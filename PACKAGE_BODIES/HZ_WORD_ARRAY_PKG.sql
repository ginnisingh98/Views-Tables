--------------------------------------------------------
--  DDL for Package Body HZ_WORD_ARRAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_ARRAY_PKG" AS
/*$Header: ARHDQWAB.pls 120.1 2005/08/29 13:19:48 rchanamo noship $ */

/*************** Globals *****************************/
-- VJN created for implementing Associative arrays in DQM Word Replacements

PROCEDURE populate_word_arrays(wl_id NUMBER)
IS
flag varchar2(1) ;
BEGIN

-- populate word list only if it doesn't exist
IF word_list_exists(wl_id)
THEN
    NULL;

-- if it doesn't exist do the following
-- populate non_delimited flag in flag lookup array
-- populate global replacements in global array
-- populate conditional replacements by storing -1 as replacement for original word
ELSE
   select nvl(non_delimited_flag,'N') into flag
   from hz_word_lists
   where word_list_id = wl_id ;

   -- Populate flag first
   word_list_ndl_flag_lookup(wl_id) := flag ;

   -- Populate word list array with global replacements first
   FOR indx IN (
     SELECT original_word, replacement_word
       FROM HZ_WORD_REPLACEMENTS
       WHERE word_list_id = wl_id and nvl(condition_id, 0) = 0
       AND ((HZ_TRANS_PKG.staging_context = 'Y' AND DELETE_FLAG = 'N')
		OR (nvl(HZ_TRANS_PKG.staging_context,'N') = 'N' AND STAGED_FLAG = 'Y')
	   )
       )
   LOOP
      word_list_global_rep_lookup(wl_id)(indx.original_word) := indx.replacement_word ;

   END LOOP;

   -- Populate word list array with conditional replacements second
   -- Here we just mark the original word as dirty

   FOR indx IN (
     SELECT distinct original_word
       FROM HZ_WORD_REPLACEMENTS
       WHERE word_list_id = wl_id and condition_id > 0
       AND ((HZ_TRANS_PKG.staging_context = 'Y' AND DELETE_FLAG = 'N')
		OR (nvl(HZ_TRANS_PKG.staging_context,'N') = 'N' AND STAGED_FLAG = 'Y')
	   )
       order by original_word  )
   LOOP
        word_list_global_rep_lookup(wl_id)(indx.original_word) := '-1' ;
   END LOOP ;

END IF ;
END ;

FUNCTION get_global_repl_word(wl_id NUMBER, original_word VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    -- Look in global replacement array only
    IF  word_list_global_rep_lookup(wl_id)(original_word) IS NULL or
        word_list_global_rep_lookup(wl_id)(original_word) like '%'
    THEN
          RETURN word_list_global_rep_lookup(wl_id)(original_word) ;
    END IF ;

    -- if there is an exception
    EXCEPTION WHEN NO_DATA_FOUND
    THEN
        RETURN '-2' ;
END ;

FUNCTION word_list_exists(wl_id NUMBER)
RETURN BOOLEAN
IS
BEGIN
            -- Look into non delimited flag array only
            IF  word_list_ndl_flag_lookup(wl_id) in ('Y', 'N')
            THEN
                RETURN TRUE ;
            END IF ;

            EXCEPTION WHEN NO_DATA_FOUND
            THEN
                RETURN FALSE ;
END ;

END;

/
