--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BE7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BE7" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:31:56
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure update_delivered_dates_a (
p_activity_version_id          number,
p_old_start_date               date,
p_start_date                   date,
p_old_end_date                 date,
p_end_date                     date);
end hr_competence_element_be7;

 

/
