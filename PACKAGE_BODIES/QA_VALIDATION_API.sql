--------------------------------------------------------
--  DDL for Package Body QA_VALIDATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_VALIDATION_API" AS
/* $Header: qltvalb.plb 120.30.12010000.6 2010/04/26 17:15:23 ntungare ship $ */

g_dependency_matrix             DependencyArray;

   --
-- Mapping between an internal validation error message code
-- and the AOL message name.
--
g_message_map             dbms_sql.varchar2s;

g_restrict_subinv_code          NUMBER;
g_restrict_locators_code        NUMBER;
g_location_control_code         NUMBER;
g_revision_qty_cntrl_code       NUMBER;

g_comp_restrict_subinv_code     NUMBER;
g_comp_restrict_locators_code   NUMBER;
g_comp_location_control_code    NUMBER;
g_comp_revision_qty_cntrl_code  NUMBER;

-- Added the following for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

g_bill_restrict_subinv_code     NUMBER;
g_bill_restrict_locators_code   NUMBER;
g_bill_location_control_code    NUMBER;
g_bill_revision_qty_cntrl_code  NUMBER;

g_rout_restrict_subinv_code     NUMBER;
g_rout_restrict_locators_code   NUMBER;
g_rout_location_control_code    NUMBER;
g_rout_revision_qty_cntrl_code  NUMBER;

-- End of inclusions for NCM Hardcode Elements.


g_comp_item_id                  NUMBER;
g_item_id                       NUMBER;
g_org_id                        NUMBER;
g_transaction_number            NUMBER;
g_transaction_id                NUMBER;
g_lot_number                    VARCHAR2(150);
g_line_id                       NUMBER DEFAULT null;
g_wip_entity_id                 NUMBER;
g_po_header_id                  NUMBER;
--
-- bug 9652549 CLM changes
--
g_po_line_number                VARCHAR2(240);
g_subinventory                  VARCHAR2(15);

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
-- Added the following global variable
--
g_work_order_id                 NUMBER;

-- Added the following for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

g_bill_reference_id             NUMBER;
g_routing_reference_id          NUMBER;
g_to_subinventory               VARCHAR2(15);

--
-- Bug 6126260
-- Needed for validating the dependent
-- elements of componenet subinventory
-- like comp_locator.
-- bhsankar Mon Jul 16 05:51:51 PDT 2007
--
g_comp_subinventory             VARCHAR2(15);

--
-- Bug 2672396.  Added g_project_id because task is a dependent element.
-- We will need to keep a cache copy of project_id when it is validated
-- to be used to validate task_number later.
-- bso Mon Nov 25 17:29:56 PST 2002
--
g_project_id                    NUMBER;

-- End of inclusions for NCM Hardcode Elements.

-- R12 OPM Deviations. Bug 4345503 Start
g_process_batch_id              NUMBER;
g_process_batchstep_id          NUMBER;
g_process_activity_id           NUMBER;
g_process_resource_id           NUMBER;
-- R12 OPM Deviations. Bug 4345503 End

--
-- Bug 4635316.
-- Global variable to store the application user_id.
-- ntungare Wed Sep 28 05:59:14 PDT 2005.
--
g_user_id number;



-- Bug 4558205. Lot/Serial Validation.
g_revision                     VARCHAR2(10);
-- End 4558205.


-- Bug 4558205. Lot/Serial Validation.
-- Init procedure for global variables.
-- srhariha. Tue Sep 27 05:07:58 PDT 2005.

PROCEDURE init_globals IS

BEGIN
   g_lot_number := NULL;
   g_revision   := NULL;
END init_globals;

-- End 4558205.

PROCEDURE populate_dependency_matrix IS

BEGIN

    g_dependency_matrix(1).element_id  := qa_ss_const.item;
    g_dependency_matrix(1).parent      := qa_ss_const.production_line;

    g_dependency_matrix(2).element_id  := qa_ss_const.to_op_seq_num;
    g_dependency_matrix(2).parent      := qa_ss_const.job_name;

    g_dependency_matrix(3).element_id  := qa_ss_const.to_op_seq_num;
    g_dependency_matrix(3).parent      := qa_ss_const.production_line;

    g_dependency_matrix(4).element_id  := qa_ss_const.from_op_seq_num;
    g_dependency_matrix(4).parent      := qa_ss_const.job_name;

    g_dependency_matrix(5).element_id  := qa_ss_const.from_op_seq_num;
    g_dependency_matrix(5).parent      := qa_ss_const.production_line;

    g_dependency_matrix(6).element_id  := qa_ss_const.to_intraoperation_step;
    g_dependency_matrix(6).parent      := qa_ss_const.to_op_seq_num;

    g_dependency_matrix(7).element_id  := qa_ss_const.from_intraoperation_step;
    g_dependency_matrix(7).parent      := qa_ss_const.from_op_seq_num;

    g_dependency_matrix(8).element_id := qa_ss_const.uom;
    g_dependency_matrix(8).parent     := qa_ss_const.item;

    g_dependency_matrix(9).element_id := qa_ss_const.revision;
    g_dependency_matrix(9).parent     := qa_ss_const.item;

    g_dependency_matrix(10).element_id := qa_ss_const.subinventory;
    g_dependency_matrix(10).parent     := qa_ss_const.item;

    g_dependency_matrix(11).element_id := qa_ss_const.locator;
    g_dependency_matrix(11).parent     := qa_ss_const.subinventory;

    g_dependency_matrix(12).element_id := qa_ss_const.lot_number;
    g_dependency_matrix(12).parent     := qa_ss_const.item;

    g_dependency_matrix(13).element_id := qa_ss_const.serial_number;
    g_dependency_matrix(13).parent     := qa_ss_const.item;

    g_dependency_matrix(14).element_id := qa_ss_const.comp_uom;
    g_dependency_matrix(14).parent     := qa_ss_const.comp_item;

    g_dependency_matrix(15).element_id := qa_ss_const.comp_revision;
    g_dependency_matrix(15).parent     := qa_ss_const.comp_item;

    g_dependency_matrix(16).element_id := qa_ss_const.po_line_num;
    g_dependency_matrix(16).parent     := qa_ss_const.po_number;

    g_dependency_matrix(17).element_id := qa_ss_const.po_shipment_num;
    g_dependency_matrix(17).parent     := qa_ss_const.po_line_num;

    g_dependency_matrix(18).element_id := qa_ss_const.po_release_num;
    g_dependency_matrix(18).parent     := qa_ss_const.po_number;

    g_dependency_matrix(19).element_id := qa_ss_const.order_line;
    g_dependency_matrix(19).parent     := qa_ss_const.sales_order;

    g_dependency_matrix(20).element_id := qa_ss_const.task_number;
    g_dependency_matrix(20).parent     := qa_ss_const.project_number;

    g_dependency_matrix(21).element_id := qa_ss_const.serial_number;
    g_dependency_matrix(21).parent     := qa_ss_const.lot_number;

    g_dependency_matrix(22).element_id := qa_ss_const.contract_line_number;
    g_dependency_matrix(22).parent     := qa_ss_const.contract_number;

    g_dependency_matrix(23).element_id := qa_ss_const.deliverable_number;
    g_dependency_matrix(23).parent     := qa_ss_const.contract_line_number;

    g_dependency_matrix(24).element_id := qa_ss_const.asset_number;
    g_dependency_matrix(24).parent     := qa_ss_const.asset_group;

    --
    -- See Bug 2588213
    -- To support the element Maintenance Op Seq Number
    -- to be used along with Maintenance Workorder
    -- rkunchal Mon Sep 23 23:46:28 PDT 2002
    --
    g_dependency_matrix(25).element_id := qa_ss_const.maintenance_op_seq;
    g_dependency_matrix(25).parent     := qa_ss_const.work_order;

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

    g_dependency_matrix(26).element_id := qa_ss_const.to_subinventory;
    g_dependency_matrix(26).parent     := qa_ss_const.item;

    g_dependency_matrix(27).element_id := qa_ss_const.to_locator;
    g_dependency_matrix(27).parent     := qa_ss_const.to_subinventory;

    -- R12 OPM Deviations. Bug 4345503 Start
    g_dependency_matrix(28).element_id := qa_ss_const.process_batchstep_num;
    g_dependency_matrix(28).parent     := qa_ss_const.process_batch_num;

    g_dependency_matrix(29).element_id := qa_ss_const.process_operation;
    g_dependency_matrix(29).parent     := qa_ss_const.process_batch_num;

    g_dependency_matrix(30).element_id := qa_ss_const.process_activity;
    g_dependency_matrix(30).parent     := qa_ss_const.process_batch_num;

    g_dependency_matrix(31).element_id := qa_ss_const.process_resource;
    g_dependency_matrix(31).parent     := qa_ss_const.process_batch_num;

    g_dependency_matrix(32).element_id := qa_ss_const.process_parameter;
    g_dependency_matrix(32).parent     := qa_ss_const.process_batch_num;
    -- R12 OPM Deviations. Bug 4345503 End

    --dgupta: Start R12 EAM Integration. Bug 4345492
    --Ensure that sequence number (within brackets) is unique when merged
    g_dependency_matrix(33).element_id := qa_ss_const.asset_instance_number;
    g_dependency_matrix(33).parent     := qa_ss_const.asset_group;
    --dgupta: End R12 EAM Integration. Bug 4345492

END populate_dependency_matrix;


FUNCTION flag_is_set (all_flags IN VARCHAR2, flag_in_question IN VARCHAR2)
    RETURN BOOLEAN IS

    pos NUMBER;

BEGIN

    IF instr(all_flags, flag_in_question, 1, 1) > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END flag_is_set;


FUNCTION  parent (element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

   -- Earlier we have populated an array with the elements
   -- that have least one element dependent on them
   --
   -- This PARENT function should simply look through
   -- this list to and return if that exists


    FOR i IN 1..g_dependency_matrix.count LOOP

        IF g_dependency_matrix(i).parent = element_id THEN
                RETURN TRUE;
        END IF;

    END LOOP;

    RETURN FALSE;

END parent;


-- Bug 3397484 ksoh Tue Jan 27 13:54:38 PST 2004
-- order ordered_array by prompt_sequence, need to pass plan_id in
FUNCTION populate_elements (row_elements IN ElementsArray, p_plan_id IN NUMBER)
    RETURN ElementInfoArray IS

    i                   NUMBER;
    indx                NUMBER;
    ordered_array       ElementInfoArray;

    CURSOR c IS
        select char_id
        from qa_plan_chars
        where plan_id = p_plan_id
        and enabled_flag = 1
        order by prompt_sequence;

BEGIN

    -- This function takes the row_elements array that is passed
    -- by the user of validate_row and copies the ids and validation
    -- flags to the ordered_array. The ordered_array has continuous
    -- indexing (e.g. 1,2,3,4..) unlike row_elements which is sparsed
    -- (e.g. 4, 10, 120)

    -- i := row_elements.FIRST;

    -- ordered_array is being processed from index 1

    -- ordered_array(ordered_array.count).id := 0;

    -- WHILE (i <> row_elements.LAST) LOOP
    OPEN c;
    LOOP
        FETCH c INTO i;
        EXIT WHEN c%NOTFOUND;
        indx := ordered_array.count;
        -- bug 3419514 ksoh Wed Feb  4 12:19:04 PST 2004
        -- must skip if row_elements(i) does not exist.
        -- It would not exist for the following case:
        -- say Quantity is in the history plan
        -- but not in relationship with the parent plan.
        -- From qapcb, when we call post_result_with_no_validation,
        -- we pass only elements in pc history relationship.
        -- And thus row_elements(i).validation_flag would fail for Quantity
        -- old check does not cover this case
        -- IF (i <= row_elements.LAST) THEN
        IF row_elements.EXISTS(i) THEN
            ordered_array(indx).id := i;
            ordered_array(indx).validation_flag := nvl(row_elements(i).validation_flag, 'invalid');
        END IF;
        -- i := row_elements.NEXT(i);

    END LOOP;

    -- indx := ordered_array.count;
    -- ordered_array(indx).id := i;
    -- ordered_array(indx).validation_flag := nvl(row_elements(i).validation_flag, 'invalid');

    RETURN ordered_array;

END populate_elements;


FUNCTION direct_child(x IN NUMBER, y IN NUMBER) RETURN BOOLEAN IS
    --
    -- Determine if x is a direct child of y.  Implemented as simple
    -- linear lookup.
    --
BEGIN

    FOR i IN 1..g_dependency_matrix.count LOOP
        IF x = g_dependency_matrix(i).element_id AND
            y = g_dependency_matrix(i).parent THEN
            RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;

END direct_child;


FUNCTION descendant(x IN NUMBER, y IN NUMBER) RETURN BOOLEAN IS
--
-- Determine if x is a descendant of y.  This is the logic:
-- x is a descendant of y either
--    1. x is a direct child or
--    2. x is the child of some z and z is a descendant of y.
--
BEGIN

    IF direct_child(x, y) THEN
        RETURN TRUE;
    END IF;

    FOR i IN 1..g_dependency_matrix.count LOOP
        IF x = g_dependency_matrix(i).element_id AND
            descendant(g_dependency_matrix(i).parent, y) THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END descendant;


PROCEDURE pushdown ( position IN NUMBER, element_id IN NUMBER, assorted_array
    IN OUT NOCOPY ElementInfoArray) IS

BEGIN

    FOR i IN REVERSE position..assorted_array.count-1 LOOP
        assorted_array(i+1).id := assorted_array(i).id;
    END LOOP;

    assorted_array(position).id := element_id;

END pushdown;


PROCEDURE determine_navigation_order (ordered_array IN OUT
    NOCOPY ElementInfoArray) IS

    KEY         NUMBER;
    ancestor   BOOLEAN;

    assorted_array ElementInfoArray;

BEGIN

    ancestor := false;

    FOR j IN 0..ordered_array.count-1 LOOP

        IF parent(ordered_array(j).id) THEN

            -- If parent, then check if any of the children is present
            -- in the already assorted list

            FOR t IN 0..assorted_array.count-1 LOOP

                IF descendant (assorted_array(t).id, ordered_array(j).id) THEN
                     ancestor := TRUE;
                     pushdown(t, ordered_array(j).id, assorted_array);
                     exit;
                END IF;
            END LOOP;
        END IF;

        IF NOT ancestor THEN
            assorted_array(assorted_array.count).id := ordered_array(j).id;
        END IF;

        ancestor := FALSE;

    END LOOP;

    FOR q IN 0..assorted_array.count-1 LOOP
        ordered_array(q).id := assorted_array(q).id;
        -- dbms_output.put_line(ordered_array(q).id);
    END LOOP;

END determine_navigation_order;


PROCEDURE append_errors (element_id IN NUMBER, element_error_list IN
    ErrorArray, row_error_list IN OUT NOCOPY ErrorArray) IS

    ind                 NUMBER;
    i                   NUMBER;

BEGIN

    ind := row_error_list.count + 1;

    --
    -- Bug 5331420
    -- Corrected small issue with this routine before the above
    -- bug fix can continue.  The indexes for element_error_list
    -- is not linear, so we should use WHILE loop instead of FOR.
    -- bso Thu Jun 15 16:22:54 PDT 2006
    --
    -- FOR i IN 1..element_error_list.count LOOP
    --

    i := element_error_list.FIRST;
    WHILE i IS NOT NULL LOOP

        IF (element_error_list(i).error_code <> ok) THEN

            row_error_list(ind).element_id := element_id;
            row_error_list(ind).error_code :=
            element_error_list(i).error_code;

            ind := ind + 1;

        END IF;
        i := element_error_list.NEXT(i);

    END LOOP;

END append_errors;


FUNCTION no_errors (error_array IN ErrorArray)
    RETURN BOOLEAN IS

BEGIN


    FOR i IN 1..error_array.count LOOP
        IF error_array(i).error_code <> ok THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;

END no_errors;


FUNCTION validate_enabled (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN NUMBER IS

    flag NUMBER;

BEGIN

    flag := qa_plan_element_api.get_enabled_flag(plan_id, element_id);

    IF (flag = 1) THEN
        RETURN ok;
    ELSE
        RETURN not_enabled_error;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN no_data_found_error;

END validate_enabled;


FUNCTION validate_mandatory_revision (plan_id IN NUMBER,
                                      element_id IN NUMBER,
                                      value IN NUMBER)
    RETURN NUMBER IS

    revision_flag NUMBER;

BEGIN

    IF (element_id = qa_ss_const.revision) THEN
        revision_flag := g_revision_qty_cntrl_code;

    ELSIF (element_id = qa_ss_const.comp_revision) THEN
        revision_flag := g_comp_revision_qty_cntrl_code;
    END IF;

    IF ( revision_flag = 1) and (value is not NULL)  THEN
        return not_revision_controlled_error;
    END IF;

    IF ( revision_flag = 2) and (value is NULL)  THEN
        return mandatory_revision_error;
    END IF;

    RETURN ok;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN unknown_error;

END validate_mandatory_revision;

-- anagarwa Mon Feb 24 17:08:57 PST 2003
-- Bug 2808693
-- Overloaded method validate_mandatory_revision.
-- Here value is of type VARCHAR2 to support data being entered from selfservice

FUNCTION validate_mandatory_revision (plan_id IN NUMBER,
                                      element_id IN NUMBER,
                                      value IN VARCHAR2)
    RETURN NUMBER IS

    revision_flag NUMBER;

BEGIN

    IF (element_id = qa_ss_const.revision) THEN
        revision_flag := g_revision_qty_cntrl_code;

    ELSIF (element_id = qa_ss_const.comp_revision) THEN
        revision_flag := g_comp_revision_qty_cntrl_code;
    END IF;

    IF ( revision_flag = 1) and (value is not NULL)  THEN
        return not_revision_controlled_error;
    END IF;

    IF ( revision_flag = 2) and (value is NULL)  THEN
        return mandatory_revision_error;
    END IF;

    RETURN ok;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN unknown_error;

END validate_mandatory_revision;


FUNCTION validate_mandatory_locator (plan_id IN NUMBER,
                                     element_id IN NUMBER,
                                     value IN NUMBER)
    RETURN NUMBER IS

BEGIN

    --
    -- delay mandatory validation until we validate
    -- the locator keyflex
    --

    RETURN ok;

END validate_mandatory_locator;


-- The Function validate_mandatory_locator has been overloaded.
-- The overloading is required because History record insert procedure
-- is called by Parent child call, locator values is passed as locator
-- name (like 6.6.6..)and not as locator_id.
-- Bug 2700230.suramasw Mon Dec 23 03:06:30 PST 2002.

FUNCTION validate_mandatory_locator (plan_id IN NUMBER,
                                     element_id IN NUMBER,
                                     value IN VARCHAR2)
    RETURN NUMBER IS

BEGIN

    --
    -- delay mandatory validation until we validate
    -- the locator keyflex
    --

    RETURN ok;

END validate_mandatory_locator;


FUNCTION validate_mandatory (row_record IN RowRecord, element_id IN NUMBER,
    value IN VARCHAR2)
    RETURN NUMBER IS

    element_name        VARCHAR2(240);
    m_flag              NUMBER;

BEGIN

    IF (element_id = qa_ss_const.revision) or
       (element_id = qa_ss_const.comp_revision) THEN

        RETURN validate_mandatory_revision(row_record.plan_id, element_id,
            value);

    END IF;

    -- Modified the code below to enable History Records to be created
    -- when History Relationship is present.
    -- Bug 2700230.suramasw Mon Dec 23 03:06:30 PST 2002.

    /*
    IF (element_id = qa_ss_const.locator) or
       (element_name = qa_ss_const.comp_locator) THEN
    */

    IF (element_id IN( qa_ss_const.locator,qa_ss_const.to_locator,
                       qa_ss_const.comp_locator)) THEN

        RETURN validate_mandatory_locator(row_record.plan_id, element_id,
            value);
    END IF;


    m_flag := qa_plan_element_api.get_mandatory_flag(row_record.plan_id,
         element_id);

    IF ( (m_flag = 2) or (value IS NOT NULL) ) THEN
        RETURN ok;
    END IF;

    RETURN mandatory_error;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN no_data_found_error;

END validate_mandatory;


FUNCTION validate_kf_item (row_elements IN ElementsArray,
    row_record IN RowRecord, element_id IN NUMBER, value IN VARCHAR2,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

    id                  NUMBER;
    error_code          NUMBER;
    x_where_clause      VARCHAR2(500);

    CURSOR c2 (i_id NUMBER, o_id NUMBER) IS
        select restrict_subinventories_code, restrict_locators_code,
            location_control_code, revision_qty_control_code
        from mtl_system_items
        where inventory_item_id = i_id
        and organization_id = o_id;

BEGIN
    IF (value is NULL) THEN
        RETURN ok;
    END IF;

    -- Bug 3593287
    --
    -- Item validation needs to be revised.  The original
    -- implementation was not correct.  The subsequent bug
    -- fix 3506231 is also not correct, introducing new bug
    -- 3593287.  The proper design is this
    --
    --     if Production Line is in plan and is not null then
    --     we should restrict item further by wip production line
    --     or flow production line
    --
    -- This is an exact rephrase from QLTRES mimicing the Forms
    -- validation logic.  Nowhere do we involve sales order line.
    --
    -- In addition, we want to make absolutely certain that
    -- Bug 3506231 does not recur.  To prevent that always
    -- check row_elements.exists(i) before accessing
    -- row_elements(i).value
    --
    -- bso Mon Apr 26 18:15:10 PDT 2004
    --
    -- original comment now obsolete:
    -- if production line is in the plan then
    --    if so line number is in the plan then
    --        if the vlaue for so line number is NULL then
    --            x_where_clause := NULL;
    --

    IF (qa_plan_element_api.element_in_plan(row_record.plan_id,
        qa_ss_const.production_line) AND
        row_elements.exists(qa_ss_const.production_line) AND
        row_elements(qa_ss_const.production_line).value IS NOT NULL) THEN

        x_where_clause :=
        'inventory_item_id IN ' ||
            '((SELECT primary_item_id ' ||
              'FROM   wip_repetitive_items_v ' ||
              'WHERE  organization_id = ' || g_org_id || ' AND ' ||
                     'line_code = ''' ||
                      row_elements(qa_ss_const.production_line).value ||
                      ''') ' ||
              'UNION ALL ' ||
             '(SELECT assembly_item_id '||
              'FROM   bom_operational_routings_v '||
              'WHERE  organization_id = ' || g_org_id || ' AND ' ||
                     'line_code = ''' ||
                      row_elements(qa_ss_const.production_line).value ||
                      '''))';

    ELSE
        x_where_clause :=  NULL;
    END IF;

    IF (
        FND_FLEX_KEYVAL.validate_segs(
        operation => 'CHECK_COMBINATION',
        key_flex_code => 'MSTK',
        appl_short_name => 'INV',
        structure_number => '101',
        concat_segments => value,
        data_set => g_org_id,
        where_clause => x_where_clause))  THEN

        id := FND_FLEX_KEYVAL.combination_id;

        IF (id = 0) THEN
            RETURN item_keyflex_error;
        END IF;

        OPEN c2 (id, g_org_id);
        FETCH c2 INTO g_restrict_subinv_code, g_restrict_locators_code,
            g_location_control_code, g_revision_qty_cntrl_code;
        CLOSE c2;

        result_holder.id := id;
        g_item_id := id;

        RETURN ok;

    ELSE
        RETURN item_keyflex_error;

        -- NEED FURTHER WORK: FND_FLEX_KEYVAL.error_message

    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN item_keyflex_error;

END validate_kf_item;

-- Bug 5248191. Wrote a new method to validate Asset Group
-- as Asset Group may be in  production/maintenance org.
-- saugupta Wed, 02 Aug 2006 01:42:09 -0700 PDT
FUNCTION validate_kf_asset_group (row_elements IN ElementsArray,
    row_record IN RowRecord, element_id IN NUMBER, value IN VARCHAR2,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

    id                  NUMBER;
    error_code          NUMBER;
    x_where_clause      VARCHAR2(500);

    CURSOR c2 (i_value VARCHAR2, o_id NUMBER) IS
        SELECT restrict_subinventories_code, restrict_locators_code,
        location_control_code, revision_qty_control_code,inventory_item_id
        FROM mtl_system_items_kfv msi, mtl_parameters mp
        WHERE msi.concatenated_segments = i_value
          AND msi.organization_id = mp.organization_id
          AND mp.maint_organization_id = o_id
          AND rownum = 1;
BEGIN

    IF (value is NULL) THEN
        RETURN ok;
    END IF;

    OPEN c2 (value, g_org_id);
    FETCH c2 INTO g_restrict_subinv_code, g_restrict_locators_code,
        g_location_control_code, g_revision_qty_cntrl_code,id;
    IF c2%NOTFOUND THEN
       CLOSE c2;
       RETURN item_keyflex_error;
    END IF;
    CLOSE c2;

    result_holder.id := id;
    g_item_id := id;

    RETURN ok;

EXCEPTION
    WHEN OTHERS THEN
      RETURN item_keyflex_error;
END validate_kf_asset_group;

FUNCTION validate_kf_comp_item (row_elements IN ElementsArray, row_record IN
    RowRecord, element_id IN NUMBER, value IN VARCHAR2, result_holder IN OUT
    NOCOPY ResultRecord)
    RETURN NUMBER IS

    id                  NUMBER;
    error_code          NUMBER;
    x_where_clause      VARCHAR2(500);

    CURSOR c2 (i_id NUMBER, o_id NUMBER) IS
        select restrict_subinventories_code, restrict_locators_code,
            location_control_code, revision_qty_control_code
        from mtl_system_items
        where inventory_item_id = i_id
        and organization_id = o_id;

BEGIN

    IF (value is NULL) THEN
        RETURN ok;
    END IF;

    -- Bug 3506231.suramasw.
    -- Bug 3593287
    --
    -- A large chunk of code is removed due to error in
    -- initial implementation.  See validate_kf_item for more
    -- info.  For Component Item, we will use a simple relaxed
    -- validation.  Since the validation API is not being used
    -- as LOV, it will suffice to give a relaxed superset
    -- validation instead of a very accurate one.  See QLTRES
    -- for precise comp item LOV conditions which is dependent
    -- on either WIP or BOM depending on what elements are
    -- present in the plan.
    --
    -- bso Mon Apr 26 19:56:05 PDT 2004
    --
    -- x_where_clause :=  NULL;

    IF (
        FND_FLEX_KEYVAL.validate_segs(
        operation => 'CHECK_COMBINATION',
        key_flex_code => 'MSTK',
        appl_short_name => 'INV',
        structure_number => '101',
        concat_segments => value,
        data_set => g_org_id,
        where_clause => x_where_clause))  THEN

        id := FND_FLEX_KEYVAL.combination_id;

        IF (id = 0) THEN
            RETURN comp_item_keyflex_error;
        END IF;

        OPEN c2 (id, g_org_id);
        FETCH c2 INTO g_comp_restrict_subinv_code,
            g_comp_restrict_locators_code, g_comp_location_control_code,
            g_comp_revision_qty_cntrl_code;
        CLOSE c2;

        result_holder.id := id;
        g_comp_item_id := id;

        RETURN ok;

    ELSE
        RETURN comp_item_keyflex_error;

        -- NEED FURTHER WORK: FND_FLEX_KEYVAL.error_message

    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN comp_item_keyflex_error;

END validate_kf_comp_item;


FUNCTION validate_kf_locator (row_elements IN ElementsArray, row_record IN
    RowRecord, element_id IN NUMBER, value IN VARCHAR2, result_holder IN OUT
    NOCOPY ResultRecord)
    RETURN NUMBER IS

    error_code          NUMBER;
    stock_locator       NUMBER;
    negative_inv        NUMBER;
    locator_type        NUMBER;
    locator_flag        NUMBER;
    mandatory_flag      NUMBER;
    id                  NUMBER;
    x_where_clause      VARCHAR2(500);

    CURSOR C1 (org_id NUMBER) IS
        select stock_locator_control_code, negative_inv_receipt_code
        from mtl_parameters
        where organization_id = org_id;


    -- Bug 3381173. The cursor C2 was based on the view mtl_subinventories_val_v,
    -- which is only for storage subs. Based the cursor on mtl_secondary_inventories
    -- and added the where clause to differentiate receiving subs.
    -- kabalakr Tue Jan 27 02:18:59 PST 2004.

    CURSOR C2 (org_id NUMBER) IS
        select locator_type
        FROM  mtl_secondary_inventories
        WHERE organization_id = org_id
        AND ((((SUBINVENTORY_TYPE <> 2) OR (SUBINVENTORY_TYPE IS NULL))
                          AND nvl(disable_date, sysdate+1) > sysdate)
                          OR (SUBINVENTORY_TYPE = 2))
        AND  secondary_inventory_name = g_subinventory;

/*
    CURSOR C2 (org_id NUMBER) IS
        select locator_type
        from mtl_subinventories_val_v
        where organization_id = org_id
        and secondary_inventory_name = g_subinventory;
*/

BEGIN

    OPEN C1(g_org_id);
    FETCH C1 INTO stock_locator, negative_inv;
    CLOSE C1;

    OPEN C2(g_org_id);
    FETCH C2 INTO locator_type;
    CLOSE C2;

    locator_flag := qltinvcb.control(org_control => stock_locator,
                        sub_control => locator_type,
                        item_control => g_location_control_code,
                        restrict_flag => g_restrict_locators_code,
                        neg_flag => negative_inv);

    IF locator_flag = 1 THEN
        IF value IS NULL THEN
            RETURN ok;
        ELSE
            RETURN not_locator_controlled_error;
        END IF;
    END IF;

    mandatory_flag := qa_plan_element_api.get_mandatory_flag(
        row_record.plan_id, element_id);

    IF ( (mandatory_flag = 1) and (value IS NULL) ) THEN

        IF NOT flag_is_set(row_elements(element_id).validation_flag,
            background_element)
            AND NOT flag_is_set(row_elements(element_id).validation_flag,
            valid_element) THEN
            RETURN mandatory_error;
        ELSE
            RETURN ok;
        END IF;
    END IF;

    IF locator_flag = 2 THEN

        IF g_restrict_locators_code = 1 THEN
            x_where_clause := '(disable_date > sysdate or disable_date is null)
                                and subinventory_code = ' ||
                                '''' || g_subinventory || '''' ||
                                ' and inventory_location_id in
                                  (select secondary_locator
                                   from mtl_secondary_locators
                                   where inventory_item_id = g_item_id and
                                   organization_id = ' ||
                                   '''' || g_org_id || '''' ||
                                   ' and subinventory_code = ' ||
                                   '''' || g_subinventory || '''' || '))';

        ELSIF g_restrict_locators_code = 2 THEN
            x_where_clause := '(disable_date > sysdate or disable_date is null)
                                and subinventory_code = ' ||
                                '''' || g_subinventory || '''';

        ELSE
                x_where_clause := null;

        END IF;

        IF (
            FND_FLEX_KEYVAL.validate_segs(
            operation => 'CHECK_COMBINATION',
            appl_short_name => 'INV',
            key_flex_code => 'MTLL',
            structure_number => '101',
            concat_segments => value,
            values_or_ids => 'V',
            data_set => g_org_id,
            where_clause => x_where_clause))  THEN

            id := FND_FLEX_KEYVAL.combination_id;
        END IF;
    END IF;

    IF locator_flag = 3 THEN
        IF (
            FND_FLEX_KEYVAL.validate_segs(
            operation => 'CREATE_COMBINATION',
            appl_short_name => 'INV',
            key_flex_code => 'MTLL',
            structure_number => '101',
            concat_segments => value,
            values_or_ids => 'V',
            data_set => g_org_id,
            where_clause => x_where_clause))  THEN

            id := FND_FLEX_KEYVAL.combination_id;
        END IF;

    END IF;

    IF (id = 0) THEN
        RETURN locator_keyflex_error;
    END IF;

    result_holder.id := id;

    RETURN ok;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN locator_keyflex_error;

END validate_kf_locator;


FUNCTION validate_kf_comp_locator (row_elements IN ElementsArray, row_record
    IN RowRecord,  element_id IN NUMBER, value IN VARCHAR2, result_holder IN
    OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

    error_code NUMBER;
    stock_locator       NUMBER;
    negative_inv        NUMBER;
    locator_type        NUMBER;
    locator_flag        NUMBER;
    mandatory_flag      NUMBER;
    id                  NUMBER;
    x_where_clause      VARCHAR2(500);

    CURSOR C1 (org_id NUMBER) IS
        select stock_locator_control_code, negative_inv_receipt_code
        from mtl_parameters
        where organization_id = org_id;

    --
    -- Bug 6126260
    -- In the where clause replaced g_subinventory
    -- with g_comp_subinventory for getting locator type
    -- for the component subinventory
    -- bhsankar Mon Jul 16 05:51:51 PDT 2007
    --
    CURSOR C2 (org_id NUMBER) IS
        select locator_type
        from mtl_subinventories_val_v
        where organization_id = org_id
        and secondary_inventory_name = g_comp_subinventory;

BEGIN

    OPEN C1(g_org_id);
    FETCH C1 INTO stock_locator, negative_inv;
    CLOSE C1;

    OPEN C2(g_org_id);
    FETCH C2 INTO locator_type;
    CLOSE C2;

    locator_flag := qltinvcb.control(
                        org_control => stock_locator,
                        sub_control => locator_type,
                        item_control => g_comp_location_control_code,
                        restrict_flag => g_comp_restrict_locators_code,
                        neg_flag => negative_inv);

    IF locator_flag = 1 THEN
        IF value IS NULL THEN
            RETURN ok;
        ELSE
            RETURN not_locator_controlled_error;
        END IF;
    END IF;

    mandatory_flag := qa_plan_element_api.get_mandatory_flag(
        row_record.plan_id, element_id);

    IF ( (mandatory_flag = 1) and (value IS NULL) ) THEN
        RETURN mandatory_error;
    END IF;

    IF locator_flag = 2 THEN
        --
        -- Bug 6126260
        -- In the where clause replaced g_subinventory
        -- with g_comp_subinventory for getting locator type
        -- for the component subinventory
        -- bhsankar Mon Jul 16 05:51:51 PDT 2007
        --
        IF g_restrict_locators_code = 1 THEN
            x_where_clause := '(disable_date > sysdate or disable_date is null)
                                and subinventory_code = ' ||
                                '''' || g_comp_subinventory || '''' ||
                                ' and inventory_location_id in
                                  (select secondary_locator
                                   from mtl_secondary_locators
                                   where inventory_item_id = x_item_id and
                                   organization_id = ' ||
                                   '''' || g_org_id || '''' ||
                                   ' and subinventory_code = ' ||
                                   '''' || g_comp_subinventory || '''' || '))';

        ELSIF g_restrict_locators_code = 2 THEN
            x_where_clause := '(disable_date > sysdate or disable_date is null)
                                and subinventory_code = ' ||
                                '''' || g_comp_subinventory || '''';

        ELSE
                x_where_clause := null;

        END IF;

        IF (
            FND_FLEX_KEYVAL.validate_segs(
            operation => 'CHECK_COMBINATION',
            appl_short_name => 'INV',
            key_flex_code => 'MTLL',
            structure_number => '101',
            concat_segments => value,
            values_or_ids => 'V',
            data_set => g_org_id,
            where_clause => x_where_clause))  THEN

            id := FND_FLEX_KEYVAL.combination_id;
        END IF;
    END IF;

    IF locator_flag = 3 THEN
        IF (
            FND_FLEX_KEYVAL.validate_segs(
            operation => 'CREATE_COMBINATION',
            appl_short_name => 'INV',
            key_flex_code => 'MTLL',
            structure_number => '101',
            concat_segments => value,
            values_or_ids => 'V',
            data_set => g_org_id,
            where_clause => x_where_clause))  THEN

            id := FND_FLEX_KEYVAL.combination_id;
        END IF;

    END IF;

    IF (id = 0) THEN
        RETURN comp_locator_keyflex_error;
    END IF;

    result_holder.id := id;

    RETURN ok;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN comp_locator_keyflex_error;

END validate_kf_comp_locator;

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

FUNCTION validate_kf_bill_reference (row_elements IN ElementsArray,
    row_record IN RowRecord, element_id IN NUMBER, value IN VARCHAR2,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

    id                  NUMBER;
    error_code          NUMBER;
    x_where_clause      VARCHAR2(240) := NULL;

    CURSOR c2 (i_id NUMBER, o_id NUMBER) IS
        select restrict_subinventories_code, restrict_locators_code,
            location_control_code, revision_qty_control_code
        from mtl_system_items
        where inventory_item_id = i_id
        and organization_id = o_id;

BEGIN

    IF (value is NULL) THEN
        RETURN ok;
    END IF;

    IF (
        FND_FLEX_KEYVAL.validate_segs(
        operation => 'CHECK_COMBINATION',
        key_flex_code => 'MSTK',
        appl_short_name => 'INV',
        structure_number => '101',
        concat_segments => value,
        data_set => g_org_id,
        where_clause => x_where_clause))  THEN

        id := FND_FLEX_KEYVAL.combination_id;

        IF (id = 0) THEN
            RETURN bill_reference_keyflex_error;
        END IF;

        OPEN c2 (id, g_org_id);
        FETCH c2 INTO g_bill_restrict_subinv_code, g_bill_restrict_locators_code,
            g_bill_location_control_code, g_bill_revision_qty_cntrl_code;
        CLOSE c2;

        result_holder.id := id;
        g_bill_reference_id := id;

        RETURN ok;

    ELSE
        RETURN bill_reference_keyflex_error;

        -- NEED FURTHER WORK: FND_FLEX_KEYVAL.error_message

    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN bill_reference_keyflex_error;

END validate_kf_bill_reference;



FUNCTION validate_kf_routing_reference (row_elements IN ElementsArray,
    row_record IN RowRecord, element_id IN NUMBER, value IN VARCHAR2,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

    id                  NUMBER;
    error_code          NUMBER;
    x_where_clause      VARCHAR2(240) := NULL;

    CURSOR c2 (i_id NUMBER, o_id NUMBER) IS
        select restrict_subinventories_code, restrict_locators_code,
            location_control_code, revision_qty_control_code
        from mtl_system_items
        where inventory_item_id = i_id
        and organization_id = o_id;

BEGIN

    IF (value is NULL) THEN
        RETURN ok;
    END IF;

    IF (
        FND_FLEX_KEYVAL.validate_segs(
        operation => 'CHECK_COMBINATION',
        key_flex_code => 'MSTK',
        appl_short_name => 'INV',
        structure_number => '101',
        concat_segments => value,
        data_set => g_org_id,
        where_clause => x_where_clause))  THEN

        id := FND_FLEX_KEYVAL.combination_id;

        IF (id = 0) THEN
            RETURN rtg_reference_keyflex_error;
        END IF;

        OPEN c2 (id, g_org_id);
        FETCH c2 INTO g_rout_restrict_subinv_code, g_rout_restrict_locators_code,
            g_rout_location_control_code, g_rout_revision_qty_cntrl_code;
        CLOSE c2;

        result_holder.id := id;
        g_routing_reference_id := id;

        RETURN ok;
    ELSE
        RETURN rtg_reference_keyflex_error;

        -- NEED FURTHER WORK: FND_FLEX_KEYVAL.error_message

    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN rtg_reference_keyflex_error;

END validate_kf_routing_reference;


FUNCTION validate_kf_to_locator (row_elements IN ElementsArray, row_record IN
    RowRecord, element_id IN NUMBER, value IN VARCHAR2, result_holder IN OUT
    NOCOPY ResultRecord)
    RETURN NUMBER IS

    error_code          NUMBER;
    stock_locator       NUMBER;
    negative_inv        NUMBER;
    locator_type        NUMBER;
    locator_flag        NUMBER;
    mandatory_flag      NUMBER;
    id                  NUMBER;
    x_where_clause      VARCHAR2(500);

    CURSOR C1 (org_id NUMBER) IS
        select stock_locator_control_code, negative_inv_receipt_code
        from mtl_parameters
        where organization_id = org_id;

    CURSOR C2 (org_id NUMBER) IS
        select locator_type
        from mtl_subinventories_val_v
        where organization_id = org_id
        and secondary_inventory_name = g_to_subinventory;


BEGIN

    OPEN C1(g_org_id);
    FETCH C1 INTO stock_locator, negative_inv;
    CLOSE C1;

    OPEN C2(g_org_id);
    FETCH C2 INTO locator_type;
    CLOSE C2;

    locator_flag := qltinvcb.control(org_control => stock_locator,
                        sub_control => locator_type,
                        item_control => g_location_control_code,
                        restrict_flag => g_restrict_locators_code,
                        neg_flag => negative_inv);

    IF locator_flag = 1 THEN
        IF value IS NULL THEN
            RETURN ok;
        ELSE
            RETURN not_locator_controlled_error;
        END IF;
    END IF;

    mandatory_flag := qa_plan_element_api.get_mandatory_flag(
        row_record.plan_id, element_id);

    IF ( (mandatory_flag = 1) and (value IS NULL) ) THEN

        IF NOT flag_is_set(row_elements(element_id).validation_flag,
            background_element)
            AND NOT flag_is_set(row_elements(element_id).validation_flag,
            valid_element) THEN
            RETURN mandatory_error;
        ELSE
            RETURN ok;
        END IF;
    END IF;

    IF locator_flag = 2 THEN

        IF g_restrict_locators_code = 1 THEN
            x_where_clause := '(disable_date > sysdate or disable_date is null)
                                and subinventory_code = ' ||
                                '''' || g_to_subinventory || '''' ||
                                ' and inventory_location_id in
                                  (select secondary_locator
                                   from mtl_secondary_locators
                                   where inventory_item_id = g_item_id and
                                   organization_id = ' ||
                                   '''' || g_org_id || '''' ||
                                   ' and subinventory_code = ' ||
                                   '''' || g_to_subinventory || '''' || '))';

        ELSIF g_restrict_locators_code = 2 THEN
            x_where_clause := '(disable_date > sysdate or disable_date is null)
                                and subinventory_code = ' ||
                                '''' || g_to_subinventory || '''';

        ELSE
                x_where_clause := null;

        END IF;

        IF (
            FND_FLEX_KEYVAL.validate_segs(
            operation => 'CHECK_COMBINATION',
            appl_short_name => 'INV',
            key_flex_code => 'MTLL',
            structure_number => '101',
            concat_segments => value,
            values_or_ids => 'V',
            data_set => g_org_id,
            where_clause => x_where_clause))  THEN

            id := FND_FLEX_KEYVAL.combination_id;
        END IF;
    END IF;

    IF locator_flag = 3 THEN
        IF (
            FND_FLEX_KEYVAL.validate_segs(
            operation => 'CREATE_COMBINATION',
            appl_short_name => 'INV',
            key_flex_code => 'MTLL',
            structure_number => '101',
            concat_segments => value,
            values_or_ids => 'V',
            data_set => g_org_id,
            where_clause => x_where_clause))  THEN

            id := FND_FLEX_KEYVAL.combination_id;
        END IF;

    END IF;

    IF (id = 0) THEN
        RETURN to_locator_keyflex_error;
    END IF;

    result_holder.id := id;

    RETURN ok;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN to_locator_keyflex_error;

END validate_kf_to_locator;

-- End of inclusions for NCM Hardcode Elements.



FUNCTION validate_keyflex (row_elements IN ElementsArray,
    row_record IN RowRecord, element_id IN NUMBER, value IN VARCHAR2,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

    error_code NUMBER;

BEGIN
    IF flag_is_set( row_elements(element_id).validation_flag, id_derived) THEN
        result_holder.id := row_elements(element_id).id;

-- added the following to include new hardcoded element followup activity
-- saugupta

        IF element_id IN (qa_ss_const.item, qa_ss_const.comp_item,
            qa_ss_const.asset_group, qa_ss_const.asset_activity, qa_ss_const.followup_activity) THEN
             g_item_id := row_elements(element_id).id;
        END IF;

    ELSIF (element_id = qa_ss_const.item) THEN
        error_code := validate_kf_item(row_elements, row_record, element_id,
            value, result_holder);

    ELSIF (element_id = qa_ss_const.comp_item) THEN
        error_code := validate_kf_comp_item(row_elements, row_record,
            element_id, value, result_holder);

    ELSIF (element_id = qa_ss_const.locator) THEN
        error_code := validate_kf_locator(row_elements, row_record, element_id,
            value, result_holder);

    ELSIF (element_id = qa_ss_const.comp_locator) THEN
        error_code := validate_kf_comp_locator(row_elements, row_record,
            element_id, value, result_holder);

    -- Bug 5248191. Modified check for Asset Group to call new function
    -- saugupta Wed, 02 Aug 2006 01:44:07 -0700 PDT
    ELSIF (element_id = qa_ss_const.asset_group) THEN
        error_code := validate_kf_asset_group(row_elements, row_record,
                element_id, value, result_holder);

    ELSIF (element_id = qa_ss_const.asset_activity) THEN
        error_code := validate_kf_item(row_elements, row_record,
            element_id, value, result_holder);

-- added the following to include new hardcoded element followup activity
-- saugupta

    ELSIF (element_id = qa_ss_const.followup_activity) THEN
        error_code := validate_kf_item(row_elements, row_record,
            element_id, value, result_holder);


-- Added the following for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

    ELSIF (element_id = qa_ss_const.bill_reference) THEN
        error_code := validate_kf_bill_reference(row_elements, row_record,
            element_id, value, result_holder);

    ELSIF (element_id = qa_ss_const.routing_reference) THEN
        error_code := validate_kf_routing_reference(row_elements, row_record,
            element_id, value, result_holder);

    ELSIF (element_id = qa_ss_const.to_locator) THEN
        error_code := validate_kf_to_locator(row_elements, row_record,
            element_id, value, result_holder);

-- End of inclusions for NCM Hardcode Elements.


        END IF;

    RETURN error_code;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN keyflex_error;

END validate_keyflex;

--
-- Added to the IF-ELSIF ladder for newly added collection elements
-- for ASO project. New entries are appended after Party_Name
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

FUNCTION get_normalized_id (element_id IN NUMBER, value IN VARCHAR2, x_org_id
    IN NUMBER)
    RETURN NUMBER IS

    id  NUMBER;

BEGIN

    IF (element_id = qa_ss_const.department)
        OR (element_id = qa_ss_const.to_department) THEN
        id := qa_plan_element_api.get_department_id(x_org_id, value);

    ELSIF (element_id = qa_ss_const.job_name) THEN
        id := qa_plan_element_api.get_job_id(x_org_id, value);

    ELSIF (element_id = qa_ss_const.production_line) THEN
        id := qa_plan_element_api.get_production_line_id(x_org_id, value);

    ELSIF (element_id = qa_ss_const.resource_code) THEN
        id := qa_plan_element_api.get_resource_code_id(x_org_id, value);

    ELSIF (element_id = qa_ss_const.vendor_name) THEN
        id := qa_plan_element_api.get_supplier_id(value);

    ELSIF (element_id = qa_ss_const.po_number) THEN
        id := qa_plan_element_api.get_po_number_id(value);

    ELSIF (element_id = qa_ss_const.customer_name) THEN
        id := qa_plan_element_api.get_customer_id(value);

    ELSIF (element_id = qa_ss_const.sales_order) THEN
        id := qa_plan_element_api.get_so_number_id(value);

    ELSIF (element_id = qa_ss_const.order_line) THEN
        id := qa_plan_element_api.get_so_line_number_id(value);

    ELSIF (element_id = qa_ss_const.po_release_num) THEN
        id := qa_plan_element_api.get_po_release_number_id(value,
        g_po_header_id);

    ELSIF (element_id = qa_ss_const.project_number) THEN
        id := qa_plan_element_api.get_project_number_id(value);
    --
    -- Bug 2672396.  Need to keep a cache of the returned project ID
    -- bso Mon Nov 25 17:29:56 PST 2002
    --
        g_project_id := id;

    ELSIF (element_id = qa_ss_const.task_number) THEN
    --
    -- Bug 2672396.  Added g_project_id because task is a dependent element.
    -- bso Mon Nov 25 17:29:56 PST 2002
    --
        id := qa_plan_element_api.get_task_number_id(value, g_project_id);

    ELSIF (element_id = qa_ss_const.rma_number) THEN
        id := qa_plan_element_api.get_rma_number_id(value);

    ELSIF (element_id = qa_ss_const.license_plate_number) THEN
        id := qa_plan_element_api.get_lpn_id(value);

-- added the following to include new hardcoded element Transfer license plate number
-- saugupta

    ELSIF (element_id = qa_ss_const.xfr_license_plate_number) THEN
        id := qa_plan_element_api.get_xfr_lpn_id(value);


    ELSIF (element_id = qa_ss_const.contract_number) THEN
        id := qa_plan_element_api.get_contract_id(value);

    ELSIF (element_id = qa_ss_const.contract_line_number) THEN
        id := qa_plan_element_api.get_contract_line_id(value);

    ELSIF (element_id = qa_ss_const.deliverable_number) THEN
        id := qa_plan_element_api.get_deliverable_id(value);

    ELSIF (element_id = qa_ss_const.work_order) THEN
        id := qa_plan_element_api.get_work_order_id(x_org_id, value);

    --dgupta: Start R12 EAM Integration. Bug 4345492
    ELSIF (element_id = qa_ss_const.asset_instance_number) THEN
        id := qa_plan_element_api.get_asset_instance_id(value);
    --dgupta: End R12 EAM Integration. Bug 4345492

    ELSIF (element_id = qa_ss_const.party_name) THEN
        id := qa_plan_element_api.get_party_id(value);

    ELSIF (element_id = qa_ss_const.item_instance) THEN
        id := qa_plan_element_api.get_item_instance_id(value);

    ELSIF (element_id = qa_ss_const.service_request) THEN
        id := qa_plan_element_api.get_service_request_id(value);

    ELSIF (element_id = qa_ss_const.maintenance_requirement) THEN
        id := qa_plan_element_api.get_maintenance_req_id(value);

    ELSIF (element_id = qa_ss_const.rework_job) THEN
        id := qa_plan_element_api.get_rework_job_id(x_org_id, value);

    ELSIF (element_id = qa_ss_const.counter_name) THEN
        id := qa_plan_element_api.get_counter_name_id(value);

-- Added the following for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

    ELSIF (element_id = qa_ss_const.lot_status) THEN
        id := qa_plan_element_api.get_lot_status_id(value);

    ELSIF (element_id = qa_ss_const.serial_status) THEN
        id := qa_plan_element_api.get_serial_status_id(value);

-- End of inclusions for NCM Hardcode Elements.

-- R12 OPM Deviations. Bug 4345503 Start
    ELSIF (element_id = qa_ss_const.process_batch_num) THEN
        id := qa_plan_element_api.get_process_batch_id(value, x_org_id);
        g_process_batch_id := id;

    ELSIF (element_id = qa_ss_const.process_batchstep_num) THEN
        id := qa_plan_element_api.get_process_batchstep_id
             (value,g_process_batch_id);
        g_process_batchstep_id := id;

    ELSIF (element_id = qa_ss_const.process_operation) THEN
        id := qa_plan_element_api.get_process_operation_id
             (value,g_process_batch_id,g_process_batchstep_id);

    ELSIF (element_id = qa_ss_const.process_activity) THEN
        id := qa_plan_element_api.get_process_activity_id
             (value,g_process_batch_id,g_process_batchstep_id);
        g_process_activity_id := id;

    ELSIF (element_id = qa_ss_const.process_resource) THEN
        id := qa_plan_element_api.get_process_resource_id
             (value,g_process_batch_id,
              g_process_batchstep_id, g_process_activity_id);
        g_process_resource_id := id;
    ELSIF (element_id = qa_ss_const.process_parameter) THEN
        id := qa_plan_element_api.get_process_parameter_id
             (value,g_process_resource_id);

-- R12 OPM Deviations. Bug 4345503 End
--R12 DR Integration . Bug 4345489 start
    ELSIF (element_id = qa_ss_const.repair_order_number) THEN
          id := qa_plan_element_api.get_repair_line_id
                      (value);
    ELSIF (element_id = qa_ss_const.jtf_task_number) THEN
          id := qa_plan_element_api.get_jtf_task_id(value);
--R12 Dr Integration. Bug 4345489 end
    END IF;

    RETURN id;

END get_normalized_id;


FUNCTION validate_normalized (row_elements IN ElementsArray,
    row_record IN RowRecord, element_id IN NUMBER, value IN VARCHAR2,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS


    id            NUMBER;
    sql_statement VARCHAR2(1500);

BEGIN

    --
    -- Bug 2617638.
    -- Added the second conjunct because value can be null if there
    -- is a valid id.  We want the procedure to continue in that case
    -- or the result_holder will be empty.
    -- bso Tue Oct  8 18:42:49 PDT 2002
    --
    IF (value is NULL AND NOT
        flag_is_set(row_elements(element_id).validation_flag, id_derived)) THEN
        RETURN ok;
    END IF;


    IF (flag_is_set(row_elements(element_id).validation_flag, id_derived)) THEN
        id := row_elements(element_id).id;
    ELSE
        id := get_normalized_id (element_id, value, g_org_id);
        IF (id IS NULL) THEN
            RETURN id_not_found_error;
        END IF;
    END IF;

    result_holder.id := id;

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
-- Added to the IF ladder for Maintenance Workorder
--
    IF (element_id = qa_ss_const.job_name) THEN
        g_wip_entity_id := id;
    ELSIF (element_id = qa_ss_const.po_number) THEN
        g_po_header_id := id;
    ELSIF (element_id = qa_ss_const.production_line) THEN
        g_line_id := id;
    ELSIF (element_id = qa_ss_const.work_order) THEN
        g_work_order_id := id;
    END IF;


    RETURN ok;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN id_not_found_error;

END validate_normalized;


FUNCTION valid_against_sql (element_id IN NUMBER, x_org_id IN NUMBER,
    x_value IN VARCHAR2)
    RETURN BOOLEAN IS

    result BOOLEAN;

BEGIN

    -- Transaction Date is validated only in PO Inspection Transaction

    IF (element_id = qa_ss_const.transaction_date) THEN
        result := qa_plan_element_api.validate_transaction_date(
            g_transaction_number);
    --
    -- Bug 8690822
    -- Separating the condition for UOM and Comp UOM,
    -- as Comp Item Id would have to be used for Comp UOM.
    -- skolluku
    --
    ELSIF (element_id = qa_ss_const.uom) THEN
        --OR (element_id = qa_ss_const.comp_uom) THEN
        result := qa_plan_element_api.validate_uom(
            x_org_id, g_item_id, x_value);
    --
    -- Bug 8690822
    -- Pass g_comp_item_id to validate_uom, as the validation has
    -- to be done for Comp UOM and not UOM.
    -- skolluku
    --
    ELSIF (element_id = qa_ss_const.comp_uom) THEN
         result := qa_plan_element_api.validate_uom(
            x_org_id, g_comp_item_id, x_value);

    ELSIF (element_id = qa_ss_const.revision)
        OR (element_id = qa_ss_const.comp_revision) THEN
        result := qa_plan_element_api.validate_revision(
            x_org_id, g_item_id, x_value);

    ELSIF (element_id = qa_ss_const.subinventory)
        OR (element_id = qa_ss_const.comp_subinventory) THEN
        result := qa_plan_element_api.validate_subinventory(
            x_org_id, x_value);

    -- Bug 4558205. OA Framewok Integration UT bug fix.
    -- Lot and serial numbers are not validated in server
    -- side for stand alone QWB.
    -- srhariha. Tue Sep 27 03:14:23 PDT 2005.

    ELSIF (element_id = qa_ss_const.lot_number) THEN
        IF(g_transaction_number is null) OR (g_transaction_number = -1) THEN
           result := qa_plan_element_api.validate_lot_num(x_org_id,
                                                          g_item_id ,
                                                          x_value);
        ELSE
           result := qa_plan_element_api.validate_lot_number(g_transaction_number,
                                                             g_transaction_id,
                                                             x_value);
        END IF;

    ELSIF (element_id = qa_ss_const.serial_number) THEN

        IF(g_transaction_number is null) OR (g_transaction_number = -1) THEN

            result := qa_plan_element_api.validate_serial_num(x_org_id,
                                                              g_item_id,
                                                              g_lot_number,
                                                              g_revision,
                                                              x_value);
        ELSE
            result := qa_plan_element_api.validate_serial_number(g_transaction_number,
                                                                 g_transaction_id,
                                                                 g_lot_number,
                                                                 x_value);
        END IF;

     -- End. Bug 4558205.

    ELSIF (element_id = qa_ss_const.to_op_seq_num)
        OR (element_id = qa_ss_const.from_op_seq_num) THEN
        result := qa_plan_element_api.validate_op_seq_number(
            x_org_id, g_line_id,
            g_wip_entity_id, x_value);

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

    ELSIF (element_id = qa_ss_const.maintenance_op_seq) THEN
        result := qa_plan_element_api.validate_maintenance_op_seq(
                                 x_org_id, g_work_order_id, x_value);
--
-- End of inclusions for Bug 2588213
--


    ELSIF (element_id = qa_ss_const.po_line_num) THEN

        g_po_line_number := x_value;
        result := qa_plan_element_api.validate_po_line_number(
            g_po_header_id, x_value);

    ELSIF (element_id = qa_ss_const.po_shipment_num) THEN
        result := qa_plan_element_api.validate_po_shipments(
            g_po_line_number,
            g_po_header_id, x_value);

    ELSIF (element_id = qa_ss_const.receipt_num) THEN
        result := qa_plan_element_api.validate_receipt_number(x_value);

/*
    ELSIF (element_id = qa_ss_const.comp_serial_number) THEN
        result := TRUE;

    ELSIF (element_id = qa_ss_const.comp_lot_number) THEN
        result := TRUE;

    ELSIF (element_id = qa_ss_const.quantity) THEN
        result := TRUE;

    ELSIF (element_id = qa_ss_const.asset_number) THEN
        result := TRUE;
  */
-- Added the following for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

    ELSIF (element_id = qa_ss_const.to_subinventory) THEN
        result := qa_plan_element_api.validate_to_subinventory(
            x_org_id, x_value);

/*
    ELSIF (element_id = qa_ss_const.lot_status) THEN
        result := qa_plan_element_api.validate_lot_status(x_value);

    ELSIF (element_id = qa_ss_const.concurrent_request_id) THEN
        result := TRUE;

    ELSIF (element_id = qa_ss_const.nonconformance_code) THEN
        result := TRUE;

    ELSIF (element_id = qa_ss_const.date_opened) THEN
        result := TRUE;

    ELSIF (element_id = qa_ss_const.date_closed) THEN
        result := TRUE;

    ELSIF (element_id = qa_ss_const.days_to_close) THEN
        result := TRUE;
 */
-- the above code and the code above to_subinventory procedure was commented
-- out to directly put an else clause which validates to TRUE since there is no
-- special validation - suramasw Thu Oct 24 05:14:54 PDT 2002

    ELSE
       result := TRUE;


    END IF;

    RETURN result;

END valid_against_sql;


FUNCTION validate_values  (plan_id IN NUMBER, element_id IN NUMBER,
    value IN VARCHAR2)
    RETURN NUMBER IS

    sql_string VARCHAR2(1500);
    ok_flag    varchar2(240);

    -- Bug 3111310.  Used to have a SQL that select from
    -- dual which is inefficient
    -- saugupta Aug 2003

    CURSOR c1 (p_id NUMBER, e_id NUMBER, v VARCHAR2) IS
        select '1'
         from qa_plan_char_value_lookups
         where plan_id = p_id
         and   char_id = e_id
         and short_code = v;
BEGIN

    IF (value is NULL) THEN
        RETURN ok;
    END IF;

    OPEN c1(plan_id, element_id, value);
    FETCH c1 INTO ok_flag;
    CLOSE c1;

    IF ok_flag = '1' THEN
       RETURN ok;
    ELSE
       RETURN no_values_error;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN no_data_found_error;

END validate_values;

 -- Bug 4343758. OA Framework Integration project.
 -- Added a new procedure. If the primitive values are validated
 -- then it must be copied to package globals, which will be used
 -- to validate other dependent elements.
 -- srhariha. Thu May 26 02:38:04 PDT 2005.

PROCEDURE copy_primitive_to_global(p_element_id IN NUMBER, p_value IN VARCHAR2) IS

BEGIN

   IF (p_element_id = qa_ss_const.subinventory) THEN
       g_subinventory := p_value;

   ELSIF (p_element_id = qa_ss_const.lot_number) THEN
       g_lot_number := p_value;

   -- Added the following condition to enable History Records
   -- to be created when History Relationship is present.
   -- Bug 2700230.suramasw Mon Dec 23 03:06:30 PST 2002.

   ELSIF (p_element_id = qa_ss_const.to_subinventory) THEN
       g_to_subinventory := p_value;

    -- Bug 4558205. OA Framewok Integration UT bug fix.
    -- Lot and serial numbers are not validated in server
    -- side for stand alone QWB. Adding revision for serial
    -- number validation.
    -- srhariha. Tue Sep 27 03:14:23 PDT 2005.

   ELSIF  (p_element_id = qa_ss_const.revision) THEN
       g_revision := p_value;
   --
   -- Bug 6126260
   -- Added the extra condition to assign the value of the
   -- component subinventory to the global variable which
   -- would later be used to validate the comp subinventory locator.
   -- bhsankar Thu Jan  4 20:58:23 PST 2007
   --
   ELSIF (p_element_id = qa_ss_const.comp_subinventory) THEN
       g_comp_subinventory := p_value;

   END IF;

END copy_primitive_to_global;



FUNCTION validate_primitive (plan_id IN NUMBER, row_elements IN ElementsArray,
    row_record IN RowRecord, element_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER IS

    sql_statement       VARCHAR2(1500);
    valid_element       BOOLEAN;

BEGIN

    IF (value IS NULL) THEN
        RETURN ok;
    END IF;

-- The following code was put to reduce element_id check.The existing code
-- for element_id check is commented out after the new code.
-- suramasw Thu Oct 24 05:14:54 PDT 2002.

    IF qa_plan_element_api.values_exist(plan_id, element_id) THEN
        RETURN validate_values(plan_id, element_id, value);
    END IF;

/*
    IF element_id IN (
        qa_ss_const.disposition,
        qa_ss_const.disposition_action,
        qa_ss_const.disposition_source,
        qa_ss_const.disposition_status,
        qa_ss_const.nonconformance_source,
        qa_ss_const.nonconform_severity,
        qa_ss_const.nonconform_priority,
        qa_ss_const.nonconformance_type,
        qa_ss_const.nonconformance_status) THEN

        RETURN validate_values(plan_id, element_id, value);
    END IF;
*/

    valid_element := valid_against_sql(element_id, g_org_id, value);

    IF valid_element THEN

        -- Bug 4343758. OA Framework Integration project.
        -- If the primitive values are validated then it
        -- must be copied to package globals, which will
        -- be used to validate other dependent elements.
        -- Existing logic wrapped into a new procedure.
        -- srhariha. Thu May 26 02:38:04 PDT 2005.

        copy_primitive_to_global(p_element_id => element_id,
                                 p_value => value);

        RETURN ok;

    ELSE
        RETURN value_not_in_sql_error;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN value_not_in_sql_error;

END validate_primitive;


FUNCTION validate_sql (element_id IN NUMBER, value IN VARCHAR2, x_org_id IN
    NUMBER, x_user_id IN NUMBER)
    RETURN NUMBER IS

    sql_string VARCHAR2(1500);

BEGIN

    IF (value IS NULL) THEN
        RETURN ok;
    END IF;

    sql_string := qa_plan_element_api.get_sql_validation_string(element_id);

    sql_string := qa_chars_api.format_sql_for_validation (sql_string,
        x_org_id, x_user_id);

    IF qa_plan_element_api.value_in_sql (sql_string, value) THEN
        RETURN ok;

    ELSE
        RETURN sql_validation_error;

    END IF;

    EXCEPTION WHEN OTHERS THEN
        RETURN sql_validation_error;

END validate_sql;


FUNCTION validate_spec_limits (row_record IN RowRecord, element_id IN NUMBER,
    value IN VARCHAR2)
    RETURN NUMBER IS

    lower_limit         VARCHAR2(150);
    upper_limit         VARCHAR2(150);
    datatype            NUMBER;

BEGIN

    IF (value IS NULL) THEN
        RETURN ok;
    END IF;

    -- gets the spec limits and converts them to canonical
    -- BUG 3303285
    -- ksoh Mon Dec 29 13:33:02 PST 2003
    -- call overloaded get_spec_limits that takes in plan_id
    -- it performs uom conversion
    qa_plan_element_api.get_spec_limits(row_record.plan_id, row_record.spec_id,
         element_id,
         lower_limit, upper_limit);

    IF (lower_limit IS NULL) OR (upper_limit IS NULL) THEN
        RETURN ok;
    END IF;

    datatype := qa_plan_element_api.get_element_datatype(element_id);

    IF qltcompb.compare(value, 6, lower_limit, null, datatype) THEN
        -- if (value < lower_limit) then
        RETURN lower_limit_error;
    END IF;

    IF qltcompb.compare(value, 5, upper_limit, null, datatype) THEN
        -- if (value > upper_limit) then
        RETURN upper_limit_error;
    END IF;

    RETURN ok;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN spec_error;

END validate_spec_limits;


FUNCTION validate_char (value IN VARCHAR2, result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

BEGIN

   result_holder.canonical_value := substr(value, 1, 150);

   RETURN ok;

END validate_char;


FUNCTION validate_number (value IN VARCHAR2, length IN NUMBER,
    precision IN NUMBER, result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

BEGIN

    -- anagarwal Fri Dec 12 12:04:39 PST 2003
    -- Bug 3303276
    -- Decimal precision of numbers was not being used. The new call
    -- uses the passed precision to round off the number according to
    -- the precision specified in the plan
    -- We use qltdate.number_to_cannon to ensure that there are no errors
    -- if the number is in format 1,2345 instead of 1.2345 (a German user
    -- perhaps).

    --result_holder.canonical_value := qltdate.any_to_number(value);
    result_holder.canonical_value := qltdate.number_to_canon(
                                      round(qltdate.any_to_number(value),
                                      nvl(precision, 240)));

    RETURN ok;


    EXCEPTION
        WHEN OTHERS THEN
            RAISE;

END validate_number;


FUNCTION validate_date (value IN VARCHAR2, result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

BEGIN
    -- convert it to canonical format
    result_holder.canonical_value := qltdate.any_to_canon(value);
    RETURN ok;

    EXCEPTION
        WHEN  OTHERS THEN
            RAISE;

END validate_date;


-- rkaza. bug 3220767. 10/29/2003. Follwing function not used.
-- When coming from ss, we have to do the tz conversion in the middle tier.
-- because server side initializations required for tz conversion to work
-- on server side would not be done by ss tech stack as in forms.
FUNCTION validate_datetime (value IN VARCHAR2, result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

-- Bug 4965371
-- Variable to hold the date converted
-- from the User format into DD-MON-RRRR HH24:MI:SS
-- format
-- nutngare Sun Feb 12 04:31:28 PST 2006

l_value varchar2(50);

BEGIN

    -- Bug 4965371
    -- Convert the format of the argument value which would be '2005/12/21 17:09:36' to the
    -- format compatible to the fnd_date.displayDT_to_date function which needs the value to
    -- be in the format 'DD-MON-RRRR HH24:MI:SS'. So used qltdate.any_to_user_dt to convert
    -- the value to the format 'DD-MON-RRRR HH24:MI:SS' and then call the Fnd_date functions.
    -- ntungare Sun Feb 12 04:35:39 PST 2006

    l_value := qltdate.any_to_user_dt(value);

    -- convert the value to server tz and then to canonical.
    -- Bug 4965371
    -- Using the converted value
    -- ntungare Sun Feb 12 04:35:20 PST 2006

    result_holder.canonical_value :=
        Fnd_date.date_to_canonical(fnd_date.displayDT_to_date(l_value));

    RETURN ok;

    EXCEPTION
        WHEN  OTHERS THEN
          -- Bug 3318462. This exception is raised when date coming
          -- from self service and mobile, since data is in server
          -- timezone from history plans and it is required to distinguish
          -- data from Forms.
          -- saugupta Fri, 06 Feb 2004 00:03:57 -0800 PDT
          IF SQLCODE = -1861 THEN
             RETURN -1861;
          ELSE
            RAISE;
          END IF;

END validate_datetime;


FUNCTION validate_datatype  (plan_id IN NUMBER, element_id IN NUMBER,
    value IN VARCHAR2, row_elements IN OUT NOCOPY ElementsArray,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS

    data_type   NUMBER;
    len         NUMBER;
    precision   NUMBER;
    error_code  NUMBER;
    val_len     NUMBER;
     -- Bug 3318462. New variable to get actual datatype
     -- of date time elements to distinguish between
     -- softcoded and hardcoded eements
     actual_datatype NUMBER;

BEGIN
    -- bug 3178307. rkaza. 10/06/2003.
    -- Modifed the function for Timezone Support.

    data_type := qa_chars_api.datatype(element_id);

    len    := qa_chars_api.display_length(element_id);

     -- Bug 3318462. History child plans showing wrong
     -- client timezone. It is saving date time in client timezone
     -- for child plans due to this, difference is again added when
     -- viewing child plans
     -- saugupta Wed, 14 Jan 2004 04:39:30 -0800 PDT
     actual_datatype := qa_plan_element_api.get_actual_datatype(element_id);

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level.
--
-- Validation would be appropriate when decimal precision is
-- taken from plan definition rather than element setup
--
-- Before this change
--    precision := qa_chars_api.decimal_precision(element_id);
-- After this change
--    precision := nvl(qa_plan_element_api.decimal_precision(plan_id, element_id),
--                     qa_chars_api.decimal_precision(element_id));
--
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--

    precision := nvl(qa_plan_element_api.decimal_precision(plan_id, element_id),
                     qa_chars_api.decimal_precision(element_id));

    IF (data_type = qa_ss_const.date_datatype) THEN
        error_code := validate_date(value, result_holder);

    ELSIF (data_type = qa_ss_const.datetime_datatype) THEN
        val_len := length(value);
        if substr(value, val_len - 1, 2) = '.0' then
           -- all hardcoded datetimes in self service come here.
           -- When coming from Self service, a '.0' is appended to the value
           -- because of an implicit conversion from date to string.
           -- So chop it off.
           error_code := validate_date(substr(value, 1, val_len-2), result_holder);
        else
           -- softcoded datetime elements from ss and mobile comes here
           -- From ss, values are already in server tz and in canonical format
           -- values from Mobile are also in server timezone
           -- saugupta Fri, 06 Feb 2004 00:14:24 -0800 PDT

           -- Bug 3318462. Also all forms datetime elements come here
           -- Forms calls validate_api and data for softcoded is coming
           -- from DISPLAYxx. So for History Plans softcoded date is getting saved in
           -- client timezone. To correct it, using get_actual_datatype() to check the
           -- real datatype of the element. If it is character than call validate_datetime
           -- else its hardcoded so calling validate_date.
           -- saugupta Wed, 14 Jan 2004 04:40:08 -0800 PDT

           IF (actual_datatype = qa_ss_const.character_datatype) THEN
               error_code := validate_datetime(value, result_holder);

               -- Bug 3318462. From ss and mobile softcoded datetime elements are
               -- in server timezone. Above call will throw and exception. Returned
               -- the error number from validate_datetime() and handled it in below
               -- statement to make sure that ss and mobile calls correct function.
               -- saugupta Fri, 06 Feb 2004 00:18:38 -0800 PDT

               IF (error_code = -1861 ) THEN
                 error_code := validate_date(value, result_holder);
               END IF;
           ELSE
               error_code := validate_date(value, result_holder);
           END IF;
        end if;

    ELSIF (data_type = qa_ss_const.number_datatype) THEN
        error_code :=  validate_number(value, len, precision,
            result_holder);
        --
        -- Bug 3402251.  In order to use the round-up values in
        -- further assign-a-value actions, the canonical value
        -- needs to be copied back to the row element, readjusted
        -- to client format.
        -- bso Mon Feb  9 21:42:20 PST 2004
        --
        row_elements(element_id).value := to_char(
            fnd_number.canonical_to_number(result_holder.canonical_value));

    -- Bug 2427337. Added following elsif condition for longcomment datatype
    -- rponnusa Tue Jun 25 06:15:48 PDT 2002

    ELSIF (data_type = qa_ss_const.comment_datatype) THEN
        error_code := validate_comment(value, result_holder);

    ELSE
        error_code := validate_char(value, result_holder);

    END IF;

    RETURN ok;

    EXCEPTION
        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            RETURN invalid_number_error;

        WHEN INVALID_DATE OR INVALID_DATE_FORMAT THEN
            RETURN invalid_date_error;

        WHEN OTHERS THEN
            RETURN unknown_error;

END validate_datatype;


FUNCTION evaluate_trigger (condition_record IN ConditionRecord, plan_id IN NUMBER, element_id IN
    NUMBER, value IN VARCHAR2, spec_id IN NUMBER)
    RETURN BOOLEAN IS

    low_value   VARCHAR2(150);
    high_value  VARCHAR2(150);
    datatype    NUMBER;

BEGIN

    IF condition_record.low_value_other IS NULL THEN
        -- BUG 3303285
        -- ksoh Mon Jan  5 12:55:13 PST 2004
        -- replaced get_spec_limits, which does not retrieve the
        -- correct low high value as it always retrieve reasonable limits
        --
        --   qa_plan_element_api.get_spec_limits(spec_id, element_id,
        --        low_value, high_value);
        qa_plan_element_api.get_low_high_values(plan_id, spec_id, element_id,
              condition_record.low_value_lookup, condition_record.high_value_lookup,
              low_value, high_value);

    ELSE
            low_value  := condition_record.low_value_other;
            high_value := condition_record.high_value_other;

    END IF;

    datatype := qa_plan_element_api.get_element_datatype(element_id);

    IF qltcompb.compare(value, condition_record.operator, low_value,
        high_value, datatype) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END evaluate_trigger;

--
-- Bug 2976810
-- this function modified to a procedure to give back the value of a token
-- as well as the datatype of this value.
-- ilawler Tue May 27 13:34:49 2003
--
PROCEDURE get_token_value (p_token_name                 IN  VARCHAR2,
                           p_plan_char_action_id        IN  NUMBER,
                           p_row_elements               IN  ElementsArray,
                           x_token_value                OUT NOCOPY VARCHAR2,
                           x_token_datatype             OUT NOCOPY NUMBER)
 IS

    element_id          NUMBER;
    token_value         VARCHAR2(2150);

    --move the lookup of the datatype into this cursor
/*    CURSOR c1 (token VARCHAR2, pca_id NUMBER) IS
       SELECT qpcao.char_id, qpcv.datatype
       FROM qa_plan_char_action_outputs qpcao, qa_plan_chars_v qpcv
       WHERE plan_char_action_id = pca_id AND
             token_name = token AND
             qpcao.char_id = qpcv.char_id; */

    -- Bug 4958778. SQL Repository Fix SQL ID: 15008783
    CURSOR c1 (token VARCHAR2, pca_id NUMBER) IS
        SELECT
          qpcao.char_id,
          qpcv.datatype
        FROM qa_plan_char_action_outputs qpcao,
          qa_chars qpcv
        WHERE plan_char_action_id = pca_id
          AND token_name = token
          AND qpcao.char_id = qpcv.char_id;


 BEGIN
    -- rkaza. 05/07/2003. Bug 2946779. Converting token name to upper case
    -- before comparing with token variable

    OPEN c1 (upper(p_token_name), p_plan_char_action_id);
    FETCH c1 INTO element_id, x_token_datatype;
    CLOSE c1;

    x_token_value := p_row_elements(element_id).value;

END get_token_value;


--
-- Bug 2976810
-- this function performs the sql text/formula associated with an
-- 'Assign a value to a collection element' plan action.  This function has been
-- modified to use dbms_sql and bind variables to remove our dependence on
-- an exemption.  This function was also expanded to do some of the data formatting
-- done by import(qltdactb.do_assignment).
-- ilawler Tue May 27 13:34:49 2003
--
FUNCTION get_assigned_value (plan_char_action_id        IN NUMBER,
                             message                    IN VARCHAR2,
                             row_elements               IN ElementsArray)
    RETURN VARCHAR2
IS
    assigned_value              VARCHAR2(150);

    -- Bug 5150287. SHKALYAN 02-Mar-2006.
    -- Increased the column width of final_stmt from 500 to 2500.
    -- In 'Assign a value' action if we populate a comment datatype element
    -- directly with a value(without tokens) which is approximately 2000
    -- characters then this variable would not be able to hold the value.
    final_stmt                  VARCHAR2(2500);

    len                         NUMBER;
    i                           NUMBER;
    k                           NUMBER := 1;
    ignore                      NUMBER;
    assigned_datatype           NUMBER;
    assigned_precision          NUMBER;
    curr_char                   VARCHAR2(30);
    token_name                  VARCHAR2(30);
    token_datatype              NUMBER;
    bind_var_name               VARCHAR2(100);

    -- Bug 5150287. SHKALYAN 02-Mar-2006.
    -- Increased the column width of token_value from 150 to 2000.
    -- If the value of token_value which is going to be copied to
    -- the target element is more than 150 characters then ORA-06502
    -- would be raised. To prevent that column width has been increased.
    token_value                 VARCHAR2(2000) DEFAULT NULL;

    TYPE tokenValTab IS TABLE OF token_value%TYPE INDEX BY BINARY_INTEGER;
    token_vals                  tokenValTab;

    assignment_type             VARCHAR2(1);

    -- Bug 5150287. SHKALYAN 02-Mar-2006.
    -- Increased the column width of return_value_char from 1500 to
    -- 2000 for the same reason mentioned above for token_value.
    return_value_char           VARCHAR2(2000);

    return_value_num            NUMBER;
    return_value_date           DATE;

    c1                          NUMBER;

    --besides fetching the assign type, get the datatype of the assign target
/*    CURSOR c2 (pca_id NUMBER) IS
        SELECT qpca.assign_type, qpcv.datatype, qpcv.decimal_precision
        FROM qa_plan_char_actions qpca, qa_plan_chars_v qpcv
        WHERE qpca.plan_char_action_id = pca_id AND
              qpca.assigned_char_id = qpcv.char_id; */

      -- Bug 4958778. SQL Repository Fix SQL ID: 15008799
      -- There is also an existing bug in the original query,
      -- namely qpc.plan_id is not used as a condition.
      -- It is hereby fixed.
      -- bso Fri Feb  3 11:31:47 PST 2006
      CURSOR c2 (pca_id NUMBER) IS
        SELECT
          qpca.assign_type,
          qc.datatype,
          nvl(qpc.decimal_precision, qc.decimal_precision) decimal_precision
        FROM qa_chars qc,
          qa_plan_chars qpc,
          qa_plan_char_actions qpca,
          qa_plan_char_action_triggers qpcat
        WHERE
          qpca.plan_char_action_trigger_id = qpcat.plan_char_action_trigger_id
          AND qpca.plan_char_action_id = pca_id
          AND qpc.plan_id = qpcat.plan_id
          AND qpc.char_id = qpca.assigned_char_id
          AND qc.char_id = qpca.assigned_char_id;

BEGIN

    i := 1;
    len := NVL(length (message), 0);

    WHILE i <= len LOOP
        curr_char := substr(message, i, 1);
        IF curr_char <> '&' THEN
            final_stmt := final_stmt || curr_char;
            i := i + 1;

        ELSE   -- we're at an ampersand

            i := i + 1;    -- skip over ampersand
            token_name := '';
            curr_char := substr(message, i, 1);

            WHILE (curr_char between '0' and '9')
                OR (curr_char between 'A' and 'Z')
                OR (curr_char between 'a' and 'z')
            LOOP
                token_name := token_name || curr_char;
                i := i + 1;
                curr_char := substr(message, i, 1);
            END LOOP;

            -- at this point the token name is formed so get the value and datatype
            get_token_value (p_token_name               => token_name,
                             p_plan_char_action_id      => plan_char_action_id,
                             p_row_elements             => row_elements,
                             x_token_value              => token_value,
                             x_token_datatype           => token_datatype);

            --based on this datatype we add different text to our sql statement
            bind_var_name := ':' || k;

            -- Bug 5150287. SHKALYAN 02-Mar-2006.
            -- Included comment datatype(y_datatype=4) in the following IF loop
            -- Before this fix if we try to assign a value to a comment
            -- datatype element the action would fire but the value would not
            -- be copied to the target element (or) would error out in SSQR.
            if token_datatype in (1,4) then
               bind_var_name := bind_var_name;
            elsif token_datatype = 2 then
               bind_var_name:= 'nvl(qltdate.canon_to_number(' || bind_var_name || '), 0)';
            elsif token_datatype = 3 then
               bind_var_name := 'qltdate.any_to_date(' || bind_var_name || ')';

            -- Bug 3179845. Timezone Project. rponnusa Thu Oct 30 00:47:31 PST 2003
            elsif token_datatype = 6 then -- datetime
               bind_var_name := 'qltdate.any_to_datetime(' || bind_var_name || ')';
            end if;

            --add the token value to the token value array and append the bind variable
            --reference string to the statement
            token_vals(k) := token_value;
            final_stmt := final_stmt || bind_var_name ;

            k := k + 1;

        END IF;

    END LOOP;

    -- anagarwa Wed Jan  7 16:27:11 PST 2004
    -- Bug 3340004 actions are not being fired in SSQR
    -- The reason was that template plans have an extra new line character
    -- at the end of the sql for date opened. This extran new line is now
    -- being removed along with comma and forward slash
    -- IMPORTANT NOTE: DO NOT REMOVE THE NEW LINE CHARACTER IN FOLLOWING
    -- RTRIM EXPRESSION. IT HAS BEEN PUT TO FIX BUG 3340004
    final_stmt := rtrim(final_stmt, ' ;/
');

    OPEN c2 (plan_char_action_id);
    FETCH c2 INTO assignment_type, assigned_datatype, assigned_precision;
    CLOSE c2;

    -- if it's a formula type assign, wrap the action text in a select from dual
    IF assignment_type = 'F' THEN
        final_stmt := 'SELECT ' || final_stmt || ' FROM DUAL';
    END IF;

    c1 := dbms_sql.open_cursor;
    dbms_sql.parse(c1, final_stmt, dbms_sql.native);

    --go through the token_vals array and do the bindings
    k := token_vals.FIRST;
    WHILE (k IS NOT NULL) LOOP
       dbms_sql.bind_variable(c1, ':' || to_char(k), token_vals(k));
       k := token_vals.NEXT(k);
    END LOOP;

    --
    -- Bug 4635316
    -- Binding the value of the Global parameter Org Id set in the function
    -- validate_row
    -- ntungare Mon Oct 10 01:14:31 PDT 2005
    --
    IF INSTR(final_stmt, QA_SS_CONST.bindvar_param_org_id, 1)<> 0 THEN
       dbms_sql.bind_variable(c1, QA_SS_CONST.bindvar_param_org_id, g_org_id);
    END IF;

    --
    -- Bug 4635316
    -- Binding the value of the Global parameter User Id set in the function
    -- validate_row
    -- ntungare Mon Oct 10 01:14:31 PDT 2005
    --
    IF INSTR(final_stmt, QA_SS_CONST.bindvar_param_user_id, 1) <> 0 THEN
      dbms_sql.bind_variable(c1, QA_SS_CONST.bindvar_param_user_id, g_user_id);
    END IF;

    --set up the type of the output we expect

    -- Bug 5150287. SHKALYAN 02-Mar-2006.
    -- Included comment datatype(assigned_datatype=4) in the following IF loop.
    -- Before this fix if we try to assign a value to a comment datatype
    -- element the action would fire but the value would not be copied to
    -- the target element in SSQR. Also increased the width of
    -- return_value_char from 1500 to 2000.
    IF assigned_datatype in (1,4) THEN
       dbms_sql.define_column(c1, 1, return_value_char, 2000);
    ELSIF assigned_datatype = 2 THEN
       dbms_sql.define_column(c1, 1, return_value_num);
    ELSIF assigned_datatype = 3 THEN
       -- Bug 3179845. Timezone Project. rponnusa Thu Oct 30 00:47:31 PST 2003

       -- Assign value from Date element to Date element fail if
       -- col defined as char type. To fix this get the value as Date type
       -- dbms_sql.define_column(c1, 1, return_value_char, 1500);
       dbms_sql.define_column(c1, 1, return_value_date);

    ELSIF assigned_datatype = 6 THEN -- datetime
       dbms_sql.define_column(c1, 1, return_value_date);
    END IF;

    --execute the cursor and fetch the value into return_value_char
    ignore := dbms_sql.execute(c1);

    IF dbms_sql.fetch_rows(c1)>0 THEN

       -- Bug 5150287. SHKALYAN 02-Mar-2006.
       -- Included assigned_datatype=4 also in the following loop for the
       -- same reason mentioned few lines above.
       IF assigned_datatype in (1,4) THEN

          dbms_sql.column_value(c1, 1, return_value_char);

       ELSIF assigned_datatype = 2 THEN

          dbms_sql.column_value(c1, 1, return_value_num);
          return_value_char := to_char(round(return_value_num, nvl(assigned_precision, 0)));

       ELSIF assigned_datatype = 3 THEN
          -- Bug 3179845. Timezone Project. rponnusa Thu Oct 30 00:47:31 PST 2003

          -- dbms_sql.column_value(c1, 1, return_value_char);
          dbms_sql.column_value(c1, 1, return_value_date);
          return_value_char := qltdate.date_to_canon(return_value_date);

       ELSIF assigned_datatype = 6 THEN -- datetime

          dbms_sql.column_value(c1, 1, return_value_date);
          return_value_char := qltdate.date_to_canon_dt(return_value_date);

       END IF;
    ELSE
       --if we didn't get anything then just give back a null
       return_value_char := NULL;
    END IF;
    dbms_sql.close_cursor(c1);

    RETURN return_value_char;

    EXCEPTION WHEN OTHERS THEN
        RAISE;

END get_assigned_value;

-- Bug 3397484. Added row_record to the function required to make a call to
-- validate_keyflex and validate_normalized.
-- saugupta Wed, 28 Jan 2004 07:59:39 -0800 PDT

-- 12.1 QWB Usability Improvements
-- Added 2 new parameters p_ssqr_operation
-- and ordered_array
FUNCTION perform_immediate_actions (action_id IN NUMBER,
                                    element_id IN NUMBER,
                                    row_record IN RowRecord,
                                    message IN VARCHAR2,
                                    plan_char_action_id IN NUMBER,
                                    row_elements IN OUT NOCOPY ElementsArray,
                                    return_results_array IN OUT NOCOPY ResultRecordArray,
                                    message_array IN OUT NOCOPY MessageArray,
                                    result_holder IN OUT NOCOPY ResultRecord,
                                    ordered_array IN OUT NOCOPY ElementInfoArray,
                                    p_ssqr_operation IN NUMBER DEFAULT NULL
                                   )
    RETURN NUMBER IS

    target_element        NUMBER;

    -- Bug 5150287. SHKALYAN 02-Mar-2006.
    -- Increased the column width of assigned_value from 150 to 2000.
    -- If the value of variable assigned_value which is going to store the
    -- value to be assigned  to the target element is more than 150 characters
    -- then ORA-06502 would be raised. To prevent that column width has been
    -- increased to the maximum supported by Quality.
    assigned_value        VARCHAR2(2000);
    message_index         NUMBER;
    assigned_element      VARCHAR2(30);

    -- Bug 3397484. Added the variables to make a call to validate_keyflex and validate_normalized.
    -- This is required for backward assignment.
    -- saugupta Wed, 28 Jan 2004 08:01:37 -0800 PDT.
    back_result_holder    ResultRecord;
    error_code            NUMBER;

    -- Bug 3679762. Added the following cursor to validte whether the target column
    -- for "assign a value" action exist/enabled  in collection plan.
    -- srhariha.Wed Jun 16 06:54:06 PDT 2004

cursor validate_target(p_plan_id number,p_char_id number) is
select 1
from qa_plan_chars
where plan_id = p_plan_id
and char_id = p_char_id
and enabled_flag = 1;

l_target_exists number;

--
-- Bug 4635316.
-- The variable altered_message would hold the formula or the sql text used in the
-- assign a value action and passed to this fucntion in the variable message. If
-- the sql text has reference to parameter fields like org_id and user_id then
-- they are replaced with the BindVars and the resultant string is stored in this
-- variable altered_message
-- ntungare Sun Oct 16 20:36:17 PDT 2005
--
altered_message VARCHAR2(2000);

BEGIN

    -- We need to take both the row_elements and return_results_array
    -- because we allow both forward and backward assignment in the assign
    -- a value action.
    --
    -- If it is forward assignment then row_elements will have the
    -- correct value and will be validated as the validation proceeds.
    --
    -- If it is backward assignment then we must modify the
    -- return_results_array to indicate the change, but this value
    -- will NOT be validated.

    IF (action_id = qa_ss_const.display_message_action) THEN

        message_index := message_array.count;
        message_array(message_index).element_id := element_id;
        message_array(message_index).action_type  :=
            qa_ss_const.display_message_action;
        message_array(message_index).message    := message;

    ELSIF (action_id = qa_ss_const.reject_input_action) THEN

        message_index := message_array.count;
        message_array(message_index).element_id := element_id;
        message_array(message_index).action_type  :=
            qa_ss_const.reject_input_action;
        message_array(message_index).message    := message;

        -- This can be used in self service, and if the action
        -- is fired, this will be consiidered an error.  Therrfore,
        -- we should return reject_an_entry_error.

        RETURN reject_an_entry_error;

    ELSIF (action_id = qa_ss_const.assign_value_action) THEN

        target_element := qa_plan_element_api.get_target_element(
            plan_char_action_id);


          -- Bug 3679762. Check whether target column of assign a value action
          -- exist/enabled in collection plan.If it doesnot exist/enabled return
          -- the corresponding error code.
          -- srhariha. Wed Jun 16 06:54:06 PDT 2004

        l_target_exists:= -1;

        open validate_target(row_record.plan_id,target_element);
        fetch validate_target into l_target_exists;

        if (validate_target%NOTFOUND) then
            close validate_target;
            return missing_assign_column;
        end if;

        close validate_target;

        --
        -- Bug 4635316.
        -- The variable message would hold the formula or the sql text used in the
        -- assign a value action. If the sql text has reference to parameter fields
        -- like org_id and user_id then replace those references with the  Bind Vars
        -- The replaced message string is stored in a variable altered_message, which
        -- is then used in the subsequent calls.
        -- ntungare Sun Oct 16 20:36:17 PDT 2005
        --
        altered_message := QLTTRAFB.REPLACE_TOKEN(X_STRING    => message,
                                                  X_OLD_TOKEN => QA_SS_CONST.global_param_org_id ,
                                                  X_NEW_TOKEN => QA_SS_CONST.bindvar_param_org_id);

        altered_message := QLTTRAFB.REPLACE_TOKEN(X_STRING    => altered_message,
                                                  X_OLD_TOKEN => QA_SS_CONST.global_param_user_id,
                                                  X_NEW_TOKEN => QA_SS_CONST.bindvar_param_user_id);

        assigned_value := get_assigned_value(plan_char_action_id, altered_message,
            row_elements);

        -- Bug 3397484. Check for the item type keyflex or normalized and then call appropriate
        -- validate functions to get the ids.
        -- saugupta Wed, 28 Jan 2004 08:02:59 -0800 PDT
        IF qa_plan_element_api.keyflex(target_element) THEN
           error_code := validate_keyflex(row_elements, row_record,
                               target_element, assigned_value, back_result_holder);

        return_results_array(target_element).id := back_result_holder.id;
        row_elements(target_element).id := back_result_holder.id;

        --12.1 QWB Usability Improvements
        -- Setting the validation flag to action not fired
        -- so that the actions initiated from value not entered trigger
        -- on one of the collection elements are cascaded
        --
        IF (p_ssqr_operation IS NOT NULL) THEN
           ordered_array(target_element).validation_flag := invalid_element;
        END IF;

        ELSIF  qa_plan_element_api.normalized(target_element) THEN
           error_code := validate_normalized(row_elements, row_record,
                               target_element, assigned_value, back_result_holder);

        return_results_array(target_element).id := back_result_holder.id;
        row_elements(target_element).id := back_result_holder.id;

        --12.1 QWB Usability Improvements
        -- Setting the validation flag to action not fired
        -- so that the actions initiated from value not entered trigger
        -- on one of the collection elements are cascaded
        --
        IF (p_ssqr_operation IS NOT NULL) THEN
           ordered_array(target_element).validation_flag := invalid_element;
        END IF;

        END IF;

        return_results_array(target_element).canonical_value := assigned_value;
        row_elements(target_element).value := assigned_value;

        --12.1 QWB Usability Improvements
        -- Setting the validation flag to action not fired
        -- so that the actions initiated from value not entered trigger
        -- on one of the collection elements are cascaded
        --
        IF (p_ssqr_operation IS NOT NULL) THEN
           ordered_array(target_element).validation_flag := invalid_element;
        END IF;

        --ilawler - bug #3340004 - Mon Feb 16 18:40:12 2004
        --this covers the case of actions that do self-assignment.
        --update the result_holder element also to keep validate_row's logic
        --from overwriting the return_results_array with a blank value.
        IF (element_id = target_element) THEN
           result_holder.canonical_value := assigned_value;
        END IF;

        message_index := message_array.count;
        message_array(message_index).element_id := element_id;
        message_array(message_index).action_type := qa_ss_const.assign_value_action;
        assigned_element  := qa_chars_api.prompt(target_element);

        -- bug 3178307. rkaza. 10/07/2003. Timezone Support.
        If qa_chars_api.datatype(target_element) = qa_ss_const.datetime_datatype then
           assigned_value :=
                fnd_date.date_to_displayDT(fnd_date.canonical_to_date(assigned_value));
        End if;

        -- anagarwa Wed Jan 28 16:39:34 PST 2004
        -- Bug bug 3404863 Commenting the hardcoded message
        -- Modify the action messages to Source: Target = Value
        -- Also we now escape @ chars in value string.

        --ilawler - bug #3340004 - Mon Feb 16 18:53:29 2004
        --According to bso, the message should always be <target> = <value>
/*
        message_array(message_index).message := assigned_value || ' Has Been Assigned To: ' || assigned_element || ' As Per The Assign A Value Action Of ' || trigger_element;
        IF (action_id <> qa_ss_const.assign_value_action) THEN
          startText :=  trigger_element || ': ' ;
        END IF;

        message_array(message_index).message := startText || assigned_element || ' = ' || replace(assigned_value,'@','@@');
*/
        message_array(message_index).message := assigned_element || ' = ' || replace(assigned_value,'@','@@');

    END IF;

    RETURN ok;

END perform_immediate_actions;

-- 12.1 QWB Usability Improvements
-- Added 2 new parameters p_ssqr_operation
-- and ordered_array
--
FUNCTION fire_immediate_actions (plan_id      IN NUMBER,
                                 spec_id      IN NUMBER,
                                 element_id   IN NUMBER,
                                 row_elements         IN OUT NOCOPY ElementsArray,
                                 return_results_array IN OUT NOCOPY ResultRecordArray,
                                 message_array        IN OUT NOCOPY MessageArray,
                                 result_holder        IN OUT NOCOPY ResultRecord,
                                 ordered_array        IN OUT NOCOPY ElementInfoArray,
                                 p_ssqr_operation     IN NUMBER DEFAULT NULL
                                )
    RETURN NUMBER IS

    sequence_limit      NUMBER;
    sequence_number     NUMBER;
    trigger_id          NUMBER;
    action_id           NUMBER;
    plan_char_action_id NUMBER;
    message             VARCHAR2(2000);
    target_element      NUMBER;
    error_code          NUMBER  default ok;
    value               VARCHAR2(2000);
    condition_record    ConditionRecord;
    val_len             number;
    datatype            number;

    --
    -- Bug 5003885
    -- Added the column plan_char_action_trigger_id to the order by
    -- clause so that all the actions under the trigger sequences
    -- on the same level are picked up in order
    -- ntungare Sun Feb 12 06:23:11 PST 2006
    --

    CURSOR rule_cursor (p_id NUMBER, c_id NUMBER) IS
        SELECT plan_char_action_trigger_id, trigger_sequence, operator,
            low_value_other, high_value_other,
            low_value_lookup, high_value_lookup
        FROM qa_plan_char_action_triggers
        WHERE plan_id = p_id
        AND char_id = c_id
        ORDER BY trigger_sequence, plan_char_action_trigger_id;

    CURSOR action_cursor        (rule_id NUMBER) IS
        SELECT plan_char_action_id, action_id, message
        FROM qa_plan_char_actions
        WHERE plan_char_action_trigger_id = rule_id;

    -- Bug 3397484. Added to make a call to changed function perform_immediate_actions
    -- see below the data in RowRecord.
    -- saugupta Wed, 28 Jan 2004 08:04:20 -0800 PDT
    row_record   RowRecord;

BEGIN

    -- Bug 3397484. setting values of row_record for passing to perform_immediate_actions.
    -- saugupta Wed, 28 Jan 2004 08:05:21 -0800 PDT
    row_record.plan_id := plan_id;
    row_record.spec_id := spec_id;
    row_record.org_id  := NULL;
    row_record.user_id  := NULL;


    value := row_elements(element_id).value;

    -- rkaza. bug 3248836. 11/11/2003. tz bug.
    datatype := qa_chars_api.datatype(element_id);

    IF (datatype = qa_ss_const.datetime_datatype) THEN
       val_len := length(value);
       if substr(value, val_len - 1, 2) = '.0' then
          -- Sometimes when coming from Self service, a '.0'
          -- is appended to the value
          -- because of an implicit conversion from date to string.
          -- So chop it off.
          value := substr(value, 1, val_len-2);
       end if;
    end if;

    sequence_limit := 9999;

    OPEN rule_cursor (plan_id, element_id);

    LOOP

        FETCH rule_cursor INTO  trigger_id, sequence_number,
            condition_record.operator,
            condition_record.low_value_other,
            condition_record.high_value_other,
            condition_record.low_value_lookup,
            condition_record.high_value_lookup;

        EXIT WHEN rule_cursor%NOTFOUND;

        IF sequence_number > sequence_limit THEN
            EXIT;

        ELSE

            -- BUG 3303285
            -- ksoh Mon Dec 29 13:33:02 PST 2003
            -- pass in plan_id so that
            -- it calls get_low_high_values and performs uom conversion
            IF evaluate_trigger(condition_record, plan_id, element_id, value, spec_id)
                THEN
                OPEN action_cursor (trigger_id);
                LOOP

                    FETCH action_cursor INTO plan_char_action_id, action_id,
                        message;

                    EXIT WHEN action_cursor%NOTFOUND;

                    error_code := perform_immediate_actions(
                                          action_id,
                                          element_id,
                                          row_record,
                                          message,
                                          plan_char_action_id,
                                          row_elements,
                                          return_results_array,
                                          message_array,
                                          result_holder,
                                          ordered_array,
                                          p_ssqr_operation);

                    IF error_code = reject_an_entry_error THEN
                        RETURN reject_an_entry_error;
                    END IF;

                END LOOP;

                CLOSE action_cursor;
                sequence_limit := sequence_number;
            END IF;

        END IF;

    END LOOP;

    CLOSE rule_cursor;

    RETURN error_code;

    EXCEPTION WHEN OTHERS THEN
        RETURN immediate_action_error;

END fire_immediate_actions;

    -- Bug 4519558.  OA Framework integration project. UT bug fix.
    -- Transaction type element was erroring out for WIP transactions.
    -- "Transaction Type" will be treated as one of a kind.
    -- srhariha.Tue Aug  2 00:43:07 PDT 2005.

FUNCTION validate_transaction_type(value IN VARCHAR2,
                                   p_org_id IN NUMBER,
                                   p_user_id IN NUMBER)
                                         RETURN NUMBER IS


BEGIN

    IF (value IS NULL) THEN
        RETURN ok;
    END IF;

    IF qa_plan_element_api.validate_transaction_type(g_transaction_number,p_org_id,
                                                     p_user_id, value) THEN
       RETURN ok;
    ELSE
       RETURN value_not_in_sql_error;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN value_not_in_sql_error;

END validate_transaction_type;

--
-- Bug 6749653
-- 12.1 QWB Usability Enhancements
-- New function to peform the Reject and Input
-- online validation
-- nutngare
--
FUNCTION validate_reject_an_input(plan_id    IN NUMBER,
                                  element_id IN NUMBER,
                                  value      IN VARCHAR2)
     RETURN NUMBER AS
    CURSOR rule_cursor (p_id NUMBER, c_id NUMBER) IS
        SELECT pcat.plan_char_action_trigger_id, pcat.trigger_sequence, pcat.operator,
               pcat.low_value_other, pcat.high_value_other,
               pcat.low_value_lookup, pcat.high_value_lookup,
               pca.plan_char_action_id, pca.action_id, pca.message
        FROM qa_plan_char_action_triggers pcat, qa_plan_char_actions pca
        WHERE plan_id = p_id
        AND char_id = c_id
        AND pca.plan_char_action_trigger_id = pcat.plan_char_action_trigger_id
        AND pca.action_id = 2
        ORDER BY trigger_sequence, plan_char_action_trigger_id;

    sequence_number     NUMBER;
    trigger_id          NUMBER;
    condition_record    ConditionRecord;
    action_id           NUMBER;
    plan_char_action_id NUMBER;
    message             VARCHAR2(2000);
    sequence_limit      NUMBER;
BEGIN
    sequence_limit := 9999;

    OPEN rule_cursor (plan_id, element_id);

    LOOP
       FETCH rule_cursor INTO  trigger_id, sequence_number,
            condition_record.operator,
            condition_record.low_value_other,
            condition_record.high_value_other,
            condition_record.low_value_lookup,
            condition_record.high_value_lookup,
            plan_char_action_id,
            action_id,
            message;

        EXIT WHEN rule_cursor%NOTFOUND;

        IF sequence_number > sequence_limit THEN
            EXIT;
        ELSE
            IF evaluate_trigger(condition_record, plan_id, element_id, value, 0)
               THEN
                 RETURN reject_an_entry_error;
            END IF;
        END IF;
    END LOOP;

    RETURN ok;
END validate_reject_an_input;

--
-- 12.1 QWB Usablity Improvements Project
-- Modified the API to add a new parameter
-- org_id. This is needed to online validations
-- through PPR
-- ntungare
--
FUNCTION validate_element (
    row_elements        IN OUT NOCOPY ElementsArray,
    row_record          IN RowRecord,
    element_id          IN NUMBER,
    org_id              IN NUMBER,
    result_holder       IN OUT NOCOPY ResultRecord)
    RETURN ErrorArray IS

    error_list          ErrorArray;
    error_code          NUMBER;

    -- Bug 2427337 variable size increased for long comment datatype
    -- rponnusa Tue Jun 25 06:15:48 PDT 2002
    element_value               VARCHAR2(2100);

BEGIN
    -- 12.1 QWB Usablitity Improvements
    g_org_id := org_id;
    element_value := row_elements(element_id).value;

    result_holder.actual_datatype :=
        qa_plan_element_api.get_actual_datatype (element_id);

    error_list(1).error_code := validate_enabled (row_record.plan_id,
        element_id);


    -- We should not perform any mandatory check if the row is
    -- coming from background transaction.  For Background
    -- transaction null is allowed even for mandatory elements.

    error_list(2).error_code := ok;

    --
    -- Bug 2617638.
    -- Added the id_derived conjunct.  No need to call validate
    -- mandatory if ID is passed.  It is always NOT NULL in this
    -- case, and will not fail validate_mandatory.
    -- bso Tue Oct  8 18:44:45 PDT 2002
    --
    IF NOT flag_is_set(row_elements(element_id).validation_flag,
        background_element)
        AND NOT flag_is_set(row_elements(element_id).validation_flag,
        valid_element)
        AND NOT flag_is_set(row_elements(element_id).validation_flag,
        id_derived)
        THEN

        error_list(2).error_code := validate_mandatory (row_record, element_id,
            element_value);
    END IF;

    error_list(3).error_code := validate_datatype(row_record.plan_id,
        element_id, element_value, row_elements, result_holder);

    IF qa_plan_element_api.keyflex(element_id) THEN
        error_list(4).error_code := validate_keyflex(row_elements, row_record,
            element_id, element_value, result_holder);

    ELSIF qa_plan_element_api.normalized(element_id) THEN
        error_list(4).error_code := validate_normalized(row_elements,
            row_record, element_id, element_value, result_holder);

    ELSIF qa_plan_element_api.primitive(element_id) THEN
        error_list(4).error_code := validate_primitive(row_record.plan_id,
            row_elements, row_record, element_id, element_value);

    -- Bug 4519558.  OA Framework integration project. UT bug fix.
    -- Transaction type element was erroring out for WIP transactions.
    -- "Transaction Type" will be treated as one of a kind.
    -- srhariha.Tue Aug  2 00:43:07 PDT 2005.

    ELSIF element_id = qa_ss_const.transaction_type THEN
        error_list(4).error_code := validate_transaction_type(element_value,
             g_org_id,row_record.user_id);

    ELSIF qa_plan_element_api.values_exist(row_record.plan_id, element_id) THEN
        error_list(4).error_code := validate_values(row_record.plan_id,
            element_id, element_value);

    -- Bug 7716875.pdube Mon Apr 13 03:25:19 PDT 2009
    -- Added condition based on validation_flag which will
    -- be true for elements with sql validation for forms and qwb
    -- ELSIF qa_plan_element_api.sql_validation_exists(element_id) THEN
    ELSIF qa_plan_element_api.sql_validation_exists(element_id)
	AND NOT row_elements(element_id).validation_flag = 'valid' THEN

        error_list(4).error_code := validate_sql(element_id, element_value,
            row_record.org_id, row_record.user_id);

    ELSE        -- For
        error_list(4).error_code := ok;
    END if;

    error_list(5).error_code := validate_spec_limits(row_record, element_id,
        result_holder.canonical_value);

    --
    -- Bug 6749653
    -- 12.1 QWB Usability Improvements
    -- Checking for Reject an input actions
    -- ntungare
    --
    error_list(6).error_code := validate_reject_an_input(row_record.plan_id, element_id,
        result_holder.canonical_value);

    RETURN error_list;

END validate_element;

--
-- 12.1 QWB Usability Improvements
-- Added a new parameter p_ssqr_operation that would determine
-- if the online actions should be fired or not. This is neede
-- since in QWB the online actions would be fired though PPR
-- and so need not be fired again at the time of validation
--
FUNCTION validate_row (
    plan_id                    IN      NUMBER,
    spec_id                    IN      NUMBER,
    org_id                     IN      NUMBER,
    user_id                    IN      NUMBER,
    transaction_number         IN      NUMBER,
    transaction_id             IN      NUMBER,
    return_results_array       OUT     NOCOPY ResultRecordArray,
    message_array              OUT     NOCOPY MessageArray,
    row_elements               IN OUT  NOCOPY ElementsArray,
    p_ssqr_operation           IN      NUMBER DEFAULT NULL)
    RETURN ErrorArray IS

    row_record                  RowRecord;
    result_holder               ResultRecord;
    error_list                  ErrorArray;
    row_error_list              ErrorArray;
    ordered_array               ElementInfoArray;

BEGIN

    row_record.plan_id := plan_id;
    row_record.spec_id := spec_id;
    row_record.org_id  := org_id;
    row_record.user_id  := user_id;

    g_org_id := org_id;
    g_transaction_number := transaction_number;
    g_transaction_id := transaction_id;

    --
    -- Bug 4635316.
    -- Store the value of user_id in the global variable g_user_id so
    -- that it can be used in Function fire_immediate_actions.
    -- ntungare Wed Sep 28 06:03:11 PDT 2005.
    --
    g_user_id := user_id;

    -- Bug 4558205. Lot/Serial Validation.
    -- Call init procedure for global variables.
    -- srhariha. Tue Sep 27 05:07:58 PDT 2005.

    init_globals;

    -- End Bug 4558205.

    -- Bug 3397484 ksoh Tue Jan 27 13:54:38 PST 2004
    -- pass plan_id for ordering ordered_array by prompt_sequence
    ordered_array := populate_elements (row_elements, plan_id);
    determine_navigation_order (ordered_array);

    FOR i IN 0..row_elements.count-1 LOOP

        IF NOT nvl(ordered_array(i).treated, FALSE) THEN

            -- We must not validate an element if it is already valid,
            -- for example context elements for transactions.
            --
            -- However, if this element is a keyflex or normalized
            -- then we have to go through validation to determine
            -- the corresponding id to put in qa_results.

            -- Bug 3381173. Validation should be performed even if the
            -- element is a primitive one. Hence adding an OR condn below.
            -- This is also necessary because of the dependent elements.
            -- Eg.. the subinventory (primitive) validation should be
            -- performed before the locator (keyflex) validation.
            -- kabalakr Tue Jan 27 02:18:59 PST 2004.

            -- Bug 4343758. OA Framework Integration project.
            -- If the primitive values are validated then it
            -- must be copied to package globals, which will
            -- be used to validate other dependent elements.
            -- Also removed primitive call from below OR list.
            -- srhariha. Thu May 26 02:38:04 PDT 2005.

           IF flag_is_set(ordered_array(i).validation_flag,valid_element) AND
                           qa_plan_element_api.primitive(ordered_array(i).id) THEN

                     copy_primitive_to_global(p_element_id => ordered_array(i).id,
                                              p_value => row_elements(ordered_array(i).id).value);
           END IF;


            IF  NOT flag_is_set(ordered_array(i).validation_flag,
                    valid_element)
                OR qa_plan_element_api.keyflex(ordered_array(i).id)
                OR qa_plan_element_api.normalized(ordered_array(i).id) THEN
               -- OR qa_plan_element_api.primitive(ordered_array(i).id) THEN

                -- 12.1 QWB Usabiltiy Improvements
                -- Passing the Org Id parameter
                error_list := validate_element( row_elements, row_record,
                    ordered_array(i).id, org_id, result_holder);
                ordered_array(i).treated := TRUE;

                --
                -- Bug 5331420.  Some primitive elements are not firing
                -- actions because they do not match the complex IF
                -- condition.  Hence, moved the following block to
                -- out of the IF THEN ELSE.  Actions should be fired
                -- for all elements as long as it doesn't have the
                -- action_fired flag set which will be checked here.
                -- bso Thu Jun 15 16:19:59 PDT 2006
                --
                -- IF no_errors(error_list) THEN
                --
                --   -- if the calling application took care of immediate
                --   -- actions then we must not do any processing
                --   -- related to firing immediate actions
                --
                --   --ilawler - bug #3340004 - Mon Feb 16 18:38:25 2004
                --   --add result_holder as a param to allow self-assignment
                --   IF NOT (flag_is_set(ordered_array(i).validation_flag,
                --      action_fired)) THEN
                --      error_list(6).error_code := fire_immediate_actions (
                --          plan_id, spec_id, ordered_array(i).id,
                --          row_elements, return_results_array, message_array,
                --          result_holder);
                --   END IF;
                --
                -- END IF;

            ELSE

                -- If validation is not performed on elements there are couple of
                -- things we must compute.
                -- validate_datatype is called because we want to compute
                -- the canonical values for each element.
                -- Another thing is to cmopute the actual datatype

                error_list(1).error_code := validate_datatype(row_record.plan_id,
                   ordered_array(i).id , row_elements(ordered_array(i).id).value,
                   row_elements, result_holder);

                result_holder.actual_datatype := qa_plan_element_api.get_actual_datatype(
                   ordered_array(i).id);

            END IF;

            --
            -- Bug 5331420.  See above.  Moved code here.
            --
            IF no_errors(error_list) THEN

		-- if the calling application took care of immediate
                -- actions then we must not do any processing
                -- related to firing immediate actions

                --ilawler - bug #3340004 - Mon Feb 16 18:38:25 2004
                --add result_holder as a param to allow self-assignment
                -- 12.1 QWB Usabiltity Improvements
                -- Online actions are to fired only in case the
                -- Validate_row method has not been called from the QWB
                -- Application.
                --
                IF (NOT (flag_is_set(ordered_array(i).validation_flag,
                                     action_fired)) AND
                    p_ssqr_operation IS NULL) THEN
                    error_list(6).error_code := fire_immediate_actions (
                        plan_id, spec_id, ordered_array(i).id,
                        row_elements, return_results_array, message_array,
                        result_holder, ordered_array);
                END IF;
            END IF;

        END IF;

        append_errors( ordered_array(i).id, error_list, row_error_list);
        return_results_array(ordered_array(i).id).element_id :=
            ordered_array(i).id;
        return_results_array(ordered_array(i).id).id := result_holder.id;
        return_results_array(ordered_array(i).id).actual_datatype :=
            result_holder.actual_datatype;
        return_results_array(ordered_array(i).id).canonical_value :=
            result_holder.canonical_value;
        result_holder.id := NULL;
        error_list.delete;

    END LOOP;

    RETURN row_error_list;

    EXCEPTION WHEN OTHERS THEN
        -- dbms_output.put_line('An Error Occurred, Unable To Continue');
        -- dbms_output.put_line(to_char(sqlcode)||': '||sqlerrm);
        RAISE;

END validate_row;


PROCEDURE init_message_map IS
--
-- A mapping between our internal error message and its AOL message name.
--
BEGIN
  g_message_map(not_enabled_error) :=             'QA_API_NOT_ENABLED';
  g_message_map(no_values_error) :=               'QA_API_NO_VALUES';
  g_message_map(mandatory_error) :=               'QA_API_MANDATORY';
  g_message_map(not_revision_controlled_error) := 'QA_API_REVISION_CONTROLLED';
  g_message_map(mandatory_revision_error) :=      'QA_API_MANDATORY_REVISION';
  g_message_map(no_values_error) :=               'QA_API_NO_VALUES';
  g_message_map(keyflex_error) :=                 'QA_API_KEYFLEX';
  g_message_map(id_not_found_error) :=            'QA_API_ID_NOT_FOUND';
  g_message_map(spec_limit_error) :=              'QA_API_SPEC_LIMIT';
  g_message_map(immediate_action_error) :=        'QA_API_IMMEDIATE_ACTION';
  g_message_map(lower_limit_error) :=             'QA_API_LOWER_LIMIT';
  g_message_map(upper_limit_error) :=             'QA_API_UPPER_LIMIT';
  g_message_map(value_not_in_sql_error) :=        'QA_API_VALUE_NOT_IN_SQL';
  g_message_map(sql_validation_error) :=          'QA_API_SQL_VALIDATION';
  g_message_map(date_conversion_error) :=         'QA_API_INVALID_DATE';
  g_message_map(data_type_error) :=               'QA_API_DATA_TYPE';
  g_message_map(number_conversion_error) :=       'QA_API_INVALID_NUMBER';
  g_message_map(no_data_found_error) :=           'QA_API_NO_DATA_FOUND';
  g_message_map(not_locator_controlled_error) :=  'QA_API_NOT_LOCATOR_CONTROLLED';
  g_message_map(item_keyflex_error) :=            'QA_API_ITEM_KEYFLEX';
  g_message_map(comp_item_keyflex_error) :=       'QA_API_COMP_ITEM_KEYFLEX';
  g_message_map(locator_keyflex_error) :=         'QA_API_LOCATOR_KEYFLEX';
  g_message_map(comp_locator_keyflex_error) :=    'QA_API_COMP_LOCATOR_KEYFLEX';
  g_message_map(invalid_number_error) :=          'QA_API_INVALID_NUMBER';
  g_message_map(invalid_date_error) :=            'QA_API_INVALID_DATE';
  g_message_map(spec_error) :=                    'QA_API_SPEC';
  g_message_map(ok) :=                            'QA_API_NO_ERROR';
  g_message_map(unknown_error) :=                 'QA_API_UNKNOWN';
  g_message_map(reject_an_entry_error) :=         'QA_API_REJECT_AN_ENTRY';

  -- Added the following messages for Bill_Reference,Routing_Reference,To_locator
  -- Key FlexFields. Bug 2686970.suramasw Wed Nov 27 05:12:52 PST 2002.

  g_message_map(bill_reference_keyflex_error) :=  'QA_API_BILL_REFERENCE_KEYFLEX';
  g_message_map(rtg_reference_keyflex_error)  :=  'QA_API_RTG_REFERENCE_KEYFLEX';
  g_message_map(to_locator_keyflex_error)     :=  'QA_API_TO_LOCATOR_KEYFLEX';

  -- Bug 3679762.Initialising the message array for the "missing assign a value target
  -- column" error message.
  -- srhariha.Wed Jun 16 06:54:06 PDT 2004

  g_message_map(missing_assign_column)     :=  'QA_MISSING_ASSIGN_COLUMN';

END init_message_map;


FUNCTION get_error_message(error_code IN NUMBER) RETURN VARCHAR2 IS
--
-- Return an error message in the user's language given an error code.
--
BEGIN
    RETURN fnd_message.get_string('QA', g_message_map(error_code));
END get_error_message;

FUNCTION validate_comment (value IN VARCHAR2, result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER IS
--
-- This function is for long comment datatype. Long comment can hold
-- max of 2000 characters. Introduced for bug 2427337
-- rponnusa Tue Jun 25 06:15:48 PDT 2002

BEGIN
   result_holder.canonical_value := substr(value, 1, 2000);

   RETURN ok;
END validate_comment;


    --
    -- R12 Project MOAC 4637896
    --
    -- Moved several procedures from qltssreb to this package
    -- to centralize all validation routines.  These are
    --
    -- parse_id
    -- parse_value
    -- result_to_array
    -- id_to_array
    -- set_validation_flag
    -- set_validation_flag_txn
    --
    -- bso Sat Oct  1 16:15:58 PDT 2005
    --


    FUNCTION parse_id(p_result IN VARCHAR2, n IN INTEGER,
        p IN INTEGER, q IN INTEGER) RETURN NUMBER IS
    BEGIN
        RETURN to_number(substr(p_result, p, q-p));
    END parse_id;


    FUNCTION parse_value(p_result IN VARCHAR2, n IN INTEGER,
        p IN OUT NOCOPY INTEGER) RETURN VARCHAR2 IS

       -- anagarwal Fri Nov 14 14:11:12 PST 2003
       -- bug 3256981
       -- the problem was happening due to value being initialized to have
       -- character1 length. For comment1 to comment5, it can be as long as
       -- 2000 chars. So we need to have long enough field.
        l_value qa_results.comment1%TYPE;
        c VARCHAR2(10);
        separator CONSTANT VARCHAR2(1) := '@';

    BEGIN
    --
    -- Loop until a single @ is found or p_result is exhausted.
    --
        p := p + 1;                   -- add 1 before substr to skip '='
        WHILE p <= n LOOP
            c := substr(p_result, p, 1);
            p := p + 1;
            IF (c = separator) THEN
                IF substr(p_result, p, 1) <> separator THEN
                --
                -- take a peak at the next character, if not another @,
                -- we have reached the end.  Otherwise, skip this @
                --
                    RETURN l_value;
                ELSE
                    p := p + 1;
                END IF;
            END IF;
            l_value := l_value || c;
        END LOOP;

        RETURN l_value;
    END parse_value;


    FUNCTION result_to_array(p_result IN VARCHAR2)
    RETURN qa_validation_api.ElementsArray IS

        elements qa_validation_api.ElementsArray;
        n INTEGER;
        p INTEGER;            -- starting string position
        q INTEGER;            -- ending string position
        x_char_id NUMBER;
       --anagarwal Fri Nov 14 14:11:12 PST 2003
       -- bug 3256981
       -- the problem was happening due t value being initialized to have
       -- character1 length. For comment1 to comment5, it can be as long as
       -- 2000 chars. So we need to have long enough field.
        x_value qa_results.comment1%TYPE;

    BEGIN
        n := length(p_result);
        p := 1;
        WHILE p < n LOOP
            q := instr(p_result, '=', p);
            --
            -- found the first = sign.  To the left, must be char_id
            --
            x_char_id := parse_id(p_result, n, p, q);
            -- Bug 7716875.pdube Mon Apr 13 03:25:19 PDT 2009
            -- Added this statement to set the validation flag back to
            -- valid if the element has a validation string.
            -- this api is called from forms and qwb where the
            -- value of the element will be validated at UI.
            IF qa_validation_api.set_validation_flag_sql_valid(x_char_id) THEN
              elements(x_char_id).validation_flag := 'valid';
            END IF;
	    --
            -- To the right, must be the value
            --
            x_value := parse_value(p_result, n, q);
            elements(x_char_id).value := x_value;
            p := q;
        END LOOP;

        RETURN elements;
    END result_to_array;


    -- I am over riding this function for the ability to pass ids.
    -- This will resolve the validation issue for work order like elements
    -- names are not unique only ids are.
    --
    -- ORASHID 15-August-2001
    --
    -- R12 Project MOAC 4637896
    -- Renaming this function from result_to_array to
    -- id_to_array to fix a confusion.  Uptake the
    -- parameter and local variable naming to Apps
    -- standard convention.
    -- bso Tue Sep 27 17:51:10 PDT 2005
    --
    FUNCTION id_to_array(
        p_result IN VARCHAR2,
        x_elements IN OUT NOCOPY qa_validation_api.ElementsArray)
        RETURN qa_validation_api.ElementsArray IS

        n INTEGER;
        p INTEGER;            -- starting string position
        q INTEGER;            -- ending string position
        l_char_id NUMBER;
        l_value qa_results.character1%TYPE;

    BEGIN

        IF p_result IS NULL THEN
            RETURN x_elements;
        END IF;

        n := length(p_result);
        p := 1;
        WHILE p < n LOOP
            q := instr(p_result, '=', p);
            --
            -- found the first = sign.  To the left, must be char_id
            --
            l_char_id := parse_id(p_result, n, p, q);
            --
            -- To the right, must be the value
            --
            l_value := parse_value(p_result, n, q);
            x_elements(l_char_id).id := l_value;
            -- Bug 7716875.pdube Mon Apr 13 03:25:19 PDT 2009
            -- Added this statement to set the validation flag back to
            -- valid if the element has a validation string.
            -- this api is called from forms and qwb where the
            -- value of the element will be validated at UI.
            IF qa_validation_api.set_validation_flag_sql_valid(l_char_id) THEN
              x_elements(l_char_id).validation_flag := 'valid';
            END IF;

            x_elements(l_char_id).validation_flag :=
                nvl(x_elements(l_char_id).validation_flag, 'invalid') ||
                qa_validation_api.id_derived;
            p := q;
        END LOOP;

        RETURN x_elements;
    END id_to_array;


    PROCEDURE set_validation_flag(
        x_elements IN OUT NOCOPY qa_validation_api.ElementsArray) IS
        i INTEGER;
    BEGIN
        i := x_elements.FIRST;
        WHILE i <= x_elements.LAST LOOP
            x_elements(i).validation_flag :=
                x_elements(i).validation_flag ||
                    qa_validation_api.action_fired;

            IF i = qa_ss_const.transaction_type THEN
                x_elements(i).validation_flag :=
                    x_elements(i).validation_flag ||
                    qa_validation_api.valid_element;
            END IF;

            i := x_elements.NEXT(i);
        END LOOP;
    END set_validation_flag;


    --
    -- The previous version of the following routine was
    -- incorrectly implemented.  It is hereby redone.
    -- See version 120.4 of qltssreb.plb or before for the
    -- old version.  Also renamed from set_validation_flag
    -- to set_validation_flag_txn.
    --
    -- This procedure is needed to set context elements to
    -- have background_element flag so that it will pass
    -- mandatory-ness validation even though the value is
    -- null.  Background values will be posted later in a
    -- separate step, hence mandatory check is not needed.
    --
    -- Caller chould supply p_plan_id + p_transaction_number
    -- or simply p_plan_transaction_id which will be more
    -- accurate.
    --
    -- bso Sat Oct  1 15:05:35 PDT 2005
    --

    PROCEDURE set_validation_flag_txn(
        x_elements IN OUT NOCOPY qa_validation_api.ElementsArray,
        p_plan_id NUMBER,
        p_transaction_number NUMBER,
        p_plan_transaction_id NUMBER) IS

        CURSOR context IS
            SELECT collection_trigger_id
            FROM   qa_txn_collection_triggers
            WHERE  transaction_number = p_transaction_number AND
                   enabled_flag = 1;

        CURSOR bg1 IS
            SELECT 1
            FROM   qa_plan_transactions
            WHERE  plan_id = p_plan_id AND
                   transaction_number = p_transaction_number AND
                   enabled_flag = 1 AND
                   background_collection_flag = 1;

        CURSOR bg2 IS
            SELECT 1
            FROM   qa_plan_transactions
            WHERE  plan_transaction_id = p_plan_transaction_id AND
                   enabled_flag = 1 AND
                   background_collection_flag = 1;

        i BINARY_INTEGER;
        l_background NUMBER;

    BEGIN
        --
        -- Step 1.  Set all context elements to be valid.
        --
        FOR c IN context LOOP
            IF x_elements.EXISTS(c.collection_trigger_id) THEN
                x_elements(c.collection_trigger_id).validation_flag :=
                    x_elements(c.collection_trigger_id).validation_flag ||
                    qa_validation_api.valid_element;
            END IF;
        END LOOP;

        --
        -- Step 2.  Set additional valid elements.
        --
        IF x_elements.EXISTS(qa_ss_const.lot_number) THEN
            x_elements(qa_ss_const.lot_number).validation_flag :=
                x_elements(qa_ss_const.lot_number).validation_flag ||
                qa_validation_api.valid_element;
        END IF;

        IF x_elements.EXISTS(qa_ss_const.serial_number) THEN
            x_elements(qa_ss_const.serial_number).validation_flag :=
                x_elements(qa_ss_const.serial_number).validation_flag ||
                qa_validation_api.valid_element;
        END IF;

        IF x_elements.EXISTS(qa_ss_const.transaction_type) THEN
            x_elements(qa_ss_const.transaction_type).validation_flag :=
                x_elements(qa_ss_const.transaction_type).validation_flag ||
                qa_validation_api.valid_element;
        END IF;

        --
        -- Step 3.  If it is a background plan, set all elements
        -- to have the background_element flag.  Currently this
        -- is only an approximation because we should have used
        -- plan_transaction_id to identify the particular txn.
        -- But this was not available in the current architecture,
        -- so using a conservative approach to look for all
        -- plan_id + transaction_number combination and if any
        -- is background, then assume it is a background plan.
        -- The correct fix is that the caller must supply the
        -- p_plan_transaction_id param, then this function will
        -- work correctly.
        --

        IF p_plan_transaction_id IS NULL THEN
            OPEN bg1;
            FETCH bg1 INTO l_background;
            CLOSE bg1;
        ELSE
            OPEN bg2;
            FETCH bg2 INTO l_background;
            CLOSE bg2;
        END IF;

        IF l_background IS NOT NULL THEN
            i := x_elements.FIRST;
            WHILE i <= x_elements.LAST LOOP
                x_elements(i).validation_flag :=
                    x_elements(i).validation_flag ||
                    qa_validation_api.background_element;
                i := x_elements.NEXT(i);
            END LOOP;
        END IF;

    END set_validation_flag_txn;

    -- End R12 Project MOAC 4637896

    -- Bug 7716875.pdube Mon Apr 13 03:25:19 PDT 2009
    -- This function will return true if there is already a sql validation
    -- attached to the element.We consider that the UI will validate the
    -- elements correctly and they need not to be validated again, hence
    -- using this value, shall set the validation_flag to valid
    FUNCTION set_validation_flag_sql_valid(
        p_char_id IN NUMBER) RETURN BOOLEAN IS

        CURSOR sql_valid(x_char_id NUMBER) IS
             SELECT 1
             FROM   qa_chars
             WHERE  char_id = x_char_id AND
                    sql_validation_string is not null;
         p_sql_validation_flag BOOLEAN;
         temp NUMBER := 0; -- Flag number 1 for true and 0 for false

    BEGIN
         IF p_char_id is not null then
              OPEN sql_valid(p_char_id);
              FETCH sql_valid INTO temp;
              CLOSE sql_valid;
          END IF;

          IF temp = 1 THEN
              RETURN TRUE;
          ELSE
              RETURN FALSE;
          END IF;
     END set_validation_flag_sql_valid;

-- 12.1 QWB Usability Improvements
-- Procedure to De-reference the values for the HC elements
-- that depended on Non Quality tables for their values
PROCEDURE build_deref_string(p_plan_id        IN NUMBER,
                             p_collection_id  IN NUMBER,
                             p_occurrence     IN NUMBER,
                             p_charid_string  OUT NOCOPY VARCHAR2,
                             p_values_string  OUT NOCOPY VARCHAR2)
    AS

    Type hardcoded_char_tab_typ IS TABLE OF NUMBER INDEX BY binary_integer;
    hardcoded_char_tab hardcoded_char_tab_typ;

    cols_str VARCHAR2(32767);
    char_ids_str VARCHAR2(32767);

    plan_name VARCHAR2(100);

    result_str VARCHAR2(32767);

    char_name  VARCHAR(100);

BEGIN
    --Get the list of HardCoded elements in the
    --Collection plan
    SELECT qpc.char_id bulk collect
      INTO hardcoded_char_tab
    FROM qa_plan_chars qpc,
         qa_chars qc
    WHERE qpc.plan_id = p_plan_id
      AND qpc.char_id = qc.char_id
      AND qc.hardcoded_column IS NOT NULL
      AND fk_table_name IS NOT NULL;

    --loop through the list of HardCoded elements
    FOR cntr IN 1 .. hardcoded_char_tab.COUNT
      LOOP
        -- Select the column name for the Hardcoded
        -- element based on the element id
        Select upper(translate(name,' ''*{}','_____')) into char_name
          from qa_chars
        where char_id =   hardcoded_char_tab(cntr);

        --
        -- bug 7559568
        -- Added replace function  to double encode the delimiter ,
        -- if the data contains the delimiter.
        -- ntungare
        --
        cols_str := cols_str || 'REPLACE(NVL(to_char('||char_name||'), ''NULL''),'','','',,'') ||'',''||';
        char_ids_str := char_ids_str ||
                        qa_ak_mapping_api.get_vo_attribute_name(hardcoded_char_tab(cntr), p_plan_id)||
                        ',';
      END LOOP;

      if hardcoded_char_tab.count <> 0 then
        -- Get the plan name to form the Dynamic Plan View Name
        SELECT deref_view_name
          INTO plan_name
        FROM qa_plans
         WHERE plan_id = p_plan_id;

        cols_str := RTRIM(cols_str, '||'',''||');
        char_ids_str := RTRIM(char_ids_str,   ',');

         begin
         EXECUTE IMMEDIATE 'Select ''' || char_ids_str || ''',' || cols_str || ' from ' || plan_name ||
                             ' where collection_id = :collection_id and
                                   occurrence = :occurrence'
             INTO p_charid_string,
                  p_values_string
            USING p_collection_id,
                  p_occurrence;
         EXCEPTION when others
            then null;
         end;
      end if;

END build_deref_string;

-- 12.1 QWB Usability Improvements
-- API to replace the Tokens in the error messages
-- with the element prompts
-- ntungare
FUNCTION replace_message_tokens(p_error_message IN VARCHAR2)
      RETURN VARCHAR2 AS

    token_count      NUMBER;
    element_prompt   VARCHAR2(200);
    replaced_message VARCHAR2(2000);
    token_postn      NUMBER;
BEGIN
    SELECT LENGTH(p_error_message) - LENGTH(REPLACE(p_error_message,'&',''))
       INTO token_count FROM DUAL;

    IF token_count <> 0 THEN
       SELECT INSTR(p_error_message,':',1) INTO token_postn FROM DUAL;

       SELECT SUBSTR(p_error_message,1,token_postn-1),
              SUBSTR(p_error_message,token_postn+1)
         INTO element_prompt, replaced_message
       FROM DUAL;

       SELECT REPLACE(replaced_message,'&'||'CHAR_PROMPT', element_prompt)
         INTO replaced_message FROM DUAL;
    ELSE
       RETURN p_error_message;
    END IF;

  RETURN replaced_message;
END replace_message_tokens;

-- 12.1 QWB Usability Improvements
-- Method to do the online validations
-- This method would also make a call to the API
-- process_dependent_elements to do the dependent
-- elelemts processing
--
PROCEDURE perform_ssqr_validation (p_plan_id     IN VARCHAR2,
                                   p_org_id      IN VARCHAR2,
                                   p_spec_id     IN VARCHAR2,
                                   p_user_id     IN VARCHAR2 DEFAULT NULL,
                                   p_element_id  IN VARCHAR2,
                                   p_input_value IN VARCHAR2,
                                   result_string IN VARCHAR2,
                                   id_string     IN VARCHAR2,
                                   normalized_attr               OUT NOCOPY VARCHAR2,
                                   normalized_id_val             OUT NOCOPY VARCHAR2,
                                   message                       OUT NOCOPY VARCHAR2,
                                   dependent_elements            OUT NOCOPY VARCHAR2,
                                   disable_enable_flag_list      OUT NOCOPY VARCHAR2,
                                   disabled_dep_elem_vo_attr_lst OUT NOCOPY VARCHAR2)
      AS
    row_record     QA_VALIDATION_API.RowRecord;
    result_record  QA_VALIDATION_API.ResultRecord;
    row_elements   QA_VALIDATION_API.ElementsArray;
    error_array    QA_VALIDATION_API.ErrorArray;
    errors_list    QA_VALIDATION_API.ErrorArray;
    cntr           NUMBER;
    i              NUMBER :=1 ;
    message_str    VARCHAR2(4000);

    l_id_string     VARCHAR2(4000);
    -- Bug 9382356
    -- Modified the length to 32767 so that it can hold more than 1 Comments type elements.
    -- Also, added new variable l_input_value to truncate a string to 2000 characters as the
    -- limit in row_elements.value is 2000 characters.
    -- skolluku
    l_result_string VARCHAR2(32767);
    l_input_value   VARCHAR2(2000);

    dep_elements_list   VARCHAR2(4000);
    dep_flag_list       VARCHAR2(4000);
    dep_elements_status VARCHAR2(4000);

    elements       qa_validation_api.ElementsArray;

    dependent_elements_arr  QA_PARENT_CHILD_PKG.ChildPlanArray;
    dep_elements_status_arr QA_PARENT_CHILD_PKG.ChildPlanArray;

    disabled_dep_elem_vo_attr     VARCHAR2(4000);
    disabled_dep_elem_id_attr     VARCHAR2(4000);
BEGIN
    -- populate the record structures
    /*
    if result_string is not NULL THEN
       elements := qa_validation_api.result_to_array(result_string);
       elements := qa_validation_api.id_to_array(id_string, elements);
    end if;
    */

    row_elements(p_element_id).id := p_element_id;
    /*
    If (elements.COUNT <> 0 AND elements(p_element_id).value IS NOT NULL) THEN
      row_elements(p_element_id).value := elements(p_element_id).value;
    ELSE
      row_elements(p_element_id).value := p_input_value;
    END If;
    */
    -- Bug 9382356. Truncate the value to 2000 and use it instead of p_input_value.
    l_input_value := substr(p_input_value,1,2000);
    row_elements(p_element_id).value := l_input_value;

    -- Bug 9382356. Use l_input_value instead of p_input_value.
    l_result_string := result_string || '@' || p_element_id || '=' || l_input_value;

    IF (qa_chars_api.datatype(p_element_id) IN (6,3) AND
        p_input_value is NOT NULL) THEN
        BEGIN
            row_elements(p_element_id).value := QLTDATE.any_to_canon(UPPER(p_input_value));
        EXCEPTION WHEN OTHERS THEN
            errors_list(1).error_code := invalid_date_error;
            errors_list(1).element_id := p_element_id;

            QA_SS_RESULTS.get_error_messages(errors_list, p_plan_id,message_str);
            message := replace_message_tokens(message_str);
            RETURN;
        END;
    END IF;

    row_record.plan_id := p_plan_id;
    row_record.org_id  := p_org_id;
    row_record.spec_id := p_spec_id;
    row_record.user_id := p_user_id;

    result_record.element_id := p_element_id;

    -- call the validate_element api to perform
    -- the element validation
    error_array := QA_VALIDATION_API.validate_element(
                        row_elements  => row_elements,
                        row_record    => row_record,
                        element_id    => p_element_id,
                        org_id        => p_org_id,
                        result_holder => result_record);

    cntr := error_array.first;

    -- build the error list array
    while cntr <= error_array.last
      loop
         if error_array(cntr).error_code <> QA_VALIDATION_API.OK THEN
           errors_list(i).element_id := p_element_id;
           errors_list(i).error_code := error_array(cntr).error_code;
           i := i+1;
         END If;
         cntr := error_array.next(cntr);
      end loop;

   -- build the error message string
   -- bug 6980226
   -- If the element is a HC element then we need to clear
   -- the Id value and also disable the dependent elements
   -- This is done in the ELSE part
   -- ntungare
   --
   If (QA_VALIDATION_API.no_errors(error_array) = FALSE AND
       ((qa_plan_element_api.keyflex(p_element_id) OR
         qa_plan_element_api.normalized(p_element_id)) = FALSE)) THEN

      QA_SS_RESULTS.get_error_messages(errors_list, p_plan_id, message_str);
      message := replace_message_tokens(message_str);

   ELSE
      -- bug 6980226
      -- In case the element is a HC element then the error message
      -- needs to be captured if there is any. The dependent elements
      -- processing needs to be done in case of an invalid value as well
      -- ntungare
      --
      IF QA_VALIDATION_API.no_errors(error_array) = FALSE THEN
         QA_SS_RESULTS.get_error_messages(errors_list, p_plan_id, message_str);
         message := replace_message_tokens(message_str);
      END IF;

      -- Set the normalized value for HC element
      IF ((qa_plan_element_api.keyflex(p_element_id) OR
          qa_plan_element_api.normalized(p_element_id)) = TRUE) THEN
         normalized_id_val := result_record.id;
         -- Set the normalized element VO attribute
         normalized_attr   := qa_chars_api.hardcoded_column(p_element_id);

         IF normalized_id_val is NOT NULL THEN
            l_id_string := id_string || '@'|| p_element_id || '=' || normalized_id_val;
         ELSE
            normalized_id_val := 'NULL';
         END IF;

         l_id_string := LTRIM(l_id_string, '@');
      END IF;

      -- Process dependent elements
      QA_PLAN_ELEMENT_API.process_dependent_elements(
                                 l_result_string,
                                 l_id_string,
                                 p_org_id,
                                 p_plan_id,
                                 p_element_id,
                                 dep_elements_list,
                                 dep_flag_list);

       dependent_elements:= dep_elements_list;
       disable_enable_flag_list :=  dep_flag_list;

       -- If any dependent element has been disabled then its
       -- value needs to be cleared.
       --
       IF (dependent_elements IS NOT NULL AND
           INSTR(disable_enable_flag_list,'D',1,1) <> 0) THEN
           -- If the above condition evaluates to true then it means
           -- that there are dependent elements that are disabled

           -- Representing the enabled and disabled flags as 1 and 2
           -- respectively. This is needed since the parse_list API
           -- that converts the comma separated strings into arrays
           -- works only with number elements
           SELECT TRANSLATE(disable_enable_flag_list,'ED','12')
             INTO dep_elements_status
           FROM DUAL;

           QA_PARENT_CHILD_PKG.parse_list(dependent_elements , dependent_elements_arr);
           QA_PARENT_CHILD_PKG.parse_list(dep_elements_status, dep_elements_status_arr);

           -- Loop though the dependent elements
           FOR dep_elem_ctr in 1..dependent_elements_arr.COUNT
              LOOP
                 -- Check if any of them is disabled
                 IF (dep_elements_status_arr(dep_elem_ctr) = 2) THEN

                    disabled_dep_elem_vo_attr :=
                    qa_ak_mapping_api.get_vo_attribute_name(dependent_elements_arr(dep_elem_ctr),
                                                            p_plan_id);

                    IF (disabled_dep_elem_vo_attr IS NOT NULL) THEN
                         disabled_dep_elem_vo_attr_lst := disabled_dep_elem_vo_attr_lst || ',' ||
                                                          disabled_dep_elem_vo_attr;
                    END IF;

                    -- Getting the HC id column
                    disabled_dep_elem_id_attr :=
                    qa_chars_api.hardcoded_column(dependent_elements_arr(dep_elem_ctr));

                    IF (disabled_dep_elem_id_attr IS NOT NULL AND
                        disabled_dep_elem_id_attr <> disabled_dep_elem_vo_attr) THEN
                         disabled_dep_elem_vo_attr_lst := disabled_dep_elem_vo_attr_lst || ',' ||
                                                          disabled_dep_elem_id_attr;
                    END IF;

                    disabled_dep_elem_id_attr := NULL;
                    disabled_dep_elem_vo_attr := NULL;
                 END IF;
              END LOOP;

              IF (disabled_dep_elem_vo_attr_lst IS NOT NULL) THEN
                 disabled_dep_elem_vo_attr_lst := LTRIM(disabled_dep_elem_vo_attr_lst, ',');
              END IF;
       END IF;
   END IF;
END perform_ssqr_validation;

-- 12.1 QWB Usability Improvements
-- method to get the sql string for ResultExportVO
FUNCTION get_export_vo_sql (p_plan_id in NUMBER) Return VARCHAR2 is

CURSOR plan_chars IS
    select   upper(translate(qc.name,' ''*{}','_____')) name
    from     qa_chars qc,
             qa_plan_chars qpc
    WHERE    qc.char_id = qpc.char_id
    AND      qpc.plan_id = p_plan_id
    ORDER BY qpc.prompt_sequence;

l_sql_stmt    VARCHAR2(4000);
l_view_name   VARCHAR2(200);
BEGIN
    l_sql_stmt := 'select ''N'' as "HideShowStatus" , ';
    for rec in plan_chars
    loop
        l_sql_stmt := l_sql_stmt || rec.name ||', ';
    end loop;

    l_sql_stmt := l_sql_stmt || 'CREATED_BY, COLLECTION_ID, LAST_UPDATE_DATE FROM ';

    select view_name into l_view_name
    from qa_plans
    where plan_id = p_plan_id;

    l_sql_stmt := l_sql_stmt || l_view_name;

    return l_sql_stmt;

END get_export_vo_sql;

-- 12.1 QWB Usability Improvements
-- Procedure to fire the online actions
-- on elements that have triggers defined
-- for the value not entered conditition
--
FUNCTION processNotEnteredActions (p_plan_id         IN NUMBER,
                                    p_spec_id        IN NUMBER,
                                    p_ssqr_operation IN NUMBER DEFAULT NULL,
                                    p_row_elements         IN OUT NOCOPY ElementsArray,
                                    p_return_results_array IN OUT NOCOPY ResultRecordArray,
                                    message_array             OUT NOCOPY MessageArray)
     RETURN ErrorArray IS
   charctr        NUMBER;
   ordered_array  ElementInfoArray;
   ordered_array2 ElementInfoArray;
   error_list     ErrorArray;
   result_holder  ResultRecord;

   row_error_list ErrorArray;

   TYPE action_elements_tab_Typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   action_elements_tab  action_elements_tab_Typ ;

   Cursor cur is
     SELECT distinct char_id
       FROM qa_plan_char_action_triggers qpt, qa_plan_char_actions qpa
     WHERE plan_id = p_plan_id AND
           qpt.plan_char_action_trigger_id = qpa.plan_char_action_trigger_id AND
           operator = 8;
BEGIN
   ordered_array := populate_elements (p_row_elements, p_plan_id);

   for c in cur
   loop
      action_elements_tab(c.char_id) := c.char_id;
   end loop;

   For cntr in 0..ordered_array.COUNT-1
      Loop
         -- If the element is in the actions tab then it means
         -- the actions for it have not been fired since this tab
         -- is specific to elements having online actions defined on
         -- operator
         IF (action_elements_tab.EXISTS((ordered_array(cntr).id)) AND
             p_row_elements(ordered_array(cntr).id).id IS NULL AND
             p_row_elements(ordered_array(cntr).id).value IS NULL) THEN

            ordered_array(cntr).validation_flag := invalid_element;
         ELSE
            ordered_array(cntr).validation_flag := action_fired;
         END If;
         ordered_array2(ordered_array(cntr).id) := ordered_array(cntr);
      End Loop;

   charctr := p_row_elements.first;

   while charctr <= p_row_elements.last
      loop
         result_holder.element_id := charctr;

         -- In case the call is from the self-service application p_ssqr_operation=1
         -- then the results_record_arry needs to be populated. This is because in other
         -- cases the result array is populated by the validate_row api in qltrsiub
         -- which is not called for standalone ssqr operations
         --
         IF (p_ssqr_operation = 1)  THEN
            -- Assinging the element Id
            p_return_results_array(ordered_array2(charctr).id).element_id :=
                 ordered_array2(charctr).id;

            -- Assinging the element Normalized Id
            p_return_results_array(ordered_array2(charctr).id).id :=
                 p_row_elements(ordered_array2(charctr).id).id;

            -- Assinging the Actual data Type
            p_return_results_array(ordered_array2(charctr).id).actual_datatype :=
                 qa_plan_element_api.get_actual_datatype(ordered_array2(charctr).id);

           -- Assinging the Deferenced value
            p_return_results_array(ordered_array2(charctr).id).canonical_value :=
                 p_row_elements(ordered_array2(charctr).id).value;

         END IF;


         if p_return_results_array(ordered_array2(charctr).id).id  IS NOT NULL THEN
           -- Set the id value
           result_holder.id := p_return_results_array(ordered_array2(charctr).id).id;
         ELSE
           -- Set the canonical value
           result_holder.canonical_value := p_return_results_array(ordered_array2(charctr).id).canonical_value;
         END If;

         result_holder.actual_datatype := qa_plan_element_api.get_actual_datatype(charctr);

         IF (NOT (flag_is_set(ordered_array2(charctr).validation_flag,action_fired))) THEN
              error_list(6).error_code := fire_immediate_actions (
                                                   p_plan_id,
                                                   p_spec_id,
                                                   ordered_array2(charctr).id,
                                                   p_row_elements,
                                                   p_return_results_array,
                                                   message_array,
                                                   result_holder,
                                                   ordered_array2,
                                                   p_ssqr_operation);
         END IF;
         append_errors( ordered_array2(charctr).id, error_list, row_error_list);

         result_holder.id := NULL;
         error_list.delete;

         charctr := p_row_elements.next(charctr);
      end loop;
   RETURN row_error_list;
EXCEPTION WHEN OTHERS THEN
   raise;
END processNotEnteredActions;

BEGIN

    populate_dependency_matrix;
    init_message_map;

END qa_validation_api;

/
