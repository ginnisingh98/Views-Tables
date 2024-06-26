--------------------------------------------------------
--  DDL for Package HRDPP_UPDATE_CONTACT_RELATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_UPDATE_CONTACT_RELATIONS" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:35
 * Generated for API: HR_CONTACT_REL_API.UPDATE_CONTACT_RELATIONSHIP
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
,P_CONTACT_TYPE in varchar2 default null
,P_COMMENTS in long default null
,P_PRIMARY_CONTACT_FLAG in varchar2 default null
,P_THIRD_PARTY_PAY_FLAG in varchar2 default null
,P_BONDHOLDER_FLAG in varchar2 default null
,P_DATE_START in date default null
,I_DATE_START in varchar2 default 'N'
,P_DATE_END in date default null
,I_DATE_END in varchar2 default 'N'
,P_RLTD_PER_RSDS_W_DSGNTR_FLAG in varchar2 default null
,P_PERSONAL_FLAG in varchar2 default null
,P_SEQUENCE_NUMBER in number default null
,I_SEQUENCE_NUMBER in varchar2 default 'N'
,P_DEPENDENT_FLAG in varchar2 default null
,P_BENEFICIARY_FLAG in varchar2 default null
,P_CONT_ATTRIBUTE_CATEGORY in varchar2 default null
,P_CONT_ATTRIBUTE1 in varchar2 default null
,P_CONT_ATTRIBUTE2 in varchar2 default null
,P_CONT_ATTRIBUTE3 in varchar2 default null
,P_CONT_ATTRIBUTE4 in varchar2 default null
,P_CONT_ATTRIBUTE5 in varchar2 default null
,P_CONT_ATTRIBUTE6 in varchar2 default null
,P_CONT_ATTRIBUTE7 in varchar2 default null
,P_CONT_ATTRIBUTE8 in varchar2 default null
,P_CONT_ATTRIBUTE9 in varchar2 default null
,P_CONT_ATTRIBUTE10 in varchar2 default null
,P_CONT_ATTRIBUTE11 in varchar2 default null
,P_CONT_ATTRIBUTE12 in varchar2 default null
,P_CONT_ATTRIBUTE13 in varchar2 default null
,P_CONT_ATTRIBUTE14 in varchar2 default null
,P_CONT_ATTRIBUTE15 in varchar2 default null
,P_CONT_ATTRIBUTE16 in varchar2 default null
,P_CONT_ATTRIBUTE17 in varchar2 default null
,P_CONT_ATTRIBUTE18 in varchar2 default null
,P_CONT_ATTRIBUTE19 in varchar2 default null
,P_CONT_ATTRIBUTE20 in varchar2 default null
,P_CONT_INFORMATION_CATEGORY in varchar2 default null
,P_CONT_INFORMATION1 in varchar2 default null
,P_CONT_INFORMATION2 in varchar2 default null
,P_CONT_INFORMATION3 in varchar2 default null
,P_CONT_INFORMATION4 in varchar2 default null
,P_CONT_INFORMATION5 in varchar2 default null
,P_CONT_INFORMATION6 in varchar2 default null
,P_CONT_INFORMATION7 in varchar2 default null
,P_CONT_INFORMATION8 in varchar2 default null
,P_CONT_INFORMATION9 in varchar2 default null
,P_CONT_INFORMATION10 in varchar2 default null
,P_CONT_INFORMATION11 in varchar2 default null
,P_CONT_INFORMATION12 in varchar2 default null
,P_CONT_INFORMATION13 in varchar2 default null
,P_CONT_INFORMATION14 in varchar2 default null
,P_CONT_INFORMATION15 in varchar2 default null
,P_CONT_INFORMATION16 in varchar2 default null
,P_CONT_INFORMATION17 in varchar2 default null
,P_CONT_INFORMATION18 in varchar2 default null
,P_CONT_INFORMATION19 in varchar2 default null
,P_CONT_INFORMATION20 in varchar2 default null
,P_OBJECT_VERSION_NUMBER in number
,P_CONTACT_USER_KEY in varchar2
,P_CONTACTEE_USER_KEY in varchar2
,P_START_LIFE_REASON in varchar2 default null
,P_END_LIFE_REASON in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_UPDATE_CONTACT_RELATIONS;
 

/
