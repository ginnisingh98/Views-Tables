--------------------------------------------------------
--  DDL for Package OTA_CERT_ENROLLMENT_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_ENROLLMENT_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:59
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_cert_enrollment_a (
p_effective_date               date,
p_cert_enrollment_id           number,
p_object_version_number        number,
p_certification_id             number,
p_person_id                    number,
p_contact_id                   number,
p_certification_status_code    varchar2,
p_completion_date              date,
p_unenrollment_date            date,
p_expiration_date              date,
p_earliest_enroll_date         date,
p_is_history_flag              varchar2,
p_business_group_id            number,
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
p_enrollment_date              date);
end ota_cert_enrollment_be2;

/
