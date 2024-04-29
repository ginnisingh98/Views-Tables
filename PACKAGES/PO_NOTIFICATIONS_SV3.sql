--------------------------------------------------------
--  DDL for Package PO_NOTIFICATIONS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTIFICATIONS_SV3" AUTHID CURRENT_USER AS
/* $Header: POXBWN3S.pls 120.0.12010000.1 2008/09/18 12:20:43 appldev noship $*/

/*===========================================================================
  PROCEDURE NAME: 	forward_all

  DESCRIPTION:		Forwards all notifications with message name
			'AWAITING_YOUR_APPROVAL' from one approval queue
			to another.

  PARAMETERS:		x_old_employee_id  IN NUMBER,
		        x_new_employee_id  IN NUMBER,
		        x_note	           IN VARCHAR2 DEFAULT NULL

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE forward_all (x_old_employee_id  IN NUMBER,
		       x_new_employee_id  IN NUMBER,
		       x_note	          IN VARCHAR2 DEFAULT NULL);

/*===========================================================================
  PROCEDURE NAME: 	forward_document

  DESCRIPTION:		Forwards a notification with message name
			'AWAITING_YOUR_APPROVAL' from one approver
			to another.

  PARAMETERS:		x_new_employee_id      IN NUMBER,
			x_doc_type	       IN VARCHAR2,
			x_object_id	       IN NUMBER,
			x_note		       IN VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE forward_document (x_new_employee_id  IN NUMBER,
			    x_doc_type	       IN VARCHAR2,
			    x_object_id	       IN NUMBER,
			    x_note	       IN VARCHAR2 DEFAULT NULL);

/*===========================================================================
  PROCEDURE NAME: 	delete_from_fnd_notif

  DESCRIPTION:		This procedure is called by the post-delete trigger
			on po_notifications to delete the same notification
			from fnd_notifications.

  PARAMETERS:		n_object_type_lookup_code  IN VARCHAR2,
			n_object_id	           IN NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE delete_from_fnd_notif (n_object_type_lookup_code  IN VARCHAR2,
			   	   n_object_id	              IN NUMBER);

  FUNCTION get_emp_name (x_emp_id  NUMBER)
	return VARCHAR2;

--  pragma restrict_references (get_emp_name, WNDS,WNPS);

  FUNCTION get_wf_role_id (x_role_name VARCHAR2)
	return number;

--  pragma restrict_references (get_wf_role_id, WNDS,WNPS);

  FUNCTION get_doc_total (x_document_type_code	VARCHAR2,
			  x_object_id		NUMBER)
	return NUMBER;
--  pragma restrict_references (get_doc_total, WNDS);

END po_notifications_sv3;

/
