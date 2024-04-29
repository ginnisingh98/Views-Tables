--------------------------------------------------------
--  DDL for Package Body RCV_TRX_INTERFACE_TRX_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRX_INTERFACE_TRX_UPD_PKG" as
/* $Header: RCVTIR6B.pls 120.0.12010000.4 2013/01/31 03:45:06 wayin ship $ */

PROCEDURE update_rcv_transaction (
rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE) IS

X_rowid     ROWID;
X_progress  VARCHAR2(4) := '000';

BEGIN

  /*
  ** get the rowid for this transaction
  */
  X_progress := '010';

  SELECT rowid
  INTO   X_Rowid
  FROM   rcv_transactions_interface
  WHERE  interface_transaction_id = rcv_trx.interface_transaction_id;

  /*
  ** Update the columns of the transaction
  */
  RCV_TRX_INTERFACE_UPDATE_PKG.update_row(
     X_Rowid,
     rcv_trx.Interface_Transaction_Id,
     rcv_trx.Group_Id,
     rcv_trx.Last_Update_Date,
     rcv_trx.Last_Updated_By,
     rcv_trx.Last_Update_Login,
     rcv_trx.Transaction_Type,
     rcv_trx.Transaction_Date,
     rcv_trx.Processing_Status_Code,
     rcv_trx.Processing_Mode_Code,
     rcv_trx.Processing_Request_Id,
     rcv_trx.Transaction_Status_Code,
     rcv_trx.Category_Id,
     rcv_trx.Quantity,
     rcv_trx.Unit_Of_Measure,
     rcv_trx.Interface_Source_Code,
     rcv_trx.Interface_Source_Line_Id,
     rcv_trx.Inv_Transaction_Id,
     rcv_trx.Item_Id,
     rcv_trx.Item_Description,
     rcv_trx.Item_Revision,
     rcv_trx.Uom_Code,
     rcv_trx.Employee_Id,
     rcv_trx.Auto_Transact_Code,
     rcv_trx.Shipment_Header_Id,
     rcv_trx.Shipment_Line_Id,
     rcv_trx.Ship_To_Location_Id,
     rcv_trx.Primary_Quantity,
     rcv_trx.Primary_Unit_Of_Measure,
     rcv_trx.Receipt_Source_Code,
     rcv_trx.Vendor_Id,
     rcv_trx.Vendor_Site_Id,
     rcv_trx.From_Organization_Id,
     rcv_trx.To_Organization_Id,
     rcv_trx.Routing_Header_Id,
     rcv_trx.Routing_Step_Id,
     rcv_trx.Source_Document_Code,
     rcv_trx.Parent_Transaction_Id,
     rcv_trx.Po_Header_Id,
     rcv_trx.Po_Revision_Num,
     rcv_trx.Po_Release_Id,
     rcv_trx.Po_Line_Id,
     rcv_trx.Po_Line_Location_Id,
     rcv_trx.Po_Unit_Price,
     rcv_trx.Currency_Code,
     rcv_trx.Currency_Conversion_Type,
     rcv_trx.Currency_Conversion_Rate,
     rcv_trx.Currency_Conversion_Date,
     rcv_trx.Po_Distribution_Id,
     rcv_trx.Requisition_Line_Id,
     rcv_trx.Req_Distribution_Id,
     rcv_trx.Charge_Account_Id,
     rcv_trx.Substitute_Unordered_Code,
     rcv_trx.Receipt_Exception_Flag,
     rcv_trx.Accrual_Status_Code,
     rcv_trx.Inspection_Status_Code,
     rcv_trx.Inspection_Quality_Code,
     rcv_trx.Destination_Type_Code,
     rcv_trx.Deliver_To_Person_Id,
     rcv_trx.Location_Id,
     rcv_trx.Deliver_To_Location_Id,
     rcv_trx.Subinventory,
     rcv_trx.Locator_Id,
     rcv_trx.Wip_Entity_Id,
     rcv_trx.Wip_Line_Id,
     rcv_trx.Department_Code,
     rcv_trx.Wip_Repetitive_Schedule_Id,
     rcv_trx.Wip_Operation_Seq_Num,
     rcv_trx.Wip_Resource_Seq_Num,
     rcv_trx.Bom_Resource_Id,
     rcv_trx.Shipment_Num,
     rcv_trx.Freight_Carrier_Code,
     rcv_trx.Bill_Of_Lading,
     rcv_trx.Packing_Slip,
     rcv_trx.Shipped_Date,
     rcv_trx.Expected_Receipt_Date,
     rcv_trx.Actual_Cost,
     rcv_trx.Transfer_Cost,
     rcv_trx.Transportation_Cost,
     rcv_trx.Transportation_Account_Id,
     rcv_trx.Num_Of_Containers,
     rcv_trx.Waybill_Airbill_Num,
     rcv_trx.Vendor_Item_Num,
     rcv_trx.Vendor_Lot_Num,
     rcv_trx.Rma_Reference,
     rcv_trx.Comments,
     rcv_trx.Attribute_Category,
     rcv_trx.Attribute1,
     rcv_trx.Attribute2,
     rcv_trx.Attribute3,
     rcv_trx.Attribute4,
     rcv_trx.Attribute5,
     rcv_trx.Attribute6,
     rcv_trx.Attribute7,
     rcv_trx.Attribute8,
     rcv_trx.Attribute9,
     rcv_trx.Attribute10,
     rcv_trx.Attribute11,
     rcv_trx.Attribute12,
     rcv_trx.Attribute13,
     rcv_trx.Attribute14,
     rcv_trx.Attribute15,
     rcv_trx.Ship_Head_Attribute_Category,
     rcv_trx.Ship_Head_Attribute1,
     rcv_trx.Ship_Head_Attribute2,
     rcv_trx.Ship_Head_Attribute3,
     rcv_trx.Ship_Head_Attribute4,
     rcv_trx.Ship_Head_Attribute5,
     rcv_trx.Ship_Head_Attribute6,
     rcv_trx.Ship_Head_Attribute7,
     rcv_trx.Ship_Head_Attribute8,
     rcv_trx.Ship_Head_Attribute9,
     rcv_trx.Ship_Head_Attribute10,
     rcv_trx.Ship_Head_Attribute11,
     rcv_trx.Ship_Head_Attribute12,
     rcv_trx.Ship_Head_Attribute13,
     rcv_trx.Ship_Head_Attribute14,
     rcv_trx.Ship_Head_Attribute15,
     rcv_trx.Ship_Line_Attribute_Category,
     rcv_trx.Ship_Line_Attribute1,
     rcv_trx.Ship_Line_Attribute2,
     rcv_trx.Ship_Line_Attribute3,
     rcv_trx.Ship_Line_Attribute4,
     rcv_trx.Ship_Line_Attribute5,
     rcv_trx.Ship_Line_Attribute6,
     rcv_trx.Ship_Line_Attribute7,
     rcv_trx.Ship_Line_Attribute8,
     rcv_trx.Ship_Line_Attribute9,
     rcv_trx.Ship_Line_Attribute10,
     rcv_trx.Ship_Line_Attribute11,
     rcv_trx.Ship_Line_Attribute12,
     rcv_trx.Ship_Line_Attribute13,
     rcv_trx.Ship_Line_Attribute14,
     rcv_trx.Ship_Line_Attribute15,
     rcv_trx.Ussgl_Transaction_Code,
     rcv_trx.Government_Context,
     rcv_trx.Reason_Id,
     rcv_trx.Destination_Context,
     rcv_trx.Source_Doc_Quantity,
     rcv_trx.Source_Doc_Unit_Of_Measure,
     rcv_trx.Use_Mtl_Lot,
     rcv_trx.Use_Mtl_Serial);

END update_rcv_transaction;
--ROI project start
  PROCEDURE roi_update_rti_rhi(p_rti_id       IN NUMBER,
                               p_success_flag IN OUT NOCOPY NUMBER) IS
  BEGIN
    -- update the current RTI and its parent RTIs
    UPDATE rcv_transactions_interface
       SET request_id                = NULL,
           processing_request_id     = NULL,
           order_transaction_id      = NULL,
           primary_quantity          = NULL,
           primary_unit_of_measure   = NULL,
           interface_transaction_qty = NULL,
           processing_status_code    = 'PENDING',
           transaction_status_code   = 'PENDING',
           processing_mode_code      = 'BATCH'
     WHERE interface_transaction_id IN
           (SELECT interface_transaction_id
              FROM rcv_transactions_interface rti
             START WITH rti.interface_transaction_id = p_rti_id
            CONNECT BY PRIOR rti.parent_interface_txn_id =
                        rti.interface_transaction_id);

    UPDATE rcv_headers_interface
       SET processing_request_id  = NULL,
           receipt_header_id      = NULL,
           processing_status_code = 'PENDING'
     WHERE header_interface_id IN
           (SELECT header_interface_id
              FROM rcv_transactions_interface
             START WITH interface_transaction_id = p_rti_id
            CONNECT BY PRIOR
                        parent_interface_txn_id = interface_transaction_id);
    p_success_flag := 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_success_flag := 1;
  END roi_update_rti_rhi;

  PROCEDURE roi_update_rti_rhi_grp(p_rti_index        IN NUMBER,
                                   p_count            IN NUMBER,
                                   p_rti_id_tbl       IN rti_table,
                                   p_group_id_tbl     IN group_table,
                                   p_process_flag_tbl IN OUT NOCOPY process_flag,
                                   p_success_flag     IN OUT NOCOPY NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_rti_id         NUMBER;
    l_group_id       NUMBER;
    l_inner_rti_id   NUMBER;
    l_inner_group_id NUMBER;
    l_inner_index    NUMBER := 1;
  BEGIN

    l_rti_id   := p_rti_id_tbl(p_rti_index);
    l_group_id := p_group_id_tbl(p_rti_index);

    --update the current record(rhi,rti) and its parent
    roi_update_rti_rhi(l_rti_id, p_success_flag);
    p_process_flag_tbl(p_rti_index) := 1;
    IF p_success_flag = 0 THEN
      -- find records in the same group
      l_inner_index := p_rti_index + 1;
      WHILE (l_inner_index <= p_count) LOOP
        l_inner_rti_id   := p_rti_id_tbl(l_inner_index);
        l_inner_group_id := p_group_id_tbl(l_inner_index);
        --update rhi in same group
        IF p_success_flag = 0 AND p_process_flag_tbl(l_inner_index) = 0 AND
           l_group_id = l_inner_group_id THEN
          roi_update_rti_rhi(l_inner_rti_id, p_success_flag);
          p_process_flag_tbl(l_inner_index) := 1;
        END IF;
        l_inner_index := l_inner_index + 1;
      END LOOP;
    END IF;
    IF p_success_flag = 0 THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_success_flag := 1;
      ROLLBACK;
  END roi_update_rti_rhi_grp;

  /*===========================================================================

    PROCEDURE NAME:  RESUBMIT ()

  ===========================================================================*/
  PROCEDURE resubmit(p_rti_id_tbl       IN rti_table,
                     p_group_id_tbl     IN group_table,
                     p_process_flag_tbl IN OUT NOCOPY process_flag,
                     p_count            IN NUMBER) IS
    l_sucess_flag NUMBER := 0;
    l_index       NUMBER := 1;
    v_req_id      NUMBER;

  BEGIN

    IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Enter RCV_ROI_INTERFACE_PKG.RESUBMIT');
    END IF;

    WHILE (l_index <= p_count) LOOP
      ---update data record in same group and its parent if not processed
      IF (p_process_flag_tbl(l_index) = 0) THEN
        roi_update_rti_rhi_grp(l_index,
                               p_count,
                               p_rti_id_tbl,
                               p_group_id_tbl,
                               p_process_flag_tbl,
                               l_sucess_flag);
        --if update sucessfully then sibmit RTP with the group
        IF (l_sucess_flag = 0) THEN
          v_req_id := fnd_request.submit_request('PO',
                      'RVCTP',
                      null,
                      null,
                      false,
                      'BATCH',
                      p_group_id_tbl(l_index),
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        ELSE
          IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Unexpected exception in update rhi/rti : ' ||
                               SQLERRM);
          END IF;
        END IF;
      END IF;
      l_index       := l_index + 1;
      l_sucess_flag := 0;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Unexpected exception in RESUBMIT : ' ||
                           SQLERRM);
      END IF;
  END resubmit;
--ROI project end
END RCV_TRX_INTERFACE_TRX_UPD_PKG;

/
