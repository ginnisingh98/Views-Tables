--------------------------------------------------------
--  DDL for Package CSI_WEB_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_WEB_SERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: csiwss.pls 120.1 2007/12/04 17:42:26 fli noship $ */

PROCEDURE get_item_instance_obj
(
  p_api_version           IN  NUMBER,
  p_commit                IN  VARCHAR2 := FND_API.g_FALSE,
  p_init_msg_list         IN  VARCHAR2 := FND_API.g_FALSE,
  p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_instance_id           IN  NUMBER,
  p_instance_number       IN  VARCHAR2,
  x_item_instance_obj     OUT NOCOPY  CSI_ITEM_INSTANCE_OBJ,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2
);

END;

/
