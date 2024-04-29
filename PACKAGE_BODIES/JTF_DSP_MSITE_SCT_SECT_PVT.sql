--------------------------------------------------------
--  DDL for Package Body JTF_DSP_MSITE_SCT_SECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DSP_MSITE_SCT_SECT_PVT" AS
/* $Header: JTFVCMSB.pls 115.15 2004/07/09 18:51:37 applrt ship $ */


  --
  --
  -- Start of Comments
  --
  -- NAME
  --   JTF_DSP_MSITE_SCT_SECT_PVT
  --
  -- PURPOSE
  --   Private API for saving, retrieving and updating mini site
  --   section sections.
  --
  -- NOTES
  --   This is a pulicly accessible package.  It should be used by all
  --   sources for saving, retrieving and updating mini site section
  --   sections

  -- HISTORY
  --   11/28/99           VPALAIYA         Created
  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'JTF_DSP_MSITE_SCT_SECT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'JTFVCMSB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    TABLE HANDLERS
--      1. insert_row
--      2. update_row
--      3. delete_row
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- insert row into mini site section-section
-- ****************************************************************************

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
  )
IS
  CURSOR c IS SELECT rowid FROM jtf_dsp_msite_sct_sects
    WHERE mini_site_section_section_id = x_mini_site_section_section_id;
  CURSOR c2 IS SELECT jtf_dsp_msite_sct_sects_s1.nextval FROM dual;

BEGIN

  -- Primary key validation check
  x_mini_site_section_section_id := p_mini_site_section_section_id;
  IF ((x_mini_site_section_section_id IS NULL) OR
      (x_mini_site_section_section_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_mini_site_section_section_id;
    CLOSE c2;
  END IF;

  -- insert base
  INSERT INTO jtf_dsp_msite_sct_sects
    (
    mini_site_section_section_id,
    object_version_number,
    mini_site_id,
    parent_section_id,
    child_section_id,
    start_date_active,
    end_date_active,
    level_number,
    sort_order,
    concat_ids,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    VALUES
    (
    x_mini_site_section_section_id,
    p_object_version_number,
    p_mini_site_id,
    decode(p_parent_section_id, FND_API.G_MISS_NUM, NULL, p_parent_section_id),
    p_child_section_id,
    p_start_date_active,
    decode(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active),
    decode(p_level_number, FND_API.G_MISS_NUM, NULL, p_level_number),
    decode(p_sort_order, FND_API.G_MISS_NUM, NULL, p_sort_order),
    decode(p_concat_ids, FND_API.G_MISS_CHAR, NULL, p_concat_ids),
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
  )
IS
BEGIN

  -- update base
  UPDATE jtf_dsp_msite_sct_sects SET
    object_version_number = object_version_number + 1,
    level_number = decode(p_level_number, FND_API.G_MISS_NUM,
                          level_number, p_level_number),
    sort_order = decode(p_sort_order, FND_API.G_MISS_NUM,
                        sort_order, p_sort_order),
    concat_ids = decode(p_concat_ids, FND_API.G_MISS_CHAR,
                        concat_ids, p_concat_ids),
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
    WHERE mini_site_section_section_id = p_mini_site_section_section_id
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
   p_mini_site_section_section_id IN NUMBER
  )
IS
BEGIN

  DELETE FROM jtf_dsp_msite_sct_sects
    WHERE mini_site_section_section_id = p_mini_site_section_section_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

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
  )
IS
  l_user_id                        NUMBER := 0;
  l_rowid                          VARCHAR2(256);
  l_mini_site_section_section_id   NUMBER;
  l_object_version_number          NUMBER := 1;
BEGIN

  IF (p_owner = 'SEED') THEN
    l_user_id := 1;
  END IF;

  IF ((p_object_version_number IS NOT NULL) AND
      (p_object_version_number <> FND_API.G_MISS_NUM))
  THEN
    l_object_version_number := p_object_version_number;
  END IF;

  BEGIN

    update_row
      (
      p_mini_site_section_section_id        => p_mini_site_section_section_id,
      p_object_version_number               => p_object_version_number,
      p_start_date_active                   => p_start_date_active,
      p_end_date_active                     => p_end_date_active,
      p_level_number                        => p_level_number,
      p_sort_order                          => p_sort_order,
      p_concat_ids                          => p_concat_ids,
      p_last_update_date                    => sysdate,
      p_last_updated_by                     => l_user_id,
      p_last_update_login                   => 0
      );

  EXCEPTION

     WHEN NO_DATA_FOUND THEN

       insert_row
       (
       p_mini_site_section_section_id       => p_mini_site_section_section_id,
       p_object_version_number              => l_object_version_number,
       p_mini_site_id                       => p_mini_site_id,
       p_parent_section_id                  => p_parent_section_id,
       p_child_section_id                   => p_child_section_id,
       p_start_date_active                  => p_start_date_active,
       p_end_date_active                    => p_end_date_active,
       p_level_number                       => p_level_number,
       p_sort_order                         => p_sort_order,
       p_concat_ids                         => p_concat_ids,
       p_creation_date                      => sysdate,
       p_created_by                         => l_user_id,
       p_last_update_date                   => sysdate,
       p_last_updated_by                    => l_user_id,
       p_last_update_login                  => 0,
       x_rowid                              => l_rowid,
       x_mini_site_section_section_id       => l_mini_site_section_section_id
       );
  END;

END load_row;


-- ****************************************************************************
--*****************************************************************************
--
--APIs
--
-- 1. Create_MSite_Section_Section
-- 2. Update_MSite_Section_Section
-- 3. Delete_MSite_Section_Section
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
   p_parent_section_id            IN NUMBER,
   p_child_section_id             IN NUMBER,
   x_return_status                OUT VARCHAR2,
   x_msg_count                    OUT NUMBER,
   x_msg_data                     OUT VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Check_Duplicate_Entry';
  l_api_version           CONSTANT NUMBER       := 1.0;

  l_tmp_msite_sct_sect_id NUMBER;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- Check duplicate entry
  BEGIN

    IF (p_parent_section_id IS NOT NULL) THEN

      SELECT mini_site_section_section_id INTO l_tmp_msite_sct_sect_id
        FROM  jtf_dsp_msite_sct_sects
        WHERE mini_site_id = p_mini_site_id
          AND parent_section_id = p_parent_section_id
          AND child_section_id = p_child_section_id;

    ELSE

      SELECT mini_site_section_section_id INTO l_tmp_msite_sct_sect_id
        FROM  jtf_dsp_msite_sct_sects
        WHERE mini_site_id = p_mini_site_id
          AND parent_section_id IS NULL
          AND child_section_id = p_child_section_id;

    END IF;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
       -- not duplicate
       -- do nothing
       NULL;

     WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END;

  IF (l_tmp_msite_sct_sect_id IS NOT NULL) THEN
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
   p_parent_section_id              IN NUMBER,
   p_child_section_id               IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_level_number                   IN NUMBER,
   p_sort_order                     IN NUMBER,
   p_concat_ids                     IN VARCHAR2,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Validate_Create';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  l_mini_site_id            NUMBER;
  l_parent_section_id       NUMBER;
  l_child_section_id        NUMBER;
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

  -- child section id
  IF ((p_child_section_id IS NULL) OR
      (p_child_section_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_CHILD_SCT_ID');
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
  -- non-null field validation
  --

  -- level number
  IF ((p_level_number IS NOT NULL) AND
      (p_level_number <> FND_API.G_MISS_NUM))
  THEN
    IF(p_level_number < 0) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_SCT_LVL_NUM');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- sort order
  IF ((p_sort_order IS NOT NULL) AND
      (p_sort_order <> FND_API.G_MISS_NUM))
  THEN
    IF(p_sort_order < 0) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_SCT_SORT_ORDER');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
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

  -- parent section id
  IF ((p_parent_section_id IS NOT NULL) AND
      (p_parent_section_id <> FND_API.G_MISS_NUM))
  THEN
    BEGIN
      SELECT section_id INTO l_parent_section_id FROM jtf_dsp_sections_b
        WHERE section_id = p_parent_section_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_NO_SCT_ID');
         FND_MESSAGE.Set_Token('SECTION_ID', p_parent_section_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_GET_SCT_ID');
         FND_MESSAGE.Set_Token('SECTION_ID', p_parent_section_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  -- child section id
  -- note that child section id cannot be null due to previous checks
  BEGIN
    SELECT section_id INTO l_child_section_id FROM jtf_dsp_sections_b
      WHERE section_id = p_child_section_id;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_NO_SCT_ID');
       FND_MESSAGE.Set_Token('SECTION_ID', p_child_section_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_SCT_GET_SCT_ID');
       FND_MESSAGE.Set_Token('SECTION_ID', p_child_section_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  -- Validate if the entry is duplicate
  Check_Duplicate_Entry(p_init_msg_list                 => FND_API.G_FALSE,
                        p_mini_site_id                  => p_mini_site_id,
                        p_parent_section_id             => p_parent_section_id,
                        p_child_section_id              => p_child_section_id,
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
   p_mini_site_section_section_id   IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_level_number                   IN NUMBER,
   p_sort_order                     IN NUMBER,
   p_concat_ids                     IN VARCHAR2,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Update';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_msite_sct_sect_id     NUMBER;
  l_mini_site_id          NUMBER;
  l_parent_section_id     NUMBER;
  l_child_section_id      NUMBER;
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

  -- mini_site_section_section_id
  IF (p_mini_site_section_section_id IS NULL) THEN
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

  --
  -- non-null field validation
  --

  -- level number
  IF ((p_level_number IS NOT NULL) AND
      (p_level_number <> FND_API.G_MISS_NUM))
  THEN
    IF(p_level_number < 0) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_SCT_LVL_NUM');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- sort order
  IF ((p_sort_order IS NOT NULL) AND
      (p_sort_order <> FND_API.G_MISS_NUM))
  THEN
    IF(p_sort_order < 0) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_INVALID_SCT_SORT_ORDER');
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
  )
IS
  l_api_name               CONSTANT VARCHAR2(30)
    := 'Create_MSite_Section_Section';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1);

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  CREATE_MSITE_SCT_SECT_PVT;

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
    p_mini_site_id                   => p_mini_site_id,
    p_parent_section_id              => p_parent_section_id,
    p_child_section_id               => p_child_section_id,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_level_number                   => p_level_number,
    p_sort_order                     => p_sort_order,
    p_concat_ids                     => p_concat_ids,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSS_INVALID_CREATE');
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
      p_parent_section_id,
      p_child_section_id,
      p_start_date_active,
      p_end_date_active,
      p_level_number,
      p_sort_order,
      p_concat_ids,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id,
      l_rowid,
      x_mini_site_section_section_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSS_INSERT_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSS_INSERT_FAIL');
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
     ROLLBACK TO CREATE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_MSite_Section_Section;

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
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_MSite_Section_Section';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_msite_sct_sect_id NUMBER;
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_MSITE_SCT_SECT_PVT;

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
  -- 1. Check if either mini_site_section_section_id or combination of
  --    mini_site_id, parent_section_id and child_section_id is specified
  -- 2. Update row
  --

  -- 1. Check if either mini_site_section_section_id or combination of
  --    mini_site_id, parent_section_id and child_section_id is specified
  IF ((p_mini_site_section_section_id IS NOT NULL) AND
      (p_mini_site_section_section_id <> FND_API.G_MISS_NUM))
  THEN
    -- mini_site_section_section_id specified, continue
    l_msite_sct_sect_id := p_mini_site_section_section_id;
  ELSIF ((p_mini_site_id IS NOT NULL)                AND
         (p_mini_site_id <> FND_API.G_MISS_NUM)      AND
         (p_parent_section_id <> FND_API.G_MISS_NUM) AND -- parent can be NULL
         (p_child_section_id IS NOT NULL)            AND
         (p_child_section_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of mini_site_id, parent_section_id and child_section_id
    -- is specified, then query for mini_site_section_section_id
    BEGIN
      IF (p_parent_section_id IS NOT NULL) THEN

        SELECT mini_site_section_section_id INTO l_msite_sct_sect_id
          FROM jtf_dsp_msite_sct_sects
          WHERE mini_site_id = p_mini_site_id
            AND parent_section_id = p_parent_section_id
            AND child_section_id = p_child_section_id;
      ELSE

        SELECT mini_site_section_section_id INTO l_msite_sct_sect_id
          FROM jtf_dsp_msite_sct_sects
          WHERE mini_site_id = p_mini_site_id
            AND parent_section_id IS NULL
            AND child_section_id = p_child_section_id;

      END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSS_ID');
           FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
           IF (p_parent_section_id IS NOT NULL) THEN
             FND_MESSAGE.Set_Token('PARENT_SECTION_ID', p_parent_section_id);
           ELSE
             FND_MESSAGE.Set_Token('PARENT_SECTION_ID', 'NULL');
           END IF;
           FND_MESSAGE.Set_Token('CHILD_SECTION_ID', p_child_section_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         WHEN OTHERS THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSS_ID');
           FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
           IF (p_parent_section_id IS NOT NULL) THEN
             FND_MESSAGE.Set_Token('PARENT_SECTION_ID', p_parent_section_id);
           ELSE
             FND_MESSAGE.Set_Token('PARENT_SECTION_ID', 'NULL');
           END IF;
           FND_MESSAGE.Set_Token('CHILD_SECTION_ID', p_child_section_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
  ELSE
    -- neither mini_site_section_section_id nor combination of
    -- mini_site_id, parent_section_id and child_section_id is specified
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSS_IDS_SPEC');
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
    p_mini_site_section_section_id   => l_msite_sct_sect_id,
    p_object_version_number          => p_object_version_number,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_level_number                   => p_level_number,
    p_sort_order                     => p_sort_order,
    p_concat_ids                     => p_concat_ids,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSS_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  -- 2. update row
  BEGIN
    update_row
      (
      l_msite_sct_sect_id,
      p_object_version_number,
      p_start_date_active,
      p_end_date_active,
      p_level_number,
      p_sort_order,
      p_concat_ids,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSS_UPDATE_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_MSS_UPDATE_FAIL');
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
     ROLLBACK TO UPDATE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_MSite_Section_Section;


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
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_MSite_Section_Section';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_msite_sct_sect_id        NUMBER;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  DELETE_MSITE_SCT_SECT_PVT;

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
  -- 1. If mini_site_section_section_id specified, delete all references for it
  -- 2. If combination of mini_site_id, parent_section_id and child_section_id
  --    is specified, then query for mini_site_section_section_id and delete
  --    all references

  -- 1. If mini_site_section_section_id specified, delete all references for it
  IF ((p_mini_site_section_section_id IS NOT NULL) AND
      (p_mini_site_section_section_id <> FND_API.G_MISS_NUM))
  THEN
    -- mini_site_section_section_id specified, continue
    l_msite_sct_sect_id := p_mini_site_section_section_id;
  ELSIF ((p_mini_site_id IS NOT NULL)                AND
         (p_mini_site_id <> FND_API.G_MISS_NUM)      AND
         (p_parent_section_id <> FND_API.G_MISS_NUM) AND -- parent can be NULL
         (p_child_section_id IS NOT NULL)            AND
         (p_child_section_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of mini_site_id, parent_section_id and child_section_id
    -- is specified, then query for mini_site_section_section_id
    BEGIN
      IF (p_parent_section_id IS NOT NULL) THEN

        SELECT mini_site_section_section_id INTO l_msite_sct_sect_id
          FROM jtf_dsp_msite_sct_sects
          WHERE mini_site_id = p_mini_site_id
            AND parent_section_id = p_parent_section_id
            AND child_section_id = child_section_id;
      ELSE

        SELECT mini_site_section_section_id INTO l_msite_sct_sect_id
          FROM jtf_dsp_msite_sct_sects
          WHERE mini_site_id = p_mini_site_id
            AND parent_section_id IS NULL
            AND child_section_id = child_section_id;

      END IF;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSS_ID');
         FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
         IF (p_parent_section_id IS NOT NULL) THEN
           FND_MESSAGE.Set_Token('PARENT_SECTION_ID', p_parent_section_id);
         ELSE
           FND_MESSAGE.Set_Token('PARENT_SECTION_ID', 'NULL');
         END IF;
         FND_MESSAGE.Set_Token('CHILD_SECTION_ID', p_child_section_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSS_ID');
         FND_MESSAGE.Set_Token('MINI_SITE_ID', p_mini_site_id);
         IF (p_parent_section_id IS NOT NULL) THEN
           FND_MESSAGE.Set_Token('PARENT_SECTION_ID', p_parent_section_id);
         ELSE
           FND_MESSAGE.Set_Token('PARENT_SECTION_ID', 'NULL');
         END IF;
         FND_MESSAGE.Set_Token('CHILD_SECTION_ID', p_child_section_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

  ELSE
    -- neither mini_site_section_section_id nor combination of
    -- mini_site_id, parent_section_id and child_section_id is specified
    FND_MESSAGE.Set_Name('JTF', 'JTF_DSP_NO_MSS_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- delete row
  delete_row(l_msite_sct_sect_id);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_MSITE_SCT_SECT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_MSite_Section_Section;

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
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_MSite_Section_Sections';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_msite_sct_sect_id NUMBER;
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_MSITE_SCT_SECTS_PVT;

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

    Update_MSite_Section_Section
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
      x_return_status                  => l_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
     ROLLBACK TO UPDATE_MSITE_SCT_SECTS_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_MSITE_SCT_SECTS_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_MSITE_SCT_SECTS_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_MSite_Section_Sections;

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
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Delete_Sct_Scts';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_section_item_id   NUMBER;
  l_return_status     VARCHAR2(1);

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

      Delete_MSite_Section_Section
        (
        p_api_version                  => p_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
        p_mini_site_section_section_id => p_msite_section_section_ids(i),
        p_mini_site_id                 => FND_API.G_MISS_NUM,
        p_parent_section_id            => FND_API.G_MISS_NUM,
        p_child_section_id             => FND_API.G_MISS_NUM,
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

      Update_Msite_Section_Section
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
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Delete_Sct_Scts;

END JTF_DSP_MSITE_SCT_SECT_PVT;

/
