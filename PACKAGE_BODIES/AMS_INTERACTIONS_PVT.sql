--------------------------------------------------------
--  DDL for Package Body AMS_INTERACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_INTERACTIONS_PVT" AS
/* $Header: amsvintb.pls 115.2 2001/12/14 16:27:20 pkm ship    $ */


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
) IS

BEGIN
   null;
END;

END AMS_INTERACTIONS_PVT;

/
