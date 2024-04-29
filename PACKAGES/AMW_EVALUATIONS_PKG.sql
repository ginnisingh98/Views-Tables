--------------------------------------------------------
--  DDL for Package AMW_EVALUATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_EVALUATIONS_PKG" AUTHID CURRENT_USER as
/*$Header: amwevals.pls 115.8 2004/01/27 01:56:00 kosriniv noship $*/

procedure insert_row (
 p_EVALUATION_SET_ID               IN NUMBER,
 p_EVALUATION_OBJECT_NAME          IN VARCHAR2,
 p_EVALUATION_CONTEXT              IN VARCHAR2,
 p_EVALUATION_TYPE                 IN VARCHAR2,
 -- 12.31.2003 tsho: for bug 3326347
 -- p_DATE_EVALUATED                  IN VARCHAR2,
 p_DATE_EVALUATED                  IN DATE,
 p_PK1_VALUE                       IN VARCHAR2,
 p_PK2_VALUE                       IN VARCHAR2,
 p_PK3_VALUE                       IN VARCHAR2,
 p_PK4_VALUE                       IN VARCHAR2,
 p_PK5_VALUE                       IN VARCHAR2,
 p_ENTERED_BY_ID                   IN NUMBER,
 p_EXECUTED_BY_ID                  IN NUMBER,
 p_COMMENTS			   IN VARCHAR2,
 p_DES_EFF			   IN VARCHAR2,
 p_OP_EFF			   IN VARCHAR2,
 p_OV_EFF			   IN VARCHAR2,
 p_PGMODE			   IN VARCHAR2,
 p_EVALUATION_ID		   IN NUMBER,
 p_commit		           in varchar2 := FND_API.G_FALSE,
 p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
 p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
 x_return_status		   out nocopy varchar2,
 x_msg_count			   out nocopy number,
 x_msg_data			   out nocopy varchar2,
 p_EVALUATION_SET_STATUS_CODE          IN VARCHAR2 := 'P'
);

function get_op_effectiveness(p_evaluation_id IN NUMBER) return varchar2;

function get_des_effectiveness(p_evaluation_id IN NUMBER) return varchar2;

function get_op_effectiveness_code(p_evaluation_id IN NUMBER) return varchar2;

function get_des_effectiveness_code(p_evaluation_id IN NUMBER) return varchar2;

function get_line_conclusion(p_evaluation_id IN NUMBER) return varchar2;

function get_line_conclusion_code(p_evaluation_id IN NUMBER) return varchar2;

function isEvalOwnerOrExecutor(p_evaluation_id IN NUMBER, p_user_id IN NUMBER) return varchar2;

function isEvalExecutorOfAssessment(p_assessment_id IN NUMBER, p_user_id IN NUMBER, p_eval_context IN VARCHAR2) return varchar2;

procedure ADD_LANGUAGE;

end AMW_EVALUATIONS_PKG;

 

/
