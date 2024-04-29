--------------------------------------------------------
--  DDL for Package PAY_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: payuswfpkg.pkh 120.1 2005/10/10 16:35:44 jgoswami noship $
--
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

    Package Body Name : PAY_WF_PKG
    Package File Name : payuswfpkg.pkh
    Description : This package declares functions which are ....

    Change List
    -----------
    Date        Name       Vers   Description
    ----        ----       ----   -----------
    08-JUN-2003 jgoswami   115.0  Created
    06-AUG-2003 jgoswami   115.3  No Copy changes.
    26-AUG-2003 jgoswami   115.4  modified parameter sequence to
                                  corelate with the SRS definition.
    10-OCT-2005 jgoswami   115.6  modified procedure,added parameter for
                                  check_writer and Costing Reports

  *******************************************************************/
procedure payroll_wf_process(errbuf     OUT nocopy    VARCHAR2,
                      retcode    OUT nocopy    NUMBER,
                      p_wf_item_type        Varchar2 ,
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
                      p_payment_method_override varchar2,
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
                      p_is_element_classification    varchar2,
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
                      );


 procedure StartProcess	(
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
                      p_ppa_finder_pqp             varchar2,
                      ProcessDesc               in varchar2,
                      RequestorUsername         in Varchar2,
                      ProcessOwner              in Varchar2,
                      Workflowprocess           in Varchar2 ,
                      item_type                 in Varchar2 ,
                      item_key                  in varchar2
                      ) ;



function get_notifier( ln_payroll_id    in number,
                        ln_gre_id    in number,
                        l_effective_date    in varchar2
                      ) return varchar2 ;


procedure error;
  gv_package               VARCHAR2(50);

end PAY_WF_PKG;

 

/
