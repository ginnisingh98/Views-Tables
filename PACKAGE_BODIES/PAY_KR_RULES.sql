--------------------------------------------------------
--  DDL for Package Body PAY_KR_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_RULES" as
/*   $Header: pykrrule.pkb 120.2.12000000.1 2007/01/17 22:14:24 appldev noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_kr_rules
--
   Change List
   -----------
   Date         Name        Vers   Bug       Description
   -----------  ----------  -----  --------  -------------------------------------------
   10-APR-2002  nbristow    115.0            Created.
   12-DEC-2002  krapolu     115.1            Added the NOCOPY directive.
   07-FEB-2006  mmark       115.2  4913403   Added GET_DYNAMIC_ORG_METH
   08-FEB-2006  mmark       115.3  4913403   Updated procedure GET_DYNAMIC_ORG_METH
                                             - Removed cursor CSR_EFF_DATE
                                             - Used language from userenv('LANG')
*/
--
--
   procedure get_default_run_type(p_asg_id   in number,
                                  p_ee_id    in number,
                                  p_effdate  in date,
                                  p_run_type out NOCOPY varchar2)
   is
     l_run_type_id number;
   begin
    select run_type_id
      into l_run_type_id
      from pay_run_types_f
     where run_type_name = 'MTH'
       and p_effdate between effective_start_date
                         and effective_end_date;
--
     p_run_type := to_char(l_run_type_id);
--
   end get_default_run_type;

--
   procedure get_dynamic_org_meth(
   		p_assignment_action_id in number,
		p_effective_date       in date,
		p_org_meth             in number,   -- org meth with no bank account
		p_org_method_id        out nocopy number
    )
    is

        --
        cursor csr_pay_meth_name is
                select  ppmtl.org_payment_method_name
                from
                        pay_org_payment_methods_f_tl ppmtl,
                        pay_org_payment_methods_f ppm
                where
                        ppmtl.org_payment_method_id = p_org_meth
                        and ppm.org_payment_method_id = p_org_meth
                        and ppm.external_account_id is null
                        and ppmtl.language = userenv('LANG')
                        and p_effective_date between ppm.effective_start_date and ppm.effective_end_date ;
        --
        l_pay_meth_name pay_org_payment_methods_f_tl.org_payment_method_name%type ;
        --
    begin
    	--
        open csr_pay_meth_name ;
        fetch csr_pay_meth_name into l_pay_meth_name ;
        --
        if csr_pay_meth_name%found then
                hr_utility.set_message(801, 'PAY_KR_INV_ORG_PAY_METHOD') ;
                hr_utility.set_message_token('PAY_METH_NAME', l_pay_meth_name) ;
                hr_utility.raise_error;
        end if ;
        --
        close csr_pay_meth_name ;
	--
    end get_dynamic_org_meth ;
--
end pay_kr_rules;

/
