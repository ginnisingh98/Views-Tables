--------------------------------------------------------
--  DDL for Package Body BIS_VIEW_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VIEW_GENERATOR_PVT" AS
/* $Header: BISTBVGB.pls 120.1.12010000.2 2008/10/24 23:54:52 dbowles ship $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---      BISTBVGB.pls
---
---  DESCRIPTION
---
---      body of package which generates the business views
---
---  NOTES
---
---  HISTORY
---
---  29-JUL-98 surao created
---  19-MAR-99 Edited by WNASRALL@US: for exception handling)
---  21-Apr-99 Edited by WNASRALL@US: commented out various debug statements.
---  18-NOV-99 Edited by DBOWLES@US:  added check for p_debug before
---                                   DBMS_OUTPUT
---  10-NOV-00 Edited by WNASRALL@US: added new function generate_pruned_view
---  19-DEC-00 Edited by ILI@US:      changed generate_pruned_view to obtain
---                                   segment list across database link
---  20-DEC-00 Edited by WNASRALL@US: Added update generate status across
---                                   database link to generate_view
---                                   and generate_pruned_view
---  26-DEC-00 Edited by WNASRALL@US: final debug of cross-database links
---  02-FEB-00 Edited by WNASRALL@US: preparation for base table select
---  06-APR-00 Edited by DBOWLES.  Modified update_flexfields
---            procedure, update_View procedure passing parameter of
---            bis_vg_types.Flex_Column_Comment_Table_Type.  Created new procedure
---            comment_Flex_Columns which is called after the view is generated.
---            This procedure will comment columns derived from flexfield
---            with data regarding specifics of the flexfield definition.
---  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
---  31-JAN-02 Fix bug 2208122 by phu
---  10-MAY-02 Fix bug 2369734 by phu
---  12-JAN-05 Fix bug 4093769 by amitgupt
---  18-JAN-05 Modified by AMITGUPT for GSCC warnings
--============================================================================
-- CONSTANTS
--============================================================================

G_PKG_NAME           CONSTANT  VARCHAR2(60) :='BIS_VIEW_GENERATOR_PVT';

g_newline            CONSTANT  VARCHAR2(1):='
';

g_tab                CONSTANT  VARCHAR2(1):='	';

update_status_stmt   CONSTANT  VARCHAR2(320) :=
  'UPDATE EDW_LOCAL_GENERATION_STATUS
  SET generate_status = :status,
  error_message = :error,
  last_update_date = Sysdate
  WHERE flex_view_name = :viewname'
;

insert_status_stmt   CONSTANT  VARCHAR2(560) :=
  'INSERT INTO  EDW_LOCAL_GENERATION_STATUS
  (FLEX_VIEW_NAME,
   GENERATE_STATUS,
   ERROR_MESSAGE,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   CREATED_BY,
   CREATION_DATE)
  values
  (  :viewname,
     :status,
     :error,
     sysdate,0,0,0,Sysdate
     )'
;

base_table_v_query_stmt CONSTANT  VARCHAR2(2000) :=
  'SELECT  upper(table_name),
  upper(table_alias),
  upper(source_column_name)
  FROM edw_view_gen_base_table_v@edw_apps_to_wh
  WHERE
  instance_code = :1
  AND
  flex_view_name = :2
  ORDER BY table_name, table_alias'
  ;

selection_v_query_stmt CONSTANT  VARCHAR2(2000) :=
  'SELECT
  structure _num,
  structure_name ,
  application_column_name,
  segment_name,
  segment_datatype,
  id_flex_code,
  flex_field_type,
  flex_field_name,
  application_name,
  FROM    edw_view_gen_flex_v@edw_apps_to_wh
  WHERE   object_short_name = :1
  AND     instance_code = :2 '
  ; --- For use in release 4.0

selection_query_stmt CONSTANT  VARCHAR2(2000) :=
  'SELECT
  a.structure_num,
  a.structure_name ,
  a.application_column_name,
  a.segment_name,
  a.value_set_datatype,
  a.id_flex_code,
  decode(a.flex_field_type,''A'',''K'',a.flex_field_type),
  a.flex_field_name,
  c.application_short_name application_name
  FROM    edw_flex_seg_mappings@edw_apps_to_wh a,
  edw_fact_flex_fk_maps@edw_apps_to_wh b,
  fnd_application@edw_apps_to_wh c
  WHERE   b.fact_short_name = :1
  AND   b.enabled_flag =''Y''
  AND   b.dimension_short_name = a.dimension_short_name
  AND   a.instance_code = :2
  AND   c.application_id = a.application_id
  union
  select distinct
  b.structure_num,
  b.structure_name,
  b.application_column_name,
  b.segment_name,
  b.value_set_datatype,
  b.id_flex_code,
  b.flex_field_type,
  b.flex_field_name,
  c.application_short_name application_name
  from    edw_attribute_mappings@edw_apps_to_wh a,
  edw_flex_attribute_mappings@edw_apps_to_wh b,
  fnd_application@edw_apps_to_wh c
  where   a.source_view = :3
   and   a.object_short_name= :1
   and   a.instance_code = :2
   and   a.ATTR_MAPPING_PK = b.attr_mapping_fk
   AND   c.application_id = b.application_id'
;

-- Bug 6819715  New constants and global variables to control session settings related to the RDBMS optimizer
v_shared_pool CONSTANT  VARCHAR2(50) := 'alter system flush shared_pool';
v_session_sort CONSTANT  VARCHAR2(50) := 'alter session set "_newsort_enabled"=false';

---
--============================================================================
-- mode for the program
--============================================================================
--
g_mode bis_vg_types.view_generator_mode_type := bis_vg_types.production_mode;
--


--=====================
--PRIVATE TYPES
--=====================
--- Weak REF CURSOR TYPE for use in dynamic queries
TYPE Ref_Cursor_Type IS REF CURSOR;

TYPE superset_rec_type IS
   RECORD
     (   table_name   VARCHAR2(200)
       , table_alias  VARCHAR2(40)
       , column_name   VARCHAR2(60)
       )
     ;

TYPE superset_table_type
  IS
     TABLE of superset_rec_type;

TYPE superset_summary_rec_type is
   record
     (  table_name         VARCHAR2(200)
      , table_alias        VARCHAR2(40)
      , first_record       NUMBER
      , last_record        NUMBER
      , currently_valid    BOOLEAN
     )
     ;

TYPE superset_summary_table_type
  IS
     TABLE of superset_summary_rec_type;

--=====================
--PRIVATE PROCEDURES
--=====================
--
-- ============================================================================
--FUNCTION  : get_tag_keyword_position
--PARAMETERS: 1. p_view_table    view table text
--            2. p_string_set    set of strings to look for
--            3. p_start_pointer start pointer
--            4. x_return_status    error or normal
--            5. x_error_Tbl        table of error messages
--COMMENT   : Call this function to get start position of any string in
--            p_string_set
--RETURN    : view_character_pointer
--EXCEPTION : None
-- ============================================================================
FUNCTION get_tag_keyword_position
( p_view_table    IN bis_vg_types.View_Text_Table_Type
, p_string_set    IN bis_vg_types.View_Text_Table_Type
, p_start_pointer IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN bis_vg_types.view_character_pointer_type
IS
l_pointer      bis_vg_types.View_Character_Pointer_Type;
l_save_pointer bis_vg_types.View_Character_Pointer_Type;
l_done         BOOLEAN ;
l_char         VARCHAR2(1);
BEGIN
   l_done := FALSE;
   bis_debug_pub.Add('> get_tag_keyword_position');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_pointer := p_start_pointer;
   WHILE (NOT l_done) LOOP
    l_pointer := bis_vg_parser.get_keyword_position
                                 ( p_view_table
                                 , p_string_set
                                 , l_pointer
                                 , x_return_status
                                 , x_error_Tbl
                                 );
    IF (bis_vg_util.null_pointer( l_pointer
                                , x_return_status
                                , x_error_Tbl
				) = TRUE
	) THEN
      l_done := TRUE;
    ELSIF(l_pointer.col_num = 1) THEN
      l_done := TRUE;
    ELSE
      l_save_pointer := bis_vg_util.decrement_pointer
                                ( p_view_table
                                , l_pointer
                                , x_return_status
                                , x_error_Tbl
                                );
       l_char := bis_vg_util.get_char
                                ( p_view_table
                                , l_save_pointer
                                , x_return_status
                                , x_error_Tbl
                                );
       IF(l_char = '''') THEN
        l_done := TRUE;
       ELSE
         l_pointer := bis_vg_util.increment_pointer
                                ( p_view_table
                                , l_pointer
                                , x_return_status
                                , x_error_Tbl
                                );
       END IF;
    END IF;
  END LOOP;
  bis_debug_pub.Add('< get_tag_keyword_position');
  RETURN l_pointer;
--
--
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.get_tag_keyword_position'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_tag_keyword_position;
--
-- ============================================================================
--PROCEDURE : Update_Flexfields
--- PARAMETERS:
---  1. p_View_Column_Table  table of varchars to hold columns of view text
---  2. p_View_Select_Table  table of varchars to hold select clause of view
---  3. p_Mode               mode of the program
---  4. p_selected_columns IN  BIS_VG_TYPES.flexfield_column_table_type:
---                             Use only for calls from generate_pruned_view
---  5. p_Column_Pointer     pointer to the key flex column in column table
---  6. p_Select_Pointer     pointer to the select clause
---  7. x_Column_Table       table of varchars to hold additional columns
---  8. x_Select_Table       table of varchars to hold additional columns
---  9. x_Column_Comment_Table table of records to hold
---                          flex data for flex derived columns.
---  10. x_Column_Pointer     pointer to the character after the delimiter
---                          (column table)
---  11. x_Select_Pointer     pointer to the character after the delimiter
---                           (select table)
---  12. x_return_status    error or normal
---  13. x_error_Tbl        table of error messages
---
--- COMMENT   : Call this procedure to update the flex field pointed
--- EXCEPTION : None
--- ========================================================================

PROCEDURE update_flexfields -- PRIVATE PROCEDURE
( p_view_column_text_table  IN  bis_vg_types.View_Text_Table_Type
, p_view_select_text_table  IN  bis_vg_types.View_Text_Table_Type
, p_mode                    IN  NUMBER := bis_vg_types.sqlplus_production_mode
, p_selected_columns        IN BIS_VG_TYPES.flexfield_column_table_type := NULL
, p_column_pointer          IN  bis_vg_types.view_character_pointer_type
, p_select_pointer          IN  bis_vg_types.view_character_pointer_type
, x_column_table            OUT bis_vg_types.View_Text_Table_Type
, x_select_table            OUT bis_vg_types.View_Text_Table_Type
, x_column_comment_table    OUT bis_vg_types.Flex_Column_Comment_Table_Type
, x_column_pointer          OUT bis_vg_types.view_character_pointer_type
, x_select_pointer          OUT bis_vg_types.view_character_pointer_type
, x_return_status           OUT VARCHAR2
, x_error_Tbl               OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
l_str     VARCHAR2(300);
l_sel_str VARCHAR2(300);
l_pointer bis_vg_types.view_character_pointer_type;
l_col     NUMBER;
BEGIN
--
   bis_debug_pub.Add('> update_flexfields');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
--- --- --- DEBUG ---
---   bis_vg_util.print_view_pointer ( p_select_pointer
---                                 , x_return_status
---                                 , x_error_Tbl
---				 );
  l_str := bis_vg_util.get_row( p_view_select_text_table
                              , p_select_pointer
			      , x_return_status
			      , x_error_Tbl
                              );
  bis_debug_pub.Add('l_str = '||l_str);
  l_str := bis_vg_parser.get_string_token
                        ( l_str
                        , p_select_pointer.col_num
                        , ':'
                        , l_col
			, x_return_status
			, x_error_Tbl
                        );
  l_sel_str := UPPER(l_str);
--
  bis_debug_pub.Add('l_sel_str = '||l_sel_str);
  l_str := bis_vg_util.get_row( p_view_column_text_table
                              , p_column_pointer
			      , x_return_status
			      , x_error_Tbl
                              );
--
  l_str := bis_vg_parser.get_string_token
                        ( l_str
                        , p_column_pointer.col_num
                        , ':'
                        , l_col
			, x_return_status
			, x_error_Tbl
                        );
  l_str := UPPER(l_str);
  IF (l_col IS NULL) THEN
    bis_debug_pub.Add('out pointer is null');
    l_pointer := bis_vg_util.increment_pointer_by_row
                                         ( p_view_column_text_table
					 , p_column_pointer
					 , x_return_status
					 , x_error_Tbl
					 );
   ELSE
     l_pointer := p_column_pointer;
     l_pointer.col_num := l_col;
  END IF;
--
  IF (l_str <> l_sel_str) THEN

     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => MISMATCHED_TAG_EXCEPTION_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.update_flexfields'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_error_table       => x_error_tbl
	 , x_error_table       => x_error_tbl
	 );
     RAISE FND_API.G_EXC_ERROR;

  END IF;
---
  bis_debug_pub.Add('l_str = '||l_str);
  IF (l_str = '_KF') THEN
    BIS_VG_KEY_FLEX.add_Key_Flex_Info( p_View_Column_text_Table
                                     , p_View_Select_Text_Table
				     , p_Mode
				     , p_selected_columns
                                     , p_Column_Pointer
                                     , p_Select_Pointer
                                     , p_select_Pointer -- not used
                                     , x_Column_Table
                                     , x_Select_Table
                                     , x_Column_Comment_Table
                                     , x_Column_Pointer
                                     , x_Select_Pointer
				     , x_return_status
				     , x_error_Tbl
                                     );
--- --- --- DEBUG ----
---  bis_vg_util.print_View_Text
---                        ( x_Column_Table
---			, x_return_status
---			, x_error_Tbl
---			);
---  bis_vg_util.print_View_Text
---                        ( x_Select_Table
---			, x_return_status
---			, x_error_Tbl
---			);
  ELSE
    IF (l_str = '_DF') THEN
      BIS_VG_DESC_FLEX.add_Desc_Flex_Info( p_View_Column_text_Table
                                         , p_View_Select_Text_Table
					 , p_Mode
					 , p_selected_columns
                                         , p_Column_Pointer
                                         , p_Select_Pointer
                                         , p_select_pointer -- not used
                                         , x_Column_Table
                                         , x_Select_Table
                                         , x_Column_Comment_Table
                                         , x_Column_Pointer
                                         , x_Select_Pointer
					 , x_return_status
					 , x_error_Tbl
                                         );
    ELSE
      IF (l_str = '_LA') THEN
        bis_vg_lookup.add_Lookup_Info( p_View_Column_text_Table
                                     , p_View_Select_Text_Table
                                     , p_Mode
                                     , p_Column_Pointer
                                     , p_Select_Pointer
                                     , x_Column_Table
                                     , x_Select_Table
                                     , x_Column_Pointer
                                     , x_Select_Pointer
				     , x_return_status
				     , x_error_Tbl
                                     );
      ELSE
        NULL;
        -- raise exception
      END IF;
    END IF;
  END IF;
  bis_debug_pub.Add('< update_flexfields');
--
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'. update_flexfields'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END  update_flexfields;
--
-- ============================================================================
--FUNCTION : exclude_comma_before_tag
--PARAMETERS:
--  1. p_View_Select_Text_Table contains select text
--  2. p_Select_Pointer         in pointer
--  3. p_start_pointer          pointer to beginning of select table
--  4. x_Select_Pointer         out pointer
--  5. x_return_status    error or normal
--  6. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to position the pointer to handle the comma
--            when in remove_tags_mode or when _DF with no segments encountered
--Return    : 1 iff found a comma else 0
--EXCEPTION : None
-- ============================================================================
FUNCTION exclude_comma_before_tag -- PRIVATE function
( p_View_Select_Text_Table IN  bis_vg_types.View_Text_Table_Type
, p_Select_Pointer         IN  bis_vg_types.view_character_pointer_type
, p_start_pointer          IN  bis_vg_types.view_character_pointer_type
, x_Select_Pointer         OUT bis_vg_types.view_character_pointer_type
, x_return_status     OUT VARCHAR2
, x_error_Tbl         OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN NUMBER
IS
--
l_select_pointer    bis_vg_types.view_character_pointer_type;
--
BEGIN
   bis_debug_pub.Add('> exclude_comma');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_select_pointer := p_Select_Pointer;
   WHILE( bis_vg_util.get_char( p_View_Select_Text_Table
				, l_select_pointer
				, x_return_status
				, x_error_Tbl
				)
         <> ','
       ) LOOP
    l_select_pointer := bis_vg_util.decrement_pointer
                             ( p_View_Select_Text_Table
                             , l_select_pointer
                             , x_return_status
                             , x_error_Tbl
                             );
    IF(bis_vg_util.equal_pointers
                            ( l_select_pointer
                            , p_start_pointer
                            , x_return_status
                            , x_error_Tbl
                            )
      )
    THEN
       x_select_pointer := p_select_pointer;
       bis_debug_pub.Add('< exclude_comma_before_tag');
       RETURN 0;
    END IF;
  END LOOP;
  IF (NOT bis_vg_util.equal_pointers
                            ( l_select_pointer
                            , p_start_pointer
                            , x_return_status
                            , x_error_Tbl
                            )
      )
THEN
    x_select_pointer := bis_vg_util.decrement_pointer
                           ( p_View_Select_Text_Table
                           , l_select_pointer
                           , x_return_status
                           , x_error_Tbl
                           );
  END IF;
  bis_debug_pub.Add('< exclude_comma_before_tag');
  RETURN 1;
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'. exclude_comma_before_tag'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END exclude_comma_before_tag;
--
-- ============================================================================
--PROCEDURE : exclude_comma_after_tag
--PARAMETERS:
--  1. p_View_Select_Text_Table contains select text
--  2. p_Select_Pointer         in pointer
--  3. p_end_pointer          pointer to beginning of select table
--  4. x_Select_Pointer         out pointer
--  5. x_return_status    error or normal
--  6. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to position the pointer to handle the comma
--            when in remove_tags_mode or when _DF with no segments encountered
--Return    : 1 iff found a comma else 0
--EXCEPTION : None
-- ============================================================================
PROCEDURE exclude_comma_after_tag -- PRIVATE PROCEDURE
( p_View_Select_Text_Table IN  bis_vg_types.View_Text_Table_Type
, p_Select_Pointer         IN  bis_vg_types.view_character_pointer_type
, p_end_pointer            IN  bis_vg_types.view_character_pointer_type
, x_Select_Pointer         OUT bis_vg_types.view_character_pointer_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_select_pointer    bis_vg_types.view_character_pointer_type;
--
BEGIN
   bis_debug_pub.Add('> exclude_comma_after_tag');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_select_pointer := p_Select_Pointer;
   WHILE( bis_vg_util.get_char( p_View_Select_Text_Table
                             , l_select_pointer
                             , x_return_status
                             , x_error_Tbl
                             )
         <> ','
       ) LOOP
    l_select_pointer := bis_vg_util.increment_pointer
                             ( p_View_Select_Text_Table
                             , l_select_pointer
                             , x_return_status
                             , x_error_Tbl
                             );
    IF(bis_vg_util.equal_pointers
                            ( l_select_pointer
                            , p_end_pointer
                            , x_return_status
                            , x_error_Tbl
                            )
      )
    THEN
       x_select_pointer := p_select_pointer;
       bis_debug_pub.Add('< exclude_comma_after_tag');
       RETURN;
    END IF;
  END LOOP;
  -- we are currently pointing to ',' position beyond that
  IF (NOT bis_vg_util.equal_pointers
                            ( l_select_pointer
                            , p_end_pointer
                            , x_return_status
                            , x_error_Tbl
                            )
      )
  THEN
    x_select_pointer := bis_vg_util.increment_pointer
                           ( p_View_Select_Text_Table
                           , l_select_pointer
                           , x_return_status
                           , x_error_Tbl
                           );
  END IF;
  bis_debug_pub.Add('< exclude_comma_after_tag');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'. exclude_comma_after_tag'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END exclude_comma_after_tag;


--- ========================================================================
--- PROCEDURE : get_base_table_cols
--- PARAMETERS:
---  1. p_extra_columns  IN superset_table_type
---                  contains all columns to be added to the view from
---                  the base table, as selected in APPS integrator
---  2. x_unique_tables OUT superset_summary_table_type
---                  table built in this procedure, contains all unique
---                  table names referenced in p_extra_columns.
---  3. x_view_column_text_table OUT bis_vg_types.View_Text_Table_Type
---                  table of all old + new column names
---  4. x_error_Tbl        table of error messages
--- COMMENT   : Call this procedure to add extra columns selected from
---             the view base tables in APPS Integrator to the column list
---             of the view, and to prepare a summary table for use in
---             get_base_table_selects.
--- =========================================================================
PROCEDURE Get_base_Table_Cols
  (   p_extra_columns          IN superset_table_type
      , x_unique_tables        OUT superset_summary_table_type
      , x_column_table           OUT bis_vg_types.View_Text_Table_Type
    , x_error_Tbl              OUT BIS_VG_UTIL.error_tbl_type
    )
  IS
     l_table_count     PLS_INTEGER ;

BEGIN
--
   l_table_count := 0;
   bis_debug_pub.Add('> Get_base_Table_Cols');
    x_unique_tables := superset_summary_table_type();

   FOR l_col_count  IN p_extra_columns.FIRST..p_extra_columns.LAST
     LOOP
	x_column_table(l_col_count) :=
	  p_extra_columns(l_col_count).table_alias
	  || '_'
	  || p_extra_columns(l_col_count).column_name ;
	   bis_debug_pub.ADD('   x_column_table('||l_col_count
			     ||') = '
			     || x_column_table(l_col_count));
	IF ( l_col_count = 1 --- first time
	     OR
	    x_unique_tables(l_table_count).table_name --- table_name changed
	        <> p_extra_columns(l_col_count).table_name
	    OR
	    x_unique_tables(l_table_count).table_alias ---table_alias changed
	        <>
	    p_extra_columns(l_col_count).table_alias
	    )
	  THEN
	   --- add new summary entry

	   x_unique_tables.extend;
	   l_table_count := l_table_count +1;
	   bis_debug_pub.ADD('Adding entry number '||l_table_count
			     || ' to x_unique_tables');	   x_unique_tables(l_table_count).table_name :=
	     p_extra_columns(l_col_count).table_name;
	   bis_debug_pub.ADD('   x_unique_tables('||l_table_count
			     ||').table_name = '
			     || x_unique_tables(l_table_count).table_name);
	   x_unique_tables(l_table_count).table_alias :=
	     p_extra_columns(l_col_count).table_alias;
	   x_unique_tables(l_table_count).currently_valid := FALSE;
	   x_unique_tables(l_table_count).first_record := l_col_count;
	   x_unique_tables(l_table_count).last_record :=  l_col_count;
	 ELSE
	   x_unique_tables(l_table_count).last_record := l_col_count;
	END IF;

     END LOOP;

   bis_debug_pub.Add('< Get_base_Table_Cols');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Get_base_Table_Cols'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END  Get_base_Table_Cols;


--- ========================================================================
--- PROCEDURE : get_base_table_selects
--- PARAMETERS:
---  1. p_unique_tables IN superset_summary_table_type
---                                contains previously parsed column names
---  2. p_extra_columns  IN superset_table_type
---                  table built in get_base_table_selects when the first
---                  union branch was parsed.  Contains all unique table
---                  names referenced in p_extra_columns.
---  3. p_select_table IN bis_vg_types.View_Text_Table_Type
---                  contains the "FROM" clause of the union branch
---                  currently being parsed
---  4. x_select_table  OUT bis_vg_types.View_Text_Table_Type
---                  contains all the selects for the extra columns, with
---                  a alias.column reference if the table name and alias
---                  exist in this union branch, or a "NULL" if it does not.
---  5. x_error_Tbl        table of error messages
--- COMMENT   : Call this procedure to build the select clause for the extra
---             columns from the view base tables.  This list of select
---             references is concatenated to the select clause of the
---             generated view, one union barnch at a time.
--- =========================================================================
PROCEDURE Get_Base_Table_Selects
  (p_view_select_table IN  bis_vg_types.View_Text_Table_Type
   , p_start_pos       IN  bis_vg_types.View_Character_Pointer_Type
   , p_unique_tables   IN  superset_summary_table_type
   , p_extra_columns   IN  superset_table_type
   , x_select_table    OUT bis_vg_types.View_Text_Table_Type
   ,  x_error_Tbl              OUT BIS_VG_UTIL.error_tbl_type
    )
  IS
     l_pos          bis_vg_types.View_Character_Pointer_Type;
     l_end          PLS_INTEGER;
     l_dummy                  VARCHAR2(2000);
     l_str          VARCHAR2(60);
     l_str2         VARCHAR2(60);
     l_row          VARCHAR2(2000);
     l_unique_tabs  SUPERSET_SUMMARY_TABLE_TYPE;
BEGIN
--
   bis_debug_pub.Add('> Get_Base_Table_Selects');
   l_unique_tabs := p_unique_tables;

   l_str :=  bis_vg_parser.get_string_token   --- get the 'FROM'
		     ( p_view_select_table(p_start_pos.row_num)
		     , p_start_pos.col_num
		     , ', '||g_newline||g_tab
		     , l_end
		     , l_dummy
		     , x_error_Tbl
		   );
   IF l_end IS NULL THEN ---- reached end of row
    l_pos := bis_vg_util.increment_pointer_by_row
      ( p_view_select_table
	, p_start_pos
	, l_dummy
	, x_error_Tbl
	);
    ELSE
      l_pos := p_start_pos;
      l_pos.col_num  := l_end;
   END IF;


   WHILE (bis_vg_util.null_pointer(l_pos, l_dummy, x_error_tbl) = FALSE)

     LOOP
	l_str :=  upper(bis_vg_parser.get_string_token
			( p_view_select_table(l_pos.row_num)
			  ,l_pos.col_num
			  , ', '||g_newline||g_tab
			  , l_end
			  , l_dummy
			  , x_error_Tbl
			  )
			);
	EXIT when (l_str = 'WHERE'
		   OR
		   l_str = 'UNION'
		   );
	IF l_end IS NULL
	  THEN
	       l_pos := bis_vg_util.increment_pointer_by_row
		 ( p_view_select_table
		   , l_pos
		   , l_dummy
		   , x_error_Tbl
		   );

	 ELSE l_pos.col_num := l_end;
	END IF;
  ---
      FOR l_table_count IN p_unique_tables.FIRST..p_unique_tables.last
	LOOP  --- over the list of table names
	   IF l_str = p_unique_tables(l_table_count).table_name
	     THEN --- found table, look for alias
	      IF (
		  p_unique_tables(l_table_count).table_alias
		  =
		  upper(bis_vg_parser.get_string_token
			             ( p_view_select_table(l_pos.row_num)
				       ,l_pos.col_num
				       , ', '||g_newline||g_tab
				       , l_end
				       , l_dummy
				       , x_error_Tbl
				       )
			     )
		  )
		THEN
		 l_unique_tabs(l_table_count).currently_valid := TRUE;
		 --- increment l_pos to the next string
		 IF l_end IS NULL
		   THEN
		    l_pos := bis_vg_util.increment_pointer_by_row
		      ( p_view_select_table
			, l_pos
			, l_dummy
			, x_error_Tbl
			);
		  ELSE
		    l_pos.col_num := l_end;
		 END IF;  --- l_end is null
	      END IF; --- alias found
	   END IF; --- table_name found
	END LOOP; --- over the list of table names

     END LOOP; --- over the select statement string table


     FOR table_count IN p_unique_tables.FIRST..p_unique_tables.last
     LOOP
	IF (l_unique_tabs(table_count).currently_valid = FALSE)
	  THEN
	   FOR
	     column_count
	     IN
	     p_unique_tables(table_count).first_record
	     ..
	     p_unique_tables(table_count).last_record
	     LOOP
		x_select_table(column_count) := ', NULL';
	     END LOOP; --- column loop

	 ELSE
	   FOR
	     column_count
	     IN
	     p_unique_tables(table_count).first_record
	     ..
	     p_unique_tables(table_count).last_record
	     LOOP
		x_select_table(column_count) :=
		  ' , '
		  || p_extra_columns(column_count).table_alias
		  || '.'
		  || p_extra_columns(column_count).column_name;
	     END LOOP; --- column loop

	END IF; --- valid or invalid
     END LOOP; --- table loop

   bis_debug_pub.Add('< Get_Base_Table_Selects');


EXCEPTION
   when FND_API.G_EXC_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Get_Base_Table_Selects'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; END  get_base_table_selects;

--- ========================================================================
--- PROCEDURE : Update_View
--- PARAMETERS:
---  1. p_View_Column_Text_Table IN bis_vg_types.View_Text_Table_Type:
---                                    contains column names
---  2. p_View_Select_Text_Table IN bis_vg_types.View_Text_Table_Type:
---                                    contains select text
---  3. p_mode IN bi_vg_types.View_Generator_Mode_type:
---                                     production, plsql or test
---  4. p_selected_columns IN  BIS_VG_TYPES.flexfield_column_table_type
---                              Used only for calls from generate_pruned_view
---  5. p_extra_columns  IN  superset_table_type
---                         Used only for calls from generate_pruned_view
---  6. x_View_Column_Text_Table OUT bis_vg_types.View_Text_Table_Type:
---                                     return column names
---  7. x_View_Select_Text_Table OUT bis_vg_types.View_Text_Table_Type
---                                     return select text
---  8. x_View_Column_Comment_Table OUT bis_vg_types.Flex_Column_Comment_Table_Type
---                                 returns table of records with comments
---                                 for flex derived columns.
---  8. x_error_Tbl        table of error messages
--- COMMENT   : Call this procedure to update the flex filed in a view
--- ==========================================================================

PROCEDURE Update_View --- PRIVATE PROCEDURE
( p_View_Column_Text_Table IN bis_vg_types.View_Text_Table_Type
, p_View_Select_Text_Table IN bis_vg_types.view_text_table_type
, p_mode                   IN NUMBER := bis_vg_types.sqlplus_production_mode
, p_selected_columns       IN  BIS_VG_TYPES.flexfield_column_table_type := NULL
, p_extra_columns          IN  superset_table_type := NULL
, x_View_Column_Text_Table OUT bis_vg_types.View_Text_Table_Type
, x_View_Select_Text_Table OUT bis_vg_types.View_Text_Table_Type
, x_View_Column_Comment_Table OUT bis_vg_types.Flex_Column_Comment_Table_Type
, x_error_Tbl              OUT BIS_VG_UTIL.error_tbl_type
)
IS
l_col_tab_curr_pos       bis_vg_types.view_character_pointer_type;
l_sel_tab_curr_pos       bis_vg_types.view_character_pointer_type;
l_col_tab_past_pos       bis_vg_types.view_character_pointer_type;
l_sel_tab_past_pos       bis_vg_types.view_character_pointer_type;
l_sel_tab_pretag_pos     bis_vg_types.view_character_pointer_type;
l_col_tab_pretag_pos     bis_vg_types.view_character_pointer_type;
l_sel_tab_FROM_pos       bis_vg_types.view_character_pointer_type;
l_sel_tab_SELECT_pos     bis_vg_types.view_character_pointer_type;
l_sel_tab_sec_tag_pos    bis_vg_types.view_character_pointer_type;
l_select_string_table    bis_vg_types.view_text_table_type;
l_union_string_table     bis_vg_types.view_text_table_type;
l_flex_string_table      bis_vg_types.view_text_table_type;
l_from_string_table      bis_vg_types.view_text_table_type;
l_security_string_table  bis_vg_types.view_text_table_type;
l_column_table           bis_vg_types.view_text_table_type;
l_select_table           bis_vg_types.view_text_table_type;
l_column_comment_table bis_vg_types.Flex_Column_Comment_Table_Type;
l_temp_column_table      bis_vg_types.view_text_table_type;
l_temp_select_table      bis_vg_types.view_text_table_type;
l_unique_tables          superset_summary_table_type;
l_done                   BOOLEAN;
l_select_count           NUMBER;
l_in_union               BOOLEAN ;
l_dummy                  VARCHAR2(2000);
l_hcr                    NUMBER;
--
BEGIN
--
   l_in_union := FALSE;
   bis_debug_pub.Add('> Update_View');
---   x_return_status := FND_API.G_RET_STS_SUCCESS;




--- --- --- DEBUG ---

---   IF (g_mode = bis_vg_types.test_view_gen_mode) THEN
---     bis_debug_pub.debug_on;
---  END IF;
---
---  bis_vg_util.print_View_Text
---                           ( p_View_Column_Text_Table
---                           , l_dummy
---                           , x_error_Tbl
---                           );
---  bis_vg_util.print_View_Text
---                           ( p_View_Select_Text_Table
---                           , l_dummy
---                           , x_error_Tbl
---                           );
---
---  IF (g_mode = bis_vg_types.test_view_gen_mode) THEN
---     bis_debug_pub.debug_off;
---  END IF;
---
  l_flex_string_table(1) := '_KF';
  l_flex_string_table(2) := '_DF';
  l_flex_string_table(3) := '_LA';
  --
  l_from_string_table(1)   := 'FROM';
  l_select_string_table(1) := 'SELECT';
  l_union_string_table(1)  := 'UNION';
  l_security_string_table(1)  := '_SEC:';
  --
  l_sel_tab_curr_pos.row_num := 1;
  l_sel_tab_curr_pos.col_num := 1;
  l_sel_tab_SELECT_pos := l_sel_tab_curr_pos;
  --
  WHILE (l_sel_tab_curr_pos.row_num IS NOT null) LOOP
    -- find the next from pointer
    bis_debug_pub.Add('before seeking from');
    l_sel_tab_FROM_pos := bis_vg_parser.get_keyword_position
                                     ( p_view_select_text_table
                                     , l_from_string_table
                                     , l_sel_tab_curr_pos
                                     , l_dummy
                                     , x_error_Tbl
                                     );
    bis_debug_pub.Add('after seeking from');
    -- reset column pointer
    l_col_tab_curr_pos.row_num := 1;
    l_col_tab_curr_pos.col_num := 1;
--
    l_col_tab_past_pos := l_col_tab_curr_pos;
    l_sel_tab_past_pos := l_sel_tab_curr_pos;
--
    -- iterate with the columns
    WHILE (l_col_tab_curr_pos.row_num IS NOT NULL) LOOP
      bis_debug_pub.Add('column row = '||l_col_tab_curr_pos.row_num||
                           ' column col = '||l_col_tab_curr_pos.col_num);
      -- find the new keyword
      l_col_tab_curr_pos := get_tag_keyword_position
                            ( p_view_column_text_table
                            , l_flex_string_table
                            , l_col_tab_past_pos
                            , l_dummy
                            , x_error_Tbl
                            );
--- --- --- DEBUG ---
---      bis_vg_util.print_view_pointer( l_col_tab_past_pos
---			            , l_dummy
---				    , x_error_Tbl
---				    );
      IF (l_col_tab_curr_pos.row_num IS NOT NULL) THEN
        -- found a valid flex field
        -- find the new keyword
        l_sel_tab_curr_pos := get_tag_keyword_position
                              ( p_view_select_text_table
                              , l_flex_string_table
                              , l_sel_tab_past_pos
                              , l_dummy
                              , x_error_Tbl
                              );
        l_col_tab_pretag_pos := l_col_tab_curr_pos;
        l_sel_tab_pretag_pos := l_sel_tab_curr_pos;
        bis_debug_pub.Add('PREV COLUMN POINTER');
--- --- --- DEBUG ---
---        bis_vg_util.print_view_pointer( l_col_tab_past_pos
---				      , l_dummy
---				      , x_error_Tbl
---				      );
        -- update the flex fields
        -- and copy to output tables
        update_flexfields( p_View_Column_Text_Table
                          , p_view_select_text_table
			  , p_mode
			  , p_selected_columns
                          , l_col_tab_curr_pos
                          , l_sel_tab_curr_pos
                          , l_Column_Table
                          , l_Select_Table
                          , l_Column_Comment_Table
                          , l_col_tab_curr_pos
                          , l_sel_tab_curr_pos
                          , l_dummy
                          , x_error_Tbl
                          );
	-- position the pointer before the last single quote in select
        l_sel_tab_pretag_pos := bis_vg_util.position_before_characters
                                  ( p_view_select_text_table
                                  , '''' ----||' '||'	'
                                  , l_sel_tab_pretag_pos
                                  , l_dummy
                                  , x_error_Tbl
                                  );
--- --- --- DEBUG ---
---        bis_vg_util.print_view_pointer ( l_sel_tab_pretag_pos
---					, l_dummy
---					, x_error_Tbl
---					);
        -- if tag generated an empty table (empty _DF or remove_tags mode)
        -- and its not the first column in a UNION clause
        l_hcr := 1;
        IF (l_select_table.COUNT = 0) THEN
          -- no flex definition or remove_tags mode,
          -- remove the comma prior to the tag just processed in the
          -- select table.  (Note: no commas in column table yet)
          l_hcr := exclude_comma_before_tag( p_view_select_text_table
                      		 	  , l_sel_tab_pretag_pos
                      		 	  , l_sel_tab_SELECT_pos
                      		 	  , l_sel_tab_pretag_pos
                                          , l_dummy
                                          , x_error_Tbl
                      		 	  );
      	  IF (l_hcr = 0) THEN
	     -- No valid columns prior to current tag in select statement.
	     -- Current (unexpanded) tag is first tag, so we must remove the
	     -- trailing ',' in order for the next column to be first in
	     -- the generated select statement
      	    exclude_comma_after_tag( p_view_select_text_table
      				  , l_sel_tab_curr_pos
      				  , l_sel_tab_FROM_pos
      				  , l_sel_tab_curr_pos
                                  , l_dummy
                                  , x_error_Tbl
      				  );

      	  END IF;

        END IF; -- end of tag generated an empty table
--
        bis_debug_pub.ADD('right after positioning before');
--        bis_vg_util.print_view_pointer
--                              ( l_sel_tab_pretag_pos
--                              , l_dummy
--                              , x_error_Tbl
--                              );
--
        -- pointers have been decremented to point just before ' or '
        -- if we have a valid character at the current position, we need
        -- to increment the pointers as the copy function copies
        -- exclusive of the end pointer
        --
        l_sel_tab_pretag_pos := BIS_VG_UTIL.increment_pointer
                                            ( p_view_select_text_table
                                            , l_sel_tab_pretag_pos
                                            , l_dummy
                                            , x_error_Tbl
                                            );
        -- copy the portion between the prev and current pointer
        -- to output tables
--
        bis_debug_pub.Add('PREV COLUMN POINTER');
--- --- --- DEBUG ---
---        bis_vg_util.print_view_pointer
---                            (l_col_tab_past_pos
---                            , l_dummy
---                            , x_error_Tbl
---                            );
        bis_vg_util.copy_part_of_table
                            ( p_view_column_text_table
                            , l_col_tab_past_pos
                            , l_col_tab_pretag_pos
                            , l_temp_column_table
			    , l_dummy
                            , x_error_Tbl
			    );
        bis_debug_pub.ADD('Copy column table is ');
        bis_vg_util.print_view_text(l_temp_column_table
				    , l_dummy
				    , x_error_Tbl
				    );

        IF(l_in_union = FALSE) THEN
	   --- Column table only traversed once for a union
	   bis_vg_util.concatenate_tables( x_view_column_text_table
					 , l_temp_column_table
                                         , x_view_column_text_table
					 , l_dummy
					 , x_error_Tbl
                                         );

--- --- --- DEBUG ---
---          bis_debug_pub.ADD('Concatenated  column table is ');
---          bis_vg_util.print_view_text
---	                           ( x_view_column_text_table
---				   , l_dummy
---				   , x_error_Tbl
---				   );
        END IF;
--
--- --- --- DEBUG ---
---        bis_debug_pub.ADD('beore Copy select table');
---        bis_vg_util.print_view_pointer
---                                   ( l_sel_tab_past_pos
---				   , l_dummy
---				   , x_error_Tbl
---				   );
---        bis_debug_pub.ADD( 'l_char := '||
---                           bis_vg_util.get_char( p_view_select_text_table
---                                               , l_sel_tab_past_pos
---                                               , l_dummy
---		                               , x_error_Tbl
---			                       )
---                          );
---
        bis_vg_util.copy_part_of_table( p_view_select_text_table
                                      , l_sel_tab_past_pos
                                      , l_sel_tab_pretag_pos
                                      , l_temp_select_table
				      , l_dummy
				      , x_error_Tbl
                                      );
--- --- --- DEBUG ---
---        bis_debug_pub.ADD('Copy select table is ');
---        bis_vg_util.print_view_text
---                                ( l_temp_select_table
---				, l_dummy
---				, x_error_Tbl
---				);
---
        bis_vg_util.concatenate_tables( x_view_select_text_table
                                      , l_temp_select_table
                                      , x_view_select_text_table
				      , l_dummy
				      , x_error_Tbl
                                      );

--- --- --- DEBUG ---
---        bis_debug_pub.ADD('Concatenated  select table is ');
---        bis_vg_util.print_view_text
---			    ( x_view_select_text_table
---                           , l_dummy
---                           , x_error_Tbl
---			     );
---


        IF (l_column_table.COUNT > 0) THEN
	   --- concatenate expanded flexfield columns to output
	   IF(l_in_union = FALSE) THEN
	      --- first the column headings
	      bis_vg_util.concatenate_tables( x_view_column_text_table
                                          , l_column_table
                                          , x_view_column_text_table
					  , l_dummy
					  , x_error_Tbl
                                          );
              --- get the column comments
              bis_vg_util.concatenate_tables( x_view_column_comment_table
                                            , l_column_comment_table
                                            , x_view_column_comment_table
		                            , l_dummy
					    , x_error_Tbl
                                            );
          END IF;
	  --- second - the select statement
          bis_vg_util.concatenate_tables( x_view_select_text_table
                                        , l_select_table
                                        , x_view_select_text_table
					, l_dummy
					, x_error_Tbl
                                        );
        END IF;

        bis_debug_pub.Add('after concatenation of tables');

--- --- --- DEBUG ---
---        bis_vg_util.print_view_text
---                            ( x_view_column_text_table
---		              , l_dummy
---                            , x_error_Tbl
---			      );
---        bis_vg_util.print_view_text
---			    (x_view_select_text_table
---		             , l_dummy
---                           , x_error_Tbl
---			     );
---
      	-- save the pointers as previous
      	l_col_tab_past_pos := l_col_tab_curr_pos;
      	l_sel_tab_past_pos := l_sel_tab_curr_pos;
      END IF; -- end column not null
--
    END LOOP; -- end column pointer loop

--- --- --- DEBUG ---
--
---    bis_debug_pub.Add('out of col loop');
--
    -- out of the columns, copy the last part of the column table
    IF(l_in_union = FALSE) THEN
       bis_vg_util.copy_part_of_table
	 ( p_view_column_text_table
	   , l_col_tab_past_pos
	   , l_col_tab_curr_pos --- defaults to end of table if null
	   , l_column_table
	   , l_dummy
	   , x_error_Tbl
	   );

--- --- --- DEBUG ---
---    bis_debug_pub.ADD('Copy column table is ');
---    bis_vg_util.print_view_text(l_column_table
---                                , l_dummy
--- 		                  , x_error_Tbl
---				  );

      bis_vg_util.concatenate_tables( x_view_column_text_table
                                    , l_column_table
                                    , x_view_column_text_table
				    , l_dummy
				    , x_error_Tbl
                                    );

--- --- --- DEBUG ---
---      bis_debug_pub.ADD('Concatenated  column table is ');
---      bis_vg_util.print_view_text( x_view_column_text_table
---			         , l_dummy
---				 , x_error_Tbl
---				 );

    END IF;
    -- prepare to copy the select table
    -- find the security pointer


    IF (p_extra_columns IS NOT NULL
	AND p_extra_columns.COUNT > 0
	AND x_view_column_text_table.COUNT > 0
	)
      THEN
--- --- --- DEBUG ---
---      bis_vg_util.print_view_pointer ( l_sel_tab_FROM_pos
---                                     , l_dummy
---				     , x_error_Tbl
---				     );
      IF (l_in_union = FALSE)
	THEN
	 get_base_table_cols( p_extra_columns
			     , l_unique_tables
			     , l_Column_Table
			     , x_error_Tbl
			      );
	 bis_vg_util.concatenate_tables( x_view_column_text_table
					 , l_column_table
					 , x_view_column_text_table
					 , l_dummy
					 , x_error_Tbl
					 );


      END IF;

---      bis_debug_pub.Add('before seeking where');

---      bis_debug_pub.Add('after seeking where');
      get_base_table_selects(p_view_select_text_table
			     , l_sel_tab_from_pos
			     , l_unique_tables
			     , p_extra_columns
			     , l_select_table
			     , x_error_Tbl
			     );

      bis_vg_util.concatenate_tables( x_view_select_text_table
				      , l_select_table
				      , x_view_select_text_table
				      , l_dummy
				      , x_error_Tbl
				      );

    END IF;

    IF (p_mode = bis_vg_types.remove_tags_mode) THEN
      l_sel_tab_sec_tag_pos := NULL;
    ELSE

      l_sel_tab_sec_tag_pos := bis_vg_parser.get_keyword_position
                                        ( p_view_select_text_table
                                        , l_security_string_table
                                        , l_sel_tab_FROM_pos
					, l_dummy
					, x_error_Tbl
                                     );
--- --- --- DEBUG ---
---

---      bis_vg_util.print_view_pointer ( l_sel_tab_sec_tag_pos
---                                     , l_dummy
---				     , x_error_Tbl
---				     );
---
      -- see if where pointer pointing to security is good
      IF (bis_vg_util.null_pointer ( l_sel_tab_sec_tag_pos
				     , l_dummy
				     , x_error_Tbl
				     )
	  = FALSE
	  )
	THEN
	 -- copy part of select table from FROM pointer to security pointer
	 bis_debug_pub.Add('security pointer is not null');
	 l_sel_tab_pretag_pos := bis_vg_util.position_before_characters
	   ( p_view_select_text_table
	     , ' ,'
	     , l_sel_tab_sec_tag_pos
	     , l_dummy
	     , x_error_Tbl
	     );
	 bis_vg_util.copy_part_of_table( p_view_select_text_table
					 , l_sel_tab_past_pos
					 , l_sel_tab_pretag_pos
					 , l_select_table
					 , l_dummy
					 , x_error_Tbl
					 );
	 bis_vg_util.concatenate_tables( x_view_select_text_table
					 , l_select_table
					 , x_view_select_text_table
					 , l_dummy
					 , x_error_Tbl
					 );
	 bis_vg_security.add_security_Info( p_View_Select_Text_Table
					    , l_sel_tab_sec_tag_pos
					    , l_select_table
					    , l_sel_tab_past_pos
					    , l_dummy
					    , x_error_Tbl
					    );

 --- --- --- DEBUG ---
 ---
 ---      bis_debug_pub.Add('security pointer after add security info');
 ---      bis_vg_util.print_view_pointer ( l_sel_tab_past_pos
 ---                                     , l_dummy
 ---				     , x_error_Tbl
 ---				     );
 ---
	 bis_vg_util.concatenate_tables( x_view_select_text_table
					 , l_select_table
					 , x_view_select_text_table
					 , l_dummy
					 , x_error_Tbl
					 );
       ELSE
	 bis_debug_pub.Add('security pointer is null');
      END IF; --- SEC tag is valid
    END IF;   --- remove tags mode


--
    IF (l_sel_tab_past_pos.row_num IS NOT NULL) THEN
      -- position at the next select statement
--

--- --- --- DEBUG ---
---      bis_vg_util.print_view_pointer ( l_sel_tab_past_pos
---                                     , l_dummy
---				     , x_error_Tbl
---				     );

       --- Look for keyword UNION
       l_sel_tab_curr_pos := bis_vg_parser.get_keyword_position
                                        ( p_view_select_text_table
                                        , l_union_string_table
                                        , l_sel_tab_past_pos
					, l_dummy
					, x_error_Tbl
					);


--- --- --- DEBUG ---
---
---      bis_vg_util.print_view_pointer ( l_sel_tab_curr_pos
---                                     , l_dummy
---				     , x_error_Tbl
---				     );
---
      IF (l_sel_tab_curr_pos.row_num IS NOT NULL) THEN
        bis_debug_pub.ADD('more select info');
        l_sel_tab_curr_pos := bis_vg_parser.get_keyword_position
                                         ( p_view_select_text_table
                                         , l_select_string_table
                                         , l_sel_tab_curr_pos
					 , l_dummy
					 , x_error_Tbl
                                         );
      END IF;
--
      l_sel_tab_SELECT_pos := l_sel_tab_curr_pos;
      -- copy up to next select statement
      bis_vg_util.copy_part_of_table( p_view_select_text_table
                                    , l_sel_tab_past_pos
                                    , l_sel_tab_curr_pos
                                    , l_select_table
				    , l_dummy
				    , x_error_Tbl
                                    );


--- --- --- DEBUG ---
---
---      bis_debug_pub.ADD('Copy select table is ');
---      bis_vg_util.print_view_text(l_select_table
---                                  , l_dummy
---				  , x_error_Tbl
---				  );
---
      bis_vg_util.concatenate_tables( x_view_select_text_table
                                    , l_select_table
                                    , x_view_select_text_table
				    , l_dummy
				    , x_error_Tbl
                                    );
/*
      bis_vg_util.concatenate_tables( x_view_column_comment_table
                                    , l_column_comment_table
                                    , x_view_column_comment_table
				    , l_dummy
				    , x_error_Tbl
                                    );
*/

--- --- --- DEBUG ---
---
---      bis_debug_pub.ADD('Concatenated  select table is ');
---      bis_vg_util.print_view_text ( x_view_select_text_table
---                                  , l_dummy
---				  , x_error_Tbl
---				  );
---
      l_in_union := TRUE;

    END IF;

   END LOOP;

--- --- --- DEBUG ---
---
---   bis_debug_pub.ADD('out of the select loop');
---   bis_vg_util.print_View_Text
---                            ( x_View_Column_Text_Table
---                            , l_dummy
---                            , x_error_Tbl
---               p             );
---   bis_vg_util.print_View_Text
---                            ( x_View_Select_Text_Table
---                            , l_dummy
---                            , x_error_Tbl
---                            );
   bis_debug_pub.Add('< Update_View');
--
EXCEPTION
   when FND_API.G_EXC_ERROR then
      bis_debug_pub.add('x_error_tbl.count = '||x_error_tbl.count);
---      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
---      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
---      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_View'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Update_View;
--
--
-- ============================================================================
--PROCEDURE : Handle_Gen_Exception
--PARAMETERS:
--  1. p_ViewName Name of the View
--  2. p_MsgName  Exception Message Name
--COMMENT   : Call this procedure to update the flex filed in a view
--EXCEPTION : None
-- ============================================================================
--
PROCEDURE handle_gen_exception
(p_ViewName IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_error_code NUMBER;
l_error_msg  VARCHAR2(2000);
l_count      NUMBER;
l_trace      VARCHAR2(2000);
l_message    VARCHAR2(2000);
l_appl_short VARCHAR2(50);
l_end_pos    NUMBER;
--
BEGIN
   bis_debug_pub.Add('> handle_gen_exception');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- get first message in message queue
  l_error_msg := fnd_msg_pub.get(fnd_msg_pub.G_FIRST, FND_API.G_TRUE);
  -- get application short name
  l_appl_short := SUBSTR( l_error_msg
                        , 1
                        , INSTR(l_error_msg, FND_API.G_MISS_CHAR) - 1
                        );
  l_end_pos := INSTR(l_error_msg, FND_API.G_MISS_CHAR, 1, 2)
            -  LENGTH(l_appl_short) - 2;
  -- get message_name
  l_error_msg := SUBSTR(l_error_msg, LENGTH(l_appl_short)+2, l_end_pos);
  -- get message_code
  l_error_code := fnd_message.get_number( l_appl_short
                                        , l_error_msg
                                        );
  -- reset message stack
  fnd_msg_pub.reset;
  l_count := fnd_msg_pub.count_msg;
--
  --- retrieve user-friendly message and pass it as a token for
  --- BIS_VG_FAIL_VIEW_NAME_PROMPT
  --- assumption: as the message stack is first populated with the
  --- message explaining the exception and then with the execution trace for
  --- every procedure in the call stack, the user-friendly message is the first
  --- one
  l_error_msg := fnd_msg_pub.get(p_encoded => FND_API.G_FALSE);
  fnd_message.set_name( application => bis_vg_types.MESSAGE_APPLICATION
                      , name        => 'BIS_VG_FAIL_VIEW_NAME_PROMPT'
                      );
  fnd_message.set_token('VIEW_NAME', p_viewname);
  fnd_message.set_token('ERROR_NUMBER',l_error_code );
  fnd_message.set_token('ERROR_MESSAGE', l_error_msg);
  l_message := fnd_message.get;
--
  -- get execution trace
  l_trace := '';
  FOR i IN 2 .. l_count LOOP
    l_trace := SUBSTR( l_trace ||
                       ' ' ||
                       fnd_msg_pub.get(p_encoded => FND_API.G_FALSE)
                     , 1
                     , 2000
                     );
  END LOOP;
--
  -- empty message stack
  fnd_msg_pub.Initialize;
--
  -- add entry to failure log to enable reporting
  bis_vg_log.update_failure_log( p_ViewName
                               , l_error_code
                               , SUBSTR(l_message||' '||l_trace, 1, 2000)
                               , x_return_status
                               , x_error_Tbl
                               );
  bis_debug_pub.Add('< handle_gen_exception');
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'. handle_gen_exception'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END handle_gen_exception;
--
--
-- ============================================================================
--PROCEDURE : comment_View
--PARAMETERS:
--            1. p_View_Name    name of generated view to comment
--            2. p_column_Comment_Table  PL/SQL table
--COMMENT   : This procedure is used to comment flexfield derived column
--            with information as to the source of the flexfield
--EXCEPTION : None
-- ============================================================================
PROCEDURE comment_Flex_Columns
(p_View_Name              IN VARCHAR2
, p_column_Comment_Table  IN bis_vg_types.Flex_Column_Comment_Table_Type
)
IS

l_comment_stmt               VARCHAR2(5000);
l_comment_table_stmt         VARCHAR2(100);
BEGIN
bis_debug_pub.Add('> comment_Flex_Columns');

  FOR j IN  1 .. p_column_Comment_Table.COUNT LOOP
  --- Handle each comment statement in own block
     BEGIN

/*
         l_comment_stmt := 'COMMENT ON COLUMN '||p_view_name||'.'
                        ||p_column_comment_table(j).column_name||' IS '''
                        ||p_column_comment_table(j).flex_type||','
                        ||p_column_comment_table(j).column_comments||'''';

--for bug 2208122
         if (instr(p_column_comment_table(j).column_name, '.') <> 0) then
                l_comment_stmt := 'COMMENT ON COLUMN '||p_view_name||'."'
                                  ||p_column_comment_table(j).column_name||'" IS '''
                                  ||p_column_comment_table(j).flex_type||','
                                  ||p_column_comment_table(j).column_comments||'''';
         end if;
*/

--for bug 2369734: add double quotes to comment for all columns
         l_comment_stmt := 'COMMENT ON COLUMN '||p_view_name||'."'
                             ||p_column_comment_table(j).column_name||'" IS '''
                             ||p_column_comment_table(j).flex_type||','
                             ||p_column_comment_table(j).column_comments||'''';
-----------------

         EXECUTE IMMEDIATE l_comment_stmt;



      EXCEPTION
             WHEN OTHERS THEN
             -- The COMMENT command may have failed due to column name not starting with a letter
             -- Try wrapping the column name with double quotes
             BEGIN
                l_comment_stmt := 'COMMENT ON COLUMN '||p_view_name||'."'
                                  ||p_column_comment_table(j).column_name||'" IS '''
                                  ||p_column_comment_table(j).flex_type||','
                                  ||p_column_comment_table(j).column_comments||'''';
                EXECUTE IMMEDIATE l_comment_stmt;

             EXCEPTION
              -- Will ignore failure to comment column
                 WHEN OTHERS THEN
                    null;
             END;
      END;
  END LOOP;
  -- Bug 6819715
  -- add a comment on the view itself to document the optimizer mode used and the RDBMS major verion number.
  l_comment_table_stmt := 'COMMENT ON TABLE ' ||p_view_name|| ' IS '' optimizer mode is '||
                          BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints||' database version is '||
                          g_db_version||'''';
  BEGIN
      EXECUTE IMMEDIATE l_comment_table_stmt;
  EXCEPTION
       -- Will ignore failure to comment table
        WHEN OTHERS THEN
               null;

  END;
bis_debug_pub.Add('< comment_Flex_Columns');
EXCEPTION
   WHEN OTHERs THEN
      NULL;
END comment_Flex_Columns;
--
-- =====================
-- PUBLIC PROCEDURES
-- =====================
--

PROCEDURE Generate_Pruned_View
  (  p_viewname       IN BIS_VG_TYPES.view_name_type
   , p_objectname     IN varchar2
   , p_gen_viewname   IN varchar2   := NULL
     )

  IS
     l_instance                  VARCHAR2(200);
     l_SubsetColRec              BIS_VG_TYPES.Flexfield_column_rec_Type;
     l_subset_table              BIS_VG_TYPES.flexfield_column_table_type
                          := BIS_VG_TYPES.flexfield_column_table_type();
     l_SupersetColRec            superset_Rec_Type;
     l_superset_table            superset_table_type
                                 := superset_table_type();
     l_View_Column_Text_Table    bis_vg_types.View_Text_Table_Type;
     l_View_Select_Text_Table    bis_vg_types.View_Text_Table_Type;
     l_View_Column_Out_Table     bis_vg_types.View_Text_Table_Type;
     l_View_Select_Out_Table     bis_vg_types.View_Text_Table_Type;
     l_View_Column_Comment_Table bis_vg_types.Flex_Column_Comment_Table_Type;
     l_success                   VARCHAR2(100); --changed the length from 2 to 100 for bug 4093769
     l_error_string              VARCHAR2(4000);

     --- cursor used to process a dynamic multi-row query
     l_FlexColRec_cur Ref_Cursor_Type;

     --- local variable not used but maintained for backward compatibility.
     l_dummy_Tbl        BIS_VG_UTIL.Error_Tbl_Type;

BEGIN
   --- --- DEBUG
---   dbms_output.put_line('GENERATE_PRUNED_VIEW - '||p_viewname);
   --- FIRST CHECK FOR DATA WAREHOUSE LINK

   l_success := bis_debug_pub.set_debug_mode('FILE');
   bis_debug_pub.initialize;
   bis_debug_pub.setdebuglevel(10);
   g_mode := bis_vg_types.production_mode;

BEGIN
   execute immediate 'ALTER session SET global_names=FALSE';
   --- --- DEBUG
---   dbms_output.put_line('GENERATE_PRUNED_VIEW - Checking Warehouse link');
      SELECT db_link INTO l_instance from user_db_links where
	db_link like 'EDW_APPS_TO_WH%';


      execute immediate 'SELECT instance_code FROM edw_local_instance'
	INTO l_instance;

      IF l_instance IS NULL OR l_instance =''
	then
      	 RAISE no_warehouse_link_found;
      END IF;

      EXCEPTION
      WHEN others THEN
	 RAISE no_warehouse_link_found;
   END;
   --- We want one long call to get averything at once
   --- because this happens over a database link.
   --- --- DEBUG   dbms_output.put_line('GENERATE_PRUNED_VIEW - Warehouse link exists');
BEGIN
   OPEN l_FlexColRec_cur
     FOR selection_query_stmt
     using p_objectname, l_instance, p_viewname, p_objectname, l_instance;

   --- --- DEBUG   dbms_output.put_line('GENERATE_PRUNED_VIEW - Cursor Opened');

   ---  Get all names of selected flexfield segments for pruned view
   LOOP
      --- --- DEBUG
      --- dbms_output.put_line('GENERATE_PRUNED_VIEW - looping');
      FETCH l_FlexColRec_cur INTO l_SubsetColRec;
      --- --- DEBUG
      --- dbms_output.put_line('GENERATE_PRUNED_VIEW - fetching');
      EXIT WHEN l_FlexColRec_cur%NOTFOUND;
      --- --- DEBUG
      --- dbms_output.put_line('GENERATE_PRUNED_VIEW - line fetched');
      l_subset_table.EXTEND;
      l_subset_table(l_subset_table.last) := l_SubsetColRec;
      --- --- DEBUG
      --- dbms_output.put_line('GENERATE_PRUNED_VIEW - line stored');
   END LOOP;

   --- --- DEBUG
---   IF (l_subset_table.COUNT=0)
---     THEN
---      dbms_output.put_line('GENERATE_PRUNED_VIEW - Cursor Done w/ NULL '
---			   );
---    ELSE
---      dbms_output.put_line('GENERATE_PRUNED_VIEW - Cursor Done returning '
---			   || l_subset_table.last ||' lines ('
---			   ||  l_subset_table.count
---			   ||')' );
---      END IF;


   --- Get all the names of base column tables to be appended to the view
   OPEN l_FlexColRec_cur
     FOR base_table_v_query_stmt
     using l_instance, p_viewname;
      --- --- DEBUG   dbms_output.put_line('GENERATE_PRUNED_VIEW - Cursor Opened twice');

   LOOP
      --- --- DEBUG       dbms_output.put_line('GENERATE_PRUNED_VIEW - looping');
     FETCH l_FlexColRec_cur INTO l_SupersetColRec;
      --- --- DEBUG        dbms_output.put_line('GENERATE_PRUNED_VIEW - fetching');

     EXIT WHEN l_FlexColRec_cur%NOTFOUND;
     --- --- DEBUG
---     dbms_output.put_line('GENERATE_PRUNED_VIEW - line fetched');

---     dbms_output.put_line(l_SupersetColRec.table_alias
---			  ||'.'
---			  ||l_SupersetColRec.column_name);
     l_superset_table.EXTEND;
     l_superset_table(l_superset_table.last) := l_SupersetColRec;
   END LOOP;

--- --- DEBUG
---   IF (l_superset_table.COUNT=0)
---     THEN
---      dbms_output.put_line('GENERATE_PRUNED_VIEW - Cursor Done w/ NULL '
---			   );
---    ELSE
---      dbms_output.put_line('GENERATE_PRUNED_VIEW - Cursor Done returning '
---			   || l_superset_table.last ||' lines ('
---			   ||  l_superset_table.count
---			   ||')' );
---      END IF;

      CLOSE l_FlexColRec_cur;

EXCEPTION WHEN OTHERS THEN NULL;
END;
--- --- DEBUG
---      dbms_output.put_line('GENERATE_PRUNED_VIEW - Cursor Closed');



      ---   --- Deleted check for no selection.  Will behave as regular generate all
---   --- if no columns are selected.
---   IF (l_subset_table IS NULL OR l_subset_table.COUNT = 0)
---     THEN
---      RAISE no_columns_selected;
---   END IF;
   --- ELSE process pruned view

   BIS_VG_REPOSITORY_MEDIATOR.create_View_Text_Tables
     ( p_viewname
       , l_View_Column_Text_Table
       , l_view_select_text_table
       , l_dummy_tbl
       );
--- ---DEBUG
---   dbms_output.put_line('GENERATE_PRUNED_VIEW - View Parsed');
   Update_View( p_view_column_text_table => l_view_column_text_table
		, p_view_select_text_table  => l_View_Select_Text_Table
		, p_selected_columns  => l_subset_table
		, p_extra_columns  => l_superset_table
		, x_view_column_text_table => l_view_column_out_table
		, x_view_select_text_table => l_view_select_out_table
		, x_view_column_comment_table => l_view_column_comment_table
		, x_error_tbl => l_dummy_tbl
		);
--- ---DEBUG
---   dbms_output.put_line('GENERATE_PRUNED_VIEW - View Processed');
   IF (l_view_column_out_table.COUNT > 0) THEN
      --create the view
      IF p_gen_viewname IS NULL
	THEN
	 BIS_VG_COMPILE.write_View
	( bis_vg_types.sqlplus_production_mode
	  , p_viewname
	  , l_View_Column_out_Table
	  , l_View_Select_out_Table
	  , l_View_Column_Comment_Table
          , l_View_Column_Comment_Table
	  , l_dummy_tbl  ----- not used
	  );
       ELSE
      	 BIS_VG_COMPILE.write_View
	   (   bis_vg_types.EDW_verify_mode
	     , p_gen_viewname
	     , l_View_Column_out_Table
	     , l_View_Select_out_Table
	     , l_View_Column_Comment_Table
             , l_View_Column_Comment_Table
	     , l_dummy_tbl  ----- not used
	     );
      END IF;
   END IF;
--- ---DEBUG
---   dbms_output.put_line('GENERATE_PRUNED_VIEW - View Created');
---- NOW record success in the database table

   execute immediate update_status_stmt
     using
     'GENERATED_PRUNED',
     '',
     p_viewname;
   COMMIT;

---        dbms_output.put_line('GENERATE_PRUNED_VIEW - Status updated');
EXCEPTION
   WHEN  FND_API.g_exc_unexpected_error
     THEN
---      bis_debug_pub.dumpdebug;
      bis_vg_log.write_error_to_string(l_error_string);
      execute immediate update_status_stmt
	using
	'FAILED_PRUNED',
	l_error_string,
	p_viewname;
      COMMIT;

---      RAISE; --- the same exception
   WHEN  FND_API.g_exc_error
     THEN
---      bis_debug_pub.dumpdebug;
      bis_vg_log.write_error_to_string(l_error_string);
   execute immediate update_status_stmt
     using
     'FAILED_PRUNED',
     l_error_string,
     p_viewname;
   COMMIT;

---      RAISE; --- the same exception
   WHEN OTHERS
     THEN
---      bis_debug_pub.dumpdebug;
      l_error_string := 'New Error '|| SQLCODE||' : '|| SQLERRM;
   execute immediate update_status_stmt
     using
     'FAILED_PRUNED',
     l_error_string,
     p_viewname;
   COMMIT;
---      RAISE;    -- the same exception.
END generate_pruned_view;


-- ============================================================================
--PROCEDURE : generate_Views
--PARAMETERS: 1. x_error_buf          error buffer to hold concurrent program
--                                    errors
--            2. x_ret_code           return code of concurrent program
--            3. p_all_flag           generate all views for all products
--            4. p_Appl_Short_Name    application product_short name
--            5. p_KF_Appl_Short_Name application product_short name
--            6. p_Key_Flex_Code      key flexfield code
--            7. p_DF_Appl_Short_Name application product_short name
--            8. p_Desc_Flex_Name     descriptive flex field name
--            9. p_Lookup_Table_Name  lookup table name
--           10. p_Lookup_Type        lookup code type
--           11. p_View_Name          name of view to generate
--COMMENT   : Launch this program to generate the business view(s) with the
--            key flexfield, descriptive flexfield and lookup information.
--EXCEPTION : None
-- ============================================================================
PROCEDURE generate_Views -- PUBLIC PROCEDURE
( x_error_buf          OUT VARCHAR2
, x_ret_code           OUT NUMBER
, p_all_flag           IN  VARCHAR2                         := NULL
, p_App_Short_Name     IN  bis_vg_types.App_Short_Name_Type := NULL
, p_KF_Appl_Short_Name IN  bis_vg_types.App_Short_Name_Type := NULL
, p_Key_Flex_Code      IN  bis_vg_types.Key_Flex_Code_Type  := NULL
, p_DF_Appl_Short_Name IN  bis_vg_types.App_Short_Name_Type := NULL
, p_Desc_Flex_Name     IN  bis_vg_types.Desc_Flex_Name_Type := NULL
, p_Lookup_Table_Name  IN  VARCHAR2                         := NULL
, p_Lookup_Type        IN  bis_vg_types.Lookup_Code_Type    := NULL
, p_View_Name          IN  bis_vg_types.View_Name_Type      := NULL
)
IS
--
l_View_Table             bis_vg_types.View_Table_Type;
l_View_Column_Text_Table bis_vg_types.View_Text_Table_Type;
l_View_Select_Text_Table bis_vg_types.View_Text_Table_Type;
l_View_Column_Out_Table  bis_vg_types.View_Text_Table_Type;
l_View_Select_Out_Table  bis_vg_types.View_Text_Table_Type;
l_View_Text_Table        bis_vg_types.View_Text_Table_Type;
l_View_Column_Comment_Table bis_vg_types.Flex_Column_Comment_Table_Type;
l_debug_file             VARCHAR2(2000);
l_log_file               VARCHAR2(2000);
l_out_file               VARCHAR2(2000);
l_warehouse_exists       NUMBER(1) ;
l_instance               VARCHAR2(200);
l_generated_view_name    bis_vg_types.view_name_type;
l_error_message          VARCHAR2(4000);
l_return_status          VARCHAR2(1000);
l_error_Tbl              BIS_VG_UTIL.Error_Tbl_Type;

--
BEGIN
--
  l_warehouse_exists := 1;
  IF (  g_mode = bis_vg_types.production_mode
     OR g_mode = bis_vg_types.sqlplus_production_mode
     OR g_mode = bis_vg_types.remove_tags_mode
     ) THEN
    fnd_profile.put('FND_AS_MSG_LEVEL_THRESHOLD'
                   , FND_MSG_PUB.G_MSG_LVL_SUCCESS);
  ELSE
    fnd_profile.put('FND_AS_MSG_LEVEL_THRESHOLD'
                   , FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
  END IF;
--
  l_debug_file := bis_debug_pub.set_debug_mode('FILE');
  bis_debug_pub.initialize;
  bis_debug_pub.setdebuglevel(10);
--
  bis_debug_pub.Add('> generate_Views');
  x_ret_code := 0;
  -- verify parameters
  -- retrieve business views

  --- CHECK FOR WAREHOUSE PRESENCE
   BEGIN

      execute immediate 'ALTER session SET global_names=FALSE';
      SELECT db_link INTO l_instance from user_db_links where
	db_link like 'EDW_APPS_TO_WH%';

      SELECT a.table_name INTO l_instance FROM all_tables a, user_synonyms u
	WHERE a.table_name = 'EDW_LOCAL_GENERATION_STATUS'
	AND u.table_name= 'EDW_LOCAL_GENERATION_STATUS'
	AND a.owner = u.table_owner;
      l_warehouse_exists := 1;
   EXCEPTION
      WHEN others THEN
	 l_warehouse_exists := 0;
   END;

  BIS_VG_REPOSITORY_MEDIATOR.retrieve_Business_Views
                            ( p_all_flag
                            , p_App_Short_Name
                            , p_KF_Appl_Short_Name
                            , p_Key_Flex_Code
                            , p_DF_Appl_Short_Name
                            , p_Desc_Flex_Name
                            , p_Lookup_Table_Name
                            , p_Lookup_Type
                            , p_View_Name
                            , l_View_Table
                            , l_return_status
                            , l_error_Tbl
                            );
  bis_vg_log.init_log(l_return_status, l_error_Tbl);

  IF (g_mode <> bis_vg_types.production_mode) THEN
--
   BEGIN
    -- only dbms_output allowed in the whole program
    --dbms_output.put_line('Debug file - ' || l_debug_file);
      BIS_VIEW_GENERATOR_PVT.g_debug_file  := ('Debug file - ' || l_debug_file);
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

--
--
    IF (g_mode <> bis_vg_types.sqlplus_production_mode) THEN
      bis_debug_pub.debug_on;
      bis_debug_pub.Add('BIS_VEW_GENERATOR. Generate_Views : '
			|| 'l_View_Table.count = ' || l_View_Table.COUNT);
      bis_debug_pub.debug_off;
    END IF;
--
  END IF;
  --
      IF (l_View_Table.count = 0)
    THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_view_generator_pvt.GENERATOR_NO_VIEWS
	 , p_error_proc_name   => G_PKG_NAME||'.generate_Views'
	 , p_error_table       => l_error_tbl
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , x_error_table       => l_error_tbl
	 );
    RAISE FND_API.G_EXC_ERROR;
  END IF;


--
--
  FOR i IN 1 .. l_View_Table.COUNT LOOP
--
    fnd_msg_pub.initialize;
    l_generated_view_name :=
      bis_vg_util.get_generated_view_name (l_View_Table(i).view_name
					   , l_return_status
					   , l_error_Tbl
					   );
    BEGIN
--
      IF (g_mode <> bis_vg_types.test_no_view_gen_mode) then
       --- start a block for use in updating warehouse status
       BEGIN --- BLOCK inside IF enumerate-without-generate mode
 --  Bug 6819715
       --  Check the profile and database version to decide if the we need to modify some session and system settings
       --- and user optimizer hints
         BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints := nvl(FND_PROFILE.VALUE('BVG_OPTIMIZER_MODE'),'NEW');
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_PVT.GENERATE_VIEWS',
                       'g_use_optimizer_hints is  '||g_use_optimizer_hints);
         END IF;
         BEGIN
            SELECT substrb(version, 1, instrb(version,'.') -1) into BIS_VIEW_GENERATOR_PVT.g_db_version
            FROM product_component_version
            WHERE upper(product) like 'ORACLE';
         EXCEPTION
            WHEN OTHERS THEN
               BIS_VIEW_GENERATOR_PVT.g_db_version := '10';
         END;
         IF BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints = '9' and BIS_VIEW_GENERATOR_PVT.g_db_version > 9 then
         --This is the only case we want to use optimizer hints to try to mimic a 9i database
         --when we are not on a 9i database
           BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints  := '9.2';
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'fnd.plsql.BIS_VG_PVT.GENERATE_VIEWS',
                              'g_use_optimizer_hints is 9.2');
           END IF;

         ELSIF  BIS_VIEW_GENERATOR_PVT.g_db_version IN ('10', '11') AND BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints = 'NEW' then
         --This mode setting will cause the Desc Flex package to use the cursor with the new order by clause
         --on a new install no one should be on 9.2
           BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints  := 'NEW';
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'fnd.plsql.BIS_VG_PVT.GENERATE_VIEWS',
                              'g_use_optimizer_hints is NEW');
           END IF;

         ELSIF  BIS_VIEW_GENERATOR_PVT.g_db_version = '9' OR BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints IN ('10', '11') then
         --This setting cause the Desc Flex package to use the original cursor
           BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints  := '9i';
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                              'fnd.plsql.BIS_VG_PVT.GENERATE_VIEWS',
                              'g_use_optimizer_hints is 9i');
           END IF;
         END IF;
         IF  BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints = '9.2'then
            -- execute immediate v_shared_pool;
            execute immediate v_session_sort;
         END IF;
--  END BUG 6819715
	  --- create two tables - one with columns, one with the view text
	  BIS_VG_REPOSITORY_MEDIATOR.create_View_Text_Tables
	                       ( l_View_Table(i).view_name
                               , l_View_Column_Text_Table
                               , l_View_Select_Text_Table
                               , l_error_Tbl
                               );
	--
	  Update_View( p_view_column_text_table => l_view_column_text_table
                     , p_view_select_text_table  => l_View_Select_Text_Table
		     , p_mode => g_mode
		     , x_view_column_text_table => l_view_column_out_table
                     , x_view_select_text_table => l_view_select_out_table
                     , x_view_column_comment_table => l_view_column_comment_table
		     , x_error_tbl => l_error_Tbl
                     );

--
	  IF (l_view_column_out_table.COUNT > 0) THEN
	     --create the view
	     ---	   bis_debug_pub.debug_on;
	     BIS_VG_COMPILE.write_View
	       ( g_mode
		 , l_View_Table(i).view_name
		 , l_View_Column_out_Table
		 , l_View_Select_out_Table
		 , l_View_Column_Comment_Table
		 , l_View_Column_Comment_Table
		 ---          , l_return_status
		 , l_error_Tbl
		 );
	     ---	   bis_debug_pub.debug_off;
	     --
	     --
	     -- Update the view column comments
	     comment_Flex_Columns(l_generated_view_name
	                          , l_view_column_comment_table);

	     --- Update generate status for warehouse views
	     IF ( l_warehouse_exists = 1
		  AND
		  (l_generated_view_name like '%LCV'
		   OR l_generated_view_name like '%FCV'
		   )
		  )
	       THEN
	       BEGIN
		  execute immediate update_status_stmt
		    using
		    'GENERATED_ALL',
		    '',
		    l_View_Table(i).view_name
		    ;

		  IF SQL%notfound
		    THEN
		     execute immediate  insert_status_stmt
		       using
		       l_View_Table(i).view_name,
		       'GENERATED_ALL',
		       ''
		       ;
		  END IF;
	       EXCEPTION
		  WHEN OTHERS THEN
		     --- Ignore all exceptions due to non-definition of EDW
		     l_warehouse_exists := 0;
	       END;

	     END IF;



	     bis_vg_log.update_success_log( l_View_Table(i).view_name
					    , l_generated_view_name
					    , l_return_status
					    , l_error_Tbl
					    );

	  END IF; --- generated COUNT > 0
       EXCEPTION
	  WHEN OTHERS THEN
	     IF ( l_warehouse_exists = 1
		  AND
		  (l_generated_view_name like '%LCV'
		   OR l_generated_view_name like '%FCV'
		   )
		  )
	       THEN
		bis_vg_log.write_error_to_string(l_error_message);
                BEGIN
		  execute immediate update_status_stmt
		    using
		    'FAILED_ALL',
		    l_error_message,
		    l_View_Table(i).view_name
		    ;
		  IF SQL%notfound
		    THEN
		     execute immediate insert_status_stmt
		       using
		       l_View_Table(i).view_name,
		       'FAILED_ALL',
		       l_error_message
		       ;
		  END IF;
		EXCEPTION
		   WHEN OTHERS THEN
		      --- Ignore all exceptions due to non-definition of EDW
		      l_warehouse_exists := 0;
		END;

	     END IF;
	     RAISE; --- the same excpetion to the next block
       END; --- BLOCK inside IF enumerate-without-generate mode

       ELSE --- enumerate-without-generate mode
	 bis_vg_log.update_success_log( l_View_Table(i).view_name
					, l_generated_view_name
					, l_return_status
					, l_error_Tbl
					);

      END IF; --- Mode check
--
    EXCEPTION
--
       when FND_API.G_EXC_ERROR then
	  bis_vg_log.backpatch_failure_log( l_View_Table(i).view_name
					    , l_return_status
					    , l_error_Tbl
					    );
	  l_return_status := FND_API.G_RET_STS_ERROR ;
      when FND_API.G_EXC_UNEXPECTED_ERROR then
	  bis_vg_log.backpatch_failure_log( l_View_Table(i).view_name
					    , l_return_status
					    , l_error_Tbl
					    );
   	 l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--
      WHEN OTHERS THEN
  	bis_vg_log.update_failure_log( l_View_Table(i).view_name
  				     , SQLCODE
  				     , SQLERRM
				     , l_return_status
				     , l_error_Tbl
  				     );
    END;
  END LOOP;
--
  bis_vg_log.write_log( g_mode
                      , p_all_flag
                      , p_App_Short_Name
                      , p_KF_Appl_Short_Name
                      , p_Key_Flex_Code
                      , p_DF_Appl_Short_Name
                      , p_Desc_Flex_Name
                      , p_Lookup_Table_Name
                      , p_Lookup_Type
                      , p_View_Name
                      , l_return_status
                      , l_error_Tbl
                      );
--
  bis_debug_pub.Add('< generate_Views');
--
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     bis_vg_log.update_failure_log( l_error_tbl
				    , l_return_status
				    , l_error_Tbl
				    );
     bis_vg_log.backpatch_failure_log( 'N/A'
				    , l_return_status
				    , l_error_Tbl
				    );
    bis_vg_log.write_log ( g_mode
			   , p_all_flag
			   , p_App_Short_Name
			   , p_KF_Appl_Short_Name
			   , p_Key_Flex_Code
			   , p_DF_Appl_Short_Name
			   , p_Desc_Flex_Name
			   , p_Lookup_Table_Name
			   , p_Lookup_Type
			   , p_View_Name
			   , l_return_status
			   , l_error_Tbl
			   );
   WHEN OTHERS THEN
    IF (g_mode = bis_vg_types.production_mode) THEN
      x_error_buf := SQLERRM;
      x_ret_code := 2;
     ELSE
       bis_debug_pub.debug_on;
       bis_debug_pub.Add('Error code    - '||SQLCODE);
       bis_debug_pub.ADD('Error message - '||Sqlerrm);
       bis_debug_pub.debug_off;
    END IF;
END generate_Views;

PROCEDURE set_mode
(p_mode IN bis_vg_types.view_generator_mode_type)
IS
BEGIN
   bis_debug_pub.Add('> set_mode');
   g_mode := p_mode;
   bis_debug_pub.Add('< set_mode');
EXCEPTION
  WHEN OTHERS THEN
    bis_debug_pub.debug_on;
    bis_debug_pub.add('bis_view_generator_pvt.set_mode');
    bis_debug_pub.debug_off;
    fnd_msg_pub.Add_Exc_Msg( 'bis_view_generator_pvt'
                           , 'set_mode'
                           );
    RAISE;
--
  END set_mode;

PROCEDURE set_mode
(p_mode IN bis_vg_types.view_generator_mode_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
BEGIN
   bis_debug_pub.Add('> set_mode');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   g_mode := p_mode;
   bis_debug_pub.Add('< set_mode');
--
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.set_mode'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END set_mode;

END bis_view_generator_pvt;


/
