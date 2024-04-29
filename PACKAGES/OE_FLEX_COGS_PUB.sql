--------------------------------------------------------
--  DDL for Package OE_FLEX_COGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FLEX_COGS_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXWCGSS.pls 120.0 2005/06/01 01:32:31 appldev noship $ */
--
-- Package
--   OE_Flex_Cogs_Pub
-- Purpose
--

--
-- PUBLIC FUNCTIONS
--

-- Name
--   START_PROCESS
-- Purpose
-- Runs the Workflow process to create the COGS Account
-- Arguments
--    Line ID

FUNCTION START_PROCESS( p_api_version_number	IN	NUMBER,
					 p_line_id         IN NUMBER,
x_return_ccid OUT NOCOPY NUMBER,

x_concat_segs OUT NOCOPY VARCHAR2,

x_concat_ids OUT NOCOPY VARCHAR2,

x_concat_descrs OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2)

		   			 RETURN VARCHAR2;

-- Name
--   GET_COST_SALE_ITEM_DERIVED
-- Purpose
-- Derives the COGS account for a line regardless of the option flag
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE GET_COST_SALE_ITEM_DERIVED(itemtype  IN VARCHAR2,
	    	   itemkey     IN VARCHAR2,
		   actid       IN NUMBER,
		   funcmode    IN VARCHAR2,
result OUT NOCOPY VARCHAR2);


-- Name
--   GET_MODEL_DERIVED
-- Purpose
-- Derives the COGS account for a line based on it's model line if the line is
-- an option line
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE Get_Model_Derived(itemtype  IN VARCHAR2,
	    	   itemkey     IN VARCHAR2,
		   actid       IN NUMBER,
		   funcmode    IN VARCHAR2,
result OUT NOCOPY VARCHAR2);


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
RESULT OUT NOCOPY VARCHAR2);


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
RESULT OUT NOCOPY VARCHAR2);



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
RESULT OUT NOCOPY VARCHAR2);


-- Name
--  Get_Invitm_Org_Derived
-- Purpose
-- Derives COGS account for an invenrory item id and Selling operating unit
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE Get_Invitm_Org_Derived(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
RESULT OUT NOCOPY VARCHAR2);


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
RESULT OUT NOCOPY VARCHAR2);


-- Name
--  Check_Option
-- Purpose
-- Checks if a line is an option line or not
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE Check_Option(itemtype  IN VARCHAR2,
			itemkey     IN VARCHAR2,
		   	actid       IN NUMBER,
		   	funcmode    IN VARCHAR2,
result OUT NOCOPY VARCHAR2);


-- Name
--   UPGRADE_COGS_FLEX
-- Purpose
-- To upgrade an existing flexbuilder function
-- Arguments
--    Internal Name for the WF Item Type
--    WF Item Key
--    ID Number of thw WF activity
--    Result

PROCEDURE UPGRADE_COGS_FLEX(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY	IN VARCHAR2,
		   ACTID	     IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
RESULT OUT NOCOPY VARCHAR2);

-- Name
--   BUILD
-- Purpose
-- Ts is a stub build function that returns a value FALSE and
-- sets the value of the output varriable FB_FLEX_SEGto NULL and
-- output error message variable FB_ERROR_MSG to the AOL error
-- message FLEXWK-UPGRADE FUNC MISSING. This will ensure that the
-- user will get an appropriate error message if they try to use
-- the FLEXBUILDER_UPGRADE process without creating the conversion
-- package successfully.   o upgrade an existing flexbuilder function
-- Arguments
--    Flexfield  Structure Number
--    Commitment ID
--    Customrer ID
--    Header ID
--    Option Flag
--    Order Category
--    Line ID
--    Order Type ID
--    Organization ID
--    Flexfield Segments
--    Error Message

FUNCTION BUILD (
      fb_flex_num IN NUMBER DEFAULT 101,
      oe_ii_commitment_id_raw IN VARCHAR2 DEFAULT NULL,
      oe_ii_customer_id_raw IN VARCHAR2 DEFAULT NULL,
      oe_ii_header_id_raw IN VARCHAR2 DEFAULT NULL,
      oe_ii_option_flag_raw IN VARCHAR2 DEFAULT NULL,
      oe_ii_order_category_raw IN VARCHAR2 DEFAULT NULL,
      oe_ii_order_line_id_raw IN VARCHAR2 DEFAULT NULL,
      oe_ii_order_type_id_raw IN VARCHAR2 DEFAULT NULL,
      oe_ii_organization_id_raw IN VARCHAR2 DEFAULT NULL,
      fb_flex_seg IN OUT NOCOPY VARCHAR2,
      fb_error_msg IN OUT NOCOPY VARCHAR2)
	 RETURN BOOLEAN;

PROCEDURE Get_Type_From_Line
(       itemtype    IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
result OUT NOCOPY VARCHAR2);


END  OE_Flex_Cogs_Pub;




 

/
