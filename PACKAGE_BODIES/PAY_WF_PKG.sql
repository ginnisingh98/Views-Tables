--------------------------------------------------------
--  DDL for Package Body PAY_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WF_PKG" AS
/* $Header: payuswfpkg.pkb 120.1.12010000.2 2009/12/24 11:23:43 mikarthi ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Package Body Name : PAY_WF_PKG
    Package File Name : payuswfpkg.pkb
    Description : This package declares functions which are ....

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    08-JUN-2003 jgoswami   115.0             Created
    19-JUN-2003 jgoswami   115.1   3006871   Created New Item attributes.
                                   3006753   Modified values passed to
                                             message text based on SRS input
    17-JUL-2003 jgoswami   115.3   3054384   Added Item Attributes for
                                             processes and retro notification.
    17-JUL-2003 jgoswami   115.4             Made  GSCC  Compliant
    18-JUL-2003 jgoswami   115.5             Modified the IF Conditions for
                                             HTML Message as Retro Notification
                                             was not displayed even if the
                                             parameters are entered.
    04-AUG-2003 jgoswami   115.6   3079094   Added parameter to check the
                                             required parameters are available
                                             to execute the Element Register
                                             Report.
    26-AUG-2003 jgoswami   115.7             modified parameter sequence to
                                             corelate with the SRS definition.
    09-DEC-2003 jgoswami   115.8  3310302    modified condition to check for
                                             BEE entered or skiped.
    12-APR-2004 jgoswami   115.9  3316422    Modified to pass correct Dates for
                                             all processes. Added itemattribute
                                             required for the workflow. Added
                                             functionality to wait for user
                                             response in notification based on
                                             PAYROLL_WF_NOTIFY_ACTION value
                                             WAIT or value is NULL -Default wait
                                             NOWAIT - Response not required for
                                             any Notification.
                                             PAYMENTWAIT - Response required for
                                             only payment notifications
    04-MAY-2004 jgoswami   115.10 3316422    Added Itemattribute to pas value to
                                             Notification.
    10-OCT-2005 jgoswami   115.6  4538713    modified procedure,added parameter
                                             for check_writer and Costing Report
    24-DEC-2009 mikarthi   115.12 9211154    l_profile_sec_grp_id variable was
                                             always holding NULL value


  *******************************************************************/



procedure payroll_wf_process(errbuf     OUT nocopy    VARCHAR2,
                      retcode    OUT nocopy    NUMBER,
                      p_wf_item_type        Varchar2,
                      p_business_group_id   number ,
                      p_batch_id            number ,
                      p_payroll_id        varchar2,
                      p_payroll_id_dummy    varchar2 ,
                      p_consolidation_set_id varchar2,
                      p_consolidation_set_id_dummy varchar2 ,
                      p_date_earned                varchar2,
                      p_date_paid                  varchar2,
                      p_period                     varchar2,
                      p_payroll_element_set_name   varchar2,
                      p_payroll_assignment_set_name varchar2,
                      p_payroll_run_type           varchar2,
                      p_event_group                varchar2,
                      p_retro_assignment_set_name  varchar2,
                      p_retro_assignment_set_dummy varchar2,
                      p_retro_element_set          varchar2,
                      p_retro_start_date           varchar2,
                      p_effective_date             varchar2,
                      p_gre                        varchar2,
                      p_gre_id_dummy               varchar2,
                      p_p_payroll_action_id        varchar2,
                      p_organization               varchar2,
                      p_location                   varchar2,
                      p_legislation_code           varchar2,
                      p_select_report_or_group     varchar2,
                      p_is_exception_group         varchar2,
                      p_exception_group_name       varchar2,
                      p_exception_group_name_dummy varchar2,
                      p_is_exception_report         varchar2,
                      p_exception_report_name      varchar2,
                      p_exception_report_name_dummy varchar2,
                      p_over_ride_variance_type    varchar2,
                      p_over_ride_varianc_type_dumy varchar2,
                      p_over_ride_variance_value   varchar2,
                      p_over_ride_varinc_value_dumy varchar2,
                      p_payment_method_override    varchar2,
                      p_nacha_payment_type         varchar2,
                      p_nacha_payment_method       varchar2,
                      p_deposit_date_override      varchar2,
                      p_file_id_modifier           varchar2,
                      p_file_id_modifier_check     varchar2,
                      p_thrid_party_check          varchar2,
                      p_check_writer_payment_type  varchar2,
                      p_check_style                varchar2,
                      p_check_writer_payment_method varchar2,
                      p_check_writer_sort_sequence  varchar2,
                      p_start_check_number         varchar2,
                      p_end_check_number           varchar2,
                      p_overriding_cheque_date     varchar2,
                      p_payment_method_3rd_party   varchar2,
                      p_sort_sequence_3rd_party    varchar2,
                      p_start_check_num_3rd_party varchar2,
                      p_end_check_num_3rd_party   varchar2,
                      p_da_report_category          varchar2,
                      p_da_sort_sequence          varchar2,
                      p_da_assignment_set         varchar2,
                      p_assignment_set_dummy       varchar2,
                      p_selection_criterion        varchar2,
                      p_is_element_set             varchar2,
                      p_ele_reg_element_set        varchar2,
                      p_is_element_classification  varchar2,
                      p_element_classification     varchar2,
                      p_is_element_name            varchar2,
                      p_element                    varchar2,
                      p_ele_reg_employee           varchar2,
                      p_costing_process            varchar2,
                      p_dummy_cost_run             varchar2,
                      p_cost_summary_accruals      varchar2,
                      p_cost_summary_file_out      varchar2,
                      p_cost_detail_selection      varchar2,
                      p_cost_detail_is_ele_set     varchar2,
                      p_cost_detail_ele_set        varchar2,
                      p_cost_detail_is_class       varchar2,
                      p_cost_detail_class          varchar2,
                      p_cost_detail_is_element     varchar2,
                      p_cost_detail_element        varchar2,
                      p_cost_detail_asg_set        varchar2,
                      p_cost_detail_accruals       varchar2,
                      p_start_date                 varchar2,
                      p_end_date                   varchar2,
                      p_ppa_finder                 varchar2,
                      p_ppa_finder_pqp             varchar2
                      ) is

  l_valid_status  varchar2(5);
  l_program       varchar2(100);
  l_workflowprocess  varchar2(100);
  l_ProcessDesc  varchar2(100);
  l_RequestorUsername    Varchar2(100);
  l_ProcessOwner   Varchar2(100);
  l_item_type   Varchar2(100);
  l_item_key   varchar2(100);
  lv_runnable_process Varchar2(1);

--
--
begin
--hr_utility.trace_on(null,'PYWF');
  gv_package := 'pay_wf_pkg';
  l_RequestorUsername := 'SYSADMIN';

  select to_char(sysdate,'DDHH24MISS') into l_item_key from  dual;

  -- initialise variable - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
  retcode := 0;


  l_workflowprocess  := 'PAYUSPROCESSWF';
  l_item_type := p_wf_item_type;

  BEGIN
       select RUNNABLE_FLAG
         into lv_runnable_process
         from wf_activities
        where item_type = p_wf_item_type
          and type = 'PROCESS'
          and name = l_workflowprocess
          and end_date is null;

  Exception     when others then
    hr_utility.trace('In exception: OTHERS at payroll_wf_process');
     null;

  END;



    hr_utility.trace('Item Type is : '|| l_item_type);
    hr_utility.trace('Item Key is : '|| l_item_key);
    hr_utility.trace('Workflow Process is : '|| l_workflowprocess);

if lv_runnable_process = 'Y' then

   StartProcess( p_business_group_id,
                      p_batch_id          ,
                      p_payroll_id        ,
                      p_payroll_id_dummy     ,
                      p_consolidation_set_id ,
                      p_consolidation_set_id_dummy  ,
                      p_date_earned                ,
                      p_date_paid                  ,
                      p_period                     ,
                      p_payroll_element_set_name   ,
                      p_payroll_assignment_set_name ,
                      p_payroll_run_type           ,
                      p_event_group                ,
                      p_retro_assignment_set_name  ,
                      p_retro_assignment_set_dummy ,
                      p_retro_element_set          ,
                      p_retro_start_date           ,
                      p_effective_date             ,
                      p_gre                        ,
                      p_gre_id_dummy               ,
                      p_p_payroll_action_id        ,
                      p_organization               ,
                      p_location                   ,
                      p_legislation_code           ,
                      p_select_report_or_group     ,
                      p_is_exception_group         ,
                      p_exception_group_name       ,
                      p_exception_group_name_dummy ,
                      p_is_exception_report        ,
                      p_exception_report_name      ,
                      p_exception_report_name_dummy ,
                      p_over_ride_variance_type    ,
                      p_over_ride_varianc_type_dumy ,
                      p_over_ride_variance_value   ,
                      p_over_ride_varinc_value_dumy ,
                      p_payment_method_override    ,
                      p_nacha_payment_type         ,
                      p_nacha_payment_method       ,
                      p_deposit_date_override      ,
                      p_file_id_modifier           ,
                      p_file_id_modifier_check     ,
                      p_thrid_party_check          ,
                      p_check_writer_payment_type  ,
                      p_check_style                ,
                      p_check_writer_payment_method ,
                      p_check_writer_sort_sequence  ,
                      p_start_check_number         ,
                      p_end_check_number           ,
                      p_overriding_cheque_date     ,
                      p_payment_method_3rd_party   ,
                      p_sort_sequence_3rd_party    ,
                      p_start_check_num_3rd_party ,
                      p_end_check_num_3rd_party   ,
                      p_da_report_category        ,
                      p_da_sort_sequence          ,
                      p_da_assignment_set         ,
                      p_assignment_set_dummy       ,
                      p_selection_criterion        ,
                      p_is_element_set             ,
                      p_ele_reg_element_set        ,
                      p_is_element_classification  ,
                      p_element_classification     ,
                      p_is_element_name            ,
                      p_element                    ,
                      p_ele_reg_employee           ,
                      p_costing_process            ,
                      p_dummy_cost_run             ,
                      p_cost_summary_accruals   ,
                      p_cost_summary_file_out   ,
                      p_cost_detail_selection   ,
                      p_cost_detail_is_ele_set  ,
                      p_cost_detail_ele_set     ,
                      p_cost_detail_is_class    ,
                      p_cost_detail_class       ,
                      p_cost_detail_is_element  ,
                      p_cost_detail_element     ,
                      p_cost_detail_asg_set     ,
                      p_cost_detail_accruals    ,
                      p_start_date                 ,
                      p_end_date                   ,
                      p_ppa_finder                 ,
                      p_ppa_finder_pqp             ,
                      l_ProcessDesc,
                      l_RequestorUsername,
                      l_ProcessOwner,
                      l_workflowprocess,
                      l_item_type,
                      l_item_key
                      );

end if;

EXCEPTION
  --
   WHEN hr_utility.hr_error THEN
     --
     -- Set up error message and error return code.
     --
        --hr_utility.trace('in the exception');
     errbuf  := hr_utility.get_message;
     retcode := 2;
     --
--
WHEN others THEN
--
     -- Set up error message and return code.
     errbuf  := sqlerrm;
     retcode := 2;
end payroll_wf_process;


--
-- Start Workflow Process will Create a Process and Set the Attributes
-- for the Workflow Process.


 procedure StartProcess	(
                      p_business_group_id           number ,
                      p_batch_id                    number ,
                      p_payroll_id                  varchar2,
                      p_payroll_id_dummy            varchar2 ,
                      p_consolidation_set_id        varchar2,
                      p_consolidation_set_id_dummy  varchar2 ,
                      p_date_earned                 varchar2,
                      p_date_paid                   varchar2,
                      p_period                      varchar2,
                      p_payroll_element_set_name    varchar2,
                      p_payroll_assignment_set_name varchar2,
                      p_payroll_run_type            varchar2,
                      p_event_group                 varchar2,
                      p_retro_assignment_set_name   varchar2,
                      p_retro_assignment_set_dummy  varchar2,
                      p_retro_element_set           varchar2,
                      p_retro_start_date            varchar2,
                      p_effective_date              varchar2,
                      p_gre                         varchar2,
                      p_gre_id_dummy                varchar2,
                      p_p_payroll_action_id         varchar2,
                      p_organization                varchar2,
                      p_location                    varchar2,
                      p_legislation_code            varchar2,
                      p_select_report_or_group      varchar2,
                      p_is_exception_group          varchar2,
                      p_exception_group_name        varchar2,
                      p_exception_group_name_dummy  varchar2,
                      p_is_exception_report         varchar2,
                      p_exception_report_name       varchar2,
                      p_exception_report_name_dummy varchar2,
                      p_over_ride_variance_type     varchar2,
                      p_over_ride_varianc_type_dumy varchar2,
                      p_over_ride_variance_value    varchar2,
                      p_over_ride_varinc_value_dumy varchar2,
                      p_payment_method_override     varchar2,
                      p_nacha_payment_type          varchar2,
                      p_nacha_payment_method        varchar2,
                      p_deposit_date_override       varchar2,
                      p_file_id_modifier            varchar2,
                      p_file_id_modifier_check      varchar2,
                      p_thrid_party_check           varchar2,
                      p_check_writer_payment_type   varchar2,
                      p_check_style                 varchar2,
                      p_check_writer_payment_method varchar2,
                      p_check_writer_sort_sequence  varchar2,
                      p_start_check_number          varchar2,
                      p_end_check_number            varchar2,
                      p_overriding_cheque_date      varchar2,
                      p_payment_method_3rd_party    varchar2,
                      p_sort_sequence_3rd_party     varchar2,
                      p_start_check_num_3rd_party   varchar2,
                      p_end_check_num_3rd_party     varchar2,
                      p_da_report_category          varchar2,
                      p_da_sort_sequence            varchar2,
                      p_da_assignment_set           varchar2,
                      p_assignment_set_dummy        varchar2,
                      p_selection_criterion         varchar2,
                      p_is_element_set              varchar2,
                      p_ele_reg_element_set         varchar2,
                      p_is_element_classification   varchar2,
                      p_element_classification      varchar2,
                      p_is_element_name             varchar2,
                      p_element                     varchar2,
                      p_ele_reg_employee            varchar2,
                      p_costing_process             varchar2,
                      p_dummy_cost_run              varchar2,
                      p_cost_summary_accruals   varchar2,
                      p_cost_summary_file_out   varchar2,
                      p_cost_detail_selection   varchar2,
                      p_cost_detail_is_ele_set  varchar2,
                      p_cost_detail_ele_set     varchar2,
                      p_cost_detail_is_class    varchar2,
                      p_cost_detail_class       varchar2,
                      p_cost_detail_is_element  varchar2,
                      p_cost_detail_element     varchar2,
                      p_cost_detail_asg_set     varchar2,
                      p_cost_detail_accruals    varchar2,
                      p_start_date                  varchar2,
                      p_end_date                    varchar2,
                      p_ppa_finder                  varchar2,
                      p_ppa_finder_pqp              varchar2,
                      ProcessDesc                   varchar2,
                      RequestorUsername             varchar2,
                      ProcessOwner               in varchar2,
                      Workflowprocess            in varchar2,
                      item_type                  in varchar2,
                      item_key                   in varchar2
                      ) is

ItemType	               	varchar2(30);
ItemKey    			varchar2(30);
ItemUserKey			varchar2(80);
l_business_group_id  		number(30);
l_payroll_id			number(16);
l_consolidation_set_id  	number(16);
ln_asignment_id         	NUMBER(30);

l_message_subject1 		varchar2(240);
l_message_text1 		varchar2(3200) ;
l_message_html_text1 		varchar2(3200) ;
l_message_html_text2 		varchar2(3200) ;
l_pay_excep_rpt_message_text1 	varchar2(3200) ;
l_pay_excep_rpt_message_html1 	varchar2(3200) ;
l_ele_reg_rpt_message_text1 	varchar2(3200) ;
l_ele_reg_rpt_message_html1 	varchar2(3200) ;
l_current_user  		varchar2(40);
l_current_user_display_name  	varchar2(40);
l_app_user_name   		varchar2(40);
l_orig_system     		varchar2(40);
l_orig_system_id  		varchar2(40);
l_role_name       		varchar2(50);
l_role_display_name     	varchar2(50);
lv_currency_code       		varchar2(5);
lv_is_batch       		varchar2(1);
lv_is_retro_ntfy       		varchar2(1);
lv_is_nacha       		varchar2(1);
lv_is_check       		varchar2(1);
lv_is_third_party_check 	varchar2(1);
lv_is_deposit_advice 		varchar2(1);
lv_is_payroll_exception_report 	varchar2(1);
lv_is_ele_reg       		varchar2(1);
lv_isResponseRequired   	varchar2(1) ;
lv_isPaymentWait   		varchar2(1) ;
lv_Payroll_WF_Notify_Action 	Varchar2(30);
ln_nacha_payment_type_id 	Varchar2(30);
ln_check_payment_type_id 	Varchar2(30);
lv_da_report 			Varchar2(30);

lv_payroll_name       		varchar2(80);
lv_consolidation_set_name 	varchar2(80);
lv_gre_name       		varchar2(80);
lv_org_name       		varchar2(80);
lv_loc_name       		varchar2(80);
lv_pre_ovr_pymt_name       	varchar2(80);
lv_check_pymt_name       	varchar2(80);
lv_nacha_pymt_name       	varchar2(80);
lv_event_group_name    		varchar2(80);
lv_loc_name       		varchar2(80);
lv_exc_grp_name         	varchar2(80);
lv_grp_orv_type         	varchar2(80);
lv_grp_orv_value        	varchar2(80);
lv_exc_rep_name         	varchar2(80);
lv_orv_type         		varchar2(80);
lv_orv_value        		varchar2(80);
lv_check_sort_seq_meaning 	varchar2(80);
lv_period_name 			varchar2(80);
lv_element_name 		varchar2(80);
lv_batch_name 			varchar2(80);

--l_profile_per_sec_id 		VARCHAR2(100);
l_profile_per_sec_id 		Number(15);
l_profile_per_bg 		VARCHAR2(100);
--l_profile_sec_grp_id 		VARCHAR2(100);
l_profile_sec_grp_id 		Number(15);
l_profile_user_name 		VARCHAR2(100);
lv_prc_list         		varchar2(3200);
lv_prc_list_html         	varchar2(3200);
lv_date_time 			varchar2(80);
l_proc	             		varchar2(80);
lv_contact_user_name		VARCHAR2(80);
l_user_id             		NUMBER;
l_resp_id             		NUMBER;
l_resp_appl_id 			NUMBER;
l_org_id             		NUMBER;
l_per_sec_id          		NUMBER;
l_sec_grp_id          		NUMBER;
i_count  			number;

lv_is_costing_summary      varchar2(1);
lv_is_costing_detail       varchar2(1);
lv_cost_summary_accruals   varchar2(80);
lv_cost_summary_file_out   varchar2(80);
lv_cost_detail_ele_set     varchar2(80);
lv_cost_detail_ele_class   varchar2(80);
lv_cost_detail_ele_name    varchar2(80);
lv_cost_detail_asg_set     varchar2(80);
lv_cost_detail_accruals    varchar2(80);

     varname   			Wf_Engine.NameTabTyp;
     varval    			Wf_Engine.TextTabTyp;

     num_varname   		Wf_Engine.NameTabTyp;
     num_varvalue 		Wf_Engine.NumTabTyp;

  TYPE char80_table IS TABLE OF VARCHAR2(80)
  INDEX BY BINARY_INTEGER;

    lv_conc_prog_name  		char80_table;
    lv_cur_process  		char80_table;
	i 			number;
	j 			number;
	k 			number;
	l			number;
	n 			number;
	p 			number;


cursor cur_costing_summary_accruals is
select meaning
from hr_lookups
where lookup_code  = p_cost_summary_accruals
and   lookup_type  = 'PAY_PAYRPCBR';

cursor cur_costing_summary_file_out is
select meaning
from fnd_common_lookups
where lookup_code    = p_cost_summary_file_out
and   lookup_type    = 'REPORT_OUTPUT_TYPE'
and   application_id = 801
and   enabled_flag   = 'Y';

cursor cur_costing_detail_ele_set is
select element_set_name
from pay_element_sets
where element_set_id  = to_number(p_cost_detail_ele_set)
and   element_set_type  = 'C';

cursor cur_costing_detail_ele_class is
select classification_name
from pay_element_classifications
where classification_id  = to_number(p_cost_detail_class);

cursor cur_costing_detail_ele_name is
select tl.element_name
from pay_element_types_f el, pay_element_types_f_tl tl
where el.element_type_id  = to_number(p_cost_detail_element)
and   el.element_type_id  = tl.element_type_id
and   tl.language = userenv('LANG')
and   fnd_date.canonical_to_date(p_date_earned)
            between el.effective_start_date and el.effective_end_date;

cursor cur_costing_detail_asg_set is
select assignment_set_name
from hr_assignment_sets
where assignment_set_id  = to_number(p_cost_detail_asg_set);

cursor cur_costing_detail_accruals is
select meaning
from hr_lookups
where lookup_code  = p_cost_detail_accruals
and   lookup_type  = 'PAY_PAYRPCBR';


begin

-- Initialize Variables
l_proc := gv_package||'.StartProcess';
ItemType := item_type;
ItemKey := item_key;
ItemUserKey := ProcessDesc;
l_business_group_id := p_business_group_id;
l_payroll_id := to_number(p_payroll_id);
l_consolidation_set_id  := to_number(p_consolidation_set_id);
lv_is_batch := 'N';
lv_is_retro_ntfy := 'N';
lv_is_nacha := 'N';
lv_is_check := 'N';
lv_is_third_party_check := 'N';
lv_is_deposit_advice := 'N';
lv_is_payroll_exception_report := 'N';
lv_is_ele_reg := 'N';
--hhh

-- Initialize the Process and Report List.
   lv_conc_prog_name(1) := 'BEE Batch Process (Transfer)';
   lv_conc_prog_name(2) := 'Retro-Notifications Report';
   lv_conc_prog_name(3) := 'Retro Pay By Element';
   lv_conc_prog_name(4) := 'Payroll Process';
   lv_conc_prog_name(5) := 'US Gross to Net Summary';
   lv_conc_prog_name(6) := 'Payroll Message Report';
   lv_conc_prog_name(7) := 'Employee Assignments Not Processed';
   lv_conc_prog_name(8) := 'Payroll Exception Report';
   lv_conc_prog_name(9) := 'Federal and State Tax Remittance Report';
   lv_conc_prog_name(10) := 'Pre Payments';
   lv_conc_prog_name(11) := 'NACHA';
   lv_conc_prog_name(12) := 'External Process Archive';
   lv_conc_prog_name(13) := 'Check Writer';
   lv_conc_prog_name(14) := 'Third Party Check Writer';
   lv_conc_prog_name(15) := 'Deposit Advice';
   lv_conc_prog_name(16) := 'Element Register Report';
   lv_conc_prog_name(17) := 'Payment Register Report';
   lv_conc_prog_name(18) := 'Third Party Payment Register Report';
   lv_conc_prog_name(19) := 'Costing Process';
   lv_conc_prog_name(20) := 'Costing Summary Report';
   lv_conc_prog_name(21) := 'Costing Detail Report';

--  wf_core.clear;

  -- make sure the process terminated by aborting it first
--  begin
--     wf_engine.abortprocess(ItemType, ItemKey);
--     exception
--        when others then null;
--  end;

    hr_utility.trace('In StartProcess Item Type is : '|| ItemType);
    hr_utility.trace('In StartProcess Item Key is : '|| ItemKey);
    hr_utility.trace('WF process name is : '|| Workflowprocess);

  begin
  select to_char(sysdate,'DD-MON-YYYY') ||' '|| to_char(sysdate,'HH24:MI:SS') into lv_date_time from  dual;
  end;

    hr_utility.trace('b4 create_process');

    wf_engine.createProcess( ItemType => ItemType,
                             ItemKey  => ItemKey,
                             process  => Workflowprocess);

    wf_engine.SetItemUserKey( 	ItemType => ItemType,
                             	ItemKey  => ItemKey,
                             	UserKey  => ItemUserKey);
      hr_utility.trace('In Start Process b4 HR_SIGNON.Initialize_HR_Security');
       HR_SIGNON.Initialize_HR_Security;
      hr_utility.trace('A4 HR_SIGNON.Initialize_HR_Security of Start ');

     l_user_id:= FND_GLOBAL.USER_ID;
     l_resp_appl_id:= FND_GLOBAL.RESP_APPL_ID;
     l_resp_id:= FND_GLOBAL.RESP_ID;
     l_org_id:= FND_GLOBAL.ORG_ID;

     l_per_sec_id := FND_GLOBAL.PER_SECURITY_PROFILE_ID;
     l_sec_grp_id  :=  FND_GLOBAL.SECURITY_GROUP_ID;

	hr_utility.trace('l_user_id = ' || l_user_id);
	hr_utility.trace('l_resp_appl_id = ' || l_resp_appl_id);
	hr_utility.trace('l_resp_id = ' || l_resp_id);
	hr_utility.trace('l_org_id = ' || l_org_id);
	hr_utility.trace('l_per_sec_id = ' || l_per_sec_id);
	hr_utility.trace('l_sec_grp_id = ' || l_sec_grp_id);
	hr_utility.trace('BG = ' || to_char(p_business_group_id));
	hr_utility.trace('PAYMENT TYPE = ' || p_nacha_payment_type);


   /*
     fnd_global.apps_initialize(l_user_id,l_resp_id,l_resp_appl_id);
*/

     Begin
     select currency_code into lv_currency_code
       from per_business_groups
      where business_group_id = p_business_group_id;
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;


     Begin
     SELECT to_char(PPT.PAYMENT_TYPE_ID) into ln_nacha_payment_type_id
      FROM PAY_PAYMENT_TYPES PPT,
           PER_BUSINESS_GROUPS BG
     WHERE ( ((PPT.TERRITORY_CODE IS NOT NULL
           AND PPT.TERRITORY_CODE=BG.LEGISLATION_CODE)
            OR PPT.TERRITORY_CODE IS NULL)
           AND BG.BUSINESS_GROUP_ID= p_business_group_id
           AND PPT.PAYMENT_TYPE_NAME = 'NACHA'
           );
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;


     Begin
     SELECT to_char(PPT.PAYMENT_TYPE_ID)
       into ln_check_payment_type_id
      FROM PAY_PAYMENT_TYPES PPT,
           PER_BUSINESS_GROUPS BG
     WHERE ( ((PPT.TERRITORY_CODE IS NOT NULL
           AND PPT.TERRITORY_CODE=BG.LEGISLATION_CODE)
            OR PPT.TERRITORY_CODE IS NULL)
           AND BG.BUSINESS_GROUP_ID= p_business_group_id
           AND PPT.PAYMENT_TYPE_NAME = 'Check'
           );
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;


     Begin
     select report_name into lv_da_report
       from pay_report_format_mappings_f
      where report_type = 'DAR'
        and report_category = p_da_report_category;
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;


     Begin
-- Payroll Name
     select payroll_name into lv_payroll_name
       from pay_all_payrolls_f
      where payroll_id = p_payroll_id
       and  fnd_date.canonical_to_date(p_date_earned)
            between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

    hr_utility.trace('lv_payroll_name = ' || lv_payroll_name);
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;

     Begin
-- Consolidation Set Name
     select consolidation_set_name into lv_consolidation_set_name
       from pay_consolidation_sets
      where consolidation_set_id = p_consolidation_set_id;

    hr_utility.trace('lv_consolidation_set_name = ' || lv_consolidation_set_name);
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;

     Begin
-- GRE Name
     select name into lv_gre_name
       from hr_tax_units_v
      where tax_unit_id = to_number(p_gre);
    hr_utility.trace('lv_gre_name = ' || lv_gre_name);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;

     Begin
-- Period Name
    select PERIOD_NAME into lv_period_name
      from per_time_periods
     where time_period_id = p_period;
    hr_utility.trace('lv_period_name = ' || lv_period_name);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;

     Begin
-- Event Group Name
     select event_group_name
       into lv_event_group_name
       from pay_event_groups
      where event_group_id = substr(p_event_group,12,length(p_event_group));

    hr_utility.trace('lv_event_group_name = ' || lv_event_group_name);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;

     Begin
-- Nacha Org Payment Method Name
    select ORG_PAYMENT_METHOD_NAME
      into lv_nacha_pymt_name
      from pay_org_payment_methods_f
     where business_group_id = p_business_group_id
       and org_payment_method_id  = p_nacha_payment_method
       and  fnd_date.canonical_to_date(p_date_earned)
            between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;
    hr_utility.trace('lv_nacha_pymt_name = ' || lv_nacha_pymt_name);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS Nacha Org Payment Method Name ');
     null;

   END;

     Begin
-- Check Org Payment Method Name
    select ORG_PAYMENT_METHOD_NAME
      into lv_check_pymt_name
      from pay_org_payment_methods_f
     where business_group_id = p_business_group_id
       and org_payment_method_id  = p_check_writer_payment_method
       and  fnd_date.canonical_to_date(p_date_earned)
            between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;
    hr_utility.trace('lv_check_pymt_name = ' || lv_check_pymt_name);
    Exception     when others then
    hr_utility.trace('In exception: OTHERS of Check Org Payment Method Name ');
     null;

   END;

     Begin
-- Pre Org Payment Method Name Override
    select ORG_PAYMENT_METHOD_NAME
      into lv_pre_ovr_pymt_name
      from pay_org_payment_methods_f
     where business_group_id = p_business_group_id
       and org_payment_method_id  = p_payment_method_override
       and  fnd_date.canonical_to_date(p_date_earned)
            between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;
    hr_utility.trace('lv_pre_ovr_pymt_name = ' || lv_pre_ovr_pymt_name);
    Exception     when others then
    hr_utility.trace('In exception : OTHERS Pre Org Payment Method Name Override');
     null;

   END;

  begin
    open cur_costing_summary_accruals;
    fetch cur_costing_summary_accruals into lv_cost_summary_accruals;
    close cur_costing_summary_accruals;

    hr_utility.trace('Costing Summary Accruals = ' || lv_cost_summary_accruals);

    open cur_costing_summary_file_out;
    fetch cur_costing_summary_file_out into lv_cost_summary_file_out;
    close cur_costing_summary_file_out;

    hr_utility.trace('Costing Summary File Format = ' || lv_cost_summary_file_out);

    open cur_costing_detail_ele_set;
    fetch cur_costing_detail_ele_set into lv_cost_detail_ele_set;
    close cur_costing_detail_ele_set;

    hr_utility.trace('Costing Detail Element Set = ' || lv_cost_detail_ele_set);

    open cur_costing_detail_ele_name;
    fetch cur_costing_detail_ele_name into lv_cost_detail_ele_name;
    close cur_costing_detail_ele_name;

    hr_utility.trace('Costing Detail Element Name = ' || lv_cost_detail_ele_name);

    open cur_costing_detail_ele_class;
    fetch cur_costing_detail_ele_class into lv_cost_detail_ele_class;
    close cur_costing_detail_ele_class;

    hr_utility.trace('Costing Detail Element Classification = ' || lv_cost_detail_ele_class);

    open cur_costing_detail_asg_set;
    fetch cur_costing_detail_asg_set into lv_cost_detail_asg_set;
    close cur_costing_detail_asg_set;

    hr_utility.trace('Costing Detail Assignment Set = ' || lv_cost_detail_asg_set);

    open cur_costing_detail_accruals;
    fetch cur_costing_detail_accruals into lv_cost_detail_accruals;
    close cur_costing_detail_accruals;

    hr_utility.trace('Costing Detail Accruals = ' || lv_cost_detail_accruals);

   END;


     Begin
-- Check lv_isResponseRequired
    select nvl(parameter_value,'WAIT')
      into lv_Payroll_WF_Notify_Action
      from pay_action_parameters
     where parameter_name = 'PAYROLL_WF_NOTIFY_ACTION';

    hr_utility.trace('lv_Payroll_WF_Notify_Action = ' || lv_Payroll_WF_Notify_Action);
    If lv_Payroll_WF_Notify_Action = 'WAIT' then
       lv_isResponseRequired := 'Y';
       lv_isPaymentWait := 'Y';
    elsif lv_Payroll_WF_Notify_Action = 'NOWAIT' then
       lv_isResponseRequired := 'N';
       lv_isPaymentWait := 'N';
    elsif lv_Payroll_WF_Notify_Action = 'PAYMENTWAIT' then
       lv_isResponseRequired := 'N';
       lv_isPaymentWait := 'Y';
    end if;

    hr_utility.trace('lv_isResponseRequire = ' || lv_isResponseRequired);
    hr_utility.trace('lv_isPaymentWait = ' || lv_isPaymentWait);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
    lv_isResponseRequired := 'Y';
    lv_isPaymentWait := 'Y';
    hr_utility.trace('lv_isResponseRequire = ' || lv_isResponseRequired);

   END;

     Begin
-- Check Sorting Sequence
    select meaning
      into lv_check_sort_seq_meaning
      from fnd_common_lookups
     where lookup_type = 'CHEQUE_PROCEDURE'
       and lookup_code = p_check_writer_sort_sequence;

    hr_utility.trace('lv_check_sort_seq_meaning = ' || lv_check_sort_seq_meaning);
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;

     Begin
-- Exception REports Information
    select per.exception_report_name ,
           hr_general.decode_lookup('PQP_VARIANCE_TYPES',per.variance_type) ovt,
           to_char(per.VARIANCE_VALUE)
      into lv_exc_rep_name,lv_orv_type,lv_orv_value
      from pqp_exception_reports per
     where legislation_code = 'US'
       and per.exception_report_id = p_exception_report_name;

    hr_utility.trace('lv_exc_rep_name = ' || lv_exc_rep_name);
    hr_utility.trace('lv_orv_type = ' || lv_orv_type);
    hr_utility.trace('lv_orv_value = ' || lv_orv_value);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;
/*
     Begin
-- Exception Group Information
    select perg.exception_report_name ,
           hr_general.decode_lookup('PQP_VARIANCE_TYPES',perg.variance_type) ovt,
           to_char(VARIANCE_VALUE)
      into lv_exc_grp_name,lv_grp_orv_type,lv_grp_orv_value
      from pqp_exception_report_groups perg
     where legislation_code = 'US'
       and perg.EXCEPTION_GROUP_ID = p_exception_group_name;

    hr_utility.trace('lv_gre_name = ' || lv_gre_name);
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;
*/
    Begin
    select element_name
      into lv_element_name
      from pay_element_types_f
      where element_type_id = p_element;
    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;

    Begin
     If p_batch_id is not null then
     select
       batch_name
       into        lv_batch_name
       from        pay_batch_headers
       where       batch_id = p_batch_id;
     End If;
    hr_utility.trace('Batch Name :' ||lv_batch_name);

    Exception     when others then
    lv_batch_name := '';
    hr_utility.trace('In exception: Batch Name ');
     null;

   END;

   Begin
        /* currently we are only looking at the context at payroll level
           as we do not have any required parameter for GRE on the SRS
           screen, if we want to use the contact defined at GRE level then
           we need to modify the package and SRS defination to get the
           GRE_ID , and pass it in the following function.
        */

        lv_contact_user_name := get_notifier( to_number(p_payroll_id),
                                              to_number(p_gre),
                                              p_date_earned);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS at get_notifier');
     null;

   END;

    Begin

    select orig_system,orig_system_id,name,display_name
      into l_orig_system,l_orig_system_id,l_role_name,l_role_display_name
      from wf_roles
     where name = lv_contact_user_name ;

    Exception     when others then
    hr_utility.trace('In exception: OTHERS ');
     null;

   END;
-- For debugging ..  remove the code
   Begin
/*
        select fnd_profile_server.value('PER_SECURITY_PROFILE_ID')
          into l_profile_per_sec_id
          from dual;
*/
        select to_number(fnd_profile_server.value('PER_SECURITY_PROFILE_ID'))
          into l_profile_per_sec_id
          from dual;
          select fnd_profile_server.value('PER_BUSINESS_GROUP_ID')
          into l_profile_per_bg
          from dual;
/*
          select fnd_profile_server.value('SECURITY_GROUP_ID')
          into l_profile_sec_grp_id
          from dual;
*/

/* Bug 9211154 - There is no profile 'SECURITY_GROUP_ID' and hence below query will always return NULL'
          select to_number(fnd_profile_server.value('SECURITY_GROUP_ID'))
          into l_profile_sec_grp_id
          from dual;
*/
          --Bug 9211154 Setting the value as fnd security group id
          l_profile_sec_grp_id := l_sec_grp_id;

          select fnd_profile_server.value('USERNAME')
          into l_profile_user_name
          from dual;

  hr_utility.trace('jj payuswfpkg l_profile_per_sec_id = '||l_profile_per_sec_id);
  hr_utility.trace('jj payuswfpkg l_profile_per_bg = '||l_profile_per_bg);
  hr_utility.trace('jj payuswfpkg l_profile_sec_grp_id = '||l_profile_sec_grp_id);
  hr_utility.trace('jj payuswfpkg l_profile_user_namep = '||l_profile_user_name);

    Exception     when others then
    hr_utility.trace('In exception: OTHERS at profile');
     null;

   END;

     --'JJ CA HRMS Manager';
    hr_utility.trace('orig ststem  : '|| l_orig_system);
    hr_utility.trace('orig ststem  : '|| l_orig_system_id);
    hr_utility.trace('l_role_name = ' || l_role_name);

  wf_engine.SetItemOwner ( itemtype  => ItemType,
                                itemkey   => ItemKey,
                                owner     => ProcessOwner);

--
   /* Set Require Values for the Variables
    */

-- BEE Transfer
     If p_batch_id is not null then
        lv_is_batch := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(1)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(1)||'</p>';
     else
        lv_is_batch := 'N';
     end if;

-- Retro Pay By Element and Retro Notification Report

     If ((p_retro_assignment_set_name is not null) and
         (p_event_group is not null )) then
        lv_is_retro_ntfy := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(2)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(2)||'</p>';
     else
        lv_is_retro_ntfy := 'N';
     end if;

-- Payroll Exception Report

     If ((p_exception_report_name is not null) OR
        (p_exception_group_name is not null)) then
        lv_is_payroll_exception_report := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(1)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(1)||'</p>';
     else
        lv_is_payroll_exception_report := 'N';
     end if;

-- NACHA

     If p_nacha_payment_method is not null then
        lv_is_nacha := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(1)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(1)||'</p>';
     else
        lv_is_nacha := 'N';
     end if;

-- Check
     If (p_check_writer_payment_method is not null ) and
        (p_start_check_number is not null ) then
        lv_is_check := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(1)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(1)||'</p>';
     else
        lv_is_check := 'N';
     end if;

-- Third Party Check

     If p_payment_method_3rd_party is not null then
        lv_is_third_party_check := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(1)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(1)||'</p>';
     else
        lv_is_third_party_check := 'N';
     end if;

-- Deposit Advice

     If p_da_report_category is not null then
        lv_is_deposit_advice := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(1)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(1)||'</p>';
     else
        lv_is_deposit_advice := 'N';
     end if;

-- Element Register Report
     If (p_selection_criterion is not null ) and
        ((p_ele_reg_element_set is not null) or
        (p_element_classification is not null) or
        (p_element is not null))
        then
        lv_is_ele_reg := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(16)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(16)||'</p>';
     else
        lv_is_ele_reg := 'N';
     end if;

-- Text
    for k in 4..19 loop
    lv_prc_list := lv_prc_list||lv_conc_prog_name(k);
    end loop;

-- HTML
    for l in 4..19 loop
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(l)||'</p>';
    end loop;

-- Costing Summary and Detail Report
     if ((p_consolidation_set_id is not null)) then
        lv_is_costing_detail := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(21)||wf_core.newline;
        lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(21)||'</p>';

        if (p_cost_summary_file_out is not null) then
           lv_is_costing_summary := 'Y';
           lv_prc_list := lv_prc_list||lv_conc_prog_name(20)||wf_core.newline;
           lv_prc_list_html := lv_prc_list_html||'<p>'||lv_conc_prog_name(20)||'</p>';
        else
           lv_is_costing_summary := 'N';
        end if;
     else
        lv_is_costing_summary := 'N';
        lv_is_costing_detail := 'N';
     end if;
    l_message_subject1 := 'List of Processes and Reports which will be submitted.';
 if lv_isResponseRequired = 'Y' then
    l_message_text1 := 'Review the List of Processes and Reports which will be submitted based on the input parameters, please click on the '||''''||'Continue'||''''||' button to start processing.'||wf_core.newline||lv_prc_list;

    l_message_html_text1 := 'Review the List of Processes and Reports which will be submitted based on the input parameters, please click on the '||''''||'Continue'||''''||' to start processing.';
 else
    l_message_text1 := 'Review the List of Processes and Reports which will be submitted based on the input parameters.'||wf_core.newline||lv_prc_list;

    l_message_html_text1 := 'Review the List of Processes and Reports which will be submitted based on the input parameters.';
 end if;

/*
    l_message_html_text1 := '<p> Review the List of Processes and Reports which will be submitted based on the input parameters, please click on the '||''''||'Continue'||''''||' button to start processing.'||'</p>'||'<p>'||lv_prc_list_html||'</p>';

*/

/*
    l_message_html_text1 := '<p> Review the List of Processes and Reports which will be submitted based on the input parameters, please click on the '||''''||'Continue'||''''||' to start processing.'||'</p>';


    l_message_html_text1 := 'Review the List of Processes and Reports which will be submitted based on the input parameters, please click on the '||''''||'Continue'||''''||' to start processing.';

*/
/*
    if ((lv_is_batch = 'Y') and (lv_is_retro_ntfy = 'Y'))then
    l_message_html_text2 := 'WF_NOTIFICATION(ATTRS,MSG_ATTR19,MSG_ATTR20,MSG_ATTR21,MSG_ATTR1,MSG_ATTR2,MSG_ATTR3,MSG_ATTR4,MSG_ATTR5,'
||'MSG_ATTR6,MSG_ATTR7,MSG_ATTR8,MSG_ATTR9,MSG_ATTR10,MSG_ATTR11,MSG_ATTR12,MSG_ATTR13,MSG_ATTR14,'
||'MSG_ATTR15,MSG_ATTR16,MSG_ATTR17,MSG_ATTR18)';
    elsif ((lv_is_batch = 'Y') and (lv_is_retro_ntfy = 'N' or lv_is_retro_ntfy is null))then
    l_message_html_text2 := 'WF_NOTIFICATION(ATTRS,MSG_ATTR19,MSG_ATTR1,MSG_ATTR2,MSG_ATTR3,MSG_ATTR4,MSG_ATTR5,MSG_ATTR6,MSG_ATTR7,'
||'MSG_ATTR8,MSG_ATTR9,MSG_ATTR10,MSG_ATTR11,MSG_ATTR12,MSG_ATTR13,MSG_ATTR14,'
||'MSG_ATTR15,MSG_ATTR16,MSG_ATTR17,MSG_ATTR18)';
    elsif ((lv_is_batch = 'N' or lv_is_batch is null) and (lv_is_retro_ntfy = 'Y'))then
    l_message_html_text2 := 'WF_NOTIFICATION(ATTRS,MSG_ATTR20,MSG_ATTR21,MSG_ATTR1,MSG_ATTR2,MSG_ATTR3,MSG_ATTR4,MSG_ATTR5,MSG_ATTR6,MSG_ATTR7,MSG_ATTR8,'
||'MSG_ATTR9,MSG_ATTR10,MSG_ATTR11,MSG_ATTR12,MSG_ATTR13,MSG_ATTR14,MSG_ATTR15,'
||'MSG_ATTR16,MSG_ATTR17,MSG_ATTR18)';
   else
    l_message_html_text2 := 'WF_NOTIFICATION(ATTRS,MSG_ATTR1,MSG_ATTR2,MSG_ATTR3,MSG_ATTR4,MSG_ATTR5,MSG_ATTR6,MSG_ATTR7,'
||'MSG_ATTR8,MSG_ATTR9,MSG_ATTR10,MSG_ATTR11,MSG_ATTR12,MSG_ATTR13,MSG_ATTR14,'
||'MSG_ATTR15,MSG_ATTR16,MSG_ATTR17,MSG_ATTR18)';
   end if;
*/

/*
-- Testing with multiple functions in the same text of the body for the notification

    if (lv_is_batch = 'Y') then
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR19)';
    elsif (lv_is_retro_ntfy = 'Y') then
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR20,MSG_ATTR21)';
    end if;
--   For Other Processes Dependent on Payroll Run.

       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR1,MSG_ATTR2,MSG_ATTR3,MSG_ATTR4,MSG_ATTR5)';

    if (lv_is_payroll_exception_report = 'Y') then
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR6)';
    end if;

       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR7)';

    if (lv_is_nacha = 'Y') then
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR8)';
    end if;

--  External Process Archive
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR9)';

    if (lv_is_check = 'Y') then
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR10)';
    elsif (lv_is_third_party_check = 'Y') then
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR11)';
   end if;

-- Deposit Advice

    if (lv_is_deposit_advice = 'Y') then
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR12)';
    end if;

-- Register Reports and Costing Process and Reports.

       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR13,MSG_ATTR14,MSG_ATTR15,MSG_ATTR16,MSG_ATTR17,MSG_ATTR18)';

*/
--jjj
-- Testing with single functions and all message attributes in the same text of the body for the notification , setting  vlalues of the message attribute by setting the values of the item attributes
n := 1;
    if (lv_is_batch = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(1);
       n := n+1;
    end if;

    if (lv_is_retro_ntfy = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(2);
       n := n+1;
       lv_cur_process(n) := lv_conc_prog_name(3);
       n := n+1;
    end if;
--   For Other Processes Dependent on Payroll Run.

       lv_cur_process(n) := lv_conc_prog_name(4);
       n := n+1;
       lv_cur_process(n) := lv_conc_prog_name(5);
       n := n+1;
       lv_cur_process(n) := lv_conc_prog_name(6);
       n := n+1;
       lv_cur_process(n) := lv_conc_prog_name(7);
       n := n+1;

    if (lv_is_payroll_exception_report = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(8);
       n := n+1;
       l_pay_excep_rpt_message_text1  := 'Payroll Exception Report(Request Id: &REQ_ID_REP4) :'||'
 Start Date:  &START_DATE
 End Date:  &END_DATE
 Payroll Name:  &PAYROLL
 Consolidation Set:  &CONSOLIDATION_SET
 Exception Group Name: &GROUP_NAME
 Exception Report Name: &REPORT_NAME
 Override Variance Type: &OVER_VAR_TYPE
 Override Variance Value: &OVER_VAR_VALUE ' ;
 l_pay_excep_rpt_message_html1 := 'Payroll Exception Report (Request Id: &REQ_ID_REP4) : WF_NOTIFICATION(ATTRS,START_DATE,PAYROLL,CONSOLIDATION_SET,GROUP_NAME,REPORT_NAME,OVER_VAR_TYPE,OVER_VAR_VALUE) ';

    else
       l_pay_excep_rpt_message_text1 := null;
       l_pay_excep_rpt_message_html1 := null;

    end if;

--Federal and State Tax Remittance Report

       lv_cur_process(n) := lv_conc_prog_name(9);
       n := n+1;

--Pre Payments

       lv_cur_process(n) := lv_conc_prog_name(10);
       n := n+1;

    if (lv_is_nacha = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(11);
       n := n+1;
    end if;

--  External Process Archive
       lv_cur_process(n) := lv_conc_prog_name(12);
       n := n+1;

    if (lv_is_check = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(13);
       n := n+1;
    end if;

    if (lv_is_third_party_check = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(14);
       n := n+1;
   end if;

-- Deposit Advice

    if (lv_is_deposit_advice = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(15);
       n := n+1;
    end if;

-- Register Reports and Costing Process and Reports.

    if (lv_is_ele_reg = 'Y') then
       lv_cur_process(n) := lv_conc_prog_name(16);
       n := n+1;
       l_ele_reg_rpt_message_text1  := 'Element Register(Request ID: &REQ_ID_REP6) ';
 l_ele_reg_rpt_message_html1 := 'Element Register Report (Request Id: &REQ_ID_REP6) ';

    else
       l_ele_reg_rpt_message_text1 := null;
       l_ele_reg_rpt_message_html1 := null;

    end if;

-- Payment Register

       lv_cur_process(n) := lv_conc_prog_name(17);
       n := n+1;

-- 3rd Payment Register

       lv_cur_process(n) := lv_conc_prog_name(18);
       n := n+1;

-- Costing Process

       lv_cur_process(n) := lv_conc_prog_name(19);
       n := n+1;

-- Costing Summary and  Detail Reports

       lv_cur_process(n) := lv_conc_prog_name(20);
       n := n+1;
       lv_cur_process(n) := lv_conc_prog_name(21);
       n := n+1;



       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR1,MSG_ATTR2,MSG_ATTR3,MSG_ATTR4,MSG_ATTR5)';
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR6,MSG_ATTR7,MSG_ATTR8,MSG_ATTR9,MSG_ATTR10)';
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR11,MSG_ATTR12,MSG_ATTR13,MSG_ATTR14,MSG_ATTR15)';
       l_message_html_text2 := l_message_html_text2 ||'WF_NOTIFICATION(ATTRS,MSG_ATTR16,MSG_ATTR17,MSG_ATTR18,MSG_ATTR19,MSG_ATTR20,MSG_ATTR21)';

      if n < 22 then
        for p in n..21 loop
        lv_cur_process(p) := null;
        end loop;
      end if;

    hr_utility.trace('p_payroll_id = ' || p_payroll_id);
    hr_utility.trace('p_consolidation_set_id = ' || p_consolidation_set_id);
    hr_utility.trace('p_date_earned = ' || p_date_earned);
    hr_utility.trace('p_date_paid = ' || p_date_paid);
    hr_utility.trace('p_payroll_assignment_set_name = ' || p_payroll_assignment_set_name);
    hr_utility.trace('p_payroll_run_type = ' || p_payroll_run_type);
    hr_utility.trace('ln_nacha_payment_type_id = ' || ln_nacha_payment_type_id);
    hr_utility.trace('check_style = ' || p_check_style);
begin

     i := 0;

     varname(i) := 'CUR_ITEM_TYPE';
     varval(i)  := ItemType;
              i := i+1;
     varname(i) := 'CURR_ITEM_KEY';
     varval(i)  := ItemKey;
              i := i+1;
     varname(i) := 'IS_BATCH';
     varval(i)  := lv_is_batch;
              i := i+1;
     varname(i) := 'IS_RETRO';
     varval(i)  := lv_is_retro_ntfy;
              i := i+1;
     varname(i) := 'PAYROLL_NAME';
     varval(i)  := lv_payroll_name;
              i := i+1;
     varname(i) := 'PAYROLL_ID';
     varval(i)  := p_payroll_id;
              i := i+1;
     varname(i) := 'CONSOLIDATION_SET_NAME';
     varval(i)  := lv_consolidation_set_name;
              i := i+1;
     varname(i) := 'CONSOLIDATION_SET_ID';
     varval(i)  := p_consolidation_set_id;
              i := i+1;
     varname(i) := 'DATE_EARNED';
     varval(i)  := p_date_earned;
              i := i+1;
     varname(i) := 'DATE_PAID';
     varval(i)  := p_date_paid;
              i := i+1;
     varname(i) := 'EVENT_GROUP';
     varval(i)  := p_event_group;
              i := i+1;
     varname(i) := 'RETRO_ASSIGNMENT_SET_NAME';
     varval(i)  := p_retro_assignment_set_name;
              i := i+1;
     varname(i) := 'RETRO_ASSIGNMENT_SET_NAME_DUMY';
     varval(i)  := p_retro_assignment_set_dummy;
              i := i+1;
     varname(i) := 'RETRO_ELEMENT_SET';
     varval(i)  := p_retro_element_set;
              i := i+1;
     varname(i) := 'RETRO_START_DATE';
     varval(i)  := p_retro_start_date;
              i := i+1;
     varname(i) := 'EFFECTIVE_DATE';
     varval(i)  := p_effective_date;
     --varval(i)  := p_date_earned;
     --varval(i)  := p_date_paid;
              i := i+1;
     varname(i) := 'PAYROLL_ELEMENT_SET_NAME';
     varval(i)  := p_payroll_element_set_name;
              i := i+1;
     varname(i) := 'PAYROLL_ASSIGNMENT_SET_NAME';
     varval(i)  := p_payroll_assignment_set_name;
              i := i+1;
     varname(i) := 'PAYROLL_RUN_TYPE';
     varval(i)  := p_payroll_run_type;
              i := i+1;
     varname(i) := 'GOVERNMENT_REPORTING_ENTITY';
     varval(i)  := p_gre;
              i := i+1;
     varname(i) := 'GRE_NAME';
     varval(i)  := lv_gre_name;
              i := i+1;
     varname(i) := 'ORGANIZATION';
     varval(i)  := p_organization;
              i := i+1;
     varname(i) := 'LOCATION';
     varval(i)  := p_location;
              i := i+1;
     varname(i) := 'IS_PAYROLL_EXCEPTION_REPORT';
     varval(i)  := lv_is_payroll_exception_report;
              i := i+1;
     varname(i) := 'SELECT_REPORT_OR_GROUP';
     varval(i)  := p_select_report_or_group;
              i := i+1;
     varname(i) := 'EXCEPTION_GROUP_NAME';
     varval(i)  := p_exception_group_name;
              i := i+1;
     varname(i) := 'EXCPTN_RPT_GRP_NAME';
     varval(i)  := lv_exc_grp_name;
              i := i+1;
     varname(i) := 'EXCPTN_RPT_NAME';
     varval(i)  := lv_exc_rep_name;
              i := i+1;
     varname(i) := 'EXCEPTION_GROUP_NAME_DMY';
     varval(i)  := p_exception_group_name_dummy;
              i := i+1;
     varname(i) := 'EXCEPTION_REPORT_NAME';
     varval(i)  := p_exception_report_name;
              i := i+1;
     varname(i) := 'EXCEPTION_REPORT_NAME_DMY';
     varval(i)  := p_exception_report_name_dummy;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_TYPE';
     varval(i)  := p_over_ride_variance_type;
              i := i+1;
     varname(i) := 'ORV_TYPE';
     varval(i)  := lv_orv_type;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_TYPE_DMY';
     varval(i)  := p_over_ride_varianc_type_dumy;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_VALUE';
     varval(i)  := p_over_ride_variance_value;
              i := i+1;
     varname(i) := 'ORV_VALUE';
     varval(i)  := lv_orv_value;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_VALUE_DMY';
     varval(i)  := p_over_ride_varinc_value_dumy;
              i := i+1;
     varname(i) := 'TRANSFER_DATE';
--     varval(i)  := 'TRANSFER_DATE='||p_effective_date;
     --varval(i)  := 'TRANSFER_DATE='||p_date_earned;
     varval(i)  := 'TRANSFER_DATE='||p_date_paid;
              i := i+1;
     varname(i) := 'PPA_FINDER_PQP';
     varval(i)  := p_ppa_finder_pqp;
              i := i+1;
     varname(i) := 'TRANSFER_PPA_FINDER_PQP';
     varval(i)  := 'TRANSFER_PPA_FINDER='||p_ppa_finder_pqp;
              i := i+1;
     varname(i) := 'PREPAY_PAYMENT_METHOD_OVERRIDE';
     varval(i)  := p_payment_method_override;
              i := i+1;
     varname(i) := 'IS_NACHA';
     varval(i)  := lv_is_nacha;
              i := i+1;
     varname(i) := 'NACHA_PAYMENT_METHOD';
     varval(i)  := p_nacha_payment_method;
              i := i+1;
     varname(i) := 'NACHA_PYMT_NAME';
     varval(i)  := lv_nacha_pymt_name;
              i := i+1;
     varname(i) := 'DEPOSIT_DATE_OVERRIDE';
     varval(i)  := p_deposit_date_override;
              i := i+1;
     varname(i) := 'FILE_ID_MODIFIER';
     varval(i)  := p_file_id_modifier;
              i := i+1;
     varname(i) := 'FILE_ID_MODIFIER_CHECK';
     varval(i)  := p_file_id_modifier_check;
              i := i+1;
     varname(i) := 'THRID_PARTY_CHECK';
     varval(i)  := p_thrid_party_check;
              i := i+1;
     varname(i) := 'IS_CHECK';
     varval(i)  := lv_is_check;
              i := i+1;
     varname(i) := 'CHECK_WRITER_PAYMENT_METHOD';
     varval(i)  := p_check_writer_payment_method;
              i := i+1;
     varname(i) := 'CHECK_PYMT_NAME';
     varval(i)  := lv_check_pymt_name;
              i := i+1;
     varname(i) := 'CHECK_WRITER_SORT_SEQUENCE';
     varval(i)  := p_check_writer_sort_sequence;
              i := i+1;
    varname(i) := 'CHECK_SORT_SEQ_MEANING';
     varval(i)  := lv_check_sort_seq_meaning;
              i := i+1;
     varname(i) := 'CHECK_STYLE';
     varval(i)  := p_check_style;
              i := i+1;
     varname(i) := 'IS_THIRD_PARTY_CHECK';
     varval(i)  := lv_is_third_party_check;
              i := i+1;
     varname(i) := 'PAYMENT_METHOD_3RD_PARTY';
     varval(i)  := p_payment_method_3rd_party;
              i := i+1;
     varname(i) := 'SORT_SEQUENCE_3RD_PARTY';
     varval(i)  := p_sort_sequence_3rd_party;
              i := i+1;
     varname(i) := 'IS_DEPOSIT_ADVICE';
     varval(i)  := lv_is_deposit_advice;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_REPORT_CATEGORY';
     varval(i)  := p_da_report_category;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_START_DATE_DMY';
     varval(i)  := 'START_DATE='||p_date_paid;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_END_DATE_DMY';
     varval(i)  := 'END_DATE='||p_date_paid;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_PAYROLL';
     varval(i)  := 'PAYROLL_ID='||p_payroll_id;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_CONC_SET';
     varval(i)  := 'CONSOLIDATION_SET_ID='||p_consolidation_set_id;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_SORT_SEQUENCE';
     varval(i)  := p_da_sort_sequence;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_ASSIGNMENT_SET';
     varval(i)  := p_da_assignment_set;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_ASGSET_DMY';
     varval(i)  := p_assignment_set_dummy;
              i := i+1;
     varname(i) := 'DEPOSIT_ADVICE_REPORT_NAME';
     varval(i)  := lv_da_report;
              i := i+1;
     varname(i) := 'SELECTION_CRITERION';
     varval(i)  := p_selection_criterion;
              i := i+1;
     varname(i) := 'ELE_REG_ELEMENT_SET';
     varval(i)  := p_ele_reg_element_set;
              i := i+1;
     varname(i) := 'ELEMENT_CLASSIFICATION';
     varval(i)  := p_element_classification;
              i := i+1;
     varname(i) := 'ELEMENT';
     varval(i)  := p_element;
              i := i+1;
     varname(i) := 'ELEMENT_NAME';
     varval(i)  := lv_element_name;
---              i := i+1;
---     varname(i) := 'ELEMENT_REGISTER_EMPLOYEE';
---     varval(i)  := p_ele_reg_employee;
              i := i+1;
     varname(i) := 'EMP_ID';
     varval(i)  := p_ele_reg_employee;
              i := i+1;
     varname(i) := 'COSTING_PROCESS';
     varval(i)  := p_costing_process;
              i := i+1;
     varname(i) := 'START_DATE';
     varval(i)  := p_date_earned;
              i := i+1;
     varname(i) := 'END_DATE';
     varval(i)  := p_date_paid;
              i := i+1;
     varname(i) := 'PPA_FINDER';
     varval(i)  := p_ppa_finder;
              i := i+1;
     varname(i) := 'USER';
     varval(i)  := lv_contact_user_name;
---     varval(i)  := RequestorUsername;
              i := i+1;
     varname(i) := 'CONTACT_USERNAME';
     varval(i)  := lv_contact_user_name;
              i := i+1;
     varname(i) := 'MESSAGE_SUBJECT1';
     varval(i)  := l_message_subject1;
              i := i+1;
     varname(i) := 'MESSAGE_TEXT1';
     varval(i)  := l_message_text1;
              i := i+1;
     varname(i) := 'MESSAGE_HTML_TEXT1';
     varval(i)  := l_message_html_text1;
              i := i+1;
     varname(i) := 'MESSAGE_HTML_TEXT2';
     varval(i)  := l_message_html_text2;
              i := i+1;
     varname(i) := 'ROLE_NAME';
     varval(i)  := l_role_name;
              i := i+1;
     varname(i) := 'REPORTING_CURRENCY_CODE';
     varval(i)  := lv_currency_code;
              i := i+1;
     varname(i) := 'PPA_FINDER';
     varval(i)  := p_ppa_finder;
              i := i+1;
     varname(i) := 'TRANSFER_PPA_FINDER';
     varval(i)  := 'TRANSFER_PPA_FINDER='||p_ppa_finder;
              i := i+1;
     varname(i) := 'TRANSFER_GRE';
     varval(i)  := 'TRANSFER_GRE='||p_gre;
              i := i+1;
     varname(i) := 'TRANSFER_PAYROLL';
     varval(i)  := 'TRANSFER_PAYROLL='||p_payroll_id;
              i := i+1;
     varname(i) := 'TRANSFER_CONC_SET';
     varval(i)  := 'TRANSFER_CONC_SET='||p_consolidation_set_id;
              i := i+1;
     varname(i) := 'XFR_TRANSFER_PAYROLL_ID';
     varval(i)  := 'TRANSFER_PAYROLL_ID='||p_payroll_id;
              i := i+1;
     varname(i) := 'XFR_TRANS_CONS_SET';
     varval(i)  := 'TRANSFER_CONSOLIDATION_SET_ID='||p_consolidation_set_id;
              i := i+1;
     varname(i) := 'FILE_ID_MODIFIER_HIDDEN';
     varval(i)  := 'FILE_ID_MODIFIER='||p_file_id_modifier;
              i := i+1;
     varname(i) := 'PERIOD';
     varval(i)  := p_period;
              i := i+1;
     varname(i) := 'PERIOD_NAME';
     varval(i)  := lv_period_name;
              i := i+1;
     varname(i) := 'P_PAYROLL_ACTION_ID';
     varval(i)  := p_p_payroll_action_id;
              i := i+1;
     varname(i) := 'NACHA_PAYMENT_TYPE_ID';
     varval(i)  := ln_nacha_payment_type_id;
              i := i+1;
     varname(i) := 'CHECK_PAYMENT_TYPE_ID';
     varval(i)  := ln_check_payment_type_id;
              i := i+1;
     varname(i) := 'DATE_TIME';
     varval(i)  := lv_date_time;
              i := i+1;
     varname(i) := 'END_DATE_LEG_PARAM';
     varval(i)  := 'END_DATE='||p_date_earned;
              i := i+1;
     varname(i) := 'PAYROLL_LEG_PARAM';
     varval(i)  := 'PAYROLL_ID='||p_payroll_id;
              i := i+1;
     varname(i) := 'CONC_SET_LEG_PARAM';
     varval(i)  := 'CONSOLIDATION_SET_ID='||p_consolidation_set_id;
              i := i+1;
     varname(i) := 'PROCESS_01';
     varval(i)  := lv_cur_process(1);
              i := i+1;
     varname(i) := 'PROCESS_02';
     varval(i)  := lv_cur_process(2);
              i := i+1;
     varname(i) := 'PROCESS_03';
     varval(i)  := lv_cur_process(3);
              i := i+1;
     varname(i) := 'PROCESS_04';
     varval(i)  := lv_cur_process(4);
              i := i+1;
     varname(i) := 'PROCESS_05';
     varval(i)  := lv_cur_process(5);
              i := i+1;
     varname(i) := 'PROCESS_06';
     varval(i)  := lv_cur_process(6);
              i := i+1;
     varname(i) := 'PROCESS_07';
     varval(i)  := lv_cur_process(7);
              i := i+1;
     varname(i) := 'PROCESS_08';
     varval(i)  := lv_cur_process(8);
              i := i+1;
     varname(i) := 'PROCESS_09';
     varval(i)  := lv_cur_process(9);
              i := i+1;
     varname(i) := 'PROCESS_10';
     varval(i)  := lv_cur_process(10);
              i := i+1;
     varname(i) := 'PROCESS_11';
     varval(i)  := lv_cur_process(11);
              i := i+1;
     varname(i) := 'PROCESS_12';
     varval(i)  := lv_cur_process(12);
              i := i+1;
     varname(i) := 'PROCESS_13';
     varval(i)  := lv_cur_process(13);
              i := i+1;
     varname(i) := 'PROCESS_14';
     varval(i)  := lv_cur_process(14);
              i := i+1;
     varname(i) := 'PROCESS_15';
     varval(i)  := lv_cur_process(15);
              i := i+1;
     varname(i) := 'PROCESS_16';
     varval(i)  := lv_cur_process(16);
              i := i+1;
     varname(i) := 'PROCESS_17';
     varval(i)  := lv_cur_process(17);
              i := i+1;
     varname(i) := 'PROCESS_18';
     varval(i)  := lv_cur_process(18);
              i := i+1;
     varname(i) := 'PROCESS_19';
     varval(i)  := lv_cur_process(19);
              i := i+1;
     varname(i) := 'PROCESS_20';
     varval(i)  := lv_cur_process(20);
              i := i+1;
     varname(i) := 'PROCESS_21';
     varval(i)  := lv_cur_process(21);
              i := i+1;
     varname(i) := 'BEE_BATCH_NAME';
     varval(i)  := lv_batch_name;
              i := i+1;
     varname(i) := 'PAY_EXCEPTION_RPT_MSG_TEXT1';
     varval(i)  := l_pay_excep_rpt_message_text1;
              i := i+1;
     varname(i) := 'PAY_EXCEPTION_RPT_MSG_HTML1';
     varval(i)  := l_pay_excep_rpt_message_html1;
              i := i+1;
     varname(i) := 'RETRO_START_DATE_DUMMY';
     varval(i)  := 'START_DATE='||p_retro_start_date;
              i := i+1;
     varname(i) := 'ELEMENT_REGISTER_RPT_MSG_TEXT1';
     varval(i)  := l_ele_reg_rpt_message_text1;
              i := i+1;
     varname(i) := 'ELEMENT_REGISTER_RPT_MSG_HTML1';
     varval(i)  := l_ele_reg_rpt_message_html1;
              i := i+1;
     varname(i) := 'IS_ELEMENT_REGISTER_REPORT';
     varval(i)  := lv_is_ele_reg;

              i := i+1;
     varname(i) := 'IS_RESPONSE_REQUIRED';
     varval(i)  := lv_isResponseRequired;

              i := i+1;
     varname(i) := 'PAYROLL_WF_NOTIFY_ACTION';
     varval(i)  := lv_Payroll_WF_Notify_Action;

              i := i+1;
     varname(i) := 'IS_PAYMENT_WAIT';
     varval(i)  := lv_isPaymentWait;

              i := i+1;
     varname(i) := 'LEGISLATION_CODE';
     varval(i)  := p_legislation_code;

              i := i+1;
     varname(i) := 'IS_EXCEPTION_GROUP';
     varval(i)  := p_is_exception_group;

              i := i+1;
     varname(i) := 'IS_EXCEPTION_REPORT';
     varval(i)  := p_is_exception_report;

              i := i+1;
     varname(i) := 'PREPAY_PYMENT_MTHD_OVRIDE_NAME';
     varval(i)  := lv_pre_ovr_pymt_name;
              i := i+1;
     varname(i) := 'RETRO_EVENT_GROUP_NAME';
     varval(i)  := lv_event_group_name;
              i := i+1;
     varname(i) := 'OVERRIDING_CHEQUE_DATE';
     varval(i)  := p_overriding_cheque_date;

-- Costing Summary

     varname(i) := 'IS_COSTING_SUMMARY';
     varval(i)  := lv_is_costing_summary;
              i := i+1;
     varname(i) := 'SUMMARY_COSTING_ACCRUALS';
     varval(i)  := p_cost_summary_accruals;
              i := i+1;
     varname(i) := 'SUMMARY_COSTING_ACCRUALS_NAME';
     varval(i)  := lv_cost_summary_accruals;
              i := i+1;
     varname(i) := 'SUMMARY_COSTING_FILE_FORMAT';
     varval(i)  := p_cost_summary_file_out;
              i := i+1;
     varname(i) := 'SUMMARY_COSTING_FILE_FMT_NAME';
     varval(i)  := lv_cost_summary_file_out;
              i := i+1;

-- Costing Detail

     varname(i) := 'IS_COSTING_DETAIL';
     varval(i)  := lv_is_costing_detail;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_CRITERION';
     varval(i)  := p_cost_detail_selection;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_IS_ELEMENT_SET';
     varval(i)  := p_cost_detail_is_ele_set;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ELEMENT_SET';
     varval(i)  := p_cost_detail_ele_set;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ELE_SET_NAME';
     varval(i)  := lv_cost_detail_ele_set;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_IS_ELEMENT_C';
     varval(i)  := p_cost_detail_is_class;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ELEMENT_C';
     varval(i)  := p_cost_detail_class;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ELEMENT_C_NAME';
     varval(i)  := lv_cost_detail_ele_class;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_IS_ELEMENT';
     varval(i)  := p_cost_detail_is_element;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ELEMENT';
     varval(i)  := p_cost_detail_element;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ELEMENT_NAME';
     varval(i)  := lv_cost_detail_ele_name;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ASG_SET';
     varval(i)  := p_cost_detail_asg_set;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ASG_SET_NAME';
     varval(i)  := lv_cost_detail_asg_set;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ACCRUALS';
     varval(i)  := p_cost_detail_accruals;
              i := i+1;
     varname(i) := 'DETAIL_COSTING_ACCRUALS_NAME';
     varval(i)  := lv_cost_detail_accruals;
              i := i+1;


              i := i+1;
     num_varname(i) := 'P_BUSINESS_GROUP_ID';
     num_varvalue(i)  := p_business_group_id;
              i := i+1;
     num_varname(i) := 'BATCH_ID';
     num_varvalue(i)  := p_batch_id;
              i := i+1;
     num_varname(i) := 'START_CHECK_NUMBER';
     num_varvalue(i)  := to_number(p_start_check_number);
              i := i+1;
     num_varname(i) := 'END_CHECK_NUMBER';
     num_varvalue(i)  := to_number(p_end_check_number);
              i := i+1;
     num_varname(i) := 'START_CHECK_NUMBER_3RD_PARTY';
     num_varvalue(i)  := to_number(p_start_check_num_3rd_party);
              i := i+1;
     num_varname(i) := 'END_CHECK_NUMBER_3RD_PARTY';
     num_varvalue(i)  := to_number(p_end_check_num_3rd_party);
              i := i+1;
     num_varname(i) := 'USER_ID';
     num_varvalue(i)  := l_user_id;
              i := i+1;
     num_varname(i) := 'APPLICATION_ID';
     num_varvalue(i)  := l_resp_appl_id;
              i := i+1;
     num_varname(i) := 'RESPONSIBILITY_ID';
     num_varvalue(i)  := l_resp_id;
              i := i+1;
     num_varname(i) := 'ORG_ID';
     num_varvalue(i)  := l_org_id;
              i := i+1;
     num_varname(i) := 'PER_SECURITY_PROFILE_ID';
     num_varvalue(i)  := l_profile_per_sec_id;
              i := i+1;
     num_varname(i) := 'SECURITY_GROUP_ID';
     num_varvalue(i)  := l_profile_sec_grp_id;

for j in varname.first..varname.last loop
hr_utility.trace( 'J = '|| j );
hr_utility.trace( 'varname = '||varname(j));
hr_utility.trace( 'varval = '||varval(j));
end loop;

Wf_Engine.SetItemAttrTextArray(ItemType, ItemKey, varname, varval);
hr_utility.trace( 'Total Var Kount = '||to_char(varname.COUNT));

for p in num_varname.first..num_varname.last loop
hr_utility.trace( 'p = '|| p );
hr_utility.trace( 'num_varname = '||num_varname(p));
hr_utility.trace( 'num_varval = '||num_varvalue(p));
end loop;

Wf_Engine.SetItemAttrNumberArray(ItemType, ItemKey, num_varname, num_varvalue);

hr_utility.trace( 'Total Num Kount = '||to_char(num_varname.COUNT));
exception
     when OTHERS then
          hr_utility.trace('In exception: OTHERS of TextArray');
          raise;
end;

/*
wf_engine.SetItemAttrText ( itemtype  => ItemType,
                                itemkey   => ItemKey,
                                aname     => 'USER_DISPLAY_NAME',
                                avalue    => wf_directory.GetRoleDisplayName(RequestorUsername));

  wf_engine.SetItemOwner ( itemtype  => ItemType,
                                itemkey   => ItemKey,
                                owner     => ProcessOwner);


  wf_engine.SetItemAttrText ( itemtype  => ItemType,
                                itemkey   => ItemKey,
                                aname     => 'MESSAGE_SUBJECT1',
                                avalue    => l_message_subject1);


  wf_engine.SetItemAttrText ( itemtype  => ItemType,
                                itemkey   => ItemKey,
                                aname     => 'MESSAGE_TEXT1',
                                avalue    => l_message_text1);

    hr_utility.trace('B4 SetItemAttrText : l_role_name = ' || l_role_name);
  wf_engine.SetItemAttrText ( itemtype  => ItemType,
                                itemkey   => ItemKey,
                                aname     => 'ROLE_NAME',
                                avalue    => l_role_name);

  wf_engine.SetItemAttrText ( itemtype  => ItemType,
                                itemkey   => ItemKey,
                                aname     => 'APPLNAME',
                                avalue    => 'PAY');

    hr_utility.trace('APPLNAME ');
*/

    hr_utility.trace('b4 starting process');

        wf_engine.StartProcess ( ItemType => ItemType,
                                 ItemKey  => ItemKey );
    hr_utility.trace('a4 starting process');



exception
	when others then
	WF_CORE.Context('PAY_WF_PKG', 'StartProcess',ItemType, RequestorUsername, ProcessOwner, Workflowprocess);

        error;
        RAISE;

end StartProcess;

function get_notifier( ln_payroll_id    in number,
               		ln_gre_id    in number,
               		l_effective_date    in varchar2
                      ) return varchar2 is

 /******************************************************************
  **
  ** Description:
  **
  ** Access Status:
  **
  ******************************************************************/

  l_proc	             	varchar2(80);
  lv_contact_source		VARCHAR2(50);
  ln_current_assignment_id	per_assignments_f.assignment_id%TYPE;
  lv_contact_user_name		VARCHAR2(150);
  ln_contact_person_id		per_people_f.person_id%TYPE;
  ln_employee_person_id		per_people_f.person_id%TYPE;

-- get the payroll contact

  CURSOR c_payroll_contact IS
	select 	prl.prl_information1
	from 	pay_payrolls_f prl
	where 	prl.payroll_id = ln_payroll_id
		and prl.prl_information_category = 'US'
                and fnd_date.canonical_to_date(l_effective_date) between
                    prl.effective_start_date and prl.effective_end_date;


-- get the GRE contact

  CURSOR c_gre_contact IS
        select org.org_information1
        from hr_organization_information org
        where org.org_information_context || '' = 'Contact Information'
          and org.organization_id = ln_gre_id;

begin

    l_proc := gv_package||'.get_notifier';
    lv_contact_source := fnd_profile.value('HR_PAYROLL_CONTACT_SOURCE');

    hr_utility.trace('Profile Value is : '|| lv_contact_source);
    hr_utility.trace('Payroll Id is : '|| ln_payroll_id);
    hr_utility.trace('GRE Id is : '|| ln_gre_id);
    hr_utility.trace('Effective Date is : '|| l_effective_date);



    if lv_contact_source = 'PAYROLL' then
	open c_payroll_contact;
	fetch c_payroll_contact into lv_contact_user_name;
        hr_utility.trace('Contact User is : '|| lv_contact_user_name);
	if c_payroll_contact%NOTFOUND then
          lv_contact_user_name := 'SYSADMIN';
	end if;

	close c_payroll_contact;


    elsif lv_contact_source = 'GRE' then
	open c_gre_contact;
	fetch c_gre_contact into lv_contact_user_name;
	if c_gre_contact%NOTFOUND then
          lv_contact_user_name := 'SYSADMIN';
	end if;

	close c_gre_contact;

    elsif lv_contact_source = 'CUSTOM' then
          lv_contact_user_name := 'SYSADMIN';
    else -- some other source we don't understand yet
          lv_contact_user_name := 'SYSADMIN';
          --lv_contact_user_name := null;
    end if;

    return lv_contact_user_name;

  hr_utility.set_location('Leaving: ' || l_proc, 100);
end get_notifier;


procedure error
is
begin
/*
  dbms_output.put_line('Run time error in test script');
  dbms_output.put_line('Sqlerror: '||sqlerrm);
  dbms_output.put_line('Errname: '||wf_core.error_name);
  dbms_output.put_line('Errmsg: '||substr(wf_core.error_message, 1, 200));
  dbms_output.put_line('Stack1: '||substr(wf_core.error_stack, 1, 200));
  dbms_output.put_line('Stack2: '||substr(wf_core.error_stack, 200, 200));
  dbms_output.put_line('Stack3: '||substr(wf_core.error_stack, 400, 200));
  dbms_output.put_line('Stack4: '||substr(wf_core.error_stack, 600, 200));
  dbms_output.put_line('Stack5: '||substr(wf_core.error_stack, 800, 200));
  dbms_output.put_line('Stack6: '||substr(wf_core.error_stack, 1000, 200));
  dbms_output.put_line('Stack7: '||substr(wf_core.error_stack, 1200, 200));
  dbms_output.put_line('Stack8: '||substr(wf_core.error_stack, 1400, 200));
  dbms_output.put_line('Stack9: '||substr(wf_core.error_stack, 1600, 200));
  dbms_output.put_line('Stack10: '||substr(wf_core.error_stack, 1800, 200));
  */

  hr_utility.trace('Run time error in test script');
  hr_utility.trace('Sqlerror: '||sqlerrm);
  hr_utility.trace('Errname: '||wf_core.error_name);
  hr_utility.trace('Errmsg: '||substr(wf_core.error_message, 1, 200));
  hr_utility.trace('Stack1: '||substr(wf_core.error_stack, 1, 200));
  hr_utility.trace('Stack2: '||substr(wf_core.error_stack, 200, 200));
  hr_utility.trace('Stack3: '||substr(wf_core.error_stack, 400, 200));
  hr_utility.trace('Stack4: '||substr(wf_core.error_stack, 600, 200));
  hr_utility.trace('Stack5: '||substr(wf_core.error_stack, 800, 200));
  hr_utility.trace('Stack6: '||substr(wf_core.error_stack, 1000, 200));
  hr_utility.trace('Stack7: '||substr(wf_core.error_stack, 1200, 200));
  hr_utility.trace('Stack8: '||substr(wf_core.error_stack, 1400, 200));
  hr_utility.trace('Stack9: '||substr(wf_core.error_stack, 1600, 200));
  hr_utility.trace('Stack10: '||substr(wf_core.error_stack, 1800, 200));

end error;


end PAY_WF_PKG;

/
