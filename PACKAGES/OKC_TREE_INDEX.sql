--------------------------------------------------------
--  DDL for Package OKC_TREE_INDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TREE_INDEX" AUTHID CURRENT_USER as
/* $Header: OKCRTRIS.pls 120.0 2005/05/26 09:33:57 appldev noship $ */

--
-- p_tree_id is only for the case when
-- several tree statements included in a single query
-- and there is hazard that they will be treated in parallel;
-- usually rely on default value of this parameter
--
--
-- default separator is '.', to override use set_separator(p_separator varchar2)
--
-- default pad character is ' ', to override use set_pad_char(p_pad_char varchar2)
--
-- use not paded methods only if need
--

--
-- function get_id constructs tree index for numeric leaf index
--
-- p_level to pass level from treewalk query
-- p_id to pass key entry that will be part of the returned index
-- p_tree_id explained at the package top

  function get_id(
	p_level IN number,
	p_id IN number,
	p_tree_id IN number default 1
  ) return varchar2;

--
-- function get_id_lpaded constructs tree index for numeric leaf index
-- each key entry will be lpaded up to p_digits size
--
-- p_level to pass level from treewalk query
-- p_id to pass key entry that will be part of the returned index
-- p_digits size of key entry lpaded
-- p_tree_id explained at the package top

  function get_id_lpaded(
	p_level IN number,
	p_id IN number,
	p_digits IN number,
	p_tree_id IN number default 1
  ) return varchar2;

--
-- function get_label constructs tree index for character leaf index
--
-- p_level to pass level from treewalk query
-- p_label to pass key entry that will be part of the returned index
-- p_tree_id explained at the package top

  function get_label(
	p_level IN number,
	p_label IN varchar2,
	p_tree_id IN number default 1
  ) return varchar2;

--
-- function get_label_rpaded constructs tree index for character leaf index
-- key entries will be rpaded up to p_characters
--
-- p_level to pass level from treewalk query
-- p_label to pass key entry that will be part of the returned index
-- p_characters size of key entry after rpaded
-- p_tree_id explained at the package top

  function get_label_rpaded(
	p_level IN number,
	p_label IN varchar2,
	p_characters IN number,
	p_tree_id IN number default 1
  ) return varchar2;

--
-- procedure set_separator
--
-- to override default separator that is '.'
--
  procedure set_separator(p_separator IN varchar2);

--
-- procedure set_pad_char
--
-- to override default pad character that is ' '
--
  procedure set_pad_char(p_pad_char IN varchar2);

--
-- these procedures are of rare usage
--
-- set/get root id is only needed for deep nested treewalk queries
-- to set something like bind var for the tree root
--

  procedure set_root_id(p_id IN number,p_tree_id IN number default 1);

  function get_root_id(p_tree_id IN number default 1) return number;

--
-- function nested_rownum for internal usage only
--
  function nested_rownum(p_instance number, p_idx number, p_cnt number) return number;

end;

 

/
