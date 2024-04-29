--------------------------------------------------------
--  DDL for Package PV_DIRECT_ASSIGN_WRAPPER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_DIRECT_ASSIGN_WRAPPER_PUB" AUTHID CURRENT_USER as
 /* $Header: pvxpdaws.pls 120.0 2005/05/27 16:26:59 appldev noship $*/
 G_PKG_NAME      CONSTANT VARCHAR2(30):='PV_DIRECT_ASSIGN_WRAPPER_PUB';

 Procedure Create_Assignment_Wrapper (  p_api_version_number    IN       NUMBER
                                      ,p_init_msg_list         IN      VARCHAR2 := FND_API.G_TRUE
                                      ,p_commit                IN      VARCHAR2 := FND_API.G_TRUE
                                      ,p_validation_level      IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                      ,p_entity                IN       VARCHAR2
                                      ,p_lead_id               IN       NUMBER
                                      ,p_creating_username     IN       VARCHAR2
                                      ,p_bypass_cm_ok_flag     IN       VARCHAR2
                                      ,x_return_status         OUT    NOCOPY  VARCHAR2
                                      ,x_msg_count             OUT    NOCOPY  NUMBER
                                      ,x_msg_data              OUT    NOCOPY  VARCHAR2
                                      );
End PV_DIRECT_ASSIGN_WRAPPER_PUB;

 

/
