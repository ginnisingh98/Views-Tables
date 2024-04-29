--------------------------------------------------------
--  DDL for Package RCV_SETUP_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SETUP_S" AUTHID CURRENT_USER AS
/* $Header: RCVSTS1S.pls 115.1 2002/11/23 00:59:45 sbull ship $*/

/*===========================================================================
  FUNCTION NAME:	get_override_routing()

  DESCRIPTION:		Function returns Override Routing Option. If the
			Override Routing Option is NULL then it defaults the
			Option to 'N'.

			Function references a 'FND_PROFILE.GET' procedure
			defined by the AOL grp to retrieve the Override
			Routing Option.

  PARAMETERS:		None

  RETURN VALUE:		Override Routing Option:
				1 =  Standard Receipt
                		2 =  Inspection Required
                		3 =  Direct Delivery
			or null.


  DESIGN REFERENCES:	RCVRCERC.dd
			RCVRCMUR.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
FUNCTION get_override_routing  RETURN VARCHAR2;

/*===========================================================================
  FUNCTION NAME:	get_trx_proc_mode()

  DESCRIPTION:		Function returns Receiving's Transaction Processor
 			Mode.  If Transaction Processor Mode is NULL the it
			defaults the mode to 'ONLINE'.

			Function references a 'FND_PROFILE.GET' procedure
			defined by the AOL grp to retrieve the Receiving
			Transaction Processor Mode.

  PARAMETERS:		None

  RETURN VALUE:		Receiving Transaction Processor Mode:
				Batch
				Immediate
				On-line

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVRCMUR.dd
			RCVTXECO.dd
			RCVTXERE.dd
			RCVTXERT.dd

  ALGORITHM:


  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
FUNCTION get_trx_proc_mode  RETURN VARCHAR2;

/*===========================================================================
  FUNCTION NAME:	get_print_traveller()

  DESCRIPTION:		Function returns Print Traveller Option.  If Print
			Traveller Option is NULL then it defaults the Option
			to 'N'.

			Function references a 'FND_PROFILE.GET' procedure
			defined by the AOL grp to retreive the value of the
			Print Traveller Option.

  PARAMETERS:		None

  RETURN VALUE:		Y = auto-print the traveller
			N = do not auto-print the traveller

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVRCMUR.dd
			RCVTXECO.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
FUNCTION get_print_traveller  RETURN VARCHAR2;
/*===========================================================================
  PROCEDURE NAME: get_org_locator_control()

  DESCRIPTION:
	o DEF - For the organization, get the locator control
                and negative_inventory_receipt_code
  PARAMETERS:

  DESIGN REFERENCES:	RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_org_locator_control (x_org_id           IN NUMBER,
                                   x_locator_cc      OUT NOCOPY NUMBER,
                                   x_negative_inv_rc OUT NOCOPY NUMBER) ;

/*===========================================================================
  PROCEDURE NAME:	get_receipt_number_info()

  DESCRIPTION:		Procedure gets the user defined receipt number code,
			manual receipt and purchase order number types from
			po_system parameters

  PARAMETERS:		x_user_defined_rcpt_num_code OUT (MANUAL  or AUTOMATIC)
                        x_manual_rcpt_num_type OUT (NUMERIC or ALPHANUMERIC)
                        x_manual_po_num_type      OUT (NUMERIC or ALPHANUMERIC)

  DESIGN REFERENCES:	RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
PROCEDURE get_receipt_number_info (x_user_defined_rcpt_num_code  OUT NOCOPY VARCHAR2,
                                   x_manual_rcpt_num_type  OUT NOCOPY VARCHAR2,
                                   x_manual_po_num_type       OUT NOCOPY VARCHAR2) ;

/*===========================================================================

  FUNCTION NAME : get_chart_of_accounts

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    :

  ALGORITHM     : Retreive chart of accounts id from
                  financials_system_parameters and gl_sets_of_books table

  NOTES         :

===========================================================================*/
FUNCTION get_chart_of_accounts RETURN NUMBER;

END RCV_SETUP_S;

 

/
