--------------------------------------------------------
--  DDL for Package HZ_WORD_ARRAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_ARRAY_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQWAS.pls 120.0 2005/03/14 22:10:58 cvijayan noship $ */

-- VJN created for implementing Associative arrays in DQM Word Replacements
TYPE word_rep_array IS
      TABLE OF hz_word_replacements.original_word%TYPE
      INDEX BY hz_word_replacements.replacement_word%TYPE ;

TYPE word_list_array IS
      TABLE OF word_rep_array
      INDEX BY BINARY_INTEGER ;

TYPE word_list_ndl_flag_array IS
      TABLE OF VARCHAR2(1)
      INDEX BY BINARY_INTEGER ;


-- word replacement array
word_rep_lookup word_rep_array ;

-- word list array for global replacements
word_list_global_rep_lookup word_list_array ;

-- word list array for non delimited flag lookup
word_list_ndl_flag_lookup word_list_ndl_flag_array ;


-- Procedure to populate all the above 3 arrays for a word list
PROCEDURE populate_word_arrays(wl_id NUMBER) ;

-- Getter for a global replacement
FUNCTION get_global_repl_word(wl_id NUMBER, original_word VARCHAR2)
RETURN VARCHAR2 ;

-- Existence check for a word list
FUNCTION word_list_exists(wl_id NUMBER)
RETURN BOOLEAN ;


END;

 

/
