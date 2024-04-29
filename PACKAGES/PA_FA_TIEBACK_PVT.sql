--------------------------------------------------------
--  DDL for Package PA_FA_TIEBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FA_TIEBACK_PVT" AUTHID CURRENT_USER AS
/* $Header: PACFATBS.pls 115.2 2003/08/18 14:31:33 ajdas noship $ */


PROCEDURE ASSETS_TIEBACK
	(errbuf                  OUT NOCOPY VARCHAR2,
    retcode                  OUT NOCOPY VARCHAR2);

END PA_FA_TIEBACK_PVT;

 

/
