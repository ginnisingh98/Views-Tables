--------------------------------------------------------
--  DDL for Package XLA_REPORTING_SEQUENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_REPORTING_SEQUENCE_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarepseq.pkh 120.0 2004/07/17 00:06:55 weshen noship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_REPORTING_SEQUENCE_PKG                                             |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification for the Accounting Program.                      |
|                                                                            |
| HISTORY                                                                    |
|     16/07/2004    W. Shen         Creation of Package                      |
+===========================================================================*/


FUNCTION period_close (p_subscription_guid IN raw,
                          p_event IN OUT NOCOPY WF_EVENT_T) return varchar2;

FUNCTION period_reopen(p_subscription_guid IN raw,
                          p_event IN OUT NOCOPY WF_EVENT_T) return varchar2;

PROCEDURE reporting_sequence(p_errbuf        OUT NOCOPY VARCHAR2
                          , p_retcode       OUT NOCOPY NUMBER
                          , p_ledger_id    IN NUMBER
                          , p_period_name   IN VARCHAR2
                          , p_mode          IN VARCHAR2);

/*
PROCEDURE assign_sequence(p_ledger_id    IN NUMBER
                          , p_period_name   IN VARCHAR2
                          , p_errbuf        OUT NOCOPY VARCHAR2
                          , p_retcode       OUT NOCOPY NUMBER);
*/


END XLA_REPORTING_SEQUENCE_PKG;


 

/
