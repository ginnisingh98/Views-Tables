--------------------------------------------------------
--  DDL for Package Body PA_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DRILLDOWN_PUB_PKG" 
/* $Header: PAXDRPUB.pls 120.5.12010000.2 2008/08/22 16:16:27 mumohan ship $ */

AS
PROCEDURE DRILLDOWN
(p_application_id 	IN INTEGER
,p_ledger_id 		IN INTEGER
,p_legal_entity_id 	IN INTEGER DEFAULT NULL
,p_entity_code 		IN VARCHAR2
,p_event_class_code 	IN VARCHAR2
,p_event_type_code 	IN VARCHAR2
,p_source_id_int_1 	IN INTEGER DEFAULT NULL
,p_source_id_int_2 	IN INTEGER DEFAULT NULL
,p_source_id_int_3 	IN INTEGER DEFAULT NULL
,p_source_id_int_4 	IN INTEGER DEFAULT NULL
,p_source_id_char_1 	IN VARCHAR2 DEFAULT NULL
,p_source_id_char_2 	IN VARCHAR2 DEFAULT NULL
,p_source_id_char_3 	IN VARCHAR2 DEFAULT NULL
,p_source_id_char_4 	IN VARCHAR2 DEFAULT NULL
,p_security_id_int_1 	IN INTEGER DEFAULT NULL
,p_security_id_int_2 	IN INTEGER DEFAULT NULL
,p_security_id_int_3 	IN INTEGER DEFAULT NULL
,p_security_id_char_1 	IN VARCHAR2 DEFAULT NULL
,p_security_id_char_2 	IN VARCHAR2 DEFAULT NULL
,p_security_id_char_3 	IN VARCHAR2 DEFAULT NULL
,p_valuation_method 	IN VARCHAR2 DEFAULT NULL
,p_user_interface_type  IN OUT NOCOPY VARCHAR2
,p_function_name 	IN OUT NOCOPY VARCHAR2
,p_parameters 		IN OUT NOCOPY VARCHAR2
)
IS

BEGIN
IF (p_application_id = 275) THEN
	IF (p_entity_code = 'EXPENDITURES') THEN
              -- This condition supports drilldown from Accounting Events and Subledger Journal Entry Lines Inquiry to the Expenditure Inquiry form.
	      p_user_interface_type := 'FORM';
	      p_function_name       := 'PA_PAXTRAPE_SINGLE_PROJECT';
	      p_parameters          := 'FORM_USAGE_MODE="GL_DRILLDOWN"'
					||' TRANSACTION_ID="' || to_char(p_source_id_int_1)||'"'
					||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
                        	        --- ||' LEDGER_ID="'||to_char(p_ledger_id)||'"';
	ELSIF (p_event_class_code IN( 'REVENUE','REVENUE_ADJ')) THEN
	   p_user_interface_type := 'FORM';
	   p_function_name 	 := 'PA_PAXRVRVW_DRILLDOWN';
	   p_parameters    	 := 'FORM_USAGE_MODE="GL_DRILLDOWN"'
				||' PROJECT_ID="' ||TO_NUMBER(p_source_id_int_1)||'"'
	   		        ||' DRAFT_REVENUE_NUM="'||TO_NUMBER(p_source_id_int_2)||'"'
				||' ORG_ID="'||to_NUMBER(p_security_id_int_1)||'"';
                               --||' LEDGER_ID_XLA="'||to_char(p_ledger_id)||'"';

	ELSE
		p_user_interface_type := 'NONE';
	END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN
null;
END DRILLDOWN;
END PA_DRILLDOWN_PUB_PKG;

/
