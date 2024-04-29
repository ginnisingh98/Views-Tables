--------------------------------------------------------
--  DDL for Package Body IBC_LOAD_CITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_LOAD_CITEMS_PVT" as
/* $Header: ibcvlcib.pls 120.1 2005/06/24 14:28:27 appldev ship $ */

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_To_Be_Loaded
--    Type       : Private
--    Pre-reqs   : None
--    Function   : This implementation will return all the associated content items.
--		   In addition to these content items' live version, all their labelled
--                 versions would also be returned.
--    OUT        : x_content_item_ids	JTF_NUMBER_TABLE
--		   x_citem_version_ids	JTF_NUMBER_TABLE
--		   x_label_codes	JTF_VARCHAR2_TABLE_100
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_To_Be_Loaded (
	x_content_item_ids	OUT NOCOPY	JTF_NUMBER_TABLE,
	x_citem_version_ids	OUT NOCOPY	JTF_NUMBER_TABLE,
	x_label_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100
) AS
	CURSOR Get_Citems IS
	SELECT content_item_id, citem_version_id, label_code
	FROM ibc_citem_version_labels
	WHERE content_item_id IN (select distinct a.CONTENT_ITEM_ID
                          from ibc_associations a, ibc_content_items c
                          where a.content_item_id = c.content_item_id
                          and c.content_item_status = 'APPROVED'
                          and c.WD_RESTRICTED_FLAG = 'F'
                          and c.LIVE_CITEM_VERSION_ID IS NOT NULL)
	AND ROWID IN (SELECT MAX(ROWID)
              FROM ibc_citem_version_labels
              GROUP BY content_item_id, citem_version_id)
	UNION
	SELECT a.*
	FROM (select distinct a.CONTENT_ITEM_ID, c.live_citem_version_id as citem_version_id,
	      NULL as label_code
	from ibc_associations a, ibc_content_items c
	where a.content_item_id = c.content_item_id
	and c.content_item_status = 'APPROVED'
	and c.WD_RESTRICTED_FLAG = 'F'
	and c.LIVE_CITEM_VERSION_ID IS NOT NULL) a
	WHERE NOT EXISTS (SELECT NULL
	FROM  ibc_citem_version_labels b
	WHERE b.citem_version_id = a.citem_version_id);

BEGIN
	OPEN Get_Citems;
	   FETCH Get_Citems BULK COLLECT INTO x_content_item_ids, x_citem_version_ids, x_label_codes;
	CLOSE Get_Citems;

END Get_Citems_To_Be_Loaded;




END IBC_LOAD_CITEMS_PVT;

/
