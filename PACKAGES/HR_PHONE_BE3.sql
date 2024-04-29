--------------------------------------------------------
--  DDL for Package HR_PHONE_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PHONE_BE3" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_phone_a (
p_phone_id                     number,
p_object_version_number        number,
p_person_id                    number);
end hr_phone_be3;

/
