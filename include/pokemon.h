#ifndef POKEMON_H
#define POKEMON_H

/*************************************/
/* Pokemon struct related functions  */
/* If you add more to this header,   */
/* Please commit them to the repo.   */
/* Make syre you also input correct  */
/* offsets in rom.ld                 */
/*************************************/

#include "types.h"


u32 __attribute__((long_call))GetMonData(int * a2,int id,void *buf);
void * __attribute__((long_call)) PokeStatusGet(void* a1);
void * __attribute__((long_call))PokemonAlloc(u32 heap);
void __attribute__((long_call))PokeReplace(void*,void*);
void __attribute__((long_call))FreeSystem(void*);
void __attribute__((long_call))FillWindowPixelBuffer(void*,u8);
void __attribute__((long_call))ConvertNumToString(void*,u32,u32,u8,u8);
void __attribute__((long_call))StringPut(void*,void*,u32,u32);
void __attribute__((long_call))PutWindows(void*);
#endif