--------------------------------------------------------
--  DDL for Package PAY_CA_GROUP_LEVEL_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_GROUP_LEVEL_BAL_PKG" AUTHID CURRENT_USER AS
/* $Header: pycatxbv.pkh 120.0.12000000.1 2007/01/17 17:39:05 appldev noship $ */
--
-- Functions/Procedures (see package body for detailed descriptions)
--
FUNCTION  ca_group_level_balance (p_balance_name  in VARCHAR2,
                          p_time_dimension        in VARCHAR2,
                          p_effective_date        in DATE,
                          p_start_date            in DATE      DEFAULT NULL,
                          p_source_id             in NUMBER    DEFAULT NULL,
                          p_gre_id                in NUMBER    DEFAULT NULL,
                          p_jurisdiction          in VARCHAR2  DEFAULT NULL,
                          p_organization_id       in NUMBER    DEFAULT NULL,
                          p_location_id           in NUMBER    DEFAULT NULL,
                          p_payroll_id            in NUMBER    DEFAULT NULL,
                          p_pay_basis_type        in VARCHAR2  DEFAULT NULL)

RETURN NUMBER;
--
--PRAGMA RESTRICT_REFERENCES(ca_group_level_balance, WNDS);
--
FUNCTION get_defined_balance (p_balance_name      VARCHAR2,
                              p_dimension         VARCHAR2,
                              p_business_group_id NUMBER DEFAULT NULL)
RETURN NUMBER;
--
PRAGMA RESTRICT_REFERENCES(get_defined_balance, WNDS);
--
FUNCTION  ca_group_level_balance_rb (p_balance_name  in VARCHAR2,
                          p_time_dimension        in VARCHAR2,
                          p_effective_date        in DATE,
                          p_start_date            in DATE      DEFAULT NULL,
                          p_source_id             in NUMBER    DEFAULT NULL,
                          p_gre_id                in NUMBER    DEFAULT NULL,
                          p_jurisdiction          in VARCHAR2  DEFAULT NULL,
                          p_organization_id       in NUMBER    DEFAULT NULL,
                          p_location_id           in NUMBER    DEFAULT NULL,
                          p_payroll_id            in NUMBER    DEFAULT NULL,
                          p_pay_basis_type        in VARCHAR2  DEFAULT NULL,
                          p_flag                  in VARCHAR2  DEFAULT 'N')

RETURN NUMBER;
END pay_ca_group_level_bal_pkg;
--

 

/
