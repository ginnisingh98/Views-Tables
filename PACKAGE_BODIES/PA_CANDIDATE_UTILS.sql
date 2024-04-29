--------------------------------------------------------
--  DDL for Package Body PA_CANDIDATE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CANDIDATE_UTILS" AS
-- $Header: PARCANUB.pls 120.5.12010000.2 2010/03/23 12:45:32 vgovvala ship $

/* --------------------------------------------------------------------
FUNCTION: Get_Active_Candidates_Number
PURPOSE:
-------------------------------------------------------------------- */
FUNCTION Get_Active_Candidates_Number(p_assignment_id IN NUMBER)
RETURN NUMBER
IS
l_no_of_active_candidates NUMBER := 0;
BEGIN
  SELECT no_of_active_candidates
  INTO l_no_of_active_candidates
  FROM pa_project_assignments
  WHERE assignment_id = p_assignment_id;

  IF l_no_of_active_candidates is null THEN
     RETURN 0;
  ELSE
     RETURN l_no_of_active_candidates;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END Get_Active_Candidates_Number;

/* --------------------------------------------------------------------
FUNCTION: Get_Requirements_Of_Candidate
PURPOSE:
-------------------------------------------------------------------- */
FUNCTION Get_Requirements_Of_Candidate(p_resource_id IN NUMBER)
RETURN requirements_tbl
IS
i NUMBER := 0;
l_candidate_req_table requirements_tbl;

BEGIN
  SELECT
  assignment_id
  BULK COLLECT INTO l_candidate_req_table
  FROM pa_candidates
  WHERE resource_id = p_resource_id;

  RETURN l_candidate_req_table;
EXCEPTION
     WHEN OTHERS THEN RAISE;

END Get_Requirements_Of_Candidate;


/* --------------------------------------------------------------------
FUNCTION: Get_Resource_Id
PURPOSE:
-------------------------------------------------------------------- */
FUNCTION Get_Resource_Id(p_person_id IN NUMBER)
RETURN NUMBER
IS
l_resource_id NUMBER := null;
BEGIN
  SELECT resource_id
  INTO l_resource_id
  FROM pa_resources_denorm
  WHERE person_id = p_person_id and rownum=1;

  RETURN l_resource_id;
EXCEPTION
   WHEN OTHERS THEN
      RETURN null;
END Get_Resource_Id;

/* --------------------------------------------------------------------
FUNCTION: Check_Resource_Is_Candidate
PURPOSE:  This API checks to see if the resource p_resource_id is a
          candidate on the assignment p_assignment_id.
          It returns 'Y', if the resource is a candidate.
          It returns 'N', if the resource is not a candidate.
-------------------------------------------------------------------- */
FUNCTION Check_Resource_Is_Candidate(p_resource_id   IN NUMBER,
                                     p_assignment_id IN NUMBER)
RETURN VARCHAR2
IS
l_exists VARCHAR2(1) := 'N';
BEGIN
  SELECT 'Y'
  into l_exists
  from pa_candidates
  where assignment_id = p_assignment_id
  and resource_id = p_resource_id;

  RETURN 'Y';

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END Check_Resource_Is_Candidate;

/* --------------------------------------------------------------------
PROCEDURE: Reverse_Candidate_Status
PURPOSE: This procedure will restore given candidate's status
         to PENDING_REVIEW. It is called when when the cancel button on
         page PA_SUBMIT_ASMT_APR_LAYOUT is clicked.
 -------------------------------------------------------------------- */

PROCEDURE Reverse_Candidate_Status
(p_assignment_id        IN NUMBER,
 p_resource_id          IN NUMBER,
 x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_error_message_code   OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_candidate_id          NUMBER;
l_candidate_ranking     NUMBER;
l_record_version_number NUMBER;
l_msg_count             NUMBER := 0;
l_project_status_code   VARCHAR2(30);
l_return_status         VARCHAR2(1);
l_msg_data              VARCHAR2(2000);

-- 4537865
l_new_record_version_number NUMBER;

l_candidate_in_rec	PA_RES_MANAGEMENT_AMG_PUB.CANDIDATE_IN_REC_TYPE;  -- Added for bug 8339510


BEGIN

 -- Initialize the Error Stack
 PA_DEBUG.init_err_stack('PA_CANDIDATE_PUB.Reverse_Candidate_Status');

 -- initialize return_status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 x_error_message_code := NULL;

 BEGIN
 SELECT candidate_id,
        candidate_ranking,
        record_version_number
 INTO   l_candidate_id,
        l_candidate_ranking,
        l_record_version_number
 FROM   pa_candidates
 WHERE  assignment_id = p_assignment_id
 AND    resource_id = p_resource_id;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        -- No candiddate record exist for given resource_id
        RETURN;
 END;

 SELECT project_status_code
 INTO   l_project_status_code
 FROM   PA_PROJECT_STATUSES
 WHERE  project_system_status_code = 'CANDIDATE_PENDING_REVIEW'
 AND  PREDEFINED_FLAG = 'Y'  -- Added for bug 5222893
 AND status_type = 'CANDIDATE';     -- Bug 4773033 CANDIDATE ROUTINES JOIN FOR PROJECT STATUSES

 PA_CANDIDATE_PUB.Update_Candidate
   (p_candidate_id               => l_candidate_id,
    p_status_code                => l_project_status_code,
    p_ranking                    => l_candidate_ranking,
    p_change_reason_code         => null,
    p_record_version_number      => l_record_version_number,
    -- Added for bug 8339510
    p_attribute_category    => l_candidate_in_rec.attribute_category,
    p_attribute1            => l_candidate_in_rec.attribute1,
    p_attribute2            => l_candidate_in_rec.attribute2,
    p_attribute3            => l_candidate_in_rec.attribute3,
    p_attribute4            => l_candidate_in_rec.attribute4,
    p_attribute5            => l_candidate_in_rec.attribute5,
    p_attribute6            => l_candidate_in_rec.attribute6,
    p_attribute7            => l_candidate_in_rec.attribute7,
    p_attribute8            => l_candidate_in_rec.attribute8,
    p_attribute9            => l_candidate_in_rec.attribute9,
    p_attribute10           => l_candidate_in_rec.attribute10,
    p_attribute11           => l_candidate_in_rec.attribute11,
    p_attribute12           => l_candidate_in_rec.attribute12,
    p_attribute13           => l_candidate_in_rec.attribute13,
    p_attribute14           => l_candidate_in_rec.attribute14,
    p_attribute15           => l_candidate_in_rec.attribute15,
    x_record_version_number      => l_new_record_version_number, -- 4537865 : Changed from l_record_version_number to new variable
    x_msg_count                  => l_msg_count,
    x_msg_data                   => l_msg_data,
    x_return_status              => l_return_status);

    -- 4537865 : Start
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	l_record_version_number := l_new_record_version_number ;
    END IF;
    -- End : 4537865
 IF(l_return_status =  FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
 ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := l_msg_data;

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_error_message_code := SQLCODE; -- 4537865
        RAISE;

END Reverse_Candidate_Status;


/* --------------------------------------------------------------------
FUNCTION: Get_Candidate_Score
PURPOSE:  This API calculates the candidate score of a resource.
          Expects p_resource_id, p_person_id, p_assignment_id
           and p_resource_job_level to be always passed in.
          It returns the Candidate Score.
-------------------------------------------------------------------- */
FUNCTION Get_Candidate_Score(p_resource_id               IN NUMBER,
                             p_person_id                 IN NUMBER,
                             p_assignment_id             IN NUMBER,
                             p_project_id                IN NUMBER,
                             p_competence_match_count    IN VARCHAR2,
                             p_competence_match          IN NUMBER,
                             p_competence_count          IN NUMBER,
                             p_availability              IN NUMBER,
                             p_resource_job_level        IN NUMBER,
                             p_min_job_level             IN NUMBER,
                             p_max_job_level             IN NUMBER,
                             p_comp_match_weighting      IN NUMBER,
                             p_avail_match_weighting     IN NUMBER,
                             p_job_level_match_weighting IN NUMBER)
RETURN NUMBER
IS

l_candidate_score    NUMBER := null;
l_competence_count   NUMBER := null;
l_competence_match   NUMBER := null;
l_availability       NUMBER := null;
l_min_job_level  NUMBER := null;
l_max_job_level  NUMBER := null;
l_comp_match_weighting  NUMBER := null;
l_avail_match_weighting NUMBER := null;
l_job_level_match_weighting  NUMBER := null;
l_comp_match_count  VARCHAR2(20) := null;
l_target_job_level  NUMBER := null;
l_job_level_match_denorm  NUMBER := null;
l_job_level_match   NUMBER := null;
l_total_weightings  NUMBER := 0;

CURSOR get_requirement_details IS
SELECT min_resource_job_level, max_resource_job_level, competence_match_weighting, availability_match_weighting, job_level_match_weighting
FROM   pa_project_assignments
WHERE  assignment_id = p_assignment_id;

BEGIN

  --get max min job levels and match weightings from the requirement
  --if any of these are not passed in
  IF (p_min_job_level IS NULL OR p_max_job_level IS NULL OR
      p_comp_match_weighting IS NULL OR p_avail_match_weighting IS NULL OR
      p_job_level_match_weighting IS NULL) THEN

    OPEN get_requirement_details;
    FETCH get_requirement_details into l_min_job_level, l_max_job_level, l_comp_match_weighting, l_avail_match_weighting, l_job_level_match_weighting;
    CLOSE get_requirement_details;

  END IF;

  --use the parameter values for job levels if they are passed in
  IF p_min_job_level IS NOT NULL AND p_max_job_level IS NOT NULL THEN
    l_min_job_level := p_min_job_level;
    l_max_job_level := p_max_job_level;
  END IF;

  --use the parameter values for match weightings if they are passed in
  IF p_comp_match_weighting IS NOT NULL AND
     p_avail_match_weighting IS NOT NULL AND
     p_job_level_match_weighting IS NOT NULL THEN
    l_comp_match_weighting := p_comp_match_weighting;
    l_avail_match_weighting := p_avail_match_weighting;
    l_job_level_match_weighting := p_job_level_match_weighting;
  END IF;

  -- return candidate score = 0 if the weightings add up to zero
  l_total_weightings := l_comp_match_weighting + l_avail_match_weighting + l_job_level_match_weighting;

  IF l_total_weightings = 0 THEN
    l_candidate_score := 0;
    RETURN l_candidate_score;
  END IF;

  --obtain competence match and count
  IF p_competence_count IS NULL OR p_competence_match IS NULL THEN

    IF p_competence_match_count IS NULL THEN
      l_comp_match_count := PA_CANDIDATE_PUB.Get_Competence_Match(p_person_id,
                                                              p_assignment_id);
    ELSE
      l_comp_match_count := p_competence_match_count;
    END IF;

    l_competence_match := TO_NUMBER(SUBSTR(l_comp_match_count, 1, INSTR(l_comp_match_count, '/') -1));
    l_competence_count := TO_NUMBER(SUBSTR(l_comp_match_count, INSTR(l_comp_match_count, '/')+1, LENGTH(l_comp_match_count)));

  ELSE
    l_competence_match := p_competence_match;
    l_competence_count := p_competence_count;
  END IF;

  IF l_competence_count = 0 THEN
    l_competence_count := 1;
  END IF;

  --obtain availability
  IF p_availability IS NULL THEN
    l_availability := nvl(PA_CANDIDATE_PUB.Check_Availability(p_resource_id,
                                                              p_assignment_id,
                                                              p_project_id),
                          0);

  ELSE
    l_availability := p_availability;
  END IF;

  -- Job Level Match is zero if resource does not have a job level
  IF p_resource_job_level IS NOT NULL THEN

    --calculate target Job Level
    l_target_job_level := (l_max_job_level + l_min_job_level)/2;

    --calculate the job level match value
    IF p_resource_job_level > l_max_job_level OR
       p_resource_job_level < l_min_job_level THEN
      l_job_level_match := 0;
    ELSE
      l_job_level_match := 100;
    END IF;

/*
    -- Temporarily give either 0 or 100 as job level match
    -- instead of calculating job level match using a formula
    -- due to open issue about HR job level ranges

    ELSIF p_resource_job_level = l_target_job_level THEN
      l_job_level_match := 100;
    ELSE
      --calculate the denominator of the job level match formula
      l_job_level_match_denorm := (l_max_job_level - l_target_job_level) * 1.01;

      l_job_level_match := (1- ABS(p_resource_job_level-l_target_job_level)/l_job_level_match_denorm) * 100;
    END IF;
*/

  ELSE
    l_job_level_match := 0;
  END IF;


  --calculate candidate score
  l_candidate_score := TRUNC( 100 * (
    (l_competence_match/l_competence_count * 100 * l_comp_match_weighting +
     l_availability * l_avail_match_weighting +
     l_job_level_match * l_job_level_match_weighting) /
    ((l_comp_match_weighting +
      l_avail_match_weighting +
      l_job_level_match_weighting) * 100)));

  RETURN l_candidate_score;
EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END  Get_Candidate_Score;

/* --------------------------------------------------------------------
FUNCTION: Get_Nominator_Name
PURPOSE:  This API returns nominator of the candidate
          Expects nominator's person Id
          It returns the name of the nominator.
-------------------------------------------------------------------- */

FUNCTION Get_Nominator_Name(p_nominated_by_person_id IN NUMBER)
RETURN VARCHAR2
IS
l_nominator_name    VARCHAR2(100) := null;
BEGIN

  IF p_nominated_by_person_id IS NULL THEN
     l_nominator_name := FND_MESSAGE.GET_STRING('PA', 'PA_AUTOMATED_SEARCH_PROCESS');
     /*
     SELECT message_text
     INTO   l_nominator_name
     FROM   fnd_new_messages
     WHERE  message_name = 'PA_AUTOMATED_SEARCH_PROCESS';
     */
  ELSE
     SELECT full_name
     INTO   l_nominator_name
     FROM   per_people_x
     WHERE  person_id = p_nominated_by_person_id;
  END IF;

  RETURN l_nominator_name;
EXCEPTION
   WHEN OTHERS THEN
      RETURN null;
END Get_Nominator_Name;

/* --------------------------------------------------------------------
FUNCTION: Get_Candidate_Nominations
PURPOSE:  This API returns how many times he/she has been
          nominated among all REQUIREMENTS.
-------------------------------------------------------------------- */
FUNCTION Get_Candidate_Nominations (p_resource_id IN NUMBER)
RETURN NUMBER
IS
l_num_nomination    NUMBER := 0;
BEGIN

  SELECT count(*)
  INTO   l_num_nomination
  FROM   pa_candidates can,
         pa_project_assignments asmt,
         pa_project_statuses ps
  WHERE  can.assignment_id = asmt.assignment_id
  AND    can.status_code = ps.project_status_code
  AND    can.resource_id = p_resource_id
  AND    asmt.assignment_type = 'OPEN_ASSIGNMENT'
  AND    ps.status_type = 'CANDIDATE'
  AND    ps.project_system_status_code IN ('CANDIDATE_PENDING_REVIEW',
                                           'CANDIDATE_UNDER_REVIEW',
                                           'CANDIDATE_SUITABLE',
                                           'CANDIDATE_SYSTEM_NOMINATED');

  RETURN l_num_nomination;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END Get_Candidate_Nominations;

/* --------------------------------------------------------------------
FUNCTION: Get_Candidate_Qualifieds
PURPOSE:  This API returns how many times he/she has been
          nominated as qualified assignment for REQUIREMENTS.
-------------------------------------------------------------------- */
FUNCTION Get_Candidate_Qualifieds (p_resource_id IN NUMBER)
RETURN NUMBER
IS
l_num_qualifieds    NUMBER := 0;
BEGIN

  SELECT count(*)
  INTO   l_num_qualifieds
  FROM   pa_candidates can,
         pa_project_assignments asmt,
         pa_project_statuses ps
  WHERE  can.assignment_id = asmt.assignment_id
  AND    can.status_code = ps.project_status_code
  AND    asmt.assignment_type = 'OPEN_ASSIGNMENT'
  AND    can.resource_id = p_resource_id
  AND    ps.status_type = 'CANDIDATE'
  AND    ps.project_system_status_code = 'CANDIDATE_SYSTEM_QUALIFIED';

  RETURN l_num_qualifieds;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END Get_Candidate_Qualifieds;

/* --------------------------------------------------------------------
FUNCTION: Update_No_Of_Active_Candidates
PURPOSE:  This API updates the no_of_active_candidates column in the
          pa_project_assignments table. It will be called when the user
          changes the duration for the requirements.
-------------------------------------------------------------------- */
PROCEDURE Update_No_Of_Active_Candidates (p_assignment_id IN NUMBER,
                                          x_return_status OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_no_of_active_candidates    NUMBER := 0;
l_record_version_number      NUMBER := 0;
l_return_status              VARCHAR2(1);
BEGIN

  PA_DEBUG.init_err_stack('PA_CANDIDATE_UTIL.Update_No_Of_Active_Candidates');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT count(*)
  INTO   l_no_of_active_candidates
  FROM   pa_candidates cand,
         pa_project_assignments asmt,
         pa_resources_denorm res,
         pa_project_statuses ps
  WHERE  cand.assignment_id = p_assignment_id
  AND    cand.assignment_id = asmt.assignment_id
  AND    cand.resource_id = res.resource_id
  AND    asmt.start_date BETWEEN res.resource_effective_start_date AND
                         NVL(res.resource_effective_end_date, asmt.start_date+1)
  AND    cand.status_code = ps.project_status_code
  AND    ps.status_type = 'CANDIDATE'
  AND    ps.project_system_status_code in ('CANDIDATE_PENDING_REVIEW',
                                           'CANDIDATE_UNDER_REVIEW',
                                           'CANDIDATE_SYSTEM_NOMINATED',
                                           'CANDIDATE_SUITABLE')
  AND    res.schedulable_flag = 'Y';

  SELECT record_version_number
  INTO   l_record_version_number
  FROM   pa_project_assignments
  WHERE  assignment_id = p_assignment_id;

  pa_project_assignments_pkg.Update_row(
                             p_assignment_id           => p_assignment_id,
                             p_no_of_active_candidates => l_no_of_active_candidates,
                             p_record_version_number   => l_record_version_number,
                             x_return_status           => l_return_status );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_msg_pub.add_exc_msg
                (p_pkg_name       => 'PA_CANDIDATE_UTIL',
                 p_procedure_name => 'Update_No_Of_Active_Candidates' );

RAISE;
END Update_No_Of_Active_Candidates;

END PA_CANDIDATE_UTILS ;


/
