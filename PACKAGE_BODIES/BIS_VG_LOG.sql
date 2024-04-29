--------------------------------------------------------
--  DDL for Package Body BIS_VG_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VG_LOG" AS
/* $Header: BISTLOGB.pls 115.8 2003/11/05 20:00:03 dbowles ship $ */

--
--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTLOGB.pls
--
--  DESCRIPTION
--
--      body of package which writes the log for generated business views
--
--  NOTES
--
--  HISTORY
--
--  21-Aug-1998 ANSINGHA created
--  08-Jan-2001 Walid.Nasrallah Modified to add write_error_to_string
--  11-DEC-01 Edited by DBOWLES  Added dr driver comments.
--
--
--=====================
--PRIVATE CONSTANTS
--=====================
g_line_length CONSTANT NUMBER := 80;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'bis_vg_log';
G_newline CONSTANT varchar2(2) := '
';

--=====================
--PRIVATE TYPES
--=====================
--
-- ============================================================================
--TYPE : View_Generator_Result_Type
-- ============================================================================

g_dummy_result VARCHAR2(10);
SUBTYPE generation_result IS g_dummy_result%TYPE;

TYPE View_Gen_Success_Type IS  -- local type
RECORD
  ( business_view_name bis_vg_types.view_name_type  -- original view name
  , gen_view_name      bis_vg_types.view_name_type  -- generated view/message
  );
--
-- ============================================================================
--TYPE : View_Generator_Success_Table_Type
-- ============================================================================
TYPE  View_Gen_success_Table_Type  IS  -- local type
TABLE OF View_Gen_Success_Type
INDEX BY BINARY_INTEGER;
--
--
g_gen_success_table view_gen_success_table_type;
--
--
--
TYPE View_Gen_Failure_Type IS  -- local type
RECORD
( business_view_name bis_vg_types.view_name_type := FND_API.G_MISS_CHAR
, Error_Msg_ID       Number         := FND_API.G_MISS_NUM
, Error_Msg_Name     VARCHAR2(30)   := FND_API.G_MISS_CHAR
, Error_Description  VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Error_Proc_Name    VARCHAR2(100)  := FND_API.G_MISS_CHAR
, Error_Type         VARCHAR2(1)
);
--
-- ============================================================================
--TYPE : View_Generator_Failure_Table_Type
-- ============================================================================
TYPE  View_Gen_failure_Table_Type  IS  -- local type
TABLE OF View_Gen_Failure_Type
INDEX BY BINARY_INTEGER;
--
--
g_gen_failure_table view_gen_failure_table_type;
--
-- ============================================================================
--PROCEDURE : Init_Log
--PARAMETERS
--  1. x_return_status    error or normal
--  2. x_error_Tbl        table of error messages

--COMMENT   : Call this function to start logging the messages
--RETURN    : None
--EXCEPTION : None
-- ============================================================================

PROCEDURE init_log
    ( x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
BEGIN
  bis_debug_pub.Add('> init_log');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_gen_success_table.DELETE;
  g_gen_failure_table.DELETE;
  bis_debug_pub.Add('< init_log ');

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
      , p_error_proc_name   => G_PKG_NAME||'.init_log'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END init_log;

-- ============================================================================
--PROCEDURE : Update_Success_Log
--PARAMETERS: 1. p_OrigBV - Original business view  name
--            2. p_GenBV  - Generated Business View name
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
--COMMENT   : Call this function to log a successful generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE update_success_log
    ( p_origbv IN bis_vg_types.view_name_type
    , p_genbv  IN bis_vg_types.view_name_type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_result view_gen_success_type;
BEGIN

  bis_debug_pub.Add('> update_success_log');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_result.business_view_name := p_origbv;
  l_result.gen_view_name      := p_genbv;
  g_gen_success_table(g_gen_success_table.COUNT + 1) := l_result;
  bis_debug_pub.Add('< update_success_log');

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
      , p_error_proc_name   => G_PKG_NAME||'.update_success_log'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END update_success_log;



-- ============================================================================
--PROCEDURE : Update_Failure_Log
--PARAMETERS: 1. p_OrigBV - Original business view  name
--            2. p_code   - code for the error message
--            3. p_errm   - error message
--            4. x_return_status    error or normal
--            5. x_error_Tbl        table of error messages
--COMMENT   : Call this function to log failed generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE update_failure_log
    ( p_origbv IN bis_vg_types.view_name_type
    , p_code   IN NUMBER
    , p_errm   IN VARCHAR2
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_result view_gen_failure_type;
l_str    VARCHAR2(100);
BEGIN
  bis_debug_pub.Add('> update_failure_log');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_result.business_view_name := p_origbv;
  l_result.Error_Msg_ID       := p_code;
  l_result.Error_Description  := p_errm;

  g_gen_failure_table(g_gen_failure_table.COUNT + 1) := l_result;

  bis_debug_pub.Add('< update_failure_log');

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
      , p_error_proc_name   => G_PKG_NAME||'.update_failure_log'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END update_failure_log;

-- ============================================================================
--PROCEDURE : Update_Failure_Log
--PARAMETERS: 1. p_error_Tbl - table containint one or more error messages
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : This overloaded version of Update_Failure_Log generates
--            a partiual log of failure at teh point where it occurs.
--RETURN    : None
--EXCEPTION : None
-- ============================================================================

PROCEDURE update_failure_log
    ( p_error_Tbl           IN BIS_VG_UTIL.Error_Tbl_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_result view_gen_failure_type;
l_str    VARCHAR2(100);
BEGIN
  bis_debug_pub.Add('> update_failure_log');
  bis_debug_pub.add('g_gen_failure_table.count = '||g_gen_failure_table.count);
  bis_debug_pub.add('p_error_Tbl.count = '||p_error_Tbl.count);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for i in 1 .. p_error_Tbl.count loop
    l_result.Error_Msg_ID       := p_error_Tbl(i).Error_Msg_ID;
    l_result.Error_Msg_Name     := p_error_Tbl(i).Error_Msg_Name;
    l_result.Error_Description  := p_error_Tbl(i).Error_Description;
    l_result.Error_Proc_Name    := p_error_Tbl(i).Error_Proc_Name;
    l_result.Error_Type         := p_error_Tbl(i).Error_Type;

    g_gen_failure_table(g_gen_failure_table.COUNT + 1) := l_result;
  end loop;

  bis_debug_pub.add('g_gen_failure_table.count = '||g_gen_failure_table.count);
  bis_debug_pub.Add('< update_failure_log');
  bis_debug_pub.debug_off;

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
      , p_error_proc_name   => G_PKG_NAME||'.update_failure_log'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END update_failure_log;

-- ============================================================================
--PROCEDURE : backpatch_failure_log
--PARAMETERS: 1. p_OrigBV - Original business view  name
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : Function fills in view name where missing.  Used in
--            conjunction with the short version of update_failure_log.
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE backpatch_failure_log
  ( p_origbv IN bis_vg_types.view_name_type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
   l_counter  NUMBER;
BEGIN
   bis_debug_pub.Add('> backpatch_failure_log');

   FOR l_counter IN REVERSE 1..g_gen_failure_table.COUNT
     LOOP
	-- Find missing view names starting from ther high end
	IF g_gen_failure_table(l_counter).business_view_name
	  = FND_API.G_MISS_CHAR
	  THEN
          g_gen_failure_table(l_counter).business_view_name := p_origbv;


--- The following is deleted to allow back-patching of multiple entries
---          ELSE
---          -- We are done with the most recent portion of the table
---          EXIT; -- from the loop
         END IF;
     END LOOP;
  bis_debug_pub.Add('< backpatch_failure_log');

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
      , p_error_proc_name   => G_PKG_NAME||'.backpatch_failure_log'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END backpatch_failure_log;

-- ============================================================================
-- PROCEDURE : Write_string
-- PARAMETERS 1. p_mode    [production, test, ...]
--            2. p_string              IN  VARCHAR2
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
-- COMMENT   : Call this function to write string to the output
-- RETURN    : None
-- EXCEPTION : None
-- ============================================================================
PROCEDURE write_string
    ( p_mode            IN  bis_vg_Types.view_generator_mode_type
    , p_string          IN  VARCHAR2
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
BEGIN

  bis_debug_pub.Add('> write_string');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_mode = bis_vg_types.production_mode) THEN
    fnd_file.put_line(fnd_file.OUTPUT, p_string);
--    fnd_file.new_line(fnd_file.OUTPUT);
  ELSE
     bis_debug_pub.debug_on;
     bis_debug_pub.ADD(p_string);
     bis_debug_pub.debug_off;
  END IF;
  bis_debug_pub.Add('< write_string');


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
      , p_error_proc_name   => G_PKG_NAME||'.write_string'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_string;

-- ============================================================================
-- PROCEDURE : Write_blank_line
-- PARAMETERS 1. p_mode    [production, test, ...]
--            2. p_count   number of blank lines
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
-- COMMENT   : Call this function to write the list of success full conversion
-- RETURN    : None
-- EXCEPTION : None
-- ============================================================================
PROCEDURE write_blank_line
    ( p_mode  IN bis_vg_Types.view_generator_mode_type
    , p_count IN NUMBER
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
BEGIN
  bis_debug_pub.Add('> write_blank_line');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i IN 1 .. p_count LOOP
    write_string ( p_mode
                 , ' '
		 , x_return_status
		 , x_error_Tbl
		 );
  END LOOP;
  bis_debug_pub.Add('< write_blank_line');


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
      , p_error_proc_name   => G_PKG_NAME||'.write_blank_line'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_blank_line;

-- ============================================================================
--PROCEDURE : Write_inputs
--PARAMETERS 1. p_mode    [production, test, ...]
--           2. p_all_flag            IN  VARCHAR2
--           3. p_App_Short_Name      IN  BIS_VG_TYPES.App_Short_Name_Type
--           4. p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
--           5. p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type
--           6. p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
--           7. p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type
--           8. p_Lookup_Table_Name   IN  VARCHAR2
--           9. p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type
--           10. p_View_Name          IN  BIS_VG_TYPES.View_Name_Type
--           11. x_return_status    error or normal
--           12. x_error_Tbl        table of error messages
--COMMENT   : Call this function to write inputs to the function
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE write_inputs
    ( p_mode                IN  bis_vg_Types.view_generator_mode_type
    , p_all_flag            IN  VARCHAR2
    , p_App_Short_Name      IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type
    , p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type
    , p_Lookup_Table_Name   IN  VARCHAR2
    , p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type
    , p_View_Name           IN  BIS_VG_TYPES.View_Name_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_str    VARCHAR2(100);
l_length NUMBER;
BEGIN

  bis_debug_pub.Add('> write_inputs');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                 , 'BIS_VG_INPUT_PARAMETERS'
                                 );

  write_string ( p_mode
               , l_str
	       , x_return_status
	       , x_error_Tbl
	       );
  l_length := Length(l_str);
  l_str := '-';
  l_str := Rpad(l_str, l_length, '-');
  write_string ( p_mode
               , l_str
	       , x_return_status
	       , x_error_Tbl
	       );

  write_blank_line ( p_mode
                   , 1
		   , x_return_status
		   , x_error_Tbl
		   );

  IF (p_all_flag = fnd_api.g_true) THEN
    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_ALL_VIEWS'
                                   );

    write_string ( p_mode
               , l_str || ' ' || p_all_flag
	       , x_return_status
	       , x_error_Tbl
	       );

  ELSIF (p_view_name IS NOT  NULL) THEN
    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_VIEW_NAME'
                                   );

    write_string ( p_mode
                 , l_str || ' ' || p_view_name
		 , x_return_status
		 , x_error_Tbl
		 );


  ELSIF (p_app_short_name IS NOT NULL) THEN
    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_APP'
                                   );

    write_string ( p_mode
                 , l_str || ' ' || p_app_short_name
		 , x_return_status
		 , x_error_Tbl
		 );
  ELSIF (p_kf_appl_short_name IS NOT NULL) THEN
    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_APP'
                                   );

    write_string ( p_mode
                 , l_str || ' ' || p_kf_appl_short_name
		 , x_return_status
		 , x_error_Tbl
		 );
    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_KFX'
                                   );


    write_string ( p_mode
                 , l_str || ' ' || p_Key_Flex_Code
		 , x_return_status
		 , x_error_Tbl
		 );

  ELSIF (p_df_appl_short_name IS NOT NULL) then
    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_APP'
                                   );

    write_string ( p_mode
                 , l_str || ' ' || p_df_appl_short_name
		 , x_return_status
		 , x_error_Tbl
		 );

    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_DFX'
                                   );

    write_string ( p_mode
                 , l_str || ' ' || p_Desc_Flex_Name
		 , x_return_status
		 , x_error_Tbl
		 );

  ELSE
    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_LOOKUP_TABLE_NAME'
                                   );

    write_string ( p_mode
                 , l_str || ' ' || p_Lookup_Table_Name
		 , x_return_status
		 , x_error_Tbl
		 );

    l_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                   , 'BIS_VG_INPUT_LOOKUP_TYPE'
                                   );
    write_string ( p_mode
                 , l_str || ' ' || p_Lookup_Type
		 , x_return_status
		 , x_error_Tbl
		 );

  END IF;

  bis_debug_pub.Add('< write_inputs');

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
      , p_error_proc_name   => G_PKG_NAME||'.write_inputs'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_inputs;

-- ============================================================================
-- PROCEDURE : Write_header
-- PARAMETERS 1. p_mode    [production, test, ...]
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
-- COMMENT   : Call this function to write the report header
-- RETURN    : None
-- EXCEPTION : None
-- ============================================================================
PROCEDURE write_header
    ( p_mode IN  bis_vg_Types.view_generator_mode_type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type    )
IS
l_date VARCHAR2(80);
l_head VARCHAR2(80);
l_str  VARCHAR2(120);
BEGIN
  bis_debug_pub.Add('> write_header');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_head := fnd_message.get_string( BIS_VG_TYPES.message_application
                                  , 'BIS_VG_GENERATOR_NAME'
                                  );

  l_date := To_char(Sysdate, 'DD-MON-YYYY HH:MI');
  l_str := Lpad(l_head, g_line_length/2 + Length(l_head)/2);
  l_date := Lpad(l_date, g_line_length - Length(l_str));
  l_str := l_str||l_date;
  write_string ( p_mode
               , l_str
	       , x_return_status
	       , x_error_Tbl
	       );
  bis_debug_pub.Add('< write_header');


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
      , p_error_proc_name   => G_PKG_NAME||'.write_header'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_header;

-- ============================================================================
-- PROCEDURE : Write_SUCCESS_views
-- PARAMETERS 1. p_mode    [production, test, ...]
--            2. p_gen_success_table IN view_gen_success_table_type
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
-- COMMENT   : Call this function to write the list of success full conversion
-- RETURN    : None
-- EXCEPTION : None
-- ============================================================================
PROCEDURE write_success_views
    ( p_mode              IN bis_vg_Types.view_generator_mode_type
    , p_gen_success_table IN view_gen_success_table_type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_src    VARCHAR2(100);
l_des    VARCHAR2(100);
l_pad    NUMBER;
l_result view_gen_success_type;
BEGIN

  bis_debug_pub.Add('> write_success_views');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_src := fnd_message.get_string( BIS_VG_TYPES.message_application
                                 , 'BIS_VG_SOURCE_VIEW_HEADING'
                                 );

  l_des := fnd_message.get_string( BIS_VG_TYPES.message_application
                                 , 'BIS_VG_GENERATED_VIEW_HEADING'
                                 );

  l_src := Rpad(l_src, 30);
  l_des := Rpad(l_des, 30);

  write_string ( p_mode
               , l_src||' '||l_des
	       , x_return_status
	       , x_error_Tbl
	       );
  write_string ( p_mode
               , '------------------------------------------------------------'
	       , x_return_status
	       , x_error_Tbl
	       );

  FOR i IN 1 .. p_gen_success_table.COUNT LOOP
    l_result := p_gen_success_table(i);

    l_src := l_result.business_view_name;
    l_des := l_result.gen_view_name;

    l_src := Rpad(l_src, 30);
    l_des := Rpad(l_des, 30);

    write_string ( p_mode
                 , l_src||' '||l_des
		 , x_return_status
		 , x_error_Tbl
		 );
  END LOOP;

  bis_debug_pub.Add('< write_success_views');

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
      , p_error_proc_name   => G_PKG_NAME||'.write_success_views'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_success_views;

-- ============================================================================
-- PROCEDURE : Write_FAILURE_views
-- PARAMETERS 1. p_mode    [production, test, ...]
--            2. p_gen_success_table IN view_gen_success_table_type
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
-- COMMENT   : Call this function to write the list of success full conversion
-- RETURN    : None
-- EXCEPTION : None
-- ============================================================================
PROCEDURE write_failure_views
( p_mode              IN bis_vg_Types.view_generator_mode_type
, p_gen_failure_table IN view_gen_failure_table_type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
)
IS
l_result           view_gen_failure_type;
l_failure          BOOLEAN := FALSE;
l_start            NUMBER := 1;
l_view_name_prompt VARCHAR2(100);
l_err_code_prompt  VARCHAR2(100);
l_err_msg_prompt   VARCHAR2(100);
BEGIN
  bis_debug_pub.Add('> write_failure_views');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN l_start .. p_gen_failure_table.COUNT LOOP
    l_result := p_gen_failure_table(i);

    write_blank_line ( p_mode
                     , 1
		     , x_return_status
		     , x_error_Tbl
		     );
    write_string ( p_mode
		   , l_result.business_view_name
		   , x_return_status
		   , x_error_Tbl
		   );
    write_string ( p_mode
		   , l_result.error_proc_name
		   , x_return_status
		   , x_error_Tbl
		   );
    write_string ( p_mode
		   , l_result.error_description
		   , x_return_status
		   , x_error_Tbl
		   );
  END LOOP;

  bis_debug_pub.Add('< write_failure_views');

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
      , p_error_proc_name   => G_PKG_NAME||'.write_failure_views'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_failure_views;

-- ============================================================================
--PROCEDURE : Write_Log
--PARAMETERS 1. p_mode                IN  bis_vg_Types.view_generator_mode_type
--           2. p_all_flag            IN  VARCHAR2
--           3. p_App_Short_Name      IN  BIS_VG_TYPES.App_Short_Name_Type
--           4. p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
--           5. p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type
--           6. p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
--           7. p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type
--           8. p_Lookup_Table_Name   IN  VARCHAR2
--           9. p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type
--           10. p_View_Name          IN  BIS_VG_TYPES.View_Name_Type
--           11. x_return_status    error or normal
--           12. x_error_Tbl        table of error messages
--COMMENT   : Call this function to write the log to the out file in production
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE write_log
    ( p_mode                IN  bis_vg_types.View_Generator_Mode_Type
    , p_all_flag            IN  VARCHAR2
    , p_App_Short_Name      IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type
    , p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type
    , p_Lookup_Table_Name   IN  VARCHAR2
    , p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type
    , p_View_Name           IN  BIS_VG_TYPES.View_Name_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
IS
l_msg_str    VARCHAR2(2000);
BEGIN
  bis_debug_pub.Add('> write_log');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  write_header ( p_mode, x_return_status, x_error_Tbl);
  write_blank_line(p_mode, 1, x_return_status, x_error_Tbl);
  write_inputs( p_mode
              , p_all_flag
              , p_App_Short_Name
              , p_KF_Appl_Short_Name
              , p_Key_Flex_Code
              , p_DF_Appl_Short_Name
              , p_Desc_Flex_Name
              , p_Lookup_Table_Name
              , p_Lookup_Type
              , p_View_Name
	      , x_return_status
	      , x_error_Tbl
              );
  write_blank_line(p_mode, 1, x_return_status, x_error_Tbl);

  IF (g_gen_success_table.COUNT > 0) THEN
    IF (g_gen_failure_table.COUNT <> 0) THEN
      l_msg_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                         , 'BIS_VG_SOME_VIEWS_SUCCESSFUL'
                                         );
    ELSE
      l_msg_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                         , 'BIS_VG_ALL_VIEWS_SUCCESSFUL'
                                         );
    END IF;
    write_string(p_mode, l_msg_str, x_return_status, x_error_Tbl);
    write_blank_line(p_mode, 1, x_return_status, x_error_Tbl);

    write_success_views ( p_mode
                        , g_gen_success_table
			, x_return_status
			, x_error_Tbl
			);
    write_blank_line(p_mode, 1, x_return_status, x_error_Tbl);
  END IF;

    bis_debug_pub.add('g_gen_failure_table.count = '||g_gen_failure_table.count);
  IF (g_gen_failure_table.COUNT > 0) THEN
    IF (g_gen_success_table.COUNT = 0) THEN
      l_msg_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                         , 'BIS_VG_ALL_VIEWS_UNSUCCESSFUL'
                                         );
    ELSE
      l_msg_str := fnd_message.get_string( BIS_VG_TYPES.message_application
                                         , 'BIS_VG_SOME_VIEWS_UNSUCCESSFUL'
                                         );
    END IF;
    write_string(p_mode, l_msg_str, x_return_status, x_error_Tbl);
    write_blank_line(p_mode, 1, x_return_status, x_error_Tbl);
    write_failure_views ( p_mode
                        , g_gen_failure_table
			, x_return_status
			, x_error_Tbl
			);
    write_blank_line(p_mode, 1, x_return_status, x_error_Tbl);
  END IF;

  IF (p_mode = bis_vg_types.production_mode) THEN
    fnd_file.CLOSE;
  END IF;
  bis_debug_pub.Add('< write_log');

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
      , p_error_proc_name   => G_PKG_NAME||'.write_log'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END write_log;


-- ============================================================================
-- PROCEDURE : Write_Error_to_String
-- PARAMETERS 1. x_error_string        String to hold error messages
-- COMMENT   : Call this function to access the list of errors in g_failure_log
-- RETURN    : None
-- EXCEPTION : None
-- ============================================================================
PROCEDURE write_error_to_string
( x_error_string       OUT VARCHAR2
)
IS
l_result           view_gen_failure_type;
l_start            NUMBER := 1;
BEGIN
  bis_debug_pub.Add('> write_error_to_string');
         x_error_string := x_error_string
	   || g_newline
	   || 'Error Count = '
	   || g_gen_failure_table.COUNT;

  FOR i IN l_start .. g_gen_failure_table.COUNT LOOP
    l_result := g_gen_failure_table(i);
    x_error_string :=
         x_error_string
      || g_newline
      || 'Reported by Procedure: '
      || l_result.error_proc_name
      || g_newline
      || 'Error Message: '
      || l_result.error_description
      || g_newline;
  END LOOP;

  bis_debug_pub.Add('< write_error_to_string');

EXCEPTION
---   WHEN numeric_or_value_error THEN
---      --- This might happen if the string becomes too long
---      x_error_string :=
---	x_error_string
---	|| g_newline
---	|| 'Error string too long - too many errors';

   WHEN FND_API.G_EXC_ERROR then
      x_error_string :=
	x_error_string
	|| g_newline
	|| '***CAUTION: Error ''G_EXC_ERROR'' occurred in write_error_to_string';

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
      x_error_string :=
	x_error_string
	|| g_newline
	|| '***CAUTION: Error ''G_EXC_UNEXPECTED_ERROR'' occurred '
	|| 'in Write_error_to_string';

   WHEN others then
      x_error_string :=
	x_error_string
	|| g_newline
	|| '*** CAUTION: Error Code '
	|| SQLCODE
	|| g_newline
	|| 'Relayed Error Message : '
	|| SQLERRM
	|| g_newline
	|| ' occurred in write_error_to_string';

END write_error_to_string;

END BIS_VG_LOG;

/
