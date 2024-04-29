--------------------------------------------------------
--  DDL for Package FII_AR_CASH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_CASH_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIAR08S.pls 120.1 2005/06/13 11:15:38 sgautam noship $ */

---------------------------------------------------
-- PROCEDURE Refresh_Summary
---------------------------------------------------
procedure Refresh_Summary(Errbuf	IN OUT	NOCOPY VARCHAR2,
			  Retcode	IN OUT	NOCOPY VARCHAR2);

End FII_AR_CASH_PKG;

 

/
