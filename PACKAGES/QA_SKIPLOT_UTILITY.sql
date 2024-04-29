--------------------------------------------------------
--  DDL for Package QA_SKIPLOT_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SKIPLOT_UTILITY" AUTHID CURRENT_USER AS
/* $Header: qaslutls.pls 120.1 2006/02/15 08:37:07 ntungare noship $ */

    --
    -- constants defined to distinguish receiving inspection
    -- from wip inspection
    --
    RCV             CONSTANT NUMBER := 1;
    WIP             CONSTANT NUMBER := 2;

    ADJACENT_DATE_CHECK     CONSTANT NUMBER := 1;
    DATE_SPAN_CHECK   CONSTANT NUMBER := 2;

    -- Check in as Bug 2917141
    -- GSCC problem ... removed g_miss_char
    -- skiplot_avail VARCHAR2(1) := fnd_api.g_miss_char;

    skiplot_avail VARCHAR2(1);

    TYPE refCursorTyp IS REF CURSOR;

    TYPE skiplot_plan IS RECORD
        (plan_id NUMBER,
         alternate_flag VARCHAR2(1));

    TYPE planList IS TABLE OF skiplot_plan
    INDEX BY BINARY_INTEGER;

    TYPE plan_state_rec IS RECORD
        (plan_id number,
         process_plan_id number,
         process_id number,
         adjacent_days number,
         criteria_id number,
         alternate_plan_id number,
         current_rule number,
         total_round number,
         day_span number,
         current_freq_num number,
         current_freq_denom number,
         current_round number,
         current_lot number,
         lot_accepted number,
         rule_start_lot_id number,
         rule_start_date date,
         last_receipt_lot_id number,
         last_receipt_date date);

    TYPE planStateTable IS TABLE OF plan_state_rec
    INDEX BY BINARY_INTEGER;

    --
    -- The function calls skiplot_control, qa_installation
    -- and skiplot_setup to check whether skiplot functionality
    -- is avalilable
    --
    FUNCTION CHECK_SKIPLOT_AVAILABILITY (
    p_txn IN NUMBER,
    p_organization_id IN NUMBER)
    RETURN VARCHAR2;

    --
    -- The function checks whether skip lot control
    -- is set for an inventory organization.
    --
    FUNCTION SKIPLOT_CONTROL
    (p_organization_id IN NUMBER)
    RETURN VARCHAR2;

    --
    -- The function returns whether skip lot criteria
    -- has been set for the specified organization
    --
    FUNCTION SKIPLOT_SETUP (
    p_txn IN NUMBER,
    p_organization_id IN NUMBER)
    RETURN VARCHAR2;

    --
    -- The function returns process_plan_id
    --
    FUNCTION GET_PROCESS_PLAN_ID (
    p_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_txn IN NUMBER)RETURN NUMBER;


    --
    -- The procedure gets the frequency based on the rule
    -- sequence given
    --
    PROCEDURE CHECK_RULE_FREQUENCY (
    p_process_plan_id IN NUMBER,
    p_rule_seq IN NUMBER,
    p_freq_num OUT NOCOPY NUMBER,
    p_freq_denom OUT NOCOPY NUMBER);

    --
    -- The procedure instantiates the pl/sql table
    -- plan_states.
    -- if p_process_plan_id is not provided,
    -- p_plan_id and p_process_id must be provided
    -- so that process_plan_id can be derived
    --
    PROCEDURE FETCH_PLAN_STATE(
    p_plan_id IN NUMBER DEFAULT NULL,
    p_process_plan_id IN NUMBER DEFAULT NULL,
    p_process_id IN NUMBER DEFAULT NULL,
    p_criteria_id IN NUMBER,
    p_txn IN NUMBER DEFAULT NULL,
    p_plan_state OUT nocopy plan_state_rec);

    --
    -- The procedure initialize the
    -- qa_skiplot_plan_states table.
    --
    PROCEDURE INIT_PLAN_STATE(
    p_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_txn IN NUMBER,
    p_lot_id IN NUMBER DEFAULT NULL,
    p_process_plan_id OUT NOCOPY NUMBER);

    --
    -- The procedure initialize the
    -- qa_skiplot_plan_states table.
    --
    PROCEDURE INIT_PLAN_STATE(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_txn IN NUMBER,
    p_lot_id IN NUMBER DEFAULT NULL);

    --
    -- The procedure initialize all the
    -- process plan/criteria in the
    -- qa_skiplot_plan_states table
    --
    PROCEDURE INIT_PLAN_STATES(
    p_process_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_txn IN NUMBER);

    --
    -- The procedure initializes the plan states
    -- for all the processes and associated processes plans
    -- for the specified criteria
    --
    PROCEDURE INIT_PLAN_STATES(
    p_criteria_id IN NUMBER);

    --
    -- Bug 5037121
    -- New procedure to reset the last receipt date
    -- to the sysdate when  the skip process is
    -- interrupted due to the day span being exceeded.
    -- ntungare Wed Feb 15 07:23:23 PST 2006
    --
    PROCEDURE RESET_LAST_RECEIPT_DATE(
    p_criteria_id     IN NUMBER,
    p_process_plan_id IN NUMBER) ;

    --
    -- The procedure initializes the plan states
    -- for all the process plans associated with
    -- the specified process, no matter which criteria
    -- this process is linked to.
    --
    PROCEDURE RESET_PLAN_STATES(
    p_process_id IN NUMBER);

    --
    -- The function checks whether the inspection
    -- round is finished
    --
    FUNCTION INSP_ROUND_FINISHED(
    p_plan_state IN plan_state_rec) RETURN VARCHAR2;

    --
    -- The function check whether the inspection
    -- rule is finished
    --
    FUNCTION INSP_RULE_FINISHED(
    p_plan_state IN plan_state_rec)RETURN VARCHAR2;

    --
    -- The function gets the next inspection rule
    -- and returns -1 if no next rule found
    --
    FUNCTION GET_NEXT_INSP_RULE(
    p_plan_state in plan_state_rec)RETURN NUMBER;

    --
    -- The function checks whether there are more
    -- inspection rounds available
    --
    FUNCTION MORE_ROUNDS (
    p_plan_state IN plan_state_rec) RETURN VARCHAR2;

    --
    -- The function checks whether enough lots
    -- are inspected and accepted in the current
    -- round
    --
    FUNCTION ENOUGH_LOT_ACCEPTED(
    p_plan_state IN plan_state_rec) RETURN VARCHAR2;

    --
    -- The function checks whether the receipt
    -- date satisfy the skip lot receipt date
    -- restriction
    --
    FUNCTION DATE_REASONABLE(
    p_receipt_date IN DATE DEFAULT NULL,
    p_check_mode IN NUMBER,
    p_plan_state plan_state_rec)RETURN VARCHAR2;

    -- The procedure updates insp_stage column
    -- in criteria table
    --
    PROCEDURE UPDATE_INSP_STAGE (
    p_txn IN NUMBER,
    p_stage IN VARCHAR2,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER);

    --
    -- The procedure updates plan state table
    --
    PROCEDURE UPDATE_PLAN_STATE(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_next_rule IN NUMBER DEFAULT NULL,
    p_next_round IN NUMBER DEFAULT NULL,
    p_next_lot IN NUMBER DEFAULT NULL,
    p_rule_start_lotid IN NUMBER DEFAULT NULL,
    p_last_receipt_lot_id IN NUMBER DEFAULT NULL,
    p_lot_accepted IN NUMBER DEFAULT NULL,
    p_txn IN NUMBER DEFAULT NULL);


    --
    -- The procedure launches notification workflow to
    -- notify specified user of inspection frequency changes.
    --
    PROCEDURE LAUNCH_WORKFLOW (
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_old_freq_num IN NUMBER,
    p_old_freq_denom IN NUMBER,
    p_new_freq_num IN NUMBER,
    p_new_freq_denom IN NUMBER,
    p_txn IN NUMBER);

    --
    -- The procedure updates plan state history table
    --
    PROCEDURE UPDATE_STATE_HISTORY(
    p_old_plan_state IN plan_state_rec,
    p_next_rule IN NUMBER,
    p_txn IN NUMBER DEFAULT NULL);

    --
    -- The procedure updates plan state history table
    --
    PROCEDURE UPDATE_STATE_HISTORY(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_old_rule IN NUMBER,
    p_new_rule IN NUMBER,
    p_txn IN NUMBER);

    --
    -- The procedure updates plan state history table
    --
    PROCEDURE UPDATE_STATE_HISTORY(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_old_freq_num IN NUMBER,
    p_old_freq_denom IN NUMBER,
    p_new_freq_num IN NUMBER,
    p_new_freq_denom IN NUMBER,
    p_txn IN NUMBER);

    --
    -- The procedure has autonomous transaction pragma.
    -- It inserts error message into error log table
    --
    PROCEDURE INSERT_ERROR_LOG (
    p_module_name IN VARCHAR2,
    p_error_message IN VARCHAR2 DEFAULT NULL,
    p_comments IN VARCHAR2 DEFAULT NULL);

    FUNCTION GET_LOT_ID RETURN NUMBER;

    --
    -- The function returns fnd_api.g_true when
    -- next rule have frequency numerator 0,
    -- fnd_api.g_false otherwise
    --
    FUNCTION INSPECT_ZERO (
    p_plan_state IN plan_state_rec,
    p_txn IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

    FUNCTION GET_PROCESS_ID (
    p_process_plan_id IN NUMBER) RETURN NUMBER;

END QA_SKIPLOT_UTILITY;


 

/
