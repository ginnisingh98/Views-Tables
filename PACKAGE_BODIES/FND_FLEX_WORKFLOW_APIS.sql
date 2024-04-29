--------------------------------------------------------
--  DDL for Package Body FND_FLEX_WORKFLOW_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_WORKFLOW_APIS" AS
/* $Header: AFFFWKAB.pls 120.1.12010000.5 2014/10/15 19:31:34 hgeorgi ship $ */

--
-- Global variables, initalized in package body init section.
--
g_debug_fnd_flex_workflow_apis BOOLEAN := FALSE;

chr_newline        VARCHAR2(8);
complete           VARCHAR2(30);
error              VARCHAR2(30);
complete_no_result VARCHAR2(30);
complete_error     VARCHAR2(30);
complete_true      VARCHAR2(30);
complete_false     VARCHAR2(30);
complete_failure   VARCHAR2(30);
complete_success   VARCHAR2(30);

-- ==================================================
-- CACHING
-- ==================================================
g_cache_return_code VARCHAR2(30);
g_cache_key         VARCHAR2(2000);
g_cache_value       fnd_plsql_cache.generic_cache_value_type;

-- --------------------------------------------------
-- uqs : Unique Qualifier to Segment Cache.
-- --------------------------------------------------
uqs_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
uqs_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- --------------------------------------------------
-- gsn : Get Segment Number Cache.
-- --------------------------------------------------
gsn_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
gsn_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- ----------------------------------------
-- idc : CCID Cache.
--
-- Primary Key For IDC : <application_short_name> || NEWLINE ||
--        <id_flex_code> || NEWLINE || <id_flex_num> || NEWLINE || <ccid>
--
-- Combination : <seg1> || NEWLINE || ... || NEWLINE || <segn> || NEWLINE
--
-- ----------------------------------------
idc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
idc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

TYPE idc_last_record_type IS RECORD
  (primary_key              VARCHAR2(32000) := NULL,
   encoded_error_message    VARCHAR2(32000),
   segment_count            NUMBER,
   segment_values           fnd_plsql_cache.cache_varchar2_varray_type);

idc_last_record      idc_last_record_type;

-- ----------------------------------------
-- ccc : Code Combination Cache.
--
-- Primary Key For CCC
-- <keyval_mode> || NEWLINE || <application_short_name> || NEWLINE ||
-- <id_flex_code> || NEWLINE || <id_flex_num> || NEWLINE ||
-- <concat_segments> || <allow_nulls> || NEWLINE || <allow_orphans>
--
-- ----------------------------------------
ccc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
ccc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

TYPE ccc_last_record_type IS RECORD
  (primary_key               VARCHAR2(32000) := NULL,
   encoded_error_message     VARCHAR2(32000),
   combination_id            NUMBER,
   concatenated_values       VARCHAR2(32000),
   concatenated_ids          VARCHAR2(32000),
   concatenated_descriptions VARCHAR2(32000),
   new_combination           BOOLEAN);

ccc_last_record      ccc_last_record_type;

FUNCTION idc_validate_ccid(p_application_short_name IN VARCHAR2,
			   p_id_flex_code           IN VARCHAR2,
			   p_id_flex_num            IN NUMBER,
			   p_ccid                   IN NUMBER)
  RETURN BOOLEAN
  IS
     l_bool            BOOLEAN;
     l_vc2             VARCHAR2(32000);
     l_pos1            NUMBER;
     l_pos2            NUMBER;
BEGIN
   g_cache_key := (p_application_short_name || '.' ||
		   p_id_flex_code || '.' ||
		   p_id_flex_num || '.' ||
		   p_ccid);

   fnd_plsql_cache.generic_1to1_get_value(idc_cache_controller,
					  idc_cache_storage,
					  g_cache_key,
					  g_cache_value,
					  g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      IF (g_cache_value.varchar2_1 IS NULL) THEN
	 --
	 -- No error message.
	 --
	 g_cache_return_code := fnd_plsql_cache.CACHE_VALID;
       ELSE
	 g_cache_return_code := fnd_plsql_cache.CACHE_INVALID;
      END IF;
   END IF;

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_VALID) THEN
      GOTO return_true;
    ELSIF (g_cache_return_code = fnd_plsql_cache.CACHE_INVALID) THEN
      GOTO return_false;
   END IF;

   --
   -- Either not found or expired. Let's validate.
   --
   l_bool := fnd_flex_keyval.validate_ccid(p_application_short_name,
					   p_id_flex_code,
					   p_id_flex_num,
					   p_ccid,
					   'ALL', NULL, NULL,
					   'IGNORE',NULL,NULL,NULL,NULL);

   IF (l_bool) THEN
      l_vc2 := NULL;
      FOR i IN 1..Nvl(fnd_flex_keyval.segment_count, 0) LOOP
	 l_vc2 := l_vc2 || fnd_flex_keyval.segment_value(i) || chr_newline;
      END LOOP;

      fnd_plsql_cache.generic_cache_new_value
	(x_value      => g_cache_value,
	 p_varchar2_1 => NULL,
	 p_number_1   => Nvl(fnd_flex_keyval.segment_count, 0),
	 p_varchar2_2 => l_vc2);

      fnd_plsql_cache.generic_1to1_put_value(idc_cache_controller,
					     idc_cache_storage,
					     g_cache_key,
					     g_cache_value);
      GOTO return_true;
    ELSE
      fnd_plsql_cache.generic_cache_new_value
	(x_value      => g_cache_value,
	 p_varchar2_1 => Nvl(fnd_flex_keyval.encoded_error_message,
			     'FND-FLEX'),
	 p_number_1   => 0,
	 p_varchar2_2 => NULL);

      fnd_plsql_cache.generic_1to1_put_value(idc_cache_controller,
					     idc_cache_storage,
					     g_cache_key,
					     g_cache_value);
      GOTO return_false;
   END IF;

   <<return_true>>
     IF ((g_cache_return_code = fnd_plsql_cache.CACHE_VALID) AND
	 (g_cache_key = idc_last_record.primary_key)) THEN
	RETURN(TRUE);
     END IF;

     idc_last_record.primary_key           := g_cache_key;
     idc_last_record.encoded_error_message := NULL;
     idc_last_record.segment_count         := g_cache_value.number_1;

     l_vc2 := g_cache_value.varchar2_2;
     l_pos1 := 1;
     l_pos2 := Instr(l_vc2, chr_newline, l_pos1, 1);
     FOR i IN 1..idc_last_record.segment_count LOOP
	idc_last_record.segment_values(i) := Substr(l_vc2, l_pos1, l_pos2 - l_pos1);
	l_pos1 := l_pos2 + Length(chr_newline);
	l_pos2 := Instr(l_vc2, chr_newline, l_pos1, 1);
     END LOOP;
     RETURN(TRUE);

   <<return_false>>
     IF ((g_cache_return_code = fnd_plsql_cache.CACHE_INVALID) AND
	 (g_cache_key = idc_last_record.primary_key)) THEN
        fnd_message.set_encoded(idc_last_record.encoded_error_message);
	RETURN(FALSE);
     END IF;

     idc_last_record.primary_key           := g_cache_key;
     idc_last_record.encoded_error_message := g_cache_value.varchar2_1;
     idc_last_record.segment_count         := 0;

     fnd_message.set_encoded(idc_last_record.encoded_error_message);

     RETURN(FALSE);

     --
     -- Let the exceptions propagate to caller.
     --
END idc_validate_ccid;

FUNCTION idc_segment_count
  RETURN NUMBER
  IS
BEGIN
   RETURN(idc_last_record.segment_count);
END idc_segment_count;

FUNCTION idc_segment_value(segnum IN NUMBER)
  RETURN VARCHAR2
  IS
BEGIN
   IF ((segnum >= 1) AND (segnum <= idc_last_record.segment_count)) THEN
      RETURN(idc_last_record.segment_values(segnum));
   END IF;
   RETURN(NULL);
END idc_segment_value;

FUNCTION ccc_validate_segs(p_operation              IN VARCHAR2,
			   p_application_short_name IN VARCHAR2,
			   p_id_flex_code           IN VARCHAR2,
			   p_id_flex_num            IN NUMBER,
			   p_concat_segments        IN VARCHAR2,
			   p_validation_date        IN DATE,
			   p_allow_nulls            IN BOOLEAN,
			   p_allow_orphans          IN BOOLEAN)
  RETURN BOOLEAN
  IS
     l_bool            BOOLEAN;
BEGIN
   g_cache_key := (p_operation || '.' ||
		   p_application_short_name || '.' ||
		   p_id_flex_code || '.' ||
		   p_id_flex_num || '.' ||
		   p_concat_segments || '.');

   IF (p_allow_nulls) THEN
      g_cache_key := g_cache_key || 'Y' || '.';
    ELSE
      g_cache_key := g_cache_key || 'N' || '.';
   END IF;

   IF (p_allow_orphans) THEN
      g_cache_key := g_cache_key || 'Y' || '.';
    ELSE
      g_cache_key := g_cache_key || 'N' || '.';
   END IF;

   IF (p_validation_date IS NOT NULL) THEN
      g_cache_key := g_cache_key ||
        To_char(p_validation_date, 'YYYY/MM/DD') || '.';
   END IF;

   fnd_plsql_cache.generic_1to1_get_value(ccc_cache_controller,
					  ccc_cache_storage,
					  g_cache_key,
					  g_cache_value,
					  g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      IF (g_cache_value.varchar2_1 IS NULL) THEN
	 --
	 -- No error message.
	 --
	 g_cache_return_code := fnd_plsql_cache.CACHE_VALID;
       ELSE
	 g_cache_return_code := fnd_plsql_cache.CACHE_INVALID;
      END IF;
   END IF;

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_VALID) THEN
      GOTO return_true;
    ELSIF (g_cache_return_code = fnd_plsql_cache.CACHE_INVALID) THEN
      GOTO return_false;
   END IF;

   --
   -- Either not found or expired. Let's validate.
   --
   l_bool := fnd_flex_keyval.validate_segs(p_operation,
					   p_application_short_name,
					   p_id_flex_code,
					   p_id_flex_num,
					   p_concat_segments,
					   'V',
					   p_validation_date,
					   'ALL', NULL, NULL, NULL, NULL,
					   p_allow_nulls,
					   p_allow_orphans, NULL, NULL, NULL);


   IF (l_bool) THEN
      fnd_plsql_cache.generic_cache_new_value
	(x_value      => g_cache_value,
	 p_varchar2_1 => NULL,
	 p_number_1   => fnd_flex_keyval.combination_id,
	 p_varchar2_2 => fnd_flex_keyval.concatenated_values,
	 p_varchar2_3 => fnd_flex_keyval.concatenated_ids,
	 p_varchar2_4 => fnd_flex_keyval.concatenated_descriptions,
	 p_boolean_1  => fnd_flex_keyval.new_combination);

      fnd_plsql_cache.generic_1to1_put_value(ccc_cache_controller,
					     ccc_cache_storage,
					     g_cache_key,
					     g_cache_value);
      GOTO return_true;
    ELSE
      fnd_plsql_cache.generic_cache_new_value
	(x_value      => g_cache_value,
	 p_varchar2_1 => Nvl(fnd_flex_keyval.encoded_error_message,
			     'FND-FLEX'),
	 p_number_1   => NULL,
	 p_varchar2_2 => NULL,
	 p_varchar2_3 => NULL,
	 p_varchar2_4 => NULL,
	 p_boolean_1  => NULL);

      fnd_plsql_cache.generic_1to1_put_value(ccc_cache_controller,
					     ccc_cache_storage,
					     g_cache_key,
					     g_cache_value);
      GOTO return_false;
   END IF;

   <<return_true>>
     IF ((g_cache_return_code = fnd_plsql_cache.CACHE_VALID) AND
	 (g_cache_key = ccc_last_record.primary_key)) THEN
	RETURN(TRUE);
     END IF;

     ccc_last_record.primary_key               := g_cache_key;
     ccc_last_record.encoded_error_message     := NULL;
     ccc_last_record.combination_id            := g_cache_value.number_1;
     ccc_last_record.concatenated_values       := g_cache_value.varchar2_2;
     ccc_last_record.concatenated_ids          := g_cache_value.varchar2_3;
     ccc_last_record.concatenated_descriptions := g_cache_value.varchar2_4;
     ccc_last_record.new_combination           := g_cache_value.boolean_1;
     RETURN(TRUE);

   <<return_false>>
     IF ((g_cache_return_code = fnd_plsql_cache.CACHE_INVALID) AND
	 (g_cache_key = ccc_last_record.primary_key)) THEN
	RETURN(FALSE);
     END IF;

     ccc_last_record.primary_key               := g_cache_key;
     ccc_last_record.encoded_error_message     := g_cache_value.varchar2_1;
     ccc_last_record.combination_id            := NULL;
     ccc_last_record.concatenated_values       := NULL;
     ccc_last_record.concatenated_ids          := NULL;
     ccc_last_record.concatenated_descriptions := NULL;
     ccc_last_record.new_combination           := NULL;
     RETURN(FALSE);

     --
     -- Let the exceptions propagate to caller.
     --
END ccc_validate_segs;

-- ======================================================================
-- DEBUG
-- ======================================================================
PROCEDURE dbms_debug(p_debug IN VARCHAR2)
  IS
     i INTEGER;
     m INTEGER;
     c INTEGER := 80;
     l_session_id NUMBER;
     utl_file_dir VARCHAR2(4000);
     L_HANDLER UTL_FILE.FILE_TYPE;
BEGIN


      --get the directory where we can write
      SELECT value into utl_file_dir FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
      --get the session id
      SELECT userenv('SESSIONID') into l_session_id from dual;

      -- If no dir defined, then try using /usr/tmp, it may not work.
      -- So you need to edit the init.ora file to include the UTL_FILE_DIR parameter.
      IF utl_file_dir IS NULL THEN
         L_HANDLER := UTL_FILE.FOPEN('/usr/tmp', 'fdfsrvdbg.log', 'A');
      ELSE
        --get the first directory from a possible several dirs
        IF instr(utl_file_dir,',') > 0 THEN
           utl_file_dir := substr(utl_file_dir,1,instr(utl_file_dir,',')-1);
         END IF;
         L_HANDLER := UTL_FILE.FOPEN(utl_file_dir, 'fdfsrvdbg.log', 'A');
      END IF;

   m := Ceil(Length(p_debug)/c);
   FOR i IN 1..m LOOP
      execute immediate ('begin dbms' ||
			 '_output' ||
			 '.put_line(''' ||
			 REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''')||
					'''); end;');
                         UTL_FILE.PUT_LINE(L_HANDLER, CONCAT(l_session_id || ' ', REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''')));
   END LOOP;
   UTL_FILE.FCLOSE(L_HANDLER);
EXCEPTION
   WHEN OTHERS THEN
      UTL_FILE.FCLOSE(L_HANDLER);
END dbms_debug;

-- ======================================================================

PROCEDURE debug(p_debug IN VARCHAR2)
  IS
     l_vc2       VARCHAR2(32000) := p_debug || chr_newline;
     l_line_size NUMBER := 75;
     l_pos       NUMBER;
BEGIN
   IF (g_debug_fnd_flex_workflow_apis) THEN
      WHILE (Nvl(Length(l_vc2),0) > 0) LOOP
	 l_pos := Instr(l_vc2, chr_newline, 1, 1);
	 IF (l_pos >= l_line_size) THEN
	    l_pos := l_line_size;
	 END IF;
	 dbms_debug(Rtrim(Substr(l_vc2, 1, l_pos), chr_newline));
	 l_vc2 := Substr(l_vc2, l_pos + 1);
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END debug;

-- ======================================================================

PROCEDURE report_wf_error(p_func_name IN VARCHAR2)
  IS
BEGIN
   IF (g_debug_fnd_flex_workflow_apis) THEN
      debug('Account Generator failed in ' || p_func_name ||
	    ' with following error.' || chr_newline ||
	    'ERROR_NAME    : ' || wf_core.error_name || chr_newline ||
	    'ERROR_MESSAGE : ' || wf_core.error_message || chr_newline ||
	    'ERROR_STACK   : ' || wf_core.error_stack || chr_newline ||
	    'SQLERRM       : ' || Sqlerrm || chr_newline ||
	    'DBMS_ERROR_STACK:' || chr_newline ||
	    dbms_utility.format_error_stack() || chr_newline ||
	    'DBMS_CALL_STACK:' || chr_newline ||
	    dbms_utility.format_call_stack());
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END report_wf_error;

-- ======================================================================
-- bool_to_char
--
-- A utility function to convert boolean values to char to print in
-- debug statements
--
FUNCTION bool_to_char(value IN BOOLEAN)
  RETURN VARCHAR2
  IS
BEGIN
   IF (value) THEN
      RETURN 'TRUE';
    ELSIF (NOT value) THEN
      RETURN 'FALSE';
    ELSE
      RETURN 'NULL';
   END IF;
END bool_to_char;

-- ======================================================================
FUNCTION char_to_bool(value IN VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   IF (value IN ('TRUE', 'Y', 'YES')) THEN
      RETURN TRUE;
    ELSIF (value IN ('FALSE', 'N', 'NO')) THEN
      RETURN FALSE;
    ELSIF (value IS NULL) THEN
      RETURN NULL;
    ELSIF (value = 'NULL') THEN
      RETURN NULL;
    ELSE
      RETURN FALSE;
   END IF;
END char_to_bool;

-- ======================================================================
-- This function returns the index of the segment identified by
-- p_segment_identifier_type/p_segment_identifier.
-- (e.g. : QUALIFIER/GL_ACCOUNT, SEGMENT/COMPANY)
--
FUNCTION segment_to_index(p_application_id          IN NUMBER,
			  p_id_flex_code            IN VARCHAR2,
			  p_id_flex_num             IN NUMBER,
			  p_segment_identifier_type IN VARCHAR2,
			  p_segment_identifier      IN VARCHAR2,
			  x_segment_index           OUT nocopy NUMBER)
  RETURN BOOLEAN
  IS
     l_segment_name  fnd_id_flex_segments.segment_name%TYPE;
     l_segment_index NUMBER;
     l_segment_num   NUMBER;
BEGIN
   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow_apis) THEN
      debug('START FND_FLEX_WORKFLOW_APIS.SEGMENT_TO_INDEX');
      debug('APPLICATION_ID = ' || To_char(p_application_id));
      debug('CODE = ' || p_id_flex_code);
      debug('NUM = ' || To_char(p_id_flex_num));
      debug('SEGMENT IDENTIFIER = ' || p_segment_identifier_type || '/' || p_segment_identifier);
   END IF;

   --
   -- If the segment is identified by a qualifier, then get the
   -- corresponding segment name. We have to extend this to
   -- handle non unique qualifier names
   --
   IF (p_segment_identifier_type = 'QUALIFIER') THEN
      BEGIN
	 --
	 -- Get the segment name, using qualifier name.
	 --
	 g_cache_key := (p_application_id || '.' || p_id_flex_code || '.' ||
			 p_id_flex_num || '.' || p_segment_identifier);
	 fnd_plsql_cache.generic_1to1_get_value(uqs_cache_controller,
						uqs_cache_storage,
						g_cache_key,
						g_cache_value,
						g_cache_return_code);
	 IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
	    l_segment_name := g_cache_value.varchar2_1;
	  ELSE
	    SELECT s.segment_name
	      INTO l_segment_name
	      FROM fnd_id_flex_segments s,
	      fnd_segment_attribute_values sav,
	      fnd_segment_attribute_types sat
	      WHERE s.application_id = p_application_id
	      AND s.id_flex_code = p_id_flex_code
	      AND s.id_flex_num = p_id_flex_num
	      AND s.enabled_flag = 'Y'
	      AND s.application_column_name = sav.application_column_name
	      AND sav.application_id = p_application_id
	      AND sav.id_flex_code = p_id_flex_code
	      AND sav.id_flex_num = p_id_flex_num
	      AND sav.attribute_value = 'Y'
	      AND sav.segment_attribute_type = sat.segment_attribute_type
	      AND sat.application_id = p_application_id
	      AND sat.id_flex_code = p_id_flex_code
	      AND sat.segment_attribute_type = p_segment_identifier;

	    fnd_plsql_cache.generic_cache_new_value
	      (x_value      => g_cache_value,
	       p_varchar2_1 => l_segment_name);

	    fnd_plsql_cache.generic_1to1_put_value(uqs_cache_controller,
						   uqs_cache_storage,
						   g_cache_key,
						   g_cache_value);
	 END IF;
      EXCEPTION
	 WHEN TOO_MANY_ROWS THEN
	    fnd_message.set_name('FND', 'FLEXWK-USE UNIQUE QUALIFIER');
	    fnd_message.set_token('QUAL', p_segment_identifier);
	    RETURN FALSE;
	 WHEN OTHERS THEN
	    fnd_message.set_name('FND', 'FLEXWK-NO SEG MATCHING QUAL');
	    fnd_message.set_token('QUAL', p_segment_identifier);
	    fnd_message.set_token('NUM', TO_CHAR(p_id_flex_num));
	    fnd_message.set_token('CODE', p_id_flex_code);
	    RETURN FALSE;
      END;
    ELSE
      l_segment_name := p_segment_identifier;
   END IF;

   --
   -- Get the sequence number for the segment name.
   --
   BEGIN
      --
      -- Get the user specified segment number
      --
      g_cache_key := (p_application_id || '.' || p_id_flex_code || '.' ||
		      p_id_flex_num || '.' || l_segment_name);
      fnd_plsql_cache.generic_1to1_get_value(gsn_cache_controller,
					     gsn_cache_storage,
					     g_cache_key,
					     g_cache_value,
					     g_cache_return_code);

      IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
	 l_segment_num := g_cache_value.number_1;
	 l_segment_index := g_cache_value.number_2;
       ELSE
	 SELECT segment_num
	   INTO l_segment_num
	   FROM fnd_id_flex_segments
	   WHERE application_id = p_application_id
	   AND id_flex_code = p_id_flex_code
	   AND id_flex_num = p_id_flex_num
	   AND segment_name = l_segment_name
	   AND enabled_flag = 'Y';

	 --
	 -- The above value gives the relative order of the
	 -- segments. Convert it into the segment index.
	 --
	 SELECT count(segment_num)
	   INTO l_segment_index
	   FROM fnd_id_flex_segments
	   WHERE application_id = p_application_id
	   AND id_flex_code = p_id_flex_code
	   AND id_flex_num = p_id_flex_num
	   AND enabled_flag = 'Y'
	   AND segment_num <= l_segment_num;

	 fnd_plsql_cache.generic_cache_new_value
	   (x_value    => g_cache_value,
	    p_number_1 => l_segment_num,
	    p_number_2 => l_segment_index);

	 fnd_plsql_cache.generic_1to1_put_value(gsn_cache_controller,
						gsn_cache_storage,
						g_cache_key,
						g_cache_value);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
	 fnd_message.set_name('FND', 'FLEXWK-CANNOT FIND SEG');
	 fnd_message.set_token('SEG', l_segment_name);
	 fnd_message.set_token('NUM', TO_CHAR(p_id_flex_num));
	 fnd_message.set_token('CODE', p_id_flex_code);
	 RETURN FALSE;
   END;

   IF (g_debug_fnd_flex_workflow_apis) THEN
      debug('SEGMENT NAME/INDEX = ' || l_segment_name || '/' || l_segment_index);
   END IF;

   x_segment_index := l_segment_index;
   RETURN TRUE;
END segment_to_index;

-- ======================================================================
-- START_GENERATION
--
--   Starts the flexfield workflow process.
--
-- Activity Attributes:
--
-- Result:<None>
--
PROCEDURE start_generation(itemtype IN  VARCHAR2,
			   itemkey  IN  VARCHAR2,
			   actid    IN  NUMBER,
			   funcmode IN  VARCHAR2,
			   result   OUT nocopy VARCHAR2)
  IS
     acct_gen_profile     VARCHAR2(1);
BEGIN
   IF (funcmode = 'RUN') THEN


      -- get profile value for "Account Generator: Run in Debug Mode"
      -- This will turn on debug for Work Flow Account Generator
      FND_PROFILE.get('ACCOUNT_GENERATOR:DEBUG_MODE', acct_gen_profile);
      if(acct_gen_profile='Y') then
         g_debug_fnd_flex_workflow_apis := TRUE;
      end if;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.START_GENERATION');
      END IF;

      result := complete_no_result;
      RETURN;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      RETURN;

    ELSE
      result := '';
      RETURN;

   END IF;
EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS', 'START_PROCESS',
		      itemtype, itemkey, TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.START_GENERATION');
      RAISE;
END start_generation;

-- ======================================================================
-- ASSIGN_TO_SEGMENT
--
--   This function is used to assign a value to a key flexfield
--   segment identified by either the segment name or a
--   flexfield qualifier.
--
-- Activity Attributes:
--   SEGMENT_IDENTIFIER     {SEGMENT|QUALIFIER}
--   SEGMENT                {varchar2(30)}
--   VALUE                  {varchar2(240)}
--   REPLACE_CURRENT_VALUE  {TRUE|FALSE}
--
-- Result:<None>
--
PROCEDURE assign_to_segment(itemtype IN  VARCHAR2,
			    itemkey  IN  VARCHAR2,
			    actid    IN  NUMBER,
			    funcmode IN  VARCHAR2,
			    result   OUT nocopy VARCHAR2)
  IS
     l_key_flex        fnd_flex_workflow.key_flex_type;
     l_segment_id_type VARCHAR2(30);
     l_segment_id      VARCHAR2(30);
     l_segment_index   NUMBER;
     l_segment_value   VARCHAR2(240);
     l_replace_value   BOOLEAN;
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.ASSIGN_TO_SEGMENT');
      END IF;

      --
      -- Get the key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get all the function activity attributes
      --
      l_segment_id_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
							 'SEGMENT_IDENTIFIER');
      l_segment_id := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						    'SEGMENT');
      l_segment_value := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						     'VALUE');
      l_replace_value := char_to_bool(wf_engine.GetActivityAttrText
				      (itemtype, itemkey, actid,
				       'REPLACE_CURRENT_VALUE'));

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('SEGMENT_IDENTIFIER = ' || l_segment_id_type);
	 debug('SEGMENT = ' || l_segment_id);
	 debug('VALUE = ' || l_segment_value);
	 debug('REPLACE_CURRENT_VALUE = ' || bool_to_char(l_replace_value));
      END IF;

      --
      -- Get the segment index.
      --
      IF (NOT segment_to_index(l_key_flex.application_id,
			       l_key_flex.id_flex_code,
			       l_key_flex.id_flex_num,
			       l_segment_id_type, l_segment_id,
			       l_segment_index)) THEN
	 GOTO return_error;
      END IF;

      --
      -- If the replace flag is true or the current value is NULL then
      -- replace the current value, else don't touch it.
      --
      IF ((l_replace_value) OR
	  (wf_engine.GetItemAttrText(itemtype, itemkey,
				     'FND_FLEX_SEGMENT' || TO_CHAR(l_segment_index)) IS NULL)) THEN
	 wf_engine.SetItemAttrText(itemtype, itemkey,
				   'FND_FLEX_SEGMENT' || TO_CHAR(l_segment_index),
				   l_segment_value);

	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALUE ASSIGNED IS ' || l_segment_value);
	 END IF;
       ELSE
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALUE NOT ASSIGNED');
	 END IF;
      END IF;

      result := complete_no_result;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'ASSIGN_TO_SEGMENT';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS', 'ASSIGN_TO_SEGMENT',
		      itemtype, itemkey, TO_CHAR(actid), funcmode);

      report_wf_error('FND_FLEX_WORKFLOW_APIS.ASSIGN_TO_SEGMENT');
      RAISE;
END assign_to_segment;

-- ======================================================================
-- GET_VALUE_FROM_COMBINATION
--
--  This procdure returns the value for a specified segment from a given
--  code combination. The segment can be identified by either the
--  segment name or flexfield qualifier.
--
-- Activity Attributes:
--   SEGMENT_IDENTIFIER     {SEGMENT|QUALIFIER}
--   SEGMENT                {varchar2(30)}
--   CODE_COMBINATION_ID    {number}
--   RETURN_VALUE_ATTRIBUTE {varchar2(240)}
--
-- Result:<None>
--
PROCEDURE get_value_from_combination(itemtype IN  VARCHAR2,
				     itemkey  IN  VARCHAR2,
				     actid    IN  NUMBER,
				     funcmode IN  VARCHAR2,
				     result   OUT nocopy VARCHAR2)
  IS
     l_key_flex        fnd_flex_workflow.key_flex_type;
     l_segment_id_type VARCHAR2(30);
     l_segment_id      VARCHAR2(30);
     l_segment_index   NUMBER;
     l_ccid            NUMBER;
     l_result_attr     VARCHAR2(240);
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION');
      END IF;

      --
      -- Get the key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get all the function activity attributes
      --
      l_segment_id_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
							 'SEGMENT_IDENTIFIER');
      l_segment_id := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						    'SEGMENT');
      l_ccid := wf_engine.GetActivityAttrNumber(itemtype, itemkey, actid,
						'CODE_COMBINATION_ID');
      l_result_attr := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						     'RETURN_VALUE_ATTRIBUTE');

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('SEGMENT_IDENTIFIER = ' || l_segment_id_type);
	 debug('SEGMENT = ' || l_segment_id);
	 debug('CCID = ' || TO_CHAR(l_ccid));
	 debug('RETURN_VALUE_ATTRIBUTE = ' || l_result_attr);
      END IF;

      --
      -- Get the segment index.
      --
      IF (NOT segment_to_index(l_key_flex.application_id,
			       l_key_flex.id_flex_code,
			       l_key_flex.id_flex_num,
			       l_segment_id_type,
			       l_segment_id,
			       l_segment_index)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Use the IDC cache to get the segment values for this ccid.
      --
      IF (NOT idc_validate_ccid(l_key_flex.application_short_name,
				l_key_flex.id_flex_code,
				l_key_flex.id_flex_num,
				l_ccid)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Return the value that was asked for.
      --
      wf_engine.SetItemAttrText(itemtype, itemkey, l_result_attr,
				idc_segment_value(l_segment_index));

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('VALUE ASSIGNED IS ' || idc_segment_value(l_segment_index));
      END IF;

      result := complete_no_result;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'GET_VALUE_FROM_COMBINATION';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'GET_VALUE_FROM_COMBINATION', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION');
      RAISE;
END get_value_from_combination;

-- ======================================================================
-- GET_VALUE_FROM_COMBINATION2
--
-- This procedure copied/pasted from get_value_from_combination.
-- It is provided to get values from a different structure combination.
-- Note: Not from a different flexfield.
-- See bug845445.
-- This procdure returns the value for a specified segment from a given
-- code combination. The segment can be identified by either the
-- segment name or flexfield qualifier.
--
-- Activity Attributes:
--   STRUCTURE_NUMBER       {number}
--   SEGMENT_IDENTIFIER     {SEGMENT|QUALIFIER}
--   SEGMENT                {varchar2(30)}
--   CODE_COMBINATION_ID    {number}
--   RETURN_VALUE_ATTRIBUTE {varchar2(240)}
--
-- Result:<None>
--
PROCEDURE get_value_from_combination2(itemtype IN  VARCHAR2,
				      itemkey  IN  VARCHAR2,
				      actid    IN  NUMBER,
				      funcmode IN  VARCHAR2,
				      result   OUT nocopy VARCHAR2)
  IS
     l_key_flex             fnd_flex_workflow.key_flex_type;
     l_source_id_flex_num   NUMBER;
     l_segment_id_type      VARCHAR2(30);
     l_segment_id           VARCHAR2(30);
     l_source_segment_index NUMBER;
     l_ccid                 NUMBER;
     l_result_attr          VARCHAR2(240);
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION2');
      END IF;

      --
      -- Get the original key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get all the function activity attributes
      --
      l_source_id_flex_num := wf_engine.GetActivityAttrNumber(itemtype, itemkey, actid,
							      'STRUCTURE_NUMBER');
      l_segment_id_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						       'SEGMENT_IDENTIFIER');
      l_segment_id := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						  'SEGMENT');
      l_ccid := wf_engine.GetActivityAttrNumber(itemtype, itemkey, actid,
						'CODE_COMBINATION_ID');
      l_result_attr := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						     'RETURN_VALUE_ATTRIBUTE');

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('SOURCE NUM = ' || TO_CHAR(l_source_id_flex_num));
	 debug('SEGMENT_IDENTIFIER = ' || l_segment_id_type);
	 debug('SEGMENT = ' || l_segment_id);
	 debug('CCID = ' || TO_CHAR(l_ccid));
	 debug('RETURN_VALUE_ATTRIBUTE = ' || l_result_attr);
      END IF;

      --
      -- Get the source segment index.
      --
      IF (NOT segment_to_index(l_key_flex.application_id,
			       l_key_flex.id_flex_code,
			       l_source_id_flex_num,
			       l_segment_id_type,
			       l_segment_id,
			       l_source_segment_index)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Use the IDC cache to get the segment values for this ccid.
      --
      IF (NOT idc_validate_ccid(l_key_flex.application_short_name,
				l_key_flex.id_flex_code,
				l_source_id_flex_num,
				l_ccid)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Return the value that was asked for.
      --
      wf_engine.SetItemAttrText(itemtype, itemkey, l_result_attr,
				idc_segment_value(l_source_segment_index));

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('VALUE ASSIGNED IS ' || idc_segment_value(l_source_segment_index));
      END IF;

      result := complete_no_result;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'GET_VALUE_FROM_COMBINATION2';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'GET_VALUE_FROM_COMBINATION2', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION2');
      RAISE;
END get_value_from_combination2;

-- ======================================================================
-- COPY_FROM_COMBINATION
--
--   This procedure copies values from a specified combination.
--
-- Activity Attributes:
--   CODE_COMBINATION_ID    {number}
--   REPLACE_CURRENT_VALUE  {TRUE|FALSE}
--
-- Result:<None>
--
PROCEDURE copy_from_combination(itemtype IN  VARCHAR2,
				itemkey  IN  VARCHAR2,
				actid    IN  NUMBER,
				funcmode IN  VARCHAR2,
				result   OUT nocopy VARCHAR2)
  IS
     l_key_flex      fnd_flex_workflow.key_flex_type;

     l_ccid          NUMBER;
     l_nsegments     NUMBER;
     l_replace_value BOOLEAN;
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.COPY_FROM_COMBINATION');
      END IF;

      --
      -- Get the key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get all the function activity attributes
      --
      l_ccid := wf_engine.GetActivityAttrNumber(itemtype, itemkey, actid,
						'CODE_COMBINATION_ID');
      l_replace_value := char_to_bool(wf_engine.GetActivityAttrText
				      (itemtype, itemkey, actid,
				       'REPLACE_CURRENT_VALUE'));
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('CCID = ' || TO_CHAR(l_ccid));
	 debug('REPLACE_CURRENT_VALUE = ' || bool_to_char(l_replace_value));
      END IF;

      --
      -- Use the IDC cache to get the segment values for this ccid.
      --
      IF (NOT idc_validate_ccid(l_key_flex.application_short_name,
				l_key_flex.id_flex_code,
				l_key_flex.id_flex_num,
				l_ccid)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Now assign them to the segment attributes
      -- after checking the replace flag.
      --
      l_nsegments := idc_segment_count();
      FOR i IN 1..l_nsegments LOOP
	 IF (l_replace_value OR
	     (wf_engine.GetItemAttrText(itemtype, itemkey,
					'FND_FLEX_SEGMENT' || TO_CHAR(i)) IS NULL)) THEN
	    wf_engine.SetItemAttrText(itemtype, itemkey,
				      'FND_FLEX_SEGMENT' || TO_CHAR(i),
				      idc_segment_value(i));
	    --
	    -- Debug
	    --
	    IF (g_debug_fnd_flex_workflow_apis) THEN
	       debug('VALUE ASSIGNED TO SEGMENT ' || TO_CHAR(i) || ' IS ' ||
		     idc_segment_value(i));
	    END IF;
	 END IF;
      END LOOP;

      result := complete_no_result;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'COPY_FROM_COMBINATION';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'COPY_FROM_COMBINATION', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.COPY_FROM_COMBINATION');
      RAISE;
END copy_from_combination;

-- ======================================================================
-- COPY_SEGMENT_FROM_COMBINATION
--
--   This procedure copies a given segment value from a
--   specified combination.
--
-- Activity Attributes:
--   CODE_COMBINATION_ID    {number}
--   SEGMENT_IDENTIFIER     {SEGMENT|QUALIFIER}
--   SEGMENT                {varchar2(30)}
--   REPLACE_CURRENT_VALUE  {TRUE|FALSE}
--
-- Result:<None>
--
PROCEDURE copy_segment_from_combination(itemtype IN  VARCHAR2,
					itemkey  IN  VARCHAR2,
					actid    IN  NUMBER,
					funcmode IN  VARCHAR2,
					result   OUT nocopy VARCHAR2)
  IS
     l_key_flex        fnd_flex_workflow.key_flex_type;
     l_ccid            NUMBER;
     l_segment_id_type VARCHAR2(30);
     l_segment_id      VARCHAR2(30);
     l_segment_index   NUMBER;
     l_replace_value   BOOLEAN;
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION');
      END IF;

      --
      -- Get the key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get all the function activity attributes
      --
      l_segment_id_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						       'SEGMENT_IDENTIFIER');
      l_segment_id := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						  'SEGMENT');
      l_ccid := wf_engine.GetActivityAttrNumber(itemtype, itemkey, actid,
						'CODE_COMBINATION_ID');
      l_replace_value := char_to_bool(wf_engine.GetActivityAttrText
				      (itemtype, itemkey, actid,
				       'REPLACE_CURRENT_VALUE'));

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('SEGMENT_IDENTIFIER = ' || l_segment_id_type);
	 debug('SEGMENT = ' || l_segment_id);
	 debug('CCID = ' || TO_CHAR(l_ccid));
	 debug('REPLACE_CURRENT_VALUE = ' || bool_to_char(l_replace_value));
      END IF;

      --
      -- Get the segment index.
      --
      IF (NOT segment_to_index(l_key_flex.application_id,
			       l_key_flex.id_flex_code,
			       l_key_flex.id_flex_num,
			       l_segment_id_type,
			       l_segment_id,
			       l_segment_index)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Use the IDC cache to get the segment values for this ccid.
      --
      IF (NOT idc_validate_ccid(l_key_flex.application_short_name,
				l_key_flex.id_flex_code,
				l_key_flex.id_flex_num,
				l_ccid)) THEN
	 GOTO return_error;
      END IF;

      --
      -- now assign the required value to the segment
      -- attribute after checking the replace segment flag.
      --
      IF (l_replace_value OR
	  (wf_engine.GetItemAttrText(itemtype, itemkey,
				     'FND_FLEX_SEGMENT' || TO_CHAR(l_segment_index))
	   IS NULL)) THEN
	 wf_engine.SetItemAttrText(itemtype, itemkey,
				   'FND_FLEX_SEGMENT' || TO_CHAR(l_segment_index),
				   idc_segment_value(l_segment_index));
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALUE ASSIGNED : ' || idc_segment_value(l_segment_index));
	 END IF;
       ELSE
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALUE NOT ASSIGNED');
	 END IF;
      END IF;

      result := complete_no_result;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'COPY_SEGMENT_FROM_COMBINATION';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'COPY_SEGMENT_FROM_COMBINATION', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION');
      RAISE;
END copy_segment_from_combination;

-- ======================================================================
-- COPY_SEGMENT_FROM_COMBINATION2
--
--  This procedure copied/pasted from copy_segment_from_combination.
--  It is provided to copy values from a different structure combination.
--  Note: Not from a different flexfield.
--  See bug845445.
--
--   This procedure copies a given segment value from a
--   specified combination.
--
-- Activity Attributes:
--   STRUCTURE_NUMBER       {number}
--   CODE_COMBINATION_ID    {number}
--   SEGMENT_IDENTIFIER     {SEGMENT|QUALIFIER}
--   SEGMENT                {varchar2(30)}
--   REPLACE_CURRENT_VALUE  {TRUE|FALSE}
--
-- Result:<None>
--
PROCEDURE copy_segment_from_combination2(itemtype IN  VARCHAR2,
					 itemkey  IN  VARCHAR2,
					 actid    IN  NUMBER,
					 funcmode IN  VARCHAR2,
					 result   OUT nocopy VARCHAR2)
  IS
     l_key_flex                  fnd_flex_workflow.key_flex_type;
     l_source_id_flex_num        NUMBER;
     l_destination_id_flex_num   NUMBER;
     l_ccid                      NUMBER;
     l_segment_id_type           VARCHAR2(30);
     l_segment_id                VARCHAR2(30);
     l_source_segment_index      NUMBER;
     l_destination_segment_index NUMBER;
     l_replace_value             BOOLEAN;
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION2');
      END IF;

      --
      -- Get the original key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get all the function activity attributes
      --
      l_source_id_flex_num := wf_engine.GetActivityAttrNumber(itemtype, itemkey, actid,
							      'STRUCTURE_NUMBER');
      l_segment_id_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
							 'SEGMENT_IDENTIFIER');
      l_segment_id := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
						    'SEGMENT');
      l_ccid := wf_engine.GetActivityAttrNumber(itemtype, itemkey, actid,
						'CODE_COMBINATION_ID');
      l_replace_value := char_to_bool(wf_engine.GetActivityAttrText
				      (itemtype, itemkey, actid,
				       'REPLACE_CURRENT_VALUE'));

      l_destination_id_flex_num := l_key_flex.id_flex_num;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('SOURCE NUM = ' || To_char(l_source_id_flex_num));
	 debug('DEST NUM = ' || To_char(l_destination_id_flex_num));
	 debug('SEGMENT_IDENTIFIER = ' || l_segment_id_type);
	 debug('SEGMENT = ' || l_segment_id);
	 debug('CCID = ' || TO_CHAR(l_ccid));
	 debug('REPLACE_CURRENT_VALUE = ' || bool_to_char(l_replace_value));
      END IF;

      --
      -- Get the source segment index.
      --
      IF (NOT segment_to_index(l_key_flex.application_id,
			       l_key_flex.id_flex_code,
			       l_source_id_flex_num,
			       l_segment_id_type,
			       l_segment_id,
			       l_source_segment_index)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Get the destination segment index.
      --
      IF (NOT segment_to_index(l_key_flex.application_id,
			       l_key_flex.id_flex_code,
			       l_destination_id_flex_num,
			       l_segment_id_type,
			       l_segment_id,
			       l_destination_segment_index)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Use the IDC cache to get the source segment values for this ccid.
      --
      IF (NOT idc_validate_ccid(l_key_flex.application_short_name,
				l_key_flex.id_flex_code,
				l_source_id_flex_num,
				l_ccid)) THEN
	 GOTO return_error;
      END IF;

      --
      -- Now assign the required value to the destination segment
      -- attribute after checking the replace segment flag.
      --
      IF (l_replace_value OR
	  (wf_engine.GetItemAttrText(itemtype, itemkey,
				     'FND_FLEX_SEGMENT' || TO_CHAR(l_destination_segment_index))
	   IS NULL)) THEN
	 wf_engine.SetItemAttrText(itemtype, itemkey,
				   'FND_FLEX_SEGMENT' || TO_CHAR(l_destination_segment_index),
				   idc_segment_value(l_source_segment_index));
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALUE ASSIGNED : ' || idc_segment_value(l_source_segment_index));
	 END IF;
       ELSE
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALUE NOT ASSIGNED');
	 END IF;
      END IF;

      result := complete_no_result;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'COPY_SEGMENT_FROM_COMBINATION2';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'COPY_SEGMENT_FROM_COMBINATION2', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION2');
      RAISE;
END copy_segment_from_combination2;

-- ======================================================================
-- IS_COMBINATION_COMPLETE
--
--   This procedure checks to see if all the segments in the combination
--   have been assigned a value. If the attribute CHECK_ONLY_FOR_REQUIRED
--   is set to TRUE, only required segments need to have values.
--
-- Activity Attributes:
--   CHECK_ONLY_FOR_REQUIRED   {TRUE|FALSE}
--
-- Result:
--   TRUE
--   FALSE
--
PROCEDURE is_combination_complete(itemtype IN  VARCHAR2,
				  itemkey  IN  VARCHAR2,
				  actid    IN  NUMBER,
				  funcmode IN  VARCHAR2,
				  result   OUT nocopy VARCHAR2)
  IS
     l_key_flex        fnd_flex_workflow.key_flex_type;
     l_non_required_ok BOOLEAN;
     l_segment_index   NUMBER;

     CURSOR cur(p_application_id IN NUMBER,
		p_id_flex_code   IN VARCHAR2,
		p_id_flex_num    IN NUMBER) IS
	SELECT required_flag
	  FROM fnd_id_flex_segments
	  WHERE application_id = p_application_id
	  AND id_flex_code = p_id_flex_code
	  AND id_flex_num = p_id_flex_num
	  AND enabled_flag = 'Y'
          ORDER BY segment_num;
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.IS_COMBINATION_COMPLETE');
      END IF;

      --
      -- Get the key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get all the function activity attributes
      --
      l_non_required_ok := char_to_bool(wf_engine.GetActivityAttrText
					(itemtype, itemkey, actid,
					 'CHECK_ONLY_FOR_REQUIRED'));

      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('CHECK_ONLY_FOR_REQUIRED = ' || bool_to_char(l_non_required_ok));
      END IF;

      --
      -- Loop through all the segments and check if all of them have values.
      --
      l_segment_index := 0;
      FOR cur_rec IN cur(l_key_flex.application_id,
			 l_key_flex.id_flex_code,
			 l_key_flex.id_flex_num) LOOP
	 l_segment_index := l_segment_index + 1;
	 IF ((wf_engine.GetItemAttrText(itemtype, itemkey,
					'FND_FLEX_SEGMENT' || TO_CHAR(l_segment_index)) IS NULL) AND
	     ((cur_rec.required_flag = 'Y') OR
	      (NOT l_non_required_ok))) THEN
	    --
	    -- Debug
	    --
	    IF (g_debug_fnd_flex_workflow_apis) THEN
	       debug('COMBINATION NOT COMPLETE');
	    END IF;
	    result := complete_false;
	    GOTO return_success;
	 END IF;
      END LOOP;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('COMBINATION COMPLETE');
      END IF;

      result := complete_true;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'IS_COMBINATION_COMPLETE';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'IS_COMBINATION_COMPLETE', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.IS_COMBINATION_COMPLETE');
      RAISE;
END is_combination_complete;

-- ======================================================================
-- VALIDATE_COMBINATION
--
--   This procedure validates the combination to generate the code
--   combination id, concatenated segment values, concatenated ids
--   and descriptions.
--
-- Activity Attributes:
--   DYNAMIC_INSERTS_ALLOWED  {TRUE|FALSE}
--   VALIDATION_TYPE          {GENERATE_CCID|VALIDATE_VALUES}
--   CHECK_EXPIRATION         {Y|N}
--   VALIDATION_DATE          {date}
--
-- Result:<None>
--
PROCEDURE validate_combination(itemtype IN  VARCHAR2,
			       itemkey  IN  VARCHAR2,
			       actid    IN  NUMBER,
			       funcmode IN  VARCHAR2,
			       result   OUT nocopy VARCHAR2)
  IS
     l_key_flex          fnd_flex_workflow.key_flex_type;

     l_insert_if_new     BOOLEAN;
     l_dinserts_ok       BOOLEAN;
     l_validation_type   VARCHAR2(100);
     l_check_expiration  VARCHAR2(1);
     l_validation_date   DATE;

     l_segment_array     FND_FLEX_EXT.SegmentArray;
     l_concat_segs       VARCHAR2(2000);
     l_delimiter         VARCHAR2(10);

     l_keyval_mode       VARCHAR2(100);
     l_keyval_status     BOOLEAN;
     l_allow_nulls       BOOLEAN;
     l_allow_orphans     BOOLEAN;
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.VALIDATE_COMBINATION');
      END IF;

      --
      -- Get the key flex.
      --
      fnd_flex_workflow.get_key_flex(itemtype, itemkey, l_key_flex);

      --
      -- Get the item attributes
      --
      l_insert_if_new := char_to_bool(wf_engine.GetItemAttrText
				      (itemtype, itemkey,
				       'FND_FLEX_INSERT'));
      --
      -- Get all the function activity attributes
      --
      l_dinserts_ok := char_to_bool(wf_engine.GetActivityAttrText
				    (itemtype, itemkey, actid,
				     'DYNAMIC_INSERTS_ALLOWED'));
      l_validation_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,
							 'VALIDATION_TYPE');
      l_check_expiration := Nvl(wf_engine.GetActivityAttrText
				(itemtype, itemkey, actid,
				 'CHECK_EXPIRATION',TRUE), 'Y');

      --
      -- If no date is specified then default it to Sysdate.
      -- IF check_expiration is turned off then set validation_date
      -- to NULL, this will turn off the vdate check in SSV engine.
      --
      IF (l_check_expiration = 'Y') THEN
	 l_validation_date := Nvl(wf_engine.GetActivityAttrDate
				  (itemtype, itemkey, actid,
				   'VALIDATION_DATE',TRUE), Sysdate);
       ELSE
	 l_validation_date := NULL;
      END IF;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('INSERT IF NEW COMBINATION = ' || bool_to_char(l_insert_if_new));
	 debug('DYNAMIC_INSERTS_ALLOWED = ' || bool_to_char(l_dinserts_ok));
	 debug('VALIDATION_TYPE = ' || l_validation_type);
	 debug('CHECK EXPIRATION = ' || l_check_expiration);
	 debug('VALIDATION DATE = ' || To_char(l_validation_date,
					       'YYYY/MM/DD HH24:MI:SS'));
      END IF;

      --
      -- Populate the segment array with the segment values
      --
      FOR i IN 1..l_key_flex.numof_segments LOOP
	 l_segment_array(i) :=
	   wf_engine.GetItemAttrText(itemtype, itemkey,
				     'FND_FLEX_SEGMENT' || TO_CHAR(i));
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('FND_FLEX_SEGMENT' || TO_CHAR(i) || ' IS ' ||
		  l_segment_array(i));
	 END IF;
      END LOOP;

      --
      -- Use the FND_FLEX_EXT pacakge to concatenate the segments
      --
      l_delimiter := fnd_flex_ext.get_delimiter(l_key_flex.application_short_name,
						l_key_flex.id_flex_code,
						l_key_flex.id_flex_num);
      IF (l_delimiter = NULL) THEN
	 GOTO return_error;
      END IF;
      l_concat_segs := fnd_flex_ext.concatenate_segments(l_key_flex.numof_segments,
							 l_segment_array,
							 l_delimiter);

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('CONCATENATED SEGMENTS TO BE VALIDATED IS ' || l_concat_segs);
      END IF;

      --
      -- Use the CCC Cache package to validate the combination
      --
      IF (l_validation_type = 'VALIDATE_VALUES') THEN
	 l_keyval_mode := 'CHECK_SEGMENTS';
	 l_allow_nulls := TRUE;
	 l_allow_orphans := TRUE;
       ELSIF (l_validation_type = 'GENERATE_CCID') THEN
	 IF (NOT l_dinserts_ok) THEN
	    l_keyval_mode := 'FIND_COMBINATION';
	  ELSE
	    IF (l_insert_if_new) THEN
	       l_keyval_mode := 'CREATE_COMBINATION';
	     ELSE
	       l_keyval_mode := 'CHECK_COMBINATION';
	    END IF;
	 END IF;
	 l_allow_nulls := FALSE;
	 l_allow_orphans := FALSE;
      END IF;

      l_keyval_status := ccc_validate_segs(l_keyval_mode,
					   l_key_flex.application_short_name,
					   l_key_flex.id_flex_code,
					   l_key_flex.id_flex_num,
					   l_concat_segs,
					   l_validation_date,
					   l_allow_nulls,
					   l_allow_orphans);

      IF (NOT l_keyval_status) THEN
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALIDATION FAILED');
	 END IF;

	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_STATUS',
				   'INVALID');
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_MESSAGE',
				   ccc_last_record.encoded_error_message);
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_CCID',
				   '0');
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_SEGMENTS',
				   l_concat_segs);
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DATA',
				   '');
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DESCRIPTIONS',
				   '');
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_NEW',
				   'N');

	 result := complete_no_result;
	 GOTO return_success;

       ELSE
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow_apis) THEN
	    debug('VALIDATION SUCCEEDED');
	    debug('CCID IS ' || TO_CHAR(ccc_last_record.combination_id));
	 END IF;

	 wf_engine.SetItemAttrText
	   (itemtype, itemkey, 'FND_FLEX_STATUS', 'VALID');
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_CCID',
				   To_char(ccc_last_record.combination_id));
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_SEGMENTS',
				   ccc_last_record.concatenated_values);
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DATA',
				   ccc_last_record.concatenated_ids);
	 wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DESCRIPTIONS',
				   ccc_last_record.concatenated_descriptions);
	 IF (l_keyval_mode = 'CREATE_COMBINATION' AND
	     ccc_last_record.new_combination) THEN
	    wf_engine.SetItemAttrText
	      (itemtype, itemkey, 'FND_FLEX_NEW', 'Y');
	  ELSE
	    wf_engine.SetItemAttrText
	      (itemtype, itemkey, 'FND_FLEX_NEW', 'N');
	 END IF;

	 result := complete_no_result;
	 GOTO return_success;
      END IF;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

   <<return_error>>
     --
     -- Fatal error abort!
     --
     wf_engine.SetItemAttrText(itemtype, itemkey,
			       'FND_FLEX_MESSAGE', fnd_message.get_encoded);
     result := error || 'VALIDATE_COMBINATION';
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'VALIDATE_COMBINATION', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.VALIDATE_COMBINATION');
      RAISE;
END validate_combination;

-- ======================================================================
-- ABORT_GENERATION
--
--   This process is used to abort the combination generation process.
--   An error message can be passed to this function which can be displayed
--   from the calling form or program.
--   This process terminates the top level process and returns
--   a result of FAILURE.
--
-- Activity Attribute:
--   ERROR_MESSAGE    {varchar2(2000)}
--
-- Result:
--   FAILURE
--
PROCEDURE abort_generation(itemtype IN  VARCHAR2,
			   itemkey  IN  VARCHAR2,
			   actid    IN  NUMBER,
			   funcmode IN  VARCHAR2,
			   result   OUT nocopy VARCHAR2)
  IS
     l_errmsg VARCHAR2(2000) DEFAULT '';
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.ABORT_GENERATION');
      END IF;

      --
      -- Get the function activity attribute
      --
      l_errmsg := wf_engine.GetActivityAttrText(itemtype, itemkey,
						actid, 'ERROR_MESSAGE');

      --
      -- Save the error message passed in.
      --
      wf_engine.SetItemAttrText(itemtype, itemkey,
				'FND_FLEX_MESSAGE', l_errmsg);

      result := complete_failure;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'END_IN_FAILURE', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.ABORT_GENERATION');
      RAISE;
END abort_generation;

-- ======================================================================
-- END_GENERATION
--
--   This procedure marks the ending of the code combination generation
--   process without any errors.
--
-- Activity Attribute:
--
-- Result:
--   SUCCESS
--
PROCEDURE end_generation(itemtype IN  VARCHAR2,
			 itemkey  IN  VARCHAR2,
			 actid    IN  NUMBER,
			 funcmode IN  VARCHAR2,
			 result   OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (funcmode = 'RUN') THEN
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow_apis) THEN
	 debug('START FND_FLEX_WORKFLOW_APIS.END_GENERATION');
      END IF;

      result := complete_success;
      GOTO return_success;

    ELSIF (funcmode = 'CANCEL') THEN
      result := complete;
      GOTO return_success;

    ELSE
      result := '';
      GOTO return_success;

   END IF;

   <<return_success>>
     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW_APIS',
		      'END_IN_SUCCESS', itemtype, itemkey,
		      TO_CHAR(actid), funcmode);
      report_wf_error('FND_FLEX_WORKFLOW_APIS.END_GENERATION');
      RAISE;
END end_generation;

-- ======================================================================
-- Set the debug mode on
--
PROCEDURE debug_on IS
BEGIN
   execute immediate ('begin dbms' ||
		      '_output' ||
		      '.enable(1000000); end;');
   g_debug_fnd_flex_workflow_apis := TRUE;
END debug_on;

--
-- Set the debug mode off
--
PROCEDURE debug_off IS
BEGIN
   g_debug_fnd_flex_workflow_apis := FALSE;
END debug_off;

BEGIN
   chr_newline        := fnd_global.newline;
   complete           := wf_engine.eng_completed;
   error              := wf_engine.eng_error || ':';
   complete_no_result := wf_engine.eng_completed || ':' || wf_engine.eng_null;
   complete_error     := wf_engine.eng_completed || ':' || wf_engine.eng_error;
   complete_true      := wf_engine.eng_completed || ':' || 'TRUE';
   complete_false     := wf_engine.eng_completed || ':' || 'FALSE';
   complete_failure   := wf_engine.eng_completed || ':' || 'FAILURE';
   complete_success   := wf_engine.eng_completed || ':' || 'SUCCESS';


   fnd_plsql_cache.generic_1to1_init('WKA.UQS',
				     uqs_cache_controller,
				     uqs_cache_storage);

   fnd_plsql_cache.generic_1to1_init('WKA.GSN',
				     gsn_cache_controller,
				     gsn_cache_storage);

   fnd_plsql_cache.generic_1to1_init('WKA.IDC',
				     idc_cache_controller,
				     idc_cache_storage);

   fnd_plsql_cache.generic_1to1_init('WKA.CCC',
				     ccc_cache_controller,
				     ccc_cache_storage);

   idc_last_record.segment_values := fnd_plsql_cache.cache_varchar2_varray_type();
   idc_last_record.segment_values.EXTEND(fnd_plsql_cache.CACHE_MAX_NUMOF_KEYS);
END fnd_flex_workflow_apis;

/
