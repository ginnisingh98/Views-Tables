--------------------------------------------------------
--  DDL for Package Body IBE_DSP_HIERARCHY_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DSP_HIERARCHY_SETUP_PVT" AS
/* $Header: IBEVCHSB.pls 120.3 2005/12/28 13:21:13 savarghe ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBE_DSP_HIERARCHY_SETUP_PVT
  --
  -- PURPOSE
  --   Private API for saving, retrieving and updating sections.
  --
  -- NOTES
  --   This is a pulicly accessible pacakge.  It should be used by all
  --   sources for saving, retrieving and updating personalized queries
  -- within the personalization framework.
  --

  -- HISTORY
  --   11/28/99           VPALAIYA         Created
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) and Debug (Bug # 2691710) Changes.
  --   12/19/02           SCHAK         Modified for reverting Debug (IBEUtil) Changes.
  --   12/21/02           SCHAK         Modified for NOCOPY (Bug # 2691704)) Changes and adding exceptions.
  --   07/21/04           SVIJAYKR      Modified for performance bug (Bug # 3765932) - removed literals from cursor query

  -- **********************************************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):='IBE_DSP_HIERAHCY_SETUP_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):='IBEVCHSB.pls';
G_ENABLE_TRACE VARCHAR2(1) := 'N';

TYPE section_map_rec IS RECORD
  (
    from_section_id   NUMBER,
    to_section_id     NUMBER
  );

TYPE section_map_list IS TABLE OF section_map_rec;

--
-- get master mini site id for the store
--
PROCEDURE Get_Master_Mini_Site_Id
  (
   x_mini_site_id    OUT NOCOPY NUMBER,
   x_root_section_id OUT NOCOPY NUMBER
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Master_Mini_Site_Id';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  CURSOR c1 IS
    SELECT msite_id, msite_root_section_id FROM ibe_msites_b
      WHERE UPPER(master_msite_flag) = 'Y';
BEGIN

  OPEN c1;
  FETCH c1 INTO x_mini_site_id, x_root_section_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c1;

END Get_Master_Mini_Site_Id;

--
-- get concatenation of all section ids starting with the p_section_id
--
PROCEDURE Get_Concat_Ids
  (
   p_section_id          IN  NUMBER,
   p_master_mini_site_id IN  NUMBER,
   x_concat_ids          OUT NOCOPY VARCHAR2,
   x_level_number        OUT NOCOPY NUMBER
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'Get_Concat_Ids';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_delimiter                    CONSTANT VARCHAR2(1)  := '.';

  --
  -- Get the list of ancestors for l_c_section_id upto the root section
  --
  CURSOR c1(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER) IS
    SELECT parent_section_id FROM ibe_dsp_msite_sct_sects
      WHERE parent_section_id IS NOT NULL
      AND mini_site_id = l_c_master_mini_site_id
      START WITH child_section_id = l_c_section_id
      CONNECT BY PRIOR parent_section_id = child_section_id
      AND PRIOR mini_site_id = l_c_master_mini_site_id
      AND mini_site_id = l_c_master_mini_site_id;
BEGIN

  x_concat_ids := p_section_id;
  x_level_number := 1;
  FOR r1 IN c1(p_section_id, p_master_mini_site_id) LOOP
    x_concat_ids := r1.parent_section_id || l_delimiter || x_concat_ids;
    x_level_number := x_level_number + 1;
  END LOOP;

EXCEPTION

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Concat_Ids;

PROCEDURE Delete_Recursive_Sections
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_master_mini_site_id            IN NUMBER,
   p_section_id                     IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Delete_Recursive_Sections';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;
  l_child_section_id             NUMBER;
  l_mini_site_id                 NUMBER;
  l_count                        NUMBER := -1;

  CURSOR c1(l_c_section_id IN NUMBER) IS
    SELECT child_section_id FROM ibe_dsp_msite_sct_sects
      WHERE parent_section_id = l_c_section_id AND
      mini_site_id = p_master_mini_site_id;

BEGIN

  -- cannot have savepoints within a recursively called function

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check if p_section_id has any children, if yes, then delete recursively
  -- else delete the current section and return

  OPEN c1(p_section_id);
  FETCH c1 INTO l_child_section_id;
  IF (c1%NOTFOUND) THEN
    -- p_section_id is a leaf section, delete it
    CLOSE c1;

    IBE_DSP_SECTION_GRP.Delete_Section
      (
      p_api_version         => p_api_version,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_section_id          => p_section_id,
      p_access_name         => FND_API.G_MISS_CHAR,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE

    -- p_section_id is not a leaf section, so delete its children

    LOOP -- first time loop already has a valid l_child_section_id

      Delete_Recursive_Sections
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_master_mini_site_id            => p_master_mini_site_id,
        p_section_id                     => l_child_section_id,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RECUR_SCT_DEL_FAIL');
        FND_MESSAGE.Set_Token('SECTION_ID', l_child_section_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RECUR_SCT_DEL_FAIL');
        FND_MESSAGE.Set_Token('SECTION_ID', l_child_section_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FETCH c1 INTO l_child_section_id;
      EXIT WHEN c1%NOTFOUND;

    END LOOP;

    CLOSE c1;

    -- after deleting the child of p_section_id, delete itself
    IBE_DSP_SECTION_GRP.Delete_Section
      (
      p_api_version         => p_api_version,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_section_id          => p_section_id,
      p_access_name         => FND_API.G_MISS_CHAR,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

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

END Delete_Recursive_Sections;

--
-- Associate the section (p_section_id) and all its valid descendants
-- (i.e. with available_for_all_sites_flag = 'Y') to mini-site p_mini_site_id
-- This procedure also makes the association for the p_mini_site_id with the
-- descendants section items.
-- Assumption: p_section_id will be associated with p_mini_site_id irrespective
-- of its available_for_all_sites_flag
--
PROCEDURE Associate_Recursive_MSite_Sct
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   p_mini_site_id                   IN NUMBER,
   p_master_mini_site_id            IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Recursive_MSite_Sct';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_are_subsections_present      BOOLEAN;
  l_section_id                   NUMBER;
  l_child_section_id             NUMBER;
  l_mini_site_id                 NUMBER;
  l_mini_site_section_section_id NUMBER;
  l_mini_site_section_item_id    NUMBER;
  l_count                        NUMBER := -1;

  --
  -- Get the detail info for MSS association for l_c_section_id from the
  -- master mini-site's entry
  --
  CURSOR c1(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT parent_section_id, child_section_id, start_date_active,
    end_date_active, sort_order
    FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id;

  --
  -- Get all the children sections for l_c_section_id which have
  -- available_in_all_sites_flag set to 'Y' (for master mini-site)
  --
  CURSOR c2(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT S.section_id AS s_section_id
    FROM ibe_dsp_msite_sct_sects MSS, ibe_dsp_sections_b S
    WHERE MSS.child_section_id = S.section_id
    AND MSS.parent_section_id = l_c_section_id
    AND MSS.mini_site_id = l_c_master_mini_site_id
    AND S.available_in_all_sites_flag = 'Y';

  --
  -- Get all the children items for the section l_c_section_id
  --
  CURSOR c3(l_c_section_id IN NUMBER)
  IS SELECT section_item_id
    FROM ibe_dsp_section_items
    WHERE section_id = l_c_section_id;

BEGIN

  -- cannot have savepoints within a recursively called function

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Associate the section p_section_id to mini-site p_mini_site_id
  --
  -- todo change logic here to have open, fetch, close instead, and test
  --
  FOR r1 IN c1(p_section_id, p_master_mini_site_id) LOOP

    IBE_DSP_MSITE_SCT_SECT_PVT.Create_MSite_Section_Section
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_mini_site_id                   => p_mini_site_id,
      p_parent_section_id              => r1.parent_section_id,
      p_child_section_id               => r1.child_section_id,
      p_start_date_active              => r1.start_date_active,
      p_end_date_active                => r1.end_date_active,
      p_level_number                   => FND_API.G_MISS_NUM,
      p_sort_order                     => r1.sort_order,
      p_concat_ids                     => FND_API.G_MISS_CHAR,
      x_mini_site_section_section_id   => l_mini_site_section_section_id,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- as there should be only one entry returned from c1
    EXIT;

  END LOOP; -- end loop r1

  --
  -- Associate the child sections of p_section_id with p_mini_site_id
  -- which will be done in calling this same procedure recursively
  --

  -- Flag which will used to determine if p_section_id has sub-sections or
  -- not. If it does not, then it is possible that it has items as children
  l_are_subsections_present := FALSE;
  FOR r2 IN c2(p_section_id, p_master_mini_site_id) LOOP

    l_are_subsections_present := TRUE;

    Associate_Recursive_MSite_Sct
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_section_id                     => r2.s_section_id,
      p_mini_site_id                   => p_mini_site_id,
      p_master_mini_site_id            => p_master_mini_site_id,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RCR_MSITE_SCT_ASC_FAIL');
      FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
      FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RCR_MSITE_SCT_ASC_FAIL');
      FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
      FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

  --
  -- p_section_id doesn't have children sections, its possible that it may
  -- have children items. For those items, create an entry in MSI table
  --
  IF (NOT l_are_subsections_present) THEN

    FOR r3 IN c3(p_section_id) LOOP

      -- Notes: start_date_active is not used in MSI, therefore adding
      -- beginning of time value
      IBE_DSP_MSITE_SCT_ITEM_PVT.Create_MSite_Section_Item
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_mini_site_id                   => p_mini_site_id,
        p_section_item_id                => r3.section_item_id,
        p_start_date_active              => sysdate,
        p_end_date_active                => FND_API.G_MISS_DATE,
        x_mini_site_section_item_id      => l_mini_site_section_item_id,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP; -- end loop r3

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

END Associate_Recursive_MSite_Sct;

FUNCTION Get_Layout_Type(p_deliverable_id IN NUMBER) RETURN VARCHAR2
IS
  CURSOR c_get_layout_type_csr(c_item_id NUMBER) IS
    SELECT access_name, applicable_to_code
      FROM jtf_amv_items_b
     WHERE item_id = c_item_id
	  AND deliverable_type_code = 'TEMPLATE';

  l_access_name VARCHAR2(40);
  l_applicable_to_code VARCHAR2(40);
BEGIN
  IF ((p_deliverable_id IS NULL) OR (p_deliverable_id = -1)) THEN
    RETURN 'F';
  ELSE
    OPEN c_get_layout_type_csr(p_deliverable_id);
    FETCH c_get_layout_type_csr INTO l_access_name, l_applicable_to_code;
    IF (c_get_layout_type_csr%NOTFOUND) THEN
      CLOSE c_get_layout_type_csr;
      RETURN 'F';
    END IF;
    CLOSE c_get_layout_type_csr;
    IF (l_applicable_to_code = 'SECTION_LAYOUT') THEN
      IF (l_access_name = 'STORE_CTLG_SCT_COMMON') THEN
	   RETURN 'F';
	 ELSE
        RETURN 'C';
      END IF;
    ELSE
      RETURN 'F';
    END IF;
  END IF;
END Get_Layout_Type;

-- This procedure will check the layout type of a section.
-- layout type has following two choices:
-- 1) F - section is using fixed layout
-- 2) C - section is using configurable layout
--
PROCEDURE Get_Sect_Layout_Type(p_section_id IN NUMBER,
                          x_deliverable_id OUT NOCOPY NUMBER,
					 x_layout_type OUT NOCOPY VARCHAR2)
IS
  CURSOR c_get_deliverable_id_csr(c_section_id NUMBER) IS
    SELECT deliverable_id
      FROM ibe_dsp_sections_b
     WHERE section_id = c_section_id;

  l_deliverable_id NUMBER;
BEGIN
  OPEN c_get_deliverable_id_csr(p_section_id);
  FETCH c_get_deliverable_id_csr INTO l_deliverable_id;
  IF (c_get_deliverable_id_csr%NOTFOUND) THEN
    CLOSE c_get_deliverable_id_csr;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE c_get_deliverable_id_csr;
  x_layout_type := Get_Layout_Type(l_deliverable_id);
  x_deliverable_id := l_deliverable_id;
END Get_Sect_Layout_Type;

-- This procedure will copy the layout component mapping from
-- parent section to the child section when the section is using
-- new configurable layout.
-- If the section is not using any layout (blank in deliverable_id)
-- or using old standard layout, then no layout component mapping
-- will be copied over.
PROCEDURE Copy_Layout_Comp_Mapping
(p_api_version       IN NUMBER,
 p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
 p_commit            IN VARCHAR2 := FND_API.G_FALSE,
 p_source_section_id IN NUMBER,
 p_target_section_id  IN NUMBER,
 p_include_all       IN VARCHAR2 := FND_API.G_FALSE,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2)
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'copy_layout_comp_mapping';
 l_api_version CONSTANT NUMBER := 1.0;
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_return_status     VARCHAR2(1);

 l_msg_count NUMBER;
 l_msg_data VARCHAR2(4000);

 -- Call save_logical_content to save the layout component
 -- mapping inherit from the parent
 l_lgl_ctnt_rec IBE_LogicalContent_GRP.OBJ_LGL_CTNT_REC_TYPE;
 l_lgl_ctnt_tbl IBE_LogicalContent_GRP.OBJ_LGL_CTNT_TBL_TYPE;

 l_source_deliverable_id NUMBER;
 l_source_layout_type VARCHAR2(1);

 CURSOR c_get_component_mapping_all(c_section_id NUMBER) IS
   SELECT obj.item_id, obj.context_id, obj.object_type
     FROM ibe_dsp_obj_lgl_ctnt obj,  ibe_dsp_context_b context
    WHERE obj.object_id = c_section_id
      AND obj.object_type = 'S'
	 AND obj.context_id = context.context_id
	 AND context.context_type_code = 'LAYOUT_COMPONENT';
	--  AND context.component_type_code <> 'OLD_PROCESS';

  -- Specific layout component templates are excluded
  -- for example, subsection, featured section, product section
  -- old process template
  CURSOR c_get_component_mapping(c_section_id NUMBER) IS
    SELECT obj.item_id, obj.context_id, obj.object_type
      FROM ibe_dsp_obj_lgl_ctnt obj,  ibe_dsp_context_b context
     WHERE obj.object_id = c_section_id
	  AND obj.object_type = 'S'
	  AND obj.context_id = context.context_id
	  AND context.context_type_code = 'LAYOUT_COMPONENT'
	  AND context.access_name <> 'CENTER';
	 -- AND context.component_type_code <> 'OLD_PROCESS'

BEGIN
  SAVEPOINT copy_layout_comp_mapping;
  IF NOT FND_API.compatible_api_call(l_api_version,
       p_api_version, l_api_name, g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.g_ret_sts_success;

  Get_Sect_Layout_Type(p_section_id => p_source_section_id,
    x_deliverable_id => l_source_deliverable_id,
    x_layout_type => l_source_layout_type);

  IF (l_source_layout_type = 'C') THEN
    -- Bulk collection will be used for inserting the data into mapping table
    IF (p_include_all = FND_API.G_FALSE) THEN
      DELETE FROM ibe_dsp_obj_lgl_ctnt obj
	   WHERE obj.object_id = p_target_section_id
	     AND obj.object_type = 'S'
		AND EXISTS (
		  SELECT 1
		    FROM ibe_dsp_context_b context
             WHERE obj.context_id = context.context_id
		     AND context.context_type_code = 'LAYOUT_COMPONENT')
		AND NOT EXISTS(
              SELECT 1
                FROM ibe_dsp_context_b context, ibe_dsp_obj_lgl_ctnt obj1
               WHERE obj1.context_id = obj.context_id
			  AND obj1.context_id = context.context_id
			  AND obj1.object_id = p_source_section_id
			  AND obj1.object_type = 'S'
			  AND context.context_type_code = 'LAYOUT_COMPONENT'
			  AND context.component_type_code <> 'CENTER');
		--  AND context.component_type_code <> 'OLD_PROCESS'
      -- Component mapping except old processing and center display template
      FOR mapping IN c_get_component_mapping(p_source_section_id) LOOP
	   UPDATE ibe_dsp_obj_lgl_ctnt
           SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
               ITEM_ID = mapping.item_id,
               CREATED_BY = FND_GLOBAL.user_id,
	          CREATION_DATE = SYSDATE,
               LAST_UPDATED_BY = FND_GLOBAL.user_id,
		     LAST_UPDATE_DATE = SYSDATE,
			LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
	   WHERE object_id = p_target_section_id
	     AND object_type = 'S'
	     AND context_id = mapping.context_id;
        IF sql%NOTFOUND THEN
          INSERT INTO ibe_dsp_obj_lgl_ctnt(OBJ_LGL_CTNT_ID,
            OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE,
            LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID, CONTEXT_ID, OBJECT_TYPE, OBJECT_ID,
            ITEM_ID)
          VALUES(ibe_dsp_obj_lgl_ctnt_s1.NEXTVAL,1,FND_GLOBAL.user_id,SYSDATE,
            FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.login_id, NULL,
            mapping.context_id, 'S', p_target_section_id, mapping.item_id);
	   END IF;
	 END LOOP;
    ELSE
      -- Component exclude old processing
      DELETE FROM ibe_dsp_obj_lgl_ctnt obj
	   WHERE obj.object_id = p_target_section_id
	     AND obj.object_type = 'S'
		AND EXISTS (
		  SELECT 1
		    FROM ibe_dsp_context_b context
             WHERE obj.context_id = context.context_id
		     AND context.context_type_code = 'LAYOUT_COMPONENT')
		AND NOT EXISTS(
              SELECT 1
                FROM ibe_dsp_context_b context, ibe_dsp_obj_lgl_ctnt obj1
               WHERE obj1.context_id = obj.context_id
			  AND obj1.context_id = context.context_id
			  AND obj1.object_id = p_source_section_id
			  AND obj1.object_type = 'S'
			  AND context.context_type_code = 'LAYOUT_COMPONENT');
			--  AND context.component_type_code <> 'OLD_PROCESS');
      FOR mapping IN c_get_component_mapping_all(p_source_section_id) LOOP
	   UPDATE ibe_dsp_obj_lgl_ctnt
          SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
              ITEM_ID = mapping.item_id,
              CREATED_BY = FND_GLOBAL.user_id,
		    CREATION_DATE = SYSDATE,
              LAST_UPDATED_BY = FND_GLOBAL.user_id,
		    LAST_UPDATE_DATE = SYSDATE,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
	     WHERE object_id = p_target_section_id
		  AND object_type = 'S'
		  AND context_id = mapping.context_id;
        IF sql%NOTFOUND THEN
          INSERT INTO ibe_dsp_obj_lgl_ctnt(OBJ_LGL_CTNT_ID,
            OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE,
            LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID, CONTEXT_ID, OBJECT_TYPE, OBJECT_ID,
            ITEM_ID)
          VALUES(ibe_dsp_obj_lgl_ctnt_s1.NEXTVAL,1,FND_GLOBAL.user_id,SYSDATE,
              FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.login_id, NULL,
              mapping.context_id, 'S', p_target_section_id, mapping.item_id);
	   END IF;
	 END LOOP;
    END IF;
  END IF;
  --
  -- End of main API body.
  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
					   p_encoded =>      'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO copy_layout_comp_mapping;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_layout_comp_mapping;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO copy_layout_comp_mapping;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
	 p_encoded => 'F');
END Copy_Layout_Comp_Mapping;

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
   p_inherit_layout                 IN VARCHAR2,
   x_section_id                     OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Create_Hierarchy_Section';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_item_id              NUMBER;
  l_parent_section_id            NUMBER;
  l_parent_section_type_code     VARCHAR2(30);
  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;
  l_mini_site_section_section_id NUMBER;
  l_concat_ids                   VARCHAR2(2000);
  l_level_number                 NUMBER;
  l_tmp_id                       NUMBER;

  -- assuming non-root section is to be created, unless otherwise found
  l_is_root_section              BOOLEAN := FALSE;

  -- For 11.5.10
  -- This flag will be checked to see if use configurable layout
  -- or standard layout (old). By default, configurable layout will
  -- be used
  l_use_configurable_layout BOOLEAN := TRUE;
  l_deliverable_id NUMBER;
  l_parent_deli_id NUMBER := NULL;
  l_parent_layout_type VARCHAR2(1) := NULL;
  -- Need to access name to the new seed configurable layout template
  -- access name
  -- Make the cursor query use bind variables

  l_access_name                  VARCHAR2(50);
  l_deliverable_type_code        VARCHAR2(50);
  l_applicable_to_code           VARCHAR2(50);
  l_application_id               NUMBER;

  CURSOR c_get_configurable_csr(l_c_access_name IN VARCHAR2,
                                l_c_deliverable_type_code IN VARCHAR2,
                                l_c_applicable_to_code IN VARCHAR2,
                                l_c_application_id IN NUMBER ) IS
    SELECT item_id
      FROM jtf_amv_items_b
     WHERE access_name = l_c_access_name
      AND deliverable_type_code = l_c_deliverable_type_code
      AND applicable_to_code = l_c_applicable_to_code
      AND application_id = l_c_application_id;

  CURSOR c1(l_c_section_id IN NUMBER)
  IS SELECT section_type_code
    FROM ibe_dsp_sections_b
    WHERE section_id = l_c_section_id;

  CURSOR c2(l_c_access_name IN VARCHAR2)
  IS SELECT section_id, section_type_code
    FROM ibe_dsp_sections_b
    WHERE access_name = l_c_access_name;

  CURSOR c3(l_c_section_id IN NUMBER)
  IS SELECT section_item_id
    FROM ibe_dsp_section_items
    WHERE section_id = l_c_section_id;

  CURSOR c4 IS SELECT msite_root_section_id
    FROM ibe_msites_b
    WHERE master_msite_flag = 'Y';

  CURSOR c5(l_c_master_mini_site_id IN NUMBER)
  IS SELECT msite_id
    FROM ibe_msites_vl
    WHERE msite_id <> l_c_master_mini_site_id;

  CURSOR c6(l_c_master_mini_site_id IN NUMBER,
    l_c_section_id IN NUMBER,
    l_c_parent_section_id IN NUMBER)
  IS SELECT msite_id
    FROM ibe_msites_vl
    WHERE msite_id <> l_c_master_mini_site_id AND
    (msite_root_section_id = l_c_section_id OR
    EXISTS (SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = msite_id
    AND mini_site_id <> l_c_master_mini_site_id
    AND child_section_id = l_c_parent_section_id));

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  CREATE_HIERARCHY_SECTION_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Give values to cursor variables for c_get_configurable_crsr
  l_access_name           := 'STORE_SCT_CONFIGURABLE_LAYOUT';
  l_deliverable_type_code := 'TEMPLATE';
  l_applicable_to_code    := 'SECTION_LAYOUT';
  l_application_id        := 671;



  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get parent section id
  -- Check if either p_parent_section_id or p_parent_section_access_name
  -- is defined
  --
  IF ((p_parent_section_id IS NOT NULL) AND
      (p_parent_section_id <> FND_API.G_MISS_NUM))
  THEN

    l_parent_section_id := p_parent_section_id; -- parent_section_id specified

    OPEN c1(l_parent_section_id);
    FETCH c1 INTO l_parent_section_type_code;
    IF c1%NOTFOUND THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ID');
      FND_MESSAGE.Set_Token('SECTION_ID', l_parent_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSIF ((p_parent_section_access_name IS NOT NULL) AND
         (p_parent_section_access_name <> FND_API.G_MISS_CHAR))
  THEN
    --    query for parent section id
    OPEN c2(p_parent_section_access_name);
    FETCH c2 INTO l_parent_section_id, l_parent_section_type_code;
    IF (c2%NOTFOUND) THEN
      CLOSE c2;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_SCT_ACSS_NAME');
      FND_MESSAGE.Set_Token('ACCESS_NAME', p_parent_section_access_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c2;

  ELSE
    -- neither parent section id nor access name is specified
    -- This means the section to be added is a root section, i.e., with no
    -- parent
    l_is_root_section := TRUE;
    l_parent_section_id := NULL;
  END IF;

  IF (l_is_root_section) THEN
    -- Make sure that there is no other root section id
    OPEN c4;
    FETCH c4 INTO l_tmp_id;
    IF (c4%NOTFOUND) THEN
      CLOSE c4;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_MASTER_MSITE_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      CLOSE c4;
      IF (l_tmp_id IS NOT NULL) THEN
      -- already a root section defined
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_ROOT_SCT_ALREADY_DEF');
      FND_MESSAGE.Set_Token('SECTION_ID', l_tmp_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  ELSE
    -- check if the parent section is a navigational type section
    -- if not, throw error
    IF (l_parent_section_type_code <> 'N') THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_PRNT_SCT_NOT_NAV');
      FND_MESSAGE.Set_Token('SECTION_ID', l_parent_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check if the parent section (which is navigational) doesn't have
    -- children as items. If there are child items for a section, then cannot
    -- add child section to it
    OPEN c3(l_parent_section_id);
    FETCH c3 INTO l_section_item_id;
    IF (c3%FOUND) THEN
      CLOSE c3;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_PRNT_SCT_HAS_CHILD_ITM');
      FND_MESSAGE.Set_Token('SECTION_ID', l_parent_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c3;

  END IF; -- end l_is_root_section

  --
  -- 11.5.10 deliverable id setting for configurable layout
  -- The child section will inherit the parent section's layout
  --  if the parent section is using configurable layout
  -- otherwise, the seed configurable layout will be used.
  --
  -- Make the cursor query use bind variables instead of hard coding the values

  l_deliverable_id := p_deliverable_id;
  IF (p_inherit_layout = FND_API.G_TRUE) THEN
    IF (l_use_configurable_layout) THEN
      IF (p_parent_section_id IS NULL) THEN
        OPEN c_get_configurable_csr(l_access_name,l_deliverable_type_code,
                                    l_applicable_to_code,l_application_id);
        FETCH c_get_configurable_csr INTO l_deliverable_id;
        IF (c_get_configurable_csr%NOTFOUND) THEN
          l_deliverable_id := p_deliverable_id;
        END IF;
        CLOSE c_get_configurable_csr;
      ELSE
        Get_Sect_Layout_Type(p_section_id => p_parent_section_id,
          x_deliverable_id => l_parent_deli_id,
	     x_layout_type => l_parent_layout_type);
        IF l_parent_layout_type = 'C' THEN
          l_deliverable_id := l_parent_deli_id;
        ELSE
        OPEN c_get_configurable_csr(l_access_name,l_deliverable_type_code,
                                    l_applicable_to_code,l_application_id);
          FETCH c_get_configurable_csr INTO l_deliverable_id;
          IF (c_get_configurable_csr%NOTFOUND) THEN
            l_deliverable_id := p_deliverable_id;
          END IF;
          CLOSE c_get_configurable_csr;
        END IF;
      END IF;
    END IF;
  END IF;
  -- create section entry
  IBE_DSP_SECTION_GRP.Create_Section
  (
   p_api_version                  => p_api_version,
   p_init_msg_list                => FND_API.G_FALSE,
   p_commit                       => FND_API.G_FALSE,
   p_validation_level             => p_validation_level,
   p_access_name                  => p_access_name,
   p_start_date_active            => p_start_date_active,
   p_end_date_active              => p_end_date_active,
   p_section_type_code            => p_section_type_code,
   p_status_code                  => p_status_code,
   p_display_context_id           => p_display_context_id,
   p_deliverable_id               => l_deliverable_id,
   p_available_in_all_sites_flag  => p_available_in_all_sites_flag,
   p_auto_placement_rule          => p_auto_placement_rule,
   p_order_by_clause              => p_order_by_clause,
   p_display_name                 => p_display_name,
   p_description                  => p_description,
   p_long_description             => p_long_description,
   p_keywords                     => p_keywords,
   p_attribute_category           => p_attribute_category,
   p_attribute1                   => p_attribute1,
   p_attribute2                   => p_attribute2,
   p_attribute3                   => p_attribute3,
   p_attribute4                   => p_attribute4,
   p_attribute5                   => p_attribute5,
   p_attribute6                   => p_attribute6,
   p_attribute7                   => p_attribute7,
   p_attribute8                   => p_attribute8,
   p_attribute9                   => p_attribute9,
   p_attribute10                  => p_attribute10,
   p_attribute11                  => p_attribute11,
   p_attribute12                  => p_attribute12,
   p_attribute13                  => p_attribute13,
   p_attribute14                  => p_attribute14,
   p_attribute15                  => p_attribute15,
   x_section_id                   => x_section_id,
   x_return_status                => x_return_status,
   x_msg_count                    => x_msg_count,
   x_msg_data                     => x_msg_data
  );

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- get master mini site id for the store
  --
  Get_Master_Mini_Site_Id(x_mini_site_id    => l_master_mini_site_id,
                          x_root_section_id => l_master_root_section_id);

  --
  -- Get the concat_ids and level number
  --
  IF (l_is_root_section) THEN
    l_concat_ids := NULL;
    l_level_number := 1;
  ELSE
    Get_Concat_Ids(l_parent_section_id, l_master_mini_site_id,
                   l_concat_ids, l_level_number);
    l_level_number := l_level_number + 1;
  END IF;

  --
  -- Create mini site section section entry for root mini site
  --
  IBE_DSP_MSITE_SCT_SECT_PVT.Create_MSite_Section_Section
  (
   p_api_version                    => p_api_version,
   p_init_msg_list                  => FND_API.G_FALSE,
   p_commit                         => FND_API.G_FALSE,
   p_validation_level               => p_validation_level,
   p_mini_site_id                   => l_master_mini_site_id,
   p_parent_section_id              => l_parent_section_id,
   p_child_section_id               => x_section_id,
   p_start_date_active              => p_start_date_active,
   p_end_date_active                => p_end_date_active,
   p_level_number                   => l_level_number,
   p_sort_order                     => p_sort_order,
   p_concat_ids                     => l_concat_ids,
   x_mini_site_section_section_id   => l_mini_site_section_section_id,
   x_return_status                  => x_return_status,
   x_msg_count                      => x_msg_count,
   x_msg_data                       => x_msg_data
  );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- todo fm

  --
  -- If root section is being inserted, make sure that ibe_msites_b is
  -- updated to have msite_root_section_id as x_section_id
  --
  IF (l_is_root_section) THEN

    UPDATE ibe_msites_b
      SET msite_root_section_id = x_section_id,
      object_version_number = object_version_number + 1
      WHERE master_msite_flag = 'Y';

    IF (sql%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_MASTER_MSITE_RT_SCT_F');
      FND_MESSAGE.Set_Token('SECTION_ID', x_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  --
  -- Add all the candidate sites to the section. Add them only if the
  -- available in all sites flag is either missing or set to 'Y'. For iStore
  -- it should be always true (based on the UI)
  --
  IF (p_available_in_all_sites_flag = 'Y' OR
      p_available_in_all_sites_flag = FND_API.G_MISS_CHAR)
  THEN
    IF (l_is_root_section) THEN

      FOR r5 IN  c5(l_master_mini_site_id) LOOP
        --
        -- Create mini site section section entry for candidate mini sites
        --
        IBE_DSP_MSITE_SCT_SECT_PVT.Create_MSite_Section_Section
          (
          p_api_version                    => p_api_version,
          p_init_msg_list                  => FND_API.G_FALSE,
          p_commit                         => FND_API.G_FALSE,
          p_validation_level               => p_validation_level,
          p_mini_site_id                   => r5.msite_id,
          p_parent_section_id              => l_parent_section_id,
          p_child_section_id               => x_section_id,
          p_start_date_active              => p_start_date_active,
          p_end_date_active                => p_end_date_active,
          p_level_number                   => FND_API.G_MISS_NUM,
          p_sort_order                     => p_sort_order,
          p_concat_ids                     => FND_API.G_MISS_CHAR,
          x_mini_site_section_section_id   => l_mini_site_section_section_id,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data
          );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

        -- todo fm

      END LOOP;

    ELSE

      FOR r6 IN  c6(l_master_mini_site_id, x_section_id, l_parent_section_id)
      LOOP
        --
        -- Create mini site section section entry for candidate mini sites
        --
        IBE_DSP_MSITE_SCT_SECT_PVT.Create_MSite_Section_Section
          (
          p_api_version                    => p_api_version,
          p_init_msg_list                  => FND_API.G_FALSE,
          p_commit                         => FND_API.G_FALSE,
          p_validation_level               => p_validation_level,
          p_mini_site_id                   => r6.msite_id,
          p_parent_section_id              => l_parent_section_id,
          p_child_section_id               => x_section_id,
          p_start_date_active              => p_start_date_active,
          p_end_date_active                => p_end_date_active,
          p_level_number                   => FND_API.G_MISS_NUM,
          p_sort_order                     => p_sort_order,
          p_concat_ids                     => FND_API.G_MISS_CHAR,
          x_mini_site_section_section_id   => l_mini_site_section_section_id,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data
          );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

        -- todo fm

      END LOOP;

    END IF;

  END IF;

  -- 11.5.10 Save the layout component mapping
  -- from the parent section
  IF ((p_inherit_layout = FND_API.G_TRUE)
    AND (l_parent_section_id IS NOT NULL)) THEN
    IF (l_parent_layout_type = 'C') THEN
      Copy_Layout_Comp_Mapping(
        p_api_version => 1.0,
	   p_init_msg_list => FND_API.G_FALSE,
	   p_commit => FND_API.G_FALSE,
	   p_source_section_id => l_parent_section_id,
	   p_target_section_id => x_section_id,
	   p_include_all => FND_API.G_FALSE,
	   x_return_status => x_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data);
       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
     END IF;
  END IF;
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
     ROLLBACK TO CREATE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_HIERARCHY_SECTION_PVT;
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

END Create_Hierarchy_Section;

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
  )
IS
BEGIN
 Create_Hierarchy_Section
  (
   p_api_version              => p_api_version,
   p_init_msg_list            => p_init_msg_list,
   p_commit                   => p_commit,
   p_validation_level         => p_validation_level,
   p_parent_section_id        => p_parent_section_id,
   p_parent_section_access_name=>p_parent_section_access_name,
   p_access_name              => p_access_name,
   p_start_date_active        => p_start_date_active,
   p_end_date_active          => p_end_date_active,
   p_section_type_code        => p_section_type_code,
   p_status_code              => p_status_code,
   p_display_context_id       => p_display_context_id,
   p_deliverable_id           => p_deliverable_id,
   p_available_in_all_sites_flag=> p_available_in_all_sites_flag,
   p_auto_placement_rule      => p_auto_placement_rule,
   p_order_by_clause          => p_order_by_clause,
   p_sort_order               => p_sort_order,
   p_display_name             => p_display_name,
   p_description              => p_description,
   p_long_description         => p_long_description,
   p_keywords                 => p_keywords,
   p_attribute_category       => p_attribute_category,
   p_attribute1               => p_attribute1,
   p_attribute2               => p_attribute2,
   p_attribute3               => p_attribute3,
   p_attribute4               => p_attribute4,
   p_attribute5               => p_attribute5,
   p_attribute6               => p_attribute6,
   p_attribute7               => p_attribute7,
   p_attribute8               => p_attribute8,
   p_attribute9               => p_attribute9,
   p_attribute10              => p_attribute10,
   p_attribute11              => p_attribute11,
   p_attribute12              => p_attribute12,
   p_attribute13              => p_attribute13,
   p_attribute14              => p_attribute14,
   p_attribute15              => p_attribute15,
   p_inherit_layout           => FND_API.G_TRUE,
   x_section_id               => x_section_id,
   x_return_status            => x_return_status,
   x_msg_count                => x_msg_count,
   x_msg_data                 => x_msg_data
  );
END Create_Hierarchy_Section;

--
-- if sort_number specified, then update ibe_dsp_msite_sct_sects table too
-- p_mss_object_version_number will be used only then, and also it should be
-- specified if sort_number is specified
-- p_upd_dsc_scts_status (value 'Y' or 'N') will be used to update all the
-- descendant section's (of p_section_id) status to p_status_code. If Y, then
-- update all descendants (including p_section_id), else update only
-- p_section_id's status.
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Update_Hierarchy_Section';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;
  l_section_section_id           NUMBER;
  l_parent_section_id            NUMBER;
  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;

  CURSOR c1(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT parent_section_id
    FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id;

  CURSOR c2(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT mini_site_section_section_id
    FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_mini_site_id
    AND parent_section_id = l_c_section_id;

  --
  -- Get the descendant sections of l_c_section_id (not including
  -- l_c_section_id)
  --
  CURSOR c3(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT section_id, object_version_number FROM ibe_dsp_sections_b
    WHERE section_id IN
    (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_mini_site_id
    START WITH parent_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND PRIOR mini_site_id = l_c_master_mini_site_id
    AND mini_site_id = l_c_master_mini_site_id);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_HIERARCHY_SECTION_PVT;

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
  -- Get section id
  --
  IF ((p_section_id IS NOT NULL) AND
      (p_section_id <> FND_API.G_MISS_NUM))
  THEN

    l_section_id := p_section_id; -- section_id specified

  ELSE
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_ID_NULL_OR_NOTSPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Check (and validate) if p_sort_order is specified
  --
  IF (p_sort_order <> FND_API.G_MISS_NUM) THEN

    IF ((p_mss_object_version_number = FND_API.G_MISS_NUM) OR
        (p_mss_object_version_number IS NULL))
    THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_MSS_OVN');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  --
  -- get master mini site id for the store
  --
  Get_Master_Mini_Site_Id(x_mini_site_id    => l_master_mini_site_id,
                          x_root_section_id => l_master_root_section_id);

  -- Check if the section which have children as sections is being updated to
  -- non-navigational section type.
  OPEN c2(l_section_id, l_master_mini_site_id);
  FETCH c2 INTO l_section_section_id;
  IF (c2%FOUND) THEN
    -- section has children sections
    CLOSE c2;
    IF((p_section_type_code <> FND_API.G_MISS_CHAR) AND
       (p_section_type_code <> 'N'))
    THEN
      -- non-navigations section with children sections is being changed to
      -- type other than 'N' (navigational)
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NAV_SCT_TYPE_CHNG_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    CLOSE c2;
  END IF;

  IBE_DSP_SECTION_GRP.Update_Section
    (
    p_api_version                    => p_api_version,
    p_init_msg_list                  => FND_API.G_FALSE,
    p_commit                         => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_section_id                     => p_section_id,
    p_object_version_number          => p_object_version_number,
    p_access_name                    => p_access_name,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_section_type_code              => p_section_type_code,
    p_status_code                    => p_status_code,
    p_display_context_id             => p_display_context_id,
    p_deliverable_id                 => p_deliverable_id,
    p_available_in_all_sites_flag    => p_available_in_all_sites_flag,
    p_auto_placement_rule            => p_auto_placement_rule,
    p_order_by_clause                => p_order_by_clause,
    p_display_name                   => p_display_name,
    p_description                    => p_description,
    p_long_description               => p_long_description,
    p_keywords                       => p_keywords,
    p_attribute_category             => p_attribute_category,
    p_attribute1                     => p_attribute1,
    p_attribute2                     => p_attribute2,
    p_attribute3                     => p_attribute3,
    p_attribute4                     => p_attribute4,
    p_attribute5                     => p_attribute5,
    p_attribute6                     => p_attribute6,
    p_attribute7                     => p_attribute7,
    p_attribute8                     => p_attribute8,
    p_attribute9                     => p_attribute9,
    p_attribute10                    => p_attribute10,
    p_attribute11                    => p_attribute11,
    p_attribute12                    => p_attribute12,
    p_attribute13                    => p_attribute13,
    p_attribute14                    => p_attribute14,
    p_attribute15                    => p_attribute15,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Update ibe_dsp_msite_sct_sects only if the sort order is present
    --
    IF (p_sort_order <> FND_API.G_MISS_NUM) THEN
      --
      -- get parent section id of the section to be updated
      --
      OPEN c1(p_section_id, l_master_mini_site_id);
      FETCH c1 INTO l_parent_section_id;
      IF (c1%NOTFOUND) THEN
        CLOSE c1;
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_GET_PRNT_SCT_FAIL');
        FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c1;

      --
      -- update ibe_dsp_msite_sct_sects
      --
      IBE_DSP_MSITE_SCT_SECT_PVT.Update_MSite_Section_Section
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_mini_site_section_section_id   => FND_API.G_MISS_NUM,
        p_object_version_number          => p_mss_object_version_number,
        p_mini_site_id                   => l_master_mini_site_id,
        p_parent_section_id              => l_parent_section_id,
        p_child_section_id               => p_section_id,
        p_start_date_active              => FND_API.G_MISS_DATE,
        p_end_date_active                => FND_API.G_MISS_DATE,
        p_level_number                   => FND_API.G_MISS_NUM,
        p_sort_order                     => p_sort_order,
        p_concat_ids                     => FND_API.G_MISS_CHAR,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF; -- p_sort_order <> FND_API.G_MISS_NUM OR ...

    --
    -- Update status of descendant sections of p_section_id
    --
    IF (p_upd_dsc_scts_status = 'Y') THEN

      FOR r3 in c3(p_section_id, l_master_mini_site_id) LOOP

        IBE_DSP_SECTION_GRP.Update_Section
          (
          p_api_version                    => p_api_version,
          p_init_msg_list                  => FND_API.G_FALSE,
          p_commit                         => FND_API.G_FALSE,
          p_validation_level               => p_validation_level,
          p_section_id                     => r3.section_id,
          p_object_version_number          => r3.object_version_number,
          p_access_name                    => FND_API.G_MISS_CHAR,
          p_start_date_active              => FND_API.G_MISS_DATE,
          p_end_date_active                => FND_API.G_MISS_DATE,
          p_section_type_code              => FND_API.G_MISS_CHAR,
          p_status_code                    => p_status_code,
          p_display_context_id             => FND_API.G_MISS_NUM,
          p_deliverable_id                 => FND_API.G_MISS_NUM,
          p_available_in_all_sites_flag    => FND_API.G_MISS_CHAR,
          p_auto_placement_rule            => FND_API.G_MISS_CHAR,
          p_order_by_clause                => FND_API.G_MISS_CHAR,
          p_display_name                   => FND_API.G_MISS_CHAR,
          p_description                    => FND_API.G_MISS_CHAR,
          p_long_description               => FND_API.G_MISS_CHAR,
          p_keywords                       => FND_API.G_MISS_CHAR,
          p_attribute_category             => FND_API.G_MISS_CHAR,
          p_attribute1                     => FND_API.G_MISS_CHAR,
          p_attribute2                     => FND_API.G_MISS_CHAR,
          p_attribute3                     => FND_API.G_MISS_CHAR,
          p_attribute4                     => FND_API.G_MISS_CHAR,
          p_attribute5                     => FND_API.G_MISS_CHAR,
          p_attribute6                     => FND_API.G_MISS_CHAR,
          p_attribute7                     => FND_API.G_MISS_CHAR,
          p_attribute8                     => FND_API.G_MISS_CHAR,
          p_attribute9                     => FND_API.G_MISS_CHAR,
          p_attribute10                    => FND_API.G_MISS_CHAR,
          p_attribute11                    => FND_API.G_MISS_CHAR,
          p_attribute12                    => FND_API.G_MISS_CHAR,
          p_attribute13                    => FND_API.G_MISS_CHAR,
          p_attribute14                    => FND_API.G_MISS_CHAR,
          p_attribute15                    => FND_API.G_MISS_CHAR,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data
          );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_UPD_DSC_SCT_STATUS_FL');
          FND_MESSAGE.Set_Token('SECTION_ID', r3.section_id);
          FND_MESSAGE.Set_Token('OVN', r3.object_version_number);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_UPD_DSC_SCT_STATUS_FL');
          FND_MESSAGE.Set_Token('SECTION_ID', r3.section_id);
          FND_MESSAGE.Set_Token('OVN', r3.object_version_number);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END LOOP; -- end for r3

    END IF; -- end if (p_upd_dsc_scts_status)

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
     ROLLBACK TO UPDATE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_HIERARCHY_SECTION_PVT;
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

END Update_Hierarchy_Section;


--- modified for better performance 11/20/03 ab

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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Delete_Hierarchy_Section';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;
  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;

  CURSOR c1(l_c_access_name IN VARCHAR2)
  IS SELECT section_id FROM ibe_dsp_sections_b
    WHERE access_name = l_c_access_name;

  CURSOR c_get_child_sections( l_section_id in NUMBER ,l_master_mini_site_id in NUMBER) IS
    SELECT S.section_id
    FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS
    WHERE S.section_id = MSS.child_section_id
    AND MSS.mini_site_id = l_master_mini_site_id
    AND S.section_id IN
    (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_master_mini_site_id
    START WITH parent_section_id = l_section_id
    AND mini_site_id = l_master_mini_site_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND mini_site_id = l_master_mini_site_id)
    ORDER BY MSS.level_number desc;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  DELETE_HIERARCHY_SECTION_PVT;

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
  -- Validate input data
  --
  IF ((p_section_id IS NOT NULL) AND
      (p_section_id <> FND_API.G_MISS_NUM))
  THEN
    -- p_section_id specified, continue
    l_section_id := p_section_id;
  ELSIF ((p_access_name IS NOT NULL) AND
         (p_access_name <> FND_API.G_MISS_CHAR))
  THEN
    -- find out the section_id from the access_name
    OPEN c1(p_access_name);
    FETCH c1 INTO l_section_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ACSS_NAME');
      FND_MESSAGE.Set_Token('ACCESS_NAME', p_access_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;
  ELSE
    -- neither access_name nor section_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_ID_OR_ACSS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- get master mini site id for the store
  --
  Get_Master_Mini_Site_Id(x_mini_site_id    => l_master_mini_site_id,
                          x_root_section_id => l_master_root_section_id);

  --
  -- Delete all the descendents of the section
  FOR r1 in c_get_child_sections(p_section_id,l_master_mini_site_id) loop
     IBE_DSP_SECTION_GRP.Delete_Section
      (
      p_api_version         => p_api_version,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_section_id          => r1.section_id,
      p_access_name         => FND_API.G_MISS_CHAR,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;
  -- after deleting the children of p_section_id, delete itself
    IBE_DSP_SECTION_GRP.Delete_Section
      (
      p_api_version         => p_api_version,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_section_id          => p_section_id,
      p_access_name         => FND_API.G_MISS_CHAR,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
      );

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
     ROLLBACK TO DELETE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_HIERARCHY_SECTION_PVT;
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

END Delete_Hierarchy_Section;


/*PROCEDURE Delete_Hierarchy_Section
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Delete_Hierarchy_Section';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;
  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;

  CURSOR c1(l_c_access_name IN VARCHAR2)
  IS SELECT section_id FROM ibe_dsp_sections_b
    WHERE access_name = l_c_access_name;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  DELETE_HIERARCHY_SECTION_PVT;

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
  -- Validate input data
  --
  IF ((p_section_id IS NOT NULL) AND
      (p_section_id <> FND_API.G_MISS_NUM))
  THEN
    -- p_section_id specified, continue
    l_section_id := p_section_id;
  ELSIF ((p_access_name IS NOT NULL) AND
         (p_access_name <> FND_API.G_MISS_CHAR))
  THEN
    -- find out the section_id from the access_name
    OPEN c1(p_access_name);
    FETCH c1 INTO l_section_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ACSS_NAME');
      FND_MESSAGE.Set_Token('ACCESS_NAME', p_access_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;
  ELSE
    -- neither access_name nor section_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_ID_OR_ACSS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- get master mini site id for the store
  --
  Get_Master_Mini_Site_Id(x_mini_site_id    => l_master_mini_site_id,
                          x_root_section_id => l_master_root_section_id);

  --
  -- Delete the current section and all its descendants
  --
  Delete_Recursive_Sections
    (
    p_api_version                    => p_api_version,
    p_init_msg_list                  => FND_API.G_FALSE,
    p_commit                         => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_master_mini_site_id            => l_master_mini_site_id,
    p_section_id                     => l_section_id,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RECUR_SCT_DEL_FAIL');
    FND_MESSAGE.Set_Token('SECTION_ID', l_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RECUR_SCT_DEL_FAIL');
    FND_MESSAGE.Set_Token('SECTION_ID', l_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
     ROLLBACK TO DELETE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_HIERARCHY_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_HIERARCHY_SECTION_PVT;
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

END Delete_Hierarchy_Section;
*/

--bug 2699547, code for PROCEDURE Get_Hierarchy_Sections removed

--
-- for each item in p_inventory_item_ids, associate the item to p_section_id
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Items_To_Section';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;
  l_mini_site_id                 NUMBER;
  l_mini_site_section_item_id    NUMBER;
  l_tmp_section_item_id          NUMBER;
  l_duplicate_flags              JTF_VARCHAR2_TABLE_300;

  -- get all the mini-sites to which the section belongs to except the
  -- master mini-site(s)
  CURSOR c1(l_c_section_id IN NUMBER)
  IS SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_section_id
    AND mini_site_id NOT IN
    (SELECT msite_id FROM ibe_msites_b
    WHERE UPPER(master_msite_flag) = 'Y');

  CURSOR c2(l_c_section_id IN NUMBER,
    l_c_inventory_item_id IN NUMBER,
    l_c_organization_id IN NUMBER)
  IS SELECT section_item_id FROM ibe_dsp_section_items
    WHERE section_id = l_c_section_id
    AND inventory_item_id = l_c_inventory_item_id
    AND organization_id = l_c_organization_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  ASSOCIATE_ITEMS_TO_SECTION_PVT;

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
  x_duplicate_association_status := FND_API.G_RET_STS_SUCCESS;

  -- todo optimize using FORALL and BIND COLLECT
  x_section_item_ids := JTF_NUMBER_TABLE();
  l_duplicate_flags := JTF_VARCHAR2_TABLE_300();
  FOR i IN 1..p_inventory_item_ids.COUNT LOOP

    x_section_item_ids.EXTEND();
    l_duplicate_flags.EXTEND();

    OPEN c2(p_section_id, p_inventory_item_ids(i), p_organization_ids(i));
    FETCH c2 INTO l_tmp_section_item_id;
    IF (c2%FOUND) THEN

      CLOSE c2;
      x_duplicate_association_status := FND_API.G_RET_STS_ERROR;
      x_section_item_ids(i) := l_tmp_section_item_id;
      l_duplicate_flags(i) := FND_API.G_RET_STS_ERROR;

      -- add a message if the association already exists. Don't raise error.
      -- This message will be used to display as a warning in the UI
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_ITM_ALREADY_ASSOC');
      FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_ids(i));
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_ids(i));
      FND_MSG_PUB.Add;

    ELSE

      CLOSE c2;
      l_duplicate_flags(i) := FND_API.G_RET_STS_SUCCESS;

      -- insert an entry in ibe_dsp_section_items table
      IBE_DSP_SECTION_ITEM_PVT.Create_Section_Item
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_section_id                     => p_section_id,
        p_inventory_item_id              => p_inventory_item_ids(i),
        p_organization_id                => p_organization_ids(i),
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_sort_order                     => p_sort_orders(i),
        p_association_reason_code        => p_association_reason_codes(i),
        x_section_item_id                => x_section_item_ids(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END LOOP;

  -- add entries into ibe_dsp_msite_sct_items for each mini-site (except
  -- master mini-sites)
  FOR r1 IN c1(p_section_id) LOOP -- for each mini-site

    FOR i IN 1..x_section_item_ids.COUNT LOOP

      IF (l_duplicate_flags(i) = FND_API.G_RET_STS_SUCCESS) THEN

        IBE_DSP_MSITE_SCT_ITEM_PVT.Create_MSite_Section_Item
          (
          p_api_version                    => p_api_version,
          p_init_msg_list                  => FND_API.G_FALSE,
          p_commit                         => FND_API.G_FALSE,
          p_validation_level               => p_validation_level,
          p_mini_site_id                   => r1.mini_site_id,
          p_section_item_id                => x_section_item_ids(i),
          p_start_date_active              => p_start_date_actives(i),
          p_end_date_active                => p_end_date_actives(i),
          x_mini_site_section_item_id      => l_mini_site_section_item_id,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data
          );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF; -- end (l_duplicate_flags(i) = FND_API.G_RET_STS_SUCCESS)

    END LOOP; -- end for i

  END LOOP; -- end for r1

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
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PVT;
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

END Associate_Items_To_Section;

--
-- for each section in p_section_ids, associate the item inventory_item_id
-- to it
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Sections_To_Item';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;
  l_mini_site_id                 NUMBER;
  l_mini_site_section_item_id    NUMBER;
  l_tmp_section_item_id          NUMBER;

  -- get all the mini-sites to which the section belongs to except the
  -- master mini-site(s)
  CURSOR c1(l_c_section_id IN NUMBER)
  IS SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_section_id
    AND mini_site_id NOT IN
    (SELECT msite_id FROM ibe_msites_b
    WHERE UPPER(master_msite_flag) = 'Y');

  CURSOR c2(l_c_section_id IN NUMBER,
    l_c_inventory_item_id IN NUMBER,
    l_c_organization_id IN NUMBER)
  IS SELECT section_item_id FROM ibe_dsp_section_items
    WHERE section_id = l_c_section_id
    AND inventory_item_id = l_c_inventory_item_id
    AND organization_id = l_c_organization_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  ASSOCIATE_SECTIONS_TO_ITEM_PVT;

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
  x_duplicate_association_status := FND_API.G_RET_STS_SUCCESS;

  -- todo optimize using FORALL and BIND COLLECT
  x_section_item_ids := JTF_NUMBER_TABLE();
  FOR i IN 1..p_section_ids.COUNT LOOP

    x_section_item_ids.EXTEND();

    OPEN c2(p_section_ids(i), p_inventory_item_id, p_organization_id);
    FETCH c2 INTO l_tmp_section_item_id;
    IF (c2%FOUND) THEN
      CLOSE c2;

      x_duplicate_association_status := FND_API.G_RET_STS_ERROR;
      x_section_item_ids(i) := l_tmp_section_item_id;

      -- add a message if the association already exists. Don't raise error.
      -- This message will be used to display as a warning in the UI
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_ITM_ALREADY_ASSOC');
      FND_MESSAGE.Set_Token('SECTION_ID', p_section_ids(i));
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
      FND_MSG_PUB.Add;

    ELSE

      CLOSE c2;

      --
      -- insert an entry in ibe_dsp_section_items table
      --
      IBE_DSP_SECTION_ITEM_PVT.Create_Section_Item
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_section_id                     => p_section_ids(i),
        p_inventory_item_id              => p_inventory_item_id,
        p_organization_id                => p_organization_id,
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_sort_order                     => p_sort_orders(i),
        p_association_reason_code        => p_association_reason_codes(i),
        x_section_item_id                => x_section_item_ids(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- add entries into ibe_dsp_msite_sct_items for each mini-site (except
      -- master mini-sites)
      FOR r1 IN c1(p_section_ids(i)) LOOP -- for each mini-site

        IBE_DSP_MSITE_SCT_ITEM_PVT.Create_MSite_Section_Item
          (
          p_api_version                    => p_api_version,
          p_init_msg_list                  => FND_API.G_FALSE,
          p_commit                         => FND_API.G_FALSE,
          p_validation_level               => p_validation_level,
          p_mini_site_id                   => r1.mini_site_id,
          p_section_item_id                => x_section_item_ids(i),
          p_start_date_active              => p_start_date_actives(i),
          p_end_date_active                => p_end_date_actives(i),
          x_mini_site_section_item_id      => l_mini_site_section_item_id,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data
          );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END LOOP; -- end r1

    END IF;

  END LOOP; -- end i

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
     ROLLBACK TO ASSOCIATE_SECTIONS_TO_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO ASSOCIATE_SECTIONS_TO_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO ASSOCIATE_SECTIONS_TO_ITEM_PVT;
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

END Associate_Sections_To_Item;

--
-- for each section in p_section_ids, delete each of the inventory_item_ids
-- Entries in p_sections_ids and p_inventory_item_ids are assumed to be unique
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Disassociate_Scts_To_Itms';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  DISASSOCIATE_SCTS_TO_ITMS_PVT;

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

  -- todo optimize using FORALL and BIND COLLECT
  FOR i IN 1..p_section_ids.COUNT LOOP

    FOR j IN 1..p_inventory_item_ids.COUNT LOOP
      -- delete entry in ibe_dsp_section_items table
      IBE_DSP_SECTION_ITEM_PVT.Delete_Section_Item
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_call_from_trigger              => FALSE,
        p_section_item_id                => FND_API.G_MISS_NUM,
        p_section_id                     => p_section_ids(i),
        p_inventory_item_id              => p_inventory_item_ids(j),
        p_organization_id                => p_organization_ids(j),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP; -- j loop

  END LOOP; -- i loop

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
     ROLLBACK TO DISASSOCIATE_SCTS_TO_ITMS_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DISASSOCIATE_SCTS_TO_ITMS_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO DISASSOCIATE_SCTS_TO_ITMS_PVT;
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

END Disassociate_Scts_To_Itms;

--
-- for each section in p_section_ids, delete each of the inventory_item_ids
-- Entries in p_sections_ids and p_inventory_item_ids are assumed to be unique
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Disassociate_Scts_Itms';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  DISASSOCIATE_SCTS_ITMS_PVT;

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

  -- todo optimize using FORALL and BIND COLLECT
  FOR i IN 1..p_section_item_ids.COUNT LOOP

    -- delete entry in ibe_dsp_section_items table
    IBE_DSP_SECTION_ITEM_PVT.Delete_Section_Item
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_call_from_trigger              => FALSE,
      p_section_item_id                => p_section_item_ids(i),
      p_section_id                     => FND_API.G_MISS_NUM,
      p_inventory_item_id              => FND_API.G_MISS_NUM,
      p_organization_id                => FND_API.G_MISS_NUM,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
      );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END LOOP; -- i loop

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
     ROLLBACK TO DISASSOCIATE_SCTS_ITMS_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DISASSOCIATE_SCTS_ITMS_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO DISASSOCIATE_SCTS_ITMS_PVT;
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

END Disassociate_Scts_Itms;

--
-- Associate p_mini_site_ids with p_section_id. If there are any other
-- mini-sites associated with p_section_id, they will be removed. At the
-- end of this procedure, p_section_id will be associated with only mini-sites
-- specified in p_mini_site_ids. Also all the descendants of p_section_id
-- will have an association with each of the p_mini_site_ids, if
-- available_in_all_sites_flag is 'Y'
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_MSites_To_Section';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_found_flag                   BOOLEAN;
  l_counter                      NUMBER;
  l_row_id                       VARCHAR2(30);
  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;
  l_mini_site_section_section_id NUMBER;
  l_mini_site_section_item_id    NUMBER;
  l_parent_mini_site_ids         JTF_NUMBER_TABLE;
  l_root_mini_site_ids           JTF_NUMBER_TABLE;
  l_old_mini_site_ids            JTF_NUMBER_TABLE;

  --
  -- Get the mini-sites to which the parent of l_c_child_section_id belongs to
  -- and which does not include master mini-site id
  --
  CURSOR c1(l_c_child_section_id IN NUMBER,
    l_c_master_mini_site_id IN NUMBER)
  IS SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id =
    (SELECT parent_section_id FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_child_section_id
    AND mini_site_id = l_c_master_mini_site_id)
    AND mini_site_id <> l_c_master_mini_site_id;

  --
  -- Get the mini-sites to which l_c_section_id belongs to and which does
  -- not include master mini-site id
  --
  CURSOR c2(l_c_section_id IN NUMBER,
    l_c_master_mini_site_id IN NUMBER)
  IS SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_section_id
    AND   mini_site_id <> l_c_master_mini_site_id;

  --
  -- Get the row in ibe_dsp_msite_sct_items which belongs to mini-site
  -- l_c_mini_site_id, and the section item id is one of the descendants
  -- of the section l_c_section_id
  --
  -- Bug 2684417 (use UNION instead of OR clause)
  CURSOR c3(l_c_section_id IN NUMBER,
    l_c_mini_site_id IN NUMBER,
    l_c_master_mini_site_id IN NUMBER)
  IS SELECT MSI.mini_site_section_item_id
     FROM   ibe_dsp_msite_sct_items MSI,
            ibe_dsp_section_items SI,
            ibe_dsp_msite_sct_sects MSS
     WHERE  MSI.mini_site_id = l_c_mini_site_id
     AND    MSI.section_item_id = SI.section_item_id
     AND    SI.section_id = MSS.child_section_id
     AND    MSS.mini_site_id = l_c_master_mini_site_id
     AND    MSS.child_section_id = l_c_section_id

   UNION

     SELECT MSI.mini_site_section_item_id
     FROM   ibe_dsp_msite_sct_items MSI,
            ibe_dsp_section_items SI,
            ibe_dsp_msite_sct_sects MSS
     WHERE  MSI.mini_site_id = l_c_mini_site_id
     AND    MSI.section_item_id = SI.section_item_id
     AND    SI.section_id = MSS.child_section_id
     AND    MSS.mini_site_id = l_c_master_mini_site_id
	AND    MSS.child_section_id IN
              (SELECT child_section_id
			FROM ibe_dsp_msite_sct_sects
               START WITH parent_section_id = l_c_section_id
			AND mini_site_id = l_master_mini_site_id
               CONNECT BY PRIOR child_section_id = parent_section_id
               AND mini_site_id = l_master_mini_site_id);

  --
  -- Get the (master) info for the section l_c_section_id and all its
  -- descendants
  --
--  CURSOR c4(l_c_section_id IN NUMBER,
--     l_c_master_mini_site_id IN NUMBER)
--   IS SELECT parent_section_id, child_section_id, start_date_active,
--     end_date_active, sort_order
--     FROM ibe_dsp_msite_sct_sects
--     WHERE mini_site_id = l_c_master_mini_site_id
--     START WITH child_section_id = l_c_section_id
--     CONNECT BY PRIOR child_section_id = parent_section_id
--     AND PRIOR mini_site_id = l_c_master_mini_site_id
--     AND mini_site_id = l_c_master_mini_site_id;
--
--   CURSOR c5(l_c_section_id IN NUMBER,
--     l_c_master_mini_site_id IN NUMBER)
--   IS SELECT SI.section_item_id
--     FROM ibe_dsp_msite_sct_sects MSS, ibe_dsp_section_items SI
--     WHERE SI.section_id = MSS.child_section_id
--     AND   MSS.mini_site_id = l_c_master_mini_site_id
--     AND   (MSS.child_section_id = l_c_section_id OR
--     MSS.child_section_id IN
--     (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
--     START WITH child_section_id = l_c_section_id
--     CONNECT BY PRIOR child_section_id = parent_section_id
--     AND PRIOR mini_site_id = l_c_master_mini_site_id));

  --
  -- Get the list of mini-sites for which l_c_section_id is the
  -- root section id
  --
  CURSOR c6(l_c_section_id IN NUMBER) IS SELECT msite_id
    FROM ibe_msites_b
    WHERE msite_root_section_id = l_c_section_id
    AND master_msite_flag <> 'Y';

  --
  -- Get the detail info for MSS association for l_c_section_id from the
  -- master mini-site's entry
  --
  CURSOR c_get_section_hierary_info(l_c_section_id IN NUMBER,
	l_c_master_mini_site_id IN NUMBER)
  IS SELECT parent_section_id, start_date_active, end_date_active, sort_order
    FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id;

  l_parent_section_id NUMBER;
  l_start_date_active DATE;
  l_end_date_active DATE;
  l_sort_order NUMBER;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  ASSOCIATE_MSITES_TO_SECTION;

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
  -- Get master mini site id for the store
  --
  Get_Master_Mini_Site_Id(x_mini_site_id    => l_master_mini_site_id,
                          x_root_section_id => l_master_root_section_id);

  --
  -- Check if the parent section of p_section_id belongs to all the mini-sites
  -- specified in p_mini_site_ids. If not, then that mini-site should be
  -- have root section id as p_section_id.
  -- Also lock the rows (todo) for the parent section, so that they don't get
  -- changed while the child section and its descendants are assigned with
  -- mini-sites
  --

  --
  -- Get the list of mini-sites to which the parent section (of p_section_id)
  -- belongs to
  --
  l_counter := 1;
  l_parent_mini_site_ids := JTF_NUMBER_TABLE();
  FOR r1 IN c1(p_section_id, l_master_mini_site_id) LOOP
    l_parent_mini_site_ids.EXTEND();
    l_parent_mini_site_ids(l_counter) := r1.mini_site_id;
    l_counter := l_counter + 1;
  END LOOP;

  --
  -- Get the list of mini-sites (l_root_mini_site_ids) for which the section
  -- (p_section_id) is the root section. This will be used later in processing
  -- logic
  --
  l_counter := 1;
  l_root_mini_site_ids := JTF_NUMBER_TABLE();
  FOR r6 IN c6(p_section_id) LOOP
    l_root_mini_site_ids.EXTEND();
    l_root_mini_site_ids(l_counter) := r6.msite_id;
    l_counter := l_counter + 1;
  END LOOP;

  -- Check if p_mini_site_ids is a subset of l_parent_mini_site_ids
  -- Check this only if the section is not the master root section
  -- If an entry in p_mini_site_ids does not exist in l_parent_mini_site_ids,
  -- then it could be possible that that p_mini_site_ids' entry has the
  -- root section id as p_section_id. In this case, don't raise an error.
  -- If not, then raise an error
  IF (p_section_id <> l_master_root_section_id) THEN
    FOR i IN 1..p_mini_site_ids.COUNT LOOP

      l_found_flag := FALSE;
      FOR j IN 1..l_parent_mini_site_ids.COUNT LOOP
        IF (p_mini_site_ids(i) = l_parent_mini_site_ids(j)) THEN
          l_found_flag := TRUE;
          EXIT;
        END IF;
      END LOOP; -- loop j

      -- if not found in the list of parent mini-site ids, check if this
      -- section (p_section_id) is root section for p_mini_site_ids(i). If yes,
      -- then don't raise error. Otherwise do.
      IF (NOT l_found_flag) THEN

        FOR k IN 1..l_root_mini_site_ids.COUNT LOOP
          IF(p_mini_site_ids(i) = l_root_mini_site_ids(k)) THEN
            l_found_flag := TRUE;
            EXIT;
          END IF;

        END LOOP; -- loop k

      END IF;

      IF (NOT l_found_flag) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_MSITE_SCT_ASSC');
        FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_ids(i));
        FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP; -- loop i
  END IF;

  --
  -- Find the old mini-sites to which the p_section_id belongs
  --
  l_counter := 1;
  l_old_mini_site_ids := JTF_NUMBER_TABLE();
  FOR r2 IN c2(p_section_id, l_master_mini_site_id) LOOP
    l_old_mini_site_ids.EXTEND();
    l_old_mini_site_ids(l_counter) := r2.mini_site_id;
    l_counter := l_counter + 1;
  END LOOP;

  --
  -- Find out the mini-sites for which the association should be removed for
  -- p_section_id and its descendants
  --
  FOR i IN 1..l_old_mini_site_ids.COUNT LOOP
    l_found_flag := FALSE;
    FOR j IN 1..p_mini_site_ids.COUNT LOOP
      IF (l_old_mini_site_ids(i) = p_mini_site_ids(j)) THEN
        l_found_flag := TRUE;
        EXIT;
      END IF;
    END LOOP; -- j loop

    IF (NOT l_found_flag) THEN
      -- l_old_mini_site_ids(i)'s association to be removed from
      -- ibe_dsp_msite_sct_sects and ibe_dsp_msite_sct_items

      -- remove from ibe_dsp_msite_sct_items
      FOR r3 IN c3(p_section_id, l_old_mini_site_ids(i), l_master_mini_site_id) LOOP
        DELETE FROM ibe_dsp_msite_sct_items
          WHERE mini_site_section_item_id = r3.mini_site_section_item_id;
      END LOOP;

    -- remove from ibe_dsp_msite_sct_sects
    --Bug 2684417 (break up into 2 deletes)
    DELETE FROM  ibe_dsp_msite_sct_sects
           WHERE mini_site_id = l_old_mini_site_ids(i)
           AND   child_section_id = p_section_id;

    DELETE FROM  ibe_dsp_msite_sct_sects
           WHERE mini_site_id = l_old_mini_site_ids(i)
           AND   child_section_id IN
                   (SELECT child_section_id
			     FROM ibe_dsp_msite_sct_sects
                    START WITH parent_section_id = p_section_id
				AND mini_site_id = l_master_mini_site_id
                    CONNECT BY prior child_section_id = parent_section_id
                    AND mini_site_id = l_master_mini_site_id);

    END IF;
  END LOOP; -- i loop


  --
  -- Add the new entries for the new mini-site ids
  --
  OPEN c_get_section_hierary_info(p_section_id, l_master_mini_site_id);
  FETCH c_get_section_hierary_info INTO l_parent_section_id,
    l_start_date_active, l_end_date_active, l_sort_order;
  IF c_get_section_hierary_info%NOTFOUND THEN
    l_parent_section_id := -1;
  END IF;
  CLOSE c_get_section_hierary_info;

  FOR i IN 1..p_mini_site_ids.COUNT LOOP

    l_found_flag := FALSE;
    FOR j IN 1..l_old_mini_site_ids.COUNT LOOP
      IF (p_mini_site_ids(i) = l_old_mini_site_ids(j)) THEN
        l_found_flag := TRUE;
	   -- minisite id is linked to the section already
	   -- If so, update the section-msite record if the parent section
	   -- is not set correctly.
	   IF (l_parent_section_id <> -1) AND (l_parent_section_id IS NOT NULL) THEN
	     UPDATE IBE_DSP_MSITE_SCT_SECTS
		   SET parent_section_id = l_parent_section_id,
                 start_date_active = l_start_date_active,
                 end_date_active = l_end_date_active,
			  sort_order = l_sort_order,
			  last_update_date = SYSDATE,
			  last_updated_by = FND_GLOBAL.user_id
	      WHERE mini_site_id = l_old_mini_site_ids(j)
		   AND child_section_id = p_section_id
		   AND parent_section_id <> l_parent_section_id;
	   END IF;
        EXIT;
      END IF;
    END LOOP; -- loop j

    IF (NOT l_found_flag) THEN
      -- new entry found, should add entry for p_section_id and for all
      -- its descendants in ibe_dsp_msite_sct_sects and
      -- ibe_dsp_msite_sct_items table

      -- add entries in ibe_dsp_msite_sct_sects and ibe_dsp_msite_sct_items
      -- table
      Associate_Recursive_MSite_Sct
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_section_id                     => p_section_id,
        p_mini_site_id                   => p_mini_site_ids(i),
        p_master_mini_site_id            => l_master_mini_site_id,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RCR_MSITE_SCT_ASC_FAIL');
        FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
        FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_ids(i));
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RCR_MSITE_SCT_ASC_FAIL');
        FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
        FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_ids(i));
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF; -- if NOT l_found_flag

  END LOOP; -- loop i

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
      ROLLBACK TO ASSOCIATE_MSITES_TO_SECTION;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ASSOCIATE_MSITES_TO_SECTION;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN OTHERS THEN
      ROLLBACK TO ASSOCIATE_MSITES_TO_SECTION;
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

END Associate_MSites_To_Section;

--
-- Associate p_mini_site_ids with root section p_section_id.
-- Previously associated sections and items for this mini-site will be removed
-- Also all the descendants of p_section_id will have an association with
-- p_mini_site_id (for seciton, if available_in_all_sites_flag is 'Y')
-- This procedure doesn't check if p_section_id is root section id for
-- p_mini_site_id in ibe_msites_b table
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Root_Sct_To_MSite';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  ASSOCIATE_ROOT_SCT_TO_MSITE;

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
  -- Get master mini site id for the store
  --
  Get_Master_Mini_Site_Id(x_mini_site_id    => l_master_mini_site_id,
                          x_root_section_id => l_master_root_section_id);

  --
  -- Check if the p_mini_site_id is not master mini-site id
  --
  IF (p_mini_site_id = l_master_mini_site_id) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_ROOT_SCT_MSITE');
    FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Remove all the occurrences of p_mini_site_id from ibe_dsp_msite_sct_sects
  -- and ibe_dsp_msite_sct_items table
  --
  DELETE FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = p_mini_site_id;
  IF (sql%NOTFOUND) THEN
    -- ok, as there could be no data in ibe_dsp_msite_sct_sects
    NULL;
  END IF;

  DELETE FROM ibe_dsp_msite_sct_items
    WHERE mini_site_id = p_mini_site_id;
  IF (sql%NOTFOUND) THEN
    -- ok, as there could be no data in ibe_dsp_msite_sct_items
    NULL;
  END IF;

  -- Associate p_mini_site_id with p_section_id and all its descendants
  -- (sections and items). For section, the available_in_all_sites_flag
  -- should be 'Y'
  Associate_Recursive_MSite_Sct
    (
    p_api_version                    => p_api_version,
    p_init_msg_list                  => FND_API.G_FALSE,
    p_commit                         => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_section_id                     => p_section_id,
    p_mini_site_id                   => p_mini_site_id,
    p_master_mini_site_id            => l_master_mini_site_id,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RCR_MSITE_SCT_ASC_FAIL');
    FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
    FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_RCR_MSITE_SCT_ASC_FAIL');
    FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
    FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
      ROLLBACK TO ASSOCIATE_ROOT_SCT_TO_MSITE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ASSOCIATE_ROOT_SCT_TO_MSITE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN OTHERS THEN
      ROLLBACK TO ASSOCIATE_ROOT_SCT_TO_MSITE;
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

END Associate_Root_Sct_To_MSite;

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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'Update_Hierarchy_Item';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_section_id                   NUMBER;
  l_parent_section_id            NUMBER;
  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;
  l_in_item_rec                  INV_ITEM_GRP.ITEM_REC_TYPE;
  l_out_item_rec                 INV_ITEM_GRP.ITEM_REC_TYPE;
  l_out_error_tbl                INV_ITEM_GRP.ERROR_TBL_TYPE;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_HIERARCHY_ITEM_PVT;

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
  -- Get inventory item id
  --
  IF ((p_inventory_item_id IS NULL) OR
      (p_inventory_item_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_INV_ITEM_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Get organization id
  --
  IF ((p_organization_id IS NULL) OR
      (p_organization_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_INV_ORG_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Set the values for inventory to be updated
  --
  l_in_item_rec.INVENTORY_ITEM_ID := p_inventory_item_id;
  l_in_item_rec.ORGANIZATION_ID   := p_organization_id;
  l_in_item_rec.LAST_UPDATED_BY   := p_last_updated_by;
  l_in_item_rec.LAST_UPDATE_DATE  := p_last_update_date;
  l_in_item_rec.LAST_UPDATE_LOGIN := p_last_update_login;
  l_in_item_rec.WEB_STATUS        := p_web_status_type;
  l_in_item_rec.DESCRIPTION       := p_description;
  l_in_item_rec.LONG_DESCRIPTION  := p_long_description;


  INV_ITEM_GRP.Update_Item
    (
    p_commit              => FND_API.G_FALSE,
    p_lock_rows           => FND_API.G_TRUE,
    p_validation_level    => p_validation_level,
    p_Item_rec            => l_in_item_rec,
    x_Item_rec            => l_out_item_rec,
    x_return_status       => x_return_status,
    x_Error_tbl           => l_out_error_tbl
    );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN

      FOR i IN 1..l_out_error_tbl.count LOOP
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INV_API_ERROR');
        FND_MESSAGE.Set_Token('MESSAGE_NAME', l_out_error_tbl(i).MESSAGE_NAME);
        FND_MESSAGE.Set_Token('MESSAGE_TEXT', l_out_error_tbl(i).MESSAGE_TEXT);
        FND_MESSAGE.Set_Token('TRANSACTION_ID',
          l_out_error_tbl(i).TRANSACTION_ID);
        FND_MESSAGE.Set_Token('UNIQUE_ID', l_out_error_tbl(i).UNIQUE_ID);
        FND_MESSAGE.Set_Token('TABLE_NAME', l_out_error_tbl(i).TABLE_NAME);
        FND_MESSAGE.Set_Token('COLUMN_NAME', l_out_error_tbl(i).COLUMN_NAME);
        FND_MESSAGE.Set_Token('ORGANIZATION_ID',
          l_out_error_tbl(i).ORGANIZATION_ID);
        FND_MSG_PUB.Add;
      END LOOP;

      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_UPDATE_INV_ITEM_FAIL');
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

      FOR i IN 1..l_out_error_tbl.count LOOP
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INV_API_ERROR');
        FND_MESSAGE.Set_Token('MESSAGE_NAME', l_out_error_tbl(i).MESSAGE_NAME);
        FND_MESSAGE.Set_Token('MESSAGE_TEXT', l_out_error_tbl(i).MESSAGE_TEXT);
        FND_MESSAGE.Set_Token('TRANSACTION_ID',
          l_out_error_tbl(i).TRANSACTION_ID);
        FND_MESSAGE.Set_Token('UNIQUE_ID', l_out_error_tbl(i).UNIQUE_ID);
        FND_MESSAGE.Set_Token('TABLE_NAME', l_out_error_tbl(i).TABLE_NAME);
        FND_MESSAGE.Set_Token('COLUMN_NAME', l_out_error_tbl(i).COLUMN_NAME);
        FND_MESSAGE.Set_Token('ORGANIZATION_ID',
          l_out_error_tbl(i).ORGANIZATION_ID);
        FND_MSG_PUB.Add;
      END LOOP;

      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_UPDATE_INV_ITEM_FAIL');
      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
--     ROLLBACK TO UPDATE_HIERARCHY_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--     ROLLBACK TO UPDATE_HIERARCHY_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
--     ROLLBACK TO UPDATE_HIERARCHY_ITEM_PVT;
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

END Update_Hierarchy_Item;

--
-- Associate p_mini_site_ids with (p_inventory_item_id, p_organization_id).
-- If there are any other mini-sites associated with (p_inventory_item_id,
-- p_organization_id), they will be removed. At the end of this procedure,
-- (p_inventory_item_id, p_organization_id) will be associated with only
-- mini-sites specified in p_mini_site_ids.
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_MSites_To_Item';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_found_flag                   BOOLEAN;
  l_counter                      NUMBER;
  l_row_id                       VARCHAR2(30);
  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;
  l_mini_site_section_section_id NUMBER;
  l_mini_site_section_item_id    NUMBER;
  l_parent_mini_site_ids         JTF_NUMBER_TABLE;
  l_root_mini_site_ids           JTF_NUMBER_TABLE;
  l_old_mini_site_ids            JTF_NUMBER_TABLE;

  --
  -- Get the mini-sites to which the parent of (l_c_inventory_item_id,
  -- organization_id) belongs to and which does not include master mini-site id
  --
  CURSOR c1(l_c_inventory_item_id IN NUMBER,
            l_c_organization_id IN NUMBER,
            l_c_mini_site_id IN NUMBER,
            l_c_master_mini_site_id IN NUMBER)
  IS SELECT section_item_id FROM ibe_dsp_section_items
    WHERE inventory_item_id = l_c_inventory_item_id
    AND organization_id = l_c_organization_id
    AND EXISTS (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
                WHERE child_section_id = section_id
                AND mini_site_id = l_c_mini_site_id
                AND mini_site_id <> l_c_master_mini_site_id);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  ASSOCIATE_MSITES_TO_ITEM_PVT;

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
  -- Get master mini site id for the store
  --
  Get_Master_Mini_Site_Id(x_mini_site_id    => l_master_mini_site_id,
                          x_root_section_id => l_master_root_section_id);


  --
  -- Delete all the associations for mini-site and inventory item from
  -- ibe_dsp_msite_sct_items table
  --
  DELETE FROM ibe_dsp_msite_sct_items
    WHERE section_item_id IN
    (SELECT section_item_id FROM ibe_dsp_section_items
     WHERE inventory_item_id = p_inventory_item_id
     AND organization_id = p_organization_id);

  IF (sql%NOTFOUND) THEN
    -- ok, as there could be no data in ibe_dsp_msite_sct_sects
    NULL;
  END IF;

  --
  -- Make association for each mini-site in p_mini_site_ids to
  -- (p_inventory_item_id, p_organization_id)
  --
  FOR i IN 1..p_mini_site_ids.COUNT LOOP

    FOR r1 in c1(p_inventory_item_id, p_organization_id, p_mini_site_ids(i),
                 l_master_mini_site_id) LOOP

      IBE_DSP_MSITE_SCT_ITEM_PVT.Create_MSite_Section_Item
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_mini_site_id                   => p_mini_site_ids(i),
        p_section_item_id                => r1.section_item_id,
        p_start_date_active              => sysdate, --col not used for value
        p_end_date_active                => FND_API.G_MISS_DATE,
        x_mini_site_section_item_id      => l_mini_site_section_item_id,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP; -- end r1

  END LOOP; -- for i

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
      ROLLBACK TO ASSOCIATE_MSITES_TO_ITEM_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ASSOCIATE_MSITES_TO_ITEM_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN OTHERS THEN
      ROLLBACK TO ASSOCIATE_MSITES_TO_ITEM_PVT;
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

END Associate_MSites_To_Item;

--
-- This procedure is called when a list of section-section associations is
-- updated or any of the associations is deleted. If any section-section
-- association is deleted, it is equivalent to deleting the child section
-- of the association
--
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
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Delete_Sct_Scts';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_section_item_id   NUMBER;
  l_child_section_id  NUMBER;

  CURSOR c1(l_c_msite_section_section_id IN NUMBER)
  IS SELECT child_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_section_section_id = l_c_msite_section_section_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_DELETE_SCT_SCTS_PVT;

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

  -- API body
  --  CALL FLOW :
  -- 1.

  FOR i IN 1..p_msite_section_section_ids.COUNT LOOP

    IF (p_delete_flags(i) = 'Y') THEN

      OPEN c1(p_msite_section_section_ids(i));
      FETCH c1 INTO l_child_section_id;
      IF (c1%NOTFOUND) THEN
        l_child_section_id := NULL;
      END IF;
      CLOSE c1;

      Delete_Hierarchy_Section
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
        p_section_id                     => l_child_section_id,
        p_access_name                    => FND_API.G_MISS_CHAR,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE

      IBE_DSP_MSITE_SCT_SECT_pvt.Update_Msite_Section_Section
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_mini_site_section_section_id   => p_msite_section_section_ids(i),
        p_object_version_number          => p_object_version_numbers(i),
        p_mini_site_id                   => FND_API.G_MISS_NUM,
        p_parent_section_id              => FND_API.G_MISS_NUM,
        p_child_section_id               => FND_API.G_MISS_NUM,
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_level_number                   => FND_API.G_MISS_NUM,
        p_sort_order                     => p_sort_orders(i),
        p_concat_ids                     => FND_API.G_MISS_CHAR,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END LOOP;

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
     ROLLBACK TO UPDATE_DELETE_SCT_SCTS_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_DELETE_SCT_SCTS_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_DELETE_SCT_SCTS_PVT;

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

END Update_Delete_Sct_Scts;

PROCEDURE Put_Section_Map
  (
   p_from_section_id                IN NUMBER,
   p_to_section_id                  IN NUMBER,
   px_section_map_list              IN OUT NOCOPY SECTION_MAP_list,
   x_return_status                  OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Put_Section_Map';

  l_found                           BOOLEAN;
  l_index                           NUMBER;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_found := FALSE;
  FOR i IN 1..px_section_map_list.COUNT LOOP

    IF (px_section_map_list(i).from_section_id = p_from_section_id) THEN
      l_found := TRUE;
      EXIT;
    END IF;

  END LOOP;

  IF (l_found = FALSE) THEN
    l_index := px_section_map_list.COUNT + 1;
    px_section_map_list.EXTEND();
    px_section_map_list(l_index).from_section_id := p_from_section_id;
    px_section_map_list(l_index).to_section_id := p_to_section_id;
  END IF;

EXCEPTION

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Put_Section_Map;

PROCEDURE Get_Section_Map
  (
   p_section_map_list               IN SECTION_MAP_LIST,
   p_from_section_id                IN NUMBER,
   x_to_section_id                  OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Section_Map';
BEGIN

  -- Initialize API return status to error
  x_return_status := FND_API.G_RET_STS_ERROR;

  FOR i IN 1..p_section_map_list.COUNT LOOP

    IF (p_section_map_list(i).from_section_id = p_from_section_id) THEN
      x_to_section_id := p_section_map_list(i).to_section_id;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      EXIT;
    END IF;

  END LOOP;

EXCEPTION

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Section_Map;

---
--bug 2942525 (code for PROCEDURE Copy_And_Paste_Section removed on 05/07/2003)
-- use PROCEDURE Copy_Section_Ref_Content instead
--

--
-- This procedure cuts the source section p_src_section_id and pastes it
-- under the destination section p_dst_parent_section_id. The source and
-- destination section cannot be the same section. Also the destination section
-- cannot be a descendant section of source section. Also the destination
-- section should not have children as items and also cannot be a featured
-- section. After validation, this procedure makes p_dst_parent_section_id
-- as the parent of p_src_section_id. Then for all the descendant sections
-- of p_src_section_id including p_src_section_id, the level_number and
-- concat_ids is updated in table IBE_DSP_MSITE_SCT_SECTS for master mini-site.
-- Lastly, the association of the (p_src_section_id and all it's descendants
-- including sections and section-items) and mini-sites is updated.
--
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Cut_And_Paste_Section';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;
  l_section_item_id              NUMBER;
  l_tmp_id                       NUMBER;
  l_level_number                 NUMBER;
  l_counter                      NUMBER;
  l_mini_site_ids                JTF_NUMBER_TABLE;
  l_section_type_code            VARCHAR2(30);
  l_concat_ids                   VARCHAR2(2000);


  -- Get the section type code for the section
  CURSOR c1(l_c_section_id IN NUMBER)
  IS SELECT section_type_code
    FROM ibe_dsp_sections_b
    WHERE section_id = l_c_section_id;

  -- Get the section-item-ids for the section
  CURSOR c2(l_c_section_id IN NUMBER)
  IS SELECT section_item_id
    FROM ibe_dsp_section_items
    WHERE section_id = l_c_section_id;

  -- Get all the descendant sections including l_c_section_id, starting from
  -- l_c_section_id
  CURSOR c3(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT parent_section_id, child_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_mini_site_id
    START WITH child_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND PRIOR mini_site_id = l_c_master_mini_site_id
    AND mini_site_id = l_c_master_mini_site_id;

  -- Get all the mini-sites associated with the parent of l_c_section_id (from
  -- ibe_dsp_msite_sct_sects) and with l_c_section_id (from ibe_msites_b)
  -- where l_c_section_id is root section of mini-sites (excluding master
  -- mini-site)
  CURSOR c4(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT mini_site_id FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id =
    (SELECT parent_section_id FROM ibe_dsp_msite_sct_sects
    WHERE child_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id)
    AND mini_site_id <> l_c_master_mini_site_id
    UNION
    SELECT msite_id AS mini_site_id FROM ibe_msites_b
      WHERE msite_root_section_id = l_c_section_id
      AND msite_id <> l_c_master_mini_site_id;

    --
    -- Check if l_c_dst_parent_section_id is a descendant of l_c_src_section_id
    -- This cursor will return one row if l_c_dst_parent_section_id is a
    -- descendant of l_c_src_section_id, otherwise it will return 0 row.
    --
    CURSOR c5(l_c_src_section_id IN NUMBER,
      l_c_dst_parent_section_id IN NUMBER,
      l_c_master_mini_site_id IN NUMBER)
    IS SELECT child_section_id FROM ibe_dsp_msite_sct_sects
      WHERE child_section_id = l_c_dst_parent_section_id
      AND mini_site_id = l_c_master_mini_site_id
      START WITH child_section_id = l_c_src_section_id
      AND mini_site_id = l_c_master_mini_site_id
      CONNECT BY PRIOR child_section_id = parent_section_id
      AND PRIOR mini_site_id = l_c_master_mini_site_id
      AND mini_site_id = l_c_master_mini_site_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT CUT_AND_PASTE_SECTION_PVT;

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
  -- API logic
  --

  --
  -- Get master mini site id for the store
  --
  Get_Master_Mini_Site_Id
    (
    x_mini_site_id    => l_master_mini_site_id,
    x_root_section_id => l_master_root_section_id
    );

  -- Section to be cut should not be an invalid ID
  IF ((p_src_section_id IS NULL) OR
      (p_src_section_id <= 0) OR
      (p_src_section_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVLD_CUT_SRC_SCT');
    FND_MESSAGE.Set_Token('SRC_SECTION_ID', p_src_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- New parent section should not be an invalid ID
  IF ((p_dst_parent_section_id IS NULL) OR
      (p_dst_parent_section_id <= 0)    OR
      (p_dst_parent_section_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVLD_CUT_DST_SCT');
    FND_MESSAGE.Set_Token('DST_PARENT_SECTION_ID', p_dst_parent_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- p_src_section_id and p_dst_parent_section_id cannot be equal.
  -- That is, you cannot cut and paste a section within itself
  --
  IF (p_src_section_id = p_dst_parent_section_id) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_CUT_SAME_SCT_FAIL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- p_dst_parent_section_id cannot be a descendant section of p_src_section_id
  --
  OPEN c5(p_src_section_id, p_dst_parent_section_id, l_master_mini_site_id);
  FETCH c5 INTO l_tmp_id;
  IF (c5%FOUND) THEN
    CLOSE c5;
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_CUT_DST_SCT_IS_DSC_SCT');
    FND_MESSAGE.Set_Token('DST_PARENT_SECTION_ID', p_dst_parent_section_id);
    FND_MESSAGE.Set_Token('SRC_SECTION_ID', p_src_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c5;

  --
  -- Verify if p_dst_parent_section_id section is a navigational section
  -- If it's not, then cannot add (or paste) sections under it
  OPEN c1(p_dst_parent_section_id);
  FETCH c1 INTO l_section_type_code;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ID');
    FND_MESSAGE.Set_Token('SECTION_ID', p_dst_parent_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c1;

  IF (l_section_type_code <> 'N') THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_PRNT_SCT_NOT_NAV');
    FND_MESSAGE.Set_Token('SECTION_ID', p_dst_parent_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if the destination parent section (which is navigational) doesn't
  -- have children as items. If there are child items for this section, then
  -- cannot add child section to it
  OPEN c2(p_dst_parent_section_id);
  FETCH c2 INTO l_section_item_id;
  IF (c2%FOUND) THEN
    CLOSE c2;
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_PRNT_SCT_HAS_CHILD_ITM');
    FND_MESSAGE.Set_Token('SECTION_ID', p_dst_parent_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c2;

  --
  -- Make p_dst_parent_section_id parent of p_src_section_id by removing
  -- p_src_section_id as a child from its current parent at the same time
  --
  BEGIN
    UPDATE ibe_dsp_msite_sct_sects
      SET parent_section_id = p_dst_parent_section_id
      WHERE child_section_id = p_src_section_id
      AND mini_site_id = l_master_mini_site_id;
  EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  --
  -- For all the descendant sections of p_src_section_id including
  -- p_src_section_id, update the level_number and concat_ids for them
  --
  FOR r3 IN c3(p_src_section_id, l_master_mini_site_id) LOOP

    BEGIN

      -- Get the concat_ids for the parent of r3.child_section_id
      Get_Concat_Ids
        (
        p_section_id          => r3.parent_section_id,
        p_master_mini_site_id => l_master_mini_site_id,
        x_concat_ids          => l_concat_ids,
        x_level_number        => l_level_number
        );

      UPDATE ibe_dsp_msite_sct_sects
        SET concat_ids = l_concat_ids,
        level_number = l_level_number + 1
        WHERE child_section_id = r3.child_section_id
        AND mini_site_id = l_master_mini_site_id;

    EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_GET_CONCAT_IDS_FAIL');
         FND_MESSAGE.Set_Token('SECTION_ID', r3.parent_section_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

  END LOOP; -- end loop r3

  --
  -- Associate the new set of mini-sites to p_src_section_id and its
  -- descendants including section-items. For each of these sections (starting
  -- from p_src_section_id), the list of mini-sites associated will be the
  -- union of mini-sites to which their respective parent belong and mini-sites
  -- to which the current section is the root section (ibe_msites_b). Since
  -- the association with start in top-down fashion, the query for c4 will
  -- return the updated results as the loop for c3 progresses.
  --
  -- For each descendant sections of p_src_section_id including
  -- p_src_section_id
  FOR r33 IN c3(p_src_section_id, l_master_mini_site_id) LOOP

    -- For each mini-site associated with parent of r33.child_section_id
    -- and with r33.child_section_id (thru ibe_msites_b)
    l_counter := 1;
    l_mini_site_ids := JTF_NUMBER_TABLE();
    FOR r4 IN c4(r33.child_section_id, l_master_mini_site_id) LOOP
      l_mini_site_ids.EXTEND();
      l_mini_site_ids(l_counter) := r4.mini_site_id;
      l_counter := l_counter + 1;
    END LOOP; -- end loop r4

    -- Associate the mini-sites to section, which will recursively associate
    -- the mini-sites to all descendant sections and section-items
    Associate_MSites_To_Section
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_section_id                     => r33.child_section_id,
      p_mini_site_ids                  => l_mini_site_ids,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_ASC_MSTS_TO_SCT_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_ASC_MSTS_TO_SCT_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP; -- end loop r33

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
     ROLLBACK TO CUT_AND_PASTE_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CUT_AND_PASTE_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CUT_AND_PASTE_SECTION_PVT;
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

END Cut_And_Paste_Section;


PROCEDURE Batch_Duplicate_Section(
	    errbuf	OUT NOCOPY VARCHAR2,
	    retcode OUT NOCOPY NUMBER,
		p_source_section_id IN VARCHAR2,
		p_dest_parent_section_id IN VARCHAR2,
		p_new_sect_display_name IN VARCHAR2 ,
		p_enable_trace  IN  VARCHAR2
		)
IS
	x_return_status		VARCHAR2(1000);
	x_msg_count		NUMBER;
	x_msg_data		VARCHAR2(1000);
    x_new_src_section_id NUMBER;
BEGIN

	if  p_enable_trace = 'Y'  then
		G_ENABLE_TRACE := 'Y';
	end if;
    IF G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'Calling copy_section_ref_content ');
       fnd_file.put_line(fnd_file.log,'section id:'||p_source_section_id);
       fnd_file.put_line(fnd_file.log,'dest section id:'||p_dest_parent_section_id);
    END IF;

	copy_section_ref_content (
		p_api_version   =>1.0,
		p_init_msg_list =>FND_API.G_FALSE,
		p_commit  => FND_API.G_FALSE,
		p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		p_src_section_id   => to_number(p_source_section_id),
		p_dst_parent_section_id => to_number(p_dest_parent_section_id),
		x_new_src_section_id =>  x_new_src_section_id,
		x_return_status  => x_return_status,
		x_msg_count  => x_msg_count,
		x_msg_data   => x_msg_data,
		p_new_display_name => p_new_sect_display_name);

        if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
          retcode := 0;
          errbuf := 'SUCCESS';
       else
            retcode := -1;
            errbuf := x_msg_data;
       end if;
     IF G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'After Calling copy_section_ref_content ');
       fnd_file.put_line(fnd_file.log,'return Code:'||retcode);
       fnd_file.put_line(fnd_file.log,'Return Status:'||errbuf);
    END IF;
END batch_duplicate_section;




-- added by abhandar  apr-25-2002--
--This procedure copies the section p_src_section_id under the section
--p_dst_parent_section_id and references the content. It validates the ID's passed in for the
--sections. The procedure first copies the p_src_section_id, references the content
--,and then all its descendant sections are copied along with reference to the respective contents.
--To do this, it uses the Create_Hierarchy_Section and the  Reference_Section_Content
--APIs of this package. Also the mapping between old section ID and new section
--ID is created to facilitate the logic. After the sections, all the
--section-items are copied (using Associate_Items_To_Section API)
--
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
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
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Copy_Section_Ref_Content';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_master_mini_site_id          NUMBER;
  l_master_root_section_id       NUMBER;
  l_section_id                   NUMBER;
  l_parent_section_id            NUMBER;
  l_found                        BOOLEAN;
  l_section_map_list             SECTION_MAP_LIST;
  l_section_item_ids             JTF_NUMBER_TABLE;
  l_inventory_item_ids           JTF_NUMBER_TABLE;
  l_organization_ids             JTF_NUMBER_TABLE;
  l_start_date_actives           JTF_DATE_TABLE;
  l_end_date_actives             JTF_DATE_TABLE;
  l_sort_orders                  JTF_NUMBER_TABLE;
  l_association_reason_codes     JTF_VARCHAR2_TABLE_300;
  l_duplicate_association_status VARCHAR2(1);
  --bug 3303424
  l_count_langs                  NUMBER;
  l_debug                        VARCHAR2(1);
  -- Get the detail information of the section l_c_section_id
  CURSOR c1(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT S.access_name, S.start_date_active, S.end_date_active,
    S.section_type_code, S.status_code, S.display_context_id, S.deliverable_id,
    S.available_in_all_sites_flag, S.auto_placement_rule, S.order_by_clause,
    S.display_name, S.description, S.long_description, S.keywords,
    S.attribute_category, S.attribute1, S.attribute2, S.attribute3,
    S.attribute4, S.attribute5, S.attribute6, S.attribute7, S.attribute8,
    S.attribute9, S.attribute10, S.attribute11, S.attribute12, S.attribute13,
    S.attribute14, S.attribute15, MSS.sort_order
    FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS
    WHERE S.section_id = l_c_section_id
    AND MSS.child_section_id = S.section_id
    AND MSS.mini_site_id = l_c_master_mini_site_id;

  -- Get the detail information of all descendants of l_c_section_id
  -- Need to do order by level_number so that the parents entries are returned
  -- before the children.
  CURSOR c2(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT S.section_id, S.access_name, S.start_date_active,
    S.end_date_active, S.section_type_code, S.status_code,
    S.display_context_id, S.deliverable_id,
    S.available_in_all_sites_flag, S.auto_placement_rule, S.order_by_clause,
    S.display_name, S.description, S.long_description, S.keywords,
    S.attribute_category, S.attribute1, S.attribute2, S.attribute3,
    S.attribute4, S.attribute5, S.attribute6, S.attribute7, S.attribute8,
    S.attribute9, S.attribute10, S.attribute11, S.attribute12, S.attribute13,
    S.attribute14, S.attribute15, MSS.sort_order, MSS.parent_section_id
    FROM ibe_dsp_sections_vl S, ibe_dsp_msite_sct_sects MSS
    WHERE S.section_id = MSS.child_section_id
    AND MSS.mini_site_id = l_c_master_mini_site_id
    AND S.section_id IN
    (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_mini_site_id
    START WITH parent_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND mini_site_id = l_c_master_mini_site_id)
    ORDER BY MSS.level_number;

  --
  -- Get all the section-items which are descendants of l_c_section_id
  --
  CURSOR c3(l_c_section_id IN NUMBER, l_c_master_mini_site_id IN NUMBER)
  IS SELECT section_item_id, section_id, inventory_item_id, organization_id,
    start_date_active, end_date_active, sort_order, association_reason_code
    FROM ibe_dsp_section_items
    WHERE section_id = l_c_section_id
    OR section_id IN
    (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_mini_site_id
    START WITH parent_section_id = l_c_section_id
    AND mini_site_id = l_c_master_mini_site_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND mini_site_id = l_c_master_mini_site_id);

   -- Cursor to get the translated rows of the section  from ibe_Dsp_sections_tl table
  --bug 3303424
  CURSOR c4(l_c_section_id IN NUMBER)
  IS SELECT language,source_lang,display_name,description,long_description,keywords
  from ibe_dsp_sections_tl where section_id=l_c_section_id;

BEGIN

    -- Standard Start of API savepoint
  SAVEPOINT COPY_SECTION_REF_CONTENT_PVT;
l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
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
  -- API logic
  --

  --
  -- Get master mini site id for the store
  --
  Get_Master_Mini_Site_Id
    (
    x_mini_site_id    => l_master_mini_site_id,
    x_root_section_id => l_master_root_section_id
    );

  -- Section to be copied should not be an invalid ID
  IF ((p_src_section_id IS NULL) OR
      (p_src_section_id <= 0) OR
      (p_src_section_id = FND_API.G_MISS_NUM))
  THEN
	if G_ENABLE_TRACE = 'Y' then
		fnd_file.put_line(fnd_file.log,'Invalid duplicate source section');
  else
		FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVLD_COPY_SRC_SCT');
	   	FND_MESSAGE.Set_Token('SRC_SECTION_ID', p_src_section_id);
    	FND_MSG_PUB.Add;
	end if;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- New parent section should not be an invalid ID
  IF ((p_dst_parent_section_id IS NULL) OR
      (p_dst_parent_section_id <= 0)    OR
      (p_dst_parent_section_id = FND_API.G_MISS_NUM))
  THEN


	if G_ENABLE_TRACE = 'Y' then
		fnd_file.put_line(fnd_file.log,'Invalid duplicate source section');
	  else
    	FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVLD_COPY_DST_SCT');
    	FND_MESSAGE.Set_Token('DST_PARENT_SECTION_ID', p_dst_parent_section_id);
    	FND_MSG_PUB.Add;

	end if;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Initialize the table of record which stores the section mappings
  --
  l_section_map_list := SECTION_MAP_LIST();

  --
  -- Copy the p_src_section_id first
  -- Get the detail information of the p_src_section_id and call the API
  -- to create similar new section as a child of p_dst_section_id
  -- The for loop will only loop once. For loop is used in place of
  -- open/ftech/close because need to get all the columns without creating
  -- a record for them
  --
  l_found := FALSE;
  --bug 3303424
  select count(*)into l_count_langs from fnd_languages where installed_flag in ('I','B');

  FOR r1 IN c1(p_src_section_id, l_master_mini_site_id) LOOP
    l_found := TRUE;
   IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Create_Hierarchy_Section for immediate section ');

   IBE_UTIL.debug('parent section id:'||p_dst_parent_section_id);
  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Create_Hierarchy_Section for immediate section ');

   fnd_file.put_line(fnd_file.log,'parent section id:'||p_dst_parent_section_id);
  END IF;

    Create_Hierarchy_Section
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_parent_section_id              => p_dst_parent_section_id,
      p_parent_section_access_name     => FND_API.G_MISS_CHAR,
      p_access_name                    => FND_API.G_MISS_CHAR,
      p_start_date_active              => r1.start_date_active,
      p_end_date_active                => r1.end_date_active,
      p_section_type_code              => r1.section_type_code,
      p_status_code                    => r1.status_code,
      p_display_context_id             => r1.display_context_id,
      p_deliverable_id                 => r1.deliverable_id,
      p_available_in_all_sites_flag    => r1.available_in_all_sites_flag,
      p_auto_placement_rule            => r1.auto_placement_rule,
      p_order_by_clause                => r1.order_by_clause,
      p_sort_order                     => r1.sort_order,
      p_display_name                   => r1.display_name,
      p_description                    => r1.description,
      p_long_description               => r1.long_description,
      p_keywords                       => r1.keywords,
      p_attribute_category             => r1.attribute_category,
      p_attribute1                     => r1.attribute1,
      p_attribute2                     => r1.attribute2,
      p_attribute3                     => r1.attribute3,
      p_attribute4                     => r1.attribute4,
      p_attribute5                     => r1.attribute5,
      p_attribute6                     => r1.attribute6,
      p_attribute7                     => r1.attribute7,
      p_attribute8                     => r1.attribute8,
      p_attribute9                     => r1.attribute9,
      p_attribute10                    => r1.attribute10,
      p_attribute11                    => r1.attribute11,
      p_attribute12                    => r1.attribute12,
      p_attribute13                    => r1.attribute13,
      p_attribute14                    => r1.attribute14,
      p_attribute15                    => r1.attribute15,
	  p_inherit_layout                 => FND_API.G_FALSE,
      x_section_id                     => x_new_src_section_id,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );
    IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('After Calling Create_Hierarchy_Section for immediate section ');
   IBE_UTIL.debug('new section id:'||x_new_src_section_id);

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'After Calling Create_Hierarchy_Section for immediate section ');
   fnd_file.put_line(fnd_file.log,'new section id:'||x_new_src_section_id);

  END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		if G_ENABLE_TRACE = 'Y' then
			fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Create_Hierarchy_Section');

		else
      		FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_CRT_HIER_SCT_FAIL');
      		FND_MSG_PUB.Add;

        end if;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR in Create_Hierarchy_Section');
	else
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_CRT_HIER_SCT_FAIL');
      FND_MSG_PUB.Add;

      end if;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  ---------------------------------------------------
 -- customer bug 3303424:
 -- update the ibe_dsp_section_tl table  of the duplicated section
 -- with the display name, shortdesc, longdesc and keywords of the source section.
 -- except for the session lang row
-- customer bug 3303424:

 if ( l_count_langs >1)then -- if more than one lang installed
   FOR r4 IN c4(p_src_section_id) LOOP
     update ibe_dsp_sections_tl set
         display_name= r4.display_name,
         description = r4.description,
         long_description = r4.long_description,
         keywords= r4.keywords,
         source_lang = r4.source_lang
      where language=r4.language and section_id=x_new_src_section_id
      and language <>userenv('lang');
   END LOOP;
end if;

-- modify the display name for the sesion language.
if  p_new_display_name is not null then
       update ibe_dsp_sections_tl
       set display_name = p_new_display_name
       where section_id = x_new_src_section_id
       and language= userenv('lang');
    end if;

 /*
   FOR r4 IN c4(p_src_section_id) LOOP

     IF p_new_display_name=r1.display_name  and l_count_langs >1 then
      -- if  multiple lang installed and the input display name for the duplicated section
      -- is same  as the src section display name then update the translated rows from src section
      -- except for the session lang row.

        update ibe_dsp_sections_tl set
         display_name = r4.display_name,
         description = r4.description,
         long_description = r4.long_description,
         keywords= r4.keywords,
         source_lang=r4.source_lang
         where language=r4.language
         and section_id=x_new_src_section_id
         and language <> userenv('lang');

    ELSIF p_new_display_name is not null and p_new_display_name <> r1.display_name then

    -- if new display name is not same as the src section name then
    -- update the duplicated section display name with the new display name
    -- for all rows, keeping the source_lang column same as the userenv(lang).

         update ibe_dsp_sections_tl set
         display_name = p_new_display_name,
         description = r4.description,
         long_description = r4.long_description,
         keywords= r4.keywords
         where language=r4.language
         and section_id=x_new_src_section_id;
    END IF;
  END LOOP;
*/

 -----------------------------------------------------------------
  ---------  Reference content for the copied  section
 -----------------------------------------------------------------
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Reference_Section_Content ,copying from p_src_section :'||p_src_section_id ||'to x_new_section_id:'||x_new_src_section_id);


  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Reference_Section_Content,copying from p_src_section :'||p_src_section_id ||'to x_new_section_id:'||x_new_src_section_id );

  END IF;
    Reference_Section_Content(
       p_old_section_id                 =>p_src_section_id,
       p_new_section_id                 =>x_new_src_section_id,
       x_return_status                  =>x_return_status,
       x_msg_count                      =>x_msg_count,
       x_msg_data                       =>x_msg_data);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Reference_Section_Content');
	 end if;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR in Reference_Section_Content');
	 end if;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Put_Section_Map ,copying from p_src_section :'||p_src_section_id ||'to x_new_section_id:'||x_new_src_section_id);


  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Put_Section_Map,copying from p_src_section :'||p_src_section_id ||'to x_new_section_id:'||x_new_src_section_id );

  END IF;

    Put_Section_Map
      (
      p_from_section_id                => p_src_section_id,
      p_to_section_id                  => x_new_src_section_id,
      px_section_map_list              => l_section_map_list,
      x_return_status                  => x_return_status
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Put_Section_Map, with IBE_DSP_SCT_MAP_INSERT_FAIL error');
	 end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_INSERT_FAIL');
      FND_MESSAGE.Set_Token('FROM_SECTION_ID', p_src_section_id);
      FND_MESSAGE.Set_Token('TO_SECTION_ID', x_new_src_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR in Put_Section_Map, with IBE_DSP_SCT_MAP_INSERT_FAIL error');
	 end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_INSERT_FAIL');
      FND_MESSAGE.Set_Token('FROM_SECTION_ID', p_src_section_id);
      FND_MESSAGE.Set_Token('TO_SECTION_ID', x_new_src_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- 11.5.10, Copy layout component mapping during section  duplication
    -- including center display template
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Copy_Layout_Comp_Mapping ,copying from p_src_section :'||p_src_section_id ||'to x_new_section_id:'||x_new_src_section_id);


  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Copy_Layout_Comp_Mapping,copying from p_src_section :'||p_src_section_id ||'to x_new_section_id:'||x_new_src_section_id );

  END IF;
    Copy_Layout_Comp_Mapping(
      p_api_version => 1.0,
	 p_init_msg_list => FND_API.G_FALSE,
	 p_commit => FND_API.G_FALSE,
	 p_source_section_id => p_src_section_id,
	 p_target_section_id => x_new_src_section_id,
	 p_include_all => FND_API.G_TRUE,
	 x_return_status => x_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data);
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Copy_Layout_Comp_Mapping');
	 end if;
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get RET_STS_UNEXP_ERROR in Copy_Layout_Comp_Mapping');
	 end if;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    EXIT;
   -- adding commit 11/20/03 ab :to avoid time out in case large number of sections duplicated
   COMMIT;
  END LOOP; -- end for r1 in c1

  IF (l_found = FALSE) THEN
       if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_IBE_DSP_COPY_SRC_SCT_NOT_FOUND error');
	 end if;
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_COPY_SRC_SCT_NOT_FOUND');
    FND_MESSAGE.Set_Token('SRC_SECTION_ID', p_src_section_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Copy all the descendants of p_src_section_id
  -- Get the detail information of the descendants of p_src_section_id
  -- and call the API to create similar new section
  --
  FOR r2 IN c2(p_src_section_id, l_master_mini_site_id) LOOP

    IF (r2.section_id = x_new_src_section_id) THEN
      -- do nothing. This might happen when p_src_section_id = p_dst_section_id
      -- In that case, don't want to re-copy the same section
      NULL;
    ELSE

      Get_Section_Map
        (
        p_section_map_list               => l_section_map_list,
        p_from_section_id                => r2.parent_section_id,
        x_to_section_id                  => l_parent_section_id,
        x_return_status                  => x_return_status
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR error in Get_Section_Map for descendants of parent section ');
	    fnd_file.put_line(fnd_file.log,'get IBE_DSP_SCT_MAP_GET_FAIL error in Get_Section_Map for descendants of parent section ');
      end if;
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_GET_FAIL');
        FND_MESSAGE.Set_Token('FROM_SECTION_ID', r2.parent_section_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      if G_ENABLE_TRACE = 'Y' then
        fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR error in Get_Section_Map for descendants of parent section ');
	    fnd_file.put_line(fnd_file.log,'get IBE_DSP_SCT_MAP_GET_FAIL error in Get_Section_Map for descendants of parent section ');
      end if;
        FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_GET_FAIL');
        FND_MESSAGE.Set_Token('FROM_SECTION_ID', r2.parent_section_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Create_Hierarchy_Section for immediate section ');
   IBE_UTIL.debug('section id:'||l_parent_section_id);

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Create_Hierarchy_Section for immediate section ');
   fnd_file.put_line(fnd_file.log,'section id:'||l_parent_section_id);

  END IF;
      Create_Hierarchy_Section
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_parent_section_id              => l_parent_section_id,
        p_parent_section_access_name     => FND_API.G_MISS_CHAR,
        p_access_name                    => FND_API.G_MISS_CHAR,
        p_start_date_active              => r2.start_date_active,
        p_end_date_active                => r2.end_date_active,
        p_section_type_code              => r2.section_type_code,
        p_status_code                    => r2.status_code,
        p_display_context_id             => r2.display_context_id,
        p_deliverable_id                 => r2.deliverable_id,
        p_available_in_all_sites_flag    => r2.available_in_all_sites_flag,
        p_auto_placement_rule            => r2.auto_placement_rule,
        p_order_by_clause                => r2.order_by_clause,
        p_sort_order                     => r2.sort_order,
        p_display_name                   => r2.display_name,
        p_description                    => r2.description,
        p_long_description               => r2.long_description,
        p_keywords                       => r2.keywords,
        p_attribute_category             => r2.attribute_category,
        p_attribute1                     => r2.attribute1,
        p_attribute2                     => r2.attribute2,
        p_attribute3                     => r2.attribute3,
        p_attribute4                     => r2.attribute4,
        p_attribute5                     => r2.attribute5,
        p_attribute6                     => r2.attribute6,
        p_attribute7                     => r2.attribute7,
        p_attribute8                     => r2.attribute8,
        p_attribute9                     => r2.attribute9,
        p_attribute10                    => r2.attribute10,
        p_attribute11                    => r2.attribute11,
        p_attribute12                    => r2.attribute12,
        p_attribute13                    => r2.attribute13,
        p_attribute14                    => r2.attribute14,
        p_attribute15                    => r2.attribute15,
	   p_inherit_layout                 => FND_API.G_FALSE,
        x_section_id                     => l_section_id,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );
    END IF;
   IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('After Calling Create_Hierarchy_Section for immediate section ');
   IBE_UTIL.debug('new section id:'||l_section_id);

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'After Calling Create_Hierarchy_Section for immediate section ');
   fnd_file.put_line(fnd_file.log,'new section id:'||l_section_id);

  END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    if G_ENABLE_TRACE = 'Y' then
	   fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Create_Hierarchy_Section');
	end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_CRT_HIER_SCT_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    if G_ENABLE_TRACE = 'Y' then
	   fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR in Create_Hierarchy_Section');
	end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_CRT_HIER_SCT_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


          ---------------------------------------------------
 -- customer bug 3303424:
 -- update the ibe_dsp_section_tl table  of the duplicated child section
 -- with the display name, shortdesc, longdesc and keywords of the source child section.


 if ( l_count_langs >1)then -- if more than one lang installed
   FOR r4 IN c4(r2.section_id) LOOP

     update ibe_dsp_sections_tl set
        display_name= r4.display_name,
        description = r4.description,
        long_description = r4.long_description,
        keywords= r4.keywords,
        source_lang = r4.source_lang
       where language=r4.language and section_id=l_section_id
       and language <>userenv('lang');
   END LOOP;
end if;

------------------------------------- ---------------------------------------------
 --------------------------Reference content for  the copied descendent sections
--------------------------------------------------------------------------------------
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Reference_Section_Content ,copying from p_src_section :'||r2.section_id ||'to x_new_section_id:'||l_section_id);


  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Reference_Section_Content,copying from p_src_section :'||r2.section_id ||'to x_new_section_id:'||l_section_id );

  END IF;
    Reference_Section_Content(
       p_old_section_id                 =>r2.section_id,
       p_new_section_id                 =>l_section_id,
       x_return_status                  =>x_return_status,
       x_msg_count                      =>x_msg_count,
       x_msg_data                       =>x_msg_data);

       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Reference_Section_Content');
	 end if;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR in Reference_Section_Content');
	 end if;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Put_Section_Map
      (
      p_from_section_id                => r2.section_id,
      p_to_section_id                  => l_section_id,
      px_section_map_list              => l_section_map_list,
      x_return_status                  => x_return_status
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
       if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Put_Section_Map, with IBE_DSP_SCT_MAP_INSERT_FAIL error');
	 end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_INSERT_FAIL');
      FND_MESSAGE.Set_Token('FROM_SECTION_ID', r2.section_id);
      FND_MESSAGE.Set_Token('TO_SECTION_ID', l_section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Put_Section_Map, with IBE_DSP_SCT_MAP_INSERT_FAIL error');
	 end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_INSERT_FAIL');
      FND_MESSAGE.Set_Token('FROM_SECTION_ID', r2.section_id);
      FND_MESSAGE.Set_Token('TO_SECTION_ID', l_section_id);
      FND_MSG_PUB.Add;
    END IF;

    -- 11.5.10, Copy layout component mapping during section  duplication
    -- including center display template
   IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Copy_Layout_Comp_Mapping ,copying from p_src_section :'||r2.section_id ||'to x_new_section_id:'||l_section_id);


  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Copy_Layout_Comp_Mapping,copying from p_src_section :'||r2.section_id ||'to x_new_section_id:'||l_section_id );

  END IF;
    Copy_Layout_Comp_Mapping(
      p_api_version => 1.0,
	 p_init_msg_list => FND_API.G_FALSE,
	 p_commit => FND_API.G_FALSE,
	 p_source_section_id => r2.section_id,
	 p_target_section_id => l_section_id,
	 p_include_all => FND_API.G_TRUE,
	 x_return_status => x_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data);
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
       if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Copy_Layout_Comp_Mapping');
	 end if;
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR in Copy_Layout_Comp_Mapping');
	 end if;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
/* An idea ahead of its time ...
	copy_segments (
		p_api_version   =>1.0,
		p_init_msg_list  => FND_API.G_FALSE,
		p_commit     => FND_API.G_FALSE,
		p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		p_source_section_id => r2.section_id,
		p_target_section_id => l_section_id,
		x_return_status =>x_return_status,
		x_msg_count =>x_msg_count,
		x_msg_data  =>x_msg_data);
*/

     -- adding commit 11/20/03 ab :to avoid time out in case large number of sections duplicated
   COMMIT;
  END LOOP;

  --
  -- Copy the section items
  --
  FOR r3 IN c3(p_src_section_id, l_master_mini_site_id) LOOP

    Get_Section_Map
      (
      p_section_map_list               => l_section_map_list,
      p_from_section_id                => r3.section_id,
      x_to_section_id                  => l_section_id,
      x_return_status                  => x_return_status
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_GET_FAIL');
      FND_MESSAGE.Set_Token('FROM_SECTION_ID', r3.section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MAP_GET_FAIL');
      FND_MESSAGE.Set_Token('FROM_SECTION_ID', r3.section_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_inventory_item_ids       := JTF_NUMBER_TABLE();
    l_organization_ids         := JTF_NUMBER_TABLE();
    l_start_date_actives       := JTF_DATE_TABLE();
    l_end_date_actives         := JTF_DATE_TABLE();
    l_sort_orders              := JTF_NUMBER_TABLE();
    l_association_reason_codes := JTF_VARCHAR2_TABLE_300();

    l_inventory_item_ids.EXTEND();
    l_organization_ids.EXTEND();
    l_start_date_actives.EXTEND();
    l_end_date_actives.EXTEND();
    l_sort_orders.EXTEND();
    l_association_reason_codes.EXTEND();

    l_inventory_item_ids(1) := r3.inventory_item_id;
    l_organization_ids(1) := r3.organization_id;
    l_start_date_actives(1) := r3.start_date_active;
    l_end_date_actives(1) := r3.end_date_active;
    l_sort_orders(1) := r3.sort_order;
    l_association_reason_codes(1) := r3.association_reason_code;
 IF (l_debug = 'Y') THEN
   IBE_UTIL.debug(' Calling Associate_Items_To_Section to copy section items to section :'||l_section_id);

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,' Calling Associate_Items_To_Section to copy section items to section :'||l_section_id);

  END IF;
    Associate_Items_To_Section
      (
      p_api_version                    => p_api_version,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => p_validation_level,
      p_section_id                     => l_section_id,
      p_inventory_item_ids             => l_inventory_item_ids,
      p_organization_ids               => l_organization_ids,
      p_start_date_actives             => l_start_date_actives,
      p_end_date_actives               => l_end_date_actives,
      p_sort_orders                    => l_sort_orders,
      p_association_reason_codes       => l_association_reason_codes,
      x_section_item_ids               => l_section_item_ids,
      x_duplicate_association_status   => l_duplicate_association_status,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_ERROR in Associate_Items_To_Section');
	 end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_ASC_ITMS_TO_SCT_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      if G_ENABLE_TRACE = 'Y' then
       fnd_file.put_line(fnd_file.log,'get G_RET_STS_UNEXP_ERROR in Associate_Items_To_Section');
	 end if;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_ASC_ITMS_TO_SCT_FAIL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- adding commit 11/20/03 ab :to avoid time out in case large number of sections duplicated
   COMMIT;
  END LOOP;

  -- Standard check of p_commit.
  --commented the following as we are already doing commit for each duplicated section
  --IF (FND_API.To_Boolean(p_commit)) THEN
   -- COMMIT WORK;
  --END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION
    -- commenting the Rollback as we already commit for each duplicated section
    WHEN FND_API.G_EXC_ERROR THEN
    -- ROLLBACK TO COPY_SECTION_REF_CONTENT_PVT;
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug(' Calling Delete_Hierarchy_Section to delete sections if exception happens'||x_new_src_section_id );

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,' Calling Delete_Hierarchy_Section to delete sections if exception happens '||x_new_src_section_id);

  END IF;
    Delete_Hierarchy_Section(p_api_version =>1.0,
                             p_init_msg_list=> FND_API.G_FALSE,
                             p_commit => FND_API.G_FALSE,
                             p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                             p_section_id => x_new_src_section_id,
                             p_access_name=> null,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data);

     FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_DUP_HIER_SCT_FAIL');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- ROLLBACK TO COPY_SECTION_REF_CONTENT_PVT;
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug(' Calling Delete_Hierarchy_Section when G_EXC_UNEXPECTED_ERROR'||x_new_src_section_id);

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,' Calling Delete_Hierarchy_Section when G_EXC_UNEXPECTED_ERROR '||x_new_src_section_id);

  END IF;
      Delete_Hierarchy_Section(p_api_version =>1.0,
                             p_init_msg_list=> FND_API.G_FALSE,
                             p_commit => FND_API.G_FALSE,
                             p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                             p_section_id => x_new_src_section_id,
                             p_access_name=> null,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data);

     FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_DUP_HIER_SCT_FAIL');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug(' Calling Delete_Hierarchy_Section when Other exception happens'||x_new_src_section_id);

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,' Calling Delete_Hierarchy_Section when Other exception happens '||x_new_src_section_id);

  END IF;
   --  ROLLBACK TO COPY_SECTION_REF_CONTENT_PVT;
     Delete_Hierarchy_Section(p_api_version =>1.0,
                             p_init_msg_list=> FND_API.G_FALSE,
                             p_commit => FND_API.G_FALSE,
                             p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                             p_section_id => x_new_src_section_id,
                             p_access_name=> null,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data);

     FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_J_DUP_HIER_SCT_FAIL');
     FND_MSG_PUB.Add;
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



END Copy_Section_Ref_Content;

-----------------------------------------------------------------------------------------------------------
--  Reference the contents of the old section to the new section.

---  Associate the new section with these  existing Logical Media and Mutimedia
--- ---------------------------------------------------------------------------------

 PROCEDURE Reference_Section_Content
  (
   p_old_section_id                 IN NUMBER,
   p_new_section_id                 IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
l_api_name                     CONSTANT VARCHAR2(30) :=
   'Reference_section_Content';
l_api_version                  CONSTANT NUMBER    := 1.0;
l_old_section_id               NUMBER;
l_new_section_id               NUMBER;
l_item_id                      NUMBER;
l_new_item_id                  NUMBER;

--get all the logical multimedia associated with the original Section

CURSOR c1(l_old_section_id IN NUMBER)
    IS SELECT item_id,context_id from ibe_dsp_obj_lgl_ctnt where
    object_type='S' and object_id= l_old_section_id;



BEGIN
  IF ((p_old_section_id is null) or (p_new_section_id is null))  then
        RAISE FND_API.g_exc_error;
  END IF;
  -- dbms_output.put_line('old_section_id=' || p_old_section_id);

   FOR r1 in c1(p_old_section_id) LOOP

          -- dbms_output.put_line('old media object=' || r1.item_id);

           --save the new section, old logical media ,old context in the ibe_dsp_lgl_ctnt table
           Save_Object_Logical_Content(   p_object_id     => p_new_section_id,
                                          p_context_id    => r1.context_id,
                                          p_object_type   => 'S',
                                          p_item_id       => r1.item_id,
                                          x_msg_count     => x_msg_count,
                                          x_return_status => x_return_status,
                                          x_msg_data      => x_msg_data);

             -- dbms_output.put_line('saved in the object logical content');

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    END LOOP; -- End for r1 in c1

  END Reference_Section_Content;


-----------------------------------------------------------------------------------------------------------
--  DEPRECATED: Due to change in requirement from PMs.  : abhandar 14-Aug 2002
-- Reference the contents of the old section to the new section.
--
---step1:Retrieve all the Logical Media associated with the Old_Section
-- step2:Create copy of all these Logical Media (jtf_amv_items_b/tl table)
-- step3:Associate the new section with these new Logical Media ( ibe_dsp_obj_lgl_ctnt table)
-- step4:For all the new Logical media, create equivalent  store mappings as existed for the Old Logical Media
--   (ibe_dsp_lgl_phys_map)

---------------------------------------------------------------------------------------------------
--** PROCEDURE Reference_Section_Content
--**  (
--**   p_old_section_id                 IN NUMBER,
--**   p_new_section_id                 IN NUMBER,
--**   x_return_status                  OUT NOCOPY VARCHAR2,
--**   x_msg_count                      OUT NOCOPY NUMBER,
--**   x_msg_data                       OUT NOCOPY VARCHAR2
--**  )
--** IS
--** l_api_name                     CONSTANT VARCHAR2(30) :=
--**    'Reference_section_Content';
--** l_api_version                  CONSTANT NUMBER    := 1.0;
--** l_old_section_id               NUMBER;
--** l_new_section_id               NUMBER;
--** l_item_id                      NUMBER;
--** l_new_item_id                  NUMBER;

--get all the logical multimedia associated with the original Section

--** CURSOR c1(l_old_section_id IN NUMBER)
--**     IS SELECT item_id,context_id from ibe_dsp_obj_lgl_ctnt where
--**     object_type='S' and object_id= l_old_section_id;


-- get all the mappings associated with the Media logical item

--** CURSOR c2(l_item_id IN NUMBER)
--**      IS SELECT msite_id,language_code,attachment_id,default_language,default_site
--**      from  ibe_dsp_lgl_phys_map where item_id=l_item_id;

--** BEGIN
--**   IF ((p_old_section_id is null) or (p_new_section_id is null))  then
--**         RAISE FND_API.g_exc_error;
--**   END IF;
  -- dbms_output.put_line('old_section_id=' || p_old_section_id);

--**   FOR r1 in c1(p_old_section_id) LOOP

           -- for each logical Media, create a copy of it
--**            Copy_Logical_Media(p_item_id     => r1.item_id,
--**                              p_object_id    => p_new_section_id,
--**                              p_context_id   => r1.context_id,
--**                              x_new_item_id  => l_new_item_id,
--**                              x_msg_count    => x_msg_count,
--**                              x_return_status=> x_return_status,
--**                              x_msg_data     => x_msg_data);

          -- dbms_output.put_line('old media object=' || r1.item_id);

           --save the new section, new logical media ,old context in the ibe_dsp_lgl_ctnt table
--**            Save_Object_Logical_Content(   p_object_id     => p_new_section_id,
--**                                           p_context_id    => r1.context_id,
--**                                           p_object_type   => 'S',
--**                                           p_item_id       => l_new_item_id,
--**                                           x_msg_count     => x_msg_count,
--**                                           x_return_status => x_return_status,
--**                                           x_msg_data      => x_msg_data);

             -- dbms_output.put_line('saved in the object logical content');

           -- now save all the mappings for the new Logical Media's

               -- get all the mapping for the old Logical Media
--**                For r2 in c2(r1.item_id) LOOP

                  -- Add all the mappings in the ibe_dsp_lgl_phys_map table for the copied new Logical Item Id

--**                     Save_Physical_Map(p_item_id          => l_new_item_id,
--**                                      p_msite_id         => r2.msite_id,
--**                                      p_language_code    =>r2.language_code,
--**                                      p_attachment_id    =>r2.attachment_id,
--** 				                     p_default_site     =>r2.default_site,
--**                                      p_default_language =>r2.default_language,
--**                                      x_return_status    =>x_return_status,
--**                                      x_msg_count        =>x_msg_count,
--**                                      x_msg_data	        =>x_msg_data);

				 -- dbms_output.put_line('inserting into ibe_dsp_lgl_phys_map');

--**     	     END LOOP; -- end for r2 in c2


--**     END LOOP; -- End for r1 in c1

--**   END Reference_Section_Content;

------------------------------------------------------------------------
  -- Procedure to Create a copy of the logical media item
  --
  --
  PROCEDURE Copy_Logical_Media(
       p_item_id        IN    NUMBER,
       p_object_id      IN    NUMBER,
       p_context_id     IN    NUMBER,
       x_new_item_id    OUT NOCOPY NUMBER,
       x_msg_count      OUT NOCOPY NUMBER,
       x_return_status  OUT NOCOPY VARCHAR2,
       x_msg_data       OUT NOCOPY VARCHAR2
   )
   IS
        l_api_name      CONSTANT VARCHAR2(30):='Copy_Logical_Media';

        l_api_version   CONSTANT NUMBER       := 1.0;

        l_deliverable_rec    IBE_DELIVERABLE_GRP.DELIVERABLE_REC_TYPE;

   BEGIN

     select access_name,item_name,deliverable_type_code,applicable_to_code,keyword,description
     into l_deliverable_rec.access_name,
          l_deliverable_rec.display_name,
          l_deliverable_rec.item_type,
          l_deliverable_rec.item_applicable_to,
          l_deliverable_rec.keywords,
          l_deliverable_rec.description
     from ibe_dsp_amv_items_v where item_id=p_item_id;

     if (SQL%NOTFOUND) then
        RAISE FND_API.g_exc_error;
      END IF;

      -- change the item  display name to 'Copy of'  the old display name
     --l_deliverable_rec.display_name:= 'Copy of ' || l_deliverable_rec.display_name;


     l_deliverable_rec.access_name := 'IBE_MO_'||p_object_id ||'_'||p_context_id;

     l_deliverable_rec.object_version_number:=1;
     l_deliverable_rec.x_action_status:=null;

      IBE_DELIVERABLE_GRP.save_deliverable (
                p_api_version	        =>l_api_version,
                p_init_msg_list	        =>FND_API.g_false,
                p_commit	            =>FND_API.g_false,
                x_return_status	        =>x_return_status,
                x_msg_count		        =>x_msg_count,
                x_msg_data		        =>x_msg_data,
                p_deliverable_rec       =>l_deliverable_rec);


      x_new_item_id:= l_deliverable_rec.deliverable_id ;
     -- dbms_output.put_line('New media object=' || l_deliverable_rec.deliverable_id);
     -- dbms_output.put_line('Return Status' || x_return_status);

  EXCEPTION
       WHEN FND_API.g_exc_error then
         	IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
    			x_return_status := FND_API.g_ret_sts_error;
	       END IF;

      WHEN OTHERS THEN
			x_return_status := FND_API.g_ret_sts_unexp_error ;

  END Copy_Logical_Media;

---------------------------------------------------------------------------
-- save the rows in the ibe_dsp_lgl_phys_map table for the logical item id.
--
--
PROCEDURE Save_Physical_Map(p_item_id           IN  NUMBER,
                           p_msite_id           IN  NUMBER,
                           p_language_code      IN  VARCHAR2,
                           p_attachment_id      IN  NUMBER,
				           p_default_site       IN  VARCHAR2,
                           p_default_language   IN  VARCHAR2,
                           x_return_status	    OUT NOCOPY VARCHAR2,
                           x_msg_count		    OUT NOCOPY NUMBER,
                           x_msg_data		    OUT NOCOPY VARCHAR2)

  IS
        l_api_name      CONSTANT VARCHAR2(30):='Save_Physical_Map';
        l_api_version   CONSTANT NUMBER       := 1.0;
        l_lgl_phys_map_id  NUMBER;
        l_language_code_tbl    ibe_physicalMap_grp.LANGUAGE_CODE_TBL_TYPE;

        CURSOR lgl_phys_map_id_seq IS
		SELECT IBE_DSP_LGL_PHYS_MAP_S1.NEXTVAL FROM DUAL;
  BEGIN

         IF (p_item_id IS NULL)or (p_msite_id IS NULL) OR (p_attachment_id IS NULL)
          OR (p_language_code IS NULL ) or (p_default_site is null ) or (p_default_language is null) THEN
		     RAISE FND_API.g_exc_error;
          END IF;

         OPEN lgl_phys_map_id_seq;
	     FETCH lgl_phys_map_id_seq INTO l_lgl_phys_map_id;
		 CLOSE lgl_phys_map_id_seq;

         INSERT INTO IBE_DSP_LGL_PHYS_MAP (
				lgl_phys_map_id,
				object_version_number,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				msite_id,
				language_code,
				attachment_id,
				item_id,
				default_site,
				default_language
			) VALUES (
				l_lgl_phys_map_id,
				1,
				SYSDATE,
				FND_GLOBAL.user_id,
				SYSDATE,
				FND_GLOBAL.user_id,
				FND_GLOBAL.login_id,
				p_msite_id,
				p_language_code,
				p_attachment_id,
				p_item_id,
				p_default_site,
				p_default_language);

  EXCEPTION
           	WHEN FND_API.g_exc_error THEN
					IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
						x_return_status := FND_API.g_ret_sts_error;
					END IF;

				WHEN dup_val_on_index THEN

					IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
						x_return_status := FND_API.g_ret_sts_error;
					END IF;

              WHEN OTHERS THEN

					x_return_status := FND_API.g_ret_sts_unexp_error ;

  END Save_Physical_Map;

-----------------------------------------------------------------------
-- save the logical content for the Section
---
  PROCEDURE Save_Object_Logical_Content(
   p_object_id              IN  NUMBER,
   p_context_id             IN  NUMBER,
   p_item_id                IN  NUMBER,
   p_object_type            IN  VARCHAR2,
   x_return_status	    OUT NOCOPY VARCHAR2,
   x_msg_count		    OUT NOCOPY NUMBER,
   x_msg_data		    OUT NOCOPY VARCHAR2)

  IS

  l_api_name      CONSTANT VARCHAR2(30) :='Save Object Logical Content';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_obj_lgl_ctnt_rec_type  IBE_LOGICALCONTENT_GRP.obj_lgl_ctnt_rec_type;
  l_obj_lgl_ctnt_tbl_type  IBE_LOGICALCONTENT_GRP.obj_lgl_ctnt_tbl_type;

  BEGIN

    IF ((p_object_id is null) OR (p_context_id is null) or (p_item_id is null)
         or (p_object_type is null))  Then
         Raise FND_API.g_exc_error;
    End if;

    l_obj_lgl_ctnt_rec_type.obj_lgl_ctnt_delete:=   FND_API.g_false;
    l_obj_lgl_ctnt_rec_type.OBJ_lgl_ctnt_id:=       null;
    l_obj_lgl_ctnt_rec_type.Object_Version_Number:= 1.0;
    l_obj_lgl_ctnt_rec_type.Object_id:=             p_object_id;
    l_obj_lgl_ctnt_rec_type.Context_id:=            p_context_id;
    l_obj_lgl_ctnt_rec_type.deliverable_id:=        p_item_id;

    l_obj_lgl_ctnt_tbl_type(1):=l_obj_lgl_ctnt_rec_type;

    IBE_LOGICALCONTENT_GRP.save_delete_lgl_ctnt(
                    p_api_version         =>l_api_version,
                    p_init_msg_list       => FND_API.g_false,
                    p_commit              => FND_API.g_false,
                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data,
                    p_object_type_code    => 'S',
                    p_lgl_ctnt_tbl        => l_obj_lgl_ctnt_tbl_type);

    EXCEPTION
           	WHEN FND_API.g_exc_error THEN
					IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
						x_return_status := FND_API.g_ret_sts_error;
					END IF;

				WHEN dup_val_on_index THEN

					IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
						x_return_status := FND_API.g_ret_sts_error;
					END IF;

              WHEN OTHERS THEN

					x_return_status := FND_API.g_ret_sts_unexp_error ;


   END Save_Object_Logical_Content;
   PROCEDURE  Batch_Cascade_Sec_Layout_Map(
    		errbuf	OUT NOCOPY VARCHAR2,
	    	retcode OUT NOCOPY NUMBER,
		p_section_id         IN VARCHAR2,
		p_enable_trace_flag  IN VARCHAR2)

		IS
    		x_return_status		VARCHAR2(1000);
		x_msg_count		NUMBER;
		x_msg_data		VARCHAR2(1000);
		CURSOR c_get_child_section(
			c_section_id NUMBER,
			c_master_mini_site_id NUMBER) IS
				SELECT child_section_id
				FROM ibe_dsp_msite_sct_sects
				WHERE mini_site_id = c_master_mini_site_id
				START WITH parent_section_id = c_section_id
					AND mini_site_id = c_master_mini_site_id
				CONNECT BY PRIOR child_section_id = parent_section_id
					AND mini_site_id = c_master_mini_site_id;

 		l_master_minisite_id NUMBER;
		l_root_section_id NUMBER;
		l_section_ids  JTF_NUMBER_TABLE ;
		l_layout_comp_ids JTF_NUMBER_TABLE;
		BEGIN
        	l_section_ids :=  JTF_NUMBER_TABLE();
        	l_layout_comp_ids := JTF_NUMBER_TABLE();
		if  p_enable_trace_flag = 'Y'  then
			G_ENABLE_TRACE := 'Y';
		end if;

		Get_Master_Mini_Site_Id(x_mini_site_id => l_master_minisite_id,
      							x_root_section_id => l_root_section_id);

		FOR child_section IN c_get_child_section(to_number(p_section_id),l_master_minisite_id) LOOP
		IF G_ENABLE_TRACE = 'Y' then
       		fnd_file.put_line(fnd_file.log,'Calling Cascade_Layout_Comp_Mapping ');
       		fnd_file.put_line(fnd_file.log,'section id:'||child_section.child_section_id);
    		END IF;
            Cascade_Layout_Comp_Mapping
				(p_api_version   => 1.0,
				p_init_msg_list => FND_API.G_FALSE,
				p_commit        => FND_API.G_FALSE,
				p_source_section_id => to_number(p_section_id),
				p_target_section_id => child_section.child_section_id,
				x_return_status => x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data,
				x_section_ids => l_section_ids,
				x_layout_comp_ids => l_layout_comp_ids);

			IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			COMMIT;
		END LOOP;
       if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
          retcode := 0;
          errbuf := 'SUCCESS';
       else
            retcode := -1;
            errbuf := x_msg_data;

       end if;

	End Batch_Cascade_Sec_Layout_Map;


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
 x_layout_comp_ids   IN OUT NOCOPY JTF_NUMBER_TABLE)
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'cascade_layout_comp_mapping';
 l_api_version CONSTANT NUMBER := 1.0;
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 l_source_deliverable_id NUMBER;
 l_source_layout_type VARCHAR2(1);
 l_debug                        VARCHAR2(1);
 l_idx NUMBER;
 TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 l_context_ids num_tbl;
 l_i NUMBER;

 -- Specific layout component templates are excluded
 -- for example, subsection, featured section, product section
 -- old process template
 CURSOR c_get_component_mapping(c_section_id NUMBER) IS
   SELECT obj.item_id, obj.context_id, obj.object_type
     FROM ibe_dsp_obj_lgl_ctnt obj,  ibe_dsp_context_b context
    WHERE obj.object_id = c_section_id
      AND obj.object_type = 'S'
      AND obj.context_id = context.context_id
      AND context.context_type_code = 'LAYOUT_COMPONENT'
      AND context.access_name <> 'CENTER';
BEGIN
  SAVEPOINT cascade_layout_comp_mapping;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  IF NOT FND_API.compatible_api_call(l_api_version,
       p_api_version, l_api_name, g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.g_ret_sts_success;

  l_idx := x_section_ids.COUNT;
 IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Get_Sect_Layout_Type');
   IBE_UTIL.debug('section id:'||p_source_section_id);

  END IF;

   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'Calling Get_Sect_Layout_Type ');
   fnd_file.put_line(fnd_file.log,'section id:'||p_source_section_id);

  END IF;
  Get_Sect_Layout_Type(p_section_id => p_source_section_id,
    x_deliverable_id => l_source_deliverable_id,
    x_layout_type => l_source_layout_type);
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('After Calling Get_Sect_Layout_Type');
   IBE_UTIL.debug('layout type:'||l_source_layout_type);

  END IF;
   IF (G_ENABLE_TRACE= 'Y') THEN
   fnd_file.put_line(fnd_file.log,'After Calling Get_Sect_Layout_Type ');
   fnd_file.put_line(fnd_file.log,'layout type:'||l_source_layout_type);

  END IF;

  IF (l_source_layout_type = 'C') THEN
    IF (l_debug = 'Y') THEN
     IBE_UTIL.debug('Delete from ibe_dsp_obj_lgl_cnt_obj for section'||p_target_section_id);
     END IF;
    IF (G_ENABLE_TRACE= 'Y') THEN
      fnd_file.put_line(fnd_file.log,'Delete from ibe_dsp_obj_lgl_cnt_obj for section '||p_target_section_id);
    END IF;
    DELETE FROM ibe_dsp_obj_lgl_ctnt obj
      WHERE obj.object_id = p_target_section_id
	   AND obj.object_type = 'S'
	   AND EXISTS (
		SELECT 1
		  FROM ibe_dsp_context_b context
           WHERE obj.context_id = context.context_id
		   AND context.context_type_code = 'LAYOUT_COMPONENT')
        AND NOT EXISTS(
            SELECT 1
              FROM ibe_dsp_context_b context, ibe_dsp_obj_lgl_ctnt obj1
             WHERE obj1.context_id = obj.context_id
               AND obj1.context_id = context.context_id
               AND obj1.object_id = p_source_section_id
               AND obj1.object_type = 'S'
               AND context.context_type_code = 'LAYOUT_COMPONENT'
               AND context.component_type_code <> 'CENTER')
    RETURNING context_id BULK COLLECT INTO l_context_ids;
    IF (l_context_ids.count > 0) THEN
      FOR l_i IN 1..l_context_ids.COUNT LOOP
	   x_section_ids.extend(1);
	   x_layout_comp_ids.extend(1);
        l_idx := l_idx + 1;
	   x_section_ids(l_idx) := p_target_section_id;
	   x_layout_comp_ids(l_idx) := l_context_ids(l_i);
	 END LOOP;
    END IF;
    -- Component mapping except old processing and center display template
    FOR mapping IN c_get_component_mapping(p_source_section_id) LOOP

    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Layout component mapping  for section'||p_target_section_id);
    END IF;
     IF (G_ENABLE_TRACE= 'Y') THEN
      fnd_file.put_line(fnd_file.log,'Layout component mapping for section '||p_target_section_id);
     END IF;
      UPDATE ibe_dsp_obj_lgl_ctnt
         SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
	        ITEM_ID = mapping.item_id,
	        CREATED_BY = FND_GLOBAL.user_id,
             CREATION_DATE = SYSDATE,
             LAST_UPDATED_BY = FND_GLOBAL.user_id,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
       WHERE object_id = p_target_section_id
         AND object_type = 'S'
         AND context_id = mapping.context_id;
      IF sql%NOTFOUND THEN
        INSERT INTO ibe_dsp_obj_lgl_ctnt(OBJ_LGL_CTNT_ID,
          OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE,
          LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
          SECURITY_GROUP_ID, CONTEXT_ID, OBJECT_TYPE, OBJECT_ID,
          ITEM_ID)
        VALUES(ibe_dsp_obj_lgl_ctnt_s1.NEXTVAL,1,FND_GLOBAL.user_id,SYSDATE,
          FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.login_id, NULL,
          mapping.context_id, 'S', p_target_section_id, mapping.item_id);
      END IF;
	 x_section_ids.extend(1);
	 x_layout_comp_ids.extend(1);
      l_idx := l_idx + 1;
	 x_section_ids(l_idx) := p_target_section_id;
	 x_layout_comp_ids(l_idx) := mapping.context_id;
    END LOOP;
  END IF;
  --
  -- End of main API body.
  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
	if G_ENABLE_TRACE = 'Y' then
		fnd_file.put_line(fnd_file.log,'get G_EXC_ERROR in Cascade_Layout_Comp_Mapping');
	end if;
    ROLLBACK TO cascade_layout_comp_mapping;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   	if G_ENABLE_TRACE = 'Y' then
		fnd_file.put_line(fnd_file.log,'get G_EXC_UNEXPECTED_ERROR in Cascade_Layout_Comp_Mapping');
	end if;
    ROLLBACK TO cascade_layout_comp_mapping;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
  WHEN OTHERS THEN
 	if G_ENABLE_TRACE = 'Y' then
		fnd_file.put_line(fnd_file.log,'get OTHERS Exception in Cascade_Layout_Comp_Mapping');
	end if;

    ROLLBACK TO cascade_layout_comp_mapping;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
END Cascade_Layout_Comp_Mapping;

-- For 11.5.10, Layout Components Map
-- 12/02/03 add x_section_ids and x_layout_comp_ids
--   for layout component mapping cache refresh
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
 x_layout_comp_ids  OUT NOCOPY JTF_NUMBER_TABLE)
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'Update_Hierarchy_Layout_Map';
 l_api_version CONSTANT NUMBER := 1.0;
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_return_status     VARCHAR2(1);

 l_msg_count NUMBER;
 l_msg_data VARCHAR2(4000);

 l_org_deliverable_id NUMBER;
 l_new_deliverable_id NUMBER;
 l_org_layout_type VARCHAR2(1);
 l_new_layout_type VARCHAR2(1);

 l_obj_lgl_ctnt_id NUMBER;

 l_master_minisite_id NUMBER;
 l_root_section_id NUMBER;

 CURSOR c_get_child_section(c_section_id NUMBER,
   c_master_mini_site_id NUMBER) IS
   SELECT child_section_id
     FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = c_master_mini_site_id
    START WITH parent_section_id = c_section_id
      AND mini_site_id = c_master_mini_site_id
    CONNECT BY PRIOR child_section_id = parent_section_id
      AND mini_site_id = c_master_mini_site_id;

 l_debug VARCHAR2(1);
 l_idx NUMBER := 0;
BEGIN
  SAVEPOINT UPDATE_HIERARCHY_LAYOUT_MAP;
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --- Initialize API return status to success
  x_return_status := FND_API.g_ret_sts_success;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('Calling Update_Hierarchy_Layout_Map');
   IBE_UTIL.debug('section id:'||p_section_id);
   IBE_UTIL.debug('layout id:'||p_layout_id);
   FOR l_i IN 1..p_layout_comp_id.COUNT LOOP
     IBE_UTIL.debug('layout component id '||l_i||':'||p_layout_comp_id(l_i));
   END LOOP;
   FOR l_i IN 1..p_layout_temp_id.COUNT LOOP
     IBE_UTIL.debug('layout template id '||l_i||':'||p_layout_temp_id(l_i));
   END LOOP;
   FOR l_i IN 1..p_object_versions.COUNT LOOP
     IBE_UTIL.debug('object version id '||l_i||':'||p_object_versions(l_i));
   END LOOP;
   FOR l_i IN 1..p_actionflags.COUNT LOOP
     IBE_UTIL.debug('action flags '||l_i||':'||p_actionflags(l_i));
   END LOOP;
   IBE_UTIL.debug('cascading flag:'||p_cascading_flag);
  END IF;

  -- Get the original layout of the section
  Get_Sect_Layout_Type(p_section_id => p_section_id,
    x_deliverable_id => l_org_deliverable_id,
    x_layout_type => l_org_layout_type);
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('org deliverable id:'||l_org_deliverable_id);
   IBE_UTIL.debug('org layout type:'||l_org_layout_type);
  END IF;
  l_new_layout_type
    := Get_Layout_Type(p_deliverable_id => p_layout_id);
  IF (p_layout_id = -1) THEN
    l_new_deliverable_id := NULL;
  ELSE
    l_new_deliverable_id := p_layout_id;
  END IF;
  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('new deliverable id:'||l_new_deliverable_id);
    IBE_UTIL.debug('new layout type:'||l_new_layout_type);
  END IF;
  x_section_ids := JTF_NUMBER_TABLE();
  x_layout_comp_ids := JTF_NUMBER_TABLE();
  -- dbms_output.put_line('layout type:'||l_new_layout_type);
  -- New layout is associated with section
  IF (l_new_layout_type = 'C') THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Updating section deliverable id');
    END IF;
    -- x_section_ids := JTF_NUMBER_TABLE();
    -- x_layout_comp_ids := JTF_NUMBER_TABLE();
    -- dbms_output.put_line('Before updating ibe_dsp_sections_b');
    UPDATE ibe_dsp_sections_b
       SET deliverable_id = l_new_deliverable_id,
	      last_update_date = SYSDATE,
		 last_updated_by = FND_GLOBAL.user_id,
		 object_version_number = object_version_number + 1
     WHERE section_id = p_section_id;
    -- dbms_output.put_line('After updating ibe_dsp_sections_b');
    -------------------------------------
    -------------------------------------
    FOR l_i IN 1..p_layout_comp_id.COUNT LOOP
      IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('p_actionflags '||l_i||':'||p_actionflags(l_i));
        IBE_UTIL.debug('p_layout_comp_id '||l_i||':'||p_layout_comp_id(l_i));
        IBE_UTIL.debug('p_layout_temp_id '||l_i||':'||p_layout_temp_id(l_i));
      END IF;
      IF (p_actionflags(l_i) = 'D') THEN
	   x_section_ids.extend(1);
	   x_layout_comp_ids.extend(1);
        l_idx := l_idx + 1;
	   x_section_ids(l_idx) := p_section_id;
	   x_layout_comp_ids(l_idx) := p_layout_comp_id(l_i);
	   DELETE FROM ibe_dsp_obj_lgl_ctnt obj
	     WHERE obj.object_id = p_section_id
		  AND obj.object_type = 'S'
		  AND obj.context_id = p_layout_comp_id(l_i);
	 ELSIF (p_actionflags(l_i) = 'I') AND
	    (p_layout_temp_id(l_i) IS NOT NULL) THEN
	   x_section_ids.extend(1);
	   x_layout_comp_ids.extend(1);
        l_idx := l_idx + 1;
	   x_section_ids(l_idx) := p_section_id;
	   x_layout_comp_ids(l_idx) := p_layout_comp_id(l_i);
	   INSERT INTO ibe_dsp_obj_lgl_ctnt(OBJ_LGL_CTNT_ID,
	     OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE,
		LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
		SECURITY_GROUP_ID, CONTEXT_ID, OBJECT_TYPE, OBJECT_ID,
		ITEM_ID)
        VALUES(ibe_dsp_obj_lgl_ctnt_s1.NEXTVAL, 1, FND_GLOBAL.user_id,
	     SYSDATE, FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.login_id,
		NULL, p_layout_comp_id(l_i), 'S', p_section_id,
		p_layout_temp_id(l_i));
	 ELSIF (p_actionflags(l_i) = 'U') AND
	   (p_layout_temp_id(l_i) IS NOT NULL) THEN
	   x_section_ids.extend(1);
	   x_layout_comp_ids.extend(1);
        l_idx := l_idx + 1;
	   x_section_ids(l_idx) := p_section_id;
	   x_layout_comp_ids(l_idx) := p_layout_comp_id(l_i);
        UPDATE ibe_dsp_obj_lgl_ctnt
	     SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		    ITEM_ID = p_layout_temp_id(l_i),
		    CREATED_BY = FND_GLOBAL.user_id,
		    CREATION_DATE = SYSDATE,
		    LAST_UPDATED_BY = FND_GLOBAL.user_id,
		    LAST_UPDATE_DATE = SYSDATE,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
        WHERE object_id = p_section_id
	     AND object_type = 'S'
		AND context_id = p_layout_comp_id(l_i)
          AND object_version_number = p_object_versions(l_i);
	 END IF;
    END LOOP;
    -- Commit the change to the database
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('after updating base section layout and mapping');
    END IF;
    ---------------------------------------
    IF (p_cascading_flag = 1) AND (l_new_layout_type = 'C') THEN
      IF (l_debug = 'Y') THEN
	   IBE_UTIL.debug('start cascading the layout mapping');
	 END IF;
      Get_Master_Mini_Site_Id(x_mini_site_id => l_master_minisite_id,
	   x_root_section_id => l_root_section_id);
      FOR child_section IN c_get_child_section(p_section_id,
        l_master_minisite_id) LOOP
        UPDATE ibe_dsp_sections_b
           SET deliverable_id = l_new_deliverable_id,
	          last_update_date = SYSDATE,
	 	     last_updated_by = FND_GLOBAL.user_id,
		     object_version_number = object_version_number + 1
         WHERE section_id = child_section.child_section_id;
        -- Get the original layout of the section
	   Cascade_Layout_Comp_Mapping
          (p_api_version => 1.0,
           p_init_msg_list => FND_API.G_FALSE,
           p_commit => FND_API.G_FALSE,
		 p_source_section_id => p_section_id,
		 p_target_section_id => child_section.child_section_id,
           x_return_status => x_return_status,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data,
		 x_section_ids => x_section_ids,
		 x_layout_comp_ids => x_layout_comp_ids);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	     RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	   COMMIT;
      END LOOP;
    END IF;
  ELSIF (l_new_layout_type = 'F') THEN
    IF (l_org_layout_type = 'C') THEN
      -- No cascading for standard layout
	 l_org_deliverable_id := null;
	 -- Set the section deliverable_id to old processing page
      UPDATE ibe_dsp_sections_b
         SET deliverable_id = l_org_deliverable_id
       WHERE section_id = p_section_id;
    END IF;
  END IF;
  IF (l_debug = 'Y') THEN
   IBE_UTIL.debug('After Calling Update_Hierarchy_Layout_Map');
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
    ROLLBACK TO UPDATE_HIERARCHY_LAYOUT_MAP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_HIERARCHY_LAYOUT_MAP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_HIERARCHY_LAYOUT_MAP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
END Update_Hierarchy_Layout_Map;

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
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'Update_Section_Dlv_Ctx';
 l_api_version CONSTANT NUMBER := 1.0;
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_return_status     VARCHAR2(1);

 l_msg_count NUMBER;
 l_msg_data VARCHAR2(4000);

 l_org_deliverable_id NUMBER;
 l_org_layout_type VARCHAR2(1);
 l_obj_lgl_ctnt_id NUMBER;
 l_object_version_number NUMBER;
 l_center_main_id NUMBER;
 l_display_context_id NUMBER;

 l_lgl_ctnt_rec IBE_LogicalContent_GRP.OBJ_LGL_CTNT_REC_TYPE;
 l_lgl_ctnt_tbl IBE_LogicalContent_GRP.OBJ_LGL_CTNT_TBL_TYPE;

 l_deliverable_id NUMBER;

 CURSOR c_get_center_main_csr IS
   SELECT ctx.context_id
     FROM ibe_dsp_context_b ctx
    WHERE ctx.access_name = 'CENTER'
      AND ctx.context_type_code = 'LAYOUT_COMPONENT'
	 AND ctx.component_type_code = 'SECTION';

 CURSOR c_get_center_map_csr(c_section_id NUMBER, c_context_id NUMBER) IS
   SELECT map.obj_lgl_ctnt_id, map.object_version_number
     FROM ibe_dsp_obj_lgl_ctnt map
    WHERE map.object_id = c_section_id
      AND map.object_type = 'S'
	 AND map.context_id = c_context_id;

 l_debug VARCHAR2(1);
BEGIN
  SAVEPOINT UPDATE_SECTION_DLV_CTX;
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --- Initialize API return status to success
  x_return_status := FND_API.g_ret_sts_success;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Calling Update_Section_Dlv_Ctx starts');
    IBE_UTIL.debug('Parameters:');
    IBE_UTIL.debug('section id:'||p_section_id);
    IBE_UTIL.debug('deliverable id:'||p_deliverable_id);
    IBE_UTIL.debug('display context id:'||p_display_context_id);
    IBE_UTIL.debug('object version number:'|| p_object_version_number);
    IBE_UTIL.debug('save ds:'|| p_saveds_flag);
  END IF;
  -- Get the original layout of the section
  Get_Sect_Layout_Type(p_section_id => p_section_id,
    x_deliverable_id => l_org_deliverable_id,
    x_layout_type => l_org_layout_type);
  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('after calling Get_Sect_Layout_Type');
    IBE_UTIL.debug('deliverable id:'||l_org_deliverable_id);
    IBE_UTIL.debug('layout type:'||l_org_layout_type);
  END IF;
  l_deliverable_id := p_deliverable_id;
  IF (l_deliverable_id = -1) THEN
    l_deliverable_id := NULL;
  END IF;

  IF (l_org_layout_type = 'F') THEN
    IF (p_saveds_flag = 1) THEN
	 l_display_context_id := p_display_context_id;
      IF (p_display_context_id = -1) THEN
	   l_display_context_id := NULL;
      END IF;
      IF (l_debug = 'Y') THEN
	   IBE_UTIL.debug('Before calling IBE_DSP_SECTION_GRP.Update_Section');
	 END IF;
      IBE_DSP_SECTION_GRP.Update_Section
	   ( p_api_version => 1.0,
	     p_init_msg_list => FND_API.G_FALSE,
		p_commit => FND_API.G_FALSE,
		p_section_id => p_section_id,
		p_object_version_number => p_object_version_number,
		p_deliverable_id => l_deliverable_id,
		p_display_context_id => l_display_context_id,
          x_return_status => x_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data);
    ELSE
      IBE_DSP_SECTION_GRP.Update_Section
	   ( p_api_version => 1.0,
	     p_init_msg_list => FND_API.G_FALSE,
		p_commit => FND_API.G_FALSE,
		p_section_id => p_section_id,
		p_object_version_number => p_object_version_number,
		p_deliverable_id => l_deliverable_id,
          x_return_status => x_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data);
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSIF (l_org_layout_type = 'C') THEN
    OPEN c_get_center_main_csr;
    FETCH c_get_center_main_csr INTO l_center_main_id;
    CLOSE c_get_center_main_csr;
    OPEN c_get_center_map_csr(p_section_id, l_center_main_id);
    FETCH c_get_center_map_csr INTO l_obj_lgl_ctnt_id, l_object_version_number;
    IF (c_get_center_map_csr%FOUND) THEN
      l_lgl_ctnt_rec.OBJ_lgl_ctnt_id := l_obj_lgl_ctnt_id;
      l_lgl_ctnt_rec.Object_Version_Number := l_object_version_number;
    ELSE
      l_lgl_ctnt_rec.OBJ_lgl_ctnt_id := NULL;
      l_lgl_ctnt_rec.Object_Version_Number := 1;
    END IF;
    CLOSE c_get_center_map_csr;
    l_lgl_ctnt_rec.Object_id := p_section_id;
    l_lgl_ctnt_rec.Context_id := l_center_main_id;
    l_lgl_ctnt_rec.deliverable_id := l_deliverable_id;
    l_lgl_ctnt_rec.obj_lgl_ctnt_delete := FND_API.G_FALSE;
    l_lgl_ctnt_tbl(1) := l_lgl_ctnt_rec;
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('section id:'||l_lgl_ctnt_rec.Object_id);
    END IF;
    IBE_LogicalContent_GRP.save_delete_lgl_ctnt(
      p_api_version => 1.0,
	 x_return_status => x_return_status,
      x_msg_count => l_msg_count,
	 x_msg_data => l_msg_data,
	 p_object_type_code => 'S',
	 p_lgl_ctnt_tbl => l_lgl_ctnt_tbl);
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Display Style process
    IF (p_saveds_flag = 1) THEN
	 l_display_context_id := p_display_context_id;
      IF (p_display_context_id = -1) THEN
	   l_display_context_id := NULL;
	 END IF;
      IBE_DSP_SECTION_GRP.Update_Section
	   ( p_api_version => 1.0,
	     p_init_msg_list => FND_API.G_FALSE,
		p_commit => FND_API.G_FALSE,
		p_section_id => p_section_id,
		p_object_version_number => p_object_version_number,
		p_display_context_id => l_display_context_id,
          x_return_status => x_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data);
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   IF (l_debug = 'Y') THEN
	     FOR i in 1..l_msg_count loop
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
		  IBE_UTIL.debug(l_msg_data);
	     END LOOP;
	   END IF;
        RAISE FND_API.G_EXC_ERROR;
	 ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	   IF (l_debug = 'Y') THEN
	     FOR i in 1..l_msg_count loop
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
		  IBE_UTIL.debug(l_msg_data);
	     END LOOP;
	   END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  --
  -- End of main API body.
  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_SECTION_DLV_CTX;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_SECTION_DLV_CTX;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_SECTION_DLV_CTX;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => 'F');
END Update_Section_Dlv_Ctx;

/***************************************/
/*  overloaded package for the public API
/*******************************************/

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
   x_section_item_out_tbl            	OUT NOCOPY IBE_DSP_HIERARCHY_SETUP_PUB.SECTION_ITEM_OUT_TBL_TYPE)
  IS

  l_api_name                CONSTANT VARCHAR2(30) :=
  'Associate_Items_To_Section';
  l_api_version             CONSTANT NUMBER   := 1.0;
  l_section_id_tbl              JTF_NUMBER_TABLE;
  l_inventory_item_id_tbl       JTF_NUMBER_TABLE;
  l_organization_id_tbl         JTF_NUMBER_TABLE;
  l_start_date_active_tbl       JTF_DATE_TABLE;
  l_end_date_active_tbl         JTF_DATE_TABLE;
  l_sort_order_tbl              JTF_NUMBER_TABLE;
  l_association_reason_code_tbl JTF_VARCHAR2_TABLE_300;
  l_counter NUMBER;
  l_section_item_id_tbl         JTF_NUMBER_TABLE;
  l_overall_return_status        VARCHAR2(1);
  l_duplicate_association_status VARCHAR2(1);
  l_debug                        VARCHAR2(1);
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  ASSOCIATE_ITEMS_TO_SECTION_PVT;

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
    l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

    IF (l_debug = 'Y') THEN
            IBE_UTIL.debug('start of Associate_Items_To_Section');
    END If;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_duplicate_association_status := FND_API.G_RET_STS_SUCCESS;
    l_overall_return_status :=  FND_API.G_RET_STS_SUCCESS;

   -- call to IBE_DSP_HIERARCHY_SETUP_PVT.Associate_Items_To_Section API
   -- requires passing the parameters as JTF_xxxx_TABLE

   -- initialize the jtf number table variables
     l_inventory_item_id_tbl:=JTF_NUMBER_TABLE();
     l_organization_id_tbl:=JTF_NUMBER_TABLE();
     l_start_date_active_tbl:=JTF_DATE_TABLE();
     l_end_date_active_tbl:=JTF_DATE_TABLE();
     l_sort_order_tbl:=JTF_NUMBER_TABLE();
     l_association_reason_code_tbl:=JTF_VARCHAR2_TABLE_300();

     l_inventory_item_id_tbl.extend();
     l_organization_id_tbl.extend();
     l_start_date_active_tbl.extend();
     l_end_date_active_tbl.extend();
     l_sort_order_tbl.extend();
     l_association_reason_code_tbl.extend();

      -- convert to JTF NUMBER TABLE
     l_counter:=1;
     FOR l_counter in 1..p_section_item_tbl.count LOOP
        l_inventory_item_id_tbl(1):=p_section_item_tbl(l_counter).inventory_item_id;
        l_organization_id_tbl(1):=p_section_item_tbl(l_counter).organization_id;
        l_start_date_active_tbl(1):=p_section_item_tbl(l_counter).start_date_active;
        l_end_date_active_tbl(1):=p_section_item_tbl(l_counter).end_date_active;
        l_sort_order_tbl(1):=p_section_item_tbl(l_counter).sort_order;
        l_association_reason_code_tbl(1):=p_section_item_tbl(l_counter).association_reason_code;
        IF (l_debug = 'Y') THEN
            IBE_UTIL.debug('Parameters:l_counter='||l_counter||'inventory_item_id='||l_inventory_item_id_tbl(1)||
            'organization_id='||l_organization_id_tbl(1)||'start_date_active='||l_start_date_active_tbl(1)||
            'end_date_active='||l_end_date_active_tbl(1)||'sort_order='||l_sort_order_tbl(1)||
            'association_reason_code='||l_association_reason_code_tbl(1));
        END IF;
        -- Call private API to associate the items to the section
        IBE_DSP_HIERARCHY_SETUP_PVT.Associate_Items_To_Section(
        p_api_version                    => p_api_version,
        p_init_msg_list                  => p_init_msg_list,
        p_commit                         => p_commit,
        p_validation_level               => p_validation_level,
        p_section_id                     => p_section_id,
        p_inventory_item_ids             => l_inventory_item_id_tbl,
        p_organization_ids               => l_organization_id_tbl,
        p_start_date_actives             => l_start_date_active_tbl,
        p_end_date_actives               => l_end_date_active_tbl,
        p_sort_orders                    => l_sort_order_tbl,
        p_association_reason_codes       => l_association_reason_code_tbl,
        x_section_item_ids               => l_section_item_id_tbl,
        x_duplicate_association_status   => l_duplicate_association_status,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );
        --- get the individual section item row association status
        x_section_item_out_tbl(l_counter).x_return_status   :=x_return_status;
        x_section_item_out_tbl(l_counter).section_item_id   :=l_section_item_id_tbl(1);
        x_section_item_out_tbl(l_counter).inventory_item_id :=l_inventory_item_id_tbl(1);
        x_section_item_out_tbl(l_counter).organization_id   :=l_organization_id_tbl(1);
        if(l_debug='Y') then
              IBE_UTIL.debug('Internal API return_status='||x_return_status);
        end if;
         -- derive the API overall status
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)then
              IF (l_overall_return_status=FND_API.G_RET_STS_SUCCESS) then
                    l_overall_return_status:= FND_API.G_RET_STS_ERROR;
              END IF;
              IF (l_debug = 'Y') THEN
	            FOR i in 1..x_msg_count loop
	              IBE_UTIL.debug(FND_MSG_PUB.get(i,FND_API.G_FALSE));
	            END LOOP;
              END IF;
        END IF;

  END LOOP;

  if(l_debug='Y') then
     IBE_UTIL.debug('API overall status='||l_overall_return_status);
  end if;
  -- set the x_return status to the API overall status
  x_return_status:= l_overall_return_status;
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
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PVT;
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

 END Associate_Items_To_Section;

END IBE_DSP_HIERARCHY_SETUP_PVT;


/
