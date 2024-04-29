--------------------------------------------------------
--  DDL for Package JTF_FM_QUERY_LINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_QUERY_LINK_PKG" AUTHID CURRENT_USER AS
/* $Header: jtffmgqs.pls 120.0 2005/05/11 08:14:19 appldev ship $*/
PROCEDURE Link_Content_To_Query
(
     p_api_version         IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_content_id         IN NUMBER,
     p_query_id           IN NUMBER
);
PROCEDURE UnLink_Content_To_Query
(
     p_api_version         IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_content_id         IN NUMBER,
     p_query_id           IN NUMBER
);
END JTF_FM_QUERY_LINK_PKG;

 

/
