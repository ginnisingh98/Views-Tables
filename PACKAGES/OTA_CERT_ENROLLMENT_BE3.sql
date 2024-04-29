--------------------------------------------------------
--  DDL for Package OTA_CERT_ENROLLMENT_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_ENROLLMENT_BE3" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:59
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_cert_enrollment_a (
p_cert_enrollment_id           number,
p_object_version_number        number,
p_person_id                    number);
end ota_cert_enrollment_be3;

/
