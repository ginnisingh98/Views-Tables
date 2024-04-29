--------------------------------------------------------
--  DDL for Package PO_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DRILLDOWN_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: PO_DRILLDOWN_PUB_PKG.pls 120.1.12010000.2 2014/05/29 09:55:58 sbontala ship $ */

  PROCEDURE DRILLDOWN(p_application_id      IN INTEGER,
                      p_ledger_id           IN INTEGER,
                      p_legal_entity_id     IN INTEGER DEFAULT NULL,
                      p_entity_code         IN VARCHAR2,
                      p_event_class_code    IN VARCHAR2,
                      p_event_type_code     IN VARCHAR2,
                      p_source_id_int_1     IN INTEGER DEFAULT NULL,
                      p_source_id_int_2     IN INTEGER DEFAULT NULL,
                      p_source_id_int_3     IN INTEGER DEFAULT NULL,
                      p_source_id_int_4     IN INTEGER DEFAULT NULL,
                      p_source_id_char_1    IN VARCHAR2 DEFAULT NULL,
                      p_source_id_char_2    IN VARCHAR2 DEFAULT NULL,
                      p_source_id_char_3    IN VARCHAR2 DEFAULT NULL,
                      p_source_id_char_4    IN VARCHAR2 DEFAULT NULL,
                      p_security_id_int_1   IN INTEGER DEFAULT NULL,
                      p_security_id_int_2   IN INTEGER DEFAULT NULL,
                      p_security_id_int_3   IN INTEGER DEFAULT NULL,
                      p_security_id_char_1  IN VARCHAR2 DEFAULT NULL,
                      p_security_id_char_2  IN VARCHAR2 DEFAULT NULL,
                      p_security_id_char_3  IN VARCHAR2 DEFAULT NULL,
                      p_valuation_method    IN VARCHAR2 DEFAULT NULL,
                      p_user_interface_type IN OUT NOCOPY VARCHAR2,
                      p_function_name       IN OUT NOCOPY VARCHAR2,
                      p_parameters          IN OUT NOCOPY VARCHAR2);
--<<Bug#18697086  Start>>--
--Added new overloading function passing event Id as extra paramter
-- This is required only in 12.2.4 , but XLA code is same for 12.1\12.2
--branch lines. Hence new procedure is required in 12.1.3 to avoid
-- signature change errors.
PROCEDURE DRILLDOWN(p_application_id      IN INTEGER,
		    p_ledger_id           IN INTEGER,
		    p_legal_entity_id     IN INTEGER DEFAULT NULL,
		    p_entity_code         IN VARCHAR2,
		    p_event_class_code    IN VARCHAR2,
		    p_event_type_code     IN VARCHAR2,
		    p_source_id_int_1     IN INTEGER DEFAULT NULL,
		    p_source_id_int_2     IN INTEGER DEFAULT NULL,
		    p_source_id_int_3     IN INTEGER DEFAULT NULL,
		    p_source_id_int_4     IN INTEGER DEFAULT NULL,
		    p_source_id_char_1    IN VARCHAR2 DEFAULT NULL,
		    p_source_id_char_2    IN VARCHAR2 DEFAULT NULL,
		    p_source_id_char_3    IN VARCHAR2 DEFAULT NULL,
		    p_source_id_char_4    IN VARCHAR2 DEFAULT NULL,
		    p_security_id_int_1   IN INTEGER DEFAULT NULL,
		    p_security_id_int_2   IN INTEGER DEFAULT NULL,
		    p_security_id_int_3   IN INTEGER DEFAULT NULL,
		    p_security_id_char_1  IN VARCHAR2 DEFAULT NULL,
		    p_security_id_char_2  IN VARCHAR2 DEFAULT NULL,
		    p_security_id_char_3  IN VARCHAR2 DEFAULT NULL,
		    p_valuation_method    IN VARCHAR2 DEFAULT NULL,
		    p_event_id            IN INTEGER DEFAULT NULL,
		    p_user_interface_type IN OUT NOCOPY VARCHAR2,
		    p_function_name       IN OUT NOCOPY VARCHAR2,
		    p_parameters          IN OUT NOCOPY VARCHAR2);
--<<Bug#18697086  END>>--

END PO_DRILLDOWN_PUB_PKG;

/
