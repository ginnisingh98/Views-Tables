--------------------------------------------------------
--  DDL for Package Body INV_GMI_RSV_BRANCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_GMI_RSV_BRANCH" AS
-- $Header: INVGGMIB.pls 120.1 2005/06/11 13:35:19 appldev  $
-- API start comments
--+=========================================================================+
--|                Copyright (c) 2000 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|    INVGGMIS.pls                                                         |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains Global procedures relating to Branching       |
--|     Logic that will cause the code to call PROCESS  Iventory ( GMI)     |
--|     Instead Of DISCRETE Invemtory (INV).                                |
--|                                                                         |
--| HISTORY                                                                 |
--|     14-FEB-2000  H.Verdding      Created                                |
--|                                                                         |
--+=========================================================================+
-- API Name  : INV_GMI_RSV_BRANCH
-- Type      : Global - Package Body Specification
-- Function  : This package contains Global procedures used to Branch code
--             From Within Discrete Inventory (INV) to Process Inventory
---            (GMI).
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 1.0
-- Api end of comments

-- Global variables
G_PKG_NAME             CONSTANT VARCHAR2(30):='INV_GMI_RSV_BRANCH';
l_process_rec          INV_GMI_RSV_BRANCH.process_org_rec;
l_process_rec_tbl      INV_GMI_RSV_BRANCH.process_org_rec_tbl;
l_discrete_rec         INV_GMI_RSV_BRANCH.discrete_org_rec;
l_discrete_rec_tbl     INV_GMI_RSV_BRANCH.discrete_org_rec_tbl;

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|   PROCESS_BRANCH                                                         |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   Allow Calling Function To Branch between DISCRETE Inventory (INV)      |
--|   Functionality and PROCESS Inventory Functionality.                     |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   Allow Calling Function To Branch between DISCRETE Inventory (INV)      |
--|   Functionality and PROCESS Inventory Functionality.                     |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_organization_id  IN  NUMBER       - Organization Identifier         |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+
-- Api end of comments
FUNCTION PROCESS_BRANCH
(
  p_organization_id  IN   NUMBER
)
RETURN BOOLEAN
IS

BEGIN

-- Validate Input Attribute p_organization_id;
   IF p_organization_id IS NULL  OR p_organization_id = fnd_api.g_miss_num THEN
      RETURN FALSE;
   END IF;

-- Check IF Process Inventory Is Installed.
/* No need to check if Process Inventory is installed - INVCONV
   IF INV_GMI_RSV_BRANCH.G_PROCESS_INV_INSTALLED <> 'I' THEN
      RETURN FALSE;
   ELSE */
-- ELSE check IF Organization Parameter is defined as a PROCESS ORG.
   IF IS_ORG_PROCESS_ORG(p_organization_id) THEN
        RETURN TRUE;
   END IF;
-- END IF; /* INVCONV */

RETURN FALSE;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;

   WHEN OTHERS THEN
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'BRANCHING LOGIC'
              );
        END IF;
      RETURN FALSE;

END PROCESS_BRANCH;

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    GET_PROCESS_ORG                                                       |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Procedure will Return OPM Organization Values From A Global       |
--|   CACHE. If the specified row does not EXIST in the cache it will        |
--|   try and Retrive this from the database                                 |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This Procedure will Return OPM Organization Values From A Global       |
--|   CACHE. If the specified row does not EXIST in the cache it will        |
--|   try and Retrive this from the database                                 |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_organization_id  IN  NUMBER       - Organization Identifier         |
--|    x_opm_whse_code    OUT VARCHAR2     - OPM Whse Code                   |
--|    x_opm_co_code      OUT NUMBER       - OPM Company Code                |
--|    x_opm_orgn_code    OUT VARCHAR2     - OPM Organization Code           |
--|    x_return_status    OUT VARCHAR2     - Return Status                   |
--|                                                                          |
--| RETURNS                                                                  |
--|    See Above OUT PARAMETERS                                              |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+

PROCEDURE GET_PROCESS_ORG
(
   P_ORGANIZATION_ID IN  NUMBER
  ,X_OPM_WHSE_CODE   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,X_OPM_CO_CODE     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,X_OPM_ORGN_CODE   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,X_RETURN_STATUS   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
tbl_index BINARY_INTEGER :=1;
l_opm_whse_code VARCHAR2(4);
l_opm_orgn_code VARCHAR2(4);
l_opm_co_code   VARCHAR2(4);

BEGIN

-- Initialize API return status to sucess
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- As long as there are records in the Global cache
-- search It to find matching organization id.

-- INVCONV
/* IF l_process_rec_tbl.COUNT > 0 THEN
    WHILE tbl_index <= l_process_rec_tbl.COUNT
    LOOP
     IF l_process_rec_tbl(tbl_index).organization_id = P_ORGANIZATION_ID THEN
        l_opm_whse_code := l_process_rec_tbl(tbl_index).whse_code;
        l_opm_co_code   := l_process_rec_tbl(tbl_index).co_code;
        l_opm_orgn_code := l_process_rec_tbl(tbl_index).orgn_code;
        EXIT;
     END IF;
     tbl_index := tbl_index +1;
    END LOOP;
ELSE */
   -- Seach the database
   IF SEARCH_PROCESS_ORG_DB(P_ORGANIZATION_ID) THEN
      -- If this is successful then the global rec type
      -- l_process_rec will have the record we need

      x_opm_whse_code := l_process_rec.whse_code;
      x_opm_co_code   := l_process_rec.co_code;
      x_opm_orgn_code := l_process_rec.orgn_code;

      -- Call Add To CACHE Since We May need This Again
      -- add_process_org_to_cache(l_process_rec); /* INVCONV */
      RETURN;
    ELSE
    -- Return Expected Error do I need A MESSAGE!!!
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
-- END IF; End INVCONV
/*  INVCONV x_opm_whse_code := l_opm_whse_code;
x_opm_co_code   := l_opm_co_code;
x_opm_orgn_code := l_opm_orgn_code; INVCONV */

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'GET PROCESS ORG'
            );
       END IF;

END get_process_org;

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|   SEARCH_PROCESS_ORG_CACHE                                               |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   The cache of Organizations defined as PROCESS Orgs to find a matching  |
--|   Record.If Found It Will Return TRUE, Otherwise It Will Return False.   |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   The cache of Organizations defined as PROCESS Orgs to find a matching  |
--|   Record.If Found It Will Return TRUE, Otherwise It Will Return False.   |
--|                                                                          |
--| PARAMETERS                                                               |
--|   p_organization_id  IN  NUMBER       - Organization Identifier          |
--|                                                                          |
--| RETURNS                                                                  |
--|   NONE 								     |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+
-- Api end of comments

FUNCTION search_process_org_cache
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN
IS

tbl_index BINARY_INTEGER :=1;

BEGIN

-- As long as there are records in the cache
-- Search the cache Else return FALSE.

IF l_process_rec_tbl.COUNT > 0 THEN
    WHILE tbl_index <= l_process_rec_tbl.COUNT
    LOOP
     IF l_process_rec_tbl(tbl_index).organization_id = P_ORGANIZATION_ID THEN
        RETURN TRUE;
     END IF;
     tbl_index := tbl_index +1;
    END LOOP;
END IF;

 RETURN FALSE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Search_process_org_cache'
                            );
    RETURN FALSE;


END search_process_org_cache;
-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    SET_INSTALLED                                                         |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Procedure Will Be called the First Time That This Package         |
--|   Is Instantiated ( Loaded into Memory).                                 |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This will set The GLOBAL VARIABLE G_PROCESS_INV_INSTALLED to the       |
--|   Installed Status of The Passed in Application Short Name (GMI).        |
--|                                                                          |
--| PARAMETERS                                                               |
--|    P_APP_SHORT_NAME    IN VARCHAR2    - Application Short name           |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+

Procedure SET_INSTALLED
(
   P_APP_SHORT_NAME IN VARCHAR2
)
IS
l_status   VARCHAR2(1);
l_industry VARCHAR2(1);
l_schema   VARCHAR2(30);

BEGIN


-- Call FND API to set Installed Flag
IF  fnd_installation.get_app_info( 'GMI',l_status,l_industry,l_schema) THEN
    INV_GMI_RSV_BRANCH.G_PROCESS_INV_INSTALLED := l_status;
END IF;

EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'SET INSTALLED'
                            );

END set_installed;

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|   SEARCH_PROCESS_ORG_DB                                                  |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   The cache of Organizations defined as PROCESS Orgs to find a matching  |
--|   Record.If Found It Will Return TRUE, Otherwise It Will Return False.   |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   The the database using a Cursor Select For the Input Organization      |
--|   If It Finds A matching record It Will return TRUE Otherwise It Will    |
--|   Return False.                                                          |
--|                                                                          |
--| PARAMETERS                                                               |
--|   p_organization_id  IN  NUMBER       - Organization Identifier          |
--|                                                                          |
--| RETURNS                                                                  |
--|   NONE 								     |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+
-- Api end of comments

FUNCTION SEARCH_PROCESS_ORG_DB
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN
IS

BEGIN
-- Open the Defined Global Cursor

  OPEN Cur_get_aprocess_org(P_ORGANIZATION_ID);
  FETCH Cur_get_aprocess_org INTO l_process_rec;
  IF(Cur_get_aprocess_org%NOTFOUND) THEN
  CLOSE Cur_get_aprocess_org;
  -- If failed To retrive Row , return FALSE.
     RETURN FALSE;
  ELSE
  CLOSE Cur_get_aprocess_org;
  -- Close This cursor If Matching Row Found, return TRUE.
     RETURN TRUE;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'SEARCH_PROCESS_ORG_DB'
                            );
    RETURN FALSE;

END search_process_org_db;

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|   ADD_PROCESS_ORG_TO_CACHE                                               |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Function Will Find the MAXIMUM rows in the Organization Cache     |
--|   And then Add this INPUT record To the end of the cache.                |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This Function Will Find the MAXIMUM rows in the Organization Cache     |
--|   And then Add this INPUT record To the end of the cache.                |
--|                                                                          |
--| PARAMETERS                                                               |
--|   p_process_org_rec  IN  INV_GMI_RSV_BRANCH.process_org_rec              |
--|                                                                          |
--| RETURNS                                                                  |
--|   NONE 								     |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+
-- Api end of comments

Procedure add_process_org_to_cache
(
    p_process_org_rec IN  INV_GMI_RSV_BRANCH.process_org_rec
)
IS
tbl_index BINARY_INTEGER :=0;

BEGIN
   -- Set counter To the End Row Of the cache.
   tbl_index := l_process_rec_tbl.COUNT;
   -- Increment counter
   tbl_index := tbl_index +1;
   -- Add this record to Global CACHE.
   l_process_rec_tbl(tbl_index) := l_process_rec;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'ADD_PROCESS_ORG_TO_CACHE'
                            );


END add_process_org_to_cache;

-- Api start of comments
--+==========================================================================+
--| FUNCTION NAME                                                            |
--|   IS_ORG_PROCESS_ORG                                                     |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   A cache of locally defined Discrete Orgs. IF it finds a matching row   |
--|   It will then return FALSE. Else it will then search The cache of       |
--|   Organizations defined as PROCESS Orgs to find a matching  record.      |
--|   If Found It Will Return TRUE, Otherwise It Will Go To the database     |
--|   to find a matching row. If found It Will Add this record to the        |
--|   process cache and Return TRUE else it Will Return FALSE and add this   |
--|   record to the discrete CACHE..                                         |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   A cache of locally defined Discrete Orgs. IF it finds a matching row   |
--|   It will then return FALSE. Else it will then search The cache of       |
--|   Organizations defined as PROCESS Orgs to find a matching  record.      |
--|   If Found It Will Return TRUE, Otherwise It Will Go To the database     |
--|   to find a matching row. If found It Will Add this record to the        |
--|   process cache and Return TRUE else it Will Return FALSE and add this   |
--|   record to the discrete CACHE..                                         |
--|                                                                          |
--| PARAMETERS                                                               |
--|   p_organization_id  IN  NUMBER       - Organization Identifier          |
--|                                                                          |
--| RETURNS                                                                  |
--|   NONE 								     |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|     14-Mar-2005 Rajesh Kulkarni. Removed the earlier caching mechanism.  |
--|                Now only cache G_PROCESS_ORGN for the organization        |
--|                instance                                                  |
--+==========================================================================+
-- Api end of comments

FUNCTION IS_ORG_PROCESS_ORG
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN
IS

/* INVCONV */
-- tbl_index BINARY_INTEGER :=1;
process_enabled mtl_parameters.process_enabled_flag%TYPE;
   CURSOR process_org IS
     SELECT process_enabled_flag
     FROM   mtl_parameters
     WHERE  organization_id = p_organization_id;

BEGIN

-- Always Search Discrete Cache First.

-- INVCONV
/* IF ( search_discrete_org_cache ( P_ORGANIZATION_ID) ) THEN
     RETURN FALSE;
END IF;

IF l_process_rec_tbl.COUNT > 0 THEN
   -- search cache
   IF ( search_process_org_cache( P_ORGANIZATION_ID)) THEN
      RETURN TRUE;
   ELSE
   -- if not found in cache, search database.
      IF ( search_process_org_db( P_ORGANIZATION_ID)) THEN
	     -- IF This Select is True l_process_rec will
	     -- Hold all the record characteristics We Need
	     -- In Global l_process_rec Therefore Add this to the cache.
         add_process_org_to_cache(l_process_rec);
	    RETURN TRUE;
      ELSE
         add_discrete_org_to_cache(P_ORGANIZATION_ID);
	    RETURN FALSE;
      END IF;
   END IF;
ELSE
-- No records EXITS in cache Load Form the database.
-- if not found in cache, search database.

   IF ( search_process_org_db( P_ORGANIZATION_ID)) THEN
      add_process_org_to_cache(l_process_rec);
	 RETURN TRUE;
   ELSE
      add_discrete_org_to_cache(P_ORGANIZATION_ID);
	 RETURN FALSE;
   END IF;

END IF; */
-- Validate Input Attribute p_organization_id;
   IF p_organization_id IS NULL  OR p_organization_id = fnd_api.g_miss_num THEN
      RETURN FALSE;
   END IF;
   process_enabled := 'N';
   INV_GMI_RSV_BRANCH.G_PROCESS_ORGN := 'N';
   OPEN process_org;
   FETCH process_org into process_enabled;
   CLOSE process_org;

   If process_enabled = 'Y'
   Then
        INV_GMI_RSV_BRANCH.G_PROCESS_ORGN := 'Y';
        RETURN TRUE;
   Else
        RETURN FALSE;
   End If;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'IS_ORG_PROCESS_ORG'
                            );
    RETURN FALSE;

END IS_ORG_PROCESS_ORG;
-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|   SEARCH_DISCRETE_ORG_CACHE                                              |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   The cache of Organizations defined as DISCRETE Orgs to find a matching |
--|   Record.If Found It Will Return TRUE, Otherwise It Will Return False.   |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This Function Will Return  A BOOLEAN TRUE or FALSE. It Will Search     |
--|   The cache of Organizations defined as DISCRETE Orgs to find a matching |
--|   Record.If Found It Will Return TRUE, Otherwise It Will Return False.   |
--|                                                                          |
--| PARAMETERS                                                               |
--|   p_organization_id  IN  NUMBER       - Organization Identifier          |
--|                                                                          |
--| RETURNS                                                                  |
--|   NONE 								     |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+
-- Api end of comments

FUNCTION search_discrete_org_cache
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN
IS

tbl_index BINARY_INTEGER :=1;

BEGIN

-- As long as there are records in the cache
-- Search the cache Else return FALSE.

IF l_discrete_rec_tbl.COUNT > 0 THEN
    WHILE tbl_index <= l_discrete_rec_tbl.COUNT
    LOOP
     IF l_discrete_rec_tbl(tbl_index).organization_id = P_ORGANIZATION_ID THEN
        RETURN TRUE;
     END IF;
     tbl_index := tbl_index +1;
    END LOOP;
END IF;

 RETURN FALSE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Search_discrete_org_cache'
                            );
    RETURN FALSE;


END search_discrete_org_cache;

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|   ADD_DISCRETE_ORG_TO_CACHE                                              |
--|                                                                          |
--| TYPE                                                                     |
--|    Global                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|   This Function Will Find the MAXIMUM rows in the Organization Cache     |
--|   And then Add this INPUT record To the end of the cache.                |
--|                                                                          |
--| DESCRIPTION                                                              |
--|   This Function Will Find the MAXIMUM rows in the Organization Cache     |
--|   And then Add this INPUT record To the end of the cache.                |
--|                                                                          |
--| PARAMETERS                                                               |
--|   p_organization_id  IN  NUMBER                                          |
--|                                                                          |
--| RETURNS                                                                  |
--|   NONE 								     |
--|                                                                          |
--| HISTORY                                                                  |
--|     14-FEB-2000  H.Verdding      Created                                 |
--|                                                                          |
--+==========================================================================+
-- Api end of comments

Procedure add_discrete_org_to_cache
(
    P_ORGANIZATION_ID  IN NUMBER
)
IS
tbl_index BINARY_INTEGER :=0;

BEGIN
   -- Set counter To the End Row Of the cache.
   tbl_index := l_discrete_rec_tbl.COUNT;
   -- Increment counter
   tbl_index := tbl_index +1;
   -- Add this record to Global CACHE.
   l_discrete_rec_tbl(tbl_index).organization_id := P_ORGANIZATION_ID;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'ADD_DISCRETE_ORG_TO_CACHE'
                            );


END add_discrete_org_to_cache;


-- Set Initailization Logic
-- This Following Procedures Are called once Per SESSION
BEGIN
   set_installed('GMI');
END INV_GMI_RSV_BRANCH;

/
