--------------------------------------------------------
--  DDL for Package WSH_FLEX_UPGR_COGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FLEX_UPGR_COGS" AUTHID CURRENT_USER AS
/* $Header: WSHWFUPS.pls 115.1 99/07/16 08:24:52 porting shi $ */
--
-- Package
--   WSH_FLEX_UPGR_COGS
-- Purpose
--   Will contain routines to upgrade an existing flexbuilder function
--   for the COGS Account
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
		   RESULT      OUT VARCHAR2);
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
--    Line Detail ID
--    Option Flag
--    Order Category
--    Line ID
--    Order Type ID
--    Organization ID
--    Picking Line Detail ID
--    Flexfield Segments
--    Error Message

      FUNCTION BUILD (
      FB_FLEX_NUM IN NUMBER DEFAULT 101,
      OE_II_COMMITMENT_ID_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_CUSTOMER_ID_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_HEADER_ID_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_LINE_DETAIL_ID_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_OPTION_FLAG_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_ORDER_CATEGORY_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_ORDER_LINE_ID_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_ORDER_TYPE_ID_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_ORGANIZATION_ID_RAW IN VARCHAR2 DEFAULT NULL,
      OE_II_PICK_LINE_DETAIL_ID_RAW IN VARCHAR2 DEFAULT NULL,
      FB_FLEX_SEG IN OUT VARCHAR2,
      FB_ERROR_MSG IN OUT VARCHAR2)
	 RETURN BOOLEAN;
END WSH_FLEX_UPGR_COGS;

 

/
