--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEEDS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEEDS_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:32
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_balance_feed_a (
p_effective_date               date,
p_business_group_id            number,
p_legislation_code             varchar2,
p_balance_type_id              number,
p_input_value_id               number,
p_scale                        number,
p_legislation_subgroup         varchar2,
p_balance_feed_id              number,
p_effective_start_date         date,
p_effective_end_date           date,
p_object_version_number        number,
p_exist_run_result_warning     boolean);
end pay_balance_feeds_be1;

/
