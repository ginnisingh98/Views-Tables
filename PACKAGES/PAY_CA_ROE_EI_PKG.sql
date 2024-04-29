--------------------------------------------------------
--  DDL for Package PAY_CA_ROE_EI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_ROE_EI_PKG" AUTHID CURRENT_USER AS
/* $Header: pycaroei.pkh 120.0.12010000.1 2008/07/27 22:16:31 appldev ship $ */

TYPE rec_element IS RECORD (element_id        NUMBER);

TYPE element_table IS TABLE OF rec_element INDEX BY BINARY_INTEGER;

dp_element_table     element_table;
de_element_table     element_table;

TYPE t_small_number_table IS TABLE OF NUMBER(3) INDEX BY BINARY_INTEGER;
TYPE t_large_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_days_from_start t_small_number_table;
l_period_number   t_small_number_table;
--
-- Functions/Procedures (see package body for detailed descriptions)
--
FUNCTION populate_date_lookup_table
                    ( p_payroll_id             NUMBER,
                      p_assignment_id          NUMBER,
                      p_start_date             DATE,
                      p_effective_date         DATE,
                      p_last_period_start_date DATE)
RETURN VARCHAR2;
--
--PRAGMA RESTRICT_REFERENCES(populate_date_lookup_table, WNDS);
--
FUNCTION taxability_rule_exists
                    ( p_classification_name   VARCHAR2,
                      p_classification_id     NUMBER,
                      p_tax_category          VARCHAR2,
                      p_effective_date        DATE,
                      p_tax_type              VARCHAR2)
RETURN VARCHAR2;
--
--PRAGMA RESTRICT_REFERENCES(taxability_rule_exists, WNDS, WNPS);
--
FUNCTION date_paid_or_date_earned
                    ( p_element_type_id NUMBER,
                      p_dp_or_de        VARCHAR2,
                      p_ele_info3       VARCHAR2)
RETURN VARCHAR2;
--
--PRAGMA RESTRICT_REFERENCES(date_paid_or_date_earned, WNDS, WNPS);
--
FUNCTION get_pd_num
                    ( p_current_date DATE,
                      p_end_date     DATE)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_pd_num, WNDS);
--
FUNCTION get_ei_amount_totals
                    ( p_total_type      IN  VARCHAR2,
                      p_assignment_id   IN  NUMBER,
                      p_gre             IN  NUMBER,
                      p_payroll_id      IN  NUMBER,
                      p_start_date      IN  DATE,
                      p_end_date        IN  DATE,
                      p_period_type     OUT NOCOPY VARCHAR2,
                      p_total_insurable OUT NOCOPY NUMBER,
                      p_no_of_periods   OUT NOCOPY NUMBER,
                      p_period_total    OUT NOCOPY t_large_number_table,
                      p_term_or_abs_flag IN VARCHAR2)
RETURN VARCHAR2;
--
--PRAGMA RESTRICT_REFERENCES(get_ei_amount_totals, WNDS);
--
FUNCTION get_ei_amount_totals
                    ( p_total_type      IN  VARCHAR2,
                      p_assignment_id   IN  NUMBER,
                      p_gre             IN  NUMBER,
                      p_payroll_id      IN  NUMBER,
                      p_end_date        IN  DATE,
                      p_period_type     OUT NOCOPY VARCHAR2,
                      p_total_insurable OUT NOCOPY NUMBER,
                      p_no_of_periods   OUT NOCOPY NUMBER,
                      p_period_total    OUT NOCOPY t_large_number_table,
                      p_term_or_abs_flag IN VARCHAR2)
RETURN VARCHAR2;
--
--PRAGMA RESTRICT_REFERENCES(get_ei_amount_totals, WNDS);
--
PROCEDURE populate_element_table(p_bg_id number);

END pay_ca_roe_ei_pkg;
--

/
