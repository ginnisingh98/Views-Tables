--------------------------------------------------------
--  DDL for Package Body OKC_TREE_INDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TREE_INDEX" as
/* $Header: OKCRTRIB.pls 120.0 2005/05/25 19:20:34 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

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

  TYPE leaf_rec IS RECORD (label varchar2(256));
  TYPE path_tbl IS TABLE OF leaf_rec INDEX BY BINARY_INTEGER;
  G_PATH_TBL path_tbl;

  G_SEPARATOR varchar2(3) := '.';
  G_PAD_CHAR varchar2(3);

  TYPE root_rec IS RECORD (id number);
  TYPE root_tbl IS TABLE OF root_rec INDEX BY BINARY_INTEGER;
  G_ROOT_TBL root_tbl;

  TYPE count_rec IS RECORD (idx number, cnt number);
  TYPE count_tbl IS TABLE OF count_rec INDEX BY BINARY_INTEGER;
  G_COUNT_TBL count_tbl;

-- private procedure
  function get_separator return varchar2 is
  begin
    return G_SEPARATOR;
  end;

-- private procedure
  function get_pad_char return varchar2 is
  begin
    return G_PAD_CHAR;
  end;

-- private procedure
  function ret_label(p_level number, p_tree_id number) return varchar2 is
    l_path varchar2(1000);
    s1 number;
    s2 number;
  begin
    s1 := power(2,p_tree_id-1);
    s2 := 2*s1;
    l_path := g_path_tbl(s1).label;
    for i in 2..p_level loop
      l_path := l_path||get_separator||g_path_tbl(s1+s2*(i-1)).label;
    end loop;
    return l_path;
  end;

--
-- function get_id constructs tree index for numeric leaf index
--
-- p_level to pass level from treewalk query
-- p_id to pass key entry that will be part of the returned index
-- p_tree_id explained at the package top

  function get_id(p_level number, p_id number, p_tree_id number ) return varchar2 is
    s1 number;
    s3 number;
  begin
    s1 := power(2,p_tree_id-1);
    s3 := s1+2*s1*(p_level-1);
    g_path_tbl(s3).label := to_char(p_id);
    return ret_label(p_level,p_tree_id);
  end;

--
-- function get_id_lpaded constructs tree index for numeric leaf index
-- each key entry will be lpaded up to p_digits size
--
-- p_level to pass level from treewalk query
-- p_id to pass key entry that will be part of the returned index
-- p_digits size of key entry lpaded
-- p_tree_id explained at the package top

  function get_id_lpaded(p_level number, p_id number, p_digits number, p_tree_id number ) return varchar2 is
    s1 number;
    s3 number;
  begin
    s1 := power(2,p_tree_id-1);
    s3 := s1+2*s1*(p_level-1);
    g_path_tbl(s3).label := lpad(to_char(p_id),p_digits,NVL(get_pad_char,' '));
    return ret_label(p_level,p_tree_id);
  end;

--
-- function get_label constructs tree index for character leaf index
--
-- p_level to pass level from treewalk query
-- p_label to pass key entry that will be part of the returned index
-- p_tree_id explained at the package top

  function get_label(p_level number, p_label varchar2, p_tree_id number ) return varchar2 is
    s1 number;
    s3 number;
  begin
    s1 := power(2,p_tree_id-1);
    s3 := s1+2*s1*(p_level-1);
    g_path_tbl(s3).label := p_label;
    return ret_label(p_level,p_tree_id);
  end;

--
-- function get_label_rpaded constructs tree index for character leaf index
-- key entries will be rpaded up to p_characters
--
-- p_level to pass level from treewalk query
-- p_label to pass key entry that will be part of the returned index
-- p_characters size of key entry after rpaded
-- p_tree_id explained at the package top

  function get_label_rpaded(p_level number, p_label varchar2, p_characters number, p_tree_id number ) return varchar2 is
    s1 number;
    s3 number;
  begin
    s1 := power(2,p_tree_id-1);
    s3 := s1+2*s1*(p_level-1);
    g_path_tbl(s3).label := rpad(p_label,p_characters,NVL(get_pad_char,' '));
    return ret_label(p_level,p_tree_id);
  end;

--
-- procedure set_separator
--
-- to override default separator that is '.'
--
  procedure set_separator(p_separator varchar2) is
  begin
    G_SEPARATOR := substr(p_separator,1,3);
  end;

--
-- procedure set_pad_char
--
-- to override default pad character that is ' '
--
  procedure set_pad_char(p_pad_char varchar2) is
  begin
    G_PAD_CHAR := substr(p_pad_char,1,3);
  end;

--
-- these procedures are of rare usage
--
-- set/get root id is only needed for deep nested treewalk queries
-- to set something like bind var for the tree root
--
  procedure set_root_id(p_id number,p_tree_id number) is
  begin
    G_ROOT_TBL(p_tree_id).id := p_id;
  end;

  function get_root_id(p_tree_id number ) return number is
  begin
    return G_ROOT_TBL(p_tree_id).id;
  exception when others then
    return NULL;
  end;

--
-- function nested_rownum for internal usage only
--
  function nested_rownum(p_instance number, p_idx number, p_cnt number) return number is
  begin
    if (p_cnt = 1 or G_COUNT_TBL(p_instance).idx <> p_idx) then
      G_COUNT_TBL(p_instance).idx := p_idx;
      G_COUNT_TBL(p_instance).cnt := 1;
      return 1;
    end if;
    G_COUNT_TBL(p_instance).cnt := G_COUNT_TBL(p_instance).cnt + 1;
    return G_COUNT_TBL(p_instance).cnt;
  end;

end;

/
