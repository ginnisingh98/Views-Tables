--------------------------------------------------------
--  DDL for Package Body CN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_UTILS" AS
-- $Header: cnsyutlb.pls 120.6 2005/09/28 05:11:50 apink ship $



  --+
  -- Private constants (these would have been macros in C) */
  --+

--  cr		CONSTANT	CHAR := CHR(10);	-- carriage retur
--cr		CONSTANT	CHAR := '
--  ';	-- carriage return

  indent_by	CONSTANT	NUMBER := 2;		-- # spaces to indent by

  -- a constant which has a null value for passing to the insert_row
  -- procedures of table handler APIs as the primary key value
  null_id	CONSTANT	NUMBER := NULL;

  g_org_id  NUMBER;

  null_org_id EXCEPTION;
  --+
  -- Private functions and procedures
  --+

  FUNCTION spaces (i NUMBER) RETURN VARCHAR2 IS
    str VARCHAR2(200) := '';
    j	NUMBER;
  BEGIN
    -- hard code some common values of i
    IF (i = 2) THEN
      RETURN '  ';
    ELSIF (i = 4) THEN
      RETURN '    ';
    ELSIF (i = 6) THEN
      RETURN '      ';
    ELSIF (i = 8) THEN
      RETURN '        ';
    ELSE
      FOR j in 1..i LOOP
	str := str || ' ';
      END LOOP;
    RETURN str;
    END IF;
  END spaces;


  --+
  -- Public Functions and Procedures
  --+

PROCEDURE set_org_id(p_org_id IN NUMBER)
IS
BEGIN
  g_org_id := p_org_id;
END;

PROCEDURE unset_org_id
IS
BEGIN
  g_org_id := null;
END;

  PROCEDURE delete_module (x_module_id	      cn_modules.module_id%TYPE,
			   x_package_spec_id  cn_objects.object_id%TYPE,
			   x_package_body_id  cn_objects.object_id%TYPE,
               p_org_id IN NUMBER) IS
  BEGIN
    DELETE FROM cn_source_all
     WHERE (object_id = x_package_spec_id
	        OR object_id = x_package_body_id)
       AND org_id = p_org_id ;

  END delete_module;


  PROCEDURE init_code (
	    X_object_id     cn_objects.object_id%TYPE,
	    code    IN OUT NOCOPY  cn_utils.code_type) IS
  BEGIN
    code.object_id := X_object_id;
    code.line := 1;
    code.indent := 0;
    code.text := NULL;
  END init_code;

-- for clob
  PROCEDURE init_code (
	    X_object_id     cn_objects.object_id%TYPE,
	    code    IN OUT NOCOPY  cn_utils.clob_code_type) IS
  BEGIN

    code.object_id := X_object_id;
    code.line := 1;
    code.indent := 0;
    DBMS_LOB.FREETEMPORARY(code.text);
    DBMS_LOB.CREATETEMPORARY(code.text,false,DBMS_LOB.CALL);

  END init_code;
--  end clob


  PROCEDURE indent ( code    IN OUT NOCOPY  cn_utils.code_type,
		     nesting_level   NUMBER) IS
  BEGIN
    code.indent := code.indent + (nesting_level * indent_by);
  END indent;


--for clob
  PROCEDURE indent ( code    IN OUT NOCOPY  cn_utils.clob_code_type,
		     nesting_level   NUMBER) IS
  BEGIN
    code.indent := code.indent + (nesting_level * indent_by);
  END indent;
--end clob

  PROCEDURE unindent ( code    IN OUT NOCOPY  cn_utils.code_type,
		       nesting_level   NUMBER) IS
  BEGIN
    code.indent := code.indent - (nesting_level * indent_by);
  END unindent;

--for clob
  PROCEDURE unindent ( code    IN OUT NOCOPY  cn_utils.clob_code_type,
		       nesting_level   NUMBER) IS
  BEGIN

  code.indent := code.indent - (nesting_level * indent_by);

  END unindent;
--end clob

  PROCEDURE append (code IN OUT NOCOPY cn_utils.code_type,
		    str2 VARCHAR2) IS
  BEGIN
    code.text := code.text || str2;
  END append;

--for clob
  PROCEDURE append (code IN OUT NOCOPY cn_utils.clob_code_type,
		    str2 VARCHAR2) IS
  BEGIN

    DBMS_LOB.WRITEAPPEND(code.text,length(str2),str2);

  END append;
--end clob

--for clob
  PROCEDURE append (code IN OUT NOCOPY cn_utils.clob_code_type,
                    expr clob,
		    str2 VARCHAR2) IS
  BEGIN

    DBMS_LOB.APPEND(code.text,expr);
    DBMS_LOB.WRITEAPPEND(code.text,length(str2),str2);

  END append;
--end clob




  PROCEDURE appind (code IN OUT NOCOPY cn_utils.code_type,
		    str2 VARCHAR2) IS
  BEGIN
    code.text := code.text || spaces(code.indent) || str2;
  END appind;


--for clob
  PROCEDURE appind (code IN OUT NOCOPY cn_utils.clob_code_type,
		    str2 VARCHAR2) IS
  BEGIN

    DBMS_LOB.WRITEAPPEND(code.text,length(str2),str2);

  END appind;
--end clob

  PROCEDURE appendcr (code IN OUT NOCOPY cn_utils.code_type) IS
  BEGIN
    code.text := code.text || '
';
    cn_utils.dump_line( code );
  END appendcr;

--for clob
  PROCEDURE appendcr (code IN OUT NOCOPY cn_utils.clob_code_type) IS
    line varchar2(32700);
  BEGIN

    line := '
';

    DBMS_LOB.WRITEAPPEND(code.text,length(line),line);
    cn_utils.dump_line( code );

  END appendcr;
--end clob

  PROCEDURE appendcr (code IN OUT NOCOPY cn_utils.code_type,
		      str2 VARCHAR2) IS
  BEGIN
    code.text := code.text || str2 || '
';
    cn_utils.dump_line( code );
  END appendcr;


  --for clob
  PROCEDURE appendcr (code IN OUT NOCOPY cn_utils.clob_code_type,
		      str2 VARCHAR2) IS
    line varchar2(32700);
  BEGIN

    line := str2 || '
';

    DBMS_LOB.WRITEAPPEND(code.text,length(line),line);
    cn_utils.dump_line( code );

  END appendcr;
  --end clob

  PROCEDURE appindcr (code IN OUT NOCOPY cn_utils.code_type,
		      str2 VARCHAR2) IS
  BEGIN
    code.text := code.text || spaces(code.indent) || str2 || '
';
    cn_utils.dump_line( code );
  END appindcr;

  PROCEDURE appindcr (code IN OUT NOCOPY cn_utils.clob_code_type,
		      str2 VARCHAR2) IS
	line varchar2(32700);
  BEGIN

    line :=  spaces(code.indent) || str2 || '
';

    DBMS_LOB.WRITEAPPEND(code.text,length(line),line);

    cn_utils.dump_line( code );

  END appindcr;

-- Note: STRIP works on the current line, before it is written out.
  PROCEDURE strip (code IN OUT NOCOPY cn_utils.code_type, i NUMBER) IS
  BEGIN
      code.text := substr(code.text, 1, length(code.text) - i);
  END strip;


-- AE 08-24-95
-- Note: STRIP_PREV works on the previous line, after it is written out.
  PROCEDURE strip_prev (code IN OUT NOCOPY cn_utils.code_type,
                        i NUMBER) IS
  BEGIN

    code.line := code.line - 1 ;		-- back up to prev line.
    code.text := NULL ;

    SELECT text
      INTO code.text
      FROM cn_source_all
     WHERE object_id = code.object_id
       AND line_no = code.line
       AND org_id = g_org_id;

-- remove number of bytes requested plus 1 for the CR at the end.
      code.text := substr(code.text, 1, length(code.text) - (i + 1));
      code.text := code.text || '
';

    UPDATE cn_source_all
       SET text = code.text
     WHERE object_id = code.object_id
       AND line_no = code.line
       AND org_id = g_org_id;

-- Restore the line number to its original value.
    code.line := code.line + 1 ;
    code.text := NULL ;

  END strip_prev;



 PROCEDURE dump_line ( code  IN OUT NOCOPY  cn_utils.code_type) IS

    l_pos NUMBER;
    l_text VARCHAR2(32000);
    l_text1 VARCHAR2(1900);
 BEGIN

   if (g_org_id is null) then
     raise null_org_id;
   end if;

      IF length(code.text) > 1900 then
         l_text := code.text;

         LOOP
            l_pos := instr(l_text,')');
            l_text1 :=substr(l_text,1,l_pos);
            INSERT into cn_source_all (source_id, object_id, line_no, text, org_id)
               VALUES (cn_source_s.NEXTVAL, code.object_id, code.line,l_text1, g_org_id);
            l_text :=  substr(l_text, l_pos +1 );

            IF nvl(l_pos,0) = 0 then
               INSERT into cn_source_all (source_id, object_id, line_no, text, org_id)
                  VALUES (cn_source_s.NEXTVAL, code.object_id, code.line,substr(l_text,l_pos), g_org_id);
                EXIT;
            END IF;

            IF l_pos= 0 then
   	     INSERT into cn_source_all (source_id, object_id, line_no, text, org_id)
   		VALUES (cn_source_s.NEXTVAL, code.object_id, code.line,substr(l_text,l_pos), g_org_id);
   	     EXIT;
            END IF;

            code.line := code.line + 1 ;

         END LOOP;

         code.text := NULL ;

      ELSE

         INSERT into cn_source (source_id, object_id, line_no, text, org_id)
             VALUES (cn_source_s.NEXTVAL, code.object_id, code.line, code.text, g_org_id );
   	code.text := NULL ;

      END IF;

      code.line := code.line + 1 ;

  END dump_line;

 --for clob
 PROCEDURE dump_line (code  IN OUT NOCOPY  cn_utils.clob_code_type) IS

     l_curr_pos NUMBER;
     l_text VARCHAR2(32000);
     l_text1 VARCHAR2(1900);
     codelen number;
     amount number;

     l_clob_text clob;
     l_prev_pos number;

    BEGIN


   if (g_org_id is null) then
     raise null_org_id;
   end if;

       l_prev_pos := 1;
       DBMS_LOB.CREATETEMPORARY(l_clob_text,FALSE,DBMS_LOB.CALL);

       -- If the length of the expression is less than 1900 characters
       -- the expression can be inserted directly into cn_source
       -- otherwise need to find the close braces and insert the string
       -- upto close bracess.
       -- l_curr_pos - is used to store the no. of characters between the previously found
       -- paranthesis and the newly found paranthesis
       -- l_prev_pos - is used to store the previous position of previously found parantesis

       IF DBMS_LOB.GETLENGTH(code.text) > 1900 then
          DBMS_LOB.COPY(l_clob_text,code.text,DBMS_LOB.GETLENGTH(code.text),1,1);
          LOOP

             l_curr_pos := abs(DBMS_LOB.INSTR(l_clob_text,')',l_prev_pos) - l_prev_pos) + 1;

             l_text1 :=DBMS_LOB.SUBSTR(l_clob_text,l_curr_pos,l_prev_pos);

             INSERT into cn_source (source_id, object_id, line_no, text, org_id)
                VALUES (cn_source_s.NEXTVAL, code.object_id, code.line,l_text1, g_org_id);

             DBMS_LOB.ERASE(l_clob_text,l_curr_pos,l_prev_pos);


             code.line := code.line + 1 ;
             l_prev_pos := l_prev_pos + l_curr_pos ;

             IF nvl(abs(DBMS_LOB.INSTR(l_clob_text,')',l_prev_pos)),0) = 0 THEN
             	INSERT into cn_source (source_id, object_id, line_no, text, org_id)
	                        VALUES (cn_source_s.NEXTVAL, code.object_id, code.line,DBMS_LOB.SUBSTR(l_clob_text,DBMS_LOB.GETLENGTH(code.text)-l_prev_pos,l_prev_pos), g_org_id);
                 EXIT;
             END IF;

          END LOOP;

          codelen := DBMS_LOB.GETLENGTH(code.text);

       ELSE
           codelen := DBMS_LOB.GETLENGTH(code.text);
           DBMS_LOB.READ(code.text,codelen,1,l_text1);
          INSERT into cn_source (source_id, object_id, line_no, text, org_id)
              VALUES (cn_source_s.NEXTVAL, code.object_id, code.line, l_text1, g_org_id);
       END IF;

          DBMS_LOB.ERASE(code.text,codelen,1);
          DBMS_LOB.FREETEMPORARY(l_clob_text);
          DBMS_LOB.FREETEMPORARY(code.text);
          DBMS_LOB.CREATETEMPORARY(code.text,FALSE,DBMS_LOB.CALL);

       code.line := code.line + 1 ;

  END dump_line;
  --end clob
--
-- Procedure Name
--   record_process_start
-- Purpose
--   This procedure generates some text to record the start of a process
-- History
--   17-NOV-93		Devesh Khatu		Created
--   22-MAR-94		Devesh Khatu		Modified
--
  PROCEDURE record_process_start (
	audit_type	VARCHAR2,
	audit_desc	VARCHAR2,
	parent_audit_id VARCHAR2,
	code	IN OUT NOCOPY cn_utils.code_type) IS
  BEGIN
    cn_debug.print_msg('record_process_start>>', 1);

    cn_utils.appindcr(code, 'x_proc_audit_id := NULL;   -- Will get a value in the call below');
    cn_utils.appindcr(code, 'cn_process_audits_pkg.insert_row(x_rowid, x_proc_audit_id, ' || parent_audit_id || ',');
    cn_utils.appindcr(code, '  ''' || audit_type || ''',' || audit_desc || ', NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL,'||g_org_id||');');
--AE  cn_utils.appindcr(code, 'COMMIT;');
    cn_utils.appendcr(code);

    cn_debug.print_msg('record_process_start<<', 1);
  END record_process_start;


--
-- Procedure Name
--   record_process_success
-- Purpose
--   Generates some boilerplate text to record success of the process
-- History
--   22-MAR-94		Devesh Khatu		Created
--
  PROCEDURE record_process_success (
	message 	VARCHAR2,
	code	IN OUT NOCOPY cn_utils.code_type) IS
  BEGIN
    cn_debug.print_msg('record_process_status>>', 1);
    -- Generate code to record success of the process
    cn_utils.appindcr(code, 'cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, 0, ' || message || ');');
--AE  cn_utils.appindcr(code, 'COMMIT;');
    cn_utils.appendcr(code);
    cn_debug.print_msg('record_process_success<<', 1);
  END record_process_success;


--
-- Procedure Name
--   record_process_exception
-- Purpose
--   Generates some boilerplate text to record exception of the process
-- History
--   22-MAR-94		Devesh Khatu		Created
--
  PROCEDURE record_process_exception (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	savepoint_name		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS
  BEGIN
    -- Generate code to handle errors
    cn_debug.print_msg('record_process_exception>>', 1);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'EXCEPTION');
    cn_utils.indent(code, 1);
    IF (savepoint_name IS NOT NULL) THEN
      cn_utils.appindcr(code, 'WHEN OTHERS THEN ROLLBACK TO ' || savepoint_name || ';');
    ELSE
--AE  cn_utils.appindcr(code, 'WHEN OTHERS THEN ROLLBACK;');
      cn_utils.appindcr(code, 'WHEN OTHERS THEN ');
    END IF;
    cn_utils.appindcr(code, 'cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, SQLCODE,');
    cn_utils.appindcr(code, '  SQLERRM);');
--AE  cn_utils.appindcr(code, 'COMMIT;');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'app_exception.raise_exception;');  --AE 04-28-95
    cn_utils.appendcr(code);
  END record_process_exception;

--for clob
--
-- Procedure Name
--   record_process_exception
-- Purpose
--   Generates some boilerplate text to record exception of the process
-- History
--   22-MAR-94		Devesh Khatu		Created
--
  PROCEDURE record_process_exception (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	savepoint_name		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS
  BEGIN
    -- Generate code to handle errors
    cn_debug.print_msg('record_process_exception>>', 1);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'EXCEPTION');
    cn_utils.indent(code, 1);
    IF (savepoint_name IS NOT NULL) THEN
      cn_utils.appindcr(code, 'WHEN OTHERS THEN ROLLBACK TO ' || savepoint_name || ';');
    ELSE
--AE  cn_utils.appindcr(code, 'WHEN OTHERS THEN ROLLBACK;');
      cn_utils.appindcr(code, 'WHEN OTHERS THEN ');
    END IF;
    cn_utils.appindcr(code, 'cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, SQLCODE,');
    cn_utils.appindcr(code, '  SQLERRM);');
--AE  cn_utils.appindcr(code, 'COMMIT;');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'app_exception.raise_exception;');  --AE 04-28-95
    cn_utils.appendcr(code);
  END record_process_exception;
--end clob

  PROCEDURE pkg_init_boilerplate (
	code		IN OUT NOCOPY cn_utils.code_type,
	package_name		cn_obj_packages_v.name%TYPE,
	description		cn_obj_packages_v.description%TYPE,
	object_type		VARCHAR2) IS

    X_userid		VARCHAR2(20);

  BEGIN
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code, '-- |                Copyright (c) 1994 Oracle Corporation                 | --');
    cn_utils.appendcr(code, '-- |                   Redwood Shores, California, USA                    | --');
    cn_utils.appendcr(code, '-- |                        All rights reserved.                          | --');
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code);

    SELECT user INTO X_userid FROM sys.dual;

    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code, '-- Package Name');
    cn_utils.appendcr(code, '--   ' || package_name);
    cn_utils.appendcr(code, '-- Purpose');
    cn_utils.appendcr(code, '--   ' || description);
    cn_utils.appendcr(code, '-- History');
    cn_utils.appendcr(code, '--   ' || SYSDATE || '          ' || X_userid || '            Created');
    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code);

    cn_utils.appendcr(code, 'SET VERIFY OFF');
    cn_utils.appendcr(code, 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;');
    cn_utils.appendcr(code, 'DEFINE PACKAGE_NAME="' || LOWER(package_name) || '"');

    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE ' || package_name || ' AS');
    ELSE
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY ' || package_name || ' AS');
    END IF;
    cn_utils.appendcr(code);

  END pkg_init_boilerplate;


--for clob
  PROCEDURE pkg_init_boilerplate (
	code		IN OUT NOCOPY cn_utils.clob_code_type,
	package_name		cn_obj_packages_v.name%TYPE,
	description		cn_obj_packages_v.description%TYPE,
	object_type		VARCHAR2) IS
    X_userid		VARCHAR2(20);

  BEGIN
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code, '-- |                Copyright (c) 1994 Oracle Corporation                 | --');
    cn_utils.appendcr(code, '-- |                   Redwood Shores, California, USA                    | --');
    cn_utils.appendcr(code, '-- |                        All rights reserved.                          | --');
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code);

    SELECT user INTO X_userid FROM sys.dual;

    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code, '-- Package Name');
    cn_utils.appendcr(code, '--   ' || package_name);
    cn_utils.appendcr(code, '-- Purpose');
    cn_utils.appendcr(code, '--   ' || description);
    cn_utils.appendcr(code, '-- History');
    cn_utils.appendcr(code, '--   ' || SYSDATE || '          ' || X_userid || '            Created');
    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code);

    cn_utils.appendcr(code, 'SET VERIFY OFF');
    cn_utils.appendcr(code, 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;');
    cn_utils.appendcr(code, 'DEFINE PACKAGE_NAME="' || LOWER(package_name) || '"');

    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE ' || package_name || ' AS');
    ELSE
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY ' || package_name || ' AS');
    END IF;
    cn_utils.appendcr(code);

  END pkg_init_boilerplate;

--end clob


  PROCEDURE pkg_end_boilerplate (
	code		IN OUT NOCOPY cn_utils.code_type,
	object_type		cn_obj_packages_v.object_type%TYPE) IS

  BEGIN
    cn_utils.appendcr(code, 'END &' || 'PACKAGE_NAME;');
    cn_utils.appendcr(code, '/');
    cn_utils.appendcr(code);
    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, 'SHOW ERRORS PACKAGE &' || 'PACKAGE_NAME');
    ELSE
      cn_utils.appendcr(code, 'SHOW ERRORS PACKAGE BODY &' || 'PACKAGE_NAME');
    END IF;
    cn_utils.appendcr(code, 'SELECT TEXT ');
    cn_utils.appendcr(code, '  FROM USER_ERRORS');

    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, '  WHERE TYPE = ''PACKAGE''');
    ELSE
      cn_utils.appendcr(code, '  WHERE TYPE = ''PACKAGE BODY''');
    END IF;
    cn_utils.appendcr(code, '    AND NAME = UPPER(''&' || 'PACKAGE_NAME'');');
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, 'COMMIT;');
    cn_utils.appendcr(code, '-- EXIT;');                --AE 03-22-96
    cn_utils.appendcr(code);

  END pkg_end_boilerplate;

--for clob
  PROCEDURE pkg_end_boilerplate (
	code		IN OUT NOCOPY cn_utils.clob_code_type,
	object_type		cn_obj_packages_v.object_type%TYPE) IS

  BEGIN
    cn_utils.appendcr(code, 'END &' || 'PACKAGE_NAME;');
    cn_utils.appendcr(code, '/');
    cn_utils.appendcr(code);
    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, 'SHOW ERRORS PACKAGE &' || 'PACKAGE_NAME');
    ELSE
      cn_utils.appendcr(code, 'SHOW ERRORS PACKAGE BODY &' || 'PACKAGE_NAME');
    END IF;
    cn_utils.appendcr(code, 'SELECT TEXT ');
    cn_utils.appendcr(code, '  FROM USER_ERRORS');

    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, '  WHERE TYPE = ''PACKAGE''');
    ELSE
      cn_utils.appendcr(code, '  WHERE TYPE = ''PACKAGE BODY''');
    END IF;
    cn_utils.appendcr(code, '    AND NAME = UPPER(''&' || 'PACKAGE_NAME'');');
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, 'COMMIT;');
    cn_utils.appendcr(code, '-- EXIT;');                --AE 03-22-96
    cn_utils.appendcr(code);

  END pkg_end_boilerplate;
--end clob

  PROCEDURE pkg_init (
	module_id		    cn_modules.module_id%TYPE,
	package_name		    cn_obj_packages_v.name%TYPE,
	package_org_append          VARCHAR2,
	package_type		    cn_obj_packages_v.package_type%TYPE,
	package_spec_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_body_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_spec_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
	package_body_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,

	spec_code	    IN OUT NOCOPY  cn_utils.code_type,
	body_code	    IN OUT NOCOPY  cn_utils.code_type) IS

    x_rowid			ROWID;
    null_id			NUMBER;

  BEGIN

   if (g_org_id is null) then
     raise null_org_id;
   end if;

    -- Find the package objects    AE 01-08-96
    cn_utils.find_object(package_name,'PKS',package_spec_id, package_spec_desc, g_org_id);
    cn_utils.find_object(package_name,'PKB',package_body_id, package_body_desc, g_org_id);

    -- Delete module source code from cn_source
    -- Delete module object dependencies for this module
    cn_utils.delete_module(module_id, package_spec_id, package_body_id, g_org_id);

    cn_utils.init_code (package_spec_id, spec_code);	   -- AE 05-02-95
    cn_utils.init_code (package_body_id, body_code);	   -- AE 05-02-95

    cn_utils.pkg_init_boilerplate(spec_code, package_name|| package_org_append, package_spec_desc, 'PKS');
    cn_utils.pkg_init_boilerplate(body_code, package_name|| package_org_append, package_body_desc, 'PKB');

    cn_utils.indent(spec_code, 1);
    cn_utils.indent(body_code, 1);

  END pkg_init;


  PROCEDURE pkg_end (
	package_name		cn_obj_packages_v.name%TYPE,
	package_spec_id 	cn_obj_packages_v.package_id%TYPE,
	package_body_id 	cn_obj_packages_v.package_id%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
	body_code	IN OUT NOCOPY cn_utils.code_type) IS

  BEGIN
    cn_utils.unindent(spec_code, 1);
    cn_utils.unindent(body_code, 1);

    cn_utils.pkg_end_boilerplate(spec_code, 'PKS');     --AE 04-28-95
    cn_utils.pkg_end_boilerplate(body_code, 'PKB');     --AE 04-28-95

  END pkg_end;

--for clob
    PROCEDURE pkg_end (
  	package_name		cn_obj_packages_v.name%TYPE,
  	package_spec_id 	cn_obj_packages_v.package_id%TYPE,
  	package_body_id 	cn_obj_packages_v.package_id%TYPE,
  	spec_code	IN OUT NOCOPY cn_utils.clob_code_type,
  	body_code	IN OUT NOCOPY cn_utils.clob_code_type) IS

    BEGIN
      cn_utils.unindent(spec_code, 1);
      cn_utils.unindent(body_code, 1);

      cn_utils.pkg_end_boilerplate(spec_code, 'PKS');     --AE 04-28-95
      cn_utils.pkg_end_boilerplate(body_code, 'PKB');     --AE 04-28-95

    END pkg_end;
--end clob


  -- overloaded for use in formula generation
  PROCEDURE pkg_init_boilerplate (code		IN OUT NOCOPY cn_utils.code_type,
				  package_name		cn_obj_packages_v.name%TYPE,
				  description		cn_obj_packages_v.description%TYPE,
				  object_type		VARCHAR2,
				  package_flag          VARCHAR2 ) IS

     X_userid		VARCHAR2(20);
  BEGIN
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code, '-- |                Copyright (c) 1994 Oracle Corporation                 | --');
    cn_utils.appendcr(code, '-- |                   Redwood Shores, California, USA                    | --');
    cn_utils.appendcr(code, '-- |                        All rights reserved.                          | --');
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code);

    SELECT user INTO X_userid FROM sys.dual;

    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code, '-- Package Name');
    cn_utils.appendcr(code, '--   ' || package_name);
    cn_utils.appendcr(code, '-- Purpose');
    cn_utils.appendcr(code, '--   ' || description);
    cn_utils.appendcr(code, '-- History');
    cn_utils.appendcr(code, '--   ' || SYSDATE || '          ' || X_userid || '            Created');
    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code);

    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE ' || package_name || ' AS');
    ELSE
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY ' || package_name || ' AS');
    END IF;
    cn_utils.appendcr(code);

  END pkg_init_boilerplate;

--for clob

-- overloaded for use in formula generation
  PROCEDURE pkg_init_boilerplate (code		IN OUT NOCOPY cn_utils.clob_code_type,
				  package_name		cn_obj_packages_v.name%TYPE,
				  description		cn_obj_packages_v.description%TYPE,
				  object_type		VARCHAR2,
				  package_flag          VARCHAR2 ) IS

     X_userid		VARCHAR2(20);
  BEGIN
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code, '-- |                Copyright (c) 1994 Oracle Corporation                 | --');
    cn_utils.appendcr(code, '-- |                   Redwood Shores, California, USA                    | --');
    cn_utils.appendcr(code, '-- |                        All rights reserved.                          | --');
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code);

    SELECT user INTO X_userid FROM sys.dual;

    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code, '-- Package Name');
    cn_utils.appendcr(code, '--   ' || package_name);
    cn_utils.appendcr(code, '-- Purpose');
    cn_utils.appendcr(code, '--   ' || description);
    cn_utils.appendcr(code, '-- History');
    cn_utils.appendcr(code, '--   ' || SYSDATE || '          ' || X_userid || '            Created');
    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code);

    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE ' || package_name || ' AS');
    ELSE
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY ' || package_name || ' AS');
    END IF;
    cn_utils.appendcr(code);

  END pkg_init_boilerplate;


--end clob

  -- overloaded for use in formula generation, adding package_flag = 'FORMULA'
  PROCEDURE pkg_init (
		      module_id		    cn_modules.module_id%TYPE,
		      package_name	    cn_obj_packages_v.name%TYPE,
		      package_org_append    VARCHAR2,
		      package_type	    cn_obj_packages_v.package_type%TYPE,
		      package_flag          VARCHAR2,
		      package_spec_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
		      package_body_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
		      package_spec_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
		      package_body_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
		      spec_code	    IN OUT NOCOPY  cn_utils.code_type,
		      body_code	    IN OUT NOCOPY  cn_utils.code_type) IS

    x_rowid			ROWID;
    null_id			NUMBER;

  BEGIN

   if (g_org_id is null) then
     raise null_org_id;
   end if;

    -- Find the package objects    AE 01-08-96
    cn_utils.find_object(package_name,'PKS',package_spec_id, package_spec_desc, g_org_id);
    cn_utils.find_object(package_name,'PKB',package_body_id, package_body_desc, g_org_id);

    -- Delete module source code from cn_source
    -- Delete module object dependencies for this module
    cn_utils.delete_module(module_id, package_spec_id, package_body_id, g_org_id);

    cn_utils.init_code (package_spec_id, spec_code);	   -- AE 05-02-95
    cn_utils.init_code (package_body_id, body_code);	   -- AE 05-02-95

    cn_utils.pkg_init_boilerplate(spec_code, package_name, package_spec_desc, 'PKS', package_flag);
    cn_utils.pkg_init_boilerplate(body_code, package_name, package_body_desc, 'PKB', package_flag);

    cn_utils.indent(spec_code, 1);
    cn_utils.indent(body_code, 1);

  END pkg_init;

  --for clob
    -- overloaded for use in formula generation, adding package_flag = 'FORMULA'
    PROCEDURE pkg_init (
  		      module_id		    cn_modules.module_id%TYPE,
  		      package_name	    cn_obj_packages_v.name%TYPE,
  		      package_org_append    VARCHAR2,
  		      package_type	    cn_obj_packages_v.package_type%TYPE,
  		      package_flag          VARCHAR2,
  		      package_spec_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
  		      package_body_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
  		      package_spec_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
  		      package_body_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
  		      spec_code	    IN OUT NOCOPY  cn_utils.clob_code_type,
  		      body_code	    IN OUT NOCOPY  cn_utils.clob_code_type) IS

      x_rowid			ROWID;
      null_id			NUMBER;

    BEGIN

   if (g_org_id is null) then
     raise null_org_id;
   end if;

      -- Find the package objects    AE 01-08-96
      cn_utils.find_object(package_name,'PKS',package_spec_id, package_spec_desc, g_org_id);
      cn_utils.find_object(package_name,'PKB',package_body_id, package_body_desc, g_org_id);

      -- Delete module source code from cn_source
      -- Delete module object dependencies for this module
      cn_utils.delete_module(module_id, package_spec_id, package_body_id, g_org_id);

      cn_utils.init_code (package_spec_id, spec_code);	   -- AE 05-02-95
      cn_utils.init_code (package_body_id, body_code);	   -- AE 05-02-95

      cn_utils.pkg_init_boilerplate(spec_code, package_name, package_spec_desc, 'PKS', package_flag);
      cn_utils.pkg_init_boilerplate(body_code, package_name, package_body_desc, 'PKB', package_flag);

      cn_utils.indent(spec_code, 1);
      cn_utils.indent(body_code, 1);

    END pkg_init;
  --end clob


  -- overloaded procedure used for formula generation
  PROCEDURE pkg_end_boilerplate (code		IN OUT NOCOPY cn_utils.code_type,
				 package_name		cn_obj_packages_v.name%TYPE,
				 object_type		cn_obj_packages_v.object_type%TYPE) IS

  BEGIN
    cn_utils.appendcr(code, 'END ' || package_name || ' ;');
    cn_utils.appendcr(code);
  END pkg_end_boilerplate;

--for clob
  PROCEDURE pkg_end_boilerplate (code		IN OUT NOCOPY cn_utils.clob_code_type,
				 package_name		cn_obj_packages_v.name%TYPE,
				 object_type		cn_obj_packages_v.object_type%TYPE) IS

  BEGIN
    cn_utils.appendcr(code, 'END ' || package_name || ' ;');
    cn_utils.appendcr(code);
  END pkg_end_boilerplate;
--end clob

  -- overloaded procedure for use in formula generation
  PROCEDURE pkg_end (package_name		cn_obj_packages_v.name%TYPE,
		     spec_code	IN OUT NOCOPY cn_utils.code_type,
		     body_code	IN OUT NOCOPY cn_utils.code_type) IS

  BEGIN
    cn_utils.unindent(spec_code, 1);
    cn_utils.unindent(body_code, 1);

    cn_utils.pkg_end_boilerplate(spec_code, package_name,'PKS');
    cn_utils.pkg_end_boilerplate(body_code, package_name,'PKB');
  END pkg_end;

--for clob
  -- overloaded procedure for use in formula generation
  PROCEDURE pkg_end (package_name		cn_obj_packages_v.name%TYPE,
		     spec_code	IN OUT NOCOPY cn_utils.clob_code_type,
		     body_code	IN OUT NOCOPY cn_utils.clob_code_type) IS

  BEGIN
    cn_utils.unindent(spec_code, 1);
    cn_utils.unindent(body_code, 1);

    cn_utils.pkg_end_boilerplate(spec_code, package_name,'PKS');
    cn_utils.pkg_end_boilerplate(body_code, package_name,'PKB');
  END pkg_end;

--end clob


  PROCEDURE proc_init_boilerplate (
	code		IN OUT NOCOPY cn_utils.code_type,
	procedure_name		cn_obj_procedures_v.name%TYPE,
	description		cn_obj_procedures_v.description%TYPE) IS

    X_userid	VARCHAR2(20);

  BEGIN
    SELECT user INTO X_userid FROM sys.dual;

    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code, '-- Procedure Name');
    cn_utils.appendcr(code, '--   ' || procedure_name);
    cn_utils.appendcr(code, '-- Purpose');
    cn_utils.appendcr(code, '--   ' || description);
    cn_utils.appendcr(code, '-- History');
    cn_utils.appendcr(code, '--   ' || TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI') || '      ' || X_userid || '        Created');
    cn_utils.appendcr(code, '--');

  END proc_init_boilerplate;

--for clob
  PROCEDURE proc_init_boilerplate (
	code		IN OUT NOCOPY cn_utils.clob_code_type,
	procedure_name		cn_obj_procedures_v.name%TYPE,
	description		cn_obj_procedures_v.description%TYPE) IS

    X_userid	VARCHAR2(20);

  BEGIN
    SELECT user INTO X_userid FROM sys.dual;

    cn_utils.appendcr(code, '--');
    cn_utils.appendcr(code, '-- Procedure Name');
    cn_utils.appendcr(code, '--   ' || procedure_name);
    cn_utils.appendcr(code, '-- Purpose');
    cn_utils.appendcr(code, '--   ' || description);
    cn_utils.appendcr(code, '-- History');
    cn_utils.appendcr(code, '--   ' || TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI') || '      ' || X_userid || '        Created');
    cn_utils.appendcr(code, '--');

  END proc_init_boilerplate;
--end clob

  PROCEDURE proc_init (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	description		cn_obj_procedures_v.description%TYPE,
	parameter_list		cn_obj_procedures_v.parameter_list%TYPE,
	procedure_type		cn_obj_procedures_v.procedure_type%TYPE,
	return_type		cn_obj_procedures_v.return_type%TYPE,
	package_id		cn_obj_procedures_v.package_id%TYPE,
	repository_id		cn_obj_procedures_v.repository_id%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.code_type,
	body_code	IN OUT NOCOPY cn_utils.code_type) IS

    X_rowid			ROWID;

  BEGIN
    cn_debug.print_msg('proc_init>>', 1);

    -- Generate boilerplate comments
    cn_utils.proc_init_boilerplate(spec_code, procedure_name, description);
    cn_utils.proc_init_boilerplate(body_code, procedure_name, description);

    -- Generate procedure header and parameters in both spec and body
    IF (procedure_type = 'P') THEN
      cn_utils.appind(spec_code, 'PROCEDURE ' || procedure_name);
      cn_utils.appind(body_code, 'PROCEDURE ' || procedure_name);
    ELSIF (procedure_type = 'F') THEN
      cn_utils.appind(spec_code, 'FUNCTION ' || procedure_name);
      cn_utils.appind(body_code, 'FUNCTION ' || procedure_name);
    END IF;

    IF (parameter_list IS NOT NULL) THEN
      cn_utils.append(spec_code, ' (' || parameter_list || ')');
      cn_utils.append(body_code, ' (' || parameter_list || ')');
    END IF;

    IF (procedure_type = 'F') THEN
      cn_utils.append(spec_code, ' RETURN ' || return_type);
      cn_utils.append(body_code, ' RETURN ' || return_type);
    END IF;

    cn_utils.appendcr(spec_code, ';');
    cn_utils.appendcr(spec_code);
    cn_utils.appendcr(body_code, ' IS');

    cn_debug.print_msg('proc_init<<', 1);
  END proc_init;

--for clob
  PROCEDURE proc_init (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	description		cn_obj_procedures_v.description%TYPE,
	parameter_list		cn_obj_procedures_v.parameter_list%TYPE,
	procedure_type		cn_obj_procedures_v.procedure_type%TYPE,
	return_type		cn_obj_procedures_v.return_type%TYPE,
	package_id		cn_obj_procedures_v.package_id%TYPE,
	repository_id		cn_obj_procedures_v.repository_id%TYPE,
	spec_code	IN OUT NOCOPY cn_utils.clob_code_type,
	body_code	IN OUT NOCOPY cn_utils.clob_code_type) IS

    X_rowid			ROWID;

  BEGIN
    cn_debug.print_msg('proc_init>>', 1);

    -- Generate boilerplate comments
    cn_utils.proc_init_boilerplate(spec_code, procedure_name, description);
    cn_utils.proc_init_boilerplate(body_code, procedure_name, description);

    -- Generate procedure header and parameters in both spec and body
    IF (procedure_type = 'P') THEN
      cn_utils.appind(spec_code, 'PROCEDURE ' || procedure_name);
      cn_utils.appind(body_code, 'PROCEDURE ' || procedure_name);
    ELSIF (procedure_type = 'F') THEN
      cn_utils.appind(spec_code, 'FUNCTION ' || procedure_name);
      cn_utils.appind(body_code, 'FUNCTION ' || procedure_name);
    END IF;

    IF (parameter_list IS NOT NULL) THEN
      cn_utils.append(spec_code, ' (' || parameter_list || ')');
      cn_utils.append(body_code, ' (' || parameter_list || ')');
    END IF;

    IF (procedure_type = 'F') THEN
      cn_utils.append(spec_code, ' RETURN ' || return_type);
      cn_utils.append(body_code, ' RETURN ' || return_type);
    END IF;

    cn_utils.appendcr(spec_code, ';');
    cn_utils.appendcr(spec_code);
    cn_utils.appendcr(body_code, ' IS');

    cn_debug.print_msg('proc_init<<', 1);
  END proc_init;

--end clob


  PROCEDURE proc_begin (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	generate_debug_pipe	VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS

  BEGIN
    cn_debug.print_msg('proc_begin>>', 1);

    -- Generate begin procedure statement
    cn_utils.appindcr(code, 'BEGIN');
    cn_utils.indent(code, 1);

    IF (generate_debug_pipe = 'Y') THEN
      -- Generate code to initialize a debug pipe if a pipename has been specified
      cn_utils.appindcr(code, 'IF (debug_pipe IS NOT NULL) THEN');
      cn_utils.appindcr(code, '  cn_debug.init_pipe(debug_pipe, debug_level);');
      cn_utils.appindcr(code, 'END IF;');
    END IF;

    cn_utils.appendcr(code);

    cn_debug.print_msg('proc_begin<<', 1);
  END proc_begin;

--for clob
  PROCEDURE proc_begin (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	generate_debug_pipe	VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS
  BEGIN
    cn_debug.print_msg('proc_begin>>', 1);

    -- Generate begin procedure statement
    cn_utils.appindcr(code, 'BEGIN');
    cn_utils.indent(code, 1);

    IF (generate_debug_pipe = 'Y') THEN
      -- Generate code to initialize a debug pipe if a pipename has been specified
      cn_utils.appindcr(code, 'IF (debug_pipe IS NOT NULL) THEN');
      cn_utils.appindcr(code, '  cn_debug.init_pipe(debug_pipe, debug_level);');
      cn_utils.appindcr(code, 'END IF;');
    END IF;

    cn_utils.appendcr(code);

    cn_debug.print_msg('proc_begin<<', 1);
  END proc_begin;
--end clob


  PROCEDURE proc_end (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	exception_flag		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS

  BEGIN
    cn_debug.print_msg('proc_end>>', 1);

    cn_utils.appendcr(code);
    cn_utils.appendcr(code);
    IF (exception_flag = 'Y') THEN
      cn_utils.record_process_exception(procedure_name, NULL, code);
    END IF;

    -- Generate end of procedure statement
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'END ' || procedure_name || ';');
    cn_utils.appendcr(code);

    cn_debug.print_msg('proc_end<<', 1);
  END proc_end;

--for clob
  PROCEDURE proc_end (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	exception_flag		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS

  BEGIN
    cn_debug.print_msg('proc_end>>', 1);

    cn_utils.appendcr(code);
    cn_utils.appendcr(code);
    IF (exception_flag = 'Y') THEN
      cn_utils.record_process_exception(procedure_name, NULL, code);
    END IF;

    -- Generate end of procedure statement
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'END ' || procedure_name || ';');
    cn_utils.appendcr(code);

    cn_debug.print_msg('proc_end<<', 1);
  END proc_end;

--end clob

-- AE 05-02-95.  gen_create_xxxxxx procedures commented out. not used.
/*
  --+
  -- Procedure Name
  --   gen_create_table
  -- Purpose
  --   generates the code for creating a table
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE gen_create_table (
	X_table_id		cn_obj_tables_v.table_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS

    -- Declare cursor for getting columns that need to be created
    CURSOR columns_cursor IS
      SELECT cocv.name column_name, data_type, data_length, data_scale,
	     primary_key, nullable
	FROM cn_obj_columns_v cocv
	WHERE cocv.table_id = X_table_id
	ORDER BY cocv.position;

    table_name		cn_obj_tables_v.name%TYPE;

  BEGIN
    cn_debug.print_msg('gen_create_table>>', 1);

      table_name := cn_utils.get_object_name(X_table_id);

      cn_utils.init_code( X_table_id, code);

      appendcr(code, 'CREATE TABLE ' || LOWER(table_name) || ' (');
      FOR c IN columns_cursor LOOP
	cn_utils.append(code, '  ' || LOWER(c.column_name) || '         ' || UPPER(c.data_type));
	IF (c.data_length IS NOT NULL) THEN
	  IF (c.data_scale IS NOT NULL) THEN
	    cn_utils.append(code, '(' || c.data_length || ',' || c.data_scale || ')     ');
	  ELSE
	    cn_utils.append(code, '(' || c.data_length || ')    ');
	  END IF;
	END IF;
	IF (c.primary_key = 'Y') THEN
	  cn_utils.append(code, '       PRIMARY KEY');
	END IF;
	IF (c.nullable = 'N') THEN
	  cn_utils.appendcr(code, '     NOT NULL,');
	ELSE
	  cn_utils.appendcr(code, '     NULL,');
	END IF;
      END LOOP;
      IF (SQL%FOUND) THEN
	strip(code, 2); 		-- remove trailing comma
      END IF;
      cn_utils.appendcr(code, ')');

      -- Note: How does one get storage parameters for the table?
    cn_debug.print_msg('gen_create_table<<', 1);
  END gen_create_table;


  --+
  -- Procedure Name
  --   gen_create_index
  -- Purpose
  --   generates the code for creating an index
  -- History
  --   02-FEB-94		Devesh Khatu		Created
  --+
  PROCEDURE gen_create_index (
	X_index_id		cn_obj_indexes_v.index_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS

    CURSOR index_columns IS
      SELECT cocv.name column_name
	FROM cn_obj_columns_v cocv, cn_column_ind_maps ccim
	WHERE cocv.column_id = ccim.column_id
	  AND ccim.index_id = X_index_id;
    X_name			cn_obj_indexes_v.name%TYPE;
    X_table_name		cn_obj_tables_v.name%TYPE;
    X_unique_flag		cn_obj_indexes_v.unique_flag%TYPE;

  BEGIN
    cn_debug.print_msg('gen_create_index>>', 1);

    SELECT coiv.name, cotv.name, unique_flag
      INTO X_name, X_table_name, X_unique_flag
      FROM cn_obj_indexes_v coiv, cn_obj_tables_v cotv
      WHERE cotv.table_id = coiv.table_id
	AND coiv.index_id = X_index_id;

    cn_utils.init_code( X_index_id, code);
    cn_utils.appind(code, 'CREATE ');
    IF (X_unique_flag = 'Y') THEN
      cn_utils.appind(code, 'UNIQUE ');
    END IF;
    cn_utils.appindcr(code, 'INDEX ' || LOWER(X_name) || ' ON ' || LOWER(X_table_name) || '(');
    FOR ic IN index_columns LOOP
      cn_utils.appindcr(code, LOWER(ic.column_name) || ',');
    END LOOP;
    cn_utils.strip(code, 2);		-- remove trailing comma
    cn_utils.appindcr(code, ')');
    -- Shouldn't the next statement be customizable? -- Devesh
    cn_utils.appindcr(code, 'PCTFREE 10');

    cn_debug.print_msg('gen_create_index<<', 1);
  END gen_create_index;


  --+
  -- Procedure Name
  --   gen_create_sequence
  -- Purpose
  --   generates the code for creating a sequence
  -- History
  --   02-FEB-94		Devesh Khatu		Created
  --+
  PROCEDURE gen_create_sequence (
	X_sequence_id		cn_obj_sequences_v.sequence_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS
    X_name			cn_obj_sequences_v.name%TYPE;
    X_start_value		cn_obj_sequences_v.start_value%TYPE;
    X_increment_value		cn_obj_sequences_v.increment_value%TYPE;
  BEGIN
    cn_debug.print_msg('gen_create_sequence>>', 1);

    SELECT name, start_value, increment_value
      INTO X_name, X_start_value, X_increment_value
      FROM cn_obj_sequences_v cosv
      WHERE cosv.sequence_id = X_sequence_id;

    cn_utils.init_code( X_sequence_id, code);
    cn_utils.appindcr(code, 'CREATE SEQUENCE ' || LOWER(X_name));
    cn_utils.indent(code, 1);

    IF (X_increment_value IS NOT NULL) THEN
      cn_utils.appindcr(code, 'INCREMENT BY ' || X_increment_value);
    END IF;
    IF (X_start_value IS NOT NULL) THEN
      cn_utils.appindcr(code, 'START WITH ' || X_start_value);
    END IF;

    cn_utils.appindcr(code, 'NOMINVALUE');
    cn_utils.appindcr(code, 'NOMAXVALUE');
    cn_utils.appindcr(code, 'NOCYCLE');
    cn_utils.appindcr(code, 'CACHE 20');
    cn_utils.appindcr(code, 'NOORDER');
    cn_utils.unindent(code, 1);

    cn_debug.print_msg('gen_create_sequence<<', 1);
  END gen_create_sequence;


  --+
  -- Procedure Name
  --   gen_create_dblink
  -- Purpose
  --   generates the code for creating a dblink
  -- History
  --   11-JUN-94		Devesh Khatu		Created
  --+
  PROCEDURE gen_create_dblink (
	X_dblink_id		cn_obj_dblinks_v.dblink_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS
    X_name			cn_obj_dblinks_v.name%TYPE;
    X_connect_to_username	cn_obj_dblinks_v.connect_to_username%TYPE;
    X_connect_to_password	cn_obj_dblinks_v.connect_to_password%TYPE;
    X_connect_to_host		cn_obj_dblinks_v.connect_to_host%TYPE;
  BEGIN
    cn_debug.print_msg('gen_create_dblink>>', 1);

    SELECT name, connect_to_username, connect_to_password, connect_to_host
      INTO X_name, X_connect_to_username, X_connect_to_password, X_connect_to_host
      FROM cn_obj_dblinks_v codv
      WHERE codv.dblink_id = X_dblink_id;

    cn_utils.init_code( X_dblink_id, code);
    cn_utils.appindcr(code, 'CREATE DATABASE LINK ' || LOWER(X_name));
    cn_utils.indent(code, 1);
    cn_utils.appind(code, 'CONNECT TO ' || LOWER(X_connect_to_username));
    cn_utils.appendcr(code, ' IDENTIFIED BY ' || LOWER(X_connect_to_password));
    cn_utils.appindcr(code, 'USING ''' || LOWER(X_connect_to_host) || '''');
    cn_utils.unindent(code, 1);

    cn_debug.print_msg('gen_create_dblink<<', 1);
  END gen_create_dblink;


  --+
  -- Procedure Name
  --   gen_create_subprogram
  -- Purpose
  --   generates the code for creating a subprogram
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --+
  PROCEDURE gen_create_subprogram (
	X_object_id		cn_objects.object_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS

    X_statement_text		cn_obj_packages_v.statement_text%TYPE;
  BEGIN
    cn_debug.print_msg('gen_create_subprogram>>', 1);

    SELECT statement_text
      INTO X_statement_text
      FROM cn_objects co
      WHERE co.object_id = X_object_id;

    cn_utils.init_code( X_object_id, code);
    cn_utils.appendcr(code, 'CREATE OR REPLACE ' || X_statement_text);

    cn_debug.print_msg('gen_create_subprogram<<', 1);
  END gen_create_subprogram;


  --+
  -- Procedure Name
  --   gen_create_package
  -- Purpose
  --   generates the code for creating a package, or a package body
  -- History
  --   18-NOV-93		Devesh Khatu		Created
  --   16-MAR-94		Devesh Khatu		Modified
  --+
  PROCEDURE gen_create_package (
	X_object_id		cn_objects.object_id%TYPE,
	dump_to_file		VARCHAR2,
	code	IN OUT NOCOPY 	cn_utils.code_type) IS

    X_statement_text		cn_obj_packages_v.statement_text%TYPE;
    X_object_type		cn_obj_packages_v.object_type%TYPE;
    X_name			cn_obj_packages_v.name%TYPE;
    X_description		cn_obj_packages_v.description%TYPE;

  BEGIN
    cn_debug.print_msg('gen_create_package>>', 1);

    SELECT statement_text, object_type, name, description
      INTO X_statement_text, X_object_type, X_name, X_description
      FROM cn_objects co
      WHERE co.object_id = X_object_id;

    cn_utils.init_code( X_object_id, code);

    IF (dump_to_file = 'N') THEN
      IF (X_object_type = 'PKS') THEN
	cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE ' || LOWER(X_name) || ' AS');
      ELSE
	cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY ' || LOWER(X_name) || ' AS');
      END IF;

      cn_utils.appendcr(code, X_statement_text);
      cn_utils.appendcr(code, 'END ' || LOWER(X_name) || ';');

    ELSIF (dump_to_file = 'Y') THEN
      cn_utils.pkg_init_boilerplate(code, X_name, X_description, X_object_type);
      cn_utils.appendcr(code, X_statement_text);
      cn_utils.pkg_end_boilerplate(code, X_object_type);
    END IF;

    cn_debug.print_msg('gen_create_package<<', 1);
  END gen_create_package;


  --+
  -- Procedure Name
  --   gen_create_trigger
  -- Purpose
  --   generates the code for creating a trigger
  -- History
  --   14-DEC-93		Devesh Khatu		Created
  --+
  PROCEDURE gen_create_trigger (
	X_trigger_id		cn_obj_triggers_v.trigger_id%TYPE,
	code		IN OUT NOCOPY cn_utils.code_type) IS

    row 	cn_obj_triggers_v%ROWTYPE;
    table_name	cn_obj_tables_v.name%TYPE;

    CURSOR triggering_columns IS
      SELECT cocv.name
	FROM cn_obj_columns_v cocv, cn_column_trg_maps cctm
	WHERE cocv.column_id = cctm.column_id
	  AND cctm.trigger_id = X_trigger_id;

  BEGIN
    cn_debug.print_msg('gen_create_trigger>>', 1);
    cn_utils.init_code( X_trigger_id, code);

    row.trigger_id := X_trigger_id;
    cn_obj_triggers_v_pkg.select_row(row);
    cn_utils.appendcr(code, 'CREATE OR REPLACE TRIGGER ' || LOWER(row.name));
    cn_utils.append(code, 'AFTER ');

    IF (row.triggering_event = 'I') THEN
      cn_utils.append(code, 'INSERT OF ');
    ELSIF (row.triggering_event = 'U') THEN
      cn_utils.append(code, 'UPDATE OF ');
    ELSIF (row.triggering_event = 'D') THEN
      cn_utils.append(code, 'DELETE OF ');
    END IF;

    FOR tc IN triggering_columns LOOP
      cn_utils.append(code, tc.name || ', ');
    END LOOP;

    strip(code, 2);		-- remove trailing comma
    cn_utils.append(code, ' ON ');

    SELECT name INTO table_name
      FROM cn_obj_tables_v
      WHERE table_id = row.table_id;

    cn_utils.appendcr(code, LOWER(table_name));
    cn_utils.appendcr(code, 'FOR EACH ROW');

    IF (row.when_clause IS NOT NULL) THEN
      cn_utils.appendcr(code, 'WHEN ' || row.when_clause);
    END IF;

    cn_utils.appendcr(code, row.statement_text);
    cn_debug.print_msg('gen_create_trigger<<', 1);
  END gen_create_trigger;


  PROCEDURE gen_instantiation_code (
	X_object_id		cn_objects.object_id%TYPE,
	dump_to_file		VARCHAR2,
	code_text	IN OUT NOCOPY VARCHAR2) IS

    code			cn_utils.code_type;
    X_object_type		cn_objects.object_type%TYPE;

  BEGIN
    cn_debug.print_msg('gen_instantiation_code>>', 1);
    cn_debug.print_msg('gen_instantiation_code: X_object_id     = ' || X_object_id, 1);

    SELECT object_type INTO X_object_type
      FROM cn_objects co
      WHERE co.object_id = X_object_id;

    IF (X_object_type = 'TBL') THEN             -- table
      gen_create_table(X_object_id, code);
    ELSIF (X_object_type = 'PKS') THEN          -- package spec
      gen_create_package(X_object_id, dump_to_file, code);
    ELSIF (X_object_type = 'PKB') THEN          -- package body
      gen_create_package(X_object_id, dump_to_file, code);
    ELSIF (X_object_type = 'PRC') THEN          -- procedure
      gen_create_subprogram(X_object_id, code);
    ELSIF (X_object_type = 'TRG') THEN          -- trigger
      gen_create_trigger(X_object_id, code);
    ELSIF (X_object_type = 'SEQ') THEN          -- sequence
      gen_create_sequence(X_object_id, code);
    ELSIF (X_object_type = 'DBL') THEN          -- database link
      gen_create_dblink(X_object_id, code);
    ELSIF (X_object_type = 'IND') THEN          -- index
      gen_create_index(X_object_id, code);
    END IF;
    code_text := code.text;

    cn_debug.print_msg('gen_instantiation_code<<', 1);
  END gen_instantiation_code;
*/
-- AE 05-02-95.  gen_create_xxxxxx procedures commented out. not used.





  FUNCTION get_proc_audit_id
	RETURN cn_process_audits.process_audit_id%TYPE IS
    x_process_audit_id		cn_process_audits.process_audit_id%TYPE;
  BEGIN
    SELECT cn_process_audits_s.NEXTVAL
      INTO x_process_audit_id
      FROM sys.dual;
    RETURN x_process_audit_id;
  END get_proc_audit_id;


  FUNCTION get_object_id
	RETURN cn_objects.object_id%TYPE IS
    x_object_id 	cn_objects.object_id%TYPE;
  BEGIN
    SELECT cn_objects_s.NEXTVAL
      INTO x_object_id
      FROM sys.dual;
    RETURN x_object_id;
  END get_object_id;


  FUNCTION get_mod_obj_depends_id
	RETURN cn_mod_obj_depends.mod_obj_depends_id%TYPE IS
    x_mod_obj_depends_id	cn_mod_obj_depends.mod_obj_depends_id%TYPE;
  BEGIN
    SELECT cn_mod_obj_depends_s.NEXTVAL
      INTO x_mod_obj_depends_id
      FROM sys.dual;
    RETURN x_mod_obj_depends_id;
  END get_mod_obj_depends_id;


  FUNCTION get_object_name (X_object_id cn_objects.object_id%TYPE, p_org_id IN NUMBER)
	RETURN cn_objects.name%TYPE IS
    X_name	cn_objects.name%TYPE;
  BEGIN
    SELECT name INTO X_name
      FROM cn_objects
      WHERE object_id = X_object_id
       AND org_id = p_org_id;
    RETURN X_name;
  END get_object_name;


  FUNCTION get_repository (X_module_id	cn_modules.module_id%TYPE, p_org_id IN NUMBER)
	RETURN cn_repositories.repository_id%TYPE IS
    X_repository_id	cn_repositories.repository_id%TYPE;
  BEGIN
    SELECT repository_id INTO X_repository_id
      FROM cn_modules
      WHERE module_id = X_module_id
      AND org_id = p_org_id;
    RETURN X_repository_id;
  END get_repository;



  FUNCTION get_event (X_module_id	cn_modules.module_id%TYPE, p_org_id IN NUMBER)
	RETURN cn_events.event_id%TYPE IS
    X_event_id		cn_events.event_id%TYPE;
  BEGIN
    SELECT event_id INTO X_event_id
      FROM cn_modules
      WHERE module_id = X_module_id
      AND org_id = p_org_id;
    RETURN X_event_id;
  END get_event;


  PROCEDURE find_object (
	x_name			cn_objects.name%TYPE,
	x_object_type		cn_objects.object_type%TYPE,
	x_object_id	IN OUT NOCOPY cn_objects.object_id%TYPE,
	x_description	IN OUT NOCOPY cn_objects.description%TYPE,
    p_org_id IN NUMBER ) IS

  BEGIN
    SELECT object_id, description
      INTO x_object_id, x_description
      FROM cn_objects
     WHERE name = x_name
       AND object_type = x_object_type
       AND org_id = p_org_id ;
  END find_object;



  PROCEDURE compute_hierarchy_levels (
	X_dim_hierarchy_id	cn_dim_hierarchies.dim_hierarchy_id%TYPE) IS
  BEGIN
    cn_debug.print_msg('compute_hierarchy_levels>>', 1);

--    DELETE FROM cn_tmp_hierarchy_levels;
--    INSERT INTO cn_tmp_hierarchy_levels
--	SELECT value_id, MAX(LEVEL) FROM cn_hierarchy_edges
--	  WHERE dim_hierarchy_id = X_dim_hierarchy_id
--	  CONNECT BY PRIOR parent_value_id = value_id
--		       AND dim_hierarchy_id = X_dim_hierarchy_id
--	  GROUP BY value_id;
--    UPDATE cn_hierarchy_nodes chn
--	SET hierarchy_level = (
--	    SELECT hierarchy_level FROM cn_tmp_hierarchy_levels cthl
--	     WHERE chn.value_id = cthl.value_id)
--     WHERE chn.dim_hierarchy_id = X_dim_hierarchy_id;
--    DELETE FROM cn_tmp_hierarchy_levels;

--    cn_debug.print_msg('compute_hierarchy_levels<<', 1);
  END compute_hierarchy_levels;

  --+
  -- Procedure Name
  --   next_period
  -- Purpose
  --   get the next period
  -- History
  --   24-Nov-98	Angela Chung		Created
  --+
   FUNCTION next_period (x_period_id NUMBER, p_org_id NUMBER)
   RETURN cn_periods.period_id%TYPE IS
      l_next_period_id cn_periods.period_id%TYPE;
   BEGIN
      SELECT MIN(period_id)
       INTO l_next_period_id
        FROM cn_period_statuses_all
       WHERE period_id > x_period_id
         AND period_status IN ('F', 'O')
         AND org_id = p_org_id;

      RETURN l_next_period_id;

   EXCEPTION
      WHEN no_data_found THEN
         RETURN NULL;
   END next_period;

END cn_utils;

/
