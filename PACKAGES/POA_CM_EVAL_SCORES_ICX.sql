--------------------------------------------------------
--  DDL for Package POA_CM_EVAL_SCORES_ICX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_CM_EVAL_SCORES_ICX" AUTHID CURRENT_USER AS
/* $Header: POACMSCS.pls 120.0 2005/06/02 00:37:54 appldev noship $ */

TYPE t_criteria_record IS RECORD (
  criteria_code VARCHAR2(25),
  weight	NUMBER,
  min_score	NUMBER,
  max_score	NUMBER
);

TYPE t_scores_record IS RECORD (
  score		NUMBER,
  comments      VARCHAR2(240)
);

TYPE t_eval_record IS RECORD (
  eval_id		NUMBER,
  supplier_site		VARCHAR2(15),
  oper_unit		VARCHAR2(60),
  commodity		VARCHAR2(81),
  item			VARCHAR2(40),
  evaluator		VARCHAR2(100),
  creation_date		DATE,
  last_update_date	DATE
);

TYPE t_header_record IS RECORD (
  custom_measure_code 	VARCHAR2(240),
  custom_measure 	VARCHAR2(240),
  period_type 		VARCHAR2(240),
  user_period_type 	VARCHAR2(240),
  period_name 		VARCHAR2(240),
  supplier_id 		VARCHAR2(240),
  supplier 		VARCHAR2(240),
  supplier_site_id 	VARCHAR2(240),
  supplier_site 	VARCHAR2(240),
  category_id 		VARCHAR2(240),
  commodity 		VARCHAR2(240),
  item_id 		VARCHAR2(240),
  item 			VARCHAR2(240),
  comments 		VARCHAR2(240),
  evaluated_by_id 	VARCHAR2(240),
  evaluated_by 		VARCHAR2(240),
  org_id 		VARCHAR2(240),
  oper_unit_id 		VARCHAR2(240),
  operating_unit 	VARCHAR2(240),
  submit_type	        VARCHAR2(10),
  evaluation_id		VARCHAR2(10)
);

TYPE t_criteria_table IS TABLE OF t_criteria_record INDEX BY BINARY_INTEGER;
TYPE t_scores_table IS TABLE OF t_scores_record INDEX BY BINARY_INTEGER;

PROCEDURE score_entry_page(poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			   poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_period_type	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			   poa_cm_period_name	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
			   poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			   poa_cm_category_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_commodity	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_item_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_item		      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_comments	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			   poa_cm_evaluated_by	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_org_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_oper_unit_id	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_submit_type 	      IN VARCHAR2 DEFAULT NULL,
			   poa_cm_evaluation_id	      IN VARCHAR2 DEFAULT NULL
);

PROCEDURE  Get_Criteria_Info(  p_category_id	  IN NUMBER,
			       p_oper_unit_id	  IN NUMBER,
			       p_table		  IN OUT NOCOPY t_criteria_table);

PROCEDURE redirect_page(poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_name	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
		 	poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			poa_cm_category_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_commodity	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item_id		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_comments		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_org_id	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_oper_unit_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			poa_cm_submit_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluation_id	   IN VARCHAR2 DEFAULT NULL
);

PROCEDURE query_evals(  poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_name	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
		 	poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			poa_cm_category_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_commodity	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item_id		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_comments		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_org_id	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_oper_unit_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			poa_cm_submit_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluation_id	   IN VARCHAR2 DEFAULT NULL
);


END poa_cm_eval_scores_icx;
 

/
