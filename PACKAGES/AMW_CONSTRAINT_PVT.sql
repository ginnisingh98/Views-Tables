--------------------------------------------------------
--  DDL for Package AMW_CONSTRAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_CONSTRAINT_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvcsts.pls 120.9.12010000.1 2008/07/28 08:35:47 appldev ship $ */

-- ===============================================================
-- Package name
--          AMW_CONSTRAINT_PVT
-- Purpose
--
-- History
-- 		  	10/27/2003    tsho     Creates
--          05/05/2004    tsho     add Get_Functions and related getters
--          05/13/2005    tsho     introduce Cocurrent Program, Incomapatible Sets, Revalidation, (Role, GLOBAL Grant/USER Grant) in AMW.E
--          12/01/2005    tsho     add Purge_Violation_Before_Date (for bug 4673154)
-- ===============================================================

-- FND_API global constant
G_FALSE    		  		   CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE 					   CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_VALID_LEVEL_FULL 		   CONSTANT NUMBER 		:= FND_API.G_VALID_LEVEL_FULL;
G_RET_STS_SUCCESS 		   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR 	   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

-- FND_GLOBAL
G_USER_ID         	 				NUMBER 		:= FND_GLOBAL.USER_ID;
G_PARTY_ID         	 				NUMBER 		:= NULL;
G_LOGIN_ID        	 				NUMBER 		:= FND_GLOBAL.CONC_LOGIN_ID;
G_SECURITY_GROUP_ID                 NUMBER      := FND_GLOBAL.SECURITY_GROUP_ID;

-- AMW table/view name
G_AMW_USER                 CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_USER');
G_AMW_USER_RESP_GROUPS     CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_USER_RESP_GROUPS');
G_AMW_RESPONSIBILITY       CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_RESPONSIBILITY');
G_AMW_RESP_FUNCTIONS       CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_RESP_FUNCTIONS');
G_AMW_MENUS                CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_MENUS');
G_AMW_MENU_ENTRIES         CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_MENU_ENTRIES');
G_AMW_FORM_FUNCTIONS_VL    CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_FORM_FUNCTIONS_VL');
G_AMW_COMPILED_MENU_FUNCTIONS    CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_COMPILED_MENU_FUNCTIONS');
G_AMW_GRANTS               CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_GRANTS');
G_AMW_USER_ROLES           CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_USER_ROLES');
G_AMW_USER_ROLE_ASSIGNMENTS     CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_USER_ROLE_ASSIGNMENTS');
G_AMW_REQUEST_GROUP_UNITS  CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_REQUEST_GROUP_UNITS');
G_AMW_CONCURRENT_PROGRAMS_VL    CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('AMW_CONCURRENT_PROGRAMS_VL');


-- AMW constraint
G_OBJ_TYPE				   CONSTANT	VARCHAR2(80)	:= 'Constraint';


-- AMW Users :store AWM Employees having corresponding user_id in g_amw_user
TYPE UserIdList IS TABLE OF NUMBER;
G_USER_ID_LIST UserIdList   := NULL;


-- ===============================================================
-- Function name
--          Get_Party_Id
--
-- Purpose
--          get the party_id by specified user_id
--
-- Params
--          p_user_id   := specified user_id
--
-- ===============================================================
Function Get_Party_Id (
    p_user_id   IN  NUMBER
)
Return  NUMBER;


-- ===============================================================
-- Procedure name
--          Populate_User_Id_List
--
-- Purpose
--          populate the global user id list
--
-- ===============================================================
Procedure Populate_User_Id_List;



-- ===============================================================
-- Procedure name
--          Check_Violation
--
-- Purpose
--          to check violations for constraint
--
-- Params
--          p_check_all_constraint_flag := 'Y' or 'N' (default to 'N')
--          p_constraint_set
--          p_constraint_rev_id1
--          p_constraint_rev_id2
--          p_constraint_rev_id3
--          p_constraint_rev_id4
--
-- Notes
--          If 'Y' is passed-in as p_check_all_constraint_flag,
--          will run violation check for
--          every valid constraint
--          (valid means the current time is between constraint's START_DATE and END_DATE)
--          and ignore the passed-in p_constraint_rev_id.
--
--
--          If 'N' is passed-in as p_check_all_constraint_flag,
--          then check the passed-in p_constraint_rev_id
--          currently only support up to four specified constraints
--          p_constraint_rev_id1....p_constraint_rev_id4
--
--          12.21.2004 tsho: fix for performance bug 4036679
-- ===============================================================
PROCEDURE Check_Violation(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_check_all_constraint_flag  IN   VARCHAR2      := 'N',
    p_constraint_set             IN   VARCHAR2      := NULL,
    p_constraint_rev_id1         IN   NUMBER        := NULL,
    p_constraint_rev_id2         IN   NUMBER        := NULL,
    p_constraint_rev_id3         IN   NUMBER        := NULL,
    p_constraint_rev_id4         IN   NUMBER        := NULL
    );


-- ===============================================================
-- Function name
--          Get_Resps_By_Appl
--
-- Purpose
--          get the responsibility by specified applicaiton_id,
-- Params
--          p_appl_id   := specified application_id
--
-- ===============================================================
Procedure Get_Resps_By_Appl (
    p_appl_id               IN  NUMBER,
    x_resp_list             OUT NOCOPY VARCHAR2,
    x_menu_list             OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
);


-- ===============================================================
-- Function name
--          Get_Functions_By_Appl
-- Purpose
--          get the available functions by specified applicaiton_id,
-- Params
--          p_appl_id   := specified application_id
--
-- ===============================================================
Function Get_Functions_By_Appl (
    p_appl_id   IN  NUMBER
)
Return  VARCHAR2;


-- ===============================================================
-- Function name
--          Get_Functions_By_Resp
--
-- Purpose
--          get the available functions by specified resp_id,
-- Params
--          p_appl_id   := specified application_id
--          p_resp_id   := specified responsibility_id
--          p_menu_id   := specified menu_id
-- Notes
--          this Function is modified from PROCESS_MENU_TREE_DOWN_MN,
--          Instead of checking specific function_id, check all the
--          available functions under specific responsibility_id
--
-- ===============================================================
Function Get_Functions_By_Resp (
    p_appl_id   IN NUMBER,
    p_resp_id   IN NUMBER,
    p_menu_id   IN NUMBER
)
Return  VARCHAR2;


-- ===============================================================
-- Procedure name
--          Revalidate_Violation
-- Purpose
--          to revalidate existing violators of specified violation report
--
-- Params
--          p_violation_id
--
-- Notes
--          this only checks violations for existing violators (against this constraint),
--          don't consider if any other users violate this constraint or not.
-- History
--          05.20.2005 tsho: create for AMW.E
-- ===============================================================
PROCEDURE Revalidate_Violation(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_violation_id               IN   NUMBER            := NULL
    );


-- ===============================================================
-- Procedure name
--          Purge_Violation_Before_Date
-- Purpose
--          to clear violation history before the specified date
-- Params
--          p_delopt
--          p_date
-- Notes
--          p_delopt can have one of the two values
--              ALLCSTVIO - All Constraint Violations
--              INVALCSTVIO - Invalid Constraint Violations
--          p_date will have passed-in date
--
--          With "ALL Constraint Violations", we will delete all the constraint
--          violations created before the specified date.
--          With "Invalid Constraint violations", we will delete all the invalid
--          constraint violations created before the specified date. deleted.
--
-- History
--          12.01.2005 tsho     create (related to customer requirement: bug 4673154)
--          12.14.2006 psomanat Added delete statements for amw_violation_resp and amw_violat_resp_entries
--          03.14.2007 psomanat Added parameter p_delopt
-- ===============================================================
PROCEDURE Purge_Violation_Before_Date (
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_delopt                     IN   VARCHAR2 := NULL,
    p_date                       IN   VARCHAR2 := NULL
    );


-- ===============================================================
-- Procedure name
--     Check_Violation_By_Name
--
-- Purpose
--     This Concurrent Program Executable checks the constraint
--     violation for Constraint Name Starting with p_constraint_name%.
--
-- Params
--     p_constraint_name  : Constraint Name Starting With
--
--
-- Notes
--     18.05.2006 psomanat: created
-- ===============================================================
PROCEDURE Check_Violation_By_Name(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_constraint_name            IN   VARCHAR2:= NULL
);

-- ----------------------------------------------------------------------
END AMW_CONSTRAINT_PVT;

/
