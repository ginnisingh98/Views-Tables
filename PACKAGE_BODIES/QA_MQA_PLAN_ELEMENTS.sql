--------------------------------------------------------
--  DDL for Package Body QA_MQA_PLAN_ELEMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_MQA_PLAN_ELEMENTS" AS
/* $Header: qacharb.pls 120.2 2006/02/05 18:06:27 bso noship $ */


--
-- Removed DEFAULT clause for GSCC compliance
-- Before removal
--      x_spec_id IN NUMBER DEFAULT -1
-- After removal
--      x_spec_id IN NUMBER
-- rkunchal
--

--
-- changed x_spec_id default to null instead of -1
-- for performance purpose
-- jezheng
-- Wed Nov 27 13:48:52 PST 2002
--

FUNCTION get_elements(x_plan_id IN NUMBER, x_spec_id IN NUMBER)
RETURN PlanElementRefCursor IS
--
-- Get all plan elements info for a particular collection plan.
-- bso Fri May  5 17:29:39 PDT 2000
--
x_ref PlanElementRefCursor;

BEGIN
-- When user doesnt enter any spec, a -1 is passed in..........not a null.

-- rkaza bugs 2753703, 2767550. 01/27/2003. Refer to bug texts for more
-- info.  Previously the where clause used to have 3 outer joins qa_chars,
-- qa_spec_chars, qa_specs and the user entered spec value. It gave
-- incorrect results. For Eg: 1) Either the char is removed if no spec matches. 2) More
-- than one row results for the same char if the char is present in some
-- other spec other than the one specified by user. 3) The char is retained
-- if no spec matches but some spec limits found in qa_spec_chars are also
-- retained when they have to be made null. In order to correct this
-- behavior the qa_spec_chars and qa_specs need to combined into one without
-- an outer join between them based on common_spec. Since we didnt want to
-- create a new view for a bug fix, we have combined them in the from clause
-- itself. Also we put the filtering condition for the user entered spec
-- value in the same.

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level.
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--
-- Modified the query again for Global Specifications Enhancements
--
-- rkunchal
--

-- Modified to include Read Only Flag for Collection Plan Element
-- saugupta


--
-- Bug 3257220
-- Corrected precision problem.  The previous SQL decode
-- for decimal_precision is not correct.  Changed to nvl.
-- bso Thu Nov 13 15:59:14 PST 2003
--

--
-- Bug 4958730.  SQL Repository fix for SQL ID 15007756
-- Rewrite SQL by using a more streamlined get_spec_limit
-- PL/SQL function.   Also reformatted.
-- bso Sun Feb  5 17:48:31 PST 2006
--
OPEN x_ref FOR

    SELECT
        qc.char_id,
        qc.name,
        qp.prompt,
        qc.data_entry_hint,
        qc.datatype,
        qc.display_length,
        nvl(qp.decimal_precision,
            nvl(qc.decimal_precision, 12)) decimal_precision,
        qp.default_value,
        decode(qp.values_exist_flag,
            1, 1,
            decode(qc.sql_validation_string, null, 2, 1)) lov_flag,
        qp.mandatory_flag,
        qp.displayed_flag,
        qp.read_only_flag,
        qa_mqa_plan_elements.get_spec_limit(
            qc.char_id,
            qc.datatype,
            qscqs.char_id,
            qc.uom_code,
            qp.uom_code,
            qscqs.uom_code,
            qc.decimal_precision,
            qp.decimal_precision,
            qc.target_value,
            qscqs.target_value) target_value,
        qa_mqa_plan_elements.get_spec_limit(
            qc.char_id,
            qc.datatype,
            qscqs.char_id,
            qc.uom_code,
            qp.uom_code,
            qscqs.uom_code,
            qc.decimal_precision,
            qp.decimal_precision,
            qc.upper_spec_limit,
            qscqs.upper_spec_limit) upper_spec_limit,
        qa_mqa_plan_elements.get_spec_limit(
            qc.char_id,
            qc.datatype,
            qscqs.char_id,
            qc.uom_code,
            qp.uom_code,
            qscqs.uom_code,
            qc.decimal_precision,
            qp.decimal_precision,
            qc.lower_spec_limit,
            qscqs.lower_spec_limit) lower_spec_limit,
        qa_mqa_plan_elements.get_spec_limit(
            qc.char_id,
            qc.datatype,
            qscqs.char_id,
            qc.uom_code,
            qp.uom_code,
            qscqs.uom_code,
            qc.decimal_precision,
            qp.decimal_precision,
            qc.upper_reasonable_limit,
            qscqs.upper_reasonable_limit) upper_reasonable_limit,
        qa_mqa_plan_elements.get_spec_limit(
            qc.char_id,
            qc.datatype,
            qscqs.char_id,
            qc.uom_code,
            qp.uom_code,
            qscqs.uom_code,
            qc.decimal_precision,
            qp.decimal_precision,
            qc.lower_reasonable_limit,
            qscqs.lower_reasonable_limit) lower_reasonable_limit,
        qa_mqa_plan_elements.get_spec_limit(
            qc.char_id,
            qc.datatype,
            qscqs.char_id,
            qc.uom_code,
            qp.uom_code,
            qscqs.uom_code,
            qc.decimal_precision,
            qp.decimal_precision,
            qc.upper_user_defined_limit,
            qscqs.upper_user_defined_limit) upper_user_defined_limit,
        qa_mqa_plan_elements.get_spec_limit(
            qc.char_id,
            qc.datatype,
            qscqs.char_id,
            qc.uom_code,
            qp.uom_code,
            qscqs.uom_code,
            qc.decimal_precision,
            qp.decimal_precision,
            qc.lower_user_defined_limit,
            qscqs.lower_user_defined_limit) lower_user_defined_limit
    FROM
        qa_chars qc,
        qa_plan_chars qp,
       (SELECT
            qsc.CHAR_ID,
            qsc.ENABLED_FLAG,
            qsc.TARGET_VALUE,
            qsc.UPPER_SPEC_LIMIT,
            qsc.LOWER_SPEC_LIMIT,
            qsc.UPPER_REASONABLE_LIMIT,
            qsc.LOWER_REASONABLE_LIMIT,
            qsc.UPPER_USER_DEFINED_LIMIT,
            qsc.LOWER_USER_DEFINED_LIMIT,
            qsc.UOM_CODE
        FROM
            qa_spec_chars qsc,
            qa_specs qs
        WHERE
            qsc.spec_id = qs.common_spec_id AND
            qs.spec_id = x_spec_id) QscQs
    WHERE
        qp.plan_id = x_plan_id AND
        qp.enabled_flag = 1 AND
        qc.char_id = qp.char_id AND
        qc.char_id = QscQs.char_id (+)
    ORDER BY qp.prompt_sequence;

RETURN x_ref;

END get_elements;


FUNCTION no_action_triggers(x_plan_id IN NUMBER, x_char_id IN NUMBER)
    RETURN BOOLEAN IS
--
-- Simple function to decide whether there will be some action triggers.
--
    result BOOLEAN;
    dummy NUMBER;
    CURSOR c IS
        SELECT plan_char_action_trigger_id
        FROM   qa_plan_char_action_triggers
        WHERE  plan_id = x_plan_id AND
               char_id = x_char_id;
BEGIN
    OPEN c;
    FETCH c INTO dummy;
    result := c%NOTFOUND;
    CLOSE c;

    RETURN result;
END no_action_triggers;


FUNCTION get_online_action_triggers(x_plan_id IN NUMBER, x_char_id IN NUMBER)
    RETURN ActionTriggerRefCursor IS
--
-- Return a ref cursor that loops through all online (aka immediate)
-- action triggers of a plan element.
-- bso Fri May  5 17:29:30 PDT 2000
--
    x_ref ActionTriggerRefCursor;
BEGIN
    --
    -- Since this SQL is extremely complicated.  We may as well do a
    -- simple existence query to find out if we need to really do it.
    -- Return a no-row-selected query if there is nothing to be found.
    --
    IF no_action_triggers(x_plan_id, x_char_id) THEN
        OPEN x_ref FOR
            SELECT
                null plan_char_action_trigger_id,
                null plan_char_action_id,
                null trigger_sequence,
                null operator,
                null low_value_lookup,
                null high_value_lookup,
                null low_value_other,
                null high_value_other,
                null action_id,
                null message,
                null assigned_char_id,
                null assign_type,
                null online_flag
            FROM  dual
            WHERE 1 = 2;
        RETURN x_ref;
    END IF;

    OPEN x_ref FOR
    --
    -- The first select selects all triggers with online actions eliminating
    -- all deferred actions.  Unfortunately, this also eliminates those
    -- triggers that have no online actions, which we still need, hence the
    -- union all statement.  May Hari Seldon help me find a more elegant
    -- solution through the force of psychohistory.  (This SQL actually has
    -- a pretty good performance.  All accesses are done by indices.)
    -- bso
    --
        SELECT
            qpcat.plan_char_action_trigger_id,
            qpca.plan_char_action_id,
            qpcat.trigger_sequence,
            qpcat.operator,
            qpcat.low_value_lookup,
            qpcat.high_value_lookup,
            qpcat.low_value_other,
            qpcat.high_value_other,
            qpca.action_id,
            qpca.message,
            qpca.assigned_char_id,
            qpca.assign_type,
            1 online_flag
        FROM
            qa_plan_char_action_triggers qpcat,
            qa_plan_char_actions qpca,
            qa_actions qa
        WHERE
            qpcat.plan_id = x_plan_id AND
            qpcat.char_id = x_char_id AND
            qpcat.plan_char_action_trigger_id =
                qpca.plan_char_action_trigger_id AND
            qpca.action_id = qa.action_id AND
            qa.online_flag = 1
        UNION ALL
    --
    -- This select gets all the triggers with either no actions or only
    -- deferred actions.
    --
        SELECT
            qpcat.plan_char_action_trigger_id,
            -1,                      -- no action in this part
            qpcat.trigger_sequence,
            qpcat.operator,
            qpcat.low_value_lookup,
            qpcat.high_value_lookup,
            qpcat.low_value_other,
            qpcat.high_value_other,
            -1 action_id,
            null,                     -- message, null in this case
            -1,                       -- action details, -1 in this case
            null,                     -- action details, null in this case
            1                         -- online flag, always 1 in this case
        FROM
            qa_plan_char_action_triggers qpcat
        WHERE
            qpcat.plan_id = x_plan_id AND
            qpcat.char_id = x_char_id AND
            NOT EXISTS
            (SELECT
                 1
             FROM
                 qa_plan_char_actions qpca,
                 qa_actions qa
             WHERE
                 qpca.plan_char_action_trigger_id =
                     qpcat.plan_char_action_trigger_id AND
                 qpca.action_id = qa.action_id AND
                 qa.online_flag = 1)
        ORDER BY 3, 1;
        --
        -- A PL/SQL bug prevents me from using the following.  It
        -- complains that plan_char_action_trigger_id appears in more
        -- than one table and should use qualifier.  This is allowed
        -- in direct SQL/Plus.  Since order by always refers to the
        -- output column position, there should not be any need for
        -- explicit qualifiers.  Using integer column position.
        -- bso
        --
        -- order by trigger_sequence, plan_char_action_trigger_id;
    RETURN x_ref;
END get_online_action_triggers;


FUNCTION get_action_tokens(x_plan_char_action_id IN NUMBER)
    RETURN ActionTokenRefCursor IS
--
-- Return a ref cursor that loops through all action tokens
-- given an action of an action trigger.
-- bso Fri May  5 17:29:57 PDT 2000
--
    x_ref ActionTokenRefCursor;
BEGIN
    OPEN x_ref FOR
        SELECT token_name, char_id
        FROM   qa_plan_char_action_outputs
        WHERE  plan_char_action_id = x_plan_char_action_id;
    RETURN x_ref;
END get_action_tokens;


FUNCTION get_plan_name(x_plan_id IN NUMBER) RETURN VARCHAR2 IS
--
-- Return a plan name given a plan ID.
--
    x_name qa_plans.name%TYPE;
BEGIN
    SELECT name INTO x_name
    FROM   qa_plans
    WHERE  plan_id = x_plan_id;

    RETURN x_name;
END get_plan_name;


PROCEDURE get_spec_type (p_plan_id IN NUMBER, x_spec_type OUT NOCOPY VARCHAR2,
    x_spec_type_name OUT NOCOPY VARCHAR2) IS

--
-- Return a spec type and spec type name given a plan ID.
--
    x_type qa_plans.spec_assignment_type%TYPE;
    x_type_name VARCHAR2(30);

BEGIN
    SELECT spec_assignment_type INTO x_type
    FROM   qa_plans
    WHERE  plan_id = p_plan_id;

    SELECT meaning into x_spec_type_name
    FROM mfg_lookups
    WHERE lookup_type = 'QA_SPEC_TYPE'
    AND   lookup_code = x_type;

    x_spec_type :=  to_char(x_type);

END get_spec_type;

--
-- For Specifications Enhancements
-- rkunchal
--

FUNCTION get_spec_limit(plan_char_uom VARCHAR2, spec_char_uom VARCHAR2,
                        decimal_precision NUMBER, value NUMBER)
RETURN NUMBER IS
  return_val  NUMBER;
BEGIN

  IF value IS NULL THEN
    RETURN NULL;
  END IF;

  IF plan_char_uom <> spec_char_uom THEN
    return_val := INV_CONVERT.INV_UM_CONVERT(null,
                                             decimal_precision,
                                             value,
                                             spec_char_uom,
                                             plan_char_uom,
                                             null,
                                             null);
  ELSE
    return_val := value;
  END IF;

  RETURN return_val;
END get_spec_limit;

-- Bug 3288391. The function added for returning specification limits for
-- date and datetime elements
-- saugupta Thu, 11 Dec 2003 22:07:25 -0800 PDT
FUNCTION get_spec_limit(plan_char_uom VARCHAR2, spec_char_uom VARCHAR2,
                        decimal_precision NUMBER, x_value VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
  RETURN x_value;
END get_spec_limit;


    --
    -- Bug 4958730.  SQL Repository fix for SQL ID 15007756
    -- requires a rewrite of the above "get_spec_limit" function.
    -- We will take in raw IDs and data from the SQL (see
    -- java/util/ContextElementTable.java) and perform the
    -- decode and nvl here instead.
    --
    -- bso Sun Feb  5 17:30:58 PST 2006
    --
    FUNCTION get_spec_limit(
        p_char_id NUMBER,
        p_datatype NUMBER,
        p_spec_char_id NUMBER,
        p_qc_uom_code VARCHAR2,
        p_qpc_uom_code VARCHAR2,
        p_qsc_uom_code VARCHAR2,
        p_qc_dec_prec NUMBER,
        p_qpc_dec_prec NUMBER,
        p_qc_spec_limit VARCHAR2,
        p_qsc_spec_limit VARCHAR2) RETURN VARCHAR2 IS

        l_spec_limit qa_chars.target_value%TYPE;

    BEGIN
        IF p_spec_char_id IS NULL THEN
            l_spec_limit := p_qc_spec_limit;
        ELSE
            l_spec_limit := p_qsc_spec_limit;
        END IF;

        IF p_datatype <> qa_ss_const.number_datatype THEN
        --
        -- No UOM Conversion needed.  Simply return the spec limit.
        --
            RETURN l_spec_limit;
        END IF;

        --
        -- Perform UOM Conversion by calling the original function.
        --
        RETURN get_spec_limit(
            plan_char_uom => nvl(p_qpc_uom_code, p_qc_uom_code),
            spec_char_uom => nvl(p_qsc_uom_code, p_qc_uom_code),
            decimal_precision => nvl(p_qpc_dec_prec, nvl(p_qc_dec_prec, 12)),
            value => to_number(l_spec_limit));

    END get_spec_limit;


END qa_mqa_plan_elements;

/
