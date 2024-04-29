--------------------------------------------------------
--  DDL for Package QA_MQA_PLAN_ELEMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_MQA_PLAN_ELEMENTS" AUTHID CURRENT_USER AS
/* $Header: qachars.pls 120.2 2006/02/05 18:06:53 bso noship $ */


    --
    -- Attributes of a plan element.
    --
    -- Modified to include Read Only Flag for Collection Plan Elements
    -- saugupta
    TYPE PlanElementRecord IS RECORD (
        char_id             NUMBER,
        name                qa_chars.name%TYPE,
        prompt              qa_plan_chars.prompt%TYPE,
        data_entry_hint     qa_chars.data_entry_hint%TYPE,
        datatype            NUMBER,
        display_length      NUMBER,
        decimal_precision   NUMBER,
        default_value       qa_plan_chars.default_value%TYPE,
        lov_flag            NUMBER,
        mandatory_flag      NUMBER,
        displayed_flag      NUMBER,
        read_only_flag      NUMBER,
        target_value             qa_chars.target_value%TYPE,
        upper_spec_limit         qa_chars.upper_spec_limit%TYPE,
        lower_spec_limit         qa_chars.lower_spec_limit%TYPE,
        upper_reasonable_limit   qa_chars.upper_reasonable_limit%TYPE,
        lower_reasonable_limit   qa_chars.lower_reasonable_limit%TYPE,
        upper_user_defined_limit qa_chars.upper_user_defined_limit%TYPE,
        lower_user_defined_limit qa_chars.lower_user_defined_limit%TYPE
    );


    TYPE PlanElementRefCursor IS REF CURSOR RETURN PlanElementRecord;


    --
    -- Attributes of a flattened Action Trigger for a given plan element.
    --
    TYPE ActionTriggerRecord IS RECORD (
        plan_char_action_trigger_id NUMBER,
        plan_char_action_id NUMBER,
        trigger_sequence    NUMBER,
        operator            NUMBER,
        low_value_lookup    qa_plan_char_action_triggers.low_value_lookup%TYPE,
        high_value_lookup   qa_plan_char_action_triggers.high_value_lookup%TYPE,
        low_value_other     qa_plan_char_action_triggers.low_value_other%TYPE,
        high_value_other    qa_plan_char_action_triggers.high_value_other%TYPE,
        action_id           NUMBER,
        message             qa_plan_char_actions.message%TYPE,
        assigned_char_id    NUMBER,
        assign_type         qa_plan_char_actions.assign_type%TYPE,
        online_flag         NUMBER
    );


    TYPE ActionTriggerRefCursor IS REF CURSOR RETURN ActionTriggerRecord;


    --
    -- Attributes of an action token
    --
    TYPE ActionTokenRecord IS RECORD (
        token_name  qa_plan_char_action_outputs.token_name%TYPE,
        char_id     NUMBER
    );


    TYPE ActionTokenRefCursor IS REF CURSOR RETURN ActionTokenRecord;


    --
    -- Return a ref cursor that loops through all plan
    -- elements.
    --
    FUNCTION get_elements(
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER DEFAULT NULL) RETURN PlanElementRefCursor;


    --
    -- Return a ref cursor that loops through all online (aka immediate)
    -- action triggers of a plan element.
    --
    FUNCTION get_online_action_triggers(x_plan_id IN NUMBER, x_char_id IN NUMBER)
        RETURN ActionTriggerRefCursor;


    --
    -- Return a ref cursor that loops through all action tokens
    -- given an action of an action trigger.
    --
    FUNCTION get_action_tokens(x_plan_char_action_id IN NUMBER)
        RETURN ActionTokenRefCursor;


    --
    -- Return a plan name given a plan ID.
    --
    FUNCTION get_plan_name(x_plan_id IN NUMBER) RETURN VARCHAR2;


    --
    -- Return a spec type given a plan ID.
    --
    PROCEDURE get_spec_type (p_plan_id IN NUMBER, x_spec_type OUT NOCOPY VARCHAR2,
        x_spec_type_name OUT NOCOPY VARCHAR2);



/*
    Excluded for performance reasons.

    --
    -- Return 1 if there should be an lov for the given plan element.
    -- Return 2 if not.
    --
    FUNCTION has_lov(x_plan_id IN NUMBER, x_char_id IN NUMBER)
        RETURN NUMBER;
*/

--
-- For Specification Enhancements
-- rkunchal
--

FUNCTION get_spec_limit(plan_char_uom VARCHAR2, spec_char_uom VARCHAR2,
                        decimal_precision NUMBER, value NUMBER)
RETURN NUMBER;

-- Bug 3288391. The function added for returning specification limits for
-- date and datetime elements
-- saugupta Thu, 11 Dec 2003 22:06:30 -0800 PDT
FUNCTION get_spec_limit(plan_char_uom VARCHAR2, spec_char_uom VARCHAR2,
                        decimal_precision NUMBER, x_value VARCHAR2)
RETURN VARCHAR2;

    --
    -- Bug 4958730.  SQL Repository fix for SQL ID 15007756
    -- requires a rewrite of the above "get_spec_limit" function.
    -- bso Sun Feb  5 17:46:13 PST 2006
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
        p_qsc_spec_limit VARCHAR2)
    RETURN VARCHAR2;

END qa_mqa_plan_elements;

 

/
