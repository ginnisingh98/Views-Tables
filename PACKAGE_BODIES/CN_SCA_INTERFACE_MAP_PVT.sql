--------------------------------------------------------
--  DDL for Package Body CN_SCA_INTERFACE_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_INTERFACE_MAP_PVT" AS
-- $Header: cnvmpgnb.pls 120.3.12010000.2 2009/01/29 08:27:56 gmarwah ship $

PROCEDURE get_min ( p_min IN OUT NOCOPY number, p_max number) IS
BEGIN
   IF p_min =0 and p_max <> 0
   THEN
      p_min := p_max;
   ELSIF p_min <> 0 and p_max <> 0
   THEN
      IF p_min > p_max
      THEN
         p_min := p_max;
      END IF;
   END IF;
END;

-- search the next occurence of delimiter '+ - * / ( ) ' in sql_select portion and return the position
FUNCTION search_delimiter_select ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min		NUMBER ;
     l_position    		NUMBER;
BEGIN
   l_position_min := instr( p_input_str, '*', p_start) ;
   l_position := instr(p_input_str, '-', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '+', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '/', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '(', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, ')', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, ',', p_start);
   get_min(l_position_min, l_position);

   return l_position_min;
END;


-- search the next occurence of delimiter ', ' in sql_from portion and return the position
FUNCTION search_delimiter_from ( p_input_str varchar2, p_start  number) RETURN
  NUMBER IS
     l_position_min        NUMBER :=0;
     l_position          	NUMBER;
BEGIN
   l_position := instr(p_input_str, ',', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END;

-- search the next occurence of delimiter 'and ' in sql_where portion and return the position
FUNCTION search_delimiter_where ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min        NUMBER :=0;
     l_position         	NUMBER;
BEGIN
   l_position := instr(p_input_str, 'and', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END;

-- search the next occurence of delimiter empty space in COMMENT and return the position
FUNCTION search_delimiter_comment ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min     NUMBER :=0;
     l_position         NUMBER;
BEGIN
   l_position := instr(p_input_str, ' ', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END search_delimiter_comment ;

PROCEDURE split_long_sql ( body_code        IN OUT NOCOPY cn_utils.code_type,
                           p_input_str      VARCHAR2  ,
                           sql_type   VARCHAR2) --,
--                           p_org_id   IN NUMBER        ) -- MOAC Change
  IS
     l_length 		NUMBER;    	/* total length of input string */
     l_start  		NUMBER;    	/* the start position of current split */
     l_next   		NUMBER;    	/* position of next delimiter */
     l_next_prev 	NUMBER; 		/* position of previous delimiter */
     l_limit  		NUMBER;    	/* the upper boundary of current split */

     l_sql_segment_length NUMBER := 80;
BEGIN

   DBMS_APPLICATION_INFO.SET_ACTION('inside SPLIT LONG ' );

   -- Set org Id for CN_UTILS package
 --  cn_utils.set_org_id( p_org_id ); -- MOAC Change

   l_start := 1;
   l_limit := l_start + l_sql_segment_length;

   l_length := Length(p_input_str);
   l_next := l_start;
   l_next_prev := l_start;

   WHILE l_limit < l_length
   LOOP
      WHILE l_next < l_limit
      LOOP

       /* the postion of l_next delimiter is not beyong the upper boudary yet  */

         l_next_prev := l_next;

         IF sql_type = 'SELECT'
         THEN
            l_next := search_delimiter_select(p_input_str, l_next_prev+1 );
         ELSIF sql_type = 'FROM'
         THEN
            l_next := NVL(search_delimiter_from(p_input_str, l_next_prev+1 ),0);
         ELSIF sql_type = 'WHERE'
         THEN
            l_next := search_delimiter_where(p_input_str, l_next_prev+1 );
         ELSIF sql_type = 'COMMENT'
         THEN
            l_next := search_delimiter_comment(p_input_str, l_next_prev+1 );
         END IF;

         IF l_next = 0
         THEN  /* no more delimiter */
            EXIT;
         END IF;

         IF l_next >= l_limit
         THEN
           l_next_prev := l_next;
         END IF;


      END LOOP;

      IF sql_type = 'COMMENT'
      THEN
         cn_utils.appindcr(body_code, '-- ' || substr(p_input_str, l_start,
                           l_next_prev -  l_start) );
      ELSE
         cn_utils.appindcr(body_code, substr(p_input_str, l_start,
                                             l_next_prev - l_start));
      END IF;

      l_start := l_next_prev ;
      l_limit := l_start + l_sql_segment_length;

      IF l_next = 0
      THEN  /* no more delimiter */
         EXIT;
      END IF;
   END LOOP;

   IF sql_type = 'COMMENT'
   THEN
      cn_utils.appindcr(body_code, '--' || substr(p_input_str, l_start,
                        l_length -  l_start  + 1));
   ELSE
      cn_utils.appindcr(body_code, substr(p_input_str, l_start,
                                          l_length - l_start  + 1));
   END IF;

   -- Unset org_id in CN_UTILS package
--   cn_utils.unset_org_id( );   -- MOAC Change
END split_long_sql;


PROCEDURE pkg_init_boilerplate (
	code		     	IN OUT NOCOPY cn_utils.code_type,
	package_name	IN cn_obj_packages_v.name%TYPE,
	description		IN cn_obj_packages_v.description%TYPE,
	object_type		IN VARCHAR2) --,
--        p_org_id                IN NUMBER) -- MOAC Change
IS
	x_userid		VARCHAR2(20);
BEGIN
	SELECT  user
	INTO    x_userid
	FROM    sys.dual;

        -- Set org id in cn_utils package
--        cn_utils.set_org_id( p_org_id );  -- MOAC Change

	cn_utils.appendcr(code, '--+============================================================================+');
	cn_utils.appendcr(code, '--    		       Copyright (c) 1993 Oracle Corporation');
	cn_utils.appendcr(code, '--		             Redwood Shores, California, USA');
	cn_utils.appendcr(code, '--			               All rights reserved.');
	cn_utils.appendcr(code, '--+============================================================================+');
	cn_utils.appendcr(code, '-- Package Name');
	cn_utils.appendcr(code, '--   '||package_name);
	cn_utils.appendcr(code, '-- Purpose');
	cn_utils.appendcr(code, '--   '||description);
	cn_utils.appendcr(code, '-- History');
	cn_utils.appendcr(code, '--   '||SYSDATE||'          '||x_userid ||'            Created');
	cn_utils.appendcr(code, '--+============================================================================+');

	----+
	-- Check For Package type, based on PKS(spec) or PKB(body) generate init section
	-- Of your code accordingly
	----+
	IF (object_type = 'PKS')
	THEN
		cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE ' ||package_name||' AS');
	ELSE
		cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY ' ||package_name||' AS');
	END IF;

	cn_utils.appendcr(code);

        -- Unset org id in cn_utils package
--        cn_utils.unset_org_id(); -- MOAC Change
END pkg_init_boilerplate;

PROCEDURE check_create_object(
	p_init_msg_list    	IN  	VARCHAR2 := FND_API.G_FALSE,
  	p_commit           	IN  	VARCHAR2 := FND_API.G_FALSE,
  	p_validation_level 	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	p_name             	IN  	cn_objects.name%TYPE,
	p_object_type      	IN  	cn_objects.object_type%TYPE,
	p_object_id        	IN  	OUT NOCOPY cn_objects.object_id%TYPE,
	p_repository_id    	IN  	cn_repositories.repository_id%TYPE,
        p_org_id                IN      cn_repositories.org_id%TYPE, -- MOAC Change
	x_return_status    	OUT 	NOCOPY  VARCHAR2,
	x_msg_count        	OUT 	NOCOPY  NUMBER,
	x_msg_data         	OUT 	NOCOPY  VARCHAR2)
IS
	dummy      NUMBER;
	x_rowid    ROWID;

BEGIN

	SAVEPOINT check_create_object;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
	  FND_MSG_PUB.initialize;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

------+
-- check whether Mapping Package exist in cn_objects
------+

	SELECT  COUNT(*)
	INTO   	dummy
	FROM   	cn_objects
	WHERE  	name = P_NAME
	AND    	object_type = P_OBJECT_TYPE
        AND     org_id = p_org_id;   -- MOAC Change

	IF dummy = 0
	THEN
		P_OBJECT_ID := cn_utils.get_object_id;

		cn_objects_pkg.insert_row(
                        x_org_id                    => p_org_id,  -- MOAC Change
			x_rowid                     => x_rowid,
			x_object_id                 => p_object_id,
			x_dependency_map_complete   => 'n',
			x_name                      => p_name,
			x_description               => null,
			x_object_type               => p_object_type,
			x_repository_id             => p_repository_id,
			x_next_synchronization_date => NULL,
			x_synchronization_frequency => NULL,
			x_object_status             => 'a',
			x_object_value              => NULL );

	ELSIF dummy = 1
	THEN
		SELECT  object_id
      INTO    P_OBJECT_ID
		FROM    cn_objects
		WHERE   name        = P_NAME
		AND     object_type = P_OBJECT_TYPE
                AND     org_id      = p_org_id;  -- MOAC Change
	END IF;

	FND_MSG_PUB.Count_And_Get
		 (p_count	 =>	x_msg_count,
		  p_data     =>	x_msg_data,
		  p_encoded  =>	FND_API.G_FALSE);

EXCEPTION

WHEN FND_API.G_EXC_ERROR
THEN
	ROLLBACK TO check_create_object;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Add_Exc_Msg( P_NAME ,'check_create_object' );
	FND_MSG_PUB.Count_And_Get
			 (p_count	 =>	x_msg_count,
			  p_data     =>	x_msg_data,
			  p_encoded  =>	FND_API.G_FALSE);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
	ROLLBACK TO check_create_object;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Add_Exc_Msg( P_NAME ,'check_create_object' );
	FND_MSG_PUB.Count_And_Get
			 (p_count	 =>	x_msg_count,
			  p_data     =>	x_msg_data,
			  p_encoded  =>	FND_API.G_FALSE);
WHEN OTHERS THEN
	ROLLBACK TO check_create_object;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	FND_MSG_PUB.ADD_EXC_MSG( P_NAME ,'check_create_object');

	FND_MSG_PUB.Count_And_Get
		 (p_count	 =>	x_msg_count,
		  p_data     =>	x_msg_data,
		  p_encoded  =>	FND_API.G_FALSE);


END check_create_object;

PROCEDURE pkg_init (
	module_id		    cn_modules.module_id%TYPE,
    package_name		    cn_obj_packages_v.name%TYPE,
    package_spec_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
    package_body_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
    package_spec_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
    package_body_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
    spec_code	    		IN OUT NOCOPY  cn_utils.code_type,
    body_code	    		IN OUT NOCOPY  cn_utils.code_type,
    p_org_id                    IN NUMBER) IS -- MOAC Change

    x_rowid			ROWID;
    null_id			NUMBER;

BEGIN
        -- Set org_id in cn_utils
--        cn_utils.set_org_id( p_org_id ); -- MOAC Change

	-- Find the package objects
	cn_utils.find_object(package_name,'PKS',package_spec_id, package_spec_desc, p_org_id); -- MOAC Change
	cn_utils.find_object(package_name,'PKB',package_body_id, package_body_desc, p_org_id); -- MOAC Change

	-- Delete module source code from cn_source
	-- Delete module object dependencies for this module
	cn_utils.delete_module(module_id, package_spec_id, package_body_id, p_org_id); -- MOAC Change

	cn_utils.init_code (package_spec_id, spec_code);
	cn_utils.init_code (package_body_id, body_code);

	pkg_init_boilerplate(spec_code, package_name, package_spec_desc, 'PKS');
	pkg_init_boilerplate(body_code, package_name, package_body_desc, 'PKB');

	cn_utils.indent(spec_code, 1);
	cn_utils.indent(body_code, 1);

        -- Unset org id in cn_utils
--        cn_utils.unset_org_id(); -- MOAC Change
END pkg_init;

PROCEDURE install_package_object(
	p_object_name 			IN VARCHAR2,
        p_org_id                        IN cn_objects.org_id%TYPE,  -- MOAC Change
	x_compile_status 		OUT NOCOPY  VARCHAR2,
	x_return_status    	OUT NOCOPY  VARCHAR2,
    x_msg_count        	OUT NOCOPY  NUMBER,
    x_msg_data         	OUT NOCOPY  VARCHAR2)
IS
	l_user_id  		 		NUMBER(15) 		:= fnd_global.user_id;
	l_login_id 				NUMBER(15) 		:= fnd_global.login_id;
	l_object_name       	VARCHAR2(80) 	:= p_object_name;
	l_line_length       	NUMBER;
	l_send_position     	NUMBER;
	l_pkg_object_id     	NUMBER;
	l_sqlstring 	    	dbms_sql.varchar2s;
	l_empty_sqlstring   	dbms_sql.varchar2s;
	i 		            	INTEGER;
	j		            	INTEGER;
	l_cur 	  	        	INTEGER;
	l_new_line_flag     	BOOLEAN := TRUE;
	l_retval 	        	NUMBER;
	l_error_count       	NUMBER;



BEGIN

	SAVEPOINT install_package_object;
----+
-- Get Object id of the package Body
----+
	SELECT	object_id
	INTO 		l_pkg_object_id
	FROM 		cn_objects
	WHERE 	UPPER(name) =  UPPER(p_object_name)
	AND 	object_type = 'PKS'
        AND     org_id = p_org_id;  -- MOAC Change
----+
-- Store The Code For Package Specification in l_sqlstring
----+
	SELECT	text BULK COLLECT
	INTO 	 	l_sqlstring
	FROM 	 	cn_source
	WHERE 	object_id = l_pkg_object_id
        AND     org_id = p_org_id -- MOAC Change
	ORDER BY source_id;
----+--+
-- Compile Package Specification
------+
	i := 1;

	j := l_sqlstring.count;

	l_cur:= DBMS_SQL.OPEN_CURSOR;

	DBMS_SQL.PARSE(l_cur, l_sqlstring, i, j, l_new_line_flag, DBMS_SQL.V7);

	l_retval:= DBMS_SQL.EXECUTE(l_cur);

	DBMS_SQL.CLOSE_CURSOR(l_cur);

	l_sqlstring := l_empty_sqlstring;
	------+
	-- Get Object id of the package Body
	------+
	SELECT	object_id
	INTO 		l_pkg_object_id
	FROM 		cn_objects
	WHERE 	UPPER(name) =  UPPER(p_object_name)
	AND 		object_type = 'PKB'
        AND     org_id = p_org_id; -- MOAC Change
------+
-- Store The Code For Package Body in l_sqlstring
------+
	SELECT	text BULK COLLECT
	INTO 	 	l_sqlstring
	FROM 	 	cn_source
	WHERE 	object_id = l_pkg_object_id
        AND     org_id = p_org_id  -- MOAC Change
	ORDER BY source_id;
------+
-- Compile Package Body
------+
	i := 1;

	j := l_sqlstring.count;

	l_cur := DBMS_SQL.OPEN_CURSOR;

	DBMS_SQL.PARSE(l_cur, l_sqlstring, i, j, l_new_line_flag, DBMS_SQL.V7);

	l_retval:= DBMS_SQL.EXECUTE(l_cur);

	DBMS_SQL.CLOSE_CURSOR(l_cur);

	l_sqlstring := l_empty_sqlstring;
	------+
	-- Check Whether Package Compiled Successfully
	------+
	SELECT  COUNT(ROWNUM)
	INTO    l_error_count
	FROM    user_errors
	WHERE   name = p_object_name
	AND     type IN ('PACKAGE', 'PACKAGE BODY');


	IF (l_error_count > 0)
	THEN
		x_compile_status := 'INCOMPLETE';
	ELSE
		x_compile_status := 'COMPLETE';
	END IF;

	FND_MSG_PUB.Count_And_Get
		 (p_count	 =>	x_msg_count,
		  p_data     =>	x_msg_data,
		  p_encoded  =>	FND_API.G_FALSE);

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
	ROLLBACK TO install_package_object;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_compile_status := 'INCOMPLETE';
	FND_MSG_PUB.Count_And_Get
    	(p_count    =>  x_msg_count,
	 	 p_data     =>  x_msg_data);
WHEN OTHERS
THEN
	ROLLBACK TO install_package_object;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_compile_status := 'INCOMPLETE';
	FND_MSG_PUB.Count_And_Get
    	(p_count    =>  x_msg_count,
	 	 p_data     =>  x_msg_data);
END install_package_object;

PROCEDURE GENERATE (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 := fnd_api.g_false,
    p_commit            IN VARCHAR2 := fnd_api.g_false,
    p_validation_level  IN VARCHAR2 := fnd_api.g_valid_level_full,
    p_org_id            IN NUMBER, -- MOAC Change
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2)
AS
	l_module_id	        cn_modules.module_id%TYPE;
	l_object_id         cn_objects.object_id%TYPE;
	l_org_id            VARCHAR2(5);
	l_pkg_spec_id       cn_obj_packages_v.package_id%TYPE;
	l_pkg_body_id       cn_obj_packages_v.package_id%TYPE;
	l_spec_code         cn_utils.code_type;
	l_body_code         cn_utils.code_type;
	l_pkg_spec_desc     cn_obj_packages_v.description%TYPE;
	l_pkg_body_desc     cn_obj_packages_v.description%TYPE;
	l_pkg_name          cn_obj_packages_v.NAME%TYPE;
	l_creation_status   BOOLEAN;
	l_user              VARCHAR2(15);
	l_repository_id     cn_repositories.repository_id%TYPE;

	l_api_name	        CONSTANT VARCHAR2(10) := 'MAP';
	l_api_version       CONSTANT NUMBER       := 1.0;
	l_user_id  	        NUMBER(15)  := fnd_global.user_id;
	l_login_id 	        NUMBER(15)  := fnd_global.login_id;

	l_init_msg_list		VARCHAR2(5) := fnd_api.g_false;
	l_commit					VARCHAR2(5) := fnd_api.g_false;
	l_validation_level	NUMBER 		:= fnd_api.g_valid_level_full;

	l_return_status     VARCHAR2(20);
	l_compile_status    VARCHAR2(20);
	l_msg_count         NUMBER;
	l_msg_data          VARCHAR2(2000);

------++
-- For Compiled Dynamic Generated Mapping Package Status
------++
--	l_compile_status 	VARCHAR2(20);
------++
-- Variables for CN_SCA_HEADERS_INTERFACE.SCA_TRX_TYPE
------++
	l_trx_type   cn_sca_headers_interface.source_type%TYPE;
------++
-- FOR CN_SCA_HEADERS_INTERFACE.TRANSACTION_SOURCE
------++
	l_trx_source   	VARCHAR2(10) := '''CN''';
------++
-- List of arguments for MAP API.
------++
	l_proc_arg1    VARCHAR2(60) := '    p_sca_process_batch_id  IN NUMBER';
	l_proc_arg2    VARCHAR2(60) := '    p_start_date            IN DATE';
	l_proc_arg3    VARCHAR2(60) := '    p_end_date              IN DATE';
	l_proc_arg4    VARCHAR2(65) := '    p_api_version           IN NUMBER';
	l_proc_arg5    VARCHAR2(60) := '    p_init_msg_list         IN VARCHAR2 := fnd_api.g_false';
	l_proc_arg6    VARCHAR2(60) := '    p_commit                IN VARCHAR2 := fnd_api.g_false';
	l_proc_arg7    VARCHAR2(80) := '    p_validation_level      IN NUMBER   := fnd_api.g_valid_level_full';
	l_proc_arg8    VARCHAR2(60) := '    p_org_id                IN NUMBER';
	l_proc_arg9    VARCHAR2(60) := '    x_return_status         OUT NOCOPY VARCHAR2';
	l_proc_arg10   VARCHAR2(60) := '    x_msg_count             OUT NOCOPY NUMBER';
	l_proc_arg11   VARCHAR2(60) := '    x_msg_data              OUT NOCOPY VARCHAR2';
------++
-- Variable declaration for few loop counters
------++
	l_loop_cntr1    INTEGER := 0;
	l_loop_cntr2    INTEGER := 1;
	l_loop_cntr3    INTEGER := 1;
------++
-- PL/SQL Table type and Variable declaration for
-- CN_SCA_RULE_ATTRIBUTES.SRC_COLUMN_NAME
------++
	TYPE src_column_name
	IS   TABLE OF VARCHAR2(4000)
	INDEX BY BINARY_INTEGER;
	l_src_column_name src_column_name;
------++
-- PL/SQL Table type and Variable declaration for
-- CN_SCA_RULE_ATTRIBUTES.TRX_SRC_COLUMN_NAME
------++
	TYPE trx_src_column_name
	IS TABLE OF VARCHAR2(4000)
	INDEX BY BINARY_INTEGER;
	l_trx_src_column_name trx_src_column_name;
------++
-- Cursor and Variable declaration to get SOURCE and
-- TRANSACTION SOURCE Mapping column names from CN_SCA_RULE_ATTRIBUTES
------++
	CURSOR 	cn_sca_rule_attr_cur
	IS
	SELECT 	sca_rule_attribute_id,
			 	LOWER(src_column_name) src_column_name,
			 	LOWER(user_column_name) user_column_name,
			 	LOWER(trx_src_column_name) trx_src_column_name
	FROM   	cn_sca_rule_attributes
	WHERE  	transaction_source = 'CN'
        AND     org_id = p_org_id  -- MOAC Change
	ORDER BY src_column_name;

	cnracv  	cn_sca_rule_attr_cur%ROWTYPE;
BEGIN

	SAVEPOINT generate_map_package;
------++
-- Initialize message list if p_init_msg_list is set to TRUE.
------++
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
------++
-- Initialize API return status to success
------++
	x_return_status := FND_API.G_RET_STS_SUCCESS;
------++
-- Get Values for repository_id and org_id
------++
	SELECT  repository_id, org_id
	INTO    l_repository_id, l_org_id
	FROM    cn_repositories
       WHERE    org_id = p_org_id;   -- MOAC Change
------++
-- Get Value For module_id
------++
	SELECT  module_id
	INTO    l_module_id
	FROM    cn_modules
	WHERE   NAME = 'Collection'
          AND   org_id = p_org_id;  -- MOAC Change
------++
-- Get Vaule For module_id
------++
	SELECT  USER
	INTO    l_user
	FROM    dual;
------++
-- Process cn_sca_rule_attr_cur to get values for runtime call to
-- INSERT INTO SCA HEADERS AS SELECT FROM OIC API
------++
------++
-- Append ORG_ID to the dynamic package name
------++
	l_pkg_name := 'CN_SCA_MAP_CN_'||l_org_id;


	FOR cnracv
	IN cn_sca_rule_attr_cur
	LOOP
		IF NOT cn_sca_rule_attr_cur%NOTFOUND
		THEN
			l_loop_cntr1 := l_loop_cntr1 + 1;
			l_src_column_name(l_loop_cntr1) := cnracv.src_column_name;
			l_trx_src_column_name(l_loop_cntr1) := cnracv.trx_src_column_name;
		ELSE
			x_return_status := fnd_api.g_ret_sts_error;
			FND_MESSAGE.SET_NAME('CN','CN_SCA_NO_ATTR_MAP');
	 		FND_MSG_PUB.Add_Exc_Msg( 'CN_SCA_INTERFACE_MAP_PVT' ,'GENERATE');
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	END LOOP;
------++
-- Loop to convert src_column_name values in comma seperated row format
------++
	FOR l_loop_cntr2
	IN 2..l_src_column_name.COUNT
	LOOP
	   l_src_column_name(l_loop_cntr3) :=
			l_src_column_name(l_loop_cntr3)||','||l_src_column_name(l_loop_cntr2);

	END LOOP;
------++
-- Loop to convert trx_src_column_name values in comma seperated row format
------++
	FOR l_loop_cntr2
	IN 2..l_trx_src_column_name.COUNT
	LOOP
		l_trx_src_column_name(l_loop_cntr3) :=
			l_trx_src_column_name(l_loop_cntr3)||','||l_trx_src_column_name(l_loop_cntr2);
	END LOOP;
------++
-- Dynamic Package Generation Code Starts Here
-- Call Check Create Object to Check whether Mappong Package Spec Already Exists
-- If it exists It will use the same object Id or create a new object using the
-- parameter values provided
-- This is For Package Specification.
------++

--++ Set org_id for cn_utils package
cn_utils.set_org_id( p_org_id );

	check_create_object(
			p_init_msg_list		=> l_init_msg_list,
			p_commit					=> l_commit,
			p_validation_level 	=> l_validation_level,
			p_name         		=> l_pkg_name,
			p_object_type 			=> 'PKS',
			p_object_id     		=> l_object_id,
			p_repository_id		=> l_repository_id,
                        p_org_id                => p_org_id, -- MOAC Change
			x_return_status 		=> l_return_status,
			x_msg_count				=> l_msg_count,
			x_msg_data				=> l_msg_data);

------++
-- Store Package Spec Id in l_pkg_spec_id
------++
	l_pkg_spec_id :=  l_object_id;
------++
-- This is For Package Body
------++
	check_create_object(
			p_init_msg_list		=> l_init_msg_list,
			p_commit					=> l_commit,
			p_validation_level 	=> l_validation_level,
			p_name         		=> l_pkg_name,
			p_object_type 			=> 'PKB',
			p_object_id     		=> l_object_id,
			p_repository_id		=> l_repository_id,
                        p_org_id                => p_org_id, -- MOAC Change
			x_return_status 		=> l_return_status,
			x_msg_count				=> l_msg_count,
			x_msg_data				=> l_msg_data);
------++
-- Store Package Body Id in l_pkg_spec_id
------++
	l_pkg_body_id :=  l_object_id;
------++
-- Assign Value to l_pkg_spec_desc and l_pkg_body_desc
------++
	l_pkg_spec_desc := 'Package Specification For SCA Interface Mapping Package';
	l_pkg_body_desc := 'Package Body For SCA Interface Mapping Package';
------++
-- Call cn_utils.pkg_init to create a new package and do initialization
------++
	pkg_init(
			module_id	        =>  l_module_id,
			package_name	     =>  l_pkg_name,
			package_spec_id     =>  l_pkg_spec_id,
			package_body_id     =>  l_pkg_body_id,
			package_spec_desc   =>  l_pkg_spec_desc,
			package_body_desc   =>  l_pkg_body_desc,
			spec_code	        =>  l_spec_code,
			body_code           =>  l_body_code,
                        p_org_id            =>  p_org_id);  -- MOAC Change
------++
-- Call cn_utils.init_code to populate object_id, line, ident and text of
-- record type cn_utils.code_type
-- This will populate value of l_pkg_spec_id into x_object_id and use
-- package spec id to store package spec code into cn_source.
------++
	cn_utils.init_code (
			x_object_id =>   l_pkg_spec_id,
			code        =>   l_spec_code);
------++
-- This code will write package specification code for dynamic mapping package
-- All the arbuments for MAP API.
------++

	cn_utils.appendcr(l_spec_code,'-- Package Specification For Interface Mapping Package ');
	cn_utils.appendcr(l_spec_code,' PROCEDURE map ('||l_proc_arg1||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg2||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg3||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg4||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg5||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg6||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg7||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg8||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg9||',');
        cn_utils.appendcr(l_spec_code,l_proc_arg10||',');
	cn_utils.appendcr(l_spec_code,l_proc_arg11||');');
	cn_utils.appendcr(l_spec_code);
	cn_utils.appendcr(l_spec_code,'END '||l_pkg_name||';');

------++
-- Call cn_utils.init_code to populate object_id, line, ident and text of
-- record type cn_utils.code_type
-- This will populate value of l_pkg_spec_id into x_object_id and use
-- package body id to store package body code into cn_source.
------++
	cn_utils.init_code (
					x_object_id =>   l_pkg_body_id,
					code        =>   l_body_code);
------++
-- This code will write package body code for dynamic mapping package
-- All the arbuments for MAP API
------++
	------++
	-- Procedure Debug Message
	------++
	cn_utils.appendcr(l_body_code,'PROCEDURE debugmsg(msg VARCHAR2) IS');
	cn_utils.appendcr(l_body_code,'BEGIN');
	cn_utils.appendcr(l_body_code,'	IF fnd_profile.value(''CN_DEBUG'') = ''Y'' ');
	cn_utils.appendcr(l_body_code,'	THEN');
	cn_utils.appendcr(l_body_code,'		cn_message_pkg.debug(substr(msg,1,254));');
	cn_utils.appendcr(l_body_code,'	ELSE');
	cn_utils.appendcr(l_body_code,'		NULL;');
	cn_utils.appendcr(l_body_code,'	END IF;');
	cn_utils.appendcr(l_body_code,'	END debugmsg;');

	cn_utils.appendcr(l_body_code,'FUNCTION get_adjusted_by(p_sca_process_batch_id 	cn_sca_process_batches.sca_process_batch_id%TYPE,');
	cn_utils.appendcr(l_body_code,'                         p_org_id         	cn_sca_process_batches.org_id%TYPE)');
	cn_utils.appendcr(l_body_code,'   RETURN VARCHAR2 IS');
	cn_utils.appendcr(l_body_code,'   l_adjusted_by 	VARCHAR2(100) := ''0'';');
	cn_utils.appendcr(l_body_code,'BEGIN');
	cn_utils.appendcr(l_body_code,'  SELECT	user_name');
	cn_utils.appendcr(l_body_code,'	 INTO 	l_adjusted_by');
	cn_utils.appendcr(l_body_code,'	 FROM 	fnd_user');
	cn_utils.appendcr(l_body_code,'	 WHERE 	user_id  = (SELECT	created_by');
	cn_utils.appendcr(l_body_code,'	 					FROM	cn_sca_process_batches');
	cn_utils.appendcr(l_body_code,'	 					WHERE	sca_process_batch_id = p_sca_process_batch_id');
	cn_utils.appendcr(l_body_code,'	 					AND     org_id = p_org_id);');
	cn_utils.appendcr(l_body_code,'   RETURN l_adjusted_by;');
	cn_utils.appendcr(l_body_code,'EXCEPTION');
	cn_utils.appendcr(l_body_code,'   WHEN OTHERS THEN');
	cn_utils.appendcr(l_body_code,'	  RETURN l_adjusted_by;');
	cn_utils.appendcr(l_body_code,'END get_adjusted_by;');
	------++
	-- Procedure get_init_values Initiates the l_trx_type, l_start_id and l_end_id Variables
	------++
	cn_utils.appendcr(l_body_code,'		PROCEDURE get_init_values(');
	cn_utils.appendcr(l_body_code,'			p_api_version          	IN  NUMBER,');
	cn_utils.appendcr(l_body_code,'			p_init_msg_list			IN  VARCHAR2 := fnd_api.g_false,');
	cn_utils.appendcr(l_body_code,'			p_commit	    		IN  VARCHAR2 := fnd_api.g_false,');
	cn_utils.appendcr(l_body_code,'			p_sca_process_batch_id 	IN  cn_sca_process_batches.sca_process_batch_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_org_id         	IN  cn_sca_process_batches.org_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_trx_type 				OUT NOCOPY  cn_sca_process_batches.type%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_start_id 				OUT NOCOPY  cn_sca_process_batches.start_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_end_id   				OUT NOCOPY  cn_sca_process_batches.end_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_return_status			OUT VARCHAR2,');
	cn_utils.appendcr(l_body_code,'			x_msg_count				OUT NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_msg_data				OUT VARCHAR2)');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'			sca_proc_batch_id_error  EXCEPTION;');
	cn_utils.appendcr(l_body_code,'			l_api_name		CONSTANT VARCHAR2(30)	:= ''get_init_values'';');
	cn_utils.appendcr(l_body_code,'			l_api_version	CONSTANT NUMBER 		:= 1.0;');

	cn_utils.appendcr(l_body_code,'		BEGIN');

	cn_utils.appendcr(l_body_code,'			SAVEPOINT	get_init_values;');

	cn_utils.appendcr(l_body_code,'			IF NOT FND_API.Compatible_API_Call (');
	cn_utils.appendcr(l_body_code,'					l_api_version,');
	cn_utils.appendcr(l_body_code,'					l_api_version,');
	cn_utils.appendcr(l_body_code,'					l_api_name,');
	cn_utils.appendcr(l_body_code,'					NULL)');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			IF FND_API.to_Boolean( p_init_msg_list )');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.initialize;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			--  Initialize API return status to success');
	cn_utils.appendcr(l_body_code,'			x_return_status := FND_API.G_RET_STS_SUCCESS;');

	cn_utils.appendcr(l_body_code,'			SELECT	start_id,   end_id, type');
	cn_utils.appendcr(l_body_code,'				INTO   	x_start_id, x_end_id, x_trx_type');
	cn_utils.appendcr(l_body_code,'				FROM   	cn_sca_process_batches');
	cn_utils.appendcr(l_body_code,'				WHERE  	sca_process_batch_id = p_sca_process_batch_id');
	cn_utils.appendcr(l_body_code,'				AND  	org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'				IF	((x_start_id IS NULL) OR (x_end_id IS NULL))');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					x_return_status := FND_API.G_RET_STS_ERROR;');
	cn_utils.appendcr(l_body_code,'					FND_MESSAGE.SET_NAME(''CN'',''CN_SCA_INVALID_BATCH_ID'');');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.ADD;');
	cn_utils.appendcr(l_body_code,'					RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'						(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'						 p_data     => x_msg_data);');
	cn_utils.appendcr(l_body_code,'				END IF;');

	cn_utils.appendcr(l_body_code,'		EXCEPTION');
	cn_utils.appendcr(l_body_code,'			WHEN FND_API.G_EXC_ERROR');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				ROLLBACK TO get_init_values;');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_ERROR;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Error In Procedure GET_INIT_VALUES'');');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'					(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'					 p_data     => x_msg_data);');
	cn_utils.appendcr(l_body_code,'			WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				ROLLBACK TO get_init_values;');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Unexpected Error In Procedure GET_INIT_VALUES''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'						(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'						 p_data    =>  x_msg_data);');
	cn_utils.appendcr(l_body_code,'			WHEN OTHERS');
	cn_utils.appendcr(l_body_code,'			THEN ');
	cn_utils.appendcr(l_body_code,'				ROLLBACK TO get_init_values;');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Unhandled Error In Procedure GET_INIT_VALUES''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'		    		(p_count	=>      x_msg_count,');
	cn_utils.appendcr(l_body_code,'		   			 p_data 	=>      x_msg_data);');
	cn_utils.appendcr(l_body_code,'		END get_init_values;');

	------++
	-- Procedure check_update_revenue_error Updates cn_comm_lines_api's Adjust Status to SCA_REVENUE_ERROR
	-- for all the orders / invoices that are submitted to SCA Engine and having invalid REVENUE_TYPE
	------++
cn_utils.appendcr(l_body_code,'		PROCEDURE check_reset_error_normal(');
	cn_utils.appendcr(l_body_code,'			p_api_version          	IN NUMBER,');
	cn_utils.appendcr(l_body_code,'			p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_commit	    		IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_validation_level		IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,');
	cn_utils.appendcr(l_body_code,'			p_start_date            IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_date              IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_trx_type				IN cn_comm_lines_api.trx_type%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_start_id 				IN cn_sca_process_batches.start_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_id   				IN cn_sca_process_batches.end_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_sca_process_batch_id  IN cn_sca_process_batches.sca_process_batch_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_org_id                IN cn_sca_process_batches.org_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_reset_ord_recs		OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_reset_inv_recs		OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_return_status			OUT	NOCOPY VARCHAR2,');
	cn_utils.appendcr(l_body_code,'			x_msg_count				OUT	NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_msg_data				OUT	NOCOPY VARCHAR2)');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'			l_api_name				CONSTANT VARCHAR2(30)	:= ''check_update_revenue_error'';');
	cn_utils.appendcr(l_body_code,'			l_user_id  				NUMBER 					:= fnd_global.user_id;');
	cn_utils.appendcr(l_body_code,'			l_adj_by				VARCHAR(100);');

	cn_utils.appendcr(l_body_code,'			CURSOR sca_reset_ord_err_cur');
	cn_utils.appendcr(l_body_code,'			IS');
	cn_utils.appendcr(l_body_code,'			SELECT	comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'			FROM	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'			WHERE	(order_number BETWEEN TO_NUMBER(p_start_id) AND TO_NUMBER(p_end_id))');
	cn_utils.appendcr(l_body_code,'			AND		(TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'			AND     (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'			AND     (order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'			AND     (invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'			AND     (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'			AND     (line_number IS NOT NULL)');

	-- For Bug Fix : 3114337 Modified Typo From SCA_DISTINCT_ERRIR to SCA_DISTINCT_ERROR
	cn_utils.appendcr(l_body_code,'			AND     (adjust_status in (''SCA_SRP_ERROR'',''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''));');

	cn_utils.appendcr(l_body_code,'			CURSOR sca_reset_inv_err_cur');
	cn_utils.appendcr(l_body_code,'			IS');
	cn_utils.appendcr(l_body_code,'			SELECT	comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'			FROM	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'			WHERE	(invoice_number BETWEEN p_start_id AND p_end_id)');
	cn_utils.appendcr(l_body_code,'			AND		(TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'			AND     (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'			AND     (invoice_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'			AND     (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'			AND     (org_id = p_org_id)');

	-- For Bug Fix : 3114337 Modified Typo From SCA_DISTINCT_ERRIR to SCA_DISTINCT_ERROR
	cn_utils.appendcr(l_body_code,'			AND     (adjust_status in (''SCA_SRP_ERROR'',''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''));');

	cn_utils.appendcr(l_body_code,'			TYPE ccla_id_type IS');
	cn_utils.appendcr(l_body_code,'			TABLE OF cn_comm_lines_api.comm_lines_api_id%TYPE');
	cn_utils.appendcr(l_body_code,'			INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'			ccla_id_var	ccla_id_type;');

	cn_utils.appendcr(l_body_code,'			BEGIN');
	cn_utils.appendcr(l_body_code,'			SAVEPOINT check_reset_error_normal;');

	cn_utils.appendcr(l_body_code,'			IF NOT FND_API.Compatible_API_Call (');
	cn_utils.appendcr(l_body_code,'					p_api_version,');
	cn_utils.appendcr(l_body_code,'					p_api_version,');
	cn_utils.appendcr(l_body_code,'					l_api_name,');
	cn_utils.appendcr(l_body_code,'					NULL)');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			-----+');
	cn_utils.appendcr(l_body_code,'			-- Initialize message list if p_init_msg_list is set to TRUE.');
	cn_utils.appendcr(l_body_code,'			-----+');
	cn_utils.appendcr(l_body_code,'			IF FND_API.to_Boolean( p_init_msg_list ) THEN');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.initialize;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			l_adj_by := get_adjusted_by(p_sca_process_batch_id, p_org_id);');

	cn_utils.appendcr(l_body_code,'			x_return_status := FND_API.G_RET_STS_SUCCESS;');

	cn_utils.appendcr(l_body_code,'			IF p_trx_type = ''ORD'' ');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				OPEN sca_reset_ord_err_cur;');
	cn_utils.appendcr(l_body_code,'				FETCH sca_reset_ord_err_cur');
	cn_utils.appendcr(l_body_code,'				BULK COLLECT INTO ccla_id_var LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'				CLOSE sca_reset_ord_err_cur;');

	cn_utils.appendcr(l_body_code,'				IF ccla_id_var.COUNT > 0');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					FORALL i IN ccla_id_var.FIRST..ccla_id_var.LAST');
	cn_utils.appendcr(l_body_code,'					UPDATE	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'					SET		adjust_status = ''NEW'',');
	cn_utils.appendcr(l_body_code,'							adjust_comments = ''SCA_CHECK'',');
	cn_utils.appendcr(l_body_code,'							adjust_date = SYSDATE,');
	cn_utils.appendcr(l_body_code,'							adjusted_by = l_adj_by,');
	cn_utils.appendcr(l_body_code,'							last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'							last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'					WHERE	comm_lines_api_id = ccla_id_var(i)');
	cn_utils.appendcr(l_body_code,'					AND	org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'					debugmsg(SQL%ROWCOUNT||'' Errored Records Of Type ORDER Are Updated To Process By SCA'');');
	cn_utils.appendcr(l_body_code,'					x_reset_ord_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'				ELSE');
	cn_utils.appendcr(l_body_code,'					debugmsg(''No Errored ORDER Records Are Present In This Batch For Reset'');');
	cn_utils.appendcr(l_body_code,'					x_reset_ord_recs := 0;');
	cn_utils.appendcr(l_body_code,'				END IF;');

	cn_utils.appendcr(l_body_code,'			ELSIF p_trx_type = ''INV'' ');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				OPEN sca_reset_inv_err_cur;');
	cn_utils.appendcr(l_body_code,'				FETCH sca_reset_inv_err_cur');
	cn_utils.appendcr(l_body_code,'				BULK COLLECT INTO ccla_id_var LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'				CLOSE sca_reset_inv_err_cur;');

	cn_utils.appendcr(l_body_code,'				IF ccla_id_var.COUNT > 0');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					FORALL i IN ccla_id_var.FIRST..ccla_id_var.LAST');
	cn_utils.appendcr(l_body_code,'					UPDATE	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'					SET		adjust_status = ''NEW'',');
	cn_utils.appendcr(l_body_code,'							adjust_comments = ''SCA_CHECK'',');
	cn_utils.appendcr(l_body_code,'							adjust_date = SYSDATE,');
	cn_utils.appendcr(l_body_code,'							adjusted_by = l_adj_by,');
	cn_utils.appendcr(l_body_code,'							last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'							last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'					WHERE	comm_lines_api_id = ccla_id_var(i)');
	cn_utils.appendcr(l_body_code,'					AND	org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'					debugmsg(SQL%ROWCOUNT||'' Errored Records Of Type INVOICE Are Updated To Process By SCA'');');
	cn_utils.appendcr(l_body_code,'					x_reset_inv_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'				ELSE');
	cn_utils.appendcr(l_body_code,'					debugmsg(''No Errored INVOICE Records Are Present In This Batch For Reset'');');
	cn_utils.appendcr(l_body_code,'					x_reset_inv_recs := 0;');
	cn_utils.appendcr(l_body_code,'				END IF;');

	cn_utils.appendcr(l_body_code,'			END IF;');
	cn_utils.appendcr(l_body_code,'			EXCEPTION');
	cn_utils.appendcr(l_body_code,'				WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					ROLLBACK TO check_reset_error_normal;');
	cn_utils.appendcr(l_body_code,'					x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'					debugmsg(''Unexpected Error In Procedure CHECK_RESET_ERROR_NORMAL''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'						(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'						 p_data    =>  x_msg_data);');
	cn_utils.appendcr(l_body_code,'				WHEN OTHERS');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					ROLLBACK TO check_reset_error_normal;');
	cn_utils.appendcr(l_body_code,'					debugmsg(''Error In Procedure CHECK_RESET_ERROR_NORMAL''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'					x_return_status := FND_API.G_RET_STS_ERROR;');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'						(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'						 p_data     => x_msg_data);');
	cn_utils.appendcr(l_body_code,'		END check_reset_error_normal;');
	cn_utils.appendcr(l_body_code,'		PROCEDURE check_update_revenue_error(');
	cn_utils.appendcr(l_body_code,'			p_api_version          	IN NUMBER,');
	cn_utils.appendcr(l_body_code,'			p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_commit	    		IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_validation_level		IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,');
	cn_utils.appendcr(l_body_code,'			p_start_date            IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_date              IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_trx_type				IN cn_comm_lines_api.trx_type%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_start_id 				IN cn_sca_process_batches.start_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_id  				IN cn_sca_process_batches.end_id%TYPE,');
        cn_utils.appendcr(l_body_code,'			p_org_id   				IN cn_sca_process_batches.org_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_ord_rev_recs		    OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_inv_rev_recs		    OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_return_status			OUT	NOCOPY VARCHAR2,');
	cn_utils.appendcr(l_body_code,'			x_msg_count				OUT	NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_msg_data				OUT	NOCOPY VARCHAR2)');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'			l_api_name				CONSTANT VARCHAR2(30)	:= ''check_update_revenue_error'';');
	cn_utils.appendcr(l_body_code,'			l_user_id  				NUMBER 					:= fnd_global.user_id;');

	cn_utils.appendcr(l_body_code,'			CURSOR rev_typ_all_ord_cur');
	cn_utils.appendcr(l_body_code,'			IS');
	cn_utils.appendcr(l_body_code,'			SELECT  comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'			FROM');
	cn_utils.appendcr(l_body_code,'				(SELECT  order_number, line_number, comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'				 FROM    cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				 WHERE   (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'				 AND     (order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'				 AND     (invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'				 AND     (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'				 AND     (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'				 AND     (order_number BETWEEN TO_NUMBER(p_start_id) AND TO_NUMBER(p_end_id))');
	cn_utils.appendcr(l_body_code,'				 AND     (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'				 AND     ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'				 		 (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'				 		  ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'				 AND     ((trx_type = ''ORD'') OR (trx_type = ''MAN'')))   ord_tbl');
	cn_utils.appendcr(l_body_code,'				 WHERE NOT EXISTS');
	cn_utils.appendcr(l_body_code,'				 		 (SELECT	1');
	cn_utils.appendcr(l_body_code,'				 		  FROM 	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				 		  WHERE   (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'				 		  AND     (invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'				                  AND     (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'				 		  AND     (order_number = ord_tbl.order_number)');
	cn_utils.appendcr(l_body_code,'				 		  AND     (line_number = ord_tbl.line_number)');
	cn_utils.appendcr(l_body_code,'				 		  AND     (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'				 		  AND     ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'				 		  		  (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'				 		  		   ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'				 		  AND     ((trx_type = ''ORD'') OR (trx_type = ''MAN''))');
	cn_utils.appendcr(l_body_code,'				 		  AND 	  (revenue_type = ''REVENUE''));');

	cn_utils.appendcr(l_body_code,'			CURSOR rev_typ_all_inv_cur');
	cn_utils.appendcr(l_body_code,'			IS');
	cn_utils.appendcr(l_body_code,'			SELECT  comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'			FROM');
	cn_utils.appendcr(l_body_code,'				(SELECT  invoice_number, line_number, comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'				 FROM    cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				 WHERE   (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'				 AND     (invoice_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'				 AND     (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'				 AND     (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'				 AND     (invoice_number BETWEEN p_start_id AND p_end_id)');
	cn_utils.appendcr(l_body_code,'				 AND     (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'				 AND     ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'				  		 (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'				 		  ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'				 AND     ((trx_type = ''INV'') OR (trx_type = ''MAN'')))   inv_tbl');
	cn_utils.appendcr(l_body_code,'				 WHERE NOT EXISTS');
	cn_utils.appendcr(l_body_code,'				 		 (SELECT	1');
	cn_utils.appendcr(l_body_code,'				 		  FROM 	  cn_comm_lines_api');
 	cn_utils.appendcr(l_body_code,'				 		  WHERE   (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'				 		  AND     (invoice_number = inv_tbl.invoice_number)');
	cn_utils.appendcr(l_body_code,'				                  AND     (org_id = p_org_id)');
 	cn_utils.appendcr(l_body_code,'				 		  AND     (line_number = inv_tbl.line_number)');
 	cn_utils.appendcr(l_body_code,'				 		  AND     (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'				 		  AND     ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'				 		  		  (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'				 		  		   ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'				 		  AND     ((trx_type = ''INV'') OR (trx_type = ''MAN''))');
	cn_utils.appendcr(l_body_code,'				 		  AND 	  (revenue_type = ''REVENUE''));');

	cn_utils.appendcr(l_body_code,'		TYPE ccla_id_type');
	cn_utils.appendcr(l_body_code,'		IS TABLE OF cn_comm_lines_api.comm_lines_api_id%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');
	cn_utils.appendcr(l_body_code,'		ccla_id_var    ccla_id_type;');

	cn_utils.appendcr(l_body_code,'		BEGIN');
	cn_utils.appendcr(l_body_code,'			SAVEPOINT check_update_revenue_error;');

	cn_utils.appendcr(l_body_code,'			IF NOT FND_API.Compatible_API_Call (');
	cn_utils.appendcr(l_body_code,'					p_api_version,');
	cn_utils.appendcr(l_body_code,'					p_api_version,');
	cn_utils.appendcr(l_body_code,'					l_api_name,');
	cn_utils.appendcr(l_body_code,'					NULL)');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			-----+');
	cn_utils.appendcr(l_body_code,'			-- Initialize message list if p_init_msg_list is set to TRUE.');
	cn_utils.appendcr(l_body_code,'			-----+');
	cn_utils.appendcr(l_body_code,'			IF FND_API.to_Boolean( p_init_msg_list ) THEN');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.initialize;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			x_return_status := FND_API.G_RET_STS_SUCCESS;');

	cn_utils.appendcr(l_body_code,'			IF p_trx_type = ''ORD'' ');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				OPEN	rev_typ_all_ord_cur;');
	cn_utils.appendcr(l_body_code,'				FETCH	rev_typ_all_ord_cur');
	cn_utils.appendcr(l_body_code,'				BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'						ccla_id_var LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'				CLOSE 	rev_typ_all_ord_cur;');

	cn_utils.appendcr(l_body_code,'					IF (ccla_id_var.COUNT > 0)');
	cn_utils.appendcr(l_body_code,'					THEN');
	cn_utils.appendcr(l_body_code,'						FORALL i IN ccla_id_var.FIRST..ccla_id_var.LAST');
	cn_utils.appendcr(l_body_code,'						UPDATE	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'						SET		adjust_status    = ''SCA_REVENUE_ERROR'',');
	cn_utils.appendcr(l_body_code,'								last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'								last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'						WHERE	comm_lines_api_id = ccla_id_var(i)');
	cn_utils.appendcr(l_body_code,'				                  AND     org_id = p_org_id;');

	cn_utils.appendcr(l_body_code,'						IF (SQL%ROWCOUNT > 0)');
	cn_utils.appendcr(l_body_code,'						THEN');
	cn_utils.appendcr(l_body_code,'							debugmsg(SQL%ROWCOUNT||''Records Of Type ORDER Are Updated With Error SCA_REVENUE_ERROR'');');
	cn_utils.appendcr(l_body_code,'							x_ord_rev_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'						ELSE');
	cn_utils.appendcr(l_body_code,'							debugmsg(''All Record(s) of Type ORDER Are REVENUE Type Record(s).'');');
	cn_utils.appendcr(l_body_code,'							x_ord_rev_recs := 0;');
	cn_utils.appendcr(l_body_code,'						END IF;');
	cn_utils.appendcr(l_body_code,'					END IF;');

	cn_utils.appendcr(l_body_code,'				ELSIF (p_trx_type = ''INV'')');
	cn_utils.appendcr(l_body_code,'				THEN');

	cn_utils.appendcr(l_body_code,'					OPEN	rev_typ_all_inv_cur;');
	cn_utils.appendcr(l_body_code,'					FETCH	rev_typ_all_inv_cur');
	cn_utils.appendcr(l_body_code,'					BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'							ccla_id_var LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'					CLOSE 	rev_typ_all_inv_cur;');

	cn_utils.appendcr(l_body_code,'					IF	(ccla_id_var.COUNT > 0)');
	cn_utils.appendcr(l_body_code,'					THEN');
	cn_utils.appendcr(l_body_code,'						FORALL i IN ccla_id_var.FIRST..ccla_id_var.LAST');
	cn_utils.appendcr(l_body_code,'						UPDATE	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'						SET		adjust_status    = ''SCA_REVENUE_ERROR'',');
	cn_utils.appendcr(l_body_code,'								last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'								last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'						WHERE	comm_lines_api_id = ccla_id_var(i)');
	cn_utils.appendcr(l_body_code,'				                AND     org_id = p_org_id;');

	cn_utils.appendcr(l_body_code,'						IF (SQL%ROWCOUNT > 0)');
	cn_utils.appendcr(l_body_code,'						THEN');
	cn_utils.appendcr(l_body_code,'							debugmsg(SQL%ROWCOUNT||''Records Of Type INVOICE Are Updated With Error SCA_REVENUE_ERROR'');');
	cn_utils.appendcr(l_body_code,'							x_ord_rev_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'						ELSE');
	cn_utils.appendcr(l_body_code,'							debugmsg(''All Record(s) of Type INVOICE Are REVENUE Type Record(s).'');');
	cn_utils.appendcr(l_body_code,'							x_ord_rev_recs := 0;');
	cn_utils.appendcr(l_body_code,'						END IF;');

	cn_utils.appendcr(l_body_code,'					END IF;');

	cn_utils.appendcr(l_body_code,'				END IF;');

	cn_utils.appendcr(l_body_code,'			EXCEPTION');
	cn_utils.appendcr(l_body_code,'				WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					ROLLBACK TO check_update_revenue_error;');
	cn_utils.appendcr(l_body_code,'					x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'					debugmsg(''Unexpected Error In Procedure CHECK_UPDATE_REVENUE_ERROR''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'						(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'						 p_data    =>  x_msg_data);');
	cn_utils.appendcr(l_body_code,'				WHEN OTHERS');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					ROLLBACK TO check_update_revenue_error;');
	cn_utils.appendcr(l_body_code,'					debugmsg(''Error In Procedure CHECK_UPDATE_REVENUE_ERROR''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'					x_return_status := FND_API.G_RET_STS_ERROR;');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'						(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'						 p_data     => x_msg_data);');
	cn_utils.appendcr(l_body_code,'			END check_update_revenue_error;');

	------++
	-- Procedure check_update_role_error Updates cn_comm_lines_api's Adjust Status to SCA_ROLE_ERROR
	-- for all the orders / invoices that are submitted to SCA Engine and not having valid ROLE_ID
	------++

	cn_utils.appendcr(l_body_code,'		PROCEDURE check_update_role_error(');
	cn_utils.appendcr(l_body_code,'				p_api_version          	IN NUMBER,');
	cn_utils.appendcr(l_body_code,'				p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'				p_commit	    		IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'				p_validation_level		IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,');
	cn_utils.appendcr(l_body_code,'			   p_sca_process_batch_id  IN cn_sca_process_batches.sca_process_batch_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			   p_start_date            IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			   p_end_date              IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			   p_trx_type				IN cn_comm_lines_api.trx_type%TYPE,');
	cn_utils.appendcr(l_body_code,'				p_start_id 				IN cn_sca_process_batches.start_id%TYPE,');
	cn_utils.appendcr(l_body_code,'				p_end_id   				IN cn_sca_process_batches.end_id%TYPE,');
	cn_utils.appendcr(l_body_code,'				p_org_id   				IN cn_sca_process_batches.org_id%TYPE,');
	cn_utils.appendcr(l_body_code,'				x_ord_role_recs		    OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			   x_inv_role_recs		    OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			   x_return_status			OUT	NOCOPY VARCHAR2,');
	cn_utils.appendcr(l_body_code,'				x_msg_count				OUT	NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'				x_msg_data				OUT	NOCOPY VARCHAR2)');
	cn_utils.appendcr(l_body_code,'			IS');
	cn_utils.appendcr(l_body_code,'				l_api_name				CONSTANT VARCHAR2(30)	:= ''check_update_role_error'';');
	cn_utils.appendcr(l_body_code,'			    l_user_id  				NUMBER 					:= fnd_global.user_id;');

	cn_utils.appendcr(l_body_code,'			    TYPE  ccla_id_tbl IS');
	cn_utils.appendcr(l_body_code,'			    TABLE OF cn_comm_lines_api.comm_lines_api_id%TYPE');
	cn_utils.appendcr(l_body_code,'				 INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'			    TYPE  ccla_ord_tbl IS');
	cn_utils.appendcr(l_body_code,'			    TABLE OF cn_comm_lines_api.order_number%TYPE');
	cn_utils.appendcr(l_body_code,'				 INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'			    TYPE  ccla_inv_tbl IS');
	cn_utils.appendcr(l_body_code,'			    TABLE OF cn_comm_lines_api.invoice_number%TYPE');
	cn_utils.appendcr(l_body_code,'				 INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'			    TYPE ccla_ord_rec IS RECORD');
	cn_utils.appendcr(l_body_code,'			    	(id_col	   ccla_id_tbl,');
	cn_utils.appendcr(l_body_code,'			    	 ord_col   ccla_ord_tbl);');
	cn_utils.appendcr(l_body_code,'				 ccla_ord_rec_var	ccla_ord_rec;');

	cn_utils.appendcr(l_body_code,'			    TYPE ccla_inv_rec IS RECORD');
	cn_utils.appendcr(l_body_code,'			    	(id_col	   ccla_id_tbl,');
	cn_utils.appendcr(l_body_code,'			    	 inv_col   ccla_inv_tbl);');
	cn_utils.appendcr(l_body_code,'				 ccla_inv_rec_var	ccla_inv_rec;');

	cn_utils.appendcr(l_body_code,'		BEGIN');

	cn_utils.appendcr(l_body_code,'				SAVEPOINT	check_update_role_error;');
	cn_utils.appendcr(l_body_code,'				IF NOT FND_API.Compatible_API_Call (');
	cn_utils.appendcr(l_body_code,'						p_api_version,');
	cn_utils.appendcr(l_body_code,'						p_api_version,');
	cn_utils.appendcr(l_body_code,'						l_api_name,');
	cn_utils.appendcr(l_body_code,'						NULL)');
	cn_utils.appendcr(l_body_code,'				THEN');
	cn_utils.appendcr(l_body_code,'					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
	cn_utils.appendcr(l_body_code,'				END IF;');
	cn_utils.appendcr(l_body_code,'				-- Initialize message list if p_init_msg_list is set to TRUE.');
	cn_utils.appendcr(l_body_code,'				IF FND_API.to_Boolean( p_init_msg_list ) THEN');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.initialize;');
	cn_utils.appendcr(l_body_code,'				END IF;');

	cn_utils.appendcr(l_body_code,'				--  Initialize API return status to success');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_SUCCESS;');
	cn_utils.appendcr(l_body_code,'			    IF (p_trx_type = ''ORD'')');
	cn_utils.appendcr(l_body_code,'			    THEN');
	cn_utils.appendcr(l_body_code,'         		SELECT  ccla.comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'         		        ccla.order_number');
	cn_utils.appendcr(l_body_code,'         		BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'         		        ccla_ord_rec_var.id_col,');
	cn_utils.appendcr(l_body_code,'		    		        ccla_ord_rec_var.ord_col');
	cn_utils.appendcr(l_body_code,'         		FROM    ');
	cn_utils.appendcr(l_body_code,'         		        cn_comm_lines_api ccla');

	cn_utils.appendcr(l_body_code,'         		WHERE   (TRUNC(ccla.processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'		    		AND     (ccla.load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'		    		AND     (ccla.org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'         		AND     (ccla.order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'         		AND     (ccla.line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'         		AND     (ccla.invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'					AND     ((ccla.adjust_status IS NULL) OR ccla.adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'						    (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'					         ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'         		AND     (ccla.order_number BETWEEN TO_NUMBER(p_start_id) AND TO_NUMBER(p_end_id))');
	cn_utils.appendcr(l_body_code,'         		AND     ((ccla.trx_type = ''ORD'') OR (ccla.trx_type = ''MAN''))');
   cn_utils.appendcr(l_body_code,'         		AND     NOT EXISTS ');
   cn_utils.appendcr(l_body_code,'         			(SELECT 1 ');
   cn_utils.appendcr(l_body_code,'         		         FROM cn_srp_roles csro ');
	cn_utils.appendcr(l_body_code,'         		         WHERE   (csro.ROLE_id = ccla.role_id)');
	cn_utils.appendcr(l_body_code,'         		         AND     (ccla.salesrep_id = csro.salesrep_id)');
	cn_utils.appendcr(l_body_code,'         		         AND     (ccla.org_id = csro.org_id)');
   cn_utils.appendcr(l_body_code,'         		      AND     (TRUNC(ccla.processed_date) BETWEEN TRUNC(csro.start_date) AND NVL(TRUNC(csro.end_date), TRUNC(ccla.processed_date)))); ');

	cn_utils.appendcr(l_body_code,'					IF ccla_ord_rec_var.id_col.COUNT > 0');
	cn_utils.appendcr(l_body_code,'					THEN');
	cn_utils.appendcr(l_body_code,'						FORALL i IN ccla_ord_rec_var.id_col.FIRST..ccla_ord_rec_var.id_col.LAST');
	cn_utils.appendcr(l_body_code,'						UPDATE 	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'						SET		adjust_status    = ''SCA_ROLE_ERROR'',');
	cn_utils.appendcr(l_body_code,'								last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'								last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'						WHERE comm_lines_api_id = ccla_ord_rec_var.id_col(i)');
	cn_utils.appendcr(l_body_code,'						AND   org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'						debugmsg(SQL%ROWCOUNT||''Record(s) of Type ORDER Updated To SCA_ROLE_ERROR In CN_COMM_LINES_API'');');
	cn_utils.appendcr(l_body_code,'						x_ord_role_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'					ELSE');
	cn_utils.appendcr(l_body_code,'						debugmsg(''All Record(s) of Type ORDER Are Having Valid Role Assigned.'');');
	cn_utils.appendcr(l_body_code,'						x_ord_role_recs := 0;');
	cn_utils.appendcr(l_body_code,'					END IF;');

	cn_utils.appendcr(l_body_code,'			    ELSIF (p_trx_type = ''INV'')');
	cn_utils.appendcr(l_body_code,'			    THEN');
	cn_utils.appendcr(l_body_code,'         		SELECT  ccla.comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'         		        ccla.invoice_number');
	cn_utils.appendcr(l_body_code,'					BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'							ccla_inv_rec_var.id_col,');
	cn_utils.appendcr(l_body_code,'							ccla_inv_rec_var.inv_col');
	cn_utils.appendcr(l_body_code,'         		FROM ');
	cn_utils.appendcr(l_body_code,'         		        cn_comm_lines_api ccla');
	cn_utils.appendcr(l_body_code,'					WHERE   (TRUNC(ccla.processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'					AND   	(ccla.load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'					AND   	(ccla.org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'					AND     (ccla.invoice_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					AND     (ccla.line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					AND   	((ccla.adjust_status IS NULL) OR ccla.adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'						    (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'			                 ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'					AND     (ccla.invoice_number BETWEEN p_start_id AND p_end_id)');
	cn_utils.appendcr(l_body_code,'					AND     ((ccla.trx_type = ''INV'') OR (ccla.trx_type = ''MAN''))');

   cn_utils.appendcr(l_body_code,'         		AND     NOT EXISTS ');
   cn_utils.appendcr(l_body_code,'         			(SELECT 1 ');
   cn_utils.appendcr(l_body_code,'         		         FROM cn_srp_roles csro ');
	cn_utils.appendcr(l_body_code,'         		         WHERE   (csro.ROLE_id = ccla.role_id)');
   cn_utils.appendcr(l_body_code,'         		         AND     (ccla.salesrep_id = csro.salesrep_id)');
   cn_utils.appendcr(l_body_code,'         		         AND     (ccla.org_id = csro.org_id)');
   cn_utils.appendcr(l_body_code,'         		      	AND     (TRUNC(ccla.processed_date) BETWEEN TRUNC(csro.start_date) AND NVL(TRUNC(csro.end_date), TRUNC(ccla.processed_date)))); ');

	cn_utils.appendcr(l_body_code,'					IF ccla_inv_rec_var.id_col.COUNT > 0');
	cn_utils.appendcr(l_body_code,'					THEN');
	cn_utils.appendcr(l_body_code,'		    			FORALL i IN ccla_inv_rec_var.id_col.FIRST..ccla_inv_rec_var.id_col.LAST');
	cn_utils.appendcr(l_body_code,'						UPDATE 	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'						SET		adjust_status    = ''SCA_ROLE_ERROR'',');
	cn_utils.appendcr(l_body_code,'									last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'									last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'						WHERE comm_lines_api_id = ccla_inv_rec_var.id_col(i)');
	cn_utils.appendcr(l_body_code,'						AND   org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'			        	debugmsg(SQL%ROWCOUNT||''Record(s) of Type INVOICE Updated To SCA_ROLE_ERROR In CN_COMM_LINES_API'');');
	cn_utils.appendcr(l_body_code,'						x_inv_role_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'					ELSE');
	cn_utils.appendcr(l_body_code,'						debugmsg(''All Record(s) of Type INVOICE Are Having Valid Role Assigned.'');');
	cn_utils.appendcr(l_body_code,'						x_inv_role_recs := 0;');
	cn_utils.appendcr(l_body_code,'			        END IF;');
	cn_utils.appendcr(l_body_code,'			    END IF;');
	cn_utils.appendcr(l_body_code,'			EXCEPTION');
	cn_utils.appendcr(l_body_code,'			WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				ROLLBACK TO check_update_role_error;');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Unexpected Error In Procedure CHECK_UPDATE_ROLE_ERROR''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'					(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'					 p_data    =>  x_msg_data);');
	cn_utils.appendcr(l_body_code,'			    WHEN OTHERS');
	cn_utils.appendcr(l_body_code,'			    THEN');
	cn_utils.appendcr(l_body_code,'			    	ROLLBACK TO check_update_role_error;');
	cn_utils.appendcr(l_body_code,'					x_return_status := FND_API.G_RET_STS_ERROR;');
	cn_utils.appendcr(l_body_code,'					debugmsg(''Unhandled Error In Procedure CHECK_UPDATE_ROLE_ERROR''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'					FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'							(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'							 p_data     => x_msg_data);');
	cn_utils.appendcr(l_body_code,'		END check_update_role_error;');
	------++
	-- Procedure check_update_resource_error Updates cn_comm_lines_api's Adjust Status to SCA_SRP_ERROR
	-- for all the orders / invoices that are submitted to SCA Engine and not having valid SALESREP_ID
	------++
	cn_utils.appendcr(l_body_code,'		PROCEDURE check_update_resource_error(');
	cn_utils.appendcr(l_body_code,'			p_api_version          	IN NUMBER,');
	cn_utils.appendcr(l_body_code,'			p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_commit	    				IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_sca_process_batch_id 	IN cn_sca_process_batches.sca_process_batch_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_start_date            IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_date              IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_validation_level		IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,');
	cn_utils.appendcr(l_body_code,'			p_trx_type 					IN cn_sca_process_batches.type%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_start_id 					IN cn_sca_process_batches.start_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_id   					IN cn_sca_process_batches.end_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_org_id   					IN cn_sca_process_batches.org_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_ord_res_recs		    	OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_inv_res_recs		    	OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_return_status			OUT NOCOPY VARCHAR2,');
	cn_utils.appendcr(l_body_code,'			x_msg_count					OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_msg_data					OUT NOCOPY VARCHAR2)');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'			l_api_name	CONSTANT VARCHAR2(50)	:=	''check_update_resource_error'';');
	cn_utils.appendcr(l_body_code,'		    l_user_id  	NUMBER := fnd_global.user_id;');

	cn_utils.appendcr(l_body_code,'		   TYPE  ccla_id_tbl IS');
	cn_utils.appendcr(l_body_code,'			TABLE OF cn_comm_lines_api.comm_lines_api_id%TYPE');
	cn_utils.appendcr(l_body_code,'			INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'			TYPE  ccla_ord_tbl IS');
	cn_utils.appendcr(l_body_code,'			TABLE OF cn_comm_lines_api.order_number%TYPE');
	cn_utils.appendcr(l_body_code,'			INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'			TYPE  ccla_inv_tbl IS');
	cn_utils.appendcr(l_body_code,'			TABLE OF cn_comm_lines_api.invoice_number%TYPE');
	cn_utils.appendcr(l_body_code,'			INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'			TYPE ccla_ord_rec IS RECORD');
	cn_utils.appendcr(l_body_code,'			     (id_col	   ccla_id_tbl,');
	cn_utils.appendcr(l_body_code,'			      ord_col   ccla_ord_tbl);');
	cn_utils.appendcr(l_body_code,'			ccla_ord_rec_var	ccla_ord_rec;');

	cn_utils.appendcr(l_body_code,'			TYPE ccla_inv_rec IS RECORD');
	cn_utils.appendcr(l_body_code,'				 (id_col	   ccla_id_tbl,');
	cn_utils.appendcr(l_body_code,'			      inv_col   ccla_inv_tbl);');
	cn_utils.appendcr(l_body_code,'			ccla_inv_rec_var	ccla_inv_rec;');

	cn_utils.appendcr(l_body_code,'		BEGIN');
	cn_utils.appendcr(l_body_code,'			SAVEPOINT check_update_resource_error;');
	cn_utils.appendcr(l_body_code,'			IF NOT FND_API.Compatible_API_Call (');
	cn_utils.appendcr(l_body_code,'				p_api_version,');
	cn_utils.appendcr(l_body_code,'				p_api_version,');
	cn_utils.appendcr(l_body_code,'				l_api_name,');
	cn_utils.appendcr(l_body_code,'				NULL)');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			-- Initialize message list if p_init_msg_list is set to TRUE.');
	cn_utils.appendcr(l_body_code,'			IF FND_API.to_Boolean( p_init_msg_list ) THEN');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.initialize;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			x_return_status := FND_API.G_RET_STS_SUCCESS;');

	cn_utils.appendcr(l_body_code,'		    IF (p_trx_type = ''ORD'')');
	cn_utils.appendcr(l_body_code,'		    THEN');
	cn_utils.appendcr(l_body_code,'				SELECT 	comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'							order_number');
	cn_utils.appendcr(l_body_code,'				BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'						ccla_ord_rec_var.id_col,');
	cn_utils.appendcr(l_body_code,'						ccla_ord_rec_var.ord_col');
	cn_utils.appendcr(l_body_code,'				FROM 	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				WHERE	comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'					IN');
	cn_utils.appendcr(l_body_code,'					(SELECT 	ccla.comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'					 FROM 	jtf_rs_salesreps jrs, cn_comm_lines_api ccla');
	cn_utils.appendcr(l_body_code,'					 WHERE (ccla.salesrep_id = jrs.salesrep_id(+))');
	cn_utils.appendcr(l_body_code,'					 AND   (ccla.org_id = jrs.org_id(+))');
	cn_utils.appendcr(l_body_code,'					 AND   (ccla.salesrep_id IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					 AND   (ccla.org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'					 AND   (nvl(jrs.resource_id,0) = 0)');
	cn_utils.appendcr(l_body_code,'					 AND   (TRUNC(ccla.processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'					 AND   (ccla.load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'					 AND   (order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					 AND   (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					 AND   (invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'					 AND   (ccla.order_number BETWEEN TO_NUMBER(p_start_id) AND TO_NUMBER(p_end_id))');
	cn_utils.appendcr(l_body_code,'					 AND   ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'						    (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'					        ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'					 AND   ((ccla.trx_type = ''ORD'') OR (ccla.trx_type = ''MAN'')));');

	cn_utils.appendcr(l_body_code,'					IF ccla_ord_rec_var.id_col.COUNT > 0');
	cn_utils.appendcr(l_body_code,'					THEN');
	cn_utils.appendcr(l_body_code,'						FORALL i IN ccla_ord_rec_var.id_col.FIRST..ccla_ord_rec_var.id_col.LAST');
	cn_utils.appendcr(l_body_code,'						UPDATE   cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'						SET      adjust_status    = ''SCA_SRP_ERROR'',');
	cn_utils.appendcr(l_body_code,'									last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'									last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'						WHERE  comm_lines_api_id = ccla_ord_rec_var.id_col(i)');
	cn_utils.appendcr(l_body_code,'						AND    org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'						debugmsg(SQL%ROWCOUNT||''Record(s) of Type ORDER Updated To SCA_SRP_ERROR In CN_COMM_LINES_API.'');');
	cn_utils.appendcr(l_body_code,'						x_ord_res_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'					ELSE');
	cn_utils.appendcr(l_body_code,'						debugmsg(''All Record(s) of Type ORDER Are Having Valid Salesrep Id Assigned.'');');
	cn_utils.appendcr(l_body_code,'						x_ord_res_recs := 0;');
	cn_utils.appendcr(l_body_code,'					END IF;');

	cn_utils.appendcr(l_body_code,'		    ELSIF (p_trx_type = ''INV'')');
	cn_utils.appendcr(l_body_code,'		    THEN');
	cn_utils.appendcr(l_body_code,'		    	SELECT 	comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'							invoice_number');
	cn_utils.appendcr(l_body_code,'				BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'						ccla_inv_rec_var.id_col,');
	cn_utils.appendcr(l_body_code,'						ccla_inv_rec_var.inv_col');
	cn_utils.appendcr(l_body_code,'				FROM 	cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				WHERE	comm_lines_api_id ');
	cn_utils.appendcr(l_body_code,'					IN');
	cn_utils.appendcr(l_body_code,'					(SELECT ccla.comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'					FROM 	jtf_rs_salesreps jrs, cn_comm_lines_api ccla');
	cn_utils.appendcr(l_body_code,'					WHERE (ccla.salesrep_id = jrs.salesrep_id(+))');
	cn_utils.appendcr(l_body_code,'					AND   (ccla.org_id = jrs.org_id(+))');
	cn_utils.appendcr(l_body_code,'					AND   (ccla.salesrep_id IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					AND   (ccla.org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'					AND   (nvl(jrs.resource_id,0) = 0)');
	cn_utils.appendcr(l_body_code,'					AND   (TRUNC(ccla.processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'					AND   (ccla.load_status = ''UNLOADED'') ');
	cn_utils.appendcr(l_body_code,'					AND   (invoice_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					AND   (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					AND   (ccla.invoice_number BETWEEN p_start_id AND p_end_id)');
	cn_utils.appendcr(l_body_code,'					AND   ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'						   (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'					       ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'					AND   ((ccla.trx_type = ''INV'') OR (ccla.trx_type = ''MAN'')));');

	cn_utils.appendcr(l_body_code,'					IF ccla_inv_rec_var.id_col.COUNT > 0');
	cn_utils.appendcr(l_body_code,'					THEN');
	cn_utils.appendcr(l_body_code,'						FORALL i IN ccla_inv_rec_var.id_col.FIRST..ccla_inv_rec_var.id_col.LAST');
	cn_utils.appendcr(l_body_code,'						UPDATE  	cn_comm_lines_api ');
	cn_utils.appendcr(l_body_code,'						SET     	adjust_status    = ''SCA_SRP_ERROR'',');
	cn_utils.appendcr(l_body_code,'									last_updated_by  = l_user_id,');
	cn_utils.appendcr(l_body_code,'									last_update_date = SYSDATE');
	cn_utils.appendcr(l_body_code,'						WHERE comm_lines_api_id = ccla_inv_rec_var.id_col(i)');
	cn_utils.appendcr(l_body_code,'						AND   org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'						debugmsg(SQL%ROWCOUNT||''Record(s) of Type INVOICE Updated To SCA_SRP_ERROR In CN_COMM_LINES_API'');');
	cn_utils.appendcr(l_body_code,'						x_inv_res_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'					ELSE');
	cn_utils.appendcr(l_body_code,'						debugmsg(''All Record(s) of Type INVOICE Are Having Valid Salesrep Id Assigned.'');');
	cn_utils.appendcr(l_body_code,'						x_inv_res_recs := 0;');
	cn_utils.appendcr(l_body_code,'					END IF;');
 	cn_utils.appendcr(l_body_code,'		    END IF;');
	cn_utils.appendcr(l_body_code,'		EXCEPTION');
	cn_utils.appendcr(l_body_code,'			WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				ROLLBACK TO check_update_resource_error;');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Unexpected Error In Procedure CHECK_UPDATE_RESOURCE_ERROR''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'					(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'					 p_data    =>  x_msg_data);');
	cn_utils.appendcr(l_body_code,'		    WHEN OTHERS');
	cn_utils.appendcr(l_body_code,'		    THEN');
	cn_utils.appendcr(l_body_code,'		    	ROLLBACK TO check_update_resource_error;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Error In Procedure CHECK_UPDATE_RESOURCE_ERROR''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'		    	x_return_status := FND_API.G_RET_STS_ERROR;');
	cn_utils.appendcr(l_body_code,'		    	FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'		    		(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'		    		 p_data     => x_msg_data);');
	cn_utils.appendcr(l_body_code,'		END check_update_resource_error;');
	------++
	-- Procedure check_update_distinct_error Updates cn_comm_lines_api's Adjust Status to SCA_DISTINCT_ERROR
	-- for all the orders / invoices that are submitted to SCA Engine and not having distinct attribute values across
	-- order / invoice lines
	------++
	cn_utils.appendcr(l_body_code,'		PROCEDURE check_update_distinct_error(');
	cn_utils.appendcr(l_body_code,'			p_api_version          	IN NUMBER,');
	cn_utils.appendcr(l_body_code,'			p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_commit	    				IN VARCHAR2 := FND_API.G_FALSE,');
	cn_utils.appendcr(l_body_code,'			p_sca_process_batch_id 	IN cn_sca_process_batches.sca_process_batch_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_start_date            IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_date              IN cn_comm_lines_api.processed_Date%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_validation_level		IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,');
	cn_utils.appendcr(l_body_code,'			p_trx_type 					IN cn_sca_process_batches.type%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_start_id 					IN cn_sca_process_batches.start_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_end_id   					IN cn_sca_process_batches.end_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			p_org_id   					IN cn_sca_process_batches.org_id%TYPE,');
	cn_utils.appendcr(l_body_code,'			x_ord_dist_recs		   OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_inv_dist_recs		   OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_return_status			OUT NOCOPY VARCHAR2,');
	cn_utils.appendcr(l_body_code,'			x_msg_count					OUT NOCOPY NUMBER,');
	cn_utils.appendcr(l_body_code,'			x_msg_data					OUT NOCOPY VARCHAR2)');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'			l_api_name	CONSTANT VARCHAR2(30)	:= ''check_update_distinct_error'';');
	cn_utils.appendcr(l_body_code,'		BEGIN');
	cn_utils.appendcr(l_body_code,'			SAVEPOINT	check_update_distinct_error;');
	cn_utils.appendcr(l_body_code,'			IF NOT FND_API.Compatible_API_Call (');
	cn_utils.appendcr(l_body_code,'					p_api_version,');
	cn_utils.appendcr(l_body_code,'					p_api_version,');
	cn_utils.appendcr(l_body_code,'					l_api_name,');
	cn_utils.appendcr(l_body_code,'					NULL)');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			-- Initialize message list if p_init_msg_list is set to TRUE.');
	cn_utils.appendcr(l_body_code,'			IF FND_API.to_Boolean( p_init_msg_list ) THEN');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.initialize;');
	cn_utils.appendcr(l_body_code,'			END IF;');

	cn_utils.appendcr(l_body_code,'			--  Initialize API return status to success');
	cn_utils.appendcr(l_body_code,'			x_return_status := FND_API.G_RET_STS_SUCCESS;');

	cn_utils.appendcr(l_body_code,'		    IF (p_trx_type = ''ORD'')');
	cn_utils.appendcr(l_body_code,'		    THEN');
	cn_utils.appendcr(l_body_code,'				UPDATE  cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				SET     adjust_status = ''SCA_DISTINCT_ERROR'' ');
	cn_utils.appendcr(l_body_code,'				WHERE   (comm_lines_api_id, trx_type) IN');
	cn_utils.appendcr(l_body_code,'				         (SELECT  comm_lines_api_id, trx_type');
	cn_utils.appendcr(l_body_code,'				          FROM cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				          WHERE (order_number, line_number)');
	cn_utils.appendcr(l_body_code,'				          IN');
	cn_utils.appendcr(l_body_code,'				             (SELECT  ord_no, line_no');
	cn_utils.appendcr(l_body_code,'				          	  FROM');
	cn_utils.appendcr(l_body_code,'				          	  (SELECT distinct order_number ord_no,line_number line_no,');

	split_long_sql(l_body_code,l_trx_src_column_name(l_loop_cntr3),'SELECT');

	cn_utils.appendcr(l_body_code,'				    FROM    cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				    WHERE   (order_number BETWEEN TO_NUMBER(p_start_id) AND TO_NUMBER(p_end_id))');
	cn_utils.appendcr(l_body_code,'				    AND     (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'				    AND     (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'				    AND     (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'				    AND     (order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'				    AND     (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'				    AND     (invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'				    AND     ((trx_type = ''ORD'') OR (trx_type = ''MAN''))');
	cn_utils.appendcr(l_body_code,'					 AND     ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'						      (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'					          ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR'')))');
	cn_utils.appendcr(l_body_code,'				    HAVING COUNT(ord_no) > 1');
	cn_utils.appendcr(l_body_code,'				    GROUP BY ord_no, line_no)');
	cn_utils.appendcr(l_body_code,'			AND (trx_type IN (''ORD'',''MAN''))');
	cn_utils.appendcr(l_body_code,'			AND (adjust_status NOT IN (''FROZEN'',''REVERSAL'') OR adjust_status IS NULL));');

	cn_utils.appendcr(l_body_code,'				    IF SQL%ROWCOUNT > 0');
	cn_utils.appendcr(l_body_code,'				    THEN');
	cn_utils.appendcr(l_body_code,'				    	debugmsg(SQL%ROWCOUNT||''Records Of Type ORDER Are Updated With Error SCA_DISTINCT_ERROR'');');
	cn_utils.appendcr(l_body_code,'						x_ord_dist_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'				    ELSE');
	cn_utils.appendcr(l_body_code,'				    	debugmsg(''Each ORDER Is Having Distinct Attribute Values'');');
	cn_utils.appendcr(l_body_code,'						x_ord_dist_recs := 0;');
	cn_utils.appendcr(l_body_code,'				    END IF;');

	cn_utils.appendcr(l_body_code,'		    ELSIF (p_trx_type = ''INV'')');
	cn_utils.appendcr(l_body_code,'		    THEN');
	cn_utils.appendcr(l_body_code,'				UPDATE  cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				SET     adjust_status = ''SCA_DISTINCT_ERROR'' ');
	cn_utils.appendcr(l_body_code,'				WHERE   (comm_lines_api_id,trx_type) IN');
	cn_utils.appendcr(l_body_code,'				        (SELECT  comm_lines_api_id, trx_type');
	cn_utils.appendcr(l_body_code,'				         FROM cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				         WHERE (invoice_number, line_number)');
	cn_utils.appendcr(l_body_code,'				         IN');
	cn_utils.appendcr(l_body_code,'				          (SELECT  inv_no, line_no');
	cn_utils.appendcr(l_body_code,'				           FROM');
	cn_utils.appendcr(l_body_code,'				    	      (SELECT distinct invoice_number inv_no,line_number line_no,');

	split_long_sql(l_body_code,l_trx_src_column_name(l_loop_cntr3),'SELECT');

	cn_utils.appendcr(l_body_code,'				    FROM     cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'				    WHERE   (invoice_number BETWEEN p_start_id AND p_end_id)');
	cn_utils.appendcr(l_body_code,'				    AND     (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'					 AND  	(load_status = ''UNLOADED'') ');
	cn_utils.appendcr(l_body_code,'				         AND    (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'					 AND  	(invoice_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					 AND  	(line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'					 AND  	((trx_type = ''INV'') OR (trx_type = ''MAN''))');
	cn_utils.appendcr(l_body_code,'					 AND     ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'						      (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'					          ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR'')))');
	cn_utils.appendcr(l_body_code,'				    HAVING COUNT(inv_no) > 1');
	cn_utils.appendcr(l_body_code,'				    GROUP BY inv_no, line_no)');
	cn_utils.appendcr(l_body_code,'			AND (trx_type IN (''INV'',''MAN''))');
	cn_utils.appendcr(l_body_code,'			AND (adjust_status NOT IN (''FROZEN'',''REVERSAL'') OR adjust_status IS NULL));');

	cn_utils.appendcr(l_body_code,'				    IF SQL%ROWCOUNT > 0');
	cn_utils.appendcr(l_body_code,'				    THEN');
	cn_utils.appendcr(l_body_code,'				    	debugmsg(SQL%ROWCOUNT||''Records Of Type INVOICE Are Updated With Error SCA_DISTINCT_ERROR'');');
	cn_utils.appendcr(l_body_code,'						x_inv_dist_recs := SQL%ROWCOUNT;');
	cn_utils.appendcr(l_body_code,'				    ELSE');
	cn_utils.appendcr(l_body_code,'				    	debugmsg(''Each INVOICE Is Having Distinct Attribute Values'');');
	cn_utils.appendcr(l_body_code,'						x_inv_dist_recs := 0;');
	cn_utils.appendcr(l_body_code,'				    END IF;');

	cn_utils.appendcr(l_body_code,'			END IF;');
	cn_utils.appendcr(l_body_code,'		EXCEPTION');
	cn_utils.appendcr(l_body_code,'			WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				ROLLBACK TO check_update_distinct_error;');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Unexpected Error In Procedure CHECK_UPDATE_DISTINCT_ERROR''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'					(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'					 p_data    =>  x_msg_data);');
	cn_utils.appendcr(l_body_code,'			WHEN OTHERS');
	cn_utils.appendcr(l_body_code,'			THEN');
	cn_utils.appendcr(l_body_code,'				ROLLBACK TO check_update_distinct_error;');
	cn_utils.appendcr(l_body_code,'				debugmsg(''Error In Procedure CHECK_UPDATE_DISTINCT_ERROR''||SQLERRM); ');
	cn_utils.appendcr(l_body_code,'				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'				FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'						(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'						 p_data     => x_msg_data);');
	cn_utils.appendcr(l_body_code,'		END check_update_distinct_error;');

	cn_utils.appendcr(l_body_code,'------+');
	cn_utils.appendcr(l_body_code,'-- Package Body For Interface Mapping Package ');
	cn_utils.appendcr(l_body_code,'------+');
	cn_utils.appendcr(l_body_code,' PROCEDURE map (');
	cn_utils.appendcr(l_body_code,		l_proc_arg1 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg2 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg3 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg4 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg5 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg6 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg7 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg8 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg9 ||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg10||',');
	cn_utils.appendcr(l_body_code,		l_proc_arg11||')');
	cn_utils.appendcr(l_body_code,'IS ');

	cn_utils.appendcr(l_body_code,'------+');
	cn_utils.appendcr(l_body_code,'-- To Store values to update WHO Columns');
	cn_utils.appendcr(l_body_code,'------+');
	cn_utils.appendcr(l_body_code,'     l_user_id  		NUMBER(15) := fnd_global.user_id;');
	cn_utils.appendcr(l_body_code,'     l_login_id 		NUMBER(15) := fnd_global.login_id;');

	cn_utils.appendcr(l_body_code,'------+');
	cn_utils.appendcr(l_body_code,'-- To store values for start_id and end_id of CN_SCA_PROCESS_BATCHES');
	cn_utils.appendcr(l_body_code,'------+');
	cn_utils.appendcr(l_body_code,'     l_start_id   	cn_sca_process_batches.start_id%TYPE;');
	cn_utils.appendcr(l_body_code,'     l_end_id     	cn_sca_process_batches.end_id%TYPE;');
	cn_utils.appendcr(l_body_code,'     l_trx_type   	cn_sca_headers_interface.source_type%TYPE;');

	cn_utils.appendcr(l_body_code,'     l_return_status VARCHAR2(50);');
	cn_utils.appendcr(l_body_code,'     l_msg_count		 NUMBER;');
	cn_utils.appendcr(l_body_code,'     l_msg_data		 VARCHAR2(2000);');
	cn_utils.appendcr(l_body_code,'	   l_upd_ccla		 VARCHAR2(1) := ''N''; ');

	cn_utils.appendcr(l_body_code,'	    -----+');
	cn_utils.appendcr(l_body_code,'	    -- Variable Declarations To Hold Values Of Rows Effected By 5 Check Procedures');
	cn_utils.appendcr(l_body_code,'	    -----+');
	cn_utils.appendcr(l_body_code,'	    l_reset_ord_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_reset_inv_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_ord_role_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_inv_role_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_ord_res_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_inv_res_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_ord_dist_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_inv_dist_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_ord_rev_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_inv_rev_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    -----+');
	cn_utils.appendcr(l_body_code,'	    -- Variable Declarations To Hold Values Of Rows Inserted into CN_SCA_HEADERS_INTERFACE,');
	cn_utils.appendcr(l_body_code,'	    -- CN_SCA_LINES_INTERFACE And Rows Updated Into CN_COMM_LINES_API For Each ORDER and/or INVOICE');
	cn_utils.appendcr(l_body_code,'	    -----+');

	cn_utils.appendcr(l_body_code,'	    l_ord_ccla_recs 		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_ord_cshi_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_ord_csli_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_inv_ccla_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_inv_csli_recs		NUMBER := 0;');
	cn_utils.appendcr(l_body_code,'	    l_inv_cshi_recs		NUMBER := 0;');

	cn_utils.appendcr(l_body_code,'		CURSOR   sca_head_ord_cur');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'		SELECT trx_amt, comm_lines_api_id, order_number, line_number from ');
	cn_utils.appendcr(l_body_code,'		(SELECT SUM(transaction_amount) trx_amt,');
	cn_utils.appendcr(l_body_code,'			   MAX(comm_lines_api_id) comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'			   order_number,');
	cn_utils.appendcr(l_body_code,'			   line_number');
	cn_utils.appendcr(l_body_code,'		FROM   cn_comm_lines_api ccla');
	cn_utils.appendcr(l_body_code,'		WHERE  (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'		AND    (load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'		AND    (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'		AND    (order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND    (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND    (invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'		AND    ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'			    (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'',');
	cn_utils.appendcr(l_body_code,'			     ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'		AND    (order_number BETWEEN TO_NUMBER(l_start_id) AND TO_NUMBER(l_end_id))');
	cn_utils.appendcr(l_body_code,'		AND    (trx_type = ''ORD'' OR trx_type = ''MAN'')');
   cn_utils.appendcr(l_body_code,'		AND    (revenue_type = ''REVENUE'')');
	cn_utils.appendcr(l_body_code,'		GROUP BY  order_number, line_number) ord_tbl');
	cn_utils.appendcr(l_body_code,'		WHERE NOT EXISTS');
   cn_utils.appendcr(l_body_code,'		    (SELECT 1 FROM cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'		         WHERE order_number = ord_tbl.order_number');
	cn_utils.appendcr(l_body_code,'		         AND line_number = ord_tbl.line_number');
	cn_utils.appendcr(l_body_code,'		         AND org_id = p_org_id');
	cn_utils.appendcr(l_body_code,'		         AND adjust_status IN (''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR'')); ');

	cn_utils.appendcr(l_body_code,'		CURSOR  sca_line_ord_cur');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'		SELECT	cshi.sca_headers_interface_id,');
	cn_utils.appendcr(l_body_code,'					jrs.resource_id,');
	cn_utils.appendcr(l_body_code,'					ccla.role_id,');
	cn_utils.appendcr(l_body_code,'					ccla.comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'		        	ccla.object_version_number');
	cn_utils.appendcr(l_body_code,'		FROM		cn_comm_lines_api ccla,');
	cn_utils.appendcr(l_body_code,'					jtf_rs_salesreps jrs,');
	cn_utils.appendcr(l_body_code,'					cn_sca_headers_interface cshi');
	cn_utils.appendcr(l_body_code,'		WHERE	(ccla.salesrep_id  = jrs.salesrep_id)');
	cn_utils.appendcr(l_body_code,'		AND   (ccla.load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'		AND 	(order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND 	(ccla.org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'		AND 	(ccla.org_id = jrs.org_id)');
	cn_utils.appendcr(l_body_code,'		AND 	(jrs.org_id = cshi.org_id)');
	cn_utils.appendcr(l_body_code,'		AND 	(line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND 	(invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'		AND	(ccla.order_number BETWEEN TO_NUMBER(l_start_id) AND TO_NUMBER(l_end_id))');
	cn_utils.appendcr(l_body_code,'		AND   (TRUNC(ccla.processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'		AND   ((ccla.adjust_status IS NULL) OR ccla.adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'			   (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'', ');
	cn_utils.appendcr(l_body_code,'			    ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR'')) ');
	cn_utils.appendcr(l_body_code,'	    AND	(ccla.order_number = cshi.source_id)');
	cn_utils.appendcr(l_body_code,'	    AND	(ccla.line_number  = cshi.source_line_id)');
	cn_utils.appendcr(l_body_code,'	    AND  (ccla.trx_type     = ''ORD'' OR ccla.trx_type = ''MAN'')');
	cn_utils.appendcr(l_body_code,'		 AND  (cshi.source_type  = ''ORD'');');

	cn_utils.appendcr(l_body_code,'		CURSOR sca_ord_ccla_cur');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'		SELECT  comm_lines_api_id ');
	cn_utils.appendcr(l_body_code,'		FROM    cn_comm_lines_api ccla');
	cn_utils.appendcr(l_body_code,'		WHERE   (order_number BETWEEN TO_NUMBER(l_start_id) AND TO_NUMBER(l_end_id))');
	cn_utils.appendcr(l_body_code,'		AND     (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'		AND 	  (load_Status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'		AND 	  (trx_type = ''ORD'' OR trx_type = ''MAN'')');
	cn_utils.appendcr(l_body_code,'		AND 	  (order_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND 	  (org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'		AND 	  (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND 	  (invoice_number IS NULL)');
	cn_utils.appendcr(l_body_code,'		AND     ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'			     (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'', ');
	cn_utils.appendcr(l_body_code,'			      ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'		AND NOT EXISTS');
	cn_utils.appendcr(l_body_code,'		       (SELECT 1 FROM cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'		        WHERE order_number = ccla.order_number');
	cn_utils.appendcr(l_body_code,'		        AND line_number = ccla.line_number');
	cn_utils.appendcr(l_body_code,'		        AND org_id = p_org_id');
	cn_utils.appendcr(l_body_code,'		        AND adjust_status IN (''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''));');

	cn_utils.appendcr(l_body_code,'		CURSOR   sca_head_inv_cur');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'		SELECT trx_amt, comm_lines_api_id, invoice_number, line_number FROM');
	cn_utils.appendcr(l_body_code,'		(SELECT SUM(transaction_amount) trx_amt,');
	cn_utils.appendcr(l_body_code,'			     MAX(comm_lines_api_id) comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'				  invoice_number,');
	cn_utils.appendcr(l_body_code,'				  line_number');
	cn_utils.appendcr(l_body_code,'		FROM    cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'		WHERE   (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'		AND     (load_status = ''UNLOADED'') ');
	cn_utils.appendcr(l_body_code,'		AND     (org_id = p_org_id) ');
 	cn_utils.appendcr(l_body_code,'		AND 	  (invoice_number IS NOT NULL)');
 	cn_utils.appendcr(l_body_code,'		AND 	  (line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND     ((adjust_status IS NULL) OR adjust_status NOT IN ');
	cn_utils.appendcr(l_body_code,'				 (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'', ');
	cn_utils.appendcr(l_body_code,'				  ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR'')) ');
	cn_utils.appendcr(l_body_code,'		AND      (invoice_number BETWEEN l_start_id AND l_end_id) ');
	cn_utils.appendcr(l_body_code,'		AND      (trx_type = ''INV'' OR trx_type = ''MAN'') ');
	cn_utils.appendcr(l_body_code,'		AND      (revenue_type = ''REVENUE'')');
	cn_utils.appendcr(l_body_code,'		GROUP BY invoice_number, line_number) inv_tbl');
	cn_utils.appendcr(l_body_code,'		WHERE NOT EXISTS');
   cn_utils.appendcr(l_body_code,'		    (SELECT 1 FROM cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'		     WHERE  invoice_number = inv_tbl.invoice_number');
   cn_utils.appendcr(l_body_code,'		     AND 	line_number = inv_tbl.line_number');
   cn_utils.appendcr(l_body_code,'		     AND 	org_id = p_org_id');
	cn_utils.appendcr(l_body_code,'		     AND 	adjust_status IN (''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR'')); ');

	cn_utils.appendcr(l_body_code,'		CURSOR  sca_line_inv_cur');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'		SELECT	cshi.sca_headers_interface_id,');
	cn_utils.appendcr(l_body_code,'			    	jrs.resource_id,');
	cn_utils.appendcr(l_body_code,'			    	ccla.role_id,');
	cn_utils.appendcr(l_body_code,'			    	ccla.comm_lines_api_id,');
	cn_utils.appendcr(l_body_code,'			    	ccla.object_version_number');
	cn_utils.appendcr(l_body_code,'		FROM		cn_comm_lines_api ccla,');
	cn_utils.appendcr(l_body_code,'					jtf_rs_salesreps jrs,');
	cn_utils.appendcr(l_body_code,'					cn_sca_headers_interface cshi');
	cn_utils.appendcr(l_body_code,'		WHERE	(ccla.salesrep_id  = jrs.salesrep_id)');
	cn_utils.appendcr(l_body_code,'		AND   (ccla.load_status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'		AND 	(invoice_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND 	(ccla.org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'		AND 	(ccla.org_id = jrs.org_id)');
	cn_utils.appendcr(l_body_code,'		AND 	(jrs.org_id = cshi.org_id)');
 	cn_utils.appendcr(l_body_code,'		AND 	(line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND	(ccla.invoice_number BETWEEN l_start_id AND l_end_id)');
	cn_utils.appendcr(l_body_code,'		AND   (TRUNC(ccla.processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'		AND   ((ccla.adjust_status IS NULL) OR ccla.adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'			   (''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'', ');
	cn_utils.appendcr(l_body_code,'			    ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR'')) ');
	cn_utils.appendcr(l_body_code,'		AND	(ccla.invoice_number = cshi.source_id)');
	cn_utils.appendcr(l_body_code,'		AND	(ccla.line_number    = cshi.source_line_id)');
	cn_utils.appendcr(l_body_code,'		AND   (ccla.trx_type      = ''INV'' OR ccla.trx_type = ''MAN'')');
	cn_utils.appendcr(l_body_code,'		AND   (cshi.source_type   = ''INV'');');

	cn_utils.appendcr(l_body_code,'		CURSOR sca_inv_ccla_cur');
	cn_utils.appendcr(l_body_code,'		IS');
	cn_utils.appendcr(l_body_code,'		SELECT  comm_lines_api_id');
	cn_utils.appendcr(l_body_code,'		FROM    cn_comm_lines_api ccla');

	cn_utils.appendcr(l_body_code,'		WHERE (invoice_number BETWEEN l_start_id AND l_end_id)');
	cn_utils.appendcr(l_body_code,'		AND   (TRUNC(processed_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))');
	cn_utils.appendcr(l_body_code,'		AND 	(load_Status = ''UNLOADED'')');
	cn_utils.appendcr(l_body_code,'		AND 	(org_id = p_org_id)');
	cn_utils.appendcr(l_body_code,'		AND 	(invoice_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND 	(line_number IS NOT NULL)');
	cn_utils.appendcr(l_body_code,'		AND 	(trx_type = ''INV'' OR trx_type = ''MAN'')');
	cn_utils.appendcr(l_body_code,'		AND   ((adjust_status IS NULL) OR adjust_status NOT IN');
	cn_utils.appendcr(l_body_code,'				(''SCA_PENDING'', ''SCA_ALLOCATED'', ''SCA_NOT_ALLOCATED'',''SCA_NO_RULE'',''REVERSAL'',''FROZEN'', ');
	cn_utils.appendcr(l_body_code,'				 ''SCA_NOT_ELIGIBLE'',''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''))');
	cn_utils.appendcr(l_body_code,'		AND NOT EXISTS');
	cn_utils.appendcr(l_body_code,'		       (SELECT 1 FROM cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'		        WHERE invoice_number = ccla.invoice_number');
	cn_utils.appendcr(l_body_code,'		        AND line_number = ccla.line_number');
	cn_utils.appendcr(l_body_code,'		        AND org_id = p_org_id');
	cn_utils.appendcr(l_body_code,'		        AND adjust_status IN (''SCA_SRP_ERROR'', ''SCA_ROLE_ERROR'',''SCA_DISTINCT_ERROR'',''SCA_REVENUE_ERROR''));');

	cn_utils.appendcr(l_body_code,'		TYPE  ord_num_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_comm_lines_api.order_number%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE  inv_num_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_comm_lines_api.invoice_number%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE line_num_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_comm_lines_api.line_number%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE trx_amt_sum_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF NUMBER');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE  ccla_id_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_comm_lines_api.comm_lines_api_id%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'    TYPE sca_head_ord_rec IS RECORD(');
	cn_utils.appendcr(l_body_code,'         ord_num     ord_num_tbl,');
	cn_utils.appendcr(l_body_code,'         line_num    line_num_tbl,');
	cn_utils.appendcr(l_body_code,'         amt_sum     trx_amt_sum_tbl,');
	cn_utils.appendcr(l_body_code,'         api_id      ccla_id_tbl);');
	cn_utils.appendcr(l_body_code,'    sca_head_ord_var    sca_head_ord_rec;');

	cn_utils.appendcr(l_body_code,'    TYPE sca_head_inv_rec IS RECORD(');
	cn_utils.appendcr(l_body_code,'         inv_num     inv_num_tbl,');
	cn_utils.appendcr(l_body_code,'         line_num    line_num_tbl,');
	cn_utils.appendcr(l_body_code,'         amt_sum     trx_amt_sum_tbl,');
	cn_utils.appendcr(l_body_code,'         api_id      ccla_id_tbl);');
	cn_utils.appendcr(l_body_code,'    sca_head_inv_var    sca_head_inv_rec;');

	cn_utils.appendcr(l_body_code,'		TYPE cshi_id_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_sca_headers_interface.sca_headers_interface_id%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE jrs_rs_id_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF jtf_rs_salesreps.resource_id%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE ccla_rl_id_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_comm_lines_api.role_id%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE ccla_api_id_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_comm_lines_api.comm_lines_api_id%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'		TYPE ccla_ovn_tbl IS');
	cn_utils.appendcr(l_body_code,'		TABLE OF cn_comm_lines_api.object_version_number%TYPE');
	cn_utils.appendcr(l_body_code,'		INDEX BY BINARY_INTEGER;');

	cn_utils.appendcr(l_body_code,'    TYPE sca_line_rec IS RECORD(');
	cn_utils.appendcr(l_body_code,'			cshi_id cshi_id_tbl,');
	cn_utils.appendcr(l_body_code,'			jrs_id  jrs_rs_id_tbl,');
	cn_utils.appendcr(l_body_code,'			role_id ccla_rl_id_tbl,');
	cn_utils.appendcr(l_body_code,'			api_id  ccla_api_id_tbl,');
	cn_utils.appendcr(l_body_code,'			ovn_no  ccla_ovn_tbl);');

	cn_utils.appendcr(l_body_code,'		sca_line_rec_var  sca_line_rec;');
	cn_utils.appendcr(l_body_code,'		sca_ccla_id_var		ccla_id_tbl;');

	cn_utils.appendcr(l_body_code,'BEGIN');
	cn_utils.appendcr(l_body_code,'		SAVEPOINT map_package_savepoint;');


	cn_utils.appendcr(l_body_code,'		get_init_values(');
	cn_utils.appendcr(l_body_code,'		p_api_version		=> 	1.0,');
	cn_utils.appendcr(l_body_code,'		p_sca_process_batch_id	=> 	p_sca_process_batch_id,');
	cn_utils.appendcr(l_body_code,'		p_org_id         	=> 	p_org_id,');
	cn_utils.appendcr(l_body_code,'		x_trx_type		=>	l_trx_type,');
	cn_utils.appendcr(l_body_code,'		x_start_id		=> 	l_start_id,');
	cn_utils.appendcr(l_body_code,'		x_end_id		=> 	l_end_id,');
	cn_utils.appendcr(l_body_code,'     	x_return_status		=>	l_return_status,');
	cn_utils.appendcr(l_body_code,'     	x_msg_count		=> 	l_msg_count,');
	cn_utils.appendcr(l_body_code,'     	x_msg_data		=>	l_msg_data);');


	cn_utils.appendcr(l_body_code,'		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'			x_return_status := l_return_status;');
	cn_utils.appendcr(l_body_code,'			FND_MESSAGE.SET_NAME(''CN'',''CN_GET_INIT_VALUES_ERROR'');');
	cn_utils.appendcr(l_body_code,'			FND_MSG_PUB.ADD;');
	cn_utils.appendcr(l_body_code,'			RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'		END IF;');

	cn_utils.appendcr(l_body_code,'		check_reset_error_normal(');
	cn_utils.appendcr(l_body_code,'		p_api_version		=> 	1.0,');
	cn_utils.appendcr(l_body_code,'		p_start_date		=>	p_start_date,');
	cn_utils.appendcr(l_body_code,'		p_end_date		=>	p_end_date,');
	cn_utils.appendcr(l_body_code,'		p_trx_type		=>	l_trx_type,');
	cn_utils.appendcr(l_body_code,'		p_start_id		=>	l_start_id,');
	cn_utils.appendcr(l_body_code,'		p_end_id		=>	l_end_id,');
	cn_utils.appendcr(l_body_code,'		p_org_id         	=> 	p_org_id,');
	cn_utils.appendcr(l_body_code,'		p_sca_process_batch_id	=> 	p_sca_process_batch_id,');
	cn_utils.appendcr(l_body_code,'		x_reset_ord_recs	=>	l_reset_ord_recs,');
	cn_utils.appendcr(l_body_code,'		x_reset_inv_recs	=>	l_reset_inv_recs,');
	cn_utils.appendcr(l_body_code,'     	x_return_status		=>	l_return_status,');
	cn_utils.appendcr(l_body_code,'     	x_msg_count		=> 	l_msg_count,');
	cn_utils.appendcr(l_body_code,'     	x_msg_data		=>	l_msg_data);');

	cn_utils.appendcr(l_body_code,'		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'			x_return_status := l_return_status;');
	cn_utils.appendcr(l_body_code,'			FND_MESSAGE.SET_NAME(''CN'',''CN_CHECK_RESET_ERROR_NORMAL'');');
	cn_utils.appendcr(l_body_code,'			FND_MSG_PUB.ADD;');
	cn_utils.appendcr(l_body_code,'			RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'		END IF;');

	cn_utils.appendcr(l_body_code,'		check_update_revenue_error(');
	cn_utils.appendcr(l_body_code,'			p_api_version		=> 	1.0,');
	cn_utils.appendcr(l_body_code,'			p_start_date		=>	p_start_date,');
	cn_utils.appendcr(l_body_code,'			p_end_date		=>	p_end_date,');
	cn_utils.appendcr(l_body_code,'			p_trx_type		=>	l_trx_type,');
	cn_utils.appendcr(l_body_code,'			p_start_id		=>	l_start_id,');
	cn_utils.appendcr(l_body_code,'			p_end_id		=>	l_end_id,');
	cn_utils.appendcr(l_body_code,'		        p_org_id         	=> 	p_org_id,');
	cn_utils.appendcr(l_body_code,'			x_ord_rev_recs		=>	l_ord_rev_recs,');
	cn_utils.appendcr(l_body_code,'			x_inv_rev_recs		=>	l_inv_rev_recs,');
	cn_utils.appendcr(l_body_code,'     		x_return_status		=>	l_return_status,');
	cn_utils.appendcr(l_body_code,'     		x_msg_count		=> 	l_msg_count,');
	cn_utils.appendcr(l_body_code,'     		x_msg_data		=>	l_msg_data);');

	cn_utils.appendcr(l_body_code,'		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'			x_return_status := l_return_status;');
	cn_utils.appendcr(l_body_code,'			FND_MESSAGE.SET_NAME(''CN'',''CN_CHK_REV_ERROR'');');
	cn_utils.appendcr(l_body_code,'			FND_MSG_PUB.ADD;');
	cn_utils.appendcr(l_body_code,'			RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'		END IF;');

	cn_utils.appendcr(l_body_code,'		check_update_role_error(');
	cn_utils.appendcr(l_body_code,'			p_api_version		=> 	1.0,');
	cn_utils.appendcr(l_body_code,'			p_sca_process_batch_id	=>	p_sca_process_batch_id,');
	cn_utils.appendcr(l_body_code,'			p_start_date		=>	p_start_date,');
	cn_utils.appendcr(l_body_code,'			p_end_date		=>	p_end_date,');
	cn_utils.appendcr(l_body_code,'			p_trx_type		=>	l_trx_type,');
	cn_utils.appendcr(l_body_code,'			p_start_id		=>	l_start_id,');
	cn_utils.appendcr(l_body_code,'			p_end_id		=>	l_end_id,');
	cn_utils.appendcr(l_body_code,'	        	p_org_id         	=> 	p_org_id,');
	cn_utils.appendcr(l_body_code,'			x_ord_role_recs		=>	l_ord_role_recs,');
	cn_utils.appendcr(l_body_code,'			x_inv_role_recs		=>	l_inv_role_recs,');
	cn_utils.appendcr(l_body_code,'     	x_return_status			=>	l_return_status,');
	cn_utils.appendcr(l_body_code,'     	x_msg_count			=> 	l_msg_count,');
	cn_utils.appendcr(l_body_code,'     	x_msg_data			=>	l_msg_data);');

	cn_utils.appendcr(l_body_code,'		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'			x_return_status := l_return_status;');
	cn_utils.appendcr(l_body_code,'			FND_MESSAGE.SET_NAME(''CN'',''CN_CHK_ROLE_ERROR'');');
	cn_utils.appendcr(l_body_code,'			FND_MSG_PUB.ADD;');
	cn_utils.appendcr(l_body_code,'			RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'		END IF;');

	cn_utils.appendcr(l_body_code,'		check_update_resource_error(');
	cn_utils.appendcr(l_body_code,'			p_api_version		=>  	1.0,');
	cn_utils.appendcr(l_body_code,'			p_sca_process_batch_id	=>	p_sca_process_batch_id,');
	cn_utils.appendcr(l_body_code,'			p_start_date		=>	p_start_date,');
	cn_utils.appendcr(l_body_code,'			p_end_date		=>	p_end_date,');
	cn_utils.appendcr(l_body_code,'			p_trx_type		=>	l_trx_type,');
	cn_utils.appendcr(l_body_code,'			p_start_id		=>	l_start_id,');
	cn_utils.appendcr(l_body_code,'			p_end_id		=>	l_end_id,');
	cn_utils.appendcr(l_body_code,'	        	p_org_id         	=> 	p_org_id,');
	cn_utils.appendcr(l_body_code,'			x_ord_res_recs		=>	l_ord_res_recs,');
	cn_utils.appendcr(l_body_code,'			x_inv_res_recs		=> 	l_inv_res_recs,');
	cn_utils.appendcr(l_body_code,'     	x_return_status			=>	l_return_status,');
	cn_utils.appendcr(l_body_code,'     	x_msg_count			=> 	l_msg_count,');
	cn_utils.appendcr(l_body_code,'     	x_msg_data			=>	l_msg_data);');

	cn_utils.appendcr(l_body_code,'		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'			x_return_status := l_return_status;');
	cn_utils.appendcr(l_body_code,'			FND_MESSAGE.SET_NAME(''CN'',''CN_CHK_RES_ERROR'');');
	cn_utils.appendcr(l_body_code,'			FND_MSG_PUB.ADD;');
	cn_utils.appendcr(l_body_code,'			RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'		END IF;');

	cn_utils.appendcr(l_body_code,'		check_update_distinct_error(');
	cn_utils.appendcr(l_body_code,'			p_api_version		=>  	1.0,');
	cn_utils.appendcr(l_body_code,'			p_sca_process_batch_id	=>	p_sca_process_batch_id,');
	cn_utils.appendcr(l_body_code,'			p_start_date		=>	p_start_date,');
	cn_utils.appendcr(l_body_code,'			p_end_date		=>	p_end_date,');
	cn_utils.appendcr(l_body_code,'			p_trx_type		=>	l_trx_type,');
	cn_utils.appendcr(l_body_code,'			p_start_id		=>	l_start_id,');
	cn_utils.appendcr(l_body_code,'			p_end_id		=>	l_end_id,');
	cn_utils.appendcr(l_body_code,'	        	p_org_id         	=> 	p_org_id,');
	cn_utils.appendcr(l_body_code,'			x_ord_dist_recs		=>	l_ord_dist_recs,');
	cn_utils.appendcr(l_body_code,'			x_inv_dist_recs		=>	l_inv_dist_recs,');
	cn_utils.appendcr(l_body_code,'     	x_return_status			=>	l_return_status,');
	cn_utils.appendcr(l_body_code,'     	x_msg_count			=> 	l_msg_count,');
	cn_utils.appendcr(l_body_code,'     	x_msg_data			=>	l_msg_data);');

	cn_utils.appendcr(l_body_code,'		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'			x_return_status := l_return_status;');
	cn_utils.appendcr(l_body_code,'			FND_MESSAGE.SET_NAME(''CN'',''CN_CHK_DIST_ERROR'');');
	cn_utils.appendcr(l_body_code,'			FND_MSG_PUB.ADD;');
	cn_utils.appendcr(l_body_code,'			RAISE FND_API.G_EXC_ERROR;');
	cn_utils.appendcr(l_body_code,'		END IF;');

   cn_utils.appendcr(l_body_code,'    IF l_trx_type = ''ORD'' ');
   cn_utils.appendcr(l_body_code,'    THEN');
   cn_utils.appendcr(l_body_code,'	   OPEN  sca_head_ord_cur;');

   cn_utils.appendcr(l_body_code,'	   FETCH sca_head_ord_cur ');
   cn_utils.appendcr(l_body_code,'	   BULK COLLECT INTO ');
   cn_utils.appendcr(l_body_code,'				sca_head_ord_var.amt_sum,');
   cn_utils.appendcr(l_body_code,'		    		sca_head_ord_var.api_id,');
   cn_utils.appendcr(l_body_code,'				sca_head_ord_var.ord_num,');
   cn_utils.appendcr(l_body_code,'	  			sca_head_ord_var.line_num LIMIT 1000;');
   cn_utils.appendcr(l_body_code,'	   CLOSE sca_head_ord_cur;');
	cn_utils.appendcr(l_body_code,'	   IF sca_head_ord_var.api_id.COUNT > 0');
	cn_utils.appendcr(l_body_code,'	   THEN');

	cn_utils.appendcr(l_body_code,'	   	   l_ord_cshi_recs := sca_head_ord_var.api_id.COUNT;');

	cn_utils.appendcr(l_body_code,'	   	   l_upd_ccla := ''Y'';');
 	cn_utils.appendcr(l_body_code,'        FORALL i IN sca_head_ord_var.ord_num.FIRST..sca_head_ord_var.ord_num.LAST');
 	cn_utils.appendcr(l_body_code,' 	         INSERT INTO cn_sca_headers_interface');
	cn_utils.appendcr(l_body_code,' 		         (sca_headers_interface_id, transaction_source, source_type,');
	cn_utils.appendcr(l_body_code,' 		          source_id, source_line_id, transaction_amount,');
	cn_utils.appendcr(l_body_code,' 		          object_version_number, processed_date, process_status, transaction_status,');
	cn_utils.appendcr(l_body_code,' 		          created_by, creation_Date, org_id,');

	split_long_sql(l_body_code,l_src_column_name(l_loop_cntr3),'SELECT');
	cn_utils.appendcr(l_body_code,')');

	cn_utils.appendcr(l_body_code,' 		     SELECT');
	cn_utils.appendcr(l_body_code,' 			    cn_sca_headers_interface_s.NEXTVAL, ''CN'' ,''ORD'',');
	cn_utils.appendcr(l_body_code,' 			    order_number, line_number, sca_head_ord_var.amt_sum(i),');
	cn_utils.appendcr(l_body_code,' 			    object_version_number, processed_date, ''SCA_UNPROCESSED'' ,''SCA_UNPROCESSED'' ,');
	cn_utils.appendcr(l_body_code,' 			    '||l_login_id||', SYSDATE, org_id,');

	split_long_sql(l_body_code,l_trx_src_column_name(l_loop_cntr3),'SELECT');

	cn_utils.appendcr(l_body_code,' 		     FROM  cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,' 		     WHERE order_number      = sca_head_ord_var.ord_num(i)');
	cn_utils.appendcr(l_body_code,' 		     AND   line_number       = sca_head_ord_var.line_num(i)');
	cn_utils.appendcr(l_body_code,' 		     AND   comm_lines_api_id = sca_head_ord_var.api_id(i)');
	cn_utils.appendcr(l_body_code,' 		     AND   org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'	   ELSE');
	cn_utils.appendcr(l_body_code,'	   	   l_upd_ccla := ''N'';');
	cn_utils.appendcr(l_body_code,'	   END IF;');

	cn_utils.appendcr(l_body_code,'	   IF l_upd_ccla = ''Y'' ');
	cn_utils.appendcr(l_body_code,'	   THEN');
	cn_utils.appendcr(l_body_code,'			OPEN sca_line_ord_cur;');
	cn_utils.appendcr(l_body_code,'			FETCH sca_line_ord_cur');
	cn_utils.appendcr(l_body_code,'			BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'				sca_line_rec_var.cshi_id,');
	cn_utils.appendcr(l_body_code,'				sca_line_rec_var.jrs_id,');
	cn_utils.appendcr(l_body_code,'				sca_line_rec_var.role_id,');
	cn_utils.appendcr(l_body_code,'				sca_line_rec_var.api_id,');
	cn_utils.appendcr(l_body_code,'			    sca_line_rec_var.ovn_no LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'			CLOSE sca_line_ord_cur;');

	cn_utils.appendcr(l_body_code,'			l_ord_csli_recs	:=	sca_line_rec_var.cshi_id.COUNT;');

	cn_utils.appendcr(l_body_code,'		    	FORALL j IN sca_line_rec_var.cshi_id.FIRST..sca_line_rec_var.cshi_id.LAST');
	cn_utils.appendcr(l_body_code,' 			         INSERT INTO cn_sca_lines_interface');
	cn_utils.appendcr(l_body_code,'					    (sca_lines_interface_id, sca_headers_interface_id, resource_id, role_id,');
	cn_utils.appendcr(l_body_code,'					     source_trx_id,org_id, object_version_number, created_by, creation_date)');
	cn_utils.appendcr(l_body_code,'					 VALUES');
	cn_utils.appendcr(l_body_code,'					    (cn_sca_lines_interface_s.NEXTVAL, sca_line_rec_var.cshi_id(j), sca_line_rec_var.jrs_id(j), sca_line_rec_var.role_id(j),');
	cn_utils.appendcr(l_body_code,'					     sca_line_rec_var.api_id(j),'||l_org_id||' ,sca_line_rec_var.ovn_no(j),'||l_user_id||', SYSDATE);');

	cn_utils.appendcr(l_body_code,'	    	OPEN sca_ord_ccla_cur;');
	cn_utils.appendcr(l_body_code,'	    	FETCH sca_ord_ccla_cur');
	cn_utils.appendcr(l_body_code,'	    	BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'	    		sca_ccla_id_var	LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'	    	CLOSE sca_ord_ccla_cur;');

	cn_utils.appendcr(l_body_code,'	    	l_ord_ccla_recs	:=	sca_ccla_id_var.COUNT;');

	cn_utils.appendcr(l_body_code,'	    	FORALL k in sca_ccla_id_var.FIRST..sca_ccla_id_var.LAST');
	cn_utils.appendcr(l_body_code,'	    		UPDATE cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'	    		SET');
	cn_utils.appendcr(l_body_code,'					adjust_status        = ''SCA_PENDING'',');
	cn_utils.appendcr(l_body_code,'					last_updated_by      = '||l_user_id||',');
	cn_utils.appendcr(l_body_code,'					last_update_login    = '||l_login_id||',');
	cn_utils.appendcr(l_body_code,'					last_update_date     = SYSDATE');
	cn_utils.appendcr(l_body_code,'	    		WHERE comm_lines_api_id  = sca_ccla_id_var(k)');
	cn_utils.appendcr(l_body_code,'                 AND   org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'     	x_return_status := FND_API.G_RET_STS_SUCCESS;');
	cn_utils.appendcr(l_body_code,'     	FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'                (p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'                 p_data     => x_msg_data,');
	cn_utils.appendcr(l_body_code,'           		p_encoded  => FND_API.G_TRUE);');
	cn_utils.appendcr(l_body_code,'	    END IF;');

	cn_utils.appendcr(l_body_code,'	   ELSIF l_trx_type = ''INV'' ');
	cn_utils.appendcr(l_body_code,'    THEN');

	cn_utils.appendcr(l_body_code,'		OPEN sca_head_inv_cur;');
	cn_utils.appendcr(l_body_code,'		FETCH sca_head_inv_cur');
	cn_utils.appendcr(l_body_code,'		BULK COLLECT INTO ');
	cn_utils.appendcr(l_body_code,'				 sca_head_inv_var.amt_sum,');
	cn_utils.appendcr(l_body_code,'				 sca_head_inv_var.api_id,');
	cn_utils.appendcr(l_body_code,'				 sca_head_inv_var.inv_num,');
	cn_utils.appendcr(l_body_code,'				 sca_head_inv_var.line_num LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'		CLOSE sca_head_inv_cur;');
	cn_utils.appendcr(l_body_code,'		IF sca_head_inv_var.api_id.COUNT > 0');
	cn_utils.appendcr(l_body_code,'		THEN');

	cn_utils.appendcr(l_body_code,'	   	   l_inv_cshi_recs	:=	sca_head_inv_var.api_id.COUNT;');

	cn_utils.appendcr(l_body_code,'	   	   l_upd_ccla := ''Y'';');
	cn_utils.appendcr(l_body_code,'        FORALL i IN sca_head_inv_var.inv_num.FIRST..sca_head_inv_var.inv_num.LAST');
	cn_utils.appendcr(l_body_code,' 	         INSERT INTO cn_sca_headers_interface');
	cn_utils.appendcr(l_body_code,' 		         (sca_headers_interface_id, transaction_source, source_type,');
	cn_utils.appendcr(l_body_code,' 		          source_id, source_line_id, transaction_amount,');
	cn_utils.appendcr(l_body_code,' 		          object_version_number, processed_date, process_status, transaction_status,');
	cn_utils.appendcr(l_body_code,' 		          created_by, creation_Date, org_id,');

	split_long_sql(l_body_code,l_src_column_name(l_loop_cntr3),'SELECT');
	cn_utils.appendcr(l_body_code,')');

	cn_utils.appendcr(l_body_code,' 		     SELECT');
	cn_utils.appendcr(l_body_code,' 			    cn_sca_headers_interface_s.NEXTVAL, ''CN'' ,''INV'',');
	cn_utils.appendcr(l_body_code,' 			    invoice_number, line_number, sca_head_inv_var.amt_sum(i),');
	cn_utils.appendcr(l_body_code,' 			    object_version_number, processed_date, ''SCA_UNPROCESSED'' ,''SCA_UNPROCESSED'' ,');
	cn_utils.appendcr(l_body_code,' 			    '||l_login_id||', SYSDATE, org_id,');

	split_long_sql(l_body_code,l_trx_src_column_name(l_loop_cntr3),'SELECT');

	cn_utils.appendcr(l_body_code,' 		     FROM  cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,' 		     WHERE invoice_number    = sca_head_inv_var.inv_num(i)');
	cn_utils.appendcr(l_body_code,' 		     AND   line_number       = sca_head_inv_var.line_num(i)');
	cn_utils.appendcr(l_body_code,' 		     AND   comm_lines_api_id = sca_head_inv_var.api_id(i)');
	cn_utils.appendcr(l_body_code,' 		     AND   org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'	    ELSE');
	cn_utils.appendcr(l_body_code,'	   	   l_upd_ccla := ''N'';');
	cn_utils.appendcr(l_body_code,'		END IF;');

	cn_utils.appendcr(l_body_code,'	    IF l_upd_ccla = ''Y'' ');
	cn_utils.appendcr(l_body_code,'	    THEN');
	cn_utils.appendcr(l_body_code,'			OPEN sca_line_inv_cur;');
	cn_utils.appendcr(l_body_code,'			FETCH sca_line_inv_cur');
	cn_utils.appendcr(l_body_code,'			BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'					sca_line_rec_var.cshi_id,');
	cn_utils.appendcr(l_body_code,'					sca_line_rec_var.jrs_id,');
	cn_utils.appendcr(l_body_code,'					sca_line_rec_var.role_id,');
	cn_utils.appendcr(l_body_code,'					sca_line_rec_var.api_id,');
	cn_utils.appendcr(l_body_code,'			        sca_line_rec_var.ovn_no LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'			CLOSE sca_line_inv_cur;');

	cn_utils.appendcr(l_body_code,'			l_inv_csli_recs	:=	sca_line_rec_var.cshi_id.COUNT;');

	cn_utils.appendcr(l_body_code,'	    	FORALL j IN sca_line_rec_var.cshi_id.FIRST..sca_line_rec_var.cshi_id.LAST');
	cn_utils.appendcr(l_body_code,' 		         INSERT INTO cn_sca_lines_interface');
	cn_utils.appendcr(l_body_code,'				     (sca_lines_interface_id, sca_headers_interface_id, resource_id, role_id,');
	cn_utils.appendcr(l_body_code,'				      source_trx_id,org_id, object_version_number, created_by, creation_date)');
	cn_utils.appendcr(l_body_code,'				 VALUES');
	cn_utils.appendcr(l_body_code,'				    (cn_sca_lines_interface_s.NEXTVAL, sca_line_rec_var.cshi_id(j), sca_line_rec_var.jrs_id(j), sca_line_rec_var.role_id(j),');
	cn_utils.appendcr(l_body_code,'				     sca_line_rec_var.api_id(j),'||l_org_id||' ,sca_line_rec_var.ovn_no(j),'||l_user_id||', SYSDATE);');

	cn_utils.appendcr(l_body_code,'	    	OPEN sca_inv_ccla_cur;');
	cn_utils.appendcr(l_body_code,'	    	FETCH sca_inv_ccla_cur');
	cn_utils.appendcr(l_body_code,'	    	BULK COLLECT INTO');
	cn_utils.appendcr(l_body_code,'	    		sca_ccla_id_var	LIMIT 1000;');
	cn_utils.appendcr(l_body_code,'	    	CLOSE sca_inv_ccla_cur;');

	cn_utils.appendcr(l_body_code,'	    	l_inv_ccla_recs	:=	sca_ccla_id_var.COUNT;');

	cn_utils.appendcr(l_body_code,'	    	FORALL k in sca_ccla_id_var.FIRST..sca_ccla_id_var.LAST');
	cn_utils.appendcr(l_body_code,'	    		UPDATE cn_comm_lines_api');
	cn_utils.appendcr(l_body_code,'	    		SET');
	cn_utils.appendcr(l_body_code,'					adjust_status        = ''SCA_PENDING'',');
	cn_utils.appendcr(l_body_code,'					last_updated_by      = '||l_user_id||',');
	cn_utils.appendcr(l_body_code,'					last_update_login    = '||l_login_id||',');
	cn_utils.appendcr(l_body_code,'					last_update_date     = SYSDATE');
	cn_utils.appendcr(l_body_code,'	    		WHERE comm_lines_api_id  = sca_ccla_id_var(k)');
	cn_utils.appendcr(l_body_code,' 		AND   org_id = p_org_id;');
	cn_utils.appendcr(l_body_code,'     	x_return_status := FND_API.G_RET_STS_SUCCESS;');
	cn_utils.appendcr(l_body_code,'     	FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'                (p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'                 p_data     => x_msg_data,');
	cn_utils.appendcr(l_body_code,'           		p_encoded  => FND_API.G_TRUE);');
	cn_utils.appendcr(l_body_code,'	    END IF;');
	cn_utils.appendcr(l_body_code,'END IF;');

	cn_utils.appendcr(l_body_code,'		debugmsg(''***** START OF PROCESSED RECORD SUMMARY *****'');');

	cn_utils.appendcr(l_body_code,'		debugmsg(''*RESET RECORDS SUMMARY*'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''-----------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''TRANSACTION TYPE*****|***RESET RECORD COUNT'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|---------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''ORDER TRANSACTION****|''||nvl(l_reset_ord_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''INVOICE TRANSACTION**|''||nvl(l_reset_inv_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|-----------------------|------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''ERROR NAME***********|***TRANSACTION TYPE****|*****#OF RECORDS'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|-----------------------|------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_ROLE_ERROR*******|***ORDER***************|''||nvl(l_ord_role_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_ROLE_ERROR*******|***INVOICE*************|''||nvl(l_inv_role_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|-----------------------|------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_RESOURCE_ERROR***|***ORDER***************|''||nvl(l_ord_res_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_RESOURCE_ERROR***|***INVOICE*************|''||nvl(l_inv_res_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|-----------------------|------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_DISTINCT_ERROR***|***ORDER***************|''||nvl(l_ord_dist_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_DISTINCT_ERROR***|***INVOICE*************|''||nvl(l_inv_dist_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|-----------------------|------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_REVENUE_ERROR****|***ORDER***************|''||nvl(l_ord_rev_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''SCA_REVENUE_ERROR****|***INVOICE*************|''||nvl(l_inv_rev_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|-----------------------|------------------'');');

	cn_utils.appendcr(l_body_code,'		debugmsg(''-------------------------|-----------------------|---------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''RECORDS INSERTED INTO****|***TRANSACTION TYPE****|****#OF RECORDS'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''-------------------------|-----------------------|---------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''CN_SCA_HEADERS_INTERFACE*| ORDER*****************|''||nvl(l_ord_cshi_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''CN_SCA_LINES_INTERFACE***| ORDER*****************|''||nvl(l_ord_csli_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''CN_SCA_HEADERS_INTERFACE*| INVOICE***************|''||nvl(l_inv_cshi_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''CN_SCA_LINES_INTERFACE***| INVOICE***************|''||nvl(l_inv_csli_recs,0));');
	cn_utils.appendcr(l_body_code,'		debugmsg(''-------------------------|-----------------------|---------------'');');

	cn_utils.appendcr(l_body_code,'		debugmsg(''RECORDS UPDATED IN CN_COMM_LINES_INTERFACE WITH SCA_PENDING STATUS'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|---------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''TRANSACTION TYPE*****|*******#OF RECORDS'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|---------------------'');');
	cn_utils.appendcr(l_body_code,'		debugmsg(''ORDER****************|''||l_ord_ccla_recs);');
	cn_utils.appendcr(l_body_code,'		debugmsg(''INVOICE**************|''||l_inv_ccla_recs);');
	cn_utils.appendcr(l_body_code,'		debugmsg(''---------------------|---------------------'');');

	cn_utils.appendcr(l_body_code,'		debugmsg(''***** END OF PROCESSED RECORD SUMMARY *****'');');

	cn_utils.appendcr(l_body_code,'EXCEPTION');
	cn_utils.appendcr(l_body_code,'	WHEN FND_API.G_EXC_ERROR');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'		ROLLBACK TO map_package_savepoint;');
	cn_utils.appendcr(l_body_code,'		debugmsg(''User Error In Dynamic Mapping Package'');');
	cn_utils.appendcr(l_body_code,'		x_return_status := FND_API.G_RET_STS_ERROR;');
	cn_utils.appendcr(l_body_code,'		FND_MSG_PUB.count_and_get');
	cn_utils.appendcr(l_body_code,'				(p_count    => x_msg_count,');
	cn_utils.appendcr(l_body_code,'				 p_data     => x_msg_data,');
	cn_utils.appendcr(l_body_code,'				 p_encoded  => FND_API.G_TRUE);');
  	cn_utils.appendcr(l_body_code,'	WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'		ROLLBACK TO map_package_savepoint;');
	cn_utils.appendcr(l_body_code,'		debugmsg(''Unexpected Error In Dynamic Mapping Package'');');
	cn_utils.appendcr(l_body_code,'		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'		FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'				(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'				 p_data    =>  x_msg_data,');
	cn_utils.appendcr(l_body_code,'				 p_encoded  => FND_API.G_TRUE);');
	cn_utils.appendcr(l_body_code,'	WHEN OTHERS');
	cn_utils.appendcr(l_body_code,'		THEN');
	cn_utils.appendcr(l_body_code,'		ROLLBACK TO map_package_savepoint;');
	cn_utils.appendcr(l_body_code,'		debugmsg(''Unhandled Error In Dynamic Mapping Package''||SQLCODE||'' ''||SQLERRM);');
	cn_utils.appendcr(l_body_code,'		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
	cn_utils.appendcr(l_body_code,'		FND_MSG_PUB.Count_And_Get');
	cn_utils.appendcr(l_body_code,'				(p_count   =>  x_msg_count,');
	cn_utils.appendcr(l_body_code,'				 p_data    =>  x_msg_data,');
	cn_utils.appendcr(l_body_code,'				 p_encoded  => FND_API.G_TRUE);');

	cn_utils.appendcr(l_body_code,'END map;');
	cn_utils.appendcr(l_body_code,'END '||l_pkg_name||';');


	-----+
	-- Call to install_package_object will pull out source code of CN_SCA_MAP_CN_204 package
	-- And compile it in the database
	-----+
	install_package_object(p_object_name    => l_pkg_name,
                               p_org_id         => p_org_id,
						   x_compile_status => l_compile_status,
						   x_return_status  => l_return_status,
						   x_msg_count		=> l_msg_count,
						   x_msg_data		=> l_msg_data);

	IF  (l_compile_status = 'COMPLETE')
	THEN
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		FND_MSG_PUB.count_and_get
				(p_count    => x_msg_count,
				 p_data     => x_msg_data,
				 p_encoded  => FND_API.G_TRUE);
	ELSE
		RAISE FND_API.G_EXC_ERROR;
	END IF;

--++ Unset org id for cn_utils package
	cn_utils.unset_org_id();

EXCEPTION
   	WHEN FND_API.G_EXC_ERROR THEN
		-- ROLLBACK TO generate_map_package;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count    =>      x_msg_count,
		 	 p_data         =>      x_msg_data);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count    =>      x_msg_count,
		 	 p_data     =>      x_msg_data);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count    =>      x_msg_count,
		 	 p_data     =>      x_msg_data);
END generate;
END cn_sca_interface_map_pvt;

/
