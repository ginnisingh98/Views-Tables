--------------------------------------------------------
--  DDL for Package Body BIS_VG_REPOSITORY_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_REPOSITORY_MEDIATOR" AS
/* $Header: BISTRPMB.pls 115.18 2002/08/20 14:36:52 dbowles ship $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTRPMB.pls
--
--  DESCRIPTION
--
--      specification of package which mediates with the repository
--
--  NOTES
--
--  HISTORY
--
--  29-JUL-98 Created
--  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
--
G_PKG_NAME CONSTANT VARCHAR(30) := 'bis_VG_repository_mediator';
--============================================================================
-- variables for the String generator
--============================================================================
  g_cursor       INTEGER;
  g_current_posn INTEGER;
--
-- ============================================================================
-- PROCEDURE : String_Generator_Init
-- PARAMETERS: 1. p_View_Name   View name
--             2. x_return_status    error or normal (obsolete)
--             3. x_error_Tbl        table of error messages
--
-- COMMENT   : Call this procedure to initialize the string generator
--             the runtime repository.
-- EXCEPTION : None
-- ===========================================================================
   PROCEDURE string_generator_init
   ( p_view_name IN BIS_VG_TYPES.view_name_type
---   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS

   l_statement      VARCHAR2(100)
                    := 'SELECT TEXT FROM USER_VIEWS WHERE VIEW_NAME = ';
   l_dummy          NUMBER;
--
   BEGIN

     BIS_DEBUG_PUB.Add('> init_string_generator');
---     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_statement := l_statement || '''' || p_View_Name || '''';
     g_cursor := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(g_cursor, l_statement, DBMS_SQL.NATIVE);
     DBMS_SQL.DEFINE_COLUMN_LONG(g_cursor, 1);
     l_dummy := DBMS_SQL.EXECUTE(g_cursor);
     l_dummy := DBMS_SQL.FETCH_ROWS(g_cursor);
     g_current_posn := 0;
     BIS_DEBUG_PUB.Add('< init_string_generator');


EXCEPTION
   when FND_API.G_EXC_ERROR then
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
      , p_error_proc_name   => G_PKG_NAME||'.string_generator_init'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END string_generator_init;

-- ============================================================================
-- PROCEDURE : String_Generator_Get_String
-- PARAMETERS: 1. p_chunk_size     chunk size to fetch
--             2. x_string         return string
--             3. x_eod            return true if end of data
--             4. x_return_status    error or normal (obsolete)
--             5. x_error_Tbl        table of error messages
--
-- COMMENT   : Call this procedure to retrieve a string of given size. It will
--             return a string which will end at a delimiter
-- EXCEPTION : None
-- ===========================================================================
PROCEDURE String_Generator_Get_String
   ( p_chunk_size  IN  INTEGER
   , x_string      OUT VARCHAR2
   , x_eod         OUT BOOLEAN
---   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
  IS
   l_dummy          VARCHAR2(1000);
   l_chunk_size_ret INTEGER;
   BEGIN
     BIS_DEBUG_PUB.Add('> String_Generator_Get_String');
---     x_return_status := FND_API.G_RET_STS_SUCCESS;
     DBMS_SQL.COLUMN_VALUE_LONG( g_cursor
                               , 1
                               , p_chunk_size
                               , g_current_posn
                               , x_string
                               , l_chunk_size_ret
                               );

     x_eod := FALSE;
     IF (l_chunk_size_ret = p_chunk_size) THEN
       -- we retrived what was required, check that we end on delimiter
       WHILE ( NOT bis_vg_util.is_char_delimiter( SUBSTR( x_string
                                                        , l_chunk_size_ret
                                                        , 1
                                                        )
						 , l_dummy
						 , x_error_Tbl
                                                 )
             ) LOOP
         l_chunk_size_ret := l_chunk_size_ret - 1;
       END LOOP;
       g_current_posn := g_current_posn + l_chunk_size_ret;
       x_string := Substr(x_string, 1, l_chunk_size_ret);
     ELSE
       x_eod := TRUE;
     END IF;
     BIS_DEBUG_PUB.Add('< String_Generator_Get_String');


EXCEPTION
   when FND_API.G_EXC_ERROR then
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
      , p_error_proc_name   => G_PKG_NAME||'.String_Generator_Get_String'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END String_Generator_Get_String;


-- ============================================================================
-- PROCEDURE : create_View_Select_Text_Table
-- PARAMETERS:
--    1. p_View_name         view name
--    2. x_View_Select_Text_Table table of varchars to hold select
--    3. x_error_Tbl        table of error messages
--                                         view text
-- COMMENT   : Call this procedure to retrieve select clause of the view from
--             the runtime repository.
-- EXCEPTION : None
-- ============================================================================
PROCEDURE create_View_Select_Text_Table
  ( p_view_name              IN  BIS_VG_TYPES.View_name_Type := null
    , x_View_Select_Text_Table OUT BIS_VG_TYPES.View_Text_Table_Type
    , x_error_Tbl              OUT BIS_VG_UTIL.Error_Tbl_Type
    )
  IS
     --
     l_eod              BOOLEAN;
     l_string           VARCHAR2(200);

BEGIN

   BIS_DEBUG_PUB.Add('> create_View_Select_Text_Table');
   ---     x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_eod := FALSE;

   string_generator_init ( p_view_name
			   ---	                   , x_return_status
			   , x_error_Tbl
			   );
   WHILE (NOT l_eod) LOOP
      string_generator_get_string( 200
				   , l_string
				   , l_eod
				   ---				  , x_return_status
				   , x_error_Tbl
				   );

      bis_debug_pub.add('l_string := ' || l_string);
      x_View_Select_Text_Table(x_View_Select_Text_Table.COUNT + 1):= l_string;

   END LOOP;

   DBMS_SQL.CLOSE_CURSOR(g_cursor);

   BIS_DEBUG_PUB.Add('< create_View_Select_Text_Table');


EXCEPTION
   when FND_API.G_EXC_ERROR then
      DBMS_SQL.CLOSE_CURSOR(g_cursor);

      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      DBMS_SQL.CLOSE_CURSOR(g_cursor);

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      DBMS_SQL.CLOSE_CURSOR(g_cursor);

      BIS_VG_UTIL.Add_Error_Message
	( p_error_msg_id      => SQLCODE
	  , p_error_description => SQLERRM
	  , p_error_proc_name   => G_PKG_NAME||'.create_View_Select_Text_Table'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END create_View_Select_Text_Table;
   ---
--- ============================================================================
--- PROCEDURE : create_View_Text_Tables
--- PARAMETERS: 1. p_View_name             view name
---             2. x_View_Create_Text_Table table of varchars to hold create
---                                         view text
---             3. x_View_Select_Text_Table table of varchars to hold select
---                                            view
---             4. x_error_Tbl        table of error messages
---                                         text
--- COMMENT   : Call this procedure to retrieve the view text from the runtime
---             repository.
--- EXCEPTION : None
--- ============================================================================
PROCEDURE create_View_Text_Tables
   ( p_view_name              IN  BIS_VG_TYPES.View_name_type := null
   , x_View_Column_Text_Table OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_View_Select_Text_Table OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_error_Tbl              OUT BIS_VG_UTIL.Error_Tbl_Type
   )
  IS
     l_count           NUMBER;
     l_done            BOOLEAN;
     l_text_count      NUMBER;
     l_start           NUMBER;
     l_ViewText        LONG;
     l_str             VARCHAR2(255);
     l_pos             NUMBER;
     l_char            VARCHAR2(1);
     --
     CURSOR c_all_columns IS
	select COLUMN_NAME
	  from user_tab_columns
	  where TABLE_NAME=Upper(p_view_name)
	  order by COLUMN_ID;
     --
BEGIN
   BIS_DEBUG_PUB.Add('> create_View_Text_Tables');
   ---     x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   l_Done := FALSE;
     l_count := 1;
     --
     -- get the select text
     Bis_debug_pub.Add('view name = '||p_view_name);

     create_View_Select_Text_Table ( p_View_name
				     , x_View_Select_Text_Table
---				   , x_return_status
				     , x_error_Tbl
				     );
     --
     BIS_DEBUG_PUB.Add('text count = '||x_View_Select_Text_Table.COUNT);
     l_count := 1;
     -- get the columns
     FOR cr IN c_all_columns LOOP
	x_view_column_text_table(l_count) := cr.column_name;
	l_count := l_count + 1;
     END LOOP;
     --
     BIS_DEBUG_PUB.Add('< create_View_Text_Tables');

EXCEPTION
   when FND_API.G_EXC_ERROR then

      CLOSE c_all_columns;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then

      CLOSE c_all_columns;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then

      CLOSE c_all_columns;
      BIS_VG_UTIL.Add_Error_Message
	( p_error_msg_id      => SQLCODE
	  , p_error_description => SQLERRM
	  , p_error_proc_name   => G_PKG_NAME||'.create_View_Text_Tables'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END create_View_Text_Tables;


--
/* ============================================================================
   FUNCTION Get_App_Info
   PARAMETERS : 1. p_view_rec  IN     view name
                2. x_return_status    error or normal
                3. x_error_Tbl        table of error messages
   Comment : fills in the app_id, short_name for business views
             returns view record with all the info
   Exception : none
  ========================================================================== */
  FUNCTION  get_app_info
   ( p_view_rec  IN bis_vg_types.view_table_rec_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
  RETURN bis_vg_types.view_table_rec_type
  IS
  l_str      fnd_application.application_short_name%TYPE;
  l_pos      NUMBER;
  l_view_rec bis_vg_types.view_table_rec_type;

  CURSOR app_cursor(p_short_name IN VARCHAR2) IS
     SELECT application_id
       FROM fnd_application
       WHERE application_short_name = Lower(p_short_name);

  BEGIN
     BIS_DEBUG_PUB.Add('> get_app_info');
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_view_rec := p_view_rec;
     l_pos := Instr(l_view_rec.view_name, 'BV_');
     IF (l_pos = 0) THEN
        l_pos := Instr(l_view_rec.view_name, 'FV_');
        IF (l_pos = 0) THEN
           BIS_DEBUG_PUB.Add('< get_app_info');
           RETURN NULL;
        END IF;
     END IF;

     l_view_rec.app_short_name := Substr(l_view_rec.view_name, 1, l_pos - 1);

     IF (  l_view_rec.app_short_name = 'GL'
        OR l_view_rec.app_short_name = 'AP') THEN
        -- GL and AP are special cases
        l_view_rec.app_short_name := 'SQL'||l_view_rec.app_short_name;
     END IF;

     FOR cr IN app_cursor(l_view_rec.app_short_name) LOOP
       l_view_rec.application_id := cr.application_id;
     END LOOP;

     BIS_DEBUG_PUB.Add('< get_app_info');
     RETURN l_view_rec;
       CLOSE app_cursor;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      CLOSE app_cursor;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE app_cursor;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE app_cursor;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.get_app_info'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END get_app_info;

/* ============================================================================
   FUNCTION : valid_view
   PARAMETERS: 1. p_comapre_string compare string for the field
               2. p_view_name      name of the view
               3. x_return_status    error or normal
               4. x_error_Tbl        table of error messages
   RETURNS	BOOLEAN
   COMMENT   : returns true is view text contains given compare string

   EXCEPTION : None
  ========================================================================== */
  FUNCTION valid_view
  ( p_compare_string IN VARCHAR2
  , p_view_name      IN VARCHAR2
  , x_return_status       OUT VARCHAR2
  , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
  )
  RETURN BOOLEAN
  IS
  l_eod              BOOLEAN;
  l_found            BOOLEAN := FALSE;
  l_string           VARCHAR2(32000);
  l_compare_string_u VARCHAR2(1000);
  l_compare_string_l VARCHAR2(1000);
  BEGIN

    BIS_DEBUG_PUB.Add('> valid_view');
    l_eod := FALSE;
    l_compare_string_u := Upper(p_compare_string);
    l_compare_string_l := Lower(p_compare_string);

    string_generator_init ( p_view_name
---			  , x_return_status
			  , x_error_Tbl
			  );
    WHILE (NOT l_eod AND NOT l_found) LOOP
      string_generator_get_string( 32000
                                 , l_string
                                 , l_eod
---				 , x_return_status
				 , x_error_Tbl
                                 );

      IF ((Instr(l_string, l_compare_string_l) <> 0) OR
          (Instr(l_string, l_compare_string_u) <> 0)) THEN
        l_found := TRUE;
      END IF;

    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(g_cursor);

    BIS_DEBUG_PUB.Add('< valid_view');

    RETURN l_found;


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      dbms_sql.close_cursor(g_cursor);
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      dbms_sql.close_cursor(g_cursor);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      dbms_sql.close_cursor(g_cursor);
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.valid_view'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END valid_view;

/* ============================================================================
   PROCEDURE : retrieve_business_views_field
   PARAMETERS: 1. p_comapre_string compare string for the field
               2. p_search_string  string to limit the views
               3. x_View_Table     returned list of views
               4. x_return_status    error or normal
               5. x_error_Tbl        table of error messages
   COMMENT   : Call this procedure get all the view with a particular field

   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_business_views_field
   ( p_compare_string  IN  VARCHAR2
   , p_search_string   IN  VARCHAR2
   , x_View_Table      OUT BIS_VG_TYPES.view_table_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS

     CURSOR c_field_views(p_like_str IN VARCHAR2) IS
        select
          view_name
        , text_length
        FROM user_views
        WHERE
          (
               view_name LIKE '__BV\_%' escape '\'
            OR view_name LIKE '__FV\_%' escape '\'
            OR view_name LIKE '___BV\_%' escape '\'
            OR view_name LIKE '___FV\_%' escape '\'
          )
          AND view_name IN (
                             SELECT
                               DISTINCT(table_name) view_name
                             FROM user_tab_columns
                             WHERE
                               column_name LIKE Upper(p_like_str) escape '\'
                            OR column_name LIKE Lower(p_like_str) escape '\'
                           )
                           ;

   l_view_rec   bis_vg_types.view_table_rec_type;
   l_valid_view BOOLEAN;
   begin
     BIS_DEBUG_PUB.Add('> retrieve_business_views_field');

     FOR cr IN c_field_views(p_search_string) LOOP
       l_view_rec.view_name   := cr.view_name;
       l_view_rec.text_length := cr.text_length;
       l_view_rec := get_app_info ( l_view_rec
				  , x_return_status
				  , x_error_Tbl
                                  );
       l_valid_view := valid_view ( p_compare_string
				  , l_view_rec.view_name
				  , x_return_status
				  , x_error_Tbl
				  );
       IF (l_valid_view = TRUE) THEN
         x_view_table(x_view_table.COUNT + 1) := l_view_rec;
       END IF;

     END LOOP;
     BIS_DEBUG_PUB.Add('< retrieve_business_views_field');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      CLOSE c_field_views;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_field_views;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_field_views;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_business_views_field'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END retrieve_business_views_field;

/* ============================================================================
   PROCEDURE : retrieve_business_views_kfx
   PARAMETERS: 1. p_KF_Appl_Short_Name application short name
               2. p_Key_Flex_Code      key flexfield code
               3. x_View_Table         returned list of views               3.
               4. x_return_status    error or normal
               5. x_error_Tbl        table of error messages
   COMMENT   : Call this procedure get all the view with a particular kfx

   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_business_views_kfx
   ( p_KF_App_Short_Name   IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type  := NULL
   , x_View_Table          OUT BIS_VG_TYPES.view_table_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS

   l_compare_string         VARCHAR2(100);
   l_search_string          VARCHAR2(100);

   BEGIN

     BIS_DEBUG_PUB.Add('> retrieve_business_views_kfx');

     l_compare_string := '_KF:' || p_kf_app_short_name
                                ||':' ||p_key_flex_code;

     l_search_string := '\_KF:%';

     retrieve_business_views_field( l_compare_string
                                   , l_search_string
                                   , x_view_table
				   , x_return_status
				   , x_error_Tbl
                                   );
     BIS_DEBUG_PUB.Add('< retrieve_business_views_kfx');

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
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_business_views_kfx'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END retrieve_business_views_kfx;

/* ============================================================================
   PROCEDURE : retrieve_business_views_dfx
   PARAMETERS: 1. p_DF_Appl_Short_Name application short name
               2. p_Desc_Flex_Name     descriptive flexfield name
               3. x_View_Table         returned list of views               3.
               4. x_return_status    error or normal
               5. x_error_Tbl        table of error messages
   COMMENT   : Call this procedure get all the view with a particular dfx

   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_business_views_dfx
   ( p_DF_App_Short_Name   IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type := NULL
   , x_View_Table          OUT BIS_VG_TYPES.view_table_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS

   l_compare_string         VARCHAR2(100);
   l_search_string          VARCHAR2(100);

   BEGIN

     BIS_DEBUG_PUB.Add('> retrieve_business_views_dfx');

     l_compare_string := '_DF:' || p_df_app_short_name
                                        ||':' ||p_Desc_Flex_Name;

     l_search_string := '\_DF%';

     retrieve_business_views_field( l_compare_string
                                   , l_search_string
                                   , x_view_table
				   , x_return_status
				   , x_error_Tbl
                                   );
     BIS_DEBUG_PUB.Add('< retrieve_business_views_dfx');

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
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_business_views_dfx'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END retrieve_business_views_dfx;

/* ============================================================================
   PROCEDURE : retrieve_business_views_lat
   PARAMETERS:
     1. p_Lookup_Table_Name  lookup table name
     2. p_Lookup_Type        lookup code
     3. x_View_Table         returned list of views               3.
     4. x_return_status    error or normal
     5. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure get all the view with a particular lat

   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_business_views_lat
   ( p_Lookup_Table_Name   IN  VARCHAR2
   , p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type
   , x_View_Table          OUT BIS_VG_TYPES.view_table_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS

   l_compare_string         VARCHAR2(100);
   l_search_string          VARCHAR2(100);

   BEGIN

     BIS_DEBUG_PUB.Add('> retrieve_business_views_lat');

     l_compare_string := ':'||p_lookup_table_name||':'||p_lookup_Type||':';

     l_search_string := '\_LA:%';

     retrieve_business_views_field( l_compare_string
                                   , l_search_string
                                   , x_view_table
				   , x_return_status
				   , x_error_Tbl
                                   );
     BIS_DEBUG_PUB.Add('< retrieve_business_views_lat');

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
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_business_views_lat'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END retrieve_business_views_lat;

/* ============================================================================
   PROCEDURE : retrieve_Business_View_name
     PARAMETERS:
     1. p_view_name    name of the view
     2. x_View_Table   returned list of views
     3. x_return_status    error or normal
     4. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to retrieve the business views
               from the runtime repository.
   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_business_view_name
   ( p_view_name   IN  BIS_VG_TYPES.View_name_Type
   , x_View_Table  OUT BIS_VG_TYPES.view_table_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS
   CURSOR C_all_views IS
     select
       view_name
     , text_length
     FROM user_views
     WHERE view_name = Upper(p_view_name);
   l_view_rec   bis_vg_types.view_table_rec_type;
   BEGIN
      BIS_DEBUG_PUB.Add('> retrieve_Business_Views_view_name');
      BIS_DEBUG_PUB.Add('view-name is '||p_view_name);
      FOR cr IN c_all_views LOOP
        l_view_rec.view_name   := cr.view_name;
        l_view_rec.text_length := cr.text_length;
        l_view_rec := get_app_info(l_view_rec, x_return_status, x_error_Tbl);
  	IF l_view_rec.view_name IS NOT NULL THEN
	   x_view_table(x_view_table.COUNT + 1) := l_view_rec;
	END IF;

     END LOOP;
     BIS_DEBUG_PUB.Add('< retrieve_Business_Views_view_name');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      CLOSE c_all_views;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_all_views;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_all_views;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_Business_View_name'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END retrieve_Business_View_name;

/* ============================================================================
   PROCEDURE : retrieve_Business_Views_app
     PARAMETERS:
     1. p_view_name    name of the view
     2. x_View_Table   returned list of views
     3. x_return_status    error or normal
     4. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to retrieve the business views
               from the runtime repository.
   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_business_views_app
   ( p_app_short_name   IN  BIS_VG_TYPES.App_Short_Name_Type
   , x_View_Table       OUT BIS_VG_TYPES.view_table_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS

   CURSOR c_all_views(p_app_abbrev IN VARCHAR2) IS
     select
       view_name
     , text_length
     FROM user_views
     WHERE view_name LIKE Upper(p_app_abbrev)||'BV\_%' escape '\'
       OR  view_name LIKE Upper(p_app_abbrev)||'FV\_%' escape '\';
    -- Handle PER(HR) product views as a special case
   CURSOR c_hr_views is
     select
       view_name
     , text_length
     FROM user_views
     WHERE view_name LIKE 'HR'||'BV\_%' escape '\'
       OR  view_name LIKE 'HR'||'FV\_%' escape '\'
       OR  view_name LIKE 'IRC'||'BV\_%' escape '\'
       OR  view_name LIKE 'IRC'||'FV\_%' escape '\';

   l_count      NUMBER := 1;
   l_view_rec   bis_vg_types.view_table_rec_type;
   l_app_abbrev BIS_VG_TYPES.app_short_name_type;
   l_view_table BIS_VG_TYPES.view_table_type;
   BEGIN

     BIS_DEBUG_PUB.Add('> retrieve_Business_Views_app');

     BIS_DEBUG_PUB.Add('short_name = '||p_app_short_name);
     -- Handle  HR product views as a special case
     IF UPPER(p_app_short_name) = 'HR' then
       FOR cr IN c_hr_views
       LOOP
         BIS_DEBUG_PUB.Add('view_name = '||cr.view_name);
         BIS_DEBUG_PUB.Add('text length = '||cr.text_length);
         l_view_rec.view_name   := cr.view_name;
         l_view_rec.text_length := cr.text_length;
         l_view_rec := get_app_info(l_view_rec, x_return_status, x_error_Tbl);
         x_view_table(l_count) := l_view_rec;
         l_count := l_count +1;
         BIS_DEBUG_PUB.Add('l_count = '||l_count);
       END LOOP;
     ELSE
       FOR cr IN c_all_views(p_app_short_name)
       LOOP
         BIS_DEBUG_PUB.Add('view_name = '||cr.view_name);
         BIS_DEBUG_PUB.Add('text length = '||cr.text_length);
         l_view_rec.view_name   := cr.view_name;
         l_view_rec.text_length := cr.text_length;
         l_view_rec := get_app_info(l_view_rec, x_return_status, x_error_Tbl);
         x_view_table(l_count) := l_view_rec;
         l_count := l_count +1;
         BIS_DEBUG_PUB.Add('l_count = '||l_count);
       END LOOP;
     END IF;

     -- handle special cases
     l_app_abbrev := Upper(p_app_short_name);

     IF(Substr(l_app_abbrev, 1, 3) = 'SQL') THEN
       l_app_abbrev := Substr(l_app_abbrev, 4);
       retrieve_business_views_app ( l_app_abbrev
                                   , l_view_table
				   , x_return_status
				   , x_error_Tbl
				   );
     ELSE
       IF (l_app_abbrev='OE') THEN
         retrieve_business_views_app('WSH'
				    , l_view_table
				    , x_return_status
				    , x_error_Tbl
				    );
       ELSE
         IF (l_app_abbrev='PER') THEN
           retrieve_business_views_app('HR'
				      , l_view_table
				      , x_return_status
				      , x_error_Tbl
				      );

         ELSE
           IF (l_app_abbrev='OTA') THEN
             retrieve_business_views_app('OT'
					, l_view_table
					, x_return_status
					, x_error_Tbl
					);
           ELSE
             IF (l_app_abbrev='OFA') THEN
               retrieve_business_views_app('FA'
					  , l_view_table
					  , x_return_status
					  , x_error_Tbl
					  );
             END IF;
	   END IF;
	 END IF;
       END IF;
     END IF;

     FOR i IN 1 .. l_view_table.COUNT LOOP
       x_view_table(x_view_table.COUNT + 1) := l_view_table(i);
     END LOOP;

     BIS_DEBUG_PUB.Add('< retrieve_Business_Views_app');


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      CLOSE c_all_views;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_all_views;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_all_views;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_business_views_app'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END retrieve_business_views_app;

/* ============================================================================
   PROCEDURE : retrieve_Business_Views_all
     PARAMETERS:
     1. x_View_Table   returned list of views
     2. x_return_status    error or normal
     3. x_error_Tbl        table of error message

   COMMENT   : Call this procedure to retrieve all the business views

   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_business_views_all
   (x_View_Table       OUT BIS_VG_TYPES.view_table_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS

   CURSOR C_all_views IS
     select
       view_name
     , text_length
     FROM user_views
     WHERE view_name LIKE '__BV\_%' escape '\'
        OR view_name LIKE '__FV\_%' escape '\'
        OR view_name LIKE '___BV\_%' escape '\'
        OR view_name LIKE '___FV\_%' escape '\';

   l_view_rec  bis_vg_types.view_table_rec_type;

   BEGIN

     FOR cr IN c_all_views LOOP
       l_view_rec.view_name   := cr.view_name;
       l_view_rec.text_length := cr.text_length;
       l_view_rec := get_app_info ( l_view_rec
				  , x_return_status
				  , x_error_Tbl
                                  );

       x_view_table(x_view_table.COUNT + 1) := l_view_rec;
     END LOOP;


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      CLOSE c_all_views;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_all_views;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      CLOSE c_all_views;
      BIS_VG_UTIL.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_business_views_all'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END retrieve_business_views_all;

/* ============================================================================
   PROCEDURE : retrieve_Business_Views
   PARAMETERS: 1. p_all_flag           retrieve all views for all products
               2. p_App_Short_Name     application short name
               3. p_KF_Appl_Short_Name application short name
               4. p_Key_Flex_Code      key flexfield code
               5. p_DF_Appl_Short_Name application short name
               6. p_Desc_Flex_Name     descriptive flexfield name
               7. p_Lookup_Table_Name  lookup table name
               8. p_Lookup_Code        lookup code
               9. p_View_Name          name of view to generate
              10. x_View_Table         table to hold view definitions
              11. x_return_status    error or normal
              12. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to retrieve the business views from the
               runtime repository.
   EXCEPTION : None
  ========================================================================== */
   PROCEDURE retrieve_Business_Views
   ( p_all_flag            IN  VARCHAR2                         := NULL
   , p_App_Short_name      IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type  := NULL
   , p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type := NULL
   , p_Lookup_Table_Name   IN  VARCHAR2                         := NULL
   , p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type    := NULL
   , p_View_Name           IN  BIS_VG_TYPES.View_name_Type      := NULL
   , x_View_Table          OUT BIS_VG_TYPES.View_Table_Type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS
--
   BEGIN

     BIS_DEBUG_PUB.Add('> retrieve_Business_Views');
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (p_all_flag = fnd_api.g_true) THEN

        retrieve_business_views_all ( x_view_table
				    , x_return_status
				    , x_error_Tbl
				    );

     ELSIF (p_view_name IS NOT  NULL) THEN

         retrieve_business_view_name( p_view_name
				    , x_view_table
				    , x_return_status
				    , x_error_Tbl
				    );

     ELSIF (p_app_short_name IS NOT NULL) THEN

         retrieve_business_views_app(p_app_short_name
				    , x_view_table
				    , x_return_status
				    , x_error_Tbl
				    );


     ELSIF(    p_kf_appl_short_name IS NOT NULL
           AND p_key_flex_code IS NOT NULL
          ) THEN

       retrieve_business_views_kfx( p_kf_appl_short_name
                                  , p_key_flex_code
                                  , x_view_table
				  , x_return_status
				  , x_error_Tbl
                                  );

     ELSIF(    p_DF_Appl_Short_Name IS NOT NULL
           AND p_Desc_Flex_Name IS NOT NULL
          ) THEN

       retrieve_business_views_dfx( p_df_appl_short_name
                                  , p_desc_flex_name
                                  , x_view_table
				  , x_return_status
				  , x_error_Tbl
                                  );

     ELSE

       retrieve_business_views_lat( p_lookup_table_name
                                  , p_lookup_Type
                                  , x_view_table
				  , x_return_status
				  , x_error_Tbl
                                  );

     END IF;

     BIS_DEBUG_PUB.Add('< retrieve_Business_Views');

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
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_Business_Views'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END retrieve_Business_Views;
--
END BIS_VG_REPOSITORY_MEDIATOR;

/
