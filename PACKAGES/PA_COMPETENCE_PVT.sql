--------------------------------------------------------
--  DDL for Package PA_COMPETENCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COMPETENCE_PVT" AUTHID CURRENT_USER AS
-- $Header: PACOMPVS.pls 120.1 2005/08/19 16:20:31 mwasowic noship $

--
--  PROCEDURE
--              Add_Competence_Element
--  PURPOSE
--              This procedure creates the competence elements for
--		a project role or an open assignment
--  HISTORY
--   24-JUL-2000      R. Krishnamurthy       Created
--
	g_noof_errors  NUMBER := 0;

PROCEDURE Add_competence_element
	( p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
	--p_object_id	    IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
	p_object_id	        IN PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
	p_project_id        IN pa_project_assignments.project_id%TYPE := FND_API.G_MISS_NUM,
	p_competence_id	    IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
	p_rating_level_id   IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
	p_mandatory_flag    IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
	p_commit	          IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_validate_only	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_init_msg_list	    IN VARCHAR2 := FND_API.G_FALSE,
	x_element_rowid	    OUT NOCOPY ROWID, --File.Sql.39 bug 4440895
	x_element_id	      OUT NOCOPY per_competence_elements.competence_element_id%TYPE, --File.Sql.39 bug 4440895
	x_return_status	    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Update_competence_element
(p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
 p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_element_rowid   IN ROWID := FND_API.G_MISS_CHAR,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
 p_mandatory_flag  IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
 p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
 p_object_version_number IN NUMBER,
 x_object_version_number OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_return_status   OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE delete_competence_element
	(p_object_name          IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
	p_object_id	            IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
	p_competence_id         IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
	p_element_rowid         IN ROWID := FND_API.G_MISS_CHAR,
	p_element_id	          IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
	p_commit	              IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_validate_only         IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
	p_object_version_number IN NUMBER,
	x_return_status         OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Check_Element_id
	(p_object_name        IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
	p_object_id	          IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
	p_competence_id       IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
	p_element_id	        IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
	x_effective_date_from OUT NOCOPY per_competence_elements.effective_date_from%TYPE , --File.Sql.39 bug 4440895
	x_return_status       OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
	x_error_message_code  OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Check_Error (p_return_status      IN VARCHAR2,
											 p_error_message_code IN VARCHAR2) ;

PROCEDURE Check_Object_version_number
	(p_element_id            IN per_competence_elements.competence_element_id%TYPE,
	 p_object_version_number IN NUMBER,
	 x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_error_message_code    OUT NOCOPY VARCHAR2)  ; --File.Sql.39 bug 4440895

end pa_competence_PVT ;
 

/
