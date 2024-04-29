--------------------------------------------------------
--  DDL for Package Body BIS_VG_COMPILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_COMPILE" AS
/* $Header: BISTCMPB.pls 120.5.12010000.2 2008/10/24 23:59:56 dbowles ship $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTCMPB.pls
--
--  DESCRIPTION
--
--      body of package which writes the business views
--
--  NOTES
--
--  HISTORY
--
--  21-AUG-98 ANSINGHA created
--  12-MAY-99 WNASRALL replaced call to do_array_ddl with do_ddl for eficiency
--  06-APR-01 DBOWLES modified make_column_len30 and  write view procedures.  Add two
--            new parameters of bis_vg_types.Flex_Column_Comment_Table_Type
--            to each procedure.
--  25-OCT-05 Edited by donald.bowles  Made changes for NOCOPY hint.
--
--
G_PKG_NAME CONSTANT VARCHAR(30) := 'bis_vg_compile';

--=====================
--PRIVATE TYPES
--=====================
--
-- ============================================================================
--TYPE : View_Text_Count_Rec_Type
-- ============================================================================
TYPE View_Text_Count_Rec_Type    IS  -- local type
RECORD
  ( Column_name bis_vg_types.View_Text_Table_Rec_Type
  , Count       NUMBER
    );

--
--============================================================================
--TYPE : View_Text_Count_Table_Type
--============================================================================
TYPE View_Text_Count_Table_Type IS
   -- local type
   TABLE OF
   View_Text_Count_Rec_Type INDEX BY BINARY_INTEGER;
--
--
--=====================
--OBSOLETE PROCEDURES
--=====================
--
--
--============================================================================
--PROCEDURE : remove_blank_lines
--PARAMETERS: 1. p_View_Text_Table table of varchars for view text
-- 2. x_View_Text_Table table of varchars for view text
-- 3. x_return_status error or normal
-- 4. x_error_Tbl table of error messages
--COMMENT : Call this procedure to remove blank lines from the view table
--EXCEPTION : None
--============================================================================
--PROCEDURE remove_blank_lines ( p_view_text_table IN
--bis_vg_types.view_text_table_type , x_view_text_table out
--bis_vg_types.view_text_table_type , x_return_status OUT VARCHAR2 ,
--x_error_Tbl OUT BIS_VG_UTIL.Error_Tbl_Type ) IS l_str
--bis_vg_types.view_text_table_rec_type; l_char VARCHAR(1); l_length NUMBER;
--BEGIN
--  bis_debug_pub.Add('> remove_blank_lines');
--  x_return_status := FND_API.G_RET_STS_SUCCESS;
--
--  FOR i IN 1 .. p_view_text_table.COUNT LOOP
--    l_str := p_view_text_table(i);
--    l_length := Length(l_str);
--    IF (l_length > 0) THEN
--      FOR j IN 1 .. l_length LOOP
--        l_char := Substr(l_str, j, 1);
--        IF (l_char <> ' ' AND l_char <> ' ') THEN
--    x_view_text_table(x_view_text_table.COUNT + 1) := l_str;
--          EXIT;
--        END IF;
--      END LOOP;
--    END IF;
--  END LOOP;
--
--  bis_debug_pub.Add('< remove_blank_lines');
--
--
--EXCEPTION
--   when FND_API.G_EXC_ERROR then
--      x_return_status := FND_API.G_RET_STS_ERROR ;
--      RAISE FND_API.G_EXC_ERROR;
--   when FND_API.G_EXC_UNEXPECTED_ERROR then
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--   when others then
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      BIS_VG_UTIL.Add_Error_Message
--  ( p_error_msg_id      => SQLCODE
--    , p_error_description => SQLERRM
--    , p_error_proc_name   => G_PKG_NAME||'.remove_blank_lines'
--    , p_error_table       => x_error_tbl
--    , x_error_table       => x_error_tbl
--    );
--      bis_vg_log.update_failure_log( x_error_tbl
--             , x_return_status
--             , x_error_Tbl
--             );
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
--END remove_blank_lines;
--
-- ============================================================================
--PROCEDURE : create_DSQL_view
--PARAMETERS: 1. p_View_Text_Table  complete view text table
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : Call this function to retrieve the application short name
--            for a particular application.
--RETURN    : application short name
--EXCEPTION : None
-- ============================================================================
--PROCEDURE create_DSQL_view
--( p_View_Text_Table IN  bis_vg_types.View_Text_Table_Type
--, x_return_status       OUT VARCHAR2
--, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
--)
--   IS
----
--   p_CursorID INTEGER;
--   p_SQL_text LONG := null;
--   p_dummy INTEGER;
----
--   BEGIN
--      bis_debug_pub.Add('> create_DSQL_view');
--      x_return_status := FND_API.G_RET_STS_SUCCESS;
--      FOR i IN 1 .. p_View_Text_Table.COUNT LOOP
--   p_SQL_text := p_SQL_text || p_View_Text_Table(i);
--      END LOOP;
--      p_CursorID := DBMS_SQL.OPEN_CURSOR;
--     DBMS_SQL.PARSE( p_CursorID, p_SQL_text, DBMS_SQL.NATIVE);
--     p_dummy := DBMS_SQL.EXECUTE(p_CursorID);
--     bis_debug_pub.Add('< create_DSQL_view');
--
--
--   EXCEPTION
--      when FND_API.G_EXC_ERROR then
--   x_return_status := FND_API.G_RET_STS_ERROR ;
--   RAISE FND_API.G_EXC_ERROR;
--      when FND_API.G_EXC_UNEXPECTED_ERROR then
--   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--      when others then
--
--   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--   BIS_VG_UTIL.Add_Error_Message
--     ( p_error_msg_id      => SQLCODE
--       , p_error_description => SQLERRM
--       , p_error_proc_name   => G_PKG_NAME||'.create_DSQL_view'
--       , p_error_table       => x_error_tbl
--       , x_error_table       => x_error_tbl
--       );
--   bis_vg_log.update_failure_log( x_error_tbl
--          , x_return_status
--          , x_error_Tbl
--          );
--   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
--   END create_DSQL_view;
-- ============================================================================
--PROCEDURE : execute_DDL_Statement
--PARAMETERS: 1. p_View_Table_Rec name of view to be created
--            2. p_ub             last statement in buffer
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
--
--COMMENT   : Call this procedure to execute the dynamic SQL statement to
--            create the view.
--EXCEPTION : None
-- ============================================================================
--PROCEDURE execute_DDL_Statement -- PRIVATE PROCEDURE
--( p_View_Table_Rec IN bis_vg_types.View_Table_Rec_Type
--, p_ub             IN INTEGER
--, x_return_status       OUT VARCHAR2
--, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
--)
--IS
----
--l_applsys_schema         VARCHAR2(100);
--l_application_short_name VARCHAR2(10);
--l_View_Name              VARCHAR2(100);
--dummy1                   VARCHAR2(2);
--dummy2                   VARCHAR2(2);
--l_lb                     INTEGER := 1;
--l_retvar                 BOOLEAN;
----
--BEGIN
--  bis_debug_pub.Add('> execute_DDL_Statement');
--  x_return_status := FND_API.G_RET_STS_SUCCESS;
--  l_retvar := FND_INSTALLATION.GET_APP_INFO
--                                ( 'FND'
--                                , dummy1
--                                , dummy2
--                                , l_applsys_schema
--                                );
--  bis_debug_pub.Add('l_applsys_schema = ' || l_applsys_schema);
--  bis_debug_pub.Add('p_View_Table_Rec.View_Name = '
--                        || p_View_Table_Rec.View_Name);
--*************************************************************************
-- BIG COMMENT
-- force AD_DDL to behave like a single instance as we want the view
-- to be created only once; here FND has been hardcoded for this purpose
--*************************************************************************
--  l_application_short_name := 'FND';
--  l_View_Name := p_View_Table_Rec.View_Name;
--
--  bis_debug_pub.Add(' l_applsys_schema = '||l_applsys_schema);
--  bis_debug_pub.ADD(' l_application_short_name = '||l_application_short_name);
--  bis_debug_pub.ADD(' ad_ddl.create_view = '||ad_ddl.create_view);
--  bis_debug_pub.ADD(' l_lb = '||l_lb);
--  bis_debug_pub.ADD(' p_ub = '||p_ub);
--  bis_debug_pub.ADD(' l_View_Name = '||l_View_Name);
--
--  AD_DDL.do_array_ddl( l_applsys_schema
--                     , l_application_short_name
--                     , ad_ddl.create_view
--                     , l_lb
--                     , p_ub
--                     , l_View_Name
--                     );
--
--  bis_debug_pub.Add('< execute_DDL_Statement');
----
--
--
--EXCEPTION
--   when FND_API.G_EXC_ERROR then
--      x_return_status := FND_API.G_RET_STS_ERROR ;
--      RAISE FND_API.G_EXC_ERROR;
--   when FND_API.G_EXC_UNEXPECTED_ERROR then
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--   when others then
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      BIS_VG_UTIL.Add_Error_Message
--  ( p_error_msg_id      => SQLCODE
--    , p_error_description => SQLERRM
--    , p_error_proc_name   => G_PKG_NAME||'.execute_DDL_Statement'
--    , p_error_table       => x_error_tbl
--    , x_error_table       => x_error_tbl
--    );
--      bis_vg_log.update_failure_log( x_error_tbl
--             , x_return_status
--             , x_error_Tbl
--             );
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
--END execute_DDL_Statement;
--
--
--
-- ============================================================================
--PROCEDURE : build_DDL_Statement
--PARAMETERS: 1. p_View_Text_Table  table of varchars to hold view creation
--               text
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to create a DDL statement from the view text
--            of the view.
--EXCEPTION : None
-- ============================================================================
--PROCEDURE build_DDL_Statement -- PRIVATE PROCEDURE
--( p_View_Text_Table IN  bis_vg_types.View_Text_Table_Type
--, x_return_status       OUT VARCHAR2
--, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
--)
--IS
--
--l_count INTEGER;
--
--BEGIN
--   bis_debug_pub.Add('> build_DDL_Statement');
--   x_return_status := FND_API.G_RET_STS_SUCCESS;
--  FOR l_count IN 1 .. p_View_Text_Table.COUNT LOOP
--    AD_DDL.build_statement(' '||p_View_Text_Table(l_count)||' ', l_count);
--  END LOOP;
--  bis_debug_pub.Add('< build_DDL_Statement');
--
--
--EXCEPTION
--   when FND_API.G_EXC_ERROR then
--      x_return_status := FND_API.G_RET_STS_ERROR ;
--      RAISE FND_API.G_EXC_ERROR;
--   when FND_API.G_EXC_UNEXPECTED_ERROR then
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--   when others then
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      BIS_VG_UTIL.Add_Error_Message
--  ( p_error_msg_id      => SQLCODE
--    , p_error_description => SQLERRM
--    , p_error_proc_name   => G_PKG_NAME||'.build_DDL_Statement'
--    , p_error_table       => x_error_tbl
--    , x_error_table       => x_error_tbl
--    );
--      bis_vg_log.update_failure_log( x_error_tbl
--             , x_return_status
--             , x_error_Tbl
--             );
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
--END build_DDL_Statement;

--=====================
--PRIVATE PROCEDURES
--=====================
--
-- ============================================================================
--PROCEDURE : do_long_DDL
--PARAMETERS:
--           1. p_View_Table_Rec    record of view table
--           2. p_View_Create_Text_Table table of varchars for create view text
--           3. p_View_Select_Text_Table table of varchars for select view text
--           4. p_applsys_schema name of schema tobe used in call to ad_ddl
--           5. x_return_status    error or normal
--           6. x_error_Tbl        table of error messages
--COMMENT   :  Creates a DDL statement from the tables directly.
--             Best used whenthe view text is bigger than 30K.
--EXCEPTION : None
-- ============================================================================
PROCEDURE DO_LONG_DDL
 ( p_mode                       IN NUMBER
  , p_view_name                 IN VARCHAR2
  , p_View_Create_Text_Table    IN bis_vg_types.View_Text_Table_Type
  , p_View_Select_Text_Table    IN bis_vg_types.View_Text_Table_Type
  , p_applsys_schema            IN VARCHAR2
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_error_Tbl                 OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)

  IS
   l_count  NUMBER;
   l_total  NUMBER;
   l_dummy  VARCHAR2(100);
BEGIN
   bis_debug_pub.Add('> do_long_ddl');
---  x_return_status := FND_API.G_RET_STS_SUCCESS;


  FOR l_count IN 1 .. p_View_Create_Text_Table.COUNT
    LOOP
       AD_DDL.build_statement(p_View_Create_Text_Table(l_count)
            , l_count);
       IF (p_mode <> bis_vg_types.production_mode AND
     p_mode <> bis_vg_types.sqlplus_production_mode) THEN
    BIS_DEBUG_PUB.Add(p_View_Create_Text_Table(l_count));
       END IF;
       l_total := l_count;
    END LOOP;

    FOR l_count IN 1 .. p_View_Select_Text_Table.COUNT
      LOOP
   l_total := l_total+1;
   AD_DDL.build_statement(p_View_Select_Text_Table(l_count)
        , l_total);
   IF (p_mode <> bis_vg_types.production_mode AND
       p_mode <> bis_vg_types.sqlplus_production_mode) THEN
      BIS_DEBUG_PUB.Add(p_View_Select_Text_Table(l_count));
   END IF;

      END LOOP;
   AD_DDL.do_array_ddl(   p_applsys_schema
        , 'FND' -- hardcoded to force AD_DDL
        -- to create the view only once
        , ad_ddl.create_view  -- type
        , 1
        , l_total
        , p_View_Name
        );
bis_debug_pub.Add('< do_long_ddl');

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
    , p_error_description => SQLERRM||'[ '||ad_ddl.error_buf||' ]'
    , p_error_proc_name   => G_PKG_NAME||'.do_long_ddl'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END do_long_ddl;
--
-- ============================================================================
--PROCEDURE : do_short_DDL
--PARAMETERS:
--           1. p_View_name    name of view table
--           2. p_View_Create_Text_Table table of varchars for create view text
--           3. p_View_Select_Text_Table table of varchars for select view text
--           4. p_applsys_schema name of schema tobe used in call to ad_ddl
--           5. x_return_status    error or normal
--           6. x_error_Tbl        table of error messages
--COMMENT   :  Creates a DDL statement using a 28K vcarchar2.
--             Best used whenthe view text is smaller than 28K.
--EXCEPTION : Throws 'expected_overflow_exception' to indicate text overflow
--            (i.e. view text bigger than 30K)
-- ============================================================================
PROCEDURE DO_SHORT_DDL

  ( p_mode                      IN NUMBER
  , p_view_name                 IN VARCHAR2
  , p_View_Create_Text_Table    IN bis_vg_types.View_Text_Table_Type
  , p_View_Select_Text_Table    IN bis_vg_types.View_Text_Table_Type
  , p_applsys_schema            IN VARCHAR2
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_error_Tbl                 OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)

  IS
     l_buffer VARCHAR2(29000);
     l_count  NUMBER;
     l_length NUMBER := 0;
BEGIN
   bis_debug_pub.Add('> do_short_ddl');
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   BEGIN
      FOR l_count IN 1 .. p_View_Create_Text_Table.COUNT
  LOOP
     l_length := l_length  + length(p_View_Create_Text_Table(l_count));
     if l_length > 30999 then raise expected_overflow_error;
     end if;
     IF (p_mode <> bis_vg_types.production_mode AND
         p_mode <> bis_vg_types.sqlplus_production_mode) THEN
        BIS_DEBUG_PUB.Add(p_View_Create_Text_Table(l_count));
     END IF;
     l_buffer:=l_buffer || p_View_Create_Text_Table(l_count);
  END LOOP;

  FOR l_count IN 1 .. p_View_Select_Text_Table.COUNT
    LOOP
       l_buffer:=l_buffer || p_View_Select_Text_Table(l_count);
       l_length := l_length  + length(p_View_Select_Text_Table(l_count));
---      if l_length > 30999 then raise expected_overflow_error;
---      end if;
       IF (p_mode <> bis_vg_types.production_mode AND
     p_mode <> bis_vg_types.sqlplus_production_mode) THEN
    BIS_DEBUG_PUB.Add(p_View_Select_Text_Table(l_count) );
       END IF;
    END LOOP;

    IF l_buffer IS NULL
      THEN RAISE expected_overflow_error;
    END IF;
   EXCEPTION
      when numeric_or_value_error then
   -- This is propagated because it is expected
   bis_debug_pub.Add('Failed  do_short');
   raise expected_overflow_error;
      when expected_overflow_error then
   raise;

   END;

   AD_DDL.DO_DDL( p_applsys_schema
      , 'FND' -- hardcoded to force AD_DDL
              -- to create the view only once
      , ad_ddl.create_view  -- type
      , l_buffer
      , p_View_Name
      );
   bis_debug_pub.Add('< do_short_ddl');

EXCEPTION
   when expected_overflow_error
     -- This is propagated because it is expected
     then
      bis_debug_pub.Add('Expected exit from do_short_ddl');
      raise;
   when numeric_or_value_error then
      bis_debug_pub.Add('Numeric_or_value error unexpected in do_short_ddl');
      RAISE;
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
    , p_error_description => SQLERRM||'[ '||ad_ddl.error_buf||' ]'
    , p_error_proc_name   => G_PKG_NAME||'.do_short_ddl'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END do_short_ddl;



   --
-- ============================================================================
--PROCEDURE : make_column_len30
--PARAMETERS: 1. p_View_Column_Table table of varchars
--            2. x_View_Column_Table table of varchars
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to ensure column names <= 30 bytes
--EXCEPTION : None
-- ============================================================================
PROCEDURE make_column_len30 -- PRIVATE PROCEDURE
( p_View_Column_Table         IN  bis_vg_types.View_Text_Table_Type
, p_View_Column_Comment_Table IN bis_vg_types.Flex_Column_Comment_Table_Type
, x_View_Column_Table         IN OUT NOCOPY bis_vg_types.View_Text_Table_Type
, x_View_Column_Comment_Table IN OUT NOCOPY bis_vg_types.Flex_Column_Comment_Table_Type
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_column_name  bis_vg_types.View_Text_Table_Rec_Type;
l_start_string bis_vg_types.View_Text_Table_Rec_Type;
l_end_string   bis_vg_types.View_Text_Table_Rec_Type;
l_original_column_name bis_vg_types.View_Text_Table_Rec_Type;
l_pos          NUMBER;
--
BEGIN
  bis_debug_pub.Add('> make_column_len30');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_View_Column_Table := p_View_Column_Table;
  x_View_Column_Comment_Table := p_View_Column_Comment_Table;
  FOR i IN 1 .. p_View_Column_Table.COUNT LOOP
    l_column_name := p_View_Column_Table(i);
    l_original_column_name := l_column_name;
    --
    IF(LENGTHB(l_column_name) > 30) THEN
      l_pos := INSTRB(l_column_name, '^');
      IF(l_pos = 0) THEN
        l_column_name := SUBSTRB(l_column_name, 1, 30);
      --SUBSTRB seems to pull extra bytes if the last character is multibyte.
      --testing new column length and reducing the number of bytes requested
      --if length still over 30 bytes.
        IF (LENGTHB(l_column_name) > 30) THEN
          l_column_name := SUBSTRB(l_column_name, 1, 29);
          IF (LENGTHB(l_column_name) > 30) THEN
            l_column_name := SUBSTRB(l_column_name, 1, 28);
          END IF;
        END IF;
      ELSE
        l_start_string := SUBSTRB(l_column_name, 1, l_pos - 1);
        l_end_string := SUBSTRB(l_column_name, l_pos + 1);
        l_column_name := SUBSTRB(l_start_string, 1, 29 - LENGTHB(l_end_string))
                         || '^' || l_end_string;
        IF (LENGTHB(l_column_name) > 30) THEN
          l_column_name := SUBSTRB(l_column_name, 1, 29);
          IF (LENGTHB(l_column_name) > 30) THEN
            l_column_name := SUBSTRB(l_column_name, 1, 28);
          END IF;
        END IF;
      END IF;
      x_View_Column_Table(i) := l_column_name;
      <<comment_loop>>
      FOR j IN 1 .. p_View_Column_Comment_Table.COUNT LOOP
         IF (x_View_Column_Comment_Table(j).column_name = l_original_column_name) THEN
             x_View_Column_Comment_Table(j).column_name := l_column_name;
         EXIT comment_loop;
         END IF;
      END LOOP comment_loop;

    END IF;
  END LOOP;
  bis_debug_pub.Add('< make_column_len30');

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
    , p_error_proc_name   => G_PKG_NAME||'.make_column_len30'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END make_column_len30;
--
-- ============================================================================
--FUNCTION  : find_column
--PARAMETERS: 1. p_column_name            column name to look for
--            2. p_View_Text_Count_Table  table of View_Text_Count_Rec_Type
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
--RETURN    : NUMBER
--COMMENT   : Call this function to get the index of p_column_name in
--            p_View_Text_Count_Table; else return 0;
--EXCEPTION : None
-- ============================================================================
FUNCTION find_column -- PRIVATE FUNCTION
( p_column_name           IN bis_vg_types.View_Text_Table_Rec_Type
, p_View_Text_Count_Table IN View_Text_Count_Table_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)
RETURN NUMBER IS
--
BEGIN
  bis_debug_pub.Add('> find_column');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i IN 1 .. p_View_Text_Count_Table.COUNT LOOP
    IF( REPLACE(p_column_name, '^', '_') =
        REPLACE(p_View_Text_Count_Table(i).Column_name, '^', '_') ) THEN
      RETURN i;
    END IF;
  END LOOP;
  bis_debug_pub.Add('< find_column');
  RETURN 0;



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
    , p_error_proc_name   => G_PKG_NAME||'.find_column'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END find_column;
--
-- ============================================================================
--PROCEDURE : insert_hat_in_column
--PARAMETERS: 1. p_column_name       column name
--            2. p_table_column_name column name in count table
--            3. x_column_name       updated column name
--            4. x_return_status    error or normal
--            5. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to put hat in p_column_name if
--            p_table_column_name has a hat
--EXCEPTION : None
-- ============================================================================
PROCEDURE insert_hat_in_column -- PRIVATE PROCEDURE
( p_column_name       IN  bis_vg_types.View_Text_Table_Rec_Type
, p_table_column_name IN  bis_vg_types.View_Text_Table_Rec_Type
, x_column_name       IN OUT NOCOPY bis_vg_types.View_Text_Table_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_pos NUMBER;
--
BEGIN
  bis_debug_pub.Add('> insert_hat_in_column');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_column_name := p_column_name;
  l_pos := INSTRB(p_table_column_name, '^');
  IF(l_pos > 0) THEN
    x_column_name := SUBSTRB(p_column_name, 1, l_pos - 1) ||
                     '^' ||
                     SUBSTRB(p_column_name, l_pos + 1);
  END IF;
  bis_debug_pub.Add('< insert_hat_in_column');


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
    , p_error_proc_name   => G_PKG_NAME||'.insert_hat_in_column'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END insert_hat_in_column;
--
-- ============================================================================
--PROCEDURE : make_unique_columns
--PARAMETERS: 1. p_View_Column_Table table of varchars
--            2. p_View_Column_Comment_Table Table of records
--               holding flex info for flex derived columns
--            3. x_View_Column_Table table of varchars
--            4. x_View_Column_Comment_Table table of records
--               holding flex info for flex derived columns
--            5. x_return_status    error or normal
--            6. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to ensure column names are unique
--EXCEPTION : None
-- ============================================================================
PROCEDURE make_unique_columns -- PRIVATE PROCEDURE
( p_View_Column_Table         IN  bis_vg_types.View_Text_Table_Type
, p_View_Column_Comment_Table IN bis_vg_types.Flex_Column_Comment_Table_Type
, x_View_Column_Table         IN OUT NOCOPY bis_vg_types.View_Text_Table_Type
, x_View_Column_Comment_Table IN OUT NOCOPY bis_vg_types.Flex_Column_Comment_Table_Type
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_View_Text_Count_Table View_Text_Count_Table_Type;
l_View_Text_Count_Rec   View_Text_Count_Rec_Type;
l_column_name           bis_vg_types.View_Text_Table_Rec_Type;
l_count_string          VARCHAR2(10);
l_end_string            VARCHAR2(100);
l_start_string          VARCHAR2(100);
l_index                 NUMBER;
l_pos                   NUMBER;
--
BEGIN
  bis_debug_pub.Add('> make_unique_columns');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_View_Column_Table := p_View_Column_Table;
  x_View_Column_Comment_Table := p_View_Column_Comment_Table;
  FOR i IN 1 .. x_View_Column_Table.COUNT LOOP
    x_View_Column_Table(i) := UPPER(x_View_Column_Table(i));
    l_column_name := x_View_Column_Table(i);
    l_index := find_column( l_column_name
        , l_View_Text_Count_Table
        , x_return_status
        , x_error_Tbl
        );
    IF(l_index = 0) THEN
      l_View_Text_Count_Rec.Column_name := l_column_name;
      l_View_Text_Count_Rec.Count := 0;
      l_View_Text_Count_Table(l_View_Text_Count_Table.COUNT + 1)
         := l_View_Text_Count_Rec;
    ELSE
      bis_debug_pub.add('l_column_name = ' || l_column_name);
      bis_debug_pub.add('l_index = ' || l_index);
      bis_debug_pub.add('l_View_Text_Count_Table(l_index).Column_name = '
            || l_View_Text_Count_Table(l_index).Column_name);
      bis_debug_pub.add('l_View_Text_Count_Table(l_index).Count = '
            || l_View_Text_Count_Table(l_index).Count);
      l_View_Text_Count_Table(l_index).Count
         := l_View_Text_Count_Table(l_index).Count + 1;
      l_count_string := TO_CHAR(l_View_Text_Count_Table(l_index).Count);
      insert_hat_in_column( l_column_name
                            , l_View_Text_Count_Table(l_index).Column_name
                            , l_column_name
                            , x_return_status
                            , x_error_Tbl
                           );
      x_View_Column_Table(i) := l_column_name || '^' || l_count_string;
    END IF;
    -- column comment table needs to have its column names match the new column table name
    <<comment_loop>>
    FOR j IN 1 .. x_View_Column_Comment_Table.COUNT LOOP
      IF ( UPPER(x_View_Column_Comment_Table(j).column_name) = l_column_name ) THEN
        x_View_Column_Comment_Table(j).column_name := x_View_Column_Table(i);
        EXIT comment_loop;
      END IF;
    END LOOP comment_loop;
  END LOOP;
  bis_debug_pub.Add('< make_unique_columns');


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
    , p_error_proc_name   => G_PKG_NAME||'.make_unique_columns'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END make_unique_columns;
--
-- ============================================================================
--PROCEDURE : format_columns
--PARAMETERS: 1. p_View_Column_Table table of varchars
--            2. x_View_Column_Table table of varchars with hats removed
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to ensure column names dont have hats
--EXCEPTION : None
-- ============================================================================
PROCEDURE format_columns -- PRIVATE PROCEDURE
( p_View_Column_Table         IN  bis_vg_types.View_Text_Table_Type
, p_View_Column_Comment_Table IN bis_vg_types.Flex_Column_Comment_Table_Type
, x_View_Column_Table         IN OUT NOCOPY bis_vg_types.View_Text_Table_Type
, x_View_Column_Comment_Table IN OUT NOCOPY bis_vg_types.Flex_Column_Comment_Table_Type
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)
IS
l_length   NUMBER;
l_x_View_Column_Table  bis_vg_types.View_Text_Table_Type;
l_counter   NUMBER;
l_occurence_counter NUMBER;
BEGIN
  bis_debug_pub.Add('> format_columns');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i IN 1 .. p_View_Column_Table.COUNT LOOP
    x_View_Column_Table(i) := REPLACE(p_View_Column_Table(i), '&', '_');
    x_View_Column_Table(i) := REPLACE(x_View_Column_Table(i), '"','_');
    x_View_Column_Table(i) := REPLACE(x_View_Column_Table(i), '^', '_');
  END LOOP;
  x_View_Column_Comment_Table := p_View_Column_Comment_Table;
  FOR i IN 1 .. x_View_Column_Comment_Table.COUNT LOOP
    x_View_Column_Comment_Table(i).column_name := REPLACE(x_View_Column_Comment_Table(i).column_name, '&', '_');
    x_View_Column_Comment_Table(i).column_name := REPLACE(x_View_Column_Comment_Table(i).column_name, '"', '_');
    x_View_Column_Comment_Table(i).column_name := REPLACE(x_View_Column_Comment_Table(i).column_name, '^', '_');
  END LOOP;
    l_x_View_Column_Table := x_View_Column_Table;
  -- make sure all column names are unique
  FOR i IN 1 .. l_x_View_Column_Table.COUNT LOOP
    FOR j IN i .. x_View_Column_Table.COUNT LOOP
       IF j <> i AND x_View_Column_Table(j) = l_x_View_Column_Table(i) then
          l_length := LENGTHB(x_View_Column_Table(j));
          IF j < 10  THEN
             x_View_Column_Table(j) := SUBSTRB(x_View_Column_Table(j),1, l_length -1)||j;
             -- need to keep the changed names synched up with those in the x_View_Column_Comment_Table
             l_counter := 0;
             l_occurence_counter := 0;
                <<comments_loop1>>
                LOOP
                   l_counter := l_counter + 1;
                   IF x_View_Column_Comment_Table(l_counter).column_name = l_x_View_Column_Table(i) THEN
                     l_occurence_counter := l_occurence_counter +1;
                   END IF;
                   IF l_occurence_counter = 2 THEN
                      x_View_Column_Comment_Table(l_counter).column_name := x_View_Column_Table(j);
                   END IF;
                   EXIT comments_loop1 WHEN l_occurence_counter = 2 OR l_counter = x_View_Column_Comment_Table.COUNT;
                END LOOP comments_loop1;
          ELSIF j < 100 THEN
             x_View_Column_Table(j) := SUBSTRB(x_View_Column_Table(j),1, l_length - 2)||j;
             -- need to keep the changed names synched up with those in the x_View_Column_Comment_Table
             l_counter := 0;
             l_occurence_counter := 0;
                <<comments_loop2>>
                LOOP
                   l_counter := l_counter + 1;
                   IF x_View_Column_Comment_Table(l_counter).column_name = l_x_View_Column_Table(i) THEN
                     l_occurence_counter := l_occurence_counter +1;
                   END IF;
                   IF l_occurence_counter = 2 THEN
                      x_View_Column_Comment_Table(l_counter).column_name := x_View_Column_Table(j);
                   END IF;
                   EXIT comments_loop2 WHEN l_occurence_counter = 2 OR l_counter = x_View_Column_Comment_Table.COUNT;
                END LOOP comments_loop2;
          ELSE
             x_View_Column_Table(j) := SUBSTRB(x_View_Column_Table(j),1, l_length - 3)||j;
             -- need to keep the changed names synched up with those in the x_View_Column_Comment_Table
             l_counter := 0;
             l_occurence_counter := 0;
                <<comments_loop3>>
                LOOP
                   l_counter := l_counter + 1;
                   IF x_View_Column_Comment_Table(l_counter).column_name = l_x_View_Column_Table(i) THEN
                     l_occurence_counter := l_occurence_counter +1;
                   END IF;
                   IF l_occurence_counter = 2 THEN
                      x_View_Column_Comment_Table(l_counter).column_name := x_View_Column_Table(j);
                   END IF;
                   EXIT comments_loop3 WHEN l_occurence_counter = 2 OR l_counter = x_View_Column_Comment_Table.COUNT;
                END LOOP comments_loop3;
          END IF;
       END IF;
    END LOOP;
  END LOOP;
  -- end column name uniqueness routine
  -- wrap the column list names in double quotes
  FOR i IN 1 .. x_View_Column_Table.COUNT LOOP
    x_View_Column_Table(i) := '"'
                              || x_View_Column_Table(i)
                              || '"';
  END LOOP;
  bis_debug_pub.Add('< format_columns');


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
    , p_error_proc_name   => G_PKG_NAME||'.format_columns'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , x_return_status
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END format_columns;
--
-- ============================================================================
--PROCEDURE : format_Table
--PARAMETERS: 1. p_View_Table_Rec    record of view table
--            2. p_View_Column_Table table of varchars
--            3. x_View_Table_Rec    updated record of view table
--            4. x_View_Column_Table table of varchars
--            5. x_return_status    error or normal
--            6. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to add the create statement and commas to the
--            column table; adds whitespace to end of each line in select table
--EXCEPTION : None
-- ============================================================================
PROCEDURE format_Table -- PRIVATE PROCEDURE
( p_View_name                 IN  VARCHAR2
, p_view_column_table         IN  bis_vg_types.View_Text_Table_Type
, p_View_Column_Comment_Table IN  bis_vg_types.Flex_Column_Comment_Table_Type
, x_View_name                 OUT NOCOPY VARCHAR2
, x_View_Column_Table         OUT NOCOPY bis_vg_types.View_Text_Table_Type
, x_View_Column_Comment_Table OUT NOCOPY   bis_vg_types.Flex_Column_Comment_Table_Type

---, x_return_status      OUT VARCHAR2
, x_error_Tbl          OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_count     INTEGER := 1;
l_flag      BOOLEAN := TRUE;

l_dummy     VARCHAR2(1000);
l_pos       NUMBER;
l_View_Column_Table bis_vg_types.View_Text_Table_Type;
l_View_Column_Comment_Table bis_vg_types.Flex_Column_Comment_Table_Type;
l_View_Column_Table1 bis_vg_types.View_Text_Table_Type;
l_View_Column_Comment_Table1 bis_vg_types.Flex_Column_Comment_Table_Type;
l_View_Column_Table2 bis_vg_types.View_Text_Table_Type;
l_View_Column_Comment_Table2 bis_vg_types.Flex_Column_Comment_Table_Type;
l_View_Column_Table3 bis_vg_types.View_Text_Table_Type;
l_View_Column_Comment_Table3 bis_vg_types.Flex_Column_Comment_Table_Type;
l_View_Column_Table4 bis_vg_types.View_Text_Table_Type;
l_View_Column_Comment_Table4 bis_vg_types.Flex_Column_Comment_Table_Type;
--
BEGIN
  bis_debug_pub.Add('> format_Table');
---  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_pos := INSTRB(p_View_Name, 'V_');
  x_View_Name := bis_vg_util.get_generated_view_name
                            ( p_View_name
                              , l_dummy
                              , x_error_Tbl
                            );

  bis_debug_pub.Add('view name is '||x_view_name);
  --
  l_View_Column_Table := p_View_Column_Table;
  l_View_Column_Comment_Table := p_View_Column_Comment_Table;
  FOR i IN 1 .. p_View_Column_Table.COUNT LOOP
    l_View_Column_Table(i) := REPLACE(l_View_Column_Table(i), ' ', '_');
    l_View_Column_Table(i) := REPLACE(l_View_Column_Table(i), '-', '_');
  END LOOP;
  --
  --
  FOR i IN 1 .. p_View_Column_Comment_Table.COUNT LOOP
    l_View_Column_Comment_Table(i).column_name := REPLACE(l_View_Column_Comment_Table(i).column_name,' ', '_');
    l_View_Column_Comment_Table(i).column_name := REPLACE(l_View_Column_Comment_Table(i).column_name,'-', '_');
  END LOOP;
  --
  make_column_len30 ( l_view_column_table
                     , l_View_Column_Comment_Table
                     , l_view_column_table1
                     , l_View_Column_Comment_Table1
                     , l_dummy
                     , x_error_Tbl
                    );

  make_unique_columns ( l_view_column_table1
                       , l_View_Column_Comment_Table1
                       , l_view_column_table2
                       , l_View_Column_Comment_Table2
                       , l_dummy
                       , x_error_Tbl
                      );



  make_column_len30 ( l_view_column_table2
                     , l_View_Column_Comment_Table2
                     , l_view_column_table3
                     , l_View_Column_Comment_Table3
                     , l_dummy
                     , x_error_Tbl
                    );

  format_columns ( l_view_column_table3
                  , l_View_Column_Comment_Table3
                  , l_view_column_table4
                  , l_View_Column_Comment_Table4  -- last manipulation of comment table
                  , l_dummy
                  , x_error_Tbl
                 );

  FOR i IN 1 .. l_view_column_comment_table4.COUNT LOOP
      x_View_Column_Comment_Table(i).column_name := l_view_column_comment_table4(i).column_name;
      x_View_Column_Comment_Table(i).flex_type := l_view_column_comment_table4(i).flex_type;
      x_View_Column_Comment_Table(i).column_comments := l_view_column_comment_table4(i).column_comments;
  END LOOP;

  --
  -- column table
  x_View_Column_Table(l_count) := 'CREATE OR REPLACE VIEW ' || x_View_Name;
  --
  FOR l_ind IN 1 .. l_view_column_table4.COUNT LOOP
    l_count := l_count + 1;
    IF(l_flag = TRUE) then
      x_View_Column_Table(l_count) := ' ( ' || l_view_column_table4(l_ind);
      l_flag := FALSE;
    ELSE
      x_View_Column_Table(l_count) := ' , ' || l_view_column_table4(l_ind);
    END IF;
  END LOOP;

  x_View_Column_Table(l_count+1) :=  ' ) AS ';
  --
  bis_debug_pub.Add('< format_Table');


EXCEPTION
   when FND_API.G_EXC_ERROR then
---      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
---      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;
   when others then
---      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
  ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.format_Table'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , l_dummy
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END format_Table;

--=====================
--Public Procedure
--=====================
--
-- ============================================================================
--PROCEDURE : write_View
--PARAMETERS: 1. p_View_name         name of view
--            2. p_View_Create_Text_Table table of varchars for create view text
--            3. p_View_Select_Text_Table table of varchars for select view text
--            4. x_return_status    error or normal
--            5. x_error_Tbl        table of error messages
--COMMENT   : Call this procedure to create the view given the complete create
--            and select tables.
--EXCEPTION : None
-- ============================================================================
PROCEDURE write_View -- PUBLIC PROCEDURE
( p_mode                      IN NUMBER
, p_View_Name                 IN VARCHAR2
, p_View_Create_Text_Table    IN bis_vg_types.View_Text_Table_Type
, p_View_Select_Text_Table    IN bis_vg_types.view_text_table_type
, p_View_Column_Comment_Table IN  bis_vg_types.Flex_Column_Comment_Table_Type
, x_View_Column_Comment_Table OUT bis_vg_types.Flex_Column_Comment_Table_Type
---, x_return_status       OUT VARCHAR2
, x_error_Tbl                 OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_View_Create_Text_Table bis_vg_types.View_Text_Table_Type;
l_View_name        VARCHAR2(100);
l_applsys_schema         VARCHAR2(100);
dummy_char               VARCHAR2(100);


--
BEGIN

   bis_debug_pub.Add('> write_View');
---   x_return_status := FND_API.G_RET_STS_SUCCESS;
   format_Table( p_View_name
                , p_View_Create_Text_Table
                , p_View_Column_Comment_Table
                , l_View_name
                , l_View_Create_Text_Table
                , x_View_Column_Comment_Table
                ---    , x_return_status
                , x_error_Tbl
               );


--  Get the schema
  IF NOT  FND_INSTALLATION.GET_APP_INFO( 'FND'
                                        , dummy_char
                                        , dummy_char
                                        , l_applsys_schema
                                        )
    THEN RAISE FND_API.G_EXC_ERROR ;
  END IF;


   declare
   BEGIN
      bis_debug_pub.debug_on;
      bis_debug_pub.Add('l_applsys_schema = ' || l_applsys_schema);
      bis_debug_pub.Add('l_View_Name = '
                         || l_View_Name);

      do_short_ddl(p_mode
                   , l_View_name
                   , l_View_Create_Text_Table
                   , p_View_Select_Text_Table
                   , l_applsys_schema
                   , dummy_char
                   , x_error_Tbl
                   );
         bis_debug_pub.debug_off;
   EXCEPTION
      WHEN  expected_overflow_error
  -- We have a view that is too large to fit in a 28000 varchar2
  THEN
   bis_debug_pub.debug_on;

   do_long_ddl( p_mode
                , l_View_name
                , l_View_Create_Text_Table
                , p_View_Select_Text_Table
                , l_applsys_schema
                , dummy_char
                , x_error_Tbl
               );
   bis_debug_pub.debug_off;
   END;

   bis_debug_pub.Add('< write_View');

EXCEPTION
   when FND_API.G_EXC_ERROR then
---      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
---      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;
   when others then
---      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
  ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.write_View'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      bis_vg_log.update_failure_log( x_error_tbl
             , dummy_char
             , x_error_Tbl
             );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_View;
--
END BIS_VG_COMPILE;

/
