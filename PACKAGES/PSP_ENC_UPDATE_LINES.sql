--------------------------------------------------------
--  DDL for Package PSP_ENC_UPDATE_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_UPDATE_LINES" AUTHID CURRENT_USER AS
/* $Header: PSPENUPS.pls 115.20 2004/03/04 23:13:06 vdharmap ship $ */
Procedure Update_Enc_lines
(errbuf 		out NOCOPY 	varchar2,
retcode 		out NOCOPY	varchar2,
p_payroll_id		IN	Number,
p_enc_line_type 	IN	VARCHAR2,
p_business_group_id	IN	NUMBER,
p_set_of_books_id	IN	NUMBER);


Procedure verify_changes (p_payroll_id IN  NUMBER,
                          p_business_group_id IN NUMBER,
                          p_set_of_books_id IN NUMBER,
                          p_enc_line_type IN VARCHAR2, --Added for bug 2143723.
                          l_retcode      OUT NOCOPY VARCHAR2);


--Procedure clean_up_when_error;  --Commented for Enh. Restart Update Encumbrance Process.

/*UnCommented procedure for Enh. Restart Update Encumbrance Process.  */
PROCEDURE  move_qkupd_rec_to_hist( p_payroll_id	IN	NUMBER,
	   			     p_enc_line_type	IN	VARCHAR2,
			             p_business_group_id IN    NUMBER,
				     p_set_of_books_id   IN    NUMBER,
				     p_return_status	OUT NOCOPY	VARCHAR2);

/* Added for  Enh. Restart Update Encumbrance Process*/
PROCEDURE  cleanup_on_success	( p_enc_line_type 	IN 	VARCHAR2,
                                  p_payroll_id  	IN 	NUMBER,
                                  p_business_group_id 	IN 	NUMBER,
                                  p_set_of_books_id 	IN 	NUMBER,
                                  p_invalid_suspense 	IN	VARCHAR2,
                                  p_return_status	OUT NOCOPY 	VARCHAR2);

g_error_api_path                VARCHAR2(500); --Added for bug 21437123.

/*	commented for Enh. 2143723
FUNCTION backtrack(p_time_period_id IN NUMBER,p_enc_line_type VARCHAR2) return BOOLEAN;
--Added parameter p_enc_line_type to the function. Bug 2143723.
End of Enh. fix 2143723	*/

PROCEDURE ROLLBACK_REJECTED_ASG (p_payroll_id in integer,
                                 p_action_type in varchar2,
                                 p_gms_batch_name in varchar2,
                                 p_accepted_group_id in integer,
                                 p_rejected_group_id in integer,
                                 p_run_id      in integer,
                                 p_business_group_id in integer,
                                 p_set_of_books_id   in integer,
                                 p_return_status out nocopy varchar2);
END;

 

/
