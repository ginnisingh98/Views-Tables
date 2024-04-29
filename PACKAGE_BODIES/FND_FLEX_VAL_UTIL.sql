--------------------------------------------------------
--  DDL for Package Body FND_FLEX_VAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_VAL_UTIL" AS
/* $Header: AFFFUTVB.pls 120.3.12010000.4 2009/02/04 19:35:01 hgeorgi ship $ */


chr_newline VARCHAR2(8); -- := fnd_global.newline;

g_package_name VARCHAR2(50) := 'FND_FLEX_VAL_UTIL';

g_internal_debug VARCHAR2(32000);
g_flag_debugging BOOLEAN := FALSE;

g_message_stack_number NUMBER := 0;

-- Time zone conversion directions. see fdffds.h

g_tz_server_to_local VARCHAR2(10) := '1';
g_tz_local_to_server VARCHAR2(20) := '2';

g_date_format_19  VARCHAR2(80) := 'RRRR/MM/DD HH24:MI:SS';
g_date_format_5   VARCHAR2(80) := 'HH24:MI';
g_date_format_8   VARCHAR2(80) := 'HH24:MI:SS';
g_date_format_9   VARCHAR2(80) := 'DD-MON-RR';
g_date_format_11  VARCHAR2(80) := 'DD-MON-RRRR';
g_date_format_15  VARCHAR2(80) := 'DD-MON-RR HH24:MI';
g_date_format_17  VARCHAR2(80) := 'DD-MON-RRRR HH24:MI';
g_date_format_18  VARCHAR2(80) := 'DD-MON-RR HH24:MI:SS';
g_date_format_20  VARCHAR2(80) := 'DD-MON-RRRR HH24:MI:SS';

-- ==============================
-- Masks
-- ==============================
--
-- Keep room for Universal Time Stamp.
--
m_sep                     VARCHAR2(1)  := '|'; -- mask separator.
m_canonical_date          VARCHAR2(50) := 'RRRR/MM/DD HH24:MI:SS';
m_canonical_datetime      VARCHAR2(50) := 'RRRR/MM/DD HH24:MI:SS';
m_canonical_time          VARCHAR2(50) := 'HH24:MI:SS';
m_canonical_numeric_chars VARCHAR2(2)  := '.,';
m_db_numeric_chars        VARCHAR2(2);

--
-- _IN masks can have multiple values separated by '|'. Keep enough room.
-- _OUT masks will have only one mask.
--
m_nls_date_in             VARCHAR2(500);
m_nls_date_out            VARCHAR2(50);
m_nls_datetime_in         VARCHAR2(500);
m_nls_datetime_out        VARCHAR2(50);
m_nls_time_in             VARCHAR2(500);
m_nls_time_out            VARCHAR2(50);
m_nls_numeric_chars_in    VARCHAR2(100);
m_nls_numeric_chars_out   VARCHAR2(10);

m_ds_can                  VARCHAR2(1) := '.';  -- Canonical decimal separator.
m_ds_db                   VARCHAR2(1);         -- dataBase decimal separator.
m_ds_disp                 VARCHAR2(1);         -- Display decimal separator.

-- =======================================================================
--          Added by NGOUGLER START
-- =======================================================================
-- g2u: Gregorian to User calendar
-- u2g: User to Gregorian calendar
g_cal_g2u		VARCHAR2(10) := '1';
g_cal_u2g		VARCHAR2(10) := '2';

-- =======================================================================
--          Added by NGOUGLER END
-- =======================================================================

-- ==================================================
-- VTV definitions
-- ==================================================
--
-- vtv_rec_type : Segment qualifier definition record.
-- For now we don't need all the details of segment qualifier.
-- Only lookup_type and default_value are enough.
--
TYPE vtv_rec_type IS RECORD
  (
   --   id_flex_application_id NUMBER,
   --   id_flex_code           VARCHAR2(10),
   --   segment_attribute_type VARCHAR2(100),
   --   value_attribute_type   VARCHAR2(100),
   --   assignment_date        DATE,
   lookup_type            VARCHAR2(100),
   default_value          VARCHAR2(100));

--
-- vtv_arr_type : Segment qualifiers for a given value set.
--
TYPE vtv_arr_type IS TABLE OF vtv_rec_type INDEX BY BINARY_INTEGER;

g_vtv_array              vtv_arr_type;
g_vtv_array_size         NUMBER := NULL;
g_vtv_flex_value_set_id  NUMBER := 0;

-- ==================================================
-- Private Function Definitions.
-- ==================================================
PROCEDURE debug(p_debug IN VARCHAR2);

PROCEDURE set_message_name(p_appl_short_name IN VARCHAR2,
			   p_message_name   IN VARCHAR2);
PROCEDURE set_message_token(p_token_name  IN VARCHAR2,
			    p_token_value IN VARCHAR2);
PROCEDURE set_message(p_appl_short_name IN VARCHAR2,
		      p_message_name    IN VARCHAR2,
		      p_num_of_tokens   IN NUMBER,
		      p_token_name_1    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_1   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_2    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_2   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_3    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_3   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_4    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_4   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_5    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_5   IN VARCHAR2 DEFAULT NULL);

PROCEDURE internal_init;
PROCEDURE init_masks;
PROCEDURE ssv_exception(p_func_name IN VARCHAR2,
			p_message   IN VARCHAR2 DEFAULT NULL);

PROCEDURE ssv_bad_parameter(p_func_name IN VARCHAR2,
			    p_reason    IN VARCHAR2 DEFAULT NULL);

PROCEDURE get_format_private(p_vset_name     IN VARCHAR2,
			     p_vset_format   IN VARCHAR2,
			     p_max_length    IN NUMBER,
			     p_precision     IN NUMBER DEFAULT NULL,
			     x_format_in     OUT NOCOPY VARCHAR2,
			     x_format_out    OUT NOCOPY VARCHAR2,
			     x_canonical     OUT NOCOPY VARCHAR2,
			     x_number_format OUT NOCOPY VARCHAR2,
			     x_number_min    OUT NOCOPY NUMBER,
			     x_number_max    OUT NOCOPY NUMBER,
			     x_success       OUT NOCOPY NUMBER);

PROCEDURE validate_value_private(p_value             IN VARCHAR2,
				 p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
				 p_vset_name         IN VARCHAR2 DEFAULT NULL,
				 p_vset_format       IN VARCHAR2 DEFAULT 'C',
				 p_max_length        IN NUMBER   DEFAULT 0,
				 p_precision         IN NUMBER   DEFAULT NULL,
				 p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
				 p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
				 p_zero_fill         IN VARCHAR2 DEFAULT 'N',
				 p_min_value         IN VARCHAR2 DEFAULT NULL,
				 p_max_value         IN VARCHAR2 DEFAULT NULL,
				 x_storage_value     OUT NOCOPY VARCHAR2,
				 x_display_value     OUT NOCOPY VARCHAR2,
				 x_success           OUT NOCOPY NUMBER);

FUNCTION get_vtv_lookup(p_lookup_type  IN VARCHAR2,
			p_lookup_code  IN VARCHAR2,
			p_use_default  IN BOOLEAN,
			p_default_code IN VARCHAR2)
  RETURN VARCHAR2;

-- ==================================================
-- Public Functions.
-- ==================================================
PROCEDURE vtv_to_display_value(p_flex_value_set_id IN NUMBER,
			       p_use_default       IN BOOLEAN,
			       p_storage_value     IN VARCHAR2,
			       x_display_value     OUT NOCOPY VARCHAR2)
  IS
     i               NUMBER;
     l_use_default   BOOLEAN         := Nvl(p_use_default, FALSE);
     l_storage_value VARCHAR2(32000) := p_storage_value;
     l_display_value VARCHAR2(32000) := NULL;
     l_lookup_code   VARCHAR2(100);
     l_lookup_value  VARCHAR2(100);
     l_pos           NUMBER;
     CURSOR vtv_cur(p_flex_value_set_id IN NUMBER) IS
	SELECT
	  --	  fvq.id_flex_application_id,
	  --	  fvq.id_flex_code,
	  --	  fvq.segment_attribute_type,
	  --	  fvq.value_attribute_type,
	  --	  fvq.assignment_date,
	  vat.lookup_type,
	  vat.default_value
	  FROM fnd_flex_validation_qualifiers fvq,
	  fnd_value_attribute_types vat
	  WHERE fvq.flex_value_set_id    = p_flex_value_set_id
	  AND fvq.id_flex_application_id = vat.application_id(+)
	  AND fvq.id_flex_code           = vat.id_flex_code(+)
	  AND fvq.segment_attribute_type = vat.segment_attribute_type(+)
	  AND fvq.value_attribute_type   = vat.value_attribute_type(+)
	  ORDER BY fvq.flex_value_set_id, fvq.assignment_date,
	  fvq.value_attribute_type;
     --
     -- Note : Above ORDER BY statement is important. Qualifiers are sorted
     -- by assignment date.
     --
BEGIN
   internal_init();
   IF (p_flex_value_set_id <> g_vtv_flex_value_set_id) THEN
      --
      -- Re-populate the global cache. Either this is the first time
      -- this procedure is called or value set is changed.
      -- Note : initial value of g_vtv_flex_value_set_id is 0
      -- and none of the value sets can have 0 value set id.
      --
      g_vtv_array_size := 0;
      FOR vtv_rec IN vtv_cur(p_flex_value_set_id) LOOP
	 g_vtv_array_size := g_vtv_array_size + 1;
	 g_vtv_array(g_vtv_array_size).lookup_type   := vtv_rec.lookup_type;
	 g_vtv_array(g_vtv_array_size).default_value := vtv_rec.default_value;
      END LOOP;
      g_vtv_flex_value_set_id := p_flex_value_set_id;

      IF (g_flag_debugging) THEN
	 debug('VTV: New Value Set Id : ' || To_char(p_flex_value_set_id));
	 debug('VTV: VTV Array Size   : ' || To_char(g_vtv_array_size));
      END IF;
   END IF;

   IF (g_vtv_array_size = 0) THEN
      --
      -- There are no qualifiers for this value set.
      --
      IF (g_flag_debugging) THEN
	 debug('VTV: No Qualifier : ' || To_char(p_flex_value_set_id));
      END IF;
      GOTO lbl_return;
   END IF;

   IF ((l_storage_value IS NULL) AND
       (NOT l_use_default)) THEN
      IF (g_flag_debugging) THEN
	 debug('VTV: NULL value and no default. : ' || To_char(p_flex_value_set_id));
      END IF;
      GOTO lbl_return;
   END IF;

   --
   -- Add extra newline at the end for parsing.
   --
   l_storage_value := l_storage_value || chr_newline;
   i := 0;
   WHILE ((l_storage_value IS NOT NULL) AND
	  (i < g_vtv_array_size)) LOOP
      i := i + 1;
      l_pos := Instr(l_storage_value, chr_newline, 1, 1);
      l_lookup_code := Substr(l_storage_value, 1, l_pos - 1);
      l_storage_value := Substr(l_storage_value, l_pos + 1);
      l_lookup_value := get_vtv_lookup(g_vtv_array(i).lookup_type,
				       l_lookup_code,
				       l_use_default,
				       g_vtv_array(i).default_value);
      l_display_value := l_display_value || l_lookup_value || '.';
   END LOOP;
   --
   -- Fill in the remaining VTV values.
   -- If a value is created before a Qualifier is defined,
   -- there will be remaining values.
   --
   WHILE ((i < g_vtv_array_size) AND
	  (l_use_default)) LOOP
      i := i + 1;
      l_lookup_value := get_vtv_lookup(g_vtv_array(i).lookup_type,
				       NULL,
				       l_use_default,
				       g_vtv_array(i).default_value);
      l_display_value := l_display_value || l_lookup_value || '.';
   END LOOP;
   --
   -- Remove the last '.'.
   --
   x_display_value := Substr(l_display_value, 1,
			     Nvl(Lengthb(l_display_value),0)-1);

   <<lbl_return>>
     x_display_value := l_display_value;
     RETURN;
EXCEPTION
   WHEN OTHERS THEN
      IF (g_flag_debugging) THEN
	 debug('vtv_to_display_value() Exception : ' || Sqlerrm);
      END IF;
      x_display_value := NULL;
      RETURN;
END vtv_to_display_value;



FUNCTION is_success(p_success IN NUMBER)
  RETURN BOOLEAN IS
BEGIN
   IF (p_success = g_ret_no_error) THEN
      RETURN(TRUE);
   END IF;
   RETURN(FALSE);
END is_success;

-- ==================================================
FUNCTION get_debug RETURN VARCHAR2
  IS
BEGIN
   RETURN(g_internal_debug);
END get_debug;

-- ==================================================
PROCEDURE set_debugging(p_flag IN BOOLEAN DEFAULT TRUE)
  IS
BEGIN
   g_flag_debugging := Nvl(p_flag, FALSE);
   IF (NOT g_flag_debugging) THEN
      g_internal_debug := ('Debugging is turned OFF. ' || chr_newline ||
			   'Please call set_debugging(TRUE) to turn it ON.');
   END IF;
END set_debugging;

-- ==================================================
FUNCTION get_mask(p_mask_name  IN VARCHAR2,
		  x_mask_value OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  IS
     l_code_name  VARCHAR2(100) := g_package_name || '.get_mask()';
     l_mask_value VARCHAR2(500);
BEGIN
   internal_init();
   SELECT Decode(Upper(p_mask_name),
		 'CANONICAL_DATE',          m_canonical_date,
		 'CANONICAL_DATETIME',      m_canonical_datetime,
		 'CANONICAL_TIME',          m_canonical_time,
		 'CANONICAL_NUMERIC_CHARS', m_canonical_numeric_chars,
		 'DB_NUMERIC_CHARS',        m_db_numeric_chars,
		 'NLS_DATE_IN',             m_nls_date_in,
		 'NLS_DATE_OUT',            m_nls_date_out,
		 'NLS_DATETIME_IN',         m_nls_datetime_in,
		 'NLS_DATETIME_OUT',        m_nls_datetime_out,
		 'NLS_TIME_IN',             m_nls_time_in,
		 'NLS_TIME_OUT',            m_nls_time_out,
		 'NLS_NUMERIC_CHARS_IN',    m_nls_numeric_chars_in,
		 'NLS_NUMERIC_CHARS_OUT',   m_nls_numeric_chars_out,
		 'FLEX_UNKNOWN_MASK')
     INTO l_mask_value
     FROM dual;
   x_mask_value := l_mask_value;
   IF (l_mask_value = 'FLEX_UNKNOWN_MASK') THEN
      ssv_bad_parameter(l_code_name, 'Unknown mask name is passed.');
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name);
      RETURN(FALSE);
END get_mask;

-- ==================================================
FUNCTION set_mask(p_mask_name  IN VARCHAR2,
		  p_mask_value IN VARCHAR2) RETURN BOOLEAN
  IS
     l_code_name VARCHAR2(100)   := g_package_name || '.set_mask()';
     l_mask_name VARCHAR2(100)  := Upper(p_mask_name);
BEGIN
   internal_init();
   IF ((Instr(p_mask_name, '_OUT') > 0) AND
       (Instr(p_mask_value, m_sep) >0)) THEN
      ssv_bad_parameter(l_code_name,
			'_OUT masks cannot have multiple values.');
      RETURN(FALSE);
   END IF;

   IF (l_mask_name = 'NLS_DATE_IN') THEN
      m_nls_date_in := p_mask_value;
    ELSIF (l_mask_name = 'NLS_DATE_OUT') THEN
      m_nls_date_out := p_mask_value;

    ELSIF (l_mask_name = 'NLS_DATETIME_IN') THEN
      m_nls_datetime_in := p_mask_value;
    ELSIF (l_mask_name = 'NLS_DATETIME_OUT') THEN
      m_nls_datetime_out := p_mask_value;

    ELSIF (l_mask_name = 'NLS_TIME_IN') THEN
      m_nls_time_in := p_mask_value;
    ELSIF (l_mask_name = 'NLS_TIME_OUT') THEN
      m_nls_time_out := p_mask_value;

    ELSIF (l_mask_name = 'NLS_NUMERIC_CHARS_IN') THEN
      m_nls_numeric_chars_in := p_mask_value;
    ELSIF (l_mask_name = 'NLS_NUMERIC_CHARS_OUT') THEN
      m_nls_numeric_chars_out := p_mask_value;
      m_ds_disp := Substr(m_nls_numeric_chars_out, 1, 1);
    ELSE
      ssv_bad_parameter(l_code_name, 'Unknown mask name is passed.');
      RETURN(FALSE);
   END IF;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name);
      RETURN(FALSE);
END set_mask;

-- ==================================================
FUNCTION get_storage_format(p_vset_format IN VARCHAR2,
			    p_max_length  IN NUMBER,
			    p_precision   IN NUMBER DEFAULT NULL,
			    x_format      OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  IS
     l_code_name VARCHAR2(100) := g_package_name || '.get_storage_format()';
     l_success   NUMBER;

     tmp_vc1     VARCHAR2(2000);
     tmp_vc2     VARCHAR2(2000);
     tmp_vc3     VARCHAR2(2000);
     tmp_number1 NUMBER;
     tmp_number2 NUMBER;
BEGIN
   internal_init();
   --
   -- Use tmp_ variables for unused arguments.
   --
   get_format_private(p_vset_name     => l_code_name,
		      p_vset_format   => p_vset_format,
		      p_max_length    => p_max_length,
		      p_precision     => p_precision,
		      x_format_in     => tmp_vc1,
		      x_format_out    => tmp_vc2,
		      x_canonical     => x_format,
		      x_number_format => tmp_vc3,
		      x_number_min    => tmp_number1,
		      x_number_max    => tmp_number2,
		      x_success       => l_success);
   RETURN(is_success(l_success));
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name);
      RETURN(FALSE);
END get_storage_format;

-- ==================================================
FUNCTION get_display_format(p_vset_format IN VARCHAR2,
			    p_max_length  IN NUMBER,
			    p_precision   IN NUMBER DEFAULT NULL,
			    x_format_in   OUT NOCOPY VARCHAR2,
			    x_format_out  OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  IS
     l_code_name VARCHAR2(100) := g_package_name || '.get_display_mask()';
     l_success   NUMBER;

     tmp_vc1     VARCHAR2(2000);
     tmp_vc2     VARCHAR2(2000);
     tmp_number1 NUMBER;
     tmp_number2 NUMBER;
BEGIN
   internal_init();
   --
   -- Use tmp_ variables for unused arguments.
   --
   get_format_private(p_vset_name     => l_code_name,
		      p_vset_format   => p_vset_format,
		      p_max_length    => p_max_length,
		      p_precision     => p_precision,
		      x_format_in     => x_format_in,
		      x_format_out    => x_format_out,
		      x_canonical     => tmp_vc1,
		      x_number_format => tmp_vc2,
		      x_number_min    => tmp_number1,
		      x_number_max    => tmp_number2,
		      x_success       => l_success);
   RETURN(is_success(l_success));
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name);
      RETURN(FALSE);
END get_display_format;

-- ==================================================
FUNCTION is_date_private(p_value           IN VARCHAR2,
			 p_nls_date_format IN VARCHAR2 DEFAULT NULL,
			 x_date            OUT NOCOPY DATE)
  RETURN BOOLEAN IS
     l_nls_date_format VARCHAR2(500) := p_nls_date_format;
     l_mask            VARCHAR2(100);
     l_pos             NUMBER;
BEGIN
   IF (p_value IS NULL) THEN
      x_date := NULL;
      RETURN(TRUE);
    ELSIF (l_nls_date_format IS NULL) THEN
      RETURN(FALSE);
    ELSE
      l_nls_date_format := Rtrim(l_nls_date_format, m_sep) || m_sep;
      LOOP
	 l_pos := Instr(l_nls_date_format, m_sep);
	 IF (l_pos > 0) THEN
	    l_mask := Substr(l_nls_date_format, 1, l_pos - 1);
	    l_nls_date_format := Substr(l_nls_date_format, l_pos + 1);
	  ELSE
	    l_mask := l_nls_date_format;
	    l_nls_date_format := NULL;
	 END IF;

         BEGIN
	    x_date := To_date(p_value, l_mask);
	    RETURN(TRUE);
	 EXCEPTION
	    --
	    -- This mask failed, try others, if we have.
	    --
	    WHEN OTHERS THEN
	       IF (l_nls_date_format IS NULL) THEN
		  RETURN(FALSE);
	       END IF;
	 END;
      END LOOP;
   END IF;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(FALSE);
END is_date_private;

-- ==================================================
FUNCTION is_date(p_value           IN VARCHAR2,
		 p_nls_date_format IN VARCHAR2 DEFAULT NULL,
		 x_date            OUT NOCOPY DATE)
  RETURN BOOLEAN IS
     l_nls_date_format VARCHAR2(500) := p_nls_date_format;
     l_mask            VARCHAR2(100);
     l_pos             NUMBER;
BEGIN
   internal_init();
   RETURN(is_date_private(p_value,
			  p_nls_date_format,
			  x_date));
END is_date;

-- ==================================================
FUNCTION flex_to_date(p_value           IN VARCHAR2,
		      p_nls_date_format IN VARCHAR2) RETURN DATE
  IS
     l_date DATE;
BEGIN
   internal_init();
   IF (is_date_private(p_value, p_nls_date_format, l_date)) THEN
      RETURN(l_date);
    ELSE
      RETURN(NULL);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN(NULL);
END flex_to_date;

-- ==================================================
--
-- Takes with nls_numeric_chars mask, returns in db_numeric_chars mask.
--
FUNCTION is_number_private(p_value             IN VARCHAR2,
			   p_nls_numeric_chars IN VARCHAR2,
			   x_value             OUT NOCOPY VARCHAR2,
			   x_number            OUT NOCOPY NUMBER)
  RETURN BOOLEAN IS
     l_nls_numeric_chars VARCHAR2(100) := p_nls_numeric_chars;
     l_mask              VARCHAR2(10);
     l_pos               NUMBER;
     l_value             VARCHAR2(2000) := p_value;
BEGIN
   IF (p_value IS NULL) THEN
      x_value := NULL;
      x_number := NULL;
      RETURN(TRUE);
    ELSIF (l_nls_numeric_chars IS NULL) THEN
      RETURN(FALSE);
    ELSE
      l_nls_numeric_chars := Rtrim(l_nls_numeric_chars, m_sep) || m_sep;
      LOOP
	 l_pos := Instr(l_nls_numeric_chars, m_sep);
	 IF (l_pos > 0) THEN
	    l_mask := Substr(l_nls_numeric_chars, 1, l_pos - 1);
	    l_nls_numeric_chars := Substr(l_nls_numeric_chars, l_pos + 1);
	  ELSE
	    l_mask := l_nls_numeric_chars;
	    l_nls_numeric_chars := NULL;
	 END IF;

         BEGIN
	    --
	    -- We do not use Group Separator.
	    -- To_number will use database decimal separator.
	    --
	    l_value  := REPLACE(p_value, Substr(l_mask, 1, 1), m_ds_db);
	    x_number := To_number(l_value);
	    x_value  := l_value;
	    RETURN(TRUE);
	 EXCEPTION
	    --
	    -- This mask failed, try others, if we have.
	    --
	    WHEN OTHERS THEN
	       IF (l_nls_numeric_chars IS NULL) THEN
		  RETURN(FALSE);
	       END IF;
	 END;
      END LOOP;
   END IF;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(FALSE);
END is_number_private;

-- ==================================================
--
-- Takes with nls_numeric_chars mask, returns in db_numeric_chars mask.
--
FUNCTION is_number(p_value             IN VARCHAR2,
		   p_nls_numeric_chars IN VARCHAR2,
		   x_value             OUT NOCOPY VARCHAR2,
		   x_number            OUT NOCOPY NUMBER)
  RETURN BOOLEAN
  IS
BEGIN
   internal_init();
   RETURN(is_number_private(p_value,
			    p_nls_numeric_chars,
			    x_value,
			    x_number));
END is_number;

-- ==================================================
FUNCTION flex_to_number(p_value             IN VARCHAR2,
			p_nls_numeric_chars IN VARCHAR2) RETURN NUMBER
  IS
     l_number NUMBER;
     l_value  VARCHAR2(2000);
BEGIN
   internal_init();
   IF (is_number_private(p_value, p_nls_numeric_chars, l_value, l_number)) THEN
      RETURN(l_number);
    ELSE
      RETURN(NULL);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN(NULL);
END flex_to_number;


-- ==================================================
PROCEDURE validate_value(p_value             IN VARCHAR2,
			 p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
			 p_vset_name         IN VARCHAR2 DEFAULT NULL,
			 p_vset_format       IN VARCHAR2 DEFAULT 'C',
			 p_max_length        IN NUMBER   DEFAULT 0,
			 p_precision         IN NUMBER   DEFAULT NULL,
			 p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			 p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			 p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			 p_min_value         IN VARCHAR2 DEFAULT NULL,
			 p_max_value         IN VARCHAR2 DEFAULT NULL,
			 x_storage_value     OUT NOCOPY VARCHAR2,
			 x_display_value     OUT NOCOPY VARCHAR2,
			 x_success           OUT NOCOPY BOOLEAN)
  IS
     l_code_name VARCHAR2(100) := g_package_name || '.validate_value()';
     l_success   NUMBER;
BEGIN
   internal_init();
   validate_value_private(p_value            => p_value,
			  p_is_displayed     => p_is_displayed,
			  p_vset_name        => p_vset_name,
			  p_vset_format      => p_vset_format,
			  p_max_length       => p_max_length,
			  p_precision        => p_precision,
			  p_alpha_allowed    => p_alpha_allowed,
			  p_uppercase_only   => p_uppercase_only,
			  p_zero_fill        => p_zero_fill,
			  p_min_value        => p_min_value,
			  p_max_value        => p_max_value,
			  x_storage_value    => x_storage_value,
			  x_display_value    => x_display_value,
			  x_success          => l_success);
   x_success := is_success(l_success);
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name,
		    ' Value Set : ' || p_vset_name ||
		    ' Value : ' || p_value);
      x_success := FALSE;
END validate_value;

-- ==================================================
FUNCTION is_value_valid(p_value             IN VARCHAR2,
			p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
			p_vset_name         IN VARCHAR2 DEFAULT NULL,
			p_vset_format       IN VARCHAR2 DEFAULT 'C',
			p_max_length        IN NUMBER   DEFAULT 0,
			p_precision         IN NUMBER   DEFAULT NULL,
			p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			p_min_value         IN VARCHAR2 DEFAULT NULL,
			p_max_value         IN VARCHAR2 DEFAULT NULL,
			x_storage_value     OUT NOCOPY VARCHAR2,
			x_display_value     OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  IS
     l_code_name VARCHAR2(100) := g_package_name || '.is_value_valid()';
     l_success   NUMBER;
BEGIN
   internal_init();
   validate_value_private(p_value            => p_value,
			  p_is_displayed     => p_is_displayed,
			  p_vset_name        => p_vset_name,
			  p_vset_format      => p_vset_format,
			  p_max_length       => p_max_length,
			  p_precision        => p_precision,
			  p_alpha_allowed    => p_alpha_allowed,
			  p_uppercase_only   => p_uppercase_only,
			  p_zero_fill        => p_zero_fill,
			  p_min_value        => p_min_value,
			  p_max_value        => p_max_value,
			  x_storage_value    => x_storage_value,
			  x_display_value    => x_display_value,
			  x_success          => l_success);
   RETURN(is_success(l_success));
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name,
		    ' Value Set : ' || p_vset_name ||
		    ' Value : ' || p_value);
      RETURN(FALSE);
END is_value_valid;


-- ==================================================
FUNCTION to_display_value(p_value             IN VARCHAR2,
			  p_vset_format       IN VARCHAR2 DEFAULT 'C',
			  p_vset_name         IN VARCHAR2 DEFAULT NULL,
			  p_max_length        IN NUMBER   DEFAULT 0,
			  p_precision         IN NUMBER   DEFAULT NULL,
			  p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			  p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			  p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			  p_min_value         IN VARCHAR2 DEFAULT NULL,
			  p_max_value         IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_code_name     VARCHAR2(100) := g_package_name || '.to_display_value()';
     l_vset_name     VARCHAR2(100) := Nvl(p_vset_name, l_code_name);
     l_max_length    NUMBER        := Nvl(p_max_length, Lengthb(p_value));
     l_display_value VARCHAR2(2000);
     l_success       NUMBER;

     tmp_vc          VARCHAR2(2000);
BEGIN
   internal_init();
   validate_value_private(p_value             => p_value,
			  p_is_displayed      => FALSE,
			  p_vset_name         => l_vset_name,
			  p_vset_format       => p_vset_format,
			  p_max_length        => l_max_length,
			  p_precision         => p_precision,
			  p_alpha_allowed     => p_alpha_allowed,
			  p_uppercase_only    => p_uppercase_only,
			  p_zero_fill         => p_zero_fill,
			  p_min_value         => p_min_value,
			  p_max_value         => p_max_value,
			  x_storage_value     => tmp_vc,
			  x_display_value     => l_display_value,
			  x_success           => l_success);
   IF (l_success = g_ret_no_error) THEN
      RETURN(l_display_value);
    ELSE
      RETURN(NULL);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name);
      RETURN(NULL);
END to_display_value;

-- ==================================================
FUNCTION to_storage_value(p_value             IN VARCHAR2,
			  p_vset_format       IN VARCHAR2 DEFAULT 'C',
			  p_vset_name         IN VARCHAR2 DEFAULT NULL,
			  p_max_length        IN NUMBER   DEFAULT 0,
			  p_precision         IN NUMBER   DEFAULT NULL,
			  p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			  p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			  p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			  p_min_value         IN VARCHAR2 DEFAULT NULL,
			  p_max_value         IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_code_name  VARCHAR2(100) := g_package_name || '.to_storage_value()';
     l_vset_name  VARCHAR2(100) := Nvl(p_vset_name, l_code_name);
     l_max_length NUMBER        := Nvl(p_max_length, Lengthb(p_value));
     l_storage_value VARCHAR2(2000);
     l_success       NUMBER;

     tmp_vc          VARCHAR2(2000);

BEGIN
   internal_init();
   validate_value_private(p_value             => p_value,
			  p_is_displayed      => TRUE,
			  p_vset_name         => l_vset_name,
			  p_vset_format       => p_vset_format,
			  p_max_length        => l_max_length,
			  p_precision         => p_precision,
			  p_alpha_allowed     => p_alpha_allowed,
			  p_uppercase_only    => p_uppercase_only,
			  p_zero_fill         => p_zero_fill,
			  p_min_value         => p_min_value,
			  p_max_value         => p_max_value,
			  x_storage_value     => l_storage_value,
			  x_display_value     => tmp_vc,
			  x_success           => l_success);
   IF (l_success = g_ret_no_error) THEN
      RETURN(l_storage_value);
    ELSE
      RETURN(NULL);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name);
      RETURN(NULL);
END to_storage_value;

-- ==================================================
PROCEDURE validate_value_ssv(p_value             IN VARCHAR2,
			     p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
			     p_vset_name         IN VARCHAR2 DEFAULT NULL,
			     p_vset_format       IN VARCHAR2 DEFAULT 'C',
			     p_max_length        IN NUMBER   DEFAULT 0,
			     p_precision         IN NUMBER   DEFAULT NULL,
			     p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			     p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			     p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			     p_min_value         IN VARCHAR2 DEFAULT NULL,
			     p_max_value         IN VARCHAR2 DEFAULT NULL,
			     x_storage_value     OUT NOCOPY VARCHAR2,
			     x_display_value     OUT NOCOPY VARCHAR2,
			     x_success           OUT NOCOPY NUMBER)
  IS
     l_code_name VARCHAR2(100) := g_package_name || '.validate_value_ssv()';
     l_success   NUMBER;
BEGIN
   internal_init();
   validate_value_private(p_value            => p_value,
			  p_is_displayed     => p_is_displayed,
			  p_vset_name        => p_vset_name,
			  p_vset_format      => p_vset_format,
			  p_max_length       => p_max_length,
			  p_precision        => p_precision,
			  p_alpha_allowed    => p_alpha_allowed,
			  p_uppercase_only   => p_uppercase_only,
			  p_zero_fill        => p_zero_fill,
			  p_min_value        => p_min_value,
			  p_max_value        => p_max_value,
			  x_storage_value    => x_storage_value,
			  x_display_value    => x_display_value,
			  x_success          => l_success);
   x_success := l_success;
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name,
		    ' Value Set : ' || p_vset_name ||
		    ' Value : ' || p_value);
      x_success := g_ret_exception_others;
END validate_value_ssv;

-- ==================================================
-- Since client is using auvc1998 for varchar2 types,
-- Substr(X,1,1998) will be used for out varchar2's.
--
PROCEDURE get_server_global(p_char_in  IN VARCHAR2,
			    x_char_out OUT NOCOPY VARCHAR2,
			    x_error    OUT NOCOPY NUMBER,
			    x_message  OUT NOCOPY VARCHAR2)
  IS
     l_code_name VARCHAR2(100) := (g_package_name ||
				   '.get_server_global()');
     l_char_out VARCHAR2(32000);
     l_plsql    VARCHAR2(32000);
     l_char_in  VARCHAR2(2000) := Upper(p_char_in);
BEGIN
   internal_init();
   IF (l_char_in = 'FND_DATE.USER_MASK') THEN
      l_char_out := fnd_date.user_mask;
    ELSIF (l_char_in = 'FND_DATE.USERDT_MASK') THEN
      l_char_out := fnd_date.userdt_mask;
    ELSIF (l_char_in = 'FND_NUMBER.DECIMAL_CHAR') THEN
      l_char_out := fnd_number.decimal_char;
    ELSE
      l_plsql := 'BEGIN :l_char_out := ' || p_char_in || '; END;';
      EXECUTE IMMEDIATE l_plsql USING OUT l_char_out;
   END IF;
   IF (l_char_out IS NULL) THEN
      x_error := -1;
      x_message := 'NULL mask value for ' || l_char_in ||' in '|| l_code_name;
      x_char_out := NULL;
      RETURN;
   END IF;

   x_char_out := Substrb(l_char_out,1,1998);
   x_error := 0;
   x_message := NULL;
EXCEPTION
   WHEN OTHERS THEN
      --
      -- ssv_exception will put SQLERRM in stack.
      -- Store SQLCODE in x_error.
      --
      ssv_exception(l_code_name, 'p_char_in : ' || p_char_in);
      x_char_out := NULL;
      x_error := SQLCODE;
      --
      -- Hope encoded message will not be longer than 1998.
      --
      x_message := Substr(fnd_message.get_encoded,1,1998);
END get_server_global;

-- ==================================================
PROCEDURE flex_date_converter(p_vs_format_type IN VARCHAR2,
			      p_tz_direction   IN VARCHAR2,
			      p_input_mask     IN VARCHAR2,
			      p_input          IN VARCHAR2,
			      p_output_mask    IN VARCHAR2,
			      x_output         OUT NOCOPY VARCHAR2,
			      x_error          OUT NOCOPY NUMBER,
			      x_message        OUT NOCOPY VARCHAR2)
  IS
     l_code_name   VARCHAR2(100) := (g_package_name ||
				     '.flex_date_converter()');
     l_input       VARCHAR2(2000);
     l_input_date  DATE;
     l_output      VARCHAR2(2000);
     l_output_date DATE;
BEGIN
   internal_init();

   l_input_date := To_date(p_input, p_input_mask);

   IF (p_vs_format_type = 'Y') THEN
      --
      -- Standard Date Time Value Set.
      --
      IF (p_tz_direction = g_tz_server_to_local) THEN
	 --
	 -- Server to Local Time Zone conversion.
	 -- fnd_date.date_to_displayDT() returns in fnd_date.outputDT_mask.
	 --
	 l_output := fnd_date.date_to_displayDT(l_input_date);
	 l_output_date := To_date(l_output, fnd_date.outputDT_mask);

       ELSIF (p_tz_direction = g_tz_local_to_server) THEN
	 --
	 -- Local to Server Time Zone conversion.
	 -- fnd_date.displayDT_to_date() expects in fnd_date.userDT_mask.
	 --
	 l_input := To_char(l_input_date, fnd_date.userDT_mask);
	 l_output_date := fnd_date.displayDT_to_date(l_input);

       ELSE
	 ssv_exception(l_code_name, ('Invalid p_tz_direction: ' ||
				     p_tz_direction));
	 x_error := 1;
	 GOTO return_failure;
      END IF;

    ELSIF (p_vs_format_type IN ('D', 'T', 't', 'I', 'X', 'Z')) THEN
      --
      -- other DATE value sets.
      --
      l_output_date := l_input_date;

    ELSE
      ssv_exception(l_code_name, ('Invalid p_vs_format_type: ' ||
				  p_vs_format_type));
      x_error := 2;
      GOTO return_failure;
   END IF;

   <<return_success>>
   x_error := 0;
   l_output := To_char(l_output_date, p_output_mask);
   x_message := ('DEBUG: p_vs_format_type: ' || p_vs_format_type ||
		 ', p_tz_direction: ' || p_tz_direction ||
		 ', p_input: ' || p_input ||
		 ', p_input_mask: ' || p_input_mask ||
		 ', l_otput: ' || l_output ||
		 ', p_output_mask: ' || p_output_mask ||
		 ', fnd_date.outputDT_mask: ' || fnd_date.outputDT_mask ||
		 ', fnd_date.userDT_mask: ' || fnd_date.userDT_mask);
   x_output := l_output;
   RETURN;

   <<return_failure>>
   x_output := NULL;
   x_message := Substrb(fnd_message.get_encoded, 1, 1998);
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_output := NULL;
      x_error := SQLCODE;
      ssv_exception(l_code_name, ('p_vs_format_type: ' || p_vs_format_type ||
				  ', p_tz_direction: ' || p_tz_direction ||
				  ', p_input: ' || p_input ||
				  ', p_input_mask: ' || p_input_mask ||
				  ', p_output_mask: ' || p_output_mask ||
				  ', fnd_date.outputDT_mask: ' || fnd_date.outputDT_mask ||
				  ', fnd_date.userDT_mask: ' || fnd_date.userDT_mask));

      x_message := Substrb(fnd_message.get_encoded,1,1998);
END flex_date_converter;

-- =======================================================================
--          Added by NGOUGLER START
-- =======================================================================
-- ==================================================
PROCEDURE flex_date_converter_cal(p_vs_format_type IN VARCHAR2,
			      p_tz_direction   IN VARCHAR2,
                                          p_cal_direction  IN VARCHAR2,
			      p_mask     IN VARCHAR2,
			      p_calendar    IN VARCHAR2,
			      p_input          IN VARCHAR2,
			      x_output         OUT NOCOPY VARCHAR2,
			      x_error          OUT NOCOPY NUMBER,
			      x_message        OUT NOCOPY VARCHAR2)
  IS
     l_code_name   VARCHAR2(100) := (g_package_name ||
				     '.flex_date_converter_cal()');
     l_input       VARCHAR2(2000);
     l_input_date  DATE;
     l_output      VARCHAR2(2000);
     l_output_date DATE;

     l_calendar_param VARCHAR2(100) :=  'NLS_CALENDAR=''' || p_calendar || '''' ;

BEGIN
   internal_init();

--   l_input_date := To_date(p_input, p_input_mask);  --- Original
   --
   -- Calendar conversion
   -- g2u: Assumes the input date value as Greogrian calendar date
   -- u2g: Assumes the input date value as User calendar date
   --
   IF (p_cal_direction = g_cal_g2u) THEN
       l_input_date := To_date(p_input, p_mask);
   ELSIF (p_cal_direction = g_cal_u2g) THEN
       l_input_date :=  To_date(p_input, p_mask, l_calendar_param);
   END IF;

-- ===   IF (p_vs_format_type = 'Y') THEN
      --
      -- Standard Date Time Value Set.
      --
-- ===     IF (p_tz_direction = g_tz_server_to_local) THEN
	 --
	 -- Server to Local Time Zone conversion.
	 -- fnd_date.date_to_displayDT() returns in fnd_date.outputDT_mask.
	 --
-- ===	 l_output := fnd_date.date_to_displayDT(l_input_date);
-- === 	 l_output_date := To_date(l_output, fnd_date.outputDT_mask);

-- ===       ELSIF (p_tz_direction = g_tz_local_to_server) THEN
	 --
	 -- Local to Server Time Zone conversion.
	 -- fnd_date.displayDT_to_date() expects in fnd_date.userDT_mask.
	 --
-- ===	 l_input := To_char(l_input_date, fnd_date.userDT_mask);
-- ===	 l_output_date := fnd_date.displayDT_to_date(l_input);

-- ===       ELSE
-- ===	 ssv_exception(l_code_name, ('Invalid p_tz_direction: ' ||
-- ===				     p_tz_direction));
-- ===	 x_error := 1;
-- ===	 GOTO return_failure;
-- ===      END IF;

    IF (p_vs_format_type IN ('D', 'T', 't', 'I', 'X', 'Y', 'Z')) THEN
      --
      -- other DATE value sets.
      --
      l_output_date := l_input_date;

    ELSE
      ssv_exception(l_code_name, ('Invalid p_vs_format_type: ' ||
				  p_vs_format_type));
      x_error := 2;
      GOTO return_failure;
   END IF;

   <<return_success>>
   x_error := 0;
--   l_output := To_char(l_output_date, p_output_mask);    --- ORIGINAL
   --
   -- Calendar conversion
   -- g2u: Returns the output date value as User  calendar date
   -- u2g: Returns the output date value as Gregorian calendar date
   --
   IF (p_cal_direction = g_cal_g2u) THEN
	l_output := To_char(l_output_date, p_mask, l_calendar_param);
   ELSIF (p_cal_direction = g_cal_u2g) THEN
	l_output := To_char(l_output_date, p_mask);
   END IF;

   x_message := ('DEBUG: p_vs_format_type: ' || p_vs_format_type ||
		 ', p_tz_direction: ' || p_tz_direction ||
		 ', p_cal_direction: ' || p_cal_direction ||
		 ', p_input: ' || p_input ||
		 ', p_mask: ' || p_mask ||
		 ', l_output: ' || l_output ||
		 ', p_calendar: ' || p_calendar ||
		 ', fnd_date.outputDT_mask: ' || fnd_date.outputDT_mask ||
		 ', fnd_date.userDT_mask: ' || fnd_date.userDT_mask);
   x_output := l_output;
   RETURN;

   <<return_failure>>
   x_output := NULL;
   x_message := Substrb(fnd_message.get_encoded, 1, 1998);
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_output := NULL;
      x_error := SQLCODE;
      ssv_exception(l_code_name, ('p_vs_format_type: ' || p_vs_format_type ||
				  ', p_tz_direction: ' || p_tz_direction ||
                 		              ', p_cal_direction: ' || p_cal_direction ||
				  ', p_input: ' || p_input ||
				  ', p_mask: ' || p_mask ||
				  ', p_calendar: ' || p_calendar ||
				  ', fnd_date.outputDT_mask: ' || fnd_date.outputDT_mask ||
				  ', fnd_date.userDT_mask: ' || fnd_date.userDT_mask));

      x_message := Substrb(fnd_message.get_encoded,1,1998);
END flex_date_converter_cal;
-- =======================================================================
--          Added by NGOUGLER END
-- =======================================================================


-- ======================================================================
-- Private Functions
-- ======================================================================
-- --------------------------------------------------
FUNCTION get_vtv_lookup(p_lookup_type  IN VARCHAR2,
			p_lookup_code  IN VARCHAR2,
			p_use_default  IN BOOLEAN,
			p_default_code IN VARCHAR2)
  RETURN VARCHAR2 IS
     l_lookup_value VARCHAR2(100) := NULL;
     CURSOR lookup_cur(p_lookup_type IN VARCHAR2,
		       p_lookup_code IN VARCHAR2) IS
 	SELECT meaning
	  FROM fnd_lookups
	  WHERE lookup_type = p_lookup_type
	  AND lookup_code = p_lookup_code
	  AND ROWNUM = 1;
BEGIN
   --
   -- This loop will run 0 or 1 time because of ROWNUM = 1.
   -- OPEN and FETCH is not used since FOR handles
   -- 'no rows found' exception.
   --
   FOR lookup_rec IN lookup_cur(p_lookup_type, p_lookup_code) LOOP
      l_lookup_value := lookup_rec.meaning;
   END LOOP;
   --
   -- If lookup is not found and default can be used try
   -- default code. This happens if p_lookup_code is NULL
   -- or it is an invalid value.
   --
   IF ((l_lookup_value IS NULL) AND
       (Nvl(p_use_default, FALSE))) THEN
      FOR lookup_rec IN lookup_cur(p_lookup_type, p_default_code) LOOP
	 l_lookup_value := lookup_rec.meaning;
      END LOOP;
   END IF;
   RETURN(l_lookup_value);
EXCEPTION
   WHEN OTHERS THEN
      IF (g_flag_debugging) THEN
	 debug('get_vtv_lookup() Exception : ' || Sqlerrm);
      END IF;
      RETURN(NULL);
END get_vtv_lookup;

-- --------------------------------------------------
PROCEDURE validate_value_private
  (p_value             IN VARCHAR2,
   p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
   p_vset_name         IN VARCHAR2 DEFAULT NULL,
   p_vset_format       IN VARCHAR2 DEFAULT 'C',
   p_max_length        IN NUMBER   DEFAULT 0,
   p_precision         IN NUMBER   DEFAULT NULL,
   p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
   p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
   p_zero_fill         IN VARCHAR2 DEFAULT 'N',
   p_min_value         IN VARCHAR2 DEFAULT NULL,
   p_max_value         IN VARCHAR2 DEFAULT NULL,
   x_storage_value     OUT NOCOPY VARCHAR2,
   x_display_value     OUT NOCOPY VARCHAR2,
   x_success           OUT NOCOPY NUMBER)
  IS
     l_code_name VARCHAR2(100) := (g_package_name ||
				   '.validate_value_private()');

     l_value               VARCHAR2(2000) := p_value;
     l_lengthb             NUMBER;
     l_is_displayed        BOOLEAN        := Nvl(p_is_displayed, TRUE);
     l_storage_value       VARCHAR2(2000) := p_value;
     l_display_value       VARCHAR2(2000) := p_value;
     --
     -- These min, and max display values are used for error reporting.
     --
     l_min_display_value   VARCHAR2(2000) := p_min_value;
     l_max_display_value   VARCHAR2(2000) := p_max_value;

     l_is_in_range         BOOLEAN        := TRUE;
     l_is_too_long         BOOLEAN        := FALSE;
     l_is_number           BOOLEAN        := FALSE;

     --
     -- Several Format Masks.
     --
     l_nls_numeric_chars   VARCHAR2(100);

     l_date_format         VARCHAR2(500)  := 'NO NEED TO SET';
     l_number_format       VARCHAR2(500)  := 'NO NEED TO SET';
     l_format_in           VARCHAR2(500)  := 'NO NEED TO SET';
     l_format_out          VARCHAR2(100)  := 'NO NEED TO SET';
     l_canonical           VARCHAR2(100)  := 'NO NEED TO SET';

     l_success             NUMBER         := g_ret_no_error;

     --
     -- Temporary variables.
     --
     tmp_success           NUMBER;
     tmp_varchar2          VARCHAR2(2000);
     tmp_number            NUMBER;
     tmp_date              DATE;
     tmp_min_vc2           VARCHAR2(2000);
     tmp_max_vc2           VARCHAR2(2000);
     tmp_min_number        NUMBER;
     tmp_max_number        NUMBER;
     tmp_min_date          DATE;
     tmp_max_date          DATE;

BEGIN
   --
   -- NULL is always a valid value.
   --
   IF (l_value IS NULL) THEN
      GOTO lbl_return;
   END IF;
   --
   -- If displayed, no space around the value.
   --
   IF (l_is_displayed) THEN
      l_value := Ltrim(Rtrim(l_value));
   END IF;

   --
   -- NLS_NUMERIC_CHARACTERS
   --
   IF (l_is_displayed) THEN
      l_nls_numeric_chars := m_nls_numeric_chars_in;
    ELSE
      l_nls_numeric_chars := m_canonical_numeric_chars;
   END IF;

   --
   -- Lengths are in bytes.
   --
   l_lengthb := Lengthb(l_value);

   --
   -- Check length.
   -- p_max_length doesn't work for X, Y, and Z in STORAGE mode.
   -- Date type value sets will be checked in format check.
   --
   IF (NOT l_is_displayed) THEN
      IF (p_vset_format IN ('X', 'Y', 'Z')) THEN
	 IF (p_vset_format = 'X') THEN
	    tmp_varchar2 := m_canonical_date;
	  ELSIF (p_vset_format = 'Y') THEN
	    tmp_varchar2 := m_canonical_datetime;
	  ELSIF (p_vset_format = 'Z') THEN
	    tmp_varchar2 := m_canonical_time;
	 END IF;
	 IF (l_lengthb > Lengthb(To_char(Sysdate, tmp_varchar2))) THEN
	    l_is_too_long := TRUE;
	 END IF;
       ELSE
	 --
	 -- We are calling this function for None validated value sets in
	 -- Id mode too. This means the storage validation for them, and we
	 -- should check the lengthb.
	 --
	 IF (l_lengthb > p_max_length) THEN
	    l_is_too_long := TRUE;
	 END IF;
      END IF;
    ELSE
      IF (l_lengthb > p_max_length) THEN
	 l_is_too_long := TRUE;
      END IF;
   END IF;

   IF (l_is_too_long) THEN
      set_message('FND', 'FLEX-VALUE TOO LONG', 2,
		  'VALUE', p_value,
		  'LENGTH', To_char(p_max_length));
      l_success := g_ret_value_too_long;
      GOTO lbl_return;
   END IF;

   IF (p_vset_format = 'C') THEN
      --
      -- Char Format.
      --
      l_is_number := is_number_private(l_value, l_nls_numeric_chars,
				       tmp_varchar2, tmp_number);

      IF (p_alpha_allowed = 'N') THEN
	 --
	 -- Numbers Only.
	 --
	 IF (NOT l_is_number) THEN
	    set_message('FND', 'FLEX-INVALID NUMBER', 1,
			'NUMBER', l_value);
	    l_success := g_ret_invalid_number;
	    GOTO lbl_return;
	 END IF;
	 --
	 -- Now in DB format.
	 --
	 l_value := tmp_varchar2;
      END IF;

      IF ((p_zero_fill = 'Y') AND
	  (l_is_number)) THEN
	 --
	 -- Right Justify Zero Fill is enabled.
	 --
	 l_value := Nvl(Ltrim(l_value, '0'),'0');

	 IF (tmp_number < 0) THEN
	    --
	    -- First character is '-'.
	    --
	    l_value := Substr(l_value,2);
	    l_value := Lpad(l_value, p_max_length-1, '0');
	    l_value := '-' || l_value;
	  ELSE
	    l_value := Lpad(l_value, p_max_length, '0');
	 END IF;
      END IF;

      IF (p_uppercase_only = 'Y') THEN
	 l_value := Upper(l_value);
      END IF;

      l_display_value := l_value;
      l_storage_value := l_value;
      IF (p_alpha_allowed = 'N') THEN
	 --
	 -- Numbers Only.
	 --
	 l_display_value := REPLACE(l_value, m_ds_db, m_ds_disp);
	 l_storage_value := REPLACE(l_value, m_ds_db, m_ds_can);
      END IF;

      --
      -- Range Check.
      --
      IF (p_alpha_allowed = 'N') THEN
	 --
	 -- Numbers Only.
	 --
	 -- p_min_value and p_max_value must be in canonical format.
	 --
	 IF (is_number_private(p_min_value, m_canonical_numeric_chars,
			       tmp_min_vc2, tmp_min_number) AND
	     is_number_private(p_max_value, m_canonical_numeric_chars,
			       tmp_max_vc2, tmp_max_number)) THEN
	    IF (tmp_number < Nvl(tmp_min_number, tmp_number) OR
		tmp_number > Nvl(tmp_max_number, tmp_number)) THEN
	       l_is_in_range := FALSE;
	       l_min_display_value := REPLACE(p_min_value, m_ds_can, m_ds_disp);
	       l_max_display_value := REPLACE(p_max_value, m_ds_can, m_ds_disp);
	    END IF;
	  ELSE
	    set_message('FND', 'FLEX-VS BAD NUMRANGE', 1,
			'VSNAME', p_vset_name);
	    l_success := g_ret_vs_bad_numrange;
	    GOTO lbl_return;
	 END IF;
       ELSE
	 IF (l_storage_value < Nvl(p_min_value, l_storage_value) OR
	     l_storage_value > Nvl(p_max_value, l_storage_value)) THEN
	    l_is_in_range := FALSE;
	    l_min_display_value := p_min_value;
	    l_max_display_value := p_max_value;
	 END IF;
      END IF;

    ELSIF (p_vset_format = 'N') THEN
      --
      -- Number Format.
      --
      IF (NOT is_number_private(l_value, l_nls_numeric_chars,
				tmp_varchar2, tmp_number)) THEN
	 set_message('FND', 'FLEX-INVALID NUMBER', 1,
		     'NUMBER', l_value);
	 l_success := g_ret_invalid_number;
	 GOTO lbl_return;
      END IF;

      get_format_private(p_vset_name     => p_vset_name,
			 p_vset_format   => p_vset_format,
			 p_max_length    => p_max_length,
			 p_precision     => p_precision,
			 x_format_in     => l_format_in,
			 x_format_out    => l_format_out,
			 x_canonical     => l_canonical,
			 x_number_format => l_number_format,
			 x_number_min    => tmp_min_number,
			 x_number_max    => tmp_max_number,
			 x_success       => tmp_success);

      IF (NOT is_success(tmp_success)) THEN
	 l_success := tmp_success;
	 GOTO lbl_return;
      END IF;

      --
      -- Check for universal limits.
      --
      IF ((tmp_number < tmp_min_number) OR
	  (tmp_number > tmp_max_number)) THEN
	 set_message('FND', 'FLEX-INVALID NUMBER', 1,
		     'NUMBER', l_value);
	 l_success := g_ret_invalid_number;
	 GOTO lbl_return;
      END IF;

      IF (p_precision IS NULL) THEN
	 l_value := Ltrim(To_char(tmp_number));
	 --
	 -- To_char(0.45) returns '.45', make it '0.45'
	 -- To_char(-0.45) returns '-.45', make it '-0.45'
	 --
	 IF (tmp_number > 0) THEN
	    IF (Substr(l_value,1,1) = m_ds_db) THEN
	       l_value := '0' || l_value;
	    END IF;
	  ELSIF (tmp_number < 0) THEN
	     IF (Substr(l_value,2,1) = m_ds_db) THEN
		l_value := '-0' || Substr(l_value,2);
	     END IF;
	  END IF;
	  l_value := Substr(l_value,1,p_max_length);
       ELSE
	 l_value := Ltrim(To_char(tmp_number, l_number_format));
      END IF;

      l_display_value := REPLACE(l_value, m_ds_db, m_ds_disp);
      l_storage_value := REPLACE(l_value, m_ds_db, m_ds_can);

      --
      -- Range Check. p_min_value, and p_max_value must be in canonical format.
      --
      IF (is_number_private(p_min_value, m_canonical_numeric_chars,
			    tmp_min_vc2, tmp_min_number) AND
	  is_number_private(p_max_value, m_canonical_numeric_chars,
			    tmp_max_vc2, tmp_max_number)) THEN
	 IF (tmp_number < Nvl(tmp_min_number, tmp_number) OR
	     tmp_number > Nvl(tmp_max_number, tmp_number)) THEN
	    l_is_in_range := FALSE;
	    l_min_display_value := REPLACE(p_min_value, m_ds_can, m_ds_disp);
	    l_max_display_value := REPLACE(p_max_value, m_ds_can, m_ds_disp);
	 END IF;
       ELSE
	 set_message('FND', 'FLEX-VS BAD NUMRANGE', 1,
		     'VSNAME', p_vset_name);
	 l_success := g_ret_vs_bad_numrange;
	 GOTO lbl_return;
      END IF;

    ELSIF (p_vset_format IN ('D', 'T', 't', 'I', 'X', 'Y', 'Z')) THEN
      --
      -- All kind of date formats.
      --
      --  D = Date format.  Sizes 9 or 11
      --  T = DateTime format.  Sizes 15, 17, 18 or 20.
      --  I or t = Time format.  Sizes 5 or 8
      --  X = Translatable date format
      --  Y = Translatable datetime format
      --  Z = Translatable time format
      --

      get_format_private(p_vset_name     => p_vset_name,
			 p_vset_format   => p_vset_format,
			 p_max_length    => p_max_length,
			 p_precision     => p_precision,
			 x_format_in     => l_format_in,
			 x_format_out    => l_format_out,
			 x_canonical     => l_canonical,
			 x_number_format => tmp_varchar2,
			 x_number_min    => tmp_min_number,
			 x_number_max    => tmp_max_number,
			 x_success       => tmp_success);
      IF (NOT is_success(tmp_success)) THEN
	 l_success := tmp_success;
	 GOTO lbl_return;
      END IF;

      IF (l_is_displayed) THEN
	 l_date_format := l_format_in;
       ELSE
	 l_date_format := l_canonical;
      END IF;

      IF (NOT is_date_private(l_value, l_date_format, tmp_date)) THEN
	 set_message('FND', 'FLEX-INVALID DATE', 2,
		     'DATE', l_value,
		     'FORMAT', l_date_format);
	 l_success := g_ret_invalid_date;
	 GOTO lbl_return;
      END IF;

      l_display_value := To_char(tmp_date, l_format_out);
      l_storage_value := To_char(tmp_date, l_canonical);

      --
      -- Range Check. p_min_value, and p_max_value must be in canonical format.
      --
      IF (is_date_private(p_min_value, l_canonical, tmp_min_date) AND
	  is_date_private(p_max_value, l_canonical, tmp_max_date)) THEN
	 IF (tmp_date < Nvl(tmp_min_date, tmp_date) OR
	     tmp_date > Nvl(tmp_max_date, tmp_date)) THEN
	    l_is_in_range := FALSE;
	    l_min_display_value := To_char(tmp_min_date,l_format_out);
	    l_max_display_value := To_char(tmp_max_date,l_format_out);
	 END IF;
       ELSE
	 set_message('FND', 'FLEX-VS BAD DATERANGE', 1,
		     'VSNAME', p_vset_name);
	 l_success := g_ret_vs_bad_daterange;
	 GOTO lbl_return;
      END IF;

    --
    -- Invalid Value Set Format.
    --
    ELSE
      set_message('FND', 'FLEX-VS BAD FORMAT', 2,
		  'VSNAME', p_vset_name,
		  'FMT', p_vset_format);
      l_success := g_ret_vs_bad_format;
      GOTO lbl_return;
   END IF;

   --
   -- Min <= Value <= Max Range Check:
   --
   IF (NOT l_is_in_range) THEN
      set_message('FND', 'FLEX-VAL OUT OF RANGE', 3,
		  'VALUE', l_display_value,
		  'MINVALUE', l_min_display_value,
		  'MAXVALUE', l_max_display_value);
      l_success := g_ret_val_out_of_range;
      GOTO lbl_return;
   END IF;

   <<lbl_return>>

   x_display_value := l_display_value;
   x_storage_value := l_storage_value;
   x_success       := l_success;

   IF (g_flag_debugging) THEN
      IF (p_vset_format = 'N' OR
	  p_vset_format = 'C' AND p_alpha_allowed = 'N') THEN
	 debug('l_nls_numeric_chars: ' || l_nls_numeric_chars);
	 debug('l_number_format    : ' || l_number_format);
	 debug('l_format_in/out    : ' || l_format_in || '-/-' || l_format_out);
	 debug('m_db_numeric_chars : ' || m_db_numeric_chars);
	 debug('m_nls_numeric_chars_in/out: ' || (m_nls_numeric_chars_in ||'-/-' ||
						  m_nls_numeric_chars_out));
       ELSIF (p_vset_format IN ('D', 'T', 't', 'I', 'X', 'Y', 'Z')) THEN
	 debug('l_canonical       : ' || l_canonical);
	 debug('l_format_in/out   : ' || l_format_in || '-/-' || l_format_out);
	 debug('l_date_format     : ' || l_date_format);
	 debug('m_nls_date_in/out : ' || m_nls_date_in || '-/-' || m_nls_date_out);
	 debug('m_nls_datetimet_in/out:' || (m_nls_datetime_in || '-/-' ||
					     m_nls_datetime_out));
	 debug('m_nls_time_in/out   : ' || (m_nls_time_in || '-/-' ||
					    m_nls_time_out));
      END IF;
      debug('Value Disp/Stor   : ' || l_display_value || '/' || l_storage_value);
      debug('Success Code      : ' || To_char(l_success));
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name,
		    ' Value Set : ' || p_vset_name ||
		    ' Value : ' || p_value);
      x_success := g_ret_exception_others;
END validate_value_private;


-- --------------------------------------------------
PROCEDURE get_format_private(p_vset_name     IN VARCHAR2,
			     p_vset_format   IN VARCHAR2,
			     p_max_length    IN NUMBER,
			     p_precision     IN NUMBER DEFAULT NULL,
			     x_format_in     OUT NOCOPY VARCHAR2,
			     x_format_out    OUT NOCOPY VARCHAR2,
			     x_canonical     OUT NOCOPY VARCHAR2,
			     x_number_format OUT NOCOPY VARCHAR2,
			     x_number_min    OUT NOCOPY NUMBER,
			     x_number_max    OUT NOCOPY NUMBER,
			     x_success       OUT NOCOPY NUMBER)
  IS
     l_code_name VARCHAR2(100) := g_package_name || '.get_format_private()';
     l_format    VARCHAR2(1000);
     l_success   NUMBER := g_ret_no_error;

     tmp_varchar2          VARCHAR2(2000);
     tmp_min_vc2           VARCHAR2(2000);
     tmp_max_vc2           VARCHAR2(2000);

BEGIN
   x_format_in     := NULL;  -- _IN NLS format.
   x_format_out    := NULL;  -- _OUT NLS format
   x_canonical     := NULL;  -- Storage Format.
   x_number_format := NULL;  -- Numbers only, mask with D.
   x_number_min    := NULL;  -- Universal min for Numbers.
   x_number_max    := NULL;  -- Universal max for numbers.

   --
   -- Only Date, DateTime, Time, and Number value sets need masking.
   --
   IF (NOT (p_vset_format IN ('D', 'T', 't', 'I', 'X', 'Y', 'Z', 'N'))) THEN
      ssv_bad_parameter(l_code_name, 'Illegal Value Set Format is passed.');
      l_success := g_ret_bad_parameter;
      GOTO lbl_return;
   END IF;

   IF (p_vset_format = 'N') THEN
      --
      -- Number Value Sets.
      --
      -- Construct Number Format and Universal Limits.
      -- Example :
      -- These are universal min and max boundaries.
      --
      -- We have to check these universal min and max values, otherwise
      -- to_char will return ######'s for not fitting numbers.
      --
      --    maximum                       universal      number
      --     length       precision   minimum   maximum  format
      -- ----------    ------------   -------   -------  ------
      --          5    NULL or <= 0     -9999     99999   99990
      --          5               1     -99.9     999.9   990D9
      --          5               2     -9.99     99.99   90D99
      --          5               3     -.999     9.999   0D999
      --          5               4     0         .9999   D9999
      --          5    else bad precision.
      --
      IF ((p_precision IS NULL) OR (p_precision <= 0)) THEN
	 l_format := Lpad('0', p_max_length, '9');
	 tmp_varchar2 := Lpad('9', p_max_length -1 , '9');
	 tmp_max_vc2 := '9' || tmp_varchar2;
	 tmp_min_vc2 := '-' || Nvl(tmp_varchar2, '0');

       ELSIF (p_precision < p_max_length - 2) THEN
	 l_format := Rpad('0D', p_precision + 2, '9');
	 l_format := Lpad(l_format, p_max_length, '9');
	 tmp_varchar2 := Rpad('9' || m_ds_db , p_precision + 2, '9');
	 tmp_varchar2 := Lpad(tmp_varchar2, p_max_length-1, '9');
	 tmp_max_vc2 := '9' || tmp_varchar2;
	 tmp_min_vc2 := '-' || tmp_varchar2;

       ELSIF (p_precision < p_max_length - 1) THEN
	 l_format := Rpad('0D', p_precision + 2, '9');
	 l_format := Lpad(l_format, p_max_length, '9');
	 tmp_varchar2 := Rpad(m_ds_db, p_precision + 1, '9');
	 tmp_varchar2 := Lpad(tmp_varchar2, p_max_length-1, '9');
	 tmp_max_vc2 := '9' || tmp_varchar2;
	 tmp_min_vc2 := '-' || tmp_varchar2;

       ELSIF (p_precision < p_max_length) THEN
	 l_format := Rpad('D', p_max_length, '9');
	 tmp_varchar2    := Rpad(m_ds_db, p_max_length, '9');
	 tmp_max_vc2 := tmp_varchar2;
	 tmp_min_vc2 := '0';

       ELSE
	 set_message('FND', 'FLEX-VS BAD PRECIS', 1,
		     'VSNAME', p_vset_name);
	 l_success := g_ret_vs_bad_precision;
	 GOTO lbl_return;
      END IF;

      x_number_format := l_format;
      x_number_min    := To_number(tmp_min_vc2);
      x_number_max    := To_number(tmp_max_vc2);

      x_format_in     := REPLACE(l_format, 'D',
				 Substr(m_nls_numeric_chars_in, 1, 1));
      x_format_out    := REPLACE(l_format, 'D', m_ds_disp);
      x_canonical     := REPLACE(l_format, 'D', m_ds_can);

    ELSIF (p_vset_format IN ('D', 'T', 'I', 't')) THEN
      --
      -- Regular Date, DateTime, Time Value sets.
      -- For these value sets (display mask = storage mask)
      --
      IF (p_vset_format = 'D' AND p_max_length = 9) THEN
	 l_format := g_date_format_9;
       ELSIF (p_vset_format = 'D' AND p_max_length = 11) THEN
	 l_format := g_date_format_11;
       ELSIF (p_vset_format IN ('I','t') AND p_max_length = 5) THEN
	 l_format := g_date_format_5;
       ELSIF (p_vset_format IN ('I','t') AND p_max_length = 8) THEN
	 l_format := g_date_format_8;
       ELSIF (p_vset_format = 'T' AND p_max_length = 15) THEN
	 l_format := g_date_format_15;
       ELSIF (p_vset_format = 'T' AND p_max_length = 17) THEN
	 l_format := g_date_format_17;
       ELSIF (p_vset_format = 'T' AND p_max_length = 18) THEN
	 l_format := g_date_format_18;
       ELSIF (p_vset_format = 'T' AND p_max_length = 20) THEN
	 l_format := g_date_format_20;
       ELSE
	 set_message('FND', 'FLEX-VS BAD DATE', 1,
		     'VSNAME', p_vset_name);
	 l_success := g_ret_vs_bad_date;
	 GOTO lbl_return;
      END IF;
      x_format_in  := l_format;
      x_format_out := l_format;
      x_canonical  := l_format;

    ELSIF (p_vset_format IN ('X', 'Y', 'Z')) THEN
      --
      -- Standard Date, DateTime, Time Value Sets.
      --
      IF (p_vset_format = 'X') THEN
	 x_format_in  := m_nls_date_in;
	 x_format_out := m_nls_date_out;
	 x_canonical  := m_canonical_date;
       ELSIF (p_vset_format = 'Y') THEN
	 x_format_in  := m_nls_datetime_in;
	 x_format_out := m_nls_datetime_out;
	 x_canonical  := m_canonical_datetime;
       ELSIF (p_vset_format = 'Z') THEN
	 x_format_in  := m_nls_time_in;
	 x_format_out := m_nls_time_out;
	 x_canonical  := m_canonical_time;
      END IF;
   END IF;

   <<lbl_return>>
   x_success := l_success;
EXCEPTION
   WHEN OTHERS THEN
      ssv_exception(l_code_name);
      x_success := g_ret_exception_others;
END get_format_private;


-- ==============================
-- DEBUG
-- ==============================
-- --------------------------------------------------
PROCEDURE debug(p_debug IN VARCHAR2)
  IS
BEGIN
   IF g_flag_debugging THEN
      IF (Length(g_internal_debug) <= 31000) THEN
	 g_internal_debug := g_internal_debug || p_debug || chr_newline;
       ELSE
	 g_internal_debug := g_internal_debug ||
           'Maximum size is reached for debug string. ' || chr_newline ||
           'Debugging is turned OFF.';
         g_flag_debugging := FALSE;
      END IF;
   END IF;
END debug;

-- ==============================
-- FND_MESSAGE utility.
-- ==============================
-- --------------------------------------------------
PROCEDURE set_message_name(p_appl_short_name IN VARCHAR2,
			   p_message_name   IN VARCHAR2)
  IS
BEGIN
   IF (g_message_stack_number = 0) THEN
      IF (p_appl_short_name IS NULL) THEN
	 fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
	 fnd_message.set_token('MSG', p_message_name);
       ELSE
	 fnd_message.set_name(p_appl_short_name, p_message_name);
      END IF;
   END IF;
   g_message_stack_number := g_message_stack_number + 1;
END;

-- --------------------------------------------------
PROCEDURE set_message_token(p_token_name  IN VARCHAR2,
			    p_token_value IN VARCHAR2)
  IS
BEGIN
   IF (g_message_stack_number = 1) THEN
      fnd_message.set_token(p_token_name, p_token_value);
   END IF;
END;

-- --------------------------------------------------
PROCEDURE set_message(p_appl_short_name IN VARCHAR2,
		      p_message_name    IN VARCHAR2,
		      p_num_of_tokens   IN NUMBER,
		      p_token_name_1    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_1   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_2    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_2   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_3    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_3   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_4    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_4   IN VARCHAR2 DEFAULT NULL,
		      p_token_name_5    IN VARCHAR2 DEFAULT NULL,
		      p_token_value_5   IN VARCHAR2 DEFAULT NULL)
  IS
BEGIN
   set_message_name(p_appl_short_name, p_message_name);
   IF (p_num_of_tokens > 0) THEN
      set_message_token(p_token_name_1, p_token_value_1);
   END IF;
   IF (p_num_of_tokens > 1) THEN
      set_message_token(p_token_name_2, p_token_value_2);
   END IF;
   IF (p_num_of_tokens > 2) THEN
      set_message_token(p_token_name_3, p_token_value_3);
   END IF;
   IF (p_num_of_tokens > 3) THEN
      set_message_token(p_token_name_4, p_token_value_4);
   END IF;
   IF (p_num_of_tokens > 4) THEN
      set_message_token(p_token_name_5, p_token_value_5);
   END IF;
END set_message;

-- --------------------------------------------------
PROCEDURE internal_init
  IS
BEGIN
   IF g_flag_debugging THEN
      g_internal_debug := g_package_name || ':' || chr_newline;
   END IF;

   g_message_stack_number := 0;

   init_masks();
END internal_init;

-- --------------------------------------------------
PROCEDURE ssv_bad_parameter(p_func_name IN VARCHAR2,
			    p_reason    IN VARCHAR2 DEFAULT NULL)
  IS
BEGIN
   set_message('FND','FLEX-SSV EXCEPTION', 1,
	       'MSG', p_func_name || 'is failed.' || chr_newline ||
	       'Reason : ' ||
	       Nvl(p_reason, 'Wrong parameters in function call.'));
END ssv_bad_parameter;

-- --------------------------------------------------
PROCEDURE ssv_exception(p_func_name IN VARCHAR2,
			p_message   IN VARCHAR2 DEFAULT NULL)
  IS
BEGIN
   set_message('FND', 'FLEX-SSV EXCEPTION', 1,
	       'MSG', p_func_name || ' failed. ' || chr_newline ||
	       'Message : ' || p_message || chr_newline ||
	       'Error : ' || Sqlerrm);
END ssv_exception;

-- --------------------------------------------------
PROCEDURE init_masks
  IS
BEGIN
   --
   -- Default NLS masks.
   --
   m_nls_date_in           := fnd_date.user_mask;
   m_nls_date_out          := fnd_date.output_mask;
   m_nls_datetime_in       := fnd_date.userdt_mask;
   m_nls_datetime_out      := fnd_date.outputdt_mask;
   m_nls_time_in           := 'HH24:MI:SS';
   m_nls_time_out          := 'HH24:MI:SS';
   m_db_numeric_chars      := (Substr(To_char(1234.5,'FM9G999D9'), 6, 1) ||
			       Substr(To_char(1234.5,'FM9G999D9'), 2, 1));
   m_ds_db                 := Substr(m_db_numeric_chars, 1, 1);
   m_nls_numeric_chars_in  := m_db_numeric_chars;
   m_nls_numeric_chars_out := m_db_numeric_chars;
   m_ds_disp               := Substr(m_nls_numeric_chars_out, 1, 1);
END init_masks;

BEGIN
   chr_newline := fnd_global.newline;
   g_flag_debugging := FALSE;
   g_internal_debug := ('Debugging is turned OFF. ' || chr_newline ||
			'Please call set_debugging(TRUE) to turn it ON.');

   init_masks();
END fnd_flex_val_util;

/
