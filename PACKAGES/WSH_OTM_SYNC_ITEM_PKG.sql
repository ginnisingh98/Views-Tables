--------------------------------------------------------
--  DDL for Package WSH_OTM_SYNC_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OTM_SYNC_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHTMITS.pls 120.0.12000000.2 2007/03/20 18:47:45 schennal noship $ */

--Record of item
TYPE item_info IS RECORD(
item_id NUMBER,
item_name VARCHAR2(100),
item_description VARCHAR2(240),
last_update_date DATE,
org_id NUMBER
);

--Table of the record item_info
TYPE item_info_tbl IS TABLE OF item_info INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------
--
-- Function	:get_EBS_item_info
-- Parameters	:p_entity_in_rec is the input rec type.
--		It has the entity_type, entity id and parent entity id
--		x_transmission_id Transmission id passed to the caller
--		x_return_status Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
-- Description	:This Function takes input from the txn service and passes
--		the item data back. The item data is passed in the form of
--		of collection WSH_OTM_GLOG_ITEM_TBL thats maps to
--		GLOG Schema ITEMMASTER
-----------------------------------------------------------------------------
FUNCTION get_EBS_item_info(	p_entity_in_rec IN WSH_OTM_ENTITY_REC_TYPE,
				x_transmission_id OUT NOCOPY NUMBER,
				x_return_status OUT NOCOPY VARCHAR2
			) RETURN WSH_OTM_GLOG_ITEM_TBL;


-----------------------------------------------------------------------------
--
-- Procedure	:remove_duplicate_items
-- Parameters	:p_item_tbl is the input table of item_info_tbl.
--		x_return_status Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
-- Description	:This procedure take in the input table and removes all the
--		duplicate rows.
-----------------------------------------------------------------------------
PROCEDURE remove_duplicate_items(p_item_tbl IN OUT NOCOPY item_info_tbl,
				 x_return_status OUT NOCOPY VARCHAR2);

END WSH_OTM_SYNC_ITEM_PKG;

 

/
