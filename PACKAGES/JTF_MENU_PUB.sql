--------------------------------------------------------
--  DDL for Package JTF_MENU_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MENU_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfmenus.pls 120.2 2005/10/25 05:22:46 psanyal ship $ */
  /* this is test version 'sql5.1' */

TYPE menu_responsibility is record(
   responsibility_id          number
,  responsibility_name        fnd_responsibility_vl.responsibility_name%type -- varchar2(100)
);

TYPE root_menu_data is record (
   menu_id      	number
,  menu_name		fnd_menus_vl.menu_name%type -- varchar2(30)
,  prompt	       fnd_menus_vl.user_menu_name%type -- varchar2(80)
,  description          fnd_menus_vl.description%type -- varchar2(240)
);

TYPE menu_data is record (
   sub_menu_id      		fnd_menu_entries_vl.sub_menu_id%type -- number
,  prompt           		fnd_menu_entries_vl.prompt%type -- varchar2(30)
,  description      		fnd_menu_entries_vl.description%type -- varchar2(240)
,  function_id      		fnd_menu_entries_vl.function_id%type -- number
,  menu_name        		fnd_menus.menu_name%type -- varchar2(30)
,  menu_entry_rowid 		varchar2(240)
,  func_web_host_name           fnd_form_functions_vl.web_host_name%type -- varchar2(80)
,  func_web_agent_name          fnd_form_functions_vl.web_agent_name%type -- varchar2(80)
,  func_web_html_call           fnd_form_functions_vl.web_html_call%type -- varchar2(240)
,  func_web_encrypt_parameters  fnd_form_functions_vl.web_encrypt_parameters%type -- varchar2(1)
,  func_web_secured             fnd_form_functions_vl.web_secured%type -- varchar2(1)
,  func_web_icon                fnd_form_functions_vl.web_icon%type -- varchar2(30)
,  func_function_id             fnd_form_functions_vl.function_id%type -- number
,  func_function_name           fnd_form_functions_vl.function_name%type -- varchar2(30)
,  func_application_id          fnd_form_functions_vl.application_id%type -- number
,  func_creation_date           fnd_form_functions_vl.creation_date%type -- date
,  func_type                    fnd_form_functions_vl.type%type -- varchar2(30)
,  func_user_function_name      fnd_form_functions_vl.user_function_name%type -- varchar2(80)
,  func_description             fnd_form_functions_vl.description%type -- varchar2(240)
);

type menu_table is table of menu_data index by binary_integer;
type number_table is table of number index by binary_integer;

TYPE responsibility_table IS TABLE OF MENU_RESPONSIBILITY
	INDEX BY BINARY_INTEGER;

  -- this'll call new get_excluded_root_menu_tl, then recursively
  -- get_excluded_menu_entries_tl, up to p_max_depth
  -- p_kids_menu_ids and p_kids_menu_data always
  -- have the same count and correspond 1-to-1.
  -- if p_lang is not null, then we assume that it is the language,
  -- else use userenv('lang') value.  This is the "NLS Robustnes" fix
  procedure get_excl_entire_menu_tree_tl(
    p_lang varchar2,
    p_respid number,
    p_appid number,
    p_max_depth number,
    p_responsibility_table OUT NOCOPY /* file.sql.39 change */ responsibility_table, -- from get_root_menu
    p_root_menu_data       OUT NOCOPY /* file.sql.39 change */ root_menu_data, -- from get_root_menu
    p_root_menu_table      OUT NOCOPY /* file.sql.39 change */ menu_table,
    p_kids_menu_ids    OUT NOCOPY /* file.sql.39 change */ number_table,
    p_kids_menu_data   OUT NOCOPY /* file.sql.39 change */ menu_table); -- all menus except the root


-- get_excluded_root_menu_tl works just like get_root_menu_tl, except
-- that the menu exclusion stuff happens before the menu is returned
procedure get_excluded_root_menu_tl(
  p_lang                 in     varchar2
, p_respid               in     number
, p_appid                in     number
, p_responsibility_table OUT NOCOPY /* file.sql.39 change */    responsibility_table
, p_root_menu_data       OUT NOCOPY /* file.sql.39 change */    root_menu_data
, p_menu_table           OUT NOCOPY /* file.sql.39 change */    menu_table
);
-- get_root_menu_tl works just like get_root_menu, except has 'NLS Robustness',
-- i.e. doesn't assume that the userenv('lang') is set correctly.
-- @deprecated! use get_excluded_root_menu_tl instead !
procedure get_root_menu_tl(
  p_lang                 in     varchar2
, p_respid               in     number
, p_appid                in     number
, p_responsibility_table OUT NOCOPY /* file.sql.39 change */    responsibility_table
, p_root_menu_data       OUT NOCOPY /* file.sql.39 change */    root_menu_data
, p_menu_table           OUT NOCOPY /* file.sql.39 change */    menu_table
);

-- @deprecated! use get_excluded_root_menu_tl instead !
PROCEDURE get_root_menu(
  p_respid               in     number
, p_appid                in     number
, p_responsibility_table OUT NOCOPY /* file.sql.39 change */    responsibility_table
, p_root_menu_data       OUT NOCOPY /* file.sql.39 change */    root_menu_data
, p_menu_table           OUT NOCOPY /* file.sql.39 change */    menu_table
);

  -- this is like the old get_menu_entries_tl, but it does menu
  -- exclusion based on respid/appid.
  procedure get_excluded_menu_entries_tl(
    p_lang varchar2,
    p_menu_id number,
    p_respid number,
    p_appid number,
    p_menu_table OUT NOCOPY /* file.sql.39 change */ menu_table);

  -- this is like the old get_menu_entries, but it
  -- takes an explicit language argument, rather than depending
  -- on the userenv('LANG') to be set.
  -- if p_lang is not null, then we assume that it is the language,
  -- else use userenv('lang') value.  This is the "NLS Robustness" fix
  -- @deprecated! use get_excluded_menu_entries_tl
  procedure get_menu_entries_tl(
    p_lang varchar2,
    p_menu_id number,
    p_menu_table OUT NOCOPY /* file.sql.39 change */ menu_table);

  -- @deprecated! use get_excluded_menu_entries_tl
  PROCEDURE get_menu_entries(
   p_menu_id          	in    number
  ,p_menu_table           OUT NOCOPY /* file.sql.39 change */   menu_table
  );

PROCEDURE get_func_entries(
 p_menu_id          	in    number
,p_menu_table           OUT NOCOPY /* file.sql.39 change */   menu_table
);

  -- this is like the old get_function_name, but it
  -- takes an explicit language argument, rather than depending
  -- on the userenv('LANG') to be set.
  -- if p_lang is not null, then we assume that it is the language,
  -- else use userenv('lang') value.  This is the "NLS Robustnes" fix
  FUNCTION get_function_name_tl(
    p_lang varchar2,
    p_function_id number) return varchar2;

FUNCTION get_function_name(
   p_function_id  in number
) RETURN VARCHAR2;

  -- this is like the old get_menu_name, but it
  -- takes an explicit language argument, rather than depending
  -- on the userenv('LANG') to be set.
  -- if p_lang is not null, then we assume that it is the language,
  -- else use userenv('lang') value.  This is the "NLS Robustnes" fix
  FUNCTION get_menu_name_tl(
    p_lang varchar2,
    p_menu_row_id varchar2) return varchar2;

FUNCTION get_menu_name(
   p_menu_row_id  in varchar2
) RETURN VARCHAR2;

  -- this is like the old get_root_menu_name, but it
  -- takes an explicit language argument, rather than depending
  -- on the userenv('LANG') to be set.
  -- if p_lang is not null, then we assume that it is the language,
  -- else use userenv('lang') value.  This is the "NLS Robustnes" fix
  function get_root_menu_name_tl(
    p_lang varchar2,
    p_menu_id  in number) return varchar2;

FUNCTION get_root_menu_name(
   p_menu_id  in number
) RETURN VARCHAR2;

END jtf_menu_pub;

 

/
