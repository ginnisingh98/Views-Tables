--------------------------------------------------------
--  DDL for Package IBE_DSP_HIERARCHY_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DSP_HIERARCHY_QUERY_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVCHQS.pls 115.16 2003/08/21 20:13:06 abhandar ship $ */

  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) and Debug (Bug # 2691710) Changes.
  --   08/16/03          abhandar       added procedure load_section_hierarchy() (bug ##3090284)
  -- **********************************************************************************************************

-- Cursor which would return with section related data from
-- ibe_dsp_sections_vl view.
TYPE SECTION_CSR IS REF CURSOR;

-- Cursor with data from ibe_dsp_section_items table and mtl_system_items
-- table.
TYPE SECTIONITEM_ITEM_CSR IS REF CURSOR;

-- Cursor with data from ibe_dsp_section_items table and ibe_dsp_sections_vl
-- view.
TYPE SECTIONITEM_SECTION_CSR IS REF CURSOR;

-- Cursor with data from ibe_dsp_msite_sct_sects table and ibe_dsp_sections_vl
-- view.
TYPE SECTION_SECTION_CSR IS REF CURSOR;

-- Cursor with data for lookup_code and meaning for lookup type =
-- 'IBE_SECTION_TYPE'
TYPE SECTION_TYPE_CSR IS REF CURSOR;

-- Cursor with data for lookup_code and meaning for lookup type =
-- 'IBE_SECTION_STATUS'
TYPE SECTION_STATUS_CSR IS REF CURSOR;

-- Cursor with data for deliverables (logical templates)
TYPE DELIVERABLE_CSR IS REF CURSOR;

-- Cursor with data for display context
TYPE DISPLAY_CONTEXT_CSR IS REF CURSOR;

-- Cursor with data for mini-site
TYPE MINI_SITE_CSR IS REF CURSOR;

-- Cursor with item data
TYPE INVENTORY_ITEM_CSR IS REF CURSOR;

-- Cursor with list of web status types
TYPE WEB_STATUS_TYPE_CSR IS REF CURSOR;

-- added by abhandar
-- Cursor with section hierarchy information
TYPE SECTION_HGRID_CSR IS REF CURSOR;

PROCEDURE Load_SectionItems_For_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   x_section_csr                    OUT NOCOPY SECTION_CSR,
   x_sectionitem_item_csr           OUT NOCOPY SECTIONITEM_ITEM_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_SectionItems_For_Item
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   x_sectionitem_section_csr        OUT NOCOPY SECTIONITEM_SECTION_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_ChildSections_For_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   x_section_csr                    OUT NOCOPY SECTION_CSR,
   x_section_section_csr            OUT NOCOPY SECTION_SECTION_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_Children_For_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   x_is_leaf_section                OUT NOCOPY VARCHAR2,
   x_section_path                   OUT NOCOPY VARCHAR2,
   x_section_csr                    OUT NOCOPY SECTION_CSR,
   x_section_section_csr            OUT NOCOPY SECTION_SECTION_CSR,
   x_sectionitem_item_csr           OUT NOCOPY SECTIONITEM_SECTION_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_Section_For_Basic_Desc
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   x_section_path                   OUT NOCOPY VARCHAR2,
   x_section_csr                    OUT NOCOPY SECTION_CSR,
   x_section_type_csr               OUT NOCOPY SECTION_TYPE_CSR,
   x_section_status_csr             OUT NOCOPY SECTION_STATUS_CSR,
   x_deliverable_csr                OUT NOCOPY DELIVERABLE_CSR,
   x_display_context_csr            OUT NOCOPY DISPLAY_CONTEXT_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_Root_Sct_For_Basic_Desc
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_section_path                   OUT NOCOPY VARCHAR2,
   x_section_csr                    OUT NOCOPY SECTION_CSR,
   x_section_type_csr               OUT NOCOPY SECTION_TYPE_CSR,
   x_section_status_csr             OUT NOCOPY SECTION_STATUS_CSR,
   x_deliverable_csr                OUT NOCOPY DELIVERABLE_CSR,
   x_display_context_csr            OUT NOCOPY DISPLAY_CONTEXT_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Get_Cand_Incl_MSites_For_Sct
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   x_section_path                   OUT NOCOPY VARCHAR2,
   x_section_csr                    OUT NOCOPY SECTION_CSR,
   x_incl_mini_site_csr             OUT NOCOPY MINI_SITE_CSR,
   x_cndt_mini_site_csr             OUT NOCOPY MINI_SITE_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_Items_For_Basic_Desc
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   x_inventory_item_csr             OUT NOCOPY INVENTORY_ITEM_CSR,
   x_web_status_type_csr            OUT NOCOPY WEB_STATUS_TYPE_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Get_Cand_Incl_MSites_For_Itm
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   x_inventory_item_csr             OUT NOCOPY INVENTORY_ITEM_CSR,
   x_incl_mini_site_csr             OUT NOCOPY MINI_SITE_CSR,
   x_cndt_mini_site_csr             OUT NOCOPY MINI_SITE_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );
--
-- Obsoleted and Removed code for the PROCEDURE Get_Item_Id_List :bug 2936693 :05/09/2003:abhandar
---
--
-- Obsoleted and Removed code for the PROCEDURE Get_Item_Info_For_Lookup :bug 2936693 :05/09/2003:abhandar
---
--
-- Obsoleted and Removed code for the PROCEDURE Get_Item_Info_For_Detail_List :bug 2936693 :05/09/2003:abhandar
---
--
-- Obsoleted and Removed code for the PROCEDURE Get_Section_Id_List :bug 2936693 :05/09/2003 :abhandar
---
--
-- Obsoleted and Removedcode for the PROCEDURE Get_Section_Info_For_Lookup :bug 2936693 :05/09/2003:abhandar
---

-- added by abhandar apr/24/2002
PROCEDURE Get_Section_Path
(
   p_section_id                     IN NUMBER,
   x_section_path                   OUT NOCOPY VARCHAR2,
   x_section_name                   OUT NOCOPY VARCHAR2,
   x_section_desc                   OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

-- added by abhandar 08/16/03 for loading hgrid data
PROCEDURE Load_Section_Hierarchy
 (
   p_msite_id                       IN NUMBER,
   p_section_id                     IN NUMBER,
   p_level_number                   IN NUMBER,
   x_section_hierarchy_csr          OUT NOCOPY SECTION_HGRID_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

END IBE_DSP_HIERARCHY_QUERY_PVT;


 

/
