--------------------------------------------------------
--  DDL for Package IRC_LOCATION_CRITERIA_VAL_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LOCATION_CRITERIA_VAL_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:19
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_location_criteria_a (
p_location_criteria_value_id   number,
p_search_criteria_id           number,
p_derived_locale               varchar2,
p_object_version_number        number);
end irc_location_criteria_val_be1;

/
