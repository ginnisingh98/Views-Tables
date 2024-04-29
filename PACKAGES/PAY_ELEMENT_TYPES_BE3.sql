--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPES_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPES_BE3" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:34
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_element_type_a (
p_effective_date               date,
p_datetrack_delete_mode        varchar2,
p_element_type_id              number,
p_object_version_number        number,
p_effective_start_date         date,
p_effective_end_date           date,
p_balance_feeds_warning        boolean,
p_processing_rules_warning     boolean);
end pay_element_types_be3;

/
