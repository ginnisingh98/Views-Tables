--------------------------------------------------------
--  DDL for Package PER_QUALIFICATIONS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUALIFICATIONS_BE1" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_qualification_a (
p_qualification_id             number,
p_effective_date               date,
p_business_group_id            number,
p_qualification_type_id        number,
p_person_id                    number,
p_party_id                     number,
p_title                        varchar2,
p_grade_attained               varchar2,
p_status                       varchar2,
p_awarded_date                 date,
p_fee                          number,
p_fee_currency                 varchar2,
p_training_completed_amount    number,
p_reimbursement_arrangements   varchar2,
p_training_completed_units     varchar2,
p_total_training_amount        number,
p_start_date                   date,
p_end_date                     date,
p_license_number               varchar2,
p_expiry_date                  date,
p_license_restrictions         varchar2,
p_projected_completion_date    date,
p_awarding_body                varchar2,
p_tuition_method               varchar2,
p_group_ranking                varchar2,
p_comments                     varchar2,
p_attendance_id                number,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_qua_information_category     varchar2,
p_qua_information1             varchar2,
p_qua_information2             varchar2,
p_qua_information3             varchar2,
p_qua_information4             varchar2,
p_qua_information5             varchar2,
p_qua_information6             varchar2,
p_qua_information7             varchar2,
p_qua_information8             varchar2,
p_qua_information9             varchar2,
p_qua_information10            varchar2,
p_qua_information11            varchar2,
p_qua_information12            varchar2,
p_qua_information13            varchar2,
p_qua_information14            varchar2,
p_qua_information15            varchar2,
p_qua_information16            varchar2,
p_qua_information17            varchar2,
p_qua_information18            varchar2,
p_qua_information19            varchar2,
p_qua_information20            varchar2,
p_professional_body_name       varchar2,
p_membership_number            varchar2,
p_membership_category          varchar2,
p_subscription_payment_method  varchar2,
p_language_code                varchar2);
end per_qualifications_be1;

/
