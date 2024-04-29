--------------------------------------------------------
--  DDL for Package Body OE_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_GENERATE" AS
/* $Header: OEXTGENB.pls 120.0 2005/06/01 23:18:13 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME      	CONSTANT    VARCHAR2(30):='OE_GENERATE';

FUNCTION Gen_Start_Token
(   p_text	IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN

    RETURN SUBSTR(p_text,15);

END Gen_Start_Token;

FUNCTION Gen_End_Token
(   p_text	IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN

    RETURN SUBSTR(p_text,13);

END Gen_End_Token;

FUNCTION Is_Gen_Start
(   p_text	IN  VARCHAR2
)
RETURN BOOLEAN
IS
BEGIN

    RETURN ( SUBSTR(p_text,1,13) = '--  START GEN');

END Is_Gen_Start;

FUNCTION Is_Gen_End
(   p_text	IN  VARCHAR2
)
RETURN BOOLEAN
IS
BEGIN

    RETURN ( SUBSTR(p_text,1,11) = '--  END GEN');

END Is_Gen_End;

PROCEDURE Start_Gen
(   p_file	IN  UTL_FILE.file_type
,   p_text	IN  VARCHAR2
)
IS
BEGIN

    Comment ( p_file , 'START GEN '||p_text,0,FALSE,FALSE);

END Start_Gen;

PROCEDURE End_Gen
(   p_file	IN  UTL_FILE.file_type
,   p_text	IN  VARCHAR2
)
IS
BEGIN

    Comment ( p_file , 'END GEN '||p_text,0,FALSE,FALSE);

END End_Gen;

PROCEDURE Load_File
(   p_file	IN  UTL_FILE.file_type
)
IS
l_buffer	VARCHAR2(240);
l_count		NUMBER := 0;
BEGIN

    --	Init g_src_tbl

    g_src_tbl.DELETE;

    --	Read from file.

    WHILE TRUE LOOP

	l_count := l_count + 1;
	UTL_FILE.get_line ( p_file , l_buffer );
	g_src_tbl(l_count) := l_buffer;

    END LOOP;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	NULL;

END Load_File;

PROCEDURE Parameter
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2
,   p_mode	IN  VARCHAR2 := 'IN'
,   p_type	IN  VARCHAR2 := G_TYPE_NUMBER
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
)
IS
l_first		varchar2(1);
l_prefix	VARCHAR2(10);
BEGIN

    IF p_mode = 'IN' THEN
	l_prefix := '   p_';
    ELSE
	l_prefix := '   x_';
    END IF;

    IF p_first THEN
	l_first := '(';
    ELSE
	l_first := ',';
    END IF;

    Text(   p_file
	,   l_first||l_prefix||RPAD(p_param,p_rpad)||RPAD(p_mode,4)||p_type
	,   p_level
	);

END Parameter;

PROCEDURE Element
(   p_file	IN  UTL_FILE.file_type
,   p_element	IN  VARCHAR2
,   p_type	IN  VARCHAR2 := G_TYPE_NUMBER
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
)
IS
l_first		varchar2(1);
BEGIN

    IF p_first THEN
	l_first := '(';
    ELSE
	l_first := ',';
    END IF;

    Text(   p_file
	,   l_first||'   '||RPAD(p_element,p_rpad)||p_type
	,   p_level
	);

END Element;

PROCEDURE Variable
(   p_file	IN  UTL_FILE.file_type
,   p_var	IN  VARCHAR2
,   p_type	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
)
IS
l_rpad 		NUMBER := p_rpad;
BEGIN

    IF LENGTH(p_var) >= 30 THEN
	l_rpad := LENGTH(p_var)+1;
    END IF;

    Text(   p_file
	,   RPAD(p_var,l_rpad)||p_type||';'
	,   p_level
	);

END Variable;

PROCEDURE Assign
(   p_file	IN  UTL_FILE.file_type
,   p_left	IN  VARCHAR2
,   p_right	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
)
IS
l_rpad		NUMBER:=p_rpad;
BEGIN

    IF p_rpad = -1 OR
	p_rpad < LENGTH(p_left)
    THEN
	l_rpad := LENGTH(p_left);
    END IF;

    Text(   p_file
	,   RPAD(p_left,l_rpad)||' := '||p_right||';'
	,   p_level
	);

END Assign;

PROCEDURE Call_Param
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2
,   p_val	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
)
IS
l_first		varchar2(1);
BEGIN

    IF p_first THEN
	l_first := '(';
    ELSE
	l_first := ',';
    END IF;

    UTL_FILE.put_line( p_file ,
	LPAD(l_first,p_level*4+1)||'   '||RPAD(p_param,p_rpad)||'=> '||p_val);

END Call_Param;

PROCEDURE End_Call
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Text (p_file,');',p_level);

END End_Call;

PROCEDURE Get_Msg
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Comment (p_file,'Get message count and data',p_level);
    Text (p_file,'FND_MSG_PUB.Count_And_Get',p_level);
    Call_Param (p_file,'p_count','x_msg_count',p_level,30,TRUE);
    Call_Param (p_file,'p_data','x_msg_data',p_level);
    End_Call (p_file,p_level);
    UTL_FILE.new_line(p_file);

END Get_Msg;

PROCEDURE Pkg_Header
(   p_file	IN  UTL_FILE.file_type
,   p_filename	IN  VARCHAR2
,   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
)
IS
BEGIN

    --	Copyright section.

    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file ,
	'Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA',
				0,FALSE,FALSE);
    Comment ( p_file , 'All rights reserved.',0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file , 'FILENAME',0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file , '    '||p_filename,0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file , 'DESCRIPTION',0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file , '    '||INITCAP(p_pkg_type)||' of package '
		||p_pkg_name,0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file ,'NOTES',0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file ,'HISTORY',0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,FALSE);
    Comment ( p_file , TO_CHAR(SYSDATE)||' Created',0,FALSE,FALSE);
    Comment ( p_file , '',0,FALSE,TRUE);

    --	Standard WHENEVER clause.

    Text ( p_file,'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;',0);

    --	Define package.

    UTL_FILE.new_line ( p_file );
    IF p_pkg_type = G_PKG_TYPE_BODY THEN
	Text ( p_file ,'CREATE or REPLACE PACKAGE BODY '||
		p_pkg_name|| ' AS',0);
    ELSE
	Text ( p_file ,'CREATE or REPLACE PACKAGE '||
		p_pkg_name|| ' AS',0);
    END IF;

    --	$Header clause.

    UTL_FILE.new_line ( p_file );
    Text (p_file,'/* $Header: OEXTGENB.pls 120.0 2005/06/01 23:18:13 appldev noship $ */',0);

    --	Global constant holding package name.

    IF p_pkg_type = G_PKG_TYPE_BODY THEN
	Comment ( p_file , 'Global constant holding the package name',0);
	Text ( p_file,RPAD('G_PKG_NAME',30)||'CONSTANT '||
		    'VARCHAR2(30) := '''||p_pkg_name||''';',0);
    END IF;

END Pkg_Header;

PROCEDURE Pkg_End
(   p_file	IN  UTL_FILE.file_type
,   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
,   p_filename	IN  VARCHAR2 := NULL
)
IS
BEGIN

    --	end statement.

    UTL_FILE.new_line(p_file);
    Text ( p_file , 'END '||p_pkg_name||';',0);
    Text ( p_file , '/',0);
    --	Show errors.

    UTL_FILE.new_line(p_file);
    IF p_pkg_type = G_PKG_TYPE_BODY THEN
	Text ( p_file ,'SHOW ERRORS PACKAGE BODY '||
		p_pkg_name||';' ,0);
    ELSE
	Text ( p_file ,'SHOW ERRORS PACKAGE '||
		p_pkg_name||';' ,0);
    END IF;

    --	Commit and Exit.

    UTL_FILE.new_line(p_file);
    Text ( p_file , 'COMMIT;',0);
    Comment ( p_file , 'EXIT;',0);

    --	Log an entry in the compile file if p_filename is not NULL.

    IF p_filename IS NOT NULL THEN

	Log_Compile
	(   p_pkg_name
	,   p_filename
	,   p_pkg_type
	);

    END IF;

END Pkg_End;

PROCEDURE Check_Status
(   p_file	IN  UTL_FILE.file_type
,   p_variable	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    UTL_FILE.new_line (p_file);
    Text (p_file,
'IF '||p_variable||' = FND_API.G_RET_STS_UNEXP_ERROR THEN',p_level);
    Text (p_file , 'RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',p_level+1);
    Text (p_file,
'ELSIF '||p_variable||' = FND_API.G_RET_STS_ERROR THEN',p_level);
    Text (p_file ,'RAISE FND_API.G_EXC_ERROR;',p_level+1);
    Text (p_file ,'END IF;',p_level);
    UTL_FILE.new_line (p_file);

END Check_Status;


PROCEDURE Exc_Msg
(   p_file	IN  UTL_FILE.file_type
,   p_procedure	IN  VARCHAR2
,   p_error	IN  VARCHAR2 := NULL
,   p_level	IN  NUMBER := 2
,   p_text	IN  BOOLEAN := FALSE
)
IS
BEGIN

    Text (p_file,'IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)',p_level);
    Text (p_file,'THEN',p_level);
    Text (p_file,'FND_MSG_PUB.Add_Exc_Msg',p_level+1);
    Text (p_file,'(   G_PKG_NAME',p_level+1);
    Text (p_file,',   '''||p_procedure||'''',p_level+1);

    IF p_error IS NOT NULL THEN
       IF p_text THEN
	  Text (p_file, p_error, p_level+1);
	ELSE
	  Text (p_file, ',   ''' || p_error || '''', p_level+1);
       END IF;
    END IF;

    Text (p_file,');',p_level+1);
    Text (p_file,'END IF;',p_level);

END Exc_Msg;

PROCEDURE Error_Msg
(   p_file	IN  UTL_FILE.file_type
,   p_product	IN  VARCHAR2
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 2
,   p_tk1	IN  VARCHAR2 := NULL
,   p_tk1_val	IN  VARCHAR2 := NULL
,   p_tk2	IN  VARCHAR2 := NULL
,   p_tk2_val	IN  VARCHAR2 := NULL
,   p_tk3	IN  VARCHAR2 := NULL
,   p_tk3_val	IN  VARCHAR2 := NULL
,   p_tk4	IN  VARCHAR2 := NULL
,   p_tk4_val	IN  VARCHAR2 := NULL
,   p_tk5	IN  VARCHAR2 := NULL
,   p_tk5_val	IN  VARCHAR2 := NULL
,   p_tk1_is_text IN  BOOLEAN := TRUE
,   p_tk2_is_text IN  BOOLEAN := TRUE
,   p_tk3_is_text IN  BOOLEAN := TRUE
,   p_tk4_is_text IN  BOOLEAN := TRUE
,   p_tk5_is_text IN  BOOLEAN := TRUE
)
IS
BEGIN

    Msg
    (   p_file	    =>	p_file
    ,   p_product   =>	p_product
    ,   p_name	    =>	p_name
    ,   p_level	    =>	p_level
    ,   p_tk1	    =>	p_tk1
    ,   p_tk1_val   =>	p_tk1_val
    ,   p_tk2	    =>	p_tk2
    ,   p_tk2_val   =>	p_tk2_val
    ,   p_tk3	    =>	p_tk3
    ,   p_tk3_val   =>	p_tk3_val
    ,   p_tk4	    =>	p_tk4
    ,   p_tk4_val   =>	p_tk4_val
    ,   p_tk5	    =>	p_tk5
    ,   p_tk5_val   =>	p_tk5_val
    ,   p_type	    =>	G_MSG_ERROR
    ,   p_tk1_is_text	=>  p_tk1_is_text
    ,   p_tk2_is_text	=>  p_tk2_is_text
    ,   p_tk3_is_text	=>  p_tk3_is_text
    ,   p_tk4_is_text	=>  p_tk4_is_text
    ,   p_tk5_is_text	=>  p_tk5_is_text
    );

END Error_Msg;

PROCEDURE Msg
(   p_file	IN  UTL_FILE.file_type
,   p_product	IN  VARCHAR2
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 2
,   p_tk1	IN  VARCHAR2 := NULL
,   p_tk1_val	IN  VARCHAR2 := NULL
,   p_tk2	IN  VARCHAR2 := NULL
,   p_tk2_val	IN  VARCHAR2 := NULL
,   p_tk3	IN  VARCHAR2 := NULL
,   p_tk3_val	IN  VARCHAR2 := NULL
,   p_tk4	IN  VARCHAR2 := NULL
,   p_tk4_val	IN  VARCHAR2 := NULL
,   p_tk5	IN  VARCHAR2 := NULL
,   p_tk5_val	IN  VARCHAR2 := NULL
,   p_type	IN  NUMBER   := G_MSG_ERROR
,   p_tk1_is_text IN  BOOLEAN := TRUE
,   p_tk2_is_text IN  BOOLEAN := TRUE
,   p_tk3_is_text IN  BOOLEAN := TRUE
,   p_tk4_is_text IN  BOOLEAN := TRUE
,   p_tk5_is_text IN  BOOLEAN := TRUE
)
IS
l_buffer    VARCHAR2(30);
l_quotes    VARCHAR2(3);
BEGIN

    IF p_type = G_MSG_ERROR THEN
	l_buffer    :=	'G_MSG_LVL_ERROR';
    ELSIF p_type = G_MSG_SUCCESS THEN
	l_buffer    :=	'G_MSG_LVL_SUCCESS';
    ELSIF p_type = G_MSG_UNEXP_ERROR THEN
	l_buffer    :=	'G_MSG_LVL_UNEXP_ERROR';
    END IF;

    Text (p_file,'IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.'||
	l_buffer||')',p_level);

    Text (p_file,'THEN',p_level);

    UTL_FILE.new_line(p_file);
    Text(p_file,'FND_MESSAGE.SET_NAME('''||p_product||''','''||p_name||''');'
	    ,p_level+1);

    IF p_tk1 IS NOT NULL THEN

	IF p_tk1_is_text THEN
	    l_quotes := '''';
	ELSE
	    l_quotes := NULL;
	END IF;

	Text(p_file,'FND_MESSAGE.SET_TOKEN('''||p_tk1||''','||
		l_quotes||p_tk1_val||l_quotes||');',p_level+1);
    END IF;

    IF p_tk2 IS NOT NULL THEN

	IF p_tk2_is_text THEN
	    l_quotes := '''';
	ELSE
	    l_quotes := NULL;
	END IF;

	Text(p_file,'FND_MESSAGE.SET_TOKEN('''||p_tk2||''','||
		l_quotes||p_tk2_val||l_quotes||');',p_level+1);

    END IF;

    IF p_tk3 IS NOT NULL THEN

	IF p_tk3_is_text THEN
	    l_quotes := '''';
	ELSE
	    l_quotes := NULL;
	END IF;

	Text(p_file,'FND_MESSAGE.SET_TOKEN('''||p_tk3||''','||
		l_quotes||p_tk3_val||l_quotes||');',p_level+1);
    END IF;

    IF p_tk4 IS NOT NULL THEN

	IF p_tk4_is_text THEN
	    l_quotes := '''';
	ELSE
	    l_quotes := NULL;
	END IF;

	Text(p_file,'FND_MESSAGE.SET_TOKEN('''||p_tk4||''','||
		l_quotes||p_tk4_val||l_quotes||');',p_level+1);
    END IF;

    IF p_tk5 IS NOT NULL THEN

	IF p_tk5_is_text THEN
	    l_quotes := '''';
	ELSE
	    l_quotes := NULL;
	END IF;

	Text(p_file,'FND_MESSAGE.SET_TOKEN('''||p_tk5||''','||
		l_quotes||p_tk5_val||l_quotes||');',p_level+1);
    END IF;

    Text(p_file,'FND_MSG_PUB.Add;',p_level+1);

    UTL_FILE.new_line(p_file);
    Text (p_file,'END IF;',p_level);

END Msg;


PROCEDURE Comment
(   p_file	    IN  UTL_FILE.file_type
,   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER := 1
,   p_line_before   IN	BOOLEAN := TRUE
,   p_line_after    IN	BOOLEAN := TRUE
)
IS
BEGIN

    IF p_line_before THEN
        UTL_FILE.new_line(p_file);
    END IF;

    Text(p_file,'--  '||p_comment,p_level);

    IF p_line_after THEN
        UTL_FILE.new_line(p_file);
    END IF;

END Comment;

PROCEDURE API_Out_Vars
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_pkg	    IN	VARCHAR2
,   p_level	    IN  NUMBER := 1
)
IS
BEGIN

    FOR I IN 1..p_entity_tbl.COUNT LOOP

	IF Multiple_Branch(I) THEN

	    Variable
	    (	p_file
	    ,	'l_x_'||p_entity_tbl(I).name||'_rec'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'
	    ,	p_level
	    );

	    Variable
	    (	p_file
	    ,	'l_x_'||p_entity_tbl(I).name||'_tbl'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Tbl_Type'
	    ,	p_level
	    );

	ELSE

	    Variable
	    (	p_file
	    ,	'l_x_'||p_entity_tbl(I).name||'_rec'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'
	    ,	p_level
	    );

	END IF;

    END LOOP;

END API_Out_Vars;

PROCEDURE API_Out_Param
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_level	    IN  NUMBER := 1
,   p_entity_prefix IN	VARCHAR2 := 'l_'
,   p_type	    IN	VARCHAR2 := G_API_TYPE_PVT
)
IS
BEGIN

    FOR I IN 1..p_entity_tbl.COUNT LOOP

	IF Multiple_Branch(I) THEN

	    Call_Param
	    (	p_file
	    ,	'x_'||p_entity_tbl(I).name||'_tbl'
	    ,	p_entity_prefix||p_entity_tbl(I).name||'_tbl'
	    ,	p_level
	    );

	    IF p_type = G_API_TYPE_PUB THEN
		Call_Param
		(   p_file
		,   'x_'||p_entity_tbl(I).name||'_val_tbl'
		,   p_entity_prefix||p_entity_tbl(I).name||'_val_tbl'
		,   p_level
		);
	    END IF;

	ELSE

	    Call_Param
	    (	p_file
	    ,	'x_'||p_entity_tbl(I).name||'_rec'
	    ,	p_entity_prefix||p_entity_tbl(I).name||'_rec'
	    ,	p_level
	    );

	    IF p_type = G_API_TYPE_PUB THEN
		Call_Param
		(   p_file
		,   'x_'||p_entity_tbl(I).name||'_val_rec'
		,   p_entity_prefix||p_entity_tbl(I).name||'_val_rec'
		,   p_level
		);
	    END IF;

	END IF;

    END LOOP;

END API_Out_Param;

PROCEDURE API_In_Param
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_level	    IN  NUMBER := 1
,   p_entity_prefix IN	VARCHAR2 := 'l_'
,   p_old_param	    IN	BOOLEAN := TRUE
,   p_val_param     IN	BOOLEAN := FALSE
,   p_id_param      IN	BOOLEAN := FALSE
)
IS
BEGIN

    FOR I IN 1..p_entity_tbl.COUNT LOOP

       -- Id and tbls/recs are mutually exclusive

       IF p_id_param THEN	-- Add Id's as parameters

	  -- If root entity
	  IF p_entity_tbl(i).parent IS NULL THEN

	    Load_Entity_Attributes(p_entity_tbl(I));

	     FOR I IN 1..g_pk_attr_tbl.COUNT LOOP

		Call_Param
		(  p_file
		,  'p_' || g_pk_attr_tbl(I).code
		,  p_entity_prefix || g_pk_attr_tbl(I).code
		,  p_level
		);

	     END LOOP;

	  END IF;

	ELSE			-- Add tables/records as parameters

	    IF Multiple_Branch(I) THEN

	     Call_Param
	     (  p_file
	     ,	'p_'||p_entity_tbl(I).name||'_tbl'
	     ,	p_entity_prefix||p_entity_tbl(I).name||'_tbl'
	     ,	p_level
	     );

	     IF p_old_param THEN
	    	Call_Param
		(  p_file
		,  'p_old_'||p_entity_tbl(I).name||'_tbl'
		,  p_entity_prefix||'old_'||p_entity_tbl(I).name||'_tbl'
		,  p_level
		);
	     END IF;

	     IF p_val_param THEN
	    	Call_Param
		(  p_file
		,  'p_'||p_entity_tbl(I).name||'_val_tbl'
		,  p_entity_prefix||p_entity_tbl(I).name||'_val_tbl'
		,  p_level
		);
	     END IF;

	   ELSE		-- if entity branch not multiple

	     Call_Param
	     (	p_file
	     ,	'p_'||p_entity_tbl(I).name||'_rec'
	     ,	p_entity_prefix||p_entity_tbl(I).name||'_rec'
	     ,	p_level
	     );

	     IF p_old_param THEN
	    	Call_Param
		(  p_file
		,   'p_old_'||p_entity_tbl(I).name||'_rec'
		,   p_entity_prefix||'old_'||p_entity_tbl(I).name||'_rec'
		,   p_level
		);
	     END IF;

	     IF p_val_param THEN
	    	Call_Param
		(  p_file
		,   'p_'||p_entity_tbl(I).name||'_val_rec'
		,   p_entity_prefix||p_entity_tbl(I).name||'_val_rec'
		,   p_level
		);
	     END IF;

	  END IF;

       END IF;

    END LOOP;

END API_In_Param;

PROCEDURE API_Local_Vars
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_pkg	    IN	VARCHAR2
)
IS
BEGIN

    FOR I IN 1..p_entity_tbl.COUNT LOOP

	IF Multiple_Branch(I) THEN

	    Variable
	    (	p_file
	    ,	'l_'||p_entity_tbl(I).name||'_rec'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'
	    ,	0
	    );

	    Variable
	    (	p_file
	    ,	'l_'||p_entity_tbl(I).name||'_tbl'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Tbl_Type'
	    ,	0
	    );

	    Variable
	    (	p_file
	    ,	'l_old_'||p_entity_tbl(I).name||'_rec'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'
	    ,	0
	    );

	    Variable
	    (	p_file
	    ,	'l_old_'||p_entity_tbl(I).name||'_tbl'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Tbl_Type'
	    ,	0
	    );

	ELSE

	    Variable
	    (	p_file
	    ,	'l_'||p_entity_tbl(I).name||'_rec'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'||
	    	' := p_'||p_entity_tbl(I).name||'_rec'
	    ,	0
	    );

	    Variable
	    (	p_file
	    ,	'l_old_'||p_entity_tbl(I).name||'_rec'
	    ,	p_pkg||'.'||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'||
	    	' := p_old_'||p_entity_tbl(I).name||'_rec'
	    ,	0
	    );

	END IF;

    END LOOP;

END API_Local_Vars;

PROCEDURE Text
(   p_file	IN  UTL_FILE.file_type
,   p_string	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    UTL_FILE.put_line (p_file ,LPAD(p_string,p_level*4+LENGTH(p_string)));

END text;

PROCEDURE Comp_Check
(   p_file	IN  UTL_FILE.file_type
)
IS
BEGIN

    Comment (p_file,'Standard call to check for call compatibility');

    Text (p_file,'IF NOT FND_API.Compatible_API_Call');
    Text (p_file,'       (   l_api_version_number');
    Text (p_file,'       ,   p_api_version_number');
    Text (p_file,'       ,   l_api_name');
    Text (p_file,'       ,   G_PKG_NAME');
    Text (p_file,'       )');
    Text (p_file,'THEN');
    Text (p_file,'RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',2);
    Text (p_file,'END IF;');

END Comp_Check;

PROCEDURE Std_Exc_Handler
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2 := NULL
,   p_savepoint	IN  VARCHAR2 := NULL
)
IS
BEGIN

    UTL_FILE.new_line (p_file);
    Text (p_file,'EXCEPTION',0);

    UTL_FILE.new_line (p_file);
    Text (p_file,'WHEN FND_API.G_EXC_ERROR THEN',1);
    UTL_FILE.new_line (p_file);
    Text (p_file,'x_return_status := FND_API.G_RET_STS_ERROR;',2);
    Get_Msg (p_file,2);
    IF p_savepoint IS NOT NULL THEN
	Add_Rollback ( p_file , p_savepoint , 2 );
    END IF;

    Text (p_file,'WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN',1);
    UTL_FILE.new_line (p_file);
    Text (p_file,'x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;',2);
    Get_Msg (p_file,2);
    IF p_savepoint IS NOT NULL THEN
	Add_Rollback ( p_file , p_savepoint , 2 );
    END IF;

    Text (p_file,'WHEN OTHERS THEN',1);
    UTL_FILE.new_line (p_file);
    Text (p_file,'x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;',2);
    UTL_FILE.new_line (p_file);
    Exc_Msg (p_file,p_name,NULL,2);
    Get_Msg (p_file,2);
    IF p_savepoint IS NOT NULL THEN
	Add_Rollback ( p_file , p_savepoint , 2 );
    END IF;

END Std_Exc_Handler;

PROCEDURE Others_Exc
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2	:= NULL
,   p_level	IN  NUMBER	:= 0
,   p_raise_exc	IN  BOOLEAN	:= TRUE
)
IS
BEGIN

    UTL_FILE.new_line (p_file);
    Text (p_file,'EXCEPTION',p_level);
    UTL_FILE.new_line (p_file);
    Text (p_file,'WHEN OTHERS THEN',p_level+1);
    UTL_FILE.new_line (p_file);
    Exc_Msg (p_file,p_name,NULL,p_level+2);
    UTL_FILE.new_line (p_file);

    IF p_raise_exc THEN
	Text (p_file,'RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',p_level+2);
    ELSE
	Assign
	(   p_file
	,   'x_return_status'
	,   'FND_API.G_RET_STS_UNEXP_ERROR'
	,   p_level+2
	,   -1
	);

	Get_Msg
	(   p_file
	,   p_level+2
	);

    END IF;

    UTL_FILE.new_line (p_file);

END Others_Exc;

PROCEDURE Client_Exception
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2	:=  NULL
,   p_level	IN  NUMBER	:= 0
)
IS
BEGIN

    UTL_FILE.new_line (p_file);
    Text (p_file,'EXCEPTION',p_level);

    UTL_FILE.new_line (p_file);
    Text (p_file,'WHEN VALUE_ERROR THEN',p_level+1);
    UTL_FILE.new_line (p_file);
    Text (p_file,'Message(''Error calling server API in procedure '||
	p_name||''');',p_level+2);
    OE_GENERATE.Text(p_file,'RAISE FORM_TRIGGER_FAILURE;',p_level+2);
    UTL_FILE.new_line (p_file);

END Client_Exception;

PROCEDURE API_Parameters
(   p_file	    IN  UTL_FILE.file_type
,   p_product	    IN	VARCHAR2
,   p_object	    IN	VARCHAR2
,   p_name	    IN  VARCHAR2
,   p_type	    IN  VARCHAR2
,   p_entity_tbl    IN	Entity_Tbl_Type
,   p_lock_api	    IN	BOOLEAN := FALSE
)
IS
l_p_pkg	    VARCHAR2(30):=NULL;
BEGIN

    IF p_type <> G_API_TYPE_PUB THEN
	l_p_pkg := p_product||'_'||INITCAP(p_object)||'_PUB.';
    END IF;

    Text (p_file ,'PROCEDURE '||p_name,0);
    Parameter(p_file,'api_version_number','IN',
			    G_TYPE_NUMBER,0,30,TRUE);
    Parameter(p_file,'init_msg_list','IN',
			    'VARCHAR2 := FND_API.G_FALSE',0);

    IF p_type = G_API_TYPE_PUB THEN

	Parameter(p_file,'return_values','IN',
			    'VARCHAR2 := FND_API.G_FALSE',0);
    END IF;

    IF NOT p_lock_api THEN
	Parameter(p_file,'commit','IN',
			    'VARCHAR2 := FND_API.G_FALSE',0);

	IF p_type = G_API_TYPE_PVT THEN
	    Parameter(p_file,'validation_level','IN'
			    ,'NUMBER := FND_API.G_VALID_LEVEL_FULL',0);
	    Parameter
	    (   p_file
	    ,   'control_rec'
	    ,   'IN'
	    ,   p_product||'_GLOBALS.Control_Rec_Type :='
	    ,   0
	    );

	    Text
	    (   p_file
	    ,   p_product||'_GLOBALS.G_MISS_CONTROL_REC'
	    ,   10
	    );

	END IF;


    END IF;

    Parameter(p_file,'return_status','OUT',
			    G_TYPE_CHAR,0);
    Parameter(p_file,'msg_count','OUT',
			    G_TYPE_NUMBER,0);
    Parameter(p_file,'msg_data','OUT',
			    G_TYPE_CHAR,0);

    FOR I IN 1..p_entity_tbl.COUNT LOOP

	--  for each entity add two INs (new and old)
	--  If it is a public api add a third value parameter.

	IF Multiple_Branch(I) THEN

	    --	Add tbl.

	    Parameter
	    (	p_file
	    ,	p_entity_tbl(I).name||'_tbl'
	    ,	'IN'
	    ,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Tbl_Type :='
	    ,	0
	    );

	    Text
	    (	p_file
	    ,	l_p_pkg||'G_MISS_'||UPPER(p_entity_tbl(I).name)||'_TBL'
	    ,	10
	    );

	    --	For public APIs ad value based parameters.

	    IF p_type = G_API_TYPE_PUB THEN

		Parameter
		(   p_file
		,   p_entity_tbl(I).name||'_val_tbl'
		,   'IN'
		,   l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Val_Tbl_Type :='
		,   0
		);

		Text
		(   p_file
		,   l_p_pkg||'G_MISS_'||UPPER(p_entity_tbl(I).name)||'_VAL_TBL'
		,   10
		);

	    END IF;

	    IF NOT p_lock_api AND
		p_type = G_API_TYPE_PVT
	    THEN

		--  Add old parameters for private APIs only.

		Parameter
		(	p_file
		,	'old_'||p_entity_tbl(I).name||'_tbl'
		,	'IN'
		,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Tbl_Type :='
		,	0
		);

		Text
		(	p_file
		,	l_p_pkg||'G_MISS_'||UPPER(p_entity_tbl(I).name)||'_TBL'
		,	10
		);

	    END IF;

	ELSE

	    --	Add Rec

	    Parameter
	    (	p_file
	    ,	p_entity_tbl(I).name||'_rec'
	    ,	'IN'
	    ,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Rec_Type :='
	    ,	0
	    );

	    Text
	    (	p_file
	    ,	l_p_pkg||'G_MISS_'||UPPER(p_entity_tbl(I).name)||'_REC'
	    ,	10
	    );

	    --	For public APIs ad value based parameters.

	    IF p_type = G_API_TYPE_PUB THEN

		Parameter
		(   p_file
		,   p_entity_tbl(I).name||'_val_rec'
		,   'IN'
		,   l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Val_Rec_Type :='
		,   0
		);

		Text
		(   p_file
		,   l_p_pkg||'G_MISS_'||UPPER(p_entity_tbl(I).name)||'_VAL_REC'
		,   10
		);

	    END IF;

	    IF NOT p_lock_api AND
		p_type = G_API_TYPE_PVT
	    THEN

	    Parameter
	    (	p_file
	    ,	'old_'||p_entity_tbl(I).name||'_rec'
	    ,	'IN'
	    ,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Rec_Type :='
	    ,	0
	    );

	    Text
	    (	p_file
	    ,	l_p_pkg||'G_MISS_'||UPPER(p_entity_tbl(I).name)||'_REC'
	    ,	10
	    );

	END IF;

	END IF;

    END LOOP;

    --	OUT parameters.

    FOR I IN 1..p_entity_tbl.COUNT LOOP

	--  for each entity add one OUT

	IF Multiple_Branch(I) THEN

	    --	Add tbl.

	    Parameter
	    (	p_file
	    ,	p_entity_tbl(I).name||'_tbl'
	    ,	'OUT'
	    ,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Tbl_Type'
	    ,	0
	    );

	    --	Add value out parameters.

	    IF p_type = G_API_TYPE_PUB THEN

		Parameter
		(	p_file
		,	p_entity_tbl(I).name||'_val_tbl'
		,	'OUT'
		,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Val_Tbl_Type'
		,	0
		);

	    END IF;

	ELSE

	    --	Add Rec

	    Parameter
	    (	p_file
	    ,	p_entity_tbl(I).name||'_rec'
	    ,	'OUT'
	    ,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'
	    ,	0
	    );

	    --	Add value out parameters.

	    IF p_type = G_API_TYPE_PUB THEN

		Parameter
		(	p_file
		,	p_entity_tbl(I).name||'_val_rec'
		,	'OUT'
		,	l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Val_Rec_Type'
		,	0
		);

	    END IF;

	END IF;

    END LOOP;

END API_Parameters;

PROCEDURE API_Header
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2
,   p_type	IN  VARCHAR2
)
IS
BEGIN

    Comment ( p_file,'Start of Comments',0,TRUE,FALSE);
    Comment ( p_file,RPAD('API name',12)||p_name
	,0,FALSE,FALSE);
    Comment ( p_file,RPAD('Type',12)||INITCAP(p_type),0,FALSE,FALSE);
    Comment ( p_file,'Function',0,FALSE,FALSE);
    Comment ( p_file,'',0,FALSE,FALSE);
    Comment ( p_file,'Pre-reqs',0,FALSE,FALSE);
    Comment ( p_file,'',0,FALSE,FALSE);
    Comment ( p_file,'Parameters',0,FALSE,FALSE);
    Comment ( p_file,'',0,FALSE,FALSE);
    Comment ( p_file,RPAD('Version',12)||
	'Current version = 1.0',0,FALSE,FALSE);
    Comment ( p_file,LPAD('Initial version = 1.0',33),0,FALSE,FALSE);
    Comment ( p_file,'',0,FALSE,FALSE);
    Comment ( p_file,'Notes',0,FALSE,FALSE);
    Comment ( p_file,'',0,FALSE,FALSE);
    Comment ( p_file,'End of Comments',0,FALSE,TRUE);

END API_Header;

PROCEDURE Load_PK_Attr_Tbl
IS
BEGIN

    g_pk_attr_tbl.DELETE;

    FOR I IN 1..g_attr_tbl.COUNT LOOP

	IF g_attr_tbl(I).pk_flag THEN

	    g_pk_attr_tbl(g_pk_attr_tbl.COUNT+1) := g_attr_tbl(I);

	END IF;

    END LOOP;

END Load_PK_Attr_Tbl;

PROCEDURE Load_Flex_Attr_Tbl
(   p_flex_name	    IN	VARCHAR2
)
IS
l_count	    NUMBER := 1;
l_attr_rec  Attribute_Rec_Type;
BEGIN

    g_flex_attr_tbl.DELETE;

    FOR I IN 1..g_attr_tbl.COUNT LOOP

	l_attr_rec := g_attr_tbl(I);

	IF  (	l_attr_rec.category = G_CAT_DESC_FLEX
	    OR	l_attr_rec.category = G_CAT_KEY_FLEX )
	AND l_attr_rec.text1 = p_flex_name
	THEN

	    g_flex_attr_tbl(l_count) := l_attr_rec;
	    l_count := l_count + 1;

	END IF;

    END LOOP;

END Load_Flex_Attr_Tbl;

PROCEDURE Load_Flex_Tables
IS
l_exists	BOOLEAN;
l_flex_rec	Flex_Rec_Type;
l_attr_rec	Attribute_Rec_Type;
BEGIN

    g_desc_flex_tbl.DELETE;
    g_key_flex_tbl.DELETE;

    FOR I IN 1..g_attr_tbl.COUNT LOOP

	l_attr_rec := g_attr_tbl(I);

	IF l_attr_rec.category = G_CAT_DESC_FLEX THEN

	    l_exists	:= FALSE;

	    FOR J IN 1..g_desc_flex_tbl.COUNT LOOP

		l_flex_rec := g_desc_flex_tbl(J);

		IF l_attr_rec.text1 = l_flex_rec.name THEN

		    --	Flexfield already in g_desc_flex_tbl

		    l_exists := TRUE;
		    g_desc_flex_tbl(J).seg_count := l_flex_rec.seg_count + 1;

		END IF;

	    END LOOP;

	    --	Check whether the flexfield was found or not.

	    IF NOT l_exists THEN

		l_flex_rec.name		:= l_attr_rec.text1;
		l_flex_rec.seg_count	:= 0;

		g_desc_flex_tbl(g_desc_flex_tbl.COUNT+1) := l_flex_rec;

	    END IF;

	ELSIF l_attr_rec.category = G_CAT_KEY_FLEX THEN

	    l_exists	:= FALSE;

	    FOR J IN 1..g_key_flex_tbl.COUNT LOOP

		l_flex_rec := g_key_flex_tbl(J);

		IF l_attr_rec.text1 = l_flex_rec.name THEN

		    --	Flexfield already in g_key_flex_tbl

		    l_exists := TRUE;
		    g_key_flex_tbl(J).seg_count := l_flex_rec.seg_count + 1;

		END IF;

	    END LOOP;

	    --	Check whether the flexfield was found or not.

	    IF NOT l_exists THEN

		l_flex_rec.name		:= l_attr_rec.text1;
		l_flex_rec.seg_count	:= 0;

		g_key_flex_tbl(g_key_flex_tbl.COUNT+1) := l_flex_rec;

	    END IF;

	END IF;

    END LOOP;

END Load_Flex_Tables;

PROCEDURE Parameter_PK
(   p_file	   IN  UTL_FILE.file_type
,   p_mode	   IN  VARCHAR2 := 'IN'
,   p_level	   IN  NUMBER := 0
,   p_rpad	   IN  NUMBER := 30
,   p_first	   IN  BOOLEAN := FALSE
,   p_default_miss IN  BOOLEAN := FALSE
,   p_value	   IN  BOOLEAN := FALSE
,   p_attr_tbl	   IN  Attribute_Tbl_Type :=
		       G_MISS_ATTR_TBL
)
IS
l_attr_rec	    Attribute_Rec_Type;
l_first		    BOOLEAN := p_first;
l_pk_attr_type	    VARCHAR2(240) := NULL;
l_pk_value_tbl	    Attribute_Tbl_Type;
l_attr_tbl	    Attribute_Tbl_Type;
BEGIN

   IF p_attr_tbl.COUNT = 0 THEN
      l_attr_tbl := g_pk_attr_tbl;
    ELSE
      l_attr_tbl := p_attr_tbl;
   END IF;

    FOR I IN 1..l_attr_tbl.COUNT LOOP

	l_attr_rec := l_attr_tbl(I);

	IF p_default_miss THEN
	   l_pk_attr_type := l_attr_rec.TYPE || ' := ';
	 ELSE
	   l_pk_attr_type := l_attr_rec.TYPE;
	END IF;

	Parameter
	(   p_file
	,   l_attr_rec.code
	,   p_mode
	,   l_pk_attr_type
	,   p_level
	,   p_rpad
	,   l_first
	);

	IF p_default_miss THEN

	   IF l_attr_rec.TYPE = OE_GENERATE.G_TYPE_NUMBER THEN
	      l_pk_attr_type := 'FND_API.G_MISS_NUM';
	    ELSIF l_attr_rec.TYPE = OE_GENERATE.G_TYPE_CHAR THEN
	      l_pk_attr_type := 'FND_API.G_MISS_CHAR';
	    ELSIF l_attr_rec.TYPE = OE_GENERATE.G_TYPE_DATE THEN
	      l_pk_attr_type := 'FND_API.G_MISS_DATE';
	   END IF;

	   Text
	   (  p_file
	   ,  l_pk_attr_type
	   ,  p_level + 10
	   );

	END IF;

	-- Add value parameters

	IF (p_value
	    AND
	    l_attr_rec.value) THEN

	  l_pk_value_tbl := Get_Attr_Values(l_attr_rec.code);

	  FOR j IN 1..l_pk_value_tbl.COUNT LOOP

	     IF p_default_miss THEN
		l_pk_attr_type := l_pk_value_tbl(j).type || ' := ';
	      ELSE
		l_pk_attr_type := l_pk_value_tbl(j).type;
	     END IF;

	     Parameter
	     (   p_file
	     ,   l_pk_value_tbl(j).name
	     ,   p_mode
	     ,   l_pk_attr_type
	     ,   p_level
	     ,   p_rpad
	     ,   l_first
	     );

	     IF p_default_miss THEN

		IF l_pk_value_tbl(j).type = OE_GENERATE.G_TYPE_NUMBER THEN
		   l_pk_attr_type := 'FND_API.G_MISS_NUM';
		 ELSIF l_pk_value_tbl(j).type = OE_GENERATE.G_TYPE_CHAR THEN
		   l_pk_attr_type := 'FND_API.G_MISS_CHAR';
		 ELSIF l_pk_value_tbl(j).type = OE_GENERATE.G_TYPE_DATE THEN
		   l_pk_attr_type := 'FND_API.G_MISS_DATE';
		END IF;

		Text
		( p_file
		, l_pk_attr_type
		, p_level + 10
		);

	     END IF;

	  END LOOP;

	END IF;

	l_first := FALSE;

    END LOOP;

END Parameter_PK;

PROCEDURE Call_Param_PK
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2 := NULL
,   p_val	IN  VARCHAR2 := NULL
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
)
IS
l_pk_attr_rec	    Attribute_Rec_Type;
l_first		    BOOLEAN := p_first;
BEGIN

    FOR I IN 1..g_pk_attr_tbl.COUNT LOOP

	l_pk_attr_rec := g_pk_attr_tbl(I);

	Call_Param
	(   p_file
	,   p_param||l_pk_attr_rec.code
	,   p_val||l_pk_attr_rec.code
	,   p_level
	,   p_rpad
	,   l_first
	);

	l_first := FALSE;

    END LOOP;

END Call_Param_PK;

PROCEDURE Add_Savepoint
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Comment ( p_file , 'Set Savepoint' , p_level );
    Text    ( p_file , 'SAVEPOINT '||p_name||';' , p_level );

END Add_Savepoint;

PROCEDURE Add_Rollback
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Comment ( p_file , 'Rollback' , p_level , FALSE, TRUE);
    Text    ( p_file , 'ROLLBACK TO '||p_name||';' , p_level );
    UTL_FILE.new_line (p_file);

END Add_Rollback;

PROCEDURE Load_Constants
(   p_entity_name	    IN	VARCHAR2
)
IS
BEGIN

    CONS_l_g_rec	    := 'g_'	||p_entity_name||'_rec';
    CONS_l_g_db_rec	    := 'g_db_'	||p_entity_name||'_rec';
    CONS_l_l_rec	    := 'l_'	||p_entity_name||'_rec';
    CONS_l_p_rec	    := 'p_'	||p_entity_name||'_rec';
    CONS_l_l_x_rec	    := 'l_x_'	||p_entity_name||'_rec';
    CONS_l_x_rec	    := 'x_'	||p_entity_name||'_rec';
    CONS_l_l_old_rec	    := 'l_old_'	||p_entity_name||'_rec';
    CONS_l_p_old_rec	    := 'p_old_'	||p_entity_name||'_rec';
    CONS_l_x_old_rec	    := 'x_old_'	||p_entity_name||'_rec';
    CONS_l_l_val_rec	    := 'l_'	||p_entity_name||'_val_rec';
    CONS_l_p_val_rec	    := 'p_'	||p_entity_name||'_val_rec';
    CONS_l_g_val_rec	    := 'g_'	||p_entity_name||'_val_rec';
    CONS_l_x_val_rec	    := 'x_'	||p_entity_name||'_val_rec';
    CONS_l_l_tbl	    := 'l_'	||p_entity_name||'_tbl';
    CONS_l_g_tbl	    := 'g_'	||p_entity_name||'_tbl';
    CONS_l_p_tbl	    := 'p_'	||p_entity_name||'_tbl';
    CONS_l_l_x_tbl	    := 'l_x_'	||p_entity_name||'_tbl';
    CONS_l_x_tbl	    := 'x_'	||p_entity_name||'_tbl';
    CONS_l_l_old_tbl	    := 'l_old_'	||p_entity_name||'_tbl';
    CONS_l_p_old_tbl	    := 'p_old_'	||p_entity_name||'_tbl';
    CONS_l_x_old_tbl	    := 'x_old_'	||p_entity_name||'_tbl';
    CONS_l_g_val_tbl	    := 'g_'	||p_entity_name||'_val_tbl';
    CONS_l_p_val_tbl	    := 'p_'	||p_entity_name||'_val_tbl';
    CONS_l_x_val_tbl	    := 'x_'	||p_entity_name||'_val_tbl';

    CONS_l_pub_bus_obj_pkg  :=	g_product || '_' ||
				INITCAP(g_object_name) || '_PUB';
    CONS_l_pvt_bus_obj_pkg  :=	g_product || '_' ||
				INITCAP(g_object_name) || '_PVT';
    CONS_l_entity_attr_pkg  :=	g_product || '_' ||
				UPPER(p_entity_name) || '_ATTR';
    CONS_l_rec_type	    :=	CONS_l_pub_bus_obj_pkg || '.' ||
				INITCAP(p_entity_name) || '_Rec_Type';
    CONS_l_tbl_type	    :=	CONS_l_pub_bus_obj_pkg || '.' ||
				INITCAP(p_entity_name) || '_Tbl_Type';
    CONS_l_val_rec_type	    :=	CONS_l_pub_bus_obj_pkg || '.' ||
				INITCAP(p_entity_name) ||'_Val_Rec_Type';
    CONS_l_val_tbl_type	    :=	CONS_l_pub_bus_obj_pkg || '.' ||
				INITCAP(p_entity_name) ||'_Val_Tbl_Type';
    CONS_l_ctrl_rec_type    :=	g_product||'_GLOBALS.Control_Rec_Type';
    CONS_l_entity_prefix    :=	g_product || '_GLOBALS.G_ENTITY_';
    CONS_l_form_pkg	    :=  g_product||'_'||g_form_code||'_Form_'||
				INITCAP(p_entity_name);

    CONS_l_util_pkg	    :=	g_product||'_'||
				INITCAP(p_entity_name)||'_Util';
    CONS_l_def_pkg	    :=	g_product||'_Default_'||
				INITCAP(p_entity_name);
    CONS_l_val_pkg	    :=	g_product||'_Validate_'||
				INITCAP(p_entity_name);
    CONS_l_id_to_value_pkg  :=	g_product||'_Id_To_Value';
    CONS_l_glb_pkg	    :=	g_product||'_GLOBALS';

    CONS_l_val_to_id_pkg    :=	g_product||'_Value_To_Id';

    CONS_l_miss_rec	    := 	CONS_l_pub_bus_obj_pkg||'.G_MISS_'||
				UPPER(p_entity_name)||'_REC';
    CONS_l_miss_val_rec	    := 	CONS_l_pub_bus_obj_pkg||'.G_MISS_'||
				UPPER(p_entity_name)||'_VAL_REC';
    CONS_l_miss_tbl	    := 	CONS_l_pub_bus_obj_pkg||'.G_MISS_'||
				UPPER(p_entity_name)||'_TBL';
    CONS_l_miss_val_tbl	    := 	CONS_l_pub_bus_obj_pkg||'.G_MISS_'||
				UPPER(p_entity_name)||'_VAL_TBL';

END Load_Constants;

PROCEDURE End_If
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Text    ( p_file , 'END IF;' , p_level );

END End_If;

PROCEDURE Add_Then
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Text    ( p_file , 'THEN' , p_level );

END Add_Then;

PROCEDURE Add_Is
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 0
)
IS
BEGIN

    Text    ( p_file , 'IS' , p_level );

END Add_Is;

PROCEDURE Add_Begin
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 0
)
IS
BEGIN

    Text    ( p_file , 'BEGIN' , p_level );

END Add_Begin;

PROCEDURE Add_Else
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Text    ( p_file , 'ELSE' , p_level );

END Add_Else;

PROCEDURE End_Loop
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
)
IS
BEGIN

    Text    ( p_file , 'END LOOP;' , p_level );

END End_Loop;

PROCEDURE Log_Compile
(   p_pkg_name	    IN	VARCHAR2
,   p_filename	    IN	VARCHAR2
,   p_pkg_type	    IN	VARCHAR2
)
IS
l_gen_pkg_rec	gen_pkg_rec_type;
BEGIN

    --	Add package to generated package table.

    l_gen_pkg_rec.name := p_pkg_name;
    l_gen_pkg_rec.type := p_pkg_type;
    l_gen_pkg_rec.filename := p_filename;

    g_gen_pkg_tbl(g_gen_pkg_tbl.COUNT+1) := l_gen_pkg_rec;

END Log_Compile;

FUNCTION Get_Name_In
(   p_attr_rec	    IN	Attribute_Rec_type
,   p_block_name    IN	VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN

    IF p_attr_rec.type = G_TYPE_DATE THEN
	RETURN 'Dates_NLS.Char_To_Date(Name_In('''||p_block_name||'.'
	    ||UPPER(p_attr_rec.code)||'''))';
    ELSE
	RETURN 'Name_In('''||p_block_name||'.'||UPPER(p_attr_rec.code)||''')';
    END IF;

END Get_Name_In;

PROCEDURE Add_Copy
(   p_file	    IN	UTL_FILE.file_type
,   p_source	    IN	VARCHAR2
,   p_dest	    IN	VARCHAR2
,   p_type	    IN	VARCHAR2 := G_TYPE_CHAR
,   p_level	    IN	NUMBER := 1
)
IS
BEGIN

    IF p_type = G_TYPE_NUMBER THEN
	Text(p_file,'Copy(To_Char('||p_source||'),'''||p_dest||''');',p_level);
    ELSIF p_type = G_TYPE_DATE THEN
	Text(p_file,'Copy(Dates_NLS.Date_To_Char('||p_source||'),'''||p_dest||''');',p_level);
    ELSIF p_type = G_TYPE_CHAR THEN
	Text (p_file,'Copy('||p_source||','''||p_dest||''');',p_level);
    END IF;

END Add_Copy;

PROCEDURE IDL_Comment
(   p_file	    IN  UTL_FILE.file_type
,   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER := 1
,   p_line_before   IN	BOOLEAN := TRUE
,   p_line_after    IN	BOOLEAN := TRUE
)
IS
BEGIN

    IF p_line_before THEN
        UTL_FILE.new_line(p_file);
    END IF;

    Text(p_file,'//  '||p_comment,p_level);

    IF p_line_after THEN
        UTL_FILE.new_line(p_file);
    END IF;

END IDL_Comment;

PROCEDURE IDL_Header
(   p_file	    IN  UTL_FILE.file_type
,   p_filename	    IN  VARCHAR2
,   p_object_name   IN  VARCHAR2
)
IS
BEGIN

    --	Copyright section.

    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file ,
	'Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA',
				0,FALSE,FALSE);
    IDL_Comment ( p_file , 'All rights reserved.',0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file , 'FILENAME',0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file , '    '||p_filename,0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file , 'DESCRIPTION',0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file , '    '||'CORBA IDL for '||p_object_name||
			' business object.' ,0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file ,'NOTES',0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file ,'HISTORY',0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,FALSE);
    IDL_Comment ( p_file , TO_CHAR(SYSDATE)||' Created',0,FALSE,FALSE);
    IDL_Comment ( p_file , '',0,FALSE,TRUE);

    --	$Header clause.

    Text (p_file,'/* $Header: OEXTGENB.pls 120.0 2005/06/01 23:18:13 appldev noship $ */',0);

    --	Standard INCLUDE clause.

    IDL_Comment ( p_file , 'Standard Include',0);
    Text ( p_file,'#include "../fnd/arb/arb.idl"',0);

    --	Module name

    IDL_Comment ( p_file , 'Module definition',0);
    Text ( p_file,'module '||p_object_name||' { module IDL {',0);

END IDL_Header;

FUNCTION Strip_Underscore
(   p_string	    IN	VARCHAR2
)
RETURN VARCHAR2
IS
l_buffer	VARCHAR2(2000);
l_begin		NUMBER;
l_position	NUMBER;
BEGIN

    l_begin	:=  1;
    l_buffer	:=  NULL;

    l_position	:= INSTR ( p_string , '_' , l_begin , 1 );

    WHILE l_position <> 0 LOOP


	l_buffer := l_buffer ||
		    INITCAP(SUBSTR(p_string,l_begin,l_position-l_begin)) ;


	l_begin := l_position + 1 ;

	l_position	:= INSTR ( p_string , '_' , l_begin , 1 );

    END LOOP;

    RETURN l_buffer||INITCAP(SUBSTR(p_string,l_begin,
		LENGTH(p_string)-l_begin+1)) ;

END Strip_Underscore;

PROCEDURE Strip_Entities
IS
BEGIN

    --	Object name

    g_object_name := Strip_Underscore ( g_object_name );

    --	Entity names

    FOR I IN 1..g_entity_tbl.COUNT LOOP

	g_entity_tbl(I).name := Strip_Underscore (g_entity_tbl(I).name);

    END LOOP;

END Strip_Entities;

FUNCTION Strip_Attributes
(   p_attr_tbl	    IN	Attribute_Tbl_Type
)
RETURN Attribute_Tbl_Type
IS
l_attr_tbl  Attribute_Tbl_Type;
l_attr_rec  Attribute_Rec_Type;
BEGIN

    FOR I IN 1..p_attr_tbl.COUNT LOOP

	l_attr_rec := p_attr_tbl(I);
	l_attr_rec.name := Strip_Underscore (l_attr_rec.name);
	l_attr_tbl(I) := l_attr_rec;

    END LOOP;

    RETURN l_attr_tbl;

END Strip_Attributes;

PROCEDURE IDL_Parameter
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2
,   p_mode	IN  VARCHAR2 := 'in'
,   p_type	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_first	IN  BOOLEAN := FALSE
)
IS
l_first		varchar2(1);
l_prefix	VARCHAR2(10);
l_rpad		NUMBER;
BEGIN

    IF p_mode = 'in' THEN
	l_prefix := 'p';
    ELSE
	l_prefix := 'x';
    END IF;

    IF p_first THEN
	l_first := '(';
    ELSE
	l_first := ',';
    END IF;

    IF 32 <= LENGTH(p_type) THEN
	l_rpad := LENGTH(p_type) +1;
    ELSE
	l_rpad := 32;
    END IF;

    Text(   p_file
	,   RPAD(l_first,4)||RPAD(p_mode,4)||RPAD(p_type,l_rpad)
	    ||l_prefix||p_param
	,   p_level
	);

END IDL_Parameter;

FUNCTION Get_Attr_Values
(   p_attr_code	    IN	VARCHAR2
) RETURN Attribute_Tbl_Type
IS
l_attr_tbl	Attribute_Tbl_Type;
BEGIN

    FOR I IN 1..g_attr_value_tbl.COUNT LOOP

	IF g_attr_value_tbl(I).code = p_attr_code THEN

	    l_attr_tbl(l_attr_tbl.COUNT+1) := g_attr_value_tbl(I);

	END IF;

    END LOOP;

    RETURN l_attr_tbl;

END Get_Attr_Values;

PROCEDURE Get_Api_Parameters
(   p_file	    IN  UTL_FILE.file_type
,   p_product	    IN	VARCHAR2
,   p_object	    IN	VARCHAR2
,   p_name	    IN  VARCHAR2
,   p_type	    IN  VARCHAR2 := G_API_TYPE_PVT
,   p_entity_tbl    IN	Entity_Tbl_Type
)
IS
   l_entity_attr_tbl	Attribute_Tbl_Type;
   l_p_pkg		VARCHAR2(30) := NULL;
   l_attr_csr		INTEGER;
   l_result		INTEGER;
   l_default_and_val	BOOLEAN := FALSE;
BEGIN

   IF p_type <> G_API_TYPE_PUB
     THEN
      l_p_pkg := p_product || '_' || INITCAP(p_object) || '_PUB.';
   END IF;

   IF p_type = G_API_TYPE_PUB THEN
      l_default_and_val := TRUE;
   END IF;

   Text (p_file ,'PROCEDURE '||p_name,0);

   --	IN parameters.

   Parameter(p_file,'api_version_number','IN',
	     G_TYPE_NUMBER,0,30,TRUE);
   Parameter(p_file,'init_msg_list','IN',
	     'VARCHAR2 := FND_API.G_FALSE',0);

   IF p_type = G_API_TYPE_PUB
     THEN
      Parameter(p_file,'return_values','IN',
		'VARCHAR2 := FND_API.G_FALSE',0);
   END IF;

   Parameter(p_file,'return_status','OUT',
	     G_TYPE_CHAR,0);
   Parameter(p_file,'msg_count','OUT',
	     G_TYPE_NUMBER,0);
   Parameter(p_file,'msg_data','OUT',
	     G_TYPE_CHAR,0);

   --	In ID and Value parameters.

   FOR I IN 1..p_entity_tbl.COUNT LOOP

      -- For root object

      IF p_entity_tbl(I).parent IS NULL
	THEN

	 Load_Entity_Attributes(p_entity_tbl(I));

	 Load_Entity_Attribute_Values(p_entity_tbl(I));

	 Parameter_PK
	 (   p_file		=>  p_file
	 ,   p_first		=>  FALSE
	 ,   p_default_miss	=>  l_default_and_val
	 ,   p_value		=>  l_default_and_val
	 );

      END IF;

   END LOOP;

   --	OUT parameters.

   FOR I IN 1..p_entity_tbl.COUNT LOOP

      --  for each entity add one OUT

	IF Multiple_Branch(I) THEN

	 --	Add tbl.

	 Parameter
	 (   p_file
	 ,   p_entity_tbl(I).name||'_tbl'
	 ,   'OUT'
	 ,   l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Tbl_Type'
	 ,   0
	 );

	 IF p_type = G_API_TYPE_PUB THEN

	    Parameter
	    (p_file
	    ,p_entity_tbl(I).name||'_val_tbl'
	    ,'OUT'
	    ,l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Val_Tbl_Type'
	    ,0
	    );

	 END IF;

       ELSE

	 --	Add Rec

	 Parameter
	   (p_file
	    ,p_entity_tbl(I).name||'_rec'
	    ,'OUT'
	    ,l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Rec_Type'
	    ,0
	    );

	 IF p_type = G_API_TYPE_PUB THEN

	    Parameter
	    (p_file
	    ,p_entity_tbl(I).name||'_val_rec'
	    ,'OUT'
	    ,l_p_pkg||INITCAP(p_entity_tbl(I).name)||'_Val_Rec_Type'
	    ,0
	    );

	 END IF;

      END IF;

   END LOOP;

END Get_Api_Parameters;

PROCEDURE Null_Or_Missing
(  p_file		IN  UTL_FILE.file_type
,  p_attribute		IN  attribute_rec_type
,  p_prefix_text	IN  VARCHAR2 := NULL
,  p_not		IN  BOOLEAN := TRUE
,  p_and		IN  BOOLEAN := TRUE
,  p_level		IN  NUMBER  := 1
,  p_first		IN  BOOLEAN := FALSE
)
IS
   l_buffer1		VARCHAR2(100) := NULL;
   l_buffer2		VARCHAR2(10) := NULL;
   l_buffer3		VARCHAR2(10) := NULL;
   l_pk_attr_type	VARCHAR2(30) := NULL;
BEGIN


   IF p_attribute.type = OE_GENERATE.G_TYPE_NUMBER THEN
      l_pk_attr_type := 'FND_API.G_MISS_NUM';
    ELSIF p_attribute.type = OE_GENERATE.G_TYPE_CHAR THEN
      l_pk_attr_type := 'FND_API.G_MISS_CHAR';
    ELSIF p_attribute.type = OE_GENERATE.G_TYPE_DATE THEN
      l_pk_attr_type := 'FND_API.G_MISS_DATE';
   END IF;

   l_buffer1 := p_prefix_text || p_attribute.code;

   IF p_not THEN
      l_buffer2 := ' NOT';
      l_buffer3 := ' <> ';
    ELSE
      l_buffer2 := NULL;
      l_buffer3 := ' = ';
   END IF;

   IF NOT p_first THEN
      IF p_and THEN
	 OE_GENERATE.Text (p_file , 'AND' , p_level);
       ELSE
	 OE_GENERATE.Text (p_file , 'OR' , p_level);
      END IF;
      -- UTL_FILE.new_line(p_file);
   END IF;

   OE_GENERATE.Text
   (   p_file
   ,   '(' || l_buffer1 || ' IS' || l_buffer2 || ' NULL'
   ,   p_level
   );

   IF p_and THEN
      OE_GENERATE.Text (p_file , ' AND' , p_level);
    ELSE
      OE_GENERATE.Text (p_file , ' OR' , p_level);
   END IF;

   OE_GENERATE.Text
   (   p_file
   ,   ' ' || l_buffer1 || l_buffer3 || l_pk_attr_type || ')'
   ,   p_level
   );

END Null_Or_Missing;

PROCEDURE Load_Entity_Attributes
(   p_entity_rec    IN  Entity_Rec_Type
)
IS
   l_attr_csr		INTEGER;
   l_result		INTEGER;
BEGIN

   --  Get entity attributes. Use dynamic SQL.

   l_attr_csr := DBMS_SQL.open_cursor;

   --  Parse statement.

   DBMS_SQL.parse
     (c		=> l_attr_csr,
      statement	=> 'BEGIN ' || g_product || '_' ||
		   p_entity_rec.name ||
		   '_Attr.Get_Attr_tbl; END;',
      language_flag	=> DBMS_SQL.native
      );

   --  Execute procedure

   l_result := DBMS_SQL.execute(l_attr_csr);

   IF l_result = 0 THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   --  Close the cursor.

   DBMS_SQL.close_cursor (l_attr_csr);

   --  Load the primary key attribute table.

   Load_PK_Attr_Tbl;

END Load_Entity_Attributes;

PROCEDURE Load_Entity_Attribute_Values
(   p_entity_rec    IN  Entity_Rec_Type
)
IS
   l_attr_csr		INTEGER;
   l_result		INTEGER;
BEGIN

   --  Get entity attributes. Use dynamic SQL.

   l_attr_csr := DBMS_SQL.open_cursor;

   --  Parse statement.

   DBMS_SQL.parse
     (c		=> l_attr_csr,
      statement	=> 'BEGIN ' || g_product || '_' ||
		   p_entity_rec.name ||
		   '_Attr.Get_Attr_Value_tbl; END;',
      language_flag	=> DBMS_SQL.native
      );

   --  Execute procedure

   l_result := DBMS_SQL.execute(l_attr_csr);

   IF l_result = 0 THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   --  Close the cursor.

   DBMS_SQL.close_cursor (l_attr_csr);

END Load_Entity_Attribute_Values;

FUNCTION Multiple_Branch
(   p_index	    IN	NUMBER
) RETURN BOOLEAN
IS
BEGIN

    IF p_index IS NULL THEN
	RETURN FALSE;
    END IF;

    IF g_entity_tbl(p_index).multiple THEN
	RETURN TRUE;
    ELSE
	RETURN Multiple_Branch(g_entity_tbl(p_index).parent);
    END IF;

END Multiple_Branch;

FUNCTION Multiple_Branch
(   p_entity_name    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    FOR I IN 1..g_entity_tbl.COUNT LOOP

	IF p_entity_name = g_entity_tbl(I).name	THEN

	    RETURN Multiple_Branch(I);

	END IF;

    END LOOP;


    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multiple_Branch;

FUNCTION Convert_Entity_Rec_Type
(   p_runtime_entity_rec	    IN	FND_API.Entity_Rec_Type
) RETURN OE_GENERATE.Entity_Rec_Type
IS
l_entity_rec	    OE_GENERATE.Entity_Rec_Type;
BEGIN

    l_entity_rec.name	    := p_runtime_entity_rec.name ;
    l_entity_rec.tbl	    := p_runtime_entity_rec.tbl ;
    l_entity_rec.parent	    := p_runtime_entity_rec.parent ;
    l_entity_rec.multiple   := p_runtime_entity_rec.multiple ;
    l_entity_rec.code	    := p_runtime_entity_rec.code ;
    l_entity_rec.pk_column  := p_runtime_entity_rec.pk_column ;
    l_entity_rec.text1	    := p_runtime_entity_rec.text1 ;
    l_entity_rec.text2	    := p_runtime_entity_rec.text2 ;
    l_entity_rec.text3	    := p_runtime_entity_rec.text3 ;

    RETURN l_entity_rec;

END Convert_Entity_Rec_Type;

FUNCTION Convert_Entity_Tbl_Type
(   p_runtime_entity_tbl	    IN	FND_API.Entity_Tbl_Type
) RETURN OE_GENERATE.Entity_Tbl_Type
IS
l_entity_tbl	    OE_GENERATE.Entity_Tbl_Type;
BEGIN

    FOR I IN 1..p_runtime_entity_tbl.COUNT LOOP

	l_entity_tbl(I)  := Convert_Entity_Rec_Type(p_runtime_entity_tbl(I));

    END LOOP;

    RETURN l_entity_tbl;

END Convert_Entity_Tbl_Type;

END OE_GENERATE;

/
