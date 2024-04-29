--------------------------------------------------------
--  DDL for Package Body BIS_VG_KEY_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_KEY_FLEX" AS
/* $Header: BISTKFXB.pls 120.2 2005/11/16 10:39:27 dbowles ship $ */

---  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---      BISTKFXB.pls
---
---  DESCRIPTION
---
---      body of package which handles key flexfield tags
---
---  NOTES
---
---  HISTORY
---
---  29-JUL-98 Created
---  21-Apr-99 Edited by WNASRALL@US to correct parsing behavior
---  10-NOV-00 Edited by WNASRALL@US to add new function generate_pruned_view
---  22-JAN-01 Edited by WNASRALL@US to fix problem with generate_pruned_view
---  06-APR-01 Edited by dbowles.  Modified add_key_flexfield_segments,
---            update_Key_Flex_Tables and add_Key_Flex_Info procedures
---            adding new parameter x_Column_Comment_Table.  This PL/SQL
---            table is used to hold flex information for flex derived
---            columns.
---  01-Jun-01 Edited by ILI  fix bug1802137
---  19-JUL-01 Edited by Walid.Nasrallah : surrounded previous fix by an
---            IF statement  to limit its effect to EDW views only.
---  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
---  19-MAY-03 Modified update_Key_Flex_Tables not name a column over 30 bytes
---            while still preserving the structure number.
---
---
-- ============================================================================


-- =====================
-- GLOBAL CONSTANTS
-- =====================

G_PKG_NAME CONSTANT VARCHAR(30) := 'bis_vg_key_flex';


-- =====================
-- PRIVATE PROCEDURES
-- =====================
--
-- PROCEDURE : parse_KF_Column_Line
-- PARAMETERS: 1. p_View_Column_Table   table of varchars to hold columns of
--                                      view text
--             2. p_Column_Pointer      pointer to the key flex column in
--                                      column table (IN)
--             3. x_Column_Pointer      pointer to the char after the delimiter
--                                      in column table (OUT)
--             4. x_Concat_Seg_Name     concatenated segment name
--             5. l_concat_segment_flag flag to indicate if only concatenated
--                                      segments reqd.
--             6. x_return_status    error or normal
--             7. x_error_Tbl        table of error messages
-- COMMENT   : Call this procedure to parse the KF view column tag.
-- ---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
-- ============================================================================
PROCEDURE parse_KF_Column_Line
( p_View_Column_Table   IN  bis_vg_types.View_Text_Table_Type
, p_Column_Pointer      IN  bis_vg_types.View_Character_Pointer_Type
, x_Column_Pointer      OUT bis_vg_types.View_Character_Pointer_Type
, x_Concat_Seg_Name     OUT VARCHAR2
, x_concat_segment_flag OUT BOOLEAN
, x_decode_on_segments  OUT BOOLEAN
, x_EDW_flag            OUT BOOLEAN
, x_prefix              OUT VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_token               VARCHAR2(100);
l_string              bis_vg_types.view_text_table_rec_type;
l_pos                 NUMBER;
l_message_token       VARCHAR2(2000);
--
BEGIN
  bis_debug_pub.Add('> parse_KF_Column_Line');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --   get row of text from table
  l_string := bis_vg_util.get_row ( p_View_Column_Table
            , p_Column_Pointer
          , x_return_status
          , x_error_Tbl
          );

  l_message_token := l_string;
    --   get "_KF"
  l_token := bis_vg_parser.get_string_token
                             ( l_string
                             , 1
                             , ':'
                             , l_pos
           , x_return_status
           , x_error_Tbl
                             );
  bis_debug_pub.Add('l_token = ' || l_token);

--   get concatenated segment
  x_Concat_Seg_Name := bis_vg_parser.get_string_token
                                       ( l_string
                                       , l_pos
                                       , ':'
                                       , l_pos
               , x_return_status
               , x_error_Tbl
                                       );
  bis_debug_pub.Add('x_Concat_Seg_Name = ' || x_Concat_Seg_Name);
--
  IF (x_concat_seg_name IS NULL) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => BIS_VG_KEY_FLEX.KFX_COL_TAG_EXP_NO_SEG_MSG
   , p_error_proc_name   => G_PKG_NAME||'.parse_KF_Column_Line'
   , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
   , p_token1        => 'tag'
   , p_value1        => l_string
   , p_error_table       => x_error_tbl
   , x_error_table       => x_error_tbl
   );
     bis_vg_log.update_failure_log( x_error_tbl
            , x_return_status
            , x_error_Tbl
            );
     RAISE FND_API.G_EXC_ERROR;
  END IF;
--
  IF(l_pos IS NOT NULL) THEN
--     get next token, if any
    l_token := bis_vg_parser.get_string_token
                             ( l_string
                             , l_pos
                             , ':'
                             , l_pos
           , x_return_status
           , x_error_Tbl
                             );
    bis_debug_pub.Add('l_token = ' || l_token);

    IF( UPPER(l_token) = '_CO' ) THEN
      x_concat_segment_flag := TRUE;
      bis_debug_pub.Add('x_concat_segment_flag = TRUE');
    ELSIF ( UPPER(l_token) = '_BS') THEN
      x_decode_on_segments := TRUE;
      bis_debug_pub.Add('x_decode_on_segements = TRUE');
    ELSIF ( UPPER(l_token) = '_EDW') THEN  --EDW flag change
      x_EDW_flag:=true;
      bis_debug_pub.Add('x_EDW_flag = TRUE');  --EDW flag change
    ELSE
      IF(SUBSTR(l_token, 1, 1) = '_') THEN
   --
   BIS_VG_UTIL.Add_Error_message
     ( p_error_msg_name => BIS_VG_KEY_FLEX.KFX_COL_TAG_PREF_CO_MSG
       , p_error_proc_name   => G_PKG_NAME||'.parse_KF_Column_Line'
       , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
       , p_token1        => 'tag'
       , p_value1        => l_message_token
       , p_token2        => 'flag'
       , p_value2        => l_token
       , p_error_table       => x_error_tbl
       , x_error_table       => x_error_tbl
       );
   bis_vg_log.update_failure_log( x_error_tbl
          , x_return_status
          , x_error_Tbl
          );
   RAISE FND_API.G_EXC_ERROR;

      END IF;

      --
      x_prefix := l_token;
      bis_debug_pub.Add('x_prefix = ' || x_prefix);
      IF(l_pos IS NOT NULL) THEN
        l_token := bis_vg_parser.get_string_token
                                 ( l_string
                                 , l_pos
                                 , ':'
                                 , l_pos
         , x_return_status
         , x_error_Tbl
                                 );
        bis_debug_pub.Add('l_token = ' || l_token);

        IF( UPPER(l_token) = '_CO' ) THEN
          x_concat_segment_flag := TRUE;
          bis_debug_pub.Add('x_concat_segment_flag = TRUE');
        ELSIF ( UPPER(l_token) = '_BS') THEN
          x_decode_on_segments := TRUE;
          bis_debug_pub.Add('x_decode_on_segements = TRUE');
        ELSIF ( UPPER(l_token) ='_EDW') THEN     --EDW flag change
          x_EDW_flag := TRUE;
    bis_debug_pub.Add('x_EDW_flag = TRUE');  --EDW flag change
  ELSE
--
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => BIS_VG_KEY_FLEX.KFX_COL_TAG_EXP_BAD_FLAG_MSG
         , p_error_proc_name   => G_PKG_NAME||'.parse_KF_Column_Line'
         , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
         , p_token1        => 'tag'
         , p_value1        => l_message_token
         , p_token2        => 'flag'
         , p_value2        => l_token
         , p_error_table       => x_error_tbl
         , x_error_table       => x_error_tbl
         );
     bis_vg_log.update_failure_log( x_error_tbl
            , x_return_status
            , x_error_Tbl
            );
     RAISE FND_API.G_EXC_ERROR;
     --
   END IF;
      END IF;
    END IF;
  END IF;
  x_Column_Pointer := bis_vg_util.increment_pointer_by_row
                                    ( p_View_Column_Table
                                    , p_Column_Pointer
            , x_return_status
            , x_error_Tbl
                                    );
  bis_debug_pub.Add('< parse_KF_Column_Line');
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
    , p_error_proc_name   => G_PKG_NAME||'.parse_KF_Column_Line'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END parse_KF_Column_Line;
--
-- ============================================================================
-- FUNCTION: CHECK_APPLICATION_VALIDITY  (PRIVATE FUNCTION)
-- RETURNS: boolean - true if application short name p[assed is defined
--  1. p_app  short name of application
--
-- COMMENT  : Checks against the FND_APPLICATION_ALL_VIEW.
--            Called from parse_DF_Select_Line.
-- ---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
--  ==========================================================================
FUNCTION CHECK_APPLICATION_VALIDITY
  (  p_app    IN VARCHAR2
     )
  return boolean
  is
     l_return_value boolean ;
     l_dummy        number;
     cursor l_cursor is
  select 1
    from   fnd_application_all_view
    where  application_short_name = p_app;
begin
   BIS_DEBUG_PUB.Add('> check_application_validity');
   open l_cursor ;
   fetch l_cursor into l_dummy ;
   l_return_value := l_cursor%found ;
   close l_cursor ;
   BIS_DEBUG_PUB.Add('< check_application_validity');
   return(l_return_value);

END CHECK_APPLICATION_VALIDITY;


-- =============================================================================
-- PROCEDURE : parse_KF_Select_Line
-- PARAMETERS: 1. p_View_Select_Table table of varchars to hold select clause
--                                    of view text
--             2. p_Select_Pointer    pointer to the key flex column in select
--                                    table (IN)
--             3. x_Select_Pointer    pointer to the char after the delimiter in
--                                    select table (OUT)
--             4. x_PLSQL_Expression  PL/SQL expression
--             5. x_Application_Name  Application Name
--             6. x_Key_Flex_Code     Key Flexfield code
--             7. x_Table_Alias       Table alias
--             8. x_Structure_Column  Structure Column Name
--             9. x_return_status    error or normal
--            10. x_error_Tbl        table of error messages
-- COMMENT   : Call this procedure to parse the KF selected tag.
-- ---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
-- =============================================================================
PROCEDURE parse_KF_Select_Line
( p_View_Select_Table IN  bis_vg_types.View_Text_Table_Type
, p_Select_Pointer    IN  bis_vg_types.View_Character_Pointer_Type
, x_Select_Pointer    OUT bis_vg_types.View_Character_Pointer_Type
, x_PLSQL_Expression  OUT VARCHAR2
, x_Application_Name  OUT VARCHAR2
, x_Key_Flex_Code     OUT VARCHAR2
, x_Table_Alias       OUT VARCHAR2
, x_Structure_Column  OUT VARCHAR2
, x_DUMMY_flag        OUT BOOLEAN      --EDW flag change
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_token                VARCHAR2(100);
l_message_token        VARCHAR2(2000);
l_tmp_pointer          bis_vg_types.View_Character_Pointer_Type;
--
BEGIN
  bis_debug_pub.Add('> parse_KF_Select_Line');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_message_token := bis_vg_parser.get_expression( p_View_Select_Table
                                                 , p_Select_Pointer
                                                 , l_tmp_pointer
             , x_return_status
             , x_error_Tbl
               );
  l_tmp_pointer :=   bis_vg_util.increment_pointer
      ( p_View_Select_Table
  , l_tmp_pointer
  , x_return_status
  , x_error_Tbl
  );

  --   get '_KF'

  l_token := bis_vg_parser.get_token_increment_pointer
                            ( p_View_Select_Table
                            , p_Select_Pointer
                            , ':'''
                            , x_Select_Pointer
          , x_return_status
          , x_error_Tbl
                            );
  IF bis_vg_util.equal_pointers(
        l_tmp_pointer
        , x_select_pointer
        , x_return_status
        , x_error_Tbl
        )
    THEN
     raise MALFORMED_KFX_SEL_TAG_NO_FIELD;
  END IF;

  l_token := bis_vg_parser.get_token_increment_pointer
                            ( p_View_Select_Table
            , x_Select_Pointer
            , ':'''
            , x_Select_Pointer
            , x_return_status
            , x_error_Tbl
            );

  IF (l_token IS NULL
      OR
      bis_vg_util.equal_pointers(
        l_tmp_pointer
        , x_select_pointer
        , x_return_status
        , x_error_Tbl
         )
      ) THEN
     raise MALFORMED_KFX_SEL_TAG_NO_FIELD;
  END IF;
--

  -- check for dummy tag
--EDW flag change
IF (l_token = '_DUMMY') THEN
   x_DUMMY_flag := TRUE;
   l_token := bis_vg_parser.get_token_increment_pointer
                            ( p_View_Select_Table
                            , x_Select_Pointer
                            , ':'
                            , x_Select_Pointer
          , x_return_status
                            , x_error_Tbl
                            );

END IF;
--EDW flag change

  -- check for SQL epression
  IF (l_token = '_EX') THEN
    x_PLSQL_Expression := bis_vg_parser.get_expression
                                        ( p_View_Select_Table
                                        , x_Select_Pointer
                                        , x_Select_Pointer
          , x_return_status
          , x_error_Tbl
                                        );
--
    IF (x_plsql_expression IS NULL) THEN
       raise MALFORMED_KFX_SEL_TAG_NO_FIELD;
    END IF;
--
    -- replace escaped single quotes with a single single quote
    x_PLSQL_Expression := REPLACE(x_PLSQL_Expression, '''''', '''');
  --
  ELSE
    x_Application_Name := l_token;
    IF NOT check_application_validity(x_Application_Name)
      THEN
       BIS_VG_UTIL.Add_Error_message
   ( p_error_msg_name => BIS_VG_KEY_FLEX.KFX_SEL_TAG_EXP_INVALID_APP
     , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Select_Line'
     , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
     , p_token1        => 'tag'
     , p_value1        => l_message_token
     , p_token2        => 'app'
     , p_value2        => x_Application_Name
     , p_error_table       => x_error_tbl
     , x_error_table       => x_error_tbl
     );
       bis_vg_log.update_failure_log( x_error_tbl
              , x_return_status
              , x_error_Tbl
              );
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_Key_Flex_Code := bis_vg_parser.get_token_increment_pointer
      ( p_View_Select_Table
                                      , x_Select_Pointer
                                      , ':'''
                                      , x_Select_Pointer
              , x_return_status
              , x_error_Tbl
                                      );
      IF(
   x_Key_Flex_Code IS NULL
   OR
   bis_vg_util.equal_pointers(
            l_tmp_pointer
            , x_select_pointer
            , x_return_status
            , x_error_Tbl
            )
   ) THEN
--
       raise MALFORMED_KFX_SEL_TAG_NO_FIELD;
    END IF;

    x_Table_Alias := bis_vg_parser.get_token
      ( p_View_Select_Table
  , x_Select_Pointer
  , ':'''
  , x_Select_Pointer
  , x_return_status
  , x_error_Tbl
  );

    IF (x_Table_Alias IS NULL) THEN
       raise MALFORMED_KFX_SEL_TAG_NO_FIELD;
    END IF;
--
    IF(bis_vg_util.get_char( p_View_Select_Table
                           , x_Select_Pointer
         , x_return_status
         , x_error_Tbl
                           ) = ':') THEN
      x_Select_Pointer := bis_vg_util.increment_pointer
                                       ( p_View_Select_Table
                                       , x_Select_Pointer
               , x_return_status
               , x_error_Tbl
                                       );
      x_Structure_Column := bis_vg_parser.get_token
                                           ( p_View_Select_Table
                                           , x_Select_Pointer
                                           , ':'''
                                           , x_Select_Pointer
             , x_return_status
             , x_error_Tbl
                                           );
    END IF;
  END IF;
  x_Select_Pointer := bis_vg_util.increment_pointer
                                    ( p_View_Select_Table
                                    , x_Select_Pointer
            , x_return_status
            , x_error_Tbl
                                    );
  bis_debug_pub.Add('< parse_KF_Select_Line');
--

EXCEPTION
   when MALFORMED_KFX_SEL_TAG_NO_FIELD
     THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      BIS_VG_UTIL.Add_Error_message
  ( p_error_msg_name => BIS_VG_KEY_FLEX.KFX_SEL_TAG_EXP_NO_FIELD_MSG
    , p_error_proc_name   => G_PKG_NAME||'.parse_KF_Select_Line'
    , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_token1        => 'tag'
    , p_value1        => l_message_token
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
   RAISE FND_API.G_EXC_ERROR;

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
    , p_error_proc_name   => G_PKG_NAME||'.parse_KF_Select_Line'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END parse_KF_Select_Line;
--
-- ============================================================================
-- PROCEDURE : add_key_flexfield_segments
-- PARAMETERS: 1. p_dummy_flag          indicates that a NULL is to be inserted
--                                      in the select
--             2. p_Structure_Num       number of the structure ie., 1, 2, 3
--             3. p_nStructures         total number of structures present
--             4. p_Flexfield           flexfield
--             5. p_Structure           structure
--             6. p_Concat_Seg_Name     concatenated segment name
--             7. p_Prefix              prefix for segments
--             8. p_Table_Alias         Table alias
--             9. x_Column_Table        table of varchars to hold select clause
--                                      of view text
--            10. x_Select_Table        table of varchars to hold select clause
--                                      of view text
--            11. x_Column_Comment_Table table of records that is used
--                                      to hold flex info for flex derived
--                                      columns.
--            12. x_return_status    error or normal
--            13. x_error_Tbl        table of error messages
-- COMMENT   : Call this procedure to build the column and select tables for
--             key flexfields.
-- ---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
-- ============================================================================
PROCEDURE add_key_flexfield_segments
( p_dummy_flag          IN  BOOLEAN
, p_Structure_Num       IN  NUMBER
, p_suffix              IN  VARCHAR2
, p_Flexfield           IN  FND_FLEX_KEY_API.FLEXFIELD_TYPE
, p_Structure           IN  FND_FLEX_KEY_API.STRUCTURE_TYPE
, p_Concat_Seg_Name     IN  VARCHAR2
, p_decode_on_segments  IN  BOOLEAN
, p_Prefix              IN  VARCHAR2
, p_Table_Alias         IN  VARCHAR2
, x_Column_Table        OUT bis_vg_types.View_Text_Table_Type
, x_Select_Table        OUT bis_vg_types.View_Text_Table_Type
, x_Column_Comment_Table OUT BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_Segment_List    FND_FLEX_KEY_API.SEGMENT_LIST;
l_Segment         FND_FLEX_KEY_API.SEGMENT_TYPE;
--
l_nSegments           NUMBER;
l_Concat_Segment_Flag BOOLEAN;          -- mirrors p_Concat_Segment_Flag
                                        -- to circumvent possible PL/SQL bug
l_prefix              VARCHAR2(100) := NULL;
l_prefix_Len          NUMBER := 0;
l_Concat_Seg_Name     VARCHAR2(100) := NULL;
l_Segment_Name        NUMBER := 0;
--
BEGIN
  bis_debug_pub.Add('> add_key_flexfield_segments');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Concat_Segment_Flag := FALSE;
--
  FND_FLEX_KEY_API.GET_SEGMENTS( flexfield    => p_Flexfield
                               , structure    => p_Structure
                               , enabled_only => TRUE
                               , nsegments    => l_nSegments
                               , segments     => l_Segment_List
                               );

  IF( l_nSegments > 0 ) THEN
     IF(p_prefix IS NOT NULL) THEN
  l_prefix := p_prefix || '_';
     END IF;
     bis_debug_pub.Add('p_Concat_Seg_Name = ' || p_Concat_Seg_Name);
    --

     x_Select_Table(1) := ' ';
     FOR i IN 1 .. l_nSegments LOOP
  l_Segment := FND_FLEX_KEY_API.FIND_SEGMENT
                             ( flexfield    => p_Flexfield
                                     , structure    => p_Structure
                                     , segment_name => l_Segment_List(i)
                                     );
--
  x_Column_Table(i) := l_Prefix || l_Segment.segment_name
                                || p_Suffix;

---  Remove the following two lines. They overwrite the correct
--- x_Column_Table value at i-th slot.
----  This causes the key flexfield column name to not be appended
---  with the structure number.
---  ili, 06/01/01.
---

--- x_Column_Table(i) := l_Prefix || l_Segment.segment_name
---                                      || l_Struct_Num;

        x_Column_Comment_Table(i).column_name := l_Prefix
                                           || l_Segment.segment_name
                                                 || p_suffix;
        x_Column_Comment_Table(i).flex_type := 'KEY';

--- Populate the column_comments column with application_id, flex_code,
--- stucture_code,segment_name, application_column_name
  x_Column_Comment_Table(i).column_comments
    := p_Flexfield.table_application_id||','||
             p_Flexfield.flex_code||','||
       p_structure.structure_number||','||
       l_Segment.segment_name||','||l_Segment.column_name;


  IF p_dummy_flag
      THEN
       x_Select_Table(i) := ', NULL' ;

     ELSIF  p_decode_on_segments
       THEN
       x_Select_Table(i) := ', '
         || 'DECODE( ' || p_Table_Alias
         || '.'
         || p_flexfield.structure_column
         || ', '
         || p_structure.structure_number
         || ','
         || p_Table_Alias || '.' ||l_Segment.column_name
         || ', NULL' || ')';


     ELSE
       x_Select_Table(i) := ', ' || p_Table_Alias
         || '.' || l_Segment.column_name;
    END IF;

       END LOOP;
    END IF;

  bis_debug_pub.Add('< add_key_flexfield_segments');


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
    , p_error_proc_name   => G_PKG_NAME||'.add_key_flexfield_segments'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_key_flexfield_segments;

-- =============================================================================
-- PROCEDURE : add_kfx_segments_concat
-- PARAMETERS: 1. p_nStructures         total number of structures present
--             2. p_Flexfield           flexfield
--             3. p_Structure           structure
--             4. p_Table_Alias         Table alias
--             5. x_Select_Table        table of varchars to hold select clause
--                                      of view text
--             6. x_return_status    error or normal
--             7. x_error_Tbl        table of error messages
-- COMMENT   : Call this procedure to build the concatenated segments for a structure
-- ---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
-- =============================================================================
PROCEDURE add_kfx_segments_concat
( p_nStructures         IN  NUMBER
, p_Flexfield           IN  FND_FLEX_KEY_API.FLEXFIELD_TYPE
, p_Structure           IN  FND_FLEX_KEY_API.STRUCTURE_TYPE
, p_Table_Alias         IN  VARCHAR2
, p_pad_count           IN NUMBER
, x_Select_Table        OUT bis_vg_types.View_Text_Table_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_Segment_List    FND_FLEX_KEY_API.SEGMENT_LIST;
l_Segment         FND_FLEX_KEY_API.SEGMENT_TYPE;
--
l_nSegments           NUMBER;
l_prefix              VARCHAR2(100) := NULL;
l_prefix_Len          NUMBER := 0;
l_Concat_Seg_Name     VARCHAR2(100) := NULL;
l_Segment_Name        NUMBER := 0;
--
BEGIN
  bis_debug_pub.Add('> add_kfx_segments_concat');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_FLEX_KEY_API.GET_SEGMENTS( flexfield    => p_Flexfield
                               , structure    => p_Structure
                               , enabled_only => TRUE
                               , nsegments    => l_nSegments
                               , segments     => l_Segment_List
         );
  IF( l_nSegments > 0 ) THEN
    --
    FOR i IN 1 .. l_nSegments LOOP
      l_Segment := FND_FLEX_KEY_API.FIND_SEGMENT
                                     ( flexfield    => p_Flexfield
                                     , structure    => p_Structure
                                     , segment_name => l_Segment_List(i)
                                     );
      IF (i = 1) THEN
   IF(p_nStructures > 1) THEN
            x_Select_Table(x_select_table.COUNT +1 ) :=
        lpad(' ',p_pad_count)|| p_Structure.structure_number || ', ';
   END IF;
   x_Select_Table(x_select_table.COUNT +1 ) := lpad(' ',p_pad_count) || p_Table_Alias || '.' || l_Segment.column_name;
       ELSE
       -- increment the table pointer for every 5 segments added
   IF MOD(i,5)=0
     THEN
      x_select_table(x_select_table.COUNT+1) := Lpad(' ',p_pad_count+2);
   END IF;

   x_Select_Table(x_select_table.COUNT) :=
     x_Select_Table(x_select_table.COUNT)
     ||' || '''
     || p_Structure.segment_separator
     || ''' || '
     || p_Table_Alias || '.'
     || l_Segment.column_name;
      END IF;
    END LOOP;
  END IF;
  bis_debug_pub.Add('< add_kfx_segments_concat');
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
    , p_error_proc_name   => G_PKG_NAME||'.add_kfx_segments_concat'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_kfx_segments_concat;
--
-- ============================================================================
-- PROCEDURE : update_Key_Flex_Tables
-- PARAMETERS: 1. p_Concat_Seg_Name     concatenated segment name
--             2. p_Concat_Segment_Flag flag to indicate if only
--                                      concatenated segments desired
--             3. p_decode_on_segments  flag to indicate if select
--                                      statement should contain a decode
--                                      or always fetch data even when
--                                      meaningless
--             4. p_EDW_Flag            flag to add context column
--             5. p_dummy_flag          flag to indicate a flexfield
--                                      which is not valid in this branch
--                                      of a union, hence filled with
--                                      NULLs to keep number of columns.
--             6. p_column_table        PLSQL table of columns to prune by
--                                      if present, else expand all.
--             7. p_Prefix              prefix for segments
--             8. p_PLSQL_Expression    PL/SQL expression if any
--             9. p_Application_Name    Application Name
--            10. p_Key_Flex_Code       Key Flexfield code
--            11. p_Table_Alias         Table alias
--            12. p_Structure_Column    Name of structure column
--            13. x_Column_Table        table of varchars to hold
--                                      view columns
--            14. x_Select_Table        table of varchars to hold select
--                                      clause of view text
--            15. X_Column_Comment_Table table to hold flex info for
--                                      flex derived columns
--            16. x_return_status    error or normal (not used)
--            17. x_error_Tbl        table of error messages
--                                      of view text
-- COMMENT   : Call this procedure to build the column and select
--             tables for key flexfields.
-- ---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
-- ============================================================================
PROCEDURE update_Key_Flex_Tables
( p_Concat_Seg_Name     IN  VARCHAR2
, p_Concat_Segment_Flag IN  BOOLEAN
, p_decode_on_segments  IN  BOOLEAN
, p_EDW_Flag            IN  BOOLEAN
, p_dummy_flag          IN  BOOLEAN
, p_column_table        IN  BIS_VG_TYPES.flexfield_column_table_type
, p_Prefix              IN  VARCHAR2
, p_PLSQL_Expression    IN  VARCHAR2
, p_Application_Name    IN  VARCHAR2
, p_Key_Flex_Code       IN  VARCHAR2
, p_Table_Alias         IN  VARCHAR2
, p_Structure_Column    IN  VARCHAR2
, x_Column_Table        OUT bis_vg_types.View_Text_Table_Type
, x_Select_Table        OUT bis_vg_types.View_Text_Table_Type
, x_Column_Comment_Table  OUT BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--

--
l_Flexfield      FND_FLEX_KEY_API.FLEXFIELD_TYPE;
l_Structure_List FND_FLEX_KEY_API.STRUCTURE_LIST;
l_Structure      FND_FLEX_KEY_API.STRUCTURE_TYPE;
--
l_nStructures       NUMBER;
l_count             NUMBER;
l_Column_Table      bis_vg_types.View_Text_Table_Type;
l_Select_Table      bis_vg_types.View_Text_Table_Type;
l_Column_Comment_Table   BIS_VG_TYPES.Flex_Column_Comment_Table_Type;
--
l_prefix            VARCHAR2(100) := NULL;
l_suffix            VARCHAR2(100) := NULL;
l_delimiter         VARCHAR2(10) := '  ';
l_DUMMY_Flag        BOOLEAN;   ---EDW flag change
l_decode_Counter    NUMBER := 1;  --- change for bug 1752739
l_decode_max        NUMBER := 127;
l_prefix_len        NUMBER;
--

BEGIN
--
   bis_debug_pub.debug_on;
   bis_debug_pub.Add('> update_Key_Flex_Tables');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   bis_debug_pub.Add('p_Table_Alias = ' || p_Table_Alias);
   IF(p_prefix IS NOT NULL) THEN
      l_prefix := p_prefix || '_';
   END IF;

--- What to do in case of PLSQL expression:
  IF(p_PLSQL_Expression IS NOT NULL) THEN
     IF (p_Concat_Segment_Flag ) THEN

  --- -1- column table
  x_Column_Table(1) := l_Prefix || p_Concat_Seg_Name;
    --- -2- select table
  IF p_dummy_flag THEN
     bis_vg_util.create_Text_Table('NULL'
             , x_Select_Table
             , x_return_status
             , x_error_tbl
             );
     ELSE

       bis_vg_util.create_Text_Table(p_PLSQL_Expression
             , x_Select_Table
             , x_return_status
             , x_error_Tbl
             );
    END IF; --- dummy flag

      ELSE ---  plsql expression with no concat segment clause: Should not occur
  bis_debug_pub.add('flag error');
     END IF; --- concat segment flag

     --- not a plsql expression - must be a flexfield
   ELSIF (p_column_table IS NULL)
     --- regular BVG behavior (not pruned)
     THEN
     bis_debug_pub.Add('regular BVG behavior (not pruned)');
     FND_FLEX_KEY_API.SET_SESSION_MODE(session_mode => 'customer_data');
     l_Flexfield := FND_FLEX_KEY_API.FIND_FLEXFIELD
                   ( appl_short_name => p_Application_Name
                     , flex_code => p_Key_Flex_Code
                   );
     FND_FLEX_KEY_API.GET_STRUCTURES( flexfield    => l_Flexfield
              , enabled_only => TRUE
              , nstructures  => l_nStructures
              , structures   => l_Structure_List
              );

  ---EDW flag change
     IF(l_nStructures = 0) THEN
  --- If the flexfield is not defined then we do not want to do anything.
       bis_debug_pub.add('No Structures');
       l_dummy_flag := TRUE;
     ELSE
       l_dummy_flag := p_dummy_flag;
--- bis_debug_pub.Add('< update_Key_Flex_Tables');
--- return;
     END IF;

     IF (p_EDW_Flag ) THEN
        x_Column_Table(x_column_table.COUNT+1):= l_Prefix || 'context';

        IF l_dummy_flag OR l_Flexfield.structure_column IS NULL THEN
           x_Select_Table(x_Select_Table.COUNT + 1) := 'TO_NUMBER(NULL),';
        ELSE
           x_Select_Table(x_Select_Table.COUNT + 1) := p_Table_Alias
                                                       || '.'
                                                       || l_Flexfield.structure_column
                                                       || ', ';
        END IF; --- dummy flag
     END IF;  --- EDW flag


     --
     -- set the column table

     x_Column_Table(x_column_table.COUNT+1):= l_Prefix || p_Concat_Seg_Name;
     IF l_dummy_flag THEN
        x_Select_Table(x_Select_Table.COUNT + 1) := 'NULL';
     ELSE
        IF(l_nStructures > 1) THEN
           --- add the decode statement only first
           x_Select_Table(x_Select_Table.COUNT + 1) := ' DECODE( ' || p_Table_Alias
                                                         || '.'
                                                         || l_Flexfield.structure_column;
        END IF;

        bis_debug_pub.Add('l_nStructures = ' || l_nstructures);
  --
        FOR i IN 1 .. l_nStructures LOOP
       -- nest a DECODE statement if we have more then 127 structures in the outer DECODE
       -- as we nest DECODE statements inside DECODE statements, the max number of
       -- values in the DECODE statement will decrement
        IF (MOD(i, l_decode_max) = 0) THEN
            x_Select_Table(x_Select_Table.COUNT + 1) := lpad(' ',7*l_decode_counter)
                                                             ||', DECODE( ' || p_Table_Alias
                                                             || '.'
                                                             || l_Flexfield.structure_column;
            l_decode_Counter := l_decode_Counter +1;
            l_decode_max := l_decode_max - 1;
        END IF;

        bis_debug_pub.ADD('before calling fnd');
        l_Structure := FND_FLEX_KEY_API.FIND_STRUCTURE( flexfield        => l_Flexfield
                                                        , structure_number => l_Structure_List(i)
                                                       );
        bis_debug_pub.ADD('after calling fnd');
        bis_debug_pub.Add('l_Structure.structure_name = ' ||l_Structure.structure_name);
        bis_debug_pub.Add('l_Structure.structure_number = ' ||l_Structure.structure_number);
        bis_debug_pub.Add('l_Structure.segment_separator = ' ||l_Structure.segment_separator);
     --

        add_kfx_segments_concat(l_nStructures
                                , l_Flexfield
                                , l_Structure
                                , p_table_alias
                                , 1 + (l_decode_counter * 8)
                                , l_Select_Table
                                , x_return_status
                                , x_error_Tbl
                                );
        IF l_select_table.COUNT > 0 THEN
           IF (l_nstructures > 1 OR i > 1)THEN
              x_Select_Table(x_Select_Table.COUNT + 1) :=
              lpad(', ', 1 + (l_decode_counter * 8));
           END  IF;

           bis_vg_util.concatenate_Tables( x_Select_Table
                                           , l_Select_Table
                                           , x_Select_Table
                                           , x_return_status
                                           , x_error_Tbl
                                          );
        END IF;



        END LOOP;
  --
        bis_debug_pub.ADD('after the loop');
        IF(l_nStructures > 1) THEN
           IF(x_Select_Table.COUNT = 1) THEN
             -- seems like none of the structures had any segments defined
             -- hence add a NULL pair to make decode compile
             x_Select_Table(2) := '      , NULL, NULL';
            END IF;
           -- need to check to see if any nested DECODE statements
           x_Select_Table(x_Select_Table.COUNT+1) := lpad(', NULL'
                                                           ,l_decode_counter*8 + 5
                                                         );
           FOR i IN  REVERSE 1.. l_decode_Counter LOOP
               x_Select_Table(x_Select_Table.COUNT+1) := lpad(')'
                                                              ,i*8
                                                              );
           END LOOP;
         -- add the closing parentheses
        END IF;  --- l_nstructures > 1

  --
     END IF; --- dummy flag

     IF (p_concat_segment_flag) THEN
        bis_debug_pub.Add('p_Concat_Segment_Flag =  TRUE');
        --- we need to put in the columns as well
          NULL;
     ELSE
        bis_debug_pub.Add('p_Concat_Segment_Flag =  FALSE');
        --
        --- we need to put in the columns as well

        bis_debug_pub.ADD('adding columns to the table');

        FOR i IN 1 .. l_nStructures LOOP
           bis_debug_pub.ADD('before calling fnd');
           l_Structure := FND_FLEX_KEY_API.FIND_STRUCTURE( flexfield => l_Flexfield
                                                           , structure_number => l_Structure_List(i)
                                                          );
           bis_debug_pub.ADD('after calling fnd');
           bis_debug_pub.Add('l_Structure.structure_name = '||l_Structure.structure_name);
           bis_debug_pub.Add('l_Structure.structure_number = '||l_Structure.structure_number);
           bis_debug_pub.Add('l_Structure.segment_separator = '||l_Structure.segment_separator);
        --
        IF(l_nStructures > 1 OR p_edw_flag) THEN
        -- we should use '^' rather than '_' (bug 2259939)
           l_Suffix := '^' || TO_CHAR(l_Structure.structure_number);
        END IF;

        add_key_flexfield_segments(p_dummy_flag
                                   , i
                                   , l_Suffix
                                   , l_Flexfield
                                   , l_Structure
                                   , p_Concat_Seg_Name
                                   , p_decode_on_segments
                                   , p_Prefix
                                   , p_Table_Alias
                                   , l_Column_Table
                                   , l_Select_Table
                                   , l_Column_Comment_Table
                                   , x_return_status
                                   , x_error_Tbl
                                   );
     --
        bis_vg_util.concatenate_Tables(x_Column_Table
                                       , l_Column_Table
                                       , x_Column_Table
                                       , x_return_status
                                       , x_error_Tbl
                                       );

        bis_vg_util.concatenate_Tables(x_Select_Table
                                       , l_Select_Table
                                       , x_Select_Table
                                       , x_return_status
                                       , x_error_Tbl
                                       );

        bis_vg_util.concatenate_Tables( x_column_comment_table
                                          , l_column_comment_table
                                          , x_column_comment_table
                                          , x_return_status
                                          , x_error_Tbl
                                          );
        END LOOP;
     --
     END IF; --- Concat_segment_flag false

   ELSE --- The pruned case - no need for concatenated segments column.
     bis_debug_pub.Add('The pruned case');
     FND_FLEX_KEY_API.SET_SESSION_MODE(session_mode => 'customer_data');
     l_Flexfield := FND_FLEX_KEY_API.FIND_FLEXFIELD
                                     (appl_short_name => p_Application_Name
                                      , flex_code => p_Key_Flex_Code
                                      );

     ---  Add selected columns
     l_count := 2;
     FOR i in p_column_table.first..p_column_table.last LOOP
      IF ( p_column_table(i).flex_field_type = 'K'
---        AND p_column_table(i).flexfield_prefix = p_prefix
           AND p_column_table(i).id_flex_code =  p_key_flex_code) THEN
      --- make sure that the structure number is maintained in the column name.
       x_column_table(l_count):= l_prefix
                                 || substrb(p_column_table(i).segment_name, 1
                                    , (30 - lengthb(l_prefix)- lengthb(p_column_table(i).structure_num)- 1))
                                 || '_'
                                 ||p_column_table(i).structure_num;

          IF p_dummy_flag OR p_column_table(i).application_column_name IS NULL THEN
             x_select_table(l_count) :=  ', NULL';
          ELSE
             x_select_table(l_count) :=  ' , '
                                       || p_table_alias
                                       || '.'
                                       || p_column_table(i).application_column_name;
          END IF;  --- dummy_flag
       l_count := l_count + 1;
      END IF; --- p_column_table(i) matches criteria
     END LOOP;
       --- Add context to all flexfields which have segments selected
       IF l_count > 2 THEN

          x_Column_Table(1):= l_Prefix || 'context';

          IF p_dummy_flag OR l_Flexfield.structure_column IS NULL THEN
             x_Select_Table(1) := 'TO_NUMBER(NULL)';
          ELSE
             x_Select_Table(1) := p_Table_Alias
             || '.'
             || l_Flexfield.structure_column;
          END IF; --- dummy flag
       END IF; --- l_count > 2
  END IF; ---PLSQL_expression ELSE flexfield full lookup ELSE pruned lookup

    bis_vg_util.print_View_Text
                            ( x_Column_Table
                            , x_return_status
                            , x_error_Tbl
                            );

    bis_vg_util.print_View_Text
                            ( x_Select_Table
                            , x_return_status
                            , x_error_Tbl
                            );

  --
  bis_debug_pub.Add('< update_Key_Flex_Tables');
  bis_debug_pub.debug_off;
--- ====== ====== ====== ====== ====== ======
--- OBSOLETE FUNCTIONALITY: we no longer care if there are no segments in
--- the flexfield - leave a blank in the view
--- ====== ====== ====== ====== ====== ======
---       IF (x_select_table.COUNT = 0) THEN
---   -- no segments in the key flex.
---   --
---   BIS_VG_UTIL.Add_Error_message
---     ( p_error_msg_name => BIS_VG_KEY_FLEX.NO_SEGMENTS_IN_KEY_FLEX_MSG
---       , p_error_proc_name   => G_PKG_NAME||'.update_Key_Flex_Tables'
---       , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
---       , p_error_table       => x_error_tbl
---       , x_error_table       => x_error_tbl
---       );
---   bis_vg_log.update_failure_log( x_error_tbl
---          , x_return_status
---          , x_error_Tbl
---          );
---   RAISE FND_API.G_EXC_ERROR;
---
---
---       END IF;

--  if no segments defined for flexfield use  NULL for the column
       IF (x_select_table.COUNT = 0) THEN
          x_select_table(1) := 'NULL';
       END IF;

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
    , p_error_proc_name   => G_PKG_NAME||'.update_Key_Flex_Tables'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END update_Key_Flex_Tables;

---
---
--- =====================
--- PUBLIC PROCEDURES
--- =====================
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
---              10. x_Column_Comment_Table table of records used to hold flex info
---                                       for flex derived columns
---              11. x_Column_Pointer     pointer to the character after the delimiter
---                                       (column table)
---              12. x_Select_Pointer     pointer to the character after the delimiter
---                                       (select table)
---              13. x_return_status    error or normal
---              14. x_error_Tbl        table of error messages
---
---   COMMENT   : Call this procedure to add particular key flexfield information to a view.
---   EXCEPTION : FND_API.G_EXC_UNEXPECTED_ERROR
---               FND_API.G_EXC_ERROR;
--- ==================================================================================== */

PROCEDURE add_Key_Flex_Info
( p_View_Column_Table    IN  bis_vg_types.View_Text_Table_Type
, p_View_Select_Table    IN  bis_vg_types.View_Text_Table_Type
, p_Mode                 IN  NUMBER
, p_column_table         IN  BIS_VG_TYPES.flexfield_column_table_type
, p_Column_Pointer       IN  bis_vg_types.View_Character_Pointer_Type
, p_Select_Pointer       IN  bis_vg_types.View_Character_Pointer_Type
, p_From_Pointer         IN  bis_vg_types.View_Character_Pointer_Type
, x_Column_Table         OUT bis_vg_types.View_Text_Table_Type
, x_Select_Table         OUT bis_vg_types.View_Text_Table_Type
, x_Column_Comment_Table OUT BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, x_Column_Pointer       OUT bis_vg_types.View_Character_Pointer_Type
, x_Select_Pointer       OUT bis_vg_types.View_Character_Pointer_Type
, x_return_status        OUT VARCHAR2
, x_error_Tbl            OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_Concat_Seg_Name     VARCHAR2(100);
l_Prefix              VARCHAR2(100);
l_EDW_Flag            BOOLEAN;   ---EDW flag change
l_DUMMY_Flag          BOOLEAN;   ---EDW flag change
l_Concat_Segment_Flag BOOLEAN;
l_decode_on_segments  BOOLEAN;
--
l_PLSQL_Expression VARCHAR2(2000);
l_Application_Name VARCHAR2(10);
l_Key_Flex_Code    VARCHAR2(100);
l_Table_Alias      VARCHAR2(100);
l_Table_Name       VARCHAR2(100);
l_Structure_Column VARCHAR2(100);
--
BEGIN
--
  bis_debug_pub.Add('> add_Key_Flex_Info');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  parse_KF_Column_Line( p_View_Column_Table
                      , p_Column_Pointer
                      , x_Column_Pointer
                      , l_Concat_Seg_Name
                      , l_Concat_Segment_Flag
                      , l_decode_on_segments
          , l_EDW_Flag       ---EDW flag change
                      , l_Prefix
          , x_return_status
          , x_error_Tbl
                      );

--- --- DEBUG ---
---  bis_debug_pub.Add('l_Concat_Seg_Name =  ' || l_Concat_Seg_Name);
---
---
---  IF(l_Concat_Segment_Flag = TRUE) THEN
---    bis_debug_pub.Add('l_Concat_Segment_Flag =  TRUE');
---  ELSE
---    bis_debug_pub.Add('l_Concat_Segment_Flag =  FALSE');
---  END IF;
--- --- -- -

  --- This clause catches flexfield tags that do not have the
  --- _EDW tags when the generator is called via generate_pruned_view
  IF (l_edw_flag = FALSE AND p_column_table IS NOT NULL)
    THEN
     RAISE bis_view_generator_pvt.CANNOT_PRUNE_NON_EDW_VIEW;
      END IF;

  parse_KF_Select_Line( p_View_Select_Table
                      , p_Select_Pointer
                      , x_Select_Pointer
                      , l_PLSQL_Expression
                      , l_Application_Name
                      , l_Key_Flex_Code
                      , l_Table_Alias
                      , l_Structure_Column
          , l_DUMMY_Flag      ---EDW flag change
          , x_return_status
          , x_error_Tbl
                      );
  bis_debug_pub.Add('l_PLSQL_Expression =  ' || l_PLSQL_Expression);
  bis_debug_pub.Add('l_Application_Name =  ' || l_Application_Name);
  bis_debug_pub.Add('l_Key_Flex_Code =  ' || l_Key_Flex_Code);
  bis_debug_pub.Add('l_Table_Alias =  ' || l_Table_Alias);
  bis_debug_pub.Add('l_Structure_Column =  ' || l_Structure_Column);

  IF(
     (p_Mode <> bis_vg_types.remove_tags_mode)
     AND
     (p_column_table IS NULL
      OR
      p_column_table.COUNT > 0
      )
    )
    THEN

---     IF(l_Prefix IS NULL) THEN
---      x_Column_Table(1) := l_Concat_Seg_Name;
---    ELSE
---      x_Column_Table(1) := l_Prefix || '_' || l_Concat_Seg_Name;
---    END IF;
---    x_Select_Table(1) := 'TO_CHAR(NULL)';
---  ELSE
     update_Key_Flex_Tables(l_Concat_Seg_Name
                          , l_Concat_Segment_Flag
                          , l_decode_on_segments
                          , l_EDW_flag
        , l_dummy_flag
        , p_column_table
        , l_prefix
        , l_PLSQL_Expression
                          , l_Application_Name
                          , l_Key_Flex_Code
                          , l_Table_Alias
                          , l_Structure_Column
                          , x_Column_Table
                          , x_Select_Table
                          , x_Column_Comment_Table
        , x_return_status
        , x_error_Tbl
                          );

  END IF;
  bis_debug_pub.Add('COLUMN POINTER');
  bis_vg_util.print_View_Pointer( x_Column_Pointer
          , x_return_status
        , x_error_Tbl
        );
  bis_debug_pub.Add('SELECT POINTER');
  bis_vg_util.print_View_Pointer( x_Select_Pointer
          , x_return_status
        , x_error_Tbl
        );
---  bis_debug_pub.debug_on;
  bis_vg_util.print_View_Text(x_Column_Table, x_return_status, x_error_Tbl);
  bis_vg_util.print_View_Text(x_Select_Table, x_return_status, x_error_Tbl);
  --
  bis_debug_pub.Add('< add_Key_Flex_Info');
---  bis_debug_pub.debug_off;
--


EXCEPTION
   when bis_view_generator_pvt.cannot_prune_non_edw_view THEN
      RAISE;    -- same exception
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE;    -- same exception
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;    -- same exception
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
  ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.add_Key_Flex_Info'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_Key_Flex_Info;
--
--
END bis_vg_key_flex;

/
