--------------------------------------------------------
--  DDL for Package Body ASO_DEPENDENCY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_DEPENDENCY_UTIL" AS
/* $Header: asovdpub.pls 120.1.12010000.3 2014/04/03 06:23:49 akushwah ship $ */
-- Package name     : ASO_DEPENDENCY_UTIL
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--CREATE OR REPLACE
--PACKAGE BODY ASO_DEPENDENCY_UTIL AS

--  Global constant holding the package name

G_PKG_NAME      	CONSTANT  VARCHAR2(240):='ASO_DEPENDENCY_UTIL';
line_number			  NUMBER := 0;
g_min				      NUMBER;
g_conc_mode       VARCHAR2(1);
G_APPLICATION_ID  NUMBER  := 697;


-- need to find OUT NOCOPY /* file.sql.39 change */ which log files it puts in.
PROCEDURE Put_Line
     (Text Varchar2)
IS
  l_bol	   boolean := true;
BEGIN


  if g_conc_mode is null then

   if nvl(fnd_profile.value('CONC_REQUEST_ID'),0) <> 0 then
        g_conc_mode := 'Y';
   else
        g_conc_mode := 'N';
   end if;

  end if;

  if g_conc_mode = 'Y' then
    FND_FILE.PUT_LINE(FND_FILE.LOG, Text);
  end if;

  l_bol := true;
  ASO_UPGRADE_PVT.Add_Message(
    p_module_name => 'ASO',
    p_error_level => 'INFORMATION',
    p_error_text  => Text,
    p_source_name => 'asovdpub.pls'
  );

END Put_Line;

PROCEDURE Init_Applsys_Schema
IS
  l_app_info		BOOLEAN;
  l_status			VARCHAR2(30);
  l_industry		VARCHAR2(30);
BEGIN

  IF g_schema is null THEN
    l_app_info := FND_INSTALLATION.GET_APP_INFO('FND',l_status, l_industry, g_schema);
  END IF;

END Init_Applsys_Schema;

PROCEDURE New_Line
IS
BEGIN

    line_number := line_number + 1;
    ad_ddl.build_package(' ',line_number);

END New_Line;

PROCEDURE Text
(   p_string	IN  VARCHAR2
,   p_level	IN  NUMBER default 1
)
IS
BEGIN

  line_number := line_number + 1;
  ad_ddl.build_package(LPAD(p_string,p_level*2+LENGTH(p_string)),line_number);

END text;

PROCEDURE Comment
(   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER default 1
)
IS
BEGIN

  Text('--  '||p_comment,p_level);

END Comment;

PROCEDURE Parameter
(   p_param	    IN  VARCHAR2
,   p_mode	    IN  VARCHAR2  := 'IN'
,   p_type	    IN  VARCHAR2  := 'NUMBER'
,   p_level	    IN  NUMBER default  1
,   p_def_flag  IN  BOOLEAN   := FALSE
,   p_def_str   IN  VARCHAR2  := ''
,   p_rpad	    IN  NUMBER := 30
,   p_first	    IN  BOOLEAN := FALSE
)
IS
  l_first		varchar2(1);
  l_prefix	VARCHAR2(10);
BEGIN

  IF rtrim(p_mode) = 'IN' THEN
    l_prefix := '   P_';
  ELSE
    l_prefix := '   X_';
  END IF;

  IF p_first THEN
    l_first := '(';
  ELSE
    l_first := ',';
  END IF;

--  PUT_LINE(l_prefix||p_param);
  Text(  l_first||l_prefix||RPAD(UPPER(p_param),p_rpad)||RPAD(UPPER(p_mode),4)||UPPER(p_type)
  ,   p_level
  );
--  PUT_LINE(l_first||l_prefix||RPAD(UPPER(p_param),p_rpad)||RPAD(UPPER(p_mode),4)||UPPER(p_type));
  IF p_def_flag THEN
    Text(  LPAD(' ',p_rpad+6)||p_def_str,   p_level    );
  END IF;

END Parameter;

-------------------------------------------------------------------------------
PROCEDURE Pkg_End
(   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
)
IS
  l_is_pkg_body			VARCHAR2(30);
  n					NUMBER := 0;
  CURSOR errors IS
  	SELECT line, text
  	FROM user_errors
  	WHERE name = upper(p_pkg_name)
  	  AND type = decode(p_pkg_type,'SPEC','PACKAGE',
  					'BODY','PACKAGE BODY');
BEGIN

  --	end statement.
  Text('END '||p_pkg_name||';',0);

  --	Show errors.
  IF p_pkg_type = 'BODY' THEN
    l_is_pkg_body := 'TRUE';
  ELSE
    l_is_pkg_body := 'FALSE';
  END IF;

  --PUT_LINE(
  --'Call AD_DDL to create '||p_pkg_type||' of package '||p_pkg_name);


  ad_ddl.create_package(
    applsys_schema          => g_schema,
    application_short_name	=> 'ASO',
    package_name			      => p_pkg_name,
    is_package_body		      => l_is_pkg_body,
    lb					            => 1,
    ub					            => line_number);

  -- if there were any errors when creating this package, print out
  -- the errors in the log file
  FOR error IN errors LOOP
    if n= 0 then
      PUT_LINE('ERROR in creating PACKAGE '||p_pkg_type||' :'||p_pkg_name);
    end if;
    PUT_LINE(
      'LINE :'||error.line||' '||substr(error.text,1,200));
    n := 1;
  END LOOP;

  -- if there was an error in compiling the package, raise
  -- an error
  if  n > 0 then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  exception
    when FND_API.G_EXC_ERROR then
    raise FND_API.G_EXC_ERROR;
    when others THEN
    raise_application_error(-20000,SQLERRM||' '||ad_ddl.error_buf);

END Pkg_End;

-------------------------------------------------------------------------------
-- Generates the Package Header for the package SPEC AND BODY

PROCEDURE Pkg_Header
(   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
)
IS
  header_string		VARCHAR2(200);
BEGIN

  -- Initialize line number
  line_number := 0;

  --	Define package.

  IF p_pkg_type = 'BODY' THEN
    Text ('CREATE or REPLACE PACKAGE BODY '||	p_pkg_name|| ' AS',0);
  ELSE
    Text ('CREATE or REPLACE PACKAGE '|| p_pkg_name|| ' AUTHID CURRENT_USER AS',0);
  END IF;

  --	$Header clause.
  header_string := 'Header: asodphdb.pls 115.0 '||TO_CHAR(SYSDATE, 'DD-MON-YY HH:MI:SS') ||' appldev ship ';
  Text('/* $'||header_string||'$ */',0);
  New_Line;

  --	Copyright section.

  Comment ( '',0 );
  Comment ('Copyright (c) 2004, 2014 Oracle Corporation, Redwood Shores, CA, USA',0);
  Comment ( 'All rights reserved.',0);
  Comment ( '',0);
  Comment ( 'FILENAME',0);
  Comment ( '',0);
  Comment ( '    '||p_pkg_name,0);
  Comment ( '',0);
  Comment ( 'DESCRIPTION',0);
  Comment ( '',0);
  Comment ( '    '||INITCAP(p_pkg_type)||' of package '||p_pkg_name,0);
  Comment ( '',0);
  Comment ('NOTES',0);
  Comment ( '',0);
  Comment ('HISTORY',0);
  Comment ( '',0);
  Comment ( TO_CHAR(SYSDATE)||' Created',0);
  Comment ( '',0);
  New_Line;

  --	Global constant holding package name.

  IF p_pkg_type = 'BODY' THEN
    Comment ( 'Global constant holding the package name',0);
    Text (RPAD('G_PKG_NAME',30)||'CONSTANT '||
	    'VARCHAR2(30) := '''||p_pkg_name||''';',0);
    New_Line;
  END IF;

END Pkg_Header;

PROCEDURE Api_Body_Start
IS
BEGIN

  NEW_LINE;

  -- Construct the prelude logic
  Comment(' Initialize message list if p_init_msg_list is set to TRUE', 1);
    Text('IF fnd_api.to_boolean (', 1);
    Text('     p_init_msg_list', 1);
    Text(' )', 1);
    Text('THEN', 1);
    Text('   fnd_msg_pub.initialize;', 1);
    Text('END IF;', 1);

  NEW_LINE;

  Comment(' Initialize API return status to success ', 1);
    Text('x_return_status := fnd_api.g_ret_sts_success;', 1);

  NEW_LINE;

  Comment('--- ', 1);
  Comment('API body ', 1);
  Comment('--- ', 1);

  NEW_LINE;


END Api_Body_Start;

PROCEDURE Api_Body_End
IS
BEGIN

  NEW_LINE;

  -- Construct the end of the package body

  Comment('--- ', 1);
  Comment(' End of API body ', 1);
  Comment('--- ', 1);

  Comment('Standard Call to get message count ', 1);

  Text('fnd_msg_pub.count_and_get   ( ', 1);
  Text('  p_count           =>  x_msg_count, ', 1);
  Text('  p_data            =>  x_msg_data ', 1);
  Text('  ); ', 1);

  Text('EXCEPTION ', 0);
  Text('  WHEN broadcast_exception THEN', 0);
  Text('    x_return_status := FND_API.G_RET_STS_ERROR;', 0);
  NEW_LINE;

END Api_Body_End;

PROCEDURE  Convert_Hash_To_Array
(   p_hash_table	IN    Boolean_Tbl_Type
  , x_array_table OUT NOCOPY /* file.sql.39 change */   Number_Tbl_Type
)
IS
  l_hash_index		NUMBER;
  l_array_index   NUMBER;
BEGIN

  l_hash_index := p_hash_table.FIRST;
  l_array_index := 1;

  WHILE l_hash_index IS NOT NULL LOOP

    IF p_hash_table(l_hash_index) = TRUE THEN
      x_array_table(l_array_index) := l_hash_index;
	    l_array_index := l_array_index + 1;
    END IF;
	  l_hash_index := p_hash_table.NEXT(l_hash_index);

 END LOOP;

END Convert_Hash_To_Array;

PROCEDURE   Convert_Array_To_Hash
(   p_array_table	IN    Number_Tbl_Type	,
    x_hash_table OUT NOCOPY /* file.sql.39 change */   Boolean_Tbl_Type
)
IS
BEGIN

  /* p_array_table should contain records with continous index */
  FOR i IN p_array_table.FIRST..p_array_table.LAST LOOP
      x_hash_table(p_array_table(i)) := TRUE;
  END LOOP;


END Convert_Array_To_Hash;

PROCEDURE   Mark_Dependent
(   p_trigger_attr_id	IN  NUMBER,
    x_dep_attr_tbl OUT NOCOPY /* file.sql.39 change */  Number_Tbl_Type
)
IS
  l_src_index   NUMBER;
  l_g_dep_index NUMBER;
  l_dep_index   NUMBER;
  l_out_index	    NUMBER;
  l_dep_attr_tbl	    Boolean_Tbl_Type;
  l_src_attr_tbl	    Boolean_Tbl_Type;
  l_examined_attr_tbl Boolean_Tbl_Type;
  l_out_attr_tbl	    Boolean_Tbl_Type;
  l_root_scan         BOOLEAN;
BEGIN


  --	 Populating the source hash table with the trigger attribute id

  l_src_attr_tbl(p_trigger_attr_id) := TRUE;

  -- While the source hash table is not empty

  WHILE l_src_attr_tbl.COUNT <> 0 LOOP

    l_src_index := l_src_attr_tbl.FIRST;

    -- For each trigger attribute in the source hash table
    WHILE l_src_index IS NOT NULL LOOP

      PUT_LINE(' ');
      PUT_LINE('Trigger attribute: ' || TO_CHAR(l_src_index));

	    -- Mark attributes that have been examined.
      l_examined_attr_tbl(l_src_index) := TRUE;
      l_g_dep_index := l_src_index * G_MAX;

	    -- For each Associate in the global dependency hash table
	    -- associated with this trigger attribute.
      WHILE ( g_dep_tbl.EXISTS(l_g_dep_index)
            AND l_g_dep_index < (l_src_index+1) * G_MAX
            )
      LOOP
	      -- put it in dependent attribute table
        l_dep_attr_tbl(g_dep_tbl(l_g_dep_index).attribute) := TRUE;
        PUT_LINE('Dependent attribute: ' || TO_CHAR(g_dep_tbl(l_g_dep_index).attribute));
	      l_g_dep_index := l_g_dep_index + 1;
	    END LOOP; -- next g_dep_tbl entry

      l_src_index := l_src_attr_tbl.NEXT(l_src_index);

    END LOOP; -- next source attribute

	  --  Clear source hash table.
	  l_src_attr_tbl.DELETE;

  	--  Check dependent attributes. If they have been already
  	--  examined then no need to re-check them.
    l_dep_index := l_dep_attr_tbl.FIRST;

    WHILE l_dep_index IS NOT NULL LOOP

	    -- Merge current list of dependent attributes into output hash table
	    l_out_attr_tbl(l_dep_index) := TRUE;

      -- Populate the source hash table with attributes
      -- from current list of dependent attributes but
      -- not in the examined list
	    IF NOT l_examined_attr_tbl.EXISTS(l_dep_index) THEN
		    l_src_attr_tbl(l_dep_index) := TRUE;
	    END IF;

		  l_dep_index := l_dep_attr_tbl.NEXT(l_dep_index);

    END LOOP;

	  --  Clear dependent hash table.
    l_dep_attr_tbl.DELETE;

  END LOOP; -- next set of source attributes from previous round of scan.

  --Convert the output hash table to output list
  convert_hash_to_array(
    p_hash_table  =>  l_out_attr_tbl,
    x_array_table =>  x_dep_attr_tbl);


END Mark_Dependent;

FUNCTION Get_Min_Attribute_ID
  ( P_DATABASE_OBJECT_NAME    VARCHAR2 )
RETURN NUMBER
IS
CURSOR  get_min_attr_id IS
SELECT  min(attribute_id)
FROM    oe_ak_obj_attr_ext
WHERE   database_object_name = p_database_object_name
        AND attribute_application_id = G_APPLICATION_ID;

l_min_attr_id   NUMBER;
BEGIN

  /* Get min(TRIGGER_ATTRIBUTE_ID) from ASO_DEPENDENCY_MAPPINGS */

   OPEN get_min_attr_id;
   FETCH get_min_attr_id INTO l_min_attr_id;
   CLOSE get_min_attr_id;

   RETURN l_min_attr_id;

  --RETURN 10000;

END Get_Min_Attribute_ID;

FUNCTION Get_Dependent_Attributes_Count
  ( P_DATABASE_OBJECT_NAME    VARCHAR2 )
RETURN NUMBER
IS

CURSOR  get_dep_attr_num IS
SELECT  count(distinct dependent_attribute_id)
FROM    aso_dependency_mappings
WHERE   database_object_name = p_database_object_name;

l_dep_attr_count         NUMBER;

BEGIN

  /* Get distinct(DEPENDENT_ATTRIBUTE_ID) from ASO_DEPENDENCY_MAPPINGS */

   OPEN get_dep_attr_num;
   FETCH get_dep_attr_num INTO l_dep_attr_count;
   CLOSE get_dep_attr_num;

   RETURN l_dep_attr_count;
  --RETURN 10;

END Get_Dependent_Attributes_Count;

PROCEDURE Build_Dependencies_Table
  ( P_DATABASE_OBJECT_NAME    VARCHAR2 )
IS

  i                         NUMBER;
  normalized_trigger_id     NUMBER;
  normalized_dependent_id   NUMBER;
  starting_point            NUMBER;
  l_dep_index               NUMBER;

  l_dep_attr_tbl            Number_Tbl_Type;

  CURSOR c_trigger_attributes IS
    SELECT  DISTINCT a.trigger_attribute_id,b.attribute_code
    FROM    ASO_DEPENDENCY_MAPPINGS a,oe_ak_obj_attr_ext b
    WHERE   a.trigger_attribute_id = b.attribute_id
            AND a.database_object_name = p_database_object_name;

  CURSOR c_dependent_attributes(lc_trigger_attribute_id NUMBER) IS
    SELECT  a.dependent_attribute_id,b.attribute_code
    FROM    ASO_DEPENDENCY_MAPPINGS a,oe_ak_obj_attr_ext b
    WHERE   a.dependent_attribute_id = b.attribute_id
    AND     a.trigger_attribute_id = lc_trigger_attribute_id
    AND     a.enabled_flag = 'Y';
BEGIN

  g_min := Get_Min_Attribute_ID(p_database_object_name);
  G_Max := Get_Dependent_Attributes_Count(p_database_object_name);
  PUT_LINE('G_Min: '||TO_CHAR(g_min));
  PUT_LINE('G_Max: '||TO_CHAR(G_Max));
  put_line('     ');

  put_line('Trigger Attribute');
  put_line('******* Direct Dependent_attribute');
  put_line('     ');

  -- populate g_dep_tbl based on TRIGGER_ATTRIBUTE_ID
  FOR l_trigger_attr_rec IN c_trigger_attributes LOOP

    put_line('     ');
    put_line('--------------------');
    put_line(l_trigger_attr_rec.attribute_code);

    normalized_trigger_id := l_trigger_attr_rec.trigger_attribute_id - g_min;
    starting_point := normalized_trigger_id * G_Max;

  	i := 0;
    FOR l_dependent_attr_rec IN c_dependent_attributes(l_trigger_attr_rec.trigger_attribute_id)
    LOOP
      normalized_dependent_id := l_dependent_attr_rec.dependent_attribute_id - g_min;

      g_dep_tbl(starting_point + i).attribute
        := normalized_dependent_id;

	    put_line('-> '||l_dependent_attr_rec.attribute_code);
	    put_line('g_dep_tbl('||TO_CHAR(starting_point + i)
	      ||').attribute = '||TO_CHAR(normalized_dependent_id));
	    i := i + 1;
    END LOOP;

  -- call  Mark_Dependencies
    Mark_Dependent (
      p_trigger_attr_id => normalized_trigger_id,
      x_dep_attr_tbl    => l_dep_attr_tbl);

    put_line('     ');
    put_line('******* Chained Dependent_attribute');
    put_line('     ');
    IF l_dep_attr_tbl.COUNT <> 0
    THEN
      -- Populate g_dep_chain_tbl, which stores chained dependent attributes
    	i := 0;
    	l_dep_index := l_dep_attr_tbl.FIRST;

      WHILE l_dep_index IS NOT NULL
      LOOP

        g_dep_chain_tbl(starting_point + i).attribute
          := l_dep_attr_tbl(l_dep_index);
  	    put_line('-> '||TO_CHAR(l_dep_attr_tbl(l_dep_index)));

  	    i := i + 1;
		    l_dep_index := l_dep_attr_tbl.NEXT(l_dep_index);

      END LOOP;

    END IF;

  END LOOP;

  /* here is just a hack */
  /*
  g_dep_tbl((10000 - g_min) * G_MAX).attribute := 1;
  g_dep_tbl((10000 - g_min) * G_MAX+1).attribute := 2;

  g_dep_tbl((10001 - g_min) * G_MAX).attribute := 0;
  g_dep_tbl((10001 - g_min) * G_MAX+1).attribute := 2;
  */

END Build_Dependencies_Table;



PROCEDURE Make_Dependency_Engine_Body (
  Errbuf                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  RetCode                 OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_database_object_name  IN  VARCHAR2,
  p_primary_key_name      IN  VARCHAR2,
  p_last_update_date_name IN  VARCHAR2)
IS
  l_attribute_code          VARCHAR2(30);
  l_first_loop              BOOLEAN := TRUE;
  l_miss_str                VARCHAR2(30);
  l_pkg_name                VARCHAR2(30);
  l_dep_attr_tbl            Number_Tbl_Type;
  l_string                  VARCHAR2(2000);
  i                         NUMBER;
  l_entity_name             VARCHAR2(15);
  l_ak_view_name            VARCHAR2(30);
  normalized_trigger_id     NUMBER;
  normalized_dependent_id   NUMBER;
  starting_point            NUMBER;
  l_ck_cursor_name          VARCHAR2(30);
  l_ac_cursor_name          VARCHAR2(30);
  l_attribute_name          VARCHAR2(30);
  lv_ak_var_name            VARCHAR2(30);
  l_trigger_code            VARCHAR2(30);
  l_dependent_code          VARCHAR2(30);

  CURSOR c_trigger_attribute IS
    SELECT  DISTINCT a.attribute_code, a.attribute_id, c.column_name
    FROM    oe_ak_obj_attr_ext a, ASO_DEPENDENCY_MAPPINGS b, ak_object_attributes c
    WHERE   b.TRIGGER_ATTRIBUTE_ID = a.attribute_id
            AND a.attribute_application_id = G_APPLICATION_ID
            AND a.database_object_name = p_database_object_name
            AND b.enabled_flag = 'Y'
            AND a.database_object_name = c.database_object_name
            AND a.attribute_code = c.attribute_code
            AND a.attribute_application_id = c.attribute_application_id;

  CURSOR c_all_trigger_attribute IS
    SELECT  DISTINCT a.attribute_code, a.attribute_id, c.column_name
    FROM    oe_ak_obj_attr_ext a, ASO_DEPENDENCY_MAPPINGS b, ak_object_attributes c
    WHERE   b.TRIGGER_ATTRIBUTE_ID = a.attribute_id
            AND a.attribute_application_id = G_APPLICATION_ID
            AND a.database_object_name = p_database_object_name
            AND a.database_object_name = c.database_object_name
            AND a.attribute_code = c.attribute_code
            AND a.attribute_application_id = c.attribute_application_id
    ORDER BY  a.attribute_code;

  CURSOR c_data_type(lc_attribute_code VARCHAR2) IS
    SELECT  DECODE(data_type, 'NUMBER', 'FND_API.G_MISS_NUM',
              'VARCHAR2', 'FND_API.G_MISS_CHAR',
              'DATE', 'FND_API.G_MISS_DATE',
              'FND_API.G_MISS_CHAR')
    FROM    ak_attributes
    WHERE   attribute_code = lc_attribute_code
            AND attribute_application_id = G_APPLICATION_ID;

  CURSOR c_attribute_code(lc_attribute_id NUMBER) IS
    SELECT  attribute_code
    FROM    oe_ak_obj_attr_ext
    WHERE   attribute_id = lc_attribute_id;

  CURSOR c_attribute_column_name(lc_attribute_code VARCHAR2) IS
    SELECT  column_name
    FROM    ak_object_attributes
    WHERE   database_object_name = p_database_object_name
            AND attribute_code = lc_attribute_code;

  CURSOR c_attributes IS
    SELECT  a.attribute_code, a.attribute_id, b.column_name,
            DECODE(data_type, 'NUMBER', 'FND_API.G_MISS_NUM',
              'VARCHAR2', 'FND_API.G_MISS_CHAR',
              'DATE', 'FND_API.G_MISS_DATE',
              'FND_API.G_MISS_CHAR') miss_str
    FROM    oe_ak_obj_attr_ext a, ak_object_attributes b, ak_attributes c
    WHERE   a.attribute_application_id = G_APPLICATION_ID
            AND a.database_object_name = p_database_object_name
            AND a.database_object_name = b.database_object_name
            AND a.attribute_application_id = b.attribute_application_id
            AND a.attribute_code = b.attribute_code
            AND b.attribute_code = c.attribute_code
            and b.attribute_application_id = b.attribute_application_id
    ORDER BY ATTRIBUTE_ID;

  CURSOR c_entity_name is
    SELECT  entity_code
    FROM    oe_ak_objects_ext
    WHERE   database_object_name = p_database_object_name;

BEGIN

  PUT_LINE('p_database_object_name: ' || p_database_object_name);
  PUT_LINE('p_primary_key_name: ' || p_primary_key_name);
  PUT_LINE('p_last_update_date_name: ' || p_last_update_date_name);

  -- build the dependencies index table
  Build_Dependencies_Table(
    p_database_object_name
  );


  -- initialize the application schema information
  Init_Applsys_Schema;

  -- Get the G_MISS value of this trigger
  OPEN  c_entity_name;
  FETCH c_entity_name INTO l_entity_name;
  CLOSE c_entity_name;

  l_pkg_name := 'ASO_'||l_entity_name||'_DEP_HDLR';
  l_ak_view_name := p_database_object_name;

  -- Construct the package header

  Pkg_Header(
    p_pkg_name  => l_pkg_name,
    p_pkg_type  => 'BODY');


  NEW_LINE;

  -- Construct the global variables
  FOR l_attribute_rec IN c_attributes LOOP
     l_string := 'G_'||l_attribute_rec.attribute_code;
     l_string := RPAD(l_string,35)||'         CONSTANT  NUMBER:= '||l_attribute_rec.attribute_id||';';
	Text(l_string, 0);
	--Text('G_'||l_attribute_rec.attribute_code||'         CONSTANT  NUMBER:= '||l_attribute_rec.attribute_id||';', 1);
  END LOOP;

  New_Line;

  IF ( p_database_object_name = 'ASO_AK_QUOTE_HEADER_V'
    OR p_database_object_name = 'ASO_AK_QUOTE_LINE_V')
  THEN
    --
    -- Construct Get_Dependent_Attributes_Sets
    --
    -- Construct the procedure header
    Text('PROCEDURE Get_Dependent_Attributes_Sets',0);
    Parameter('init_msg_list','IN',
                           'VARCHAR2',1,TRUE,':= fnd_api.g_false',30,TRUE);
    -- One output table for each trigger attribute
    FOR l_trigger_attr_rec IN c_all_trigger_attribute
    LOOP
      Parameter(l_trigger_attr_rec.attribute_code||'_TBL',
        'OUT', 'ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type',1);
    END LOOP;
    Parameter('return_status', 'OUT', 'VARCHAR2',1);
    Parameter('msg_count', 'OUT', 'NUMBER',1);
    Parameter('msg_data', 'OUT', 'VARCHAR2',1);
    Text(') ',0);
    Text('IS', 0);
    New_Line;

     -- Construct the Local variables
    Text('l_api_name            CONSTANT VARCHAR2 ( 50 ) := ''Get_Dependent_Attributes_Sets'';', 1);
    Text('broadcast_exception   EXCEPTION;', 1);
    New_Line;

    Text('BEGIN', 0);

    Api_Body_Start;

    -- fill output table
    FOR l_trigger_attr_rec IN c_trigger_attribute
    LOOP

      normalized_trigger_id := l_trigger_attr_rec.attribute_id - g_min;
      starting_point := normalized_trigger_id * G_Max;

      -- Construct the block for all chained dependent attributes for this trigger
      i := 0;
      WHILE ( g_dep_chain_tbl.EXISTS(starting_point + i)
              AND i < G_Max
            )
      LOOP
        OPEN  c_attribute_code(g_dep_chain_tbl(starting_point + i).attribute + g_min);
        FETCH c_attribute_code INTO l_attribute_code;
        CLOSE c_attribute_code;

        Text('x_'||LOWER(l_trigger_attr_rec.attribute_code)
          ||'_tbl('||TO_CHAR(i+1)||') := '||'G_'||l_attribute_code||';',1);

        i := i + 1;
      END LOOP;

    END LOOP;

    -- Start : Code change done for Bug 18442949
    IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' Then
       Text('x_q_price_list_id_tbl(4) :=  G_Q_CURRENCY_CODE;',1);
    End If;
    -- End : Code change done for Bug 18442949

    Api_Body_End;

    Text('END Get_Dependent_Attributes_Sets;',0);
    NEW_LINE;
    NEW_LINE;

  -- if quoting entities
  END IF;

  --
  -- Construct Get_Dependent_Attributes_Proc
  --
  -- Construct the procedure header
  Text('PROCEDURE Get_Dependent_Attributes_Proc',0);
  Parameter('init_msg_list','IN',
                         'VARCHAR2',1,TRUE,':= fnd_api.g_false',30,TRUE);
  Parameter('trigger_record','IN',
                         l_ak_view_name||'%ROWTYPE',1);
  Parameter('TRIGGERS_ID_TBL','IN',
                         'ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type',1,
                         TRUE,':= ASO_DEFAULTING_INT.G_MISS_ATTRIBUTE_IDS_TBL');
  Parameter('control_record','IN','ASO_DEFAULTING_INT.Control_Rec_Type',1,
                         TRUE,':= ASO_DEFAULTING_INT.G_MISS_CONTROL_REC');
  Parameter('dependent_record', 'OUT', l_ak_view_name||'%ROWTYPE',1);
  Parameter('return_status', 'OUT', 'VARCHAR2',1);
  Parameter('msg_count', 'OUT', 'NUMBER',1);
  Parameter('msg_data', 'OUT', 'VARCHAR2',1);
  Text(') ',0);
  Text('IS', 0);
  New_Line;

  -- Construct the cursor

  l_ac_cursor_name := 'c_attribute_code';
  Text('CURSOR '||l_ac_cursor_name||' (lc_attribute_id NUMBER)', 1);
  Text('IS', 1);
  Text('  SELECT   attribute_code', 1);
  Text('  FROM     oe_ak_obj_attr_ext', 1);
  Text('  WHERE    attribute_id = lc_attribute_id;', 1);
  NEW_LINE;

  l_ck_cursor_name := 'c_ak_'||l_entity_name;
  Text('CURSOR '||l_ck_cursor_name||' (lc_'||p_primary_key_name||' NUMBER)', 1);
  Text('IS', 1);
  Text('  SELECT    ', 1);

  i := 0;
  FOR l_attribute_rec IN c_attributes LOOP

  IF i= 0 THEN
   Text('           '||l_attribute_rec.column_name,1);
  ELSE
   Text('          ,'||l_attribute_rec.column_name,1);
  END IF;

  i := i + 1;

  END LOOP;


  Text('  FROM    '||l_ak_view_name, 1);
  Text('  WHERE   '||p_primary_key_name||' = lc_'||p_primary_key_name||';', 1);

  NEW_LINE;

  lv_ak_var_name := 'lv_ak_'||l_entity_name;
  Text(lv_ak_var_name||'            '||l_ck_cursor_name||'%ROWTYPE;', 1);
  Text('l_api_name            CONSTANT VARCHAR2 ( 50 ) := ''Get_Dependent_Attributes_Proc'';', 1);
  Text('l_triggers_id_tbl     ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type;', 1);
  Text('l_count               NUMBER;', 1);
  Text('l_attribute_code      VARCHAR2(30);', 1);
  Text('l_record_found        BOOLEAN := TRUE;', 1);
  Text('broadcast_exception   EXCEPTION;', 1);
  New_Line;

  Text('BEGIN', 0);

  Api_Body_Start;

  Text('IF ASO_DEBUG_PUB.G_DEBUG_FLAG = ''Y''', 1);
  Text('THEN ', 1);
  FOR l_attribute_rec IN c_attributes LOOP
    l_attribute_name :=  l_attribute_rec.column_name;
    Text('  ASO_DEBUG_PUB.ADD(''p_trigger_record.'||
      l_attribute_name||'= ''||p_trigger_record.'||l_attribute_name||', 1, ''N'');', 1);
  END LOOP;
  Text('END IF;', 1);
  NEW_LINE;

  COMMENT('Get records from database', 1);
  Text('OPEN  '||l_ck_cursor_name||'(p_trigger_record.'||p_primary_key_name||');', 1);
  Text('FETCH '||l_ck_cursor_name||' INTO '||lv_ak_var_name||';', 1);
  Text('IF '||l_ck_cursor_name||'%NOTFOUND', 1);
  Text('THEN', 1);
  Text('	l_record_found := FALSE;', 1);
  Text('END IF;      ', 1);
  Text('CLOSE '||l_ck_cursor_name||';', 1);
  Text('x_dependent_record := p_trigger_record;', 1);
  NEW_LINE;

  Text('IF l_record_found = TRUE', 1);
  Text('THEN', 1);
  NEW_LINE;
  Text('  IF ASO_DEBUG_PUB.G_DEBUG_FLAG = ''Y''', 1);
  Text('  THEN ', 1);
  FOR l_attribute_rec IN c_attributes LOOP
    l_attribute_name :=  l_attribute_rec.column_name;
    Text('    ASO_DEBUG_PUB.ADD('''||lv_ak_var_name||'.'||
      l_attribute_name||'= ''||'||lv_ak_var_name||'.'||l_attribute_name||', 1, ''N'');', 1);
  END LOOP;
  Text('  END IF;', 1);
  NEW_LINE;

  COMMENT('  Initialize the G_MISS fields from the database', 1);
  FOR l_attribute_rec IN c_attributes LOOP
    l_miss_str :=  l_attribute_rec.miss_str;
    l_attribute_name :=  l_attribute_rec.column_name;

    -- skip primary key since it must not be g_miss.
    IF (l_attribute_name <> p_primary_key_name)
    THEN
	    Text('  IF x_dependent_record.'||l_attribute_name||' = '||l_miss_str, 1);
      Text('  THEN', 1);
      Text('    x_dependent_record.'||l_attribute_name||' := '
        ||lv_ak_var_name||'.'||l_attribute_name||';', 1);
      Text('  END IF;', 1);
      NEW_LINE;
    END IF;

  END LOOP;
  NEW_LINE;
  Text('END IF;');
  NEW_LINE;

  Text('l_triggers_id_tbl := p_triggers_id_tbl;', 1);
  NEW_LINE;
  Text('IF (ASO_DEBUG_PUB.G_DEBUG_FLAG = ''Y'' AND l_triggers_id_tbl.count > 0)', 1);
  Text('THEN ', 1);
  Text('  ASO_DEBUG_PUB.ADD(''Get_Dependent_Attributes_Proc: Initial Trigger Attributes'', 1, ''N'');', 1);
  NEW_LINE;
  Text('  l_count := l_triggers_id_tbl.FIRST;');
  Text('  WHILE l_count IS NOT NULL LOOP');
  NEW_LINE;
  Text('    OPEN  c_attribute_code(l_count);');
  Text('    FETCH c_attribute_code INTO l_attribute_code;');
  Text('    CLOSE c_attribute_code;');
  NEW_LINE;
  Text('    aso_debug_pub.add(l_attribute_code,1,''N'');');
  NEW_LINE;
  Text('    l_count := l_triggers_id_tbl.NEXT(l_count);');
  NEW_LINE;
  Text('  END LOOP; ');
  Text('END IF;', 1);
  NEW_LINE;

  -- building the block for generating trigger list if not passed.
  COMMENT('If trigger attributes list passed, compose trigger list by comparing values', 1);
  COMMENT('of passed attributes whith those in database.', 1);
  Text('IF (l_triggers_id_tbl.count = 0 AND l_record_found = TRUE)', 1);
  Text('THEN', 1);
  NEW_LINE;
  COMMENT('  Check whether the database record has been changed.', 1);
  Text('  IF (p_control_record.last_update_date is NULL OR', 1);
  Text('        p_control_record.last_update_date = FND_API.G_MISS_Date ) ', 1);
  Text('  THEN', 1);
  Text('	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN', 1);
  Text('	      FND_MESSAGE.Set_Name(''ASO'', ''ASO_API_MISSING_COLUMN'');', 1);
  Text('	      FND_MESSAGE.Set_Token(''COLUMN'', ''Last_Update_Date'', FALSE);', 1);
  Text('	      FND_MSG_PUB.ADD;', 1);
  Text('	  END IF;', 1);
  Text('    RAISE broadcast_exception;', 1);
  Text('  END IF;', 1);
  Text('  IF (p_control_record.last_update_date <> '||lv_ak_var_name||'.'||p_last_update_date_name||')', 1);
  Text('  THEN', 1);
  Text('	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN', 1);
  Text('	      FND_MESSAGE.Set_Name(''ASO'', ''ASO_API_RECORD_CHANGED'');', 1);
  Text('	      FND_MESSAGE.Set_Token(''INFO'', ''quote'', FALSE);', 1);
  Text('	      FND_MSG_PUB.ADD;', 1);
  Text('	  END IF;', 1);
  Text('	  RAISE broadcast_exception;', 1);
  Text('  END IF;', 1);
  NEW_LINE;

  COMMENT('compose trigger id list', 1);
  FOR l_trigger_attr_rec IN c_trigger_attribute LOOP
    l_attribute_name :=  l_trigger_attr_rec.column_name;
    Text('  IF (  (x_dependent_record.'||l_attribute_name||' IS NOT NULL', 1);
    Text('          AND '||lv_ak_var_name||'.'||l_attribute_name||' IS NOT NULL', 1);
    Text('          AND x_dependent_record.'||l_attribute_name||' <> '||lv_ak_var_name||'.'||l_attribute_name||')', 1);
    Text('        OR', 1);
    Text('        (x_dependent_record.'||l_attribute_name||' IS NOT NULL ', 1);
    Text('          AND '||lv_ak_var_name||'.'||l_attribute_name||' IS NULL)', 1);
    Text('        OR', 1);
    Text('        (x_dependent_record.'||l_attribute_name||' IS NULL', 1);
    Text('          AND '||lv_ak_var_name||'.'||l_attribute_name||' IS NOT NULL)    ', 1);
    Text('     )', 1);
    Text('  THEN', 1);
    Text('  ', 1);
    Text('      l_triggers_id_tbl(G_'||l_trigger_attr_rec.attribute_code||') := 1;', 1);
    Text('    ', 1);
    Text('  END IF;', 1);
    NEW_LINE;
  END LOOP;

  -- for l_triggers_id_tbl.count = 0
  Text('END IF;', 1);
  NEW_LINE;
  Text('IF (ASO_DEBUG_PUB.G_DEBUG_FLAG = ''Y'' AND l_triggers_id_tbl.count > 0)', 1);
  Text('THEN ', 1);
  Text('  ASO_DEBUG_PUB.ADD(''Get_Dependent_Attributes_Proc: Final Trigger Attributes'', 1, ''N'');', 1);
  NEW_LINE;
  Text('  l_count := l_triggers_id_tbl.FIRST;');
  Text('  WHILE l_count IS NOT NULL LOOP');
  NEW_LINE;
  Text('    OPEN  c_attribute_code(l_count);');
  Text('    FETCH c_attribute_code INTO l_attribute_code;');
  Text('    CLOSE c_attribute_code;');
  NEW_LINE;
  Text('    aso_debug_pub.add(l_attribute_code,1,''N'');');
  NEW_LINE;
  Text('    l_count := l_triggers_id_tbl.NEXT(l_count);');
  NEW_LINE;
  Text('  END LOOP; ');
  Text('END IF;', 1);
  NEW_LINE;

  -- adding the block for g_miss
  COMMENT('Put g_miss for dependent attributes for each trigger', 1);
  Text('IF (l_triggers_id_tbl.count <> 0)', 1);
  Text('THEN', 1);
    FOR l_trigger_attr_rec IN c_trigger_attribute LOOP
      l_trigger_code := l_trigger_attr_rec.attribute_code;
      normalized_trigger_id := l_trigger_attr_rec.attribute_id - g_min;
      starting_point := normalized_trigger_id * G_Max;

      NEW_LINE;
      Text('  IF l_triggers_id_tbl.exists(G_'||l_trigger_code||')', 1);
      Text('  THEN', 1);

      NEW_LINE;
      i := 0;
      WHILE ( g_dep_chain_tbl.EXISTS(starting_point + i)
              AND i < G_Max
            )
      LOOP
        OPEN  c_attribute_code(g_dep_chain_tbl(starting_point + i).attribute + g_min);
        FETCH c_attribute_code INTO l_attribute_code;
        CLOSE c_attribute_code;

        OPEN  c_attribute_column_name(l_attribute_code);
        FETCH c_attribute_column_name INTO l_attribute_name;
        CLOSE c_attribute_column_name;

        -- Get the G_MISS value of this trigger
        OPEN c_data_type(l_attribute_code);
        FETCH c_data_type INTO l_miss_str;
        CLOSE c_data_type;

        Text('    IF p_control_record.override_trigger_flag = FND_API.G_TRUE', 1);
        Text('       OR', 1);
        Text('       (p_control_record.override_trigger_flag = FND_API.G_FALSE', 1);
        Text('        AND NOT l_triggers_id_tbl.exists(G_'||l_attribute_code||')', 1);
        Text('       )', 1);
        Text('    THEN', 1);
        Text('      x_dependent_record.'||l_attribute_name||' := '||l_miss_str||';', 1);
        Text('    END IF;', 1);
        NEW_LINE;
        i := i + 1;
      END LOOP;
      -- if trigger exist
      Text('  END IF;', 1);
      NEW_LINE;
  END LOOP;

  -- l_triggers_id_tbl.count <> 0
  Text('END IF;', 1);

  Api_Body_End;

  Text('END Get_Dependent_Attributes_Proc;',0);

  Pkg_End (l_pkg_name,'BODY');

  retcode := 0;
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
	PUT_LINE('Please check the log file for error messages');
	retcode := 2;
	errbuf := 'Please check the log file for error messages';

  WHEN OTHERS THEN
	PUT_LINE( 'Error in creating entity def hdlr '||sqlerrm);
	retcode := 2;
	errbuf := sqlerrm;

END Make_Dependency_Engine_Body;

PROCEDURE Attribute_Code_To_Id
(   P_ATTRIBUTE_CODES_TBL           IN  ASO_DEFAULTING_INT.attribute_Codes_Tbl_Type
  , P_DATABASE_OBJECT_NAME          IN  VARCHAR2
  , X_ATTRIBUTE_IDS_TBL             OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
)
IS

  l_count         NUMBER;
  l_attribute_id  NUMBER;

  CURSOR  c_attribute_id (
    lc_attribute_code VARCHAR2
  ) IS
    SELECT  attribute_id
      FROM  oe_ak_obj_attr_ext
     WHERE  attribute_code = lc_attribute_code
            AND database_object_name = p_database_object_name
            AND attribute_application_id = G_APPLICATION_ID;
BEGIN

    l_count := p_attribute_codes_tbl.FIRST;

    -- For each trigger attribute code
    WHILE l_count IS NOT NULL LOOP

      OPEN  c_attribute_id(p_attribute_codes_tbl(l_count));
      FETCH c_attribute_id INTO l_attribute_id;
      CLOSE c_attribute_id;

      x_attribute_ids_tbl(l_attribute_id) := 1;

      l_count := p_attribute_codes_tbl.NEXT(l_count);

    END LOOP; -- next source attribute

END Attribute_Code_To_Id;

END ASO_DEPENDENCY_UTIL;

/
