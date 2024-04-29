--------------------------------------------------------
--  DDL for Package OE_ADV_ITEM_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ADV_ITEM_SEARCH_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVAISS.pls 120.0 2005/06/01 23:07:12 appldev noship $ */

TYPE Ais_Item_Rec IS RECORD
  ( inventory_item_id NUMBER,
    return_status VARCHAR2(1) );

TYPE Ais_Item_Tbl IS TABLE OF Ais_Item_Rec
  INDEX BY BINARY_INTEGER;

PROCEDURE Create_Items_Selected( p_session_id IN NUMBER,
				 p_header_id  IN NUMBER,
				 x_ais_items_tbl OUT NOCOPY /* file.sql.39 change */ ais_item_tbl,
				 x_msg_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
				 x_msg_data OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE delete_selection( p_session_id NUMBER );

PROCEDURE update_used_flag( p_session_id NUMBER );

PROCEDURE insert_unused_session( p_session_id NUMBER );


END OE_ADV_ITEM_SEARCH_PVT;

 

/
