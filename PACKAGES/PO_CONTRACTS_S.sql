--------------------------------------------------------
--  DDL for Package PO_CONTRACTS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CONTRACTS_S" AUTHID CURRENT_USER AS
/* $Header: pocontvs.pls 120.0.12010000.1 2008/09/18 12:20:38 appldev noship $ */
/* Declare global variables */

msgbuf                   varchar2(200);

/*===========================================================================
  FUNCTION NAME:       val_contract_amount

  DESCRIPTION:		Is used in the podsu.lpc file to determine if a given
			po can be approved based on the lines of that po
			being related to a contract with available funds to
			be approved.


  PARAMETERS:		X_po_header_id IN NUMBER - The po header id you're
						   attempting to approve

  ALGORITHM:		Get each line of the po that you're trying
			to approve and get the contract number.
			Then for each line see if the amount
			on existing po lines for that contract + what
			you're trying to approve exceeds what's avaiable
			on the contract.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_contract_amount (X_po_header_id IN NUMBER) RETURN NUMBER;

pragma restrict_references (val_contract_amount,WNDS,RNPS,WNPS);

PROCEDURE test_val_contract_amount (X_po_header_id IN NUMBER);

END PO_CONTRACTS_S;


/
