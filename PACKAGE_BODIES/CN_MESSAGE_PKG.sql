--------------------------------------------------------
--  DDL for Package Body CN_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MESSAGE_PKG" as
/* $Header: cnsymsgb.pls 120.2 2006/02/17 11:57:01 ymao ship $ */
/*
Date      Name          Description
----------------------------------------------------------------------------+
21-NOV-94 P Cook	Created
24-MAY-95 P Cook	Revised message stacking procedures in preparation for
			testing.
23-JUN-95 P Cook	populate audit_lines.message_type_code not message_type
07-JUL-95 P Cook	Use CN_DEBUG_MODE profile to determine whether debug
			messages are written to the table
20-JUL-95 P Cook	Modified calls to begin batch
07-AUG-95 P Cook	Renamed CN_DEBUG_MODE to CN_DEBUG.
31-AUG-95 P Cook	Changed end_batch to set the completion timestamp.
19-FEB-96 P Cook	Debugginf messages now only written if profile is set.

*/

/*------------------------------ DATA TYPES ---------------------------------*/
TYPE message_table_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
TYPE code_table_type    IS TABLE OF VARCHAR2(12)  INDEX BY BINARY_INTEGER;
TYPE date_table_type    IS TABLE OF DATE INDEX BY BINARY_INTEGER;

/*---------------------------- PRIVATE VARIABLES ----------------------------*/

-- Text is indented in 3 character increments
 g_indent0	     VARCHAR2(14) := ''		 ;
 g_indent1	     VARCHAR2(14) := '  '	 ;
 g_indent2	     VARCHAR2(14) := '    '	 ;
 g_indent3	     VARCHAR2(14) := '      '	 ;
 g_indent4	     VARCHAR2(14) := '        '	 ;
 g_indent5	     VARCHAR2(14) := '          ';

 g_msg_stack         MESSAGE_TABLE_TYPE; -- Message Stack
 g_msg_stack_empty   MESSAGE_TABLE_TYPE; -- Empty Stack for clearing memory
 g_msg_type_stack    CODE_TABLE_TYPE;	 -- Message Type Stack in sync with
					 -- message stack
 g_msg_type_stack_empty	CODE_TABLE_TYPE; -- Emtpy Type Stack
 g_msg_date_stack    DATE_TABLE_TYPE;	 -- Message Date Stack in sync with
					 -- message stack
 g_msg_date_stack_empty	DATE_TABLE_TYPE; -- Emtpy Date Stack


 g_msg_count	     NUMBER := 0;	 -- Num of Messages on stack
 g_msg_ptr	     NUMBER := 1;	 -- Points to next Message
					 -- on stack to retreive.

 g_user_id	     NUMBER := FND_GLOBAL.User_Id;
 g_conc_request_id   NUMBER := 0;
 g_batch_id 	     NUMBER NULL;
 g_process_audit_id  NUMBER;
 g_org_id            NUMBER;

 g_f_log utl_file.file_type;
 g_log_file_open VARCHAR2(1):='N';

 g_cn_debug VARCHAR2(1);


/*---------------------------- PUBLIC ROUTINES ------------------------------*/
  -- NAME
  --
  --
  -- PURPOSE
  --   Cover for set_name and set_token
  -- NOTES
  --   Whenever either the fornm or batch program encounters validation
  --   problems we push the corresponding  message onto the stack.
  --   At the the end of batch processing we will dump these messages into a
  --   table, we never interrupt the processing to issue messages.
  --   If validation fails during form processing we must either raise
  --   an error thus halting processing or raise a warning.
  --   These forms messages are handlerd by fnd_set_message but we alos
  --  write the messages to the stack so that if no application_error is
  --  not raised we have the option of pushing them back into a form window
  --  ate the end of the comit cycle.
  --
  PROCEDURE Set_Message( Appl_Short_Name IN VARCHAR2
		        ,Message_Name    IN VARCHAR2
		        ,Token_Name1     IN VARCHAR2
		        ,Token_Value1    IN VARCHAR2
		        ,Token_Name2     IN VARCHAR2
		        ,Token_Value2    IN VARCHAR2
		        ,Token_Name3     IN VARCHAR2
		        ,Token_Value3    IN VARCHAR2
		        ,Token_Name4     IN VARCHAR2
		        ,Token_Value4    IN VARCHAR2
		        ,Translate       IN BOOLEAN ) IS

  BEGIN

    -- Always set the passed message in case we want to fail processing
    -- and issue the message in the form.

    fnd_message.set_name (Appl_Short_Name,Message_Name);

    -- protecting unused tokens prevents display of an "=" character in the
    -- message

    if token_name1 is not null then
      fnd_message.set_token(token_name1, token_value1);
    end if;
    if token_name2 is not null then
      fnd_message.set_token(token_name2, token_value2);
    end if;
    if token_name3 is not null then
      fnd_message.set_token(token_name3, token_value3);
    end if;
    if token_name4 is not null then
      fnd_message.set_token(token_name4, token_value4);
    end if;

    /* Set_Name ( Appl_Short_Name
	         ,Message_Name);
       Set_Token(
		  Token_Name1
	         ,Token_Value1
		  Token_Name2
	         ,Token_Value2
		  Token_Name3
	         ,Token_Value3
		  Token_Name4
	         ,Token_Value4
	         ,Translate);
    */

  END Set_Message;

  PROCEDURE ins_audit_line( x_message_text 	VARCHAR2
		           ,x_message_type 	VARCHAR2) IS
  BEGIN

    INSERT INTO cn_process_audit_lines_all
	  ( process_audit_id
	   ,process_audit_line_id
	   ,message_text
	   ,message_type_code
       ,org_id)
    VALUES( g_process_audit_id
	   ,cn_process_audit_lines_s1.nextval
	   ,substrb(x_message_text,1, 239)
	   ,x_message_type
       ,g_org_id)
    ;

  EXCEPTION
     WHEN OTHERS THEN
    	rollback_errormsg_commit('cn_message.insert_audit_line');
        raise;
 END ins_audit_line;

 PROCEDURE push( x_message_text VARCHAR2
		,x_message_type VARCHAR2) IS
 BEGIN

   IF (g_msg_count > 1000) THEN

     flush;

   END IF;

      g_msg_count 		       := g_msg_count + 1;
      g_msg_stack(g_msg_count)         := Substrb(x_message_text, 1, 254);
      g_msg_type_stack(g_msg_count)    := x_message_type;
      g_msg_date_stack(g_msg_count)    := Sysdate;

 EXCEPTION

   WHEN others THEN

     flush;

      g_msg_count 		       := g_msg_count + 1;
      g_msg_stack(g_msg_count)         := x_message_text;
      g_msg_type_stack(g_msg_count)    := x_message_type;
      g_msg_date_stack(g_msg_count)    := Sysdate;

 END push;


 PROCEDURE open_file(x_sequence IN NUMBER,
		     x_process_type IN VARCHAR2 ) IS

    x_file_name VARCHAR2(100);
    x_request_id NUMBER(15);

    x_log_file VARCHAR2(1);
    x_log_file_dir VARCHAR2(100);


 BEGIN

    x_log_file := fnd_profile.value('CN_LOG_FILE');
    x_log_file_dir := fnd_profile.value('UTL_FILE_LOG');

    IF ((x_log_file='Y') AND (x_log_file_dir IS NOT NULL) AND (g_log_file_open <>'Y')) THEN
       x_request_id :=  fnd_global.conc_request_id;

       IF ((x_request_id <> -1) AND (x_process_type = 'CALCULATION')) THEN
	  /*concurrent request case */
	  x_file_name := 'cn' || Lpad(x_request_id, 7, '0') || '.log';
	ELSE
	  x_file_name := 'cn' || Lpad(x_sequence, 7, '0') || '.log';
       END IF;

       push( x_message_text => 'Concurrent request ID: '||x_request_id
	   ,x_message_type => 'DEBUG');
       push( x_message_text => 'Log file name: '||x_file_name
	   ,x_message_type => 'DEBUG');
        push( x_message_text => 'Log file directory: '||x_log_file_dir
	   ,x_message_type => 'DEBUG');
	g_f_log := utl_file.fopen(x_log_file_dir, x_file_name, 'w');

	g_log_file_open:='Y';

    END IF;

 EXCEPTION

    WHEN UTL_FILE.INVALID_PATH THEN

      push( x_message_text => 'UTL_FILE open failed. Invalid path'
	   ,x_message_type => 'DEBUG');

    WHEN UTL_FILE.INVALID_MODE THEN

      push( x_message_text => 'UTL_FILE open failed. Invalid mode'
	   ,x_message_type => 'DEBUG');

    WHEN UTL_FILE.INVALID_OPERATION THEN

      push( x_message_text => 'UTL_FILE open failed. Invalid operation'
	   ,x_message_type => 'DEBUG');

    WHEN others THEN

      push( x_message_text => 'UTL_FILE open failed. others'
	   ,x_message_type => 'DEBUG');



 END open_file;

 PROCEDURE ins_audit_batch( x_parent_proc_audit_id     NUMBER
			   ,x_process_audit_id	   IN OUT NOCOPY NUMBER
		           ,x_request_id	      	  NUMBER
			    ,x_process_type	          VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   SELECT cn_process_audits_s.nextval
     INTO g_process_audit_id
     FROM sys.dual;

   x_process_audit_id := g_process_audit_id;

   INSERT INTO cn_process_audits_all
	(  process_audit_id
	  ,parent_process_audit_id
	  ,concurrent_request_id
	  ,process_type
	  ,timestamp_start
      ,org_id)
   VALUES( x_process_audit_id
	  ,nvl(x_parent_proc_audit_id,x_process_audit_id)
	  ,x_request_id
  	  ,x_process_type
	  ,sysdate
      ,g_org_id) ;

   COMMIT;

   open_file(g_process_audit_id, x_process_type);

  EXCEPTION
     WHEN OTHERS THEN
        rollback_errormsg_commit('cn_message.insert_audit_batch');
	raise;

 END ins_audit_batch;

 --
 -- NAME
 --  push
 --
 -- PURPOSE
 --   Writes a debugging message to the Message Stack only if
 --   the profile option value for CN_DEBUG = 'Y'.

 PROCEDURE put_line (message_text VARCHAR2) IS

 BEGIN

    IF (g_log_file_open = 'Y') THEN

       utl_file.put_line(g_f_log, message_text);
       utl_file.fflush(g_f_log);

    END IF;

 EXCEPTION

    WHEN UTL_FILE.INVALID_FILEHANDLE THEN

      push( x_message_text => 'UTL_FILE write failed. Invalid file handle'
	   ,x_message_type => 'DEBUG');

    WHEN UTL_FILE.INVALID_OPERATION THEN

      push( x_message_text => 'UTL_FILE write failed. Invalid operation'
	   ,x_message_type => 'DEBUG');

    WHEN UTL_FILE.WRITE_ERROR THEN

      push( x_message_text => 'UTL_FILE write failed. Write error'
	   ,x_message_type => 'DEBUG');



 END put_line;

 PROCEDURE close_file IS

 BEGIN

    g_log_file_open := 'N';
    utl_file.fclose(g_f_log);

  EXCEPTION

    WHEN UTL_FILE.INVALID_FILEHANDLE THEN

      push( x_message_text => 'UTL_FILE close failed. Invalid file handle'
	   ,x_message_type => 'DEBUG');


 END close_file;


 /*---------------------------- PUBLIC ROUTINES ------------------------------*/
 --
 -- NAME
 --  debug
 --
 -- PURPOSE
 --   Writes a debug message to the stack only if profile  CN_DEBUG = 'Y'.

 PROCEDURE debug(message_text VARCHAR2) IS
   profile NUMBER;
 BEGIN

    put_line(message_text);

   IF g_cn_debug = 'Y' THEN
      push( x_message_text => message_text
	   ,x_message_type => 'DEBUG');
   END IF;


   -- Replaced with the above code for Performance concern
   --IF fnd_profile.value('CN_DEBUG') = 'Y' THEN
   --   push( x_message_text => message_text
   --	   ,x_message_type => 'DEBUG');
   --END IF;



 END debug;

 --
 -- NAME
 --   write
 --
 -- PURPOSE
 --   Writes a message to the output buffer regardless
 --   the value for profile option AS_DEBUG
 --
 PROCEDURE write(p_message_text IN VARCHAR2,p_message_type IN VARCHAR2)
 IS
   profile NUMBER;
 BEGIN

    put_line(p_message_text);

    push( x_message_text => p_message_text
	  ,x_message_type => p_message_type );

 END write;

 --
 -- NAME
 --   Set_Name
 --
 -- PURPOSE
 --   Puts an "encoded" message name on the stack, marked for translation
 --

 PROCEDURE Set_Name( appl_short_name	VARCHAR2
		    ,message_name	VARCHAR2
		    ,indent		NUMBER ) IS

  indent_value NUMBER(2);
 BEGIN

   g_msg_count 			 := g_msg_count + 1;
   g_msg_stack(g_msg_count) 	 := appl_short_name || ' ' || message_name;
   g_msg_type_stack(g_msg_count) := 'TRANSLATE';
   g_msg_date_stack(g_msg_count) := Sysdate;

   IF indent IS NOT NULL THEN

      IF indent = 0 THEN
        indent_value := g_indent0;
      ELSIF indent = 1 THEN
        indent_value := g_indent1;
      ELSIF indent = 2 THEN
        indent_value := g_indent2;
      ELSIF indent = 3 THEN
        indent_value := g_indent3;
      ELSIF indent = 4 THEN
        indent_value := g_indent4;
      ELSIF indent = 5 THEN
        indent_value := g_indent5;
      END IF;

      set_token('INDENT', indent_value, FALSE);

   END IF;

 END set_name;

 --
 -- NAME
 --   Set_Token
 --
 -- PURPOSE
 --   Append Token Information to the current message on the stack.
 --   The current message must be of type 'TRANSLATE' for this
 --   to work properly when the message is translated on the client,
 --   although no serious errors will occur.
 --
 PROCEDURE set_token(token_name  IN VARCHAR2,
		     token_value IN VARCHAR2,
		     translate   IN BOOLEAN ) IS
   trans_label VARCHAR2(5);
 BEGIN
   IF translate THEN
     trans_label := 'TRUE';
   ELSE
     trans_label := 'FALSE';
   END IF;
   g_msg_stack(g_msg_count)
	 := g_msg_stack(g_msg_count)|| ' ' ||
   	    token_name|| ' \"' ||token_value|| '\" ' ||trans_label;

 END set_token;

 --
 -- NAME
 --
 --
 -- PURPOSE
 --    Flush all messages (debug and translatable) off the stack(FIFO) into
 --    the table
 --

 PROCEDURE flush IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    TYPE numlist IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    seq_key  numlist;
    counter NUMBER := 1;

 BEGIN
    -- Build sequence collection
    FOR i IN 1 .. g_msg_count LOOP
       SELECT CN_PROCESS_AUDIT_LINES_S1.NEXTVAL
	 INTO seq_key(i)  FROM dual;
    END LOOP;

    forall i IN 1 ..  g_msg_count
      INSERT INTO cn_process_audit_lines
      ( process_audit_id
	,process_audit_line_id
	,message_text
	,message_type_code
	,creation_date
    ,org_id)
      VALUES( g_process_audit_id
	      ,seq_key(i)
	      ,substrb(g_msg_stack(i),1, 239)
	      ,g_msg_type_stack(i)
	      ,g_msg_date_stack(i)
          ,g_org_id);

    COMMIT;

   /*
   WHILE counter <= g_msg_count LOOP

     ins_audit_line( g_msg_stack(counter)
		    ,g_msg_type_stack(counter));

     counter := counter+1;

   END LOOP;
     */


   clear; -- We've flushed the messages into the table so clear the stack
 EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       debug('cn_message.insert_audit_line : '||SQLCODE||SQLERRM);
       COMMIT;

 END flush;

 --
 -- NAME
 --
 --
 -- PURPOSE
 --
 PROCEDURE end_batch(x_process_audit_id NUMBER) IS
     PRAGMA AUTONOMOUS_TRANSACTION;
 BEGIN
  flush;

  UPDATE cn_process_audits_all
    SET timestamp_end 	  = sysdate
    WHERE process_audit_id = x_process_audit_id;

  close_file;

  COMMIT;

 END end_batch;

 --
 -- NAME
 --   Set_Error
 -- Purpose
 --

 PROCEDURE set_error( routine IN VARCHAR2
		     ,context IN VARCHAR2 ) IS
  delimiter1 VARCHAR2(3);
  delimiter2 VARCHAR2(3);

 BEGIN
  IF routine IS NOT NULL THEN
    delimiter1 := ' : ';
  END IF;
  IF context IS NOT NULL THEN
    delimiter2 := ' : ';
  END IF;

  push( x_message_text => routine||delimiter1||context||delimiter2
				 ||SQLCODE||SQLERRM
       ,x_message_type => 'ERROR');

 END set_error;

 --
 -- NAME
 --   Clear
 --
 -- PURPOSE
 --   Frees memory used the the Message Stacks and resets the
 --   the Message Stack counter and pointer variables.
 --
 PROCEDURE Clear IS
 BEGIN
   g_msg_stack 	    := g_msg_stack_empty;
   g_msg_type_stack := g_msg_type_stack_empty;
   g_msg_date_stack := g_msg_date_stack_empty;
   g_msg_count      := 0;
   g_msg_ptr        := 1;
 END clear;

 --
 -- NAME
 --   Purge
 --
 -- PURPOSE
 --   Delete the contents of cn_messages by batch_id or by creation date.
 --
 PROCEDURE purge( x_process_audit_id NUMBER
	         ,x_creation_date    DATE) IS
 BEGIN
   IF x_process_audit_id IS NOT NULL THEN
     DELETE FROM cn_process_audit_lines_all
     WHERE  process_audit_id = x_process_audit_id;

     DELETE FROM cn_process_audits_all
     WHERE  process_audit_id = x_process_audit_id;

   ELSIF x_creation_date IS NOT NULL THEN
     DELETE FROM cn_process_audit_lines
     WHERE  creation_date <= x_creation_date;

     DELETE FROM cn_process_audits
     WHERE  creation_date <= x_creation_date;
   END IF;

 END purge;

 --
 -- NAME
 --  start
 --
 -- PURPOSE
 --   Prepare the stacks and insert the batch record. Retrive the batch id
 --   to be passe
 --
 PROCEDURE begin_batch( x_parent_proc_audit_id        NUMBER
		       ,x_process_audit_id	  IN OUT NOCOPY NUMBER
		       ,x_request_id	      		 NUMBER
		       ,x_process_type 	      		 VARCHAR2
               ,p_org_id              IN NUMBER) IS
 BEGIN
   clear;
   g_cn_debug := fnd_profile.value('CN_DEBUG');
   g_org_id := p_org_id;

   ins_audit_batch( x_parent_proc_audit_id
		   ,x_process_audit_id
		   ,x_request_id
		   ,x_process_type);
 END begin_batch;


 PROCEDURE rollback_errormsg_commit (x_error_context VARCHAR2) IS
   delimiter 	VARCHAR2(3) := ' : ';
 BEGIN
   rollback;
   debug(x_error_context||delimiter||SQLCODE||SQLERRM);
   flush;
   -- commit; -- comment out since flush will do commit
 END rollback_errormsg_commit;

END CN_MESSAGE_PKG;

/
