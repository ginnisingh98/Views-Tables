--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BE9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BE9" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_hr_organization_a (
p_effective_date               date,
p_business_group_id            number,
p_name                         varchar2,
p_date_from                    date,
p_language_code                varchar2,
p_location_id                  number,
p_date_to                      date,
p_internal_external_flag       varchar2,
p_internal_address_line        varchar2,
p_type                         varchar2,
p_enabled_flag                 varchar2,
p_segment1                     varchar2,
p_segment2                     varchar2,
p_segment3                     varchar2,
p_segment4                     varchar2,
p_segment5                     varchar2,
p_segment6                     varchar2,
p_segment7                     varchar2,
p_segment8                     varchar2,
p_segment9                     varchar2,
p_segment10                    varchar2,
p_segment11                    varchar2,
p_segment12                    varchar2,
p_segment13                    varchar2,
p_segment14                    varchar2,
p_segment15                    varchar2,
p_segment16                    varchar2,
p_segment17                    varchar2,
p_segment18                    varchar2,
p_segment19                    varchar2,
p_segment20                    varchar2,
p_segment21                    varchar2,
p_segment22                    varchar2,
p_segment23                    varchar2,
p_segment24                    varchar2,
p_segment25                    varchar2,
p_segment26                    varchar2,
p_segment27                    varchar2,
p_segment28                    varchar2,
p_segment29                    varchar2,
p_segment30                    varchar2,
p_concat_segments              varchar2,
p_object_version_number_inf    number,
p_object_version_number_org    number,
p_organization_id              number,
p_org_information_id           number,
p_duplicate_org_warning        boolean);
end hr_organization_be9;

/
