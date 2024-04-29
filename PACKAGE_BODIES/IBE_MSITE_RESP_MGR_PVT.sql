--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_RESP_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_RESP_MGR_PVT" AS
/* $Header: IBEVMRMB.pls 120.0.12010000.3 2016/10/18 20:24:57 ytian ship $ */



G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_RESP_MGR_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVMRMB.pls';
l_true       VARCHAR2(1)            := FND_API.G_TRUE;
--
-- Associate (p_responsibility_ids, p_application_ids) with p_msite_id.
-- x_is_any_duplicate_status will be FND_API.G_RET_STS_SUCCESS, if there is
-- no duplicate and will be FND_API.G_RET_STS_ERROR when there is at least 1
-- duplicate association attempted
--
PROCEDURE Associate_Resps_To_MSite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_responsibility_ids             IN JTF_NUMBER_TABLE,
   p_application_ids                IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   x_msite_resp_ids                 OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Resps_To_MSite';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_tmp_id                       NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
    l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id FROM ibe_msite_resps_b
    WHERE msite_id = l_c_msite_id
    AND responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Associate_Resps_To_Msite_Pvt;

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

  -- Check if the association already exists. Populate the
  -- x_duplicate_association_status with the appropriate information
  x_duplicate_association_status := JTF_VARCHAR2_TABLE_100();
  x_msite_resp_ids := JTF_NUMBER_TABLE();
  x_is_any_duplicate_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_responsibility_ids.COUNT LOOP

    x_duplicate_association_status.EXTEND();
    x_msite_resp_ids.EXTEND();

    OPEN c1(p_msite_id, p_responsibility_ids(i), p_application_ids(i));
    FETCH c1 INTO l_tmp_id;
    IF(c1%FOUND) THEN
      CLOSE c1;
       -- duplicate exists
      x_duplicate_association_status(i) := FND_API.G_RET_STS_ERROR;
      x_is_any_duplicate_status := FND_API.G_RET_STS_ERROR;
      x_msite_resp_ids(i) := l_tmp_id;
    ELSE
      CLOSE c1;
      -- no duplicate exists, create new entry
      x_duplicate_association_status(i) := FND_API.G_RET_STS_SUCCESS;

      Ibe_Msite_Resp_Pvt.Create_Msite_Resp
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_msite_resp_id			 => FND_API.G_MISS_NUM,
        p_msite_id                       => p_msite_id,
        p_responsibility_id              => p_responsibility_ids(i),
        p_application_id                 => p_application_ids(i),
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_sort_order                     => p_sort_orders(i),
        p_display_name                   => p_display_names(i),
        x_msite_resp_id                  => x_msite_resp_ids(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

  END LOOP; -- end for i

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
      ROLLBACK TO Associate_Resps_To_Msite_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Associate_Resps_To_Msite_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN OTHERS THEN
      ROLLBACK TO Associate_Resps_To_Msite_Pvt;
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

END Associate_Resps_To_MSite;


PROCEDURE Associate_Resps_To_MSite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_responsibility_ids             IN JTF_NUMBER_TABLE,
   p_application_ids                IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   p_ordertype_ids                IN JTF_NUMBER_TABLE,
   x_msite_resp_ids                 OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Resps_To_MSite';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_tmp_id                       NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
    l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id FROM ibe_msite_resps_b
    WHERE msite_id = l_c_msite_id
    AND responsibility_id = l_c_responsibility_id
    AND application_id = l_c_application_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Associate_Resps_To_Msite_Pvt;

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

  -- Check if the association already exists. Populate the
  -- x_duplicate_association_status with the appropriate information
  x_duplicate_association_status := JTF_VARCHAR2_TABLE_100();
  x_msite_resp_ids := JTF_NUMBER_TABLE();
  x_is_any_duplicate_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_responsibility_ids.COUNT LOOP

    x_duplicate_association_status.EXTEND();
    x_msite_resp_ids.EXTEND();

    OPEN c1(p_msite_id, p_responsibility_ids(i), p_application_ids(i));
    FETCH c1 INTO l_tmp_id;
    IF(c1%FOUND) THEN
      CLOSE c1;
       -- duplicate exists
      x_duplicate_association_status(i) := FND_API.G_RET_STS_ERROR;
      x_is_any_duplicate_status := FND_API.G_RET_STS_ERROR;
      x_msite_resp_ids(i) := l_tmp_id;
    ELSE
      CLOSE c1;
      -- no duplicate exists, create new entry
      x_duplicate_association_status(i) := FND_API.G_RET_STS_SUCCESS;

      Ibe_Msite_Resp_Pvt.Create_Msite_Resp
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_msite_resp_id			 => FND_API.G_MISS_NUM,
        p_msite_id                       => p_msite_id,
        p_responsibility_id              => p_responsibility_ids(i),
        p_application_id                 => p_application_ids(i),
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_sort_order                     => p_sort_orders(i),
        p_display_name                   => p_display_names(i),
        p_ordertype_id                   => p_ordertype_ids(i),
        x_msite_resp_id                  => x_msite_resp_ids(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

  END LOOP; -- end for i

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
      ROLLBACK TO Associate_Resps_To_Msite_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Associate_Resps_To_Msite_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN OTHERS THEN
      ROLLBACK TO Associate_Resps_To_Msite_Pvt;
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

END Associate_Resps_To_MSite;

--
-- to update and delete multiple entries.
--
PROCEDURE Update_Delete_Msite_Resps
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_ids                 IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_100,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Delete_Msite_Resps';
  l_api_version       CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Update_Delete_Msite_Resps_Pvt;

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

  FOR i IN 1..p_msite_resp_ids.COUNT LOOP

    IF (p_delete_flags(i) = 'Y') THEN

      Ibe_Msite_Resp_Pvt.Delete_Msite_Resp
        (
        p_api_version                  => p_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        p_validation_level             => p_validation_level,
        p_msite_resp_id                => p_msite_resp_ids(i),
        p_msite_id                     => FND_API.G_MISS_NUM,
        p_responsibility_id            => FND_API.G_MISS_NUM,
        p_application_id               => FND_API.G_MISS_NUM,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE

      Ibe_Msite_Resp_Pvt.Update_Msite_Resp
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_msite_resp_id                  => p_msite_resp_ids(i),
        p_object_version_number          => p_object_version_numbers(i),
        p_msite_id                       => FND_API.G_MISS_NUM,
        p_responsibility_id              => FND_API.G_MISS_NUM,
        p_application_id                 => FND_API.G_MISS_NUM,
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_sort_order                     => p_sort_orders(i),
	p_display_name                   => p_display_names(i),
        p_group_code 			 => FND_API.G_MISS_CHAR,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END LOOP; -- end for i

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
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Delete_Msite_Resps;

--
-- to update and delete multiple entries.
--
PROCEDURE Update_Delete_Msite_Resps
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_ids                 IN JTF_NUMBER_TABLE,
   p_msite_ids 			    IN JTF_NUMBER_TABLE,
   p_responsibility_ids 	    IN JTF_NUMBER_TABLE,
   p_application_ids		    IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   p_group_codes                    IN JTF_VARCHAR2_TABLE_300,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_100,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Delete_Msite_Resps';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msite_resp_id     NUMBER;
  l_group_code        VARCHAR2(80);
  l_msite_resp_ids    JTF_NUMBER_TABLE;

  Cursor c_msite_resp_group (l_msite_resp_id Number)
  Is Select group_code
  From ibe_msite_resps_b
  where msite_resp_id = l_msite_resp_id;

BEGIN

  l_msite_resp_ids := JTF_NUMBER_TABLE();

  -- Standard Start of API savepoint
  SAVEPOINT  Update_Delete_Msite_Resps_Pvt;

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

  FOR i IN 1..p_msite_resp_ids.COUNT LOOP
    l_msite_resp_ids.EXTEND();

    IF (p_delete_flags(i) = 'Y') THEN

      Ibe_Msite_Resp_Pvt.Delete_Msite_Resp
        (
        p_api_version                  => p_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        p_validation_level             => p_validation_level,
        p_msite_resp_id                => p_msite_resp_ids(i),
        p_msite_id                     => FND_API.G_MISS_NUM,
        p_responsibility_id            => FND_API.G_MISS_NUM,
        p_application_id               => FND_API.G_MISS_NUM,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSIF (p_delete_flags(i) = 'IG') THEN

      Open C_msite_resp_group(p_msite_resp_ids(i));
      Fetch C_msite_resp_group INTO l_group_code;
      CLOSE c_msite_resp_group;

      IF (l_group_code is null) THEN

        Ibe_Msite_Resp_Pvt.Update_Msite_Resp
          (
          p_api_version                    => p_api_version,
          p_init_msg_list                  => FND_API.G_FALSE,
          p_commit                         => FND_API.G_FALSE,
          p_validation_level               => p_validation_level,
          p_msite_resp_id                  => p_msite_resp_ids(i),
          p_object_version_number          => p_object_version_numbers(i),
          p_msite_id                       => FND_API.G_MISS_NUM,
          p_responsibility_id              => FND_API.G_MISS_NUM,
          p_application_id                 => FND_API.G_MISS_NUM,
          p_start_date_active              => p_start_date_actives(i),
          p_end_date_active                => p_end_date_actives(i),
          p_sort_order                     => p_sort_orders(i),
	  p_display_name                   => p_display_names(i),
          p_group_code 			   => p_group_codes(i),
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data
          );

      	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      ELSE

	Ibe_Msite_Resp_Pvt.Create_Msite_Resp
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
	p_msite_resp_id			 => p_msite_resp_ids(i),
        p_msite_id                       => p_msite_ids(i),
        p_responsibility_id              => p_responsibility_ids(i),
        p_application_id                 => p_application_ids(i),
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_sort_order                     => p_sort_orders(i),
        p_display_name                   => p_display_names(i),
        p_group_code			 => p_group_codes(i),
	x_msite_resp_id                  => l_msite_resp_ids(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      	IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_RESP_FL');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_RESP_FL');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

    ELSIF (p_delete_flags(i) = 'DG') THEN

      Ibe_Msite_Resp_Pvt.Delete_Msite_Resp_Group
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_msite_resp_id                  => p_msite_resp_ids(i),
        p_msite_id                       => FND_API.G_MISS_NUM,
        p_responsibility_id              => FND_API.G_MISS_NUM,
        p_application_id                 => FND_API.G_MISS_NUM,
        p_group_code             	 => p_group_codes(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSIF (p_delete_flags(i) = 'N') THEN
    	NULL;
    END IF;
  END LOOP; -- end for i

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
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Delete_Msite_Resps;



--
-- to update and delete multiple entries.
--
PROCEDURE Update_Delete_Msite_Resps
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_ids                 IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_100,
   p_order_type_ids                 IN JTF_NUMBER_TABLE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Delete_Msite_Resps';
  l_api_version       CONSTANT NUMBER       := 1.0;

BEGIN


  -- Standard Start of API savepoint
  SAVEPOINT  Update_Delete_Msite_Resps_Pvt;

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

  FOR i IN 1..p_msite_resp_ids.COUNT LOOP

    IF (p_delete_flags(i) = 'Y') THEN

      Ibe_Msite_Resp_Pvt.Delete_Msite_Resp
        (
        p_api_version                  => p_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        p_validation_level             => p_validation_level,
        p_msite_resp_id                => p_msite_resp_ids(i),
        p_msite_id                     => FND_API.G_MISS_NUM,
        p_responsibility_id            => FND_API.G_MISS_NUM,
        p_application_id               => FND_API.G_MISS_NUM,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE


      Ibe_Msite_Resp_Pvt.Update_Msite_Resp
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => p_commit,
        p_validation_level               => p_validation_level,
        p_msite_resp_id                  => p_msite_resp_ids(i),
        p_object_version_number          => p_object_version_numbers(i),
        p_msite_id                       => FND_API.G_MISS_NUM,
        p_responsibility_id              => FND_API.G_MISS_NUM,
        p_application_id                 => FND_API.G_MISS_NUM,
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        p_sort_order                     => p_sort_orders(i),
	p_display_name                   => p_display_names(i),
        p_group_code 			 => FND_API.G_MISS_CHAR,
        p_order_type_id                  => p_order_type_ids(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END LOOP; -- end for i

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
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Delete_Msite_Resps;
--
-- Return data (association + minisite data + responsibility data) belonging to
-- the p_msite_id and to a particular p_application_id. If p_application_id is
-- -1, NULL, or FND_API.G_MISS_NUM, then load for all applications
--
PROCEDURE Load_MsiteResps_For_Msite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_application_id                 IN NUMBER,
   x_msite_csr                      OUT NOCOPY MSITE_CSR,
   x_msite_resp_csr                 OUT NOCOPY MSITE_RESP_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_MsiteResps_For_Msite';
  l_api_version             CONSTANT NUMBER       := 1.0;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the mini-site data
  OPEN x_msite_csr FOR SELECT msite_name, msite_description
    FROM ibe_msites_vl
    WHERE msite_id = p_msite_id and site_type = 'I';

  -- Get the msite-resp data and resp data
  IF (p_application_id = -1 OR
      p_application_id IS NULL OR
      p_application_id = fnd_api.g_miss_num)
  THEN

    OPEN x_msite_resp_csr FOR SELECT MR.msite_resp_id,
      MR.object_version_number, R.responsibility_id, R.application_id,
      MR.display_name, A.application_name,
      R.responsibility_key, R.responsibility_name, MR.start_date_active,
      MR.end_date_active, MR.sort_order
      FROM ibe_msite_resps_vl MR, fnd_responsibility_vl R, fnd_application_vl A
      WHERE MR.msite_id = p_msite_id
      AND MR.responsibility_id = R.responsibility_id
      AND MR.application_id = R.application_id
      AND R.application_id = A.application_id;

  ELSE

    OPEN x_msite_resp_csr FOR SELECT MR.msite_resp_id,
      MR.object_version_number, R.responsibility_id, R.application_id,
      MR.display_name, A.application_name,
      R.responsibility_key, R.responsibility_name, MR.start_date_active,
      MR.end_date_active, MR.sort_order
      FROM ibe_msite_resps_vl MR, fnd_responsibility_vl R, fnd_application_vl A
      WHERE MR.msite_id = p_msite_id
      AND MR.application_id = p_application_id
      AND MR.responsibility_id = R.responsibility_id
      AND MR.application_id = R.application_id
      AND R.application_id = A.application_id;

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

END Load_MsiteResps_For_Msite;


--
-- to sort multiple entries.
--
PROCEDURE Update_Msite_Resps
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_ids                 IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Msite_Resps';
  l_api_version       CONSTANT NUMBER       := 1.0;


BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Update_Msite_Resps_Pvt;

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

  FOR i IN 1..p_msite_resp_ids.COUNT LOOP


    Ibe_Msite_Resp_Pvt.Update_Msite_Resp
      (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_msite_resp_id                  => p_msite_resp_ids(i),
        p_object_version_number          => p_object_version_numbers(i),
        p_msite_id                       => FND_API.G_MISS_NUM,
        p_responsibility_id              => FND_API.G_MISS_NUM,
        p_application_id                 => FND_API.G_MISS_NUM,
        p_start_date_active              => FND_API.G_MISS_DATE,
        p_end_date_active                => FND_API.G_MISS_DATE,
        p_sort_order                     => p_sort_orders(i),
        p_display_name                   => FND_API.G_MISS_CHAR,
	p_group_code			 => FND_API.G_MISS_CHAR,
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
      );


    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_RESP_FL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  END LOOP; -- end for i

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
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO Update_Delete_Msite_Resps_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Msite_Resps;


END Ibe_Msite_Resp_Mgr_Pvt;

/
