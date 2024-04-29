--------------------------------------------------------
--  DDL for Package PER_FR_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_TERMINATION" AUTHID CURRENT_USER as
/* $Header: pefrterm.pkh 120.1 2006/05/10 07:23:34 abhaduri noship $ */
procedure actual_termination(p_period_of_service_id number
                            ,p_actual_termination_date date);
--
procedure termination
(p_period_of_service_id number
,p_actual_termination_date date
,p_leaving_reason varchar2
,p_pds_information8 varchar2
,p_pds_information9 varchar2
,p_pds_information10 varchar2
,p_actual_termination_date_o date
,p_leaving_reason_o varchar2
,p_pds_information8_o varchar2
,p_pds_information9_o varchar2
,p_pds_information10_o varchar2
,p_final_process_date date -- added for bug#5191942
);
--
procedure reverse
(p_period_of_service_id number
,p_actual_termination_date date
,p_leaving_reason varchar2);
--

Function npil_earnings_base_12months
(p_assignment_id in Number
,p_last_day_worked in Date)
Return Number;

end per_fr_termination;

 

/
