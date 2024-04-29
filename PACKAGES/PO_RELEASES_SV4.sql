--------------------------------------------------------
--  DDL for Package PO_RELEASES_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RELEASES_SV4" AUTHID CURRENT_USER as
/* $Header: POXPOR4S.pls 115.4 2004/01/21 19:16:07 jskim ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_RELEASES_SV

  DESCRIPTION:		Contains all server side procedures that access the
			PO_RELEASES entity

  CLIENT/SERVER:	SERVER

  LIBRARY NAME		NONE

  OWNER:		KPOWELL

  PROCEDURES/FUNCTIONS:	get_release_num()
			get_po_release_id()
			val_release_date()
			val_doc_num_unique()
			val_approval_status()

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_release_num

  DESCRIPTION:		Gets the next release number to be created for
			the Blanket or Schedule Release

  PARAMETERS:		po_header_id		IN	NUMBER
			release_num		IN OUT  NUMBER

  DESIGN REFERENCES:


  ALGORITHM:		Get the maximum release number created for the
				PLANNED or BLANKET purchase order
			If there is not a maximum, set the
				release number to 1

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL CREATED 4/15

===========================================================================*/

PROCEDURE release_post_query
(
    X_release_id                IN  NUMBER,
    X_rel_total                 OUT NOCOPY NUMBER,
    X_encumbered_flag           OUT NOCOPY VARCHAR2,
    X_release_type              IN  VARCHAR2,
    X_po_header_id              IN  NUMBER,
    X_rel_total_2               OUT NOCOPY NUMBER,
    X_ship_via_lookup_code      OUT NOCOPY VARCHAR2,
    X_ship_num                  OUT NOCOPY NUMBER,
    p_ship_to_org_id            IN  NUMBER,             --< Bug 3378554 Start >
    p_po_authorization_status   IN  VARCHAR2,
    p_freight_terms_lookup_code IN  VARCHAR2,
    p_fob_lookup_code           IN  VARCHAR2,
    p_pay_on_code               IN  VARCHAR2,
    x_ship_to_org_code          OUT NOCOPY VARCHAR2,
    x_agreement_status          OUT NOCOPY VARCHAR2,
    x_freight_terms             OUT NOCOPY VARCHAR2,
    x_fob                       OUT NOCOPY VARCHAR2,
    x_pay_on_dsp                OUT NOCOPY VARCHAR2     --< Bug 3378554 End >
);

  PROCEDURE get_release_num
		      (X_po_header_id IN     NUMBER,
		       X_release_num  IN OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:	get_po_release_id

  DESCRIPTION:		Gets the po_release_id for a given release number.

  PARAMETERS:		release_id_record_type	IN	RECORD

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG	12/6/96		Created

===========================================================================*/

  PROCEDURE  get_po_release_id	(x_po_release_id_record	IN OUT	NOCOPY rcv_shipment_line_sv.release_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	val_release_date

  DESCRIPTION:		Verifies that the release date is within
			the start and end date of the BLANKET or
			PLANNED purchase order.

  PARAMETERS:		po_header_id			IN	NUMBER
			release_date			IN	DATE
			X_valid_release_date_flag 	IN OUT 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL CREATED 4/15

===========================================================================*/
  PROCEDURE val_release_date
		      (X_po_header_id            IN     NUMBER,
		       X_release_date            IN     DATE,
		       X_valid_release_date_flag IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  FUNCTION NAME:	val_doc_num_unique

  DESCRIPTION:		Verifies that the release number is unique
			for a Planned or Blanket purchase order.

  PARAMETERS:		X_po_header_id        IN     NUMBER,
		        X_release_num 	      IN     NUMBER,
		        X_rowid               IN     VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL CREATED 5/4

===========================================================================*/

   FUNCTION val_doc_num_unique
		      (X_po_header_id         IN     NUMBER,
		       X_release_num 	      IN     NUMBER,
		       X_rowid                IN     VARCHAR2)
				RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	val_approval_status

  DESCRIPTION:		Validates if the approval status of the release
			header needs to be changed.

  PARAMETERS:		X_po_release_id            IN NUMBER,
		        X_release_num              IN NUMBER,
		        X_agent_id                 IN NUMBER,
		        X_release_date             IN DATE,
	 	        X_acceptance_required_flag IN VARCHAR2,
		        X_acceptance_due_date      IN VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:		If any of the following release header values
			have changed, return FALSE indicating that
			the release's approval status needs to be
			changed.

				release_num
				agent_id
				release_date
				acceptance_required_flag
				acceptance_due_date

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL CREATED 5/4

===========================================================================*/
   FUNCTION val_approval_status
		      (X_po_release_id            IN NUMBER,
		       X_release_num              IN NUMBER,
		       X_agent_id                 IN NUMBER,
		       X_release_date             IN DATE,
	 	       X_acceptance_required_flag IN VARCHAR2,
		       X_acceptance_due_date      IN VARCHAR2,
                       p_shipping_control         IN VARCHAR2
                       -- <INBOUND LOGISTICS FPJ>
                      ) RETURN BOOLEAN;


END PO_RELEASES_SV4;

 

/
