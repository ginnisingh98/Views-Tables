--------------------------------------------------------
--  DDL for Package CN_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MESSAGE_PKG" AUTHID CURRENT_USER as
/* $Header: cnsymsgs.pls 120.1 2005/07/06 19:00:23 appldev ship $ */

/*
Date      Name          Description
----------------------------------------------------------------------------+
21-NOV-94 P Cook	Created
24-MAY-95 P Cook	Revised message stacking procedures in preparation for
			testing.
Name
 cn_message_pkg

Purpose
  Allow messages (both for reporting and debugging) to be written to a
  database table or to a stack(plsql table) by PL/SQL programs executed
  on the server.
  Messages can be retrieved and used in an on-line report or log file.

Notes
  Currently the stack is unimplemented. Only one message is output back to
  the form.

*/

  -- Procedure Name
  --
  -- Purpose
  --   Cover routine combining set_name and set_token
  --
  -- Notes
  --   Should be able to make set_name/token private leaving this one visible

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
		        ,Translate       IN BOOLEAN );

 -- Name
 --   Flush
 --
 -- Purpose
 --   Flush all session messages off the stack and into the table cn_messages

 PROCEDURE Flush;

 -- Name
 --
 --
 -- Purpose
 --

 PROCEDURE ins_audit_batch( x_parent_proc_audit_id        NUMBER
			   ,x_process_audit_id	      IN OUT NOCOPY NUMBER
		           ,x_request_id	             NUMBER
			   ,x_process_type	             VARCHAR2);
 --
 -- NAME
 --   Debug
 --
 -- PURPOSE
 --   Writes a non-translated message to the output buffer only when
 --   the value for profile option AS_DEBUG = 'Y' or is NULL.
 --
 PROCEDURE debug(message_text IN VARCHAR2);

 --
 -- NAME
 --   write
 --
 -- PURPOSE
 --   Writes a message to the output buffer regardless
 --   the value for profile option AS_DEBUG
 --
 PROCEDURE write(p_message_text IN VARCHAR2,p_message_type IN VARCHAR2);

 --
 -- Name
 --   Set_Name
 --
 -- Purpose
 --   Puts a Message Dictionary message on the message stack.
 --   (Same syntax as FND_MESSAGE.Set_Name)
 --
 PROCEDURE set_name(  appl_short_name VARCHAR2 DEFAULT 'CN'
		     ,message_name    VARCHAR2
		     ,indent          NUMBER DEFAULT null) ;

 --
 -- Name
 --   Set_Token
 --
 -- Purpose
 --   Sets the token of the current message on the message stack.
 --   (Same syntax as FND_MESSAGE.Set_Token
 --
 PROCEDURE set_token(token_name  VARCHAR2,
		     token_value VARCHAR2,
		     translate   BOOLEAN DEFAULT FALSE);
 --
 -- Name
 --   Set_Error
 --
 -- Purpose
 --   Writes the error message of the most recently encountered
 --   Oracle Error to the output buffer.
 --
 -- Arguments
 --   Routine		The name of the routine where the Oracle Error
 --			occured. (Optional)
 --   Context		Any context information relating to the error
 --			(e.g. Customer_Id) (Optional)
 --
 PROCEDURE Set_Error(routine VARCHAR2 DEFAULT NULL,
	 	     context VARCHAR2 DEFAULT NULL);
 --
 -- NAME
 --   Clear
 --
 -- PURPOSE
 --   Clears the message stack and frees memory used by it.
 --
 PROCEDURE Clear;

 --
 -- NAME
 --   Purge
 --
 -- PURPOSE
 --   Delete messages for a given bacth id or forward from a particular date

 PROCEDURE purge( x_process_audit_id NUMBER
		 ,x_creation_date    DATE);

 PROCEDURE begin_batch( x_parent_proc_audit_id        NUMBER
		       ,x_process_audit_id	  IN OUT NOCOPY NUMBER
		       ,x_request_id			 NUMBER
		       ,x_process_type 			 VARCHAR2
               ,p_org_id              IN NUMBER);

 PROCEDURE end_batch(x_process_audit_id NUMBER);

 PROCEDURE rollback_errormsg_commit (x_error_context VARCHAR2);

END CN_MESSAGE_PKG;
 

/
