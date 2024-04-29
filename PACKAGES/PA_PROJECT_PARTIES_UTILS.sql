--------------------------------------------------------
--  DDL for Package PA_PROJECT_PARTIES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_PARTIES_UTILS" AUTHID CURRENT_USER as
/* $Header: PARPPU2S.pls 120.1 2005/08/19 16:58:36 mwasowic noship $ */

--
-- Global Variables.
--
  G_PROJECT_MANAGER_ID NUMBER;

Function VALIDATE_DELETE_PARTY_OK( p_project_id        IN NUMBER,
                                   p_project_party_id  IN NUMBER) return varchar2;

FUNCTION ACTIVE_PARTY (	p_start_date_active IN DATE,
			p_end_date_active IN DATE) return varchar2;

PROCEDURE GET_PROJECT_DATES (p_project_id IN NUMBER,
                             x_project_start_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                             x_project_end_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                             x_return_status  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE VALIDATE_PROJECT_PARTY( p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER,
                                p_OBJECT_TYPE           IN VARCHAR2,
                                p_project_role_id       IN NUMBER,
                                p_resource_type_id      IN NUMBER default 101,
                                p_resource_source_id    IN NUMBER,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2,
                                p_record_version_number IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                p_calling_module        IN VARCHAR2,
                                p_action                IN VARCHAR2,
                                p_project_id            IN NUMBER,
                                p_project_end_date      IN DATE,
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                p_project_party_id      IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_call_overlap          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_assignment_action     IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

Function GET_SCHEDULED_FLAG(p_project_party_id     IN NUMBER,
                            p_record_version_number  IN NUMBER) return varchar2;

Function VALIDATE_SCHEDULE_ALLOWED(p_project_role_id  IN NUMBER) return varchar2;

Function GET_PROJECT_ROLE_ID(P_PROJECT_ROLE_TYPE IN VARCHAR2,
                             P_CALLING_MODULE    IN VARCHAR2) return number;

Function GET_RESOURCE_SOURCE_ID(p_resource_name   IN VARCHAR2) return number;

Procedure GET_PERSON_PARTY_ID( p_object_type       IN VARCHAR2,
                               p_object_id         IN NUMBER,
                              p_project_role_id     IN NUMBER,
                              p_resource_type_id      IN NUMBER default 101,
                              p_resource_source_id  IN NUMBER,
                              p_start_date_active   IN DATE,
                              p_end_date_active     IN DATE,
                              x_project_party_id    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_record_version_number OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE CHECK_MANDATORY_FIELDS(p_project_Role_id        IN NUMBER,
                                 p_resource_type_id      IN NUMBER default 101,
                                 p_resource_source_id     IN NUMBER,
                                 p_start_date_active      IN DATE,
                                 p_end_date_active        IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                 p_project_end_date       IN DATE,
                                 p_scheduled_flag         IN VARCHAR2,
                                 x_error_occured          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE VALIDATE_DATES( p_start_date_active   IN DATE,
                          p_end_date_active     IN DATE,
                          x_error_occured       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE VALIDATE_NO_OVERLAP_MANAGER(  p_object_type       IN VARCHAR2,
                                       p_object_id         IN NUMBER,
                                       p_project_role_id    IN NUMBER,
                                       p_project_party_id   IN NUMBER,
                                       p_start_date_active  IN DATE,
                                       p_end_date_active    IN DATE,
                                       x_error_occured      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE VALIDATE_PERSON_NOT_OVERLAPPED( p_object_type       IN VARCHAR2,
                                       p_object_id         IN NUMBER,
                                       p_project_role_id    IN NUMBER,
                                       p_project_party_id   IN NUMBER,
                                       p_resource_type_id      IN NUMBER default 101,
                                       p_resource_source_id IN NUMBER,
                                       p_start_date_active  IN DATE,
                                       p_end_date_active    IN DATE,
                                       x_error_occured      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION ENABLE_EDIT_LINK(p_project_id       IN NUMBER,
                          p_scheduled_flag   IN VARCHAR2,
                          p_assignment_id    IN NUMBER) return varchar2;

FUNCTION GET_GRANT_ID(p_project_party_id   IN NUMBER) return raw;

PROCEDURE GET_CURR_PROJ_MGR_DETAILS(p_project_id        in number,
                                              x_manager_person_id out NOCOPY number, --File.Sql.39 bug 4440895
                                              x_manager_name      out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                              x_project_party_id  out NOCOPY number, --File.Sql.39 bug 4440895
                                              x_project_role_id   out NOCOPY number, --File.Sql.39 bug 4440895
                                              x_project_role_name out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                              x_return_status     out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                              x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895

FUNCTION get_customer_project_party_id (
  p_project_id IN NUMBER,
  p_customer_id IN NUMBER) RETURN NUMBER;

PROCEDURE VALIDATE_ROLE_PARTY( p_project_role_id     IN NUMBER,
                               p_resource_type_id    IN NUMBER DEFAULT 101,
                               p_resource_source_id  IN NUMBER,
                               x_error_occured       OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895


-- API name             : get_project_manager
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : NUMBER
--
--  History
--
--       26-Dec-2002   -- shyugen     - Created
--
FUNCTION GET_PROJECT_MANAGER  ( p_project_id  IN NUMBER)
RETURN NUMBER;

-- API name             : get_project_manager_name
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_person_id         IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--       26-Dec-2002   -- shyugen     - Created
--
--
FUNCTION GET_PROJECT_MANAGER_NAME
RETURN VARCHAR2;

FUNCTION GET_PROJECT_MANAGER_NAME( p_project_id  IN NUMBER)
RETURN VARCHAR2;

/* Added the following procedure for bug #2111806. */
PROCEDURE VALIDATE_MANAGER_DATE_RANGE( p_mode               IN VARCHAR2,
                                       p_project_id         IN NUMBER,
			       	       x_start_no_mgr_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                           	       x_end_no_mgr_date   OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                       x_error_occured     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE VALIDATE_ONE_MANAGER_EXISTS( p_project_id         IN NUMBER,
                                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--  API name             : get_current_project_manager
--  Type                 : Public
--  Pre-reqs             : None.
--  Parameters           :
--  p_project_id         IN NUMBER
--  Return               : NUMBER
--  Details: This function is created so as to return the project manager who is
--  active on the project as on the sysdate.
--  History
--
--   23-May-2005        adarora      - Created
--

FUNCTION GET_CURRENT_PROJECT_MANAGER  ( p_project_id  IN NUMBER)
RETURN NUMBER;

-- API name             : GET_CURRENT_PROJ_MANAGER_NAME
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
--  p_project_id         IN NUMBER
--  Return               : VARCHAR2
--  Details: This function is created so as to return the project manager name who is
--  active on the project as on the sysdate.
--  History
--
--   23-May-2005        adarora      - Created
--
FUNCTION GET_CURRENT_PROJ_MANAGER_NAME( p_project_id  IN NUMBER)
RETURN VARCHAR2;


END PA_PROJECT_PARTIES_UTILS;

 

/

  GRANT EXECUTE ON "APPS"."PA_PROJECT_PARTIES_UTILS" TO "EBSBI";
