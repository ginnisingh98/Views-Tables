--------------------------------------------------------
--  DDL for Package Body BIS_VG_PARSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_PARSER" AS
/* $Header: BISTPARB.pls 115.7 2002/03/27 08:18:43 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTPARB.pls
--
--  DESCRIPTION
--
--      body of view parser to be used in the view generator
--         package specifyling the view security
--
--  NOTES
--
--  HISTORY
--
--  21-JUL-98 Created
--  19-MAR-99 Edited by WNASRALL@US for exception handling
--  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
--
g_max_number CONSTANT NUMBER := 100000000000000000000000;
G_PKG_NAME CONSTANT VARCHAR(30) := 'BIS_VG_PARSER';
--========================================================
-- replaces the selected portion WITH blanks
-- start and end are included
FUNCTION put_blanks
( p_string  IN VARCHAR2
, start_num IN NUMBER
, end_num   IN NUMBER
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
l_temp VARCHAR2(2000);
l_str  VARCHAR2(2000);
BEGIN
   BIS_DEBUG_PUB.Add ('> put_blanks');
  -- BIS_DEBUG_PUB.Add ('begin string is '||p_string);
  -- BIS_DEBUG_PUB.Add ('start_num = '||start_num||' end num = '||end_num);
--
  FOR j IN start_num .. end_num loop
    l_temp := l_temp || ' ';
  END LOOP;
--
  l_str :=  Substr(p_string, 1, start_num - 1);
  l_str := l_str || l_temp;
--
  IF (end_num < Length(p_string)) THEN
    l_temp := Substr(p_string, end_num + 1, Length(p_string));
    l_str := l_str||l_temp;
  END IF;
  -- BIS_DEBUG_PUB.Add ('end string is '||l_str);
  BIS_DEBUG_PUB.Add ('< put_blanks ');
  RETURN l_str;


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
      , p_error_proc_name   => G_PKG_NAME||'.put_blanks'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END put_blanks;
--
-- find the comments and replace them with blanks
FUNCTION replace_comments_with_blanks
( p_string     IN  VARCHAR2
, p_in_comment IN  BOOLEAN
, x_in_comment OUT BOOLEAN
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
l_done      BOOLEAN := FALSE;
l_start_pos NUMBER;
l_end_pos   NUMBER;
l_string    VARCHAR2(2000);
l_first     BOOLEAN := TRUE;
l_open_pos  NUMBER;
l_close_pos NUMBER;
BEGIN
   BIS_DEBUG_PUB.Add('> replace_comments_with_blanks');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_string := p_string;

--   l_start_pos := Instr(l_string, '--');
--   IF (l_start_pos <> 0) THEN
--     l_string := Substr(l_string, 1, l_start_pos);
--   END IF;
--
   x_in_comment := p_in_comment;
   WHILE (l_done = false) LOOP
     l_open_pos :=  Instr(l_string, '/*');
     l_close_pos := Instr(l_string, '*/');
     IF (l_open_pos = 0) THEN
        -- no open comments
        IF (l_close_pos = 0) THEN
          -- no close comments
          IF (x_in_comment = TRUE) THEN
            -- we are in comment mode
            IF (l_first = TRUE) THEN
              -- just entered, blank out the entire line
               l_string := '';
            END IF;
            -- done
          END IF;
          -- no start or end, done
          l_done := TRUE;
        ELSE
          -- end pos is not zero, blank till end of comment
          l_string := put_blanks(l_string
	  			, 1
				, l_close_pos + 1
				, x_return_status
				, x_error_Tbl
				);
          x_in_comment := FALSE;
        END IF;
     ELSE
       -- there is an open comment
       IF (l_close_pos = 0) THEN
          -- no close comments
          l_string := put_blanks ( l_string
	  			 , l_open_pos
				 , Length(l_string)
				 , x_return_status
				 , x_error_Tbl
				 );
          x_in_comment := TRUE;
          l_done := TRUE;
       ELSE
          IF (l_open_pos < l_close_pos) THEN
            l_string := put_blanks ( l_string
	    			   , l_open_pos
				   , l_close_pos + 1
				   , x_return_status
				   , x_error_Tbl
				   );
          ELSE
            l_string := put_blanks ( l_string
	    			   , 1
				   , l_close_pos + 1
				   , x_return_status
				   , x_error_Tbl
				   );
          END IF;
          x_in_comment := FALSE;
       END IF;
     END IF;
   END LOOP;
   BIS_DEBUG_PUB.Add('< replace_comments_with_blanks');
   RETURN l_string;


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
      , p_error_proc_name   => G_PKG_NAME||'.replace_comments_with_blanks'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END replace_comments_with_blanks;
--
FUNCTION Get_Keyword_Position
( p_view_table    IN bis_vg_types.View_Text_Table_Type
, p_string_set    IN bis_vg_types.View_Text_Table_Type
, p_start_pointer IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN bis_vg_types.view_character_pointer_type
IS
l_pos      NUMBER;
l_min_pos  NUMBER;
total_rows NUMBER;
l_string   VARCHAR2(2000);
l_temp     VARCHAR2(2000);
l_pointer  bis_vg_types.view_character_pointer_type := NULL;
l_in_comment BOOLEAN := FALSE;
BEGIN
   BIS_DEBUG_PUB.Add ('> Get_Keyword_Position ');
   total_rows := p_view_table.COUNT;
--
   bis_vg_util.print_view_pointer(p_start_pointer, x_return_status, x_error_Tbl);
--
   FOR i IN 1 .. p_string_set.COUNT LOOP
     BIS_DEBUG_PUB.Add ('string set '||i||' is '||p_string_set(i));
   END LOOP;

   l_min_pos := g_max_number;
   l_pos     := 0;
   FOR i IN p_start_pointer.row_num .. total_rows LOOP
     l_string := p_view_table(i);
--
     IF (i = p_start_pointer.row_num) THEN
        -- we are AT the beginning,
        -- make sure that we only take the relevant part
        -- blank OUT the rest
        IF (p_start_pointer.col_num > 1) THEN
          l_string := put_blanks( l_string
	  			, 1
				, p_start_pointer.col_num - 1
				, x_return_status
				, x_error_Tbl
				);
        END IF;
     END IF;
--
     BIS_DEBUG_PUB.Add ('string is '||l_string);
     -- REPLACE ALL the comments WITH blanks
     l_string := replace_comments_with_blanks( l_string
                                             , l_in_comment
                                             , l_in_comment
					     , x_return_status
					     , x_error_Tbl
					     );
--
     -- find the earliest occuring string
     FOR j IN 1 .. p_string_set.COUNT LOOP
        BIS_DEBUG_PUB.Add ('comparing string is '||p_string_set(j));
        l_pos := Instr(Upper(l_string), Upper(p_string_set(j)));
--
        BIS_DEBUG_PUB.Add ('string occurrence at '||l_pos);
        IF (l_pos <> 0) THEN
           IF (l_pos < l_min_pos) THEN
              BIS_DEBUG_PUB.Add ('l_pos '||l_pos||
                                 ' less than l_min '|| l_min_pos);
              l_min_pos := l_pos;
           END IF;
        END IF;
     END LOOP;

     BIS_DEBUG_PUB.Add ('l_min is '||l_min_pos);

     -- we found the string. set up the end pointer and return
     IF (l_min_pos <> g_max_number) THEN
       l_pointer.row_num := i;
       l_pointer.col_num := l_min_pos;
       BIS_DEBUG_PUB.Add ('returning with a valid pointer');
       bis_vg_util.print_view_pointer(l_pointer, x_return_status, x_error_Tbl);
       BIS_DEBUG_PUB.Add ('< Get_Keyword_Position');
       RETURN l_pointer;
     END IF;

   END LOOP;
   bis_vg_util.print_view_pointer(l_pointer, x_return_status, x_error_Tbl);
   BIS_DEBUG_PUB.Add ('< Get_Keyword_Position');
   RETURN l_pointer;

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
      , p_error_proc_name   => G_PKG_NAME||'.Get_Keyword_Position'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Keyword_Position;

FUNCTION get_string_token
( p_view_str         IN  bis_vg_types.View_Text_Table_Rec_Type
, p_start            IN  NUMBER
, p_delimiter_string IN  VARCHAR2
, x_end_pointer      OUT NUMBER
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
l_str        VARCHAR2(2000);
l_char       VARCHAR2(1);
l_end        NUMBER;
l_start      NUMBER;
l_total      NUMBER;
l_pos        NUMBER := 0;
l_delimiters VARCHAR2(100);
BEGIN
   BIS_DEBUG_PUB.Add('> get_string_token');
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_start := p_start;
   l_total := Length(p_view_str);
   x_end_pointer := l_start;
   l_delimiters  := Upper(p_delimiter_string);
   WHILE (   l_pos = 0
         AND x_end_pointer IS NOT NULL
         AND x_end_pointer <= l_total) LOOP

      l_char := Substr(p_view_str, x_end_pointer, 1);
      l_pos := Instr(l_delimiters, Upper(l_char));
      BIS_DEBUG_PUB.Add('l_char = '||l_char||' l_pos = '||l_pos);
      IF (l_pos = 0) then
        x_end_pointer := x_end_pointer + 1;
      END IF;
   END LOOP;

   l_str := Substr(p_view_str, l_start, x_end_pointer - l_start);

   -- skip the delimiter
   IF (x_end_pointer >= l_total) THEN
      x_end_pointer := NULL;
   ELSE
     WHILE (    l_pos <> 0
           AND x_end_pointer IS NOT NULL
           AND x_end_pointer <= l_total) LOOP

        l_char := Substr(p_view_str, x_end_pointer, 1);
        l_pos := Instr(l_delimiters, Upper(l_char));
        BIS_DEBUG_PUB.Add('l_char = '||l_char||' l_pos = '||l_pos);
        IF (l_pos <> 0) then
          x_end_pointer := x_end_pointer + 1;
        END IF;
     END LOOP;
   END IF;

   BIS_DEBUG_PUB.Add('< get_string_token');
   RETURN l_str;


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
      , p_error_proc_name   => G_PKG_NAME||'.get_string_token'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_string_token;

FUNCTION get_token
( p_view_table       IN  bis_vg_types.View_Text_Table_Type
, p_start_pointer    IN  bis_vg_types.View_Character_Pointer_Type
, p_delimiter_string IN  VARCHAR2
, x_end_pointer      OUT bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
l_str_table  bis_vg_types.view_text_table_type;
l_length     NUMBER;
l_temp       VARCHAR2(2000);
l_char       VARCHAR2(1);
l_pos        NUMBER := 0;
l_delimiters VARCHAR2(100);
BEGIN
   BIS_DEBUG_PUB.Add('> get_token');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_temp := NULL;
   BIS_VG_UTIL.print_view_pointer(p_start_pointer, x_return_status, x_error_Tbl);
   x_end_pointer := p_start_pointer;
   l_delimiters := Upper(p_delimiter_string);
   WHILE (l_pos = 0 AND x_end_pointer.row_num IS NOT null) loop
      l_char := BIS_VG_UTIL.get_char( p_view_table
      				    , x_end_pointer
				    , x_return_status
				    , x_error_Tbl
				    );
      l_pos := Instr(l_delimiters, Upper(l_char));
      BIS_DEBUG_PUB.Add('l_char = '||l_char||' l_pos = '||l_pos);
      IF (l_pos = 0) then
        x_end_pointer := BIS_VG_UTIL.increment_pointer( p_view_table
                                                      , x_end_pointer
						      , x_return_status
						      , x_error_Tbl
                                                      );
      END IF;
      bis_vg_util.print_view_pointer( x_end_pointer
      				    , x_return_status
				    , x_error_Tbl
				    );
   end loop;
   BIS_DEBUG_PUB.Add('out of loop');
   l_temp := bis_vg_util.get_string( p_view_table
                                   , p_start_pointer
                                   , x_end_pointer
				   , x_return_status
				   , x_error_Tbl
				   );
   BIS_VG_UTIL.print_view_pointer(x_end_pointer, x_return_status, x_error_Tbl);
   BIS_DEBUG_PUB.Add('< get_token');
   RETURN l_temp;


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
      , p_error_proc_name   => G_PKG_NAME||'.get_token'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_token;


FUNCTION get_token_increment_pointer
( p_view_table       IN  bis_vg_types.View_Text_Table_Type
, p_start_pointer    IN  bis_vg_types.View_Character_Pointer_Type
, p_delimiter_string IN  VARCHAR2
, x_end_pointer      OUT bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
l_temp        VARCHAR2(1000);
l_CHAR        VARCHAR2(10);
l_pos         NUMBER := 1;
l_delimiters  VARCHAR2(100);
BEGIN

   BIS_DEBUG_PUB.Add('> get_token_increment_pointer');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   BIS_VG_UTIL.print_View_Pointer(p_start_pointer, x_return_status, x_error_Tbl);
   l_temp := get_token( p_view_table
                      , p_start_pointer
                      , p_delimiter_string
                      , x_end_pointer
		      , x_return_status
		      , x_error_Tbl
                      );
   BIS_VG_UTIL.print_View_Pointer(x_end_pointer, x_return_status, x_error_Tbl);
   l_delimiters := Upper(p_delimiter_string);
   WHILE (l_pos <> 0 AND x_end_pointer.row_num IS NOT null) loop
      l_char := BIS_VG_UTIL.get_char ( p_View_Table
      				     , x_end_pointer
				     , x_return_status
				     , x_error_Tbl
				     );
      l_pos := Instr(l_delimiters, Upper(l_char));
      IF (l_pos <> 0) THEN
         x_end_pointer := BIS_VG_UTIL.increment_pointer( p_View_Table
                                                       , x_end_pointer
						       , x_return_status
						       , x_error_Tbl
                                                       );
      END IF;
   end loop;
   BIS_DEBUG_PUB.Add('< get_token_increment_pointer');
   RETURN l_temp;


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
      , p_error_proc_name   => G_PKG_NAME||'.get_token_increment_pointer'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_token_increment_pointer;

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
RETURN VARCHAR2
IS
l_done           BOOLEAN := FALSE;
l_str            VARCHAR2(2000);
l_delimiter      VARCHAR2(1) := '''';
l_temp_pointer   bis_vg_types.View_Character_Pointer_Type;
BEGIN
   BIS_DEBUG_PUB.Add('> get_expression');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_end_pointer := p_start_pointer;
   WHILE (l_done = FALSE) LOOP
     -- find the single quote incrementing the pointer
     l_str := get_token( p_view_table
                       , x_end_pointer
                       , l_delimiter
                       , x_end_pointer
		       , x_return_status
		       , x_error_Tbl
                       );

     -- increment pointer to just beyond
     l_temp_pointer := bis_vg_util.increment_pointer( p_view_table
                                                    , x_end_pointer
						    , x_return_status
						    , x_error_Tbl
                                                    );

     IF (bis_vg_util.get_char( p_view_table
     			     , l_temp_pointer
			     , x_return_status
			     , x_error_Tbl
			     )
			     <> l_delimiter)
      THEN
        -- we do not have two quotes one after another
        -- valid delimiter, done
        l_done := TRUE;
      ELSE
        -- invalid delimiter. increment and continue
        x_end_pointer := bis_vg_util.increment_pointer( p_view_table
                                                        , l_temp_pointer
                                                        , x_return_status
							, x_error_Tbl
							);

     END IF;
   END LOOP;
   BIS_DEBUG_PUB.Add('< get_expression');
   RETURN bis_vg_util.get_string ( p_view_table
   				 , p_start_pointer
				 , x_end_pointer
				 , x_return_status
				 , x_error_Tbl
				 );

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
      , p_error_proc_name   => G_PKG_NAME||'.get_expression'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_expression;

-- skips the type of tag
-- returns the tag
-- the out pointer is positioned beyond the separator
FUNCTION skip_tag
( p_View_Table    IN  BIS_VG_TYPES.View_Text_Table_Type
, p_start_pointer IN  BIS_VG_TYPES.view_character_pointer_type
, X_end_pointer   OUT BIS_VG_TYPES.view_character_pointer_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
l_str VARCHAR2(100);
BEGIN
  -- get the tag
  BIS_DEBUG_PUB.Add('> skip_tag');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_str := bis_vg_parser.get_token_increment_pointer( p_view_table
                                                    , p_start_pointer
                                                    , ':'
                                                    , x_end_pointer
						    , x_return_status
						    , x_error_Tbl
                                                    );
  BIS_DEBUG_PUB.Add('< skip_tag');
  RETURN l_str;


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
      , p_error_proc_name   => G_PKG_NAME||'.skip_tag'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END skip_tag;

END BIS_VG_PARSER;

/
