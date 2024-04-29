--------------------------------------------------------
--  DDL for Package IEM_CONCURRENT_WRAP_DPN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CONCURRENT_WRAP_DPN_PVT" AUTHID CURRENT_USER as
/* $Header: iemdpwps.pls 120.0 2005/08/08 18:30:51 kbeagle noship $*/


PROCEDURE LaunchProcess(ERRBUF   OUT NOCOPY     VARCHAR2,
                        RETCODE  OUT NOCOPY     VARCHAR2);


END IEM_CONCURRENT_WRAP_DPN_PVT;


 

/
