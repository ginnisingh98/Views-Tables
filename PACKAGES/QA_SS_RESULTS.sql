--------------------------------------------------------
--  DDL for Package QA_SS_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_RESULTS" AUTHID CURRENT_USER AS
/* $Header: qltssreb.pls 120.10.12010000.1 2008/07/25 09:22:50 appldev ship $ */

    --
    -- Post a result to the database.  This is a wrapper to the QA API
    -- qa_results_api.insert_row.  Do not perform commit.  Most of the
    -- parameters are self explanatory.
    --
    -- x_result is a flattened @-separated list of <char_id>=<value>.
    -- x_result1 is an @-sepated list of <char_id>=<id> used for
    --           hardcoded referenced elements that have known IDs.
    -- x_result2 is not used but can be reserved for
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
    FUNCTION nontxn_post_result(
        x_occurrence OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_messages OUT NOCOPY VARCHAR2)
        RETURN INTEGER;

    --
    -- The overloaded method is used for transaction only
    --
    FUNCTION post_result(
        x_occurrence IN OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2)
        RETURN INTEGER;


    --
    -- The overloaded method is used for ssqr.
    -- In addition to the code in post_result,
    -- we call insert history and automatic records.
    --
    -- 12.1 QWB Usability Improvements
    -- Added 2  new paramters to pass the aggregated values for
    -- the parent plan collection elements to the JAVA layer.
    --
    FUNCTION ssqr_post_result(
        x_occurrence IN OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_txn_header_id IN NUMBER,
        x_par_plan_id IN NUMBER,
        x_par_col_id IN NUMBER,
        x_par_occ IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2,
        x_agg_elements OUT NOCOPY VARCHAR2,
        x_agg_val OUT NOCOPY VARCHAR2,
        p_last_update_date IN DATE DEFAULT SYSDATE)
        RETURN INTEGER;

    --
    -- update_result
    --
    FUNCTION update_result(
        x_occurrence IN NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2)
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
    -- knowing!  Actions will be fired in the background.
    --
    PROCEDURE commit_results;

    PROCEDURE wrapper_fire_action (
       q_collection_id		IN	NUMBER,
       q_return_status		OUT 	NOCOPY VARCHAR2,
       q_msg_count		OUT 	NOCOPY NUMBER,
       q_msg_data		OUT 	NOCOPY VARCHAR2);


    PROCEDURE GET_COLLECTION_ID (x_collection_id OUT NOCOPY NUMBER);

    --
    -- Bug 6881303
    -- added 2 new elements, one a comma separated list of the
    -- Parent collection elements that would receive aggregated
    -- values and the other a comma separated list of the
    -- aggregated values.
    -- ntungare Fri Mar 21 01:19:03 PDT 2008
    --
    FUNCTION ssqr_update_result(
        x_occurrence IN NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_txn_header_id IN NUMBER,
        x_par_plan_id IN NUMBER,
        x_par_col_id IN NUMBER,
        x_par_occ IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2,
        x_agg_elements OUT NOCOPY VARCHAR2,
        x_agg_val OUT NOCOPY VARCHAR2,
        p_last_update_date IN DATE DEFAULT SYSDATE)
    RETURN INTEGER;

    --
    -- bug 5306909
    -- Added p_last_update_date parameter. This parameter is used to
    -- check whether the record which the user is trying to update has
    -- been updated already  by some other user.
    -- ntungare Mon Apr 10 07:00:21 PDT 2006
    --
    FUNCTION ssqr_lock_row (
        p_occurrence IN NUMBER,
        p_plan_id IN NUMBER,
	p_last_update_date IN DATE,
        x_status OUT NOCOPY VARCHAR2)
    RETURN INTEGER;

    --
    -- 12.1 QWB Usability Improvements
    -- Added 2 new parameters x_charid_str and x_id_str
    -- to return comma separated strings of HC
    -- elements and the Normalized Id values
    --
    FUNCTION ssqr_validate_row (
        p_occurrence IN OUT NOCOPY NUMBER,
        p_org_id IN NUMBER,
        p_plan_id IN NUMBER,
        p_spec_id IN NUMBER,
        p_collection_id IN NUMBER,
        p_result IN VARCHAR2,
        p_result1 IN VARCHAR2,
        p_result2 IN VARCHAR2,      -- not used yet, for future expansion
        p_enabled IN INTEGER,
        p_committed IN INTEGER,
        p_transaction_number IN NUMBER,
        p_transaction_id IN  NUMBER DEFAULT 0,
   --     p_who_created_by IN  NUMBER := fnd_global.user_id,
        x_messages OUT NOCOPY VARCHAR2,
        x_charid_str OUT NOCOPY VARCHAR2,
        x_id_str out NOCOPY VARCHAR2)
    RETURN INTEGER ;


    TYPE mesg_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


    -- Bug 4502450 R12. eSig Status support in Multirow  UQR
    -- Functions checks if the current plan row has PENDING eSig
    -- Status, if not it checks all the parent plans for eSig Status
    -- if for corresponding parent row has eSig Status as PENDING
    -- fills the message array and returns -1
    -- rest is taken care in updateRow() method of QualityResultsEOImpl
    -- saugupta Wed, 24 Aug 2005 08:51:28 -0700 PDT
    FUNCTION validate_esig_for_update(
        p_plan_id            IN NUMBER,
        p_plan_collection_id IN NUMBER,
        p_plan_occurrence    IN NUMBER)
    RETURN BOOLEAN;

   -- bug 4658275. eSig functionality support in QWB
   -- this new method checks if user can insert a new
   -- child row if ERES is enables
   -- saugupta Tue, 18 Oct 2005 02:55:19 -0700 PDT
   FUNCTION validate_esig_for_insert(p_plan_id            IN NUMBER,
                                     p_plan_collection_id IN NUMBER,
                                     p_plan_occurrence    IN NUMBER)
             RETURN BOOLEAN;


    -- R12 Project MOAC 4637896
    -- For modularity, exposing this method for use by
    -- qa_mqa_results
    --
    -- Parse out the error messages in the ErrorArray
    -- returned by the validation API and append them
    -- into an @-separated string.  If an error message
    -- contains @, it will be doubly encoded.
    --
    PROCEDURE get_error_messages(
        p_errors IN qa_validation_api.ErrorArray,
        p_plan_id IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2);

   PROCEDURE post_error_messages (p_errors IN qa_validation_api.ErrorArray,
                                  plan_id NUMBER);

   -- R12.1 QWB Usability Improvements project
   -- Function to perform deletetion of rows
   --
   FUNCTION delete_row(p_plan_id        IN  NUMBER,
                       p_collection_id  IN  NUMBER,
                       p_occurrence     IN  NUMBER,
		       p_org_id         IN  NUMBER,
		       p_txn_header_id  IN  NUMBER,
                       p_par_plan_id    IN  NUMBER DEFAULT -1,
                       p_par_col_id     IN  NUMBER DEFAULT -1,
                       p_par_occ        IN  NUMBER DEFAULT -1)
           RETURN VARCHAR2;

END qa_ss_results;

/
