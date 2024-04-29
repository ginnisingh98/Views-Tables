--------------------------------------------------------
--  DDL for Package Body GMF_MSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_MSG_PKG" AS
/* $Header: gmfmesgb.pls 115.5 2002/11/11 00:40:09 rseshadr Exp $ */
/*hb***********************************************************************
* External
* Procedure:	get_msg_from_code
*
* Purpose:		Retrieve message_id and message_text from sy_mesg_table
*				for a given message_code and op_code.  The op_code is
*				used to determine the current session's lang_code.
*
* Forms: 		Each publically accessable procedure for extracting
*				messages has 2 forms. This is done by using the
*				overloading technique provided in PL/SQL.
*	  1-		Messages without substitution parameters (eg. "%s").
*	  2-		Declaration for messages with substitution variables
*
* Parameters:	The in/out disposition of the first three paramters will
				depend on which procedure is called.  The parameter after
*				the "_from_" in the procedure name will be an "in" only
*				parameter and the other two will be "in out".
*
*				po_message_id	[in	out] or [in] varchar2
*				pi_message_code	[in	out] or [in] varchar2
*				po_message_text	[in	out] or [in] varchar2
*				pi_op_code		in	varchar2
*				pi_svar			in	SubstituteTabTyp  ***Form 2 only***
*				po_error_status	out	number
*
* Returns:		po_error_ststus
*					0 == Success
*					1 == Operator Code Not Found
*					2 == Language Code Not Found
*
*    Jatinder Gogna -05/05/99 -Changed substr and instr to substrb and instrb
*        as per AOL standards.
*
*	Rajesh Kulkarni 10/27/99 Take the substrb for message_text in a
*	cursor as out var po_message_text is restricted to 512. Also vars
*	v_message_text and v_old_message_text are made to 512 from 255. B1043070
*
*	Venkat Chukkapalli 08/16/01 B1933961 Removed reference to APPS schema.
*       RajaSekhar    30-OCT-2002 Bug#2641405 Added NOCOPY hint.
****************************************************************hf*/
	procedure get_msg_from_code
			(po_message_id    out NOCOPY number,
			 pi_message_code  in  varchar2,
			 po_message_text  out NOCOPY  varchar2,
			 pi_op_code       in  varchar2,
			 po_error_status  out NOCOPY  number)
		is
			v_message_code	fnd_new_messages.message_name%TYPE;
			v_error_status	number;
			cursor read_mesg_rec
				(v_message_code_csr	char)
			 is
				select substrb(message_text,1,512)
				  from fnd_new_messages
				 where language_code    = nvl(userenv('LANG'), C_DEFAULT_LANG)
		                       and message_name = v_message_code_csr;
				 /*  and delete_mark  = 0; */
	begin
		v_message_code := pi_message_code;
		/*
		* Now we try to get the message
		*/
			if (not read_mesg_rec%ISOPEN) then
				open read_mesg_rec(v_message_code);
			end if;
			fetch read_mesg_rec
				into po_message_text;
			if (read_mesg_rec%NOTFOUND) then
				po_message_text :=  v_message_code ;
			end if;
			if (read_mesg_rec%ISOPEN) then
				close read_mesg_rec;
			end if;
		exception
			when others then
				po_message_text := v_message_code;
	end; /* Form 1: get_msg_from_code */
	/*hb*********************************************************************
	* External
	* Procedure:	get_msg_from_code - Form 2
	*
	* Purpose:		Sames as form 1 but allows use of substitution variables
	*				in the message_text.  The addtional parameter pi_svar
	*				is required.  Variables must be in the form "%s#" where
	*				# is sequentially assigned number starting at 1.
	*				Code logic allows up to 99 sub vars in text.  We should
	*				hope that we don't get there!
	*				Note that "%s" without trailing # won't work properly
	*				here.
	**********************************************************************hf*/
	procedure get_msg_from_code
			(po_message_id    out NOCOPY number,
			 pi_message_code  in  varchar2,
			 po_message_text  out NOCOPY  varchar2,
			 pi_op_code       in  varchar2,
			 pi_svar          in  SubstituteTabTyp,
			 po_error_status  out NOCOPY  number)
		is
			v_message_id	fnd_new_messages.message_number%TYPE;
			v_message_text	varchar2(512);
			v_old_message_text	varchar2(512);
			v_error_status	number;
			v_i		number default 1;
			v_j		number;
			v_old_j		number default -1;
			v_len	number	default 3;
			v_str	varchar2(5);
			ex_form1_failure	exception;
			/*
			* WARNING: The hardcoded -20000 is required but must be
			* in sync with constant "C_GETMSG_NO_OPCODE" if we ever
			* get info from database.
			*/
			pragma EXCEPTION_INIT(ex_form1_failure, -20000);
		begin
			/*
			 Next line calls Form 1 of proc --why recode
			*/
			get_msg_from_code (v_message_id,
								pi_message_code,
								v_message_text,
								pi_op_code,
								v_error_status);
			po_message_id   := v_message_id;	/* Get this out of the way */
			po_error_status := v_error_status;
			/*
			* Copy-append each value to temp var
			* Exception raised when end of array reached
			*/
			loop
				/* find starting point of %s# flag */
				v_j := instrb(lower(v_message_text), '%s');
				if (v_j > 0 ) then
					v_str := '%s'||to_char(v_i);
					/*
					* Actual sustitution
					* - Possible error if substitution causes length
					*   greater than message_text%TYPE.
					*   The error in this case is ORA-6502
					*/
					v_old_message_text := v_message_text;
					v_message_text := replace(v_message_text, v_str,pi_svar(v_i));
					exit when v_old_message_text = v_message_text;
				else
					exit; /* "%s" not found-return what we have */
				end if;
				v_i := v_i + 1;
			end loop;
			po_message_text := v_message_text;
		exception
			/*
			* Actually an abnormal ending.
			* We went past end of pi_svar array.
			* Time to quit - even if more %s found
			*/
			when others then
				po_message_text := v_message_text;
		end; /* Form 2: get_msg_from_code */
end; /* gmmsg_pkg */

/
