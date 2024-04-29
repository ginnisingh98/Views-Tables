--------------------------------------------------------
--  DDL for Package PO_NOTIFICATIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTIFICATIONS_SV2" AUTHID CURRENT_USER AS
/* $Header: POXBWN2S.pls 115.1 2002/11/26 23:56:17 sbull ship $*/

/*===========================================================================
  PROCEDURE NAME: 	insert_into_po_notif

  DESCRIPTION:		Called by the send_po_notif procedure
			to insert notification into the po_notifications
			table when a notification is inserted into the
			fnd_notifications table.

  PARAMETERS:		x_employee_id  		IN 	NUMBER,
			x_message_name		IN	VARCHAR2,
			x_doc_type		IN 	VARCHAR2,
			x_object_id		IN 	NUMBER,
			x_doc_creation_date	IN	DATE,
			x_start_effective_date  IN	DATE,
			x_end_effective_date	IN	DATE

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE insert_into_po_notif (x_employee_id IN 	NUMBER,
			x_message_name		IN	VARCHAR2,
			x_doc_type		IN 	VARCHAR2,
			x_object_id		IN 	NUMBER,
			x_doc_creation_date	IN      DATE,
			x_start_effective_date  IN	DATE,
			x_end_effective_date	IN	DATE);

/*===========================================================================
  PROCEDURE NAME: 	update_fnd_notif

  DESCRIPTION:		Called by the database trigger to update
			notification in fnd_notifications when one is
			updated in po_notifications.

  PARAMETERS:		x_object_type_lookup_code	IN  VARCHAR2,
			x_object_id			IN  NUMBER,
			x_old_employee_id		IN  NUMBER,
			x_new_employee_id		IN  NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE update_fnd_notif (x_object_type_lookup_code	IN  VARCHAR2,
			    x_object_id			IN  NUMBER,
			    x_old_employee_id		IN  NUMBER,
			    x_new_employee_id		IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	update_po_notif

  DESCRIPTION:		Forwards notification into the po_notifications
			table when a notification is forwarded into the
			fnd_notifications table.

  PARAMETERS:		x_new_employee_id	IN  NUMBER,
		     	x_doc_type		IN  VARCHAR2,
		     	x_object_id		IN  NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	6/14	created
===========================================================================*/

  PROCEDURE update_po_notif (x_new_employee_id  IN	NUMBER,
		     x_doc_type		  IN	VARCHAR2,
		     x_object_id	  IN	NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	delete_from_po_notif

  DESCRIPTION:		Deletes notification from the po_notifications
			table when a notification is deleted from the
			fnd_notifications table.

  PARAMETERS:		x_new_employee_id  	NUMBER,
		     	x_old_employe_id	NUMBER,
		     	x_doc_type		VARCHAR2,
		     	x_object_id		NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	6/14	created
===========================================================================*/

  PROCEDURE delete_from_po_notif (x_doc_type	  IN	VARCHAR2,
			          x_object_id   IN	NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	get_doc_type_subtype

  DESCRIPTION:		Determines the document type and subtype given the
			document type lookup code used by fnd_notifications.

  PARAMETERS:		x_notif_doc_type	IN	VARCHAR2,
			x_type			OUT	VARCHAR2,
			x_subtype		OUT	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	6/15	created
===========================================================================*/

PROCEDURE get_doc_type_subtype (x_notif_doc_type	IN	VARCHAR2,
			    x_type		OUT	NOCOPY VARCHAR2,
			    x_subtype		OUT	NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME: 	get_fnd_doc_type

  DESCRIPTION:		Determines the document type lookup code used by the
			fnd_notifications table given the document type lookup
			code used by the po_notifications table.

  PARAMETERS:		x_po_type_code      IN     VARCHAR2,
			x_object_id	    IN     NUMBER,
			x_fnd_type_code	    IN OUT VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE get_fnd_doc_type (x_po_type_code      IN     VARCHAR2,
				x_object_id	    IN     NUMBER,
			        x_fnd_type_code	    IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME: 	get_fnd_message_name

  DESCRIPTION:		Determines the message name used by the fnd_notifications
			table given the message name used by the po_notifications
			table.

  PARAMETERS:		x_old_message_name	IN     VARCHAR2,
			x_new_message_name	IN OUT VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE get_fnd_msg_name (x_old_message_name	IN     VARCHAR2,
			      x_new_message_name	IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME: 	insert_into_fnd_notif

  DESCRIPTION:		Inserts a notification into fnd_notifications.
		        This procedure is called by the database trigger to insert
			a notification into fnd_notifications whenever one is
			inserted into po_notifications.  It is also called by the
			procedure install_fnd_notif to copy notifications from
			the po_notifications table to the fnd_notifications table.

  PARAMETERS:		n_object_type_lookup_code     IN  VARCHAR2,
			n_object_id		      IN  NUMBER,
			n_employee_id	      	      IN  NUMBER,
			n_start_date_active	      IN  DATE,
			n_end_date_active	      IN  DATE,
			n_notification_id	      OUT NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE insert_into_fnd_notif(n_object_type_lookup_code  IN  VARCHAR2,
			   n_object_id		      IN  NUMBER,
			   n_employee_id	      IN  NUMBER,
			   n_start_date_active	      IN  DATE,
			   n_end_date_active	      IN  DATE,
			   n_notification_id	      OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME: 	Install_fnd_notif

  DESCRIPTION:		Copies all notifications from the po_notifications
			table into the fnd_notifications table.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/25	created
===========================================================================*/

  PROCEDURE install_fnd_notif;

END;

 

/
