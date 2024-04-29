--------------------------------------------------------
--  DDL for Package PAY_CA_EOY_RL2_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EOY_RL2_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pycarl2a.pkh 120.1.12010000.2 2009/04/20 15:20:02 sapalani ship $ */
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

   Description : Canadian RL2 Archiver Process

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   30-SEP-2002  SSattini    115.0           Created.
   02-DEC-2002  SSattini    115.1           Added 'nocopy' for out and in out
                                            parameters, GSCC compliance.
   02-FEB-06    SSouresr    115.2           Added new plsql table for extra
                                            employee data
   09-APR-2009  sapalani    115.3 6768167   Added Function gen_rl2_pdf_seq.
*/

procedure eoy_range_cursor(pactid in  number,
                       sqlstr out nocopy varchar2);

procedure eoy_action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number);

procedure eoy_archive_data(p_assactid in number, p_effective_date in date);

procedure eoy_archinit(p_payroll_action_id in number);

procedure archive_data_records(
               p_action_context_id   in number
              ,p_action_context_type in varchar2
              ,p_assignment_id       in number
              ,p_tax_unit_id         in number
              ,p_effective_date      in date
              ,p_tab_rec_data        in pay_ca_eoy_rl2_archive.action_info_table
               );

function gen_rl2_pdf_seq(p_aaid number,
                         p_reporting_year varchar2,
                         called_from varchar2)
          return varchar2;

/* Pl/Sql table to store and insert values into
   pay_action_information table at one shot */

  TYPE act_info_rec IS RECORD
     ( action_context_id      number(15)
      ,action_context_type    varchar2(1)
      ,action_info_category   varchar2(50)
      ,jurisdiction_code      varchar2(11)
      ,act_info1              varchar2(300)
      ,act_info2              varchar2(300)
      ,act_info3              varchar2(300)
      ,act_info4              varchar2(300)
      ,act_info5              varchar2(300)
      ,act_info6              varchar2(300)
      ,act_info7              varchar2(300)
      ,act_info8              varchar2(300)
      ,act_info9              varchar2(300)
      ,act_info10             varchar2(300)
      ,act_info11             varchar2(300)
      ,act_info12             varchar2(300)
      ,act_info13             varchar2(300)
      ,act_info14             varchar2(300)
      ,act_info15             varchar2(300)
      ,act_info16             varchar2(300)
      ,act_info17             varchar2(300)
      ,act_info18             varchar2(300)
      ,act_info19             varchar2(300)
      ,act_info20             varchar2(300)
      ,act_info21             varchar2(300)
      ,act_info22             varchar2(300)
      ,act_info23             varchar2(300)
      ,act_info24             varchar2(300)
      ,act_info25             varchar2(300)
      ,act_info26             varchar2(300)
      ,act_info27             varchar2(300)
      ,act_info28             varchar2(300)
      ,act_info29             varchar2(300)
      ,act_info30             varchar2(300)
     );

     TYPE action_info_table IS TABLE OF act_info_rec
     INDEX BY BINARY_INTEGER;

     ltr_ppa_arch_data       action_info_table;
     ltr_ppa_arch_er_data    action_info_table;
     ltr_ppa_arch_ee_data    action_info_table;
     ltr_ppa_arch_ee_data2   action_info_table;
     ltr_ppa_arch_ee_ft_data action_info_table;

TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
TYPE number_data_type_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;

g_min_chunk            number      := -1;
g_archive_flag         varchar2(1) := 'N';
g_rl2_last_slip_number number      := 0;

end pay_ca_eoy_rl2_archive;

/
