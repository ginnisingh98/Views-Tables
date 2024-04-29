--------------------------------------------------------
--  DDL for Package Body GHR_BREAKDOWN_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_BREAKDOWN_RPT" AS
/* $Header: ghbrkdwn.pkb 120.1 2005/07/01 02:12:45 asubrahm noship $ */
--
  l_agcy_and_selm    VARCHAR2(4)  := '%';
  l_by_clause        VARCHAR2(80) := 'GRADE/LEVEL';
  l_within_clause    VARCHAR2(80) := 'PAY_PLAN';
  l_for_clause       NUMBER(3)    := 0;
  l_extra_clause     VARCHAR2(80);
  l_org_strver_id    per_org_structure_versions.org_structure_version_id%TYPE;

  PROCEDURE Set_Effective_Date(p_date IN DATE)
  IS
  BEGIN
    l_effective_date    := p_date;
  END;

  FUNCTION Effective_Date RETURN DATE
  IS
  BEGIN
    RETURN l_effective_date;
  END;

  PROCEDURE Set_Agency(p_agency IN VARCHAR2,
                       p_subelm IN VARCHAR2)
  IS
  BEGIN
    l_agcy_and_selm := p_agency || NVL(p_subelm, '%');
  END;

  FUNCTION Agency_Subelement RETURN VARCHAR2
  IS
  BEGIN
    RETURN l_agcy_and_selm;
  END;

  PROCEDURE Set_By_Clause(p_name     IN VARCHAR2)
  IS
  BEGIN
    l_by_clause    := UPPER(p_name);
  END;

  PROCEDURE Set_within_clause(p_name IN VARCHAR2)
  IS
  BEGIN
    l_within_clause := UPPER(p_name);
  END;

  PROCEDURE set_for_clause(p_value IN NUMBER)
  IS
  BEGIN
    l_for_clause    := p_value;
  END;

  FUNCTION get_for_clause RETURN NUMBER
  IS
  BEGIN
    RETURN l_for_clause;
  END;

  PROCEDURE set_extra_clause(p_name IN VARCHAR2)
  IS
  BEGIN
    l_extra_clause  := UPPER(p_name);
  END;

  PROCEDURE set_hierarchy(p_org_strver_id IN NUMBER)
  IS
  BEGIN
    l_org_strver_id    := p_org_strver_id;
  END;

  FUNCTION get_hierarchy_level(p_position_id IN NUMBER, p_effective_date IN DATE)
  RETURN NUMBER
  IS
    l_level  NUMBER(3);
    l_orgid  hr_all_positions_f.organization_id%TYPE;
    CURSOR c_level IS
     SELECT DECODE(ORG.organization_id_child, l_orgid, LEVEL+1, LEVEL) ORG_LEVEL
       FROM per_org_structure_elements ORG
      WHERE (ORG.organization_id_child  = l_orgid OR
             ORG.organization_id_parent = l_orgid)
        AND ORG.org_structure_version_id = l_org_strver_id
    CONNECT
         BY
      PRIOR organization_id_child = organization_id_parent
      AND PRIOR org_structure_version_id = org_structure_version_id
      START
       WITH organization_id_parent
              NOT IN (SELECT organization_id_child
                        FROM per_org_structure_elements);
  BEGIN
    l_level := 0;
    IF l_for_clause > 0 THEN
      SELECT organization_id
        INTO l_orgid
        FROM hr_all_positions_f
       WHERE position_id = p_position_id
         AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
      OPEN c_level;
      FETCH c_level INTO l_level;
      IF c_level%NOTFOUND THEN
        l_level := -1;
      END IF;
      CLOSE c_level;
    END IF;
    RETURN (l_level);
  END;

  FUNCTION get_hierarchy_codes (p_ASG_rowid IN ROWID, p_effective_date IN DATE,
                                p_mode IN VARCHAR2 := 'PARENTS')
  RETURN VARCHAR2
  IS
    l_prvorg VARCHAR2(15);
    l_result VARCHAR2(80);
    l_count  INTEGER;
    CURSOR c_codes IS
      SELECT LEVEL org_level,
             organization_id_parent,
             organization_id_child,
             org_structure_version_id
        FROM per_org_structure_elements
       WHERE org_structure_version_id = l_org_strver_id
     CONNECT
          BY
       PRIOR organization_id_parent = organization_id_child
       START
        WITH organization_id_child = (SELECT POS.organization_id
                                        FROM hr_all_positions_f POS,
                                             per_assignments_f ASG
                                       WHERE ASG.rowid       = p_ASG_rowid
                                         AND ASG.position_id = POS.position_id
                                         AND p_effective_date BETWEEN POS.effective_start_date
                                                                  AND POS.effective_end_date)
       ORDER BY LEVEL DESC;
  BEGIN
    l_result := NULL;
    l_count  := 1;
    FOR r_codes IN c_codes LOOP
      IF p_mode = 'ALL' OR
         (l_count < l_for_clause AND p_mode = 'PARENTS')
      THEN
        IF l_result IS NULL THEN
          l_result := TO_CHAR(r_codes.organization_id_parent);
          l_prvorg := TO_CHAR(r_codes.organization_id_child);
        ELSE
          l_result := l_result || '-' || TO_CHAR(r_codes.organization_id_parent);
          l_prvorg := TO_CHAR(r_codes.organization_id_child);
        END IF;
        l_count := l_count + 1;
      ELSE
        IF l_for_clause = 1 THEN
          l_result := r_codes.organization_id_parent;
        END IF;
        EXIT;
      END IF;
    END LOOP;
    IF l_result IS NOT NULL AND l_prvorg IS NOT NULL THEN
      l_result := l_result || '-' || l_prvorg;
    ELSIF l_result IS NULL AND p_mode = 'PARENTS' THEN
      SELECT POS.organization_id
        INTO l_result
        FROM hr_all_positions_f POS,
             per_assignments_f ASG
       WHERE ASG.rowid       = p_ASG_rowid
         AND ASG.position_id = POS.position_id
         AND p_effective_date BETWEEN POS.effective_start_date
                                  AND POS.effective_end_date;
    END IF;
    RETURN l_result;
  END;

  FUNCTION decode_lookup(p_lookup_type  IN VARCHAR2,
                         p_lookup_code  IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_result     VARCHAR2(80);
    CURSOR csr_lookup IS
        SELECT meaning
          FROM hr_lookups
         WHERE lookup_type     = p_lookup_type
           AND lookup_code     = p_lookup_code
           AND enabled_flag = 'Y'
           AND TRUNC(l_effective_date)
                 BETWEEN NVL(start_date_active, TRUNC(l_effective_date))
                     AND NVL(end_date_active,   TRUNC(l_effective_date));
  BEGIN
    open csr_lookup;
    fetch csr_lookup into l_result;
    close csr_lookup;
    RETURN l_result;
  END;



-- --------------------------------------------------------------------------
-- |--------------------------< return_special_information >----------------|
-- --------------------------------------------------------------------------

  Procedure return_special_information
  (p_person_id       in  number
  ,p_structure_name  in  varchar2
  ,p_effective_date  in  date
  ,p_special_info    OUT NOCOPY ghr_api.special_information_type
  )
  is
  l_proc           varchar2(72)  := 'return_special_information ';
  l_id_flex_num    fnd_id_flex_structures.id_flex_num%type;
  l_max_segment    per_analysis_criteria.segment1%type;

  Cursor c_flex_num is
    select    flx.id_flex_num
    from      fnd_id_flex_structures_tl flx
    where     flx.id_flex_code           = 'PEA'  --
    and       flx.application_id         =  800   --
    and       flx.id_flex_structure_name =  p_structure_name
    and       flx.language               = 'US';

   Cursor    c_sit      is
     select  pea.analysis_criteria_id,
             pan.date_from, -- added for bug fix : 609285
             pea.start_date_active,
             pea.segment1,
             pea.segment2,
             pea.segment3,
             pea.segment4,
             pea.segment5,
             pea.segment6,
             pea.segment7,
             pea.segment8,
             pea.segment9,
             pea.segment10,
             pea.segment11,
             pea.segment12,
             pea.segment13,
             pea.segment14,
             pea.segment15,
             pea.segment16,
             pea.segment17,
             pea.segment18,
             pea.segment19,
             pea.segment20
     from    per_analysis_Criteria pea,
             per_person_analyses   pan
     where   pan.person_id            =  p_person_id
     and     pan.id_flex_num          =  l_id_flex_num
     and     pea.analysis_Criteria_id =  pan.analysis_criteria_id
     and     p_effective_date
     between nvl(pan.date_from,p_effective_date)
     and     nvl(pan.date_to,p_effective_date)
     and     p_effective_date
     between nvl(pea.start_date_active,p_effective_date)
     and     nvl(pea.end_date_active,p_effective_date)
     order   by  2 desc ;


  begin

    for flex_num in c_flex_num loop
      l_id_flex_num  :=  flex_num.id_flex_num;
    End loop;

    for special_info in c_sit loop
      p_special_info.segment1   := special_info.segment1;
      p_special_info.segment2   := special_info.segment2;
      p_special_info.segment3   := special_info.segment3;
      p_special_info.segment4   := special_info.segment4;
      p_special_info.segment5   := special_info.segment5;
      p_special_info.segment6   := special_info.segment6;
      p_special_info.segment7   := special_info.segment7;
      p_special_info.segment8   := special_info.segment8;
      p_special_info.segment9   := special_info.segment9;
      p_special_info.segment10  := special_info.segment10;
      p_special_info.segment11  := special_info.segment11;
      p_special_info.segment12  := special_info.segment12;
      p_special_info.segment13  := special_info.segment13;
      p_special_info.segment14  := special_info.segment14;
      p_special_info.segment15  := special_info.segment15;
      p_special_info.segment16  := special_info.segment16;
      p_special_info.segment17  := special_info.segment17;
      p_special_info.segment18  := special_info.segment18;
      p_special_info.segment19  := special_info.segment19;
      p_special_info.segment20  := special_info.segment20;
      exit;
    End loop;
  EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
    p_special_info  := null;
    raise;
   End return_special_information;

  FUNCTION Any_Clause(p_clause      IN VARCHAR2,
                      p_PER_rowid    IN ROWID,
                      p_PEI_GRP1     IN per_people_extra_info%ROWTYPE,
                      p_ASG          IN per_all_assignments_f%ROWTYPE)
  RETURN VARCHAR2
  IS
    l_result    VARCHAR2(300);
    l_rescpy    VARCHAR2(300);
    l_int       INTEGER;
    -- record structure for special Info 'US Fed Perf Appraisal'
    l_special_info   ghr_api.special_information_type;
    l_posei_data     per_position_extra_info%ROWTYPE;
  BEGIN
    IF    p_clause = 'GRADE/LEVEL'         -- Grade or Level
    THEN
      SELECT GDF.segment2
        INTO l_result
        FROM per_grades GRD
            ,per_grade_definitions GDF
       WHERE GRD.grade_id = p_ASG.grade_id
         AND GDF.grade_definition_id = GRD.grade_definition_id;
    ELSIF p_clause = 'OCCODE_PATCOB'   -- Occupational Category (PATCOB) Code
    THEN
      ghr_history_fetch.fetch_positionei(p_ASG.position_id, 'GHR_US_POS_GRP1',
                                         l_effective_date, l_posei_data);
      l_result := l_posei_data.poei_information6 || ' - ' ||
                  decode_lookup('GHR_US_OCC_CATEGORY_CODE', l_posei_data.poei_information6);
    ELSIF p_clause = 'SERIES'            -- Occupational Series
    THEN
      SELECT job.name || ' - ' || decode_lookup('GHR_US_OCC_SERIES', job.name)
        INTO l_result
        FROM hr_all_positions_f POS,
             per_jobs job
       WHERE POS.position_id = p_ASG.position_id
         AND TRUNC(effective_date) BETWEEN POS.effective_start_date
                                       AND POS.effective_end_date
         AND JOB.job_id      = POS.job_id;
    ELSIF p_clause = 'GRADE'            -- Grade
    THEN
      SELECT GRD.name
        INTO l_result
        FROM per_grades GRD
       WHERE GRD.grade_id = p_ASG.grade_id;
    ELSIF p_clause = 'APPOINTMENT_TYPE' -- Appointment Type
    THEN
       l_result := p_PEI_GRP1.pei_information3 || ' - ' ||
                   decode_lookup('GHR_US_APPOINTMENT_TYPE', p_PEI_GRP1.pei_information3);
    ELSIF p_clause = 'HANDICAP_GROUP'  -- Handicap Group
    THEN
      l_result := p_PEI_GRP1.pei_information11;
      l_rescpy := l_result;
      IF    l_result = '13'
      THEN
        l_result := 'Speech Impairments';
      ELSIF l_result in ('15', '16', '17')
      THEN
        l_result := 'Hearing Impairments';
      ELSIF l_result in ('22', '23', '24', '25')
      THEN
        l_result := 'Vision Impairments';
      ELSIF l_result in ('27', '28', '29', '32', '33', '34',
                         '35', '36', '37', '38')
      THEN
        l_result := 'Absences of Extremities';
      ELSIF l_result in ('44', '45', '46', '47', '48', '49', '57', '61',
                         '62', '63', '64', '65', '66', '67', '68')
      THEN
        l_result := 'Nonparalytic Orthopedic Impairments, chronic pain, stiffnes or weakness';
      ELSIF l_result IN ('70', '71', '72', '73', '74', '75', '76', '77', '78')
      THEN
        l_result := 'Complete Paralysis';
      ELSIF l_result IN ('80', '81', '82', '83', '84', '86', '87', '88', '89',
                         '90', '91', '92', '93', '94')
      THEN
        l_result := 'Other Impairments';
      ELSE
        l_result := 'No Handicap';
      END IF;
      SELECT NVL(LKP.description, l_result)
        INTO l_result
        FROM hr_lookups LKP
       WHERE LKP.lookup_type = 'GHR_US_HANDICAP_CODE'
         AND LKP.lookup_code = l_rescpy
         AND LKP.enabled_flag = 'Y'
         AND TRUNC(l_effective_date)
               BETWEEN NVL(LKP.start_date_active, TRUNC(l_effective_date))
                   AND NVL(LKP.end_date_active,   TRUNC(l_effective_date));
    ELSIF p_clause = 'TARGET_HANDICAP_CODE'  -- Target Handicap Code
    THEN
      l_result := p_PEI_GRP1.pei_information11 || ' - ' ||
                  decode_lookup('GHR_US_HANDICAP_CODE', p_PEI_GRP1.pei_information11);
    ELSIF p_clause = 'AA_CATEGORY'         -- AA Category
    THEN
      BEGIN
        ghr_history_fetch.fetch_positionei(p_ASG.position_id, 'GHR_US_POS_GRP1',
                                           l_effective_date, l_posei_data);
        SELECT NVL(LKP.description, LKP.meaning)
          INTO l_result
          FROM hr_lookups LKP
         WHERE LKP.lookup_type     = 'GHR_US_OCC_CATEGORY_CODE'
           AND LKP.lookup_code     = l_posei_data.poei_information6
           AND LKP.enabled_flag = 'Y'
           AND TRUNC(l_effective_date)
                 BETWEEN NVL(LKP.start_date_active, TRUNC(l_effective_date))
                     AND NVL(LKP.end_date_active,   TRUNC(l_effective_date));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_result := NULL;
      END;
      l_int    := TRUNC((TO_NUMBER(Any_Clause('GRADE/LEVEL', p_PER_rowid, p_PEI_GRP1, p_ASG))-1)/4, 0);
      l_result := l_result ||
                  ' ' ||
                  Any_Clause('PAY_PLAN', p_PER_rowid, p_PEI_GRP1, p_ASG) ||
                  ' ' ||
                  'GRDS ' || RTRIM(TO_CHAR((l_int*4)+1, '09')) || ' - ' || RTRIM(TO_CHAR((l_int+1)*4, '09'));
    ELSIF p_clause = 'PERFORMANCE_RATING'  -- Performance Rating level
    THEN
      SELECT person_id
        INTO l_result
        FROM per_people_f
       WHERE rowid = p_PER_rowid;
      return_special_information(p_person_id => l_result,
                                 p_structure_name => 'US Fed Perf Appraisal',
                                 p_effective_date => l_effective_date,
                                 p_special_info => l_special_info);
      IF l_special_info.segment5 IS NOT NULL
      THEN
        l_result := l_special_info.segment5 || ' - ' ||
                    decode_lookup('GHR_US_RATING_LEVEL', l_special_info.segment5);
      ELSE
        l_result := '* - No Performance Rating Available';
      END IF;
    ELSIF p_clause = 'PAY_PLAN'       -- Pay Plan
    THEN
      SELECT GDF.segment1
        INTO l_result
        FROM per_grades GRD
            ,per_grade_definitions GDF
       WHERE GRD.grade_id = p_ASG.grade_id
         AND GDF.grade_definition_id = GRD.grade_definition_id;
    ELSIF p_clause = 'FULL_NAME' THEN
      SELECT full_name
        INTO l_result
        FROM per_people_f
       WHERE rowid = p_PER_rowid;
    ELSIF p_clause = 'PERSON_ID' THEN
      SELECT person_id
        INTO l_result
        FROM per_people_f
       WHERE rowid = p_PER_rowid;
    ELSIF p_clause = 'EMPLOYEE_NUMBER' THEN
      SELECT employee_number
        INTO l_result
        FROM per_people_f
       WHERE rowid = p_PER_rowid;
    ELSIF p_clause = 'AGENCY_CODE' THEN
      l_result := ghr_api.get_position_agency_code_pos(p_ASG.position_id,
                                                       p_ASG.business_group_id);
    ELSIF p_clause = 'ORGANIZATION_ID' THEN
      SELECT POS.organization_id
        INTO l_result
        FROM hr_all_positions_f POS
       WHERE POS.position_id = p_ASG.position_id
         AND TRUNC(l_effective_date) BETWEEN POS.effective_start_date
                                         AND POS.effective_end_date;
    END IF;
    RETURN l_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_result := NULL;
      RETURN l_result;
  END;

  PROCEDURE Delete_Temp_Data IS
  BEGIN
    DELETE FROM GHR_BREAKDOWN_RESULTS WHERE session_id = USERENV('SESSIONID');
  END;

  PROCEDURE process(p_breakdown_criteria_id IN NUMBER := NULL) IS
    CURSOR c_emp IS
      SELECT PER.rowid PER_rowid, ASG.rowid ASG_rowid,
             PER.person_id, PER.sex
        FROM per_people_f PER, per_assignments_f ASG
       WHERE l_effective_date BETWEEN PER.effective_start_date
                                  AND PER.effective_end_date
         AND PER.person_id = ASG.person_id
         AND l_effective_date BETWEEN ASG.effective_start_date
                                  AND ASG.effective_end_date
         AND get_hierarchy_level(ASG.position_id, l_effective_date) >= l_for_clause
         AND ghr_api.get_position_agency_code_pos(ASG.position_id, ASG.business_group_id)
             LIKE l_agcy_and_selm
         AND ASG.primary_flag = 'Y'
         AND ASG.assignment_type <> 'B';
    r_GRP1   per_people_extra_info%rowtype;
    r_ASG    per_all_assignments_f%rowtype;
    l_result VARCHAR2(80);

    -- Information to be inserted in GHR_BREAKDOWN_RESULTS
    l_rslt_session_id     ghr_breakdown_results.session_id%TYPE := USERENV('SESSIONID');
    l_rslt_id             ghr_breakdown_results.breakdown_result_id%TYPE;
    l_rslt_for_clause     ghr_breakdown_results.for_clause%TYPE;
    l_rslt_within_clause  ghr_breakdown_results.within_clause%TYPE;
    l_rslt_by_clause      ghr_breakdown_results.by_clause%TYPE;

  BEGIN
    IF p_breakdown_criteria_id IS NOT NULL THEN
      DELETE FROM GHR_BREAKDOWN_RESULTS
      WHERE session_id = l_rslt_session_id
        AND breakdown_criteria_id = p_breakdown_criteria_id;
    ELSE
      DELETE FROM GHR_BREAKDOWN_RESULTS
      WHERE session_id = l_rslt_session_id;
    END IF;
    l_rslt_id := 0;
    FOR r_emp IN c_emp LOOP
      ghr_history_fetch.fetch_peopleei(r_emp.person_id, 'GHR_US_PER_GROUP1',
                                       l_effective_date, r_GRP1);
      ghr_history_fetch.fetch_assignment(p_rowid           => r_emp.ASG_rowid,
                                         p_assignment_data => r_ASG,
                                         p_result_code     => l_result);
      IF r_GRP1.pei_information5 IS NOT NULL THEN
        l_rslt_id := l_rslt_id + 1;
        IF l_for_clause > 0 THEN
          l_rslt_for_clause := get_hierarchy_codes(r_emp.ASG_rowid, l_effective_date, 'PARENTS');
        END IF;
        l_rslt_within_clause  := Any_Clause(l_within_clause, r_emp.PER_rowid, r_GRP1, r_ASG);
        l_rslt_by_clause      := Any_Clause(l_by_clause, r_emp.PER_rowid, r_GRP1, r_ASG);
        INSERT INTO ghr_breakdown_results
          (session_id, breakdown_result_id, breakdown_criteria_id, for_clause, within_clause,
           by_clause, sex, ethnic_origin)
        VALUES
          (l_rslt_session_id, l_rslt_id, p_breakdown_criteria_id, l_rslt_for_clause,
           l_rslt_within_clause, l_rslt_by_clause, r_emp.sex, r_GRP1.pei_information5);
        l_rslt_for_clause     := NULL;
        l_rslt_within_clause  := NULL;
        l_rslt_by_clause      := NULL;
      END IF;
    END LOOP;
  END;

-- Given and org structure version iud return the org structure name (ie hierarchy)
FUNCTION get_org_struct_name(
                   p_org_structure_version_id      per_org_structure_versions.org_structure_version_id%TYPE)
  RETURN VARCHAR2 IS

CURSOR cur_hier IS
  SELECT s.name
  FROM   per_organization_structures s
        ,per_org_structure_versions  v
  WHERE  v.org_structure_version_id = p_org_structure_version_id
  AND    v.organization_structure_id = s.organization_structure_id;

BEGIN
  FOR cur_hier_rec IN cur_hier LOOP
    RETURN(cur_hier_rec.name);
  END LOOP;

  RETURN(null);

END get_org_struct_name;

END ghr_breakdown_rpt;

/
