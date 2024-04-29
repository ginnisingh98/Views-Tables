--------------------------------------------------------
--  DDL for Package JTF_DIAGNOSTIC_COREAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAGNOSTIC_COREAPI" AUTHID CURRENT_USER AS
/* $Header: jtfdiagcoreapi_s.pls 120.3 2006/12/06 12:07:52 rudas noship $ */

   l_newline varchar2(1) := fnd_global.newline;
   l_tab     varchar2(1) := fnd_global.tab;
   l_return varchar2(1) := fnd_global.local_chr(13);

  /* Default starting point for date searches - Date 30 years ago */
   olddate DATE := SYSDATE-(365*30);

   g_hold_output clob;
   counter      number  := 0;
   failures     number  := 0;
   g_curr_loc   number  := 1;

/* Global variables set by Set_Client which can be used throughout a script */
   g_user_id      number;
   g_resp_id      number;
   g_appl_id      number;
   g_org_id       number;

/* Global variable set by Show_Header which can be referenced in scripts
   which branch based on applications release */
   g_appl_version varchar2(10);

   type V2T is table of varchar2(32767);

/* Types for use as parameters to the Display_SQL and Run_SQL API's */
   type headers   is table of varchar2(32767);
   type lengths   is table of integer;


procedure line_out (text varchar2);
procedure Insert_Style_Sheet;
procedure Insert_HTML(p_text varchar2);
procedure ActionErrorPrint(p_text varchar2);
procedure ActionPrint(p_text varchar2);
procedure ActionWarningPrint(p_text varchar2);
procedure WarningPrint(p_text varchar2);
procedure ActionErrorLink(p_txt1 varchar2
         , p_note varchar2
         , p_txt2 varchar2);
procedure ActionErrorLink(p_txt1 varchar2
         , p_url varchar2
         , p_link_txt varchar2
         , p_txt2 varchar2);
procedure ActionWarningLink(p_txt1 varchar2
                          , p_note varchar2
                          , p_txt2 varchar2);
procedure ActionWarningLink(p_txt1 varchar2
           , p_url varchar2
           , p_link_txt varchar2
           , p_txt2 varchar2);
procedure ErrorPrint(p_text varchar2);
procedure SectionPrint (p_text varchar2);
procedure Tab0Print (p_text varchar2);
procedure Tab1Print (p_text varchar2);
procedure Tab2Print (p_text varchar2);
procedure Tab3Print (p_text varchar2);
procedure BRPrint;
procedure checkFinPeriod (p_sobid NUMBER, p_appid NUMBER );
procedure CheckKeyFlexfield(p_flex_code     in varchar2
                        ,   p_flex_num  in number default null
                        ,   p_print_heading in boolean default true);
procedure CheckProfile(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0);
procedure Begin_Pre;
procedure End_Pre;
procedure Show_Table(p_type varchar2, p_values V2T, p_caption varchar2 default null, p_options V2T default null);
procedure Show_Table(p_values V2T);
procedure Show_Table(p_type varchar2);
procedure Show_Table_Row(p_values V2T, p_options V2T default null);
procedure Show_Table_Header(p_values V2T, p_options V2T default null);
procedure Show_Table_Header(p_headers in headers, p_lengths in out NOCOPY lengths);
procedure Start_Table (p_caption varchar2 default null);
procedure End_Table;
function Run_SQL(p_title varchar2, p_sql_statement varchar2) return number;
function Run_SQL(p_title varchar2,p_sql_statement varchar2,p_feedback varchar2) return number;
function Run_SQL(p_title varchar2,p_sql_statement varchar2,p_max_rows number) return number;
function Run_SQL(p_title varchar2,p_sql_statement varchar2,p_feedback varchar2, p_max_rows number) return number;
procedure Run_SQL(p_title varchar2, p_sql_statement varchar2);
procedure Run_SQL(p_title varchar2, p_sql_statement varchar2,p_feedback varchar2);
procedure Run_SQL(p_title varchar2,p_sql_statement varchar2,p_max_rows number);
procedure Run_SQL(p_title varchar2,p_sql_statement varchar2,p_feedback varchar2,p_max_rows number);
function Run_SQL(p_title varchar2,p_sql_statement varchar2, p_disp_lengths lengths) return number;
function Run_SQL(p_title varchar2,p_sql_statement varchar2,p_disp_lengths lengths,p_headers headers) return number;
function Run_SQL(p_title varchar2,p_sql_statement varchar2,p_disp_lengths lengths,p_headers headers,p_feedback varchar2) return number;
function Run_SQL(p_title varchar2,p_sql_statement varchar2,p_disp_lengths  lengths,p_headers headers,p_max_rows number) return number;
function Run_SQL(p_title varchar2,p_sql_statement varchar2,p_disp_lengths lengths,p_headers headers,p_feedback varchar2,p_max_rows number) return number;
procedure Run_SQL(p_title varchar2,p_sql_statement varchar2,p_disp_lengths  lengths);
procedure Run_SQL(p_title varchar2,p_sql_statement varchar2,p_disp_lengths  lengths,p_headers headers);
procedure Display_Table (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y');
procedure Show_Header(p_note varchar2, p_title varchar2);
procedure Show_Footer(p_script_name varchar2, p_header varchar2);
procedure Show_Footer;
procedure Show_Link(p_note varchar2);
procedure Show_Link(p_link varchar2, p_link_name varchar2 );
procedure Send_Email ( p_sender varchar2
                     , p_recipient varchar2
                     , p_subject varchar2
                     , p_message varchar2
                     , p_mailhost varchar2);
procedure Display_Profiles (p_application_id varchar2
                          , p_short_name     varchar2 default null);
procedure Set_Org (p_org_id number);
procedure Set_Client(p_user_name varchar2, p_resp_id number,
                     p_app_id number, p_sec_grp_id number);
procedure Set_Client(p_user_name varchar2, p_resp_id number);
procedure Set_Client(p_user_name varchar2, p_resp_id number,
                     p_app_id number );

/*
procedure Get_DB_Patch_List (p_heading varchar2 default 'AD_BUGS'
           , p_app_short_name varchar2 default '%'
           , p_bug_number varchar2 default '%'
           , p_start_date date default to_date(olddate,'MM-DD-YYYY')
           , p_output_option varchar2 default 'TABLE');
Procedure Show_Invalids (p_start_string   varchar2
                      ,  p_include_errors varchar2 default 'N'
                      ,  p_heading        varchar2 default null);
*/

Function CheckKeyFlexfield(p_flex_code     in varchar2
                       ,   p_flex_num  in number default null
                       ,   p_print_heading in boolean default true) return V2T;
function CheckProfile(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0) return varchar2;
function Column_Exists(p_tab in varchar, p_col in varchar, p_owner in varchar) return varchar2;
function Display_SQL (p_sql_statement  varchar2
                    , table_alias      varchar2
                    , display_longs    varchar2 default 'Y'
                    , p_feedback       varchar2 default 'Y'
                    , p_max_rows       number   default null
                    , p_current_exec   number default 0) return number;

function Display_SQL (p_sql_statement  varchar2
                    , table_alias      varchar2
                    , hideHeader Boolean
                    , display_longs    varchar2 default 'Y'
                    , p_feedback       varchar2 default 'Y'
                    , p_max_rows       number   default null
                    , p_current_exec   number default 0) return number;

function Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers default null
         , p_feedback      varchar2 default 'Y'
         , p_max_rows      number default null) return number;
procedure Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths);
procedure Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers);
procedure Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers
         , p_feedback      varchar2);
procedure Display_SQL(
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers
         , p_feedback      varchar2
         , p_max_rows      number);
function Display_Table (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') return number;
function Get_DB_Apps_Version return varchar2;
function Get_Package_Version (p_type varchar2, p_schema varchar2, p_package varchar2) return varchar2;
function Get_Package_Spec(p_package varchar2) return varchar2;
function Get_Package_Body(p_package varchar2) return varchar2;
function Get_Profile_Option (p_profile_option varchar2) return varchar2;
Function Get_RDBMS_Header return varchar2;
Function Compare_Pkg_Version(
     package_name   in varchar2,
     object_type in varchar2,
     object_owner in varchar2,
     version_str in out NOCOPY varchar2,
     compare_version in varchar2) return varchar2;
Function Compare_Pkg_Version_text(
     package_name   in varchar2,
     object_type in varchar2,
     version_str in out NOCOPY varchar2,
     compare_version in varchar2 default null) return varchar2;

END JTF_DIAGNOSTIC_COREAPI;


/
