--------------------------------------------------------
--  DDL for Package OTA_DELEGATE_BOOKING_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_DELEGATE_BOOKING_BE3" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:00
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_delegate_booking_a (
p_booking_id                   number,
p_object_version_number        number,
p_person_id                    number);
end ota_delegate_booking_be3;

/
