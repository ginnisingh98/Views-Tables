--------------------------------------------------------
--  DDL for Package AMS_CAMPAIGN_ITEMS_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMPAIGN_ITEMS_DENORM_PVT" AUTHID CURRENT_USER as
/* $Header: amsvcpis.pls 115.1 2002/11/25 20:48:06 ryedator ship $ */

procedure loadCampaignItemsDenormTable(
	errbuf	 OUT NOCOPY VARCHAR2,
	retcode  OUT NOCOPY NUMBER);
end;

 

/
