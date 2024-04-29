--------------------------------------------------------
--  DDL for Package PA_COMP_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COMP_PROFILE_PVT" AUTHID CURRENT_USER AS
-- $Header: PARPRFVS.pls 120.1 2005/08/19 16:59:07 mwasowic noship $

g_noof_errors  NUMBER := 0;
PROCEDURE Add_competence_element
( p_person_id	    IN per_competence_elements.person_id%TYPE,
p_competence_id	    IN per_competences.competence_id%TYPE,
p_rating_level_id   IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_effective_date_from   IN DATE,
p_commit	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_validate_only	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_init_msg_list	    IN VARCHAR2 := FND_API.G_FALSE,
x_return_status	    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Update_competence_element
(p_person_id       IN per_competence_elements.person_id%TYPE := FND_API.G_MISS_NUM ,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
 p_effective_date_from   IN DATE,
 p_commit	         IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only         IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
 p_object_version_number IN NUMBER,
 x_object_version_number OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_return_status         OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

Procedure delete_competence_element
          ( p_person_id             IN NUMBER,
            p_competence_id         IN NUMBER,
            p_element_id            IN NUMBER,
            p_object_version_number IN NUMBER,
            p_commit	            IN VARCHAR2 := FND_API.G_MISS_CHAR,
            x_return_status        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Check_Object_version_number
   (p_element_id  IN per_competence_elements.competence_element_id%TYPE,
    p_object_version_number IN  NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_error_message_code    OUT NOCOPY VARCHAR2)  ; --File.Sql.39 bug 4440895

Procedure Start_Approval_Process
(x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Check_Error
(p_return_status      IN VARCHAR2,
 p_error_message_code IN VARCHAR2);

PROCEDURE Update_HR
(p_profile_id    IN  NUMBER,
 x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

Procedure Approval_Message_Body
(document_id   in varchar2,
display_type   in varchar2,
document       in out NOCOPY varchar2,  --File.Sql.39 bug 4440895
document_type  in out NOCOPY varchar2); --File.Sql.39 bug 4440895

Procedure Clear_Temp_Table
(p_profile_id    IN NUMBER,
x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_msg_data      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end PA_COMP_PROFILE_PVT ;
 

/
