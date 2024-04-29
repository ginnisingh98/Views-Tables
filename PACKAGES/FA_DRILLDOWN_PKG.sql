--------------------------------------------------------
--  DDL for Package FA_DRILLDOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DRILLDOWN_PKG" AUTHID CURRENT_USER as
/* $Header: faddwns.pls 120.2.12010000.2 2009/07/19 11:07:38 glchen ship $   */

PROCEDURE DRILLDOWN
   (p_application_id       IN    INTEGER   DEFAULT NULL,
    p_ledger_id            IN    INTEGER   DEFAULT NULL,
    p_legal_entity_id      IN    INTEGER   DEFAULT NULL,
    p_entity_code          IN    VARCHAR2  DEFAULT NULL,
    p_event_class_code     IN    VARCHAR2  DEFAULT NULL,
    p_event_type_code      IN    VARCHAR2  DEFAULT NULL,
    p_source_id_int_1      IN    INTEGER   DEFAULT NULL,
    p_source_id_int_2      IN    INTEGER   DEFAULT NULL,
    p_source_id_int_3      IN    INTEGER   DEFAULT NULL,
    p_source_id_int_4      IN    INTEGER   DEFAULT NULL,
    p_source_id_char_1     IN    VARCHAR2  DEFAULT NULL,
    p_source_id_char_2     IN    VARCHAR2  DEFAULT NULL,
    p_source_id_char_3     IN    VARCHAR2  DEFAULT NULL,
    p_source_id_char_4     IN    VARCHAR2  DEFAULT NULL,
    p_security_id_int_1    IN    INTEGER   DEFAULT NULL,
    p_security_id_int_2    IN    INTEGER   DEFAULT NULL,
    p_security_id_int_3    IN    INTEGER   DEFAULT NULL,
    p_security_id_char_1   IN    VARCHAR2  DEFAULT NULL,
    p_security_id_char_2   IN    VARCHAR2  DEFAULT NULL,
    p_security_id_char_3   IN    VARCHAR2  DEFAULT NULL,
    p_valuation_method     IN    VARCHAR2  DEFAULT NULL,
    p_user_interface_type  OUT   NOCOPY VARCHAR2,
    p_function_name        OUT   NOCOPY VARCHAR2,
    p_parameters           OUT   NOCOPY VARCHAR2);

END FA_DRILLDOWN_PKG;

/
