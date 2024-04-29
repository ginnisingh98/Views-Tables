--------------------------------------------------------
--  DDL for Package CSTPACWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACWF" AUTHID CURRENT_USER AS
/* $Header: CSTACWFS.pls 115.3 2002/11/08 01:10:12 awwang ship $ */

-- FUNCTION
--  START_AVG_WF          Calls the appropriate Average Costing Workflow process
--                        based on the accounting line type.
--
--
-- INPUT PARAMETERS
--   X_TXN_ID number
--   X_TXN_TYPE_ID number
--   X_TXN_ACT_ID number
--   X_TXN_SRC_TYPE_ID number
--   X_ORG_ID number
--   X_ITEM_ID number
--   X_CE_ID number
--   X_ALT number
--   X_CG_ID number
--   X_RES_ID IN number

-- OUTPUT PARAMETERS

--   X_ERR_NUM number     -1 for error, 0 for no error
--   X_ERR_CODE varchar2   System error code (SQLCODE)
--   X_ERR_MSG varchar2  System error message (SQLERRM)

-- RETURN VALUES
--  integer             -1      Use default account.
--                      >0      This is the User defined account.

  FUNCTION START_AVG_WF(X_TXN_ID IN NUMBER,
                          X_TXN_TYPE_ID IN NUMBER,
                          X_TXN_ACT_ID NUMBER,
                          X_TXN_SRC_TYPE_ID IN NUMBER,
	 	          X_ORG_ID  IN NUMBER,
                          X_ITEM_ID IN NUMBER,
                          X_CE_ID IN NUMBER,
                          X_ALT IN NUMBER,
                          X_CG_ID IN NUMBER,
                          X_RES_ID IN NUMBER,
                          X_ERR_NUM OUT NOCOPY NUMBER,
                          X_ERR_CODE OUT NOCOPY VARCHAR2,
                          X_ERR_MSG OUT NOCOPY VARCHAR2)
RETURN integer ;

-- Name
--  GET_AVG_CE
-- Purpose
-- Returns  Cost Element ID.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_AVG_CE(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

-- Name
--  GET_DEF_ACC
-- Purpose
-- Returns  -1 for default accounts.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_DEF_ACC(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);


-- Name
--  GET_AVG_MTL_PLA
-- Purpose
-- Returns Material Product line Account for Average Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_AVG_MTL_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);


-- Name
--  GET_AVG_MO_PLA
-- Purpose
-- Returns Material Overhead Product line Account for Average Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_AVG_MO_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

-- Name
--  GET_AVG_RES_PLA
-- Purpose
-- Returns Resource Product line Account for Average Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_AVG_RES_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

-- Name
--  GET_AVG_OSP_PLA
-- Purpose
-- Returns Outside Processing Product line Account for Average Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_AVG_OSP_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

-- Name
--  GET_AVG_OVH_PLA
-- Purpose
-- Returns Overhead Product line Account for Average Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_AVG_OVH_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

END  CSTPACWF;

 

/
