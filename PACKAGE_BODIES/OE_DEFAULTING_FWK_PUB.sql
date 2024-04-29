--------------------------------------------------------
--  DDL for Package Body OE_DEFAULTING_FWK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULTING_FWK_PUB" AS
/* $Header: OEXDFWKB.pls 120.2 2006/09/15 17:22:43 chhung noship $ */

--  Global constant holding the package name

G_PKG_NAME      	CONSTANT    VARCHAR2(30):= 'OE_Defaulting_Fwk_PUB';
g_login_seq		VARCHAR2(15) := abs(FND_GLOBAL.login_id);
g_schema	        VARCHAR2(30);
g_conc_mode             VARCHAR2(1);

-- 5529963 : from ad_ddl.build_package spec. max_line_size is up tp 256 char
g_max_line_size        NUMBER := 256;

line_number	        NUMBER := 0;
--  Global Cache Table defined for Performance issue we want to genarate PkgBdy once
TYPE g_cache_pkgbdy_rec_Type IS RECORD
(   entity_id              number default null,
    package_spec           varchar2(1) default null,
    package_body           varchar2(1) default null);

TYPE g_PkgBdy_Tbl_Type IS TABLE OF g_cache_pkgbdy_rec_Type
    INDEX BY BINARY_INTEGER;

g_PkgBdy_tbl            g_PkgBdy_Tbl_Type;

-- LOCAL PROCEDURES
-------------------------------------------------------------------------
PROCEDURE Put_Line
     (Text Varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
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

END Put_Line;

PROCEDURE Init_Applsys_Schema
IS
l_app_info		BOOLEAN;
l_status			VARCHAR2(30);
l_industry		VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	if g_schema is null then

      l_app_info := FND_INSTALLATION.GET_APP_INFO
	    ('FND',l_status, l_industry, g_schema);

	end if;

END;

-------------------------------------------------------------------------
PROCEDURE New_Line
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    line_number := line_number + 1;
    ad_ddl.build_package(' ',line_number);

END New_Line;

-------------------------------------------------------------------------
PROCEDURE Comment
(   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER default 1
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    Text('--  '||p_comment,p_level);

END Comment;

-------------------------------------------------------------------------------
PROCEDURE Text
(   p_string	IN  VARCHAR2
,   p_level	IN  NUMBER default 1
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    line_number := line_number + 1;
    /* replaced with the next line for bug fix 3179429
    ad_ddl.build_package(LPAD(p_string,p_level*2+LENGTH(p_string)),line_number);
    */
    ad_ddl.build_package(LPAD(' ', p_level*2)||p_string, line_number);

END text;

-------------------------------------------------------------------------------
PROCEDURE Parameter
(   p_param	IN  VARCHAR2
,   p_mode	IN  VARCHAR2 := 'IN'
,   p_type	IN  VARCHAR2 := 'NUMBER'
,   p_level	IN  NUMBER default  1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
)
IS
l_first		varchar2(1);
l_prefix	VARCHAR2(10);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF rtrim(p_mode) = 'IN' THEN
	l_prefix := '   p_';
    ELSE
	l_prefix := '   x_';
    END IF;

    IF p_first THEN
	l_first := '(';
    ELSE
	l_first := ',';
    END IF;

    Text(  l_first||l_prefix||RPAD(p_param,p_rpad)||RPAD(p_mode,4)||p_type
	,   p_level
	);

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
					--
					l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
					--
BEGIN

    --	end statement.
    Text('END '||p_pkg_name||';',0);

    --	Show errors.
    IF p_pkg_type = 'BODY' THEN
	l_is_pkg_body := 'TRUE';
    ELSE
	l_is_pkg_body := 'FALSE';
    END IF;

    PUT_LINE(
		'Call AD_DDL to create '||p_pkg_type||' of package '||p_pkg_name);


    ad_ddl.create_package(applsys_schema => g_schema
	,application_short_name	=> 'ONT'
	,package_name			=> p_pkg_name
	,is_package_body		=> l_is_pkg_body
	,lb					=> 1
	,ub					=> line_number);

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
--	PUT_LINE('Iam into exception' ||ad_ddl.error_buf);
--	  RAISE FND_API.G_EXC_ERROR;

END Pkg_End;

-------------------------------------------------------------------------------
-- Generates the Package Header for the package SPEC AND BODY

PROCEDURE Pkg_Header
(   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
)
IS
header_string		VARCHAR2(200);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Initialize line number
    line_number := 0;

--	Define package.

    IF p_pkg_type = 'BODY' THEN
	Text ('CREATE or REPLACE PACKAGE BODY '||
		p_pkg_name|| ' AS',0);
    ELSE
	Text ('CREATE or REPLACE PACKAGE '||
		p_pkg_name|| ' AUTHID CURRENT_USER AS',0);
    END IF;

    --	$Header clause.
    header_string := 'Header: OEXDFWKB.pls 115.0 '||sysdate||' 23:23:31 appldev ship ';
	Text('/* $'||header_string||'$ */',0);
	New_Line;

    --	Copyright section.

    Comment ( '',0 );
    Comment (
	'Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA',0);
    Comment ( 'All rights reserved.',0);
    Comment ( '',0);
    Comment ( 'FILENAME',0);
    Comment ( '',0);
    Comment ( '    '||p_pkg_name,0);
    Comment ( '',0);
    Comment ( 'DESCRIPTION',0);
    Comment ( '',0);
    Comment ( '    '||INITCAP(p_pkg_type)||' of package '
		||p_pkg_name,0);
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

-------------------------------------------------------------------------------
PROCEDURE Assign
(   p_left	IN  VARCHAR2
,   p_right	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
)
IS
l_rpad		NUMBER:=p_rpad;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_rpad = -1 OR
	p_rpad < LENGTH(p_left)
    THEN
	l_rpad := LENGTH(p_left);
    END IF;

    Text( RPAD(p_left,l_rpad)||' := '||p_right||';'
	,   p_level
	);

END Assign;


--------------------------------------------------------------------------
-- PUBLIC PROCEDURES
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- PROCEDURE Create_Entity_Def_handler
-- This procedure generates the defaulting handler for the Rule based
-- Defaulting Framework.
-- Called by concurrent program: DEFGEN
--
-- ARGUMENTS:
-- retcode		=> parameter passed to concurrent program
-- errbuf			=> parameter passed to concurrent program
-- p_application_id => entity application ID (for Order Entry, = 300)
-- p_database_object_name => database object name stored in OE_AK_OBJECTS_EXT table
--					(for Order Line, = 'OE_AK_ORDER_LINES_V')
--------------------------------------------------------------------------

PROCEDURE Create_Entity_Def_handler
(
retcode OUT NOCOPY VARCHAR2,

errbuf OUT NOCOPY VARCHAR2,

 p_application_id         IN  VARCHAR2,
 p_database_object_name   IN  VARCHAR2,
 p_attribute_code         IN  VARCHAR2 DEFAULT NULL,
 p_generate_all           IN  VARCHAR2 DEFAULT 'Y'
)
IS

-- table declaration
TYPE obj_attr_tbl_type IS TABLE OF OE_DEF_AK_ATTR_EXT_V%ROWTYPE
INDEX BY BINARY_INTEGER;

l_obj_attr_tbl          obj_attr_tbl_type;

-- variables declaration
J			NUMBER;
l_entity_code		VARCHAR2(15);
l_app_short_name		VARCHAR2(3);
l_application_id		NUMBER;
l_column_name		VARCHAR2(30);
l_status		VARCHAR2(10);
l_pkg_name		VARCHAR2(30);
l_related_pkg		VARCHAR2(30);
l_generated_pkg		VARCHAR2(30);
l_attribute_code	VARCHAR2(30);
l_defaulting_api		VARCHAR2(61);
l_defaulting_api_pkg		VARCHAR2(30);
l_defaulting_api_proc		VARCHAR2(30);
l_validation_api		VARCHAR2(61);
l_validation_api_pkg		VARCHAR2(30);
l_validation_api_proc		VARCHAR2(30);
l_depend_api	        	VARCHAR2(61);
l_dependent_api_pkg		VARCHAR2(30);
l_dependent_api_proc		VARCHAR2(30);
l_security_api_pkg		VARCHAR2(30);
l_security_api_proc		VARCHAR2(30);
l_security_api			VARCHAR2(61);
l_buffer                               VARCHAR2(20);
l_defaulting_condn_ref_flag   		VARCHAR2(1);
l_defaulting_enabled_flag   		VARCHAR2(1);
l_data_type			VARCHAR2(30);
l_related_entity_code		VARCHAR2(15);
l_related_database_object_name	VARCHAR2(30);
l_uk_name		VARCHAR2(30);
l_fk_name		VARCHAR2(30);
l_entity_id             NUMBER;

-- CURSOR to SELECT the application name

CURSOR APP
is
	SELECT substr(rtrim(APPLICATION_SHORT_NAME),1,3)
	FROM fnd_application
	WHERE application_id = p_application_id;

CURSOR OBJ (p_database_object_name varchar2,p_application_id number)
 is
	SELECT ENTITY_CODE
	FROM OE_DEF_AK_OBJ_EXT_V
	WHERE database_object_name = p_database_object_name
	AND application_id = p_application_id;


-- This CURSOR SELECTs all the related views for the current entity.
-- This will be used when the defaulting source is FROM a "Related Record"

CURSOR FKEY (p_database_object_name varchar2,p_application_id number)
IS
	SELECT distinct fk.unique_key_name
               ,uk.database_object_name uk_database_object_name
               ,fk.foreign_key_name
	       ,obj.entity_code uk_entity_code
               , obj.defaulting_enabled_flag uk_obj_defaulting_enabled
	FROM AK_FOREIGN_KEYS fk, AK_UNIQUE_KEYS uk, OE_AK_OBJECTS_EXT obj
	WHERE fk.database_object_name= p_database_object_name
	  AND fk.application_id= p_application_id
          AND fk.unique_key_name = uk.unique_key_name
          AND fk.application_id = uk.application_id
	  AND uk.database_object_name = obj.database_object_name
          AND obj.application_id = p_application_id;

-- This CURSOR fetches all the attributes for the entity for which
-- defaulting can be done.
-- Note that only the attributes that are of 3rd normal form attributes
-- are being defaulted.

CURSOR OAORDER(p_database_object_name varchar2,p_application_id number)
 is
	SELECT ak.column_name,
		oe.attribute_code,
		ak.data_type,
		ak.defaulting_api_pkg,
		ak.defaulting_api_proc,
		ak.validation_api_pkg,
		ak.validation_api_proc,
		oe.dependent_api_pkg,
		oe.dependent_api_proc,
		oe.security_api_pkg,
		oe.security_api_proc,
	        oe.defaulting_condn_ref_flag,
		oe.defaulting_enabled_flag
	FROM OE_AK_OBJ_ATTR_EXT OE
		, AK_OBJECT_ATTRIBUTES_VL ak
	WHERE oe.database_object_name  = p_database_object_name
	AND oe.attribute_application_id = p_application_id
        AND ak.database_object_name = oe.database_object_name
	AND ak.attribute_code = oe.attribute_code
	AND ak.attribute_application_id = oe.attribute_application_id
	ORDER BY oe.defaulting_sequence, ak.attribute_label_long;

-- This CURSOR SELECTs the attribute code FROM ak unique keys.
-- This will be used only when the primary key is comprised of a single column.
-- If the primary key has more than one column, then in the later part of the
-- code we loop through to get all the keys.

 CURSOR PKGSTATUS(cp_pkg_name VARCHAR2)
 IS
	SELECT NVL(status,'INVALID')
	--FROM dba_objects
	FROM user_objects
	WHERE object_name = UPPER(cp_pkg_name);

l_attr_str		VARCHAR2(50);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  Init_Applsys_Schema;

  open APP;
  fetch APP into l_app_short_name;
  close APP;

  open OBJ (p_database_object_name, p_application_id);
  fetch OBJ into l_entity_code;
  close OBJ;

  -- Performance Bug 1678746:
  -- IF p_attribute_code is passed, then generate defaulting handler
  -- package only for this attribute else generate for the entity
  -- and all its attributes.

  IF p_attribute_code IS NOT NULL THEN
     PUT_LINE('Create defaulting handler for attribute: '
              ||p_attribute_code);
     Create_Obj_Attr_Def_handler
            (p_application_id         => p_application_id,
             p_database_object_name   => p_database_object_name,
             p_attribute_code         => p_attribute_code,
             p_entity_code            => l_entity_code,
             p_generation_level       => 'BODY_ONLY',
             x_defaulting_api_pkg     => l_generated_pkg );
     PUT_LINE('Attribute handler package generated :'||l_generated_pkg);
     RETURN;
  END IF;

  -- Construct the pkg name(eg ONT_Header_Def_Hdlr)
  l_application_id := p_application_id;

  l_pkg_name := l_app_short_name||'_'||l_entity_code||'_Def'||'_Hdlr';

-------------------------------------------------------------------------------
-- (1) GENERATE THE SPECS OF UTIL PACKAGES FOR RELATED ENTITITES
--     e.g. ONT_PRICE_LIST_DEF_UTIL
-- NOTE: The spec of ALL related entities should be generated BEFORE the
-- package body as there maybe calls to other entity utilities
-------------------------------------------------------------------------------

FOR fkey_view in FKEY (p_database_object_name ,p_application_id )
LOOP

l_related_database_object_name := fkey_view.uk_database_object_name;
l_uk_name := fkey_view.unique_key_name;
l_fk_name := fkey_view.foreign_key_name;
l_related_entity_code := fkey_view.uk_entity_code;

-- This will never fetch null entity code because the oe_def_ak_fkeys_v
-- will fetch only the entities WHERE entity_code is not null.
l_related_pkg := l_app_short_name||'_'||l_related_entity_code||'_Def'||'_Util';

OPEN PKGSTATUS(l_related_pkg );
FETCH PKGSTATUS INTO l_status;

if PKGSTATUS%NOTFOUND then
 l_status := 'INVALID';
end if;
CLOSE PKGSTATUS;

-- For the related entities,
--  a) if p_generate_all= 'Y', generate util packages for all related entities
--  or b) if p_generate_all = 'N', then generate util package for related
--		entity only if the util package does not exist OR is invalid
--  Workaround for bug 1699929: For HEADER and LINE entities, do not generate
--  the spec as it will invalidate OE_HEADER_UTIL and OE_LINE_UTIL packages
IF  (l_status = 'INVALID'
     OR p_generate_all = 'Y')
 AND (p_application_id <> 660
	 OR l_related_entity_code NOT IN ('HEADER','LINE') )
THEN

       select entity_id into l_entity_id
       from oe_ak_objects_ext
       where DATABASE_OBJECT_NAME =l_related_database_object_name;

       PUT_LINE(
		'--------------------------------');
       PUT_LINE('entity id :'||l_entity_id);
       if g_PkgBdy_tbl.exists(l_entity_id) then
          PUT_LINE('cache exists');
          PUT_LINE('package spec :'||g_PkgBdy_tbl(l_entity_id).package_spec);
          PUT_LINE('package body :'||g_PkgBdy_tbl(l_entity_id).package_body);
       else
          PUT_LINE('cache does not exist');
       end if;

       if (not g_PkgBdy_tbl.exists(l_entity_id) or nvl(g_PkgBdy_tbl(l_entity_id).package_spec,'X') <>  'S')
       then

	PUT_LINE(
		'Create caching/util package for related entity: '||l_related_entity_code);
	Create_Entity_Def_Util_handler
		( p_application_id		=>p_application_id
		, p_database_object_name	=> l_related_database_object_name
		, p_entity_code		=> l_related_entity_code
		, p_application_short_name	=> l_app_short_name
		, p_obj_defaulting_enabled	=> fkey_view.uk_obj_defaulting_enabled
		, p_generation_level	=> 'SPEC_ONLY'
		);
       g_PkgBdy_tbl(l_entity_id).package_spec := 'S';
       g_PkgBdy_tbl(l_entity_id).entity_id := l_entity_id;
       end if;


END IF;

END LOOP;


-------------------------------------------------------------------------------
-- (2) GENERATE THE BODY OF UTIL PACKAGES FOR RELATED ENTITITES
--     e.g. ONT_PRICE_LIST_DEF_UTIL
-------------------------------------------------------------------------------

FOR fkey_view in FKEY (p_database_object_name ,p_application_id )
LOOP

l_related_database_object_name := fkey_view.uk_database_object_name;
l_uk_name := fkey_view.unique_key_name;
l_fk_name := fkey_view.foreign_key_name;
l_related_entity_code := fkey_view.uk_entity_code;

-- This will never fetch null entity code because the oe_def_ak_fkeys_v
-- will fetch only the entities WHERE entity_code is not null.
l_related_pkg := l_app_short_name||'_'||l_related_entity_code||'_Def'||'_Util';

OPEN PKGSTATUS(l_related_pkg );
FETCH PKGSTATUS INTO l_status;

if PKGSTATUS%NOTFOUND then
 l_status := 'INVALID';
end if;
CLOSE PKGSTATUS;

-- For the related entities,
--  a) if p_generate_all= 'Y', generate util packages for all related entities
--  or b) if p_generate_all = 'N', then generate util package for related
--		entity only if the util package does not exist OR is invalid
IF l_status = 'INVALID'
 OR p_generate_all = 'Y'
THEN
        select entity_id into l_entity_id
        from oe_ak_objects_ext
        where DATABASE_OBJECT_NAME =l_related_database_object_name;

       PUT_LINE(
		'--------------------------------');
       PUT_LINE('entity id :'||l_entity_id);
       if g_PkgBdy_tbl.exists(l_entity_id) then
          PUT_LINE('cache exists');
          PUT_LINE('package spec :'||g_PkgBdy_tbl(l_entity_id).package_spec);
          PUT_LINE('package body :'||g_PkgBdy_tbl(l_entity_id).package_body);
       else
          PUT_LINE('cache does not exist');
       end if;

        if ( not g_PkgBdy_tbl.exists(l_entity_id) or nvl(g_PkgBdy_tbl(l_entity_id).package_body,'X') <>  'B')  then

	PUT_LINE(
		'Create caching/util package for related entity: '||l_related_entity_code);

	Create_Entity_Def_Util_handler
		( p_application_id		=>p_application_id
		, p_database_object_name	=> l_related_database_object_name
		, p_entity_code		=> l_related_entity_code
		, p_application_short_name	=> l_app_short_name
		, p_obj_defaulting_enabled	=> fkey_view.uk_obj_defaulting_enabled
		, p_generation_level	=> 'BODY_ONLY'
		);
        g_PkgBdy_tbl(l_entity_id).entity_id := l_entity_id;
        g_PkgBdy_tbl(l_entity_id).package_body := 'B';
        end if;
        -- populate cache

END IF;

END LOOP;


-------------------------------------------------------------------------------
-- (3) GENERATE THE SPEC AND BODY OF UTIL PACKAGE FOR CURRENT ENTITY
--     e.g. ONT_LINE_DEF_UTIL
--  Workaround for bug 1699929: For HEADER and LINE entities, generate the packages
--  after the attribute defaulting packages as Create_Obj_Attr_Def_handler
--  calls the entity util packages dynamically (OE_HEADER_UTIL and OE_LINE_UTIL)
--  dynamically to get the attribute constant values. And since these UTIL
--  packages call the def util package (ONT_LINE_DEF_UTIL etc.), they
--  are invalidated and dynamic calls fail with a coredump due to an RDBMS issue.
-------------------------------------------------------------------------------

  IF p_application_id <> 660
     OR l_entity_code NOT IN ('HEADER','LINE') THEN

        select entity_id into l_entity_id
        from oe_ak_objects_ext
        where DATABASE_OBJECT_NAME =p_database_object_name;

       PUT_LINE(
		'--------------------------------');
       PUT_LINE('entity id :'||l_entity_id);
       if g_PkgBdy_tbl.exists(l_entity_id) then
          PUT_LINE('cache exists');
          PUT_LINE('package spec :'||g_PkgBdy_tbl(l_entity_id).package_spec);
          PUT_LINE('package body :'||g_PkgBdy_tbl(l_entity_id).package_body);
       else
          PUT_LINE('cache does not exist');
       end if;

       if ( not g_PkgBdy_tbl.exists(l_entity_id) or nvl(g_PkgBdy_tbl(l_entity_id).package_body,'X') <>  'B'
             or nvl(g_PkgBdy_tbl(l_entity_id).package_spec,'X') <>  'S')  then

         PUT_LINE(
	'Create caching/util package for current entity '||l_entity_code);
        Create_Entity_Def_Util_handler
		(p_application_id
		,p_database_object_name
		,l_entity_code
		, l_app_short_name);
        g_PkgBdy_tbl(l_entity_id).entity_id := l_entity_id;
        g_PkgBdy_tbl(l_entity_id).package_spec := 'S';
        g_PkgBdy_tbl(l_entity_id).package_body := 'B';

       end if;

  END IF;

-------------------------------------------------------------------------------
-- (4) GENERATE THE ATTRIBUTE DEFAULTING PACKAGES e.g. ONT_D2_PAYMENT_TERM_ID
--	  As these packages contain calls to the util packages, these should be
--	  generated after the util package
-------------------------------------------------------------------------------

-- Loop to get all the attributes for the entity that are to be defaulted.
-- Get the name of the defaulting pkg name,validation pkg name AND
-- the dependent pkg name.


 j := 0;

 FOR obj_attr in OAORDER(p_database_object_name ,p_application_id )
 LOOP

   -- Retrieve all the values into a PL/SQL table
   l_obj_attr_tbl(j).column_name := obj_attr.column_name;
   l_obj_attr_tbl(j).attribute_code := obj_attr.attribute_code;
   l_obj_attr_tbl(j).data_type := obj_attr.data_type;
   l_obj_attr_tbl(j).defaulting_api_pkg := obj_attr.defaulting_api_pkg;
   l_obj_attr_tbl(j).defaulting_api_proc := obj_attr.defaulting_api_proc;
   l_obj_attr_tbl(j).validation_api_pkg := obj_attr.validation_api_pkg;
   l_obj_attr_tbl(j).validation_api_proc := obj_attr.validation_api_proc;
   l_obj_attr_tbl(j).dependent_api_pkg := obj_attr.dependent_api_pkg;
   l_obj_attr_tbl(j).dependent_api_proc := obj_attr.dependent_api_proc;
   l_obj_attr_tbl(j).security_api_pkg := obj_attr.security_api_pkg;
   l_obj_attr_tbl(j).security_api_proc := obj_attr.security_api_proc;
   l_obj_attr_tbl(j).defaulting_condn_ref_flag := obj_attr.defaulting_condn_ref_flag;
   l_obj_attr_tbl(j).defaulting_enabled_flag := obj_attr.defaulting_enabled_flag;

   -- For all the attributes that can be defaulted,
   --  a) if p_generate_all= 'Y', generate all attribute handlers
   --  or b) if p_generate_all = 'N', then generate attributes handlers only if
   --	there is NO defaulting API registered in the AK dictionary

   IF upper(obj_attr.defaulting_enabled_flag) = 'Y' THEN

	IF  (p_generate_all = 'Y')
	    OR (p_generate_all = 'N' AND
			( obj_attr.defaulting_api_pkg is null
			  OR obj_attr.defaulting_api_proc is null)
		   )
	THEN

     PUT_LINE(
		'------------------------------------------------------------------------------');
	PUT_LINE(
		'Create defaulting handler for attribute: '||obj_attr.attribute_code);
	Create_Obj_Attr_Def_handler
		   ( p_application_id => p_application_id,
 			p_database_object_name => p_database_object_name,
 			p_attribute_code => obj_attr.attribute_code,
			p_entity_code => l_entity_code,
 			x_defaulting_api_pkg => l_generated_pkg );
     PUT_LINE(
		'------------------------------------------------------------------------------');

   	l_obj_attr_tbl(j).defaulting_api_pkg := l_generated_pkg;
   	l_obj_attr_tbl(j).defaulting_api_proc := 'Get_Default_Value';

	END IF;

   END IF; -- if attribute is defaultable

   j := j + 1;

 END LOOP;

-------------------------------------------------------------------------------
--  Workaround for bug 1699929: For HEADER and LINE entities, generate the
--  entity def util packages after the attribute packages are generated
--  Generating BODY ONLY as specs are in the source area - OEXRHDRS.pls
--  , OEXRLINS.pls
------------------------------------------------------------------------------
  IF p_application_id = 660
	AND l_entity_code IN ('HEADER','LINE') THEN

        select entity_id into l_entity_id
        from oe_ak_objects_ext
        where DATABASE_OBJECT_NAME =p_database_object_name;

       PUT_LINE(
		'--------------------------------');
       PUT_LINE('entity id :'||l_entity_id);
       if g_PkgBdy_tbl.exists(l_entity_id) then
          PUT_LINE('cache exists');
          PUT_LINE('package spec :'||g_PkgBdy_tbl(l_entity_id).package_spec);
          PUT_LINE('package body :'||g_PkgBdy_tbl(l_entity_id).package_body);
       else
          PUT_LINE('cache does not exist');
       end if;

       if ( not g_PkgBdy_tbl.exists(l_entity_id) or nvl(g_PkgBdy_tbl(l_entity_id).package_body,'X') <>  'B') then
         PUT_LINE(
	'Create caching/util package for current entity '||l_entity_code);
        Create_Entity_Def_Util_Handler
          ( p_application_id       =>p_application_id
          , p_database_object_name => p_database_object_name
          , p_entity_code          => l_entity_code
          , p_application_short_name    => l_app_short_name
          , p_generation_level     => 'BODY_ONLY'
          );
        g_PkgBdy_tbl(l_entity_id).entity_id := l_entity_id;
        g_PkgBdy_tbl(l_entity_id).package_body := 'B';
       end if;

  END IF;

-------------------------------------------------------------------------------
-- (5) WRITING OUT THE BODY OF THE handler PACKAGE e.g ONT_LINE_DEF_HDLR
-------------------------------------------------------------------------------

  PUT_LINE(
		'------------------------------------------------------------------------------');
  PUT_LINE(
	'Create defaulting handler package for entity '||l_entity_code);

  Pkg_Header(p_pkg_name     =>  l_pkg_name,
			p_pkg_type	=>  'BODY');

  Text ('g_entity_code  varchar2(15) := '''||
			    l_entity_code||''';',1);

  Text ('g_database_object_name varchar2(30) :='''||p_database_object_name||''';',1);
  New_Line;

  --	Procedure to default record.
  Comment ('Default_Record',0);
  Text ('PROCEDURE Default_Record',0);
  Text ('(   p_x_rec                         IN OUT NOCOPY  '||
		p_database_object_name||'%ROWTYPE');
  IF l_entity_code IN ('HEADER', 'LINE') THEN
  Parameter('initial_rec   ','IN',
		 p_database_object_name||'%ROWTYPE ',0);
  END IF;
  Parameter('in_old_rec   ','IN',
		 p_database_object_name||'%ROWTYPE ',0);
  Parameter('iteration','IN','NUMBER default 1',0);
  Text (')',0);
  Text ('IS',0);
  Text ('l_action  NUMBER;',0);
  Text ('l_attr  VARCHAR2(200);',0);  --added for bug 4002431
  Text ('BEGIN',0);
  New_Line;
  Text ('oe_debug_pub.ADD(''Enter '||l_app_short_name||'_'||l_entity_code||
	'_Def_Hdlr.Default_Record'');',0);
  New_Line;
  Text('IF p_iteration =1 THEN',0);
  Text('OE_'||l_entity_code||'_Security.G_Is_Caller_Defaulting := ''Y'';',0);
  Assign ('g_record','p_x_rec',1,-1);
  Text('END IF;',0);
  New_Line;

  Comment ('if max. iteration is reached exit',0);
  Text ('IF p_iteration > ONT_DEF_UTIL.G_MAX_DEF_ITERATIONS THEN',0);
  Text ('FND_MESSAGE.SET_NAME('||''''||'ONT'||''''||','||''''||'OE_DEF_MAX_ITERATIONS'||''''||');',2);
  Text ('OE_MSG_PUB.ADD;',2);
  Text ('RAISE FND_API.G_EXC_ERROR;',2);
  Text ('END IF;',0);
  New_Line;

  --	Default missing attributes.
  Comment ('Default missing attributes',0);

  FOR J IN 0..l_obj_attr_tbl.COUNT -1  LOOP

  l_column_name := l_obj_attr_tbl(j).column_name ;
  l_attribute_code := l_obj_attr_tbl(j).attribute_code ;
  l_data_type := l_obj_attr_tbl(j).data_type ;
  l_defaulting_api_pkg := l_obj_attr_tbl(j).defaulting_api_pkg ;
  l_defaulting_api_proc := l_obj_attr_tbl(j).defaulting_api_proc ;
  l_validation_api_pkg := l_obj_attr_tbl(j).validation_api_pkg ;
  l_validation_api_proc := l_obj_attr_tbl(j).validation_api_proc ;
  l_dependent_api_pkg := l_obj_attr_tbl(j).dependent_api_pkg ;
  l_dependent_api_proc := l_obj_attr_tbl(j).dependent_api_proc ;
  l_security_api_pkg := l_obj_attr_tbl(j).security_api_pkg ;
  l_security_api_proc := l_obj_attr_tbl(j).security_api_proc ;
  l_defaulting_condn_ref_flag := l_obj_attr_tbl(j).defaulting_condn_ref_flag ;
  l_defaulting_enabled_flag := l_obj_attr_tbl(j).defaulting_enabled_flag ;
 Text ('l_attr:= '''||l_attribute_code||''';',0); --bug 4002431
    if substr(l_data_type,1,4) = 'DATE' then
	l_buffer := 'FND_API.G_MISS_DATE';
    elsif substr(l_data_type,1,3) = 'NUM'
        or substr(l_data_type,1,3) = 'INT' then
	l_buffer := 'FND_API.G_MISS_NUM';
    else
	l_buffer := 'FND_API.G_MISS_CHAR';
    end if;

  -- ATTRIBUTE IS NOT DEFAULTABLE, RETURN NULL IF ATTRIBUTE IS MISSING
  IF upper(l_defaulting_enabled_flag) <> 'Y' THEN

	New_Line;
	Text(
		'IF g_record.'||l_column_name||' = '||l_buffer||' THEN',0);
        Text('-- Attribute is NOT defaulting enabled, return NULL if MISSING',1);
	Text('g_record.'||l_column_name||' := NULL;',1);
	Text('END IF;',0);


  -- ATTRIBUTE IS DEFAULTABLE, GENERATE OR USE AK DEFAULT ATTRIBUTE handler
  ELSIF upper(l_defaulting_enabled_flag) = 'Y' THEN

	l_defaulting_api := l_defaulting_api_pkg||'.'||l_defaulting_api_proc;

     -- If there is no validation api registered in the AK make it NONE

    IF  (l_validation_api_pkg  is null) OR (l_validation_api_proc is null) THEN
	  l_validation_api := null;
    else
	  l_validation_api := l_validation_api_pkg||'.'||l_validation_api_proc;
    end if;

    -- If there is no dependent api registered in the AK make it NONE

    IF  (l_dependent_api_pkg is null ) OR (l_dependent_api_proc is null ) THEN
	  l_depend_api := null;
    else
	  l_depend_api := l_dependent_api_pkg||'.'||l_dependent_api_proc;
    end if;

    -- If there is no security api registered in the AK make it NONE

    IF  (l_security_api_pkg is null ) OR (l_security_api_proc is null ) THEN
	  l_security_api := null;
    else
	  l_security_api := l_security_api_pkg||'.'||l_security_api_proc;
    end if;

    -- Generate procedure code.
    New_Line;

    Text(
		'IF g_record.'||l_column_name||' = '||l_buffer||' THEN',0);
    Comment ('Get the defaulting api registered '||
		'in the AK AND default',0);

  Text ('l_attr:=l_attr||'' 1'';',2);
    Assign(
		'g_record.'||l_column_name,l_defaulting_api||'(g_record)',2,-1);
  Text ('l_attr:=l_attr||'' 2'';',2);
    -----------------------------------------------------------------------
    -- BEGIN Fix for bug 1343621
    -- if the new defaulted value is null, then retain the old value
    -- Initially, this will be implemented only for the following fields:
    -- Order Type, Salesperson, Price List, Customer PO
    --
    -- Fix Bug 1757278:
    -- Customer PO number column name corrected - it should be
    -- CUST_PO_NUMBER, not CUSTOMER_PO_NUMBER
    --
    -----------------------------------------------------------------------

    IF l_column_name IN ('ORDER_TYPE_ID','SALESREP_ID'
                        ,'PRICE_LIST_ID','CUST_PO_NUMBER'
                        ,'SOLD_TO_ORG_ID'
                        -- QUOTING change
                        ,'TRANSACTION_PHASE_CODE'
                        )
    THEN

      Text(
		'  IF g_record.'||l_column_name||' IS NULL ',0);
      Text(
		'   AND p_in_old_rec.'||l_column_name||' <> '||l_buffer||' THEN ',0);
      Text(
		'  g_record.'||l_column_name||' := p_in_old_rec.'||l_column_name||';',0);
      Text(
		'  END IF;',0);

    END IF;

    -----------------------------------------------------------------------
    -- END Fix for bug 1343621
    -----------------------------------------------------------------------

    -- If there is a security pkg registered for this attribute, then
    -- call security if the value on old record is different FROM the new
    -- defaulted value.
    if (l_security_api is not null) then
        Text (
        '-- For UPDATE operations, check security if new defaulted value is not equal to old value',1);
        Text ('IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN',1);
 	Text ('l_attr:=l_attr||'' 3'';',2);  --bug 4002431
        Text ('IF NOT OE_GLOBALS.Equal(g_record.'||
                lower(l_column_name)||', p_in_old_rec.'||
                lower(l_column_name)||') THEN',2);
        Text ('IF '||l_security_api||
                '(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN',3);
        Text (
        '-- Raise error if security returns YES, operation IS CONSTRAINED',3);
        Text('  RAISE FND_API.G_EXC_ERROR;',3);
        Text('END IF;',3);
        Text('OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := ''Y'';',3);
        Text('END IF;',2);
        Text('END IF;',1);
    else
        Text(
                '-- There is no security api registered in the AK dictionary  ',0);
    end if;

    -- if validation api is registered in AK, then validate value if not null
    if (l_validation_api is not null)
        -- QUOTING - bug identified during quote testing that clear dependents
        -- does not fire if validation api is not registered.
        or (l_depend_api is not null)
    then

        Text(
            'IF g_record.'||l_column_name||' IS NOT NULL THEN',1);
  	Text ('l_attr:=l_attr||'' 4'';',2);
        -- bug identified during quote testing
        if (l_validation_api is not null) then
          Text (
            '-- Validate defaulted value if not null',2);
          Text('IF '||l_validation_api
            ||'(g_record.'||l_column_name||') THEN  ',2);
        end if;
        if (l_depend_api is not null) then
          Text (
           '-- if valid, clear dependent attributes',3);
  		IF l_entity_code IN ('HEADER', 'LINE') THEN
          --Text(l_depend_api||'(g_record);',3);
          Text(l_depend_api||'(p_initial_rec, p_in_old_rec, g_record);',3);
		else
          Text(l_depend_api||'(g_record);',3);
		end if;
        else
          Text(
                '-- There is no dependent api registered in the AK dictionary  ',3);
          Text('NULL;',3);
  Text ('l_attr:=l_attr||'' 5'';',3); --bug 4002431
        end if;
        -- bug identified during quote testing
        if (l_validation_api is not null) then
          Text('ELSE',2);
          Text('g_record.'||l_column_name||' := NULL;',3);
          Text ('l_attr:=l_attr||'' 6'';',3);  --bug 4002431
          Text('END IF;',2);
        end if;
        Text('END IF;',1);
    else
        Text(
                '-- There is no validation api registered in the AK dictionary  ',3);
    end if;

    Text('END IF;',0);

  END IF; -- END OF CHECK TO SEE IF ATTRIBUTE IS DEFAULTING ENABLED

  END LOOP;


  -- Now loop through all the attributes to check if there are any missing values
  -- for the attributes. If there are any missing values that could be defaulted,
  -- call the Defaulting procedure repeatedly till the values are defaulted or
  -- till the maximum iteration is reached.

  New_Line;
  Comment ('CHeck if there are any missing values for attrs',2);
  Comment ('If there are any missing call Default_Record again '||
	'AND repeat till all the values ',2);
  Comment ('are defaulted or till the max. iterations are reached',2);

  New_Line;
  Text(' IF( ' ,2);

  FOR J IN 0..l_obj_attr_tbl.COUNT -1  LOOP

	l_data_type := l_obj_attr_tbl(j).data_type ;
	l_attribute_code := l_obj_attr_tbl(j).attribute_code ;
	l_column_name := l_obj_attr_tbl(j).column_name ;

    if substr(l_data_type,1,4) = 'DATE' then
	l_buffer := 'FND_API.G_MISS_DATE';
    elsif substr(l_data_type,1,3) = 'NUM'
     or substr(l_data_type,1,3) = 'INT' then
	l_buffer := 'FND_API.G_MISS_NUM';
    else
	l_buffer := 'FND_API.G_MISS_CHAR';
    end if;

    if j =0 then
 	  Text('  (g_record.'||l_column_name||' =' ||l_buffer||')  ',2);
    else
 	  Text(' OR (g_record.'||l_column_name||' = '||l_buffer||')  ',2);
    end if;

   END LOOP;

 	  Text(') THEN   ' ,2);
 	  Text(l_pkg_name||'.Default_Record(',2);
 	  Text(' p_x_rec => g_record,',2);
	  if l_entity_code in ('HEADER','LINE') then
	  Text(' p_initial_rec => p_initial_rec,',2);
	  end if;
 	  Text(' p_in_old_rec => p_in_old_rec,',2);
 	  Text('  p_iteration => p_iteration+1 );',2);
 	  Text('END IF;',2);
	New_Line;

     Text('IF p_iteration =1 THEN',0);
     Text('OE_'||l_entity_code||'_Security.'||
		'G_Is_Caller_Defaulting := ''N'';',0);
     Assign ('p_x_rec','g_record',1,-1);
     Text('END IF;',0);
	New_Line;

     Text ('oe_debug_pub.ADD(''Exit '||l_app_short_name||'_'||l_entity_code||
	'_Def_Hdlr.Default_Record'');',0);
	New_Line;

	Text('EXCEPTION',0);
	New_Line;
	Text('WHEN FND_API.G_EXC_ERROR THEN',1);
 	Text('OE_'||l_entity_code||'_Security.'||
		'G_Is_Caller_Defaulting := ''N'';',2);
	Text('RAISE FND_API.G_EXC_ERROR;',2);
	Text('WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN',1);
 	Text('OE_'||l_entity_code||'_Security.'||
		'G_Is_Caller_Defaulting := ''N'';',2);
	Text('RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',2);
	Text('WHEN OTHERS THEN',1);
	Text('IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)',2);
	Text('THEN',2);
	Text('OE_MSG_PUB.Add_Exc_Msg',3);
	Text('( G_PKG_NAME',3);
	--Text(',''Default_Record''',3);
	Text(',''Default_Record: ''||l_attr',3);  --bug 4002431
	Text(');',3);
	Text('END IF;',2);
 	  Text('OE_'||l_entity_code||'_Security.G_Is_Caller_Defaulting := ''N'';',2);
	Text('RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',2);
	New_Line;
 	  Text('END Default_Record;',0);
	New_Line;

  Pkg_End (l_pkg_name,'BODY');

  PUT_LINE(
		'------------------------------------------------------------------------------');

retcode := 0;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
	retcode := 2;
	errbuf := 'Please check the log file for error messages';

  WHEN OTHERS THEN
	PUT_LINE( 'Error in creating entity def hdlr '||sqlerrm);
	retcode := 2;
	errbuf := sqlerrm;

END Create_Entity_Def_handler;
-------------------------------------------------------------------------------


PROCEDURE Return_String(p_data_type	IN VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
       Text( 'if l_return_value is not null then ',2);
       if p_data_type='NUMBER' then
	   Text( ' RETURN to_number(l_return_value);',3);
       elsif p_data_type='DATE' then
	   Text( ' RETURN to_date(l_return_value,''RRRR/MM/DD HH24:MI:SS'');',3);
       else
 	   Text( ' RETURN (l_return_value);',3);
       end if;
       Text( 'end if; ',2);
       New_Line ;
END;

-- Procedure to create the object attribute handler
-- This procedure generates the attribute defaulting handler for the Rule based
-- Defaulting Framework.
-- This procedure will be called separately to generate a particular attribute
-- handler or it cwn be called by the entity handler to generate all the
-- attribute handlers for a particular entity.

PROCEDURE Create_Obj_Attr_Def_handler
( p_application_id      IN      VARCHAR2,
 p_database_object_name IN	VARCHAR2,
 p_attribute_code  	IN	VARCHAR2,
 p_entity_code          IN      VARCHAR2,
 p_generation_level     IN      VARCHAR2 DEFAULT 'FULL',
x_defaulting_api_pkg OUT NOCOPY VARCHAR2

)
IS

l_defaulting_api		VARCHAR2(61);
l_package				VARCHAR2(30);
l_function			VARCHAR2(30);
l_app_short_name		VARCHAR2(3);
l_attr_code			VARCHAR2(30);
l_data_type			VARCHAR2(30);
l_column_name			VARCHAR2(30);
l_seq_no				NUMBER(4);
l_attr_id				VARCHAR2(200);
l_sql_string			VARCHAR2(1000);
l_value				NUMBER;

-- CURSOR to get the name of the defaulting api pkgs.
CURSOR OA(p_database_object_name varchar2,p_application_id number,
	  p_attribute_code varchar2)
is
	SELECT DEFAULTING_API_PKG,
	DEFAULTING_API_PROC,NVL(DATA_TYPE,'CHAR'),
	COLUMN_NAME
	FROM OE_DEF_AK_ATTR_EXT_V
	WHERE DATABASE_OBJECT_NAME = p_database_object_name
	AND attribute_application_id = p_application_id
	AND attribute_code = p_attribute_code;
CURSOR APP is
	SELECT substr(rtrim(APPLICATION_SHORT_NAME),1,3)
	FROM fnd_application
	WHERE application_id = p_application_id;
CURSOR ENT_SEQ (p_entity_code varchar2)
 IS
	SELECT entity_id FROM OE_DEF_AK_OBJ_EXT_V
	WHERE entity_code = p_entity_code;

l_condition_id                          NUMBER;
l_attr_def_condn_id                     NUMBER;
l_elem_attribute_code         VARCHAR2(30);
l_value_op                              VARCHAR2(15);
l_value_string                VARCHAR2(255);
l_src_type                              VARCHAR2(30);
l_src_api_pkg                           VARCHAR2(30);
l_src_api_fn                            VARCHAR2(2000);
l_src_profile_option            VARCHAR2(30);
l_src_constant_value            VARCHAR2(240);
l_src_system_variable_expr      VARCHAR2(240);
l_group_number                NUMBER;
l_old_group_number            NUMBER;
l_src_database_object_name    VARCHAR2(240);
l_src_attribute_code          VARCHAR2(240);
l_src_column_name             VARCHAR2(30);
l_related_entity_code         VARCHAR2(30);
l_uk_attribute                VARCHAR2(30);
l_fk_attribute                VARCHAR2(30);
l_pk_attribute                VARCHAR2(30);  -- 2218044
l_src_data_type               VARCHAR2(30);  -- 3081991
l_count                       NUMBER;
l_rule_id                     NUMBER;

CURSOR C_CONDNS IS
        SELECT condition_id, attr_def_condition_id
        FROM OE_DEF_ATTR_CONDNS
        WHERE DATABASE_OBJECT_NAME = p_database_object_name
          AND ATTRIBUTE_CODE = p_attribute_code
          AND ENABLED_FLAG = 'Y'
        ORDER BY PRECEDENCE;

CURSOR C_CONDN_ELEMS IS
     SELECT group_number, attribute_code, value_op, value_string
        FROM OE_DEF_CONDN_ELEMS
        WHERE CONDITION_ID = l_condition_id
        ORDER BY GROUP_NUMBER;

CURSOR C_DEF_RULES IS
     SELECT attr_def_rule_id
                  ,src_type
                  ,src_api_pkg
                  ,src_api_fn
                  ,src_profile_option
                  ,src_constant_value
                  ,src_system_variable_expr
                  ,src_database_object_name
                  ,src_attribute_code
     FROM OE_DEF_ATTR_DEF_RULES
        WHERE ATTR_DEF_CONDITION_ID = l_attr_def_condn_id
        ORDER BY SEQUENCE_NO;

CURSOR C_UK_COLS IS
        SELECT ua.column_name, fa.column_name
        FROM AK_UNIQUE_KEYS uk, AK_UNIQUE_KEY_COLUMNS uc
            , AK_FOREIGN_KEYS fk,  AK_FOREIGN_KEY_COLUMNS fc
            , AK_OBJECT_ATTRIBUTES ua, AK_OBJECT_ATTRIBUTES fa
     WHERE uk.database_object_name = l_src_database_object_name
          AND uk.unique_key_name = uc.unique_key_name
          AND fk.database_object_name = p_database_object_name
          AND fk.unique_key_name = uk.unique_key_name
          AND fc.foreign_key_name = fk.foreign_key_name
          AND uc.unique_key_sequence = fc.foreign_key_sequence
          AND ua.database_object_name = l_src_database_object_name
          AND ua.attribute_code = uc.attribute_code
          AND fa.database_object_name = p_database_object_name
          AND fa.attribute_code = fc.attribute_code
        ORDER BY uc.unique_key_sequence;

CURSOR C_PK_COLS IS  -- 2218044
        SELECT ua.column_name
        FROM AK_UNIQUE_KEYS uk,
             AK_UNIQUE_KEY_COLUMNS uc,
             AK_OBJECT_ATTRIBUTES ua
        WHERE uk.database_object_name = p_database_object_name
          AND ua.database_object_name = p_database_object_name
          AND uk.unique_key_name = uc.unique_key_name
          AND uc.attribute_code = ua.attribute_code
          AND uc.attribute_application_id = ua.attribute_application_id
          AND ua.database_object_name = p_database_object_name
        ORDER BY uc.unique_key_sequence;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  Init_Applsys_Schema;

  open APP;
  fetch APP into l_app_short_name;
  close APP;

  open ENT_SEQ (p_entity_code);
  fetch ENT_SEQ into l_seq_no;
  close ENT_SEQ;

  open OA(p_database_object_name ,p_application_id , p_attribute_code );
  fetch OA into l_package,l_function,l_data_type,l_column_name;

  if OA%notfound
  or l_package is null then
  	-- l_attr_code may not exceed 20 characters.
  	l_attr_code := substr(p_attribute_code,1,20);
 	if substr(l_attr_code,length(l_attr_code)) = '_' then
    		l_attr_code := substr(l_attr_code,1,length(l_attr_code) -1);
  	end if;
  	l_package := l_app_short_name||'_D'||l_seq_no||'_'||l_attr_code;
  	l_function :='Get_Default_Value';
  end if;

  close OA;

  l_defaulting_api := l_package||'.'||l_function;
  x_defaulting_api_pkg := l_package;


  ----------------------------------------------------------------------------
  -- WRITING OUT THE SPEC
  ----------------------------------------------------------------------------

   if p_generation_level = 'BODY_ONLY' then
	goto START_OF_BODY;
   end if;

   Pkg_Header( p_pkg_name     =>  l_package,
               p_pkg_type     =>  'SPEC');

   Text('FUNCTION Get_Default_Value(p_'||LOWER(p_entity_code)||'_rec IN '
         || p_database_object_name||' %ROWTYPE ',1);
   Text(') RETURN '|| l_data_type||';',1);
   New_Line ;

   Pkg_End (l_package,'SPEC');


   <<START_OF_BODY>>
   ---------------------------------------------------------------------------
   -- WRITING OUT THE BODY
   ---------------------------------------------------------------------------

   if p_generation_level = 'SPEC_ONLY' then
	RETURN;
   end if;

   Pkg_Header( p_pkg_name    =>  l_package,
               p_pkg_type    =>  'BODY');

   -- Function Get_Default_Value
   New_Line ;
   Text('FUNCTION Get_Default_Value(p_'||LOWER(p_entity_code)||'_rec IN  '
         || p_database_object_name||'%ROWTYPE ',0);
   Text(') RETURN '|| l_data_type||' IS ', 1);
   IF l_data_type = 'DATE' THEN
     Text('l_return_value     DATE;',1);
   ELSE
     Text('l_return_value    VARCHAR2(2000);',1);
   END IF;
   Text('l_rule_id         NUMBER;',1);
   Text('BEGIN',0);
   New_Line;

   -- Added 09-DEC-2002
   -- Supress defaulting of blanket number for items that are not of type
   -- 'STANDARD' or 'KIT'
   IF p_attribute_code = 'BLANKET_NUMBER'
      AND p_database_object_name = 'OE_AK_ORDER_LINES_V'
   THEN
      Text('IF p_line_rec.item_type_code NOT IN (''STANDARD'',''KIT'') THEN',2);
      Text('   RETURN NULL;',2);
      Text('END IF;',2);
   END IF;


   -- BEGIN LOOP TO CONSTRUCT PL/SQL LOGIC FOR DEFAULTING CONDITIONS

   OPEN C_CONDNS;
   LOOP
   FETCH C_CONDNS INTO l_condition_id, l_attr_def_condn_id;
   EXIT WHEN (C_CONDNS%NOTFOUND);

   IF l_condition_id = 0 THEN
	GOTO ADD_RULES;
   END IF;

   l_old_group_number := -1;
   OPEN C_CONDN_ELEMS;
   LOOP
   FETCH C_CONDN_ELEMS INTO l_group_number, l_elem_attribute_code
                            , l_value_op, l_value_string;
   EXIT WHEN (C_CONDN_ELEMS%NOTFOUND);

    /* =========== Code appended for the bug 3081991 =========== */

   select ada.data_type
     into l_src_data_type
     from OE_DEF_AK_ATTR_EXT_V ada
    where ada.DATABASE_OBJECT_NAME = p_database_object_name
      and ada.ATTRIBUTE_APPLICATION_ID = p_application_id
      and ada.ATTRIBUTE_CODE = l_elem_attribute_code;

   IF l_src_data_type = 'DATE' THEN
      l_value_string := ('TO_DATE('''||l_value_string||''', '||'''RRRR/MM/DD HH24:MI:SS'''||')');
   END IF;

   IF l_old_group_number <> l_group_number THEN
   -- Construct an OR condition if group number changes
     IF l_old_group_number = -1 THEN
        IF l_src_data_type = 'DATE' THEN
           Text('IF (p_'||LOWER(p_entity_code)||'_rec.'||l_elem_attribute_code||' '||l_value_op||' '||l_value_string||'',2);
        ELSE
           Text('IF (p_'||LOWER(p_entity_code)||'_rec.'||l_elem_attribute_code||' '||l_value_op||' '''||l_value_string||'''',2);
        END IF;
     ELSE
        IF l_src_data_type = 'DATE' THEN
           Text('    )',2);
           Text('OR (p_'||LOWER(p_entity_code)||'_rec.'||l_elem_attribute_code||' '||l_value_op||' '||l_value_string||'',2);
        ELSE
           Text('    )',2);
           Text('OR (p_'||LOWER(p_entity_code)||'_rec.'||l_elem_attribute_code||' '||l_value_op||' '''||l_value_string||'''',2);
        END IF;
     END IF;
   ELSE
   -- Construct an AND condition if group number is same
     IF l_src_data_type = 'DATE' THEN
        Text('    AND p_'||LOWER(p_entity_code)||'_rec.'||l_elem_attribute_code||' '||l_value_op||' '||l_value_string||'',2);
     ELSE
        Text('    AND p_'||LOWER(p_entity_code)||'_rec.'||l_elem_attribute_code||' '||l_value_op||' '''||l_value_string||'''',2);
     END IF;
   END IF;

    /* =========== Appended till here =========== */

   l_old_group_number := l_group_number;

   END LOOP;
   CLOSE C_CONDN_ELEMS;
   Text('    ) THEN',2);

   -- BEGIN LOOP TO CONSTRUCT PL/SQL LOGIC FOR RULES

   <<ADD_RULES>>
   OPEN C_DEF_RULES;
   LOOP
   FETCH C_DEF_RULES INTO l_rule_id
                          , l_src_type
                          , l_src_api_pkg
                          , l_src_api_fn
                          , l_src_profile_option
                          , l_src_constant_value
                          , l_src_system_variable_expr
                          , l_src_database_object_name
                          , l_src_attribute_code;
   EXIT WHEN (C_DEF_RULES%NOTFOUND);

   Text('l_rule_id := '||l_rule_id||';',2);
   IF l_src_type = 'RELATED_RECORD' THEN

      SELECT upper(entity_code)
      INTO l_related_entity_code
      FROM OE_AK_OBJECTS_EXT
      WHERE DATABASE_OBJECT_NAME = l_src_database_object_name;

      SELECT column_name
      INTO l_src_column_name
      FROM AK_OBJECT_ATTRIBUTES
      WHERE DATABASE_OBJECT_NAME = l_src_database_object_name
        AND ATTRIBUTE_CODE = l_src_attribute_code;

      Text('IF '||l_app_short_name||'_'||l_related_entity_code
           ||'_Def_Util.Sync_'||l_related_entity_code||'_Cache',2);

      l_count := 1;
      OPEN C_UK_COLS;
      LOOP
      FETCH C_UK_COLS INTO l_uk_attribute, l_fk_attribute;
      EXIT WHEN (C_UK_COLS%NOTFOUND);
      IF l_count = 1 THEN
        Text('(p_'||l_uk_attribute||' => p_'||LOWER(p_entity_code)||'_rec.'
               ||l_fk_attribute,2);
      ELSE
        -- ER: 1840556
        IF l_src_database_object_name = 'OE_AK_INVENTORY_ITEMS_V'
           AND l_fk_attribute = 'SHIP_FROM_ORG_ID'
        THEN
           -- Bug 2422910: Item Validation Org System Parameter should be
           -- be passed to the item caching API if ship from is null
           -- OR missing on the line.
           Text(',p_'||l_uk_attribute||' => REPLACE(nvl(p_'||LOWER(p_entity_code)||'_rec.'
              ||l_fk_attribute||',FND_API.G_MISS_NUM),FND_API.G_MISS_NUM,OE_SYS_Parameters.Value(''MASTER_ORGANIZATION_ID''))',2);
        ELSE
           Text(',p_'||l_uk_attribute||' => p_'||LOWER(p_entity_code)||'_rec.'
              ||l_fk_attribute,2);
        END IF;
      END IF;
      l_count := 2;
      END LOOP;
      Text(') = 1 THEN',2);
      CLOSE C_UK_COLS;

      Text('l_return_value := '||l_app_short_name||'_'||l_related_entity_code
		   ||'_Def_Util.g_cached_record.'||l_src_column_name||';',2);

      Text('END IF;',2);

   ELSIF l_src_type = 'SAME_RECORD' THEN

      SELECT column_name
      INTO l_src_column_name
      FROM AK_OBJECT_ATTRIBUTES
      WHERE DATABASE_OBJECT_NAME = p_database_object_name
        AND ATTRIBUTE_CODE = l_src_attribute_code;

      Text('l_return_value := p_'||LOWER(p_entity_code)||'_rec.'||l_src_column_name||';',2);

      IF l_src_attribute_code = p_attribute_code  THEN  -- 2218044
         Text('IF '||l_app_short_name||'_'||p_entity_code
               ||'_Def_Util.Sync_'||p_entity_code||'_Cache',2);

         l_count := 1;
         OPEN C_PK_COLS;
         LOOP
         FETCH C_PK_COLS INTO l_pk_attribute;
         EXIT WHEN (C_PK_COLS%NOTFOUND);
         IF l_count = 1 THEN
           Text('(p_'||l_pk_attribute||' => p_'||LOWER(p_entity_code)||'_rec.'
           ||l_pk_attribute,2);
         ELSE
            Text(',p_'||l_pk_attribute||' => p_'||LOWER(p_entity_code)||'_rec.'
                  ||l_pk_attribute,2);
         END IF;
         l_count := 2;
         END LOOP;
         Text(') = 1 THEN',2);
         CLOSE C_PK_COLS;

         Text('l_return_value := '||l_app_short_name||'_'||p_entity_code
                   ||'_Def_Util.g_cached_record.'||l_src_column_name||';',3);
         Text('ELSE', 2);
         Text('l_return_value := NULL;', 3);
         Text('END IF;',2);
      END IF;  -- 2218044

   ELSIF l_src_type = 'CONSTANT' OR l_src_type = p_attribute_code THEN
      IF l_data_type = 'DATE' THEN -- 2358338
         Text('l_return_value := TO_DATE('''||REPLACE(l_src_constant_value, '''', '''''')||''', ''RRRR/MM/DD HH24:MI:SS'');',2);  -- 2222482
      ELSE
         -- 5529963 : 4 = space length => 2*level 2
          IF ( (4 + length('l_return_value := '''||REPLACE(l_src_constant_value, '''', '''''')||''';') ) <=
g_max_line_size  ) THEN
            Text('l_return_value := '''||REPLACE(l_src_constant_value, '''', '''''')||''';',2);  -- 2222482
          ELSE
            Text('l_return_value := ', 2);
            Text(''''||REPLACE(l_src_constant_value, '''', '''''')||''';', 2);
          END IF;
      END IF; -- 2358338
   ELSIF l_src_type = 'SYSTEM' THEN

      IF l_data_type = 'DATE' THEN
         Text( 'l_return_value := '||l_app_short_name||
                '_Def_Util.Get_Expression_Value_Date',2);
         Text( ' (p_expression_string => '''||REPLACE(l_src_system_variable_expr, '''', '''''')||''');',3);  -- 2222482
      ELSE
         Text( 'l_return_value := '||l_app_short_name||
               '_Def_Util.Get_Expression_Value_Varchar2',2);
         Text( ' (p_expression_string => '''||REPLACE(l_src_system_variable_expr, '''', '''''')||''');',3);  -- 2222482
      END IF;

   ELSIF l_src_type = 'PROFILE_OPTION' THEN

      -- Fix bug 1756855: Convert from canonical to number format for
      -- defaults of number fields from profile options
      IF l_data_type = 'NUMBER' THEN
         Text( 'l_return_value := fnd_number.canonical_to_number',2);
         Text( '(FND_PROFILE.VALUE('''||l_src_profile_option||''')); ',3);
      ELSE
         Text('l_return_value := FND_PROFILE.VALUE('''||
			   l_src_profile_option||''');',2);
      END IF;

   ELSIF l_src_type = 'API' THEN

      IF l_src_database_object_name IS NULL THEN
	 l_src_database_object_name := 'null';
      ELSE
	 l_src_database_object_name := ''''||l_src_database_object_name||'''';
      END IF;

      IF l_src_attribute_code IS NULL THEN
         l_src_attribute_code := 'null';
      ELSE
         l_src_attribute_code := ''''||l_src_attribute_code||'''';
      END IF;

      Text('l_return_value := '||l_src_api_pkg||'.'||l_src_api_fn,2);
      Text('                   (p_database_object_name => '||l_src_database_object_name,2);
      Text('                   ,p_attribute_code => '||l_src_attribute_code||');',2);

   ELSIF l_src_type = 'WAD_ATTR' THEN

      Text( 'l_return_value := '||l_app_short_name||'_Def_Util.Get_Attr_Default_Varchar2',
2);
      Text( '(p_attribute_code => g_attribute_code,',3);
      Text( ' p_application_id => g_application_id);',3);

   ELSIF l_src_type = 'WAD_OBJATTR' THEN

      Text( 'l_return_value := '||l_app_short_name||'_Def_Util.Get_ObjAttr_Default_Varchar
2',2);
      Text( '(p_attribute_code => g_attribute_code,',3);
      Text( ' p_database_object_name => g_database_object_name,',3);
      Text( ' p_application_id => g_application_id);',3);

   END IF;

   Text('IF l_return_value IS NOT NULL THEN',2);
   Text('   GOTO RETURN_VALUE;',2);
   Text('END IF;',1); -- End if l_return_value is not null

   END LOOP;
   IF C_DEF_RULES%ROWCOUNT = 0 THEN  -- 2216700: If no rules are defined for this def. condition
      Text('NULL;', 2);
   END IF;
   CLOSE C_DEF_RULES;

   IF l_condition_id <> 0 THEN
      Text('END IF;',1); -- End if for the condition elements logic
   END IF;
   New_Line;

   END LOOP;
   CLOSE C_CONDNS;
   Text('<<RETURN_VALUE>>');
   Text('RETURN l_return_value;',1);
   New_Line;

   Text('EXCEPTION',0);
   Text('WHEN OTHERS THEN',0);
   Text('         ONT_Def_Util.Add_Invalid_Rule_Message',0);
   Text('         ( p_attribute_code => '''||p_attribute_code||'''',0);
   Text('         , p_rule_id => l_rule_id',0);
   Text('         );',0);
   Text('         RETURN NULL;',0);
   Text('END Get_Default_Value;',0);

   Pkg_End(l_package,'BODY');

EXCEPTION
   WHEN OTHERS THEN
	PUT_LINE('Error :'||substr(sqlerrm,1,200));
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Obj_Attr_Def_handler;

-- Procedure to create the object attribute handler
-- This procedure generates the attribute defaulting handler for the Rule based
-- Defaulting Framework.
-- This procedure will be called separately to generate a particular attribute
-- handler or it cwn be called by the entity handler to generate all the
-- attribute handlers for a particular entity.

PROCEDURE Create_Obj_Attr_Def_handler
( p_application_id        IN    VARCHAR2,
 p_database_object_name  IN	VARCHAR2,
 p_attribute_code  	IN	VARCHAR2 ,
 p_entity_code          IN      VARCHAR2,
x_defaulting_api_pkg OUT NOCOPY VARCHAR2

)
IS
l_defaulting_api		VARCHAR2(61);
l_package				VARCHAR2(30);
l_function			VARCHAR2(30);
l_app_short_name		VARCHAR2(3);
l_attr_code			VARCHAR2(30);
l_data_type			VARCHAR2(30);
l_column_name			VARCHAR2(30);
l_seq_no				NUMBER(4);
l_attr_id				VARCHAR2(200);
l_sql_string			VARCHAR2(1000);
l_value				NUMBER;
-- CURSOR to get the name of the defaulting api pkgs.
CURSOR OA(p_database_object_name varchar2,p_application_id number,
	  p_attribute_code varchar2)
is
	SELECT DEFAULTING_API_PKG,
	DEFAULTING_API_PROC,NVL(DATA_TYPE,'CHAR'),
	COLUMN_NAME
	FROM OE_DEF_AK_ATTR_EXT_V
	WHERE DATABASE_OBJECT_NAME = p_database_object_name
	AND attribute_application_id = p_application_id
	AND attribute_code = p_attribute_code;
CURSOR APP is
	SELECT substr(rtrim(APPLICATION_SHORT_NAME),1,3)
	FROM fnd_application
	WHERE application_id = p_application_id;
CURSOR ENT_SEQ (p_entity_code varchar2)
 IS
	SELECT entity_id FROM OE_DEF_AK_OBJ_EXT_V
	WHERE entity_code = p_entity_code;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

  Init_Applsys_Schema;

  open APP;
  fetch APP into l_app_short_name;
  close APP;

  open ENT_SEQ (p_entity_code);
  fetch ENT_SEQ into l_seq_no;
  close ENT_SEQ;

  open OA(p_database_object_name ,p_application_id , p_attribute_code );
  fetch OA into l_package,l_function,l_data_type,l_column_name;

   if OA%notfound
   or l_package is null then
  	-- l_attr_code may not exceed 20 characters.
  	l_attr_code := substr(p_attribute_code,1,20);
 	if substr(l_attr_code,length(l_attr_code)) = '_' then
    		l_attr_code := substr(l_attr_code,1,length(l_attr_code) -1);
  	end if;
  	l_package := l_app_short_name||'_D'||l_seq_no||'_'||l_attr_code;
	/*
	if length(l_package) > 30 then
	 l_package := substr(l_package,1,30);
	 if substr(l_package,length(l_package)) = '_' then
	    l_package := substr(l_package,1,length(l_package) -1);
	 end if;
	end if;
	*/
  	l_function :='Get_Default_Value';
   end if;

  close OA;


  l_defaulting_api := l_package||'.'||l_function;

  x_defaulting_api_pkg := l_package;

--  generate the attribute id string
--  (ASSUMPTION: for each attribute, there is a unique constant defined in the
--  entity's util package. For e.g. for the attribute accounting_rule_id
--  on the entity LINE, the constant would be OE_LINE_UTIL.G_ACCOUNTING_RULE)

     IF l_column_name like '%_ID' THEN
     l_attr_id := 'OE_'||upper(p_entity_code)||'_UTIL.G_'||substr(l_column_name,1,length(l_column_name)-3);
     -- OPTION is a restricted word hence retain OPTION_FLAG
     -- to construct the attribute id string
     ELSIF (( l_column_name like '%_CODE' OR l_column_name like '%_FLAG')
          AND l_column_name <> 'OPTION_FLAG')THEN
     l_attr_id := 'OE_'||upper(p_entity_code)||'_UTIL.G_'||substr(l_column_name,1,length(l_column_name)-5);
     ELSE
     l_attr_id := 'OE_'||upper(p_entity_code)||'_UTIL.G_'||l_column_name;
     END IF;

     l_sql_string :=
  	  'declare '||
          'begin '||
	  ':l_value := '||l_attr_id||'; end;' ;

     BEGIN
     PUT_LINE( 'Using constant '||l_attr_id);
     EXECUTE IMMEDIATE
          'declare '||
          'begin '||
          ':l_value := '||l_attr_id||'; end;'
          USING OUT l_value;

     EXCEPTION
     WHEN OTHERS THEN
	 BEGIN
	 l_attr_id := 'OE_'||upper(p_entity_code)||'_UTIL.G_'||l_column_name;
         PUT_LINE( 'Prev. constant not valid. Using constant '||l_attr_id);
         EXECUTE IMMEDIATE
            'declare '||
            'begin '||
            ':l_value := '||l_attr_id||'; end;'
         USING OUT l_value;

	 EXCEPTION
	 WHEN OTHERS THEN
          PUT_LINE( 'ERROR: Not a Valid Constant; '||sqlerrm);
	  RAISE FND_API.G_EXC_ERROR;
	 END;
     END;


-------------------------------------------------------------------------------
-- WRITING OUT THE SPEC
-------------------------------------------------------------------------------

   Pkg_Header( p_pkg_name     =>  l_package,
			p_pkg_type	=>  'SPEC');

-- Global Declarations section of the SPEC file
   Text('g_database_object_name varchar2(30) :='''||p_database_object_name||''';',1);
   Text('g_attribute_code varchar2(30) :='''||p_attribute_code||''';',1);
   Text('g_column_name varchar2(30) :='''||l_column_name||''';',1);
   Text('g_application_id NUMBER :='||p_application_id||';',1);
   New_Line ;

-- Function Get_Default_Value
   Text('FUNCTION Get_Default_Value(p_'||LOWER(p_entity_code)||'_rec IN  '|| p_database_object_name||' %ROWTYPE ',1);
   Text(') RETURN '|| l_data_type||';',1);
   New_Line ;

   Pkg_End (l_package,'SPEC');


-------------------------------------------------------------------------------
-- WRITING OUT THE BODY
-------------------------------------------------------------------------------

--  Write out header section of the Package BODY

   Pkg_Header( p_pkg_name     =>  l_package,
			p_pkg_type	=>  'BODY');

-- Function Get_Default_Value
   New_Line ;
   Text('FUNCTION Get_Default_Value(p_'||LOWER(p_entity_code)||'_rec IN  '
		|| p_database_object_name||'%ROWTYPE ',0);
   Text(') RETURN '|| l_data_type||' IS ', 1);

   -- Declarations
   Text('l_return_value    VARCHAR2(2000);',1);
   IF l_data_type = 'DATE' THEN
	    Text('l_return_date     DATE;',1);
   END IF;
   Text('l_src_type			VARCHAR2(30);',1);
   Text('l_index			NUMBER;',1);
   Text('l_start_index_tbl	OE_GLOBALS.NUMBER_TBL_Type;',1);
   Text('l_stop_index_tbl	OE_GLOBALS.NUMBER_TBL_Type;',1);
   Text('l_rule_rec			ONT_Def_Util.Attr_Def_Rule_REC_Type;',1);

   Text('BEGIN',0);
   New_Line ;

   -- THe function that is generated is "Get_Valid_Defaulting_Rules".
   -- This function determines the valid defaulting condition based on the
   -- sequence that is determined when the conditions are initially set-up
   Comment ('Get the rules associated with valid defaulting conditions',0);
   Text(l_app_short_name||'_'||p_entity_code||'_Def_Util'||'.Get_Valid_Defaulting_Rules',0);
   Text('(p_attr_code 		=> g_attribute_code,',1);
   Text(' p_attr_id => '||l_attr_id||',',1);
   Text(' p_'||LOWER(p_entity_code)||'_rec => p_'||LOWER(p_entity_code)||'_rec,',1);
   Text(' x_rules_start_index_tbl	=> l_start_index_tbl,',1);
   Text(' x_rules_stop_index_tbl	=> l_stop_index_tbl);',1);
   New_Line ;


   -- GET THE DEFAULT SOURCES
   Text('FOR I IN 1..l_start_index_tbl.COUNT LOOP ',0);
   New_Line ;
   Text('IF l_start_index_tbl(I) <> -1 THEN',0);
   New_Line ;
   Text(' FOR l_index IN l_start_index_tbl(I)..l_stop_index_tbl(I) LOOP ',0);
   New_Line ;
   Text(' l_rule_rec := '||l_app_short_name||'_'||p_entity_code||'_Def_Util.g_attr_rules_cache(l_index);',1);
   Text(' l_src_type := l_rule_rec.SRC_TYPE;',1);
   New_Line ;
   Text(' BEGIN',0);
   New_Line ;

       -- IF DEFAULT SOURCE IS RELATED RECORD

       Text( 'IF l_src_type = ''RELATED_RECORD'' THEN  ',1);
       New_Line ;
	  IF l_data_type = 'DATE' THEN
         Text( 'l_return_date := '||l_app_short_name||'_'||p_entity_code||
				'_Def_Util.Get_Foreign_Attr_Val_Date',2);
         Text( '(p_foreign_attr_code => l_rule_rec.src_attribute_code,',3);
         Text( ' p_record => p_'||LOWER(p_entity_code)||'_rec,',3);
         Text( ' p_foreign_database_object_name => l_rule_rec.src_database_object_name);',3);
	    Text(' if l_return_date is not null then',3);
	    Text('  RETURN l_return_date;',3);
	    Text(' end if;',3);
	    New_Line;
	  ELSE
         Text( 'l_return_value := '||l_app_short_name||'_'||p_entity_code||
				'_Def_Util.Get_Foreign_Attr_Val_Varchar2',2);
         Text( '(p_foreign_attr_code => l_rule_rec.src_attribute_code,',3);
         Text( ' p_record => p_'||LOWER(p_entity_code)||'_rec,',3);
         Text( ' p_foreign_database_object_name => l_rule_rec.src_database_object_name);',3);
	    Return_String(l_data_type);
	  END IF;

       -- IF DEFAULT SOURCE IS SAME RECORD

       Text( 'ELSIF l_src_type = ''SAME_RECORD'' THEN  ',1);
       New_Line ;
	  IF l_data_type = 'DATE' THEN
         Text( 'l_return_date := '||l_app_short_name||'_'||LOWER(p_entity_code)
				||'_Def_Util.Get_Attr_Val_Date',2);
         Text( '(p_attr_code => l_rule_rec.src_attribute_code,',3);
         Text( ' p_record=> p_'||LOWER(p_entity_code)||'_rec);',3);
	    Text(' if l_return_date is not null then',3);
	    Text('  RETURN l_return_date;',3);
	    Text(' end if;',3);
	    New_Line;
	  ELSE
         Text( 'l_return_value := '||l_app_short_name||'_'||LOWER(p_entity_code)
                    ||'_Def_Util.Get_Attr_Val_Varchar2',2);
         Text( '(p_attr_code => l_rule_rec.src_attribute_code,',3);
         Text( ' p_record=> p_'||LOWER(p_entity_code)||'_rec);',3);
         Return_String(l_data_type);
       END IF;

       -- IF DEFAULT SOURCE IS CONSTANT VALUE

       Text( 'ELSIF l_src_type = ''CONSTANT'' OR',1);
       Text( '	   l_src_type = '''||p_attribute_code||''' THEN',1);
       New_Line ;
       Text( 'l_return_value := l_rule_rec.src_constant_value;',2);
	  Return_String(l_data_type);

       -- IF DEFAULT SOURCE IS SYSTEM EXPRESSION

       Text( 'ELSIF l_src_type = ''SYSTEM'' THEN  ',1);
	  New_Line;
       IF l_data_type = 'DATE' THEN
        Text( 'l_return_date := '||l_app_short_name||
	            '_Def_Util.Get_Expression_Value_Date',2);
	   Text( ' (p_expression_string => l_rule_rec.src_system_variable_expr);',3);
	   Text( ' if l_return_date is not null then ',2);
        Text( ' RETURN l_return_date;',3);
	   Text( ' end if; ',2);
	   New_Line;
       ELSE
	   Text( 'l_return_value := '||l_app_short_name||
			'_Def_Util.Get_Expression_Value_Varchar2',2);
	   Text( ' (p_expression_string =>l_rule_rec.src_system_variable_expr);',3);
	   Return_String(l_data_type);
	  END IF;

       -- IF DEFAULT SOURCE IS PROFILE OPTION

       Text( 'ELSIF l_src_type = ''PROFILE_OPTION'' THEN  ',1);
       New_Line ;
       Text( 'l_return_value := FND_PROFILE.VALUE',2);
       Text( '(l_rule_rec.SRC_PROFILE_OPTION); ',3);
	  Return_String(l_data_type);

       -- IF DEFAULT SOURCE IS PL/SQL API

       Text(' ELSIF l_src_type = ''API'' THEN ',1);
       New_Line ;
       IF l_data_type = 'DATE' THEN
        Text( 'l_return_date := '||l_app_short_name||'_Def_Util.Get_API_Value_Date',2);
	  ELSE
        Text( 'l_return_value := '||l_app_short_name||'_Def_Util.Get_API_Value_Varchar2',2);
	  END IF;
       Text( '(p_api_name => l_rule_rec.SRC_API_NAME,',3);
       Text( ' p_database_object_name => l_rule_rec.SRC_DATABASE_OBJECT_NAME,',3);
       Text( ' p_attribute_code => l_rule_rec.src_ATTRIBUTE_CODE);',3);
	  IF l_data_type = 'DATE' THEN
	   Text( ' if l_return_date is not null then ',2);
        Text( ' RETURN l_return_date;',3);
	   Text( ' end if; ',2);
	   New_Line;
       ELSE
	   Return_String(l_data_type);
       END IF;

       -- IF DEFAULT SOURCE IS WAD-ATTRIBUTE DEFAULT

       Text( 'ELSIF l_src_type = ''WAD_ATTR'' THEN  ',1);
       New_Line ;
       Text( 'l_return_value := '||l_app_short_name||'_Def_Util.Get_Attr_Default_Varchar2',2);
       Text( '(p_attribute_code => g_attribute_code,',3);
       Text( ' p_application_id => g_application_id);',3);
	  Return_String(l_data_type);

       -- IF DEFAULT SOURCE IS WAD-OBJECT ATTRIBUTE DEFAULT

       Text( 'ELSIF l_src_type = ''WAD_OBJATTR'' THEN  ',1);
       New_Line ;
       Text( 'l_return_value := '||l_app_short_name||'_Def_Util.Get_ObjAttr_Default_Varchar2',2);
       Text( '(p_attribute_code => g_attribute_code,',3);
       Text( ' p_database_object_name => g_database_object_name,',3);
       Text( ' p_application_id => g_application_id);',3);
	  Return_String(l_data_type);

       /* SEQUENCE values, DATABASE default, Form PARAMETER are not supported
       default sources for initial R11.5.1

       -- if the default source  type is a sequence then invoke
       -- the function OE_Def_Util.Get_Sequence_Value to get the default.
       Text( 'ELSIF l_src_type = ''SEQUENCE'' THEN  ',1);
       New_Line ;
       Text( 'l_return_value := ONT_Def_Util.Get_Sequence_Value',2);
       Text( '(p_sequence_name => l_rule_rec.src_sequence_name);',3);
	  Return_String(l_data_type);

       -- if the default source type is FROM the database call the
       -- function Get_Database_Default_value to get the default value.
       Text( 'ELSIF l_src_type = ''DATABASE'' THEN  ',1);
       New_Line ;
       Text( 'l_return_value := '||l_app_short_name||'_Def_Util.Get_Database_Default_Varchar2',2);
       Text( '(p_column_name => g_column_name,',3);
       Text( ' p_table_name => l_rule_rec.src_database_object_name);',3);
	  Return_String(l_data_type);

        -- if the default source type is FROM a parameter then invoke
        -- function Get_Parameter_value to get the default value.
        Text( 'ELSIF l_src_type = ''PARAMETER'' THEN  ',1);
        New_Line ;
        Text( 'l_return_value := '||l_app_short_name||'_Def_Util.GET_PARAMETER_VALUE',2);
        Text( '(l_rule_rec.SRC_PARAMETER_NAME);',3);
	   Return_String(l_data_type);
        */

       Text( ' END IF; ',1);
       New_Line ;

 Text('  EXCEPTION',0);
 Text('    WHEN OTHERS THEN',0);
 Text('    	ONT_Def_Util.Add_Invalid_Rule_Message',0);
 Text('    	( g_attribute_code',0);
 Text('    	, l_rule_rec.src_type',0);
 Text('    	, l_rule_rec.src_api_name',0);
 Text('    	, l_rule_rec.src_database_object_name',0);
 Text('    	, l_rule_rec.src_attribute_code',0);
 Text('    	, l_rule_rec.src_constant_value',0);
 Text('    	, l_rule_rec.src_profile_option',0);
 Text('    	, l_rule_rec.src_system_variable_expr',0);
 Text('    	, l_rule_rec.src_sequence_name ',0);
 Text('    	);',0);
 Text('  END;',0);
 New_Line ;
 Text('  END LOOP; ',0);
 New_Line ;
 Text('END IF; ',0);
 New_Line ;
 Text('END LOOP; ',0);
 New_Line ;
 Text('RETURN NULL; ',1);

 New_Line ;
 Text( 'EXCEPTION',0);
 Text( 'WHEN OTHERS THEN',0);
 Text( ' OE_MSG_PUB.Add_Exc_Msg',0);
 Text( '     ( G_PKG_NAME',0);
 Text( '      , ''Get_Default_Value''',0);
 Text( '      );',0);
 Text('  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',0);
 Text( 'END Get_Default_Value; ',0);
 New_Line ;
 Pkg_End (l_package,'BODY');

UPDATE AK_OBJECT_ATTRIBUTES
SET defaulting_api_pkg= l_package,
defaulting_api_proc = 'Get_Default_Value'
WHERE attribute_code = p_attribute_code
AND database_object_name=p_database_object_name
AND attribute_application_id= p_application_id;
commit;

x_defaulting_api_pkg := l_package;

END Create_Obj_Attr_Def_handler ;
-------------------------------------------------------------------------------
-- PROCEDURE Create_Entity_Def_Util_handler
--
-- This procedure generates the defaulting utility handler for the
-- entity.
-- This procedure will be invoked when the entity handler is being created and
-- a reference is made to the utility package of  a related entity.
--
-- ARGUMENTS:
-- p_application_id:	Application ID (660 for 'Oracle Order Management')
-- p_database_object_name:	AK base view for the related entity
--						(OE_AK_SOLD_TO_ORGS_V for 'Customer')
-- p_entity_code:			Short entity code for the related entity stored
--						in OE_AK_OBJECTS_EXT table
--						(SOLD_TO_ORG for 'Customer')
-- p_application_short_name:	Application Short Name
--						('ONT' for 'Oracle Order Management')
-- p_obj_defaulting_enabled	: 'Y' if defaulting rules can be defined
--							for the related entity's attributes also.
--							if 'N', the rules AND conditions caching
--							utilities need not be generated
-- p_generation_level	: create only the package specification if 'SPEC_ONLY'
--					  create only the package body if 'BODY_ONLY'
--					  create both spec AND body if 'FULL'
----------------------------------------------------------------------------
PROCEDURE Create_Entity_Def_Util_handler
(
 p_application_id				IN		VARCHAR2 ,
 p_database_object_name			IN		VARCHAR2 ,
 p_entity_code  				IN		VARCHAR2 ,
 p_application_short_name		IN      	VARCHAR2 ,
 p_obj_defaulting_enabled		IN 		VARCHAR2	DEFAULT 'Y',
 p_generation_level				IN		VARCHAR2  DEFAULT 'FULL'
)
IS

-- table declaration
TYPE obj_attr_tbl_type IS TABLE OF OE_DEF_AK_ATTR_EXT_V%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE foreign_keys_tbl_type IS TABLE OF OE_DEF_AK_FKEYS_V%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE col_rec_type IS RECORD
( attribute_code             VARCHAR2(30)
, column_name                VARCHAR2(30)
, data_type                  VARCHAR2(30)
);

TYPE col_tbl_type IS TABLE OF col_rec_type INDEX BY BINARY_INTEGER;

l_ak_obj_attr_tbl      obj_attr_tbl_type;
l_fkey_tbl              foreign_keys_tbl_type;
l_ukey_attr_tbl         col_tbl_type;
l_fkey_attr_tbl         col_tbl_type;

-- variables declaration
l_buffer                               VARCHAR2(20);
l_entity_code		VARCHAR2(15);
l_app_short_name		VARCHAR2(3);
l_pkg_name		VARCHAR2(30);
l_attribute_code	VARCHAR2(30);
l_column_name		VARCHAR2(30);
l_database_object_name		VARCHAR2(30);
l_uk_database_object_name		VARCHAR2(30);
l_fk_database_object_name		VARCHAR2(30);
J			NUMBER;
K			NUMBER;
U			NUMBER;
F			NUMBER;
l_related_pkg_name		VARCHAR2(30);
l_related_datatype		VARCHAR2(30);
l_uk_name		VARCHAR2(30);
l_fk_name		VARCHAR2(30);
l_uk_attribute		VARCHAR2(30);
l_fk_attribute		VARCHAR2(30);
l_uk_column		VARCHAR2(30);
l_fk_column		VARCHAR2(30);
l_missing_data_str	VARCHAR2(30);
l_date_field_exists VARCHAR2(1);


CURSOR OASV (p_database_object_name varchar2,p_application_id number)
is
	SELECT aoj.attribute_code,NVL(aoj.data_type,'VARCHAR2')data_type,
	aoj.column_name
	FROM AK_OBJECT_ATTRIBUTES_VL aoj
	WHERE aoj.database_object_name  = p_database_object_name
	AND aoj.attribute_application_id = p_application_id
        AND aoj.column_name is not null;

CURSOR PKEY (l_database_object_name varchar2,p_application_id number)
IS
	SELECT unique_key_name
	FROM AK_UNIQUE_KEYS
	WHERE database_object_name=l_database_object_name
	AND application_id=p_application_id
	AND rownum = 1;

CURSOR UKEY_COL(l_uk_name varchar2,p_application_id number,
		l_uk_database_object_name varchar2)
 IS
	SELECT attribute_code,column_name,
	unique_key_sequence,data_type
	FROM OE_DEF_AK_UKEY_COLS_V
	WHERE unique_key_name= l_uk_name
	AND database_object_name = l_uk_database_object_name
	ORDER BY unique_key_sequence;

CURSOR FKEY_COL(l_fk_name varchar2,p_application_id number,
		l_database_object_name varchar2)
IS
	SELECT b.attribute_code, b.column_name,
	foreign_key_sequence, b.data_type
	FROM ak_object_attributes_vl b,ak_foreign_key_columns a
	WHERE a.foreign_key_name= l_fk_name
	AND b.database_object_name = l_database_object_name
	AND b.attribute_application_id = a.attribute_application_id
	AND b.attribute_code = a.attribute_code
	ORDER BY foreign_key_sequence;

CURSOR FKEY(l_database_object_name varchar2,p_application_id number)
IS
	SELECT unique_key_name,uk_database_object_name,foreign_key_name,
	fk_entity_code
	FROM OE_DEF_AK_FKEYS_V
	WHERE fk_database_object_name=l_database_object_name
	AND application_id=p_application_id;

CURSOR FKEY_DATE(l_database_object_name varchar2,p_application_id number)
IS
	SELECT unique_key_name,uk_database_object_name
	       , foreign_key_name, fk_entity_code
	FROM OE_DEF_AK_FKEYS_V fk
	WHERE fk_database_object_name=l_database_object_name
	AND application_id=p_application_id
	AND exists (SELECT 'Y'
			  FROM ak_object_attributes_vl oa
			  WHERE oa.database_object_name = fk.uk_database_object_name
			  AND oa.data_type = 'DATE'
			  );
			  --
			  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
			  --
BEGIN

	Init_Applsys_Schema;

 	l_app_short_name := p_application_short_name;
	l_database_object_name := p_database_object_name;

  -- Generate the util package

  l_pkg_name := l_app_short_name||'_'||p_entity_code||'_Def'||'_Util';


  --------------------------------------------------------------------
  -- WRITE OUT THE SPEC FOR THE UTIL PACKAGE e.g. ONT_HEADER_DEF_UTIL
  --------------------------------------------------------------------

  if p_generation_level = 'BODY_ONLY' then
	goto START_OF_BODY;
  end if;

  Pkg_Header( p_pkg_name     =>  l_pkg_name,
			p_pkg_type	=>  'SPEC');


  Text('g_cached_record          '||l_database_object_name||'%ROWTYPE;',1);

  IF upper(p_obj_defaulting_enabled) = 'Y' THEN
 	Text('g_attr_rules_cache         ONT_DEF_UTIL.Attr_Def_Rule_Tbl_Type;',1);
  END IF;

  -- FUNCTION Get_Attr_Val_Varchar2

  New_Line;
  Text ('FUNCTION Get_Attr_Val_Varchar2',0);
  Parameter('attr_code   ','IN','VARCHAR2',0,30,TRUE);
  Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0);
  Text (') RETURN VARCHAR2;',0);

  -- FUNCTION Get_Attr_Val_Date

  New_Line;
  Text ('FUNCTION Get_Attr_Val_Date',0);
  Parameter('attr_code   ','IN','VARCHAR2',0,30,TRUE);
  Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0);
  Text (') RETURN DATE;',0);


  -- FUNCTION Sync_<Entity>_Cache

  New_Line;
  Text('FUNCTION Sync_'||p_entity_code||'_Cache',0);
  FOR pkey_name in PKEY (l_database_object_name ,p_application_id )
  LOOP
	l_uk_name := pkey_name.unique_key_name;
	l_uk_database_object_name := p_database_object_name;
     -- Cache the primary key columns for this entity in l_ukey_attr_tbl
	l_ukey_attr_tbl.DELETE;
	u:=0;
	FOR ukey_cols in UKEY_COL (l_uk_name ,p_application_id
							, l_uk_database_object_name )
	LOOP
		if u=0 then
	       Parameter
			(ukey_cols.column_name,'IN',ukey_cols.data_type,0,30,TRUE);
          else
	       Parameter
			(ukey_cols.column_name,'IN',ukey_cols.data_type,0,30);
	     end if;
		l_ukey_attr_tbl(u).attribute_code := ukey_cols.attribute_code;
		l_ukey_attr_tbl(u).column_name := ukey_cols.column_name;
		l_ukey_attr_tbl(u).data_type := ukey_cols.data_type;
		u := u+1;
	END LOOP;
  END LOOP;
  Text (') RETURN NUMBER;',0);
  New_Line;

  -- Following functions are NEEDED ONLY IF attributes for this object can be
  -- defaulted i.e. defaulting_enabled_flag = 'Y' for this entity on the
  -- oe_ak_objects_ext table

  IF upper(p_obj_defaulting_enabled) = 'Y' THEN

     -- FUNCTION Get_Foreign_Attr_Val_Varchar2

  	New_Line;
 	Text ('FUNCTION Get_Foreign_Attr_Val_Varchar2',0);
  	Parameter('foreign_attr_code   ','IN','VARCHAR2',0,30,TRUE);
  	Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0,30);
  	Parameter('foreign_database_object_name   ','IN','VARCHAR2',0);
  	Text (') RETURN VARCHAR2;',0);

     -- FUNCTION Get_Foreign_Attr_Val_Date

  	New_Line;
 	Text ('FUNCTION Get_Foreign_Attr_Val_Date',0);
  	Parameter('foreign_attr_code   ','IN','VARCHAR2',0,30,TRUE);
  	Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0,30);
  	Parameter('foreign_database_object_name   ','IN','VARCHAR2',0);
  	Text (') RETURN DATE;',0);

	-- PROCEDURE Clear_<Entity>_Cache

  	New_Line;
  	Text ('PROCEDURE Clear_'||p_entity_code||'_Cache;',0);

	-- PROCEDURE Get_Valid_Defaulting_Rules

  	New_Line;
  	Text ('PROCEDURE Get_Valid_Defaulting_Rules',0);
  	Parameter('attr_code   ','IN','VARCHAR2',0,30,TRUE);
  	Parameter('attr_id   ','IN','NUMBER',0,30,FALSE);
  	Parameter(LOWER(p_entity_code)||'_rec','IN',
			 l_database_object_name||'%ROWTYPE',0);
  	Parameter('rules_start_index_tbl   ','OUT','OE_GLOBALS.NUMBER_TBL_Type',0,30,FALSE);
  	Parameter('rules_stop_index_tbl   ','OUT','OE_GLOBALS.NUMBER_TBL_Type',0,30,FALSE);
  	Text (');',0);

	-- FUNCTION Validate_Defaulting_Condition

  	New_Line;
  	Text ('FUNCTION Validate_Defaulting_Condition',0);
  	Parameter('condition_id   ','IN','NUMBER',0,30,TRUE);
  	Parameter(LOWER(p_entity_code)||'_rec','IN',
			 l_database_object_name||'%ROWTYPE ',0);
  	Text (') RETURN BOOLEAN;',0);

  END IF;

  New_Line;

  Pkg_End (l_pkg_name,'SPEC');


  <<START_OF_BODY>>
  -----------------------------------------------------------------------------
  -- WRITE OUT THE BODY FOR THE UTIL PACKAGE e.g. ONT_HEADER_DEF_UTIL
  -----------------------------------------------------------------------------

  if p_generation_level = 'SPEC_ONLY' then
	RETURN;
  end if;

  Pkg_Header( p_pkg_name     =>  l_pkg_name,
			p_pkg_type	=>  'BODY');

  New_Line;
  Text ('g_database_object_name varchar2(30) :='''||l_database_object_name||''';',1);

  if upper(p_obj_defaulting_enabled) <> 'Y' then
	goto END_OF_BODY_GLOBALS;
  end if;

  New_Line;
  Text ('TYPE Condition_Rec_Type IS RECORD (',1);
  Text ('condition_id      NUMBER,',1);
  Text ('group_number      NUMBER,',1);
  Text ('attribute_code      VARCHAR2(30),',1);
  Text ('value_op            VARCHAR2(15),',1);
  Text ('value_string      VARCHAR2(255));',1);
  New_Line;

  Text ('TYPE Condition_Tbl_Type IS TABLE OF Condition_Rec_Type',1);
  Text ('INDEX BY BINARY_INTEGER;',1);
  Text ('g_conditions_tbl_cache         Condition_Tbl_Type;',1);
  New_Line;
  Text ('g_attr_condns_cache         ONT_DEF_UTIL.Attr_Condn_Tbl_Type;',1);

  <<END_OF_BODY_GLOBALS>>

  New_Line;
  New_Line;

  -----------------------------------------------------------------------
  -- FUNCTION Get_Attr_Val_Varchar2
  -- This function returns the value of a given attribute on this entity
  -- from the record passed to it
  -----------------------------------------------------------------------

  PUT_LINE( '       Create FUNCTION Get_Attr_Val_Varchar2');

  Text ('FUNCTION Get_Attr_Val_Varchar2',0);
  Parameter('attr_code   ','IN','VARCHAR2',0,30,TRUE);
  Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0);
  Text (') RETURN VARCHAR2',0);
  Text ('IS',0);
  Text ('BEGIN',0);
  New_Line;

  l_ak_obj_attr_tbl.DELETE;
  j :=0;
  FOR l_attr_rec in OASV(p_database_object_name ,p_application_id )
  LOOP
	l_ak_obj_attr_tbl(j).attribute_code := l_attr_rec.attribute_code;
	l_ak_obj_attr_tbl(j).column_name := l_attr_rec.column_name;
	l_ak_obj_attr_tbl(j).data_type := l_attr_rec.data_type;
	j := j+1;
  END LOOP;

  IF l_ak_obj_attr_tbl.COUNT = 0 THEN
	PUT_LINE
		(' ERROR: NO ATTRIBUTES DEFINED FOR THIS ENTITY');
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  j:= 0;
  FOR J IN 0..l_ak_obj_attr_tbl.COUNT -1 LOOP

    l_attribute_code := l_ak_obj_attr_tbl(j).attribute_code ;
    l_column_name := l_ak_obj_attr_tbl(j).column_name ;

    IF l_ak_obj_attr_tbl(j).data_type = 'NUMBER' THEN
       l_missing_data_str := 'FND_API.G_MISS_NUM';
    ELSIF l_ak_obj_attr_tbl(j).data_type = 'VARCHAR2' THEN
       l_missing_data_str := 'FND_API.G_MISS_CHAR';
    ELSIF l_ak_obj_attr_tbl(j).data_type = 'DATE' THEN
       l_missing_data_str := 'FND_API.G_MISS_DATE';
    END IF;

    if j=0 then
      Text ('IF p_attr_code =('||''''||l_attribute_code||''''||') THEN',0);
    else
      Text ('ELSIF p_attr_code =('||''''||l_attribute_code||''''||') THEN',0);
    end if;

    Text ('IF NVL(p_record.'||l_column_name||', '||l_missing_data_str||
		 ') <> '||l_missing_data_str||' THEN',1);
    Text ('RETURN p_record.'||l_column_name||';',1);
    Text ('ELSE',1);
    Text ('RETURN NULL; ',1);
    Text ('END IF;',1);

  END LOOP;

  Text ('ELSE',0);
  Text ('RETURN NULL; ',0);
  Text ('END IF;',0);
  Text ('END  Get_Attr_Val_Varchar2;',0);

  New_Line;
  New_Line;


  -----------------------------------------------------------------------
  -- FIX BUG 1548433 - Added function Get_Attr_Val_Date
  -- FUNCTION Get_Attr_Val_Date. This function will return a
  -- DATE default so that the time component is NOT lost.
  -- This function returns the value of a given attribute on this entity
  -- from the record passed to it
  -----------------------------------------------------------------------
  PUT_LINE( '       Create FUNCTION Get_Attr_Val_Date');


  Text ('FUNCTION Get_Attr_Val_Date',0);
  Parameter('attr_code   ','IN','VARCHAR2',0,30,TRUE);
  Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0);
  Text (') RETURN DATE',0);
  Text ('IS',0);
  Text ('BEGIN',0);
  New_Line;

  j:= 0;
  l_date_field_exists := 'N';

  -- First, set up the if loop for all date attributes on this entity
  FOR J IN 0..l_ak_obj_attr_tbl.COUNT -1 LOOP

    IF l_ak_obj_attr_tbl(j).data_type = 'DATE' THEN
       l_attribute_code := l_ak_obj_attr_tbl(j).attribute_code ;
       l_column_name := l_ak_obj_attr_tbl(j).column_name ;
       l_missing_data_str := 'FND_API.G_MISS_DATE';
       if l_date_field_exists = 'N' then
         Text ('IF p_attr_code =('||''''||l_attribute_code||''''||') THEN',0);
       else
         Text ('ELSIF p_attr_code =('||''''||l_attribute_code||''''||') THEN',0);
       end if;
       Text ('IF NVL(p_record.'||l_column_name||', '||l_missing_data_str||
		    ') <> '||l_missing_data_str||' THEN',2);
       Text ('RETURN p_record.'||l_column_name||';',2);
       Text ('ELSE',2);
       Text ('RETURN NULL; ',2);
       Text ('END IF;',2);
	  l_date_field_exists := 'Y';
    END IF;

  END LOOP;

  -- Next, loop through all non-date attributes on this entity and return
  -- to_date of the value in that attribute
  FOR J IN 0..l_ak_obj_attr_tbl.COUNT -1 LOOP

    IF l_ak_obj_attr_tbl(j).data_type <> 'DATE' THEN
       l_attribute_code := l_ak_obj_attr_tbl(j).attribute_code ;
       l_column_name := l_ak_obj_attr_tbl(j).column_name ;
       IF l_ak_obj_attr_tbl(j).data_type = 'NUMBER' THEN
         l_missing_data_str := 'FND_API.G_MISS_NUM';
       ELSIF l_ak_obj_attr_tbl(j).data_type = 'VARCHAR2' THEN
         l_missing_data_str := 'FND_API.G_MISS_CHAR';
       END IF;
       if l_date_field_exists = 'N' then
         Text ('IF p_attr_code =('||''''||l_attribute_code||''''||') THEN',0);
       else
         Text ('ELSIF p_attr_code =('||''''||l_attribute_code||''''||') THEN',0);
       end if;
       Text ('IF NVL(p_record.'||l_column_name||', '||l_missing_data_str||
		    ') <> '||l_missing_data_str||' THEN',2);
       Text ('RETURN to_date(p_record.'||l_column_name||',''RRRR/MM/DD HH24:MI:SS'');',2);
       Text ('ELSE',2);
       Text ('RETURN NULL; ',2);
       Text ('END IF;',2);
	  l_date_field_exists := 'Y';
    END IF;

  END LOOP;

  Text ('ELSE',0);
  Text ('RETURN NULL; ',0);
  Text ('END IF;',0);
  New_Line;
  Text ('END  Get_Attr_Val_Date;',0);
  New_Line;
  New_Line;


  -- Cache the primary key columns for this entity in l_ukey_attr_tbl
  -- Will be needed in generation of following procedures/functions
  FOR pkey_name in PKEY (l_database_object_name ,p_application_id )
  LOOP
    l_uk_name := pkey_name.unique_key_name;
    l_uk_database_object_name := p_database_object_name;
    l_ukey_attr_tbl.DELETE;
    u:=0;
    FOR ukey_cols in UKEY_COL (l_uk_name ,p_application_id
				, l_uk_database_object_name )
    LOOP
      l_ukey_attr_tbl(u).attribute_code := ukey_cols.attribute_code;
      l_ukey_attr_tbl(u).column_name := ukey_cols.column_name;
      l_ukey_attr_tbl(u).data_type := ukey_cols.data_type;
      u := u+1;
    END LOOP;
  END LOOP;

  -------------------------------------------------------------------------------
  -- PROCEDURE Clear_<Entity>_Cache
  -- Function to clear cache.
  -- Assign all the attributes of the cached record to null;
  -------------------------------------------------------------------------------

  PUT_LINE( '       Create PROCEDURE Clear_'||p_entity_code||'_Cache');

  Text ('PROCEDURE Clear_'||p_entity_code||'_Cache',1);
  Text ('IS  ',1);
  Text ('BEGIN  ',1);

  FOR u in 0..l_ukey_attr_tbl.COUNT -1  LOOP
     l_uk_column := l_ukey_attr_tbl(U).column_name;
     Text ('g_cached_record.'||l_uk_column||' := null;',1);
  END LOOP;

  Text (' END Clear_'||p_entity_code||'_Cache;',1);
  New_Line;
  New_Line;


  -------------------------------------------------------------------------------
  -- FUNCTION Sync_'||p_entity_code||'_Cache
  -- Function to Synchronize cache.If the cached record is not equal to the
  -- current record , clear the cache AND load the cache with the new record.
  -------------------------------------------------------------------------------

  PUT_LINE('       Create FUNCTION Sync_'||p_entity_code||'_Cache');

  l_uk_database_object_name := p_database_object_name;

  Text('FUNCTION Sync_'||p_entity_code||'_Cache',0);
  FOR u in 0..l_ukey_attr_tbl.COUNT -1  LOOP
    l_uk_attribute := l_ukey_attr_tbl(U).attribute_code;
    l_uk_column := l_ukey_attr_tbl(U).column_name;
    -- first column
    if u=0 then
       Parameter
		(l_uk_column,'IN', l_ukey_attr_tbl(U).data_type,0,30,TRUE);
    else
       Parameter
		(l_uk_column,'IN', l_ukey_attr_tbl(U).data_type,0,30);
    end if;
  END LOOP;

  New_Line;

  New_Line;
  Text (') RETURN NUMBER',0);

  -- Write out the local variables declared in this function
  Text ('IS',0);

  Text ('CURSOR cache IS ',0);
  Text ('SELECT * FROM   '||p_database_object_name,1);
  FOR U in 0..l_ukey_attr_tbl.COUNT -1  LOOP
    l_uk_attribute := l_ukey_attr_tbl(U).attribute_code;
    l_uk_column := l_ukey_attr_tbl(U).column_name;
    if u = 0 then
      Text ('WHERE '||l_uk_column||'  = p_'||l_uk_column,1);
    else
      Text ('AND '||l_uk_column||'  = p_'||l_uk_column,1);
    end if;
  END LOOP;
  Text (';',1);
  Text ('BEGIN',0);
  New_Line;

  FOR U in 0..l_ukey_attr_tbl.COUNT -1  LOOP

    l_uk_column := l_ukey_attr_tbl(U).column_name;

    if substr(l_ukey_attr_tbl(U).data_type,1,4) = 'DATE' then
      l_buffer := 'FND_API.G_MISS_DATE';
    elsif substr(l_ukey_attr_tbl(U).data_type,1,3) = 'NUM'
          or substr(l_ukey_attr_tbl(U).data_type,1,3) = 'INT' then
      l_buffer := 'FND_API.G_MISS_NUM';
    else
      l_buffer := 'FND_API.G_MISS_CHAR';
    end if;

    if u = 0 then
       Text('IF (NVL(p_'||l_uk_column||','||l_buffer||
                 ')  = '||l_buffer||') ',0);
    else
       Text('OR (NVL(p_'||l_uk_column||','||l_buffer||
                 ')  = '||l_buffer||') ',0);
    end if;

  END LOOP;
  Text('THEN',0);
  Text ('RETURN 0 ;',1);

  -- Cache the record
  FOR U in 0..l_ukey_attr_tbl.COUNT -1  LOOP
    l_uk_column := l_ukey_attr_tbl(U).column_name;

    if substr(l_ukey_attr_tbl(U).data_type,1,4) = 'DATE' then
      l_buffer := 'FND_API.G_MISS_DATE';
    elsif substr(l_ukey_attr_tbl(U).data_type,1,3) = 'NUM'
       or substr(l_ukey_attr_tbl(U).data_type,1,3) = 'INT' then
      l_buffer := 'FND_API.G_MISS_NUM';
    else
      l_buffer := 'FND_API.G_MISS_CHAR';
    end if;

    if u = 0 then
      Text
      ('ELSIF (NVL(g_cached_record.'||l_uk_column||','||l_buffer||
       ')  <>  p_'||l_uk_column||') ',0);
    else
      Text
      ('OR (NVL(g_cached_record.'||l_uk_column||','||l_buffer||
       ')  <>  p_'||l_uk_column||') ',0);
    end if;
  END LOOP;
  Text('THEN',0);
  Text ('Clear_'||p_entity_code||'_Cache;',1);
  Text ('Open cache;',1);
  Text ('FETCH cache into g_cached_record;',1);
  Text ('IF cache%NOTFOUND THEN',1);  -- 2218044
  Text ('RETURN 0;',2);
  Text ('END IF;',1);  -- 2218044 end
  Text ('Close cache;',1);
  Text ('RETURN 1 ;',1);
  Text ('END IF;',0);
  New_Line;

  Text ('RETURN 1 ;',1);
  Text ('EXCEPTION',0);
  Text ('WHEN OTHERS THEN ',1);
  Text ('RETURN 0 ;',1);
  Text ('END Sync_'||p_entity_code||'_Cache;',0);
  New_Line;
  New_Line;

  -- END OF FUNCTION Sync_'||p_entity_code||'_Cache

  -- if object CANNOT be defaulted, then skip the rest of the procedures
  -- AND go to the end
  if upper(p_obj_defaulting_enabled) <> 'Y' then
	goto END_OF_BODY;
  end if;

  -------------------------------------------------------------------------------
  -- FUNCTION Get_Foreign_Attr_Val_Varchar2
  -- This Function is used to get the value when the default source_type
  -- is a related record. Based on the foreign key relationship, it gets the value
  -- FROM the related entity.
  -------------------------------------------------------------------------------

  PUT_LINE( '       Create FUNCTION Get_Foreign_Attr_Val_Varchar2');

  Text ('FUNCTION Get_Foreign_Attr_Val_Varchar2',0);
  Parameter('foreign_attr_code   ','IN','VARCHAR2',0,30,TRUE);
  Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0,30);
  Parameter('foreign_database_object_name   ','IN','VARCHAR2',0);
  Text (') RETURN VARCHAR2',0);
  New_Line;
  Text ('IS',0);

  j :=0;
  l_fkey_tbl.DELETE;

  -- Retrieve all the objects to which this object has a foreign key
  FOR fkey_view in FKEY (l_database_object_name ,p_application_id )
  LOOP
    l_fkey_tbl(j).uk_database_object_name := fkey_view.uk_database_object_name;
    l_fkey_tbl(j).unique_key_name := fkey_view.unique_key_name;
    l_fkey_tbl(j).foreign_key_name := fkey_view.foreign_key_name;
    l_fkey_tbl(j).fk_entity_code := fkey_view.fk_entity_code;
    j := j+1;
  END LOOP;

  New_Line;
  Text ('BEGIN',0);
  New_Line;

  IF l_fkey_tbl.COUNT = 0 THEN

    PUT_LINE('        No foreign keys defined for this entity');

  ELSIF l_fkey_tbl.COUNT <> 0 then

    j:= 0;

    FOR J in 0..l_fkey_tbl.COUNT -1  LOOP

      l_uk_name := l_fkey_tbl(j).unique_key_name;
      l_fk_name := l_fkey_tbl(j).foreign_key_name;
      l_uk_database_object_name := l_fkey_tbl(j).uk_database_object_name;
      l_entity_code  := l_fkey_tbl(j).fk_entity_code;
      l_related_pkg_name := l_app_short_name||'_'||l_entity_code||'_Def'||'_Util';

      l_ukey_attr_tbl.DELETE;
      U :=0;
	 -- Get all the unique key columns e.g. ORGANIZATION_ID on OE_AK_SOLD_TO_ORGS_V
      FOR ukey_cols in UKEY_COL (l_uk_name ,p_application_id , l_uk_database_object_name )
      LOOP
	   l_ukey_attr_tbl(u).attribute_code := ukey_cols.attribute_code;
	   l_ukey_attr_tbl(u).column_name := ukey_cols.column_name;
	   l_ukey_attr_tbl(u).data_type := ukey_cols.data_type;
        u := u+1;
      END LOOP;

      IF l_ukey_attr_tbl.COUNT  =0 THEN
	 -- THere are no unique keys defined in the AK for this entity. so exit
	 PUT_LINE('   ERROR: No unique key columns on the key:'
			||l_uk_name);
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_fkey_attr_tbl.DELETE;
      F :=0;
	 -- Get all the foreign key columns e.g. SOLD_TO_ORG_ID on OE_AK_ORDER_LINES_V
      FOR fkey_cols in FKEY_COL (l_fk_name ,p_application_id ,l_database_object_name )
      LOOP
	   l_fkey_attr_tbl(f).attribute_code := fkey_cols.attribute_code;
	   l_fkey_attr_tbl(f).column_name := fkey_cols.column_name;
	   l_fkey_attr_tbl(f).data_type := fkey_cols.data_type;
        f := f+1;
      END LOOP;

      IF l_fkey_attr_tbl.COUNT  = 0 THEN
 	 PUT_LINE('        ERROR: No foreign key columns on the key:'
			||l_fk_name);
 	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      if j=0 then
         Text (' IF (p_foreign_database_object_name = '||''''
				||l_uk_database_object_name||''''||') THEN',0);
      else
	    Text (' ELSIF (p_foreign_database_object_name = '||''''
				||l_uk_database_object_name||''''||') THEN',0);
      end if;

	 IF l_ukey_attr_tbl.COUNT = 1 THEN

        l_uk_attribute := l_ukey_attr_tbl(0).attribute_code;
        l_fk_attribute := l_fkey_attr_tbl(0).attribute_code;
        l_uk_column  := l_ukey_attr_tbl(0).column_name;
        l_fk_column  := l_fkey_attr_tbl(0).column_name;
        IF l_fkey_attr_tbl(0).data_type = 'NUMBER' THEN
          l_missing_data_str := 'FND_API.G_MISS_NUM';
        ELSIF l_fkey_attr_tbl(0).data_type = 'VARCHAR2' THEN
          l_missing_data_str := 'FND_API.G_MISS_CHAR';
        ELSIF l_fkey_attr_tbl(0).data_type = 'DATE' THEN
          l_missing_data_str := 'FND_API.G_MISS_DATE';
        END IF;
	   -- Fix Bug 1549538: Return NULL if the foreign key column is null
	   -- or missing
	   Text('IF NVL(p_record.'||l_fk_column||','||l_missing_data_str||') = '
			   ||l_missing_data_str||' THEN ',2);
        Text('RETURN NULL;',3);
        Text('END IF;',2);
	   Text('IF  '||l_related_pkg_name||'.Sync_'||l_entity_code||'_Cache',2);
	   Text('(p_'||l_uk_column||' => p_record.'||l_fk_column||') = 1  then ',3);
	   Text('RETURN '||l_related_pkg_name||'.Get_Attr_Val_Varchar2',2);
	   Text('(p_foreign_attr_code,'||l_related_pkg_name||'.g_cached_record); ',3);
        Text('END IF;');

      ELSE

        U:= 0;
        FOR U in 0..l_ukey_attr_tbl.COUNT -1  LOOP

        l_fk_attribute := l_fkey_attr_tbl(U).attribute_code;
        l_fk_column  := l_fkey_attr_tbl(U).column_name;
        IF l_fkey_attr_tbl(U).data_type = 'NUMBER' THEN
          l_missing_data_str := 'FND_API.G_MISS_NUM';
        ELSIF l_fkey_attr_tbl(U).data_type = 'VARCHAR2' THEN
          l_missing_data_str := 'FND_API.G_MISS_CHAR';
        ELSIF l_fkey_attr_tbl(U).data_type = 'DATE' THEN
          l_missing_data_str := 'FND_API.G_MISS_DATE';
        END IF;

	   -- Fix Bug 1549538: Return NULL if any one of the foreign key
	   -- columns is null or missing
        if u = 0 then
          Text('IF ( NVL(p_record.'||l_fk_column||','||l_missing_data_str||') = '
			   ||l_missing_data_str||' )',2);
        else
          Text('   OR ( NVL(p_record.'||l_fk_column||','||l_missing_data_str||') = '
			   ||l_missing_data_str||' )',2);
        end if;
        if u = l_ukey_attr_tbl.COUNT -1 then
	     Text('THEN',2);
	     Text('RETURN NULL;',2);
          Text('END IF;',2);
        end if;

        END LOOP;

        FOR U in 0..l_ukey_attr_tbl.COUNT -1  LOOP

        l_uk_attribute := l_ukey_attr_tbl(U).attribute_code;
        l_fk_attribute := l_fkey_attr_tbl(U).attribute_code;
        l_uk_column  := l_ukey_attr_tbl(U).column_name;
        l_fk_column  := l_fkey_attr_tbl(U).column_name;

        if u = 0 then
          Text('IF '||l_related_pkg_name||'.Sync_'||l_entity_code||'_Cache(p_'||l_uk_column
		  ||' => p_record.'||l_fk_column||',',2);
        elsif u = l_ukey_attr_tbl.COUNT -1 then
	     Text('p_'||l_uk_column||' => p_record.'||l_fk_column||') =1 then ',2);
	     Text('RETURN  '||l_related_pkg_name||'.Get_Attr_Val_Varchar2(p_foreign_attr_code,'
		  ||l_related_pkg_name||'.g_cached_record); ',2);
          Text('END IF;');
        else
	     Text('p_'||l_uk_column||' => p_record.'||l_fk_column||', ',2);
        end if;
        END LOOP;

      END IF;

      if j = l_fkey_tbl.COUNT -1 then
        Text ('END IF;',0);
      end if;

      New_Line;
    END LOOP;

  END IF; -- end if foreign keys exist

  Text (' RETURN NULL;',2);
  Text ('END Get_Foreign_Attr_Val_Varchar2;',0);
  New_Line;
  -- END OF FUNCTION Get_Foreign_Attr_Val_Varchar2


  -----------------------------------------------------------------------
  -- FIX BUG 1548433 - Added function Get_Foreign_Attr_Val_Date
  -- FUNCTION Get_Foreign_Attr_Val_Date. This function will return a
  -- DATE default so that the time component is NOT lost.
  -- This Function is used to get the value when the default source_type
  -- is a related record. Based on the foreign key relationship, it gets
  -- the value FROM the related entity.
  -----------------------------------------------------------------------

  PUT_LINE( '       Create FUNCTION Get_Foreign_Attr_Val_Date');

  Text ('FUNCTION Get_Foreign_Attr_Val_Date',0);
  Parameter('foreign_attr_code   ','IN','VARCHAR2',0,30,TRUE);
  Parameter('record','IN',
			 l_database_object_name||'%ROWTYPE ',0,30);
  Parameter('foreign_database_object_name   ','IN','VARCHAR2',0);
  Text (') RETURN DATE',0);
  New_Line;
  Text ('IS',0);
  Text ('BEGIN',0);
  New_Line;

  IF l_fkey_tbl.COUNT = 0 THEN

    PUT_LINE('        No related objects exist');

  ELSIF l_fkey_tbl.COUNT <> 0 then

    j:= 0;

    FOR J in 0..l_fkey_tbl.COUNT -1  LOOP

      l_uk_database_object_name := l_fkey_tbl(j).uk_database_object_name;
      l_uk_name := l_fkey_tbl(j).unique_key_name;
      l_fk_name := l_fkey_tbl(j).foreign_key_name;
      l_entity_code  := l_fkey_tbl(j).fk_entity_code;
      l_related_pkg_name := l_app_short_name||'_'||l_entity_code||'_Def'||'_Util';

      l_ukey_attr_tbl.DELETE;
      U :=0;
	 -- Get all the unique key columns e.g. ORGANIZATION_ID on OE_AK_SOLD_TO_ORGS_V
      FOR ukey_cols in UKEY_COL (l_uk_name ,p_application_id , l_uk_database_object_name )
      LOOP
	   l_ukey_attr_tbl(u).attribute_code := ukey_cols.attribute_code;
	   l_ukey_attr_tbl(u).column_name := ukey_cols.column_name;
	   l_ukey_attr_tbl(u).data_type := ukey_cols.data_type;
        u := u+1;
      END LOOP;

      IF l_ukey_attr_tbl.COUNT  =0 THEN
	 -- THere are no unique keys defined in the AK for this entity. so exit
	 PUT_LINE('   ERROR: No unique key columns on the key:'
			||l_uk_name);
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_fkey_attr_tbl.DELETE;
      F :=0;
	 -- Get all the foreign key columns e.g. SOLD_TO_ORG_ID on OE_AK_ORDER_LINES_V
      FOR fkey_cols in FKEY_COL (l_fk_name ,p_application_id ,l_database_object_name )
      LOOP
	   l_fkey_attr_tbl(f).attribute_code := fkey_cols.attribute_code;
	   l_fkey_attr_tbl(f).column_name := fkey_cols.column_name;
	   l_fkey_attr_tbl(f).data_type := fkey_cols.data_type;
        f := f+1;
      END LOOP;

      IF l_fkey_attr_tbl.COUNT  = 0 THEN
 	 PUT_LINE('        ERROR: No foreign key columns on the key:'
			||l_fk_name);
 	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      if j=0 then
         Text (' IF (p_foreign_database_object_name = '||''''
				||l_uk_database_object_name||''''||') THEN',0);
      else
	    Text (' ELSIF (p_foreign_database_object_name = '||''''
				||l_uk_database_object_name||''''||') THEN',0);
      end if;

	 IF l_ukey_attr_tbl.COUNT = 1 THEN

        l_uk_attribute := l_ukey_attr_tbl(0).attribute_code;
        l_fk_attribute := l_fkey_attr_tbl(0).attribute_code;
        l_uk_column  := l_ukey_attr_tbl(0).column_name;
        l_fk_column  := l_fkey_attr_tbl(0).column_name;
        IF l_fkey_attr_tbl(0).data_type = 'NUMBER' THEN
          l_missing_data_str := 'FND_API.G_MISS_NUM';
        ELSIF l_fkey_attr_tbl(0).data_type = 'VARCHAR2' THEN
          l_missing_data_str := 'FND_API.G_MISS_CHAR';
        ELSIF l_fkey_attr_tbl(0).data_type = 'DATE' THEN
          l_missing_data_str := 'FND_API.G_MISS_DATE';
        END IF;
	   Text('IF NVL(p_record.'||l_fk_column||','||l_missing_data_str||') = '
			   ||l_missing_data_str||' THEN ',2);
        Text('RETURN NULL;',3);
        Text('END IF;',2);
	   Text('IF  '||l_related_pkg_name||'.Sync_'||l_entity_code||'_Cache',2);
	   Text('(p_'||l_uk_column||' => p_record.'||l_fk_column||') = 1  then ',3);
	   Text('RETURN '||l_related_pkg_name||'.Get_Attr_Val_Date(p_foreign_attr_code,'
		  ||l_related_pkg_name||'.g_cached_record); ',2);
        Text('END IF;');

      ELSE

        U:= 0;
        FOR U in 0..l_ukey_attr_tbl.COUNT -1  LOOP

        l_fk_attribute := l_fkey_attr_tbl(U).attribute_code;
        l_fk_column  := l_fkey_attr_tbl(U).column_name;
        IF l_fkey_attr_tbl(U).data_type = 'NUMBER' THEN
          l_missing_data_str := 'FND_API.G_MISS_NUM';
        ELSIF l_fkey_attr_tbl(U).data_type = 'VARCHAR2' THEN
          l_missing_data_str := 'FND_API.G_MISS_CHAR';
        ELSIF l_fkey_attr_tbl(U).data_type = 'DATE' THEN
          l_missing_data_str := 'FND_API.G_MISS_DATE';
        END IF;

        if u = 0 then
          Text('IF ( NVL(p_record.'||l_fk_column||','||l_missing_data_str||') = '
			   ||l_missing_data_str||' )',2);
        else
          Text('   OR ( NVL(p_record.'||l_fk_column||','||l_missing_data_str||') = '
			   ||l_missing_data_str||' )',2);
        end if;
        if u = l_ukey_attr_tbl.COUNT -1 then
	     Text('THEN',2);
	     Text('RETURN NULL;',2);
          Text('END IF;',2);
        end if;

        END LOOP;

        FOR U in 0..l_ukey_attr_tbl.COUNT -1  LOOP

        l_uk_attribute := l_ukey_attr_tbl(U).attribute_code;
        l_fk_attribute := l_fkey_attr_tbl(U).attribute_code;
        l_uk_column  := l_ukey_attr_tbl(U).column_name;
        l_fk_column  := l_fkey_attr_tbl(U).column_name;

        if u = 0 then
          Text('IF '||l_related_pkg_name||'.Sync_'||l_entity_code||'_Cache(p_'
		  ||l_uk_column||' => p_record.'||l_fk_column||',',2);
        elsif u = l_ukey_attr_tbl.COUNT -1 then
	     Text('p_'||l_uk_column||' => p_record.'||l_fk_column||') =1 then ',2);
	     Text('RETURN '||l_related_pkg_name||'.Get_Attr_Val_Date(p_foreign_attr_code,'
		  ||l_related_pkg_name||'.g_cached_record); ',2);
          Text('END IF;');
        else
	     Text('p_'||l_uk_column||' => p_record.'||l_fk_column||', ',2);
        end if;
        END LOOP;

      END IF;

      if j = l_fkey_tbl.COUNT -1 then
        Text ('END IF;',0);
      end if;

      New_Line;
    END LOOP;

   end if;

   Text (' RETURN NULL;',2);
   Text ('END Get_Foreign_Attr_Val_Date;',0);
   New_Line;

-------------------------------------------------------------------------------

  New_Line;
-- Function to get the current condition index
-- Validate_defaulting_condition calls this function to get the condition
-- AND cache it .

PUT_LINE( '       Create FUNCTION Get_Condition_Index_In_Cache');
Text ('FUNCTION Get_Condition_Index_In_Cache',0);
Parameter('condition_id   ','IN', 'NUMBER',0,30,TRUE);
Text (') RETURN NUMBER',0);
Text ('IS  ',0);
Text ('BEGIN  ',0);
New_Line;
Text ('FOR i in 0..g_conditions_tbl_cache.COUNT -1  LOOP  ',1);
Text ('if (g_conditions_tbl_cache(i).condition_id = p_condition_id ) then  ',2);
Text ('RETURN i; ',3);
Text ('END IF;  ',2);
Text ('END LOOP;  ',1);
Text ('RETURN -1; ',1);
Text ('END Get_Condition_Index_In_Cache;  ',0);

-- End Get_Condition_in_cache
-------------------------------------------------------------------------------

-- FUnction to validate Defaulting Condition
--
PUT_LINE( '       Create FUNCTION Validate_Defaulting_Condition');
Text ('FUNCTION Validate_Defaulting_Condition',0);
Parameter('condition_id   ','IN','NUMBER',0,30,TRUE);
  Parameter(LOWER(p_entity_code)||'_rec','IN',
			 l_database_object_name||'%ROWTYPE ',0);
  Text (') RETURN BOOLEAN',0);
Text ('IS  ',0);

-- CURSOR to get all the defaulting condition elements for the condition

Text ('CURSOR CONDNS IS  ',1);
Text ('SELECT condition_id,group_number,attribute_code,',1);
Text ('value_op,value_string',2);
Text ('FROM OE_DEF_CONDN_ELEMS',1);
Text ('WHERE condition_id = p_condition_id',1);
Text ('ORDER BY group_number;',1);
New_Line;
Text ('I         NUMBER;  ',1);
Text ('l_column_value          VARCHAR2(255);  ',1);
Text ('l_start_index         NUMBER;  ',1);
Text ('l_stop_index         NUMBER ;  ',1);
Text ('l_curr_group         NUMBER;  ',1);
Text ('l_group_result         BOOLEAN;  ',1);
Text ('l_element_result         BOOLEAN;  ',1);
Text ('BEGIN  ',0);
New_Line;

-- Get the condition for the first time AND cache it.

Assign ('l_start_index','Get_Condition_Index_In_Cache(p_condition_id)',1,-1);
Text ('IF (l_start_index = -1) THEN  ',0);
Text ('l_stop_index := g_conditions_tbl_cache.COUNT;  ',1);
Assign ('l_start_index','l_stop_index',1,-1);
Assign ('i','l_start_index',1,-1);
Text ('FOR condns_rec IN CONDNS LOOP  ',1);
Assign ('g_conditions_tbl_cache(i).condition_id','condns_rec.condition_id',2,-1);
Assign ('g_conditions_tbl_cache(i).group_number','condns_rec.group_number',2,-1);
Assign ('g_conditions_tbl_cache(i).attribute_code','condns_rec.attribute_code',2,-1);
Assign ('g_conditions_tbl_cache(i).value_op','condns_rec.value_op',2,-1);
Assign ('g_conditions_tbl_cache(i).value_string','condns_rec.value_string',2,-1);
Assign ('i','i+1',1,-1);
Text ('END LOOP;  ',1);
--Text ('l_stop_index := i;  ',1);


-- There is no condition, hence the condition is not valid

Text ('IF (i = l_start_index) THEN  ',0);
Text ('Return FALSE;  ',2);
Text ('END IF;  ',1);
Text ('END IF;  ',1);
New_Line;
New_Line;

-- Evaluate the condition now

Assign ('i','0',1,-1);
Assign ('l_curr_group','g_conditions_tbl_cache(l_start_index).group_number',1,-1);
Assign ('l_group_result','TRUE',1,-1);
Assign ('l_element_result','FALSE',1,-1);
New_Line;

--loop till all the conditions are done.

Text (' IF g_conditions_tbl_cache.COUNT <> 0 then  ',0);
Text ('FOR J in l_start_index ..g_conditions_tbl_cache.COUNT -1 LOOP  ',0);
Text ('IF (g_conditions_tbl_cache(j).condition_id <>  p_condition_id) THEN',1);
Text ('EXIT;',2);
Text ('END IF;',1);
New_Line;

-- Is there a group change?
-- Every group is ORed. If one group evaluates to true we can exit.

Text ('IF (l_curr_group <>  g_conditions_tbl_cache(j).group_number) THEN',1);
Text ('IF (l_group_result = TRUE) THEN',2);
Text ('EXIT;',3);
Text ('ELSE',2);
Text ('l_group_result := TRUE;',3);
Text ('END IF;',2);
Text ('END IF;',1);
New_Line;
Text ('l_element_result := '||l_app_short_name||'_Def_Util.Validate_Value(g_conditions_tbl_cache(j).value_string,',1);
Text('g_conditions_tbl_cache(j).value_op,Get_Attr_Val_Varchar2(g_conditions_tbl_cache(j).attribute_code,p_'||LOWER(p_entity_code)||'_rec ));',1);

-- IF there is no group change, the results are ANDed

Text ('l_group_result := l_group_result AND l_element_result;',2);
Text ('END LOOP;',0);
Text ('ELSE',0);
Text ('l_group_result := FALSE;',1);
Text ('END IF;',1);
Text ('RETURN l_group_result;',1);
Text ('END Validate_Defaulting_Condition;',0);
New_Line;
-------------------------------------------------------------------------------


-- Function to Update_Attr_Rules_Cache

PUT_LINE( '       Create PROCEDURE Update_Attr_Rules_Cache');
New_Line;
Text('PROCEDURE Update_Attr_Rules_Cache',0);
Text('	( p_condn_index		        IN NUMBER',0);
Text('	)',0);
Text('IS',0);
Text('l_index			NUMBER := 0;',0);
Text('l_start_index		NUMBER := 0;',0);
Text('l_attribute_code		VARCHAR2(30);',0);
Text('l_condition_id		NUMBER;',0);
Text('    CURSOR DEFSRC IS SELECT',0);
Text('    R.SEQUENCE_NO,',0);
Text('    R.SRC_TYPE,',0);
Text('    R.SRC_ATTRIBUTE_CODE,',0);
Text('    R.SRC_DATABASE_OBJECT_NAME,',0);
Text('    R.SRC_PARAMETER_NAME,',0);
Text('    R.SRC_SYSTEM_VARIABLE_EXPR,',0);
Text('    R.SRC_PROFILE_OPTION,',0);
Text('    R.SRC_API_PKG||''.''||R.SRC_API_FN SRC_API_NAME,',0);
Text('    R.SRC_CONSTANT_VALUE,',0);
Text('    R.SRC_SEQUENCE_NAME',0);
Text('    FROM OE_DEF_ATTR_DEF_RULES R, OE_DEF_ATTR_CONDNS C',0);
Text('    WHERE R.database_object_name = g_database_object_name',0);
Text('    AND R.attribute_code = l_attribute_code',0);
Text('    AND C.database_object_name = g_database_object_name',0);
Text('    AND C.attribute_code = l_attribute_code',0);
Text('    AND R.attr_def_condition_id = C.attr_def_condition_id',0);
Text('    AND C.CONDITION_ID = l_condition_id',0);
Text('    AND C.ENABLED_FLAG = ''Y''',0);
Text('    ORDER BY SEQUENCE_NO;',0);
Text('BEGIN',0);

New_Line;
Text('      l_attribute_code := g_attr_condns_cache(p_condn_index).attribute_code;',0);
Text('      l_condition_id := g_attr_condns_cache(p_condn_index).condition_id;',0);
Text('      l_start_index := g_attr_rules_cache.COUNT + 1;',0);

New_Line;
Text('    FOR DEFSRC_rec IN DEFSRC LOOP',0);
Text('	l_index := g_attr_rules_cache.COUNT + 1; ',0);
Text('	g_attr_rules_cache(l_index).SRC_TYPE ',0);
Text('			:= DEFSRC_rec.SRC_TYPE; ',0);
Text('	g_attr_rules_cache(l_index).SRC_ATTRIBUTE_CODE ',0);
Text('			:= DEFSRC_rec.SRC_ATTRIBUTE_CODE; ',0);
Text('	g_attr_rules_cache(l_index).SRC_DATABASE_OBJECT_NAME ',0);
Text('			:= DEFSRC_rec.SRC_DATABASE_OBJECT_NAME; ',0);
Text('	g_attr_rules_cache(l_index).SRC_PARAMETER_NAME ',0);
Text('			:= DEFSRC_rec.SRC_PARAMETER_NAME; ',0);
Text('	g_attr_rules_cache(l_index).SRC_SYSTEM_VARIABLE_EXPR ',0);
Text('			:= DEFSRC_rec.SRC_SYSTEM_VARIABLE_EXPR; ',0);
Text('	g_attr_rules_cache(l_index).SRC_PROFILE_OPTION',0);
Text('			:= DEFSRC_rec.SRC_PROFILE_OPTION; ',0);
Text('	g_attr_rules_cache(l_index).SRC_API_NAME',0);
Text('			:= DEFSRC_rec.SRC_API_NAME; ',0);
Text('	g_attr_rules_cache(l_index).SRC_CONSTANT_VALUE',0);
Text('			:= DEFSRC_rec.SRC_CONSTANT_VALUE; ',0);
Text('	g_attr_rules_cache(l_index).SRC_SEQUENCE_NAME',0);
Text('			:= DEFSRC_rec.SRC_SEQUENCE_NAME; ',0);
Text('   END LOOP;',0);
New_Line;

Text('   IF l_index > 0 THEN',0);
Text('	g_attr_condns_cache(p_condn_index).rules_start_index := l_start_index;',0);
Text('	g_attr_condns_cache(p_condn_index).rules_stop_index := l_index;',0);
Text('   ELSE',0);
Text('	g_attr_condns_cache(p_condn_index).rules_start_index := -1;',0);
Text('   END IF;',0);
New_Line;

Text('EXCEPTION',0);
Text('	WHEN OTHERS THEN',0);
Text('        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)',0);
Text('        THEN',0);
Text('            OE_MSG_PUB.Add_Exc_Msg',0);
Text('            (   G_PKG_NAME          ,',0);
Text('		''Update_Attr_Rules_Cache: ''||l_attribute_code',0);
Text('            );',0);
Text('        END IF;',0);
Text('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',0);
Text('END Update_Attr_Rules_Cache;',0);
New_Line;

/*-------------------------------------------------------------------------------*/
-- PROCEDURE Get_Valid_Defaulting_Rules
-- This procedure is called FROM each defaulting attribute handler function
-- to retrieve the rules associated with that attribute for the defaulting
-- conditions that are valid for the current entity record
-- The indexes of the rules in the cache are returned in the rules_start_index_Tbl
-- AND rules_stop_index_tbl

PUT_LINE( '       Create PROCEDURE Get_Valid_Defaulting_Rules');
New_Line;
Text ('PROCEDURE Get_Valid_Defaulting_Rules',0);
Parameter('attr_code   ','IN','VARCHAR2',0,30,TRUE);
Parameter('attr_id   ','IN','NUMBER',0,30,FALSE);
Parameter(LOWER(p_entity_code)||'_rec','IN',
	 l_database_object_name||'%ROWTYPE',0);
Parameter('rules_start_index_tbl   ','OUT','OE_GLOBALS.NUMBER_TBL_Type',0,30,FALSE);
Parameter('rules_stop_index_tbl   ','OUT','OE_GLOBALS.NUMBER_TBL_Type',0,30,FALSE);
Text (') IS',0);
Text('l_condn_index     			NUMBER; ',0);
Text('l_index     				NUMBER := 0; ',0);
Text('l_valid_condn_index_tbl		OE_GLOBALS.Number_TBL_Type; ',0);
Text('condns_cached				BOOLEAN := FALSE;',0);
Text('num_attr_condns			NUMBER := 0;',0);
Text('CURSOR ATTRC IS    ',0);
Text('    SELECT condition_id  ',0);
Text('    FROM OE_DEF_ATTR_CONDNS    ',0);
Text('    WHERE attribute_code = p_attr_code  ',0);
Text('      AND database_object_name = g_database_object_name  ',0);
Text('      AND enabled_flag = ''Y''',0);
Text('    ORDER BY precedence;',0);
Text('BEGIN  ',0);
New_Line;

Text('  l_condn_index := p_attr_id * ONT_Def_Util.G_MAX_ATTR_CONDNS;',0);
New_Line;

Text('  -- Check in the cache',0);
Text('  WHILE g_attr_condns_cache.EXISTS(l_condn_index) LOOP',0);
Text('    condns_cached := TRUE;',0);
Text('    IF g_attr_condns_cache(l_condn_index).conditions_defined = ''N'' THEN',0);
Text('      EXIT;',0);
Text('    ELSE',0);
Text('      IF (g_attr_condns_cache(l_condn_index).condition_id = 0 OR',0);
Text('         Validate_Defaulting_Condition',0);
Text('	       (g_attr_condns_cache(l_condn_index).condition_id,p_'
				||lower(p_entity_code)||'_rec)= TRUE) THEN ',0);
Text('	     l_index := l_index + 1;',0);
Text('	     l_valid_condn_index_tbl(l_index) := l_condn_index;',0);
Text('      END IF;',0);
Text('    END IF;',0);
Text('    l_condn_index := l_condn_index + 1;',0);
Text('  END LOOP;',0);
New_Line;

Text('  -- If the conditions were cached for this attribute, ',0);
Text('  -- then return rules for valid conditions',0);
Text('  IF condns_cached THEN',0);
New_Line;
Text('      GOTO Return_Rules;',0);
New_Line;
Text('  -- If the conditions were NOT cached for this attribute,',0);
Text('  -- then cache them AND get the conditions that are valid',0);
Text('  -- for the current record',0);
Text('  ELSE',0);
Text('    FOR c_rec IN ATTRC LOOP  ',0);
Text('      -- Put it in the cache',0);
Text('      g_attr_condns_cache(l_condn_index).attribute_code',0);
Text('        := p_attr_code;',0);
Text('      g_attr_condns_cache(l_condn_index).condition_id',0);
Text('        := c_rec.condition_id;',0);
Text('      g_attr_condns_cache(l_condn_index).conditions_defined',0);
Text('        := ''Y'';',0);
Text('	  IF (c_rec.condition_id = 0 OR',0);
Text('	         Validate_Defaulting_Condition',0);
Text('		  (c_rec.condition_id,p_'||lower(p_entity_code)||'_rec)= TRUE) THEN ',0);
Text('	     l_index := l_index + 1;',0);
Text('	     l_valid_condn_index_tbl(l_index) := l_condn_index;',0);
Text('      END IF;',0);
Text('      l_condn_index := l_condn_index + 1;',0);
Text('      num_attr_condns := num_attr_condns + 1;',0);
Text('    END LOOP;',0);
New_Line;

Text('    -- No defaulting conditions defined for this attribute,',0);
Text('    -- insert a new record in the cache with conditions_defined = ''N''',0);
Text('    IF num_attr_condns = 0 THEN',0);
Text('      g_attr_condns_cache(l_condn_index).attribute_code',0);
Text('        := p_attr_code;',0);
Text('      g_attr_condns_cache(l_condn_index).conditions_defined',0);
Text('        := ''N'';',0);
Text('    END IF;',0);
New_Line;

Text('  END IF;',0);
New_Line;

Text('  <<Return_Rules>>',0);
Text('FOR I IN 1..l_index LOOP',0);
-- Cache the rules if not already cached for this condition
Text('  IF g_attr_condns_cache(l_valid_condn_index_tbl(I)).rules_start_index IS NULL THEN',0);
Text('     Update_Attr_Rules_Cache(l_valid_condn_index_tbl(I));',0);
Text('  END IF;',0);
-- Populate rules for this condition
Text('  x_rules_start_index_tbl(I) := g_attr_condns_cache(l_valid_condn_index_tbl(I)).rules_start_index;',0);
Text('  x_rules_stop_index_tbl(I) := g_attr_condns_cache(l_valid_condn_index_tbl(I)).rules_stop_index;',0);
Text('END LOOP;',0);
New_Line;

Text('EXCEPTION',0);
Text('	WHEN OTHERS THEN',0);
Text('        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)',0);
Text('        THEN',0);
Text('            OE_MSG_PUB.Add_Exc_Msg',0);
Text('            (   G_PKG_NAME          ,',0);
Text('		''Get_Valid_Defaulting_Rules :''||p_attr_code',0);
Text('            );',0);
Text('        END IF;',0);
Text('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;',0);
Text('END Get_Valid_Defaulting_Rules;',0);
New_Line;
New_Line;

<<END_OF_BODY>>

Pkg_End(l_pkg_name,'BODY');

END Create_Entity_Def_Util_handler;


--------------------------------------------------------------------
PROCEDURE Create_OE_Def_Hdlr
(
 p_application_id	IN	VARCHAR2 ,
 p_database_object_name	IN	VARCHAR2 ,
 p_entity_code  	IN	VARCHAR2
)
IS

-- Table declarations
TYPE obj_attr_tbl_type IS TABLE OF OE_DEF_AK_ATTR_EXT_V%ROWTYPE
INDEX BY BINARY_INTEGER;
l_data_attr_tbl         obj_attr_tbl_type;

-- variable declarations

l_entity_code		VARCHAR2(15);
l_app_short_name		VARCHAR2(3);
l_pkg_name		VARCHAR2(30);
l_attribute_code	VARCHAR2(30);
l_column_name		VARCHAR2(30);
l_database_object_name		VARCHAR2(30);
J			NUMBER;

CURSOR APP
is
	SELECT substr(rtrim(APPLICATION_SHORT_NAME),1,3)
	FROM fnd_application
	WHERE application_id = p_application_id;

CURSOR OASS(p_database_object_name varchar2)
is
	SELECT oeatt.attribute_code, akatt.column_name
	FROM OE_AK_OBJ_ATTR_EXT oeatt
		, AK_OBJECT_ATTRIBUTES akatt
	WHERE oeatt.database_object_name  = p_database_object_name
	AND oeatt.attribute_application_id=p_application_id
	AND oeatt.attribute_code = akatt.attribute_code
	AND oeatt.database_object_name = akatt.database_object_name
        AND oeatt.attribute_application_id= akatt.attribute_application_id
	ORDER BY akatt.column_name;
--        AND NVL(data_storage_type,OE_DEF_UTIL.NONE)='3RD NORMAL';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  OPEN APP;
  FETCH APP INTO l_app_short_name;
  CLOSE APP;

l_database_object_name := p_database_object_name;
-- Generate the util package
  l_pkg_name := 'OE_Default_'||INITCAP(p_entity_code);

PUT_LINE( 'Create OE entity defaulting package ' ||l_pkg_name);


 -- Write out the header to the Spec file.

  Pkg_Header( p_pkg_name     =>  l_pkg_name,
			p_pkg_type	=>  'SPEC');

--
  Text ('PROCEDURE Attributes',0);
  Parameter(INITCAP(p_entity_code)||'_rec','IN',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30,TRUE);
  Parameter('old_'||INITCAP(p_entity_code)||'_rec','IN',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30);
  Parameter('itteration   ','IN','NUMBER := 1',0,30);
  Parameter(INITCAP(p_entity_code)||'_rec','OUT',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30);
  Text (') ;',0);

  New_Line;

  Text ('PROCEDURE Copy_API_Rec_To_Rowtype_Rec',0);
  Parameter('api_rec','IN',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30,TRUE);
  Parameter('rowtype_rec','OUT',
			 l_database_object_name||'%ROWTYPE ',0,30);
  Text (') ;',0);
  New_Line;
  Text ('PROCEDURE Copy_Rowtype_Rec_To_API_Rec',0);
  Parameter('rowtype_rec','IN',
			 l_database_object_name||'%ROWTYPE ',0,30,TRUE);
  Parameter('api_rec','OUT',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30);
  Text (') ;',0);

  Pkg_End( p_pkg_name     =>  l_pkg_name,
			p_pkg_type	=>  'SPEC');


  Pkg_Header( p_pkg_name     =>  l_pkg_name,
			p_pkg_type	=>  'BODY');

  Text ('PROCEDURE Attributes',0);
  Parameter(INITCAP(p_entity_code)||'_rec','IN',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30,TRUE);
  Parameter('old_'||INITCAP(p_entity_code)||'_rec','IN',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30);
  Parameter('itteration   ','IN','NUMBER := 1',0,30);
  Parameter(INITCAP(p_entity_code)||'_rec','OUT',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30);
  Text (') ',0);

  New_Line;
Text ('IS  ',0);
Text ('l_in_rec     '||p_database_object_name||'%ROWTYPE;',1);
Text ('l_in_old_rec     '||p_database_object_name||'%ROWTYPE;',1);
Text ('l_out_rec     '||p_database_object_name||'%ROWTYPE;',1);
Text ('BEGIN  ',0);
Comment ('Due to incompatibilities in the record type structure',0);
Comment ('copy the data to a rowtype record format',0);
Text (' Copy_API_Rec_To_Rowtype_Rec(p_api_rec => p_'||LOWER(p_entity_code)||'_rec,',2);
Text (' x_rowtype_rec => l_in_rec);',4);
Text (' Copy_API_Rec_To_Rowtype_Rec(p_api_rec => p_old_'||LOWER(p_entity_code)||'_rec,',2);
Text (' x_rowtype_rec => l_in_old_rec);',4);
Text (' x_'||lower(p_entity_code)||'_rec := p_'||lower(p_entity_code)||'_rec;',2);
Comment ('call the default handler framework to default the missing attributes',0);
Text (l_app_short_name||'_'||p_entity_code||'_Def_Hdlr.Default_Record(l_in_rec, l_in_old_rec, p_itteration,l_out_rec);',2);
Comment ('copy the data back to a format that is compatible with the API architecture',0);
Text ('Copy_RowType_Rec_to_API_Rec(l_out_rec,x_'||LOWER(p_entity_code)||'_rec);',2);
Text ('x_'||LOWER(p_entity_code)||'_rec.db_flag := p_'||LOWER(p_entity_code)||'_rec.db_flag;',0);
Text ('x_'||LOWER(p_entity_code)||'_rec.return_status := p_'||LOWER(p_entity_code)||'_rec.return_status;',0);
Text ('x_'||LOWER(p_entity_code)||'_rec.operation := p_'||LOWER(p_entity_code)||'_rec.operation;',0);
Text ('return;',2);
Text ('End Attributes;',0);
  New_Line;
  New_Line;


Comment ('Procedure to copy the data to a rowtype record format so that we can call the Default handler package.',0);
  Text ('PROCEDURE Copy_API_Rec_To_Rowtype_Rec',0);
  Parameter('api_rec','IN',
			 'OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30,TRUE);
  Parameter('rowtype_rec','OUT',
			 p_database_object_name||'%ROWTYPE ',0,30);
  Text (') ',0);

  New_Line;
Text ('IS  ',0);
Text ('BEGIN  ',0);


j :=0;

FOR l_attr_rec in OASS(p_database_object_name )
 LOOP

l_data_attr_tbl(j).attribute_code := l_attr_rec.attribute_code;
l_data_attr_tbl(j).column_name := l_attr_rec.column_name;

j := j+1;

END LOOP;

FOR J IN 0..l_data_attr_tbl.COUNT -1 LOOP

l_attribute_code := l_data_attr_tbl(j).attribute_code ;
l_column_name := l_data_attr_tbl(j).column_name ;

Text ('x_rowtype_rec.'||l_column_name||'  := p_api_rec.'||l_column_name||';',1);

END LOOP;
Text ('END Copy_API_Rec_To_Rowtype_Rec;',0);
  New_Line;
  New_Line;


  Text ('PROCEDURE Copy_Rowtype_Rec_To_API_Rec',0);
  Parameter('rowtype_rec','IN',
			 p_database_object_name||'%ROWTYPE ',0,30,TRUE);
  Parameter('api_rec',' OUT',
			 ' OE_Order_PUB.'||INITCAP(p_entity_code)||'_Rec_Type ',0,30);
  Text (') ',0);

  New_Line;
Text ('IS  ',0);
Text ('BEGIN  ',0);


j :=0;


FOR J IN 0..l_data_attr_tbl.COUNT -1 LOOP

l_attribute_code := l_data_attr_tbl(j).attribute_code ;
l_column_name := l_data_attr_tbl(j).column_name ;

Text ('x_api_rec.'||l_column_name||'  := p_rowtype_rec.'||l_column_name||';',1);

END LOOP;
Text ('END Copy_Rowtype_Rec_To_API_Rec;',0);
New_Line;

Pkg_End( p_pkg_name     =>  l_pkg_name,
		p_pkg_type	=>  'BODY');

PUT_LINE( 'Created '||l_pkg_name||' successfully');

EXCEPTION

  WHEN OTHERS THEN
	PUT_LINE( 'ERROR when creating '||l_pkg_name||' :'||sqlerrm);

END Create_OE_Def_Hdlr ;

END OE_Defaulting_Fwk_PUB;

/
