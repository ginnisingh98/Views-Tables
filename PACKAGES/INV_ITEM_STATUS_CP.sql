--------------------------------------------------------
--  DDL for Package INV_ITEM_STATUS_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_STATUS_CP" AUTHID CURRENT_USER AS
/* $Header: INVCIPSS.pls 120.0.12010000.2 2010/02/10 22:49:24 mshirkol ship $ */

PROCEDURE Process_Pending_Status(ERRBUF          OUT  NOCOPY   VARCHAR2
			        ,RETCODE         OUT  NOCOPY   NUMBER
				,p_Org_Id        IN   NUMBER   := NULL
				,p_Item_Id       IN   NUMBER   := NULL
                                ,p_commit        IN   VARCHAR2:=  FND_API.g_TRUE
                                ,p_prog_appid    IN   NUMBER   := NULL
                                ,p_prog_id       IN   NUMBER   := NULL
                                ,p_request_id    IN   NUMBER   := NULL
                                ,p_user_id       IN   NUMBER   := NULL
  				,p_login_id      IN   NUMBER   := NULL
                                ,p_init_msg_list IN   VARCHAR2 :=  FND_API.G_TRUE
				,p_msg_logname   IN   VARCHAR2 := 'FILE');


-- Fix for bug#9297937
-- ERES in Deferred during Item Creation
PROCEDURE Create_Item_ERES_Event ( p_commit             IN  VARCHAR2  := fnd_api.g_false,
                                   p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
                                   p_event_name         IN  VARCHAR2,
                                   p_event_key          IN  VARCHAR2,
                                   p_caller_type        IN  VARCHAR2,
                                   p_org_id             IN  NUMBER,
                                   p_inventory_item_id  IN  NUMBER);

-- Fix for bug#9297937
-- ERES in Deferred during Item Creation
PROCEDURE Create_Item_ERES_Event ( p_commit             IN  VARCHAR2  := fnd_api.g_false,
                                   p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
                                   p_event_name         IN  VARCHAR2,
                                   p_event_key          IN  VARCHAR2,
                                   p_caller_type        IN  VARCHAR2,
                                   p_org_id             IN  NUMBER,
                                   p_inventory_item_id  IN  NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2 );

end INV_ITEM_STATUS_CP;

/
