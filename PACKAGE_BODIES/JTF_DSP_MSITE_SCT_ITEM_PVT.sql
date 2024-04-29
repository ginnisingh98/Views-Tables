--------------------------------------------------------
--  DDL for Package Body JTF_DSP_MSITE_SCT_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DSP_MSITE_SCT_ITEM_PVT" AS
/* $Header: JTFVCMIB.pls 115.14 2004/07/09 18:51:29 applrt ship $ */


  --
  --
  -- Start of Comments
  --
  -- NAME
  --   JTF_DSP_MSITE_SCT_ITEM_PVT
  --
  -- PURPOSE
  --   Private API for saving, retrieving and updating mini site
  --   section items.
  --
  -- NOTES
  --   This is a pulicly accessible package.  It should be used by all
  --   sources for saving, retrieving and updating mini site section
  --   items

  -- HISTORY
  --   11/28/99           VPALAIYA         Created
  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'JTF_DSP_MSITE_SCT_ITEM_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'JTFVCMIB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    TABLE HANDLERS
--      1. insert_row
--      2. update_row
--      3. delete_row
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- insert row into mini site section-item
-- ****************************************************************************

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
  )
IS

  CURSOR c IS SELECT rowid FROM jtf_dsp_msite_sct_items
    WHERE mini_site_section_item_id = x_mini_site_section_item_id;
  CURSOR c2 IS SELECT jtf_dsp_msite_sct_items_s1.nextval FROM dual;

BEGIN

  -- Primary key validation check
  x_mini_site_section_item_id := p_mini_site_section_item_id;
  IF ((x_mini_site_section_item_id IS NULL) OR
      (x_mini_site_section_item_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_mini_site_section_item_id;
    CLOSE c2;
  END IF;

  -- insert base
  INSERT INTO jtf_dsp_msite_sct_items
    (
    mini_site_section_item_id,
    object_version_number,
    mini_site_id,
    section_item_id,
    start_date_active,
    end_date_active,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    VALUES
    (
    x_mini_site_section_item_id,
    p_object_version_number,
    p_mini_site_id,
    p_section_item_id,
    p_start_date_active,
    decode(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active),
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
  p_mini_site_section_item_id           IN NUMBER,
  p_object_version_number               IN NUMBER   := FND_API.G_MISS_NUM,
  p_start_date_active                   IN DATE,
  p_end_date_active                     IN DATE,
  p_last_update_date                    IN DATE,
  p_last_updated_by                     IN NUMBER,
  p_last_update_login                   IN NUMBER
  )
IS
BEGIN

  -- update base
  UPDATE jtf_dsp_msite_sct_items SET
    object_version_number = object_version_number + 1,
    start_date_active = decode(p_start_date_active, FND_API.G_MISS_DATE,
                               start_date_active, p_start_date_active),
    end_date_active = decode(p_end_date_active, FND_API.G_MISS_DATE,
                             end_date_active, p_end_date_active),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE,
                              sysdate, NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                               FND_GLOBAL.login_id, NULL,
                               FND_GLOBAL.login_id, p_last_update_login)
    WHERE mini_site_section_item_id = p_mini_site_section_item_id
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
   p_mini_site_section_item_id IN NUMBER
  )
IS
BEGIN

  DELETE FROM jtf_dsp_msite_sct_items
    WHERE mini_site_section_item_id = p_mini_site_section_item_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

-- ****************************************************************************
--*****************************************************************************
--
--APIs
--
-- 1. Create_MSite_Section_Item
-- 2. Update_MSite_Section_Item
-- 3. Delete_MSite_Section_Item
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
   p_mini_site_id                 IN NUMBER,
   p_section_item_id              IN NUMBER,
   x_return_status                OUT VARCHAR2,
   x_msg_count                    OUT NUMBER,
   x_msg_data                     OUT VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Check_Duplicate_Entry';
  l_api_version           CONSTANT NUMBER       := 1.0;

  l_tmp_msite_sct_item_id NUMBER;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- Check duplicate entry
  BEGIN

      SELECT mini_site_section_item_id INTO l_tmp_msite_sct_item_id
        FROM  jtf_dsp_msite_sct_items
        WHERE mini_site_id = p_mini_site_id
          AND section_item_id = p_section_item_id;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
       -- not duplicate
       -- do nothing
       NULL;

     WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END;

  IF (l_tmp_msite_sct_item_id IS NOT NULL) THEN
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
   p_mini_site_id                   IN NUMBER,
   p_section_item_id                IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Validate_Create';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  l_msite_sct_item_id       NUMBER;
  l_mini_site_id            NUMBER;
  l_section_item_id         NUMBER;
  l_return_status           VARCHAR2(1);
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

  -- mini site id
  IF ((p_mini_site_id IS NULL) OR
      (p_mini_site_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_MSITE_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- section item id
  IF ((p_section_item_id IS NULL) OR
      (p_section_item_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_SI_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- start_date_active
  IF ((p_start_date_active IS NULL) OR
      (p_start_date_active = FND_API.G_MISS_DATE))
  THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_START_DATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Foreign key integrity constraint check
  --

  -- mini site id
  -- note that mini site id cannot be null due to previous checks
  BEGIN
    SELECT msite_id INTO l_mini_site_id FROM jtf_msites_b
      WHERE msite_id = p_mini_site_id;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_NO_MSITE_ID');
       FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_GET_MSITE_ID');
       FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  -- section item id
  -- note that section item id cannot be null due to previous checks
  BEGIN
    SELECT section_item_id INTO l_section_item_id FROM jtf_dsp_section_items
      WHERE section_item_id = p_section_item_id;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_NO_SI_ID');
       FND_MESSAGE.Set_Token('SECTION_ITEM_ID', p_section_item_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_GET_SI_ID');
       FND_MESSAGE.Set_Token('SECTION_ITEM_ID', p_section_item_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  -- Validate if the entry is duplicate
  Check_Duplicate_Entry(p_init_msg_list                 => FND_API.G_FALSE,
                        p_mini_site_id                  => p_mini_site_id,
                        p_section_item_id               => p_section_item_id,
                        x_return_status                 => l_return_status,
                        x_msg_count                     => l_msg_count,
                        x_msg_data                      => l_msg_data);

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_DUPLICATE_ENTRY');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- duplicate entry
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
   p_mini_site_section_item_id      IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Update';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_msite_sct_item_id     NUMBER;
  l_mini_site_id          NUMBER;
  l_section_item_id       NUMBER;
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

  -- mini_site_section_item_id
  IF (p_mini_site_section_item_id IS NULL) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NULL_PRIMARY_KEY');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- start_date_active
  IF (p_start_date_active IS NULL) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_START_DATE');
    FND_MSG_PUB.Add;
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
  )
IS
  l_api_name               CONSTANT VARCHAR2(30)
    := 'Create_MSite_Section_Item';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1);

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  CREATE_MSITE_SCT_ITEM_PVT;

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
  -- 2. Insert row with section data into section table
  --

  --
  -- 1. Validate
  --
  Validate_Create
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_mini_site_id                   => p_mini_site_id,
    p_section_item_id                => p_section_item_id,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSI_INVALID_CREATE');
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
      p_mini_site_id,
      p_section_item_id,
      p_start_date_active,
      p_end_date_active,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id,
      l_rowid,
      x_mini_site_section_item_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSI_INSERT_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSI_INSERT_FAIL');
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
     ROLLBACK TO CREATE_MSITE_SCT_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_MSITE_SCT_ITEM_PVT;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name || 'xxx');
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', p_mini_site_id || ':' || p_section_item_id);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_MSITE_SCT_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_MSite_Section_Item;

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
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_MSite_Section_Item';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_msite_sct_item_id NUMBER;
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_MSITE_SCT_ITEM_PVT;

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
  -- 1. Check if either mini_site_section_item_id or combination of
  --    mini_site_id and section_item_id is specified
  -- 2. Update row
  --

  -- 1. Check if either mini_site_section_item_id or combination of
  --    mini_site_id, section_item_id is specified
  IF ((p_mini_site_section_item_id IS NOT NULL) AND
      (p_mini_site_section_item_id <> FND_API.G_MISS_NUM))
  THEN
    -- mini_site_section_item_id specified, continue
    l_msite_sct_item_id := p_mini_site_section_item_id;
  ELSIF ((p_mini_site_id IS NOT NULL)                AND
         (p_mini_site_id <> FND_API.G_MISS_NUM)      AND
         (p_section_item_id IS NOT NULL)             AND
         (p_section_item_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of mini_site_id and section_item_id
    -- is specified, then query for mini_site_section_item_id
    BEGIN

      SELECT mini_site_section_item_id INTO l_msite_sct_item_id
        FROM jtf_dsp_msite_sct_items
        WHERE mini_site_id = p_mini_site_id
          AND section_item_id = p_section_item_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSI_ID');
           FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
           FND_MESSAGE.Set_Token('SECTION_ITEM_ID', p_section_item_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         WHEN OTHERS THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSI_ID');
           FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
           FND_MESSAGE.Set_Token('SECTION_ITEM_ID', p_section_item_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
  ELSE
    -- neither mini_site_section_item_id nor combination of
    -- mini_site_id and section_item_id is specified
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSI_IDS_SPEC');
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
    p_mini_site_section_item_id      => l_msite_sct_item_id,
    p_object_version_number          => p_object_version_number,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSI_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  -- 2. update row
  BEGIN
    update_row
      (
      l_msite_sct_item_id,
      p_object_version_number,
      p_start_date_active,
      p_end_date_active,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSI_UPDATE_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSI_UPDATE_FAIL');
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
     ROLLBACK TO UPDATE_MSITE_SCT_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_MSITE_SCT_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_MSITE_SCT_ITEM_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_MSite_Section_Item;


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
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_MSite_Section_Item';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_msite_sct_item_id        NUMBER;
BEGIN

  IF (p_call_from_trigger = FALSE) THEN
    -- Standard Start of API savepoint
    SAVEPOINT  DELETE_MSITE_SCT_ITEM_PVT;
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
  -- 1. If mini_site_section_item_id specified, delete all references for it
  -- 2. If combination of mini_site_id and section_item_id is specified, then
  --    query for mini_site_section_item_id and delete all references

  -- 1. If mini_site_section_item_id specified, delete all references for it
  IF ((p_mini_site_section_item_id IS NOT NULL) AND
      (p_mini_site_section_item_id <> FND_API.G_MISS_NUM))
  THEN
    -- mini_site_section_item_id specified, continue
    l_msite_sct_item_id := p_mini_site_section_item_id;
  ELSIF ((p_mini_site_id IS NOT NULL)                AND
         (p_mini_site_id <> FND_API.G_MISS_NUM)      AND
         (p_section_item_id IS NOT NULL)             AND
         (p_section_item_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of mini_site_id and section_item_id is specified, then
    -- query for mini_site_section_item_id
    BEGIN

        SELECT mini_site_section_item_id INTO l_msite_sct_item_id
          FROM jtf_dsp_msite_sct_items
          WHERE mini_site_id = p_mini_site_id
            AND section_item_id = p_section_item_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSI_ID');
         FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
         FND_MESSAGE.Set_Token('SECTION_ITEM_ID', p_section_item_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSI_ID');
         FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
         FND_MESSAGE.Set_Token('SECTION_ITEM_ID', p_section_item_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

  ELSE
    -- neither mini_site_section_item_id nor combination of
    -- mini_site_id and section_item_id is specified
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSI_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- delete row
  delete_row(l_msite_sct_item_id);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF (p_call_from_trigger = FALSE) THEN
       ROLLBACK TO DELETE_MSITE_SCT_ITEM_PVT;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (p_call_from_trigger = FALSE) THEN
       ROLLBACK TO DELETE_MSITE_SCT_ITEM_PVT;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     IF (p_call_from_trigger = FALSE) THEN
       ROLLBACK TO DELETE_MSITE_SCT_ITEM_PVT;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_MSite_Section_Item;

END JTF_DSP_MSITE_SCT_ITEM_PVT;

/