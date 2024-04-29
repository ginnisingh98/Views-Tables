--------------------------------------------------------
--  DDL for Package OZF_COPY_OFFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_COPY_OFFER_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcpos.pls 120.1 2005/08/08 18:15:12 appldev ship $ */

g_pkg_name   CONSTANT VARCHAR2(30) := 'OZF_COPY_OFFER_PVT';

PROCEDURE copy_offer_detail(
           p_api_version        IN  NUMBER,
           p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
           p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
           p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
           x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_count          OUT NOCOPY NUMBER,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_source_object_id   IN  NUMBER,
           p_attributes_table   IN  AMS_CpyUtility_PVT.copy_attributes_table_type,
           p_copy_columns_table IN  AMS_CpyUtility_PVT.copy_columns_table_type,
           x_new_object_id      OUT NOCOPY NUMBER,
           p_custom_setup_id    IN  NUMBER);

PROCEDURE copy_offer(
           p_api_version        IN  NUMBER,
           p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
           p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
           p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
           x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_count          OUT NOCOPY NUMBER,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_source_object_id   IN  NUMBER,
           p_attributes_table   IN  AMS_CpyUtility_PVT.copy_attributes_table_type,
           p_copy_columns_table IN  AMS_CpyUtility_PVT.copy_columns_table_type,
           x_new_object_id      OUT NOCOPY NUMBER,
           x_custom_setup_id    OUT NOCOPY NUMBER);

END OZF_COPY_OFFER_PVT;

 

/
