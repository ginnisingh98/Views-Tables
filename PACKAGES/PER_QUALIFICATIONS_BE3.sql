--------------------------------------------------------
--  DDL for Package PER_QUALIFICATIONS_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUALIFICATIONS_BE3" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:19
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_qualification_a (
p_qualification_id             number,
p_object_version_number        number,
p_person_id                    number);
end per_qualifications_be3;

/
