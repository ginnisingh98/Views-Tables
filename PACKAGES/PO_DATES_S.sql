--------------------------------------------------------
--  DDL for Package PO_DATES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DATES_S" AUTHID CURRENT_USER AS
/* $Header: POXCODAS.pls 115.3 2004/05/26 00:34:51 spangulu ship $*/

/* bao - global variables*/
  x_po_install_status VARCHAR2(2) := NULL;
  x_inv_install_status VARCHAR2(2) := NULL;
  x_sqlgl_install_status VARCHAR2(2) := NULL;
  x_last_org_id NUMBER := NULL;
  x_po_app_id NUMBER := NULL;
  x_sqlgl_app_id NUMBER := NULL;
  x_inv_app_id  NUMBER := NULL;

  /* Bug 3647086: Forward port; reverting faulty cache fix.
   * We no longer need these global variables:
   * x_last_txn_date, x_po_closing_status,
   * x_inv_closing_status, x_other_closing_status
   * Added global variable x_inv_app_id for clarity in body code.
   * Added global variable x_sqlgl_install_status to use as cache.
   */



/*===========================================================================
  FUNCTION NAME:	val_open_period()

  DESCRIPTION:		Checks the install status for Inventory and Purchasing.

			Calls get_closing_status to validate that a date is in
 			an open GL, Inventory or Purchasing period (depending
			on which application short name is passed in).  Only
			checks Inventory and Purchasing if they are installed.
			Always checks GL.

  PARAMETERS:

  Parameter	IN/OUT	Datatype	Description
  ------------- ------- --------------- -------------------------------------
  x_trx_date 	IN 	DATE		Date to be validated
  x_sob_id   	IN 	NUMBER,		Set of Books ID
  x_app_name 	IN 	VARCHAR2	Application short name:
				 	  GL  = General Ledger
					  INV = Inventory
					  PO  = Purchasing
  x_org_id	IN	NUMBER		Organization ID

  RETURN VALUE:		TRUE if date is in an open GL, Inventory or Purchasing
			period or if Inventory or Purchasing is not installed.
  			FALSE if date is not in an open GL, Inventory or
			Purchasing period.

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXECO.dd
			RCVTXERE.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_open_period(x_trx_date IN DATE,
			 x_sob_id   IN NUMBER,
			 x_app_name IN VARCHAR2,
		 	 x_org_id   IN NUMBER)RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	get_app_id()

  DESCRIPTION:		Determines the application id for the application
			short name passed in.

  Parameter	IN/OUT	Datatype	Description
  ------------- ------- --------------- -------------------------------------
  x_app_name 	IN 	VARCHAR2   	Application Short Name:
					  SQLGL  = General Ledger
					  PO     = Purchasing

  RETURN VALUE:		Application ID

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXECO.dd
			RCVTXERE.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION get_app_id(x_app_name  IN VARCHAR2)RETURN NUMBER;

/*===========================================================================
  FUNCTION NAME:	get_closing_status()

  DESCRIPTION:		Gets the closing status of the GL or Purchasing
			period (depending on which application ID
			is passed in) for a given date.

  PARAMETERS:

  Parameter	IN/OUT	Datatype	Description
  ------------- ------- --------------- -------------------------------------
  x_trx_date 	IN	DATE		Date to be validated.
  x_sob	   	IN 	NUMBER		Set of Books ID.
  x_app_id 	IN 	NUMBER   	Application ID.

  RETURN VALUE:		C = closed
			F = future
			N = never opened
			O = open
			P = permanently closed


  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXECO.dd
			RCVTXERE.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION get_closing_status(x_trx_date IN DATE,
		            x_sob_id   IN NUMBER,
		            x_app_id   IN NUMBER)RETURN VARCHAR2;

/*===========================================================================
  FUNCTION NAME:	get_acct_period_status()

  DESCRIPTION:		Gets the closing status of the GL accounting period
 			for a given date.

  PARAMETERS:

  Parameter	IN/OUT	Datatype	Description
  ------------- ------- --------------- -------------------------------------
  x_trx_date 	IN	DATE		Date to be validated.
  x_sob	   	IN 	NUMBER		Set of Books ID.
  x_app_id 	IN 	NUMBER   	Application ID.
  x_org_id	IN   	NUMBER		Organization ID

  RETURN VALUE:		C = closed
			F = future
			N = never opened
			O = open
			P = permanently closed


  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXECO.dd
			RCVTXERE.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION get_acct_period_status(x_trx_date IN DATE,
		                x_sob_id   IN NUMBER,
		                x_app_id   IN NUMBER,
				x_org_id   IN NUMBER)RETURN VARCHAR2;

END PO_DATES_S;

 

/
