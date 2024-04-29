--------------------------------------------------------
--  DDL for Package PA_COMPETENCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COMPETENCE_PUB" AUTHID CURRENT_USER AS
-- $Header: PACOMPPS.pls 120.1 2005/08/19 16:20:22 mwasowic noship $

--
--  PROCEDURE
--              Add_Competence_Element
--  PURPOSE
--              This procedure creates the competence elements for
--		a project role or an open assignment
--  HISTORY
--   11-JUL-2000  R. Krishnamurthy   Created
--
PROCEDURE Add_competence_element
( p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
p_object_id	    IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
p_competence_id	    IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias  IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name   IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_rating_level_id   IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
p_mandatory_flag    IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
p_init_msg_list	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_commit	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_validate_only	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
x_element_rowid	    OUT NOCOPY ROWID, --File.Sql.39 bug 4440895
x_element_id	    OUT NOCOPY per_competence_elements.competence_element_id%TYPE, --File.Sql.39 bug 4440895
x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count	    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_msg_data	    OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Update_competence_element
(p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
 p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name  IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
 p_element_rowid   IN ROWID := FND_API.G_MISS_CHAR,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_value IN per_rating_levels.step_value%TYPE := FND_API.G_MISS_NUM,
 p_mandatory_flag  IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_version_number IN NUMBER,
 x_object_version_number OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count	   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data	   OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE delete_competence_element
(p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
 p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_alias IN per_competences.competence_alias%TYPE := FND_API.G_MISS_CHAR,
 p_competence_name IN per_competences.name%TYPE := chr(0),
 p_element_rowid   IN ROWID := FND_API.G_MISS_CHAR,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_version_number IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count	  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data	  OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE standard_pub_checks
(
p_element_id       IN NUMBER := null,
p_object_name      IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
p_object_id	  IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
p_competence_id	   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name  IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_rating_level_id  IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
p_operation         IN  VARCHAR2,
x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_competence_id     OUT NOCOPY per_competences.competence_id%TYPE, --File.Sql.39 bug 4440895
x_rating_level_id   OUT NOCOPY per_competence_elements.rating_level_id%TYPE ) ; --File.Sql.39 bug 4440895

PROCEDURE Mass_Exec_Process_Competences
( p_asgn_update_mode            IN  VARCHAR2 := FND_API.G_MISS_CHAR
 ,p_project_id                  IN  pa_project_assignments.project_id%TYPE
 ,p_assignment_id_tbl           IN  SYSTEM.pa_num_tbl_type
 ,p_competence_id_tbl           IN  SYSTEM.pa_num_tbl_type
 ,p_competence_name_tbl         IN  SYSTEM.pa_varchar2_240_tbl_type
 ,p_competence_alias_tbl        IN  SYSTEM.pa_varchar2_30_tbl_type
 ,p_rating_level_id_tbl         IN  SYSTEM.pa_num_tbl_type
 ,p_rating_level_value_tbl      IN  SYSTEM.pa_num_tbl_type
 ,p_mandatory_flag_tbl          IN  SYSTEM.pa_varchar2_1_tbl_type
 ,p_init_msg_list               IN  VARCHAR2  := FND_API.G_FALSE
 ,p_commit                      IN  VARCHAR2  := FND_API.G_FALSE
 ,p_validate_only               IN  VARCHAR2  := FND_API.G_TRUE
 ,p_max_msg_count               IN  NUMBER    := FND_API.G_MISS_NUM
 ,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Mass_Process_Competences
  ( p_project_id                 IN  pa_project_assignments.project_id%TYPE,
  p_assignment_tbl               IN  SYSTEM.pa_num_tbl_type,
  p_competence_id_tbl            IN  SYSTEM.pa_num_tbl_type,
  p_competence_name_tbl          IN  SYSTEM.pa_varchar2_240_tbl_type,
  p_competence_alias_tbl         IN  SYSTEM.pa_varchar2_30_tbl_type,
  p_rating_level_id_tbl          IN  SYSTEM.pa_num_tbl_type,
  p_mandatory_flag_tbl           IN  SYSTEM.pa_varchar2_1_tbl_type,
  p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE,
  p_validate_only                IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                       IN  VARCHAR2 := FND_API.G_FALSE,
  x_success_assignment_id_tbl    OUT NOCOPY SYSTEM.pa_num_tbl_type,    /* Added NOCOPY for bug#2674619 */
  x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end pa_competence_pub ;
 

/
