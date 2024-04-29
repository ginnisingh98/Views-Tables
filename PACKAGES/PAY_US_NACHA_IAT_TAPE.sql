--------------------------------------------------------
--  DDL for Package PAY_US_NACHA_IAT_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_NACHA_IAT_TAPE" AUTHID CURRENT_USER AS
/* $Header: pytapnaciat.pkh 120.0.12010000.1 2009/08/20 20:07:58 mikarthi noship $ */
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
                of nacha IAT Tape.

  Uses        : hr_utility

  Change List
  -----------
  Date        Name     Vers    Bug No   Description
  ----        ----      -----  -------  -----------
  AUG-17-2009 MIKARTHI  1.0             Initial Version


  *****************************************************************************/

  -- Global Variable for the Package



 /* *****************************************************************
 NAME
   run_formula
 DESCRIPTION
   Setup contexts and parameter for the formula. Setup next formula to call
   so that Magtape ('C' process) could call appropriate formula
 NOTES
   C process 'pymx' uses parameters and contexts set by this procedure
   to setup the interface for the formula and to call the formula.
 *******************************************************************/
  PROCEDURE run_formula (p_business_group_id NUMBER,
						 p_effective_date DATE,
                         p_direct_dep_date varchar2,
                         p_org_payment_method_id NUMBER,
                         p_csr_org_pay_third_party VARCHAR2,
                         p_file_id_modifier VARCHAR2,
                         p_test_file VARCHAR2,
						 p_payroll_id NUMBER);




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
  g_legislative_parameters varchar2(240) := null;
  g_date                   varchar2(06)  := TO_CHAR(SYSDATE,'YYMMDD');
  g_time                   varchar2(04)  := TO_CHAR(SYSDATE,'HHMI');
  g_nacha_balance_flag	   varchar2(1)    := null;

  g_overflow_flag          varchar2(1)   := 'N';
  g_overflow_amount        number        := 0;
  g_overflow_batch         varchar2(1)   := 'N';
  g_rowid                  rowid         := null;


  g_reset_greid            number        := 0;

  --IAT Enhancement
    g_sec_code               varchar2(3)   := null;
    g_org_sec_code           varchar2(3)   := null;
	g_addenda_num						NUMBER			:=0;
	g_foreign_transact			varchar2(1)	:= null;

    g_payroll_id				    PAY_PAYROLLS_F.PAYROLL_ID%TYPE;
    g_organization_id			    per_all_assignments.ORGANIZATION_ID%TYPE;
    g_full_name 				    per_all_people_f.full_name%type;
    g_org_name					    hr_organization_units.name%type;
    g_street_address			    hr_locations.ADDRESS_LINE_1%type;
    g_city						    hr_locations.TOWN_OR_CITY%type;
    g_state						    hr_locations.REGION_1%type;
    g_county					    hr_locations.REGION_2%type;
    g_country					    hr_locations.COUNTRY%type;
    g_postal_code				    hr_locations.POSTAL_CODE%type;
    g_emp_num					    per_all_people_f.employee_number%type := null;
    g_emp_adress				    per_addresses_v.ADDRESS_LINE1%type := null;
    g_emp_city					    per_addresses_v.TOWN_OR_CITY%type := null;
    g_emp_state					    per_addresses_v.REGION_2%type := null;
    g_emp_county				    per_addresses_v.REGION_1%type := null;
    g_emp_country				    per_addresses_v.D_COUNTRY%type := null;
    g_emp_postal				    per_addresses_v.POSTAL_CODE%type := null;
    g_first_exec				    VARCHAR2(1) := 'Y';
    g_org_addenda				    VARCHAR2(1) := 'N';


 --
 -- Cursor to get the Organisation Payment method Flex information
 -- IF org_payment_method_id is not supplied
 --


 CURSOR csr_org_flex_info (p_business_group_id number,
                           p_payroll_action_id number,
													 p_effective_date date ) IS
   select opm.ORG_PAYMENT_METHOD_ID,
					ppa.payroll_id
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
      and p_effective_date between opm.EFFECTIVE_START_DATE and
                                   opm.EFFECTIVE_END_DATE
      and opm.BUSINESS_GROUP_ID + 0 = p_business_group_id ;


-- Cursor to get batch information
-- There is one batch for each combination of GRE and Org Payment Method
CURSOR csr_nacha_batch (p_business_group_id number,
			  p_payroll_action_id number,
				p_effective_date date) IS

   SELECT DISTINCT opm.org_payment_method_id, -- Changed to use OPM, moved PAY_PRE_PAYMENTS fully TO subquery
                    hrorgu.organization_id                                                                         ,
                    opm.pmeth_information6
    FROM            pay_payroll_actions ppa      , -- Add here to allow join directly to ORG_PAYMENT_METHOD_ID
                    pay_org_payment_methods_f opm,
                    hr_organization_units hrorgu ,
                    hr_organization_information hroinf
    WHERE           ppa.payroll_action_id     = p_payroll_action_id       -- New clause to allow primary key access
                AND ppa.org_payment_method_id = opm.org_payment_method_id -- join PPA to OPM to narrow to one method
                AND p_effective_date BETWEEN opm.effective_start_date AND opm.effective_end_date
                AND hrorgu.business_group_id       = p_business_group_id
                AND opm.business_group_id          = p_business_group_id
                AND hrorgu.organization_id         = hroinf.organization_id
                AND hroinf.org_information_context = 'CLASS'
                AND hroinf.org_information1        = 'HR_LEGAL'
                AND hroinf.org_information2        = 'Y'
                AND EXISTS
                    ( SELECT 1
                    FROM    per_assignments_f perasg     ,
                            pay_assignment_actions pyaact,
                            pay_pre_payments prepay -- Moved from outer query to subquery
                    WHERE   pyaact.payroll_action_id = ppa.payroll_action_id
                            -- join now to outer query
                        AND pyaact.tax_unit_id   = hrorgu.organization_id
                        AND perasg.assignment_id = pyaact.assignment_id
                        AND p_effective_date BETWEEN perasg.effective_start_date AND perasg.effective_end_date
                        AND pyaact.pre_payment_id        = prepay.pre_payment_id
                        AND prepay.org_payment_method_id = opm.org_payment_method_id
                        AND rownum                       = 1
                    );


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

--
END pay_us_nacha_iat_tape;

/
