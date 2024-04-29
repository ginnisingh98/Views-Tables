--------------------------------------------------------
--  DDL for Package Body JTF_MENU_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MENU_PUB" AS
  /* $Header: jtfmenub.pls 120.2 2005/10/25 05:22:20 psanyal ship $ */
  /* this is test version 'sql5.1' */

  type num_tab_ibbi is table of number index by binary_integer;

-- =======================================================================
-- Types and Constants
-- =======================================================================
TYPE function_data is record(
 web_host_name              fnd_form_functions_vl.web_host_name%type, -- varchar2(80),
 web_agent_name             fnd_form_functions_vl.web_agent_name%type, -- varchar2(80),
 web_html_call              fnd_form_functions_vl.web_html_call%type, -- varchar2(240),
 web_encrypt_parameters     fnd_form_functions_vl.web_encrypt_parameters%type, -- varchar2(1),
 web_secured                fnd_form_functions_vl.web_secured%type, -- varchar2(1),
 web_icon                   fnd_form_functions_vl.web_icon%type, -- varchar2(30),
 function_id                fnd_form_functions_vl.function_id%type, -- number,
 function_name              fnd_form_functions_vl.function_name%type, -- varchar2(30),
 application_id             fnd_form_functions_vl.application_id%type, -- number,
 creation_date              fnd_form_functions_vl.creation_date%type, -- date,
 type                       fnd_form_functions_vl.type%type, -- varchar2(30),
 user_function_name         fnd_form_functions_vl.user_function_name%type, -- varchar2(80),
 description                fnd_form_functions_vl.description%type -- varchar2(240)
);

cursor get_app_menu(p_menuid  number) is
	select  a.sub_menu_id , prompt,description,function_id,menu_name
	from 	fnd_menu_entries_vl a, fnd_menus b
	where 	a.menu_id = p_menuid  and b.menu_id(+) = a.sub_menu_id ;

cursor get_function_c(p_functionid  number) is
  select  web_host_name, web_agent_name,web_html_call,
      web_encrypt_parameters, web_secured,
      web_icon,function_id, function_name,application_id, creation_date,type,
      user_function_name, description
    from fnd_form_functions_vl
    where function_id = p_functionid;

  -- this private function is the basis of 'menu exclusion' functionality.
  -- (this functionality used to be done only in the Java layer, but
  -- we moved it to PL/SQL).
  --
  -- returns true if the users with (p_respid, p_appid) are able
  -- to see this menu_data (i.e. if they're NOT excluded from it)
  -- If the menu object contains a m_subMenuId, then we only consider
  -- whether we're excluded from the specified menu, else we only look
  -- at the m_functionId to see whether we're excluded from that.
  -- p_sub_menu_id and p_function_id are simply the sub_menu_id
  -- and function_id from the candidate menu_data
  function check_exclusion(p_respid number, p_appid number,
      p_sub_menu_id number, p_function_id number) return boolean is
    temp fnd_resp_functions.rule_type%type;

    -- this cursors job is simply to help us decide whether there exists
    -- any row which matches the given respid/appid/action_id/rule_type.
    cursor c1(pp_respid number, pp_appid number, pp_action_id number,
        pp_rule_type varchar2) is
      select rule_type from fnd_resp_functions where
        application_id = pp_appid and responsibility_id = pp_respid and
        action_id = pp_action_id and rule_type = pp_rule_type;
  begin
    if p_sub_menu_id is not null then
      -- check exclusion only based on the p_sub_menu_id!
      open c1(p_respid, p_appid, p_sub_menu_id, 'M');
      fetch c1 into temp;

      -- if temp is no longer null, then there IS an exclusion
      -- on this menu_id!
      return temp is null;
    else
      -- check exclusion only based on the p_function_id
      open c1(p_respid, p_appid, p_function_id, 'F');
      fetch c1 into temp;

      -- if temp is no longer null, then there IS an exclusion
      -- on this function_id!
      return temp is null;
    end if;
  end;


  procedure get_excl_menu_tree_recurs_tl(p_lang varchar2, p_menu_id number,
    p_respid number, p_appid number,
    p_max_depth number, p_kids_menu_ids in out nocopy number_table,
    p_kids_menu_data in out nocopy menu_table)
  is
    t_new_ids num_tab_ibbi;
    t_mt menu_table;
    cnt number;
    loc number;
  begin
    get_excluded_menu_entries_tl(p_lang, p_menu_id, p_respid, p_appid, t_mt);

    if t_mt is null or t_mt.count = 0 then return; end if;

    cnt := t_mt.first;
    while true loop
      -- put the p_menu_id in the p_kids_menu_ids, and the new menu_data
      -- from t_mt into the p_kids_menu_data
      loc := p_kids_menu_ids.count+1;
      p_kids_menu_ids(loc) := p_menu_id;
      p_kids_menu_data(loc) := t_mt(cnt);

      -- if this child also points at a menu, and we're not past our maximum
      -- depth, then add it to t_new_ids, so we'll remember to recurse
      if p_max_depth > 0 and t_mt(cnt).sub_menu_id is not null then
        t_new_ids(t_new_ids.count+1) := t_mt(cnt).sub_menu_id;
      end if;

      -- next...
      if cnt = t_mt.last then exit; end if;
      cnt := t_mt.next(cnt);
    end loop;

    -- if no new_ids were saved, then just return
    if t_new_ids is null or t_new_ids.count = 0 then return; end if;

    -- recurse
    cnt := t_new_ids.first;
    while true loop
      get_excl_menu_tree_recurs_tl(p_lang, t_new_ids(cnt), p_respid, p_appid,
        p_max_depth-1, p_kids_menu_ids, p_kids_menu_data);

      -- next...
      if cnt = t_new_ids.last then exit; end if;
      cnt := t_new_ids.next(cnt);
    end loop;
  end get_excl_menu_tree_recurs_tl;

  -- this'll call new get_root_menu_tl, then recursively
  -- get_menu_entries_tl, up to p_max_depth
  procedure get_excl_entire_menu_tree_tl(
    p_lang varchar2,
    p_respid number,
    p_appid number,
    p_max_depth number,
    p_responsibility_table OUT NOCOPY /* file.sql.39 change */ responsibility_table, -- from get_root_menu
    p_root_menu_data       OUT NOCOPY /* file.sql.39 change */ root_menu_data, -- from get_root_menu
    p_root_menu_table      OUT NOCOPY /* file.sql.39 change */ menu_table,
    p_kids_menu_ids    OUT NOCOPY /* file.sql.39 change */ number_table,
    p_kids_menu_data   OUT NOCOPY /* file.sql.39 change */ menu_table) -- all menus except the root
  is
    cnt number;
    t_mt menu_table;
    t_kids_menu_ids number_table;
    t_kids_menu_data menu_table;
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
  begin
    if p_lang is null then
      select userenv('lang') into t_lang from dual;
    else
      t_lang := p_lang;
    end if;

    -- first, get the root menu info
    get_excluded_root_menu_tl(t_lang, p_respid, p_appid,
      p_responsibility_table, p_root_menu_data, t_mt);

    -- now, recursively get the children of the root menu, up to
    -- depth p_max_depth
    if t_mt is not null and t_mt.count > 0 then
      cnt := t_mt.first;
      while true loop
        if t_mt(cnt).sub_menu_id is not null then
          get_excl_menu_tree_recurs_tl(t_lang, t_mt(cnt).sub_menu_id,
            p_respid, p_appid,
	    p_max_depth, t_kids_menu_ids, t_kids_menu_data);
        end if;

        -- next...
        if cnt = t_mt.last then exit; end if;
        cnt := t_mt.next(cnt);
      end loop;
    end if;

    -- copy temp values to OUT NOCOPY /* file.sql.39 change */ variables
    p_root_menu_table := t_mt;
    p_kids_menu_ids := t_kids_menu_ids;
    p_kids_menu_data := t_kids_menu_data;
  end get_excl_entire_menu_tree_tl;


PROCEDURE get_excluded_root_menu_tl(
  p_lang                 in     varchar2
, p_respid               in     number
, p_appid                in     number
, p_responsibility_table OUT NOCOPY /* file.sql.39 change */    responsibility_table
, p_root_menu_data       OUT NOCOPY /* file.sql.39 change */    root_menu_data
, p_menu_table           OUT NOCOPY /* file.sql.39 change */    menu_table
)
IS
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
    p_function_data function_data := null;
    cnt      number := 0;
    l_resp_name varchar2(256);
    cursor root_menu(pp_respid number, pp_appid number, pp_lang varchar2) is
      select  b.menu_id, b.menu_name , t.user_menu_name, t.description
      from fnd_menus_tl t, fnd_menus b, fnd_responsibility r
      where b.menu_id = t.menu_id and
	t.language = pp_lang and
	b.menu_id = r.menu_id and
	r.responsibility_id = pp_respid and
	r.application_id = pp_appid;

  --  cursor get_responsibilities(pp_menuid number, pp_lang varchar2) is
  --    select b.responsibility_id, t.responsibility_name
  --      from fnd_responsibility_tl t, fnd_responsibility b
  --      where b.responsibility_id = t.responsibility_id and
  --        b.application_id = t.application_id and
  --        t.language = pp_lang and
  --        b.menu_id = pp_menuid;
  BEGIN
    if p_lang is null then
      select userenv('lang') into t_lang from dual;
    else
      t_lang := p_lang;
    end if;

    open root_menu(p_respid, p_appid, t_lang);
    fetch root_menu into p_root_menu_data;
    close root_menu;

    get_excluded_menu_entries_tl(t_lang, p_root_menu_data.menu_id,
      p_respid, p_appid,
      p_menu_table);

    --for c1 in get_responsibilities(p_root_menu_data.menu_id, t_lang)
    --LOOP
      --cnt := cnt + 1;
      --p_responsibility_table(cnt).responsibility_id := c1.responsibility_id;
      --p_responsibility_table(cnt).responsibility_name := c1.responsibility_name;
      cnt := cnt + 1;
      p_responsibility_table(cnt).responsibility_id := p_respid;
      select t.responsibility_name into l_resp_name
        from fnd_responsibility_tl t, fnd_responsibility b
        where b.responsibility_id = t.responsibility_id and
          b.application_id = t.application_id and
          t.language = t_lang and b.responsibility_id = p_respid and b.application_id = p_appid;
      p_responsibility_table(cnt).responsibility_name := l_resp_name;
    --END LOOP;
  END get_excluded_root_menu_tl;

PROCEDURE get_root_menu_tl(
  p_lang                 in     varchar2
, p_respid               in     number
, p_appid                in     number
, p_responsibility_table OUT NOCOPY /* file.sql.39 change */    responsibility_table
, p_root_menu_data       OUT NOCOPY /* file.sql.39 change */    root_menu_data
, p_menu_table           OUT NOCOPY /* file.sql.39 change */    menu_table
)
IS
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
    p_function_data function_data := null;
    cnt      number := 0;
    l_resp_name varchar2(256);
-- here's the old cursor definition, which assumed userenv('lang')
-- was set correctly:
--    cursor root_menu(pp_respid number, pp_appid number) is
--select  a.menu_id, a.menu_name , a.user_menu_name, a.description
--from  fnd_menus_vl a , fnd_responsibility b
--where a.menu_id = b.menu_id and b.responsibility_id = pp_respid
--and   b.application_id = pp_appid;

-- here's the new one, which assumes we use pp_lang instead
    cursor root_menu(pp_respid number, pp_appid number, pp_lang varchar2) is
      select  b.menu_id, b.menu_name , t.user_menu_name, t.description
      from fnd_menus_tl t, fnd_menus b, fnd_responsibility r
      where b.menu_id = t.menu_id and
	t.language = pp_lang and
	b.menu_id = r.menu_id and
	r.responsibility_id = pp_respid and
	r.application_id = pp_appid;

-- here's the old cursor definition, which assumed userenv('lang')
-- was set correctly:
--    cursor get_responsibilities(pp_menuid number) is
--      select a.responsibility_id, a.responsibility_name
--      from fnd_responsibility_vl a
--      where a.menu_id = pp_menuid;

-- here's the new one, which assumes we use pp_lang instead
--    cursor get_responsibilities(pp_menuid number, pp_lang varchar2) is
--      select b.responsibility_id, t.responsibility_name
--        from fnd_responsibility_tl t, fnd_responsibility b
--        where b.responsibility_id = t.responsibility_id and
--          b.application_id = t.application_id and
--          t.language = pp_lang and
--          b.menu_id = pp_menuid;
  BEGIN
    if p_lang is null then
      select userenv('lang') into t_lang from dual;
    else
      t_lang := p_lang;
    end if;

    open root_menu(p_respid, p_appid, t_lang);
    fetch root_menu into p_root_menu_data;
    close root_menu;

    get_menu_entries_tl(t_lang, p_root_menu_data.menu_id, p_menu_table);

    --for c1 in get_responsibilities(p_root_menu_data.menu_id, t_lang)
    --LOOP
      --cnt := cnt + 1;
      --p_responsibility_table(cnt).responsibility_id := c1.responsibility_id;
      --p_responsibility_table(cnt).responsibility_name := c1.responsibility_name;
      cnt := cnt + 1;
      p_responsibility_table(cnt).responsibility_id := p_respid;
      select t.responsibility_name into l_resp_name
        from fnd_responsibility_tl t, fnd_responsibility b
        where b.responsibility_id = t.responsibility_id and
          b.application_id = t.application_id and
          t.language = t_lang and b.responsibility_id = p_respid and b.application_id = p_appid;
      p_responsibility_table(cnt).responsibility_name := l_resp_name;
    --END LOOP;
  END get_root_menu_tl;

PROCEDURE get_root_menu(
  p_respid               in     number
, p_appid                in     number
, p_responsibility_table OUT NOCOPY /* file.sql.39 change */    responsibility_table
, p_root_menu_data       OUT NOCOPY /* file.sql.39 change */    root_menu_data
, p_menu_table           OUT NOCOPY /* file.sql.39 change */    menu_table
)
IS

p_function_data function_data := null;
 cnt      number := 0;
 l_resp_name varchar2(256);
cursor root_menu(pp_respid number, pp_appid number) is
select  a.menu_id, a.menu_name , a.user_menu_name, a.description
from  fnd_menus_vl a , fnd_responsibility b
where a.menu_id = b.menu_id and b.responsibility_id = pp_respid
and   b.application_id = pp_appid;

--cursor get_responsibilities(pp_menuid number) is
--select a.responsibility_id, a.responsibility_name
--from fnd_responsibility_vl a
--where a.menu_id = pp_menuid;

BEGIN

    open root_menu(p_respid,p_appid);
    fetch root_menu into p_root_menu_data;
    close root_menu;

    get_menu_entries(p_root_menu_data.menu_id, p_menu_table);

    --for c1 in get_responsibilities(p_root_menu_data.menu_id, t_lang)
    --LOOP
      --cnt := cnt + 1;
      --p_responsibility_table(cnt).responsibility_id := c1.responsibility_id;
      --p_responsibility_table(cnt).responsibility_name := c1.responsibility_name;
      cnt := cnt + 1;
      p_responsibility_table(cnt).responsibility_id := p_respid;
      select a.responsibility_name into l_resp_name
      from fnd_responsibility_vl a
      where a.responsibility_id  = p_respid and a.application_id = p_appid;
      p_responsibility_table(cnt).responsibility_name := l_resp_name;
    --END LOOP;

END get_root_menu;


  PROCEDURE get_function(
    p_function_id        in    number
  , p_function_data      OUT NOCOPY /* file.sql.39 change */   function_data
  ) IS

  BEGIN

    open get_function_c(p_function_id);
    fetch get_function_c into p_function_data;
    close get_function_c;

  END get_function;

  procedure get_excluded_menu_entries_tl(
      p_lang varchar2,
      p_menu_id number,
      p_respid number,
      p_appid number,
      p_menu_table OUT NOCOPY /* file.sql.39 change */ menu_table) is
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
    cnt number := 0;
    p_function_data function_data := null;

    cursor get_sub_menus(p_mid number, pp_lang varchar2) is
      SELECT
    rowidtochar(B.ROWID) menu_entry_rowid, B.MENU_ID, B.ENTRY_SEQUENCE,
    B.SUB_MENU_ID, B.FUNCTION_ID,
    B.GRANT_FLAG, B.LAST_UPDATE_DATE, B.LAST_UPDATED_BY, B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE , B.CREATED_BY , T.PROMPT, T.DESCRIPTION, fm.menu_name
      FROM FND_MENU_ENTRIES_TL T, FND_MENU_ENTRIES B, fnd_menus fm
      WHERE B.MENU_ID = T.MENU_ID AND B.ENTRY_SEQUENCE = T.ENTRY_SEQUENCE
        and b.menu_id = p_mid and fm.menu_id(+) = b.sub_menu_id
        AND T.LANGUAGE = pp_lang
      order by b.entry_sequence;
  begin
    if p_lang is null then
      select userenv('lang') into t_lang from dual;
    else
      t_lang := p_lang;
    end if;

    for c1 in get_sub_menus(p_menu_id, t_lang) loop
      if check_exclusion(p_respid, p_appid, c1.sub_menu_id,
	  c1.function_id) then
        cnt := cnt + 1;

        p_menu_table(cnt).sub_menu_id 		:= c1.sub_menu_id;
        p_menu_table(cnt).prompt 		:= c1.prompt;
        p_menu_table(cnt).description 		:= c1.description;
        p_menu_table(cnt).function_id 		:= c1.function_id;
        p_menu_table(cnt).menu_name 		:= c1.menu_name;
        p_menu_table(cnt).menu_entry_rowid 	:= c1.menu_entry_rowid;

        if c1.function_id > 0 then
	  get_function(c1.function_id, p_function_data);
	  p_menu_table(cnt).func_web_host_name 	:= p_function_data.web_host_name;
	  p_menu_table(cnt).func_web_agent_name	:= p_function_data.web_agent_name;
	  p_menu_table(cnt).func_web_html_call 	:= p_function_data.web_html_call;
	  p_menu_table(cnt).func_web_encrypt_parameters := p_function_data.web_encrypt_parameters;
	  p_menu_table(cnt).func_web_secured 	:= p_function_data.web_secured;
	  p_menu_table(cnt).func_web_icon 	:= p_function_data.web_icon;
	  p_menu_table(cnt).func_function_id 	:= p_function_data.function_id;
	  p_menu_table(cnt).func_function_name 	:= p_function_data.function_name;
	  p_menu_table(cnt).func_application_id	:= p_function_data.application_id;
	  p_menu_table(cnt).func_creation_date 	:= p_function_data.creation_date;
	  p_menu_table(cnt).func_type 		:= p_function_data.type;
	  p_menu_table(cnt).func_user_function_name := p_function_data.user_function_name;
	  p_menu_table(cnt).func_description 	:= p_function_data.description;
        end if;
      end if;
    end loop;
  end get_excluded_menu_entries_tl;

  procedure get_menu_entries_tl(
      p_lang varchar2,
      p_menu_id number,
      p_menu_table OUT NOCOPY /* file.sql.39 change */ menu_table) is
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
    cnt number := 0;
    p_function_data function_data := null;

    cursor get_sub_menus(p_mid number, pp_lang varchar2) is
    -- here's the query, before we parameterized it by language
--      select sub_menu_id, prompt, description, function_id, menu_name,
--        rowidtochar(a.rowid) menu_entry_rowid
--      from fnd_menu_entries_vl a, fnd_menus b
--      where a.menu_id = p_mid and b.menu_id(+) = a.sub_menu_id
--      order by entry_sequence;
      SELECT
    rowidtochar(B.ROWID) menu_entry_rowid, B.MENU_ID, B.ENTRY_SEQUENCE,
    B.SUB_MENU_ID, B.FUNCTION_ID,
    B.GRANT_FLAG, B.LAST_UPDATE_DATE, B.LAST_UPDATED_BY, B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE , B.CREATED_BY , T.PROMPT, T.DESCRIPTION, fm.menu_name
      FROM FND_MENU_ENTRIES_TL T, FND_MENU_ENTRIES B, fnd_menus fm
      WHERE B.MENU_ID = T.MENU_ID AND B.ENTRY_SEQUENCE = T.ENTRY_SEQUENCE
        and b.menu_id = p_mid and fm.menu_id(+) = b.sub_menu_id
        AND T.LANGUAGE = pp_lang
      order by b.entry_sequence;
  begin
    if p_lang is null then
      select userenv('lang') into t_lang from dual;
    else
      t_lang := p_lang;
    end if;

    for c1 in get_sub_menus(p_menu_id, t_lang) loop
      cnt := cnt + 1;

      p_menu_table(cnt).sub_menu_id 		:= c1.sub_menu_id;
      p_menu_table(cnt).prompt	 		:= c1.prompt;
      p_menu_table(cnt).description 		:= c1.description;
      p_menu_table(cnt).function_id 		:= c1.function_id;
      p_menu_table(cnt).menu_name 		:= c1.menu_name;
      p_menu_table(cnt).menu_entry_rowid 	:= c1.menu_entry_rowid;

      if c1.function_id > 0 then
	get_function(c1.function_id, p_function_data);
	p_menu_table(cnt).func_web_host_name 	:= p_function_data.web_host_name;
	p_menu_table(cnt).func_web_agent_name 	:= p_function_data.web_agent_name;
	p_menu_table(cnt).func_web_html_call 	:= p_function_data.web_html_call;
	p_menu_table(cnt).func_web_encrypt_parameters 	:= p_function_data.web_encrypt_parameters;
	p_menu_table(cnt).func_web_secured 	:= p_function_data.web_secured;
	p_menu_table(cnt).func_web_icon 	:= p_function_data.web_icon;
	p_menu_table(cnt).func_function_id 	:= p_function_data.function_id;
	p_menu_table(cnt).func_function_name 	:= p_function_data.function_name;
	p_menu_table(cnt).func_application_id 	:= p_function_data.application_id;
	p_menu_table(cnt).func_creation_date 	:= p_function_data.creation_date;
	p_menu_table(cnt).func_type 		:= p_function_data.type;
	p_menu_table(cnt).func_user_function_name 	:= p_function_data.user_function_name;
	p_menu_table(cnt).func_description 	:= p_function_data.description;
      end if;
     end loop;
   end get_menu_entries_tl;

PROCEDURE get_menu_entries(
  p_menu_id         in    number
, p_menu_table      OUT NOCOPY /* file.sql.39 change */   menu_table
) IS

cnt number := 0;
p_function_data function_data := null;

cursor get_sub_menus(p_mid number) is
--select sub_menu_id, prompt, description, function_id, menu_name, rowidtochar(a.rowid) menu_entry_rowid
select sub_menu_id, prompt, description, function_id, menu_name, rowidtochar(a.row_id) menu_entry_rowid
from fnd_menu_entries_vl a, fnd_menus b
where a.menu_id = p_mid and b.menu_id(+) = a.sub_menu_id
order by entry_sequence;

BEGIN

    for c1 in get_sub_menus(p_menu_id) loop
  	cnt := cnt + 1;

--	if (c1.function_id > 0 ) then
--		get_function(c1.function_id, p_function_data);
--	end if;

	p_menu_table(cnt).sub_menu_id 		:= c1.sub_menu_id;
	p_menu_table(cnt).prompt 		:= c1.prompt;
	p_menu_table(cnt).description 		:= c1.description;
	p_menu_table(cnt).function_id 		:= c1.function_id;
	p_menu_table(cnt).menu_name 		:= c1.menu_name;
	p_menu_table(cnt).menu_entry_rowid 	:= c1.menu_entry_rowid;

        if c1.function_id > 0 then
	  get_function(c1.function_id, p_function_data);
	  p_menu_table(cnt).func_web_host_name 	:= p_function_data.web_host_name;
	  p_menu_table(cnt).func_web_agent_name 	:= p_function_data.web_agent_name;
	  p_menu_table(cnt).func_web_html_call 	:= p_function_data.web_html_call;
	  p_menu_table(cnt).func_web_encrypt_parameters 	:= p_function_data.web_encrypt_parameters;
	  p_menu_table(cnt).func_web_secured 	:= p_function_data.web_secured;
	  p_menu_table(cnt).func_web_icon 	:= p_function_data.web_icon;
	  p_menu_table(cnt).func_function_id 	:= p_function_data.function_id;
	  p_menu_table(cnt).func_function_name 	:= p_function_data.function_name;
	  p_menu_table(cnt).func_application_id 	:= p_function_data.application_id;
	  p_menu_table(cnt).func_creation_date 	:= p_function_data.creation_date;
	  p_menu_table(cnt).func_type 		:= p_function_data.type;
	  p_menu_table(cnt).func_user_function_name 	:= p_function_data.user_function_name;
	  p_menu_table(cnt).func_description 	:= p_function_data.description;
        end if;
    END LOOP;

END get_menu_entries;

PROCEDURE get_func_entries(
  p_menu_id         in    number
, p_menu_table      OUT NOCOPY /* file.sql.39 change */   menu_table
) IS

cnt number := 0;
p_function_data function_data := null;

cursor get_sub_menus(p_mid number) is
-- select sub_menu_id, prompt, description, function_id, '' menu_name, rowidtochar(rowid) menu_entry_rowid
select sub_menu_id, prompt, description, function_id, '' menu_name, rowidtochar(row_id) menu_entry_rowid
  from fnd_menu_entries_vl
    where menu_id = p_mid
    order by entry_sequence;

BEGIN

for c1 in get_sub_menus(p_menu_id)
LOOP
  	cnt := cnt + 1;

	if (c1.function_id > 0 ) then
		get_function(c1.function_id, p_function_data);
	end if;

	p_menu_table(cnt).sub_menu_id 		:= c1.sub_menu_id;
	p_menu_table(cnt).prompt 		:= c1.prompt;
	p_menu_table(cnt).description 		:= c1.description;
	p_menu_table(cnt).function_id 		:= c1.function_id;
	p_menu_table(cnt).menu_name 		:= c1.menu_name;
	p_menu_table(cnt).menu_entry_rowid 	:= c1.menu_entry_rowid;
 	p_menu_table(cnt).func_web_host_name 	:= p_function_data.web_host_name;
 	p_menu_table(cnt).func_web_agent_name 	:= p_function_data.web_agent_name;
 	p_menu_table(cnt).func_web_html_call 	:= p_function_data.web_html_call;
 	p_menu_table(cnt).func_web_encrypt_parameters 	:= p_function_data.web_encrypt_parameters;
 	p_menu_table(cnt).func_web_secured 	:= p_function_data.web_secured;
 	p_menu_table(cnt).func_web_icon 	:= p_function_data.web_icon;
 	p_menu_table(cnt).func_function_id 	:= p_function_data.function_id;
 	p_menu_table(cnt).func_function_name 	:= p_function_data.function_name;
 	p_menu_table(cnt).func_application_id 	:= p_function_data.application_id;
 	p_menu_table(cnt).func_creation_date 	:= p_function_data.creation_date;
 	p_menu_table(cnt).func_type 		:= p_function_data.type;
 	p_menu_table(cnt).func_user_function_name 	:= p_function_data.user_function_name;
 	p_menu_table(cnt).func_description 	:= p_function_data.description;

END LOOP;

END get_func_entries;


  FUNCTION get_function_name_tl(
      p_lang varchar2,
      p_function_id number) return varchar2 is
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
    l_function_name varchar2(80);

--  the old SELECT statement
--  cursor get_func_name(p_func_id number) is
--    select user_function_name
--    from fnd_form_functions_vl
--    where function_id = p_func_id;
  cursor get_func_name(p_func_id number, pp_lang varchar2) is
    SELECT
      T.USER_FUNCTION_NAME
    FROM FND_FORM_FUNCTIONS_TL T, FND_FORM_FUNCTIONS B
    WHERE B.FUNCTION_ID = T.FUNCTION_ID AND T.LANGUAGE = pp_lang and
      b.function_id = p_func_id;
  begin
    if p_lang is null then
      select userenv('lang') into t_lang from dual;
    else
      t_lang := p_lang;
    end if;

    open get_func_name(p_function_id, t_lang);
    fetch get_func_name into l_function_name;
    close get_func_name;

    return l_function_name;
  end get_function_name_tl;

FUNCTION get_function_name(
   p_function_id  in number
) RETURN VARCHAR2
IS
l_function_name varchar2(80);

cursor get_func_name(p_func_id number) is
select user_function_name
from fnd_form_functions_vl
where function_id = p_func_id;

BEGIN
  open get_func_name(p_function_id);
  fetch get_func_name into l_function_name;
  close get_func_name;

  return l_function_name;

END get_function_name;


  FUNCTION get_menu_name_tl(
      p_lang varchar2,
      p_menu_row_id varchar2) return varchar2 is
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
    l_prompt_name varchar2(30);
    -- here's the query, before we parameterized it by language
--    cursor get_menu_name(p_row_id varchar2) is
--      select prompt
--      from fnd_menu_entries_vl
--      where rowid = chartorowid(p_row_id);
    cursor get_menu_name(p_row_id varchar2, pp_lang varchar2) is
      SELECT T.PROMPT
        FROM FND_MENU_ENTRIES_TL T, FND_MENU_ENTRIES B
        WHERE B.MENU_ID = T.MENU_ID AND B.ENTRY_SEQUENCE = T.ENTRY_SEQUENCE
          AND T.LANGUAGE = pp_lang and
	    b.rowid = chartorowid(p_row_id);
  begin
    if p_lang is null then
      select userenv('lang') into t_lang from dual;
    else
      t_lang := p_lang;
    end if;

    open get_menu_name(p_menu_row_id, t_lang);
    fetch get_menu_name into l_prompt_name;
    close get_menu_name;

    return l_prompt_name;
  end get_menu_name_tl;

FUNCTION get_menu_name(
   p_menu_row_id  in varchar2
) RETURN VARCHAR2
IS
l_prompt_name varchar2(30);

cursor get_menu_name(p_row_id varchar2) is
select prompt
from fnd_menu_entries_vl
--where rowid = chartorowid(p_row_id);
where row_id = chartorowid(p_row_id);

BEGIN
  open get_menu_name(p_menu_row_id);
  fetch get_menu_name into l_prompt_name;
  close get_menu_name;

  return l_prompt_name;

END get_menu_name;

  function get_root_menu_name_tl(
      p_lang varchar2,
      p_menu_id  in number) return varchar2 is
    t_lang varchar2(25); -- probably '5' was enuf, I don't know the max
    l_prompt_name varchar2(80);
    -- here's the query, before we parameterized it by language
--    cursor get_root_name(p_menu_id number) is
--      select user_menu_name
--      from fnd_menus_vl
--      where menu_id = p_menu_id;
    cursor get_root_name(p_menu_id number, pp_lang varchar2) is
      SELECT T.USER_MENU_NAME
      FROM FND_MENUS_TL T, FND_MENUS B
      WHERE B.MENU_ID = T.MENU_ID AND T.LANGUAGE = pp_lang and
        b.menu_id = p_menu_id;
    begin
      open get_root_name(p_menu_id, t_lang);
      fetch get_root_name into l_prompt_name;
      close get_root_name;

      return l_prompt_name;
  end get_root_menu_name_tl;

FUNCTION get_root_menu_name(
   p_menu_id  in number
) RETURN VARCHAR2
IS
l_prompt_name varchar2(80);

cursor get_root_name(p_menu_id number) is
select user_menu_name
from fnd_menus_vl
where menu_id = p_menu_id;

BEGIN
  open get_root_name(p_menu_id);
  fetch get_root_name into l_prompt_name;
  close get_root_name;

  return l_prompt_name;

END get_root_menu_name;

end jtf_menu_pub;

/
