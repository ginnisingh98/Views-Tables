--------------------------------------------------------
--  DDL for Package Body PAY_IP_ROUTE_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IP_ROUTE_SUPPORT" AS
 /* $Header: pyiprous.pkb 115.1 2002/09/18 12:28:44 jahobbs noship $ */
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the tax year relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION tax_year
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE IS
   --
   -- Get the start date of the tax year in the same year as the effective
   -- date NB. the start date for the tax year is held in a legislation rule
   -- ('L') in the format DD/MM.
   --
   CURSOR csr_base_tax_year(p_business_group_id NUMBER, p_effective_date DATE) IS
     SELECT TO_DATE(ru.rule_mode || '/' || TO_CHAR(p_effective_date, 'YYYY'), 'DD/MM/YYYY')
     FROM   per_business_groups   bg
           ,pay_legislation_rules ru
     WHERE  bg.business_group_id = p_business_group_id
       AND  ru.legislation_code  = bg.legislation_code
       AND  ru.rule_type         = 'L';
   --
   --
   -- Local variables.
   --
   l_tax_yr DATE;
 BEGIN
   --
   --
   -- Fetch the start date of the tax year.
   --
   OPEN  csr_base_tax_year(p_business_group_id, p_effective_date);
   FETCH csr_base_tax_year INTO l_tax_yr;
   CLOSE csr_base_tax_year;
   --
   --
   -- The effective date is AFTER the tax year start date so it is valid.
   --
   IF p_effective_date >= l_tax_yr THEN
     RETURN l_tax_yr;
   --
   --
   -- The effective date is BEFORE the tax year start date so go back to the
   -- previous tax year start date.
   --
   ELSE
     RETURN ADD_MONTHS(l_tax_yr, -12);
   END IF;
 END tax_year;
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the tax quarter relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION tax_quarter
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE IS
   --
   --
   -- Local variables.
   --
   l_tax_yr DATE;
 BEGIN
   --
   --
   -- Find the start of the tax year.
   --
   l_tax_yr := tax_year(p_business_group_id, p_effective_date);
   --
   --
   -- Find the closest tax quarter start date to the effective date.
   --
   RETURN ADD_MONTHS(l_tax_yr, FLOOR(MONTHS_BETWEEN(p_effective_date, l_tax_yr) / 3) * 3);
 END tax_quarter;
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the fiscal year relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION fiscal_year
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE IS
   --
   -- Get the start date of the fiscal year in the same year as the effective
   -- date NB. the start date for the fiscal year is held against the business
   -- group in canonical format.
   --
   CURSOR csr_base_fiscal_year(p_business_group_id NUMBER, p_effective_date DATE) IS
     SELECT TO_DATE(TO_CHAR(fnd_date.canonical_to_date(hoi.org_information11), 'DD/MM/')
                 || TO_CHAR(p_effective_date, 'YYYY'), 'DD/MM/YYYY')
     FROM   hr_organization_information HOI
     WHERE  UPPER(hoi.org_information_context) = 'BUSINESS GROUP INFORMATION'
       AND  hoi.organization_id                = p_business_group_id;
   --
   --
   -- Local variables.
   --
   l_fis_yr DATE;
 BEGIN
   --
   --
   -- Fetch the start date of the fiscal year.
   --
   OPEN  csr_base_fiscal_year(p_business_group_id, p_effective_date);
   FETCH csr_base_fiscal_year INTO l_fis_yr;
   CLOSE csr_base_fiscal_year;
   --
   --
   -- The effective date is AFTER the fiscal year start date so it is valid.
   --
   IF p_effective_date >= l_fis_yr THEN
     RETURN l_fis_yr;
   --
   --
   -- The effective date is BEFORE the fiscal year start date so go back to the
   -- previous fis year start date.
   --
   ELSE
     RETURN ADD_MONTHS(l_fis_yr, -12);
   END IF;
 END fiscal_year;
 --
 --
 -- --------------------------------------------------------------------------
 -- This returns the start date of the fiscal quarter relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION fiscal_quarter
 (p_business_group_id NUMBER
 ,p_effective_date    DATE) RETURN DATE is
   --
   --
   -- Local variables.
   --
   l_fis_yr DATE;
 BEGIN
   --
   --
   -- Find the start of the fiscal year.
   --
   l_fis_yr := fiscal_year(p_business_group_id, p_effective_date);
   --
   --
   -- Find the closest fiscal quarter start date to the effective date.
   --
   RETURN ADD_MONTHS(l_fis_yr, FLOOR(MONTHS_BETWEEN(p_effective_date, l_fis_yr) / 3) * 3);
 END fiscal_quarter;
END pay_ip_route_support;

/
