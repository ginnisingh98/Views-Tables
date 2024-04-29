--------------------------------------------------------
--  DDL for Package IBC_LOAD_CITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_LOAD_CITEMS_PVT" AUTHID CURRENT_USER as
/* $Header: ibcvlcis.pls 120.1 2005/06/24 14:27:37 appldev ship $ */

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_To_Be_Loaded
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Procedure to decide which content items and versions should be
--		   bulkloaded at the start of the Mid-Tier OCM Cache.
--    OUT        : x_content_item_ids	JTF_NUMBER_TABLE
--		   x_citem_version_ids	JTF_NUMBER_TABLE
--		   x_label_codes	JTF_VARCHAR2_TABLE_100
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_To_Be_Loaded (
	x_content_item_ids	OUT NOCOPY    JTF_NUMBER_TABLE,
	x_citem_version_ids	OUT NOCOPY    JTF_NUMBER_TABLE,
	x_label_codes		OUT NOCOPY    JTF_VARCHAR2_TABLE_100
);


END IBC_LOAD_CITEMS_PVT;

 

/
