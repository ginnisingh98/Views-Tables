--------------------------------------------------------
--  DDL for Package Body FND_FLEX_UPGRADE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_UPGRADE_UTILITIES" AS
/* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */


g_package_name     VARCHAR2(10) := 'UPU.';
g_internal_message VARCHAR2(32000);
g_flag_messaging   BOOLEAN := TRUE;

g_mask_new VARCHAR2(80) := 'YYYY/MM/DD HH24:MI:SS';


g_mask_5     VARCHAR2(80) := 'HH24:MI';
g_mask_8     VARCHAR2(80) := 'HH24:MI:SS';
g_mask_9_8   VARCHAR2(80) := 'DD-MM-RR';
g_mask_9     VARCHAR2(80) := 'DD-MON-RR';
g_mask_11_10 VARCHAR2(80) := 'DD-MM-YYYY';
g_mask_11    VARCHAR2(80) := 'DD-MON-YYYY';
g_mask_15_14 VARCHAR2(80) := 'DD-MM-RR HH24:MI';
g_mask_15    VARCHAR2(80) := 'DD-MON-RR HH24:MI';
g_mask_17_16 VARCHAR2(80) := 'DD-MM-YYYY HH24:MI';
g_mask_17    VARCHAR2(80) := 'DD-MON-YYYY HH24:MI';
g_mask_18_17 VARCHAR2(80) := 'DD-MM-RR HH24:MI:SS';
g_mask_18    VARCHAR2(80) := 'DD-MON-RR HH24:MI:SS';
g_mask_20_19 VARCHAR2(80) := 'DD-MM-YYYY HH24:MI:SS';
g_mask_19    VARCHAR2(80) := 'YYYY/MM/DD HH24:MI:SS';
g_mask_20    VARCHAR2(80) := 'DD-MON-YYYY HH24:MI:SS';

chr_newline VARCHAR2(8) := fnd_global.newline;

g_block_size INTEGER := 100000; -- used in app table upgrades.

-- Concanical Decimal Separator
g_cs VARCHAR2(5) := '.';

-- Decimal Separator;
g_ds VARCHAR2(5) := '.';

-- Group Separator;
g_gs VARCHAR2(5) := ',';

-- nls_numeric_characters;
g_nls_chars VARCHAR2(10) := g_ds || g_gs;

-- CP Log File Indentation.
g_cp_numof_errors NUMBER := 0;    /* Number of errors in one vset upgrade. */
g_cp_indent       NUMBER := 1;    /* Indentation in Log File.              */
g_line_size       NUMBER := 240;  /* Maximum line size.                    */
g_cp_max_indent   NUMBER := 80;   /* Maximum Indentation. Used in headers. */

-- Error message length
g_error_length NUMBER := 2000;

-- Maximum Number of Errors for a given TABLE.COLUMN update.
g_max_numof_errors NUMBER := 1000;

-- Upgrade modes.
g_number_mode    VARCHAR2(10) := 'N';
g_date_mode      VARCHAR2(10) := 'X';
g_datetime_mode  VARCHAR2(10) := 'Y';
g_session_mode   VARCHAR2(100) := 'NOT_SET';

TYPE who_rec_type IS RECORD
  (session_mode      VARCHAR2(100),
   creation_date     fnd_id_flexs.creation_date%TYPE,
   created_by        fnd_id_flexs.created_by%TYPE,
   last_update_date  fnd_id_flexs.last_update_date%TYPE,
   last_updated_by   fnd_id_flexs.last_updated_by%TYPE,
   last_update_login fnd_id_flexs.last_update_login%TYPE);

SUBTYPE vset_rec_type IS fnd_flex_value_sets%ROWTYPE;

TYPE cursor_type IS REF CURSOR;


-- ======================================================================
-- Utility Functions used in both Date and Number Upgrades.
-- ======================================================================
-- --------------------------------------------------
FUNCTION set_error(p_func_name IN VARCHAR2,
                   p_message   IN VARCHAR2,
                   p_sqlerrm   IN VARCHAR2)
  RETURN VARCHAR2
  IS
BEGIN
   RETURN(Substr(p_func_name || ' failed.' || chr_newline ||
                 'ERROR  :' || REPLACE(Nvl(p_message, 'None'),
                                       chr_newline,
                                       Rpad(chr_newline, 9, ' ')) ||
                 chr_newline ||
                 'SQLERRM:' || Nvl(p_sqlerrm, 'None'),
                 1, g_error_length));
EXCEPTION
   WHEN OTHERS THEN
      RETURN(Substr('Set_error : ' || Sqlerrm, 1, g_error_length));
END set_error;


-- --------------------------------------------------
FUNCTION set_who(p_session_mode IN VARCHAR2 DEFAULT 'seed_data',
                 x_error        OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name VARCHAR2(80) := g_package_name || 'set_who';
BEGIN
   x_error := NULL;
   IF (p_session_mode IN ('seed_data', 'customer_data')) THEN
      g_session_mode := p_session_mode;
    ELSE
      x_error := set_error
        (l_func_name,
         'Session Mode must be seed_data or customer_data.' || chr_newline ||
         'p_session_mode : ' || p_session_mode, NULL);
      RETURN(FALSE);
   END IF;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_error := set_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(FALSE);
END set_who;

-- --------------------------------------------------
FUNCTION get_who(x_who_rec      OUT nocopy who_rec_type,
                 x_error        OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name VARCHAR2(100) := g_package_name || 'get_who';
     l_who_rec   who_rec_type;
BEGIN
   x_error := NULL;
   IF (g_session_mode = 'seed_data') THEN
      l_who_rec.created_by := 1;
    ELSIF (g_session_mode = 'customer_data') THEN
      l_who_rec.created_by := 0;
    ELSE
      x_error := set_error
        (l_func_name,
         'Session Mode must be seed_data or customer_data.' || chr_newline ||
         'g_session_mode : ' || g_session_mode, NULL);
      RETURN(FALSE);
   END IF;
   l_who_rec.session_mode      := g_session_mode;
   l_who_rec.creation_date     := Sysdate;
   l_who_rec.last_update_login := 0;
   l_who_rec.last_update_date  := l_who_rec.creation_date;
   l_who_rec.last_updated_by   := l_who_rec.created_by;
   x_who_rec := l_who_rec;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_error := set_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(FALSE);
END get_who;

-- --------------------------------------------------
FUNCTION set_get_who(p_session_mode IN VARCHAR2 DEFAULT 'seed_data',
                     x_who_rec      OUT nocopy who_rec_type,
                     x_error        OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name VARCHAR2(100) := g_package_name || 'set_who';
BEGIN
   IF (NOT set_who(p_session_mode, x_error)) THEN
      RETURN(FALSE);
   END IF;

   IF (NOT get_who(x_who_rec, x_error)) THEN
      RETURN(FALSE);
   END IF;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_error := set_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(FALSE);
END set_get_who;


-- --------------------------------------------------
FUNCTION column_exists(p_application_id IN VARCHAR2,
                       p_table_name     IN VARCHAR2,
                       p_column_name    IN VARCHAR2)
  RETURN BOOLEAN
  IS
     l_rows_count NUMBER;
     l_value             BOOLEAN;
     l_out_status        VARCHAR2(30);
     l_out_industry      VARCHAR2(30);
     l_out_oracle_schema VARCHAR2(30);
BEGIN

   /* Bug 3434427 Fixed warning for GSCC Standard.      */
   /* USed the function below to retrieve oracle_schema */
   /* and then used it in the Where clause below.       */
   l_value :=FND_INSTALLATION.GET_APP_INFO (p_application_id,
                                            l_out_status,
                                            l_out_industry,
                                            l_out_oracle_schema);

   SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
     COUNT(*)
     INTO l_rows_count
     FROM user_synonyms syn, all_tab_columns col
     where syn.synonym_name = p_table_name
     and col.owner = syn.table_owner
     and col.table_name = syn.table_name
     and col.column_name = p_column_name
     and col.owner = l_out_oracle_schema;

   IF (l_rows_count = 1) THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN(FALSE);
END column_exists;

-- --------------------------------------------------
FUNCTION is_fake_table(p_application_id IN fnd_tables.application_id%TYPE,
                       p_table_name     IN fnd_tables.table_name%TYPE)
  RETURN BOOLEAN
  IS
     l_table_type fnd_tables.table_type%TYPE;
BEGIN
   SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
     ft.table_type
     INTO l_table_type
     FROM fnd_tables ft
     WHERE ft.application_id = p_application_id
     AND ft.table_name = p_table_name;

   IF (l_table_type = 'F') THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN(TRUE);
END is_fake_table;

-- --------------------------------------------------
FUNCTION get_application_id
  (p_appl_short_name IN VARCHAR2,
   x_application_id  OUT nocopy NUMBER,
   x_error           OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name VARCHAR2(80) := g_package_name || 'get_application_id';
BEGIN
   SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
     application_id
     INTO x_application_id
     FROM fnd_application
     WHERE application_short_name = p_appl_short_name;
   RETURN(TRUE);
EXCEPTION
   WHEN no_data_found THEN
      x_error :=
        set_error(l_func_name,
                  p_appl_short_name || ' application does not exist.',
                  Sqlerrm);
      RETURN(FALSE);
   WHEN OTHERS THEN
      x_error := set_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(FALSE);
END get_application_id;

-- --------------------------------------------------
FUNCTION get_value_set
  (p_flex_value_set_name IN  VARCHAR2,
   x_vset_rec            OUT nocopy vset_rec_type,
   x_error               OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name VARCHAR2(80) := g_package_name || 'get_value_set';
BEGIN
   SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
     *
     INTO x_vset_rec
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = p_flex_value_set_name;
   RETURN(TRUE);
EXCEPTION
   WHEN no_data_found THEN
      x_error :=
        set_error(l_func_name,
                  p_flex_value_set_name || ' value set does not exist.',
                  Sqlerrm);
      RETURN(FALSE);
   WHEN OTHERS THEN
      x_error :=
        set_error(l_func_name,
                  'Value Set : ' || p_flex_value_set_name,
                  Sqlerrm);
      RETURN(FALSE);
END get_value_set;

-- --------------------------------------------------
FUNCTION is_id_value_set_success
  (p_vset_rec        IN vset_rec_type,
   x_is_id_value_set OUT nocopy BOOLEAN,
   x_error           OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name VARCHAR2(80) := g_package_name || 'is_id_value_set_success';
     l_vc2       VARCHAR2(2000);
BEGIN
   --
   -- Is it id type value set?
   -- User exits and table validated value sets with id column
   -- are id type value sets. For these value sets we store id's in
   -- ATTRIBUTE/SEGMENT columns so we don't need to do any conversion.
   --
   IF (p_vset_rec.validation_type IN ('U','P')) THEN
      x_is_id_value_set := TRUE;
    ELSIF (p_vset_rec.validation_type = 'F') THEN
      BEGIN
         SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
           id_column_name
           INTO l_vc2
           FROM fnd_flex_validation_tables
           WHERE flex_value_set_id = p_vset_rec.flex_value_set_id;
      EXCEPTION
         WHEN OTHERS THEN
            x_error := set_error(l_func_name,
                                 'Error in get table info.', Sqlerrm);
            RETURN(FALSE);
      END;
      IF (l_vc2 IS NOT NULL) THEN
         x_is_id_value_set := TRUE;
      END IF;
    ELSE
      x_is_id_value_set := FALSE;
   END IF;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_error := set_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(FALSE);
END is_id_value_set_success;

-- --------------------------------------------------
FUNCTION get_sql_update
  (p_application_id IN VARCHAR2,
   p_table_name     IN VARCHAR2,
   p_column_name    IN VARCHAR2,
   p_who_rec        IN who_rec_type)
  RETURN VARCHAR2
  IS
     l_sql_update VARCHAR2(2000);
BEGIN
   l_sql_update :=
     'UPDATE ' || p_table_name ||
     ' SET ' || p_column_name || ' = :l_value_new';

   IF (column_exists(p_application_id, p_table_name, 'LAST_UPDATE_DATE')) THEN
      l_sql_update := l_sql_update ||
        ', LAST_UPDATE_DATE = to_date(''' ||
        To_char(p_who_rec.last_update_date,'RRRR/MM/DD') ||
        ''',''RRRR/MM/DD'')';
   END IF;

   IF (column_exists(p_application_id, p_table_name, 'LAST_UPDATED_BY')) THEN
      l_sql_update := l_sql_update ||
        ', LAST_UPDATED_BY = ' || p_who_rec.last_updated_by;
   END IF;
   l_sql_update := l_sql_update || ' WHERE ROWID = :l_rowid';
   RETURN(l_sql_update);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(NULL);
END get_sql_update;

-- --------------------------------------------------
-- p_nls_numeric_characters :
--   NLS setting for the customer site. In general for US customers
--   this is '.,', and for EU customers this is ',.'.
-- Number converters will use this value to convert existing values.
-- If NULL then get it from v$nls_parameters table.
--
FUNCTION set_nls_numeric_characters
  (p_nls_numeric_characters IN VARCHAR2 DEFAULT NULL,
   x_error                  OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name VARCHAR2(80) := g_package_name||'set_nls_numeric_characters';
     l_invalid_set VARCHAR2(100) := '<>+-0123456789';
     l_nls_numeric_characters VARCHAR2(100) := p_nls_numeric_characters;
BEGIN
   --
   -- If NULL get from v$nls_parameters table.
   --
   IF (l_nls_numeric_characters IS NULL) THEN
      BEGIN
         SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
           value INTO l_nls_numeric_characters
           FROM v$nls_parameters
           WHERE parameter = 'NLS_NUMERIC_CHARACTERS';
      EXCEPTION
         WHEN OTHERS THEN
            x_error := set_error(l_func_name,
                                 'SELECT FROM V$NLS_PARAMETERS failed.',
                                 Sqlerrm);
            RETURN(FALSE);
      END;
   END IF;

   --
   -- At least two bytes.
   --
   IF (Nvl(Lengthb(l_nls_numeric_characters),0) < 2) THEN
      GOTO lbl_return_error;
   END IF;

   --
   -- First two bytes should not be in above invalid set.
   --
   IF (Ltrim(Substrb(l_nls_numeric_characters, 1, 2),
             l_invalid_set) IS NULL) THEN
      GOTO lbl_return_error;
   END IF;

   --
   -- First two bytes should not be same.
   --
   IF (Substrb(l_nls_numeric_characters, 1, 1) =
       Substrb(l_nls_numeric_characters, 2, 1)) THEN
      GOTO lbl_return_error;
   END IF;

   --
   -- Now we have a valid nls_numeric_characters.
   --
   g_ds := Substrb(l_nls_numeric_characters, 1, 1);
   g_gs := Substrb(l_nls_numeric_characters, 2, 1);
   g_nls_chars := g_ds || g_gs;

   RETURN(TRUE);

   <<lbl_return_error>>
   --
   -- ORA-12705: invalid or unknown NLS parameter value specified
   --
   x_error := set_error(l_func_name, NULL, Sqlerrm(-12705));
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_error := set_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(FALSE);
END set_nls_numeric_characters;

-- ======================================================================
-- Function : is_to_standard_number
-- ======================================================================
-- Will be used to convert numbers. (Replace ',' with '.')
--
-- Error Cases :
-- If there are more than one <D>.
-- If group separators are not separated by 3 digits.
-- If characters are not in  '<G><D>-0123456789'.
--
-- Examples:
--  <D> : decimal separator := Substr(p_nls_numeric_characters, 2, 1);
--  <G> : group separator   := Substr(p_nls_numeric_characters, 1, 1);
--
--  existing value         converted value
--  ---------------------- --------------------
--  no <G>, no <D>         value stays same
--  no <G>, only one <D>   <D> is replaced with '.'.
--  multiple <D>           ERROR : value stays same
--  'X<G>XXX<D>XX'         'XXXX.XX'
--
--
FUNCTION is_to_standard_number(p_char_in   IN VARCHAR2,
                               x_char_out  OUT nocopy VARCHAR2,
                               x_error     OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_char      VARCHAR2(2000) := p_char_in;
     l_vc2       VARCHAR2(2000);
     l_length    NUMBER := Nvl(Length(l_char),0);
     l_d_pos     NUMBER;
     l_g_pos     NUMBER;
     l_num_g     NUMBER := 0;
     l_valid_set VARCHAR2(100) := g_ds || g_gs || '-0123456789';
     l_g_exists  BOOLEAN := FALSE;
BEGIN
   x_char_out := l_char;
   x_error := NULL;
   --
   -- Null is a valid value.
   --
   IF (l_length = 0) THEN
      RETURN TRUE;
   END IF;

   --
   -- Check against valid characters.
   --
   l_vc2 := Ltrim(Rtrim(l_char, l_valid_set),l_valid_set);
   IF (l_vc2 IS NOT NULL) THEN
      x_error := 'Value contains invalid characters :'''||l_vc2||'''.';
      RETURN FALSE;
   END IF;

   --
   -- There can be only 0 or 1 <D>.
   --
   IF (Instr(l_char, g_ds, 1, 2) > 0) THEN
      x_error := 'More than one <D>.';
      RETURN FALSE;
   END IF;

   --
   -- There must be digits after <D>.
   --
   l_d_pos := Instr(l_char, g_ds, 1, 1);
   IF (l_d_pos = l_length) THEN
      x_error := 'There are no digits after <D>.';
      RETURN FALSE;
   END IF;

   --
   -- If there is no <D> add one at the end.
   -- This will help us to parse <G>'s.
   --
   IF (l_d_pos = 0) THEN
      l_char := l_char || g_ds;
      l_length := Length(l_char);
      l_d_pos := Instr(l_char, g_ds, 1, 1);
   END IF;

   --
   -- At this point we have only one <D>.
   --
   --
   -- Find the right-most group separator.
   --
   l_g_pos := Instr(l_char, g_gs, -1, 1);
   IF (l_g_pos > 0) THEN
      l_g_exists := TRUE;
   END IF;

   --
   -- If value has <G> in it, they must be in correct positions.
   --
   l_num_g := 0;
   IF (l_g_exists) THEN

      IF (l_g_pos > l_d_pos) THEN
         x_error := '<G> cannot be after <D>.';
         RETURN FALSE;
      END IF;

      IF ((Substr(l_char,1,1) = g_gs) OR
          (Substr(l_char,1,2) = '-' || g_gs)) THEN
         x_error := '<G> cannot be at the beginning.';
         RETURN FALSE;
      END IF;

      WHILE (l_g_pos > 0) LOOP
         l_num_g := l_num_g + 1;

         IF ((l_g_pos + 4 * l_num_g) <> l_d_pos) THEN
            x_error := '<G>''s are not in correct positions.';
            RETURN FALSE;
         END IF;

         --
         -- Find the next <G>.
         --
         l_g_pos := Instr(l_char, g_gs, -1, l_num_g + 1);
      END LOOP;
   END IF;

   --
   -- Remove <D> from the tail, if it is there.
   --
   l_char := Rtrim(l_char, g_ds);

   --
   -- If <G> is '.' and there is only one '.' then
   -- it is possible that the value was already upgraded.
   -- if this is the case report it.
   -- For example, say NLS is ',.' and the value is '1.000'
   -- Now is this unconverted '1000' or converted '1.000'?
   --
   IF (g_gs = g_cs AND
       l_num_g = 1 AND
       Instr(l_char, g_ds, 1, 1) = 0) THEN
      x_error := 'Do not know if ''.'' is <G> or canonical separator.';
      RETURN FALSE;
   END IF;

   --
   -- Now we have a legal number.
   --

   --
   -- Remove all <G>'s.
   --
   l_char := REPLACE(l_char, g_gs, NULL);

   --
   -- Replace <D> with '.'.
   --
   l_char := REPLACE(l_char, g_ds, g_cs);

   x_char_out := Rtrim(l_char, g_cs);
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      x_char_out := p_char_in;
      x_error := 'is_to_standard_number:Exception : ' || Sqlerrm;
      RETURN FALSE;
END is_to_standard_number;


-- ======================================================================
-- Function : is_to_standard_date
-- ======================================================================
-- Will be used to convert dates.
--
FUNCTION is_to_standard_date(p_char_in   IN VARCHAR2,
                             x_char_out  OUT nocopy VARCHAR2,
                             x_error     OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_length    NUMBER;
     l_func_name VARCHAR2(80) := g_package_name || 'is_to_standard_date';
     l_date      DATE;
BEGIN
   x_char_out := p_char_in;
   l_length := Nvl(Length(p_char_in), 0);
   IF (l_length = 0) THEN
      RETURN(TRUE);
   END IF;

   --
   -- This is only for Date upgrades, do not try Time masks.
   --
   IF (l_length = 8) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_9_8);
    ELSIF (l_length = 9) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_9);
    ELSIF (l_length = 10) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_11_10);
    ELSIF (l_length = 11) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_11);
    ELSIF (l_length = 14) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_15_14);
    ELSIF (l_length = 15) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_15);
    ELSIF (l_length = 16) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_17_16);
    ELSIF (l_length = 17) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_17);
      IF (l_date IS NULL) THEN
         l_date := fnd_date.string_to_date(p_char_in, g_mask_18_17);
      END IF;
    ELSIF (l_length = 18) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_18);
    ELSIF (l_length = 19) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_19);
      IF (l_date IS NULL) THEN
         l_date := fnd_date.string_to_date(p_char_in, g_mask_20_19);
      END IF;
    ELSIF (l_length = 20) THEN
      l_date := fnd_date.string_to_date(p_char_in, g_mask_20);
    ELSE
      x_error :=
        set_error(l_func_name,
                  'Unknown length. Old Value : ''' ||
                  p_char_in || '''', NULL);
      RETURN(FALSE);
   END IF;

   IF (l_date IS NULL) THEN
      x_error := set_error(l_func_name,
                           'Unable to convert to date.',
                           Sqlerrm);
      RETURN(FALSE);
   END IF;

   x_char_out := To_char(l_date, g_mask_new);
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_error :=
        set_error(l_func_name,
                  'Top Level Exception. Old value : ''' ||
                  p_char_in || '''', Sqlerrm);
      RETURN(FALSE);
END is_to_standard_date;

-- --------------------------------------------------
FUNCTION is_to_standard(p_mode      IN VARCHAR2,
                        p_char_in   IN VARCHAR2,
                        x_char_out  OUT nocopy VARCHAR2,
                        x_error     OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_func_name      VARCHAR2(80) := g_package_name || 'is_to_standard';
BEGIN
   IF (p_mode = g_number_mode) THEN
      RETURN(is_to_standard_number(p_char_in, x_char_out, x_error));
    ELSIF (p_mode = g_date_mode OR
           p_mode = g_datetime_mode) THEN
      RETURN(is_to_standard_date(p_char_in, x_char_out, x_error));
    ELSE
      x_error := set_error(l_func_name,
                           'Unknown Mode : ' || p_mode ,
                           NULL);
      RETURN(FALSE);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_error := set_error(l_func_name,
                           'Top Level Exception.',
                           Sqlerrm);
      RETURN(FALSE);
END is_to_standard;


-- ======================================================================
-- MESSAGE
-- ======================================================================
PROCEDURE init_message
  IS
BEGIN
   IF g_flag_messaging THEN
      g_internal_message := g_package_name || ':' || chr_newline;
    ELSE
      g_internal_message := 'Messaging is turned OFF. ' || chr_newline ||
        'Please call set_messaging(TRUE) to turn it ON.';
   END IF;
END init_message;

FUNCTION get_message RETURN VARCHAR2
  IS
BEGIN
   RETURN(g_internal_message);
END get_message;

PROCEDURE message(p_msg IN VARCHAR2)
  IS
BEGIN
   IF g_flag_messaging THEN
      IF (Length(g_internal_message) < 31000) THEN
         g_internal_message := g_internal_message || p_msg || chr_newline;
       ELSE
         g_internal_message := g_internal_message ||
           'Maximum size is reached for message string. ' || chr_newline ||
           'Messaging is turned OFF.';
         g_flag_messaging := FALSE;
      END IF;
   END IF;
END message;

PROCEDURE set_messaging(p_flag IN BOOLEAN)
  IS
BEGIN
   g_flag_messaging := Nvl(p_flag,FALSE);
END set_messaging;

PROCEDURE internal_init
  IS
BEGIN
   init_message;
   g_cp_indent := 1;
   g_cp_numof_errors := 0;
END internal_init;

PROCEDURE debug(p_debug IN VARCHAR2)
  IS
BEGIN
   message('DEBUG:' || p_debug);
END debug;

PROCEDURE report_success(p_func_name IN VARCHAR2,
                         p_message IN VARCHAR2)
  IS
BEGIN
   message(p_func_name  || ' successfully completed.');
   message('Message:' || Nvl(p_message, 'None'));
END report_success;

PROCEDURE report_error(p_func_name IN VARCHAR2,
                       p_message IN VARCHAR2,
                       p_sqlerrm IN VARCHAR2)
  IS
BEGIN
   message(set_error(p_func_name,
                     p_message,
                     p_sqlerrm));
END report_error;


-- ======================================================================
-- Public Functions
-- ======================================================================

-- ======================================================================
-- Date Upgrades
-- ======================================================================

FUNCTION clone_date_vset
  (p_old_value_set_name IN VARCHAR2,
   p_new_value_set_name IN VARCHAR2,
   p_session_mode       IN VARCHAR2 DEFAULT 'customer_data')
  RETURN NUMBER
  IS
     l_func_name      VARCHAR2(80) := g_package_name || 'clone_date_vset';
     l_format_type    VARCHAR2(1);
     l_maximum_size   NUMBER;
     l_ret_code       NUMBER := g_ret_no_error;

     l_minimum_value             fnd_flex_value_sets.minimum_value%TYPE;
     l_maximum_value             fnd_flex_value_sets.maximum_value%TYPE;
     l_dependant_default_value   fnd_flex_value_sets.dependant_default_value%TYPE;
     l_dependant_default_meaning fnd_flex_value_sets.dependant_default_meaning%TYPE;
     l_who_rec                   who_rec_type;
     l_old_vset_rec              vset_rec_type;
     l_new_vset_rec              vset_rec_type;
     l_long                      VARCHAR2(32000);
     l_count                     NUMBER;
     l_event_code                fnd_flex_validation_events.event_code%TYPE;
     l_error                     VARCHAR2(2000);
BEGIN
   internal_init;
   debug('Starting to clone...');
   debug('Old Value Set Name : ' || p_old_value_set_name);
   debug('New Value Set Name : ' || p_new_value_set_name);

   SAVEPOINT sp_clone_date_vset;
   --
   -- WHO columns
   --
   IF (NOT set_get_who(p_session_mode, l_who_rec, l_error)) THEN
      message(l_error);
      l_ret_code := g_ret_critical_error;
      GOTO lbl_return;
   END IF;

   --
   -- Make sure old value set exists.
   --
   IF (NOT get_value_set(p_old_value_set_name, l_old_vset_rec, l_error)) THEN
      message(l_error);
      l_ret_code := g_ret_critical_error;
      GOTO lbl_return;
   END IF;
   debug('Old value set id : ' || l_old_vset_rec.flex_value_set_id);

   --
   -- Make sure old value set is in old date format.
   --
   IF (NOT (l_old_vset_rec.format_type IN ('D', 'T'))) THEN
      report_error(l_func_name,
                   'No need to clone this value set' || chr_newline ||
                   'Value Set Name : '||p_old_value_set_name||chr_newline ||
                   'Format Type    : '||l_old_vset_rec.format_type,
                   NULL);
      l_ret_code := g_ret_no_need_to_clone;
      GOTO lbl_return;
   END IF;

   --
   -- New format_type and maximum_size.
   --
   IF (l_old_vset_rec.format_type = 'D') THEN
      l_format_type := 'X';
      l_maximum_size := 11;
    ELSE
      l_format_type := 'Y';
      l_maximum_size := 20;
   END IF;
   debug('New value set format type  : ' || l_format_type);
   debug('New value set maximum size : ' || l_maximum_size);
   --
   -- Make sure new value set does not exist or
   -- if it exists it was already cloned.
   --
   BEGIN
      SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
        *
        INTO l_new_vset_rec
        FROM fnd_flex_value_sets
        WHERE flex_value_set_name = p_new_value_set_name;
      --
      -- New value set exists check the format and maximum size.
      --
      IF ((l_new_vset_rec.format_type = l_format_type) AND
          (l_new_vset_rec.maximum_size = l_maximum_size)) THEN
         --
         -- It was already cloned.
         --
         report_error(l_func_name,
                      p_old_value_set_name || ' was already cloned.',
                      NULL);
         l_ret_code := g_ret_already_cloned;
         GOTO lbl_return;
       ELSE
         report_error(l_func_name,
                      p_new_value_set_name || ' value set already exists ' ||
                      'with a different format_type or maximum_size.' ||
                      chr_newline ||
                      'Format Type  : ' || l_new_vset_rec.format_type ||
                      chr_newline ||
                      'Maximum Size : ' || l_new_vset_rec.maximum_size, NULL);
         l_ret_code := g_ret_new_vset_exists;
         GOTO lbl_return;
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
         --
         -- New value set does not exist.
         --
         debug('New value set does not exist, which is OK...');
         NULL;
      WHEN OTHERS THEN
         report_error(l_func_name,
                      'Value Set : ' || p_new_value_set_name, Sqlerrm);
         l_ret_code := g_ret_critical_error;
         GOTO lbl_return;
   END;

   --
   -- New minimum_value, maximum_value and dependant_default_value.
   --
   IF (NOT is_to_standard_date(l_old_vset_rec.minimum_value,
                               l_minimum_value, l_error)) THEN
      message(l_error);
      message(l_func_name || chr_newline ||
              'Minimum Value is not in proper format.' || chr_newline ||
              'Minimum Value : '||l_old_vset_rec.minimum_value||chr_newline ||
              'It is set to NULL');
      l_minimum_value := NULL;
   END IF;
   IF (NOT is_to_standard_date(l_old_vset_rec.maximum_value,
                               l_maximum_value, l_error)) THEN
      message(l_error);
      message(l_func_name || chr_newline ||
              'Maximum Value is not in proper format.' || chr_newline ||
              'Maximum Value : '||l_old_vset_rec.maximum_value||chr_newline ||
              'It is set to NULL');
      l_maximum_value := NULL;
   END IF;

   l_dependant_default_value := l_old_vset_rec.dependant_default_value;
   l_dependant_default_meaning := l_old_vset_rec.dependant_default_meaning;
   IF (l_old_vset_rec.validation_type = 'D') THEN
      IF (NOT is_to_standard_date(l_old_vset_rec.dependant_default_value,
                                  l_dependant_default_value, l_error)) THEN
         --
         -- dependant_default_value is required, set it to something.
         --
         message(l_error);
         message(l_func_name || chr_newline ||
                 'Dependent Default Value is not in proper format.' ||
                 chr_newline ||
                 'Dependent Default Value : ' ||
                 l_old_vset_rec.dependant_default_value || chr_newline ||
                 'It is set to 1000/01/01 00:00:00');
         l_dependant_default_value := '1000/01/01 00:00:00';
         l_dependant_default_meaning := 'Set to 1000/01/01 00:00:00 by upgrade utility.';
      END IF;
   END IF;

   --
   -- Clone the row in FND_FLEX_VALUE_SETS table.
   --
   BEGIN
      INSERT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
        INTO fnd_flex_value_sets
        (flex_value_set_id,
         flex_value_set_name,
         validation_type,
         security_enabled_flag,
         longlist_flag,
         format_type,
         maximum_size,
         alphanumeric_allowed_flag,
         uppercase_only_flag,
         numeric_mode_enabled_flag,
         description,
         minimum_value,
         maximum_value,
         number_precision,
         protected_flag,
         last_update_login,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,

         dependant_default_value,/* note spelling */
         dependant_default_meaning,/* note spelling */
         parent_flex_value_set_id)
        SELECT
        fnd_flex_value_sets_s.NEXTVAL,
        p_new_value_set_name,
        validation_type,
        security_enabled_flag,
        longlist_flag,
        l_format_type,
        l_maximum_size,
        'Y', -- alphanumeric_allowed_flag
        'Y', -- uppercase_only_flag
        'N', -- numeric_mode_enabled_flag
        description,
        l_minimum_value,
        l_maximum_value,
        number_precision,
        protected_flag,
        l_who_rec.last_update_login,
        l_who_rec.last_update_date,
        l_who_rec.last_updated_by,
        l_who_rec.creation_date,
        l_who_rec.created_by,
        l_dependant_default_value,
        l_dependant_default_meaning,
        parent_flex_value_set_id
        FROM fnd_flex_value_sets
        WHERE flex_value_set_name = p_old_value_set_name;

      IF (SQL%rowcount = 1) THEN
         debug('FND_FLEX_VALUE_SETS entry cloned successfully.');
       ELSE
         report_error(l_func_name,
                      'SQL%ROWCOUNT : ' || SQL%rowcount,NULL);
         l_ret_code := g_ret_critical_error;
         GOTO lbl_return;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         report_error(l_func_name,
                      'INSERT INTO fnd_flex_value_sets failed.', Sqlerrm);
         l_ret_code := g_ret_critical_error;
         GOTO lbl_return;
   END;

   --
   -- Reselect New Value Set.
   --
   IF (NOT get_value_set(p_new_value_set_name, l_new_vset_rec, l_error)) THEN
      message(l_error);
      l_ret_code := g_ret_critical_error;
      GOTO lbl_return;
   END IF;
   debug('New value set id : ' || l_new_vset_rec.flex_value_set_id);
   debug('New value set validation type : ' || l_new_vset_rec.validation_type);

   IF (l_new_vset_rec.validation_type = 'F') THEN
      --
      -- Clone the row in FND_FLEX_VALIDATION_TABLES table.
      --
      -- Since we have a long column we have to select it first.
      --
      BEGIN
         SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
           additional_where_clause
           INTO l_long
           FROM fnd_flex_validation_tables
           WHERE flex_value_set_id = l_old_vset_rec.flex_value_set_id;
      EXCEPTION
         WHEN OTHERS THEN
            report_error(l_func_name,
                         'SELECT FROM fnd_flex_validation_tables failed.',
                         Sqlerrm);
            l_ret_code := g_ret_critical_error;
            GOTO lbl_return;
      END;
      BEGIN
         INSERT INTO fnd_flex_validation_tables
           (flex_value_set_id,
            application_table_name,
            value_column_name,
            value_column_type,
            value_column_size,
            id_column_name,
            id_column_type,
            id_column_size,
            meaning_column_name,
            meaning_column_type,
            meaning_column_size,
            summary_allowed_flag,
            table_application_id,
            additional_where_clause,
            additional_quickpick_columns,

            compiled_attribute_column_name,
            enabled_column_name,
            hierarchy_level_column_name,
            start_date_column_name,
            end_date_column_name,
            summary_column_name,

            last_update_login,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
           SELECT
           l_new_vset_rec.flex_value_set_id,
           application_table_name,
           value_column_name,
           value_column_type,
           value_column_size,
           id_column_name,
           id_column_type,
           id_column_size,
           meaning_column_name,
           meaning_column_type,
           meaning_column_size,
           summary_allowed_flag,
           table_application_id,
           l_long, -- additional_where_clause,
           additional_quickpick_columns,

           compiled_attribute_column_name,
           enabled_column_name,
           hierarchy_level_column_name,
           start_date_column_name,
           end_date_column_name,
           summary_column_name,

           l_who_rec.last_update_login,
           l_who_rec.last_update_date,
           l_who_rec.last_updated_by,
           l_who_rec.creation_date,
           l_who_rec.created_by
           FROM fnd_flex_validation_tables
           WHERE flex_value_set_id = l_old_vset_rec.flex_value_set_id;
         IF (SQL%rowcount = 1) THEN
            debug('FND_FLEX_VALIDATION_TABLES entry is succesfully cloned.');
          ELSE
            report_error(l_func_name,
                         'SQL%ROWCOUNT : ' || SQL%rowcount,NULL);
            l_ret_code := g_ret_critical_error;
            GOTO lbl_return;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            report_error(l_func_name,
                         'INSERT INTO fnd_flex_validation_tables failed.',
                         Sqlerrm);
            l_ret_code := g_ret_critical_error;
            GOTO lbl_return;
      END;


    ELSIF (l_new_vset_rec.validation_type IN  ('U','P')) THEN
       --
       -- Clone the rows in FND_FLEX_VALIDATION_EVENTS table.
       --
       BEGIN
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            COUNT(*)
            INTO l_count
            FROM fnd_flex_validation_events
            WHERE flex_value_set_id = l_old_vset_rec.flex_value_set_id;
       EXCEPTION
          WHEN OTHERS THEN
             report_error(l_func_name,
                          'SELECT COUNT fnd_flex_validation_events failed.',
                          Sqlerrm);
             l_ret_code := g_ret_critical_error;
             GOTO lbl_return;
       END;
       debug('Number of events : ' || l_count);

       FOR i IN 1..l_count LOOP
          BEGIN
             SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
               user_exit, event_code
               INTO l_long, l_event_code
               FROM fnd_flex_validation_events told
               WHERE told.flex_value_set_id = l_old_vset_rec.flex_value_set_id
               AND ROWNUM = 1
               AND NOT exists
               (SELECT NULL
                FROM fnd_flex_validation_events tnew
                WHERE tnew.flex_value_set_id = l_new_vset_rec.flex_value_set_id
                AND tnew.event_code = told.event_code);
          EXCEPTION
             WHEN OTHERS THEN
                report_error(l_func_name,
                             'SELECT FROM fnd_flex_validation_events ' ||
                             'failed.', Sqlerrm);
                l_ret_code := g_ret_critical_error;
                GOTO lbl_return;
          END;
          BEGIN
             INSERT INTO fnd_flex_validation_events
               (flex_value_set_id,
                event_code,
                user_exit,
                last_update_login,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by)
               VALUES (l_new_vset_rec.flex_value_set_id,
                       l_event_code,
                       l_long,
                       l_who_rec.last_update_login,
                       l_who_rec.last_update_date,
                       l_who_rec.last_updated_by,
                       l_who_rec.creation_date,
                       l_who_rec.created_by);
             IF (SQL%rowcount = 1) THEN
                debug('FND_FLEX_VALIDATION_EVENTS is succesfully cloned.');
                debug('event code : ' || l_event_code);
              ELSE
                report_error(l_func_name,
                             'SQL%ROWCOUNT : ' || SQL%rowcount,NULL);
                l_ret_code := g_ret_critical_error;
                GOTO lbl_return;
             END IF;
          EXCEPTION
             WHEN OTHERS THEN
                report_error(l_func_name,
                             'INSERT INTO fnd_flex_validation_events failed.',
                             Sqlerrm);
                l_ret_code := g_ret_critical_error;
                GOTO lbl_return;
          END;
       END LOOP;
   END IF;

   <<lbl_return>>
   IF (l_ret_code = g_ret_no_error) THEN
      message('Successful operation calling !!!COMMIT!!! ...');
      COMMIT;
    ELSE
      message('Unsuccessful operation calling !!!ROLLBACK!!! ...');
      ROLLBACK TO SAVEPOINT sp_clone_date_vset;
   END IF;
   RETURN(l_ret_code);
EXCEPTION
   WHEN OTHERS THEN
      report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      ROLLBACK TO SAVEPOINT sp_clone_date_vset;
      message('Unsuccessful operation calling !!!ROLLBACK!!! ...');
      RETURN(g_ret_critical_error);
END clone_date_vset;



FUNCTION upgrade_date_report_parameters
  (p_appl_short_name  IN VARCHAR2,
   p_value_set_from   IN VARCHAR2,
   p_value_set_to     IN VARCHAR2,
   p_session_mode     IN VARCHAR2 DEFAULT 'customer_data',
   p_report_name_like IN VARCHAR2 DEFAULT '%')
  RETURN NUMBER
  IS
     l_func_name         VARCHAR2(80) := (g_package_name ||
                                          'upgrade_date_report_parameters');
     l_who_rec           who_rec_type;
     l_application_id    NUMBER;
     l_old_vset_rec      vset_rec_type;
     l_new_vset_rec      vset_rec_type;
     l_report_name_like  VARCHAR2(200) :='$SRS$.'||Nvl(p_report_name_like,'%');
     l_ret_code          NUMBER := g_ret_no_error;
     l_segs_count        NUMBER := 0;
     l_default_value     fnd_descr_flex_column_usages.default_value%TYPE;

     CURSOR srs_cur(p_application_id    IN NUMBER,
                    p_flex_value_set_id IN NUMBER,
                    p_report_name_like  IN VARCHAR2)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            application_id, descriptive_flexfield_name,
            descriptive_flex_context_code,
            application_column_name, end_user_column_name,
            default_type, default_value
            FROM fnd_descr_flex_column_usages
            WHERE application_id = p_application_id
            AND flex_value_set_id = p_flex_value_set_id
            AND descriptive_flexfield_name LIKE p_report_name_like
            AND enabled_flag = 'Y'
            AND descriptive_flex_context_code = 'Global Data Elements'
            ORDER BY application_id, descriptive_flexfield_name,
            descriptive_flex_context_code, application_column_name;

     srs_rec   srs_cur%ROWTYPE;
     l_error   VARCHAR2(2000);
BEGIN
   internal_init;
   --
   -- WHO columns
   --
   IF (NOT set_get_who(p_session_mode, l_who_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Get the application_id.
   --
   IF (NOT get_application_id(p_appl_short_name,
                              l_application_id, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('application_id : ' || To_char(l_application_id));

   --
   -- Get the old value set.
   --
   IF (NOT get_value_set(p_value_set_from, l_old_vset_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('from_value_set_id : ' || To_char(l_old_vset_rec.flex_value_set_id));

   IF (NOT (l_old_vset_rec.format_type IN ('D', 'T'))) THEN
      message('From value set must be regular type Date or Date/Time.');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Get the new value set.
   --
   IF (NOT get_value_set(p_value_set_to, l_new_vset_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('to_value_set_id : ' || To_char(l_new_vset_rec.flex_value_set_id));

   IF (NOT (l_new_vset_rec.format_type IN ('X', 'Y'))) THEN
      message('To value set must be standard type Date or Date/Time.');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Count the segments
   --
   l_segs_count := 0;
   FOR srs_rec IN srs_cur(l_application_id,
                          l_old_vset_rec.flex_value_set_id,
                          l_report_name_like) LOOP
      l_segs_count := l_segs_count + 1;
   END LOOP;
   debug('Number of parameters to upgrade : ' || To_char(l_segs_count));

   -- go one-by-one
   FOR i IN 1..l_segs_count LOOP
      --
      -- Since cursor data is changed every time, we will fetch one row
      -- at a time.
      --
      OPEN srs_cur(l_application_id, l_old_vset_rec.flex_value_set_id,
                   l_report_name_like);
      FETCH srs_cur INTO srs_rec;
      CLOSE srs_cur;
      debug('Modifying:' || p_appl_short_name || ':' ||
            srs_rec.descriptive_flexfield_name || ':' ||
            srs_rec.descriptive_flex_context_code || ':' ||
            srs_rec.end_user_column_name);
      l_default_value := srs_rec.default_value;
      IF (srs_rec.default_type = 'C') THEN
         IF (NOT is_to_standard_date(srs_rec.default_value,
                                     l_default_value, l_error)) THEN
            --
            -- If type is constant then default_value is required,
            -- set it to something.
            --
            message(l_error);
            message(l_func_name || chr_newline ||
                    'Default Value is not in proper format.' ||chr_newline||
                    'Default Value : ' ||
                    srs_rec.default_value || chr_newline ||
                    'It is set to 1000/01/01 00:00:00');
            l_default_value := '1000/01/01 00:00:00';
            l_ret_code := g_ret_ignored_errors;
         END IF;
      END IF;

      BEGIN
         UPDATE fnd_descr_flex_column_usages
           SET flex_value_set_id = l_new_vset_rec.flex_value_set_id,
           default_value = l_default_value,
           last_update_date = l_who_rec.last_update_date,
           last_updated_by = l_who_rec.last_updated_by
           WHERE application_id = srs_rec.application_id
           AND descriptive_flexfield_name = srs_rec.descriptive_flexfield_name
           AND descriptive_flex_context_code = srs_rec.descriptive_flex_context_code
           AND application_column_name = srs_rec.application_column_name;
      EXCEPTION
         WHEN OTHERS THEN
            report_error(l_func_name,
                         'Failure in UPDATE FND_DESCR_FLEX_COLUMN_USAGES.',
                         Sqlerrm);
            l_ret_code := g_ret_ignored_errors;
      END;
      COMMIT;
   END LOOP;

   report_success(l_func_name,
                  'Parameters upgraded for : ' || p_appl_short_name);
   message('Calling !!!COMMIT!!! ...');
   COMMIT;
   RETURN(l_ret_code);
EXCEPTION
   WHEN OTHERS THEN
      report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(g_ret_critical_error);
END upgrade_date_report_parameters;


FUNCTION upgrade_date_dff_segments
  (p_appl_short_name   IN VARCHAR2,
   p_value_set_from    IN VARCHAR2,
   p_value_set_to      IN VARCHAR2,
   p_session_mode      IN VARCHAR2 DEFAULT 'customer_data',
   p_dff_name_like     IN VARCHAR2 DEFAULT '%',
   p_context_code_like IN VARCHAR2 DEFAULT '%')
  RETURN NUMBER
  IS
     l_func_name         VARCHAR2(80) := (g_package_name ||
                                          'upgrade_date_dff_segments');
     l_application_id    NUMBER;
     l_ret_code          NUMBER := g_ret_no_error;
     l_segs_count        NUMBER := 0;
     l_default_value     fnd_descr_flex_column_usages.default_value%TYPE;
     l_old_vset_rec      vset_rec_type;
     l_new_vset_rec      vset_rec_type;
     l_dff_name_like     VARCHAR2(500) := Nvl(p_dff_name_like, '%');
     l_context_code_like VARCHAR2(500) := Nvl(p_context_code_like, '%');

     l_who_rec           who_rec_type;
     l_error             VARCHAR2(2000);

     CURSOR dff_cur(p_application_id    IN NUMBER,
                    p_flex_value_set_id IN NUMBER,
                    p_dff_name_like     IN VARCHAR2,
                    p_context_code_like IN VARCHAR2)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            df.application_id, df.descriptive_flexfield_name,
            df.table_application_id, df.application_table_name,
            df.context_column_name,
            dfc.descriptive_flex_context_code, dfc.global_flag,
            dfcu.application_column_name, dfcu.end_user_column_name,
            dfcu.default_type, dfcu.default_value,
            fc.column_type, fc.width
            FROM fnd_descriptive_flexs df, fnd_descr_flex_contexts dfc,
            fnd_descr_flex_column_usages dfcu, fnd_columns fc
            WHERE df.application_id = dfc.application_id
            AND df.descriptive_flexfield_name = dfc.descriptive_flexfield_name
            AND dfc.application_id = dfcu.application_id
            AND dfc.descriptive_flexfield_name = dfcu.descriptive_flexfield_name
            AND dfc.descriptive_flex_context_code = dfcu.descriptive_flex_context_code
            AND ((fc.application_id, fc.table_id) =
                 (SELECT ft.application_id, ft.table_id
                  FROM fnd_tables ft
                  WHERE ft.application_id = df.table_application_id
                  AND ft.table_name = df.application_table_name))
            AND fc.column_name = dfcu.application_column_name
            AND fc.flexfield_usage_code = 'D'
            AND dfcu.flex_value_set_id = p_flex_value_set_id
            AND dfcu.enabled_flag = 'Y'
            AND dfc.enabled_flag = 'Y'
            AND df.application_id = p_application_id
            AND df.descriptive_flexfield_name LIKE p_dff_name_like
            AND dfc.descriptive_flex_context_code LIKE p_context_code_like
            ORDER BY df.application_id, df.descriptive_flexfield_name,
            dfc.descriptive_flex_context_code, dfcu.application_column_name;

     dff_rec   dff_cur%ROWTYPE;
BEGIN
   internal_init;
   --
   -- WHO columns
   --
   IF (NOT set_get_who(p_session_mode, l_who_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Get the application_id.
   --
   IF (NOT get_application_id(p_appl_short_name,
                              l_application_id, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('application_id : ' || To_char(l_application_id));

   --
   -- Get the old value set.
   --
   IF (NOT get_value_set(p_value_set_from, l_old_vset_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('from_value_set_id : ' || To_char(l_old_vset_rec.flex_value_set_id));

   IF (NOT (l_old_vset_rec.format_type IN ('D', 'T'))) THEN
      message('From value set must be regular type Date or Date/Time.');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Get the new value set.
   --
   IF (NOT get_value_set(p_value_set_to, l_new_vset_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('to_value_set_id : ' || To_char(l_new_vset_rec.flex_value_set_id));

   IF (NOT (l_new_vset_rec.format_type IN ('X', 'Y'))) THEN
      message('To value set must be standard type Date or Date/Time.');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Count the old segments
   --
   l_segs_count := 0;
   FOR dff_rec IN dff_cur(l_application_id,
                          l_old_vset_rec.flex_value_set_id,
                          l_dff_name_like,
                          l_context_code_like) LOOP
      l_segs_count := l_segs_count + 1;
   END LOOP;
   debug('Number of DFF segments to upgrade : ' || To_char(l_segs_count));

   -- go one-by-one
   FOR i IN 1..l_segs_count LOOP
      --
      -- Since cursor data is changed every time, we will fetch one row
      -- at a time.
      --
      OPEN dff_cur(l_application_id, l_old_vset_rec.flex_value_set_id,
                   l_dff_name_like, l_context_code_like);
      FETCH dff_cur INTO dff_rec;
      CLOSE dff_cur;
      debug('Modifying:' || p_appl_short_name || ':' ||
            dff_rec.descriptive_flexfield_name || ':' ||
            dff_rec.descriptive_flex_context_code || ':' ||
            dff_rec.end_user_column_name);
      l_default_value := dff_rec.default_value;
      IF (dff_rec.default_type = 'C') THEN
         IF (NOT is_to_standard_date(dff_rec.default_value,
                                     l_default_value, l_error)) THEN
            --
            -- If type is constant then default_value is required,
            -- set it to something.
            --
            message(l_error);
            message(l_func_name || chr_newline ||
                    'Default Value is not in proper format.' ||chr_newline||
                    'Default Value : ' ||
                    dff_rec.default_value || chr_newline ||
                    'It is set to 1000/01/01 00:00:00');
            l_default_value := '1000/01/01 00:00:00';
            l_ret_code := g_ret_ignored_errors;
         END IF;
      END IF;

      BEGIN
         UPDATE fnd_descr_flex_column_usages
           SET flex_value_set_id = l_new_vset_rec.flex_value_set_id,
           default_value = l_default_value,
           last_update_date = l_who_rec.last_update_date,
           last_updated_by = l_who_rec.last_updated_by
           WHERE application_id = dff_rec.application_id
           AND descriptive_flexfield_name = dff_rec.descriptive_flexfield_name
           AND descriptive_flex_context_code = dff_rec.descriptive_flex_context_code
           AND application_column_name = dff_rec.application_column_name;
      EXCEPTION
         WHEN OTHERS THEN
            report_error(l_func_name,
                         'Failure in UPDATE FND_DESCR_FLEX_COLUMN_USAGES.',
                         Sqlerrm);
            l_ret_code := g_ret_ignored_errors;
      END;
      COMMIT;
   END LOOP; -- FOR i IN 1..l_segs_count

   report_success(l_func_name,
                  'DFF segments upgraded for : ' || p_appl_short_name);
   message('Calling !!!COMMIT!!! ...');
   COMMIT;
   RETURN(l_ret_code);
EXCEPTION
   WHEN OTHERS THEN
      report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(g_ret_critical_error);
END upgrade_date_dff_segments;


FUNCTION upgrade_date_kff_segments
  (p_appl_short_name  IN VARCHAR2,
   p_id_flex_code     IN VARCHAR2,
   p_value_set_from   IN VARCHAR2,
   p_value_set_to     IN VARCHAR2,
   p_session_mode     IN VARCHAR2 DEFAULT 'customer_data',
   p_struct_num_like  IN VARCHAR2 DEFAULT '%',
   p_struct_name_like IN VARCHAR2 DEFAULT '%')
  RETURN NUMBER
  IS
     l_func_name         VARCHAR2(80) := (g_package_name ||
                                          'upgrade_date_kff_segments');
     l_application_id    NUMBER;
     l_ret_code          NUMBER := g_ret_no_error;
     l_segs_count        NUMBER := 0;
     l_default_value     fnd_id_flex_segments.default_value%TYPE;
     l_old_vset_rec      vset_rec_type;
     l_new_vset_rec      vset_rec_type;
     l_struct_num_like   VARCHAR2(500) := Nvl(p_struct_num_like, '%');
     l_struct_name_like  VARCHAR2(500) := Nvl(p_struct_name_like, '%');

     l_who_rec           who_rec_type;
     l_error             VARCHAR2(2000);

     CURSOR kff_cur(p_application_id IN NUMBER,
                    p_id_flex_code IN VARCHAR2,
                    p_flex_value_set_id IN NUMBER,
                    p_struct_num_like IN VARCHAR2,
                    p_struct_name_like IN VARCHAR2)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            idf.application_id, idf.id_flex_code,
            idf.table_application_id, idf.application_table_name,
            idf.set_defining_column_name, idf.unique_id_column_name,
            ifst.id_flex_num, ifst.id_flex_structure_name,
            ifsg.segment_name, ifsg.application_column_name,
            ifsg.default_type, ifsg.default_value,
            fc.column_type, fc.width
            FROM fnd_id_flexs idf, fnd_id_flex_structures_vl ifst,
            fnd_id_flex_segments ifsg, fnd_columns fc
            WHERE idf.application_id = ifst.application_id
            AND idf.id_flex_code = ifst.id_flex_code
            AND ifst.application_id = ifsg.application_id
            AND ifst.id_flex_code = ifsg.id_flex_code
            AND ifst.id_flex_num = ifsg.id_flex_num
            AND ((fc.application_id, fc.table_id) =
                 (SELECT ft.application_id, ft.table_id
                  FROM fnd_tables ft
                  WHERE ft.application_id = idf.table_application_id
                  AND ft.table_name = idf.application_table_name))
            AND fc.column_name = ifsg.application_column_name
            AND fc.flexfield_usage_code = 'K'
            AND ifsg.flex_value_set_id = p_flex_value_set_id
            AND ifst.enabled_flag = 'Y'
            AND ifsg.enabled_flag = 'Y'
            AND idf.application_id = p_application_id
            AND idf.id_flex_code = p_id_flex_code
            AND ifst.id_flex_structure_name LIKE p_struct_name_like
            AND To_char(ifst.id_flex_num) LIKE p_struct_num_like
            ORDER BY idf.application_id, idf.id_flex_code,
            ifst.id_flex_num, ifsg.application_column_name;

     kff_rec   kff_cur%ROWTYPE;
BEGIN
   internal_init;
   --
   -- WHO columns
   --
   IF (NOT set_get_who(p_session_mode, l_who_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Get the application_id.
   --
   IF (NOT get_application_id(p_appl_short_name,
                              l_application_id, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('application_id : ' || To_char(l_application_id));

   --
   -- Get the old value set.
   --
   IF (NOT get_value_set(p_value_set_from, l_old_vset_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('from_value_set_id : ' || To_char(l_old_vset_rec.flex_value_set_id));

   IF (NOT (l_old_vset_rec.format_type IN ('D', 'T'))) THEN
      message('From value set must be regular type Date or Date/Time.');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Get the new value set.
   --
   IF (NOT get_value_set(p_value_set_to, l_new_vset_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug('to_value_set_id : ' || To_char(l_new_vset_rec.flex_value_set_id));

   IF (NOT (l_new_vset_rec.format_type IN ('X', 'Y'))) THEN
      message('To value set must be standard type Date or Date/Time.');
      RETURN(g_ret_critical_error);
   END IF;


   --
   -- Count the old segments
   --
   l_segs_count := 0;
   FOR kff_rec IN kff_cur(l_application_id,
                          p_id_flex_code,
                          l_old_vset_rec.flex_value_set_id,
                          l_struct_num_like,
                          l_struct_name_like) LOOP
      l_segs_count := l_segs_count + 1;
   END LOOP;
   debug('Number of KFF segments to upgrade : ' || To_char(l_segs_count));

   -- go one-by-one
   FOR i IN 1..l_segs_count LOOP
      --
      -- Since cursor data is changed every time, we will fetch one row
      -- at a time.
      --
      OPEN kff_cur(l_application_id, p_id_flex_code,
                   l_old_vset_rec.flex_value_set_id,
                   l_struct_num_like, l_struct_name_like);
      FETCH kff_cur INTO kff_rec;
      CLOSE kff_cur;
      debug('Modifying:' || p_appl_short_name || ':' ||
            kff_rec.id_flex_code || ':' ||
            kff_rec.id_flex_structure_name || ':' ||
            kff_rec.segment_name);
      l_default_value := kff_rec.default_value;
      IF (kff_rec.default_type = 'C') THEN
         IF (NOT is_to_standard_date(kff_rec.default_value,
                                     l_default_value, l_error)) THEN
            --
            -- If type is constant then default_value is required,
            -- set it to something.
            --
            message(l_error);
            message(l_func_name || chr_newline ||
                    'Default Value is not in proper format.' ||chr_newline||
                    'Default Value : ' ||
                    kff_rec.default_value || chr_newline ||
                    'It is set to 1000/01/01 00:00:00');
            l_default_value := '1000/01/01 00:00:00';
            l_ret_code := g_ret_ignored_errors;
         END IF;
      END IF;

      BEGIN
         UPDATE fnd_id_flex_segments
           SET flex_value_set_id = l_new_vset_rec.flex_value_set_id,
           default_value = l_default_value,
           last_update_date = l_who_rec.last_update_date,
           last_updated_by = l_who_rec.last_updated_by
           WHERE application_id = kff_rec.application_id
           AND id_flex_code = kff_rec.id_flex_code
           AND id_flex_num = kff_rec.id_flex_num
           AND application_column_name = kff_rec.application_column_name;
      EXCEPTION
         WHEN OTHERS THEN
            report_error(l_func_name,
                         'Failure in UPDATE fnd_id_flex_segments.', Sqlerrm);
            l_ret_code := g_ret_ignored_errors;
      END;

      COMMIT;
   END LOOP; -- FOR i IN 1..l_segs_count

   report_success(l_func_name,
                  'KFF segments upgraded for : ' || p_appl_short_name);
   message('Calling !!!COMMIT!!! ...');
   COMMIT;
   RETURN(l_ret_code);
EXCEPTION
   WHEN OTHERS THEN
      report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(g_ret_critical_error);
END upgrade_date_kff_segments;

-- --------------------------------------------------
FUNCTION upgrade_vset_to_translatable
  (p_vset_name        IN VARCHAR2,
   p_session_mode     IN VARCHAR2 DEFAULT 'customer_data')
  RETURN NUMBER
  IS
     l_func_name        VARCHAR2(80) := (g_package_name ||
                                  'upgrade_vset_to_translatable');
     l_ret_code         NUMBER := g_ret_no_error;
     l_ind_vset_rec     vset_rec_type; -- Parent
     l_dep_vset_rec     vset_rec_type; -- Child
     l_who_rec          who_rec_type;
     l_error            VARCHAR2(2000);
     l_trans_msg        VARCHAR2(32000);
     l_num_segs         NUMBER;

     CURSOR dep_vset_cur(p_ind_vset_id IN NUMBER) IS
        SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
          *
          FROM fnd_flex_value_sets
          WHERE validation_type = 'D'
          AND parent_flex_value_set_id = p_ind_vset_id;

     PROCEDURE debug_vset_details(p_vset_rec IN vset_rec_type)
       IS
     BEGIN
        debug('Value Set Details : ');
        debug('Value Set Name  : ' || p_vset_rec.flex_value_set_name);
        debug('Value Set Id    : ' || p_vset_rec.flex_value_set_id);
        debug('Validation Type : ' || p_vset_rec.validation_type);
        debug('Format Type     : ' || p_vset_rec.format_type);
        debug('Maximum Size    : ' || p_vset_rec.maximum_size);
        debug('Minimum Value   : ' || p_vset_rec.minimum_value);
        debug('Maximum Value   : ' || p_vset_rec.maximum_value);
     END;
BEGIN
   internal_init;
   --
   -- WHO columns
   --
   IF (NOT set_get_who(p_session_mode, l_who_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Get the Independent value set.
   --
   IF (NOT get_value_set(p_vset_name, l_ind_vset_rec, l_error)) THEN
      message(l_error);
      RETURN(g_ret_critical_error);
   END IF;
   debug_vset_details(l_ind_vset_rec);

   --
   -- Must be independent.
   --
   IF (l_ind_vset_rec.validation_type <> 'I') THEN
      message('ERROR: Not an Independent value set.');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Must be Character format type.
   --
   IF (l_ind_vset_rec.format_type <> 'C') THEN
      message('ERROR: Not a Character type value set.');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Must be non-secured value set.
   --
   IF (l_ind_vset_rec.security_enabled_flag = 'Y') THEN
      message('ERROR: This value set is a secured value set. ' ||
              'Secured value sets cannot be translatable. ');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Must be alphanumeric allowed.
   --
   IF (l_ind_vset_rec.alphanumeric_allowed_flag = 'N') THEN
      message('ERROR: This value set is a Numbers Only value set. ' ||
              'Numbers only value sets cannot be translatable. ');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Numeric mode must be disabled.
   --
   IF (l_ind_vset_rec.numeric_mode_enabled_flag = 'Y') THEN
      message('ERROR: This value set is a Right Justify Zero Fill value ' ||
              'set. RJZF value sets cannot be translatable. ');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Must not be Upper Case only.
   --
   IF (l_ind_vset_rec.uppercase_only_flag = 'Y') THEN
      message('ERROR: This value set is an Uppercase Only value set. ' ||
              'Uppercase Only value sets cannot be Translatable. ');
      RETURN(g_ret_critical_error);
   END IF;

   --
   -- Do not allow conversion if the vset is attached
   -- to a KFF that does not allow id vsets.
   --
  BEGIN

   SELECT
     count(*)
   INTO
     l_num_segs
   FROM
     fnd_id_flexs f,
     fnd_id_flex_segments s
   WHERE
     s.flex_value_set_id=l_ind_vset_rec.flex_value_set_id AND
     f.application_id=s.application_id AND
     f.id_flex_code=s.id_flex_code AND
     f.allow_id_valuesets='N';

   IF (l_num_segs > 0) THEN

      SELECT
         ' Segment ''' || fifsg.segment_name ||
         ''' Structure ''' || fifst.id_flex_structure_code ||
         ''' Key Flex Code ''' || fif.id_flex_code ||
         ''' Application Id ''' || fif.application_id
      INTO
         l_trans_msg
      FROM
         fnd_id_flexs fif, fnd_id_flex_structures fifst,
         fnd_id_flex_segments fifsg
      WHERE
         fifst.application_id = fif.application_id
         and fifst.id_flex_code = fif.id_flex_code
         and fifsg.application_id = fifst.application_id
         and fifsg.id_flex_code = fifst.id_flex_code
         and fifsg.id_flex_num = fifst.id_flex_num
         and fifsg.flex_value_set_id = l_ind_vset_rec.flex_value_set_id
         and fif.allow_id_valuesets = 'N'
         and rownum = 1;

      message('ERROR: This value set cannot be converted to a ' ||
            'translatable value set because it is attached to ' ||
            l_trans_msg || ' This KFF does not allow id validated value sets.');
      RETURN(g_ret_critical_error);
   END IF;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;

  END;


   --
   -- Make sure Dependent value sets are OK.
   --
   FOR dep_vset_rec IN dep_vset_cur(l_ind_vset_rec.flex_value_set_id) LOOP
      IF (NOT get_value_set(dep_vset_rec.flex_value_set_name,
                            l_dep_vset_rec, l_error)) THEN
         message(l_error);
         RETURN(g_ret_critical_error);
      END IF;
      debug('');
      debug_vset_details(l_dep_vset_rec);
      --
      -- Must be Character format type.
      --
      IF (dep_vset_rec.format_type <> 'C') THEN
         debug('ERROR: ' || dep_vset_rec.flex_value_set_name ||
               ' dependent value set is not Character type.');
         RETURN(g_ret_critical_error);
      END IF;

      --
      -- Must be non-secured value set.
      --
      IF (dep_vset_rec.security_enabled_flag = 'Y') THEN
         message('ERROR: This value set is a secured value set. ' ||
                 'Secured value sets cannot be translatable. ');
         RETURN(g_ret_critical_error);
      END IF;

      --
      -- Must be alphanumeric allowed.
      --
      IF (dep_vset_rec.alphanumeric_allowed_flag = 'N') THEN
         message('ERROR: This value set is a Numbers Only value set. ' ||
                 'Numbers only value sets cannot be translatable. ');
         RETURN(g_ret_critical_error);
      END IF;

      --
      -- Numeric mode must be disabled.
      --
      IF (dep_vset_rec.numeric_mode_enabled_flag = 'Y') THEN
         message('ERROR: This value set is a Right Justify Zero Fill value ' ||
                 'set. RJZF value sets cannot be translatable. ');
         RETURN(g_ret_critical_error);
      END IF;

      --
      -- Must not be Upper Case only.
      --
      IF (dep_vset_rec.uppercase_only_flag = 'Y') THEN
         message('ERROR: This value set is an Uppercase Only value set. ' ||
                 'Uppercase Only value sets cannot be translatable. ');
         RETURN(g_ret_critical_error);
      END IF;

   END LOOP;

   --
   -- Now we can upgrade. First upgrade the dependent vsets.
   --
   FOR dep_vset_rec IN dep_vset_cur(l_ind_vset_rec.flex_value_set_id) LOOP
      UPDATE fnd_flex_value_sets
        SET
        validation_type = 'Y',
        last_update_date = l_who_rec.last_update_date,
        last_updated_by = l_who_rec.last_updated_by
        WHERE flex_value_set_id = dep_vset_rec.flex_value_set_id;
   END LOOP;

   --
   -- Upgrade the independent vset.
   --
   UPDATE fnd_flex_value_sets
     SET
     validation_type = 'X',
     last_update_date = l_who_rec.last_update_date,
     last_updated_by = l_who_rec.last_updated_by
     WHERE flex_value_set_id = l_ind_vset_rec.flex_value_set_id;

   report_success(l_func_name, p_vset_name || ' value set is upgraded' ||
                  ' to Translatable Independent.');
   message('Calling !!!COMMIT!!! ...');
   COMMIT;
   RETURN(l_ret_code);
EXCEPTION
   WHEN OTHERS THEN
      report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN(g_ret_critical_error);
END upgrade_vset_to_translatable;


-- ======================================================================
-- ======================================================================
-- CONCURRENT PROGRAM FUNCTIONS
-- ======================================================================
-- ======================================================================
-- --------------------------------------------------
PROCEDURE cp_debug(p_debug IN VARCHAR2)
  IS
     l_debug     VARCHAR2(32000) := p_debug;
     l_len       NUMBER := Nvl(Length(l_debug),0);
     l_pos       NUMBER;
BEGIN
   IF (p_debug LIKE 'ERROR%') THEN
      g_cp_numof_errors := g_cp_numof_errors + 1;
   END IF;

   WHILE l_len > 0 LOOP
      l_pos := Instr(l_debug, chr_newline, 1, 1);
      IF ((l_pos + g_cp_indent > g_line_size) OR (l_pos = 0)) THEN
         l_pos := g_line_size - g_cp_indent;
         fnd_file.put_line(FND_FILE.LOG,
                           Lpad(' ',g_cp_indent-1,' ') ||
                           Substr(l_debug, 1, l_pos));
       ELSE
         fnd_file.put(FND_FILE.LOG,
                      Lpad(' ',g_cp_indent-1,' ') ||
                      Substr(l_debug, 1, l_pos));
      END IF;

      l_debug := Substr(l_debug, l_pos + 1);
      l_len := Nvl(Length(l_debug),0);
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END cp_debug;

-- --------------------------------------------------
PROCEDURE cp_report_success(p_func_name IN VARCHAR2,
                            p_message   IN VARCHAR2)
  IS
BEGIN
   cp_debug(p_func_name || ' successfully completed.');
   cp_debug('Message:' || Nvl(p_message, 'None'));
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END cp_report_success;

-- --------------------------------------------------
PROCEDURE cp_report_error(p_func_name IN VARCHAR2,
                          p_message IN VARCHAR2,
                          p_sqlerrm IN VARCHAR2)
  IS
BEGIN
   cp_debug('ERROR: ' || set_error(p_func_name, p_message, p_sqlerrm));
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END cp_report_error;

-- --------------------------------------------------
PROCEDURE cp_upgrade_table_column
  (p_mode         IN VARCHAR2,
   p_rows_count   IN NUMBER,
   p_table_name   IN VARCHAR2,
   p_column_name  IN VARCHAR2,
   p_use_bind     IN BOOLEAN,
   p_bind_value   IN VARCHAR2,
   p_sql_select   IN VARCHAR2,
   p_sql_update   IN VARCHAR2,
   x_upg_count    OUT nocopy NUMBER)
  IS
     l_func_name     VARCHAR2(80) := (g_package_name ||
                                      'cp_upgrade_table_column');
     select_cursor   cursor_type;

     l_upg_count     NUMBER := 0;
     j               NUMBER;
     l_last_rowid    ROWID;
     l_rowid         ROWID;

     l_value_old     VARCHAR2(2000);
     l_value_new     VARCHAR2(2000);
     l_error         VARCHAR2(2000);
     l_numof_errors  NUMBER;
     l_many_errors   BOOLEAN;
BEGIN
   --
   -- p_sql_select is something like
   --
   -- SELECT rowid, my_column
   -- FROM (SELECT rowid, my_column
   --       FROM my_table
   --       WHERE (my_column IS NOT NULL)
   --       AND ((:l_last_rowid IS NULL) OR (ROWID > :l_last_rowid))
   --       AND (<my_where_clause>) -- might have bind value
   --       ORDER BY ROWID)
   -- WHERE (ROWNUM <= :b_block_size)
   --
   -- p_sql_update is something like
   --
   -- UPDATE my_table
   -- SET my_column = :l_value_new,
   -- WHO = <WHO>
   -- WHERE ROWID = :l_rowid
   --

   -- go g_block_size-by-g_block_size.

   cp_debug('TABLE.COLUMN:' ||
            p_table_name || '.' ||
            p_column_name||
            ': Rowcount:' || p_rows_count);
   l_numof_errors := 0;
   l_many_errors := FALSE;
   l_upg_count := 0;
   j := 1;
   l_last_rowid := NULL; -- For the first set of fetch.
   WHILE ((j <= p_rows_count) AND (NOT l_many_errors)) LOOP
      IF (p_use_bind) THEN
         OPEN select_cursor FOR p_sql_select USING l_last_rowid, l_last_rowid, p_bind_value, g_block_size;
       ELSE
         OPEN select_cursor FOR p_sql_select USING l_last_rowid, l_last_rowid, g_block_size;
      END IF;

      LOOP
         FETCH select_cursor INTO l_rowid, l_value_old;
         EXIT WHEN select_cursor%NOTFOUND;

         IF (NOT is_to_standard(p_mode, l_value_old,
                                l_value_new, l_error)) THEN
            cp_debug('ERROR: ' || l_error || chr_newline ||
                     'ROWID: ' || l_rowid || chr_newline ||
                     'VALUE: ''' || l_value_old || '''');
            l_numof_errors := l_numof_errors + 1;
         END IF;
         IF (l_value_new <> l_value_old) THEN
            EXECUTE IMMEDIATE p_sql_update USING l_value_new, l_rowid;
            l_upg_count := l_upg_count + 1;
         END IF;

      END LOOP;
      CLOSE select_cursor;
      COMMIT;
      j := j + g_block_size;
      l_last_rowid := l_rowid;
      IF (l_numof_errors > g_max_numof_errors) THEN
         l_many_errors := TRUE;
      END IF;
   END LOOP; -- WHILE (j ...
   IF (l_many_errors) THEN
      cp_debug('ERROR:Too many errors (' || To_char(l_numof_errors) ||
               '), upgrade is aborted.');
   END IF;
   x_upg_count := l_upg_count;
   cp_debug('TABLE.COLUMN:' ||
            p_table_name || '.' ||
            p_column_name ||
            ': Upgcount:' || l_upg_count);
EXCEPTION
   WHEN OTHERS THEN
      x_upg_count := l_upg_count;
      cp_report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
END cp_upgrade_table_column;


-- --------------------------------------------------
PROCEDURE cp_upgrade_value_set_private
  (p_mode         IN VARCHAR2,
   p_vset_rec     IN vset_rec_type,
   p_who_rec      IN who_rec_type)
  IS
     l_func_name         VARCHAR2(80) := (g_package_name ||
                                          'cp_upgrade_value_set_private');

     l_segs_count        NUMBER;
     l_ff_last_rowid     ROWID;
     l_ff_rowid          ROWID;

     l_rows_count        NUMBER;
     j                   NUMBER;

     l_sql_select        VARCHAR2(2000);
     l_sql_update        VARCHAR2(2000);
     l_addtl_where       VARCHAR2(2000);

     vset_rec            vset_rec_type := p_vset_rec;
     l_upg_count         NUMBER;

     l_vc2_tmp1          VARCHAR2(2000);
     l_vc2_tmp2          VARCHAR2(2000);
     l_vc2_tmp3          VARCHAR2(2000);
     l_error             VARCHAR2(2000);

     l_use_bind          BOOLEAN;
     l_bind_value        VARCHAR2(2000);

     CURSOR dff_cur(p_flex_value_set_id IN NUMBER,
                    p_ff_last_rowid IN ROWID)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            df.application_id, df.descriptive_flexfield_name,
            df.table_application_id, df.application_table_name,
            df.context_column_name,
            dfc.descriptive_flex_context_code, dfc.global_flag,
            dfcu.application_column_name, dfcu.end_user_column_name,
            dfcu.default_type, dfcu.default_value, dfcu.ROWID,
            fc.column_type, fc.width
            FROM fnd_descriptive_flexs df, fnd_descr_flex_contexts dfc,
            fnd_descr_flex_column_usages dfcu, fnd_columns fc
            WHERE df.application_id = dfc.application_id
            AND df.descriptive_flexfield_name = dfc.descriptive_flexfield_name
            AND dfc.application_id = dfcu.application_id
            AND dfc.descriptive_flexfield_name = dfcu.descriptive_flexfield_name
            AND dfc.descriptive_flex_context_code = dfcu.descriptive_flex_context_code
            AND ((fc.application_id, fc.table_id) =
                 (SELECT ft.application_id, ft.table_id
                  FROM fnd_tables ft
                  WHERE ft.application_id = df.table_application_id
                  AND ft.table_name = df.application_table_name))
            AND fc.column_name = dfcu.application_column_name
            AND fc.flexfield_usage_code = 'D'
            AND dfcu.flex_value_set_id = p_flex_value_set_id
            AND dfcu.enabled_flag = 'Y'
            AND dfc.enabled_flag = 'Y'
            AND (p_ff_last_rowid IS NULL OR p_ff_last_rowid < dfcu.ROWID)
            ORDER BY dfcu.ROWID;

     dff_rec   dff_cur%ROWTYPE;

     CURSOR kff_cur(p_flex_value_set_id IN NUMBER,
                    p_ff_last_rowid IN ROWID)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            idf.application_id, idf.id_flex_code,
            idf.table_application_id, idf.application_table_name,
            idf.set_defining_column_name, idf.unique_id_column_name,
            ifst.id_flex_num, ifst.id_flex_structure_name,
            ifsg.segment_name, ifsg.application_column_name,
            ifsg.default_type, ifsg.default_value, ifsg.ROWID,
            fc.column_type, fc.width
            FROM fnd_id_flexs idf, fnd_id_flex_structures_vl ifst,
            fnd_id_flex_segments ifsg, fnd_columns fc
            WHERE idf.application_id = ifst.application_id
            AND idf.id_flex_code = ifst.id_flex_code
            AND ifst.application_id = ifsg.application_id
            AND ifst.id_flex_code = ifsg.id_flex_code
            AND ifst.id_flex_num = ifsg.id_flex_num
            AND ((fc.application_id, fc.table_id) =
                 (SELECT ft.application_id, ft.table_id
                  FROM fnd_tables ft
                  WHERE ft.application_id = idf.table_application_id
                  AND ft.table_name = idf.application_table_name))
            AND fc.column_name = ifsg.application_column_name
            AND fc.flexfield_usage_code = 'K'
            AND ifsg.flex_value_set_id = p_flex_value_set_id
            AND ifst.enabled_flag = 'Y'
            AND ifsg.enabled_flag = 'Y'
            AND (p_ff_last_rowid IS NULL OR p_ff_last_rowid < ifsg.ROWID)
              ORDER BY ifsg.ROWID;

     kff_rec   kff_cur%ROWTYPE;

     CURSOR val_cur(p_flex_value_set_id IN NUMBER)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            ROWID, flex_value
            FROM fnd_flex_values
            WHERE flex_value_set_id = p_flex_value_set_id
            ORDER BY flex_value;

     val_rec val_cur%ROWTYPE;

     CURSOR nhier_cur(p_flex_value_set_id IN NUMBER)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            ROWID, parent_flex_value,
            child_flex_value_low, child_flex_value_high
            FROM fnd_flex_value_norm_hierarchy
            WHERE flex_value_set_id = p_flex_value_set_id;

     nhier_rec nhier_cur%ROWTYPE;

     CURSOR hier_cur(p_flex_value_set_id IN NUMBER)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            ROWID, parent_flex_value,
            child_flex_value_low, child_flex_value_high
            FROM fnd_flex_value_hierarchies
            WHERE flex_value_set_id = p_flex_value_set_id;

     hier_rec hier_cur%ROWTYPE;

     CURSOR par_cur(p_flex_value_set_id IN NUMBER)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            ROWID, parent_flex_value_low
            FROM fnd_flex_values
            WHERE flex_value_set_id IN
            (SELECT flex_value_set_id
             FROM fnd_flex_value_sets
             WHERE parent_flex_value_set_id = p_flex_value_set_id
             AND validation_type = 'D');

     par_rec par_cur%ROWTYPE;

     is_id_value_set      BOOLEAN := FALSE;
BEGIN

   EXECUTE IMMEDIATE
     'alter session set sort_area_size = 10000000';

   cp_debug(' ');
   cp_debug('VALUE SET:<id>:<name>:<validation type>:<format type>');
   cp_debug('VALUE SET:' || vset_rec.flex_value_set_id || ':' ||
            vset_rec.flex_value_set_name || ':' ||
            vset_rec.validation_type || ':' ||
            vset_rec.format_type);
   cp_debug('SYSDATE  :' || To_char(Sysdate, g_mask_new));
   cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));

   --
   -- For ID type value sets we store id's in application columns.
   --
   IF (NOT is_id_value_set_success(vset_rec, is_id_value_set, l_error)) THEN
      cp_debug('ERROR: ' || l_error);
      is_id_value_set := TRUE;
   END IF;
   IF (is_id_value_set) THEN
      cp_debug('ID VALUE SET.');
   END IF;

   g_cp_indent := g_cp_indent + 5;
   --
   -- Update minimum, maximum, and dependant_default_value
   --
   IF (NOT is_to_standard(p_mode, vset_rec.minimum_value,
                          l_vc2_tmp1, l_error)) THEN
      cp_debug('ERROR: VSET.MINIMUM_VALUE :' ||
               vset_rec.minimum_value || ': ' || l_error);
   END IF;

   IF (NOT is_to_standard(p_mode, vset_rec.maximum_value,
                          l_vc2_tmp2, l_error)) THEN
      cp_debug('ERROR: VSET.MAXIMUM_VALUE :' ||
               vset_rec.maximum_value || ': ' || l_error);
   END IF;

   IF (NOT is_to_standard(p_mode, vset_rec.dependant_default_value,
                          l_vc2_tmp3, l_error)) THEN
      cp_debug('ERROR: VSET.DEPENDANT_DEFAULT_VALUE :' ||
               vset_rec.dependant_default_value || ': ' || l_error);
   END IF;

   l_upg_count := 0;
   IF (p_mode = g_number_mode) THEN
      --
      -- For number value sets alphanumeric_allowed_flag should be set to 'N'.
      -- If not fix it.
      --
      IF (vset_rec.minimum_value <> l_vc2_tmp1 OR
          vset_rec.maximum_value <> l_vc2_tmp2 OR
          vset_rec.dependant_default_value <> l_vc2_tmp3 OR
          vset_rec.alphanumeric_allowed_flag <> 'N') THEN
         BEGIN
            UPDATE fnd_flex_value_sets
              SET
              alphanumeric_allowed_flag = 'N',
              minimum_value = l_vc2_tmp1,
              maximum_value = l_vc2_tmp2,
              dependant_default_value = l_vc2_tmp3,
              last_update_date = p_who_rec.last_update_date,
              last_updated_by = p_who_rec.last_updated_by
              WHERE flex_value_set_id = vset_rec.flex_value_set_id;
            l_upg_count := SQL%rowcount;
         EXCEPTION
            WHEN OTHERS THEN
               cp_report_error(l_func_name,
                               'Failure in UPDATE FND_FLEX_VALUE_SETS.',
                               Sqlerrm);
         END;
      END IF;
    ELSIF (p_mode = g_date_mode) THEN
         --
         -- For std date value sets, set the flags and maximum size.
         --
      IF (vset_rec.minimum_value <> l_vc2_tmp1 OR
          vset_rec.maximum_value <> l_vc2_tmp2 OR
          vset_rec.dependant_default_value <> l_vc2_tmp3 OR
          vset_rec.maximum_size <> 11 OR
          vset_rec.alphanumeric_allowed_flag <> 'Y' OR
          vset_rec.uppercase_only_flag <> 'Y' OR
          vset_rec.numeric_mode_enabled_flag <> 'N') THEN
         BEGIN
            UPDATE fnd_flex_value_sets
              SET
              maximum_size = 11,
              alphanumeric_allowed_flag = 'Y',
              uppercase_only_flag = 'Y',
              numeric_mode_enabled_flag = 'N',
              minimum_value = l_vc2_tmp1,
              maximum_value = l_vc2_tmp2,
              dependant_default_value = l_vc2_tmp3,
              last_update_date = p_who_rec.last_update_date,
              last_updated_by = p_who_rec.last_updated_by
              WHERE flex_value_set_id = vset_rec.flex_value_set_id;
            l_upg_count := SQL%rowcount;
         EXCEPTION
            WHEN OTHERS THEN
               cp_report_error(l_func_name,
                               'Failure in UPDATE FND_FLEX_VALUE_SETS.',
                               Sqlerrm);
         END;
      END IF;
    ELSIF (p_mode = g_datetime_mode) THEN
         --
         -- For std datetime value sets, set the flags and maximum size.
         --
      IF (vset_rec.minimum_value <> l_vc2_tmp1 OR
          vset_rec.maximum_value <> l_vc2_tmp2 OR
          vset_rec.dependant_default_value <> l_vc2_tmp3 OR
          vset_rec.maximum_size <> 20 OR
          vset_rec.alphanumeric_allowed_flag <> 'Y' OR
          vset_rec.uppercase_only_flag <> 'Y' OR
          vset_rec.numeric_mode_enabled_flag <> 'N') THEN
         BEGIN
            UPDATE fnd_flex_value_sets
              SET
              maximum_size = 20,
              alphanumeric_allowed_flag = 'Y',
              uppercase_only_flag = 'Y',
              numeric_mode_enabled_flag = 'N',
              minimum_value = l_vc2_tmp1,
              maximum_value = l_vc2_tmp2,
              dependant_default_value = l_vc2_tmp3,
              last_update_date = p_who_rec.last_update_date,
              last_updated_by = p_who_rec.last_updated_by
              WHERE flex_value_set_id = vset_rec.flex_value_set_id;
            l_upg_count := SQL%rowcount;
         EXCEPTION
            WHEN OTHERS THEN
               cp_report_error(l_func_name,
                               'Failure in UPDATE FND_FLEX_VALUE_SETS.',
                               Sqlerrm);
         END;
      END IF;
   END IF;
   cp_debug('FND_FLEX_VALUE_SETS:Upg/Count:'||l_upg_count||'/1');
   IF (l_upg_count > 0) THEN
      COMMIT;
   END IF;


   IF (vset_rec.validation_type IN ('I','D','F')) THEN
      --
      -- Update fnd_flex_values table.
      -- Vset must be Ind, Dep, or Table (We store parent values of
      -- Table Vsets in fnd_flex_values table.
      --
      l_rows_count := 0;
      l_upg_count  := 0;
      FOR val_rec IN val_cur(vset_rec.flex_value_set_id) LOOP
         l_rows_count := l_rows_count + 1;
         IF (NOT is_to_standard(p_mode, val_rec.flex_value,
                                l_vc2_tmp1, l_error)) THEN
            cp_debug('ERROR: VAL.FLEX_VALUE :' ||
                     val_rec.flex_value || ': ' || l_error);
         END IF;
         IF (val_rec.flex_value <> l_vc2_tmp1) THEN
            BEGIN
               UPDATE fnd_flex_values
                 SET
                 flex_value = l_vc2_tmp1,
                 last_update_date = p_who_rec.last_update_date,
                 last_updated_by = p_who_rec.last_updated_by
                 WHERE ROWID = val_rec.ROWID;
               l_upg_count := l_upg_count + SQL%rowcount;
            EXCEPTION
               WHEN OTHERS THEN
                  cp_report_error(l_func_name,
                                  'Failure in UPDATE FND_FLEX_VALUES.',
                                  Sqlerrm);
            END;
         END IF;
      END LOOP;
      IF (l_rows_count > 0) THEN
         cp_debug('FND_FLEX_VALUES : Upg/Count : ' ||
                  l_upg_count || '/' || l_rows_count);
         IF (l_upg_count > 0) THEN
            COMMIT;
         END IF;
      END IF;

      l_rows_count := 0;
      l_upg_count := 0;
      FOR nhier_rec IN nhier_cur(vset_rec.flex_value_set_id) LOOP
         l_rows_count := l_rows_count + 1;
         IF (NOT is_to_standard(p_mode, nhier_rec.parent_flex_value,
                                l_vc2_tmp1, l_error)) THEN
            cp_debug('ERROR: NHIER.PARENT_FLEX_VALUE :' ||
                     nhier_rec.parent_flex_value || ': ' || l_error);
         END IF;
         IF (NOT is_to_standard(p_mode, nhier_rec.child_flex_value_low,
                                l_vc2_tmp2, l_error)) THEN
            cp_debug('ERROR: NHIER.CHILD_FLEX_VALUE_LOW :' ||
                     nhier_rec.child_flex_value_low || ': ' || l_error);
         END IF;
         IF (NOT is_to_standard(p_mode, nhier_rec.child_flex_value_high,
                                l_vc2_tmp3, l_error)) THEN
            cp_debug('ERROR: NHIER.CHILD_FLEX_VALUE_HIGH :' ||
                     nhier_rec.child_flex_value_high || ': ' || l_error);
         END IF;

         IF (nhier_rec.parent_flex_value <> l_vc2_tmp1 OR
             nhier_rec.child_flex_value_low <> l_vc2_tmp2 OR
             nhier_rec.child_flex_value_high <> l_vc2_tmp3) THEN
            BEGIN
               UPDATE fnd_flex_value_norm_hierarchy
                 SET
                 parent_flex_value = l_vc2_tmp1,
                 child_flex_value_low = l_vc2_tmp2,
                 child_flex_value_high = l_vc2_tmp3,
                 last_update_date = p_who_rec.last_update_date,
                 last_updated_by = p_who_rec.last_updated_by
                 WHERE ROWID = nhier_rec.ROWID;
               l_upg_count := l_upg_count + SQL%rowcount;
            EXCEPTION
               WHEN OTHERS THEN
                  cp_report_error(l_func_name,
                                  'Failure in UPDATE FND_FLEX_VALUE_NORM_HIERARCHY.',
                                  Sqlerrm);
            END;
         END IF;
      END LOOP;
      IF (l_rows_count > 0) THEN
         cp_debug('FND_FLEX_VALUE_NORM_HIERARCHY : Upg/Count : ' ||
                  l_upg_count || '/' || l_rows_count);
         IF (l_upg_count > 0) THEN
            COMMIT;
         END IF;
      END IF;

      l_rows_count := 0;
      l_upg_count := 0;
      FOR hier_rec IN hier_cur(vset_rec.flex_value_set_id) LOOP
         l_rows_count := l_rows_count + 1;
         IF (NOT is_to_standard(p_mode, hier_rec.parent_flex_value,
                                l_vc2_tmp1, l_error)) THEN
            cp_debug('ERROR: HIER.PARENT_FLEX_VALUE :' ||
                     hier_rec.parent_flex_value || ': ' || l_error);
         END IF;
         IF (NOT is_to_standard(p_mode, hier_rec.child_flex_value_low,
                                l_vc2_tmp2, l_error)) THEN
            cp_debug('ERROR: HIER.CHILD_FLEX_VALUE_LOW :' ||
                     hier_rec.child_flex_value_low || ': ' || l_error);
         END IF;
         IF (NOT is_to_standard(p_mode, hier_rec.child_flex_value_high,
                                l_vc2_tmp3, l_error)) THEN
            cp_debug('ERROR: HIER.CHILD_FLEX_VALUE_HIGH :' ||
                     hier_rec.child_flex_value_high || ': ' || l_error);
         END IF;

         IF (hier_rec.parent_flex_value <> l_vc2_tmp1 OR
             hier_rec.child_flex_value_low <> l_vc2_tmp2 OR
             hier_rec.child_flex_value_high <> l_vc2_tmp3) THEN
            BEGIN
               UPDATE fnd_flex_value_hierarchies
                 SET
                 parent_flex_value = l_vc2_tmp1,
                 child_flex_value_low = l_vc2_tmp2,
                 child_flex_value_high = l_vc2_tmp3,
                 last_update_date = p_who_rec.last_update_date,
                 last_updated_by = p_who_rec.last_updated_by
                 WHERE ROWID = hier_rec.ROWID;
               l_upg_count := l_upg_count + SQL%rowcount;
            EXCEPTION
               WHEN OTHERS THEN
                  cp_report_error(l_func_name,
                                  'Failure in UPDATE FND_FLEX_VALUE_HIERARCHIES.',
                                  Sqlerrm);
            END;
         END IF;
      END LOOP;
      IF (l_rows_count > 0) THEN
         cp_debug('FND_FLEX_VALUE_HIERARCHIES : Upg/Count : ' ||
                  l_upg_count || '/' || l_rows_count);
         IF (l_upg_count > 0) THEN
            COMMIT;
         END IF;
      END IF;

   END IF;

   --
   -- Is this value set used as an independent value set by another
   -- dependent value set?
   -- If so, update parent_flex_value_low column.
   --
   IF (vset_rec.validation_type = 'I') THEN
      l_rows_count := 0;
      l_upg_count := 0;
      FOR par_rec IN par_cur(vset_rec.flex_value_set_id) LOOP
         l_rows_count := l_rows_count + 1;
         IF (NOT is_to_standard(p_mode, par_rec.parent_flex_value_low,
                                l_vc2_tmp1, l_error)) THEN
            cp_debug('ERROR: PAR.PARENT_FLEX_VALUE_LOW :' ||
                     par_rec.parent_flex_value_low || ': ' || l_error);
         END IF;
         IF (par_rec.parent_flex_value_low <> l_vc2_tmp1) THEN
            BEGIN
               UPDATE fnd_flex_values
                 SET
                 parent_flex_value_low = l_vc2_tmp1,
                 last_update_date = p_who_rec.last_update_date,
                 last_updated_by = p_who_rec.last_updated_by
                 WHERE ROWID = par_rec.ROWID;
               l_upg_count := l_upg_count + SQL%rowcount;
            EXCEPTION
               WHEN OTHERS THEN
                  cp_report_error(l_func_name,
                                  'Failure in UPDATE PARENT FND_FLEX_VALUES.',
                                  Sqlerrm);
            END;
         END IF;
      END LOOP;
      IF (l_rows_count > 0) THEN
         cp_debug('PARENT FND_FLEX_VALUES : Upg/Count : ' ||
                  l_upg_count || '/' || l_rows_count);
         IF (l_upg_count > 0) THEN
            COMMIT;
         END IF;
      END IF;

   END IF;

   --
   -- Fix DFF.
   --
   --
   -- Count the segments, this includes $SRS$ DFFs.
   --
   l_segs_count := 0;
   FOR dff_rec IN dff_cur(vset_rec.flex_value_set_id, NULL) LOOP
      l_segs_count := l_segs_count + 1;
   END LOOP;
   IF (l_segs_count > 0) THEN
      cp_debug('Upgrading Descriptive Flexfields.');
      cp_debug('Number of DFF segments:'|| To_char(l_segs_count));
      cp_debug('DFF:<app id>:<name>:<context code>:<column name>:<user name>');
      cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));
   END IF;
   g_cp_indent := g_cp_indent + 10;

   -- go one-by-one
   l_ff_last_rowid := NULL;
   FOR i IN 1..l_segs_count LOOP
      --
      -- Since cursor data is changed every time, we will fetch one row
      -- at a time.
      --
      OPEN dff_cur(vset_rec.flex_value_set_id, l_ff_last_rowid);
      FETCH dff_cur INTO dff_rec;
      CLOSE dff_cur;
      l_ff_last_rowid := dff_rec.ROWID;

      g_cp_indent := g_cp_indent - 5;
      cp_debug('DFF:' || dff_rec.application_id || ':' ||
               dff_rec.descriptive_flexfield_name || ':' ||
               dff_rec.descriptive_flex_context_code || ':' ||
               dff_rec.application_column_name || ':' ||
               dff_rec.end_user_column_name);
      g_cp_indent := g_cp_indent + 5;

      IF (dff_rec.default_type = 'C') THEN
         IF (NOT is_to_standard(p_mode, dff_rec.default_value,
                                l_vc2_tmp1, l_error)) THEN
            cp_debug('ERROR: DFF.DEFAULT_VALUE :' ||
                     dff_rec.default_value || ': ' || l_error);
         END IF;
         IF (dff_rec.default_value <> l_vc2_tmp1) THEN
            BEGIN
               UPDATE fnd_descr_flex_column_usages
                 SET
                 default_value = l_vc2_tmp1,
                 last_update_date = p_who_rec.last_update_date,
                 last_updated_by = p_who_rec.last_updated_by
                 WHERE application_id = dff_rec.application_id
                 AND descriptive_flexfield_name = dff_rec.descriptive_flexfield_name
                 AND descriptive_flex_context_code = dff_rec.descriptive_flex_context_code
                 AND application_column_name = dff_rec.application_column_name;
               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  cp_report_error
                    (l_func_name,
                     'Failure in UPDATE FND_DESCR_FLEX_COLUMN_USAGES.',
                     Sqlerrm);
            END;
         END IF;
      END IF;
      --
      -- Now we need to upgrade underlying application table.
      --
      -- FND_SRS_MASTER is a fake table.
      --
      -- C: Char, U: Varchar, V: Varchar2
      --
      IF ((Substr(dff_rec.descriptive_flexfield_name,1,6) <> '$SRS$.') AND
          (dff_rec.column_type IN ('C', 'U', 'V')) AND
          ((p_mode IN (g_date_mode, g_datetime_mode) AND
            dff_rec.width >= 20) OR
           (p_mode NOT IN (g_date_mode, g_datetime_mode))) AND
          (NOT is_id_value_set) AND
          (NOT is_fake_table(dff_rec.table_application_id, dff_rec.application_table_name))) THEN
         --
         -- First count the rows.
         --
         l_rows_count := 0;
         l_sql_select := ('SELECT COUNT(*)' ||
                          ' FROM ' || dff_rec.application_table_name ||
                          ' WHERE (''/* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */'' IS NOT NULL)');

         l_addtl_where := (' AND (' || dff_rec.application_column_name ||
                           ' IS NOT NULL)');

         IF (p_mode = g_number_mode) THEN
            l_addtl_where := l_addtl_where ||
              ' AND (RTRIM(' || dff_rec.application_column_name ||
              ', ''0123456789'') IS NOT NULL)';
         END IF;

         --
         -- Non-Global Contexts.
         --
         IF (dff_rec.global_flag = 'N') THEN
            l_use_bind := TRUE;
            l_bind_value := dff_rec.descriptive_flex_context_code;
            l_addtl_where := l_addtl_where ||
              ' AND (' || dff_rec.context_column_name || ' = :b_bind_value)';
          ELSE
            l_use_bind := FALSE;
         END IF;

         l_sql_select := l_sql_select || l_addtl_where;

         BEGIN
            IF (l_use_bind) THEN
               EXECUTE IMMEDIATE l_sql_select INTO l_rows_count USING l_bind_value;
             ELSE
               EXECUTE IMMEDIATE l_sql_select INTO l_rows_count;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               l_rows_count := 0;
               cp_report_error(l_func_name, 'DFF:Count(*) failed. ' ||
                               'TABLE.COL:'|| dff_rec.application_table_name ||
                               '.' || dff_rec.application_column_name,
                               Sqlerrm);
         END;

         --
         -- Construct the SELECT and UPDATE statements.
         --
         IF (l_rows_count > 0) THEN
            l_sql_select :=
              'SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */ ' ||
              ' ROWID, ' || dff_rec.application_column_name ||
              ' FROM ' ||
              '(SELECT ROWID, ' || dff_rec.application_column_name ||
              ' FROM ' || dff_rec.application_table_name ||
              ' WHERE ((:l_last_rowid IS NULL) OR (ROWID > :l_last_rowid))';

            l_sql_select := l_sql_select || l_addtl_where;
            l_sql_select := l_sql_select || ' ORDER BY ROWID)';
            l_sql_select := l_sql_select || ' WHERE (ROWNUM <= :b_block_size)';

            l_sql_update := get_sql_update(dff_rec.application_id,
                                           dff_rec.application_table_name,
                                           dff_rec.application_column_name,
                                           p_who_rec);

            cp_upgrade_table_column(p_mode, l_rows_count,
                                    dff_rec.application_table_name,
                                    dff_rec.application_column_name,
                                    l_use_bind, l_bind_value,
                                    l_sql_select, l_sql_update, l_upg_count);

         END IF; -- (l_rows_count > 0)
      END IF; -- Upgrade table.
   END LOOP; -- FOR i IN 1..l_segs_count

   --
   -- Fix KFF
   --
   --
   -- Count the segments.
   --
   l_segs_count := 0;
   FOR kff_rec IN kff_cur(vset_rec.flex_value_set_id, NULL) LOOP
      l_segs_count := l_segs_count + 1;
   END LOOP;

   g_cp_indent := g_cp_indent - 10;
   IF (l_segs_count > 0) THEN
      cp_debug('Upgrading Key Flexfields.');
      cp_debug('Number of KFF segments:' || To_char(l_segs_count));
      cp_debug('KFF:<app id>:<code>:<str num>:<str name>:<column name>:<segment name>');
      cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));
   END IF;
   g_cp_indent := g_cp_indent + 10;


   -- go one-by-one
   l_ff_last_rowid := NULL;
   FOR i IN 1..l_segs_count LOOP
      --
      -- Since cursor data is changed every time, we will fetch one row
      -- at a time.
      --
      OPEN kff_cur(vset_rec.flex_value_set_id, l_ff_last_rowid);
      FETCH kff_cur INTO kff_rec;
      CLOSE kff_cur;
      l_ff_last_rowid := kff_rec.ROWID;

      g_cp_indent := g_cp_indent - 5;
      cp_debug('KFF:' || kff_rec.application_id || ':' ||
               kff_rec.id_flex_code || ':' ||
               kff_rec.id_flex_num || ':' ||
               kff_rec.id_flex_structure_name || ':' ||
               kff_rec.application_column_name || ':' ||
               kff_rec.segment_name);
      g_cp_indent := g_cp_indent + 5;

      IF (kff_rec.default_type = 'C') THEN
         IF (NOT is_to_standard(p_mode, kff_rec.default_value,
                                l_vc2_tmp1, l_error)) THEN
            cp_debug('ERROR: KFF.DEFAULT_VALUE :' ||
                     kff_rec.default_value || ': ' || l_error);
         END IF;
         IF (dff_rec.default_value <> l_vc2_tmp1) THEN
            BEGIN
               UPDATE fnd_id_flex_segments
                 SET
                 default_value = l_vc2_tmp1,
                 last_update_date = p_who_rec.last_update_date,
                 last_updated_by = p_who_rec.last_updated_by
                 WHERE application_id = kff_rec.application_id
                 AND id_flex_code = kff_rec.id_flex_code
                 AND id_flex_num = kff_rec.id_flex_num
                 AND application_column_name = kff_rec.application_column_name;
               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  cp_report_error(l_func_name,
                                  'Failure in UPDATE FND_ID_FLEX_SEGMENTS.',
                                  Sqlerrm);
            END;
         END IF;
      END IF;

      --
      -- Now we need to upgrade underlying application table.
      --
      -- C: Char, U: Varchar, V: Varchar2
      --
      -- KFF tables cannot be fake tables.
      --
      IF ((kff_rec.column_type IN ('C', 'U', 'V')) AND
          ((p_mode IN (g_date_mode, g_datetime_mode) AND
            kff_rec.width >= 20) OR
           (p_mode NOT IN (g_date_mode, g_datetime_mode))) AND
          (NOT is_id_value_set)) THEN
         --
         -- First count the rows.
         --
         l_rows_count := 0;
         l_sql_select := ('SELECT COUNT(*)' ||
                          ' FROM ' || kff_rec.application_table_name ||
                          ' WHERE (''/* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */'' IS NOT NULL)');

         l_addtl_where := (' AND (' || kff_rec.application_column_name ||
                           ' IS NOT NULL)');

         IF (p_mode = g_number_mode) THEN
            l_addtl_where := l_addtl_where ||
              ' AND (RTRIM(' || kff_rec.application_column_name ||
              ', ''0123456789'') IS NOT NULL)';
         END IF;

         --
         -- These are single structure key flexfields.
         --
         IF ((kff_rec.set_defining_column_name IS NULL) OR
             ((kff_rec.application_id = 401) AND (kff_rec.id_flex_code = 'MSTK')) OR
             ((kff_rec.application_id = 401) AND (kff_rec.id_flex_code = 'MTLL')) OR
             ((kff_rec.application_id = 401) AND (kff_rec.id_flex_code = 'MICG')) OR
             ((kff_rec.application_id = 401) AND (kff_rec.id_flex_code = 'MDSP')) OR
             ((kff_rec.application_id = 401) AND (kff_rec.id_flex_code = 'SERV'))) THEN
            l_use_bind := FALSE;
          ELSE
            l_use_bind := TRUE;
            l_bind_value := To_char(kff_rec.id_flex_num);
            l_addtl_where := l_addtl_where ||
              ' AND (' || kff_rec.set_defining_column_name ||
              ' = to_number(:b_bind_value))';
         END IF;

         l_sql_select := l_sql_select || l_addtl_where;

         BEGIN
            IF (l_use_bind) THEN
               EXECUTE IMMEDIATE l_sql_select INTO l_rows_count USING l_bind_value;
             ELSE
               EXECUTE IMMEDIATE l_sql_select INTO l_rows_count;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               l_rows_count := 0;
               cp_report_error(l_func_name,'KFF:Count(*) failed. ' ||
                               'TABLE.COL:'|| kff_rec.application_table_name ||
                               '.' || kff_rec.application_column_name,
                               Sqlerrm);
         END;

         --
         -- Construct the SELECT and UPDATE statements.
         --
         IF (l_rows_count > 0) THEN
            l_sql_select :=
              'SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */ ' ||
              ' ROWID, ' || kff_rec.application_column_name ||
              ' FROM ' ||
              '(SELECT ROWID, ' || kff_rec.application_column_name ||
              ' FROM ' || kff_rec.application_table_name ||
              ' WHERE ((:l_last_rowid IS NULL) OR (ROWID > :l_last_rowid))';

            l_sql_select := l_sql_select || l_addtl_where;
            l_sql_select := l_sql_select || ' ORDER BY ROWID)';
            l_sql_select := l_sql_select || ' WHERE (ROWNUM <= :b_block_size)';

            l_sql_update := get_sql_update(kff_rec.application_id,
                                           kff_rec.application_table_name,
                                           kff_rec.application_column_name,
                                           p_who_rec);

            cp_upgrade_table_column(p_mode, l_rows_count,
                                    kff_rec.application_table_name,
                                    kff_rec.application_column_name,
                                    l_use_bind, l_bind_value,
                                    l_sql_select, l_sql_update, l_upg_count);
         END IF;

      END IF; -- Upgrade table.
   END LOOP; -- FOR i IN 1..l_segs_count
EXCEPTION
   WHEN OTHERS THEN
      cp_report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN;
END cp_upgrade_value_set_private;


-- ----------------------------------------------------------
-- FNDFFUPG CP Public Procedures.
-- ----------------------------------------------------------
------------------------------------------------------------
PROCEDURE cp_init(p_param_name IN VARCHAR2,
                  p_param_value IN VARCHAR2)
  IS
     l_func_name  VARCHAR2(80) := g_package_name || 'cp_init';
     l_param_name VARCHAR2(100) := Upper(p_param_name);
     l_error      VARCHAR2(2000);
BEGIN
   IF (l_param_name IS NULL) THEN
      cp_report_error(l_func_name, 'Parameter name cannot be NULL.', NULL);
      RAISE bad_parameter;
    ELSIF (l_param_name = 'SESSION_MODE') THEN
      IF (NOT set_who(Nvl(p_param_value, 'customer_data'), l_error)) THEN
         cp_report_error(l_func_name, l_error, NULL);
         RAISE bad_parameter;
      END IF;
      cp_debug('DEBUG: SESSION_MODE : ' || g_session_mode);
    ELSIF (l_param_name = 'NLS_NUMERIC_CHARACTERS') THEN
      IF (NOT set_nls_numeric_characters(p_param_value, l_error)) THEN
         cp_report_error(l_func_name, l_error, NULL);
         RAISE bad_parameter;
      END IF;
      cp_debug('DEBUG: NLS_NUMERIC_CHARACTERS : ' || g_nls_chars);
    ELSE
      cp_report_error(l_func_name,
                      'Unknown parameter : ' || p_param_name,
                      NULL);
      RAISE bad_parameter;
   END IF;
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      cp_report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RAISE;
END cp_init;

------------------------------------------------------------
PROCEDURE cp_upgrade_value_set(p_flex_value_set_type IN VARCHAR2,
                               p_flex_value_set_name IN VARCHAR2)
  IS
     l_func_name VARCHAR2(80) := g_package_name || 'cp_upgrade_value_set';
     l_who_rec   who_rec_type;
     l_vset_rec  vset_rec_type;
     l_error     VARCHAR2(2000);
BEGIN
   internal_init;
   --
   -- WHO columns.
   --
   IF (NOT get_who(l_who_rec, l_error)) THEN
      cp_debug('ERROR: ' || l_error);
      RETURN;
   END IF;

   --
   -- Get value set.
   --
   IF (NOT get_value_set(p_flex_value_set_name, l_vset_rec, l_error)) THEN
      cp_debug('ERROR: ' || l_error);
      RETURN;
   END IF;

   IF (p_flex_value_set_type = 'DATE') THEN
      IF (l_vset_rec.format_type = 'X') THEN
         cp_upgrade_value_set_private(g_date_mode, l_vset_rec, l_who_rec);
       ELSIF (l_vset_rec.format_type = 'Y') THEN
         cp_upgrade_value_set_private(g_datetime_mode, l_vset_rec, l_who_rec);
       ELSE
         cp_report_error(l_func_name,
                         'Not a Date or DateTime value set.', NULL);
      END IF;
    ELSIF (p_flex_value_set_type = 'NUMBER') THEN
      IF (l_vset_rec.format_type = 'N') THEN
         cp_upgrade_value_set_private(g_number_mode, l_vset_rec, l_who_rec);
       ELSIF (l_vset_rec.format_type = 'C' AND
              l_vset_rec.alphanumeric_allowed_flag = 'N') THEN
         cp_upgrade_value_set_private(g_number_mode, l_vset_rec, l_who_rec);
       ELSE
         cp_report_error(l_func_name,
                         'Not a Number value set.', NULL);
      END IF;
    ELSE
      cp_report_error(l_func_name,
                      'Unknown value set type : ' || p_flex_value_set_type,
                      NULL);
   END IF;
   COMMIT;
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      cp_report_error(l_func_name, 'Top Level Exception.', Sqlerrm);
      RETURN;
END cp_upgrade_value_set;

-- ----------------------------------------------------------
-- FNDFFUPG CP SRS Procedures.
-- ----------------------------------------------------------

-- ======================================================================
PROCEDURE cp_srs_upgrade_all_private(errbuf            OUT nocopy VARCHAR2,
                                     retcode           OUT nocopy VARCHAR2,
                                     p_sub_program     IN VARCHAR2,
                                     p_sub_description IN VARCHAR2,
                                     p_sql_select      IN VARCHAR2)
  IS
     l_flex_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
     l_request_id          NUMBER;
     l_sub_request_id      NUMBER;
     l_request_count       NUMBER;
     i                     NUMBER;
     l_request_data        VARCHAR2(100);
     l_sub_requests        fnd_concurrent.requests_tab_type;
     l_action_message      VARCHAR2(200);
     l_normal_count        NUMBER := 0;
     l_warning_count       NUMBER := 0;
     l_error_count         NUMBER := 0;
     l_vset_cur            cursor_type;
BEGIN
   l_request_id := fnd_global.conc_request_id;
   l_request_data := fnd_conc_global.request_data;

   cp_debug('DEBUG: Request Id   : ' || l_request_id);
   cp_debug('DEBUG: Request Data : ' || l_request_data);
   cp_debug(' ');

   IF (l_request_data IS NULL) THEN
      --
      -- Print the header.
      --
      cp_debug(Lpad('Request ID', 10) || ' ' ||
               Rpad('Value Set Name', 60));
      cp_debug(Lpad('-',10, '-') || ' ' ||
               Rpad('-',60, '-'));

      BEGIN
         OPEN l_vset_cur FOR p_sql_select;
         l_request_count := 0;
         LOOP
            FETCH l_vset_cur INTO l_flex_value_set_name;
            EXIT WHEN l_vset_cur%NOTFOUND;
            l_request_count := l_request_count + 1;

            IF (p_sub_program = 'FNDFFUPG_DATE_ONE') THEN
               l_sub_request_id := fnd_request.submit_request
                 (application => 'FND',
                  program     => p_sub_program,
                  description => p_sub_description ||' : '|| l_flex_value_set_name,
                  start_time  => NULL,
                  sub_request => TRUE,
                  argument1   => l_flex_value_set_name);
             ELSIF (p_sub_program = 'FNDFFUPG_NUMBER_ONE') THEN
               l_sub_request_id := fnd_request.submit_request
                 (application => 'FND',
                  program     => p_sub_program,
                  description => p_sub_description ||' : '|| l_flex_value_set_name,
                  start_time  => NULL,
                  sub_request => TRUE,
                  argument1   => l_flex_value_set_name,
                  argument2   => g_nls_chars);
            END IF;

            cp_debug(Lpad(l_sub_request_id, 10) || ' ' ||
                     Rpad(l_flex_value_set_name, 60));

            IF (l_sub_request_id = 0) THEN
               cp_debug('ERROR   : Unable to submit sub request.');
               cp_debug('MESSAGE : ' || fnd_message.get);
            END IF;
         END LOOP;
         CLOSE l_vset_cur;
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_vset_cur%isopen) THEN
               CLOSE l_vset_cur;
            END IF;
            RAISE;
      END;

      l_request_count := Nvl(l_request_count, 0);

      fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                                      request_data => To_char(l_request_count));

      errbuf := l_request_count || ' sub request(s) submitted.';
      cp_debug(' ');
      cp_debug(errbuf);
      cp_debug(' ');
      retcode := 0;
      RETURN;
    ELSE
      l_request_count := To_number(l_request_data);

      cp_debug(l_request_count || ' sub request(s) completed.');
      --
      -- Print the header.
      --
      cp_debug(' ');
      cp_debug('Status Report');
      cp_debug(Rpad('-',72,'-'));
      cp_debug(Lpad('Request ID', 10) || ' ' ||
               Rpad('Status', 10) || ' ' ||
               Rpad('Action', 50));
      cp_debug(Lpad('-',10, '-') || ' ' ||
               Lpad('-',10, '-') || ' ' ||
               Lpad('-',50, '-'));

      l_sub_requests := fnd_concurrent.get_sub_requests(l_request_id);
      i := l_sub_requests.first;
      WHILE i IS NOT NULL LOOP
         IF (l_sub_requests(i).dev_status = 'NORMAL') THEN
            l_normal_count := l_normal_count + 1;
            l_action_message := 'Completed successfully.';
          ELSIF (l_sub_requests(i).dev_status = 'WARNING') THEN
            l_warning_count := l_warning_count + 1;
            l_action_message := 'Warnings reported, please see the sub-request log file.';
          ELSIF (l_sub_requests(i).dev_status = 'ERROR') THEN
            l_error_count := l_error_count + 1;
            l_action_message := 'Errors reported, please see the sub-request log file.';
          ELSE
            l_error_count := l_error_count + 1;
            l_action_message := 'Unknown status reported, please see the sub-request log file.';
         END IF;
         cp_debug(Lpad(l_sub_requests(i).request_id, 10) || ' ' ||
                  Rpad(l_sub_requests(i).dev_status, 10) || ' ' ||
                  l_action_message);
         i := l_sub_requests.next(i);
      END LOOP;
      cp_debug(' ');
      cp_debug('Summary Report');
      cp_debug(Rpad('-',72,'-'));
      cp_debug(Rpad('Status', 20) || ' ' ||
               Rpad('Count', 10));
      cp_debug(Rpad('-', 20, '-') || ' ' ||
               Rpad('-', 10, '-'));
      cp_debug(Rpad('Normal', 20) || ' ' ||
               Rpad(l_normal_count, 10));
      cp_debug(Rpad('Warning', 20) || ' ' ||
               Rpad(l_warning_count, 10));
      cp_debug(Rpad('Error', 20) || ' ' ||
               Rpad(l_error_count, 10));
      cp_debug(Rpad('-', 20, '-') || ' ' ||
               Rpad('-', 10, '-'));
      cp_debug(Rpad('Total', 20) || ' ' ||
               Rpad(l_sub_requests.COUNT, 10));
      cp_debug(' ');
      errbuf := l_sub_requests.COUNT || ' sub request(s) completed.';
      IF (l_error_count > 0) THEN
         retcode := 2;
       ELSIF (l_warning_count > 0) THEN
         retcode := 1;
       ELSE
         retcode := 0;
      END IF;
      RETURN;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_upgrade_all_private:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_upgrade_all_private;

-- ======================================================================
-- Procedure : cp_srs_upgrade_date_all
-- ======================================================================
-- Upgrades Date Value Sets. (called from SRS form.)
--
PROCEDURE cp_srs_upgrade_date_all(errbuf  OUT nocopy VARCHAR2,
                                  retcode OUT nocopy VARCHAR2)
  IS
     l_sql VARCHAR2(1000) :=
       ('SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */ ' ||
        '       flex_value_set_name ' ||
        '  FROM fnd_flex_value_sets ' ||
        ' WHERE format_type IN (''X'', ''Y'')');
BEGIN
   internal_init;
   cp_debug('Upgrading All Standard Date and Standard DateTime Value Sets.');
   cp_debug(' ');

   cp_init('SESSION_MODE','customer_data');

   cp_srs_upgrade_all_private
     (errbuf            => errbuf,
      retcode           => retcode,
      p_sub_program     => 'FNDFFUPG_DATE_ONE',
      p_sub_description => 'Flexfields Upgrade One Standard Date or Standard Date Time Value Set.',
      p_sql_select      => l_sql );
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_upgrade_date_all:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_upgrade_date_all;

-- ======================================================================
-- Procedure : cp_srs_upgrade_number_all
-- ======================================================================
-- Upgrades All Number Value Sets. (called from SRS.)
--
PROCEDURE cp_srs_upgrade_number_all(errbuf                   OUT nocopy VARCHAR2,
                                    retcode                  OUT nocopy VARCHAR2,
                                    p_nls_numeric_characters IN VARCHAR2)
  IS
     l_sql VARCHAR2(1000) :=
       ('SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */ ' ||
        '       flex_value_set_name ' ||
        '  FROM fnd_flex_value_sets ' ||
        ' WHERE (format_type = ''N'' OR ' ||
        '       (format_type = ''C'' AND ' ||
        '        alphanumeric_allowed_flag = ''N''))');
BEGIN
   internal_init;
   cp_debug('Upgrading All Number Value Sets.');
   cp_debug(' ');

   cp_init('SESSION_MODE','customer_data');
   cp_init('NLS_NUMERIC_CHARACTERS', p_nls_numeric_characters);

   cp_srs_upgrade_all_private
     (errbuf            => errbuf,
      retcode           => retcode,
      p_sub_program     => 'FNDFFUPG_NUMBER_ONE',
      p_sub_description => 'Flexfields Upgrade One Number Value Set.',
      p_sql_select      => l_sql);
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_upgrade_number_all:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_upgrade_number_all;

-- ======================================================================
PROCEDURE cp_srs_upgrade_one_private(errbuf                OUT nocopy VARCHAR2,
                                     retcode               OUT nocopy VARCHAR2,
                                     p_flex_value_set_type IN VARCHAR2,
                                     p_flex_value_set_name IN VARCHAR2)
  IS
BEGIN
   cp_debug('DEBUG: Value Set  : ' || p_flex_value_set_name);
   cp_debug('DEBUG: Request Id : ' || fnd_global.conc_request_id);

   cp_upgrade_value_set(p_flex_value_set_type, p_flex_value_set_name);

   g_cp_indent := 1;
   cp_debug(' ');
   cp_debug('Total ' || g_cp_numof_errors || ' error(s) reported.');
   cp_debug(' ');

   IF (g_cp_numof_errors > 0) THEN
      retcode := 2;
      errbuf := 'FNDFFUPG_' || p_flex_value_set_type || '_ONE failed. Please see the log file for details.';
    ELSE
      retcode := 0;
      errbuf := 'FNDFFUPG_' || p_flex_value_set_type || '_ONE completed successfully.';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_upgrade_one_private:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_upgrade_one_private;

-- ======================================================================
-- Procedure : cp_srs_upgrade_date_one
-- ======================================================================
-- Upgrades One Standard Date Value Set. (called from SRS.)
--
PROCEDURE cp_srs_upgrade_date_one(errbuf                OUT nocopy VARCHAR2,
                                  retcode               OUT nocopy VARCHAR2,
                                  p_flex_value_set_name IN VARCHAR2)
  IS
BEGIN
   internal_init;
   cp_debug('Upgrading One Standard Date or Standard DateTime Value Set.');
   cp_debug(' ');

   cp_init('SESSION_MODE','customer_data');

   cp_srs_upgrade_one_private(errbuf                => errbuf,
                              retcode               => retcode,
                              p_flex_value_set_type => 'DATE',
                              p_flex_value_set_name => p_flex_value_set_name);
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_upgrade_date_one:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_upgrade_date_one;

-- ======================================================================
-- Procedure : cp_srs_upgrade_number_one
-- ======================================================================
-- Upgrades One Number Value Set. (called from SRS.)
--
PROCEDURE cp_srs_upgrade_number_one(errbuf                   OUT nocopy VARCHAR2,
                                    retcode                  OUT nocopy VARCHAR2,
                                    p_flex_value_set_name    IN VARCHAR2,
                                    p_nls_numeric_characters IN VARCHAR2)
  IS
BEGIN
   internal_init;
   cp_debug('Upgrading One Number Value Set.');
   cp_debug(' ');

   cp_init('SESSION_MODE','customer_data');
   cp_init('NLS_NUMERIC_CHARACTERS', p_nls_numeric_characters);

   cp_srs_upgrade_one_private(errbuf                => errbuf,
                              retcode               => retcode,
                              p_flex_value_set_type => 'NUMBER',
                              p_flex_value_set_name => p_flex_value_set_name);
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_upgrade_number_one:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_upgrade_number_one;

-- ======================================================================
-- Procedure : cp_srs_list_date_usages
-- ======================================================================
-- Lists Date and DateTime Value Set Usages. (called from SRS.)
--
PROCEDURE cp_srs_list_date_usages(errbuf                   OUT nocopy VARCHAR2,
                                  retcode                  OUT nocopy VARCHAR2)
  IS

     CURSOR dff_cur(p_srs_or_dff IN VARCHAR2)
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            fa.application_id,
            fa.application_short_name,
            fa.application_name,

            df.descriptive_flexfield_name,
            df.title,

            dfc.descriptive_flex_context_code,
            dfc.descriptive_flex_context_name,
            fl1.meaning context_enabled_flag_lookup,

            dfcu.application_column_name,
            dfcu.end_user_column_name,
            dfcu.form_left_prompt,
            fl2.meaning segment_enabled_flag_lookup,

            fvs.flex_value_set_id,
            fvs.flex_value_set_name,
            fvs.maximum_size,
            fl3.meaning format_type_lookup

            FROM fnd_descr_flex_col_usage_vl dfcu, fnd_descr_flex_contexts_vl dfc,
            fnd_descriptive_flexs_vl df, fnd_application_vl fa,
            fnd_lookups fl1, fnd_lookups fl2, fnd_lookups fl3,
            fnd_flex_value_sets fvs
            WHERE df.application_id = fa.application_id
            AND dfc.application_id = df.application_id
            AND dfc.descriptive_flexfield_name = df.descriptive_flexfield_name
            AND dfc.enabled_flag = fl1.lookup_code
            AND fl1.lookup_type = 'YES_NO'
            AND dfcu.application_id = dfc.application_id
            AND dfcu.descriptive_flexfield_name = dfc.descriptive_flexfield_name
            AND dfcu.descriptive_flex_context_code = dfc.descriptive_flex_context_code
            AND dfcu.enabled_flag = fl2.lookup_code
            AND fl2.lookup_type = 'YES_NO'
            AND dfcu.flex_value_set_id = fvs.flex_value_set_id
            AND fvs.format_type in ('D', 'T')
            AND fvs.format_type = fl3.lookup_code
            AND fl3.lookup_type = 'FIELD_TYPE'
            AND ((p_srs_or_dff = 'SRS' AND
                  df.descriptive_flexfield_name LIKE '$SRS$.%') OR
                 (p_srs_or_dff = 'DFF' AND
                  df.descriptive_flexfield_name NOT LIKE '$SRS$.%'));

     CURSOR kff_cur
       IS
          SELECT /* $Header: AFFFUPUB.pls 120.4.12010000.2 2012/11/30 18:19:02 hgeorgi ship $ */
            fa.application_id,
            fa.application_short_name,
            fa.application_name,

            idf.id_flex_code,
            idf.id_flex_name,

            ifst.id_flex_num,
            ifst.id_flex_structure_code,
            ifst.id_flex_structure_name,
            fl1.meaning structure_enabled_flag_lookup,

            ifsg.application_column_name,
            ifsg.segment_name,
            ifsg.form_left_prompt,
            fl2.meaning segment_enabled_flag_lookup,

            fvs.flex_value_set_id,
            fvs.flex_value_set_name,
            fvs.maximum_size,
            fl3.meaning format_type_lookup

            FROM fnd_id_flex_segments_vl ifsg, fnd_id_flex_structures_vl ifst,
            fnd_id_flexs idf, fnd_application_vl fa,
            fnd_lookups fl1, fnd_lookups fl2, fnd_lookups fl3,
            fnd_flex_value_sets fvs
            WHERE idf.application_id = fa.application_id
            AND ifst.application_id = idf.application_id
            AND ifst.id_flex_code = idf.id_flex_code
            AND ifst.enabled_flag = fl1.lookup_code
            AND fl1.lookup_type = 'YES_NO'
            AND ifsg.application_id = ifst.application_id
            AND ifsg.id_flex_code = ifst.id_flex_code
            AND ifsg.id_flex_num = ifst.id_flex_num
            AND ifsg.flex_value_set_id = fvs.flex_value_set_id
            AND ifsg.enabled_flag = fl2.lookup_code
            AND fl2.lookup_type = 'YES_NO'
            AND fvs.format_type in ('D', 'T')
            AND fvs.format_type = fl3.lookup_code
            AND fl3.lookup_type = 'FIELD_TYPE';

     srs_rec     dff_cur%ROWTYPE;
     dff_rec     dff_cur%ROWTYPE;
     kff_rec     kff_cur%ROWTYPE;
     l_srs_count NUMBER;
     l_dff_count NUMBER;
     l_kff_count NUMBER;

     PROCEDURE cp_print_srs(p_srs_rec IN dff_cur%ROWTYPE)
       IS
     BEGIN
        cp_debug(' ');
        cp_debug('Application Id          : ' || p_srs_rec.application_id);
        cp_debug('Application Short Name  : ' || p_srs_rec.application_short_name);
        cp_debug('Application Name        : ' || p_srs_rec.application_name);

        cp_debug('Program Short Name      : ' || Substr(p_srs_rec.descriptive_flexfield_name, Length('$SRS$..')));

        cp_debug('Parameter Name          : ' || p_srs_rec.end_user_column_name);
        cp_debug('Parameter Prompt        : ' || p_srs_rec.form_left_prompt);
        cp_debug('Parameter Enabled?      : ' || p_srs_rec.segment_enabled_flag_lookup);

        cp_debug('Value Set Id            : ' || p_srs_rec.flex_value_set_id);
        cp_debug('Value Set Name          : ' || p_srs_rec.flex_value_set_name);
        cp_debug('Value Set Format Type   : ' || p_srs_rec.format_type_lookup);
        cp_debug('Value Set Maximum Size  : ' || p_srs_rec.maximum_size);
     END cp_print_srs;

     PROCEDURE cp_print_dff(p_dff_rec IN dff_cur%ROWTYPE)
       IS
     BEGIN
        cp_debug(' ');
        cp_debug('Application Id          : ' || p_dff_rec.application_id);
        cp_debug('Application Short Name  : ' || p_dff_rec.application_short_name);
        cp_debug('Application Name        : ' || p_dff_rec.application_name);

        cp_debug('DFF Name                : ' || p_dff_rec.descriptive_flexfield_name);
        cp_debug('DFF Title               : ' || p_dff_rec.title);

        cp_debug('Context Code            : ' || p_dff_rec.descriptive_flex_context_code);
        cp_debug('Context Name            : ' || p_dff_rec.descriptive_flex_context_name);
        cp_debug('Context Enabled?        : ' || p_dff_rec.context_enabled_flag_lookup);

        cp_debug('Segment Column Name     : ' || p_dff_rec.application_column_name);
        cp_debug('Segment Name            : ' || p_dff_rec.end_user_column_name);
        cp_debug('Segment Prompt          : ' || p_dff_rec.form_left_prompt);
        cp_debug('Segment Enabled?        : ' || p_dff_rec.segment_enabled_flag_lookup);

        cp_debug('Value Set Id            : ' || p_dff_rec.flex_value_set_id);
        cp_debug('Value Set Name          : ' || p_dff_rec.flex_value_set_name);
        cp_debug('Value Set Format Type   : ' || p_dff_rec.format_type_lookup);
        cp_debug('Value Set Maximum Size  : ' || p_dff_rec.maximum_size);
     END cp_print_dff;

     PROCEDURE cp_print_kff(p_kff_rec IN kff_cur%ROWTYPE)
       IS
     BEGIN
        cp_debug(' ');
        cp_debug('Application Id          : ' || p_kff_rec.application_id);
        cp_debug('Application Short Name  : ' || p_kff_rec.application_short_name);
        cp_debug('Application Name        : ' || p_kff_rec.application_name);

        cp_debug('KFF Code                : ' || p_kff_rec.id_flex_code);
        cp_debug('KFF Name                : ' || p_kff_rec.id_flex_name);

        cp_debug('Structure Number        : ' || p_kff_rec.id_flex_num);
        cp_debug('Structure Code          : ' || p_kff_rec.id_flex_structure_code);
        cp_debug('Structure Name          : ' || p_kff_rec.id_flex_structure_name);
        cp_debug('Structure Enabled?      : ' || p_kff_rec.structure_enabled_flag_lookup);

        cp_debug('Segment Column Name     : ' || p_kff_rec.application_column_name);
        cp_debug('Segment Name            : ' || p_kff_rec.segment_name);
        cp_debug('Segment Prompt          : ' || p_kff_rec.form_left_prompt);
        cp_debug('Segment Enabled?        : ' || p_kff_rec.segment_enabled_flag_lookup);

        cp_debug('Value Set Id            : ' || p_kff_rec.flex_value_set_id);
        cp_debug('Value Set Name          : ' || p_kff_rec.flex_value_set_name);
        cp_debug('Value Set Format Type   : ' || p_kff_rec.format_type_lookup);
        cp_debug('Value Set Maximum Size  : ' || p_kff_rec.maximum_size);
     END cp_print_kff;

BEGIN
   internal_init;

   cp_debug(' ');
   cp_debug('Listing the Report Parameters that use Date or DateTime Value Sets.');
   cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));

   l_srs_count := 0;
   FOR srs_rec IN dff_cur('SRS') LOOP
      l_srs_count := l_srs_count + 1;
      g_cp_indent := g_cp_indent + 5;
      cp_print_srs(srs_rec);
      g_cp_indent := g_cp_indent - 5;
   END LOOP;

   cp_debug(' ');
   cp_debug(l_srs_count || ' Report Parameter(s) listed.');

   cp_debug(' ');
   cp_debug(' ');
   cp_debug('Listing the Descriptive Flexfield Segments that use Date or DateTime Value Sets.');
   cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));

   l_dff_count := 0;
   FOR dff_rec IN dff_cur('DFF') LOOP
      l_dff_count := l_dff_count + 1;
      g_cp_indent := g_cp_indent + 5;
      cp_print_dff(dff_rec);
      g_cp_indent := g_cp_indent - 5;
   END LOOP;

   cp_debug(' ');
   cp_debug(l_dff_count || ' Descriptive Flexfield Segment(s) listed.');

   cp_debug(' ');
   cp_debug(' ');
   cp_debug('Listing the Key Flexfield Segments that use Date or DateTime Value Sets.');
   cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));

   l_kff_count := 0;
   FOR kff_rec IN kff_cur LOOP
      l_kff_count := l_kff_count + 1;
      g_cp_indent := g_cp_indent + 5;
      cp_print_kff(kff_rec);
      g_cp_indent := g_cp_indent - 5;
   END LOOP;

   cp_debug(' ');
   cp_debug(l_kff_count || ' Key Flexfield Segment(s) listed.');

   retcode := 0;
   errbuf := 'FNDFFUPG_LIST_DATE completed successfully.';

   cp_debug(' ');
   cp_debug(errbuf);
   cp_debug(' ');
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_list_date_usages:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_list_date_usages;

-- ======================================================================
-- Procedure : cp_srs_clone_date_vset
-- ======================================================================
-- Clones a Date or DateTime Value Set. (called from SRS.)
--
PROCEDURE cp_srs_clone_date_vset(errbuf               OUT nocopy VARCHAR2,
                                 retcode              OUT nocopy VARCHAR2,
                                 p_old_value_set_name IN VARCHAR2,
                                 p_new_value_set_name IN VARCHAR2)
  IS
     l_return_code NUMBER;
BEGIN
   internal_init;
   set_messaging(TRUE);

   l_return_code := clone_date_vset
     (p_old_value_set_name => p_old_value_set_name,
      p_new_value_set_name => p_new_value_set_name,
      p_session_mode       => 'customer_data');

   cp_debug('Debug messages from Internal Clone Function.');
   cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));
   cp_debug(get_message);
   cp_debug(Rpad('=',g_cp_max_indent-g_cp_indent,'='));

   IF (l_return_code = g_ret_no_error) THEN
      retcode := 0;
      errbuf  := 'FNDFFUPG_CLONE_DATE completed successfully.';
    ELSE
      retcode := 2;
      errbuf  := 'FNDFFUPG_CLONE_DATE failed, please see the log file.';
   END IF;

   cp_debug(' ');
   cp_debug(errbuf);
   cp_debug(' ');
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('cp_srs_clone_date_vset:SQLERRM: ' || Sqlerrm, 1, 240);
END cp_srs_clone_date_vset;


-- ======================================================================
-- Procedure : afffupg1_get_prompt
-- ======================================================================
-- From $FND_TOP/sql/afffupg1.sql.
--
PROCEDURE afffupg1_get_prompt
  (p_menu_choice IN NUMBER,
   p_step        IN NUMBER,
   x_prompt      OUT nocopy VARCHAR2)
  IS
     l_prompt VARCHAR2(2000);
BEGIN
  l_prompt := NULL;
  SELECT Decode
    (p_menu_choice,
     1, Decode
     (p_step,
      0, ('-- List Report Parameters: ' ||
          'You will be asked to enter 6 inputs. ' ||
          'Please ignore the last 4 of them.'),
      1, 'Please enter the application short name [% for all] :',
      2, 'Please enter the report name like [% for all] : ',
      NULL),
     2, Decode
     (p_step,
      0, ('-- List Descriptive Flexfield Segments: '||
          'You will be asked to enter 6 inputs. ' ||
          'Please ignore the last 3 of them.'),
      1, 'Please enter the application short name [% for all] :',
      2, 'Please enter the descriptive flexfield name like [% for all] : ',
      3, 'Please enter the context code like [% for all] : ',
      NULL),
     3, Decode
     (p_step,
      0, ('-- List Key Flexfield Segments: ' ||
          'You will be asked to enter 6 inputs. ' ||
          'Please ignore the last 2 of them.'),
      1, 'Please enter the application short name [% for all] :',
      2, 'Please enter the key flexfield code [% for all] : ',
      3, 'Please enter the structure number like [% for all] :',
      4, 'Please enter the structure name like [% for all] :',
      NULL),
     4, Decode
     (p_step,
      0, ('-- Clone a value set: ' ||
          'You are about to clone one of the Date or DateTime value ' ||
          'sets to Standard Date or Standard DateTime value set. ' ||
          'We recommend you use <old_value_set_name>_STANDARD as a ' ||
          'new name for your value set. ' ||
          'You will be asked to enter 6 inputs. ' ||
          'Please ignore the last 4 of them.'),
      1, 'Please enter the old value set name :',
      2, 'Please enter the new value set name :',
      NULL),
     5, Decode
     (p_step,
      0, ('-- Upgrade Report Parameters: ' ||
          'You are about to upgrade report parameters which use ' ||
          'Date or DateTime value sets, and these value sets will be ' ||
          'replaced with Standard Date or Standard DateTime value sets. ' ||
          'By using a % sign in the report name, you can upgrade multiple ' ||
          'report parameters. ' ||
          'You will be asked to enter 6 inputs. ' ||
          'Please ignore the last 2 of them.'),
      1, 'Please enter the application short name :',
      2, 'Please enter the old value set name :',
      3, 'Please enter the new value set name :',
      4, 'Please enter the report name like [% for all] :',
      NULL),
    6, Decode
    (p_step,
     0, ('-- Upgrade Descriptive Flexfield Segments: ' ||
         'You are about to upgrade descriptive flexfield segments which ' ||
         'use Date or DateTime value sets, and these value sets will be ' ||
         'replaced with Standard Date or Standard DateTime value sets. ' ||
         'By using a % sign in the descriptive flexfield name, or context ' ||
         'code, you can upgrade multiple descriptive flexfields and/or ' ||
         'contexts. ' ||
         'You will be asked to enter 6 inputs. ' ||
         'Please ignore the last one.'),
     1, 'Please enter the application short name :',
     2, 'Please enter the old value set name :',
     3, 'Please enter the new value set name :',
     4, 'Please enter the descriptive flexfield name like [% for all] :',
     5, 'Please enter the context code like [% for all] :',
     NULL),
    7, Decode
    (p_step,
     0, ('-- Upgrade Key Flexfield Segments: ' ||
         'You are about to upgrade key flexfield segments which use ' ||
         'Date or DateTime value sets, and these value sets will be ' ||
         'replaced with Standard Date or Standard DateTime value sets. ' ||
         'By using a % sign in the structure number or structure name ' ||
         'you can upgrade multiple key flexfield structures. ' ||
         'You will be asked to enter 6 inputs.'),
     1, 'Please enter the application short name :',
     2, 'Please enter the key flexfield code :',
     3, 'Please enter the old value set name :',
     4, 'Please enter the new value set name :',
     5, 'Please enter the structure number like [% for all] :',
     6, 'Please enter the structure name like [% for all] :',
     NULL),
    8, Decode
    (p_step,
     0, ('-- Upgrade to Translatable Independent/Dependent value set: ' ||
         'You are about to upgrade an Independent/Dependent Value set to a ' ||
         'Translatable Independent/Dependent Value set. ' ||
         'You will be asked to enter the Independent value set name. ' ||
         'This script will try to upgrade this value set to a Translatable ' ||
         'Independent value set and it will also try to upgrade all ' ||
         'dependent value sets (which depend on the given independent ' ||
         'value set) to Translatable Dependent value sets. ' ||
         'You will be asked to enter 6 inputs. ' ||
         'Please ignore the last 5 of them.'),
     1, 'Please enter the independent value set name :',
     NULL),
    Decode
    (p_step,
     0, 'Invalid menu choice.',
     NULL))
    INTO l_prompt
    FROM dual;

  l_prompt := Nvl(l_prompt,
                  'Please ignore this line and type RETURN to continue :');
  IF (p_step = 0) THEN
     x_prompt := l_prompt;
   ELSE
     x_prompt := 'Input ' || p_step || ': ' || l_prompt;
  END IF;
END afffupg1_get_prompt;


PROCEDURE afffupg1_data_upgrade
  (p_menu_choice IN NUMBER,
   p_param1      IN VARCHAR2,
   p_param2      IN VARCHAR2,
   p_param3      IN VARCHAR2,
   p_param4      IN VARCHAR2,
   p_param5      IN VARCHAR2,
   p_param6      IN VARCHAR2,
   x_prompt      IN OUT nocopy VARCHAR2)
IS
   l_number NUMBER := fnd_flex_upgrade_utilities.g_ret_no_error;
BEGIN
   x_prompt := NULL;

   SAVEPOINT afffupg1_savepoint;
   IF (p_menu_choice = 4) THEN
      l_number := fnd_flex_upgrade_utilities.clone_date_vset
        (p_old_value_set_name => p_param1,
         p_new_value_set_name => p_param2,
         p_session_mode       => 'customer_data');
    ELSIF (p_menu_choice = 5) THEN
      l_number := fnd_flex_upgrade_utilities.upgrade_date_report_parameters
        (p_appl_short_name  => p_param1,
         p_value_set_from   => p_param2,
         p_value_set_to     => p_param3,
         p_session_mode     => 'customer_data',
         p_report_name_like => p_param4);
    ELSIF (p_menu_choice = 6) THEN
      l_number := fnd_flex_upgrade_utilities.upgrade_date_dff_segments
        (p_appl_short_name   => p_param1,
         p_value_set_from    => p_param2,
         p_value_set_to      => p_param3,
         p_session_mode      => 'customer_data',
         p_dff_name_like     => p_param4,
         p_context_code_like => p_param5);
    ELSIF (p_menu_choice = 7) THEN
      l_number := fnd_flex_upgrade_utilities.upgrade_date_kff_segments
        (p_appl_short_name   => p_param1,
         p_id_flex_code      => p_param2,
         p_value_set_from    => p_param3,
         p_value_set_to      => p_param4,
         p_session_mode      => 'customer_data',
         p_struct_num_like   => p_param5,
         p_struct_name_like  => p_param6);
    ELSIF (p_menu_choice = 8) THEN
      l_number := fnd_flex_upgrade_utilities.upgrade_vset_to_translatable
        (p_vset_name      => p_param1,
         p_session_mode   => 'customer_data');
    ELSIF (p_menu_choice IN (1,2,3)) THEN
      --
      -- List the segments.
      --
      x_prompt := NULL;
      RETURN;
    ELSE
      x_prompt := 'Invalid menu choice.';
      RETURN;
   END IF;
   IF (l_number = fnd_flex_upgrade_utilities.g_ret_no_error) THEN
      x_prompt := 'Successful operation, calling COMMIT.';
      COMMIT;
    ELSE
      x_prompt := 'Unsuccessful operation, calling ROLLBACK.';
      ROLLBACK TO afffupg1_savepoint;
   END IF;
END;

END fnd_flex_upgrade_utilities;

/
