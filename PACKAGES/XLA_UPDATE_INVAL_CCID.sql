--------------------------------------------------------
--  DDL for Package XLA_UPDATE_INVAL_CCID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_UPDATE_INVAL_CCID" AUTHID CURRENT_USER AS
/*$Header: xlaudccid.pkh 120.1.12010000.2 2009/08/05 12:41:42 karamakr noship $
============================================================================+
|             COPYRIGHT (C) 2001-2002 ORACLE CORPORATION                     |
|                       REDWOOD SHORES, CA, USA                              |
|                         ALL RIGHTS RESERVED.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_update_inval_ccid                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     PACKAGE BODY FOR Update Invalid CCIDS program                          |
|     This Api Will be called from the Java Layer once the BPEL              |
|     returns the invalid ccids java cp will call this API to Update         |
|     Accounting Entries with the invalid status                             |
|                                                                            |
| HISTORY                                                                    |
|     04/08/2008    Jagan Koduri         CREATED                             |
+===========================================================================*/
TYPE t_array_ccid IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    PROCEDURE xla_update_inval_ccid_api (
        p_accounting_batch_id   IN       NUMBER,
        p_ledger_id             IN       NUMBER,
        p_application_id        IN       NUMBER,
        p_ccid                  IN       t_ccid_table,
        p_status                IN       NUMBER,
        p_err_msg               IN       VARCHAR2
    );


END xla_update_inval_ccid;

/
