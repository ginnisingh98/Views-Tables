--------------------------------------------------------
--  DDL for Package AMS_MINISITE_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MINISITE_DENORM_PVT" AUTHID CURRENT_USER as
/* $Header: amsvmsis.pls 120.0 2005/06/01 23:43:53 appldev noship $ */

procedure loadMsitesDenormTable(
	errbuf	 OUT NOCOPY VARCHAR2,
	retcode  OUT NOCOPY NUMBER);
end;

 

/
