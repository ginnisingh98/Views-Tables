--------------------------------------------------------
--  DDL for Package PO_REQS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQS_SV" AUTHID CURRENT_USER as
/* $Header: POXRQR1S.pls 120.0 2005/06/01 17:43:01 appldev noship $ */
/*===========================================================================
  PACKAGE NAME:		po_reqs_sv

  DESCRIPTION:		Contains all server side procedures that access the
			requisitions  entity

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		RMULPURY

  PROCEDURE/FUNCTIONS:	lock_row_for_status_update
                        get_reqs_auth_status()
			update_reqs_header_status()
			delete_children()
			delete_req()
			insert_req()
			update_oe_flag()
===========================================================================*/

/*===========================================================================
  FUNCTION NAME:	lock_row_for_status_update

  DESCRIPTION:   	Locks a row in the po_requisition_headers table
			for update by the approvals and control forms.

  PARAMETERS:		x_requisition_header_id		IN	NUMBER

  DESIGN REFERENCES:	POXDOAPP.dd, POXDOCON.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	7/26	created it
                        wlau    7/31    change api name
===========================================================================*/

PROCEDURE lock_row_for_status_update (x_requisition_header_id  IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME:	update_reqs_header_status

  DESCRIPTION:          Updates requisition header status fields.

  PARAMETERS:           X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
                        X_req_action_history_code IN OUT VARCHAR2,
                        X_req_control_error_rc    IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            1. If control action is 'CANCEL' and all lines
                           are closed, update requisition header's
                           authorization_status to 'CANCELLED'.

                        2. If requisition still has lines that are on
                           open po shipment, update requisition
                           header's authorization_status to 'APPROVED'.

                        3. If control action is 'FINALLY CLOSE', update
                           closed_code to 'FINALLY CLOSED'.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
                        WLAU       7/13     Added X_req_action_history_code
                                            parameter.
===========================================================================*/
  PROCEDURE update_reqs_header_status
                       (X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
                        X_req_action_history_code IN OUT NOCOPY VARCHAR2,
                        X_req_control_error_rc    IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	get_req_encumbered

  DESCRIPTION:	   	Check if any distributions for a REQ is encumbered.

  PARAMETERS:		X_req_hdr_id	IN NUMBER

  DESIGN REFERENCES:

  ALGORITHM:		1. Check if any distributions for a given
			   req_header_id is encumbered.
			2. If there encumbered distributions, return TRUE
			   else return FALSE.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SMURUGES 	11/22/99	Created(930894)
			SMURUGES	12/01/99	Modified(930894)
							Closed the cursor
							when it fetches some
							rows.
============================================================================*/

  FUNCTION get_req_encumbered(X_req_hdr_id IN NUMBER) RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	val_req_delete

  DESCRIPTION:	   	Checks if the REQ is not encumbered.
			If it is encumbered, cannot delete the Requisition.

  PARAMETERS:		X_req_hdr_id	IN NUMBER

  DESIGN REFERENCES:

  ALGORITHM:		1. Calls get_req_encumbered and checks if the REQ
			   is encumbered.
			2. If the REQ is encumbered, displays the message
			   "PO_RQ_USE_LINE_DEL" and returns FALSE.
			3. If the REQ is not encumbered returns TRUE.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SMURUGES 	11/22/99	Created(930894)
============================================================================*/

  FUNCTION val_req_delete(X_req_hdr_id IN NUMBER) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	delete_children

  DESCRIPTION:		Deletes all the children associated with
			a requisition header. The following entities
			are deleted for a specific header:

			- distributions
			- lines

  PARAMETERS:		X_req_hdr_id	IN NUMBER

  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:		DEBUG. Need to verify if notifications should
			also be  deleted as a part of  this package.

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY 	05/10	Created
===========================================================================*/

PROCEDURE delete_children(X_req_hdr_id	IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:	delete_req

  DESCRIPTION:		Cover routine for deleting the requisition
			header and the following entities associated
			with the requisition header.

			- header
			- lines
			- distributions
			- notifications

  PARAMETERS:		X_req_hdr_id	IN NUMBER


  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	05/10	Created
===========================================================================*/

PROCEDURE delete_req(X_req_hdr_id  IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:	insert_req

  DESCRIPTION:		Cover routine to insert a requisition header
			and notification. This procedure also
			handles automatic numbering.

  PARAMETERS:		See below.

  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:		X_manual should be FALSE if numbering is 'AUTOMATIC'
			and it  should be TRUE if 'MANUAL' numbering
			is being used for requisitions.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	05/10	Created
===========================================================================*/

PROCEDURE   insert_req(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Requisition_Header_Id   IN OUT	NOCOPY NUMBER,
                       X_Preparer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                IN OUT NOCOPY VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Description                    VARCHAR2,
                       X_Authorization_Status           VARCHAR2,
                       X_Note_To_Authorizer             VARCHAR2,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Transferred_To_Oe_Flag         VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_On_Line_Flag                   VARCHAR2,
                       X_Preliminary_Research_Flag      VARCHAR2,
                       X_Research_Complete_Flag         VARCHAR2,
                       X_Preparer_Finished_Flag         VARCHAR2,
                       X_Preparer_Finished_Date         DATE,
                       X_Agent_Return_Flag              VARCHAR2,
                       X_Agent_Return_Note              VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Interface_Source_Code          VARCHAR2,
                       X_Interface_Source_Line_Id       NUMBER,
                       X_Closed_Code                    VARCHAR2,
		       X_Manual				BOOLEAN,
		       X_amount				NUMBER,
		       X_currency_code			VARCHAR2,
                       p_org_id                     IN  NUMBER   default null         -- <R12 MOAC>
                      );

/*===========================================================================
  PROCEDURE NAME:	update_oe_flag

  DESCRIPTION:		Update the column transferred_to_oe_flag
			for the specific requisition.


  PARAMETERS:		X_req_hdr_id	IN NUMBER
			X_flag		IN VARCHAR2

  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	Created 	05/10
===========================================================================*/

PROCEDURE update_oe_flag(X_req_hdr_id	IN NUMBER,
			 X_flag		IN VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:	get_req_startup_values

  DESCRIPTION:          Gets startup values required for requisitions.


  PARAMETERS:           X_source_inventory        IN OUT VARCHAR2,
			X_source_vendor           IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       RMULPURY       08/10     Created
===========================================================================*/
  PROCEDURE get_req_startup_values
                       (X_source_inventory        IN OUT NOCOPY VARCHAR2,
                        X_source_vendor		  IN OUT NOCOPY VARCHAR2);



END PO_REQS_SV;
 

/
