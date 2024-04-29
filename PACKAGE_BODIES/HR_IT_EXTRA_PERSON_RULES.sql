--------------------------------------------------------
--  DDL for Package Body HR_IT_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IT_EXTRA_PERSON_RULES" AS
  /* $Header: peitexpr.pkb 120.0 2005/05/31 10:27:32 appldev noship $ */
  --
  --
  -- Service functions to return TRUE if the value passed has been changed.
  --
  FUNCTION val_changed(p_value IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_number);
  END val_changed;
  --
  FUNCTION val_changed(p_value IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_varchar2);
  END val_changed;
  --
  FUNCTION val_changed(p_value IN DATE) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_date);
  END val_changed;
  --
  --
  -- Uses Tobacco:
  --
  -- This cannot be entered.
  --
  -- Employee Reference No (per_information2):
  --
  -- Must be unique.
  --
  -- Note: ONLY supports real values.
  --
  procedure extra_create_person_checks
  (p_per_information2  IN VARCHAR2
  ,p_uses_tobacco_flag IN VARCHAR2
  ,p_business_group_id IN NUMBER) IS
    --
    --
    -- Local variables.
    --
    l_v number(2) :=0;

    l_per_information2 VARCHAR2(50);
  BEGIN
    --
    --
    -- Uses tobacco cannot be entered.
    --
    If p_uses_tobacco_flag IS NOT NULL THEN
      hr_utility.set_message(800, 'HR_IT_INVALID_USES_TOBACCO');
      hr_utility.raise_error;
    END IF;
    --
    --
    -- Employee Reference No must be unique.
    --
    IF p_per_information2 IS NOT NULL THEN
      BEGIN
      select 1
      into l_v
      from dual where  EXISTS
      (SELECT NULL
     FROM   per_all_people_f
     WHERE  per_information2 = p_per_information2
     AND business_group_id=p_business_group_id);
    if l_v = 1 then
    hr_utility.set_message(800, 'HR_IT_INVALID_EMP_REF_NO');
    hr_utility.raise_error;
    end if;

      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;
  END extra_create_person_checks;


  --
  -- Uses Tobacco:
  --
  -- This cannot be entered.
  --
  -- Employee Reference No (per_information2):
  --
  -- Must be unique.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_update_person_checks
  (p_person_id         IN NUMBER
  ,p_per_information2  IN VARCHAR2
  ,p_uses_tobacco_flag IN VARCHAR2) IS
    --
    --
    -- Local variables.
    --
    l_v number(2) := 0;
    l_per_information2 VARCHAR2(50);
    l_business_group_id per_all_people_f.business_group_id%TYPE;
  BEGIN
    --
    --
    -- Uses tobacco cannot be entered.
    --
    If val_changed(p_uses_tobacco_flag) AND p_uses_tobacco_flag IS NOT NULL THEN
      hr_utility.set_message(800, 'HR_IT_INVALID_USES_TOBACCO');
      hr_utility.raise_error;
    END IF;
    --
    --

   select distinct business_group_id into l_business_group_id
      from per_all_people_f
      where person_id=p_person_id;

    -- Employee Reference No must be unique.
    --
    IF val_changed(p_per_information2) AND p_per_information2 IS NOT NULL THEN
      BEGIN
        select 1
       into l_v
       from dual where  EXISTS
      (SELECT NULL
      FROM   per_all_people_f
      WHERE  per_information2 = p_per_information2
          AND  person_id        <> p_person_id
          AND  business_group_id=l_business_group_id);
        if l_v = 1 then
        hr_utility.set_message(800, 'HR_IT_INVALID_EMP_REF_NO');
        hr_utility.raise_error;
       end if;

      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;
  END extra_update_person_checks;
  --
  --
  -- Service procedure to check that the collective agreement grade being entered is
  -- within the structure of IT_CAGR.
  --
  -- If it is valid then the dynamic inserts flag is returned for future reference.
  --
  PROCEDURE cagr_structure_valid
  (p_cagr_id_flex_num        IN  NUMBER
  ,p_collective_agreement_id IN  NUMBER
  ,p_organization_id         IN  NUMBER
  ,o_dynamic_inserts         OUT NOCOPY VARCHAR2) IS
    --
    --
    -- Local cursors.
    --
    CURSOR csr_it_cagr
    (p_cagr_id_flex_num        NUMBER
    ,p_collective_agreement_id NUMBER
    ,p_organization_id         NUMBER) IS
      SELECT pcagv.dynamic_insert_allowed
      FROM   per_coll_agree_grades_v pcagv
            ,hr_organization_units   org
      WHERE  org.organization_id           = p_organization_id
        AND  pcagv.business_group_id       = org.business_group_id
	AND  pcagv.collective_agreement_id = p_collective_agreement_id
        AND  pcagv.id_flex_num             = p_cagr_id_flex_num
        AND  pcagv.d_grade_type_name       = 'IT_CAGR';
    --
    --
    -- Local variables.
    --
    l_dynamic_insert VARCHAR2(1) := 'N';
  BEGIN
    --
    --
    -- Get the name of the collective agreement grade structure that is being used.
    --
    OPEN  csr_it_cagr(p_cagr_id_flex_num, p_collective_agreement_id, p_organization_id);
    FETCH csr_it_cagr INTO l_dynamic_insert;
    IF csr_it_cagr%NOTFOUND THEN
      CLOSE csr_it_cagr;
      hr_utility.set_message(800, 'HR_IT_INVALID_GRADE_TYPE_NAME');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_it_cagr;
    --
    --
    -- Return dynamic insert flag.
    --
    o_dynamic_inserts := l_dynamic_insert;
  END cagr_structure_valid;
  --
  --
  -- Service procedure to check that the collective agreement grade being entered is
  -- defined correctly i.e. built from first segment down with no intermediate null
  -- values.
  --
  PROCEDURE cagr_format_valid
  (p_cag_segment1 IN VARCHAR2
  ,p_cag_segment2 IN VARCHAR2
  ,p_cag_segment3 IN VARCHAR2) IS
  BEGIN
    --
    --
    -- Level or Description has been entered without a grade.
    --
    If p_cag_segment1 IS NULL AND (p_cag_segment2 IS NOT NULL OR p_cag_segment3 IS NOT NULL) THEN
      hr_utility.set_message(800, 'HR_IT_IVALID_GRADE_LEVEL_DESC');
      hr_utility.raise_error;
    --
    --
    -- Description has been entered without a Level.
    --
    ELSIF p_cag_segment2 IS NULL AND p_cag_segment3 IS NOT NULL THEN
      hr_utility.set_message(800, 'HR_IT_IVALID_LEVEL_DESC');
      hr_utility.raise_error;
    END IF;
  END cagr_format_valid;
  --
  --
  -- Collective Agreement Grades:
  --
  -- If the user is using a collective agreement grade then it must be within the
  -- predefined structure of IT_CAGR: Grade - Level - Description. This requires that
  -- the structure is associated with the collective agreement and the collective
  -- agreement is defined within the business group to which the assignment belongs.
  --
  -- The grade structure must be built from the first segment down i.e. cannot have a null
  -- value followed by an actual value e.g. cannot have a value for level if there is no
  -- grade.
  --
  -- If dynamic inserts is not enabled for the IT_CAGR structure then the combination
  -- must already exist.
  --
  -- Unemployment Insurance Code (p_segment2):
  --
  -- This is mandatory.
  --
  -- Note: ONLY supports real values.
  --
  PROCEDURE extra_create_assignment_checks
  (p_collective_agreement_id IN NUMBER
  ,p_cagr_id_flex_num        IN NUMBER
  ,p_organization_id	     IN NUMBER
  ,p_cag_segment1            IN VARCHAR2
  ,p_cag_segment2            IN VARCHAR2
  ,p_cag_segment3            IN VARCHAR2
  ,p_scl_segment2            IN VARCHAR2) IS
    --
    --
    -- Local variables.
    --
    l_dynamic_inserts VARCHAR2(1) := 'N';
  BEGIN
    --
    --
    -- A collective agreement grade has been entered.
    --
    If p_collective_agreement_id IS NOT NULL AND p_cagr_id_flex_num IS NOT NULL THEN
      --
      --
      -- Check that collective agreement grade structure is IT_CAGR.
      --
      cagr_structure_valid(p_cagr_id_flex_num, p_collective_agreement_id, p_organization_id, l_dynamic_inserts);
      --
      --
      -- Check that collective agreement grade is formatted correctly i.e. built from top
      -- down with no intermediate null values.
      --
      cagr_format_valid(p_cag_segment1, p_cag_segment2, p_cag_segment3);
      --
      --
      -- If dynamic inserts are not supported then the collective agreeement grade must already
      -- exist NB. this is supported by the API via hr_cgd_ins.ins_or_sel().
      --
      NULL;
    END IF;
    --
    --
    -- Unemployment insurance code must be entered.
    --
    /*IF p_scl_segment2 IS NULL THEN
      hr_utility.set_message(800, 'HR_IT_NULL_INS_CODE');
      hr_utility.raise_error;
    END IF;*/
  END extra_create_assignment_checks;
  --
  --
  -- Collective Agreement Grades:
  --
  -- If the user is using a collective agreement grade then it must be within the
  -- predefined structure of IT_CAGR: Grade - Level - Description. This requires that
  -- the structure is associated with the collective agreement and the collective
  -- agreement is defined within the business group to which the assignment belongs.
  --
  -- The grade structure must be built from the first segment down i.e. cannot have a null
  -- value followed by an actual value e.g. cannot have a value for level if there is no
  -- grade.
  --
  -- If dynamic inserts is not enabled for the IT_CAGR structure then the combination
  -- must already exist.
  --
  -- Unemployment Insurance Code (p_segment2):
  --
  -- This is mandatory.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_update_assignment_checks
  (p_collective_agreement_id IN NUMBER
  ,p_cagr_id_flex_num        IN NUMBER
  ,p_assignment_id	     IN NUMBER
  ,p_object_version_number   IN NUMBER
  ,p_effective_date          IN DATE
  ,p_cag_segment1            IN VARCHAR2
  ,p_cag_segment2            IN VARCHAR2
  ,p_cag_segment3            IN VARCHAR2
  ,p_segment2                IN VARCHAR2) IS
    --
    --
    -- Local cursors.
    --
    CURSOR csr_cagr_details
    (p_effective_date        DATE
    ,p_assignment_id         NUMBER
    ,p_object_version_number NUMBER) IS
      SELECT asg.collective_agreement_id
            ,asg.cagr_id_flex_num
            ,asg.organization_id
            ,cagr.segment1 cag_segment1
            ,cagr.segment2 cag_segment2
            ,cagr.segment3 cag_segment3
      FROM   per_all_assignments_f asg
            ,per_cagr_grades_def   cagr
      WHERE  asg.assignment_id         = p_assignment_id
        AND  asg.object_version_number = p_object_version_number
        AND  p_effective_date BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date
        AND  cagr.cagr_grade_def_id (+) = asg.cagr_grade_def_id;
    --
    --
    -- Local variables.
    --
    l_dynamic_inserts VARCHAR2(1) := 'N';
    l_rec             csr_cagr_details%ROWTYPE;
  BEGIN
    --
    --
    -- Check to see if any value affecting the collective agreement grade has changed.
    --
    IF val_changed(p_collective_agreement_id) OR
       val_changed(p_cagr_id_flex_num)        OR
       val_changed(p_cag_segment1)            OR
       val_changed(p_cag_segment2)            OR
       val_changed(p_cag_segment3)            THEN
      --
      --
      -- Fill in any values which have not been changed this time i.e. the resulting record
      -- represents the new combination of values for all the above values.
      --
      OPEN  csr_cagr_details(p_effective_date, p_assignment_id, p_object_version_number);
      FETCH csr_cagr_details INTO l_rec;
      CLOSE csr_cagr_details;
      --
      IF val_changed(p_collective_agreement_id) THEN
        l_rec.collective_agreement_id := p_collective_agreement_id;
      END IF;
      IF val_changed(p_cagr_id_flex_num) THEN
        l_rec.cagr_id_flex_num := p_cagr_id_flex_num;
      END IF;
      IF val_changed(p_cag_segment1) THEN
        l_rec.cag_segment1 := p_cag_segment1;
      END IF;
      IF val_changed(p_cag_segment2) THEN
        l_rec.cag_segment2 := p_cag_segment2;
      END IF;
      IF val_changed(p_cag_segment3) THEN
        l_rec.cag_segment3 := p_cag_segment3;
      END IF;
      --
      --
      -- A collective agreement grade has been entered.
      --
      If l_rec.collective_agreement_id IS NOT NULL AND l_rec.cagr_id_flex_num IS NOT NULL THEN
        --
        --
        -- Check that collective agreement grade structure is IT_CAGR.
        --
        cagr_structure_valid(l_rec.cagr_id_flex_num, l_rec.collective_agreement_id, l_rec.organization_id, l_dynamic_inserts);
        --
        --
        -- Check that collective agreement grade is formatted correctly i.e. built from top
        -- down with no intermediate null values.
        --
        cagr_format_valid(l_rec.cag_segment1, l_rec.cag_segment2, l_rec.cag_segment3);
        --
        --
        -- If dynamic inserts are not supported then the collective agreeement grade must already
        -- exist NB. this is supported by the API via hr_cgd_ins.ins_or_sel().
        --
        NULL;
      END IF;
    END IF;
    --
    --
    -- Unemployment insurance code must be entered.
    --
    /*IF val_changed(p_segment2) AND p_segment2 IS NULL THEN
      hr_utility.set_message(800, 'HR_IT_NULL_INS_CODE');
      hr_utility.raise_error;
    END IF;*/
  END extra_update_assignment_checks;
END hr_it_extra_person_rules;

/
