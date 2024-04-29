--------------------------------------------------------
--  DDL for Package IRC_PROF_AREA_CRITERIA_VAL_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PROF_AREA_CRITERIA_VAL_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:19
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_prof_area_criteria_a (
p_effective_date               date,
p_prof_area_criteria_value_id  number,
p_search_criteria_id           number,
p_professional_area            varchar2,
p_object_version_number        number);
end irc_prof_area_criteria_val_be1;

/