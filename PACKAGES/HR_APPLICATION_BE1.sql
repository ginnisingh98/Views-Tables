--------------------------------------------------------
--  DDL for Package HR_APPLICATION_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICATION_BE1" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:31:33
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure update_apl_details_a (
p_application_id               number,
p_object_version_number        number,
p_effective_date               date,
p_comments                     varchar2,
p_current_employer             varchar2,
p_projected_hire_date          date,
p_termination_reason           varchar2,
p_appl_attribute_category      varchar2,
p_appl_attribute1              varchar2,
p_appl_attribute2              varchar2,
p_appl_attribute3              varchar2,
p_appl_attribute4              varchar2,
p_appl_attribute5              varchar2,
p_appl_attribute6              varchar2,
p_appl_attribute7              varchar2,
p_appl_attribute8              varchar2,
p_appl_attribute9              varchar2,
p_appl_attribute10             varchar2,
p_appl_attribute11             varchar2,
p_appl_attribute12             varchar2,
p_appl_attribute13             varchar2,
p_appl_attribute14             varchar2,
p_appl_attribute15             varchar2,
p_appl_attribute16             varchar2,
p_appl_attribute17             varchar2,
p_appl_attribute18             varchar2,
p_appl_attribute19             varchar2,
p_appl_attribute20             varchar2);
end hr_application_be1;

 

/
