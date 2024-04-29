--------------------------------------------------------
--  DDL for Package PA_CANDIDATE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CANDIDATE_UTILS" AUTHID CURRENT_USER AS
-- $Header: PARCANUS.pls 120.1 2005/08/19 16:49:19 mwasowic noship $

TYPE requirements_tbl IS TABLE OF NUMBER index by binary_integer;

FUNCTION Get_Active_Candidates_Number(p_assignment_id IN NUMBER)
RETURN NUMBER;

FUNCTION Get_Requirements_Of_Candidate (p_resource_id IN NUMBER)
RETURN requirements_tbl;

FUNCTION Get_Resource_Id(p_person_id IN NUMBER)
RETURN NUMBER;

FUNCTION Check_Resource_Is_Candidate(p_resource_id   IN NUMBER,
                                     p_assignment_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE Reverse_Candidate_Status
(p_assignment_id       IN NUMBER,
 p_resource_id         IN NUMBER,
 x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_error_message_code  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

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
RETURN NUMBER;

FUNCTION Get_Nominator_Name(p_nominated_by_person_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Candidate_Nominations (p_resource_id IN NUMBER)
RETURN NUMBER;

FUNCTION Get_Candidate_Qualifieds (p_resource_id IN NUMBER)
RETURN NUMBER;

PROCEDURE Update_No_Of_Active_Candidates
(p_assignment_id       IN NUMBER,
 x_return_status       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end PA_CANDIDATE_UTILS ;
 

/
