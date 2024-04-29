--------------------------------------------------------
--  DDL for Package IBE_DSP_SECTION_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DSP_SECTION_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVCISS.pls 120.0 2005/05/30 02:46:55 appldev noship $ */

  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) and Debug (Bug # 2691710) Changes.
  -- **********************************************************************************************************

PROCEDURE insert_row
  (
   p_section_item_id                    IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_section_id                         IN NUMBER,
   p_inventory_item_id                  IN NUMBER,
   p_organization_id                    IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_usage_name				IN VARCHAR2,
   p_sort_order                         IN NUMBER,
   p_association_reason_code            IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_section_item_id                    OUT NOCOPY NUMBER
  );

PROCEDURE update_row
  (
  p_section_item_id                     IN NUMBER,
  p_object_version_number               IN NUMBER   := FND_API.G_MISS_NUM,
  p_start_date_active                   IN DATE,
  p_end_date_active                     IN DATE,
  p_usage_name				IN VARCHAR2,
  p_sort_order                          IN NUMBER,
  p_association_reason_code             IN VARCHAR2,
  p_last_update_date                    IN DATE,
  p_last_updated_by                     IN NUMBER,
  p_last_update_login                   IN NUMBER
  );

PROCEDURE delete_row
  (
   p_section_item_id IN NUMBER
  );

PROCEDURE Create_Section_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_association_reason_code        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_section_item_id                OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Update_Section_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_item_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_section_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_inventory_item_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_organization_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_usage_name			    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_association_reason_code        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Delete_Section_Item
  (
   p_api_version                  IN NUMBER,
   p_init_msg_list                IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                       IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level             IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_call_from_trigger            IN BOOLEAN     := FALSE,
   p_section_item_id              IN NUMBER      := FND_API.G_MISS_NUM,
   p_section_id                   IN NUMBER      := FND_API.G_MISS_NUM,
   p_inventory_item_id            IN NUMBER      := FND_API.G_MISS_NUM,
   p_organization_id              IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2
  );

PROCEDURE Delete_Section_Items_For_Item
  (
   p_inventory_item_id            IN NUMBER      := FND_API.G_MISS_NUM,
   p_organization_id              IN NUMBER      := FND_API.G_MISS_NUM
  );

PROCEDURE Update_Delete_Sct_Itms
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_item_ids               IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_usage_names		    IN JTF_VARCHAR2_TABLE_300,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_association_reason_codes       IN JTF_VARCHAR2_TABLE_300,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_300,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

END IBE_DSP_SECTION_ITEM_PVT;

 

/
