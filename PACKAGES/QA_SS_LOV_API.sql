--------------------------------------------------------
--  DDL for Package QA_SS_LOV_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_LOV_API" AUTHID CURRENT_USER AS
/* $Header: qltsslob.pls 120.5.12010000.8 2010/04/26 17:14:55 ntungare ship $ */


TYPE LovRecord IS RECORD (
    code VARCHAR2(150),
    description VARCHAR2(2000));

TYPE LovRefCursor IS REF CURSOR;

FUNCTION values_exist (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION sql_validation_exists (element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION element_in_plan (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION get_sql_validation_string (element_id IN NUMBER)
    RETURN VARCHAR2;


PROCEDURE get_department_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_job_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_work_order_lov (org_id IN NUMBER, value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_production_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_resource_code_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_supplier_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_po_number_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_customer_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_so_number_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


-- Bug 7716875.Changed the definition of the procedure
-- to introduce additional parameters.pdube Mon Apr 13 03:25:19 PDT 2009
-- PROCEDURE get_so_line_number_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);
PROCEDURE get_so_line_number_lov (p_plan_id IN NUMBER,
                                  p_so_number IN VARCHAR2,
                                  value IN VARCHAR2,
                                  x_lov_sql OUT NOCOPY VARCHAR2);

-- Bug 5003511 SQLID : 15008630
-- Release number is dependent on PO Number.
-- As per safe spec, creating procedure for getting the lov sql.
-- and commneting out unused overridden procedure below
-- saugupta Tue, 14 Feb 2006 07:07:11 -0800 PDT
/*
PROCEDURE get_po_release_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2);
*/
PROCEDURE get_po_release_number_lov (p_plan_id IN NUMBER,
                                     po_header_id IN VARCHAR2,
                                     value IN VARCHAR2,
                                     x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_project_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2);


PROCEDURE get_task_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2);


PROCEDURE get_rma_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2);


PROCEDURE get_uom_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_revision_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_subinventory_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_lot_number_lov (x_transaction_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_serial_number_lov (x_transaction_id IN NUMBER, x_lot_number
    IN VARCHAR2, value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

--dgupta: Start R12 EAM Integration. Bug 4345492
PROCEDURE get_asset_instance_number_lov (plan_id IN NUMBER, x_org_id IN NUMBER, x_asset_group IN VARCHAR2,x_asset_number IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);
--dgupta: End R12 EAM Integration. Bug 4345492

PROCEDURE get_asset_number_lov ( x_org_id IN NUMBER, x_asset_group IN VARCHAR2, value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_op_seq_number_lov(org_id IN NUMBER, value IN VARCHAR2,
    job_name IN VARCHAR2, production_line IN VARCHAR2 DEFAULT NULL,
    x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_po_line_number_lov (po_number IN VARCHAR2, value IN
    VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

--
-- bug 9652549 CLM changes
--
PROCEDURE get_po_shipments_lov (po_line_num IN VARCHAR2, po_number IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

--
-- Bug 7197055
-- Added new parameter, production line, to base the item's lov on prod line,
-- whenever a value for prod line is present.
-- skolluku
--
PROCEDURE get_item_lov (org_id IN NUMBER, value IN VARCHAR2, p_production_line IN
    VARCHAR2 DEFAULT NULL, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_asset_group_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_locator_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_receipt_num_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);


PROCEDURE get_party_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

--
-- Included the following get_lov procedures for ASO project
-- rkunchal Thu Aug  1 12:04:56 PDT 2002
--

PROCEDURE get_item_instance_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_counter_name_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_maintenance_req_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_service_request_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_rework_job_lov (org_id IN NUMBER, value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_disposition_source_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_disposition_action_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_disposition_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_disposition_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

/* R12 DR Integration. Bug 4345489 Start */
PROCEDURE get_repair_order_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_jtf_task_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);
/* R12 DR Integration. Bug 4345489 End */

-- R12 OPM Deviations. Bug 4345503 Start

PROCEDURE get_process_batch_num_lov
(org_id                      IN            NUMBER,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2);

PROCEDURE get_process_batchstep_num_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2);

PROCEDURE get_process_operation_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 process_batchstep_num       IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2);

PROCEDURE get_process_activity_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 process_batchstep_num       IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2);

PROCEDURE get_process_resource_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 process_batchstep_num       IN            VARCHAR2,
 process_activity            IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2);

PROCEDURE get_process_parameter_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_resource            IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2);

-- R12 OPM Deviations. Bug 4345503 End
--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

PROCEDURE get_maintenance_op_seq_lov(org_id IN NUMBER,
                                     value IN VARCHAR2,
                                     maintenance_work_order IN VARCHAR2,
                                     x_lov_sql OUT NOCOPY VARCHAR2);

--
-- End of inclusions for ASO project
-- rkunchal Thu Aug  1 12:04:56 PDT 2002
--

PROCEDURE get_plan_element_lov(plan_id IN NUMBER, char_id IN NUMBER,
    org_id IN NUMBER, user_id IN NUMBER DEFAULT NULL,
    x_lov_sql OUT NOCOPY VARCHAR2);

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


PROCEDURE get_bill_reference_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_routing_reference_lov (org_id IN NUMBER, value IN VARCHAR2,
        x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_to_locator_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_to_subinventory_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_lot_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

-- Bug 7588754.pdube Wed Apr 15 07:37:25 PDT 2009
-- PROCEDURE get_serial_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);
PROCEDURE get_serial_status_lov(value IN VARCHAR2,item_name IN VARCHAR2,
    serial_num IN VARCHAR2,x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_nonconformance_source_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_nonconform_severity_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_nonconform_priority_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_nonconformance_type_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_nonconformance_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

-- End of inclusions for NCM Hardcode Elements.

--anagarwa Fri Nov 15 13:03:35 PST 2002
--Following added for new CAR lov's

PROCEDURE get_request_source_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_request_priority_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_request_severity_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_request_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2);

-- End of inclusions for CAR Hardcode Elements.

/*
FUNCTION get_lov_sql (
    plan_id IN NUMBER,
    char_id IN NUMBER,
    org_id IN NUMBER DEFAULT NULL,
    user_id IN NUMBER DEFAULT NULL,
    item_name IN VARCHAR2 DEFAULT NULL,
    job_name IN VARCHAR2 DEFAULT NULL,
    lot_number IN VARCHAR2 DEFAULT NULL,
    po_line_number IN NUMBER DEFAULT NULL,
    po_number IN VARCHAR2 DEFAULT NULL,
    production_line IN VARCHAR2 DEFAULT NULL,
    transaction_id IN NUMBER DEFAULT NULL,
    value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
*/

FUNCTION get_lov_sql (
    plan_id IN NUMBER,
    char_id IN NUMBER,
    org_id IN NUMBER DEFAULT NULL,
    user_id IN NUMBER DEFAULT NULL,
    depen1 IN VARCHAR2 DEFAULT NULL,
    depen2 IN VARCHAR2 DEFAULT NULL,
    depen3 IN VARCHAR2 DEFAULT NULL,
    value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- Bug 4270911. SQL bind compliance fix.
-- Please see bugdb for more details and TD link.
-- srhariha. Thu Apr  7 21:43:08 PDT 2005.

FUNCTION get_lov_bind_values (
    plan_id IN NUMBER,
    char_id IN NUMBER,
    org_id IN NUMBER DEFAULT NULL,
    user_id IN NUMBER DEFAULT NULL,
    depen1 IN VARCHAR2 DEFAULT NULL,
    depen2 IN VARCHAR2 DEFAULT NULL,
    depen3 IN VARCHAR2 DEFAULT NULL,
    value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;



END qa_ss_lov_api;

/
