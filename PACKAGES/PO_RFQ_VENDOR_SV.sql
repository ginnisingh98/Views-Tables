--------------------------------------------------------
--  DDL for Package PO_RFQ_VENDOR_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RFQ_VENDOR_SV" AUTHID CURRENT_USER as
/* $Header: POXSORVS.pls 115.2 2002/11/25 22:38:32 sbull ship $ */
/*===========================================================================
  PACKAGE NAME:		PO_RFQ_VENDOR_SV

  DESCRIPTION:		This package contains the server side RFQ Vendor
			related Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  PROCEDURE NAMES:	get_sequence_num()
			val_seq_num_unique()
===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:	get_sequence_num()

  DESCRIPTION:		This procedure will get the next sequence number
			to be defaulted for an RFQ Vendor line.

  PARAMETERS:		X_po_header_id	IN	NUMBER
			X_sequence_num	IN OUT	NUMBER

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_get_sequence_num(X_po_header_id	IN	NUMBER);

PROCEDURE get_sequence_num
		(X_po_header_id		IN	NUMBER,
		 X_sequence_num		IN OUT	NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:	val_seq_num_unique()

  DESCRIPTION:		This procedure will verify the chosen sequence
			number is unique to the RFQ Vendor list

  PARAMETERS:		X_po_header_id		IN	NUMBER
			X_sequence_num		IN	NUMBER
			X_seq_num_is_unique	IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_val_seq_num_unique
		(X_po_header_id		IN	NUMBER,
		 X_sequence_num		IN	NUMBER);

PROCEDURE val_seq_num_unique
		(X_po_header_id		IN	NUMBER,
		 X_sequence_num		IN	NUMBER,
		 X_seq_num_is_unique	IN OUT	NOCOPY VARCHAR2);

END PO_RFQ_VENDOR_SV;

 

/
