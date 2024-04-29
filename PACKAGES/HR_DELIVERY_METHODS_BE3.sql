--------------------------------------------------------
--  DDL for Package HR_DELIVERY_METHODS_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DELIVERY_METHODS_BE3" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_delivery_method_a (
p_delivery_method_id           number,
p_object_version_number        number,
p_person_id                    number);
end hr_delivery_methods_be3;

/
