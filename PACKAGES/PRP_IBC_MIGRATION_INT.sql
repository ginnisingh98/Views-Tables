--------------------------------------------------------
--  DDL for Package PRP_IBC_MIGRATION_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRP_IBC_MIGRATION_INT" AUTHID CURRENT_USER AS
/* $Header: PRPVMIBS.pls 115.0 2003/10/15 00:44:15 hekkiral noship $ */

PROCEDURE CREATE_CONTENT(
                         p_api_version                 IN  NUMBER,
                         p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
                         p_component_style_id          IN  NUMBER,
                         p_base_language               IN  VARCHAR2,
                         p_file_id                     IN  NUMBER,
                         p_comp_style_ctntver_id       IN  NUMBER,
                         px_content_item_id            IN  OUT NOCOPY NUMBER,
                         px_object_version_number      IN  OUT NOCOPY NUMBER,
                         x_citem_ver_id                OUT NOCOPY NUMBER,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_CONTENT(
                         p_api_version                 IN  NUMBER,
                         p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
                         p_file_id                     IN  NUMBER,
                         p_component_style_id          IN  NUMBER,
                         p_comp_style_ctntver_id       IN  NUMBER,
                         p_content_item_id             IN  NUMBER,
                         p_citem_version_id            IN  NUMBER,
                         p_language                    IN  VARCHAR2,
                         px_object_version_number      IN  OUT NOCOPY NUMBER,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2);

PROCEDURE MIGRATE_PROPOSAL_DOC(
                         p_api_version                 IN  NUMBER,
                         p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
                         p_proposal_id                 IN  NUMBER,
                         p_proposal_ctntver_id       IN  NUMBER,
                         p_base_language               IN  VARCHAR2,
                         p_file_id                     IN  NUMBER,
                         px_content_item_id            IN  OUT NOCOPY NUMBER,
                         px_object_version_number      IN  OUT NOCOPY NUMBER,
                         x_citem_ver_id                OUT NOCOPY NUMBER,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2);

END PRP_IBC_MIGRATION_INT;


 

/
