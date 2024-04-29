--------------------------------------------------------
--  DDL for Package Body JTF_MSITE_RESP_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MSITE_RESP_MGR_PVT" AS
/* $Header: JTFVMRMB.pls 115.2 2001/04/09 11:33:41 pkm ship      $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   Jtf_Msite_Resp_Mgr_Pvt
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --
  -- HISTORY
  --   01/24/01           VPALAIYA         Created
  --   04/06/01           SSRIDHAR         Modified
  --   the query criteria string in Get_Resp_Appl_Id_List should be
  --   DESC and not DESCRIPTION, as the UI is passing DESC.
  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'JTF_MSITE_RESP_MGR_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'JTFVMRMB.pls';

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
   x_msite_resp_ids                 OUT JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT VARCHAR2,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Resps_To_MSite';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_tmp_id                       NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_responsibility_id IN NUMBER,
    l_c_application_id IN NUMBER)
  IS SELECT msite_resp_id FROM jtf_msite_resps_b
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

      Jtf_Msite_Resp_Pvt.Create_Msite_Resp
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
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
        FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_CREATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_CREATE_MSITE_RESP_FL');
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
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
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

      Jtf_Msite_Resp_Pvt.Delete_Msite_Resp
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
        FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_DELETE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE

      Jtf_Msite_Resp_Pvt.Update_Msite_Resp
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
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_UPDATE_MSITE_RESP_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_UPDATE_MSITE_RESP_FL');
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
   x_msite_csr                      OUT MSITE_CSR,
   x_msite_resp_csr                 OUT MSITE_RESP_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
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
    FROM jtf_msites_vl
    WHERE msite_id = p_msite_id;

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
      FROM jtf_msite_resps_vl MR, fnd_responsibility_vl R, fnd_application_vl A
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
      FROM jtf_msite_resps_vl MR, fnd_responsibility_vl R, fnd_application_vl A
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
-- Get the cursor which returns the (responsibility_id, application_id)
-- based on the query criteria and the query value
--
-- Query criteria (p_query_criteria) can have the following values:
--   1. NAME                    (uses p_criteria_value_str)
--   2. KEY                     (uses p_criteria_value_str)
--   3. DESCRIPTION             (uses p_criteria_value_str)
--
-- p_criteria_value_str will be passed as input if the criteria value is string
-- Note: p_criteria_value_str might have "'" in it, so we are calling to
-- replace any "'" with "''" so that the SQL query is constructed ok
--
PROCEDURE Get_Resp_Appl_Id_List
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_query_criteria                 IN VARCHAR2,
   p_criteria_value_str             IN VARCHAR2,
   p_application_id                 IN NUMBER,
   x_responsibility_csr             OUT RESPONSIBILITY_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Resp_Appl_Id_List';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_db_sql                       VARCHAR2(2000);
  l_criteria_value_str           VARCHAR2(256);
  l_application_id_sql_str       VARCHAR2(30);

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
  -- Assign criteria value to local variable (so that it can be modified)
  --
  l_criteria_value_str := p_criteria_value_str;

  --
  -- Handle null value of criteria value
  --
  IF (l_criteria_value_str IS NULL) THEN
    l_criteria_value_str := '%';
  END IF;

  --
  -- Replace any occurence of "'" with "''", so that the SQL query
  -- constructed is OK
  --
  l_criteria_value_str := replace(l_criteria_value_str, '''', '''''');

  --
  -- If p_application_id is "-1", then search for responsibilities across
  -- all applications, else search for responsibilities under the particular
  -- application_id
  --
  IF ((p_application_id IS NULL) OR
      (p_application_id = FND_API.G_MISS_NUM) OR
      (p_application_id = -1)) THEN
    l_application_id_sql_str := NULL;
  ELSE
    l_application_id_sql_str := ' A.application_id = ' || p_application_id ||
      ' AND ';
  END IF;

  --
  -- Construct the database sql query
  --
  l_db_sql :=
    'SELECT R.responsibility_id, R.application_id FROM fnd_responsibility_vl R, fnd_application_vl A WHERE R.application_id = A.application_id AND ' || l_application_id_sql_str;

  --
  -- Based on the query criteria
  --
  IF (p_query_criteria IS NULL) THEN

    FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_QUERY_CRIT_NULL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  ELSIF (p_query_criteria = 'NAME') THEN

    l_db_sql := l_db_sql || ' UPPER(R.responsibility_name) LIKE ''' ||
                UPPER(l_criteria_value_str) || '''';

  ELSIF (p_query_criteria = 'KEY') THEN

    l_db_sql := l_db_sql || ' UPPER(R.responsibility_key) LIKE ''' ||
                UPPER(l_criteria_value_str) || '''';

  ELSIF (p_query_criteria = 'DESC') THEN

    l_db_sql := l_db_sql || ' UPPER(R.description) LIKE ''' ||
                UPPER(l_criteria_value_str) || '''';

  ELSE
    -- none of the query criteria specified
    FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_INVLD_QUERY_CRIT');
    FND_MESSAGE.Set_Token('QUERY_CRITERIA', p_query_criteria);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Get the responsibility data
  --
  OPEN x_responsibility_csr FOR l_db_sql;

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

END Get_Resp_Appl_Id_List;

--
-- Get the cursor which returns the x_responsibility_csr with info for lookup
-- page for responsibilities in (p_responsibilities_ids, p_application_ids)
--
PROCEDURE Get_Resp_Appl_Info_For_Lookup
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_responsibility_ids             IN JTF_NUMBER_TABLE,
   p_application_ids                IN JTF_NUMBER_TABLE,
   x_responsibility_csr             OUT RESPONSIBILITY_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Resp_Appl_Info_For_Lookup';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_db_sql                       VARCHAR2(2000);
  l_tmp_str                      VARCHAR2(2000);

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
  -- If there are no responsibilities in the input, then return error
  --
  IF (p_responsibility_ids.COUNT <= 0) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_NO_RESPS_SPECIFIED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Prepare the part of the sql query which does selection based on the input
  --
  l_tmp_str := '(';

  FOR i IN 1..p_responsibility_ids.COUNT LOOP

    IF (i <> 1) THEN
      l_tmp_str := l_tmp_str || ' OR ';
    END IF;

    l_tmp_str := l_tmp_str                    ||
                 ' (R.responsibility_id = '   ||
                 p_responsibility_ids(i)      ||
                 ' AND R.application_id = '   ||
                 p_application_ids(i)         || ' ) ';

  END LOOP; -- end loop i

  -- end construction of part of sql query
  l_tmp_str := l_tmp_str || ')';

  --
  -- Construct the database sql query
  --
  l_db_sql :=
    'SELECT R.responsibility_id, R.application_id, A.application_name, R.responsibility_key, R.responsibility_name, R.description, R.start_date, R.end_date FROM fnd_responsibility_vl R, fnd_application_vl A WHERE ' ||
    ' R.application_id = A.application_id AND ' ||
    l_tmp_str;

  --
  -- Get the responsibility data
  --
  OPEN x_responsibility_csr FOR l_db_sql;

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

END Get_Resp_Appl_Info_For_Lookup;


END Jtf_Msite_Resp_Mgr_Pvt;

/
