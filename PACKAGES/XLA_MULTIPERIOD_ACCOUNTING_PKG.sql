--------------------------------------------------------
--  DDL for Package XLA_MULTIPERIOD_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MULTIPERIOD_ACCOUNTING_PKG" AUTHID CURRENT_USER AS
-- $Header: xlampaac.pkh 120.1 2006/03/29 07:24:38 vkasina noship $
/*===========================================================================+
|             Copyright (c) 2005 Oracle Corporation                          |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_multiperiod_accounting_pkg                                         |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification for the multiperiod accounting prgram.           |
|                                                                            |
| HISTORY                                                                    |
|     05/23/2002    eklau             Created                                |
+===========================================================================*/

--============================================================================
--
--  API which completes incomplete recognition journal entries and
--  accrual reversal journal entries.
--
--============================================================================
PROCEDURE complete_journal_entries
       (p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category_code      IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_errors_only_flag           IN  VARCHAR2
       ,p_transfer_to_gl_flag        IN  VARCHAR2
       ,p_post_in_gl_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method_code      IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER);

END xla_multiperiod_accounting_pkg; -- end of package spec.
 

/
