--------------------------------------------------------
--  DDL for Package QA_SKIPLOT_EVAL_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SKIPLOT_EVAL_ENGINE" AUTHID CURRENT_USER AS
/* $Header: qaslevas.pls 120.1 2006/03/31 05:19:51 saugupta noship $ */

    --
    -- This package defines skip lot evaluation engine
    -- logic.
    --

    --
    -- The function returns criteria id
    -- it also resolve the criteria conflicts
    -- so that only one criteria id is returned
    -- if multiple groups of criteria are setup
    --

    FUNCTION GET_RCV_CRITERIA_ID
    (p_organization_id IN NUMBER,
    p_vendor_id IN NUMBER,
    p_vendor_site_id IN NUMBER,
    p_item_id IN NUMBER,
    p_item_revision IN VARCHAR2,
    p_item_category_id IN NUMBER,
    p_project_id IN NUMBER,
    p_task_id IN NUMBER,
    p_manufacturer_id IN NUMBER)
    RETURN NUMBER;


    --
    -- The procedure evaluates receiving inspection
    -- criteria and process and creates avaliable plan
    -- list if inspection is required.
    --

    PROCEDURE EVALUATE_RCV_CRITERIA (
    p_organization_id IN NUMBER,
    p_vendor_id IN NUMBER,
    p_vendor_site_id IN NUMBER,
    p_item_id IN NUMBER,
    p_item_revision IN VARCHAR2,
    p_item_category_id IN NUMBER,
    p_project_id IN NUMBER,
    p_task_id IN NUMBER,
    p_manufacturer_id IN NUMBER,
    p_lot_qty IN NUMBER,
    p_primary_uom IN varchar2,
    p_transaction_uom IN varchar2,
    p_availablePlans OUT NOCOPY qa_skiplot_utility.planList,
    p_criteria_id OUT NOCOPY NUMBER,
    p_process_id OUT NOCOPY NUMBER);


    --
    -- The procedure evaluate skip lot rules
    -- and generate applicable plan list if
    -- applicable.
    --

    PROCEDURE EVALUATE_RULES (
    p_availablePlans IN qa_skiplot_utility.planList,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_txn IN NUMBER,
    p_lot_id OUT NOCOPY NUMBER,
    p_applicablePlans OUT NOCOPY qa_skiplot_utility.planList);


    --
    -- The procedure inserts the inspection
    -- lot into skip lot result table and
    -- set inspection statuses.
    --
    PROCEDURE INSERT_RCV_RESULTS (
    p_interface_txn_id IN NUMBER,
    p_manufacturer_id IN NUMBER,
    p_receipt_qty IN NUMBER,
    p_criteriaID IN NUMBER,
    p_insp_status IN VARCHAR2,
    p_receipt_date IN DATE,
    p_lotID IN NUMBER DEFAULT NULL,
    p_source_inspected IN NUMBER,
    p_process_id IN NUMBER,
    p_lpn_id IN NUMBER);

    --
    -- The procedure stores the lot/plan pairs
    -- for inspection time usage.
    --

    PROCEDURE STORE_LOT_PLANS(
    p_applicablePlans IN qa_skiplot_utility.planList,
    p_lotid IN NUMBER,
    p_insp_status IN VARCHAR2);

END QA_SKIPLOT_EVAL_ENGINE;


/
