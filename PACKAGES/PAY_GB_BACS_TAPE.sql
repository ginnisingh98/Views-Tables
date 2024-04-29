--------------------------------------------------------
--  DDL for Package PAY_GB_BACS_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_BACS_TAPE" AUTHID CURRENT_USER AS
/* $Header: pytapbac.pkh 120.1.12010000.3 2009/07/07 14:27:04 namgoyal ship $ */
/*
 * ***************************************************************************

  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All Rights Reserved.

  PRODUCT
    Oracle*Payroll

  NAME


  DESCRIPTION
    Magnetic tape format procedure.

1.0 Overview

  A PL/SQL package will be written for each type of magnetic tape. The package
  will include all cursors and procedures required for the particular magnetic
  tape format. A stored procedure provides the top level of control flow for
  the magnetic tape file generation. This may call other procedures dependant
  on the state of the cursors and the input parameters.

  The stored procedure will be called before each execution of a
  formula. Parameters returned as results of the previous formula execution
  will be passed to the procedure. The procedure must handle all context
  cursors needed and may also set parameters required by the formula.

  Using NACHA as an example, for the file header record formula, a call
  to a cursor which fetches legal_company_id must be performed.

  The interface between the 'C' process and the stored procedure will make
  extensive use of PL/SQL tables. PL/SQL tables are single column tables which
  are accessed by an integer index value. Items in the tables will use indexes
  begining with 1 and increasing contiguously to the number of elements. The
  index number will be used to match items in the name and value tables.

  The first element in the value tables will always be the number of elements
  available in the table. The elements in the tables will be of type VARCHAR2
  any conversion necessary should be performed within the PL/SQL procedure.

  The parameters returned by formula execution will be passed
  to the stored procedure. Parameters may or may not be altered by the PL/SQL
  procedure and will be passed back to the formula for the next execution.
  Context tables will always be reset by the PL/SQL procedure.

  The names of the tables used to interface with the PL/SQL procedure are
       param_names     type IN/OUT
       param_values    type IN/OUT
       context_names   type OUT
       context_values  type OUT

  The second item in the output_parameter_value table will be the formula ID
  of the next formula to be executed (the first item is the number of values
  in the table).

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    30-JUN-95   ASNELL        40.0               Created.
    30-JUN-95   NBRISTOW      40.1               Modified to use PL/SQL tables
                                                 to pass parameter and
                                                 and context rule data.
    29-AUG-95   NBRISTOW      40.2               Added cursors for the single
                                                 day single file format.
    30-JUL-96   JALLOUN       40.3               Added error handling.
    16-JUL-97   APARKES       40.15   513830     Added ORG_PAY_METHOD_ID
                                                 Context to %_bacs_payment_method_id
                                                 cursors.
    02-DEC-97   APARKES       40.16   572919     changed sub-selects in the
                                                 %m_bacs_payment% cursors to project
                                                 1 instead of '' as this was causing
                                                 only one assignment per processing
                                                 day to be reported in R11.
    19-DEC-97   APARKES       40.17   572940     Added correlated subqueries to the
                                      593757     %m_bacs_payment% cursors to ensure
                                                 that only one payment is made per
                                                 assignment when pre-payments are run
                                                 across multiple payroll runs.
    23-FEB-97   APARKES       40.18   619733     Corrected cursors
                                                 %m_bacs_payment_method_id to
                                                 order by process date within
                                                 payment method id.
    22-APR-98   ARUNDELL     110.4    641673     Changes to sm_bacs_payment_method_id
                                                 and sm_bacs_payment for multiday
                                                 performance improvements.
    23-JUL-98   APARKES      110.6    641673     Further performance fixes to
                                                 all formats.
    03-DEC-98   FDUCHENE     110.7    749168     Changes to sm_bacs_payment_method_id
                                                 and s_bacs_payment_method_id for
                                                 enabling BACS to report in Euros.
                                                 Other cursors involved :
                                                 ms_bacs_header, m_bacs_header,
                                                 m_bacs_payment_method_id,
                                                 and ms_bacs_payment_method_id.
    15-FEB-00   SMROBINS     115.4   1071880     Handle date parameters in canonical
                                                 format.
    25-FEB-00   SMROBINS     115.5   1071880     Change to sm_bacs_payment_method_id
                                                 and m_bacs_payment_method_id handle
                                                 date parameters in canonical format
    06-MAR-02	GBUTLER	     115.6		 Added dbdrv comments
    22-JUL-02   AMILLS       115.7   2466221     fix to sm_bacs_payment cursor for
                                                 Canonical date conversion.
    08-JAN-03   GBUTLER      115.8   2665685     Performance enhancements to cursors
    						 sm_bacs_payment_method_id,
    						 m_bacs_payment_method_id,
    						 ms_bacs_payment_method_id,
    						 s_bacs_payment_method_id
    26-AUG-04   KTHAMPAN     115.9               Change to s_bacs_header, sm_bacs_header,
                                                 ms_bacs_header and m_bacs_header to
                                                 return the bacs format type
    07-SEP-06   NPERSHAD     115.11   5514457    Modified the sort sequence.
    14-JUL-08   PVELUGUL     115.12   6689591    Modified for 6689591.
    07-Jul-09   NAMGOYAL     115.13   8505257    Added Cash Management Reconciliation
                                                 function
  Package header:
*/
--Single file single day
-- Cursors
--
  CURSOR s_bacs_header IS
  select 'TRANSFER_EFFECTIVE_DATE=P',
    to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
    'DATE_EARNED=C',
    to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
    'ORG_PAY_METHOD_ID=C',
    min(ppp.org_payment_method_id),
    'TRANSFER_TODAYS_DATE=P',
    to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
    'TRANSFER_BACS_PROCESS_DATE=P',
    to_char(ppa.overriding_dd_date, 'YYYY/MM/DD HH24:MI:SS'),
    'TRANSFER_FORMAT_TYPE=P',
    substr(ppa.LEGISLATIVE_PARAMETERS,instr(LEGISLATIVE_PARAMETERS,'FORMAT_TYPE=')+12,1)
  from fnd_sessions                         fnd,
       pay_pre_payments                     ppp,
       pay_assignment_actions               paa,
       pay_payroll_actions                  ppa
  where paa.payroll_action_id =
            pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppp.pre_payment_id = paa.pre_payment_id
  and   fnd.session_id = userenv('sessionid')
  group by fnd.effective_date, sysdate, ppa.overriding_dd_date,ppa.legislative_parameters;
--
  CURSOR s_bacs_payment_method_id IS
  SELECT /*+ ORDERED */ DISTINCT 'TRANSFER_ORG_PAY_METHOD=P',
                  ppp.org_payment_method_id,
                  'ORG_PAY_METHOD_ID=C',
                  ppp.org_payment_method_id,
                  'TRANSFER_USER_NUMBER=P',
                  popm.pmeth_information1,
                  'TRANSFER_CURRENCY_CODE=P',
                  popm.currency_code,
                  'ORG_PAY_METHOD_NAME=P',
                  popm.ORG_PAYMENT_METHOD_NAME
  from  pay_assignment_actions paa,
        pay_pre_payments       ppp,
        pay_org_payment_methods popm
  WHERE  paa.payroll_action_id =
           pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  AND    ppp.pre_payment_id    = paa.pre_payment_id
  AND    ppp.org_payment_method_id = popm.org_payment_method_id
  ORDER  by ppp.org_payment_method_id;
--
  CURSOR s_bacs_payment IS
  select 'TRANSFER_VALUE=P',
         ROUND(ppp.value,2) * 100, /*BUG:6689591*/
         'TRANSFER_ASSIGN_NO=P',
         pa.assignment_number,
         'PER_PAY_METHOD_ID=C',
         ppp.personal_payment_method_id,
         'TRANSFER_ASG_ACTION_ID=P',
         paa.assignment_action_id
  from   pay_external_accounts        pea,
         pay_personal_payment_methods ppm,
         per_assignments              pa,
         pay_pre_payments             ppp,
         pay_assignment_actions       paa
  where  paa.payroll_action_id          =
                  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    paa.pre_payment_id             = ppp.pre_payment_id
  and    paa.assignment_id              = pa.assignment_id
  and    ppp.org_payment_method_id +0   =
            pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METHOD')
  and    ppp.personal_payment_method_id = ppm.personal_payment_method_id
  and    ppm.external_account_id        = pea.external_account_id
  order by  decode(pay_magtape_generic.get_parameter_value('SET_ORDER_BY'),
                                     'A', pa.assignment_number,
                                     'S', pea.segment3||pea.segment5,
                                     'E', pea.segment5, null);
--
-- Single file multi day
--
-- Cursors
--
--
  CURSOR sm_bacs_header IS
  select 'ORG_PAY_METHOD_ID=C',
         min(ppp.org_payment_method_id),
         'TRANSFER_EFFECTIVE_DATE=P',
         to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
         'DATE_EARNED=C',
         to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
         'TRANSFER_TODAYS_DATE=P',
         to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
         'TRANSFER_BACS_PROCESS_DATE=P',
         to_char(ppa.overriding_dd_date, 'YYYY/MM/DD HH24:MI:SS'),
         'TRANSFER_BACS_PROCESS_DATE2=P',
         to_char(ppa.overriding_dd_date, 'YYDDD'),
         'TRANSFER_FORMAT_TYPE=P',
         substr(ppa.LEGISLATIVE_PARAMETERS,instr(LEGISLATIVE_PARAMETERS,'FORMAT_TYPE=')+12,1)
  from   fnd_sessions           fnd,
         pay_pre_payments       ppp,
         pay_assignment_actions paa,
         pay_payroll_actions    ppa
  where  paa.payroll_action_id =
            pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppp.pre_payment_id = paa.pre_payment_id
  and   fnd.session_id = userenv('sessionid')
  group by  fnd.effective_date, sysdate, ppa.overriding_dd_date,ppa.legislative_parameters;
--
  CURSOR sm_bacs_payment_method_id IS
  SELECT /*+ ORDERED */ DISTINCT 'TRANSFER_ORG_PAY_METHOD=P',
                  ppp.org_payment_method_id,
                  'ORG_PAY_METHOD_ID=C',
                  ppp.org_payment_method_id,
                  'TRANSFER_PER_PROCESS_DATE=P',
                  to_char(greatest(to_date(prrv.result_value, 'YYYY/MM/DD HH24:MI:SS'),
                    to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
                  to_char(greatest(to_date(prrv.result_value, 'YYYY/MM/DD HH24:MI:SS'),
                    to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
                  'TRANSFER_PER_PROCESS_DATE2=P',
                  to_char(greatest(to_date(prrv.result_value, 'YYYY/MM/DD HH24:MI:SS'),
                    to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYDDD'),
                  'TRANSFER_USER_NUMBER=P',
                  popm.pmeth_information1,
                  'TRANSFER_CURRENCY_CODE=P',
                  popm.currency_code,
                  'ORG_PAY_METHOD_NAME=P',
                  popm.ORG_PAYMENT_METHOD_NAME
  from  pay_assignment_actions     paa,
        pay_pre_payments           ppp,
        pay_org_payment_methods    popm,
        pay_run_results            prr,
        pay_element_types          pet,
        pay_run_result_values      prrv,
        pay_input_values           piv
  where  paa.payroll_action_id =
            pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    prr.assignment_action_id =
          (select max(locked_action_id)
           from pay_action_interlocks pai
           where ppp.assignment_action_id=pai.locking_action_id
          )
  and    prrv.run_result_id   = prr.run_result_id
                                  + decode(pet.element_type_id,0,0,0)
  and    pet.element_type_id  = prr.element_type_id
  and    pet.element_name     = 'BACS Process Date'
  and    piv.input_value_id   = prrv.input_value_id
  and    piv.name             = 'Process Date'
  and    ppp.pre_payment_id   = paa.pre_payment_id
  and    ppp.org_payment_method_id = popm.org_payment_method_id
  union
  select DISTINCT 'TRANSFER_ORG_PAY_METHOD=P',
                  ppp.org_payment_method_id,
                  'ORG_PAY_METHOD_ID=C',
                  ppp.org_payment_method_id,
                  'TRANSFER_PER_PROCESS_DATE=P',
                  to_char(greatest(ptp.default_dd_date,
                    to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
                  to_char(greatest(ptp.default_dd_date,
                    to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
                  'TRANSFER_PER_PROCESS_DATE2=P',
                  to_char(greatest(ptp.default_dd_date,
                    to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYDDD'),
                  'TRANSFER_USER_NUMBER=P',
                  popm.pmeth_information1,
                  'TRANSFER_CURRENCY_CODE=P',
                  popm.currency_code,
                  'ORG_PAY_METHOD_NAME=P',
                  popm.ORG_PAYMENT_METHOD_NAME
  from  per_time_periods           ptp,
        pay_payroll_actions        ppa,
        pay_assignment_actions     paa2,
        pay_org_payment_methods    popm,
        pay_pre_payments           ppp,
        pay_assignment_actions     paa
  where paa.payroll_action_id =
          pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   ppp.pre_payment_id    = paa.pre_payment_id
  and   paa2.assignment_action_id =
          (select max(locked_action_id)
           from pay_action_interlocks pai
           where ppp.assignment_action_id=pai.locking_action_id
          )
  and   not exists (select 1
             from   pay_element_types pet,
                    pay_run_results   prr
             where  prr.assignment_action_id = paa2.assignment_action_id
             and    pet.element_type_id      = prr.element_type_id
             and    pet.element_name         = 'BACS Process Date')
  and   paa2.payroll_action_id = ppa.payroll_action_id
  and   ppa.time_period_id     = ptp.time_period_id
  and   ppp.org_payment_method_id = popm.org_payment_method_id
  order  by  2, 7;
--
  CURSOR sm_bacs_payment IS
  select
        'TRANSFER_VALUE=P',
        ROUND(oppp.value,2) * 100, /*BUG:6689591*/
        'TRANSFER_ASSIGN_NO=P',
        opa.assignment_number,
        'PER_PAY_METHOD_ID=C',
        oppp.personal_payment_method_id,
        'TRANSFER_ASG_ACTION_ID=P',
        opaa.assignment_action_id
  from  pay_external_accounts             opea,
        pay_personal_payment_methods      oppm,
        per_assignments                   opa,
        pay_pre_payments                  oppp,
        pay_assignment_actions            opaa
  where opaa.payroll_action_id =
          pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   opa.assignment_id               = opaa.assignment_id
  and   opaa.pre_payment_id             = oppp.pre_payment_id
  and   oppp.org_payment_method_id +0   =
          pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METHOD')
  and   oppm.personal_payment_method_id = oppp.personal_payment_method_id
  and   opea.external_account_id        = oppm.external_account_id
  and exists (
       select 1
       from  pay_input_values      piv,
             pay_run_result_values prrv,
             pay_element_types     pet,
             pay_run_results       prr
       where prr.assignment_action_id       =
                 (select max(pai.locked_action_id)
                  from pay_action_interlocks pai
                  where oppp.assignment_action_id=pai.locking_action_id
                 )
       and   prrv.run_result_id  = prr.run_result_id
                                     + decode(pet.element_type_id,0,0,0)
       and   pet.element_type_id = prr.element_type_id
       and   pet.element_name    = 'BACS Process Date'
       and   piv.input_value_id  = prrv.input_value_id
       and   piv.name            = 'Process Date'
       and   (to_date(pay_magtape_generic.get_parameter_value(
                  'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
                           = to_date(prrv.result_value,'YYYY/MM/DD HH24:MI:SS')
              OR (
                to_date(prrv.result_value,'YYYY/MM/DD HH24:MI:SS') <
                  to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
                AND to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS') =
                  to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
              )
             )
       union
       select 1
       from
              per_time_periods       ptp,
              pay_payroll_actions    ppa,
              pay_assignment_actions paa
       where  paa.assignment_action_id =
                 (select max(pai.locked_action_id)
                  from pay_action_interlocks pai
                  where oppp.assignment_action_id=pai.locking_action_id
                 )
       and    paa.payroll_action_id = ppa.payroll_action_id
       and    ppa.payroll_id        = ptp.payroll_id
       and    ppa.time_period_id    = ptp.time_period_id
       and    (ptp.default_dd_date  =
                to_date(pay_magtape_generic.get_parameter_value(
                  'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
              or (pay_magtape_generic.get_parameter_value(
                    'TRANSFER_PER_PROCESS_DATE') =
                  pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE')
                and to_date(pay_magtape_generic.get_parameter_value(
                  'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
                    > ptp.default_dd_date))
       and    not exists (select 1
               from pay_element_types   pet,
                    pay_run_results     prr
               where  prr.assignment_action_id = paa.assignment_action_id
               and    pet.element_type_id      = prr.element_type_id
               and    pet.element_name         = 'BACS Process Date')
        )
  order by  decode(pay_magtape_generic.get_parameter_value('SET_ORDER_BY'),
                                       'A', opa.assignment_number,
                                       'S', opea.segment3||opea.segment5,
                                       'E', opea.segment5, null);
--
--
--Multi file single day
-- Cursors
--
  CURSOR ms_bacs_vol IS
  select distinct
         'DATE_EARNED=C',
         to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
         'TRANSFER_EFFECTIVE_DATE=P',
         to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
         'TRANSFER_FIRST_BUREAU_NO=P',
         org.pmeth_information3,
         'TRANSFER_FORMAT_TYPE=P',
         substr(ppa.LEGISLATIVE_PARAMETERS,instr(LEGISLATIVE_PARAMETERS,'FORMAT_TYPE=')+12,1)
  from   fnd_sessions fnd,
         PAY_ORG_PAYMENT_METHODS org,
         pay_pre_payments ppp,
         pay_assignment_actions paa,
         pay_payroll_actions ppa
  where  paa.payroll_action_id =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    ppp.pre_payment_id = paa.pre_payment_id
  and    ppp.org_payment_method_id = org.org_payment_method_id
  and    fnd.session_id = userenv('sessionid');
--
  CURSOR ms_bacs_header IS
  select      'TRANSFER_EFFECTIVE_DATE=P',
               to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
              'BACS_TAPE_BACS_USER_NUMBER=P',
               org.pmeth_information1,
              'ORG_PAY_METHOD_ID=C',
              min(ppp.org_payment_method_id),
              'TRANSFER_TODAYS_DATE=P',
              to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
              'TRANSFER_BACS_PROCESS_DATE=P',
               to_char(ppa.overriding_dd_date, 'YYYY/MM/DD HH24:MI:SS'),
              'TRANSFER_CURRENCY_CODE=P',
              org.currency_code,
              'ORG_PAY_METHOD_NAME=P',
              min(org.org_payment_method_name)
  from         fnd_sessions fnd,
               pay_org_payment_methods org,
               pay_pre_payments ppp,
               pay_assignment_actions paa,
               pay_payroll_actions ppa
  where        paa.payroll_action_id =
                  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and          ppa.payroll_action_id = paa.payroll_action_id
  and          ppp.pre_payment_id = paa.pre_payment_id
  and          org.org_payment_method_id = ppp.org_payment_method_id
  and          fnd.session_id = userenv('sessionid')
  group by     org.pmeth_information1,fnd.effective_date,
               sysdate, ppa.overriding_dd_date, org.currency_code
  order by     4, 12;
--
  CURSOR ms_bacs_payment_method_id IS
  SELECT    /*+ ORDERED */ DISTINCT 'TRANSFER_ORG_PAY_METHOD=P',
                      ppp.org_payment_method_id,
                      'ORG_PAY_METHOD_ID=C',
                      ppp.org_payment_method_id,
                      'TRANSFER_BUREAU_NO=P',
                      org.pmeth_information3,
                      'ORG_PAY_METHOD_NAME=P',
                      org.org_payment_method_name
  FROM       pay_assignment_actions paa,
             pay_pre_payments ppp,
             pay_org_payment_methods org
  WHERE      org.currency_code =
              pay_magtape_generic.get_parameter_value('TRANSFER_CURRENCY_CODE')
  and 	 paa.payroll_action_id =
              pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  AND        ppp.pre_payment_id = paa.pre_payment_id
  and        ppp.org_payment_method_id    = org.org_payment_method_id
  and        org.pmeth_information1 =
             pay_magtape_generic.get_parameter_value('BACS_TAPE_BACS_USER_NUMBER')
  ORDER  by  ppp.org_payment_method_id;
--
  CURSOR ms_bacs_payment IS
  select    'TRANSFER_VALUE=P',
             ROUND(ppp.value,2) * 100, /*BUG:6689591*/
            'TRANSFER_ASSIGN_NO=P',
             pa.assignment_number,
            'PER_PAY_METHOD_ID=C',
             ppp.personal_payment_method_id,
            'TRANSFER_ASG_ACTION_ID=P',
             paa.assignment_action_id
  from       pay_assignment_actions       paa,
             pay_pre_payments             ppp,
             per_assignments              pa,
             pay_personal_payment_methods ppm,
             pay_external_accounts        pea
  where      paa.payroll_action_id          =
                   pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and        paa.pre_payment_id             = ppp.pre_payment_id
  and        paa.assignment_id              = pa.assignment_id
  and        ppp.org_payment_method_id +0   =
              pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METHOD')
  and        ppp.personal_payment_method_id = ppm.personal_payment_method_id
  and        ppm.external_account_id        = pea.external_account_id
  order by   decode(pay_magtape_generic.get_parameter_value('SET_ORDER_BY'),
              'A', pa.assignment_number, 'S', pea.segment3||pea.segment5, 'E', pea.segment5, null);
--
--
-- Multi file multi day
-- Cursors
--
  CURSOR m_bacs_vol IS
  select distinct
    'DATE_EARNED=C',
    to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
    'TRANSFER_EFFECTIVE_DATE=P',
    to_char(fnd.effective_date, 'YYYY/MM/DD HH24:MI:SS') ,
    'TRANSFER_FIRST_BUREAU_NO=P',
    org.pmeth_information3,
    'TRANSFER_FORMAT_TYPE=P',
    substr(ppa.LEGISLATIVE_PARAMETERS,instr(LEGISLATIVE_PARAMETERS,'FORMAT_TYPE=')+12,1)
  from  fnd_sessions fnd,
        PAY_ORG_PAYMENT_METHODS org,
        pay_pre_payments ppp,
        pay_payroll_actions ppa,
        pay_assignment_actions paa
  where paa.payroll_action_id =
          pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   ppa.payroll_action_id     = paa.payroll_action_id
  and   ppp.pre_payment_id        = paa.pre_payment_id
  and   ppp.org_payment_method_id = org.org_payment_method_id
  and   fnd.session_id            = userenv('sessionid');
--
  CURSOR m_bacs_header IS
  select  'BACS_TAPE_BACS_USER_NUMBER=P',
          org.pmeth_information1,
          'ORG_PAY_METHOD_ID=C',
          min(ppp.org_payment_method_id),
          'TRANSFER_TODAYS_DATE=P',
          to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
          'TRANSFER_BACS_PROCESS_DATE=P',
          to_char(ppa.overriding_dd_date, 'YYYY/MM/DD HH24:MI:SS'),
          'TRANSFER_BACS_PROCESS_DATE2=P',
          to_char(ppa.overriding_dd_date, 'YYDDD'),
	  'TRANSFER_CURRENCY_CODE=P',
          org.currency_code,
          'ORG_PAY_METHOD_NAME=P',
          min(org.org_payment_method_name)
  from fnd_sessions fnd,
       pay_org_payment_methods               org,
       pay_pre_payments                      ppp,
       pay_payroll_actions                   ppa,
       pay_assignment_actions                paa
  where paa.payroll_action_id =
            pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   ppa.payroll_action_id     = paa.payroll_action_id
  and   ppp.pre_payment_id        = paa.pre_payment_id
  and   org.org_payment_method_id = ppp.org_payment_method_id
  and   fnd.session_id            = userenv('sessionid')
  group by  org.pmeth_information1,fnd.effective_date,
            sysdate, ppa.overriding_dd_date, org.currency_code
  order by 2, 12;
--
  CURSOR m_bacs_payment_method_id IS
  SELECT /*+ ORDERED */ DISTINCT
    'TRANSFER_ORG_PAY_METHOD=P',
    ppp.org_payment_method_id,
    'ORG_PAY_METHOD_ID=C',
    ppp.org_payment_method_id,
    'TRANSFER_PER_PROCESS_DATE=P',
    to_char(greatest(to_date(prrv.result_value, 'YYYY/MM/DD HH24:MI:SS'),
     to_date(pay_magtape_generic.get_parameter_value(
      'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
    to_char(greatest(to_date(prrv.result_value, 'YYYY/MM/DD HH24:MI:SS'),
     to_date(pay_magtape_generic.get_parameter_value(
      'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
    'TRANSFER_PER_PROCESS_DATE2=P',
    to_char(greatest(to_date(prrv.result_value, 'YYYY/MM/DD HH24:MI:SS'),
     to_date(pay_magtape_generic.get_parameter_value(
      'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYDDD'),
    'TRANSFER_BUREAU_NO=P',
    org.pmeth_information3,
    'ORG_PAY_METHOD_NAME=P',
    org.org_payment_method_name
  from  pay_assignment_actions     paa,
        pay_pre_payments           ppp,
        pay_org_payment_methods    org,
        pay_run_results            prr,
        pay_element_types          pet,
        pay_run_result_values      prrv,
        pay_input_values           piv
  where org.currency_code =
          pay_magtape_generic.get_parameter_value('TRANSFER_CURRENCY_CODE')
  and     paa.payroll_action_id        =
                  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   ppp.pre_payment_id           = paa.pre_payment_id
  and   ppp.org_payment_method_id    = org.org_payment_method_id
  and   org.pmeth_information1       =
          pay_magtape_generic.get_parameter_value('BACS_TAPE_BACS_USER_NUMBER')
  and   prr.assignment_action_id     =
              (select max(locked_action_id)
                         + decode(org.org_payment_method_id,0,0,0)
               from pay_action_interlocks pai
               where ppp.assignment_action_id=pai.locking_action_id
              )
  and   pet.element_type_id = prr.element_type_id
  and   pet.element_name    = 'BACS Process Date'
  and   prrv.run_result_id  = prr.run_result_id
                                + decode(pet.element_type_id,0,0,0)
  and   piv.input_value_id  = prrv.input_value_id
  and   piv.name            = 'Process Date'
  union
  select DISTINCT
    'TRANSFER_ORG_PAY_METHOD=P',
    ppp.org_payment_method_id,
    'ORG_PAY_METHOD_ID=C',
    ppp.org_payment_method_id,
    'TRANSFER_PER_PROCESS_DATE=P',
    to_char(greatest(ptp.default_dd_date,
      to_date(pay_magtape_generic.get_parameter_value(
      'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
    to_char(greatest(ptp.default_dd_date,
      to_date(pay_magtape_generic.get_parameter_value(
      'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'),
    'TRANSFER_PER_PROCESS_DATE2=P',
    to_char(greatest(ptp.default_dd_date,
      to_date(pay_magtape_generic.get_parameter_value(
      'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')), 'YYDDD'),
    'TRANSFER_BUREAU_NO=P', org.pmeth_information3,
    'ORG_PAY_METHOD_NAME=P', org.org_payment_method_name
  from  per_time_periods           ptp,
        pay_payroll_actions        ppa,
        pay_assignment_actions     paa2,
        pay_org_payment_methods    org,
        pay_pre_payments           ppp,
        pay_assignment_actions     paa
  where org.currency_code =
          pay_magtape_generic.get_parameter_value('TRANSFER_CURRENCY_CODE')
  and        paa.payroll_action_id        =
          pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and   ppp.pre_payment_id           = paa.pre_payment_id
  and   ppp.org_payment_method_id    = org.org_payment_method_id
  and   org.pmeth_information1       =
          pay_magtape_generic.get_parameter_value('BACS_TAPE_BACS_USER_NUMBER')
  and   paa2.assignment_action_id    =
          (select max(locked_action_id)
                + decode(org.org_payment_method_id,0,0,0)
           from pay_action_interlocks pai
           where ppp.assignment_action_id=pai.locking_action_id
          )
  and   not exists (select 1
          from     pay_element_types   pet,
                   pay_run_results     prr
          where    prr.assignment_action_id = paa2.assignment_action_id
          and      pet.element_type_id      = prr.element_type_id
          and      pet.element_name         = 'BACS Process Date')
  and   paa2.payroll_action_id       = ppa.payroll_action_id
  and   ppa.time_period_id           = ptp.time_period_id
  order by  2, 7;
--
 CURSOR m_bacs_payment IS
select
         'TRANSFER_VALUE=P',
         ROUND(oppp.value,2) * 100,/* BUG:6689691*/
         'TRANSFER_ASSIGN_NO=P',
         opa.assignment_number,
         'PER_PAY_METHOD_ID=C',
         oppp.personal_payment_method_id,
         'TRANSFER_ASG_ACTION_ID=P',
         opaa.assignment_action_id
from
       pay_external_accounts             opea,
       pay_personal_payment_methods      oppm,
       per_assignments                   opa,
       pay_pre_payments                  oppp,
       pay_assignment_actions            opaa
where opaa.payroll_action_id =
            pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and   opa.assignment_id               = opaa.assignment_id
and   opaa.pre_payment_id             = oppp.pre_payment_id
and   oppp.org_payment_method_id      =
          pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METHOD')
and   oppm.personal_payment_method_id = oppp.personal_payment_method_id
and   opea.external_account_id        = oppm.external_account_id
  and exists (
       select 1
       from  pay_input_values      piv,
             pay_run_result_values prrv,
             pay_element_types     pet,
             pay_run_results       prr
       where prr.assignment_action_id       =
                 (select max(pai.locked_action_id)
                  from pay_action_interlocks pai
                  where oppp.assignment_action_id=pai.locking_action_id
                 )
       and   prrv.run_result_id  = prr.run_result_id
                                     + decode(pet.element_type_id,0,0,0)
       and   pet.element_type_id = prr.element_type_id
       and   pet.element_name    = 'BACS Process Date'
       and   piv.input_value_id  = prrv.input_value_id
       and   piv.name            = 'Process Date'
       and   (to_date(pay_magtape_generic.get_parameter_value(
                  'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
                           = to_date(prrv.result_value,'YYYY/MM/DD HH24:MI:SS')
              OR (
                to_date(prrv.result_value,'YYYY/MM/DD HH24:MI:SS') <
                  to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
                AND to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS') =
                  to_date(pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
              )
             )
       union
       select 1
       from
              per_time_periods       ptp,
              pay_payroll_actions    ppa,
              pay_assignment_actions paa
       where  paa.assignment_action_id =
                 (select max(pai.locked_action_id)
                  from pay_action_interlocks pai
                  where oppp.assignment_action_id=pai.locking_action_id
                 )
       and    paa.payroll_action_id = ppa.payroll_action_id
       and    ppa.payroll_id        = ptp.payroll_id
       and    ppa.time_period_id    = ptp.time_period_id
       and    (ptp.default_dd_date  =
                to_date(pay_magtape_generic.get_parameter_value(
                  'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
              or (pay_magtape_generic.get_parameter_value(
                    'TRANSFER_PER_PROCESS_DATE') =
                  pay_magtape_generic.get_parameter_value(
                    'TRANSFER_BACS_PROCESS_DATE')
                and to_date(pay_magtape_generic.get_parameter_value(
                  'TRANSFER_PER_PROCESS_DATE'),'YYYY/MM/DD HH24:MI:SS')
                    > ptp.default_dd_date))
       and    not exists (select 1
               from pay_element_types pet,
                    pay_run_results   prr
               where  prr.assignment_action_id = paa.assignment_action_id
               and    pet.element_type_id      = prr.element_type_id
               and    pet.element_name         = 'BACS Process Date')
        )
order by  decode(pay_magtape_generic.get_parameter_value('SET_ORDER_BY'),
                                     'A', opa.assignment_number,
                                     'S', opea.segment3||opea.segment5,
                                     'E', opea.segment5, null);
--
--
  level_cnt number;
--
  PROCEDURE new_formula;
--
  FUNCTION get_process_date(p_assignment_action_id in number,
                            p_entry_date           in date)
  return date;
  FUNCTION validate_process_date(p_assignment_action_id in number,
                                 p_process_date           in date)
  return date;

  --Cash Management Reconciliation function
  FUNCTION f_get_eft_recon_data (p_effective_date       IN DATE,
			        p_identifier_name       IN VARCHAR2,
			        p_payroll_action_id	IN NUMBER,
				p_payment_type_id	IN NUMBER,
				p_org_payment_method_id	IN NUMBER,
				p_personal_payment_method_id	IN NUMBER,
				p_assignment_action_id	IN NUMBER,
				p_pre_payment_id	IN NUMBER,
				p_delimiter_string   	IN VARCHAR2)
 RETURN VARCHAR2;

--
END pay_gb_bacs_tape;

/
