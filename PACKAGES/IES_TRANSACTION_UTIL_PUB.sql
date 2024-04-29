--------------------------------------------------------
--  DDL for Package IES_TRANSACTION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_TRANSACTION_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: iestutls.pls 115.0.1159.1 2003/05/23 22:12:51 prkotha noship $ */
   procedure update_status_to_completed
   (
      p_api_version                    IN     NUMBER,
      p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
      p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
      p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
      p_transaction_id                 IN     NUMBER,
      x_return_status                  OUT NOCOPY     VARCHAR2,
      x_msg_count                      OUT NOCOPY     NUMBER,
      x_msg_data                       OUT NOCOPY     VARCHAR2
   );

END IES_TRANSACTION_UTIL_PUB;

 

/
