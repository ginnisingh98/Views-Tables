--------------------------------------------------------
--  DDL for Package ARP_RECEIPTS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RECEIPTS_MAIN" AUTHID CURRENT_USER AS
/* $Header: ARRECACS.pls 120.2.12000000.2 2007/08/24 13:25:36 dgaurab ship $ */

/* =======================================================================
 | PUBLIC Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS ARP_ACCT_MAIN.ae_doc_rec_type;
SUBTYPE ae_event_rec_type IS ARP_ACCT_MAIN.ae_event_rec_type;
SUBTYPE ae_line_rec_type  IS ARP_ACCT_MAIN.ae_line_rec_type;
SUBTYPE ae_line_tbl_type  IS ARP_ACCT_MAIN.ae_line_tbl_type;
SUBTYPE ae_sys_rec_type   IS ARP_ACCT_MAIN.ae_sys_rec_type;
SUBTYPE ae_curr_rec_type  IS ARP_ACCT_MAIN.ae_curr_rec_type;
SUBTYPE ae_rule_rec_type  IS ARP_ACCT_MAIN.ae_app_rule_rec_type;

--Used to pair a UNAPP record with an APP, UNDID or ACC record as applicable
TYPE ae_app_pair_rec_type IS RECORD (
  status                  ar_distributions.source_type%TYPE, -- E.g. APP, ACC, UNID only
  source_id               ar_distributions.source_id%TYPE  , -- E.g. New APP receivable application id
  source_id_old           ar_distributions.source_id%TYPE  , -- E.g. Old APP receivable application id
  source_table            ar_distributions.source_table%TYPE
  );

--
-- Table for pairing APP, ACC, UNID records with UNAPP records when reversing a Cash Receipt
--
TYPE ae_app_pair_tbl_type IS TABLE of ae_app_pair_rec_type
  INDEX BY BINARY_INTEGER;

ae_app_pair_tbl ae_app_pair_tbl_type;

ae_app_pair_tbl_ctr           BINARY_INTEGER := 0;


ard_cash_receipt_id       ar_cash_receipts.cash_receipt_id%TYPE; -- E.g. Cash Receipt Id used for Initialising table

--Exception handler which raises an error if unable to derive a valid substituted ccid
invalid_ccid_error      EXCEPTION;  --bug6024475

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
		   p_ae_created         OUT NOCOPY BOOLEAN,
--{HYUDETUPT
p_from_llca_call  IN  VARCHAR2 DEFAULT 'N',
p_gt_id           IN  NUMBER   DEFAULT NULL
--}
     );

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

END ARP_RECEIPTS_MAIN;

 

/
