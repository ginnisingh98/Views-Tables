--------------------------------------------------------
--  DDL for Package Body QA_AK_MAPPING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_AK_MAPPING_API" AS
/* $Header: qltakmpb.plb 120.1 2005/06/10 17:27:54 appldev  $ */


TYPE ParentArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_sysdate DATE;


FUNCTION osp_self_service_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

    CURSOR c IS
        SELECT 1
	FROM qa_plan_transactions
	WHERE plan_id = p_plan_id
	AND transaction_number = qa_ss_const.ss_outside_processing_txn
	AND enabled_flag = 1;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for osp self service transactions or not.
    -- If it is then it returns true else it returns false.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;
    RETURN result;

END osp_self_service_plan;


FUNCTION shipment_self_service_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy  NUMBER;

    CURSOR c IS
        SELECT 1
	FROM qa_plan_transactions
	WHERE plan_id = p_plan_id
	AND transaction_number = qa_ss_const.ss_shipments_txn
	AND enabled_flag = 1;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for shipment self service transactions or not.
    -- If it is then it returns true else it returns false.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;
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

    CURSOR c IS
        SELECT 1
	FROM qa_plan_transactions
	WHERE plan_id = p_plan_id
	AND transaction_number = 31
	AND enabled_flag = 1;

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for EAM work order or not. If it is then it returns true
    -- else it returns false.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END eam_work_order_plan;



FUNCTION eam_asset_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
	FROM qa_plan_transactions
	WHERE plan_id = p_plan_id
	AND transaction_number = 32
	AND enabled_flag = 1;

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for EAM asset query or not. If it is then it returns true
    -- else it returns false.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END eam_asset_plan;



FUNCTION eam_op_comp_plan (p_plan_id IN NUMBER)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
	FROM qa_plan_transactions
	WHERE plan_id = p_plan_id
	AND transaction_number = 33
	AND enabled_flag = 1;

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This subroutine determines if a plan has been associated
    -- and enabled for EAM op comp or not. If it is then it returns true
    -- else it returns false.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END eam_op_comp_plan;



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


FUNCTION construct_ak_code (p_appendix  IN VARCHAR2, p_id IN VARCHAR2)
    RETURN VARCHAR2 IS

BEGIN

   -- The function is the standard way to compute attribute and
   -- region codes.

   RETURN (p_appendix ||p_id);

END construct_ak_code;


FUNCTION retrieve_id (p_code IN VARCHAR2)
    RETURN NUMBER IS

    pos NUMBER;
    id  VARCHAR2(100);

BEGIN

   -- The function is the standard way to retrive id given the code

   IF (INSTR(p_code, g_element_appendix) <> 0) THEN
       pos := length(g_element_appendix)+1;

   ELSIF (INSTR(p_code, g_osp_vqr_appendix) <> 0) THEN
       pos := length(g_osp_vqr_appendix)+1;
   ELSE
       pos := length(g_txn_osp_appendix)+1;
   END IF;

   id := substr(p_code, pos, length(p_code));

   RETURN to_number(id);

END retrieve_id;


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


FUNCTION get_plan_char_sequence (p_plan_id IN NUMBER, p_element_id IN NUMBER)
    RETURN NUMBER IS

    CURSOR c IS
        SELECT prompt_sequence
        FROM qa_plan_chars
	WHERE plan_id = p_plan_id
	AND char_id = p_element_id;

    sequence qa_plan_chars.prompt_sequence%TYPE;

BEGIN

   -- This functions retrieves the plan char display sequence.

    OPEN c;
    FETCH c INTO sequence;
    CLOSE c;

    RETURN sequence;

END get_plan_char_sequence;


FUNCTION get_special_label (p_appendix IN VARCHAR2)
    RETURN VARCHAR2 IS

    label VARCHAR2(30);

BEGIN

    -- For some hardocded columns such as "Created By", "Colleciton"
    -- and "Last Update Date" we need to retrieve the right label
    -- keeping translation in mind.

    IF (p_appendix = g_qa_created_by_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_CREATED_BY');
    ELSIF (p_appendix = g_collection_id_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_COLLECTION');
    ELSIF (p_appendix = g_last_update_date_attribute) THEN
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
    column_name := replace(column_name, 'COMMENT', 'Comment');
    column_name := replace(column_name, 'SEQUENCE', 'Sequence');

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

    IF p_data_type = 1 THEN
	return 'VARCHAR2';
    ELSIF p_data_type = 2 THEN
	return 'NUMBER';
    ELSE
	return 'DATE';
    END IF;

END convert_data_type;


FUNCTION convert_flag (p_flag IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    -- In Quality all the flags are numeric, meaning a value of 1 or 2
    -- is used to indicate if the flag is on or off.  In AK however,
    -- it is a character that describes if the flag is on or off.
    -- This routine was written to convert the Quality flags to AK.

    IF p_flag = 1 THEN
	return 'Y';
    ELSIF p_flag = 2 THEN
	return 'N';
    END IF;

END convert_flag;


FUNCTION compute_item_style (p_appendix IN VARCHAR2, p_element_id IN NUMBER)
    RETURN VARCHAR2 IS

    l_txn_number NUMBER;

BEGIN

    -- For Quality's self service application we need to know what
    -- item style to render the UI.  If the element is a context
    -- element then the item style must be HIDDEN, but for the rest
    -- of them it should be text input.  This distiction is made here.


    IF (p_appendix = g_txn_osp_appendix) THEN
        l_txn_number := qa_ss_const.ss_outside_processing_txn;

    ELSIF (p_appendix = g_txn_ship_appendix) THEN
        l_txn_number := qa_ss_const.ss_shipments_txn;

    ELSIF (p_appendix = g_txn_work_appendix) THEN
        l_txn_number := 31;

    ELSIF (p_appendix = g_txn_asset_appendix) THEN
        l_txn_number := 32;

    ELSIF (p_appendix = g_txn_op_appendix) THEN
        l_txn_number := 33;

    END IF;

    IF context_element(p_element_id, l_txn_number) THEN
	return 'HIDDEN';
    ELSE
	return 'TEXT_INPUT';
    END IF;

END compute_item_style;


FUNCTION query_criteria (p_appendix IN VARCHAR2, p_element_id IN NUMBER)
    RETURN BOOLEAN IS

    CURSOR c (p_txn_number NUMBER) IS
        SELECT 'TRUE'
        FROM qa_txn_collection_triggers
        WHERE transaction_number = p_txn_number
        AND search_flag = 1
        AND collection_trigger_id = p_element_id;

    l_txn_number 	NUMBER;
    dummy 		VARCHAR2(10);
    result 		BOOLEAN;

BEGIN

    -- This procecure determines if a colleciton element is a part of the
    -- VQR where clause.  If it is then it is a query criteria for vqr.
    -- In case of OM nothing is a query query criteria, hence always
    -- return FALSE

    IF (instr(p_appendix, g_om_vqr_appendix) <> 0) THEN
        RETURN FALSE;
    END IF;

    -- parent-child
    -- In case of parentchild no hidden fields, hence always
    -- return FALSE
    IF ((instr(p_appendix, g_pc_vqr_appendix) <> 0) OR
	   (instr(p_appendix, g_pc_vqr_sin_appendix) <> 0 )) THEN
        RETURN FALSE;
    END IF;

    IF ( instr(p_appendix, g_osp_vqr_appendix) <> 0 ) THEN
        -- appendix passed has 'QAVQROSP' in it
        l_txn_number := qa_ss_const.ss_outside_processing_txn;

    ELSIF ( instr(p_appendix, g_ship_vqr_appendix) <> 0 ) THEN
        -- appendix passed has 'QAVQRSHP' in it
        l_txn_number := qa_ss_const.ss_shipments_txn;

    ELSIF ( instr(p_appendix, g_work_vqr_appendix) <> 0 ) THEN
        -- appendix passed has 'QAVQRWORK' in it
        l_txn_number := 31;

    ELSIF ( instr(p_appendix, g_asset_vqr_appendix) <> 0 ) THEN
        -- appendix passed has 'QAVQRASSET' in it
        l_txn_number := 32;

    ELSIF ( instr(p_appendix, g_op_vqr_appendix) <> 0 ) THEN
        -- appendix passed has 'QAVQROP' in it
        l_txn_number := 33;
    END IF;

    OPEN c(l_txn_number);
    FETCH c into dummy;
    result := c%FOUND;
    CLOSE c;
    RETURN result;

END query_criteria;


FUNCTION get_display_sequence (p_region_code IN VARCHAR2,
    p_region_application_id IN NUMBER)
    RETURN NUMBER IS

    max_display_sequence NUMBER DEFAULT 0;

    CURSOR c IS
        SELECT MAX(display_sequence)
	FROM ak_region_items
	WHERE region_code = p_region_code
	AND region_application_id = p_region_application_id;

BEGIN

    -- display_sequence is a not null and unique field in ak_region_items.
    -- When adding region items dynamically there is a need to know the next
    -- available display sequence.  This function computes that.

    OPEN c;
    FETCH c INTO max_display_sequence;
    CLOSE c;

    IF (max_display_sequence IS NOT NULL) THEN
	RETURN max_display_sequence + 10;
    ELSE
	RETURN 10;
    END IF;

END get_display_sequence;


FUNCTION get_text_display_sequence (p_region_code IN VARCHAR2,
    p_region_application_id IN NUMBER)
    RETURN NUMBER IS

    max_display_sequence NUMBER DEFAULT 0;

    CURSOR c IS
        SELECT MAX(display_sequence)
	FROM ak_region_items
	WHERE region_code = p_region_code
	AND region_application_id = p_region_application_id
	AND item_style <> 'HIDDEN';

BEGIN

    -- display_sequence is a not null and unique field in ak_region_items.
    -- When adding region items dynamically there is a need to know the next
    -- available display sequence.  However, in case of special region items
    -- there is a little complexity.  There is a ATG bug that we have to work
    -- around, which mandates that all hidden elements are addded at the end.
    -- Since the special elements for vqr can be 'TEXT', we must add these
    -- before the hidden items.

    OPEN c;
    FETCH c INTO max_display_sequence;
    CLOSE c;

    IF (max_display_sequence IS NOT NULL) THEN
	RETURN max_display_sequence + 10;
    ELSE
	RETURN 10;
    END IF;

END get_text_display_sequence;


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

    ELSIF p_char_id = qa_ss_const.lot_number THEN
	x_parents(1) := qa_ss_const.item;
	x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.serial_number THEN
	x_parents(1) := qa_ss_const.lot_number;
	x_parents(2) := qa_ss_const.item;
	x_parents(3) := qa_ss_const.production_line;

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
    --dgupta: End R12 EAM Integration. Bug 4345492

    END IF;

END get_dependencies;


FUNCTION action_target_element (p_plan_id IN NUMBER, p_char_id IN NUMBER)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM DUAL
        WHERE p_char_id
        IN
            (SELECT assigned_char_id
             FROM qa_plan_char_actions
             WHERE plan_char_action_trigger_id
             IN
                 (SELECT plan_char_action_trigger_id
                  FROM qa_plan_char_action_triggers
                  WHERE plan_id = p_plan_id));

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


FUNCTION get_eqr_header_region_code (p_code VARCHAR2)
    RETURN VARCHAR2 IS

    l_header_region_code VARCHAR2(30);

BEGIN

    -- A value of zero is false 1 is true for INSTR comparison

    IF (instr(p_code, g_txn_work_appendix) <> 0)
        OR (instr(p_code, g_txn_asset_appendix) <> 0)
        OR (instr(p_code, g_txn_op_appendix) <> 0)
    THEN
        l_header_region_code := g_eam_eqr_hdr_region;
    ELSE
        l_header_region_code := g_eqr_top_region;
    END IF;

    RETURN l_header_region_code;

END get_eqr_header_region_code;


FUNCTION get_vqr_header_region_code (p_code VARCHAR2)
    RETURN VARCHAR2 IS

    l_header_region_code VARCHAR2(30);

BEGIN

    -- A value of zero is false 1 is true for INSTR comparison

    --parent-child
    IF ((instr(p_code, g_pc_vqr_appendix) <> 0)
	OR (instr(p_code, g_pc_vqr_sin_appendix) <> 0)) THEN
	l_header_region_code := g_pc_vqr_hdr_region;
    ELSIF (instr(p_code, g_work_vqr_appendix) <> 0)
          OR (instr(p_code, g_op_vqr_appendix) <> 0) THEN
        l_header_region_code := g_eam_vqr_work_hdr_region;
    ELSIF (instr(p_code, g_asset_vqr_appendix) <> 0) THEN
        l_header_region_code := g_eam_vqr_asset_hdr_region;
    ELSE
        l_header_region_code := g_vqr_top_region;
    END IF;

    RETURN l_header_region_code;

END get_vqr_header_region_code;


FUNCTION get_region_style (p_code VARCHAR2)
    RETURN VARCHAR2 IS

    l_region_style VARCHAR2(30);

BEGIN

    -- A value of zero is false 1 is true for INSTR comparison

    IF (instr(p_code, g_txn_work_appendix) <> 0)
        OR (instr(p_code, g_txn_asset_appendix) <> 0)
        OR (instr(p_code, g_txn_op_appendix) <> 0)
    THEN
        l_region_style := 'DEFAULT_SINGLE_COLUMN';
    ELSIF (instr(p_code, g_pc_vqr_sin_appendix) <> 0) --parent-child
    THEN
	l_region_style := 'DEFAULT_DOUBLE_COLUMN';--ui improvement
    ELSE
        l_region_style := 'TABLE';
    END IF;

    RETURN l_region_style;

END get_region_style;


FUNCTION attribute_exists ( p_attribute_application_id IN NUMBER,
    p_attribute_code IN VARCHAR2)
    RETURN BOOLEAN IS

    l_row_exists VARCHAR2(4);

    CURSOR c IS
	SELECT 'TRUE'
	FROM ak_attributes
  	WHERE attribute_application_id = p_attribute_application_id
  	AND attribute_code = p_attribute_code;

BEGIN

    -- This function determines if an attribute exists.

    OPEN c;
    FETCH c INTO l_row_exists;
    CLOSE c;

    IF (l_row_exists = 'TRUE') THEN
	RETURN TRUE;
    ELSE
	RETURN FALSE;
    END IF;

END attribute_exists;


PROCEDURE delete_attribute_for_plan (
    p_attribute_code IN VARCHAR2,
    p_attribute_application_id IN NUMBER) IS

BEGIN

    -- Deletes an attribute (corresponds to a collection plan)
    -- if the combination already exists.

    IF attribute_exists(p_attribute_application_id, p_attribute_code) THEN
       -- dbms_output.put_line('Deleting Element : ' || p_attribute_code);
       ak_attributes_pkg.delete_row(p_attribute_application_id,
	   p_attribute_code);
    END IF;

END delete_attribute_for_plan;


PROCEDURE delete_element_mapping (
    p_char_id IN NUMBER,
    p_attribute_application_id IN NUMBER) IS

    l_attribute_code VARCHAR2(30);

BEGIN

    -- Deletes an attribute (corresponds to a collection element)
    -- If it exists.

    l_attribute_code := construct_ak_code(g_element_appendix, p_char_id);

    IF attribute_exists(p_attribute_application_id, l_attribute_code) THEN

       -- dbms_output.put_line('Deleting Element : ' || l_attribute_code);
       ak_attributes_pkg.delete_row(p_attribute_application_id,
	   l_attribute_code);
    END IF;

END delete_element_mapping;


PROCEDURE delete_region (
    p_region_application_id IN NUMBER,
    p_region_code IN VARCHAR2) IS

    l_row_exists VARCHAR2(6);
    dummy VARCHAR2(6);

    CURSOR c IS
	SELECT 'TRUE'
	FROM ak_regions
  	WHERE region_application_id = p_region_application_id
  	AND region_code = p_region_code;

BEGIN

    -- Deletes a region (corresponds to a collection plan)
    -- If it exists.

    OPEN c;
    FETCH c INTO l_row_exists;

    CLOSE c;

    IF (l_row_exists = 'TRUE') THEN
       -- dbms_output.put_line('Deleting Region  : ' || p_region_code);
       ak_regions_pkg.delete_row(p_region_application_id,
	   p_region_code);
    END IF;

END delete_region;


PROCEDURE delete_a_lov_relation (
    p_region_application_id IN NUMBER,
    p_region_code IN VARCHAR2,
    p_attribute_application_id IN NUMBER,
    p_attribute_code IN VARCHAR2,
    p_lov_region_appl_id IN NUMBER,
    p_lov_region_code IN VARCHAR2,
    p_lov_attribute_appl_id IN NUMBER,
    p_lov_attribute_code IN VARCHAR2,
    p_base_attribute_appl_id IN NUMBER,
    p_base_attribute_code IN VARCHAR2,
    p_direction_flag	IN VARCHAR2) IS

    l_row_exists VARCHAR2(4);
    err_num	 NUMBER;
    err_msg	 VARCHAR2(100);

    CURSOR c IS
	SELECT 'TRUE'
	FROM ak_region_lov_relations
	WHERE region_application_id = p_region_application_id
  	AND region_code = p_region_code
  	AND attribute_application_id = p_attribute_application_id
  	AND attribute_code = p_attribute_code
  	AND lov_region_appl_id = p_lov_region_appl_id
  	AND lov_region_code = p_lov_region_code
  	AND lov_attribute_appl_id = p_lov_attribute_appl_id
  	AND lov_attribute_code = p_lov_attribute_code
  	AND base_attribute_appl_id = p_base_attribute_appl_id
  	AND base_attribute_code = p_base_attribute_code
  	AND direction_flag = p_direction_flag ;

BEGIN

    -- Deletes an individual row from lov relations table.
    -- Here the region item corresponds to a collection plan element.

    OPEN c;
    FETCH c INTO l_row_exists;
    CLOSE c;

    IF (l_row_exists = 'TRUE') THEN
       -- dbms_output.put_line('Deleting LOV Rel : ' || p_region_code|| ' ' ||
       --    p_base_attribute_code);

	AK_LOV_RELATIONS_PKG.DELETE_ROW (
  	    X_REGION_APPLICATION_ID 	=> p_region_application_id,
  	    X_REGION_CODE 	 	=> p_region_code,
            X_ATTRIBUTE_APPLICATION_ID 	=> p_attribute_application_id,
            X_ATTRIBUTE_CODE 		=> p_attribute_code,
            X_LOV_REGION_APPL_ID 	=> p_lov_region_appl_id,
            X_LOV_REGION_CODE 		=> p_lov_region_code,
            X_LOV_ATTRIBUTE_APPL_ID 	=> p_lov_attribute_appl_id,
            X_LOV_ATTRIBUTE_CODE 	=> p_lov_attribute_code,
            X_BASE_ATTRIBUTE_APPL_ID 	=> p_base_attribute_appl_id,
            X_BASE_ATTRIBUTE_CODE 	=> p_base_attribute_code,
            X_DIRECTION_FLAG 		=> p_direction_flag);

    END IF;


EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END delete_a_lov_relation;


PROCEDURE delete_lov_relations (
    p_char_id IN NUMBER,
    p_region_application_id IN NUMBER,
    p_region_code IN VARCHAR2,
    p_attribute_application_id IN NUMBER,
    p_attribute_code IN VARCHAR2,
    p_lov_region_appl_id IN NUMBER,
    p_lov_region_code IN VARCHAR2) IS

    l_lov_attribute_code 	VARCHAR2(30);
    l_base_attribute_code 	VARCHAR2(30);
    l_parents			ParentArray;

BEGIN

    -- Deletes an lov relations for a region item.
    -- Here the region item corresponds to a collection plan element.

    delete_a_lov_relation(
  	p_region_application_id 	=> p_region_application_id,
  	p_region_code 	 		=> p_region_code,
        p_attribute_application_id 	=> p_attribute_application_id,
        p_attribute_code 		=> p_attribute_code,
        p_lov_region_appl_id 		=> p_lov_region_appl_id,
        p_lov_region_code 		=> p_lov_region_code,
        p_lov_attribute_appl_id 	=> g_application_id,
        p_lov_attribute_code 		=> g_lov_attribute_code,
        p_base_attribute_appl_id 	=> p_attribute_application_id,
        p_base_attribute_code 		=> p_attribute_code,
        p_direction_flag 		=> 'CRITERIA');

    delete_a_lov_relation(
  	p_region_application_id 	=> p_region_application_id,
  	p_region_code 	 		=> p_region_code,
        p_attribute_application_id 	=> p_attribute_application_id,
        p_attribute_code 		=> p_attribute_code,
        p_lov_region_appl_id 		=> p_lov_region_appl_id,
        p_lov_region_code 		=> p_lov_region_code,
        p_lov_attribute_appl_id 	=> g_application_id,
        p_lov_attribute_code 		=> g_lov_attribute_code,
        p_base_attribute_appl_id 	=> p_attribute_application_id,
        p_base_attribute_code 		=> p_attribute_code,
        p_direction_flag 		=> 'RESULT');

    delete_a_lov_relation(
  	p_region_application_id 	=> p_region_application_id,
  	p_region_code 	 		=> p_region_code,
        p_attribute_application_id 	=> p_attribute_application_id,
        p_attribute_code 		=> p_attribute_code,
        p_lov_region_appl_id 		=> p_lov_region_appl_id,
        p_lov_region_code 		=> p_lov_region_code,
        p_lov_attribute_appl_id 	=> g_application_id,
        p_lov_attribute_code 		=> g_lov_attribute_org_id,
        p_base_attribute_appl_id 	=> p_attribute_application_id,
        p_base_attribute_code 		=> g_org_id_attribute,
        p_direction_flag 		=> 'PASSIVE_CRITERIA');

    delete_a_lov_relation(
  	p_region_application_id 	=> p_region_application_id,
  	p_region_code 	 		=> p_region_code,
        p_attribute_application_id 	=> p_attribute_application_id,
        p_attribute_code 		=> p_attribute_code,
        p_lov_region_appl_id 		=> p_lov_region_appl_id,
        p_lov_region_code 		=> p_lov_region_code,
        p_lov_attribute_appl_id 	=> g_application_id,
        p_lov_attribute_code 		=> g_lov_attribute_plan_id,
        p_base_attribute_appl_id 	=> p_attribute_application_id,
        p_base_attribute_code 		=> g_plan_id_attribute,
        p_direction_flag 		=> 'PASSIVE_CRITERIA');

    get_dependencies(p_char_id, l_parents);

    FOR i IN 1..l_parents.COUNT LOOP

	l_lov_attribute_code := g_lov_attribute_dependency || to_char(i);
 	l_base_attribute_code := construct_ak_code(g_element_appendix,
	    l_parents(i));

	-- dbms_output.put_line('Deleting Lov Rel : ' ||
        --    l_lov_attribute_Code || ' ' || l_base_attribute_code);

        delete_a_lov_relation(
  	    p_region_application_id 	=> p_region_application_id,
  	    p_region_code 	 	=> p_region_code,
            p_attribute_application_id 	=> p_attribute_application_id,
            p_attribute_code 		=> p_attribute_code,
            p_lov_region_appl_id 	=> p_lov_region_appl_id,
            p_lov_region_code 		=> p_lov_region_code,
            p_lov_attribute_appl_id 	=> g_application_id,
            p_lov_attribute_code 	=> l_lov_attribute_code,
            p_base_attribute_appl_id 	=> p_attribute_application_id,
            p_base_attribute_code 	=> l_base_attribute_code,
            p_direction_flag 		=> 'PASSIVE_CRITERIA');

    END LOOP;


END delete_lov_relations;


PROCEDURE delete_region_item (
    p_region_application_id IN NUMBER,
    p_region_code IN VARCHAR2,
    p_attribute_application_id IN NUMBER,
    p_attribute_code IN VARCHAR2) IS

    l_row_exists VARCHAR2(4);
    l_char_id	 NUMBER;

    CURSOR c IS
	SELECT 'TRUE'
	FROM ak_region_items
  	WHERE region_application_id = p_region_application_id
  	AND region_code = p_region_code
  	AND attribute_application_id = p_attribute_application_id
  	AND attribute_code = p_attribute_code;

BEGIN

    -- Deletes a region item if the combination already exists.
    -- Here the region item corresponds to a collection plan element.

    OPEN c;
    FETCH c INTO l_row_exists;
    CLOSE c;


    IF (l_row_exists = 'TRUE') THEN

       -- dbms_output.put_line('Deleting Item    : ' || p_region_code|| ' ' ||
       --    p_attribute_code);

       ak_region_items_pkg.delete_row(
	   p_region_application_id,
	   p_region_code,
	   p_attribute_application_id,
	   p_attribute_code);

       -- IF (INSTR(p_attribute_code, g_special_appendix) = 0) THEN

       IF (INSTR(p_attribute_code, g_element_appendix) = 1) THEN

	  l_char_id := retrieve_id(p_attribute_code);

          delete_lov_relations(
	      P_CHAR_ID				=> l_char_id,
  	      P_REGION_APPLICATION_ID 		=> g_application_id,
  	      P_REGION_CODE 	 		=> p_region_code,
              P_ATTRIBUTE_APPLICATION_ID 	=> g_application_id,
              P_ATTRIBUTE_CODE 			=> p_attribute_code,
              P_LOV_REGION_APPL_ID 		=> g_application_id,
              P_LOV_REGION_CODE			=> g_lov_region);

	END IF;

    END IF;

END delete_region_item;


PROCEDURE get_element_values (p_char_id IN NUMBER,
    l_label_length OUT  NOCOPY NUMBER,
    l_data_type OUT NOCOPY VARCHAR2,
    l_item_style OUT NOCOPY VARCHAR2,
    l_name OUT NOCOPY VARCHAR2,
    l_label OUT	NOCOPY VARCHAR2,
    l_default_value OUT NOCOPY VARCHAR2,
    l_created_by OUT NOCOPY NUMBER,
    l_last_updated_by OUT NOCOPY NUMBER,
    l_last_update_login OUT NOCOPY NUMBER) IS

    l_qa_chars_row   qa_chars%ROWTYPE;

    CURSOR c IS
	SELECT * from qa_chars
	WHERE char_id = p_char_id;

BEGIN

    -- When mapping an element you need to know certain attributes
    -- of a collection element to be able to put in the correct
    -- information in ak tables.  This function retrieves those
    -- relevant information.

    OPEN c;
    FETCH c INTO l_qa_chars_row;
    CLOSE c;

    l_data_type 	:= convert_data_type(l_qa_chars_row.datatype);
    l_label_length  	:= length(l_qa_chars_row.prompt);
    l_name 		:= l_qa_chars_row.name;
    l_label		:= l_qa_chars_row.prompt;
    l_item_style	:= 'TEXT_INPUT';
    l_default_value 	:= l_qa_chars_row.default_value;
    l_created_by	:= l_qa_chars_row.created_by;
    l_last_updated_by	:= l_qa_chars_row.last_updated_by;
    l_last_update_login := nvl(l_qa_chars_row.last_update_login,
        l_last_updated_by);

END get_element_values;


PROCEDURE get_plan_values (p_plan_id IN NUMBER,
    l_label_length OUT  NOCOPY NUMBER,
    l_data_type OUT NOCOPY VARCHAR2,
    l_item_style OUT NOCOPY VARCHAR2,
    l_name OUT NOCOPY VARCHAR2,
    l_label OUT	NOCOPY VARCHAR2,
    l_created_by OUT NOCOPY NUMBER,
    l_last_updated_by OUT NOCOPY NUMBER,
    l_last_update_login OUT NOCOPY NUMBER) IS

    l_qa_plans_row   qa_plans%ROWTYPE;

    CURSOR c IS
	SELECT * from qa_plans
	WHERE plan_id = p_plan_id;

BEGIN

    -- For every collection plan we create not only a region but also
    -- ak attribute.  When creating this ak_attribute there is a need
    -- to know certain attributes of this plan so that correct information
    -- canbe put in the ak tables.  This function retrieves those
    -- relevant information.

    OPEN c;
    FETCH c INTO l_qa_plans_row;
    CLOSE c;

    l_data_type 	:= 'VARCHAR2';
    l_label_length  	:= length(l_qa_plans_row.name);
    l_name 		:= l_qa_plans_row.name;
    l_label		:= l_qa_plans_row.name;
    l_item_style	:= 'NESTED_REGION';
    l_created_by	:= l_qa_plans_row.created_by;
    l_last_updated_by	:= l_qa_plans_row.last_updated_by;
    l_last_update_login := l_qa_plans_row.last_update_login;

END get_plan_values;


PROCEDURE map_element (
    p_char_id IN NUMBER,
    p_attribute_application_id IN NUMBER,
    p_appendix IN VARCHAR2) IS

    l_attribute_code 	VARCHAR2(30);
    l_row_id	     	VARCHAR2(30);
    l_label_length   	NUMBER;
    l_data_type      	VARCHAR2(30);
    l_item_style     	VARCHAR2(30);
    l_name 	     	VARCHAR2(30);
    l_label	     	VARCHAR2(30);
    l_varchar2_default	VARCHAR2(150) DEFAULT null;
    l_default_value	VARCHAR2(150);
    l_number_default	NUMBER DEFAULT null;
    l_date_default	DATE DEFAULT null;
    l_created_by     	NUMBER;
    l_last_updated_by 	NUMBER;
    l_last_update_login NUMBER;

BEGIN

    -- This procedure does whatever is necessary to map a collection
    -- element to ak entity called attribute.

    l_attribute_code := construct_ak_code(p_appendix, p_char_id);

    delete_element_mapping (p_char_id, p_attribute_application_id);

    get_element_values(p_char_id,  l_label_length, l_data_type,
        l_item_style, l_name, l_label, l_default_value, l_created_by,
        l_last_updated_by, l_last_update_login);

    IF (l_data_type = 'VARCHAR2') THEN
	l_varchar2_default := l_default_value;
    ELSIF (l_data_type = 'NUMBER') THEN
	l_number_default := to_number(l_default_value);
    ELSE
	l_date_default := qltdate.canon_to_date(l_default_value);
    END IF;

    ak_attributes_pkg.insert_row (
        X_ROWID                        => l_row_id,
        X_ATTRIBUTE_APPLICATION_ID     => p_attribute_application_id,
        X_ATTRIBUTE_CODE               => l_attribute_code,
        X_ATTRIBUTE_LABEL_LENGTH       => l_label_length,
        X_ATTRIBUTE_VALUE_LENGTH       => 150,
        X_BOLD                         => 'N',
        X_ITALIC                       => 'N',
        X_UPPER_CASE_FLAG              => 'N',
        X_VERTICAL_ALIGNMENT           => 'TOP',
        X_HORIZONTAL_ALIGNMENT         => 'LEFT' ,
        X_DEFAULT_VALUE_VARCHAR2       => l_varchar2_default,
        X_DEFAULT_VALUE_NUMBER         => l_number_default,
        X_DEFAULT_VALUE_DATE           => l_date_default,
        X_LOV_REGION_CODE              => null,
        X_LOV_REGION_APPLICATION_ID    => null,
        X_DATA_TYPE                    => l_data_type,
        X_DISPLAY_HEIGHT               => 1,
        X_ITEM_STYLE                   => l_item_style,
        X_CSS_CLASS_NAME               => null,
        X_CSS_LABEL_CLASS_NAME         => null,
        X_POPLIST_VIEWOBJECT           => null,
        X_POPLIST_DISPLAY_ATTRIBUTE    => null,
        X_POPLIST_VALUE_ATTRIBUTE      => null,
        X_ATTRIBUTE_CATEGORY           => null,
        X_ATTRIBUTE1                   => null,
        X_ATTRIBUTE2                   => null,
        X_ATTRIBUTE3                   => null,
        X_ATTRIBUTE4                   => null,
        X_ATTRIBUTE5                   => null,
        X_ATTRIBUTE6                   => null,
        X_ATTRIBUTE7                   => null,
        X_ATTRIBUTE8                   => null,
        X_ATTRIBUTE9                   => null,
        X_ATTRIBUTE10                  => null,
        X_ATTRIBUTE11                  => null,
        X_ATTRIBUTE12                  => null,
        X_ATTRIBUTE13                  => null,
        X_ATTRIBUTE14                  => null,
        X_ATTRIBUTE15                  => null,
        X_NAME                         => l_name,
        X_ATTRIBUTE_LABEL_LONG         => l_label,
        X_DESCRIPTION                  => 'Quality Attribute',
        X_CREATION_DATE                => g_sysdate,
        X_CREATED_BY                   => l_created_by,
        X_LAST_UPDATE_DATE             => g_sysdate,
        X_LAST_UPDATED_BY  	       => l_last_updated_by,
        X_LAST_UPDATE_LOGIN            => l_last_update_login);


    -- dbms_output.put_line('Adding Element   : ' || l_attribute_code);

END map_element;


PROCEDURE add_attribute_for_plan (
    p_plan_id IN NUMBER,
    p_attribute_application_id IN NUMBER,
    p_appendix IN VARCHAR2) IS

    l_attribute_code 	VARCHAR2(30);
    l_row_id	     	VARCHAR2(30);
    l_label_length   	NUMBER;
    l_data_type      	VARCHAR2(30);
    l_item_style     	VARCHAR2(30);
    l_name 	     	VARCHAR2(30);
    l_label	     	VARCHAR2(30);
    l_varchar2_default	VARCHAR2(150) DEFAULT null;
    l_default_value	VARCHAR2(150);
    l_number_default	NUMBER DEFAULT null;
    l_date_default	DATE DEFAULT null;
    l_created_by     	NUMBER;
    l_last_updated_by 	NUMBER;
    l_last_update_login NUMBER;

BEGIN

    -- For every collection plan we create not only a region but also
    -- ak attribute to be able to refer to it from regions higher
    -- in hierarchy.

    l_attribute_code := construct_ak_code(p_appendix, p_plan_id);

    delete_attribute_for_plan (l_attribute_code, p_attribute_application_id);

    get_plan_values(p_plan_id,  l_label_length, l_data_type,
            l_item_style, l_name, l_label, l_created_by, l_last_updated_by,
    	     l_last_update_login);

    IF (l_data_type = 'VARCHAR2') THEN
	l_varchar2_default := l_default_value;
    ELSIF (l_data_type = 'NUMBER') THEN
	l_number_default := to_number(l_default_value);
    ELSE
	l_date_default := qltdate.canon_to_date(l_default_value);
    END IF;

    ak_attributes_pkg.insert_row (
        X_ROWID                        => l_row_id,
        X_ATTRIBUTE_APPLICATION_ID     => p_attribute_application_id,
        X_ATTRIBUTE_CODE               => l_attribute_code,
        X_ATTRIBUTE_LABEL_LENGTH       => l_label_length,
        X_ATTRIBUTE_VALUE_LENGTH       => 150,
        X_BOLD                         => 'N',
        X_ITALIC                       => 'N',
        X_UPPER_CASE_FLAG              => 'N',
        X_VERTICAL_ALIGNMENT           => 'TOP',
        X_HORIZONTAL_ALIGNMENT         => 'LEFT' ,
        X_DEFAULT_VALUE_VARCHAR2       => l_varchar2_default,
        X_DEFAULT_VALUE_NUMBER         => l_number_default,
        X_DEFAULT_VALUE_DATE           => l_date_default,
        X_LOV_REGION_CODE              => null,
        X_LOV_REGION_APPLICATION_ID    => null,
        X_DATA_TYPE                    => l_data_type,
        X_DISPLAY_HEIGHT               => 1,
        X_ITEM_STYLE                   => l_item_style,
        X_CSS_CLASS_NAME               => null,
        X_CSS_LABEL_CLASS_NAME         => null,
        X_POPLIST_VIEWOBJECT           => null,
        X_POPLIST_DISPLAY_ATTRIBUTE    => null,
        X_POPLIST_VALUE_ATTRIBUTE      => null,
        X_ATTRIBUTE_CATEGORY           => null,
        X_ATTRIBUTE1                   => null,
        X_ATTRIBUTE2                   => null,
        X_ATTRIBUTE3                   => null,
        X_ATTRIBUTE4                   => null,
        X_ATTRIBUTE5                   => null,
        X_ATTRIBUTE6                   => null,
        X_ATTRIBUTE7                   => null,
        X_ATTRIBUTE8                   => null,
        X_ATTRIBUTE9                   => null,
        X_ATTRIBUTE10                  => null,
        X_ATTRIBUTE11                  => null,
        X_ATTRIBUTE12                  => null,
        X_ATTRIBUTE13                  => null,
        X_ATTRIBUTE14                  => null,
        X_ATTRIBUTE15                  => null,
        X_NAME                         => l_name,
        X_ATTRIBUTE_LABEL_LONG         => l_label,
        X_DESCRIPTION                  => 'Quality Attribute',
        X_CREATION_DATE                => g_sysdate,
        X_CREATED_BY                   => l_created_by,
        X_LAST_UPDATE_DATE             => g_sysdate,
        X_LAST_UPDATED_BY  	       => l_last_updated_by,
        X_LAST_UPDATE_LOGIN            => l_last_update_login);

    -- dbms_output.put_line('Adding Element   : ' || l_attribute_code);

END add_attribute_for_plan;


PROCEDURE add_ak_region (
    p_plan_id IN NUMBER,
    p_region_application_id IN NUMBER,
    p_appendix IN VARCHAR2) IS

    l_region_code 	VARCHAR2(30);
    l_region_style 	VARCHAR2(30);
    l_row_id	     	VARCHAR2(30);
    l_qa_plans_row	qa_plans%ROWTYPE;

    CURSOR c IS
	SELECT * from qa_plans
	WHERE plan_id = p_plan_id;

BEGIN

    -- This procedure creates an entry in ak regions table for a collection
    -- plan in Quality.

    OPEN c;
    FETCH c INTO l_qa_plans_row;
    CLOSE c;

    l_region_code := construct_ak_code(p_appendix, p_plan_id);
    delete_region (p_region_application_id, l_region_code);

    l_region_style := get_region_style(l_region_code);

    AK_REGIONS_PKG.insert_row (
        X_ROWID                        => l_row_id,
        X_REGION_APPLICATION_ID        => p_region_application_id,
        X_REGION_CODE                  => l_region_code,
        X_DATABASE_OBJECT_NAME         => 'ICX_PROMPTS',
        X_REGION_STYLE                 => l_region_style,
        X_NUM_COLUMNS                  => null,
        X_ICX_CUSTOM_CALL              => null ,
        X_NAME                         => l_qa_plans_row.name,
        X_DESCRIPTION                  => l_qa_plans_row.description,
        X_REGION_DEFAULTING_API_PKG    => null,
        X_REGION_DEFAULTING_API_PROC   => null,
        X_REGION_VALIDATION_API_PKG    => null,
        X_REGION_VALIDATION_API_PROC   => null,
        X_APPL_MODULE_OBJECT_TYPE      => null,
        X_NUM_ROWS_DISPLAY             => null,
        X_REGION_OBJECT_TYPE           => null,
        X_IMAGE_FILE_NAME              => null,
        X_ISFORM_FLAG                  => 'N',
        X_HELP_TARGET                  => null,
        X_STYLE_SHEET_FILENAME	       => null,
	X_VERSION		       => null,
	X_APPLICATIONMODULE_USAGE_NAME => null,
	X_ADD_INDEXED_CHILDREN	       => 'Y',
        X_STATEFUL_FLAG                => null, --5.5
        X_FUNCTION_NAME                => null, --5.5
        X_CHILDREN_VIEW_USAGE_NAME     => null, --5.5
        X_SEARCH_PANEL                 => null, --5.5
        X_ADVANCED_SEARCH_PANEL        => null, --5.5
        X_CUSTOMIZE_PANEL              => null, --5.5
        X_DEFAULT_SEARCH_PANEL         => null, --5.5
        X_RESULTS_BASED_SEARCH         => null, --5.5
        X_DISPLAY_GRAPH_TABLE          => null, --5.5
        X_CREATION_DATE                => g_sysdate,
        X_CREATED_BY                   => l_qa_plans_row.created_by,
        X_LAST_UPDATE_DATE             => g_sysdate,
        X_LAST_UPDATED_BY              => l_qa_plans_row.last_updated_by,
        X_LAST_UPDATE_LOGIN            => l_qa_plans_row.last_update_login,
        X_ATTRIBUTE_CATEGORY           => null,
        X_ATTRIBUTE1                   => null,
        X_ATTRIBUTE2                   => null,
        X_ATTRIBUTE3                   => null,
        X_ATTRIBUTE4                   => null,
        X_ATTRIBUTE5                   => null,
        X_ATTRIBUTE6                   => null,
        X_ATTRIBUTE7                   => null,
        X_ATTRIBUTE8                   => null,
        X_ATTRIBUTE9                   => null,
        X_ATTRIBUTE10                  => null,
        X_ATTRIBUTE11                  => null,
        X_ATTRIBUTE12                  => null,
        X_ATTRIBUTE13                  => null,
        X_ATTRIBUTE14                  => null,
        X_ATTRIBUTE15                  => null);

    -- dbms_output.put_line('Adding Region    : ' || l_region_code);

END add_ak_region;


PROCEDURE add_lov_relations (
    p_plan_id			IN NUMBER,
    p_region_code		IN VARCHAR2,
    p_char_id			IN NUMBER,
    p_attribute_code		IN VARCHAR2,
    p_region_application_id 	IN NUMBER,
    p_attribute_application_id 	IN NUMBER,
    p_lov_region_appl_id 	IN NUMBER,
    p_lov_region_code 		IN VARCHAR2) IS


    err_num			NUMBER;
    err_msg			VARCHAR2(100);

    l_row_id			VARCHAR2(30);
    l_region_code		VARCHAR2(30);
    l_attribute_code		VARCHAR2(30);
    l_lov_attribute_code 	VARCHAR2(30);
    l_base_attribute_code 	VARCHAR2(30);
    l_parents			ParentArray;
    l_qa_plans_row		qa_plans%ROWTYPE;

    CURSOR c IS
	SELECT * from qa_plans
	WHERE plan_id = p_plan_id;

BEGIN

    -- This function adds lov relations for a region item.
    -- Here the region item corresponds to a collection plan element.

    OPEN c;
    FETCH c INTO l_qa_plans_row;
    CLOSE c;

    AK_LOV_RELATIONS_PKG.INSERT_ROW (
  	X_ROWID 			=> l_row_id,
  	X_REGION_APPLICATION_ID 	=> p_region_application_id,
  	X_REGION_CODE 	 		=> p_region_code,
        X_ATTRIBUTE_APPLICATION_ID 	=> p_attribute_application_id,
        X_ATTRIBUTE_CODE 		=> p_attribute_code,
        X_LOV_REGION_APPL_ID 		=> p_lov_region_appl_id,
        X_LOV_REGION_CODE 		=> g_lov_region,
        X_LOV_ATTRIBUTE_APPL_ID 	=> g_application_id,
        X_LOV_ATTRIBUTE_CODE 		=> g_lov_attribute_code,
        X_BASE_ATTRIBUTE_APPL_ID 	=> p_attribute_application_id,
        X_BASE_ATTRIBUTE_CODE 		=> p_attribute_code,
        X_DIRECTION_FLAG 		=> 'CRITERIA',
        X_REQUIRED_FLAG 		=> 'N',
        X_LAST_UPDATE_DATE 		=> l_qa_plans_row.last_update_date,
        X_LAST_UPDATED_BY 		=> l_qa_plans_row.last_updated_by,
        X_CREATION_DATE 		=> l_qa_plans_row.creation_date,
        X_CREATED_BY 			=> l_qa_plans_row.created_by,
        X_LAST_UPDATE_LOGIN 		=> l_qa_plans_row.last_update_login);


    AK_LOV_RELATIONS_PKG.INSERT_ROW (
  	X_ROWID 			=> l_row_id,
  	X_REGION_APPLICATION_ID 	=> p_region_application_id,
  	X_REGION_CODE 	 		=> p_region_code,
        X_ATTRIBUTE_APPLICATION_ID 	=> p_attribute_application_id,
        X_ATTRIBUTE_CODE 		=> p_attribute_code,
        X_LOV_REGION_APPL_ID 		=> p_lov_region_appl_id,
        X_LOV_REGION_CODE 		=> g_lov_region,
        X_LOV_ATTRIBUTE_APPL_ID 	=> g_application_id,
        X_LOV_ATTRIBUTE_CODE 		=> g_lov_attribute_code,
        X_BASE_ATTRIBUTE_APPL_ID 	=> p_attribute_application_id,
        X_BASE_ATTRIBUTE_CODE 		=> p_attribute_code,
        X_DIRECTION_FLAG 		=> 'RESULT',
        X_REQUIRED_FLAG 		=> 'N',
        X_LAST_UPDATE_DATE 		=> l_qa_plans_row.last_update_date,
        X_LAST_UPDATED_BY 		=> l_qa_plans_row.last_updated_by,
        X_CREATION_DATE 		=> l_qa_plans_row.creation_date,
        X_CREATED_BY 			=> l_qa_plans_row.created_by,
        X_LAST_UPDATE_LOGIN 		=> l_qa_plans_row.last_update_login);


    AK_LOV_RELATIONS_PKG.INSERT_ROW (
  	X_ROWID 			=> l_row_id,
  	X_REGION_APPLICATION_ID 	=> p_region_application_id,
  	X_REGION_CODE 	 		=> p_region_code,
        X_ATTRIBUTE_APPLICATION_ID 	=> p_attribute_application_id,
        X_ATTRIBUTE_CODE 		=> p_attribute_code,
        X_LOV_REGION_APPL_ID 		=> p_lov_region_appl_id,
        X_LOV_REGION_CODE 		=> p_lov_region_code,
        X_LOV_ATTRIBUTE_APPL_ID 	=> g_application_id,
        X_LOV_ATTRIBUTE_CODE 		=> g_lov_attribute_org_id,
        X_BASE_ATTRIBUTE_APPL_ID 	=> p_attribute_application_id,
        X_BASE_ATTRIBUTE_CODE 		=> g_org_id_attribute,
        X_DIRECTION_FLAG 		=> 'PASSIVE_CRITERIA',
        X_REQUIRED_FLAG 		=> 'N',
        X_LAST_UPDATE_DATE 		=> l_qa_plans_row.last_update_date,
        X_LAST_UPDATED_BY 		=> l_qa_plans_row.last_updated_by,
        X_CREATION_DATE 		=> l_qa_plans_row.creation_date,
        X_CREATED_BY 			=> l_qa_plans_row.created_by,
        X_LAST_UPDATE_LOGIN 		=> l_qa_plans_row.last_update_login);


    AK_LOV_RELATIONS_PKG.INSERT_ROW (
  	X_ROWID 			=> l_row_id,
  	X_REGION_APPLICATION_ID 	=> p_region_application_id,
  	X_REGION_CODE 	 		=> p_region_code,
        X_ATTRIBUTE_APPLICATION_ID 	=> p_attribute_application_id,
        X_ATTRIBUTE_CODE 		=> p_attribute_code,
        X_LOV_REGION_APPL_ID 		=> p_lov_region_appl_id,
        X_LOV_REGION_CODE 		=> p_lov_region_code,
        X_LOV_ATTRIBUTE_APPL_ID 	=> g_application_id,
        X_LOV_ATTRIBUTE_CODE 		=> g_lov_attribute_plan_id,
        X_BASE_ATTRIBUTE_APPL_ID 	=> p_attribute_application_id,
        X_BASE_ATTRIBUTE_CODE 		=> g_plan_id_attribute,
        X_DIRECTION_FLAG 		=> 'PASSIVE_CRITERIA',
        X_REQUIRED_FLAG 		=> 'N',
        X_LAST_UPDATE_DATE 		=> l_qa_plans_row.last_update_date,
        X_LAST_UPDATED_BY 		=> l_qa_plans_row.last_updated_by,
        X_CREATION_DATE 		=> l_qa_plans_row.creation_date,
        X_CREATED_BY 			=> l_qa_plans_row.created_by,
        X_LAST_UPDATE_LOGIN 		=> l_qa_plans_row.last_update_login);

    get_dependencies(p_char_id, l_parents);

    FOR i IN 1..l_parents.COUNT LOOP

	l_lov_attribute_code := g_lov_attribute_dependency || to_char(i);
 	l_base_attribute_code := construct_ak_code(g_element_appendix,
	    l_parents(i));

   	AK_LOV_RELATIONS_PKG.INSERT_ROW (
  	    X_ROWID 			=> l_row_id,
  	    X_REGION_APPLICATION_ID 	=> p_region_application_id,
  	    X_REGION_CODE 	 	=> p_region_code,
            X_ATTRIBUTE_APPLICATION_ID 	=> p_attribute_application_id,
            X_ATTRIBUTE_CODE 		=> p_attribute_code,
            X_LOV_REGION_APPL_ID 	=> p_lov_region_appl_id,
            X_LOV_REGION_CODE 		=> p_lov_region_code,
            X_LOV_ATTRIBUTE_APPL_ID 	=> g_application_id,
            X_LOV_ATTRIBUTE_CODE 	=> l_lov_attribute_code,
            X_BASE_ATTRIBUTE_APPL_ID 	=> p_attribute_application_id,
            X_BASE_ATTRIBUTE_CODE 	=> l_base_attribute_code,
            X_DIRECTION_FLAG 		=> 'PASSIVE_CRITERIA',
            X_REQUIRED_FLAG 		=> 'N',
            X_LAST_UPDATE_DATE 		=> l_qa_plans_row.last_update_date,
            X_LAST_UPDATED_BY 		=> l_qa_plans_row.last_updated_by,
            X_CREATION_DATE 		=> l_qa_plans_row.creation_date,
            X_CREATED_BY 		=> l_qa_plans_row.created_by,
            X_LAST_UPDATE_LOGIN 	=> l_qa_plans_row.last_update_login);

    END LOOP;

    -- dbms_output.put_line('Adding LOV rel   : ');

EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END add_lov_relations;


PROCEDURE add_region_item_for_eqr (
    p_char_id IN NUMBER,
    p_attribute_application_id IN NUMBER,
    p_plan_id IN NUMBER,
    p_region_application_id IN NUMBER,
    p_appendix IN VARCHAR2) IS

    l_row_id	     	 	VARCHAR2(30);
    l_region_code	 	VARCHAR2(30);
    l_attribute_code	 	VARCHAR2(30);
    l_lov_region_code	 	VARCHAR2(30) DEFAULT NULL;
    l_char_name			VARCHAR2(30);
    l_vo_attribute_name		VARCHAR2(30);
    l_display_flag	 	VARCHAR2(1);
    l_required_flag	 	VARCHAR2(1);
    l_item_style		VARCHAR2(30);
    l_row_exists 		VARCHAR2(4);
    l_data_type			VARCHAR2(30);
    l_varchar2_default		VARCHAR2(150) DEFAULT null;
    l_number_default		NUMBER DEFAULT null;
    l_date_default		DATE DEFAULT null;
    l_qa_plan_chars_row 	qa_plan_chars%ROWTYPE;
    l_qa_chars_row 		qa_chars%ROWTYPE;
    l_display_sequence		NUMBER;

    err_num			NUMBER;
    err_msg			VARCHAR2(100);

    CURSOR c1 IS
	SELECT *
 	FROM qa_plan_chars
	WHERE plan_id = p_plan_id
	AND   char_id = p_char_id;

    CURSOR c2 IS
	SELECT *
	FROM qa_chars
	WHERE char_id = p_char_id;

BEGIN

    -- This procedure adds a region item to the plan's eqr region.

    OPEN c1;
    FETCH c1 INTO l_qa_plan_chars_row;
    CLOSE c1;

    OPEN c2;
    FETCH c2 INTO l_qa_chars_row;
    CLOSE c2;

    l_region_code := construct_ak_code(p_appendix, p_plan_id);
    l_attribute_code := construct_ak_code(g_element_appendix, p_char_id);

    -- As a part of our upgrade strategy, we want to find out
    -- if the attribute exists in ak_attributes if it does not,
    -- we should create it.

    IF NOT attribute_exists(p_attribute_application_id, l_attribute_code) THEN

	-- dbms_output.put_line('Recognized region item as not existing');
    	qa_ak_mapping_api.map_element(
            p_char_id => p_char_id,
    	    p_attribute_application_id => g_application_id,
	    p_appendix => qa_ak_mapping_api.g_element_appendix);

    END IF;

    l_vo_attribute_name := get_vo_attribute_name(p_char_id, p_plan_id);

    l_display_flag  := convert_flag(l_qa_plan_chars_row.displayed_flag);

    l_item_style    := compute_item_style(p_appendix, p_char_id);

    l_required_flag := convert_flag(l_qa_plan_chars_row.mandatory_flag);

    IF  l_item_style = 'TEXT_INPUT' AND
        (qa_plan_element_api.values_exist(p_plan_id, p_char_id)
         OR qa_plan_element_api.sql_validation_exists(p_char_id)
         OR qa_chars_api.has_hardcoded_lov(p_char_id)) THEN

        -- dbms_output.put_line('Has Lov          : ' || l_region_code || ' '
	--    || l_attribute_code);

	l_lov_region_code := g_lov_region;

    END IF;

    l_data_type := convert_data_type(l_qa_chars_row.datatype);

    IF (l_data_type = 'VARCHAR2') THEN
	l_varchar2_default := l_qa_plan_chars_row.default_value;
    ELSIF (l_data_type = 'NUMBER') THEN
	l_number_default := to_number(l_qa_plan_chars_row.default_value);
    ELSE
	l_date_default := qltdate.any_to_date(l_qa_plan_chars_row.default_value);
    END IF;

    -- work around needed for a ATG bug
    -- hidden items should be at the very end of all region items in a region.

    IF  (l_item_style = 'HIDDEN') THEN
	l_display_sequence := l_qa_plan_chars_row.prompt_sequence +
             g_hidden_element_increment;
    ELSE
	l_display_sequence :=l_qa_plan_chars_row.prompt_sequence;
    END IF;

    AK_REGION_ITEMS_PKG.insert_row (
        X_ROWID                        => l_row_id,
        X_REGION_APPLICATION_ID        => p_region_application_id,
        X_REGION_CODE                  => l_region_code,
        X_ATTRIBUTE_APPLICATION_ID     => p_attribute_application_id,
        X_ATTRIBUTE_CODE               => l_attribute_code,
        X_DISPLAY_SEQUENCE             => l_display_sequence,
        X_NODE_DISPLAY_FLAG            => l_display_flag,
        X_NODE_QUERY_FLAG              => 'N',
        X_ATTRIBUTE_LABEL_LENGTH       => length(l_qa_chars_row.prompt),
        X_BOLD                         => 'N',
        X_ITALIC                       => 'N',
        X_VERTICAL_ALIGNMENT           => 'TOP',
        X_HORIZONTAL_ALIGNMENT         => 'LEFT',
        X_ITEM_STYLE                   => l_item_style,
        X_OBJECT_ATTRIBUTE_FLAG        => 'N',
        X_ATTRIBUTE_LABEL_LONG         => l_qa_chars_row.prompt,
        X_DESCRIPTION                  => l_qa_chars_row.name,
        X_SECURITY_CODE                => null,
        X_UPDATE_FLAG                  => 'Y',
        X_REQUIRED_FLAG                => l_required_flag,
        X_DISPLAY_VALUE_LENGTH         => l_qa_chars_row.display_length,
        X_LOV_REGION_APPLICATION_ID    => g_application_id,
        X_LOV_REGION_CODE              => l_lov_region_code,
        X_LOV_FOREIGN_KEY_NAME         => null,
        X_LOV_ATTRIBUTE_APPLICATION_ID => null,
        X_LOV_ATTRIBUTE_CODE           => null,
        X_LOV_DEFAULT_FLAG             => null,
        X_REGION_DEFAULTING_API_PKG    => null,
        X_REGION_DEFAULTING_API_PROC   => null,
        X_REGION_VALIDATION_API_PKG    => null,
        X_REGION_VALIDATION_API_PROC   => null,
        X_ORDER_SEQUENCE               => null,
        X_ORDER_DIRECTION              => null,
        X_DEFAULT_VALUE_VARCHAR2       => l_varchar2_default,
        X_DEFAULT_VALUE_NUMBER         => l_number_default,
        X_DEFAULT_VALUE_DATE           => l_date_default,
        X_ITEM_NAME                    => l_attribute_code,
        X_DISPLAY_HEIGHT               => 1,
        X_SUBMIT                       => 'N',
        X_ENCRYPT                      => 'N',
        X_VIEW_USAGE_NAME              => g_eqr_view_usage_name,
        X_VIEW_ATTRIBUTE_NAME          => l_vo_attribute_name,
        X_CSS_CLASS_NAME               => null,
        X_CSS_LABEL_CLASS_NAME         => null,
        X_URL                          => null,
        X_POPLIST_VIEWOBJECT           => null,
        X_POPLIST_DISPLAY_ATTRIBUTE    => null,
        X_POPLIST_VALUE_ATTRIBUTE      => null,
        X_IMAGE_FILE_NAME              => null,
        X_NESTED_REGION_CODE           => null,
        X_NESTED_REGION_APPL_ID        => null,
        X_MENU_NAME                    => null,
	X_FLEXFIELD_NAME 	       => null,
  	X_FLEXFIELD_APPLICATION_ID     => null,
  	X_TABULAR_FUNCTION_CODE        => null,
  	X_TIP_TYPE		       => null,
  	X_TIP_MESSAGE_NAME             => null,
  	X_TIP_MESSAGE_APPLICATION_ID   => null,
        X_ENTITY_ID		       => null,
        X_FLEX_SEGMENT_LIST	       => null,
 	X_ANCHOR		       => null,
	X_POPLIST_VIEW_USAGE_NAME      => null,
        X_USER_CUSTOMIZABLE            => null, --5.5
        X_SORTBY_VIEW_ATTRIBUTE_NAME   => null,	--5.5
        X_CREATION_DATE                => g_sysdate,
        X_CREATED_BY                   => l_qa_plan_chars_row.created_by,
        X_LAST_UPDATE_DATE             => g_sysdate,
        X_LAST_UPDATED_BY              => l_qa_plan_chars_row.last_updated_by,
        X_LAST_UPDATE_LOGIN            => l_qa_plan_chars_row.last_updated_by,
        X_ATTRIBUTE_CATEGORY           => null,
        X_ATTRIBUTE1                   => null,
        X_ATTRIBUTE2                   => null,
        X_ATTRIBUTE3                   => null,
        X_ATTRIBUTE4                   => null,
        X_ATTRIBUTE5                   => null,
        X_ATTRIBUTE6                   => null,
        X_ATTRIBUTE7                   => null,
        X_ATTRIBUTE8                   => null,
        X_ATTRIBUTE9                   => null,
        X_ATTRIBUTE10                  => null,
        X_ATTRIBUTE11                  => null,
        X_ATTRIBUTE12                  => null,
        X_ATTRIBUTE13                  => null,
        X_ATTRIBUTE14                  => null,
        X_ATTRIBUTE15                  => null);

    -- At this point, if the element has lovs then we must determine
    -- what are its dependency and populate ak_region_lov_relations
    -- with this information.

    IF (l_lov_region_code IS NOT NULL) THEN

 	add_lov_relations(
            P_PLAN_ID			=> p_plan_id,
	    P_CHAR_ID			=> p_char_id,
  	    P_REGION_APPLICATION_ID 	=> g_application_id,
  	    P_REGION_CODE 	 	=> l_region_code,
            P_ATTRIBUTE_APPLICATION_ID 	=> g_application_id,
            P_ATTRIBUTE_CODE 		=> l_attribute_code,
            P_LOV_REGION_APPL_ID 	=> g_application_id,
            P_LOV_REGION_CODE 		=> g_lov_region);

    END IF;

    -- dbms_output.put_line('Adding Item      : ' || l_region_code || ' ' ||
    --    l_attribute_code);

EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END add_region_item_for_eqr;


PROCEDURE add_region_item_for_vqr (
    p_attribute_code           IN VARCHAR2,
    p_attribute_application_id IN NUMBER,
    p_plan_id		       IN VARCHAR2,
    p_region_application_id    IN NUMBER,
    p_appendix 		       IN VARCHAR2) IS

    l_row_id	     	 	VARCHAR2(30);
    l_element_id	     	NUMBER;
    l_region_code	 	VARCHAR2(30);
    l_nested_region_code	VARCHAR2(30) DEFAULT null;
    l_item_style		VARCHAR2(30) DEFAULT 'TEXT';
    l_display_sequence		NUMBER;
    l_display_flag		VARCHAR2(1)  DEFAULT 'Y';
    l_update_flag		VARCHAR2(1)  DEFAULT 'Y';
    l_query_flag		VARCHAR2(1)  DEFAULT 'N';
    l_view_attribute_name	VARCHAR2(30) DEFAULT NULL;
    l_view_usage_name		VARCHAR2(30) DEFAULT NULL;
    l_label_long		VARCHAR2(30) DEFAULT NULL;

    err_num			NUMBER;
    err_msg			VARCHAR2(100);

BEGIN

    -- This procedure adds a region item to the plan's vqr region.

    l_region_code := construct_ak_code(p_appendix, p_plan_id);
    l_view_usage_name := g_vqr_view_usage_name;
    -- parent-child for header single row region only
        IF (instr(p_appendix, g_pc_vqr_sin_appendix) <> 0)
	THEN
		l_view_usage_name := 'ParentResultVO';
	END IF;

    l_nested_region_code := p_attribute_code;
    l_update_flag := 'N';
    l_element_id := retrieve_id(p_attribute_code);

    -- As a part of our upgrade strategy, we want to find out
    -- if the attribute exists in ak_attributes if it does not,
    -- we should create it.

    IF NOT attribute_exists(p_attribute_application_id, p_attribute_code) THEN

	-- dbms_output.put_line('Recognized region item as not existing');
    	qa_ak_mapping_api.map_element(
            p_char_id => l_element_id,
    	    p_attribute_application_id => g_application_id,
	    p_appendix => qa_ak_mapping_api.g_element_appendix);

    END IF;

    l_view_attribute_name := qa_core_pkg.get_result_column_name (
         l_element_id, p_plan_id);

    l_label_long := get_label(p_plan_id, l_element_id);
    l_display_sequence := get_plan_char_sequence(p_plan_id, l_element_id);

    -- item_style is HIDDEN and if this element is a context element
    -- and is a query criteria (search flag is 1) for vqr

    IF (query_criteria (l_region_code, l_element_id)) THEN
         l_item_style := 'HIDDEN';
         l_display_sequence := l_display_sequence +
                 g_hidden_element_increment;
    END IF;

    IF (instr(l_region_code, g_work_vqr_appendix) <> 0)
        OR (instr(l_region_code, g_asset_vqr_appendix) <> 0)
        OR (instr(l_region_code, g_op_vqr_appendix) <> 0) THEN
        l_query_flag := 'Y';
    END IF;


    AK_REGION_ITEMS_PKG.insert_row (
        X_ROWID                        => l_row_id,
        X_REGION_APPLICATION_ID        => p_region_application_id,
        X_REGION_CODE                  => l_region_code,
        X_ATTRIBUTE_APPLICATION_ID     => p_attribute_application_id,
        X_ATTRIBUTE_CODE               => p_attribute_code,
        X_DISPLAY_SEQUENCE             => l_display_sequence,
        X_NODE_DISPLAY_FLAG            => l_display_flag,
        X_NODE_QUERY_FLAG              => l_query_flag,
        X_ATTRIBUTE_LABEL_LENGTH       => 13,
        X_BOLD                         => 'N',
        X_ITALIC                       => 'N',
        X_VERTICAL_ALIGNMENT           => 'TOP',
        X_HORIZONTAL_ALIGNMENT         => 'LEFT',
        X_ITEM_STYLE                   => l_item_style,
        X_OBJECT_ATTRIBUTE_FLAG        => 'N',
        X_ATTRIBUTE_LABEL_LONG         => l_label_long,
        X_DESCRIPTION                  => 'Quality Column',
        X_SECURITY_CODE                => null,
        X_UPDATE_FLAG                  => l_update_flag,
        X_REQUIRED_FLAG                => 'N',
        X_DISPLAY_VALUE_LENGTH         => 0,
        X_LOV_REGION_APPLICATION_ID    => null,
        X_LOV_REGION_CODE              => null,
        X_LOV_FOREIGN_KEY_NAME         => null,
        X_LOV_ATTRIBUTE_APPLICATION_ID => null,
        X_LOV_ATTRIBUTE_CODE           => null,
        X_LOV_DEFAULT_FLAG             => null,
        X_REGION_DEFAULTING_API_PKG    => null,
        X_REGION_DEFAULTING_API_PROC   => null,
        X_REGION_VALIDATION_API_PKG    => null,
        X_REGION_VALIDATION_API_PROC   => null,
        X_ORDER_SEQUENCE               => null,
        X_ORDER_DIRECTION              => null,
        X_DEFAULT_VALUE_VARCHAR2       => null,
        X_DEFAULT_VALUE_NUMBER         => null,
        X_DEFAULT_VALUE_DATE           => null,
        X_ITEM_NAME                    => p_attribute_code,
        X_DISPLAY_HEIGHT               => 1,
        X_SUBMIT                       => 'N',
        X_ENCRYPT                      => 'N',
        X_VIEW_USAGE_NAME              => l_view_usage_name,
        X_VIEW_ATTRIBUTE_NAME          => l_view_attribute_name,
        X_CSS_CLASS_NAME               => null,
        X_CSS_LABEL_CLASS_NAME         => null,
        X_URL                          => null,
        X_POPLIST_VIEWOBJECT           => null,
        X_POPLIST_DISPLAY_ATTRIBUTE    => null,
        X_POPLIST_VALUE_ATTRIBUTE      => null,
        X_IMAGE_FILE_NAME              => null,
        X_NESTED_REGION_CODE           => l_nested_region_code,
        X_NESTED_REGION_APPL_ID        => p_region_application_id,
        X_MENU_NAME                    => null,
	X_FLEXFIELD_NAME 	       => null,
  	X_FLEXFIELD_APPLICATION_ID     => null,
  	X_TABULAR_FUNCTION_CODE        => null,
  	X_TIP_TYPE		       => null,
  	X_TIP_MESSAGE_NAME             => null,
  	X_TIP_MESSAGE_APPLICATION_ID   => null,
        X_ENTITY_ID		       => null,
        X_FLEX_SEGMENT_LIST	       => null,
 	X_ANCHOR		       => null,
	X_POPLIST_VIEW_USAGE_NAME      => null,
        X_USER_CUSTOMIZABLE            => null, --5.5
        X_SORTBY_VIEW_ATTRIBUTE_NAME   => null,	--5.5
        X_CREATION_DATE                => g_sysdate,
        X_CREATED_BY                   => 1,
        X_LAST_UPDATE_DATE             => g_sysdate,
        X_LAST_UPDATED_BY              => 1,
        X_LAST_UPDATE_LOGIN            => 1,
        X_ATTRIBUTE_CATEGORY           => null,
        X_ATTRIBUTE1                   => null,
        X_ATTRIBUTE2                   => null,
        X_ATTRIBUTE3                   => null,
        X_ATTRIBUTE4                   => null,
        X_ATTRIBUTE5                   => null,
        X_ATTRIBUTE6                   => null,
        X_ATTRIBUTE7                   => null,
        X_ATTRIBUTE8                   => null,
        X_ATTRIBUTE9                   => null,
        X_ATTRIBUTE10                  => null,
        X_ATTRIBUTE11                  => null,
        X_ATTRIBUTE12                  => null,
        X_ATTRIBUTE13                  => null,
        X_ATTRIBUTE14                  => null,
        X_ATTRIBUTE15                  => null);

    -- dbms_output.put_line('Adding Item (S)  : ' || l_region_code || ' ' ||
    --    p_attribute_code);

EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END add_region_item_for_vqr;


PROCEDURE add_region_to_header (
    p_attribute_code           IN VARCHAR2,
    p_attribute_application_id IN NUMBER,
    p_plan_id		       IN VARCHAR2,
    p_region_application_id    IN NUMBER,
    p_appendix 		       IN VARCHAR2) IS

    l_row_id	     	 	VARCHAR2(30);
    l_element_id	     	NUMBER;
    l_region_code	 	VARCHAR2(30);
    l_nested_region_code	VARCHAR2(30) DEFAULT null;
    l_item_style		VARCHAR2(30) DEFAULT 'NESTED_REGION';
    l_display_sequence		NUMBER;
    l_display_flag		VARCHAR2(1)  DEFAULT 'Y';
    l_update_flag		VARCHAR2(1)  DEFAULT 'Y';
    l_view_attribute_name	VARCHAR2(30) DEFAULT NULL;
    l_view_usage_name		VARCHAR2(30) DEFAULT NULL;
    l_label_long		VARCHAR2(50) DEFAULT NULL;

    err_num			NUMBER;
    err_msg			VARCHAR2(100);

BEGIN

    --  This function adds a region to a parent region.
    --  In our case, we want add the plan region to the top level region
    --  (e.g. QAPL<plan id> to EQR TOP or
    --  QAVQROSP<plan_id> or QAVQRSHP<plan id> to the VQR TOP

    -- we have now added code to include mapping for eam.

    -- l_region_code := construct_ak_code(p_appendix, p_plan_id);
    l_nested_region_code := p_attribute_code;
    l_view_usage_name := null;

    IF ( instr(p_attribute_code, g_vqr_appendix) <> 1) THEN

 	-- l_region_code := g_eqr_top_region;
        l_region_code := get_eqr_header_region_code(p_attribute_code);
        l_display_sequence := get_display_sequence(l_region_code,
             p_region_application_id);
        l_label_long := 'Plan Name: ' || qa_plans_api.plan_name(p_plan_id);

    ELSE
         -- we come here if we are adding plan region to the vqr top

         -- this has to be enhanced to branch on attribute code as well

 	 -- l_region_code := g_vqr_top_region;
         l_region_code := get_vqr_header_region_code(p_attribute_code);
         l_display_sequence := get_display_sequence(l_region_code,
             p_region_application_id);

    END IF;

    AK_REGION_ITEMS_PKG.insert_row (
        X_ROWID                        => l_row_id,
        X_REGION_APPLICATION_ID        => p_region_application_id,
        X_REGION_CODE                  => l_region_code,
        X_ATTRIBUTE_APPLICATION_ID     => p_attribute_application_id,
        X_ATTRIBUTE_CODE               => p_attribute_code,
        X_DISPLAY_SEQUENCE             => l_display_sequence,
        X_NODE_DISPLAY_FLAG            => l_display_flag,
        X_NODE_QUERY_FLAG              => 'N',
        X_ATTRIBUTE_LABEL_LENGTH       => 0,
        X_BOLD                         => 'N',
        X_ITALIC                       => 'N',
        X_VERTICAL_ALIGNMENT           => 'TOP',
        X_HORIZONTAL_ALIGNMENT         => 'LEFT',
        X_ITEM_STYLE                   => l_item_style,
        X_OBJECT_ATTRIBUTE_FLAG        => 'N',
        X_ATTRIBUTE_LABEL_LONG         => l_label_long,
        X_DESCRIPTION                  => 'Quality Column',
        X_SECURITY_CODE                => null,
        X_UPDATE_FLAG                  => l_update_flag,
        X_REQUIRED_FLAG                => 'N',
        X_DISPLAY_VALUE_LENGTH         => 0,
        X_LOV_REGION_APPLICATION_ID    => null,
        X_LOV_REGION_CODE              => null,
        X_LOV_FOREIGN_KEY_NAME         => null,
        X_LOV_ATTRIBUTE_APPLICATION_ID => null,
        X_LOV_ATTRIBUTE_CODE           => null,
        X_LOV_DEFAULT_FLAG             => null,
        X_REGION_DEFAULTING_API_PKG    => null,
        X_REGION_DEFAULTING_API_PROC   => null,
        X_REGION_VALIDATION_API_PKG    => null,
        X_REGION_VALIDATION_API_PROC   => null,
        X_ORDER_SEQUENCE               => null,
        X_ORDER_DIRECTION              => null,
        X_DEFAULT_VALUE_VARCHAR2       => null,
        X_DEFAULT_VALUE_NUMBER         => null,
        X_DEFAULT_VALUE_DATE           => null,
        X_ITEM_NAME                    => p_attribute_code,
        X_DISPLAY_HEIGHT               => 1,
        X_SUBMIT                       => 'N',
        X_ENCRYPT                      => 'N',
        X_VIEW_USAGE_NAME              => l_view_usage_name,
        X_VIEW_ATTRIBUTE_NAME          => l_view_attribute_name,
        X_CSS_CLASS_NAME               => null,
        X_CSS_LABEL_CLASS_NAME         => null,
        X_URL                          => null,
        X_POPLIST_VIEWOBJECT           => null,
        X_POPLIST_DISPLAY_ATTRIBUTE    => null,
        X_POPLIST_VALUE_ATTRIBUTE      => null,
        X_IMAGE_FILE_NAME              => null,
        X_NESTED_REGION_CODE           => l_nested_region_code,
        X_NESTED_REGION_APPL_ID        => p_region_application_id,
        X_MENU_NAME                    => null,
	X_FLEXFIELD_NAME 	       => null,
  	X_FLEXFIELD_APPLICATION_ID     => null,
  	X_TABULAR_FUNCTION_CODE        => null,
  	X_TIP_TYPE		       => null,
  	X_TIP_MESSAGE_NAME             => null,
  	X_TIP_MESSAGE_APPLICATION_ID   => null,
        X_ENTITY_ID		       => null,
        X_FLEX_SEGMENT_LIST	       => null,
 	X_ANCHOR		       => null,
	X_POPLIST_VIEW_USAGE_NAME      => null,
        X_USER_CUSTOMIZABLE            => null, --5.5
        X_SORTBY_VIEW_ATTRIBUTE_NAME   => null,	--5.5
        X_CREATION_DATE                => g_sysdate,
        X_CREATED_BY                   => 1,
        X_LAST_UPDATE_DATE             => g_sysdate,
        X_LAST_UPDATED_BY              => 1,
        X_LAST_UPDATE_LOGIN            => 1,
        X_ATTRIBUTE_CATEGORY           => null,
        X_ATTRIBUTE1                   => null,
        X_ATTRIBUTE2                   => null,
        X_ATTRIBUTE3                   => null,
        X_ATTRIBUTE4                   => null,
        X_ATTRIBUTE5                   => null,
        X_ATTRIBUTE6                   => null,
        X_ATTRIBUTE7                   => null,
        X_ATTRIBUTE8                   => null,
        X_ATTRIBUTE9                   => null,
        X_ATTRIBUTE10                  => null,
        X_ATTRIBUTE11                  => null,
        X_ATTRIBUTE12                  => null,
        X_ATTRIBUTE13                  => null,
        X_ATTRIBUTE14                  => null,
        X_ATTRIBUTE15                  => null);

    -- dbms_output.put_line('Adding Item (H)  : ' || l_region_code || ' ' ||
    --    p_attribute_code);

EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END add_region_to_header;


PROCEDURE add_special_region_item (
    p_attribute_code           IN VARCHAR2,
    p_attribute_application_id IN NUMBER,
    p_plan_id		       IN VARCHAR2,
    p_region_application_id    IN NUMBER,
    p_appendix 		       IN VARCHAR2) IS

    l_row_id	     	 	VARCHAR2(30);
    l_element_id	     	NUMBER;
    l_region_code	 	VARCHAR2(30);
    l_nested_region_code	VARCHAR2(30)  DEFAULT null;
    l_item_style		VARCHAR2(30)  DEFAULT 'HIDDEN';
    l_display_sequence		NUMBER;
    l_display_flag		VARCHAR2(1)   DEFAULT 'Y';
    l_update_flag		VARCHAR2(1)   DEFAULT 'Y';
    l_view_attribute_name	VARCHAR2(30)  DEFAULT NULL;
    l_view_usage_name		VARCHAR2(30)  DEFAULT NULL;
    l_label_long		VARCHAR2(30)  DEFAULT NULL;
    l_entity_id                 VARCHAR2(30)  DEFAULT NULL;
    l_url                       VARCHAR2(240) DEFAULT NULL;
    l_image_file_name           VARCHAR2(240) DEFAULT NULL;
    l_description               VARCHAR2(240) DEFAULT NULL;
    l_query_flag		VARCHAR2(1)   DEFAULT 'N';

    err_num			NUMBER;
    err_msg			VARCHAR2(100);

BEGIN


    -- This function adds special region items to the region.
    -- 	1.  To add special elements for eqr (e.g. org_id, plan_id_ etc)
    --  2.  To add special elements for vqr (e.g. org_id, plan_id_ etc)

    l_region_code := construct_ak_code(p_appendix, p_plan_id);

    IF ( instr(p_appendix, g_vqr_appendix) = 1) THEN

         -- Adding special elements for vqr
         l_view_usage_name := g_vqr_view_usage_name;
         l_item_style := 'TEXT';
         l_display_sequence := get_text_display_sequence(l_region_code,
             p_region_application_id);
         l_query_flag := 'Y';

    ELSE

         -- Adding special elements for eqr
         l_view_usage_name := g_eqr_view_usage_name;
         l_display_sequence := get_display_sequence(l_region_code,
              p_region_application_id);

    END IF;

    l_view_attribute_name := get_hardcoded_vo_attr_name(
            p_attribute_code);

    l_label_long := get_special_label(p_attribute_code);

    -- added for attachments
    IF (p_attribute_code = g_single_row_attachment) OR
        (p_attribute_code = g_multi_row_attachment) THEN
         l_entity_id := 'QA_RESULTS';

         l_view_attribute_name := '';
         l_label_long := 'Attachment';
         l_description := 'View Attachment';
         l_query_flag := 'N';

         IF (instr(l_region_code, g_txn_work_appendix) <> 0)
             OR (instr(l_region_code, g_txn_asset_appendix) <> 0)
             OR (instr(l_region_code, g_txn_op_appendix) <> 0)
             AND (p_attribute_code = g_single_row_attachment) THEN
             l_item_style := 'ATTACHMENT_LINK';
         ELSE
             l_item_style := 'ATTACHMENT_IMAGE';
         END IF;

         IF ( instr(p_appendix, g_vqr_appendix) = 1) THEN
            l_update_flag := 'N';
         END IF;
    END IF;

    IF (p_attribute_code = g_update_attribute) THEN

        -- dbms_output.put_line('Display Sequence: ' || l_display_sequence);

         -- need to get translated
         l_query_flag := 'N';
         l_label_long := 'Update';
         l_view_attribute_name := '';
         l_item_style := 'IMAGE';
         l_image_file_name := 'updateicon_enabled.gif';
         l_url := '/OA_HTML/OA.jsp?akRegionCode=QA_DDE_EQR_PAGE' || '&' ||
             'akRegionApplicationId=250' || '&' ||
             'PlanId={@PLAN_ID}' || '&' ||
             'Occurrence={@OCCURRENCE}' || '&' ||
             'UCollectionId={@COLLECTION_ID}' || '&' ||
             'retainAM=Y' || '&' || 'addBreadCrumb=Y';

    END IF;

    -- parent-child
    IF (p_attribute_code = g_child_url_attribute) THEN

        -- dbms_output.put_line('Display Sequence: ' || l_display_sequence);

         -- need to get translated
         l_query_flag := 'N';
         l_label_long := 'Child Plans';--earlier called Children
         l_view_attribute_name := '';
         l_item_style := 'IMAGE';
         l_image_file_name := 'allocationbr_pagetitle.gif';--image changed!
         l_url := '/OA_HTML/OA.jsp?akRegionCode=QA_PC_RES_SUMMARY_PAGE'
			|| '&' ||
             'akRegionApplicationId=250' || '&' ||
             'ParentPlanId={@PLAN_ID}' || '&' ||
             'ParentOccurrence={@OCCURRENCE}' || '&' ||
             'ParentCollectionId={@COLLECTION_ID}' || '&' ||
             'retainAM=Y' || '&' || 'addBreadCrumb=Y' ;
		--breadcrumb added for bug 2331941
    END IF;

    -- parent-child results inquiry ui improvement
    IF (p_attribute_code = g_vqr_all_elements_url) THEN

        -- dbms_output.put_line('Display Sequence: ' || l_display_sequence);

         -- need to get translated
         l_query_flag := 'N';
         l_label_long := 'More Details';--parent-child ui improvement
         l_view_attribute_name := '';
         l_item_style := 'IMAGE';
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

    -- dbms_output.put_line('Adding Item  (S)  : ' || l_region_code || ' ' ||
    --    p_attribute_code);

    AK_REGION_ITEMS_PKG.insert_row (
        X_ROWID                        => l_row_id,
        X_REGION_APPLICATION_ID        => p_region_application_id,
        X_REGION_CODE                  => l_region_code,
        X_ATTRIBUTE_APPLICATION_ID     => p_attribute_application_id,
        X_ATTRIBUTE_CODE               => p_attribute_code,
        X_DISPLAY_SEQUENCE             => l_display_sequence,
        X_NODE_DISPLAY_FLAG            => l_display_flag,
        X_NODE_QUERY_FLAG              => l_query_flag,
        X_ATTRIBUTE_LABEL_LENGTH       => 13,
        X_BOLD                         => 'N',
        X_ITALIC                       => 'N',
        X_VERTICAL_ALIGNMENT           => 'TOP',
        X_HORIZONTAL_ALIGNMENT         => 'LEFT',
        X_ITEM_STYLE                   => l_item_style,
        X_OBJECT_ATTRIBUTE_FLAG        => 'N',
        X_ATTRIBUTE_LABEL_LONG         => l_label_long,
        X_DESCRIPTION                  => l_description,
        X_SECURITY_CODE                => NULL,
        X_UPDATE_FLAG                  => l_update_flag,
        X_REQUIRED_FLAG                => 'N',
        X_DISPLAY_VALUE_LENGTH         => 0,
        X_LOV_REGION_APPLICATION_ID    => null,
        X_LOV_REGION_CODE              => null,
        X_LOV_FOREIGN_KEY_NAME         => null,
        X_LOV_ATTRIBUTE_APPLICATION_ID => null,
        X_LOV_ATTRIBUTE_CODE           => null,
        X_LOV_DEFAULT_FLAG             => null,
        X_REGION_DEFAULTING_API_PKG    => null,
        X_REGION_DEFAULTING_API_PROC   => null,
        X_REGION_VALIDATION_API_PKG    => null,
        X_REGION_VALIDATION_API_PROC   => null,
        X_ORDER_SEQUENCE               => null,
        X_ORDER_DIRECTION              => null,
        X_DEFAULT_VALUE_VARCHAR2       => null,
        X_DEFAULT_VALUE_NUMBER         => null,
        X_DEFAULT_VALUE_DATE           => null,
        X_ITEM_NAME                    => p_attribute_code,
        X_DISPLAY_HEIGHT               => 1,
        X_SUBMIT                       => 'N',
        X_ENCRYPT                      => 'N',
        X_VIEW_USAGE_NAME              => l_view_usage_name,
        X_VIEW_ATTRIBUTE_NAME          => l_view_attribute_name,
        X_CSS_CLASS_NAME               => null,
        X_CSS_LABEL_CLASS_NAME         => null,
        X_URL                          => l_url,
        X_POPLIST_VIEWOBJECT           => null,
        X_POPLIST_DISPLAY_ATTRIBUTE    => null,
        X_POPLIST_VALUE_ATTRIBUTE      => null,
        X_IMAGE_FILE_NAME              => l_image_file_name,
        X_NESTED_REGION_CODE           => l_nested_region_code,
        X_NESTED_REGION_APPL_ID        => p_region_application_id,
        X_MENU_NAME                    => null,
	X_FLEXFIELD_NAME 	       => null,
  	X_FLEXFIELD_APPLICATION_ID     => null,
  	X_TABULAR_FUNCTION_CODE        => null,
  	X_TIP_TYPE		       => null,
  	X_TIP_MESSAGE_NAME             => null,
  	X_TIP_MESSAGE_APPLICATION_ID   => null,
        X_ENTITY_ID		       => l_entity_id,
        X_FLEX_SEGMENT_LIST	       => null,
 	X_ANCHOR		       => null,
	X_POPLIST_VIEW_USAGE_NAME      => null,
        X_USER_CUSTOMIZABLE            => null, --5.5
        X_SORTBY_VIEW_ATTRIBUTE_NAME   => null,	--5.5
        X_CREATION_DATE                => g_sysdate,
        X_CREATED_BY                   => 1,
        X_LAST_UPDATE_DATE             => g_sysdate,
        X_LAST_UPDATED_BY              => 1,
        X_LAST_UPDATE_LOGIN            => 1,
        X_ATTRIBUTE_CATEGORY           => null,
        X_ATTRIBUTE1                   => null,
        X_ATTRIBUTE2                   => null,
        X_ATTRIBUTE3                   => null,
        X_ATTRIBUTE4                   => null,
        X_ATTRIBUTE5                   => null,
        X_ATTRIBUTE6                   => null,
        X_ATTRIBUTE7                   => null,
        X_ATTRIBUTE8                   => null,
        X_ATTRIBUTE9                   => null,
        X_ATTRIBUTE10                  => null,
        X_ATTRIBUTE11                  => null,
        X_ATTRIBUTE12                  => null,
        X_ATTRIBUTE13                  => null,
        X_ATTRIBUTE14                  => null,
        X_ATTRIBUTE15                  => null);

    -- dbms_output.put_line('Added Item  (S)  : ' || l_region_code || ' ' ||
    --    p_attribute_code);

EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END add_special_region_item;


PROCEDURE map_plan_for_eqr (
    x_plan_id IN VARCHAR2,
    x_region_application_id IN NUMBER,
    x_attribute_application_id IN NUMBER,
    x_appendix IN VARCHAR2) IS

    l_element_id  NUMBER;
    l_region_code VARCHAR2(30);

    err_num	 NUMBER;
    err_msg	 VARCHAR2(100);

    CURSOR c IS
	SELECT char_id
	FROM qa_plan_chars
	WHERE plan_id = x_plan_id
        AND enabled_flag = 1;

BEGIN

    -- To map a plan for eqr (specific to a txn) we need to do the following:
    --
    -- 1. create a nested region ak attribute
    -- 2. create a region for the current plan
    -- 4. add the region as the region item of EQR Header region
    -- 5. add the plan elements as the region items of this region
    -- 6. add the special attributes (org id and plan id)

    add_attribute_for_plan(
            p_plan_id		       => x_plan_id,
    	    p_attribute_application_id => x_attribute_application_id,
	    p_appendix 		       => x_appendix);

    add_ak_region(
            p_plan_id		       => x_plan_id,
    	    p_region_application_id    => x_region_application_id,
	    p_appendix		       => x_appendix);

    l_region_code := construct_ak_code(x_appendix, x_plan_id);

    add_region_to_header (
        p_attribute_code           => l_region_code,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    OPEN c;
    LOOP
        FETCH c INTO l_element_id;
        EXIT WHEN c%NOTFOUND;

        -- we have taken a decision to not to display an element
        -- for data entry if the element is a potenital target
        -- for a assigned a value action.

        IF (NOT action_target_element(x_plan_id, l_element_id)) THEN

	    qa_ak_mapping_api.add_region_item_for_eqr (
    	        p_char_id		   => l_element_id,
    	        p_attribute_application_id => x_attribute_application_id,
    	        p_plan_id		   => x_plan_id,
    	        p_region_application_id    => x_region_application_id,
	        p_appendix		   => x_appendix);

        END IF;

    END LOOP;
    CLOSE c;

    add_special_region_item (
        p_attribute_code           => g_org_id_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_org_code_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_plan_id_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_plan_name_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_process_status_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_source_code_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_source_line_id_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_po_agent_id_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    -- added for attachments

    IF (instr(l_region_code, g_txn_work_appendix) <> 0)
         OR (instr(l_region_code, g_txn_asset_appendix) <> 0)
         OR (instr(l_region_code, g_txn_op_appendix) <> 0) THEN

        -- code branch for eam eqr, so make it single
        add_special_region_item (
            p_attribute_code           => g_single_row_attachment,
            p_attribute_application_id => 601,
            p_plan_id                  => x_plan_id,
            p_region_application_id    => g_application_id,
            p_appendix                 => x_appendix);

    ELSE
        add_special_region_item (
            p_attribute_code           => g_multi_row_attachment,
            p_attribute_application_id => 601,
            p_plan_id                  => x_plan_id,
            p_region_application_id    => g_application_id,
            p_appendix                 => x_appendix);

    END IF;

    -- dbms_output.put_line('-------------------------------------------');

EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END map_plan_for_eqr;


PROCEDURE map_plan_for_vqr (
    x_plan_id IN VARCHAR2,
    x_region_application_id IN NUMBER,
    x_attribute_application_id IN NUMBER,
    x_appendix IN VARCHAR2) IS

    l_element_id     NUMBER;
    l_region_code    VARCHAR2(30);
    l_attribute_code VARCHAR2(30);

    err_num	 NUMBER;
    err_msg	 VARCHAR2(100);
    elmt_counter 	 NUMBER;--parent-child results inquiry

    CURSOR c IS
	SELECT char_id
	FROM qa_plan_chars
	WHERE plan_id = x_plan_id
        AND enabled_flag = 1
	ORDER BY PROMPT_SEQUENCE;

BEGIN

    -- To map a plan for vqr we need to do the follwing:
    --
    -- 1. create a nested region ak attribute
    -- 2. create a region for the current plan
    -- 4. add the region as the region item of VQR Header region
    -- 5. add the plan elements to current plan region
    -- 6. add special region items to the region

	--dbms_output.put_line('in here');
    add_attribute_for_plan(
            p_plan_id		       => x_plan_id,
    	    p_attribute_application_id => x_attribute_application_id,
	    p_appendix 		       => x_appendix);

    add_ak_region(
            p_plan_id		       => x_plan_id,
    	    p_region_application_id    => x_region_application_id,
	    p_appendix		       => x_appendix);

    l_region_code := construct_ak_code(x_appendix, x_plan_id);

    add_region_to_header (
        p_attribute_code           => l_region_code,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    elmt_counter := 0; --parent-child results inquiry
		  --initialize counter
    OPEN c;
    LOOP
        FETCH c INTO l_element_id;
        EXIT WHEN c%NOTFOUND;

	elmt_counter := elmt_counter + 1; --parent-child
	--dbms_output.put_line('counter' || elmt_counter);
        l_attribute_code := construct_ak_code(g_element_appendix,l_element_id);

        -- For Eam transactions if it is an action target then this element
        -- should not show up in VQR region.

        IF (instr(l_region_code, g_work_vqr_appendix) <> 0)
             OR  (instr(l_region_code, g_asset_vqr_appendix) <> 0)
             OR  (instr(l_region_code, g_op_vqr_appendix) <> 0) THEN

            IF (NOT action_target_element(x_plan_id, l_element_id)) THEN
	        qa_ak_mapping_api.add_region_item_for_vqr (
    	            p_attribute_code	       => l_attribute_code,
    	            p_attribute_application_id => x_attribute_application_id,
    	            p_plan_id		       => x_plan_id,
    	            p_region_application_id    => x_region_application_id,
	            p_appendix		       => x_appendix);
            END IF;

        ELSE
	    IF (instr(l_region_code, g_pc_vqr_appendix) <> 0 and
			elmt_counter > 4) THEN
		--if this is a parent child multi-row vqr screen
			EXIT; --exit the loop. Dont show more elements
	    END IF; --parent-child

	    qa_ak_mapping_api.add_region_item_for_vqr (
    	        p_attribute_code	   => l_attribute_code,
    	        p_attribute_application_id => x_attribute_application_id,
    	        p_plan_id		   => x_plan_id,
    	        p_region_application_id    => x_region_application_id,
	        p_appendix		   => x_appendix);
        END IF;

    END LOOP;
    CLOSE c;

  IF (instr(l_region_code, g_pc_vqr_sin_appendix) = 0) THEN
  -- means if this is "not" single row parent vqr region
    add_special_region_item (
        p_attribute_code           => g_qa_created_by_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_collection_id_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);

    add_special_region_item (
        p_attribute_code           => g_last_update_date_attribute,
        p_attribute_application_id => g_application_id,
        p_plan_id		   => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix 		   => x_appendix);


    -- added for attachments
    add_special_region_item (
        p_attribute_code           => g_multi_row_attachment,
        p_attribute_application_id => 601,
        p_plan_id                  => x_plan_id,
        p_region_application_id    => g_application_id,
        p_appendix                 => x_appendix);

    -- added for update capability

    IF (instr(l_region_code, g_work_vqr_appendix) <> 0)
         OR (instr(l_region_code, g_asset_vqr_appendix) <> 0)
         OR (instr(l_region_code, g_op_vqr_appendix) <> 0) THEN

        add_special_region_item (
            p_attribute_code           => g_update_attribute,
            p_attribute_application_id => g_application_id,
            p_plan_id                  => x_plan_id,
            p_region_application_id    => g_application_id,
            p_appendix                 => x_appendix);

    END IF;

    -- parent-child
       IF (instr(l_region_code, g_pc_vqr_appendix) <> 0) THEN
	--if this is a parent child results inquiry multi-row vqr screen
        add_special_region_item (
            p_attribute_code           => g_child_url_attribute,
            p_attribute_application_id => g_application_id,
            p_plan_id                  => x_plan_id,
            p_region_application_id    => g_application_id,
            p_appendix                 => x_appendix);

	--below introduced for ui improvement
	--link to click and see all coll.elements for a vqr row
	-- (More Details Link)
	--one 'nice' feedback here is that make this call only if the
	--total no of collection elements is greater than 4
	--since this link is not needed otherwise
	--this additional check can be coded here...
	--
        add_special_region_item (
            p_attribute_code           => g_vqr_all_elements_url,
            p_attribute_application_id => g_application_id,
            p_plan_id                  => x_plan_id,
            p_region_application_id    => g_application_id,
            p_appendix                 => x_appendix);
 	END IF;
  END IF; --end "outer if" stmt: "not" single row parent vqr region
EXCEPTION

    WHEN OTHERS THEN
	err_num := SQLCODE;
 	err_msg := SUBSTR(SQLERRM, 1, 100);
	-- dbms_output.put_line(err_msg);

END map_plan_for_vqr;


PROCEDURE map_plan(
    p_plan_id IN NUMBER,
    p_region_application_id IN NUMBER,
    p_attribute_application_id IN NUMBER) IS

    associated BOOLEAN DEFAULT FALSE;
    asset_mapped BOOLEAN DEFAULT FALSE;

BEGIN

    -- This procedure does whatever is necessary to map a collection
    -- plan to ak tables.
    --
    -- At a very high level this is what we need to do:
    --
    -- 1. Delete the plan mapping if it existed (in case of update).
    -- 2. Check if this plan is associated with OSP transaction.
    --    If it is then map this plan for osp transaction.
    -- 3. Check if this plan is associated with SHIPMENT Transaction,
    --    If it is then map this plan for shipment transaction.
    -- 4. Check if this plan is associated with CUSTOMER PORTAL Transaction,
    --    If it is then map this plan for transaction but only the VQR part.

    delete_plan_mapping(p_plan_id, p_region_application_id,
	p_attribute_application_id);


    -- To avoid hitting the database multiple times for sysdate.
    g_sysdate := SYSDATE;
    --dbms_output.put_line('entered');
    IF osp_self_service_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for osp');
    	map_plan_for_eqr(p_plan_id, p_region_application_id,
            p_attribute_application_id, g_txn_osp_appendix);
    	map_plan_for_vqr (p_plan_id, p_region_application_id,
            p_attribute_application_id, g_osp_vqr_appendix);

	--for project3 parent-child
	--find out all descendants and call map plan for eqr and vqr
	--for all these descendants
    END IF;

    IF shipment_self_service_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for shipment');
        map_plan_for_eqr(p_plan_id, p_region_application_id,
            p_attribute_application_id, g_txn_ship_appendix);

    	map_plan_for_vqr (p_plan_id, p_region_application_id,
            p_attribute_application_id, g_ship_vqr_appendix);

	--for project3 parent-child
	--find out all descendants and call map plan for eqr and vqr
	--for all these descendants
    END IF;

    IF customer_portal_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for OM');
        map_plan_for_vqr (p_plan_id, p_region_application_id,
            p_attribute_application_id, g_om_vqr_appendix);
    END IF;

    IF eam_asset_plan(p_plan_id) THEN

	if not asset_mapped then
	        map_plan_for_eqr(p_plan_id, p_region_application_id,
        	    p_attribute_application_id, g_txn_asset_appendix);
	        map_plan_for_vqr (p_plan_id, p_region_application_id,
        	    p_attribute_application_id, g_asset_vqr_appendix);
		asset_mapped := TRUE;
	end if;

    END IF;

    IF eam_work_order_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for EAM');
        map_plan_for_eqr(p_plan_id, p_region_application_id,
            p_attribute_application_id, g_txn_work_appendix);
        map_plan_for_vqr (p_plan_id, p_region_application_id,
            p_attribute_application_id, g_work_vqr_appendix);

	if not asset_mapped then
	        map_plan_for_eqr(p_plan_id, p_region_application_id,
        	    p_attribute_application_id, g_txn_asset_appendix);
	        map_plan_for_vqr (p_plan_id, p_region_application_id,
        	    p_attribute_application_id, g_asset_vqr_appendix);
		asset_mapped := TRUE;
	end if;

    END IF;

    IF eam_op_comp_plan(p_plan_id) THEN

        -- dbms_output.put_line('mapping for EAM');
        map_plan_for_eqr(p_plan_id, p_region_application_id,
            p_attribute_application_id, g_txn_op_appendix);
        map_plan_for_vqr (p_plan_id, p_region_application_id,
            p_attribute_application_id, g_op_vqr_appendix);

	if not asset_mapped then
	        map_plan_for_eqr(p_plan_id, p_region_application_id,
        	    p_attribute_application_id, g_txn_asset_appendix);
	        map_plan_for_vqr (p_plan_id, p_region_application_id,
        	    p_attribute_application_id, g_asset_vqr_appendix);
		asset_mapped := TRUE;
	end if;

    END IF;

    -- Parent-Child
    IF parent_child_plan(p_plan_id) THEN
	map_plan_for_vqr (p_plan_id, p_region_application_id,
            p_attribute_application_id, g_pc_vqr_appendix);
	map_plan_for_vqr (p_plan_id, p_region_application_id,
            p_attribute_application_id, g_pc_vqr_sin_appendix);

	--below info when we do project3 parent-child
	--this is called from qa_ss_parent_child_pkg
	--in that call check for isp and make appropriate map calls
    END IF;

END map_plan;


PROCEDURE delete_plan_mapping_for_txn (
    p_plan_id IN VARCHAR2,
    p_region_application_id IN NUMBER,
    p_attribute_application_id IN NUMBER,
    p_appendix IN VARCHAR2) IS

    l_element_id NUMBER;
    l_attribute_code VARCHAR2(30);
    l_region_code VARCHAR2(30);
    l_top_region VARCHAR2(30);

    CURSOR c (x_region_code VARCHAR2) IS
	SELECT attribute_code
	FROM ak_region_items
	WHERE region_code = x_region_code
	AND region_application_id = g_application_id;

BEGIN

    -- To delete a plan for txn we need to do the follwing:
    --
    -- 1. delete the region as the region item of EQR/VQR TOP
    -- 2. delete all the region items for this region
    -- 3. delete the region
    -- 4. delete the nested region ak attribute

    l_region_code := construct_ak_code(p_appendix, p_plan_id);

    IF ( instr(p_appendix, g_vqr_appendix) = 1) THEN
        -- possibly change this for eam vqr
        l_top_region := get_vqr_header_region_code(l_region_code);
    ELSE
        l_top_region := get_eqr_header_region_code(l_region_code);
    END IF;

    delete_region_item (
        p_region_application_id,
        l_top_region,
	p_attribute_application_id,
	l_region_code);

    -- dbms_output.put_line('Deleting From Region: ' || l_region_code);
    OPEN c (l_region_code);
    LOOP
        FETCH c INTO l_attribute_code;
        EXIT WHEN c%NOTFOUND;

        IF (l_attribute_code = g_single_row_attachment)
            OR (l_attribute_code = g_multi_row_attachment) THEN
            delete_region_item (
                p_region_application_id,
                l_region_code,
	        601,
	        l_attribute_code);
        ELSE
            delete_region_item (
                p_region_application_id,
                l_region_code,
	        p_attribute_application_id,
	        l_attribute_code);
        END IF;
    END LOOP;
    CLOSE c;

    delete_region (p_region_application_id, l_region_code);
    delete_attribute_for_plan (l_region_code, p_attribute_application_id);

    -- dbms_output.put_line('-------------------------------------------');

END delete_plan_mapping_for_txn;


PROCEDURE delete_plan_mapping (
    p_plan_id IN NUMBER,
    p_region_application_id IN NUMBER,
    p_attribute_application_id IN NUMBER) IS

BEGIN

    -- This procedure deletes the mapping of a collection
    -- plan from ak tables.  This does it by deleting all the
    -- individual mapping per transaction at a time.

    -- Even for the same txn the call needs to be made multiple times
    -- for example for ship txn, call made once for EQR and once for VQR
    -- with appendix g_txn_ship_appendix and g_ship_vqr_appendix

    -- parent-child
    -- note the use of g_pc_vqr_appendix means this is for PC vqr
    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_pc_vqr_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_pc_vqr_sin_appendix);

    -- end parent-child ... old code follows below

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_txn_osp_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_txn_ship_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_ship_vqr_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_osp_vqr_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_om_vqr_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_txn_work_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_work_vqr_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_txn_asset_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_asset_vqr_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_txn_op_appendix);

    delete_plan_mapping_for_txn(p_plan_id, p_region_application_id,
        p_attribute_application_id, g_op_vqr_appendix);

END delete_plan_mapping;


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


END qa_ak_mapping_api;


/
