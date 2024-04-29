--------------------------------------------------------
--  DDL for Package AMS_ACT_MESSAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACT_MESSAGES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvacms.pls 115.3 2002/11/15 21:01:49 abhola ship $ */


  /****************************************************************************/
-- Procedure
--   create_act_messages
-- Purpose
--   create a row in AMS_ACT_messages
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER   := FND_API.g_valid_level_full
--
--  p_message_id               IN      NUMBER,
--  p_message_used_by   IN      NUMBER,
--  p_msg_used_by_id       IN      NUMBER,
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
--
--     x_act_msg_id         OUT     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_act_messages
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_message_id               IN      NUMBER,
  p_message_used_by   IN      VARCHAR2,
  p_msg_used_by_id       IN      NUMBER,
  x_act_msg_id            OUT NOCOPY     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_act_messages
-- Purpose
--   update a row in AMS_ACT_MessageS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER   := FND_API.g_valid_level_full
--
--  p_message_id               IN      NUMBER,
--  p_message_used_by   IN      NUMBER,
--  p_msg_used_by_id       IN      NUMBER,
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_act_messages
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_act_msg_id                 IN      NUMBER,
  p_message_id               IN      NUMBER,
  p_msg_used_by	     IN      VARCHAR2,
  p_msg_used_by_id       IN      NUMBER,
  p_object_version     IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   delete_act_messages
-- Purpose
--   delete a row from AMS_ACT_MessageS
-- Parameters
--   IN:
--     p_api_version      IN      NUMBER
--     p_init_msg_list    IN      VARCHAR2 := FND_API.g_false
--     p_commit           IN      VARCHAR2 := FND_API.g_false
--
--     p_act_msg_id       IN      NUMBER
--     p_object_version   IN      NUMBER
--
--   OUT:
--     x_return_status    OUT     VARCHAR2
--     x_msg_count        OUT     NUMBER
--     x_msg_data         OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_act_messages
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,
  p_commit           IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_msg_id       IN      NUMBER,
  p_object_version   IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_act_messages
-- Purpose
--   lock a row form AMS_ACT_MessageS
-- Parameters
--   IN:
--     p_api_version      IN      NUMBER
--     p_init_msg_list    IN      VARCHAR2 := FND_API.g_false
--
--     p_act_msg_id       IN      NUMBER
--     p_object_version   IN      NUMBER
--
--   OUT:
--     x_return_status    OUT     VARCHAR2
--     x_msg_count        OUT     NUMBER
--     x_msg_data         OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_act_messages
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_msg_id       IN      NUMBER,
  p_object_version   IN      NUMBER
);

END AMS_Act_Messages_PVT;

 

/
