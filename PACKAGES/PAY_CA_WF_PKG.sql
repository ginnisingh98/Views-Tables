--------------------------------------------------------
--  DDL for Package PAY_CA_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: paycawfpkg.pkh 120.0 2005/05/29 10:49 appldev noship $ */

/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Package Body Name : pay_ca_wf_pkg
    Package File Name : paycawfpkg.pkh
    Description : This package declares functions which are used by the
                  Canadian Payroll Workflow process

    Change List
    -----------
    Date        Name       Vers   Description
    ----        ----       ----   -----------
    15-JUN-2004 ssouresr   115.0  Created

  *******************************************************************/

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
                             p_cost_detail_accruals    varchar2);

procedure StartProcess (p_business_group_id       number ,
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
                        p_cost_detail_accruals    varchar2,
                        ProcessDesc in            varchar2,
                        RequestorUsername in      varchar2,
                        ProcessOwner in           varchar2,
                        Workflowprocess in        varchar2 default null,
                        item_type in              varchar2 default null,
                        item_key in               varchar2);


function get_notifier(p_payroll_id     in number,
                      p_gre_id         in number,
                      p_effective_date in varchar2) return varchar2;

procedure error;

gv_package                varchar2(50);

end pay_ca_wf_pkg;

 

/
