--------------------------------------------------------
--  DDL for Package POR_RCV_ORD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_RCV_ORD_SV" AUTHID CURRENT_USER as
/* $Header: PORRCVOS.pls 120.2 2005/11/07 16:31:38 tolick noship $ */


type rcvInfoRecord is record(
rcv_line_id number,
available boolean,
used_quantity number);
type rcvInfoTable is table of rcvInfoRecord index by binary_integer;

/*************************************************************
 **  Public Function :
 **    groupPoTransaction
 **  Description :
 **    grouping logic to group and split into transaction lines
 **    each transaction line is inserted to rcv transaction interface
 **    return true if grouping is successful
 **************************************************************/

function groupPoTransaction (X_po_header_id             IN rcvNumberArray,
                            X_line_location_id          IN rcvNumberArray,
                            X_receipt_qty               IN rcvNumberArray,
                            X_receipt_uom               IN rcvVarcharArray,
                            X_receipt_date              IN date,
                            X_item_id                   IN rcvNumberArray,
                            X_uom_class                 IN rcvVarcharArray,
                            X_org_id                    IN rcvNumberArray,
                            X_po_distribution_id        IN rcvNumberArray,
                            X_group_id                  IN number,
                            X_caller                    IN varchar2,
                            X_Comments                  IN rcvVarcharArray,
                            X_PackingSlip               IN rcvVarcharArray,
                            X_WayBillNum                IN rcvVarcharArray)
 return number;


 /*************************************************************
 **  Public Function :
 **    groupInternalTransaction
 **  Description :
 **    grouping logic to group and split into transaction lines
 **    return true if grouping is successful
 **************************************************************/

function groupInternalTransaction (x_req_line_id in rcvNumberArray,
                           x_receipt_qty in rcvNumberArray,
                           x_receipt_uom in rcvVarcharArray,
                           x_item_id in rcvNumberArray,
                           x_uom_class in rcvVarcharArray,
                           x_org_id in rcvNumberArray,
                           x_comments in rcvVarcharArray,
                           x_packingSlip in rcvVarcharArray,
                           x_waybillNum in rcvVarcharArray,
                           x_group_id in number,
                           x_receipt_date in date,
                           x_caller in varchar2)
return number;


procedure INSERT_RCV_TXN_INTERFACE_IR   (
                                      X_rcv_shipment_line_id            IN number,
                                      x_req_line_id in number,
                                      X_receipt_qty             IN number,
                                      X_receipt_uom             IN varchar2,
                                      X_receipt_date            IN date,
                                      X_item_id                 IN number,
                                      X_uom_class               IN varchar2,
                                      X_org_id                  IN number,
                                      X_group_id                IN number,
                                      X_caller                  IN varchar2,
                                      X_Comments                IN varchar2 default null,
                                      X_PackingSlip             IN varchar2 default null,
                                      X_WayBillNum              IN varchar2 default null
);

procedure INSERT_RCV_TXN_INTERFACE   (X_source_type_code        IN varchar2 default 'VENDOR',
                                      X_rcv_shipment_line_id    IN number default 0,
                                      X_po_header_id            IN number,
                                      X_line_location_id        IN number,
                                      X_receipt_qty             IN number,
                                      X_receipt_uom             IN varchar2,
                                      X_receipt_date            IN date,
                                      X_item_id                 IN number,
                                      X_uom_class               IN varchar2,
                                      X_org_id                  IN number,
                                      X_po_distribution_id      IN number,
                                      X_group_id                IN number,
                                      X_caller                  IN varchar2,
                                      X_Comments                IN varchar2 default null,
                                      X_PackingSlip             IN varchar2 default null,
                                      X_WayBillNum              IN varchar2 default null
);

 /*************************************************************
 **  Function :     Process_Transactions
 **  Description :  This is a procedure that validates
 **                 the transactions and calls create_rcv_shipment_headers
 **                 and call_txn_processor.
 **************************************************************/

 function process_transactions          (X_group_id     IN number,
                                         X_caller       IN varchar2,
                                         X_Comments      IN varchar2 default null,
                                         X_PackingSlip   IN varchar2 default null,
                                         X_WayBillNum    IN varchar2 default null)
    return number;

 /*************************************************************
 **  Function    : Create_Rcv_Shipment_Header
 **  Description : This procedure creates a header
 **                for those txns that have the same vendor
 **                and to_org_id.
 **************************************************************/

 function create_rcv_shipment_headers   (X_group_Id     IN number,
                                         X_caller       IN varchar2,
                                         X_Comments     IN varchar2 default null,
                                         X_PackingSlip  IN varchar2 default null,
                                         X_WayBillNum   IN varchar2 default null)
    return boolean;

 /*************************************************************
 **  Function :     Call_Txn_Processor
 **  Description :  This function calls the transaction processor
 **                 in IMMEDIATE mode.
 **************************************************************/

 function call_txn_processor            (X_group_Id     IN number,
                                         X_caller       IN varchar2)
    return number;

 /*************************************************************
 **  Function :     check_group_id
 **  Description :  This function checks if there are records
 **                 in RTI with teh specified group id
 **************************************************************/
 FUNCTION check_group_id  (x_group_id IN NUMBER) RETURN BOOLEAN;

/*************************************************************
 **  Function :     cancel_pending_notifs
 **  Description :  This function cancels any open notifications
 **                 if the user has received from the web
 **************************************************************/
 PROCEDURE cancel_pending_notifs (x_group_id IN NUMBER) ;

/*************************************************************
 **  Function :     notif_is_active
 **  Description :  This function checks if the notification is
 **                 active ( ie., not COMPLETE or ERROR )
 **************************************************************/
 FUNCTION notif_is_active (wf_item_type in varchar2,
                           wf_item_key  in varchar2) RETURN BOOLEAN;

end;
 

/
