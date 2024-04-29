--------------------------------------------------------
--  DDL for Package ARP_ACCT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ACCT_HOOK" AUTHID CURRENT_USER AS
/* $Header: ARHOOKS.pls 115.2 99/07/16 23:59:08 porting s $ */

-- Declare PUBLIC Data Types

-- Standard SLA data types
SUBTYPE ae_doc_rec_type 	IS ARP_ACCT_MAIN.ae_doc_rec_type;
SUBTYPE ae_event_rec_type 	IS ARP_ACCT_MAIN.ae_event_rec_type;
SUBTYPE ae_line_rec_type 	IS ARP_ACCT_MAIN.ae_line_rec_type;
SUBTYPE ae_line_tbl_type 	IS ARP_ACCT_MAIN.ae_line_tbl_type;

/*========================================================================
 | PUBLIC PROCEDURE Override_Ae_Lines
 |
 | DESCRIPTION
 |      Overrides Accounting entry lines of a Document
 |      -----------------------------------------------
 |      This procedure is part of a user hook which overrides the actual
 |      accounting lines created by the MAIN routines for a given document
 |      to enable the user to build the accounting.
 |
 | PARAMETERS
 |      p_mode 				IN  ONE or ALL Entities
 |      p_ae_doc_rec 			IN  Document record
 |      p_ae_event_rec 			IN  Event Record
 |      p_ae_line_tbl 			OUT Accounting lines table
 |      p_ae_created 			OUT Created accounting boolean
 |      p_replace_default_processing 	OUT Values Y or N
 *=======================================================================*/
PROCEDURE Override_Ae_Lines(
	p_mode 				IN VARCHAR2,
        p_ae_doc_rec 			IN ae_doc_rec_type,
        p_ae_event_rec 			IN ae_event_rec_type,
	p_ae_line_tbl 			OUT ae_line_tbl_type,
        p_ae_created 			OUT BOOLEAN,
        p_replace_default_processing 	OUT BOOLEAN);

/*========================================================================
 | PUBLIC PROCEDURE Override_Account
 |
 | DESCRIPTION
 |      Overrides the accounts created by the MAIN accounting routines
 |      --------------------------------------------------------------
 |      Enables the user to override an existing code combination id
 |      for accounts associated with accounting entry lines built for a
 |      Document.
 |
 | PARAMETERS
 |      p_mode 				IN  ONE or ALL Entities
 |      p_ae_doc_rec 			IN  Document record
 |      p_ae_event_rec 			IN  Event Record
 |      p_ae_line_rec                   IN  Accounting line record
 |      p_account                       OUT Actual account
 |      p_account_valid                 OUT Valid account flag
 |      p_replace_default_account       OUT Override default account
 *=======================================================================*/
PROCEDURE Override_Account(
	p_mode 				IN VARCHAR2,
        p_ae_doc_rec 			IN ae_doc_rec_type,
        p_ae_event_rec 			IN ae_event_rec_type,
        p_ae_line_rec                   IN ae_line_rec_type,
        p_account                       OUT NUMBER,
        p_account_valid                 OUT BOOLEAN,
        p_replace_default_account       OUT BOOLEAN );

END ARP_ACCT_HOOK;

 

/
