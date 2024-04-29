--------------------------------------------------------
--  DDL for Package JTF_DSP_MSITE_SCT_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DSP_MSITE_SCT_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVCMIS.pls 115.13 2004/07/09 18:51:33 applrt ship $ */

PROCEDURE insert_row
  (
   p_mini_site_section_item_id          IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_mini_site_id                       IN NUMBER,
   p_section_item_id                    IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT VARCHAR2,
   x_mini_site_section_item_id          OUT NUMBER
  );

PROCEDURE update_row
  (
  p_mini_site_section_item_id           IN NUMBER,
  p_object_version_number               IN NUMBER   := FND_API.G_MISS_NUM,
  p_start_date_active                   IN DATE,
  p_end_date_active                     IN DATE,
  p_last_update_date                    IN DATE,
  p_last_updated_by                     IN NUMBER,
  p_last_update_login                   IN NUMBER
  );

PROCEDURE delete_row
  (
   p_mini_site_section_item_id IN NUMBER
  );

PROCEDURE Create_MSite_Section_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mini_site_id                   IN NUMBER,
   p_section_item_id                IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   x_mini_site_section_item_id      OUT NUMBER,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Update_MSite_Section_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mini_site_section_item_id      IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_mini_site_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_section_item_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Delete_MSite_Section_Item
  (
   p_api_version                  IN NUMBER,
   p_init_msg_list                IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                       IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level             IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_call_from_trigger            IN BOOLEAN     := FALSE,
   p_mini_site_section_item_id    IN NUMBER      := FND_API.G_MISS_NUM,
   p_mini_site_id                 IN NUMBER      := FND_API.G_MISS_NUM,
   p_section_item_id              IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status                OUT VARCHAR2,
   x_msg_count                    OUT NUMBER,
   x_msg_data                     OUT VARCHAR2
  );

END JTF_DSP_MSITE_SCT_ITEM_PVT;

 

/
