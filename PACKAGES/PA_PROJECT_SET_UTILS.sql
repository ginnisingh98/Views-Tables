--------------------------------------------------------
--  DDL for Package PA_PROJECT_SET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SET_UTILS" AUTHID CURRENT_USER AS
/*$Header: PAPPSUTS.pls 120.1 2005/08/19 16:44:00 mwasowic noship $*/
--+

TYPE project_set_lines_tbl_type IS TABLE OF pa_project_set_lines%ROWTYPE
   INDEX BY BINARY_INTEGER;

PROCEDURE getPartyIdName (p_user_id      IN NUMBER
                         ,x_party_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                         ,x_party_name  OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);


FUNCTION get_project_set_lines(p_project_set_id IN NUMBER)
RETURN project_set_lines_tbl_type;

FUNCTION do_lines_exist(p_project_set_id  IN  NUMBER)
RETURN VARCHAR2;

FUNCTION check_projects_in_set(p_project_set_id  IN NUMBER
                              ,p_project_id      IN NUMBER)
RETURN VARCHAR2;

FUNCTION check_security_on_set(p_party_id IN NUMBER,
                               p_user_id NUMBER DEFAULT fnd_global.user_id,
                               p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;


FUNCTION is_name_unique(p_project_set_name  IN  VARCHAR2
                       ,p_project_set_id    IN  NUMBER := NULL)
RETURN VARCHAR2;

FUNCTION get_proj_set_name (p_project_set_id    IN  NUMBER)
RETURN VARCHAR2;

PROCEDURE add_projects_to_proj_set
( p_project_set_id           IN  pa_project_sets_b.project_set_id%TYPE
 ,p_project_id_tbl           IN  SYSTEM.pa_num_tbl_type
 ,p_init_msg_list            IN  VARCHAR2  := FND_API.G_FALSE
 ,p_commit                   IN  VARCHAR2  := FND_API.G_FALSE
 ,p_validate_only            IN  VARCHAR2  := FND_API.G_TRUE
 ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_project_list            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_project_set_name        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Check_PartyName_Or_Id(
        p_party_id           IN     NUMBER,
        p_party_name	       IN     VARCHAR2,
        p_check_id_flag      IN     VARCHAR2,
        x_party_id           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_return_status      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_error_msg_code     OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE Check_ProjectSetName_Or_Id(
        p_project_set_id         IN     NUMBER
       ,p_project_set_name	 IN     VARCHAR2
       ,p_check_id_flag          IN     VARCHAR2   DEFAULT  'A'
       ,x_project_set_id        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_return_status         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_msg_code        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION is_party_internal (p_party_id  IN NUMBER) RETURN VARCHAR2;

END PA_PROJECT_SET_UTILS;
 

/
