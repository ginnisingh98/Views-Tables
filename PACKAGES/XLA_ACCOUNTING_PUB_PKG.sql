--------------------------------------------------------
--  DDL for Package XLA_ACCOUNTING_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCOUNTING_PUB_PKG" AUTHID CURRENT_USER AS
-- $Header: xlaappub.pkh 120.8 2008/01/01 15:22:00 svellani ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_pub_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification for the accounting Prgram that contains public   |
|     APIs.                                                                  |
|                                                                            |
| HISTORY                                                                    |
|     11/08/2002    S. Singhania      Created                                |
|     07/22/2003    S. Singhania      Added NOCOPY hint to the OUT parameters|
|     08/05/2003    S. Singhania      Added P_ENTITY_ID and P_ACCOUNTING_FLAG|
|                                       to ACCOUNTING_PROGRAM_DOCUMENT       |
|     09/22/2003    S. Singhania      Added p_source_application to the API  |
|                                       ACCOUNTING_PROGRAM_BATCH             |
|     10/14/2003    S. Singhania      Added semicolon to the EXIT statement. |
|                                       (Bug # 3165900)                      |
|     04/27/2005    V. Kumar          Bug 4323078. Overloaded the procedure  |
|                                     accounting_program_document            |
+===========================================================================*/

--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_batch
       (p_source_application_id      IN  NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category           IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_accounting_flag            IN  VARCHAR2
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method           IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER);


--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_document
       (p_event_source_info          IN  xla_events_pub_pkg.t_event_source_info
       ,p_application_id             IN  NUMBER      DEFAULT NULL
       ,p_entity_id                  IN  NUMBER
       ,p_accounting_flag            IN  VARCHAR2    DEFAULT 'Y'
       ,p_accounting_mode            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_offline_flag               IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_request_id                 OUT NOCOPY NUMBER);

--============================================================================
--
-- Overloaded with extra valuation_method parameter
--
--============================================================================
PROCEDURE accounting_program_document
       (p_event_source_info          IN  xla_events_pub_pkg.t_event_source_info
       ,p_application_id             IN  NUMBER      DEFAULT NULL
       ,p_valuation_method           IN  VARCHAR2
       ,p_entity_id                  IN  NUMBER
       ,p_accounting_flag            IN  VARCHAR2    DEFAULT 'Y'
       ,p_accounting_mode            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_offline_flag               IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_request_id                 OUT NOCOPY NUMBER);

--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_doc_batch
(p_application_id        IN INTEGER
,p_accounting_mode       IN VARCHAR2
,p_gl_posting_flag       IN VARCHAR2
,p_accounting_batch_id   IN OUT NOCOPY INTEGER
,p_errbuf                IN OUT NOCOPY VARCHAR2
,p_retcode               IN OUT NOCOPY INTEGER
);

--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_events
(p_application_id        IN INTEGER
,p_accounting_mode       IN VARCHAR2
,p_gl_posting_flag       IN VARCHAR2
,p_accounting_batch_id   IN OUT NOCOPY INTEGER
,p_errbuf                IN OUT NOCOPY VARCHAR2
,p_retcode               IN OUT NOCOPY INTEGER
);

FUNCTION is_historic_upgrade_running(p_ledger_id IN NUMBER)
RETURN BOOLEAN;

END xla_accounting_pub_pkg; -- end of package spec.

/
