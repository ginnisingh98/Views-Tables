--------------------------------------------------------
--  DDL for Package Body FV_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_DRILLDOWN_PUB_PKG" as
--$Header: fvsladrb.pls 120.2.12010000.2 2008/12/05 10:05:05 bnarang ship $
/*========================================================================
 | PROCEDURE:  DRILLDOWN
 | COMMENT:    DRILLDOWN procedure provides a public API for sla to return
 |             the appropriate information via OUT parameters to open the
 |             appropriate transaction form.
 | PARAMETERS:
 |   p_application_id     : Subledger application internal identifier
 |   p_ledger_id          : Event ledger identifier
 |   p_legal_entity_id    : Legal entity identifier
 |   p_entity_code        : Event entity internal code
 |   p_event_class_code   : Event class internal code
 |   p_event_type_code    : Event type internal codess
 |   p_source_id_int_1    : Generic system transaction identifiers
 |   p_source_id_int_2    : Generic system transaction identifiers
 |   p_source_id_int_3    : Generic system transaction identifiers
 |   p_source_id_int_4    : Generic system transaction identifiers
 |   p_source_id_char_1   : Generic system transaction identifiers
 |   p_source_id_char_2   : Generic system transaction identifiers
 |   p_source_id_char_3   : Generic system transaction identifiers
 |   p_source_id_char_4   : Generic system transaction identifiers
 |   p_security_id_int_1  : Generic system transaction identifiers
 |   p_security_id_int_2  : Generic system transaction identifiers
 |   p_security_id_int_3  : Generic system transaction identifiers
 |   p_security_id_char_1 : Generic system transaction identifiers
 |   p_security_id_char_2 : Generic system transaction identifiers
 |   p_security_id_char_3 : Generic system transaction identifiers
 |   p_valuation_method   : Valuation Method internal identifier
 |   p_user_interface_type: This parameter determines the user interface type.
 |                          The possible values are FORM, HTML, or NONE.
 |   p_function_name      : The name of the Oracle Application Object
 |                          Library function defined to open the transaction
 |                          form. This parameter is used only if the page
 |                          is a FORM page.
 |   p_parameters         : An Oracle Application Object Library Function
 |                          can have its own arguments/parameters. SLA
 |                          expects developers to return these arguments via
 |                          p_parameters.
 |
 +===========================================================================*/

PROCEDURE DRILLDOWN
(p_application_id      IN            INTEGER
,p_ledger_id           IN            INTEGER
,p_legal_entity_id     IN            INTEGER DEFAULT NULL
,p_entity_code         IN            VARCHAR2
,p_event_class_code    IN            VARCHAR2
,p_event_type_code     IN            VARCHAR2
,p_source_id_int_1     IN            INTEGER DEFAULT NULL
,p_source_id_int_2     IN            INTEGER DEFAULT NULL
,p_source_id_int_3     IN            INTEGER DEFAULT NULL
,p_source_id_int_4     IN            INTEGER DEFAULT NULL
,p_source_id_char_1    IN            VARCHAR2 DEFAULT NULL
,p_source_id_char_2    IN            VARCHAR2 DEFAULT NULL
,p_source_id_char_3    IN            VARCHAR2 DEFAULT NULL
,p_source_id_char_4    IN            VARCHAR2 DEFAULT NULL
,p_security_id_int_1   IN            INTEGER DEFAULT NULL
,p_security_id_int_2   IN            INTEGER DEFAULT NULL
,p_security_id_int_3   IN            INTEGER DEFAULT NULL
,p_security_id_char_1  IN            VARCHAR2 DEFAULT NULL
,p_security_id_char_2  IN            VARCHAR2 DEFAULT NULL
,p_security_id_char_3  IN            VARCHAR2 DEFAULT NULL
,p_valuation_method    IN            VARCHAR2 DEFAULT NULL
,p_user_interface_type IN OUT NOCOPY VARCHAR2
,p_function_name       IN OUT NOCOPY VARCHAR2
,p_parameters          IN OUT NOCOPY VARCHAR2)

IS

BEGIN

-- To check whether the application
IF (p_application_id =8901) THEN
 IF(p_event_class_code = 'TREASURY_ACCOMPLISHMENT') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_FVXRTCRF';
    p_parameters := ' TREASURY_CONFIRMATION_ID="' ||TO_CHAR(p_source_id_int_1)
                    ||'" FORM_USAGE_MODE="GL_DRILLDOWN" ';
 ELSIF(p_event_class_code = 'BUDGET_EXECUTION') THEN
   IF (p_event_type_code = 'BA_RESERVE') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'FV_FVXBEAPR';
    p_parameters := ' QUERY_ONLY=Y" DOC_ID="' ||TO_CHAR(p_source_id_int_1)
                      ||'" FORM_USAGE_MODE="GL_DRILLDOWN" ';
   ELSIF (p_event_type_code = 'FD_RESERVE') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'FV_FVXBEDFD';
    p_parameters := ' QUERY_ONLY=Y" DOC_ID="' ||TO_CHAR(p_source_id_int_1)
                     ||'" FORM_USAGE_MODE="GL_DRILLDOWN" ';
   END IF;
 ELSIF(p_event_class_code = 'RPR_BUDGET_EXECUTION') THEN
   IF (p_event_type_code IN ('RPR_BA_RESERVE', 'RPR_FD_RESERVE'))  THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'FV_FVXBERPR';
    p_parameters := ' QUERY_ONLY=Y" TRANSACTION_ID="'||TO_CHAR(p_source_id_int_1)
                    ||'" FORM_USAGE_MODE="GL_DRILLDOWN" ';
   END IF;

  ELSE
    p_user_interface_type :='NONE';
  END IF;
END IF;

END DRILLDOWN;
END FV_DRILLDOWN_PUB_PKG;


/
