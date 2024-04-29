--------------------------------------------------------
--  DDL for Package PAY_CA_PAYROLL_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_PAYROLL_ARCH" AUTHID CURRENT_USER as
/* $Header: pycapyar.pkh 120.0.12010000.1 2008/07/27 22:15:25 appldev ship $ */
--
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
   16-AUG-2001  vpandya     115.0            Created.
   22-Jan-2002  vpandya     115.1            Added dbdrv to meet new standard.
   23-Jan-2002  vpandya     115.2            Replace variable p_assactid with
                                             p_xfr_action_id in archive_data
   12-Jun-2002  vpandya     115.3            Added PL/SQL table, to populate
                                             Tax data and one variable
                                             gv_jurisdiction_cd.
   17-Jun-2002  vpandya     115.4            Added jurisdiction_cd column in
                                             def_bal PL/SQL table.
   18-Feb-2003  vpandya     115.5            Added nocopy for gscc.
   10-Mar-2003  vpandya     115.6            Added variables
                                             gn_gross_earn_def_bal_id and
                                             gn_payments_def_bal_id.
   02-Aug-2004  ssattini    115.7  3498653   Added run_def_bal_id column in
                                             def_bal PL/SQL table.
*/
--

  PROCEDURE py_range_cursor( p_payroll_action_id in number
                            ,p_sqlstr           out nocopy varchar2);

  PROCEDURE py_action_creation( p_payroll_action_id   in number
                               ,p_start_assignment_id in number
                               ,p_end_assignment_id   in number
                               ,p_chunk               in number);

  PROCEDURE py_archive_data(p_xfr_action_id  in number,
                            p_effective_date in date);


  PROCEDURE py_archinit(p_payroll_action_id in number);

  TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
  TYPE number12_2_data_type_table IS TABLE OF NUMBER(15,2)
                                  INDEX BY BINARY_INTEGER;

  TYPE def_bal  IS RECORD ( bal_name            varchar2(240),
                            disp_sequence       number(10),
                            bal_type_id         number(10),
                            pymt_def_bal_id     number(10),
                            gre_ytd_def_bal_id  number(10),
                            tg_ytd_def_bal_id   number(10),
                            run_def_bal_id      number(10),
                            jurisdiction_cd     varchar2(30));

  TYPE def_bal_tbl IS TABLE OF def_bal INDEX BY BINARY_INTEGER;

  TYPE tax_name IS RECORD ( language            varchar2(30),
                            lookup_code         varchar2(30),
                            meaning             varchar2(80));

  TYPE tax_tbl IS TABLE OF tax_name INDEX BY BINARY_INTEGER;

  g_min_chunk    number:= -1;
  g_archive_flag varchar2(1) := 'N';
  g_bal_act_id   number:= -1;

  gn_gross_earn_def_bal_id  number := 0;
  gn_payments_def_bal_id    number := 0;

  gv_jurisdiction_cd varchar2(30) := NULL;

end pay_ca_payroll_arch;

/
