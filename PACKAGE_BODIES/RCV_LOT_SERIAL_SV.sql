--------------------------------------------------------
--  DDL for Package Body RCV_LOT_SERIAL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_LOT_SERIAL_SV" AS
/* $Header: RCVTXLSB.pls 120.2 2005/06/21 18:57:50 wkunz noship $*/

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
			       use_mtl_serial   IN NUMBER) IS

X_progress 	         VARCHAR2(4) := '000';

BEGIN

    /*
    ** Insert into the lots interface. The item is either under lot control
    ** only or is under both lot and serial control
    */
    IF (use_mtl_lot = 2 OR use_mtl_serial = 2) THEN

	X_progress := '010';

	INSERT INTO rcv_lots_interface (
                       INTERFACE_TRANSACTION_ID,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                       REQUEST_ID,
                       PROGRAM_APPLICATION_ID,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE,
                       LOT_NUM,
                       QUANTITY,
                       TRANSACTION_DATE,
                       EXPIRATION_DATE,
                       PRIMARY_QUANTITY,
                       ITEM_ID,
                       SHIPMENT_LINE_ID,
                     --Bug Fix # 1548597.
                     --Added the following Columns to Insert them into RCV_LOTS_INTERFACE.
                       SECONDARY_QUANTITY,
                       SUBLOT_NUM
                     --End of Modification for Bug # 1548597.
                       )
                SELECT rti.interface_transaction_id,
                       rti.last_update_date,
                       rti.last_updated_by,
                       rti.creation_date,
                       rti.created_by,
                       rti.last_update_login,
                       rti.request_id,
                       rti.program_application_id,
                       rti.program_id,
                       rti.program_update_date,
                       mtlt.lot_number,
                       mtlt.transaction_quantity,
                       rti.transaction_date,
                       mtlt.lot_expiration_date,
                       mtlt.primary_quantity,
                       rti.item_id,
                       rti.shipment_line_id,
                     --Bug Fix # 1548597.
                     --Added the following Columns to Insert into RCV_LOTS_INTERFACE table.
                       mtlt.secondary_quantity,
                       mtlt.sublot_num
                     --End of Modification for Bug # 1548597.
                FROM   rcv_transactions_interface rti,
                       mtl_transaction_lots_temp mtlt
                WHERE  rti.interface_transaction_id  = interface_trx_id
                AND    mtlt.transaction_temp_id = rti.interface_transaction_id;

    END IF;

    /*
    ** The item is only under serial control if the use_mtl_serial field
    ** is equal to 2.
    ** Insert into the serial interface. The item is under both lot and
    ** serial control if use_mtl_serial is equal to 5.  The serial form
    ** creates the serial rows with the transaction_temp_id equal to the
    ** interface_transaction_id
    */
    IF (use_mtl_serial = 2) THEN

	X_progress := '020';

       INSERT INTO rcv_serials_interface (
                       INTERFACE_TRANSACTION_ID,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                       REQUEST_ID,
                       PROGRAM_APPLICATION_ID,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE,
                       TRANSACTION_DATE,
                       FM_SERIAL_NUM,
                       TO_SERIAL_NUM,
                       SERIAL_PREFIX,
                       LOT_NUM,
                       VENDOR_SERIAL_NUM,
                       VENDOR_LOT_NUM,
                       ITEM_ID,
                       ORGANIZATION_ID)
                SELECT rti.interface_transaction_id,
                       rti.last_update_date,
                       rti.last_updated_by,
                       rti.creation_date,
                       rti.created_by,
                       rti.last_update_login,
                       rti.request_id,
                       rti.program_application_id,
                       rti.program_id,
                       rti.program_update_date,
                       rti.transaction_date,
                       mtst.fm_serial_number,
                       mtst.to_serial_number,
                       mtst.serial_prefix,
		       null,
                       null,
                       rti.vendor_lot_num,
                       rti.item_id,
                       rti.to_organization_id
                FROM   rcv_transactions_interface rti,
                       mtl_serial_numbers_temp mtst
                WHERE  rti.interface_transaction_id  = interface_trx_id
                AND    mtst.transaction_temp_id = rti.interface_transaction_id;

    /*
    ** The item is only under serial control if the use_mtl_serial field
    ** is equal to 2.
    ** Insert into the serial interface. The item is under both lot and
    ** serial control if use_mtl_serial is equal to 5.  The serial form
    ** creates the serial rows with the transaction_temp_id equal to the
    ** interface_transaction_id
    */
    ELSIF (use_mtl_serial = 5) THEN

       X_progress := '030';

       INSERT INTO rcv_serials_interface (
                       INTERFACE_TRANSACTION_ID,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                       REQUEST_ID,
                       PROGRAM_APPLICATION_ID,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE,
                       TRANSACTION_DATE,
                       FM_SERIAL_NUM,
                       TO_SERIAL_NUM,
                       SERIAL_PREFIX,
                       LOT_NUM,
                       VENDOR_SERIAL_NUM,
                       VENDOR_LOT_NUM,
                       ITEM_ID,
                       ORGANIZATION_ID)
                SELECT rti.interface_transaction_id,
                       rti.last_update_date,
                       rti.last_updated_by,
                       rti.creation_date,
                       rti.created_by,
                       rti.last_update_login,
                       rti.request_id,
                       rti.program_application_id,
                       rti.program_id,
                       rti.program_update_date,
                       rti.transaction_date,
                       mtst.fm_serial_number,
                       mtst.to_serial_number,
                       mtst.serial_prefix,
                       mtlt.lot_number,
                       null,
                       rti.vendor_lot_num,
                       rti.item_id,
                       rti.to_organization_id
                FROM   rcv_transactions_interface rti,
                       mtl_transaction_lots_temp mtlt,
                       mtl_serial_numbers_temp mtst
                WHERE  rti.interface_transaction_id  = interface_trx_id
                AND    mtlt.transaction_temp_id = rti.interface_transaction_id
                AND    mtlt.SERIAL_TRANSACTION_TEMP_ID =
                          mtst.transaction_temp_id;

   END IF;

   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('create_rcv_lotserial', X_progress, sqlcode);
   RAISE;

END create_rcv_lotserial;

END RCV_LOT_SERIAL_SV;


/
