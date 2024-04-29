--------------------------------------------------------
--  DDL for Package QA_SKIPLOT_RES_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SKIPLOT_RES_ENGINE" AUTHID CURRENT_USER AS
/* $Header: qaslress.pls 120.0.12010000.2 2009/08/07 09:44:50 skolluku ship $ */


    SUBTYPE lot_plan_rec IS QA_SKIPLOT_LOT_PLANS%ROWTYPE;
    TYPE lotPlanTable IS TABLE OF lot_plan_rec INDEX BY BINARY_INTEGER;

    --
    -- The procedure checks whether lot is accepted or rejected
    -- and set the plan states accordingly. It also update
    -- the lot result table with the inspection result.
    --
    --
    -- Bug 8678609. FP for Bug 4517387.
    -- Added a new parameter p_shipment_header_id to support skiplot based on ASN's.
    -- skolluku
    --
    PROCEDURE PROCESS_SKIPLOT_RESULT (
    p_collection_id IN NUMBER,
    p_insp_lot_id IN NUMBER DEFAULT NULL,
    p_shipment_line_id IN NUMBER DEFAULT NULL,
    p_inspected_qty IN NUMBER DEFAULT NULL,
    p_total_txn_qty IN NUMBER DEFAULT NULL,
    p_rcv_txn_id IN NUMBER DEFAULT NULL,
    p_shipment_header_id IN NUMBER DEFAULT NULL, -- Added for bug 8678609.
    p_lot_result OUT NOCOPY VARCHAR2);

    --
    -- This is an overloaded procedure, which takes LPN_ID
    -- as parameter. Internally, it calls process_skiplot_result
    -- defined above for each shipment line match the LPN_ID.
    -- The lot result will be the same for all the shipment lines
    --
    PROCEDURE PROCESS_SKIPLOT_RESULT (
    p_collection_id IN NUMBER,
    p_lpn_id IN NUMBER,
    p_inspected_qty IN NUMBER,
    p_total_txn_qty IN NUMBER,
    p_lot_result OUT NOCOPY VARCHAR2);

    --
    -- This procedure process MSCA mobile Skiplot inspection result
    -- Based on po number or receipt number or rma ID or intransit
    -- shipment ID, shipment_line_id is derived. For each shipment_
    -- line_id found, procedure PROCESS_SKIPLOT_RESULT is called.
    --
    PROCEDURE MSCA_PROCESS_SKIPLOT_RESULT (  p_collection_id IN  NUMBER,
                                             p_po_num        IN  VARCHAR2,
                                             p_receipt_num   IN  VARCHAR2,
                                             p_rma_id        IN  NUMBER,
                                             p_int_ship_id   IN  NUMBER,
                                             p_item          IN  VARCHAR2,
                                             p_revision      IN  VARCHAR2,
                                             p_org_id        IN  NUMBER,
                                             p_inspected_qty IN  NUMBER,
                                             p_total_txn_qty IN  NUMBER,
                                             x_lot_result    OUT NOCOPY VARCHAR2) ;

    --
    -- The procedure update the lot plans table with plan inspection
    -- results and returns affected rows.
    --
    PROCEDURE UPDATE_LOT_PLANS(
    p_collection_id IN NUMBER,
    p_insp_lot_id IN NUMBER,
    p_rcv_txn_id IN NUMBER,
    p_shipment_line_id IN NUMBER,
    p_inspected_qty IN NUMBER DEFAULT NULL,
    p_prev_txn_type IN VARCHAR2 DEFAULT NULL,
    p_reinsp_flag IN VARCHAR2 DEFAULT NULL);

    --
    -- The procedure updates the skiplot result table with
    -- lot inspection result and returns , inspection result
    -- and criteria_id
    --
    --
    -- Bug 8678609. FP for Bug 4517387.
    -- Added two new parameters p_shipment_header_id and p_rcv_txn_id to support
    -- skiplot based on ASN's.
    -- skolluku
    --
    PROCEDURE UPDATE_SKIPLOT_RESULT(
    p_collection_id IN NUMBER,
    p_insp_lot_id IN NUMBER DEFAULT NULL,
    p_shipment_line_id IN NUMBER DEFAULT NULL,
    p_total_txn_qty IN NUMBER DEFAULT NULL,
    p_prev_txn_type IN VARCHAR2 DEFAULT NULL,
    p_reinsp_flag IN VARCHAR2 DEFAULT NULL,
    p_shipment_header_id IN NUMBER DEFAULT NULL, -- Added for bug 8678609.
    p_rcv_txn_id IN NUMBER DEFAULT NULL, -- Added for bug 8678609.
    p_criteria_id OUT NOCOPY NUMBER,
    p_lot_plans OUT NOCOPY lotPlanTable,
    p_result OUT NOCOPY VARCHAR2);

    --
    -- The procedure updates the plan state table with new
    -- plan state
    --
    PROCEDURE UPDATE_PLAN_STATE(
    p_insp_result IN VARCHAR2,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_lot_plan IN lot_plan_rec,
    p_txn IN NUMBER,
    p_prev_txn_type IN VARCHAR2 DEFAULT NULL,
    p_reinsp_flag IN VARCHAR2 DEFAULT NULL);


    --
    -- The function returns skiplot flag stored in temporary table qa_insp_collections_temp
    --
    FUNCTION GET_SKIPLOT_FLAG (
    p_collection_id IN NUMBER) RETURN VARCHAR2;


    --
    -- The procedure set skiplot flag to 'T' or 'F'
    PROCEDURE SET_SKIPLOT_FLAG(
    p_collection_id IN NUMBER,
    p_skiplot_flag IN VARCHAR2);

    PROCEDURE LAUNCH_SHIPMENT_ACTION (
    p_po_txn_processor_mode IN VARCHAR2,
    p_po_group_id IN NUMBER,
    p_collection_id IN NUMBER,
    p_employee_id IN NUMBER,
    p_transaction_id IN NUMBER,
    p_uom IN VARCHAR2,
    p_lotsize IN NUMBER,
    p_transaction_date IN DATE,
    p_created_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_last_update_login IN NUMBER);

    --
    -- This procedure calculate the rejection quantity and
    -- acceptance quantity for a lot. The rejection quantity
    -- is the accumulated rejection quantity for all the
    -- plans. The acceptance quantity is the rest of the
    -- lot quantity.
    -- The procedure also returns the lookup code for ACCEPT
    -- and REJECT
    --
    PROCEDURE CALCULATE_QUANT_RESULT (
    p_collection_id IN NUMBER,
    p_lotqty IN NUMBER,
    p_rej_qty OUT NOCOPY NUMBER,
    p_acc_qty OUT NOCOPY NUMBER);

/*
  anagarwa Wed Apr 10 12:48:10 PDT 2002
  Qa MSCA: Following method should actually be placed in qltutlfb.pls
  But due to GSCC error for qltutlfb.pls, I'm putting it here. The related bug
  is 2312644.
  Whenever this is moved back to qltutlfb.pls, the java file
  $QA_TOP/java/util/ContextElementTable.java should be changed
*/

FUNCTION get_asl_status(p_org_id NUMBER,
                        p_po_num VARCHAR2,
                        p_item_id NUMBER) RETURN VARCHAR2;


END QA_SKIPLOT_RES_ENGINE;


/
