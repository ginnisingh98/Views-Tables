--------------------------------------------------------
--  DDL for Package HRDPP_UPDATE_IN_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_UPDATE_IN_LOCATION" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:49
 * Generated for API: hr_in_location_api.update_in_location
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
,P_EFFECTIVE_DATE in date
,P_LANGUAGE_CODE in varchar2
,P_LOCATION_CODE in varchar2
,P_DESCRIPTION in varchar2 default null
,P_TIMEZONE_CODE in varchar2 default null
,P_ECE_TP_LOCATION_CODE in varchar2 default null
,P_FLAT_DOOR_BLOCK in varchar2 default null
,P_BUILDING_VILLAGE in varchar2 default null
,P_ROAD_STREET in varchar2 default null
,P_BILL_TO_SITE_FLAG in varchar2 default null
,P_IN_ORGANIZATION_FLAG in varchar2 default null
,P_INACTIVE_DATE in date default null
,I_INACTIVE_DATE in varchar2 default 'N'
,P_OFFICE_SITE_FLAG in varchar2 default null
,P_POSTAL_CODE in varchar2 default null
,P_RECEIVING_SITE_FLAG in varchar2 default null
,P_SHIP_TO_SITE_FLAG in varchar2 default null
,P_STYLE in varchar2 default null
,P_TAX_NAME in varchar2 default null
,P_TELEPHONE_NUMBER in varchar2 default null
,P_FAX_NUMBER in varchar2 default null
,P_AREA in varchar2 default null
,P_TOWN_CITY_DISTRICT in varchar2 default null
,P_STATE_UT in varchar2 default null
,P_EMAIL in varchar2 default null
,P_ATTRIBUTE_CATEGORY in varchar2 default null
,P_ATTRIBUTE1 in varchar2 default null
,P_ATTRIBUTE2 in varchar2 default null
,P_ATTRIBUTE3 in varchar2 default null
,P_ATTRIBUTE4 in varchar2 default null
,P_ATTRIBUTE5 in varchar2 default null
,P_ATTRIBUTE6 in varchar2 default null
,P_ATTRIBUTE7 in varchar2 default null
,P_ATTRIBUTE8 in varchar2 default null
,P_ATTRIBUTE9 in varchar2 default null
,P_ATTRIBUTE10 in varchar2 default null
,P_ATTRIBUTE11 in varchar2 default null
,P_ATTRIBUTE12 in varchar2 default null
,P_ATTRIBUTE13 in varchar2 default null
,P_ATTRIBUTE14 in varchar2 default null
,P_ATTRIBUTE15 in varchar2 default null
,P_ATTRIBUTE16 in varchar2 default null
,P_ATTRIBUTE17 in varchar2 default null
,P_ATTRIBUTE18 in varchar2 default null
,P_ATTRIBUTE19 in varchar2 default null
,P_ATTRIBUTE20 in varchar2 default null
,P_GLOBAL_ATTRIBUTE_CATEGORY in varchar2 default null
,P_GLOBAL_ATTRIBUTE1 in varchar2 default null
,P_GLOBAL_ATTRIBUTE2 in varchar2 default null
,P_GLOBAL_ATTRIBUTE3 in varchar2 default null
,P_GLOBAL_ATTRIBUTE4 in varchar2 default null
,P_GLOBAL_ATTRIBUTE5 in varchar2 default null
,P_GLOBAL_ATTRIBUTE6 in varchar2 default null
,P_GLOBAL_ATTRIBUTE7 in varchar2 default null
,P_GLOBAL_ATTRIBUTE8 in varchar2 default null
,P_GLOBAL_ATTRIBUTE9 in varchar2 default null
,P_GLOBAL_ATTRIBUTE10 in varchar2 default null
,P_GLOBAL_ATTRIBUTE11 in varchar2 default null
,P_GLOBAL_ATTRIBUTE12 in varchar2 default null
,P_GLOBAL_ATTRIBUTE13 in varchar2 default null
,P_GLOBAL_ATTRIBUTE14 in varchar2 default null
,P_GLOBAL_ATTRIBUTE15 in varchar2 default null
,P_GLOBAL_ATTRIBUTE16 in varchar2 default null
,P_GLOBAL_ATTRIBUTE17 in varchar2 default null
,P_GLOBAL_ATTRIBUTE18 in varchar2 default null
,P_GLOBAL_ATTRIBUTE19 in varchar2 default null
,P_GLOBAL_ATTRIBUTE20 in varchar2 default null
,P_COUNTRY in varchar2 default null
,P_SHIP_TO_LOCATION_ID in number default null
,I_SHIP_TO_LOCATION_ID in varchar2 default 'N');
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_update_in_location;
 

/
