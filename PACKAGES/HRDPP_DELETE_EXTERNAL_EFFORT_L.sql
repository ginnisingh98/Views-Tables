--------------------------------------------------------
--  DDL for Package HRDPP_DELETE_EXTERNAL_EFFORT_L
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_DELETE_EXTERNAL_EFFORT_L" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:55
 * Generated for API: PSP_EXTERNAL_EFFORT_LINES_API.DELETE_EXTERNAL_EFFORT_LINE
 */
--
g_generator_version constant varchar2(128) default '$Revision: 120.4  $';
--

function dc(p in date) return varchar2;
pragma restrict_references(dc,WNDS);

function d(p in varchar2) return date;
pragma restrict_references(d,WNDS);
function n(p in varchar2) return number;
pragma restrict_references(n,WNDS);
function dd(p in date,i in varchar2) return varchar2;
pragma restrict_references(dd,WNDS);
function nd(p in number,i in varchar2) return varchar2;
pragma restrict_references(nd,WNDS);
--
procedure insert_batch_lines
(p_batch_id      in number
,p_data_pump_batch_line_id in number default null
,p_data_pump_business_grp_name in varchar2 default null
,p_user_sequence in number default null
,p_link_value    in number default null
,P_OBJECT_VERSION_NUMBER in number
,P_EXT_EFFORT_LINE_USER_KEY in varchar2);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_DELETE_EXTERNAL_EFFORT_L;
 

/