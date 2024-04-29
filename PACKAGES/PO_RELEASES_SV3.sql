--------------------------------------------------------
--  DDL for Package PO_RELEASES_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RELEASES_SV3" AUTHID CURRENT_USER as
/* $Header: POXPOR3S.pls 120.0.12010000.1 2008/09/18 12:21:03 appldev noship $ */

/*===========================================================================
  PACKAGE NAME:		PO_RELEASES_SV2

  DESCRIPTION:		Contains all server side procedures that access the
			PO_RELEASES entity

  CLIENT/SERVER:	SERVER

  LIBRARY NAME		NONE

  OWNER:		KPOWELL

  PROCEDURES/FUNCTIONS:
			test_get_release_num
			test_val_doc_num_unique
			test_val_approval_status

===========================================================================*/

   PROCEDURE test_get_release_num
		      (X_po_header_id IN     NUMBER);

   PROCEDURE test_val_doc_num_unique (X_po_header_id   IN NUMBER,
				      X_release_num    IN NUMBER,
					X_rowid	 IN VARCHAR2);

   PROCEDURE test_val_approval_status(
		       X_po_release_id            IN NUMBER,
		       X_release_num              IN NUMBER,
		       X_agent_id                 IN NUMBER,
		       X_release_date             IN DATE,
	 	       X_acceptance_required_flag IN VARCHAR2,
		       X_acceptance_due_date      IN VARCHAR2);



END PO_RELEASES_SV3;

/
