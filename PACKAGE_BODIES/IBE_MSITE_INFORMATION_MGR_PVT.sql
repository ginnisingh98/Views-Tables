--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_INFORMATION_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_INFORMATION_MGR_PVT" AS
/* $Header: IBEVMIMB.pls 120.0 2005/05/30 03:21:16 appldev noship $ */

  -- HISTORY
  --   12/13/02           SCHAK          Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_INFORMATION_MGR_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVMIMB.pls';

--
--
--
PROCEDURE Change_Msite_Info
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_operation_flags                IN JTF_VARCHAR2_TABLE_100,
   p_msite_information_ids          IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_msite_ids                      IN JTF_NUMBER_TABLE,
   p_msite_information_contexts     IN JTF_VARCHAR2_TABLE_100,
   p_msite_informations1            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations2            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations3            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations4            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations5            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations6            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations7            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations8            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations9            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations10           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations11           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations12           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations13           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations14           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations15           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations16           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations17           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations18           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations19           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations20           IN JTF_VARCHAR2_TABLE_300,
   p_attribute_categorys            IN JTF_VARCHAR2_TABLE_100,
   p_attributes1                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes2                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes3                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes4                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes5                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes6                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes7                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes8                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes9                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes10                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes11                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes12                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes13                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes14                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes15                   IN JTF_VARCHAR2_TABLE_300,
   x_msite_information_ids          OUT NOCOPY JTF_NUMBER_TABLE,
   x_msite_info_return_statuses     OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Change_Msite_Info';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_tmp_id                       NUMBER;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Change_Msite_Info_Pvt;

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

  x_msite_info_return_statuses := JTF_VARCHAR2_TABLE_100();
  x_msite_information_ids := JTF_NUMBER_TABLE();

  FOR i IN 1..p_operation_flags.COUNT LOOP

    x_msite_info_return_statuses.EXTEND();
    x_msite_information_ids.EXTEND();

    x_msite_info_return_statuses(i) := FND_API.G_RET_STS_SUCCESS;

    IF (p_operation_flags(i) = 'C') THEN

      Ibe_Msite_Information_Pvt.Create_Msite_Information
        (
        p_api_version                     => p_api_version,
        p_init_msg_list                   => FND_API.G_FALSE,
        p_commit                          => FND_API.G_FALSE,
        p_validation_level                => p_validation_level,
        p_msite_id                        => p_msite_ids(i),
        p_msite_information_context       => p_msite_information_contexts(i),
        p_msite_information1              => p_msite_informations1(i),
        p_msite_information2              => p_msite_informations2(i),
        p_msite_information3              => p_msite_informations3(i),
        p_msite_information4              => p_msite_informations4(i),
        p_msite_information5              => p_msite_informations5(i),
        p_msite_information6              => p_msite_informations6(i),
        p_msite_information7              => p_msite_informations7(i),
        p_msite_information8              => p_msite_informations8(i),
        p_msite_information9              => p_msite_informations9(i),
        p_msite_information10             => p_msite_informations10(i),
        p_msite_information11             => p_msite_informations11(i),
        p_msite_information12             => p_msite_informations12(i),
        p_msite_information13             => p_msite_informations13(i),
        p_msite_information14             => p_msite_informations14(i),
        p_msite_information15             => p_msite_informations15(i),
        p_msite_information16             => p_msite_informations16(i),
        p_msite_information17             => p_msite_informations17(i),
        p_msite_information18             => p_msite_informations18(i),
        p_msite_information19             => p_msite_informations19(i),
        p_msite_information20             => p_msite_informations20(i),
        p_attribute_category              => p_attribute_categorys(i),
        p_attribute1                      => p_attributes1(i),
        p_attribute2                      => p_attributes2(i),
        p_attribute3                      => p_attributes3(i),
        p_attribute4                      => p_attributes4(i),
        p_attribute5                      => p_attributes5(i),
        p_attribute6                      => p_attributes6(i),
        p_attribute7                      => p_attributes7(i),
        p_attribute8                      => p_attributes8(i),
        p_attribute9                      => p_attributes9(i),
        p_attribute10                     => p_attributes10(i),
        p_attribute11                     => p_attributes11(i),
        p_attribute12                     => p_attributes12(i),
        p_attribute13                     => p_attributes13(i),
        p_attribute14                     => p_attributes14(i),
        p_attribute15                     => p_attributes15(i),
        x_msite_information_id            => x_msite_information_ids(i),
        x_return_status                   => x_msite_info_return_statuses(i),
        x_msg_count                       => x_msg_count,
        x_msg_data                        => x_msg_data
        );

      IF (x_msite_info_return_statuses(i) = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_INFO_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_msite_info_return_statuses(i) = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CREATE_MSITE_INFO_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF (p_operation_flags(i) = 'U') THEN

      Ibe_Msite_Information_Pvt.Update_Msite_Information
        (
        p_api_version                     => p_api_version,
        p_init_msg_list                   => FND_API.G_FALSE,
        p_commit                          => FND_API.G_FALSE,
        p_validation_level                => p_validation_level,
        p_msite_information_id            => p_msite_information_ids(i),
        p_object_version_number           => p_object_version_numbers(i),
        p_msite_information1              => p_msite_informations1(i),
        p_msite_information2              => p_msite_informations2(i),
        p_msite_information3              => p_msite_informations3(i),
        p_msite_information4              => p_msite_informations4(i),
        p_msite_information5              => p_msite_informations5(i),
        p_msite_information6              => p_msite_informations6(i),
        p_msite_information7              => p_msite_informations7(i),
        p_msite_information8              => p_msite_informations8(i),
        p_msite_information9              => p_msite_informations9(i),
        p_msite_information10             => p_msite_informations10(i),
        p_msite_information11             => p_msite_informations11(i),
        p_msite_information12             => p_msite_informations12(i),
        p_msite_information13             => p_msite_informations13(i),
        p_msite_information14             => p_msite_informations14(i),
        p_msite_information15             => p_msite_informations15(i),
        p_msite_information16             => p_msite_informations16(i),
        p_msite_information17             => p_msite_informations17(i),
        p_msite_information18             => p_msite_informations18(i),
        p_msite_information19             => p_msite_informations19(i),
        p_msite_information20             => p_msite_informations20(i),
        p_attribute_category              => p_attribute_categorys(i),
        p_attribute1                      => p_attributes1(i),
        p_attribute2                      => p_attributes2(i),
        p_attribute3                      => p_attributes3(i),
        p_attribute4                      => p_attributes4(i),
        p_attribute5                      => p_attributes5(i),
        p_attribute6                      => p_attributes6(i),
        p_attribute7                      => p_attributes7(i),
        p_attribute8                      => p_attributes8(i),
        p_attribute9                      => p_attributes9(i),
        p_attribute10                     => p_attributes10(i),
        p_attribute11                     => p_attributes11(i),
        p_attribute12                     => p_attributes12(i),
        p_attribute13                     => p_attributes13(i),
        p_attribute14                     => p_attributes14(i),
        p_attribute15                     => p_attributes15(i),
        x_return_status                   => x_msite_info_return_statuses(i),
        x_msg_count                       => x_msg_count,
        x_msg_data                        => x_msg_data
        );

      IF (x_msite_info_return_statuses(i) = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_INFO_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_msite_info_return_statuses(i) = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_UPDATE_MSITE_INFO_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_msite_information_ids(i) := p_msite_information_ids(i);

    ELSIF (p_operation_flags(i) = 'D') THEN

      Ibe_Msite_Information_Pvt.Delete_Msite_Information
        (
        p_api_version                  => p_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        p_validation_level             => p_validation_level,
        p_msite_information_id         => p_msite_information_ids(i),
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data
        );

      IF (x_msite_info_return_statuses(i) = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_INFO_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_msite_info_return_statuses(i) = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_INFO_FL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_msite_information_ids(i) := p_msite_information_ids(i);

    ELSIF (p_operation_flags(i) = 'N') THEN
      -- do nothing
      x_msite_information_ids(i) := p_msite_information_ids(i);
    ELSE
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_INVALID_OP_FLAG');
      FND_MESSAGE.Set_Token('FLAG', p_operation_flags(i));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
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
      ROLLBACK TO Change_Msite_Info_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Change_Msite_Info_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                                p_data       =>      x_msg_data,
                                p_encoded    =>      'F');

    WHEN OTHERS THEN
      ROLLBACK TO Change_Msite_Info_Pvt;
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

END Change_Msite_Info;

--
-- Return data (association + minisite data) belonging to
-- the p_msite_id for the given p_msite_information_context
--
PROCEDURE Load_MsiteInformation
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_msite_information_context      IN VARCHAR2,
   x_msite_csr                      OUT NOCOPY MSITE_CSR,
   x_msite_information_csr          OUT NOCOPY MSITE_INFO_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Load_MsiteInformation';
  l_api_version             CONSTANT NUMBER       := 1.0;
BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the mini-site data
  OPEN x_msite_csr FOR SELECT msite_id, msite_name
    FROM ibe_msites_vl
    WHERE msite_id = p_msite_id and site_type = 'I';

  -- Get the msite-party access data and party data
  OPEN x_msite_information_csr FOR SELECT msite_information_id,
    object_version_number, msite_id, msite_information_context,
    msite_information1, msite_information2, msite_information3,
    msite_information4, msite_information5, msite_information6,
    msite_information7, msite_information8, msite_information9,
    msite_information10, msite_information11, msite_information12,
    msite_information13, msite_information14, msite_information15,
    msite_information16, msite_information17, msite_information18,
    msite_information19, msite_information20, attribute_category, attribute1,
    attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
    attribute8, attribute9, attribute10, attribute11, attribute12,
    attribute13, attribute14, attribute15
    FROM ibe_msite_information
    WHERE msite_id = p_msite_id
    AND msite_information_context = p_msite_information_context;

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

END Load_MsiteInformation;

PROCEDURE duplicate_msite_info(
  p_api_version                    IN NUMBER,
  p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_source_msite_id                IN NUMBER,
  p_target_msite_id                IN NUMBER,
  x_return_status                  OUT NOCOPY VARCHAR2,
  x_msg_count                      OUT NOCOPY NUMBER,
  x_msg_data                       OUT NOCOPY VARCHAR2)
IS
  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'duplicate_msite_info';
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(4000);
  l_debug VARCHAR2(1);
  l_i NUMBER;
  -- For minisite information, such as payment type, credit card
  -- and shipping method
  l_operation_flags JTF_VARCHAR2_TABLE_100;
  l_msite_information_ids JTF_NUMBER_TABLE;
  l_object_version_numbers JTF_NUMBER_TABLE;
  l_msite_ids JTF_NUMBER_TABLE;
  x_msite_information_ids JTF_NUMBER_TABLE;
  x_msite_info_return_statuses JTF_VARCHAR2_TABLE_100;
  l_msite_information_context VARCHAR2(40);
  l_msite_information1 VARCHAR2(150);
  l_msite_information2 VARCHAR2(150);
  l_msite_information3 VARCHAR2(150);
  l_msite_information4 VARCHAR2(150);
  l_msite_information5 VARCHAR2(150);
  l_msite_information6 VARCHAR2(150);
  l_msite_information7 VARCHAR2(150);
  l_msite_information8 VARCHAR2(150);
  l_msite_information9 VARCHAR2(150);
  l_msite_information10 VARCHAR2(150);
  l_msite_information11 VARCHAR2(150);
  l_msite_information12 VARCHAR2(150);
  l_msite_information13 VARCHAR2(150);
  l_msite_information14 VARCHAR2(150);
  l_msite_information15 VARCHAR2(150);
  l_msite_information16 VARCHAR2(150);
  l_msite_information17 VARCHAR2(150);
  l_msite_information18 VARCHAR2(150);
  l_msite_information19 VARCHAR2(150);
  l_msite_information20 VARCHAR2(150);
  l_attribute_category VARCHAR2(30);
  l_attribute1 VARCHAR2(150);
  l_attribute2 VARCHAR2(150);
  l_attribute3 VARCHAR2(150);
  l_attribute4 VARCHAR2(150);
  l_attribute5 VARCHAR2(150);
  l_attribute6 VARCHAR2(150);
  l_attribute7 VARCHAR2(150);
  l_attribute8 VARCHAR2(150);
  l_attribute9 VARCHAR2(150);
  l_attribute10 VARCHAR2(150);
  l_attribute11 VARCHAR2(150);
  l_attribute12 VARCHAR2(150);
  l_attribute13 VARCHAR2(150);
  l_attribute14 VARCHAR2(150);
  l_attribute15 VARCHAR2(150);
  l_msite_information_contexts JTF_VARCHAR2_TABLE_100;
  l_msite_informations1 JTF_VARCHAR2_TABLE_300;
  l_msite_informations2 JTF_VARCHAR2_TABLE_300;
  l_msite_informations3 JTF_VARCHAR2_TABLE_300;
  l_msite_informations4 JTF_VARCHAR2_TABLE_300;
  l_msite_informations5 JTF_VARCHAR2_TABLE_300;
  l_msite_informations6 JTF_VARCHAR2_TABLE_300;
  l_msite_informations7 JTF_VARCHAR2_TABLE_300;
  l_msite_informations8 JTF_VARCHAR2_TABLE_300;
  l_msite_informations9 JTF_VARCHAR2_TABLE_300;
  l_msite_informations10 JTF_VARCHAR2_TABLE_300;
  l_msite_informations11 JTF_VARCHAR2_TABLE_300;
  l_msite_informations12 JTF_VARCHAR2_TABLE_300;
  l_msite_informations13 JTF_VARCHAR2_TABLE_300;
  l_msite_informations14 JTF_VARCHAR2_TABLE_300;
  l_msite_informations15 JTF_VARCHAR2_TABLE_300;
  l_msite_informations16 JTF_VARCHAR2_TABLE_300;
  l_msite_informations17 JTF_VARCHAR2_TABLE_300;
  l_msite_informations18 JTF_VARCHAR2_TABLE_300;
  l_msite_informations19 JTF_VARCHAR2_TABLE_300;
  l_msite_informations20 JTF_VARCHAR2_TABLE_300;
  l_attribute_categorys JTF_VARCHAR2_TABLE_100;
  l_attributes1  JTF_VARCHAR2_TABLE_300;
  l_attributes2  JTF_VARCHAR2_TABLE_300;
  l_attributes3  JTF_VARCHAR2_TABLE_300;
  l_attributes4  JTF_VARCHAR2_TABLE_300;
  l_attributes5  JTF_VARCHAR2_TABLE_300;
  l_attributes6  JTF_VARCHAR2_TABLE_300;
  l_attributes7  JTF_VARCHAR2_TABLE_300;
  l_attributes8  JTF_VARCHAR2_TABLE_300;
  l_attributes9  JTF_VARCHAR2_TABLE_300;
  l_attributes10 JTF_VARCHAR2_TABLE_300;
  l_attributes11 JTF_VARCHAR2_TABLE_300;
  l_attributes12 JTF_VARCHAR2_TABLE_300;
  l_attributes13 JTF_VARCHAR2_TABLE_300;
  l_attributes14 JTF_VARCHAR2_TABLE_300;
  l_attributes15 JTF_VARCHAR2_TABLE_300;

CURSOR c_get_msite_info_csr(c_msite_id NUMBER) IS
  SELECT MSITE_INFORMATION_CONTEXT, MSITE_INFORMATION1, MSITE_INFORMATION2,
    MSITE_INFORMATION3, MSITE_INFORMATION4, MSITE_INFORMATION5,
    MSITE_INFORMATION6, MSITE_INFORMATION7, MSITE_INFORMATION8,
    MSITE_INFORMATION9, MSITE_INFORMATION10, MSITE_INFORMATION11,
    MSITE_INFORMATION12, MSITE_INFORMATION13, MSITE_INFORMATION14,
    MSITE_INFORMATION15, MSITE_INFORMATION16, MSITE_INFORMATION17,
    MSITE_INFORMATION18, MSITE_INFORMATION19, MSITE_INFORMATION20,
    ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
    ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
    ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
    ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
   FROM IBE_MSITE_INFORMATION
  WHERE MSITE_ID = c_msite_id;
BEGIN
  SAVEPOINT DUPLICATE_MSITE_INFO_SAVE;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('duplicate_msite Starts +');
    IBE_UTIL.debug('p_api_version = '||p_api_version);
    IBE_UTIL.debug('p_init_msg_list = '||p_init_msg_list);
    IBE_UTIL.debug('p_commit = '||p_commit);
    IBE_UTIL.debug('p_source_msite_id = '||p_source_msite_id);
    IBE_UTIL.debug('p_target_msite_id = '||p_target_msite_id);
  END IF;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- For Payment Types, Shipping Methods, and Credit Card
  l_operation_flags := JTF_VARCHAR2_TABLE_100();
  l_msite_ids := JTF_NUMBER_TABLE();
  l_msite_information_ids := JTF_NUMBER_TABLE();
  l_object_version_numbers := JTF_NUMBER_TABLE();
  l_msite_information_contexts := JTF_VARCHAR2_TABLE_100();
  l_msite_informations1 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations2 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations3 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations4 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations5 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations6 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations7 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations8 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations9 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations10 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations11 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations12 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations13 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations14 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations15 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations16 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations17 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations18 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations19 := JTF_VARCHAR2_TABLE_300();
  l_msite_informations20 := JTF_VARCHAR2_TABLE_300();
  l_attribute_categorys := JTF_VARCHAR2_TABLE_100();
  l_attributes1 := JTF_VARCHAR2_TABLE_300();
  l_attributes2 := JTF_VARCHAR2_TABLE_300();
  l_attributes3 := JTF_VARCHAR2_TABLE_300();
  l_attributes4 := JTF_VARCHAR2_TABLE_300();
  l_attributes5 := JTF_VARCHAR2_TABLE_300();
  l_attributes6 := JTF_VARCHAR2_TABLE_300();
  l_attributes7 := JTF_VARCHAR2_TABLE_300();
  l_attributes8 := JTF_VARCHAR2_TABLE_300();
  l_attributes9 := JTF_VARCHAR2_TABLE_300();
  l_attributes10 := JTF_VARCHAR2_TABLE_300();
  l_attributes11 := JTF_VARCHAR2_TABLE_300();
  l_attributes12 := JTF_VARCHAR2_TABLE_300();
  l_attributes13 := JTF_VARCHAR2_TABLE_300();
  l_attributes14 := JTF_VARCHAR2_TABLE_300();
  l_attributes15 := JTF_VARCHAR2_TABLE_300();
  l_i := 1;
  OPEN c_get_msite_info_csr(p_source_msite_id);
  LOOP
    FETCH c_get_msite_info_csr INTO l_msite_information_context,
     l_msite_information1, l_msite_information2, l_msite_information3,
     l_msite_information4, l_msite_information5, l_msite_information6,
     l_msite_information7, l_msite_information8, l_msite_information9,
     l_msite_information10, l_msite_information11, l_msite_information12,
     l_msite_information13, l_msite_information14, l_msite_information15,
     l_msite_information16, l_msite_information17, l_msite_information18,
     l_msite_information19, l_msite_information20, l_attribute_category,
     l_attribute1, l_attribute2, l_attribute3, l_attribute4, l_attribute5,
     l_attribute6, l_attribute7, l_attribute8, l_attribute9, l_attribute10,
     l_attribute11, l_attribute12, l_attribute13, l_attribute14, l_attribute15;
    EXIT WHEN c_get_msite_info_csr%NOTFOUND;
    l_msite_ids.EXTEND;
    l_operation_flags.EXTEND;
    l_msite_information_ids.EXTEND;
    l_object_version_numbers.EXTEND;
    l_msite_information_contexts.EXTEND;
    l_msite_informations1.EXTEND;
    l_msite_informations2.EXTEND;
    l_msite_informations3.EXTEND;
    l_msite_informations4.EXTEND;
    l_msite_informations5.EXTEND;
    l_msite_informations6.EXTEND;
    l_msite_informations7.EXTEND;
    l_msite_informations8.EXTEND;
    l_msite_informations9.EXTEND;
    l_msite_informations10.EXTEND;
    l_msite_informations11.EXTEND;
    l_msite_informations12.EXTEND;
    l_msite_informations13.EXTEND;
    l_msite_informations14.EXTEND;
    l_msite_informations15.EXTEND;
    l_msite_informations16.EXTEND;
    l_msite_informations17.EXTEND;
    l_msite_informations18.EXTEND;
    l_msite_informations19.EXTEND;
    l_msite_informations20.EXTEND;
    l_attribute_categorys.EXTEND;
    l_attributes1.EXTEND;
    l_attributes2.EXTEND;
    l_attributes3.EXTEND;
    l_attributes4.EXTEND;
    l_attributes5.EXTEND;
    l_attributes6.EXTEND;
    l_attributes7.EXTEND;
    l_attributes8.EXTEND;
    l_attributes9.EXTEND;
    l_attributes10.EXTEND;
    l_attributes11.EXTEND;
    l_attributes12.EXTEND;
    l_attributes13.EXTEND;
    l_attributes14.EXTEND;
    l_attributes15.EXTEND;
    l_operation_flags(l_i) := 'C';
    l_msite_ids(l_i) := p_target_msite_id;
    l_msite_information_ids(l_i) := NULL;
    l_object_version_numbers(l_i) := NULL;
    l_msite_information_contexts(l_i) := l_msite_information_context;
    l_msite_informations1(l_i) := l_msite_information1;
    l_msite_informations2(l_i) := l_msite_information2;
    l_msite_informations3(l_i) := l_msite_information3;
    l_msite_informations4(l_i) := l_msite_information4;
    l_msite_informations5(l_i) := l_msite_information5;
    l_msite_informations6(l_i) := l_msite_information6;
    l_msite_informations7(l_i) := l_msite_information7;
    l_msite_informations8(l_i) := l_msite_information8;
    l_msite_informations9(l_i) := l_msite_information9;
    l_msite_informations10(l_i) := l_msite_information10;
    l_msite_informations11(l_i) := l_msite_information11;
    l_msite_informations12(l_i) := l_msite_information12;
    l_msite_informations13(l_i) := l_msite_information13;
    l_msite_informations14(l_i) := l_msite_information14;
    l_msite_informations15(l_i) := l_msite_information15;
    l_msite_informations16(l_i) := l_msite_information16;
    l_msite_informations17(l_i) := l_msite_information17;
    l_msite_informations18(l_i) := l_msite_information18;
    l_msite_informations19(l_i) := l_msite_information19;
    l_msite_informations20(l_i) := l_msite_information20;
    l_attribute_categorys(l_i) := l_attribute_category;
    l_attributes1(l_i) := l_attribute1;
    l_attributes2(l_i) := l_attribute2;
    l_attributes3(l_i) := l_attribute3;
    l_attributes4(l_i) := l_attribute4;
    l_attributes5(l_i) := l_attribute5;
    l_attributes6(l_i) := l_attribute6;
    l_attributes7(l_i) := l_attribute7;
    l_attributes8(l_i) := l_attribute8;
    l_attributes9(l_i) := l_attribute9;
    l_attributes10(l_i) := l_attribute10;
    l_attributes11(l_i) := l_attribute11;
    l_attributes12(l_i) := l_attribute12;
    l_attributes13(l_i) := l_attribute13;
    l_attributes14(l_i) := l_attribute14;
    l_attributes15(l_i) := l_attribute15;
    l_i := l_i + 1;
  END LOOP;
  CLOSE c_get_msite_info_csr;
  IF (l_i > 1) THEN
    IBE_MSITE_INFORMATION_MGR_PVT.Change_Msite_Info  (
      p_api_version => 1.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_commit => p_commit,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      p_operation_flags => l_operation_flags,
      p_msite_information_ids => l_msite_information_ids,
      p_object_version_numbers => l_object_version_numbers,
      p_msite_ids => l_msite_ids,
      p_msite_information_contexts => l_msite_information_contexts,
      p_msite_informations1 => l_msite_informations1,
      p_msite_informations2 => l_msite_informations2,
      p_msite_informations3 => l_msite_informations3,
      p_msite_informations4 => l_msite_informations4,
      p_msite_informations5 => l_msite_informations5,
      p_msite_informations6 => l_msite_informations6,
      p_msite_informations7 => l_msite_informations7,
      p_msite_informations8 => l_msite_informations8,
      p_msite_informations9 => l_msite_informations9,
      p_msite_informations10 => l_msite_informations10,
      p_msite_informations11 => l_msite_informations11,
      p_msite_informations12 => l_msite_informations12,
      p_msite_informations13 => l_msite_informations13,
      p_msite_informations14 => l_msite_informations14,
      p_msite_informations15 => l_msite_informations15,
      p_msite_informations16 => l_msite_informations16,
      p_msite_informations17 => l_msite_informations17,
      p_msite_informations18 => l_msite_informations18,
      p_msite_informations19 => l_msite_informations19,
      p_msite_informations20 => l_msite_informations20,
      p_attribute_categorys => l_attribute_categorys,
      p_attributes1 => l_attributes1,
      p_attributes2 => l_attributes2,
      p_attributes3 => l_attributes3,
      p_attributes4 => l_attributes4,
      p_attributes5 => l_attributes5,
      p_attributes6 => l_attributes6,
      p_attributes7 => l_attributes7,
      p_attributes8 => l_attributes8,
      p_attributes9 => l_attributes9,
      p_attributes10 => l_attributes10,
      p_attributes11 => l_attributes11,
      p_attributes12 => l_attributes12,
      p_attributes13 => l_attributes13,
      p_attributes14 => l_attributes14,
      p_attributes15 => l_attributes15,
      x_msite_information_ids => x_msite_information_ids,
      x_msite_info_return_statuses => x_msite_info_return_statuses,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data
    );
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 'Y') THEN
       IBE_UTIL.debug('Error in IBE_MSITE_INFORMATION_MGR_PVT.'||
         'Change_Msite_Info');
       for i in 1..l_msg_count loop
         l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
         IBE_UTIL.debug(l_msg_data);
       end loop;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('Error in IBE_MSITE_INFORMATION_MGR_PVT.'||
          'Change_Msite_Info');
        for i in 1..l_msg_count loop
          l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
          IBE_UTIL.debug(l_msg_data);
        end loop;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Before committing the work:'||p_commit);
  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('duplicate_msite Ends +');
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DUPLICATE_MSITE_INFO_SAVE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DUPLICATE_MSITE_INFO_SAVE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO DUPLICATE_MSITE_INFO_SAVE;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('SQLCODE:'||SQLCODE);
  IBE_UTIL.debug('SQLERRM:'||SQLERRM);
  END IF;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
END duplicate_msite_info;

END Ibe_Msite_Information_Mgr_Pvt;

/
