--------------------------------------------------------
--  DDL for Package BIS_VG_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_SECURITY" AUTHID CURRENT_USER AS
/* $Header: BISTSECS.pls 115.7 2002/03/27 08:18:50 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTSECS.pls
--
--  DESCRIPTION
--
--      specification of security package
--
--  NOTES
--
--  HISTORY
--
--  23-JUL-98 Created
--  10-DEC-01 Edited by DBOWLES Added db driver comment
--
--
--
--============================================================================
--PROCEDURE : parse_SEC_select
--  PARAMETERS:
--  1. p_View_Select_Table  table of varchars to hold select
--  2. p_pointer     	    pointer to the lookup column in select table
--  3. x_tbl 		    name of security column
--  4. x_app	  	    the application to use for security
--  5. x_pointer	    pointer to the character after the delimiter
-- 			    (select table)
--  6. x_return_status      error or normal
--  7. x_error_Tbl          table of error messages
----
--  COMMENT   : Call this procedure to add a particular lookup select
--              information to a view.
--EXCEPTION : None
--  ==========================================================================
PROCEDURE parse_SEC_select
( p_View_Select_Table 	IN  BIS_VG_TYPES.View_Text_Table_Type
, p_pointer    	IN  BIS_VG_TYPES.View_Character_Pointer_Type
, x_tbl      		OUT VARCHAR2
, x_app      		OUT VARCHAR2
, x_pointer    	OUT BIS_VG_TYPES.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
);

/* ============================================================================
   PROCEDURE : add_Security_Info
     PARAMETERS:
     1. p_View_Select_Table  table of varchars to hold SELECT clause of view
     2. p_From_Pointer       pointer to the corresponding from clause
     3. x_Select_Table       table of varchars to hold additional columns
     4. x_security_pointer   pointer at end of security
     5. x_return_status    error or normal
     6. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to add a security information to a view.
   EXCEPTION : None
  ===========================================================================*/
PROCEDURE add_Security_Info
( p_View_Select_Table IN  BIS_VG_TYPES.View_Text_Table_Type
, p_security_pointer  IN  BIS_VG_TYPES.view_character_pointer_type
, x_Select_Table      OUT BIS_VG_TYPES.view_text_table_type
, x_security_pointer  OUT  BIS_VG_TYPES.view_character_pointer_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
);
--
/*============================================================================
  EXCEPTIONS
  ===========================================================================*/
--  MALFORMED_SECURITY_TAG EXCEPTION;
  SECURITY_COL_EXP_MSG CONSTANT VARCHAR2(50):= 'BIS_VG_MALFORMED_SECURITY_TAG';
  SECURITY_FUN_EXP_MSG CONSTANT VARCHAR2(50):= 'BIS_VG_UNDEFINED_SECURITY_TAG';
END BIS_VG_SECURITY;

 

/
