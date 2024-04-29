--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BE3" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:31:52
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure update_personal_comp_element_a (
p_competence_element_id        number,
p_object_version_number        number,
p_proficiency_level_id         number,
p_effective_date_from          date,
p_effective_date_to            date,
p_source_of_proficiency_level  varchar2,
p_certification_date           date,
p_certification_method         varchar2,
p_next_certification_date      date,
p_comments                     varchar2,
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
p_effective_date               date,
p_ins_ovn                      number,
p_ins_comp_id                  number);
end hr_competence_element_be3;

 

/
