--------------------------------------------------------
--  DDL for Package Body PAY_SE_HOLIDAY_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_HOLIDAY_PAY" AS
/*$Header: pyseholi.pkb 120.1 2007/06/28 17:23:06 rravi noship $*/
   FUNCTION get_earning_year_workingdays (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_assignment_action_id     IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_earning_start_date        DATE;
      l_earning_end_date          DATE;
      l_start_month               NUMBER;
      l_end_month                 NUMBER;
      l_person_id                 NUMBER;
      l_business_group_id         NUMBER;
      l_assignment_entitlement    NUMBER;
      l_person_entitlement        NUMBER;
      l_legal_entitlement         NUMBER;
      l_gen_entitlement           NUMBER;
      lr_get_defined_balance_id   NUMBER;
      l_value                     NUMBER;
      l_generate                  NUMBER;
      l_max_days                  NUMBER;
--l_absence_days number;
      l_days_year                 NUMBER;
      l_absence_days              NUMBER;
      l_paid_holiday_days         NUMBER;
      l_unpaid_holiday_days       NUMBER;
      l_saved_days                NUMBER;
      l_assignment_start          DATE;

/*Cursor csr_Earning_Year is
  SELECT substr(hoi4.ORG_INFORMATION1,4,2),substr(hoi4.ORG_INFORMATION2,4,2)
          FROM HR_ORGANIZATION_UNITS o1
          ,HR_ORGANIZATION_INFORMATION hoi1
          ,HR_ORGANIZATION_INFORMATION hoi2
          ,HR_ORGANIZATION_INFORMATION hoi3
          ,HR_ORGANIZATION_INFORMATION hoi4
          ,( SELECT TRIM(SCL.SEGMENT2) AS ORG_ID
          FROM PER_ALL_ASSIGNMENTS_F ASG
               ,HR_SOFT_CODING_KEYFLEX SCL
         WHERE ASG.ASSIGNMENT_ID = p_assignment_id
           AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
           AND p_effective_date BETWEEN ASG.EFFECTIVE_START_DATE  AND ASG.EFFECTIVE_END_DATE ) X
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
      AND hoi4.ORG_INFORMATION_CONTEXT='SE_HOLIDAY_YEAR_DEFN'  'SE_LE_HOLIDAY_PAY_DETAILS'
      AND hoi4.org_information1 IS NOT NULL;*/
      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;

      CURSOR csr_attendance_type_id
      IS
         SELECT DISTINCT eev1.screen_entry_value attendance_type_id
                    FROM per_all_assignments_f asg1
                         --,per_all_assignments_f      asg2
                        -- ,per_all_people_f         per
         ,               pay_element_links_f el
                        ,pay_element_types_f et
                        ,pay_input_values_f iv1
                        ,pay_element_entries_f ee
                        ,pay_element_entry_values_f eev1
                   WHERE asg1.assignment_id = p_assignment_id
                     AND p_effective_date BETWEEN asg1.effective_start_date
                                              AND asg1.effective_end_date
      --AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
   --   AND  per.person_id  = asg1.person_id
     -- AND  asg2.person_id    = per.person_id
--      AND  asg2.primary_flag    = 'Y'
                     AND et.element_name = 'Absence Details'
                     AND et.legislation_code = 'SE'
                     --OR et.business_group_id=3261     ) --checking for the business  group, it should be removed
                     AND iv1.element_type_id = et.element_type_id
                     AND iv1.NAME = 'Absence Category'        --l_inp_val_name
                     AND el.business_group_id = asg1.business_group_id
                     AND el.element_type_id = et.element_type_id
                     AND ee.assignment_id = asg1.assignment_id
                     AND ee.element_link_id = el.element_link_id
                     AND eev1.element_entry_id = ee.element_entry_id
                     AND eev1.input_value_id = iv1.input_value_id
                     AND ee.effective_start_date >= l_earning_start_date
                     AND ee.effective_end_date <= l_earning_end_date
                     AND eev1.effective_start_date >= l_earning_start_date
                     AND eev1.effective_end_date <= l_earning_end_date;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      CURSOR csr_generate_max_days (csr_v_absence_type_id NUMBER)
      IS
         SELECT information2 generate
               ,information3 max_days
           FROM per_absence_attendance_types
          WHERE absence_attendance_type_id = csr_v_absence_type_id;

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi4.org_information1, 4, 2)
               ,SUBSTR (hoi4.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi4.org_information1 IS NOT NULL;
/*CURSOR csr_assignment_start IS
    SELECT min(EFFECTIVE_START_DATE) FROM
    per_all_assignments_f
    WHERE assignment_id=p_assignment_id;*/
   BEGIN
      SELECT papf.business_group_id
            ,papf.person_id
        INTO l_business_group_id
            ,l_person_id
        FROM per_all_assignments_f paaf
            ,per_all_people_f papf
            ,hr_soft_coding_keyflex hsck
       WHERE paaf.assignment_id = p_assignment_id
         AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         AND papf.person_id = paaf.person_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND p_effective_date BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date;

      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_start_month
           ,l_end_month;

      CLOSE csr_earning_year;

      IF l_start_month IS NULL AND l_end_month IS NULL
      THEN
         RETURN -1;
      ELSE
         l_earning_start_date :=
            TO_DATE (   '01/'
                     || l_start_month
                     || '/'
                     || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                    ,'dd/mm/yyyy'
                    );
         l_earning_end_date :=
              TO_DATE (   '01/'
                       || l_start_month
                       || '/'
                       || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                      ,'dd/mm/yyyy'
                      )
            + 360;
         l_earning_end_date := LAST_DAY (l_earning_end_date);
      END IF;

        /*OPEN csr_assignment_start;
      FETCH csr_assignment_start INTO l_assignment_start;
       CLOSE csr_assignment_start;*/
       /*l_days_year:=(p_earning_end_date-(greatest(p_earning_start_date,l_assignment_start)+1));*/
      FOR csr_context IN csr_attendance_type_id
      LOOP
         pay_balance_pkg.set_context ('SOURCE_NUMBER'
                                     ,csr_context.attendance_type_id
                                     );
         pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID'
                                     ,p_assignment_action_id
                                     );

         OPEN csr_get_defined_balance_id
                                 ('TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ABC_PER_YTD');

         FETCH csr_get_defined_balance_id
          INTO lr_get_defined_balance_id;

         CLOSE csr_get_defined_balance_id;

         l_value :=
            TO_CHAR
               (pay_balance_pkg.get_value
                           (p_defined_balance_id        => lr_get_defined_balance_id
                           ,p_assignment_action_id      => p_assignment_action_id
                           )
               );

         OPEN csr_generate_max_days (csr_context.attendance_type_id);

         FETCH csr_generate_max_days
          INTO l_generate
              ,l_max_days;

         CLOSE csr_generate_max_days;

         /* If generate is Y then value greater than the max is considered as absence, else whole value */
         IF l_generate = 'Y'
         THEN
            IF l_value > l_max_days
            THEN
               l_absence_days := l_absence_days + (l_value - l_max_days);
            ELSE
               l_absence_days := l_absence_days + l_value;
            END IF;
         ELSE
            l_absence_days := l_absence_days + l_value;
         END IF;
      END LOOP;

      RETURN l_absence_days;
   END get_earning_year_workingdays;

   FUNCTION check_entitlement (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_pay_start_date           IN       DATE
     ,p_pay_end_date             IN       DATE
     ,p_earning_start_date       OUT NOCOPY DATE
     ,p_earning_end_date         OUT NOCOPY DATE
   )
      RETURN VARCHAR2
   IS
      l_business_group_id    NUMBER;
      l_start_month          NUMBER;
      l_end_month            NUMBER;
      l_earning_start_date   DATE;
      l_earning_end_date     DATE;
      l_assignment_start     DATE;

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi4.org_information1, 4, 2)
               ,SUBSTR (hoi4.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi4.org_information1 IS NOT NULL;

      CURSOR csr_assignment_start
      IS
         SELECT MIN (effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id;
   BEGIN
      SELECT papf.business_group_id
        INTO l_business_group_id
        FROM per_all_assignments_f paaf
            ,per_all_people_f papf
            ,hr_soft_coding_keyflex hsck
       WHERE paaf.assignment_id = p_assignment_id
         AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         AND papf.person_id = paaf.person_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND p_effective_date BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date;

      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_start_month
           ,l_end_month;

      CLOSE csr_earning_year;

      IF l_start_month IS NULL AND l_end_month IS NULL
      THEN
         RETURN 'N';
      ELSE
         l_earning_start_date :=
            TO_DATE (   '01/'
                     || l_start_month
                     || '/'
                     || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                    ,'dd/mm/yyyy'
                    );
         l_earning_end_date :=
              TO_DATE (   '01/'
                       || l_start_month
                       || '/'
                       || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                      ,'dd/mm/yyyy'
                      )
            + 360;
         l_earning_end_date := LAST_DAY (l_earning_end_date);
         p_earning_start_date := l_earning_start_date;
         p_earning_end_date := l_earning_end_date;

         --checking the l_earning_end_date+1 lies between the payroll periods for first payroll
         --period after earning year
         IF     (p_pay_start_date <= (l_earning_end_date + 1))
            AND ((l_earning_end_date + 1) <= p_pay_end_date)
         THEN
            --IF (p_effective_date>=l_earning_start_date) AND (p_effective_date<=l_earning_end_date) THEN
            /* check whether the person has the assignment in the earning year */
            OPEN csr_assignment_start;

            FETCH csr_assignment_start
             INTO l_assignment_start;

            CLOSE csr_assignment_start;

            IF l_assignment_start <= l_earning_end_date
            THEN
               RETURN 'F';
            ELSE
               RETURN 'N';
            END IF;
          --checking the earning_end_date lies between payroll_start and end_date, to find the last payroll
          --period
          /*ELSIF  (p_pay_start_date>=l_earning_end_date) AND (l_earning_end_date<= p_pay_end_date)   THEN
         RETURN 'L';*/
         ELSE
            RETURN 'N';
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END check_entitlement;

   FUNCTION get_paid_unpaid_days (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_assignment_action_id     IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_earning_start_date       IN       DATE
     ,p_earning_end_date         IN       DATE
     ,p_paid_holiday_days        OUT NOCOPY NUMBER
     ,p_unpaid_holiday_days      OUT NOCOPY NUMBER
     ,p_total_working_days       OUT NOCOPY NUMBER
   )
      RETURN NUMBER
   IS
      l_person_id                 NUMBER;
      l_business_group_id         NUMBER;
      l_assignment_entitlement    NUMBER;
      l_person_entitlement        NUMBER;
      l_legal_entitlement         NUMBER;
      l_gen_entitlement           NUMBER;
      lr_get_defined_balance_id   NUMBER;
      l_value                     NUMBER;
      l_generate                  VARCHAR (1);
      l_max_days                  NUMBER;
--l_absence_days number;
      l_days_year                 NUMBER;
      l_work_days_year            NUMBER;
      l_absence_days              NUMBER        := 0;
      l_paid_holiday_days         NUMBER;
      l_unpaid_holiday_days       NUMBER;
      l_saved_days                NUMBER;
      l_assignment_start          DATE;
      l_attendance_category_id    VARCHAR2 (30);
      l_working_perc              NUMBER;
      l_days                      NUMBER;

/*Cursor csr_Earning_Year is
  SELECT substr(hoi4.ORG_INFORMATION1,4,2),substr(hoi4.ORG_INFORMATION2,4,2)
          FROM HR_ORGANIZATION_UNITS o1
          ,HR_ORGANIZATION_INFORMATION hoi1
          ,HR_ORGANIZATION_INFORMATION hoi2
          ,HR_ORGANIZATION_INFORMATION hoi3
          ,HR_ORGANIZATION_INFORMATION hoi4
          ,( SELECT TRIM(SCL.SEGMENT2) AS ORG_ID
          FROM PER_ALL_ASSIGNMENTS_F ASG
               ,HR_SOFT_CODING_KEYFLEX SCL
         WHERE ASG.ASSIGNMENT_ID = p_assignment_id
           AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
           AND p_effective_date BETWEEN ASG.EFFECTIVE_START_DATE  AND ASG.EFFECTIVE_END_DATE ) X
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
      AND hoi4.ORG_INFORMATION_CONTEXT='SE_HOLIDAY_YEAR_DEFN'  'SE_LE_HOLIDAY_PAY_DETAILS'
      AND hoi4.org_information1 IS NOT NULL;*/
      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;

      CURSOR csr_attendance_category_id
      IS
         SELECT DISTINCT eev1.screen_entry_value attendance_category_id
                    FROM per_all_assignments_f asg1
                         --,per_all_assignments_f      asg2
                        -- ,per_all_people_f         per
         ,               pay_element_links_f el
                        ,pay_element_types_f et
                        ,pay_input_values_f iv1
                        ,pay_element_entries_f ee
                        ,pay_element_entry_values_f eev1
                   WHERE asg1.assignment_id = p_assignment_id
                     AND p_effective_date BETWEEN asg1.effective_start_date
                                              AND asg1.effective_end_date
      --AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
   --   AND  per.person_id  = asg1.person_id
     -- AND  asg2.person_id    = per.person_id
--      AND  asg2.primary_flag    = 'Y'
      --AND  et.element_name   = 'Absence Details'
                     AND et.legislation_code = 'SE'
                     --OR et.business_group_id=3261     ) --checking for the business  group, it should be removed
                     AND iv1.element_type_id = et.element_type_id
                     AND iv1.NAME = 'Absence Category'        --l_inp_val_name
                     AND el.business_group_id = asg1.business_group_id
                     AND el.element_type_id = et.element_type_id
                     AND ee.assignment_id = asg1.assignment_id
                     AND ee.element_link_id = el.element_link_id
                     AND eev1.element_entry_id = ee.element_entry_id
                     AND eev1.input_value_id = iv1.input_value_id
                     AND ee.effective_start_date <= p_earning_end_date
                     AND ee.effective_end_date >= p_earning_start_date
                     AND eev1.effective_start_date <= p_earning_end_date
                     AND eev1.effective_end_date >= p_earning_start_date
                     AND et.element_name NOT IN
                            ('Advance Holiday Details', 'Advance Holiday Pay');

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      CURSOR csr_generate_max_days
      IS
         /*SELECT INFORMATION2 Generate
         ,INFORMATION3 Max_Days
         FROM PER_ABSENCE_ATTENDANCE_TYPES
         WHERE ABSENCE_ATTENDANCE_TYPE_ID=csr_v_absence_type_id;*/
         SELECT hoi4.org_information2
               ,hoi4.org_information3
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            --AND   hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_ABSENCE_CATEGORY_LIMIT'
            AND hoi4.org_information1 IS NOT NULL
            AND hoi4.org_information1 = l_attendance_category_id;

      CURSOR csr_assignment_start
      IS
         SELECT MIN (effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id;
   BEGIN
      SELECT papf.business_group_id
            ,papf.person_id
            ,segment9
        INTO l_business_group_id
            ,l_person_id
            ,l_working_perc
        FROM per_all_assignments_f paaf
            ,per_all_people_f papf
            ,hr_soft_coding_keyflex hsck
       WHERE paaf.assignment_id = p_assignment_id                      --15381
         AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         AND papf.person_id = paaf.person_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND p_effective_date BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date;

      /* To get the entitlement */
      OPEN csr_assignment_entitlement;

      FETCH csr_assignment_entitlement
       INTO l_assignment_entitlement;

      CLOSE csr_assignment_entitlement;

      OPEN csr_person_entitlement;

      FETCH csr_person_entitlement
       INTO l_person_entitlement;

      CLOSE csr_person_entitlement;

      OPEN csr_legal_employer_entitlement;

      FETCH csr_legal_employer_entitlement
       INTO l_legal_entitlement;

      CLOSE csr_legal_employer_entitlement;

      l_gen_entitlement :=
         NVL (l_assignment_entitlement
             ,NVL (l_person_entitlement, l_legal_entitlement)
             );

      OPEN csr_assignment_start;

      FETCH csr_assignment_start
       INTO l_assignment_start;

      CLOSE csr_assignment_start;

      /* After discussing with vinod, assignment start date should not be considered while
      calculating the number of days in a year, entitlement calculation, changing the same on 20-sep-2006 */
      l_work_days_year :=
         (  p_earning_end_date
          - (GREATEST (p_earning_start_date, l_assignment_start))
          + 1
         );
      l_days_year := (p_earning_end_date - p_earning_start_date + 1);

      FOR csr_category IN csr_attendance_category_id
      LOOP
         l_attendance_category_id := csr_category.attendance_category_id;
         pay_balance_pkg.set_context ('SOURCE_TEXT'
                                     ,csr_category.attendance_category_id
                                     );
         pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID'
                                     ,p_assignment_action_id
                                     );
         pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);

-- pay_balance_pkg.set_context('DATE_EARNED',p_effective_date);
   --OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ABC_PER_YTD');
   --OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ABS_CAT_ASG_EARN_YTD');
         OPEN csr_get_defined_balance_id
                    ('TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ASG_LE_ABS_CAT_EARN_YEAR');

         FETCH csr_get_defined_balance_id
          INTO lr_get_defined_balance_id;

         CLOSE csr_get_defined_balance_id;

         /*l_value :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                     P_ASSIGNMENT_ACTION_ID =>p_assignment_action_id   )                    );*/
         l_value :=
            pay_balance_pkg.get_value
                        (p_defined_balance_id        => lr_get_defined_balance_id
                        ,p_assignment_action_id      => p_assignment_action_id
                        ,p_tax_unit_id               => p_tax_unit_id
                        ,p_jurisdiction_code         => NULL
                        ,p_source_id                 => NULL
                        ,p_source_text               => csr_category.attendance_category_id
                        ,p_tax_group                 => NULL
                        ,p_date_earned               => p_effective_date
                        );

         OPEN csr_generate_max_days;

         FETCH csr_generate_max_days
          INTO l_generate
              ,l_max_days;

         CLOSE csr_generate_max_days;

         /* If generate is Y then value greater than the max is considered as absence, else whole value */
         IF l_generate = 'Y'
         THEN
            IF l_value > l_max_days
            THEN
               l_absence_days := l_absence_days + (l_value - l_max_days);
            ELSE
               l_absence_days := l_absence_days;                -- + l_value;
            END IF;
         ELSE
            l_absence_days := l_absence_days + l_value;
         END IF;
      END LOOP;

      /*Commented for Bug 5662967 */
      /*IF l_absence_days IS NULL or l_absence_days=0 THEN

          l_paid_holiday_days:=trunc(0.01*l_working_perc*l_gen_entitlement);
          l_unpaid_holiday_days:=l_gen_entitlement-l_paid_holiday_days;
           p_total_working_days:=l_days_year;
      ELSE*/

      --        l_paid_holiday_days:=trunc(0.01*l_working_perc*((l_days_year-l_absence_days)/l_days_year)*l_gen_entitlement) + 1;
      /*l_paid_holiday_days :=
         TRUNC (  0.01
                * l_working_perc
                * ((l_work_days_year - l_absence_days) / l_days_year)
                * l_gen_entitlement
               );

      IF (  0.01
          * l_working_perc
          * ((l_days_year - l_absence_days) / l_days_year)
          * l_gen_entitlement
         ) > l_paid_holiday_days
      THEN
         l_paid_holiday_days := l_paid_holiday_days + 1;
      END IF;*/

      l_paid_holiday_days:=ceil(((l_work_days_year-l_absence_days)/l_days_year)*l_gen_entitlement) ;
      l_unpaid_holiday_days:=l_gen_entitlement-l_paid_holiday_days;
      p_total_working_days:=(l_work_days_year-l_absence_days);

/*    END IF;*/
      p_paid_holiday_days := l_paid_holiday_days;
      p_unpaid_holiday_days := l_unpaid_holiday_days;
         /*IF l_absence_days>p_paid_holiday_days THEN
        l_saved_days:=0;
        /* We need to get the previous saved days from the balance and check, if the absence doesnt cross the
        total days */
      /*   ELSE
        l_saved_days:=(p_paid_holiday_days-l_absence_days);
         END IF;*/
      RETURN 0;
   END get_paid_unpaid_days;

   FUNCTION get_vacation_days (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_payroll_start_date       IN       DATE
     ,p_payroll_end_date         IN       DATE
   )
      RETURN NUMBER
   IS
      lr_get_defined_balance_id   NUMBER;
      l_vacation_days             NUMBER;

      CURSOR csr_get_vacation_days
      IS
         SELECT NVL (SUM (peevf2.screen_entry_value), 0)
           FROM per_all_assignments_f paaf
               ,pay_element_types_f et
               ,pay_element_entries_f ee
               ,pay_element_entry_values_f peevf1
               ,pay_element_entry_values_f peevf2
               ,pay_input_values_f pivf1
               ,pay_input_values_f pivf2
          WHERE paaf.assignment_id = p_assignment_id
            AND p_effective_date BETWEEN paaf.effective_start_date
                                     AND paaf.effective_end_date
            AND et.element_name = 'Absence Details'
            AND et.legislation_code = 'SE'
            AND ee.assignment_id = paaf.assignment_id
            AND ee.element_type_id = et.element_type_id
            AND ee.effective_start_date >= p_payroll_start_date
            AND ee.effective_end_date <= p_payroll_end_date
            AND ee.element_entry_id = peevf1.element_entry_id
            AND pivf1.element_type_id = et.element_type_id
            AND pivf1.NAME = 'Absence Category'
            AND peevf1.input_value_id = pivf1.input_value_id
            AND peevf1.screen_entry_value = 'V'
            AND ee.element_entry_id = peevf2.element_entry_id
            AND pivf2.element_type_id = et.element_type_id
            AND pivf2.NAME = 'Days'
            AND peevf2.input_value_id = pivf2.input_value_id
            AND p_payroll_start_date BETWEEN et.effective_start_date
                                         AND et.effective_end_date
            AND p_payroll_end_date BETWEEN et.effective_start_date
                                       AND et.effective_end_date
                                                                --AND  peevf1.effective_start_date >= to_date('01-jan-2000')
                                                                --AND  peevf1.effective_end_date <= to_date('31-jan-2000')
                                                                --AND  peevf2.effective_start_date >= to_date('01-jan-2000')
                                                                --AND  peevf2.effective_end_date <= to_date('31-jan-2000')
      ;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';
   BEGIN
      OPEN csr_get_vacation_days;

      FETCH csr_get_vacation_days
       INTO l_vacation_days;

      CLOSE csr_get_vacation_days;

      RETURN l_vacation_days;
   END get_vacation_days;

   FUNCTION get_saved_year_limit_level (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_legal_employer           OUT NOCOPY VARCHAR2
     ,p_person                   OUT NOCOPY VARCHAR2
     ,p_assignment               OUT NOCOPY VARCHAR2
   )
      RETURN NUMBER
   IS
      l_person_id                NUMBER;
      l_business_group_id        NUMBER;
      l_assignment_entitlement   NUMBER;
      l_person_entitlement       NUMBER;
      l_legal_entitlement        NUMBER;

      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;
   BEGIN
      SELECT papf.business_group_id
            ,papf.person_id
        INTO l_business_group_id
            ,l_person_id
        FROM per_all_assignments_f paaf
            ,per_all_people_f papf
            ,hr_soft_coding_keyflex hsck
       WHERE paaf.assignment_id = p_assignment_id                      --15381
         AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         AND papf.person_id = paaf.person_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND p_effective_date BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date;

      OPEN csr_assignment_entitlement;

      FETCH csr_assignment_entitlement
       INTO l_assignment_entitlement;

      CLOSE csr_assignment_entitlement;

      OPEN csr_person_entitlement;

      FETCH csr_person_entitlement
       INTO l_person_entitlement;

      CLOSE csr_person_entitlement;

      OPEN csr_legal_employer_entitlement;

      FETCH csr_legal_employer_entitlement
       INTO l_legal_entitlement;

      CLOSE csr_legal_employer_entitlement;

      IF l_legal_entitlement IS NOT NULL
      THEN
         p_legal_employer := 'Y';
      END IF;

      IF l_person_entitlement IS NOT NULL
      THEN
         p_person := 'Y';
      END IF;

      IF l_assignment_entitlement IS NOT NULL
      THEN
         p_assignment := 'Y';
      END IF;

      RETURN 0;
   END get_saved_year_limit_level;

   FUNCTION get_calculation_option (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_local_unit_id            IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_absence_category         IN       VARCHAR2
     ,p_return_vacation          OUT NOCOPY VARCHAR2
   )
      RETURN NUMBER
   IS
   BEGIN
/* OPEN csr_get_vacation_days;
      FETCH csr_get_vacation_days INTO l_vacation_days;
   CLOSE csr_get_vacation_days;

   IF l_vacation_days is not null
         P_return_vacation := l_vacation_days;
   ELSE
         P_return_vacation := 0;
   END IF;*/
      p_return_vacation := '';
      RETURN 1;
   END get_calculation_option;

   FUNCTION element_exist (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_element_name             IN       VARCHAR2
   )
      RETURN NUMBER
   IS
      l_element_exist   NUMBER;

      CURSOR check_element_exist (
         p_assignment_id            IN       NUMBER
        ,p_effective_date           IN       DATE
        ,p_element_name             IN       VARCHAR2
      )
      IS
         SELECT 1
           FROM per_all_assignments_f asg
               ,pay_element_links_f el
               ,pay_element_types_f et
               ,pay_element_entries_f ee
          WHERE asg.assignment_id = p_assignment_id
            AND et.element_name = p_element_name
            AND et.legislation_code = 'SE'
            AND el.business_group_id = asg.business_group_id
            AND el.element_type_id = et.element_type_id
            AND ee.assignment_id = asg.assignment_id
            AND ee.element_link_id = el.element_link_id
            AND p_effective_date BETWEEN ee.effective_start_date
                                     AND ee.effective_end_date
            AND p_effective_date BETWEEN asg.effective_start_date
                                     AND asg.effective_end_date
            AND p_effective_date BETWEEN et.effective_start_date
                                     AND et.effective_end_date
            AND p_effective_date BETWEEN el.effective_start_date
                                     AND el.effective_end_date;
   BEGIN
      l_element_exist := 0;

      OPEN check_element_exist (p_assignment_id
                               ,p_date_earned
                               ,p_element_name
                               );

      FETCH check_element_exist
       INTO l_element_exist;

      CLOSE check_element_exist;

      RETURN l_element_exist;
   END element_exist;

-- Function to get the Further period for the payroll Run.
   FUNCTION get_further_period_details (
      p_payroll_id               IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_pay_saved_holiday        OUT NOCOPY VARCHAR2
     ,p_no_of_saved_days         OUT NOCOPY NUMBER
     ,p_pay_remaining_saved_days OUT NOCOPY VARCHAR2
     ,p_pay_additional_holiday   OUT NOCOPY VARCHAR2
     ,p_no_of_additional_holiday OUT NOCOPY NUMBER
     ,p_pay_remaining_addl_holiday OUT NOCOPY VARCHAR2
   )
      RETURN NUMBER
   IS
      l_fixed_period              NUMBER;

      CURSOR csr_further_period_details
      IS
         SELECT prd_information1
               ,prd_information3
               ,prd_information4
               ,prd_information6
               ,prd_information8
               ,prd_information9
           FROM per_time_periods
          WHERE payroll_id = p_payroll_id
            AND p_date_earned BETWEEN start_date AND end_date;

      lr_further_period_details   csr_further_period_details%ROWTYPE;
   BEGIN
      OPEN csr_further_period_details;

      FETCH csr_further_period_details
       INTO lr_further_period_details;

      CLOSE csr_further_period_details;

      p_pay_saved_holiday :=
                         NVL (lr_further_period_details.prd_information1, 'N');
      p_no_of_saved_days := lr_further_period_details.prd_information3;
      p_pay_remaining_saved_days :=
                         NVL (lr_further_period_details.prd_information4, 'N');
      p_pay_additional_holiday := lr_further_period_details.prd_information6;
      p_no_of_additional_holiday := lr_further_period_details.prd_information8;
      p_pay_remaining_addl_holiday :=
                                    lr_further_period_details.prd_information9;
      l_fixed_period := 1;
      RETURN l_fixed_period;
   END get_further_period_details;

   FUNCTION get_saved_holiday_limit (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
   )
      RETURN NUMBER
   IS
      l_assignment_limit         NUMBER;
      l_person_limit             NUMBER;
      l_legal_limit              NUMBER;
      l_person_id                NUMBER;
      l_business_group_id        NUMBER;
      l_gen_limit                NUMBER;
      l_assignment_entitlement   NUMBER;
      l_person_entitlement       NUMBER;
      l_legal_entitlement        NUMBER;
      l_gen_entitlement          NUMBER;

      CURSOR csr_assignment_limit
      IS
         SELECT aei_information3
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_limit
      IS
         SELECT pei_information3
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_limit
      IS
         SELECT hoi4.org_information3
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;

      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_effective_date BETWEEN asg.effective_start_date
                                              AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;
   BEGIN
      SELECT papf.business_group_id
            ,papf.person_id
        INTO l_business_group_id
            ,l_person_id
        FROM per_all_assignments_f paaf
            ,per_all_people_f papf
            ,hr_soft_coding_keyflex hsck
       WHERE paaf.assignment_id = p_assignment_id                      --15381
         AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         AND papf.person_id = paaf.person_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND p_effective_date BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date;

      OPEN csr_assignment_limit;

      FETCH csr_assignment_limit
       INTO l_assignment_limit;

      CLOSE csr_assignment_limit;

      OPEN csr_person_limit;

      FETCH csr_person_limit
       INTO l_person_limit;

      CLOSE csr_person_limit;

      OPEN csr_legal_employer_limit;

      FETCH csr_legal_employer_limit
       INTO l_legal_limit;

      CLOSE csr_legal_employer_limit;

      l_gen_limit :=
                 NVL (l_assignment_limit, NVL (l_person_limit, l_legal_limit));

      OPEN csr_assignment_entitlement;

      FETCH csr_assignment_entitlement
       INTO l_assignment_entitlement;

      CLOSE csr_assignment_entitlement;

      OPEN csr_person_entitlement;

      FETCH csr_person_entitlement
       INTO l_person_entitlement;

      CLOSE csr_person_entitlement;

      OPEN csr_legal_employer_entitlement;

      FETCH csr_legal_employer_entitlement
       INTO l_legal_entitlement;

      CLOSE csr_legal_employer_entitlement;

      l_gen_entitlement :=
         NVL (l_assignment_entitlement
             ,NVL (l_person_entitlement, l_legal_entitlement)
             );
      RETURN (l_gen_entitlement - l_gen_limit);
   END get_saved_holiday_limit;

   FUNCTION get_end_year (p_date_earned IN DATE, p_tax_unit_id IN NUMBER)
      RETURN NUMBER
   IS
      l_start_month   CHAR (2);
      l_end_month     CHAR (2);

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi2.org_information1, 4, 2)
               ,SUBSTR (hoi2.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = p_tax_unit_id                    --3134
            AND hoi1.org_information_context = 'CLASS'
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi2.org_information1 IS NOT NULL;
   BEGIN
      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_start_month
           ,l_end_month;

      CLOSE csr_earning_year;

      /* Logic for Earning Year is from Jan-Dec */
      IF l_start_month = '01' AND l_end_month = '12'
      THEN
         RETURN TO_NUMBER (TO_CHAR (p_date_earned, 'YYYY'));
      ELSE
         IF TO_NUMBER (TO_CHAR (p_date_earned, 'MM')) <
                                                    TO_NUMBER (l_start_month)
         THEN
            RETURN TO_NUMBER (TO_CHAR (p_date_earned, 'YYYY') - 1);
         ELSE
            RETURN TO_NUMBER (TO_CHAR (p_date_earned, 'YYYY'));
         END IF;
      END IF;
   END get_end_year;

   FUNCTION get_remaining_saved_pay (
      p_assignment_id            IN       NUMBER
     ,p_assignment_action_id     IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_payroll_id               IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_days_to_pay              OUT NOCOPY NUMBER
   )
      RETURN VARCHAR2
   IS
      l_pay_date                    DATE;
      l_end_year                    NUMBER;
      l_start_month                 NUMBER;
      l_end_month                   NUMBER;
      l_start_date                  DATE;
      l_end_date                    DATE;
      l_value                       NUMBER;
      l_total_saved_holidays        NUMBER;
      l_total_saved_days_tracking   NUMBER;
      l_tracking_start_date         DATE;
      l_tracking_end_date           DATE;
      l_days_to_pay                 DATE;
      lr_get_defined_balance_id     NUMBER;
      l_pay_yes_no                  VARCHAR (1);

      CURSOR csr_further_period_details
      IS
         SELECT prd_information4
           FROM per_time_periods
          WHERE payroll_id = p_payroll_id
            AND p_effective_date BETWEEN start_date AND end_date;

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi2.org_information1, 4, 2)
               ,SUBSTR (hoi2.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = p_tax_unit_id                    --3134
            AND hoi1.org_information_context = 'CLASS'
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi2.org_information1 IS NOT NULL;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';
   BEGIN
      OPEN csr_further_period_details;

      FETCH csr_further_period_details
       INTO l_pay_yes_no;

      CLOSE csr_further_period_details;

      IF l_pay_yes_no IS NULL
      THEN
         l_pay_yes_no := 'N';
      END IF;

      p_days_to_pay := 0;
      RETURN l_pay_yes_no;
/* OPEN csr_Further_period_details;
      FETCH csr_Further_period_details INTO l_pay_date;
   CLOSE csr_Further_period_details;
   l_end_year:=GET_END_YEAR(l_pay_date,p_tax_unit_id);
   OPEN csr_Earning_Year;
      FETCH csr_Earning_Year INTO  l_start_month,l_end_month;
   CLOSE csr_Earning_Year;
   l_start_date:=TO_DATE('01/'|| l_start_month || '/' || l_end_year-1,'dd/mm/yyyy');
   l_end_date:=TO_DATE(last_day('01/'|| l_end_month || '/' || l_end_year),'dd/mm/yyyy');

   IF to_number(to_char(l_pay_date,'YYYY')) - to_number(to_char(l_start_date,'YYYY')) < 5 THEN
   /* we dont need to pay anything, exit */
/*    P_days_to_pay:=0;
      RETURN 'N';
   ELSIF to_number(to_char(l_pay_date,'YYYY')) - to_number(to_char(l_start_date,'YYYY')) = 5 THEN
   /* do the calculation in the formula */
/*    P_days_to_pay:=0;
      RETURN 'E';
   ELSE

      pay_balance_pkg.set_context('TAX_UNIT',p_tax_unit_id);
      pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
      OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SAVED_HOLIDAY_DAYS_ASG_HY_YTD');
         FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
      CLOSE csr_Get_Defined_Balance_Id;
      l_total_saved_holidays :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                             P_ASSIGNMENT_ACTION_ID =>p_assignment_action_id   )                    );
      /*l_total_saved_holidays:=pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id,NULL,p_tax_unit_id,
      NULL,NULL,NULL,l_pay_date);*/

   /*    l_tracking_start_date:=to_date('01/'|| to_char(l_start_date,'MM') ||'/' || to_number(to_char(l_start_date,'YYYY'))+4,'dd/mm/yyyy');
      l_tracking_end_date:=last_day(to_date('01/'|| to_char(l_end_date,'MM') ||'/' || to_number(to_char(l_end_date,'YYYY'))+4,'dd/mm/yyyy'));
      pay_balance_pkg.set_context('TAX_UNIT',p_tax_unit_id);
      pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
      OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SAVED_HOLIDAY_DAYS_TRACKING_ASG_HY_YTD');
         FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
      CLOSE csr_Get_Defined_Balance_Id;
      l_total_saved_days_tracking :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                             P_ASSIGNMENT_ACTION_ID =>p_assignment_action_id   )                    );
      /*l_total_saved_days_tracking:=(pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id,NULL,p_tax_unit_id,
      NULL,NULL,NULL,l_tracking_start_date);*/
/*    IF l_total_saved_holidays>l_total_saved_days_tracking THEN
         /* We need to pay the remaining days for that person */
/*       P_days_to_pay:=   (l_total_saved_holidays-l_total_saved_days_tracking);
      ELSE
         P_days_to_pay:=0;
      END IF;
      RETURN 'G';
   END IF;*/
   END get_remaining_saved_pay;

   FUNCTION get_hourly_salaried_code (
      p_assignment_id_id         IN       NUMBER
     ,p_date_earned              IN       DATE
   )
      RETURN VARCHAR2
   IS
      CURSOR csr_hourly_salaried_code
      IS
         SELECT NVL (hourly_salaried_code, '##') hsc
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id_id
            AND p_date_earned BETWEEN effective_start_date AND effective_end_date;

      lr_hourly_salaried_code   csr_hourly_salaried_code%ROWTYPE;
   BEGIN
--hr_utility.trace_on(null,'raja');
      OPEN csr_hourly_salaried_code;

      FETCH csr_hourly_salaried_code
       INTO lr_hourly_salaried_code;

      CLOSE csr_hourly_salaried_code;

      RETURN lr_hourly_salaried_code.hsc;
   END get_hourly_salaried_code;

-- Function to get the Further period for the payroll Run.
   FUNCTION get_absence_day_with_as_per (
      p_payroll_id               IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_pay_saved_holiday        OUT NOCOPY VARCHAR2
     ,p_no_of_saved_days         OUT NOCOPY NUMBER
     ,p_pay_remaining_saved_days OUT NOCOPY VARCHAR2
     ,p_pay_additional_holiday   OUT NOCOPY VARCHAR2
     ,p_no_of_additional_holiday OUT NOCOPY NUMBER
     ,p_pay_remaining_addl_holiday OUT NOCOPY VARCHAR2
   )
      RETURN NUMBER
   IS
      l_fixed_period              NUMBER;

      CURSOR csr_further_period_details
      IS
         SELECT prd_information1
               ,prd_information3
               ,prd_information4
               ,prd_information5
               ,prd_information7
               ,prd_information8
           FROM per_time_periods
          WHERE payroll_id = p_payroll_id
            AND p_date_earned BETWEEN start_date AND end_date;

      lr_further_period_details   csr_further_period_details%ROWTYPE;
   BEGIN
      OPEN csr_further_period_details;

      FETCH csr_further_period_details
       INTO lr_further_period_details;

      CLOSE csr_further_period_details;

      p_pay_saved_holiday :=
                         NVL (lr_further_period_details.prd_information1, 'N');
      p_no_of_saved_days := lr_further_period_details.prd_information3;
      p_pay_remaining_saved_days :=
                         NVL (lr_further_period_details.prd_information4, 'N');
      p_pay_additional_holiday := lr_further_period_details.prd_information5;
      p_no_of_additional_holiday := lr_further_period_details.prd_information7;
      p_pay_remaining_addl_holiday :=
                                    lr_further_period_details.prd_information8;
      l_fixed_period := 1;
      RETURN l_fixed_period;
   END get_absence_day_with_as_per;

   FUNCTION update_entitlement_ran (p_tax_unit_id IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      UPDATE hr_organization_information
         SET org_information5 = 'Y'
       WHERE org_information_id =
                (SELECT hoi2.org_information_id
                   FROM hr_organization_units o1
                       ,hr_organization_information hoi1
                       ,hr_organization_information hoi2
                  WHERE hoi1.organization_id = o1.organization_id
                    AND hoi1.organization_id = p_tax_unit_id            --3134
                    AND hoi1.org_information_context = 'CLASS'
                    AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
                    AND hoi1.organization_id = hoi2.organization_id
                    AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
                    AND hoi2.org_information1 IS NOT NULL);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END update_entitlement_ran;

   FUNCTION get_calendar_days (
      p_date_earned              IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_assignment_id            IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_pay_proc_period_end_date IN       DATE
     ,p_earn_end_date            OUT NOCOPY DATE
   )
      RETURN NUMBER
   IS
      l_end_month          CHAR (2);
      l_start_month        CHAR (2);
      l_end_date           DATE;
      l_start_date         DATE;
      l_days_year          NUMBER;
      l_status_return      CHAR (1);
      l_termination_date   DATE;
      l_year               NUMBER;

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi2.org_information1, 4, 2)
               ,SUBSTR (hoi2.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = p_tax_unit_id
            AND hoi1.org_information_context = 'CLASS'
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi2.org_information1 IS NOT NULL;

      CURSOR csr_assignment_start
      IS
         SELECT MIN (effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id;
   BEGIN
--l_year:=GET_END_YEAR(p_date_earned,p_tax_unit_id);
      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_start_month
           ,l_end_month;

      CLOSE csr_earning_year;

--l_end_date:=last_day(to_date('01/'||l_end_month||'/'||l_year,'dd/mm/yyyy'));

      --l_start_date:= to_date('01/'||l_start_month||'/'||l_year,'dd/mm/yyyy');
      IF l_start_month = '01' AND l_end_month = '12'
      THEN
         l_end_date :=
            LAST_DAY (TO_DATE (   '01/'
                               || l_end_month
                               || '/'
                               || TO_NUMBER (  TO_CHAR (p_date_earned, 'yyyy')
                                             - 1
                                            )
                              ,'dd/mm/yyyy'
                              )
                     );
         l_start_date :=
            TO_DATE (   '01/'
                     || l_start_month
                     || '/'
                     || TO_NUMBER (TO_CHAR (p_date_earned, 'yyyy') - 1)
                    ,'dd/mm/yyyy'
                    );
      ELSE
         l_end_date :=
            LAST_DAY (TO_DATE (   '01/'
                               || l_end_month
                               || '/'
                               || TO_NUMBER (TO_CHAR (p_date_earned, 'yyyy'))
                              ,'dd/mm/yyyy'
                              )
                     );
         l_start_date :=
            TO_DATE (   '01/'
                     || l_start_month
                     || '/'
                     || TO_NUMBER (TO_CHAR (p_date_earned, 'yyyy') - 1)
                    ,'dd/mm/yyyy'
                    );
      END IF;

      l_days_year := l_end_date - l_start_date;
      p_earn_end_date := l_end_date;
/*l_status_return:=get_assg_status(p_tax_unit_id,p_assignment_id,p_pay_proc_period_start_date,p_pay_proc_period_end_date ,l_termination_date);
IF  l_status_return='T' then
   l_days_year:=(l_termination_date-l_end_date+1);
ELSE
   l_days_year:=0;
END IF;*/
      RETURN l_days_year;
   END get_calendar_days;

   FUNCTION get_assg_status (
      p_business_group_id        IN       NUMBER
     ,p_asg_id                   IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_pay_proc_period_end_date IN       DATE
     ,p_termination_date         OUT NOCOPY DATE
   )
      RETURN VARCHAR2
   IS
      CURSOR csr_asg
      IS
         SELECT paaf.effective_start_date effective_start_date
           FROM per_all_assignments_f paaf
          WHERE paaf.business_group_id = p_business_group_id
            AND paaf.assignment_id = p_asg_id
            AND paaf.assignment_status_type_id = 3;

      l_flag         VARCHAR2 (1);
      l_asg_status   csr_asg%ROWTYPE;
   BEGIN
      OPEN csr_asg;

      FETCH csr_asg
       INTO l_asg_status;

      CLOSE csr_asg;

      p_termination_date := l_asg_status.effective_start_date;

      IF     l_asg_status.effective_start_date >= p_pay_proc_period_start_date
         AND l_asg_status.effective_start_date <=
                                             (p_pay_proc_period_end_date + 1
                                             )
      THEN
         l_flag := 'T';
      ELSE
         l_flag := 'A';
      END IF;

      RETURN l_flag;
   END get_assg_status;

   FUNCTION compensation_entitlement (
      p_date_earned              IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_assignment_id            IN       NUMBER
     ,p_assignment_action_id     IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_pay_proc_period_end_date IN       DATE
     ,p_paid_holiday_days        OUT NOCOPY NUMBER
     ,p_termination_date         IN       DATE
     ,p_earn_end_date            IN       DATE
   )
      RETURN NUMBER
   IS
      l_termination_date          DATE;
      l_year                      NUMBER;
      l_end_month                 CHAR (2);
      l_end_date                  DATE;
      l_status_return             CHAR (1);
      l_days_year                 NUMBER;
      l_worked_days_year	  NUMBER;
      lr_get_defined_balance_id   NUMBER;
      l_generate                  CHAR (1);
      l_max_days                  NUMBER;
      l_value                     NUMBER;
      l_absence_days              NUMBER        := 0;
      l_attendance_category_id    VARCHAR2 (30);
      l_business_group_id         NUMBER;
      l_paid_holiday_days         NUMBER;
      l_assignment_entitlement    NUMBER;
      l_person_entitlement        NUMBER;
      l_legal_entitlement         NUMBER;
      l_gen_entitlement           NUMBER;
      l_person_id                 NUMBER;
      l_working_perc              NUMBER;

      CURSOR csr_attendance_category_id
      IS
         SELECT DISTINCT eev1.screen_entry_value attendance_category_id
                    FROM per_all_assignments_f asg1
                         --,per_all_assignments_f      asg2
                        -- ,per_all_people_f         per
         ,               pay_element_links_f el
                        ,pay_element_types_f et
                        ,pay_input_values_f iv1
                        ,pay_element_entries_f ee
                        ,pay_element_entry_values_f eev1
                   WHERE asg1.assignment_id = p_assignment_id
                     AND p_date_earned BETWEEN asg1.effective_start_date
                                           AND asg1.effective_end_date
      --AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
   --   AND  per.person_id  = asg1.person_id
     -- AND  asg2.person_id    = per.person_id
--      AND  asg2.primary_flag    = 'Y'
      --AND  et.element_name   = 'Absence Details'
                     AND et.legislation_code = 'SE'
                     --OR et.business_group_id=3261     ) --checking for the business  group, it should be removed
                     AND iv1.element_type_id = et.element_type_id
                     AND iv1.NAME = 'Absence Category'        --l_inp_val_name
                     AND el.business_group_id = asg1.business_group_id
                     AND el.element_type_id = et.element_type_id
                     AND ee.assignment_id = asg1.assignment_id
                     AND ee.element_link_id = el.element_link_id
                     AND eev1.element_entry_id = ee.element_entry_id
                     AND eev1.input_value_id = iv1.input_value_id
                     AND ee.effective_start_date > p_earn_end_date
                     AND ee.effective_end_date <= p_termination_date
                     AND eev1.effective_start_date > p_earn_end_date
                     AND eev1.effective_end_date <= p_termination_date;

      CURSOR csr_generate_max_days
      IS
         SELECT hoi4.org_information2
               ,hoi4.org_information3
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_date_earned BETWEEN asg.effective_start_date
                                           AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            --AND   hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_ABSENCE_CATEGORY_LIMIT'
            AND hoi4.org_information1 IS NOT NULL
            AND hoi4.org_information1 = l_attendance_category_id;

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi2.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = p_tax_unit_id
            AND hoi1.org_information_context = 'CLASS'
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi2.org_information1 IS NOT NULL;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_date_earned BETWEEN asg.effective_start_date
                                           AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;
   BEGIN
      SELECT papf.business_group_id
            ,papf.person_id
            ,segment9
        INTO l_business_group_id
            ,l_person_id
            ,l_working_perc
        FROM per_all_assignments_f paaf
            ,per_all_people_f papf
            ,hr_soft_coding_keyflex hsck
       WHERE paaf.assignment_id = p_assignment_id                      --15381
         AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         AND papf.person_id = paaf.person_id
         AND p_date_earned BETWEEN paaf.effective_start_date
                               AND paaf.effective_end_date
         AND p_date_earned BETWEEN papf.effective_start_date
                               AND papf.effective_end_date;

      l_year := get_end_year (p_date_earned, p_tax_unit_id);

      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_end_month;

      CLOSE csr_earning_year;

      --l_end_date:=last_day(to_date('01/'||l_end_month||'/'||l_year,'dd/mm/yyyy'));

      /*l_status_return:=get_assg_status(p_tax_unit_id,p_assignment_id,p_pay_proc_period_start_date,p_pay_proc_period_end_date
       /*,l_termination_date);*/
      /*IF  l_status_return='T' then*/
      l_worked_days_year:= (p_termination_date - p_earn_end_date + 1);
      l_days_year:=(add_months(p_earn_end_date,12) - p_earn_end_date );

/* ELSE
      l_days_year:=0;
   END IF;*/
      OPEN csr_assignment_entitlement;

      FETCH csr_assignment_entitlement
       INTO l_assignment_entitlement;

      CLOSE csr_assignment_entitlement;

      OPEN csr_person_entitlement;

      FETCH csr_person_entitlement
       INTO l_person_entitlement;

      CLOSE csr_person_entitlement;

      OPEN csr_legal_employer_entitlement;

      FETCH csr_legal_employer_entitlement
       INTO l_legal_entitlement;

      CLOSE csr_legal_employer_entitlement;

      l_gen_entitlement :=
         NVL (l_assignment_entitlement
             ,NVL (l_person_entitlement, l_legal_entitlement)
             );

      FOR csr_category IN csr_attendance_category_id
      LOOP
         l_attendance_category_id := csr_category.attendance_category_id;
         pay_balance_pkg.set_context ('SOURCE_TEXT'
                                     ,csr_category.attendance_category_id
                                     );
         pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID'
                                     ,p_assignment_action_id
                                     );
         pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);

         -- pay_balance_pkg.set_context('DATE_EARNED',p_date_earned);
            --OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ABC_PER_YTD');
            --OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ABS_CAT_ASG_HY_YTD');
         OPEN csr_get_defined_balance_id
                      ('TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ASG_LE_ABS_CAT_HY_YEAR');

         FETCH csr_get_defined_balance_id
          INTO lr_get_defined_balance_id;

         CLOSE csr_get_defined_balance_id;

         /*l_value :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                      P_ASSIGNMENT_ACTION_ID =>p_assignment_action_id   )                    );*/
         l_value :=
            pay_balance_pkg.get_value
                        (p_defined_balance_id        => lr_get_defined_balance_id
                        ,p_assignment_action_id      => p_assignment_action_id
                        ,p_tax_unit_id               => p_tax_unit_id
                        ,p_jurisdiction_code         => NULL
                        ,p_source_id                 => NULL
                        ,p_source_text               => csr_category.attendance_category_id
                        ,p_tax_group                 => NULL
                        ,p_date_earned               => p_date_earned
                        );

         OPEN csr_generate_max_days;

         FETCH csr_generate_max_days
          INTO l_generate
              ,l_max_days;

         CLOSE csr_generate_max_days;

         /* If generate is Y then value greater than the max is considered as absence, else whole value */
         IF l_generate = 'Y'
         THEN
            IF l_value > l_max_days
            THEN
               l_absence_days := l_absence_days + (l_value - l_max_days);
            ELSE
               l_absence_days := l_absence_days;                -- + l_value;
            END IF;
         ELSE
            l_absence_days := l_absence_days + l_value;
         END IF;
      END LOOP;

      /*IF l_absence_days IS NULL or l_absence_days=0 THEN

         l_paid_holiday_days:=25;
         l_unpaid_holiday_days:=0;
               p_total_working_days:=l_days_year;
      ELSE*/
      /*l_paid_holiday_days :=
         TRUNC (  0.01
                * l_working_perc
                * ((l_days_year - l_absence_days) / l_days_year)
                * l_gen_entitlement
               );

      IF (  0.01
          * l_working_perc
          * ((l_days_year - l_absence_days) / l_days_year)
          * l_gen_entitlement
         ) > l_paid_holiday_days
      THEN
         l_paid_holiday_days := l_paid_holiday_days + 1;
      END IF;*/
      l_paid_holiday_days:=ceil(((l_worked_days_year-l_absence_days)/l_days_year)*l_gen_entitlement) ;
      l_paid_holiday_days := LEAST (l_paid_holiday_days, l_gen_entitlement);
      /* l_unpaid_holiday_days:=l_gen_entitlement-l_paid_holiday_days;*/
         /*p_total_working_days:=(l_days_year-l_absence_days);*/

      /* END IF;*/
      p_paid_holiday_days := l_paid_holiday_days;
      /*p_unpaid_holiday_days:=l_unpaid_holiday_days;*/
      RETURN 0;
   END compensation_entitlement;

   FUNCTION get_sickness_days (
      p_assignment_action_id     IN       NUMBER
     ,p_assignment_id            IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_date_earned              IN       DATE
   )
      RETURN NUMBER
   IS
      l_termination_date          DATE;
      l_year                      NUMBER;
      l_end_month                 CHAR (2);
      l_end_date                  DATE;
      l_status_return             CHAR (1);
      l_days_year                 NUMBER;
      lr_get_defined_balance_id   NUMBER;
      l_generate                  CHAR (1);
      l_max_days                  NUMBER;
      l_value                     NUMBER;
      l_absence_days              NUMBER        := 0;
      l_attendance_category_id    VARCHAR2 (30);
      l_business_group_id         NUMBER;
      l_paid_holiday_days         NUMBER;
      l_assignment_entitlement    NUMBER;
      l_person_entitlement        NUMBER;
      l_legal_entitlement         NUMBER;
      l_gen_entitlement           NUMBER;
      l_person_id                 NUMBER;

      CURSOR csr_generate_max_days
      IS
         SELECT hoi4.org_information2
               ,hoi4.org_information3
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_date_earned BETWEEN asg.effective_start_date
                                           AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            --AND   hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_ABSENCE_CATEGORY_LIMIT'
            AND hoi4.org_information1 IS NOT NULL
            AND hoi4.org_information1 = 'S';

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi2.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = p_tax_unit_id
            AND hoi1.org_information_context = 'CLASS'
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi2.org_information1 IS NOT NULL;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
               , (SELECT TRIM (scl.segment2) AS org_id
                    FROM per_all_assignments_f asg
                        ,hr_soft_coding_keyflex scl
                   WHERE asg.assignment_id = p_assignment_id
                     AND asg.soft_coding_keyflex_id =
                                                    scl.soft_coding_keyflex_id
                     AND p_date_earned BETWEEN asg.effective_start_date
                                           AND asg.effective_end_date) x
          WHERE o1.business_group_id = l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = x.org_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;
   BEGIN
      --l_attendance_category_id:='V';
      pay_balance_pkg.set_context ('SOURCE_TEXT', 'S');
      pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID'
                                  ,p_assignment_action_id
                                  );
      pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);

      --pay_balance_pkg.set_context('DATE_EARNED',p_date_earned);
      --OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ABC_PER_YTD');
      --OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ABS_CAT_ASG_YTD');
      OPEN csr_get_defined_balance_id
                    ('TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ASG_LE_ABS_CAT_EARN_YEAR');

      FETCH csr_get_defined_balance_id
       INTO lr_get_defined_balance_id;

      CLOSE csr_get_defined_balance_id;

      /*l_value :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                   P_ASSIGNMENT_ACTION_ID =>p_assignment_action_id   )                    );*/
      l_value :=
         pay_balance_pkg.get_value
                           (p_defined_balance_id        => lr_get_defined_balance_id
                           ,p_assignment_action_id      => p_assignment_action_id
                           ,p_tax_unit_id               => p_tax_unit_id
                           ,p_jurisdiction_code         => NULL
                           ,p_source_id                 => NULL
                           ,p_source_text               => 'S'
                           ,p_tax_group                 => NULL
                           ,p_date_earned               => p_date_earned
                           );

      OPEN csr_generate_max_days;

      FETCH csr_generate_max_days
       INTO l_generate
           ,l_max_days;

      CLOSE csr_generate_max_days;

      /* If generate is Y then value greater than the max is considered as absence, else whole value */
      IF l_generate = 'Y'
      THEN
         IF l_value > l_max_days
         THEN
            l_absence_days := l_absence_days + (l_value - l_max_days);
         ELSE
            l_absence_days := l_absence_days;                   -- + l_value;
         END IF;
      ELSE
         l_absence_days := l_absence_days + l_value;
      END IF;

      RETURN l_absence_days;
   END get_sickness_days;

   FUNCTION check_advance_holiday_limit (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
   )
      RETURN VARCHAR2
   IS
      l_advance_holiday_year_limit   NUMBER;
      l_assignment_start_date        DATE;
      l_months_worked                NUMBER;

      CURSOR csr_global_value (csr_v_effective_date DATE)
      IS
         SELECT global_value
           FROM ff_globals_f fgf
          WHERE csr_v_effective_date BETWEEN effective_start_date
                                         AND effective_end_date
            AND GLOBAL_NAME = 'SE_ADVANCE_HOLIDAY_YEAR_LIMIT';

      CURSOR csr_assignment_start (csr_v_assignment_id NUMBER)
      IS
         SELECT MIN (effective_start_date)
           FROM per_all_assignments_f paaf
          WHERE paaf.assignment_id = csr_v_assignment_id;
   BEGIN
      OPEN csr_assignment_start (p_assignment_id);

      FETCH csr_assignment_start
       INTO l_assignment_start_date;

      CLOSE csr_assignment_start;

      --dbms_output.put_line(' l_assignment_start_date'||l_assignment_start_date);
      l_months_worked :=
                       MONTHS_BETWEEN (p_date_earned, l_assignment_start_date);

      -- DBMS_OUTPUT.put_line(' l_months_worked'||l_months_worked);
      OPEN csr_global_value (p_date_earned);

      FETCH csr_global_value
       INTO l_advance_holiday_year_limit;

      CLOSE csr_global_value;

      --DBMS_OUTPUT.put_line(' l_months_worked'||l_months_worked);
      l_advance_holiday_year_limit := l_advance_holiday_year_limit * 12;

      --DBMS_OUTPUT.put_line(' l_months_worked'||l_months_worked);
      /* check whether he has worked for more than the year for advance year limit */
      IF l_months_worked >= l_advance_holiday_year_limit
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END check_advance_holiday_limit;

   FUNCTION get_cy_start_date (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_payroll_start_date       IN       DATE
     ,p_payroll_end_date         IN       DATE
     ,p_cy_start_date            OUT NOCOPY DATE
     ,p_cy_end_date              OUT NOCOPY DATE
   )
      RETURN VARCHAR2
   IS
      l_business_group_id        NUMBER;
      l_start_month              NUMBER;
      l_end_month                NUMBER;
      l_cy_start_date            DATE;
      l_cy_end_date              DATE;
      l_assignment_start         DATE;
      l_year                     NUMBER;
      l_payroll_id               NUMBER;
      l_min_payroll_start_date   DATE;

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi4.org_information1, 4, 2)
               ,SUBSTR (hoi4.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
          WHERE o1.business_group_id = l_business_group_id
            AND o1.organization_id = hoi3.organization_id
            AND hoi3.organization_id = p_tax_unit_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi4.org_information1 IS NOT NULL;

      CURSOR csr_assignment_start
      IS
         SELECT MIN (effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id;

      CURSOR csr_payroll_id
      IS
         SELECT payroll_id
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

      CURSOR csr_first_payroll_start_date (v_payroll_id NUMBER, v_date DATE)
      IS
         SELECT MIN (start_date)
           FROM per_time_periods
          WHERE payroll_id = v_payroll_id AND start_date >= v_date;
   BEGIN
      l_business_group_id := p_business_group_id;

      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_start_month
           ,l_end_month;

      CLOSE csr_earning_year;

      IF l_start_month IS NULL AND l_end_month IS NULL
      THEN
         RETURN 'N';
      ELSE
         /* Logic for Earning Year is from Jan-Dec */
         IF l_start_month = '01' AND l_end_month = '12'
         THEN
            l_year := TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY'));
         ELSE
            IF TO_NUMBER (TO_CHAR (p_effective_date, 'MM')) <
                                                    TO_NUMBER (l_start_month)
            THEN
               l_year := TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1);
            ELSE
               l_year := TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY'));
            END IF;
         END IF;

         -- get the start date of the Holiday year
         l_cy_start_date :=
               TO_DATE ('01/' || l_start_month || '/' || l_year, 'dd/mm/yyyy');

         OPEN csr_assignment_start;

         FETCH csr_assignment_start
          INTO l_assignment_start;

         CLOSE csr_assignment_start;

         l_cy_start_date := GREATEST (l_assignment_start, l_cy_start_date);
         l_cy_end_date :=
              TO_DATE ('01/' || l_start_month || '/' || l_year, 'dd/mm/yyyy')
            + 360;
         --l_cy_end_date:=least(last_day(l_cy_end_date),p_payroll_end_date);
         l_cy_end_date := LAST_DAY (l_cy_end_date);
         p_cy_start_date := l_cy_start_date;
         p_cy_end_date := l_cy_end_date;

         OPEN csr_payroll_id;

         FETCH csr_payroll_id
          INTO l_payroll_id;

         CLOSE csr_payroll_id;

         --  hr_utility.trace(' In l_payroll_id => ' || l_payroll_id);
         OPEN csr_first_payroll_start_date (l_payroll_id, p_cy_start_date);

         FETCH csr_first_payroll_start_date
          INTO l_min_payroll_start_date;

         CLOSE csr_first_payroll_start_date;

         --     hr_utility.trace(' p_cy_start_date => ' || p_cy_start_date);
         --     hr_utility.trace(' p_cy_end_date => ' || p_cy_end_date);
         --     hr_utility.trace(' l_min_payroll_start_date => ' || l_min_payroll_start_date);

         --checking the l_earning_end_date+1 lies between the payroll periods for first payroll
         --period after earning year
         IF (l_min_payroll_start_date = p_payroll_start_date)
         THEN
               --IF (p_effective_date>=l_earning_start_date) AND (p_effective_date<=l_earning_end_date) THEN
               /* check whether the person has the assignment in the earning year */
            --    hr_utility.trace(' retuning => ' || 'FIRST');
            RETURN 'FIRST';
         ELSE
            --   hr_utility.trace(' retuning => ' || 'OTHERS');
            RETURN 'OTHERS';
         END IF;
       --checking the earning_end_date lies between payroll_start and end_date, to find the last payroll
       --period
       /*ELSIF  (p_pay_start_date>=l_earning_end_date) AND (l_earning_end_date<= p_pay_end_date)   THEN
      RETURN 'L';*/
       --ELSE
--    return 'N';
--     end  if;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END get_cy_start_date;

   FUNCTION get_paid_days_limit (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_person_id                NUMBER;
      l_business_group_id        NUMBER;
      l_assignment_entitlement   NUMBER;
      l_person_entitlement       NUMBER;
      l_legal_entitlement        NUMBER;
      l_paid_holiday_days        NUMBER;

      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
          WHERE o1.business_group_id = l_business_group_id
            AND o1.organization_id = hoi3.organization_id
            AND hoi3.organization_id = p_tax_unit_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;

      CURSOR csr_get_details
      IS
         SELECT papf.business_group_id
               ,papf.person_id
           FROM per_all_assignments_f paaf
               ,per_all_people_f papf
               ,hr_soft_coding_keyflex hsck
          WHERE paaf.assignment_id = p_assignment_id                   --15381
            --AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
            AND papf.person_id = paaf.person_id
            AND p_effective_date BETWEEN paaf.effective_start_date
                                     AND paaf.effective_end_date
            AND p_effective_date BETWEEN papf.effective_start_date
                                     AND papf.effective_end_date;
   BEGIN
      l_paid_holiday_days := 0;

      OPEN csr_get_details;

      FETCH csr_get_details
       INTO l_business_group_id
           ,l_person_id;

      CLOSE csr_get_details;

      OPEN csr_assignment_entitlement;

      FETCH csr_assignment_entitlement
       INTO l_assignment_entitlement;

      CLOSE csr_assignment_entitlement;

      OPEN csr_person_entitlement;

      FETCH csr_person_entitlement
       INTO l_person_entitlement;

      CLOSE csr_person_entitlement;

      OPEN csr_legal_employer_entitlement;

      FETCH csr_legal_employer_entitlement
       INTO l_legal_entitlement;

      CLOSE csr_legal_employer_entitlement;

      l_paid_holiday_days :=
         NVL (l_assignment_entitlement
             ,NVL (l_person_entitlement, l_legal_entitlement)
             );
      RETURN l_paid_holiday_days;
   END get_paid_days_limit;

   FUNCTION get_cy_paid_unpaid_days (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_assignment_action_id     IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_cy_start_date            IN       DATE
     ,p_cy_end_date              IN       DATE
     ,p_paid_holiday_days        OUT NOCOPY NUMBER
     ,p_unpaid_holiday_days      OUT NOCOPY NUMBER
   --p_total_working_days OUT nocopy NUMBER
   )
      RETURN NUMBER
   IS
      l_person_id                 NUMBER;
      l_business_group_id         NUMBER;
      l_assignment_entitlement    NUMBER;
      l_person_entitlement        NUMBER;
      l_legal_entitlement         NUMBER;
      l_gen_entitlement           NUMBER;
      lr_get_defined_balance_id   NUMBER;
      l_value                     NUMBER;
      l_generate                  VARCHAR (1);
      l_max_days                  NUMBER;
      l_days_year                 NUMBER;
      l_work_days_year            NUMBER;
      l_absence_days              NUMBER        := 0;
      l_paid_holiday_days         NUMBER;
      l_unpaid_holiday_days       NUMBER;
      l_saved_days                NUMBER;
      l_assignment_start          DATE;
      l_attendance_category_id    VARCHAR2 (30);
      l_working_perc              NUMBER;
      l_days                      NUMBER;

      CURSOR csr_assignment_entitlement
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = 'SE_ASSIGN_HOLIDAY_PAY_DETAILS';

      CURSOR csr_person_entitlement
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = l_person_id
            AND information_type = 'SE_PERSON_HOLIDAY_PAY_DETAILS';

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
          WHERE o1.business_group_id = l_business_group_id
            AND o1.organization_id = hoi3.organization_id
            AND hoi3.organization_id = p_tax_unit_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;

      CURSOR csr_attendance_category_id
      IS
         SELECT DISTINCT eev1.screen_entry_value attendance_category_id
                    FROM per_all_assignments_f asg1
                        ,pay_element_links_f el
                        ,pay_element_types_f et
                        ,pay_input_values_f iv1
                        ,pay_element_entries_f ee
                        ,pay_element_entry_values_f eev1
                   WHERE asg1.assignment_id = p_assignment_id
                     AND p_effective_date BETWEEN asg1.effective_start_date
                                              AND asg1.effective_end_date
                     AND et.legislation_code = 'SE'
                     AND iv1.element_type_id = et.element_type_id
                     AND iv1.NAME = 'Absence Category'        --l_inp_val_name
                     AND el.business_group_id = asg1.business_group_id
                     AND el.element_type_id = et.element_type_id
                     AND ee.assignment_id = asg1.assignment_id
                     AND ee.element_link_id = el.element_link_id
                     AND eev1.element_entry_id = ee.element_entry_id
                     AND eev1.input_value_id = iv1.input_value_id
                     AND ee.effective_start_date <= p_cy_end_date
                     AND ee.effective_end_date >= p_cy_start_date
                     AND eev1.effective_start_date <= p_cy_end_date
                     AND eev1.effective_end_date >= p_cy_start_date
                     AND et.element_name NOT IN
                            ('Advance Holiday Details', 'Advance Holiday Pay');

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      CURSOR csr_generate_max_days
      IS
         SELECT hoi4.org_information2
               ,hoi4.org_information3
           FROM hr_organization_units o1
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
          WHERE o1.business_group_id = l_business_group_id
            AND hoi3.organization_id = o1.organization_id
            AND hoi3.organization_id = p_tax_unit_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_ABSENCE_CATEGORY_LIMIT'
            AND hoi4.org_information1 IS NOT NULL
            AND hoi4.org_information1 = l_attendance_category_id;

      CURSOR csr_assignment_start
      IS
         SELECT MIN (effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id;
   BEGIN
      SELECT papf.business_group_id
            ,papf.person_id
            ,segment9
        INTO l_business_group_id
            ,l_person_id
            ,l_working_perc
        FROM per_all_assignments_f paaf
            ,per_all_people_f papf
            ,hr_soft_coding_keyflex hsck
       WHERE paaf.assignment_id = p_assignment_id
         AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         AND papf.person_id = paaf.person_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND p_effective_date BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date;

--        hr_utility.trace(' l_person_id => ' || l_person_id);

      /* To get the entitlement */
      OPEN csr_assignment_entitlement;

      FETCH csr_assignment_entitlement
       INTO l_assignment_entitlement;

      CLOSE csr_assignment_entitlement;

--        hr_utility.trace(' l_assignment_entitlement => ' || l_assignment_entitlement);
      OPEN csr_person_entitlement;

      FETCH csr_person_entitlement
       INTO l_person_entitlement;

      CLOSE csr_person_entitlement;

--        hr_utility.trace(' l_person_entitlement => ' || l_person_entitlement);
      OPEN csr_legal_employer_entitlement;

      FETCH csr_legal_employer_entitlement
       INTO l_legal_entitlement;

      CLOSE csr_legal_employer_entitlement;

--        hr_utility.trace(' l_legal_entitlement => ' || l_legal_entitlement);
      l_gen_entitlement :=
         NVL (l_assignment_entitlement
             ,NVL (l_person_entitlement, l_legal_entitlement)
             );

--        hr_utility.trace(' l_gen_entitlement => ' || l_gen_entitlement);
      OPEN csr_assignment_start;

      FETCH csr_assignment_start
       INTO l_assignment_start;

      CLOSE csr_assignment_start;

--        hr_utility.trace(' l_assignment_start => ' || l_assignment_start);

      /* After discussing with vinod, assignment start date should not be considered while
      calculating the number of days in a year, entitlement calculation, changing the same on 20-sep-2006 */
      l_work_days_year :=
         (p_cy_end_date - (GREATEST (p_cy_start_date, l_assignment_start)) + 1
         );
      l_days_year := (p_cy_end_date - p_cy_start_date + 1);

--        hr_utility.trace(' p_cy_start_date => ' || p_cy_start_date);
--        hr_utility.trace(' p_cy_end_date => ' || p_cy_end_date);

      --        hr_utility.trace(' l_work_days_year => ' || l_work_days_year);
--        hr_utility.trace(' l_days_year => ' || l_days_year);
      FOR csr_category IN csr_attendance_category_id
      LOOP
         l_attendance_category_id := csr_category.attendance_category_id;
         pay_balance_pkg.set_context ('SOURCE_TEXT'
                                     ,csr_category.attendance_category_id
                                     );
         pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID'
                                     ,p_assignment_action_id
                                     );
         pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);

         OPEN csr_get_defined_balance_id
                      ('TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ASG_LE_ABS_CAT_HY_YEAR');

         FETCH csr_get_defined_balance_id
          INTO lr_get_defined_balance_id;

         CLOSE csr_get_defined_balance_id;

         l_value :=
            pay_balance_pkg.get_value
                        (p_defined_balance_id        => lr_get_defined_balance_id
                        ,p_assignment_action_id      => p_assignment_action_id
                        ,p_tax_unit_id               => p_tax_unit_id
                        ,p_jurisdiction_code         => NULL
                        ,p_source_id                 => NULL
                        ,p_source_text               => csr_category.attendance_category_id
                        ,p_tax_group                 => NULL
                        ,p_date_earned               => p_effective_date
                        );
        l_generate := NULL;
        l_max_days := 0;
         OPEN csr_generate_max_days;

         FETCH csr_generate_max_days
          INTO l_generate
              ,l_max_days;

         CLOSE csr_generate_max_days;

--        hr_utility.trace(' csr_Category.Attendance_Category_Id => ' || csr_Category.Attendance_Category_Id);
--        hr_utility.trace(' l_value => ' || l_value);
--        hr_utility.trace(' l_max_days => ' || l_max_days);
--        hr_utility.trace(' l_generate => ' || l_generate);

         /* If generate is Y then value greater than the max is considered as absence, else whole value */
         IF l_generate = 'Y'
         THEN
--        hr_utility.trace(' In Y Y Y => ' || l_absence_days);
            IF l_value > l_max_days
            THEN
               l_absence_days := l_absence_days + (l_value - l_max_days);
            ELSE
               l_absence_days := l_absence_days + l_value;
            END IF;
--        hr_utility.trace(' OUT OUT Y Y Y => ' || l_absence_days);
         ELSIF l_generate IS NOT NULL
         THEN
--        hr_utility.trace(' In No No No => ' || l_absence_days);
            l_absence_days := l_absence_days + l_value;
--        hr_utility.trace(' OUT OUT No No No => ' || l_absence_days);
         END IF;
      END LOOP;

--        hr_utility.trace(' l_absence_days => ' || l_absence_days);

      --       l_paid_holiday_days:=trunc(0.01*l_working_perc*((l_work_days_year-l_absence_days)/l_days_year)*l_gen_entitlement) ;
      l_paid_holiday_days :=
         CEIL (  ((l_work_days_year - l_absence_days) / l_days_year)
               * l_gen_entitlement
              );
--        hr_utility.trace(' l_paid_holiday_days => ' || l_paid_holiday_days);

      --        hr_utility.trace(' l_gen_entitlement => ' || l_gen_entitlement);
      l_unpaid_holiday_days := l_gen_entitlement - l_paid_holiday_days;
--        p_total_working_days:=(l_work_days_year-l_absence_days);
--        hr_utility.trace(' l_unpaid_holiday_days => ' || l_unpaid_holiday_days);

      --    p_paid_holiday_days:=l_gen_entitlement - l_paid_holiday_days;
      p_paid_holiday_days := l_paid_holiday_days;
      p_unpaid_holiday_days := l_unpaid_holiday_days;
--       hr_utility.trace(' p_paid_holiday_days => ' || p_paid_holiday_days);
--       hr_utility.trace(' p_unpaid_holiday_days => ' || p_unpaid_holiday_days);
      RETURN 0;
   END get_cy_paid_unpaid_days;

   FUNCTION get_earning_year (p_date_earned IN DATE, p_tax_unit_id IN NUMBER)
      RETURN NUMBER
   IS
      l_start_month   CHAR (2);
      l_end_month     CHAR (2);

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi2.org_information1, 4, 2)
               ,SUBSTR (hoi2.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = p_tax_unit_id                    --3134
            AND hoi1.org_information_context = 'CLASS'
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi2.org_information1 IS NOT NULL;
   BEGIN
      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_start_month
           ,l_end_month;

      CLOSE csr_earning_year;

      /* Logic for Earning Year is from Jan-Dec */
      IF l_start_month = '01' AND l_end_month = '12'
      THEN
         RETURN TO_NUMBER (TO_CHAR (p_date_earned, 'YYYY') - 1);
      ELSE
         IF TO_NUMBER (TO_CHAR (p_date_earned, 'MM')) <
                                                    TO_NUMBER (l_start_month)
         THEN
            RETURN TO_NUMBER (TO_CHAR (p_date_earned, 'YYYY') - 1);
         ELSE
            RETURN TO_NUMBER (TO_CHAR (p_date_earned, 'YYYY'));
         END IF;
      END IF;
   END get_earning_year;

   FUNCTION get_employee_category_type (
      p_asg_id                   IN       NUMBER
     ,p_business_group_id        IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      l_start_month        NUMBER;
      l_end_month          NUMBER;
      l_cy_start_date      DATE;
      l_assignment_start   DATE;
      l_year               NUMBER;
      l_what_collar        VARCHAR2 (50);

      CURSOR csr_asg_employee_category (csr_v_effective_date DATE)
      IS
         SELECT employee_category
           FROM per_all_assignments_f
          WHERE assignment_id = p_asg_id
            AND csr_v_effective_date BETWEEN effective_start_date
                                         AND effective_end_date;
   BEGIN
      OPEN csr_asg_employee_category (p_pay_proc_period_start_date);

      FETCH csr_asg_employee_category
       INTO l_what_collar;

      CLOSE csr_asg_employee_category;

      RETURN NVL(l_what_collar,'ORACLE_NO_COLLAR');
   END get_employee_category_type;

   FUNCTION get_coincident_holiday_year (
      p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      l_what_year   VARCHAR2 (50);

      CURSOR csr_get_concidental
      IS
         SELECT hoi4.org_information6
           FROM hr_organization_units o1
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
          WHERE o1.business_group_id = p_business_group_id
            AND o1.organization_id = hoi3.organization_id
            AND hoi3.organization_id = p_tax_unit_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi4.org_information1 IS NOT NULL;
   BEGIN
      OPEN csr_get_concidental;

      FETCH csr_get_concidental
       INTO l_what_year;

      CLOSE csr_get_concidental;

      RETURN l_what_year;
   END get_coincident_holiday_year;

   FUNCTION get_min_assignment_start (p_assignment_id IN NUMBER)
      RETURN DATE
   IS
      l_return   DATE;
   BEGIN
      SELECT MIN (effective_start_date)
        INTO l_return
        FROM per_all_assignments_f
       WHERE assignment_id = p_assignment_id;

      RETURN l_return;
   END get_min_assignment_start;

   FUNCTION part_time_employee (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_full_time                OUT NOCOPY NUMBER
     ,p_days_week                OUT NOCOPY NUMBER
   )
      RETURN VARCHAR2
   IS
      l_days_week   NUMBER;
      l_full_time   NUMBER := 5;

      CURSOR csr_part_time (
         csr_v_assignment_id                 NUMBER
        ,csr_v_effective_date                DATE
      )
      IS
         SELECT nvl(TRUNC
                   (fnd_number.canonical_to_number (segment13)),l_full_time)
/* change this to the field which we are going to add for part time employee */
           FROM per_all_assignments_f paaf
               ,
-- per_all_people_f papf,
                hr_soft_coding_keyflex hsck
          WHERE paaf.assignment_id = csr_v_assignment_id               --15381
            AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
            --AND papf.person_id=paaf.person_id
            AND csr_v_effective_date BETWEEN paaf.effective_start_date
                                         AND paaf.effective_end_date;
   --AND p_effective_date BETWEEN papf.effective_start_date
   --AND papf.effective_end_date;
   BEGIN
      OPEN csr_part_time (p_assignment_id, p_date_earned);

      FETCH csr_part_time
       INTO l_days_week;

      CLOSE csr_part_time;

      p_full_time := l_full_time;
      p_days_week := l_days_week;

      IF l_days_week = l_full_time
      THEN
         RETURN 'N';
      ELSE
         RETURN 'Y';
      END IF;
   END part_time_employee;

   FUNCTION get_holiday_pay_agreement_row (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_business_group_id        IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      l_row_id     NUMBER;
      l_row_name   VARCHAR2 (240);

      CURSOR csr_get_details (
         csr_v_assignment_id                 NUMBER
        ,csr_v_effective_date                DATE
      )
      IS
         SELECT segment12
           FROM per_all_assignments_f paaf
               ,hr_soft_coding_keyflex hsck
          WHERE paaf.assignment_id = csr_v_assignment_id
            AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
            AND csr_v_effective_date BETWEEN paaf.effective_start_date
                                         AND paaf.effective_end_date;

      CURSOR csr_get_row_name (csr_v_row_id NUMBER, csr_v_effective_date DATE)
      IS
         SELECT r.row_low_range_or_name
           FROM pay_user_rows_f r
               ,pay_user_tables t
          WHERE r.legislation_code IS NULL
            AND t.legislation_code = 'SE'
            AND UPPER (t.user_table_name) = UPPER ('SE_HOLIDAY_PAY_AGREEMENT')
            AND t.user_table_id = r.user_table_id
            AND r.business_group_id = p_business_group_id
            AND r.user_row_id = csr_v_row_id
            AND csr_v_effective_date BETWEEN r.effective_start_date
                                         AND r.effective_end_date;
   BEGIN
      OPEN csr_get_details (p_assignment_id, p_date_earned);

      FETCH csr_get_details
       INTO l_row_id;

      CLOSE csr_get_details;

      OPEN csr_get_row_name (l_row_id, p_date_earned);

      FETCH csr_get_row_name
       INTO l_row_name;

      CLOSE csr_get_row_name;

      RETURN NVL(l_row_name,'ORACLENULL');
   END get_holiday_pay_agreement_row;

   FUNCTION get_ey_start_end_date (
      p_effective_date           IN       DATE
     ,p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_ey_start_date            OUT NOCOPY DATE
     ,p_ey_end_date              OUT NOCOPY DATE
   )
      RETURN VARCHAR2
   IS
      l_business_group_id        NUMBER;
      l_start_month              NUMBER;
      l_end_month                NUMBER;
      l_ey_start_date            DATE;
      l_ey_end_date              DATE;
      l_assignment_start         DATE;
      l_year                     NUMBER;
      l_payroll_id               NUMBER;
      l_min_payroll_start_date   DATE;

      CURSOR csr_earning_year
      IS
         SELECT SUBSTR (hoi4.org_information1, 4, 2)
               ,SUBSTR (hoi4.org_information2, 4, 2)
           FROM hr_organization_units o1
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
          WHERE o1.business_group_id = l_business_group_id
            AND o1.organization_id = hoi3.organization_id
            AND hoi3.organization_id = p_tax_unit_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
            AND hoi4.org_information1 IS NOT NULL;
   BEGIN
      l_business_group_id := p_business_group_id;

      OPEN csr_earning_year;

      FETCH csr_earning_year
       INTO l_start_month
           ,l_end_month;

      CLOSE csr_earning_year;

      IF l_start_month IS NULL AND l_end_month IS NULL
      THEN
         RETURN 'N';
      ELSE
         l_ey_start_date :=
            TO_DATE (   '01/'
                     || l_start_month
                     || '/'
                     || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                    ,'dd/mm/yyyy'
                    );
         l_ey_end_date :=
              TO_DATE (   '01/'
                       || l_start_month
                       || '/'
                       || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                      ,'dd/mm/yyyy'
                      )
            + 360;
         -- get the start date of the Holiday year
         l_ey_end_date := LAST_DAY (l_ey_end_date);
         p_ey_start_date := l_ey_start_date;
         p_ey_end_date := l_ey_end_date;
         RETURN 'Y';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END get_ey_start_end_date;

   FUNCTION get_avg_working_percentage (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_work_percentage   NUMBER;
      l_ey_start_date     DATE;
      l_ey_end_date       DATE;
      l_call_sub_fun      VARCHAR2 (10);

/*
  Cursor csr_all_asg_EYear(csr_v_ey_start date,csr_v_ey_end date)
   is
   SELECT paaf.business_group_id,
      paaf.person_id,
      segment9
      FROM per_all_assignments_f paaf,
      hr_soft_coding_keyflex hsck
      WHERE paaf.assignment_id = p_assignment_id --15381
      AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
   AND paaf.effective_start_date <= l_ey_end_date
    AND paaf.effective_end_date >= l_ey_start_date;
*/
--((csr_v_ey_end - csr_v_ey_start) + 1)
      CURSOR csr_get_all_asg_eyear (csr_v_ey_start DATE, csr_v_ey_end DATE)
      IS
         SELECT ROUND (SUM (perc * days) / sum(days)
                      ,2
                      )
           FROM (SELECT
--      paaf.business_group_id,
--    paaf.person_id,
--    greatest(paaf.effective_start_date,'01-Apr-2000'),
--    least(paaf.effective_end_date,'31-Mar-2001'),
                        segment9 perc
                       ,   LEAST (paaf.effective_end_date, csr_v_ey_end)
                         - GREATEST (paaf.effective_start_date
                                    ,csr_v_ey_start)
                         + 1 "DAYS"
                   FROM per_all_assignments_f paaf
                       ,hr_soft_coding_keyflex hsck
                  WHERE paaf.assignment_id = p_assignment_id
                    AND paaf.soft_coding_keyflex_id =
                                                   hsck.soft_coding_keyflex_id
                    AND paaf.effective_start_date <= csr_v_ey_end
                    AND paaf.effective_end_date >= csr_v_ey_start);
   BEGIN
      l_call_sub_fun :=
         get_ey_start_end_date (p_effective_date
                               ,p_business_group_id
                               ,p_tax_unit_id
                               ,l_ey_start_date
                               ,l_ey_end_date
                               );

      IF l_call_sub_fun = 'Y'
      THEN
         OPEN csr_get_all_asg_eyear (l_ey_start_date, l_ey_end_date);

         FETCH csr_get_all_asg_eyear
          INTO l_work_percentage;

         CLOSE csr_get_all_asg_eyear;
      ELSE
         l_work_percentage := 0;
      END IF;

      RETURN l_work_percentage;
   END get_avg_working_percentage;

   FUNCTION get_employee_age_experience (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
   )
      RETURN varchar2
   IS
      l_days_in_year       NUMBER := 365;
      l_months_in_year     NUMBER := 12;
      l_months_between     NUMBER;
      l_assignment_start   DATE;
      l_prev_exp_days      NUMBER;
      l_curr_exp_days      NUMBER;

      CURSOR csr_assignment_start
      IS
         SELECT MIN (effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id;

      CURSOR csr_get_dob
      IS
         SELECT TRUNC (MONTHS_BETWEEN (p_effective_date, papf.date_of_birth))
           FROM per_all_assignments_f paaf
               ,per_all_people_f papf
          WHERE paaf.assignment_id = p_assignment_id
            AND papf.person_id = paaf.person_id
            AND p_effective_date BETWEEN paaf.effective_start_date
                                     AND paaf.effective_end_date
            AND p_effective_date BETWEEN papf.effective_start_date
                                     AND papf.effective_end_date;

      CURSOR csr_get_prev_exp_days
      IS
         SELECT SUM (end_date - start_date)
           FROM per_previous_job_usages
          WHERE assignment_id = p_assignment_id;
   BEGIN
      OPEN csr_get_dob;

      FETCH csr_get_dob
       INTO l_months_between;

      CLOSE csr_get_dob;

      OPEN csr_assignment_start;

      FETCH csr_assignment_start
       INTO l_assignment_start;

      CLOSE csr_assignment_start;

      l_curr_exp_days := p_effective_date - l_assignment_start;

      OPEN csr_get_prev_exp_days;

      FETCH csr_get_prev_exp_days
       INTO l_prev_exp_days;

      CLOSE csr_get_prev_exp_days;

      IF (    l_months_between >= (18 * l_months_in_year)
          AND (l_curr_exp_days + l_prev_exp_days) >= (3 * l_days_in_year)
         )
      THEN
         RETURN 'ABOVE';
      ELSE
         RETURN 'BELOW';
      END IF;
   END get_employee_age_experience;

   FUNCTION get_sdays_wrking_percentage (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_first_year               IN       NUMBER
     ,p_second_year              IN       NUMBER
     ,p_third_year               IN       NUMBER
     ,p_fourth_year              IN       NUMBER
     ,p_fifth_year               IN       NUMBER
     ,p_sixth_year               IN       NUMBER
     ,p_seventh_year             IN       NUMBER
     ,p_all_years                IN       NUMBER
     ,p_saved_days_taken         IN       NUMBER
     ,p_saved_days_availed       IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_work_percentage         NUMBER;

      TYPE balance_tab IS VARRAY (7) OF NUMBER;

      balance_value             balance_tab;
      l_year                    NUMBER;
      l_already_taken           NUMBER;
      l_availed                 NUMBER;
      l_current_year_balance    NUMBER;
      l_sday_wrk_percentage     NUMBER        := 0;
      l_current_year_wrk_perc   NUMBER        := 0;
      l_exit                    VARCHAR2 (10);

      CURSOR csr_legal_employer_entitlement
      IS
         SELECT hoi4.org_information2
           FROM hr_organization_units o1
               ,hr_organization_information hoi3
               ,hr_organization_information hoi4
          WHERE o1.business_group_id = p_business_group_id
            AND o1.organization_id = hoi3.organization_id
            AND hoi3.organization_id = p_tax_unit_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = hoi4.organization_id
            AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
            AND hoi4.org_information1 IS NOT NULL;
   BEGIN
      l_exit := 'FALSE';
      balance_value :=
         balance_tab (p_first_year
                     ,p_second_year
                     ,p_third_year
                     ,p_fourth_year
                     ,p_fifth_year
                     ,p_sixth_year
                     ,p_seventh_year
                     );

-- Get the Year value from the EIT
      OPEN csr_legal_employer_entitlement;

      FETCH csr_legal_employer_entitlement
       INTO l_year;

      CLOSE csr_legal_employer_entitlement;

--    DBMS_OUTPUT.Put_Line( l_year );
-- Assign the value from the input parameters
      l_already_taken := p_saved_days_taken;
      l_availed := p_saved_days_availed;

-- to ge teh init for the year and taken;
-- DBMS_OUTPUT.Put_Line( '********************' );
      WHILE (l_exit = 'FALSE' AND l_year > 0)
      LOOP
         l_current_year_balance := balance_value (l_year);

         IF l_current_year_balance = 0
         THEN
             l_year := l_year - 1;

         ELSIF (l_already_taken - l_current_year_balance) > 0
         THEN
--    DBMS_OUTPUT.Put_Line( l_current_year_balance );
            l_year := l_year - 1;
            l_already_taken := l_already_taken - l_current_year_balance;
--    DBMS_OUTPUT.Put_Line( l_year );
--    DBMS_OUTPUT.Put_Line( l_already_taken );
         ELSIF (l_already_taken - l_current_year_balance) = 0
         THEN
--    DBMS_OUTPUT.Put_Line( l_current_year_balance );
            l_year := l_year - 1;
            l_already_taken := l_already_taken - l_current_year_balance;
--    DBMS_OUTPUT.Put_Line( l_year );
--    DBMS_OUTPUT.Put_Line( l_already_taken );
            l_exit := 'TRUE';
         ELSE
            l_exit := 'TRUE';
         END IF;
--    DBMS_OUTPUT.Put_Line( '*%%%%%%%%%%%%%%%%%%%%' );
--    DBMS_OUTPUT.Put_Line( l_year );
--    DBMS_OUTPUT.Put_Line( l_already_taken );

      -- DBMS_OUTPUT.Put_Line( '*******************' );
      END LOOP;

-- end of teh init for the year and taken;
      l_exit := 'FALSE';

-- DBMS_OUTPUT.Put_Line( '11111111111111111111' );
      WHILE (l_exit = 'FALSE' AND l_year > 0)
      LOOP
         l_current_year_balance := balance_value (l_year);
--    DBMS_OUTPUT.Put_Line( 'current balance  ' ||l_current_year_balance );
         l_current_year_wrk_perc :=
            get_avg_working_percentage (p_assignment_id
                                       , ((p_effective_date) - 365 * l_year)
                                       ,p_business_group_id
                                       ,p_tax_unit_id
                                       );

--DBMS_OUTPUT.Put_Line( 'l_current_year_wrk_perc ' ||l_current_year_wrk_perc );
         IF ((l_already_taken + l_availed) > l_current_year_balance)
         THEN
-- DBMS_OUTPUT.Put_Line( 'Greater ');
            l_sday_wrk_percentage :=
                 l_sday_wrk_percentage
               +   (l_current_year_balance - l_already_taken)
                 * l_current_year_wrk_perc;
            l_availed :=
                        l_availed
                        - (l_current_year_balance - l_already_taken);
            l_already_taken := 0;
--    DBMS_OUTPUT.Put_Line( 'l_year ' ||l_year );
--    DBMS_OUTPUT.Put_Line( 'l_availed  '||l_availed );
--    DBMS_OUTPUT.Put_Line( ' sday ' ||l_sday_wrk_percentage );
         ELSIF ((l_already_taken + l_availed) = l_current_year_balance)
         THEN
-- DBMS_OUTPUT.Put_Line( 'Equal ');
            l_sday_wrk_percentage :=
                 l_sday_wrk_percentage
               +   (l_current_year_balance - l_already_taken)
                 * l_current_year_wrk_perc;
            l_availed :=
                        l_availed
                        - (l_current_year_balance - l_already_taken);
            l_already_taken := 0;
--    DBMS_OUTPUT.Put_Line( 'l_year ' ||l_year );
--    DBMS_OUTPUT.Put_Line( 'l_availed  '||l_availed );
--    DBMS_OUTPUT.Put_Line( ' sday ' ||l_sday_wrk_percentage );
            l_exit := 'TRUE';
         ELSE
-- DBMS_OUTPUT.Put_Line( 'Lesser');
            l_sday_wrk_percentage :=
                l_sday_wrk_percentage
                + (l_availed * l_current_year_wrk_perc);
--    DBMS_OUTPUT.Put_Line( 'l_year ' ||l_year );
--    DBMS_OUTPUT.Put_Line( 'l_availed  '||l_availed );
--    DBMS_OUTPUT.Put_Line( ' sday ' ||l_sday_wrk_percentage );
            l_exit := 'TRUE';
         END IF;

-- DBMS_OUTPUT.Put_Line( '@@@@@@@@@@@@@@@@@@@@@@@@@@' );

         --    DBMS_OUTPUT.Put_Line( 'l_year ' ||l_year );
--    DBMS_OUTPUT.Put_Line( 'l_availed  '||l_availed );
--    DBMS_OUTPUT.Put_Line( ' sday ' || l_sday_wrk_percentage );
         l_year := l_year - 1;
-- DBMS_OUTPUT.Put_Line( '*******************' );
      END LOOP;

      l_sday_wrk_percentage := ROUND (l_sday_wrk_percentage / 100, 2);
--    DBMS_OUTPUT.Put_Line( ' sday ' || l_sday_wrk_percentage );
      RETURN NVL(l_sday_wrk_percentage,0);
   END get_sdays_wrking_percentage;

PROCEDURE get_weekend_public_holidays (
   p_assignment_id            IN       NUMBER
  ,p_start_date               IN       DATE
  ,p_end_date                 IN       DATE
  ,p_start_time               IN       VARCHAR2
  ,p_end_time                 IN       VARCHAR2
  ,p_calc_type                IN       VARCHAR2
  ,p_total_holidays           OUT NOCOPY NUMBER
)
IS
   l_return_frm_wrk_schd       NUMBER;
   l_days_wth_public           NUMBER;
   l_days_wthout_public        NUMBER;
   l_total_days                NUMBER;
   l_current_public_holidays   NUMBER;
   l_current_weekends          NUMBER;
   l_start_date                DATE;
   l_end_date                  DATE;

   CURSOR get_total_days (csr_end_date DATE, csr_start_date DATE)
   IS
      SELECT FLOOR (csr_end_date - csr_start_date) + 1
        FROM DUAL;

   CURSOR get_time_format (l_time VARCHAR2)
   IS
      SELECT REPLACE (TRIM (l_time), ':', '.')
        FROM DUAL;

   l_start_time                VARCHAR2 (5);
   l_end_time                  VARCHAR2 (5);
BEGIN
   OPEN get_time_format (p_start_time);

   FETCH get_time_format
    INTO l_start_time;

   CLOSE get_time_format;

   OPEN get_time_format (p_end_time);

   FETCH get_time_format
    INTO l_end_time;

   CLOSE get_time_format;

   l_start_date :=
      TO_DATE (   TO_CHAR (p_start_date
                          ,'DD-MM-YYYY')
               || ' '
               || l_start_time
              ,'DD-MM-YYYY HH24:MI'
              );
   l_end_date :=
      TO_DATE (   TO_CHAR (p_end_date, 'DD-MM-YYYY')
               || ' '
               || l_end_time
              ,'DD-MM-YYYY HH24:MI'
              );

   OPEN get_total_days (l_end_date, l_start_date);

   FETCH get_total_days
    INTO l_total_days;

   CLOSE get_total_days;

-- Get Total days Excluding Public Holidays exculding Weekends
   l_return_frm_wrk_schd :=
      hr_loc_work_schedule.calc_sch_based_dur (p_assignment_id
                                              ,p_calc_type
                                              ,'N'
                                              ,p_start_date
                                              ,p_end_date
                                              ,l_start_time
                                              ,l_end_time
                                              ,l_days_wthout_public
                                              );
   p_total_holidays := l_days_wthout_public;
END get_weekend_public_holidays;

FUNCTION get_avg_earning_year_hours (
   p_assignment_id            IN       NUMBER
  ,p_effective_date           IN       DATE
  ,p_business_group_id        IN       NUMBER
  ,p_tax_unit_id              IN       NUMBER
  ,p_total_absence            IN       NUMBER
)
   RETURN NUMBER
IS
   l_hours           NUMBER;
   l_ey_start_date   DATE;
   l_ey_end_date     DATE;
   l_call_sub_fun    VARCHAR2 (10);

   CURSOR csr_get_all_asg_eyear (csr_v_ey_start DATE, csr_v_ey_end DATE)
   IS
      SELECT ROUND (SUM (perc * in_hours) / 100, 2)
        FROM (SELECT segment9 perc
                    ,   LEAST (paaf.effective_end_date, csr_v_ey_end)
                      - GREATEST (paaf.effective_start_date, csr_v_ey_start)
                      + 1 "DAYS"
                    ,normal_hours
                    ,frequency
                    ,segment13 days_in_week
                    ,CASE
                        WHEN frequency = 'D'
                           THEN   (  LEAST (paaf.effective_end_date
                                           ,csr_v_ey_end
                                           )
                                   - GREATEST (paaf.effective_start_date
                                              ,csr_v_ey_start
                                              )
                                   + 1
                                  )
                                * normal_hours
                        WHEN frequency = 'W'
                           THEN   (  LEAST (paaf.effective_end_date
                                           ,csr_v_ey_end
                                           )
                                   - GREATEST (paaf.effective_start_date
                                              ,csr_v_ey_start
                                              )
                                   + 1
                                  )
                                * (normal_hours / segment13)
                        WHEN frequency = 'M'
                           THEN   (  LEAST (paaf.effective_end_date
                                           ,csr_v_ey_end
                                           )
                                   - GREATEST (paaf.effective_start_date
                                              ,csr_v_ey_start
                                              )
                                   + 1
                                  )
                                * (  (normal_hours * 12)
                                   / (  (   (csr_v_ey_end)
                                         -  (csr_v_ey_start)
                                        )
                                      + 1
                                     )
                                  )
                     END "IN_HOURS"
                FROM per_all_assignments_f paaf
                    ,hr_soft_coding_keyflex hsck
               WHERE paaf.assignment_id = p_assignment_id
                 AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
                 AND paaf.effective_start_date <= csr_v_ey_end
                 AND paaf.effective_end_date >= csr_v_ey_start);
BEGIN
   l_hours := 0;
   l_call_sub_fun :=
      get_ey_start_end_date (p_effective_date
                            ,p_business_group_id
                            ,p_tax_unit_id
                            ,l_ey_start_date
                            ,l_ey_end_date
                            );

   IF l_call_sub_fun = 'Y'
   THEN
      get_weekend_public_holidays (p_assignment_id
                                  ,l_ey_start_date
                                  ,l_ey_end_date
                                  ,'00.00'
                                  ,'23.59'
                                  ,'H'
                                  ,l_hours
                                  );

      IF l_hours <= 0
      THEN
         OPEN csr_get_all_asg_eyear (l_ey_start_date, l_ey_end_date);

         FETCH csr_get_all_asg_eyear
          INTO l_hours;

         CLOSE csr_get_all_asg_eyear;
      END IF;
   ELSE
      l_hours := 0;
   END IF;

   l_hours :=
      ROUND (  l_hours
             -   (l_hours / ((l_ey_end_date - l_ey_start_date) + 1))
               * p_total_absence
            ,2
            );
   RETURN NVL (l_hours, 0);
END get_avg_earning_year_hours;


FUNCTION get_first_three_payroll_check (
   p_assignment_id            IN       NUMBER
  ,p_effective_date           IN       DATE
  ,p_business_group_id        IN       NUMBER
  ,p_tax_unit_id              IN       NUMBER
  ,p_pay_start_date           IN       DATE
  ,p_pay_end_date             IN       DATE
)
   RETURN VARCHAR2
IS
   l_business_group_id    NUMBER;
   l_start_month          NUMBER;
   l_end_month            NUMBER;
   l_earning_start_date   DATE;
   l_earning_end_date     DATE;
   l_assignment_start     DATE;

   CURSOR csr_earning_year
   IS
      SELECT SUBSTR (hoi2.org_information1, 4, 2)
            ,SUBSTR (hoi2.org_information2, 4, 2)
        FROM hr_organization_units o1
            ,hr_organization_information hoi1
            ,hr_organization_information hoi2
       WHERE hoi1.organization_id = o1.organization_id
         AND hoi1.organization_id = p_tax_unit_id                       --3134
         AND hoi1.org_information_context = 'CLASS'
         AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
         AND hoi1.organization_id = hoi2.organization_id
         AND hoi2.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
         AND hoi2.org_information1 IS NOT NULL;

   CURSOR csr_assignment_start
   IS
      SELECT MIN (effective_start_date)
        FROM per_all_assignments_f
       WHERE assignment_id = p_assignment_id;
BEGIN
   l_business_group_id := p_business_group_id;

   OPEN csr_earning_year;

   FETCH csr_earning_year
    INTO l_start_month
        ,l_end_month;

   CLOSE csr_earning_year;

   IF l_start_month IS NULL AND l_end_month IS NULL
   THEN
      RETURN 'N';
   ELSE
      l_earning_start_date :=
         TO_DATE (   '01/'
                  || l_start_month
                  || '/'
                  || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                 ,'dd/mm/yyyy'
                 );
      l_earning_end_date :=
           TO_DATE (   '01/'
                    || l_start_month
                    || '/'
                    || TO_NUMBER (TO_CHAR (p_effective_date, 'YYYY') - 1)
                   ,'dd/mm/yyyy'
                   )
         + 360;
      l_earning_end_date := LAST_DAY (l_earning_end_date);

      --checking the l_earning_end_date+1 lies between the payroll periods for first payroll
      --period after earning year
      IF     (p_pay_start_date <= (ADD_MONTHS (l_earning_end_date, 3)))
         AND (ADD_MONTHS (l_earning_end_date, 3) >= p_pay_end_date)
      THEN
         /* check whether the person has the assignment in the earning year */
         OPEN csr_assignment_start;

         FETCH csr_assignment_start
          INTO l_assignment_start;

         CLOSE csr_assignment_start;

         IF l_assignment_start <= l_earning_end_date
         THEN
            RETURN 'Y';
         ELSE
            RETURN 'N';
         END IF;
      ELSE
         RETURN 'N';
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 'N';
END get_first_three_payroll_check;


END pay_se_holiday_pay;

/
