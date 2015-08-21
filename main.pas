program breakthrough;
{
	Jeu de breakthrough

	Copyright 2012 Stanislas Michalak <stanislas.michalak@gmail.com>

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
	MA 02110-1301, USA.
}
uses Both, sysutils, Human, SDL, SDL_addon, SDL_TTF, SDL_image;

//Prototypes
procedure play_new_game(fenetre : PSDL_Surface ; var continuerProgramme : boolean) forward;
procedure play_old_game(fenetre : PSDL_Surface ; var continuerProgramme : boolean) forward;
procedure settings(fenetre : PSDL_Surface ; var continuerProgramme : boolean) forward;

{
	*
	*
}
procedure play_new_game(fenetre : PSDL_Surface ; var continuerProgramme : boolean);
var
	continuer : boolean;
	itemSelectionne : integer;
	event : PSDL_event;
begin
	new(event);
	itemSelectionne := 1;
	continuer := TRUE;

	while(continuer AND continuerProgramme) do
	begin
		effacer_ecran(fenetre);
		afficher_image(fenetre, 'pictures/menu.jpg', 0, 0);
		ecrire(fenetre, 'Nouvelle partie', 274, 51, './fonts/Fontasique.ttf', 42, 72, 80, 21);

		if(itemSelectionne = 1) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 172)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 172);
		ecrire(fenetre, 'Joueur contre joueur', 318, 188, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);

		if(itemSelectionne = 2) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 249)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 249);
		ecrire(fenetre, 'Joueur contre IA', 338, 264, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);

		if(itemSelectionne = 3) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 326)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 326);
		ecrire(fenetre, 'Retour au menu', 340, 340, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);
		
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
					case event^.key.keysym.sym of
						SDLK_UP :
						begin
							if(itemSelectionne = 1) then
								itemSelectionne := 3
							else
								dec(itemSelectionne);
						end;
						SDLK_DOWN :
						begin
							if(itemSelectionne = 3) then
								itemSelectionne := 1
							else
								inc(itemSelectionne);
						end;
						SDLK_RETURN :
						begin
							case itemSelectionne of
								1 :
								begin
									play_a_game(fenetre, continuerProgramme, TRUE, FALSE);
									continuer := FALSE;
								end;
								2 :
								begin
									play_a_game(fenetre, continuerProgramme, FALSE, FALSE);
									continuer := FALSE;
								end;
								3 : continuer := FALSE;
							end;
						end;
					end; 
				end;
				SDL_MOUSEBUTTONUP:
				begin
					if (event^.button.button = SDL_BUTTON_LEFT) then
					begin
						case itemSelectionne of
							1 :
							begin
								play_a_game(fenetre, continuerProgramme, TRUE, FALSE);
								continuer := FALSE;
							end;
							2 :
							begin
								play_a_game(fenetre, continuerProgramme, FALSE, FALSE);
								continuer := FALSE;
							end;
							3 : continuer := FALSE;
						end;
					end;
				end;
				SDL_MOUSEMOTION :
				begin
					if( (event^.motion.x >= 292) AND (event^.motion.x <= 511) ) then
					begin
						if( (event^.motion.y >= 172) AND (event^.motion.y <= 215) ) then
							itemSelectionne := 1
						else if( (event^.motion.y >= 249) AND (event^.motion.y <= 294) ) then
							itemSelectionne := 2
						else if( (event^.motion.y >= 326) AND (event^.motion.y <= 371) ) then
							itemSelectionne := 3;
					end;
				end;
			end;
		end;
	end;
	dispose(event);
end;

procedure play_old_game(fenetre : PSDL_Surface ; var continuerProgramme : boolean);
var sauvegarde : text; joueurContreJoueur : integer;
begin
	//Chargement du fichier de sauvegarde
	{$I-}
	assign(sauvegarde, './sauvegarde.txt');
	reset(sauvegarde);
	{$I+}

	//Si le fichier de configuration existe, on lance la partie
	if IORESULT = 0 then
	begin
		read(sauvegarde, joueurContreJoueur);
		close(sauvegarde);
		if(joueurContreJoueur = 1) then//Reprendre une partie contre un joueur
			play_a_game(fenetre, continuerProgramme, TRUE, TRUE)
		else//Reprendre une partie contre l'IA
			play_a_game(fenetre, continuerProgramme, FALSE, TRUE)
	end;
end;

procedure settings(fenetre : PSDL_Surface ; var continuerProgramme : boolean);
var
	settings : text;
	params : Array [0..1] of integer;
	i, itemSelectionne : integer;
	continuer : Boolean;
	event : PSDL_event;
begin
	new(event);
	continuer := TRUE;

	assign(settings, './settings.txt');
	reset(settings);
	
	for i:= 0 to 1 do
		read(settings, params[i]);

	close(settings);

	itemSelectionne := 1;

	while(continuer AND continuerProgramme) do
	begin
		effacer_ecran(fenetre);
		afficher_image(fenetre, 'pictures/menu.jpg', 0, 0);
		ecrire(fenetre, 'Paramètres', 300, 51, './fonts/Fontasique.ttf', 42, 72, 80, 21);

		if(itemSelectionne = 1) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 172)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 172);
		ecrire(fenetre, PChar('Hauteur : ' + intToStr(params[0])), 360, 188, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);

		if(itemSelectionne = 2) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 249)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 249);
		ecrire(fenetre, PChar('Largeur : ' + intToStr(params[1])), 360, 264, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);

		if(itemSelectionne = 3) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 326)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 326);
		ecrire(fenetre, 'Retour au menu', 340, 340, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);
		ecrire(fenetre, 'Utilisez les flèches gauche et droite pour modifier les paramètres.', 145, 550, './fonts/Fontin_Sans_R_45b.ttf', 19, 48, 34, 33);
		
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
					case event^.key.keysym.sym of
						SDLK_UP :
						begin
							if(itemSelectionne = 1) then
								itemSelectionne := 3
							else
								dec(itemSelectionne);
						end;
						SDLK_DOWN :
						begin
							if(itemSelectionne = 3) then
								itemSelectionne := 1
							else
								inc(itemSelectionne);
						end;
						SDLK_LEFT :
						begin
							if(itemSelectionne = 1) then
							begin
								if( params[0] > 5 ) then
									dec(params[0]);
							end
							else if(itemSelectionne = 2) then
							begin
								if( params[1] > 5 ) then
									dec(params[1]);
							end
						end;
						SDLK_RIGHT :
						begin
							if(itemSelectionne = 1) then
							begin
								if( params[0] < 8 ) then
									inc(params[0]);
							end
							else if(itemSelectionne = 2) then
							begin
								if( params[1] < 12 ) then
									inc(params[1]);
							end
						end;
						SDLK_RETURN :
						begin
							if itemSelectionne = 3 then
								continuer := FALSE;
						end;
					end; 
				end;
				SDL_MOUSEBUTTONUP:
				begin
					if (event^.button.button = SDL_BUTTON_LEFT) then
					begin
						if itemSelectionne = 3 then
							continuer := FALSE;
					end;
				end;
				SDL_MOUSEMOTION :
				begin
					if( (event^.motion.x >= 292) AND (event^.motion.x <= 511) ) then
					begin
						if( (event^.motion.y >= 172) AND (event^.motion.y <= 215) ) then
							itemSelectionne := 1
						else if( (event^.motion.y >= 249) AND (event^.motion.y <= 294) ) then
							itemSelectionne := 2
						else if( (event^.motion.y >= 326) AND (event^.motion.y <= 371) ) then
							itemSelectionne := 3;
					end;
				end;
			end;
		end;
	end;
	dispose(event);

	//Réécriture des paramètres
	assign(settings, './settings.txt');
	rewrite(settings);
	writeln(settings, params[0]);
	writeln(settings, params[1]);
	close(settings);
end;

var
	continuer : boolean;
	fenetre : PSDL_Surface;
	event : PSDL_event;
	itemSelectionne : integer;

begin
	SDL_Init(SDL_INIT_VIDEO); //Initialisation de la SDL
	TTF_Init(); //Initialisation de la gestion des polices

	new(event);

	fenetre := SDL_SetVideoMode(800, 600, 32, SDL_HWSURFACE OR SDL_DOUBLEBUF); // On crée une fenêtre de taille 800 x 600.
	SDL_WM_SetCaption('Breakthrough', NIL);
	SDL_EnableKeyRepeat(10, 100);

	continuer := TRUE;
	itemSelectionne := 1;

	while(continuer) do
	begin
		effacer_ecran(fenetre);
		afficher_image(fenetre, 'pictures/menu.jpg', 0, 0);
		ecrire(fenetre, 'Breakthrough', 284, 51, './fonts/Fontasique.ttf', 42, 72, 80, 21);

		if(itemSelectionne = 1) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 172)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 172);
		ecrire(fenetre, 'Nouvelle partie', 343, 188, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);

		if(itemSelectionne = 2) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 249)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 249);
		ecrire(fenetre, 'Reprendre une partie', 314, 264, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);

		if(itemSelectionne = 3) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 326)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 326);
		ecrire(fenetre, 'Paramètres', 358, 340, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);

		if(itemSelectionne = 4) then
			afficher_image(fenetre, 'pictures/item_menu_hover.png', 292, 403)
		else
			afficher_image(fenetre, 'pictures/item_menu.png', 292, 403);
		ecrire(fenetre, 'Quitter', 375, 417, './fonts/Fontin_Sans_R_45b.ttf', 19, 77, 77, 103);
		
		SDL_Flip(fenetre);
		
		while(SDL_PollEvent(event) <> 0) do
		begin
			case event^.type_ of
				SDL_QUITEV : continuer := FALSE;
				SDL_KEYDOWN :
				begin
					case event^.key.keysym.sym of
						SDLK_UP :
						begin
							if(itemSelectionne = 1) then
								itemSelectionne := 4
							else
								dec(itemSelectionne);
						end;
						SDLK_DOWN :
						begin
							if(itemSelectionne = 4) then
								itemSelectionne := 1
							else
								inc(itemSelectionne);
						end;
						SDLK_RETURN :
						begin
							case itemSelectionne of
								1 : play_new_game(fenetre, continuer);
								2 : play_old_game(fenetre, continuer);
								3 : settings(fenetre, continuer);
								4 : continuer := FALSE;
							end;
						end;
					end;
				end;
				SDL_MOUSEBUTTONUP:
				begin
					if (event^.button.button = SDL_BUTTON_LEFT) then
					begin
						case itemSelectionne of
							1 : play_new_game(fenetre, continuer);
							2 : play_old_game(fenetre, continuer);
							3 : settings(fenetre, continuer);
							4 : continuer := FALSE;
						end;
					end;
				end;
				SDL_MOUSEMOTION :
				begin
					if( (event^.motion.x >= 292) AND (event^.motion.x <= 511) ) then
					begin
						if( (event^.motion.y >= 172) AND (event^.motion.y <= 215) ) then
							itemSelectionne := 1
						else if( (event^.motion.y >= 249) AND (event^.motion.y <= 294) ) then
							itemSelectionne := 2
						else if( (event^.motion.y >= 326) AND (event^.motion.y <= 371) ) then
							itemSelectionne := 3
						else if( (event^.motion.y >= 403) AND (event^.motion.y <= 448) ) then
							itemSelectionne := 4;
					end;
				end;
			end;
		end;
	end;
	dispose(event);
	TTF_Quit();
	SDL_Quit;
end.
