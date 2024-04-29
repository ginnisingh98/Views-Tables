--------------------------------------------------------
--  DDL for Package XLA_ACCOUNTING_DUMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCOUNTING_DUMP_PKG" AUTHID CURRENT_USER AS
-- $Header: xlaapdmp.pkh 120.2 2004/12/20 18:47:30 kboussem noship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_dump_pkg                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification for the Extract Source Values dump               |
|                                                                            |
| HISTORY                                                                    |
|     25/08/2004     K. Boussema     Created                                 |
|     09/12/2004     K. Boussema     Reviewed the concurrent program         |
|                                    parameters                              |
|     20/12/2004     K. Boussema     Reviewed the purge                      |
+===========================================================================*/
--============================================================================
-- PUBLIC PROCEDURE
--    transaction_objects_diag
--
--============================================================================
PROCEDURE transaction_objects_diag
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN NUMBER
       ,p_dummy_parameter_1          IN VARCHAR2
       ,p_ledger_id                  IN NUMBER
       ,p_dummy_parameter_2          IN VARCHAR2
       ,p_event_class_code           IN VARCHAR2
       ,p_dummy_parameter_3          IN VARCHAR2
       ,p_event_type_code            IN VARCHAR2
       ,p_dummy_parameter_4          IN VARCHAR2
       ,p_transaction_number         IN VARCHAR2
       ,p_dummy_parameter_5          IN VARCHAR2
       ,p_event_number               IN NUMBER
       ,p_dummy_parameter_6          IN VARCHAR2
       ,p_from_line_number           IN NUMBER
       ,p_dummy_parameter_7          IN VARCHAR2
       ,p_to_line_number             IN NUMBER
       ,p_request_id                 IN NUMBER
       ,p_errors_only                IN VARCHAR2
       ,p_source_name                IN VARCHAR2
       ,p_acctg_attribute            IN VARCHAR2
)
;

--
--============================================================================
--
-- PUBLIC PROCEDURE
--   acctg_event_extract_log
--
--============================================================================
PROCEDURE acctg_event_extract_log
      ( p_application_id             IN NUMBER
       ,p_request_id                 IN NUMBER)
;

--============================================================================
--
-- PUBLIC PROCEDURE
--     purge
--
--============================================================================
PROCEDURE purge
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN NUMBER
       ,p_up_to_date                 IN DATE
       ,p_request_id                 IN NUMBER
)
;

END xla_accounting_dump_pkg; -- end of package spec.

 

/
