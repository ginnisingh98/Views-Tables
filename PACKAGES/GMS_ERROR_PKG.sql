--------------------------------------------------------
--  DDL for Package GMS_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_ERROR_PKG" AUTHID CURRENT_USER as
--$Header: gmserhns.pls 115.9 2002/11/28 09:00:53 srkotwal ship $

X_Request_Trace_Id  Number;
PROCEDURE gms_message ( 	x_err_name IN VARCHAR2,
				x_token_name1 IN VARCHAR2 default NULL,
				x_token_val1 IN VARCHAR2 default NULL,
				x_token_name2 IN VARCHAR2 default NULL,
				x_token_val2 IN VARCHAR2 default NULL,
				x_token_name3 IN VARCHAR2 default NULL,
				x_token_val3 IN VARCHAR2 default NULL,
				x_token_name4 IN VARCHAR2 default NULL,
				x_token_val4 IN VARCHAR2 default NULL,
				x_token_name5 IN VARCHAR2 default NULL,
				x_token_val5 IN VARCHAR2 default NULL,
				x_exec_type IN VARCHAR2 default NULL,
				x_err_code IN OUT NOCOPY NUMBER,
				x_err_buff IN OUT NOCOPY VARCHAR2);
/**
Parameters details:
-------------------
	x_err_name: 			Name of the error message that is to be used.
	x_token_name1 .. 5: 		Name of the token (if any) associated with the message.
	x_token_val1 .. 5: 		Value of the token (if any) associated with the message.
	x_exec_type:			'C' - concurrent mode (logged to FND_FILE.log);
					'I' - interactive mode (logged to PL/SQL table).
	x_err_code:			0 - Success; 1 - Unexpected error; 2 - Expected error
	x_err_buff:			The actual message with the substituted token values.
**/

PROCEDURE gms_debug (x_debug_msg IN VARCHAR2,
		     x_exec_type IN VARCHAR2);

-- Added for Bug 1744641: To Generate errors when an exception occurs
-- during the process of generation of invoice/Revenue.
PROCEDURE Gms_Exception_Head_Proc(x_calling_process VARCHAR2) ;

PROCEDURE Gms_Exception_Lines_Proc (
			        x_exception_msg IN VARCHAR2 ,
			        x_token_1 IN VARCHAR2,
			        x_calling_place IN VARCHAR2,
                                x_project_id IN NUMBER DEFAULT NULL ,
                                x_award_number IN VARCHAR2 DEFAULT NULL ,
                                x_award_name   IN VARCHAR2 DEFAULT NULL,
                                x_sql_code IN VARCHAR2 DEFAULT NULL,
                                x_sql_message IN VARCHAR2 DEFAULT NULL ) ;

-- End of code added for bug 1744641

PROCEDURE gms_output(x_output IN VARCHAR2);

PROCEDURE set_debug_context; -- Added for Bug: 2510024

end GMS_ERROR_PKG;

 

/
