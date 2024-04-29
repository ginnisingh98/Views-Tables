--------------------------------------------------------
--  DDL for Package PAY_US_NACHA_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_NACHA_TAPE" AUTHID CURRENT_USER AS
/* $Header: pytapnac.pkh 120.0.12010000.4 2009/11/20 10:30:38 mikarthi ship $ */
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

  Name        : pay_us_nacha_tape

  Description : This package holds building blocks used in the generation
                of nacha Tape.

  Uses        : hr_utility

  Change List
  -----------
  Date        Name     Vers    Bug No   Description
  ----        ----      -----  -------  -----------
  JUL-23-1993 RMAMGAIN 1.0              Created with following proc.
                                          . run_formula
  15-May-95   RFine    40.3	        Changed 'show errors' from
                                        package body to package.
  28-JUN-1995 NBRISTOW 40.4             Package now uses PL/SQL
                                        tables to interface with
                                        the C process.
  17-Apr-1996 ALLEE                     Added more global variables
                                        to support padding functionality
  24-JUL-1996 allee                     Fixed org_flex cursor to account
                                        for consolidation sets.
                                        Added gloabl variables.
  01-MAR-1998 EKIM     40.10            Modified CURSOR csr_org_flex_info
  17-MAY-2000 DSCULLY                   Added support for child care addenda
                                        records. Removed cursors
                                        csr_org_pay_method and
                                        csr_leg_comp in favor of one cursor,
                                        csr_nacha_batch which does both
                                        queries.
  17-JUN-2000 DSCULLY	                Added g_addenda_count

  ****************************************************************************
  Due to extensive changes in the 11.0 version, and little difference between
  the previous 11.0 version and the 11.5 version, we are taking the modified
  11.0 version and redoing the changes made in earlier revisions of the 11.5
  version
  ****************************************************************************

  17-JUN-2000 DSCULLY  115.2            Updated the 11.0 version into the 11.5
                                        codetree
  15-AUG-2000 ahanda   115.4            Changed the Format mask for g_time
                                        from HHMMto HHMI
  05-DEC-2000 ahanda   115.5            Added the RULE Hint to the cursor
                                        csr_assignments. Also changed cursor
                                        to use exists clause.
  09-JUL-2001 MESHAH   115.6            Direct join in csr_org_flex_info
                                        between pay_payroll_actions and
                                        pay_payrolls_f.
  19-JUL-2001 MESHAH   115.7  1357404   changed cursor csr_assignments to
                                        include rowid as a parameter for the
                                        cursor, as a select value in the
                                        query and in the where clause.
                                        Also declared 3 new global variables.
  27-JUL-2001 MESHAH   115.8            new parameter g_test_file.
  31-AUG-2001 MESHAH   115.9            new parameter g_reset_greid.
  20-DEC-2002 MESHAH   115.10 2714155   changed csr_nacha_batch to remove a
                                        cartesian join for 1159.
  18-FEB-2004 kvsankar 115.11 3331019   Added cursor csr_assignments_no_rule,
                                        equivalent to cursor csr_assignments,
                                        but doesnt use RULE hint.
                                        (as part of 10G certification).
  06-MAY-2004 svmadira 115.12 3587226   Commented the sub query from
                                        csr_assignments cursor for improving
                                        performance of the  process.
  06-JUL-2004 ahanda   115.13           Added third_party flag to cursor
                                        csr_org_flex_info and changed
                                        business_group_id initialize from
                                        '0' to null.
  05-Aug-2009 kagangul 115.14	        Added function f_get_batch_transact_ident
					for supporting the EFT reconciliation.
  08-Aug-2009 mikarthi 115.15	        Modifications for Nacha IAT enhancement
  *****************************************************************************/

  -- Global Variable for the Package

    TYPE tt_used_results IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  g_used_results_tab	    tt_used_results;
  g_effective_date         date  := null;
  g_business_group_id      number;
  g_payroll_action_id      number        := 0;
  g_assignment_id	    number	  := 0;
  g_assignment_action_id   number	  := 0;
  g_personal_payment_method_id number    := 0;
  g_org_payment_method_id  number        := 0;   /* Tape Level Id*/
  g_csr_org_pay_meth_id    number        := 0;   /* Assignment Level Id */
  g_csr_org_pay_third_party varchar2(1)  := null;
  g_pad_count              number        := 0;
  g_temp_count             number        := 0;
  g_count                  number        := 0;
  g_addenda_count	    number 	  := 0;
  g_hash                   number        := 0;
  g_amount                 number        := 0;
  g_batch_number           number        := 0;
  g_legal_company_id       number        := 0;
  g_addenda_write	    varchar2(1)   := 'N';
  g_batch_control_write    varchar2(1)	  := 'N';
  g_file_id_modifier       varchar2(1)   := null;
  g_company_entry_desc     varchar2(10)  := null;
  g_descriptive_date       varchar2(6)   := null;
  g_file_header            varchar2(9)   := null;
  g_batch_header           varchar2(9)   := null;
  g_org_pay_dummy          varchar2(9)   := null;
  g_entry_detail           varchar2(9)   := null;
  g_addenda		    varchar2(9)	  := null;
  g_org_pay_entry_detail   varchar2(9)   := null;
  g_batch_control          varchar2(9)   := null;
  g_file_control           varchar2(9)   := null;
  g_nacha_dest_code        varchar2(8)   := null;
  g_padding                varchar2(8)   := null;
  g_direct_dep_date        varchar2(6)   := null;
  g_legislative_parameters varchar2(240) := null;
  g_date                   varchar2(06)  := TO_CHAR(SYSDATE,'YYMMDD');
  g_time                   varchar2(04)  := TO_CHAR(SYSDATE,'HHMI');
  g_nacha_balance_flag	   varchar2(1)    := null;

  g_overflow_flag          varchar2(1)   := 'N';
  g_overflow_amount        number        := 0;
  g_overflow_batch         varchar2(1)   := 'N';
  g_rowid                  rowid         := null;

  g_test_file              varchar2(1)   := 'N';
  g_reset_greid            number        := 0;

  --IAT Enhancement
	g_foreign_transact			varchar2(1)	:= null;
	g_payroll_id						NUMBER;


 /******************************************************************
 NAME
   run_formula
 DESCRIPTION
   Setup contexts and parameter for the formula. Setup next formula to call
   so that Magtape ('C' process) could call appropriate formula
 NOTES
   C process 'pymx' uses parameters and contexts set by this procedure
   to setup the interface for the formula and to call the formula.
 *******************************************************************/
 PROCEDURE run_formula;


 --
 -- Cursor to get the Organisation Payment method Flex information
 -- IF org_payment_method_id is not supplied
 --


 CURSOR csr_org_flex_info (p_business_group_id number,
                           p_payroll_action_id number ) IS
   select opm.ORG_PAYMENT_METHOD_ID,
          decode(nvl(to_char(opm.defined_balance_id),'Y'),'Y','Y','N')
     from pay_org_payment_methods_f   opm,
          pay_payment_types           pt,
          pay_org_pay_method_usages_f opmu,
          pay_payrolls_f              pay,
          pay_payroll_actions         ppa
    where ppa.PAYROLL_ACTION_ID = p_payroll_action_id
      and ppa.payroll_id = pay.payroll_id
      and ppa.CONSOLIDATION_SET_ID = pay.CONSOLIDATION_SET_ID
      and pay.PAYROLL_ID = opmu.PAYROLL_ID
      and opmu.ORG_PAYMENT_METHOD_ID = opm.ORG_PAYMENT_METHOD_ID
      and upper(pt.PAYMENT_TYPE_NAME) =  'NACHA'
      and pt.PAYMENT_TYPE_ID = opm.PAYMENT_TYPE_ID
      and g_effective_date between opm.EFFECTIVE_START_DATE and
                                   opm.EFFECTIVE_END_DATE
      and opm.BUSINESS_GROUP_ID + 0 = p_business_group_id ;


-- Cursor to get batch information
-- There is one batch for each combination of GRE and Org Payment Method
CURSOR csr_nacha_batch (p_business_group_id number,
			  p_payroll_action_id number) IS

    select distinct
          prepay.org_payment_method_id,
	  decode(nvl(to_char(opm.defined_balance_id),'Y'),'Y','Y','N'),
	  hrorgu.organization_id,
	  opm.pmeth_information6
     from
          pay_pre_payments                prepay,
	  pay_org_payment_methods_f	  opm,
	  hr_organization_units		  hrorgu,
	  hr_organization_information	  hroinf
    where
          opm.org_payment_method_id	= prepay.org_payment_method_id
      and g_effective_date between opm.effective_start_date
                               and opm.effective_end_date
      and hrorgu.business_group_id          = p_business_group_id
      and opm.business_group_id             = p_business_group_id
      and hrorgu.organization_id            = hroinf.organization_id
      and hroinf.org_information_context    = 'CLASS'
      and hroinf.org_information1           = 'HR_LEGAL'
      and hroinf.org_information2           = 'Y'
      and EXISTS
          ( select 1
              from per_assignments_f          perasg,
                   pay_assignment_actions     pyaact
             where pyaact.payroll_action_id      = p_payroll_action_id
               and pyaact.tax_unit_id            = hrorgu.organization_id
               and perasg.assignment_id          = pyaact.assignment_id
               and g_effective_date between perasg.effective_start_date
                                        and perasg.effective_end_date
	       and pyaact.pre_payment_id	 = prepay.pre_payment_id);


-- gets all prepayments of a specific org payment method whose assignments
-- are in a specific GRE
--
 CURSOR csr_assignments(p_legal_company_id    number,
                        p_payroll_action_id   number,
                        p_org_payment_method_id number,
                        p_rowid rowid) IS
   select /*+ RULE */
          paa.assignment_id,
          paa.assignment_action_id,
          ppp.value,
          ppp.personal_payment_method_id,
          ppp.pre_payment_id,
          ppp.rowid
     from pay_assignment_actions paa,
          pay_pre_payments       ppp
    where ppp.org_payment_method_id+0 = p_org_payment_method_id  -- suppressing index for performance improvement Bug 3587226
      and ppp.PRE_PAYMENT_ID        = paa.PRE_PAYMENT_ID
      and paa.PAYROLL_ACTION_ID     = p_payroll_action_id
      and paa.tax_unit_id = p_legal_company_id  -- ADDED for GRE join as the subquery is removed Bug 3587226
      and ((ppp.rowid >= p_rowid and p_rowid is not null )
            or
           (p_rowid is null) )
     order by ppp.rowid;
-- Commented for performance improvement Bug 3587226
/*      and exists
          ( select 'x'
              from per_assignments_f paf,
                   hr_soft_coding_keyflex hsck
             where paf.assignment_id = paa.assignment_id
               and g_effective_date between paf.effective_start_date
                                        and paf.effective_end_date
               and hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
               and hsck.segment1 = to_char(p_legal_company_id)
          )
   order by ppp.rowid;      */
-- Commented for performance improvement Bug 3587226     upto here

-- Bug 3331019
 CURSOR csr_assignments_no_rule (p_legal_company_id    number,
                                 p_payroll_action_id   number,
                                 p_org_payment_method_id number,
                                 p_rowid rowid) IS
   select
          paa.assignment_id,
          paa.assignment_action_id,
          ppp.value,
          ppp.personal_payment_method_id,
          ppp.pre_payment_id,
          ppp.rowid
     from pay_assignment_actions paa,
          pay_pre_payments       ppp
    where ppp.org_payment_method_id = p_org_payment_method_id
      and ppp.PRE_PAYMENT_ID        = paa.PRE_PAYMENT_ID
      and paa.PAYROLL_ACTION_ID     = p_payroll_action_id
      and paa.tax_unit_id = p_legal_company_id    -- ADDED for GRE join as the subquery is removed  Bug 3587226
      and ((ppp.rowid >= p_rowid and p_rowid is not null )
            or
           (p_rowid is null) )
     order by ppp.rowid;
-- Commented for performance improvement Bug 3587226
/*
  and exists
          ( select 'x'
              from per_assignments_f paf,
                   hr_soft_coding_keyflex hsck
             where paf.assignment_id = paa.assignment_id
               and g_effective_date between paf.effective_start_date
                                        and paf.effective_end_date
               and hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
               and hsck.segment1 = to_char(p_legal_company_id)
          )
   order by ppp.rowid;
*/
-- Commented for performance improvement Bug 3587226 upto here
--
--
/* Bug 5098064 : Added for supporting EFT reconciliation */
FUNCTION f_get_batch_transact_ident(p_effective_date	DATE,
					   p_identifier_name		VARCHAR2,
					   p_payroll_action_id		NUMBER,
					   p_payment_type_id		NUMBER,
					   p_org_payment_method_id	NUMBER,
					   p_personal_payment_method_id	NUMBER,
					   p_assignment_action_id	NUMBER,
					   p_pre_payment_id		NUMBER,
					   p_delimiter_string   	VARCHAR2)
RETURN VARCHAR2;
END pay_us_nacha_tape;

/
