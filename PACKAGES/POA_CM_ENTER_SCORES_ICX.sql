--------------------------------------------------------
--  DDL for Package POA_CM_ENTER_SCORES_ICX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_CM_ENTER_SCORES_ICX" AUTHID CURRENT_USER AS
/* $Header: POACMINS.pls 120.0 2005/06/01 20:00:53 appldev noship $ */

TYPE t_text_table is table of varchar2(240) index by binary_integer;

PROCEDURE insert_scores(criteria_code	IN t_text_table,
			score		IN t_text_table,
			weight		IN t_text_table,
			weighted_score  IN t_text_table,
			min_score	IN t_text_table,
			max_score	IN t_text_table,
			comments	IN t_text_table,
			total_score	IN VARCHAR2,
			poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
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

PROCEDURE redirect_page(criteria_code	IN t_text_table,
			score		IN t_text_table,
			weight		IN t_text_table,
			weighted_score  IN t_text_table,
			min_score	IN t_text_table,
			max_score	IN t_text_table,
			comments	IN t_text_table,
			total_score	IN VARCHAR2,
			poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
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


END poa_cm_enter_scores_icx;
 

/
