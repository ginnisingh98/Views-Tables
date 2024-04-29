--------------------------------------------------------
--  DDL for Package IBE_DSP_MSITE_SCT_SECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DSP_MSITE_SCT_SECT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVCMSS.pls 120.2 2006/06/30 22:32:31 abhandar noship $ */

  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) Changes.

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
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_mini_site_section_section_id       OUT NOCOPY NUMBER
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
-- To be called from ibemste.lct only
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
   p_concat_ids                         IN VARCHAR2,
   P_LAST_UPDATE_DATE                   IN VARCHAR2,
   P_CUSTOM_MODE                        IN VARCHAR2
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
   x_mini_site_section_section_id   OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
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
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
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
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2
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
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
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
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE LOAD_SEED_ROW
  (
			P_MINI_SITE_SECTION_SECTION_ID    	IN NUMBER,
			P_OWNER  	                        IN VARCHAR2,
			P_OBJECT_VERSION_NUMBER   	        IN NUMBER   := FND_API.G_MISS_NUM,
			P_MINI_SITE_ID 	                    IN NUMBER,
			P_PARENT_SECTION_ID   		        IN NUMBER,
			P_CHILD_SECTION_ID      		    IN NUMBER,
			P_START_DATE_ACTIVE 	            IN VARCHAR2, --IN DATE,
			P_END_DATE_ACTIVE 		    IN VARCHAR2, --IN DATE,
			P_LEVEL_NUMBER 	                    IN NUMBER,
			P_SORT_ORDER 		                IN NUMBER,
			P_CONCAT_IDS 	                    IN VARCHAR2,
			P_LAST_UPDATE_DATE	            	IN VARCHAR2,
            P_CUSTOM_MODE                       IN VARCHAR2,
   			P_UPLOAD_MODE                       IN VARCHAR2
  );


END IBE_DSP_MSITE_SCT_SECT_PVT;

 

/
