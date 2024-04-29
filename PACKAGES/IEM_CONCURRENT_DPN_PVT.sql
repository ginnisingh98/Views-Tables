--------------------------------------------------------
--  DDL for Package IEM_CONCURRENT_DPN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CONCURRENT_DPN_PVT" AUTHID CURRENT_USER as
/* $Header: iemecdps.pls 120.0 2005/08/03 18:47:24 kbeagle noship $*/


PROCEDURE StartProcess(ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT NOCOPY     VARCHAR2,
                       p_period_to_wake_up  NUMBER);


END IEM_CONCURRENT_DPN_PVT;


 

/
