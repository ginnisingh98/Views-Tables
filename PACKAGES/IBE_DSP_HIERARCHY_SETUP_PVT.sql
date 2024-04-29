--------------------------------------------------------
--  DDL for Package IBE_DSP_HIERARCHY_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DSP_HIERARCHY_SETUP_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVCHSS.pls 120.3 2005/12/28 13:21:40 savarghe ship $ */

  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) and Debug (Bug # 2691710) Changes.

  -- **********************************************************************************************************

PROCEDURE Get_Master_Mini_Site_Id
  (
   x_mini_site_id    OUT NOCOPY NUMBER,
   x_root_section_id OUT NOCOPY NUMBER
  );

PROCEDURE Create_Hierarchy_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_parent_section_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_parent_section_access_name     IN VARCHAR2 := FND_API.G_MISS_CHAR,
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
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
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
   x_section_id                     OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Update_Hierarchy_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_mss_object_version_number      IN NUMBER   := FND_API.G_MISS_NUM,
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
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
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
   p_upd_dsc_scts_status            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Delete_Hierarchy_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_access_name                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

--bug 2699547 (code for PROCEDURE Get_Hierarchy_Sections removed)

PROCEDURE Associate_Items_To_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   p_inventory_item_ids             IN JTF_NUMBER_TABLE,
   p_organization_ids               IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_association_reason_codes       IN JTF_VARCHAR2_TABLE_300,
   x_section_item_ids               OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Associate_Sections_To_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   p_section_ids                    IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_association_reason_codes       IN JTF_VARCHAR2_TABLE_300,
   x_section_item_ids               OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Disassociate_Scts_To_Itms
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_ids                    IN JTF_NUMBER_TABLE,
   p_inventory_item_ids             IN JTF_NUMBER_TABLE,
   p_organization_ids               IN JTF_NUMBER_TABLE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Disassociate_Scts_Itms
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_item_ids               IN JTF_NUMBER_TABLE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Associate_MSites_To_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   p_mini_site_ids                  IN JTF_NUMBER_TABLE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Associate_Root_Sct_To_MSite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   p_mini_site_id                   IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Update_Hierarchy_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   p_last_updated_by                IN NUMBER,
   p_last_update_login              IN NUMBER,
   p_last_update_date               IN DATE,
   p_web_status_type                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_description                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_long_description               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Associate_MSites_To_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   p_mini_site_ids                  IN JTF_NUMBER_TABLE,
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

--bug 2942525 (code for PROCEDURE Copy_And_Paste_Section removed on 05/07/2003)

PROCEDURE Cut_And_Paste_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_src_section_id                 IN NUMBER,
   p_dst_parent_section_id          IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

--begin :  added by abhandar :26 apr 2002 for Copy section with content reference
PROCEDURE Copy_Section_Ref_Content
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_src_section_id                 IN NUMBER,
   p_dst_parent_section_id          IN NUMBER,
   x_new_src_section_id             OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2,
   p_new_display_name               IN VARCHAR2 := NULL
  );

PROCEDURE Copy_Logical_Media(
       p_item_id        IN    NUMBER,
       p_object_id      IN    NUMBER,
       p_context_id     IN    NUMBER,
       x_new_item_id    OUT NOCOPY   NUMBER,
       x_msg_count      OUT NOCOPY   NUMBER,
       x_return_status  OUT NOCOPY   VARCHAR2,
       x_msg_data	OUT  NOCOPY  VARCHAR2
   );


PROCEDURE Save_Physical_Map(p_item_id           IN  NUMBER,
                           p_msite_id           IN  NUMBER,
                           p_language_code      IN  VARCHAR2,
                           p_attachment_id      IN  NUMBER,
                           p_default_site       IN  VARCHAR2,
                           p_default_language   IN  VARCHAR2,
                           x_return_status	OUT NOCOPY VARCHAR2,
                           x_msg_count		OUT NOCOPY NUMBER,
                           x_msg_data		OUT NOCOPY VARCHAR2);

PROCEDURE Save_Object_Logical_Content(
   p_object_id              IN  NUMBER,
   p_context_id             IN  NUMBER,
   p_item_id                IN  NUMBER,
   p_object_type            IN  VARCHAR2,
   x_return_status	    OUT NOCOPY VARCHAR2,
   x_msg_count		    OUT NOCOPY NUMBER,
   x_msg_data		    OUT NOCOPY VARCHAR2);

PROCEDURE Reference_Section_Content
  (
   p_old_section_id                 IN NUMBER,
   p_new_section_id                 IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2  );

-- end : added by abhandar

-- For 11.5.10, Layout Components Map
PROCEDURE Update_Hierarchy_Layout_Map
(p_api_version      IN NUMBER,
 p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
 p_commit           IN VARCHAR2 := FND_API.G_FALSE,
 p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_section_id       IN NUMBER,
 p_layout_id        IN NUMBER,
 p_layout_comp_id   IN JTF_NUMBER_TABLE,
 p_layout_temp_id   IN JTF_NUMBER_TABLE,
 p_object_versions  IN JTF_NUMBER_TABLE,
 p_actionflags      IN JTF_VARCHAR2_TABLE_100,
 p_cascading_flag   IN NUMBER := 0,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2,
 x_section_ids      OUT NOCOPY JTF_NUMBER_TABLE,
 x_layout_comp_ids  OUT NOCOPY JTF_NUMBER_TABLE
);

PROCEDURE Update_Section_Dlv_Ctx
(p_api_version      IN NUMBER,
 p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
 p_commit           IN VARCHAR2 := FND_API.G_FALSE,
 p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_section_id       IN NUMBER,
 p_deliverable_id   IN NUMBER,
 p_display_context_id IN NUMBER,
 p_object_version_number IN NUMBER,
 p_saveds_flag      IN NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE Batch_Duplicate_Section(
	errbuf	OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER,
	p_source_section_id IN VARCHAR2,
	p_dest_parent_section_id IN VARCHAR2,
	p_new_sect_display_name IN VARCHAR2 ,
	p_enable_trace  IN  VARCHAR2
);

PROCEDURE Cascade_Layout_Comp_Mapping
	(p_api_version       IN NUMBER,
	p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
	p_commit            IN VARCHAR2 := FND_API.G_FALSE,
	p_source_section_id IN NUMBER,
	p_target_section_id  IN NUMBER,
	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,
	x_section_ids       IN OUT NOCOPY JTF_NUMBER_TABLE,
	x_layout_comp_ids   IN OUT NOCOPY JTF_NUMBER_TABLE);


PROCEDURE Batch_Cascade_Sec_Layout_Map (
    errbuf	OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER,
	p_section_id         IN VARCHAR2,
	p_enable_trace_flag  IN VARCHAR2);


PROCEDURE Associate_Items_To_Section(
   p_api_version                    	IN NUMBER,
   p_init_msg_list                    	IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         	IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level                   IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
   x_return_status                  	OUT NOCOPY VARCHAR2,
   x_msg_count                      	OUT NOCOPY NUMBER,
   x_msg_data                       	OUT NOCOPY VARCHAR2,
   p_section_id                        	IN NUMBER,
   p_section_item_tbl               	IN IBE_DSP_HIERARCHY_SETUP_PUB.SECTION_ITEM_TBL_TYPE,
   x_section_item_out_tbl            	OUT NOCOPY IBE_DSP_HIERARCHY_SETUP_PUB.SECTION_ITEM_OUT_TBL_TYPE);

END IBE_DSP_HIERARCHY_SETUP_PVT;

 

/
