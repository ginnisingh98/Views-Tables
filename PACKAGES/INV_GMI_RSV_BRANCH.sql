--------------------------------------------------------
--  DDL for Package INV_GMI_RSV_BRANCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_GMI_RSV_BRANCH" AUTHID CURRENT_USER AS
-- $Header: INVGGMIS.pls 120.1 2005/06/11 13:34:43 appldev  $
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
--|     Logic that will allow the code to call PROCESS Inventory ( GMI)     |
--|     Instead Of DISCRETE Inventory (INV).                                |
--|                                                                         |
--| HISTORY                                                                 |
--|     14-FEB-2000  H.Verdding      Created                                |
--|   								            |
--+=========================================================================+
-- API Name  : INV_GMI_RSV_BRANCH
-- Type      : Global
-- Function  : This package contains Global procedures used to Branch code
--             From Within Discrete Inventory (INV) to Process Inventory
---            (GMI).
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 1.0
--
--

-- This is a global cursor defination used
-- for checking existance of OPM Inventory Organization

Cursor Cur_get_aprocess_org
       ( p_organization_id IN NUMBER)
       IS
SELECT p.organization_id,
       w.whse_code,
       s.co_code,
       s.orgn_code
FROM   mtl_parameters p,
       ic_whse_mst w,
       sy_orgn_mst s
WHERE
      w.mtl_organization_id   = p.organization_id
AND   p.ORGANIZATION_ID       = p_organization_id
AND   s.orgn_code             = w.orgn_code
AND   s.orgn_code             = p.process_orgn_code
AND   p.process_enabled_flag  ='Y'
AND   s.delete_mark           = 0
AND   w.delete_mark           = 0
;

-- Record type Definition Of A process_org

TYPE process_org_rec is RECORD
(
  organization_id   MTL_PARAMETERS.ORGANIZATION_ID%TYPE
, whse_code         IC_WHSE_MST.WHSE_CODE%TYPE
, co_code           SY_ORGN_MST.PARENT_ORGN_CODE%TYPE
, orgn_code         SY_ORGN_MST.ORGN_CODE%TYPE
);



-- We Need A Table Of process_org RECORDS

TYPE process_org_rec_tbl is TABLE of process_org_rec
     INDEX BY BINARY_INTEGER;

-- Record type Definition Of A discrete_org

TYPE discrete_org_rec is RECORD
(
  organization_id   MTL_PARAMETERS.ORGANIZATION_ID%TYPE
);



-- We Need A Table Of process_org RECORDS

TYPE discrete_org_rec_tbl is TABLE of discrete_org_rec
     INDEX BY BINARY_INTEGER;

-- Define Global Variable To Hold Process Installed

G_PROCESS_INV_INSTALLED  VARCHAR2(1) DEFAULT 'N';
G_PROCESS_ORGN      VARCHAR2(1) DEFAULT 'N'; /* INVCONV */


FUNCTION PROCESS_BRANCH
(
  P_ORGANIZATION_ID  IN   NUMBER
)
RETURN BOOLEAN;


FUNCTION IS_ORG_PROCESS_ORG
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN;

FUNCTION SEARCH_PROCESS_ORG_CACHE
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN;

FUNCTION SEARCH_DISCRETE_ORG_CACHE
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN;

PROCEDURE ADD_DISCRETE_ORG_TO_CACHE
(
    P_ORGANIZATION_ID IN  NUMBER
);

PROCEDURE SET_INSTALLED
(
   P_APP_SHORT_NAME IN VARCHAR2
);

PROCEDURE GET_PROCESS_ORG
(
    P_ORGANIZATION_ID IN  NUMBER
   ,X_OPM_WHSE_CODE   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,X_OPM_CO_CODE     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,X_OPM_ORGN_CODE   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,X_RETURN_STATUS   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


FUNCTION SEARCH_PROCESS_ORG_DB
(
   P_ORGANIZATION_ID IN  NUMBER
)
RETURN BOOLEAN;

PROCEDURE ADD_PROCESS_ORG_TO_CACHE
(
    P_PROCESS_ORG_REC  IN  INV_GMI_RSV_BRANCH.process_org_rec
);
END INV_GMI_RSV_BRANCH;

 

/
