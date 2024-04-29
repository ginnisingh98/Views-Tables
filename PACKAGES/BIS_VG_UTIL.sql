--------------------------------------------------------
--  DDL for Package BIS_VG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_UTIL" AUTHID CURRENT_USER AS
/* $Header: BISTUTLS.pls 115.8 2002/03/27 08:18:57 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTUTLS.pls
--
--  DESCRIPTION
--
--      spec of view generator util to be used in the view generator
--      package specifyling the view security
--
--  NOTES
--
--  HISTORY
--
--  21-JUL-98 Created
--  07-FEB-01 Edited by DBOWLES Added Find_Flex_Prompt function
--  10-DEC-01 Edited by DBOWLES Added db driver comment
--
--
---- Data Type: Records and Tables
G_SHORT_NAME_LEN  Number := 20;
G_ERROR           VARCHAR2(1) := 'E';
G_WARNING         VARCHAR2(1) := 'W';

TYPE Error_Rec_Type IS RECORD
  ( Error_Msg_ID       Number         := FND_API.G_MISS_NUM
    , Error_Msg_Name     VARCHAR2(30)   := FND_API.G_MISS_CHAR
    , Error_Description  VARCHAR2(2000) := FND_API.G_MISS_CHAR
    , Error_Proc_Name    VARCHAR2(100)  := FND_API.G_MISS_CHAR
    , Error_Type         VARCHAR2(1)    := G_ERROR  );

TYPE Error_Tbl_Type IS TABLE of Error_Rec_Type
  INDEX BY BINARY_INTEGER;
--

-- returns TRUE if p_character is a delimiter
FUNCTION is_char_delimiter
	( p_character 		IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN BOOLEAN;
--
-- creates a table of varchars from a single VARCHAR2 such that
-- each LENGTH(row) <= 250
PROCEDURE create_Text_Table
	( p_String     		IN  VARCHAR2
	, x_View_Table 		OUT bis_vg_types.View_Text_Table_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	);
--
-- returns a valid column name after verification
FUNCTION get_valid_col_name
	( p_Col_Name 		IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN VARCHAR2;
--
-- returns the string with the prefix and suffix and strlen <= 30
FUNCTION get_string_len30
	( p_String 		IN VARCHAR2
	, p_Prefix 		IN VARCHAR2
	, p_Suffix 		IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN VARCHAR2;
--
--returns TRUE if p_start_pointer = p_end_pointer else returns FALSE

FUNCTION equal_pointers
	( p_start_pointer 	IN  BIS_VG_TYPES.view_character_pointer_type
	, p_end_pointer   	IN  BIS_VG_TYPES.view_character_pointer_type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN BOOLEAN;
--
-- returns the string between p_start and p_end
-- end is not included

FUNCTION get_string
	( p_view_table     	IN bis_vg_types.View_Text_Table_Type
	, p_start_pointer  	IN bis_vg_types.View_Character_Pointer_Type
	, p_end_pointer    	IN bis_vg_types.View_Character_Pointer_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN VARCHAR2;

-- returns the charater pointed to by the p_pointer
FUNCTION get_char
	( p_view_table     	IN bis_vg_types.View_Text_Table_Type
	, p_pointer        	IN bis_vg_types.View_Character_Pointer_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN VARCHAR2;

-- increments pointer by one
FUNCTION increment_pointer
	( p_view_table     	IN bis_vg_types.View_Text_Table_Type
	, p_pointer        	IN bis_vg_types.View_Character_Pointer_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN bis_vg_types.view_character_pointer_type;

-- concatenates p_View_Table_A with p_View_Table_B
PROCEDURE concatenate_Tables
	( p_View_Table_A 	IN  BIS_VG_TYPES.View_Text_Table_Type
	, p_View_Table_B 	IN  BIS_VG_TYPES.View_Text_Table_Type
	, x_View_Table   	OUT BIS_VG_TYPES.View_Text_Table_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	);
-- concatenates p_View_Table_A with p_View_Table_B  Flex_Column_Comment
PROCEDURE concatenate_Tables
       ( p_View_Table_A IN  BIS_VG_TYPES.Flex_Column_Comment_Table_Type
       , p_View_Table_B IN  BIS_VG_TYPES.Flex_Column_Comment_Table_Type
       , x_View_Table   OUT BIS_VG_TYPES.Flex_Column_Comment_Table_Type
       , x_return_status       OUT VARCHAR2
       , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
       );
-- copies the part between the pointers into a table
-- character pointed to by start is copied
-- character pointed to by end is not copied

PROCEDURE copy_part_of_table
	( p_View_Table_A  	IN  BIS_VG_TYPES.View_Text_Table_Type
	, p_start_pointer 	IN  BIS_VG_TYPES.view_character_pointer_type
	, p_end_pointer   	IN  BIS_VG_TYPES.view_character_pointer_type
	, x_View_Table    	OUT BIS_VG_TYPES.View_Text_Table_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	);

PROCEDURE print_View_Text
	( p_View_Text_Table 	IN BIS_VG_TYPES.View_Text_Table_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	);

PROCEDURE print_View_pointer
	( p_pointer 		IN BIS_VG_TYPES.View_character_pointer_type
	, x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	);

-- position the pointer before trailing characters
FUNCTION position_before_characters
	( p_View_Text_Table 	IN BIS_VG_TYPES.view_text_table_type
	, p_str             	IN VARCHAR2
	, p_pointer         	IN bis_vg_types.view_character_pointer_type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN bis_vg_types.view_character_pointer_type;

-- position the pointer before trailing characters
FUNCTION position_before_characters
	( p_View_Text_Table 	IN BIS_VG_TYPES.view_text_table_type
	, p_str             	IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN bis_vg_types.view_character_pointer_type;

-- decrements pointer by one
FUNCTION decrement_pointer
	( p_view_table     	IN bis_vg_types.View_Text_Table_Type
	, p_pointer       	IN bis_vg_types.View_Character_Pointer_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN bis_vg_types.view_character_pointer_type;

-- return TRUE if pointer is a null
FUNCTION null_pointer
	(p_pointer		IN bis_vg_types.view_character_pointer_type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN BOOLEAN;

-- returns the row pointed to by the pointer
FUNCTION get_row
	( p_view_table     	IN bis_vg_types.View_Text_Table_Type
	, p_pointer        	IN bis_vg_types.View_Character_Pointer_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN bis_vg_types.view_text_table_rec_type;

-- increments the pointer to next row
FUNCTION increment_pointer_by_row
	( p_view_table     	IN bis_vg_types.View_Text_Table_Type
	, p_pointer        	IN bis_vg_types.View_Character_Pointer_Type
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
        )
RETURN bis_vg_types.view_character_pointer_type;

-- this function returns the generated view name for the original view name
FUNCTION get_generated_view_name
	(p_view_name 		IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
	)
RETURN VARCHAR2;

-- these procedures check and puts the error message on the message stack
PROCEDURE add_message
	( p_msg_name  		IN VARCHAR2
        , p_msg_level 		IN NUMBER
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
        );

PROCEDURE add_message
	( p_msg_name  		IN VARCHAR2
        , p_msg_level 		IN NUMBER
        , p_token1    		IN VARCHAR2
        , p_value1    		IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
        );

PROCEDURE add_message
	( p_msg_name  		IN VARCHAR2
        , p_msg_level 		IN NUMBER
        , p_token1    		IN VARCHAR2
        , p_value1    		IN VARCHAR2
        , p_token2    		IN VARCHAR2
        , p_value2    		IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
        );

PROCEDURE add_message
	( p_msg_name  		IN VARCHAR2
        , p_msg_level 		IN NUMBER
        , p_token1    		IN VARCHAR2
        , p_value1    		IN VARCHAR2
        , p_token2    		IN VARCHAR2
        , p_value2    		IN VARCHAR2
        , p_token3    		IN VARCHAR2
        , p_value3    		IN VARCHAR2
        , x_return_status       OUT VARCHAR2
        , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
        );

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
);

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_VG_UTIL.G_ERROR
, p_token1    	      IN VARCHAR2
, p_value1    	      IN VARCHAR2
, p_error_table       IN  BIS_VG_UTIL.Error_Tbl_Type
, x_error_table       OUT BIS_VG_UTIL.Error_Tbl_Type
);

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
);

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
);

PROCEDURE Add_Error_Message
( p_error_msg_id      IN  NUMBER    := NULL
, p_error_msg_name    IN  VARCHAR2  := NULL
, p_error_description IN  VARCHAR2  := NULL
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_VG_UTIL.G_ERROR
, p_error_table       IN  BIS_VG_UTIL.Error_Tbl_Type
, x_error_table       OUT BIS_VG_UTIL.Error_Tbl_Type
);

FUNCTION Find_Flex_Prompt(p_db_link        IN VARCHAR2
, p_view_owner   IN VARCHAR2
, p_view_name    IN VARCHAR2
,p_column_name  IN VARCHAR2
, p_language     IN VARCHAR2 )
RETURN VARCHAR2;

END BIS_VG_UTIL;

 

/
