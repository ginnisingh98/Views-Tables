--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_PRTY_ACCSS_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_PRTY_ACCSS_MGR_PVT" AS
/* $Header: IBEVMPMB.pls 120.0 2005/05/30 02:55:43 appldev noship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   Ibe_Msite_Prty_Accss_Mgr_Pvt
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --
  -- HISTORY
  --   01/24/01           VPALAIYA         Created
  --   12/13/02           SCHAK         Modified for NOCOPY (Bug # 2691704)  Changes.
  --   01/10/03           JQU           Delete procedure Get_Party_Id_List for bug 2699536
  --   05/05/03           JQU           Delete procedure Get_Party_Info_For_Lookup for performance bug 2935856
  -- ********************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_PRTY_ACCSS_MGR_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVMPMB.pls';

--
-- Associate (p_party_ids) with p_msite_id.
-- x_is_any_duplicate_status will be FND_API.G_RET_STS_SUCCESS, if there is
-- no duplicate and will be FND_API.G_RET_STS_ERROR when there is at least 1
-- duplicate association attempted
--
PROCEDURE Associate_Parties_To_MSite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_party_ids                      IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   x_msite_prty_accss_ids           OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Associate_Parties_To_MSite';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_tmp_id                       NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_party_id IN NUMBER)
  IS SELECT msite_prty_accss_id FROM ibe_msite_prty_accss
    WHERE msite_id = l_c_msite_id
    AND party_id = l_c_party_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Associate_Parties_To_Msite_Pvt;

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
  x_msite_prty_accss_ids := JTF_NUMBER_TABLE();
  x_is_any_duplicate_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_party_ids.COUNT LOOP

    x_duplicate_association_status.EXTEND();
    x_msite_prty_accss_ids.EXTEND();

    OPEN c1(p_msite_id, p_party_ids(i));
    FETCH c1 INTO l_tmp_id;
    IF(c1%FOUND) THEN
      CLOSE c1;
       -- duplicate exists
      x_duplicate_association_status(i) := FND_API.G_RET_STS_ERROR;
      x_is_any_duplicate_status := FND_API.G_RET_STS_ERROR;
      x_msite_prty_accss_ids(i) := l_tmp_id;
    ELSE
      CLOSE c1;
      -- no duplicate exists, create new entry
      x_duplicate_association_status(i) := FND_API.G_RET_STS_SUCCESS;

      Ibe_Msite_Prty_Accss_Pvt.Create_Msite_Prty_Accss
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_msite_id                       => p_msite_id,
        p_party_id                       => p_party_ids(i),
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        x_msite_prty_accss_id            => x_msite_prty_accss_ids(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_PRTY_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_PRTY_FL');
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
      ROLLBACK TO Associate_Parties_To_Msite_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Associate_Parties_To_Msite_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN OTHERS THEN
      ROLLBACK TO Associate_Parties_To_Msite_Pvt;
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

END Associate_Parties_To_MSite;

--
-- to update and delete multiple entries.
--
PROCEDURE Update_Delete_Msite_Prty
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_prty_accss_ids           IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_msite_ids                      IN JTF_NUMBER_TABLE,
   p_party_ids                      IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_100,
   p_msite_id                       IN NUMBER,
   p_party_access_code              IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Delete_Msite_Prty';
  l_api_version       CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Update_Delete_Msite_Prty_Pvt;

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

  FOR i IN 1..p_msite_prty_accss_ids.COUNT LOOP

    IF (p_delete_flags(i) = 'Y') THEN

      Ibe_Msite_Prty_Accss_Pvt.Delete_Msite_Prty_Accss
        (
        p_api_version                  => p_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        p_validation_level             => p_validation_level,
        p_msite_prty_accss_id          => p_msite_prty_accss_ids(i),
        p_msite_id                     => FND_API.G_MISS_NUM,
        p_party_id                     => FND_API.G_MISS_NUM,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_PRTY_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_PRTY_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE

      Ibe_Msite_Prty_Accss_Pvt.Update_Msite_Prty_Accss
        (
        p_api_version                    => p_api_version,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => p_validation_level,
        p_msite_prty_accss_id            => p_msite_prty_accss_ids(i),
        p_object_version_number          => p_object_version_numbers(i),
        p_msite_id                       => FND_API.G_MISS_NUM,
        p_party_id                       => FND_API.G_MISS_NUM,
        p_start_date_active              => p_start_date_actives(i),
        p_end_date_active                => p_end_date_actives(i),
        x_return_status                  => x_return_status,
        x_msg_count                      => x_msg_count,
        x_msg_data                       => x_msg_data
        );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_PRTY_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_PRTY_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END LOOP; -- end for i

  --
  -- Update ibe_msites_b's party_access_code flag
  --
  -- Check for validity of party access code
  IF ((p_party_access_code IS NULL) OR
      (p_party_access_code = FND_API.G_MISS_CHAR))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVLD_PRTY_ACSS_CODE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN
    UPDATE ibe_msites_b
      SET party_access_code = p_party_access_code
      WHERE msite_id = p_msite_id;
  EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PRTY_ACCSS_CODE_FAIL');
       FND_MESSAGE.Set_Token('PARTY_ACCESS_CODE', p_party_access_code);
       FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

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
     ROLLBACK TO Update_Delete_Msite_Prty_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Delete_Msite_Prty_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO Update_Delete_Msite_Prty_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Delete_Msite_Prty;

--
-- Return data (association + minisite data + party data) belonging to
-- the p_msite_id
--
PROCEDURE Load_MsiteParties_For_Msite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   x_party_access_code_csr          OUT NOCOPY PARTY_ACCESS_CODE_CSR,
   x_msite_csr                      OUT NOCOPY MSITE_CSR,
   x_msite_prty_accss_csr           OUT NOCOPY MSITE_PRTY_ACCSS_CSR,
   x_cust_account_csr               OUT NOCOPY CUST_ACCOUNT_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_MsiteParties_For_Msite';
  l_api_version             CONSTANT NUMBER       := 1.0;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the party access code data
  OPEN x_party_access_code_csr FOR SELECT lookup_code, meaning
    FROM fnd_lookups
    WHERE lookup_type = 'IBE_PARTY_ACCESS_CODE'
    ORDER BY lookup_code;

  -- Get the mini-site data
  OPEN x_msite_csr FOR SELECT msite_id, msite_name, party_access_code
    FROM ibe_msites_vl
    WHERE msite_id = p_msite_id and site_type = 'I';

  -- Get the msite-party access data and party data
  OPEN x_msite_prty_accss_csr FOR SELECT MP.msite_prty_accss_id,
    MP.object_version_number, MP.msite_id, MP.party_id,
    P.party_name, P.party_type, L.meaning, MP.start_date_active,
    MP.end_date_active
    FROM ibe_msite_prty_accss MP, hz_parties P, ar_lookups L
    WHERE MP.msite_id = p_msite_id
    AND MP.party_id = P.party_id
    AND P.party_type = 'ORGANIZATION'
    AND L.lookup_type = 'PARTY_TYPE'
    AND P.party_type = L.lookup_code;

  -- Get the party account data
  OPEN x_cust_account_csr FOR SELECT party_id, account_number
    FROM hz_cust_accounts_all
    WHERE status = 'A' and party_id IN
    (SELECT party_id FROM ibe_msite_prty_accss
    WHERE msite_id = p_msite_id)
    ORDER BY party_id, account_number;

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

END Load_MsiteParties_For_Msite;

END Ibe_Msite_Prty_Accss_Mgr_Pvt;

/
