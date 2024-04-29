--------------------------------------------------------
--  DDL for Package QA_PLAN_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PLAN_ELEMENT_API" AUTHID CURRENT_USER AS
/* $Header: qltelemb.pls 120.15.12010000.5 2010/04/26 17:13:00 ntungare ship $ */


TYPE LovRecord IS RECORD (
    code VARCHAR2(150),
    description VARCHAR2(2000));


TYPE LovRefCursor IS REF CURSOR;

-- Bug 3769260. shkalyan 30 July 2004.
-- Added this procedure to fetch all the elements of a specifications
-- The reason for introducing this procedure is to reduce the number of
-- hits on the QA_SPEC_CHARS.
-- Callers will use this procedure to pre-fetch all the Spec elements
-- to the cache if all the elements of a Spec would be accessed.

PROCEDURE fetch_qa_spec_chars (spec_id IN NUMBER);

-- Bug 3769260. shkalyan 30 July 2004.
-- Added this procedure to fetch all the elements of a plan
-- The reason for introducing this procedure is to reduce the number of
-- hits on the QA_PLAN_CHARS.
-- Callers will use this procedure to pre-fetch all the Plan elements
-- to the cache if all the elements of a plan would be accessed.

PROCEDURE fetch_qa_plan_chars (plan_id IN NUMBER);

--
-- Bug 5182097.  Need a procedure to force repopulate qpc cache.
-- Some subtle changes in Setup Collection Plans are not immediately
-- reflected in QWB.  So this is provided to reread qpc on demand.
-- bso Mon May  1 17:02:33 PDT 2006
--
PROCEDURE refetch_qa_plan_chars(p_plan_id IN NUMBER);


FUNCTION keyflex (element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION normalized (element_id IN NUMBER)
    RETURN BOOLEAN;

FUNCTION derived (element_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION hardcoded (element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION primitive (element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION values_exist (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN;

--anagarwa
--Bug 2751198
--Added the function to spec so that it may be used by other packages
FUNCTION exists_qa_plan_chars(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN;

FUNCTION sql_validation_exists (element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION element_in_plan (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN;

FUNCTION element_in_spec (spec_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN;


FUNCTION get_actual_datatype (element_id IN NUMBER)
    RETURN NUMBER;


FUNCTION get_element_datatype (element_id IN NUMBER)
    RETURN NUMBER;


PROCEDURE get_spec_limits (spec_id IN NUMBER, element_id IN NUMBER,
    lower_limit OUT NOCOPY VARCHAR2, upper_limit OUT NOCOPY VARCHAR2);


-- BUG 3303285
-- ksoh Mon Dec 29 13:33:02 PST 2003
-- overloaded get_spec_limits with a version that takes in plan_id
-- it is used for retrieving qa_plan_chars.uom_code for uom conversion
PROCEDURE get_spec_limits (p_plan_id IN NUMBER, p_spec_id IN NUMBER,
    p_element_id IN NUMBER,
    lower_limit OUT NOCOPY VARCHAR2, upper_limit OUT NOCOPY VARCHAR2);


-- BUG 3303285
-- ksoh Mon Jan  5 12:55:13 PST 2004
-- it is used for retrieving low/high value for evaluation of action triggers
-- it performs UOM conversion.
PROCEDURE get_low_high_values (p_plan_id IN NUMBER, p_spec_id IN NUMBER,
    p_element_id IN NUMBER,
    p_low_value_lookup IN NUMBER,
    p_high_value_lookup IN NUMBER,
    x_low_value OUT NOCOPY VARCHAR2, x_high_value OUT NOCOPY VARCHAR2);


FUNCTION get_department_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_job_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_production_line_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_resource_code_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_supplier_id (value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_po_number_id (value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_customer_id (value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_so_number_id (value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_so_line_number_id (value IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_po_release_number_id (value IN VARCHAR2, x_po_header_id IN NUMBER)
    RETURN NUMBER;


FUNCTION get_project_number_id (value IN VARCHAR2)
    RETURN NUMBER;


--
-- Bug 2672396.  Added p_project_id because task is a dependent element.
-- Fix is required in qltvalb.plb also.
-- bso Mon Nov 25 17:29:56 PST 2002
--
FUNCTION get_task_number_id (value IN VARCHAR2, p_project_id IN NUMBER)
    RETURN NUMBER;


FUNCTION get_rma_number_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_LPN_id (value IN VARCHAR2)
    RETURN NUMBER;

-- added the following to include new hardcoded element Transfer license plate number
-- saugupta Aug 2003

FUNCTION get_XFR_LPN_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_contract_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_contract_line_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_deliverable_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_work_order_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_party_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION retrieve_id (sql_statement IN VARCHAR2)
    RETURN NUMBER;

--
-- Included the following six get_id functions for ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

FUNCTION get_item_instance_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_counter_name_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_maintenance_req_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_service_request_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_rework_job_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER;

-- R12 OPM Deviations. Bug 4345503 Start
FUNCTION get_process_batch_id (value IN VARCHAR2,p_org_id IN NUMBER)
    RETURN NUMBER;

FUNCTION get_process_batchstep_id (value IN VARCHAR2,
                                   p_process_batch_id IN NUMBER)
    RETURN NUMBER;

FUNCTION get_process_operation_id (value IN VARCHAR2,
                                   p_process_batch_id IN NUMBER,
                                   p_process_batchstep_id IN NUMBER)
    RETURN NUMBER;

FUNCTION get_process_activity_id (value IN VARCHAR2,
	                          p_process_batch_id IN NUMBER,
	                          p_process_batchstep_id IN NUMBER)
    RETURN NUMBER;

FUNCTION get_process_resource_id (value IN VARCHAR2,
	                          p_process_batch_id IN NUMBER,
	                          p_process_batchstep_id IN NUMBER,
	                          p_process_activity_id IN NUMBER)
    RETURN NUMBER;

FUNCTION get_process_parameter_id (value IN VARCHAR2,
	                           p_process_resource_id IN NUMBER)
    RETURN NUMBER;

-- R12 OPM Deviations. Bug 4345503 End

/* R12 DR Integration. Bug 4345489 Start */

FUNCTION get_repair_line_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_jtf_task_id (value IN VARCHAR2)
    RETURN NUMBER;

/* R12 DR Integration. Bug 4345489 End */

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

FUNCTION validate_maintenance_op_seq (x_org_id IN NUMBER,
                                      x_maintenance_work_order_id IN NUMBER,
                                      x_maintenance_op_seq IN VARCHAR2)
         RETURN BOOLEAN;

--
-- End of inclusions for ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


FUNCTION validate_to_subinventory (x_org_id IN NUMBER,
                                   x_to_subinventory IN VARCHAR2)
    RETURN BOOLEAN;

FUNCTION get_lot_status_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_serial_status_id (value IN VARCHAR2)
    RETURN NUMBER;

-- End of inclusions for NCM Hardcode Elements.


FUNCTION value_in_sql (sql_statement IN VARCHAR2, value IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_transaction_date(transaction_number IN NUMBER)
    RETURN BOOLEAN;


FUNCTION validate_uom(x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_uom_code IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_revision (x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_revision IN VARCHAR2)
    RETURN BOOLEAN;

FUNCTION validate_lot_num(x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_lot_num IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_serial_num(x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_lot_num IN VARCHAR2, x_revision IN VARCHAR2, x_serial_num IN VARCHAR2)
    RETURN BOOLEAN;

FUNCTION validate_subinventory (x_org_id IN NUMBER, x_subinventory IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_lot_number (x_transaction_number IN NUMBER, x_transaction_id
    IN NUMBER, x_lot_number IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_serial_number (x_transaction_number IN NUMBER,
    x_transaction_id IN NUMBER, x_lot_number IN VARCHAR2, x_serial_number IN
    VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_op_seq_number (x_org_id IN NUMBER, x_line_id IN NUMBER,
    x_wip_entity_id IN NUMBER, x_op_seq_number IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_po_line_number (x_po_header_id IN NUMBER, x_po_line_number
    IN VARCHAR2)
    RETURN BOOLEAN;

--
-- bug 9652549 CLM changes
--
FUNCTION validate_po_shipments (x_po_line_num IN VARCHAR2, x_po_header_id IN
    NUMBER, x_po_shipments IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION validate_receipt_number (x_receipt_number IN VARCHAR2)
    RETURN BOOLEAN;


FUNCTION get_target_element (plan_char_action_id IN NUMBER)
    RETURN NUMBER;


FUNCTION get_enabled_flag (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN NUMBER;

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level.
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--
-- New function to get the decimal precision for the element
-- from the QA_PLAN_CHARS table.
--

FUNCTION decimal_precision (p_plan_id IN NUMBER, p_element_id IN NUMBER)
    RETURN NUMBER;

FUNCTION get_mandatory_flag (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN NUMBER;

FUNCTION get_sql_validation_string (element_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION qsc_lower_reasonable_limit(spec_id IN NUMBER,
        element_id IN NUMBER) RETURN VARCHAR2;

FUNCTION qsc_upper_reasonable_limit(spec_id IN NUMBER,
        element_id IN NUMBER) RETURN VARCHAR2;

FUNCTION qpc_enabled_flag(plan_id IN NUMBER,
        element_id IN NUMBER) RETURN NUMBER;

FUNCTION qpc_mandatory_flag(plan_id IN NUMBER,
        element_id IN NUMBER) RETURN NUMBER;

FUNCTION qpc_values_exist_flag(plan_id IN NUMBER,
        element_id IN NUMBER) RETURN NUMBER;

-- Added the below function in specs for Bug 3754667. kabalakr.
FUNCTION qpc_result_column_name (plan_id IN NUMBER,
    element_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prompt(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION get_uom_code(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION get_decimal_precision(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION get_result_column_name (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN VARCHAR2;

-- New get functions added for the new columns in qa_plan_chars
-- SSQR project

FUNCTION qpc_displayed_flag(plan_id IN NUMBER,
        element_id IN NUMBER) RETURN NUMBER;

FUNCTION qpc_poplist_flag(plan_id IN NUMBER,
        element_id IN NUMBER) RETURN NUMBER;

FUNCTION qpc_read_only_flag(plan_id IN NUMBER,
        element_id IN NUMBER) RETURN NUMBER;


PROCEDURE get_department_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_job_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_production_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_resource_code_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_supplier_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_po_number_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_customer_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_so_number_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


 -- Bug 7716875.Added parameter x_so_number.pdube
 -- PROCEDURE get_so_line_number_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);
 PROCEDURE get_so_line_number_lov (x_so_number IN VARCHAR2,value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

-- Bug 4958763.  SQL Repository Fix
-- Modified procedure signature to honour po_header_id
-- saugupta Wed, 08 Feb 2006 23:30:37 -0800 PDT
PROCEDURE get_po_release_number_lov (p_po_header_id IN NUMBER, value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);


PROCEDURE get_project_number_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);

PROCEDURE get_LPN_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);

-- added the following to include new hardcoded element Transfer license plate number
-- saugupta Aug 2003

PROCEDURE get_XFR_LPN_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);

PROCEDURE get_contract_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);

PROCEDURE get_contract_line_lov (value IN VARCHAR2, contract_number IN VARCHAR2,
				 x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_deliverable_lov (value IN VARCHAR2, contract_number IN VARCHAR2,
			       line_number IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

--dgupta: Start R12 EAM Integration. Bug 4345492
PROCEDURE get_asset_instance_number_lov (p_org_id IN NUMBER, p_asset_group IN VARCHAR2,
p_asset_number IN VARCHAR2, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

FUNCTION get_asset_instance_id (value IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_asset_instance_id (p_asset_group_id IN NUMBER, p_asset_number IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_asset_group_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER;

PROCEDURE get_asset_number_lov ( x_org_id IN NUMBER, x_asset_group IN VARCHAR2,
              x_asset_instance_number IN VARCHAR2,
              value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);
--dgupta: End R12 EAM Integration. Bug 4345492


PROCEDURE get_work_order_lov (org_id IN NUMBER, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_task_number_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);


PROCEDURE get_rma_number_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);
--
-- Bug 6161802
-- Added procedure to return lov sql for rma line number
-- with rma number as a bind variable
-- skolluku Tue Jul 17 02:49:13 PDT 2007
--
PROCEDURE get_rma_line_num_lov (x_rma_number IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_uom_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_revision_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_subinventory_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_lot_num_lov(x_org_id IN NUMBER, x_item_name IN VARCHAR2, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_serial_num_lov(x_org_id IN NUMBER, x_item_name IN VARCHAR2, x_lot_number IN VARCHAR2, x_revision IN VARCHAR2, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_lot_number_lov (x_transaction_id IN NUMBER, value IN
VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_serial_number_lov (x_transaction_id IN NUMBER, x_lot_number
    IN VARCHAR2, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_op_seq_number_lov(org_id IN NUMBER, value IN VARCHAR2,
    job_name IN VARCHAR2, production_line IN VARCHAR2 DEFAULT NULL,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_po_line_number_lov(p_po_header_id IN NUMBER, value IN
    VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

--
-- bug 9652549 CLM changes
--
PROCEDURE get_po_shipments_lov(po_line_num IN VARCHAR2, p_po_header_id IN NUMBER,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_item_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);


-- Bug 5292020 adding comp item LOV to mqa.
-- bso Thu Jun  8 00:45:32 PDT 2006
PROCEDURE get_comp_item_lov(
    p_org_id IN NUMBER,
    p_item_name IN VARCHAR2,
    p_job_name IN VARCHAR2,
    p_prod_line IN VARCHAR2,
    p_value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_asset_group_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_asset_activity_lov (x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
    p_asset_number IN VARCHAR2,
    p_asset_instance_number IN VARCHAR2, -- R12 EAM Integration. Bug 4345492
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

-- added the following to include new hardcoded element followup activity
-- saugupta Aug 2003

PROCEDURE get_followup_activity_lov (x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
    p_asset_number IN VARCHAR2,
    p_asset_instance_number IN VARCHAR2, -- R12 EAM Integration. Bug 4345492
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_locator_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_receipt_num_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_party_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

--
-- Included the following five get_lov procedures for ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

PROCEDURE get_item_instance_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

--
-- Bug 9032151
-- Overloading above procedure with the new one which takes
-- care of the dependency of item instance on item.
-- skolluku
--
PROCEDURE get_item_instance_lov (p_org_id IN NUMBER, p_item_name IN VARCHAR2,
                                 value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

--
-- Bug 9359442
-- New procedure which returns lov for item instance serial based on item.
-- skolluku
--
PROCEDURE get_item_instance_serial_lov (p_org_id IN NUMBER, p_item_name IN VARCHAR2,
                                        value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_counter_name_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_maintenance_req_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_service_request_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_rework_job_lov (org_id IN NUMBER, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

PROCEDURE get_maintenance_op_seq_lov(org_id IN NUMBER,
                                     value IN VARCHAR2,
				     maintenance_work_order IN VARCHAR2,
				     x_ref OUT NOCOPY LovRefCursor);
--
-- End of inclusions for ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

PROCEDURE get_bill_reference_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_routing_reference_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_to_locator_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_to_subinventory_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_lot_status_lov (x_org_id IN NUMBER, x_lot_num IN VARCHAR2,
    x_item_name IN VARCHAR2, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_serial_status_lov(x_org_id IN NUMBER, x_serial_num IN VARCHAR2,
    x_item_name IN VARCHAR2, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor);

-- End of inclusions for NCM Hardcode Elements.

-- R12 OPM Deviations. Bug 4345503 Start
PROCEDURE get_process_batch_num_lov (p_org_id IN NUMBER,
                                     value IN VARCHAR2,
                                     x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_process_batchstep_num_lov (p_org_id IN NUMBER,
                                         p_process_batch_num IN VARCHAR2,
                                         value IN VARCHAR2,
                                         x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_process_operation_lov (p_org_id IN NUMBER,
                                     p_process_batch_num IN VARCHAR2,
                                     p_process_batchstep_num IN NUMBER,
                                     value IN VARCHAR2,
                                     x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_process_activity_lov (p_org_id IN NUMBER,
                                    p_process_batch_num IN VARCHAR2,
                                    p_process_batchstep_num IN NUMBER,
                                    value IN VARCHAR2,
                                    x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_process_resource_lov (p_org_id IN NUMBER,
	                            p_process_batch_num IN VARCHAR2,
	                            p_process_batchstep_num IN NUMBER,
	                            p_process_activity IN VARCHAR2,
	                            value IN VARCHAR2,
	                            x_ref OUT NOCOPY LovRefCursor);

PROCEDURE get_process_parameter_lov (p_org_id IN NUMBER,
	                             p_process_resource IN VARCHAR2,
	                             value IN VARCHAR2,
	                             x_ref OUT NOCOPY LovRefCursor);
-- R12 OPM Deviations. Bug 4345503 End

/* R12 DR Integration. Bug 4345489 Start */

PROCEDURE get_repair_number_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);

PROCEDURE get_jtf_task_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor);

/* R12 DR Integration. Bug 4345489 End */

PROCEDURE get_plan_element_lov(plan_id IN NUMBER, char_id IN NUMBER,
    org_id IN NUMBER, user_id IN NUMBER DEFAULT NULL,
    value IN VARCHAR2 DEFAULT NULL,
    x_ref OUT NOCOPY LovRefCursor);


PROCEDURE get_spec_details ( x_spec_id IN NUMBER, x_char_id IN NUMBER,
    x_target_value              OUT NOCOPY VARCHAR2,
    x_lower_spec_limit          OUT NOCOPY VARCHAR2,
    x_upper_spec_limit          OUT NOCOPY VARCHAR2,
    x_lower_user_defined_limit  OUT NOCOPY VARCHAR2,
    x_upper_user_defined_limit  OUT NOCOPY VARCHAR2,
    x_lower_reasonable_limit    OUT NOCOPY VARCHAR2,
    x_upper_reasonable_limit    OUT NOCOPY VARCHAR2);


PROCEDURE get_spec_sub_type (x_spec_id IN NUMBER,
    x_element_name OUT NOCOPY VARCHAR2);


PROCEDURE get_spec_type (p_spec_id IN NUMBER,
    x_spec_type OUT NOCOPY VARCHAR2);


PROCEDURE get_item_name (p_spec_id IN NUMBER,
    x_item_name OUT NOCOPY VARCHAR2);


PROCEDURE get_supplier_name (p_spec_id IN NUMBER,
    x_supplier_name OUT NOCOPY VARCHAR2);


PROCEDURE get_customer_name (p_spec_id IN NUMBER,
    x_customer_name OUT NOCOPY VARCHAR2);


FUNCTION context_element (element_id IN NUMBER, txn_number IN NUMBER)
    RETURN BOOLEAN;

 -- Bug 4519558. OA Framework integration project. UT bug fix.
 -- Transaction type element was erroring out for WIP transactions.
 -- New function to validate "Transaction Type".
 -- srhariha.Tue Aug  2 00:43:07 PDT 2005.
 FUNCTION validate_transaction_type(p_transaction_number IN NUMBER,
                                    p_org_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_value IN VARCHAR2)
                                          RETURN BOOLEAN ;

-- Bug 5186397
-- New function to perform the UOM
-- conversion for the source val passed
-- from the source UOM to the Target UOM
-- SHKALYAN 01-May-2006
--
FUNCTION perform_uom_conversion (p_source_val IN VARCHAR2,
                                 p_precision  IN NUMBER ,
                                 p_source_UOM IN VARCHAR2,
                                 p_target_UOM IN VARCHAR2)
    RETURN NUMBER;


--
-- Bug 5383667
-- New function to get the
-- Id Values from QA_results table
-- ntungare Thu Aug 24 02:01:29 PDT 2006
--
Function get_id_val(p_child_char_id IN NUMBER,
                    p_plan_id       IN NUMBER,
                    p_collection_id IN NUMBER,
                    p_occurrence    IN NUMBER)
    RETURN VARCHAR2;

-- bug 6263809
-- New function to get the quantity received for
-- a particular shipment in a receipt.
-- This is needed for LPN Inspections wherein
-- if there is a shipment number collection element
-- then the quantity validation should happen
-- based on it.
-- bhsankar Fri Oct 12 03:06:24 PDT 2007
--
PROCEDURE get_qty_for_shipment(
                p_po_num IN VARCHAR2,
                p_line_num IN VARCHAR2,
                p_ship_num IN NUMBER,
                x_qty OUT NOCOPY NUMBER);

--
-- 12.1 QWB Usabitlity Improvements
-- Function to build the Info column value
--
FUNCTION build_info_column(p_plan_id        IN NUMBER,
                           p_collection_id  IN NUMBER,
                           p_occurrence     IN NUMBER)
      RETURN VARCHAR2;

-- 12.1 QWB Usability Improvemenets
-- New procedure to process dependent elements
PROCEDURE process_dependent_elements(result_string IN VARCHAR2,
                                     id_string     IN VARCHAR2,
                                     org_id        IN NUMBER,
                                     p_plan_id     IN NUMBER,
                                     char_Id       IN VARCHAR2,
                                     dependent_elements OUT NOCOPY VARCHAR2,
                                     disable_enable_flag_list OUT NOCOPY VARCHAR2);

END qa_plan_element_api;

/
