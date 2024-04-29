--------------------------------------------------------
--  DDL for Package GMF_MSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_MSG_PKG" AUTHID CURRENT_USER AS
/* $Header: gmfmesgs.pls 115.1 2002/11/11 00:40:19 rseshadr ship $ */
    /*
	* This is used for the Form 2 of the procedures
	*/
	type SubstituteTabTyp is table of varchar2(64)
			index by binary_integer;
	/* Constants used by this package */
	C_GETMSG_SUCCESS		constant number :=      0;
	C_SY_OPCODENOTFOUND		constant number :=      1;
	C_SY_LANGCODE			constant number :=      2;
	C_MSG_NOT_FOUND			constant number :=    100;
	C_GETMSG_NO_OPCODE		constant number := -20000;
	C_DEFAULT_LANG			constant varchar2(4) := 'US';
	SY_OPCODENOTFOUND		constant varchar2(32) := 'SY_OPCODENOTFOUND';
	SY_LANGCODE				constant varchar2(32) := 'SY_LANGCODE';
	/**********************************************************************
	* Procedures:	get_msg_from_code
	* Purpose:		Retrieve message_id and message_text from sy_mesg_table
	*				for a given message_code and op_code.  The op_code is
	*				used to determine the current session's lang_code.
	* Form 1:	Call declaration for NO substitution vars.
	**********************************************************************/
	procedure get_msg_from_code
		(po_message_id    out NOCOPY number,
		 pi_message_code  in  varchar2,
		 po_message_text  out NOCOPY varchar2,
		 pi_op_code       in  varchar2,
		 po_error_status  out NOCOPY number);
	/**********************************************************************
	* Form 2:	Overload the proc with pi_svar array for substitution vars.
	**********************************************************************/
	 procedure get_msg_from_code
	  (po_message_id    out NOCOPY number,
	   pi_message_code  in  varchar2,
	   po_message_text  out NOCOPY varchar2,
	   pi_op_code       in  varchar2,
	   pi_svar          in  SubstituteTabTyp,
	   po_error_status  out NOCOPY number);
end;

 

/
