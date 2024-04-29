--------------------------------------------------------
--  DDL for Package Body HR_APPRAISALS_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPRAISALS_UTIL_SS" as
/* $Header: hrapprss.pkb 120.9.12010000.9 2010/05/22 12:06:16 psugumar ship $ */

-- Global cursor for getting competence ratings
   CURSOR get_competence_ratings(p_competence_id NUMBER,
                               p_assessment_id NUMBER) IS
         select prl1.step_value prof_value, prl2.step_value perf_value, prl3.step_value weigh_value
         from per_competence_elements pce, per_rating_levels_vl prl1, per_rating_levels_vl prl2,
              per_rating_levels_vl prl3
         where pce.assessment_id = p_assessment_id and pce.competence_id = p_competence_id
         and pce.type='ASSESSMENT' and pce.object_name='ASSESSOR_ID'
         and pce.proficiency_level_id = prl1.rating_level_id(+)
         and pce.rating_level_id = prl2.rating_level_id (+)
         and pce.weighting_level_id = prl3.rating_level_id(+)
         and (prl1.step_value is not null or prl2.step_value is not null or
              prl3.step_value is not null)
	 and exists (select * from per_participants pp where pp.PARTICIPATION_STATUS='COMPLETED'
	 AND pp.PARTICIPATION_IN_COLUMN='APPRAISAL_ID'
	 AND pp.PARTICIPATION_IN_ID=(select APPRAISAL_ID from per_assessments
	 where assessment_id=p_assessment_id)
	 AND pp.PERSON_ID=pce.object_id );
-- table type for appraisal objectives
   TYPE comp_ratings_table IS TABLE OF get_competence_ratings%ROWTYPE INDEX BY BINARY_INTEGER ;

-- Global cursor for getting objective ratings
   CURSOR get_objective_ratings(p_objective_id NUMBER,
                                p_assessment_id NUMBER) IS
         select prl.step_value perf_value, pos.weighting_percent weigh_percent
         from per_performance_ratings ppr, per_rating_levels_vl prl, per_assessments pas,
          per_objectives pos
         where pas.assessment_id = p_assessment_id
	 and ppr.objective_id = p_objective_id
	 and ppr.appraisal_id = pas.appraisal_id
         and ppr.performance_level_id = prl.rating_level_id
         and pos.appraisal_id = ppr.appraisal_id
         and pos.objective_id =  ppr.objective_id
 	 and exists (select * from per_participants pp where pp.PARTICIPATION_STATUS='COMPLETED'
	 AND pp.PARTICIPATION_IN_COLUMN='APPRAISAL_ID'
	 AND pp.PARTICIPATION_IN_ID=(select APPRAISAL_ID from per_assessments
	 where assessment_id=p_assessment_id)
	 AND pp.PERSON_ID=ppr.PERSON_ID);

-- table type for appraisal objectives
   TYPE obj_ratings_table IS TABLE OF get_objective_ratings%ROWTYPE INDEX BY BINARY_INTEGER ;

--
-- Global cursor for getting the appraisee appraisal info
--
   CURSOR get_appraisal_details(p_assessment_id NUMBER) IS
	select pap.appraisal_id,
	       pap.assignment_id,
	       pap.assignment_business_group_id,
	       pap.assignment_organization_id,
	       pap.appraisee_person_id,
               pap.appraisal_template_id,
               pap.system_type,
               pap.type
	from per_appraisals pap,
	     per_assessments pas
	where pas.assessment_id = p_assessment_id
	and pap.appraisal_id = pas.appraisal_id;

FUNCTION get_comp_line_score(p_line_formula IN VARCHAR,
                             p_comp_ratings IN comp_ratings_table) return NUMBER IS
i INTEGER DEFAULT 0;
j INTEGER DEFAULT 0;
l_comp_score NUMBER := 0;
BEGIN
    FOR i IN 1 ..p_comp_ratings.count LOOP
        j := j+1;
        if(p_line_formula = 'WEIGHTING*PROFICIENCY') then
           l_comp_score := l_comp_score + (nvl(p_comp_ratings(i).prof_value,1) * nvl(p_comp_ratings(i).weigh_value,1));
        elsif (p_line_formula = 'WEIGHTING*PERFORMANCE') then
           l_comp_score := l_comp_score + (nvl(p_comp_ratings(i).perf_value,1) * nvl(p_comp_ratings(i).weigh_value,1));
        elsif (p_line_formula = 'PERFORMANCE*PROFICIENCY') then
           l_comp_score := l_comp_score + (nvl(p_comp_ratings(i).prof_value,1) * nvl(p_comp_ratings(i).perf_value,1));
        elsif (p_line_formula = 'PERFORMANCE') then
           l_comp_score := l_comp_score + nvl(p_comp_ratings(i).perf_value,0);
        elsif (p_line_formula = 'PROFICIENCY') then
           l_comp_score := l_comp_score + nvl(p_comp_ratings(i).prof_value,0);
        end if;
    END LOOP;

    if(j = 0) then
      j := 1;
    end if;

    return l_comp_score / j;
END;


FUNCTION get_ff_line_score (p_object_id in NUMBER,
                            p_assessment_id in NUMBER,
                            p_line_formula_id in NUMBER,
			    p_prof_value in NUMBER,
                            p_perf_value in NUMBER,
	   		    p_weigh_value in NUMBER) return NUMBER IS

  l_effective_date     DATE := trunc(sysdate);
  e_wrong_parameters   EXCEPTION;
  l_line_formula_id    NUMBER;
  l_formula_name       ff_formulas_f.formula_name%TYPE := '&formula_name';
  l_inputs             ff_exec.inputs_t;
  l_outputs            ff_exec.outputs_t;
  l_line_score         NUMBER;

  l_business_group_id  per_appraisals.assignment_business_group_id%TYPE;
  l_assignment_id      per_appraisals.assignment_id%TYPE;
  l_organization_id    per_appraisals.assignment_organization_id%TYPE;
  l_person_id          per_appraisals.appraisee_person_id%TYPE;
  l_appraisal_id       per_appraisals.appraisal_id%TYPE;
  l_appraisal_temp_id  per_appraisals.appraisal_template_id%TYPE;
  l_appr_system_type   per_appraisals.system_type%TYPE;
  l_appr_type          per_appraisals.type%TYPE;
  --
  -- Get the line FF.
  --
  CURSOR csr_get_line_ff
  IS
  SELECT ff.formula_id, ff.formula_name
  FROM   ff_formulas_f ff
  WHERE  l_effective_date BETWEEN
         ff.effective_start_date AND ff.effective_end_date
  AND    ff.formula_id = p_line_formula_id;

BEGIN

  --
  -- Fetch the line scoring formula ID.
  --
  OPEN  csr_get_line_ff;
  FETCH csr_get_line_ff INTO l_line_formula_id
                            ,l_formula_name;
  CLOSE csr_get_line_ff;

  IF l_line_formula_id IS null THEN
     fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
     fnd_message.set_token('1', l_formula_name);
     fnd_message.raise_error;
  END IF;

  --
  -- Initialize the Fast Formula.
  --
  ff_exec.init_formula
      (p_formula_id     => l_line_formula_id
      ,p_effective_date => l_effective_date
      ,p_inputs         => l_inputs
      ,p_outputs        => l_outputs);

  --
  -- Get appraisee appraisal details
  --
  OPEN  get_appraisal_details(p_assessment_id);
  FETCH get_appraisal_details INTO l_appraisal_id,
                                    l_assignment_id,
                                    l_business_group_id,
				    l_organization_id,
				    l_person_id,
                                    l_appraisal_temp_id,
                                    l_appr_system_type,
                                    l_appr_type;
  CLOSE get_appraisal_details;
  --
  -- Assign the FF inputs.
  --
  if (l_inputs.count <> 0) then
  FOR i_input IN l_inputs.first..l_inputs.last LOOP

      IF l_inputs(i_input).name    = 'BUSINESS_GROUP_ID' THEN
         l_inputs(i_input).value  := l_business_group_id;
      ELSIF l_inputs(i_input).name = 'ASSIGNMENT_ID' THEN
         l_inputs(i_input).value  := l_assignment_id;
      ELSIF l_inputs(i_input).name = 'ORGANIZATION_ID' THEN
         l_inputs(i_input).value  := l_organization_id;
      ELSIF l_inputs(i_input).name = 'PERSON_ID' THEN
         l_inputs(i_input).value  := l_person_id;
      ELSIF l_inputs(i_input).name = 'DATE_EARNED' THEN
         l_inputs(i_input).value  := fnd_date.date_to_canonical(l_effective_date);
      ELSIF l_inputs(i_input).name = 'PERFORMANCE' THEN
         l_inputs(i_input).value  := p_perf_value;
      ELSIF l_inputs(i_input).name = 'PROFICIENCY' THEN
         l_inputs(i_input).value  := p_prof_value;
      ELSIF l_inputs(i_input).name = 'WEIGHTING' THEN
         l_inputs(i_input).value  := p_weigh_value;
      ELSIF l_inputs(i_input).name = 'LINE_OBJECT_ID' THEN
         l_inputs(i_input).value  := p_object_id;
      ELSIF l_inputs(i_input).name = 'APPRAISAL_ID' THEN
         l_inputs(i_input).value  := l_appraisal_id;
      ELSIF l_inputs(i_input).name = 'APPR_TEMPLATE_ID' THEN
         l_inputs(i_input).value  := l_appraisal_temp_id;
      ELSIF l_inputs(i_input).name = 'APPR_SYSTEM_TYPE' THEN
         l_inputs(i_input).value  := l_appr_system_type;
      ELSIF l_inputs(i_input).name = 'APPR_TYPE' THEN
         l_inputs(i_input).value  := l_appr_type;
      ELSE
         raise e_wrong_parameters;
      END IF;

  END LOOP;
 END IF;

  --
  -- Run the FF.
  --
  ff_exec.run_formula(l_inputs, l_outputs);

  --
  -- Assign the outputs.
  --
  FOR i_output in l_outputs.first..l_outputs.last LOOP

      IF l_outputs(i_output).name = 'LINE_SCORE' THEN
        IF substr(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),1,1) = ',' then
            l_line_score := replace(l_outputs(i_output).value,'.',',');
        ELSE
            l_line_score := l_outputs(i_output).value;
        END IF;
      ELSE
        RAISE e_wrong_parameters;
      END IF;

  END LOOP;

  return l_line_score;

EXCEPTION

  WHEN e_wrong_parameters THEN
    --
    -- The inputs / outputs of the Fast Formula are incorrect
    -- so raise an error.
    --
    hr_utility.set_message(800,'HR_34964_BAD_FF_DEFINITION');
    hr_utility.raise_error;

  WHEN OTHERS THEN
    RAISE;

END;

FUNCTION get_ff_overall_score (p_comp_asmt_score NUMBER,
                               p_obj_asmt_score NUMBER,
                               p_final_formula_id NUMBER,
                               p_assessment_id NUMBER) return NUMBER IS

  l_effective_date     DATE := trunc(sysdate);
  e_wrong_parameters   EXCEPTION;
  l_final_formula_id    NUMBER;
  l_formula_name       ff_formulas_f.formula_name%TYPE := '&formula_name';
  l_inputs             ff_exec.inputs_t;
  l_outputs            ff_exec.outputs_t;
  l_line_score         NUMBER;

  l_business_group_id  per_appraisals.assignment_business_group_id%TYPE;
  l_assignment_id      per_appraisals.assignment_id%TYPE;
  l_organization_id    per_appraisals.assignment_organization_id%TYPE;
  l_person_id          per_appraisals.appraisee_person_id%TYPE;
  l_appraisal_id       per_appraisals.appraisal_id%TYPE;
  l_appraisal_temp_id  per_appraisals.appraisal_template_id%TYPE;
  l_appr_system_type   per_appraisals.system_type%TYPE;
  l_appr_type          per_appraisals.type%TYPE;
  --
  -- Get the line FF.
  --
  CURSOR csr_get_line_ff
  IS
  SELECT ff.formula_id, ff.formula_name
  FROM   ff_formulas_f ff
  WHERE  l_effective_date BETWEEN
         ff.effective_start_date AND ff.effective_end_date
  AND    ff.formula_id = p_final_formula_id;

BEGIN

  --
  -- Fetch the line scoring formula ID.
  --
  OPEN  csr_get_line_ff;
  FETCH csr_get_line_ff INTO l_final_formula_id
                            ,l_formula_name;
  CLOSE csr_get_line_ff;

  IF l_final_formula_id IS null THEN
     fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
     fnd_message.set_token('1', l_formula_name);
     fnd_message.raise_error;
  END IF;

  --
  -- Initialize the Fast Formula.
  --
  ff_exec.init_formula
      (p_formula_id     => l_final_formula_id
      ,p_effective_date => l_effective_date
      ,p_inputs         => l_inputs
      ,p_outputs        => l_outputs);

  --
  -- Get appraisee appraisal details
  --
  OPEN  get_appraisal_details(p_assessment_id);
  FETCH get_appraisal_details INTO l_appraisal_id,
                                    l_assignment_id,
                                    l_business_group_id,
				    l_organization_id,
				    l_person_id,
                                    l_appraisal_temp_id,
                                    l_appr_system_type,
                                    l_appr_type;
  CLOSE get_appraisal_details;
  --
  -- Assign the FF inputs.
  --
  if (l_inputs.count <> 0) then
  FOR i_input IN l_inputs.first..l_inputs.last LOOP

      IF l_inputs(i_input).name    = 'BUSINESS_GROUP_ID' THEN
         l_inputs(i_input).value  := l_business_group_id;
      ELSIF l_inputs(i_input).name = 'ASSIGNMENT_ID' THEN
         l_inputs(i_input).value  := l_assignment_id;
      ELSIF l_inputs(i_input).name = 'ORGANIZATION_ID' THEN
         l_inputs(i_input).value  := l_organization_id;
      ELSIF l_inputs(i_input).name = 'PERSON_ID' THEN
         l_inputs(i_input).value  := l_person_id;
      ELSIF l_inputs(i_input).name = 'DATE_EARNED' THEN
         l_inputs(i_input).value  := fnd_date.date_to_canonical(l_effective_date);
      ELSIF l_inputs(i_input).name = 'COMPETENCY_SCORE' THEN
         l_inputs(i_input).value  := p_comp_asmt_score;
      ELSIF l_inputs(i_input).name = 'OBJECTIVE_SCORE' THEN
         l_inputs(i_input).value  := p_obj_asmt_score;
      ELSIF l_inputs(i_input).name = 'APPRAISAL_ID' THEN
         l_inputs(i_input).value  := l_appraisal_id;
      ELSIF l_inputs(i_input).name = 'APPR_TEMPLATE_ID' THEN
         l_inputs(i_input).value  := l_appraisal_temp_id;
      ELSIF l_inputs(i_input).name = 'APPR_SYSTEM_TYPE' THEN
         l_inputs(i_input).value  := l_appr_system_type;
      ELSIF l_inputs(i_input).name = 'APPR_TYPE' THEN
         l_inputs(i_input).value  := l_appr_type;
      ELSE
         raise e_wrong_parameters;
      END IF;

  END LOOP;
 END IF;

  --
  -- Run the FF.
  --
  ff_exec.run_formula(l_inputs, l_outputs);

  --
  -- Assign the outputs.
  --
  FOR i_output in l_outputs.first..l_outputs.last LOOP

      IF l_outputs(i_output).name = 'FINAL_RATING' THEN
        IF substr(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),1,1) = ',' then
            l_line_score := replace(l_outputs(i_output).value,'.',',');
        ELSE
            l_line_score := l_outputs(i_output).value;
        END IF;
      ELSE
        RAISE e_wrong_parameters;
      END IF;

  END LOOP;

  return l_line_score;

EXCEPTION

  WHEN e_wrong_parameters THEN
    --
    -- The inputs / outputs of the Fast Formula are incorrect
    -- so raise an error.
    --
    hr_utility.set_message(800,'HR_34964_BAD_FF_DEFINITION');
    hr_utility.raise_error;

  WHEN OTHERS THEN
    RAISE;

END;


function get_competence_score (p_competence_id NUMBER,
                               p_assessment_id NUMBER) return NUMBER IS
    cursor get_line_formula is
          select line_score_formula, line_score_formula_id from per_assessment_types, per_assessments
          where per_assessments.assessment_id = p_assessment_id
          and per_assessments.assessment_type_id = per_assessment_types.assessment_type_id;

    l_num_part NUMBER := 0;
    l_line_formula per_assessment_types.line_score_formula%type;
    l_line_formula_id per_assessment_types.line_score_formula_id%type;
    l_prof_value NUMBER;
    l_perf_value NUMBER;
    l_weigh_value NUMBER;
    l_tot_prof_value NUMBER default 0;
    l_tot_perf_value NUMBER default 0;
    l_tot_weigh_value NUMBER default 0;
    l_comp_ratings_table comp_ratings_table;
    i INTEGER DEFAULT 0;
    j INTEGER DEFAULT 0;
begin
 open get_line_formula;
 fetch get_line_formula into l_line_formula, l_line_formula_id;
 close get_line_formula;

 -- get competence_ratings
 OPEN get_competence_ratings(p_competence_id, p_assessment_id);
 FETCH get_competence_ratings BULK COLLECT INTO l_comp_ratings_table;
 CLOSE get_competence_ratings;

 IF (l_line_formula is not null) THEN
    return get_comp_line_score(l_line_formula, l_comp_ratings_table);
 ELSIF (l_line_formula_id is not null) THEN
    FOR i IN 1 ..l_comp_ratings_table.count LOOP
        j := j+1;
        l_tot_prof_value := l_tot_prof_value + nvl(l_comp_ratings_table(i).prof_value,0);
        l_tot_perf_value := l_tot_perf_value + nvl(l_comp_ratings_table(i).perf_value,0);
        l_tot_weigh_value := l_tot_weigh_value + nvl(l_comp_ratings_table(i).weigh_value,0);
    END LOOP;

    if(j = 0) then
      j := 1;
    end if;

    return get_ff_line_score(p_competence_id,
				  p_assessment_id,
                                  l_line_formula_id,
			          l_tot_prof_value/j,
                                  l_tot_perf_value/j,
	           	          l_tot_weigh_value/j);
 ELSE
    return 0;
 END IF;
end get_competence_score;

function get_objective_score (p_objective_id NUMBER,
                              p_appraisal_id NUMBER) return NUMBER IS
    cursor get_line_formula is
          select pat.line_score_formula,
	         pat.line_score_formula_id,
	         pas.assessment_id
	  from per_assessment_types pat,
	       per_assessments pas
          where pas.appraisal_id = p_appraisal_id
          and pas.assessment_type_id = pat.assessment_type_id
	  and pat.type = 'OBJECTIVE';

    l_num_part NUMBER := 0;
    l_line_formula per_assessment_types.line_score_formula%type;
    l_line_formula_id per_assessment_types.line_score_formula_id%type;
    l_assessment_id per_assessments.assessment_id%type;
    l_perf_value NUMBER;
    l_tot_prof_value NUMBER default 0;
    l_tot_perf_value NUMBER default 0;
    l_tot_weigh_value NUMBER default 0;
    l_obj_ratings_table obj_ratings_table;
    i INTEGER DEFAULT 0;
    j INTEGER DEFAULT 0;
begin
 open get_line_formula;
 fetch get_line_formula into l_line_formula, l_line_formula_id, l_assessment_id;
 close get_line_formula;

 -- get objective ratings
 OPEN get_objective_ratings(p_objective_id, l_assessment_id);
 FETCH get_objective_ratings BULK COLLECT INTO l_obj_ratings_table;
 CLOSE get_objective_ratings;

 -- loop thru and get total performance rating
 FOR i IN 1 ..l_obj_ratings_table.count LOOP
  j := j+1;
  l_tot_perf_value := l_tot_perf_value + nvl(l_obj_ratings_table(i).perf_value,0);
  l_tot_weigh_value := nvl(l_obj_ratings_table(i).weigh_percent,l_tot_weigh_value);
 END LOOP;

 IF(j = 0) THEN
    j := 1;
 END IF;

 IF (l_line_formula is not null) THEN
    return l_tot_perf_value/j;
 ELSIF (l_line_formula_id is not null) THEN
    return get_ff_line_score(p_objective_id,
		             l_assessment_id,
                             l_line_formula_id,
			     l_tot_prof_value/j,
                             l_tot_perf_value/j,
	           	     l_tot_weigh_value);
 ELSE
    return 0;
 END IF;
end get_objective_score;

function get_assessment_score (p_assessment_id NUMBER) return NUMBER IS
    cursor get_score_formula is
          select total_score_formula from per_assessment_types, per_assessments
          where per_assessments.assessment_id = p_assessment_id
          and per_assessments.assessment_type_id = per_assessment_types.assessment_type_id;
    cursor get_competences is
          select distinct pce.competence_id
          from per_competence_elements pce
          where pce.assessment_id = p_assessment_id and pce.type='ASSESSMENT'
          and pce.object_name = 'ASSESSOR_ID';
    cursor get_objectives is
          select po.objective_id
          from per_objectives po,
	       per_assessments pa
          where pa.assessment_id = p_assessment_id
          and po.appraisal_id = pa.appraisal_id;
    cursor get_asmnt_type is
          select nvl(pst.type, 'COMPETENCE'),
                 pa.appraisal_id
          from per_assessment_types pst,
	       per_assessments pa
          where pa.assessment_id = p_assessment_id
          and pst.assessment_type_id = pa.assessment_type_id;
    l_num_part NUMBER := 0;
    l_score_formula per_assessment_types.total_score_formula%type;
    l_total_score NUMBER := 0;
    l_competence_id NUMBER;
    l_objective_id NUMBER;
    l_asmnt_type per_assessment_types.type%type;
    l_appraisal_id per_appraisals.appraisal_id%type;
begin
 open get_score_formula;
 fetch get_score_formula into l_score_formula;
 close get_score_formula;

 -- get assessment type
 OPEN get_asmnt_type;
 FETCH get_asmnt_type INTO l_asmnt_type, l_appraisal_id;
 CLOSE get_asmnt_type;

 IF ('COMPETENCE' = l_asmnt_type) THEN
    open get_competences;
    loop
      fetch get_competences into l_competence_id;
      exit when get_competences%NOTFOUND;
      l_num_part := l_num_part + 1;
      l_total_score := l_total_score + get_competence_score(l_competence_id, p_assessment_id);
     end loop;
     close get_competences;
 ELSIF ('OBJECTIVE' = l_asmnt_type) THEN
    open get_objectives;
    loop
      fetch get_objectives into l_objective_id;
      exit when get_objectives%NOTFOUND;
      l_num_part := l_num_part + 1;
      l_total_score := l_total_score + get_objective_score(l_objective_id, l_appraisal_id);
     end loop;
     close get_objectives;
 END IF;

  if(l_num_part = 0) then
    l_num_part := 1;
  end if;

 if l_score_formula = 'TOTAL_LINES' then
    return l_total_score;
 elsif l_score_formula = 'AVERAGE_LINES' then
    return l_total_score / l_num_part;
 else
    return null;
 end if;
  return l_total_score;

end get_assessment_score;

function get_overall_score (p_appraisal_id NUMBER,
                            p_final_formula_id NUMBER) return NUMBER IS
    cursor get_assessments is
          select pa.assessment_id,
                 nvl(pst.type, 'COMPETENCE')
          from per_assessment_types pst,
	       per_assessments pa
          where pa.appraisal_id = p_appraisal_id
          and pst.assessment_type_id = pa.assessment_type_id;
    l_assessment_id per_assessments.assessment_id%type;
    l_comp_asmt_score NUMBER;
    l_obj_asmt_score NUMBER;
    l_asmnt_type per_assessment_types.type%type;
begin

    open get_assessments;
    loop
      fetch get_assessments into l_assessment_id, l_asmnt_type;
      exit when get_assessments%NOTFOUND;
      if ('COMPETENCE' = l_asmnt_type) then
       l_comp_asmt_score := get_assessment_score(l_assessment_id);
      elsif ('OBJECTIVE' = l_asmnt_type) then
       l_obj_asmt_score := get_assessment_score(l_assessment_id);
      end if;
    end loop;
    close get_assessments;

    if(l_assessment_id is not null) then
      return get_ff_overall_score(l_comp_asmt_score, l_obj_asmt_score,
                                p_final_formula_id, l_assessment_id);
    else
      return null;
    end if;

end get_overall_score;


procedure send_notification( p_fromPersonId VARCHAR2, p_toPersonId VARCHAR2,p_comment VARCHAR2,p_mainAprId VARCHAR2,p_actionType VARCHAR2) AS
      ln_notification_id           NUMBER;
      ln_MAnotification_id           NUMBER;

      CURSOR get_role (person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT wf.NAME role_name
           FROM wf_roles wf
          WHERE wf.orig_system = 'PER' AND wf.orig_system_id = person_id;

      CURSOR get_global_name (p_person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT NVL (GLOBAL_NAME, first_name || ', ' || last_name)
           FROM per_all_people_f
          WHERE person_id = p_person_id
            AND TRUNC (SYSDATE) BETWEEN effective_start_date AND effective_end_date;

      from_role                    wf_local_roles.NAME%TYPE                       DEFAULT NULL;
      to_role                    wf_local_roles.NAME%TYPE                       DEFAULT NULL;
      from_name                    per_all_people_f.GLOBAL_NAME%TYPE;
      appraisee_name                    per_all_people_f.GLOBAL_NAME%TYPE;
      msg_name varchar2(100);
BEGIN

      OPEN get_role (p_fromPersonId);
      FETCH get_role
       INTO from_role;
      CLOSE get_role;

      OPEN get_role (p_toPersonId);
      FETCH get_role
       INTO to_role;
      CLOSE get_role;

      OPEN get_global_name (p_fromPersonId);
      FETCH get_global_name
       INTO from_name;
      CLOSE get_global_name;




      IF p_actionType = 'MACHG' THEN
        msg_name := 'HR_APPRAISAL_MACHANGE_MSG';
      ELSIF p_actionType = 'HRSYSCOMPNOFEED' THEN
        msg_name := 'HR_APPRAISAL_COMPLETE_MSG';
      ELSIF p_actionType = 'HRSYSCOMPFEED' THEN
        msg_name := 'HR_APPRAISAL_FEEDBACK_MSG';
      END IF;

            ln_notification_id         :=
               wf_notification.send (ROLE              => to_role,
                                     msg_type          => 'HRSSA',
                                     msg_name          => msg_name,
                                     callback          => NULL,
                                     CONTEXT           => NULL,
                                     send_comment      => NULL,
                                     priority          => 50
                                    );

           wf_notification.setattrtext (ln_notification_id, '#FROM_ROLE', from_role);
           wf_notification.setattrtext (ln_notification_id, 'HRPROFNAME', from_name);
           wf_notification.setattrtext (ln_notification_id, 'APPROVAL_COMMENT', p_comment);

     IF msg_name = 'HR_APPRAISAL_MACHANGE_MSG' THEN
       msg_name := 'HR_APPRAISAL_MACHANGE_MGR_MSG';
     ELSIF  msg_name =  'HR_APPRAISAL_FEEDBACK_MSG' OR  msg_name = 'HR_APPRAISAL_COMPLETE_MSG' THEN
       msg_name := 'HR_APPRAISAL_COMP_MGR_MSG';
     END IF;

      OPEN get_role (p_mainAprId);
      FETCH get_role
       INTO to_role;
      CLOSE get_role;


      OPEN get_global_name (p_toPersonId);
      FETCH get_global_name
       INTO appraisee_name;
      CLOSE get_global_name;


          ln_MAnotification_id           :=
                 wf_notification.send (ROLE              => to_role,
                                     msg_type          => 'HRSSA',
                                     msg_name          => msg_name,
                                     callback          => NULL,
                                     CONTEXT           => NULL,
                                     send_comment      => NULL,
                                     priority          => 50
                                    );

           wf_notification.setattrtext (ln_MAnotification_id, '#FROM_ROLE', from_role);
           wf_notification.setattrtext (ln_MAnotification_id, 'HRPROFNAME', from_name);
           wf_notification.setattrtext (ln_MAnotification_id, 'APPROVAL_COMMENT', p_comment);
            wf_notification.setattrtext (ln_MAnotification_id, 'APPRAISEE', appraisee_name);


Exception
when others then
 raise;

END;

function is_maiappraiser_terminated(p_person_id varchar2) return varchar2 is
  cursor csr_wkr_status is
SELECT
  nvl(nvl(current_employee_flag
         ,current_npw_flag)
     ,'N')
FROM
  per_people_f
WHERE person_id = p_person_id
  AND sysdate BETWEEN effective_start_date AND effective_end_date;

  current_wkr_flag VARCHAR2(2);
begin
 open csr_wkr_status;
 fetch csr_wkr_status into current_wkr_flag;
 close csr_wkr_status;
 if current_wkr_flag='Y' then
  return 'N';
 else
  return 'Y';
 end if;

 Exception
  when others then
  return 'N';
end is_maiappraiser_terminated;


function is_worker_terminated(p_person_id varchar2) return varchar2 is
  cursor csr_wkr_status is
SELECT
  nvl(nvl(current_employee_flag
         ,current_npw_flag)
     ,'N')
FROM
  per_people_f
WHERE person_id = p_person_id
  AND sysdate BETWEEN effective_start_date AND effective_end_date;

  current_wkr_flag VARCHAR2(2);
begin
 open csr_wkr_status;
 fetch csr_wkr_status into current_wkr_flag;
 close csr_wkr_status;
 if current_wkr_flag='Y' then
  return 'N';
 else
  return 'Y';
 end if;
 Exception
  when others then
  return 'N';
end is_worker_terminated;

function is_approver_terminated(p_person_id varchar2) return varchar2 is
  cursor csr_wkr_status (p_approver_id in varchar2) is
SELECT
  nvl(nvl(current_employee_flag
         ,current_npw_flag)
     ,'N')
FROM
  per_people_f
WHERE person_id = p_approver_id
  AND sysdate BETWEEN effective_start_date AND effective_end_date;

  current_wkr_flag VARCHAR2(2);
  approverId VARCHAR2(20);
begin


 approverId := hr_approval_custom.get_next_approver (p_person_id);
 if approverId = null then
  return 'N';
 end if;
 open csr_wkr_status(approverId);
 fetch csr_wkr_status into current_wkr_flag;
 close csr_wkr_status;

if current_wkr_flag = 'Y' then
 return 'N';
else
 return 'Y';
end if;

 Exception
  when others then
  return 'N';

end is_approver_terminated;

function is_approver_terminated(p_item_type IN VARCHAR2,p_item_key IN VARCHAR2) return varchar2 is
  cursor csr_wkr_status (p_approver_id in varchar2) is
	SELECT
	  nvl(nvl(current_employee_flag
		 ,current_npw_flag)
	     ,'N')
	FROM
	  per_people_f
	WHERE person_id = p_approver_id
	  AND sysdate BETWEEN effective_start_date AND effective_end_date;

 cursor csr_approver_id ( p_role in varchar2 ) is
	 SELECT wf.orig_system_id from wf_roles wf
	 WHERE wf.orig_system = 'PER'
	 AND wf.name = p_role;

  current_wkr_flag VARCHAR2(2);
  approverId VARCHAR2(20);
  approverRole VARCHAR2(100);
begin
--Works Only for appraisals with pending approval does not work for other statuses
--When the appraisal is waiting for pending approval get to whom the appraisal forwarded and checks if the pprover terminatted
approverRole := wf_engine.GetItemAttrText(p_item_type,p_item_key,'FORWARD_TO_USERNAME',TRUE);

open csr_approver_id(approverRole);
fetch csr_approver_id into approverId;
 if csr_approver_id%notfound then
    return 'N';
 end if;
 close csr_approver_id;
 if approverId = null then
  return 'N';
 end if;

open csr_wkr_status(approverId);
fetch csr_wkr_status into current_wkr_flag;
if csr_wkr_status%notfound then
    hr_utility.set_location('Point 3.1  ', 1);
    return 'N';
end if;
close csr_wkr_status;


if current_wkr_flag = 'Y' then
 return 'N';
else
 return 'Y';
end if;

 Exception
  when others then
  return 'N';

end is_approver_terminated;


function get_item_key(p_appraisal_id VARCHAR2) return varchar2 is
l_itemkey varchar2(1000);
begin

select substr(system_params,instr(system_params,'pItemKey=')+9) into l_itemkey from per_appraisals where appraisal_id=p_appraisal_id;
return l_itemkey;

Exception
when others then
return '';
end;

end hr_appraisals_util_ss;

/
