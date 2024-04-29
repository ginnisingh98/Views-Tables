--------------------------------------------------------
--  DDL for Package XLA_PERIOD_CLOSE_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_PERIOD_CLOSE_EXP_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarppcl.pkh 120.9.12010000.3 2009/02/11 11:17:03 svellani ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarppcl.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_period_close_exp_pkg                                               |
|                                                                            |
| DESCRIPTION                                                                |
| This package generates an XML extract for the Period Close Validation      |
| program unit. A dynamic query is created based on the parameters that are  |
| input and data template is used to generate XML. The extract is            |
| called either when the user submits a concurrent request or when a General |
| Ledger Period is closed.                                                   |
|                                                                            |
| HISTORY                                                                    |
|     26/07/2005  VS Koushik            Created                              |
|     15/02/2006  VamsiKrishna Kasina   Changed the package to use           |
|                                       Data Template.                       |
+===========================================================================*/
--
-- To be used in query as bind variable
--

p_application_id                 NUMBER;
p_je_source                      VARCHAR2(80);
p_ledger_id                      NUMBER;
p_ledger                         VARCHAR2(30);
p_period_from                    VARCHAR2(30);
p_period_to                      VARCHAR2(30);
p_dummy_param_1                  NUMBER;
p_event_class                    VARCHAR2(30);
p_event_class_code               VARCHAR2(30);
p_dummy_param_2                  NUMBER;
p_je_category                    VARCHAR2(30);
p_je_category_name               VARCHAR2(30);
p_mode                           VARCHAR2(1);

p_je_source_name                 VARCHAR2(25);
p_object_type_code               VARCHAR2(1);
C_RETURN_CODE                    NUMBER;
--p_trx_identifiers               VARCHAR2(32000):= ' '; commented by preeti/6204675
--added by preeti/6204675
p_trx_identifiers_1                VARCHAR2(32000):= ' ';
p_trx_identifiers_2                VARCHAR2(32000):= ' ';
p_trx_identifiers_3                VARCHAR2(32000):= ' ';
p_trx_identifiers_4                VARCHAR2(32000):= ' ';
p_trx_identifiers_5                VARCHAR2(32000):= ' ';
 -- end preeti/6204675

p_ledger_ids                     VARCHAR2(2000):= ' ';
p_event_filter                   VARCHAR2(2000):= ' ';

p_header_filter                  VARCHAR2(2000):= ' ';
p_je_source_filter               VARCHAR2(2000):= ' ';

C_EVENTS_COLS_QUERY              VARCHAR2(10000):= ' ';

C_EVENTS_FROM_QUERY              VARCHAR2(10000):= ' ';

C_HEADERS_COLS_QUERY             VARCHAR2(10000):= ' ';
C_HEADERS_FROM_QUERY             VARCHAR2(10000):= ' ';

CURSOR period_close_cur_evt(p_application_id NUMBER,p_ledger_id NUMBER,p_period_name VARCHAR2)
IS

SELECT xte.ledger_id            LEDGER_ID,
       xte.source_id_int_1      SOURCE_ID_INT_1,
       xte.security_id_int_1    SECURITY_ID_INT_1,
       xte.entity_code          ENTITY_CODE,
       xte.legal_entity_id      LEGAL_ENTITY_ID,
       xle.event_status_code    EVENT_STATUS_CODE,
       xle.process_status_code  PROCESS_STATUS_CODE,
       xle.application_id       APPLICATION_ID,
       xle.event_id             EVENT_ID,
       xle.event_number         EVENT_NUMBER,
       xle.on_hold_flag         ON_HOLD_FLAG,
       xle.event_type_code      EVENT_TYPE_CODE,
       xle.event_date           EVENT_DATE,
       xte.transaction_number   TRANSACTION_NUMBER,
       xle.last_update_date     LAST_UPDATE_DATE ,
       xle.creation_date        CREATION_DATE,
       xle.transaction_date     TRANSACTION_DATE

FROM   xla_events xle,
       xla_transaction_entities xte,
       xla_ledger_options xlo,
       gl_period_statuses glp
WHERE  xle.entity_id = xte.entity_id
       AND xle.application_id = xte.application_id
       AND xle.event_date BETWEEN glp.start_date
                                  AND glp.end_date
       AND xle.application_id = p_application_id
       AND xle.event_status_code IN ('I',
                                     'U')
       AND xle.process_status_code IN ('I',
                                       'U',
                                       'R',
                                       'D',
                                       'E')
       AND xle.application_id = xlo.application_id
       AND xlo.capture_event_flag = 'Y'
       AND EXISTS (SELECT 1
                   FROM   gl_ledger_relationships glr1,
                          gl_ledger_relationships glr2
                   WHERE  glr1.target_ledger_id = xlo.ledger_id
                          AND glr2.target_ledger_id = p_ledger_id
                          AND glr2.source_ledger_id = glr1.source_ledger_id
                          AND glr2.application_id = glr1.application_id
                          AND (glr1.target_ledger_id = xte.ledger_id
                                OR glr1.primary_ledger_id = xte.ledger_id)
                          AND (glr1.relationship_type_code = 'SUBLEDGER'
                                OR (glr1.target_ledger_category_code = 'PRIMARY'
                                    AND glr1.relationship_type_code = 'NONE'))
                          AND glr2.application_id = 101)
       AND xte.application_id = p_application_id
       AND glp.period_name = p_period_name
       AND glp.ledger_id = p_ledger_id
       AND glp.adjustment_period_flag = 'N'
       AND glp.application_id = p_application_id;

CURSOR period_close_cur_header(p_application_id NUMBER,p_ledger_id NUMBER,p_period_name VARCHAR2)
IS
SELECT aeh.ledger_id           LEDGER_ID,
       aeh.ae_header_id        AE_HEADER_ID,
       xte.source_id_int_1     SOURCE_ID_INT_1,
       xte.entity_code         ENTITY_CODE,
       xte.security_id_int_1   SECURITY_ID_INT_1,
       xte.transaction_number  TRANSACTION_NUMBER,
       xte.legal_entity_id     LEGAL_ENTITY_ID,
       xle.event_type_code     EVENT_TYPE_CODE,
       xle.event_date          EVENT_DATE,
       xle.last_update_date    LAST_UPDATE_DATE ,
       xle.creation_date       CREATION_DATE,
       xle.transaction_date    TRANSACTION_DATE,
       aeh.event_id            EVENT_ID,
       aeh.application_id      APPLICATION_ID,
       aeh.accounting_entry_status_code            ACCOUNTING_ENTRY_STATUS_CODE,
       aeh.gl_transfer_status_code                 GL_TRANSFER_STATUS_CODE
FROM   xla_ae_headers aeh,
       xla_events xle,
       xla_transaction_entities xte,
       gl_period_statuses glp
WHERE  EXISTS (SELECT 1
               FROM   gl_ledger_relationships glr1,
                      gl_ledger_relationships glr2
               WHERE  aeh.ledger_id = glr2.target_ledger_id
                      AND glr2.source_ledger_id = glr1.source_ledger_id
                      AND glr2.application_id = glr1.application_id
                      AND glr1.target_ledger_id = p_ledger_id
                      AND glr1.application_id = 101)
       AND xte.entity_id = aeh.entity_id
       AND xte.application_id = aeh.application_id
       AND aeh.gl_transfer_status_code IN ('N',
                                           'E')
       AND xle.event_status_code = 'P'
       AND xle.event_id = aeh.event_id
       AND xle.application_id = aeh.application_id
       AND aeh.accounting_date BETWEEN glp.start_date
                                       AND glp.end_date
       AND xte.application_id = p_application_id
       AND glp.period_name = p_period_name
       AND glp.ledger_id = p_ledger_id
       AND glp.adjustment_period_flag = 'N'
       AND glp.application_id = p_application_id;



CURSOR period_close_evt_date_cur(p_application_id NUMBER,p_ledger_id NUMBER,p_start_date DATE,p_end_date DATE)
IS

SELECT xte.ledger_id            LEDGER_ID,
       xte.source_id_int_1      SOURCE_ID_INT_1,
       xte.security_id_int_1    SECURITY_ID_INT_1,
       xte.entity_code          ENTITY_CODE,
       xte.legal_entity_id      LEGAL_ENTITY_ID,
       xle.event_status_code    EVENT_STATUS_CODE,
       xle.process_status_code  PROCESS_STATUS_CODE,
       xle.application_id       APPLICATION_ID,
       xle.event_id             EVENT_ID,
       xle.event_number         EVENT_NUMBER,
       xle.on_hold_flag         ON_HOLD_FLAG,
       xle.event_type_code      EVENT_TYPE_CODE,
       xle.event_date           EVENT_DATE,
       xte.transaction_number   TRANSACTION_NUMBER,
       xle.last_update_date     LAST_UPDATE_DATE ,
       xle.creation_date        CREATION_DATE,
       xle.transaction_date     TRANSACTION_DATE

FROM   xla_events xle,
       xla_transaction_entities xte,
       xla_ledger_options xlo
WHERE  xle.entity_id = xte.entity_id
       AND xle.application_id = xte.application_id
       AND xle.event_date BETWEEN p_start_date AND p_end_date
       AND xle.application_id = p_application_id
       AND xle.event_status_code IN ('I',
                                     'U')
       AND xle.process_status_code IN ('I',
                                       'U',
                                       'R',
                                       'D',
                                       'E')
       AND xle.application_id = xlo.application_id
       AND xlo.capture_event_flag = 'Y'
       AND EXISTS (SELECT 1
                   FROM   gl_ledger_relationships glr1,
                          gl_ledger_relationships glr2
                   WHERE  glr1.target_ledger_id = xlo.ledger_id
                          AND glr2.target_ledger_id = p_ledger_id
                          AND glr2.source_ledger_id = glr1.source_ledger_id
                          AND glr2.application_id = glr1.application_id
                          AND (glr1.target_ledger_id = xte.ledger_id
                                OR glr1.primary_ledger_id = xte.ledger_id)
                          AND (glr1.relationship_type_code = 'SUBLEDGER'
                                OR (glr1.target_ledger_category_code = 'PRIMARY'
                                    AND glr1.relationship_type_code = 'NONE'))
                          AND glr2.application_id = 101)
       AND xte.application_id = p_application_id;

CURSOR period_close_hdr_date_cur(p_application_id NUMBER,p_ledger_id NUMBER,p_start_date DATE,p_end_date DATE)
IS
SELECT aeh.ledger_id           LEDGER_ID,
       aeh.ae_header_id        AE_HEADER_ID,
       xte.source_id_int_1     SOURCE_ID_INT_1,
       xte.entity_code         ENTITY_CODE,
       xte.security_id_int_1   SECURITY_ID_INT_1,
       xte.transaction_number  TRANSACTION_NUMBER,
       xte.legal_entity_id     LEGAL_ENTITY_ID,
       xle.event_type_code     EVENT_TYPE_CODE,
       xle.event_date          EVENT_DATE,
       xle.last_update_date    LAST_UPDATE_DATE ,
       xle.creation_date       CREATION_DATE,
       xle.transaction_date    TRANSACTION_DATE,
       aeh.event_id            EVENT_ID,
       aeh.application_id      APPLICATION_ID,
       aeh.accounting_entry_status_code            ACCOUNTING_ENTRY_STATUS_CODE,
       aeh.gl_transfer_status_code                 GL_TRANSFER_STATUS_CODE
FROM   xla_ae_headers aeh,
       xla_events xle,
       xla_transaction_entities xte
WHERE  EXISTS (SELECT 1
               FROM   gl_ledger_relationships glr1,
                      gl_ledger_relationships glr2
               WHERE  aeh.ledger_id = glr2.target_ledger_id
                      AND glr2.source_ledger_id = glr1.source_ledger_id
                      AND glr2.application_id = glr1.application_id
                      AND glr1.target_ledger_id = p_ledger_id
                      AND glr1.application_id = 101)
       AND xte.entity_id = aeh.entity_id
       AND xte.application_id = aeh.application_id
       AND aeh.gl_transfer_status_code IN ('N',
                                           'E')
       AND xle.event_status_code = 'P'
       AND xle.event_id = aeh.event_id
       AND xle.application_id = aeh.application_id
       AND aeh.accounting_date BETWEEN p_start_date AND p_end_date
       AND xte.application_id = p_application_id;


FUNCTION  beforeReport  RETURN BOOLEAN;

FUNCTION  check_period_close(p_application_id   IN NUMBER
                            ,p_period_name      IN VARCHAR2
                            ,p_ledger_id        IN NUMBER) RETURN NUMBER;

END xla_period_close_exp_pkg;

/
