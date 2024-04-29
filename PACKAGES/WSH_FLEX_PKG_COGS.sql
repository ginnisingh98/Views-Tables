--------------------------------------------------------
--  DDL for Package WSH_FLEX_PKG_COGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FLEX_PKG_COGS" AUTHID CURRENT_USER AS
/* $Header: WSHWFDFS.pls 115.1 99/07/16 08:24:44 porting shi $ */
--
-- Package
--   WSH_FLEX_PKG_COGS
-- Purpose
--   Will contain routines to generate the default Cost of Goods Sold Accounting
--   flexfield combination(COGS Account)
-- History
--   7-AUG-97  ADATTA    CREATED
--

--
-- PUBLIC VARIABLES
--

--
-- PUBLIC FUNCTIONS
--

-- Name
--   START_PROCESS
-- Purpose
-- Runs the Workflow process to create the COGS Account
-- Arguments
--    Customer ID
--    Flexfield Structure Number
--    Line Detail ID
--    Option Flag
--    Order Line Header ID
--    Order Line ID
--    Picking Line Detail ID
--    Order Type ID
--    Organization ID
--    Code Combination ID

  FUNCTION START_PROCESS(X_COMMITMENT_ID  IN NUMBER,
		   X_CUSTOMER_ID           IN NUMBER,
		   X_OPTION_FLAG           IN VARCHAR2,
             X_ORDER_CATEGORY        IN VARCHAR2,
		   X_LINE_DETAIL_ID        IN NUMBER,
		   X_ORDER_LINE_HEADER_ID  IN NUMBER,
		   X_ORDER_LINE_ID         IN NUMBER,
		   X_PICKING_LINE_DTL_ID   IN NUMBER,
		   X_ORDER_TYPE_ID         IN NUMBER,
		   X_ORG_ID                IN NUMBER,
		   X_FLEX_NUMBER           IN NUMBER,
		   X_RETURN_CCID           IN OUT NUMBER,
		   X_CONCAT_SEGS           IN OUT VARCHAR2,
		   X_CONCAT_IDS            IN OUT VARCHAR2,
		   X_CONCAT_DESCRS         IN OUT VARCHAR2,
		   X_ERRMSG                IN OUT VARCHAR2)
		   RETURN BOOLEAN;

-- Name
--   GET_COST_SALE_ITEM_DERIVED
-- Purpose
-- Derives the COGS account for a line regardless of the option flag
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_COST_SALE_ITEM_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
--   GET_COST_SALE_MODEL_DERIVED
-- Purpose
-- Derives the COGS account for a model
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_COST_SALE_MODEL_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
-- GET_ORDER_TYPE_DERIVED
-- Purpose
-- Derives CCID from the Order Type
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_ORDER_TYPE_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
--  GET_SALESREP_REV_DERIVED
-- Purpose
-- Derives the CCID from Salesrep's revenue segment
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_SALESREP_REV_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);


-- Name
--  GET_SALESREP_ID
-- Purpose
-- Derives the salesrep's ID
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_SALESREP_ID(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
--  GET_COST_SALE
-- Purpose
-- Derives COGS account for an invenrory item id and organization id
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_COST_SALE(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
--  GET_INV_ITEM_ID
-- Purpose
-- Derives inventory item id from order line id
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_INV_ITEM_ID(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
--  GET_TRX_TYPE
-- Purpose
-- Derives the transaction type for a commitment id
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_TRX_TYPE(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
--  GET_OPERATING_UNIT
-- Purpose
-- Derives the selling opoerating unit
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_OPERATING_UNIT(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);

-- Name
--  GET_PARENT_LINE
-- Purpose
-- Derives a parent line id for a order line id
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_PARENT_LINE(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2);
END  WSH_FLEX_PKG_COGS;

 

/
