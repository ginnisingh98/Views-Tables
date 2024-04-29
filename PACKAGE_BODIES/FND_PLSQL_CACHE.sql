--------------------------------------------------------
--  DDL for Package Body FND_PLSQL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PLSQL_CACHE" AS
/* $Header: AFUTPSCB.pls 120.1.12010000.1 2008/07/25 14:23:34 appldev ship $ */

-- ----------------------------------------------------------------------
-- Error codes
--
ERROR_WHEN_OTHERS              CONSTANT NUMBER := -20001;
ERROR_MAX_NUMOF_KEYS           CONSTANT NUMBER := -20002;
ERROR_MAX_NUMOF_VALUES         CONSTANT NUMBER := -20003;
ERROR_MAX_NUMOF_VALUES_PER_KEY CONSTANT NUMBER := -20004;

-- ----------------------------------------------------------------------
-- Implementation constants
--
-- CACHE_EXTENT_SIZE :
--    Every time we need more indexes to put values, then cache storage
--    size is extended by 128.
--
CACHE_EXTENT_SIZE              CONSTANT NUMBER := 128;
g_newline                      VARCHAR2(100);

-- ----------------------------------------------------------------------
-- Global variables
--
g_error_code NUMBER;

-- ----------------------------------------------------------------------
PROCEDURE raise_error(p_error_code IN NUMBER,
                      p_error_text IN VARCHAR2)
  IS
BEGIN
   --
   -- Record the actual error code
   --
   g_error_code := p_error_code;

   raise_application_error(p_error_code, p_error_text);
END raise_error;

-- ----------------------------------------------------------------------
PROCEDURE raise_1to1_error(p_controller IN cache_1to1_controller_type,
                           p_error_code IN NUMBER,
                           p_error_text IN VARCHAR2)
  IS
     l_error_text     VARCHAR2(32000);
     l_newline_indent VARCHAR2(2000);
BEGIN
   l_newline_indent := g_newline || Rpad(' ', 11, ' ');

   l_error_text := p_error_text || l_newline_indent ||
     'cache type     : ' || p_controller.cache_type || ' 1to1' || l_newline_indent ||
     'cache name     : ' || p_controller.name || l_newline_indent ||
     'max numof keys : ' || p_controller.max_numof_keys || l_newline_indent ||
     'numof keys     : ' || p_controller.numof_keys;

   raise_error(p_error_code, l_error_text);
END raise_1to1_error;

-- ----------------------------------------------------------------------
PROCEDURE raise_1tom_error(p_controller IN cache_1tom_controller_type,
                           p_error_code IN NUMBER,
                           p_error_text IN VARCHAR2)
  IS
     l_error_text     VARCHAR2(32000);
     l_newline_indent VARCHAR2(2000);
BEGIN
   l_newline_indent := g_newline || Rpad(' ', 11, ' ');

   l_error_text := p_error_text || l_newline_indent ||
     'cache type              : ' || p_controller.cache_type || ' 1tom' || l_newline_indent ||
     'cache name              : ' || p_controller.name || l_newline_indent ||
     'max numof keys          : ' || p_controller.max_numof_keys || l_newline_indent ||
     'numof keys              : ' || p_controller.numof_keys || l_newline_indent ||
     'numof values            : ' || p_controller.numof_values || l_newline_indent ||
     'maxof available indexes : ' || p_controller.maxof_available_indexes || l_newline_indent ||
     'numof available indexes : ' || p_controller.numof_available_indexes;

   raise_error(p_error_code, l_error_text);
END raise_1tom_error;

-- ----------------------------------------------------------------------
FUNCTION trunc_arg(p_arg IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_arg VARCHAR2(100);
BEGIN
   IF (Length(p_arg) > 20) THEN
      l_arg := Substr(p_arg, 1, 17) || '...';
    ELSE
      l_arg := p_arg;
   END IF;

   l_arg := '''' || l_arg || '''';

   RETURN l_arg;
END trunc_arg;

-- ----------------------------------------------------------------------
PROCEDURE raise_others_error(p_func_name IN VARCHAR2,
                             p_arg1      IN VARCHAR2,
                             p_arg2      IN VARCHAR2 DEFAULT NULL,
                             p_arg3      IN VARCHAR2 DEFAULT NULL)
  IS
     l_error VARCHAR2(32000);
BEGIN
   l_error := 'UTPSC.' || p_func_name || '(' || trunc_arg(p_arg1);

   IF (p_arg2 IS NOT NULL) THEN
      l_error := l_error || ', ' || trunc_arg(p_arg2);

      IF (p_arg3 IS NOT NULL) THEN
	 l_error := l_error || ', ' || trunc_arg(p_arg3);
      END IF;
   END IF;

   l_error := l_error || ') failed';

   l_error := (l_error || g_newline ||
               dbms_utility.format_error_stack());

   IF (l_error NOT LIKE '%PL/SQL Call Stack%') THEN
      l_error := (l_error || g_newline ||
                  dbms_utility.format_call_stack());
   END IF;

   raise_application_error(ERROR_WHEN_OTHERS, l_error);

   --
   -- Don't catch the exception here.
   --
END raise_others_error;

-- ----------------------------------------------------------------------
FUNCTION boolean_to_char(p_boolean IN BOOLEAN)
  RETURN VARCHAR2
  IS
BEGIN
   IF (p_boolean) THEN
      RETURN 'TRUE';
    ELSIF (NOT p_boolean) THEN
      RETURN 'FALSE';
    ELSE
      RETURN NULL;
   END IF;
END boolean_to_char;

-- ----------------------------------------------------------------------
PROCEDURE debug_put_line(p_debug IN VARCHAR2)
  IS
     l_debug VARCHAR2(100);
BEGIN
   IF (Lengthb(p_debug) > 77) THEN
      l_debug := substrb(p_debug, 1, 74) || '...';
    ELSE
      l_debug := p_debug;
   END IF;
   execute immediate ('begin dbms_output.put_line(''|' ||
		      REPLACE(l_debug, '''', '''''') ||
		      ''');end;');
END debug_put_line;

-- ----------------------------------------------------------------------
PROCEDURE debug_append_attribute(px_debug_value IN OUT nocopy VARCHAR2,
                                 p_value        IN VARCHAR2)
  IS
BEGIN
   IF (p_value IS NOT NULL) THEN
      IF (px_debug_value IS NOT NULL) THEN
         px_debug_value := px_debug_value || '.';
      END IF;
      px_debug_value := px_debug_value || p_value;
   END IF;
END debug_append_attribute;

-- ----------------------------------------------------------------------
FUNCTION debug_get_generic_value_concat(p_value IN generic_cache_value_type)
  RETURN VARCHAR2
  IS
     l_debug_value VARCHAR2(32000);
BEGIN
   l_debug_value := NULL;
   debug_append_attribute(l_debug_value, p_value.varchar2_1);
   debug_append_attribute(l_debug_value, p_value.varchar2_2);
   debug_append_attribute(l_debug_value, p_value.varchar2_3);
   debug_append_attribute(l_debug_value, p_value.varchar2_4);
   debug_append_attribute(l_debug_value, p_value.varchar2_5);
   debug_append_attribute(l_debug_value, p_value.varchar2_6);
   debug_append_attribute(l_debug_value, p_value.varchar2_7);
   debug_append_attribute(l_debug_value, p_value.varchar2_8);
   debug_append_attribute(l_debug_value, p_value.varchar2_9);
   debug_append_attribute(l_debug_value, p_value.varchar2_10);
   debug_append_attribute(l_debug_value, p_value.varchar2_11);
   debug_append_attribute(l_debug_value, p_value.varchar2_12);
   debug_append_attribute(l_debug_value, p_value.varchar2_13);
   debug_append_attribute(l_debug_value, p_value.varchar2_14);
   debug_append_attribute(l_debug_value, p_value.varchar2_15);

   debug_append_attribute(l_debug_value, To_char(p_value.number_1));
   debug_append_attribute(l_debug_value, To_char(p_value.number_2));
   debug_append_attribute(l_debug_value, To_char(p_value.number_3));
   debug_append_attribute(l_debug_value, To_char(p_value.number_4));
   debug_append_attribute(l_debug_value, To_char(p_value.number_5));

   debug_append_attribute(l_debug_value, To_char(p_value.date_1, 'YYYY/MM/DD HH24:MI:SS'));
   debug_append_attribute(l_debug_value, To_char(p_value.date_2, 'YYYY/MM/DD HH24:MI:SS'));
   debug_append_attribute(l_debug_value, To_char(p_value.date_3, 'YYYY/MM/DD HH24:MI:SS'));

   debug_append_attribute(l_debug_value, boolean_to_char(p_value.boolean_1));
   debug_append_attribute(l_debug_value, boolean_to_char(p_value.boolean_2));
   debug_append_attribute(l_debug_value, boolean_to_char(p_value.boolean_3));

   RETURN(l_debug_value);
END debug_get_generic_value_concat;

-- ----------------------------------------------------------------------
PROCEDURE internal_1to1_debug
  (px_controller      IN cache_1to1_controller_type,
   px_storage         IN generic_cache_values_type,
   p_debug_level      IN VARCHAR2)
  IS
     l_debug_line VARCHAR2(32000);
BEGIN
   debug_put_line(' ');
   debug_put_line(Rpad('== ' || px_controller.cache_type || ' 1to1 Cache Debug ==', 77, '='));
   debug_put_line('Name               : ' || px_controller.name);
   debug_put_line('Max Number Of Keys : ' || px_controller.max_numof_keys);
   debug_put_line('Number Of Keys     : ' || px_controller.numof_keys);
   debug_put_line(' ');

   IF (p_debug_level IN (CDL_SUMMARY_KEYS,
                         CDL_SUMMARY_KEYS_VALUES)) THEN
      IF ((px_controller.cache_type = CACHE_TYPE_GENERIC) AND
          (p_debug_level = CDL_SUMMARY_KEYS_VALUES)) THEN
         --
         -- Print Header for Keys/Values
         --
         debug_put_line('Index Key                                 Value                              ');
         debug_put_line('===== =================================== ===================================');
       ELSE
         --
         -- Print Header for Keys
         --
         debug_put_line('Index Key                                                                    ');
         debug_put_line('===== =======================================================================');
      END IF;

      FOR i IN 1..px_controller.max_numof_keys LOOP
         IF (px_controller.keys(i) IS NOT NULL) THEN

            l_debug_line := Lpad(i, 5, ' ') || ' ';

            IF ((px_controller.cache_type = CACHE_TYPE_GENERIC) AND
                (p_debug_level = CDL_SUMMARY_KEYS_VALUES)) THEN

               IF (Length(px_controller.keys(i)) > 35) THEN
                  l_debug_line := l_debug_line || Substr(px_controller.keys(i), 1, 32) || '...';
                ELSE
                  l_debug_line := l_debug_line || Rpad(px_controller.keys(i), 35, ' ');
               END IF;

               l_debug_line := l_debug_line || ' ' || debug_get_generic_value_concat(px_storage(i));
             ELSE
               l_debug_line := l_debug_line || px_controller.keys(i);
            END IF;

            debug_put_line(l_debug_line);

         END IF;
      END LOOP;
   END IF;

   debug_put_line(Rpad('=', 77, '='));
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'internal_1to1_debug',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_debug_level);
END internal_1to1_debug;

-- ----------------------------------------------------------------------
PROCEDURE internal_1tom_debug
  (px_controller      IN cache_1tom_controller_type,
   px_storage         IN generic_cache_values_type,
   p_debug_level      IN VARCHAR2)
  IS
     l_index      NUMBER;
     l_debug_line VARCHAR2(32000);
BEGIN
   debug_put_line(' ');
   debug_put_line(Rpad('== ' || px_controller.cache_type || ' 1toM Cache Debug ==', 77, '='));
   debug_put_line('Name                 : ' || px_controller.name);
   debug_put_line('Max Number Of Keys   : ' || px_controller.max_numof_keys);
   debug_put_line('Number Of Keys       : ' || px_controller.numof_keys);
   debug_put_line('Number Of Values     : ' || px_controller.numof_values);
   debug_put_line('Max Of Avail Indexes : ' || px_controller.maxof_available_indexes);
   debug_put_line('Num Of Avail Indexes : ' || px_controller.numof_available_indexes);
   debug_put_line('Available Indexes    : ' || px_controller.available_indexes);
   debug_put_line(' ');

   IF (p_debug_level IN (CDL_SUMMARY_KEYS,
                         CDL_SUMMARY_KEYS_VALUES)) THEN
      --
      -- Print Header for Keys
      --
      debug_put_line('Index Key                                  #Vals Value Indexes               ');
      debug_put_line('===== ==================================== ===== ============================');

      FOR i IN 1..px_controller.max_numof_keys LOOP
         IF (px_controller.keys(i) IS NOT NULL) THEN

            l_debug_line := Lpad(i, 5, ' ') || ' ';

            IF (Length(px_controller.keys(i)) > 36) THEN
               l_debug_line := l_debug_line || Substr(px_controller.keys(i), 1, 33) || '...';
             ELSE
               l_debug_line := l_debug_line || Rpad(px_controller.keys(i), 36, ' ');
            END IF;

            l_debug_line := l_debug_line || (' ' || Rpad(px_controller.numof_indexes(i), 5, ' ') || ' ' ||
                                             px_controller.value_indexes(i));

            debug_put_line(l_debug_line);

            IF ((px_controller.cache_type = CACHE_TYPE_GENERIC) AND
                (p_debug_level = CDL_SUMMARY_KEYS_VALUES)) THEN
               IF (px_controller.numof_indexes(i) > 0) THEN
                  --
                  -- Print Header for Values
                  --
                  debug_put_line('      Index Value                                                            ');
                  debug_put_line('      ===== =================================================================');
               END IF;

               FOR j IN 1..px_controller.numof_indexes(i) LOOP
                  l_index := To_number(Substr(px_controller.value_indexes(i),
                                              (j - 1) * CACHE_NUMOF_DIGITS_PER_INDEX + 1,
                                              CACHE_NUMOF_DIGITS_PER_INDEX));

                  debug_put_line(Lpad(' ', 6, ' ') || Lpad(l_index, 5, ' ') || ' ' ||
                                 debug_get_generic_value_concat(px_storage(l_index)));
               END LOOP;
               debug_put_line(' ');
            END IF;
         END IF;
      END LOOP;
   END IF;

   debug_put_line(Rpad('=', 77, '='));
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'internal_1tom_debug',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_debug_level);
END internal_1tom_debug;

-- ----------------------------------------------------------------------
PROCEDURE generic_cache_new_value
  (x_value       OUT nocopy generic_cache_value_type,
   p_varchar2_1  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_2  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_3  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_4  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_5  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_6  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_7  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_8  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_9  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_10 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_11 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_12 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_13 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_14 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_15 IN VARCHAR2 DEFAULT NULL,
   p_number_1    IN NUMBER DEFAULT NULL,
   p_number_2    IN NUMBER DEFAULT NULL,
   p_number_3    IN NUMBER DEFAULT NULL,
   p_number_4    IN NUMBER DEFAULT NULL,
   p_number_5    IN NUMBER DEFAULT NULL,
   p_date_1      IN DATE DEFAULT NULL,
   p_date_2      IN DATE DEFAULT NULL,
   p_date_3      IN DATE DEFAULT NULL,
   p_boolean_1   IN BOOLEAN DEFAULT NULL,
   p_boolean_2   IN BOOLEAN DEFAULT NULL,
   p_boolean_3   IN BOOLEAN DEFAULT NULL)
  IS
BEGIN
   x_value.varchar2_1  := p_varchar2_1;
   x_value.varchar2_2  := p_varchar2_2;
   x_value.varchar2_3  := p_varchar2_3;
   x_value.varchar2_4  := p_varchar2_4;
   x_value.varchar2_5  := p_varchar2_5;
   x_value.varchar2_6  := p_varchar2_6;
   x_value.varchar2_7  := p_varchar2_7;
   x_value.varchar2_8  := p_varchar2_8;
   x_value.varchar2_9  := p_varchar2_9;
   x_value.varchar2_10 := p_varchar2_10;
   x_value.varchar2_11 := p_varchar2_11;
   x_value.varchar2_12 := p_varchar2_12;
   x_value.varchar2_13 := p_varchar2_13;
   x_value.varchar2_14 := p_varchar2_14;
   x_value.varchar2_15 := p_varchar2_15;
   x_value.number_1    := p_number_1;
   x_value.number_2    := p_number_2;
   x_value.number_3    := p_number_3;
   x_value.number_4    := p_number_4;
   x_value.number_5    := p_number_5;
   x_value.date_1      := p_date_1;
   x_value.date_2      := p_date_2;
   x_value.date_3      := p_date_3;
   x_value.boolean_1   := p_boolean_1;
   x_value.boolean_2   := p_boolean_2;
   x_value.boolean_3   := p_boolean_3;
END generic_cache_new_value;

-- ----------------------------------------------------------------------
FUNCTION generic_cache_new_value
  (p_varchar2_1  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_2  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_3  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_4  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_5  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_6  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_7  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_8  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_9  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_10 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_11 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_12 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_13 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_14 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_15 IN VARCHAR2 DEFAULT NULL,
   p_number_1    IN NUMBER DEFAULT NULL,
   p_number_2    IN NUMBER DEFAULT NULL,
   p_number_3    IN NUMBER DEFAULT NULL,
   p_number_4    IN NUMBER DEFAULT NULL,
   p_number_5    IN NUMBER DEFAULT NULL,
   p_date_1      IN DATE DEFAULT NULL,
   p_date_2      IN DATE DEFAULT NULL,
   p_date_3      IN DATE DEFAULT NULL,
   p_boolean_1   IN BOOLEAN DEFAULT NULL,
   p_boolean_2   IN BOOLEAN DEFAULT NULL,
   p_boolean_3   IN BOOLEAN DEFAULT NULL)
  RETURN generic_cache_value_type
  IS
     l_value generic_cache_value_type;
BEGIN
   l_value.varchar2_1  := p_varchar2_1;
   l_value.varchar2_2  := p_varchar2_2;
   l_value.varchar2_3  := p_varchar2_3;
   l_value.varchar2_4  := p_varchar2_4;
   l_value.varchar2_5  := p_varchar2_5;
   l_value.varchar2_6  := p_varchar2_6;
   l_value.varchar2_7  := p_varchar2_7;
   l_value.varchar2_8  := p_varchar2_8;
   l_value.varchar2_9  := p_varchar2_9;
   l_value.varchar2_10 := p_varchar2_10;
   l_value.varchar2_11 := p_varchar2_11;
   l_value.varchar2_12 := p_varchar2_12;
   l_value.varchar2_13 := p_varchar2_13;
   l_value.varchar2_14 := p_varchar2_14;
   l_value.varchar2_15 := p_varchar2_15;
   l_value.number_1    := p_number_1;
   l_value.number_2    := p_number_2;
   l_value.number_3    := p_number_3;
   l_value.number_4    := p_number_4;
   l_value.number_5    := p_number_5;
   l_value.date_1      := p_date_1;
   l_value.date_2      := p_date_2;
   l_value.date_3      := p_date_3;
   l_value.boolean_1   := p_boolean_1;
   l_value.boolean_2   := p_boolean_2;
   l_value.boolean_3   := p_boolean_3;

   RETURN (l_value);
END generic_cache_new_value;

-- ======================================================================
-- Generic One Cache:
-- ======================================================================

-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS)
  IS
BEGIN
   custom_1to1_init(p_name,
		    px_controller,
		    p_max_numof_keys);
   px_controller.cache_type := CACHE_TYPE_GENERIC;
   px_storage.DELETE;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1to1_init',
                         p_arg1      => p_name,
                         p_arg2      => p_max_numof_keys);
END generic_1to1_init;

-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_get_value
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   x_value            OUT nocopy generic_cache_value_type,
   x_return_code      OUT nocopy VARCHAR2)
  IS
     l_key       VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index NUMBER;
BEGIN
   -- Similar logic exists in custom_1to1_get_get_index()
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);
   --
   -- Is it in cache?
   --
   IF (px_controller.keys(l_key_index) = l_key) THEN
      x_value := px_storage(l_key_index);
      x_return_code := CACHE_FOUND;
    ELSE
      x_return_code := CACHE_NOTFOUND;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1to1_get_value',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END generic_1to1_get_value;

-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_put_value
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   p_value            IN generic_cache_value_type)
  IS
     l_key       VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index NUMBER;
BEGIN
   -- Similar logic exists in custom_1to1_get_put_index()
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);

   IF (px_controller.keys(l_key_index) IS NULL) THEN
      --
      -- A new key is cached.
      --
      px_controller.numof_keys := px_controller.numof_keys + 1;
   END IF;

   --
   -- Update the cache. Old entry is overwritten.
   --
   px_controller.keys(l_key_index) := l_key;
   px_storage(l_key_index) := p_value;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1to1_put_value',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END generic_1to1_put_value;

-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_remove_key
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2)
  IS
BEGIN
   custom_1to1_remove_key(px_controller,
			  p_key);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1to1_remove_key',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END generic_1to1_remove_key;

-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_clear
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type)
  IS
BEGIN
   generic_1to1_init(px_controller.name,
		     px_controller,
		     px_storage,
		     px_controller.max_numof_keys);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1to1_clear',
                         p_arg1      => px_controller.name);
END generic_1to1_clear;

-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_debug
  (px_controller      IN cache_1to1_controller_type,
   px_storage         IN generic_cache_values_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES)
  IS
BEGIN
   internal_1to1_debug(px_controller, px_storage, p_debug_level);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1to1_debug',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_debug_level);
END generic_1to1_debug;


-- ======================================================================
-- Generic Many Cache:
-- ======================================================================

-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS)
  IS
BEGIN
   custom_1tom_init(p_name,
		    px_controller,
		    p_max_numof_keys);
   px_controller.cache_type := CACHE_TYPE_GENERIC;
   px_storage.DELETE;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1tom_init',
                         p_arg1      => p_name,
                         p_arg2      => p_max_numof_keys);
END generic_1tom_init;

-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_get_values
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   x_numof_values     OUT nocopy NUMBER,
   x_values           OUT nocopy generic_cache_values_type,
   x_return_code      OUT nocopy VARCHAR2)
  IS
     l_key         VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index   NUMBER;
     l_indexes_vc2 VARCHAR2(2048);
BEGIN
   -- Similar logic exists in custom_1tom_get_get_indexes()
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);
   --
   -- Is it in cache?
   --
   IF (px_controller.keys(l_key_index) = l_key) THEN
      --
      -- Resolve the value indexes.
      --
      l_indexes_vc2 := px_controller.value_indexes(l_key_index);
      --
      -- Use indexes list to get values.
      --
      FOR i IN 1..px_controller.numof_indexes(l_key_index) LOOP
	 x_values(i) := px_storage(To_number(Substr(l_indexes_vc2, 1, CACHE_NUMOF_DIGITS_PER_INDEX)));
	 l_indexes_vc2 := Substr(l_indexes_vc2, CACHE_NUMOF_DIGITS_PER_INDEX + 1);
      END LOOP;

      x_numof_values := px_controller.numof_indexes(l_key_index);
      x_return_code := CACHE_FOUND;
    ELSE

      x_return_code := CACHE_NOTFOUND;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1tom_get_values',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END generic_1tom_get_values;

-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_put_values
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   p_numof_values     IN NUMBER,
   p_values           IN generic_cache_values_type)
  IS
     l_indexes     custom_cache_indexes_type;
     l_return_code VARCHAR2(1);
BEGIN
   --
   -- Since the put logic in 1tom is complicated, it is not repeated here.
   -- Hopefully put will not be called many times anyway.
   --
   custom_1tom_get_put_indexes(px_controller,
                               p_key,
                               p_numof_values,
                               l_indexes,
                               l_return_code);

   IF (l_return_code = CACHE_PUT_IS_SUCCESSFUL) THEN
      FOR i IN 1..p_numof_values LOOP
         px_storage(l_indexes(i)) := p_values(i);
      END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1tom_put_values',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key,
                         p_arg3      => p_numof_values);
END generic_1tom_put_values;

-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_remove_key
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2)
  IS
BEGIN
   custom_1tom_remove_key(px_controller,
			  p_key);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1tom_remove_key',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END generic_1tom_remove_key;

-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_clear
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type)
  IS
BEGIN
   generic_1tom_init(px_controller.name,
		     px_controller,
		     px_storage,
		     px_controller.max_numof_keys);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1tom_clear',
                         p_arg1      => px_controller.name);
END generic_1tom_clear;

-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_debug
  (px_controller      IN cache_1tom_controller_type,
   px_storage         IN generic_cache_values_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES)
  IS
     l_index NUMBER;
BEGIN
   internal_1tom_debug(px_controller, px_storage, p_debug_level);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'generic_1tom_debug',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_debug_level);
END generic_1tom_debug;


-- ======================================================================
-- Custom One Cache:
-- ======================================================================

-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS)
  IS
BEGIN
   px_controller.name := Nvl(p_name, 'NONAME Cache');
   px_controller.cache_type := CACHE_TYPE_CUSTOM;
   px_controller.max_numof_keys := p_max_numof_keys;
   px_controller.numof_keys := 0;

   --
   -- 1 <= p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS, 2^n = p_max_numof_keys
   --
   IF (NOT ((p_max_numof_keys >= 1) AND
            (p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS) AND
            (p_max_numof_keys IN (1,2,4,8,16,32,64,128,256,512,1024)))) THEN
      raise_1to1_error(px_controller, ERROR_MAX_NUMOF_KEYS,
                       'p_max_numof_keys (' || p_max_numof_keys ||
                       ') must be between 1 and ' ||
                       CACHE_MAX_NUMOF_KEYS || ', and must be power of 2.');
   END IF;

   px_controller.keys := cache_varchar2_varray_type();
   px_controller.keys.extend(px_controller.max_numof_keys);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1to1_init',
                         p_arg1      => p_name,
                         p_arg2      => p_max_numof_keys);
END custom_1to1_init;

-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_get_get_index
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2,
   x_index            OUT nocopy BINARY_INTEGER,
   x_return_code      OUT nocopy VARCHAR2)
  IS
     l_key       VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index NUMBER;
BEGIN
   -- Similar logic exists in generic_1to1_get_value()
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);
   --
   -- Is it in cache?
   --
   IF (px_controller.keys(l_key_index) = l_key) THEN
      x_index := l_key_index;
      x_return_code := CACHE_FOUND;
    ELSE
      x_return_code := CACHE_NOTFOUND;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1to1_get_get_index',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END custom_1to1_get_get_index;

-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_get_put_index
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2,
   x_index            OUT nocopy BINARY_INTEGER)
  IS
     l_key       VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index NUMBER;
BEGIN
   -- Similar logic exists in generic_1to1_put_value()
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);

   IF (px_controller.keys(l_key_index) IS NULL) THEN
      --
      -- A new key is cached.
      --
      px_controller.numof_keys := px_controller.numof_keys + 1;
   END IF;

   --
   -- Update the cache. Old entry is overwritten.
   --
   px_controller.keys(l_key_index) := l_key;
   x_index := l_key_index;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1to1_get_put_index',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END custom_1to1_get_put_index;

-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_remove_key
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2)
  IS
     l_key       VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index NUMBER;
BEGIN
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);

   --
   -- Is it in cache?
   --
   IF (px_controller.keys(l_key_index) = l_key) THEN
      --
      -- Remove it from the cache.
      --
      px_controller.numof_keys := px_controller.numof_keys - 1;
      px_controller.keys(l_key_index) := NULL;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1to1_remove_key',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END custom_1to1_remove_key;

-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_clear
  (px_controller      IN OUT nocopy cache_1to1_controller_type)
  IS
BEGIN
   custom_1to1_init(px_controller.name,
		    px_controller,
		    px_controller.max_numof_keys);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1to1_clear',
                         p_arg1      => px_controller.name);
END custom_1to1_clear;

-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_debug
  (px_controller      IN cache_1to1_controller_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES)
  IS
     l_dummy_storage generic_cache_values_type;
BEGIN
   internal_1to1_debug(px_controller, l_dummy_storage, p_debug_level);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1to1_debug',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_debug_level);
END custom_1to1_debug;


-- ======================================================================
-- Custom Many Cache:
-- ======================================================================

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_remove_key_private
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key_index        IN NUMBER)
  IS
BEGIN
   --
   -- Return the indexes
   --
   px_controller.available_indexes       := px_controller.value_indexes(p_key_index) || px_controller.available_indexes;
   px_controller.numof_available_indexes := px_controller.numof_available_indexes + px_controller.numof_indexes(p_key_index);

   --
   -- Remove it from the cache.
   --
   px_controller.numof_keys := px_controller.numof_keys - 1;
   px_controller.numof_values := px_controller.numof_values - px_controller.numof_indexes(p_key_index);

   px_controller.keys(p_key_index) := NULL;
   px_controller.value_indexes(p_key_index) := NULL;
   px_controller.numof_indexes(p_key_index) := 0;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1tom_remove_key_private',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key_index);
END custom_1tom_remove_key_private;

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_extend_private
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_extent_size      IN NUMBER)
  IS
BEGIN
   --
   -- Make sure we are not gonna hit the CACHE_MAX_NUMOF_VALUES limit.
   --
   IF ((px_controller.maxof_available_indexes + p_extent_size) > CACHE_MAX_NUMOF_VALUES) THEN
      raise_1tom_error(px_controller, ERROR_MAX_NUMOF_VALUES,
                       'Cache maximum size (' ||
                       CACHE_MAX_NUMOF_VALUES || ') is reached.');
   END IF;

   --
   -- Append new indexes to the end of available list.
   --
   FOR i IN 1..p_extent_size LOOP
      px_controller.available_indexes := px_controller.available_indexes ||
        Rpad(px_controller.maxof_available_indexes + i, CACHE_NUMOF_DIGITS_PER_INDEX, ' ');
   END LOOP;

   px_controller.numof_available_indexes := px_controller.numof_available_indexes + p_extent_size;
   px_controller.maxof_available_indexes := px_controller.maxof_available_indexes + p_extent_size;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1tom_extend_private',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_extent_size);
END custom_1tom_extend_private;

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS)
  IS
BEGIN
   px_controller.name := Nvl(p_name, 'NONAME Cache');
   px_controller.cache_type := CACHE_TYPE_CUSTOM;
   px_controller.max_numof_keys := p_max_numof_keys;
   px_controller.numof_keys := 0;
   px_controller.numof_values := 0;

   px_controller.available_indexes := NULL;
   px_controller.numof_available_indexes := 0;
   px_controller.maxof_available_indexes := 0;

   custom_1tom_extend_private(px_controller, CACHE_EXTENT_SIZE);

   --
   -- 1 <= p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS, 2^n = p_max_numof_keys
   --
   IF (NOT ((p_max_numof_keys >= 1) AND
            (p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS) AND
            (p_max_numof_keys IN (1,2,4,8,16,32,64,128,256,512,1024)))) THEN
      raise_1tom_error(px_controller, ERROR_MAX_NUMOF_KEYS,
                       'p_max_numof_keys (' || p_max_numof_keys ||
                       ') must be between 1 and ' ||
                       CACHE_MAX_NUMOF_KEYS || ', and must be power of 2.');
   END IF;

   px_controller.keys := cache_varchar2_varray_type();
   px_controller.keys.extend(px_controller.max_numof_keys);

   px_controller.numof_indexes := cache_number_varray_type();
   px_controller.numof_indexes.extend(px_controller.max_numof_keys);

   px_controller.value_indexes := cache_varchar2_varray_type();
   px_controller.value_indexes.extend(px_controller.max_numof_keys);

EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1tom_init',
                         p_arg1      => p_name,
                         p_arg2      => p_max_numof_keys);
END custom_1tom_init;

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_get_get_indexes
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2,
   x_numof_indexes    OUT nocopy NUMBER,
   x_indexes          OUT nocopy custom_cache_indexes_type,
   x_return_code      OUT nocopy VARCHAR2)
  IS
     l_key         VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index   NUMBER;
     l_indexes_vc2 VARCHAR2(2048);
BEGIN
   -- Similar logic exists in generic_1tom_get_values()
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);
   --
   -- Is it in cache?
   --
   IF (px_controller.keys(l_key_index) = l_key) THEN
      --
      -- Resolve the value indexes.
      --
      l_indexes_vc2 := px_controller.value_indexes(l_key_index);
      --
      -- Use indexes list to get indexes.
      --
      FOR i IN 1..px_controller.numof_indexes(l_key_index) LOOP
	 x_indexes(i) := To_number(Substr(l_indexes_vc2, 1, CACHE_NUMOF_DIGITS_PER_INDEX));
	 l_indexes_vc2 := Substr(l_indexes_vc2, CACHE_NUMOF_DIGITS_PER_INDEX + 1);
      END LOOP;

      x_numof_indexes := px_controller.numof_indexes(l_key_index);
      x_return_code := CACHE_FOUND;
    ELSE

      x_return_code := CACHE_NOTFOUND;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1tom_get_get_indexes',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END custom_1tom_get_get_indexes;

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_get_put_indexes
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2,
   p_numof_indexes    IN NUMBER,
   x_indexes          OUT nocopy custom_cache_indexes_type,
   x_return_code      OUT nocopy VARCHAR2)
  IS
     l_key         VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index   NUMBER;
     l_indexes_vc2 VARCHAR2(2048);
BEGIN
   --
   -- 0 <= p_numof_indexes <= CACHE_MAX_NUMOF_VALUES_PER_KEY
   --
   IF (NOT ((p_numof_indexes >= 0) AND
            (p_numof_indexes <= CACHE_MAX_NUMOF_VALUES_PER_KEY))) THEN
      raise_1tom_error(px_controller, ERROR_MAX_NUMOF_VALUES_PER_KEY,
                       'p_numof_indexes (' || p_numof_indexes ||
                       ') must be between 0 and ' ||
                       CACHE_MAX_NUMOF_VALUES_PER_KEY || '.');
   END IF;

   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);

   --
   -- Old entry is overwritten.
   --
   IF (px_controller.keys(l_key_index) IS NOT NULL) THEN
      custom_1tom_remove_key_private(px_controller, l_key_index);
   END IF;

   --
   -- If there are not enough indexes then extend the cache.
   --
   WHILE (px_controller.numof_available_indexes <= p_numof_indexes) LOOP
      custom_1tom_extend_private(px_controller, CACHE_EXTENT_SIZE);
   END LOOP;

   --
   -- Get the indexes.
   --
   IF (p_numof_indexes = 0) THEN
      l_indexes_vc2 := NULL;
    ELSE
      l_indexes_vc2 := Substr(px_controller.available_indexes, 1, CACHE_NUMOF_DIGITS_PER_INDEX * p_numof_indexes);

      --
      -- Update the controller.
      --
      px_controller.available_indexes := Substr(px_controller.available_indexes, CACHE_NUMOF_DIGITS_PER_INDEX * p_numof_indexes + 1);
      px_controller.numof_available_indexes := px_controller.numof_available_indexes - p_numof_indexes;
   END IF;

   px_controller.numof_keys := px_controller.numof_keys + 1;
   px_controller.numof_values := px_controller.numof_values + p_numof_indexes;

   px_controller.keys(l_key_index) := l_key;
   px_controller.numof_indexes(l_key_index) := p_numof_indexes;
   px_controller.value_indexes(l_key_index) := l_indexes_vc2;

   --
   -- Use indexes list to get indexes.
   --
   FOR i IN 1..p_numof_indexes LOOP
      x_indexes(i) := To_number(Substr(l_indexes_vc2, 1, CACHE_NUMOF_DIGITS_PER_INDEX));
      l_indexes_vc2 := Substr(l_indexes_vc2, CACHE_NUMOF_DIGITS_PER_INDEX + 1);
   END LOOP;

   x_return_code := CACHE_PUT_IS_SUCCESSFUL;
EXCEPTION
   WHEN OTHERS THEN
      IF (g_error_code = ERROR_MAX_NUMOF_VALUES_PER_KEY) THEN
         x_return_code := CACHE_TOO_MANY_VALUES_PER_KEY;

       ELSIF (g_error_code = ERROR_MAX_NUMOF_VALUES) THEN
         x_return_code := CACHE_IS_FULL;

       ELSE
         raise_others_error(p_func_name => 'custom_1tom_get_put_indexes',
                            p_arg1      => px_controller.name,
                            p_arg2      => p_key,
                            p_arg3      => p_numof_indexes);
      END IF;
END custom_1tom_get_put_indexes;

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_remove_key
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2)
  IS
     l_key       VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
     l_key_index NUMBER;
BEGIN
   --
   -- Get the key index. (1..px_controller.max_numof_keys)
   --
   l_key_index := dbms_utility.get_hash_value(l_key, 1,
					      px_controller.max_numof_keys);
   --
   -- Is it in cache?
   --
   IF (px_controller.keys(l_key_index) = l_key) THEN
      custom_1tom_remove_key_private(px_controller, l_key_index);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1tom_remove_key',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_key);
END custom_1tom_remove_key;

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_clear
  (px_controller      IN OUT nocopy cache_1tom_controller_type)
  IS
BEGIN
   custom_1tom_init(px_controller.name,
		    px_controller,
		    px_controller.max_numof_keys);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1tom_clear',
                         p_arg1      => px_controller.name);
END custom_1tom_clear;

-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_debug
  (px_controller      IN cache_1tom_controller_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES)
  IS
     l_dummy_storage generic_cache_values_type;
BEGIN
   internal_1tom_debug(px_controller, l_dummy_storage, p_debug_level);
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error(p_func_name => 'custom_1tom_debug',
                         p_arg1      => px_controller.name,
                         p_arg2      => p_debug_level);
END custom_1tom_debug;


-- ----------------------------------------------------------------------
PROCEDURE test
  IS
     TYPE custom_cache_storage_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

     lg_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
     lg_1tom_controller fnd_plsql_cache.cache_1tom_controller_type;

     lg_generic_storage fnd_plsql_cache.generic_cache_values_type;
     lg_custom_storage  custom_cache_storage_type;

     lg_return_code     VARCHAR2(1);

     lg_same_index_key  VARCHAR2(2000);
     lg_debug           VARCHAR2(32000);

     -- ----------------------------------------------------------------------
     PROCEDURE test_generic_1to1_put(p_key   IN VARCHAR2,
				     p_value IN VARCHAR2)
       IS
	  l_value fnd_plsql_cache.generic_cache_value_type;
     BEGIN
	generic_cache_new_value(l_value,
				p_varchar2_1 => p_value);
	generic_1to1_put_value(lg_1to1_controller, lg_generic_storage,
			       p_key, l_value);
	debug_put_line('OK. (' || p_key || ', ' || p_value || ') is stored.');
     END test_generic_1to1_put;

     -- ----------------------------------------------------------------------
     PROCEDURE test_generic_1to1_get(p_key               IN VARCHAR2,
				     p_is_found_expected IN BOOLEAN)
       IS
	  l_value fnd_plsql_cache.generic_cache_value_type;
     BEGIN
	generic_1to1_get_value(lg_1to1_controller, lg_generic_storage,
			       p_key, l_value, lg_return_code);

	IF ((lg_return_code = CACHE_FOUND) AND
	    (p_is_found_expected)) THEN

	   debug_put_line('OK. (' || p_key || ', ' || l_value.varchar2_1 ||
			  ') is found.');

	 ELSIF ((lg_return_code = CACHE_FOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was not supposed to be found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('OK. (' || p_key || ') is not found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was supposed to be found.');
	END IF;
     END test_generic_1to1_get;

     -- ----------------------------------------------------------------------
     PROCEDURE test_generic_1tom_put(p_key    IN VARCHAR2,
				     p_value1 IN VARCHAR2 DEFAULT NULL,
				     p_value2 IN VARCHAR2 DEFAULT NULL,
				     p_value3 IN VARCHAR2 DEFAULT NULL,
				     p_value4 IN VARCHAR2 DEFAULT NULL,
				     p_value5 IN VARCHAR2 DEFAULT NULL)
       IS
	  l_value        fnd_plsql_cache.generic_cache_value_type;
	  l_values       fnd_plsql_cache.generic_cache_values_type;
	  l_numof_values NUMBER;
     BEGIN
	IF (p_value1 IS NOT NULL) THEN
	   generic_cache_new_value(l_value,
				   p_varchar2_1 => p_value1);
	   l_values(1) := l_value;
	   l_numof_values := 1;

	   IF (p_value2 IS NOT NULL) THEN
	      generic_cache_new_value(l_value,
				      p_varchar2_1 => p_value2);
	      l_values(2) := l_value;
	      l_numof_values := 2;

	      IF (p_value3 IS NOT NULL) THEN
		 generic_cache_new_value(l_value,
					 p_varchar2_1 => p_value3);
		 l_values(3) := l_value;
		 l_numof_values := 3;

		 IF (p_value4 IS NOT NULL) THEN
		    generic_cache_new_value(l_value,
					    p_varchar2_1 => p_value4);
		    l_values(4) := l_value;
		    l_numof_values := 4;

		    IF (p_value5 IS NOT NULL) THEN
		       generic_cache_new_value(l_value,
					       p_varchar2_1 => p_value5);
		       l_values(5) := l_value;
		       l_numof_values := 5;

		    END IF;
		 END IF;
	      END IF;
	   END IF;
	END IF;

	generic_1tom_put_values(lg_1tom_controller, lg_generic_storage,
				p_key, l_numof_values, l_values);

	lg_debug := 'OK. (' || p_key || '; [';
	FOR i IN 1..l_numof_values LOOP
	   IF (i < l_numof_values) THEN
	      lg_debug := lg_debug || l_values(i).varchar2_1 || ',';
	    ELSE
	      lg_debug := lg_debug || l_values(i).varchar2_1 || ']';
	   END IF;
	END LOOP;
	lg_debug := lg_debug || ') is stored.';
	debug_put_line(lg_debug);

     END test_generic_1tom_put;

     -- ----------------------------------------------------------------------
     PROCEDURE test_generic_1tom_get(p_key               IN VARCHAR2,
				     p_is_found_expected IN BOOLEAN)
       IS
	  l_numof_values NUMBER;
	  l_values       fnd_plsql_cache.generic_cache_values_type;
     BEGIN
	generic_1tom_get_values(lg_1tom_controller, lg_generic_storage,
				p_key, l_numof_values, l_values,
				lg_return_code);

	IF ((lg_return_code = CACHE_FOUND) AND
	    (p_is_found_expected)) THEN

	   lg_debug := 'OK. (' || p_key || '; [';
	   FOR i IN 1..l_numof_values LOOP
	      IF (i < l_numof_values) THEN
		 lg_debug := lg_debug || l_values(i).varchar2_1 || ',';
	       ELSE
		 lg_debug := lg_debug || l_values(i).varchar2_1 || ']';
	      END IF;
	   END LOOP;
	   lg_debug := lg_debug || ') is found.';
	   debug_put_line(lg_debug);

	 ELSIF ((lg_return_code = CACHE_FOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was not supposed to be found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('OK. (' || p_key || ') is not found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was supposed to be found.');
	END IF;
     END test_generic_1tom_get;

     -- ----------------------------------------------------------------------
     PROCEDURE test_custom_1to1_put(p_key   IN VARCHAR2,
				    p_value IN VARCHAR2)
       IS
	  l_index BINARY_INTEGER;
     BEGIN
	custom_1to1_get_put_index(lg_1to1_controller,
				  p_key, l_index);
	lg_custom_storage(l_index) := p_value;
	debug_put_line('OK. (' || p_key || ', ' || p_value || ') is stored.');
     END test_custom_1to1_put;

     -- ----------------------------------------------------------------------
     PROCEDURE test_custom_1to1_get(p_key               IN VARCHAR2,
				    p_is_found_expected IN BOOLEAN)
       IS
	  l_index BINARY_INTEGER;
     BEGIN
	custom_1to1_get_get_index(lg_1to1_controller,
				  p_key, l_index, lg_return_code);

	IF ((lg_return_code = CACHE_FOUND) AND
	    (p_is_found_expected)) THEN

	   debug_put_line('OK. (' || p_key || ', ' || lg_custom_storage(l_index) ||
			  ') is found.');

	 ELSIF ((lg_return_code = CACHE_FOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was not supposed to be found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('OK. (' || p_key || ') is not found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was supposed to be found.');
	END IF;
     END test_custom_1to1_get;

     -- ----------------------------------------------------------------------
     PROCEDURE test_custom_1tom_put(p_key    IN VARCHAR2,
				    p_value1 IN VARCHAR2 DEFAULT NULL,
				    p_value2 IN VARCHAR2 DEFAULT NULL,
				    p_value3 IN VARCHAR2 DEFAULT NULL,
				    p_value4 IN VARCHAR2 DEFAULT NULL,
				    p_value5 IN VARCHAR2 DEFAULT NULL)
       IS
	  l_indexes       fnd_plsql_cache.custom_cache_indexes_type;
	  l_values        custom_cache_storage_type;
	  l_numof_indexes NUMBER;
     BEGIN
	IF (p_value1 IS NOT NULL) THEN
	   l_values(1) := p_value1;
	   l_numof_indexes := 1;

	   IF (p_value2 IS NOT NULL) THEN
	      l_values(2) := p_value2;
	      l_numof_indexes := 2;

	      IF (p_value3 IS NOT NULL) THEN
		 l_values(3) := p_value3;
		 l_numof_indexes := 3;

		 IF (p_value4 IS NOT NULL) THEN
		    l_values(4) := p_value4;
		    l_numof_indexes := 4;

		    IF (p_value5 IS NOT NULL) THEN
		       l_values(5) := p_value5;
		       l_numof_indexes := 5;
		    END IF;
		 END IF;
	      END IF;
	   END IF;
	END IF;

	custom_1tom_get_put_indexes(lg_1tom_controller,
				    p_key, l_numof_indexes,
                                    l_indexes, lg_return_code);

        IF (lg_return_code = CACHE_PUT_IS_SUCCESSFUL) THEN
           FOR i IN 1..l_numof_indexes LOOP
              lg_custom_storage(l_indexes(i)) := l_values(i);
           END LOOP;

           lg_debug := 'OK. (' || p_key || '; [';
           FOR i IN 1..l_numof_indexes LOOP
              IF (i < l_numof_indexes) THEN
                 lg_debug := lg_debug || lg_custom_storage(l_indexes(i)) || ',';
               ELSE
                 lg_debug := lg_debug || lg_custom_storage(l_indexes(i)) || ']';
              END IF;
           END LOOP;
           lg_debug := lg_debug || ') is stored.';

         ELSE
           lg_debug := 'ERROR. Put failed. Return Code: ' || lg_return_code;

        END IF;

	debug_put_line(lg_debug);

     END test_custom_1tom_put;

     -- ----------------------------------------------------------------------
     PROCEDURE test_custom_1tom_get(p_key               IN VARCHAR2,
				    p_is_found_expected IN BOOLEAN)
       IS
	  l_numof_indexes NUMBER;
	  l_indexes       fnd_plsql_cache.custom_cache_indexes_type;
     BEGIN
	custom_1tom_get_get_indexes(lg_1tom_controller,
				    p_key, l_numof_indexes, l_indexes,
				    lg_return_code);

	IF ((lg_return_code = CACHE_FOUND) AND
	    (p_is_found_expected)) THEN

	   lg_debug := 'OK. (' || p_key || '; [';
	   FOR i IN 1..l_numof_indexes LOOP
	      IF (i < l_numof_indexes) THEN
		 lg_debug := lg_debug || lg_custom_storage(l_indexes(i)) || ',';
	       ELSE
		 lg_debug := lg_debug || lg_custom_storage(l_indexes(i)) || ']';
	      END IF;
	   END LOOP;
	   lg_debug := lg_debug || ') is found.';
	   debug_put_line(lg_debug);

	 ELSIF ((lg_return_code = CACHE_FOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was not supposed to be found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(NOT p_is_found_expected)) THEN
	   debug_put_line('OK. (' || p_key || ') is not found.');
	 ELSIF ((lg_return_code = CACHE_NOTFOUND) AND
		(p_is_found_expected)) THEN
	   debug_put_line('ERROR. (' || p_key || ') was supposed to be found.');
	END IF;
     END test_custom_1tom_get;

     -- ----------------------------------------------------------------------
     FUNCTION test_get_same_index_key(p_key IN VARCHAR2) RETURN VARCHAR2
       IS
	  l_key       VARCHAR2(2048) := fnd_global.session_context || '.' || p_key;
	  l_key_index NUMBER;
	  l_index     NUMBER;
	  i           NUMBER;
	  l_return    VARCHAR2(2000);
     BEGIN
	l_key_index := dbms_utility.get_hash_value(l_key, 1,
						   CACHE_MAX_NUMOF_KEYS);
	i := 1;
	LOOP
	   l_index :=  dbms_utility.get_hash_value(l_key || i, 1,
						   CACHE_MAX_NUMOF_KEYS);
	   IF (l_index = l_key_index) THEN
	      l_return := p_key || i;
	      EXIT;
	   END IF;
	   i := i + 1;
	END LOOP;

	RETURN (l_return);
     END test_get_same_index_key;

BEGIN
   execute immediate ('begin dbms_output.enable(1000000); end;');

   debug_put_line('Testing Generic 1to1');
   debug_put_line('========================================');
   generic_1to1_init('GenericOne', lg_1to1_controller, lg_generic_storage);

   test_generic_1to1_get('USA', FALSE);

   test_generic_1to1_put('USA', 'Washington DC');
   test_generic_1to1_get('USA', TRUE);

   lg_same_index_key := test_get_same_index_key('USA');
   test_generic_1to1_put(lg_same_index_key, 'Replaces USA');
   test_generic_1to1_get(lg_same_index_key, TRUE);
   test_generic_1to1_get('USA', FALSE);

   test_generic_1to1_put('Turkey', 'Ankara');
   test_generic_1to1_get('Turkey', TRUE);

   generic_1to1_remove_key(lg_1to1_controller, 'Turkey');
   test_generic_1to1_get('Turkey', FALSE);
   test_generic_1to1_put('Turkey', 'Ankara');

   generic_1to1_debug(lg_1to1_controller, lg_generic_storage);

   generic_1to1_clear(lg_1to1_controller, lg_generic_storage);

   debug_put_line('');


   debug_put_line('Testing Generic 1toM');
   debug_put_line('========================================');
   generic_1tom_init('GenericMany', lg_1tom_controller, lg_generic_storage);

   test_generic_1tom_get('Bill Gates', FALSE);

   test_generic_1tom_put('Bill Gates', 'Math', 'C Prog', 'Chem');
   test_generic_1tom_get('Bill Gates', TRUE);

   lg_same_index_key := test_get_same_index_key('Bill Gates');
   test_generic_1tom_put(lg_same_index_key, 'x1', 'x2', 'x3', 'x4', 'x5');
   test_generic_1tom_get(lg_same_index_key, TRUE);
   test_generic_1tom_get('Bill Gates', FALSE);

   test_generic_1tom_put('Bill Clinton', 'Law', 'History', 'Economy');
   test_generic_1tom_get('Bill Clinton', TRUE);

   generic_1tom_remove_key(lg_1tom_controller, 'Bill Clinton');
   test_generic_1tom_get('Bill Clinton', FALSE);
   test_generic_1tom_put('Bill Clinton', 'Law', 'History', 'Economy');

   generic_1tom_debug(lg_1tom_controller, lg_generic_storage);

   generic_1tom_clear(lg_1tom_controller, lg_generic_storage);

   debug_put_line('');


   debug_put_line('Testing Custom 1to1');
   debug_put_line('========================================');
   custom_1to1_init('CustomOne', lg_1to1_controller);

   test_custom_1to1_get('USA', FALSE);

   test_custom_1to1_put('USA', 'Washington DC');
   test_custom_1to1_get('USA', TRUE);

   lg_same_index_key := test_get_same_index_key('USA');
   test_custom_1to1_put(lg_same_index_key, 'Replaces USA');
   test_custom_1to1_get(lg_same_index_key, TRUE);
   test_custom_1to1_get('USA', FALSE);

   test_custom_1to1_put('Turkey', 'Ankara');
   test_custom_1to1_get('Turkey', TRUE);

   custom_1to1_remove_key(lg_1to1_controller, 'Turkey');
   test_generic_1to1_get('Turkey', FALSE);
   test_custom_1to1_put('Turkey', 'Ankara');

   custom_1to1_debug(lg_1to1_controller);

   custom_1to1_clear(lg_1to1_controller);

   debug_put_line('');


   debug_put_line('Testing Custom 1toM');
   debug_put_line('========================================');
   custom_1tom_init('CustomMany', lg_1tom_controller);

   test_custom_1tom_get('Bill Gates', FALSE);

   test_custom_1tom_put('Bill Gates', 'Math', 'C Prog', 'Chem');
   test_custom_1tom_get('Bill Gates', TRUE);

   lg_same_index_key := test_get_same_index_key('Bill Gates');
   test_custom_1tom_put(lg_same_index_key, 'x1', 'x2', 'x3', 'x4', 'x5');
   test_custom_1tom_get(lg_same_index_key, TRUE);
   test_custom_1tom_get('Bill Gates', FALSE);

   test_custom_1tom_put('Bill Clinton', 'Law', 'History', 'Economy');
   test_custom_1tom_get('Bill Clinton', TRUE);

   custom_1tom_remove_key(lg_1tom_controller, 'Bill Clinton');
   test_generic_1tom_get('Bill Clinton', FALSE);
   test_custom_1tom_put('Bill Clinton', 'Law', 'History', 'Economy');

   custom_1tom_debug(lg_1tom_controller);

   custom_1tom_clear(lg_1tom_controller);

   debug_put_line('');

END test;

-- ----------------------------------------------------------------------
PROCEDURE sample_package
  IS
     --
     -- Assume that this is your package declaration section
     --
     --
     -- Declare your data types
     --
     TYPE application_record_type IS RECORD
       (application_id         fnd_application_vl.application_id%TYPE,
	application_short_name fnd_application_vl.application_short_name%TYPE,
	application_name       fnd_application_vl.application_name%TYPE);

     TYPE applications_array_type IS TABLE OF application_record_type
       INDEX BY BINARY_INTEGER;

     TYPE responsibility_record_type IS RECORD
       (responsibility_id      fnd_responsibility_vl.responsibility_id%TYPE,
	responsibility_key     fnd_responsibility_vl.responsibility_key%TYPE,
	responsibility_name    fnd_responsibility_vl.responsibility_name%TYPE);

     TYPE responsibilities_array_type IS TABLE OF responsibility_record_type
       INDEX BY BINARY_INTEGER;

     --
     -- Declare your package global cache variables.
     --

     --
     -- Application cache, generic version. One value per key
     --
     g_app_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
     g_app_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;

     --
     -- Application cache, custom version. One value per key
     --
     g_app_custom_1to1_controller  fnd_plsql_cache.cache_1to1_controller_type;
     g_app_custom_1to1_storage     applications_array_type;

     --
     -- Responsibility cache, generic version. Many values per key
     --
     g_rsp_generic_1tom_controller fnd_plsql_cache.cache_1tom_controller_type;
     g_rsp_generic_1tom_storage    fnd_plsql_cache.generic_cache_values_type;

     --
     -- Responsibility cache, custom version. Many values per key
     --
     g_rsp_custom_1tom_controller  fnd_plsql_cache.cache_1tom_controller_type;
     g_rsp_custom_1tom_storage     responsibilities_array_type;

     --
     -- Implement your getter functions
     --
     ----------------------------------------------------------------------
     FUNCTION get_application_generic(p_application_short_name IN VARCHAR2)
       RETURN application_record_type
       IS
	  l_application application_record_type;
	  l_key         VARCHAR2(2000);
	  l_value       fnd_plsql_cache.generic_cache_value_type;
	  l_return_code VARCHAR2(1);
     BEGIN
	--
	-- Create the key. If you have a composite key then concatenate
	-- them with a delimiter. i.e. p_key1 || '.' || p_key2 || ...
	--
	l_key := p_application_short_name;

	--
	-- First check the cache.
	--
	fnd_plsql_cache.generic_1to1_get_value(g_app_generic_1to1_controller,
					       g_app_generic_1to1_storage,
					       l_key,
					       l_value,
					       l_return_code);

	IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
	   --
	   -- Entity is in the cache, populate the return value.
	   --
	   l_application.application_id := l_value.number_1;
	   l_application.application_short_name := l_value.varchar2_1;
	   l_application.application_name := l_value.varchar2_2;

	 ELSE
	   --
	   -- Entity is not in the cache, get it from DB.
	   --
	   SELECT application_id, application_short_name, application_name
	     INTO l_application
	     FROM fnd_application_vl
	     WHERE application_short_name = p_application_short_name;

	   --
	   -- Create the cache value, and populate it with values came from DB.
	   --
	   fnd_plsql_cache.generic_cache_new_value
	     (x_value      => l_value,
	      p_number_1   => l_application.application_id,
	      p_varchar2_1 => l_application.application_short_name,
	      p_varchar2_2 => l_application.application_name);

	   --
	   -- Put the value in cache.
	   --
	   fnd_plsql_cache.generic_1to1_put_value(g_app_generic_1to1_controller,
						  g_app_generic_1to1_storage,
						  l_key,
						  l_value);
	END IF;

	--
	-- Return the output value.
	--
	RETURN l_application;
     END get_application_generic;

     ----------------------------------------------------------------------
     FUNCTION get_application_custom(p_application_short_name IN VARCHAR2)
       RETURN application_record_type
       IS
	  l_application application_record_type;
	  l_key         VARCHAR2(2000);
	  l_index       BINARY_INTEGER;
	  l_return_code VARCHAR2(1);
     BEGIN
	--
	-- Create the key. If you have a composite key then concatenate
	-- them with a delimiter. i.e. p_key1 || '.' || p_key2 || ...
	--
	l_key := p_application_short_name;

	--
	-- First check the cache.
	--
	fnd_plsql_cache.custom_1to1_get_get_index(g_app_custom_1to1_controller,
						  l_key,
						  l_index,
						  l_return_code);

	IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
	   --
	   -- Entity is in the cache, populate the return value.
	   --
	   l_application := g_app_custom_1to1_storage(l_index);

	 ELSE
	   --
	   -- Entity is not in the cache, get it from DB.
	   --
	   SELECT application_id, application_short_name, application_name
	     INTO l_application
	     FROM fnd_application_vl
	     WHERE application_short_name = p_application_short_name;

	   --
	   -- Put the value in cache.
	   --
	   fnd_plsql_cache.custom_1to1_get_put_index(g_app_custom_1to1_controller,
						     l_key,
						     l_index);
	   g_app_custom_1to1_storage(l_index) := l_application;
	END IF;

	--
	-- Return the output value.
	--
	RETURN l_application;
     END get_application_custom;

     ----------------------------------------------------------------------
     FUNCTION get_responsibilities_generic(p_application_short_name IN VARCHAR2)
       RETURN responsibilities_array_type
       IS
	  CURSOR resp_cursor IS
	     SELECT r.responsibility_id, r.responsibility_key, r.responsibility_name
	       FROM fnd_responsibility_vl r, fnd_application a
	       WHERE a.application_short_name = p_application_short_name
	       AND r.application_id = a.application_id;

	  l_responsibilities responsibilities_array_type;
	  l_key              VARCHAR2(2000);
	  l_values           fnd_plsql_cache.generic_cache_values_type;
	  l_numof_values     NUMBER;
	  l_return_code      VARCHAR2(1);
	  i                  NUMBER;
     BEGIN
	--
	-- Create the key. If you have a composite key then concatenate
	-- them with a delimiter. i.e. p_key1 || '.' || p_key2 || ...
	--
	l_key := p_application_short_name;

	--
	-- First check the cache.
	--
	fnd_plsql_cache.generic_1tom_get_values(g_rsp_generic_1tom_controller,
						g_rsp_generic_1tom_storage,
						l_key,
						l_numof_values,
						l_values,
						l_return_code);

	IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
	   --
	   -- Entity is in the cache, populate the return values.
	   --
	   FOR i IN 1..l_numof_values LOOP
	      l_responsibilities(i).responsibility_id := l_values(i).number_1;
	      l_responsibilities(i).responsibility_key := l_values(i).varchar2_1;
	      l_responsibilities(i).responsibility_name := l_values(i).varchar2_2;
	   END LOOP;

	 ELSE
	   i := 0;
	   FOR r IN resp_cursor LOOP
	      i := i + 1;

	      l_responsibilities(i) := r;
	      --
	      -- Create the cache value, and populate it with values came from DB.
	      --
	      fnd_plsql_cache.generic_cache_new_value
		(x_value      => l_values(i),
		 p_number_1   => r.responsibility_id,
		 p_varchar2_1 => r.responsibility_key,
		 p_varchar2_2 => r.responsibility_name);

	   END LOOP;
	   l_numof_values := i;
	   --
	   -- Put the values in cache.
	   --
	   fnd_plsql_cache.generic_1tom_put_values(g_rsp_generic_1tom_controller,
						   g_rsp_generic_1tom_storage,
						   l_key,
						   l_numof_values,
						   l_values);
	END IF;

	RETURN l_responsibilities;
     END get_responsibilities_generic;

     ----------------------------------------------------------------------
     FUNCTION get_responsibilities_custom(p_application_short_name IN VARCHAR2)
       RETURN responsibilities_array_type
       IS
	  CURSOR resp_cursor IS
	     SELECT r.responsibility_id, r.responsibility_key, r.responsibility_name
	       FROM fnd_responsibility_vl r, fnd_application a
	       WHERE a.application_short_name = p_application_short_name
	       AND r.application_id = a.application_id;

	  l_responsibilities responsibilities_array_type;
	  l_key              VARCHAR2(2000);
	  l_numof_indexes    NUMBER;
	  l_indexes          fnd_plsql_cache.custom_cache_indexes_type;
	  l_return_code      VARCHAR2(1);
	  i                  NUMBER;
     BEGIN
	--
	-- Create the key. If you have a composite key then concatenate
	-- them with a delimiter. i.e. p_key1 || '.' || p_key2 || ...
	--
	l_key := p_application_short_name;

	--
	-- First check the cache.
	--
	fnd_plsql_cache.custom_1tom_get_get_indexes(g_rsp_custom_1tom_controller,
						    l_key,
						    l_numof_indexes,
						    l_indexes,
						    l_return_code);

	IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
	   --
	   -- Entity is in the cache, populate the return values.
	   --
	   FOR i IN 1..l_numof_indexes LOOP
	      l_responsibilities(i) := g_rsp_custom_1tom_storage(l_indexes(i));
	   END LOOP;

	 ELSE
	   i := 0;
	   FOR r IN resp_cursor LOOP
	      i := i + 1;
	      l_responsibilities(i) := r;
	   END LOOP;
	   l_numof_indexes := i;
	   --
	   -- Put the values in cache.
	   --
	   fnd_plsql_cache.custom_1tom_get_put_indexes(g_rsp_generic_1tom_controller,
						       l_key,
						       l_numof_indexes,
						       l_indexes,
                                                       l_return_code);

           IF (l_return_code = CACHE_PUT_IS_SUCCESSFUL) THEN
              FOR i IN 1..l_numof_indexes LOOP
                 g_rsp_custom_1tom_storage(l_indexes(i)) := l_responsibilities(i);
              END LOOP;
           END IF;
	END IF;

	RETURN l_responsibilities;
     END get_responsibilities_custom;

     PROCEDURE any_procedure
       IS
	  l_fnd_application      application_record_type;
	  l_fnd_responsibilities responsibilities_array_type;
     BEGIN
	--
	-- This will hit the DB
	--
	l_fnd_application := get_application_generic('FND');
	l_fnd_responsibilities := get_responsibilities_generic('FND');

	--
	-- This will get it from cache.
	--
	l_fnd_application := get_application_generic('FND');
	l_fnd_responsibilities := get_responsibilities_generic('FND');

	--
	-- This will hit the DB
	--
	l_fnd_application := get_application_custom('FND');
	l_fnd_responsibilities := get_responsibilities_custom('FND');

	--
	-- This will get it from cache.
	--
	l_fnd_application := get_application_custom('FND');
	l_fnd_responsibilities := get_responsibilities_custom('FND');

     END any_procedure;

BEGIN
   --
   -- Assume that this is your package initialization section.
   --
   --
   -- Application Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('Application Generic 1to1 Cache',
				     g_app_generic_1to1_controller,
				     g_app_generic_1to1_storage);

   --
   -- Application Custom 1to1 Cache.
   --
   fnd_plsql_cache.custom_1to1_init('Application Custom 1to1 Cache',
				    g_app_custom_1to1_controller);
   g_app_custom_1to1_storage.DELETE;

   --
   -- Responsibilities Generic 1toM Cache
   --
   fnd_plsql_cache.generic_1tom_init('Responsibilities Generic 1toM Cache',
				     g_rsp_generic_1tom_controller,
				     g_rsp_generic_1tom_storage);

   --
   -- Responsibilities Custom 1toM Cache
   --
   fnd_plsql_cache.custom_1tom_init('Responsibilities Custom 1toM Cache',
				    g_rsp_custom_1tom_controller);
   g_rsp_custom_1tom_storage.DELETE;
END sample_package;

BEGIN
   g_newline := fnd_global.newline();
END fnd_plsql_cache;

/
