/*
Copyright 2017 wgawronski@white-rook.pl

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE. HERE BE DRAGONS. AND SEGFAULTS. I AM WONDERING
IF SOMEONE ACTUALLY READING HEADERS. THIS IS NOT A DRILL. ALL YOUR BASE ARE BELONG TO US.
*/

#ifdef _WIN32
  #include <windows.h>
#else
  #include <unistd.h>
#endif

#include <time.h>
#include <stdio.h>
#include <string.h>
#include <erl_nif.h>

static int load(ErlNifEnv* env, void **priv, ERL_NIF_TERM info)
{
  srand(time(NULL));
  return 0;
}

static int reload(ErlNifEnv* env, void** priv, ERL_NIF_TERM info)
{
  return 0;
}

static int upgrade(ErlNifEnv* env, void** priv, void** old_priv, ERL_NIF_TERM info)
{
  *priv = *old_priv;
  return 0;
}

const char* DB_FILE_NAME = "persistence.db";

static void unload(ErlNifEnv* env, void* priv)
{
}

#define NO_SAVED_LINES (enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_int(env, 0)));
#define NO_RESTORED_LINES (enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_list(env, 0)))

#define MAX_SIZE 256

char* alloc_and_copy_to_cstring(ErlNifBinary *string)
{
  char* str = (char*) enif_alloc(string->size + 1);
  strncpy(str, (char*) string->data, string->size);

  str[string->size] = 0;

  return str;
}

static ERL_NIF_TERM clear_persistence(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  FILE *file = fopen(DB_FILE_NAME, "wt");

  if (file == NULL)
  {
    return enif_make_atom(env, "ok");
  }

  fflush(file);
  fclose(file);

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM persist_command(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  unsigned int lines = 1;

  FILE *file = fopen(DB_FILE_NAME, "a+t");

  if (file == NULL)
  {
    return NO_SAVED_LINES;
  }

  ErlNifBinary string;

  enif_inspect_binary(env, argv[0], &string);

  char* line = alloc_and_copy_to_cstring(&string);

  fprintf(file, "%s\n", line);

  fflush(file);
  fclose(file);

  return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_int(env, lines));
}

static ERL_NIF_TERM restore_commands(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  ERL_NIF_TERM* lines = NULL;

  FILE *file = fopen(DB_FILE_NAME, "rt");

  if (file == NULL)
  {
    return NO_RESTORED_LINES;
  }

  int character = 0;
  int lines_count = 0;

  do {
    character = fgetc(file);

    if (character == '\n') {
      lines_count++;
    }
  } while (character != EOF);

  rewind(file);

  lines = (ERL_NIF_TERM*) enif_alloc(lines_count * sizeof(ERL_NIF_TERM));

  long char_line_length = 0;
  char* char_line = NULL;
  char line[256];

  for(int i = 0; i < lines_count; ++i) {
    long result = getline(&char_line, &char_line_length, file);

    memcpy(line, char_line, strlen(char_line) - 1);
    line[strlen(char_line) - 1] = 0;

    lines[i] = enif_make_string(env, line, ERL_NIF_LATIN1);

    if (result == -1) {
      break;
    }
  }

  free(char_line);

  return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_list_from_array(env, lines, lines_count));
}

static ErlNifFunc functions[] = {
  {"persist_command", 1, persist_command},
  {"restore_commands", 0, restore_commands},
  {"clear_persistence", 0, clear_persistence}
};

ERL_NIF_INIT(Elixir.KV.Persistence, functions, &load, &reload, &upgrade, &unload)