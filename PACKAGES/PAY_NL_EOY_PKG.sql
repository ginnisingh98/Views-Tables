--------------------------------------------------------
--  DDL for Package PAY_NL_EOY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_EOY_PKG" AUTHID CURRENT_USER AS
/* $Header: pynleoy.pkh 120.1 2006/07/07 12:31:18 grchandr noship $ */

---------------------------------------------------------------------------
-- Function: GET_PREV_YEAR_TAX_INCOME
-- Function which returns the previous year taxable income for a person as
--on effective date
---------------------------------------------------------------------------

function GET_PREV_YEAR_TAX_INCOME(p_assignment_id 	  NUMBER
                                 ,p_effective_date	  DATE
                                 ,p_payroll_action_id NUMBER)  RETURN NUMBER;

function GET_PREV_YEAR_TAX_INCOME(p_assignment_id 	NUMBER
				                 ,p_effective_date	DATE)  RETURN NUMBER;
---------------------------------------------------------------------------
-- Procedure: get_balance_values
-- Procedure which returns the balance values of a assignment for a given date
---------------------------------------------------------------------------

Procedure get_balance_values(    l_assignment_id		 IN   NUMBER
				,l_prev_year_end_date		 IN   DATE
				,l_period_end_date		 IN   DATE
				,l_std_tax_income		 OUT NOCOPY NUMBER
				,l_spl_tax_income		 OUT NOCOPY NUMBER
				,l_retrostd_tax_income		 OUT NOCOPY NUMBER
				,l_retrostdcurrq_tax_income	 OUT NOCOPY NUMBER
				,l_retrospl_tax_income		 OUT NOCOPY NUMBER
				,l_hol_allow_pay_income		 OUT NOCOPY NUMBER
				,l_hol_allow_tax_income		 OUT NOCOPY NUMBER
				,l_retrohol_allow_tax_income	 OUT NOCOPY NUMBER
				,l_std_tax_income_ptd		 OUT NOCOPY NUMBER
				,l_spl_tax_income_ptd		 OUT NOCOPY NUMBER
				,l_retrostd_tax_income_ptd	 OUT NOCOPY NUMBER
				,l_retrostdcurrq_tax_income_ptd	 OUT NOCOPY NUMBER
				,l_retrospl_tax_income_ptd	 OUT NOCOPY NUMBER
				,l_hol_allow_pay_income_ptd	 OUT NOCOPY NUMBER
				,l_hol_allow_tax_income_ptd	 OUT NOCOPY NUMBER
				,l_rethol_allow_tax_income_ptd   OUT NOCOPY NUMBER);

---------------------------------------------------------------------------
-- Procedure: reset_override_lastyr_sal
-- Procedure which resets the override value of all the assignments at the
--end of the year
---------------------------------------------------------------------------

PROCEDURE  reset_override_lastyr_sal(errbuf out nocopy varchar2,
                                     retcode out nocopy varchar2,
                                     p_date in varchar2,
                                     p_org_struct_id  in number,
                                     p_hr_org_id in number,
                                     p_business_group_id in number
                                     );

---------------------------------------------------------------------------
-- Procedure: end_of_year_process
-- Generic Procedure for end of the year process
---------------------------------------------------------------------------

PROCEDURE end_of_year_process (errbuf out nocopy varchar2,
                               retcode out nocopy varchar2,
                               p_date in varchar2,
                               p_org_struct_id in number,
                               p_hr_org_id in number,
                               p_business_group_id in number
                               );

---------------------------------------------------------------------------
-- Procedure: update_assignments
--Procedure which does the datetrack update of all the assignments of a
--person with override value
---------------------------------------------------------------------------

Procedure update_assignments (p_assignment_id   IN NUMBER
			,p_person_id  		IN  NUMBER
			,p_effective_date 	IN  DATE
			,p_override_value  	IN  NUMBER
			,p_dt_update_mode       IN  VARCHAR2);

END pay_nl_eoy_pkg;

/
