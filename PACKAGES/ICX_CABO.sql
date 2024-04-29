--------------------------------------------------------
--  DDL for Package ICX_CABO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CABO" AUTHID CURRENT_USER as
/* $Header: ICXCABOS.pls 120.1 2005/10/07 13:22:20 gjimenez noship $ */

g_base_href varchar2(240);
g_plsql_agent varchar2(240);
g_display_menu_icon boolean default TRUE;

TYPE toolbar IS RECORD (
         title varchar2(240),
         menu_url varchar2(240),
         menu_mouseover varchar2(240),
         down_arrow_url varchar2(240),
         down_arrow_mouseover varchar2(240),
         save_url varchar2(240),
         save_mouseover varchar2(240),
         print_frame varchar2(240),
         print_mouseover varchar2(240),
         reload_frame varchar2(240),
         reload_mouseover varchar2(240),
         stop_mouseover varchar2(240),
         help_url varchar2(240),
         help_mouseover varchar2(240),
         personal_options_url varchar2(240),
         personal_options_mouseover varchar2(240),
         custom_option1_url varchar2(240),
         custom_option1_mouseover varchar2(2000),
         custom_option1_gif varchar2(240),
         custom_option1_mouseover_gif varchar2(240),
         custom_option1_disabled_gif varchar2(240),
         custom_option2_url varchar2(240),
         custom_option2_mouseover varchar2(2000),
         custom_option2_gif varchar2(240),
         custom_option2_mouseover_gif varchar2(240),
         custom_option2_disabled_gif varchar2(240),
         custom_option3_url varchar2(240),
         custom_option3_mouseover varchar2(2000),
         custom_option3_gif varchar2(240),
         custom_option3_mouseover_gif varchar2(240),
         custom_option3_disabled_gif varchar2(240),
         custom_option4_url varchar2(240),
         custom_option4_mouseover varchar2(2000),
         custom_option4_gif varchar2(240),
         custom_option4_mouseover_gif varchar2(240),
         custom_option4_disabled_gif varchar2(240),
         custom_option5_url varchar2(240),
         custom_option5_mouseover varchar2(2000),
         custom_option5_gif varchar2(240),
         custom_option5_mouseover_gif varchar2(240),
         custom_option5_disabled_gif varchar2(240),
         custom_option6_url varchar2(240),
         custom_option6_mouseover varchar2(2000),
         custom_option6_gif varchar2(240),
         custom_option6_mouseover_gif varchar2(240),
         custom_option6_disabled_gif varchar2(240));

TYPE tabicon IS RECORD (
         name varchar2(30),
         iconname varchar2(240),
         disablediconname varchar2(240),
         iconposition varchar2(30),
         hint varchar2(240),
         disabledhint varchar2(240),
         actiontype varchar2(30),
         url varchar2(2000),
         targetframe varchar2(30),
         action varchar2(2000),
         enabled varchar2(30),
         showcurrentonly varchar2(30));

TYPE tabiconTable IS TABLE OF tabicon index by binary_integer;

TYPE tab IS RECORD (
         name varchar2(30),
         text varchar2(240),
         hint varchar2(240),
         disablehint varchar2(240),
         url varchar2(2000),
         enabled varchar2(30) default 'true',
         visible varchar2(30) default 'true',
         alwaysactive varchar2(30) default 'true',
         iconobj varchar2(30));

TYPE tabTable IS TABLE OF tab index by binary_integer;

TYPE action IS RECORD (
         name varchar2(30),
         shape varchar2(30) default 'RR',
         text varchar2(80),
         actiontype varchar2(30),
         url varchar2(2000),
         targetframe varchar2(30),
         action varchar2(2000),
         enabled varchar2(30),
         defaultbutton varchar2(30),
         gap varchar2(30));

TYPE actionTable IS TABLE OF action index by binary_integer;

procedure displaytoolbar(p_toolbar in icx_cabo.toolbar);

procedure show_table;

procedure nobuttons;

procedure buttons(p_actiontext in varchar2 default null);

procedure buttons(p_actions in icx_cabo.actionTable,
                  p_actiontext in varchar2 default null,
                  p_locator in boolean default FALSE);

procedure container(p_toolbar in icx_cabo.toolbar,
                    p_helpmsg in varchar2,
                    p_helptitle in varchar2,
                    p_url in varchar2 default null,
                    p_action in boolean default FALSE,
                    p_locator in boolean default FALSE);

procedure container(p_toolbar in icx_cabo.toolbar,
                    p_helpmsg in varchar2,
                    p_helptitle in varchar2,
                    p_currenttab in number default 1,
                    p_tabs in icx_cabo.tabTable,
                    p_url in varchar2 default null,
                    p_action in boolean default FALSE,
                    p_locator in boolean default FALSE);

procedure container(p_toolbar in icx_cabo.toolbar,
                    p_helpmsg in varchar2,
                    p_helptitle in varchar2,
                    p_tabicons in icx_cabo.tabiconTable,
                    p_currenttab in number default 1,
                    p_tabs in icx_cabo.tabTable,
                    p_url in varchar2 default null,
                    p_action in boolean default FALSE,
                    p_locator in boolean default FALSE);

function plsqlagent return varchar2;

end icx_cabo;

 

/
