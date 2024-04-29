--------------------------------------------------------
--  DDL for Package QA_INSPECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_INSPECTION_PKG" AUTHID CURRENT_USER AS
/* $Header: qainsps.pls 120.0.12000000.1 2007/01/19 07:09:00 appldev ship $ */

    --
    -- This procedure initialize temp table
    -- qa_insp_collections_temp and qa_insp_plans_temp
    -- for the given collection id and plan id
    -- These temp tables are used for both skip lot and
    -- sampling project
    --
    PROCEDURE INIT_COLLECTION (
    p_collection_id IN NUMBER,
    p_lot_size IN NUMBER,
    p_coll_plan_id IN NUMBER,
    p_uom_name IN VARCHAR2);


    --
    -- This procedure dispatch action launching
    -- logic based on sampling and skiplot flag
    -- It does nothing for regular inspection
    --
    PROCEDURE LAUNCH_SHIPMENT_ACTION(
    p_po_processor_mode IN VARCHAR2,
    p_group_id IN NUMBER,
    p_employee_id IN NUMBER);

    --
    -- This function returns fnd_api.g_false
    -- if the collection is under either skiplot
    -- or sampling control, fnd_api.g_true otherwise
    --
    FUNCTION IS_REGULAR_INSP (
    p_collection_id IN NUMBER) RETURN VARCHAR2;

    --
    -- This function returns fnd_api.g_true
    -- if the collection is under sampling control
    -- fnd_api.g_false otherwise
    --
    FUNCTION IS_SAMPLING_INSP(
    p_collection_id IN NUMBER) RETURN VARCHAR2;

    --
    -- This function returns fnd_api.g_true
    -- if the collection is under skip lot control
    -- fnd_api.g_false otherwise
    --
    FUNCTION IS_SKIPLOT_INSP(
    p_collection_id IN NUMBER) RETURN VARCHAR2;

    --
    -- The function returns whether QA is installed
    --
    FUNCTION QA_INSTALLATION RETURN VARCHAR2;

    --
    -- The function returns whether QA_PO_INSPECTION profile
    -- is set to Quality
    --
    FUNCTION QA_INSPECTION RETURN VARCHAR2;


END QA_INSPECTION_PKG;


 

/
