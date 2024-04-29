--------------------------------------------------------
--  DDL for Package PQH_EMPLOYEE_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_EMPLOYEE_SALARY" AUTHID CURRENT_USER as
/* $Header: pqempsal.pkh 120.1 2005/06/05 23:58 ggnanagu noship $ */
--
Procedure get_employee_salary
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date,
 p_salary         OUT nocopy number,
 p_frequency      OUT nocopy varchar2,
 p_annual_salary  OUT nocopy number,
 p_pay_basis      OUT nocopy varchar2,
 p_reason_cd      OUT nocopy varchar2,
 p_currency       OUT nocopy varchar2,
 p_status         OUT nocopy number,
 p_pay_basis_frequency OUT nocopy varchar2
);


--
Procedure check_grade_ladder_exists(p_business_group_id in number,
                                    p_effective_date    in date,
                                    p_grd_ldr_exists_flag out nocopy varchar2);
--
Procedure check_grade_ladder_exists(p_business_group_id in number,
                                    p_effective_date    in date ,
                                    p_grd_ldr_exists_flag out nocopy boolean);

Function pgm_to_annual (p_ref_perd_cd  in varchar2,
                         p_pgm_currency in varchar2,
                         p_amount       in number)
RETURN NUMBER;

Procedure get_emp_proposed_salary
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date,
 p_proposed_salary OUT nocopy number,
 p_sal_chg_dt     OUT nocopy date,
 p_frequency      OUT nocopy varchar2,
 p_annual_salary  OUT nocopy number,
 p_pay_basis      OUT nocopy varchar2,
 p_reason_cd      OUT nocopy varchar2,
 p_currency       OUT nocopy varchar2,
 p_status         OUT nocopy number
);
--
End;

 

/
