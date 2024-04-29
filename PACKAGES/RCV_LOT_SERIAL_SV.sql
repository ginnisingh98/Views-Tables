--------------------------------------------------------
--  DDL for Package RCV_LOT_SERIAL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_LOT_SERIAL_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTXLSS.pls 120.1 2005/06/14 18:28:40 wkunz noship $*/

/*=============================================================================
  Name: create_rcv_lotserial
  Desc: Create the necessary rcv_lots_interface and rcv_serials_interface
        rows based on the rows created in the mtl_transactions_lots_temp
        and the  mtl_serial_numbers_temp table.
        There is an issue here between v10 and 10sc.
        In 10 we inserted rows into the rcv_lots_interface
        and rcv_serials_interface tables through the
        lot and serial forms.  In 10sc we are using the Inventory lot and
        serial forms which insert into the mtl_transaction_lots_temp and
        the mtl_serial_numbers_temp table.  The issue here is that if the
        transaction_interface row was created by a 10 client then we want
        to continue to insert into the mtl_ tables.  If this trx was
        generated through a 10sc client then we need to insert into the
        10sc tables.  We are adding a flag use_mtl_lot_serial that is null
        allowable to tell us whether to use the rcv_ tables or the mtl_
        tables)

  Args: IN: interface_trx_id  - ID of the transaction to be rejected.
        IN: status            - New status of the transaction
  Reqs:
  Mods:
  Err :	return(FALSE) on error.  Error messages returned on AOL message stack
  Algr: update rcv_transactions_interface to set new status
  Note:
=============================================================================*/
PROCEDURE create_rcv_lotserial(interface_trx_id IN NUMBER,
			       use_mtl_lot      IN NUMBER,
			       use_mtl_serial   IN NUMBER);

END  RCV_LOT_SERIAL_SV;


 

/
