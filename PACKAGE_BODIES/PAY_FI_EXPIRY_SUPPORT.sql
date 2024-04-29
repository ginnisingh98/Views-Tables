--------------------------------------------------------
--  DDL for Package Body PAY_FI_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_EXPIRY_SUPPORT" AS
 /* $Header: pyfiepst.pkb 120.5 2006/03/14 01:13:37 dbehera noship $ */
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
   RETURN TRUNC(ADD_MONTHS(p_effective_date, -1), 'MM');
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
   RETURN TRUNC(ADD_MONTHS(p_effective_date, -3), 'Q');
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
   RETURN TRUNC(ADD_MONTHS(p_effective_date, -12), 'Y');
 END year_ec;
 --
 --
  -- --------------------------------------------------------------------------
 -- Returns the start of the next calendar year span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION period_ec
 (p_owner_payroll_action_id          NUMBER
 ,p_owner_effective_date               DATE) RETURN DATE IS
   --
   --
   -- Local variables.
   --
   l_period_start_date DATE;
 BEGIN
   --
   --
   -- If the time periods are not the same for the two payroll actions then we need to expire
   -- the latest balance NB. returning an expiry date matching p_user_effective_date will
   -- result in the expiration of the balance.
   --
   SELECT TP.start_date
   INTO   l_period_start_date
   FROM   per_time_periods    TP
         ,pay_payroll_actions PACT
   WHERE  PACT.payroll_action_id = p_owner_payroll_action_id
     AND  PACT.payroll_id        = TP.payroll_id
     AND  p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
--
   return l_period_start_date - 1;
 END period_ec;

 -- --------------------------------------------------------------------------
 -- Returns the start of the next holiday year span relative to the effective
 -- date.
 -- --------------------------------------------------------------------------
 --
 FUNCTION hyear_ec
 (p_effective_date DATE) RETURN DATE IS
	l_date date;
 BEGIN
	SELECT  TO_DATE(decode(sign(to_number(to_char(p_effective_date,'MM'))-3),1,TO_DATE('01/04/'||(to_char(p_effective_date,'YYYY') + 1) , 'DD/MM/YYYY') ,TO_DATE('01/04/'||(to_char(p_effective_date,'YYYY')) , 'DD/MM/YYYY') ) )
	INTO l_date
	FROM dual;

	RETURN  l_date;
 END hyear_ec;
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
 PROCEDURE court_order_ec
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
  CURSOR get_period_type(p_payroll_action_id NUMBER, p_dimension_name VARCHAR2) IS
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


  CURSOR  get_element_entry_id(p_owner_assignment_action_id NUMBER, p_business_group_id  NUMBER ,p_owner_effective_date DATE) is
 select pee.element_entry_id
 from pay_element_entries_f pee,
 pay_element_types_f  pet,
 per_all_assignments_f paf1,
 per_all_assignments_f paf2,
 pay_assignment_actions paa1
 where  pet.element_name='Court Order Information'
 and   pet.legislation_code='FI'
 and  pet.element_type_id=pee.element_type_id
  and paa1.assignment_action_id=p_owner_assignment_action_id
 and paf1.business_group_id=p_business_group_id
 and paf2.business_group_id=p_business_group_id
 and  paa1.assignment_id=paf1.assignment_id
 and paf2.primary_flag='Y'
 and  paf1.person_id=paf2.person_id
 and pee.assignment_id=paf2.assignment_id
     and p_owner_effective_date between pee.effective_start_date
                               and pee.effective_end_date
     and p_owner_effective_date between pet.effective_start_date
                               and pet.effective_end_date
     and p_owner_effective_date between paf1.effective_start_date
                               and paf1.effective_end_date
     and p_owner_effective_date between paf2.effective_start_date
                               and paf2.effective_end_date ;
   -- Local variables.
   --
   l_rec   get_period_type%ROWTYPE;
   l_user_date_element_details get_element_entry_id%ROWTYPE;
   l_owner_date_element_details get_element_entry_id%ROWTYPE;
   l_owner_id NUMBER;
   l_user_id NUMBER;

 BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'expdate'||to_char(p_user_effective_date)||to_char(p_owner_effective_date));

   --    Find the business group and also the period type of the balance dimension.
   --
  OPEN  get_period_type(p_owner_payroll_action_id, p_dimension_name);
  FETCH get_period_type INTO l_rec;
  CLOSE get_period_type;
   --
   --
   -- Based on the period type of the balance dimension get the expiry date.
   --
   --IF    l_rec.period_type = 'MONTH' THEN
     --l_previous_period_date := month_ec(p_owner_effective_date);
   --
   --ELSIF l_rec.period_type = 'QUARTER' THEN
     --l_previous_period_date := quarter_ec(p_owner_effective_date);
   --
   --ELSIF l_rec.period_type = 'YEAR' THEN
     --l_previous_period_date := year_ec(p_owner_effective_date);
   --
   --for court it will always satisfy
   --ELSIF l_rec.period_type = 'PERIOD' THEN
     --l_previous_period_date := period_ec(p_owner_payroll_action_id, p_owner_effective_date);
   --
   --ELSIF l_rec.period_type = 'TYEAR' THEN
     --l_previous_period_date := tyear_ec(p_owner_effective_date, l_rec.business_group_id);
   --
   --ELSIF l_rec.period_type = 'TQUARTER' THEN
     --l_previous_period_date := tquarter_ec(p_owner_effective_date, l_rec.business_group_id);
   --
   --ELSIF l_rec.period_type = 'FYEAR' THEN
     --l_previous_period_date := fyear_ec(p_owner_effective_date, l_rec.business_group_id);
   --
   --ELSIF l_rec.period_type = 'FQUARTER' THEN
     --l_previous_period_date := fquarter_ec(p_owner_effective_date, l_rec.business_group_id);
   --END IF;
   --
   --
   --Check if previous period has the same element entry id ; If No then reset balances else do not reset
   --
   --
   --previous period details
   open get_element_entry_id(p_owner_assignment_action_id,  l_rec.business_group_id  ,p_user_effective_date);
   fetch get_element_entry_id  into l_user_date_element_details;
   close get_element_entry_id;

   l_user_id:=l_user_date_element_details.element_entry_id;
   IF l_user_id is NULL THEN
   l_user_id:=0;
   END IF;
   --current period details
   open get_element_entry_id(p_owner_assignment_action_id ,  l_rec.business_group_id ,p_owner_effective_date);
   fetch get_element_entry_id into l_owner_date_element_details;
   close get_element_entry_id;
   l_owner_id:=l_owner_date_element_details.element_entry_id;
   IF l_owner_id is NULL THEN
   l_owner_id:=0;
   END IF;
  --if there is a change in element entry id as well as the assignment is primary then balance should be reset
  --primary flag check is present to ensure that resetting takes place for only one assignment of a person
   IF(l_owner_id<>l_user_id) THEN      --new element entry indicates new court order
        P_expiry_information := 1; -- Expired!
   ELSE
     P_expiry_information := 0; -- OK!
   END IF;


 EXCEPTION
 		WHEN OTHERS THEN
 			p_expiry_information := NULL;
 END court_order_ec;

 ------overloaded procedure which returns the actual expiry date

 PROCEDURE court_order_ec
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
  CURSOR get_period_type(p_payroll_action_id NUMBER, p_dimension_name VARCHAR2) IS
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
  CURSOR  get_element_entry_id(p_owner_assignment_action_id NUMBER, p_business_group_id  NUMBER ,p_owner_effective_date DATE) is
 select pee.element_entry_id , pee.effective_end_date
 from pay_element_entries_f pee,
 pay_element_types_f  pet,
 per_all_assignments_f paf1,
 per_all_assignments_f paf2,
 pay_assignment_actions paa1
 where  pet.element_name='Court Order Information'
 and   pet.legislation_code='FI'
 and  pet.element_type_id=pee.element_type_id
  and paa1.assignment_action_id=p_owner_assignment_action_id
 and paf1.business_group_id=p_business_group_id
 and paf2.business_group_id=p_business_group_id
 and  paa1.assignment_id=paf1.assignment_id
 and paf2.primary_flag='Y'
 and  paf1.person_id=paf2.person_id
 and pee.assignment_id=paf2.assignment_id
     and p_owner_effective_date between pee.effective_start_date
                               and pee.effective_end_date
     and p_owner_effective_date between pet.effective_start_date
                               and pet.effective_end_date
     and p_owner_effective_date between paf1.effective_start_date
                               and paf1.effective_end_date
     and p_owner_effective_date between paf2.effective_start_date
                               and paf2.effective_end_date ;


   -- Local variables.
   --
   l_user_date_element_details get_element_entry_id%ROWTYPE;
   l_owner_date_element_details get_element_entry_id%ROWTYPE;
   l_owner_id NUMBER;
   l_user_id NUMBER;
   l_rec   get_period_type%ROWTYPE;
   l_expiry_date DATE;

    BEGIN
   --
   --
   -- Find the business group and also the period type of the balance dimension.
   --
   OPEN  get_period_type(p_owner_payroll_action_id, p_dimension_name);
   FETCH get_period_type INTO l_rec;
   CLOSE get_period_type;

   open get_element_entry_id(p_owner_assignment_action_id,  l_rec.business_group_id , p_user_effective_date);
   fetch get_element_entry_id  into l_user_date_element_details;
   close get_element_entry_id;

   l_user_id:=l_user_date_element_details.element_entry_id;
   IF l_user_id is NULL THEN
   l_user_id:=0;
   END IF;
   --current period details
   open get_element_entry_id(p_owner_assignment_action_id, l_rec.business_group_id , p_owner_effective_date);
   fetch get_element_entry_id into l_owner_date_element_details;
   close get_element_entry_id;
   l_owner_id:=l_owner_date_element_details.element_entry_id;
   IF l_owner_id is NULL THEN
   l_owner_id:=0;
   END IF;
  --if there is a change in element entry id as well as the assignment is primary then balance should be reset
  --primary flag check is present to ensure that resetting takes place for only one assignment of a person
   IF(l_owner_id<>l_user_id) THEN      --new element entry indicates new court order
        P_expiry_information    := l_owner_date_element_details.effective_end_date; -- Expired!
   ELSE
        P_expiry_information    := l_user_date_element_details.effective_end_date; -- OK!
   END IF;

 EXCEPTION
 		WHEN OTHERS THEN
 			p_expiry_information := NULL;
 END court_order_ec;

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
         hr_utility.trace(' In p_owner_payroll_action_id   => ' || p_owner_payroll_action_id  );
          hr_utility.trace(' In p_user_payroll_action_id => ' || p_user_payroll_action_id );
          hr_utility.trace(' In p_owner_assignment_action_id => ' || p_owner_assignment_action_id);
          hr_utility.trace(' In p_user_assignment_action_id  => ' || p_user_assignment_action_id );
          hr_utility.trace(' In p_owner_effective_date => ' || p_owner_effective_date);
          hr_utility.trace(' p_user_effective_date => ' || p_user_effective_date );
          hr_utility.trace(' In p_dimension_name => ' || p_dimension_name);

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

     l_expiry_date := hyear_ec(p_owner_effective_date);
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
	  hr_utility.trace(' In p_owner_payroll_action_id   => ' || p_owner_payroll_action_id  );
          hr_utility.trace(' In p_user_payroll_action_id => ' || p_user_payroll_action_id );
          hr_utility.trace(' In p_owner_assignment_action_id => ' || p_owner_assignment_action_id);
          hr_utility.trace(' In p_user_assignment_action_id  => ' || p_user_assignment_action_id );
          hr_utility.trace(' In p_owner_effective_date => ' || p_owner_effective_date);
          hr_utility.trace(' p_user_effective_date => ' || p_user_effective_date );
          hr_utility.trace(' In p_dimension_name => ' || p_dimension_name);

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

     p_expiry_information := hyear_ec(p_owner_effective_date)-1;

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

END pay_fi_expiry_support;

/
