--------------------------------------------------------
--  DDL for Package ZPB_SECURITY_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_SECURITY_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: ZPBVSCUS.pls 120.0.12010.2 2005/12/23 06:08:11 appldev noship $*/


PROCEDURE validate_user (p_user_id             IN  NUMBER,
                         p_business_area_id    IN  NUMBER,
                         p_api_version         IN  NUMBER,
                         p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                         p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                         p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                         x_user_account_state  OUT NOCOPY varchar2,
                         x_return_status       OUT NOCOPY varchar2,
                         x_msg_count           OUT NOCOPY number,
                         x_msg_data            OUT NOCOPY varchar2);

PROCEDURE has_read_access (p_user_id           IN  NUMBER,
                           p_business_area_id  IN  NUMBER,
                         p_api_version         IN  NUMBER,
                         p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                         p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                         p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                         x_user_read_access    OUT NOCOPY varchar2,
                         x_return_status       OUT NOCOPY varchar2,
                         x_msg_count           OUT NOCOPY number,
                         x_msg_data            OUT NOCOPY varchar2);

END ZPB_SECURITY_UTIL_PVT;


 

/
