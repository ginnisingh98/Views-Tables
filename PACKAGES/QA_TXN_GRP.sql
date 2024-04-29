--------------------------------------------------------
--  DDL for Package QA_TXN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_TXN_GRP" AUTHID CURRENT_USER AS
/* $Header: qagtxns.pls 120.3.12010000.1 2008/07/25 09:19:34 appldev ship $ */

  --
  -- Bug 2123065
  -- Custom parameters used for customization.
  -- bso Mon Nov 26 11:52:09 PST 2001
  --
  g_custom1 VARCHAR2(150) DEFAULT '';
  g_custom2 VARCHAR2(150) DEFAULT '';
  g_custom3 VARCHAR2(150) DEFAULT '';
  g_custom4 VARCHAR2(150) DEFAULT '';
  g_custom5 VARCHAR2(150) DEFAULT '';
  g_custom6 VARCHAR2(150) DEFAULT '';
  g_custom7 VARCHAR2(150) DEFAULT '';
  g_custom8 VARCHAR2(150) DEFAULT '';
  g_custom9 VARCHAR2(150) DEFAULT '';
  g_custom10 VARCHAR2(150) DEFAULT '';
  g_custom11 VARCHAR2(150) DEFAULT '';
  g_custom12 VARCHAR2(150) DEFAULT '';
  g_custom13 VARCHAR2(150) DEFAULT '';
  g_custom14 VARCHAR2(150) DEFAULT '';
  g_custom15 VARCHAR2(150) DEFAULT '';

  qa_enabled_cache    VARCHAR2(1) DEFAULT NULL;
  txn_number_cache    NUMBER DEFAULT -1;
  org_id_cache        NUMBER DEFAULT -1;

  TYPE ElementRecord IS RECORD (
    value VARCHAR2(2000),
    validation_flag VARCHAR2(100) DEFAULT 'invalid');

  TYPE ElementsArray IS TABLE OF ElementRecord INDEX BY BINARY_INTEGER;

  --
  -- Return 'T' if QA is installed and there is some plans set up
  -- Return 'F' if otherwise
  --
  FUNCTION qa_enabled(
      p_txn_number IN NUMBER,
      p_org_id IN NUMBER) RETURN VARCHAR2;

  --
  -- Return 'T' if there are plans set up for the given transaction
  -- Return 'F' if otherwise
  --
  FUNCTION commit_allowed(
      p_txn_number IN varchar2,
      p_org_id IN NUMBER,
      p_plan_txn_ids IN VARCHAR2,
      p_collection_id IN NUMBER,
      x_plan_ids OUT NOCOPY VARCHAR2)
      RETURN VARCHAR2;

  FUNCTION get_collection_id RETURN NUMBER;

  FUNCTION result_to_array(x_result IN VARCHAR2)
      RETURN ElementsArray;

  FUNCTION evaluate_triggers(
      p_txn_number IN NUMBER,
      p_org_id IN NUMBER,
      p_context_values IN VARCHAR2,
      x_plan_txn_ids OUT NOCOPY VARCHAR2)
      RETURN VARCHAR2;

  PROCEDURE insert_results(
      p_plan_id IN NUMBER,
      p_org_id IN NUMBER,
      p_collection_id IN NUMBER,
      elements IN ElementsArray);

  PROCEDURE post_background_results(
      p_txn_number IN NUMBER,
      p_org_id IN NUMBER,
      p_plan_txn_ids IN VARCHAR2,
      p_context_values IN VARCHAR2,
      p_collection_id IN NUMBER);

  -- Bug 4995406
  -- Added a procedure to do the processing
  -- of the Results for Background Collection plans
  -- for EAM Transaction
  -- ntungare Wed Feb 22 06:26:17 PST 2006
  PROCEDURE eam_post_background_results(
      p_txn_number IN NUMBER,
      p_org_id IN NUMBER,
      p_context_values IN VARCHAR2,
      p_collection_id IN NUMBER);

  FUNCTION get_plan_names(
      p_plan_ids IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE relate_results(p_collection_id NUMBER);


  --
  -- Bug 2123065
  -- Custom parameters used for customization.
  -- bso Mon Nov 26 11:52:09 PST 2001
  --
  PROCEDURE clear_customs;
  PROCEDURE put_custom1(p_value IN VARCHAR2);
  PROCEDURE put_custom2(p_value IN VARCHAR2);
  PROCEDURE put_custom3(p_value IN VARCHAR2);
  PROCEDURE put_custom4(p_value IN VARCHAR2);
  PROCEDURE put_custom5(p_value IN VARCHAR2);
  PROCEDURE put_custom6(p_value IN VARCHAR2);
  PROCEDURE put_custom7(p_value IN VARCHAR2);
  PROCEDURE put_custom8(p_value IN VARCHAR2);
  PROCEDURE put_custom9(p_value IN VARCHAR2);
  PROCEDURE put_custom10(p_value IN VARCHAR2);
  PROCEDURE put_custom11(p_value IN VARCHAR2);
  PROCEDURE put_custom12(p_value IN VARCHAR2);
  PROCEDURE put_custom13(p_value IN VARCHAR2);
  PROCEDURE put_custom14(p_value IN VARCHAR2);
  PROCEDURE put_custom15(p_value IN VARCHAR2);
  FUNCTION get_custom1 RETURN VARCHAR2;
  FUNCTION get_custom2 RETURN VARCHAR2;
  FUNCTION get_custom3 RETURN VARCHAR2;
  FUNCTION get_custom4 RETURN VARCHAR2;
  FUNCTION get_custom5 RETURN VARCHAR2;
  FUNCTION get_custom6 RETURN VARCHAR2;
  FUNCTION get_custom7 RETURN VARCHAR2;
  FUNCTION get_custom8 RETURN VARCHAR2;
  FUNCTION get_custom9 RETURN VARCHAR2;
  FUNCTION get_custom10 RETURN VARCHAR2;
  FUNCTION get_custom11 RETURN VARCHAR2;
  FUNCTION get_custom12 RETURN VARCHAR2;
  FUNCTION get_custom13 RETURN VARCHAR2;
  FUNCTION get_custom14 RETURN VARCHAR2;
  FUNCTION get_custom15 RETURN VARCHAR2;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/10/2005.
  -- This function is used by parent Txns to check whether the Quality
  -- Results entered during the Transaction can be committed.
  FUNCTION is_commit_allowed(
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER := NULL,
      p_collection_id    IN         NUMBER,
      p_plan_txn_ids     IN         VARCHAR2 := NULL,
      x_plan_names       OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/07/2005.
  -- This is an API for performing the post commit processing in
  -- transaction integration scenario. This API performs the following actions
  -- Insert Automatic and History Results.
  -- Post Background results for the transaction.
  -- Generate Sequence element values.
  -- Enable the Quality Results
  -- Fire Background actions.
  PROCEDURE process_txn_post_commit(
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER,
      p_collection_id    IN         NUMBER,
      p_plan_txn_ids     IN         VARCHAR2 := NULL,
      p_context_values   IN         VARCHAR2,
      p_context_ids      IN         VARCHAR2 := NULL,
      p_generated_values IN         VARCHAR2 := NULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2);

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/10/2005.
  -- This function is used for Purging QA Results and their associated
  -- Records. This API is called when the parent Transaction is Unsuccessful.
  FUNCTION purge_records(
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER := NULL,
      p_collection_id    IN         NUMBER) RETURN NUMBER;

  -- Bug 4343758. OA Integration Project.
  -- Wrapper around evaluate_triggers.
  -- Returns comma seperated list of transaction id
  -- srhariha. Wed May  4 03:12:40 PDT 2005.
  FUNCTION ssqr_evaluate_triggers(
      p_txn_number IN NUMBER,
      p_org_id IN NUMBER,
      p_context_values IN VARCHAR2)
      RETURN VARCHAR2;

  -- Added two new methods below for ERES in MES integration.
  -- saugupta Mon, 07 Jan 2008 05:45:06 -0800 PDT

  -- Method inserts background results, history and automatic results
  -- and generate sequence Numbers for the applicable plans
  -- saugupta Mon, 07 Jan 2008 05:46:11 -0800 PDT
  PROCEDURE process_txn_for_eres(
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER,
      p_collection_id    IN         NUMBER,
      p_plan_txn_ids     IN         VARCHAR2 := NULL,
      p_context_values   IN         VARCHAR2,
      p_context_ids      IN         VARCHAR2 := NULL,
      p_generated_values IN         VARCHAR2 := NULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2);

  -- Enable and fire background actions in case of ERES
  -- saugupta Mon, 07 Jan 2008 05:46:40 -0800 PDT
  PROCEDURE enable_and_fire_action (
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_collection_id IN NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2 );


END qa_txn_grp;


/
