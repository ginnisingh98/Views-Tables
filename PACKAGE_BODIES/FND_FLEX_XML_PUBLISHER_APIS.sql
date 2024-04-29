--------------------------------------------------------
--  DDL for Package Body FND_FLEX_XML_PUBLISHER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_XML_PUBLISHER_APIS" AS
/* $Header: AFFFXPAB.pls 120.8.12010000.9 2015/11/25 09:59:01 shagagar ship $ */

--
-- Qualifier Segment Number  cache, generic version. One value per key
--
g_snum_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
g_snum_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;
--
-- Application cache, generic version. One value per key
--
g_app_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
g_app_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;

--
-- Key Flexfield cache, generic version. One value per key
--
g_kflx_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
g_kflx_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;

--
-- Key Flexfield Structure Number cache, generic version. Many values per key
--
g_stno_generic_1tom_controller fnd_plsql_cache.cache_1tom_controller_type;
g_stno_generic_1tom_storage    fnd_plsql_cache.generic_cache_values_type;
--
-- Key Flexfield Structure cache, generic version. One value per key
--
g_str_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
g_str_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;
--
--
-- Key Flexfield Segment cache, generic version. One value per key
--
g_seg_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
g_seg_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;
--
-- Key Flexfield Segment TL cache, generic version. One value per key
--
g_segt_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
g_segt_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;
--
-- Parent Value Set Id cache, generic version. One value per key
--
p_vsid_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
p_vsid_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;
--
-- Key Flexfield Segment Info, generic version. Many values per key
--
seginf_generic_1tom_controller fnd_plsql_cache.cache_1tom_controller_type;
seginf_generic_1tom_storage    fnd_plsql_cache.generic_cache_values_type;
--
-- Process KFF Combination, generic version. One value per key
--
prcomb_generic_1to1_controller fnd_plsql_cache.cache_1to1_controller_type;
prcomb_generic_1to1_storage    fnd_plsql_cache.generic_cache_values_type;

-- ERROR constants
--
error_others                   CONSTANT NUMBER := -20100;
error_no_data_found            CONSTANT NUMBER := -20101;
error_not_supported_yet        CONSTANT NUMBER := -20102;

--
-- Invalid Argument Errors
--
error_arg_arg_name_invalid     CONSTANT NUMBER := -20200;

error_arg_lexical_name_null    CONSTANT NUMBER := -20210;
error_arg_lexical_name_space   CONSTANT NUMBER := -20211;
error_arg_lexical_name_long    CONSTANT NUMBER := -20212;

error_arg_mdata_type_null      CONSTANT NUMBER := -20220;
error_arg_mdata_type_invalid   CONSTANT NUMBER := -20221;

error_arg_multi_num_null       CONSTANT NUMBER := -20230;
error_arg_multi_num_invalid    CONSTANT NUMBER := -20231;
error_arg_multi_num_misuse     CONSTANT NUMBER := -20232;

error_arg_segments_null        CONSTANT NUMBER := -20240;

error_arg_show_p_segs_null     CONSTANT NUMBER := -20250;
error_arg_show_p_segs_invalid  CONSTANT NUMBER := -20251;

error_arg_cct_alias_null       CONSTANT NUMBER := -20260;
error_arg_cct_alias_space      CONSTANT NUMBER := -20261;
error_arg_cct_alias_long       CONSTANT NUMBER := -20262;

error_arg_output_type_null     CONSTANT NUMBER := -20270;
error_arg_output_type_invalid  CONSTANT NUMBER := -20271;

error_arg_operator_null        CONSTANT NUMBER := -20280;
error_arg_operator_invalid     CONSTANT NUMBER := -20281;

error_arg_debug_mode_null      CONSTANT NUMBER := -20295;
error_arg_debug_mode_invalid   CONSTANT NUMBER := -20296;

--
-- Flex Metadata State Errors
--
error_no_enabled_frozen_str    CONSTANT NUMBER := -20301;
error_str_not_enabled          CONSTANT NUMBER := -20302;
error_str_not_frozen           CONSTANT NUMBER := -20303;

--
-- Runtime State Errors
--
error_invalid_seg_num          CONSTANT NUMBER := -20401;
error_invalid_seg_qual         CONSTANT NUMBER := -20402;


--
-- ARGUMENT Name Constants
--
arg_argument_name        CONSTANT VARCHAR2(30) := 'ARGUMENT_NAME';
arg_debug_mode           CONSTANT VARCHAR2(30) := 'DEBUG_MODE';
arg_lexical_name         CONSTANT VARCHAR2(30) := 'LEXICAL_NAME';
arg_metadata_type        CONSTANT VARCHAR2(30) := 'METADATA_TYPE';
arg_multiple_id_flex_num CONSTANT VARCHAR2(30) := 'MULTIPLE_ID_FLEX_NUM';
arg_id_flex_num          CONSTANT VARCHAR2(30) := 'ID_FLEX_NUM';
arg_segments             CONSTANT VARCHAR2(30) := 'SEGMENTS';
arg_show_parent_segments CONSTANT VARCHAR2(30) := 'SHOW_PARENT_SEGMENTS';
arg_cct_alias            CONSTANT VARCHAR2(30) := 'CODE_COMBINATION_TABLE_ALIAS';
arg_output_type          CONSTANT VARCHAR2(30) := 'OUTPUT_TYPE';
arg_operator             CONSTANT VARCHAR2(30) := 'OPERATOR';
arg_operand1             CONSTANT VARCHAR2(30) := 'OPERAND1';
arg_operand2             CONSTANT VARCHAR2(30) := 'OPERAND2';


--
-- <SEGMENTS> parser mode constants
-- Moved to Spec for public access
--segments_mode_all_enabled    CONSTANT VARCHAR2(30) := 'ALL_ENABLED';
--segments_mode_displayed_only CONSTANT VARCHAR2(30) := 'DISPLAYED_ONLY';


--
-- TYPEs
--
SUBTYPE app_type         IS fnd_application%ROWTYPE;
SUBTYPE kff_flx_type     IS fnd_id_flexs%ROWTYPE;
SUBTYPE kff_str_type     IS fnd_id_flex_structures%ROWTYPE;
SUBTYPE kff_seg_type     IS fnd_id_flex_segments%ROWTYPE;
SUBTYPE kff_seg_tl_type  IS fnd_id_flex_segments_tl%ROWTYPE;

TYPE varchar2_30_array_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE number_array_type      IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

TYPE decode_element_type IS RECORD
  (search NUMBER,
   result VARCHAR2(32000));

TYPE decode_elements_type IS TABLE OF decode_element_type INDEX BY BINARY_INTEGER;

--
-- Global Constants
--
max_numof_decode_elements CONSTANT NUMBER := 126;

--
-- Global Variables
--
g_newline          VARCHAR2(100);
g_unused_argument  VARCHAR2(100);
g_debug_enabled    BOOLEAN;
g_debug            VARCHAR2(32000);

--
-- Private APIs
--

--------------------------------------------------------------------------------
-- Wrapper for raise_application_error(<code>, <error>, TRUE);
--------------------------------------------------------------------------------
PROCEDURE raise_error
  (p_code  IN NUMBER,
   p_error IN VARCHAR2)
  IS
BEGIN
   raise_application_error(p_code, p_error, TRUE);

   -- No exception handling here
END raise_error;

--------------------------------------------------------------------------------
-- Raises exception for 'when others then' block
--------------------------------------------------------------------------------
PROCEDURE raise_others
  (p_method IN VARCHAR2,
   p_arg1   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg2   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg3   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg4   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg5   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg6   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg7   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg8   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg9   IN VARCHAR2 DEFAULT g_unused_argument)
  IS
   l_error VARCHAR2(32000);
BEGIN
   l_error := p_method || '(';

   if (p_arg1 <> g_unused_argument) then
      l_error := l_error || p_arg1;
   end if;

   if (p_arg2 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg2;
   end if;

   if (p_arg3 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg3;
   end if;

   if (p_arg4 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg4;
   end if;

   if (p_arg5 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg5;
   end if;

   if (p_arg6 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg6;
   end if;

   if (p_arg7 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg7;
   end if;

   if (p_arg8 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg8;
   end if;

   if (p_arg9 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg9;
   end if;

   l_error := l_error || ') raised exception.';

   raise_error(error_others, l_error);

   -- No exception handling here
END raise_others;

--------------------------------------------------------------------------------
-- Initializes Debugger
--------------------------------------------------------------------------------
PROCEDURE init_debug
  IS
BEGIN
   IF (g_debug_enabled) THEN
      g_debug := 'Flexfield Debugger is ON.' || g_newline;

    ELSE
      g_debug := 'Flexfield Debugger is OFF.' || g_newline;

   END IF;

   g_debug := g_debug ||
     'Package : FND_FLEX_XML_PUBLISHER_APIS' || g_newline ||
     'Version : $Header: AFFFXPAB.pls 120.8.12010000.9 2015/11/25 09:59:01 shagagar ship $' || g_newline ||
     'Sysdate : ' || To_char(Sysdate, 'YYYY/MM/DD HH24:MI:SS') || g_newline;

EXCEPTION
   WHEN OTHERS THEN
      raise_others('init_debug');
END init_debug;

--------------------------------------------------------------------------------
-- Adds Debug Messages
--------------------------------------------------------------------------------
PROCEDURE add_debug
  (p_method IN VARCHAR2,
   p_debug  IN VARCHAR2)
  IS
BEGIN
   IF (g_debug_enabled) THEN
      g_debug := g_debug ||
        p_method || ': ' || p_debug || g_newline;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('add_debug',
                   p_method,
                   p_debug);
END add_debug;

--------------------------------------------------------------------------------
-- Raises exception for 'when no_data_found then' block
--------------------------------------------------------------------------------
PROCEDURE raise_no_data_found
  (p_entity    IN VARCHAR2,
   p_key1      IN VARCHAR2,
   p_value1    IN VARCHAR2,
   p_key2      IN VARCHAR2 DEFAULT NULL,
   p_value2    IN VARCHAR2 DEFAULT NULL,
   p_key3      IN VARCHAR2 DEFAULT NULL,
   p_value3    IN VARCHAR2 DEFAULT NULL,
   p_key4      IN VARCHAR2 DEFAULT NULL,
   p_value4    IN VARCHAR2 DEFAULT NULL,
   p_key5      IN VARCHAR2 DEFAULT NULL,
   p_value5    IN VARCHAR2 DEFAULT NULL,
   p_key6      IN VARCHAR2 DEFAULT NULL,
   p_value6    IN VARCHAR2 DEFAULT NULL,
   p_key7      IN VARCHAR2 DEFAULT NULL,
   p_value7    IN VARCHAR2 DEFAULT NULL)
  IS
     l_error VARCHAR2(32000);
BEGIN
   l_error := ('<' || p_entity || '> does not exist. Primary Key: ' ||
               Upper(p_key1) || ':''' || p_value1 || '''');
   IF (p_key2 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key2) || ':''' || p_value2 || '''';
   END IF;
   IF (p_key3 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key3) || ':''' || p_value3 || '''';
   END IF;
   IF (p_key4 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key4) || ':''' || p_value4 || '''';
   END IF;
   IF (p_key5 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key5) || ':''' || p_value5 || '''';
   END IF;
   IF (p_key6 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key6) || ':''' || p_value6 || '''';
   END IF;
   IF (p_key7 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key7) || ':''' || p_value7 || '''';
   END IF;

   raise_error(error_no_data_found, l_error);

   -- No exception handling here.
END raise_no_data_found;


--------------------------------------------------------------------------------
-- Raises exception for invalid arguments.
--------------------------------------------------------------------------------
PROCEDURE raise_invalid_argument
  (p_error_code       IN NUMBER,
   p_argument_name    IN VARCHAR2,
   p_argument_value   IN VARCHAR2,
   p_problem          IN VARCHAR2 DEFAULT NULL,
   p_solution         IN VARCHAR2 DEFAULT NULL,
   p_valid_values     IN VARCHAR2 DEFAULT NULL)
  IS
     l_error VARCHAR2(32000);
BEGIN
   l_error :=
     'The value ''' || p_argument_value || ''' is not a valid ' ||
     'value for the argument ''' || p_argument_name || '''. ' ||
     g_newline;

   IF (p_problem IS NOT NULL) THEN
      l_error := l_error ||
        'Error: ' || p_problem || '. ' || g_newline;

      IF (p_solution IS NOT NULL) THEN
         l_error := l_error ||
           'Solution: ' || p_solution || '. ' || g_newline;
      END IF;
   END IF;

   IF (p_valid_values IS NOT NULL) THEN
      l_error := l_error ||
        'The valid values are ''' || p_valid_values || '''. ' ||
        'Please see $FND_TOP/patch/115/sql/AFFFXPAS.pls file ' ||
        'for more information. ';
    ELSE
      l_error := l_error ||
        'Please see $FND_TOP/patch/115/sql/AFFFXPAS.pls file ' ||
        'for valid values and more information. ';
   END IF;

   raise_error(p_error_code, l_error);

   -- No exception handling here
END raise_invalid_argument;

--------------------------------------------------------------------------------
-- Raises Error for NOT NULL Arguments
--------------------------------------------------------------------------------
PROCEDURE raise_argument_null(p_argument_name IN VARCHAR2,
                              p_error_code    IN NUMBER)
  IS
BEGIN
   raise_invalid_argument
     (p_error_code     => p_error_code,
      p_argument_name  => p_argument_name,
      p_argument_value => NULL,
      p_problem        => 'NULL is not a valid value for ' || p_argument_name,
      p_solution       => 'Please use a NOT NULL value for ' || p_argument_name,
      p_valid_values   => NULL);

   -- No exception handling here.
END raise_argument_null;

--------------------------------------------------------------------------------
-- Validates Arguments
--------------------------------------------------------------------------------
PROCEDURE validate_argument(p_argument_name  IN VARCHAR2,
                            p_argument_value IN VARCHAR2)
  IS
     l_error_code   NUMBER;
     l_problem      VARCHAR2(32000);
     l_solution     VARCHAR2(32000);
     l_valid_values VARCHAR2(32000);
BEGIN
   l_error_code := NULL;
   l_problem := NULL;
   l_solution := NULL;
   l_valid_values := NULL;

   IF (p_argument_name = arg_lexical_name) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_lexical_name_null);

       ELSIF (Instr(p_argument_value, ' ') > 0) THEN
         l_error_code := error_arg_lexical_name_space;
         l_problem := p_argument_name || ' cannot contain space character';
         l_solution := 'Please remove space character from ' || p_argument_name;

       ELSIF (Length(p_argument_value) > 25) THEN
         l_error_code := error_arg_lexical_name_long;
         l_problem := p_argument_name || ' cannot be longer than 25 characters';
         l_solution := 'Please use a shorter ' || p_argument_name;

      END IF;

    ELSIF (p_argument_name = arg_debug_mode) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_debug_mode_null);

       ELSIF (p_argument_value NOT IN (debug_mode_on,
                                       debug_mode_off)) THEN
         l_error_code := error_arg_debug_mode_invalid;
         l_valid_values :=
           debug_mode_on || ', ' ||
           debug_mode_off;

      END IF;

    ELSIF (p_argument_name = arg_metadata_type) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_mdata_type_null);

       ELSIF (p_argument_value NOT IN (metadata_segments_above_prompt,
                                       metadata_segments_left_prompt)) THEN
         l_error_code := error_arg_mdata_type_invalid;
         l_valid_values :=
           metadata_segments_above_prompt || ', ' ||
           metadata_segments_left_prompt;

      END IF;

    ELSIF (p_argument_name = arg_multiple_id_flex_num) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_multi_num_null);

       ELSIF (p_argument_value NOT IN ('Y', 'N')) THEN
         l_error_code := error_arg_multi_num_invalid;
         l_valid_values := 'Y, N';

      END IF;

    ELSIF (p_argument_name = arg_segments) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_segments_null);

      END IF;

    ELSIF (p_argument_name = arg_show_parent_segments) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_show_p_segs_null);

       ELSIF (p_argument_value NOT IN ('Y', 'N')) THEN
         l_error_code := error_arg_show_p_segs_invalid;
         l_valid_values := 'Y, N';

      END IF;

    ELSIF (p_argument_name = arg_cct_alias) THEN
      IF (p_argument_value IS NULL) THEN
         --
         -- NULL value is OK for CODE_COMBINATION_TABLE_ALIAS
         --
         NULL;

       ELSIF (Instr(p_argument_value, ' ') > 0) THEN
         l_error_code := error_arg_cct_alias_space;
         l_problem := p_argument_name || ' cannot contain space character';
         l_solution := 'Please remove space character from ' || p_argument_name;

       ELSIF (Length(p_argument_value) > 30) THEN
         l_error_code := error_arg_cct_alias_long;
         l_problem := p_argument_name || ' cannot be longer than 30 characters';
         l_solution := 'Please use a shorter ' || p_argument_name;

      END IF;

    ELSIF (p_argument_name = arg_output_type) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_output_type_null);

       ELSIF (p_argument_value NOT IN (output_type_value,
                                       output_type_padded_value,
                                       output_type_description,
                                       output_type_full_description,
                                       output_type_security)) THEN
         l_error_code := error_arg_output_type_invalid;
         l_valid_values :=
           output_type_value            || ', ' ||
           output_type_padded_value     || ', ' ||
           output_type_description      || ', ' ||
           output_type_full_description || ', ' ||
           output_type_security;
      END IF;

    ELSIF (p_argument_name = arg_operator) THEN
      IF (p_argument_value IS NULL) THEN
         raise_argument_null(p_argument_name, error_arg_operator_null);

       ELSIF (p_argument_value NOT IN (operator_equal,
                                       operator_less_than,
                                       operator_greater_than,
                                       operator_less_than_or_equal,
                                       operator_greater_than_or_equal,
                                       operator_not_equal,
                                       operator_concatenate,
                                       operator_between,
                                       operator_qbe,
                                       operator_like)) THEN
         l_error_code := error_arg_operator_invalid;
         l_valid_values :=
           operator_equal                 || ', ' ||
           operator_less_than             || ', ' ||
           operator_greater_than          || ', ' ||
           operator_less_than_or_equal    || ', ' ||
           operator_greater_than_or_equal || ', ' ||
           operator_not_equal             || ', ' ||
           operator_concatenate           || ', ' ||
           operator_between               || ', ' ||
           operator_qbe                   || ', ' ||
           operator_like;

      END IF;

    ELSE
      l_error_code := error_arg_arg_name_invalid;
      l_problem := 'Flex Developer Error: Argument Name is not known';
      l_solution := 'Please open a bug against 510/FLEXFIELDS';

   END IF;

   IF (l_error_code IS NOT NULL) THEN
      raise_invalid_argument(p_error_code     => l_error_code,
                             p_argument_name  => p_argument_name,
                             p_argument_value => p_argument_value,
                             p_problem        => l_problem,
                             p_solution       => l_solution,
                             p_valid_values   => l_valid_values);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise_others('validate_argument',
                   p_argument_name,
                   p_argument_value);
END validate_argument;

--------------------------------------------------------------------------------
-- Cross Validates Arguments
--------------------------------------------------------------------------------
PROCEDURE cross_validate_arguments(p_argument1_name  IN VARCHAR2,
                                   p_argument1_value IN VARCHAR2,
                                   p_argument2_name  IN VARCHAR2,
                                   p_argument2_value IN VARCHAR2)
  IS
     l_error_code   NUMBER;
     l_error        VARCHAR2(32000);
BEGIN
   l_error_code := NULL;
   l_error := NULL;

   IF (p_argument1_name = arg_multiple_id_flex_num) THEN
      IF (p_argument2_name = arg_id_flex_num) THEN
         --
         -- multiple_id_flex_num
         -- |    id_flex_num  result
         -- ---  -----------  -----------
         -- N    NULL         ERROR
         -- N    NOT NULL     OK
         -- Y    NULL         OK
         -- Y    NOT NULL     ERROR BUT IGNORE, assume id_flex_num = NULL
         --
         IF (p_argument1_value = 'N' AND p_argument2_value IS NULL) THEN
            l_error_code := error_arg_multi_num_misuse;
            l_error :=
              'MULTIPLE_ID_FLEX_NUM and ID_FLEX_NUM arguments are not ' ||
              'passed properly. Valid combinations are : ' ||
              '(MULTIPLE_ID_FLEX_NUM = Y) OR ' ||
              '(MULTIPLE_ID_FLEX_NUM = N AND ID_FLEX_NUM = NOT NULL).';
         END IF;
      END IF;
   END IF;

   IF (l_error_code IS NOT NULL) THEN
      raise_error(l_error_code, l_error);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise_others('cross_validate_arguments',
                   p_argument1_name,
                   p_argument1_value,
                   p_argument2_name,
                   p_argument2_value);
END cross_validate_arguments;

--------------------------------------------------------------------------------
-- Returns Application details.
--------------------------------------------------------------------------------
PROCEDURE get_app
  (p_application_short_name       IN fnd_application.application_short_name%TYPE,
   x_app                          OUT nocopy app_type)
  IS
     l_application app_type;
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

     ELSE
       --
       -- Entity is not in the cache, get it from DB.
       --
       BEGIN
          SELECT fa.*
            INTO l_application
            FROM fnd_application fa
           WHERE fa.application_short_name = p_application_short_name;
       --
       -- Create the cache value, and populate it with values came from DB.
       --
       fnd_plsql_cache.generic_cache_new_value
         (x_value      => l_value,
          p_number_1   => l_application.application_id,
          p_varchar2_1 => l_application.application_short_name);

       --
       -- Put the value in cache.
       --
       fnd_plsql_cache.generic_1to1_put_value(g_app_generic_1to1_controller,
                                              g_app_generic_1to1_storage,
                                              l_key,
                                              l_value);
       EXCEPTION
          WHEN no_data_found THEN
             raise_no_data_found
               ('Application',
                'application_short_name', p_application_short_name);
       END;
    END IF;
    --
    -- Return the output value.
    --
    x_app := l_application;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_app',
                   p_application_short_name);
END get_app;


--------------------------------------------------------------------------------
-- Returns Key Flexfield details.
--------------------------------------------------------------------------------
PROCEDURE get_kff_flx
  (p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   x_kff_flx                      OUT nocopy kff_flx_type)
  IS
     l_application app_type;
     l_kff_flx     kff_flx_type;
     l_key         VARCHAR2(2000);
     l_value       fnd_plsql_cache.generic_cache_value_type;
     l_return_code VARCHAR2(1);
BEGIN
    get_app(p_application_short_name, l_application);

    --
    -- Create the key.
    --
    l_key := p_application_short_name || '.' || p_id_flex_code;
    --
    -- First check the cache.
    --
    fnd_plsql_cache.generic_1to1_get_value(g_kflx_generic_1to1_controller,
                                           g_kflx_generic_1to1_storage,
                                           l_key,
                                           l_value,
                                           l_return_code);
    IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        --
        -- Entity is in the cache, populate the return value.
        --
        l_kff_flx.application_id := l_value.number_1;
        l_kff_flx.id_flex_code := l_value.varchar2_1;
        l_kff_flx.set_defining_column_name := l_value.varchar2_2;
        l_kff_flx.unique_id_column_name := l_value.varchar2_3;

    ELSE
        --
        -- Entity is not in the cache, get it from DB.
        --
        BEGIN
           SELECT fif.*
             INTO l_kff_flx
             FROM fnd_id_flexs fif
             WHERE fif.application_id = l_application.application_id
             AND fif.id_flex_code = p_id_flex_code;
        --
        -- Create the cache value, and populate it with values came from DB.
        --
        fnd_plsql_cache.generic_cache_new_value
          (x_value      => l_value,
           p_number_1   => l_kff_flx.application_id,
           p_varchar2_1 => l_kff_flx.id_flex_code,
           p_varchar2_2 => l_kff_flx.set_defining_column_name,
           p_varchar2_3 => l_kff_flx.unique_id_column_name);

        --
        -- Put the value in cache.
        --
        fnd_plsql_cache.generic_1to1_put_value(g_kflx_generic_1to1_controller,
                                               g_kflx_generic_1to1_storage,
                                               l_key,
                                               l_value);
        EXCEPTION
           WHEN no_data_found THEN
              raise_no_data_found
                ('Application',
                 'application_short_name', p_application_short_name);
        END;
    END IF;
    --
    -- Return the output value.
    --
    x_kff_flx := l_kff_flx;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_kff_flx',
                   p_application_short_name,
                   p_id_flex_code);
END get_kff_flx;


--------------------------------------------------------------------------------
-- Returns Structure Numbers of enabled and frozen KFF Structures.
--------------------------------------------------------------------------------
PROCEDURE get_kff_str_numbers
  (p_kff_flx                      IN kff_flx_type,
   x_numof_structures             OUT nocopy NUMBER,
   x_structure_numbers            OUT nocopy number_array_type)
  IS
      l_key               VARCHAR2(2000);
      l_values            fnd_plsql_cache.generic_cache_values_type;
      l_numof_values      NUMBER;
      l_return_code       VARCHAR2(1);
      i                   NUMBER;
      l_numof_structures  NUMBER;
      l_structure_numbers number_array_type;
BEGIN
    --
    -- Create the key.
    --
    l_key := p_kff_flx.application_id || '.' || p_kff_flx.id_flex_code;

    --
    -- First check the cache.
    --
    fnd_plsql_cache.generic_1tom_get_values(g_stno_generic_1tom_controller,
                                            g_stno_generic_1tom_storage,
                                            l_key,
                                            l_numof_values,
                                            l_values,
                                            l_return_code);

    IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        --
        -- Entity is in the cache, populate the return values.
        --
        FOR i IN 1..l_numof_values LOOP
           l_structure_numbers(i) := l_values(i).number_1;
        END LOOP;
        l_numof_structures := l_numof_values;
    ELSE
       SELECT fifst.id_flex_num
         BULK COLLECT INTO l_structure_numbers
         FROM fnd_id_flex_structures fifst
        WHERE fifst.application_id = p_kff_flx.application_id
          AND fifst.id_flex_code = p_kff_flx.id_flex_code
          AND fifst.enabled_flag = 'Y'
          AND fifst.freeze_flex_definition_flag = 'Y'
     ORDER BY fifst.id_flex_num;

        l_numof_structures := SQL%ROWCOUNT;
        FOR i IN 1..l_structure_numbers.COUNT LOOP
           --
           -- Create the cache value, and populate it with values came from DB.
           --
           fnd_plsql_cache.generic_cache_new_value
                    (x_value      => l_values(i),
                    p_number_1    => l_structure_numbers(i));
        END LOOP;
        l_numof_values := l_numof_structures;
        --
        -- Put the values in cache.
        --
        fnd_plsql_cache.generic_1tom_put_values(g_stno_generic_1tom_controller,
                                                g_stno_generic_1tom_storage,
                                                l_key,
                                                l_numof_values,
                                                l_values);
    END IF;



    IF (l_numof_structures = 0) THEN
       raise_error(error_no_enabled_frozen_str,
                  'There are no ENABLED and FROZEN structures.');

    END IF;
    --
    -- Return the values
    --
    x_numof_structures  := l_numof_structures;
    x_structure_numbers := l_structure_numbers;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_kff_str_numbers',
                   p_kff_flx.application_id,
                   p_kff_flx.id_flex_code);
END get_kff_str_numbers;


--------------------------------------------------------------------------------
-- Returns KFF Structure
--------------------------------------------------------------------------------
PROCEDURE get_kff_str
  (p_kff_flx                      IN kff_flx_type,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   x_kff_str                      OUT nocopy kff_str_type)
  IS
      l_key               VARCHAR2(2000);
      l_return_code       VARCHAR2(1);
      l_value             fnd_plsql_cache.generic_cache_value_type;
      l_kff_str           kff_str_type;
BEGIN
    --
    -- Create the key.
    --
    l_key := p_kff_flx.application_id || '.' || p_kff_flx.id_flex_code || '.' || p_id_flex_num;

    --
    -- First check the cache.
    --
    fnd_plsql_cache.generic_1to1_get_value(g_str_generic_1to1_controller,
                                           g_str_generic_1to1_storage,
                                           l_key,
                                           l_value,
                                           l_return_code);

    IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        --
        -- Entity is in the cache, populate the return value.
        --
        l_kff_str.application_id := l_value.number_1;
        l_kff_str.id_flex_code := l_value.varchar2_1;
        l_kff_str.id_flex_num := l_value.number_2;
        l_kff_str.concatenated_segment_delimiter := l_value.varchar2_2;

    ELSE
        --
        -- Entity is not in the cache, get it from DB.
        --
        BEGIN
           SELECT fifst.*
             INTO l_kff_str
             FROM fnd_id_flex_structures fifst
            WHERE fifst.application_id = p_kff_flx.application_id
              AND fifst.id_flex_code = p_kff_flx.id_flex_code
              AND fifst.id_flex_num = p_id_flex_num;
        --
        -- Create the cache value, and populate it with values came from DB.
        --
        fnd_plsql_cache.generic_cache_new_value
          (x_value      => l_value,
           p_number_1   => l_kff_str.application_id,
           p_varchar2_1 => l_kff_str.id_flex_code,
           p_number_2 => l_kff_str.id_flex_num,
           p_varchar2_2 => l_kff_str.concatenated_segment_delimiter);

        --
        -- Put the value in cache.
        --
        fnd_plsql_cache.generic_1to1_put_value(g_str_generic_1to1_controller,
                                               g_str_generic_1to1_storage,
                                               l_key,
                                               l_value);
        EXCEPTION
           WHEN no_data_found THEN
              raise_no_data_found
                ('Key Flexfield Structure',
                 'application_id', p_kff_flx.application_id,
                 'id_flex_code', p_kff_flx.id_flex_code,
                 'id_flex_num', p_id_flex_num);
        END;
    END IF;

    IF (l_kff_str.enabled_flag <> 'Y') THEN
      raise_error(error_str_not_enabled,
                  'KFF Structure is not enabled.');

    ELSIF (l_kff_str.freeze_flex_definition_flag <> 'Y') THEN
      raise_error(error_str_not_frozen,
                  'KFF Structure is not frozen.');

   END IF;
   --
   -- Return the output value
   --
   x_kff_str := l_kff_str;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_kff_str',
                   p_kff_flx.application_id,
                   p_kff_flx.id_flex_code,
                   p_id_flex_num);
END get_kff_str;

--------------------------------------------------------------------------------
--  Returns Column Names
--
--  Please note the output given by get_kff_seg_column_names
--  for some cases using following example.
--  (segment1 (s1) is parent of segment2 (s2) and both are enabled).
--  p_s_m    => p_segments_mode; DO => DISPLAYED_ONLY; AE => ALL_ENABLED.
--  p_s      => p_segments
--  p_s_p_s  => p_show_parent_segments
--  s1d, s2d => segment1, segment2 displayed in segments form
--  x_c_n    => x_column_names (segment number given for illustration)
--
--  p_s_m   p_s   p_s_p_s      s1d   s2d      x_c_n
--
--  DO       2       Y          Y     Y        1,2
--  DO       2       Y          Y     N         1
--  DO       2       Y          N     Y         2
--  DO       2       N          Y     Y         2
--  AE       2       Y         Y/N   Y/N       1,2
--  AE       2       N         Y/N   Y/N        2
--------------------------------------------------------------------------------
PROCEDURE get_kff_seg_column_names
  (p_kff_str                      IN kff_str_type,
   p_segments_mode                IN VARCHAR2,
   p_segments                     IN VARCHAR2,
   p_show_parent_segments         IN VARCHAR2,
   x_numof_column_names           OUT nocopy NUMBER,
   x_column_names                 OUT nocopy varchar2_30_array_type)
  IS
     TYPE segment_info IS RECORD
       (application_column_name fnd_id_flex_segments.application_column_name%TYPE,
        display_flag            fnd_id_flex_segments.display_flag%TYPE,
        enabled_flag            fnd_id_flex_segments.enabled_flag%TYPE,
        flex_value_set_id       fnd_id_flex_segments.flex_value_set_id%TYPE,
        to_include              VARCHAR2(1),
        is_parent               VARCHAR2(1),
        child_segment_num       NUMBER);

     TYPE segment_info_array IS TABLE of segment_info INDEX BY BINARY_INTEGER;

     l_include             varchar2_30_array_type;
     l_exclude             varchar2_30_array_type;
     l_column_names        varchar2_30_array_type;
     l_nsegments           NUMBER;
     l_tmp_number          NUMBER;
     l_display_index       NUMBER;
     l_parent_value_set_id fnd_flex_value_sets.parent_flex_value_set_id%TYPE;
     l_value               fnd_plsql_cache.generic_cache_value_type;
     l_key                 VARCHAR2(2000);
     l_values              fnd_plsql_cache.generic_cache_values_type;
     l_numof_values        NUMBER;
     l_return_code         VARCHAR2(1);
     l_segment_info_array  segment_info_array;

     CURSOR c_segment_info(c_application_id fnd_id_flex_segments.application_id%TYPE,
                           c_id_flex_code   fnd_id_flex_segments.id_flex_code%TYPE,
                           c_id_flex_num    fnd_id_flex_segments.id_flex_num%TYPE)
       IS
          SELECT application_column_name, enabled_flag, display_flag, flex_value_set_id
            FROM fnd_id_flex_segments
            WHERE application_id = c_application_id
            AND   id_flex_code = c_id_flex_code
            AND   id_flex_num = c_id_flex_num
            ORDER BY segment_num, segment_name;

     --  Procedures/functions private to get_kff_seg_column_names start here.

     --  ------------------------------------------------------------------------
     --    Takes p_segments and tokenises into l_include and l_exclude array.
     --    Eg. p_segments => ALL\01, l_include(0)=ALL, l_exclude(0)=1
     --    p_segments => ALL\0GL_ACCOUNT, l_include(0)=ALL, l_exclude(0)=GL_ACCOUNT
     --    p_segments => GL_BALANCING, l_include(0)=GL_BALANCING
     --  ------------------------------------------------------------------------
     PROCEDURE kff_parse_string
       (p_segments                     IN VARCHAR2,
        x_include                      OUT nocopy varchar2_30_array_type,
        x_exclude                      OUT nocopy varchar2_30_array_type)
       IS
          l_delimiter     VARCHAR2(2);
          l_tmpsegments   VARCHAR2(1000);
          l_char          VARCHAR2(1000);
          l_include_index NUMBER;
          l_exclude_index NUMBER;
     BEGIN
        l_delimiter := '\0';
        l_include_index := 0;
        l_exclude_index := 0;
        l_tmpsegments := p_segments;

        l_char := instr(p_segments, '\0');
        IF (l_char = 0)
          THEN
           x_include(l_include_index) := p_segments;
           l_include_index := l_include_index + 1;
         ELSE
           x_include(l_include_index) := substr(p_segments, 1, l_char-1);
           l_include_index := l_include_index + 1;
           l_tmpsegments := substr(p_segments, l_char+2);

           LOOP
              l_char := instr(l_tmpsegments, '\0');
              IF (l_char = 0)
                THEN
                 x_exclude(l_exclude_index) := l_tmpsegments;
                 exit;
              END IF;
              x_exclude(l_exclude_index) := substr(l_tmpsegments, 1, l_char-1);
              l_exclude_index := l_exclude_index + 1;
              l_tmpsegments := substr(l_tmpsegments, l_char+2);
           END LOOP;

        END IF;

     EXCEPTION
        WHEN OTHERS THEN
           raise_others('kff_parse_string',
                        p_segments);
     END kff_parse_string;

     FUNCTION is_flexfield_qualifier_valid(p_application_id         IN  NUMBER,
                                           p_id_flex_code           IN  VARCHAR2,
                                           p_segment_attribute_type IN  VARCHAR2)
       RETURN BOOLEAN
       IS
           l_cnt NUMBER;
     BEGIN
        SELECT count(*)
           INTO l_cnt
           FROM fnd_segment_attribute_types
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND segment_attribute_type = p_segment_attribute_type;

        IF (l_cnt > 0)
        THEN
          return(TRUE);
        ELSE
          return(FALSE);
        END IF;

     EXCEPTION
        WHEN OTHERS THEN
           return(FALSE);
     END is_flexfield_qualifier_valid;

     --  ------------------------------------------------------------------------
     --      Gets the segment number corresponding to the qualifier
     --      name entered.  Segment number is the display order of the segment
     --      not to be confused with the SEGMENT_NUM column of the
     --      FND_ID_FLEX_SEGMENTS table.  Returns TRUE segment_number if ok,
     --      or FALSE and sets error using FND_MESSAGES on error.
     --      If the qualifier is non-unique, it gives the first segment with this
     --      qualifier that appears in flexfield window. (Ref: FF guide page 295).
     --  ------------------------------------------------------------------------
     FUNCTION get_qualifier_segnum(appl_id          IN  NUMBER,
                                   key_flex_code    IN  VARCHAR2,
                                   structure_number IN  NUMBER,
                                   flex_qual_name   IN  VARCHAR2,
                                   segment_number   OUT nocopy NUMBER)
       RETURN BOOLEAN
       IS
          l_key               VARCHAR2(2000);
          l_return_code       VARCHAR2(1);
          l_value             fnd_plsql_cache.generic_cache_value_type;
          l_segment_number    NUMBER;
          this_segment_num    NUMBER;
     BEGIN
     --
     -- Create the key.
     --
     l_key := appl_id || '.' || key_flex_code || '.' || structure_number || '.' || flex_qual_name;

     --
     -- First check the cache.
     --
     fnd_plsql_cache.generic_1to1_get_value(g_snum_generic_1to1_controller,
                                            g_snum_generic_1to1_storage,
                                            l_key,
                                            l_value,
                                            l_return_code);
     IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        --
        -- Entity is in the cache, populate the return value.
        --
        l_segment_number := l_value.number_1;
     ELSE
        --
        -- Entity is not in the cache, get it from DB.
        --
        SELECT s.segment_num
          INTO this_segment_num
          FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
               fnd_segment_attribute_types sat
         WHERE s.application_id = appl_id
           AND s.id_flex_code = key_flex_code
           AND s.id_flex_num = structure_number
           AND s.enabled_flag = 'Y'
           AND s.application_column_name = sav.application_column_name
           AND sav.application_id = appl_id
           AND sav.id_flex_code = key_flex_code
           AND sav.id_flex_num = structure_number
           AND sav.attribute_value = 'Y'
           AND sav.segment_attribute_type = sat.segment_attribute_type
           AND sat.application_id = appl_id
           AND sat.id_flex_code = key_flex_code
         --AND sat.unique_flag = 'Y' -- We need to look for non-unique qual. also.
           AND sat.segment_attribute_type = flex_qual_name
           AND ROWNUM < 2
           AND '$Header: AFFFXPAB.pls 120.8.12010000.9 2015/11/25 09:59:01 shagagar ship $' IS NOT NULL
      ORDER BY s.segment_num; -- Order By and rownum < 2 ensures we get first segment.

        SELECT count(segment_num)
          INTO l_segment_number
          FROM fnd_id_flex_segments
         WHERE application_id = appl_id
          AND id_flex_code = key_flex_code
          AND id_flex_num = structure_number
          AND enabled_flag = 'Y'
          AND segment_num <= this_segment_num
          AND '$Header: AFFFXPAB.pls 120.8.12010000.9 2015/11/25 09:59:01 shagagar ship $' IS NOT NULL;

        --
        -- Create the cache value, and populate it with values came from DB.
        --
        fnd_plsql_cache.generic_cache_new_value
            (x_value      => l_value,
             p_number_1   => l_segment_number);
        --
        -- Put the value in cache.
        --
        fnd_plsql_cache.generic_1to1_put_value(g_snum_generic_1to1_controller,
                                               g_snum_generic_1to1_storage,
                                               l_key,
                                               l_value);
     END IF;
     segment_number := l_segment_number;

     return(TRUE);

     EXCEPTION
        WHEN OTHERS THEN
           return(FALSE);
     END get_qualifier_segnum;

     /* ----------------------------------------------------------------------- */
     /*      Converts character representation of a number to a number.         */
     /*      Returns TRUE if it's a valid number, and FALSE otherwise.          */
     FUNCTION isa_number(teststr IN VARCHAR2,
                         outnum OUT nocopy NUMBER) RETURN BOOLEAN IS
     BEGIN
        outnum := to_number(teststr);
        return(TRUE);
     EXCEPTION
        WHEN OTHERS then
           return(FALSE);
     END isa_number;

     --  Procedures/functions private to get_kff_seg_column_names end here.


BEGIN

   kff_parse_string(p_segments, l_include, l_exclude);

   l_nsegments := 0;

   --  Get segment name, display flag and value set id for the KFF structure.

   --
   -- Create the key.
   --
   l_key := p_kff_str.application_id||'.'||p_kff_str.id_flex_code||'.'||p_kff_str.id_flex_num;
   --
   -- First check the cache.
   --
   fnd_plsql_cache.generic_1tom_get_values(seginf_generic_1tom_controller,
                                           seginf_generic_1tom_storage,
                                           l_key,
                                           l_numof_values,
                                           l_values,
                                           l_return_code);
   IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      --
      -- Entity is in the cache, populate the return values.
      --
      FOR i IN 1..l_numof_values LOOP
         l_nsegments := l_nsegments + 1;
         l_segment_info_array(l_nsegments).application_column_name := l_values(i).varchar2_1;
         l_segment_info_array(l_nsegments).enabled_flag := l_values(i).varchar2_2;
         l_segment_info_array(l_nsegments).display_flag := l_values(i).varchar2_3;
         l_segment_info_array(l_nsegments).flex_value_set_id := l_values(i).number_1;
      END LOOP;
   ELSE
      FOR l_segment_info IN c_segment_info(p_kff_str.application_id, p_kff_str.id_flex_code, p_kff_str.id_flex_num) LOOP
         l_nsegments := l_nsegments + 1;
         l_segment_info_array(l_nsegments).application_column_name := l_segment_info.application_column_name;
         l_segment_info_array(l_nsegments).enabled_flag := l_segment_info.enabled_flag;
         l_segment_info_array(l_nsegments).display_flag := l_segment_info.display_flag;
         l_segment_info_array(l_nsegments).flex_value_set_id := l_segment_info.flex_value_set_id;
         --
         -- Create the cache value, and populate it with values came from DB.
         --
         fnd_plsql_cache.generic_cache_new_value
           (x_value      => l_values(l_nsegments),
            p_varchar2_1 => l_segment_info.application_column_name,
            p_varchar2_2 => l_segment_info.enabled_flag,
            p_varchar2_3 => l_segment_info.display_flag,
            p_number_1   => l_segment_info.flex_value_set_id);
      END LOOP;
      --
      -- Put the values in cache.
      --
      fnd_plsql_cache.generic_1tom_put_values(seginf_generic_1tom_controller,
                                              seginf_generic_1tom_storage,
                                              l_key,
                                              l_nsegments,
                                              l_values);
   END IF;

   --  Determine if a segment is to be included or excluded.

   IF (l_include(0) = 'ALL')
     THEN
      FOR i IN 1..l_nsegments LOOP
         l_segment_info_array(i).to_include := 'Y';
      END LOOP;
    ELSE
      FOR i IN 1..l_nsegments LOOP
         l_segment_info_array(i).to_include := 'N';
      END LOOP;
      IF (isa_number(l_include(0), l_tmp_number))
        THEN
         IF (l_tmp_number between 1 and l_nsegments)
           THEN
            l_segment_info_array(l_tmp_number).to_include := 'Y';
         END IF;
       ELSE
         IF (is_flexfield_qualifier_valid(p_kff_str.application_id, p_kff_str.id_flex_code, l_include(0)))
         THEN
           IF (get_qualifier_segnum(p_kff_str.application_id, p_kff_str.id_flex_code, p_kff_str.id_flex_num, l_include(0), l_tmp_number))
           THEN
             l_segment_info_array(l_tmp_number).to_include := 'Y';
           END IF;
         ELSE
           raise_error(error_invalid_seg_qual, 'Invalid Qualifier: '||l_include(0));
         END IF;
      END IF;
   END IF;

   IF l_exclude.count <> 0
     THEN
      FOR i IN l_exclude.first .. l_exclude.last
        LOOP
           IF (isa_number(l_exclude(i), l_tmp_number))
             THEN
              IF (l_tmp_number between 1 and l_nsegments)
                THEN
                 l_segment_info_array(l_tmp_number).to_include := 'N';
              END IF;
            ELSE
              IF (is_flexfield_qualifier_valid(p_kff_str.application_id, p_kff_str.id_flex_code, l_exclude(i)))
              THEN
                IF (get_qualifier_segnum(p_kff_str.application_id, p_kff_str.id_flex_code, p_kff_str.id_flex_num, l_exclude(i), l_tmp_number))
                THEN
                  l_segment_info_array(l_tmp_number).to_include := 'N';
                END IF;
              END IF;
           END IF;
        END LOOP;
   END IF;

   --  See if a segment is a parent and if yes, assign child segment number
   --  and set is_parent flag to 'Y'.

   FOR i IN 1..l_nsegments
     LOOP
        l_segment_info_array(i).is_parent := 'N';

        IF (l_segment_info_array(i).flex_value_set_id IS NOT NULL) THEN
           --
           -- Create the key.
           --
           l_key := l_segment_info_array(i).flex_value_set_id;
           --
           -- First check the cache.
           --
           fnd_plsql_cache.generic_1to1_get_value(p_vsid_generic_1to1_controller,
                                               p_vsid_generic_1to1_storage,
                                               l_key,
                                               l_value,
                                               l_return_code);
           IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
              --
              -- Entity is in the cache, populate the return value.
              --
               l_parent_value_set_id := l_value.number_1;
           ELSE
              --
              -- Entity is not in the cache, get it from DB.
              --
              SELECT parent_flex_value_set_id INTO l_parent_value_set_id
                 FROM fnd_flex_value_sets
                 WHERE flex_value_set_id = l_segment_info_array(i).flex_value_set_id;
              --
              -- Create the cache value, and populate it with values came from DB.
              --
              fnd_plsql_cache.generic_cache_new_value
                (x_value      => l_value,
                 p_number_1   => l_parent_value_set_id);
              --
              -- Put the value in cache.
              --
              fnd_plsql_cache.generic_1to1_put_value(p_vsid_generic_1to1_controller,                                                 p_vsid_generic_1to1_storage,
                                                     l_key,
                                                     l_value);
           END IF;

        END IF;

        IF (l_parent_value_set_id is NOT NULL) THEN
           FOR j IN reverse 1..i
             LOOP
                IF (l_segment_info_array(j).flex_value_set_id = l_parent_value_set_id)
                  THEN
                   l_segment_info_array(j).is_parent := 'Y';
                   l_segment_info_array(j).child_segment_num := i;
                   exit;
                END IF;
             END LOOP;
        END IF;

     END LOOP;

     l_display_index := 0;

     --  Decide which all segments are to be displayed. Display a segment if:
     --  1) If a segment is enabled AND
     --  2) If p_segments_mode is ALL_ENABLED OR p_segments_mode is DISPLAYED_ONLY
     --     and segment is displayed AND
     --  3) A segment's include flag is 'Y' OR
     --  4) p_show_parent_segments is 'Y', a segment is a parent and child
     --     segment's include flag is 'Y'.
     --  ie, it should be 1 AND 2 AND (3 OR 4).
     --  The basic idea is to find out whether segments are to be displayed or not
     --  using the input p_segments irrespective of the enabled/displayed flag
     --  in segments form and then finally combine both.

     FOR i IN 1..l_nsegments
       LOOP

          IF (l_segment_info_array(i).enabled_flag = 'Y')
            THEN
             IF ((p_segments_mode = 'ALL_ENABLED') OR
                 ((p_segments_mode = 'DISPLAYED_ONLY') AND l_segment_info_array(i).display_flag = 'Y'))
               THEN
                IF ((l_segment_info_array(i).to_include = 'Y') OR
                    (p_show_parent_segments = 'Y' AND l_segment_info_array(i).is_parent = 'Y' AND l_segment_info_array(l_segment_info_array(i).child_segment_num).to_include = 'Y'))
                  THEN
                   l_display_index := l_display_index + 1;
                   l_column_names(l_display_index) := l_segment_info_array(i).application_column_name;
                END IF;
             END IF;
          END IF;

       END LOOP;

       x_column_names := l_column_names;
       x_numof_column_names := l_display_index;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_kff_seg_column_names',
                   p_kff_str.application_id,
                   p_kff_str.id_flex_code,
                   p_kff_str.id_flex_num,
                   p_segments_mode,
                   p_segments,
                   p_show_parent_segments);
END get_kff_seg_column_names;

--------------------------------------------------------------------------------
-- Returns KFF Segment
--------------------------------------------------------------------------------
PROCEDURE get_kff_seg
  (p_kff_str                      IN kff_str_type,
   p_application_column_name      IN fnd_id_flex_segments.application_column_name%TYPE,
   x_kff_seg                      OUT nocopy kff_seg_type)
  IS
     l_key         VARCHAR2(2000);
     l_value       fnd_plsql_cache.generic_cache_value_type;
     l_return_code VARCHAR2(1);
     l_kff_seg     kff_seg_type;
BEGIN
    --
    -- Create the key.
    --
    l_key :=  p_kff_str.application_id || '.' || p_kff_str.id_flex_code || '.' || p_kff_str.id_flex_num || '.' || p_application_column_name;
    --
    -- First check the cache.
    --
    fnd_plsql_cache.generic_1to1_get_value(g_seg_generic_1to1_controller,
                                           g_seg_generic_1to1_storage,
                                           l_key,
                                           l_value,
                                           l_return_code);
    IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
       --
       -- Entity is in the cache, populate the return value.
       --
       l_kff_seg.application_id := l_value.number_1;
       l_kff_seg.id_flex_code := l_value.varchar2_1;
       l_kff_seg.id_flex_num  := l_value.number_2;
       l_kff_seg.application_column_name := l_value.varchar2_2;
     ELSE
       --
       -- Entity is not in the cache, get it from DB.
       --
        BEGIN
           SELECT fifsg.*
             INTO l_kff_seg
             FROM fnd_id_flex_segments fifsg
            WHERE fifsg.application_id = p_kff_str.application_id
              AND fifsg.id_flex_code = p_kff_str.id_flex_code
              AND fifsg.id_flex_num = p_kff_str.id_flex_num
              AND fifsg.application_column_name = p_application_column_name;
          --
          -- Create the cache value, and populate it with values came from DB.
          --
          fnd_plsql_cache.generic_cache_new_value
            (x_value      => l_value,
             p_number_1   => l_kff_seg.application_id,
             p_varchar2_1 => l_kff_seg.id_flex_code,
             p_number_2   => l_kff_seg.id_flex_num,
             p_varchar2_2 => l_kff_seg.application_column_name);

          --
          -- Put the value in cache.
          --
          fnd_plsql_cache.generic_1to1_put_value(g_seg_generic_1to1_controller,
                                                 g_seg_generic_1to1_storage,
                                                 l_key,
                                                 l_value);
        EXCEPTION
           WHEN no_data_found THEN
               raise_no_data_found
                 ('Key Flexfield Segment',
                  'application_id', p_kff_str.application_id,
                  'id_flex_code', p_kff_str.id_flex_code,
                  'id_flex_num', p_kff_str.id_flex_num,
                  'application_column_name', p_application_column_name);
        END;
     END IF;
     --
     -- Return the value
     --
     x_kff_seg := l_kff_seg;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_kff_seg',
                   p_kff_str.application_id,
                   p_kff_str.id_flex_code,
                   p_kff_str.id_flex_num,
                   p_application_column_name);
END get_kff_seg;

--------------------------------------------------------------------------------
-- Returns KFF Segment TL
--------------------------------------------------------------------------------
PROCEDURE get_kff_seg_tl
  (p_kff_seg                      IN kff_seg_type,
   x_kff_seg_tl                   OUT nocopy kff_seg_tl_type)
  IS
     l_key         VARCHAR2(2000);
     l_value       fnd_plsql_cache.generic_cache_value_type;
     l_return_code VARCHAR2(1);
     l_kff_seg_tl  kff_seg_tl_type;
BEGIN
    --
    -- Create the key.
    --
    l_key :=  p_kff_seg.application_id || '.' || p_kff_seg.id_flex_code || '.' || p_kff_seg.id_flex_num || '.' || p_kff_seg.application_column_name || '.' || userenv('LANG');
    --
    -- First check the cache.
    --
    fnd_plsql_cache.generic_1to1_get_value(g_segt_generic_1to1_controller,
                                           g_segt_generic_1to1_storage,
                                           l_key,
                                           l_value,
                                           l_return_code);
    IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
       --
       -- Entity is in the cache, populate the return value.
       --
       l_kff_seg_tl.form_above_prompt := l_value.varchar2_1;
       l_kff_seg_tl.form_left_prompt  := l_value.varchar2_2;
     ELSE
       --
       -- Entity is not in the cache, get it from DB.
       --
       BEGIN
         SELECT fifsgtl.*
           INTO l_kff_seg_tl
           FROM fnd_id_flex_segments_tl fifsgtl
          WHERE fifsgtl.application_id = p_kff_seg.application_id
           AND fifsgtl.id_flex_code = p_kff_seg.id_flex_code
           AND fifsgtl.id_flex_num = p_kff_seg.id_flex_num
           AND fifsgtl.application_column_name = p_kff_seg.application_column_name
           AND fifsgtl.language = userenv('LANG');

         --
         -- Create the cache value, and populate it with values came from DB.
         --
         fnd_plsql_cache.generic_cache_new_value
            (x_value      => l_value,
             p_varchar2_1 => l_kff_seg_tl.form_above_prompt,
             p_varchar2_2 => l_kff_seg_tl.form_left_prompt);

         --
         -- Put the value in cache.
         --
         fnd_plsql_cache.generic_1to1_put_value(g_segt_generic_1to1_controller,
                                                g_segt_generic_1to1_storage,
                                                l_key,
                                                l_value);
       EXCEPTION
          WHEN no_data_found THEN
             raise_no_data_found
               ('Key Flexfield Segment TL',
                'application_id', p_kff_seg.application_id,
                'id_flex_code', p_kff_seg.id_flex_code,
                'id_flex_num', p_kff_seg.id_flex_num,
                'application_column_name', p_kff_seg.application_column_name,
                'language', userenv('LANG'));
       END;
   END IF;
   --
   -- Return the value
   --
   x_kff_seg_tl := l_kff_seg_tl;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_kff_seg_tl',
                   p_kff_seg.application_id,
                   p_kff_seg.id_flex_code,
                   p_kff_seg.id_flex_num,
                   p_kff_seg.application_column_name);
END get_kff_seg_tl;


--------------------------------------------------------------------------------
-- Builds a DECODE clause
--
-- if p_numof_decode_elements = 1
-- --------------------------------------------------
-- result1
--
-- if p_numof_decode_elements between 2 and 126
-- --------------------------------------------------
-- DECODE(expression,
--        search1, result1,
--        search2, result2,
--        ...
--        default);
--
--
-- if p_numof_decode_elements > 126
-- --------------------------------------------------
-- DECODE(expression,
--        search1, result1,
--        search2, result2,
--        ...
--        search126, result126,
--        DECODE(expression,
--               search127, result127,
--               search128, result128,
--               ...
--               search252, result252,
--               DECODE(expression,
--                      search253, result253,
--                      search254, result254,
--                      ...
--                      default))...));
--
--
-- EXAMPLES
--
-- SELECT:
--
--   l_decode_elements(1).search := 101;
--   l_decode_elements(1).result := SEGMENT1
--
--   l_decode_elements(2).search := 102;
--   l_decode_elements(2).result := SEGMENT2 || '-' || SEGMENT3
--
--   l_decode_elements(3).search := 103;
--   l_decode_elements(3).result := my_api.function_call(some_inputs...)
--
--
--   Decode(chart_of_accounts_id,
--          101, SEGMENT1,
--          102, SEGMENT2 || '-' || SEGMENT3,
--          103, my_api.function_call(some_inputs...),
--          NULL)
--
--
-- ORDER BY
--
--   l_decode_elements(1).search := 101;
--   l_decode_elements(1).result := SEGMENT1
--
--   l_decode_elements(2).search := 102;
--   l_decode_elements(2).result := SEGMENT2 || ',' || SEGMENT3
--
--   l_decode_elements(3).search := 103;
--   l_decode_elements(3).result := SEGMENT2
--
--
--   Decode(chart_of_accounts_id,
--          101, SEGMENT1,
--          102, SEGMENT2 || ',' || SEGMENT3,
--          103, SEGMENT2,
--          NULL)
--
--------------------------------------------------------------------------------
FUNCTION get_decode_recursive
  (p_expression                   IN VARCHAR2,
   p_numof_decode_elements        IN NUMBER,
   p_decode_elements              IN decode_elements_type,
   p_begin_index                  IN NUMBER,
   p_default                      IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_end_index     NUMBER;
     l_decode_clause VARCHAR2(32000);
BEGIN
   --
   -- Compute the end index
   --
   IF (p_begin_index + max_numof_decode_elements - 1 < p_numof_decode_elements) THEN
      l_end_index := p_begin_index + max_numof_decode_elements - 1;
    ELSE
      l_end_index := p_numof_decode_elements;
   END IF;

   --
   -- Begin DECODE
   --
   l_decode_clause := 'DECODE(' || p_expression || ', ';

   FOR i IN p_begin_index .. l_end_index LOOP
      --
      -- Append <search>, <result>,
      --
      l_decode_clause := l_decode_clause ||
        p_decode_elements(i).search || ', ' ||
        p_decode_elements(i).result || ', ';
   END LOOP;

   --
   -- If there are more elements then do a recursive call
   --
   IF (l_end_index < p_numof_decode_elements) THEN
      --
      -- Append nested DECODE
      --
      l_decode_clause := l_decode_clause ||
        get_decode_recursive(p_expression,
                             p_numof_decode_elements,
                             p_decode_elements,
                             l_end_index + 1,
                             p_default);
    ELSE
      --
      -- Append <default>
      --
      l_decode_clause := l_decode_clause || p_default;
   END IF;

   --
   -- End DECODE
   --
   l_decode_clause := l_decode_clause || ')';

   RETURN (l_decode_clause);

EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_decode_recursive',
                   p_expression,
                   p_numof_decode_elements,
                   p_begin_index,
                   p_default);
END get_decode_recursive;

PROCEDURE get_decode_clause
  (p_expression                   IN VARCHAR2,
   p_numof_decode_elements        IN NUMBER,
   p_decode_elements              IN decode_elements_type,
   p_default                      IN VARCHAR2,
   x_decode_clause                OUT nocopy VARCHAR2)
  IS
BEGIN
   --
   -- Check to see if we need a decode statement.
   --
   IF (p_numof_decode_elements = 1) THEN
      --
      -- Only one element no decode needed
      --
      x_decode_clause := p_decode_elements(1).result;

    ELSE
      --
      -- Call the recursive API
      --
      x_decode_clause := get_decode_recursive(p_expression,
                                              p_numof_decode_elements,
                                              p_decode_elements,
                                              1,
                                              p_default);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_decode_clause',
                   p_expression,
                   p_numof_decode_elements,
                   p_default);
END get_decode_clause;

--------------------------------------------------------------------------------
-- Concatenates Column Names
--
-- alias_prefix || column1 || <delimiter> || alias_prefix || column2 ...
--
--------------------------------------------------------------------------------
PROCEDURE get_concat_column_names_clause
  (p_alias_prefix                 IN VARCHAR2,
   p_numof_column_names           IN VARCHAR2,
   p_column_names                 IN varchar2_30_array_type,
   p_delimiter                    IN VARCHAR2,
   x_concat_column_names_clause   OUT nocopy VARCHAR2)
  IS
     l_concat_column_names_clause VARCHAR2(32000);
BEGIN
   l_concat_column_names_clause := NULL;
   FOR i IN 1 .. p_numof_column_names LOOP
      --
      -- If there are more than 1 column names then append delimiter
      --
      IF (i > 1) THEN
         l_concat_column_names_clause := l_concat_column_names_clause ||
           p_delimiter;
      END IF;

      --
      -- Append <prefix || column>
      --
      l_concat_column_names_clause := l_concat_column_names_clause ||
        p_alias_prefix || p_column_names(i);
   END LOOP;

   x_concat_column_names_clause := l_concat_column_names_clause;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_concat_column_names_clause',
                   p_alias_prefix,
                   p_numof_column_names,
                   p_delimiter);
END get_concat_column_names_clause;


--
-- Public APIs
--

-- ======================================================================
PROCEDURE set_debug_mode
  (p_debug_mode                   IN VARCHAR2)
  IS
BEGIN
   validate_argument(arg_debug_mode, p_debug_mode);

   IF (p_debug_mode = debug_mode_off) THEN
      g_debug_enabled := FALSE;

    ELSIF (p_debug_mode = debug_mode_on) THEN
      g_debug_enabled := TRUE;

   END IF;

   init_debug();
EXCEPTION
   WHEN OTHERS THEN
      raise_others('set_debug_mode',
                   p_debug_mode);
END set_debug_mode;

-- ======================================================================
PROCEDURE get_debug
  (x_debug                        OUT nocopy VARCHAR2)
  IS
BEGIN
   x_debug := g_debug;

   init_debug();
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_debug');
END get_debug;

-- ======================================================================
PROCEDURE kff_flexfield_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2)
  IS
BEGIN
   x_metadata := 'For future use, not implemented yet.';
END kff_flexfield_metadata;

-- ======================================================================
PROCEDURE kff_structure_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2)
  IS
BEGIN
   x_metadata := 'For future use, not implemented yet.';
END kff_structure_metadata;

-- ======================================================================
PROCEDURE kff_segment_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_application_column_name      IN fnd_id_flex_segments.application_column_name%TYPE,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2)
  IS
BEGIN
   x_metadata := 'For future use, not implemented yet.';
END kff_segment_metadata;

-- ======================================================================
PROCEDURE kff_segments_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_segments                     IN VARCHAR2,
   p_show_parent_segments         IN VARCHAR2,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2)
  IS
     l_kff_flx            kff_flx_type;
     l_kff_str            kff_str_type;
     l_kff_seg            kff_seg_type;
     l_kff_seg_tl         kff_seg_tl_type;

     l_column_names       varchar2_30_array_type;
     l_numof_column_names NUMBER;

     l_metadata           VARCHAR2(32000);
BEGIN
   --
   -- Validate Input Arguments
   --
   validate_argument(arg_lexical_name, p_lexical_name);
   validate_argument(arg_segments, p_segments);
   validate_argument(arg_show_parent_segments, p_show_parent_segments);
   validate_argument(arg_metadata_type, p_metadata_type);

   --
   -- Get the Key Flexfield
   --
   get_kff_flx(p_application_short_name => p_application_short_name,
               p_id_flex_code           => p_id_flex_code,
               x_kff_flx                => l_kff_flx);

   --
   -- Get the Structure
   --
   get_kff_str(p_kff_flx     => l_kff_flx,
               p_id_flex_num => p_id_flex_num,
               x_kff_str     => l_kff_str);

   --
   -- Get the Column Names
   --
   get_kff_seg_column_names(p_kff_str              => l_kff_str,
                            p_segments_mode        => segments_mode_displayed_only,
                            p_segments             => p_segments,
                            p_show_parent_segments => p_show_parent_segments,
                            x_numof_column_names   => l_numof_column_names,
                            x_column_names         => l_column_names);

   --
   -- Loop Through Column Names
   --
   l_metadata := NULL;
   FOR i IN 1 .. l_numof_column_names LOOP
      --
      -- Use delimiter to concatenate
      --
      IF (i > 1) THEN
         l_metadata := l_metadata || l_kff_str.concatenated_segment_delimiter;
      END IF;

      --
      -- Get the Segment
      --
      get_kff_seg(p_kff_str                 => l_kff_str,
                  p_application_column_name => l_column_names(i),
                  x_kff_seg                 => l_kff_seg);

      --
      -- Get the Segment TL
      --
      get_kff_seg_tl(p_kff_seg    => l_kff_seg,
                     x_kff_seg_tl => l_kff_seg_tl);

      --
      -- Build the metadata
      --
      IF (p_metadata_type = metadata_segments_above_prompt) THEN
         l_metadata := l_metadata || l_kff_seg_tl.form_above_prompt;

       ELSIF (p_metadata_type = metadata_segments_left_prompt) THEN
         l_metadata := l_metadata || l_kff_seg_tl.form_left_prompt;

      END IF;
   END LOOP;

   x_metadata := l_metadata;

EXCEPTION
   WHEN OTHERS THEN
      raise_others('kff_segments_metadata',
                   p_lexical_name,
                   p_application_short_name,
                   p_id_flex_code,
                   p_id_flex_num,
                   p_segments,
                   p_show_parent_segments,
                   p_metadata_type);
END kff_segments_metadata;

-- ======================================================================
--  Function to return the all enabled segment mode for use of
--    p_segment_mode parameter of process_kff_combination_1()
-- ======================================================================

FUNCTION get_all_segment_mode
 RETURN VARCHAR2
 IS
 BEGIN
       RETURN segments_mode_all_enabled;
END get_all_segment_mode;

-- ======================================================================
--  KFF Combination Process API, version #1
-- ======================================================================
FUNCTION process_kff_combination_1
  (p_lexical_name           IN VARCHAR2,
   p_application_short_name IN fnd_application.application_short_name%TYPE,
   p_id_flex_code           IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num            IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_data_set               IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_ccid                   IN NUMBER,
   p_segments               IN VARCHAR2,
   p_show_parent_segments   IN VARCHAR2,
   p_output_type            IN VARCHAR2,
   p_segment_mode           IN VARCHAR2 DEFAULT segments_mode_displayed_only)
  RETURN VARCHAR2
  IS
     l_return             VARCHAR2(32000);
     l_is_ccid_valid      BOOLEAN;
     l_is_secured         BOOLEAN;
     l_kff_flx            kff_flx_type;
     l_kff_str            kff_str_type;

     l_column_names       varchar2_30_array_type;
     l_numof_column_names NUMBER;

     l_segment_numbers    number_array_type;
     l_segment_count      NUMBER;

     l_values             fnd_flex_server1.stringarray;

     l_flex_values        fnd_flex_server1.stringarray;
     n_segments           NUMBER;

     l_key         VARCHAR2(2000);
     l_value       fnd_plsql_cache.generic_cache_value_type;
     l_return_code VARCHAR2(1);
BEGIN
   --
   --  For performance reasons, this API assumes that all of the input
   --  arguments are valid.
   --

   --
   -- Create the Key.
   --
   l_key := p_application_short_name||'.'||p_id_flex_code||'.'||p_id_flex_num||'.'||p_data_set||'.'||p_ccid||'.'||p_segments||'.'||p_show_parent_segments||'.'||p_output_type||'.'||p_segment_mode;

   --
   -- First check the cache.
   --
   fnd_plsql_cache.generic_1to1_get_value(prcomb_generic_1to1_controller,
                                          prcomb_generic_1to1_storage,
                                          l_key,
                                          l_value,
                                          l_return_code);

   IF (l_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      --
      -- Entity is in the cache, populate the return value.
      --
      l_return := l_value.varchar2_1;
      GOTO goto_return;

   ELSE
      --
      -- Entity is not in the cache, get it from DB.
      --

      --
      -- Validate the CCID
      --
      l_is_ccid_valid := fnd_flex_keyval.validate_ccid
        (appl_short_name       => p_application_short_name,
         key_flex_code         => p_id_flex_code,
         structure_number      => p_id_flex_num,
         combination_id        => p_ccid,
         displayable           => 'ALL',
         data_set              => p_data_set,
         vrule                 => NULL,
         security              => 'CHECK',
         get_columns           => NULL,
         resp_appl_id          => fnd_global.resp_appl_id,
         resp_id               => fnd_global.resp_id,
         user_id               => fnd_global.user_id,
         select_comb_from_view => NULL);

      IF (NOT l_is_ccid_valid) THEN
         l_return := fnd_flex_keyval.error_message();
         GOTO goto_cache_and_return;
      END IF;

      --
      -- At this point CCID is valid
      --


      --
      -- Handle single value output types first.
      --

      IF (p_output_type = output_type_security) THEN
         l_is_secured := fnd_flex_keyval.is_secured();

         IF (l_is_secured) THEN
            l_return := 'Y';
         ELSE
            l_return := 'N';
         END IF;
         GOTO goto_cache_and_return;
      END IF;


      --
      -- At this point we have multi value output type.
      --

      --
      -- !!! Performance Problem : This section should be improved.
      --

      --
      -- Get the Key Flexfield
      --
      get_kff_flx(p_application_short_name => p_application_short_name,
                  p_id_flex_code           => p_id_flex_code,
                  x_kff_flx                => l_kff_flx);

      --
      -- Get the Structure
      --
      get_kff_str(p_kff_flx     => l_kff_flx,
                  p_id_flex_num => p_id_flex_num,
                  x_kff_str     => l_kff_str);

      --
      -- Get the Column Names
      --

      get_kff_seg_column_names(p_kff_str              => l_kff_str,
                               p_segments_mode        => p_segment_mode,
                               p_segments             => p_segments,
                               p_show_parent_segments => p_show_parent_segments,
                               x_numof_column_names   => l_numof_column_names,
                               x_column_names         => l_column_names);


      /* commented and changed for Bug17332083
      get_kff_seg_column_names(p_kff_str              => l_kff_str,
                               p_segments_mode        => segments_mode_displayed_only,
                               p_segments             => p_segments,
                               p_show_parent_segments => p_show_parent_segments,
                               x_numof_column_names   => l_numof_column_names,
                               x_column_names         => l_column_names);  */


      IF (l_numof_column_names = 0)
      THEN
         l_return := NULL;
         GOTO goto_cache_and_return;
      END IF;
      --
      -- Convert Column Names to Segment Numbers
      --
      l_segment_count := fnd_flex_keyval.segment_count();

      IF (p_output_type = output_type_padded_value) THEN
         --
         -- Get Concatenated Segments from the code combinations table in PADDED mode
         --
         l_return := fnd_flex_server.get_kfv_concat_segs_by_ccid(
                                        p_concat_mode    => 'PADDED',
                                        p_application_id => l_kff_flx.application_id,
                                        p_id_flex_code   => p_id_flex_code,
                                        p_id_flex_num    => p_id_flex_num,
                                        p_ccid           => p_ccid,
                                        p_data_set       => p_data_set);
         IF (p_segments = 'ALL') THEN
            GOTO goto_cache_and_return;
         ELSE
            n_segments := fnd_flex_server1.to_stringarray(l_return,
	                                    fnd_flex_keyval.segment_delimiter,
		                            l_flex_values);
         END IF;
      END IF;

      <<loop_column_names>>
      FOR i IN 1 .. l_numof_column_names LOOP

         <<loop_segment_numbers>>
         FOR j IN 1 .. l_segment_count LOOP
            IF (fnd_flex_keyval.segment_column_name(j) = l_column_names(i)) THEN
               l_segment_numbers(i) := j;
               EXIT loop_segment_numbers;
            END IF;
         END LOOP;
      END LOOP;


      --
      -- Now, get the values
      --
      FOR i IN 1 .. l_numof_column_names LOOP

         IF (p_output_type = output_type_value) THEN
            l_values(i) := fnd_flex_keyval.segment_value(l_segment_numbers(i));

         ELSIF (p_output_type = output_type_padded_value) THEN
            l_values(i) := l_flex_values(l_segment_numbers(i));

         ELSIF (p_output_type = output_type_description) THEN
            l_values(i) := Substr(fnd_flex_keyval.segment_description(l_segment_numbers(i)), 1, fnd_flex_keyval.segment_concat_desc_length(l_segment_numbers(i)));

         ELSIF (p_output_type = output_type_full_description) THEN
            l_values(i) := fnd_flex_keyval.segment_description(l_segment_numbers(i));
         END IF;
      END LOOP;

      --
      -- Now concatenate the values. (do not forget potential ESCAPING logic.)
      --
      l_return := fnd_flex_server1.from_stringarray
        (l_numof_column_names,
         l_values,
         fnd_flex_keyval.segment_delimiter);
   END IF;

   <<goto_cache_and_return>>
      --
      -- Create the cache value, and populate it with values came from DB.
      --
      fnd_plsql_cache.generic_cache_new_value
        (x_value      => l_value,
         p_varchar2_1 => l_return);

      --
      -- Put the value in cache.
      --
      fnd_plsql_cache.generic_1to1_put_value(prcomb_generic_1to1_controller,
                                             prcomb_generic_1to1_storage,
                                             l_key,
                                             l_value);
      RETURN (l_return);

   <<goto_return>>
      RETURN (l_return);
EXCEPTION
   WHEN OTHERS THEN
      --
      -- This API cannot raise exception. If it does, database will stop
      -- executing the SELECT statement.
      -- Return the error message as output.
      --
      BEGIN
         raise_others('process_kff_combination_1',
                      p_lexical_name,
                      p_application_short_name,
                      p_id_flex_code,
                      p_id_flex_num,
                      p_data_set,
                      p_segments,
                      p_show_parent_segments,
                      p_output_type);
      EXCEPTION
         WHEN OTHERS THEN
            --
            -- For safety, return the first 2000 characters.
            --
            RETURN (Substr(Sqlerrm, 1, 2000));
      END;
END process_kff_combination_1;


-- ======================================================================
PROCEDURE kff_select
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE DEFAULT 101,
   p_multiple_id_flex_num         IN VARCHAR2 DEFAULT 'N',
   p_code_combination_table_alias IN VARCHAR2 DEFAULT NULL,
   p_segments                     IN VARCHAR2 DEFAULT 'ALL',
   p_show_parent_segments         IN VARCHAR2 DEFAULT 'Y',
   p_output_type                  IN VARCHAR2,
   x_select_expression            OUT nocopy VARCHAR2)
  IS
     l_kff_flx               kff_flx_type;
     l_alias_prefix          VARCHAR2(100);
     l_structure_column_name VARCHAR2(100);
     l_data_set_column_name  VARCHAR2(100);
BEGIN
   --
   -- Validate Input Arguments
   --
   validate_argument(arg_lexical_name, p_lexical_name);
   validate_argument(arg_multiple_id_flex_num, p_multiple_id_flex_num);
   validate_argument(arg_cct_alias, p_code_combination_table_alias);
   validate_argument(arg_segments, p_segments);
   validate_argument(arg_show_parent_segments, p_show_parent_segments);
   validate_argument(arg_output_type, p_output_type);
   cross_validate_arguments(arg_multiple_id_flex_num, p_multiple_id_flex_num,
                            arg_id_flex_num, p_id_flex_num);

   --
   -- Get the Key Flexfield
   --
   get_kff_flx(p_application_short_name => p_application_short_name,
               p_id_flex_code           => p_id_flex_code,
               x_kff_flx                => l_kff_flx);

   --
   -- Compute the Alias Prefix
   --
   IF (p_code_combination_table_alias IS NULL) THEN
      l_alias_prefix := NULL;
    ELSE
      l_alias_prefix := p_code_combination_table_alias || '.';
   END IF;

   --
   -- Build the SELECT clause
   --
   -- Please see $fnd/doc/flex/kff_multi_structure.txt for more information.
   --
   -- Multiple Structure KFFs:
   --    - set_defining_column_name is not null
   --    - DATA_SET argument is not used
   --
   --    fnd_flex_xml_publisher_apis.process_kff_combination_1(
   --       'SELECT_LEXICAL', 'SQLGL', 'GL#',
   --       cct.CHART_OF_ACCOUNTS_ID, NULL,
   --       cct.CODE_COMBINATION_ID, 'ALL', 'Y', 'VALUE')
   --
   -- Single Structure KFFs:
   --    - set_defining_column_name is null
   --    - Structure Number is always 101
   --    - DATA_SET argument is not used
   --
   --    fnd_flex_xml_publisher_apis.process_kff_combination_1(
   --       'SELECT_LEXICAL', 'OFA', 'CAT#',
   --       101, NULL,
   --       cct.CATEGORY_ID, 'ALL', 'Y', 'VALUE')
   --
   --
   -- Special Single Structure KFFs: (401/MDSP,MICG,MSTK,MTLL,SERV)
   --    - set_defining_column_name may or may not be null
   --    - Structure Number is always 101
   --    - DATA_SET argument is used
   --
   --    fnd_flex_xml_publisher_apis.process_kff_combination_1(
   --       'SELECT_LEXICAL', 'INV', 'MSTK',
   --       101, cct.ORGANIZATION_ID,
   --       cct.INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE')
   --
   IF (l_kff_flx.set_defining_column_name IS NULL) THEN
      l_structure_column_name := '101';
    ELSE
      l_structure_column_name := l_alias_prefix || l_kff_flx.set_defining_column_name;
   END IF;

   IF ((p_application_short_name = 'INV' AND p_id_flex_code = 'MDSP') OR
       (p_application_short_name = 'INV' AND p_id_flex_code = 'MICG') OR
       (p_application_short_name = 'INV' AND p_id_flex_code = 'MSTK') OR
       (p_application_short_name = 'INV' AND p_id_flex_code = 'MTLL') OR
       (p_application_short_name = 'INV' AND p_id_flex_code = 'SERV')) THEN
      l_structure_column_name := '101';
      l_data_set_column_name := l_alias_prefix || l_kff_flx.set_defining_column_name;
    ELSE
      l_data_set_column_name := 'NULL';
   END IF;

   x_select_expression := 'fnd_flex_xml_publisher_apis.process_kff_combination_1(' ||
     '''' || p_lexical_name || ''', ' ||
     '''' || p_application_short_name || ''', ' ||
     '''' || p_id_flex_code || ''', ' ||
     l_structure_column_name || ', ' ||
     l_data_set_column_name || ', ' ||
     l_alias_prefix || l_kff_flx.unique_id_column_name || ', ' ||
     '''' || p_segments || ''', ' ||
     '''' || p_show_parent_segments || ''', ' ||
     '''' || p_output_type || ''')';

EXCEPTION
   WHEN OTHERS THEN
      raise_others('kff_select',
                   p_lexical_name,
                   p_application_short_name,
                   p_id_flex_code,
                   p_id_flex_num,
                   p_multiple_id_flex_num,
                   p_code_combination_table_alias,
                   p_segments,
                   p_show_parent_segments,
                   p_output_type);
END kff_select;

-- ======================================================================
PROCEDURE kff_where
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_code_combination_table_alias IN VARCHAR2 DEFAULT NULL,
   p_segments                     IN VARCHAR2 DEFAULT 'ALL',
   p_operator                     IN VARCHAR2,
   p_operand1                     IN VARCHAR2,
   p_operand2                     IN VARCHAR2 DEFAULT NULL,
   x_where_expression             OUT nocopy VARCHAR2,
   x_numof_bind_variables         OUT nocopy NUMBER,
   x_bind_variables               OUT nocopy bind_variables)
  IS
     l_kff_flx                    kff_flx_type;
     l_kff_str                    kff_str_type;

     l_column_names               varchar2_30_array_type;
     l_numof_column_names         NUMBER;

     l_where_expression           VARCHAR2(32000);

     l_bind_variables             bind_variables;
     l_numof_bind_variables       NUMBER;

     l_operand1_array             fnd_flex_server1.StringArray;
     l_operand2_array             fnd_flex_server1.StringArray;

     l_array_index                PLS_INTEGER;
     l_numof_segs                 NUMBER;
     null_ind1                    BOOLEAN;
     null_ind2                    BOOLEAN;
     tmpcount                     number;

     PROCEDURE assign_bind_values
       (p_bind_variable_num    IN   NUMBER,
        p_bind_value           IN   VARCHAR2,
        p_column_name          IN   VARCHAR2,
        p_bind_variable        OUT  nocopy bind_variable)
       IS
          l_datatype VARCHAR2(1);
          l_format_type VARCHAR(1);
          l_maximum_size NUMBER;
          l_flex_value_set_id NUMBER;
          l_format_mask VARCHAR2(30);
     BEGIN
        SELECT fnd_columns.column_type
          INTO l_datatype
          FROM fnd_columns,fnd_tables,fnd_id_flexs
         WHERE fnd_columns.column_name = p_column_name
           AND fnd_columns.table_id = fnd_tables.table_id
           AND fnd_columns.application_id = fnd_tables.application_id
           AND fnd_tables.table_name = fnd_id_flexs.application_table_name
           AND fnd_tables.application_id = fnd_id_flexs.table_application_id
           AND fnd_id_flexs.id_flex_code = l_kff_flx.id_flex_code
           AND fnd_id_flexs.application_id =  l_kff_flx.application_id;

        p_bind_variable.name := p_lexical_name || p_bind_variable_num;

        SELECT flex_value_set_id
          INTO l_flex_value_set_id
          FROM fnd_id_flex_segments fifs
          WHERE fifs.application_id = l_kff_flx.application_id
          AND fifs.id_flex_code = l_kff_flx.id_flex_code
          AND fifs.id_flex_num = p_id_flex_num
          AND fifs.application_column_name = p_column_name;

        IF l_datatype = 'N' THEN
          p_bind_variable.data_type := bind_data_type_number;
          p_bind_variable.number_value := TO_NUMBER(p_bind_value);
          p_bind_variable.canonical_value := fnd_number.number_to_canonical(p_bind_value);

        ELSIF (l_datatype = 'D' AND l_flex_value_set_id is NOT NULL) THEN
          SELECT format_type, maximum_size
            INTO l_format_type, l_maximum_size
            FROM fnd_flex_value_sets ffvs
            WHERE ffvs.flex_value_set_id = l_flex_value_set_id;

            IF (l_format_type = 'D') THEN -- Date type

              IF (l_maximum_size = 9 ) THEN
                l_format_mask := 'DD-MON-RR';
              ELSIF (l_maximum_size = 11) THEN
                l_format_mask := 'DD-MON-YYYY';
              END IF;

            ELSIF (l_format_type = 'T') THEN -- DateTime type

              IF (l_maximum_size = 15) THEN
                l_format_mask := 'DD-MON-RR HH24:MI';
              ELSIF (l_maximum_size = 17) THEN
                l_format_mask := 'DD-MON-YYYY HH24:MI';
              ELSIF (l_maximum_size = 18) THEN
                l_format_mask := 'DD-MON-RR HH24:MI:SS';
              ELSIF (l_maximum_size = 20) THEN
                l_format_mask := 'DD-MON-YYYY HH24:MI:SS';
              END IF;

            ELSE                          -- Std. Date/DateTime type
              l_format_mask := 'YYYY/MM/DD HH24:MI:SS';
            END IF;

            p_bind_variable.data_type := bind_data_type_date;
            p_bind_variable.date_value      := TO_DATE(p_bind_value, l_format_mask);
            p_bind_variable.canonical_value := fnd_date.string_to_canonical(p_bind_value, l_format_type);

          ELSE
            p_bind_variable.data_type := bind_data_type_varchar2;
            p_bind_variable.varchar2_value := p_bind_value;
            p_bind_variable.canonical_value := p_bind_value;

        END IF;               -- END IF of l_datatype = 'N'

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          raise_no_data_found('Column','column_name',p_column_name);
     END assign_bind_values;

BEGIN
   --
   -- Validate Input Arguments
   --
   validate_argument(arg_lexical_name, p_lexical_name);
   validate_argument(arg_cct_alias, p_code_combination_table_alias);
   validate_argument(arg_segments, p_segments);
   validate_argument(arg_operator, p_operator);

   if ((p_operator <> operator_between and p_operand1 is null) or
       (p_operator = operator_between and p_operand1 is null and p_operand2 is null))
   then
      x_where_expression := '1 = 1';
      x_numof_bind_variables := 0;
      return;
   end if;
   --
   -- Get the Key Flexfield
   --
   get_kff_flx(p_application_short_name => p_application_short_name,
               p_id_flex_code           => p_id_flex_code,
               x_kff_flx                => l_kff_flx);

   --
   -- Get the Structure
   --
   get_kff_str(p_kff_flx     => l_kff_flx,
               p_id_flex_num => p_id_flex_num,
               x_kff_str     => l_kff_str);

   --
   -- Get the Column Names
   --
   get_kff_seg_column_names(p_kff_str              => l_kff_str,
                            p_segments_mode        => segments_mode_all_enabled,
                            p_segments             => p_segments,
                            p_show_parent_segments => 'Y',
                            x_numof_column_names   => l_numof_column_names,
                            x_column_names         => l_column_names);

   --
   -- Split the operand values by the segment separators
   --

   -- BUG 22063362
   -- Directly splitting was causing issue for the case when there is a single segment and the value in the
   -- segment also has the segment delimiter as a value.
   -- The escape mechanism is only used for more than one segment case. Hence fixing this part of the code
   -- to split only when the number of segments are more than 1 else to return the value as it is.

   if (l_numof_column_names >1)  then

     -- for first operand
     l_numof_segs := fnd_flex_server1.to_stringarray(p_operand1,l_kff_str.concatenated_segment_delimiter,l_operand1_array);

     -- for second operand
     l_numof_segs := fnd_flex_server1.to_stringarray(p_operand2,l_kff_str.concatenated_segment_delimiter,l_operand2_array);

   else

     l_numof_segs := 1;
     l_operand1_array(1) := p_operand1;
     l_operand2_array(1) := p_operand2;

   end if;

   -- BUG 13027090
   -- When the segment values are null, p_operand1 and or p_operand2 have "....."
   -- dots are not null so the below if stmnt did not evalute correctly.
   -- So we have parse the segments to see if they are null.
   ---------
   FOR l_array_index IN 1..l_numof_column_names LOOP
       IF(l_operand1_array(l_array_index) IS NULL) THEN
          null_ind1 := TRUE;
       ELSE
          null_ind1 := FALSE;
          EXIT;
       END IF;
   END LOOP;

   IF p_operator = operator_between THEN
      FOR l_array_index IN 1..l_numof_column_names LOOP
       IF(l_operand2_array(l_array_index) IS NULL) THEN
          null_ind2 := TRUE;
       ELSE
          null_ind2 := FALSE;
          EXIT;
       END IF;
      END LOOP;
   END IF;
   ---------

   if ((p_operator <> operator_between and (p_operand1 is null or null_ind1)) or
       (p_operator = operator_between and ((p_operand1 is null and p_operand2 is null) or
        (null_ind1 and null_ind2))))
   then
      x_where_expression := '1 = 1';
      x_numof_bind_variables := 0;
      return;
   end if;

   l_where_expression := NULL;
   l_numof_bind_variables := 0;

   -- If the number of operands does not equals the number of segments then raise exception
   IF (l_numof_column_names > l_operand1_array.COUNT) OR
     (l_numof_column_names > l_operand2_array.COUNT AND
      p_operator = operator_between)  THEN

      FOR l_array_index IN (l_operand1_array.COUNT + 1)..l_numof_column_names LOOP
         l_operand1_array(l_array_index) := NULL;
      END LOOP;

      IF p_operator = operator_between THEN
         FOR l_array_index IN (l_operand2_array.COUNT + 1)..l_numof_column_names LOOP
            l_operand2_array(l_array_index) := NULL;
         END LOOP;
      END IF;
   END IF;

   /* Bug 5140265. Use l_numof_column_names and not l_numof_segs. */
   FOR i IN 1 .. l_numof_column_names LOOP
    -- Bug 7026760 Added check to not build where clause restrictions
    -- on segments with null bind values.
    IF ((l_operand1_array(i) is not NULL AND p_operator <> operator_between) OR
        (l_operand1_array(i) is not NULL AND
         l_operand2_array(i) is not NULL AND
         p_operator = operator_between))
    THEN

      IF l_where_expression IS NOT NULL THEN
         l_where_expression := l_where_expression || ' AND ';
      END IF;

      IF p_code_combination_table_alias IS NOT NULL THEN
         l_where_expression := l_where_expression || p_code_combination_table_alias || '.' || l_column_names(i);
      ELSE
         l_where_expression := l_where_expression || ' ' || l_column_names(i);
      END IF;

      IF p_operator <> operator_between THEN
         l_numof_bind_variables := l_numof_bind_variables + 1;
         l_where_expression := l_where_expression || ' ' ||
           UPPER(p_operator) || ' :' || p_lexical_name || l_numof_bind_variables;

         assign_bind_values(l_numof_bind_variables,l_operand1_array(i),l_column_names(i),l_bind_variables(l_numof_bind_variables));
       ELSE
         IF (l_operand1_array(i) = l_operand2_array(i))
         THEN
            l_numof_bind_variables := l_numof_bind_variables + 1;
            l_where_expression := l_where_expression || ' ' ||
              UPPER('=') || ' :' || p_lexical_name || l_numof_bind_variables;

            assign_bind_values(l_numof_bind_variables,l_operand1_array(i),l_column_names(i),l_bind_variables(l_numof_bind_variables));

         ELSE
           l_numof_bind_variables := l_numof_bind_variables + 1;
           l_where_expression := l_where_expression || ' ' || UPPER(p_operator)
           || ' :' || p_lexical_name || l_numof_bind_variables;
           assign_bind_values(l_numof_bind_variables,l_operand1_array(i),l_column_names(i),l_bind_variables(l_numof_bind_variables));

           l_numof_bind_variables := l_numof_bind_variables + 1;

           l_where_expression := l_where_expression || ' AND :' || p_lexical_name || l_numof_bind_variables;

           assign_bind_values(l_numof_bind_variables,l_operand2_array(i),l_column_names(i),l_bind_variables(l_numof_bind_variables));
         END IF;
      END IF;
    END IF;
   END LOOP;

   --
   -- Assign the local variables to OUT variables
   --
   x_where_expression := l_where_expression;
   x_bind_variables := l_bind_variables;
   x_numof_bind_variables := l_numof_bind_variables;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('kff_where',
                   p_lexical_name,
                   p_application_short_name,
                   p_id_flex_code,
                   p_id_flex_num,
                   p_code_combination_table_alias,
                   p_segments,
                   p_operator,
                   p_operand1,
                   p_operand2);
END kff_where;

-- ======================================================================
PROCEDURE kff_order_by
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE DEFAULT 101,
   p_multiple_id_flex_num         IN VARCHAR2 DEFAULT 'N',
   p_code_combination_table_alias IN VARCHAR2 DEFAULT NULL,
   p_segments                     IN VARCHAR2 DEFAULT 'ALL',
   p_show_parent_segments         IN VARCHAR2 DEFAULT 'Y',
   x_order_by_expression          OUT nocopy VARCHAR2)
  IS
     l_alias_prefix               VARCHAR2(100);

     l_kff_flx                    kff_flx_type;
     l_kff_str                    kff_str_type;

     l_structure_numbers          number_array_type;
     l_numof_structures           NUMBER;

     l_column_names               varchar2_30_array_type;
     l_numof_column_names         NUMBER;

     l_decode_elements            decode_elements_type;
     l_numof_decode_elements      NUMBER;

     l_concat_column_names_clause VARCHAR2(32000);
BEGIN
   --
   -- Validate Input Arguments
   --
   validate_argument(arg_lexical_name, p_lexical_name);
   validate_argument(arg_multiple_id_flex_num, p_multiple_id_flex_num);
   validate_argument(arg_cct_alias, p_code_combination_table_alias);
   validate_argument(arg_segments, p_segments);
   validate_argument(arg_show_parent_segments, p_show_parent_segments);
   cross_validate_arguments(arg_multiple_id_flex_num, p_multiple_id_flex_num,
                            arg_id_flex_num, p_id_flex_num);
   --
   -- Compute the Alias Prefix
   --
   IF (p_code_combination_table_alias IS NULL) THEN
      l_alias_prefix := NULL;
    ELSE
      l_alias_prefix := p_code_combination_table_alias || '.';
   END IF;

   --
   -- Get the Key Flexfield
   --
   get_kff_flx(p_application_short_name => p_application_short_name,
               p_id_flex_code           => p_id_flex_code,
               x_kff_flx                => l_kff_flx);

   --
   -- Get the structure numbers
   --
   IF (p_multiple_id_flex_num = 'N') THEN
      --
      -- Single Structure
      --
      l_numof_structures := 1;
      l_structure_numbers(1) := p_id_flex_num;

    ELSIF (p_multiple_id_flex_num = 'Y') THEN
      --
      -- Multiple Structures
      --
      get_kff_str_numbers(p_kff_flx            => l_kff_flx,
                          x_numof_structures   => l_numof_structures,
                          x_structure_numbers  => l_structure_numbers);
   END IF;

   --
   -- Process the structures and load results into decode elements array
   -- The .search will contain the struct number
   -- The .result will contain the orderby column names
   --
   l_numof_decode_elements := l_numof_structures;
   FOR i IN 1 .. l_numof_decode_elements LOOP

      --
      -- Get the Structure
      --
      get_kff_str(p_kff_flx     => l_kff_flx,
                  p_id_flex_num => l_structure_numbers(i),
                  x_kff_str     => l_kff_str);

      --
      -- Get the Segment Column Names
      --
      get_kff_seg_column_names
        (p_kff_str              => l_kff_str,
         p_segments_mode        => segments_mode_displayed_only,
         p_segments             => p_segments,
         p_show_parent_segments => p_show_parent_segments,
         x_numof_column_names   => l_numof_column_names,
         x_column_names         => l_column_names);

      --
      -- Assign the structure numbers to .search
      -- i.e. l_decode_elements(i).search := 101
      --
      l_decode_elements(i).search := l_structure_numbers(i);

      --
      -- Concatenate the columns
      --
      get_concat_column_names_clause
        (p_alias_prefix               => l_alias_prefix,
         p_numof_column_names         => l_numof_column_names,
         p_column_names               => l_column_names,
         p_delimiter                  => ' || '','' || ',
         x_concat_column_names_clause => l_concat_column_names_clause);

      --
      -- Assign the concatenated column names to .result
      -- i.e. l_decode_elements(i).result := SEGMENT1 || ', ' || SEGMENT2
      --
      l_decode_elements(i).result := l_concat_column_names_clause;
   END LOOP;

   --
   -- Build final order by expression
   --
   get_decode_clause
     (p_expression            => l_alias_prefix || l_kff_flx.set_defining_column_name,
      p_numof_decode_elements => l_numof_decode_elements,
      p_decode_elements       => l_decode_elements,
      p_default               => 'NULL',
      x_decode_clause         => x_order_by_expression);

EXCEPTION
   WHEN OTHERS THEN
      raise_others('kff_order_by',
                   p_lexical_name,
                   p_application_short_name,
                   p_id_flex_code,
                   p_id_flex_num,
                   p_multiple_id_flex_num,
                   p_code_combination_table_alias,
                   p_segments,
                   p_show_parent_segments);
END kff_order_by;


BEGIN
   --
   --
   -- Qualifier Segment Number Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('Ql.Segnum Generic 1to1 Cache',
                                     g_snum_generic_1to1_controller,
                                     g_snum_generic_1to1_storage);
   -- Application Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('Application Generic 1to1 Cache',
                                     g_app_generic_1to1_controller,
                                     g_app_generic_1to1_storage);
   --
   -- Key Flexfield Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('KFF Generic 1to1 Cache',
                                     g_kflx_generic_1to1_controller,
                                     g_kflx_generic_1to1_storage);
   --
   -- Key Flexfield Structure Numbers Generic 1toM Cache
   --
   fnd_plsql_cache.generic_1tom_init('KFF Str No. Generic 1toM Cache',
                                     g_stno_generic_1tom_controller,
                                     g_stno_generic_1tom_storage);

   --
   -- Key Flexfield Structure Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('KFF Structure 1to1 Cache',
                                     g_str_generic_1to1_controller,
                                     g_str_generic_1to1_storage);
   --
   -- Key Flexfield Segment Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('KFF Segment 1to1 Cache',
                                     g_seg_generic_1to1_controller,
                                     g_seg_generic_1to1_storage);
   --
   -- Key Flexfield Segment TL Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('KFF Seg TL 1to1 Cache',
                                     g_segt_generic_1to1_controller,
                                     g_segt_generic_1to1_storage);
   --
   -- Parent Value Set Id Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('Parent VSet Id 1to1 Cache',
                                     p_vsid_generic_1to1_controller,
                                     p_vsid_generic_1to1_storage);
   --
   -- Key Flexfield Segment Info Generic 1toM Cache
   --
   fnd_plsql_cache.generic_1tom_init('KFF SegInfo Generic 1toM Cache',
                                     seginf_generic_1tom_controller,
                                     seginf_generic_1tom_storage);
   --
   -- Process KFF Combination Generic 1to1 Cache.
   --
   fnd_plsql_cache.generic_1to1_init('Process KFF Comb. 1to1 Cache',
                                     prcomb_generic_1to1_controller,
                                     prcomb_generic_1to1_storage);

   g_newline := fnd_global.newline();
   g_unused_argument := fnd_global.local_chr(0);
   g_debug_enabled := FALSE;
   init_debug();
END fnd_flex_xml_publisher_apis;

/
