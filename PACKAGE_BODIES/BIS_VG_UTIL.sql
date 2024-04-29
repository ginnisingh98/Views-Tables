--------------------------------------------------------
--  DDL for Package Body BIS_VG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_UTIL" AS
/* $Header: BISTUTLB.pls 115.12 2003/06/02 14:52:42 dbowles ship $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTUTLB.pls
--
--  DESCRIPTION
--
--      body of view generator utils to be used in the view generator
--         package specifyling the view security
--
--  NOTES
--
--  HISTORY
--
--  21-JUL-98 Created
--  06-APR-01 Edited by DBOWLES  Added new function find_Flex_Prompt.
--            function returns the translated form prompt for the flex segment.
--            Added overloaded procedure concatenate_Tables to accept
--            types of BIS_VG_TYPES.Flex_Column_Comment_Table_Type.
--  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
--
G_PKG_NAME CONSTANT VARCHAR(30) := 'BIS_VG_UTIL';
-- ============================================================================
-- FUNCTION  : is_char_delimiter
-- PARAMETERS:
-- 1. p_character  a valid character
-- 2. x_return_status    error or normal
-- 3. x_error_Tbl        table of error messages
--
-- COMMENT   : Call this function to find out if the character is a delimiter
-- EXCEPTION : None
-- ============================================================================
   FUNCTION is_char_delimiter
   ( p_character IN VARCHAR2
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   RETURN BOOLEAN IS
--
   BEGIN
     BIS_DEBUG_PUB.Add('> is_char_delimiter');
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF( p_character = ' '
--      OR p_character = '      '
      OR p_character = ','
      OR p_character = '-'
       ) THEN
       BIS_DEBUG_PUB.Add('return TRUE');
       BIS_DEBUG_PUB.Add('< is_char_delimiter');
       RETURN TRUE;
     ELSE
       bis_debug_pub.Add('char = <' || p_character || '>');
       BIS_DEBUG_PUB.Add('return FALSE');
       BIS_DEBUG_PUB.Add('< is_char_delimiter');
       RETURN FALSE;
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
      , p_error_proc_name   => G_PKG_NAME||'.is_char_delimiter'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END is_char_delimiter;
--
--
PROCEDURE create_Text_Table
( p_String     IN  VARCHAR2
, x_View_Table OUT bis_vg_types.View_Text_Table_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_beg_pos        NUMBER := 1;
l_pos            NUMBER := 0;
l_string_len     NUMBER;
l_chunk_size     NUMBER := 200;
l_beg_string     VARCHAR2(200);
l_end_string     VARCHAR2(200) := NULL;
l_string         VARCHAR2(200);
l_old_chunk_size NUMBER;
--
BEGIN
  bis_debug_pub.Add('> create_Text_Table');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_string_len := LENGTH(p_String);
  IF(l_string_len <= l_chunk_size) THEN
  -- string can be stored in one row of table
    x_View_Table(1) := p_String;
  ELSE
    LOOP
      -- take string og length l_chunk_size from l_beg_pos
      l_string := SUBSTR(p_string, l_beg_pos, l_chunk_size);
      l_old_chunk_size := l_chunk_size;
      bis_debug_pub.add('length of l_string = ' || LENGTH(l_string));
      bis_debug_pub.add('l_string = ' || l_string);
      IF( LENGTH(l_string) < l_chunk_size ) THEN
        -- string can be stored in one row of table;
        -- prepend l_end_string from previous iteration
        x_View_Table(x_View_Table.COUNT + 1) := l_end_string || l_string;
      ELSE
        -- update l_beg_pos for next iteration
        l_beg_pos := l_beg_pos + l_chunk_size;
        -- update l_pos to end of string retrieved
        l_pos := l_chunk_size;
        -- loop till you find a valid delimiter
        WHILE ( NOT is_char_delimiter(SUBSTR(l_string, l_pos, 1)
				     , x_return_status
				     , x_error_Tbl
                                     )

              ) LOOP
          l_pos := l_pos - 1;
        END LOOP;
        bis_debug_pub.add('l_pos = ' || l_pos);
        bis_debug_pub.add('l_beg_pos = ' || l_beg_pos);
        bis_debug_pub.add('l_chunk_size = ' || l_chunk_size);
        -- store the portion of string till the valid delimiter
        l_beg_string := SUBSTR(l_string, 1, l_pos);
        bis_debug_pub.add('l_beg_string = ' || l_beg_string);
        -- prepend l_end_string from previous iteration to l_beg_string
        -- to create a row of the table
        x_View_Table(x_View_Table.COUNT + 1) := l_end_string || l_beg_string;
        IF(l_pos = l_chunk_size) THEN
          -- got delimiter at the end of l_string; reset values
          l_end_string := NULL;
          l_chunk_size := 200;
          bis_debug_pub.add('l_end_string = NULL; l_chunk_size = 200');
        ELSE
          -- store the end portion of string beyond the delimiter
          l_end_string := SUBSTR(l_string, l_pos + 1);
          -- set l_chunk_size for next iteration to account for the spillover
          l_chunk_size := 200 - LENGTH(l_end_string);
          bis_debug_pub.add('l_end_string = ' || l_end_string);
          bis_debug_pub.add('l_chunk_size = ' || l_chunk_size);
        END IF;
      END IF;
      -- exit if we did not find enough characters ie., end of string reached
      EXIT WHEN LENGTH(l_string) < l_old_chunk_size;
    END LOOP;
  END IF;
  bis_debug_pub.Add('< create_Text_Table');


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
      , p_error_proc_name   => G_PKG_NAME||'.create_Text_Table'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END create_Text_Table;
--
FUNCTION get_valid_col_name
( p_Col_Name IN 	VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2 IS
--
l_String   VARCHAR2(100);
l_SQL_text VARCHAR2(100);
l_CursorID INTEGER;
l_dummy    INTEGER;
--
BEGIN
  bis_debug_pub.Add('> get_string_len30');
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_String := REPLACE(p_Col_Name, ' ', '_');
  l_String := REPLACE(l_String, '^', '_');
  l_String := REPLACE(l_String, '-', '_');
  l_SQL_text := 'SELECT NULL ' || l_String || ' FROM DUAL';
  BEGIN
    l_CursorID := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_CursorID, l_SQL_text, DBMS_SQL.NATIVE);
    DBMS_SQL.CLOSE_CURSOR(l_CursorID);
  EXCEPTION
    WHEN OTHERS THEN
      l_String := '"' || l_String || '"';
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);
  END;
  RETURN l_String;
  bis_debug_pub.Add('< get_string_len30');


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
      , p_error_proc_name   => G_PKG_NAME||'.get_valid_col_name'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_valid_col_name;
--
--
FUNCTION get_string_len30
( p_String IN VARCHAR2
, p_Prefix IN VARCHAR2
, p_Suffix IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2 IS
--
l_String VARCHAR2(100);
l_Suffix_Len NUMBER := 0;
--
BEGIN
  BIS_DEBUG_PUB.Add('> get_string_len30');
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_Suffix IS NOT NULL) THEN
    l_Suffix_Len := LENGTH(p_Suffix);
  END IF;
  l_String := SUBSTR(p_Prefix || p_String, 1, 30 - l_Suffix_Len) || p_Suffix;
  RETURN l_String;
  BIS_DEBUG_PUB.Add('< get_string_len30');


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
      , p_error_proc_name   => G_PKG_NAME||'.get_string_len30'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_string_len30;
--
--
FUNCTION get_string
( p_view_table     IN bis_vg_types.View_Text_Table_Type
, p_start_pointer  IN bis_vg_types.View_Character_Pointer_Type
, p_end_pointer    IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
l_ret       VARCHAR2(32000);
l_str       VARCHAR2(32000);
end_pointer bis_vg_types.view_character_pointer_type;
BEGIN

   BIS_DEBUG_PUB.Add('> get_string');
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   print_view_pointer ( p_start_pointer
                      , x_return_status
		      , x_error_Tbl
		      );
   print_view_pointer ( p_end_pointer
                      , x_return_status
		      , x_error_Tbl
		      );

   IF (p_start_pointer.row_num IS NULL) THEN
      -- beginning from end of table
      RETURN NULL;
   END IF;

   end_pointer := p_end_pointer;
   IF (end_pointer.row_num IS NULL) THEN
      -- has to copy entire table after start
      -- set row num as all the last row
      -- set column num as one more then length as end pointer char is excluded
      end_pointer.row_num := p_view_table.COUNT;
      end_pointer.col_num := Length(p_view_table(end_pointer.row_num)) + 1;
   END IF;

   print_view_pointer ( end_pointer
                      , x_return_status
		      , x_error_Tbl
		      );
   IF (p_start_pointer.row_num = end_pointer.row_num) THEN
      l_str := p_view_table(p_start_pointer.row_num);
      RETURN Substr( l_str
                   , p_start_pointer.col_num
                   , end_pointer.col_num - p_start_pointer.col_num
                   );
    ELSE
      FOR i IN p_start_pointer.row_num .. end_pointer.row_num LOOP
        l_str := p_view_table(i);
        IF (i = p_start_pointer.row_num) THEN
          l_ret := Substr( l_str
                         , p_start_pointer.col_num
                         , Length(l_str) - p_start_pointer.col_num + 1
                         );
        ELSIF (i = end_pointer.row_num) THEN
               l_ret := l_ret || Substr(l_str, 1, end_pointer.col_num - 1);
        ELSE
               l_ret := l_ret || l_str;
        END IF;
      END LOOP;
   END IF;

   BIS_DEBUG_PUB.Add('< get_string');
   RETURN l_ret;

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
      , p_error_proc_name   => G_PKG_NAME||'.get_string'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_string;

FUNCTION get_char
( p_view_table     IN bis_vg_types.View_Text_Table_Type
, p_pointer        IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS
BEGIN
  RETURN Substr(p_view_table(p_pointer.row_num), p_pointer.col_num, 1);

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
      , p_error_proc_name   => G_PKG_NAME||'.get_char'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_char;

FUNCTION increment_pointer
( p_view_table     IN bis_vg_types.View_Text_Table_Type
, p_pointer        IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN bis_vg_types.view_character_pointer_type
is
l_str     VARCHAR2(2000);
l_pointer bis_vg_types.view_character_pointer_type;
begin
  BIS_DEBUG_PUB.Add('> increment_pointer');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_str := p_view_table(p_pointer.row_num);
  IF (p_pointer.col_num = Length(l_str)) THEN
  -- if at end of table return null
     IF(p_pointer.row_num < p_view_table.COUNT) then
       l_pointer.row_num := p_pointer.row_num + 1;
       l_pointer.col_num := 1;
     END IF;
   ELSE
     l_pointer.row_num := p_pointer.row_num;
     l_pointer.col_num := p_pointer.col_num + 1;
  END IF;
  BIS_DEBUG_PUB.Add('< increment_pointer');
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
      , p_error_proc_name   => G_PKG_NAME||'.increment_pointer'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END increment_pointer;

-- concatenates p_View_Table_A with p_View_Table_B
PROCEDURE concatenate_Tables
( p_View_Table_A IN  BIS_VG_TYPES.View_Text_Table_Type
, p_View_Table_B IN  BIS_VG_TYPES.View_Text_Table_Type
, x_View_Table   OUT BIS_VG_TYPES.View_Text_Table_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_count INTEGER;
BEGIN
  BIS_DEBUG_PUB.Add('> concatenate_Tables');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_View_Table := p_View_Table_A;
  l_count := x_View_Table.COUNT + 1;
  for p_ind in 1 .. p_View_Table_B.COUNT loop
    x_View_Table(l_count) := p_View_Table_B(p_ind);
    l_count := l_count + 1;
  end loop;
  BIS_DEBUG_PUB.Add('< concatenate_Tables');


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
      , p_error_proc_name   => G_PKG_NAME||'.concatenate_Tables'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END concatenate_Tables;
--
--
PROCEDURE concatenate_Tables
( p_View_Table_A IN  BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, p_View_Table_B IN  BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, x_View_Table   OUT BIS_VG_TYPES.Flex_Column_Comment_Table_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_count INTEGER;
BEGIN
  BIS_DEBUG_PUB.Add('> concatenate_Tables  Flex_Column_Comment');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_View_Table := p_View_Table_A;
  l_count := x_View_Table.COUNT + 1;
  for p_ind in 1 .. p_View_Table_B.COUNT loop
    x_View_Table(l_count) := p_View_Table_B(p_ind);
    l_count := l_count + 1;
  end loop;
  BIS_DEBUG_PUB.Add('< concatenate_Tables Flex_Column_Comment');


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
      , p_error_proc_name   => G_PKG_NAME||'.concatenate_Tables'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END concatenate_Tables;
--
--
FUNCTION equal_pointers
( p_start_pointer IN  BIS_VG_TYPES.view_character_pointer_type
, p_end_pointer   IN  BIS_VG_TYPES.view_character_pointer_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN BOOLEAN IS
--
BEGIN
  BIS_DEBUG_PUB.Add('> equal_pointers');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- both are null; return true
  IF (null_pointer(p_start_pointer, x_return_status, x_error_Tbl) = TRUE)
  AND (null_pointer(p_end_pointer, x_return_status, x_error_Tbl) = TRUE) THEN
    RETURN TRUE;
  END IF;
-- one of them is null; return false
  IF (null_pointer(p_start_pointer, x_return_status, x_error_Tbl) = TRUE)
  OR (null_pointer(p_end_pointer, x_return_status, x_error_Tbl) = TRUE) THEN
    RETURN FALSE;
  END IF;
-- if start_pointer = end_pointer return true
  IF (p_start_pointer.row_num = p_end_pointer.row_num)
  AND (p_start_pointer.col_num = p_end_pointer.col_num) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
  BIS_DEBUG_PUB.Add('< equal_pointers');


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
      , p_error_proc_name   => G_PKG_NAME||'.equal_pointers'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END equal_pointers;
--
--
PROCEDURE copy_part_of_Table
( p_View_Table_A  IN  BIS_VG_TYPES.View_Text_Table_Type
, p_start_pointer IN  BIS_VG_TYPES.view_character_pointer_type
, p_end_pointer   IN  BIS_VG_TYPES.view_character_pointer_type
, x_View_Table    OUT BIS_VG_TYPES.View_Text_Table_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
l_str   VARCHAR2(2000);
l_start NUMBER;
l_end   NUMBER;
j       NUMBER;
BEGIN
   BIS_DEBUG_PUB.Add('> copy part of table');
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   print_view_pointer ( p_start_pointer
                      , x_return_status
		      , x_error_Tbl
		      );
   print_view_pointer ( p_end_pointer
                      , x_return_status
		      , x_error_Tbl
		      );
   IF ( equal_pointers ( p_start_pointer
                       , p_end_pointer
                      , x_return_status
		      , x_error_Tbl
		      )
      ) THEN
     RETURN;
   END IF;
   BIS_DEBUG_PUB.Add('count = '||p_view_table_a.COUNT);

   IF (null_pointer(p_start_pointer, x_return_status, x_error_Tbl)
      = TRUE
      )
      THEN RETURN;
   END IF;

   IF (   null_pointer ( p_end_pointer
		       , x_return_status
		       , x_error_Tbl
                       ) = TRUE
       OR p_start_pointer.row_num < p_end_pointer.row_num
      ) THEN
     l_str := p_view_table_a(p_start_pointer.row_num);
     BIS_DEBUG_PUB.Add('l_str = '||l_str);
     x_view_table(1) := Substr(l_str, p_start_pointer.col_num);
     BIS_DEBUG_PUB.Add('part str = '||x_view_table(1));

     l_start := p_start_pointer.row_num + 1;

     BIS_DEBUG_PUB.Add('after assignment');

     IF (p_end_pointer.row_num IS NULL) THEN
        l_end := p_view_table_a.COUNT;
     else
        l_end   := p_end_pointer.row_num - 1;
     END IF;

     j := 2;
     BIS_DEBUG_PUB.Add('l_end = '||l_end||' l_start = '||l_start);

     IF (l_end >= l_start) THEN
       FOR i IN l_start .. l_end LOOP
         BIS_DEBUG_PUB.Add(i||'th = '||p_view_table_a(i));
         BIS_DEBUG_PUB.Add('j = '||j);
         x_view_table(j) := p_view_table_a(i);
         BIS_DEBUG_PUB.Add(j||'th = '||x_view_table(j));
         j := j + 1;
       END LOOP;
     END IF;

     BIS_DEBUG_PUB.Add('after the loop');

     IF (l_end <> p_view_table_a.COUNT AND p_end_pointer.col_num > 1) THEN
       bis_debug_pub.ADD(' putting in the last line');
       l_str := p_view_table_a(p_end_pointer.row_num);
       j := x_view_table.COUNT + 1;
       x_view_table(j) := Substr(l_str, 1, p_end_pointer.col_num - 1);
     END IF;
   ELSIF (p_start_pointer.row_num = p_end_pointer.row_num) THEN
     l_str := p_view_table_a(p_start_pointer.row_num);
     BIS_DEBUG_PUB.Add('l_str = '||l_str);
     x_view_table(1) := Substr( l_str
                              , p_start_pointer.col_num
                              , p_end_pointer.col_num -
                                p_start_pointer.col_num
                              );
   END IF;
  BIS_DEBUG_PUB.Add('< copy part of table');


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
      , p_error_proc_name   => G_PKG_NAME||'.copy_part_of_table'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END copy_part_of_table;

/* ============================================================================
   PROCEDURE : print_View_Text
   PARAMETERS:
   1. p_View_Text_Table  table of varchars which holds the view text
   2. x_return_status    error or normal
   3. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to print the view text.
   EXCEPTION : None
  ========================================================================== */
   PROCEDURE print_View_Text --{
   ( p_View_Text_Table IN BIS_VG_TYPES.View_Text_Table_Type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS
--
   i NUMBER;
--
   BEGIN
     BIS_DEBUG_PUB.Add('> print_View_Text');
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     bis_debug_pub.ADD('# of rows in table = '||p_view_text_table.COUNT);
     for i in 1 .. p_View_Text_Table.COUNT loop
       BIS_DEBUG_PUB.Add(p_View_Text_Table(i));
     end loop;
     BIS_DEBUG_PUB.Add('< print_View_Text');


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
      , p_error_proc_name   => G_PKG_NAME||'.print_View_Text'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END print_View_Text; --}
--
/* ============================================================================
   PROCEDURE : print_View_pointer
   PARAMETERS:
   1. p_View_Text_Table  table of varchars which holds the view text
   2. x_return_status    error or normal
   3. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to print the view text.
   EXCEPTION : None
============================================================================ */
   PROCEDURE print_View_pointer --{
   ( p_pointer IN BIS_VG_TYPES.View_character_pointer_type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   )
   IS
   BEGIN
     BIS_DEBUG_PUB.Add('> print_View_pointer');
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     BIS_DEBUG_PUB.Add('pointer row num = '||p_pointer.row_num ||
                          ' pointer col num = '||p_pointer.col_num);
     BIS_DEBUG_PUB.Add('< print_View_pointer');


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
      , p_error_proc_name   => G_PKG_NAME||'.print_View_pointer'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END print_View_pointer; --}
--

/* ============================================================================
   PROCEDURE : position_before_characters
   PARAMETERS:
   1. p_View_Text_Table  table of varchars which holds the view text
   2. p_str              string of charaters tobe replaced
   3. x_return_status    error or normal
   4. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to remove all the charaters in p_str
   EXCEPTION : None
============================================================================ */
   -- remove th trailing characters in the table which are there in the p_str
    FUNCTION position_before_characters
    ( p_View_Text_Table IN BIS_VG_TYPES.view_text_table_type
    , p_str             IN VARCHAR2
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
    RETURN bis_vg_types.view_character_pointer_type
    IS
    l_pointer bis_vg_types.view_character_pointer_type;
    BEGIN
      BIS_DEBUG_PUB.Add('> position_before_characters');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_pointer.row_num := p_view_text_table.COUNT;
      l_pointer.col_num := Length(p_view_text_table(l_pointer.row_num));
      BIS_DEBUG_PUB.Add('< position_before_characters');
      RETURN (position_before_characters(p_view_text_table
                                         , p_str
					 , l_pointer
					 , x_return_status
					 , x_error_Tbl
					 )
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
      , p_error_proc_name   => G_PKG_NAME||'.position_before_characters'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END position_before_characters;

/* ============================================================================
   FUNCTION : position_before_characters
   ARGUMENTS:
   1. p_View_Text_Table  table of varchars which holds the view text
   2. p_str              string of charaters tobe replaced
   3. p_pointer          pointer to start positioning from
   4. x_return_status    error or normal
   5. x_error_Tbl        table of error messages
   RETURNS Pointer to beginning of string (?)
   COMMENT   : Call this procedure to remove all the charaters in p_str
   EXCEPTION : None
============================================================================ */
   -- remove th trailing characters in the table which are there in the p_str
    FUNCTION position_before_characters
    ( p_View_Text_Table IN BIS_VG_TYPES.view_text_table_type
    , p_str             IN VARCHAR2
    , p_pointer         IN bis_vg_types.view_character_pointer_type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
    RETURN bis_vg_types.view_character_pointer_type
    IS
    l_pointer bis_vg_types.view_character_pointer_type;
    l_char    VARCHAR2(1);
    l_pos     NUMBER;
    BEGIN
      BIS_DEBUG_PUB.Add('> position_before_characters');
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_pointer.row_num IS NULL) THEN
         return p_pointer;
      END IF;
      BIS_DEBUG_PUB.Add('p_str = ' || p_str);
      print_view_pointer ( p_pointer
                         , x_return_status
			 , x_error_Tbl
			 );
      l_pointer := decrement_pointer ( p_view_text_table
      				     , p_pointer
				     , x_return_status
				     , x_error_Tbl
				     );
      l_char := get_char( p_view_text_table
      			, l_pointer
			, x_return_status
			, x_error_Tbl
			);
      l_pos := Instr(p_str, l_char);

      WHILE (l_pos <> 0) LOOP
         BIS_DEBUG_PUB.Add('l_char = ' || l_char || ' l_pos = ' || l_pos);
         BIS_VG_UTIL.print_View_Pointer( l_pointer
				       , x_return_status
				       , x_error_Tbl
				       );
         l_pointer := decrement_pointer ( p_view_text_table
	 				, l_pointer
					, x_return_status
					, x_error_Tbl
					);
         l_char := get_char( p_view_text_table
	 		   , l_pointer
			   , x_return_status
			   , x_error_Tbl
			   );
         l_pos := Instr(p_str, l_char);
      END LOOP;

      bis_debug_pub.ADD('out of loop');
      BIS_VG_UTIL.print_View_Pointer ( l_pointer
				     , x_return_status
				     , x_error_Tbl
				     );
      BIS_DEBUG_PUB.Add('< position_before_characters');
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
      , p_error_proc_name   => G_PKG_NAME||'.position_before_characters'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


    END position_before_characters;

    -- decrements pointer by one
    FUNCTION decrement_pointer
    ( p_view_table     IN bis_vg_types.View_Text_Table_Type
    , p_pointer        IN bis_vg_types.View_Character_Pointer_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
    RETURN bis_vg_types.view_character_pointer_type
    IS
    l_str     VARCHAR2(2000);
    l_pointer bis_vg_types.view_character_pointer_type;
    BEGIN
      BIS_DEBUG_PUB.Add('> decrement_pointer');
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_pointer.row_num IS NULL) THEN
         return p_pointer;
      END IF;

      l_pointer := p_pointer;
      l_str := p_view_table(l_pointer.row_num);
      IF (l_pointer.col_num = 1) THEN
         IF (l_pointer.row_num = 1) THEN
           RETURN NULL;
         END IF;

         l_pointer.row_num := l_pointer.row_num - 1;
         l_str := p_view_table(l_pointer.row_num);
         l_pointer.col_num := Length(l_str);
       ELSE
         l_pointer.col_num := l_pointer.col_num - 1;
      END IF;
      BIS_DEBUG_PUB.Add('< decrement_pointer');
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
      , p_error_proc_name   => G_PKG_NAME||'.decrement_pointer'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END decrement_pointer;

 -- return TRUE if pointer is a null
FUNCTION null_pointer
(p_pointer IN bis_vg_types.view_character_pointer_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN BOOLEAN
IS
BEGIN

   IF (  p_pointer.row_num IS NULL
      OR p_pointer.col_num IS NULL) THEN
      RETURN TRUE;
   END IF;

   RETURN FALSE;

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
      , p_error_proc_name   => G_PKG_NAME||'.null_pointer'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END null_pointer;

-- returns the row pointed to by the pointer
FUNCTION get_row
( p_view_table     IN bis_vg_types.View_Text_Table_Type
, p_pointer        IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN bis_vg_types.view_text_table_rec_type
IS
BEGIN
   IF (  null_pointer ( p_pointer
                      , x_return_status
		      , x_error_Tbl
                      ) = TRUE
      OR p_pointer.row_num > p_view_table.COUNT
      OR p_pointer.row_num < 1) THEN
      RETURN NULL;
   END IF;

   RETURN p_view_table(p_pointer.row_num);

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
      , p_error_proc_name   => G_PKG_NAME||'.get_row'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_row;

-- increments the pointer to next row
FUNCTION increment_pointer_by_row
( p_view_table     IN bis_vg_types.View_Text_Table_Type
, p_pointer        IN bis_vg_types.View_Character_Pointer_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN bis_vg_types.view_character_pointer_type
IS
l_pointer bis_vg_types.view_character_pointer_type;
BEGIN
   BIS_DEBUG_PUB.Add('> increment_pointer_by_row ');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (  null_pointer ( p_pointer
		      , x_return_status
		      , x_error_Tbl
                      ) = TRUE
      OR p_pointer.row_num >= p_view_table.COUNT
      OR p_pointer.row_num < 1) THEN
      RETURN l_pointer;
   END IF;

   l_pointer := p_pointer;
   l_pointer.row_num := l_pointer.row_num + 1;
   l_pointer.col_num := 1;
   BIS_DEBUG_PUB.Add('< increment_pointer_by_row ');
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
      , p_error_proc_name   => G_PKG_NAME||'.increment_pointer_by_row'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END increment_pointer_by_row;

-- this function returns the generated view name for the original view name
FUNCTION get_generated_view_name
( p_view_name IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
RETURN VARCHAR2
IS

l_View_Name VARCHAR2(100);
l_pos       NUMBER;
--
BEGIN

  bis_debug_pub.Add('> get_generated_view_name');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_pos := INSTR(p_View_Name, 'V_');
  l_View_Name := SUBSTR(p_View_Name, 1, l_pos - 1)
                || 'G'
                || SUBSTR( p_View_Name
                         , l_pos + 1
                         , LENGTH(p_View_Name) - l_pos
                         );
  bis_debug_pub.Add('< get_generated_view_name');
  RETURN l_view_name;

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
      , p_error_proc_name   => G_PKG_NAME||'.get_generated_view_name'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_generated_view_name;

-- these procedure check and puts the error message on the message stack
PROCEDURE add_message
( p_msg_name  IN VARCHAR2
, p_msg_level IN NUMBER
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
BEGIN
  IF (fnd_msg_pub.check_msg_level(p_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_msg_name);
    fnd_msg_pub.ADD;
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
      , p_error_proc_name   => G_PKG_NAME||'.add_message'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_message;

PROCEDURE add_message
( p_msg_name  IN VARCHAR2
, p_msg_level IN NUMBER
, p_token1    IN VARCHAR2
, p_value1    IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
  IS

BEGIN
  IF (fnd_msg_pub.check_msg_level(p_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_msg_name);
    fnd_message.set_token(p_token1, p_value1);
    fnd_msg_pub.ADD;
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
      , p_error_proc_name   => G_PKG_NAME||'.add_message'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_message;

PROCEDURE add_message
( p_msg_name  IN VARCHAR2
, p_msg_level IN NUMBER
, p_token1    IN VARCHAR2
, p_value1    IN VARCHAR2
, p_token2    IN VARCHAR2
, p_value2    IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
BEGIN
  IF (fnd_msg_pub.check_msg_level(p_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_msg_name);
    fnd_message.set_token(p_token1, p_value1);
    fnd_message.set_token(p_token2, p_value2);
    fnd_msg_pub.ADD;
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
      , p_error_proc_name   => G_PKG_NAME||'.add_message'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_message;

PROCEDURE add_message
( p_msg_name  IN VARCHAR2
, p_msg_level IN NUMBER
, p_token1    IN VARCHAR2
, p_value1    IN VARCHAR2
, p_token2    IN VARCHAR2
, p_value2    IN VARCHAR2
, p_token3    IN VARCHAR2
, p_value3    IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
BEGIN
  IF (fnd_msg_pub.check_msg_level(p_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_msg_name);
    fnd_message.set_token(p_token1, p_value1);
    fnd_message.set_token(p_token2, p_value2);
    fnd_message.set_token(p_token3, p_value3);
    fnd_msg_pub.ADD;
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
      , p_error_proc_name   => G_PKG_NAME||'.add_message'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END add_message;
--
-- these procedure check and puts the error message on the message stack
--
PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_VG_UTIL.G_ERROR
, p_error_table       IN  BIS_VG_UTIL.Error_Tbl_Type
, x_error_table       OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_error_rec BIS_VG_UTIL.Error_Rec_Type;
--
BEGIN
  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_error_msg_name);

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;
  END IF;
END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_VG_UTIL.G_ERROR
, p_token1    	      IN VARCHAR2
, p_value1    	      IN VARCHAR2
, p_error_table       IN  BIS_VG_UTIL.Error_Tbl_Type
, x_error_table       OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_error_rec BIS_VG_UTIL.Error_Rec_Type;
--
BEGIN

  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_error_msg_name);
    fnd_message.set_token(p_token1, p_value1);

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;
  END IF;

END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_VG_UTIL.G_ERROR
, p_token1    	      IN VARCHAR2
, p_value1    	      IN VARCHAR2
, p_token2    	      IN VARCHAR2
, p_value2    	      IN VARCHAR2
, p_error_table       IN  BIS_VG_UTIL.Error_Tbl_Type
, x_error_table       OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_error_rec BIS_VG_UTIL.Error_Rec_Type;
--
BEGIN

  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_error_msg_name);
    fnd_message.set_token(p_token1, p_value1);
    fnd_message.set_token(p_token2, p_value2);

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;
  END IF;
END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_VG_UTIL.G_ERROR
, p_token1            IN VARCHAR2
, p_value1    	      IN VARCHAR2
, p_token2    	      IN VARCHAR2
, p_value2    	      IN VARCHAR2
, p_token3    	      IN VARCHAR2
, p_value3    	      IN VARCHAR2
, p_error_table       IN  BIS_VG_UTIL.Error_Tbl_Type
, x_error_table       OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_error_rec BIS_VG_UTIL.Error_Rec_Type;
--
BEGIN

  IF (fnd_msg_pub.check_msg_level(p_error_msg_level) = TRUE) THEN
    fnd_message.set_name(BIS_VG_TYPES.message_application, p_error_msg_name);
    fnd_message.set_token(p_token1, p_value1);
    fnd_message.set_token(p_token2, p_value2);
    fnd_message.set_token(p_token3, p_value3);

    l_error_rec.Error_Msg_ID      := NULL;
    l_error_rec.Error_Msg_Name    := p_error_msg_name;
    l_error_rec.Error_proc_Name   := p_error_proc_name;
    l_error_rec.Error_Description := fnd_message.get;
    l_error_rec.Error_Type        := p_error_type;
    --
    x_error_table := p_error_table;
    x_error_table(x_error_table.COUNT + 1) := l_error_rec;
  END IF;
END Add_Error_Message;

PROCEDURE Add_Error_Message
( p_error_msg_id      IN  NUMBER    := NULL
, p_error_msg_name    IN  VARCHAR2  := NULL
, p_error_description IN  VARCHAR2  := NULL
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_VG_UTIL.G_ERROR
, p_error_table       IN  BIS_VG_UTIL.Error_Tbl_Type
, x_error_table       OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
--
l_error_rec BIS_VG_UTIL.Error_Rec_Type;
--
BEGIN

  l_error_rec.Error_Msg_ID      := p_error_msg_id;
  l_error_rec.Error_Msg_Name    := p_error_msg_name;
  l_error_rec.Error_proc_Name   := p_error_proc_name;
  l_error_rec.Error_Description := p_error_description;
  l_error_rec.Error_Type        := p_error_type;
  --
  x_error_table := p_error_table;
  x_error_table(x_error_table.COUNT + 1) := l_error_rec;
END Add_Error_Message;
--

--
-- This function is called by Discoverer to return the translated prompt for a
-- flex derived column in the generated view
FUNCTION find_Flex_Prompt(p_db_link        IN VARCHAR2
                          , p_view_owner   IN VARCHAR2
                          , p_view_name    IN VARCHAR2
                          , p_column_name  IN VARCHAR2
                          , p_language     IN VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR l_lang_cur IS
                   SELECT installed_flag
                   FROM fnd_languages_vl
                   WHERE UPPER(language_code) = UPPER(p_language);

CURSOR l_get_comments_cur IS
                          SELECT comments
                          FROM all_col_comments
                          WHERE table_name = UPPER(p_view_name)
                            AND owner = UPPER(p_view_owner)
                            AND column_name = UPPER(p_column_name);

CURSOR l_get_key_prmpt_cur(p_app_id IN NUMBER
                           , p_flex_code IN fnd_id_flex_segments_tl.id_flex_code%TYPE
                           , p_struc_num IN fnd_id_flex_segments_tl.id_flex_num%TYPE
                           , p_app_column IN VARCHAR2
                           ) IS
                             SELECT form_above_prompt
                             FROM fnd_id_flex_segments_tl
                             WHERE application_id = p_app_id
                               AND id_flex_code = p_flex_code
                               AND id_flex_num = p_struc_num
                               AND application_column_name = p_app_column
                               AND language = UPPER(p_language);

CURSOR l_get_desc_ctxt_prmpt_cur(p_app_id IN NUMBER
                                  , p_desc_flex_name IN fnd_descriptive_flexs_tl.descriptive_flexfield_name%TYPE
                                  ) IS
                                    SELECT form_context_prompt
                                    FROM fnd_descriptive_flexs_tl
                                    WHERE application_id = p_app_id
                                      AND descriptive_flexfield_name = p_desc_flex_name
                                      AND language = UPPER(p_language);

CURSOR l_get_desc_seg_prmpt_cur(p_app_id IN NUMBER
                                , p_desc_flex_name IN fnd_descriptive_flexs_tl.descriptive_flexfield_name%TYPE
                                , p_context_code IN fnd_descr_flex_col_usage_tl.descriptive_flex_context_code%TYPE
                                , p_app_column IN VARCHAR2
                                ) IS
                                  SELECT form_above_prompt
                                  FROM fnd_descr_flex_col_usage_tl
                                  WHERE application_id = p_app_id
                                    AND descriptive_flexfield_name = p_desc_flex_name
                                    AND descriptive_flex_context_code = p_context_code
                                    AND application_column_name = p_app_column
                                    AND language = UPPER(p_language);

l_comments   all_col_comments.comments%TYPE;
l_flex_type  VARCHAR2(12);

l_kf_prompt_stmt  VARCHAR2(200);

l_flag  fnd_languages_vl.installed_flag%TYPE;
ex_lang_not_installed  EXCEPTION;
l_prompt  VARCHAR2(80) :='';
l_comma_pointer_1 NUMBER;
l_comma_pointer_2 NUMBER;
l_app_id     NUMBER;
l_flex_code  fnd_id_flex_segments_tl.id_flex_code%TYPE;
l_struc_num  fnd_id_flex_segments_tl.id_flex_num%TYPE;
l_app_column VARCHAR2(30);
l_seg_name   fnd_id_flex_segments.segment_name%TYPE;
l_desc_flex_name  fnd_descriptive_flexs_tl.descriptive_flexfield_name%TYPE;
l_context_code fnd_descr_flex_col_usage_tl.descriptive_flex_context_code%TYPE;
--v_debug    VARCHAR2(100);

BEGIN

-- We will ignore if the p_dblink is NULL
   IF p_view_owner = '' THEN
      RETURN l_prompt;
   ELSIF p_view_name = '' THEN
      RETURN l_prompt;
   ELSIF p_column_name = '' THEN
      RETURN l_prompt;
   ELSIF p_language = '' THEN
      RETURN l_prompt;
   END IF;
   OPEN l_lang_cur;
   FETCH l_lang_cur  INTO l_flag;
   CLOSE l_lang_cur;
   IF (NVL(l_flag,'D') NOT IN  ('I','B')) THEN
      RAISE ex_lang_not_installed;
   ELSE
      OPEN l_get_comments_cur;
      FETCH l_get_comments_cur INTO l_comments;
      CLOSE l_get_comments_cur;
      IF l_comments IS NOT NULL THEN
         l_comma_pointer_1 := INSTRB(l_comments, ',', 1);
         l_comma_pointer_2 := INSTRB(l_comments, ',', l_comma_pointer_1 +1);
         l_flex_type := SUBSTRB(l_comments, 1, l_comma_pointer_1 - 1);
         IF l_flex_type ='KEY' THEN
           -- parse the comments and get info
           --v_debug := SUBSTRB(l_comments, (l_comma_pointer_1 +1), (l_comma_pointer_2 -l_comma_pointer_1 -1));
           l_app_id := TO_NUMBER(SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 - l_comma_pointer_1 -1));
           l_comma_pointer_1 := l_comma_pointer_2;
           l_comma_pointer_2 := INSTRB(l_comments, ',', l_comma_pointer_1 +1);
           l_flex_code := SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 -l_comma_pointer_1 -1);
           l_comma_pointer_1 := l_comma_pointer_2;
           l_comma_pointer_2 := INSTRB(l_comments, ',', l_comma_pointer_1 +1);
           l_struc_num := TO_NUMBER(SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 -l_comma_pointer_1-1));
           l_comma_pointer_1 := l_comma_pointer_2;
           -- this should be the last comma in the comment string for KEY Flex column
           l_comma_pointer_2 := INSTRB(l_comments, ',', l_comma_pointer_1 +1);
           l_seg_name := SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 -l_comma_pointer_1-1);
           l_app_column := SUBSTRB(l_comments, l_comma_pointer_2+1);
           OPEN l_get_key_prmpt_cur(l_app_id
                                   , l_flex_code
                                   , l_struc_num
                                   , l_app_column);
           FETCH l_get_key_prmpt_cur INTO l_prompt;
           CLOSE l_get_key_prmpt_cur;
           RETURN l_prompt;
         ELSIF l_flex_type = 'DESC CONTEXT' THEN
           l_app_id := TO_NUMBER(SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 - l_comma_pointer_1 -1));
           l_comma_pointer_1 := l_comma_pointer_2;
           l_comma_pointer_2 := INSTRB(l_comments, ',', l_comma_pointer_1 +1);
           l_desc_flex_name := SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 -l_comma_pointer_1 -1);
           OPEN l_get_desc_ctxt_prmpt_cur(l_app_id
                                          , l_desc_flex_name);
           FETCH l_get_desc_ctxt_prmpt_cur INTO l_prompt;
           CLOSE l_get_desc_ctxt_prmpt_cur;
           RETURN l_prompt;
         ELSIF l_flex_type = 'DESC SEGMENT' THEN
           --v_debug := SUBSTRB(l_comments, (l_comma_pointer_1 +1), (l_comma_pointer_2 -l_comma_pointer_1 -1));
           l_app_id := TO_NUMBER(SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 - l_comma_pointer_1 -1));
           l_comma_pointer_1 := l_comma_pointer_2;
           l_comma_pointer_2 := INSTRB(l_comments, ',', l_comma_pointer_1 +1);
           l_desc_flex_name := SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 -l_comma_pointer_1 -1);
           l_comma_pointer_1 := l_comma_pointer_2;
           l_comma_pointer_2 := INSTRB(l_comments, ',', l_comma_pointer_1 +1);
           l_context_code := SUBSTRB(l_comments, l_comma_pointer_1 +1, l_comma_pointer_2 -l_comma_pointer_1-1);
           l_app_column := SUBSTRB(l_comments, l_comma_pointer_2+1);
           OPEN l_get_desc_seg_prmpt_cur(l_app_id
                                         , l_desc_flex_name
                                         , l_context_code
                                         , l_app_column);
           FETCH l_get_desc_seg_prmpt_cur INTO l_prompt;
           CLOSE l_get_desc_seg_prmpt_cur;
           RETURN l_prompt;
         ELSE
         --nothing should fall through to here
           RETURN l_prompt;
         END IF;
      END IF;
   END IF;
--dbms_output.put_line('fell through to outer if statement');
   RETURN l_prompt;
EXCEPTION
   WHEN ex_lang_not_installed THEN
        fnd_message.set_name(BIS_VG_TYPES.message_application, 'BIS_VG_LANG_NOT_INSTALLED');
        fnd_message.set_token('LANG',UPPER(p_language));
	raise_application_error(-20001, fnd_message.get);
   WHEN OTHERS THEN
        raise_application_error(-20002, SQLERRM ||'   p_db_link = '||p_db_link
                                ||' p_view_owner = '||p_view_owner
                                ||' p_view_name = '||p_view_name
                                ||' p_column_name = '||p_column_name
                                ||' p_language = '||p_language);



END find_Flex_Prompt;

END BIS_VG_UTIL;

/
