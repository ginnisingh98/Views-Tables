--------------------------------------------------------
--  DDL for Package JTF_DSP_SECTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DSP_SECTION_GRP" AUTHID CURRENT_USER AS
/* $Header: JTFGCSCS.pls 115.15 2004/07/09 18:49:25 applrt ship $ */

PROCEDURE insert_row
  (
   p_section_id                         IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_access_name                        IN VARCHAR2,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_section_type_code                  IN VARCHAR2,
   p_status_code                        IN VARCHAR2,
   p_display_context_id                 IN NUMBER,
   p_deliverable_id                     IN NUMBER,
   p_available_in_all_sites_flag        IN VARCHAR2,
   p_auto_placement_rule                IN VARCHAR2,
   p_order_by_clause                    IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_display_name                       IN VARCHAR2,
   p_description                        IN VARCHAR2,
   p_long_description                   IN VARCHAR2,
   p_keywords                           IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT VARCHAR2,
   x_section_id                         OUT NUMBER
  );

PROCEDURE update_row
  (
  p_section_id                          IN NUMBER,
  p_object_version_number               IN NUMBER   := FND_API.G_MISS_NUM,
  p_access_name                         IN VARCHAR2,
  p_start_date_active                   IN DATE,
  p_end_date_active                     IN DATE,
  p_section_type_code                   IN VARCHAR2,
  p_status_code                         IN VARCHAR2,
  p_display_context_id                  IN NUMBER,
  p_deliverable_id                      IN NUMBER,
  p_available_in_all_sites_flag         IN VARCHAR2,
  p_auto_placement_rule                 IN VARCHAR2,
  p_order_by_clause                     IN VARCHAR2,
  p_attribute_category                  IN VARCHAR2,
  p_attribute1                          IN VARCHAR2,
  p_attribute2                          IN VARCHAR2,
  p_attribute3                          IN VARCHAR2,
  p_attribute4                          IN VARCHAR2,
  p_attribute5                          IN VARCHAR2,
  p_attribute6                          IN VARCHAR2,
  p_attribute7                          IN VARCHAR2,
  p_attribute8                          IN VARCHAR2,
  p_attribute9                          IN VARCHAR2,
  p_attribute10                         IN VARCHAR2,
  p_attribute11                         IN VARCHAR2,
  p_attribute12                         IN VARCHAR2,
  p_attribute13                         IN VARCHAR2,
  p_attribute14                         IN VARCHAR2,
  p_attribute15                         IN VARCHAR2,
  p_display_name                        IN VARCHAR2,
  p_description                         IN VARCHAR2,
  p_long_description                    IN VARCHAR2,
  p_keywords                            IN VARCHAR2,
  p_last_update_date                    IN DATE,
  p_last_updated_by                     IN NUMBER,
  p_last_update_login                   IN NUMBER
  );

PROCEDURE delete_row
  (
   p_section_id IN NUMBER
  );

--
-- To be called from jtfmste.lct only
--
PROCEDURE load_row
  (
   p_owner                              IN VARCHAR2,
   p_section_id                         IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_access_name                        IN VARCHAR2,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_section_type_code                  IN VARCHAR2,
   p_status_code                        IN VARCHAR2,
   p_display_context_id                 IN NUMBER,
   p_deliverable_id                     IN NUMBER,
   p_available_in_all_sites_flag        IN VARCHAR2,
   p_auto_placement_rule                IN VARCHAR2,
   p_order_by_clause                    IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_display_name                       IN VARCHAR2,
   p_description                        IN VARCHAR2,
   p_long_description                   IN VARCHAR2,
   p_keywords                           IN VARCHAR2
  );

PROCEDURE Add_Language;

PROCEDURE translate_row
  (
   p_section_id                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_description                        IN VARCHAR2,
   p_long_description                   IN VARCHAR2,
   p_keywords                           IN VARCHAR2,
   x_owner                              IN VARCHAR2
  );

PROCEDURE Create_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_access_name                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_section_type_code              IN VARCHAR2,
   p_status_code                    IN VARCHAR2,
   p_display_context_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_deliverable_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_available_in_all_sites_flag    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_auto_placement_rule            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_order_by_clause                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_display_name                   IN VARCHAR2,
   p_description                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_long_description               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_keywords                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute_category             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute1                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_section_id                     OUT NUMBER,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Update_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_access_name                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_section_type_code              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_status_code                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_display_context_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_deliverable_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_available_in_all_sites_flag    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_auto_placement_rule            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_order_by_clause                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_display_name                   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_description                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_long_description               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_keywords                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute_category             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute1                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Delete_Section
  (
   p_api_version         IN NUMBER,
   p_init_msg_list       IN VARCHAR2    := FND_API.G_FALSE,
   p_commit              IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level    IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_section_id          IN NUMBER      := FND_API.G_MISS_NUM,
   p_access_name         IN VARCHAR2    := FND_API.G_MISS_CHAR,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT NUMBER,
   x_msg_data            OUT VARCHAR2
  );

PROCEDURE Update_Dsp_Context_To_Null
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_display_context_id             IN NUMBER,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Update_Deliverable_To_Null
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_deliverable_id                 IN NUMBER,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

END JTF_DSP_SECTION_GRP;

 

/
