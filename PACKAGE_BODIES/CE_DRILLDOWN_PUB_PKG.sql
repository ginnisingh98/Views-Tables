--------------------------------------------------------
--  DDL for Package Body CE_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_DRILLDOWN_PUB_PKG" AS
/* $Header: cexladdb.pls 120.2.12010000.1 2009/10/26 23:08:37 vnetan noship $ */

/*---------------------------------------------------------------
|Private procedure: logMessage
+---------------------------------------------------------------*/
PROCEDURE logMessage(log_level in number
                ,module    in varchar2
                ,message   in varchar2)
IS

BEGIN
    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;
END;

/*==========================================================================+
| PROCEDURE:  DRILLDOWN
| COMMENT:    DRILLDOWN procedure provides a public API for XLA to return
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
+==========================================================================*/

PROCEDURE DRILLDOWN
  (p_application_id         IN  INTEGER    DEFAULT NULL
  ,p_ledger_id              IN  INTEGER    DEFAULT NULL
  ,p_legal_entity_id        IN  INTEGER    DEFAULT NULL
  ,p_entity_code            IN  VARCHAR2   DEFAULT NULL
  ,p_event_class_code       IN  VARCHAR2   DEFAULT NULL
  ,p_event_type_code        IN  VARCHAR2   DEFAULT NULL
  ,p_source_id_int_1        IN  INTEGER    DEFAULT NULL
  ,p_source_id_int_2        IN  INTEGER    DEFAULT NULL
  ,p_source_id_int_3        IN  INTEGER    DEFAULT NULL
  ,p_source_id_int_4        IN  INTEGER    DEFAULT NULL
  ,p_source_id_char_1       IN  VARCHAR2   DEFAULT NULL
  ,p_source_id_char_2       IN  VARCHAR2   DEFAULT NULL
  ,p_source_id_char_3       IN  VARCHAR2   DEFAULT NULL
  ,p_source_id_char_4       IN  VARCHAR2   DEFAULT NULL
  ,p_security_id_int_1      IN  INTEGER    DEFAULT NULL
  ,p_security_id_int_2      IN  INTEGER    DEFAULT NULL
  ,p_security_id_int_3      IN  INTEGER    DEFAULT NULL
  ,p_security_id_char_1     IN  VARCHAR2   DEFAULT NULL
  ,p_security_id_char_2     IN  VARCHAR2   DEFAULT NULL
  ,p_security_id_char_3     IN  VARCHAR2   DEFAULT NULL
  ,p_valuation_method       IN  VARCHAR2   DEFAULT NULL
  ,p_user_interface_type    IN  OUT  NOCOPY VARCHAR2
  ,p_function_name          IN  OUT  NOCOPY VARCHAR2
  ,p_parameters             IN  OUT  NOCOPY VARCHAR2)
IS
  l_cashflow_id      VARCHAR2(100);

BEGIN

    logMessage(FND_LOG.level_procedure, 'CE_DRILLDOWN_PUB_PKG', 'DRILLDOWN - BEGIN');
    logMessage(FND_LOG.level_procedure, 'CE_DRILLDOWN_PUB_PKG', 'DRILLDOWN - p_application_id ' || p_application_id);
    logMessage(FND_LOG.level_procedure, 'CE_DRILLDOWN_PUB_PKG', 'DRILLDOWN - cashflow_id ' || p_source_id_int_1);
    logMessage(FND_LOG.level_procedure, 'CE_DRILLDOWN_PUB_PKG', 'DRILLDOWN - p_event_class_code ' || p_event_class_code);
    logMessage(FND_LOG.level_procedure, 'CE_DRILLDOWN_PUB_PKG', 'DRILLDOWN - p_event_type_code ' || p_event_type_code);
    logMessage(FND_LOG.level_procedure, 'CE_DRILLDOWN_PUB_PKG', 'DRILLDOWN - p_entity_code ' || p_entity_code);

    IF (p_application_id = 260)
    THEN
        IF (p_entity_code = 'CE_CASHFLOWS')
        THEN
            l_cashflow_id := TO_CHAR(p_source_id_int_1);
            p_user_interface_type := 'HTML';
            p_parameters := '/OA_HTML/OA.jsp?OAFunc=CE_CASHFLOWS_DETAILS'||
                            '&'||'drillDownCall=Y' ||
                            '&'||'cashflowID='     || l_cashflow_id;
        END IF;
    END IF;
    logMessage(FND_LOG.level_procedure, 'CE_DRILLDOWN_PUB_PKG', 'DRILLDOWN - p_parameters ' || p_parameters);

END DRILLDOWN;

END CE_DRILLDOWN_PUB_PKG;

/
