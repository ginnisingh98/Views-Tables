--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_ORG_CLASSIFICATIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_ORG_CLASSIFICATIO" as
/*
 * Generated by hr_pump_meta_mapper at: 2013/08/30 12:08:05
 * Generated for API: HR_ORGANIZATION_API.CREATE_ORG_CLASSIFICATION
 */
--
g_generator_version constant varchar2(128) default '$Revision: 120.4.12010000.1 $';
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
,P_EFFECTIVE_DATE in date
,P_ORG_CLASSIF_CODE in varchar2
,P_ORGANIZATION_NAME in varchar2
,P_LANGUAGE_CODE in varchar2);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_CREATE_ORG_CLASSIFICATIO;

/
