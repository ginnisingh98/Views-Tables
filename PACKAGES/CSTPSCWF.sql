--------------------------------------------------------
--  DDL for Package CSTPSCWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSCWF" AUTHID CURRENT_USER AS
/* $Header: CSTSCWFS.pls 115.4 2002/11/11 23:53:08 awwang ship $ */

-- FUNCTION
--  START_STD_WF      Calls the appropriate Standard Costing Workflow process
--                    based on the accounting line type.
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
--   X_SUBINV varchar2
--   X_CG_ID number
--   X_RES_ID IN number

-- OUTPUT PARAMETERS
--   X_ERR_NUM number     -1 for error, 0 for no error
--   X_ERR_CODE varchar2   System error code (SQLCODE)
--   X_ERR_MSG varchar2  System error message (SQLERRM)

-- RETURN VALUES
--  integer             -1      Use default account.
--                      >0      This is the User defined account.

  FUNCTION START_STD_WF(X_TXN_ID IN NUMBER,
                          X_TXN_TYPE_ID IN NUMBER,
                          X_TXN_ACT_ID NUMBER,
                          X_TXN_SRC_TYPE_ID IN NUMBER,
	 	          X_ORG_ID  IN NUMBER,
                          X_ITEM_ID IN NUMBER,
                          X_CE_ID IN NUMBER,
                          X_ALT IN NUMBER,
                          X_SUBINV IN VARCHAR2,
                          X_CG_ID IN NUMBER,
                          X_RES_ID IN NUMBER,
                          X_ERR_NUM OUT NOCOPY NUMBER,
                          X_ERR_CODE OUT NOCOPY VARCHAR2,
                          X_ERR_MSG OUT NOCOPY VARCHAR2)
 RETURN integer ;

-- Name
--  GET_STD_CE
-- Purpose
-- Returns  Cost Element ID.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_STD_CE(ITEMTYPE  IN VARCHAR2,
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
--  GET_STD_MTL_PLA
-- Purpose
-- Returns Material Product line Account for Standard Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_STD_MTL_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);


-- Name
--  GET_STD_MO_PLA
-- Purpose
-- Returns Material Overhead Product line Account for Standard Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_STD_MO_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

-- Name
--  GET_STD_RES_PLA
-- Purpose
-- Returns Resource Product line Account for Standard Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_STD_RES_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

-- Name
--  GET_STD_OSP_PLA
-- Purpose
-- Returns Outside Processing Product line Account for Standard Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_STD_OSP_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

-- Name
--  GET_STD_OVH_PLA
-- Purpose
-- Returns Overhead Product line Account for Standard Costing.
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of the WF activity
--    Result

PROCEDURE GET_STD_OVH_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2);

END  CSTPSCWF;

 

/
