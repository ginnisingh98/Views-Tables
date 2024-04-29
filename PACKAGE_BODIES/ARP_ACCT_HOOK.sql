--------------------------------------------------------
--  DDL for Package Body ARP_ACCT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ACCT_HOOK" AS
/* $Header: ARHOOKB.pls 115.2 99/07/16 23:59:01 porting s $ */

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
 |      p_mode                          IN  ONE or ALL Entities
 |      p_ae_doc_rec                    IN  Document record
 |      p_ae_event_rec                  IN  Event Record
 |      p_ae_line_tbl                   OUT Accounting lines table
 |      p_ae_created                    OUT Created accounting boolean
 |      p_replace_default_processing    OUT Values Y or N
 *=======================================================================*/
PROCEDURE Override_Ae_Lines(
	p_mode 				IN VARCHAR2,
        p_ae_doc_rec 			IN ae_doc_rec_type,
        p_ae_event_rec 			IN ae_event_rec_type,
	p_ae_line_tbl 			OUT ae_line_tbl_type,
        p_ae_created 			OUT BOOLEAN,
        p_replace_default_processing 	OUT BOOLEAN) IS

  l_ae_line_tbl		ae_line_tbl_type;
BEGIN
        arp_standard.debug( 'ARP_ACCT_HOOK.Override_Ae_Lines()+');

 	p_replace_default_processing := FALSE;
	p_ae_created := FALSE;
	p_ae_line_tbl := l_ae_line_tbl;

        arp_standard.debug( 'ARP_ACCT_HOOK.Override_Ae_Lines()-');

EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ACCT_HOOK.Override_Ae_Lines');
     RAISE;

END Override_Ae_Lines;

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
 |      p_mode                          IN  ONE or ALL Entities
 |      p_ae_doc_rec                    IN  Document record
 |      p_ae_event_rec                  IN  Event Record
 |      p_ae_line_rec                   IN  Accounting line record
 |      p_account                       OUT Actual account
 |      p_account_valid                 OUT Valid account flag
 |      p_replace_default_account       OUT Override default account
 *=======================================================================*/
PROCEDURE Override_Account(
        p_mode                          IN VARCHAR2,
        p_ae_doc_rec                    IN ae_doc_rec_type,
        p_ae_event_rec                  IN ae_event_rec_type,
        p_ae_line_rec 			IN ae_line_rec_type,
        p_account 			OUT NUMBER,
        p_account_valid 		OUT BOOLEAN,
        p_replace_default_account 	OUT BOOLEAN ) IS
BEGIN

        arp_standard.debug( 'ARP_ACCT_HOOK.Override_Account()+');

	p_replace_default_account := FALSE;
	p_account_valid := FALSE;
	p_account := -1;

        arp_standard.debug( 'ARP_ACCT_HOOK.Override_Account()-');

EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ACCT_HOOK.Override_Account');
     RAISE;

END Override_Account;

END ARP_ACCT_HOOK;

/
