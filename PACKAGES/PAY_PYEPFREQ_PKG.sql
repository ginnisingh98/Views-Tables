--------------------------------------------------------
--  DDL for Package PAY_PYEPFREQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYEPFREQ_PKG" AUTHID CURRENT_USER AS
/* $Header: pyepf01t.pkh 120.2 2006/10/02 07:48:23 susivasu noship $ */
--
Type g_freq_rule_rec_type Is Record
  (
  element_type_id                   number(9),
  payroll_id                        number(9),
  business_group_id                 number(15),
  period_1                          varchar2(1),
  period_2                          varchar2(1),
  period_3                          varchar2(1),
  period_4                          varchar2(1),
  period_5                          varchar2(1),
  period_6                          varchar2(1),
  rule_date_code                    varchar2(1)
  );
--
TYPE g_freq_rule_table_type IS TABLE OF g_freq_rule_rec_type
     INDEX BY BINARY_INTEGER;

g_freq_rule_table g_freq_rule_table_type;
g_freq_rule_rec   g_freq_rule_rec_type;

--
PROCEDURE hr_ele_pay_freq_rules (
				p_context	IN VARCHAR2,
				p_eletype_id	IN NUMBER,
				p_payroll_id	IN NUMBER,
				p_period_type	IN VARCHAR2,
				p_bg_id		IN NUMBER,
				p_period_1	IN OUT NOCOPY VARCHAR2,
				p_period_2	IN OUT NOCOPY VARCHAR2,
				p_period_3	IN OUT NOCOPY VARCHAR2,
				p_period_4	IN OUT NOCOPY VARCHAR2,
				p_period_5	IN OUT NOCOPY VARCHAR2,
				p_period_6	IN OUT NOCOPY VARCHAR2,
				p_eff_date	IN DATE	    DEFAULT NULL,
                                p_rule_date_code IN VARCHAR2 DEFAULT NULL,
                                p_leg_code       IN VARCHAR2 DEFAULT NULL);
--
FUNCTION get_freq_rule_period( p_ele_type_id IN NUMBER,
                               p_payroll_id IN NUMBER,
                               p_bus_grp_id IN NUMBER,
                               p_period_num IN NUMBER)
         RETURN VARCHAR2;
--
PROCEDURE remove_freq_rule_period(p_ele_type_id IN NUMBER,
                                  p_payroll_id IN NUMBER);
--
PROCEDURE initialise_freqrule_table;
--
END pay_pyepfreq_pkg;

/
