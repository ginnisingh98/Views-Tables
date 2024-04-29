--------------------------------------------------------
--  DDL for Package PA_HR_COMPETENCE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_COMPETENCE_UTILS" AUTHID CURRENT_USER AS
-- $Header: PACOMUTS.pls 120.1 2005/08/19 16:20:40 mwasowic noship $

--
--  PROCEDURE
--              Check_Rating_Level_Or_Id
--  PURPOSE
--              This procedure does the following
--              If Rating Level (Step Value) is passed converts it to the id
--		If Rating Level id is passed,
--		based on the check_id_flag validates it
--  HISTORY
--   27-JUN-2000      R. Krishnamurthy       Created
--   17-NOV-2000      R. Fadia
--                    Verified that the file can be used in Self-Service Apps.
--                    It has not global variables
--
TYPE competency_rec_typ IS RECORD
(object_id                   per_competence_elements.object_id%TYPE,
 competence_id               per_competences.competence_id%TYPE,
 rating_level_id	     per_competence_elements.rating_level_id%TYPE,
 competence_element_id	     per_competence_elements.competence_element_id%TYPE,
 row_id			     ROWID,
 mandatory       	     per_competence_elements.mandatory%TYPE,
 competence_name             per_competences.name%TYPE,
 competence_alias            per_competences.competence_alias%TYPE,
 global_flag                 VARCHAR2(1),
 object_version_number	     per_competence_elements.object_version_number%TYPE
);

TYPE competency_tbl_typ IS TABLE OF competency_rec_typ
        INDEX BY BINARY_INTEGER;

procedure Check_Rating_Level_Or_Id
    ( p_competence_id    IN per_competences.competence_id%TYPE
    ,p_rating_level_id   IN per_rating_levels.rating_level_id%TYPE
    ,p_rating_level      IN per_rating_levels.step_value%TYPE
    ,p_check_id_flag IN VARCHAR2
    ,x_rating_level_id  OUT NOCOPY per_rating_levels.rating_level_id%TYPE --File.Sql.39 bug 4440895
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Check_CompName_Or_Id
          ( p_competence_id      IN per_competences.competence_id%TYPE
           ,p_competence_alias   IN per_competences.competence_alias%TYPE
           ,p_competence_name    IN per_competences.name%TYPE := null
           ,p_check_id_flag      IN VARCHAR2
           ,x_competence_id     OUT NOCOPY per_competences.competence_id%TYPE --File.Sql.39 bug 4440895
           ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_error_msg_code OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE Get_KFF_Structure_Num
    (p_competency_structure_type IN VARCHAR2
     ,p_business_group_id       IN NUMBER
     ,x_kff_structure_num      OUT NOCOPY fnd_id_flex_structures_vl.id_flex_num%TYPE --File.Sql.39 bug 4440895
     ,x_return_status	       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_error_message_code      OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Get_KFF_SegmentInfo
 ( p_kff_structure_num    IN fnd_id_flex_structures_vl.id_flex_num%TYPE
  ,x_segment_name1   OUT NOCOPY fnd_id_flex_segments_vl.segment_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_prompt1 OUT NOCOPY fnd_id_flex_segments_vl.form_left_prompt%TYPE --File.Sql.39 bug 4440895
  ,x_column_name1    OUT NOCOPY fnd_id_flex_segments_vl.application_column_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_number1 OUT NOCOPY fnd_id_flex_segments_vl.segment_num%TYPE --File.Sql.39 bug 4440895
  ,x_value_set_id1   OUT NOCOPY fnd_id_flex_segments_vl.flex_value_set_id%TYPE --File.Sql.39 bug 4440895
  ,x_segment_name2   OUT NOCOPY fnd_id_flex_segments_vl.segment_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_prompt2 OUT NOCOPY fnd_id_flex_segments_vl.form_left_prompt%TYPE --File.Sql.39 bug 4440895
  ,x_column_name2    OUT NOCOPY fnd_id_flex_segments_vl.application_column_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_number2 OUT NOCOPY fnd_id_flex_segments_vl.segment_num%TYPE --File.Sql.39 bug 4440895
  ,x_value_set_id2   OUT NOCOPY fnd_id_flex_segments_vl.flex_value_set_id%TYPE --File.Sql.39 bug 4440895
  ,x_segment_name3   OUT NOCOPY fnd_id_flex_segments_vl.segment_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_prompt3 OUT NOCOPY fnd_id_flex_segments_vl.form_left_prompt%TYPE --File.Sql.39 bug 4440895
  ,x_column_name3    OUT NOCOPY fnd_id_flex_segments_vl.application_column_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_number3 OUT NOCOPY fnd_id_flex_segments_vl.segment_num%TYPE --File.Sql.39 bug 4440895
  ,x_value_set_id3   OUT NOCOPY fnd_id_flex_segments_vl.flex_value_set_id%TYPE --File.Sql.39 bug 4440895
  ,x_error_message_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status	 OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE get_competencies
   ( p_object_name	IN	per_competence_elements.object_name%TYPE
    ,p_object_id	IN	per_competence_elements.object_id%TYPE
    ,x_competency_tbl	OUT	NOCOPY competency_tbl_typ /* Added NOCOPY for bug#2674619 */
    ,x_no_of_competencies	OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_error_message_code	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_return_status	OUT	NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE get_person_competencies
   ( p_person_id                 IN  NUMBER
    ,x_competency_tbl           OUT  NOCOPY competency_tbl_typ /* Added NOCOPY for bug#2674619 */
    ,x_no_of_competencies       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_error_message_code       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_return_status            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION check_competence_exists
   ( p_object_name	IN	per_competence_elements.object_name%TYPE
    ,p_object_id	IN	per_competence_elements.object_id%TYPE
    ,p_competence_id    IN      per_competences.competence_id%TYPE )
    RETURN VARCHAR2 ;
    PRAGMA RESTRICT_REFERENCES (check_competence_exists , WNPS , WNDS);

FUNCTION Get_Res_competences
   ( p_person_id        IN      pa_resources_denorm.person_id%TYPE )
    RETURN VARCHAR2;

FUNCTION Get_Res_Competences_Count
   ( p_person_id        IN      pa_resources_denorm.person_id%TYPE)
    RETURN NUMBER;

FUNCTION Get_Res_Comp_Last_Updated
   ( p_person_id        IN      pa_resources_denorm.person_id%TYPE)
    RETURN DATE;

FUNCTION Get_Req_Competences
   ( p_assignment_id    IN      pa_project_assignments.assignment_id%TYPE)
    RETURN VARCHAR2;

end pa_hr_competence_utils ;

 

/
