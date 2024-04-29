--------------------------------------------------------
--  DDL for Package PO_RELEASES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RELEASES_SV" AUTHID CURRENT_USER as
/* $Header: POXPOR1S.pls 120.1 2005/06/10 01:57:24 kpsingh noship $ */

/*===========================================================================
  PACKAGE NAME:		PO_RELEASES_SV

  DESCRIPTION:		Contains all server side procedures that access the
			PO_RELEASES entity

  CLIENT/SERVER:	SERVER

  LIBRARY NAME		NONE

  OWNER:		KPOWELL

  PROCEDURES/FUNCTIONS:	lock_row_for_status_update
		        delete_release()
			delete_children()
			insert_release()
			update_release()

===========================================================================*/

/*===========================================================================
  FUNCTION NAME:	lock_row_for_status_update

  DESCRIPTION:   	Locks a row in the po_releases table for update.

  PARAMETERS:		x_po_release_id		IN	NUMBER

  DESIGN REFERENCES:	POXDOAPP.fmb

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	7/26	created it
===========================================================================*/

PROCEDURE lock_row_for_status_update (x_po_release_id  IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME:	delete_release

  DESCRIPTION:		Cover routine that includes deleting the
			release header and all of it's children.



  PARAMETERS:	        X_po_release_id IN NUMBER,
	                X_row_id        IN VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL CREATED 5/4

===========================================================================*/
   PROCEDURE delete_release
		      (X_po_release_id IN NUMBER,
	               X_row_id        IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	delete_children

  DESCRIPTION:		Deletes all of the children associated with
			a release header including:
				- shipments
				- distributions
				- attachements
				- notifications
				- the requisition link to the PO

  PARAMETERS:	        X_po_release_id IN NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:		DEBUG.  Need to include calls to other packages.
			(KP - 5/4)

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL CREATED 5/4

===========================================================================*/
   PROCEDURE delete_children
		      (X_po_release_id IN NUMBER);


END PO_RELEASES_SV;
 

/
