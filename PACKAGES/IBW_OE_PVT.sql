--------------------------------------------------------
--  DDL for Package IBW_OE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_OE_PVT" AUTHID CURRENT_USER AS
/* $Header: IBWOES.pls 120.8 2005/12/29 03:09 rgollapu noship $ */
 VERSION         CONSTANT NUMBER := 1.0;
Procedure offline_engine(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER);
Procedure recategorize_referrals(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER);
PROCEDURE printLog(p_message IN VARCHAR2);
PROCEDURE printOutput(p_message IN VARCHAR2);
PROCEDURE createpage (
   pagecode   IN       VARCHAR2,
   pagename   IN       VARCHAR2,
   url        IN       VARCHAR2,
   appctx     IN       VARCHAR2,
   bizctx     IN       VARCHAR2,
   pageid     OUT      NOCOPY NUMBER
);
PROCEDURE CONTEXT_LOAD;

END IBW_OE_PVT;

 

/
