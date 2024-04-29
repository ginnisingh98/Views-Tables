--------------------------------------------------------
--  DDL for Package PAY_DK_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_SOE" AUTHID CURRENT_USER AS
/* $Header: pydksoe.pkh 120.0.12000000.2 2007/05/08 07:12:56 saurai noship $ */

 --

-- cursor to get the CVR Number

   	cursor csr_get_cvr_number (p_assignment_id per_all_assignments_f.assignment_id%TYPE, p_effective_date Date ) is
    select hoi.org_information1
    from  hr_soft_coding_keyflex       sck
	     ,HR_ORGANIZATION_INFORMATION  hoi
		 ,per_all_assignments_f        paa
	where paa.assignment_id = p_assignment_id
	and p_effective_date between paa.effective_start_date and paa.effective_end_date
	and paa.SOFT_CODING_KEYFLEX_ID = sck.SOFT_CODING_KEYFLEX_ID
	and hoi.organization_id = to_number(sck.segment1)
	and hoi.org_information_context = 'DK_LEGAL_ENTITY_DETAILS';

-- cursor to get the Pension Provider

   	cursor csr_get_pension_provider (p_assignment_id per_all_assignments_f.assignment_id%TYPE, p_effective_date Date ) is
    select hou.name
    from  hr_soft_coding_keyflex       sck
	     ,HR_ORGANIZATION_INFORMATION  hoi
		 ,per_all_assignments_f        paa
		 ,HR_ORGANIZATION_UNITS        hou
	where paa.assignment_id = p_assignment_id
	and p_effective_date between paa.effective_start_date and paa.effective_end_date
	and paa.SOFT_CODING_KEYFLEX_ID = sck.SOFT_CODING_KEYFLEX_ID
	and hoi.organization_id = to_number(sck.segment2)
	and hoi.org_information_context = 'DK_PENSION_PROVIDER_DETAILS'
	and hoi.organization_id = hou.organization_id;


-- function for fetching the Legal Entity CVR Number or Pension Provider

FUNCTION get_cvr_or_pension
( p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
  p_effective_date IN Date,
  p_org_information_context IN VARCHAR2 )
return VARCHAR2;

-- function for fetching the Union Membership

FUNCTION get_union_membership
( p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
  p_effective_date IN Date )
return varchar2;


-- function for fetching the Bank Registration Number

FUNCTION get_bank_reg_number
( p_external_account_id IN NUMBER)
return varchar2;


-- Returns SQL string for retrievening Employee information
function Employee(p_assignment_action_id number) return long;

-- Returns Payroll Period Information
function Period(p_assignment_action_id number) return long;

--  Returns Payment Information
function PrePayments(p_assignment_action_id number) return long;

/* Added for Pension changes */

function get_pp_name(p_effective_date date
                    ,p_run_result_id number)
                     return varchar2;

function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2)
		    return long;

function Elements1(p_assignment_action_id number )
                    --,p_element_set_name varchar2)
		    return long;
function Elements2(p_assignment_action_id number )
                    --,p_element_set_name varchar2)
		    return long;

function Elements3(p_assignment_action_id number )
                    --,p_element_set_name varchar2)
		    return long;
/* Added for display of Pension Provider balances */
function getBalances(p_assignment_action_id number)
		    return long;



-- end of package
END pay_dk_soe;

 

/
