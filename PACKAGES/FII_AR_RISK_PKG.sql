--------------------------------------------------------
--  DDL for Package FII_AR_RISK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_RISK_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIAR09S.pls 120.1 2005/06/13 11:17:14 sgautam noship $ */

---------------------------------------------------
-- PROCEDURE Refresh_Summary
---------------------------------------------------
procedure Refresh_Summary(Errbuf	IN OUT	NOCOPY VARCHAR2,
			  Retcode	IN OUT	NOCOPY VARCHAR2);

End FII_AR_RISK_PKG;

 

/
