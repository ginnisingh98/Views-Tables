--------------------------------------------------------
--  DDL for Package XLA_SEQUENCE_DATAFIX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SEQUENCE_DATAFIX_PKG" AUTHID CURRENT_USER AS
-- $Header: xlaseqdf.pkh 120.0 2004/12/17 19:18:50 weshen noship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_SEQUENCE_DATAFIX_PKG                                               |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body for accounting sequence datafix                           |
|                                                                            |
| HISTORY                                                                    |
|     07/06/2004    W. Shen         Created                                  |
+===========================================================================*/


PROCEDURE resequence_acct_seq(p_errbuf           OUT NOCOPY VARCHAR2
                          , p_retcode          OUT NOCOPY NUMBER
                          , p_application_id IN NUMBER
                          , p_ledger_id        IN NUMBER
                          , p_start_date       IN DATE
                          , p_ae_header_id     IN NUMBER
                          , p_period_name      IN VARCHAR2
                          , p_seq_ver_id       IN NUMBER);


END XLA_SEQUENCE_DATAFIX_PKG;


 

/
