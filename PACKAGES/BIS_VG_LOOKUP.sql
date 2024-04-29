--------------------------------------------------------
--  DDL for Package BIS_VG_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_LOOKUP" AUTHID CURRENT_USER AS
/* $Header: BISTLATS.pls 115.7 2002/03/27 08:18:38 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTLATS.pls
--
--  DESCRIPTION
--
--      specification of view genrator to substitute lookup type
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
--
/* ============================================================================
   PROCEDURE : add_Lookup_Info
     PARAMETERS:
     1. p_View_Column_Table  table of varchars to hold columns OF view text
     2. p_View_Select_Table  table of varchars to hold SELECT clause of view
     3. p_Mode               mode of execution of the program
     3. p_Column_Pointer     pointer to the lookup column in column table
     4. p_Select_Pointer     pointer to the select clause
     5. p_From_Pointer       pointer to the corresponding from clause
     6. x_Column_Table       table of varchars to hold additional columns
     7. x_Select_Table       table of varchars to hold additional columns
     8. x_Column_Pointer     pointer to the character after the delimiter
                             (column table)
     9. x_Select_Pointer     pointer to the character after the delimiter
                             (select table)
    10. x_return_status    error or normal
    11. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to add a particular lookup information
               to a view.
   EXCEPTION : None
  ===========================================================================*/
   PROCEDURE add_Lookup_Info
   ( p_View_Column_Table IN  BIS_VG_TYPES.View_Text_Table_Type
   , p_View_Select_Table IN  BIS_VG_TYPES.View_Text_Table_Type
   , p_Mode              IN  NUMBER
   , p_Column_Pointer    IN  BIS_VG_TYPES.View_Character_Pointer_Type
   , p_Select_Pointer    IN  BIS_VG_TYPES.View_Character_Pointer_Type
   , x_Column_Table      OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_Select_Table      OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_Column_Pointer    OUT BIS_VG_TYPES.View_Character_Pointer_Type
   , x_Select_Pointer    OUT BIS_VG_TYPES.View_Character_Pointer_Type
   , x_return_status     OUT VARCHAR2
   , x_error_Tbl         OUT BIS_VG_UTIL.Error_Tbl_Type
   );

--============================================================================
--PROCEDURE : parse_LA_select
--  PARAMETERS:
--  1. p_View_Select_Table  table of varchars to hold select OF view text
--  2. p_Select_Pointer     pointer to the lookup column in select table
--  3. x_expr 		  PL-SQL expression or column name
--  4. x_lookup_table	  Lookup table to insert in select
--  5. x_lookup_type	  Lookup code in the lookup table
--  6. x_lookup_column	  name of column in lookup table
--  7. x_Select_Pointer     pointer to the character after the delimiter
--                          (select table)
--  8. x_return_status    error or normal
--  9. x_error_Tbl        table of error messages
----
--  COMMENT   : Call this procedure to add a particular lookup select
--              information to a view.
--EXCEPTION : None
--  ==========================================================================
PROCEDURE parse_LA_select
( p_View_Select_Table 	IN  BIS_VG_TYPES.View_Text_Table_Type
, p_Select_Pointer    	IN  BIS_VG_TYPES.View_Character_Pointer_Type
, x_expr          	OUT VARCHAR2
, x_lookup_table  	OUT VARCHAR2
, x_lookup_type   	OUT VARCHAR2
, x_lookup_column 	OUT VARCHAR2
, x_Select_Pointer    	OUT BIS_VG_TYPES.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
);

--
/*============================================================================
  EXCEPTIONS
  ===========================================================================*/
--  MALFORMED_LAT_COL_TAG EXCEPTION;
--  MALFORMED_LAT_SEL_TAG_NO_EXPR EXCEPTION;
--  MALFORMED_LAT_SEL_TAG_NO_TABLE EXCEPTION;
--  MALFORMED_LAT_SEL_TAG_NO_TYPE EXCEPTION;
--  MALFORMED_LAT_SEL_TAG_NO_COL EXCEPTION;
--  LAT_INVALID_LOOKUP_TYPE     EXCEPTION;

  LAT_COL_TAG_EXP_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_MALFORMED_LAT_COL_TAG';

  LAT_COL_TAG_EXP_NO_EXP_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_LAT_SEL_MISSING_EXP';

  LAT_SEL_TAG_EXP_NO_TABLE_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_LAT_SEL_MISSING_TABLE';

  LAT_SEL_TAG_EXP_NO_TYPE_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_LAT_SEL_MISSING_TYPE';

  LAT_SEL_TAG_EXP_NO_COL_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_LAT_SEL_MISSING_COL';
  LAT_SEL_TAG_UNDEF_TAB CONSTANT VARCHAR2(50)
                                := 'BIS_VG_LAT_SEL_UNDEF_TAB_COL';

  LAT_INVALID_LOOKUP_TYPE_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_LAT_INVALID_LKUP_TYPE';

--
END BIS_VG_LOOKUP;

 

/
