--------------------------------------------------------
--  DDL for Package Body AS_TCA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_TCA_PVT" as
/* $Header: asxvtcab.pls 120.0 2005/06/02 17:15:57 appldev noship $ */

--
-- NAME
--   AS_TCA_PVT
--
-- HISTORY
--  05/19/00       ACNG     Create
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_TCA_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxvtca1.pls';
G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;

-- Procedure to validate the party_id
--
-- Validation:
--    Check if this party is in the HZ_PARTY table
--
-- NOTES:
--
PROCEDURE Validate_party_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          x_return_status       OUT NOCOPY     VARCHAR2,
          x_msg_count           OUT NOCOPY     NUMBER,
          x_msg_data            OUT NOCOPY     VARCHAR2
) IS

  l_val            VARCHAR2(1);
  l_return_status  VARCHAR2(1);

  CURSOR C_Party_Exists (X_Party_Id NUMBER) IS
  SELECT  1
  FROM  AS_PARTY_CUSTOMERS_V
  WHERE party_id = X_Party_Id;

BEGIN

  -- initialize message list if p_init_msg_list is set to TRUE;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  open C_Party_Exists(p_party_id);
  fetch C_Party_Exists into l_val;
  IF (C_Party_Exists%NOTFOUND) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
        FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID', FALSE);
        FND_MESSAGE.Set_Token('VALUE',p_party_id,FALSE);
	FND_MSG_PUB.ADD;
     END IF;
  END IF;
  close C_Party_Exists;

  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_party_id;

-- Procedure to validate the party__site_id
--
-- Validation:
--    Check if this party is in the HZ_PARTY_SITES table
--
-- NOTES:
--
PROCEDURE Validate_party_site_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          p_party_site_id       IN       NUMBER,
          x_return_status       OUT NOCOPY     VARCHAR2,
          x_msg_count           OUT NOCOPY     NUMBER,
          x_msg_data            OUT NOCOPY     VARCHAR2
) IS

  l_val            VARCHAR2(1);
  l_return_status  VARCHAR2(1);

  CURSOR C_Party_Site_Exists (X_Party_Id NUMBER, X_Party_Site_Id NUMBER) IS
  SELECT  1
  FROM  AS_PARTY_ADDRESSES_V
  WHERE party_id = X_Party_Id
  AND party_site_id = X_Party_Site_Id;

BEGIN

  -- initialize message list if p_init_msg_list is set to TRUE;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  open C_Party_Site_Exists(p_party_id, p_party_site_id);
  fetch C_Party_Site_Exists into l_val;
  IF (C_Party_Site_Exists%NOTFOUND) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
        FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'PARTY_SITE_ID', FALSE);
        FND_MSG_PUB.ADD;
     END IF;
  END IF;
  close C_Party_Site_Exists;

  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_party_site_id;

-- Procedure to validate the contact_point_id
--
-- Validation:
--
-- NOTES:
--
PROCEDURE Validate_contact_point_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          p_org_contact_id      IN       NUMBER,
		p_contact_point_id    IN       NUMBER,
          x_return_status       OUT NOCOPY     VARCHAR2,
          x_msg_count           OUT NOCOPY     NUMBER,
          x_msg_data            OUT NOCOPY     VARCHAR2
) IS

  l_val            VARCHAR2(1);
  l_return_status  VARCHAR2(1);

  CURSOR C_Party_Cnt_Point_Exists (X_Party_Id NUMBER, X_Contact_Point_Id NUMBER) IS
  SELECT 1
  FROM  AS_PARTY_PHONES_V
  WHERE contact_point_id = X_Contact_Point_Id
  AND owner_table_id = X_Party_Id
  AND owner_table_name = 'HZ_PARTIES';

  CURSOR C_Org_Contact_Cnt_Point_Exists (X_Org_Contact_Id NUMBER, X_Contact_Point_Id NUMBER) IS
  SELECT 1
  FROM JTF_PARTY_PHONES_V
  WHERE org_contact_id = X_Org_Contact_Id
  AND contact_point_id = X_Contact_Point_Id;

BEGIN

  -- initialize message list if p_init_msg_list is set to TRUE;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  If(p_org_contact_id is NULL) then
     open C_Party_Cnt_Point_Exists(p_party_id, p_contact_point_id);
     fetch C_Party_Cnt_Point_Exists into l_val;
     IF (C_Party_Cnt_Point_Exists%NOTFOUND) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
           FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
           FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID', FALSE);
           FND_MSG_PUB.ADD;
        END IF;
     END IF;
     close C_Party_Cnt_Point_Exists;
  elsIf(p_party_id is NULL)then
     open C_Org_Contact_Cnt_Point_Exists(p_org_contact_id, p_contact_point_id);
     fetch C_Org_Contact_Cnt_Point_Exists into l_val;
     IF (C_Org_Contact_Cnt_Point_Exists%NOTFOUND) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
           FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
           FND_MESSAGE.Set_Token('COLUMN', 'ORG_CONTACT_ID', FALSE);
           FND_MSG_PUB.ADD;
        END IF;
     END IF;
     close C_Org_Contact_Cnt_Point_Exists;
  else
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
        FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID', FALSE);
        FND_MSG_PUB.ADD;
        FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'ORG_CONTACT_ID', FALSE);
        FND_MSG_PUB.ADD;
     END IF;
  end if;


  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_contact_point_id;

-- Procedure to validate the contact_id
--
-- Validation:
--
-- NOTES:
--
PROCEDURE Validate_contact_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
		p_contact_id          IN       NUMBER,
          x_return_status       OUT NOCOPY     VARCHAR2,
          x_msg_count           OUT NOCOPY     NUMBER,
          x_msg_data            OUT NOCOPY     VARCHAR2
) IS

  l_val            VARCHAR2(1);
  l_return_status  VARCHAR2(1);

  CURSOR C_Contact_Exists (X_Contact_Id NUMBER, X_Party_id NUMBER) IS
  SELECT  1
  FROM  AS_PARTY_ORG_CONTACTS_V
  WHERE contact_id = X_Contact_Id
  AND party_id = X_Party_Id;

BEGIN

  -- initialize message list if p_init_msg_list is set to TRUE;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  open C_Contact_Exists(p_contact_id, p_party_id);
  fetch C_Contact_Exists into l_val;
  IF (C_Contact_Exists%NOTFOUND) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
        FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID', FALSE);
        FND_MSG_PUB.ADD;
     END IF;
  END IF;
  close C_Contact_Exists;

  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_contact_id;

END AS_TCA_PVT;

/
