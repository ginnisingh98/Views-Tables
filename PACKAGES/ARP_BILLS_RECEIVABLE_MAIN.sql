--------------------------------------------------------
--  DDL for Package ARP_BILLS_RECEIVABLE_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BILLS_RECEIVABLE_MAIN" AUTHID CURRENT_USER AS
/* $Header: ARBRACMS.pls 120.1 2002/11/15 01:47:45 anukumar ship $ */

/* =======================================================================
 | PUBLIC Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS ARP_ACCT_MAIN.ae_doc_rec_type;
SUBTYPE ae_event_rec_type IS ARP_ACCT_MAIN.ae_event_rec_type;
SUBTYPE ae_line_rec_type  IS ARP_ACCT_MAIN.ae_line_rec_type;
SUBTYPE ae_line_tbl_type  IS ARP_ACCT_MAIN.ae_line_tbl_type;
SUBTYPE ae_sys_rec_type   IS ARP_ACCT_MAIN.ae_sys_rec_type;
SUBTYPE ae_rule_rec_type  IS ARP_ACCT_MAIN.ae_app_rule_rec_type;

/* =======================================================================
 | PUBLIC Procedures/functions
 * ======================================================================*/

/* =======================================================================
 | PROCEDURE Execute
 |
 | DESCRIPTION
 | 	Accounting Entry Derivation Method
 | 	----------------------------------
 | 	This procedure is the Accounting Entry derivation method for all
 | 	accounting events associated with the receivable applications
 |      layer for Receipts and CM's.
 |
 | 	Functions of the AE Derivation Method are:
 | 		- Single Entry Point for easy extensibility
 | 		- Read Event Data
 | 		- Read Transaction and Setup Data
 | 		- Determine AE Lines affected
 | 		- Derive AE Lines
 | 		- Return AE Lines created in a PL/SQL table.
 |
 | PARAMETERS
 | 	p_mode		IN	Document or Accounting Event mode
 | 	p_ae_doc_rec	IN	Document Record
 | 	p_ae_event_rec	IN	Event Record
 | 	p_ae_line_tbl	OUT NOCOPY	AE Lines table
 | 	p_ae_created	OUT NOCOPY	AE Lines creation status
 * ======================================================================*/
PROCEDURE Execute( p_mode 		IN  VARCHAR2,
		   p_ae_doc_rec         IN  ae_doc_rec_type,
		   p_ae_event_rec 	IN  ae_event_rec_type,
		   p_ae_line_tbl 	OUT NOCOPY ae_line_tbl_type,
		   p_ae_created         OUT NOCOPY BOOLEAN);

/* =======================================================================
 | PROCEDURE Delete_Acct
 |
 | DESCRIPTION
 | 	Deletes the accounting entry lines for a document
 | 	--------------------------------------------------
 | 	This procedure is the Accounting Entry deletion routine which
 | 	deletes the accounting entries for Receipts from the
 |      AR_DISTRIBUTIONS table.
 |
 | PARAMETERS
 | 	p_mode		IN	Document or Accounting Event mode
 | 	p_ae_doc_rec	IN	Document Record
 | 	p_ae_event_rec	IN	Event Record
 | 	p_ae_created	OUT NOCOPY	AE Lines creation status
 * ======================================================================*/
PROCEDURE Delete_Acct( p_mode         IN      VARCHAR2,
                       p_ae_doc_rec   IN OUT NOCOPY  ae_doc_rec_type,
                       p_ae_event_rec IN      ae_event_rec_type,
                       p_ae_deleted   OUT NOCOPY     BOOLEAN);

END ARP_BILLS_RECEIVABLE_MAIN;

 

/
