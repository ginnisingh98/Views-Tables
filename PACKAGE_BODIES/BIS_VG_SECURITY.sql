--------------------------------------------------------
--  DDL for Package Body BIS_VG_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_SECURITY" AS
/* $Header: BISTSECB.pls 115.8 2002/03/27 08:18:49 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTLATB.pls
--
--  DESCRIPTION
--
--      body of view genrator to substitute lookup code
--
--  NOTES
--
--  HISTORY
--
--  23-JUL-98 Created
--  11-MAR-99 Modified by WNASRALL.US
--  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
--


TYPE TAG_FUNC_PAIR IS RECORD
  (SECURITY_TAG varchar2(100)
   , SECURITY_FUNCTION varchar2(1000)
   );

TYPE TAG_FUNC_TABLE IS Table of TAG_FUNC_PAIR
  INDEX BY BINARY_INTEGER;

G_SECURITY_FUNCTION_TABLE TAG_FUNC_TABLE;

G_PKG_NAME CONSTANT VARCHAR(30) := 'BIS_VG_SECURITY';


--============================================================================
--PROCEDURE : parse_SEC_select
--  PARAMETERS:
--  1. p_View_Select_Table  table of varchars to hold select
--  2. p_pointer     	    pointer to the lookup column in select table
--  3. x_tbl 		    name of security column
--  4. x_app	  	    the application to use for security
--  5. x_pointer	    pointer to the character after the delimiter
-- 			    (select table)
--  6. x_return_status      error or normal
--  7. x_error_Tbl          table of error messages
----
--  COMMENT   : Call this procedure to add a particular lookup select
--              information to a view.
--EXCEPTION : None
--  ==========================================================================


PROCEDURE parse_SEC_select
  ( p_View_Select_Table 	IN  BIS_VG_TYPES.View_Text_Table_Type
    , p_pointer    	IN  BIS_VG_TYPES.View_Character_Pointer_Type
    , x_tbl      		OUT VARCHAR2
    , x_app      		OUT VARCHAR2
    , x_pointer    	OUT BIS_VG_TYPES.View_Character_Pointer_Type
    , x_return_status     OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
  IS
     l_pointer   BIS_VG_TYPES.View_Character_Pointer_Type;
     l_tag      VARCHAR2(300);
     l_index    NUMBER;
  BEGIN
     BIS_DEBUG_PUB.Add('>  parse_SEC_select');
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- get the security tag
     l_tag := bis_vg_parser.skip_tag
       ( p_view_select_table
	 , p_pointer
	 , l_pointer
	 , x_return_status
	 , x_error_Tbl
	 );

     -- get the table alias
     x_tbl := bis_vg_parser.get_token ( p_view_select_table
					, l_pointer
					, ':'''
					, l_pointer
					, x_return_status
					, x_error_Tbl
					);

     IF (x_tbl IS NULL) THEN
        BIS_VG_UTIL.Add_Error_message
	  ( p_error_msg_name => bis_vg_security.SECURITY_COL_EXP_MSG
	    , p_error_proc_name   => G_PKG_NAME||'.parse_SEC_select '
	    , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
	    , p_token1        => 'tag'
	    , p_value1        => l_tag
	    , p_error_table       => x_error_tbl
	    , x_error_table       => x_error_tbl
	    );
	bis_vg_log.update_failure_log( x_error_tbl
				       , x_return_status
				       , x_error_Tbl
				       );
        RAISE FND_API.G_EXC_ERROR;

     END IF;
     x_app := bis_vg_util.get_char(p_view_select_table
				   , l_pointer
				   , x_return_status
				   , x_error_Tbl
				   );

     l_tag := l_tag || ':' || x_tbl || x_app;


     IF (x_app = ':') THEN
	-- there is an application id which is separate
	l_pointer := bis_vg_util.increment_pointer( p_view_select_table
						    , l_pointer
						    , x_return_status
						    , x_error_Tbl
						    );
	-- get the organization id
	x_app := x_tbl;
	BIS_DEBUG_PUB.Add('Application  = ' || x_app);

	-- Find the field name
	x_tbl := bis_vg_parser.get_token_increment_pointer( p_view_select_table
							    , l_pointer
							    , ''''
							    , l_pointer
							    , x_return_status
							    , x_error_Tbl
							    );

	l_tag := l_tag || x_tbl;

	-- Look up the security function
	l_index :=  G_SECURITY_FUNCTION_TABLE.FIRST;

	LOOP
	   IF G_SECURITY_FUNCTION_TABLE(l_index).SECURITY_TAG=UPPER(x_app) THEN
	      x_app := G_SECURITY_FUNCTION_TABLE(l_index).SECURITY_FUNCTION;
	      EXIT;
	   END IF;

	   IF l_index = G_SECURITY_FUNCTION_TABLE.LAST THEN
	      -- No entry for tag
	      BIS_VG_UTIL.Add_Error_message
		( p_error_msg_name => bis_vg_security.SECURITY_FUN_EXP_MSG
		  , p_error_proc_name   => G_PKG_NAME||'. parse_SEC_select'
		  , p_error_table       => x_error_tbl
		  , p_token1        => 'tag'
		  , p_value1        => l_tag
		  , p_token2        => 'function'
		  , p_value2        => x_app
		  , p_error_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR
		  , x_error_table       => x_error_tbl
		  );
	      bis_vg_log.update_failure_log( x_error_tbl
					     , x_return_status
					     , x_error_Tbl
					     );
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   l_index:=G_SECURITY_FUNCTION_TABLE.NEXT(l_index);
	END LOOP;
      ELSE
	-- There is no applicartion-specific  tag, so default to HR security
	x_app := 'HR_SECURITY.SHOW_BIS_RECORD';

     END IF;
     x_pointer := l_pointer;
     BIS_DEBUG_PUB.Add('l_fun = ' || x_app);
     BIS_DEBUG_PUB.Add('l_tbl = ' || x_tbl);
     BIS_DEBUG_PUB.Add('<  parse_SEC_select');


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
	( p_error_msg_id      => SQLCODE
	  , p_error_description => SQLERRM
	  , p_error_proc_name   => G_PKG_NAME||'. parse_SEC_select'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END parse_SEC_select;


-- ============================================================================
--   PROCEDURE : add_Security_Info
--     PARAMETERS:
--     1. p_View_Select_Table  table of varchars to hold SELECT clause of view
--     2. p_security_Pointer   pointer to security tag
--     3. x_Select_Table       table of varchars to hold additional columns
--     4. x_security_pointer   pointer at end of security
--     5. x_return_status    error or normal
--     6. x_error_Tbl        table of error messages
--
--   COMMENT   : Call this procedure to add a security information to a view.
--   EXCEPTION : None
-- ===========================================================================
PROCEDURE add_Security_Info
( p_View_Select_Table IN  BIS_VG_TYPES.View_Text_Table_Type
, p_security_pointer  IN  BIS_VG_TYPES.view_character_pointer_type
, x_Select_Table      OUT BIS_VG_TYPES.view_text_table_type
, x_security_pointer  OUT  BIS_VG_TYPES.view_character_pointer_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
   IS
   l_tbl      VARCHAR2(100);
   l_app      VARCHAR2(100);
   l_result   VARCHAR2(1000);
   l_pointer  BIS_VG_TYPES.view_character_pointer_type;
   l_Table    BIS_VG_TYPES.view_text_table_type;
BEGIN

   BIS_DEBUG_PUB.Add('> add_Security_Info ');
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      Parse_SEC_Select ( p_View_Select_Table
		      , p_security_pointer
		      , l_tbl
		      , l_app
		      , l_pointer
		      , x_return_status
		      , x_error_Tbl
		      );

   BIS_DEBUG_PUB.Add('Function  = ' || l_app);
   BIS_DEBUG_PUB.Add('Table Column  = ' || l_tbl);

--     l_result := '( ';
--     l_result := l_result ||l_tbl;
--     l_result := l_result || ' is null or ';

     l_result := l_app;
     l_result := l_result || '( ';
     l_result := l_result ||l_tbl;
     l_result := l_result ||' ) = ''TRUE''';
     --
     BIS_DEBUG_PUB.Add('l_result = ' || l_result);

     x_select_table(x_select_table.COUNT + 1) := l_result;
--
     -- position beyond 'is not null' string
     l_table(1) := 'NULL';
--
     x_security_pointer := bis_vg_parser.get_keyword_position
                                        ( p_View_Select_Table
                                        , l_table
                                        , l_pointer
					, x_return_status
					, x_error_Tbl
                                        );

     -- increment the pointer four times to skip 'null'
     FOR i IN 1 .. 4 LOOP
       x_security_pointer := bis_vg_util.increment_pointer( p_view_select_table
                                                          , x_security_pointer
							  , x_return_status
							  , x_error_Tbl
                                                          );
     END LOOP;
--
     BIS_DEBUG_PUB.Add('< add_Security_Info ');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_VG_UTIL.Add_Error_Message
	( p_error_msg_id      => SQLCODE
	  , p_error_description => SQLERRM
	  , p_error_proc_name   => G_PKG_NAME||'.add_security_Info'
	  , p_error_table       => x_error_tbl
	  , x_error_table       => x_error_tbl
	  );
      bis_vg_log.update_failure_log( x_error_tbl
				     , x_return_status
				     , x_error_Tbl
				     );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END add_security_Info;
--
--

BEGIN

 G_SECURITY_FUNCTION_TABLE(2).SECURITY_TAG := 'HRTST';
 G_SECURITY_FUNCTION_TABLE(2).SECURITY_FUNCTION :=
   'HR_SECURITY.SHOW_BIS_RECORD';
 G_SECURITY_FUNCTION_TABLE(1).SECURITY_TAG := 'GL';
 G_SECURITY_FUNCTION_TABLE(1).SECURITY_FUNCTION :=
   'GL_SECURITY_PKG.VALIDATE_ACCESS';

END BIS_VG_SECURITY;

/
