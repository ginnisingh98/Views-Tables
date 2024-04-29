--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_RESP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_RESP_PVT" AS
/* $Header: IBEVMRSB.pls 120.0.12010000.4 2016/10/19 21:29:56 ytian ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_RESP_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVMRSB.pls';
l_true       VARCHAR2(1)            := FND_API.G_TRUE;



PROCEDURE Validate_Msite_Id_Exists
  (
   p_msite_id                       IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Msite_Id_Exists';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER)
  IS SELECT msite_id FROM ibe_msites_b
    WHERE msite_id = l_c_msite_id
    AND master_msite_flag = 'N' and site_type = 'I';

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if msite_id exists in ibe_msites_b
  OPEN c1(p_msite_id);
  FETCH c1 INTO l_tmp_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_ID_NOT_FOUND');
    FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
    FND_MSG_PUB.Add;
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
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Validate_Msite_Id_Exists;

PROCEDURE Validate_Resp_Appl_Id_Exists
  (
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Resp_Appl_Id_Exists';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_responsibility_id IN NUMBER, l_c_application_id IN NUMBER)
  IS SELECT responsibility_id FROM fnd_responsibility_vl
    WHERE responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if responsibility_id and application_id combination
  -- exists in fnd_responsibility
  OPEN c1(p_responsibility_id, p_application_id);
  FETCH c1 INTO l_tmp_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_RESP_APPL_NOT_FOUND');
    FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
    FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
    FND_MSG_PUB.Add;
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
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Validate_Resp_Appl_Id_Exists;

PROCEDURE Validate_Msite_Resp_Id_Exists
  (
   p_msite_resp_id                  IN NUMBER,
   p_msite_id                       IN NUMBER,
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Msite_Resp_Id_Exists';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_msite_resp_id IN NUMBER)
  IS SELECT msite_resp_id FROM ibe_msite_resps_b
    WHERE msite_resp_id = l_c_msite_resp_id;

  CURSOR c2(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
           l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id FROM ibe_msite_resps_b
    WHERE msite_id = l_c_msite_id
    AND responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if msite_resp_id or combination of msite_id, responsibility_id,
  -- application_id exists in ibe_msite_resps_b
  IF ((p_msite_resp_id IS NOT NULL) AND
      (p_msite_resp_id <> FND_API.G_MISS_NUM))
  THEN

    OPEN c1(p_msite_resp_id);
    FETCH c1 INTO l_tmp_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_RESP_ID', p_msite_resp_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_responsibility_id IS NOT NULL)           AND
         (p_responsibility_id <> FND_API.G_MISS_NUM) AND
         (p_application_id IS NOT NULL)              AND
         (p_application_id <> FND_API.G_MISS_NUM))
  THEN

    OPEN c2(p_msite_id, p_responsibility_id, p_application_id);
    FETCH c2 INTO l_tmp_id;
    IF (c2%NOTFOUND) THEN
      CLOSE c2;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITERESP_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
      FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c2;

  ELSE
    -- neither msite_resp_id nor combination of
    -- msite_id, responsibility_id and application_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MR_IDS_SPEC');
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

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Validate_Msite_Resp_Id_Exists;

PROCEDURE Validate_Create
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_sort_order                     IN NUMBER,
   p_display_name                   IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Validate_Create';
  l_api_version             CONSTANT NUMBER       := 1.0;

  l_msite_resp_id           NUMBER;
  l_msite_id                NUMBER;
  l_responsibility_id       NUMBER;
  l_application_id          NUMBER;

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
  -- p_msite_id
  IF ((p_msite_id IS NULL) OR
      (p_msite_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_MSITE_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- p_responsibility_id
  IF ((p_responsibility_id IS NULL) OR
      (p_responsibility_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVALID_RESP_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- application_id
  IF ((p_application_id IS NULL) OR
      (p_application_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVALID_APPL_ID');
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

  -- display_name
  IF ((p_display_name IS NULL) OR
      (p_display_name = FND_API.G_MISS_CHAR))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVLD_MSRSP_DSP_NAME');
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
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVLD_SORT_ORDER');
      FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --
  -- Foreign key integrity constraint check
  --

  -- msite_id
  Validate_Msite_Id_Exists
    (
    p_msite_id                       => p_msite_id,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );


  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_ID_VLD_FAIL');
    FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_ID_VLD_FAIL');
    FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
    RAISE FND_API.G_EXC_ERROR;            -- invalid msite_id
  END IF;

  -- responsibility_id and application_id
  Validate_Resp_Appl_Id_Exists
    (
    p_responsibility_id              => p_responsibility_id,
    p_application_id                 => p_application_id,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );


  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_RESP_ID_VLD_FAIL');
    FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
    FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_RESP_ID_VLD_FAIL');
    FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
    FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- p_msite_id, p_responsibility_id, p_application_id (check for duplicate)
--  Validate_Msite_Resp_Id_Exists
--    (
--    p_msite_resp_id                  => FND_API.G_MISS_NUM,
--    p_msite_id                       => p_msite_id,
--    p_responsibility_id              => p_responsibility_id,
--    p_application_id                 => p_application_id,
--    x_return_status                  => x_return_status,
--    x_msg_count                      => x_msg_count,
--    x_msg_data                       => x_msg_data
--    );

--  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
--    x_return_status := FND_API.G_RET_STS_SUCCESS;
--  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
--    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSRSP_ID_VLD_FAIL');
--    FND_MSG_PUB.Add;
--    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--  ELSIF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN -- duplicate exists
--    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSRSP_ID_DUP_EXISTS');
--    FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
--    FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
--    FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
--    FND_MSG_PUB.Add;
--    RAISE FND_API.G_EXC_ERROR;
--  END IF;

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

PROCEDURE Validate_Update
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id                  IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_sort_order                     IN NUMBER,
   p_display_name                   IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Update';
  l_api_version           CONSTANT NUMBER       := 1.0;

  l_msite_resp_id         NUMBER;
  l_msite_id              NUMBER;
  l_responsibility_id     NUMBER;
  l_application_id        NUMBER;

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

  -- msite_resp_id
  IF (p_msite_resp_id IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSRSP_ID_IS_NULL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- object_version_number
  IF (p_object_version_number IS NULL)
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_OVN_IS_NULL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- start_date_active
  IF (p_start_date_active IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_START_DATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- display_name
  IF (p_display_name IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVLD_MSRSP_DSP_NAME');
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
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVLD_SORT_ORDER');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- check if the association already exists, if not, then throw error
  Validate_Msite_Resp_Id_Exists
  (
   p_msite_resp_id                  => p_msite_resp_id,
   p_msite_id                       => FND_API.G_MISS_NUM,
   p_responsibility_id              => FND_API.G_MISS_NUM,
   p_application_id                 => FND_API.G_MISS_NUM,
   x_return_status                  => x_return_status,
   x_msg_count                      => x_msg_count,
   x_msg_data                       => x_msg_data
  );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSRSP_ID_VLD_FAIL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSRSP_ID_VLD_FAIL');
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


PROCEDURE Create_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id		    IN NUMBER,
   p_msite_id                       IN NUMBER,
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2,
   p_group_code                     IN VARCHAR2,
   x_msite_resp_id                  OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Msite_Resp';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT create_msite_resp_pvt;

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
  -- 1. Check if everything is valid
  -- 2. Insert row with section data into section table
  --

  --
  -- 1. Check if everything is valid
  --
  Validate_Create
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_msite_id                       => p_msite_id,
    p_responsibility_id              => p_responsibility_id,
    p_application_id                 => p_application_id,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_sort_order                     => p_sort_order,
    p_display_name                   => p_display_name,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  --
  -- 2. Insert row
  --
  BEGIN
    Ibe_Msite_Resp_Pkg.insert_row
      (
      p_msite_resp_id                      => p_msite_resp_id,
      p_object_version_number              => l_object_version_number,
      p_msite_id                           => p_msite_id,
      p_responsibility_id                  => p_responsibility_id,
      p_application_id                     => p_application_id,
      p_start_date_active                  => p_start_date_active,
      p_end_date_active                    => p_end_date_active,
      p_sort_order                         => p_sort_order,
      p_display_name                       => p_display_name,
      p_group_code                         => p_group_code,
      p_creation_date                      => sysdate,
      p_created_by                         => FND_GLOBAL.user_id,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id,
      x_rowid                              => l_rowid,
      x_msite_resp_id                      => x_msite_resp_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_INSERT_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_INSERT_FL');
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
     ROLLBACK TO create_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO create_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_Msite_Resp;

PROCEDURE Create_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id		    IN NUMBER,
   p_msite_id                       IN NUMBER,
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2,
   p_group_code                     IN VARCHAR2,
   p_ordertype_id                     IN NUMBER ,
   x_msite_resp_id                  OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Msite_Resp';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT create_msite_resp_pvt;

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
  -- 1. Check if everything is valid
  -- 2. Insert row with section data into section table
  --

  --
  -- 1. Check if everything is valid
  --
  Validate_Create
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_msite_id                       => p_msite_id,
    p_responsibility_id              => p_responsibility_id,
    p_application_id                 => p_application_id,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_sort_order                     => p_sort_order,
    p_display_name                   => p_display_name,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  --
  -- 2. Insert row
  --
  BEGIN
    Ibe_Msite_Resp_Pkg.insert_row
      (
      p_msite_resp_id                      => p_msite_resp_id,
      p_object_version_number              => l_object_version_number,
      p_msite_id                           => p_msite_id,
      p_responsibility_id                  => p_responsibility_id,
      p_application_id                     => p_application_id,
      p_start_date_active                  => p_start_date_active,
      p_end_date_active                    => p_end_date_active,
      p_sort_order                         => p_sort_order,
      p_display_name                       => p_display_name,
      p_group_code                         => p_group_code,
      p_ordertype_id                       => p_ordertype_id,
      p_creation_date                      => sysdate,
      p_created_by                         => FND_GLOBAL.user_id,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id,
      x_rowid                              => l_rowid,
      x_msite_resp_id                      => x_msite_resp_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_INSERT_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_INSERT_FL');
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
     ROLLBACK TO create_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO create_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_Msite_Resp;

PROCEDURE Update_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_msite_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_responsibility_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_application_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_group_code                     IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Msite_Resp';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_msite_resp_id     NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
           l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id FROM ibe_msite_resps_b
    WHERE msite_id = l_c_msite_id
    AND responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT update_msite_resp_pvt;

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
  -- 1. Check if everything is valid
  -- 2. Update row

  -- 1a. Check if either msite_resp_id or combination of
  --    msite_id, responsibility_id and application_id is specified
  IF ((p_msite_resp_id IS NOT NULL) AND
      (p_msite_resp_id <> FND_API.G_MISS_NUM))
  THEN
    -- msite_resp_id specified, continue
    l_msite_resp_id := p_msite_resp_id;
  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_responsibility_id IS NOT NULL)           AND
         (p_responsibility_id <> FND_API.G_MISS_NUM) AND
         (p_application_id IS NOT NULL)              AND
         (p_application_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of msite_id, responsibility_id and application_id
    -- is specified, then query for msite_resp_id

    OPEN c1(p_msite_id, p_responsibility_id, p_application_id);
    FETCH c1 INTO l_msite_resp_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITERESP_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
      FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSE
    -- neither msite_resp_id nor combination of
    -- msite_id, responsibility_id and application_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MR_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- 1b. Validate the input data
  --
  Validate_Update
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_msite_resp_id                  => l_msite_resp_id,
    p_object_version_number          => p_object_version_number,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_sort_order                     => p_sort_order,
    p_display_name                   => p_display_name,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  -- 2. update row with section data into section table
  BEGIN
    Ibe_Msite_Resp_Pkg.update_row
      (
      p_msite_resp_id                      => l_msite_resp_id,
      p_object_version_number              => p_object_version_number,
      p_start_date_active                  => p_start_date_active,
      p_end_date_active                    => p_end_date_active,
      p_sort_order                         => p_sort_order,
      p_display_name                       => p_display_name,
      p_group_code                         => p_group_code,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_UPDATE_FL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_UPDATE_FL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  --
  -- end of main api body.

  -- standard check of p_commit.
  IF (FND_API.to_boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO update_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Msite_Resp;


PROCEDURE Update_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_msite_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_responsibility_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_application_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_group_code                     IN VARCHAR2,
   p_order_type_id                  IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Msite_Resp';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_msite_resp_id     NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
           l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id FROM ibe_msite_resps_b
    WHERE msite_id = l_c_msite_id
    AND responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

BEGIN

  IBE_Util.enable_debug_new('N');

  IF (FND_API.to_boolean(p_commit)) THEN
      ibe_util.debug('@@@@@@@tier 2, p_commit is true');
  else
     ibe_util.debug('@@@@@@@tier 2, p_commit is false');
  end if;


  -- Standard Start of API savepoint
  SAVEPOINT update_msite_resp_pvt;

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
  -- 1. Check if everything is valid
  -- 2. Update row

  -- 1a. Check if either msite_resp_id or combination of
  --    msite_id, responsibility_id and application_id is specified
  IF ((p_msite_resp_id IS NOT NULL) AND
      (p_msite_resp_id <> FND_API.G_MISS_NUM))
  THEN
    -- msite_resp_id specified, continue
    l_msite_resp_id := p_msite_resp_id;
  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_responsibility_id IS NOT NULL)           AND
         (p_responsibility_id <> FND_API.G_MISS_NUM) AND
         (p_application_id IS NOT NULL)              AND
         (p_application_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of msite_id, responsibility_id and application_id
    -- is specified, then query for msite_resp_id

    OPEN c1(p_msite_id, p_responsibility_id, p_application_id);
    FETCH c1 INTO l_msite_resp_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITERESP_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
      FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSE
    -- neither msite_resp_id nor combination of
    -- msite_id, responsibility_id and application_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MR_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- 1b. Validate the input data
  --
  Validate_Update
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_msite_resp_id                  => l_msite_resp_id,
    p_object_version_number          => p_object_version_number,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_sort_order                     => p_sort_order,
    p_display_name                   => p_display_name,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MR_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  -- 2. update row with section data into section table
  BEGIN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Before call Ibe_Msite_Resp_Pkg.update_row: ordertypeid='||p_order_Type_id||'msiterespid='||l_msite_resp_id);
    END IF;
    Ibe_Msite_Resp_Pkg.update_row
      (
      p_msite_resp_id                      => l_msite_resp_id,
      p_object_version_number              => p_object_version_number,
      p_start_date_active                  => p_start_date_active,
      p_end_date_active                    => p_end_date_active,
      p_sort_order                         => p_sort_order,
      p_display_name                       => p_display_name,
      p_group_code                         => p_group_code,
      p_order_type_id                      => p_order_type_id,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_UPDATE_FL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_UPDATE_FL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  --
  -- end of main api body.

  -- standard check of p_commit.
  IF (FND_API.to_boolean(p_commit)) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('p_commit is true');
      END IF;
      COMMIT WORK;
  else
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('p_commit is false, work is not committed');
      END IF;
  END IF;

  -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');


   WHEN OTHERS THEN


     ROLLBACK TO update_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Msite_Resp;


PROCEDURE Delete_Msite_Resp
  (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                      IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level            IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id               IN NUMBER      := FND_API.G_MISS_NUM,
   p_msite_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   p_responsibility_id           IN NUMBER      := FND_API.G_MISS_NUM,
   p_application_id              IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_Msite_Resp';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_msite_resp_id     NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
           l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id FROM ibe_msite_resps_b
    WHERE msite_id = l_c_msite_id
    AND responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT delete_msite_resp_pvt;

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

  -- 1a. Check if either msite_resp_id or combination of
  --    msite_id, responsibility_id and application_id is specified
  IF ((p_msite_resp_id IS NOT NULL) AND
      (p_msite_resp_id <> FND_API.G_MISS_NUM))
  THEN
    -- msite_resp_id specified, continue
    l_msite_resp_id := p_msite_resp_id;
  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_responsibility_id IS NOT NULL)           AND
         (p_responsibility_id <> FND_API.G_MISS_NUM) AND
         (p_application_id IS NOT NULL)              AND
         (p_application_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of msite_id, responsibility_id and application_id
    -- is specified, then query for msite_resp_id

    OPEN c1(p_msite_id, p_responsibility_id, p_application_id);
    FETCH c1 INTO l_msite_resp_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITERESP_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
      FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSE
    -- neither msite_resp_id nor combination of
    -- msite_id, responsibility_id and application_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MR_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- delete for ibe_msite_resps_b and _tl tables
  BEGIN
    Ibe_Msite_Resp_Pkg.delete_row(l_msite_resp_id);
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_DELETE_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_DELETE_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO delete_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_Msite_Resp;


PROCEDURE Delete_Msite_Resp_Group
  (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                      IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level            IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id               IN NUMBER      := FND_API.G_MISS_NUM,
   p_msite_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   p_responsibility_id           IN NUMBER      := FND_API.G_MISS_NUM,
   p_application_id              IN NUMBER      := FND_API.G_MISS_NUM,
   p_group_code                  IN VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_Msite_Resp_Group';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_msite_resp_id     NUMBER;
  l_count             NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
           l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id
    FROM ibe_msite_resps_b
    WHERE msite_id = l_c_msite_id
    AND responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

  CURSOR c2(l_msite_resp_id IN NUMBER)
  IS SELECT count(*)
  FROM ibe_msite_resps_b
  WHERE msite_resp_id = l_msite_resp_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT delete_msite_resp_pvt;

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

  -- 1a. Check if either msite_resp_id or combination of
  --    msite_id, responsibility_id and application_id is specified
  IF ((p_msite_resp_id IS NOT NULL) AND
      (p_msite_resp_id <> FND_API.G_MISS_NUM))
  THEN
    -- msite_resp_id specified, continue
    l_msite_resp_id := p_msite_resp_id;
  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_responsibility_id IS NOT NULL)           AND
         (p_responsibility_id <> FND_API.G_MISS_NUM) AND
         (p_application_id IS NOT NULL)              AND
         (p_application_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of msite_id, responsibility_id and application_id
    -- is specified, then query for msite_resp_id

    OPEN c1(p_msite_id, p_responsibility_id, p_application_id);
    FETCH c1 INTO l_msite_resp_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITERESP_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
      FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSE
    -- neither msite_resp_id nor combination of
    -- msite_id, responsibility_id and application_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MR_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  OPEN c2(p_msite_resp_id);
  FETCH c2 INTO l_count;
  IF (c2%NOTFOUND) THEN
    CLOSE c2;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITERESP_NOT_FOUND');
    FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
    FND_MESSAGE.Set_Token('RESP_ID', p_responsibility_id);
    FND_MESSAGE.Set_Token('APPL_ID', p_application_id);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_count = 1) THEN
  -- update the last group code to be null
    BEGIN

      UPDATE ibe_msite_resps_b SET
      group_code = null
      where msite_resp_id = p_msite_resp_id
      AND group_code = p_group_code;

      IF (sql%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_DELETE_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_DELETE_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;

  ELSE

    -- delete for ibe_msite_resps_b and _tl tables
    BEGIN

      DELETE FROM ibe_msite_resps_b
      WHERE msite_resp_id = p_msite_resp_id
      AND group_code = p_group_code;

      IF (sql%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_DELETE_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_RESP_DELETE_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO delete_msite_resp_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_Msite_Resp_Group;

END Ibe_Msite_Resp_Pvt;

/
