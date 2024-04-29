--------------------------------------------------------
--  DDL for Package Body PAY_CA_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_WF_PKG" AS
/* $Header: paycawfpkg.pkb 120.0 2005/05/29 10:48 appldev noship $*/
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

    Package Body Name : pay_ca_wf_pkg
    Package File Name : paycawfpkg.pkb
    Description : This package declares functions which initiate the
                  Canadian Payroll Workflow

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    27-APR-2004 ssouresr   115.0             Created
    12-JUL-2004 ssouresr   115.2             Retrieved User from correct
                                             Payroll segment in function
                                             get_notifier
    21-JUL-2004 ssouresr   115.3             Changed business group and
                                             batch id attributes to varchar2
                                             Also made changes so that the
                                             assignment set used by the RetroPay
                                             by Element process is the same as
                                             for Retro-Notification if one exists
  *******************************************************************/

 /******************************************************************
  ** private package global declarations
  ******************************************************************/


procedure payroll_wf_process(errbuf     OUT nocopy     varchar2,
                             retcode    OUT nocopy     number,
                             p_wf_item_type            varchar2,
                             p_business_group_id       number ,
                             p_batch_id                number ,
                             p_payroll_id              varchar2,
                             p_consolidation_set_id    varchar2,
                             p_date_earned             varchar2,
                             p_date_paid               varchar2,
                             p_retro_event_group       varchar2,
                             p_retro_assignment_set    varchar2,
                             p_retropay_assignment_set varchar2,
                             p_retropay_element_set    varchar2,
                             p_retro_start_date        varchar2,
                             p_payroll_element_set     varchar2,
                             p_payroll_assignment_set  varchar2,
                             p_payroll_run_type        varchar2,
                             p_gre_or_tax_group        varchar2,
                             p_is_gre                  varchar2,
                             p_gre                     varchar2,
                             p_is_tax_group            varchar2,
                             p_tax_group               varchar2,
                             p_gross_to_net_period     varchar2,
                             p_payroll_process         varchar2,
                             p_session_date            varchar2,
                             p_organization            varchar2,
                             p_location                varchar2,
                             p_quebec                  varchar2,
                             p_qhsf_account_number     varchar2,
                             p_qhsf_override_table     varchar2,
                             p_sdr_federal             varchar2,
                             p_sdr_province            varchar2,
                             p_sdr_reporting_dimension varchar2,
                             p_exp_legislation_code    varchar2,
                             p_exp_report_or_group     varchar2,
                             p_exp_is_group            varchar2,
                             p_exp_group_name          varchar2,
                             p_exp_is_report           varchar2,
                             p_exp_report_name         varchar2,
                             p_exp_variance_type       varchar2,
                             p_exp_variance_value      varchar2,
                             p_payment_method_override varchar2,
                             p_ele_selection_criterion varchar2,
                             p_ele_is_element_set      varchar2,
                             p_ele_element_set         varchar2,
                             p_ele_is_element_class    varchar2,
                             p_ele_element_class       varchar2,
                             p_ele_is_element_name     varchar2,
                             p_ele_element_name        varchar2,
                             p_ele_employee            varchar2,
                             p_deduction_class         varchar2,
                             p_deduction_name          varchar2,
                             p_deduction_sort_one      varchar2,
                             p_deduction_sort_two      varchar2,
                             p_deduction_sort_three    varchar2,
                             p_reg_suppress_zero       varchar2,
                             p_reg_full_report_ver     varchar2,
                             p_reg_reporting_dim       varchar2,
                             p_reg_sort_one            varchar2,
                             p_reg_sort_two            varchar2,
                             p_reg_sort_three          varchar2,
                             p_reg_employee_page_break varchar2,
                             p_reg_req_num             varchar2,
                             p_dd_payment_type         varchar2,
                             p_dd_payment_method       varchar2,
                             p_dd_override_date        varchar2,
                             p_dd_financial_inst       varchar2,
                             p_dd_cpa_code             varchar2,
                             p_dd_file_number          varchar2,
                             p_cheque_payment_type     varchar2,
                             p_cheque_payment_method   varchar2,
                             p_cheque_sort_sequence    varchar2,
                             p_cheque_style            varchar2,
                             p_start_cheque_number     varchar2,
                             p_end_cheque_number       varchar2,
                             p_da_data_type            varchar2,
                             p_payment_rep_payment_type   varchar2,
                             p_payment_rep_payment_method varchar2,
                             p_roe_assignment_set      varchar2,
                             p_roe_worksheet_person    varchar2,
                             p_roe_mag_media_person    varchar2,
                             p_roe_mag_roe_type        varchar2,
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
                             p_cost_detail_accruals    varchar2
                      ) is

  l_workflowprocess   varchar2(100);
  l_ProcessDesc       varchar2(100);
  l_RequestorUsername varchar2(100) := 'SYSADMIN';
  l_ProcessOwner      varchar2(100);
  l_item_type         varchar2(100);
  l_item_key          varchar2(100);
  lv_runnable_process varchar2(1);


begin
  --hr_utility.trace_on(null,'PYWF');

  gv_package := 'pay_ca_wf_pkg';

  select to_char(sysdate,'DDHH24MISS') into l_item_key from  dual;

  -- initialise variable - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
  retcode := 0;


  l_workflowprocess  := 'PAYCAPROCESSWF';
  l_item_type        := p_wf_item_type;    -- PAYCAPWF

  begin
       select runnable_flag
       into lv_runnable_process
       from wf_activities
       where item_type = p_wf_item_type
       and type        = 'PROCESS'
       and name        = l_workflowprocess
       and end_date is null;

       exception when no_data_found then
       hr_utility.trace('Exception: No Data Found in payroll_wf_process');
       null;

  end;

    hr_utility.trace('Item Type : '|| l_item_type);
    hr_utility.trace('Item Key : '|| l_item_key);
    hr_utility.trace('Workflow Process : '|| l_workflowprocess);

  if lv_runnable_process = 'Y' then

         StartProcess(p_business_group_id,
                      p_batch_id,
                      p_payroll_id,
                      p_consolidation_set_id,
                      p_date_earned,
                      p_date_paid,
                      p_retro_event_group,
                      p_retro_assignment_set,
                      p_retropay_assignment_set,
                      p_retropay_element_set,
                      p_retro_start_date,
                      p_payroll_element_set,
                      p_payroll_assignment_set,
                      p_payroll_run_type,
                      p_gre_or_tax_group,
                      p_is_gre,
                      p_gre,
                      p_is_tax_group,
                      p_tax_group,
                      p_gross_to_net_period,
                      p_payroll_process,
                      p_session_date,
                      p_organization,
                      p_location,
                      p_quebec,
                      p_qhsf_account_number,
                      p_qhsf_override_table,
                      p_sdr_federal,
                      p_sdr_province,
                      p_sdr_reporting_dimension,
                      p_exp_legislation_code,
                      p_exp_report_or_group,
                      p_exp_is_group,
                      p_exp_group_name,
                      p_exp_is_report,
                      p_exp_report_name,
                      p_exp_variance_type,
                      p_exp_variance_value,
                      p_payment_method_override,
                      p_ele_selection_criterion,
                      p_ele_is_element_set,
                      p_ele_element_set,
                      p_ele_is_element_class,
                      p_ele_element_class,
                      p_ele_is_element_name,
                      p_ele_element_name,
                      p_ele_employee,
                      p_deduction_class,
                      p_deduction_name,
                      p_deduction_sort_one,
                      p_deduction_sort_two,
                      p_deduction_sort_three,
                      p_reg_suppress_zero,
                      p_reg_full_report_ver,
                      p_reg_reporting_dim,
                      p_reg_sort_one,
                      p_reg_sort_two,
                      p_reg_sort_three,
                      p_reg_employee_page_break,
                      p_reg_req_num,
                      p_dd_payment_type,
                      p_dd_payment_method,
                      p_dd_override_date,
                      p_dd_financial_inst,
                      p_dd_cpa_code,
                      p_dd_file_number,
                      p_cheque_payment_type,
                      p_cheque_payment_method,
                      p_cheque_sort_sequence,
                      p_cheque_style,
                      p_start_cheque_number,
                      p_end_cheque_number,
                      p_da_data_type,
                      p_payment_rep_payment_type,
                      p_payment_rep_payment_method,
                      p_roe_assignment_set,
                      p_roe_worksheet_person,
                      p_roe_mag_media_person,
                      p_roe_mag_roe_type,
                      p_cost_summary_accruals,
                      p_cost_summary_file_out,
                      p_cost_detail_selection,
                      p_cost_detail_is_ele_set,
                      p_cost_detail_ele_set,
                      p_cost_detail_is_class,
                      p_cost_detail_class,
                      p_cost_detail_is_element,
                      p_cost_detail_element,
                      p_cost_detail_asg_set,
                      p_cost_detail_accruals,
                      l_ProcessDesc,
                      l_RequestorUsername,
                      l_ProcessOwner,
                      l_workflowprocess,
                      l_item_type,
                      l_item_key
                      );

end if;

exception

   when hr_utility.hr_error then
     --
     -- Set up error message and error return code.
     --
     hr_utility.trace('in the exception');

     errbuf  := hr_utility.get_message;
     retcode := 2;

when others then

     -- Set up error message and return code.
     errbuf  := sqlerrm;
     retcode := 2;

end payroll_wf_process;

-- Start Workflow Process will Create a Process and Set the Attributes
-- for the Workflow Process.


procedure StartProcess	(
                      p_business_group_id       number,
                      p_batch_id                number,
                      p_payroll_id              varchar2,
                      p_consolidation_set_id    varchar2,
                      p_date_earned             varchar2,
                      p_date_paid               varchar2,
                      p_retro_event_group       varchar2,
                      p_retro_assignment_set    varchar2,
                      p_retropay_assignment_set varchar2,
                      p_retropay_element_set    varchar2,
                      p_retro_start_date        varchar2,
                      p_payroll_element_set     varchar2,
                      p_payroll_assignment_set  varchar2,
                      p_payroll_run_type        varchar2,
                      p_gre_or_tax_group        varchar2,
                      p_is_gre                  varchar2,
                      p_gre                     varchar2,
                      p_is_tax_group            varchar2,
                      p_tax_group               varchar2,
                      p_gross_to_net_period     varchar2,
                      p_payroll_process         varchar2,
                      p_session_date            varchar2,
                      p_organization            varchar2,
                      p_location                varchar2,
                      p_quebec                  varchar2,
                      p_qhsf_account_number     varchar2,
                      p_qhsf_override_table     varchar2,
                      p_sdr_federal             varchar2,
                      p_sdr_province            varchar2,
                      p_sdr_reporting_dimension varchar2,
                      p_exp_legislation_code    varchar2,
                      p_exp_report_or_group     varchar2,
                      p_exp_is_group            varchar2,
                      p_exp_group_name          varchar2,
                      p_exp_is_report           varchar2,
                      p_exp_report_name         varchar2,
                      p_exp_variance_type       varchar2,
                      p_exp_variance_value      varchar2,
                      p_payment_method_override varchar2,
                      p_ele_selection_criterion varchar2,
                      p_ele_is_element_set      varchar2,
                      p_ele_element_set         varchar2,
                      p_ele_is_element_class    varchar2,
                      p_ele_element_class       varchar2,
                      p_ele_is_element_name     varchar2,
                      p_ele_element_name        varchar2,
                      p_ele_employee            varchar2,
                      p_deduction_class         varchar2,
                      p_deduction_name          varchar2,
                      p_deduction_sort_one      varchar2,
                      p_deduction_sort_two      varchar2,
                      p_deduction_sort_three    varchar2,
                      p_reg_suppress_zero       varchar2,
                      p_reg_full_report_ver     varchar2,
                      p_reg_reporting_dim       varchar2,
                      p_reg_sort_one            varchar2,
                      p_reg_sort_two            varchar2,
                      p_reg_sort_three          varchar2,
                      p_reg_employee_page_break varchar2,
                      p_reg_req_num             varchar2,
                      p_dd_payment_type         varchar2,
                      p_dd_payment_method       varchar2,
                      p_dd_override_date        varchar2,
                      p_dd_financial_inst       varchar2,
                      p_dd_cpa_code             varchar2,
                      p_dd_file_number          varchar2,
                      p_cheque_payment_type     varchar2,
                      p_cheque_payment_method   varchar2,
                      p_cheque_sort_sequence    varchar2,
                      p_cheque_style            varchar2,
                      p_start_cheque_number     varchar2,
                      p_end_cheque_number       varchar2,
                      p_da_data_type            varchar2,
                      p_payment_rep_payment_type   varchar2,
                      p_payment_rep_payment_method varchar2,
                      p_roe_assignment_set      varchar2,
                      p_roe_worksheet_person    varchar2,
                      p_roe_mag_media_person    varchar2,
                      p_roe_mag_roe_type        varchar2,
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
                      ProcessDesc in            varchar2,
                      RequestorUsername in      varchar2,
                      ProcessOwner in           varchar2,
                      Workflowprocess in        varchar2 default null,
                      item_type in              varchar2 default null,
                      item_key in               varchar2
                      ) is

ItemType	        varchar2(30) := item_type;
ItemKey    	        varchar2(30) := item_key;
ItemUserKey	        varchar2(80) := ProcessDesc;
l_business_group_id     number(30)   := p_business_group_id;
l_payroll_id	        number(16)   := to_number(p_payroll_id);
l_consolidation_set_id  number(16)   := to_number(p_consolidation_set_id);


lv_prc_list                varchar2(3200);
lv_process_list_subject    varchar2(240);
lv_process_list_text 	   varchar2(3200);
lv_process_list_html_1     varchar2(3200);
lv_process_list_html_2     varchar2(3200);

lv_contact_user_name       varchar2(80);
lv_orig_system     	   varchar2(40);
lv_orig_system_id  	   varchar2(40);
lv_role_name       	   varchar2(50);
lv_role_display_name       varchar2(50);

lv_payroll_name       	   varchar2(80);
lv_consolidation_set_name  varchar2(80);
lv_gre_name       	   varchar2(80);
lv_tax_group      	   varchar2(80);
lv_organization   	   varchar2(80);
lv_location       	   varchar2(80);
lv_date_time               varchar2(80);

lv_is_batch                varchar2(1) := 'N';
lv_is_retropay             varchar2(1) := 'N';
lv_is_retro_notification   varchar2(1) := 'N';
lv_is_gtn                  varchar2(1);
lv_is_sdr                  varchar2(1);
lv_is_payroll_register     varchar2(1);
lv_is_element_register     varchar2(1);
lv_is_deductions           varchar2(1);
lv_is_direct_deposit       varchar2(1);
lv_is_chequewriter         varchar2(1);
lv_is_deposit_advice       varchar2(1);
lv_is_roe                  varchar2(1);
lv_is_roe_mag              varchar2(1);
lv_is_costing_summary      varchar2(1);
lv_is_consolidation_set    varchar2(1);
lv_is_exception            varchar2(1);


lv_workflow_mode           varchar2(1);
lv_batch_name              varchar2(80);
lv_retro_period            varchar2(80);
lv_event_group_name        varchar2(80);
lv_retropay_asg_set        varchar2(80);
lv_retropay_element_set    varchar2(80);
lv_payroll_element_set     varchar2(80);
lv_payroll_assignment_set  varchar2(80);
lv_payroll_run_type        varchar2(80);
lv_gtn_period              varchar2(80);
lv_payroll_process         varchar2(80);
lv_account_number          varchar2(80);
lv_federal                 varchar2(80);
lv_province                varchar2(80);
lv_reporting_dimension     varchar2(80);
lv_exp_group_name          varchar2(80);
lv_exp_report_name         varchar2(80);
lv_exp_vartype_name        varchar2(80);
lv_exp_finder_pqp          varchar2(80);
lv_prepay_payment_method   varchar2(80);
lv_ele_element_set         varchar2(80);
lv_ele_element_class       varchar2(80);
lv_ele_element_name        varchar2(80);
lv_ele_employee            varchar2(80);
lv_ded_consolidation_dummy varchar2(80);
lv_deduction_class         varchar2(80);
lv_deduction_name          varchar2(80);
lv_reg_suppress_zero       varchar2(80);
lv_reg_full_report_ver     varchar2(80);
lv_reg_reporting_dimension varchar2(80);
lv_reg_sort_one            varchar2(80);
lv_reg_sort_two            varchar2(80);
lv_reg_sort_three          varchar2(80);
lv_reg_employee_page_break varchar2(80);
lv_cheque_payment_type     varchar2(80);
lv_cheque_payment_method   varchar2(80);
lv_cheque_sort_sequence    varchar2(80);
lv_cheque_style            varchar2(80);
lv_da_data_type            varchar2(80);
lv_roe_asg_set             varchar2(80);
lv_roe_worksheet_person    varchar2(80);
lv_roe_mag_media_person    varchar2(80);
lv_cost_summary_accruals   varchar2(80);
lv_cost_summary_file_out   varchar2(80);
lv_cost_detail_ele_set     varchar2(80);
lv_cost_detail_ele_class   varchar2(80);
lv_cost_detail_ele_name    varchar2(80);
lv_cost_detail_asg_set     varchar2(80);
lv_cost_detail_accruals    varchar2(80);

l_user_id                  number;
l_resp_id                  number;
l_resp_appl_id 	           number;
l_org_id                   number;
l_per_sec_id               number;
l_sec_grp_id               number;

varname                    wf_engine.NameTabTyp;
varval                     wf_engine.TextTabTyp;
num_varname                wf_engine.NameTabTyp;
num_varvalue               wf_engine.NumTabTyp;

TYPE char80_table IS TABLE OF VARCHAR2(80)
INDEX BY BINARY_INTEGER;

lv_conc_prog_name          char80_table;
i                          number;
j                          number;
k                          number;

l_proc	             	   varchar2(80) := gv_package||'.StartProcess';

cursor cur_workflow_mode is
select nvl(substr(parameter_value,1,1), 'W')
from pay_action_parameters
where parameter_name = 'PAYROLL_CA_WF_NOTIFY_ACTION';

cursor cur_retro_period is
select period_name
from per_time_periods
where payroll_id = l_payroll_id
and   end_date   = fnd_date.canonical_to_date(p_date_earned);

cursor cur_event_group is
select event_group_name
from pay_event_groups
where business_group_id = p_business_group_id
and event_group_id =
      to_number(substr(p_retro_event_group,(length('EVT_GRP_ID=')+1)));

cursor cur_retropay_asg_set is
select assignment_set_name
from hr_assignment_sets
where assignment_set_id = to_number(p_retropay_assignment_set)
and   business_group_id = p_business_group_id;

cursor cur_retropay_element_set is
select element_set_name
from pay_element_sets
where element_set_id = to_number(p_retropay_element_set)
and   business_group_id = p_business_group_id;

cursor cur_payroll_element_set is
select element_set_name
from pay_element_sets
where element_set_id = to_number(p_payroll_element_set)
and   business_group_id = p_business_group_id;

cursor cur_payroll_asg_set is
select assignment_set_name
from hr_assignment_sets
where assignment_set_id = to_number(p_payroll_assignment_set)
and   payroll_id        = l_payroll_id;

cursor cur_payroll_run_type is
select t.run_type_name
from pay_run_types_f_tl t,
     pay_run_types_f    r
where r.run_type_id  = to_number(p_payroll_run_type)
and   r.run_type_id  = t.run_type_id
and   t.language     = userenv('LANG')
and  fnd_date.canonical_to_date(p_date_earned)
            between r.effective_start_date and r.effective_end_date;

cursor cur_sdr_reporting_dimension is
select meaning
from hr_lookups
where lookup_code    = p_sdr_reporting_dimension
and   lookup_type    = 'PAY_CA_REPORT_DIMENSION'
and   application_id = 800;

cursor cur_exp_group_name is
select exception_group_name
from pqp_exception_report_groups
where exception_group_id  = to_number(p_exp_group_name);

cursor cur_exp_report_name is
select exception_report_name
from pqp_exception_reports
where exception_report_id  = to_number(p_exp_report_name);

cursor cur_exp_variance_type is
select meaning
from fnd_common_lookups
where lookup_type  = 'PQP_VARIANCE_TYPE'
and   lookup_code  = p_exp_variance_type;

cursor cur_prepay_payment_method is
select org_payment_method_name
from pay_org_payment_methods_f_tl
where org_payment_method_id  = to_number(p_payment_method_override)
and   language = userenv('LANG');

cursor cur_ele_element_set is
select element_set_name
from pay_element_sets
where element_set_id   = to_number(p_ele_element_set)
and   element_set_type = 'C';

cursor cur_ele_element_class is
select classification_name
from pay_element_classifications
where classification_id   = to_number(p_ele_element_class);

cursor cur_ele_element_name is
select element_name
from pay_element_types_f_tl
where element_type_id   = to_number(p_ele_element_name)
and   language = userenv('LANG');

cursor cur_ele_employee is
select full_name||'(Person ID='||person_id||')'
from per_people_f
where person_id   = to_number(p_ele_employee)
and  fnd_date.canonical_to_date(p_date_earned)
            between effective_start_date and effective_end_date;

cursor cur_ded_class is
select classification_name
from pay_element_classifications
where classification_id   = to_number(p_deduction_class);

cursor cur_ded_name is
select element_name
from pay_element_types_f
where element_type_id   = to_number(p_deduction_name)
and  fnd_date.canonical_to_date(p_date_earned)
            between effective_start_date and effective_end_date;

cursor cur_reg_dimension is
select flv.meaning
from fnd_lookup_values flv, fnd_lookup_types flt
where flv.lookup_code  = p_reg_reporting_dim
and   flt.lookup_type  = 'CA_DIMENSION'
and   flt.application_id = 800
and   flt.lookup_type  = flv.lookup_type;

cursor cur_cheque_payment_type is
select payment_type_name
from pay_payment_types
where payment_type_id   = to_number(p_cheque_payment_type)
and   territory_code    = 'CA'
and   category          = 'CH';

cursor cur_cheque_payment_method is
select org_payment_method_name
from pay_org_payment_methods_f_tl
where org_payment_method_id   = to_number(p_cheque_payment_method);

cursor cur_cheque_sort_seq is
select meaning
from hr_lookups
where lookup_code  = p_cheque_sort_sequence
and   lookup_type  = 'CHEQUE_PROCEDURE'
and   enabled_flag = 'Y';

cursor cur_cheque_style is
select meaning
from hr_lookups
where lookup_code  = p_cheque_style
and   lookup_type  = 'CA_CHEQUE_DEPADV'
and   enabled_flag = 'Y';

cursor cur_deposit_advice_data_type is
select meaning
from hr_lookups
where lookup_code  = p_da_data_type
and   lookup_type  = 'DAR_REPORT'
and   enabled_flag = 'Y';

cursor cur_roe_asg_set is
select assignment_set_name
from hr_assignment_sets
where assignment_set_id  =
to_number(substr(p_roe_assignment_set,(length('ASSIGNMENT_SET_ID=')+1)));

cursor cur_roe_worksheet_person is
select full_name
from per_all_people_f
where person_id  = to_number(p_roe_worksheet_person)
and  fnd_date.canonical_to_date(p_date_earned)
            between effective_start_date and effective_end_date;

cursor cur_roe_mag_media_person is
select full_name
from per_all_people_f
where person_id  =
to_number(substr(p_roe_mag_media_person,(length('PERSON_ID=')+1)))
and  fnd_date.canonical_to_date(p_date_earned)
            between effective_start_date and effective_end_date;

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

  hr_utility.set_location('Starting: ' || l_proc, 100);

  lv_conc_prog_name(1)  := 'BEE Batch Process (Transfer)';
  lv_conc_prog_name(2)  := 'Retro-Notifications Report';
  lv_conc_prog_name(3)  := 'RetroPay By Element';
  lv_conc_prog_name(4)  := 'Process Payroll Run';
  lv_conc_prog_name(5)  := 'Gross to Net Summary';
  lv_conc_prog_name(6)  := 'Payroll Message Report';
  lv_conc_prog_name(7)  := 'Employee Assignments Not Paid';
  lv_conc_prog_name(8)  := 'Payroll Exception Report';
  lv_conc_prog_name(9)  := 'Statutory Deductions Report';
  lv_conc_prog_name(10) := 'Quebec Health Services Fund';
  lv_conc_prog_name(11) := 'Pre Payments';
  lv_conc_prog_name(12) := 'Payroll Register Report';
  lv_conc_prog_name(13) := 'Element Register Report';
  lv_conc_prog_name(14) := 'Deductions Report';
  lv_conc_prog_name(15) := 'Direct Deposit';
  lv_conc_prog_name(16) := 'Canadian Payroll Archiver';
  lv_conc_prog_name(17) := 'Canadian Chequewriter';
  lv_conc_prog_name(18) := 'Canadian Deposit Advice';
  lv_conc_prog_name(19) := 'Payment Report';
  lv_conc_prog_name(20) := 'Record of Employment by Assignment Set';
  lv_conc_prog_name(21) := 'ROE Worksheet';
  lv_conc_prog_name(22) := 'ROE-Magnetic Media';
  lv_conc_prog_name(23) := 'Costing';
  lv_conc_prog_name(24) := 'Costing Detail Report';
  lv_conc_prog_name(25) := 'Costing Summary Report';

  hr_utility.trace('In StartProcess Item Type is : '|| ItemType);
  hr_utility.trace('In StartProcess Item Key is : '|| ItemKey);
  hr_utility.trace('Workflow process name is : '|| Workflowprocess);

  select to_char(sysdate,'DD-MON-YYYY') ||' '|| to_char(sysdate,'HH24:MI:SS')
  into lv_date_time from  dual;


  hr_utility.trace('before create_process');

  wf_engine.createProcess(ItemType => ItemType,
                          ItemKey  => ItemKey,
                          process  => Workflowprocess);

  wf_engine.SetItemUserKey(ItemType => ItemType,
                           ItemKey  => ItemKey,
                           UserKey  => ItemUserKey);

  hr_utility.trace('In StartProcess before HR_SIGNON.Initialize_HR_Security');

  HR_SIGNON.Initialize_HR_Security;

  hr_utility.trace('After HR_SIGNON.Initialize_HR_Security');

  l_user_id      := FND_GLOBAL.USER_ID;
  l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
  l_resp_id      := FND_GLOBAL.RESP_ID;
  l_org_id       := FND_GLOBAL.ORG_ID;
  l_per_sec_id   := FND_GLOBAL.PER_SECURITY_PROFILE_ID;
  l_sec_grp_id   := FND_GLOBAL.SECURITY_GROUP_ID;

  hr_utility.trace('l_user_id = ' || l_user_id);
  hr_utility.trace('l_resp_appl_id = ' || l_resp_appl_id);
  hr_utility.trace('l_resp_id = ' || l_resp_id);
  hr_utility.trace('l_org_id = ' || l_org_id);
  hr_utility.trace('l_per_sec_id = ' || l_per_sec_id);
  hr_utility.trace('l_sec_grp_id = ' || l_sec_grp_id);
  hr_utility.trace('business group = ' || to_char(p_business_group_id));

  lv_gre_name  := '';
  lv_tax_group := '';

  open cur_workflow_mode;
  fetch cur_workflow_mode into lv_workflow_mode;

  if cur_workflow_mode%notfound then
      lv_workflow_mode := 'W';
  end if;

  close cur_workflow_mode;

  hr_utility.trace('Workflow Mode = ' || lv_workflow_mode);

  open cur_retro_period;
  fetch cur_retro_period into lv_retro_period;
  close cur_retro_period;

  hr_utility.trace('Retro Period = ' || lv_retro_period);

  open cur_event_group;
  fetch cur_event_group into lv_event_group_name;
  close cur_event_group;

  hr_utility.trace('Event Group = ' || lv_event_group_name);

  open cur_retropay_asg_set;
  fetch cur_retropay_asg_set into lv_retropay_asg_set;
  close cur_retropay_asg_set;

  hr_utility.trace('RetroPay Assignment Set = ' || lv_retropay_asg_set);

  open cur_retropay_element_set;
  fetch cur_retropay_element_set into lv_retropay_element_set;
  close cur_retropay_element_set;

  hr_utility.trace('RetroPay Element Set = ' || lv_retropay_element_set);

  open cur_payroll_element_set;
  fetch cur_payroll_element_set into lv_payroll_element_set;
  close cur_payroll_element_set;

  hr_utility.trace('Payroll Run Element Set = ' || lv_payroll_element_set);

  open cur_payroll_asg_set;
  fetch cur_payroll_asg_set into lv_payroll_assignment_set;
  close cur_payroll_asg_set;

  hr_utility.trace('Payroll Run Assignment Set = ' || lv_payroll_assignment_set);

  open cur_payroll_run_type;
  fetch cur_payroll_run_type into lv_payroll_run_type;
  close cur_payroll_run_type;

  hr_utility.trace('Payroll Run Type = ' || lv_payroll_run_type);

  open cur_sdr_reporting_dimension;
  fetch cur_sdr_reporting_dimension into lv_reporting_dimension;
  close cur_sdr_reporting_dimension;

  hr_utility.trace('SDR Reporting Dimension = ' || lv_reporting_dimension);

  open cur_exp_group_name;
  fetch cur_exp_group_name into lv_exp_group_name;
  close cur_exp_group_name;

  hr_utility.trace('Exception Group Name = ' || lv_exp_group_name);

  open cur_exp_report_name;
  fetch cur_exp_report_name into lv_exp_report_name;
  close cur_exp_report_name;

  hr_utility.trace('Exception Report Name = ' || lv_exp_report_name);

  open cur_exp_variance_type;
  fetch cur_exp_variance_type into lv_exp_vartype_name;
  close cur_exp_variance_type;

  hr_utility.trace('Exception Variance Type = ' || lv_exp_vartype_name);

  open cur_prepay_payment_method;
  fetch cur_prepay_payment_method into lv_prepay_payment_method;
  close cur_prepay_payment_method;

  hr_utility.trace('PrePayment Payment Method = ' || lv_prepay_payment_method);

  open cur_ele_element_set;
  fetch cur_ele_element_set into lv_ele_element_set;
  close cur_ele_element_set;

  hr_utility.trace('Element Register Element Set = ' || lv_ele_element_set);

  open cur_ele_element_class;
  fetch cur_ele_element_class into lv_ele_element_class;
  close cur_ele_element_class;

  hr_utility.trace('Element Register Element Classification = ' || lv_ele_element_class);

  open cur_ele_element_name;
  fetch cur_ele_element_name into lv_ele_element_name;
  close cur_ele_element_name;

  hr_utility.trace('Element Register Element Name = ' || lv_ele_element_name);

  open cur_ele_employee;
  fetch cur_ele_employee into lv_ele_employee;
  close cur_ele_employee;

  hr_utility.trace('Element Register Employee = ' || lv_ele_employee);

  open cur_ded_class;
  fetch cur_ded_class into lv_deduction_class;
  close cur_ded_class;

  hr_utility.trace('Deduction Report Dedn Classification = ' || lv_deduction_class);

  open cur_ded_name;
  fetch cur_ded_name into lv_deduction_name;
  close cur_ded_name;

  hr_utility.trace('Deduction Report Dedn Name = ' || lv_deduction_name);

  open cur_reg_dimension;
  fetch cur_reg_dimension into lv_reg_reporting_dimension;
  close cur_reg_dimension;

  hr_utility.trace('Payroll Register Reporting Dimension = ' || lv_reg_reporting_dimension);

  open cur_cheque_payment_type;
  fetch cur_cheque_payment_type into lv_cheque_payment_type;
  close cur_cheque_payment_type;

  hr_utility.trace('Chequewriter Payment Type = ' || lv_cheque_payment_type);

  open cur_cheque_payment_method;
  fetch cur_cheque_payment_method into lv_cheque_payment_method;
  close cur_cheque_payment_method;

  hr_utility.trace('Chequewriter Payment Method = ' || lv_cheque_payment_method);

  open cur_cheque_sort_seq;
  fetch cur_cheque_sort_seq into lv_cheque_sort_sequence;
  close cur_cheque_sort_seq;

  hr_utility.trace('Chequewriter Sort Seq = ' || lv_cheque_sort_sequence);

  open cur_cheque_style;
  fetch cur_cheque_style into lv_cheque_style;
  close cur_cheque_style;

  hr_utility.trace('Chequewriter Style = ' || lv_cheque_style);

  open cur_deposit_advice_data_type;
  fetch cur_deposit_advice_data_type into lv_da_data_type;
  close cur_deposit_advice_data_type;

  hr_utility.trace('Deposit Advice Data Type = ' || lv_da_data_type);

  open cur_roe_asg_set;
  fetch cur_roe_asg_set into lv_roe_asg_set;
  close cur_roe_asg_set;

  hr_utility.trace('ROE Assignment Set = ' || lv_roe_asg_set);

  open cur_roe_worksheet_person;
  fetch cur_roe_worksheet_person into lv_roe_worksheet_person;
  close cur_roe_worksheet_person;

  hr_utility.trace('ROE Worksheet Person = ' || lv_roe_worksheet_person);

  open cur_roe_mag_media_person;
  fetch cur_roe_mag_media_person into lv_roe_mag_media_person;
  close cur_roe_mag_media_person;

  hr_utility.trace('ROE Magnetic Media Person = ' || lv_roe_mag_media_person);

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

  begin
     select period_name
     into lv_gtn_period
     from per_time_periods
     where payroll_id = to_number(p_payroll_id)
     and   time_period_id = to_number(p_gross_to_net_period);

     hr_utility.trace('lv_gtn_period = ' || lv_gtn_period);

     exception     when no_data_found then
     hr_utility.trace('lv_gtn_period exception: no_data_found ');
     null;

  end;

  begin
     select fnd_date.date_to_chardate(effective_date)||'('||to_char(request_id)||')'
     into lv_payroll_process
     from pay_payroll_actions
     where payroll_action_id = to_number(p_payroll_process);

     hr_utility.trace('lv_payroll_process = ' || lv_payroll_process);

     exception     when no_data_found then
     hr_utility.trace('lv_payroll_process exception: no_data_found ');
     null;

  end;

  begin
     select to_char(sysdate, 'HHSSSS')
     into lv_exp_finder_pqp
     from dual;

     hr_utility.trace('lv_exp_finder_pqp = ' || lv_exp_finder_pqp);

     exception     when no_data_found then
     hr_utility.trace('lv_exp_finder_pqp exception: no_data_found ');
     null;

  end;

-- Payroll Name
     begin
      select payroll_name
      into lv_payroll_name
      from pay_all_payrolls_f
      where payroll_id = l_payroll_id
      and  fnd_date.canonical_to_date(p_date_earned)
             between effective_start_date and effective_end_date;

      hr_utility.trace('lv_payroll_name = ' || lv_payroll_name);

      exception  when no_data_found then
      hr_utility.trace('lv_payroll_name exception: no_data_found ');
      null;

    end;

-- Consolidation Set Name
    begin
      select consolidation_set_name
      into lv_consolidation_set_name
      from pay_consolidation_sets
      where consolidation_set_id = l_consolidation_set_id;

      hr_utility.trace('lv_consolidation_set_name = ' || lv_consolidation_set_name);

      exception  when no_data_found then
      hr_utility.trace('lv_consolidation_set_name exception: no_data_found ');
      null;

    end;

-- Organization
    begin
      select name
      into lv_organization
      from per_organization_units
      where organization_id  = to_number(p_organization)
      and  business_group_id = p_business_group_id
      and fnd_date.canonical_to_date(p_date_earned) between
             date_from and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'));


      hr_utility.trace('lv_organization = ' || lv_organization);

      exception  when no_data_found then
      hr_utility.trace('lv_organization exception: no_data_found ');
      null;

    end;

-- Location
    begin
      select location_code||' '||description
      into lv_location
      from hr_locations
      where location_id = to_number(p_location);

      hr_utility.trace('lv_location = ' || lv_location);

      exception  when no_data_found then
      hr_utility.trace('lv_location exception: no_data_found ');
      null;

    end;

-- GRE Name
    if p_gre_or_tax_group = 'GRE' then
        begin
            select name
            into lv_gre_name
            from hr_ca_tax_units_v
            where tax_unit_id = to_number(p_gre)
            and business_group_id = p_business_group_id
            and fnd_date.canonical_to_date(p_date_earned) between
                    date_from and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'));

            hr_utility.trace('lv_gre_name = ' || lv_gre_name);

            exception when no_data_found then
            hr_utility.trace('lv_gre_name exception: no_data_found ');
            null;

          end;
    end if;

-- Tax Group Name
    if p_gre_or_tax_group = 'Tax Group' then
        begin
            select hou.name
            into lv_tax_group
            from hr_all_organization_units hou,
                 hr_organization_information hoi
            where hou.organization_id = hoi.organization_id
            and hoi.org_information_context = 'CLASS'
            and hoi.org_information1 = 'CA_TAX_GROUP'
            and hou.business_group_id = p_business_group_id
            and hou.organization_id = to_number(p_tax_group)
            and fnd_date.canonical_to_date(p_date_earned) between
                    hou.date_from and nvl(hou.date_to,to_date('31/12/4712','DD/MM/YYYY'));

            hr_utility.trace('lv_tax_group = ' || lv_tax_group);

            exception when no_data_found then
            hr_utility.trace('lv_tax_group exception: no_data_found ');
            null;

          end;
    end if;

-- Account Number
    if p_quebec = 'Y' then
        begin
            select pcp.account_number
            into lv_account_number
            from hr_organization_information hoi1,
                 hr_organization_information hoi2,
                 pay_ca_pmed_accounts pcp
            where hoi1.org_information_context = 'CLASS'
            and   hoi1.org_information1 = 'CA_PMED'
            and   hoi1.org_information2 = 'Y'
            and   hoi1.organization_id = hoi2.organization_id
            and   pcp.organization_id  = hoi1.organization_id
            and   pcp.business_group_id = p_business_group_id
            and   pcp.source_id         = to_number(p_qhsf_account_number)
            and   hoi2.org_information1 = 'QC'
            and   hoi2.org_information_context = 'Provincial Information';

            hr_utility.trace('lv_account_number = ' || lv_account_number);

            exception when no_data_found then
            hr_utility.trace('lv_account_number exception: no_data_found ');
            null;

          end;
    end if;

-- Federal/Province Flags for SDR

    if p_sdr_federal = 'Y' then
        lv_federal := 'Yes';
    elsif p_sdr_federal = 'N' then
        lv_federal := 'No';
    else
        lv_federal := '';
    end if;

    if p_sdr_province = 'Y' then
        lv_province := 'Yes';
    elsif p_sdr_province = 'N' then
        lv_province := 'No';
    else
        lv_province := '';
    end if;


    if p_consolidation_set_id is null then
       lv_ded_consolidation_dummy := 'X';
    else
       lv_ded_consolidation_dummy := '';
    end if;

    if p_reg_suppress_zero = 'Y' then
       lv_reg_suppress_zero := 'Yes';
    elsif p_reg_suppress_zero = 'N' then
       lv_reg_suppress_zero := 'No';
    end if;

    if p_reg_full_report_ver = 'Y' then
       lv_reg_full_report_ver := 'Yes';
    elsif p_reg_full_report_ver = 'N' then
       lv_reg_full_report_ver := 'No';
    end if;

    if p_reg_employee_page_break = 'Y' then
       lv_reg_employee_page_break := 'Yes';
    elsif p_reg_employee_page_break = 'N' then
       lv_reg_employee_page_break := 'No';
    end if;


    begin
       select meaning
       into lv_reg_sort_one
       from hr_lookups
       where lookup_code = p_reg_sort_one
       and lookup_type = 'PAY_CA_YE_SORT_CODE';

       hr_utility.trace('lv_reg_sort_one  = ' || lv_reg_sort_one );

       exception  when no_data_found then
       hr_utility.trace('lv_reg_sort_one exception: no_data_found ');
       null;
    end;

    begin
       select meaning
       into lv_reg_sort_two
       from hr_lookups
       where lookup_code = p_reg_sort_two
       and lookup_type = 'PAY_CA_YE_SORT_CODE';

       hr_utility.trace('lv_reg_sort_two  = ' || lv_reg_sort_two );

       exception  when no_data_found then
       hr_utility.trace('lv_reg_sort_two exception: no_data_found ');
       null;
    end;

    begin
       select meaning
       into lv_reg_sort_three
       from hr_lookups
       where lookup_code = p_reg_sort_three
       and lookup_type = 'PAY_CA_YE_SORT_CODE';

       hr_utility.trace('lv_reg_sort_three  = ' || lv_reg_sort_three );

       exception  when no_data_found then
       hr_utility.trace('lv_reg_sort_three exception: no_data_found ');
       null;
    end;

   begin

     if p_batch_id is not null then

         select batch_name
         into   lv_batch_name
         from pay_batch_headers
         where  batch_id = p_batch_id;

         hr_utility.trace('Batch Name :' ||lv_batch_name);

     end if;

     exception  when no_data_found then
     lv_batch_name := '';
     hr_utility.trace('lv_batch_name exception: no_data_found ');
     null;

   end;

   begin
        /* currently we are only looking at the context at payroll level
           as we do not have any required parameter for GRE on the SRS
           screen, if we want to use the contact defined at GRE level then
           we need to modify the package and SRS definition to get the
           GRE_ID , and pass it in the following function.
        */

        lv_contact_user_name := get_notifier(to_number(p_payroll_id),
                                             to_number(p_gre),
                                             p_date_earned);

        exception when others then
        hr_utility.trace('lv_contact_user_name exception: OTHERS at get_notifier');
        null;

   end;

   begin

      select orig_system,
             orig_system_id,
             name,
             display_name
      into lv_orig_system,
           lv_orig_system_id,
           lv_role_name,
           lv_role_display_name
      from wf_roles
      where name = lv_contact_user_name ;

      exception when no_data_found then
      hr_utility.trace('lv_role_name exception: no_data_found');
      null;

   end;

    hr_utility.trace('orig system  : '|| lv_orig_system);
    hr_utility.trace('orig system id : '|| lv_orig_system_id);
    hr_utility.trace('role name = ' || lv_role_name);

   wf_engine.SetItemOwner (itemtype  => ItemType,
                           itemkey   => ItemKey,
                           owner     => ProcessOwner);

   lv_process_list_html_2 := 'WF_NOTIFICATION(ATTRS';

   /* set variables that run processes */

-- BEE Transfer
     if p_batch_id is not null then
        lv_is_batch := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(1)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS01';
     else
        lv_is_batch := 'N';
     end if;

-- Retro Notification Report

     if ((p_retro_assignment_set is not null) and
         (p_retro_event_group is not null)) then

        lv_is_retro_notification := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(2)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS02';

        -- If the Retro Notification is going to be run
        -- then the RetroPay assignment set should be the
        -- same one that is generated by Retro Notification

        lv_retropay_asg_set := p_retro_assignment_set;

     else
        lv_is_retro_notification := 'N';
     end if;

-- RetroPay By Element

     if (((p_retropay_assignment_set is not null) or
          (p_retro_assignment_set is not null)) and
         (p_retropay_element_set is not null)   and
         (p_retro_start_date is not null)) then
        lv_is_retropay := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(3)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS03';
     else
        lv_is_retropay := 'N';
     end if;

     lv_prc_list := lv_prc_list||lv_conc_prog_name(4)||wf_core.newline;
     lv_process_list_html_2 := lv_process_list_html_2||',PROCESS04';

-- Gross to Net Summary

     if ((p_gross_to_net_period is not null)) then
        lv_is_gtn := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(5)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS05';
     else
        lv_is_gtn := 'N';
     end if;

     lv_prc_list := lv_prc_list||lv_conc_prog_name(6)||wf_core.newline;
     lv_process_list_html_2 := lv_process_list_html_2||',PROCESS06';

-- Employee Assignments Not Paid
     if ((p_consolidation_set_id is not null)) then
        lv_is_consolidation_set := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(7)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS07';
     else
        lv_is_consolidation_set := 'N';
     end if;

-- Payroll Exception Report
     if ((p_consolidation_set_id is not null) and
         ((p_exp_report_name is not null) or
          (p_exp_group_name is not null))) then
        lv_is_exception := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(8)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS08';
     else
        lv_is_exception := 'N';
     end if;

-- Statutory Deductions Report

     if ((p_sdr_federal is not null) and
         (p_sdr_reporting_dimension is not null)) then
        lv_is_sdr := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(9)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS09';
     else
        lv_is_sdr := 'N';
     end if;

-- Quebec Health Services Fund

     if (p_quebec = 'Y') then
        lv_prc_list := lv_prc_list||lv_conc_prog_name(10)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS10';
     end if;


-- Pre Payment

     if (p_consolidation_set_id is not null) then
        lv_prc_list := lv_prc_list||lv_conc_prog_name(11)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS11';
     end if;


-- Payroll Register Report

     if ((p_consolidation_set_id is not null) and
         (p_reg_suppress_zero is not null) and
         (p_reg_req_num is not null) and
         (p_reg_reporting_dim is not null)) then
        lv_is_payroll_register := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(12)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS12';
     else
        lv_is_payroll_register := 'N';
     end if;

-- Element Register Report

     if (p_ele_selection_criterion is not null)
        then
        lv_is_element_register := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(13)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS13';
     else
        lv_is_element_register := 'N';
     end if;

-- Deductions Report

     if ((p_deduction_sort_one is not null) and
         (p_deduction_sort_two is not null) and
         (p_deduction_sort_three is not null))
        then
        lv_is_deductions := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(14)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS14';
     else
        lv_is_deductions := 'N';
     end if;

-- Direct Deposit

     if ((p_consolidation_set_id is not null) and
         (p_dd_payment_method is not null))
        then
        lv_is_direct_deposit := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(15)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS15';
     else
        lv_is_direct_deposit := 'N';
     end if;


-- Canadian Payroll Archiver

     if (p_consolidation_set_id is not null) then
        lv_prc_list := lv_prc_list||lv_conc_prog_name(16)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS16';
     end if;


-- Canadian Cheque Writer

     if ((p_consolidation_set_id is not null) and
         (p_cheque_payment_method is not null) and
         (p_cheque_payment_type is not null) and
         (p_cheque_sort_sequence is not null) and
         (p_cheque_style is not null) and
         (p_start_cheque_number is not null)) then
        lv_is_chequewriter := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(17)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS17';
     else
        lv_is_chequewriter := 'N';
     end if;

-- Canadian Deposit Advice

     if ((p_da_data_type is not null) and
         (p_consolidation_set_id is not null)) then
        lv_is_deposit_advice := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(18)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS18';
     else
        lv_is_deposit_advice := 'N';
     end if;

-- Payment Report

     if (p_consolidation_set_id is not null) then
        lv_prc_list := lv_prc_list||lv_conc_prog_name(19)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS19';
     end if;

-- Record of Employment

     if ((p_roe_assignment_set is not null)) then
        lv_is_roe := 'Y';
        lv_prc_list := lv_prc_list||lv_conc_prog_name(20)||wf_core.newline;
        lv_prc_list := lv_prc_list||lv_conc_prog_name(21)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS20';
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS21';

        if (p_roe_mag_roe_type is not null) then
            lv_is_roe_mag := 'Y';
            lv_prc_list := lv_prc_list||lv_conc_prog_name(22)||wf_core.newline;
            lv_process_list_html_2 := lv_process_list_html_2||',PROCESS22';
        else
            lv_is_roe_mag := 'N';
        end if;
     else
        lv_is_roe := 'N';
        lv_is_roe_mag := 'N';
     end if;

-- Costing

     if ((p_consolidation_set_id is not null)) then
        lv_prc_list := lv_prc_list||lv_conc_prog_name(23)||wf_core.newline;
        lv_prc_list := lv_prc_list||lv_conc_prog_name(24)||wf_core.newline;
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS23';
        lv_process_list_html_2 := lv_process_list_html_2||',PROCESS24';

        if (p_cost_summary_file_out is not null) then
           lv_is_costing_summary := 'Y';
           lv_prc_list := lv_prc_list||lv_conc_prog_name(25)||wf_core.newline;
           lv_process_list_html_2 := lv_process_list_html_2||',PROCESS25';
        else
           lv_is_costing_summary := 'N';
        end if;
     else
        lv_is_costing_summary := 'N';
     end if;

    lv_process_list_subject := 'List of Processes and Reports which will be submitted';

    if lv_workflow_mode = 'W' then

       lv_process_list_text := 'Review the List of Processes and Reports which will be submitted based on the input parameters, please click on the '||''''||'Continue'||''''||' button to start processing.'||wf_core.newline||wf_core.newline||lv_prc_list;

       lv_process_list_html_1 := 'Review the List of Processes and Reports which will be submitted based on the input parameters, please click on the '||''''||'Continue'||''''||' button to start processing.';

    else

       lv_process_list_text := 'Review the List of Processes and Reports which will be submitted based on the input parameters.'||wf_core.newline||wf_core.newline||lv_prc_list;

       lv_process_list_html_1 := 'Review the List of Processes and Reports which will be submitted based on the input parameters.';

    end if;

    lv_process_list_html_2 := lv_process_list_html_2||')';

    hr_utility.trace('p_payroll_id = ' || p_payroll_id);
    hr_utility.trace('p_consolidation_set_id = ' || p_consolidation_set_id);
    hr_utility.trace('p_date_earned = ' || p_date_earned);
    hr_utility.trace('p_date_paid = ' || p_date_paid);
    hr_utility.trace('p_payroll_assignment_set = ' || p_payroll_assignment_set);
    hr_utility.trace('p_payroll_run_type = ' || p_payroll_run_type);

begin

     num_varname(1)  := 'USER_ID';
     num_varvalue(1) := l_user_id;
     num_varname(2)  := 'APPLICATION_ID';
     num_varvalue(2) := l_resp_appl_id;
     num_varname(3)  := 'RESPONSIBILITY_ID';
     num_varvalue(3) := l_resp_id;
     num_varname(4)  := 'ORG_ID';
     num_varvalue(4) := l_org_id;
     num_varname(5)  := 'PER_SECURITY_PROFILE_ID';
     num_varvalue(5) := l_per_sec_id;
     num_varname(6)  := 'SECURITY_GROUP_ID';
     num_varvalue(6) := l_sec_grp_id;


     i := 0;

     varname(i) := 'P_BUSINESS_GROUP_ID';
     varval(i)  := to_char(p_business_group_id);
              i := i+1;
     varname(i) := 'WORKFLOW_MODE';
     varval(i)  := lv_workflow_mode;
              i := i+1;
     varname(i) := 'CURR_ITEM_TYPE';
     varval(i)  := ItemType;
              i := i+1;
     varname(i) := 'CURR_ITEM_KEY';
     varval(i)  := ItemKey;
              i := i+1;
     varname(i) := 'ROLE_NAME';
     varval(i)  := lv_role_name;
              i := i+1;
     varname(i) := 'USER';
     varval(i)  := lv_contact_user_name;
              i := i+1;


     varname(i) := 'IS_CONSOLIDATION_SET';
     varval(i)  := lv_is_consolidation_set;
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
     varname(i) := 'DATE_TIME';
     varval(i)  := lv_date_time;
              i := i+1;
     varname(i) := 'GRE';
     varval(i)  := p_gre;
              i := i+1;
     varname(i) := 'GRE_NAME';
     varval(i)  := lv_gre_name;
              i := i+1;
     varname(i) := 'TAX_GROUP';
     varval(i)  := p_tax_group;
              i := i+1;
     varname(i) := 'TAX_GROUP_NAME';
     varval(i)  := lv_tax_group;
              i := i+1;
     varname(i) := 'ORGANIZATION';
     varval(i)  := p_organization;
              i := i+1;
     varname(i) := 'ORGANIZATION_NAME';
     varval(i)  := lv_organization;
              i := i+1;
     varname(i) := 'LOCATION';
     varval(i)  := p_location;
              i := i+1;
     varname(i) := 'LOCATION_NAME';
     varval(i)  := lv_location;
              i := i+1;

-- BEE (Transfer)

     varname(i) := 'IS_BATCH';
     varval(i)  := lv_is_batch;
              i := i+1;
     varname(i) := 'BATCH_ID';
     varval(i)  := to_char(p_batch_id);
              i := i+1;
     varname(i) := 'BEE_BATCH_NAME';
     varval(i)  := lv_batch_name;
              i := i+1;

-- Retro-Notification Report

     varname(i) := 'IS_RETRO_NOTIFICATION';
     varval(i)  := lv_is_retro_notification;
              i := i+1;
     varname(i) := 'RETRO_START_DATE_DUMMY';
     varval(i)  := 'START_DATE=1900/01/01 00:00:00';
              i := i+1;
     varname(i) := 'END_DATE_LEG_PARAM';
     varval(i)  := 'END_DATE='||p_date_earned;
              i := i+1;
     varname(i) := 'PAYROLL_LEG_PARAM';
     varval(i)  := 'PAYROLL_ID='||p_payroll_id;
              i := i+1;
     varname(i) := 'RETRO_PERIOD';
     varval(i)  := lv_retro_period;
              i := i+1;
     varname(i) := 'EVENT_GROUP';
     varval(i)  := p_retro_event_group;
              i := i+1;
     varname(i) := 'EVENT_GROUP_NAME';
     varval(i)  := lv_event_group_name;
              i := i+1;
     varname(i) := 'RETRO_ASSIGNMENT_SET_NAME';
     varval(i)  := p_retro_assignment_set;
              i := i+1;
     varname(i) := 'RETRO_ASSIGNMENT_SET_NAME_DUMY';
     varval(i)  := 'ASG_SET='||p_retro_assignment_set;
              i := i+1;

-- RetroPay By Element

     varname(i) := 'IS_RETROPAY';
     varval(i)  := lv_is_retropay;
              i := i+1;
     varname(i) := 'RETRO_ASSIGNMENT_SET_ID';
     varval(i)  := p_retropay_assignment_set;
              i := i+1;
     varname(i) := 'RETROPAY_ASG_SET_NAME';
     varval(i)  := lv_retropay_asg_set;
              i := i+1;
     varname(i) := 'RETRO_ELEMENT_SET';
     varval(i)  := p_retropay_element_set;
              i := i+1;
     varname(i) := 'RETROPAY_ELEMENT_SET_NAME';
     varval(i)  := lv_retropay_element_set;
              i := i+1;
     varname(i) := 'RETRO_START_DATE';
     varval(i)  := p_retro_start_date;
              i := i+1;

-- Payroll Run Process

     varname(i) := 'PAYROLL_ELEMENT_SET_ID';
     varval(i)  := p_payroll_element_set;
              i := i+1;
     varname(i) := 'PAYROLL_ELEMENT_SET_NAME';
     varval(i)  := lv_payroll_element_set;
              i := i+1;
     varname(i) := 'PAYROLL_ASSIGNMENT_SET_ID';
     varval(i)  := p_payroll_assignment_set;
              i := i+1;
     varname(i) := 'PAYROLL_ASSIGNMENT_SET_NAME';
     varval(i)  := lv_payroll_assignment_set;
              i := i+1;
     varname(i) := 'PAYROLL_RUN_TYPES_ID';
     varval(i)  := p_payroll_run_type;
              i := i+1;
     varname(i) := 'PAYROLL_RUN_TYPE_NAME';
     varval(i)  := lv_payroll_run_type;
              i := i+1;

-- Gross to Net Summary

     varname(i) := 'IS_GTN';
     varval(i)  := lv_is_gtn;
              i := i+1;
     varname(i) := 'GTN_PERIOD';
     varval(i)  := p_gross_to_net_period;
              i := i+1;
     varname(i) := 'GTN_PERIOD_NAME';
     varval(i)  := lv_gtn_period;
              i := i+1;

-- Payroll Message Report

     varname(i) := 'SESSION_DATE';
     varval(i)  := p_session_date;
              i := i+1;
     varname(i) := 'PAYROLL_ACTION_ID';
     varval(i)  := p_payroll_process;
              i := i+1;
     varname(i) := 'PAYROLL_MSG_PAYROLL_PROCESS';
     varval(i)  := lv_payroll_process;
              i := i+1;

-- Quebec Health Services Fund

     varname(i) := 'IS_QUEBEC';
     varval(i)  := p_quebec;
              i := i+1;
     varname(i) := 'ACCOUNT_NUMBER_ID';
     varval(i)  := p_qhsf_account_number;
              i := i+1;
     varname(i) := 'ACCOUNT_NUMBER';
     varval(i)  := lv_account_number;
              i := i+1;
     varname(i) := 'OVERRIDE_TABLE';
     varval(i)  := p_qhsf_override_table;
              i := i+1;

-- Statutory Deductions Report

     varname(i) := 'IS_SDR';
     varval(i)  := lv_is_sdr;
              i := i+1;
     varname(i) := 'FEDERAL';
     varval(i)  := p_sdr_federal;
              i := i+1;
     varname(i) := 'FEDERAL_NAME';
     varval(i)  := lv_federal;
              i := i+1;
     varname(i) := 'PROVINCE';
     varval(i)  := p_sdr_province;
              i := i+1;
     varname(i) := 'PROVINCE_NAME';
     varval(i)  := lv_province;
              i := i+1;
     varname(i) := 'REPORTING_DIMENSION';
     varval(i)  := p_sdr_reporting_dimension;
              i := i+1;
     varname(i) := 'REPORTING_DIMENSION_NAME';
     varval(i)  := lv_reporting_dimension;
              i := i+1;


-- Exception Report

     varname(i) := 'IS_EXCEPTION';
     varval(i)  := lv_is_exception;
              i := i+1;
     varname(i) := 'SELECT_REPORT_OR_GROUP';
     varval(i)  := p_exp_report_or_group;
              i := i+1;
     varname(i) := 'EXCEPTION_LEGISLATION_CODE';
     varval(i)  := p_exp_legislation_code;
              i := i+1;
     varname(i) := 'IS_EXCEPTION_GROUP';
     varval(i)  := p_exp_is_group;
              i := i+1;
     varname(i) := 'EXCEPTION_GROUP_NAME';
     varval(i)  := p_exp_group_name;
              i := i+1;
     varname(i) := 'EXCEPTION_GROUP_NAME_NAME';
     varval(i)  := lv_exp_group_name;
              i := i+1;
     varname(i) := 'EXCEPTION_GROUP_NAME_DMY';
     varval(i)  := 'TRANSFER_GROUP='||p_exp_group_name;
              i := i+1;
     varname(i) := 'IS_EXCEPTION_REPORT';
     varval(i)  := p_exp_is_report;
              i := i+1;
     varname(i) := 'EXCEPTION_REPORT_NAME';
     varval(i)  := p_exp_report_name;
              i := i+1;
     varname(i) := 'EXCEPTION_REPORT_NAME_NAME';
     varval(i)  := lv_exp_report_name;
              i := i+1;
     varname(i) := 'EXCEPTION_REPORT_NAME_DMY';
     varval(i)  := 'TRANSFER_REPORT='||p_exp_report_name;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_TYPE';
     varval(i)  := p_exp_variance_type;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_TYPE_NAME';
     varval(i)  := lv_exp_vartype_name;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_TYPE_DMY';
     varval(i)  := 'TRANSFER_VARTYPE='||p_exp_variance_type;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_VALUE';
     varval(i)  := p_exp_variance_value;
              i := i+1;
     varname(i) := 'OVER_RIDE_VARIANCE_VALUE_DMY';
     varval(i)  := 'TRANSFER_VARVALUE='||p_exp_variance_value;
              i := i+1;
     varname(i) := 'TRANSFER_DATE';
     varval(i)  := 'TRANSFER_DATE='||p_date_paid;
              i := i+1;
     varname(i) := 'PPA_FINDER_PQP';
     varval(i)  := lv_exp_finder_pqp;
              i := i+1;
     varname(i) := 'TRANSFER_PPA_FINDER_PQP';
     varval(i)  := 'TRANSFER_PPA_FINDER='||lv_exp_finder_pqp;
              i := i+1;
     varname(i) := 'TRANSFER_PAYROLL';
     varval(i)  := 'TRANSFER_PAYROLL='||p_payroll_id;
              i := i+1;
     varname(i) := 'TRANSFER_CONC_SET';
     varval(i)  := 'TRANSFER_CONC_SET='||p_consolidation_set_id;
              i := i+1;

-- PrePayment

     varname(i) := 'PREPAY_PAYMENT_METHOD_OVERRIDE';
     varval(i)  := p_payment_method_override;
              i := i+1;
     varname(i) := 'PREPAY_PAYMENT_METHOD_NAME';
     varval(i)  := lv_prepay_payment_method;
              i := i+1;

-- Element Register Report

     varname(i) := 'IS_ELEMENT';
     varval(i)  := lv_is_element_register;
              i := i+1;
     varname(i) := 'SELECTION_CRITERION';
     varval(i)  := p_ele_selection_criterion;
              i := i+1;
     varname(i) := 'IS_ELEMENT_SET';
     varval(i)  := p_ele_is_element_set;
              i := i+1;
     varname(i) := 'ELE_REG_ELEMENT_SET';
     varval(i)  := p_ele_element_set;
              i := i+1;
     varname(i) := 'ELE_REG_ELEMENT_SET_NAME';
     varval(i)  := lv_ele_element_set;
              i := i+1;
     varname(i) := 'IS_ELEMENT_CLASSIFICATION';
     varval(i)  := p_ele_is_element_class;
              i := i+1;
     varname(i) := 'ELEMENT_CLASSIFICATION';
     varval(i)  := p_ele_element_class;
              i := i+1;
     varname(i) := 'ELEMENT_CLASSIFICATION_NAME';
     varval(i)  := lv_ele_element_class;
              i := i+1;
     varname(i) := 'IS_ELEMENT_NAME';
     varval(i)  := p_ele_is_element_name;
              i := i+1;
     varname(i) := 'ELEMENT';
     varval(i)  := p_ele_element_name;
              i := i+1;
     varname(i) := 'ELEMENT_NAME';
     varval(i)  := lv_ele_element_name;
              i := i+1;
     varname(i) := 'EMP_ID';
     varval(i)  := p_ele_employee;
              i := i+1;
     varname(i) := 'EMP_NAME';
     varval(i)  := lv_ele_employee;
              i := i+1;

-- Deduction Report(CA)

     varname(i) := 'IS_DEDUCTIONS';
     varval(i)  := lv_is_deductions;
              i := i+1;
     varname(i) := 'DEDN_CONSOLIDATION_DMY';
     varval(i)  := lv_ded_consolidation_dummy;
              i := i+1;
     varname(i) := 'DEDN_CLASSIFICATION';
     varval(i)  := p_deduction_class;
              i := i+1;
     varname(i) := 'DEDN_CLASSIFICATION_NAME';
     varval(i)  := lv_deduction_class;
              i := i+1;
     varname(i) := 'DEDN_ID';
     varval(i)  := p_deduction_name;
              i := i+1;
     varname(i) := 'DEDN_NAME';
     varval(i)  := lv_deduction_name;
              i := i+1;
     varname(i) := 'SORT_ONE';
     varval(i)  := p_deduction_sort_one;
              i := i+1;
     varname(i) := 'SORT_TWO';
     varval(i)  := p_deduction_sort_two;
              i := i+1;
     varname(i) := 'SORT_THREE';
     varval(i)  := p_deduction_sort_three;
              i := i+1;

-- Payroll Register Report


     varname(i) := 'IS_PAYROLL_REGISTER';
     varval(i)  := lv_is_payroll_register;
              i := i+1;
     varname(i) := 'BUSINESS_GROUP_ID_DMY';
     varval(i)  := 'B_G_ID='||p_business_group_id;
              i := i+1;
     varname(i) := 'PAYROLL_DMY';
     varval(i)  := 'PY_ID='||p_payroll_id;
              i := i+1;
     varname(i) := 'CONSOLIDATION_SET_DMY';
     varval(i)  := 'C_ST_ID='||p_consolidation_set_id;
              i := i+1;
     varname(i) := 'GRE_DMY';
     varval(i)  := 'T_U_ID='||p_gre;
              i := i+1;
     varname(i) := 'LOCATION_DMY';
     varval(i)  := 'L_ID='||p_location;
              i := i+1;
     varname(i) := 'ORGANIZATION_DMY';
     varval(i)  := 'O_ID='||p_organization;
              i := i+1;
     varname(i) := 'PERSON_DMY';
     varval(i)  := 'P_ID='||p_ele_employee;
              i := i+1;
     varname(i) := 'SUPPRESS_ZERO_CODE';
     varval(i)  := p_reg_suppress_zero;
              i := i+1;
     varname(i) := 'SUPPRESS_ZERO';
     varval(i)  := lv_reg_suppress_zero;
              i := i+1;
     varname(i) := 'SUPPRESS_ZERO_DMY';
     varval(i)  := 'S_Z='||p_reg_suppress_zero;
              i := i+1;
     varname(i) := 'FULL_REPORT_VERSION_CODE';
     varval(i)  := p_reg_full_report_ver;
              i := i+1;
     varname(i) := 'FULL_REPORT_VERSION';
     varval(i)  := lv_reg_full_report_ver;
              i := i+1;
     varname(i) := 'FULL_REPORT_VERSION_DMY';
     varval(i)  := 'F_R='||p_reg_full_report_ver;
              i := i+1;
     varname(i) := 'PAYREG_REPORTING_DIMENSION_C';
     varval(i)  := p_reg_reporting_dim;
              i := i+1;
     varname(i) := 'PAYREG_REPORTING_DIMENSION';
     varval(i)  := lv_reg_reporting_dimension;
              i := i+1;
     varname(i) := 'PAYREG_REPORTING_DIMENSION_DMY';
     varval(i)  := 'RP_DM='||p_reg_reporting_dim;
              i := i+1;
     varname(i) := 'SORT_ONE_CODE';
     varval(i)  := p_reg_sort_one;
              i := i+1;
     varname(i) := 'REGISTER_SORT_ONE';
     varval(i)  := lv_reg_sort_one;
              i := i+1;
     varname(i) := 'SORT_ONE_DMY';
     varval(i)  := 'P_S1='||p_reg_sort_one;
              i := i+1;
     varname(i) := 'SORT_TWO_CODE';
     varval(i)  := p_reg_sort_two;
              i := i+1;
     varname(i) := 'REGISTER_SORT_TWO';
     varval(i)  := lv_reg_sort_two;
              i := i+1;
     varname(i) := 'SORT_TWO_DMY';
     varval(i)  := 'P_S2='||p_reg_sort_two;
              i := i+1;
     varname(i) := 'SORT_THREE_CODE';
     varval(i)  := p_reg_sort_three;
              i := i+1;
     varname(i) := 'REGISTER_SORT_THREE';
     varval(i)  := lv_reg_sort_three;
              i := i+1;
     varname(i) := 'SORT_THREE_DMY';
     varval(i)  := 'P_S3='||p_reg_sort_three;
              i := i+1;
     varname(i) := 'EMPLOYEE_PAGE_BREAK_CODE';
     varval(i)  := p_reg_employee_page_break;
              i := i+1;
     varname(i) := 'EMPLOYEE_PAGE_BREAK';
     varval(i)  := lv_reg_employee_page_break;
              i := i+1;
     varname(i) := 'EMPLOYEE_PAGE_BREAK_DMY';
     varval(i)  := 'EMP_BRK='||p_reg_employee_page_break;
              i := i+1;
     varname(i) := 'SEQ_NUM';
     varval(i)  := p_reg_req_num;
              i := i+1;
     varname(i) := 'SEQ_NUM_DMY';
     varval(i)  := 'S_N='||p_reg_req_num;
              i := i+1;

-- Direct Deposit

     varname(i) := 'IS_DIRECT_DEPOSIT';
     varval(i)  := lv_is_direct_deposit;
              i := i+1;
     varname(i) := 'PAYMENT_TYPE_ID';
     varval(i)  := p_dd_payment_type;
              i := i+1;
     varname(i) := 'PAYMENT_METHOD_ID';
     varval(i)  := p_dd_payment_method;
              i := i+1;
     varname(i) := 'OVERRIDE_DD_DATE';
     varval(i)  := p_dd_override_date;
              i := i+1;
     varname(i) := 'FINANCIAL_INSTITUTION_CODE';
     varval(i)  := p_dd_financial_inst;
              i := i+1;
     varname(i) := 'FINANCIAL_INSTITUTION_HIDDEN';
     varval(i)  := 'MAGTAPE_REPORT_ID='||p_dd_financial_inst;
              i := i+1;
     varname(i) := 'OVERRIDE_CPA_CODE';
     varval(i)  := p_dd_cpa_code;
              i := i+1;
     varname(i) := 'OVERRIDE_FILE_CREATION_NUMBER';
     varval(i)  := p_dd_file_number;
              i := i+1;
     varname(i) := 'OVERRIDE_FCN';
     varval(i)  := 'FILE_CREATION_NUMBER_OVERRIDE='||p_dd_file_number;
              i := i+1;
     varname(i) := 'FILE_CREATION_DATE';
     varval(i)  := '|FILE_CREATION_DATE='||p_session_date||'|';
              i := i+1;


-- Canadian Payroll Archiver

     varname(i) := 'TRANSFER_PAYROLL_ARCHIVER';
     varval(i)  := 'TRANSFER_PAYROLL_ID='||p_payroll_id;
              i := i+1;
     varname(i) := 'TRANSFER_CONC_SET_ARCHIVER';
     varval(i)  := 'TRANSFER_CONSOLIDATION_SET_ID='||p_consolidation_set_id;
              i := i+1;


-- Canadian Chequewriter

     varname(i) := 'IS_CHEQUE_WRITER';
     varval(i)  := lv_is_chequewriter;
              i := i+1;
     varname(i) := 'CHEQUE_PAYMENT_TYPE_ID';
     varval(i)  := p_cheque_payment_type;
              i := i+1;
     varname(i) := 'CHEQUE_PAYMENT_TYPE_NAME';
     varval(i)  := lv_cheque_payment_type;
              i := i+1;
     varname(i) := 'CHEQUE_PAYMENT_METHOD_ID';
     varval(i)  := p_cheque_payment_method;
              i := i+1;
     varname(i) := 'CHEQUE_PAYMENT_METHOD_NAME';
     varval(i)  := lv_cheque_payment_method;
              i := i+1;
     varname(i) := 'CHEQUE_SORT_SEQUENCE';
     varval(i)  := p_cheque_sort_sequence;
              i := i+1;
     varname(i) := 'CHEQUE_SORT_SEQUENCE_MEANING';
     varval(i)  := lv_cheque_sort_sequence;
              i := i+1;
     varname(i) := 'CHEQUE_STYLE';
     varval(i)  := p_cheque_style;
              i := i+1;
     varname(i) := 'CHEQUE_STYLE_MEANING';
     varval(i)  := lv_cheque_style;
              i := i+1;
     varname(i) := 'CHEQUE_START_NUMBER';
     varval(i)  := p_start_cheque_number;
              i := i+1;
     varname(i) := 'CHEQUE_END_NUMBER';
     varval(i)  := p_end_cheque_number;
              i := i+1;

-- Deposit Advice

     varname(i) := 'IS_DEPOSIT_ADVICE';
     varval(i)  := lv_is_deposit_advice;
              i := i+1;
     varname(i) := 'ADVICE_REPORT_CATEGORY';
     varval(i)  := p_da_data_type;
              i := i+1;
     varname(i) := 'ADVICE_REPORT_CATEGORY_NAME';
     varval(i)  := lv_da_data_type;
              i := i+1;
     varname(i) := 'ADVICE_PAYROLL';
     varval(i)  := 'PAYROLL_ID='||p_payroll_id;
              i := i+1;
     varname(i) := 'ADVICE_CONSOLIDATION_SET';
     varval(i)  := 'CONSOLIDATION_SET_ID='||p_consolidation_set_id;
              i := i+1;
     varname(i) := 'ADVICE_START_DATE_DMY';
     varval(i)  := 'START_DATE='||p_date_paid;
              i := i+1;
     varname(i) := 'ADVICE_END_DATE_DMY';
     varval(i)  := 'END_DATE='||p_date_paid;
              i := i+1;
     varname(i) := 'ADVICE_ASG_SET_DMY';
     varval(i)  := 'ASG_SET_ID='||p_payroll_assignment_set;
              i := i+1;

-- Payment Report

     varname(i) := 'PAYMENT_PAYMENT_TYPE_ID';
     varval(i)  := p_payment_rep_payment_type;
              i := i+1;
     varname(i) := 'PAYMENT_PAYMENT_METHOD_ID';
     varval(i)  := p_payment_rep_payment_method;
              i := i+1;

-- ROE

     varname(i) := 'IS_ROE';
     varval(i)  := lv_is_roe;
              i := i+1;
     varname(i) := 'ROE_ASG_SET';
     varval(i)  := p_roe_assignment_set;
              i := i+1;
     varname(i) := 'ROE_ASG_SET_NAME';
     varval(i)  := lv_roe_asg_set;
              i := i+1;

-- ROE Worksheet

     varname(i) := 'ROE_WORKSHEET_PERSON';
     varval(i)  := p_roe_worksheet_person;
              i := i+1;
     varname(i) := 'ROE_WORKSHEET_PERSON_NAME';
     varval(i)  := lv_roe_worksheet_person;
              i := i+1;

-- ROE Magnetic Media

     varname(i) := 'IS_ROE_MAG';
     varval(i)  := lv_is_roe_mag;
              i := i+1;
     varname(i) := 'ROE_MAG_PERSON';
     varval(i)  := p_roe_mag_media_person;
              i := i+1;
     varname(i) := 'ROE_MAG_PERSON_NAME';
     varval(i)  := lv_roe_mag_media_person;
              i := i+1;
     varname(i) := 'ROE_TYPE';
     varval(i)  := p_roe_mag_roe_type;
              i := i+1;
     varname(i) := 'ROE_TYPE_HIDDEN';
     varval(i)  := 'ROE_TYPE='||p_roe_mag_roe_type;
              i := i+1;

-- Costing

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


-- Notification Attributes

     varname(i) := 'PROCESS_LIST_SUBJECT';
     varval(i)  := lv_process_list_subject;
              i := i+1;
     varname(i) := 'PROCESS_LIST_TEXT';
     varval(i)  := lv_process_list_text;
              i := i+1;
     varname(i) := 'PROCESS_LIST_HTML1';
     varval(i)  := lv_process_list_html_1;
              i := i+1;
     varname(i) := 'PROCESS_LIST_HTML2';
     varval(i)  := lv_process_list_html_2;
              i := i+1;

-- print out set values for attributes

     for j in varname.first..varname.last loop
          hr_utility.trace( 'varname '|| j ||'  = '||varname(j));
          hr_utility.trace( 'varval '|| j ||' = '||varval(j));
     end loop;


     wf_engine.SetItemAttrTextArray(ItemType, ItemKey, varname, varval);
     hr_utility.trace( 'Total Count = '||to_char(varname.COUNT));

     for k in num_varname.first..num_varname.last loop
         hr_utility.trace( 'num_varname '|| k ||' = '||num_varname(k));
         hr_utility.trace( 'num_varval '|| k ||' = '||num_varvalue(k));
     end loop;


     wf_engine.SetItemAttrNumberArray(ItemType, ItemKey, num_varname, num_varvalue);
     hr_utility.trace( 'Total Num Count = '||to_char(num_varname.COUNT));

exception
     when OTHERS then
          hr_utility.trace('varname exception: OTHERS of TextArray');
          raise;
end;

    hr_utility.trace('Before StartProcess');

    wf_engine.StartProcess (ItemType => ItemType,
                            ItemKey  => ItemKey );

    hr_utility.trace('After StartProcess');

    hr_utility.set_location('Leaving: ' || l_proc, 100);


exception
   when others then
   wf_core.Context('pay_ca_wf_pkg',
                   'StartProcess',
                   ItemType,
                   RequestorUsername,
                   ProcessOwner,
                   Workflowprocess);

   error;
   RAISE;

end StartProcess;

function get_notifier(p_payroll_id     in number,
               	      p_gre_id         in number,
               	      p_effective_date in varchar2) return varchar2 is

  l_proc	        varchar2(80) := gv_package||'.get_notifier';
  lv_contact_source	varchar2(50);
  lv_contact_user_name	varchar2(150);

-- get the payroll contact

  cursor c_payroll_contact is
  select prl_information7
  from 	pay_payrolls_f
  where payroll_id = p_payroll_id
  and   prl_information_category = 'CA'
  and   fnd_date.canonical_to_date(p_effective_date) between
                    effective_start_date and effective_end_date;

-- get the GRE contact

  cursor c_gre_contact is
  select org_information1
  from hr_organization_information
  where org_information_context || '' = 'Contact Information'
  and   organization_id = p_gre_id;

begin

    hr_utility.set_location('Starting: ' || l_proc, 100);

    lv_contact_source := fnd_profile.value('HR_PAYROLL_CONTACT_SOURCE');

    hr_utility.trace('Profile Value : '|| lv_contact_source);
    hr_utility.trace('Payroll Id : '|| p_payroll_id);
    hr_utility.trace('GRE Id : '|| p_gre_id);
    hr_utility.trace('Effective Date : '|| p_effective_date);


    if lv_contact_source = 'PAYROLL' then

	open c_payroll_contact;
	fetch c_payroll_contact into lv_contact_user_name;

        hr_utility.trace('Contact User : '|| lv_contact_user_name);

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

    else
 -- some other source we don't understand yet
          lv_contact_user_name := 'SYSADMIN';
    end if;

    return lv_contact_user_name;

    hr_utility.set_location('Leaving: ' || l_proc, 100);

end get_notifier;


procedure error is
begin

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


end pay_ca_wf_pkg;

/
