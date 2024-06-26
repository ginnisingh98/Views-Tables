--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:56
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_previous_employer_a (
p_effective_date               date,
p_previous_employer_id         number,
p_start_date                   date,
p_end_date                     date,
p_period_years                 number,
p_period_months                number,
p_period_days                  number,
p_employer_name                varchar2,
p_employer_country             varchar2,
p_employer_address             varchar2,
p_employer_type                varchar2,
p_employer_subtype             varchar2,
p_description                  varchar2,
p_all_assignments              varchar2,
p_pem_attribute_category       varchar2,
p_pem_attribute1               varchar2,
p_pem_attribute2               varchar2,
p_pem_attribute3               varchar2,
p_pem_attribute4               varchar2,
p_pem_attribute5               varchar2,
p_pem_attribute6               varchar2,
p_pem_attribute7               varchar2,
p_pem_attribute8               varchar2,
p_pem_attribute9               varchar2,
p_pem_attribute10              varchar2,
p_pem_attribute11              varchar2,
p_pem_attribute12              varchar2,
p_pem_attribute13              varchar2,
p_pem_attribute14              varchar2,
p_pem_attribute15              varchar2,
p_pem_attribute16              varchar2,
p_pem_attribute17              varchar2,
p_pem_attribute18              varchar2,
p_pem_attribute19              varchar2,
p_pem_attribute20              varchar2,
p_pem_attribute21              varchar2,
p_pem_attribute22              varchar2,
p_pem_attribute23              varchar2,
p_pem_attribute24              varchar2,
p_pem_attribute25              varchar2,
p_pem_attribute26              varchar2,
p_pem_attribute27              varchar2,
p_pem_attribute28              varchar2,
p_pem_attribute29              varchar2,
p_pem_attribute30              varchar2,
p_pem_information_category     varchar2,
p_pem_information1             varchar2,
p_pem_information2             varchar2,
p_pem_information3             varchar2,
p_pem_information4             varchar2,
p_pem_information5             varchar2,
p_pem_information6             varchar2,
p_pem_information7             varchar2,
p_pem_information8             varchar2,
p_pem_information9             varchar2,
p_pem_information10            varchar2,
p_pem_information11            varchar2,
p_pem_information12            varchar2,
p_pem_information13            varchar2,
p_pem_information14            varchar2,
p_pem_information15            varchar2,
p_pem_information16            varchar2,
p_pem_information17            varchar2,
p_pem_information18            varchar2,
p_pem_information19            varchar2,
p_pem_information20            varchar2,
p_pem_information21            varchar2,
p_pem_information22            varchar2,
p_pem_information23            varchar2,
p_pem_information24            varchar2,
p_pem_information25            varchar2,
p_pem_information26            varchar2,
p_pem_information27            varchar2,
p_pem_information28            varchar2,
p_pem_information29            varchar2,
p_pem_information30            varchar2,
p_object_version_number        number);
end hr_previous_employment_be2;

/
