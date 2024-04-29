--------------------------------------------------------
--  DDL for Package HR_DELIVERY_METHODS_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DELIVERY_METHODS_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:16
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_delivery_method_a (
p_effective_date               date,
p_delivery_method_id           number,
p_date_start                   date,
p_date_end                     date,
p_comm_dlvry_method            varchar2,
p_preferred_flag               varchar2,
p_object_version_number        number,
p_request_id                   number,
p_program_update_date          date,
p_program_application_id       number,
p_program_id                   number,
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
p_attribute20                  varchar2);
end hr_delivery_methods_be2;

/
