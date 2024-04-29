--------------------------------------------------------
--  DDL for Package XLA_ACCOUNTING_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCOUNTING_ENGINE_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajeaex.pkh 120.11 2005/08/02 02:32:27 wychan ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_engine_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     10-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     20-FEB-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     22-JUL-2003 K.Boussema    Added the update of journal entries          |
|     01-DEC-2003 K.Boussema    Added CacheExtractErrors to cache the extract|
|                               errors                                       |
|     03-FEB-2004 K.Boussema    Added CacheExtractObject proc. and changed   |
|                               CacheExtractErrors procedure                 |
|     26-Jul-2004 W. Shen       Add a new parameter to CacheExtractErrors    |
|                                 if it is called from transaction reversal  |
|                                 The line count is 0 or null is not treated |
|                                 as an error.                               |
|                                 bug 3786968.                               |
|     06-Oct-2004 K.Boussema    Made changes for the Accounting Event Extract|
|                               Diagnostics feature.                         |
|     11-Jul-2005 A.Wan         Changd for MPA.  4262811                     |
+===========================================================================*/
--
--
/*======================================================================+
|                                                                       |
| Global Variables                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
--
-- cache the events in error
--
g_array_event_ids                      xla_ae_journal_entry_pkg.t_array_Num;
g_array_event_status                   xla_ae_journal_entry_pkg.t_array_V1L;
--
g_diagnostics_mode                  VARCHAR2(1);
--
/*======================================================================+
|                                                                       |
| PUBLIC Procedure                                                      |
|                                                                       |
|    CacheExtractErrors                                                 |
|                                                                       |
+======================================================================*/
--
PROCEDURE CacheExtractErrors(
                             p_hdr_rowcount      IN NUMBER   DEFAULT NULL
                            ,p_line_rowcount     IN NUMBER   DEFAULT NULL
                            ,p_trx_reversal_flag IN VARCHAR2 DEFAULT NULL
                           )
;
--
/*======================================================================+
|                                                                       |
| PUBLIC Procedure                                                      |
|                                                                       |
|    CacheExtractObjects                                                |
|                                                                       |
+======================================================================*/
--
PROCEDURE CacheExtractObject(
                             p_object_name    IN VARCHAR2
                           , p_object_level   IN VARCHAR2
                           , p_event_class    IN VARCHAR2
                           , p_entity_id      IN NUMBER
                           , p_event_id       IN NUMBER
                           , p_ledger_id      IN NUMBER
                           )
;
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|      AccountingEngine                                                 |
|                                                                       |
|     PARAMETERS                                                        |
|           1  IN  p_application_id       NUMBER   application id       |
|           2  IN  p_ledger_id            NUMBER   ledger id            |
|           3  IN  p_accounting_mode      NUMBER   accounting mode      |
|           4  IN  p_accounting_batch_id  NUMBER   accounting batch id  |
|                                                                       |
|      RETURN NUMBER                                                    |
|           0 - if journal entries created and valid                    |
|           1 - if journal entries created and invalid                  |
|           2 - if no journal entries are created                       |
+======================================================================*/
FUNCTION  AccountingEngine (
                    p_application_id       IN NUMBER
                  , p_ledger_id            IN NUMBER
                  , p_end_date             IN DATE       -- 4262811
                  , p_accounting_mode      IN VARCHAR2
                  , p_accounting_batch_id  IN NUMBER
                  , p_budgetary_control_mode IN VARCHAR2 -- 4458381
                  )
RETURN NUMBER;
--
--
END xla_accounting_engine_pkg; -- end of package spec
 

/
