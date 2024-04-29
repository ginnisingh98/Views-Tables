--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_JOB" as
/*
 * Generated by hr_pump_meta_mapper at: 2018/06/16 10:06:02
 * Generated for API: hr_job_api.create_job
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
,P_DATE_FROM in date
,P_COMMENTS in varchar2 default null
,P_DATE_TO in date default null
,P_APPROVAL_AUTHORITY in number default null
,P_BENCHMARK_JOB_FLAG in varchar2 default null
,P_EMP_RIGHTS_FLAG in varchar2 default null
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
,P_JOB_INFORMATION_CATEGORY in varchar2 default null
,P_JOB_INFORMATION1 in varchar2 default null
,P_JOB_INFORMATION2 in varchar2 default null
,P_JOB_INFORMATION3 in varchar2 default null
,P_JOB_INFORMATION4 in varchar2 default null
,P_JOB_INFORMATION5 in varchar2 default null
,P_JOB_INFORMATION6 in varchar2 default null
,P_JOB_INFORMATION7 in varchar2 default null
,P_JOB_INFORMATION8 in varchar2 default null
,P_JOB_INFORMATION9 in varchar2 default null
,P_JOB_INFORMATION10 in varchar2 default null
,P_JOB_INFORMATION11 in varchar2 default null
,P_JOB_INFORMATION12 in varchar2 default null
,P_JOB_INFORMATION13 in varchar2 default null
,P_JOB_INFORMATION14 in varchar2 default null
,P_JOB_INFORMATION15 in varchar2 default null
,P_JOB_INFORMATION16 in varchar2 default null
,P_JOB_INFORMATION17 in varchar2 default null
,P_JOB_INFORMATION18 in varchar2 default null
,P_JOB_INFORMATION19 in varchar2 default null
,P_JOB_INFORMATION20 in varchar2 default null
,P_SEGMENT1 in varchar2 default null
,P_SEGMENT2 in varchar2 default null
,P_SEGMENT3 in varchar2 default null
,P_SEGMENT4 in varchar2 default null
,P_SEGMENT5 in varchar2 default null
,P_SEGMENT6 in varchar2 default null
,P_SEGMENT7 in varchar2 default null
,P_SEGMENT8 in varchar2 default null
,P_SEGMENT9 in varchar2 default null
,P_SEGMENT10 in varchar2 default null
,P_SEGMENT11 in varchar2 default null
,P_SEGMENT12 in varchar2 default null
,P_SEGMENT13 in varchar2 default null
,P_SEGMENT14 in varchar2 default null
,P_SEGMENT15 in varchar2 default null
,P_SEGMENT16 in varchar2 default null
,P_SEGMENT17 in varchar2 default null
,P_SEGMENT18 in varchar2 default null
,P_SEGMENT19 in varchar2 default null
,P_SEGMENT20 in varchar2 default null
,P_SEGMENT21 in varchar2 default null
,P_SEGMENT22 in varchar2 default null
,P_SEGMENT23 in varchar2 default null
,P_SEGMENT24 in varchar2 default null
,P_SEGMENT25 in varchar2 default null
,P_SEGMENT26 in varchar2 default null
,P_SEGMENT27 in varchar2 default null
,P_SEGMENT28 in varchar2 default null
,P_SEGMENT29 in varchar2 default null
,P_SEGMENT30 in varchar2 default null
,P_CONCAT_SEGMENTS in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null
,P_JOB_DEFINITION_ID in number
,P_BENCHMARK_JOB_USER_KEY in varchar2 default null
,P_JOB_GROUP_USER_KEY in varchar2);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_create_job;

/