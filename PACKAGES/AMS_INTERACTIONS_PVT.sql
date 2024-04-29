--------------------------------------------------------
--  DDL for Package AMS_INTERACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_INTERACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvints.pls 115.2 2001/12/14 16:27:21 pkm ship    $ */


PROCEDURE create_interactions
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT     VARCHAR2,
  x_msg_count             OUT     NUMBER,
  x_msg_data              OUT     VARCHAR2,

  x_interaction_id           OUT     NUMBER
);

END AMS_INTERACTIONS_PVT;

 

/
