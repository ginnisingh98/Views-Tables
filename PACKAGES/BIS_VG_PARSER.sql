--------------------------------------------------------
--  DDL for Package BIS_VG_PARSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_PARSER" AUTHID CURRENT_USER AS
/* $Header: BISTPARS.pls 115.7 2002/03/27 08:18:44 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTPARS.pls
--
--  DESCRIPTION
--
--      Spec of view parser to be used in the view generator
--         package specifyling the view security
--
--  NOTES
--
--  HISTORY
--
--  21-JUL-98 Created
--  19-MAR-99 Edited by WNASRALL@US for exception handling
--  10-DEC-01 Edited by DBOWLES Added db driver comment
--
-- this function starts looking for the start of any of the strigns
-- specified in the string set in the p_view_table beginning from
-- the p_start_pointer.
-- returns a pointer pointing to the beginning of such a string found
-- else null

FUNCTION Get_Keyword_Position
( p_view_table    IN bis_vg_types.View_Text_Table_Type
, p_string_set    IN bis_vg_types.View_Text_Table_Type
, p_start_pointer IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
return bis_vg_types.view_character_pointer_type;

-- this functions returns the string between the start position and
-- any of the delimiters in the delimiter string
-- the end position points beyond the delimiter or is null if end of line

FUNCTION get_string_token
( p_view_str         IN  bis_vg_types.View_Text_Table_Rec_Type
, p_start            IN  NUMBER
, p_delimiter_string IN  VARCHAR2
, x_end_pointer      OUT NUMBER
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2;


-- this functions returns the string between the start pointer and
-- any of the delimiters in the delimiter string
-- the end pointer points at the delimiter

FUNCTION get_token
( p_view_table       IN bis_vg_types.View_Text_Table_Type
, p_start_pointer    IN  bis_vg_types.View_Character_Pointer_Type
, p_delimiter_string IN  VARCHAR2
, x_end_pointer      OUT bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2;

-- this functions returns the string expression between the start pointer and
-- single quote ending the expression. Takes care of nested strings in the
-- expression

FUNCTION get_expression
( p_view_table       IN bis_vg_types.View_Text_Table_Type
, p_start_pointer    IN  bis_vg_types.View_Character_Pointer_Type
, x_end_pointer      OUT bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2;

-- this functions returns the string between the start pointer and
-- any of the delimiters in the delimiter string
-- the end pointer points one beyond the delimiter

FUNCTION get_token_increment_pointer
( p_view_table       IN bis_vg_types.View_Text_Table_Type
, p_start_pointer    IN  bis_vg_types.View_Character_Pointer_Type
, p_delimiter_string IN  VARCHAR2
, x_end_pointer      OUT bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2;

-- skips the type of tag
-- returns the tag
-- the out pointer is positioned beyond the separator
FUNCTION skip_tag
( p_view_table    IN  BIS_VG_TYPES.View_Text_Table_Type
, p_start_pointer IN  BIS_VG_TYPES.view_character_pointer_type
, X_end_pointer   OUT BIS_VG_TYPES.view_character_pointer_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2;

END BIS_VG_PARSER;

 

/
