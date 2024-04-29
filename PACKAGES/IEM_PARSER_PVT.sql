--------------------------------------------------------
--  DDL for Package IEM_PARSER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_PARSER_PVT" AUTHID CURRENT_USER as
/* $Header: iemparbs.pls 120.6 2005/10/03 15:21:55 appldev noship $*/
/*
  -- some constants

  MAXWORDLENGTH integer := 32;   -- any words longer than this are discarded
  WINDOWSIZE    integer := 3;    -- max length of phrase stored - can be tuned
  --WINDOWSIZE    integer := 1;    -- max length of phrase stored - can be tuned
                                 -- higher value = more accuracy, but
                                 -- more time and space for processing
  DOCLENGTH     integer := 4096; -- only this much of each document is processed

  -- replicate the "ctx_doc.themes" interface

  procedure p_themes (
	index_name      in  varchar2,
	-- textkey         in  varchar2,
	-- restab          in out  ctx_doc.theme_tab,
	restab       in out NOCOPY iem_im_wrappers_pvt.theme_table,
	full_themes     in  boolean default true,
	num_themes      in  number  default 32,
	document		 in	varchar2,
	pictograph      in boolean default false
     );

  -- compute word vector for varchar2 strings

  function compute_vector (
    idx_name         in varchar2, --DEFAULT fnd_api.g_miss_char,
          -- Must provide name of Text index
    document         in varchar2,          -- Text to be analyzed
    analyze_length   in integer default 5000,
    window_size      in integer default 3  -- Maximum size of phrases
    )
  return word_vector;

  -- compute word vector for clobs

  function compute_vector (
    idx_name         in varchar2,          -- Must provide name of Text index
    document         in clob,              -- Text to be analyzed
    analyze_length   in integer default 5000,
    window_size      in integer default 3  -- Maximum size of phrases
    )
  return word_vector;

  function compare_vectors (
    inlist1          in word_vector,       -- First vector to compare
    inlist2          in word_vector)       -- Second vector to compare
  return word_vector;

  function get_window_size (search_string varchar2)
  return integer;

  function remove_wild (mask varchar2)
  return varchar2;

  function test_match (mask varchar2, testToken varchar2)
  return boolean;

  function test_match_single (mask varchar2, testToken varchar2)
  return boolean;

  function is_num (s1 varchar2)
  return boolean;

  -- for debugging
  procedure dump_word_vector (inlist in word_vector);
  procedure test;

  function start_parser (
    p_message_id        number,
    p_search_str        varchar2,
    p_idx_name          varchar2,
    p_analyze_length    integer)
    return word_vector;
*/
END IEM_PARSER_PVT;


 

/
