--------------------------------------------------------
--  DDL for Package QA_SKIPLOT_RCV_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SKIPLOT_RCV_GRP" AUTHID CURRENT_USER AS
/* $Header: qaslrcvs.pls 120.0.12000000.2 2007/07/05 11:23:35 bhsankar ship $ */

    --
    -- This package containts the external APIs
    -- called from PO code.
    --

    --
    -- This procedure locks rows in criteria table to
    -- prevent multiple users from accessing the same
    -- criteria at the same time.
    -- This is done to prevent over skipping.
    --

    PROCEDURE CHECK_AVAILABILITY
        (p_api_version IN NUMBER,  -- 1.0
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_organization_id IN NUMBER,
        x_qa_availability OUT NOCOPY VARCHAR2, -- return fnd_api.g_true/false
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2);

    --
    -- This procedure calls skip lot evaluation
    -- engine to evaluate inspection status for
    -- a given lot and return "INSPECT" for
    -- inspection required lot and "STANDARD"
    -- for skipped lot.
    --

    PROCEDURE EVALUATE_LOT
        (p_api_version IN NUMBER,  -- 1.0
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_interface_txn_id IN NUMBER,
        p_organization_id IN NUMBER,
        p_vendor_id IN NUMBER,
        p_vendor_site_id IN NUMBER,
        p_item_id IN NUMBER,
        p_item_revision IN VARCHAR2,
        p_item_category_id IN NUMBER,
        p_project_id IN NUMBER,
        p_task_id IN NUMBER,
        p_manufacturer_id IN NUMBER,
        p_source_inspected IN NUMBER,
        p_receipt_qty IN NUMBER,
        p_receipt_date IN DATE,
        p_primary_uom IN varchar2 DEFAULT null,
        p_transaction_uom IN varchar2 DEFAULT null,
        p_po_header_id IN NUMBER DEFAULT null,
        p_po_line_id IN NUMBER DEFAULT null,
        p_po_line_location_id IN NUMBER DEFAULT null,
        p_po_distribution_id IN NUMBER DEFAULT null,
        p_lpn_id IN NUMBER DEFAULT null,
        p_wms_flag IN VARCHAR2 DEFAULT 'N',
        x_evaluation_result OUT NOCOPY VARCHAR2, -- returns INSPECTor STANDARD
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2);

    --
    -- This procedure is used to update qa_skiplot_rcv_results
    -- table with shipment line id and set valid flag to 2, i.e. valid
    -- The procedure is called from po rcv processor file rvtsh.lpc
    --
    PROCEDURE MATCH_SHIPMENT
        (p_api_version IN NUMBER,
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_interface_txn_id IN NUMBER,
        p_shipment_header_id IN NUMBER,
        p_shipment_line_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2);


    --
    -- ilawler Thu Jan 22 11:09:42 2004
    -- This procedure is used by PO's RCV integration to check a
    -- collection_id against qa_results and return a boolean representing
    -- whether results were actually collected with this collection_id.
    -- This API is being introduced for the ERES project so that an eRecord
    -- is only captured when quality results are present.
    -- returns x_result_present = {fnd_api.g_true | fnd_api.g_false}
    --
    PROCEDURE IS_QA_RESULT_PRESENT
        (p_api_version IN NUMBER, -- 1.0
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_collection_id IN NUMBER,
        x_result_present OUT NOCOPY VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2);

    --
    -- bug 6064562
    -- This procedure is used by PO's RCV integration to
    -- check if a receiving transaction lot was skipped.
    -- This API is being introduced since, AP Invoicing
    -- creates an hold for skipped records for PO's created
    -- with 4 Way Match with Receipt. This happens because
    -- AP calls Receiving API to get the quantity details
    -- from rcv_transactions but rcv_transactions does
    -- not maintain details of Skipped lots.
    -- returns x_skip_status = {fnd_api.g_true | fnd_api.g_false}
    -- bhsankar Thu Jul 5 04:09:04 PDT 2007
    --
    PROCEDURE IS_LOT_SKIPPED
        (p_api_version IN NUMBER, -- 1.0
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_transaction_id IN NUMBER,
        x_skip_status OUT NOCOPY VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2);

END QA_SKIPLOT_RCV_GRP;

 

/
