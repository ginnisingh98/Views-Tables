--------------------------------------------------------
--  DDL for Package INV_RCV_STD_INSPECT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_STD_INSPECT_APIS" AUTHID CURRENT_USER AS
/* $Header: INVSTDIS.pls 120.0.12010000.1 2008/07/24 01:48:02 appldev ship $ */

/*
** -------------------------------------------------------------------------
** Procedure:   main_process
** Description:
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

PROCEDURE main_process(
    x_return_status       OUT NOCOPY     VARCHAR2
  , x_msg_count           OUT NOCOPY     NUMBER
  , x_msg_data            OUT NOCOPY     VARCHAR2
  , p_inventory_item_id   IN             NUMBER
  , p_organization_id     IN             NUMBER
  , p_lpn_id              IN             NUMBER
  , p_revision            IN             VARCHAR2
  , p_lot_number          IN             VARCHAR2
  , p_uom_code            IN             VARCHAR2
  , p_quantity            IN             NUMBER
  , p_inspection_code     IN             VARCHAR2
  , p_quality_code        IN             VARCHAR2
  , p_transaction_type    IN             VARCHAR2
  , p_reason_id           IN             NUMBER
  , p_serial_number       IN             VARCHAR2
  , p_accept_lpn_id       IN             NUMBER
  , p_reject_lpn_id       IN             NUMBER
  , p_transaction_date    IN             DATE DEFAULT SYSDATE
  , p_qa_collection_id    IN             NUMBER DEFAULT NULL
  , p_vendor_lot          IN             VARCHAR2 DEFAULT NULL
  , p_comments            IN             VARCHAR2 DEFAULT NULL
  , p_attribute_category  IN             VARCHAR2 DEFAULT NULL
  , p_attribute1          IN             VARCHAR2 DEFAULT NULL
  , p_attribute2          IN             VARCHAR2 DEFAULT NULL
  , p_attribute3          IN             VARCHAR2 DEFAULT NULL
  , p_attribute4          IN             VARCHAR2 DEFAULT NULL
  , p_attribute5          IN             VARCHAR2 DEFAULT NULL
  , p_attribute6          IN             VARCHAR2 DEFAULT NULL
  , p_attribute7          IN             VARCHAR2 DEFAULT NULL
  , p_attribute8          IN             VARCHAR2 DEFAULT NULL
  , p_attribute9          IN             VARCHAR2 DEFAULT NULL
  , p_attribute10         IN             VARCHAR2 DEFAULT NULL
  , p_attribute11         IN             VARCHAR2 DEFAULT NULL
  , p_attribute12         IN             VARCHAR2 DEFAULT NULL
  , p_attribute13         IN             VARCHAR2 DEFAULT NULL
  , p_attribute14         IN             VARCHAR2 DEFAULT NULL
  , p_attribute15         IN             VARCHAR2 DEFAULT NULL
  , p_secondary_qty               IN  NUMBER      DEFAULT NULL); --OPM Convergence

procedure range_serial_process(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_lpn_id                      IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_lot_number                  IN  VARCHAR2
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_from_serial_number          IN  VARCHAR2
, p_to_serial_number            IN  VARCHAR2
, p_accept_lpn_id               IN  NUMBER
, p_reject_lpn_id               IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2    DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL);

procedure main_process_po(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_po_header_id                IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2    DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL); --OPM Convergence

procedure main_process_intransit(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_shipment_header_id          IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2    DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL); --OPM Convergence

procedure main_process_rma(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_oe_order_header_id          IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2    DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL); --OPM Convergence

procedure main_process_receipt(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_receipt_num                 IN  VARCHAR2
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2    DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL); --OPM Convergence

procedure insert_inspect_rec_rti (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_rcv_transaction_id          IN  NUMBER
, p_quantity                    IN  NUMBER
, p_uom                         IN  VARCHAR2
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_date            IN  DATE
, p_transaction_type            IN  VARCHAR2
, p_vendor_lot                  IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_primary_qty                 IN  NUMBER
, p_organization_id             IN  NUMBER
, p_comments                    IN  VARCHAR2 DEFAULT NULL
, p_attribute_category          IN  VARCHAR2 DEFAULT NULL
, p_attribute1                  IN  VARCHAR2 DEFAULT NULL
, p_attribute2                  IN  VARCHAR2 DEFAULT NULL
, p_attribute3                  IN  VARCHAR2 DEFAULT NULL
, p_attribute4                  IN  VARCHAR2 DEFAULT NULL
, p_attribute5                  IN  VARCHAR2 DEFAULT NULL
, p_attribute6                  IN  VARCHAR2 DEFAULT NULL
, p_attribute7                  IN  VARCHAR2 DEFAULT NULL
, p_attribute8                  IN  VARCHAR2 DEFAULT NULL
, p_attribute9                  IN  VARCHAR2 DEFAULT NULL
, p_attribute10                 IN  VARCHAR2 DEFAULT NULL
, p_attribute11                 IN  VARCHAR2 DEFAULT NULL
, p_attribute12                 IN  VARCHAR2 DEFAULT NULL
, p_attribute13                 IN  VARCHAR2 DEFAULT NULL
, p_attribute14                 IN  VARCHAR2 DEFAULT NULL
, p_attribute15                 IN  VARCHAR2 DEFAULT NULL
, p_qa_collection_id            IN  NUMBER   DEFAULT NULL
, p_lpn_id                      IN  NUMBER   DEFAULT NULL
, p_transfer_lpn_id             IN  NUMBER   DEFAULT NULL
, p_mmtt_temp_id                IN  NUMBER   DEFAULT NULL
, p_sec_uom                     IN  VARCHAR2 DEFAULT NULL --OPM Convergenc
, p_secondary_qty               IN  NUMBER   DEFAULT NULL
  ); --OPM Convergence

procedure rcv_manager_rpc_call(
  x_return_status out NOCOPY varchar2
, x_return_code   out NOCOPY number);

procedure launch_rcv_manager_rpc(
  x_return_status out NOCOPY varchar2
, x_return_code   out NOCOPY number);

procedure rcv_manager_conc_call;

procedure launch_rcv_manager_conc;

FUNCTION get_inspection_qty(
 p_type 		IN 	VARCHAR2
,p_lpn_id 		IN 	NUMBER := NULL
,p_po_header_id 	IN 	NUMBER := NULL
,p_po_release_id 	IN 	NUMBER := NULL
,p_po_line_id 		IN 	NUMBER := NULL
,p_shipment_header_id 	IN 	NUMBER := NULL
,p_oe_order_header_id 	IN 	NUMBER := NULL
,p_organization_id 	IN 	NUMBER
,p_item_id 		IN 	NUMBER
,p_uom_code 		IN 	VARCHAR2
,x_inspection_qty 	OUT 	NOCOPY NUMBER
,x_return_status 	OUT 	NOCOPY VARCHAR2
,x_msg_data 		OUT 	NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION get_inspection_qty_wrapper(
 p_type 	   IN VARCHAR2
,p_id1 		   IN NUMBER 	:= NULL
,p_id2 		   IN NUMBER 	:= NULL
,p_id3 		   IN NUMBER    := NULL
,p_organization_id IN NUMBER
,p_item_id	   IN NUMBER
,p_uom_code  	   IN VARCHAR2) RETURN NUMBER;


PROCEDURE obtain_receiving_information(
          p_lpn_id IN NUMBER
        , p_organization_id IN NUMBER
        , p_inventory_item_id IN NUMBER
        , x_po_id OUT NOCOPY VARCHAR2
        , x_po_number OUT NOCOPY VARCHAR2
        , x_po_return_status OUT NOCOPY VARCHAR2
        , x_vendor_id OUT NOCOPY VARCHAR2
        , x_vendor_name OUT NOCOPY VARCHAR2
        , x_asl_status_id OUT NOCOPY VARCHAR2
        , x_asl_status_dsp OUT NOCOPY VARCHAR2
        , x_rma_id OUT NOCOPY VARCHAR2
        , x_rma_number OUT NOCOPY VARCHAR2
        , x_rma_return_status OUT NOCOPY VARCHAR2
        , x_customer_id OUT NOCOPY VARCHAR2
        , x_customer_number OUT NOCOPY VARCHAR2
        , x_customer_name OUT NOCOPY VARCHAR2
        , x_intshp_id OUT NOCOPY VARCHAR2
        , x_intshp_number OUT NOCOPY VARCHAR2
        , x_intshp_return_status OUT NOCOPY VARCHAR2
        , x_receipt_number OUT NOCOPY VARCHAR2
        , x_receipt_return_status OUT NOCOPY VARCHAR2
        , x_msg_count OUT NOCOPY VARCHAR2
        , x_msg_data OUT NOCOPY VARCHAR2);

FUNCTION is_revision_required (
			       p_source_type        IN VARCHAR2
			       , p_source_id        IN NUMBER
			       , p_item_id 	    IN NUMBER
			       ) RETURN NUMBER;

end inv_rcv_std_inspect_apis;

/
