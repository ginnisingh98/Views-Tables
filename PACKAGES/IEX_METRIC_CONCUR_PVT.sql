--------------------------------------------------------
--  DDL for Package IEX_METRIC_CONCUR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_METRIC_CONCUR_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvmtcs.pls 120.3 2006/03/28 16:03:51 jypark noship $ */

PROCEDURE Refresh_All(ERRBUF       OUT NOCOPY VARCHAR2,
                      RETCODE      OUT NOCOPY VARCHAR2,
		      P_ORG_ID     IN NUMBER);

END IEX_METRIC_CONCUR_PVT;

 

/
