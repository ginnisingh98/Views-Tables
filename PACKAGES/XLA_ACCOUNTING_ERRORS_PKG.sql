--------------------------------------------------------
--  DDL for Package XLA_ACCOUNTING_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCOUNTING_ERRORS_PKG" AUTHID CURRENT_USER as
/* $Header: xlaaerrs.pkh 120.0.12010000.2 2009/08/13 16:22:11 vkasina noship $ */
/*======================================================================+
 * |             Copyright (c) 2001-2002 Oracle Corporation                |
 * |                       Redwood Shores, CA, USA                         |
 * |                         All rights reserved.                          |
 * +=======================================================================+
 * | PACKAGE NAME                                                          |
 * |    xla_accounting_errors_pkg                                          |
 * |                                                                       |
 * | DESCRIPTION                                                           |
 * |    Enhanced error messages                                            |
 * |                                                                       |
 * | HISTORY                                                               |
 * |    08/12/2009  Vamsi Kasina     Created                               |
 * |                                                                       |
 * +======================================================================*/

  PROCEDURE modify_message
       (p_application_id          IN NUMBER
       ,p_appli_s_name            IN  VARCHAR2
       ,p_msg_name                IN  VARCHAR2
       ,p_token_1                 IN  VARCHAR2
       ,p_value_1                 IN  VARCHAR2
       ,p_token_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_entity_id               IN  NUMBER
       ,p_event_id                IN  NUMBER
       ,p_ledger_id               IN  NUMBER   DEFAULT NULL
       ,p_ae_header_id            IN  NUMBER   DEFAULT NULL
       ,p_ae_line_num             IN  NUMBER   DEFAULT NULL
       ,p_accounting_batch_id     IN  NUMBER   DEFAULT NULL);
end xla_accounting_errors_pkg;

/
