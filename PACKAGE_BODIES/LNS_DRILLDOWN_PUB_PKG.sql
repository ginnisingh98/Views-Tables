--------------------------------------------------------
--  DDL for Package Body LNS_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_DRILLDOWN_PUB_PKG" AS
/* $Header: LNS_DRILLDOWN_B.pls 120.1 2006/01/04 13:43:11 raverma noship $*/

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------
 G_DEBUG_COUNT                       NUMBER := 0;
 G_DEBUG                             BOOLEAN := FALSE;
 G_FILE_NAME   CONSTANT VARCHAR2(30) := 'LNS_DRILLDOWN_B.pls';

 G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'LNS_DRILLDOWN_PUB_PKG';
 G_DAYS_COUNT                        NUMBER;
 G_DAYS_IN_YEAR                      NUMBER;

 --------------------------------------------
 -- internal package routines
 --------------------------------------------
procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin

    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

end;

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
  l_function         varchar2(100);
  l_api_name         varchar2(15);
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(32767);
  l_loan_id          varchar2(100);

BEGIN

  l_api_name           := 'DRILLDOWN';
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_id ' || p_source_id_int_1);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_event_class_code ' || p_event_class_code);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_event_type_code ' || p_event_type_code);

  IF (p_application_id = 206) THEN

    IF    (p_entity_code = 'LOANS') THEN
      l_loan_id := TO_CHAR(p_source_id_int_1);
      p_user_interface_type := 'HTML';
      p_parameters := '/OA_HTML/OA.jsp?OAFunc=LNS_ORIG_BASIC_INFO' || '&' || 'loanId=' || l_loan_id;
    END IF;

   END IF;
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_parameters ' || p_parameters);

END DRILLDOWN;

END LNS_DRILLDOWN_PUB_PKG;

/
