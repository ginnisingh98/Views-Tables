--------------------------------------------------------
--  DDL for Package PA_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SECURITY_PVT" AUTHID CURRENT_USER AS
 /* $Header: PASECPVS.pls 120.4 2007/02/06 10:00:03 dthakker ship $ */


/* TYPE sec_flag_record IS RECORD (
     user_id number,
     object_key number,
     object_name varchar2(30),
     sec_resp_flag  varchar2(1)) ;
 TYPE sec_flag_TABTYPE IS TABLE OF sec_flag_record
 INDEX BY BINARY_INTEGER ;*/


  ---This is the generic security API which is used for
  ---function security check. It applies all functions
  ---except confirm assignment function
  --  Procedure Check User Privilege
  -----------------------------------
  Procedure check_user_privilege
  (
   p_privilege    IN  VARCHAR2,
   p_object_name   IN  VARCHAR2,
   p_object_key    IN  NUMBER,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   p_init_msg_list  IN  VARCHAR2 DEFAULT 'Y')   ; -- Added for Bug 4319137


 /* ---This API check is role based security is enforced or not
  ----Procedure check_sec_by_role
  -----------------------------------------
  function  check_sec_by_role
  (
   p_user_id in number,
   p_object_name in varchar2,
   p_source_type  in varchar2,
   p_object_key in number  ) return varchar2 ;*/

---This API check if responsibility based security is enforced or not
 ----function check_sec_by_resp
 -----------------------------------------
  function  check_sec_by_resp
  (
   p_user_id in number,
   p_object_name in varchar2,
   p_source_type  in varchar2,
   p_object_key in number ) return varchar2 ;

----This API wrapps all logic for check the
----confirm assignment privilege.
 ---Procedure check_confirm_asmt
--------------------------------------------------
     procedure check_confirm_asmt
          (p_project_id in number,
           p_resource_id in number,
           p_resource_name in varchar2,
           p_privilege in varchar2,
           p_start_date in date DEFAULT SYSDATE,
	   p_init_msg_list  IN VARCHAR2 DEFAULT 'T' ,   -- Added for bug 5130421
           x_ret_code out NOCOPY varchar2, --File.Sql.39 bug 4440895
           x_return_status out NOCOPY varchar2, --File.Sql.39 bug 4440895
           x_msg_count out NOCOPY varchar2, --File.Sql.39 bug 4440895
           x_msg_data out NOCOPY varchar2     ); --File.Sql.39 bug 4440895

 ----This API is for getting the resource organization id
 ------Procedure get_resource_org_id
 ------------------------------------------------
 procedure get_resource_org_id
         (p_resource_id in number,
          p_start_date in date,
          x_resource_org_id out NOCOPY number, --File.Sql.39 bug 4440895
          x_return_status out NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_error_message_code out NOCOPY varchar2  ); --File.Sql.39 bug 4440895


-----This API is for getting the project owning organization
 ------Procedure get_project_org_id
 ------------------------------------------------
 procedure get_project_org_id
         (p_project_id in number,
          x_project_org_id out NOCOPY number, --File.Sql.39 bug 4440895
          x_return_status out NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_error_message_code out NOCOPY varchar2  ); --File.Sql.39 bug 4440895

  -----This procedure checks if the p_manager_id is a manager
  -----of p_person_id in HR
  ------Procedure check_manager_relation
 ------------------------------------------------
 procedure check_manager_relation
         (p_person_id in number,
          p_manager_id in number,
          p_start_date in date,
          x_ret_code out NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_return_status out NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_error_message_code out NOCOPY varchar2  ); --File.Sql.39 bug 4440895



----Parameters Description for the following APIs
---p_commit DEFAULT FND_API.G_FALSE
---p_debug_mode default 'N'
---p_source_type: 'EMPLOYEE" or 'PARTY'
---p_party_id: employee_id or party_id
---p_role_name: meaning column in pa_project_role_types table
---p_object_key_type: 'INSTANCE' or 'INSTANCE_SET'
---p_object_key: project_id, task_id, org_id, etc.
---For update_role and lock_grant, either pass in grant_id or these parameters:
---p_role_name_old, p_object_name_old, p_object_key_type_old,
---p_object_key_old, p_party_id_old, p_source_type_old and p_start_date_old
---For revoke_grant, either pass in grant_id or these parameters:
--p_role_name,  p_object_name, p_object_key_type, p_object_key,
--p_party_id,p_source_type,p_start_date

---Procedure Description:
---Update_role only updates the start date and end date
---Revoke_grant deletes a specific record in fnd_grants, which has the unique combination of
---p_role_name,p_object_name,p_object_key_type,p_object_key,p_party_id,p_source_type,p_start_date
---Revoke_role deletes the records in fnd_grants , which have the combintion of
---p_role_name,p_object_name,,p_object_key_type,p_object_key,p_party_id,p_source_type.
---no matter what the start_date is.
PROCEDURE grant_org_authority
  (
   p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_debug_mode     in varchar2  default 'N',
   p_project_role_id   IN  number,
   p_menu_name in varchar2,
   p_object_name          IN  VARCHAR2,
   p_object_key_type  IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   p_source_type    in varchar2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_grant_guid      out NOCOPY raw, --File.Sql.39 bug 4440895
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE grant_role
  (
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   p_debug_mode      in varchar2  default 'N',
   p_project_role_id IN  number,
   p_object_name     IN  VARCHAR2,
   p_instance_type   IN  VARCHAR2,
   p_object_key      IN  NUMBER,
   p_party_id        IN  NUMBER,
   p_source_type     IN  varchar2,
   x_grant_guid      OUT NOCOPY raw, --File.Sql.39 bug 4440895
   x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

 PROCEDURE revoke_grant
  (
   p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_debug_mode     in varchar2  default 'N',
   p_grant_guid       in raw,
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


PROCEDURE revoke_role
  (
   p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_debug_mode     in varchar2  default 'N',
   p_project_role_id  IN  number,
   p_menu_name        in varchar2,
   p_object_name          IN  VARCHAR2,
   p_object_key_type  IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   p_source_type    in varchar2,
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

 -- obsolete API
 PROCEDURE update_role
  (  p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode     in varchar2  default 'N',
     p_grant_guid       in raw,
     p_project_role_id_old       IN  number default null,
     p_object_name_old          IN  VARCHAR2 default null,
     p_object_key_type_old  IN  VARCHAR2 default null,
     p_object_key_old     IN  NUMBER default null,
     p_party_id_old       IN  NUMBER default null,
     p_source_type_old        in varchar2 default null,
     p_start_date_old   IN  DATE default null,
     p_start_date_new  IN  DATE default null,
     p_end_date_new       IN  DATE,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

 PROCEDURE lock_grant
  (
    p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_debug_mode     in varchar2  default 'N',
    p_grant_guid        in raw,
    p_project_role_id_old       IN  number default null,
    p_object_name_old          IN  VARCHAR2 default null,
    p_object_key_type_old  IN  VARCHAR2 default null,
    p_object_key_old     IN  number default null,
    p_party_id_old       IN  NUMBER default null,
    p_source_type_old    in varchar2 default null,
    p_start_date_old   IN  DATE default null,
   p_project_role_id      IN  number,
   p_party_id       IN  NUMBER,
   p_source_type    in varchar2,
   p_object_name          IN  VARCHAR2,
   p_object_key_type  IN  VARCHAR2,
   p_object_key     IN  number,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

FUNCTION get_instance_set_id (p_set_name in varchar2) return number;

---This function is for pre-seeded roles. The project_role_id
----for pre-seeded roles are fixed
FUNCTION get_menu_name (p_project_role_id in number) return varchar2 ;

----This function is obsoleted because of translation issue with the pre-seeded roles
--FUNCTION get_menu_name (p_project_role_name in varchar2) return varchar2;

FUNCTION get_menu_id (p_menu_name in varchar2) return number;

------This function is only for internal use
FUNCTION get_menu_id_for_role(p_project_role_id in number) return number;

FUNCTION get_proj_role_name(p_project_role_id in number) return varchar2;
Function get_party_id return number;
FUNCTION is_role_exists ( p_object_name     IN FND_OBJECTS.OBJ_NAME%TYPE
                         ,p_object_key_type IN FND_GRANTS.INSTANCE_TYPE%TYPE DEFAULT 'INSTANCE'
                         ,p_role_id         IN FND_MENUS.MENU_ID%TYPE
                         ,p_object_key      IN FND_GRANTS.INSTANCE_PK1_VALUE%TYPE
                         ,p_party_id        IN NUMBER
                        ) RETURN BOOLEAN;

--------FUNCTION check_user_privilege
---This function will be used in select statement in some of the PRM pages
FUNCTION check_user_privilege
         (p_privilege in varchar2,
          p_object_name in varchar2,
          p_object_key in number,
          p_init_msg_list  IN  VARCHAR2 DEFAULT 'Y') return varchar2  ;
          -- p_init_msg_list Added for Bug 4319137

---------PROCEDURE check_access_exist
--Check where the user has access to any object with the given privilege
PROCEDURE check_access_exist(p_privilege IN VARCHAR2,
                             p_object_name IN VARCHAR2,
                             x_ret_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION get_grantee_key(
  p_source_type IN VARCHAR2 DEFAULT 'USER',
  p_source_id IN NUMBER DEFAULT FND_GLOBAL.USER_ID,
  p_HZ_WF_Synch IN VARCHAR2 DEFAULT 'N')  -- Modified default parameter to 'N' for bug 3471913
RETURN VARCHAR2;

FUNCTION get_resource_source_id return NUMBER;
FUNCTION get_resource_type_id return NUMBER;
FUNCTION get_project_system_status_code return VARCHAR2;

PROCEDURE check_grant_exists(p_project_role_id in NUMBER,
                             p_instance_type in fnd_grants.INSTANCE_TYPE%TYPE,
                             p_instance_set_name in fnd_object_instance_sets.instance_set_name%TYPE,
                             p_grantee_type in fnd_grants.GRANTEE_TYPE%TYPE,
                             p_grantee_key in fnd_grants.GRANTEE_KEY%TYPE,
                             x_instance_set_id out NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_ret_code out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            );

----------------------------------------------------------------------
-- The APIs below will be used by Roles form:
-- 1. update_menu
-- 2. revoke_role_based_sec
-- 3. grant_role_based_sec
-- 4. revoke_status_based_sec
-- 5. update_status_based_sec
----------------------------------------------------------------------

 -- This API is called when the default Menu is changed
 -- in Roles form for existing roles which are in use.
 PROCEDURE update_menu
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     p_menu_id          IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- This API is called when Enforce Role-based Security checkbox
 -- is unchecked in Roles form for existing roles which are in use.
 PROCEDURE revoke_role_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

 -- This API is called when Enforce Role-based Security checkbox
 -- is checked in Roles form for existing roles which are in use.
 PROCEDURE grant_role_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

 -- This API is called when Status Level is changed
 -- in Roles form for existing roles which are in use.
 PROCEDURE revoke_status_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

 -- This API is called when status/menu under Project Status is changed
 -- in Roles form for existing roles which are in use.
 PROCEDURE update_status_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     p_status_level     IN pa_project_role_types_b.status_level%TYPE,
     p_new_status_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_new_status_type_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_new_menu_name_tbl    IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_new_role_sts_menu_id_tbl IN SYSTEM.pa_num_tbl_type := null,
     p_mod_status_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_mod_status_type_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_mod_menu_id_tbl    IN SYSTEM.pa_num_tbl_type := null,
     p_mod_role_sts_menu_id_tbl IN SYSTEM.pa_num_tbl_type := null,
     p_del_status_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_del_status_type_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_del_role_sts_menu_id_tbl IN SYSTEM.pa_num_tbl_type := null,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

end PA_SECURITY_PVT;

/

  GRANT EXECUTE ON "APPS"."PA_SECURITY_PVT" TO "EBSBI";
