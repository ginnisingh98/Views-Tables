--------------------------------------------------------
--  DDL for Package PAY_PPE_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPE_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:33
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_process_event_a (
p_process_event_id             number,
p_object_version_number        number,
p_assignment_id                number,
p_effective_date               date,
p_change_type                  varchar2,
p_status                       varchar2,
p_description                  varchar2,
p_event_update_id              number,
p_org_process_event_group_id   number,
p_business_group_id            number,
p_surrogate_key                varchar2,
p_calculation_date             date,
p_retroactive_status           varchar2,
p_noted_value                  varchar2);
end pay_ppe_be2;

/
