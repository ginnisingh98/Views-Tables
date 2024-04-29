--------------------------------------------------------
--  DDL for Package Body QA_JRAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_JRAD_PKG" AS
/* $Header: qajradb.pls 120.9.12010000.8 2010/02/19 11:34:46 skolluku ship $ */


TYPE ParentArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_sysdate DATE;

-- Bug 3769260. shkalyan 29 July 2004.
-- Since this cursor was used by many functions, declared it as global
-- so that, parse time could be reduced.
-- Modified the following functions to use this cursor
-- FUNCTION osp_self_service_plan
-- FUNCTION shipment_self_service_plan
-- FUNCTION eam_work_order_plan
-- FUNCTION eam_asset_plan
-- FUNCTION eam_op_comp_plan

CURSOR qptxn(c_plan_id NUMBER, c_txn_no NUMBER) IS
    SELECT 1
    FROM qa_plan_transactions
    WHERE plan_id = c_plan_id
    AND transaction_number = c_txn_no
    AND enabled_flag = 1;



FUNCTION osp_self_service_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for osp self service transactions or not.
    -- If it is then it returns true else it returns false.

    OPEN qptxn(p_plan_id,qa_ss_const.ss_outside_processing_txn);
    FETCH qptxn INTO dummy;
    result := qptxn%FOUND;
    CLOSE qptxn;
    RETURN result;

END osp_self_service_plan;


FUNCTION shipment_self_service_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for shipment self service transactions or not.
    -- If it is then it returns true else it returns false.

    OPEN qptxn(p_plan_id,qa_ss_const.ss_shipments_txn);
    FETCH qptxn INTO dummy;
    result := qptxn%FOUND;
    CLOSE qptxn;
    RETURN result;

END shipment_self_service_plan;


FUNCTION customer_portal_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    -- This subroutine determines if a plan should be mapped
    -- for customer portal (OM).  This can be determined
    -- by checking if sales order is a part of the plan
    -- and enabled.

    IF (qa_plan_element_api.element_in_plan(p_plan_id,
        qa_ss_const.sales_order)) THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

END customer_portal_plan;


FUNCTION eam_work_order_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for EAM work order or not. If it is then it returns true
    -- else it returns false.

    OPEN qptxn(p_plan_id,qa_ss_const.eam_work_order_txn);
    FETCH qptxn INTO dummy;
    result := qptxn%FOUND;
    CLOSE qptxn;

    RETURN result;

END eam_work_order_plan;


FUNCTION eam_asset_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for EAM asset query or not. If it is then it returns true
    -- else it returns false.

    OPEN qptxn(p_plan_id,qa_ss_const.eam_asset_txn);
    FETCH qptxn INTO dummy;
    result := qptxn%FOUND;
    CLOSE qptxn;

    RETURN result;

END eam_asset_plan;



FUNCTION eam_op_comp_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for EAM op comp or not. If it is then it returns true
    -- else it returns false.

    OPEN qptxn(p_plan_id,qa_ss_const.eam_operation_txn);
    FETCH qptxn INTO dummy;
    result := qptxn%FOUND;
    CLOSE qptxn;

    RETURN result;

END eam_op_comp_plan;

--dgupta: Start R12 EAM Integration. Bug 4345492
FUNCTION eam_checkin_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

BEGIN
    OPEN qptxn(p_plan_id,qa_ss_const.eam_checkin_txn);
    FETCH qptxn INTO dummy;
    result := qptxn%FOUND;
    CLOSE qptxn;

    RETURN result;
END eam_checkin_plan;

FUNCTION eam_checkout_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

BEGIN
    OPEN qptxn(p_plan_id,qa_ss_const.eam_checkout_txn);
    FETCH qptxn INTO dummy;
    result := qptxn%FOUND;
    CLOSE qptxn;

    RETURN result;
END eam_checkout_plan;
--dgupta: End R12 EAM Integration. Bug 4345492

-- Parent-Child
FUNCTION parent_child_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM qa_pc_plan_relationship
        WHERE parent_plan_id = p_plan_id
        OR child_plan_id = p_plan_id;

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan should be mapped
    -- for parent child VQR.  This can be determined
    -- by checking if plan is a parent or child
    --
    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;


END parent_child_plan;


FUNCTION construct_jrad_code (p_prefix  IN VARCHAR2, p_id IN VARCHAR2,
                                p_jrad_doc_ver IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS

BEGIN

   -- The function is the standard way to compute attribute and
   -- region codes.
   if (p_jrad_doc_ver IS NULL) then
           RETURN (p_prefix ||p_id);
   else
           RETURN (p_prefix ||p_id || '_V' || p_jrad_doc_ver);
   end if;

END construct_jrad_code;


FUNCTION retrieve_id (p_code IN VARCHAR2)
    RETURN NUMBER IS

    pos NUMBER;
    id  VARCHAR2(100);

BEGIN

   -- The function is the standard way to retrive id given the code

   IF (INSTR(p_code, g_element_prefix) <> 0) THEN
       pos := length(g_element_prefix)+1;

   ELSIF (INSTR(p_code, g_osp_vqr_prefix) <> 0) THEN
       pos := length(g_osp_vqr_prefix)+1;
   ELSE
       pos := length(g_txn_osp_prefix)+1;
   END IF;

   id := substr(p_code, pos, length(p_code));

   RETURN to_number(id);

END retrieve_id;

-- Bug 3769260. shkalyan 29 July 2004.
-- Removed the get_label function which was getting prompt from
-- qa_plan_chars. Using the qa_plan_element_api function to utilize cache

/*
FUNCTION get_label (p_plan_id IN NUMBER, p_element_id IN NUMBER)
    RETURN VARCHAR2 IS

    CURSOR c IS
        SELECT prompt
        FROM qa_plan_chars
        WHERE plan_id = p_plan_id
        AND char_id = p_element_id;

    label qa_plan_chars.prompt%TYPE;

BEGIN

   -- This functions retrieves the plan char prompt.  This is used
   -- to populate the label field in the AK tables.

    OPEN c;
    FETCH c INTO label;
    CLOSE c;

    RETURN label;

END get_label;
*/

FUNCTION get_special_label (p_prefix IN VARCHAR2)
    RETURN VARCHAR2 IS

    label VARCHAR2(30);

BEGIN

    -- For some hardocded columns such as "Created By", "Colleciton"
    -- and "Last Update Date" we need to retrieve the right label
    -- keeping translation in mind.

    IF (p_prefix = g_qa_created_by_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_CREATED_BY');
    ELSIF (p_prefix = g_collection_id_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_COLLECTION');
    ELSIF (p_prefix = g_last_update_date_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_ENTRY_DATE');
    ELSE
        label := '';
    END IF;

    RETURN label;

END get_special_label;


FUNCTION get_vo_attribute_name (p_char_id IN NUMBER, p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    column_name  VARCHAR2(100);

BEGIN

    -- This function computes the vo attribute name for
    -- soft coded elements.  Also, it replaces CHARACTER
    -- Character.

    column_name := qa_core_pkg.get_result_column_name (p_char_id, p_plan_id);
    column_name := replace(column_name, 'CHARACTER', 'Character');

    --
    -- bug 7714109
    -- Added support for the Comments type collection elements
    -- in EAM integration. Since the VO attribute is in INITCAPS
    -- hence converting the Comments element column name here
    -- skolluku
    --
    column_name := replace(column_name, 'COMMENT', 'Comment');

    RETURN column_name;

END get_vo_attribute_name;


FUNCTION get_hardcoded_vo_attr_name (p_code IN VARCHAR2)
    RETURN VARCHAR2 IS

    column_name  VARCHAR2(100);

BEGIN

   -- This function retrieves the result column name for
   -- hard coded elements.

   IF (INSTR(p_code, g_org_id_attribute) <> 0) THEN
       column_name := 'ORGANIZATION_ID';
   ELSIF (INSTR(p_code, g_org_code_attribute) <> 0) THEN
       column_name := 'ORGANIZATION_CODE';
   ELSIF (INSTR(p_code, g_plan_id_attribute) <> 0) THEN
       column_name := 'PLAN_ID';
   ELSIF (INSTR(p_code, g_plan_name_attribute) <> 0) THEN
       column_name := 'PLAN_NAME';
   ELSIF (INSTR(p_code, g_process_status_attribute) <> 0) THEN
       column_name := 'PROCESS_STATUS';
   ELSIF (INSTR(p_code, g_source_code_attribute) <> 0) THEN
       column_name := 'SOURCE_CODE';
   ELSIF (INSTR(p_code, g_source_line_id_attribute) <> 0) THEN
       column_name := 'SOURCE_LINE_ID';
   ELSIF (INSTR(p_code, g_po_agent_id_attribute) <> 0) THEN
       column_name := 'PO_AGENT_ID';
   ELSIF (INSTR(p_code, g_qa_created_by_attribute) <> 0) THEN
       column_name := 'QA_CREATED_BY_NAME';
   ELSIF (INSTR(p_code, g_collection_id_attribute) <> 0) THEN
       column_name := 'COLLECTION_ID';
   ELSIF (INSTR(p_code, g_last_update_date_attribute) <> 0) THEN
       column_name := 'LAST_UPDATE_DATE';
   END IF;

   RETURN column_name;

END get_hardcoded_vo_attr_name;


FUNCTION convert_data_type (p_data_type IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    -- In Quality the data type is indicated by a number. whereas,
    -- in ak it a is string that describes what the data type is.
    -- This routine was written to convert the data_type according
    -- to AK.

    IF p_data_type in (1,4,5) THEN
        return 'VARCHAR2';
    ELSIF p_data_type = 2 THEN
        return 'NUMBER';
    ELSIF p_data_type = 3 THEN
        return 'DATE';
    -- bug 3178307. rkaza. 10/06/2003. Timezone support.
    ELSIF p_data_type = 6 THEN
        return 'DATETIME';
    ELSE --catch all
        return 'VARCHAR2';
    END IF;

END convert_data_type;


FUNCTION convert_yesno_flag (p_flag IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    -- In Quality all the flags are numeric, meaning a value of 1 or 2
    -- is used to indicate if the flag is on or off.  In AK however,
    -- it is a character that describes if the flag is on or off.
    -- This routine was written to convert the Quality flags to AK.

    IF p_flag = 1 THEN
        return 'yes';
    ELSIF p_flag = 2 THEN
        return 'no';
    END IF;

END convert_yesno_flag;


FUNCTION convert_boolean_flag (p_flag IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    -- In Quality all the flags are numeric, meaning a value of 1 or 2
    -- is used to indicate if the flag is on or off.  In AK however,
    -- it is a character that describes if the flag is on or off.
    -- This routine was written to convert the Quality flags to AK.

    -- rkaza. bug 3329507. Added null value to be interpreted as not read only.
    IF p_flag IS NULL THEN
        return 'false';
    ELSIF p_flag = 1 THEN
        return 'true';
    ELSIF p_flag = 2 THEN
        return 'false';
    END IF;

END convert_boolean_flag;

FUNCTION compute_item_style (p_prefix IN VARCHAR2, p_element_id IN NUMBER,
                                p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    l_txn_number NUMBER;

BEGIN

    -- For Quality's self service application we need to know what
    -- item style to render the UI.  If the element is a context
    -- element then the item style must be HIDDEN, but for the rest
    -- of them it should be text input.  This distiction is made here.


    IF (p_prefix = g_txn_osp_prefix) THEN
        l_txn_number := qa_ss_const.ss_outside_processing_txn;

    ELSIF (p_prefix = g_txn_ship_prefix) THEN
        l_txn_number := qa_ss_const.ss_shipments_txn;

    ELSIF (p_prefix = g_txn_work_prefix) THEN
        l_txn_number := qa_ss_const.eam_work_order_txn;

    ELSIF (p_prefix = g_txn_asset_prefix) THEN
        l_txn_number := qa_ss_const.eam_asset_txn;

    ELSIF (p_prefix = g_txn_op_prefix) THEN
        l_txn_number := qa_ss_const.eam_operation_txn;

--dgupta: Start R12 EAM Integration. Bug 4345492
    ELSIF (p_prefix = g_checkin_eqr_prefix) THEN
        l_txn_number := qa_ss_const.eam_checkin_txn;

    ELSIF (p_prefix = g_checkout_eqr_prefix) THEN
        l_txn_number := qa_ss_const.eam_checkout_txn;
--dgupta: End R12 EAM Integration. Bug 4345492


    END IF;

    IF context_element(p_element_id, l_txn_number) THEN
        return 'formValue';
    ELSIF
        (qa_plan_element_api.values_exist(p_plan_id, p_element_id)
         OR qa_plan_element_api.sql_validation_exists(p_element_id)
         OR qa_chars_api.has_hardcoded_lov(p_element_id)) THEN
                return 'messageLovInput';
    ELSE

                return 'messageTextInput';
    END IF;

END compute_item_style;


FUNCTION query_criteria (p_prefix IN VARCHAR2, p_element_id IN NUMBER)
    RETURN BOOLEAN IS

    -- anagarwa Fri Mar 12 12:12:18 PST 2004
    -- bug 1795119 Ordered Quantity appears in context and detail region
    -- for VQR
    -- The cursor is modified by removing search_flag condition so that all
    -- context elements are hidden
    -- enabled_flag added as a condition to ensure that no disabled elements
    -- get added to detail region.
    CURSOR c (p_txn_number NUMBER) IS
        SELECT 'TRUE'
        FROM qa_txn_collection_triggers
        WHERE transaction_number = p_txn_number
        --AND search_flag = 1
        AND enabled_flag = 1
        AND collection_trigger_id = p_element_id;

    l_txn_number        NUMBER;
    dummy               VARCHAR2(10);
    result              BOOLEAN;

BEGIN

    -- This procecure determines if a colleciton element is a part of the
    -- VQR where clause.  If it is then it is a query criteria for vqr.
    -- In case of OM nothing is a query query criteria, hence always
    -- return FALSE

    IF (instr(p_prefix, g_om_vqr_prefix) <> 0) THEN
        RETURN FALSE;
    END IF;

    -- parent-child
    -- In case of parentchild no hidden fields, hence always
    -- return FALSE
    IF ((instr(p_prefix, g_pc_vqr_prefix) <> 0) OR
           (instr(p_prefix, g_pc_vqr_sin_prefix) <> 0 )) THEN
        RETURN FALSE;
    END IF;

    IF ( instr(p_prefix, g_osp_vqr_prefix) <> 0 ) THEN
        -- prefix passed has 'QAVQROSP' in it
        l_txn_number := qa_ss_const.ss_outside_processing_txn;

    ELSIF ( instr(p_prefix, g_ship_vqr_prefix) <> 0 ) THEN
        -- prefix passed has 'QAVQRSHP' in it
        l_txn_number := qa_ss_const.ss_shipments_txn;

    ELSIF ( instr(p_prefix, g_work_vqr_prefix) <> 0 ) THEN
        -- prefix passed has 'QAVQRWORK' in it
        l_txn_number := qa_ss_const.eam_work_order_txn;

    ELSIF ( instr(p_prefix, g_asset_vqr_prefix) <> 0 ) THEN
        -- prefix passed has 'QAVQRASSET' in it
        l_txn_number := qa_ss_const.eam_asset_txn;

    ELSIF ( instr(p_prefix, g_op_vqr_prefix) <> 0 ) THEN
        -- prefix passed has 'QAVQROP' in it
        l_txn_number := qa_ss_const.eam_operation_txn;

 --dgupta: Start R12 EAM Integration. Bug 4345492
    ELSIF ( instr(p_prefix, g_checkin_vqr_prefix) <> 0 ) THEN
        -- prefix passed has 'QAVQRCHECKIN' in it
        l_txn_number := qa_ss_const.eam_checkin_txn;

    ELSIF ( instr(p_prefix, g_checkout_vqr_prefix) <> 0 ) THEN
        -- prefix passed has 'QAVQRCHECKOUT' in it
        l_txn_number := qa_ss_const.eam_checkout_txn;
--dgupta: End R12 EAM Integration. Bug 4345492

    END IF;

    OPEN c(l_txn_number);
    FETCH c into dummy;
    result := c%FOUND;
    CLOSE c;
    RETURN result;

END query_criteria;



PROCEDURE get_dependencies (p_char_id IN NUMBER, x_parents OUT NOCOPY ParentArray) IS

BEGIN

    -- This is needed for populating correct lov relatiovs.
    -- Given a element id, this function computes the
    -- ancestors for it and accordingly populates a
    -- OUT table structure.

    x_parents.delete();

    IF p_char_id = qa_ss_const.item THEN
        x_parents(1) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.to_op_seq_num THEN
        x_parents(1) := qa_ss_const.job_name;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.from_op_seq_num THEN
        x_parents(1) := qa_ss_const.job_name;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.to_intraoperation_step THEN
        x_parents(1) := qa_ss_const.to_op_seq_num;

    ELSIF p_char_id = qa_ss_const.from_intraoperation_step THEN
        x_parents(1) := qa_ss_const.from_op_seq_num;

    ELSIF p_char_id = qa_ss_const.uom THEN

        x_parents(1) := qa_ss_const.item;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.revision THEN
        x_parents(1) := qa_ss_const.item;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.subinventory THEN
        x_parents(1) := qa_ss_const.item;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.locator THEN
        x_parents(1) := qa_ss_const.subinventory;
        x_parents(2) := qa_ss_const.item;
        x_parents(3) := qa_ss_const.production_line;

    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- bug 3830258 incorrect LOVs in QWB
    -- synced up the lot number lov with forms
    ELSIF p_char_id = qa_ss_const.lot_number THEN
        x_parents(1) := qa_ss_const.item;
        --x_parents(2) := qa_ss_const.production_line;

    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- bug 3830258 incorrect LOVs in QWB
    -- synced up the serial number lov with forms
    ELSIF p_char_id = qa_ss_const.serial_number THEN
        x_parents(1) := qa_ss_const.lot_number;
        x_parents(2) := qa_ss_const.item;
        --x_parents(3) := qa_ss_const.production_line;
        x_parents(3) := qa_ss_const.revision;

    ELSIF p_char_id = qa_ss_const.comp_uom THEN
        x_parents(1) := qa_ss_const.comp_item;

    ELSIF p_char_id = qa_ss_const.comp_revision THEN
        x_parents(1) := qa_ss_const.comp_item;

    ELSIF p_char_id = qa_ss_const.po_line_num THEN
        x_parents(1) := qa_ss_const.po_number;

    ELSIF p_char_id = qa_ss_const.po_shipment_num THEN
        x_parents(1) := qa_ss_const.po_line_num;
        x_parents(2) := qa_ss_const.po_number;

    ELSIF p_char_id = qa_ss_const.po_release_num THEN
        x_parents(1) := qa_ss_const.po_number;

    ELSIF p_char_id = qa_ss_const.order_line THEN
        x_parents(1) := qa_ss_const.sales_order;

    ELSIF p_char_id = qa_ss_const.task_number THEN
        x_parents(1) := qa_ss_const.project_number;

    --dgupta: Start R12 EAM Integration. Bug 4345492
    ELSIF p_char_id = qa_ss_const.asset_instance_number THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_number;

    ELSIF p_char_id = qa_ss_const.asset_number THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_instance_number;

    -- rkaza. 10/22/2003. 3209804. As part of EAM rebuild project
    -- added the following dependencies
    ELSIF p_char_id = qa_ss_const.asset_activity THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_number;
        x_parents(3) := qa_ss_const.asset_instance_number;

    ELSIF p_char_id = qa_ss_const.followup_activity THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_number;
        x_parents(3) := qa_ss_const.asset_instance_number;
    --dgupta: End R12 EAM Integration. Bug 4345492

    ELSIF p_char_id = qa_ss_const.maintenance_op_seq THEN
        x_parents(1) := qa_ss_const.work_order;

    -- rkaza. 12/02/2003. bug 3280307.
    -- Added dependency relation for component item with item
    ELSIF p_char_id = qa_ss_const.comp_item THEN
        x_parents(1) := qa_ss_const.item;

    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- bug 3830258 incorrect LOVs in QWB
    -- synced up the component lot number and component serial number
    -- lov with forms
    ELSIF p_char_id = qa_ss_const.comp_lot_number THEN
        x_parents(1) := qa_ss_const.comp_item;

    ELSIF p_char_id = qa_ss_const.comp_serial_number THEN
        x_parents(1) := qa_ss_const.comp_lot_number;
        x_parents(2) := qa_ss_const.comp_item;
        x_parents(3) := qa_ss_const.comp_revision;

    -- R12 OPM Deviations. Bug 4345503 Start
    ELSIF p_char_id = qa_ss_const.process_batchstep_num THEN
        x_parents(1) := qa_ss_const.process_batch_num;

    ELSIF p_char_id = qa_ss_const.process_operation THEN
        x_parents(1) := qa_ss_const.process_batch_num;
        x_parents(2) := qa_ss_const.process_batchstep_num;

    ELSIF p_char_id = qa_ss_const.process_activity THEN
        x_parents(1) := qa_ss_const.process_batch_num;
        x_parents(2) := qa_ss_const.process_batchstep_num;

    ELSIF p_char_id = qa_ss_const.process_resource THEN
        x_parents(1) := qa_ss_const.process_batch_num;
        x_parents(2) := qa_ss_const.process_batchstep_num;
        x_parents(2) := qa_ss_const.process_activity;

    ELSIF p_char_id = qa_ss_const.process_parameter THEN
        x_parents(1) := qa_ss_const.process_resource;

    -- R12 OPM Deviations. Bug 4345503 End
    --
    -- Bug 9032151
    -- Added dependency relation for  item instance with item
    -- skolluku
    --
    ELSIF p_char_id = qa_ss_const.item_instance THEN
         x_parents(1) := qa_ss_const.item;

    --
    -- Bug 9359442
    -- Added dependency relation for  item instance serial with item
    -- skolluku
    --
    ELSIF p_char_id = qa_ss_const.item_instance_serial THEN
        x_parents(1) := qa_ss_const.item;
    END IF;

END get_dependencies;


FUNCTION action_target_element (p_plan_id IN NUMBER, p_char_id IN NUMBER)
    RETURN BOOLEAN IS

    -- Bug 3111310
    -- Changed the Cursor Query for SQL performance fix
    -- saugupta Mon Sep  8 06:00:06 PDT 2003

    CURSOR c IS
        SELECT 1
        FROM qa_plan_char_actions
        WHERE assigned_char_id = p_char_id
        AND plan_char_action_trigger_id
        IN (SELECT plan_char_action_trigger_id
                  FROM qa_plan_char_action_triggers
                  WHERE plan_id = p_plan_id);

    dummy NUMBER;
    result BOOLEAN;

BEGIN

    -- if the element is a potenital target for assigned a value
    -- action then return true.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END action_target_element;




FUNCTION get_region_style (p_code VARCHAR2)
    RETURN VARCHAR2 IS

    l_region_style VARCHAR2(30);

BEGIN

    -- A value of zero is false 1 is true for INSTR comparison

    IF (instr(p_code, g_txn_work_prefix) <> 0)
        OR (instr(p_code, g_txn_asset_prefix) <> 0)
        OR (instr(p_code, g_txn_op_prefix) <> 0)
	--dgupta: Start R12 EAM Integration. Bug 4345492
        OR (instr(p_code, g_checkin_eqr_prefix) <> 0)
        OR (instr(p_code, g_checkout_eqr_prefix) <> 0)
	--dgupta: End R12 EAM Integration. Bug 4345492

    THEN
        -- rkaza. BLAF. 01/28/2004. Changed to double col from single col
        l_region_style := 'defaultDoubleColumn';
    ELSIF (instr(p_code, g_pc_vqr_sin_prefix) <> 0) --parent-child
    THEN
       --ilawler - bug #3462025 - Mon Feb 23 17:42:47 2004
       --use the new labeledFieldLayout instead
       l_region_style := 'labeledFieldLayout';
    ELSE
        l_region_style := 'table';
    END IF;

    RETURN l_region_style;

END get_region_style;


FUNCTION create_jrad_region (
    p_region_code IN VARCHAR2,
    p_plan_id IN NUMBER) RETURN JDR_DOCBUILDER.ELEMENT IS

    l_region_style      VARCHAR2(30);
    l_row_id            VARCHAR2(30);
    l_plan_name         qa_plans.name%TYPE;
    topLevel JDR_DOCBUILDER.ELEMENT := NULL;

    l_prompt       VARCHAR2(30);

    CURSOR c IS
        SELECT NAME from qa_plans
        WHERE plan_id = p_plan_id;

BEGIN

    -- This procedure creates an entry in ak regions table for a collection
    -- plan in Quality.

    OPEN c;
    FETCH c INTO l_plan_name;
    CLOSE c;


    l_region_style := get_region_style(p_region_code);
    topLevel := JDR_DOCBUILDER.createElement(JDR_DOCBUILDER.OA_NS, l_region_style);

    -- rkaza. 02/26/2004. bug 3461988.
    -- Prompt of the EQR region should be Data for EAM EQR page.
    -- EAM vqr table regions should have a width 100%

    IF (instr(p_region_code, g_txn_work_prefix) <> 0)
        OR (instr(p_region_code, g_txn_asset_prefix) <> 0)
	--dgupta: Start R12 EAM Integration. Bug 4345492
        OR (instr(p_region_code, g_checkin_eqr_prefix) <> 0)
        OR (instr(p_region_code, g_checkout_eqr_prefix) <> 0)
	--dgupta: End R12 EAM Integration. Bug 4345492
        OR (instr(p_region_code, g_txn_op_prefix) <> 0) then
       l_prompt := fnd_message.get_string('QA', 'QA_SS_RN_PROMPT_DATA');
       jdr_docbuilder.setAttribute(topLevel, 'text', l_prompt);
    END IF;

    IF (instr(p_region_code, g_work_vqr_prefix) <> 0)
        OR (instr(p_region_code, g_asset_vqr_prefix) <> 0)
	--dgupta: Start R12 EAM Integration. Bug 4345492
        OR (instr(p_region_code, g_checkin_vqr_prefix) <> 0)
        OR (instr(p_region_code, g_checkout_vqr_prefix) <> 0)
	--dgupta: End R12 EAM Integration. Bug 4345492
        OR (instr(p_region_code, g_op_vqr_prefix) <> 0) then
       jdr_docbuilder.setAttribute(topLevel, 'width', '100%');
    END IF;

    jdr_docbuilder.setAttribute(topLevel, 'prompt', l_plan_name);
    jdr_docbuilder.setAttribute(topLevel, 'regionName', l_plan_name);
    jdr_docbuilder.setAttribute(topLevel, 'id', p_region_code);

    IF (instr(p_region_code, g_pc_vqr_sin_prefix) <> 0) THEN
       jdr_docbuilder.setAttribute(topLevel, 'headerDisabled', 'true');
    ELSIF (instr(p_region_code, g_pc_vqr_prefix) <> 0) THEN
       --ilawler - bug #3462025 - Mon Feb 23 17:19:07 2004
       --Set width of table to be 90%
       jdr_docbuilder.setAttribute(topLevel, 'width', '90%');
    END IF;

    -- Tracking Bug : 3209719
    -- Added for OAC complicance
    -- ilawler Tue Oct 21 15:24:26 2003
    IF l_region_style = 'table' THEN
       jdr_docbuilder.setAttribute(topLevel, 'shortDesc', fnd_message.get_string('QA','QA_OAC_RESULTS_TABLE'));
    ELSIF l_region_style = 'labeledFieldLayout' THEN
       --ilawler - bug #3462025 - Mon Feb 23 17:42:47 2004
       --when using the labeledFieldLayout, suggest 2 columns
       jdr_docbuilder.setAttribute(topLevel, 'columns', '2');
    END IF;

    RETURN topLevel;

    -- dbms_output.put_line('Adding Region    : ' || l_region_code);

END create_jrad_region;


    --
    -- MOAC Project. 4637896
    -- New procedure to create base attribute code.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --

FUNCTION cons_base_attribute_code (
      p_element_prefix           IN VARCHAR2,
      p_id                       IN VARCHAR2)
        RETURN VARCHAR2  IS

BEGIN
    IF(p_id = qa_ss_const.po_number) THEN
       return qa_chars_api.hardcoded_column(p_id);
    END IF;

    return construct_jrad_code(p_element_prefix,p_id);

END cons_base_attribute_code;


PROCEDURE add_lov_relations (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_input_elem IN jdr_docbuilder.Element) IS


    err_num                     NUMBER;
    err_msg                     VARCHAR2(100);

    l_row_id                    VARCHAR2(30);
    l_region_code               VARCHAR2(30);
    l_attribute_code            VARCHAR2(30);
    l_lov_attribute_code        VARCHAR2(30);
    l_base_attribute_code       VARCHAR2(30);
    l_parents                   ParentArray;

    lovMap  jdr_docbuilder.ELEMENT;


BEGIN

    -- This function adds lov relations for a region item.
    -- Here the region item corresponds to a collection plan element.

   --Criteria
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', p_attribute_code);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_code);
   jdr_docbuilder.setAttribute(lovMap, 'requiredForLOV', 'true');
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
   --Result
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'resultTo', p_attribute_code);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_code);
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
  --Org Id
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', g_org_id_attribute);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_org_id);
   jdr_docbuilder.setAttribute(lovMap, 'programmaticQuery', 'true');
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
  --Plan Id
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', g_plan_id_attribute);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_plan_id);
   jdr_docbuilder.setAttribute(lovMap, 'programmaticQuery', 'true');
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);


    get_dependencies(p_char_id, l_parents);

    FOR i IN 1..l_parents.COUNT LOOP

        -- anagarwa
        -- Bug 2751198
        -- Add dependency to LOV only if the element exists in the plan
        -- This is achieved by adding the following IF statement
        -- IF qa_plan_element_api.exists_qa_plan_chars(p_plan_id,
        --                           l_parents(i)) THEN

        -- rkaza. 10/22/2003. 3209804. shold not use exists_qa_plan_chars
        -- array might not have been initialized. use element_in_plan

        IF qa_plan_element_api.element_in_plan(p_plan_id,
                                   l_parents(i)) THEN

        l_lov_attribute_code := g_lov_attribute_dependency || to_char(i);
          --
          -- MOAC Project. 4637896
          -- Call new procedure to construct base code
          -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
          --

          l_base_attribute_code := cons_base_attribute_code(g_element_prefix, l_parents(i));

      lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS,
                        'lovMap');
      jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom',
                                        l_base_attribute_code);
      jdr_docbuilder.setAttribute(lovMap, 'lovItem', l_lov_attribute_code);
      jdr_docbuilder.setAttribute(lovMap, 'programmaticQuery', 'true');
      jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
      END IF;

    END LOOP;

    -- dbms_output.put_line('Adding LOV rel   : ');

EXCEPTION

    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END add_lov_relations;

    --
    -- MOAC Project. 4637896
    -- New procedure to create id item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --


FUNCTION create_id_item_for_eqr (
    p_plan_id                  IN NUMBER,
    p_char_id                  IN NUMBER)
        RETURN jdr_docbuilder.ELEMENT  IS

    l_vo_attribute_name         VARCHAR2(30)  DEFAULT NULL;
    l_id_elem jdr_docbuilder.ELEMENT := NULL;

BEGIN

    l_vo_attribute_name := qa_chars_api.hardcoded_column(p_char_id);
    l_id_elem := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, 'formValue');

    -- set properties
    jdr_docbuilder.setAttribute(l_id_elem, 'id', l_vo_attribute_name);
    jdr_docbuilder.setAttribute(l_id_elem, 'viewName', g_eqr_view_usage_name);
    jdr_docbuilder.setAttribute(l_id_elem, 'viewAttr', l_vo_attribute_name);
    jdr_docbuilder.setAttribute(l_id_elem, 'dataType', 'NUMBER');

    return l_id_elem;

END create_id_item_for_eqr;



    --
    -- MOAC Project. 4637896
    -- Checks whether its a normalized lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
FUNCTION is_normalized_lov  (
         p_plan_id     IN NUMBER,
         p_char_id     IN NUMBER) RETURN VARCHAR2 IS

BEGIN
    -- currently we are enabling normalized logic
    -- only for  PO NUMBER
    if(p_char_id = qa_ss_const.po_number) then
      return 'T';
    end if;

    return 'F';
END is_normalized_lov;

    --
    -- MOAC Project. 4637896
    -- Gets external LOV region name
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
FUNCTION get_lov_region_name  (
         p_plan_id     IN NUMBER,
         p_char_id     IN NUMBER) RETURN VARCHAR2 IS

BEGIN
    -- currently we are enabling normalized logic
    -- only for  PO NUMBER. So we are hard coding
    -- lov region name. In future, this proc must
    -- be generalized.
    if(p_char_id = qa_ss_const.po_number) then
      return 'PONumberLovRN';
    end if;

    return 'QaLovRN';

END get_lov_region_name;


    --
    -- MOAC Project. 4637896
    -- New method to process normalized lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --

PROCEDURE process_normalized_lov (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_char_item                IN jdr_docbuilder.Element) IS

   lovMap  jdr_docbuilder.ELEMENT;
   l_lov_region  VARCHAR2(100);

BEGIN

    IF(p_char_id = qa_ss_const.po_number) THEN
      l_lov_region := qa_ssqr_jrad_pkg.g_jrad_lov_dir_path ||  get_lov_region_name(p_plan_id,p_char_id);
      jdr_docbuilder.setAttribute(p_char_item,
                                  'externalListOfValues',
                                  l_lov_region);
       --Criteria
      lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
      jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', p_attribute_code);
      jdr_docbuilder.setAttribute(lovMap, 'resultTo', p_attribute_code);
      jdr_docbuilder.setAttribute(lovMap, 'lovItem', 'Segment1');
      jdr_docbuilder.setAttribute(lovMap, 'requiredForLOV', 'true');
      jdr_docbuilder.addChild(p_char_item, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
      -- po_header_id
      lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
      jdr_docbuilder.setAttribute(lovMap, 'lovItem', 'PoHeaderId');
      jdr_docbuilder.setAttribute(lovMap, 'resultTo', qa_chars_api.hardcoded_column(p_char_id));
      jdr_docbuilder.addChild(p_char_item, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);

    END IF; -- PO Number

END process_normalized_lov;

    --
    -- MOAC Project. 4637896
    -- New method to process regular lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --

PROCEDURE process_regular_lov (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_char_item                 IN jdr_docbuilder.Element) IS

BEGIN

    jdr_docbuilder.setAttribute(p_char_item, 'externalListOfValues',
                  		                g_jrad_lov_path);

    add_lov_relations(p_plan_id, p_char_id, p_attribute_code, p_char_item);

END process_regular_lov;

    --
    -- MOAC Project. 4637896
    -- New method to process lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --

PROCEDURE process_messageLovInput (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_char_item                 IN jdr_docbuilder.Element) IS



BEGIN
   -- in the future, this may be changed to be more generic
   -- so that all hardcoded LOVs will go through this
   -- process_normalized_lov procedure.  Currently handle
   -- PO Number only for the immediate MOAC requirement.
    IF is_normalized_lov(p_plan_id,p_char_id) = 'T' THEN
         process_normalized_lov(
             p_plan_id,
             p_char_id,
             p_attribute_code,
             p_char_item);
    ELSE
         process_regular_lov(
             p_plan_id,
             p_char_id,
             p_attribute_code,
             p_char_item);
    END IF;

END process_messageLovInput;


-- Bug 5455658. SHKALYAN 20-Sep-2006
-- Added this function to get the prompt and concatenate the UOM
FUNCTION get_prompt (p_plan_id IN NUMBER,
    p_char_id IN NUMBER) RETURN VARCHAR2 IS

    l_prompt qa_plan_chars.prompt%TYPE;
    l_uom_code qa_plan_chars.uom_code%TYPE;
BEGIN
   -- The function is the standard way to compute prompt
   -- taking uom_code into account
    l_prompt := qa_plan_element_api.get_prompt(p_plan_id, p_char_id);
    l_uom_code := qa_plan_element_api.get_uom_code(p_plan_id, p_char_id);

    IF (l_uom_code is not null) THEN
      RETURN l_prompt || ' (' || l_uom_code || ')';
    ELSE
      RETURN l_prompt;
    END IF;
END get_prompt;


FUNCTION create_region_item_for_eqr (
    p_char_id IN NUMBER,
    p_plan_id IN NUMBER,
    p_prefix IN VARCHAR2) RETURN JDR_DOCBUILDER.ELEMENT  IS

    -- Bug 3769260. shkalyan 29 July 2004.
    -- Removed these attributes since the cursor to get from qa_plan_chars
    -- and qa_chars are removed.
/*
    c_displayed_flag qa_plan_chars.displayed_flag%TYPE;
    c_mandatory_flag qa_plan_chars.mandatory_flag%TYPE;
    c_prompt qa_plan_chars.prompt%TYPE;
    c_char_name qa_chars.name%TYPE;
    c_datatype qa_chars.datatype%TYPE;
    c_readonly_flag             NUMBER;
*/

    l_attribute_code            VARCHAR2(30);
    l_vo_attribute_name         VARCHAR2(30);
    l_display_flag              VARCHAR2(10);
    l_required_flag             VARCHAR2(10);
    l_item_style                VARCHAR2(30);
    l_data_type                 VARCHAR2(30);
    l_display_sequence          NUMBER;
    -- Bug 6491622
    -- Changing the length of the local variable l_prompt
    -- to a higher value - 100 and commenting out the existing code
    -- bhsankar Tue Oct 16 23:21:38 PDT 2007
    -- l_prompt                  qa_plan_chars.prompt%TYPE;
    l_prompt                    VARCHAR2(100);

    child1 jdr_docbuilder.ELEMENT;

    -- Tracking Bug : 3104827
    -- Added for Read Only Flag for Collection Plan Enhancement
    -- saugupta Thu Aug 28 08:58:53 PDT 2003
    l_readonly_flag             VARCHAR2(10);

    -- Bug 3769260. shkalyan 29 July 2004.
    -- Removed these cursors so that the cached arrays of qa_chars_api
    -- and qa_plan_element_api are used instead.
/*
    CURSOR c1 IS
        SELECT displayed_flag, mandatory_flag, prompt, read_only_flag
        FROM qa_plan_chars
        WHERE plan_id = p_plan_id
        AND   char_id = p_char_id;

    CURSOR c2 IS
        SELECT name, datatype
        FROM qa_chars
        WHERE char_id = p_char_id;
*/

    err_num                     NUMBER;
    err_msg                     VARCHAR2(100);

BEGIN

    -- Bug 3769260. shkalyan 29 July 2004.
    -- Removed these cursors so that the cached arrays of qa_chars_api
    -- and qa_plan_element_api are used instead.
/*
    OPEN c1;
    FETCH c1 INTO c_displayed_flag, c_mandatory_flag, c_prompt, c_readonly_flag;
    CLOSE c1;

    OPEN c2;
    FETCH c2 INTO c_char_name, c_datatype;
    CLOSE c2;
*/

    l_attribute_code := construct_jrad_code(g_element_prefix, p_char_id);
    -- This procedure adds a region item to the plan's eqr region.

    l_attribute_code := construct_jrad_code(g_element_prefix, p_char_id);

    l_vo_attribute_name := get_vo_attribute_name(p_char_id, p_plan_id);

    l_display_flag  := convert_boolean_flag( qa_plan_element_api.qpc_displayed_flag( p_plan_id, p_char_id ) );

    l_required_flag := convert_yesno_flag( qa_plan_element_api.qpc_mandatory_flag( p_plan_id, p_char_id ) );

    l_data_type := convert_data_type( qa_chars_api.datatype( p_char_id ) );

    l_item_style    := compute_item_style(p_prefix, p_char_id, p_plan_id);

    -- Tracking Bug : 3104827
    -- Added for Read Only Flag Collection Plan Enhancement
    -- saugupta Thu Aug 28 08:59:59 PDT 2003

    l_readonly_flag := convert_boolean_flag( qa_plan_element_api.qpc_read_only_flag( p_plan_id, p_char_id ) );

    -- Bug 5455658. SHKALYAN 20-Sep-2006
    -- modified to invoke a local function which calls
    -- qa_plan_element_api.get_prompt instead of
    -- qa_chars_api.prompt because the latter would always return the prompt
    -- defined at the element level only and this is not desired.
    -- l_prompt := qa_chars_api.prompt( p_char_id );
    l_prompt := get_prompt(p_plan_id, p_char_id);

    child1 := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, l_item_style);
    jdr_docbuilder.setAttribute(child1, 'id', l_attribute_code);
    jdr_docbuilder.setAttribute(child1, 'rendered', l_display_flag);
    jdr_docbuilder.setAttribute(child1, 'prompt', l_prompt);
    jdr_docbuilder.setAttribute(child1, 'shortDesc', l_prompt);
    jdr_docbuilder.setAttribute(child1, 'required', l_required_flag);
    jdr_docbuilder.setAttribute(child1, 'dataType', l_data_type);
    jdr_docbuilder.setAttribute(child1, 'viewName', g_eqr_view_usage_name);
    jdr_docbuilder.setAttribute(child1, 'viewAttr', l_vo_attribute_name);

    -- Tracking Bug : 3104827
    -- Added for Read Only Flag Collection Plan Enhancement
    -- saugupta Thu Aug 28 08:59:59 PDT 2003

    jdr_docbuilder.setAttribute(child1, 'readOnly', l_readonly_flag);

    -- At this point, if the element has lovs then we must determine
    -- what are its dependency and populate lov_relations
    -- with this information.

      -- MOAC Project. 4637896
      -- Call new method to process lov item.
      -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
      --
      IF (l_item_style = 'messageLovInput' ) THEN
          process_messageLovInput(p_plan_id,
                                  p_char_id,
                                  l_attribute_code,
                                  child1);
      END IF;


    RETURN child1;

    -- dbms_output.put_line('Adding Item      : ' || l_region_code || ' ' ||
    --    l_attribute_code);

EXCEPTION

    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END create_region_item_for_eqr;


FUNCTION create_region_item_for_vqr (
    p_attribute_code           IN VARCHAR2,
    p_plan_id                  IN VARCHAR2,
    p_prefix                   IN VARCHAR2,
    p_char_id                  IN NUMBER)
    RETURN JDR_DOCBUILDER.ELEMENT IS

    l_row_id                    VARCHAR2(30);
    l_element_id                NUMBER;
    l_region_code               VARCHAR2(30);
    l_nested_region_code        VARCHAR2(30) DEFAULT null;
    l_item_style                VARCHAR2(30) DEFAULT 'messageStyledText';
    l_display_sequence          NUMBER;
    l_display_flag              VARCHAR2(1)  DEFAULT 'Y';
    l_update_flag               VARCHAR2(1)  DEFAULT 'Y';
    l_query_flag                VARCHAR2(30) DEFAULT NULL;
    l_view_attribute_name       VARCHAR2(30) DEFAULT NULL;
    l_view_usage_name           VARCHAR2(30) DEFAULT NULL;
    -- Bug 6491622
    -- Changing the length of the local variable l_label_long
    -- to a higher value - 100 and commenting out the existing code
    -- bhsankar Tue Oct 16 23:21:38 PDT 2007
    -- l_label_long                VARCHAR2(30) DEFAULT NULL;
    l_label_long                VARCHAR2(100) DEFAULT NULL;
    l_data_type                 VARCHAR2(30);

    child1 jdr_docbuilder.ELEMENT;

    err_num                     NUMBER;
    err_msg                     VARCHAR2(100);

BEGIN

    -- This procedure adds a region item to the plan's vqr region.

    -- bug 3178307. rkaza. timezone support. 10/06/2003
    -- Added datatype to vqr region items

    l_region_code := construct_jrad_code(p_prefix, p_plan_id);
    l_view_usage_name := g_vqr_view_usage_name;
    -- parent-child for header single row region only
        IF (instr(p_prefix, g_pc_vqr_sin_prefix) <> 0)
        THEN
                l_view_usage_name := 'ParentResultVO';
        END IF;


    l_element_id := p_char_id;

    l_view_attribute_name := qa_core_pkg.get_result_column_name (
         l_element_id, p_plan_id);

    l_data_type := convert_data_type(qa_chars_api.datatype(p_char_id));

    -- Bug 3769260. shkalyan 29 July 2004.
    -- Removed the get_label function which was getting prompt from
    -- qa_plan_chars. Using the qa_plan_element_api function to utilize cache

    -- Bug 5455658. SHKALYAN 20-Sep-2006
    -- modified to invoke a local function which calls
    -- qa_plan_element_api.get_prompt and concatenates the UOM
    l_label_long := get_prompt(p_plan_id, l_element_id);

    -- item_style is HIDDEN and if this element is a context element
    -- and is a query criteria (search flag is 1) for vqr

    IF (query_criteria (l_region_code, l_element_id)) THEN
         l_item_style := 'formValue';
    END IF;

    IF (instr(l_region_code, g_work_vqr_prefix) <> 0)
        OR (instr(l_region_code, g_asset_vqr_prefix) <> 0)
	--dgupta: Start R12 EAM Integration. Bug 4345492
        OR (instr(l_region_code, g_checkin_vqr_prefix) <> 0)
        OR (instr(l_region_code, g_checkout_vqr_prefix) <> 0)
	--dgupta: End R12 EAM Integration. Bug 4345492
        OR (instr(l_region_code, g_op_vqr_prefix) <> 0) THEN
        l_query_flag := 'true';
    END IF;

    child1 := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, l_item_style);
    jdr_docbuilder.setAttribute(child1, 'id', p_attribute_code);
    jdr_docbuilder.setAttribute(child1, 'rendered', 'true');
    jdr_docbuilder.setAttribute(child1, 'prompt', l_label_long);
    jdr_docbuilder.setAttribute(child1, 'dataType', l_data_type);
    jdr_docbuilder.setAttribute(child1, 'shortDesc', l_label_long);
    jdr_docbuilder.setAttribute(child1, 'viewName', l_view_usage_name);
    jdr_docbuilder.setAttribute(child1, 'viewAttr', l_view_attribute_name);

    --ilawler - bug #3462025 - Mon Feb 23 17:48:09 2004
    --set the right CSS Class for data elements
    IF (instr(l_region_code, g_pc_vqr_sin_prefix) <> 0) THEN
       jdr_docbuilder.setAttribute(child1, 'styleClass', 'OraDataText');
    END IF;

    IF l_query_flag IS NOT NULL THEN
       --dbms_output.put_line('found a queryable');
       jdr_docbuilder.setAttribute(child1, 'queryable', l_query_flag);
    END IF;
    RETURN child1;

    -- dbms_output.put_line('Adding Item (S)  : ' || l_region_code || ' ' ||
    --    p_attribute_code);

EXCEPTION

    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END create_region_item_for_vqr;



FUNCTION add_special_region_item (
    p_attribute_code           IN VARCHAR2,
    p_plan_id                  IN VARCHAR2,
    p_prefix                   IN VARCHAR2,
    p_region_code              IN VARCHAR2)
                RETURN jdr_docbuilder.ELEMENT  IS

    l_row_id                    VARCHAR2(30);
    l_element_id                NUMBER;
    l_region_code               VARCHAR2(30);
    --l_nested_region_code      VARCHAR2(30)  DEFAULT null;
    l_item_style                VARCHAR2(30)  DEFAULT 'formValue';
    --l_display_sequence                NUMBER;
    --l_display_flag            VARCHAR2(1)   DEFAULT 'Y';
    l_restrict_attachment       VARCHAR2(1)   DEFAULT NULL;
    l_view_attribute_name       VARCHAR2(30)  DEFAULT NULL;
    l_view_usage_name           VARCHAR2(30)  DEFAULT NULL;
    l_label_long                VARCHAR2(30)  DEFAULT NULL;
    l_entity_id                 VARCHAR2(30)  DEFAULT NULL;
    l_url                       VARCHAR2(240) DEFAULT NULL;
    l_image_file_name           VARCHAR2(240) DEFAULT NULL;
    l_description               VARCHAR2(240) DEFAULT NULL;
    --l_query_flag              VARCHAR2(1)   DEFAULT 'N';
    l_data_type                 VARCHAR2(30);

    special_elem jdr_docbuilder.ELEMENT := NULL;
    l_entityMap jdr_docbuilder.ELEMENT := NULL;

    err_num                     NUMBER;
    err_msg                     VARCHAR2(100);

BEGIN


    -- This function adds special region items to the region.
    --  1.  To add special elements for eqr (e.g. org_id, plan_id_ etc)
    --  2.  To add special elements for vqr (e.g. org_id, plan_id_ etc)

    -- bug 3178307. rkaza. timezone support. 10/06/2003
    -- Added datatype datetime to last_update_date

    l_region_code := p_region_code;

    IF ( instr(p_prefix, g_vqr_prefix) = 1) THEN

         -- Adding special elements for vqr
         l_view_usage_name := g_vqr_view_usage_name;
         l_item_style := 'messageStyledText';
    ELSE

         -- Adding special elements for eqr
         l_view_usage_name := g_eqr_view_usage_name;

    END IF;

    l_view_attribute_name := get_hardcoded_vo_attr_name(
            p_attribute_code);

    l_label_long := get_special_label(p_attribute_code);

    -- added for attachments
    IF (p_attribute_code = g_single_row_attachment) OR
       (p_attribute_code = g_multi_row_attachment) THEN
         l_entity_id := 'QA_RESULTS';

         l_view_attribute_name := '';
         --Tue Apr 29 15:03:47 2003, ilawler: static text replaced with a message
         l_label_long := fnd_message.get_string('QA', 'QA_SS_JRAD_ATTACHMENT');
         l_description := l_label_long;

         IF (instr(l_region_code, g_txn_work_prefix) <> 0)
             OR (instr(l_region_code, g_txn_asset_prefix) <> 0)
	     --dgupta: Start R12 EAM Integration. Bug 4345492
             OR (instr(l_region_code, g_checkin_eqr_prefix) <> 0)
             OR (instr(l_region_code, g_checkout_eqr_prefix) <> 0)
	     --dgupta: End R12 EAM Integration. Bug 4345492
             OR (instr(l_region_code, g_txn_op_prefix) <> 0)
             AND (p_attribute_code = g_single_row_attachment) THEN
             l_item_style := 'attachmentLink';
         ELSE
             l_item_style := 'attachmentImage';
         END IF;

         --ilawler - bug #3436725 - Thu Feb 12 14:39:38 2004
         --In VQR, set the attachment to be non-updateable/deletable/insertable
         IF (instr(p_prefix, g_vqr_prefix) = 1) THEN
            l_restrict_attachment := 'Y';
         END IF;
    END IF;

    IF (p_attribute_code = g_update_attribute) THEN

        -- dbms_output.put_line('Display Sequence: ' || l_display_sequence);

         --l_query_flag := 'N';
         --Tue Apr 29 15:03:47 2003, ilawler: static text replaced with a message
         l_label_long := fnd_message.get_string('QA', 'QA_SS_JRAD_UPDATE');
         l_view_attribute_name := '';
         l_item_style := 'image';
         l_image_file_name := 'updateicon_enabled.gif';

         -- rkaza. bug 3461988. EAM BLAF changes.
         -- Plan name has to be displayed in the page title
         -- Adding plan name as a parameter.
         l_url := '/OA_HTML/OA.jsp?akRegionCode=QA_DDE_EQR_PAGE' || '&' ||
             'akRegionApplicationId=250' || '&' ||
             'PlanId={@PLAN_ID}' || '&' ||
             'PlanName={@NAME}' || '&' ||
             'Occurrence={@OCCURRENCE}' || '&' ||
             'UCollectionId={@COLLECTION_ID}' || '&' ||
             'retainAM=Y' || '&' || 'addBreadCrumb=Y';

    END IF;

    -- parent-child
    IF (p_attribute_code = g_child_url_attribute) THEN

        -- dbms_output.put_line('Display Sequence: ' || l_display_sequence);


         --l_query_flag := 'N';
         --Tue Apr 29 15:03:47 2003, ilawler: static text replaced with a message
         l_label_long := fnd_message.get_string('QA', 'QA_SS_JRAD_CHILD_PLANS');
         l_view_attribute_name := '';
         l_item_style := 'image';
         l_image_file_name := 'allocationbr_pagetitle.gif';--image changed!
         l_url := '/OA_HTML/OA.jsp?akRegionCode=QA_PC_RES_SUMMARY_PAGE'
                        || '&' ||
             'akRegionApplicationId=250' || '&' ||
             'ParentPlanId={@PLAN_ID}' || '&' ||
             'ParentOccurrence={@OCCURRENCE}' || '&' ||
             'ParentCollectionId={@COLLECTION_ID}' || '&' ||
             'ParentPlanName={@NAME}' || '&' ||
             'retainAM=Y' || '&' || 'addBreadCrumb=Y' ;
                --breadcrumb added for bug 2331941
    END IF;

    -- parent-child results inquiry ui improvement
    IF (p_attribute_code = g_vqr_all_elements_url) THEN

        -- dbms_output.put_line('Display Sequence: ' || l_display_sequence);


         --l_query_flag := 'N';
         --Tue Apr 29 15:03:47 2003, ilawler: static text replaced with a message
         l_label_long := fnd_message.get_string('QA', 'QA_SS_JRAD_MORE_DETAILS');
         l_view_attribute_name := '';
         l_item_style := 'image';
         l_image_file_name := 'detailsicon_enabled.gif';
         l_url := '/OA_HTML/OA.jsp?akRegionCode=QA_PC_RES_VQR_DETAIL_PAGE'
                        || '&' ||
             'akRegionApplicationId=250' || '&' ||
             'ParentPlanId={@PLAN_ID}' || '&' ||
             'ParentOccurrence={@OCCURRENCE}' || '&' ||
             'ParentCollectionId={@COLLECTION_ID}' || '&' ||
             'PlanName={@NAME}' || '&' ||
             'VqrParam=DETAILS' || '&' ||
             'retainAM=Y'  || '&' || 'addBreadCrumb=Y';
                --breadcrumb added for bug 2331941
    END IF;

    IF (p_attribute_code = g_last_update_date_attribute) THEN
        -- Assign a datatype of DATETIME to last_update_date.
        l_data_type := convert_data_type(qa_ss_const.datetime_datatype);
    END IF;

    special_elem := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS,
                                                  l_item_style);
    jdr_docbuilder.setAttribute(special_elem, 'id', p_attribute_code);

    if (l_view_usage_name is not null) then
        jdr_docbuilder.setAttribute(special_elem, 'viewName',
                        l_view_usage_name);
    end if;
    if (l_view_attribute_name is not null) then
        jdr_docbuilder.setAttribute(special_elem, 'viewAttr',
                        l_view_attribute_name);
    end if;
    if (l_label_long is not null) then
        jdr_docbuilder.setAttribute(special_elem, 'prompt',
                        l_label_long);
    end if;
    if (l_description is not null) then
        jdr_docbuilder.setAttribute(special_elem, 'shortDesc',
                        l_description);
    end if;
    if (l_image_file_name is not null) then
        jdr_docbuilder.setAttribute(special_elem, 'source',
                        l_image_file_name);
    end if;
    if (l_url is not null) then
        jdr_docbuilder.setAttribute(special_elem, 'destination',
                        replace(l_url, '&', '&#38;'));
    end if;
    if (l_data_type is not null) then
        jdr_docbuilder.setAttribute(special_elem, 'dataType', l_data_type);
    end if;
    if (l_entity_id is not null) then
        --special handling for attachments
        l_entityMap := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS,
                                        'entityMap');
        jdr_docbuilder.setAttribute(l_entityMap, 'entityId', l_entity_id);
        --
        -- Bug 8671769
        -- Adding 'id' for the entity map so that the personalization works perfectly.
        -- skolluku
        --
        jdr_docbuilder.setAttribute(l_entityMap, 'id', 'qaEntityMap1');

        --ilawler - bug #3436725 - Thu Feb 12 14:39:38 2004
        --In VQR, set the attachment to be non-updateable/deletable/insertable
        IF (l_restrict_attachment = 'Y') THEN
           jdr_docbuilder.setAttribute(l_entityMap, 'insertAllowed', 'false');
           jdr_docbuilder.setAttribute(l_entityMap, 'updateAllowed', 'false');
           jdr_docbuilder.setAttribute(l_entityMap, 'deleteAllowed', 'false');
        END IF;

        jdr_docbuilder.addChild(special_elem, jdr_docbuilder.OA_NS,
                                'entityMappings', l_entityMap);
    end if;--entity id not null

    return special_elem;

EXCEPTION

    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END add_special_region_item;


PROCEDURE map_plan_for_eqr (
    p_plan_id IN VARCHAR2,
    p_prefix IN VARCHAR2,
    p_jrad_doc_ver IN NUMBER) IS
--p_jrad_doc_ver cannot be null for now
--in future, pass null explicitly if necessary

    l_element_id   NUMBER;
    l_region_code  VARCHAR2(30);
    l_old_doc_name VARCHAR2(255);
    l_saved PLS_INTEGER;

    err_num      NUMBER;
    err_msg      VARCHAR2(100);

    qa_jrad_doc JDR_DOCBUILDER.DOCUMENT := NULL;
    topLevel JDR_DOCBUILDER.ELEMENT := NULL;
    child1 JDR_DOCBUILDER.ELEMENT := NULL;
    -- MOAC
    l_id_item JDR_DOCBUILDER.ELEMENT := NULL;

    CURSOR c IS
        SELECT char_id
        FROM qa_plan_chars
        WHERE plan_id = p_plan_id
        AND enabled_flag = 1;

BEGIN

   --qa_ian_pkg.write_log('Entered EQR, p_prefix: "'||p_prefix||'", p_jrad_doc_ver: '||p_jrad_doc_ver);

     l_region_code := construct_jrad_code(p_prefix, p_plan_id, p_jrad_doc_ver);

   --dbms_output.put_line('Entered EQR, path: "'||g_jrad_region_path||l_region_code||'", p_jrad_doc_ver: '||p_jrad_doc_ver);
     qa_jrad_doc := JDR_DOCBUILDER.createDocument(g_jrad_region_path || l_region_code, 'en-US');

     topLevel := create_jrad_region (l_region_code, p_plan_id);
     JDR_DOCBUILDER.setTopLevelElement(qa_jrad_doc, topLevel);

    OPEN c;
    LOOP
        FETCH c INTO l_element_id;
        EXIT WHEN c%NOTFOUND;

        -- we have taken a decision to not to display an element
        -- for data entry if the element is a potenital target
        -- for a assigned a value action.

        IF (NOT action_target_element(p_plan_id, l_element_id)) THEN

                child1 := create_region_item_for_eqr(
                                l_element_id, p_plan_id, p_prefix);
                JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);
                --contents is the grouping name

                -- For MOAC : add normalized column.
                IF l_element_id = qa_ss_const.po_number THEN
                  l_id_item := create_id_item_for_eqr(p_plan_id,l_element_id);
                  JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,'contents',l_id_item);
                END IF;


        END IF;

    END LOOP;
    CLOSE c;

    child1 := add_special_region_item (
        p_attribute_code           => g_org_id_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);

    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);

    child1 := add_special_region_item (
        p_attribute_code           => g_org_code_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);

    child1 := add_special_region_item (
        p_attribute_code           => g_plan_id_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);

    child1 := add_special_region_item (
        p_attribute_code           => g_plan_name_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);

    child1 := add_special_region_item (
        p_attribute_code           => g_process_status_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);

    child1 := add_special_region_item (
        p_attribute_code           => g_source_code_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);

    child1 := add_special_region_item (
        p_attribute_code           => g_source_line_id_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);

    child1 := add_special_region_item (
        p_attribute_code           => g_po_agent_id_attribute,
        p_plan_id                  => p_plan_id,
        p_prefix                   => p_prefix,
        p_region_code              => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);
    -- added for attachments

    IF (instr(l_region_code, g_txn_work_prefix) <> 0)
         OR (instr(l_region_code, g_txn_asset_prefix) <> 0)
	 --dgupta: Start R12 EAM Integration. Bug 4345492
         OR (instr(l_region_code, g_checkin_eqr_prefix) <> 0)
         OR (instr(l_region_code, g_checkout_eqr_prefix) <> 0)
	 --dgupta: End R12 EAM Integration. Bug 4345492
         OR (instr(l_region_code, g_txn_op_prefix) <> 0) THEN

        -- code branch for eam eqr, so make it single
        child1 := add_special_region_item (
            p_attribute_code           => g_single_row_attachment,
            p_plan_id                  => p_plan_id,
            p_prefix                 => p_prefix,
            p_region_code             => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);
    ELSE
        child1 := add_special_region_item (
            p_attribute_code           => g_multi_row_attachment,
            p_plan_id                  => p_plan_id,
            p_prefix                 => p_prefix,
            p_region_code            => l_region_code);
    JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                'contents', child1);
    END IF;

    l_saved := JDR_DOCBUILDER.SAVE;

    --if saved went ok and a previous, lower version document exists
    --then try to delete the previous document
    l_old_doc_name := g_jrad_region_path || construct_jrad_code(p_prefix, p_plan_id, p_jrad_doc_ver-1);
    IF (l_saved = jdr_docbuilder.SUCCESS) AND
       (p_jrad_doc_ver > 1) AND
       (jdr_docbuilder.documentExists(l_old_doc_name)) THEN
        jdr_docbuilder.deleteDocument(l_old_doc_name);
     END IF;

    --qa_ian_pkg.write_log('EQR Dumping Document(l_saved): "'||g_jrad_region_path || l_region_code||'"('||l_saved||')');
    --qa_ian_pkg.write_log(jdr_mds_internal.exportsingledocument(jdr_mds_internal.GETDOCUMENTID(g_jrad_region_path || l_region_code, 'DOCUMENT'), true));
    --qa_ian_pkg.write_log('EQR Done Dumping Document: "'||g_jrad_region_path || l_region_code||'"');

    -- dbms_output.put_line('-------------------------------------------');

EXCEPTION

    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END map_plan_for_eqr;


PROCEDURE map_plan_for_vqr (
    p_plan_id IN VARCHAR2,
    p_prefix IN VARCHAR2,
    p_jrad_doc_ver IN NUMBER) IS
--p_jrad_doc_ver cannot be null for now
--in future, pass null explicitly if necessary

    l_element_id     NUMBER;
    l_region_code    VARCHAR2(30);
    l_attribute_code VARCHAR2(30);
    l_old_doc_name   VARCHAR2(255);
    l_saved PLS_INTEGER;

    err_num      NUMBER;
    err_msg      VARCHAR2(100);
    elmt_counter         NUMBER;--parent-child results inquiry

    qa_jrad_doc JDR_DOCBUILDER.DOCUMENT := NULL;
    topLevel JDR_DOCBUILDER.ELEMENT := NULL;
    child1 JDR_DOCBUILDER.ELEMENT := NULL;

    CURSOR c IS
        SELECT char_id
        FROM qa_plan_chars
        WHERE plan_id = p_plan_id
        AND enabled_flag = 1
        ORDER BY PROMPT_SEQUENCE;

BEGIN

   --qa_ian_pkg.write_log('Entered VQR, p_prefix: "'||p_prefix||'", p_jrad_doc_ver: '||p_jrad_doc_ver);
   l_region_code := construct_jrad_code(p_prefix, p_plan_id, p_jrad_doc_ver);

   --dbms_output.put_line('Entered VQR, path: "'||g_jrad_region_path||l_region_code||'", p_jrad_doc_ver: '||p_jrad_doc_ver);

   qa_jrad_doc := JDR_DOCBUILDER.createDocument(g_jrad_region_path || l_region_code, 'en-US');

   topLevel := create_jrad_region (l_region_code, p_plan_id);
   JDR_DOCBUILDER.setTopLevelElement(qa_jrad_doc, topLevel);

   elmt_counter := 0; --parent-child results inquiry
                  --initialize counter
   OPEN c;
   LOOP
      FETCH c INTO l_element_id;
      EXIT WHEN c%NOTFOUND;

      elmt_counter := elmt_counter + 1; --parent-child
      --dbms_output.put_line('counter' || elmt_counter);
      l_attribute_code := construct_jrad_code(g_element_prefix,l_element_id);

      -- For Eam transactions if it is an action target then this element
      -- should not show up in VQR region.
      IF (instr(l_region_code, g_work_vqr_prefix) <> 0)
         OR  (instr(l_region_code, g_asset_vqr_prefix) <> 0)
	 --dgupta: Start R12 EAM Integration. Bug 4345492
         OR (instr(l_region_code, g_checkin_vqr_prefix) <> 0)
         OR (instr(l_region_code, g_checkout_vqr_prefix) <> 0)
	 --dgupta: End R12 EAM Integration. Bug 4345492
         OR  (instr(l_region_code, g_op_vqr_prefix) <> 0) THEN
         IF (NOT action_target_element(p_plan_id, l_element_id)) THEN
            child1 := create_region_item_for_vqr (
                    p_attribute_code           => l_attribute_code,
                    p_plan_id                  => p_plan_id,
                    p_prefix                   => p_prefix,
                    p_char_id                  => l_element_id);
            JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                    'contents', child1);
            --contents is the grouping name
         END IF;

      ELSE
         IF (instr(l_region_code, g_pc_vqr_prefix) <> 0 and
             elmt_counter > 4) THEN
            --if this is a parent child multi-row vqr screen
            EXIT; --exit the loop. Dont show more elements
         END IF; --parent-child

         child1 := create_region_item_for_vqr (
                p_attribute_code           => l_attribute_code,
                p_plan_id                  => p_plan_id,
                p_prefix                   => p_prefix,
                p_char_id                  => l_element_id);
         JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                 'contents', child1);
         --contents is the grouping name
      END IF;

   END LOOP;
   CLOSE c;

   IF (instr(l_region_code, g_pc_vqr_sin_prefix) = 0) THEN
      -- means if this is "not" single row parent vqr region
      child1 := add_special_region_item (p_attribute_code          => g_qa_created_by_attribute,
                                         p_plan_id                 => p_plan_id,
                                         p_prefix                  => p_prefix,
                                         p_region_code             => l_region_code);
      JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                              'contents', child1);

      child1 := add_special_region_item (p_attribute_code          => g_collection_id_attribute,
                                         p_plan_id                 => p_plan_id,
                                         p_prefix                  => p_prefix,
                                         p_region_code             => l_region_code);
      JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                              'contents', child1);

      child1 := add_special_region_item (p_attribute_code         => g_last_update_date_attribute,
                                         p_plan_id                => p_plan_id,
                                         p_prefix                 => p_prefix,
                                         p_region_code            => l_region_code);
      JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                              'contents', child1);

      -- added for attachments
      child1 := add_special_region_item (p_attribute_code         => g_multi_row_attachment,
                                         p_plan_id                => p_plan_id,
                                         p_prefix                 => p_prefix,
                                         p_region_code            => l_region_code);
      JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                              'contents', child1);

      -- added for update capability
      IF (instr(l_region_code, g_work_vqr_prefix) <> 0)
         OR (instr(l_region_code, g_asset_vqr_prefix) <> 0)
	 --dgupta: Start R12 EAM Integration. Bug 4345492
         OR (instr(l_region_code, g_checkin_vqr_prefix) <> 0)
         OR (instr(l_region_code, g_checkout_vqr_prefix) <> 0)
	 --dgupta: End R12 EAM Integration. Bug 4345492
         OR (instr(l_region_code, g_op_vqr_prefix) <> 0) THEN
         child1 := add_special_region_item (p_attribute_code         => g_update_attribute,
                                            p_plan_id                => p_plan_id,
                                            p_prefix                 => p_prefix,
                                            p_region_code            => l_region_code);
         JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                 'contents', child1);
      END IF;

      -- parent-child
      IF (instr(l_region_code, g_pc_vqr_prefix) <> 0) THEN
         --if this is a parent child results inquiry multi-row vqr screen
         child1 := add_special_region_item (p_attribute_code           => g_child_url_attribute,
                                            p_plan_id                  => p_plan_id,
                                            p_prefix                   => p_prefix,
                                            p_region_code              => l_region_code);
         JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                 'contents', child1);

         --below introduced for ui improvement
         --link to click and see all coll.elements for a vqr row
         -- (More Details Link)
         --one 'nice' feedback here is that make this call only if the
         --total no of collection elements is greater than 4
         --since this link is not needed otherwise
         --this additional check can be coded here...
         --
         child1 := add_special_region_item (p_attribute_code         => g_vqr_all_elements_url,
                                            p_plan_id                => p_plan_id,
                                            p_prefix                 => p_prefix,
                                            p_region_code            => l_region_code);
         JDR_DOCBUILDER.addChild(topLevel, JDR_DOCBUILDER.UI_NS,
                                 'contents', child1);
      END IF;
   END IF; --end "outer if" stmt: "not" single row parent vqr region

   l_saved := JDR_DOCBUILDER.SAVE;

   --if saved went ok and a previous, lower version document exists
   --then try to delete the previous document
   l_old_doc_name := g_jrad_region_path || construct_jrad_code(p_prefix, p_plan_id, p_jrad_doc_ver-1);
   IF (l_saved = jdr_docbuilder.SUCCESS) AND
      (p_jrad_doc_ver > 1) AND
      (jdr_docbuilder.documentExists(l_old_doc_name)) THEN
      jdr_docbuilder.deleteDocument(l_old_doc_name);
   END IF;

   --qa_ian_pkg.write_log('VQR Dumping Document(l_saved): "'||g_jrad_region_path || l_region_code||'"('||l_saved||')');
   --qa_ian_pkg.write_log(jdr_mds_internal.exportsingledocument(jdr_mds_internal.GETDOCUMENTID(g_jrad_region_path || l_region_code, 'DOCUMENT'), true));
   --qa_ian_pkg.write_log('VQR Done Dumping Document: "'||g_jrad_region_path || l_region_code||'"');

EXCEPTION

    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        --qa_ian_pkg.write_log('Encountered Error: SQLCODE('||SQLCODE||'), SQLERRM('||SQLERRM||')');

        -- dbms_output.put_line(err_msg);

END map_plan_for_vqr;


PROCEDURE map_plan(
    p_plan_id IN NUMBER,
    p_jrad_doc_ver IN NUMBER) IS  --default null defined in spec

        -- if p_jrad_doc_ver is passed in, then dont increment it
        -- use that as the version of the new document to be created

    -- Tracking Bug 4697145
    -- MOAC Upgrade feature.  This is not required.
    -- PRAGMA AUTONOMOUS_TRANSACTION;

    associated BOOLEAN DEFAULT FALSE;
    asset_mapped BOOLEAN DEFAULT FALSE;
    l_jrad_doc_ver NUMBER := NULL;

    --
    -- Tracking Bug 4697145
    -- MOAC Upgrade feature.
    -- Removed the FOR UPDATE clause.
    -- bso Sun Nov  6 16:52:53 PST 2005
    --
    CURSOR jrad_doc_ver_cur IS
        SELECT jrad_doc_ver
        FROM QA_PLANS
        WHERE PLAN_ID = p_plan_id;

BEGIN

    -- This procedure maps a collection plan to ak tables.
    --

   --qa_ian_pkg.init_log('jrad_t1');
   -- To avoid hitting the database multiple times for sysdate.
    g_sysdate := SYSDATE;
    --dbms_output.put_line('entered');

    IF (p_jrad_doc_ver IS NULL)THEN

       --qa_ian_pkg.write_log('p_jrad_doc_ver was NULL');
       OPEN jrad_doc_ver_cur;
        FETCH jrad_doc_ver_cur INTO l_jrad_doc_ver;
        CLOSE jrad_doc_ver_cur;

        IF l_jrad_doc_ver IS NULL THEN
           l_jrad_doc_ver := 1;
        ELSE
           l_jrad_doc_ver := l_jrad_doc_ver + 1; --increment
        END IF;
   ELSE
        --dont open the cursor since record has already been locked
        --by calling procedure, and increment has happened
        l_jrad_doc_ver := p_jrad_doc_ver;
   END IF;

    IF osp_self_service_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for osp');
        map_plan_for_eqr(p_plan_id, g_txn_osp_prefix ,l_jrad_doc_ver);
        map_plan_for_vqr (p_plan_id, g_osp_vqr_prefix ,l_jrad_doc_ver);

        --for project3 parent-child
        --find out all descendants and call map plan for eqr and vqr
        --for all these descendants
    END IF;

    IF shipment_self_service_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for shipment');
        map_plan_for_eqr(p_plan_id,  g_txn_ship_prefix ,l_jrad_doc_ver);

        map_plan_for_vqr (p_plan_id, g_ship_vqr_prefix ,l_jrad_doc_ver);

        --for project3 parent-child
        --find out all descendants and call map plan for eqr and vqr
        --for all these descendants
    END IF;

    IF customer_portal_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for OM');
        map_plan_for_vqr (p_plan_id, g_om_vqr_prefix ,l_jrad_doc_ver);
    END IF;

    IF eam_asset_plan(p_plan_id) THEN

        if not asset_mapped then
                map_plan_for_eqr(p_plan_id,  g_txn_asset_prefix ,l_jrad_doc_ver);
                map_plan_for_vqr (p_plan_id, g_asset_vqr_prefix ,l_jrad_doc_ver);
                asset_mapped := TRUE;
        end if;

    END IF;

--dgupta: Start R12 EAM Integration. Bug 4345492
    IF eam_checkin_plan(p_plan_id) THEN
         map_plan_for_eqr(p_plan_id,  g_checkin_eqr_prefix ,l_jrad_doc_ver);
         map_plan_for_vqr (p_plan_id, g_checkin_vqr_prefix ,l_jrad_doc_ver);

        if not asset_mapped then
                map_plan_for_eqr(p_plan_id,  g_txn_asset_prefix ,l_jrad_doc_ver);
                map_plan_for_vqr (p_plan_id, g_asset_vqr_prefix ,l_jrad_doc_ver);
                asset_mapped := TRUE;
        end if;

    END IF;


    IF eam_checkout_plan(p_plan_id) THEN
	    map_plan_for_eqr(p_plan_id,  g_checkout_eqr_prefix ,l_jrad_doc_ver);
        map_plan_for_vqr (p_plan_id, g_checkout_vqr_prefix ,l_jrad_doc_ver);

	if not asset_mapped then
		        map_plan_for_eqr(p_plan_id,  g_txn_asset_prefix ,l_jrad_doc_ver);
                map_plan_for_vqr (p_plan_id, g_asset_vqr_prefix ,l_jrad_doc_ver);
                asset_mapped := TRUE;
        end if;

    END IF;
--dgupta: End R12 EAM Integration. Bug 4345492

    IF eam_work_order_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for EAM');
        map_plan_for_eqr(p_plan_id, g_txn_work_prefix ,l_jrad_doc_ver);
        map_plan_for_vqr (p_plan_id, g_work_vqr_prefix ,l_jrad_doc_ver);

        if not asset_mapped then
                map_plan_for_eqr(p_plan_id, g_txn_asset_prefix ,l_jrad_doc_ver);
                map_plan_for_vqr (p_plan_id,  g_asset_vqr_prefix ,l_jrad_doc_ver);
                asset_mapped := TRUE;
        end if;

    END IF;

    IF eam_op_comp_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for EAM');
        map_plan_for_eqr(p_plan_id, g_txn_op_prefix ,l_jrad_doc_ver);
        map_plan_for_vqr (p_plan_id, g_op_vqr_prefix ,l_jrad_doc_ver);

        if not asset_mapped then
                map_plan_for_eqr(p_plan_id, g_txn_asset_prefix ,l_jrad_doc_ver);
                map_plan_for_vqr (p_plan_id,  g_asset_vqr_prefix ,l_jrad_doc_ver);
                asset_mapped := TRUE;
        end if;

    END IF;

    -- Parent-Child
    IF parent_child_plan(p_plan_id) THEN
        map_plan_for_vqr (p_plan_id, g_pc_vqr_prefix ,l_jrad_doc_ver);
        map_plan_for_vqr (p_plan_id, g_pc_vqr_sin_prefix ,l_jrad_doc_ver);

        --below info when we do project3 parent-child
        --this is called from qa_ss_parent_child_pkg
        --in that call check for isp and make appropriate map calls
    END IF;

    IF (p_jrad_doc_ver IS NULL) THEN
        UPDATE QA_PLANS
        SET JRAD_DOC_VER = l_jrad_doc_ver
        WHERE PLAN_ID = p_plan_id;
   ELSE
        NULL; --dont update here...calling procedure will update
              --since calling procedure has a lock
   END IF;
   --qa_ian_pkg.close_log;

   -- Tracking Bug 4697145
   -- MOAC Upgrade feature.  This is not required.
   -- COMMIT; --commit the autonomous txn, so all locks are released

END map_plan;

PROCEDURE map_on_demand (p_plan_id IN NUMBER,
                         x_jrad_doc_ver OUT NOCOPY NUMBER)

IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_jrad_doc_ver NUMBER;
    l_jrad_upgrade_ver NUMBER;
    l_seed_ver NUMBER;

    --
    -- Tracking Bug 4697145
    -- MOAC Upgrade feature.
    -- Rewritten cursors in inline SQL for convenience.
    -- bso Sun Nov  6 17:07:45 PST 2005
    --

BEGIN
    --Bug 2946779
    --reset the message table so that stale errors aren't
    --thrown by the checkErrors on this procedure
    --ilawler Thu May  8 11:19:27 2003
    fnd_msg_pub.initialize;

    --
    -- Tracking Bug 4697145
    -- MOAC Upgrade feature.
    -- bso Sun Nov  6 17:34:31 PST 2005
    --
    SELECT jrad_upgrade_ver
    INTO   l_jrad_upgrade_ver
    FROM   qa_plans
    WHERE  plan_id = p_plan_id
    FOR UPDATE;

    SELECT jrad_upgrade_ver
    INTO   l_seed_ver
    FROM   qa_plans
    WHERE  plan_id = qa_ss_const.JRAD_UPGRADE_PLAN;

    IF l_jrad_upgrade_ver IS NULL OR
        l_jrad_upgrade_ver < l_seed_ver THEN
        qa_ssqr_jrad_pkg.map_plan(p_plan_id);
        qa_ssqr_jrad_pkg.jrad_upgraded(p_plan_id);
        map_plan(p_plan_id);
    END IF;

    --
    -- Since map_plan may be called above and may change
    -- jrad_doc_ver number, now re-check Jrad Doc Ver
    --
    SELECT jrad_doc_ver
    INTO   l_jrad_doc_ver
    FROM   qa_plans
    WHERE  plan_id = p_plan_id;

    IF l_jrad_doc_ver IS NULL THEN
        map_plan(p_plan_id);
    END IF;

    x_jrad_doc_ver := nvl(l_jrad_doc_ver, 1); --set out variable

    COMMIT;
END map_on_demand;


FUNCTION context_element (element_id IN NUMBER, txn_number IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy NUMBER;

    CURSOR c IS
        SELECT 1
        FROM   qa_txn_collection_triggers qtct
        WHERE  qtct.transaction_number = txn_number
        AND    qtct.collection_trigger_id = element_id;

BEGIN

    -- This function determines if collection element is a context element
    -- given a transaction number.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END context_element;


END qa_jrad_pkg;


/
