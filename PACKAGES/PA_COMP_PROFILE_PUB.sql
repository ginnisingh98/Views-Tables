--------------------------------------------------------
--  DDL for Package PA_COMP_PROFILE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COMP_PROFILE_PUB" AUTHID CURRENT_USER AS
-- $Header: PARPRFPS.pls 120.1 2005/08/19 16:59:02 mwasowic noship $

PROCEDURE Add_competence_element
(
p_person_id	    IN per_competence_elements.person_id%TYPE,
p_competence_id	    IN per_competences.competence_id%TYPE,
p_competence_alias  IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name   IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_rating_level_id   IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
p_effective_date_from IN DATE := FND_API.G_MISS_DATE,
p_init_msg_list	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_commit	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_validate_only	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count	    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_msg_data	    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_competence_element
(
p_person_id         IN per_competence_elements.person_id%TYPE     := FND_API.G_MISS_NUM,
p_competence_id     IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias  IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name   IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_element_id	    IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id  IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE := FND_API.G_MISS_NUM,
p_effective_date_from IN DATE := FND_API.G_MISS_DATE,
p_init_msg_list    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_validate_only    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_object_version_number IN NUMBER,
x_object_version_number OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_msg_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

Procedure Start_Approval_Process
(x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE delete_competence_element
(p_person_id      IN per_competence_elements.person_id%TYPE  := FND_API.G_MISS_NUM,
 p_competence_id  IN per_competence_elements.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_element_id     IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_init_msg_list         IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_commit                IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only         IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_version_number IN NUMBER,
 x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_HR(
itemtype  in varchar2,
itemkey   in varchar2,
actid     in number,
funcmode  in varchar2,
resultout in out NOCOPY varchar2); --File.Sql.39 bug 4440895

PROCEDURE Clear_Temp_Table(
itemtype  in varchar2,
itemkey   in varchar2,
actid     in number,
funcmode  in varchar2,
resultout in out NOCOPY varchar2); --File.Sql.39 bug 4440895

PROCEDURE approval_message_body (
document_id in varchar2,
display_type in varchar2,
document in out NOCOPY varchar2,  --File.Sql.39 bug 4440895
document_type in out NOCOPY varchar2) ; --File.Sql.39 bug 4440895

g_person_id                   NUMBER := 0;
g_assignment_id               NUMBER := 0;

Procedure Set_Person(p_person_id IN NUMBER);
Procedure Set_Assignment(p_assignment_id IN NUMBER);

Function Get_Select_Flag(p_competence_id IN NUMBER)
RETURN VARCHAR2;

Procedure get_user_info(p_user_id       IN  VARCHAR2,
                        x_Person_id     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_Resource_id   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	     	        x_resource_name OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

Procedure get_user_info(p_user_id      IN VARCHAR2,
                        x_Person_id   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_Resource_id OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Get_person_business_group
(P_Person_id   IN NUMBER
)
RETURN NUMBER;

end PA_COMP_PROFILE_PUB ;
 

/
