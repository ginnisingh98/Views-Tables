--------------------------------------------------------
--  DDL for Package PA_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DRILLDOWN_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXDRPUS.pls 120.1 2005/06/09 03:54:11 lveerubh noship $ */


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
);
END PA_DRILLDOWN_PUB_PKG;

 

/
