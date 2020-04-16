import std.stdio;
import std.string : fromStringz;
import std.conv;

import bindbc.sdl;
import bindbc.sdl.image;

void main()
{
    const SDLSupport ret = loadSDL();
    if(ret != sdlSupport) {
      writeln("Error loading SDL dll");
      return;
    }
    if(loadSDLImage() != sdlImageSupport) {
      writeln("Error loading SDL Image dll");
      return;
    }

    // Initialise SDL
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        writeln("SDL_Init: ", fromStringz(SDL_GetError()));
    }
    scope(exit) {
      SDL_Quit();
    }

    // Initialise IMG
    const flags = IMG_INIT_PNG | IMG_INIT_JPG;
    if ((IMG_Init(flags) & flags) != flags) {
        writeln("IMG_Init: ", to!string(IMG_GetError()));
    }
    scope(exit) {
      IMG_Quit();
    }

    // Create a window
    SDL_Window* appWin = SDL_CreateWindow(
        "Example #1",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        800,
        600,
        SDL_WINDOW_OPENGL
    );
    if (appWin is null) {
        writefln("SDL_CreateWindow: ", SDL_GetError());
        return;
    }
    scope(exit) {
        // Close and destroy the window
        if (appWin !is null) {
            SDL_DestroyWindow(appWin);
        }
    }

    //Create and init the renderer
    SDL_Renderer* ren = SDL_CreateRenderer(appWin, -1, SDL_RENDERER_ACCELERATED);
    if( ren is null) {
        writefln("SDL_CreateRenderer: ", fromStringz(SDL_GetError()));
        return;
    }
    scope(exit) {
        // Close and destroy the renderer
        if (ren !is null) {
            SDL_DestroyRenderer(ren);
        }
    }

    // Load image
    SDL_Surface* imgSurf = IMG_Load("grumpy-cat.jpg");
    if (imgSurf is null) {
        writeln("IMG_Load: ", to!string(IMG_GetError()));
    }
    scope(exit) {
        // Close and destroy the surface
        if (imgSurf !is null) {
            SDL_FreeSurface(imgSurf);
        }
    }

    SDL_Texture* texture = SDL_CreateTextureFromSurface(ren, imgSurf);
    if( texture is null) {
        writefln("SDL_CreateTextureFromSurface: ", fromStringz(SDL_GetError()));
        return;
    }
    scope(exit) {
        // Close and destroy the texture
        if (texture !is null) {
            SDL_DestroyTexture(texture);
        }
    }


    // Polling for events
    bool quit = false;
    while(!quit) {
        SDL_PumpEvents();

        // Render something
        SDL_RenderSetLogicalSize(ren, 800, 600);

        // Set colour of renderer
        SDL_SetRenderDrawColor(ren, 255, 0, 0, 255 );

        // Clear the screen to the set colour
        SDL_RenderClear(ren );

        // Shows the image on the texture
        SDL_Rect dstrect = { 5, 5, 620, 387 };
        SDL_RenderCopy(ren, texture, null, &dstrect);

        //Show all the has been done behind the scenes
        SDL_RenderPresent(ren );

        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                quit = true;
            }

            if (event.type == SDL_KEYDOWN) {
                quit = true;
            }
        }
    }

}
