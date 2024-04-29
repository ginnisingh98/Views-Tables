--------------------------------------------------------
--  DDL for Package XLA_IGI_ACCT_HOOKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_IGI_ACCT_HOOKS_PKG" AUTHID CURRENT_USER AS
/*$Header: xlaapigh.pkh 120.0.12000000.1 2007/10/24 14:04:56 samejain noship $*/
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_igi_acct_hooks_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Call accounting program integration APIs for IGI                       |
|                                                                            |
| HISTORY                                                                    |
|     08/30/2007    S.Jain              Created                              |
|                                                                            |
+===========================================================================*/

PROCEDURE main
       (p_application_id           IN NUMBER
       ,p_ledger_id                IN NUMBER
       ,p_process_category         IN VARCHAR2
       ,p_end_date                 IN DATE
       ,p_accounting_mode          IN VARCHAR2
       ,p_valuation_method         IN VARCHAR2
       ,p_security_id_int_1        IN NUMBER
       ,p_security_id_int_2        IN NUMBER
       ,p_security_id_int_3        IN NUMBER
       ,p_security_id_char_1       IN VARCHAR2
       ,p_security_id_char_2       IN VARCHAR2
       ,p_security_id_char_3       IN VARCHAR2
       ,p_report_request_id        IN NUMBER
       ,p_event_name               IN VARCHAR2);

END xla_igi_acct_hooks_pkg; -- end of package spec.

 

/
