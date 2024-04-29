--------------------------------------------------------
--  DDL for Package INV_ITEM_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPISTS.pls 115.1 2002/12/11 10:53:20 mantyaku noship $ */

PROCEDURE Update_Pending_Status (p_api_version   IN   NUMBER
				,p_Org_Id        IN   NUMBER  := NULL
				,p_Item_Id       IN   NUMBER  := NULL
                                ,p_init_msg_list IN   VARCHAR2:=  FND_API.G_FALSE
                                ,p_commit        IN   VARCHAR2:=  FND_API.g_FALSE
				,x_return_status OUT  NOCOPY VARCHAR2
                                ,x_msg_count     OUT  NOCOPY NUMBER
                                ,x_msg_data      OUT  NOCOPY VARCHAR2);

END INV_ITEM_STATUS_PUB;

 

/
