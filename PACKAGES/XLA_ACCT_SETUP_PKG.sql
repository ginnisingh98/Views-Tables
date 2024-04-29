--------------------------------------------------------
--  DDL for Package XLA_ACCT_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCT_SETUP_PKG" AUTHID CURRENT_USER AS
-- $Header: xlasuaoi.pkh 120.4 2004/06/17 18:52:26 sasingha ship $
/*===========================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|    xla_acct_setup_pkg                                                      |
|                                                                            |
| DESCRIPTION                                                                |
|    XLA Accounting Options Setup api                                        |
|                                                                            |
| HISTORY                                                                    |
|    06-Feb-03 Dimple Shah    Created                                        |
|    28-Sep-03 S. Singhania   Added APIs to support 'event class setup'      |
|                               bug # 3151792:                               |
|                               - PERFORM_EVENT_CLASS_SETUP                  |
|                               - DELETE_EVENT_CLASS_SETUP                   |
|    10-Dec-03 S. Singhania   Added the API PERFORM_APPLICATION_SETUP_CP for |
|                               the concurrent program. (Bug 3229146).       |
|    17-Jun-04 S. Singhania   Added UPGRADE_LEDGER_OPTIONS API for AX upgrade|
+===========================================================================*/

--=============================================================================
-- Public Procedure
-- setup_ledger_options
-- Sets up options for a ledger for all applications
--=============================================================================
PROCEDURE setup_ledger_options
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER);

--=============================================================================
-- Public Procedure
-- check_acctg_method_for_ledger
-- Checks if the accounting method is valid for a ledger
--=============================================================================
PROCEDURE check_acctg_method_for_ledger
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER);

PROCEDURE perform_event_class_setup
       (p_application_id             IN NUMBER
       ,p_event_class_code           IN VARCHAR2);

PROCEDURE delete_event_class_setup
       (p_application_id             IN NUMBER
       ,p_event_class_code           IN VARCHAR2);

PROCEDURE perform_application_setup_cp
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN  NUMBER);

--=============================================================================
-- Public Procedure
-- for upgrade of AX.
--=============================================================================
PROCEDURE upgrade_ledger_options
       (p_application_id                    IN NUMBER
       ,p_ledger_id                         IN NUMBER
       ,p_acct_mode_code                    IN VARCHAR2
       ,p_acct_mode_override_flag           IN VARCHAR2
       ,p_summary_report_flag               IN VARCHAR2
       ,p_summary_report_override_flag      IN VARCHAR2
       ,p_submit_xfer_to_gl_flag            IN VARCHAR2
       ,p_submit_xfer_override_flag         IN VARCHAR2
       ,p_submit_gl_post_flag               IN VARCHAR2
       ,p_submit_gl_post_override_flag      IN VARCHAR2
       ,p_stop_on_error                     IN VARCHAR2
       ,p_error_limit                       IN NUMBER
       ,p_processes                         IN NUMBER
       ,p_processing_unit_size              IN NUMBER
       ,p_transfer_to_gl_mode_code          IN VARCHAR2
       ,p_acct_reversal_option_code         IN VARCHAR2);

END xla_acct_setup_pkg;
 

/
