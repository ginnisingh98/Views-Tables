--------------------------------------------------------
--  DDL for Package AMW_VIOLATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_VIOLATION_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvvlas.pls 120.13.12000000.1 2007/01/16 20:45:53 appldev ship $ */


-- ===============================================================
-- Package name
--          AMW_VIOLATION_PVT
-- Purpose
--
-- History
-- 		  	06/01/2005    tsho     Create
-- ===============================================================

TYPE G_NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE G_VARCHAR2_LONG_TABLE is table of VARCHAR2(320) INDEX BY BINARY_INTEGER;
TYPE G_VARCHAR2_CODE_TABLE   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE G_VARCHAR2_HASHTABLE   IS TABLE OF VARCHAR2(400) INDEX BY VARCHAR2(64);

-- FND_GLOBAL
G_USER_ID         	 				NUMBER 		:= FND_GLOBAL.USER_ID;
G_LOGIN_ID        	 				NUMBER 		:= FND_GLOBAL.CONC_LOGIN_ID;

-- AMW table/view name
G_AMW_USER                 CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER');
G_AMW_USER_RESP_GROUPS     CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER_RESP_GROUPS');
G_AMW_RESPONSIBILITY       CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_RESPONSIBILITY');
G_AMW_RESP_FUNCTIONS       CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_RESP_FUNCTIONS');
G_AMW_MENUS                CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_MENUS');
G_AMW_MENU_ENTRIES         CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_MENU_ENTRIES');
G_AMW_FORM_FUNCTIONS_VL    CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_FORM_FUNCTIONS_VL');
G_AMW_COMPILED_MENU_FUNCTIONS    CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_COMPILED_MENU_FUNCTIONS');
G_AMW_GRANTS               CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_GRANTS');
G_AMW_USER_ROLES           CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER_ROLES');
G_AMW_USER_ROLE_ASSIGNMENTS     CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER_ROLE_ASSIGNMENTS');
G_AMW_REQUEST_GROUP_UNITS  CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_REQUEST_GROUP_UNITS');
G_AMW_CONCURRENT_PROGRAMS_VL    CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_CONCURRENT_PROGRAMS_VL');
G_AMW_ALL_ROLES_VL         CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_ALL_ROLES_VL');
G_AMW_RESPONSIBILITY_VL    CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_RESPONSIBILITY_VL');
G_AMW_MENUS_VL             CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_MENUS_VL');
G_AMW_USER_ROLE_ASSIGNMENTS_V CONSTANT VARCHAR2(30) := 'WF_USER_ROLE_ASSIGNMENTS_V';

-- ===============================================================
-- Function name
--          Is_ICM_Installed
--
-- Purpose
--          check to see if ICM is installed or not
-- Params
--
-- Return
--          'Y' := ICM is installed
--          'N' := ICM is not installed
-- History
-- 		  	07/19/2005    tsho     Create
-- ===============================================================
Function Is_ICM_Installed
RETURN VARCHAR2;


-- ===============================================================
-- Procedure name
--          Has_Violations
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned these additional roles as well as inherited roles
-- Params
--          p_user_id            := input fnd user_id
--          p_role_names         := input a list of new roles
--          p_revoked_role_names := input a list of revoked roles
--          p_mode               := input check mode ('ADMIN', 'APPROVE', 'SUBS')
--          x_violat_region      := output full path dialog region name to display potential violation detials.
--                                  (ie. /oracle/apps/amw/audit/duty/webui/....RN)
--          x_violat_btn_region  := output full path dialog button region name to display page level buttons.
--                                  (ie. /oracle/apps/amw/audit/duty/webui/....RN)
--                                  this button region is different depending on the override privilege of Administrator
--          x_has_violation      := output 'Y' if this user will have violations with the new roles assigned; output 'N' otherwise.
--
-- History
-- 		  	06/01/2005    tsho     Create
--          08/03/2005    tsho     Consider User Waivers
--          08/01/2006    dliao    Support revoked roles
-- ===============================================================
Procedure Has_Violations (
    p_user_id               IN  NUMBER,
    p_role_names            IN  JTF_VARCHAR2_TABLE_400,
    p_revoked_role_names    IN  JTF_VARCHAR2_TABLE_400,
    p_mode                  IN  VARCHAR2,
    x_violat_region         OUT NOCOPY VARCHAR2,
    x_violat_btn_region     OUT NOCOPY VARCHAR2,
    x_has_violation         OUT NOCOPY VARCHAR2,
    x_new_resp_name   	    OUT NOCOPY VARCHAR2,
    x_existing_resp_name    OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
);



-- ===============================================================
-- Procedure name
--          Has_Violations
-- Obsolated due to the bug 5407266
-- History
-- 		  	06/01/2005    tsho     Create
--          08/03/2005    tsho     Consider User Waivers
--          08/01/2006    dliao    obsolated
-- ===============================================================
Procedure Has_Violations (
    p_user_id               IN  NUMBER,
    p_role_names            IN  JTF_VARCHAR2_TABLE_400,
    p_mode                  IN  VARCHAR2,
    x_violat_region         OUT NOCOPY VARCHAR2,
    x_violat_btn_region     OUT NOCOPY VARCHAR2,
    x_has_violation         OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
);


-- ===============================================================
-- Procedure name
--          Has_Violations_For_Mode
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned these additional roles as well as inherited roles
-- Params
--          p_user_id            := input fnd user_id
--          p_role_names         := input a list of new roles
--          p_mode               := input check mode ('ADMIN', 'APPROVE', 'SUBS')
--          x_violat_hashtable   := This API will put return parameters in a Associate Table format,
--                                  it at least contains the following key/value pairs:
--                                  HasViolation      : 'Y' or 'N' to indicate if introducing violations when trying to add those roles to the user
--                                  ViolationDetail   : the OAFunc/Region containing violation details for the user , mainly used for Notification.
--
-- History
-- 		  	07/19/2005    tsho     Create
-- ===============================================================
Procedure Has_Violations_For_Mode (
    p_user_id               IN  NUMBER,
    p_role_names            IN  JTF_VARCHAR2_TABLE_400,
    p_mode                  IN  VARCHAR2,
    x_violat_hashtable      OUT NOCOPY G_VARCHAR2_HASHTABLE
);


-- ===============================================================
-- Function name
--          Has_Violation_Due_To_Resp
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned the additional responsibility
-- Params
--          p_user_id            := input fnd user_id
--          p_responsibility_id  := input fnd responsibility_id
-- Return
--          'N'                  := if no SOD violation found.
--          'Y'                  := if SOD violation exists.
--                                  The SOD violation should NOT be restricted to
--                                  only the new responsiblity.
--                                  If the existing responsibilities have any violations,
--                                  the function should return 'Y' as well.
--
-- History
-- 		  	07/13/2005    tsho     Create
--          08/03/2005    tsho     Consider User Waivers
-- ===============================================================
Function Has_Violation_Due_To_Resp (
    p_user_id               IN  NUMBER,
    p_responsibility_id     IN  NUMBER
) return VARCHAR2;


-- ===============================================================
-- Procedure name
--          Update_Role_Constraint_Denorm
--
-- Purpose
--          populate AMW_ROLE_CONSTRAINT_DENORM table
-- Params
--          p_constraint_rev_id       := input constraint_rev_id (Default is NULL)
--                                       if p_constraint_rev_id is specified, only update/create
--                                       the corresponding role/resp with that constraint.
--
-- History
-- 		  	07/14/2005    tsho     Create
--          08/03/2005    tsho     Consider Responsibility Waivers, leave User Waiver check to the run-time
-- ===============================================================
Procedure Update_Role_Constraint_Denorm (
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_constraint_rev_id     IN  NUMBER := NULL
);



-- ===============================================================
-- Function name
--          Get_Violat_New_Role_List
--
-- Purpose
--          get a flat string list of new role display name, which together with this user's
--          exisiting role/resp , or together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--          p_new_role_names_string  := input a string list of new roles assigning to this user,
--                                  the role_name is seperated by ','
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_New_Role_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2,
    p_new_role_names_string     IN  VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          Get_Violat_Existing_Role_List
--
-- Purpose
--          get a flat string list of this user's existing role display name, together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Existing_Role_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          Get_Violat_Existing_Resp_List
--
-- Purpose
--          get a flat string list of this user's existing responsibility display name, together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Existing_Resp_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          Get_Violat_Existing_Menu_List
--
-- Purpose
--          get a flat string list of this user's existing permission set(menu) display name, ]
--          together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Existing_Menu_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          Get_Violat_Comments
--
-- Purpose
--          get comments(instruction) for specified constraint_rev_id
--
-- Params
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a seeded mesg
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Comments (
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2;



-- ===============================================================
-- Function name
--          Do_On_Role_Assigned
--
-- Purpose
--          listen to the worflow business event(mainly uses for oracle.apps.fnd.wf.ds.userRole.created)
--          and do corresponding actions
--
-- Params
--          p_subscription_guid
--          p_event
--
-- Return
--          'SUCCESS' | 'ERROR'
--
-- History
-- 		  	07/29/2005    tsho     Create
-- ===============================================================
FUNCTION Do_On_Role_Assigned (
    p_subscription_guid   in     raw,
	p_event               in out NOCOPY wf_event_t
) return VARCHAR2;


-- ===============================================================
-- Procedure name
--          Send_Notif_To_Affected_Process
--
-- Purpose
--          send violation notification to affected process owners
--          it'll find which constraints have been violated due to the user role assignment
--          and send notification to each process owner of those constraints
-- Params
--          p_item_type       := worflow template (default : AMWNOTIF)
--          p_message_name    := workflow mesg template (default : MWVIOLATUSERROLENOTIF)
--          p_user_name       := the user who got the role assigned
--          p_role_name       := the new role which is assigned to this user
--          p_assigned_date   := the assigned date
--          p_assigned_by_id  := the role is assigned by which user (user_id)
--
-- History
-- 		  	07/29/2005    tsho     Create
--          02/23/2006    psomanat removied the parameter p_assigned_date
--          02/23/2006    psomanat removied the parameter p_user_name
--          02/23/2006    psomanat added the parameter p_user_id
-- ============================================================================
Procedure Send_Notif_To_Affected_Process(
    p_item_type      IN VARCHAR2 := 'AMWNOTIF',
	p_message_name   IN VARCHAR2 := 'VIOLATIONNOTIF',
    p_user_id        IN NUMBER,
    p_role_name      IN VARCHAR2,
    p_assigned_by_id IN NUMBER
);

-- ===============================================================
-- Procedure name
--          Send_Notif_To_Process_Owner
--
-- Purpose
--          send violation notification to specified process owner
-- Params
--          p_item_type       := worflow template (default : AMWNOTIF)
--          p_message_name    := workflow mesg template (default : MWVIOLATUSERROLENOTIF)
--          p_user_name       := the user who got the role assigned
--          p_role_name       := the new role which is assigned to this user
--          p_assigned_date   := the assigned date
--          p_assigned_by_id  := the role is assigned by which user (user_id)
--          p_constraint_rev_id   := which constraint has been violated
--          p_process_owner_id    := the process owner of that constraint, to whom this notif will be sent
--
-- History
-- 		  	07/29/2005    tsho     Create
--          02/23/2006    psomanat removied the parameter p_assigned_date
--          02/23/2006    psomanat removied the parameter p_user_name
--          02/23/2006    psomanat added the parameter p_user_id
-- ===============================================================
Procedure Send_Notif_To_Process_Owner(
    p_item_type           IN VARCHAR2 := 'AMWNOTIF',
	p_message_name        IN VARCHAR2 := 'VIOLATIONNOTIF',
    p_user_id             IN NUMBER,
    p_role_name           IN VARCHAR2,
    p_assigned_by_id      IN NUMBER,
    p_constraint_rev_id   IN NUMBER,
    p_process_owner_id    IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
);


-- ===============================================================
-- Function name
--          Violation_Detail_Due_To_Resp
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned the additional responsibility
-- Params
--          p_user_id            := input fnd user_id
--          p_responsibility_id  := input fnd responsibility_id
-- Return
--          'N'                            := if no SOD violation found.
--          'Resp_name1, Resp_name2...'    := if SOD violation exists.
--                                            The SOD violation should NOT be restricted to
--                                            only the new responsiblity.
--                                            If the existing responsibilities have any violations,
--                                            the function should return 'Y' as well.
--
-- History
-- 		  	08/01/2005    tsho     Create
--          08/03/2005    tsho     Consider User Waivers
-- ===============================================================
Function Violation_Detail_Due_To_Resp (
    p_user_id               IN  NUMBER,
    p_responsibility_id     IN  NUMBER
) return VARCHAR2;


/*
 * cpetriuc
 * -------------
 * MENU_VIOLATES
 * -------------
 * Checks if the menu provided as argument violates any SOD (Segregation of Duties)
 * constraints.  If a constraint is violated, the function returns an error message
 * containing the name of the violated constraint together with the list of functions
 * that define the constraint.  Otherwise, the function returns 'N'.
 */
function MENU_VIOLATES(p_menu_id NUMBER) return VARCHAR2;


/*
 * cpetriuc
 * ----------------------
 * FUNCTION_VIOLATES_MENU
 * ----------------------
 * Checks if any SOD (Segregation of Duties) constraints would be violated if the
 * argument function would be added to the menu provided as argument.  If a constraint
 * would be violated, the function returns an error message containing the name of the
 * potentially violated constraint together with the list of functions that define the
 * constraint.  Otherwise, the function returns 'N'.
 */
function FUNCTION_VIOLATES_MENU(p_menu_id NUMBER, p_function_id NUMBER) return VARCHAR2;


-- ----------------------------------------------------------------------
END AMW_VIOLATION_PVT;

 

/
