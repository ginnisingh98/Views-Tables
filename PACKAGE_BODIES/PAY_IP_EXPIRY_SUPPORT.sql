--------------------------------------------------------
--  DDL for Package Body PAY_IP_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IP_EXPIRY_SUPPORT" AS
 /* $Header: pyipexps.pkb 120.0 2005/05/29 05:59:33 appldev noship $ */
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next calendar month span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION month_ec
 (p_effective_date DATE) RETURN DATE IS
 BEGIN
   RETURN TRUNC(ADD_MONTHS(p_effective_date, 1), 'MM');
 END month_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next calendar quarter span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION quarter_ec
 (p_effective_date DATE) RETURN DATE IS
 BEGIN
   RETURN TRUNC(ADD_MONTHS(p_effective_date, 3), 'Q');
 END quarter_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next calendar year span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION year_ec
 (p_effective_date DATE) RETURN DATE IS
 BEGIN
   RETURN TRUNC(ADD_MONTHS(p_effective_date, 12), 'Y');
 END year_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next calendar year span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION period_ec
 (p_owner_payroll_action_id NUMBER
 ,p_owner_effective_date    DATE) RETURN DATE IS
   --
   --
   -- Local variables.
   --
   l_period_end_date DATE;
 BEGIN
   --
   --
   -- If the time periods are not the same for the two payroll actions then we need to expire
   -- the latest balance NB. returning an expiry date matching p_user_effective_date will
   -- result in the expiration of the balance.
   --
   SELECT TP.end_date
   INTO   l_period_end_date
   FROM   per_time_periods    TP
         ,pay_payroll_actions PACT
   WHERE  PACT.payroll_action_id = p_owner_payroll_action_id
     AND  PACT.payroll_id        = TP.payroll_id
     AND  p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
--
   return l_period_end_date + 1;
 END period_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next tax year span relative to the effective date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION tyear_ec
 (p_effective_date    DATE
 ,p_business_group_id NUMBER) RETURN DATE IS
 BEGIN
   RETURN ADD_MONTHS(pay_ip_route_support.tax_year(p_business_group_id, p_effective_date), 12);
 END tyear_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next tax quarter span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION tquarter_ec
 (p_effective_date    DATE
 ,p_business_group_id NUMBER) RETURN DATE IS
 BEGIN
   RETURN ADD_MONTHS(pay_ip_route_support.tax_quarter(p_business_group_id, p_effective_date), 3);
 END tquarter_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next fiscal year span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION fyear_ec
 (p_effective_date    DATE
 ,p_business_group_id NUMBER) RETURN DATE IS
 BEGIN
   RETURN ADD_MONTHS(pay_ip_route_support.fiscal_year(p_business_group_id, p_effective_date), 12);
 END fyear_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- Returns the start of the next fiscal quarter span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION fquarter_ec
 (p_effective_date    DATE
 ,p_business_group_id NUMBER) RETURN DATE IS
 BEGIN
   RETURN ADD_MONTHS(pay_ip_route_support.fiscal_quarter(p_business_group_id, p_effective_date), 3);
 END fquarter_ec;
 --
 --
 -- --------------------------------------------------------------------------
 -- This is the procedure called by the core logic that manages the expiry of
 -- latest balances. Its interface is fixed as it is called dynamically.
 --
 -- It will return the following output indicating the latest balance expiration
 -- status ...
 --
 -- p_expiry_information = 1  - Expired
 -- p_expiry_information = 0  - OK
 -- --------------------------------------------------------------------------
 --
 PROCEDURE date_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY NUMBER) IS
   --
   --
   -- Find the business group of the payroll action and also the period type of the
   -- balance dimension.
   --
   CURSOR csr_info(p_payroll_action_id NUMBER, p_dimension_name VARCHAR2) IS
     SELECT bd.period_type
           ,pact.business_group_id
     FROM   pay_payroll_actions         pact
           ,hr_organization_information hoi
           ,pay_balance_dimensions      bd
     WHERE  pact.payroll_action_id             = p_payroll_action_id
       AND  hoi.organization_id                = pact.business_group_id
       AND  UPPER(hoi.org_information_context) = 'BUSINESS GROUP INFORMATION'
       AND  bd.dimension_name                  = p_dimension_name
       AND  bd.legislation_code                = hoi.org_information9;
   --
   --
   -- Local variables.
   --
   l_rec         csr_info%ROWTYPE;
   l_expiry_date DATE;
 BEGIN
   --
   --
   -- Find the business group and also the period type of the balance dimension.
   --
   OPEN  csr_info(p_owner_payroll_action_id, p_dimension_name);
   FETCH csr_info INTO l_rec;
   CLOSE csr_info;
   --
   --
   -- Based on the period type of the balance dimension get the expiry date.
   --
   IF    l_rec.period_type = 'MONTH' THEN
     l_expiry_date := month_ec(p_owner_effective_date);
   --
   ELSIF l_rec.period_type = 'QUARTER' THEN
     l_expiry_date := quarter_ec(p_owner_effective_date);
   --
   ELSIF l_rec.period_type = 'YEAR' THEN
     l_expiry_date := year_ec(p_owner_effective_date);
   --
   ELSIF l_rec.period_type = 'PERIOD' THEN
     l_expiry_date := period_ec(p_owner_payroll_action_id, p_owner_effective_date);
   --
   ELSIF l_rec.period_type = 'TYEAR' THEN
     l_expiry_date := tyear_ec(p_owner_effective_date, l_rec.business_group_id);
   --
   ELSIF l_rec.period_type = 'TQUARTER' THEN
     l_expiry_date := tquarter_ec(p_owner_effective_date, l_rec.business_group_id);
   --
   ELSIF l_rec.period_type = 'FYEAR' THEN
     l_expiry_date := fyear_ec(p_owner_effective_date, l_rec.business_group_id);
   --
   ELSIF l_rec.period_type = 'FQUARTER' THEN
     l_expiry_date := fquarter_ec(p_owner_effective_date, l_rec.business_group_id);
   END IF;
   --
   --
   -- See if the current effective date is within the same span of time as the
   -- balance's effective date. If yes then it is OK to use cached balance
   -- otherwise the balance has expired.
   --
   IF p_user_effective_date >= l_expiry_date THEN
     P_expiry_information := 1; -- Expired!
   ELSE
     P_expiry_information := 0; -- OK!
   END IF;
 EXCEPTION
 		WHEN OTHERS THEN
 			p_expiry_information := NULL;
 END date_ec;
 --
 -- ----------------------------------------------------------------------------
 -- This is the overloaded procedure which returns actual expiry date
 -- ----------------------------------------------------------------------------
 --
 PROCEDURE date_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY DATE) IS
   --
   --
   -- Find the business group of the payroll action and also the period type of the
   -- balance dimension.
   --
   CURSOR csr_info(p_payroll_action_id NUMBER, p_dimension_name VARCHAR2) IS
     SELECT bd.period_type
           ,pact.business_group_id
     FROM   pay_payroll_actions         pact
           ,hr_organization_information hoi
           ,pay_balance_dimensions      bd
     WHERE  pact.payroll_action_id             = p_payroll_action_id
       AND  hoi.organization_id                = pact.business_group_id
       AND  UPPER(hoi.org_information_context) = 'BUSINESS GROUP INFORMATION'
       AND  bd.dimension_name                  = p_dimension_name
       AND  bd.legislation_code                = hoi.org_information9;
   --
   --
   -- Local variables.
   --
   l_rec         csr_info%ROWTYPE;
 BEGIN
   --
   --
   -- Find the business group and also the period type of the balance dimension.
   --
   OPEN  csr_info(p_owner_payroll_action_id, p_dimension_name);
   FETCH csr_info INTO l_rec;
   CLOSE csr_info;
   --
   --
   -- Based on the period type of the balance dimension get the expiry date.
   --
   IF    l_rec.period_type = 'MONTH' THEN
     p_expiry_information := month_ec(p_owner_effective_date)-1;
   --
   ELSIF l_rec.period_type = 'QUARTER' THEN
     p_expiry_information := quarter_ec(p_owner_effective_date)-1;
   --
   ELSIF l_rec.period_type = 'YEAR' THEN
     p_expiry_information := year_ec(p_owner_effective_date)-1;
   --
   ELSIF l_rec.period_type = 'PERIOD' THEN
     p_expiry_information := period_ec(p_owner_payroll_action_id, p_owner_effective_date) -1;
   --
   ELSIF l_rec.period_type = 'TYEAR' THEN
     p_expiry_information := tyear_ec(p_owner_effective_date, l_rec.business_group_id)-1;
   --
   ELSIF l_rec.period_type = 'TQUARTER' THEN
     p_expiry_information := tquarter_ec(p_owner_effective_date, l_rec.business_group_id)-1;
   --
   ELSIF l_rec.period_type = 'FYEAR' THEN
     p_expiry_information := fyear_ec(p_owner_effective_date, l_rec.business_group_id)-1;
   --
   ELSIF l_rec.period_type = 'FQUARTER' THEN
     p_expiry_information := fquarter_ec(p_owner_effective_date, l_rec.business_group_id)-1;
   END IF;
   --
   --
   -- See if the current effective date is within the same span of time as the
   -- balance's effective date. If yes then it is OK to use cached balance
   -- otherwise the balance has expired.
   --
 EXCEPTION
 		WHEN OTHERS THEN
 			p_expiry_information := NULL;
 END date_ec;
END pay_ip_expiry_support;

/
