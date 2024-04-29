--------------------------------------------------------
--  DDL for Package QA_MQA_MWA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_MQA_MWA_API" AUTHID CURRENT_USER AS
/* $Header: qamwas.pls 120.1 2005/08/22 06:02:24 srhariha noship $ */

TYPE PlanTxn IS RECORD (
	planID NUMBER,
	planTxnID NUMBER);

Type PlanTxnTab is TABLE of PlanTxn INDEX BY BINARY_INTEGER;

Type CtxElemCharIdTab is TABLE of NUMBER;

TYPE CtxElemId IS RECORD (
	ID NUMBER DEFAULT NULL);

Type CtxElemIdTab is TABLE of CtxElemId INDEX BY BINARY_INTEGER;

    --
    -- Return 1 if the application p_short_name is installed.
    -- Wrapper to fnd_installation.get_app_info (which, having
    -- a Boolean return value, is not compatible with current
    -- JDBC versions.
    --

    FUNCTION app_installed(p_short_name IN VARCHAR2)
        RETURN NUMBER;

    --
    -- Wrapper to enabled API.  User is encouraged to use the
    -- original.
    --
    PROCEDURE transaction_completed(collection_id IN NUMBER,
        commit_flag IN VARCHAR2 DEFAULT 'Y');


PROCEDURE EXPLODE_WMS_LPN(
	p_lpn_id IN NUMBER,
	p_org_id IN NUMBER,
	x_content_table OUT NOCOPY WMS_CONTAINER_PUB.WMS_CONTAINER_TBL_TYPE,
	x_elements OUT NOCOPY qa_txn_grp.ElementsArray,
	x_element_ids OUT NOCOPY CtxElemIdTab);

PROCEDURE evaluate_triggers(
	p_lpn_id IN NUMBER,
	p_txn_number IN NUMBER,
	p_org_id IN NUMBER,
	x_plan_contexts_str OUT NOCOPY VARCHAR2,
	x_plan_ctxs_ids_str OUT NOCOPY VARCHAR2,
	x_plan_txn_ids_str OUT NOCOPY VARCHAR2);

FUNCTION triggers_matched(
	p_plan_txn_id IN NUMBER,
	elements IN qa_txn_grp.ElementsArray) return VARCHAR2;
-- Bug 4519558. Oa Fwk Integration Project. UT bug fix.
-- Return fnd_api.g_true if p_txn is a mobile txn
-- else return fnd_api.g_false.
-- Mobile transaction number will come in range (1000,2000)
-- srhariha. Mon Aug 22 02:50:35 PDT 2005.


FUNCTION is_mobile_txn(p_txn IN NUMBER) RETURN VARCHAR2;


END qa_mqa_mwa_api;

 

/
