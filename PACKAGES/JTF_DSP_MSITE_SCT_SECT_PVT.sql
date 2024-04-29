--------------------------------------------------------
--  DDL for Package JTF_DSP_MSITE_SCT_SECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DSP_MSITE_SCT_SECT_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVCMSS.pls 115.13 2004/07/09 18:51:41 applrt ship $ */

PROCEDURE insert_row
  (
   p_mini_site_section_section_id       IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_mini_site_id                       IN NUMBER,
   p_parent_section_id                  IN NUMBER,
   p_child_section_id                   IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_level_number                       IN NUMBER,
   p_sort_order                         IN NUMBER,
   p_concat_ids                         IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT VARCHAR2,
   x_mini_site_section_section_id       OUT NUMBER
  );

PROCEDURE update_row
  (
  p_mini_site_section_section_id        IN NUMBER,
  p_object_version_number               IN NUMBER   := FND_API.G_MISS_NUM,
  p_start_date_active                   IN DATE,
  p_end_date_active                     IN DATE,
  p_level_number                        IN NUMBER,
  p_sort_order                          IN NUMBER,
  p_concat_ids                          IN VARCHAR2,
  p_last_update_date                    IN DATE,
  p_last_updated_by                     IN NUMBER,
  p_last_update_login                   IN NUMBER
  );

PROCEDURE delete_row
  (
   p_mini_site_section_section_id IN NUMBER
  );

--
-- To be called from jtfmste.lct only
--
PROCEDURE load_row
  (
   p_owner                              IN VARCHAR2,
   p_mini_site_section_section_id       IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_mini_site_id                       IN NUMBER,
   p_parent_section_id                  IN NUMBER,
   p_child_section_id                   IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_level_number                       IN NUMBER,
   p_sort_order                         IN NUMBER,
   p_concat_ids                         IN VARCHAR2
  );

PROCEDURE Create_MSite_Section_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mini_site_id                   IN NUMBER,
   p_parent_section_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_child_section_id               IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_level_number                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_concat_ids                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_mini_site_section_section_id   OUT NUMBER,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Update_MSite_Section_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mini_site_section_section_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_mini_site_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_parent_section_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_child_section_id               IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_level_number                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_concat_ids                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Delete_MSite_Section_Section
  (
   p_api_version                  IN NUMBER,
   p_init_msg_list                IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                       IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level             IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_mini_site_section_section_id IN NUMBER      := FND_API.G_MISS_NUM,
   p_mini_site_id                 IN NUMBER      := FND_API.G_MISS_NUM,
   p_parent_section_id            IN NUMBER      := FND_API.G_MISS_NUM,
   p_child_section_id             IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status                OUT VARCHAR2,
   x_msg_count                    OUT NUMBER,
   x_msg_data                     OUT VARCHAR2
  );

PROCEDURE Update_MSite_Section_Sections
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_section_section_ids      IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Update_Delete_Sct_Scts
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_section_section_ids      IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_300,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

END JTF_DSP_MSITE_SCT_SECT_PVT;

 

/
