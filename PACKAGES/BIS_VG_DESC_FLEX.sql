--------------------------------------------------------
--  DDL for Package BIS_VG_DESC_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_DESC_FLEX" AUTHID CURRENT_USER AS
/* $Header: BISTDFXS.pls 115.18 2002/03/27 08:18:35 pkm ship     $ */

----------------------------------------------------------------
---  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---      BISTDFXS.pls
---
---  DESCRIPTION
---
---      specification of package which handles descriptive flexfield tags
---
---  NOTES
---
---  HISTORY
---
---  29-JUL-98 Created
---  19-MAR-99 Edited by WNASRALL@US for exception handling
---  10-NOV-00 Edited by WNASRALL@US to  add new function generate_pruned_view
---  06-APR-01 Edited by Don Bowles added new out parameter to add_Desc_Flex_Info
---            x_Column_Comment_Table to store flex data.
---  10-DEC-01 Edited by DBOWLES Added db driver comment
---
---
--- ============================================================================
---   PROCEDURE : add_Desc_Flex_Info
---   PARAMETERS:
---            1. p_View_Column_Table  table of varchars to hold columns of
---                                       view text
---            2. p_View_Select_Table  table of varchars to hold select clause
---                                    of view
---            3. p_Mode               mode of execution of the program
---            4. p_column_table       List of columns for calls from generate_pruned_view
---            5. p_Column_Pointer     pointer to the desc flex column in
---                                    column table
---            6. p_Select_Pointer     pointer to the select clause
---            6. p_From_Pointer       pointer to the corresponding from clause
---            8. x_Column_Table       table of varchars to hold additional
---                                    columns
---            9. x_Select_Table       table of varchars to hold additional
---                                    columns
---           10. x_Column_Comment_Table table of Flex_Column_Comment_Rec_Type
---                                    used to hold flex data as it is gathered.
---           11. x_Column_Pointer     pointer to the character after the
---                                    delimiter
---                                    (column table)
---           12. x_Select_Pointer     pointer to the character after the
---                                    delimiter
---                                    (select table)
---           13. x_return_status    error or normal
---           14. x_error_Tbl        table of error messages
---
---   COMMENT   : Call this procedure to add a particular desc flexfield
---               information to a view.
---   ---
---  ==========================================================================

PROCEDURE add_Desc_Flex_Info
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


-- ============================================================================
-- PROCEDURE : parse_DF_Select_Line
-- PARAMETERS: 1. p_View_Select_Table table of varchars to hold select clause
--                                    of view text
--             2. p_Select_Pointer    pointer to the key flex column in select
--                                    table (IN)
--             3. x_Select_Pointer    pointer to the char after the delimiter
--                                    in select table (OUT)
--             4. x_Application_Name  Application Name
--             5. x_Desc_Flex_Name    Desc Flexfield name
--             6. x_Table_Alias       Table alias
--             7. x_return_status    error or normal
--             8. x_error_Tbl        table of error messages
-- COMMENT   : Call this procedure to parse the DF selected tag.
-- ---
-- =============================================================================
PROCEDURE parse_DF_Select_Line
( p_View_Select_Table IN  bis_vg_types.View_Text_Table_Type
, p_Select_Pointer    IN  bis_vg_types.View_Character_Pointer_Type
, x_Select_Pointer    OUT bis_vg_types.View_Character_Pointer_Type
, x_Application_Name  OUT VARCHAR2
, x_Desc_Flex_Name    OUT VARCHAR2
, x_Table_Alias       OUT VARCHAR2
, x_DUMMY_flag        OUT BOOLEAN
, x_return_status     OUT VARCHAR2
, x_error_Tbl         OUT BIS_VG_UTIL.Error_Tbl_Type
);
--
--============================================================================
-- Exceptions for the package
--============================================================================
--

  MALFORMED_DFX_COL_TAG_BAD_FLAG EXCEPTION;
  DFX_COL_TAG_EXP_BAD_FLAG_MSG CONSTANT VARCHAR2(50)
    := 'BIS_VG_DFX_COL_BAD_FLAG';

  DFX_COL_TAG_EXP_INVALID_FLAG CONSTANT VARCHAR(50)
                                := 'BIS_VG_DFX_COL_INVALID_FLAG';

  DFX_SEL_TAG_EXP_NO_APP_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_DFX_SEL_MISSING_APP';

  DFX_SEL_TAG_EXP_NO_NAME_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_DFX_SEL_MISSING_NAME';

  DFX_SEL_TAG_EXP_NO_TABLE_MSG CONSTANT VARCHAR2(50)
                                := 'BIS_VG_DFX_SEL_MISSING_TABLE';

  DFX_SEL_TAG_EXP_INVALID_APP CONSTANT VARCHAR2(50)
                                := 'BIS_VG_DFX_SEL_INVALID_APP';

--  MALFORMED_DFX_SEL_TAG_NO_APP EXCEPTION;
--  MALFORMED_DFX_SEL_TAG_NO_TABLE EXCEPTION;
--  MALFORMED_DFX_SEL_TAG_NO_NAME EXCEPTION;

END BIS_VG_DESC_FLEX;

 

/
