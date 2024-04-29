--------------------------------------------------------
--  DDL for Package PSB_DE_CLIENT_EXTENSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_DE_CLIENT_EXTENSIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: PSBVCLES.pls 115.3 2003/03/28 22:58:19 krajagop noship $ */

PROCEDURE Run_Client_Extension_Pub
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY      VARCHAR2,
  x_msg_count                  OUT NOCOPY      NUMBER,
  x_msg_data                   OUT NOCOPY      VARCHAR2,
  --
  p_data_extract_id            IN       NUMBER,
  p_mode                       IN       VARCHAR2
);


END PSB_DE_Client_Extensions_Pub ;

 

/
