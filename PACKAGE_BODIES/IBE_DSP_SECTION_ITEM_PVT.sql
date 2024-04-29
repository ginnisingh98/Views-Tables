--------------------------------------------------------
--  DDL for Package Body IBE_DSP_SECTION_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DSP_SECTION_ITEM_PVT" AS
/* $Header: IBEVCISB.pls 120.0 2005/05/30 02:31:07 appldev noship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBE_DSP_SECTION_ITEM_PVT
  --
  -- PURPOSE
  --   Private API for saving, retrieving and updating section items
  --
  -- NOTES
  --   This is a pulicly accessible package.  It should be used by all
  --   sources for saving, retrieving and updating section items

  -- HISTORY
  --   11/28/99           VPALAIYA      Created
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) and Debug (Bug # 2691710) Changes.
  --   12/19/02           SCHAK         Modified for reverting Debug (IBEUtil) Changes.
  --   12/21/02           SCHAK         Modified for NOCOPY (Bug # 2691704)) Changes and adding exceptions.
  -- **********************************************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_DSP_SECTION_ITEM_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVCISB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    TABLE HANDLERS
--      1. insert_row
--      2. update_row
--      3. delete_row
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- insert row into section-items
-- ****************************************************************************

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
  )
IS
  CURSOR c IS SELECT rowid FROM ibe_dsp_section_items
    WHERE section_item_id = x_section_item_id;
  CURSOR c2 IS SELECT ibe_dsp_section_items_s1.nextval FROM dual;

BEGIN

  -- Primary key validation check
  x_section_item_id := p_section_item_id;
  IF ((x_section_item_id IS NULL) OR
      (x_section_item_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_section_item_id;
    CLOSE c2;
  END IF;

  -- insert base
  INSERT INTO ibe_dsp_section_items
    (
    section_item_id,
    object_version_number,
    section_id,
    inventory_item_id,
    organization_id,
    start_date_active,
    end_date_active,
    usage_name,
    sort_order,
    association_reason_code,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    VALUES
    (
    x_section_item_id,
    p_object_version_number,
    p_section_id,
    p_inventory_item_id,
    p_organization_id,
    p_start_date_active,
    decode(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active),
    decode(p_usage_name, FND_API.G_MISS_CHAR, NULL, p_usage_name),
    decode(p_sort_order, FND_API.G_MISS_NUM, NULL, p_sort_order),
    decode(p_association_reason_code, FND_API.G_MISS_CHAR,
           NULL, p_association_reason_code),
    decode(p_creation_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
           p_creation_date),
    decode(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
           p_last_update_date),
    decode(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    decode(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login)
    );

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END insert_row;

-- ****************************************************************************
-- update row
-- ****************************************************************************

PROCEDURE update_row
  (
  p_section_item_id                     IN NUMBER,
  p_object_version_number               IN NUMBER   := FND_API.G_MISS_NUM,
  p_start_date_active                   IN DATE,
  p_end_date_active                     IN DATE,
  p_usage_name 				IN VARCHAR2,
  p_sort_order                          IN NUMBER,
  p_association_reason_code             IN VARCHAR2,
  p_last_update_date                    IN DATE,
  p_last_updated_by                     IN NUMBER,
  p_last_update_login                   IN NUMBER
  )
IS
BEGIN

  -- update base
  UPDATE ibe_dsp_section_items SET
    object_version_number = object_version_number + 1,
    sort_order = decode(p_sort_order, FND_API.G_MISS_NUM,
                        sort_order, p_sort_order),
    association_reason_code =
      decode(p_association_reason_code, FND_API.G_MISS_CHAR,
             association_reason_code, p_association_reason_code),
    start_date_active = decode(p_start_date_active, FND_API.G_MISS_DATE,
                               start_date_active, p_start_date_active),
    end_date_active = decode(p_end_date_active, FND_API.G_MISS_DATE,
                             end_date_active, p_end_date_active),
    usage_name = decode(p_usage_name, FND_API.G_MISS_CHAR, usage_name, p_usage_name),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE,
                              sysdate, NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                               FND_GLOBAL.login_id, NULL,
                               FND_GLOBAL.login_id, p_last_update_login)
    WHERE section_item_id = p_section_item_id
      AND object_version_number = decode(p_object_version_number,
                                         FND_API.G_MISS_NUM,
                                         object_version_number,
                                         p_object_version_number);

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END update_row;


-- ****************************************************************************
-- delete row
-- ****************************************************************************

PROCEDURE delete_row
  (
   p_section_item_id IN NUMBER
  )
IS
BEGIN

  DELETE FROM ibe_dsp_section_items
    WHERE section_item_id = p_section_item_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

-- ****************************************************************************
--*****************************************************************************
--
--APIs
--
-- 1. Create_Section_Item
-- 2. Update_Section_Item
-- 3. Delete_Section_Item
-- 4. Check_Duplicate_Entry
--
--*****************************************************************************
--*****************************************************************************


--*****************************************************************************
-- PROCEDURE Check_Duplicate_Entry()
--*****************************************************************************

--
-- x_return_status = FND_API.G_RET_STS_SUCCESS, if the section is duplicate
-- x_return_status = FND_API.G_RET_STS_ERROR, if the section is not duplicate
--
--
PROCEDURE Check_Duplicate_Entry
  (
   p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE,
   p_section_id                   IN NUMBER,
   p_inventory_item_id            IN NUMBER,
   p_organization_id              IN NUMBER,
   x_return_status                OUT NOCOPY  VARCHAR2,
   x_msg_count                    OUT NOCOPY  NUMBER,
   x_msg_data                     OUT NOCOPY  VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Check_Duplicate_Entry';
  l_api_version           CONSTANT NUMBER       := 1.0;

  l_tmp_section_item_id   NUMBER;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- Check duplicate entry
  BEGIN

      SELECT section_item_id INTO l_tmp_section_item_id
        FROM  ibe_dsp_section_items
        WHERE section_id = p_section_id
          AND inventory_item_id = p_inventory_item_id
          AND organization_id = p_organization_id;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
       -- not duplicate
       -- do nothing
       NULL;

     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END;

  IF (l_tmp_section_item_id IS NOT NULL) THEN
    -- found duplicate
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS; -- found duplicate
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

END Check_Duplicate_Entry;


--*****************************************************************************
-- PROCEDURE Validate_Create()
--*****************************************************************************
-- IF  x_return_status := FND_API.G_RET_STS_ERROR, then invalid
-- IF  x_return_status := FND_API.G_RET_STS_SUCCESS, then valid

PROCEDURE Validate_Create
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   p_inventory_item_id              IN NUMBER,
   p_organization_id                IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_sort_order                     IN NUMBER,
   p_association_reason_code        IN VARCHAR2,
   x_return_status                  OUT NOCOPY  VARCHAR2,
   x_msg_count                      OUT NOCOPY  NUMBER,
   x_msg_data                       OUT NOCOPY  VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Validate_Create';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  l_section_item_id         NUMBER;
  l_section_id              NUMBER;
  l_inventory_item_id       NUMBER;
  l_organization_id         NUMBER;
  l_return_status           VARCHAR2(1);
  l_tmp_id                  NUMBER;
/*
  CURSOR c1(l_c_section_id IN NUMBER)
  IS SELECT mini_site_section_section_id FROM ibe_dsp_msite_sct_sects
    WHERE parent_section_id = l_c_section_id
    AND EXISTS (SELECT msite_id FROM ibe_msites_b
    WHERE msite_id = mini_site_id
    AND master_msite_flag = 'Y');
*/
  l_master_mini_site_id NUMBER;
  l_master_root_section_id NUMBER;
  CURSOR c1(l_c_section_id IN NUMBER, l_c_minisite_id IN NUMBER)
  IS SELECT mini_site_section_section_id FROM ibe_dsp_msite_sct_sects
    WHERE parent_section_id = l_c_section_id
	 AND mini_site_id = l_c_minisite_id;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Check null values for required fields
  --

  -- section id
  IF ((p_section_id IS NULL) OR
      (p_section_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_SCT_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- inventory item id
  IF ((p_inventory_item_id IS NULL) OR
      (p_inventory_item_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_INV_ITEM_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- organization id
  IF ((p_organization_id IS NULL) OR
      (p_organization_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_INV_ORG_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- start_date_active
  IF ((p_start_date_active IS NULL) OR
      (p_start_date_active = FND_API.G_MISS_DATE))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_START_DATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- non-null field validation
  --

  -- sort order
  IF ((p_sort_order IS NOT NULL) AND
      (p_sort_order <> FND_API.G_MISS_NUM))
  THEN
    IF(p_sort_order < 0) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_SCT_SORT_ORDER');
      FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --
  -- Foreign key integrity constraint check
  --

  -- section id
  -- note that section id cannot be null due to previous checks
  BEGIN
    SELECT section_id INTO l_section_id FROM ibe_dsp_sections_b
      WHERE section_id = p_section_id;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ID');
       FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_SCT_ID');
       FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  -- inventory item id and organization id
  BEGIN

    SELECT inventory_item_id INTO l_inventory_item_id
      FROM mtl_system_items
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

    SELECT organization_id INTO l_organization_id
      FROM mtl_system_items
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_INV_ITEM_ID');
       FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
       FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_GET_INV_ITEM_ID');
       FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
       FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  -- Validate if the entry is duplicate
  Check_Duplicate_Entry
    (
    p_init_msg_list                 => FND_API.G_FALSE,
    p_section_id                    => p_section_id,
    p_inventory_item_id             => p_inventory_item_id,
    p_organization_id               => p_organization_id,
    x_return_status                 => l_return_status,
    x_msg_count                     => l_msg_count,
    x_msg_data                      => l_msg_data);

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_DUPLICATE_ENTRY');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- duplicate entry
  END IF;

  --
  -- Check if the p_section_id doesn't have any child as sections
  -- Cannot create items for a section which has child sections
  --
  -- Performance bug fix 2854734
  IBE_DSP_HIERARCHY_SETUP_PVT.Get_Master_Mini_Site_Id(
    x_mini_site_id => l_master_mini_site_id,
    x_root_section_id => l_master_root_section_id);
--  OPEN c1(p_section_id);
  OPEN c1(p_section_id, l_master_mini_site_id);
  FETCH c1 INTO l_tmp_id;
  IF (c1%FOUND) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_HAS_CHILD_SCT');
    FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
    FND_MSG_PUB.Add;
    CLOSE c1;
    RAISE FND_API.G_EXC_ERROR;
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

END Validate_Create;


--*****************************************************************************
-- PROCEDURE Validate_Update()
--*****************************************************************************
-- IF  x_return_status := FND_API.G_RET_STS_ERROR, then invalid
-- IF  x_return_status := FND_API.G_RET_STS_SUCCESS, then valid

PROCEDURE Validate_Update
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_item_id                IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_sort_order                     IN NUMBER,
   p_association_reason_code        IN VARCHAR2,
   x_return_status                  OUT NOCOPY  VARCHAR2,
   x_msg_count                      OUT NOCOPY  NUMBER,
   x_msg_data                       OUT NOCOPY  VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Update';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_section_item_id       NUMBER;
  l_section_id            NUMBER;
  l_inventory_item_id     NUMBER;
  l_organization_id       NUMBER;
  l_return_status         VARCHAR2(1);

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Check null values for required fields
  --

  -- section_item_id
  IF (p_section_item_id IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_PRIMARY_KEY');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- start_date_active
  IF (p_start_date_active IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_START_DATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- non-null field validation
  --

  -- sort order
  IF ((p_sort_order IS NOT NULL) AND
      (p_sort_order <> FND_API.G_MISS_NUM))
  THEN
    IF(p_sort_order < 0) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_SCT_SORT_ORDER');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
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

END Validate_Update;


-- ****************************************************************************
--*****************************************************************************

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
   x_section_item_id                OUT NOCOPY  NUMBER,
   x_return_status                  OUT NOCOPY  VARCHAR2,
   x_msg_count                      OUT NOCOPY  NUMBER,
   x_msg_data                       OUT NOCOPY  VARCHAR2
  )
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Section_Item';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1);

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  CREATE_SECTION_ITEM_PVT;

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
  -- 1. Validate
  -- 2. Insert row
  --

  --
  -- 1. Validate
  --
  Validate_Create
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_section_id                     => p_section_id,
    p_inventory_item_id              => p_inventory_item_id,
    p_organization_id                => p_organization_id,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_sort_order                     => p_sort_order,
    p_association_reason_code        => p_association_reason_code,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SI_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  --
  -- 2. Insert row
  --
  BEGIN
    insert_row
      (
      FND_API.G_MISS_NUM,
      l_object_version_number,
      p_section_id,
      p_inventory_item_id,
      p_organization_id,
      p_start_date_active,
      p_end_date_active,
      null,
      p_sort_order,
      p_association_reason_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id,
      l_rowid,
      x_section_item_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SI_INSERT_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SI_INSERT_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  --
  -- Call api which makes changes in relationship tables
  --
  IBE_PROD_RELATION_PVT.Item_Section_Inserted
    (
    p_section_id        => p_section_id,
    p_inventory_item_id => p_inventory_item_id,
    p_organization_id   => p_organization_id  --Bug 2922902
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
     ROLLBACK TO CREATE_SECTION_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_SECTION_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_SECTION_ITEM_PVT;

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

END Create_Section_Item;

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
   x_return_status                  OUT NOCOPY  VARCHAR2,
   x_msg_count                      OUT NOCOPY  NUMBER,
   x_msg_data                       OUT NOCOPY  VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Section_Item';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_section_item_id   NUMBER;
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_SECTION_ITEM_PVT;

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
  -- 1. Check if either section_item_id or combination of
  --    section_id, inventory_item_id and organization_id is specified
  -- 2. Update row
  --

  -- 1. Check if either section_item_id or combination of
  --    section_id, inventory_item_id and organization_id is specified
  IF ((p_section_item_id IS NOT NULL) AND
      (p_section_item_id <> FND_API.G_MISS_NUM))
  THEN
    -- section_item_id specified, continue
    l_section_item_id := p_section_item_id;
  ELSIF ((p_section_id IS NOT NULL)                  AND
         (p_section_id <> FND_API.G_MISS_NUM)        AND
         (p_inventory_item_id IS NOT NULL)           AND
         (p_inventory_item_id <> FND_API.G_MISS_NUM) AND
         (p_organization_id IS NOT NULL)             AND
         (p_organization_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of section_id, inventory_item_id and organization_id
    -- is specified, then query for section_item_id
    BEGIN

        SELECT section_item_id INTO l_section_item_id
          FROM ibe_dsp_section_items
          WHERE section_id = p_section_id
            AND inventory_item_id = p_inventory_item_id
            AND organization_id = p_organization_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_SI_ID');
         FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
         FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
         FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;

         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_SI_ID');
         FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
         FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
         FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

  ELSE
    -- neither section_item_id nor combination of
    -- section_id, inventory_item_id and organization_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_SI_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- 1. Validate the input data
  --
  Validate_Update
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_section_item_id                => l_section_item_id,
    p_object_version_number          => p_object_version_number,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_sort_order                     => p_sort_order,
    p_association_reason_code        => p_association_reason_code,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SI_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  -- 2. update row
  BEGIN
    update_row
      (
      l_section_item_id,
      p_object_version_number,
      p_start_date_active,
      p_end_date_active,
      p_usage_name,
      p_sort_order,
      p_association_reason_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SI_UPDATE_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SI_UPDATE_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

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
     ROLLBACK TO UPDATE_SECTION_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_SECTION_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_SECTION_ITEM_PVT;

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

END Update_Section_Item;

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
   x_return_status                OUT NOCOPY  VARCHAR2,
   x_msg_count                    OUT NOCOPY  NUMBER,
   x_msg_data                     OUT NOCOPY  VARCHAR2
  )
IS


  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_Section_Item';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_section_item_id   NUMBER;
  l_section_id        NUMBER;
  l_inventory_item_id NUMBER;
  l_organization_id   NUMBER;

  CURSOR c1(l_c_section_item_id IN NUMBER)
  IS SELECT mini_site_section_item_id FROM ibe_dsp_msite_sct_items
    WHERE section_item_id = l_c_section_item_id;

  CURSOR c2(l_c_section_item_id IN NUMBER)
  IS SELECT section_id, inventory_item_id, organization_id
    FROM ibe_dsp_section_items
    WHERE section_item_id = l_c_section_item_id;

BEGIN
  -- Call savepoint only when not called from trigger
  IF (p_call_from_trigger = FALSE) THEN
    -- Standard Start of API savepoint
    SAVEPOINT  DELETE_SECTION_ITEM_PVT;
  END IF;

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

  -- CALL FLOW
  -- 1. If section_item_id specified, delete all references for it
  -- 2. If combination of section_id, inventory_item_id and organization_id
  --    is specified, then query for section_item_id and delete
  --    all references

  -- 1. If section_item_id specified, delete all references for it
  IF ((p_section_item_id IS NOT NULL) AND
      (p_section_item_id <> FND_API.G_MISS_NUM))
  THEN
    -- section_item_id specified, continue
    l_section_item_id := p_section_item_id;

    OPEN c2(l_section_item_id);
    FETCH c2 INTO l_section_id, l_inventory_item_id, l_organization_id;
    IF (c2%NOTFOUND) THEN
      CLOSE c2;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_SI_ID');
      FND_MESSAGE.Set_Token('SECTION_ITEM_ID', l_section_item_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c2;

  ELSIF ((p_section_id IS NOT NULL)                  AND
         (p_section_id <> FND_API.G_MISS_NUM)        AND
         (p_inventory_item_id IS NOT NULL)           AND
         (p_inventory_item_id <> FND_API.G_MISS_NUM) AND
         (p_organization_id IS NOT NULL)             AND
         (p_organization_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of section_id, inventory_item_id and organization_id
    -- is specified, then query for section_item_id
    l_section_id := p_section_id;
    l_inventory_item_id := p_inventory_item_id;
    l_organization_id := p_organization_id;

    BEGIN

      SELECT section_item_id INTO l_section_item_id
        FROM ibe_dsp_section_items
        WHERE section_id = p_section_id
        AND inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_SI_ID');
         FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
         FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
         FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;

         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_SI_ID');
         FND_MESSAGE.Set_Token('SECTION_ID', p_section_id);
         FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_inventory_item_id);
         FND_MESSAGE.Set_Token('ORGANIZATION_ID', p_organization_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

  ELSE
    -- neither section_item_id nor combination of
    -- section_id, inventory_item_id and organization_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_NO_SI_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- delete from ibe_dsp_msite_sct_items table
  FOR r1 IN c1(l_section_item_id) LOOP
    IBE_DSP_MSITE_SCT_ITEM_PVT.Delete_MSite_Section_Item
      (
      p_api_version                  => p_api_version,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      p_validation_level             => p_validation_level,
      p_call_from_trigger            => p_call_from_trigger,
      p_mini_site_section_item_id    => r1.mini_site_section_item_id,
      p_mini_site_id                 => FND_API.G_MISS_NUM,
      p_section_item_id              => FND_API.G_MISS_NUM,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

  -- delete from relationship tables
  IBE_PROD_RELATION_PVT.Item_Section_Deleted
    (
    p_section_id        => l_section_id,
    p_inventory_item_id => l_inventory_item_id ,
    p_organization_id   => l_organization_id  --Bug 2922902
    );

  -- delete row
  delete_row(l_section_item_id);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF (p_call_from_trigger = FALSE) THEN
       ROLLBACK TO DELETE_SECTION_ITEM_PVT;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (p_call_from_trigger = FALSE) THEN
       ROLLBACK TO DELETE_SECTION_ITEM_PVT;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     IF (p_call_from_trigger = FALSE) THEN
       ROLLBACK TO DELETE_SECTION_ITEM_PVT;
     END IF;

     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_Section_Item;

--
-- delete section items for input of inventory item id and organization id
--
PROCEDURE Delete_Section_Items_For_Item
  (
   p_inventory_item_id            IN NUMBER      := FND_API.G_MISS_NUM,
   p_organization_id              IN NUMBER      := FND_API.G_MISS_NUM
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  :='Delete_Section_Items_For_Item';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);

  CURSOR c1(l_c_inventory_item_id IN NUMBER, l_c_organization_id IN NUMBER) IS
    SELECT section_item_id FROM ibe_dsp_section_items
      WHERE inventory_item_id = l_c_inventory_item_id AND
            organization_id = l_c_organization_id;
BEGIN

  FOR r1 IN c1(p_inventory_item_id, p_organization_id) LOOP

    Delete_Section_Item
      (
      p_api_version                  => l_api_version,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
      p_call_from_trigger            => TRUE,
      p_section_item_id              => r1.section_item_id,
      p_section_id                   => FND_API.G_MISS_NUM,
      p_inventory_item_id            => FND_API.G_MISS_NUM,
      p_organization_id              => FND_API.G_MISS_NUM,
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data
      );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  END LOOP;

END Delete_Section_Items_For_Item;

--
-- to update and delete multiple entries. Delete the entries whose flag is
-- set to "Y"
--
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
   x_return_status                  OUT NOCOPY  VARCHAR2,
   x_msg_count                      OUT NOCOPY  NUMBER,
   x_msg_data                       OUT NOCOPY  VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Delete_Sct_Itms';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_section_item_id   NUMBER;
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_DELETE_SCT_ITMS_PVT;

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
  FOR i IN 1..p_section_item_ids.COUNT LOOP

    IF (p_delete_flags(i) = 'Y') THEN

      Delete_Section_Item
        (
        p_api_version                  => p_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
        p_section_item_id              => p_section_item_ids(i),
        p_section_id                   => FND_API.G_MISS_NUM,
        p_inventory_item_id            => FND_API.G_MISS_NUM,
        p_organization_id              => FND_API.G_MISS_NUM,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data
        );


      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE
      Update_Section_Item
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_section_item_id                => p_section_item_ids(i),
        p_object_version_number          => p_object_version_numbers(i),
        p_section_id                     => FND_API.G_MISS_NUM,
        p_inventory_item_id              => FND_API.G_MISS_NUM,
        p_organization_id                => FND_API.G_MISS_NUM,
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_usage_name			 => p_usage_names(i),
        p_sort_order                     => p_sort_orders(i),
        p_association_reason_code        => p_association_reason_codes(i),
        x_return_status                  => l_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
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
     ROLLBACK TO UPDATE_DELETE_SCT_ITMS_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_DELETE_SCT_ITMS_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_DELETE_SCT_ITMS_PVT;

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

END Update_Delete_Sct_Itms;

END IBE_DSP_SECTION_ITEM_PVT;

/
