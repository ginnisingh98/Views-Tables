--------------------------------------------------------
--  DDL for Package AMW_VIOLATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_VIOLATION_PUB" AUTHID CURRENT_USER as
/*$Header: amwvpubs.pls 120.4 2008/02/18 09:25:17 ptulasi ship $*/


TYPE G_NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

G_AMW_USER                 CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER');
G_AMW_GRANTS               CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_GRANTS');
G_AMW_USER_ROLES           CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER_ROLES');
G_AMW_ALL_ROLES_VL         CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_ALL_ROLES_VL');
G_AMW_RESPONSIBILITY_VL    CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_RESPONSIBILITY_VL');
/*04.26.2007 npanandi: bug 6017644 fix, added g_amw_form_functions_vl to fix compilation errors*/
G_AMW_FORM_FUNCTIONS_VL    CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_FORM_FUNCTIONS_VL');
G_AMW_MENUS_VL             CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_MENUS_VL');
G_AMW_MENU_ENTRIES         CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_MENU_ENTRIES');

-- 08:05:2007 - Psomanat : bug 	6000479 , 6000625
TYPE ridList IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
newRows ridList;


-- ===============================================================
-- Function name
--          Check_Resp_Violations
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
Function Check_Resp_Violations (
    p_user_id               IN  NUMBER,
    p_responsibility_id     IN  NUMBER
) return VARCHAR2;


-- ===============================================================
-- Function name
--          User_Resp_Violation_Details
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
Function User_Resp_Violation_Details (
    p_user_id               IN  NUMBER,
    p_responsibility_id     IN  NUMBER
) return VARCHAR2;


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


/*
 * cpetriuc
 * ---------------------
 * CHECK_MENU_VIOLATIONS
 * ---------------------
 * Checks if the menu provided as argument violates any SOD (Segregation of Duties)
 * constraints.  If a constraint is violated, the function returns an error message
 * containing the name of the violated constraint together with the list of functions
 * that define the constraint.  Otherwise, the function returns 'N'.
 *
 * psomanat : bug 5698160 : consider Responsibility waiver
 *
 */
function CHECK_MENU_VIOLATIONS(p_menu_id NUMBER,
    p_responsibility_id     IN  NUMBER :=NULL,
    p_application_id         IN  NUMBER :=NULL
) return VARCHAR2;


/*
 * cpetriuc
 * -------------------------
 * CHECK_FUNCTION_VIOLATIONS
 * -------------------------
 * Checks if any SOD (Segregation of Duties) constraints would be violated if the
 * argument function or submenu would be added to the menu provided as argument.  If a
 * constraint would be violated, the function returns an error message containing the name
 * of the potentially violated constraint together with the list of functions that define
 * the constraint.  Otherwise, the function returns 'N'.
 */
function CHECK_FUNCTION_VIOLATIONS(p_menu_id NUMBER, p_sub_menu_id NUMBER, p_function_id NUMBER) return VARCHAR2;


/*
 * cpetriuc
 * ------------------------------
 * CHECK_FUNCTION_LIST_VIOLATIONS
 * ------------------------------
 * Created initially as a helper function, to be used internally.
 *
 * Checks if the list of menu functions provided as argument violates any SOD
 * (Segregation of Duties) constraints.  If a constraint is violated, the function
 * returns an error message containing the name of the violated constraint together
 * with the list of functions that define the constraint.  Otherwise, the function
 * returns 'N'.
 * psomanat : bug 5698160 : consider Responsibility waiver
 */
function CHECK_FUNCTION_LIST_VIOLATIONS(g_menu_function_id_list G_NUMBER_TABLE,
    p_responsibility_id     IN  NUMBER,
    p_application_id         IN  NUMBER
) return VARCHAR2;


/*
 * cpetriuc
 * -----------------------------
 * CHECK_ADD_FUNCTION_VIOLATIONS
 * -----------------------------
 * Created initially as a helper function, to be used internally.
 *
 * Checks if adding the argument function to the list of menu functions provided as
 * argument violates any SOD (Segregation of Duties) constraints.  If a constraint is
 * violated, the function returns an error message containing the name of the violated
 * constraint together with the list of functions that define the constraint.  Otherwise,
 * the function returns 'N'.
 */
function CHECK_ADD_FUNCTION_VIOLATIONS(g_menu_function_id_list G_NUMBER_TABLE, p_function_id NUMBER) return VARCHAR2;

-- ===============================================================
-- Private Function name
--          get_User_Id
--
-- Purpose
--          This function takes user_name as input and returns user_id
-- Params
--          p_user_name          := user_name
-- Return
-- Notes
-- History
--          26.12.2007 ptulasi: Created for bug 6701364
--
-- ===============================================================
Function get_User_Id (
    p_user_name     IN  VARCHAR2
) return NUMBER;

end AMW_VIOLATION_PUB;

/
