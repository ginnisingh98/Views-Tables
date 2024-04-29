--------------------------------------------------------
--  DDL for Package IBE_INSTALLBASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_INSTALLBASE_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVINSTS.pls 120.1 2005/11/24 04:23:55 cshivaru noship $ */
PROCEDURE Get_Connected_Instances(
			p_instance_id IN NUMBER,
			p_owner_party_id IN NUMBER,
			p_owner_party_account_id IN NUMBER,
			p_key_bind_value IN NUMBER,
			x_parse_key OUT NOCOPY VARCHAR2,
			x_query_inst_id OUT NOCOPY VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY NUMBER,
			x_return_message OUT NOCOPY VARCHAR2
		  );

FUNCTION IS_ITEM_IN_MSITE(
                             p_inventory_item_id IN NUMBER,
                             p_minisite_id IN NUMBER
                         )
RETURN VARCHAR2;

END IBE_INSTALLBASE_PVT;

 

/
