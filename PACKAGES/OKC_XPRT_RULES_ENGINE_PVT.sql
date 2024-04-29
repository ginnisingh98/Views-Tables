--------------------------------------------------------
--  DDL for Package OKC_XPRT_RULES_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_RULES_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXRULENGS.pls 120.0.12010000.8 2012/08/21 14:04:09 nbingi noship $ */

p_doc_id NUMBER;
p_doc_type VARCHAR2(40);
p_template_id NUMBER;
questions_display_changed VARCHAR2(1);

TYPE result_rec_type IS RECORD (
  rule_id         NUMBER,
  condition_id    NUMBER,
  result	  VARCHAR2(30) );
TYPE result_tbl_type IS TABLE OF result_rec_type INDEX BY BINARY_INTEGER;

TYPE varchar2_4000 IS TABLE OF VARCHAR2(4000);
lhs_values_tbl varchar2_4000;
rhs_values_tbl varchar2_4000;

TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE init_contract_expert(doc_id IN NUMBER, doc_type IN VARCHAR2, template_id IN NUMBER, x_has_questions OUT NOCOPY VARCHAR2);
PROCEDURE populate_rule_cond_eval_table;
PROCEDURE populate_doc_var_values;
PROCEDURE populate_doc_questions;
PROCEDURE populate_rule_cond_dep;
PROCEDURE evaluate_rules_and_conditions;
FUNCTION evaluate_condition(p_cond_id NUMBER, p_cond_type VARCHAR2, p_object_code VARCHAR2, p_object_value_type VARCHAR2, p_object_value_code VARCHAR2, p_operator VARCHAR2) RETURN BOOLEAN;
PROCEDURE reevaluate_rules(reeval_rules OKC_TBL_NUMBER);
FUNCTION evaluate_user_response(doc_id NUMBER, doc_type VARCHAR2, template_id NUMBER, p_question_id VARCHAR2, p_response VARCHAR2) RETURN VARCHAR2;
PROCEDURE save_responses(doc_id IN NUMBER, doc_type IN VARCHAR2, p_lock_xprt_yn IN VARCHAR2, x_return_status OUT NOCOPY VARCHAR2);
FUNCTION getTemplateId RETURN NUMBER;
FUNCTION getDocId RETURN NUMBER;
FUNCTION getDocType RETURN VARCHAR2;
FUNCTION has_all_questions_answered(doc_id NUMBER, doc_type VARCHAR2) RETURN VARCHAR2;
PROCEDURE create_xprt_responses_version(doc_id IN NUMBER, doc_type IN VARCHAR2, p_major_version IN NUMBER);
PROCEDURE restore_xprt_responses_version(doc_id IN NUMBER, doc_type IN VARCHAR2, p_major_version IN NUMBER);
PROCEDURE delete_xprt_responses_version(doc_id IN NUMBER, doc_type IN VARCHAR2, p_major_version IN NUMBER);

END OKC_XPRT_RULES_ENGINE_PVT;

/
