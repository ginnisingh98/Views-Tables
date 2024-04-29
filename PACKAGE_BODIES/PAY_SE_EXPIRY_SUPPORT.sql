--------------------------------------------------------
--  DDL for Package Body PAY_SE_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_EXPIRY_SUPPORT" AS
/*$Header: pyseexsu.pkb 120.0.12000000.1 2007/04/24 06:53:32 rlingama noship $*/
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
 PROCEDURE holiday_pay_ec
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
   IF	l_rec.period_type = 'HYEAR' THEN

     l_expiry_date := hyear_ec(p_owner_assignment_action_id,p_owner_effective_date);
   --
   END IF;
   hr_utility.trace('   l_expiry_date => ' ||  l_expiry_date );
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
/*
   IF  p_dimension_name ='Assignment Previous Holiday Year to Date'  AND l_rec.period_type = 'HYEAR' THEN
		P_expiry_information := 1; -- OK!
   END IF;
*/

 EXCEPTION
 		WHEN OTHERS THEN
 			p_expiry_information := NULL;
 END holiday_pay_ec;
 --
 -- ----------------------------------------------------------------------------
 -- This is the overloaded procedure which returns actual expiry date
 -- ----------------------------------------------------------------------------
 --
 PROCEDURE holiday_pay_ec
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
   IF l_rec.period_type = 'HYEAR' THEN

     p_expiry_information := hyear_ec(p_owner_assignment_action_id,p_owner_effective_date)-1;

/*
	   IF  p_dimension_name ='Assignment Previous Holiday Year to Date' THEN

		p_expiry_information := p_owner_effective_date - 36500;

	   END IF;
*/

   END IF;


     hr_utility.trace('   p_expiry_information  => ' ||    p_expiry_information);
   --
   --
   -- See if the current effective date is within the same span of time as the
   -- balance's effective date. If yes then it is OK to use cached balance
   -- otherwise the balance has expired.
   --
 EXCEPTION
 		WHEN OTHERS THEN
 			p_expiry_information := NULL;
 END holiday_pay_ec;

  function  hyear_ec
 (p_assignment_action_id IN number,
 p_effective_date IN date
 ) RETURN DATE IS

 l_assignment_id number;
 l_business_group_id NUMBER;
 l_start_month number;
 l_assignment NUMBER;

CURSOR csr_assignment IS
	SELECT assignment_id
	FROM pay_assignment_actions
	WHERE assignment_action_id=p_assignment_action_id;
CURSOR csr_holiday_start IS
	SELECT	substr(hoi4.ORG_INFORMATION3,4,2)
	       FROM	HR_ORGANIZATION_UNITS o1
		    ,HR_ORGANIZATION_INFORMATION hoi1
		    ,HR_ORGANIZATION_INFORMATION hoi2
		    ,HR_ORGANIZATION_INFORMATION hoi3
		    ,HR_ORGANIZATION_INFORMATION hoi4
		    ,( SELECT TRIM(SCL.SEGMENT2) AS ORG_ID
			 FROM PER_ALL_ASSIGNMENTS_F ASG
			      ,HR_SOFT_CODING_KEYFLEX SCL
			WHERE ASG.ASSIGNMENT_ID	= l_assignment_id
			  AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
			  AND p_effective_date BETWEEN ASG.EFFECTIVE_START_DATE	AND ASG.EFFECTIVE_END_DATE ) X
	      WHERE o1.business_group_id = l_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id = X.ORG_ID
		AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id = hoi2.org_information1
		AND hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
		AND hoi2.organization_id =  hoi3.organization_id
		AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
		AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		AND hoi3.organization_id = hoi4.organization_id
		AND hoi4.ORG_INFORMATION_CONTEXT='SE_HOLIDAY_YEAR_DEFN'
		AND hoi4.org_information1 IS NOT NULL;
BEGIN
	OPEN csr_assignment;
		FETCH csr_assignment INTO l_assignment;
	CLOSE csr_assignment;
	OPEN csr_holiday_start;
		FETCH csr_holiday_start INTO l_start_month;
	CLOSE csr_holiday_start;
	IF to_number(to_char(p_effective_date,'MM'))< l_start_month THEN
		return (to_date('01/' || l_start_month || '/' || to_char(p_effective_date,'YYYY') , 'DD/MM/YYYY'));
	ELSE
		return (to_date('01/' || l_start_month || '/' || to_number(to_char(p_effective_date,'YYYY'))+1 , 'DD/MM/YYYY'));
	END IF;
END hyear_ec;

END PAY_SE_EXPIRY_SUPPORT;


/
