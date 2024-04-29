--------------------------------------------------------
--  DDL for Package RCV_BILL_UPDATING_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_BILL_UPDATING_SV" AUTHID CURRENT_USER AS
/* $Header: RCVBLUPS.pls 115.2 2003/07/24 22:14:03 sumboh ship $*/

/*===========================================================================
  PACKAGE NAME:     RCV_BILL_UPDATING_SV

  DESCRIPTION:

  CLIENT/SERVER:    Server

  LIBRARY NAME

  OWNER:

  PROCEDURE NAMES:  ap_update_po_distributions()
            ap_update_po_line_locations()
            ap_update_rcv_transactions()
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME: ap_update_po_distributions()

  DESCRIPTION:
    This procedure will accept a quantity_billed and the UOM in which the
    quantity is, and convert it to the UOM corresponding to PO_DISTRIBUTIONS
    and then insert the value. Also all values need to be added to the
    existing values in the respective columns.

  USAGE:

  PARAMETERS:   X_po_distribution_id    IN  NUMBER
            PO Distribution ID
        X_quantity_billed   IN  NUMBER
            Billed quantity, need to convert to PO UOM
        X_uom_lookup_code   IN  VARCHAR2
            UOM in which the quantity is
        X_amount_billed     IN  NUMBER
            Billed amount
--      X_base_amount_billed    IN  NUMBER
--          Base billed amount


  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
    25-Jan-99   James Zhang Created
===========================================================================*/
PROCEDURE ap_update_po_distributions(   X_po_distribution_id    IN  NUMBER,
                                        X_quantity_billed       IN  NUMBER,
                                        X_uom_lookup_code       IN  VARCHAR2,
                                        X_amount_billed         IN  NUMBER,
                                        X_matching_basis        IN  VARCHAR2 := 'QUANTITY');

/*===========================================================================
  PROCEDURE NAME: ap_update_po_line_locations()

  DESCRIPTION:
    This procedure will accept a quantity_billed and the UOM in which the
    quantity is, and convert it to the UOM corresponding to PO_LINE_LOCATIONS
    and then insert the value. Also all values need to be added to the
    existing values in the respective columns.

  USAGE:

  PARAMETERS:   X_po_line_location_id   IN  NUMBER
            PO line location ID
        X_quantity_billed   IN  NUMBER
            Billed quantity, need to convert to PO UOM
        X_uom_lookup_code   IN  VARCHAR2
            UOM in which the quantity is

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
    25-Jan-99   James Zhang Created
===========================================================================*/
PROCEDURE ap_update_po_line_locations(  X_po_line_location_id   IN  NUMBER,
                                        X_quantity_billed       IN  NUMBER,
                                        X_uom_lookup_code       IN  VARCHAR2,
                                        X_amount_billed         IN  NUMBER := NULL,
                                        X_matching_basis        IN  VARCHAR2 := 'QUANTITY');

/*===========================================================================
  PROCEDURE NAME: ap_update_rcv_transactions()

  DESCRIPTION:
    This procedure will accept a quantity_billed and the UOM in which the
    quantity is, and convert it to the UOM corresponding to RCV_TRANSACTIONS
    and then insert the value. Also all values need to be added to the
    existing values in the respective columns.


  USAGE:

  PARAMETERS:   X_rcv_transaction_id    IN  NUMBER
            Receiving transaction ID
        X_quantity_billed   IN  NUMBER
            Billed quantity, need to convert to PO UOM
        X_uom_lookup_code   IN  VARCHAR2
            UOM in which the quantity is
        X_amount_billed     IN  NUMBER
            Billed amount
--      X_base_amount_billed    IN  NUMBER           -- June 07, 1999
--          Base billed amount


  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
    25-Jan-99   James Zhang Created
===========================================================================*/
PROCEDURE ap_update_rcv_transactions(   X_rcv_transaction_id    IN  NUMBER,
                                        X_quantity_billed       IN  NUMBER,
                                        X_uom_lookup_code       IN  VARCHAR2,
                                        X_amount_billed         IN  NUMBER,
                                        X_matching_basis        IN  VARCHAR2 := 'QUANTITY');

END RCV_BILL_UPDATING_SV;

 

/
