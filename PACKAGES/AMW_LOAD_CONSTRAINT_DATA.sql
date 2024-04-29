--------------------------------------------------------
--  DDL for Package AMW_LOAD_CONSTRAINT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_CONSTRAINT_DATA" AUTHID CURRENT_USER AS
/* $Header: amwcstls.pls 120.0.12000000.1 2007/01/16 20:38:00 appldev ship $ */

-- ===============================================================
-- Package name
--          AMW_LOAD_CONSTRAINT_DATA
-- Purpose
--
-- History
-- 		  	10/01/2004    tsho     Creates
-- ===============================================================

-- FND_API global constant
G_USER_ID                           NUMBER      := FND_GLOBAL.USER_ID;
G_LOGIN_ID                          NUMBER      := FND_GLOBAL.CONC_LOGIN_ID;
G_FALSE    		  		   CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE 					   CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_VALID_LEVEL_FULL 		   CONSTANT NUMBER 		:= FND_API.G_VALID_LEVEL_FULL;
G_RET_STS_SUCCESS 		   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR 	    VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

-- AMW table/view name
G_AMW_USER                 CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER');
G_AMW_USER_RESP_GROUPS     CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_USER_RESP_GROUPS');
G_AMW_RESPONSIBILITY       CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_RESPONSIBILITY');
G_AMW_RESP_FUNCTIONS       CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_RESP_FUNCTIONS');
G_AMW_MENUS                CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_MENUS');
G_AMW_MENU_ENTRIES         CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_MENU_ENTRIES');
G_AMW_FORM_FUNCTIONS_VL    CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('AMW_FORM_FUNCTIONS_VL');


-- ===============================================================
-- Procedure name
--          create_constraints
-- Purpose
-- 		  	import constraints
--          from interface table to AMW_CONSTRAINTS_B and AMW_CONSTRAINTS_TL
-- Notes
--          this procedure is called in Concurrent Executable
-- ===============================================================
PROCEDURE create_constraints (
    ERRBUF      OUT NOCOPY   VARCHAR2,
    RETCODE     OUT NOCOPY   VARCHAR2,
    p_batch_id       IN       NUMBER,
    p_user_id        IN       NUMBER
);


-- ===============================================================
-- Procedure name
--          update_interface_with_error
-- Purpose
-- 		  	update interface table with error mesg
-- ===============================================================
PROCEDURE update_interface_with_error (
    p_err_msg        IN   VARCHAR2,
    p_table_name     IN   VARCHAR2,
    p_interface_id   IN   NUMBER
);


-- ----------------------------------------------------------------------
END AMW_LOAD_CONSTRAINT_DATA;


 

/
