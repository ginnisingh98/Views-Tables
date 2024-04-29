--------------------------------------------------------
--  DDL for Package XLA_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCOUNTING_PKG" AUTHID CURRENT_USER AS
-- $Header: xlaapeng.pkh 120.18.12010000.1 2008/07/29 09:58:58 appldev ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification for the Accounting Program.                      |
|                                                                            |
| HISTORY                                                                    |
|     01/03/2003    S. Singhania    Created                                  |
|     01/06/2003    S. Singhania    Added NOCOPY hint to the OUT parameters  |                           |
|     08/05/2003    S. Singhania    Added parameter P_ACCOUNTING_FLAG to     |
|                                     ACCOUNTING_PROGRAM_DOCUMENT            |
|     10/14/2003    S. Singhania    NOTE: THIS IS BASED ON xlaapeng.pkh 116.3|
|     10/14/2003    S. Singhania    Made changes for source application:     |
|                                     - Added p_source_application_id to     |
|                                       ACCOUNTING_PROGRAM_BATCH             |
|                                     - Added routine EVENT_APPLICATION_CP   |
|                                   Added semicolon to the EXIT statement.   |
|                                       (Bug # 3165900)                      |
|     11/24/2003    S. Singhania    Bug 3275659.                             |
|                                     - Added 'p_report_request_id' param to |
|                                       UNIT_PROCESSOR_BATCH                 |
|     12/19/2003    S. Singhania    Modified specs for UNIT_PROCESSOR_BATCH  |
|                                     replaced obsolete p_program_run_id with|
|                                     p_seq_enabled_flag parameter. This is  |
|                                     due to sequencing.                     |
|     01/26/2004    WSHEN           remove 2 parameters from function        |
|                                   unit_processor_batch                     |
|                                      p_extract_procedure                   |
|                                      p_post_processing_procedure           |
|    01/12/2006    V. Kumar         Added parameter to unit_processor_batch  |
|                                      p_transfer_flag and p_gl_posting_flag |
|    08/31/2006    V. Swapna        Bug: 5257343. Add a new parameter to     |
|                                      unit_processor_batch                  |
+===========================================================================*/

TYPE t_array_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_mpa_accrual_exists varchar2(1) := 'N';
g_message            xla_queue_msg_type;
--
-- parametrers
--

g_application_id               PLS_INTEGER;
g_ledger_id                    PLS_INTEGER;
g_process_category             VARCHAR2(30);
g_end_date                     DATE;
g_accounting_flag              VARCHAR2(1);
g_accounting_mode              VARCHAR2(1);
g_error_only_flag              VARCHAR2(1);
g_transfer_flag                VARCHAR2(1);
g_gl_posting_flag              VARCHAR2(1);
g_gl_batch_name                VARCHAR2(240);
g_valuation_method             VARCHAR2(30);
g_security_id_int_1            PLS_INTEGER;
g_security_id_int_2            PLS_INTEGER;
g_security_id_int_3            PLS_INTEGER;
g_security_id_char_1           VARCHAR2(30);
g_security_id_char_2           VARCHAR2(30);
g_security_id_char_3           VARCHAR2(30);

g_security_condition           VARCHAR2(2000);
g_process_category_condition   VARCHAR2(2000);
g_source_appl_condition        VARCHAR2(2000);
g_report_request_id            NUMBER;
g_parent_request_id            NUMBER;

--
-- Bug 5056632
-- The following two arrays store ledger_id and corresponding group_id
-- for transfer to GL purpose
--
g_array_group_id               xla_ae_journal_entry_pkg.t_array_Num;
g_array_ledger_id              xla_ae_journal_entry_pkg.t_array_Num;


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
PROCEDURE event_application_cp
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_source_application_id      IN  NUMBER
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
       ,p_accounting_batch_id        IN  NUMBER
       ,p_report_request_id          IN  NUMBER
       ,p_valuation_method           IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2);


--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_document
       (p_application_id             IN  INTEGER
       ,p_entity_id                  IN  NUMBER
       ,p_accounting_flag            IN  VARCHAR2    DEFAULT 'Y'
       ,p_accounting_mode            IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_offline_flag               IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER);

--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_events
(p_application_id         IN INTEGER
,p_accounting_mode        IN VARCHAR2
,p_gl_posting_flag        IN VARCHAR2
,p_offline_flag           IN VARCHAR2
,p_accounting_batch_id    IN OUT NOCOPY INTEGER
,p_errbuf                 IN OUT NOCOPY VARCHAR2
,p_retcode                IN OUT NOCOPY INTEGER);


--============================================================================
--
--
--
--============================================================================
PROCEDURE unit_processor_batch
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_end_date                   IN  VARCHAR2  -- Bug 5151844
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_accounting_batch_id        IN  NUMBER
       ,p_parent_request_id          IN  NUMBER
       ,p_report_request_id          IN  NUMBER
       ,p_queue_name                 IN  VARCHAR2
       ,p_comp_queue_name            IN  VARCHAR2
       ,p_error_limit                IN  NUMBER
       ,p_seq_enabled_flag           IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2);

END xla_accounting_pkg; -- end of package spec.

/
