--------------------------------------------------------
--  DDL for Package Body QA_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PLANS_PUB" AS
/* $Header: qltpplnb.plb 120.9.12010000.2 2010/04/30 10:16:02 ntungare ship $ */


-- Start of comments
--      API name        : qa_plans_pub
--      Type            : Public
-- End of comments


    TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


-- global variables section


g_pkg_name         CONSTANT VARCHAR2(30) := 'qa_plans_pub';
g_max_char_columns CONSTANT NUMBER := qltninrb.res_char_columns;

--
-- Safe globals.
--
g_user_name_cache  fnd_user.user_name%TYPE := NULL;
g_user_id_cache    NUMBER;

--
-- Bug 3926150.
-- This is used to keep a list of currently used CHARACTER result
-- column names, so that an unused result column can be easily
-- found (which will be added back to this array).
-- bso Fri Dec  3 20:42:27 PST 2004
--
g_result_columns  number_tab;
g_plan_id         NUMBER; -- a cache for performance purpose

--
-- General utility functions
--

PROCEDURE init_result_column_array(p_plan_id NUMBER) IS
--
-- Bug 3926150.  This procedure is created to keep track of whether a
-- CHARACTER column is in-use of free.  If p_plan_id is given then we
-- load the existing columns from a collection plan into the array.
-- We also cached the plan ID in g_plan_id for performance.  Only if
-- p_plan_id <> g_plan_id shall we reload the array.  If the plan_id
-- is not found, then we assume a new plan is being created so we
-- don't need to do anything.  If p_plan_id = -1 then we delete
-- the array (same as re-initialization).
--
-- bso Fri Dec  3 21:01:48 PST 2004
--
-- Bug 5406294
-- Modified the definition of the
-- Cursor to get the Substring of the
-- result column name as the result
-- col will have a value like
-- CHARACTERnn where nn would be the number part
-- SHKALYAN 24-JUL-2006
--
    CURSOR c IS
        SELECT to_number(SUBSTR(result_column_name, 10)) num
        FROM   qa_plan_chars
        WHERE  plan_id = p_plan_id AND
               result_column_name LIKE 'CHARACTER%';

BEGIN
    IF p_plan_id = g_plan_id THEN
        RETURN;
    END IF;

    --
    -- Many programmers will initialize the array with such a logic:
    --
    --  FOR i 1..g_max_char_columns LOOP
    --      g_result_columns(i) := 0;
    --  END LOOP;
    --
    -- including our own code in qltcpplb, qltauflb.  This is not
    -- performing well.  Use the collection method .EXISTS to test
    -- for existence is enough to know a member doesn't exist.
    -- bso Fri Dec  3 21:14:59 PST 2004
    --

    IF p_plan_id = -1 THEN
        g_result_columns.DELETE;
    ELSE
        FOR r IN c LOOP
            g_result_columns(r.num) := 1;
        END LOOP;
    END IF;

    g_plan_id := p_plan_id;

END init_result_column_array;


FUNCTION get_user_id(p_name VARCHAR2) RETURN NUMBER IS
--
-- Decode user name from fnd_user table.
--
    id NUMBER;

    CURSOR user_cursor IS
        SELECT user_id
        FROM fnd_user
        WHERE user_name = p_name;
BEGIN

--
-- Code is duplicated in qltpspcb.plb.  Any modification here
-- should be propagated to that file.
--

    IF p_name IS NULL THEN
        RETURN nvl(fnd_global.user_id, -1);
    END IF;

    --
    -- It is very common for the same user to call the
    -- APIs successively.
    --
    IF g_user_name_cache = p_name THEN
        RETURN g_user_id_cache;
    END IF;

    OPEN user_cursor;
    FETCH user_cursor INTO id;
    IF user_cursor%NOTFOUND THEN
        CLOSE user_cursor;
        RETURN -1;
    END IF;
    CLOSE user_cursor;

    g_user_name_cache := p_name;
    g_user_id_cache := id;

    RETURN id;
END get_user_id;


FUNCTION illegal_chars(p_name VARCHAR2) RETURN BOOLEAN IS
--
-- Check for illegal characters in a collection plan name.
-- Single quotes and spaces are allowed.
--
    potpourri CONSTANT VARCHAR2(30) := '!@#$%^&*()-+={}[]:;"|><?/\,.~';
    stars     CONSTANT VARCHAR2(30) := '*****************************';

BEGIN
    --
    -- Here is an easy way to do it:
    -- First translate all illegal chars to asterisks then use
    -- INSTR to see if * is present.  (Compare with the dozens
    -- of IF statements in QLTPLMDF)
    -- bso
    --
    RETURN instr(translate(p_name, potpourri, stars), '*') > 0;
END illegal_chars;


FUNCTION plan_exists(p_name IN VARCHAR2) RETURN NUMBER IS
--
-- Check if a collection plan already exists.  If so, return
-- the plan ID, if not return -1.
--
BEGIN

    RETURN nvl(qa_plans_api.plan_id(p_name), -1);

END plan_exists;


FUNCTION element_exists(p_plan_id IN NUMBER, p_char_id IN NUMBER)
    RETURN BOOLEAN IS
--
-- Check if an element already exists in a plan.
--
    CURSOR c IS
        SELECT 1
        FROM  qa_plan_chars
        WHERE plan_id = p_plan_id AND
              char_id = p_char_id;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END element_exists;


FUNCTION mandatory_element_exists(p_plan_id IN NUMBER)
--
-- Check if a mandatory and enabled element exists in a plan.
-- Needed when completing a new plan.
--
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM  qa_plan_chars
        WHERE plan_id = p_plan_id AND
              mandatory_flag = 1 AND
              enabled_flag = 1;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END mandatory_element_exists;


FUNCTION prompt_sequence_exists(p_plan_id IN NUMBER,
    p_prompt_sequence IN NUMBER) RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM  qa_plan_chars
        WHERE plan_id = p_plan_id AND
              prompt_sequence = p_prompt_sequence;

    l_dummy     NUMBER;
    l_found     BOOLEAN;

BEGIN

    OPEN c;
    FETCH c INTO l_dummy;
    l_found := c%FOUND;
    CLOSE c;

    RETURN l_found;

END prompt_sequence_exists;


PROCEDURE validate_datatype(p_value IN VARCHAR2, p_datatype NUMBER) IS

    temp_number Number;
    temp_date Date;

BEGIN

    IF p_value IS NULL THEN
        RETURN;
    END IF;

    IF p_datatype = qa_ss_const.number_datatype THEN
        BEGIN
            temp_number := to_number(p_value);
        EXCEPTION WHEN OTHERS THEN
            fnd_message.set_name('QA','QA_INVALID_NUMBER');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END;

    ELSIF p_datatype = qa_ss_const.date_datatype THEN
        BEGIN
            temp_date := qltdate.any_to_date(p_value);
        EXCEPTION WHEN OTHERS THEN
            fnd_message.set_name('QA','QA_INVALID_DATE');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END;
    END IF;

END validate_datatype;


FUNCTION convert_flag(p_flag IN VARCHAR2)
    RETURN NUMBER IS

BEGIN
    IF p_flag = fnd_api.g_true THEN
        RETURN 1;
    END IF;

    RETURN 2;
END convert_flag;


FUNCTION valid_plan_type (p_plan_type IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM  fnd_lookup_values
        WHERE lookup_type = 'COLLECTION_PLAN_TYPE'
        AND meaning = p_plan_type;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END valid_plan_type;


FUNCTION get_plan_type_code (p_plan_type IN VARCHAR2)
    RETURN VARCHAR2 IS

    CURSOR c IS
        SELECT lookup_code
        FROM fnd_lookup_values
        WHERE lookup_type = 'COLLECTION_PLAN_TYPE'
        AND meaning = p_plan_type;

   l_plan_type_code VARCHAR2(30);

BEGIN

    OPEN c;
    FETCH c INTO l_plan_type_code;
    CLOSE c;

    RETURN l_plan_type_code;

END get_plan_type_code;


--
-- Private functions for plan creation and element building.
--

FUNCTION get_next_sequence(p_plan_id NUMBER) RETURN NUMBER IS
    --
    -- This is a very specific function that computes
    -- the next prompt sequence for a plan when a new
    -- element is going to be added.
    --
    CURSOR c IS
        SELECT max(prompt_sequence)
        FROM   qa_plan_chars
        WHERE  plan_id = p_plan_id;

    p NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO p;
    IF c%NOTFOUND OR p IS NULL THEN
        --
        -- p IS NULL is needed.  For some reason, this cursor never
        -- raises the NOTFOUND condition.  Even if the plan id does not
        -- exist, max function returns a row of NULL instead of
        -- triggering NOTFOUND condition.
        --
        p := 10;
    ELSE
        --
        -- Add 10.
        -- Then, round to the nearest 10, so it has a nice 0 ending.
        --
        p := round((p + 10)/10) * 10;
    END IF;

    CLOSE c;
    RETURN p;

END get_next_sequence;


--
-- Bug 3926150.  This function is obsolete due to this bug fix.
-- See new function suggest_result_column() which is intentionally named
-- differently to make sure in compile time all references to the old
-- function will be found and modified.
-- bso Fri Dec  3 21:27:50 PST 2004
--
/*
FUNCTION get_next_result_column_name(p_plan_id NUMBER) RETURN VARCHAR2 IS
    --
    -- Another very specific function that computes
    -- the next result column name for a plan when a new
    -- softcoded element is going to be added.
    --

    CURSOR c IS
        SELECT max(to_number(substr(result_column_name, 10)))
        FROM   qa_plan_chars
        WHERE  plan_id = p_plan_id AND
               upper(result_column_name) like 'CHARACTER%';

    p      NUMBER;
    result qa_plan_chars.result_column_name%TYPE;

BEGIN

    OPEN c;
    FETCH c INTO p;
    IF c%NOTFOUND OR p IS NULL THEN
        --
        -- p IS NULL is needed.  For some reason, this cursor never
        -- raises the NOTFOUND condition.  Even if the plan id does not
        -- exist, max function returns a row of NULL instead of
        -- triggering NOTFOUND condition.
        --
        result := 'CHARACTER1';
    ELSE
        p := p + 1;
        IF p > g_max_char_columns THEN
            RETURN NULL;
        END IF;
        result := 'CHARACTER' || p;
    END IF;

    CLOSE c;
    RETURN result;

END get_next_result_column_name;
*/


PROCEDURE disable_index_private(p_char_id NUMBER) IS
--
-- Bug 3926150.  Simple helper to disable the function-based index
-- and insert informational message to the global msg stack.
-- bso Sat Dec  4 16:12:44 PST 2004
--
    dummy NUMBER;
BEGIN
    dummy := qa_char_indexes_pkg.disable_index(p_char_id);
    fnd_message.set_name('QA', 'QA_CHAR_REGENERATE_INDEX');
    fnd_message.set_token('ELEMENT_NAME',
        qa_chars_api.get_element_name(p_char_id));
    fnd_msg_pub.add;
END disable_index_private;


--
-- Bug 3926150.  A replacement of get_next_result_column_name to
-- return the new suggested result column name for a plan element.
-- It checks to see if the default result column of a function-based
-- index can be used.  If not, just find the first available column.
-- bso Fri Dec  3 21:30:02 PST 2004
--
FUNCTION suggest_result_column(p_plan_id NUMBER, p_char_id NUMBER)
    RETURN VARCHAR2 IS

    l_default_column qa_plan_chars.result_column_name%TYPE;
    dummy NUMBER;

BEGIN
    IF p_plan_id <> g_plan_id THEN
        --
        -- This will be a strange exceptional case.  It means caller is
        -- calling add_plan_elements for more than one plan in parallel.
        -- We can handle this by keep re-initializing.
        --
        init_result_column_array(-1);
        init_result_column_array(p_plan_id);
    END IF;

    l_default_column := qa_char_indexes_pkg.get_default_result_column(p_char_id);
    IF l_default_column IS NOT NULL THEN
        --
        -- We will be in here if there is a function-based index on this element.
        --
        IF NOT g_result_columns.EXISTS(to_number(substr(l_default_column, 10))) THEN
            --
            -- Here we know the default column name in that decode function
            -- is unassigned... great news, just use it.
            --
            RETURN l_default_column;
        ELSE
            --
            -- Otherwise, insert the informational message to the stack to ask user
            -- to regenerate the index.  Until then, the index will be disabled.
            --
            disable_index_private(p_char_id);
        END IF;
    END IF;

    FOR i IN 1 .. g_max_char_columns LOOP
        IF NOT g_result_columns.EXISTS(i) THEN
            RETURN 'CHARACTER' || i;
        END IF;
    END LOOP;

    RETURN NULL;
END suggest_result_column;


--
-- Bug 3926150.  Mark the result column name CHARACTERxx as in use.
--
PROCEDURE mark_result_column(p_col_name VARCHAR2) IS
BEGIN
    IF p_col_name LIKE 'CHARACTER%' THEN
        g_result_columns(to_number(substr(p_col_name, 10))) := 1;
    END IF;
END mark_result_column;


--
-- Private functions for plan completion verification.
--

FUNCTION get_plan_view_name(p_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    return 'Q_' || translate(substr(p_name, 1, 26), ' ''', '__') || '_V';
END get_plan_view_name;


FUNCTION get_import_view_name(p_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    return 'Q_' || translate(substr(p_name, 1, 25), ' ''', '__') || '_IV';
END get_import_view_name;


PROCEDURE check_element_dependencies(p_plan_id IN NUMBER) IS

    -- Set dependency flags from qa_plan_chars:
    --  1 = characteristic exists on the QPlan
    --  2 = characteristic does NOT exist on the QPlan

    CURSOR c IS
        SELECT min(decode(char_id, 10, 1, 2))  item,
               min(decode(char_id, 13, 1, 2))  revision,
               min(decode(char_id, 19, 1, 2))  job_name,
               min(decode(char_id, 20, 1, 2))  WIP_line,
               min(decode(char_id, 21, 1, 2))  to_op_seq,
               min(decode(char_id, 22, 1, 2))  from_op_seq,
               min(decode(char_id, 23, 1, 2))  to_intraop_step,
               min(decode(char_id, 24, 1, 2))  from_intraop_step,
               min(decode(char_id, 16, 1, 2))  lot_number,
               min(decode(char_id, 17, 1, 2))  serial_number,
               min(decode(char_id, 14, 1, 2))  subinv,
               min(decode(char_id, 12, 1, 2))  UOM,
               min(decode(char_id, 15, 1, 2))  locator,
               min(decode(char_id, 27, 1, 2))  po_number,
               min(decode(char_id, 110, 1, 2)) po_rel_number,
               min(decode(char_id, 28, 1, 2))  po_line,
               min(decode(char_id, 33, 1, 2))  so_number,
               min(decode(char_id, 35, 1, 2))  so_line,
               min(decode(char_id, 26, 1, 2))  vendor,
               min(decode(char_id, 60, 1, 2))  comp_item,
               min(decode(char_id, 65, 1, 2))  comp_locator,
               min(decode(char_id, 66, 1, 2))  comp_lot_number,
               min(decode(char_id, 63, 1, 2))  comp_revision,
               min(decode(char_id, 67, 1, 2))  comp_serial_number,
               min(decode(char_id, 64, 1, 2))  comp_subinv,
               min(decode(char_id, 62, 1, 2))  comp_UOM,
               min(decode(char_id, 122, 1, 2)) task_number,
               min(decode(char_id, 121, 1, 2)) project_number,
               --
               -- Bug 5680516.
               -- This is used to set dependency flag for the collection
               -- element SCARP OP SEQ (char id 144). From/To intra op step
               -- can exist if either From/To op seq or the Scrap op seq
               -- exists in the plan.
               -- skolluku Tue Feb 13, 2007
               --
               min(decode(char_id, 144, 1, 2)) scrap_op_seq,
               -- R12 OPM Deviations. Bug 4345503 Start
               min(decode(char_id, 2147483556, 1, 2)) process_batch_num,
	       min(decode(char_id, 2147483555, 1, 2)) process_batchstep_num,
	       min(decode(char_id, 2147483554, 1, 2)) process_operation,
	       min(decode(char_id, 2147483553, 1, 2)) process_activity,
	       min(decode(char_id, 2147483552, 1, 2)) process_resources,
	       min(decode(char_id, 2147483551, 1, 2)) process_parameter_name
               -- R12 OPM Deviations. Bug 4345503 End
    FROM  qa_plan_chars
    WHERE plan_id = p_plan_id AND enabled_flag = 1;

    -- qa_plan_char flags

    item_flag                   NUMBER;
    revision_flag               NUMBER;
    job_name_flag               NUMBER;
    wip_line_flag               NUMBER;
    to_op_seq_flag              NUMBER;
    from_op_seq_flag            NUMBER;
    to_intraop_step_flag        NUMBER;
    from_intraop_step_flag      NUMBER;
    lot_number_flag             NUMBER;
    serial_number_flag          NUMBER;
    subinv_flag                 NUMBER;
    uom_flag                    NUMBER;
    locator_flag                NUMBER;
    po_number_flag              NUMBER;
    po_rel_number_flag          NUMBER;
    po_line_flag                NUMBER;
    vendor_flag                 NUMBER;
    so_number_flag              NUMBER;
    so_line_flag                NUMBER;
    comp_item_flag              NUMBER;
    comp_locator_flag           NUMBER;
    comp_lot_number_flag        NUMBER;
    comp_revision_flag          NUMBER;
    comp_serial_number_flag     NUMBER;
    comp_subinv_flag            NUMBER;
    comp_uom_flag               NUMBER;
    task_num_flag               NUMBER;
    project_num_flag            NUMBER;
    --
    -- Bug 5680516.
    -- This is used to set dependency flag for the collection
    -- element SCARP OP SEQ (char id 144). From/To intra op step
    -- can exist if either From/To op seq or the Scrap op seq
    -- exists in the plan.
    -- skolluku Tue Feb 13, 2007
    --
    scrap_op_seq_flag           NUMBER;

    -- R12 OPM Deviations. Bug 4345503 Start
    process_batch_num_flag      NUMBER;
    process_batchstep_num_flag  NUMBER;
    process_operation_flag      NUMBER;
    process_activity_flag       NUMBER;
    process_resource_flag       NUMBER;
    process_parameter_flag      NUMBER;
    -- R12 OPM Deviations. Bug 4345503 End
BEGIN

    -- The Quality Plan Workbench should enforce dependencies between
    -- characteristics.  For example, if op seq is a characteristic on a
    -- plan, then job or line must be on the plan too.
    --
    --      WIP:
    --          - op seq (to/from) requires a wip entity ID (JOB NAME)
    --              or LINE
    --          - WIP production line requires an ITEM
    --          - intraop step (to/from) needs OP SEQ
    --            --5680516
    --            or SCRAP OP SEQ
    --          - you can't have both JOB NAME and LINE on the same QPlan
    --
    --      INV:
    --          - locator requires a SUBINV
    --          - lot requires an ITEM
    --          - serial number requires an ITEM
    --          - revision requires an ITEM
    --          - if item is on the plan, revision may need to be on it,
    --              so caution the user
    --          - if subinventory is on the plan, locator may need
    --              to be on it as well so caution the user
    --          - the above 6 items are also true for their component
    --            counterparts
    --
    --      PO:
    --          - PO line dependent on PO NUMBER
    --          - PO release number dependent on PO NUMBER
    --
    --      SO:
    --          - SO line dependent on SO NUMBER
    --
    -- The Quality Plan Workbench should enforce dependencies between
    -- characteristics and actions.  For example, if a selected action is
    -- "put job on hold", then JOB NAME must appear on the QPlan.
    -- Dependencies are:
    --
    --  Action                          Requires
    --  -----------------------------   -------------------------
    --  Job on hold                     Job Name
    --  Schedule on hold                WIP line
    --  Item status                     Item
    --  Lot status code (R11)           Lot number
    --  S/N status code (R11)           S/N
    --  Shop floor status               To or From Intra-op step
    --  Put PO line on hold             PO line
    --  Put vendor on hold              Vendor

    OPEN c;
    FETCH c INTO
        item_flag,
        revision_flag,
        job_name_flag,
        wip_line_flag,
        to_op_seq_flag,
        from_op_seq_flag,
        to_intraop_step_flag,
        from_intraop_step_flag,
        lot_number_flag,
        serial_number_flag,
        subinv_flag,
        uom_flag,
        locator_flag,
        po_number_flag,
        po_rel_number_flag,
        po_line_flag,
        so_number_flag,
        so_line_flag,
        vendor_flag,
        comp_item_flag,
        comp_locator_flag,
        comp_lot_number_flag,
        comp_revision_flag,
        comp_serial_number_flag,
        comp_subinv_flag,
        comp_uom_flag,
        task_num_flag,
        project_num_flag,
        --
        -- Bug 5680516.
        -- This is used to set dependency flag for the collection
        -- element SCARP OP SEQ (char id 144). From/To intra op step
        -- can exist if either From/To op seq or the Scrap op seq
        -- exists in the plan.
        -- skolluku Tue Feb 13, 2007
        --
        scrap_op_seq_flag,
        -- R12 OPM Deviations. Bug 4345503 Start
        process_batch_num_flag,
        process_batchstep_num_flag,
        process_operation_flag,
        process_activity_flag,
        process_resource_flag,
        process_parameter_flag;
        -- R12 OPM Deviations. Bug 4345503 End
    CLOSE c;

      -- Check dependencies on item

    IF (item_flag = 2) THEN

       IF (lot_number_flag = 1) THEN
           fnd_message.set_name ('QA', 'QA_DEPENDENT_LOT_ON_ITEM');
           fnd_msg_pub.add();
           RAISE fnd_api.g_exc_error;
       END IF;

       IF (serial_number_flag = 1) THEN
           fnd_message.set_name ('QA', 'QA_DEPENDENT_SERIAL_ON_ITEM');
           fnd_msg_pub.add();
           RAISE fnd_api.g_exc_error;
       END IF;

       IF (wip_line_flag = 1) THEN
           fnd_message.set_name ('QA', 'QA_DEPENDENT_WIP_LINE_ON_ITEM');
           fnd_msg_pub.add();
           RAISE fnd_api.g_exc_error;
       END IF;

        IF (revision_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_REV_ON_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

        IF (subinv_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_SUBINV_ON_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

        IF (uom_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_UOM_ON_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;

    -- check dependencies on component item

    IF (comp_item_flag = 2) THEN

        IF (comp_lot_number_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_COMP_LOT_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

        IF (comp_serial_number_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_COMP_SERIAL_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

        IF (comp_revision_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_COMP_REV_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

        IF (comp_subinv_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_COMP_SUBINV_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

        IF (comp_uom_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_COMP_UOM_ITEM');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;


    -- Check dependencies on job/line

    IF (job_name_flag = 2 AND wip_line_flag = 2) THEN

        IF (to_op_seq_flag = 1 OR from_op_seq_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_OPSEQ_ON_JOB');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;


    -- Check dependencies on to/from op seq

    IF (to_op_seq_flag = 2)
    --
    -- Bug 5680516.
    -- Added dependency of To Intra op Step on Scrap Op Seq
    -- collection element if To Op Seq is not present in the
    -- plan. Added this condition to throw an error only if
    -- both To Op Seq and Scrap Op Seq are not present in the
    -- plan but To Intra Op Step is present in the plan.
    -- skolluku Tue Feb 13, 2007
    --
     AND (scrap_op_seq_flag = 2) THEN

        IF (to_intraop_step_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_INTRAOP_ON_OPSEQ');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;

    IF (from_op_seq_flag = 2)
    --
    -- Bug 5680516.
    -- Added dependency of From Intra op Step on Scrap Op Seq
    -- collection element if From Op Seq is not present in the
    -- plan. Added this condition to throw an error only if
    -- both From Op Seq and Scrap Op Seq are not present in the
    -- plan but From Intra Op Step is present in the plan.
    -- skolluku Tue Feb 13, 2007
    --
     AND (scrap_op_seq_flag = 2) THEN

        IF (from_intraop_step_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_INTRAOP_ON_OPSEQ');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;


    -- Check dependencies on SUBINV

    IF (subinv_flag = 2) THEN

        IF (locator_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_LOCATOR_ON_SUB');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;

    -- Check dependencies on COMP_SUBINV

    IF (comp_subinv_flag = 2) THEN

        IF (comp_locator_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_COMP_LOCATOR_SUB');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;


    -- Check dependencies on PO NUMBER

    IF (po_number_flag = 2) THEN

        IF (po_line_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_PO_LINE_ON_HEADER');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

        IF (po_rel_number_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_PO_REL_ON_HEADER');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;


    -- Check dependencies on SO NUMBER

    IF (so_number_flag = 2) THEN

        IF (so_line_flag = 1) THEN
            fnd_message.set_name ('QA', 'QA_DEPENDENT_SO_LINE_ON_HEADER');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;

    IF (project_num_flag = 2) THEN

         IF (task_num_flag = 1) THEN
             fnd_message.set_name ('QA', 'QA_PROJECT_TASK_DEPEND');
             fnd_msg_pub.add();
             RAISE fnd_api.g_exc_error;
         END IF;

    END IF;

-- R12 OPM Deviations. Bug 4345503 Start

   IF (process_resource_flag = 2) THEN
     IF (process_parameter_flag = 1) THEN
       fnd_message.set_name ('QA', 'QA_DEPENDENT_PLAN_CHARS');
       fnd_message.set_token('CHILD_ELEMENT',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_parameter));
       fnd_message.set_token('ELEMENT_LIST',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_batch_num));
       fnd_msg_pub.add();
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   IF (process_activity_flag = 2) THEN
     IF (process_resource_flag = 1) THEN
       fnd_message.set_name ('QA', 'QA_DEPENDENT_PLAN_CHARS');
       fnd_message.set_token('CHILD_ELEMENT',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_resource));
       fnd_message.set_token('ELEMENT_LIST',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_batch_num));
       fnd_msg_pub.add();
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   IF (process_batchstep_num_flag = 2) THEN
     IF (process_activity_flag = 1) THEN
       fnd_message.set_name ('QA', 'QA_DEPENDENT_PLAN_CHARS');
       fnd_message.set_token('CHILD_ELEMENT',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_activity));
       fnd_message.set_token('ELEMENT_LIST',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_batch_num));
       fnd_msg_pub.add();
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   IF (process_batchstep_num_flag = 2) THEN
     IF (process_operation_flag = 1) THEN
       fnd_message.set_name ('QA', 'QA_DEPENDENT_PLAN_CHARS');
       fnd_message.set_token('CHILD_ELEMENT',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_operation));
       fnd_message.set_token('ELEMENT_LIST',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_batch_num));
       fnd_msg_pub.add();
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   IF (process_batch_num_flag = 2) THEN
     IF (process_batchstep_num_flag = 1) THEN
       fnd_message.set_name ('QA', 'QA_DEPENDENT_PLAN_CHARS');
       fnd_message.set_token('CHILD_ELEMENT',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_batchstep_num));
       fnd_message.set_token('ELEMENT_LIST',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.process_batch_num));
       fnd_msg_pub.add();
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

-- R12 OPM Deviations. Bug 4345503 End
END check_element_dependencies;


PROCEDURE complete_plan_private(
    p_plan_id NUMBER,
    p_plan_name VARCHAR2,
    p_commit VARCHAR2,
    p_user_id NUMBER) IS

    l_request_id NUMBER;
BEGIN
    IF NOT mandatory_element_exists(p_plan_id) THEN
        fnd_message.set_name('QA', 'QA_QPLAN_MUST_HAVE_CHARS');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    check_element_dependencies(p_plan_id);

    IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;

        --
        -- Launch the dynamic view creator only if the user
        -- commits; otherwise, the view generator will fail
        -- because it is run in another database session.
        --
        -- The init is required to get the concurrent program
        -- to run.  The resp_id 20561 is the seeded main Quality
        -- responsibility.  250 is Oracle Quality's application ID.
        --
        fnd_global.apps_initialize(
            user_id      => p_user_id,
            resp_id      => 20561,
            resp_appl_id => 250);

        l_request_id := fnd_request.submit_request(
            application => 'QA',
            program     => 'QLTPVWWB',
            argument1   => get_plan_view_name(p_plan_name),
            argument2   => NULL,
            argument3   => to_char(p_plan_id),
            argument4   => get_import_view_name(p_plan_name),
            argument5   => NULL,
            argument6   => 'QA_GLOBAL_RESULTS_V');

        COMMIT;
    END IF;
END complete_plan_private;


--
-- Private functions for copying a collection plan.
--

FUNCTION copy_plan_header(
    p_from_plan_id     IN NUMBER,
    p_to_plan_name     IN VARCHAR2,
    p_to_org_id        IN NUMBER,
    p_user_id          IN NUMBER)
    RETURN NUMBER IS

    l_plan_name    qa_plans.name%TYPE;
    l_plan_view    qa_plans.view_name%TYPE;
    l_import_view  qa_plans.import_view_name%TYPE;
    l_to_plan_id   NUMBER;

BEGIN

    --
    -- Let's see if the target plan already exists
    --
    l_plan_name := upper(p_to_plan_name);
    l_to_plan_id := plan_exists(l_plan_name);

    IF l_to_plan_id = -1 THEN
        --
        -- Create a new plan header in qa_plans table.
        --
        SELECT qa_plans_s.nextval INTO l_to_plan_id FROM dual;

        l_plan_view := get_plan_view_name(l_plan_name);
        l_import_view := get_import_view_name(l_plan_name);

        -- Bug 3726391. shkalyan 28 June 2004
        -- Added insert of missing columns viz.
        -- instructions,displayed_flag,attribute_category,
        -- attribute1 to attribute15

        -- Bug 3726391. shkalyan 30 June 2004
        -- Removed insert of attribute_category,attribute1 to attribute15
        -- As per code review comments

        -- Bug 3763668. ilawler 13 July 2004
                -- Removed DISPLAYED_FLAG field, not a valid case column

        -- 12.1 QWB Usability Improvements Project
        -- Added the Multirow flag column
        -- ntungare
        --
        -- bug 9562325
        -- Added new parameters to set the DFF attributes
        -- on the plan header level
        --
        INSERT INTO qa_plans(
            plan_id,
            organization_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            name,
            plan_type_code,
            spec_assignment_type,
            description,
            import_view_name,
            view_name,
            effective_from,
            effective_to,
            template_plan_id,
            esig_mode,
            instructions,
            multirow_flag,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15)
        SELECT
            l_to_plan_id,
            p_to_org_id,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_user_id,
            p_to_plan_name,
            plan_type_code,
            spec_assignment_type,
            description,
            l_import_view,
            l_plan_view,
            effective_from,
            effective_to,
            template_plan_id,
            esig_mode,
            instructions,
            multirow_flag,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15
        FROM  qa_plans
        WHERE plan_id = p_from_plan_id;

    END IF;

    RETURN l_to_plan_id;

END copy_plan_header;


--
-- Bug 3926150.  Commenting out copy_plan_elements because it
-- is obsolete by copy_plan_elements_bulk.  We don't want to
-- dual maintain two codelines.
-- bso Fri Dec  3 21:59:44 PST 2004
--
/*
PROCEDURE copy_plan_elements(
    p_copy_from_plan_id IN NUMBER,
    p_copy_to_plan_id IN NUMBER,
    p_copy_values_flag IN VARCHAR2,
    p_user_id IN NUMBER) IS

    --
    -- This cursor retrieves all plan elements from the source
    -- plan except those that already occur in the target plan
    -- (which could be an existing plan).
    --
    -- Explain plan shows NOT IN performance is OK.
    --

    -- Tracking Bug : 3104827
    -- Modifying to include Three new Flags for Read Only Collection Plan Elements
    -- saugupta Thu Aug 28 08:59:59 PDT 2003

    -- Bug 3726391. shkalyan 28 June 2004
    -- Added missing columns viz.
    -- decimal_precision,uom_code,attribute_category,attribute1 to attribute15

    -- Bug 3726391. shkalyan 30 June 2004
    -- Removed insert of attribute_category,attribute1 to attribute15
    -- As per code review comments

    CURSOR c IS
        SELECT
            char_id,
            prompt_sequence,
            prompt,
            enabled_flag,
            mandatory_flag,
            default_value,
            upper(result_column_name) result_column_name,
            values_exist_flag,
            displayed_flag,
            default_value_id,
            read_only_flag,
            ss_poplist_flag,
            information_flag,
            decimal_precision,
            uom_code
        FROM
            qa_plan_chars
        WHERE
            plan_id = p_copy_from_plan_id AND char_id NOT IN
            (SELECT char_id
             FROM   qa_plan_chars
             WHERE  plan_id = p_copy_to_plan_id)
        ORDER BY prompt_sequence;

    l_prompt_sequence   NUMBER;
    l_char_sequence     NUMBER;
    l_char_column_name  VARCHAR2(30);
    l_result_column     qa_plan_chars.result_column_name%TYPE;

BEGIN

    l_prompt_sequence := get_next_sequence(p_copy_to_plan_id);
    l_char_column_name := get_next_result_column_name(p_copy_to_plan_id);
    IF l_char_column_name IS NULL THEN
        --
        -- This will guarantee it prints exceed column message later.
        --
        l_char_sequence := g_max_char_columns + 1;
    ELSE
        l_char_sequence := to_number(substr(l_char_column_name, 10));
    END IF;

    --
    -- For each record in cursor c, insert into the target plan
    -- with the proper prompt_sequence and result_column_name.
    --

    FOR pc IN c LOOP

        IF pc.result_column_name LIKE 'CHARACTER%' THEN
            IF l_char_sequence > g_max_char_columns THEN
                fnd_message.set_name('QA', 'QA_EXCEEDED_COLUMN_COUNT');
                fnd_msg_pub.add();
                raise fnd_api.g_exc_error;
            END IF;
            l_result_column := 'CHARACTER' || l_char_sequence;
            l_char_sequence := l_char_sequence + 1;
        ELSE
            l_result_column := pc.result_column_name;
        END IF;

        -- Tracking Bug : 3104827
        -- Modifying to include Three new Flags for Collection Plan Element
        -- saugupta Thu Aug 28 08:59:59 PDT 2003

        -- Bug 3726391. shkalyan 28 June 2004
        -- Added insert of missing columns viz.
        -- decimal_precision,uom_code,attribute_category,
        -- attribute1 to attribute15

        -- Bug 3726391. shkalyan 30 June 2004
        -- Removed insert of attribute_category,attribute1 to attribute15
        -- As per code review comments

        INSERT INTO qa_plan_chars(
            plan_id,
            char_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            prompt_sequence,
            prompt,
            enabled_flag,
            mandatory_flag,
            default_value,
            result_column_name,
            values_exist_flag,
            displayed_flag,
            default_value_id,
            read_only_flag,
            ss_poplist_flag,
            information_flag,
            decimal_precision,
            uom_code)
        VALUES (
            p_copy_to_plan_id,
            pc.char_id,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_user_id,
            l_prompt_sequence,
            pc.prompt,
            pc.enabled_flag,
            pc.mandatory_flag,
            pc.default_value,
            l_result_column,
            decode(p_copy_values_flag,
                fnd_api.g_true, pc.values_exist_flag, 2),
            pc.displayed_flag,
            pc.default_value_id,
            pc.read_only_flag,
            pc.ss_poplist_flag,
            pc.information_flag,
            pc.decimal_precision,
            pc.uom_code
        );

        l_prompt_sequence := l_prompt_sequence + 10;
    END LOOP;

END copy_plan_elements;
*/


--
-- This version of copy_plan_elements does the same as the
-- above procedure, but uses 8i Bulk bind feature to improve
-- performance.
--
PROCEDURE copy_plan_elements_bulk(
    p_copy_from_plan_id IN NUMBER,
    p_copy_to_plan_id IN NUMBER,
    p_copy_values_flag IN VARCHAR2,
    p_user_id IN NUMBER) IS

    TYPE prompt_tab IS TABLE OF qa_plan_chars.prompt%TYPE
        INDEX BY BINARY_INTEGER;

    TYPE default_tab IS TABLE OF qa_plan_chars.default_value%TYPE
        INDEX BY BINARY_INTEGER;

    TYPE result_tab IS TABLE OF qa_plan_chars.result_column_name%TYPE
        INDEX BY BINARY_INTEGER;

    char_ids            number_tab;
    prompt_sequences    number_tab;
    prompts             prompt_tab;
    enabled_flags       number_tab;
    mandatory_flags     number_tab;
    default_values      default_tab;
    result_column_names result_tab;
    values_exist_flags  number_tab;
    displayed_flags     number_tab;
    default_value_ids   number_tab;

    l_prompt_sequence   NUMBER;
    l_char_sequence     NUMBER;
    l_char_column_name  VARCHAR2(30);

    -- Tracking Bug : 3104827
    -- Added to include Three new Flags for Collection Plan Element
    -- saugupta Thu Aug 28 08:59:59 PDT 2003
    read_only_flags     number_tab;
    ss_poplist_flags    number_tab;
    information_flags   number_tab;

    -- Bug 3726391. shkalyan 28 June 2004
    -- Added declaration of missing columns viz.
    -- decimal_precision,uom_code,attribute_category,attribute1 to attribute15

    -- Bug 3726391. shkalyan 30 June 2004
    -- Removed insert of attribute_category,attribute1 to attribute15
    -- As per code review comments

    TYPE uom_code_tab IS TABLE OF qa_plan_chars.uom_code%TYPE
        INDEX BY BINARY_INTEGER;

    decimal_precisions   number_tab;
    uom_codes            uom_code_tab;

    -- Tracking Bug : 6734330 Device Integration Project
    -- Included three columns device_flag,
    -- device_id and override_flag for Collection Plan Elements
    -- bhsankar Mon Jan  7 22:00:17 PST 2008
    device_flags     number_tab;
    device_ids       number_tab;
    override_flags   number_tab;

    --
    -- bug 9562325
    -- Added new parameters to set the DFF attributes
    -- on the plan element level
    --
    TYPE attr_cat_tab IS TABLE OF qa_plan_chars.attribute_category%TYPE
        INDEX BY BINARY_INTEGER;

    TYPE attr_tab IS TABLE OF qa_plan_chars.attribute1%TYPE;

    attribute_categories attr_cat_tab;
    attribute1s          attr_tab;
    attribute2s          attr_tab;
    attribute3s          attr_tab;
    attribute4s          attr_tab;
    attribute5s          attr_tab;
    attribute6s          attr_tab;
    attribute7s          attr_tab;
    attribute8s          attr_tab;
    attribute9s          attr_tab;
    attribute10s         attr_tab;
    attribute11s         attr_tab;
    attribute12s         attr_tab;
    attribute13s         attr_tab;
    attribute14s         attr_tab;
    attribute15s         attr_tab;
BEGIN

    --
    -- This cursor retrieves all plan elements from the source
    -- plan except those that already occur in the target plan
    -- (which could be an existing plan).
    --
    -- Explain plan shows NOT IN performance is OK.
    --

    -- Bug 3726391. shkalyan 28 June 2004
    -- Added select of missing columns viz.
    -- decimal_precision,uom_code,attribute_category,attribute1 to attribute15

    -- Bug 3726391. shkalyan 30 June 2004
    -- Removed insert of attribute_category,attribute1 to attribute15
    -- As per code review comments

    -- Bug 6734330
    -- Device Integration Project
    -- Added device columns device_id,
    -- device_flag and override_flags.
    -- bhsankar Mon Jan  7 22:00:17 PST 2008
    SELECT
        char_id,
        prompt_sequence,
        prompt,
        enabled_flag,
        mandatory_flag,
        default_value,
        upper(result_column_name) result_column_name,
        values_exist_flag,
        displayed_flag,
        default_value_id,
        read_only_flag,
        ss_poplist_flag,
        information_flag,
        decimal_precision,
        uom_code,
        device_flag,
        device_id,
        override_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15
    BULK COLLECT INTO
        char_ids,
        prompt_sequences,
        prompts,
        enabled_flags,
        mandatory_flags,
        default_values,
        result_column_names,
        values_exist_flags,
        displayed_flags,
        default_value_ids,
        read_only_flags,
        ss_poplist_flags,
        information_flags,
        decimal_precisions,
        uom_codes,
        device_flags,
        device_ids,
        override_flags,
        attribute_categories,
        attribute1s,
        attribute2s,
        attribute3s,
        attribute4s,
        attribute5s,
        attribute6s,
        attribute7s,
        attribute8s,
        attribute9s,
        attribute10s,
        attribute11s,
        attribute12s,
        attribute13s,
        attribute14s,
        attribute15s
    FROM
        qa_plan_chars
    WHERE
        plan_id = p_copy_from_plan_id AND char_id NOT IN
        (SELECT char_id
         FROM   qa_plan_chars
         WHERE  plan_id = p_copy_to_plan_id)
    ORDER BY prompt_sequence;

    IF char_ids.COUNT = 0 THEN
        --
        -- This is needed in case the target plan is an existing
        -- plan that already contains all elements in the source.
        --
        RETURN;
    END IF;

    l_prompt_sequence := get_next_sequence(p_copy_to_plan_id);

    --
    -- Bug 3926150.  This should be done inside the loop for this
    -- fix.  In fact it was a bug to just increment by 1 in the
    -- original logic.
    -- bso Fri Dec  3 22:10:27 PST 2004
    --
    -- l_char_column_name := get_next_result_column_name(p_copy_to_plan_id);
    -- IF l_char_column_name IS NULL THEN
    --    --
    --    -- This will guarantee it prints exceed column message later.
    --    --
    --    l_char_sequence := g_max_char_columns + 1;
    -- ELSE
    --    l_char_sequence := to_number(substr(l_char_column_name, 10));
    -- END IF;
    --

    --
    -- For each plan element to be copied, adjust the
    -- prompt_sequence and result_column_name.
    --

    FOR i IN char_ids.FIRST .. char_ids.LAST LOOP
        IF result_column_names(i) LIKE 'CHARACTER%' THEN
            --
            -- Bug 3926150.
            -- Change the result column assignment code to use the new
            -- suggest_result_column function.
            -- bso Fri Dec  3 22:30:23 PST 2004
            --
            result_column_names(i) := suggest_result_column(p_copy_to_plan_id,
                char_ids(i));
            IF result_column_names(i) IS NULL THEN
                fnd_message.set_name('QA', 'QA_EXCEEDED_COLUMN_COUNT');
                fnd_msg_pub.add();
                raise fnd_api.g_exc_error;
            END IF;
            mark_result_column(result_column_names(i));
        END IF;

        prompt_sequences(i) := l_prompt_sequence;
        l_prompt_sequence := l_prompt_sequence + 10;
    END LOOP;

    --
    -- Clear the values_exist_flags if values are not copied.
    --
    IF p_copy_values_flag = fnd_api.g_false THEN
        FOR i IN char_ids.FIRST .. char_ids.LAST LOOP
            values_exist_flags(i) := 2;
        END LOOP;
    END IF;

    -- Bug 3726391. shkalyan 28 June 2004
    -- Added insert of missing columns viz.
    -- decimal_precision,uom_code,attribute_category,attribute1 to attribute15

    -- Bug 3726391. shkalyan 30 June 2004
    -- Removed insert of attribute_category,attribute1 to attribute15
    -- As per code review comments

    -- Bug 6734330
    -- Device Integration Project
    -- Added device columns device_id,
    -- device_flag and override_flags.
    -- bhsankar Mon Jan  7 22:00:17 PST 2008
    --
    -- bug 9562325
    -- Added new parameters to set the DFF attributes
    -- on the plan element level
    --
    FORALL i IN char_ids.FIRST .. char_ids.LAST
        INSERT INTO qa_plan_chars(
            plan_id,
            char_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            prompt_sequence,
            prompt,
            enabled_flag,
            mandatory_flag,
            default_value,
            result_column_name,
            values_exist_flag,
            displayed_flag,
            default_value_id,
            read_only_flag,
            ss_poplist_flag,
            information_flag,
            decimal_precision,
            uom_code,
            device_flag,
            device_id,
            override_flag,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15)
        VALUES (
            p_copy_to_plan_id,
            char_ids(i),
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_user_id,
            prompt_sequences(i),
            prompts(i),
            enabled_flags(i),
            mandatory_flags(i),
            default_values(i),
            result_column_names(i),
            values_exist_flags(i),
            displayed_flags(i),
            default_value_ids(i),
            read_only_flags(i),
            ss_poplist_flags(i),
            information_flags(i),
            decimal_precisions(i),
            uom_codes(i),
            device_flags(i),
            device_ids(i),
            override_flags(i),
            attribute_categories(i),
            attribute1s(i),
            attribute2s(i),
            attribute3s(i),
            attribute4s(i),
            attribute5s(i),
            attribute6s(i),
            attribute7s(i),
            attribute8s(i),
            attribute9s(i),
            attribute10s(i),
            attribute11s(i),
            attribute12s(i),
            attribute13s(i),
            attribute14s(i),
            attribute15s(i)
        );

END copy_plan_elements_bulk;


PROCEDURE copy_plan_element_values(p_copy_from_plan_id IN NUMBER,
    p_copy_to_plan_id IN NUMBER, p_user_id IN NUMBER) IS

BEGIN

    --
    -- Explain plan shows NOT IN performance is OK.
    --
    INSERT INTO qa_plan_char_value_lookups(
        plan_id,
        char_id,
        short_code,
        description,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        short_code_id)
    SELECT
        p_copy_to_plan_id,
        char_id,
        short_code,
        description,
        sysdate,
        p_user_id,
        p_user_id,
        sysdate,
        created_by,
        short_code_id
    FROM  qa_plan_char_value_lookups
    WHERE plan_id = p_copy_from_plan_id AND char_id NOT IN
       (SELECT char_id
        FROM qa_plan_chars
        WHERE plan_id = p_copy_to_plan_id);

END copy_plan_element_values;


PROCEDURE copy_plan_element_actions(p_copy_from_plan_id IN NUMBER,
    p_copy_to_plan_id IN NUMBER, p_user_id IN NUMBER) IS

    CURSOR action_trigger_cursor is
        SELECT
            plan_char_action_trigger_id,
            trigger_sequence,
            plan_id,
            char_id,
            operator,
            low_value_lookup,
            high_value_lookup,
            low_value_other,
            high_value_other,
            low_value_other_id,
            high_value_other_id
        FROM qa_plan_char_action_triggers
        WHERE plan_id = p_copy_from_plan_id AND char_id NOT IN
           (SELECT char_id
            FROM qa_plan_chars
            WHERE plan_id = p_copy_to_plan_id)
        ORDER BY trigger_sequence;

    CURSOR action_cursor(x NUMBER) IS
        SELECT
            plan_char_action_id,
            plan_char_action_trigger_id,
            action_id,
            car_name_prefix,
            car_type_id,
            car_owner,
            message,
            status_code,
            alr_action_id,
            alr_action_set_id,
            assigned_char_id,
            assign_type
        FROM qa_plan_char_actions
        WHERE plan_char_action_trigger_id = x
        ORDER BY plan_char_action_id;

    -- Bug 3111310
    -- Modified the cursor for SQL performance fix
    -- saugupta Mon Sep  8 06:00:06 PDT 2003

    CURSOR alert_cursor(x NUMBER) is
        SELECT
            application_id,
            action_id,
            name,
            alert_id,
            action_type,
            end_date_active,
            enabled_flag,
            description,
            action_level_type,
            date_last_executed,
            file_name,
            argument_string,
            program_application_id,
            concurrent_program_id,
            list_application_id,
            list_id,
            to_recipients,
            cc_recipients,
            bcc_recipients,
            print_recipients,
            printer,
            subject,
            reply_to,
            response_set_id,
            follow_up_after_days,
            column_wrap_flag,
            maximum_summary_message_width,
            body,
            version_number
        FROM alr_actions
        WHERE action_id = x
        AND application_id = 250;

    alra alert_cursor%ROWTYPE;

    l_qpcat_id                  NUMBER;
    l_qpca_id                   NUMBER;

    l_action_set_seq            NUMBER;
    l_action_set_members_seq    NUMBER;
    l_action_name_seq           NUMBER;
    l_action_set_name_seq       NUMBER;

    new_action_id               NUMBER;
    new_action_set_id           NUMBER;
    new_action_set_member_id    NUMBER;
    new_action_name             alr_actions.name%TYPE;
    new_action_set_name         alr_action_sets.name%TYPE;


BEGIN

    FOR qpcat IN action_trigger_cursor LOOP

        SELECT qa_plan_char_action_triggers_s.nextval
        INTO l_qpcat_id
        FROM dual;

        INSERT INTO qa_plan_char_action_triggers (
            plan_char_action_trigger_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            trigger_sequence,
            plan_id,
            char_id,
            operator,
            low_value_lookup,
            high_value_lookup,
            low_value_other,
            high_value_other,
            low_value_other_id,
            high_value_other_id)
        VALUES (
            l_qpcat_id,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_user_id,
            qpcat.trigger_sequence,
            p_copy_to_plan_id,
            qpcat.char_id,
            qpcat.operator,
            qpcat.low_value_lookup,
            qpcat.high_value_lookup,
            qpcat.low_value_other,
            qpcat.high_value_other,
            qpcat.low_value_other_id,
            qpcat.high_value_other_id);

        -- Bug 5300577
        -- Included this condition to get the translated value of
        -- ACCEPT and REJECT so that Action for the inspection Result
        -- element fires accurately.
        -- Included Template OPM Recieving inspection plan because
        -- conversion is required for these plans as well.

        IF p_copy_from_plan_id IN (1,2147483637) AND
           qpcat.low_value_other IN ('ACCEPT', 'REJECT') THEN

           UPDATE QA_PLAN_CHAR_ACTION_TRIGGERS
           SET    low_value_other = (SELECT displayed_field
                                     FROM   PO_LOOKUP_CODES
                                     WHERE  lookup_type = 'ERT RESULTS ACTION'
                                     AND    lookup_code = qpcat.low_value_other)
           WHERE  plan_char_action_trigger_id = l_qpcat_id;
        END IF;

        FOR qpca IN action_cursor(qpcat.plan_char_action_trigger_id) LOOP

            SELECT qa_plan_char_actions_s.nextval
            INTO l_qpca_id
            FROM dual;

            --
            -- These are alert actions, generate new alert action IDs
            --
            IF qpca.action_id IN (10, 11, 12, 13) AND
                qpca.alr_action_id IS NOT NULL THEN

                SELECT
                    alr_actions_s.nextval,
                    alr_action_sets_s.nextval,
                    alr_action_set_members_s.nextval,
                    qa_alr_action_name_s.nextval,
                    qa_alr_action_set_name_s.nextval
                INTO
                    new_action_id,
                    new_action_set_id,
                    new_action_set_member_id,
                    l_action_name_seq,
                    l_action_set_name_seq
                FROM dual;

                --
                -- Some action details are stored in Oracle Alert tables
                -- with alert ID 10177.  Copy the header and recreate new
                -- alert actions for the new plan.
                --
                OPEN alert_cursor(qpca.alr_action_id);
                FETCH alert_cursor INTO alra;
                IF alert_cursor%FOUND THEN

                    new_action_name := 'qa_' || l_action_name_seq;
                    new_action_set_name := 'qa_' || l_action_set_name_seq;

                    INSERT INTO alr_actions (
                        application_id,
                        action_id,
                        name,
                        alert_id,
                        action_type,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        end_date_active,
                        enabled_flag,
                        description,
                        action_level_type,
                        date_last_executed,
                        file_name,
                        argument_string,
                        program_application_id,
                        concurrent_program_id,
                        list_application_id,
                        list_id,
                        to_recipients,
                        cc_recipients,
                        bcc_recipients,
                        print_recipients,
                        printer,
                        subject,
                        reply_to,
                        response_set_id,
                        follow_up_after_days,
                        column_wrap_flag,
                        maximum_summary_message_width,
                        body,
                        version_number)
                    VALUES (
                        alra.application_id,
                        new_action_id,
                        new_action_name,
                        alra.alert_id,
                        alra.action_type,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_user_id,
                        alra.end_date_active,
                        alra.enabled_flag,
                        alra.description,
                        alra.action_level_type,
                        alra.date_last_executed,
                        alra.file_name,
                        alra.argument_string,
                        alra.program_application_id,
                        alra.concurrent_program_id,
                        alra.list_application_id,
                        alra.list_id,
                        alra.to_recipients,
                        alra.cc_recipients,
                        alra.bcc_recipients,
                        alra.print_recipients,
                        alra.printer,
                        alra.subject,
                        alra.reply_to,
                        alra.response_set_id,
                        alra.follow_up_after_days,
                        alra.column_wrap_flag,
                        alra.maximum_summary_message_width,
                        alra.body,
                        alra.version_number
                    );

                    BEGIN
                        SELECT nvl(max(sequence),0) + 1
                        INTO   l_action_set_seq
                        FROM   alr_action_sets
                        WHERE  application_id = 250 AND alert_id = 10177;

                    EXCEPTION
                       WHEN no_data_found THEN
                            l_action_set_seq := 1;
                    END;

                    INSERT INTO alr_action_sets (
                        application_id,
                        action_set_id,
                        name,
                        alert_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        end_date_active,
                        enabled_flag,
                        recipients_view_only_flag,
                        description,
                        suppress_flag,
                        suppress_days,
                        sequence)
                    VALUES (
                        250,
                        new_action_set_id,
                        new_action_set_name,
                        10177,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_user_id,
                        null,
                        'Y',
                        'N',
                        new_action_set_name,
                        'N',
                        null,
                        l_action_set_seq);

                    BEGIN
                        SELECT nvl(max(sequence),0) + 1
                        INTO   l_action_set_members_seq
                        FROM   alr_action_set_members
                        WHERE  application_id = 250 AND
                               alert_id = 10177 AND
                               action_set_id = new_action_set_id;
                    EXCEPTION
                       WHEN no_data_found THEN
                            l_action_set_members_seq := 1;
                    END;

                    INSERT INTO alr_action_set_members (
                        application_id,
                        action_set_member_id,
                        action_set_id,
                        action_id,
                        action_group_id,
                        alert_id,
                        sequence,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        end_date_active,
                        enabled_flag,
                        summary_threshold,
                        abort_flag,
                        error_action_sequence)
                    VALUES (
                        250,
                        new_action_set_member_id,
                        new_action_set_id,
                        new_action_id,
                        null,
                        10177,
                        l_action_set_members_seq,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_user_id,
                        null,
                        'Y',
                        null,
                        'A',
                        null
                    );

                END IF;  -- alert_cursor%FOUND (this is an alert action)

                CLOSE alert_cursor;

            END IF;  -- the action id is 10, 11, 12, 13 (alert actions)

            INSERT INTO qa_plan_char_actions (
                plan_char_action_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                plan_char_action_trigger_id,
                action_id,
                car_name_prefix,
                car_type_id,
                car_owner,
                message,
                status_code,
                alr_action_id,
                alr_action_set_id,
                assigned_char_id,
                assign_type)
            VALUES (
                l_qpca_id,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                p_user_id,
                l_qpcat_id,
                qpca.action_id,
                qpca.car_name_prefix,
                qpca.car_type_id,
                qpca.car_owner,
                qpca.message,
                qpca.status_code,
                decode(qpca.action_id,
                    10, new_action_id,
                    11, new_action_id,
                    12, new_action_id,
                    13, new_action_id,
                    qpca.action_id),
                decode(qpca.action_id,
                    10, new_action_set_id,
                    11, new_action_set_id,
                    12, new_action_set_id,
                    13, new_action_set_id,
                    qpca.action_id),
                qpca.assigned_char_id,
                qpca.assign_type);

            INSERT INTO qa_plan_char_action_outputs (
                plan_char_action_id,
                char_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                token_name)
            SELECT
                l_qpca_id,
                char_id,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                p_user_id,
                token_name
            FROM qa_plan_char_action_outputs
            WHERE plan_char_action_id = qpca.plan_char_action_id;

        END LOOP;  -- action_cursor

    END LOOP;  -- action_trigger_cursor

END copy_plan_element_actions;


PROCEDURE copy_plan_transactions(p_copy_from_plan_id IN NUMBER,
    p_copy_to_plan_id IN NUMBER, p_user_id IN NUMBER) IS

    CURSOR txn_cursor IS
        SELECT
            plan_transaction_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            plan_id,
            transaction_number,
            mandatory_collection_flag,
            background_collection_flag,
            enabled_flag
        FROM qa_plan_transactions
        WHERE plan_id = p_copy_from_plan_id;

    l_plan_transaction_id NUMBER;

    CURSOR txn_trigger_cursor(x NUMBER) IS
        SELECT
            txn_trigger_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            plan_transaction_id,
            collection_trigger_id,
            operator,
            low_value,
            low_value_id,
            high_value,
            high_value_id
        FROM qa_plan_collection_triggers
        WHERE plan_transaction_id = x;

BEGIN

    FOR qpt IN txn_cursor LOOP

        SELECT qa_plan_transactions_s.nextval
        INTO l_plan_transaction_id
        FROM dual;

        INSERT INTO qa_plan_transactions (
            plan_transaction_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            plan_id,
            transaction_number,
            mandatory_collection_flag,
            background_collection_flag,
            enabled_flag)
        VALUES (
            l_plan_transaction_id,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_user_id,
            p_copy_to_plan_id,
            qpt.transaction_number,
            qpt.mandatory_collection_flag,
            qpt.background_collection_flag,
            qpt.enabled_flag);

        FOR qpct IN txn_trigger_cursor(qpt.plan_transaction_id) LOOP

            INSERT INTO qa_plan_collection_triggers (
                txn_trigger_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                plan_transaction_id,
                collection_trigger_id,
                operator,
                low_value,
                low_value_id,
                high_value,
                high_value_id)
            VALUES (
                qa_txn_trigger_ids_s.nextval,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                p_user_id,
                l_plan_transaction_id,
                qpct.collection_trigger_id,
                qpct.operator,
                qpct.low_value,
                qpct.low_value_id,
                qpct.high_value,
                qpct.high_value_id);

        END LOOP;   -- transaction triggers

    END LOOP;       -- transaction

END copy_plan_transactions;


--
-- Private functions for plan and plan element deletions.
--

FUNCTION results_exist(p_plan_Id IN NUMBER, p_element_id IN NUMBER)
    RETURN BOOLEAN IS

    TYPE ref_cursor IS REF CURSOR;
    c ref_cursor;

    l_dummy               NUMBER;
    l_found               BOOLEAN;
    l_result_column_name  qa_plan_chars.result_column_name%TYPE;
    l_sql_statement       VARCHAR2(200);

BEGIN

    l_result_column_name := qa_plan_element_api.get_result_column_name(
        p_plan_id, p_element_id);

    IF l_result_column_name IS NULL THEN
        RETURN true;
    END IF;

    l_sql_statement :=
        'SELECT 1 FROM qa_results WHERE plan_id = :id AND rownum = 1 AND ' ||
            l_result_column_name || ' IS NOT NULL';

    OPEN c FOR l_sql_statement USING p_plan_id;
    FETCH c INTO l_dummy;
    l_found := c%FOUND;
    CLOSE c;

    RETURN l_found;

END results_exist;


FUNCTION results_exist(p_plan_id IN NUMBER) RETURN BOOLEAN IS

    TYPE numType IS REF CURSOR;

    CURSOR c IS
        SELECT 1
        FROM qa_results
        WHERE plan_id = p_plan_id AND rownum = 1;

    l_dummy NUMBER;
    l_found BOOLEAN;

BEGIN

    OPEN c;
    FETCH c INTO l_dummy;
    l_found := c%FOUND;
    CLOSE c;

    RETURN l_found;

END results_exist;


PROCEDURE delete_plan_element_actions(p_plan_id IN NUMBER,
    p_element_id IN NUMBER) IS

    pca_ids number_tab;
    pcat_ids number_tab;

BEGIN

    DELETE FROM qa_plan_char_action_triggers
    WHERE plan_id = p_plan_id AND char_id = p_element_id
    RETURNING plan_char_action_trigger_id BULK COLLECT INTO pcat_ids;

    IF pcat_ids.COUNT = 0 THEN
        RETURN;
    END IF;

    FORALL i IN pcat_ids.FIRST .. pcat_ids.LAST
        DELETE FROM qa_plan_char_actions
        WHERE plan_char_action_trigger_id = pcat_ids(i)
        RETURNING plan_char_action_id BULK COLLECT INTO pca_ids;

    IF pca_ids.COUNT = 0 THEN
        RETURN;
    END IF;

    FORALL i IN pca_ids.FIRST .. pca_ids.LAST
        DELETE FROM qa_plan_char_action_outputs
        WHERE plan_char_action_id = pca_ids(i);
    --
    -- ### Do we need to delete the alert records?
    --

END delete_plan_element_actions;


PROCEDURE delete_plan_element_values(p_plan_id IN NUMBER,
    p_element_id IN NUMBER) IS
BEGIN
    DELETE FROM qa_plan_char_value_lookups
    WHERE plan_id = p_plan_id AND char_id = p_element_id;
END delete_plan_element_values;


PROCEDURE delete_plan_element(p_plan_id IN NUMBER, p_element_id IN NUMBER) IS
    l_result_column qa_plan_chars.result_column_name%TYPE;
BEGIN
    DELETE FROM qa_plan_chars
    WHERE plan_id = p_plan_id AND char_id = p_element_id
    RETURNING result_column_name
    INTO l_result_column;   -- needed for Bug 3926150

    --
    -- Bug 3926150.  Check if the deleted element will disrupt a
    -- function-based index.  If so, add info message to the msg stack.
    -- bso Sat Dec  4 16:08:07 PST 2004
    --
    IF l_result_column LIKE 'CHARACTER%' AND l_result_column <>
        qa_char_indexes_pkg.get_default_result_column(p_element_id) THEN
        disable_index_private(p_element_id);
    END IF;

END delete_plan_element;


PROCEDURE delete_plan_elements(p_plan_id IN NUMBER) IS
    --
    -- Bug 3926150.  Need to warn user if function-based index
    -- is disrupted due to this action.
    --
    CURSOR c IS
        SELECT qpc.char_id
        FROM   qa_plan_chars qpc, qa_char_indexes qci
        WHERE  qpc.plan_id = p_plan_id AND
               qpc.char_id = qci.char_id AND
               qpc.result_column_name <> qci.default_result_column;
BEGIN
    --
    -- Bug 3926150.  Minor revamp of this procedure from a simple
    -- delete of all plan_chars to a disable index and delete.
    -- bso Sun Dec  5 11:54:53 PST 2004
    --
    FOR r IN c LOOP
        disable_index_private(r.char_id);
    END LOOP;

    DELETE FROM qa_plan_chars
    WHERE plan_id = p_plan_id;

END delete_plan_elements;


PROCEDURE delete_plan_values(p_plan_id IN NUMBER) IS
BEGIN
    DELETE FROM qa_plan_char_value_lookups
    WHERE plan_id = p_plan_id;
END delete_plan_values;


PROCEDURE delete_plan_transactions(p_plan_id IN NUMBER) IS

    pt_ids number_tab;

BEGIN

    DELETE FROM qa_plan_transactions
    WHERE plan_id = p_plan_id
    RETURNING plan_transaction_id BULK COLLECT INTO pt_ids;

    IF pt_ids.COUNT = 0 THEN
        RETURN;
    END IF;

    FORALL i IN pt_ids.FIRST .. pt_ids.LAST
        DELETE FROM qa_plan_collection_triggers
        WHERE plan_transaction_id = pt_ids(i);

END delete_plan_transactions;


PROCEDURE delete_plan_actions(p_plan_id IN NUMBER) IS

    pcat_ids number_tab;
    pca_ids  number_tab;

BEGIN

    --
    -- Delete all triggers, collecting their primary keys
    --
    DELETE FROM qa_plan_char_action_triggers
    WHERE plan_id = p_plan_id
    RETURNING plan_char_action_trigger_id BULK COLLECT INTO pcat_ids;

    IF pcat_ids.COUNT = 0 THEN
        RETURN;
    END IF;

    --
    -- Now delete all children actions
    --
    FORALL i IN pcat_ids.FIRST .. pcat_ids.LAST
        DELETE FROM qa_plan_char_actions
        WHERE plan_char_action_trigger_id = pcat_ids(i)
        RETURNING plan_char_action_id BULK COLLECT INTO pca_ids;

    IF pca_ids.COUNT = 0 THEN
        RETURN;
    END IF;

    --
    -- Some actions have action outputs... delete them.
    --
    FORALL i IN pca_ids.FIRST .. pca_ids.LAST
        DELETE FROM qa_plan_char_action_outputs
        WHERE plan_char_action_id = pca_ids(i);

    --
    -- ### Do we need to delete the alert records?
    --
END delete_plan_actions;


PROCEDURE delete_plan_header(p_plan_id IN NUMBER) IS

BEGIN

    DELETE FROM qa_plans
    WHERE plan_id = p_plan_id;

END delete_plan_header;


--
-- This procedure is called to commit a deleted plan.
--
PROCEDURE delete_plan_private(
    p_plan_name VARCHAR2,
    p_commit VARCHAR2,
    p_user_id NUMBER) IS

    l_request_id NUMBER;
BEGIN
    IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;

        --
        -- The dynamic view creator can be used to delete the
        -- redundant plan view once a plan is deleted.
        --
        -- Launch the dynamic view creator only if the user
        -- commits; otherwise, the view generator will fail
        -- because it is run in another database session.
        --
        -- The init is required to get the concurrent program
        -- to run.  The resp_id 20561 is the seeded main Quality
        -- responsibility.  250 is Oracle Quality's application ID.
        --
        fnd_global.apps_initialize(
            user_id      => p_user_id,
            resp_id      => 20561,
            resp_appl_id => 250);

        l_request_id := fnd_request.submit_request(
            application => 'QA',
            program     => 'QLTPVWWB',
            argument1   => NULL,
            argument2   => get_plan_view_name(p_plan_name),
            argument3   => NULL,
            argument4   => NULL,
            argument5   => get_import_view_name(p_plan_name),
            argument6   => 'QA_GLOBAL_RESULTS_V');

        COMMIT;
    END IF;
END delete_plan_private;

-- 12.1 Device Integration Project
-- Procedure to get the device_id, override_flag
-- for the device_name, sensor_alias combination
-- bhsankar Mon Nov 12 05:51:37 PST 2007
PROCEDURE get_device_details (p_device_name IN VARCHAR2,
                              p_sensor_alias IN VARCHAR2,
                              x_device_id OUT NOCOPY NUMBER,
                              x_override_flag OUT NOCOPY NUMBER) IS

    CURSOR c IS
        SELECT device_id, override_flag
        FROM qa_device_info
        WHERE device_name = p_device_name
        AND sensor_alias = p_sensor_alias
        AND enabled_flag = 1;

BEGIN

    OPEN c;
    FETCH c INTO x_device_id, x_override_flag;
    CLOSE c;

END get_device_details;

--
--
--
-- Start of public API functions
--
--
-- 12.1 QWB USability Improvements
-- Added the parameter P_multirow_flag
-- ntungare
--
--
-- bug 9562325
-- Added new parameters to set the DFF attributes
-- on the plan header level
--
PROCEDURE create_collection_plan(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2  := fnd_api.g_false,
    p_validation_level          IN  NUMBER    := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2  := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_plan_type                 IN  VARCHAR2,
    p_description               IN  VARCHAR2  := NULL,
    p_effective_from            IN  DATE      := sysdate,
    p_effective_to              IN  DATE      := NULL,
    p_spec_assignment_type      IN  NUMBER    := qa_plans_pub.g_spec_type_none,
    p_multirow_flag             IN  NUMBER    := 2,
    x_plan_id                   OUT NOCOPY NUMBER,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    p_attribute_category        IN VARCHAR2 := NULL,
    p_attribute1                IN VARCHAR2 := NULL,
    p_attribute2                IN VARCHAR2 := NULL,
    p_attribute3                IN VARCHAR2 := NULL,
    p_attribute4                IN VARCHAR2 := NULL,
    p_attribute5                IN VARCHAR2 := NULL,
    p_attribute6                IN VARCHAR2 := NULL,
    p_attribute7                IN VARCHAR2 := NULL,
    p_attribute8                IN VARCHAR2 := NULL,
    p_attribute9                IN VARCHAR2 := NULL,
    p_attribute10               IN VARCHAR2 := NULL,
    p_attribute11               IN VARCHAR2 := NULL,
    p_attribute12               IN VARCHAR2 := NULL,
    p_attribute13               IN VARCHAR2 := NULL,
    p_attribute14               IN VARCHAR2 := NULL,
    p_attribute15               IN VARCHAR2 := NULL) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'create_plan';
    l_api_version       CONSTANT NUMBER         := 1.0;

    l_org_id            NUMBER;
    l_user_id           NUMBER;
    l_plan_type_code VARCHAR2(30);
    l_plan_name         qa_plans.name%TYPE;
    l_plan_view         qa_plans.view_name%TYPE;
    l_import_view       qa_plans.import_view_name%TYPE;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT create_plan_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;


    -- *** start of logic ***

    --
    -- Bug 3926150.  init the result column array.   -1 indicates
    -- a brand new plan is being created.
    -- bso Fri Dec  3 20:55:05 PST 2004
    --
    init_result_column_array(-1);

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_plan_name := upper(p_plan_name);
    IF (illegal_chars(l_plan_name)) THEN
        fnd_message.set_name('QA', 'QA_NAME_SPECIAL_CHARS');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_org_id := qa_plans_api.get_org_id(p_organization_code);
    IF (l_org_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_ORG_CODE');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF NOT valid_plan_type(p_plan_type) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_PLAN_TYPE');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    ELSE
        l_plan_type_code := get_plan_type_code(p_plan_type);
    END IF;


    -- If the name passed as the plan name already exists then
    -- generate an error.

    IF plan_exists(l_plan_name) > 0 THEN
        fnd_message.set_name('QA', 'QA_PLAN_RECORD_EXISTS');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF (p_effective_to < p_effective_from) THEN
        fnd_message.set_name('QA', 'QA_EFFECTIVE_DATE_RANGE');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_plan_view := get_plan_view_name(l_plan_name);
    l_import_view := get_import_view_name(l_plan_name);

    SELECT qa_plans_s.nextval INTO x_plan_id FROM dual;

    --
    -- bug 9562325
    -- Added new parameters to set the DFF attributes
    -- on the plan header level
    --
    INSERT INTO qa_plans(
        plan_id,
        organization_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        name,
        plan_type_code,
        spec_assignment_type,
        description,
        import_view_name,
        view_name,
        effective_from,
        effective_to,
        multirow_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15)
    VALUES(
        x_plan_id,
        l_org_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_user_id,
        l_plan_name,
        l_plan_type_code,
        p_spec_assignment_type,
        p_description,
        l_import_view,
        l_plan_view,
        p_effective_from,
        p_effective_to,
        p_multirow_flag,
        p_attribute_category ,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15);

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO create_plan_pub;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO create_plan_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO create_plan_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END create_collection_plan;

--
-- bug 9562325
-- Added new parameters to set the DFF attributes
-- on the plan element level
--
PROCEDURE add_plan_element(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_element_name              IN  VARCHAR2,
    p_prompt_sequence           IN  NUMBER      := NULL,
    p_prompt                    IN  VARCHAR2    := g_inherit,
    p_default_value             IN  VARCHAR2    := g_inherit,
    p_enabled_flag              IN  VARCHAR2    := fnd_api.g_true,
    p_mandatory_flag            IN  VARCHAR2    := g_inherit,
    p_displayed_flag            IN  VARCHAR2    := fnd_api.g_true,
    p_read_only_flag            IN  VARCHAR2    := NULL,
    p_ss_poplist_flag           IN  VARCHAR2    := NULL,
    p_information_flag          IN  VARCHAR2    := NULL,
    p_result_column_name        IN  VARCHAR2    := NULL,
    -- 12.1 Device Integration Project
    -- bhsankar Mon Nov 12 05:51:37 PST 2007
    p_device_flag               IN  VARCHAR2    := NULL,
    p_device_name               IN  VARCHAR2    := NULL,
    p_sensor_alias              IN  VARCHAR2    := NULL,
    p_override_flag             IN  VARCHAR2    := NULL,
    -- 12.1 Device Integration Project End.
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2 ,
    p_attribute_category        IN VARCHAR2    := NULL,
    p_attribute1                IN VARCHAR2    := NULL,
    p_attribute2                IN VARCHAR2    := NULL,
    p_attribute3                IN VARCHAR2    := NULL,
    p_attribute4                IN VARCHAR2    := NULL,
    p_attribute5                IN VARCHAR2    := NULL,
    p_attribute6                IN VARCHAR2    := NULL,
    p_attribute7                IN VARCHAR2    := NULL,
    p_attribute8                IN VARCHAR2    := NULL,
    p_attribute9                IN VARCHAR2    := NULL,
    p_attribute10               IN VARCHAR2    := NULL,
    p_attribute11               IN VARCHAR2    := NULL,
    p_attribute12               IN VARCHAR2    := NULL,
    p_attribute13               IN VARCHAR2    := NULL,
    p_attribute14               IN VARCHAR2    := NULL,
    p_attribute15               IN VARCHAR2    := NULL ) IS


    l_api_name          CONSTANT VARCHAR2(30)   := 'add_element';
    l_api_version       CONSTANT NUMBER         := 1.0;

    l_user_id                   NUMBER;
    l_plan_id                   NUMBER;
    l_char_id                   NUMBER;
    l_result_column_name        VARCHAR2(30);

    -- Bug 5406294
    -- Modified the variable size from
    -- 30 to 150 as default values can be
    -- of size upto 150
    -- SHKALYAN 24-JUL-2006
    --
    -- l_default_value             VARCHAR2(30);
    l_default_value             VARCHAR2(150);
    l_enabled_flag              NUMBER;
    l_mandatory_flag            NUMBER;
    l_displayed_flag            NUMBER;
    l_prompt                    VARCHAR2(30);
    l_prompt_sequence           NUMBER;
    l_datatype                  NUMBER;

    -- Tracking Bug : 3104827
    -- Added to include Three new Flags for Collection Plan Element
    -- saugupta Thu Aug 28 08:59:59 PDT 2003
    l_read_only_flag            NUMBER;
    l_ss_poplist_flag           NUMBER;
    l_information_flag          NUMBER;

    -- 12.1 Device Integration Project
    -- bhsankar Mon Nov 12 05:51:37 PST 2007
    l_device_flag               NUMBER;
    l_override_flag             NUMBER;
    x_device_id                 NUMBER;
    x_override_flag             NUMBER;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT add_element_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- *** start of logic ***

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_plan_id := qa_plans_api.plan_id(upper(p_plan_name));
    IF (l_plan_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_PLAN');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_char_id := qa_chars_api.get_element_id(p_element_name);
    IF (l_char_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_ELEMENT');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF element_exists(l_plan_id, l_char_id) THEN
        fnd_message.set_name('QA', 'QA_API_ELEMENT_ALREADY_ADDED');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    --
    -- Bug 3926150.  Since add_plan_element can be called without
    -- first calling create_plan (to add elements to an existing plan,
    -- we will need to initialize the g_result_columns array here
    -- instead of just doing it once in create_plan.  Thus we needed
    -- to cache the plan_id in the init function to avoid re-initializing
    -- every time.
    -- bso Fri Dec  3 21:42:13 PST 2004
    --
    init_result_column_array(l_plan_id);

    l_enabled_flag := convert_flag(p_enabled_flag);
    l_displayed_flag := convert_flag(p_displayed_flag);
    IF p_mandatory_flag = g_inherit THEN
        l_mandatory_flag := qa_chars_api.mandatory_flag(l_char_id);
    ELSE
        l_mandatory_flag := convert_flag(p_mandatory_flag);
    END IF;

    IF p_prompt IS NULL OR p_prompt = g_inherit THEN
        l_prompt := nvl(qa_chars_api.prompt(l_char_id), p_element_name);
    ELSE
        l_prompt := p_prompt;
    END IF;

    IF p_prompt_sequence IS NULL THEN
        l_prompt_sequence := get_next_sequence(l_plan_id);
    ELSE
        IF prompt_sequence_exists(l_plan_id, p_prompt_sequence) THEN
            fnd_message.set_name('QA', 'QA_API_INVALID_PROMPT_SEQUENCE');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;
        l_prompt_sequence := p_prompt_sequence;
    END IF;

    IF p_default_value = g_inherit THEN
        l_default_value := qa_chars_api.default_value(l_char_id);
    ELSE
        l_default_value := p_default_value;
    END IF;
    l_datatype := qa_chars_api.datatype(l_char_id);
    validate_datatype(l_default_value, l_datatype);

    IF p_result_column_name IS NULL THEN
        --
        -- Bug 3926150.  Modify get_next_result_column_name function to
        -- use the new suggest_result_column function.  bso
        --

        --
        -- Strange PL/SQL oddity.  nvl doesn't seem to use lazy evaluation.
        -- that is, suggest_result_column is being called even when
        -- hardcoded_column returns non-NULL.  Need to switch to IF..THEN for
        -- optimal performance.  bso Sat Dec  4 14:23:24 PST 2004
        --
        -- l_result_column_name := nvl(qa_chars_api.hardcoded_column(l_char_id),
        --    suggest_result_column(l_plan_id, l_char_id));

        l_result_column_name := qa_chars_api.hardcoded_column(l_char_id);
        IF l_result_column_name IS NULL THEN
            l_result_column_name := suggest_result_column(l_plan_id, l_char_id);
        END IF;

        IF l_result_column_name IS NULL THEN
            fnd_message.set_name('QA', 'QA_EXCEEDED_COLUMN_COUNT');
            fnd_msg_pub.add();
            raise fnd_api.g_exc_error;
        END IF;
    ELSE
        l_result_column_name := p_result_column_name;
    END IF;

    --
    -- Bug 3926150.
    --
    mark_result_column(l_result_column_name);

    -- added for read only flag
    l_read_only_flag :=  convert_flag(p_read_only_flag);
    l_ss_poplist_flag :=  convert_flag(p_ss_poplist_flag);
    l_information_flag :=  convert_flag(p_information_flag);

    -- 12.1 Device Integration Project Start
    -- bhsankar Mon Nov 12 05:51:37 PST 2007
    l_device_flag   :=  convert_flag(p_device_flag);
    l_override_flag :=  convert_flag(p_override_flag);

    IF FND_PROFILE.VALUE('WIP_MES_OPS_FLAG') <> 1
       AND (p_device_flag IS NOT NULL AND p_override_flag IS NOT NULL OR p_device_name IS NOT NULL OR p_sensor_alias IS NOT NULL) THEN
        fnd_message.set_name('WIP', 'WIP_WS_NO_LICENSE');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF l_device_flag = 2 AND (l_override_flag = 1 OR p_device_name IS NOT NULL OR p_sensor_alias IS NOT NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_DEVICE_FLAG');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF l_device_flag = 1 AND (p_device_name IS NULL OR p_sensor_alias IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_DEVICE_NAME');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF l_device_flag = 1 AND p_device_name IS NOT NULL AND p_sensor_alias IS NOT NULL THEN
       get_device_details(trim(p_device_name), trim(p_sensor_alias), x_device_id, x_override_flag);

       IF (x_device_id IS NULL) THEN
          fnd_message.set_name('QA', 'QA_API_INVALID_DEVICE_DETAILS');
          fnd_msg_pub.add();
          raise fnd_api.g_exc_error;
       END IF;
    END IF;

    IF p_override_flag IS NULL THEN
       l_override_flag := x_override_flag;
    END IF;
    -- 12.1 Device Integration Project End.

    INSERT INTO qa_plan_chars(
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        plan_id,
        char_id,
        prompt_sequence,
        prompt,
        enabled_flag,
        mandatory_flag,
        default_value,
        displayed_flag,
        read_only_flag,
        ss_poplist_flag,
        information_flag,
        result_column_name,
        values_exist_flag,
	-- 12.1 Device Integration Project
	-- bhsankar Mon Nov 12 05:51:37 PST 2007
	device_flag,
	device_id,
	override_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15 )
    VALUES(
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_user_id,
        l_plan_id,
        l_char_id,
        l_prompt_sequence,
        l_prompt,
        l_enabled_flag,
        l_mandatory_flag,
        l_default_value,
        l_displayed_flag,
        l_read_only_flag,
        l_ss_poplist_flag,
        l_information_flag,
        l_result_column_name,
        2,    -- values_exist_flag.  defaulting a 2 to values flag
              -- until user calls add_value
        -- 12.1 Device Integration Project
        -- bhsankar Mon Nov 12 05:51:37 PST 2007
        nvl(l_device_flag, 2),
        x_device_id,
        nvl(l_override_flag, 2),
        p_attribute_category,
        p_attribute1 ,
        p_attribute2 ,
        p_attribute3 ,
        p_attribute4 ,
        p_attribute5 ,
        p_attribute6 ,
        p_attribute7 ,
        p_attribute8 ,
        p_attribute9 ,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15
	);
EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO add_element_pub;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO add_element_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO add_element_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END add_plan_element;


PROCEDURE complete_plan_processing(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'complete_plan_definition';
    l_api_version       CONSTANT NUMBER         := 1.0;

    l_user_id           NUMBER;
    l_plan_id           NUMBER;
    l_plan_name         qa_plans.name%TYPE;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT complete_plan_definition_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- *** start of logic ***

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_plan_name := upper(p_plan_name);
    l_plan_id := qa_plans_api.plan_id(l_plan_name);
    IF (l_plan_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_PLAN');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    complete_plan_private(l_plan_id, l_plan_name, p_commit, l_user_id);

    --
    -- Bug 3926150.  Clean up the result column array.
    -- bso Fri Dec  3 21:54:48 PST 2004
    --
    init_result_column_array(-1);

    fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data
    );

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO complete_plan_definition_pub;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO complete_plan_definition_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO complete_plan_definition_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END complete_plan_processing;


PROCEDURE copy_collection_plan(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_to_plan_name              IN  VARCHAR2,
    p_to_organization_code      IN  VARCHAR2,
    p_copy_actions_flag         IN  VARCHAR2    := fnd_api.g_true,
    p_copy_values_flag          IN  VARCHAR2    := fnd_api.g_true,
    p_copy_transactions_flag    IN  VARCHAR2    := fnd_api.g_true,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_to_plan_id                OUT NOCOPY NUMBER,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'copy_plan';
    l_api_version       CONSTANT NUMBER         := 1.0;

    l_user_id           NUMBER;
    l_from_plan_id      NUMBER;
    l_to_plan_name      qa_plans.name%TYPE;
    l_to_org_id         NUMBER;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT copy_plan_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- *** start of logic ***

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    --
    -- An unusual case for copy plan.  The template plans have
    -- mixed case, but all regular plans have upper case.  So,
    -- try them both.
    --
    l_from_plan_id := qa_plans_api.plan_id(p_plan_name);
    IF (l_from_plan_id IS NULL) THEN
        l_from_plan_id := qa_plans_api.plan_id(upper(p_plan_name));
        IF (l_from_plan_id IS NULL) THEN
            fnd_message.set_name('QA', 'QA_API_INVALID_PLAN');
            fnd_msg_pub.add();
            raise fnd_api.g_exc_error;
        END IF;
    END IF;

    l_to_plan_name := upper(p_to_plan_name);
    IF (illegal_chars(l_to_plan_name)) THEN
        fnd_message.set_name('QA', 'QA_NAME_SPECIAL_CHARS');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_to_org_id := qa_plans_api.get_org_id(p_to_organization_code);
    IF (l_to_org_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_ORG_CODE');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    x_to_plan_id := copy_plan_header(l_from_plan_id, l_to_plan_name,
        l_to_org_id, l_user_id);

    IF (p_copy_values_flag = fnd_api.g_true) THEN
        copy_plan_element_values(l_from_plan_id, x_to_plan_id,
            l_user_id);
    END IF;

    IF (p_copy_actions_flag = fnd_api.g_true) THEN
        copy_plan_element_actions(l_from_plan_id, x_to_plan_id,
            l_user_id);
    END IF;

    IF (p_copy_transactions_flag = fnd_api.g_true) THEN
        copy_plan_transactions(l_from_plan_id, x_to_plan_id,
            l_user_id);
    END IF;

    --
    -- Bug 3926150.  Initialize the result column array before copying
    -- the elements.
    -- bso Fri Dec  3 22:06:09 PST 2004
    --
    init_result_column_array(x_to_plan_id);

    --
    -- Because of a special "where" clause in the above copy_plan...
    -- functions, the copy_plan_elements call must be put at this
    -- position, after all the above calls.
    --
    copy_plan_elements_bulk(l_from_plan_id, x_to_plan_id,
        p_copy_values_flag, l_user_id);

    complete_plan_private(x_to_plan_id, l_to_plan_name, p_commit, l_user_id);

    --
    -- Bug 3926150.  Re-init the result column array afterwards.
    -- bso Fri Dec  3 22:06:09 PST 2004
    --
    init_result_column_array(-1);

    fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data
    );

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO copy_plan_pub;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO copy_plan_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO copy_plan_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END copy_collection_plan;


PROCEDURE delete_plan_element(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_element_name              IN  VARCHAR2,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'delete_plan_element';
    l_api_version       CONSTANT NUMBER         := 1.0;

    l_user_id           NUMBER;
    l_plan_id           NUMBER;
    l_element_id        NUMBER;
    l_org_id            NUMBER;
    l_plan_name         qa_plans.name%TYPE;


BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT delete_plan_element_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- *** start of logic ***

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_plan_name := upper(p_plan_name);
    l_plan_id := qa_plans_api.plan_id(l_plan_name);
    IF (l_plan_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_PLAN');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    l_element_id := qa_chars_api.get_element_id(p_element_name);
    IF (l_element_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_ELEMENT');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    IF NOT element_exists(l_plan_id, l_element_id) THEN
        fnd_message.set_name('QA', 'QA_API_ELEMENT_NOT_IN_PLAN');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    IF results_exist(l_plan_id, l_element_id) THEN
        fnd_message.set_name('QA', 'QA_RESULTS_EXIST_FOR_PLANCHAR');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    delete_plan_element_values(l_plan_id, l_element_id);
    delete_plan_element_actions(l_plan_id, l_element_id);
    delete_plan_element(l_plan_id, l_element_id);

    complete_plan_private(l_plan_id, l_plan_name, p_commit, l_user_id);

    fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data
    );

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO delete_plan_element_pub;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO delete_plan_element_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO delete_plan_element_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END delete_plan_element;


PROCEDURE delete_collection_plan(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'delete_plan';
    l_api_version       CONSTANT NUMBER         := 1.0;

    l_user_id           NUMBER;
    l_plan_id           NUMBER;
    l_org_id            NUMBER;
    l_plan_name         qa_plans.name%TYPE;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT delete_plan_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;


    -- *** start of logic ***

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_plan_name := upper(p_plan_name);
    l_plan_id := qa_plans_api.plan_id(l_plan_name);
    IF l_plan_id IS NULL THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_PLAN');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF results_exist(l_plan_id) THEN
        fnd_message.set_name('QA', 'QA_CANT_DELETE_QPLAN');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    delete_plan_elements(l_plan_id);
    delete_plan_values(l_plan_id);
    delete_plan_transactions(l_plan_id);
    delete_plan_actions(l_plan_id);
    delete_plan_header(l_plan_id);
    delete_plan_private(l_plan_name, p_commit, l_user_id);

    fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data
    );

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO delete_plan_pub;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO delete_plan_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO delete_plan_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END delete_collection_plan;

FUNCTION get_plan_type (p_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR c IS
 SELECT meaning
 FROM   fnd_lookup_values
 WHERE  lookup_type  = 'COLLECTION_PLAN_TYPE'
 AND    lookup_code = p_lookup_code;

ret_val VARCHAR2(80);
BEGIN

   OPEN c;
   FETCH c INTO ret_val;
   IF  c%NOTFOUND THEN
     ret_val := '';
   END IF;

   CLOSE c;
   RETURN ret_val;

END get_plan_type;

END qa_plans_pub;


/
