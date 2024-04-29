--------------------------------------------------------
--  DDL for Package HR_CONTINGENT_WORKER_BE5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTINGENT_WORKER_BE5" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:56
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure reverse_terminate_placement_a (
p_validate                     boolean,
p_person_id                    number,
p_actual_termination_date      date,
p_clear_details                varchar2,
p_fut_actns_exist_warning      boolean);
end hr_contingent_worker_be5;

/
