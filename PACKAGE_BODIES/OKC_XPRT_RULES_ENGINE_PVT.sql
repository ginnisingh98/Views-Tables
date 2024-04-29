--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_RULES_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_RULES_ENGINE_PVT" AS
/* $Header: OKCVXRULENGB.pls 120.0.12010000.17 2013/09/18 10:23:58 nbingi noship $ */

--global_variables
G_PKG_NAME CONSTANT VARCHAR2(200) := 'OKC_XPRT_RULES_ENGINE_PVT';
G_MODULE_NAME CONSTANT VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

FUNCTION getTemplateId RETURN NUMBER IS
BEGIN
RETURN p_template_id;
END;

FUNCTION getDocId RETURN NUMBER IS
BEGIN
RETURN p_doc_id;
END;

FUNCTION getDocType RETURN VARCHAR2 IS
BEGIN
RETURN p_doc_type;
END;

PROCEDURE init_contract_expert(doc_id IN NUMBER, doc_type IN VARCHAR2, template_id IN NUMBER, x_has_questions OUT NOCOPY VARCHAR2) IS

l_api_name CONSTANT VARCHAR2(30) := 'init_contract_expert';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

l_template_id NUMBER;
BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_id : ' || doc_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_type : ' || doc_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: template_id : ' || template_id);
	END IF;

	p_doc_id := doc_id;
  	p_doc_type := doc_type;
  	p_template_id := template_id;

	--populating all temp tables and evaluating conditions
	populate_rule_cond_eval_table();    --populating okc_xprt_rule_eval_result_t table with all rules and conditions
  	populate_doc_var_values();	    --populating okc_xprt_rule_eval_condval_t with variables values
  	populate_doc_questions();	    --populating okc_xprt_rule_eval_condval_t with questions for the VO to render in Questions UI page
	populate_rule_cond_dep();		    --populating rule, cond clause lvel dependency into a gt table
  	evaluate_rules_and_conditions();    --evaluating rules and conditions. evaluate variable based conditions and question based condition if it has a response

	x_has_questions := 'N';

	BEGIN
		SELECT 'Y' INTO x_has_questions FROM dual
		WHERE EXISTS (SELECT 1 FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
				    AND object_type = 'QUESTION' AND display_flag = 'Y');
 	EXCEPTION
    		WHEN NO_DATA_FOUND THEN
  		NULL;
  	END;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: x_has_questions : ' || x_has_questions);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '120: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END init_contract_expert;


PROCEDURE populate_rule_cond_eval_table IS

CURSOR c_rules IS
SELECT rule.rule_id, rule.condition_expr_code
FROM okc_xprt_template_rules rultmpl, okc_xprt_rule_hdrs_all_v rule
WHERE rultmpl.template_id = p_template_id
AND rule.rule_id = rultmpl.rule_id
UNION ALL
SELECT rule.rule_id, rule.condition_expr_code
FROM okc_xprt_rule_hdrs_all_v rule
WHERE rule.org_id = (SELECT org_id FROM okc_terms_templates_all WHERE template_id = p_template_id)
AND rule.intent = (SELECT intent FROM okc_terms_templates_all WHERE template_id = p_template_id)
AND rule.org_wide_flag = 'Y';

CURSOR c_rule_conditions IS
SELECT cond.rule_id, cond.rule_condition_id, cond.object_type condition_type, cond.object_code, rule.condition_expr_code, cond.object_value_type, cond.object_value_code, cond.operator
FROM okc_xprt_template_rules rultmpl, okc_xprt_rule_hdrs_all_v rule, okc_xprt_rule_cond_active_v cond
WHERE rultmpl.template_id = p_template_id
AND rule.rule_id = rultmpl.rule_id
AND cond.rule_id = rule.rule_id
UNION ALL
SELECT cond.rule_id, cond.rule_condition_id, cond.object_type condition_type, cond.object_code, rule.condition_expr_code, cond.object_value_type, cond.object_value_code, cond.operator
FROM okc_xprt_rule_hdrs_all_v rule, okc_xprt_rule_cond_active_v cond
WHERE rule.org_id = (SELECT org_id FROM okc_terms_templates_all WHERE template_id = p_template_id)
AND rule.intent = (SELECT intent FROM okc_terms_templates_all WHERE template_id = p_template_id)
AND rule.org_wide_flag = 'Y'
AND cond.rule_id = rule.rule_id;

rule_ids number_type;
cond_ids number_type;

TYPE varchar2_30 IS TABLE OF VARCHAR2(30);
cond_types varchar2_30;
cond_expr_codes varchar2_30;
cond_operator varchar2_30;
cond_value_type varchar2_30;

TYPE varchar2_40 IS TABLE OF VARCHAR2(40);
cond_object_codes varchar2_40;

TYPE varchar2_1000 IS TABLE OF VARCHAR2(1000);
cond_object_value_codes varchar2_1000;

l_api_name CONSTANT VARCHAR2(30) := 'populate_rule_cond_eval_table';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	END IF;

	DELETE okc_xprt_rule_eval_result_t WHERE doc_id = p_doc_id and doc_type = p_doc_type;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: Deleted entries in okc_xprt_rule_eval_result_t for this document before populating');
	END IF;

	OPEN c_rules;
	FETCH c_rules BULK COLLECT INTO rule_ids, cond_expr_codes;
	FORALL i IN 1 .. rule_ids.count
		INSERT INTO okc_xprt_rule_eval_result_t(rule_condition_result_id, doc_id, doc_type, rule_id, condition_id, condition_type, object_code, rule_expr_type, object_value_type, cond_operator, result)
		VALUES(OKC_XPRT_RULE_EVAL_RESULT_S.nextval, p_doc_id, p_doc_type, rule_ids(i), null, null, null, cond_expr_codes(i), null, null, null);
	CLOSE c_rules;

	OPEN c_rule_conditions;
	FETCH c_rule_conditions BULK COLLECT INTO rule_ids, cond_ids, cond_types, cond_object_codes, cond_expr_codes, cond_value_type, cond_object_value_codes, cond_operator;
	FORALL i IN 1 .. rule_ids.count
		INSERT INTO okc_xprt_rule_eval_result_t(rule_condition_result_id, doc_id, doc_type, rule_id, condition_id, condition_type, object_code, rule_expr_type, object_value_type, object_value_code, cond_operator, result)
		VALUES(OKC_XPRT_RULE_EVAL_RESULT_S.nextval, p_doc_id, p_doc_type, rule_ids(i), cond_ids(i), cond_types(i), cond_object_codes(i), cond_expr_codes(i), cond_value_type(i), cond_object_value_codes(i), cond_operator(i), null);
	CLOSE c_rule_conditions;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Populated entries in okc_xprt_rule_eval_result_t for this document');
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: No. of rules populated: ' || cond_expr_codes.count);
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: No. of rule conditions populated: ' || cond_ids.count);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '130: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END populate_rule_cond_eval_table;


PROCEDURE populate_doc_var_values IS

x_return_status VARCHAR(1);
x_msg_data  VARCHAR2(4000);
x_msg_count  NUMBER;
x_hdr_var_value_tbl okc_xprt_xrule_values_pvt.var_value_tbl_type;
x_line_sysvar_value_tbl okc_xprt_xrule_values_pvt.line_sys_var_value_tbl_type;
x_line_count	NUMBER;
x_line_variables_count NUMBER;
x_intent VARCHAR2(1);
x_org_id NUMBER;

TYPE var_val_rec_type IS RECORD (
  object_type              VARCHAR2(30), --VARIABLE or CONSTANT
  variable_code            VARCHAR2(40),
  variable_value_id        VARCHAR2(4000)
);

TYPE var_val_tbl_type IS TABLE OF var_val_rec_type INDEX BY BINARY_INTEGER;
variable_values_tbl var_val_tbl_type;

l_api_name CONSTANT VARCHAR2(30) := 'populate_doc_var_values';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	END IF;

	DELETE okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id and doc_type = p_doc_type;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: Deleted entries in okc_xprt_rule_eval_condval_t for this document before populating the variable values');
	END IF;

	okc_xprt_xrule_values_pvt.get_document_values(p_api_version => 1,
                                              p_init_msg_list => FND_API.G_FALSE,
                                              p_doc_type    => p_doc_type,
                                              p_doc_id      => p_doc_id,
                                              x_return_status => x_return_status,
                                              x_msg_data    => x_msg_data,
                                              x_msg_count   => x_msg_count,
                                              x_hdr_var_value_tbl  => x_hdr_var_value_tbl,
                                              x_line_sysvar_value_tbl  => x_line_sysvar_value_tbl,
                                              x_line_count  => x_line_count,
                                              x_line_variables_count => x_line_variables_count,
                                              x_intent			=> x_intent,
                                              x_org_id		  => x_org_id
                                              );

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	IF x_hdr_var_value_tbl.Count > 0 THEN
		FOR j IN x_hdr_var_value_tbl.first..x_hdr_var_value_tbl.LAST LOOP
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Variable code: ' || x_hdr_var_value_tbl(j).variable_code);
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Variable value id: ' || x_hdr_var_value_tbl(j).variable_value_id);
		END LOOP;
	END IF;

	IF x_line_sysvar_value_tbl.Count > 0 THEN
		FOR j IN x_line_sysvar_value_tbl.first..x_line_sysvar_value_tbl.LAST LOOP
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: Variable code: ' || x_line_sysvar_value_tbl(j).variable_code);
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: Variable value: ' || x_line_sysvar_value_tbl(j).variable_value);
		END LOOP;
	END IF;
END IF;

IF x_hdr_var_value_tbl.Count > 0 THEN
  FOR j IN x_hdr_var_value_tbl.first..x_hdr_var_value_tbl.LAST LOOP
    IF InStr(x_hdr_var_value_tbl(j).variable_code,'CONSTANT$') > 0 THEN
      variable_values_tbl(j).variable_code := SubStr(x_hdr_var_value_tbl(j).variable_code,Length('CONSTANT$')+1);
	 variable_values_tbl(j).object_type := 'CONSTANT';
    ELSIF InStr(x_hdr_var_value_tbl(j).variable_code,'USER$') > 0 THEN
      variable_values_tbl(j).variable_code := SubStr(x_hdr_var_value_tbl(j).variable_code,Length('USER$')+1);
	 variable_values_tbl(j).object_type := 'VARIABLE';
    ELSE
      variable_values_tbl(j).variable_code := x_hdr_var_value_tbl(j).variable_code;
	 variable_values_tbl(j).object_type := 'VARIABLE';
    END IF;
    variable_values_tbl(j).variable_value_id := x_hdr_var_value_tbl(j).variable_value_id;
  END LOOP;

  FORALL j IN variable_values_tbl.first..variable_values_tbl.last
  INSERT INTO okc_xprt_rule_eval_condval_t(doc_value_id, doc_id, doc_type, object_type, object_code, value_or_response)
  VALUES (OKC_XPRT_RULE_EVAL_CONDVAL_S.nextval, p_doc_id, p_doc_type, variable_values_tbl(j).object_type, variable_values_tbl(j).variable_code ,variable_values_tbl(j).variable_value_id);
END IF;

IF x_line_sysvar_value_tbl.Count > 0 THEN
  FORALL j IN x_line_sysvar_value_tbl.first..x_line_sysvar_value_tbl.LAST
  INSERT INTO okc_xprt_rule_eval_condval_t(doc_value_id, doc_id, doc_type, object_type, object_code, value_or_response)
  VALUES (OKC_XPRT_RULE_EVAL_CONDVAL_S.nextval, p_doc_id, p_doc_type, 'VARIABLE',x_line_sysvar_value_tbl(j).variable_code,x_line_sysvar_value_tbl(j).variable_value);
END IF;

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: Populated entries i.e variable values in okc_xprt_rule_eval_condval_t for this document');
	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: No. of global variables populated: ' || x_hdr_var_value_tbl.count);
	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: No. of line variables populated: ' || x_line_sysvar_value_tbl.count);
     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: Leaving method');
END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '150: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END populate_doc_var_values;


PROCEDURE populate_doc_questions IS

CURSOR c_question is
SELECT distinct cond.object_code, q.mandatory_flag display_flag
FROM okc_xprt_rule_eval_result_t cond, okc_xprt_question_orders q
WHERE cond.doc_id = p_doc_id
AND cond.doc_type = p_doc_type
AND cond.condition_type = 'QUESTION'
AND q.template_id = p_template_id
AND cond.object_code = q.question_id
UNION
SELECT distinct cond.object_value_code, q.mandatory_flag display_flag
FROM okc_xprt_rule_eval_result_t cond, okc_xprt_question_orders q
WHERE cond.doc_id = p_doc_id
AND cond.doc_type = p_doc_type
AND cond.object_value_type = 'QUESTION'
AND q.template_id = p_template_id
AND cond.object_value_code = q.question_id
UNION
SELECT distinct to_char(outcome.object_value_id), q.mandatory_flag display_flag
FROM okc_xprt_template_rules rultmpl, okc_xprt_rule_outcomes_act_v outcome, okc_xprt_question_orders q
WHERE rultmpl.template_id = p_template_id
AND outcome.rule_id = rultmpl.rule_id
AND outcome.object_type = 'QUESTION'
AND q.template_id = p_template_id
AND outcome.object_value_id = q.question_id
UNION
SELECT distinct to_char(outcome.object_value_id), q.mandatory_flag display_flag
FROM okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome, okc_xprt_question_orders q
WHERE rul.org_wide_flag = 'Y'
AND outcome.rule_id = rul.rule_id
AND outcome.object_type = 'QUESTION'
AND q.template_id = p_template_id
AND outcome.object_value_id = q.question_id;

CURSOR c_question_and_response is
SELECT distinct cond.object_code, resp.response, q.mandatory_flag display_flag
FROM okc_xprt_rule_eval_result_t cond, okc_xprt_doc_ques_response resp, okc_xprt_question_orders q
WHERE cond.doc_id = p_doc_id
AND cond.doc_type = p_doc_type
AND cond.condition_type = 'QUESTION'
AND resp.doc_id (+) = cond.doc_id
AND resp.doc_type (+) = cond.doc_type
AND resp.question_id (+) = cond.object_code
AND q.template_id = p_template_id
AND cond.object_code = q.question_id
UNION
SELECT distinct cond.object_value_code, resp.response, q.mandatory_flag display_flag
FROM okc_xprt_rule_eval_result_t cond, okc_xprt_doc_ques_response resp, okc_xprt_question_orders q
WHERE cond.doc_id = p_doc_id
AND cond.doc_type = p_doc_type
AND cond.object_value_type = 'QUESTION'
AND resp.doc_id (+) = cond.doc_id
AND resp.doc_type (+) = cond.doc_type
AND resp.question_id (+) = cond.object_value_code
AND q.template_id = p_template_id
AND cond.object_value_code = q.question_id
UNION
SELECT distinct to_char(outcome.object_value_id), resp.response, q.mandatory_flag display_flag
FROM  okc_xprt_template_rules rultmpl, okc_xprt_rule_outcomes_act_v outcome, okc_xprt_doc_ques_response resp, okc_xprt_question_orders q
WHERE rultmpl.template_id = p_template_id
AND outcome.rule_id = rultmpl.rule_id
AND outcome.object_type = 'QUESTION'
AND resp.doc_id (+) = p_doc_id
AND resp.doc_type (+) = p_doc_type
AND resp.question_id (+) = outcome.object_value_id
AND q.template_id = p_template_id
AND outcome.object_value_id = q.question_id
UNION
SELECT distinct to_char(outcome.object_value_id), resp.response, q.mandatory_flag display_flag
FROM  okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome, okc_xprt_doc_ques_response resp, okc_xprt_question_orders q
WHERE rul.org_wide_flag = 'Y'
AND outcome.rule_id = rul.rule_id
AND outcome.object_type = 'QUESTION'
AND resp.doc_id (+) = p_doc_id
AND resp.doc_type (+) = p_doc_type
AND resp.question_id (+) = outcome.object_value_id
AND q.template_id = p_template_id
AND outcome.object_value_id = q.question_id;

TYPE varchar2_1 IS TABLE OF VARCHAR2(1);
display_flags varchar2_1;
TYPE varchar2_40 IS TABLE OF VARCHAR2(40);
question_ids varchar2_40;
TYPE varchar2_4000 IS TABLE OF VARCHAR2(4000);
responses varchar2_4000;
is_contract_expert_run VARCHAR2(1) := 'N';

l_api_name CONSTANT VARCHAR2(30) := 'populate_doc_questions';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	END IF;

	BEGIN
		SELECT 'Y' INTO is_contract_expert_run FROM dual
		WHERE EXISTS (SELECT 1 FROM okc_xprt_doc_ques_response WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND response IS NOT NULL);
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	END;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: is_contract_expert_run : ' || is_contract_expert_run);
	END IF;

	IF is_contract_expert_run = 'Y' THEN
		OPEN c_question_and_response;
		FETCH c_question_and_response BULK COLLECT INTO question_ids, responses, display_flags;
		FORALL i IN 1 .. question_ids.count
			INSERT INTO okc_xprt_rule_eval_condval_t(doc_value_id, doc_id, doc_type, object_type, object_code, value_or_response, display_flag)
			VALUES(OKC_XPRT_RULE_EVAL_CONDVAL_S.nextval, p_doc_id, p_doc_type, 'QUESTION', question_ids(i), responses(i), display_flags(i));
		CLOSE c_question_and_response;
	ELSE
		OPEN c_question;
		FETCH c_question BULK COLLECT INTO question_ids, display_flags;
		FORALL i IN 1 .. question_ids.count
			INSERT INTO okc_xprt_rule_eval_condval_t(doc_value_id, doc_id, doc_type, object_type, object_code, value_or_response, display_flag)
			VALUES(OKC_XPRT_RULE_EVAL_CONDVAL_S.nextval, p_doc_id, p_doc_type, 'QUESTION', question_ids(i), null, display_flags(i));
		CLOSE c_question;
	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Populated entries i.e questions and responses(if exists) in okc_xprt_rule_eval_condval_t for this document');
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: No. of questions populated: ' || question_ids.count);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '130: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END populate_doc_questions;

PROCEDURE populate_rule_cond_dep IS

l_api_name CONSTANT VARCHAR2(30) := 'populate_rule_cond_dep';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	END IF;

	INSERT INTO okc_xprt_rule_eval_condval_t(doc_value_id, doc_id, doc_type, object_type, object_code, value_or_response, display_flag, dep_clause_cond_id)
	SELECT OKC_XPRT_RULE_EVAL_CONDVAL_S.nextval, p_doc_id, p_doc_type, 'RULE', rule_id, null, null, dep_clause_cond_id FROM okc_xprt_rule_dependencies_v;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Rule_clause dependency rows populated into okc_xprt_rule_eval_condval_t table from okc_xprt_rule_dependencies_v view');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '130: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END populate_rule_cond_dep;


PROCEDURE evaluate_rules_and_conditions IS

CURSOR c_rules IS
SELECT rule_id, rule_expr_type
FROM okc_xprt_rule_eval_result_t
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND condition_id IS NULL;

CURSOR c_rule_conditions(c_rule_id NUMBER) IS
SELECT cond.condition_id, cond.condition_type, cond.rule_expr_type, cond.object_code, cond.object_value_type, cond.object_value_code, cond.cond_operator,
DECODE(cond.condition_type, 'QUESTION', (SELECT value_or_response FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
							   AND object_type = 'QUESTION' AND object_code = cond.object_code),
							   NULL) lhs_response,
DECODE(cond.object_value_type, 'QUESTION', (SELECT value_or_response FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
								    AND object_type = 'QUESTION' AND object_code = cond.object_value_code),
								    NULL) rhs_response
FROM okc_xprt_rule_eval_result_t cond
WHERE cond.doc_id = p_doc_id
AND cond.doc_type = p_doc_type
AND cond.condition_id IS NOT NULL
AND cond.rule_id = c_rule_id;

CURSOR c_dep_rules(c_crules1 OKC_TBL_NUMBER, c_crules2 OKC_TBL_NUMBER) IS
SELECT distinct * FROM table(c_crules1)
UNION
SELECT distinct * FROM table(c_crules2);

success_rule_ids OKC_TBL_NUMBER;
failure_rule_ids OKC_TBL_NUMBER;
reeval_rule_ids OKC_TBL_NUMBER;
clause_rules1 OKC_TBL_NUMBER;
clause_rules2 OKC_TBL_NUMBER;

result_tbl result_tbl_type;
is_rule_evaluated VARCHAR2(1);
has_clauses VARCHAR2(1) := 'N';
l_cond_result BOOLEAN;
i NUMBER := 0;
s NUMBER := 0;
f NUMBER := 0;
rows NUMBER := 0;

l_api_name CONSTANT VARCHAR2(30) := 'evaluate_rules_and_conditions';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	END IF;

	success_rule_ids := OKC_TBL_NUMBER();
	failure_rule_ids := OKC_TBL_NUMBER();
	reeval_rule_ids := OKC_TBL_NUMBER();
	clause_rules1 := OKC_TBL_NUMBER();
	clause_rules2 := OKC_TBL_NUMBER();

	FOR rule IN c_rules LOOP
		is_rule_evaluated := 'N';

		FOR rule_cond IN c_rule_conditions(rule.rule_id) LOOP

			l_cond_result := NULL;

			IF (rule_cond.condition_type = 'CLAUSE' AND (rule_cond.cond_operator = 'IS_NOT' OR rule_cond.cond_operator = 'NOT_IN')) THEN
				l_cond_result := TRUE;

				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110:1 rule_id : ' || rule.rule_id || ' condition_id : ' || rule_cond.condition_id);
				END IF;
			ELSIF ( (rule_cond.condition_type = 'QUESTION' AND rule_cond.lhs_response IS NULL)
				   OR (rule_cond.object_value_type = 'QUESTION' AND rule_cond.rhs_response IS NULL)) THEN
				l_cond_result := NULL;

				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110:2 rule_id : ' || rule.rule_id || ' condition_id : ' || rule_cond.condition_id);
				END IF;
			ELSIF (rule_cond.condition_type = 'QUESTION' AND rule_cond.lhs_response IS NOT NULL) THEN
				l_cond_result := evaluate_condition(rule_cond.condition_id, rule_cond.condition_type, rule_cond.object_code, rule_cond.object_value_type, rule_cond.object_value_code, rule_cond.cond_operator);

				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110:3 rule_id : ' || rule.rule_id || ' condition_id : ' || rule_cond.condition_id);
				END IF;
			ELSIF (rule_cond.condition_type = 'VARIABLE') THEN
				l_cond_result := evaluate_condition(rule_cond.condition_id, rule_cond.condition_type, rule_cond.object_code, rule_cond.object_value_type, rule_cond.object_value_code, rule_cond.cond_operator);

				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110:4 rule_id : ' || rule.rule_id || ' condition_id : ' || rule_cond.condition_id);
				END IF;
			ELSE
				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110:5 rule_id : ' || rule.rule_id || ' condition_id : ' || rule_cond.condition_id);
				END IF;
			END IF;

			IF l_cond_result THEN
				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_cond_result : TRUE');
				END IF;

				i := i + 1;
				result_tbl(i).rule_id := rule.rule_id;
				result_tbl(i).condition_id := rule_cond.condition_id;
				result_tbl(i).result := 'Y';

				IF rule.rule_expr_type = 'ANY' THEN
					i := i + 1;
					result_tbl(i).rule_id := rule.rule_id;
					result_tbl(i).condition_id := null;
					result_tbl(i).result := 'Y';
					is_rule_evaluated := 'Y';
					success_rule_ids.extend(1);
					s := s + 1;
					success_rule_ids(s) := rule.rule_id;
					EXIT;
				END IF;
			ELSIF l_cond_result IS NULL THEN
				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_cond_result : NULL');
				END IF;

				is_rule_evaluated := 'L';   -- atleast one of the rule condition cannot be evaluated now.
			ELSE
				-- if the condition result is false
				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_cond_result : FALSE');
				END IF;

				i := i + 1;
				result_tbl(i).rule_id := rule.rule_id;
				result_tbl(i).condition_id :=  rule_cond.condition_id;
				result_tbl(i).result := 'N';

				IF rule.rule_expr_type = 'ALL' THEN
					i := i + 1;
					result_tbl(i).rule_id := rule.rule_id;
					result_tbl(i).condition_id := null;
					result_tbl(i).result := 'N';
					is_rule_evaluated := 'Y';
					failure_rule_ids.extend(1);
					f := f + 1;
					failure_rule_ids(f) := rule.rule_id;
					EXIT;
				END IF;
			END IF;

		END LOOP;

		IF is_rule_evaluated = 'N' AND rule.rule_expr_type = 'ANY' THEN  --all the condition results are false for this rule
			i := i + 1;
			result_tbl(i).rule_id := rule.rule_id;
			result_tbl(i).condition_id := null;
			result_tbl(i).result := 'N';
			failure_rule_ids.extend(1);
			f := f + 1;
			failure_rule_ids(f) := rule.rule_id;
		END IF;

		IF is_rule_evaluated = 'N' AND rule.rule_expr_type = 'ALL' THEN --all the condition results are success for this rule.
			i := i + 1;
			result_tbl(i).rule_id := rule.rule_id;
			result_tbl(i).condition_id := null;
			result_tbl(i).result := 'Y';
			success_rule_ids.extend(1);
			s := s + 1;
			success_rule_ids(s) := rule.rule_id;
		END IF;
	END LOOP;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: result_tbl.count: ' || result_tbl.count);
		FOR a IN 1 .. result_tbl.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: result_tbl rule_id: ' || result_tbl(a).rule_id || ' condition_id: ' || result_tbl(a).condition_id || ' result: ' || result_tbl(a).result); END LOOP;

		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: success_rule_ids.count: ' || success_rule_ids.count);
		FOR a IN 1 .. success_rule_ids.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: success_rule_id: ' || success_rule_ids(a)); END LOOP;

		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: failure_rule_ids.count: ' || failure_rule_ids.count);
		FOR a IN 1 .. failure_rule_ids.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: failure_rule_id: ' || failure_rule_ids(a)); END LOOP;
	END IF;

    	FORALL k IN 1 .. result_tbl.count
      	UPDATE okc_xprt_rule_eval_result_t result_tmp
      	SET result = result_tbl(k).result
      	WHERE result_tmp.rule_id = result_tbl(k).rule_id
     	AND nvl(result_tmp.condition_id, -999) = nvl(result_tbl(k).condition_id, -999)
      	AND result_tmp.doc_id = p_doc_id
      	AND result_tmp.doc_type = p_doc_type;

  	BEGIN
    		SELECT 'Y' INTO has_clauses FROM dual
    		WHERE EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND condition_type = 'CLAUSE');
 	EXCEPTION
    		WHEN NO_DATA_FOUND THEN
  	NULL;
  	END;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '150: has_clauses: ' || has_clauses);
	END IF;

	--Step I: Additional Questions handling:
	--Updating the display_flag to 'Y' if the rule_id has any additional questions
	--For the first run, update of display_flag to 'N' for failure_rule_ids is not needed, as all additional question are marked as 'N' by default
	IF success_rule_ids.count > 0 THEN
		UPDATE okc_xprt_rule_eval_condval_t
		SET display_flag = 'Y'
		WHERE doc_id = p_doc_id
		AND doc_type = p_doc_type
		AND object_type = 'QUESTION'
		AND display_flag <> 'Y'
		AND object_code IN (SELECT object_value_id FROM okc_xprt_rule_outcomes_act_v WHERE rule_id IN (SELECT * FROM table(success_rule_ids)) and object_type = 'QUESTION');
		rows := sql%rowcount;
		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '160: No. of questions updated with display_flag = Y: ' || rows);
		END IF;
	END IF;

	--Step II: Dependent Clause based conditions handling:
	IF has_clauses = 'Y' THEN
		IF success_rule_ids.count > 0 THEN
			UPDATE okc_xprt_rule_eval_result_t cond
			SET result = decode(cond_operator, 'IS', 'Y', 'IN', 'Y', 'N')
			WHERE doc_id = p_doc_id
			AND doc_type = p_doc_type
			AND condition_type = 'CLAUSE'
			AND ((cond_operator IN ('IS', 'IN') and nvl(result, '*') <> 'Y') OR (cond_operator IN ('IS_NOT', 'NOT_IN') and nvl(result, '*') = 'Y')) --to avoid non-updatable statements
			AND condition_id IN (SELECT distinct dep_clause_cond_id FROM okc_xprt_rule_eval_condval_t WHERE doc_id = cond.doc_id and doc_type = cond.doc_type
					     and object_type = 'RULE' and object_code IN (SELECT * FROM table(success_rule_ids)))
			RETURNING rule_id BULK COLLECT INTO clause_rules1;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '170: No. of clause based conditions updated with result: ' || clause_rules1.count);

				FOR a IN 1 .. clause_rules1.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '170: clause_rules1 rule_id: ' || clause_rules1(a));	END LOOP;
			END IF;
		END IF;

		IF failure_rule_ids.count > 0 THEN
			UPDATE okc_xprt_rule_eval_result_t cond
			SET cond.result = 'N'
			WHERE cond.doc_id = p_doc_id
			AND cond.doc_type = p_doc_type
			AND condition_type = 'CLAUSE'
			AND cond.cond_operator IN ('IS', 'IN') --as the condition result wont change in other cases
			AND cond.result IS NULL --if the result is Y, then it wont change and the result will not be N in any case
			AND cond.condition_id IN (SELECT distinct dep_clause_cond_id FROM okc_xprt_rule_eval_condval_t WHERE doc_id = cond.doc_id and doc_type = cond.doc_type
						  and object_type = 'RULE' and object_code IN (SELECT * FROM table(failure_rule_ids)))
			AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t t, okc_xprt_rule_eval_condval_t d WHERE d.doc_id = cond.doc_id AND d.doc_type = cond.doc_type
					AND d.object_type = 'RULE' AND d.dep_clause_cond_id = cond.condition_id
					AND t.doc_id = d.doc_id AND t.doc_type = d.doc_type AND t.condition_id IS NULL
					AND t.result IS NULL AND d.object_code = t.rule_id)
			RETURNING cond.rule_id BULK COLLECT INTO clause_rules2;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '180: No. of clause based conditions updated with result: ' || clause_rules2.count);

				FOR a IN 1 .. clause_rules2.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '180: clause_rules2 rule_id: ' || clause_rules2(a));	END LOOP;
			END IF;
		END IF;

		--Step III: Finding dependent rules for all the above changes and reevaluating them
		IF clause_rules1.count > 0 OR clause_rules2.count > 0 THEN
			OPEN c_dep_rules(clause_rules1, clause_rules2);
			FETCH c_dep_rules BULK COLLECT INTO reeval_rule_ids;
			CLOSE c_dep_rules;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '190: reeval_rule_ids.count: ' || reeval_rule_ids.count);

				FOR a IN 1 .. reeval_rule_ids.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '190: reeval_rule_ids rule_id: ' || reeval_rule_ids(a)); END LOOP;
			END IF;
		END IF;
	END IF;

  	IF reeval_rule_ids.count > 0 THEN
  		reevaluate_rules(reeval_rule_ids);
  	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '200: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '210: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END evaluate_rules_and_conditions;


FUNCTION op_is RETURN BOOLEAN IS
BEGIN

IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) = rhs_values_tbl(m) THEN
        RETURN TRUE;
      END IF;
    END LOOP;
  END LOOP;
END IF;
  RETURN FALSE;
END op_is;

FUNCTION op_in RETURN  BOOLEAN IS
BEGIN
IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) = rhs_values_tbl(m) THEN
        RETURN TRUE;
      END IF;
    END LOOP;
  END LOOP;
END IF;
  RETURN FALSE;
END op_in;

FUNCTION op_is_not return BOOLEAN IS
BEGIN
IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) = rhs_values_tbl(m) THEN
        RETURN FALSE;
      END IF;
    END LOOP;
  END LOOP;
END IF;
  RETURN TRUE;
END op_is_not;

FUNCTION op_not_in return BOOLEAN IS
BEGIN
IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) = rhs_values_tbl(m) THEN
        RETURN FALSE;
      END IF;
    END LOOP;
  END LOOP;
END IF;
  RETURN TRUE;
END op_not_in;

FUNCTION op_numeric(op VARCHAR2) return BOOLEAN IS
BEGIN
IF op = '<' THEN
IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) < rhs_values_tbl(m) THEN
      RETURN TRUE;
      END IF;
    END LOOP;
  END LOOP;
END IF;
ELSIF op = '>' THEN
IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) > rhs_values_tbl(m) THEN
      	RETURN TRUE;
      END IF;
    END LOOP;
  END LOOP;
END IF;
ELSIF op = '>=' THEN
IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) >= rhs_values_tbl(m) THEN
      	RETURN TRUE;
      END IF;
    END LOOP;
  END LOOP;
END IF;
ELSIF op = '<=' THEN
IF lhs_values_tbl.Count > 0 AND rhs_values_tbl.Count > 0 THEN
  FOR k IN lhs_values_tbl.FIRST..lhs_values_tbl.LAST LOOP
    FOR m IN rhs_values_tbl.FIRST..rhs_values_tbl.LAST LOOP
      IF lhs_values_tbl(k) <= rhs_values_tbl(m) THEN
     	RETURN TRUE;
      END IF;
    END LOOP;
  END LOOP;
END IF;

END IF;
RETURN FALSE;
END op_numeric;

FUNCTION evaluate_condition(p_cond_id NUMBER, p_cond_type VARCHAR2, p_object_code VARCHAR2, p_object_value_type VARCHAR2, p_object_value_code VARCHAR2, p_operator VARCHAR2) RETURN BOOLEAN IS

CURSOR c_lhsvalues IS
SELECT value_or_response
FROM okc_xprt_rule_eval_condval_t
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND object_code = p_object_code
AND object_type = p_cond_type;

-- FOR object_value_type of 'QUESTION', 'CONSTANT', 'VARIABLE'
CURSOR c_rhsvalues IS
SELECT value_or_response
FROM okc_xprt_rule_eval_condval_t
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND object_code = p_object_value_code
AND object_type = p_object_value_type;

--FOR object_value_type of 'VALUE'
CURSOR c_rhsvalues_stored IS
SELECT object_value_code
FROM okc_xprt_rule_cond_vals_act_v
WHERE rule_condition_id = p_cond_id;

l_op_result BOOLEAN := FALSE;

l_api_name CONSTANT VARCHAR2(30) := 'evaluate_condition';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_cond_id : ' || p_cond_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_cond_type : ' || p_cond_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_object_code : ' || p_object_code);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_object_value_type : ' || p_object_value_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_object_value_code : ' || p_object_value_code);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_operator : ' || p_operator);
	END IF;

	OPEN c_lhsvalues;
	FETCH c_lhsvalues BULK COLLECT INTO lhs_values_tbl;
	CLOSE c_lhsvalues;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: No. of lhs values: ' || lhs_values_tbl.count);

		FOR a IN 1 .. lhs_values_tbl.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: lhs value: ' || lhs_values_tbl(a)); END LOOP;
	END IF;

  	IF p_object_value_type = 'VALUE' THEN
    		OPEN c_rhsvalues_stored;
    		FETCH c_rhsvalues_stored BULK COLLECT INTO rhs_values_tbl;
    		CLOSE c_rhsvalues_stored;
  	ELSE
    		OPEN c_rhsvalues;
    		FETCH c_rhsvalues BULK COLLECT INTO rhs_values_tbl;
    		CLOSE c_rhsvalues;
 	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: No. of rhs values: ' || rhs_values_tbl.count);

		FOR a IN 1 .. rhs_values_tbl.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: rhs value: ' || rhs_values_tbl(a)); END LOOP;
	END IF;

	IF p_operator = 'IS' THEN l_op_result := op_is();
	ELSIF p_operator = 'IS_NOT' THEN l_op_result := op_is_not();
	ELSIF p_operator = 'IN' THEN l_op_result := op_in();
	ELSIF p_operator = 'NOT_IN' THEN l_op_result := op_not_in();
	ELSIF p_operator IN ('=') THEN l_op_result := op_is();
	ELSIF p_operator IN ('<>') THEN l_op_result := op_is_not();
	ELSIF p_operator IN ('<=','>=','<','>') THEN l_op_result := op_numeric(p_operator);
	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		IF l_op_result THEN
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: l_op_result: TRUE');
		ELSE
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: l_op_result: FALSE');
		END IF;
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: Leaving method');
	END IF;

	RETURN l_op_result;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '140: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END evaluate_condition;


PROCEDURE reevaluate_rules(reeval_rules OKC_TBL_NUMBER) IS

CURSOR c_dep_rules(c_crules1 OKC_TBL_NUMBER, c_crules2 OKC_TBL_NUMBER, c_crules3 OKC_TBL_NUMBER, c_qrules OKC_TBL_NUMBER) IS
SELECT distinct * FROM table(c_qrules)
UNION
SELECT distinct * FROM table(c_crules1)
UNION
SELECT distinct * FROM table(c_crules2)
UNION
SELECT distinct * FROM table(c_crules3);

new_reevalrule_ids OKC_TBL_NUMBER;
rule_ids1 OKC_TBL_NUMBER;
rule_ids2 OKC_TBL_NUMBER;
rule_ids3 OKC_TBL_NUMBER;
clause_rules1 OKC_TBL_NUMBER;
clause_rules2 OKC_TBL_NUMBER;
clause_rules3 OKC_TBL_NUMBER;
ques_rules OKC_TBL_NUMBER;
question_ids OKC_TBL_NUMBER;
has_clauses VARCHAR2(1) := 'N';
rows1 NUMBER := 0;
rows2 NUMBER := 0;
no_of_questions NUMBER := 0;

i NUMBER := 1;
n NUMBER := 1;
k NUMBER := 1;
l NUMBER := 1;

l_api_name CONSTANT VARCHAR2(30) := 'reevaluate_rules';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: No. of reeval_rules rule_ids: ' || reeval_rules.count);

		FOR a IN 1 .. reeval_rules.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: reeval_rules rule_id: ' || reeval_rules(a)); END LOOP;
	END IF;

	rule_ids1 := OKC_TBL_NUMBER();
	rule_ids2 := OKC_TBL_NUMBER();
	rule_ids3 := OKC_TBL_NUMBER();
	clause_rules1 := OKC_TBL_NUMBER();
	clause_rules2 := OKC_TBL_NUMBER();
	clause_rules3 := OKC_TBL_NUMBER();
	ques_rules := OKC_TBL_NUMBER();
	question_ids := OKC_TBL_NUMBER();
	new_reevalrule_ids := OKC_TBL_NUMBER();
	rule_ids1.extend(reeval_rules.count);
	rule_ids2.extend(reeval_rules.count);
	rule_ids3.extend(reeval_rules.count);

	FOR j IN 1 .. reeval_rules.count LOOP
		UPDATE okc_xprt_rule_eval_result_t result_tmp
		SET result = 'Y'
		WHERE result_tmp.rule_id = reeval_rules(j)
		AND result_tmp.condition_id IS NULL
		AND result_tmp.doc_id = p_doc_id
		AND result_tmp.doc_type = p_doc_type
      		AND nvl(result_tmp.result, '*') <> 'Y'
		AND ((result_tmp.rule_expr_type = 'ALL' AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') <> 'Y'
								      AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								      AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1))
		     OR (result_tmp.rule_expr_type = 'ANY' AND EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') = 'Y'
								      AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								      AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1)))
      		RETURNING n + 1, result_tmp.rule_id INTO n, rule_ids1(n);
		IF SQL%FOUND THEN
			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: No. of rules updated with result = Y based on condition evaluation: ' || (n-1));

				FOR a IN 1 .. rule_ids1.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: rule_ids1 rule_id: ' || rule_ids1(a)); END LOOP;
			END IF;
			continue;
		END IF;


		UPDATE okc_xprt_rule_eval_result_t result_tmp
		SET result = decode(result_tmp.rule_expr_type, 'ANY', (SELECT result FROM (SELECT result FROM okc_xprt_rule_eval_result_t
								      WHERE rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								      AND doc_id = p_doc_id AND doc_type = p_doc_type ORDER BY
								      decode(result, NULL, 1, 2)) WHERE rownum = 1),
							       'ALL', (SELECT result FROM (SELECT result FROM okc_xprt_rule_eval_result_t
								      WHERE rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								      AND doc_id = p_doc_id AND doc_type = p_doc_type ORDER BY
								      decode(result, 'N', 1, NULL, 2, 3)) WHERE rownum = 1))
		WHERE result_tmp.rule_id = reeval_rules(j)
      		AND result_tmp.condition_id IS NULL
		AND result_tmp.doc_id = p_doc_id
		AND result_tmp.doc_type = p_doc_type
      		AND nvl(result_tmp.result, '*') = 'Y'
		AND ((result_tmp.rule_expr_type = 'ALL' AND EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') <> 'Y'
								   AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								   AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1))
		     OR (result_tmp.rule_expr_type = 'ANY' AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') = 'Y'
								      AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								      AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1)))
      		RETURNING k + 1, result_tmp.rule_id INTO k, rule_ids2(k);
		IF SQL%FOUND THEN
			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: No. of rules updated with result based on condition evaluation: ' || (k-1));

				FOR a IN 1 .. rule_ids2.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: rule_ids2 rule_id: ' || rule_ids2(a)); END LOOP;
			END IF;
			continue;
		END IF;

		--there is not need to consider nul to success and failure to success case as they will be already handled in first update statement
		UPDATE okc_xprt_rule_eval_result_t result_tmp
		SET result = decode(result_tmp.rule_expr_type, 'ANY', (SELECT result FROM (SELECT result FROM okc_xprt_rule_eval_result_t
								      WHERE rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								      AND doc_id = p_doc_id AND doc_type = p_doc_type ORDER BY
								      decode(result, NULL, 1, 2)) WHERE rownum = 1),
							       'ALL', (SELECT result FROM (SELECT result FROM okc_xprt_rule_eval_result_t
								      WHERE rule_id = reeval_rules(j) AND condition_id IS NOT NULL
								      AND doc_id = p_doc_id AND doc_type = p_doc_type ORDER BY
								      decode(result, 'N', 1, NULL, 2, 3)) WHERE rownum = 1))
		WHERE result_tmp.rule_id = reeval_rules(j)
      		AND result_tmp.condition_id IS NULL
		AND result_tmp.doc_id = p_doc_id
		AND result_tmp.doc_type = p_doc_type
     		AND nvl(result_tmp.result, '*') <> 'Y'
		AND ((result_tmp.rule_expr_type = 'ALL' AND result_tmp.result IS NULL AND EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') = 'N'
												AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
												AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1))
		     OR (result_tmp.rule_expr_type = 'ALL' AND nvl(result_tmp.result, '*') = 'N' AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') = 'N'
												AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
												AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1))
		     OR (result_tmp.rule_expr_type = 'ANY' AND result_tmp.result IS NULL AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') IS NULL
												AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
												AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1))
		     OR (result_tmp.rule_expr_type = 'ANY' AND nvl(result_tmp.result, '*') = 'N' AND EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE nvl(result, '*') <> 'N'
												AND rule_id = reeval_rules(j) AND condition_id IS NOT NULL
												AND doc_id = p_doc_id AND doc_type = p_doc_type AND rownum = 1)))
      		RETURNING l + 1, result_tmp.rule_id INTO l, rule_ids3(l);
		IF SQL%FOUND THEN
			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: No. of rules updated with result based on condition evaluation: ' || (l-1));

				FOR a IN 1 .. rule_ids3.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: rule_ids3 rule_id: ' || rule_ids3(a)); END LOOP;
			END IF;
			continue;
		END IF;
	END LOOP;

	rule_ids1.trim(reeval_rules.count - (n - 1));
	rule_ids2.trim(reeval_rules.count - (k - 1));
	rule_ids3.trim(reeval_rules.count - (l - 1));

  	BEGIN
    		SELECT 'Y' INTO has_clauses FROM dual
    		WHERE EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND condition_type = 'CLAUSE');
  	EXCEPTION
    		WHEN NO_DATA_FOUND THEN
  		NULL;
  	END;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '150: has_clauses: ' || has_clauses);
	END IF;

---------------------------------------------------------------------------------------------------------------------------------------------------
	--Step I: Additional Questions handling:
	--Updating the display_flag to 'Y' if the rule_id has any additional questions

	--A) rule_ids1--- which have changed their result from null to Y or N to Y
	--updated additional questions display flag to Y if not updated already
	--reevaluation of rule_ids1 is not needed..
	IF rule_ids1.count > 0 THEN
		UPDATE okc_xprt_rule_eval_condval_t
		SET display_flag = 'Y'
		WHERE doc_id = p_doc_id
		AND doc_type = p_doc_type
		AND object_type = 'QUESTION'
		AND display_flag <> 'Y'   --it won't update if it is already Y, so that the rows1 count will not be included if there is no updation
		AND object_code IN (SELECT object_value_id FROM okc_xprt_rule_outcomes_act_v WHERE rule_id IN (SELECT * FROM table(rule_ids1)) and object_type = 'QUESTION');
		rows1 := sql%rowcount;

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '160: No. of additional questions which are getting displayed based on the new rules that are evaluated: ' || rows1);
		END IF;
	END IF;


	--B) rule_ids2--- which have changed their result from Y to N or Y to null
	--updated additional questions display flag to N, if and only if all the the rules with outcome as this question doesnt have their as Y
	--reevaluation of rule_ids2 is needed.. i.e the reason we collect the rule_ids to ques_rules for re-evalaution.
	IF rule_ids2.count > 0 THEN

		FORALL i IN 1 .. rule_ids2.count
			UPDATE okc_xprt_rule_eval_condval_t ques
			SET ques.display_flag = 'N'
			WHERE ques.doc_id = p_doc_id
			AND ques.doc_type = p_doc_type
			AND ques.object_type = 'QUESTION'
			AND ques.display_flag <> 'N'
			AND ques.object_code IN (SELECT object_value_id FROM okc_xprt_rule_outcomes_act_v WHERE rule_id = rule_ids2(i) and object_type = 'QUESTION')
			AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_outcomes_act_v d, okc_xprt_rule_eval_result_t t
					WHERE d.rule_id = t.rule_id AND t.doc_id = ques.doc_id AND t.doc_type = ques.doc_type AND nvl(t.result, '*') = 'Y' AND t.condition_id IS NULL
					AND to_char(d.object_value_id) = ques.object_code AND d.object_type = 'QUESTION');
			IF SQL%FOUND AND rule_ids2.count > 0 THEN
				rows2 := sql%rowcount;
				IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '170: No. of additional questions which will getting displayed from the UI based on the new rules that are evaluated: ' || rows2);
				END IF;
			END IF;


		--updated additional questions response to null, if and only if all the the rules with outcome as this question doesnt have their as Y..
		--if response is made to null from any value then only we need to re-evaluate the rule status that is the reason seperation of updating the
		-- response and display_flag is needed.
		FORALL i IN 1 .. rule_ids2.count
			UPDATE okc_xprt_rule_eval_condval_t ques
			SET ques.value_or_response = NULL
			WHERE ques.doc_id = p_doc_id
			AND ques.doc_type = p_doc_type
			AND ques.object_type = 'QUESTION'
			AND ques.value_or_response IS NOT NULL   --it won't update if it is already NULL, so that re-evaluation of rules for additional questions take place only when it is an actual update
			AND ques.object_code IN (SELECT object_value_id FROM okc_xprt_rule_outcomes_act_v WHERE rule_id = rule_ids2(i) and object_type = 'QUESTION')
			AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_outcomes_act_v d, okc_xprt_rule_eval_result_t t
					WHERE d.rule_id = t.rule_id AND t.doc_id = ques.doc_id AND t.doc_type = ques.doc_type AND nvl(t.result, '*') = 'Y' AND t.condition_id IS NULL
					AND to_char(d.object_value_id) = ques.object_code AND d.object_type = 'QUESTION')
			RETURNING ques.object_code BULK COLLECT INTO question_ids;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '180: No. of additional questions which are updated the result to Y based on the new rules that are evaluated: ' || question_ids.count);

				FOR a IN 1 .. question_ids.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '180: question_ids question_id: ' || question_ids(a)); END LOOP;
			END IF;

		--updating the result of all the conditions to null which contains this additional question
		--question_ids will have unique question ids
		--question_rules can have duplicate rule_ids as it can have two questions updated to result Null so it comes twice in the question_rules
		IF question_ids.count > 0 THEN
			UPDATE okc_xprt_rule_eval_result_t
			SET result = NULL
			WHERE object_code IN (SELECT * FROM table(question_ids))
			AND doc_id = p_doc_id
			AND doc_type = p_doc_type
			AND condition_type = 'QUESTION'
			RETURNING rule_id BULK COLLECT INTO ques_rules;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '190: No. of question based conditions rule_ids which are updated the result to null as the resposne is made to null: ' || ques_rules.count);

				FOR a IN 1 .. ques_rules.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '190: ques_rules rule_id: ' || ques_rules(a)); END LOOP;
			END IF;
		END IF;
	END IF;

	--C) rule_ids3--- which have changed their result from null to N or N to null
	--updation of  additional questions display flag is not required
	--reevaluation of rule_ids3 is not needed..
	IF rows1 > 0 OR rows2 > 0 THEN
		questions_display_changed := 'Y';
	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '200: questions_display_changed: ' || questions_display_changed);
	END IF;

---------------------------------------------------------------------------------------------------------------------------------------------------
	--Step II: Dependent Clause based conditions evaluation:
	--Updating the result of dependent clause based conditions

	--A) rule_ids1--- which have changed their result from null to Y or N to Y
	--updated dependent clause questions display flag to Y if op IN (IS IN) OR N if op IN (IS_NOT NOT_IN)

	IF has_clauses = 'Y' THEN

		--A) rule_ids1--- which have changed their result from null to Y or N to Y
		--updated dependent clause conditions result to Y if op IN (IS,IN) OR N if op IN (IS_NOT,NOT_IN)

		IF rule_ids1.count > 0 THEN
			UPDATE okc_xprt_rule_eval_result_t cond
			SET result = decode(cond_operator, 'IS', 'Y', 'IN', 'Y', 'N')
			WHERE doc_id = p_doc_id
			AND doc_type = p_doc_type
			AND condition_type = 'CLAUSE'
			AND ((cond_operator IN ('IS', 'IN') and nvl(result, '*') <> 'Y') OR (cond_operator IN ('IS_NOT', 'NOT_IN') and nvl(result, '*') = 'Y')) --to avoid non-updatable statements
			AND condition_id IN (SELECT distinct dep_clause_cond_id FROM okc_xprt_rule_eval_condval_t d WHERE d.doc_id = cond.doc_id and d.doc_type = cond.doc_type
					     and d.object_type = 'RULE' and d.object_code IN (SELECT * FROM table(rule_ids1)))
			RETURNING rule_id BULK COLLECT INTO clause_rules1;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '210: No. of clause based questions which are updated the result based on the new rules that are evaluated: ' || clause_rules1.count);

				FOR a IN 1 .. clause_rules1.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '210: clause_rules1 rule_id: ' || clause_rules1(a)); END LOOP;
			END IF;
		END IF;

		--B) rule_ids2--- which have changed their result from Y to N or Y to null
		--updated dependent clause conditions  result by considering all the other rules result

		IF rule_ids2.count > 0 THEN
			UPDATE okc_xprt_rule_eval_result_t cond
			SET cond.result = decode(cond.cond_operator, 'IS_NOT', 'Y', 'NOT_IN', 'Y', decode((SELECT nvl(t.result, 1) FROM okc_xprt_rule_eval_result_t t, okc_xprt_rule_eval_condval_t d
													   WHERE d.doc_id = cond.doc_id and d.doc_type = cond.doc_type AND d.object_type = 'RULE'
													   AND d.dep_clause_cond_id = cond.condition_id AND d.object_code = t.rule_id AND t.doc_id = d.doc_id
													   AND t.doc_type = d.doc_type AND t.condition_id IS NULL AND t.result IS NULL AND ROWNUM = 1),
												           1, NULL, 'N'))
			WHERE cond.doc_id = p_doc_id
			AND cond.doc_type = p_doc_type
			AND condition_type = 'CLAUSE'
			AND cond.condition_id IN (SELECT distinct dep_clause_cond_id FROM okc_xprt_rule_eval_condval_t d WHERE d.doc_id = cond.doc_id AND d.doc_type = cond.doc_type
						  AND d.object_type = 'RULE' AND d.object_code IN (SELECT * FROM table(rule_ids2)))
			AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t t, okc_xprt_rule_eval_condval_t d WHERE d.doc_id = cond.doc_id AND d.doc_type = cond.doc_type
					 AND d.object_type = 'RULE' AND d.dep_clause_cond_id = cond.condition_id AND d.object_code = t.rule_id
					 AND t.doc_id = d.doc_id AND t.doc_type = d.doc_type AND t.condition_id IS NULL AND nvl(t.result, '*') = 'Y')
					 --it their exists a sucess condition, then the result of the rule reamins same i.e T in case of IN,IS operator and F in case of IS_NOT, NOT_IN operator
			RETURNING cond.rule_id BULK COLLECT INTO clause_rules2;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '220: No. of clause based questions which are updated the result based on the new rules that are evaluated: ' || clause_rules2.count);

				FOR a IN 1 .. clause_rules2.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '220: clause_rules2 rule_id: ' || clause_rules2(a)); END LOOP;
			END IF;
		END IF;

		--C) rule_ids3--- which have changed their result from null to N or N to null
		--updated dependent clause conditions  result by considering all the other rules result
		--for this case (null to N or N to null), when the clasue condition operator is IS_NOT or NOT_IN, the condition result wont change
		--for operator 'IS' or 'IN', the result wont change if it is already 'y'

		IF rule_ids3.count > 0 THEN
			UPDATE okc_xprt_rule_eval_result_t cond
			SET cond.result = decode((SELECT nvl(t.result, 1) FROM okc_xprt_rule_eval_result_t t, okc_xprt_rule_eval_condval_t d
						  WHERE d.doc_id = cond.doc_id and d.doc_type = cond.doc_type AND d.object_type = 'RULE'
						  AND d.dep_clause_cond_id = cond.condition_id AND d.object_code = t.rule_id AND t.doc_id = d.doc_id
						  AND t.doc_type = d.doc_type AND t.condition_id IS NULL AND t.result IS NULL AND ROWNUM = 1),
						  1, NULL, 'N')
			WHERE cond.doc_id = p_doc_id
			AND cond.doc_type = p_doc_type
			AND condition_type = 'CLAUSE'
			AND cond.cond_operator IN ('IS', 'IN') --as the condition result wont change in other cases
			AND nvl(cond.result, '*') <> 'Y'  --if the result is already Y, then it wont change
			AND cond.condition_id IN (SELECT distinct dep_clause_cond_id FROM okc_xprt_rule_eval_condval_t d WHERE d.doc_id = cond.doc_id and d.doc_type = cond.doc_type
						  AND d.object_type = 'RULE' and d.object_code IN (SELECT * FROM table(rule_ids3)))
			AND NOT EXISTS (SELECT 1 FROM okc_xprt_rule_eval_result_t t, okc_xprt_rule_eval_condval_t d WHERE d.doc_id = cond.doc_id AND d.doc_type = cond.doc_type
					 AND d.object_type = 'RULE' AND d.dep_clause_cond_id = cond.condition_id AND t.doc_id = d.doc_id
					AND t.doc_type = d.doc_type AND d.object_code = t.rule_id AND t.condition_id IS NULL AND t.result IS NULL AND cond.result IS NULL)
			RETURNING cond.rule_id BULK COLLECT INTO clause_rules3;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '230: No. of clause based questions which are updated the result based on the new rules that are evaluated: ' || clause_rules3.count);

				FOR a IN 1 .. clause_rules3.count LOOP
				FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '230: clause_rules3 rule_id: ' || clause_rules3(a)); END LOOP;
			END IF;
		END IF;

	END IF;
	--clause_rules1 OR clause_rules2 OR clause_rules3 can have duplicate rule_ids as a rule can be updated twice when it have as two clause based conditions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--Step III: Finding dependent rules for all the above changes and reevaluating them
	IF (has_clauses = 'Y' AND (clause_rules1.count > 0 OR clause_rules2.count > 0 OR clause_rules3.count > 0)) OR (ques_rules.count > 0) THEN
		OPEN c_dep_rules(clause_rules1, clause_rules2, clause_rules3, ques_rules);
		FETCH c_dep_rules BULK COLLECT INTO new_reevalrule_ids;
		CLOSE c_dep_rules;
	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '240: No. of rules that have to be re-evaluated based on changes done: ' || new_reevalrule_ids.count);

		FOR a IN 1 .. new_reevalrule_ids.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '240: new_reevalrule_ids rule_id: ' || new_reevalrule_ids(a)); END LOOP;
	END IF;

  	IF new_reevalrule_ids.count > 0 THEN
		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '250: calling reevaluate_rules method.');
		END IF;

  		reevaluate_rules(new_reevalrule_ids);
  	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '260: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '270: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END reevaluate_rules;


FUNCTION evaluate_user_response(doc_id NUMBER, doc_type VARCHAR2, template_id NUMBER, p_question_id VARCHAR2, p_response VARCHAR2) RETURN VARCHAR2 IS

CURSOR c_rule_conditions IS
SELECT rule_id, condition_id, condition_type, rule_expr_type, object_code, cond_operator, result, object_value_type, object_value_code,
(SELECT value_or_response FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
 AND object_type = 'QUESTION' AND object_code = cond.object_code) lhs_response,
DECODE(cond.object_value_type, 'QUESTION', (SELECT value_or_response FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
								    AND object_type = 'QUESTION' AND object_code = cond.object_value_code),
								    NULL) rhs_response
FROM okc_xprt_rule_eval_result_t cond
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND object_code = p_question_id
AND condition_type = 'QUESTION'

UNION

SELECT rule_id, condition_id, condition_type, rule_expr_type, object_code, cond_operator, result, object_value_type, object_value_code,
DECODE(cond.condition_type, 'QUESTION', (SELECT value_or_response FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
							      AND object_type = 'QUESTION' AND object_code = cond.object_code),
							      NULL) lhs_response,
(SELECT value_or_response FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
 AND object_type = 'QUESTION' AND object_code = cond.object_value_code) rhs_response
FROM okc_xprt_rule_eval_result_t cond
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND object_value_code = p_question_id
AND object_value_type = 'QUESTION';

result_tbl result_tbl_type;
rule_ids OKC_TBL_NUMBER;

l_cond_result BOOLEAN;
i NUMBER := 0;

l_api_name CONSTANT VARCHAR2(30) := 'evaluate_user_response';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_id : ' || doc_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_type : ' || doc_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: template_id : ' || template_id);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_question_id : ' || p_question_id);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_response : ' || p_response);
	END IF;

	p_doc_id := doc_id;
	p_doc_type := doc_type;
  	p_template_id := template_id;

	UPDATE okc_xprt_rule_eval_condval_t
	SET value_or_response  = p_response
	WHERE object_code = p_question_id
	AND object_type = 'QUESTION'
 	AND doc_id = p_doc_id
	AND doc_type = p_doc_type;

	questions_display_changed := 'N';
	rule_ids := OKC_TBL_NUMBER();

	IF p_response IS NULL THEN
		FOR rule_cond IN c_rule_conditions LOOP
			--if both lhs and rhs are questions then atleast one of the response should not be null, then only we will ahve a change in the result of the condition
			IF ((rule_cond.condition_type = 'QUESTION' AND rule_cond.object_value_type = 'QUESTION') AND (rule_cond.lhs_response IS NOT NULL OR rule_cond.rhs_response IS NOT NULL)) THEN
				i := i + 1;
				result_tbl(i).rule_id := rule_cond.rule_id;
				result_tbl(i).condition_id := rule_cond.condition_id;
				result_tbl(i).result := NULL;
				rule_ids.extend(1);
				rule_ids(i) := rule_cond.rule_id;
			END IF;
			--if only one of the rhs or lhs is a question then set the result to N of that condition as the response of the question is null
			IF (rule_cond.condition_type <> 'QUESTION' OR rule_cond.object_value_type <> 'QUESTION') THEN
				i := i + 1;
				result_tbl(i).rule_id := rule_cond.rule_id;
				result_tbl(i).condition_id := rule_cond.condition_id;
				result_tbl(i).result := NULL;
				rule_ids.extend(1);
				rule_ids(i) := rule_cond.rule_id;
			END IF;
		END LOOP;
	ELSE
		FOR rule_cond IN c_rule_conditions LOOP
			IF ((rule_cond.condition_type = 'QUESTION' AND rule_cond.object_value_type = 'QUESTION') AND (rule_cond.lhs_response IS NULL OR rule_cond.rhs_response IS NULL)) THEN
				l_cond_result := NULL;
			ELSE
				l_cond_result := evaluate_condition(rule_cond.condition_id, rule_cond.condition_type, rule_cond.object_code, rule_cond.object_value_type, rule_cond.object_value_code, rule_cond.cond_operator);
			END IF;

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: condition_id : ' || rule_cond.condition_id);
				IF l_cond_result IS NULL THEN
		     			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_cond_result : NULL');
				ELSIF l_cond_result THEN
		     			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_cond_result : TRUE');
				ELSE
		     			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_cond_result : FALSE');
				END IF;
			END IF;

			IF l_cond_result IS NULL AND rule_cond.result IS NOT NULL THEN
				i := i + 1;
				result_tbl(i).rule_id := rule_cond.rule_id;
				result_tbl(i).condition_id := rule_cond.condition_id;
				result_tbl(i).result := NULL;
				rule_ids.extend(1);
				rule_ids(i) := rule_cond.rule_id;
			ELSIF l_cond_result = FALSE AND nvl(rule_cond.result, '*') <> 'N' THEN
				i := i + 1;
				result_tbl(i).rule_id := rule_cond.rule_id;
				result_tbl(i).condition_id := rule_cond.condition_id;
				result_tbl(i).result := 'N';
				rule_ids.extend(1);
				rule_ids(i) := rule_cond.rule_id;
			ELSIF l_cond_result = TRUE AND nvl(rule_cond.result, '*') <> 'Y' THEN
				i := i + 1;
				result_tbl(i).rule_id := rule_cond.rule_id;
				result_tbl(i).condition_id := rule_cond.condition_id;
				result_tbl(i).result := 'Y';
				rule_ids.extend(1);
				rule_ids(i) := rule_cond.rule_id;
			END IF;
		END LOOP;
	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: : result_tbl count' || result_tbl.count);

		FOR a IN 1 .. result_tbl.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: result_tbl rule_id: ' || result_tbl(a).rule_id || ' condition_id: ' || result_tbl(a).condition_id || ' result: ' || result_tbl(a).result); END LOOP;
	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: rule_ids count: ' || rule_ids.count);

		FOR a IN 1 .. rule_ids.count LOOP
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '130: rule_ids rule_id: ' || rule_ids(a)); END LOOP;
	END IF;

	FORALL j IN 1 .. result_tbl.count
		UPDATE okc_xprt_rule_eval_result_t result_tmp
		SET result = result_tbl(j).result
		WHERE result_tmp.rule_id = result_tbl(j).rule_id
		AND result_tmp.condition_id = result_tbl(j).condition_id
		AND result_tmp.doc_id = p_doc_id
		AND result_tmp.doc_type = p_doc_type;

	IF result_tbl.count > 0 THEN
		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '140: calling reevaluate_rules method.');
		END IF;
		reevaluate_rules(rule_ids);
	END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '150: questions_display_changed: ' || questions_display_changed);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '150: Leaving method');
	END IF;

	RETURN questions_display_changed;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '160: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END evaluate_user_response;

PROCEDURE save_responses(doc_id IN NUMBER, doc_type IN VARCHAR2, p_lock_xprt_yn IN VARCHAR2, x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_base_table_dtls IS
SELECT orig_system_reference_code, orig_system_reference_id1
FROM okc_template_usages
WHERE document_type = p_doc_type
AND document_id = p_doc_id;

l_src_document_type okc_template_usages.orig_system_reference_code%TYPE;
l_src_document_id okc_template_usages.orig_system_reference_id1%TYPE;
x_msg_data VARCHAR2(2000);
x_msg_count NUMBER;

l_api_name CONSTANT VARCHAR2(30) := 'save_responses';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_id : ' || doc_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_type : ' || doc_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_lock_xprt_yn : ' || p_lock_xprt_yn);
	END IF;

	p_doc_id := doc_id;
	p_doc_type := doc_type;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--concurrent mod changes start
	-- Read the base table details
    	OPEN c_base_table_dtls;
      	FETCH c_base_table_dtls INTO l_src_document_type,l_src_document_id;
    	CLOSE c_base_table_dtls;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_src_document_type: ' || l_src_document_type);
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: l_src_document_id: ' || l_src_document_id);
	END IF;

    	IF p_lock_xprt_yn = 'Y' THEN
     	IF l_src_document_type IS NOT NULL AND l_src_document_id IS NOT NULL THEN
                 -- Lock base table.
                  okc_k_entity_locks_grp.lock_entity
                              ( p_api_version     => 1,
                              p_init_msg_list    => FND_API.G_FALSE ,
                              p_commit           => FND_API.G_FALSE,
                              p_entity_name      => okc_k_entity_locks_grp.G_XPRT_ENTITY,
                              p_entity_pk1       =>  To_Char(l_src_document_id),
                              p_entity_pk2       =>  To_Char(l_src_document_type),
                              p_LOCK_BY_DOCUMENT_TYPE => p_doc_type,
                              p_LOCK_BY_DOCUMENT_ID => p_doc_id,
                              X_RETURN_STATUS => X_RETURN_STATUS,
                              X_MSG_COUNT => X_MSG_COUNT,
                              X_MSG_DATA => X_MSG_DATA
                              );
                --------------------------------------------
                IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
                END IF;
              --------------------------------------------
		ELSE
              NULL;
              -- throw error;
          END IF;
    	END IF; -- p_create_lock_for_xprt = 'Y'
	--concurrent mod chanegs end

	--deleting the responses and copying the new responses into okc_xprt_doc_ques_response table
	DELETE okc_xprt_doc_ques_response WHERE doc_id = p_doc_id AND doc_type = p_doc_type;

	--copying the responses to okc_xprt_doc_ques_response
	INSERT INTO okc_xprt_doc_ques_response (doc_question_response_id, doc_id, doc_type, question_id, response)
	(SELECT OKC_XPRT_DOC_QUES_RESPONSE_S.nextval, p_doc_id, p_doc_type, object_code, value_or_response FROM okc_xprt_rule_eval_condval_t
	 WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND object_type = 'QUESTION' AND display_flag = 'Y');

	--updating contract_expert_finish_flag to N to say that the process of contract expert is not finished
	UPDATE okc_template_usages
	SET contract_expert_finish_flag = 'N'
	WHERE document_id = p_doc_id
	AND document_type = p_doc_type;

	commit;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Commit done');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '120: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '130: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END save_responses;

FUNCTION has_all_questions_answered(doc_id NUMBER, doc_type VARCHAR2) RETURN VARCHAR2 IS

has_all_ques_answered VARCHAR2(1) := 'Y';

l_api_name CONSTANT VARCHAR2(30) := 'has_all_questions_answered';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_id : ' || doc_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_type : ' || doc_type);
	END IF;

	p_doc_id := doc_id;
	p_doc_type := doc_type;

  	BEGIN
    		SELECT 'N' INTO has_all_ques_answered FROM dual
    		WHERE EXISTS (SELECT 1 FROM okc_xprt_rule_eval_condval_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type
				AND object_type = 'QUESTION' AND display_flag = 'Y' AND value_or_response IS NULL);
 	EXCEPTION
    		WHEN NO_DATA_FOUND THEN
  		NULL;
  	END;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: has_all_ques_answered: ' || has_all_ques_answered);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: Leaving method');
	END IF;

	RETURN has_all_ques_answered;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '120: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END has_all_questions_answered;


PROCEDURE create_xprt_responses_version(doc_id IN NUMBER, doc_type IN VARCHAR2, p_major_version IN NUMBER) IS

l_api_name CONSTANT VARCHAR2(30) := 'create_xprt_responses_version';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering create_xprt_responses_version method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_id : ' || doc_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_type : ' || doc_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_major_version : ' || p_major_version);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Saving responses into history table');
	END IF;

	p_doc_id := doc_id;
  	p_doc_type := doc_type;

	--copying the responses to okc_xprt_doc_ques_response_h
	INSERT INTO okc_xprt_doc_ques_response_h (doc_question_response_id, doc_id, doc_type, major_version, question_id, response)
	(SELECT doc_question_response_id, p_doc_id, p_doc_type, p_major_version, question_id, response FROM okc_xprt_doc_ques_response
	 WHERE doc_id = p_doc_id AND doc_type = p_doc_type);

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: no. of rows copied : ' || sql%rowcount);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: Leaving method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '120: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END create_xprt_responses_version;


PROCEDURE restore_xprt_responses_version(doc_id IN NUMBER, doc_type IN VARCHAR2, p_major_version IN NUMBER) IS

l_api_name CONSTANT VARCHAR2(30) := 'restore_xprt_responses_version';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering restore_xprt_responses_version method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_id : ' || doc_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_type : ' || doc_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_major_version : ' || p_major_version);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Restoring responses from history table to the main table');
	END IF;

	p_doc_id := doc_id;
  	p_doc_type := doc_type;

	--copying the responses to okc_xprt_doc_ques_response from okc_xprt_doc_ques_response_h table
	INSERT INTO okc_xprt_doc_ques_response(doc_question_response_id, doc_id, doc_type, question_id, response)
	(SELECT doc_question_response_id, p_doc_id, p_doc_type, question_id, response FROM okc_xprt_doc_ques_response_h
	 WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND major_version = p_major_version);

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: no. of rows copied : ' || sql%rowcount);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: Leaving restore_xprt_responses_version method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '120: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END restore_xprt_responses_version;


PROCEDURE delete_xprt_responses_version(doc_id IN NUMBER, doc_type IN VARCHAR2, p_major_version IN NUMBER) IS

l_api_name CONSTANT VARCHAR2(30) := 'delete_xprt_responses_version';
l_module VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Entering delete_xprt_responses_version method');
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_id : ' || doc_id);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: doc_type : ' || doc_type);
     		FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: p_major_version : ' || p_major_version);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '100: Deleting responses from history table');
	END IF;

	p_doc_id := doc_id;
  	p_doc_type := doc_type;

	--deleting the responses from okc_xprt_doc_ques_response_h history table as the revision is deleted.
	DELETE FROM okc_xprt_doc_ques_response_h
	WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND major_version = p_major_version;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: no. of rows deleted : ' || sql%rowcount);
	     	FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, '110: Leaving delete_xprt_responses_version method');
	END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_module, '120: Exception occured: ' || sqlerrm);
	END IF;
	raise;
END delete_xprt_responses_version;

END OKC_XPRT_RULES_ENGINE_PVT;

/
