Unit IA;
{
	* ia.pas
	* Fonctions propres à l'ia basé sur l'algORithme minMax
}
interface
	//Librairies
	uses Both, SDL, SDL_addon;

	Type 	arrayofinteger = array of array of integer ;
	ptr_noeud = ^noeud;
	noeud = record
		plateau : arrayofinteger;
		
		
	end;
	liste = ^list;
	list = record
		valeur : integer;
		suivant : liste;
		x : integer;
		y : integer;
		dx : integer;
		dy :integer;
	end;
	coups = record
		x : integer;
		y : integer;
		dx : integer;
		dy : integer;
	end;
	arrayint = array of integer;
	
	//Prototypes
	procedure tour_IA(var plateau : arrayplateau);
	procedure min(l : liste ; var x, y, dx, dy, min_max : integer);
	procedure max(l : liste ; var x, y, dx, dy, min_max : integer);
	function defaite(p : ptr_noeud) : boolean;
	function victoire(p : ptr_noeud) : boolean;
	function evaluation(p : ptr_noeud ; evalMax : boolean) : integer;
	function cases_jouables(T : arrayofinteger ; joueur, x, y : integer) : boolean;
	function coups_jouables(p : ptr_noeud ; evalMax : boolean) : boolean;
	procedure effacer_liste(l : liste);
	function ajouter(p : liste ; n, x, y, dx, dy : integer) : liste;
	function applique(coup : coups ; p : ptr_noeud) : ptr_noeud;
	function min_max(p : ptr_noeud ; profondeur : integer ; evalMax : boolean ; var x, y, dx, dy : integer) : integer;

implementation
	procedure tour_IA(var plateau : arrayplateau);
	var p : ptr_noeud ; xt, yt, dx, dy, i, j : integer;
	begin
		new(p);
		setlength(p^.plateau, length(plateau), length(plateau[0]));

		for i := low(plateau) to high(plateau) do
			for j := low(plateau[0]) to high(plateau[0]) do
				p^.plateau[i, j] := plateau[i, j];
				
		min_max(p, 3, TRUE, xt, yt, dx, dy);

		plateau[xt, yt] := 0;
		plateau[xt + dx, yt + dy] := 2;

		dispose(p);
	end;

	procedure min(l : liste ; var x, y, dx, dy, min_max : integer);
	var mini, xm, ym, dxm, dym : integer;
	begin
		if l = nil then
			min_max := 0
		else
		begin
			mini := l^.valeur;
			xm := l^.x;
			ym := l^.y;
			dxm := l^.dx;
			dym := l^.dy;
			while l <> nil do
			begin
				if l^.valeur < mini then 
				begin
					mini := l^.valeur;
					xm := l^.x;
					ym := l^.y;
					dxm := l^.dx;
					dym := l^.dy;	
				end;
				l := l^.suivant;
			end;
			x := xm;
			y := ym;
			dx := dxm;
			dy := dym;
			min_max := mini
		end;			
	end;

	procedure max(l : liste ; var x, y, dx, dy, min_max : integer);
	var maxi : integer ;
	begin
		if l = nil then
			min_max := 0
		else
		begin		
			maxi := l^.valeur;
			while l <> nil do
			begin
				if l^.valeur >= maxi then 
				begin
					x := l^.x;
					y := l^.y;
					dx := l^.dx;
					dy := l^.dy;
					maxi := l^.valeur;
				end;
				l := l^.suivant;
			end;
			min_max := maxi;
		end;
	end;

	function defaite(p : ptr_noeud) : boolean;
	var i : integer;
	begin
		for i := low(p^.plateau[0]) to high(p^.plateau[0]) do
		begin
			if p^.plateau[high(p^.plateau[0]), i] = 1 then 
			begin
				defaite := true;
				exit();
			end;
		end;
		defaite := false;
	end;

	function victoire(p : ptr_noeud) : boolean;
	var i : integer;
	begin
		for i := low(p^.plateau[0]) to high(p^.plateau[0]) do
		begin
			if p^.plateau[0, i] = 2 then 
			begin
				victoire := true;
				exit();
			end;
		end;
		victoire := false;
	end;

	function verifValidXY(x, y : integer; T : arrayofinteger) : boolean;
	begin 
		if ((x >= 0) and (y >= 0) and (x <= length(T)) and (y <= length(T[0]))) then
			verifValidXY := true
		else
			verifValidXY := false
	end; 

	function evaluation(p : ptr_noeud ; evalMax : boolean) : integer;
	var res, i, j : integer;
	begin
		res := 0;
		if victoire(p) then 
			evaluation := MAXINT
		else
		begin
			if defaite(p) then
				evaluation := -MAXINT
			else 
			begin
				for i := low(p^.plateau) to high(p^.plateau) do
				begin
					for j := low(p^.plateau[0]) to high(p^.plateau[0]) do
					begin
						if p^.plateau[i, j] = 2 then
						begin
							res := res + 500 + (high(p^.plateau) - i) * (high(p^.plateau) - i);
							if evalMax and ((verifValidXY(i - 1, j + 1, p^.plateau) and (p^.plateau[i - 1, j + 1] = 1)) OR (verifValidXY(i - 1, j - 1, p^.plateau) and (p^.plateau[i - 1, j - 1] = 1))) then
								res := res + 500
							else if not(evalMax) and((verifValidXY(i - 1, j + 1, p^.plateau) and (p^.plateau[i - 1, j + 1] = 1)) OR (verifValidXY(i - 1, j - 1, p^.plateau) and (p^.plateau[i - 1, j - 1] = 1))) then
								res := res - 500;
						end
						else
						begin
							if (p^.plateau[i, j] = 1)  then 
								res := res - 500;
						end;
					end;
				end;
				evaluation := res + 200;
			end;
		end;
	end;

	function cases_jouables(T : arrayofinteger ; joueur, x, y : integer) : boolean;
	var bool : boolean;
	begin
		bool := false;	
		if joueur = 1 then 
		 bool := ( verifValidXY(x + 1, y + 1, T) and ((T[x + 1, y + 1] = 0) OR (T[x + 1, y + 1] = 2)) ) OR (verifValidXY(x + 1, y - 1, T) and ( (T[x + 1, y - 1] = 2) OR (T[x + 1, y - 1] = 0)) ) OR (verifValidXY(x + 1, y, T) and (T[x + 1, y] = 0) ) 
		else 
			bool :=	(verifValidXY(x - 1, y + 1, T) and ((T[x - 1, y + 1] = 0) OR (T[x - 1, y + 1] = 1))) OR (verifValidXY(x - 1, y - 1, T)  and ((T[x - 1, y - 1] = 0) OR (T[x - 1, y - 1] = 1))) OR (verifValidXY(x - 1, y, T) and (T[x - 1, y] = 0)); 
			
		cases_jouables := bool; 
	end;

	function coups_jouables(p : ptr_noeud ; evalMax : boolean) : boolean;
	var bool : boolean ; i, j : integer;
	begin
		bool := false;
		for i := low(p^.plateau) to high(p^.plateau) do
		begin
			for j := low(p^.plateau[0]) to high(p^.plateau[0]) do
			begin
				if evalMax then
				begin
					if p^.plateau[i, j] = 2 then
						bool := bool OR cases_jouables(p^.plateau, 2, i, j);
				end
				else
					if p^.plateau[i, j] = 1 then
						bool := bool OR cases_jouables(p^.plateau, 1, i, j);
			end;
		end;
		coups_jouables := bool;
	end;

	procedure effacer_liste(l : liste);
	var l2 : liste;
	begin
		while l <> nil do
		begin
			l2 := l^.suivant;
			dispose(l);
			l := l2;
		end;
	end;

	function ajouter(p : liste ; n, x, y, dx, dy : integer) : liste;
	var l : liste;
	begin
		if (dx = 0) and (dy = 0) then
			ajouter := p
		else
		begin
			new(l);
			l^.x := x;
			l^.y := y;
			l^.dx := dx;
			l^.dy := dy;
			l^.valeur := n;
			l^.suivant := p;
			ajouter := l;
		end;
	end;

	function applique(coup : coups ; p : ptr_noeud) : ptr_noeud;
	var p2 : ptr_noeud ; i, j : integer;
	begin
		new(p2);

		setlength(p2^.plateau, length(p^.plateau), length(p^.plateau[0]));
		for i := low(p^.plateau) to high(p^.plateau) do 
			for j := low(p^.plateau[0]) to high(p^.plateau[0]) do
				p2^.plateau[i,j] := p^.plateau[i,j];

		if verifValidXY(coup.x, coup.y, p2^.plateau) and verifValidXY(coup.x + coup.dx, coup.y + coup.dy, p2^.plateau) then
		begin
			p2^.plateau[coup.x + coup.dx, coup.y + coup.dy] := p2^.plateau[coup.x, coup.y];
			p2^.plateau[coup.x,coup.y] := 0;	
		end;
		applique := p2;
	end;

	function min_max(p : ptr_noeud ; profondeur : integer ; evalMax : boolean ; var x, y, dx, dy : integer) : integer;
	var l : liste ; coup : coups ; minimax, xm, ym, dxm, dym, i, j : integer;
	begin
		new(l);
		l := nil;
		if (profondeur = 0) OR victoire(p) OR defaite(p) then	
			min_max := evaluation(p, evalMax)
		else 
		begin
			for i := low(p^.plateau) to high(p^.plateau) do
			begin
				for j := low(p^.plateau[0]) to high(p^.plateau[0]) do
				begin
					if not(evalMax) and (p^.plateau[i,j] = 1) and cases_jouables(p^.plateau, 1, i, j) then 
					begin
						coup.x := i;
						coup.y := j;
						if verifValidXY(i + 1, j, p^.plateau) and (p^.plateau[i + 1, j] = 0) then
						begin
							coup.dx := 1;
							coup.dy := 0;
							 l := ajouter(l, min_max(applique(coup, p), profondeur - 1, not(evalMax), x, y, dx, dy), coup.x, coup.y, coup.dx, coup.dy);
						end;	
						if verifValidXY(i + 1, j + 1, p^.plateau) and (p^.plateau[i + 1, j + 1] <> 1) then
						begin
							coup.dx := 1;
							coup.dy := 1;
							l := ajouter(l, min_max(applique(coup, p), profondeur - 1, not(evalMax), x, y, dx, dy), coup.x, coup.y, coup.dx, coup.dy);
						end;	
						if verifValidXY(i + 1, j - 1, p^.plateau) and (p^.plateau[i + 1, j - 1] <> 1) then
						begin
							coup.dx := 1;
							coup.dy := -1;
							l := ajouter(l, min_max(applique(coup, p), profondeur - 1, not(evalMax), x, y, dx, dy), coup.x, coup.y, coup.dx, coup.dy);
						end;
					end;				
					if evalMax and (p^.plateau[i, j] = 2) and cases_jouables(p^.plateau, 2, i, j) then
					begin
						coup.x := i;
						coup.y := j;
						if verifValidXY(i - 1, j, p^.plateau) and (p^.plateau[i - 1, j] = 0) then
						begin
							coup.dx := -1;
							coup.dy := 0;
							l := ajouter(l, min_max(applique(coup, p), profondeur - 1, not(evalMax) ,x , y, dx, dy), coup.x, coup.y, coup.dx, coup.dy);
						end;
						if verifValidXY(i - 1, j + 1, p^.plateau) and (p^.plateau[i - 1, j + 1] <> 2) then
						begin
							coup.dx := -1;
							coup.dy := 1;
							l := ajouter(l, min_max(applique(coup, p), profondeur - 1, not(evalMax), x, y, dx, dy), coup.x, coup.y, coup.dx, coup.dy);
						end;	
						if verifValidXY(i - 1, j - 1, p^.plateau) and (p^.plateau[i - 1, j - 1] <> 2) then
						begin
							coup.dx := -1;
							coup.dy := 1;
							l := ajouter(l, min_max(applique(coup, p), profondeur - 1, not(evalMax) , x, y, dx, dy), coup.x, coup.y, coup.dx, coup.dy);
						end;					
					end;				
				end;
			end;
			
			if evalMax then
				max(l, xm, ym, dxm, dym, minimax)					
			else  
				min(l, xm, ym, dxm, dym, minimax);
				
			effacer_liste(l);
			x := xm;
			y := ym;
			dx := dxm;
			dy := dym;
			min_max := minimax;
		end;
	end;

begin
	{CORps du module IA}
end.
