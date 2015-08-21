Unit SDL_addon;
{
	* sdl_addon.pas
	* Procédures rendant l'utilisation de la SDL plus facile
}
interface
	uses SDL, SDL_TTF, SDL_image;
	
	//Prototypes
	procedure ecrire(fenetre : PSDL_Surface ; texte : PChar ; positionTextex, positionTextey : integer ; fontName : PChar ; fontSize, couleurR, couleurV, couleurB : integer);
	procedure afficher_image(fenetre : PSDL_Surface ; url : PChar ; positionx, positiony : integer);
	procedure afficher_rectangle(fenetre : PSDL_Surface ; taillex, tailley, positionRectanglex, positionRectangley : integer ; couleurR, couleurV, couleurB, transparenceAlpha : integer);
	procedure effacer_ecran(fenetre : PSDL_Surface);
	
implementation
	procedure ecrire(fenetre : PSDL_Surface ; texte : PChar ; positionTextex, positionTextey : integer ; fontName : PChar ; fontSize, couleurR, couleurV, couleurB : integer);
	var surfaceTexte : PSDL_Surface;
	position : PSDL_Rect;
	couleur : PSDL_COLOR;
	police : pointer;
	begin
		new(couleur);
		new(position);
		couleur^.r := couleurR; couleur^.g := couleurV; couleur^.b := couleurB;
		police := TTF_OpenFont(fontName, fontSize);
		surfaceTexte := TTF_RenderUTF8_Blended(police, texte, couleur^);
		position^.x := positionTextex;
		position^.y := positionTextey;
		SDL_BlitSurface(surfaceTexte, NIL, fenetre, position);
		SDL_FreeSurface(surfaceTexte);
		TTF_CloseFont(police);
		dispose(couleur);
		dispose(position);
	end;
	
	procedure afficher_image(fenetre : PSDL_Surface ; url : PChar ; positionx, positiony : integer);
	var surfaceImage : PSDL_Surface;
	position : PSDL_Rect;
	begin
		new(position);
		position^.x := positionx;
		position^.y := positiony;
		surfaceImage := IMG_Load(url);
		SDL_BlitSurface(surfaceImage, NIL, fenetre, position);
		SDL_FreeSurface(surfaceImage);
		dispose(position);
	end;

	procedure afficher_rectangle(fenetre : PSDL_Surface ; taillex, tailley, positionRectanglex, positionRectangley : integer ; couleurR, couleurV, couleurB, transparenceAlpha : integer);
	var rectangle : PSDL_Surface;
	position : PSDL_Rect;
	begin
		new(position);
		position^.x := positionRectanglex;
		position^.y := positionRectangley;
		rectangle := SDL_CreateRGBSurface(SDL_HWSURFACE, taillex, tailley, 32, 0, 0, 0, 0);
		SDL_SetAlpha(rectangle, SDL_SRCALPHA OR SDL_RLEACCEL, transparenceAlpha);
		SDL_FillRect(rectangle, NIL, SDL_MapRGB(fenetre^.format, couleurR, couleurV, couleurB));
		SDL_BlitSurface(rectangle, NIL, fenetre, position);
		SDL_FreeSurface(rectangle);
		dispose(position);
	end;
	
	procedure effacer_ecran(fenetre : PSDL_Surface);
	begin
		SDL_FillRect(fenetre, NIL, SDL_MapRGB(fenetre^.format, 40, 40, 40));
	end;
	
begin
     {Corps du module SDL_addon}
end.
