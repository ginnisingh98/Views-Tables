--------------------------------------------------------
--  DDL for Package Body IBE_DSP_HIERARCHY_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DSP_HIERARCHY_QUERY_PVT" AS
/* $Header: IBEVCHQB.pls 120.3 2008/01/10 06:32:58 amaheshw ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBE_DSP_HIERARCHY_QUERY_PVT
  --
  -- PURPOSE
  --   Private API for saving, retrieving and updating sections.
  --
  -- NOTES
  --   This is a pulicly accessible pacakge.
  --
  --
  -- HISTORY
  --   11/28/99           VPALAIYA         Created
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) and Debug (Bug # 2691710) Changes.
  --   12/19/02           SCHAK         Modified for reverting Debug (IBEUtil) Changes.
  --   08/16/03          abhandar       added procedure load_section_hierarchy() (bug ##3090284)
  --   12/13/05          madesai      bugfix - 4864940  Modified query in
  --                                  Load_SectionItems_For_Section to get item
  --                                 based on profile "IBE:Item Validation for
  --                                 Organization
   --  10.Jan.08       amaheshw      bug 6712124. check end date for sections

  -- **********************************************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):='IBE_DSP_HIERAHCY_QUERY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):='IBEVCHQB.pls';

FUNCTION Get_Display_Name
  (
   p_object_type IN VARCHAR2,
   p_object_id   IN NUMBER
  ) RETURN VARCHAR2
IS
  TYPE section_path_csr_type IS REF CURSOR;
  l_section_path_csr section_path_csr_type;
  l_section_id        NUMBER;
  l_section_disp_name VARCHAR2(120);
  l_master_msite_id   NUMBER;
  l_display_name      VARCHAR2(240);

BEGIN

  IF p_object_type = 'S' THEN

    -- Get the master minisite id
    SELECT JMB.msite_id
      INTO l_master_msite_id
      FROM ibe_msites_b JMB
      WHERE JMB.master_msite_flag = 'Y' and
	        JMB.site_type = 'I';

    -- Open a cursor that retrieves the sections path from the root section
    -- to p_object_id's immediate parent, in the reverse order
    OPEN l_section_path_csr FOR
      'SELECT JDMSS.parent_section_id ' ||
      'FROM ibe_dsp_msite_sct_sects JDMSS ' ||
      'START WITH JDMSS.child_section_id = :section_id ' ||
      'AND JDMSS.mini_site_id     = :master_mini_site_id1 ' ||
      'CONNECT BY JDMSS.child_section_id = PRIOR JDMSS.parent_section_id ' ||
      'AND JDMSS.mini_site_id     = :master_mini_site_id2 ' ||
      'AND JDMSS.parent_section_id IS NOT NULL'
      USING p_object_id, l_master_msite_id, l_master_msite_id;

    -- Loop through the cursor constructing the section path string
    LOOP
      FETCH l_section_path_csr INTO l_section_id;
      EXIT WHEN l_section_path_csr%NOTFOUND;

      SELECT JDSV.display_name
        INTO l_section_disp_name
        FROM ibe_dsp_sections_vl JDSV
        WHERE JDSV.section_id = l_section_id;

      l_display_name := l_section_disp_name || '/' || l_display_name;

    END LOOP;

    CLOSE l_section_path_csr;

    SELECT JDSV.display_name
      INTO l_section_disp_name
      FROM ibe_dsp_sections_vl JDSV
      WHERE JDSV.section_id = p_object_id;

    l_display_name := l_display_name || l_section_disp_name;

  END IF;

  RETURN l_display_name;

END Get_Display_Name;

--
-- Return data (association + item data + section data) belonging to
-- the section p_section_id
--
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
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_SectionItems_For_Section';
  l_api_version             CONSTANT NUMBER       := 1.0;
   l_organization_id_str VARCHAR2(30);
   l_organization_id NUMBER;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the section data
  OPEN x_section_csr FOR SELECT display_name FROM ibe_dsp_sections_vl
    WHERE section_id = p_section_id;
/* bug fix 4864940 */
 l_organization_id_str
     := FND_PROFILE.VALUE_SPECIFIC('IBE_ITEM_VALIDATION_ORGANIZATION',null,null,671);
	      IF (l_organization_id_str IS NULL) THEN
		     RAISE FND_API.G_EXC_ERROR;
		  ELSE
		      l_organization_id := to_number(l_organization_id_str);
		  END IF;

  -- Get the section-item data and item data
  OPEN x_sectionitem_item_csr FOR SELECT MTL.inventory_item_id,
    MTL.organization_id, MTL.concatenated_segments, MTL.description,
    MTL.web_status, L.meaning, SI.section_item_id, SI.object_version_number,
    SI.start_date_active, SI.end_date_active, SI.sort_order
    FROM ibe_dsp_section_items SI, mtl_system_items_vl MTL, fnd_lookups L
    WHERE SI.section_id = p_section_id
    AND   SI.inventory_item_id = MTL.inventory_item_id
    AND   SI.organization_id = MTL.organization_id
    AND   L.lookup_type = 'IBE_ITEM_STATUS'
    AND   L.lookup_code = MTL.web_status
    AND   SI.organization_id = l_organization_id /*bug 4864940 */
    order by SI.sort_order;
--order by added by abhandar 05/30/2002


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_SectionItems_For_Section;

--
-- Return data (association + item data + section data) belonging to
-- the item (p_inventory_item_id, p_organization_id)
-- Note: No item data/cursor returned
--
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
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_SectionItems_For_Item';
  l_api_version             CONSTANT NUMBER       := 1.0;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the section-item data and section data
  OPEN x_sectionitem_section_csr FOR SELECT S.section_id, S.display_name,
    SI.section_item_id, SI.object_version_number, SI.start_date_active,
    SI.end_date_active, SI.sort_order
    FROM ibe_dsp_sections_vl S, ibe_dsp_section_items SI
    WHERE SI.inventory_item_id = p_inventory_item_id
    AND   SI.organization_id = p_organization_id
    AND   SI.section_id = S.section_id;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_SectionItems_For_Item;

--
-- Returns child-sections for the given section
-- Return data (association + child-section data + section data) belonging to
-- the section (p_section_id)
--
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
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_Sections_For_Section';
  l_api_version             CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id     NUMBER;
  l_master_root_section_id  NUMBER;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the master mini-site id
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id
    (
    x_mini_site_id      => l_master_mini_site_id,
    x_root_section_id   => l_master_root_section_id
    );

  -- Get the (parent) section data
  OPEN x_section_csr FOR SELECT display_name FROM ibe_dsp_sections_vl
    WHERE section_id = p_section_id;

  -- Get the section-(child)section association data and child-section data
/*
  OPEN x_section_section_csr FOR SELECT S.section_id, S.access_name,
    S.display_name, S.section_type_code, L1.meaning, S.status_code, L2.meaning,
    MSS.mini_site_section_section_id, MSS.object_version_number,
    MSS.start_date_active, MSS.end_date_active, MSS.sort_order
    FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS, fnd_lookups L1,
    fnd_lookups L2
    WHERE S.section_id IN
    (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
     WHERE parent_section_id = p_section_id
     AND mini_site_id = l_master_mini_site_id)
    AND   MSS.child_section_id = S.section_id
    AND   MSS.mini_site_id = l_master_mini_site_id
    AND   L1.lookup_type = 'IBE_SECTION_TYPE'
    AND   L1.lookup_code = S.section_type_code
    AND   L2.lookup_type = 'IBE_SECTION_STATUS'
    AND   L2.lookup_code = S.status_code
    --  ORDER BY S.display_name;
  --modified by abhandar 05/30/2002
   ORDER BY MSS.sort_order;
*/
  -- Performance bug fix 2887798
  OPEN x_section_section_csr FOR SELECT S.section_id, S.access_name,
    S.display_name, S.section_type_code, L1.meaning, S.status_code, L2.meaning,
    MSS.mini_site_section_section_id, MSS.object_version_number,
    MSS.start_date_active, MSS.end_date_active, MSS.sort_order
    FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS, fnd_lookups L1,
    fnd_lookups L2
    WHERE MSS.parent_section_id = p_section_id
    AND   MSS.child_section_id = S.section_id
    AND   MSS.mini_site_id = l_master_mini_site_id
    AND   L1.lookup_type = 'IBE_SECTION_TYPE'
    AND   L1.lookup_code = S.section_type_code
    AND   L2.lookup_type = 'IBE_SECTION_STATUS'
    AND   L2.lookup_code = S.status_code
        ---Added by amaheshw on 10.Jan.2008 bug 6712124. check end date also
    AND sysdate BETWEEN S.start_date_active AND NVL(S.end_date_active,sysdate)
   ORDER BY MSS.sort_order;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_ChildSections_For_Section;

--
-- Returns child-sections or child-items for the given section
-- Return data (association + child section + section data) or
-- (association + item + section data) belonging to the section (p_section_id)
-- x_sectionitem_section_csr will be returned for child-items or
-- x_section_section_csr will be returned for child-sections
-- x_is_leaf_section will be returned if p_section_id is a leaf section
-- A section will be a leaf section if it has items associated to it or
-- it has neither items nor sections associated to it. It will be a non-leaf
-- section only when there are child-sections associated to it.
--
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
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_Children_For_Section';
  l_api_version             CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id     NUMBER;
  l_master_root_section_id  NUMBER;
  l_row_id                  VARCHAR2(30);

  -- Check if l_c_section_id has child sections
  CURSOR c1(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER) IS
    SELECT rowid FROM ibe_dsp_msite_sct_sects
      WHERE mini_site_id = l_c_master_mini_site_id
      AND parent_section_id = l_c_section_id;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the master mini-site id
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id
    (
    x_mini_site_id      => l_master_mini_site_id,
    x_root_section_id   => l_master_root_section_id
    );

  -- Get the section path
  BEGIN
    x_section_path := Get_Display_Name('S', p_section_id);
  EXCEPTION
     WHEN OTHERS THEN
       x_section_path := '';
  END;

  -- Check if p_section_id is a leaf section or not. If it has child-sections,
  -- then it is not a leaf section
  OPEN c1(p_section_id, l_master_mini_site_id);
  FETCH c1 INTO l_row_id;
  IF (c1%NOTFOUND) THEN
    x_is_leaf_section := 'Y';
    Load_SectionItems_For_Section
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_section_id                     => p_section_id,
      x_section_csr                    => x_section_csr,
      x_sectionitem_item_csr           => x_sectionitem_item_csr,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_LOAD_CHILD_ITM_FOR_SCT');
      FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE

    x_is_leaf_section := 'N';
    Load_ChildSections_For_Section
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_section_id                     => p_section_id,
      x_section_csr                    => x_section_csr,
      x_section_section_csr            => x_section_section_csr,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_LOAD_CHILD_SCT_FOR_SCT');
      FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  CLOSE c1;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_Children_For_Section;

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
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_Section_For_Basic_Desc';
  l_api_version             CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id     NUMBER;
  l_master_root_section_id  NUMBER;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the section data
  OPEN x_section_csr FOR SELECT section_id, object_version_number,
    display_name, access_name, section_type_code, status_code,
    start_date_active, end_date_active, description, long_description,
    keywords, deliverable_id, display_context_id, auto_placement_rule,
    order_by_clause
    FROM ibe_dsp_sections_vl
    WHERE section_id = p_section_id;

  -- Get the section path
  BEGIN
    x_section_path := Get_Display_Name('S', p_section_id);
  EXCEPTION
     WHEN OTHERS THEN
       x_section_path := '';
  END;

  -- Get the 'list of section type' cursor
  OPEN x_section_type_csr FOR SELECT lookup_code, meaning FROM fnd_lookups
    WHERE lookup_type = 'IBE_SECTION_TYPE';

  -- Get the 'list of section type' cursor
  OPEN x_section_status_csr FOR SELECT lookup_code, meaning FROM fnd_lookups
    WHERE lookup_type = 'IBE_SECTION_STATUS';

  -- Get the deliverable list
  -- bug 3610994
  OPEN x_deliverable_csr FOR SELECT item_id, access_name, item_name
    FROM jtf_amv_items_vl
    WHERE deliverable_type_code = 'TEMPLATE'
    AND applicable_to_code LIKE '%SECTION'
    AND application_id= 671;

  -- Get the display context list
  OPEN x_display_context_csr FOR SELECT context_id, access_name, name
    FROM ibe_dsp_context_vl
    WHERE context_type_code = 'TEMPLATE';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_Section_For_Basic_Desc;

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
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_Root_Sct_For_Basic_Desc';
  l_api_version             CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id     NUMBER;
  l_master_root_section_id  NUMBER;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get the master mini-site id
  --
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id
    (
    x_mini_site_id      => l_master_mini_site_id,
    x_root_section_id   => l_master_root_section_id
    );

  --
  -- Load root section's basic description
  --
  Load_Section_For_Basic_Desc
    (
    p_api_version                    => p_api_version,
    p_init_msg_list                  => FND_API.G_FALSE,
    p_commit                         => FND_API.G_FALSE,
    p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
    p_section_id                     => l_master_root_section_id,
    x_section_path                   => x_section_path,
    x_section_csr                    => x_section_csr,
    x_section_type_csr               => x_section_type_csr,
    x_section_status_csr             => x_section_status_csr,
    x_deliverable_csr                => x_deliverable_csr,
    x_display_context_csr            => x_display_context_csr,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_Root_Sct_For_Basic_Desc;

--
-- Get the list of candidate mini-sites for a section, i.e., the list of all
-- the mini-sites to which the section can be associated with. Also get all
-- the sites to which the section is included into.
-- Also get the available_in_all_sites flag for the section in x_section_csr
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Cand_Incl_MSites_For_Sct';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;
  l_parent_section_id            NUMBER;

  CURSOR c1(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT parent_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_mini_site_id
    AND child_section_id = l_c_section_id;

BEGIN

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get the master mini-site id
  --
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id
    (
    x_mini_site_id      => l_master_mini_site_id,
    x_root_section_id   => l_master_root_section_id
    );

  --
  -- Get the parent section for p_section_id
  --
  OPEN c1(p_section_id, l_master_mini_site_id);
  FETCH c1 INTO l_parent_section_id;
  IF (c1%NOTFOUND) THEN
    l_parent_section_id := null;
  END IF;
  CLOSE c1;

  --
  -- Get the section data for p_section_id
  --
  OPEN x_section_csr FOR SELECT section_id, object_version_number,
    display_name, available_in_all_sites_flag
    FROM ibe_dsp_sections_vl
    WHERE section_id = p_section_id;

  -- Get the section path
  BEGIN
    x_section_path := Get_Display_Name('S', p_section_id);
  EXCEPTION
     WHEN OTHERS THEN
       x_section_path := '';
  END;

  --
  -- Get included mini-sites for a section
  --
  OPEN x_incl_mini_site_csr FOR SELECT msite_id, msite_name, msite_description
    FROM ibe_msites_vl
    WHERE EXISTS
    (SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = msite_id
    AND mini_site_id <> l_master_mini_site_id
    AND child_section_id = p_section_id)
    ORDER BY msite_name;

  --
  -- Get candidate mini-sites for a section
  --
  IF (l_parent_section_id IS NOT NULL) THEN
    --
    -- Get candidate mini-sites for a section, which includes the mini-sites to
    -- which the section's parent section belong to, plus the one's to which
    -- the section is the mini-site's root section
    --
    OPEN x_cndt_mini_site_csr FOR SELECT msite_id, msite_name,
      msite_description
      FROM ibe_msites_vl
      WHERE msite_id <> l_master_mini_site_id AND
      (msite_root_section_id = p_section_id OR
      EXISTS (SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
      WHERE mini_site_id = msite_id
      AND mini_site_id <> l_master_mini_site_id
      AND child_section_id = l_parent_section_id))
      ORDER BY msite_name;
  ELSE
    --
    -- Parent section ID is null (or p_section_id is root section id),
    -- therefor list of candidate sites will be all the mini-sites in
     -- ibe_msites_b table for which the msite_root_section is null or the master root section id
    --
    OPEN x_cndt_mini_site_csr FOR SELECT msite_id, msite_name,
      msite_description
      FROM ibe_msites_vl
      WHERE msite_id <> l_master_mini_site_id
	--bug 3410883
      AND (msite_root_section_id = l_master_root_section_id or msite_root_section_id is null)
      AND site_type = 'I'
      ORDER BY msite_name;

  END IF;

  --
  -- End of main API body.

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Get_Cand_Incl_MSites_For_Sct;

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
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_Items_For_Basic_Desc';
  l_api_version             CONSTANT NUMBER       := 1.0;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the item data
  OPEN x_inventory_item_csr FOR SELECT inventory_item_id, organization_id,
    web_status, description, long_description, concatenated_segments,
    creation_date, last_updated_by, last_update_login, last_update_date
    FROM mtl_system_items_vl
    WHERE inventory_item_id = p_inventory_item_id
    AND organization_id = p_organization_id;

  -- Get the 'list of item web status type' cursor
  OPEN x_web_status_type_csr FOR SELECT lookup_code, meaning FROM fnd_lookups
    WHERE lookup_type = 'IBE_ITEM_STATUS';

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_Items_For_Basic_Desc;

--
-- Get the list of candidate mini-sites for an item, i.e., the list of all
-- the mini-sites to which the item can be associated with. Also get all
-- the sites to which the item is included into.
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Cand_Incl_MSites_For_Itm';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;

BEGIN

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get the master mini-site id
  --
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id
    (
    x_mini_site_id      => l_master_mini_site_id,
    x_root_section_id   => l_master_root_section_id
    );

  --
  -- Get the item data
  --
  OPEN x_inventory_item_csr FOR SELECT MTL.inventory_item_id,
    MTL.organization_id, MTL.web_status, L.meaning, MTL.description,
    MTL.concatenated_segments, MTL.creation_date, MTL.last_updated_by,
    MTL.last_update_login, MTL.last_update_date
    FROM mtl_system_items_vl MTL, fnd_lookups L
    WHERE MTL.inventory_item_id = p_inventory_item_id
    AND MTL.organization_id = p_organization_id
    AND L.lookup_type = 'IBE_ITEM_STATUS'
    AND L.lookup_code = MTL.web_status;

  --
  -- Get included mini-sites for item
  --
  OPEN x_incl_mini_site_csr FOR SELECT msite_id, msite_name, msite_description
    FROM ibe_msites_vl
    WHERE EXISTS
    (SELECT mini_site_id FROM ibe_dsp_msite_sct_items
    WHERE mini_site_id = msite_id
    AND section_item_id IN
    (SELECT section_item_id FROM ibe_dsp_section_items
    WHERE inventory_item_id = p_inventory_item_id
    AND organization_id = p_organization_id))
    ORDER BY msite_name;

  --
  -- Get candidate mini-sites for item
  --
  OPEN x_cndt_mini_site_csr FOR SELECT msite_id, msite_name, msite_description
    FROM ibe_msites_vl
    WHERE EXISTS
    (SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = msite_id
    AND mini_site_id <> l_master_mini_site_id
    AND child_section_id IN
    (SELECT section_id FROM ibe_dsp_section_items
    WHERE inventory_item_id = p_inventory_item_id
    AND organization_id = p_organization_id))
    ORDER BY msite_name;

  --
  -- End of main API body.

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Get_Cand_Incl_MSites_For_Itm;


--
-- Obsoleted and Removed code for the PROCEDURE Get_Item_Id_List :bug 2936693 :05/09/2003 :abhandar
---
--
-- Obsoleted and Removed code for the PROCEDURE Get_Item_Info_For_Lookup :bug 2936693 :05/09/2003:abhandar
---
--
-- Obsoleted and Removed code for the PROCEDURE Get_Item_Info_For_Detail_List :bug 2936693 :05/09/2003:abhandar
---
--
-- Obsoleted and Removed code for the PROCEDURE Get_Section_Id_List :bug 2936693 :05/09/2003:abhandar
---
--
-- Obsoleted and Removedcode for the PROCEDURE Get_Section_Info_For_Lookup :bug 2936693 :05/09/2003:abhandar
---
--
--
-- Procedure to retrieve the   section hierarchy path
--

PROCEDURE Get_Section_Path
(
   p_section_id                     IN NUMBER,
   x_section_path                   OUT NOCOPY VARCHAR2,
   x_section_name                   OUT NOCOPY VARCHAR2,
   x_section_desc                   OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
  IS

   l_master_mini_site_id     NUMBER;
   l_position                NUMBER;
   l_master_root_section_id  NUMBER;

  Cursor c1( p_section_id  IN NUMBER) is
  select display_name,description
  from ibe_dsp_sections_vl where section_id=p_section_id;


BEGIN


  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the master mini-site id
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id
    (
    x_mini_site_id      => l_master_mini_site_id,
    x_root_section_id   => l_master_root_section_id
    );

  -- Get the section path
  BEGIN
    x_section_path := Get_Display_Name('S', p_section_id);

  EXCEPTION
     WHEN OTHERS THEN
       x_section_path := '';
   END;
  -- need to remove the last path from the section path string
  -- get the last occurence of  / in the string.
  SELECT INSTR(x_section_path,'/', -1, 1) into l_position FROM DUAL;

 -- get the substring  uptil the last '/'
 SELECT SUBSTR(x_section_path,1,l_position) into x_section_path from dual;

  -- get the section name and desc
  OPEN c1(p_section_id);
  FETCH c1 INTO x_section_name, x_section_desc;

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
  CLOSE c1;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END Get_Section_Path;

PROCEDURE Load_Section_Hierarchy
  (
   p_msite_id                       IN NUMBER,
   p_section_id                     IN NUMBER,
   p_level_number                   IN NUMBER,
   x_section_hierarchy_csr          OUT NOCOPY SECTION_HGRID_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
  IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Get_All_Section_Hierarchy';
   l_api_version             CONSTANT NUMBER       := 1.0;



BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_level_number >0 THEN

   --load the hgrid tree upto level= p_level_number
  OPEN x_section_hierarchy_csr FOR
   /*SELECT DISTINCT mss.parent_section_id,mss.child_section_id,
     s.display_name, mss.concat_ids, fl.meaning,s.status_code,  s.start_date_active,
     child_sct.parent_section_id subsections,child_item.section_id products,
     s.section_type_code, fl1.meaning status_name,s.access_name,MSS.level_number
     FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS ,fnd_lookups fl,
     fnd_lookups fl1, ibe_dsp_msite_sct_sects child_sct,ibe_dsp_section_items child_item
     WHERE S.section_id = MSS.child_section_id  AND fl.lookup_code=s.section_type_code
     and  fl.lookup_type= 'IBE_SECTION_TYPE' AND fl1.lookup_code=s.status_code
     AND  fl1.lookup_type= 'IBE_SECTION_STATUS' AND fl.enabled_flag = fl1.enabled_flag
     AND MSS.mini_site_id = p_msite_id   AND s.section_id = child_sct.parent_section_id (+)
     AND child_sct.mini_site_id (+)  = p_msite_id
     AND s.section_id = child_item.section_id (+)
     AND mss.level_number <= p_level_number
     ORDER BY MSS.level_number, mss.parent_section_id,s.display_name;

     SELECT DISTINCT mss.parent_section_id,mss.child_section_id,
     s.display_name, mss.concat_ids, s.status_code,s.start_date_active,
     child_sct.parent_section_id subsections,child_item.section_id products,
     s.section_type_code, s.access_name,MSS.level_number
     FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS ,
     ibe_dsp_msite_sct_sects child_sct,ibe_dsp_section_items child_item
     WHERE S.section_id = MSS.child_section_id
     AND MSS.mini_site_id = p_msite_id  AND s.section_id = child_sct.parent_section_id (+)
     AND child_sct.mini_site_id (+)  = p_msite_id
     AND s.section_id = child_item.section_id (+)
     AND mss.level_number <= p_level_number
     ORDER BY MSS.level_number, mss.parent_section_id,s.display_name;
     */
    SELECT DISTINCT mss.parent_section_id,mss.child_section_id,
     s.display_name, mss.concat_ids, s.status_code,s.start_date_active,
     s.section_type_code, s.access_name,MSS.level_number
     FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS
     WHERE S.section_id = MSS.child_section_id
     AND MSS.mini_site_id = p_msite_id
     AND mss.level_number <= p_level_number
     ORDER BY MSS.level_number, mss.parent_section_id,s.display_name;

  ELSE
   -- load the whole hgrid tree data
  OPEN x_section_hierarchy_csr FOR
 /*  SELECT DISTINCT mss.parent_section_id,mss.child_section_id,
     s.display_name, mss.concat_ids, fl.meaning,s.status_code,  s.start_date_active,
     child_sct.parent_section_id subsections,child_item.section_id products,
     s.section_type_code, fl1.meaning status_name,s.access_name,MSS.level_number
     FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS ,fnd_lookups fl,
     fnd_lookups fl1, ibe_dsp_msite_sct_sects child_sct,ibe_dsp_section_items child_item
     WHERE S.section_id = MSS.child_section_id  AND fl.lookup_code=s.section_type_code
     and  fl.lookup_type= 'IBE_SECTION_TYPE' AND fl1.lookup_code=s.status_code
     AND  fl1.lookup_type= 'IBE_SECTION_STATUS' AND fl.enabled_flag = fl1.enabled_flag
     AND MSS.mini_site_id = p_msite_id   AND s.section_id = child_sct.parent_section_id (+)
     AND child_sct.mini_site_id (+)  = p_msite_id
     AND s.section_id = child_item.section_id (+)
     ORDER BY MSS.level_number, mss.parent_section_id,s.display_name;

     SELECT DISTINCT mss.parent_section_id,mss.child_section_id,
     s.display_name, mss.concat_ids, s.status_code,s.start_date_active,
     child_sct.parent_section_id subsections,child_item.section_id products,
     s.section_type_code, s.access_name,MSS.level_number
     FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS ,
     ibe_dsp_msite_sct_sects child_sct,ibe_dsp_section_items child_item
     WHERE S.section_id = MSS.child_section_id
     AND MSS.mini_site_id = p_msite_id  AND s.section_id = child_sct.parent_section_id (+)
     AND child_sct.mini_site_id (+)  = p_msite_id
     AND s.section_id = child_item.section_id (+)
     ORDER BY MSS.level_number, mss.parent_section_id,s.display_name;
*/
   SELECT DISTINCT mss.parent_section_id,mss.child_section_id,
     s.display_name, mss.concat_ids, s.status_code,s.start_date_active,
     s.section_type_code, s.access_name,MSS.level_number
     FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS
     WHERE S.section_id = MSS.child_section_id
     AND MSS.mini_site_id = p_msite_id
     ORDER BY MSS.level_number, mss.parent_section_id,s.display_name;

   END if;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Load_Section_Hierarchy;
END IBE_DSP_HIERARCHY_QUERY_PVT;

/
