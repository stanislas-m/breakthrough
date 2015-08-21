Unit Human;
{
	* humain.pas
	* Fonctions gérant une partie et les actions propres au joueur humain
}
interface
	//Librairies
	uses Both, IA, SDL, SDL_addon;
	
	//Prototypes
	procedure play_a_game(fenetre : PSDL_Surface ; var continuerProgramme : boolean ; joueurVsJoueur, playOldGame : boolean);
	procedure tour_joueur(fenetre : PSDL_Surface ; var plateau : arrayplateau; noir, joueurContreJoueur : boolean ; var continuerProgramme : boolean ; var continuerPartie : boolean);
	procedure display_map(fenetre : PSDL_Surface ; plateau : arrayplateau ; positionCurseur : coordonnees ; noirGagne, blancGagne : boolean);

implementation

	procedure play_a_game(fenetre : PSDL_Surface ; var continuerProgramme : boolean ; joueurVsJoueur, playOldGame : boolean);
	var
		joueurNoirGagne, joueurBlancGagne, continuer, continuerPartie : boolean;
		plateau : arrayplateau;
		settings, sauvegarde : text; params : array [0..1] of integer; i, j, sauvegardeCurrent : integer;
		currentPosition : coordonnees;
		event : PSDL_event;
	begin
		//Chargement du fichier de configuration 
		{$I-}
		assign(settings, './settings.txt');
		reset(settings);
		{$I+}

		//Si le fichier de configuration n'existe pas, on affiche une erreur et on retourne au menu.
		if IORESULT <> 0 then
		begin
			new(event);
			continuer := TRUE;
			continuerPartie := TRUE;
			
			while(continuer AND continuerProgramme) do
			begin
				effacer_ecran(fenetre);
				afficher_image(fenetre, 'pictures/game.jpg', 0, 0);
				if(joueurVsJoueur) then
					ecrire(fenetre, 'Joueur contre joueur', 220, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29)
				else
					ecrire(fenetre, 'Joueur contre IA', 245, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29);
				ecrire(fenetre, 'Le fichier de configuration est introuvable.', 318, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33);
				SDL_Flip(fenetre);

				while(SDL_PollEvent(event) <> 0) do
				begin
					case event^.type_ of
						SDL_QUITEV :
						begin
							continuerProgramme := FALSE;
						end;
						SDL_KEYDOWN :
						begin
							if event^.key.keysym.sym = SDLK_RETURN then 
								continuer := FALSE;
						end;
					end;
				end;
			end;
			dispose(event);
			exit;
		end;

		//Sinon, on continue.
		for i:= 0 to 1 do
			read(settings, params[i]);

		close(settings);

		if(playOldGame) then
		begin
			assign(sauvegarde, './sauvegarde.txt');
			reset(sauvegarde);

			//On passe la ligne de choix de partie
			read(sauvegarde, sauvegardeCurrent);

			//On récupère les dimensions du plateau
			read(sauvegarde, params[0]);
			read(sauvegarde, params[1]);

			//On créé le plateau correspondant
			setLength(plateau, params[1], params[0]);

			for i := 0 to params[1] - 1 do
			begin
				for j := 0 to params[0] - 1 do
				begin
					//Et on charge le plateau
					read(sauvegarde, sauvegardeCurrent);
					plateau[i,j] := sauvegardeCurrent;
				end;
			end;
			close(sauvegarde);
		end
		else
		begin
			//On créé le plateau de jeu
			setLength(plateau, params[0], params[1]);
			init_map(plateau);
		end;
			
		currentPosition.x := -1;
		currentPosition.y := -1;

		//par défaut, personne n'a gagné
		joueurNoirGagne := FALSE;
		joueurBlancGagne := FALSE;
		
		repeat
			tour_joueur(fenetre, plateau, TRUE, joueurVsJoueur, continuerProgramme, continuerPartie);	
			check_gagne(plateau, joueurBlancGagne, joueurNoirGagne);
			
			if(joueurNoirGagne) then
				break;

			if(joueurVsJoueur) then
				tour_joueur(fenetre, plateau, FALSE, joueurVsJoueur, continuerProgramme, continuerPartie)
			else
				tour_IA(plateau);
				
			check_gagne(plateau, joueurBlancGagne, joueurNoirGagne);
		until(joueurBlancGagne OR joueurNoirGagne OR NOT(continuerProgramme) OR NOT(continuerPartie));

		new(event);
		continuer := TRUE;
		
		while(continuer AND continuerProgramme AND continuerPartie) do
		begin
			effacer_ecran(fenetre);
			afficher_image(fenetre, 'pictures/game.jpg', 0, 0);

			if(joueurVsJoueur) then
				ecrire(fenetre, 'Joueur contre joueur', 220, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29)
			else
				ecrire(fenetre, 'Joueur contre IA', 245, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29);
				
			if(joueurBlancGagne) then
				ecrire(fenetre, 'Luigi a gagné ! Appuyez sur entrée pour revenir au menu.', 155, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33)
			else
				ecrire(fenetre, 'Mario a gagné ! Appuyez sur entrée pour revenir au menu.', 155, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33);
			display_map(fenetre, plateau, currentPosition, joueurNoirGagne, joueurBlancGagne);
			SDL_Flip(fenetre);

			while(SDL_PollEvent(event) <> 0) do
			begin
				case event^.type_ of
					SDL_QUITEV :
					begin
						continuerProgramme := FALSE;
					end;
					SDL_KEYDOWN :
					begin
						if event^.key.keysym.sym = SDLK_RETURN then 
							continuer := FALSE;
					end;
				end;
			end;
		end;
		
		dispose(event);
		finalize(plateau);
	end;

	procedure tour_joueur(fenetre : PSDL_Surface ; var plateau : arrayplateau; noir, joueurContreJoueur : boolean ; var continuerProgramme : boolean ; var continuerPartie : boolean);
	const 
		TAILLE_CASE = 54;
	var
		currentPosition, wishedPosition : coordonnees;
		currentOk, whishedOk, confirmerContinuer : boolean;
		event : PSDL_event;
		i, j : integer;
		sauvegarde : text;
	begin
		currentOk := FALSE;
		whishedOk := FALSE;
		confirmerContinuer := FALSE;
		currentPosition.x := -1;
		currentPosition.y := -1;
		new(event);
		repeat
			effacer_ecran(fenetre);
			afficher_image(fenetre, 'pictures/game.jpg', 0, 0);

			if(joueurContreJoueur) then
				ecrire(fenetre, 'Joueur contre joueur', 220, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29)
			else
				ecrire(fenetre, 'Joueur contre IA', 245, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29);
				
			if( noir ) then
				ecrire(fenetre, 'C''est au tour de Mario !', 300, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33)
			else
				ecrire(fenetre, 'C''est au tour de Luigi !', 300, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33);

			while(SDL_PollEvent(event) <> 0) do
			begin
				case event^.type_ of
					SDL_QUITEV :
					begin
						continuerProgramme := FALSE;
					end;
					SDL_KEYDOWN :
					begin
						if event^.key.keysym.sym = SDLK_ESCAPE then 
							confirmerContinuer := TRUE;
					end;
					SDL_MOUSEBUTTONUP :
					begin
						if(event^.button.button = SDL_BUTTON_LEFT) then
						begin
							if(NOT(currentOk)) then
							begin
								currentPosition.x := (event^.button.x - fenetre^.w div 2 + (length(plateau[0]) * TAILLE_CASE) div 2) div TAILLE_CASE;
								currentPosition.y := (event^.button.y - fenetre^.h div 2 + (length(plateau) * TAILLE_CASE) div 2) div TAILLE_CASE;
								
								if( (currentPosition.x >= low(plateau[0])) AND (currentPosition.x <= high(plateau[0])) ) then
								begin
									if( (currentPosition.y >= low(plateau)) AND (currentPosition.y <= high(plateau)) ) then
									begin
										if( (noir AND (plateau[currentPosition.y, currentPosition.x] = 1)) OR (NOT(noir) AND (plateau[currentPosition.y, currentPosition.x] = 2)) ) then
											currentOk := TRUE
										else
										begin
											currentOk := FALSE;
											currentPosition.x := -1;
											currentPosition.y := -1;
										end;
									end
									else
									begin
										currentOk := FALSE;
										currentPosition.x := -1;
										currentPosition.y := -1;
									end;
								end
								else
								begin
									currentOk := FALSE;
									currentPosition.x := -1;
									currentPosition.y := -1;
								end
							end
							else
							begin
								wishedPosition.x := (event^.button.x - fenetre^.w div 2 + (length(plateau[0]) * TAILLE_CASE) div 2) div TAILLE_CASE;
								wishedPosition.y := (event^.button.y - fenetre^.h div 2 + (length(plateau) * TAILLE_CASE) div 2) div TAILLE_CASE;
								
								if( NOT(check_collisions( plateau, currentPosition, wishedPosition ) ) ) then
								begin
									whishedOk := FALSE;
									currentOk := FALSE;
									wishedPosition.x := -1;
									wishedPosition.y := -1;
								end
								else
								begin
									whishedOk := TRUE;
									break;
								end;
							end;
						end
						else if(event^.button.button = SDL_BUTTON_RIGHT) then
						begin
							currentOk := FALSE;
							whishedOk := FALSE;
							currentPosition.x := -1;
							currentPosition.y := -1;
							wishedPosition.x := -1;
							wishedPosition.y := -1;
						end;
					end;
				end;
			end;

			display_map(fenetre, plateau, currentPosition, FALSE, FALSE);

			//Si l'on a demandé à quitter la partie
			while(confirmerContinuer AND continuerProgramme) do
			begin
				effacer_ecran(fenetre);
				afficher_image(fenetre, 'pictures/game.jpg', 0, 0);

				if(joueurContreJoueur) then
					ecrire(fenetre, 'Joueur contre joueur', 220, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29)
				else
					ecrire(fenetre, 'Joueur contre IA', 245, 20, './fonts/Fontasique.ttf', 42, 210, 73, 29);
					
				if( noir ) then
					ecrire(fenetre, 'C''est au tour de Mario !', 300, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33)
				else
					ecrire(fenetre, 'C''est au tour de Luigi !', 300, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33);

				display_map(fenetre, plateau, currentPosition, FALSE, FALSE);

				afficher_rectangle(fenetre, 350, 120, 225, 200, 255, 255, 255, 230);
				ecrire(fenetre, 'Voulez-vous vraiment quitter la partie ?', 230, 230, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33);
				ecrire(fenetre, 'Entrée : oui. Échap : non.', 290, 270, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33);

				SDL_Flip(fenetre);
					
				while(SDL_PollEvent(event) <> 0) do
				begin
					case event^.type_ of
						SDL_QUITEV :
						begin
							continuerProgramme := FALSE;
						end;
						SDL_KEYDOWN :
						begin
							if event^.key.keysym.sym = SDLK_ESCAPE then
								confirmerContinuer := FALSE
							else if event^.key.keysym.sym = SDLK_RETURN then
							begin
								//Sauvegarde de la partie
								assign(sauvegarde, './sauvegarde.txt');
								rewrite(sauvegarde);

								if joueurContreJoueur then
									writeln(sauvegarde, 1)
								else
									writeln(sauvegarde, 0);
								writeln(sauvegarde, length(plateau[0]));
								writeln(sauvegarde, length(plateau));

								for i := low(plateau) to high(plateau) do
									for j := low(plateau[0]) to high(plateau[0]) do
										writeln(sauvegarde, plateau[i,j]);

								close(sauvegarde);

								//Maintenant, on peut quitter la partie
								continuerPartie := FALSE;
								confirmerContinuer := FALSE;
							end;
						end;
					end;
				end;
			end;

			SDL_Flip(fenetre);
			
		until whishedOk OR NOT(continuerProgramme) OR NOT(continuerPartie);
		dispose(event);

		if( continuerProgramme AND continuerPartie ) then
		begin
			//On peut déplacer le pion
			plateau[wishedPosition.y, wishedPosition.x] := plateau[currentPosition.y, currentPosition.x];
			plateau[currentPosition.y, currentPosition.x] := 0;
			effacer_ecran(fenetre);
			currentPosition.x := -1;
			currentPosition.y := -1;
			display_map(fenetre, plateau, currentPosition, FALSE, FALSE);
			SDL_Flip(fenetre);
		end;
	end;
	
	procedure display_map(fenetre : PSDL_Surface ; plateau : arrayplateau ; positionCurseur : coordonnees ; noirGagne, blancGagne : boolean);
	const
		PION_BLANC = './pictures/pion_blanc.png';
		PION_NOIR = './pictures/pion_noir.png';
		PION_BLANC_HOVER = './pictures/pion_blanc_hover.png';
		PION_NOIR_HOVER = './pictures/pion_noir_hover.png';
		PION_BLANC_WIN = './pictures/pion_blanc_win.png';
		PION_NOIR_WIN = './pictures/pion_noir_win.png';
		PION_BLANC_LOSE = './pictures/pion_blanc_lose.png';
		PION_NOIR_LOSE = './pictures/pion_noir_lose.png';
		TAILLE_CASE = 54;
	var
		i, j : integer;
		 positionSurface : coordonnees;
		 caseNoire : boolean;
	begin
		positionSurface.y := (fenetre^.h div 2) - ((TAILLE_CASE * length(plateau)) div 2);
		caseNoire := FALSE;
	
		for i := low(plateau) to high(plateau) do
		begin
			positionSurface.x := (fenetre^.w div 2) - ((TAILLE_CASE * length(plateau[0])) div 2);

			if(length(plateau[0]) mod 2 = 0) then
			begin
				if(caseNoire) then
					caseNoire := FALSE
				else
					caseNoire := TRUE;
			end;

			for j := low(plateau[0]) to high(plateau[0]) do
			begin
				if( caseNoire ) then
				begin
					afficher_rectangle(fenetre, TAILLE_CASE, TAILLE_CASE, positionSurface.x, positionSurface.y, 0, 0, 0, 200);
					caseNoire := FALSE;
				end
				else
				begin
					afficher_rectangle(fenetre, TAILLE_CASE, TAILLE_CASE, positionSurface.x, positionSurface.y, 255, 255, 255, 200);
					caseNoire := TRUE;
				end;
				
				case plateau[i,j] of
					1 :
					begin
						if noirGagne then
							afficher_image(fenetre, PION_NOIR_WIN, positionSurface.x, positionSurface.y)
						else if blancGagne then
							afficher_image(fenetre, PION_NOIR_LOSE, positionSurface.x, positionSurface.y)
						else if( (positionCurseur.x = j) AND (positionCurseur.y = i) ) then
							afficher_image(fenetre, PION_NOIR_HOVER, positionSurface.x, positionSurface.y)
						else
							afficher_image(fenetre, PION_NOIR, positionSurface.x, positionSurface.y);
					end;
					2 :
					begin
						if noirGagne then
							afficher_image(fenetre, PION_BLANC_LOSE, positionSurface.x, positionSurface.y)
						else if blancGagne then
							afficher_image(fenetre, PION_BLANC_WIN, positionSurface.x, positionSurface.y)
						else if( (positionCurseur.x = j) AND (positionCurseur.y = i) ) then
							afficher_image(fenetre, PION_BLANC_HOVER, positionSurface.x, positionSurface.y)
						else
							afficher_image(fenetre, PION_BLANC, positionSurface.x, positionSurface.y);
					end;
				end;
				positionSurface.x := positionSurface.x + TAILLE_CASE;
			end;
			positionSurface.y := positionSurface.y + TAILLE_CASE;
		end;
	end;
	
begin
     {Corps du module Human}
end.
