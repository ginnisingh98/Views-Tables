--------------------------------------------------------
--  DDL for Package OE_CREDIT_CHECK_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_CHECK_GLOBALS" AUTHID CURRENT_USER AS
-- $Header: OEXGCRCS.pls 120.0 2005/05/31 23:27:41 appldev noship $

--------------------
-- TYPE DECLARATIONS
--------------------

TYPE lines_Rec_tbl_type IS TABLE OF OE_CREDIT_CHECK_UTIL.lines_Rectype
     INDEX BY BINARY_INTEGER;


TYPE ITEM_LIMITS_TBL_TYPE IS TABLE OF OE_CREDIT_CHECK_UTIL.Items_Limit_Rec
     INDEX BY BINARY_INTEGER;


TYPE USAGE_CURR_TBL_TYPE IS TABLE OF OE_CREDIT_CHECK_UTIL.Usage_Curr_Rec
     INDEX BY BINARY_INTEGER;

------------
-- CONSTANTS
------------

--- The following constant is used to track the
--- Multi currency credit checking enhancements

-----------------------------------------------
---------- OM patchset H   = 10
---------- OM patchset G   = 5
---------- OM patchset < G = 0


----------------------------------------------

  G_MCC_project_version NUMBER := 10 ;
-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
-----------------------------------------------------------------------------
--  FUNCTION: GET_MCC_project_version
--  COMMENT    : Returns the G_MCC_project_version
--
------------------------------------------------------------------------------
FUNCTION   GET_MCC_project_version
RETURN NUMBER ;



END OE_Credit_Check_globals;

 

/
