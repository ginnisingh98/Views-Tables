--------------------------------------------------------
--  DDL for Package Body PA_CANDIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CANDIDATE_PUB" AS
-- $Header: PARCANPB.pls 120.8.12010000.11 2010/03/31 10:15:40 nisinha ship $

FUNCTION Get_Person_Id
RETURN NUMBER;

FUNCTION Get_Resource_Name(p_resource_id in NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Number_Of_Candidates(p_project_status_code IN VARCHAR2)
RETURN NUMBER
IS
l_no_of_candidates  NUMBER := 0;
BEGIN
  SELECT count(*)
  into l_no_of_candidates
  FROM pa_candidates
  where assignment_id = g_assignment_id
  AND status_code = p_project_status_code;

  RETURN l_no_of_candidates;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END;

FUNCTION Get_Number_Of_Candidates(p_assignment_id IN NUMBER)
RETURN NUMBER
IS
l_no_of_candidates  NUMBER := 0;
BEGIN
  SELECT count(*)
  into l_no_of_candidates
  FROM pa_candidates
  where assignment_id = g_assignment_id
  and status_code in ('UNDER_REVIEW','SUITABLE');

  RETURN l_no_of_candidates;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END;

FUNCTION Resource_Is_Candidate(p_resource_id   IN NUMBER,
                               p_assignment_id IN NUMBER)
RETURN VARCHAR2
IS
l_exists VARCHAR2(1) := 'N';
BEGIN
  SELECT 'Y'
  into l_exists
  FROM pa_candidates
  WHERE resource_id=p_resource_id
  AND assignment_id = p_assignment_id;

  RETURN 'Y';
EXCEPTION
  WHEN OTHERS THEN
      RETURN 'N';
END;

/* --------------------------------------------------------------------
FUNCTION: IS_CAND_ON_ANOTHER_ASSIGNMENT
PURPOSE:  This function is called from the view PA_CANDIDATE_DETAILS_V
          on which the Candidate list page is based.
          This page displays the candidates for a given assignment
          (p_assignment_id). If the candidate is also a candidate on
          another assignment, or if the candidate is provisionally
          assigned on another assignment,  then an indicator by the
          candidate number will indicate this.
          The view has the attribute CAND_ON_ANOTHER_ASSIGNMENT, whose
          value is based on the value returned by this function.
-------------------------------------------------------------------- */
FUNCTION IS_CAND_ON_ANOTHER_ASSIGNMENT
(p_resource_id           IN NUMBER,
 p_assignment_id         IN NUMBER,
 p_assignment_start_date IN DATE,
 p_assignment_end_date   IN DATE)
RETURN VARCHAR2
IS
l_exists VARCHAR2(1) := 'N';
BEGIN
  BEGIN
  --Bug 8295734: For active candidate project_system_status_code should not be CANDIDATE_ASSIGNED
    SELECT 'Y'
    INTO l_exists
    FROM pa_candidates pc,
         pa_project_statuses pps
    WHERE pc.resource_id = p_resource_id
    AND   pc.assignment_id <> p_assignment_id
    AND   pc.status_code = pps.project_status_code
    AND   pps.project_system_status_code not in ('CANDIDATE_DECLINED','CANDIDATE_WITHDRAWN','CANDIDATE_ASSIGNED')
    AND ROWNUM = 1;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         null;
  END;

  IF l_exists = 'Y' THEN
     RETURN 'Y';
  END IF;

  SELECT 'Y'
  INTO l_exists
  FROM PA_PROJECT_ASSIGNMENTS
  WHERE resource_id = p_resource_id
  AND assignment_id <> p_assignment_id
  AND nvl(start_date,sysdate) <= nvl(p_assignment_end_date,sysdate)
  AND nvl(end_date,sysdate) >= nvl(p_assignment_start_date,sysdate)
  AND ROWNUM = 1;

  RETURN 'Y';
EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';
END;

/* --------------------------------------------------------------------
FUNCTION: IS_CAND_ON_ASSIGNMENT
PURPOSE:  This function checks to see if the resource is a candidate
          on the assigment p_assignment_id. It yes, it returns a 'Y'.
          This function is called from the client side, by the Resource
          Requirement Search Page. The Resource Requirement Search
          Page checks is a page which displays the results for requirements
          done for a particular resource. If the resource is already a
          candidate on the requirement, then an indicator by the candidate
          number will indicate it.
          Return value = 'Y', means candidate already on assignment, nothing
          will be done to this candidate.
          Return value = 'N', means candidate not on assignment so it
          will be created as a new candidate.
          Return value = 'U', means candidate on assignment but his/her
          status will be updated.
-------------------------------------------------------------------- */
FUNCTION IS_CAND_ON_ASSIGNMENT(p_resource_id   IN NUMBER,
                               p_assignment_id IN NUMBER,
                               p_status_code   IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
l_exists VARCHAR2(1) := 'Y';
l_old_project_system_status VARCHAR2(30);
l_new_project_system_status VARCHAR2(30);
BEGIN
  IF p_status_code IS NULL THEN
     SELECT 'Y'
     INTO l_exists
     FROM pa_candidates
     WHERE resource_id = p_resource_id
     AND assignment_id = p_assignment_id;
  ELSE
     SELECT project_system_status_code
     INTO l_old_project_system_status
     FROM pa_candidates, pa_project_statuses
     WHERE resource_id = p_resource_id
     AND assignment_id = p_assignment_id
     AND status_code = project_status_code
     AND status_type = 'CANDIDATE';

     SELECT project_system_status_code
     INTO l_new_project_system_status
     FROM pa_project_statuses
     WHERE project_status_code = p_status_code
     AND status_type = 'CANDIDATE';

     IF l_old_project_system_status = 'CANDIDATE_SYSTEM_QUALIFIED' AND
        l_new_project_system_status <> 'CANDIDATE_SYSTEM_QUALIFIED' THEN
        RETURN 'U';
     END IF;
  END IF;

  RETURN 'Y';

EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';
END IS_CAND_ON_ASSIGNMENT;


/* --------------------------------------------------------------------
PROCEDURE: Add_Candidate
PURPOSE: This procedure will add p_resource_id as the candidate on
         p_assigment_id. p_nomination_comments are the comments
         by the nominator to add this resource on the assignment.
         This procedure will error out if:
         1. The resource is already a candidate on the assignment
         This procedure will give an unexpected error if:
         1. Resource_Id or Assignment_Id are not valid.

         09-May-2001
         p_privilege_name and p_project_super_user IN parameters are
         added, p_privilege name is one key input for checking
         whether user has resource authority over nominee while
         p_project_super_user indicates whether user has project
         super user resp.
 -------------------------------------------------------------------- */
PROCEDURE Add_Candidate
(p_assignment_id                IN  NUMBER,
 p_resource_name                IN  VARCHAR2,
 p_resource_id                  IN  NUMBER DEFAULT NULL,
 p_status_code                  IN  VARCHAR2 DEFAULT NULL,
 p_nomination_comments          IN  VARCHAR2,
 p_person_id                    IN  NUMBER DEFAULT NULL,
 p_privilege_name               IN  VARCHAR2 DEFAULT NULL,
 p_project_super_user           IN  VARCHAR2 DEFAULT 'N',
 p_init_msg_list		IN  VARCHAR2 DEFAULT FND_API.G_TRUE,  -- Added for Bug 5130421: PJR Enhancements for Public APIs
 -- Added for bug 9187892
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE,
 x_return_status                OUT NOCOPY VARCHAR2, -- 4537865
 x_msg_count                    OUT NOCOPY NUMBER, -- 4537865
 x_msg_data                     OUT NOCOPY VARCHAR2) -- 4537865
IS

l_exists                        VARCHAR2(1);
l_nominated_by_person_id        NUMBER;
l_candidate_id                  NUMBER;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(500);
l_msg_index_out                 NUMBER := 0;
l_resource_id                   NUMBER := 0;
l_status_code                   VARCHAR2(30);
l_system_status_code            VARCHAR2(30);
l_status_name                   VARCHAR2(80);
l_res_id_name_match             BOOLEAN := FALSE;
l_person_id                     NUMBER;
l_ret_code                      VARCHAR2(1);
l_asmt_start_date               DATE;
l_resource_type_id              NUMBER;
l_is_cand_on_asmt               VARCHAR2(1) := 'N';
l_fnd_user_id                   NUMBER;
l_enable_wf_flag                VARCHAR2(1);
l_wf_item_type                  VARCHAR2(30);
l_wf_process                    VARCHAR2(30);
l_check_id_flag                 VARCHAR2(1);


BEGIN
 -- Initialize the Error Stack
 PA_DEBUG.init_err_stack('PA_CANDIDATE_PUB.Add_Candidate');

 -- initialize return_status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Clear the global PL/SQL message table. Added check of p_init_msg_list Bug 5130421: PJR Enhancements for Public APIs
 IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
    FND_MSG_PUB.initialize;
 END IF;


  -- Check if assignment Id is valid
  BEGIN
    SELECT start_date
    INTO l_asmt_start_date
    FROM pa_project_assignments
    WHERE assignment_id=p_assignment_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         pa_utils.add_message
               (p_app_short_name  => 'PA',
                p_msg_name        => 'PA_XC_RECORD_CHANGED');
         RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  IF p_resource_id IS NULL THEN
     -- Check whether the pass-in person_id and person_name match


/* Bug  2843613 */

    l_check_id_flag := PA_STARTUP.G_Check_ID_Flag;
    IF PA_STARTUP.G_Calling_Application = 'SELF_SERVICE' THEN
      PA_STARTUP.G_Check_ID_Flag := 'N';
    END IF;

/* Bug  2843613 */


     pa_resource_utils.Check_ResourceName_Or_Id
                       (p_resource_id           => p_person_id,   -- p_resource_id input parameter is actually person_id
                        p_resource_name         => p_resource_name,
                        p_date                  => l_asmt_start_date,
                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag, /*changed to G_Check_ID_Flag from A*/
                        x_resource_id           => l_person_id,
                        x_resource_type_id      => l_resource_type_id,
                        x_return_status         => l_return_status,
                        x_error_message_code    => l_msg_data);

     PA_STARTUP.G_Check_ID_Flag := l_check_id_flag;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_msg_data );
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     PA_R_PROJECT_RESOURCES_PUB.create_resource
                (p_api_version        => 1.0,
                 p_init_msg_list      => fnd_api.g_false,
                 --p_commit           => p_commit,
                 --p_validate_only    => p_validate_only,
                 p_person_id          => l_person_id,
                 p_individual         => 'Y',
                 p_resource_type      => 'EMPLOYEE',
                 p_check_resource     => 'Y',
                 x_return_status      => l_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 x_resource_id        => l_resource_id);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     PA_RESOURCE_UTILS.Validate_Person
                (p_person_id      => l_person_id
                ,p_start_date     => l_asmt_start_date
                ,x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- If calling page is nominate candidate, we need to check whether the user has
     -- resource authority over nominee
     IF p_project_super_user = 'N'
        AND (p_privilege_name = 'PA_NOMINATE_CANDIDATES'
        OR p_privilege_name = 'PA_NOMINATE_SELF_AS_CANDIDATE') THEN

        pa_security_pvt.check_confirm_asmt(p_project_id      => -999,
                                           p_resource_id     => l_resource_id,
                                           p_resource_name   => p_resource_name,
                                           p_privilege       => p_privilege_name,
                                           p_start_date      => l_asmt_start_date,
                                           x_ret_code        => l_ret_code,
                                           x_return_status   => x_return_status,
                                           x_msg_count       => x_msg_count,
                                           x_msg_data        => x_msg_data);

        IF l_ret_code = FND_API.G_FALSE THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_NO_RESOURCE_AUTHORITY' );
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     l_nominated_by_person_id := Get_Person_Id;
     l_fnd_user_id := FND_GLOBAL.USER_ID;
  ELSE
     l_resource_id := p_resource_id;
     l_nominated_by_person_id := null;
     l_status_code := p_status_code;
     l_fnd_user_id := -1;
  END IF;

  -- Check if candidate Status is passed. If not, get the value from
  -- the profile
  IF p_status_code is null THEN
     SELECT fnd_profile.value('PA_DEF_START_CAND_STATUS')
     INTO l_status_code
     FROM dual;
  ELSE
     l_status_code := p_status_code;
  END IF;

  -- Return Status 'S' and return the name to the calling page if
  -- candidate are already in an assignment
  l_is_cand_on_asmt := IS_CAND_ON_ASSIGNMENT(l_resource_id,p_assignment_id, l_status_code);

  IF l_is_cand_on_asmt = 'Y' THEN
     x_msg_count := x_msg_count + 1;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_data := p_resource_name;
     RETURN;
  END IF;

  IF l_status_code is null THEN
     pa_utils.add_message
              (p_app_short_name  => 'PA',
               p_msg_name        => 'PA_CAND_STATUS_REQD');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     SELECT project_system_status_code
     INTO l_system_status_code
     FROM pa_project_statuses
     WHERE project_status_code = l_status_code;
  END IF;

  IF l_is_cand_on_asmt = 'N' THEN
     -- Insert into the candidate table.
     INSERT INTO PA_CANDIDATES
         (CANDIDATE_ID,
          ASSIGNMENT_ID,
          RESOURCE_ID,
          RECORD_VERSION_NUMBER,
          STATUS_CODE,
          NOMINATED_BY_PERSON_ID,
          NOMINATION_DATE,
          NOMINATION_COMMENTS,
          CANDIDATE_RANKING,
          CREATION_DATE,
          -- Added for bug 9187892
	  ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY)
      VALUES
         (PA_CANDIDATES_S.nextval,
          p_ASSIGNMENT_ID,
          l_RESOURCE_ID,
          1,
          l_status_code,
          l_nominated_by_person_id,
          sysdate,
          p_nomination_comments,
          null,
          SYSDATE,
	  -- Added for bug 9187892
     	  p_attribute_category,
          p_attribute1,
          p_attribute2,
          p_attribute3,
          p_attribute4,
          p_attribute5,
          p_attribute6,
          p_attribute7,
          p_attribute8,
          p_attribute9,
          p_attribute10,
          p_attribute11,
          p_attribute12,
          p_attribute13,
          p_attribute14,
          p_attribute15,
          l_fnd_user_id,
          SYSDATE,
          l_fnd_user_id)
      RETURNING
          CANDIDATE_ID into l_candidate_id;
  ELSE
      UPDATE PA_CANDIDATES
      SET STATUS_CODE = l_status_code,
          NOMINATION_COMMENTS = p_nomination_comments,
          RECORD_VERSION_NUMBER = record_version_number + 1,
          NOMINATED_BY_PERSON_ID = l_nominated_by_person_id,
          NOMINATION_DATE = SYSDATE,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = l_fnd_user_id
      WHERE assignment_id = p_assignment_id
      AND   resource_id = l_resource_id;
  END IF;

  SELECT ENABLE_WF_FLAG, WORKFLOW_ITEM_TYPE, WORKFLOW_PROCESS, PROJECT_STATUS_NAME
  INTO   l_enable_wf_flag, l_wf_item_type, l_wf_process, l_status_name
  FROM   PA_PROJECT_STATUSES
  WHERE  status_type = 'CANDIDATE'
  AND    project_status_code = l_status_code;

  --dbms_output.put_line ( 'l_enable_wf_flag  ' || l_enable_wf_flag );
  --dbms_output.put_line ( 'l_system_status_code  ' || l_system_status_code);

  IF l_enable_wf_flag = 'Y' AND l_wf_item_type IS NOT NULL AND
     l_wf_process IS NOT NULL THEN

     Start_Workflow(p_wf_item_type         => l_wf_item_type,
                    p_wf_process           => l_wf_process,
                    p_assignment_id        => p_assignment_id,
                    p_candidate_number     => l_candidate_id,
                    p_resource_id          => l_resource_id,
                    p_status_name          => l_status_name,
                    x_return_status        => l_return_status,
                    x_msg_count            => l_msg_count,
                    x_msg_data             => l_msg_data);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;


  -- Update No_Of_Active_Candidates in PA_PROJECT_ASSIGNMENTS
  Update_No_Of_Active_Candidates(
     p_assignment_id            => p_assignment_id,
     p_old_system_status_code   => NULL,
     p_new_system_status_code   => l_system_status_code,
     x_return_status            => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := FND_MSG_PUB.Count_Msg;

    IF x_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
      (p_encoded       => FND_API.G_TRUE,
       p_msg_index      => 1,
       p_msg_count      => 1 ,
       p_msg_data       => l_msg_data ,
       p_data           => x_msg_data,
       p_msg_index_out  => l_msg_index_out );
    END IF;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    fnd_msg_pub.add_exc_msg
        (p_pkg_name       => 'PA_CANDIDATE_PUB',
         p_procedure_name => 'Add_Candidate' );

    x_msg_count := FND_MSG_PUB.Count_Msg;

    IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => 1,
              p_msg_data       => l_msg_data ,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
    END IF;
    RAISE;

END Add_Candidate;



/* --------------------------------------------------------------------
 PROCEDURE: update_no_of_active_candidates
 PURPOSE: This procedure will update no_of_active_candidates column of
          pa_project_assignments by calling from other procedures which
          update candidate status like Add_Candidate, Add_Candidate_Log,
          Update_Candidate.
 -------------------------------------------------------------------- */
PROCEDURE Update_No_Of_Active_Candidates(
         p_assignment_id            IN NUMBER,
         p_old_system_status_code   IN VARCHAR2,
         p_new_system_status_code   IN VARCHAR2,
         x_return_status            OUT NOCOPY VARCHAR2 ) -- 4537865
IS
 l_no_of_active_candidates      NUMBER;
 l_record_version_number        NUMBER;
 l_return_status                VARCHAR2(1);
BEGIN
 -- initialize return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- get original no_of_active_candidates and record_version_number for the passed assignment_id
 SELECT no_of_active_candidates, record_version_number
 INTO l_no_of_active_candidates, l_record_version_number
 FROM pa_project_assignments
 WHERE assignment_id = p_assignment_id;

 -- if original no_of_active_candidates is null, set to 0 so that we can increase or
 -- decrease the value with ease.
 IF (l_no_of_active_candidates is NULL) THEN
     l_no_of_active_candidates := 0;
 END IF;

 -- if this has been called from 'Add_Candidate', p_old_system_status_code won't be passed.
 -- In that case, just check if the new_system_status_code is one of the active status.
 -- If so, increase the value of no_of_active_candidates in pa_project_assignments table.
 IF (p_old_system_status_code IS NULL AND is_active_candidate(p_new_system_status_code)='Y') THEN
     pa_project_assignments_pkg.Update_row(
                 p_assignment_id           => p_assignment_id,
                 p_no_of_active_candidates => l_no_of_active_candidates+1,
                 p_record_version_number   => l_record_version_number,
                 x_return_status           => l_return_status );

 -- if this has been called from either 'Add_Candidate_Log' or 'Update_Candidate', check
 -- if the new_status_code is differenct as an old one.
 ELSIF (p_old_system_status_code IS NOT NULL AND p_old_system_status_code <> p_new_system_status_code) THEN

     -- If the status has been changed from active to non-active, decrement no_of_active_candidates
     IF (is_active_candidate(p_old_system_status_code)='Y'
         AND is_active_candidate(p_new_system_status_code)='N') THEN
     pa_project_assignments_pkg.Update_row(
                 p_assignment_id           => p_assignment_id,
                 p_no_of_active_candidates => l_no_of_active_candidates-1,
                 p_record_version_number   => l_record_version_number,
                 x_return_status       => l_return_status );

     -- If the status has been changed from non-active to active, increment no_of_active_candidates
     ELSIF (is_active_candidate(p_old_system_status_code)='N'
            AND is_active_candidate(p_new_system_status_code)='Y') THEN
     pa_project_assignments_pkg.Update_row(
                 p_assignment_id           => p_assignment_id,
                 p_no_of_active_candidates => l_no_of_active_candidates+1,
                 p_record_version_number   => l_record_version_number,
                 x_return_status                 => l_return_status );
     END IF;

 END IF;

	-- 4537865 : Assigning l_return_status to x_return_status was missing
	x_return_status := l_return_status ;

 EXCEPTION
    -- catch the exceptins here
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
    FND_MSG_PUB.add_exc_msg(
             p_pkg_name       => 'PA_CANDIDATE_PUB',
             p_procedure_name => 'Update_No_Of_Active_Candidates');

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Update_No_Of_Active_Candidates;



/* --------------------------------------------------------------------
PROCEDURE: Update_Remaining_Candidates
PURPOSE: This procedure will update all the candidates (except p_resource_id)
         on the assignment p_assignment_id to status p_status_code.
         Currently, the only acceptable status value for p_status_code is DECLINED.
         This API is called from the assignment page, when an resource is assigned
         to an assignment. The page has a region "Candidates", where the user
         can select to update the status of remaing candidates to DECLINED.
 -------------------------------------------------------------------- */
PROCEDURE Update_Remaining_Candidates
(p_assignment_id        IN  NUMBER,
 p_resource_id          IN  NUMBER,
 p_status_code          IN  VARCHAR2,
 p_change_reason_code   IN  VARCHAR2,
 p_init_msg_list        IN  VARCHAR2  := FND_API.G_FALSE,
 -- Added for bug 9187892
    -- start for bug#9468526 , Added default null values
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE :=NULL ,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE :=NULL ,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE :=NULL ,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE :=NULL ,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE :=NULL ,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE :=NULL ,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE :=NULL ,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE :=NULL ,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE :=NULL ,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE :=NULL ,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE :=NULL ,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE :=NULL ,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE :=NULL ,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE :=NULL ,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE :=NULL ,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE :=NULL ,
   -- start for bug#9468526 , Added default null values
 x_return_status        OUT NOCOPY VARCHAR2, -- 4537865 : Added nocopy hint
 x_msg_data             OUT NOCOPY VARCHAR2, -- 4537865 : Added nocopy hint
 x_msg_count            OUT NOCOPY NUMBER)   -- 4537865 : Added nocopy hint
IS

cursor remain_candidates_csr is
   SELECT candidate_id, resource_id, record_version_number,
          candidate_ranking, status_code
   FROM pa_candidates
   WHERE assignment_id = p_assignment_id
   and resource_id <> p_resource_id;

cursor assigned_candidate_csr is
   SELECT status_code
   FROM pa_candidates
   WHERE assignment_id = p_assignment_id
   and resource_id = p_resource_id;

l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(500);
l_msg_index_out                 NUMBER := 0;
l_exists                        VARCHAR2(1);
l_record_version_number         NUMBER;
l_cand_record_version_number    NUMBER;
l_asgned_record_version_number  NUMBER;
l_asgned_candidate_id           NUMBER;
l_candidate_ranking             NUMBER;
l_project_status_code           VARCHAR2(30);
l_project_system_status_code    VARCHAR2(30);
l_old_system_status_code        VARCHAR2(30);

BEGIN
 -- Initialize the Error Stack
 PA_DEBUG.init_err_stack('PA_CANDIDATE_PUB.Update_Remaining_Candidates');

 -- initialize return_status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Check if p_status_code is DECLINED only if the passed status_code, which is for the remaining
  -- candidates, is not null
  IF p_status_code IS NOT NULL THEN
     BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM PA_PROJECT_STATUSES
        WHERE project_status_code = p_status_code
        AND project_system_status_code = 'CANDIDATE_DECLINED';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           -- Message to indicate that only status with Declined sytem status
           -- is acceptable
           pa_utils.add_message
               (p_app_short_name  => 'PA',
                p_msg_name        => 'PA_STS_NOT_VALID');

           RAISE FND_API.G_EXC_ERROR;
     END;
  END IF;

  BEGIN
    -- get information of the assigned person from pa_candidates
    -- if the passed resource is not one of the candidates,
    -- it won't update anything for the assigned person.

    SELECT candidate_id,
           record_version_number,
           candidate_ranking
    INTO l_asgned_candidate_id,
         l_asgned_record_version_number,
         l_candidate_ranking
    FROM pa_candidates
    WHERE assignment_id = p_assignment_id
    AND   resource_id = p_resource_id;

    BEGIN
      -- Get project_status_code for system_status_code CANDIADTE_ASSIGNED.

      SELECT project_status_code
      INTO l_project_status_code
      FROM PA_PROJECT_STATUSES
      WHERE project_system_status_code = 'CANDIDATE_ASSIGNED'
      AND status_type = 'CANDIDATE';  -- Bug 4773033 CANDIDATE ROUTINES JOIN FOR PROJECT STATUSES
--      AND ROWNUM=1;

      -- Update the record for the assigned candidate
      Update_Candidate
        (p_candidate_id               => l_asgned_candidate_id,
     p_status_code                => l_project_status_code,
     p_ranking                    => l_candidate_ranking,
     p_change_reason_code         => null,
     p_record_version_number      => l_asgned_record_version_number,
         p_init_msg_list              => p_init_msg_list,
     x_record_version_number      => l_cand_record_version_number,
  -- Added for bug 9187892
     p_attribute_category    => p_attribute_category,
     p_attribute1            => p_attribute1,
     p_attribute2            => p_attribute2,
     p_attribute3            => p_attribute3,
     p_attribute4            => p_attribute4,
     p_attribute5            => p_attribute5,
     p_attribute6            => p_attribute6,
     p_attribute7            => p_attribute7,
     p_attribute8            => p_attribute8,
     p_attribute9            => p_attribute9,
     p_attribute10           => p_attribute10,
     p_attribute11           => p_attribute11,
     p_attribute12           => p_attribute12,
     p_attribute13           => p_attribute13,
     p_attribute14           => p_attribute14,
     p_attribute15           => p_attribute15,
     x_msg_count                  => l_msg_count,
     x_msg_data                   => l_msg_data,
     x_return_status              => l_return_status);

      IF(l_return_status =  FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      EXCEPTION
         -- if there is no project_status_code for ASSIGN
     WHEN NO_DATA_FOUND THEN
            pa_utils.add_message
               (p_app_short_name  => 'PA',
                    p_msg_name        => 'PA_NO_ASSIGN_STATUS');

            RAISE FND_API.G_EXC_ERROR;
    END;

    EXCEPTION
       -- if the assigned person is not one of the candidates,
       -- don't do anything for the assigned person.
       WHEN NO_DATA_FOUND THEN
         null;
  END;


  -- For the remaing candiates, update the status in pa_candidates
  -- and create a record in review comments table for the changed status.
  -- only if the passed status_code, which is for the remaining
  -- candidates, is not null

  IF p_status_code IS NOT NULL THEN

     FOR c2 in remain_candidates_csr LOOP
        -- Get the original project_system_status_code for remaining candidates.
        SELECT project_system_status_code
        INTO l_project_system_status_code
        FROM PA_PROJECT_STATUSES
        WHERE project_status_code = c2.status_code;

        -- Update records only for the remaining active candidate.
        IF(Is_Active_Candidate(l_project_system_status_code)='Y') THEN

           Update_Candidate
            (p_candidate_id               => c2.candidate_id,
             p_status_code                => p_status_code,
         p_ranking                    => c2.candidate_ranking,
         p_change_reason_code         => p_change_reason_code,
         p_record_version_number      => c2.record_version_number,
             p_init_msg_list              => p_init_msg_list,
         x_record_version_number      => l_cand_record_version_number,
         -- Added for bug 9187892
         p_attribute_category    => p_attribute_category,
         p_attribute1            => p_attribute1,
         p_attribute2            => p_attribute2,
         p_attribute3            => p_attribute3,
         p_attribute4            => p_attribute4,
         p_attribute5            => p_attribute5,
         p_attribute6            => p_attribute6,
         p_attribute7            => p_attribute7,
         p_attribute8            => p_attribute8,
         p_attribute9            => p_attribute9,
         p_attribute10           => p_attribute10,
         p_attribute11           => p_attribute11,
         p_attribute12           => p_attribute12,
         p_attribute13           => p_attribute13,
         p_attribute14           => p_attribute14,
         p_attribute15           => p_attribute15,
         x_msg_count                  => l_msg_count,
         x_msg_data                   => l_msg_data,
         x_return_status              => l_return_status);

           IF(l_return_status =  FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;

     END LOOP;

     -- Get original record_version_number of pa_project_assignments
     -- for the passed assignment_id
     SELECT record_version_number
     INTO l_record_version_number
     FROM pa_project_assignments
     WHERE assignment_id = p_assignment_id;

     -- Since there are no more active candidates, update the
     -- No_Of_Active_Candidate in pa_project_assignments to 0
     -- for assignment p_assignment_id

     pa_project_assignments_pkg.Update_row(
    p_assignment_id           => p_assignment_id,
    p_no_of_active_candidates => 0,
    p_record_version_number   => l_record_version_number,
    x_return_status           => l_return_status );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

  ELSIF p_status_code IS NULL THEN

     -- Get the original project_system_status_code for the assigned candidate.
     SELECT ps.project_system_status_code
     INTO l_old_system_status_code
     FROM pa_candidates cand, pa_project_statuses ps
     WHERE cand.assignment_id = p_assignment_id
        AND cand.resource_id = p_resource_id
        AND ps.project_status_code = cand.status_code;

      -- Update No_Of_Active_Candidates in PA_PROJECT_ASSIGNMENTS
      Update_No_Of_Active_Candidates(
             p_assignment_id            => p_assignment_id,
             p_old_system_status_code   => l_old_system_status_code,
             p_new_system_status_code   => 'CANDIDATE_ASSIGNED',
             x_return_status            => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END IF;


 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;

    IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages(
                p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => 1 ,
                p_msg_data       => l_msg_data ,
                p_data           => x_msg_data,
                p_msg_index_out  => l_msg_index_out );
    END IF;

     WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_msg_count := 0; -- 4537865
	x_msg_data := NULL ; -- 4537865

     WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    fnd_msg_pub.add_exc_msg(
         p_pkg_name        => 'PA_COMPETENCE_PUB',
         p_procedure_name  => 'Update_Remaining_Candidates' );
        x_msg_count := FND_MSG_PUB.Count_Msg;

        IF x_msg_count = 1 THEN

           pa_interface_utils_pub.get_messages(
             p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => 1,
             p_msg_data       => l_msg_data,
             p_data           => x_msg_data,
             p_msg_index_out  => l_msg_index_out );
        END IF;

END Update_Remaining_Candidates;

/* --------------------------------------------------------------------
PROCEDURE: Add_Candidate_Log
PURPOSE: This Procedure will add a review comment to for a Candidate
         in the pa_candidate_reviews table. It will also update
         the status in pa_candidates table.
         A change reason  can be associated with every status change.
         A review comment can be associated with every status change.
         This API will error out if:
         1. The status change from p_old_status_code to p_new_status_code
            is not an acceptable change. (e.g: Status cannot change from
            Declined to Under Review).
         This API will return an unexpected error if:
         1. p_candidate_id is not found
         2. p_old_status_code or p_new_status_code are not valid status codes.
PARAMETERS:
   p_candidate_id            : Candidate Id of the candidate for whom
                               a log is being created
   p_status_code             : New Status Code entered for the log.
                               Pass null, if no value is entered in this field.
   p_review_comments         : Review Comments
   p_change_reason_code      : Change Reason for Status change.
   p_record_version_number   : Record Version of the Candidate Record
   p_cand_rec_version_number : Record Version Number of the Candidate
                               (from pa_candidates). We do not
                               need the record version number for
                               the review_comments table, since we only
                               insert in this table, we do not update it.
 -------------------------------------------------------------------- */
PROCEDURE Add_Candidate_Log
(p_candidate_id               IN  NUMBER,
 p_status_code                IN  VARCHAR2,
 p_change_reason_code         IN  VARCHAR2,
 p_review_comments            IN  VARCHAR2,
 p_cand_record_version_number IN  NUMBER,
 p_init_msg_list              IN  VARCHAR2 DEFAULT FND_API.G_TRUE,  -- Added for Bug 5130421: PJR Enhancements for Public APIs
 x_cand_record_version_number OUT NOCOPY NUMBER, -- 4537865
-- Added for bug 9187892
    -- start for bug#9468526 , Added default null values
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE :=NULL ,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE :=NULL ,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE :=NULL ,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE :=NULL ,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE :=NULL ,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE :=NULL ,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE :=NULL ,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE :=NULL ,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE :=NULL ,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE :=NULL ,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE :=NULL ,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE :=NULL ,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE :=NULL ,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE :=NULL ,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE :=NULL ,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE :=NULL ,
   -- start for bug#9468526 , Added default null values
 x_return_status              OUT NOCOPY VARCHAR2, -- 4537865
 x_msg_count                  OUT NOCOPY NUMBER, -- 4537865
 x_msg_data                   OUT NOCOPY VARCHAR2) -- 4537865
IS
l_old_status_code             VARCHAR2(30);
l_status_code                 VARCHAR2(30);
l_status_name                 VARCHAR2(80);
l_old_system_status_code      VARCHAR2(30);
l_system_status_code          VARCHAR2(30);
l_reviewer_person_id          NUMBER := 0;
l_change_reason_code          VARCHAR2(30)  := null;
l_review_comments             VARCHAR2(2000) := null; /* Fix for Bug 7356131 */
l_assignment_id               NUMBER;
l_resource_id                 NUMBER;
l_return_status               VARCHAR2(1);
l_new_cand_record_version_num NUMBER;
l_old_record_version_number   NUMBER;
l_msg_count                   NUMBER := 0;
l_msg_index_out               NUMBER;
l_msg_data                VARCHAR2(2000);
l_enable_wf_flag              VARCHAR2(1);
l_wf_item_type                VARCHAR2(30);
l_wf_process                  VARCHAR2(30);

BEGIN
 -- Initialize the Error Stack
 PA_DEBUG.init_err_stack('PA_CANDIDATE_PUB.Add_Candidate_Log');

 -- initialize return_status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Clear the global PL/SQL message table. Added check of p_init_msg_list Bug 5130421: PJR Enhancements for Public APIs
 IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
    FND_MSG_PUB.initialize;
 END IF;

 SELECT record_version_number
 INTO l_old_record_version_number
 FROM pa_candidates
 WHERE candidate_id = p_candidate_id;

 IF l_old_record_version_number <> p_cand_record_version_number THEN
    pa_utils.add_message
               (p_app_short_name  => 'PA',
                p_msg_name        => 'PA_XC_RECORD_CHANGED');
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 SELECT status_code
 INTO l_old_status_code
 FROM pa_candidates
 WHERE candidate_id=p_candidate_id;

  l_status_code        := p_status_code;
  l_review_comments    := p_review_comments;
  l_change_reason_code := p_change_reason_code;

  IF l_status_code is null THEN
     l_status_code := l_old_status_code;
  END IF;

 -- this is for workflow.
 SELECT assignment_id,resource_id
 INTO l_assignment_id,l_resource_id
 FROM pa_candidates
 where candidate_id = p_candidate_id;

  IF nvl(l_old_status_code,'-1') = nvl(l_status_code,'-1') THEN
     -- There is no status change

     -- Check to see if change reason is passed.
     -- The user should not update Change Reason if status is not
     -- updated.

     IF p_change_reason_code is not null THEN
       pa_utils.add_message
                     (p_app_short_name  => 'PA',
                      p_msg_name        => 'PA_CAND_NO_STATUS_CHANGE');

       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- check if a comment is passed. If no
     -- comment is passed, then return without making an entry in
     -- the log file.
     IF p_review_comments = FND_API.G_MISS_CHAR or
        p_review_comments is null THEN
        RETURN;
     END IF;

     IF l_status_code is null THEN
        -- Status is null
        l_system_status_code := null;
     ELSE
        SELECT project_system_status_code
        INTO l_system_status_code
        FROM pa_project_statuses
        WHERE project_status_code = l_status_code
        AND status_type = 'CANDIDATE';
     END IF;

     -- Since user status has not changed, assigning the same
     -- value to system status
     l_old_system_status_code := l_system_status_code;

     -- Since pa_candidates has not been updated, the new record version number should be
     -- same as the original passed value.
     l_new_cand_record_version_num := p_cand_record_version_number;
  ELSE
     -- Status has changed.

     -- Check if the change of status is allowed
     IF Pa_Project_Stus_Utils.Allow_Status_Change
           (o_status_code => l_old_status_code,
            n_status_code => l_status_code) = 'N'
     THEN
       -- Status Change is not allowed.
       pa_utils.add_message
                     (p_app_short_name  => 'PA',
                      p_msg_name        => 'PA_STATUS_CANT_CHANGE');

       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if the change of status requires change reason
     -- to be specified.
     IF (pa_project_utils.Check_prj_stus_action_allowed(l_status_code, 'CANDIDATE_CHANGE_REASON') = 'Y')
        AND p_change_reason_code is null THEN
       pa_utils.add_message
                     (p_app_short_name  => 'PA',
                      p_msg_name        => 'PA_CAND_CHG_REASON_REQD');
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Update pa_candidates with the new status code
     -- Added WHO Column update. Bug 7168412.

     -- Added Attribute Columns update for Bug 9187892

     UPDATE pa_candidates
     SET status_code           = l_status_code,
         record_version_number = record_version_number + 1,
         LAST_UPDATE_DATE      = SYSDATE,
         LAST_UPDATED_BY       = FND_GLOBAL.USER_ID,
	 -- start for bug#9468526, Added nvl such that, if the passed value is null, existing one is retained.
     attribute_category    = nvl(p_attribute_category,attribute_category),
     attribute1            = nvl(p_attribute1,attribute1),
     attribute2            = nvl(p_attribute2,attribute2),
     attribute3            = nvl(p_attribute3,attribute3),
     attribute4            = nvl(p_attribute4,attribute4),
     attribute5            = nvl(p_attribute5,attribute5),
     attribute6            = nvl(p_attribute6,attribute6),
     attribute7            = nvl(p_attribute7,attribute7),
     attribute8            = nvl(p_attribute8,attribute8),
     attribute9            = nvl(p_attribute9,attribute9),
     attribute10           = nvl(p_attribute10,attribute10),
     attribute11           = nvl(p_attribute11,attribute11),
     attribute12           = nvl(p_attribute12,attribute12),
     attribute13           = nvl(p_attribute13,attribute13),
     attribute14           = nvl(p_attribute14,attribute14),
     attribute15           = nvl(p_attribute15,attribute15)
      -- end  for bug#9468526
     WHERE candidate_id = p_candidate_id AND
           record_version_number=p_cand_record_version_number;

     -- Since pa_candidates has been updated, set the increased record version number to the local
     -- variabe to pass back as a out parameter.
     l_new_cand_record_version_num := p_cand_record_version_number+1;

     IF l_status_code is null THEN
        l_system_status_code := null;
     ELSE
        SELECT project_system_status_code
        INTO l_system_status_code
        FROM pa_project_statuses
        WHERE project_status_code = l_status_code
        AND status_type = 'CANDIDATE';
     END IF;

     IF l_old_status_code is null THEN
        l_old_system_status_code := null;
     ELSE
        SELECT project_system_status_code
        INTO l_old_system_status_code
        FROM pa_project_statuses
        WHERE project_status_code = l_old_status_code
        AND status_type = 'CANDIDATE';
     END IF;


      -- Update No_Of_Active_Candidates in PA_PROJECT_ASSIGNMENTS
      Update_No_Of_Active_Candidates(
             p_assignment_id            => l_assignment_id,
             p_old_system_status_code   => l_old_system_status_code,
             p_new_system_status_code   => l_system_status_code,
             x_return_status            => x_return_status);

      -- 4537865 Earlier wrong check was made against l_return_status
      IF x_return_status  = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  -- set the updated record_version_number to the out parameter.
  x_cand_record_version_number := l_new_cand_record_version_num;

  l_reviewer_person_id := Get_Person_Id;

  INSERT INTO PA_CANDIDATE_REVIEWS
        (CANDIDATE_REVIEW_ID,
         CANDIDATE_ID,
         RECORD_VERSION_NUMBER,
         STATUS_CODE,
         REVIEWER_PERSON_ID,
         REVIEW_DATE,
         CHANGE_REASON_CODE,
         REVIEW_COMMENTS,
         CREATION_DATE,
         -- Added for bug 9187892
	 ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY)
  VALUES
        (
         PA_CANDIDATE_REVIEWS_S.nextval,
         p_candidate_id,
         1,
         p_status_code,
         l_reviewer_person_id,
         sysdate,
         l_change_reason_code,
         l_review_comments,
         sysdate,
	 -- Added for bug 9187892
     	  p_attribute_category,
          p_attribute1,
          p_attribute2,
          p_attribute3,
          p_attribute4,
          p_attribute5,
          p_attribute6,
          p_attribute7,
          p_attribute8,
          p_attribute9,
          p_attribute10,
          p_attribute11,
          p_attribute12,
          p_attribute13,
          p_attribute14,
          p_attribute15,
         FND_GLOBAL.user_id,
         sysdate,
         FND_GLOBAL.user_id
        );

  -- Check is the status change needs a workflow to be started
  IF l_system_status_code <> l_old_system_status_code THEN

     SELECT ENABLE_WF_FLAG, WORKFLOW_ITEM_TYPE, WORKFLOW_PROCESS, PROJECT_STATUS_NAME
     INTO   l_enable_wf_flag, l_wf_item_type, l_wf_process, l_status_name
     FROM   PA_PROJECT_STATUSES
     WHERE  status_type = 'CANDIDATE'
     AND    project_status_code = l_status_code;

     IF l_enable_wf_flag = 'Y' AND l_wf_item_type IS NOT NULL AND
        l_wf_process IS NOT NULL THEN

        Start_Workflow(p_wf_item_type         => l_wf_item_type,
                       p_wf_process           => l_wf_process,
                       P_assignment_id        => l_assignment_id,
                       p_candidate_number     => p_candidate_id,
                       p_resource_id          => l_resource_id,
                       p_status_name          => l_status_name,
                       x_return_status        => l_return_status,
                       x_msg_count            => l_msg_count,
                       x_msg_data             => l_msg_data);

     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := FND_MSG_PUB.Count_Msg;

	  -- 4537865 : RESET OUT PARAM
	 x_cand_record_version_number := NULL ;

         IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages
                (p_encoded        => FND_API.G_TRUE
            ,p_msg_index       => 1
            ,p_msg_count       => 1
            ,p_msg_data        => l_msg_data
            ,p_data            => x_msg_data
            ,p_msg_index_out   => l_msg_index_out );
         END IF;
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          -- 4537865 : RESET OUT PARAM
         x_cand_record_version_number := NULL ;

     fnd_msg_pub.add_exc_msg
         (p_pkg_name => 'PA_COMPETENCE_PUB'
         ,p_procedure_name => 'Add_Candidate_Log' );

         x_msg_count := FND_MSG_PUB.Count_Msg;

         IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index       => 1
         ,p_msg_count       => 1
         ,p_msg_data        => l_msg_data
         ,p_data            => x_msg_data
         ,p_msg_index_out   => l_msg_index_out );
         END IF;

END ADD_CANDIDATE_LOG;

/* --------------------------------------------------------------------
PROCEDURE: Update_Candidate
PURPOSE:   This Procedure will update candidate p_candidate_id's
           status or ranking.
           If the status changes, we will create a log entry in the
           PA_CANDIDATES_LOG table. we will also update the
           NO_OF_ACTIVE_CANDIDATES column in PA_PROJECT_STATUSES, if an
           active candidate goes inactive or vice versa
           Since no comment is passed, we will create the log with an empty
           log message. This API will be called from the Candidate List Page,
           where the status,change reason or ranking can be updated.
PARAMETERS: p_candidate_id         : Candidate Id of the candidate being
                                     updated
            p_status_code          : Status Code for the candidate record.
                                     If the status is not changed, this
                                     field will hold the old status value.
            p_ranking              : Ranking for the candidate
                                     If the ranking is not changed, this
                                     field will hold the old ranking value.
            p_change_reason_code    : Change Reason for Status change.
            p_record_version_number : Record Version of the Candidate Record
 -------------------------------------------------------------------- */
PROCEDURE Update_Candidate
(p_candidate_id               IN  NUMBER,
 p_status_code                IN  VARCHAR2,
 p_ranking                    IN  NUMBER,
 p_change_reason_code         IN  VARCHAR2,
 p_record_version_number      IN  NUMBER,
 p_init_msg_list              IN  VARCHAR2 := FND_API.G_TRUE,
 p_validate_status            IN  VARCHAR2 := FND_API.G_TRUE,
 -- Added for bug 9187892
  -- start for bug#9468526 , Added default null values
 p_attribute_category           IN    pa_candidates.attribute_category%TYPE :=NULL ,
 p_attribute1                   IN    pa_candidates.attribute1%TYPE :=NULL ,
 p_attribute2                   IN    pa_candidates.attribute2%TYPE :=NULL ,
 p_attribute3                   IN    pa_candidates.attribute3%TYPE :=NULL ,
 p_attribute4                   IN    pa_candidates.attribute4%TYPE :=NULL ,
 p_attribute5                   IN    pa_candidates.attribute5%TYPE :=NULL ,
 p_attribute6                   IN    pa_candidates.attribute6%TYPE :=NULL ,
 p_attribute7                   IN    pa_candidates.attribute7%TYPE :=NULL ,
 p_attribute8                   IN    pa_candidates.attribute8%TYPE :=NULL ,
 p_attribute9                   IN    pa_candidates.attribute9%TYPE :=NULL ,
 p_attribute10                  IN    pa_candidates.attribute10%TYPE :=NULL ,
 p_attribute11                  IN    pa_candidates.attribute11%TYPE :=NULL ,
 p_attribute12                  IN    pa_candidates.attribute12%TYPE :=NULL ,
 p_attribute13                  IN    pa_candidates.attribute13%TYPE :=NULL ,
 p_attribute14                  IN    pa_candidates.attribute14%TYPE :=NULL ,
 p_attribute15                  IN    pa_candidates.attribute15%TYPE :=NULL ,
   -- End for bug#9468526 , Added default null values
 x_record_version_number      OUT NOCOPY NUMBER, -- 4537865 Added nocopy hint
 x_msg_count                  OUT NOCOPY NUMBER, -- 4537865 Added nocopy hint
 x_msg_data                   OUT NOCOPY VARCHAR2, -- 4537865 Added nocopy hint
 x_return_status              OUT NOCOPY VARCHAR2) -- 4537865 Added nocopy hint
IS
l_assignment_id             NUMBER;
l_resource_id               NUMBER;
l_old_status_code           VARCHAR2(30);
l_status_code               VARCHAR2(30);
l_status_name               VARCHAR2(80);
l_old_system_status_code    VARCHAR2(30);
l_system_status_code        VARCHAR2(30);
l_old_record_version_number NUMBER;
l_old_candidate_ranking     NUMBER;
l_change_reason_code        VARCHAR2(30);
l_reviewer_person_id        NUMBER := 0;
l_exists                    VARCHAR2(1);
l_msg_index_out             NUMBER ;
l_return_status             VARCHAR2(1);
l_msg_data              VARCHAR2(2000);
l_msg_count                 NUMBER := 0;
l_enable_wf_flag            VARCHAR2(1);
l_wf_item_type              VARCHAR2(30);
l_wf_process                VARCHAR2(30);

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CANDIDATE_PUB.Add_Candidate_Log');

  -- initialize return_status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_status_code        := p_status_code;
  l_change_reason_code := p_change_reason_code;

  -- Get Old Value
  BEGIN
      SELECT assignment_id,
         status_code,
         record_version_number,
     resource_id,
         candidate_ranking
      INTO l_assignment_id,
     l_old_status_code,
     l_old_record_version_number,
     l_resource_id,
     l_old_candidate_ranking
      FROM pa_candidates
      WHERE candidate_id = p_candidate_id;

      EXCEPTION
     WHEN NO_DATA_FOUND THEN
        pa_utils.add_message
               (p_app_short_name  => 'PA',
            p_msg_name        => 'PA_CAND_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  IF l_old_record_version_number <> p_record_version_number THEN
     pa_utils.add_message
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_XC_RECORD_CHANGED');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_status_code is null THEN
     l_system_status_code := null;
  ELSE
     SELECT project_system_status_code
     INTO l_system_status_code
     FROM pa_project_statuses
     WHERE project_status_code = l_status_code
     AND status_type = 'CANDIDATE';
  END IF;

  IF l_old_status_code is null THEN
     l_old_system_status_code := null;
  ELSE
     SELECT project_system_status_code
     INTO l_old_system_status_code
     FROM pa_project_statuses
     WHERE project_status_code = l_old_status_code
     AND status_type = 'CANDIDATE';
  END IF;

  IF l_system_status_code = 'CANDIDATE_SYSTEM_NOMINATED'
     AND l_old_system_status_code <> 'CANDIDATE_SYSTEM_NOMINATED' THEN
     pa_utils.add_message
             (p_app_short_name  => 'PA',
              p_msg_name        => 'PA_CAND_STATUS_NOT_ALLOWED');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(p_validate_status) THEN
     -- Status has not changed. Check to see if change reason is passed.
     -- The user should not update Change Reason if status is not
     -- updated.
     IF nvl(l_old_status_code,'-1') = nvl(l_status_code,'-1') THEN

        IF p_change_reason_code is not null THEN
           pa_utils.add_message
                        (p_app_short_name  => 'PA',
                         p_msg_name        => 'PA_CAND_NO_STATUS_CHANGE');
           RAISE FND_API.G_EXC_ERROR;

        -- If nothing has been updated, just return without updating anything.
        ELSIF p_change_reason_code is null
              AND nvl(l_old_candidate_ranking,'-1') = nvl(p_ranking,'-1') THEN
    RETURN;
        END IF;

     -- Status has changed
     -- Check if status can change from l_old_status to p_status.
     ELSE
        -- if Status Change is not allowed.
        IF Pa_Project_Stus_Utils.Allow_Status_Change
              (o_status_code => l_old_status_code,
               n_status_code => l_status_code) = 'N'  THEN
          pa_utils.add_message
                        (p_app_short_name  => 'PA',
                         p_msg_name        => 'PA_STATUS_CANT_CHANGE');

          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Check if reason is required for the status change
        IF (pa_project_utils.Check_prj_stus_action_allowed
           (l_status_code, 'CANDIDATE_CHANGE_REASON') = 'Y') AND
           p_change_reason_code is null THEN
           pa_utils.add_message
                         (p_app_short_name  => 'PA',
                          p_msg_name        => 'PA_CAND_CHG_REASON_REQD');

           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
  END IF;

  -- Added WHO Column update. Bug 7168412.
  -- Added Attribute Columns update for Bug 9187892
  UPDATE pa_candidates
  SET
     status_code           = l_status_code,
     candidate_ranking     = p_ranking,
     record_version_number = p_record_version_number+1,
     LAST_UPDATE_DATE      = SYSDATE,
     LAST_UPDATED_BY       = FND_GLOBAL.USER_ID,
	 -- start for bug#9468526, Added nvl such that, if the passed value is null, existing one is retained.
     attribute_category    = nvl(p_attribute_category,attribute_category),
     attribute1            = nvl(p_attribute1,attribute1),
     attribute2            = nvl(p_attribute2,attribute2),
     attribute3            = nvl(p_attribute3,attribute3),
     attribute4            = nvl(p_attribute4,attribute4),
     attribute5            = nvl(p_attribute5,attribute5),
     attribute6            = nvl(p_attribute6,attribute6),
     attribute7            = nvl(p_attribute7,attribute7),
     attribute8            = nvl(p_attribute8,attribute8),
     attribute9            = nvl(p_attribute9,attribute9),
     attribute10           = nvl(p_attribute10,attribute10),
     attribute11           = nvl(p_attribute11,attribute11),
     attribute12           = nvl(p_attribute12,attribute12),
     attribute13           = nvl(p_attribute13,attribute13),
     attribute14           = nvl(p_attribute14,attribute14),
     attribute15           = nvl(p_attribute15,attribute15)
      -- end  for bug#9468526
  WHERE
     candidate_id = p_candidate_id AND
     record_version_number = p_record_version_number;

  -- set the updated record_version_number to the out parameter.
  x_record_version_number := p_record_version_number+1;


  -- Create an entry on the log table if the status has changed.
  IF nvl(l_old_status_code,'-1') <> nvl(l_status_code,'-1') THEN
     l_reviewer_person_id := Get_Person_Id;

     INSERT INTO PA_CANDIDATE_REVIEWS
        (CANDIDATE_REVIEW_ID,
         CANDIDATE_ID,
         RECORD_VERSION_NUMBER,
         STATUS_CODE,
         REVIEWER_PERSON_ID,
         REVIEW_DATE,
         REVIEW_COMMENTS,
         CHANGE_REASON_CODE,
         CREATION_DATE,
          -- Added for bug 9187892
	  ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY)
     VALUES
        (
         PA_CANDIDATE_REVIEWS_S.nextval,
         p_candidate_id,
         1,
         l_status_code,
         l_reviewer_person_id,
         sysdate,
         null,
         l_change_reason_code,
         sysdate,
          -- Added for bug 9187892
	  p_attribute_category,
          p_attribute1,
          p_attribute2,
          p_attribute3,
          p_attribute4,
          p_attribute5,
          p_attribute6,
          p_attribute7,
          p_attribute8,
          p_attribute9,
          p_attribute10,
          p_attribute11,
          p_attribute12,
          p_attribute13,
          p_attribute14,
          p_attribute15,
         FND_GLOBAL.user_id,
         sysdate,
         FND_GLOBAL.user_id
        );

     -- Update No_Of_Active_Candidates in PA_PROJECT_ASSIGNMENTS
     Update_No_Of_Active_Candidates(
             p_assignment_id            => l_assignment_id,
             p_old_system_status_code   => l_old_system_status_code,
             p_new_system_status_code   => l_system_status_code,
             x_return_status            => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     SELECT ENABLE_WF_FLAG, WORKFLOW_ITEM_TYPE, WORKFLOW_PROCESS, PROJECT_STATUS_NAME
     INTO   l_enable_wf_flag, l_wf_item_type, l_wf_process, l_status_name
     FROM   PA_PROJECT_STATUSES
     WHERE  status_type = 'CANDIDATE'
     AND    project_status_code = l_status_code;

     -- Check is the status change needs a workflow to be started
     IF l_enable_wf_flag = 'Y' AND l_wf_item_type IS NOT NULL AND
        l_wf_process IS NOT NULL THEN

    Start_Workflow(
            p_wf_item_type         => l_wf_item_type,
            p_wf_process           => l_wf_process,
            P_assignment_id        => l_assignment_id,
            p_candidate_number     => p_candidate_id,
            p_resource_id          => l_resource_id,
                        p_status_name          => l_status_name,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data);
     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
 END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := FND_MSG_PUB.Count_Msg;

     -- 4537865 : RESET OUT PARAM
     x_record_version_number := NULL ;

     IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
               (p_encoded         => FND_API.G_TRUE,
            p_msg_index       => 1,
            p_msg_count       => 1 ,
            p_msg_data        => l_msg_data ,
            p_data            => x_msg_data,
            p_msg_index_out   => l_msg_index_out );
     END IF;

    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- 4537865 : RESET OUT PARAM
     x_record_version_number := NULL ;

     fnd_msg_pub.add_exc_msg
        (p_pkg_name       => 'PA_COMPETENCE_PUB',
         p_procedure_name => 'Update_Candidate' );

         x_msg_count := FND_MSG_PUB.Count_Msg;


         IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index       => 1
         ,p_msg_count       => 1
         ,p_msg_data        => l_msg_data
         ,p_data            => x_msg_data
         ,p_msg_index_out   => l_msg_index_out );
         END IF;

END Update_Candidate;

/* --------------------------------------------------------------------
FUNCTION: Get_Competence_Match
PURPOSE: This function will return the competence match for the person
         p_person_id for the assigment pa_assignment_id.
 -------------------------------------------------------------------- */

FUNCTION Get_Competence_Match
( p_person_id           IN  NUMBER
, p_assignment_id       IN  NUMBER
)
RETURN VARCHAR2
IS
--declare local variables
l_mandatory_competence_count    NUMBER:= 0;
l_mandatory_competence_match    NUMBER:= 0;
l_optional_competence_count NUMBER:= 0;
l_optional_competence_match     NUMBER:= 0;
l_competence_match              VARCHAR2(30);

BEGIN

PA_SEARCH_GLOB.Check_Competence_Match
               (p_search_mode             => 'RESOURCE',
                p_person_id               => p_person_id,
                p_requirement_id          => p_assignment_id,
                x_mandatory_match         => l_mandatory_competence_match,
                x_mandatory_count         => l_mandatory_competence_count,
                x_optional_match          => l_optional_competence_match,
                x_optional_count          => l_optional_competence_count);

-- Angie updated to fix bug 1581223 : COMPETENCE MATCH FOR CANDIDATES PAGE SHOULD INCLUDE
-- ALL COMPETENCIES. Paranthesis here is needed otherwise it will throw exception.
l_competence_match := (l_mandatory_competence_match + l_optional_competence_match) || '/'
               || (l_mandatory_competence_count + l_optional_competence_count);

RETURN l_competence_match;
END Get_Competence_Match;


/* --------------------------------------------------------------------
FUNCTION: Check_Availability
PURPOSE: This function will return the availability for the person
         p_person_id for the assigment pa_assignment_id.
 -------------------------------------------------------------------- */
FUNCTION Check_Availability(p_resource_id   IN NUMBER,
                            p_assignment_id IN NUMBER,
                            p_project_id    IN NUMBER)
RETURN NUMBER
IS
l_availability NUMBER;
BEGIN
      l_availability := PA_SEARCH_GLOB.Check_Availability(
                                       p_resource_id   => p_resource_id,
                                       p_assignment_id => p_assignment_id,
                                       p_project_id    => p_project_id);
      RETURN l_availability;
END Check_Availability;

/* --------------------------------------------------------------------
FUNCTION: Check_And_Get_Proj_Customer
PURPOSE:
 -------------------------------------------------------------------- */
PROCEDURE Check_And_Get_Proj_Customer ( p_project_id IN NUMBER
                       ,x_customer_id OUT NOCOPY NUMBER  -- 4537865 Added nocopy hint
                       ,x_customer_name OUT NOCOPY VARCHAR2 )  -- 4537865 Added nocopy hint
IS

-- 4363092 TCA changes, replaced RA views with HZ tables

/*
CURSOR project_customers IS
SELECT ppc.customer_id,rac.customer_name
FROM pa_project_customers ppc,
     ra_customers rac
WHERE ppc.project_id = p_project_id
AND   rac.customer_id = ppc.customer_id ;
*/

CURSOR project_customers IS
SELECT ppc.customer_id, substrb(party.party_name,1,50) customer_name
FROM pa_project_customers ppc,
     hz_parties party,
     hz_cust_accounts cust_acct
WHERE ppc.project_id = p_project_id
AND   cust_acct.cust_account_id = ppc.customer_id
and  party.party_id = cust_acct.party_id;

-- 4363092 end

l_count NUMBER := 0;

BEGIN
   FOR c1 in project_customers LOOP
       l_count := l_count + 1;
       IF l_count > 1 THEN
         x_customer_name := null;
         x_customer_id := null;
         EXIT;
       END IF;
       x_customer_name := c1.customer_name;
       x_customer_id   := c1.customer_id;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
	 -- 4537865 RESET OUT PARAM
	 x_customer_id := NULL ;
	 x_customer_name := NULL ;
	RAISE;

END Check_And_Get_proj_customer;

/* --------------------------------------------------------------------
FUNCTION: Check_Candidacy
PURPOSE: This Procedure accepts a count of resources, and a
         list of resource ids (separated by ",", and checks if each
         of the resource is a candidate on p_assignment_id.
         It returns back a list of 0s and 1s.
         For every resource who is not a candidate, it will return
         a "1". For every resource who is candidate, it will return
         a 0. The client side will display the resources as candidates
         based on the value passed for the corresponding resource.
         A message will all be passed back which states all the
         resources which are candidates. This API is called from
         t12a, if that page is called from T10 (where a list of
         resources could be selected to create as candidates)
 -------------------------------------------------------------------- */
PROCEDURE Check_Candidacy
(p_assignment_id       IN  NUMBER,
 p_resource_count      IN  NUMBER,
 p_resource_list       IN  VARCHAR2,
 x_resource_list       OUT NOCOPY VARCHAR2, -- 4537865 Added nocopy hint
 x_msg_count           OUT NOCOPY NUMBER, -- 4537865 Added nocopy hint
 x_invalid_candidates  OUT NOCOPY VARCHAR2,  -- 4537865 Added nocopy hint
 x_return_status       OUT NOCOPY VARCHAR2)  -- 4537865 Added nocopy hint
IS
l_in_resource_list     VARCHAR2(1000);
l_resource_list        VARCHAR2(1000);
l_resource_id          NUMBER;
l_candidate_list       VARCHAR2(4000);
l_delim                VARCHAR2(1) := ',';
l_resource_name        VARCHAR2(240);
initial                NUMBER;
J                      NUMBER;
nextpos                NUMBER;
l_candidate_exists     BOOLEAN := FALSE;

l_msg_count            NUMBER := 0;
l_data                 VARCHAR2(500);
l_msg_index_out        NUMBER ;
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_in_resource_list := p_resource_list || ',';
  j:= 1;
  initial := 1;
  nextpos        := INSTR(l_in_resource_list,l_delim,1,j);

  FOR I in 1..p_resource_count LOOP

      l_resource_id := to_number(SUBSTR(l_in_resource_list,initial,nextpos-initial));

      initial := nextpos + 1.0;

      j:= j + 1.0;

      nextpos     := INSTR(l_in_resource_list,l_delim,1,j);

      IF IS_CAND_ON_ASSIGNMENT(l_resource_id,p_assignment_id) = 'Y' THEN

        IF l_resource_list is null THEN
           l_resource_list := 'Y';
        ELSE
           l_resource_list := l_resource_list || ',' || 'Y';
        END IF;

        l_resource_name := Get_Resource_Name(l_resource_id);

        IF l_resource_name is not null THEN
           IF l_candidate_list is null THEN
              l_candidate_list := l_candidate_list || ' ' || l_resource_name;
           ELSE
              l_candidate_list := l_candidate_list || ',' || ' ' || l_resource_name;
           END IF;
           l_candidate_exists := TRUE;
        END IF;

      ELSE

        IF l_resource_list is null THEN
           l_resource_list := 'N';
        ELSE
           l_resource_list := l_resource_list || ',' || 'N';
        END IF;

      END IF;
  END LOOP;


  IF l_candidate_exists THEN
    x_invalid_candidates := l_candidate_list;
    x_msg_count := 1;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_resource_list := l_resource_list;

EXCEPTION
  WHEN OTHERS THEN
     -- 4537865 RESET OUT PARAMS
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
     x_msg_count     := 1;
     x_resource_list := NULL ;
     x_invalid_candidates := NULL ;

     If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then
            Fnd_Msg_Pub.Add_Exc_Msg
            (   P_Pkg_Name              =>  'PA_CANDIDATE_PUB',
                P_Procedure_Name        =>  'Check_Candidacy');

     End If;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;



/* --------------------------------------------------------------------
FUNCTION: Start_Workflow
PURPOSE:
 -------------------------------------------------------------------- */
Procedure Start_Workflow(p_wf_item_type         IN  VARCHAR2,
                         p_wf_process           IN  VARCHAR2,
                         p_assignment_id        IN  NUMBER,
                         p_candidate_number     IN  NUMBER,
                         p_resource_id          IN  NUMBER,
                         p_status_name          IN  VARCHAR2,
                         x_return_status        OUT NOCOPY VARCHAR2, -- 4537865
                         x_msg_count            OUT NOCOPY NUMBER, -- 4537865
                         x_msg_data             OUT NOCOPY VARCHAR2) -- 4537865
IS
CURSOR l_assignments_csr IS
SELECT ppa.assignment_id,
       ppa.assignment_name,
       ppa.assignment_effort,
       ppa.additional_information,
       ppa.description,
       ppa.note_to_approver,
       ppa.project_id,
       ppa.resource_id,
       ppa.start_date,
       ppa.end_date,
       ppa.status_code,
       ppa.apprvl_status_code,
       ppa.pending_approval_flag,
       ppa.assignment_type
FROM pa_project_assignments ppa
WHERE assignment_id = p_assignment_id;

CURSOR l_stus_csr (c_status_code IN VARCHAR2) IS
SELECT ps.wf_success_status_code,
       ps.wf_failure_status_code,
       ps.project_status_name
FROM   pa_project_statuses ps
WHERE  project_status_code = c_status_code;

CURSOR l_resource_csr(l_resource_id IN NUMBER, p_start_date IN DATE) IS
SELECT res.resource_name,
       res.person_id resource_person_id,
       res.resource_id,
       hou.name resource_organization_name,
       res.manager_id
FROM   pa_resources_denorm res,
       hr_all_organization_units hou
WHERE  res.resource_id = l_resource_id
AND    hou.organization_id = res.resource_organization_id
AND    p_start_date BETWEEN resource_effective_start_date
                            AND resource_effective_end_date
AND    res.schedulable_flag = 'Y';

CURSOR l_projects_csr(l_project_id IN NUMBER) IS
SELECT pap.project_id project_id,
       pap.name name,
       pap.segment1 segment1,
       pap.carrying_out_organization_id carrying_out_organization_id,
       pap.location_id,
       hr.name organization_name,
       NVL(pt.administrative_flag,'N') admin_flag
FROM pa_projects_all pap,
     hr_all_organization_units hr,
     pa_project_types_all pt
WHERE pap.project_id = l_project_id
AND   pap.carrying_out_organization_id =
      hr.organization_id
AND   pap.org_id = pt.org_id    -- Added for Bug 5389093
AND   pt.project_type = pap.project_type;

l_assignments_rec             l_assignments_csr%ROWTYPE;
l_resource_rec                l_resource_csr%ROWTYPE;
l_projects_rec                l_projects_csr%ROWTYPE;

l_itemkey                     VARCHAR2(30);
l_responsibility_id           NUMBER;
l_resp_appl_id                NUMBER;

l_resource_user_name          VARCHAR2(320); /* Modified VARCHAR2(240) for bug 3158966 */
l_resource_display_name       VARCHAR2(360);  /* Modified VARCHAR2(240) for bug 3158966 */
l_res_manager_id              NUMBER;
l_res_manager_name            VARCHAR2(240);
l_res_manager_user_name       VARCHAR2(320); /* Modified VARCHAR2(240) for bug 3158966 */
l_res_manager_display_name    VARCHAR2(360);  /* Modified VARCHAR2(240) for bug 3158966 */

l_proj_mgr_person_id          NUMBER;
l_proj_mgr_name               VARCHAR2(240);
l_proj_mgr_display_name       VARCHAR2(240);

l_project_party_id            NUMBER;
l_project_role_id             NUMBER;
l_project_role_name           VARCHAR2(80);

l_asgmt_details_url           VARCHAR2(600);
l_resource_details_url        VARCHAR2(600);

l_primarycontactid            NUMBER := 0;
l_primarycontactname          VARCHAR2(240);
l_primarycontact_user_name    VARCHAR2(320);  /* Modified VARCHAR2(240) for bug 3158966 */
l_primarycontact_display_name VARCHAR2(360);  /* Modified VARCHAR2(240) for bug 3158966 */
l_notification_type           VARCHAR2(80);

-- 4363092 TCA changes, replaced RA views with HZ tables
/*
l_customer_id                ra_customers.customer_id%TYPE;
l_customer_name              ra_customers.customer_name%TYPE;
*/

l_customer_id                hz_cust_accounts.cust_account_id%TYPE;
l_customer_name              hz_parties.party_name%TYPE;
-- 4363092 end

l_in_nf_recipients_rec       PA_CLIENT_EXTN_CAND_WF.Users_List_Tbltyp;
l_out_nf_recipients_rec      PA_CLIENT_EXTN_CAND_WF.Users_List_Tbltyp;
l_number_of_recipients       NUMBER;
l_in_recp_rec_index          NUMBER := 0;
l_out_recp_rec_index         NUMBER;

l_role_name                  VARCHAR2(320); /* Modified VARCHAR2(240) for bug 3158966 */
l_role_display_name          VARCHAR2(360); /* Modified VARCHAR2(240) for bug 3158966 */
l_role_users                 VARCHAR2(300);
l_resource_person_id         NUMBER;

l_staff_owner_person_id_tbl  system.pa_num_tbl_type;
l_staff_owner_user_name      VARCHAR2(300);
l_staff_owner_display_name   VARCHAR2(360);
l_is_recipient               VARCHAR2(1);

l_return_status              VARCHAR2(1);
l_error_message_code         VARCHAR2(30);
l_msg_count              NUMBER ;
l_msg_data               VARCHAR2(2000);

l_msg_index_out        NUMBER ; -- 4537865

l_err_code                   NUMBER := 0;
l_err_stage                  VARCHAR2(2000);
l_err_stack                  VARCHAR2(2000);

l_count_recipients           NUMBER := 0; -- Added for Bug 6144224

BEGIN
 -- initialize return_status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 --dbms_output.put_line('begin-- p_wf_item_type ' || p_wf_item_type);
 --dbms_output.put_line('begin-- p_wf_process ' || p_wf_process);
 --dbms_output.put_line('begin-- p_status_name ' || p_status_name);

 -- Create the unique item key to launch WF with
 SELECT pa_prm_wf_item_key_s.nextval
 INTO l_itemkey
 FROM dual;

 -- Now start fetching the details
 OPEN l_assignments_csr;
 FETCH l_assignments_csr INTO l_assignments_rec;
 IF l_assignments_csr%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    pa_utils.add_message (p_app_short_name  => 'PA',
                          p_msg_name        => 'PA_INVALID_ASMGT_ID');
    CLOSE l_assignments_csr;
  ELSE
    CLOSE l_assignments_csr;
  END IF;

  OPEN l_projects_csr(l_assignments_rec.project_id);
  FETCH l_projects_csr INTO l_projects_rec;
  IF l_projects_csr%NOTFOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     pa_utils.add_message (p_app_short_name  => 'PA',
                           p_msg_name        => 'PA_INVALID_PROJECT_ID');
     CLOSE l_projects_csr;
  ELSE
     CLOSE l_projects_csr;
  END IF;

  Check_And_Get_Proj_Customer
             (p_project_id   => l_assignments_rec.project_id
              ,x_customer_id  => l_customer_id
              ,x_customer_name => l_customer_name );

  OPEN l_resource_csr(p_resource_id, l_assignments_rec.start_date);
  FETCH l_resource_csr INTO l_resource_rec;
  IF l_resource_csr%NOTFOUND THEN
   --  bug#9150756  start
   CLOSE l_resource_csr;
     IF  l_assignments_rec.start_date > SYSDATE THEN
   OPEN l_resource_csr(p_resource_id, (SYSDATE -1 ));
   FETCH l_resource_csr INTO l_resource_rec;
IF l_resource_csr%NOTFOUND THEN
     CLOSE l_resource_csr;
     RETURN;
ELSE
CLOSE l_resource_csr;
               END IF ;
           END IF ;
  ELSE
     CLOSE l_resource_csr;
  END IF;
--  bug#9150756  end


  -- Get the project manager details
  pa_project_parties_utils.get_curr_proj_mgr_details
        (p_project_id => l_projects_rec.project_id
        ,x_manager_person_id => l_proj_mgr_person_id
        ,x_manager_name      => l_proj_mgr_name
        ,x_project_party_id  => l_project_party_id
                ,x_project_role_id   => l_project_role_id
                ,x_project_role_name => l_project_role_name
                ,x_return_status     => l_return_status
                ,x_error_message_code => l_error_message_code );

  --dbms_output.put_line('p_project_id: '|| l_projects_rec.project_id);

  -- get the candidate person_id
  l_resource_person_id := l_resource_rec.resource_person_id;
  --dbms_output.put_line('l_resource_person_id :' || l_resource_person_id);

  -- get the resource's name
  IF l_resource_person_id IS NOT NULL THEN
     wf_directory.getusername
      (p_orig_system    => 'PER',
           p_orig_system_id => l_resource_person_id,
           p_name           => l_resource_user_name,
           p_display_name   => l_resource_display_name);

     IF l_resource_user_name is not NULL THEN
        -- increase recipients_record index by one
        l_in_recp_rec_index := l_in_recp_rec_index + 1;

        --dbms_output.put_line('l_resource_user_name :' || l_resource_user_name);

        -- fill in the default recipients list(candidate, resource_manager,
        -- primary contact) to send it to the client extension procedure
        -- for the candidate workflow notification recipients.

        l_in_nf_recipients_rec(l_in_recp_rec_index).User_Name := l_resource_user_name;
        l_in_nf_recipients_rec(l_in_recp_rec_index).Person_id := l_resource_person_id;
        l_in_nf_recipients_rec(l_in_recp_rec_index).Type      := 'RESOURCE';
     END IF;
  END IF;

  -- Call the procedure to get the primary_contact_id(l_primarycontactid)
  PA_RESOURCE_UTILS.get_org_primary_contact
                          (P_ResourceId           => p_resource_id
                          ,p_assignment_id        => l_assignments_rec.assignment_id
                          ,x_PrimaryContactId     => l_primarycontactid
                          ,x_PrimaryContactName   => l_primarycontactname
                          ,x_ManagerId            => l_res_manager_id
                          ,x_ManagerName          => l_res_manager_name
                          ,x_return_Status        => l_return_status
                          ,x_msg_count            => l_msg_count
                          ,x_msg_data             => l_msg_data);
  --dbms_output.put_line('1... l_primarycontactid :' || l_primarycontactid);
  --dbms_output.put_line('l_res_manager_id :' || l_res_manager_id);
  --dbms_output.put_line('l_return_status :' || l_return_status);

  -- Now get the resource's manager name. -- bug 7623859
  IF l_res_manager_id IS NOT NULL THEN
     wf_directory.getusername
         (p_orig_system    => 'PER',
          p_orig_system_id => l_res_manager_id,
          p_name           => l_res_manager_user_name,
          p_display_name   => l_res_manager_display_name);

     IF l_res_manager_user_name is not NULL THEN
        -- increase recipients_record index by one
        l_in_recp_rec_index := l_in_recp_rec_index + 1;

        --dbms_output.put_line('l_resource_rec.manager_id :' || l_resource_rec.manager_id);
        --dbms_output.put_line('l_res_manager_user_name :' || l_res_manager_user_name);
        --dbms_output.put_line('l_in_recp_rec_index :' || l_in_recp_rec_index);

        -- fill in the default recipients list(candidate, resource_manager, primary contact)
        -- to send it to the client extension procedure for the candidate workflow notification
        -- recipients.
        l_in_nf_recipients_rec(l_in_recp_rec_index).User_Name := l_res_manager_user_name;
        l_in_nf_recipients_rec(l_in_recp_rec_index).Person_id := l_res_manager_id;
        l_in_nf_recipients_rec(l_in_recp_rec_index).Type      := 'RESOURCE_MANAGER';
    END IF;
  END IF;


  -- Get the user_name of primary contact if the primary contact is not the same
  -- as resource_manager
  IF l_primarycontactid IS NOT NULL AND
     l_primarycontactid <> l_resource_rec.manager_id AND
     l_primarycontactid <> l_resource_person_id THEN   --Added for Bug 3959762
     wf_directory.getusername
         (p_orig_system    => 'PER',
          p_orig_system_id => l_primarycontactid,
          p_name           => l_primarycontact_user_name,
          p_display_name   => l_primarycontact_display_name);

     IF l_primarycontact_user_name is not NULL THEN
        -- increase recipients_record index by one
        l_in_recp_rec_index := l_in_recp_rec_index + 1;

        --dbms_output.put_line('l_primarycontactid :' || l_primarycontactid);
        --dbms_output.put_line('l_primarycontact_user_name :' || l_primarycontact_user_name);
        --dbms_output.put_line('l_in_recp_rec_index :' || l_in_recp_rec_index);

        -- fill in the default recipients list(candidate, resource_manager, primary contact)
        -- to send it to the client extension procedure for the candidate workflow notification
        -- recipients.
        l_in_nf_recipients_rec(l_in_recp_rec_index).User_Name := l_primarycontact_user_name;
        l_in_nf_recipients_rec(l_in_recp_rec_index).Person_id := l_primarycontactid;
        l_in_nf_recipients_rec(l_in_recp_rec_index).Type      := 'ORG_PRIMARY_CONTACT';
     END IF;
  END IF;

  -- Call the procedure to get staffing owners
  PA_ASSIGNMENT_UTILS.get_all_staffing_owners
            ( p_assignment_id   => l_assignments_rec.assignment_id
             ,p_project_id      => l_assignments_rec.project_id
             ,x_person_id_tbl   => l_staff_owner_person_id_tbl
             ,x_return_status   => l_return_status
             ,x_error_message_code => l_msg_data);

  IF l_staff_owner_person_id_tbl.COUNT > 0 THEN

    FOR i in 1..l_staff_owner_person_id_tbl.COUNT LOOP

     wf_directory.getusername
         (p_orig_system    => 'PER',
          p_orig_system_id => l_staff_owner_person_id_tbl(i),
          p_name           => l_staff_owner_user_name,
          p_display_name   => l_staff_owner_display_name);

     l_is_recipient := 'F';
     -- check if this person is already a recipient
     FOR j in 1..l_in_nf_recipients_rec.COUNT LOOP
       IF l_in_nf_recipients_rec(j).User_Name = l_staff_owner_user_name THEN
          l_is_recipient := 'T';
       END IF;
     END LOOP;

     IF l_staff_owner_user_name is not NULL AND l_is_recipient = 'F' THEN
        -- increase recipients_record index by one
        l_in_recp_rec_index := l_in_recp_rec_index + 1;
        l_in_nf_recipients_rec(l_in_recp_rec_index).User_Name := l_staff_owner_user_name;
        l_in_nf_recipients_rec(l_in_recp_rec_index).Person_id := l_staff_owner_person_id_tbl(i);
        l_in_nf_recipients_rec(l_in_recp_rec_index).Type      := 'STAFFING_OWNER';
     END IF;
    END LOOP;
  END IF;

  -- Set the p_notification_type to pass it to client extension procedure for the candidate
  -- workflow notification recipients.
  IF p_wf_process = 'PRO_CANDIDATE_FYI_NOTIFICATION' THEN
     l_notification_type := 'FYI_NOTIFICATION';
  END IF;
  /*
  IF p_wf_process = 'PRO_CANDIDATE_NOMINATED' THEN
     l_notification_type := 'PENDING_REVIEW_FYI';
  ELSIF p_wf_process = 'PRO_CANDIDATE_DECLINED' THEN
     l_notification_type := 'DECLINED_FYI';
  END IF;
  */

  --dbms_output.put_line('l_notification_type :'||  l_notification_type );

  -- Call client extension procedure for the candidate workflow notification recipients.
  PA_CLIENT_EXTN_CAND_WF.Generate_NF_Recipients
    (p_project_id              => l_projects_rec.project_id
        ,p_assignment_id           => p_assignment_id
    ,p_candidate_number        => p_candidate_number
    ,p_notification_type       => l_notification_type
    ,p_in_list_of_recipients   => l_in_nf_recipients_rec
    ,x_out_list_of_recipients  => l_out_nf_recipients_rec
    ,x_number_of_recipients    => l_number_of_recipients);

  -- If the recipients record doesn't include any record, we don't need to keep processing
  -- workflow. Because there is no notification recipient anyway.

  IF l_out_nf_recipients_rec.count < 1 THEN
    return;
  END IF;

  -- get first index of l_out_nf_recipients_rec
  l_out_recp_rec_index := l_out_nf_recipients_rec.first;
  --dbms_output.put_line('l_out_recp_rec_index.first: ' || l_out_recp_rec_index);
  --dbms_output.put_line('l_number_of_recipients :' || l_number_of_recipients);

  -- loop for l_out_nf_recipients_rec to generate l_role_name with recipients which has
  -- been passed by client extension procedure
  FOR I in 1..l_out_nf_recipients_rec.count LOOP
      IF FND_GLOBAL.USER_NAME <> l_out_nf_recipients_rec(l_out_recp_rec_index).User_Name THEN

     l_count_recipients := l_count_recipients + 1 ; -- added for bug 6144224
         IF l_role_users is not null THEN
            l_role_users := l_role_users || ',' || l_out_nf_recipients_rec(l_out_recp_rec_index).User_Name;
         ELSE
            l_role_users := l_out_nf_recipients_rec(l_out_recp_rec_index).User_Name;
         END IF;
      END IF;

      -- get next index of l_out_nf_recipients_rec
      l_out_recp_rec_index := l_out_nf_recipients_rec.next(l_out_recp_rec_index);
  END LOOP;

   -- Create an ad hoc role and assign the users, which has been populated with recipients list,
   -- to this role.
   --dbms_output.put_line('l_role_users: ' || l_role_users);
   WF_DIRECTORY.CreateAdHocRole
        (role_users         => l_role_users
    ,role_name          => l_role_name
        ,role_display_name  => l_role_display_name
	,expiration_date => sysdate+1); -- Expiration_date set for bug#5962410

-- dbms_output.put_line('Role Name : ' || l_role_name);
-- dbms_output.put_line('Role Display Name : ' || l_role_display_name);

   -- We now have all the values in local variables
   -- Create the WF process

   --dbms_output.put_line('Process: ' || p_wf_process);
   wf_engine.CreateProcess ( ItemType => p_wf_item_type,
                             ItemKey  => l_itemkey,
                             process  => p_wf_process
                            );

   -- Now set the values as appropriate in the WF attributes

/* Commented for Bug 6144224
   -- Set Role details attributes
   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_NOMINATE_ROLE',
                avalue   => l_role_name
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_DECLINED_ROLE',
                avalue   => l_role_name
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_CANDIDATE_ROLE',
                avalue   => l_role_name
              );
*/
--Added for bug 6144224 to set the Adhoc role
   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_ADHOC_ROLE',
                avalue   => l_role_name
              );

--Added for bug 6144224 to set the final number of recipients
   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'NUMBER_OF_RECIPIENTS',
                avalue   => l_count_recipients
              );

--Added for bug 6144224 to set the loop counter
   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'NF_LOOP_COUNTER',
                avalue   => 0
              );

   -- Set Project details attributes

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_PROJ_NUMBER',
                avalue   => l_projects_rec.segment1
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_PROJ_NAME',
                avalue   => l_projects_rec.name
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_PROJ_ORGANIZATION',
                avalue   => l_projects_rec.organization_name
              );

   IF l_customer_name IS NOT NULL THEN
       wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_PROJ_CUSTOMER',
                avalue   => l_customer_name
              );

   END IF;


   -- Set Assignment related attributes

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_ASGMT_NAME',
                avalue   => l_assignments_rec.assignment_name
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_ASGMT_NAME',
                avalue   => l_assignments_rec.assignment_name
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_ASGMT_DESCRIPTION',
                avalue   => l_assignments_rec.description
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_ADDITIONAL_INFORMATION',
                avalue   => l_assignments_rec.additional_information
              );

   wf_engine.SetItemAttrNumber
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_ASGMT_DURATION',
                avalue   => (trunc(l_assignments_rec.end_date) -
                             trunc(l_assignments_rec.start_date)+1)
              );

   wf_engine.SetItemAttrNumber
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_ASGMT_EFFORT',
                avalue   => l_assignments_rec.assignment_effort
              );

   -- Set resource related attributes

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_CAND_NUMBER',
                avalue   => p_candidate_number
              );

   --dbms_output.put_line('p_status_name' || p_status_name);

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_CAND_STATUS',
                avalue   => p_status_name
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_RESOURCE_NAME',
                avalue   => l_resource_rec.resource_name
              );

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_RESOURCE_ORG',
                avalue   => l_resource_rec.resource_organization_name
              );


   -- Set project manager attributes

   wf_engine.SetItemAttrText
              ( itemtype => p_wf_item_type,
                itemkey  => l_itemkey,
                aname    => 'ATTR_PROJ_MANAGER',
                avalue   => l_proj_mgr_name
              );

   l_asgmt_details_url :=
           'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_ASMT_LAYOUT&paCalledPage=OpenAsmt&addBreadCrumb=RP&paAssignmentId='||p_assignment_id;

   l_resource_details_url :=
           'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_VIEW_RESOURCE_LAYOUT&addBreadCrumb=RP&paResourceId='||p_resource_id;

   wf_engine.SetItemAttrText
      ( itemtype => p_wf_item_type
      , itemkey  => l_itemkey
      , aname    => 'ATTR_ASGMT_DETAILS_URL_INFO'
      , avalue   => l_asgmt_details_url
      );

   wf_engine.SetItemAttrText
     ( itemtype => p_wf_item_type
     , itemkey  =>  l_itemkey
     , aname    => 'ATTR_RESOURCE_DETAILS_URL'
     , avalue   => l_resource_details_url
     );

    -- Now start the WF process
    wf_engine.StartProcess
             ( itemtype => p_wf_item_type,
               itemkey  => l_itemkey );

    -- Insert to PA tables wf process information.
    -- This is required for displaying notifications on PA pages.

    PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'CANDIDATE'
                ,p_item_type           => p_wf_item_type
                ,p_item_key            => l_itemkey
                ,p_entity_key1         => to_char(l_projects_rec.project_id)
                ,p_entity_key2         => to_char(p_assignment_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );


EXCEPTION
 WHEN OTHERS THEN
     -- 4537865 : RESET OUT PARAMS
     X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_CANDIDATE_PUB',
       p_procedure_name => 'Start_Workflow');

     -- 4537865 : RESET OUT PARAMS
     x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index       => 1
         ,p_msg_count       => 1
         ,p_msg_data        => l_msg_data
         ,p_data            => x_msg_data
         ,p_msg_index_out   => l_msg_index_out );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Start_Workflow;



FUNCTION is_active_candidate(p_system_status_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
 IF (p_system_status_code='CANDIDATE_PENDING_REVIEW' OR
     p_system_status_code='CANDIDATE_UNDER_REVIEW' OR
     p_system_status_code='CANDIDATE_SYSTEM_NOMINATED' OR
     p_system_status_code='CANDIDATE_SUITABLE') THEN
    RETURN 'Y';
 ELSE
    RETURN 'N';
 END IF;
END is_active_candidate;



FUNCTION Get_Person_Id
RETURN NUMBER
IS
l_employee_id       NUMBER;
BEGIN
  SELECT employee_id
  INTO l_employee_id
  FROM fnd_user
  where user_id = FND_GLOBAL.USER_ID;

  RETURN l_employee_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Person_Id;



FUNCTION Get_Resource_Name(p_resource_id in NUMBER)
RETURN VARCHAR2
IS
l_resource_name   VARCHAR2(240);
BEGIN
  SELECT distinct(resource_name)
  INTO l_resource_name
  FROM pa_resources_denorm
  WHERE resource_id = p_resource_id
  AND rownum=1 -- 5345135
  ;

  RETURN l_resource_name;
EXCEPTION
  WHEN OTHERS THEN
     l_resource_name := null;
     RETURN l_resource_name;
END Get_Resource_Name;

/* --------------------------------------------------------------------
PROCEDURE: Delete_Candidates
PURPOSE: This procedure is called by the Assignment module, once an
         assignment is deleted, the candidates in that assignment
         should be also deleted accordingly
---------------------------------------------------------------------*/
PROCEDURE Delete_Candidates(p_assignment_id      IN  NUMBER,
                            p_status_code        IN  VARCHAR2 DEFAULT NULL,
                            x_return_status      OUT NOCOPY VARCHAR2, -- 4537865
                            x_msg_count          OUT NOCOPY NUMBER, -- 4537865
                            x_msg_data           OUT NOCOPY VARCHAR2) -- 4537865
IS
   TYPE number_tbl IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

   -- 4537865
   l_msg_data VARCHAR2(2000);
   l_msg_index_out NUMBER ;

   l_candidates_tbl number_tbl;
BEGIN
  -- x_msg_count and x_msg_data are dummy variables, they are
  -- reserved for further expansion of this procedure
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;

  IF p_status_code IS NULL THEN
     SELECT candidate_id
     BULK COLLECT INTO l_candidates_tbl
     FROM pa_candidates
     WHERE assignment_id = p_assignment_id;

     DELETE FROM pa_candidates
     WHERE assignment_id = p_assignment_id;
  ELSE
     SELECT candidate_id
     BULK COLLECT INTO l_candidates_tbl
     FROM pa_candidates
     WHERE assignment_id = p_assignment_id
     AND   status_code = p_status_code;

     DELETE FROM pa_candidates
     WHERE assignment_id = p_assignment_id
     AND   status_code = p_status_code;
  END IF;

  IF l_candidates_tbl.count > 0 THEN
     FORALL i IN l_candidates_tbl.FIRST .. l_candidates_tbl.LAST
       DELETE FROM pa_candidate_reviews
       WHERE candidate_id = l_candidates_tbl(i);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := SUBSTRB(SQLERRM,1,240) ;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_CANDIDATE_PUB',
       p_procedure_name => 'Delete_Candidates',
       p_error_text     => x_msg_data);

        -- 4537865 : RESET OUT PARAMS
        x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index       => 1
         ,p_msg_count       => 1
         ,p_msg_data        => l_msg_data
         ,p_data            => x_msg_data
         ,p_msg_index_out   => l_msg_index_out );
     END IF;

        RAISE;
End Delete_Candidates;

/* --------------------------------------------------------------------
PROCEDURE: Withdraw_Candidate
PURPOSE: This procedure removes a candidate from an assignment
---------------------------------------------------------------------*/

PROCEDURE Withdraw_Candidate (p_candidate_id        IN  NUMBER,
                              x_return_status       OUT NOCOPY VARCHAR2, -- 4537865 : Added nocopy hint
                              x_msg_count           OUT NOCOPY NUMBER, -- 4537865 : Added nocopy hint
                              x_msg_data            OUT NOCOPY VARCHAR2) -- 4537865 : Added nocopy hint
IS
   l_no_of_active_candidates      NUMBER;
   l_record_version_number        NUMBER;
   l_system_status_code           VARCHAR2(30);
   l_assignment_id                NUMBER;
   l_return_status                VARCHAR2(1);

    -- 4537865
   l_msg_data VARCHAR2(2000);
   l_msg_index_out NUMBER;
BEGIN
  -- x_msg_count and x_msg_data are dummy variables, they are
  -- reserved for further expansion of this procedure

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;

  SELECT asmt.no_of_active_candidates,
         asmt.record_version_number,
         ps.project_system_status_code,
         asmt.assignment_id
  INTO   l_no_of_active_candidates,
         l_record_version_number,
         l_system_status_code,
         l_assignment_id
  FROM   pa_project_assignments asmt,
         pa_candidates cand,
         pa_project_statuses ps
  WHERE  asmt.assignment_id = cand.assignment_id
  AND    candidate_id = p_candidate_id
  AND    cand.status_code = ps.project_status_code
  AND    ps.status_type = 'CANDIDATE';

  DELETE FROM pa_candidate_reviews
  WHERE  candidate_id = p_candidate_id;

  DELETE FROM pa_candidates
  WHERE  candidate_id = p_candidate_id;

  IF (is_active_candidate(l_system_status_code)='Y') THEN
     pa_project_assignments_pkg.Update_row(
                                p_assignment_id           => l_assignment_id,
                                p_no_of_active_candidates => l_no_of_active_candidates-1,
                                p_record_version_number   => l_record_version_number,
                                x_return_status           => l_return_status );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- 4537865 : RESET OUT PARAMS
        x_msg_data := SUBSTRB(SQLERRM,1,240) ;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_CANDIDATE_PUB',
       p_procedure_name => 'Withdraw_Candidate',
       p_error_text     => x_msg_data);

        -- 4537865 : RESET OUT PARAMS
        x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index       => 1
         ,p_msg_count       => 1
         ,p_msg_data        => l_msg_data
         ,p_data            => x_msg_data
         ,p_msg_index_out   => l_msg_index_out );
     END IF;
       RAISE;
END Withdraw_Candidate;

/* --------------------------------------------------------------------
FUNCTION: Copy_Candidates
PURPOSE:  This API will be called when a requirement is partially filled.
          A new requirement will be created as a result of the partial
          fulfillment of the original requirement. This new requirment
          should have all the candidates (of the original requirement) who
          are effective as of the start date of the new requirement.
          This API is not expected to return any expected errors.
PARAMETERS: p_old_requirement_id : Assignment_id of the old requirement
            p_new_requirement_id : Assignment_id of the new requirement
            p_new_start_date     : Start Date of the new requirement
-------------------------------------------------------------------- */
PROCEDURE Copy_Candidates(p_old_requirement_id IN  NUMBER,
                          p_new_requirement_id IN  NUMBER,
                          p_new_start_date     IN  DATE,
                          x_return_status      OUT NOCOPY VARCHAR2,  -- 4537865 : Added nocopy hint
                          x_msg_count          OUT NOCOPY NUMBER,  -- 4537865 : Added nocopy hint
                          x_msg_data           OUT NOCOPY VARCHAR2)  -- 4537865 : Added nocopy hint
IS
l_old_candidate_id             NUMBER;
l_new_candidate_id             NUMBER;
l_no_of_active_candidates      NUMBER;
l_record_version_number        NUMBER;
l_return_status                VARCHAR2(1);

cursor c1 is
SELECT cand.candidate_id,
       cand.resource_id,
       cand.status_code,
       cand.nominated_by_person_id,
       cand.nomination_date,
       cand.nomination_comments,
       cand.candidate_ranking
FROM   pa_candidates cand,
       pa_resources_denorm res
WHERE assignment_id = p_old_requirement_id
AND   p_new_start_date BETWEEN
                           res.resource_effective_start_date AND
                           NVL(res.resource_effective_end_date, sysdate+1)
AND res.resource_id = cand.resource_id
AND res.schedulable_flag = 'Y';

cursor c3 is
SELECT status_code,
       reviewer_person_id,
       review_date,
       change_reason_code,
       review_comments
FROM pa_candidate_reviews
WHERE candidate_id = l_old_candidate_id;

  -- 4537865
l_msg_data VARCHAR2(2000);
l_msg_index_out NUMBER ;

BEGIN

   -- 4537865 : INITIALIZE OUT PARAMS

   l_return_status := FND_API.G_RET_STS_SUCCESS; -- At the end we will assign l_return_status to x_return_status
   x_msg_count := 0;
   x_msg_data := null;

   FOR c2 in c1 LOOP
       l_old_candidate_id := c2.candidate_id;

       -- Insert into the candidate table.
       INSERT INTO PA_CANDIDATES
           (CANDIDATE_ID,
            ASSIGNMENT_ID,
            RESOURCE_ID,
            RECORD_VERSION_NUMBER,
            STATUS_CODE,
            NOMINATED_BY_PERSON_ID,
            NOMINATION_DATE,
            NOMINATION_COMMENTS,
            CANDIDATE_RANKING,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY)
       VALUES
           (PA_CANDIDATES_S.nextval,
            p_new_requirement_id,
            c2.resource_id,
            1,
            c2.status_code,
            c2.nominated_by_person_id,
            c2.nomination_date,
            c2.nomination_comments,
            c2.candidate_ranking,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID)
       RETURNING
           CANDIDATE_ID into l_new_candidate_id;

       FOR c4 in c3 LOOP
           INSERT INTO PA_CANDIDATE_REVIEWS
                 (CANDIDATE_REVIEW_ID,
                  CANDIDATE_ID,
                  RECORD_VERSION_NUMBER,
                  STATUS_CODE,
                  REVIEWER_PERSON_ID,
                  REVIEW_DATE,
                  CHANGE_REASON_CODE,
                  REVIEW_COMMENTS,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY)
           VALUES
                 (
                  PA_CANDIDATE_REVIEWS_S.nextval,
                  l_new_candidate_id,
                  1,
                  c4.status_code,
                  c4.reviewer_person_id,
                  c4.review_date,
                  c4.change_reason_code,
                  c4.review_comments,
                  sysdate,
                  FND_GLOBAL.user_id,
                  sysdate,
                  FND_GLOBAL.user_id
                 );
           END LOOP;
   END LOOP;

   -- Update No_of_Active_Candidates attribute for the new
   -- requirement.

   -- get no_of_active_candidates from the previous requirement
   SELECT no_of_active_candidates
   INTO l_no_of_active_candidates
   FROM pa_project_assignments
   WHERE assignment_id = p_old_requirement_id;

   -- get record_version_number for the passed new requirement id

   SELECT record_version_number
   INTO l_record_version_number
   FROM pa_project_assignments
   WHERE assignment_id = p_new_requirement_id;

   IF l_no_of_active_candidates is not null AND
       l_no_of_active_candidates > 0 THEN

       pa_project_assignments_pkg.Update_row(
          p_assignment_id           => p_new_requirement_id,
          p_no_of_active_candidates => l_no_of_active_candidates,
          p_record_version_number   => l_record_version_number,
          x_return_status           => l_return_status );

   END IF;

   -- 4537865
   x_return_status := l_return_status ;

EXCEPTION
 WHEN OTHERS THEN
	 -- 4537865 : RESET OUT PARAMS
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_data := SUBSTRB(SQLERRM,1,240) ;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_CANDIDATE_PUB',
       p_procedure_name => 'Copy_Candidates');

        x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index       => 1
         ,p_msg_count       => 1
         ,p_msg_data        => l_msg_data
         ,p_data            => x_msg_data
         ,p_msg_index_out   => l_msg_index_out );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Copy_Candidates;

/*-------------------------------------------------------------------------
PROCEDURE: Decline_Candidates
PURPOSE: When a requirement is cancelled, all ACTIVE candidates attached to
         it must be declined. A decline notification should be sent to all
         candidates. If p_launch_wf is 'N', then the workflow process will
         not be launched, it is used in the upgrade script.
-------------------------------------------------------------------------*/
PROCEDURE Decline_Candidates(p_assignment_id      IN  NUMBER,
                             p_launch_wf          IN  VARCHAR2 DEFAULT 'Y',
                             x_return_status      OUT NOCOPY VARCHAR2,   -- 4537865
                             x_msg_count          OUT NOCOPY NUMBER,   -- 4537865
                             x_msg_data           OUT NOCOPY VARCHAR2)   -- 4537865
IS
   TYPE number_tbl IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

   l_candidate_id_tbl           number_tbl;
   l_resource_id_tbl            number_tbl;
   l_record_version_number_tbl  number_tbl;
   l_asmt_record_version_number NUMBER;
   l_reviewer_person_id         NUMBER;
   l_decline_status_code        VARCHAR2(30);
   l_decline_status_name        VARCHAR2(80);
   l_enable_wf_flag             VARCHAR2(1);
   l_wf_item_type               VARCHAR2(30);
   l_wf_process                 VARCHAR2(30);
   l_return_status              VARCHAR2(1);
   l_msg_data                   VARCHAR2(2000);
   l_msg_count                  NUMBER := 0;
   l_save                       boolean;

-- 4537865
l_msg_index_out NUMBER ;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_msg_data := null;

   -- Gather the candidate_ids that needs to be declined
   SELECT candidate_id,
          resource_id,
          record_version_number
   BULK COLLECT INTO
          l_candidate_id_tbl,
          l_resource_id_tbl,
          l_record_version_number_tbl
   FROM   pa_candidates cand,
          pa_project_statuses status
   WHERE  cand.assignment_id = p_assignment_id
   AND    cand.status_code = status.project_status_code
   AND    status.project_system_status_code IN ('CANDIDATE_PENDING_REVIEW',
          'CANDIDATE_UNDER_REVIEW', 'CANDIDATE_SYSTEM_NOMINATED', 'CANDIDATE_SUITABLE')
   AND    status.status_type = 'CANDIDATE';

   l_decline_status_code := FND_PROFILE.value('PA_CNL_REQ_CAND_STATUS');

   --dbms_output.put_line('Log: Candidate Status Code ' || l_decline_status_code);

   -- If the status code from the profile option is null,
   -- we need to set the default value to '110' - the status code
   -- we ship for 'CANDIDATE_DECLINDED' system status

   IF l_decline_status_code IS NULL THEN
      l_decline_status_code := '110';

      --dbms_output.put_line('Save profile option');
      l_save := FND_PROFILE.SAVE (X_NAME       => 'PA_CNL_REQ_CAND_STATUS'
                                 ,X_VALUE      => l_decline_status_code
                                 ,X_LEVEL_NAME => 'SITE');
      --IF l_save THEN
      --   dbms_output.put_line('l_save = ' || ' TRUE');
      --ELSE dbms_output.put_line('l_save = ' || ' FALSE');
      --END IF;
   END IF;

   IF l_candidate_id_tbl.count > 0 THEN

      SELECT project_status_name,
             enable_wf_flag,
             workflow_item_type,
             workflow_process
      INTO   l_decline_status_name,
             l_enable_wf_flag,
             l_wf_item_type,
             l_wf_process
      FROM   pa_project_statuses
      WHERE  project_status_code = l_decline_status_code
      AND    status_type = 'CANDIDATE';

      l_reviewer_person_id := Get_Person_Id;

      --dbms_output.put_line ('status_code: ' || l_decline_status_code);
      --dbms_output.put_line ('Status_name: ' || l_decline_status_name);
      --dbms_output.put_line ('wf_item_type ' || l_wf_item_type || ' l_wf_process ' || l_wf_process || ' decline status_name ' || l_decline_status_name);

      FOR i in l_candidate_id_tbl.FIRST .. l_candidate_id_tbl.LAST LOOP
          --dbms_output.put_line ('candidate id to be declined: ' || l_candidate_id_tbl(i));
          --dbms_output.put_line ('resource id to be declined: ' || l_resource_id_tbl(i));

          -- Added WHO Column update. Bug 7168412.
          UPDATE pa_candidates SET
                 status_code = l_decline_status_code,
                 record_version_number = l_record_version_number_tbl(i) + 1,
		             LAST_UPDATE_DATE      = SYSDATE,
                 LAST_UPDATED_BY       = FND_GLOBAL.USER_ID
          WHERE  candidate_id = l_candidate_id_tbl(i);

          -- Change reason code is not supplied in this case

          INSERT INTO PA_CANDIDATE_REVIEWS
             (CANDIDATE_REVIEW_ID,
              CANDIDATE_ID,
              RECORD_VERSION_NUMBER,
              STATUS_CODE,
              REVIEWER_PERSON_ID,
              REVIEW_DATE,
              REVIEW_COMMENTS,
              CHANGE_REASON_CODE,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
          VALUES
             (PA_CANDIDATE_REVIEWS_S.nextval,
              l_candidate_id_tbl(i),
              1,
              l_decline_status_code,
              l_reviewer_person_id,
              sysdate,
              null,
              null,
              sysdate,
              FND_GLOBAL.user_id,
              sysdate,
              FND_GLOBAL.user_id
             );

          IF p_launch_wf = 'Y' AND l_enable_wf_flag = 'Y' AND
             l_wf_item_type IS NOT NULL AND l_wf_process IS NOT NULL THEN

             Start_Workflow(p_wf_item_type      => l_wf_item_type,
                            p_wf_process        => l_wf_process,
                            p_assignment_id     => p_assignment_id,
                            p_candidate_number  => l_candidate_id_tbl(i),
                            p_resource_id       => l_resource_id_tbl(i),
                            p_status_name       => l_decline_status_name,
                            x_return_status     => l_return_status,
                            x_msg_count         => l_msg_count,
                            x_msg_data          => l_msg_data);
          END IF;

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END LOOP;

      SELECT record_version_number
      INTO   l_asmt_record_version_number
      FROM   pa_project_assignments
      WHERE  assignment_id = p_assignment_id;

      pa_project_assignments_pkg.Update_row(p_assignment_id           => p_assignment_id,
                                            p_no_of_active_candidates => 0,
                                            p_record_version_number   => l_asmt_record_version_number,
                                            x_return_status           => l_return_status );

     -- 4537865 : The following statement was missing
     x_return_status := l_return_status ;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	--4537865
       x_msg_data := SUBSTRB(SQLERRM,1,240) ;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_CANDIDATE_PUB',
       p_procedure_name => 'Decline_Candidates');

        x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index       => 1
         ,p_msg_count       => 1
         ,p_msg_data        => l_msg_data
         ,p_data            => x_msg_data
         ,p_msg_index_out   => l_msg_index_out );
     END IF;

        RAISE;
END Decline_Candidates;


/*-------------------------------------------------------------------------
PROCEDURE: Get_NF_Recipient
PURPOSE: Called from PA Candidate Notification Process workflow (PARCANDD.wft).
         This procedure is called in loop to send individual notifications to
         all people involved while candidate nomination process.
         ( Resource + Res Mgr + Primary Cont + Staffing Owner )
-------------------------------------------------------------------------*/
PROCEDURE Get_NF_Recipient (itemtype IN VARCHAR2
                          , itemkey IN VARCHAR2
                          , actid IN NUMBER
                          , funcmode IN VARCHAR2
                          , resultout OUT NOCOPY VARCHAR2 )
IS

l_number_of_nf_rects   NUMBER := 0;
l_nf_loop_counter      NUMBER := 0;
user_table             Wf_Directory.UserTable;
l_role_name            VARCHAR2(320);
l_role_name_temp       VARCHAR2(320);

BEGIN
/*
 First , get item attr NF_LOOP_COUNTER and NUMBER_OF_RECIPIENTS
   then do NF_LOOP_COUNTER := NF_LOOP_COUNTER + 1;
   If NF_LOOP_COUNTER > NUMBER_OF_RECIPIENTS , resultout = 'F'
     and return
   Else
     Get individual PER role, set role attributes for notification,
     Resultout = 'S'
   end
*/

 -- Return if WF Not Running
           IF (funcmode <> wf_engine.eng_run) THEN
               resultout := wf_engine.eng_null;
               RETURN;
           END IF;

-- Get total number of recipients
           l_number_of_nf_rects := wf_engine.GetItemAttrNumber
                               (  itemtype => itemtype
                                , itemkey =>  itemkey
                               , aname => 'NUMBER_OF_RECIPIENTS'
                               );

-- Get loop counter value
           l_nf_loop_counter := wf_engine.getItemAttrNumber
                               (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NF_LOOP_COUNTER'
                               );

-- Get adhoc role created for nitifications
                 l_role_name := wf_engine.getItemAttrText
                               (  itemtype => itemtype
                                , itemkey  => itemkey
                                , aname    => 'ATTR_ADHOC_ROLE'
                               );


         l_nf_loop_counter := l_nf_loop_counter + 1;

         IF l_nf_loop_counter > l_number_of_nf_rects THEN

          resultout := wf_engine.eng_completed||':'||'F';
         RETURN;
         END IF;

-- Get all users attached to Adhoc role
         WF_DIRECTORY.GETROLEUSERS(l_role_name, user_table);

-- Get PER role for the 'nth' user from WF_USER_ROLES
         SELECT ROLE_NAME
         INTO  l_role_name_temp
         FROM WF_USER_ROLES
         WHERE  USER_NAME  = user_table(l_nf_loop_counter)
         AND USER_ORIG_SYSTEM = 'PER'
         AND ROLE_ORIG_SYSTEM = 'PER'
         AND ROWNUM = 1;

-- Set the notification roles for the 'nth' user
         wf_engine.SetItemAttrText
           ( itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'ATTR_NOMINATE_ROLE',
                avalue   => l_role_name_temp
              );

         wf_engine.SetItemAttrText
              ( itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'ATTR_DECLINED_ROLE',
                avalue   => l_role_name_temp
              );

         wf_engine.SetItemAttrText
              ( itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'ATTR_CANDIDATE_ROLE',
                avalue   => l_role_name_temp
              );

-- Set the incremented loop counter value
        wf_engine.SetItemAttrText
              ( itemtype => itemtype,
               itemkey  => itemkey,
                aname    => 'NF_LOOP_COUNTER',
                avalue   => l_nf_loop_counter
              );
       resultout := wf_engine.eng_completed||':'||'S';


EXCEPTION
  WHEN OTHERS THEN
        WF_CORE.CONTEXT
                ('PA_CANDID_PUB',
                 'Get_NF_Recipient',
                  itemtype,
                  itemkey,
                  to_char(actid),
                  funcmode);
  RAISE;
END Get_NF_Recipient;

/* --------------------------------------------------------------------
 *  * FUNCTION: Get_Review_Change_Reason
 *   * PURPOSE: Get the latest change reason code for a candidate given
 *    *          the candidate_id
 *     * -------------------------------------------------------------------- */
FUNCTION Get_Review_Change_Reason(p_candidate_id IN NUMBER)
RETURN VARCHAR2
IS
l_change_reason_code VARCHAR2(30);
BEGIN

  SELECT change_reason_code
  INTO l_change_reason_code
  FROM (SELECT change_reason_code
        FROM PA_CANDIDATE_REVIEWS
        WHERE candidate_id =p_candidate_id
        ORDER BY review_date DESC)
  WHERE rownum = 1;

  RETURN l_change_reason_code;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END Get_Review_Change_Reason;

END PA_CANDIDATE_PUB;

/
