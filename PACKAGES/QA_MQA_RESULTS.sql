--------------------------------------------------------
--  DDL for Package QA_MQA_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_MQA_RESULTS" AUTHID CURRENT_USER AS
/* $Header: qaress.pls 120.1 2005/10/02 01:22:11 bso noship $ */

    --
    -- Post a result to the database.  This is a wrapper to the QA API
    -- qa_results_api.insert_row.  Do not perform commit.  Most of the
    -- parameters are self explanatory.
    --
    -- x_result is a flattened @-separated list of <char_id>=<value>.
    -- x_result1 and x_result2 are not used but can be reserved for
    --           expansion if one VARCHAR2 is not enough.
    -- x_enabled maps to the status flag in qa_results
    --           (i.e., null or 2 for enabled, 1 for disabled).
    -- x_committed is whether to commit the row afterwards,
    --           1 = yes, others = no.
    -- x_messages is an @-separated string of error messages if there
    --           is any error.
    --
    -- Return 0 if OK
    -- Return -1 if error.
    --
    FUNCTION post_result(
        x_occurrence OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_messages OUT NOCOPY VARCHAR2,
        p_txn_header_id IN NUMBER DEFAULT NULL) -- Currently Unused
        RETURN INTEGER;

    -- anagarwa Thu Dec 19 15:43:27 PST 2002
    -- Bug 2701777
    -- This function is defined to insert records into qa_results without
    -- any validations. The change is done for History plans.
    FUNCTION post_result_with_no_validation(
        x_occurrence OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_messages OUT NOCOPY VARCHAR2,
        p_txn_header_id IN NUMBER DEFAULT NULL)
        RETURN INTEGER;


    --
    -- The overloaded method is used for transaction only
    --
    FUNCTION post_result(
        x_occurrence OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2,
        p_txn_header_id IN NUMBER DEFAULT NULL) -- Currently Unused
        RETURN INTEGER;

    --
    -- Delete a result.  Do not perform commit.
    --
    PROCEDURE delete_result(
        x_plan_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_occurrence IN NUMBER);

    --
    -- Batch delete a set of results (supply occurrences in
    -- comma-separated list.)  Do not perform commit.
    --
    PROCEDURE delete_results(
        x_plan_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_occurrences IN VARCHAR2);

    --
    -- Perform database commit.  Do not use in transaction integration,
    -- otherwise we will be committing the parent's data without their
    -- knowing!
    --
    PROCEDURE commit_results;


END qa_mqa_results;

 

/
