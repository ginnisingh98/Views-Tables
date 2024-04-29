--------------------------------------------------------
--  DDL for Package Body BIS_VG_DESC_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_DESC_FLEX" AS
/* $Header: BISTDFXB.pls 120.1.12010000.2 2008/10/25 00:00:38 dbowles ship $ */

---  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---      BISTDFXB.pls
---
---  DESCRIPTION
---
---      body of package which handles the descriptive flexfield tag
---
---  NOTES
---
---  HISTORY
---
---  29-JUL-98 Created
---  19-MAR-99 Edited by WNASRALL@US for exception handling
---  21-Apr-99 Edited by WNASRALL@US to correct parsing behavior
---  10-NOV-00 Edited by WNASRALL@US to  add new function generate_pruned_view
---  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
---
---
G_PKG_NAME CONSTANT VARCHAR(30) := 'bis_vg_desc_flex';
--- ===================
--- PRIVATE FUNCTION
--- ===================
---
FUNCTION to_boolean(value IN VARCHAR2) RETURN BOOLEAN
IS
  rv BOOLEAN;
BEGIN
   IF(value in ('Y', 'y')) THEN
      rv := TRUE;
    ELSE
      rv := FALSE;
   END IF;
   RETURN rv;
END;

-- =====================
-- PRIVATE PROCEDURES
-- =====================
-- ========================================
-- Procedure Name: Get_contexts
-- returns the contexts in a flexfield ordered by the creation_date
-- ========================================
PROCEDURE get_contexts(flexfield         IN  FND_DFLEX.DFLEX_R,
		       contexts          OUT FND_DFLEX.CONTEXTS_DR)
  IS
CURSOR context_c IS
  SELECT descriptive_flex_context_code, descriptive_flex_context_name,
    description, global_flag, enabled_flag
    FROM fnd_descr_flex_contexts_vl
    WHERE application_id = flexfield.application_id
    AND descriptive_flexfield_name = flexfield.flexfield_name
    ORDER BY creation_date;

CURSOR context_c_with_hints IS
  SELECT /*+ leading(fnd_descr_flex_contexts_vl.t fnd_descr_flex_contexts_vl.b)
           use_nl(fnd_descr_flex_contexts_vl.b)
           index(fnd_descr_flex_contexts_vl.t
           FND_DESCR_FLEX_CONTEXTS_TL_U1)*/
    descriptive_flex_context_code, descriptive_flex_context_name,
    description, global_flag, enabled_flag
    FROM fnd_descr_flex_contexts_vl
    WHERE application_id = flexfield.application_id
    AND descriptive_flexfield_name = flexfield.flexfield_name
    ORDER BY creation_date;

CURSOR context_c_new IS
  SELECT descriptive_flex_context_code, descriptive_flex_context_name,
    description, global_flag, enabled_flag
    FROM fnd_descr_flex_contexts_vl
    WHERE application_id = flexfield.application_id
    AND descriptive_flexfield_name = flexfield.flexfield_name
    ORDER BY creation_date, descriptive_flex_context_code ;

i BINARY_INTEGER := 0;
rv FND_DFLEX.CONTEXTS_DR;

BEGIN
   rv.global_context := 0;
   -- Bug 6819715
   IF  BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints = '9.2' THEN
      FOR context_rec IN context_c_with_hints LOOP
         i := i + 1;
         rv.context_code(i) := context_rec.descriptive_flex_context_code;
         rv.context_name(i) := context_rec.descriptive_flex_context_name;
         rv.context_description(i) := context_rec.description;
         rv.is_global(i) := to_boolean(context_rec.global_flag);
         rv.is_enabled(i) := to_boolean(context_rec.enabled_flag);
         IF(rv.is_global(i) AND rv.is_enabled(i)) THEN
            rv.global_context := i;
         END IF;
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context code is '||rv.context_code(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context name is '||rv.context_name(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context description is '||rv.context_description(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'is_enabled is '||context_rec.enabled_flag);
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'is global is '||context_rec.global_flag);
         end if;
      END LOOP;
   ELSIF BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints = '9i' THEN
      FOR context_rec IN context_c LOOP
         i := i + 1;
         rv.context_code(i) := context_rec.descriptive_flex_context_code;
         rv.context_name(i) := context_rec.descriptive_flex_context_name;
         rv.context_description(i) := context_rec.description;
         rv.is_global(i) := to_boolean(context_rec.global_flag);
         rv.is_enabled(i) := to_boolean(context_rec.enabled_flag);
         IF(rv.is_global(i) AND rv.is_enabled(i)) THEN
            rv.global_context := i;
         END IF;
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context code is '||rv.context_code(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context name is '||rv.context_name(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context description is '||rv.context_description(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'is_enabled is '||context_rec.enabled_flag);
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'is global is '||context_rec.global_flag);
         end if;
      END LOOP;
    ELSIF BIS_VIEW_GENERATOR_PVT.g_use_optimizer_hints = 'NEW' THEN
      FOR context_rec IN context_c_new LOOP
         i := i + 1;
         rv.context_code(i) := context_rec.descriptive_flex_context_code;
         rv.context_name(i) := context_rec.descriptive_flex_context_name;
         rv.context_description(i) := context_rec.description;
         rv.is_global(i) := to_boolean(context_rec.global_flag);
         rv.is_enabled(i) := to_boolean(context_rec.enabled_flag);
         IF(rv.is_global(i) AND rv.is_enabled(i)) THEN
            rv.global_context := i;
         END IF;
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context code is '||rv.context_code(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context name is '||rv.context_name(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'context description is '||rv.context_description(i));
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'is_enabled is '||context_rec.enabled_flag);
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.BIS_VG_DESC_FLEX.GET_CONTENTS',
                       'is global is '||context_rec.global_flag);
         end if;
      END LOOP;
   END IF;
   rv.ncontexts := i;
   contexts := rv;
END;



--
-- =============================================================================
-- PROCEDURE : parse_DF_Column_Line
-- PARAMETERS: 1. p_View_Column_Table   table of varchars to hold columns of
--                                      view text
--             2. p_Column_Pointer      pointer to the key flex column in
--                                      column table (IN)
--             3. x_Column_Pointer      pointer to the char after the
--                                      delimiter in
--                                      column table (OUT)
--             4. x_prefix              prefix of descriptive flexfield, if any
--             5. x_return_status    error or normal
--             6. x_error_Tbl        table of error messages
-- COMMENT   : Call this procedure to parse the KF view column tag.
-- ---
--=============================================================================
PROCEDURE parse_DF_Column_Line
( p_View_Column_Table   IN  bis_vg_types.View_Text_Table_Type
, p_Column_Pointer      IN  bis_vg_types.View_Character_Pointer_Type
, x_Column_Pointer      OUT bis_vg_types.View_Character_Pointer_Type
, x_EDW_flag            OUT BOOLEAN   --EDW flag change
, x_prefix              OUT VARCHAR2
, x_decode              OUT BOOLEAN
, x_return_status     OUT VARCHAR2
, x_error_Tbl         OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_token               VARCHAR2(100);
l_string              bis_vg_types.view_text_table_rec_type;
l_pos                 NUMBER;
--
BEGIN

  bis_debug_pub.Add('> parse_DF_Column_Line');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --   get row of text from table
  l_string := bis_vg_util.get_row ( p_View_Column_Table
                                  , p_Column_Pointer
				  , x_return_status
				  , x_error_Tbl
				  );

--   get "_DF"
  x_EDW_flag := FALSE;    --EDW flag change
  l_token := bis_vg_parser.get_string_token
                             ( l_string
                             , 1
                             , ':'
                             , l_pos
			     , x_return_status
			     , x_error_Tbl
                             );
  bis_debug_pub.Add('l_token = ' || l_token);

  IF(l_pos IS NOT NULL) THEN --- first real token exists
     --     get next token, if any
     x_prefix := bis_vg_parser.get_string_token
       ( l_string
	 , l_pos
	 , ':'
	 , l_pos
	 , x_return_status
	 , x_error_Tbl
	 );

     bis_debug_pub.Add('x_prefix = ' || x_prefix);

     --EDW flag change

     IF(upper(substr(x_prefix, 1, 4)) = '_EDW')
	--- '_EDW' in forst position
       THEN
        bis_vg_util.add_message
	  ( DFX_COL_TAG_EXP_BAD_FLAG_MSG
          , FND_MSG_PUB.G_MSG_LVL_ERROR
          , 'MESSAGE_TAG'
          , l_string
	  , x_return_status
	  , x_error_Tbl
          );
        --
        RAISE MALFORMED_DFX_COL_TAG_BAD_FLAG;
        --
     END IF; --- '_EDW' in first position

     IF(l_pos IS NOT NULL) --- Second token exists
       THEN
        l_token := bis_vg_parser.get_string_token
        ( l_string
          , l_pos
          , ':'
          , l_pos
	  , x_return_status
	  , x_error_Tbl
          );

        bis_debug_pub.Add('l_token = ' || l_token);


	IF( UPPER(l_token) = '_EDW' )
	  THEN
	   x_EDW_flag := TRUE;
	   bis_debug_pub.Add('x_EDW_flag = TRUE');
	 ELSIF (UPPER(l_token) = '_BS' ) THEN
	   x_decode := TRUE;
	   bis_debug_pub.Add('x_decode = TRUE');
	 ELSE --- second token is not a valid flag
	   bis_vg_util.add_message
	     ( DFX_COL_TAG_EXP_BAD_FLAG_MSG
	       , FND_MSG_PUB.G_MSG_LVL_ERROR
	       , 'MESSAGE_TAG'
	       , l_string
	       , x_return_status
	       , x_error_Tbl
	       );
           RAISE MALFORMED_DFX_COL_TAG_BAD_FLAG;
        END IF; --- ( UPPER(l_token) = '_EDW' )

	if (l_pos IS NOT NULL) THEN --- third token exists
	   l_token := bis_vg_parser.get_string_token
	     ( l_string
	       , l_pos
	       , ':'
	       , l_pos
	       , x_return_status
	       , x_error_Tbl
	       );
	   if ((upper(l_token) = '_BS') AND (x_decode = FALSE))
	     then
	      x_decode := TRUE;
	    elsif (( upper(l_token) = '_EDW')  AND (x_EDW_flag = FALSE))
	      then
	      x_EDW_flag := TRUE;
	      bis_debug_pub.Add('x_EDW_flag = TRUE');
	    else --- Third token is not a valid flag
	      bis_vg_util.add_message
		( DFX_COL_TAG_EXP_BAD_FLAG_MSG
		  , FND_MSG_PUB.G_MSG_LVL_ERROR
		  , 'MESSAGE_TAG'
		  , l_string
		  , x_return_status
		  , x_error_Tbl
		  );
	      RAISE MALFORMED_DFX_COL_TAG_BAD_FLAG;

	   end if; --- third token = _BS or _EDW
	end if;  --- third token exists
      ELSE --- second token does not exist (only one token)
	if (x_prefix = '_BS') --- first and only token is '_BS'
	  THEN
	   x_decode := TRUE;
	   x_prefix := NULL;
	END IF; --- first and only token is '_BS'
     END IF; --- Second token exists
  END IF; --- first token exists



  x_Column_Pointer := bis_vg_util.increment_pointer_by_row
                                    ( p_View_Column_Table
                                    , p_Column_Pointer
				    , x_return_status
				    , x_error_Tbl
                                    );
  bis_debug_pub.Add('< parse_DF_Column_Line');
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
	  , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Column_Line'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END parse_DF_Column_Line;
--
-- ============================================================================
-- FUNCTION: CHECK_APPLICATION_VALIDITY  (PRIVATE FUNCTION)
-- RETURNS: boolean - true if application short name p[assed is defined
--  1. p_app  short name of application
--
-- COMMENT  : Checks against the FND_APPLICATION_ALL_VIEW.
--            Called from parse_DF_Select_Line.
-- ---
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
-- PROCEDURE : parse_DF_Select_Line
-- PARAMETERS: 1. p_View_Select_Table table of varchars to hold select clause
--                                    of view text
--             2. p_Select_Pointer    pointer to the key flex column in select
--                                    table (IN)
--             3. x_Select_Pointer    pointer to the char after the delimiter in
--                                    select table (OUT)
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
)
IS
--
   l_whole_tag           VARCHAR2(2000);
   l_tmp_pointer          bis_vg_types.View_Character_Pointer_Type;
--
BEGIN
  bis_debug_pub.Add('> parse_DF_Select_Line');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --   get '_DF'
  l_whole_tag := bis_vg_parser.get_token_increment_pointer
                            ( p_View_Select_Table
                            , p_Select_Pointer
                            , ':'''
                            , x_Select_Pointer
			    , x_return_status
			    , x_error_Tbl
			      );
  --Parse the whole tag for error messages
  l_whole_tag := bis_vg_parser.get_expression( p_View_Select_Table
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


    IF bis_vg_util.equal_pointers(
				l_tmp_pointer
				, x_select_pointer
				, x_return_status
				, x_error_Tbl
				)
    THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_desc_flex.DFX_SEL_TAG_EXP_NO_APP_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Select_Line'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1        => 'tag'
	 , p_value1        => l_whole_tag
	 , p_error_table       => x_error_tbl
	 , x_error_table       => x_error_tbl
	 );
     bis_vg_log.update_failure_log( x_error_tbl
				    , x_return_status
				    , x_error_Tbl
				    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_Application_Name := bis_vg_parser.get_token_increment_pointer
                            ( p_View_Select_Table
                            , x_Select_Pointer
                            , ':'''
                            , x_Select_Pointer
			    , x_return_status
			    , x_error_Tbl
                            );

  IF (x_Application_Name IS NULL
      OR
      bis_vg_util.equal_pointers(
				 l_tmp_pointer
				 , x_select_pointer
				 , x_return_status
				 , x_error_Tbl
				 )

      ) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_desc_flex.DFX_SEL_TAG_EXP_NO_APP_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Select_Line'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1        => 'tag'
	 , p_value1        => l_whole_tag
	 , p_error_table       => x_error_tbl
	 , x_error_table       => x_error_tbl
	 );
     bis_vg_log.update_failure_log( x_error_tbl
				    , x_return_status
				    , x_error_Tbl
				    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

--EDW flag change

  IF (x_Application_Name = '_DUMMY') THEN
     x_DUMMY_flag := TRUE;

      x_Application_Name:= bis_vg_parser.get_token_increment_pointer
       ( p_View_Select_Table
         , x_Select_Pointer
         , ':'
         , x_Select_Pointer
	 , x_return_status
	 , x_error_Tbl
         );

  END IF;
--EDW flag change

  bis_debug_pub.Add('x_Application_Name = ' || x_Application_Name);
  x_Desc_Flex_Name := bis_vg_parser.get_token_increment_pointer
                                     ( p_View_Select_Table
                                     , x_Select_Pointer
                                     , ':'''
                                     , x_Select_Pointer
				     , x_return_status
				     , x_error_Tbl
                                     );

  IF (x_desc_flex_name IS NULL
            OR
      bis_vg_util.equal_pointers(
				 l_tmp_pointer
				 , x_select_pointer
				 , x_return_status
				 , x_error_Tbl
				 )

      ) THEN

     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_desc_flex.DFX_SEL_TAG_EXP_NO_NAME_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Select_Line'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1        => 'tag'
	 , p_value1        => l_whole_tag
	 , p_error_table       => x_error_tbl
	 , x_error_table       => x_error_tbl
	 );
     bis_vg_log.update_failure_log( x_error_tbl
				    , x_return_status
				    , x_error_Tbl
				    );
     RAISE FND_API.G_EXC_ERROR;

  END IF;

  bis_debug_pub.Add('x_Desc_Flex_Name = ' || x_Desc_Flex_Name);
  x_Table_Alias := bis_vg_parser.get_token
                                  ( p_View_Select_Table
                                  , x_Select_Pointer
                                  , ':'''
                                  , x_Select_Pointer
				  , x_return_status
	        		  , x_error_Tbl
                                  );
  bis_debug_pub.Add('x_Table_Alias = ' || x_Table_Alias);


  IF (x_table_alias IS NULL
            OR
      bis_vg_util.equal_pointers(
				 l_tmp_pointer
				 , x_select_pointer
				 , x_return_status
				 , x_error_Tbl
				 )

      ) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_desc_flex.DFX_SEL_TAG_EXP_NO_TABLE_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Select_Line'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1        => 'tag'
	 , p_value1        => l_whole_tag
	 , p_error_table       => x_error_tbl
	 , x_error_table       => x_error_tbl
	 );
     bis_vg_log.update_failure_log( x_error_tbl
				    , x_return_status
				    , x_error_Tbl
				    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF check_application_validity(x_Application_Name)
    THEN
-- EVERYTHING IS FINE
     x_Select_Pointer := bis_vg_util.increment_pointer( p_View_Select_Table
                                                   , x_Select_Pointer
						   , x_return_status
						   , x_error_Tbl
                                                   );
     bis_debug_pub.Add('< parse_DF_Select_Line');
   ELSE
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_desc_flex.DFX_SEL_TAG_EXP_INVALID_APP
	 , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Select_Line'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1        => 'tag'
	 , p_value1        => l_whole_tag
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

  --
EXCEPTION
   when
    FND_API.G_EXC_ERROR then
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
	  , p_error_proc_name   => G_PKG_NAME||'.parse_DF_Select_Line'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END parse_DF_Select_Line;
--
-- =============================================================================
-- PROCEDURE : add_desc_flexfield_segments
-- PARAMETERS: 1. p_nContexts_flag is TRUE if only 1 context has been defined
--             2. p_Flexfield       desc flexfield dflex_r variable
--             3. p_Flexinfo        desc flexfield dflex_dr variable
--             4. p_Context_Code    context of the context of the desc flexfield
--             5. p_Context_Num     number of the context of the desc flexfield
--             6. p_Prefix          Desc Flexfield Name
--             7. p_Table_Alias     Table alias
--             8. x_Select_Table    table of varchars to hold select clause of
--                                  view text
--             9. x_Column_Comment_Table  table to hold flex info
--
--            10. x_Column_Table    table of varchars to hold select clause of
--                                  view text
--            11. p_attr_categ_flag flag to indicate if ATTRIBUTE_CATEGORY is
--                                  to be added
--            12. x_attr_categ_flag updated flag to indicate if
--                                  ATTRIBUTE_CATEGORY is to be added
--            13. x_return_status    error or normal
--            14. x_error_Tbl        table of error messages
--	      15. p_schema           schema name  -- schema name
-- COMMENT   : Call this procedure to add the segments for desc flexfields.
-- ---
-- ============================================================================
PROCEDURE add_desc_flexfield_segments
( p_nContexts_flag        IN  BOOLEAN
, p_Flexfield             IN  FND_DFLEX.DFLEX_R
, p_Flexinfo              IN  FND_DFLEX.DFLEX_DR
, p_Context_Code          IN
                           FND_DESCR_FLEX_CONTEXTS.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE
, p_Context_Num           IN  NUMBER
, p_Prefix                IN  VARCHAR2
, p_decode                IN  BOOLEAN
, p_Table_Alias           IN  VARCHAR2
, p_EDW_Flag              IN  BOOLEAN   --EDW flag change
, p_DUMMY_Flag            IN  BOOLEAN   --EDW flag change
, x_Column_Table          OUT bis_vg_types.View_Text_Table_Type
, x_Select_Table          OUT bis_vg_types.View_Text_Table_Type
, x_Column_Comment_Table  OUT bis_vg_types.Flex_Column_Comment_Table_Type
, p_attr_categ_flag       IN  BOOLEAN
, x_attr_categ_flag       OUT BOOLEAN
, x_return_status         OUT VARCHAR2
, x_error_Tbl             OUT BIS_VG_UTIL.Error_Tbl_Type
, p_schema                IN  VARCHAR2  --schema name
)
IS
--
l_segments          FND_DFLEX.SEGMENTS_DR;
--
l_prefix            VARCHAR(100);
l_count             NUMBER;
l_context_code      VARCHAR2(100) := NULL;
l_col_data_type     varchar2(106) :=null;
type CurType is ref cursor;
cv CurType;
--
BEGIN
  bis_debug_pub.Add('> add_desc_flexfield_segments');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_Prefix IS NOT NULL) THEN
    l_prefix := p_Prefix || '_';
  END IF;

  bis_debug_pub.Add('l_prefix = ' || l_prefix);

  x_attr_categ_flag := p_attr_categ_flag;
  IF(p_Context_Code IS NOT NULL AND p_nContexts_flag = FALSE) THEN
--       l_context_code := '^' || p_Context_Code;
    l_context_code := '^' || TO_CHAR(p_Context_Num);
  END IF;
--
  FND_DFLEX.GET_SEGMENTS
             ( context      => FND_DFLEX.MAKE_CONTEXT
                                ( flexfield    => p_flexfield
                                , context_code => p_Context_Code
                                )
             , segments     => l_segments
             , enabled_only => TRUE
             );
  IF(l_segments.NSEGMENTS > 0) THEN
     IF(p_attr_categ_flag = TRUE) THEN
	---EDW flag change
	IF (p_EDW_Flag = TRUE) THEN
	   x_Column_Table(1) := l_prefix || 'context';
          x_Column_Table(1) := l_prefix || 'context';
          x_Column_Comment_Table(1).column_name:= x_Column_Table(1);
          x_Column_Comment_Table(1).flex_type := 'DESC CONTEXT';
          --populate comments with application id, flex name, context code
          x_Column_Comment_Table(1).column_comments :=p_flexfield.application_id||','||
                                                      p_flexfield.flexfield_name||','||
                                                      p_context_code;

	 ELSE
	   x_Column_Table(1) := l_prefix
	     || p_Flexinfo.form_context_prompt;
	  x_Column_Comment_Table(1).column_name:= x_Column_Table(1);
          x_Column_Comment_Table(1).flex_type := 'DESC CONTEXT';
          --populate comments with application id, flex name, context code
          x_Column_Comment_Table(1).column_comments :=p_flexfield.application_id||','||
                                                      p_flexfield.flexfield_name||','||
                                                      p_context_code;
	 END IF;
	---EDW flag change

	bis_debug_pub.Add('x_Column_Table(1) = ' || x_Column_Table(1));

	--      x_Select_Table(1) := '  ' || p_Table_Alias || '.'
	--                                || p_Flexinfo.context_column_name;
	--EDW flag change
	IF p_DUMMY_flag
	  THEN
	   x_Select_Table(1) :=  'TO_CHAR(NULL)';
	 ELSE
	   x_Select_Table(1) := '  '  || p_Table_Alias ||
	     '.' || p_Flexinfo.context_column_name;
	END IF;
	--EDW flag change

	x_attr_categ_flag := FALSE;
     END IF;
     l_count := x_Column_Table.COUNT + 1;
     FOR j IN 1 .. l_segments.NSEGMENTS LOOP
	--
	x_Column_Table(l_count) := l_prefix
                                 || l_segments.SEGMENT_NAME(j)
                                 || l_context_code;
      x_Column_Comment_Table(l_count).column_name:= x_Column_Table(l_count);
      x_Column_Comment_Table(l_count).flex_type := 'DESC SEGMENT';
      --populate comments with application id, flex name, context code, application column
      x_Column_Comment_Table(l_count).column_comments :=p_flexfield.application_id||','||
                                                        p_flexfield.flexfield_name||','||
                                                        p_context_code||','||
                                                        l_segments.APPLICATION_COLUMN_NAME(j);
      bis_debug_pub.Add('x_Column_Table('|| l_count||') = '
                        || x_Column_Table(l_count));
      IF (p_decode = TRUE) THEN
        x_Select_Table(l_count) := ', '
                                || 'DECODE( '
                                ||p_flexinfo.context_column_name
                                || ', '
                                || ''''
                                ||p_context_code
                                ||''''
                                || ','
                                || p_Table_Alias
                                || '.'
                                || l_segments.APPLICATION_COLUMN_NAME(j)
                                || ', NULL'
                                || ')';
      ELSE
--EDW flag change
	 IF p_DUMMY_flag
	   THEN
	    if l_segments.APPLICATION_COLUMN_NAME(j) not like 'ATTRIBUTE%' then
         --use schema
	   open cv for
             select DATA_TYPE
             from  all_tab_columns
             where table_name = p_flexinfo.table_name
               and column_name=l_segments.APPLICATION_COLUMN_NAME(j)
	       and owner =p_schema;

             fetch cv into l_col_data_type;
             close cv;
	   if l_col_data_type like 'NUMBER%'
	       THEN
		x_Select_Table(l_count) := ', TO_NUMBER(NULL)';
	      ELSIF l_col_data_type like 'DATE%' THEN
		x_Select_Table(l_count) := ', TO_DATE(NULL)';
	      ELSE
		x_Select_Table(l_count) := ', TO_CHAR(NULL)';
             end if;
	     ELSE
	       x_Select_Table(l_count) := ', TO_CHAR(NULL)';
	    end if;
	  ELSE
	    x_Select_Table(l_count) := ', ' || p_Table_Alias || '.'
	      || l_segments.APPLICATION_COLUMN_NAME(j);
      END IF;
--EDW flag change
      END IF;
      bis_debug_pub.Add('x_Select_Table('|| l_count||') = ' || x_Select_Table(l_count));
--
      l_count := l_count + 1;
    END LOOP;
  END IF;
  bis_debug_pub.Add('< add_desc_flexfield_segments');
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
	  , p_error_proc_name   => G_PKG_NAME||'.add_desc_flexfield_segments'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_desc_flexfield_segments;
--
-- =============================================================================
-- PROCEDURE : update_Desc_Flex_Tables
-- PARAMETERS:
--             1. p_EDW_Flag            flag to add context column
--             2. p_dummy_flag          flag to indicate a flexfield
--                                      which is not valid in this branch
--                                      of a union, hence filled with
--                                      NULLs to keep number of columns.
--             3. p_Prefix              prefix for segments
--             4. p_decode              flag to indicate if select
--                                      statement should contain a decode
--                                      or always fetch data even when
--                                      meaningless
--             5. p_column_table        PLSQL table of columns to prune by
--                                      if present, else expand all.
--             6. p_Application_Name    Application Name
--             7. p_Desc_Flex_Name      Desc Flexfield Name
--             8. p_Table_Alias         Table alias
--             9. x_Column_Table        table of varchars to hold
--                                      view columns
--            10. x_Select_Table        table of varchars to hold select
--                                      clause of view text
--            10. x_Select_Table        table of varchars to hold select
--                                      clause of view text
--            11. x_Column_Comment_Table table to hold flex info as it is gathered
--            12. x_return_status    error or normal (not used)
--            13. x_error_Tbl        table of error messages

-- COMMENT   : Call this procedure to build the column and select tables
--                                    for desc flexfields.
-- ---
-- =============================================================================
PROCEDURE update_Desc_Flex_Tables
( p_EDW_Flag               IN  BOOLEAN    --EDW flag change
, p_DUMMY_Flag             IN  BOOLEAN    --EDW flag change
, p_Prefix                 IN  VARCHAR2
, p_decode                 IN  BOOLEAN
, p_column_table           IN  BIS_VG_TYPES.flexfield_column_table_type
, p_Application_Name       IN  VARCHAR2
, p_Desc_Flex_Name         IN  VARCHAR2
, p_Table_Alias            IN  VARCHAR2
, x_Column_Table           OUT bis_vg_types.View_Text_Table_Type
, x_Select_Table           OUT bis_vg_types.View_Text_Table_Type
, x_Column_Comment_Table   OUT bis_vg_types.Flex_Column_Comment_Table_Type
, x_return_status          OUT VARCHAR2
, x_error_Tbl              OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
i                   NUMBER;
l_flexfield         FND_DFLEX.DFLEX_R;
l_flexinfo          FND_DFLEX.DFLEX_DR;
l_contexts          FND_DFLEX.CONTEXTS_DR;
l_segments          FND_DFLEX.SEGMENTS_DR;
--
l_ATT_CATEGORY_flag BOOLEAN := TRUE;
l_nContexts_flag    BOOLEAN;
l_count             NUMBER := 0;
l_Column_Table bis_vg_types.View_Text_Table_Type;
l_Select_Table bis_vg_types.View_Text_Table_Type;
l_Column_Comment_Table bis_vg_types.Flex_Column_Comment_Table_Type;
---

--to get schema name
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_schema varchar2(400);

BEGIN
---   bis_debug_pub.debug_on;
   bis_debug_pub.Add('> update_Desc_Flex_Tables');

 --get schema name
  if FND_INSTALLATION.GET_APP_INFO(p_Application_Name,l_dummy1, l_dummy2,l_schema) = false then
	   bis_debug_pub.Add('FND_INSTALLATION.GET_APP_INFO returned with error');
  end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FND_DFLEX.GET_FLEXFIELD( appl_short_name => p_Application_Name
			    , flexfield_name  => p_Desc_Flex_Name
			    , flexfield       => l_flexfield
			    , flexinfo        => l_flexinfo
			    );
   bis_debug_pub.Add('l_flexfield.FLEXFIELD_NAME = '
		     || l_flexfield.FLEXFIELD_NAME);
   bis_debug_pub.Add('l_flexinfo.TITLE = ' || l_flexinfo.TITLE);
   IF p_column_table IS NULL
    --- regular BVG behavior (not pruned)
    THEN
     GET_CONTEXTS
       ( flexfield => l_flexfield
	 , contexts  => l_contexts
	 );
     bis_debug_pub.Add('l_contexts.NCONTEXTS = ' || l_contexts.NCONTEXTS);
     -- set l_nContexts_flag if only one context or only one enabled context
     IF(l_contexts.NCONTEXTS = 1) THEN
	l_nContexts_flag := TRUE;
      ELSE
	FOR i IN 1 .. l_contexts.NCONTEXTS LOOP
	   IF( l_contexts.IS_ENABLED(i) ) THEN
	      l_count := l_count + 1;
	   END IF;
	END LOOP;
	IF(l_count > 1) THEN
	   l_nContexts_flag := FALSE;
	 ELSE
	   if (p_edw_flag = TRUE ) THEN
	      l_nContexts_flag := FALSE;
	    else
	      l_nContexts_flag := TRUE;
	   end if;
	END IF;
     END IF;
     --
     l_count:=1;
     FOR i IN 1 .. l_contexts.NCONTEXTS LOOP
	IF( l_contexts.IS_ENABLED(i) ) THEN
	   --EDW flag change
	   IF (p_EDW_Flag = TRUE)
	     THEN
	      l_count := i+1;
	    ELSE
          l_count := i;
	   END IF;
	   --EDW flag change
	   add_desc_flexfield_segments( l_nContexts_flag
					, l_flexfield
					, l_flexinfo
					, l_contexts.CONTEXT_CODE(i)
					, l_count
					, p_Prefix
					, p_decode
					, p_Table_Alias
					, p_EDW_flag
					, p_DUMMY_flag
					, l_Column_Table
					, l_Select_Table
					, l_Column_Comment_Table
					, l_ATT_CATEGORY_flag
					, l_ATT_CATEGORY_flag
					, x_return_status
					, x_error_Tbl
					,l_schema --pass schema name

					);

	   --- Append the latest context's segments to the list
	   bis_vg_util.concatenate_Tables( x_Column_Table
					   , l_Column_Table
					   , x_Column_Table
					   , x_return_status
					   , x_error_Tbl
					   );
	   bis_vg_util.concatenate_Tables( x_Select_Table
                                    , l_Select_Table
                                    , x_Select_Table
    				    , x_return_status
				    , x_error_Tbl
                                    );
           bis_vg_util.concatenate_Tables( x_Column_Comment_Table
                                           , l_Column_Comment_Table
                                           , x_Column_Comment_Table
                                           , x_return_status
					   , x_error_Tbl
					   );
	END IF; --- Context enabled
     END LOOP;
   ELSE
     --- The pruned case - no need for concatenated segments column.
     l_count := 1;
     i := p_column_table.first;
     WHILE i <= p_column_table.last
       LOOP
	  IF ( p_column_table(i).flex_field_type = 'D'
	       AND p_column_table(i).id_flex_code =  p_desc_flex_name)
	    THEN
	     l_count := l_count+1;
	     bis_debug_pub.ADD ('Processing p_column_table(i).segment_name = '
				|| p_column_table(i).segment_name);
	     bis_debug_pub.ADD ('and  p_column_table(i).structure_num = '
				|| p_column_table(i).structure_num);
	     bis_debug_pub.ADD ('and  p_column_table(i).application_column_name = '
				|| p_column_table(i).application_column_name);
	     x_column_table(l_count):= p_Prefix
	       || '_' || p_column_table(i).segment_name;

	     IF (p_column_table(i).structure_num > 0)
	       THEN
		x_column_table(l_count):= x_column_table(l_count)
		  ||'^'  ||p_column_table(i).structure_num;
	     END IF;

	     IF p_dummy_flag OR p_column_table(i).application_column_name IS NULL
	       THEN
		IF p_column_table(i).segment_datatype = 'N'
		  THEN
		   x_select_table(l_count) := ', TO_NUMBER(NULL)';
		 ELSIF p_column_table(i).segment_datatype IN ('D','X')
		   THEN
		   x_select_table(l_count) := ', TO_DATE(NULL)';
		 ELSE
		   x_select_table(l_count) := ', TO_CHAR(NULL)';
		END IF;
	      ELSE
		   x_select_table(l_count)
		  := ' , ' || p_Table_Alias || '.'
		  || p_column_table(i).application_column_name;
	     END IF;  --- dummy_flag

	  END IF; --- p_column_table(i) matches criteria
	  i := p_column_table.next(i);
       END LOOP;  --- to enumerate p_column_table

       IF l_count > 1
	 THEN
	  x_Column_Table(1) := p_prefix || '_context';
	  bis_debug_pub.ADD ('l_Flexinfo.context_column_name = '
			     || l_Flexinfo.context_column_name);
	  IF p_dummy_flag OR l_Flexinfo.context_column_name IS NULL
	    THEN
	     x_Select_Table(1) :=  'NULL';
	   ELSE
	     x_Select_Table(1) := '  '
	       || p_Table_Alias
	       || '.' || l_Flexinfo.context_column_name;
	  END IF;

       END IF;

  END IF; --- Prune or no prune
--- DEBUG
  bis_vg_util.print_View_Text
                            ( x_Column_Table
                            , x_return_status
                            , x_error_Tbl
			      );
  bis_debug_pub.Add('< update_Desc_Flex_Tables');
---  bis_debug_pub.debug_off;
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
	  , p_error_proc_name   => G_PKG_NAME||'.update_Desc_Flex_Tables'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END update_Desc_Flex_Tables;
--
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
---           10 x_Column_Comment_Table table to hold info info as it is gathered.
---           11. x_Column_Pointer     pointer to the character after the
---                                    delimiter
---                                    (column table)
---           12. x_Select_Pointer     pointer to the character after the
---                                    delimiter
---                                    (select table)
---           14. x_return_status    error or normal
---           15. x_error_Tbl        table of error messages
---
---   COMMENT   : Call this procedure to add a particular desc flexfield
---               information to a view.
---   ---
---  ==========================================================================

PROCEDURE add_Desc_Flex_Info
( p_View_Column_Table      IN  BIS_VG_TYPES.View_Text_Table_Type
, p_View_Select_Table      IN  BIS_VG_TYPES.View_Text_Table_Type
, p_Mode                   IN  NUMBER
, p_column_table           IN  BIS_VG_TYPES.flexfield_column_table_type
, p_Column_Pointer         IN  BIS_VG_TYPES.View_Character_Pointer_Type
, p_Select_Pointer         IN  bis_vg_types.View_Character_Pointer_Type
, p_From_Pointer           IN  bis_vg_types.View_Character_Pointer_Type
, x_Column_Table           OUT bis_vg_types.View_Text_Table_Type
, x_Select_Table           OUT bis_vg_types.View_Text_Table_Type
, x_Column_Comment_Table   OUT BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, x_Column_Pointer         OUT bis_vg_types.View_Character_Pointer_Type
, x_Select_Pointer         OUT bis_vg_types.View_Character_Pointer_Type
, x_return_status          OUT VARCHAR2
, x_error_Tbl              OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_Prefix           VARCHAR2(100);
--
l_Application_Name VARCHAR2(10);
l_Desc_Flex_Name   VARCHAR2(100);
l_Table_Alias      VARCHAR2(100);
l_Table_Name       VARCHAR2(100);
--
l_decode           BOOLEAN;
l_EDW_Flag         BOOLEAN;    --EDW flag change
l_DUMMY_Flag       BOOLEAN;    --EDW flag change
BEGIN
   bis_debug_pub.Add('> add_Desc_Flex_Info');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  parse_DF_Column_Line( p_View_Column_Table
                      , p_Column_Pointer
                      , x_Column_Pointer
		      , l_EDW_Flag     --EDW flag change
                      , l_Prefix
                      , l_decode
		      , x_return_status
		      , x_error_Tbl
			);

  bis_debug_pub.Add('l_Prefix =  ' || l_Prefix);

  --- This clause catches flexfield tags that do not have the
  --- _EDW tags when the generator is called via generate_pruned_view
  IF (p_column_table IS NOT NULL AND l_edw_flag = FALSE )
    THEN
     RAISE bis_view_generator_pvt.CANNOT_PRUNE_NON_EDW_VIEW;
  END IF;


  parse_DF_Select_Line( p_View_Select_Table
                      , p_Select_Pointer
                      , x_Select_Pointer
                      , l_Application_Name
                      , l_Desc_Flex_Name
                      , l_Table_Alias
		      , l_DUMMY_Flag     --EDW flag change
		      , x_return_status
		      , x_error_Tbl
                      );
  bis_debug_pub.Add('l_Application_Name =  ' || l_Application_Name);
  bis_debug_pub.Add('l_Desc_Flex_Name =  ' || l_Desc_Flex_Name);
  bis_debug_pub.Add('l_Table_Alias =  ' || l_Table_Alias);
  bis_debug_pub.Add('l_Prefix =  ' || l_Prefix);

  IF(
     (p_Mode <> bis_vg_types.remove_tags_mode)
     AND
     (p_column_table IS NULL
      OR
      p_column_table.COUNT > 0)
     )

    THEN
---    x_Column_Table(1) := 'DESCRIPTIVE_FLEXFIELD_COLUMN';
---    x_Select_Table(1) := 'TO_CHAR(NULL)';
---  ELSE

    update_Desc_Flex_Tables( l_EDW_Flag      --EDW flag change
			   , l_DUMMY_Flag    --EDW flag change
			   , l_Prefix
                           , l_decode
			   , p_column_table
                           , l_Application_Name
                           , l_Desc_Flex_Name
                           , l_Table_Alias
                           , x_Column_Table
                           , x_Select_Table
                           , x_Column_Comment_Table
			   , x_return_status
			   , x_error_Tbl
                           );
  END IF;
  bis_vg_util.print_View_Text(x_Column_Table, x_return_status, x_error_Tbl);
  bis_vg_util.print_View_Text(x_Select_Table, x_return_status, x_error_Tbl);
  bis_debug_pub.Add('COLUMN POINTER');
  bis_vg_util.print_View_Pointer ( x_Column_Pointer
  				 , x_return_status
				 , x_error_Tbl
				 );
  bis_debug_pub.Add('SELECT POINTER');
  bis_vg_util.print_View_Pointer ( x_Select_Pointer
  				 , x_return_status
				 , x_error_Tbl
				 );
  bis_debug_pub.Add('< add_Desc_Flex_Info');

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
	  , p_error_proc_name   => G_PKG_NAME||'.add_Desc_Flex_Info'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END add_Desc_Flex_Info;
--
--
END bis_vg_desc_flex;

/
