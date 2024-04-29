--------------------------------------------------------
--  DDL for Package ARP_ADJUSTMENTS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ADJUSTMENTS_MAIN" AUTHID CURRENT_USER AS
/* $Header: ARTADJMS.pls 120.1.12010000.2 2008/11/13 09:41:14 dgaurab ship $ */
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

/* =======================================================================
 | PROCEDURE Execute
 |
 | DESCRIPTION
 |      Accounting Entry Derivation Method
 |      ----------------------------------
 |      This procedure is the Accounting Entry derivation method for all
 |      accounting events associated with adjustments and finance charges
 |
 |      Functions of the AE Derivation Method are:
 |              - Single Entry Point for easy extensibility
 |              - Read Event Data
 |              - Read Transaction and Setup Data
 |              - Determine AE Lines affected
 |              - Derive AE Lines
 |              - Return AE Lines created in a PL/SQL table.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_ae_line_tbl   OUT NOCOPY     AE Lines table
 |      p_ae_created    OUT NOCOPY     AE Lines creation status
 * ======================================================================*/
-- Added for Line Level Adjustment
PROCEDURE Execute( p_mode                IN VARCHAR2,
                   p_ae_doc_rec          IN ae_doc_rec_type,
                   p_ae_event_rec        IN ae_event_rec_type,
                   p_ae_line_tbl         OUT NOCOPY ae_line_tbl_type,
                   p_ae_created          OUT NOCOPY BOOLEAN,
		   p_from_llca_call      IN  VARCHAR2 DEFAULT 'N',
		   p_gt_id               IN  NUMBER   DEFAULT NULL);

/* =======================================================================
 | PROCEDURE Delete_Acct
 |
 | DESCRIPTION
 |      Deletes the accounting entry lines for Adjustments
 |      --------------------------------------------------
 |      This procedure is the Accounting Entry deletion routine which
 |      deletes the accounting entries for Adjustments from the
 |      AR_DISTRIBUTIONS table.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_ae_created    OUT NOCOPY     AE Lines creation status
 * ======================================================================*/
PROCEDURE Delete_Acct( p_mode         IN  VARCHAR2,
                       p_ae_doc_rec   IN  ae_doc_rec_type,
                       p_ae_event_rec IN  ae_event_rec_type,
                       p_ae_deleted   OUT NOCOPY BOOLEAN);

END ARP_ADJUSTMENTS_MAIN;

/
