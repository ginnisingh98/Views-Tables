--------------------------------------------------------
--  DDL for Package INV_LPN_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LPN_TRX_PUB" AUTHID CURRENT_USER AS
  /*  $Header: INVTRXWS.pls 120.2.12010000.2 2009/04/09 20:59:54 liyzhu ship $ */

  --
  --      Name: PROCESS_LPN_TRX
  --
  --      Input parameters:
  --
  --      p_trx_hdr_id   Transaction Header Id identified a  batch
  --                  of records in MTL_MATERIAL_TRANSACTIONS_TEMP
  --      p_commit        default fnd_api.g_false
  --                  whether to commit  the changes  to  DB.
  --                  Note that if the batch specified has records with
  --                  multiple transaction_group_ids then this API would
  --                  automatically commit. This is to prevent deadlock
  --                  on MOQD as MOQD is locked before updating.
  --      p_proc_mode      Processing Mode. This  argument  is  generally NULL,
  --                  in  which  case the  TP:INV*  profiles   are
  --                  used to determine  how to process  this transaction
  --                  record.
  --      p_process_trx   Should the  transaction  be  completely processed  OR  only
  --                  the  LPN-pre-processing be done. Default  value  is  to
  --                  completely process  the transaction records. When  this
  --                  API  is  called from  the ProC  Manager (inltpu) only
  --                  LPN-pre-processing  is  done.
  --      p_atomic       Should all  the rows  in  MMTT with the same transaction_
  --                  header_id  be  processed as one holistic unit or should
  --                  each row be treated as separate. When set to fnd_api.true
  --                  an error in one  of  the rows  will result  in  aborting
  --                  the  processing of all  further rows in a  batch.
  --
  --
  --      Output  parameters:
  --      x_proc_msg       Error Message  from the  Process-Manager
  --      return_status     0  on  Success,  1 on Error
  --
  --      Functions:
  --       This  API is used  to  process a batch of LPN based transactions.
  --       The records comprising  the batch should be present in
  --       MTL_MATERIAL_TRANSACTIONS_TEMP and  possibly  the lot and
  --       serial temp tables before  invoking  this API. The batch of
  --       records  are identified  by  the value of TRANSACTION_HEADER_ID column
  --       in MTL_MATERIAL_TRANSACTIONS_TEMP.  This API  packs/unpack items/LPNs,
  --       updates  status of LPNs  and calls the Inventory  Transaction  Manager
  --       to update the  quantity.
  --      Note:
  --       To support  LPN functionality, 3  new fields have been  added  to
  --       MTL_MATERIAL_TRANSACTIONS_TEMP table.
  --        * CONTENT_LPN_ID :  If  the transaction involves a  complete  LPN
  --          then this  field  is  filled with  that LPN's ID.
  --          In this case, the INVENTORY_ITEM_ID should  be  -1.
  --        * LPN_ID : If the transaction involved unpacking  'FROM' an
  --          LPN, then  field  is  populated with  that LPN's ID.
  --          In this case, the INVENTORY_ITEM_ID or CONTENT_LPN_ID should
  --          have the ID of item or LPN that is to be UNPACKED.
  --        * TRANSFER_LPN_ID : If the transaction involves 'PACKING'
  --          an item or LPN to another LPN,  then field should  have the
  --          ID of the  LPN to which it is PACKed.
  --
  --
  --
  FUNCTION process_lpn_trx(
    p_trx_hdr_id         IN            NUMBER
  , p_commit             IN            VARCHAR2 := fnd_api.g_false
  , x_proc_msg           OUT NOCOPY    VARCHAR2
  , p_proc_mode          IN            NUMBER := NULL
  , p_process_trx        IN            VARCHAR2 := fnd_api.g_true
  , p_atomic             IN            VARCHAR2 := fnd_api.g_false
  , p_business_flow_code IN            NUMBER := NULL
  )
    RETURN NUMBER;

  -- For BUG 2919763, the message stack is initialized only if the new parameter
  -- p_init_msg_list is true.
  FUNCTION process_lpn_trx(
    p_trx_hdr_id         IN            NUMBER
  , p_commit             IN            VARCHAR2 := fnd_api.g_false
  , x_proc_msg           OUT NOCOPY    VARCHAR2
  , p_proc_mode          IN            NUMBER := NULL
  , p_process_trx        IN            VARCHAR2 := fnd_api.g_true
  , p_atomic             IN            VARCHAR2 := fnd_api.g_false
  , p_business_flow_code IN            NUMBER := NULL
  , p_init_msg_list      IN            BOOLEAN
  )
    RETURN NUMBER;

  --
  --  Name        : PROCESS_LPN_TRX
  --  Description : This procedure encapsulates all the operations that need
  --                to be done related to LPNs in a transaction record.
  --                The operations are grouped based on the transaction_action
  --                and the contents of the columsn CONTENT_LPN_ID, LPN_ID
  --                and TRANSFER_LPN_ID.  This procedure is called from
  --                BaseTransaction.java and is called in the context of
  --                processing one transaction record in MMTT
  --
  PROCEDURE process_lpn_trx_line(
    x_return_status              OUT NOCOPY    VARCHAR2
  , x_proc_msg                   OUT NOCOPY    VARCHAR2
  , p_transaction_temp_id        IN            NUMBER
  , p_business_flow_code         IN            NUMBER := NULL
  , p_transaction_source_type_id IN            NUMBER
  , p_transaction_action_id      IN            NUMBER
  , p_lpn_id                     IN            NUMBER := NULL
  , p_content_lpn_id             IN            NUMBER := NULL
  , p_transfer_lpn_id            IN            NUMBER := NULL
  , p_organization_id            IN            NUMBER
  , p_subinventory_code          IN            VARCHAR2
  , p_locator_id                 IN            NUMBER := NULL
  , p_transfer_organization      IN            NUMBER := NULL
  , p_transfer_subinventory      IN            VARCHAR2 := NULL
  , p_transfer_to_location       IN            NUMBER := NULL
  , p_primary_quantity           IN            NUMBER
  , p_primary_uom                IN            VARCHAR2 := NULL
  , p_transaction_quantity       IN            NUMBER
  , p_transaction_uom            IN            VARCHAR2
  , p_secondary_trx_quantity     IN            NUMBER := NULL
  , p_secondary_uom_code         IN            VARCHAR2 := NULL
  , p_inventory_item_id          IN            NUMBER
  , p_revision                   IN            VARCHAR2 := NULL
  , p_lot_number                 IN            VARCHAR2 := NULL
  , p_cost_group_id              IN            NUMBER
  , p_transfer_cost_group_id     IN            NUMBER := NULL
  , p_rcv_transaction_id         IN            NUMBER := NULL
  , p_shipment_number            IN            VARCHAR2 := NULL
  , p_transaction_source_id      IN            NUMBER := NULL
  , p_trx_source_line_id         IN            NUMBER := NULL
  , p_serial_control_code        IN            NUMBER := NULL
  , p_po_dest_expense            IN            NUMBER := NULL
  , p_manual_receipt_expense     IN            VARCHAR2 := NULL
  , p_source_transaction_id      IN            NUMBER := NULL
  );
END inv_lpn_trx_pub;

/
