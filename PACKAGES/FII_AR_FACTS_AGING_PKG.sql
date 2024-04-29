--------------------------------------------------------
--  DDL for Package FII_AR_FACTS_AGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_FACTS_AGING_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIAR19S.pls 120.0.12000000.1 2007/02/23 02:27:33 applrt ship $ */


-----------------------------------------------------------
--  PROCEDURE COLLECT
-----------------------------------------------------------
Procedure Collect(Errbuf          IN OUT NOCOPY VARCHAR2,
                  Retcode         IN OUT NOCOPY VARCHAR2);

-- ===========================================================================
-- AR DBI Incremental Extraction
-- ===========================================================================

Procedure Inc_Extraction(Errbuf   IN OUT NOCOPY VARCHAR2,
                         Retcode  IN OUT NOCOPY VARCHAR2);

FUNCTION Delete_CashReceipt_Sub (
  p_subscription_guid IN RAW,
  p_event IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2;

END FII_AR_FACTS_AGING_PKG;

 

/
