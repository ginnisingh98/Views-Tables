--------------------------------------------------------
--  DDL for Package Body IGC_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_DRILLDOWN_PUB_PKG" AS
/*$Header: IGCSLADB.pls 120.2.12000000.1 2007/10/25 09:20:03 mbremkum noship $ */

-- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER                := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'IGC.PLSQL.IGC_DRILLDOWN_PUB_PKG.';
-- Logging Infra

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
 |   p_event_type_code    : Event type internal code
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

-- To check whether the application is AP
IF (p_application_id =8407) THEN

 IF(p_event_class_code in ('CC_CONTRACT_PRO','CC_CONTRACT_CMT' )) THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXINWKB';
    p_parameters := ' INVOICE_ID="' ||TO_CHAR(p_source_id_int_1) ||'"'
                  ||' ORG_ID="' ||TO_CHAR(p_security_id_int_1) ||'"';

  ELSIF (p_event_class_code = 'CC_REQUISITIONS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'PO_POXRQVRQ';
    p_parameters := 'FORM_USAGE_MODE = GL_DRILLDOWN POXDOCON_ACCESS=N TRANSACTION_ID = '||to_char(p_source_id_int_1);

  ELSIF (p_event_class_code = 'CC_REQUISITIONS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'PO_POXRQVRQ';
    p_parameters := 'FORM_USAGE_MODE = GL_DRILLDOWN POXDOCON_ACCESS=N TRANSACTION_ID = '||to_char(p_source_id_int_1);

  ELSIF (p_event_class_code = 'CC_PROJECT_BUDGET') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'PA_PAXTRAPE_SINGLE_PROJECT';
    p_parameters := 'FORM_USAGE_MODE="GL_DRILLDOWN"'
          ||' TRANSACTION_ID="' || to_char(p_source_id_int_1)||'"'
          ||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
  ELSE
    p_user_interface_type :='NONE';
  END IF;
END IF;

END DRILLDOWN;

END  IGC_DRILLDOWN_PUB_PKG;

/
