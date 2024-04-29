--------------------------------------------------------
--  DDL for Package Body OE_PC_CONSTRAINTS_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_CONSTRAINTS_ADMIN_PUB" as
/* $Header: OEXPPCAB.pls 115.15 2004/05/24 06:00:40 shewgupt ship $ */

-- global variables
G_PKG_NAME	 constant varchar2(30) := 'Oe_PC_Constraints_Admin_Pub';

-------------------------------------------------------------------
PROCEDURE Generate_Constraint_API
(
   p_api_version_number	       in  number,
   p_application_id            in  number,
   p_entity_short_name         in  varchar2,
x_script_file_name out nocopy varchar2,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

)
-------------------------------------------------------------------
IS
  l_fileDir			varchar2(255);
  l_dirSeperator        varchar2(1);
  l_fileNameTag	      varchar2(255);
  l_sqlFileName	      varchar2(255);
  l_specFileName        varchar2(255);
  l_bodyFileName        varchar2(255);
  l_sqlFileHandle	      UTL_FILE.FILE_TYPE;
  l_specFileHandle	UTL_FILE.FILE_TYPE;
  l_bodyFileHandle	UTL_FILE.FILE_TYPE;
  l_pkg_name		varchar2(30);
  l_fileNumber		number;
  l_pkg_spec		LONG;
  l_pkg_body 		LONG;
  l_return_status  	varchar2(1);
  l_msg_data           varchar2(255);
  l_msg_count          number;
  l_app_short_name     OE_PC_ENTITIES_V.APPLICATION_SHORT_NAME%TYPE;
  l_db_object_name     OE_PC_ENTITIES_V.DB_OBJECT_NAME%TYPE;
  l_entity_id          OE_PC_ENTITIES_V.ENTITY_ID%TYPE;

  l_Q                  varchar2(3) := '''';
  l_NULL               varchar2(10) := l_Q || l_Q;
  l_DUMMY_COL          varchar2(10) := l_Q || '#NULL'|| l_Q;




  CURSOR C_FILENO
  IS SELECT to_char(OE_PC_FILE_SEQUENCE_S.nextval)
  FROM DUAL;

  CURSOR C_APP
  IS SELECT application_short_name, db_object_name, entity_id
  FROM OE_PC_ENTITIES_V
  where application_id = p_application_id
  AND   entity_short_name = p_entity_short_name;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
     IF l_debug_level  > 0 THEN
   OE_Debug_PUB.ADD('Generate_Constraint_API: begin ');
   END IF;
   OPEN C_APP;
   Fetch C_APP into l_app_short_name, l_db_object_name, l_entity_id;
   Close C_APP;
        IF l_debug_level  > 0 THEN
   OE_Debug_PUB.ADD('Entity ID: '||l_entity_id);
   END IF;


   l_fileDir := ltrim(rtrim(fnd_profile.value('OE_PC_FILE_DIRECTORY')));
   --------------------------------------------
   -- ***** Remove this
   if (l_fileDir IS NULL OR l_fileDir = '' ) then
     -- l_fileDir := '/oedev/oe/11.8/debug_log';
      l_fileDir := '/sqlcom/log';
   end if;
   --------------------------------------------
   if (l_fileDir IS NULL OR l_fileDir = '') then
      -- raise error;
      fnd_message.set_name('OE', 'OE_PC_FILE_DIRECTORY_MISSING');
      --
     IF l_debug_level  > 0 THEN
      OE_Debug_PUB.ADD('couldnt find the log file directory.. profile missing..returning. End');
     END IF;
      --
      -- ** In future, the PCFWK admin may maintain a log file and log the errors in it.
      return;
   end if;
   --
     IF l_debug_level  > 0 THEN
   OE_Debug_PUB.ADD('log file directory : ' || l_fileDir);
   END IF;
   --
   open  C_FILENO;
   fetch C_FILENO into l_fileNumber;
   close C_FILENO;


   -- file names: example:
   --     SQL File   : OEPC200_OE_HEADER.SQL
   --     Spec File  : OEPC200_OE_HEADER_S.PLS
   --     Body File  : OEPC200_OE_HEADER_B.PLS
   l_fileNameTag := 'OEPC'|| to_char(l_fileNumber) || '_' ||
                       l_app_short_name ||'_' || p_entity_short_name;
   l_sqlFileName := l_fileNameTag || '.SQL';
   l_specFileName := l_fileNameTag || '_S.PLS';
   l_bodyFileName := l_fileNameTag || '_B.PLS';

   --
     IF l_debug_level  > 0 THEN
   OE_Debug_PUB.ADD('script (SQL) file name : ' || l_sqlFileName || ' DIR: ' ||l_fileDir);
   END IF;
   --
   l_sqlFileHandle := utl_file.fopen(
		      	location	=>  l_fileDir
			      ,filename	=>  l_sqlFileName
	  	            ,open_mode	=>  'w'
				);
   --
     IF l_debug_level  > 0 THEN
   OE_Debug_PUB.ADD('Spec file name : ' || l_specFileName || ' DIR: ' ||l_fileDir);
     END IF;
   --
   l_specFileHandle := utl_file.fopen(
		      	location	=>  l_fileDir
			      ,filename	=>  l_specFileName
	  	            ,open_mode	=>  'w'
				);
   --
     IF l_debug_level  > 0 THEN
   OE_Debug_PUB.ADD('Body file name : ' || l_bodyFileName || ' DIR: ' ||l_fileDir);
   END IF;
   --
   l_bodyFileHandle := utl_file.fopen(
		      	location	=>  l_fileDir
			      ,filename	=>  l_bodyFileName
	  	            ,open_mode	=>  'w'
				);


  l_pkg_name := l_app_short_name || '_' || p_entity_short_name || '_PCFWK';

  -- generate the package spec and body
  -- ** enhance the standardization of the code by applying the prevailing coding standards
  -- ** and by adding more comments
  -----------------------------------------------------------------------------------------
  -- generate spec
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA ');
  utl_file.put_line(l_specFileHandle, '--  All rights reserved. ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  FILENAME ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--   ' || l_specFileName);
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  DESCRIPTION ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--      Spec of package ' || l_pkg_name );
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  NOTES ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK; ');
  utl_file.put_line(l_specFileHandle, ' ');
  utl_file.put_line(l_specFileHandle, 'CREATE OR REPLACE PACKAGE ' || l_pkg_name);
  utl_file.put_line(l_specFileHandle, 'AS ');
  utl_file.put_line(l_specFileHandle, ' ');
  utl_file.put_line(l_specFileHandle, 'g_record  ' || l_db_object_name ||'%ROWTYPE;');
  utl_file.put_line(l_specFileHandle, '------------------------------------------- ');
  utl_file.put_line(l_specFileHandle, '--  Start of Comments ');
  utl_file.put_line(l_specFileHandle, '--  API name    Is_Op_Constrained ');
  utl_file.put_line(l_specFileHandle, '--  Type        Public ');
  utl_file.put_line(l_specFileHandle, '--  Function ');
  utl_file.put_line(l_specFileHandle, '--     You should use this function to check for constraints ');
  utl_file.put_line(l_specFileHandle, '--     against operations on ' || p_entity_short_name || ' or its columns ');
  utl_file.put_line(l_specFileHandle, '--  Pre-reqs ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  Parameters ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  Return ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  Version     Current version = 1.0 ');
  utl_file.put_line(l_specFileHandle, '--              Initial version = 1.0 ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  Notes ');
  utl_file.put_line(l_specFileHandle, '--  ');
  utl_file.put_line(l_specFileHandle, '--  End of Comments ');
  utl_file.put_line(l_specFileHandle, 'FUNCTION Is_Op_Constrained ');
  utl_file.put_line(l_specFileHandle, ' ( ');
  utl_file.put_line(l_specFileHandle, '   p_responsibility_id             in number ');
  utl_file.put_line(l_specFileHandle, '   ,p_application_id               in number default NULL'); --added for bug3631547
  utl_file.put_line(l_specFileHandle, '   ,p_operation                    in varchar2 ');
  utl_file.put_line(l_specFileHandle, '   ,p_column_name                  in varchar2 default NULL');
  utl_file.put_line(l_specFileHandle, '   ,p_record                       in '||l_db_object_name || '%ROWTYPE');
  utl_file.put_line(l_specFileHandle, '   ,p_check_all_cols_constraint    in varchar2 default ''Y''');
  utl_file.put_line(l_specFileHandle, '   ,p_is_caller_defaulting         in varchar2 default ''N''');
utl_file.put_line(l_specFileHandle, ' ,x_constraint_id out nocopy number');

utl_file.put_line(l_specFileHandle, ' ,x_constraining_conditions_grp out nocopy number');

utl_file.put_line(l_specFileHandle, ' ,x_on_operation_action out nocopy number');

  utl_file.put_line(l_specFileHandle, ' ) ');
  utl_file.put_line(l_specFileHandle, ' RETURN NUMBER; ');
  utl_file.put_line(l_specFileHandle, ' ');
  utl_file.put_line(l_specFileHandle, '------------------------------------------- ');
  utl_file.put_line(l_specFileHandle, 'END ' || l_pkg_name || ';');
  utl_file.put_line(l_specFileHandle , '/');
  utl_file.put_line(l_specFileHandle , 'COMMIT;');
  --utl_file.put_line(l_specFileHandle , 'EXIT;');
  utl_file.fclose(l_specFileHandle);
     IF l_debug_level  > 0 THEN
  OE_Debug_PUB.ADD('generate body');
     END IF;

  --generate body
  utl_file.put_line(l_bodyFileHandle, '--  ');
  utl_file.put_line(l_bodyFileHandle, '--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA ');
  utl_file.put_line(l_bodyFileHandle, '--  All rights reserved. ');
  utl_file.put_line(l_bodyFileHandle, '--  ');
  utl_file.put_line(l_bodyFileHandle, '--  FILENAME ');
  utl_file.put_line(l_bodyFileHandle, '--  ');
  utl_file.put_line(l_bodyFileHandle, '--   ' || l_bodyFileName);
  utl_file.put_line(l_bodyFileHandle, '--  ');
  utl_file.put_line(l_bodyFileHandle, '--  DESCRIPTION ');
  utl_file.put_line(l_bodyFileHandle, '--  ');
  utl_file.put_line(l_bodyFileHandle, '--      Body of package ' || l_pkg_name );
  utl_file.put_line(l_bodyFileHandle, '--  ');
  utl_file.put_line(l_bodyFileHandle, '--  NOTES ');
  utl_file.put_line(l_bodyFileHandle, '--  ');
  utl_file.put_line(l_bodyFileHandle, 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK; ');
  utl_file.put_line(l_bodyFileHandle, ' ');

  utl_file.put_line(l_bodyFileHandle , 'CREATE OR REPLACE PACKAGE  BODY ' || l_pkg_name);
  utl_file.put_line(l_bodyFileHandle , 'AS ');
  utl_file.put_line(l_bodyFileHandle , ' ');

  utl_file.put_line(l_bodyFileHandle , '-- Globals ');
  utl_file.put_line(l_bodyFileHandle , '------------------------------------------- ');
  utl_file.put_line(l_bodyFileHandle , ' g_application_id     constant number := ' || to_char(p_application_id) || ';');
  utl_file.put_line(l_bodyFileHandle , ' g_entity_id          constant number := ' || to_char(l_entity_id) || ';');
  utl_file.put_line(l_bodyFileHandle , ' g_entity_short_name  constant varchar2(15) := ' || '''' ||p_entity_short_name || '''' || ';');
     IF l_debug_level  > 0 THEN
  OE_Debug_PUB.ADD('generateValidate_Constraint ');
     END IF;

  utl_file.put_line(l_bodyFileHandle , '------------------------------------------- ');
  utl_file.put_line(l_bodyFileHandle , 'PROCEDURE Validate_Constraint ');
  utl_file.put_line(l_bodyFileHandle , ' ( ');
  utl_file.put_line(l_bodyFileHandle , '    p_constraint_id                in  number');
utl_file.put_line(l_bodyFileHandle , ' ,x_condition_count out nocopy number');

utl_file.put_line(l_bodyFileHandle , ' ,x_valid_condition_group out nocopy number');

utl_file.put_line(l_bodyFileHandle , ' ,x_result out nocopy number');

  utl_file.put_line(l_bodyFileHandle , ' ) ');
  utl_file.put_line(l_bodyFileHandle , ' IS ');
  utl_file.put_line(l_bodyFileHandle , '  ');
  utl_file.put_line(l_bodyFileHandle , ' --Cursors');
  utl_file.put_line(l_bodyFileHandle , ' CURSOR C_R ');
  utl_file.put_line(l_bodyFileHandle , ' IS SELECT ');
  utl_file.put_line(l_bodyFileHandle , '       condition_id,');
  utl_file.put_line(l_bodyFileHandle , '       group_number, ');
  utl_file.put_line(l_bodyFileHandle , '       modifier_flag, ');
  utl_file.put_line(l_bodyFileHandle , '       validation_application_id,');
  utl_file.put_line(l_bodyFileHandle , '       validation_entity_short_name,');
  utl_file.put_line(l_bodyFileHandle , '       validation_tmplt_short_name,');
  utl_file.put_line(l_bodyFileHandle , '       record_set_short_name,');
  utl_file.put_line(l_bodyFileHandle , '       scope_op,');
  utl_file.put_line(l_bodyFileHandle , '       validation_pkg,');
  utl_file.put_line(l_bodyFileHandle , '       validation_proc');
  utl_file.put_line(l_bodyFileHandle , ' FROM  oe_pc_conditions_v');
  utl_file.put_line(l_bodyFileHandle , ' WHERE constraint_id = p_constraint_id');
  utl_file.put_line(l_bodyFileHandle , ' ORDER BY group_number;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '   ');
  utl_file.put_line(l_bodyFileHandle , ' TYPE ConstraintRule_Rec_Type IS RECORD');
  utl_file.put_line(l_bodyFileHandle , ' (  ');
  utl_file.put_line(l_bodyFileHandle , '     condition_id                   number,');
  utl_file.put_line(l_bodyFileHandle , '     group_number                   number,');
  utl_file.put_line(l_bodyFileHandle , '     modifier_flag	                varchar2(1),');
  utl_file.put_line(l_bodyFileHandle , '     validation_application_id      number,');
  utl_file.put_line(l_bodyFileHandle , '     validation_entity_short_name   varchar2(15),');
  utl_file.put_line(l_bodyFileHandle , '     validation_tmplt_short_name    varchar2(8),');
  utl_file.put_line(l_bodyFileHandle , '     record_set_short_name          varchar2(8),');
  utl_file.put_line(l_bodyFileHandle , '     scope_op	                      varchar2(3),');
  utl_file.put_line(l_bodyFileHandle , '     validation_pkg	                varchar2(30),');
  utl_file.put_line(l_bodyFileHandle , '     validation_proc	          varchar2(30)');
  utl_file.put_line(l_bodyFileHandle , ' );');
  utl_file.put_line(l_bodyFileHandle , '   ');
  utl_file.put_line(l_bodyFileHandle , ' l_constraintRuleRec  ConstraintRule_Rec_Type;');
  utl_file.put_line(l_bodyFileHandle , ' l_dsqlCursor		  integer;');
  utl_file.put_line(l_bodyFileHandle , ' l_dynamicSqlString	  varchar2(2000);');
  utl_file.put_line(l_bodyFileHandle , ' l_rule_count	        number;');
  utl_file.put_line(l_bodyFileHandle , ' l_ConstrainedStatus  number;');
  utl_file.put_line(l_bodyFileHandle , ' l_dummy              integer;');
  utl_file.put_line(l_bodyFileHandle , ' i                    number;');
  utl_file.put_line(l_bodyFileHandle , ' l_tempResult         boolean;');
  utl_file.put_line(l_bodyFileHandle , ' l_result_01          number;');
  utl_file.put_line(l_bodyFileHandle , ' l_currGrpNumber      number;');
  utl_file.put_line(l_bodyFileHandle , ' l_currGrpResult      boolean;');
  utl_file.put_line(l_bodyFileHandle , 'BEGIN ');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '   l_ConstrainedStatus := OE_PC_GLOBALS.NO;');
  utl_file.put_line(l_bodyFileHandle , '   l_rule_count := 0;');
  utl_file.put_line(l_bodyFileHandle , '   i := 0;');
  utl_file.put_line(l_bodyFileHandle , '   l_currGrpNumber := -1;');
  utl_file.put_line(l_bodyFileHandle , '   l_currGrpResult := FALSE;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '   OPEN C_R;');
  utl_file.put_line(l_bodyFileHandle , '   LOOP  -- validatate constraining conditions');
  utl_file.put_line(l_bodyFileHandle , '      -- fetch all the validation procedure_names assigned to the constraint and ');
  utl_file.put_line(l_bodyFileHandle , '	    -- build the dynamic sql string ');
  utl_file.put_line(l_bodyFileHandle , '      FETCH C_R into ');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.condition_id,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.group_number,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.modifier_flag,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.validation_application_id,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.validation_entity_short_name,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.validation_tmplt_short_name,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.record_set_short_name,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.scope_op,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.validation_pkg,');
  utl_file.put_line(l_bodyFileHandle , '		  	l_constraintRuleRec.validation_proc;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- EXIT from loop ');
  utl_file.put_line(l_bodyFileHandle , '      IF (C_R%NOTFOUND) THEN');
  utl_file.put_line(l_bodyFileHandle , '         IF (l_currGrpNumber != -1 AND l_currGrpResult = TRUE) THEN');
  utl_file.put_line(l_bodyFileHandle , '            l_ConstrainedStatus := OE_PC_GLOBALS.YES;');
  utl_file.put_line(l_bodyFileHandle , '         END IF;');
  utl_file.put_line(l_bodyFileHandle , '         EXIT;  -- exit the loop');
  utl_file.put_line(l_bodyFileHandle , '      END IF;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      IF (l_currGrpNumber != l_constraintRuleRec.group_number) THEN');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '         -- we are entering the new group of conditions.. ');
  utl_file.put_line(l_bodyFileHandle , '         -- groups are ORd together, so if the previous group was evaluated');
  utl_file.put_line(l_bodyFileHandle , '         -- to TRUE (OE_PC_GLOBALS.YES) then no need to evaluvate this group.');
  utl_file.put_line(l_bodyFileHandle , '         IF (l_currGrpResult = TRUE) THEN');
  utl_file.put_line(l_bodyFileHandle , '            l_ConstrainedStatus := OE_PC_GLOBALS.YES;');
  utl_file.put_line(l_bodyFileHandle , '            EXIT;  -- exit the loop');
  utl_file.put_line(l_bodyFileHandle , '         END IF;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '         -- previous group did not evaluvate to TRUE, so lets pursue this new group');
  utl_file.put_line(l_bodyFileHandle , '         l_currGrpNumber := l_constraintRuleRec.group_number;');
  utl_file.put_line(l_bodyFileHandle , '         l_currGrpResult := FALSE;');
  utl_file.put_line(l_bodyFileHandle , '         i := 0;');
  utl_file.put_line(l_bodyFileHandle , '      END IF;');
  utl_file.put_line(l_bodyFileHandle , '      -- we have a got a record, increment the count by 1');
  utl_file.put_line(l_bodyFileHandle , '      l_rule_count := l_rule_count+1;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- pkg.function(p1, p2, ...)');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := '' begin '';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || l_constraintRuleRec.validation_pkg ||''.'';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || l_constraintRuleRec.validation_proc;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- IN Parameters');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || ''( '';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '':t_application_id, '';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '':t_entity_short_name, '';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '':t_validation_entity_short_name, '';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '':t_validation_tmplt_short_name, '';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '':t_record_set_short_name, '';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '':t_scope, '';');

  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- OUT Parameters ');
  utl_file.put_line(l_bodyFileHandle , '      -- OUT Parameters ');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '':t_result );'';');
  utl_file.put_line(l_bodyFileHandle , '      l_dynamicSqlString := l_dynamicSqlString || '' end; '';');
  utl_file.put_line(l_bodyFileHandle , '      -- open the dynamic sql cursor');
  utl_file.put_line(l_bodyFileHandle , '      l_dsqlCursor := dbms_sql.open_cursor;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- parse the validator sql');
  utl_file.put_line(l_bodyFileHandle , '      dbms_sql.parse(l_dsqlCursor, l_dynamicSqlString, DBMS_SQL.NATIVE);');
  utl_file.put_line(l_bodyFileHandle , '      -- give the bind variables');
  utl_file.put_line(l_bodyFileHandle , '      -- variables for IN parameters');
  utl_file.put_line(l_bodyFileHandle , '	    dbms_sql.bind_variable(l_dsqlCursor, '':t_application_id'',    g_application_id);');
  utl_file.put_line(l_bodyFileHandle , '	    dbms_sql.bind_variable(l_dsqlCursor, '':t_entity_short_name'', g_entity_short_name);');
  utl_file.put_line(l_bodyFileHandle , '	    dbms_sql.bind_variable(l_dsqlCursor, '':t_validation_entity_short_name'',  l_constraintRuleRec.validation_entity_short_name);');
  utl_file.put_line(l_bodyFileHandle , '	    dbms_sql.bind_variable(l_dsqlCursor, '':t_validation_tmplt_short_name'',  l_constraintRuleRec.validation_tmplt_short_name);');
  utl_file.put_line(l_bodyFileHandle , '	    dbms_sql.bind_variable(l_dsqlCursor, '':t_record_set_short_name'',  l_constraintRuleRec.record_set_short_name);');
  utl_file.put_line(l_bodyFileHandle , '	    dbms_sql.bind_variable(l_dsqlCursor, '':t_scope'',  l_constraintRuleRec.scope_op);');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- variables for OUT parameters');
  utl_file.put_line(l_bodyFileHandle , '      -- variables for OUT parameters');
  utl_file.put_line(l_bodyFileHandle , '      dbms_sql.bind_variable(l_dsqlCursor, '':t_result'', l_result_01);');
  utl_file.put_line(l_bodyFileHandle , '      -- execute the validator pfunction');
  utl_file.put_line(l_bodyFileHandle , '      l_dummy := dbms_sql.execute(l_dsqlCursor);');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- retrieve the values of the OUT variables');
  utl_file.put_line(l_bodyFileHandle , '      -- retrieve the values of the OUT variables');
  utl_file.put_line(l_bodyFileHandle , '      dbms_sql.variable_value(l_dsqlCursor, '':t_result'', l_result_01);');
  utl_file.put_line(l_bodyFileHandle , '      IF (l_result_01 = 0) THEN');
  utl_file.put_line(l_bodyFileHandle , '         l_tempResult := FALSE;');
  utl_file.put_line(l_bodyFileHandle , '      ELSE');
  utl_file.put_line(l_bodyFileHandle , '         l_tempResult := TRUE;');
  utl_file.put_line(l_bodyFileHandle , '      END IF;');
  utl_file.put_line(l_bodyFileHandle , '      -- apply the modifier on the result');
  utl_file.put_line(l_bodyFileHandle , '      if(l_constraintRuleRec.modifier_flag = OE_PC_GLOBALS.YES_FLAG) then');
  utl_file.put_line(l_bodyFileHandle , '         l_tempResult := NOT(l_tempResult);');
  utl_file.put_line(l_bodyFileHandle , '      end if;');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      IF (i = 0) THEN');
  utl_file.put_line(l_bodyFileHandle , '         l_currGrpResult := l_tempResult;');
  utl_file.put_line(l_bodyFileHandle , '      ELSE');
  utl_file.put_line(l_bodyFileHandle , '         l_currGrpResult := l_currGrpResult AND l_tempResult;');
  utl_file.put_line(l_bodyFileHandle , '      END IF;');
  utl_file.put_line(l_bodyFileHandle , '      -- close the cursor');
  utl_file.put_line(l_bodyFileHandle , '      dbms_sql.close_cursor(l_dsqlCursor); ');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , '      -- increment the index');
  utl_file.put_line(l_bodyFileHandle , '      i := i+1;');
  utl_file.put_line(l_bodyFileHandle , '   END LOOP;  -- end validatate validators');
  utl_file.put_line(l_bodyFileHandle , '   CLOSE C_R;');
  utl_file.put_line(l_bodyFileHandle , '   -- did we validate any constraint rules?. if there is none then the ');
  utl_file.put_line(l_bodyFileHandle , '   -- constraint is valid and we will return YES ');
  utl_file.put_line(l_bodyFileHandle , '   IF (l_rule_count = 0) THEN');
  utl_file.put_line(l_bodyFileHandle , '      x_condition_count := 0;');
  utl_file.put_line(l_bodyFileHandle , '      x_valid_condition_group := -1;');
  utl_file.put_line(l_bodyFileHandle , '      x_result    := OE_PC_GLOBALS.YES;');
  utl_file.put_line(l_bodyFileHandle , '   ELSE ');
  utl_file.put_line(l_bodyFileHandle , '      x_condition_count := l_rule_count;');
  utl_file.put_line(l_bodyFileHandle , '      x_valid_condition_group := l_currGrpNumber;');
  utl_file.put_line(l_bodyFileHandle , '      x_result    := l_ConstrainedStatus;');
  utl_file.put_line(l_bodyFileHandle , '   END IF;');
  utl_file.put_line(l_bodyFileHandle , ' -------------------------------------------');
  utl_file.put_line(l_bodyFileHandle , ' EXCEPTION ');
  utl_file.put_line(l_bodyFileHandle , '    WHEN OTHERS THEN ');
  utl_file.put_line(l_bodyFileHandle , '       x_result := OE_PC_GLOBALS.ERROR; ');
  utl_file.put_line(l_bodyFileHandle , 'END Validate_Constraint; ');
  utl_file.put_line(l_bodyFileHandle , '------------------------------------------- ');
     IF l_debug_level  > 0 THEN
  OE_Debug_PUB.ADD(' generate Is_Op_Constrained  ');
     END IF;

  utl_file.put_line(l_bodyFileHandle , '------------------------------------------- ');
  utl_file.put_line(l_bodyFileHandle , 'FUNCTION Is_Op_Constrained ');
  utl_file.put_line(l_bodyFileHandle , ' ( ');
  utl_file.put_line(l_bodyFileHandle , '   p_responsibility_id             in number ');
  utl_file.put_line(l_bodyFileHandle , '   ,p_application_id               in number '); --added for bug3631547
  utl_file.put_line(l_bodyFileHandle , '   ,p_operation                    in varchar2 ');
  utl_file.put_line(l_bodyFileHandle , '   ,p_column_name                  in varchar2 default NULL');
  utl_file.put_line(l_bodyFileHandle , '   ,p_record                       in '||l_db_object_name || '%ROWTYPE');
  utl_file.put_line(l_bodyFileHandle, '   ,p_check_all_cols_constraint    in varchar2 default ''Y''');
  utl_file.put_line(l_bodyFileHandle, '   ,p_is_caller_defaulting         in varchar2 default ''N''');
utl_file.put_line(l_bodyFileHandle , ' ,x_constraint_id out nocopy number');

utl_file.put_line(l_bodyFileHandle , ' ,x_constraining_conditions_grp out nocopy number');

utl_file.put_line(l_bodyFileHandle , ' ,x_on_operation_action out nocopy number');

  utl_file.put_line(l_bodyFileHandle , ' ) ');
  utl_file.put_line(l_bodyFileHandle , ' RETURN NUMBER ');
  utl_file.put_line(l_bodyFileHandle , ' ');
  utl_file.put_line(l_bodyFileHandle , ' IS ');
  utl_file.put_line(l_bodyFileHandle , '  ');
  utl_file.put_line(l_bodyFileHandle , ' --Cursors');
  utl_file.put_line(l_bodyFileHandle , ' -------------------------------------------');
  utl_file.put_line(l_bodyFileHandle , '    CURSOR C_C ');
  utl_file.put_line(l_bodyFileHandle , '    IS ');
  utl_file.put_line(l_bodyFileHandle , '    SELECT DISTINCT');
  utl_file.put_line(l_bodyFileHandle , '      c.constraint_id, c.entity_id');
  utl_file.put_line(l_bodyFileHandle , '      ,c.on_operation_action');
  --utl_file.put_line(l_bodyFileHandle , '      ,c.message_name');
  utl_file.put_line(l_bodyFileHandle , '     FROM  oe_pc_constraints c,');
  utl_file.put_line(l_bodyFileHandle , '           oe_pc_assignments a');
  utl_file.put_line(l_bodyFileHandle , '     WHERE (a.responsibility_id = p_responsibility_id OR a.responsibility_id IS NULL)');
 -- utl_file.put_line(l_bodyFileHandle , '     AND   sysdate BETWEEN nvl(a.start_date_active, sysdate) AND nvl(a.end_date_active, sysdate)');
  utl_file.put_line(l_bodyFileHandle , '     AND   a.constraint_id = c.constraint_id');
  utl_file.put_line(l_bodyFileHandle , '     AND   c.entity_id     = G_ENTITY_ID');
  utl_file.put_line(l_bodyFileHandle , '     AND   c.constrained_operation = p_operation');
  utl_file.put_line(l_bodyFileHandle , '     AND   a.application_id = p_application_id OR a.application_id IS NULL'); --bug3631547
  utl_file.put_line(l_bodyFileHandle , '     -- if caller is defaulting then DO NOT CHECK those constraints');
  utl_file.put_line(l_bodyFileHandle , '     -- that have honored_by_def_flag = ''N''');
  utl_file.put_line(l_bodyFileHandle , '     AND   decode(honored_by_def_flag,''N'',decode(p_is_caller_defaulting,''Y'',''N'',''Y''),');
  utl_file.put_line(l_bodyFileHandle , '                nvl(honored_by_def_flag,''Y'')) = ''Y''');
  utl_file.put_line(l_bodyFileHandle , '     AND   decode(c.column_name, ' || l_NULL || ',decode(p_check_all_cols_constraint,''Y'',');
  utl_file.put_line(l_bodyFileHandle, '             nvl(p_column_name,'||l_DUMMY_COL||'),'||l_DUMMY_COL||'),c.column_name) = nvl(p_column_name,'||l_DUMMY_COL||')');
  utl_file.put_line(l_bodyFileHandle , '     AND   NOT EXISTS (');
  utl_file.put_line(l_bodyFileHandle , '            SELECT ' || l_Q || 'EXISTS' || l_Q);
  utl_file.put_line(l_bodyFileHandle , '            FROM OE_PC_EXCLUSIONS e');
  utl_file.put_line(l_bodyFileHandle , '            WHERE e.responsibility_id = p_responsibility_id');
  utl_file.put_line(l_bodyFileHandle , '            AND   e.assignment_id     = a.assignment_id');
  utl_file.put_line(l_bodyFileHandle , '            AND e.application_id = p_application_id OR e.application_id IS NULL'); --bug3631547
 -- utl_file.put_line(l_bodyFileHandle , '            AND   sysdate BETWEEN nvl(e.start_date_active, sysdate)');
 --  utl_file.put_line(l_bodyFileHandle , '                           AND nvl(e.end_date_active, sysdate)');
  utl_file.put_line(l_bodyFileHandle , '            );');
utl_file.put_line(l_bodyFileHandle , '-- Cursor to select all update constraints that are applicable to insert');
utl_file.put_line(l_bodyFileHandle , '-- operations as well.');

  utl_file.put_line(l_bodyFileHandle , '    CURSOR C_CHECK_ON_INSERT ');
  utl_file.put_line(l_bodyFileHandle , '    IS ');
  utl_file.put_line(l_bodyFileHandle , '    SELECT DISTINCT');
  utl_file.put_line(l_bodyFileHandle , '      c.constraint_id, c.entity_id');
  utl_file.put_line(l_bodyFileHandle , '      ,c.on_operation_action');
  --utl_file.put_line(l_bodyFileHandle , '      ,c.message_name');
  utl_file.put_line(l_bodyFileHandle , '     FROM  oe_pc_constraints c,');
  utl_file.put_line(l_bodyFileHandle , '           oe_pc_assignments a');
  utl_file.put_line(l_bodyFileHandle , '     WHERE (a.responsibility_id = p_responsibility_id OR a.responsibility_id IS NULL)');
  utl_file.put_line(l_bodyFileHandle , '     AND   a.application_id = p_application_id OR a.application_id IS NULL'); --bug3631547
 -- utl_file.put_line(l_bodyFileHandle , '     AND   sysdate BETWEEN nvl(a.start_date_active, sysdate) AND nvl(a.end_date_active, sysdate)');
  utl_file.put_line(l_bodyFileHandle , '     AND   a.constraint_id = c.constraint_id');
  utl_file.put_line(l_bodyFileHandle , '     AND   c.entity_id     = G_ENTITY_ID');
  utl_file.put_line(l_bodyFileHandle , '     AND   c.constrained_operation = OE_PC_GLOBALS.UPDATE_OP');
  utl_file.put_line(l_bodyFileHandle , '     AND   c.check_on_insert_flag = ''Y''');
  utl_file.put_line(l_bodyFileHandle , '     AND   nvl(c.column_name, ' || l_DUMMY_COL || ') = p_column_name');
  utl_file.put_line(l_bodyFileHandle , '     -- if caller is defaulting then DO NOT CHECK those constraints');
  utl_file.put_line(l_bodyFileHandle , '     -- that have honored_by_def_flag = ''N''');
  utl_file.put_line(l_bodyFileHandle , '     AND   decode(honored_by_def_flag,''N'',decode(p_is_caller_defaulting,''Y'',''N'',''Y''),');
  utl_file.put_line(l_bodyFileHandle , '                nvl(honored_by_def_flag,''Y'')) = ''Y''');
  utl_file.put_line(l_bodyFileHandle , '     AND   NOT EXISTS (');
  utl_file.put_line(l_bodyFileHandle , '            SELECT ' || l_Q || 'EXISTS' || l_Q);
  utl_file.put_line(l_bodyFileHandle , '            FROM OE_PC_EXCLUSIONS e');
  utl_file.put_line(l_bodyFileHandle , '            WHERE e.responsibility_id = p_responsibility_id');
  utl_file.put_line(l_bodyFileHandle , '            AND   e.assignment_id     = a.assignment_id');
  utl_file.put_line(l_bodyFileHandle , '            AND e.application_id = p_application_id OR e.application_id IS NULL'); --bug3631547
--  utl_file.put_line(l_bodyFileHandle , '            AND   sysdate BETWEEN nvl(e.start_date_active, sysdate)');
--  utl_file.put_line(l_bodyFileHandle , '                           AND nvl(e.end_date_active, sysdate)');
  utl_file.put_line(l_bodyFileHandle , '            );');
  utl_file.put_line(l_bodyFileHandle , ' --Local Variables');
  utl_file.put_line(l_bodyFileHandle , ' -------------------------------------------');
  utl_file.put_line(l_bodyFileHandle , '    l_validation_result   	number;');
  utl_file.put_line(l_bodyFileHandle , '    l_condition_count     	number;');
  utl_file.put_line(l_bodyFileHandle , '    l_valid_condition_group   	number;');
  utl_file.put_line(l_bodyFileHandle , ' BEGIN ');
  utl_file.put_line(l_bodyFileHandle , '    g_record   := p_record;  ');
  utl_file.put_line(l_bodyFileHandle , '    l_validation_result   := OE_PC_GLOBALS.NO;  ');
  utl_file.put_line(l_bodyFileHandle , '    FOR c_rec in C_C LOOP  ');
  utl_file.put_line(l_bodyFileHandle , '        Validate_Constraint ( ');
  utl_file.put_line(l_bodyFileHandle , '              p_constraint_id   	=> c_rec.constraint_id');
  utl_file.put_line(l_bodyFileHandle , '              ,x_condition_count       => l_condition_count');
  utl_file.put_line(l_bodyFileHandle , '              ,x_valid_condition_group => l_valid_condition_group');
  utl_file.put_line(l_bodyFileHandle , '              ,x_result                => l_validation_result');
  utl_file.put_line(l_bodyFileHandle , '              );');
  utl_file.put_line(l_bodyFileHandle , '       IF (l_condition_count = 0 OR l_validation_result = OE_PC_GLOBALS.YES) then');
  utl_file.put_line(l_bodyFileHandle , '          x_constraint_id           := c_rec.constraint_id;');
  utl_file.put_line(l_bodyFileHandle , '          x_on_operation_action     := c_rec.on_operation_action;');
  --utl_file.put_line(l_bodyFileHandle , '          x_message_name                  := c_rec.message_name;');
  utl_file.put_line(l_bodyFileHandle , '          x_constraining_conditions_grp   := l_valid_condition_group;');
  utl_file.put_line(l_bodyFileHandle , '          EXIT;');
  utl_file.put_line(l_bodyFileHandle , '       END IF;');
  utl_file.put_line(l_bodyFileHandle , '    END LOOP;');
  utl_file.put_line(l_bodyFileHandle , '  IF ( p_operation = OE_PC_GLOBALS.CREATE_OP');
  utl_file.put_line(l_bodyFileHandle , '       AND l_validation_result = OE_PC_GLOBALS.NO');
  utl_file.put_line(l_bodyFileHandle , '       AND p_column_name IS NOT NULL) THEN');
  utl_file.put_line(l_bodyFileHandle , '    FOR c_rec in C_CHECK_ON_INSERT LOOP');
  utl_file.put_line(l_bodyFileHandle , '        Validate_Constraint ( ');
  utl_file.put_line(l_bodyFileHandle , '              p_constraint_id   	=> c_rec.constraint_id');
  utl_file.put_line(l_bodyFileHandle , '              ,x_condition_count       => l_condition_count');
  utl_file.put_line(l_bodyFileHandle , '              ,x_valid_condition_group => l_valid_condition_group');
  utl_file.put_line(l_bodyFileHandle , '              ,x_result                => l_validation_result');
  utl_file.put_line(l_bodyFileHandle , '              );');
  utl_file.put_line(l_bodyFileHandle , '       IF (l_condition_count = 0 OR l_validation_result = OE_PC_GLOBALS.YES) then');
  utl_file.put_line(l_bodyFileHandle , '          x_constraint_id           := c_rec.constraint_id;');
  utl_file.put_line(l_bodyFileHandle , '          x_on_operation_action     := c_rec.on_operation_action;');
  --utl_file.put_line(l_bodyFileHandle , '          x_message_name                  := c_rec.message_name;');
  utl_file.put_line(l_bodyFileHandle , '          x_constraining_conditions_grp   := l_valid_condition_group;');
  utl_file.put_line(l_bodyFileHandle , '          EXIT;');
  utl_file.put_line(l_bodyFileHandle , '       END IF;');
  utl_file.put_line(l_bodyFileHandle , '    END LOOP;');
  utl_file.put_line(l_bodyFileHandle , '  END IF;');
  utl_file.put_line(l_bodyFileHandle , '    return l_validation_result;');
  utl_file.put_line(l_bodyFileHandle , ' EXCEPTION ');
  utl_file.put_line(l_bodyFileHandle , '    WHEN OTHERS THEN ');
  utl_file.put_line(l_bodyFileHandle , '       RETURN OE_PC_GLOBALS.ERROR; ');
  utl_file.put_line(l_bodyFileHandle , 'END Is_Op_Constrained; ');
  utl_file.put_line(l_bodyFileHandle , '------------------------------------------- ');
  utl_file.put_line(l_bodyFileHandle , 'END ' || l_pkg_name || ';');
  utl_file.put_line(l_bodyFileHandle , '/');
  utl_file.put_line(l_bodyFileHandle , 'COMMIT;');
  -- utl_file.put_line(l_bodyFileHandle , 'EXIT;');
  utl_file.fclose(l_bodyFileHandle);

  -- write the script to compile the spec and body
  utl_file.put_line(l_sqlFileHandle , '-- compile the spec');
  utl_file.put_line(l_sqlFileHandle , '@' || l_specFileName);
  utl_file.put_line(l_sqlFileHandle , '-- compile the body');
  utl_file.put_line(l_sqlFileHandle , '@' || l_bodyFileName );
  utl_file.put_line(l_sqlFileHandle , 'EXIT;');
  utl_file.fclose(l_sqlFileHandle);

EXCEPTION

  when others then
     IF l_debug_level  > 0 THEN
     OE_Debug_PUB.ADD('Oe_PC_Constraints_Admin_Pub.Generate_Constraint_API: EXCEPTION');
     END IF;
END Generate_Constraint_API;
----------------------------------------------------------------------


-- FUNCTION Get_Authorized_WF_Roles:
-- Returns the list of WF Roles that are NOT constrained
-- by the conditions for a given constraint (p_constraint_id).
-- The list contains two elements:
-- Name: WF_ROLES.NAME
-- Display_Name: WF_ROLES.DISPLAY_NAME
-- Returns a NULL list if no auth. resps. are found.

-- NOTE: This does not mean that these roles can perform the
-- constrained operation. There may be other constraints for
-- the same operation on this entity that are applicable to this role.

-----------------------------------------------------
FUNCTION Get_Authorized_WF_Roles
(
  p_constraint_id               IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

)
RETURN OE_PC_GLOBALS.Authorized_WF_Roles_TBL
-----------------------------------------------------
IS

        CURSOR C_ASSIGNED_RESP IS
        SELECT 'FND_RESP'||R.application_id||':'||R.responsibility_id role_name
                ,  R.responsibility_name role_display_name
        FROM FND_RESPONSIBILITY_VL R
        WHERE R.responsibility_id NOT IN (SELECT NVL(responsibility_id,R.responsibility_id)
                                          FROM OE_PC_ASSIGNMENTS
                                          WHERE CONSTRAINT_ID = p_constraint_id
                                          )
	ORDER BY role_display_name;

        CURSOR C_EXCLUDED_RESP IS
        SELECT 'FND_RESP'||R.application_id||':'||R.responsibility_id role_name
                ,  R.responsibility_name role_display_name
        FROM FND_RESPONSIBILITY_VL R
                , OE_PC_EXCLUSIONS E
        WHERE E.assignment_id = (SELECT assignment_id
                                FROM oe_pc_assignments
                                WHERE constraint_id = p_constraint_id
                                AND responsibility_id IS NULL)
         AND E.responsibility_id = R.responsibility_id
         AND E.application_id    = R.application_id  --added for bug3631547
	ORDER BY role_display_name;

         I      NUMBER := 1;

	 x_WF_Roles_TBL		OE_PC_GLOBALS.Authorized_WF_Roles_TBL;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- If the constraint is applicable to ALL EXCEPT some responsibilities
-- then select from the EXCEPT list.

   FOR C1 IN C_EXCLUDED_RESP LOOP

          x_WF_Roles_TBL(I).Name := C1.Role_Name;
          x_WF_Roles_TBL(I).Display_Name := C1.Role_Display_Name;

          I := I+1;

   END LOOP;

-- If there were NO responsibilities in the ALL EXCEPT list, then
-- return all resps. except those that are constrained (OR
-- ASSIGNED to this constraint.)

   IF (I = 1) THEN

     FOR C2 IN C_ASSIGNED_RESP LOOP

          x_WF_Roles_TBL(I).Name := C2.Role_Name;
          x_WF_Roles_TBL(I).Display_Name := C2.Role_Display_Name;

          I := I+1;

     END LOOP;

   END IF;

  RETURN x_WF_Roles_TBL;

EXCEPTION

  WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Authorized_WF_Roles'
            );
        END IF;

END Get_Authorized_WF_Roles;

-- Local procedure that should be called only from add_constraint_message
-- procedure
-- This sets the correct message on the stack based on the operation
-- and also sets the tokens for OBJECT and ATTRIBUTE where needed.
-- This does NOT set the REASON token which is added in the
-- add_constraint_message procedure itself
PROCEDURE Set_Message
( p_operation			IN VARCHAR2
, p_group_number         IN VARCHAR2
, p_attribute_name       IN VARCHAR2
, p_object_name          IN VARCHAR2
)
IS
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF p_operation = OE_PC_GLOBALS.UPDATE_OP THEN
    	IF p_attribute_name IS NOT NULL THEN
	   IF nvl(p_group_number,-1) = -1 THEN
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_UPDATE_FIELD_NO_CONDN');
	   ELSE
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_UPDATE_FIELD_VIOLATION');
	   END IF;
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_attribute_name);
	ELSE
	   IF nvl(p_group_number,-1) = -1 THEN
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_UPDATE_NO_CONDN');
	   ELSE
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_UPDATE_VIOLATION');
	   END IF;
	   FND_MESSAGE.SET_TOKEN('OBJECT',p_object_name);
    	END IF;
    ELSIF p_operation = OE_PC_GLOBALS.CREATE_OP THEN
	   IF nvl(p_group_number,-1) = -1 THEN
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_CREATE_NO_CONDN');
	   ELSE
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_CREATE_VIOLATION');
	   END IF;
	   FND_MESSAGE.SET_TOKEN('OBJECT',p_object_name);
    ELSIF p_operation = OE_PC_GLOBALS.DELETE_OP THEN
	   IF nvl(p_group_number,-1) = -1 THEN
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_DELETE_NO_CONDN');
	   ELSE
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_DELETE_VIOLATION');
	   END IF;
	   FND_MESSAGE.SET_TOKEN('OBJECT',p_object_name);
    ELSIF p_operation = OE_PC_GLOBALS.CANCEL_OP THEN
	   IF nvl(p_group_number,-1) = -1 THEN
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_CANCEL_NO_CONDN');
	   ELSE
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_CANCEL_VIOLATION');
	   END IF;
	   FND_MESSAGE.SET_TOKEN('OBJECT',p_object_name);
    ELSIF p_operation = OE_PC_GLOBALS.SPLIT_OP THEN
	   IF nvl(p_group_number,-1) = -1 THEN
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_SPLIT_NO_CONDN');
	   ELSE
	     FND_MESSAGE.SET_NAME('ONT','OE_PC_SPLIT_VIOLATION');
	   END IF;
	   FND_MESSAGE.SET_TOKEN('OBJECT',p_object_name);
    END IF;

END Set_Message;

---------------------------------------
PROCEDURE Add_Constraint_Message
(  p_application_id			IN NUMBER
  ,p_database_object_name		IN VARCHAR2
  ,p_column_name		IN VARCHAR2
  ,p_operation			IN VARCHAR2
  ,p_constraint_id		IN NUMBER
  ,p_on_operation_action		IN NUMBER
  ,p_group_number		IN NUMBER
)
-----------------------------------------------------
IS
-- Fix bug#1349549:
-- Increased l_attribute_name length to 240 as length
-- of column - NAME on AK_OBJECT_ATTRIBUTES_VL was increased
l_attribute_name	VARCHAR2(240);
l_reason			VARCHAR2(2000);
i				NUMBER := 0;
l_entity_code		VARCHAR2(30);
l_object_name		VARCHAR2(30);
l_reason_length	NUMBER;
l_operation		VARCHAR2(30);
l_column_name       VARCHAR2(30);
CURSOR CONDN IS
SELECT USER_MESSAGE msg
  FROM OE_PC_CONDITIONS_VL
  WHERE CONSTRAINT_ID = p_constraint_id
    AND GROUP_NUMBER = p_group_number;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  l_operation := p_operation;

  -- NOTE: This procedure currently adds a message to the stack
  -- ONLY IF operation IS NOT ALLOWED (i.e. on_operation_action = 0)
  -- For other user actions, this procedure will have to be extended
  -- For the initial release, the only other supported user action
  -- is REQUIRE REASON (on_operation_action = 1) but this is also
  -- limited to CANCEL and Ordered Quantity UPDATE operations. Messages
  -- for this will be added in the cancellations code. (OEXUCANB.pls)

  -- if operation is NOT allowed then set the constraint ID
  -- on the message context
  IF p_on_operation_action = 0 THEN

	select o.entity_code, a.name
	into l_entity_code, l_object_name
	from oe_ak_objects_ext o, ak_objects_vl a
	where o.database_object_name = p_database_object_name
	  and o.application_id = p_application_id
	  and a.database_object_name = o.database_object_name
	  and a.application_id = o.application_id;

     IF l_operation = OE_PC_GLOBALS.CREATE_OP
	   OR l_operation = OE_PC_GLOBALS.UPDATE_OP
     THEN

	  SELECT c.constrained_operation, c.column_name
	  INTO l_operation, l_column_name
	  FROM oe_pc_constraints  c
	  WHERE c.constraint_id = p_constraint_id;

       IF l_column_name IS NOT NULL THEN
            -- Bug 2721841, attribute_label_long is the translated
            -- column and not the name column.
	    SELECT a.attribute_label_long
	    INTO l_attribute_name
	    FROM ak_object_attributes_vl a
	    WHERE column_name = l_column_name
		 AND database_object_name = p_database_object_name
		 AND attribute_application_id = p_application_id;
       END IF;

     END IF;

    OE_MSG_PUB.Update_Msg_Context
        ( p_entity_code		=> l_entity_code
        , p_constraint_id	=> p_constraint_id );

    -- Set the attribute name, object name tokens.
    -- And set the message on the message stack
    -- appropriately based on the operation
    -- This procedure does NOT set the reason token
    Set_Message(p_operation		=> l_operation
			,p_group_number	=> p_group_number
			,p_attribute_name	=> l_attribute_name
			,p_object_name		=> l_object_name
			);

    -- Set the REASON token if a group of conditions (group_number exists)
    -- resulted in this constraint violation
    IF nvl(p_group_number,-1) <> -1 THEN

      -- Fix for bug1162361:
      -- Message length can be at the maximum 2000 chars
      -- therefore, estimate the maximum length for the reason
      -- token by reducing the length of the message string
      -- without the reason token
      l_reason_length := 2000 - length(FND_MESSAGE.GET);

      -- Re-set the message , attribute name and object name tokens
      -- on the stack as the previous call to FND_MESSAGE.GET would
      -- have deleted the message from the stack.
      Set_Message(p_operation		=> l_operation
			,p_group_number	=> p_group_number
			,p_attribute_name	=> l_attribute_name
			,p_object_name		=> l_object_name
			);

      -- construct the reason token based on the user message associated
      -- with the constraining conditions
      -- e.g. 'order booked
      --       at least one line shipped '
      FOR l_condn IN CONDN LOOP
      IF i = 0 THEN
        	l_reason := substr(l_condn.msg,1,l_reason_length);
      ELSE
        	l_reason := substr(l_reason||OE_PC_GLOBALS.NEWLINE||l_condn.msg,1,l_reason_length);
      END IF;
      i := i+1;
      END LOOP;
      FND_MESSAGE.SET_TOKEN('REASON',l_reason);

    END IF; --  Add REASON token Only if group_number(set of conditions exists)

    OE_MSG_PUB.ADD;

    -- set constraint ID to null on the message context.
    OE_MSG_PUB.Update_Msg_Context
        ( p_entity_code		=> l_entity_code
        , p_constraint_id	=> null );


   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Add_Constraint_Message'
            );
        END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Add_Constraint_Message;

END Oe_PC_Constraints_Admin_Pub;

/
