--------------------------------------------------------
--  DDL for Package Body QA_MQA_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_MQA_RESULTS" AS
/* $Header: qaresb.pls 120.2 2006/08/22 11:46:14 ntungare noship $ */


    -- R12 Project MOAC 4637896
    --
    -- Moved several validation related functions and procedures to
    -- qa_validation_api where they belong so that they can be
    -- shared by other packages such as qa_ss_results.  These are:
    --
    -- parse_id
    -- parse_value
    -- result_to_array (2 variants)
    -- set_validation_flag (2 variants)
    --

    -- Bug 2701777
    -- This function sets all elements as valid and action fired and is used
    -- to insert records into qa_results without any validations.
    -- The change is done for History plans.

    PROCEDURE set_validation_flag_valid(
        elements IN OUT NOCOPY qa_validation_api.ElementsArray) IS
        i INTEGER := elements.FIRST;
    BEGIN
        WHILE i <= elements.LAST LOOP
            elements(i).validation_flag := qa_validation_api.valid_element ||
                                           qa_validation_api.action_fired;

            i := elements.NEXT(i);
        END LOOP;
    END set_validation_flag_valid;


    --
    -- Post a result to the database.  This is a wrapper to the QA API
    -- qa_results_api.insert_row
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
        p_txn_header_id IN NUMBER DEFAULT NULL)
    RETURN INTEGER IS

    BEGIN
        --
        -- R12 Project MOAC 4637896
        -- There is no difference between this method and
        -- qa_ss_results.nontxn_post_result
        -- The param p_txn_header_id is never used.
        -- bso Sat Oct  1 18:05:47 PDT 2005
        --

        RETURN qa_ss_results.nontxn_post_result(
            x_occurrence => x_occurrence,
            x_org_id => x_org_id,
            x_plan_id => x_plan_id,
            x_spec_id => x_spec_id,
            x_collection_id => x_collection_id,
            x_result => x_result,
            x_result1 => x_result1,
            x_result2 => x_result2,
            x_enabled => x_enabled,
            x_committed => x_committed,
            x_messages => x_messages);

    END post_result;

    -- anagarwa Thu Dec 19 15:43:27 PST 2002
    -- Bug 2701777
    -- This function is defined to insert records into qa_results without
    -- any validations. The change is done for History plans.
    -- It is an exact copy of post_result above with one difference:
    -- It calls set_validation_flag_valid instead of set_validation_flag.
    -- set_validation_flag_valid marks all elements as valid elements with
    -- actions already fired.

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
    RETURN INTEGER IS
        elements qa_validation_api.ElementsArray;
        error_array qa_validation_api.ErrorArray;
        message_array qa_validation_api.MessageArray;
        return_status VARCHAR2(1);
        action_result VARCHAR2(1);
        msg_count NUMBER;
        msg_data VARCHAR2(2000);
        y_spec_id NUMBER;
        y_collection_id NUMBER;
        y_committed VARCHAR2(1);
    BEGIN
        IF x_result IS NULL AND x_result1 IS NULL THEN
            RETURN -1;
        END IF;

        IF x_committed = 1 THEN
            y_committed := fnd_api.g_true;
        ELSE
            y_committed := fnd_api.g_false;
        END IF;

        --
        -- Some input can be -1, if that's the case, set to null
        --
        IF x_collection_id = -1 THEN
            y_collection_id := NULL;
        ELSE
            y_collection_id := x_collection_id;
        END IF;
        IF x_spec_id = -1 THEN
            y_spec_id := NULL;
        ELSE
            y_spec_id := x_spec_id;
        END IF;

        --
        -- The flatten string is a representation that looks like this:
        --
        -- 10=Item@101=Defected@102=20 ...
        --
        -- namely, it is an @ separated list of charID=value.  In case
        -- value contains @, then it is doubly encoded.
        --
        -- First task is to decode this string into the row_element
        -- array.
        --
        elements := qa_validation_api.result_to_array(x_result);
        set_validation_flag_valid(elements);

        --
        -- Bug 5383667
        -- Shifted the id processing after the
        -- set validation flag proc
        -- ntungare
        --
        elements := qa_validation_api.id_to_array(x_result1, elements);

        -- Bug 2290747.Added parameter p_txn_header_id to enable
        -- history plan record when parent plan gets updated
        -- rponnusa Mon Apr  1 22:25:49 PST 2002

        qa_results_pub.insert_row(
            p_api_version => 1.0,
            p_org_id => x_org_id,
            p_plan_id => x_plan_id,
            p_spec_id => y_spec_id,
            p_transaction_number => null,
            p_transaction_id => null,
            p_enabled_flag => x_enabled,
            p_commit => y_committed,
            x_collection_id => y_collection_id,
            x_occurrence => x_occurrence,
            x_row_elements => elements,
            x_msg_count => msg_count,
            x_msg_data  => msg_data,
            x_error_array => error_array,
            x_message_array => message_array,
            x_return_status => return_status,
            x_action_result => action_result,
            p_txn_header_id => p_txn_header_id);

        IF qa_validation_api.no_errors(error_array) AND
           return_status <> FND_API.G_RET_STS_ERROR AND
           return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
            RETURN 0;
        ELSE
            qa_ss_results.get_error_messages(
                error_array, x_plan_id, x_messages);
        END IF;

        RETURN -1;
    END post_result_with_no_validation;


    --
    -- This overloaded method is for transaction only
    -- Post a result to the database.  This is a wrapper to the QA API
    -- qa_results_api.insert_row
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
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2,
        p_txn_header_id IN NUMBER DEFAULT NULL)
    RETURN INTEGER IS

    BEGIN

        --
        -- R12 Project MOAC 4637896
        -- There is no difference between this method and
        -- qa_ss_results.post_result
        -- The param p_txn_header_id is never used.
        -- bso Sat Oct  1 18:05:47 PDT 2005
        --

        RETURN qa_ss_results.post_result(
            x_occurrence => x_occurrence,
            x_org_id => x_org_id,
            x_plan_id => x_plan_id,
            x_spec_id => x_spec_id,
            x_collection_id => x_collection_id,
            x_result => x_result,
            x_result1 => x_result1,
            x_result2 => x_result2,
            x_enabled => x_enabled,
            x_committed => x_committed,
            x_transaction_number => x_transaction_number,
            x_messages => x_messages);

    END post_result;


    --
    -- Delete a result.
    --
    PROCEDURE delete_result(
        x_plan_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_occurrence IN NUMBER) IS
    BEGIN
        qa_ss_results.delete_result(
            x_plan_id => x_plan_id,
            x_collection_id => x_collection_id,
            x_occurrence => x_occurrence);
    END delete_result;

    --
    -- Batch delete a set of results (supply occurrences in
    -- comma-separated list.)
    --
    PROCEDURE delete_results(
        x_plan_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_occurrences IN VARCHAR2) IS

    BEGIN
        qa_ss_results.delete_results(
            x_plan_id => x_plan_id,
            x_collection_id => x_collection_id,
            x_occurrences => x_occurrences);
    END delete_results;

    --
    -- Perform database commit.  Do not use in transaction integration,
    -- otherwise we will be committing the parent's data without their
    -- knowing!
    --
    PROCEDURE commit_results IS
    BEGIN
        commit;
        --
        -- work on action later.
        --
    END commit_results;

END qa_mqa_results;

/
