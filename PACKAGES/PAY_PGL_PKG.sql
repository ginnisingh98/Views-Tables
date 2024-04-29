--------------------------------------------------------
--  DDL for Package PAY_PGL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PGL_PKG" AUTHID CURRENT_USER as
/* $Header: pypgl01t.pkh 115.2 2002/12/11 15:14:02 exjones ship $ */
--
procedure get_cost_allocation(p_business_group_id NUMBER
                             ,p_cost_allocation_id_flex_num IN OUT NOCOPY NUMBER
                             );
--
procedure get_pay_post_query(p_gl_set_of_books_id NUMBER
                            ,p_effective_end_date DATE
                            ,p_end_of_time DATE
                            ,p_period_type VARCHAR2
                            ,p_displayed_set_of_books IN OUT NOCOPY VARCHAR2
                            ,p_displayed_eff_end_date IN OUT NOCOPY DATE
                            ,p_chart_of_accounts_id IN OUT NOCOPY NUMBER
                            ,p_display_period_type IN OUT NOCOPY VARCHAR2);
--
procedure get_prf_post_query(p_gl_account_segment VARCHAR2
                            ,p_displayed_gl_segment IN OUT NOCOPY VARCHAR2
                            ,p_gl_flex_num NUMBER
                            ,p_payroll_cost_segment VARCHAR2
                            ,p_displayed_cost_segment IN OUT NOCOPY VARCHAR2
                            ,p_cost_flex_num NUMBER);
--
procedure prf_checks(p_rowid VARCHAR2
                    ,p_payroll_id NUMBER
                    ,p_gl_set_of_books_id NUMBER
                    ,p_gl_account_segment VARCHAR2 );
--
function future_payroll_rows(p_payroll_id NUMBER
                            ,p_session_date DATE) return BOOLEAN;
--
END PAY_PGL_PKG;

 

/
