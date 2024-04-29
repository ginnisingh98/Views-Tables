--------------------------------------------------------
--  DDL for Package PER_CANCEL_PLACEMENT_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CANCEL_PLACEMENT_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:54
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure cancel_placement_a (
p_business_group_id            number,
p_person_id                    number,
p_effective_date               date,
p_supervisor_warning           boolean,
p_recruiter_warning            boolean,
p_event_warning                boolean,
p_interview_warning            boolean,
p_review_warning               boolean,
p_vacancy_warning              boolean,
p_requisition_warning          boolean,
p_budget_warning               boolean,
p_payment_warning              boolean);
end per_cancel_placement_be1;

/
