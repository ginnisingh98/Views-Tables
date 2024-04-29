--------------------------------------------------------
--  DDL for Package QA_WEB_TXN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_WEB_TXN_API" AUTHID CURRENT_USER AS
/* $Header: qlttxnwb.pls 120.3 2005/08/22 05:51:06 srhariha noship $ */

FUNCTION quality_plans_applicable (p_txn_number IN NUMBER,
    p_organization_id IN NUMBER DEFAULT NULL,
    pk1 IN VARCHAR2 DEFAULT NULL,
    pk2 IN VARCHAR2 DEFAULT NULL,
    pk3 IN VARCHAR2 DEFAULT NULL,
    pk4 IN VARCHAR2 DEFAULT NULL,
    pk5 IN VARCHAR2 DEFAULT NULL,
    pk6 IN VARCHAR2 DEFAULT NULL,
    pk7 IN VARCHAR2 DEFAULT NULL,
    pk8 IN VARCHAR2 DEFAULT NULL,
    pk9 IN VARCHAR2 DEFAULT NULL,
    pk10 IN VARCHAR2 DEFAULT NULL,
    p_txn_name IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;


FUNCTION quality_mandatory_plans_remain (p_txn_number IN NUMBER,
    p_organization_id IN NUMBER DEFAULT NULL,
    pk1 IN VARCHAR2 DEFAULT NULL,
    pk2 IN VARCHAR2 DEFAULT NULL,
    pk3 IN VARCHAR2 DEFAULT NULL,
    pk4 IN VARCHAR2 DEFAULT NULL,
    pk5 IN VARCHAR2 DEFAULT NULL,
    pk6 IN VARCHAR2 DEFAULT NULL,
    pk7 IN VARCHAR2 DEFAULT NULL,
    pk8 IN VARCHAR2 DEFAULT NULL,
    pk9 IN VARCHAR2 DEFAULT NULL,
    pk10 IN VARCHAR2 DEFAULT NULL,
    p_txn_name IN VARCHAR2 DEFAULT NULL,
    p_list_of_plans IN VARCHAR2 DEFAULT NULL,
    p_collection_id IN NUMBER DEFAULT NULL,
    p_wip_entity_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2;


FUNCTION background_plan ( p_plan_id IN NUMBER, p_txn_number IN NUMBER)
    RETURN VARCHAR2;

FUNCTION allowed_for_plan ( p_function_name IN VARCHAR2, p_plan_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION plan_applies ( p_plan_id 	IN NUMBER,
			p_txn_number    IN NUMBER   DEFAULT NULL,
                        p_org_id        IN NUMBER   DEFAULT NULL,
			pk1 		IN VARCHAR2 DEFAULT NULL,
			pk2 		IN VARCHAR2 DEFAULT NULL,
			pk3 		IN VARCHAR2 DEFAULT NULL,
			pk4	 	IN VARCHAR2 DEFAULT NULL,
			pk5 		IN VARCHAR2 DEFAULT NULL,
			pk6 		IN VARCHAR2 DEFAULT NULL,
			pk7 		IN VARCHAR2 DEFAULT NULL,
			pk8 		IN VARCHAR2 DEFAULT NULL,
			pk9 		IN VARCHAR2 DEFAULT NULL,
			pk10 		IN VARCHAR2 DEFAULT NULL,
			p_txn_name   	IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;


PROCEDURE quality_post_commit_processing (p_collection_id IN NUMBER,
    p_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2);


FUNCTION get_mandatory_optional_info (p_plan_id NUMBER, p_txn_number IN NUMBER)
    RETURN VARCHAR2;


PROCEDURE post_background_results(
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_context_values IN VARCHAR2,
    p_collection_id IN NUMBER);

--
-- Tracking Bug 4343758.  Fwk Integration.
-- Currently there is no simple metamodel to look up
-- which transactions are enabled for Workbench.
-- So, we do a hard check here.  When there is
-- datamodel available, this can be changed to
-- select from the db.
--
-- Return fnd_api.g_true if p_txn is enabled for OAF
-- transaction integration; else fnd_api.g_false.
-- bso Fri May 20 14:01:25 PDT 2005
--
--
FUNCTION is_workbench_txn(p_txn IN NUMBER) RETURN VARCHAR2;


-- Bug 4343758. Oa Fwk Integration Project.
-- New API used to get information on mandatory
-- result entry.
-- srhariha. Mon May  2 00:33:26 PDT 2005.

FUNCTION get_result_entered(p_plan_id IN NUMBER,
                            p_collection_id IN NUMBER)
      RETURN VARCHAR2;

-- Bug 4519559. Oa Fwk Integration Project. UT bug fix.
-- Return fnd_api.g_true if p_txn is a mobile txn
-- else return fnd_api.g_false
-- srhariha. Tue Aug  2 01:37:53 PDT 2005

-- Bug 4519558.OA Framework Integration project. UT bug fix.
-- Incorporating Bryan's code review comments. Moved the
-- method to qa_mqa_mwa_api package.
-- srhariha. Mon Aug 22 02:50:35 PDT 2005.

-- FUNCTION is_mobile_txn(p_txn IN NUMBER) RETURN VARCHAR2;

END qa_web_txn_api;

 

/
