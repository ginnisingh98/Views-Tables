--------------------------------------------------------
--  DDL for Package IRC_VARIABLE_COMP_ELEMENT_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VARIABLE_COMP_ELEMENT_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_variable_compensation_a (
p_vacancy_id                   number,
p_variable_comp_lookup         varchar2,
p_effective_date               date,
p_object_version_number        number);
end irc_variable_comp_element_be1;

/
