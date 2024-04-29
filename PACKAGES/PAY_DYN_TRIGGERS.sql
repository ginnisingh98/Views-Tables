--------------------------------------------------------
--  DDL for Package PAY_DYN_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYN_TRIGGERS" AUTHID CURRENT_USER as
/* $Header: pydyntrg.pkh 115.11 2003/08/12 05:41:51 jford noship $ */

/* Global definitions */
--
--As soon as we know useful info from event capture process we put it here
--then the cc event capture code can do different things (eg insert different into
--PPE as relevant.) Eg From database trigger, or from API and explicit DT mode etc
  g_dyt_mode   varchar2(80) := 'UNSET';
  g_dbms_dyt   varchar2(80) := 'DBMS_TRIGGER';

/* Procedure definitions */
procedure enable_functional_area(p_short_name varchar2);
--
/*
   ADDENDUM 10-nov-02
      For the record I believe this code is now redundant , doesnt appear to be called.
      The main form to control functional areas, forms/US/PAYWSFGT now contains logic
      to rebuild all triggers and display appropriate error messages.  Any call to this
      procedure should still work, but no feedback on results will be given.
*/
procedure gen_functional_area(p_short_name varchar2);
--
procedure generate_trigger_event(p_short_name varchar2);
--
procedure create_trigger_event (
                                p_short_name varchar2,
                                p_table_name varchar2,
                                p_description varchar2,
                                p_generated_flag varchar2,
                                p_enabled_flag varchar2,
                                p_triggering_action varchar2,
                                p_owner  varchar2,
                                p_protected_flag varchar2 default 'N'
                               );
--
procedure create_trg_declaration (p_short_name varchar2,
                                p_variable_name varchar2,
                                p_data_type varchar2,
                                p_variable_size number,
                                p_owner  varchar2
                               );
--
procedure create_trg_initialisation (p_short_name varchar2,
                                p_process_order varchar2,
                                p_plsql_code varchar2,
                                p_process_type varchar2,
                                p_owner  varchar2
                               );
--
procedure create_trg_components (p_short_name varchar2,
                                p_legislative_code     varchar2,
                                p_business_group       varchar2,
                                p_payroll_name         varchar2,
                                p_module_name          varchar2,
                                p_enabled_flag         varchar2,
                                p_owner  varchar2
                               );
--
procedure create_trg_parameter (p_short_name varchar2,
                                p_process_order varchar2,
                                p_legislative_code     varchar2,
                                p_business_group       varchar2,
                                p_payroll_name         varchar2,
                                p_module_name   varchar2,
                                p_usage_type varchar2,
                                p_parameter_type varchar2,
                                p_parameter_name varchar2,
                                p_value_name varchar2,
                                p_automatic varchar2,
                                p_owner  varchar2
                               );
--
procedure create_func_area (p_area_name varchar2,
                            p_description varchar2
                               );
--
--default for backward compatability, UI uses new format
--old pycodytg.lct uses 2 param version and old patches will fail
procedure create_func_trigger (p_area_name varchar2,
                               p_short_name varchar2,
                               p_owner      varchar2 default 'SEED'
                               );
--
procedure create_event_update (p_table_name varchar2,
                               p_column_name varchar2,
                               p_business_group_name  varchar2,
                               p_legislation_code varchar2,
                               p_change_type varchar2
                               );
--
procedure create_func_usage (p_area_name varchar2
                            ,p_usage_id varchar2
			    ,p_business_group_name varchar2
			    ,p_legislation_code varchar2
			    ,p_payroll_name varchar2
			    ,p_owner     varchar2
                            );
--

function RETURN_DATED_TABLE_NAME ( p_dated_table_id number) return varchar2;

end pay_dyn_triggers;

 

/
