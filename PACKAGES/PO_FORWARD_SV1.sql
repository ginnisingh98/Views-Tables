--------------------------------------------------------
--  DDL for Package PO_FORWARD_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_FORWARD_SV1" AUTHID CURRENT_USER AS
/* $Header: POXAPFOS.pls 120.1 2005/07/22 05:26:40 ppaulsam noship $*/
/*===========================================================================
  PROCEDURE NAME: 	insert_action_history

  DESCRIPTION:		Inserts a record into the po_action_history_table

  PARAMETERS:		x_object_id		IN  NUMBER,
        		x_object_type_code	IN  VARCHAR2,
        		x_object_sub_type_code	IN  VARCHAR2,
			x_sequence_num		IN  NUMBER,
			x_action_code		IN  VARCHAR2,
			x_action_date		IN  DATE,
			x_employee_id    	IN  NUMBER,
			x_approval_path_id	IN  NUMBER,
			x_note			IN  VARCHAR2,
			x_object_revision_num	IN  NUMBER,
 			x_offline_code		IN  VARCHAR2,
        		x_request_id		IN  NUMBER,
        		x_program_application_id IN  NUMBER,
        		x_program_id		IN  NUMBER,
        		x_program_date		IN  DATE,
			x_program_update_date	IN  DATE,
			x_user_id		IN  NUMBER,
			x_login_id		IN  NUMBER);

  DESIGN REFERENCES:	POXDOFDO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE test_insert_action_history (x_object_id		IN  NUMBER,
        			   x_object_type_code		IN  VARCHAR2,
        			   x_object_sub_type_code	IN  VARCHAR2,
				   x_sequence_num		IN  NUMBER,
				   x_action_code		IN  VARCHAR2,
				   x_action_date		IN  DATE,
				   x_employee_id    		IN  NUMBER,
				   x_approval_path_id		IN  NUMBER,
				   x_note			IN  VARCHAR2,
				   x_object_revision_num	IN  NUMBER,
 				   x_offline_code		IN  VARCHAR2,
        			   x_request_id			IN  NUMBER,
        			   x_program_application_id	IN  NUMBER,
        			   x_program_id			IN  NUMBER,
        			   x_program_date		IN  DATE,
				   x_user_id			IN  NUMBER,
				   x_login_id			IN  NUMBER);

  PROCEDURE insert_action_history (x_object_id			IN  NUMBER,
        			   x_object_type_code		IN  VARCHAR2,
        			   x_object_sub_type_code	IN  VARCHAR2,
				   x_sequence_num		IN  NUMBER,
				   x_action_code		IN  VARCHAR2,
				   x_action_date		IN  DATE,
				   x_employee_id    		IN  NUMBER,
				   x_approval_path_id		IN  NUMBER,
				   x_note			IN  VARCHAR2,
				   x_object_revision_num	IN  NUMBER,
 				   x_offline_code		IN  VARCHAR2,
        			   x_request_id			IN  NUMBER,
        			   x_program_application_id	IN  NUMBER,
        			   x_program_id			IN  NUMBER,
        			   x_program_date		IN  DATE,
				   x_user_id			IN  NUMBER,
				   x_login_id			IN  NUMBER);

  -- Added as part of iProcurement R12 AME Integration Phase II Project.
  -- Added one more input parameter x_approval_group_id.
  PROCEDURE insert_action_history (x_object_id			IN  NUMBER,
        			   x_object_type_code		IN  VARCHAR2,
        			   x_object_sub_type_code	IN  VARCHAR2,
				   x_sequence_num		IN  NUMBER,
				   x_action_code		IN  VARCHAR2,
				   x_action_date		IN  DATE,
				   x_employee_id    		IN  NUMBER,
				   x_approval_path_id		IN  NUMBER,
				   x_note			IN  VARCHAR2,
				   x_object_revision_num	IN  NUMBER,
 				   x_offline_code		IN  VARCHAR2,
        			   x_request_id			IN  NUMBER,
        			   x_program_application_id	IN  NUMBER,
        			   x_program_id			IN  NUMBER,
        			   x_program_date		IN  DATE,
				   x_user_id			IN  NUMBER,
				   x_login_id			IN  NUMBER,
                                   x_approval_group_id          IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	insert_all_action_history

  DESCRIPTION:		This procedure is called by the forward documents
			form when all documents in one approval queue is
			forwarded to another approval queue.  For each
			existing record in po_action_history that has
			employee_id = old_approver_id and null action code, it
			inserts a new record with new_approver_id.
			The action_date, action_code and note fields in this new
			record are null.

  PARAMETERS:		x_old_employee_id  IN NUMBER,
			x_new_employee_id  IN NUMBER,
			x_offline_code     IN VARCHAR2,
			x_user_id	   IN NUMBER,
			x_login_id	   IN NUMBER

  DESIGN REFERENCES:	POXDOFDO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE test_insert_all_action_history (x_old_employee_id  IN NUMBER,
				            x_new_employee_id  IN NUMBER,
			                    x_offline_code     IN VARCHAR2,
					    x_user_id	       IN NUMBER,
					    x_login_id	   IN NUMBER);

  PROCEDURE insert_all_action_history (x_old_employee_id  IN NUMBER,
				     x_new_employee_id  IN NUMBER,
			             x_offline_code     IN VARCHAR2,
				     x_user_id	        IN NUMBER,
			             x_login_id	        IN NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	update_action_history

  DESCRIPTION:		This procedure is called when selective documents in
			an approval queue are forwarded.  It updates the
			existing record in po_action_history that has
			old_approver_id and NULL action_code with action_code
			'FORWARD'.  It also clears the field offline_code
			if value is other than 'PRINTED'.

  PARAMETERS:		x_object_id		IN NUMBER,
			x_object_type_code	IN VARCHAR2,
			x_old_employee_id	IN NUMBER,
			x_action_code		IN VARCHAR2,
			x_note			IN VARCHAR2,
			x_user_id	   	IN NUMBER,
			x_login_id	   	IN NUMBER

  DESIGN REFERENCES:	POXDOFDO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE update_action_history (x_object_id		IN NUMBER,
				 x_object_type_code	IN VARCHAR2,
				 x_old_employee_id	IN NUMBER,
                                 x_action_code          IN VARCHAR2,
				 x_note			IN VARCHAR2,
				 x_user_id		IN NUMBER,
				 x_login_id		IN NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	update_all_action_history

  DESCRIPTION:		This procedure is called by the forward documents
			form when all documents in one approval queue is
			forwarded to another approval queue.  It updates all
			existing records in po_action_history that has
			old_approver_id and NULL action_code with action_code
			'FORWARD'.  It also clears the field offline_code
			if it does not have value 'PRINTED'.

  PARAMETERS:		x_old_employee_id  IN NUMBER,
			x_note		   IN VARCHAR2,
			x_user_id	   IN NUMBER,
			x_login_id	   IN NUMBER

  DESIGN REFERENCES:	POXDOFDO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE test_update_all_action_history (x_old_employee_id  IN NUMBER,
				     	x_note		   IN VARCHAR2,
					x_user_id	   IN NUMBER,
					x_login_id	   IN NUMBER);

  PROCEDURE update_all_action_history (x_old_employee_id  IN NUMBER,
				     	x_note		   IN VARCHAR2,
					x_user_id	   IN NUMBER,
					x_login_id	   IN NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	update_all_action_history

  DESCRIPTION:		Locks record in po_action_history.  Uses the value
			of last_update_date to determine whether record
			has changed.

  PARAMETERS:		x_rowid			VARCHAR2,
		    	x_last_update_date  	DATE

  DESIGN REFERENCES:	POXDOFDO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE lock_row (x_rowid		  VARCHAR2,
		      x_last_update_date  DATE);

END po_forward_sv1;

 

/
