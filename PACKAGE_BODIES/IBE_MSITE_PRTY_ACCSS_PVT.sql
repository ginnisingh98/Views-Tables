--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_PRTY_ACCSS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_PRTY_ACCSS_PVT" AS
/* $Header: IBEVMPRB.pls 120.0 2005/05/30 02:17:13 appldev noship $ */

  -- HISTORY
  --   12/13/02           SCHAK         Modified for NOCOPY (Bug # 2691704)  Changes.
  -- *********************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_PRTY_ACCSS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVMPRB.pls';

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
    AND master_msite_flag = 'N';

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

PROCEDURE Validate_Prty_Id_Exists
  (
   p_party_id                       IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Prty_Id_Exists';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_party_id IN NUMBER)
  IS SELECT party_id FROM hz_parties
    WHERE party_id = l_c_party_id;

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if party_id exists in hz_parties
  OPEN c1(p_party_id);
  FETCH c1 INTO l_tmp_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PARTY_NOT_FOUND');
    FND_MESSAGE.Set_Token('PARTY_ID', p_party_id);
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

END Validate_Prty_Id_Exists;

PROCEDURE Validate_Msite_Prty_Id_Exists
  (
   p_msite_prty_accss_id            IN NUMBER,
   p_msite_id                       IN NUMBER,
   p_party_id                       IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Msite_Prty_Id_Exists';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_msite_prty_accss_id IN NUMBER)
  IS SELECT msite_prty_accss_id FROM ibe_msite_prty_accss
    WHERE msite_prty_accss_id = l_c_msite_prty_accss_id;

  CURSOR c2(l_c_msite_id IN NUMBER, l_c_party_id IN NUMBER)
  IS SELECT msite_prty_accss_id FROM ibe_msite_prty_accss
    WHERE msite_id = l_c_msite_id
    AND party_id = l_c_party_id;

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if msite_prty_accss_id or combination of msite_id and party_id
  -- in ibe_msite_prty_accss
  IF ((p_msite_prty_accss_id IS NOT NULL) AND
      (p_msite_prty_accss_id <> FND_API.G_MISS_NUM))
  THEN

    OPEN c1(p_msite_prty_accss_id);
    FETCH c1 INTO l_tmp_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_PRTY_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_PRTY_ACCSS_ID', p_msite_prty_accss_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_party_id IS NOT NULL)                    AND
         (p_party_id <> FND_API.G_MISS_NUM))
  THEN

    OPEN c2(p_msite_id, p_party_id);
    FETCH c2 INTO l_tmp_id;
    IF (c2%NOTFOUND) THEN
      CLOSE c2;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITEPRTY_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('PARTY_ID', p_party_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c2;

  ELSE
    -- neither msite_prty_accss_id nor combination of
    -- msite_id and party_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MP_IDS_SPEC');
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

END Validate_Msite_Prty_Id_Exists;

PROCEDURE Validate_Create
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_party_id                       IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Validate_Create';
  l_api_version             CONSTANT NUMBER       := 1.0;

  l_msite_prty_accss_id           NUMBER;
  l_msite_id                      NUMBER;
  l_party_id                      NUMBER;

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

  -- p_party_id
  IF ((p_party_id IS NULL) OR
      (p_party_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVALID_PRTY_ID');
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

  -- party_id
  Validate_Prty_Id_Exists
    (
    p_party_id                       => p_party_id,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PRTY_ID_VLD_FAIL');
    FND_MESSAGE.Set_Token('PARTY_ID', p_party_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PRTY_ID_VLD_FAIL');
    FND_MESSAGE.Set_Token('PARTY_ID', p_party_id);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- p_msite_id, p_party_id (check for duplicate)
  Validate_Msite_Prty_Id_Exists
    (
    p_msite_prty_accss_id            => FND_API.G_MISS_NUM,
    p_msite_id                       => p_msite_id,
    p_party_id                       => p_party_id,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSPRT_ID_VLD_FAIL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN -- duplicate exists
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSPRT_ID_DUP_EXISTS');
    FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
    FND_MESSAGE.Set_Token('PARTY_ID', p_party_id);
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

END Validate_Create;

PROCEDURE Validate_Update
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_prty_accss_id            IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Update';
  l_api_version           CONSTANT NUMBER       := 1.0;

  l_msite_prty_accss_id         NUMBER;
  l_msite_id                    NUMBER;
  l_party_id                    NUMBER;

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

  -- msite_prty_accss_id
  IF (p_msite_prty_accss_id IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSPRT_ID_IS_NULL');
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

  --
  -- non-null field validation
  --

  -- check if the association already exists, if not, then throw error
  Validate_Msite_Prty_Id_Exists
  (
   p_msite_prty_accss_id            => p_msite_prty_accss_id,
   p_msite_id                       => FND_API.G_MISS_NUM,
   p_party_id                       => FND_API.G_MISS_NUM,
   x_return_status                  => x_return_status,
   x_msg_count                      => x_msg_count,
   x_msg_data                       => x_msg_data
  );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSPRT_ID_VLD_FAIL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSPRT_ID_VLD_FAIL');
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


PROCEDURE Create_Msite_Prty_Accss
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_party_id                       IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   x_msite_prty_accss_id            OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Msite_Prty_Accss';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT create_msite_prty_accss_pvt;

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
    p_party_id                       => p_party_id,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MP_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MP_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  --
  -- 2. Insert row
  --
  BEGIN
    Ibe_Msite_Prty_Accss_Pkg.insert_row
      (
      p_msite_prty_accss_id                => FND_API.G_MISS_NUM,
      p_object_version_number              => l_object_version_number,
      p_msite_id                           => p_msite_id,
      p_party_id                           => p_party_id,
      p_start_date_active                  => p_start_date_active,
      p_end_date_active                    => p_end_date_active,
      p_creation_date                      => sysdate,
      p_created_by                         => FND_GLOBAL.user_id,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id,
      x_rowid                              => l_rowid,
      x_msite_prty_accss_id                => x_msite_prty_accss_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_PRTY_INSERT_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_PRTY_INSERT_FL');
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
     ROLLBACK TO create_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO create_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_Msite_Prty_Accss;

PROCEDURE Update_Msite_Prty_Accss
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_prty_accss_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_msite_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_party_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Msite_Prty_Accss';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_msite_prty_accss_id     NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_party_id IN NUMBER)
  IS SELECT msite_prty_accss_id FROM ibe_msite_prty_accss
    WHERE msite_id = l_c_msite_id
    AND party_id = l_c_party_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT update_msite_prty_accss_pvt;

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

  -- 1a. Check if either msite_prty_accss_id or combination of
  --    msite_id and party_id is specified
  IF ((p_msite_prty_accss_id IS NOT NULL) AND
      (p_msite_prty_accss_id <> FND_API.G_MISS_NUM))
  THEN
    -- msite_prty_accss_id specified, continue
    l_msite_prty_accss_id := p_msite_prty_accss_id;
  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_party_id IS NOT NULL)                    AND
         (p_party_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of msite_id and party_id
    -- is specified, then query for msite_prty_accss_id

    OPEN c1(p_msite_id, p_party_id);
    FETCH c1 INTO l_msite_prty_accss_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITEPRTY_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('PARTY_ID', p_party_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSE
    -- neither msite_prty_accss_id nor combination of
    -- msite_id and party_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MP_IDS_SPEC');
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
    p_msite_prty_accss_id            => l_msite_prty_accss_id,
    p_object_version_number          => p_object_version_number,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MP_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MP_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  -- 2. update row with section data into section table
  BEGIN
    Ibe_Msite_Prty_Accss_Pkg.update_row
      (
      p_msite_prty_accss_id                => l_msite_prty_accss_id,
      p_object_version_number              => p_object_version_number,
      p_start_date_active                  => p_start_date_active,
      p_end_date_active                    => p_end_date_active,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_PRTY_UPDATE_FL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_PRTY_UPDATE_FL');
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
     ROLLBACK TO update_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO update_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Msite_Prty_Accss;

PROCEDURE Delete_Msite_Prty_Accss
  (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                      IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level            IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_msite_prty_accss_id         IN NUMBER      := FND_API.G_MISS_NUM,
   p_msite_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   p_party_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_Msite_Prty_Accss';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_msite_prty_accss_id     NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_party_id IN NUMBER)
  IS SELECT msite_prty_accss_id FROM ibe_msite_prty_accss
    WHERE msite_id = l_c_msite_id
    AND party_id = l_c_party_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT delete_msite_prty_accss_pvt;

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

  -- 1a. Check if either msite_prty_accss_id or combination of
  --    msite_id and party_id is specified
  IF ((p_msite_prty_accss_id IS NOT NULL) AND
      (p_msite_prty_accss_id <> FND_API.G_MISS_NUM))
  THEN
    -- msite_prty_accss_id specified, continue
    l_msite_prty_accss_id := p_msite_prty_accss_id;
  ELSIF ((p_msite_id IS NOT NULL)                    AND
         (p_msite_id <> FND_API.G_MISS_NUM)          AND
         (p_party_id IS NOT NULL)           AND
         (p_party_id <> FND_API.G_MISS_NUM))
  THEN
    -- If combination of msite_id and party_id
    -- is specified, then query for msite_prty_accss_id

    OPEN c1(p_msite_id, p_party_id);
    FETCH c1 INTO l_msite_prty_accss_id;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITEPRTY_NOT_FOUND');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('PARTY_ID', p_party_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSE
    -- neither msite_prty_accss_id nor combination of
    -- msite_id and party_id is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MP_IDS_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- delete for ibe_msite_prty_accss
  BEGIN
    Ibe_Msite_Prty_Accss_Pkg.delete_row(l_msite_prty_accss_id);
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_PRTY_DELETE_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSITE_PRTY_DELETE_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO delete_msite_prty_accss_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_Msite_Prty_Accss;

END Ibe_Msite_Prty_Accss_Pvt;

/
