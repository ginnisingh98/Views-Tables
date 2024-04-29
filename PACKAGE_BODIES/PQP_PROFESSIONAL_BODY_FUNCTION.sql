--------------------------------------------------------
--  DDL for Package Body PQP_PROFESSIONAL_BODY_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PROFESSIONAL_BODY_FUNCTION" AS
-- $Header: pqgbpbfn.pkb 115.4 2003/02/14 19:19:39 tmehra noship $

g_package            VARCHAR2(40) := 'pqp_professional_body_function.';
g_eei_info_type      VARCHAR2(40) := 'PQP_PROFESSIONAL_BODY_INFO';
-----------------------------------------------------------------------------
-- GET_ORGANIZATION_INFO
-----------------------------------------------------------------------------
FUNCTION  get_organization_info (p_element_type_id   IN      NUMBER -- Context
                                ,p_business_group_id IN      NUMBER -- Context
                                ,p_organization_id      OUT NOCOPY  NUMBER
                                ,p_error_message        OUT NOCOPY  VARCHAR2
                                )
RETURN NUMBER

IS

  l_proc     VARCHAR2(80) := g_package||'get_organization_info';
  l_ret_vlu  NUMBER(2)    := 0;

  CURSOR csr_get_organization_info
  IS
  SELECT TO_NUMBER(eei.eei_information1)
  FROM   pay_element_types_f          ele
        ,pay_element_type_extra_info  eei
        ,fnd_sessions                 fnd
  WHERE ele.element_type_id  = p_element_type_id
    AND eei.element_type_id  = ele.element_type_id
    AND (ele.business_group_id = p_business_group_id OR
         ele.legislation_code IS NOT NULL)
    AND eei.information_type = g_eei_info_type
    AND fnd.effective_date BETWEEN ele.effective_start_date
                               AND ele.effective_end_date
    AND fnd.session_id       = USERENV('sessionid');

  l_organization_id  NUMBER(15);

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  OPEN csr_get_organization_info;
  FETCH csr_get_organization_info INTO l_organization_id;

  IF csr_get_organization_info%NOTFOUND THEN

     --
     -- No row in Extra element information table
     --

     l_ret_vlu := -1;
     p_error_message := 'There is no extra information for this element.';

  ELSIF l_organization_id IS NULL THEN

     --
     -- Organization info not found
     --

     l_ret_vlu       := -1;
     p_error_message := 'There is no organization information for this element.';

  END IF; -- End if of not found check...
  CLOSE csr_get_organization_info;

  p_organization_id := l_organization_id;

  --
  hr_utility.set_location('Leaving: '||l_proc, 20);

  RETURN l_ret_vlu;
-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);
       p_error_message := SQLERRM;
       p_organization_id := NULL;
       raise;



END get_organization_info;

-----------------------------------------------------------------------------
-- GET_PB_MEM_INFO
-----------------------------------------------------------------------------
FUNCTION  get_pb_mem_info (p_assignment_id        IN     NUMBER -- Context
                          ,p_business_group_id    IN     NUMBER -- Context
                          ,p_organization_id      IN     NUMBER
                          ,p_pay_start_dt         IN      DATE
                          ,p_pay_end_dt           IN      DATE
                          ,p_professional_body_nm     OUT NOCOPY VARCHAR2
                          ,p_membership_category      OUT NOCOPY VARCHAR2
                          ,p_error_message            OUT NOCOPY VARCHAR2
                          )
RETURN NUMBER
IS

  l_proc         VARCHAR2(80)  := g_package || 'get_professional_mem_info';
  l_ret_vlu      NUMBER(2)     := 0;
  l_pay_start_dt DATE          := trunc(p_pay_start_dt);
  l_pay_end_dt   DATE          := trunc(p_pay_end_dt);

  CURSOR csr_get_person_id
  IS
  SELECT paa.person_id
  FROM per_all_assignments_f paa
  WHERE paa.assignment_id = p_assignment_id
    AND nvl(paa.business_group_id, p_business_group_id)
                          = p_business_group_id
    AND rownum = 1;

  l_person_id    NUMBER(15);

  CURSOR csr_get_pb_name
  IS
  SELECT hou.name
  FROM hr_all_organization_units hou
      ,hr_organization_information hoi
  WHERE hou.organization_id   = p_organization_id
    AND nvl(hou.business_group_id, p_business_group_id)
                              = p_business_group_id
    AND hoi.organization_id   = hou.organization_id
    AND hoi.org_information1  = 'PB'
    AND hoi.org_information_context = 'CLASS';

  l_pb_name  VARCHAR2(80);

  CURSOR csr_get_pb_mem_info (c_professional_body_nm IN VARCHAR2)
  IS
  SELECT qua.professional_body_name
        ,qua.membership_category
  FROM per_qualifications qua
  WHERE qua.person_id              = l_person_id
    AND qua.professional_body_name = c_professional_body_nm
    AND nvl(qua.business_group_id, p_business_group_id)
                                   = p_business_group_id
    AND ((trunc(qua.start_date) BETWEEN l_pay_start_dt
                                    AND l_pay_end_dt) OR
         (trunc(qua.end_date) BETWEEN l_pay_start_dt
                                  AND l_pay_end_dt)   OR
         (l_pay_start_dt BETWEEN trunc(qua.start_date)
                             AND trunc(qua.end_date)) OR
         (l_pay_end_dt BETWEEN trunc(qua.start_date)
                           AND trunc(qua.end_date))   OR
         (qua.end_date IS NULL AND nvl(trunc(qua.start_date), l_pay_start_dt)
                                   <= l_pay_end_dt)
        );

BEGIN

  hr_utility.set_location ('Entering: '||l_proc, 10);
  --
  OPEN csr_get_person_id;
  FETCH csr_get_person_id INTO l_person_id;

  IF csr_get_person_id%NOTFOUND THEN

     --
     -- Assignment Not found
     --

     l_ret_vlu := -1;
     p_error_message := 'There is no assignment information for this person.';
     RETURN l_ret_vlu;

  END IF; -- End if of person id check...
  CLOSE csr_get_person_id;

  hr_utility.set_location (l_proc, 20);
  --

  OPEN csr_get_pb_name;
  FETCH csr_get_pb_name INTO l_pb_name;

  IF csr_get_pb_name%NOTFOUND THEN

    --
    -- Organization not found
    --

    l_ret_vlu := -1;
    p_error_message := 'There is no professional body information for this organization.';

  ELSE

    hr_utility.set_location (l_proc, 30);
    --
    OPEN csr_get_pb_mem_info (l_pb_name);
    FETCH csr_get_pb_mem_info INTO p_professional_body_nm
                                  ,p_membership_category;
    IF csr_get_pb_mem_info%NOTFOUND THEN

       --
       -- Professional Membership Details Missing
       --

       l_ret_vlu := -2;
       p_error_message := 'There are no professional body details for this person. ' ||
                          'Check that this is the correct professional body and ' ||
                          'that membership is up-to-date.';

    ELSE

      --
      -- Check any other row exists for this professional body name
      --

      hr_utility.set_location (l_proc, 40);
      --
      FETCH csr_get_pb_mem_info INTO p_professional_body_nm
                                    ,p_membership_category;
      IF csr_get_pb_mem_info%FOUND THEN

         --
         -- Multiple professional body row exists for the same person within the same
         -- payroll period
         --

         l_ret_vlu := -1;
         p_error_message := 'A person can only belong to a particular professional body ' ||
                            'once within any given pay period.';

      END IF; -- End if of pb mem multiple row check...

    END IF; -- End if of pb info check...
    CLOSE csr_get_pb_mem_info;

  END IF; -- End if of organization check...
  CLOSE csr_get_pb_name;

  --
  hr_utility.set_location ('Leaving: '||l_proc, 50);

  RETURN l_ret_vlu;


-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 65);
       p_professional_body_nm := NULL;
       p_membership_category  := NULL;
       p_error_message        := SQLERRM;
       raise;


END get_pb_mem_info;

-----------------------------------------------------------------------------
-- GET_PB_UDT_INFO
-----------------------------------------------------------------------------
FUNCTION  get_pb_udt_info (p_business_group_id   IN     NUMBER -- Context
                          ,p_organization_id     IN     NUMBER
                          ,p_membership_category IN     VARCHAR2
                          ,p_user_table_name        OUT NOCOPY VARCHAR2
                          ,p_user_row_value         OUT NOCOPY VARCHAR2
                          ,p_error_message          OUT NOCOPY VARCHAR2
                          )
RETURN NUMBER
IS

  l_proc    VARCHAR2(80) := g_package || ' get_pb_udt_info';
  l_ret_vlu NUMBER(2)    := 0;

  CURSOR csr_get_udt_id
  IS
  SELECT TO_NUMBER(hoi.org_information1)
  FROM hr_all_organization_units hou
      ,hr_organization_information hoi
  WHERE hou.organization_id         = hoi.organization_id
    AND hou.organization_id         = TO_NUMBER(p_organization_id)
    AND nvl(hou.business_group_id, p_business_group_id)
                                    = p_business_group_id
    AND hoi.org_information_context = 'PROFESSIONAL_BODY_INFORMATION';

  l_user_table_id  NUMBER(15) := 0;

  CURSOR csr_get_udt_row (c_user_table_id IN NUMBER)
  IS
  SELECT pur.row_low_range_or_name
        ,put.user_table_name
  FROM pay_user_rows_f pur
      ,pay_user_tables put
      ,fnd_sessions    fnd
  WHERE put.user_table_id     = c_user_table_id
   AND  put.user_table_id     = pur.user_table_id
   AND  put.range_or_match    = 'M'
   AND (put.business_group_id = p_business_group_id
         OR put.legislation_code IS NOT NULL)
   AND  fnd.effective_date BETWEEN pur.effective_start_date
                               AND pur.effective_end_date
   AND  fnd.session_id        = USERENV('sessionid');

  CURSOR csr_check_udt_col (c_user_table_id IN NUMBER)
  IS
  SELECT NULL
  FROM pay_user_columns            puc
      ,pay_user_tables             put
      ,pay_user_column_instances_f puci
      ,fnd_sessions                fnd
  WHERE puc.user_table_id       = put.user_table_id
    AND put.user_table_id       = c_user_table_id
    AND puc.user_column_id      = puci.user_column_id
    AND puc.user_column_name    = p_membership_category
    AND (put.business_group_id  = p_business_group_id
          OR put.legislation_code  IS NOT NULL)
    AND (puci.business_group_id = p_business_group_id
          OR puci.legislation_code IS NOT NULL)
    AND puci.value IS NOT NULL
    AND fnd.effective_date BETWEEN puci.effective_start_date
                               AND puci.effective_end_date
    AND fnd.session_id          = USERENV('sessionid');

    l_dummy  VARCHAR2(1);

BEGIN

  hr_utility.set_location ('Entering: '||l_proc, 10);
  --
  OPEN csr_get_udt_id;
  FETCH csr_get_udt_id INTO l_user_table_id;

  IF csr_get_udt_id%NOTFOUND THEN

     --
     -- User table Info missing
     --

     l_ret_vlu := -1;
     p_error_message := 'There are no subscription rate details for this professional body.';


  ELSE

    hr_utility.set_location(l_proc, 20);
    --

    OPEN csr_get_udt_row (l_user_table_id);
    FETCH csr_get_udt_row INTO p_user_row_value
                              ,p_user_table_name;

    IF csr_get_udt_row%NOTFOUND THEN

       --
       -- User Table Row Name not found
       --

       l_ret_vlu := -1;
       p_error_message := 'There are no subscription rate details. Check that the details ' ||
                          'exist in the professional membership subscription rates table.';

    ELSE

      hr_utility.set_location(l_proc, 30);
      --

      FETCH csr_get_udt_row INTO p_user_row_value
                                ,p_user_table_name;

      IF csr_get_udt_row%FOUND THEN

         l_ret_vlu := -1;
         p_error_message := 'The correct subscription rate could not be identified. Check ' ||
                            'that the professional membership subscription rates table does ' ||
                            'not contain multiple rows.';

      ELSE

        hr_utility.set_location(l_proc, 40);
        --

        OPEN csr_check_udt_col (l_user_table_id);
        FETCH csr_check_udt_col INTO l_dummy;

        IF csr_check_udt_col%NOTFOUND THEN

           --
           -- Column name mismatch or columns not found
           --

           l_ret_vlu := -1;
           p_error_message := 'This membership category cannot be identified. Check ' ||
                              'that the membership category is included in the ' ||
                              'subscription rates table and has a value.';

        END IF; -- End if of udt col check...
        CLOSE csr_check_udt_col;

      END IF; -- End if of udt mult row check...

    END IF; -- End if of udt row check...
    CLOSE csr_get_udt_row;

  END IF; -- End if of udt info check...
  CLOSE csr_get_udt_id;

  --
  hr_utility.set_location ('Leaving: '||l_proc, 50);

  RETURN l_ret_vlu;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 65);
       p_user_table_name := NULL;
       p_user_row_value  := NULL;
       p_error_message   := SQLERRM;
       raise;


END get_pb_udt_info;

-----------------------------------------------------------------------------

END pqp_professional_body_function;

/
