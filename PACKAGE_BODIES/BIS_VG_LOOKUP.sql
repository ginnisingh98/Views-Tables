--------------------------------------------------------
--  DDL for Package Body BIS_VG_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_LOOKUP" AS
/* $Header: BISTLATB.pls 115.12 2004/03/01 21:23:31 dbowles ship $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTLATB.pls
--
--  DESCRIPTION
--
--      body of view genrator to substitute lookup type
--
--  NOTES
--
--  HISTORY
--
--  23-JUL-98 Created
--  09-MAR-99 Edited by WNASRALL
--  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
--
G_PKG_NAME CONSTANT VARCHAR(30) := 'bis_vg_lookup';
/* ============================================================================
PROCEDURE : put_column_name
  PARAMETERS:
  1. p_View_Column_Table  table of varchars to hold columns OF view text
  2. p_Column_Pointer     pointer to the lookup column in column tab
  3. p_Mode               mode of execution of the program
  3. x_Column_Table       table of varchars to hold additional columns
  4. x_Column_Pointer     pointer to the character after the delimiter
                          (column table)
  5. x_return_status    error or normal
  6. x_error_Tbl        table of error messages
--
COMMENT   : Call this procedure to add a particular lookup column
            to a view.
EXCEPTION : None
  ===========================================================================*/
PROCEDURE put_column_name
    ( p_View_Column_Table IN  BIS_VG_TYPES.View_Text_Table_Type
    , p_Column_Pointer    IN  BIS_VG_TYPES.View_Character_Pointer_Type
    , p_Mode              IN  NUMBER
    , x_Column_Table      OUT BIS_VG_TYPES.View_Text_Table_Type
    , x_Column_Pointer    OUT BIS_VG_TYPES.View_Character_Pointer_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_str VARCHAR2(1000);
l_col VARCHAR2(1000);
l_num NUMBER;
BEGIN
  BIS_DEBUG_PUB.Add('> put_column_name');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
   -- skip the _LA part
  l_str := bis_vg_parser.Skip_Tag( p_View_Column_Table
                                    , p_column_pointer
                                    , x_column_pointer
				    , x_return_status
				    , x_error_Tbl
                                    );
--
  bis_vg_util.print_view_pointer ( x_column_pointer
				 , x_return_status
				 , x_error_Tbl
                                 );
--
  l_str := bis_vg_util.get_row ( p_view_column_table
                               , p_column_pointer
			       , x_return_status
			       , x_error_Tbl
);
  l_col := l_str;
  l_num := x_column_pointer.col_num;
  l_str := bis_vg_parser.get_string_token( l_str
                                         , l_num
					 , ':'
					 , l_num
					 , x_return_status
					 , x_error_Tbl
					 );
--
  IF (l_num IS NULL) THEN
        x_column_pointer := bis_vg_util.increment_pointer_by_row
                                       ( p_view_column_table
                                       , x_column_pointer
				       , x_return_status
				       , x_error_Tbl
                                       );
   ELSE
        x_column_pointer.col_num := l_num;
  END IF;
--
  bis_debug_pub.ADD('column pos  = '||l_num);
--
  IF (l_str IS NULL) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_lookup.lat_col_tag_exp_msg
	 , p_error_proc_name   => G_PKG_NAME||'.put_column_name'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
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
  -- save to output file
  x_column_table(x_column_table.COUNT + 1) := l_str;
--
  bis_debug_pub.ADD('column name = '||l_str);
--  bis_vg_util.print_view_text(x_column_table, x_return_status, x_error_Tbl );
  bis_vg_util.print_view_pointer ( x_column_pointer
                                 , x_return_status
				 , x_error_Tbl
				 );
--
  IF(p_Mode = bis_vg_types.remove_tags_mode) THEN
    x_column_table.DELETE;
    x_column_table(1) := l_str;
  END IF;
  BIS_DEBUG_PUB.Add('< put_column_name');
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
	  , p_error_proc_name   => G_PKG_NAME||'.put_column_name'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END put_column_name;
--
/* ============================================================================
FUNCTION : get_select_statement
  PARAMETERS:
  1. p_lookup_table       lookup table name
  2. p_lookup_type        lookup type;
  3. p_lookup_column      lookup column in the table to be returned
  4. x_return_status    error or normal
  5. x_error_Tbl        table of error messages
--
  COMMENT  : Call this function to get the select statement for lookup table
             information to a view.
EXCEPTION : None
  ===========================================================================*/
FUNCTION  get_select_statement
    ( p_lookup_table  IN  VARCHAR2
    , p_lookup_type   IN  VARCHAR2
    , p_lookup_column IN  VARCHAR2
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
RETURN VARCHAR2
IS
l_select       VARCHAR2(1000);
BEGIN
  BIS_DEBUG_PUB.Add('> get_select_statement');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  l_select := 'select lookup_code, '||p_lookup_column;
  l_select := l_select || ' from '||p_lookup_table;
  l_select := l_select || ' where lookup_type = '''||p_lookup_type||'''';
--
  BIS_DEBUG_PUB.Add(' l_select = '||l_select);
--
  BIS_DEBUG_PUB.Add('< get_select_statement');
  RETURN l_select;
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
	  , p_error_proc_name   => G_PKG_NAME||'.get_select_statement'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_select_statement;
--
/* ============================================================================
PROCEDURE : write_decode_statement
  PARAMETERS:
  1. p_expr               pl/sql expression for decode
  2. p_select             select statement for the lookup table
  3. x_Select_Table       table of varchars to hold additional select
                          (select table)
  4. x_return_status    error or normal
  5. x_error_Tbl        table of error messages
--
  COMMENT   : Call this procedure to add a particular decode lookup
              information to a view.
EXCEPTION : None
  ===========================================================================*/
PROCEDURE write_decode_statement
    ( p_expr          IN  VARCHAR2
    , p_select        IN  VARCHAR2
    , x_Select_Table  OUT BIS_VG_TYPES.View_Text_Table_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_cursor_id         INTEGER;
l_lookup_code       VARCHAR2(250);
l_meaning           VARCHAR2(250);
l_dummy             INTEGER;
l_select_table      BIS_VG_TYPES.View_Text_Table_Type;
-- flag to allow verification of existence
-- of rows in the lookup table for the lookup
l_DECODE_flag       BOOLEAN := TRUE;
l_stmt_count        NUMBER := 0;
l_decode_nest_level NUMBER := 0;
l_lookup_type_valid BOOLEAN := FALSE;
l_num_rows          NUMBER;
BEGIN
  BIS_DEBUG_PUB.Add('> write_decode_statement');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- open the cursor
  l_cursor_id := dbms_sql.open_cursor;
--
  -- parse the statement
  dbms_sql.parse(l_cursor_id, p_select, dbms_sql.V7);
--
  BIS_DEBUG_PUB.Add('after parsing');
--
  -- define output variables
  dbms_sql.define_column(l_cursor_id, 1, l_lookup_code, 250);
  dbms_sql.define_column(l_cursor_id, 2, l_meaning, 250);
--
  -- execute
  l_dummy := dbms_sql.execute(l_cursor_id);
  --
  l_num_rows := dbms_sql.fetch_rows(l_cursor_id);
--
  IF (l_num_rows = 0) THEN
-- x_return_status := FND_API.G_RET_STS_ERROR;
-- Lookup type undefined set flag to return a NULL for the column
     l_DECODE_flag := TRUE;
  END IF;
--
  WHILE (l_num_rows <> 0) LOOP
    IF(l_DECODE_flag = TRUE) THEN
      bis_debug_pub.add('l_DECODE_flag is TRUE');
    ELSE
      bis_debug_pub.add('l_DECODE_flag is FALSE');
    END IF;
    l_lookup_type_valid := TRUE;
    IF(l_DECODE_flag = TRUE OR l_stmt_count = 100 ) THEN
    -- first pass, need to start the decode
    -- start the decode statement
         IF (l_stmt_count = 100) THEN
           l_stmt_count := 0;
           l_decode_nest_level := l_decode_nest_level + 1;
           x_select_table(x_select_table.COUNT + 1) := ', ';
      END IF;
--
      x_select_table(x_select_table.COUNT + 1) := 'DECODE';
--
      bis_vg_util.create_Text_Table( '( ' || p_expr
                                   , l_select_table
				   , x_return_status
				   , x_error_Tbl
                                   );
      bis_vg_util.concatenate_Tables( x_select_table
                                    , l_select_table
                                    , x_select_table
				    , x_return_status
				    , x_error_Tbl
                                    );
      l_DECODE_flag := FALSE;
    END IF;
--
    bis_debug_pub.add('l_lookup_code = ' || l_lookup_code);
    bis_debug_pub.add('l_meaning = ' || l_meaning);
    dbms_sql.column_value(l_cursor_id, 1, l_lookup_code);
    dbms_sql.column_value(l_cursor_id, 2, l_meaning);
    -- make sure that the ' in l_lookup_code are replace by ''
    l_lookup_code := REPLACE(l_lookup_code,'''','''''');
    x_select_table(x_select_table.COUNT + 1) := ', '|| ''''
                                                    || l_lookup_code
                                                    || '''';
    --
    -- make sure that ' in l_meaning are replaced by ''
    l_meaning := REPLACE (l_meaning, '''', '''''');
    x_select_table(x_select_table.COUNT + 1) := ', '|| ''''
                                                    || l_meaning
                                                    || '''';
    l_stmt_count := l_stmt_count + 1;
    l_num_rows := dbms_sql.fetch_rows(l_cursor_id);
  END LOOP;
  --
  IF(l_DECODE_flag = TRUE) THEN -- no rows in lookup table, hence put NULL
    x_select_table(x_select_table.COUNT + 1) := 'NULL';
  ELSE -- need to end the decode as rows were returned and added
    -- end the decode statement
    x_select_table(x_select_table.COUNT + 1) := ', NULL )';
--
    FOR i IN 1..l_decode_nest_level LOOP
    -- write ') for outer level decodes
      x_select_table(x_select_table.COUNT + 1) := ')';
    END LOOP;
  END IF;
  dbms_sql.close_cursor(l_cursor_id);
--
  BIS_DEBUG_PUB.Add('< write_decode_statement');
--
--
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      dbms_sql.close_cursor(l_cursor_id);
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      dbms_sql.close_cursor(l_cursor_id);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      dbms_sql.close_cursor(l_cursor_id);
      BIS_VG_UTIL.Add_Error_Message
	( p_error_msg_id      => SQLCODE
	  , p_error_description => SQLERRM
	  , p_error_proc_name   => G_PKG_NAME||'.write_decode_statement'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_decode_statement;
--
/* ============================================================================
PROCEDURE : put_decode_statement
  PARAMETERS:
  1. p_expr               pl/sql expression for decode
  2. p_lookup_table       lookup table name
  3. p_lookup_type        lookup type;
  4. p_lookup_column      lookup column in the table to be returned
  5. x_Select_Table       table of varchars to hold additional select
                          (select table)
  6. x_return_status    error or normal
  7. x_error_Tbl        table of error messages
--
  COMMENT   : Call this procedure to add a particular decode lookup
              information to a view.
EXCEPTION : None
  ===========================================================================*/
PROCEDURE put_decode_statement
    ( p_expr          IN  VARCHAR2
    , p_lookup_table  IN  VARCHAR2
    , p_lookup_type   IN  VARCHAR2
    , p_lookup_column IN  VARCHAR2
    , x_Select_Table  OUT BIS_VG_TYPES.View_Text_Table_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_select       VARCHAR2(1000);
BEGIN
  BIS_DEBUG_PUB.Add('> put_decode_statement');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BIS_DEBUG_PUB.Add('p_lookup_column = ' || p_lookup_column);
  BIS_DEBUG_PUB.Add('p_lookup_table = ' || p_lookup_table);
  BIS_DEBUG_PUB.Add('p_lookup_type = ' || p_lookup_type);
  BIS_DEBUG_PUB.Add('p_expr = ' || p_expr);
  -- select statement
  l_select := get_select_statement( p_lookup_table
                                     , p_lookup_type
                                     , p_lookup_column
				     , x_return_status
				     , x_error_Tbl
                                     );
--
--
  BIS_DEBUG_PUB.Add(' l_select = '||l_select);
--
--   write the decode statement
  write_decode_statement ( p_expr
                         , l_select
			 , x_select_table
			 , x_return_status
			 , x_error_Tbl
			   );
  IF ( x_return_status = FND_API.G_RET_STS_ERROR )
    THEN
          BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_lookup.LAT_INVALID_LOOKUP_TYPE_MSG
	 , p_error_proc_name   => G_PKG_NAME||'. write_decode_statement'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1 => 'tag'
	 , p_value1 => '_LA:' || p_expr || ':' || p_lookup_table || ':' ||
	                p_lookup_type || ':' || p_lookup_column
	 , p_token2 => 'sel'
	 , p_value2 => l_select
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
  BIS_DEBUG_PUB.Add('< put_decode_statement');
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
	  , p_error_proc_name   => G_PKG_NAME||'.put_decode_statement'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END put_decode_statement;
--
/* ============================================================================
PROCEDURE : put_decode_statement_lang
  PARAMETERS:
  1. p_expr               pl/sql expression for decode
  2. p_lookup_table       lookup table name
  3. p_lookup_type        lookup type;
  4. p_lookup_column      lookup column in the table to be returned
  5. p_language           language for this lookup
  6. x_Select_Table       table of varchars to hold additional select
  7. x_return_status    error or normal
  8. x_error_Tbl        table of error messages
                          (select table)
--
  COMMENT   : Call this procedure to add a particular decode lookup
              information to a view for the given language.
EXCEPTION : None
  ===========================================================================*/
PROCEDURE put_decode_statement_lang
    ( p_expr          IN  VARCHAR2
    , p_lookup_table  IN  VARCHAR2
    , p_lookup_type   IN  VARCHAR2
    , p_lookup_column IN  VARCHAR2
    , p_language      IN  VARCHAR2
    , x_Select_Table  OUT BIS_VG_TYPES.View_Text_Table_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_select      VARCHAR2(1000);
l_cursor_id   INTEGER;
l_lookup_code VARCHAR2(250);
l_meaning     VARCHAR2(250);
l_dummy       INTEGER;
BEGIN
--
  BIS_DEBUG_PUB.Add('> put_decode_statement_lang');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  BIS_DEBUG_PUB.Add('> put_decode_statement');
  BIS_DEBUG_PUB.Add('p_lookup_column = ' || p_lookup_column);
  BIS_DEBUG_PUB.Add('p_lookup_table = ' || p_lookup_table);
  BIS_DEBUG_PUB.Add('p_lookup_type = ' || p_lookup_type);
  BIS_DEBUG_PUB.Add('p_expr = ' || p_expr);
  BIS_DEBUG_PUB.Add('p_language = ' || p_language);
  -- select statement
  l_select := get_select_statement( p_lookup_table
                                     , p_lookup_type
                                     , p_lookup_column
				     , x_return_status
				     , x_error_Tbl
                                       );
  -- add the language restraint
  l_select := l_select || ' and language = '''|| p_language ||'''';
--
  BIS_DEBUG_PUB.Add(' l_select = '||l_select);
--
--   write the decode statement
  write_decode_statement ( p_expr
                         , l_select
			 , x_select_table
			 , x_return_status
			 , x_error_Tbl
			 );
--
  BIS_DEBUG_PUB.Add('< put_decode_statement_lang');
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
	  , p_error_proc_name   => G_PKG_NAME||'.put_decode_statement_lang'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END put_decode_statement_lang;
--
/* ============================================================================
PROCEDURE : put_decode_statement_languages
  PARAMETERS:
  1. p_expr               pl/sql expression for decode
  2. p_lookup_table       lookup table name
  3. p_lookup_type        lookup type;
  4. p_lookup_column      lookup column in the table to be returned
  5. x_Select_Table       table of varchars to hold additional select
                          (select table)
  6. x_return_status    error or normal
  7. x_error_Tbl        table of error messages
--
  COMMENT   : Call this procedure to add a particular decode lookup
              information to a view.
EXCEPTION : None
  ===========================================================================*/
PROCEDURE put_decode_statement_languages
    ( p_expr          IN  VARCHAR2
    , p_lookup_table  IN  VARCHAR2
    , p_lookup_type   IN  VARCHAR2
    , p_lookup_column IN  VARCHAR2
    , x_Select_Table  OUT BIS_VG_TYPES.View_Text_Table_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_select      VARCHAR2(1000);
l_cursor_id   INTEGER;
l_language    VARCHAR2(250);
l_dummy       INTEGER;
BEGIN
  BIS_DEBUG_PUB.Add('> put_decode_statement_languages');
  -- open the cursor
  l_cursor_id := dbms_sql.open_cursor;
--
  -- select statement
  l_select := 'select language from :table_name' ||
                  'where lookup_type = :type';
--
  -- parse the statement
  dbms_sql.parse(l_cursor_id, l_select, dbms_sql.NATIVE);
--
  -- bind the inout variables
  dbms_sql.bind_variable(l_cursor_id, ':table_name', p_lookup_table);
  dbms_sql.bind_variable(l_cursor_id, ':type', p_lookup_type);
--
  -- define output variables
  dbms_sql.define_column(l_cursor_id, 1, l_language, 250);
--
  -- execute
  l_dummy := dbms_sql.execute(l_cursor_id);
--
  -- start the decode statement
  x_select_table(x_select_table.COUNT + 1) := 'DECODE';
  x_select_table(x_select_table.COUNT + 1) := '( USERENV(''LANG'')';
--
  WHILE (dbms_sql.fetch_rows(l_cursor_id) <> 0) LOOP
--
        dbms_sql.column_value(l_cursor_id, 1, l_language);
--
        -- get the language
     x_select_table(x_select_table.COUNT + 1) := ', '||l_language;
--
        -- put the decode for that language
     put_decode_statement_lang ( p_expr
                               , p_lookup_table
			       , p_lookup_type
			       , p_lookup_column
			       , l_language
			       , x_Select_Table
			       , x_return_status
			       , x_error_Tbl
			       );
--
  END LOOP;
--
  -- end the decode statement
  x_select_table(x_select_table.COUNT + 1) := ', NULL )';
--
  dbms_sql.close_cursor(l_cursor_id);
  BIS_DEBUG_PUB.Add('< put_decode_statement_languages');
--



EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      dbms_sql.close_cursor(l_cursor_id);
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      dbms_sql.close_cursor(l_cursor_id);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      dbms_sql.close_cursor(l_cursor_id);
      BIS_VG_UTIL.Add_Error_Message
	( p_error_msg_id      => SQLCODE
	  , p_error_description => SQLERRM
	  , p_error_proc_name   => G_PKG_NAME||'.put_decode_statement_languages'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
      );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END put_decode_statement_languages;
--
/* ============================================================================
FUNCTION : check_language
  PARAMETERS:
  1. p_lookup_table       lookup table name
  2. x_return_status    error or normal
  3. x_error_Tbl        table of error messages
  RETURN  : BOOLEAN - TRUE if mutli language supported
  COMMENT : Call this procedure to find out if multi language is supported
EXCEPTION : None
  ===========================================================================*/
FUNCTION check_language
    ( p_lookup_table IN VARCHAR2
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
RETURN BOOLEAN
IS
CURSOR col_cursor IS
   SELECT 1
   FROM user_tab_columns
   WHERE table_name=p_lookup_table
        AND column_name='LANGUAGE';
l_return_value boolean;
l_dummy        number;
BEGIN

  open  col_cursor;
  fetch col_cursor into l_dummy ;
  l_return_value := col_cursor%found ;
  close col_cursor ;

  return(l_return_value);
--


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      if (col_cursor%ISOPEN) THEN
          CLOSE col_cursor;
      end if;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      if (col_cursor%ISOPEN) THEN
          CLOSE col_cursor;
      end if;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      if (col_cursor%ISOPEN) THEN
	 CLOSE col_cursor;
      end if;
      BIS_VG_UTIL.Add_Error_Message
	( p_error_msg_id      => SQLCODE
	  , p_error_description => SQLERRM
	  , p_error_proc_name   => G_PKG_NAME||'.check_language'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END check_language;
--
/* ============================================================================
PROCEDURE : add_select_info
  PARAMETERS:
  1. p_expr               pl/sql expression for decode
  2. p_lookup_table       lookup table name
  3. p_lookup_type        lookup type;
  4. p_lookup_column      lookup column in the table to be returned
  5. x_Select_Table       table of varchars to hold additional select
                          (select table)
  6. x_return_status    error or normal
  7. x_error_Tbl        table of error messages
--
  COMMENT   : Call this procedure to add a particular lookup select
              information to a view.
EXCEPTION : None
  ===========================================================================*/
PROCEDURE add_select_info
   ( p_expr          IN  VARCHAR2
   , p_lookup_table  IN  VARCHAR2
   , p_lookup_type   IN  VARCHAR2
   , p_lookup_column IN  VARCHAR2
   , x_Select_Table  OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
IS
l_lang BOOLEAN := FALSE;
BEGIN
  BIS_DEBUG_PUB.Add('> add_select_info');
--
  -- find if the language is supported for this lookup
  l_lang := check_language(p_lookup_table, x_return_status, x_error_Tbl);
--
  -- debug info
  IF (l_lang = TRUE) THEN
        BIS_DEBUG_PUB.Add('language is there for table '||p_lookup_table);
--
        put_decode_statement_languages( p_expr
                                      , p_lookup_table
                                      , p_lookup_type
                                      , p_lookup_column
                                      , x_select_table
				      , x_return_status
				      , x_error_Tbl
                                      );
--
   ELSE
        BIS_DEBUG_PUB.Add('language not there in table '||p_lookup_table);
--
     -- now put in the decode statement
     put_decode_statement( p_expr
                            , p_lookup_table
                            , p_lookup_type
                            , p_lookup_column
                            , x_select_table
			    , x_return_status
			    , x_error_Tbl
                            );
  END IF;
  BIS_DEBUG_PUB.Add('< add_select_info');
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
	  , p_error_proc_name   => G_PKG_NAME||'.add_select_info'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_select_info;
--
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
)
IS
l_str           VARCHAR2(2000);
l_tmp_pointer          bis_vg_types.View_Character_Pointer_Type;
BEGIN

   BIS_DEBUG_PUB.Add('> parse_LA_select');
   -- skip the _LA part
   l_str := bis_vg_parser.Skip_Tag( p_View_Select_Table
                                   , p_select_pointer
                                   , x_select_pointer
				   , x_return_status
				   , x_error_Tbl
                                   );
  l_str := bis_vg_parser.get_expression( p_View_Select_Table
                                                 , p_Select_Pointer
                                                 , l_tmp_pointer
						 , x_return_status
						 , x_error_Tbl
					       );
  IF (bis_vg_util.equal_pointers(
				 l_tmp_pointer
				 , x_select_pointer
				 , x_return_status
				 , x_error_Tbl
				 )
      ) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_lookup.LAT_COL_TAG_EXP_NO_EXP_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_LA_select'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1          => 'tag'
	 , p_value1         =>  l_str
	 , p_error_table       => x_error_tbl
	 , x_error_table       => x_error_tbl
	 );
     bis_vg_log.update_failure_log( x_error_tbl
				    , x_return_status
				    , x_error_Tbl
				    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_tmp_pointer :=   bis_vg_util.increment_pointer
      ( p_View_Select_Table
	, l_tmp_pointer
	, x_return_status
	, x_error_Tbl
	);

  -- get the expression
  x_expr := bis_vg_parser.get_token_increment_pointer( p_View_Select_Table
                                                        , x_select_pointer
                                                        , ':'
                                                        , x_select_pointer
							, x_return_status
							, x_error_Tbl
                                                        );
  --
  IF (x_expr IS NULL
      OR
      bis_vg_util.equal_pointers(
				 l_tmp_pointer
				 , x_select_pointer
				 , x_return_status
				 , x_error_Tbl
				 )
      ) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_lookup.LAT_COL_TAG_EXP_NO_EXP_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_LA_select'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1          => 'tag'
	 , p_value1         =>  l_str
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
  -- replace two consecutive single quotes by one single quote
  x_expr := REPLACE(x_expr, '''''', '''');
  BIS_DEBUG_PUB.Add('x_expr = '||x_expr);
--
  -- get the lookup table
  x_lookup_table := bis_vg_parser.get_token_increment_pointer
                                 ( p_View_Select_Table
                                    , x_select_pointer
                                    , ':'''
                                    , x_select_pointer
				    , x_return_status
				    , x_error_Tbl
                                    );
  BIS_DEBUG_PUB.Add('x_lookup_table = '||x_lookup_table);
--
  IF (x_lookup_table IS NULL
      OR
      bis_vg_util.equal_pointers(
				 l_tmp_pointer
				 , x_select_pointer
				 , x_return_status
				 , x_error_Tbl
				 )
      ) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_lookup.LAT_SEL_TAG_EXP_NO_TABLE_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_LA_select'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1          => 'tag'
	 , p_value1         =>  l_str
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
  -- get the lookup type
  x_lookup_type := bis_vg_parser.get_token_increment_pointer
                                ( p_View_Select_Table
                                   , x_select_pointer
                                   , ':'''
                                   , x_select_pointer
				   , x_return_status
				   , x_error_Tbl
                                   );
  BIS_DEBUG_PUB.Add('x_lookup_type = '||x_lookup_type);
--
  IF (x_lookup_type IS NULL
            OR
      bis_vg_util.equal_pointers(
				 l_tmp_pointer
				 , x_select_pointer
				 , x_return_status
				 , x_error_Tbl
				 )
      ) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_lookup.LAT_SEL_TAG_EXP_NO_TYPE_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_LA_select'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1          => 'tag'
	 , p_value1         =>  l_str
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
  -- get the lookup column
  x_lookup_column := bis_vg_parser.get_token_increment_pointer
                                  ( p_View_Select_Table
                                     , x_select_pointer
                                     , ''''
                                     , x_select_pointer
				     , x_return_status
				     , x_error_Tbl
                                     );
--
  BIS_DEBUG_PUB.Add('x_lookup_column = '||x_lookup_column);
--
  IF (x_lookup_column IS NULL
      ) THEN
     BIS_VG_UTIL.Add_Error_message
       ( p_error_msg_name => bis_vg_lookup.LAT_SEL_TAG_EXP_NO_COL_MSG
	 , p_error_proc_name   => G_PKG_NAME||'.parse_LA_select'
	 , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	 , p_token1          => 'tag'
	 , p_value1         =>  l_str
	 , p_error_table       => x_error_tbl
	 , x_error_table       => x_error_tbl
	 );
     bis_vg_log.update_failure_log( x_error_tbl
				    , x_return_status
				    , x_error_Tbl
				    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

    BIS_DEBUG_PUB.Add('Parse_LA_Select  Tag = '|| l_str);


    BIS_DEBUG_PUB.Add('< parse_LA_select');
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
	  , p_error_proc_name   => G_PKG_NAME||'.parse_LA_select'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END parse_LA_select;


-- ============================================================================
-- FUNCTION: check_lookup_exists  (PRIVATE FUNCTION)
-- RETURNS: boolean - true if the lookup table exists and has the column named
--  1. p_table the name of the table
--  2. p_column the name of the column in the table
--
-- COMMENT  : Checks that the column/table combination is defined in the
--            database.  Does not ckeck for complete lookup validity.
-- EXCEPTION : None
--  ==========================================================================
FUNCTION CHECK_LOOKUP_EXISTS
  (  p_table    IN VARCHAR2
     , p_column IN VARCHAR2
     )
  return boolean
  is
     l_return_value boolean ;
     l_dummy        number;
     l_object_type  varchar2(30);
     cursor l_object_cursor is
     select object_type
          from user_objects
          where object_name = UPPER(p_table);
     cursor l_tab_view_cursor is
     select 1
 	  from   all_tab_columns
 	  where  table_name = UPPER(p_table)
 	  and    column_name = UPPER(p_column)
 	  and owner = user;
     cursor l_tab_syn_cursor is
	select 1
	  from   all_tab_columns a, user_synonyms u
	  where  a.table_name = UPPER(p_table)
	  and    u.table_name = UPPER(p_table)
	  and    a.owner = u.table_owner
	  and    a.column_name = UPPER(p_column) ;
begin
   BIS_DEBUG_PUB.Add('> check_lookup_exists');
   BIS_DEBUG_PUB.Add('Table = '|| p_table);
   BIS_DEBUG_PUB.Add('Column = '|| p_column);
   open l_object_cursor;
   fetch l_object_cursor into l_object_type;
   close l_object_cursor;
   if l_object_type='VIEW' then
     open l_tab_view_cursor ;
     fetch l_tab_view_cursor into l_dummy ;
     l_return_value :=  l_tab_view_cursor%found;
     close l_tab_view_cursor ;
     BIS_DEBUG_PUB.Add('< check_lookup_exists');
     return(l_return_value);
   elsif l_object_type='SYNONYM' then
     open l_tab_syn_cursor ;
     fetch l_tab_syn_cursor into l_dummy ;
     l_return_value :=  l_tab_syn_cursor%found;
     close l_tab_syn_cursor ;
     BIS_DEBUG_PUB.Add('< check_lookup_exists');
     return(l_return_value);
   else
     BIS_DEBUG_PUB.Add('check_lookup_exists returned '||NVL(l_object_type,'NULL')||'object type');
     return FALSE;
   end if;

END CHECK_LOOKUP_EXISTS;


-- ============================================================================
--PROCEDURE : put_decode_in_select
--  PARAMETERS:
--  1. p_View_Select_Table  table of varchars to hold select OF view text
--  2. p_Select_Pointer     pointer to the lookup column in select table
--  3. p_Mode               mode of execution of program
--  3. x_Select_Table       table of varchars to hold additional select
--  4. x_Select_Pointer     pointer to the character after the delimiter
--                          (select table)
--  5. x_return_status    error or normal
--  6. x_error_Tbl        table of error messages
----
--  COMMENT   : Call this procedure to add a particular lookup select
--              information to a view.
-- EXCEPTION : None
--  ==========================================================================
PROCEDURE put_decode_in_select
   ( p_View_Select_Table IN  BIS_VG_TYPES.View_Text_Table_Type
   , p_Select_Pointer    IN  BIS_VG_TYPES.View_Character_Pointer_Type
   , p_Mode              IN  NUMBER
   , x_Select_Table      OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_Select_Pointer    OUT BIS_VG_TYPES.View_Character_Pointer_Type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
IS
l_expr          VARCHAR2(2000);
l_tag           VARCHAR2(3000);
l_lookup_table  VARCHAR2(100);
l_lookup_type   VARCHAR2(1000);
l_lookup_column VARCHAR2(100);

BEGIN
   BIS_DEBUG_PUB.Add('> put_decode_in_select');

   parse_LA_select ( p_View_Select_Table
		     , p_Select_Pointer
		     , l_expr
		     , l_lookup_table
		     , l_lookup_type
		     , l_lookup_column
		     , x_Select_Pointer
		     , x_return_status
		     , x_error_Tbl

		     );

   l_tag := bis_vg_util.get_string ( p_View_Select_Table
				     , p_Select_Pointer
				     , x_Select_Pointer
				     , x_return_status
				     , x_error_Tbl
				     );

  IF(p_Mode = bis_vg_types.remove_tags_mode) THEN
    x_select_table(1) := 'TO_CHAR(NULL)';
   ELSE
     -- Check for existence of table and column
     IF check_lookup_exists(l_lookup_table, l_lookup_column)
       THEN
	add_select_info( l_expr
			 , l_lookup_table
			 , l_lookup_type
			 , l_lookup_column
			 , x_select_table
			 , x_return_status
			 , x_error_Tbl
			 );
      ELSE
	-- The lookup table either does not exist
	--  or does not contain the column demanded
	BIS_VG_UTIL.Add_Error_message
	  ( p_error_msg_name => bis_vg_lookup.LAT_SEL_TAG_UNDEF_TAB
	    , p_error_proc_name   => G_PKG_NAME||'.put_decode_in_select'
	    , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	    , p_token1 =>   'tab'
	    , p_value1 =>   l_lookup_table
	    , p_token2  =>   'col'
	    , p_value2  =>   l_lookup_column
	    , p_token3  =>  'tag'
	    , p_value3 =>  l_tag
	    , p_error_table       => x_error_tbl
	    , x_error_table       => x_error_tbl
	    );
	bis_vg_log.update_failure_log( x_error_tbl
				       , x_return_status
				       , x_error_Tbl
				       );
	RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;
--
  BIS_DEBUG_PUB.Add('> put_decode_in_select');
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
	  , p_error_proc_name   => G_PKG_NAME||'.put_decode_in_select'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END put_decode_in_select;
--
/* ============================================================================
PROCEDURE : add_Lookup_Info
  PARAMETERS:
  1. p_View_Column_Table  table of varchars to hold columns OF view text
  2. p_View_Select_Table  table of varchars to hold SELECT clause of view
  3. p_Mode               mode of execution of the program
  4. p_Column_Pointer     pointer to the lookup column in column table
  5. p_Select_Pointer     pointer to the select clause
  6. x_Column_Table       table of varchars to hold additional columns
  7. x_Select_Table       table of varchars to hold additional columns
  8. x_Column_Pointer     pointer to the character after the delimiter
                          (column table)
  9. x_Select_Pointer     pointer to the character after the delimiter
                          (select table)
 10. x_return_status    error or normal
 11. x_error_Tbl        table of error messages
--
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
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
BEGIN
  BIS_DEBUG_PUB.Add('> add_Lookup_Info :-)');
--
  put_column_name( p_view_column_table
                 , p_column_pointer
                 , p_Mode
                 , x_column_table
                 , x_column_pointer
		 , x_return_status
		 , x_error_Tbl
                 );
--
  put_decode_in_select( p_view_select_table
                      , p_select_pointer
                      , p_Mode
                      , x_select_table
                      , x_select_pointer
		      , x_return_status
		      , x_error_Tbl
                      );
--
--  bis_vg_util.print_view_text(x_column_table, x_return_status, x_error_Tbl);
--  bis_vg_util.print_view_text(x_select_table, x_return_status, x_error_Tbl);
--
  BIS_DEBUG_PUB.Add('< add_Lookup_Info :-(');
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
	  , p_error_proc_name   => G_PKG_NAME||'.add_Lookup_Info'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_Lookup_Info;
--
END bis_vg_lookup;

/
