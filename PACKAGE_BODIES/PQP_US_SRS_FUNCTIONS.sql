--------------------------------------------------------
--  DDL for Package Body PQP_US_SRS_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_US_SRS_FUNCTIONS" AS
/* $Header: pqussrfn.pkb 115.6 2003/07/31 13:37:12 rpinjala noship $ */

g_business_group_id  per_business_groups.business_group_id%TYPE;
----------------------------------------------------------------------------+
-- FUNCTION GET_SRS_LIMIT
----------------------------------------------------------------------------+
FUNCTION  get_srs_limit(p_payroll_action_id IN NUMBER
                       ,p_limit             IN VARCHAR2)
   RETURN NUMBER IS
   --+
   CURSOR c_limit (p_effective_date IN DATE) IS
   SELECT fed_information1,         -- DBP Payback Limit
          fed_information2,         -- DCP Combined EE ER Limit
          fed_information3,         -- Includable Annual Comp Limit
          fed_information4,         -- Includable Annual Comp GF Limit
          fed_information5,         -- DCP EE Contribution Limit
          fed_information6          -- DBP Contribution Limit (%age)
   FROM   pay_us_federal_tax_info_f
   WHERE  p_effective_date  BETWEEN effective_start_date
                                AND effective_end_date
     AND  fed_information_category = 'SRS LIMITS';
   --+
   l_limit_val       			NUMBER;
   l_string          			VARCHAR2(1000);

   dbp_payback_limit			NUMBER;
   dcp_combined_ee_er_limit		NUMBER;
   includable_annual_comp_limit 	NUMBER;
   incld_annual_comp_gf_limit   	NUMBER;
   dcp_ee_contribution_limit		NUMBER;
   dbp_contribution_limit		NUMBER;

   --+
   l_effective_date 			DATE;

BEGIN

   l_effective_date := TRUNC(pqp_us_srs_functions.get_date_paid
                            (p_payroll_action_id));


   FOR c_rec IN c_limit(l_effective_date)
   LOOP
     dbp_payback_limit			:=    to_number(c_rec.fed_information1); -- DBP Payback Limit
     dcp_combined_ee_er_limit    	:=    to_number(c_rec.fed_information2); -- DCP Combined EE ER Limit
     includable_annual_comp_limit	:=    to_number(c_rec.fed_information3); -- Includable Annual Comp Limit
     incld_annual_comp_gf_limit         :=    to_number(c_rec.fed_information4); -- Includable Annual Comp GF Limit
     dcp_ee_contribution_limit    	:=    to_number(c_rec.fed_information5); -- DCP EE Contribution Limit
     dbp_contribution_limit		:=    to_number(c_rec.fed_information6); -- DBP Contribution Limit (%age)
   END LOOP;

   IF p_limit = 'DBP' THEN
       RETURN NVL(dbp_contribution_limit,0);
   ELSIF p_limit = 'DCP' THEN
       RETURN NVL(dcp_ee_contribution_limit,0);
   ELSIF p_limit = 'ER_LIMIT_DCP' THEN
       RETURN NVL(dcp_combined_ee_er_limit,0);
   ELSIF p_limit = 'BuyBack_DCP' THEN
       RETURN NVL(dcp_ee_contribution_limit,0);
   ELSIF p_limit = 'BuyBack_DBP' THEN
       RETURN NVL(dbp_contribution_limit,0);
   ELSIF p_limit = 'ER_LIMIT_DBP' THEN
        RETURN NVL(dbp_payback_limit,0);
   ELSIF p_limit = 'COMP_LIMIT' THEN
        RETURN NVL(includable_annual_comp_limit,0);
   ELSIF p_limit = 'GF_COMP_LIMIT' THEN
        RETURN NVL(incld_annual_comp_gf_limit,0);
   ELSE
       RETURN 0;
   END IF;

END;
----------------------------------------------------------------------------+
-- FUNCTION get_date_paid
----------------------------------------------------------------------------+
FUNCTION get_date_paid (p_payroll_action_id IN  NUMBER)

         RETURN DATE AS
   --+
	CURSOR c_date_paid IS
	SELECT effective_date, business_group_id
	FROM   pay_payroll_actions
	WHERE  payroll_action_id=  p_payroll_action_id;
   --+
	l_date_paid date;

BEGIN

 l_date_paid := null;

 FOR c_rec IN c_date_paid
 LOOP
   l_date_paid         := c_rec.effective_date;
   g_business_group_id := c_rec.business_group_id;
 END LOOP;

 RETURN (l_date_paid);

END;
----------------------------------------------------------------------------+
-- FUNCTION get_srs_plan_type
----------------------------------------------------------------------------+
FUNCTION get_srs_plan_type (p_element_type_id   IN  NUMBER)
  RETURN VARCHAR2 IS
  --+

     CURSOR srs_c1 (c_element_type_id      In NUMBER
                   ,c_information_type     In VARCHAR2
                   ) Is
     SELECT EEI_INFORMATION4
       FROM PAY_ELEMENT_TYPE_EXTRA_INFO
      WHERE element_type_id          = c_element_type_id
        AND information_type         = c_information_type ;

     l_eei_information4 PAY_ELEMENT_TYPE_EXTRA_INFO.EEI_INFORMATION4%TYPE;

  --+

BEGIN

       OPEN srs_c1 ( c_element_type_id      => p_element_type_id
                    ,c_information_type     => 'PQP_US_SRS_DEDUCTIONS'
                   );
       FETCH srs_c1 Into l_eei_information4;
       IF srs_c1%NOTFOUND THEN
          l_eei_information4  := 'N'; -- Valid values Benefit(B), Contribution(C) or None(N)
       END IF;

       CLOSE srs_c1;

       RETURN l_eei_information4;

END;

----------------------------------------------------------------------------+
-- FUNCTION check_srs_enrolled
-- Function to Check if the person is enrolled for
-- SRS plan. This function also checks if the person
-- is eligible for Grandfathering or 10 Year Rule.
----------------------------------------------------------------------------+
FUNCTION check_srs_enrollment (p_element_type_id   IN NUMBER
                              ,p_assignment_id     IN NUMBER
                              ,p_payroll_action_id IN NUMBER
                              ,p_enrollment_type   IN VARCHAR2
                              )
RETURN VARCHAR2 IS
    CURSOR srs_c1 (c_element_type_id      IN NUMBER
                   ,c_assignment_id        IN NUMBER
                   ,c_effective_date       IN DATE
                   ) Is
     SELECT aei_information5,
            aei_information6
       FROM per_assignment_extra_info paei,
            pay_element_types_f       pet
      WHERE assignment_id     = c_assignment_id
        AND information_type  = 'PQP_US_SRS_PLAN_ASG_INFO'
        AND aei_information4  = pet.element_name
        AND element_type_id   = c_element_type_id
        AND c_effective_date
            BETWEEN NVL(TO_DATE(SUBSTR(aei_information1,1,10),'yyyy/mm/dd')
                       ,c_effective_date)
                AND NVL(TO_DATE(SUBSTR(aei_information2,1,10),'yyyy/mm/dd')
                       ,c_effective_date)
        AND c_effective_date BETWEEN pet.effective_start_date
                                 AND pet.effective_end_date;

    Cursor csr_ele (c_element_name      in varchar2
                   ,c_effective_date    in date
                   ,c_business_group_id in number) Is
      Select pet.element_type_id
        from pay_element_types_f pet
       Where pet.element_name = c_element_name
         and pet.business_group_id = c_business_group_id
         and c_effective_date between pet.effective_start_date
                                  and pet.effective_end_date;

     CURSOR srs_c2 (c_assignment_id IN NUMBER
                    ) Is
     SELECT aei_information4,
            aei_information5,
            aei_information6
       FROM per_assignment_extra_info paei
      WHERE assignment_id     = c_assignment_id
        AND information_type  = 'PQP_US_SRS_PLAN_ASG_INFO';

     l_aei_information4 PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION4%TYPE;
     l_aei_information5 PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION5%TYPE;
     l_aei_information6 PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION6%TYPE;
     l_effective_date 	DATE;
     l_srs_enrolled     VARCHAR2(1) := 'N';
     l_ele_name         pay_element_types_f.element_name%TYPE;
     l_base_ele_id      pay_element_types_f.element_type_id%TYPE;
     l_buyback_ele_id   pay_element_types_f.element_type_id%TYPE;
     l_return_value     VARCHAR2(2) := 'N';
BEGIN
       l_effective_date := TRUNC(pqp_us_srs_functions.get_date_paid
                                  (p_payroll_action_id)
                                  );

       IF p_enrollment_type = 'SRS' THEN
          OPEN srs_c1 ( c_element_type_id      => p_element_type_id
                       ,c_assignment_id        => p_assignment_id
                       ,c_effective_date       => l_effective_date
                       );
          FETCH srs_c1 INTO l_aei_information5,
                            l_aei_information6;
          IF srs_c1%NOTFOUND THEN
              l_srs_enrolled  := 'N'; -- Person is not enrolled for SRS Plan
          ELSE
              l_srs_enrolled  := 'Y'; -- Person is enrolled for SRS Plan
          END IF;
          CLOSE srs_c1;
          RETURN NVL(l_srs_enrolled, 'N');
       ELSE
          l_return_value := 'N';
          For asg_ext In srs_c2 (c_assignment_id => p_assignment_id)
          Loop
              l_ele_name := asg_ext.aei_information4;
              Open csr_ele (c_element_name      => l_ele_name
                           ,c_effective_date    => l_effective_date
                           ,c_business_group_id => g_business_group_id);
              Fetch csr_ele Into l_base_ele_id;
              Close csr_ele;
              l_ele_name := asg_ext.aei_information4||' Buy Back';
              Open csr_ele (c_element_name      => l_ele_name
                           ,c_effective_date    => l_effective_date
                           ,c_business_group_id => g_business_group_id);
              Fetch csr_ele Into l_buyback_ele_id;
              Close csr_ele;
              If p_element_type_id = l_base_ele_id Or
                 p_element_type_id = l_buyback_ele_id  Then
                 IF p_enrollment_type = 'TEN_YEAR' THEN
                    l_return_value := NVL(asg_ext.aei_information5,'N');
                 ELSIF p_enrollment_type = 'GRAND_FATHERING' THEN
                    l_return_value := NVL(asg_ext.aei_information6,'N');
                 END IF;
              End If;
          End Loop;
          Return l_return_value;
       END IF;
END check_srs_enrollment;

END pqp_us_srs_functions;

/
