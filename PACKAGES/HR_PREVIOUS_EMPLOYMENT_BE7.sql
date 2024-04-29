--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BE7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BE7" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:58
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_previous_job_usage_a (
p_assignment_id                number,
p_previous_employer_id         number,
p_previous_job_id              number,
p_start_date                   date,
p_end_date                     date,
p_period_years                 number,
p_period_months                number,
p_period_days                  number,
p_pju_attribute_category       varchar2,
p_pju_attribute1               varchar2,
p_pju_attribute2               varchar2,
p_pju_attribute3               varchar2,
p_pju_attribute4               varchar2,
p_pju_attribute5               varchar2,
p_pju_attribute6               varchar2,
p_pju_attribute7               varchar2,
p_pju_attribute8               varchar2,
p_pju_attribute9               varchar2,
p_pju_attribute10              varchar2,
p_pju_attribute11              varchar2,
p_pju_attribute12              varchar2,
p_pju_attribute13              varchar2,
p_pju_attribute14              varchar2,
p_pju_attribute15              varchar2,
p_pju_attribute16              varchar2,
p_pju_attribute17              varchar2,
p_pju_attribute18              varchar2,
p_pju_attribute19              varchar2,
p_pju_attribute20              varchar2,
p_pju_information_category     varchar2,
p_pju_information1             varchar2,
p_pju_information2             varchar2,
p_pju_information3             varchar2,
p_pju_information4             varchar2,
p_pju_information5             varchar2,
p_pju_information6             varchar2,
p_pju_information7             varchar2,
p_pju_information8             varchar2,
p_pju_information9             varchar2,
p_pju_information10            varchar2,
p_pju_information11            varchar2,
p_pju_information12            varchar2,
p_pju_information13            varchar2,
p_pju_information14            varchar2,
p_pju_information15            varchar2,
p_pju_information16            varchar2,
p_pju_information17            varchar2,
p_pju_information18            varchar2,
p_pju_information19            varchar2,
p_pju_information20            varchar2,
p_previous_job_usage_id        number,
p_object_version_number        number);
end hr_previous_employment_be7;

/
