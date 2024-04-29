--------------------------------------------------------
--  DDL for Package GR_EURO_CLASSIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_EURO_CLASSIFICATION" AUTHID CURRENT_USER AS
/*$Header: GRPEUROS.pls 115.2 2002/10/30 20:20:10 mgrosser noship $*/

/* Global alpha variable definitions*/

G_PKG_NAME			CONSTANT VARCHAR2(255) := 'GR_EURO_CLASSIFICATION';

G_CURRENT_ITEM			GR_ITEM_GENERAL.item_code%TYPE;
G_INGREDIENT_ITEM		GR_ITEM_CONCENTRATIONS.ingredient_item_code%TYPE;
G_LABEL_CODE			GR_LABELS_B.label_code%TYPE;
G_PROPERTY_ID			GR_ITEM_PROPERTIES.property_id%TYPE;
G_CURRENT_DATE			DATE := sysdate;
G_PRODUCT_CLASS			GR_PRODUCT_CLASSES.product_class%TYPE;

/* Global Numeric Variables */

G_SESSION_ID			NUMBER;
G_USER_ID			NUMBER;
G_ITEM_PRINT_COUNT		NUMBER(5) 	DEFAULT 0;
G_LOGIN				NUMBER;

/* Concurrent Request return values */

G_PRINT_STATUS				BOOLEAN;
G_CONCURRENT_ID				NUMBER;


/* PL/SQL table defined for storing the consolidated safety phrases */
    TYPE cons_safety_phrases IS RECORD
             (combination_group	NUMBER(5),
              safety_string	VARCHAR2(200));

    TYPE l_cons_safety_phrases IS TABLE OF cons_safety_phrases
         INDEX BY BINARY_INTEGER;
    t_cons_safety_phrases	GR_EURO_CLASSIFICATION.l_cons_safety_phrases;

/*  PL/SQL table defined for storing the consolidated risk phrases */
    TYPE cons_risk_phrases IS RECORD
             (combination_group	NUMBER(5),
              risk_string	VARCHAR2(200));

    TYPE l_cons_risk_phrases IS TABLE OF cons_risk_phrases
         INDEX BY BINARY_INTEGER;
    t_cons_risk_phrases	GR_EURO_CLASSIFICATION.l_cons_risk_phrases;

/* PL/SQL table for storing calculations */
    TYPE gr_temp_table IS RECORD
    		(run_total	NUMBER(10),
    		percent		NUMBER(10));

    TYPE l_gr_temp IS TABLE OF gr_temp_table
    	INDEX BY BINARY_INTEGER;
    t_gr_temp_table GR_EURO_CLASSIFICATION.l_gr_temp;

/* Declare Cursors */

/*
** Get the item property information
*/

CURSOR	 g_get_item_properties IS
	  SELECT ip.alpha_value,
	         ip.number_value,
	         ip.date_value,
	         ip.property_id
	  FROM   gr_item_properties ip
	  WHERE  ip.item_code = g_current_item
	  AND    ip.label_code = g_label_code;
GlobalPropertyRecord		g_get_item_properties%ROWTYPE;

/*
** Get the risk phrase information
*/

CURSOR g_get_risk_phrases IS
	SELECT ir.risk_phrase_code,
	       rc.calculation_name_id,
	       rc.linked_risks_flag
	FROM   gr_item_risk_phrases ir,
	       gr_risk_phrases_b rp,
	       gr_risk_calculations rc,
	       gr_item_concentrations ic
	WHERE  ir.item_code = ic.ingredient_item_code
	AND    ir.item_code = g_ingredient_item
	AND    ir.risk_phrase_code = rp.risk_phrase_code
	AND    SUBSTR(ir.risk_phrase_code, 1,3) = rc.risk_phrase_code;
GlobalRiskrecord	g_get_risk_phrases%ROWTYPE;
/*CURSOR g_get_risk_phrases IS
	SELECT ws.risk_phrase_code,
	       rc.calculation_name_id,
	       rc.linked_risks_flag
	FROM   gr_item_risk_phrases ir,
	       gr_risk_phrases_b rp,
	       gr_risk_calculations rc,
	       gr_item_concentrations ic,
	       gr_work_string ws
	WHERE  ir.item_code = ic.ingredient_item_code
	AND    ir.item_code = g_ingredient_item
	AND    ws.session_id = g_session_id
	AND    ws.risk_phrase_code = rp.risk_phrase_code
	AND    ws.risk_phrase_code = rc.risk_phrase_code;

GlobalRiskrecord	g_get_risk_phrases%ROWTYPE;*/
/*
** Get the work classification information - to check if current or ingredient item
*/
CURSOR g_get_classification_work IS
   SELECT wc.hazard_classification_code,
          wc.hazard_group_code,
          wc.calculation_hierarchy
   FROM   gr_work_classns wc
   WHERE  wc.session_id = g_session_id
   AND	  wc.item_code = g_current_item
   ORDER BY wc.hazard_classification_code,
            wc.hazard_group_code;
GlobalClassWorkRecord		g_get_classification_work%ROWTYPE;

/*
** Get the safety work information
*/
CURSOR g_get_safety_work IS
   SELECT safety_phrase_code,
          safety_rule_group,
          safety_category_code,
          category_value
   FROM	  gr_work_safety_phrases wsc
   WHERE  wsc.session_id = g_session_id
   AND	  wsc.item_code = g_current_item
   AND    wsc.assign_flag = 'Y'
   ORDER BY wsc.safety_phrase_code,
            wsc.safety_rule_group;
GlobalSPWorkRecord		g_get_safety_work%ROWTYPE;

/*
** Get the item classifications
*/
CURSOR g_get_item_classn IS
	SELECT ihc.hazard_classification_code,
	       ehb.calculation_hierarchy,
	       ehb.hazard_group_code
	FROM   gr_item_classns ihc,
	       gr_eurohazards_b ehb
	WHERE  ihc.item_code = g_ingredient_item
	AND    ihc.hazard_classification_code =  ehb.hazard_classification_code;
GlobalClassnRecord	g_get_item_classn%ROWTYPE;

/* Check wether the safety phrase exists in the work table */
CURSOR g_exists_work_phrase (V_item_code VARCHAR2, V_safety_phrase VARCHAR2) IS
  SELECT 1
  FROM   dual
  WHERE  EXISTS (SELECT safety_phrase_code
                 FROM   gr_work_safety_phrases
                 WHERE  item_code = V_item_code
                 AND    session_id = g_session_id
                 AND    safety_phrase_code = V_safety_phrase
                 AND    assign_flag = 'Y');

/* Procedure Information */

	   PROCEDURE Classify_Hazard
	   			 (errbuf OUT NOCOPY VARCHAR2,
				  retcode OUT NOCOPY VARCHAR2,
				  p_api_version IN NUMBER,
				  p_init_msg_list IN VARCHAR2,
				  p_commit IN VARCHAR2,
				  p_validation_level IN NUMBER,
				  p_item_to_classify_from IN VARCHAR2,
				  p_item_to_classify_to IN VARCHAR2,
				  p_print_calculations IN VARCHAR2,
				  x_session_id OUT NOCOPY NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);

	   PROCEDURE Assign_Risk_Phrases
	   			 (errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_session_id IN NUMBER,
	   			  p_item_to_classify IN VARCHAR2,
	   			  p_print_calculations IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);

	   PROCEDURE Assign_Safety_Phrases
	   			 (errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_session_id IN NUMBER,
	   			  p_item_to_classify IN VARCHAR2,
	   			  p_print_calculations IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);

	   PROCEDURE Update_Hazard_Classifications
	   			 (errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_init_msg_list IN VARCHAR2,
	   			  p_commit IN VARCHAR2,
	   			  p_validation_level IN NUMBER,
	   			  p_session_id IN NUMBER,
	   			  p_item_to_update IN VARCHAR2,
	   			  p_update_documents IN VARCHAR2,
	   			  p_delete_work IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);

	  PROCEDURE Delete_Work_Data
	   			 (errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_init_msg_list IN VARCHAR2,
	   			  p_commit IN VARCHAR2,
	   			  p_validation_level IN NUMBER,
	   			  p_session_id IN NUMBER,
	   			  p_item_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);

	FUNCTION ITEM_MATCHES_CATEGORY_VALUE(p_item_to_compare IN VARCHAR2,
                                     p_safety_category_code IN VARCHAR2,
                                     p_category_value IN VARCHAR2) RETURN BOOLEAN;

END GR_EURO_CLASSIFICATION;

 

/
