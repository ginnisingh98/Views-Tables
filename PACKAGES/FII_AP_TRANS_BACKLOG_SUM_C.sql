--------------------------------------------------------
--  DDL for Package FII_AP_TRANS_BACKLOG_SUM_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_TRANS_BACKLOG_SUM_C" AUTHID CURRENT_USER AS
/*$Header: FIIAP13S.pls 120.1 2005/06/13 11:11:41 sgautam noship $*/

---------------------------------------------------
-- PROCEDURE Load
---------------------------------------------------
procedure Load(Errbuf IN OUT   NOCOPY VARCHAR2,
                  Retcode   IN OUT   NOCOPY VARCHAR2);

End FII_AP_TRANS_BACKLOG_SUM_C;

 

/
