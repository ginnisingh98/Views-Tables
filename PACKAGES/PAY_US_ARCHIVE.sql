--------------------------------------------------------
--  DDL for Package PAY_US_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pyusarch.pkh 120.3.12010000.2 2009/08/10 10:37:07 svannian ship $ */

/*
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

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   06-MAY-1998  nbristow    40.0            Created.
   08-AUG-98    achauhan    40.1            Added routines for the Year End Pre-Process.
   04-DEC-98    vmehta      40.3            Changed definition for check_residence_state
   27-OCT-99    rpotnuru    110.9           Added two global variables g_sqwl_state and
                                            g_sqwl_jursd to fix NY burroughs problem
   03-AUG-00    ssarma      40.10           Removed the SQWL procedures and functions
                                            as they are now stored in pyussqwl.pkh.
   31-AUG-01    ssarma     115.5            Added 2 parameters to eoy_archive_gre_data
                                            for re-archiving purposes.
   30-NOV-01   jgoswami    115.6            added dbdrv command.
   22-JAN-2002 jgoswami    115.7            added checkfile command.
   19-AUG-2002 ppanda      115.8            Added OSERROR Check
   20-AUG-2002 asasthan    115.9            Added global variables for storing
                                            'PR' and 1099R GREs.
   20-AUG-2002 asasthan    115.10           Added global variables for storing
                                            report_type
   27-AUG-2002 asasthan    115.12           Added get_parameter function
   28-AUG-2002 asasthan    115.13           Added feed_info to plsql table
   23-SEP-2002 asasthan    115.14           Added business_group_id for box 12 function
   02-DEC-2002 asasthan    115.15           Changes for nocopy gscc comp
   04-AUG-2004 meshah      115.16           defined some global variables.
   05-AUG-2004 meshah      115.18           moved plsql tables l_jd_done_tab and
                                            l_jd_name_done_tab from body to the
                                            header.
                                            Added new procedure deinit.
   11-AUG-2004 meshah      115.19           added g_archive_date.
   18-AUG-2004 meshah      115.20           changed l_jd_name_done_tab to be
                                            of type record.
   08-AUG-2005 rsethupa    115.21           Removed get_parameter()
   28-AUG-2006 sodhingr    115.22           added g_view_online_w2 and g_w2_corrected
*/
--
TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
TYPE number_data_type_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;
g_min_chunk              number:= -1;
g_archive_flag           varchar2(1) := 'N';
g_bal_act_id             number:= -1;
g_1099R_transmitter_code varchar2(5):= null ;
g_pre_tax_info           varchar2(1):= null ;
g_puerto_rico_gre        varchar2(1):= 'N' ;
g_report_type            varchar2(50) := null ;
g_govt_employer          varchar2(1) := 'N';
g_view_online_w2         varchar2(10);
g_w2_corrected           number;

g_jursd_context_id              number;
g_tax_unit_context_id           number;
g_state_uei                     number;
g_county_uei                    number;
g_city_uei                      number;
g_county_sd_uei                 number;
g_city_sd_uei                   number;
g_per_marital_status            number;
g_con_national_identifier       number;
g_taxable_amount_unknown        number;
g_total_distributions           number;
g_emp_distribution_percent      number;
g_total_distribution_percent    number;
g_distribution_code_for_1099r   number;
g_first_yr_roth_contrib         number; -- Added For Bug# 5517938
g_disability_plan_id            varchar2(200);
g_nj_flipp_id                   varchar2(200);  -- Added for Bug# 8251746
g_archive_date                  number;

l_jd_done_tab              pay_us_archive.char240_data_type_table;
--l_jd_name_done_tab         pay_us_archive.char240_data_type_table;

TYPE jd_name_rec IS RECORD
     (jd_name   pay_us_city_names.city_name%TYPE);

 TYPE jd_name_tab IS TABLE OF jd_name_rec INDEX BY BINARY_INTEGER;

 l_jd_name_done_tab         jd_name_tab;

  TYPE pre_tax_rec_info IS RECORD
     ( balance_name   varchar2(80),
       defined_balance  number,
       user_entity_id   number,
       feed_info        varchar2(1)
     );

  TYPE pre_tax_tab_info IS TABLE OF
       pre_tax_rec_info
 INDEX BY BINARY_INTEGER;

  ltr_pre_tax_bal     pre_tax_tab_info;
  ltr_pr_balances     pre_tax_tab_info;
  ltr_1099_bal        pre_tax_tab_info;

procedure eoy_range_cursor(pactid in  number,
                           sqlstr out nocopy varchar2);

procedure eoy_action_creation(pactid in number,
                              stperson in number,
                              endperson in number,
                              chunk in number);

procedure eoy_archive_data(p_assactid in number,
                           p_effective_date in date);

procedure eoy_archive_gre_data(p_payroll_action_id in number,
                               p_tax_unit_id       in number,
                               p_jd_type           in varchar2 default 'ALL',
                               p_state_code        in varchar2 default 'ALL');

procedure eoy_archinit(p_payroll_action_id in number);

function  get_puerto_rico_info(p_tax_unit_id  number) return varchar2;
function  get_1099r_info(p_tax_unit_id  number) return varchar2;
function  get_pre_tax_info(p_tax_unit_id  number,
                           p_business_group_id number) return varchar2;

function  get_report_type(p_payroll_action_id  number) return varchar2;

PROCEDURE eoy_deinit( p_payroll_action_id in number);

end pay_us_archive;

/
