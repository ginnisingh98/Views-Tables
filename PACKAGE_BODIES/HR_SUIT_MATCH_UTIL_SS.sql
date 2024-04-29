--------------------------------------------------------
--  DDL for Package Body HR_SUIT_MATCH_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SUIT_MATCH_UTIL_SS" AS
/* $Header: hrsmgutl.pkb 120.2.12010000.3 2009/01/28 04:51:24 kgowripe ship $ */
--- New global variable added by KRISHNA for perf. fix 7452233
g_prev_person_id NUMBER(15);
g_prev_ess_count NUMBER;
g_prev_des_count NUMBER;
g_ess_total_count NUMBER;
g_des_total_count NUMBER;
-- END Changes by KMG
--
-- declare global cursor for total essential/desired count
CURSOR csr_total_ess_des_count(p_mandatory in varchar2) IS
     SELECT count(competence_id)
     FROM per_suitmatch_comp smtmp
     where smtmp.mandatory = (p_mandatory);

-- declare global cursor for essential/desired match count
CURSOR csr_ess_des_match_count(p_person_id in number, p_mandatory in varchar2)IS
     select /*+ leading(smtmp) index(pce, PER_COMPETENCE_ELEMENTS_FK7) index(r1, PER_RATING_LEVELS_PK) */
          count(pce.competence_id)
     FROM per_competence_elements pce,
          per_suitmatch_comp smtmp,
          per_rating_levels r1
     where pce.competence_id = smtmp.competence_id
     AND nvl(r1.step_value,-1) >= nvl(smtmp.min_step_value, -1)
     AND pce.type = 'PERSONAL'
     AND trunc(sysdate) BETWEEN pce.effective_date_from AND
        NVL(pce.effective_date_to, trunc(sysdate))
     AND pce.proficiency_level_id = r1.rating_level_id(+)
     AND pce.person_id = p_person_id
     AND smtmp.mandatory = p_mandatory;

-- declare global cursor for essential/desired match count for a work opp
-- with competencies for person and work opp coming from base table
CURSOR csr_workopp_ed_match_count(
     p_person_id in number
    ,p_enterprise_id in number
    ,p_organization_id in number
    ,p_job_id in number
    ,p_position_id in number
    ,p_mandatory in varchar2) IS
SELECT count(pcep.competence_id)
FROM   per_competence_elements pce,
       per_competence_elements pcep,
       per_rating_levels r1,
       per_rating_levels r2
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    pce.proficiency_level_id = r1.rating_level_id(+)
AND    (pce.enterprise_id = p_enterprise_id or pce.organization_id = p_organization_id or
        pce.job_id = p_job_id or pce.position_id = p_position_id)
AND    pcep.person_id = p_person_id
AND    pce.competence_id = pcep.competence_id
AND    pcep.type = 'PERSONAL'
AND    trunc(sysdate) BETWEEN pcep.effective_date_from AND
          NVL(pcep.effective_date_to, trunc(sysdate))
AND    pcep.proficiency_level_id = r2.rating_level_id(+)
AND    nvl(r2.step_value, -1) >= nvl(r1.step_value, -1)
AND    pce.mandatory = p_mandatory;


-- declare global cursor for total essential/desired match count for a work opp
-- with competencies work opp coming from base table
CURSOR csr_total_workopp_match_count(
     p_enterprise_id in number
    ,p_organization_id in number
    ,p_job_id in number
    ,p_position_id in number
    ,p_mandatory in varchar2) IS
SELECT count(pce.competence_id)
FROM   per_competence_elements pce
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    (pce.enterprise_id = p_enterprise_id or pce.organization_id = p_organization_id or
        pce.job_id = p_job_id or pce.position_id = p_position_id)
AND    pce.mandatory = p_mandatory;


-- declare global cursor for essential/desired match count for a work opp
-- with competencies for person coming from base table and competencies for
-- work opp coming from temp table
CURSOR csr_wp_tmp_ed_match_count(
     p_person_id in number
    ,p_mandatory in varchar2) IS
SELECT /*+ leading(smtmp) index(pcep, PER_COMPETENCE_ELEMENTS_FK7) index(r2, PER_RATING_LEVELS_PK) */
       count(pcep.competence_id)
FROM   per_suitmatch_comp smtmp,
       per_competence_elements pcep,
       per_rating_levels r2
WHERE  pcep.person_id = p_person_id
AND    smtmp.competence_id = pcep.competence_id
AND    pcep.type = 'PERSONAL'
AND    trunc(sysdate) BETWEEN pcep.effective_date_from AND
          NVL(pcep.effective_date_to, trunc(sysdate))
AND    pcep.proficiency_level_id = r2.rating_level_id(+)
AND    nvl(r2.step_value, -1) >= nvl(smtmp.min_step_value, -1)
AND    smtmp.mandatory = p_mandatory;


-- declare global cursor for essential/desired match count for a work opp
-- with competencies for person coming from temp table and competencies for
-- work opp coming from base table
CURSOR csr_wp_per_tmp_ed_match_count(
     p_enterprise_id in number
    ,p_organization_id in number
    ,p_job_id in number
    ,p_position_id in number
    ,p_mandatory in varchar2) IS
SELECT /*+ leading(ptmp) index(pce, PER_COMPETENCE_ELEMENTS_N1) index(r1, PER_RATING_LEVELS_PK) */
       count(ptmp.competence_id)
FROM   per_competence_elements pce,
       per_suitmatch_person ptmp,
       per_rating_levels r1
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    pce.proficiency_level_id = r1.rating_level_id(+)
AND    (pce.enterprise_id = p_enterprise_id or pce.organization_id = p_organization_id or
        pce.job_id = p_job_id or pce.position_id = p_position_id)
AND    pce.competence_id = ptmp.competence_id
AND    nvl(ptmp.min_step_value, -1) >= nvl(r1.step_value, -1)
AND    pce.mandatory = p_mandatory;


-- declare global cursor for essential/desired match count for a work opp
-- with competencies for person and work opp coming from temp table
CURSOR csr_tmp_ed_match_count(
        p_mandatory in varchar2) IS
SELECT count(ptmp.competence_id)
FROM   per_suitmatch_comp smtmp,
       per_suitmatch_person ptmp
WHERE  smtmp.competence_id = ptmp.competence_id
AND    nvl(ptmp.min_step_value, -1) >= nvl(smtmp.min_step_value, -1)
AND    smtmp.mandatory = p_mandatory;


--cursor to get position dets
CURSOR csr_position_dets(p_position_id in number) IS
SELECT hpf.position_id,
       hpf.organization_id,
       hpf.job_id
FROM hr_all_positions_f hpf
WHERE TRUNC(sysdate) BETWEEN hpf.effective_start_date
AND hpf.effective_end_date
AND TRUNC(sysdate) BETWEEN hpf.date_effective
AND NVL(hpf.date_end, TRUNC(sysdate))
AND (hpf.status is null OR hpf.status <> 'INVALID')
AND hpf.position_id = p_position_id;

-- cursor to get vacancy dets
CURSOR csr_vacancy_dets(p_vacancy_id in number) IS
SELECT pv.vacancy_id,
       pv.organization_id,
       pv.job_id,
       pv.position_id
FROM per_all_vacancies pv
WHERE TRUNC(sysdate) BETWEEN pv.date_from
AND NVL(pv.date_to, TRUNC(sysdate))
AND pv.vacancy_id = p_vacancy_id;

FUNCTION getTableSchema RETURN VARCHAR2 IS
l_status    VARCHAR2(100) := '';
l_industry  VARCHAR2(100) := '';
l_result    BOOLEAN;
l_schema_owner VARCHAR2(10) := '';
BEGIN
    l_result := FND_INSTALLATION.GET_APP_INFO(
                'PER',
                 l_status,
                 l_industry,
                 l_schema_owner);

    IF l_result THEN
       RETURN l_schema_owner;
    ELSE
       RETURN 'HR';
    END IF;
END getTableSchema;


/**
 * applyOverridingRules applies the overriding rules.
 * Overriding rules are applied only for position and vacancy
 * and the logic is ...
 * For each competence required by the position only then
 * use the low, high and matching level from the position requirements.
 *
 * For each competence required by the position's organization or position's
 * job that is not explicitly required by the position then
 *
 * 1. if the competence is required by job only, then
 *    use the low, high and matching level from the job requirements.
 * 2. if the competence is required by org only, then
 *    use the low, high and matching level from the org requirements.
 * 3. if the competence is essential for org and job then
 *    use the low, high and matching level from the org requirements.
 * 4. if the competence is desirable for org and job, then
 *    use greatest (org low, job low), least (org high, job high) and
 *    matching level.
 * 5. if the competence is essential for org and desirable for job or
 *    essential for job and desirable for org, then 2 requirements are used.
 *    One from the org requirements and one from job requirements.
 * 6. Competence at lower level always overrides BG level.
 *
 */
procedure apply_overridding_rules(
    p_enterprise_id in number
   ,p_organization_id in number
   ,p_job_id in number
   ,p_position_id in number
)
IS

-- cursor to get cummulative competency requirements
CURSOR csr_workopp_comp_reqs(
     p_enterprise_id in number
    ,p_organization_id in number
    ,p_job_id in number
    ,p_position_id in number) IS
SELECT pce.competence_id,
       r1.step_value low_step_value,
       r2.step_value high_step_value,
       pce.mandatory,
       'BUS' lookup_code
FROM   per_competence_elements pce,
       per_rating_levels r1,
       per_rating_levels r2
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    pce.proficiency_level_id = r1.rating_level_id(+)
AND    pce.high_proficiency_level_id = r2.rating_level_id(+)
AND    pce.enterprise_id = p_enterprise_id
UNION ALL
SELECT pce.competence_id,
       r1.step_value low_step_value,
       r2.step_value high_step_value,
       pce.mandatory,
       'ORG' lookup_code
FROM   per_competence_elements pce,
       per_rating_levels r1,
       per_rating_levels r2
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    pce.proficiency_level_id = r1.rating_level_id(+)
AND    pce.high_proficiency_level_id = r2.rating_level_id(+)
AND    pce.organization_id = p_organization_id
UNION ALL
SELECT pce.competence_id,
       r1.step_value low_step_value,
       r2.step_value high_step_value,
       pce.mandatory,
       'JOB' lookup_code
FROM   per_competence_elements pce,
       per_rating_levels r1,
       per_rating_levels r2
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    pce.proficiency_level_id = r1.rating_level_id(+)
AND    pce.high_proficiency_level_id = r2.rating_level_id(+)
AND    pce.job_id = p_job_id
UNION ALL
SELECT pce.competence_id,
       r1.step_value low_step_value,
       r2.step_value high_step_value,
       pce.mandatory,
       'POS' lookup_code
FROM   per_competence_elements pce,
       per_rating_levels r1,
       per_rating_levels r2
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    pce.proficiency_level_id = r1.rating_level_id(+)
AND    pce.high_proficiency_level_id = r2.rating_level_id(+)
AND    pce.position_id = p_position_id;

isSameCompetence boolean default false;
isSameStructureType boolean default false;
isIgnore boolean default false;
isBEssential boolean default false;
isBDesired boolean default false;

TYPE sel_comp_tab IS TABLE OF csr_workopp_comp_reqs%ROWTYPE INDEX BY BINARY_INTEGER ;

l_sel_comp_table sel_comp_tab;
l_mat_comp_table sel_comp_tab;
I integer default 0;

BEGIN

OPEN csr_workopp_comp_reqs(p_enterprise_id, p_organization_id, p_job_id, p_position_id);
LOOP
    I := I + 1;
    FETCH csr_workopp_comp_reqs into l_sel_comp_table(I);
    EXIT WHEN csr_workopp_comp_reqs%NOTFOUND;
END LOOP;
CLOSE csr_workopp_comp_reqs;  -- close cursor variable

l_mat_comp_table := l_sel_comp_table;

-- execute the cursor and apply the overriding rules
FOR J IN 1 ..l_sel_comp_table.count LOOP
    FOR K IN 1 ..l_mat_comp_table.count LOOP
       BEGIN
         isSameCompetence := (l_sel_comp_table(J).competence_id = l_mat_comp_table(K).competence_id);
         isSameStructureType := (l_sel_comp_table(J).lookup_code = l_mat_comp_table(K).lookup_code);
         isIgnore := ('I' = l_mat_comp_table(K).mandatory);

          if(NOT isIgnore and isSameCompetence and NOT isSameStructureType)
            then
              if(l_sel_comp_table(J).mandatory <> 'I')
              then
                isBEssential := ('Y' = l_mat_comp_table(K).mandatory and
                                'Y' = l_sel_comp_table(J).mandatory);
                isBDesired   := ('N' = l_mat_comp_table(K).mandatory and
                                'N' = l_sel_comp_table(J).mandatory);
                --if competence is required for position only
                if('POS' = l_sel_comp_table(J).lookup_code) then
                  l_mat_comp_table(K).mandatory := 'I';
                end if;
                --if the competence is essential for org and job then
                --use the low, high and matching level from the org requirements.
                if(isBEssential and 'ORG' = l_sel_comp_table(J).lookup_code and
                                    'JOB' = l_mat_comp_table(K).lookup_code)
                then
                  l_mat_comp_table(K).mandatory := 'I';
                end if;
                --if the competence is desirable for org and job, then
                --use greatest (org low, job low), least (org high, job high) and
                --matching level.
                if(isBDesired and ('ORG' = l_sel_comp_table(J).lookup_code and
                                   'JOB' = l_mat_comp_table(K).lookup_code))
                then
                  if(l_mat_comp_table(K).low_step_value > l_sel_comp_table(J).low_step_value) then
                     l_sel_comp_table(J).low_step_value := l_mat_comp_table(K).low_step_value;
                     l_mat_comp_table(K).mandatory := 'I';
                  end if;
                  if(l_mat_comp_table(K).high_step_value < l_sel_comp_table(J).high_step_value) then
                     l_sel_comp_table(J).high_step_value := l_mat_comp_table(K).high_step_value;
                     l_mat_comp_table(K).mandatory := 'I';
                  end if;
                end if;
                if(isBDesired and ('JOB' = l_sel_comp_table(J).lookup_code and
                                   'ORG' = l_mat_comp_table(K).lookup_code))
                then
                  if(l_mat_comp_table(K).low_step_value > l_sel_comp_table(J).low_step_value) then
                     l_sel_comp_table(J).low_step_value := l_mat_comp_table(K).low_step_value;
                     l_mat_comp_table(K).mandatory := 'I';
                  end if;
                  if(l_mat_comp_table(K).high_step_value < l_sel_comp_table(J).high_step_value) then
                     l_sel_comp_table(J).high_step_value := l_mat_comp_table(K).high_step_value;
                     l_mat_comp_table(K).mandatory := 'I';
                  end if;
                end if;
                --competence at lower level always overrides BG level
                if(l_sel_comp_table(J).lookup_code <> 'BUS' and
                   ('BUS' = l_mat_comp_table(K).lookup_code))
                then
                    l_mat_comp_table(K).mandatory := 'I';
                end if;
                --if the competence is essential for org and desirable for job or
                --essential for job and desirable for org, then 2 requirements are used..
                --one from the org requirements and one from job requirements.
              end if;
            end if;
       END;
    END LOOP;
END LOOP;

   -- Now insert the competencies into temp table.
    --truncate the table before inserting
    execute immediate 'truncate table '||getTableSchema||'.per_suitmatch_comp';
    FOR L IN 1 ..l_mat_comp_table.count LOOP
      IF (l_mat_comp_table(L).mandatory <> 'I') THEN
	  insert into per_suitmatch_comp (competence_id,
          mandatory, min_step_value)
	  values (to_number(l_mat_comp_table(L).competence_id)
		 ,l_mat_comp_table(L).mandatory
	         ,to_number(l_mat_comp_table(L).low_step_value));
      END IF;
    END LOOP;
    commit;

END apply_overridding_rules;

FUNCTION compare_counts(
   p_ess_match_count in integer
  ,p_total_ess_count in integer
  ,p_des_match_count in integer
  ,p_total_des_count in integer
)
RETURN VARCHAR2
IS
BEGIN

IF ((p_total_ess_count <> 0 AND p_total_des_count <> 0) AND
    ((p_ess_match_count = p_total_ess_count ) AND
     (p_des_match_count = p_total_des_count ))) THEN
   RETURN 'ALL';
END IF;

IF ((p_total_ess_count <> 0 AND (p_ess_match_count = p_total_ess_count))
AND (p_total_des_count = 0 OR (p_des_match_count <> p_total_des_count))) THEN
   RETURN 'ESS';
END IF;

IF ((p_total_des_count <> 0 AND (p_des_match_count = p_total_des_count))
AND (p_total_ess_count = 0 OR (p_ess_match_count <> p_total_ess_count))) THEN
   RETURN 'DES';
END IF;

IF (((p_total_ess_count = 0 OR
      (p_ess_match_count <> p_total_ess_count)) AND
     (p_total_des_count = 0 OR
     (p_des_match_count <> p_total_des_count )))OR
     (p_total_ess_count = 0 AND p_total_des_count = 0)) THEN
   RETURN 'ED';
END IF;

END compare_counts;


FUNCTION get_workopp_ed_match_count (
    p_person_id in number
   ,p_enterprise_id in number
   ,p_organization_id in number
   ,p_job_id in number
   ,p_position_id in number
   ,p_req in varchar2
   ,p_vac_pos boolean default false
   ,p_person_temp boolean default false
)
RETURN INTEGER
IS
l_ret_ess_des_match_count integer;
BEGIN

   IF (p_vac_pos and p_person_temp) THEN
      OPEN csr_tmp_ed_match_count(p_req);
      FETCH csr_tmp_ed_match_count INTO l_ret_ess_des_match_count;
      IF csr_tmp_ed_match_count%NOTFOUND
      THEN
        l_ret_ess_des_match_count := 0;
      END IF;
      CLOSE csr_tmp_ed_match_count;
   ELSIF (p_vac_pos) THEN
      OPEN csr_wp_tmp_ed_match_count(p_person_id, p_req);
      FETCH csr_wp_tmp_ed_match_count INTO l_ret_ess_des_match_count;
      IF csr_wp_tmp_ed_match_count%NOTFOUND
      THEN
        l_ret_ess_des_match_count := 0;
      END IF;
      CLOSE csr_wp_tmp_ed_match_count;
   ELSIF (p_person_temp) THEN
      OPEN csr_wp_per_tmp_ed_match_count(p_enterprise_id, p_organization_id,
                                         p_job_id, p_position_id, p_req);
      FETCH csr_wp_per_tmp_ed_match_count INTO l_ret_ess_des_match_count;
      IF csr_wp_per_tmp_ed_match_count%NOTFOUND
      THEN
        l_ret_ess_des_match_count := 0;
      END IF;
      CLOSE csr_wp_per_tmp_ed_match_count;
   ELSE
      OPEN csr_workopp_ed_match_count(p_person_id, p_enterprise_id
                       ,p_organization_id, p_job_id, p_position_id, p_req);
      FETCH csr_workopp_ed_match_count INTO l_ret_ess_des_match_count;
      IF csr_workopp_ed_match_count%NOTFOUND
      THEN
        l_ret_ess_des_match_count := 0;
      END IF;
      CLOSE csr_workopp_ed_match_count;
   END IF;

  RETURN l_ret_ess_des_match_count;

END get_workopp_ed_match_count;


FUNCTION get_workopp_ed_total_count (
    p_enterprise_id in number
   ,p_organization_id in number
   ,p_job_id in number
   ,p_position_id in number
   ,p_req in varchar2
   ,p_vac_pos boolean default false
)
RETURN INTEGER
IS
l_ret_ess_des_total_count integer;
BEGIN

   IF (p_vac_pos) THEN
      OPEN csr_total_ess_des_count(p_req);
      FETCH csr_total_ess_des_count INTO l_ret_ess_des_total_count;
      IF csr_total_ess_des_count%NOTFOUND
      THEN
        l_ret_ess_des_total_count := 0;
      END IF;
      CLOSE csr_total_ess_des_count;
   ELSE
      OPEN csr_total_workopp_match_count(p_enterprise_id
                   ,p_organization_id, p_job_id, p_position_id, p_req);
      FETCH csr_total_workopp_match_count INTO l_ret_ess_des_total_count;
      IF csr_total_workopp_match_count%NOTFOUND
      THEN
        l_ret_ess_des_total_count := 0;
      END IF;
      CLOSE csr_total_workopp_match_count;
   END IF;

   RETURN l_ret_ess_des_total_count;
END get_workopp_ed_total_count;


PROCEDURE get_ess_desired_match (
     p_person_id in number
    ,p_enterprise_id in number default -1
    ,p_organization_id in number default -1
    ,p_job_id in number default -1
    ,p_position_id in number default -1
    ,p_vacancy_id in number default -1
    ,p_req in varchar2
    ,p_person_temp in number default 0
    ,p_ess_des_match_count out nocopy number
    ,p_total_ess_des_count out nocopy number

)
IS

l_enterprise_id  per_competence_elements.enterprise_id%type;
l_organization_id  per_competence_elements.organization_id%type;
l_job_id  per_competence_elements.job_id%type;
l_position_id  per_competence_elements.position_id%type;
l_vacancy_id  per_all_vacancies.vacancy_id%type;
is_vac_pos boolean default false;

BEGIN

-- move into local variables
l_enterprise_id := p_enterprise_id;
l_organization_id := p_organization_id;
l_job_id := p_job_id;
l_position_id := nvl(p_position_id, -1);
l_vacancy_id := nvl(p_vacancy_id, -1);

-- now get the position and vacancy dets, if any
IF(l_vacancy_id <> -1) THEN
   is_vac_pos := true;
   OPEN csr_vacancy_dets(p_vacancy_id);
   FETCH csr_vacancy_dets INTO l_vacancy_id, l_organization_id,
                               l_job_id, l_position_id;
   CLOSE csr_vacancy_dets;
END IF;
IF(l_position_id <> -1) THEN
   is_vac_pos := true;
   OPEN csr_position_dets(p_position_id);
   FETCH csr_position_dets INTO l_position_id, l_organization_id,
                               l_job_id;
   CLOSE csr_position_dets;
END IF;


-- if the passed in is a vacancy id/position id need to apply overridding rules
-- and populate the temp table
   IF (is_vac_pos) THEN
      apply_overridding_rules(l_enterprise_id, l_organization_id, l_job_id, l_position_id);
   END IF;

   -- get ess match count
   p_ess_des_match_count := get_workopp_ed_match_count(p_person_id, l_enterprise_id,
               l_organization_id, l_job_id, l_position_id, p_req, is_vac_pos, (p_person_temp = 1));
   -- get total ess count
   p_total_ess_des_count := get_workopp_ed_total_count(l_enterprise_id
                            ,l_organization_id, l_job_id, l_position_id, p_req, is_vac_pos);

END get_ess_desired_match;


PROCEDURE populate_comp_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
)
IS
BEGIN
    --truncate the table before inserting
    execute immediate 'truncate table '||getTableSchema||'.per_suitmatch_comp';
    FOR I IN 1 ..p_temp_tab.count LOOP
      insert into per_suitmatch_comp (competence_id,
      mandatory, min_step_value)
      values (to_number(p_temp_tab(I).competence_id)
             ,p_temp_tab(I).mandatory
	     ,to_number(p_temp_tab(I).min_step_value));
    END LOOP;
    commit;
END populate_comp_temp_table;

PROCEDURE populate_per_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
)
IS
--cursor to get the suitable work opp ids
CURSOR csr_suit_workopps(p_person_id in number) IS
SELECT /*+ leading(pcp) index(pce, PER_COMPETENCE_ELEMENTS_N1) */
       decode(pce.enterprise_id, null,
       (decode(pce.organization_id, null,
        (decode(pce.job_id, null,
         (decode(pce.position_id,null,
            -1, pce.position_id)),pce.job_id)),
            pce.organization_id)),pce.enterprise_id) workopp_id,
       decode(pce.enterprise_id, null,
       (decode(pce.organization_id, null,
        (decode(pce.job_id, null,
         (decode(pce.position_id, null,
           'SM','POS')),'JOB')),'ORG')),'BUS') type,
       ppf.person_id
FROM   per_competence_elements pce,
       per_suitmatch_person pcp,
       per_all_people_f ppf
WHERE  pce.type = 'REQUIREMENT'
AND    trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate))
       and nvl(pce.effective_date_to, trunc(sysdate))
AND    pce.business_group_id = decode(hr_general.get_xbg_profile,
                               'Y', pce.business_group_id, ppf.business_group_id)
AND    pce.competence_id = pcp.competence_id
AND    pcp.mandatory = p_person_id
AND    ppf.person_id = pcp.mandatory
AND    trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
AND    pce.object_name is null
GROUP BY pce.enterprise_id, pce.organization_id, pce.job_id, pce.position_id, ppf.person_id
ORDER BY type;

TYPE csr_workopp_tab IS TABLE OF csr_suit_workopps%ROWTYPE INDEX BY BINARY_INTEGER;
l_csr_workopp_tab csr_workopp_tab;
l_person_id number;
J integer := 0;
l_ess_match varchar2(30);
l_des_match varchar2(30);
l_meets varchar2(30);
l_ess_match_count integer;
l_total_ess_count integer;
l_des_match_count integer;
l_total_des_count integer;

BEGIN
    --insert the person competencies into per_suitmatch_person temp table
    --truncate the table before inserting
    execute immediate 'truncate table '||getTableSchema||'.per_suitmatch_person';
    FOR I IN 1 ..p_temp_tab.count LOOP
      l_person_id := p_temp_tab(I).mandatory;
      insert into per_suitmatch_person (competence_id,
      mandatory, min_step_value)
      values (to_number(p_temp_tab(I).competence_id)
             ,p_temp_tab(I).mandatory
	     ,to_number(p_temp_tab(I).min_step_value));
    END LOOP;

    --get suitable work opportunities using person competencies of per_suitmatch_person temp table
    OPEN csr_suit_workopps(l_person_id);
    LOOP
       EXIT WHEN csr_suit_workopps%NOTFOUND;
       J := J + 1;
       FETCH csr_suit_workopps into l_csr_workopp_tab(J);
    END LOOP;
    CLOSE csr_suit_workopps;  -- close cursor variable

   --now populate the per_suitmatch_workopps with the suitable work opp, essential, desired match and meets
   --truncate the table before inserting
   execute immediate 'truncate table '||getTableSchema||'.per_suitmatch_workopps';
   FOR I IN 1 ..l_csr_workopp_tab.count LOOP
    BEGIN
    -- get the essential and desired match
      l_ess_match := null;
      l_des_match := null;
      l_meets := null;
      IF (l_csr_workopp_tab(I).type = 'ORG') THEN
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, l_csr_workopp_tab(I).workopp_id, -1, -1, -1,
	                  'Y', 1, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, l_csr_workopp_tab(I).workopp_id, -1, -1, -1,
	                  'N', 1, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      ELSIF (l_csr_workopp_tab(I).type = 'JOB') THEN
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, -1, l_csr_workopp_tab(I).workopp_id, -1, -1,
	                  'Y', 1, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, -1, l_csr_workopp_tab(I).workopp_id, -1, -1,
	                  'N', 1, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      ELSIF (l_csr_workopp_tab(I).type = 'POS') THEN
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, -1, -1, l_csr_workopp_tab(I).workopp_id, -1,
	                  'Y', 1, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, -1, -1, l_csr_workopp_tab(I).workopp_id, -1,
	                  'N', 1, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      ELSIF (l_csr_workopp_tab(I).type = 'VAC') THEN
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, -1, -1, -1, l_csr_workopp_tab(I).workopp_id,
	                  'Y', 1, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(l_csr_workopp_tab(I).person_id, -1, -1, -1, -1, l_csr_workopp_tab(I).workopp_id,
	                  'N', 1, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      END IF;
      insert into per_suitmatch_workopps (workopp_id,
      type, ess_match, des_match, meets)
      values (to_number(l_csr_workopp_tab(I).workopp_id)
             ,l_csr_workopp_tab(I).type, l_ess_match, l_des_match, l_meets);
    END;
   END LOOP;
   commit;
END populate_per_temp_table;

PROCEDURE populate_workopp_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
)IS

l_ess_match varchar2(30);
l_des_match varchar2(30);
l_meets varchar2(30);
l_ess_match_count integer;
l_total_ess_count integer;
l_des_match_count integer;
l_total_des_count integer;

BEGIN
    --truncate the table before inserting
    execute immediate 'truncate table '||getTableSchema||'.per_suitmatch_workopps';
    FOR I IN 1 ..p_temp_tab.count LOOP
    -- get the essential and desired match
      IF (p_temp_tab(I).mandatory = 'ORG') THEN
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, p_temp_tab(I).competence_id, -1, -1, -1,
	                  'Y', 0, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, p_temp_tab(I).competence_id, -1, -1, -1,
	                  'N', 0, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      ELSIF (p_temp_tab(I).mandatory = 'JOB') THEN
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, -1, p_temp_tab(I).competence_id, -1, -1,
	                  'Y', 0, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, -1, p_temp_tab(I).competence_id, -1, -1,
	                  'N', 0, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      ELSIF (p_temp_tab(I).mandatory = 'POS') THEN
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, -1, -1, p_temp_tab(I).competence_id, -1,
	                  'Y', 0, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, -1, -1, p_temp_tab(I).competence_id, -1,
	                  'N', 0, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      ELSIF (p_temp_tab(I).mandatory = 'VAC') THEN
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, -1, -1, -1, p_temp_tab(I).competence_id,
	                  'Y', 0, l_ess_match_count, l_total_ess_count);
	 get_ess_desired_match(p_temp_tab(I).min_step_value, -1, -1, -1, -1, p_temp_tab(I).competence_id,
	                  'N', 0, l_des_match_count, l_total_des_count);
	 l_ess_match := l_ess_match_count || '/' || l_total_ess_count;
	 l_des_match := l_des_match_count || '/' || l_total_des_count;
	 l_meets := compare_counts(l_ess_match_count, l_total_ess_count,
	                           l_des_match_count, l_total_des_count);
      END IF;
      insert into per_suitmatch_workopps (workopp_id,
      type, ess_match, des_match, meets)
      values (to_number(p_temp_tab(I).competence_id)
             ,p_temp_tab(I).mandatory, l_ess_match, l_des_match, l_meets);
    END LOOP;
    commit;
END populate_workopp_temp_table;

PROCEDURE insert_workopp_temp_table (
    p_temp_tab IN SSHR_SM_COMP_DETAILS_TAB_TYP
)
IS
BEGIN
    --truncate the table before inserting
    execute immediate 'truncate table '||getTableSchema||'.per_suitmatch_workopps';
    FOR I IN 1 ..p_temp_tab.count LOOP
      insert into per_suitmatch_workopps (workopp_id,
                  type)
      values (to_number(p_temp_tab(I).competence_id)
             ,p_temp_tab(I).mandatory);
    END LOOP;
    commit;

END insert_workopp_temp_table;


FUNCTION get_ess_des_match_count (
    p_person_id in number
   ,p_req in varchar2
)
RETURN INTEGER
IS
l_ret_ess_des_match_count integer;
BEGIN

   OPEN csr_ess_des_match_count(p_person_id, p_req);
   FETCH csr_ess_des_match_count INTO l_ret_ess_des_match_count;
   IF csr_ess_des_match_count%NOTFOUND
   THEN
     l_ret_ess_des_match_count := 0;
   END IF;
   CLOSE csr_ess_des_match_count;

   RETURN l_ret_ess_des_match_count;
END get_ess_des_match_count;


FUNCTION get_ess_des_total_count (
   p_req in varchar2
)
RETURN INTEGER
IS
l_ret_ess_des_total_count integer;
BEGIN
   ---- added for improviing performance
   IF p_req = 'Y' THEN
    IF g_ess_total_count IS NOT NULL THEN
       hr_utility.trace('returing from ess global');
       RETURN g_ess_total_count;
    END IF;
   ELSE
    IF g_des_total_count IS NOT NULL THEN
       hr_utility.trace('returing from des global');
       RETURN g_des_total_count;
    END IF;
   END IF;
   -- upto here
   OPEN csr_total_ess_des_count(p_req);
   FETCH csr_total_ess_des_count INTO l_ret_ess_des_total_count;
   IF csr_total_ess_des_count%NOTFOUND
   THEN
     l_ret_ess_des_total_count := 0;
   END IF;
   CLOSE csr_total_ess_des_count;
   ---- added for improviing performance
   IF p_req = 'Y' THEN
      g_ess_total_count := l_ret_ess_des_total_count;
   ELSE
      g_des_total_count := l_ret_ess_des_total_count;
   END IF;
   --
   hr_utility.trace('returning from sql code');
   RETURN l_ret_ess_des_total_count;
END get_ess_des_total_count;


FUNCTION compare_counts(
   p_ess_match_count in integer
  ,p_total_ess_count in integer
  ,p_des_match_count in integer
  ,p_total_des_count in integer
  ,p_meets in varchar2
)
RETURN VARCHAR2
IS
BEGIN

IF (p_meets = 'ALL') THEN
    IF ((p_total_ess_count <> 0 AND p_total_des_count <> 0) AND
        ((p_ess_match_count = p_total_ess_count ) AND
         (p_des_match_count = p_total_des_count ))) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
ELSIF (p_meets = 'ESS') THEN
    IF ((p_total_ess_count <> 0 AND (p_ess_match_count = p_total_ess_count))
    AND (p_total_des_count = 0 OR (p_des_match_count <> p_total_des_count))) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
ELSIF (p_meets = 'DES') THEN
    IF ((p_total_des_count <> 0 AND (p_des_match_count = p_total_des_count))
    AND (p_total_ess_count = 0 OR (p_ess_match_count <> p_total_ess_count))) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
ELSIF (p_meets = 'ED') THEN
    IF (((p_total_ess_count = 0 OR
          (p_ess_match_count <> p_total_ess_count)) AND
         (p_total_des_count = 0 OR
         (p_des_match_count <> p_total_des_count )))OR
	     (p_total_ess_count = 0 AND p_total_des_count = 0)) THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
END IF;

END compare_counts;

FUNCTION get_ess_desired_match (
    p_person_id in number
   ,p_req in varchar2
)
RETURN VARCHAR2
IS

l_ess_des_match_count integer;
l_total_ess_des_count integer;

BEGIN
    -- get ess match count
    --IF NVL(g_prev_person_id,-1) <> p_person_id THEN --- added for PERF by KMG
      l_ess_des_match_count := get_ess_des_match_count(p_person_id, p_req);

    -- get total ess count
    --l_total_ess_des_count := get_ess_des_total_count(p_req);
    -- total count is now retrieved in java side

    --- return the ess match
    --- changes by KMG for performance
      g_prev_person_id := p_person_id;
      IF p_req = 'Y' THEN
         g_prev_ess_count := l_ess_des_match_count;
       ELSE
         g_prev_des_count := l_ess_des_match_count;
       END IF;
       hr_utility.trace('returning from sql for : '||p_person_id);
      RETURN l_ess_des_match_count || '/' ;
/*    ELSE --- added for PERF by KMG
           hr_utility.trace('returning from global for : '||p_person_id);
      IF p_req  = 'Y' THEN
        RETURN g_prev_ess_count || '/';
      ELSE
        RETURN g_prev_des_count || '/';
      END IF;
    END IF; --- added for PERF by KMG
*/
END get_ess_desired_match;


FUNCTION get_ess_desired_match (
     p_person_id in number
    ,p_enterprise_id in number default -1
    ,p_organization_id in number default -1
    ,p_job_id in number default -1
    ,p_position_id in number default -1
    ,p_vacancy_id in number default -1
    ,p_req in varchar2
    ,p_person_temp in number default 0
)
RETURN VARCHAR2
IS PRAGMA AUTONOMOUS_TRANSACTION;

l_enterprise_id  per_competence_elements.enterprise_id%type;
l_organization_id  per_competence_elements.organization_id%type;
l_job_id  per_competence_elements.job_id%type;
l_position_id  per_competence_elements.position_id%type;
l_vacancy_id  per_all_vacancies.vacancy_id%type;
l_ess_des_match_count integer;
l_total_ess_des_count integer;
is_vac_pos boolean default false;

BEGIN

-- move into local variables
l_enterprise_id := p_enterprise_id;
l_organization_id := p_organization_id;
l_job_id := p_job_id;
l_position_id := nvl(p_position_id, -1);
l_vacancy_id := nvl(p_vacancy_id, -1);

-- now get the position and vacancy dets, if any
IF(l_vacancy_id <> -1) THEN
   is_vac_pos := true;
   OPEN csr_vacancy_dets(p_vacancy_id);
   FETCH csr_vacancy_dets INTO l_vacancy_id, l_organization_id,
                               l_job_id, l_position_id;
   CLOSE csr_vacancy_dets;
END IF;
IF(l_position_id <> -1) THEN
   is_vac_pos := true;
   OPEN csr_position_dets(p_position_id);
   FETCH csr_position_dets INTO l_position_id, l_organization_id,
                               l_job_id;
   CLOSE csr_position_dets;
END IF;


-- if the passed in is a vacancy id/position id need to apply overridding rules
-- and populate the temp table
   IF (is_vac_pos) THEN
      apply_overridding_rules(l_enterprise_id, l_organization_id, l_job_id, l_position_id);
   END IF;

   -- get ess match count
   l_ess_des_match_count := get_workopp_ed_match_count(p_person_id, l_enterprise_id,
               l_organization_id, l_job_id, l_position_id, p_req, is_vac_pos, (p_person_temp = 1));
   -- get total ess count
   l_total_ess_des_count := get_workopp_ed_total_count(l_enterprise_id
                            ,l_organization_id, l_job_id, l_position_id, p_req, is_vac_pos);

--- return the ess match
RETURN l_ess_des_match_count || '/' || l_total_ess_des_count;

END get_ess_desired_match;

FUNCTION is_ess_des_meets (
     p_person_id in number
    ,p_meets in varchar2
)
RETURN VARCHAR2
IS

l_ess_match_count integer;
l_total_ess_count integer;
l_des_match_count integer;
l_total_des_count integer;


BEGIN

 -- first get the ess match count
    l_ess_match_count := get_ess_des_match_count(p_person_id, 'Y');
 -- get the des match count
    l_des_match_count := get_ess_des_match_count(p_person_id, 'N');
 -- get the total ess count
    l_total_ess_count := get_ess_des_total_count('Y');
 -- get the total des count
    l_total_des_count := get_ess_des_total_count('N');

 RETURN compare_counts(
         l_ess_match_count
        ,l_total_ess_count
        ,l_des_match_count
        ,l_total_des_count
        ,p_meets);

END is_ess_des_meets;


FUNCTION is_ess_des_meets (
     p_person_id in number
    ,p_enterprise_id in number default -1
    ,p_organization_id in number default -1
    ,p_job_id in number default -1
    ,p_position_id in number default -1
    ,p_vacancy_id in number default -1
    ,p_meets in varchar2
    ,p_person_temp in number default 0
)
RETURN VARCHAR2
IS PRAGMA AUTONOMOUS_TRANSACTION;

l_enterprise_id  per_competence_elements.enterprise_id%type;
l_organization_id  per_competence_elements.organization_id%type;
l_job_id  per_competence_elements.job_id%type;
l_position_id  per_competence_elements.position_id%type;
l_vacancy_id  per_all_vacancies.vacancy_id%type;

l_ess_match_count integer;
l_total_ess_count integer;
l_des_match_count integer;
l_total_des_count integer;
is_vac_pos boolean default false;

BEGIN

-- move into local variables
l_enterprise_id := p_enterprise_id;
l_organization_id := p_organization_id;
l_job_id := p_job_id;
l_position_id := nvl(p_position_id, -1);
l_vacancy_id := nvl(p_vacancy_id, -1);

-- now get the position and vacancy dets, if any
IF(l_vacancy_id <> -1) THEN
   is_vac_pos := true;
   OPEN csr_vacancy_dets(p_vacancy_id);
   FETCH csr_vacancy_dets INTO l_vacancy_id, l_organization_id,
                               l_job_id, l_position_id;
   CLOSE csr_vacancy_dets;
END IF;
IF(l_position_id <> -1) THEN
   is_vac_pos := true;
   OPEN csr_position_dets(p_position_id);
   FETCH csr_position_dets INTO l_position_id, l_organization_id,
                               l_job_id;
   CLOSE csr_position_dets;
END IF;


-- if the passed in is a vacancy id/position id need to apply overridding rules
-- and populate the temp table
IF (is_vac_pos) THEN
   apply_overridding_rules(l_enterprise_id, l_organization_id, l_job_id, l_position_id);
END IF;

 -- first get the ess match count
    l_ess_match_count := get_workopp_ed_match_count(p_person_id, l_enterprise_id
              ,l_organization_id, l_job_id, l_position_id, 'Y', is_vac_pos, (p_person_temp = 1));
 -- get the des match count
    l_des_match_count := get_workopp_ed_match_count(p_person_id, l_enterprise_id
              ,l_organization_id, l_job_id, l_position_id, 'N', is_vac_pos, (p_person_temp = 1));
 -- get the total ess count
    l_total_ess_count := get_workopp_ed_total_count(l_enterprise_id
                            ,l_organization_id, l_job_id, l_position_id, 'Y', is_vac_pos);
 -- get the total des count
    l_total_des_count := get_workopp_ed_total_count(l_enterprise_id
                            ,l_organization_id, l_job_id, l_position_id, 'N', is_vac_pos);

 RETURN compare_counts(
         l_ess_match_count
        ,l_total_ess_count
        ,l_des_match_count
        ,l_total_des_count
        ,p_meets);

END is_ess_des_meets;


FUNCTION get_bg_name(
    p_bg_id in number
)
RETURN VARCHAR2
IS
  CURSOR csr_bg_name IS
    SELECT name
    FROM hr_all_organization_units_tl
    WHERE organization_id = p_bg_id
    AND language = userenv('LANG');

  l_bg_name hr_all_organization_units_tl.name%type;

BEGIN

   OPEN csr_bg_name;
   FETCH csr_bg_name into l_bg_name;
   CLOSE csr_bg_name;
   RETURN l_bg_name;

END get_bg_name;

FUNCTION get_application_date(
   p_person_id in number
)
RETURN DATE
IS

   CURSOR csr_appl_date IS
    SELECT date_received
    FROM per_applications
    WHERE person_id(+) = p_person_id
      AND (date_end is null);

  l_date_received per_applications.date_received%type;

BEGIN

   OPEN csr_appl_date;
   FETCH csr_appl_date into l_date_received;
   CLOSE csr_appl_date;
   RETURN l_date_received;

END get_application_date;


FUNCTION get_emp_start_date(
    p_period_of_service_id in number
  )
RETURN DATE
IS

   CURSOR csr_emp_start_date IS
    SELECT date_start
    FROM per_periods_of_service
    WHERE period_of_service_id(+) = p_period_of_service_id;

  l_date_start per_periods_of_service.date_start%type;

BEGIN

   OPEN csr_emp_start_date;
   FETCH csr_emp_start_date into l_date_start;
   CLOSE csr_emp_start_date;
   RETURN l_date_start;

END get_emp_start_date;

FUNCTION get_cwk_start_date(
    p_person_id in number
  )
RETURN DATE
IS

   CURSOR csr_cwk_start_date IS
    SELECT date_start
    FROM per_periods_of_placement
    WHERE actual_termination_date is null OR
         (trunc(sysdate) < actual_termination_date);

  l_date_start per_periods_of_placement.date_start%type;

BEGIN

   OPEN csr_cwk_start_date;
   FETCH csr_cwk_start_date into l_date_start;
   CLOSE csr_cwk_start_date;
   RETURN l_date_start;

END get_cwk_start_date;


END HR_SUIT_MATCH_UTIL_SS;

/
