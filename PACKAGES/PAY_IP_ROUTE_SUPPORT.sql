--------------------------------------------------------
--  DDL for Package PAY_IP_ROUTE_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IP_ROUTE_SUPPORT" AUTHID CURRENT_USER AS
 /* $Header: pyiprous.pkh 115.1 2002/09/18 12:28:58 jahobbs noship $ */
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the tax year relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION tax_year
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE;
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the tax quarter relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION tax_quarter
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE;
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the fiscal year relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION fiscal_year
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE;
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the fiscal quarter relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION fiscal_quarter
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE;
END pay_ip_route_support;

 

/
