Unit Both;
{
	* both.pas
	* Fonctions communes aux deux modes de jeu
}
interface
	//Librairies
	uses SDL, SDL_addon;

	//Types
	type
		arrayplateau = array of array of integer;
		coordonnees = record
			x, y : integer;
		end;

	procedure check_gagne(plateau : arrayplateau; var blancGagne : boolean; var noirGagne : boolean);
	function check_collisions(plateau : arrayplateau; pionCurrent, pionVoulu : coordonnees) : boolean;
	procedure init_map(var plateau : arrayplateau);

implementation
	procedure check_gagne(plateau : arrayplateau; var blancGagne : boolean; var noirGagne : boolean);
	var i, j, nbDeNoirs, nbDeBlancs : integer;
	begin

		nbDeBlancs := 0;
		nbDeNoirs := 0;

		for i := low(plateau[0]) to high(plateau[0]) do
		begin
			if( plateau[0,i] = 2 ) then
			begin
				//Si l'un des pions blancs est arrivé à la première ligne (donc celle des noirs), alORs les blancs ont gagné
				blancGagne := TRUE;
				exit();
			end;
		end;
		
		for i := low(plateau[0]) to high(plateau[0]) do
		begin
			if( plateau[high(plateau),i] = 1 ) then
			begin
				//Si l'un des pions noirs est arrivé à la dernière ligne (donc celle des blancs), alORs les noirs ont gagné
				noirGagne := TRUE;
				exit();
			end;
		end;

		//Sinon, on vérifie si l'un des joueurs n'a plus aucun pion
		for i := low(plateau) to high(plateau) do
		begin
			for j := low(plateau[0]) to high(plateau[0]) do
			begin
				if(plateau[i,j] = 1) then
					inc(nbDeNoirs)
				else if(plateau[i,j] = 2) then
					inc(nbDeBlancs);
			end;
		end;

		if(nbDeNoirs = 0) then
		begin
			blancGagne := TRUE;
			exit();
		end
		else if(nbDeBlancs = 0) then
		begin
			noirGagne := TRUE;
			exit();
		end
	end;
	
	function check_collisions(plateau : arrayplateau; pionCurrent, pionVoulu : coordonnees) : boolean;
	begin
		if(pionVoulu.x >= low(plateau[0])) then//Limite gauche
		begin
			if(pionVoulu.x <= high(plateau[0])) then//Limite droite
			begin
				if(pionVoulu.y >= low(plateau)) then//Limite haut
				begin
					if(pionVoulu.y <= high(plateau)) then//Limite bas
					begin
						if( plateau[pionVoulu.y, pionVoulu.x] <> plateau[pionCurrent.y, pionCurrent.x] ) then//Le joueur ne peut pas manger son propre pion
						begin
							//On vérifie maintenant que le coup demandé fait partie des coups possibles
							if( ( pionVoulu.x = (pionCurrent.x - 1) ) OR ( pionVoulu.x = pionCurrent.x ) OR ( pionVoulu.x = (pionCurrent.x + 1) ) ) then
							begin
								if( plateau[pionCurrent.y, pionCurrent.x] = 1 ) then
								begin
									//Le joueur noir ne peut aller que vers le bas
									if( pionVoulu.y = (pionCurrent.y + 1) ) then
									begin
										if((plateau[pionVoulu.y, pionVoulu.x] = 2) AND (pionVoulu.x = pionCurrent.x)) then
											check_collisions := FALSE
										else
											check_collisions := TRUE;
									end
									else
										check_collisions := FALSE;
								end
								else
								begin
									//Le joueur blanc ne peut aller que vers le haut
									if( pionVoulu.y = (pionCurrent.y - 1) ) then
									begin
										if((plateau[pionVoulu.y, pionVoulu.x] = 1) AND (pionVoulu.x = pionCurrent.x)) then
											check_collisions := FALSE
										else
											check_collisions := TRUE;
									end
									else
										check_collisions := FALSE;
								end;
							end
							else
								check_collisions := FALSE;
						end
						else
							check_collisions := FALSE;	
					end
					else
						check_collisions := FALSE;
				end
				else
					check_collisions := FALSE;
			end
			else
				check_collisions := FALSE;
		end
		else
			check_collisions := FALSE;
		
	end;

	procedure init_map(var plateau : arrayplateau);
	var i, j : integer;
	begin
		for i := low(plateau) to high(plateau) do
		begin
			 for j := low(plateau[0]) to high(plateau[0]) do
			 begin
				if (i < 2) then
					plateau[i,j] := 1//Pions noirs
				else if (i > high(plateau) - 2) then
					plateau[i,j] := 2//Pions blancs
				else
					plateau[i,j] := 0;
			 end;
		end;
	end;

begin
	{Corps du module both}
end.
