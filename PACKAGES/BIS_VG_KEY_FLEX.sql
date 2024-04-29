--------------------------------------------------------
--  DDL for Package BIS_VG_KEY_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_KEY_FLEX" AUTHID CURRENT_USER AS
/* $Header: BISTKFXS.pls 115.18 2002/03/27 08:18:37 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---      BISTKFXS.pls
---
---  DESCRIPTION
---
---      specification of package which handles key flexfield tags
---
---  NOTES
---
---  HISTORY
---
---  29-JUL-98 Created
---  19-MAR-99 Edited by WNASRALL@US for exception handling
---  21-Apr-99 Edited by WNASRALL@US to re-use exception definition
---            for missing fields
---  10-NOV-00 Edited by WNASRALL@US to  add new function generate_pruned_view
---  06-APR-01 Edited by DBOWLES.  modified add_key_flex_info parameter list.  Added
---            x_Column_Comment_Table.
---  10-DEC-01 Edited by DBOWLES Added db driver comment
---
---
--- =====================================================================================
---   PROCEDURE : add_Key_Flex_Info
---   PARAMETERS: 1. p_View_Column_Table  table of varchars to hold columns of view text
---               2. p_View_Select_Table  table of varchars to hold select clause of view
---               3. p_Mode               mode of the program
---               4. p_column_table       List of columns for calls from generate_pruned_view
---               5. p_Column_Pointer     pointer to the key flex column in column table
---               6. p_Select_Pointer     pointer to the select clause
---               7. p_From_Pointer       pointer to the corresponding from clause
---               8. x_Column_Table       table of varchars to hold additional columns
---               9. x_Select_Table       table of varchars to hold additional columns
---              10. x_Column_Comment_Table table to store flex column data to be used
---                                         to comment the flex columns of the generated view
---              11. x_Column_Pointer     pointer to the character after the delimiter
---                                       (column table)
---              12. x_Select_Pointer     pointer to the character after the delimiter
---                                       (select table)
---              13. x_return_status    error or normal
---              14. x_error_Tbl        table of error messages
---
---   COMMENT   : Call this procedure to add particular key flexfield information to a view.
---   ---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
--- ==================================================================================== */
PROCEDURE add_Key_Flex_Info
( p_View_Column_Table    IN  BIS_VG_TYPES.View_Text_Table_Type
, p_View_Select_Table    IN  BIS_VG_TYPES.View_Text_Table_Type
, p_Mode                 IN  NUMBER
, p_column_table         IN  BIS_VG_TYPES.flexfield_column_table_type
, p_Column_Pointer       IN  BIS_VG_TYPES.View_Character_Pointer_Type
, p_Select_Pointer       IN  BIS_VG_TYPES.View_Character_Pointer_Type
, p_From_Pointer         IN  BIS_VG_TYPES.View_Character_Pointer_Type
, x_Column_Table         OUT BIS_VG_TYPES.View_Text_Table_Type
, x_Select_Table         OUT BIS_VG_TYPES.View_Text_Table_Type
, x_Column_Comment_Table OUT BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, x_Column_Pointer       OUT BIS_VG_TYPES.View_Character_Pointer_Type
, x_Select_Pointer       OUT BIS_VG_TYPES.View_Character_Pointer_Type
, x_return_status        OUT VARCHAR2
, x_error_Tbl            OUT BIS_VG_UTIL.Error_Tbl_Type
);

--- ============================================================================
--- PROCEDURE : parse_KF_Select_Line
--- PARAMETERS: 1. p_View_Select_Table table of varchars to hold select clause
---                                    of view text
---             2. p_Select_Pointer    pointer to the key flex column in select
---                                    table (IN)
---             3. x_Select_Pointer    pointer to the char after the delimiter in
---                                    select table (OUT)
---             4. x_PLSQL_Expression  PL/SQL expression
---             5. x_Application_Name  Application Name
---             6. x_Key_Flex_Code     Key Flexfield code
---             7. x_Table_Alias       Table alias
---             8. x_Structure_Column  Structure Column Name
---             9. x_return_status    error or normal
---            10. x_error_Tbl        table of error messages
--- COMMENT   : Call this procedure to parse the KF selected tag.
---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
--- =============================================================================
PROCEDURE parse_KF_Select_Line
( p_View_Select_Table IN  bis_vg_types.View_Text_Table_Type
, p_Select_Pointer    IN  bis_vg_types.View_Character_Pointer_Type
, x_Select_Pointer    OUT bis_vg_types.View_Character_Pointer_Type
, x_PLSQL_Expression  OUT VARCHAR2
, x_Application_Name  OUT VARCHAR2
, x_Key_Flex_Code     OUT VARCHAR2
, x_Table_Alias       OUT VARCHAR2
, x_Structure_Column  OUT VARCHAR2
, x_DUMMY_flag        OUT BOOLEAN
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
);




--
--============================================================================
-- Exceptions for the package
--============================================================================
--

  KFX_COL_TAG_EXP_NO_SEG_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_KFX_COL_MISSING_SEG';

  KFX_COL_TAG_EXP_BAD_FLAG_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_KFX_COL_BAD_FLAG';

  KFX_COL_TAG_PREF_CO_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_KFX_COL_PREF_CO';

  KFX_SEL_TAG_EXP_NO_FIELD_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_KFX_SEL_MISSING_FIELD';

  KFX_SEL_TAG_EXP_INVALID_APP CONSTANT VARCHAR2(50)
                                := 'BIS_VG_KFX_SEL_INVALID_APP';

  NO_SEGMENTS_IN_KEY_FLEX EXCEPTION;
  NO_SEGMENTS_IN_KEY_FLEX_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_NO_SEGMENTS_IN_KEY_FLEX';

  MALFORMED_KFX_SEL_TAG_NO_FIELD EXCEPTION;
--============================================================================
-- UNUSED Exceptions
--============================================================================

  --  MALFORMED_KFX_COL_TAG_NO_SEG EXCEPTION;
--  MALFORMED_KFX_COL_TAG_BAD_FLAG EXCEPTION;
--  MALFORMED_KFX_COL_TAG_PREF_CO EXCEPTION;
--  MALFORMED_KFX_SEL_TAG_NO_APP EXCEPTION;
--  MALFORMED_KFX_SEL_TAG_NO_NAME EXCEPTION;
--  MALFORMED_KFX_SEL_TAG_NO_TBALS EXCEPTION;
--  MALFORMED_KFX_SEL_TAG_NO_EXPR EXCEPTION;
--  NO_SEGMENTS_IN_KEY_FLEX EXCEPTION;
--  KFX_SEL_TAG_EXP_NO_APP_MSG CONSTANT VARCHAR2(50)
--                                := 'BIS_VG_KFX_SEL_MISSING_APP';
--
--  KFX_SEL_TAG_EXP_NO_TBALS_MSG CONSTANT VARCHAR2(50)
--                                := 'BIS_VG_KFX_SEL_MISSING_TBALS';
--
--  KFX_SEL_TAG_EXP_NO_NAME_MSG CONSTANT VARCHAR2(50)
--                                := 'BIS_VG_KFX_SEL_MISSING_NAME';
--
--  KFX_SEL_TAG_EXP_NO_EXPR_MSG CONSTANT VARCHAR2(50)
--                                := 'BIS_VG_KFX_SEL_MISSING_EXPR';


END BIS_VG_KEY_FLEX;

 

/
