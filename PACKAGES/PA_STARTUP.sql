--------------------------------------------------------
--  DDL for Package PA_STARTUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STARTUP" AUTHID CURRENT_USER as
/* $Header: PARSTUPS.pls 115.7 2002/03/04 04:51:28 pkm ship     $ */

-- ----------------------------------------------------------------------------
--  GLOBAL VARIABLE                 Purpose
--  ----------------                --------------------------------------------
--  G_Calling_Application           Calling Application. Valid Values are
--                                     SELF_SERVICE - Called from Self Service
--                                     FORMS        - Oracle Froms
--                                     REPORTS      - Oracle Reports
--                                     PLSQL        - PL/SQL
--
--  G_Calling_Module                Calling Module
--
--  G_Check_ID_Flag                 Flag for Validating ID for Value-ID
--                                  Conversion Procedure. Valid Values are
--                                    Y - Validate ID
--                                    N - No Validaton on ID
--
--  G_Check_Role_Security_Flag      Flag for the Checking Project Role Security
--                                  Valid Values are
--                                     Y - Check Project Role Security
--                                     N - No Checking Project Role Security
--
--  G_Check_Resource_Security_Flag  Flag for the Checking Resource Security
--                                  Valid Values are
--                                     Y - Check Resource Security
--                                     N - No Checking Resource Security
--
-- ----------------------------------------------------------------------------
G_Calling_Application              VARCHAR2(30)   DEFAULT FND_API.G_MISS_CHAR;
G_Calling_Module                   VARCHAR2(240)  DEFAULT FND_API.G_MISS_CHAR;
G_Check_ID_Flag                    VARCHAR2(1)    DEFAULT 'Y';
G_Check_Role_Security_Flag         VARCHAR2(1)    DEFAULT 'Y';
G_Check_Resource_Security_Flag     VARCHAR2(1)    DEFAULT 'Y';


-- ----------------------------------------------------------------------------
--  PROCEDURE
--              Initialize
--  PURPOSE
--              This procedure should be called as part of initialization
--              Note: 1. p_calling_application parameter is always required
--                    2. This procedure would not initialize the error stack
--                       nor would set the error stack as this is an
--                       Initialization procedure.
--                    3. The input parameters for this procedure correspond
--                       to the Global Variables specified in this package
--                       Unless specified:
--                          p_debug_level  --> For Enabling Debug
--  HISTORY
--   19-Jul-2000      nchouhan  Created
-- ----------------------------------------------------------------------------
procedure Initialize (
     p_calling_application          IN  VARCHAR2,
     p_calling_module               IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
     p_check_id_flag                IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
     p_check_role_security_flag     IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
     p_check_resource_Security_flag IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
     p_debug_level                  IN  NUMBER   DEFAULT FND_API.G_MISS_NUM
                     );

end PA_STARTUP ;

 

/
