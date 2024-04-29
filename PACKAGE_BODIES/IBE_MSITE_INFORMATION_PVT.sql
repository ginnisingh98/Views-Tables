--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_INFORMATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_INFORMATION_PVT" AS
/* $Header: IBEVMINB.pls 120.1 2005/08/10 07:03:32 appldev ship $ */

  -- HISTORY
  --   12/13/02           SCHAK          Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_INFORMATION_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVMINB.pls';

--
--
--
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

END Validate_Msite_Id_Exists;

--
--
--
PROCEDURE Validate_Payment_Method_Code
  (
   p_payment_method_code            IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Payment_Method_Code';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_payment_method_code IN VARCHAR2)
  IS SELECT 1 FROM fnd_lookups
    WHERE lookup_type = 'IBE_PAYMENT_TYPE'
    AND lookup_code = l_c_payment_method_code
    AND enabled_flag = 'Y'
    AND (sysdate BETWEEN NVL(start_date_active, sysdate)
    AND NVL(end_date_active, sysdate));

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if p_payment_method_code exists in fnd_lookups
  OPEN c1(p_payment_method_code);
  FETCH c1 INTO l_tmp_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PM_CODE_NOT_EXISTS');
    FND_MESSAGE.Set_Token('PAYMENT_METHOD_CODE', p_payment_method_code);
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

END Validate_Payment_Method_Code;

--
--
--
PROCEDURE Validate_Credit_Card_Code
  (
   p_credit_card_code               IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Credit_Card_Code';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_credit_card_code IN VARCHAR2)
  IS SELECT 1 FROM iby_creditcard_issuers_v
    WHERE card_issuer_code = l_c_credit_card_code;

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check if p_credit_card_code exists in oe_lookups
  OPEN c1(p_credit_card_code);
  FETCH c1 INTO l_tmp_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CC_CODE_NOT_EXISTS');
    FND_MESSAGE.Set_Token('CREDIT_CARD_CODE', p_credit_card_code);
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

END Validate_Credit_Card_Code;

--
--
--
PROCEDURE Validate_Shipment_Method_Code
  (
   p_shipment_method_code           IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) :=
    'Validate_Shipment_Method_Code';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_tmp_id                  NUMBER;

  CURSOR c1(l_c_shipment_method_code IN VARCHAR2)
  IS SELECT 1 FROM oe_ship_methods_v
    WHERE lookup_type = 'SHIP_METHOD'
    AND lookup_code = l_c_shipment_method_code
    AND enabled_flag = 'Y'
    AND (sysdate BETWEEN NVL(start_date_active, sysdate)
    AND NVL(end_date_active, sysdate));

BEGIN

  -- Initialize status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if p_shipment_method_code exists in oe_ship_methods_v
  OPEN c1(p_shipment_method_code);
  FETCH c1 INTO l_tmp_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_SM_CODE_NOT_EXISTS');
    FND_MESSAGE.Set_Token('SHIPMENT_METHOD_CODE', p_shipment_method_code);
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

END Validate_Shipment_Method_Code;

--*****************************************************************************
-- PROCEDURE Check_Duplicate_Entry()
--*****************************************************************************

--
-- x_return_status = FND_API.G_RET_STS_SUCCESS, if there is duplicate entry
-- x_return_status = FND_API.G_RET_STS_ERROR, if there is no duplicate entry
--
PROCEDURE Check_Duplicate_Entry
  (
   p_msite_id                       IN NUMBER,
   p_msite_information_context      IN VARCHAR2,
   p_msite_information1             IN VARCHAR2,
   p_msite_information2             IN VARCHAR2,
   p_msite_information3             IN VARCHAR2,
   p_msite_information4             IN VARCHAR2,
   p_msite_information5             IN VARCHAR2,
   p_msite_information6             IN VARCHAR2,
   p_msite_information7             IN VARCHAR2,
   p_msite_information8             IN VARCHAR2,
   p_msite_information9             IN VARCHAR2,
   p_msite_information10            IN VARCHAR2,
   p_msite_information11            IN VARCHAR2,
   p_msite_information12            IN VARCHAR2,
   p_msite_information13            IN VARCHAR2,
   p_msite_information14            IN VARCHAR2,
   p_msite_information15            IN VARCHAR2,
   p_msite_information16            IN VARCHAR2,
   p_msite_information17            IN VARCHAR2,
   p_msite_information18            IN VARCHAR2,
   p_msite_information19            IN VARCHAR2,
   p_msite_information20            IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Check_Duplicate_Entry';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_tmp_id            NUMBER;

  CURSOR c1(l_c_msite_id IN NUMBER, l_c_msite_information1 IN VARCHAR2)
  IS SELECT 1 FROM ibe_msite_information
    WHERE msite_information_context = 'PMT_MTHD'
    AND msite_information1 = l_c_msite_information1
    AND msite_id = l_c_msite_id;

  CURSOR c2(l_c_msite_id IN NUMBER, l_c_msite_information1 IN VARCHAR2)
  IS SELECT 1 FROM ibe_msite_information
    WHERE msite_information_context = 'CC_TYPE'
    AND msite_information1 = l_c_msite_information1
    AND msite_id = l_c_msite_id;

  CURSOR c3(l_c_msite_id IN NUMBER, l_c_msite_information1 IN VARCHAR2)
  IS SELECT 1 FROM ibe_msite_information
    WHERE msite_information_context = 'SHPMT_MTHD'
    AND msite_information1 = l_c_msite_information1
    AND msite_id = l_c_msite_id;

BEGIN

  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- developer flexfield
  IF (p_msite_information_context = 'PMT_MTHD') THEN

    -- payment method
    OPEN c1(p_msite_id, p_msite_information1);
    FETCH c1 INTO l_tmp_id;
    IF (c1%FOUND) THEN -- found duplicate
      CLOSE c1;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFORMATION_DUP');
      FND_MESSAGE.Set_Token('VALUE', p_msite_information1);
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('CONTEXT', p_msite_information_context);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

  ELSIF (p_msite_information_context = 'CC_TYPE') THEN

    -- credit card type
    OPEN c2(p_msite_id, p_msite_information1);
    FETCH c2 INTO l_tmp_id;
    IF (c2%FOUND) THEN -- found duplicate
      CLOSE c2;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFORMATION_DUP');
      FND_MESSAGE.Set_Token('VALUE', p_msite_information1);
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('CONTEXT', p_msite_information_context);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c2;

  ELSIF (p_msite_information_context = 'SHPMT_MTHD') THEN

    -- shipment method
    OPEN c3(p_msite_id, p_msite_information1);
    FETCH c3 INTO l_tmp_id;
    IF (c3%FOUND) THEN -- found duplicate
      CLOSE c3;
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFORMATION_DUP');
      FND_MESSAGE.Set_Token('VALUE', p_msite_information1);
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('CONTEXT', p_msite_information_context);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c3;

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

PROCEDURE Validate_Create
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_msite_information_context      IN VARCHAR2,
   p_msite_information1             IN VARCHAR2,
   p_msite_information2             IN VARCHAR2,
   p_msite_information3             IN VARCHAR2,
   p_msite_information4             IN VARCHAR2,
   p_msite_information5             IN VARCHAR2,
   p_msite_information6             IN VARCHAR2,
   p_msite_information7             IN VARCHAR2,
   p_msite_information8             IN VARCHAR2,
   p_msite_information9             IN VARCHAR2,
   p_msite_information10            IN VARCHAR2,
   p_msite_information11            IN VARCHAR2,
   p_msite_information12            IN VARCHAR2,
   p_msite_information13            IN VARCHAR2,
   p_msite_information14            IN VARCHAR2,
   p_msite_information15            IN VARCHAR2,
   p_msite_information16            IN VARCHAR2,
   p_msite_information17            IN VARCHAR2,
   p_msite_information18            IN VARCHAR2,
   p_msite_information19            IN VARCHAR2,
   p_msite_information20            IN VARCHAR2,
   p_attribute_category             IN VARCHAR2,
   p_attribute1                     IN VARCHAR2,
   p_attribute2                     IN VARCHAR2,
   p_attribute3                     IN VARCHAR2,
   p_attribute4                     IN VARCHAR2,
   p_attribute5                     IN VARCHAR2,
   p_attribute6                     IN VARCHAR2,
   p_attribute7                     IN VARCHAR2,
   p_attribute8                     IN VARCHAR2,
   p_attribute9                     IN VARCHAR2,
   p_attribute10                    IN VARCHAR2,
   p_attribute11                    IN VARCHAR2,
   p_attribute12                    IN VARCHAR2,
   p_attribute13                    IN VARCHAR2,
   p_attribute14                    IN VARCHAR2,
   p_attribute15                    IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Validate_Create';
  l_api_version             CONSTANT NUMBER       := 1.0;

  l_return_status           VARCHAR2(30);
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

  IF ((p_msite_id IS NULL) OR
      (p_msite_id = FND_API.G_MISS_NUM))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_INVALID_MSITE_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ((p_msite_information_context IS NULL) OR
      (p_msite_information_context = FND_API.G_MISS_CHAR))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVALID_INFO_CTX');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- developer flex-fields
  IF ((p_msite_information_context = 'PMT_MTHD')   OR
      (p_msite_information_context = 'CC_TYPE')    OR
      (p_msite_information_context = 'SHPMT_MTHD'))
  THEN

    IF ((p_msite_information1 IS NULL) OR
        (p_msite_information1 = FND_API.G_MISS_CHAR))
    THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVALID_MSITE_INFO');
      FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
      FND_MESSAGE.Set_Token('CONTEXT', p_msite_information_context);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

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
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid msite_id
  END IF;
  -- developer flexfield
  IF (p_msite_information_context = 'PMT_MTHD') THEN

    Validate_Payment_Method_Code
      (
      p_payment_method_code            => p_msite_information1,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PM_VLD_FAIL');
      FND_MESSAGE.Set_Token('PAYMENT_METHOD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PM_VLD_FAIL');
      FND_MESSAGE.Set_Token('PAYMENT_METHOD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF (p_msite_information_context = 'CC_TYPE') THEN

    Validate_Credit_Card_Code
      (
      p_credit_card_code               => p_msite_information1,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CC_VLD_FAIL');
      FND_MESSAGE.Set_Token('CREDIT_CARD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CC_VLD_FAIL');
      FND_MESSAGE.Set_Token('CREDIT_CARD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF (p_msite_information_context = 'SHPMT_MTHD') THEN

    Validate_Shipment_Method_Code
      (
      p_shipment_method_code           => p_msite_information1,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_SM_VLD_FAIL');
      FND_MESSAGE.Set_Token('SHIPMENT_METHOD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_SM_VLD_FAIL');
      FND_MESSAGE.Set_Token('SHIPMENT_METHOD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;
  --
  -- check for duplicate entry
  --
  Check_Duplicate_Entry
    (
     p_msite_id                       => p_msite_id,
     p_msite_information_context      => p_msite_information_context,
     p_msite_information1             => p_msite_information1,
     p_msite_information2             => p_msite_information2,
     p_msite_information3             => p_msite_information3,
     p_msite_information4             => p_msite_information4,
     p_msite_information5             => p_msite_information5,
     p_msite_information6             => p_msite_information6,
     p_msite_information7             => p_msite_information7,
     p_msite_information8             => p_msite_information8,
     p_msite_information9             => p_msite_information9,
     p_msite_information10            => p_msite_information10,
     p_msite_information11            => p_msite_information11,
     p_msite_information12            => p_msite_information12,
     p_msite_information13            => p_msite_information13,
     p_msite_information14            => p_msite_information14,
     p_msite_information15            => p_msite_information15,
     p_msite_information16            => p_msite_information16,
     p_msite_information17            => p_msite_information17,
     p_msite_information18            => p_msite_information18,
     p_msite_information19            => p_msite_information19,
     p_msite_information20            => p_msite_information20,
     x_return_status                  => l_return_status,
     x_msg_count                      => x_msg_count,
     x_msg_data                       => x_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_UNEXP_DUP_CHECK');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DUPLICATE_MSITE_INFO');
    FND_MESSAGE.Set_Token('MSITE_ID', p_msite_id);
    FND_MESSAGE.Set_Token('CONTEXT', p_msite_information_context);
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

--
--
--
PROCEDURE Validate_Update
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_information_id           IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_msite_information1             IN VARCHAR2,
   p_msite_information2             IN VARCHAR2,
   p_msite_information3             IN VARCHAR2,
   p_msite_information4             IN VARCHAR2,
   p_msite_information5             IN VARCHAR2,
   p_msite_information6             IN VARCHAR2,
   p_msite_information7             IN VARCHAR2,
   p_msite_information8             IN VARCHAR2,
   p_msite_information9             IN VARCHAR2,
   p_msite_information10            IN VARCHAR2,
   p_msite_information11            IN VARCHAR2,
   p_msite_information12            IN VARCHAR2,
   p_msite_information13            IN VARCHAR2,
   p_msite_information14            IN VARCHAR2,
   p_msite_information15            IN VARCHAR2,
   p_msite_information16            IN VARCHAR2,
   p_msite_information17            IN VARCHAR2,
   p_msite_information18            IN VARCHAR2,
   p_msite_information19            IN VARCHAR2,
   p_msite_information20            IN VARCHAR2,
   p_attribute_category             IN VARCHAR2,
   p_attribute1                     IN VARCHAR2,
   p_attribute2                     IN VARCHAR2,
   p_attribute3                     IN VARCHAR2,
   p_attribute4                     IN VARCHAR2,
   p_attribute5                     IN VARCHAR2,
   p_attribute6                     IN VARCHAR2,
   p_attribute7                     IN VARCHAR2,
   p_attribute8                     IN VARCHAR2,
   p_attribute9                     IN VARCHAR2,
   p_attribute10                    IN VARCHAR2,
   p_attribute11                    IN VARCHAR2,
   p_attribute12                    IN VARCHAR2,
   p_attribute13                    IN VARCHAR2,
   p_attribute14                    IN VARCHAR2,
   p_attribute15                    IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Update';
  l_api_version           CONSTANT NUMBER       := 1.0;

  l_msite_id                    NUMBER;
  l_msite_information_context   VARCHAR2(40);

  CURSOR c1(l_c_msite_information_id IN NUMBER) IS
    SELECT msite_information_context, msite_id FROM ibe_msite_information
      WHERE msite_information_id = l_c_msite_information_id;

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

  -- msite_information_id
  IF (p_msite_information_id IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_MSINF_ID_IS_NULL');
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

  --
  -- non-null field validation
  --

  -- Get the msite_information_context
  OPEN c1(p_msite_information_id);
  FETCH c1 INTO l_msite_information_context, l_msite_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_ID_NOT_FOUND');
    FND_MESSAGE.Set_Token('MSITE_INFO_ID', p_msite_information_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c1;

  -- developer flexfield - check for null value
  IF ((l_msite_information_context = 'PMT_MTHD')   OR
      (l_msite_information_context = 'CC_TYPE')    OR
      (l_msite_information_context = 'SHPMT_MTHD'))
  THEN

    IF ((p_msite_information1 IS NULL) OR
        (p_msite_information1 = FND_API.G_MISS_CHAR))
    THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INVALID_MSITE_INFO');
      FND_MESSAGE.Set_Token('MSITE_ID', l_msite_id);
      FND_MESSAGE.Set_Token('CONTEXT', l_msite_information_context);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- developer flexfield
  IF (l_msite_information_context = 'PMT_MTHD') THEN

    Validate_Payment_Method_Code
      (
      p_payment_method_code            => p_msite_information1,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PM_VLD_FAIL');
      FND_MESSAGE.Set_Token('PAYMENT_METHOD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_PM_VLD_FAIL');
      FND_MESSAGE.Set_Token('PAYMENT_METHOD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF (l_msite_information_context = 'CC_TYPE') THEN

    Validate_Credit_Card_Code
      (
      p_credit_card_code               => p_msite_information1,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CC_VLD_FAIL');
      FND_MESSAGE.Set_Token('CREDIT_CARD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_CC_VLD_FAIL');
      FND_MESSAGE.Set_Token('CREDIT_CARD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF (l_msite_information_context = 'SHPMT_MTHD') THEN

    Validate_Shipment_Method_Code
      (
      p_shipment_method_code           => p_msite_information1,
      x_return_status                  => x_return_status,
      x_msg_count                      => x_msg_count,
      x_msg_data                       => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_SM_VLD_FAIL');
      FND_MESSAGE.Set_Token('SHIPMENT_METHOD_CODE', p_msite_information1);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_SM_VLD_FAIL');
      FND_MESSAGE.Set_Token('SHIPMENT_METHOD_CODE', p_msite_information1);
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


PROCEDURE Create_Msite_Information
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_msite_information_context      IN VARCHAR2,
   p_msite_information1             IN VARCHAR2,
   p_msite_information2             IN VARCHAR2,
   p_msite_information3             IN VARCHAR2,
   p_msite_information4             IN VARCHAR2,
   p_msite_information5             IN VARCHAR2,
   p_msite_information6             IN VARCHAR2,
   p_msite_information7             IN VARCHAR2,
   p_msite_information8             IN VARCHAR2,
   p_msite_information9             IN VARCHAR2,
   p_msite_information10            IN VARCHAR2,
   p_msite_information11            IN VARCHAR2,
   p_msite_information12            IN VARCHAR2,
   p_msite_information13            IN VARCHAR2,
   p_msite_information14            IN VARCHAR2,
   p_msite_information15            IN VARCHAR2,
   p_msite_information16            IN VARCHAR2,
   p_msite_information17            IN VARCHAR2,
   p_msite_information18            IN VARCHAR2,
   p_msite_information19            IN VARCHAR2,
   p_msite_information20            IN VARCHAR2,
   p_attribute_category             IN VARCHAR2,
   p_attribute1                     IN VARCHAR2,
   p_attribute2                     IN VARCHAR2,
   p_attribute3                     IN VARCHAR2,
   p_attribute4                     IN VARCHAR2,
   p_attribute5                     IN VARCHAR2,
   p_attribute6                     IN VARCHAR2,
   p_attribute7                     IN VARCHAR2,
   p_attribute8                     IN VARCHAR2,
   p_attribute9                     IN VARCHAR2,
   p_attribute10                    IN VARCHAR2,
   p_attribute11                    IN VARCHAR2,
   p_attribute12                    IN VARCHAR2,
   p_attribute13                    IN VARCHAR2,
   p_attribute14                    IN VARCHAR2,
   p_attribute15                    IN VARCHAR2,
   x_msite_information_id           OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Msite_Information';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT create_msite_information_pvt;

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
  -- 2. Insert row


  --
  -- 1. Check if everything is valid
  --
  Validate_Create
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_msite_id                       => p_msite_id,
    p_msite_information_context      => p_msite_information_context,
    p_msite_information1             => p_msite_information1,
    p_msite_information2             => p_msite_information2,
    p_msite_information3             => p_msite_information3,
    p_msite_information4             => p_msite_information4,
    p_msite_information5             => p_msite_information5,
    p_msite_information6             => p_msite_information6,
    p_msite_information7             => p_msite_information7,
    p_msite_information8             => p_msite_information8,
    p_msite_information9             => p_msite_information9,
    p_msite_information10            => p_msite_information10,
    p_msite_information11            => p_msite_information11,
    p_msite_information12            => p_msite_information12,
    p_msite_information13            => p_msite_information13,
    p_msite_information14            => p_msite_information14,
    p_msite_information15            => p_msite_information15,
    p_msite_information16            => p_msite_information16,
    p_msite_information17            => p_msite_information17,
    p_msite_information18            => p_msite_information18,
    p_msite_information19            => p_msite_information19,
    p_msite_information20            => p_msite_information20,
    p_attribute_category             => p_attribute_category,
    p_attribute1                     => p_attribute1,
    p_attribute2                     => p_attribute2,
    p_attribute3                     => p_attribute3,
    p_attribute4                     => p_attribute4,
    p_attribute5                     => p_attribute5,
    p_attribute6                     => p_attribute6,
    p_attribute7                     => p_attribute7,
    p_attribute8                     => p_attribute8,
    p_attribute9                     => p_attribute9,
    p_attribute10                    => p_attribute10,
    p_attribute11                    => p_attribute11,
    p_attribute12                    => p_attribute12,
    p_attribute13                    => p_attribute13,
    p_attribute14                    => p_attribute14,
    p_attribute15                    => p_attribute15,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;
  --
  -- 2. Insert row
  --
  BEGIN
    Ibe_Msite_Information_Pkg.insert_row
      (
      p_msite_information_id               => FND_API.G_MISS_NUM,
      p_object_version_number              => l_object_version_number,
      p_msite_id                           => p_msite_id,
      p_msite_information_context          => p_msite_information_context,
      p_msite_information1                 => p_msite_information1,
      p_msite_information2                 => p_msite_information2,
      p_msite_information3                 => p_msite_information3,
      p_msite_information4                 => p_msite_information4,
      p_msite_information5                 => p_msite_information5,
      p_msite_information6                 => p_msite_information6,
      p_msite_information7                 => p_msite_information7,
      p_msite_information8                 => p_msite_information8,
      p_msite_information9                 => p_msite_information9,
      p_msite_information10                => p_msite_information10,
      p_msite_information11                => p_msite_information11,
      p_msite_information12                => p_msite_information12,
      p_msite_information13                => p_msite_information13,
      p_msite_information14                => p_msite_information14,
      p_msite_information15                => p_msite_information15,
      p_msite_information16                => p_msite_information16,
      p_msite_information17                => p_msite_information17,
      p_msite_information18                => p_msite_information18,
      p_msite_information19                => p_msite_information19,
      p_msite_information20                => p_msite_information20,
      p_attribute_category                 => p_attribute_category,
      p_attribute1                         => p_attribute1,
      p_attribute2                         => p_attribute2,
      p_attribute3                         => p_attribute3,
      p_attribute4                         => p_attribute4,
      p_attribute5                         => p_attribute5,
      p_attribute6                         => p_attribute6,
      p_attribute7                         => p_attribute7,
      p_attribute8                         => p_attribute8,
      p_attribute9                         => p_attribute9,
      p_attribute10                        => p_attribute10,
      p_attribute11                        => p_attribute11,
      p_attribute12                        => p_attribute12,
      p_attribute13                        => p_attribute13,
      p_attribute14                        => p_attribute14,
      p_attribute15                        => p_attribute15,
      p_creation_date                      => sysdate,
      p_created_by                         => FND_GLOBAL.user_id,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id,
      x_rowid                              => l_rowid,
      x_msite_information_id               => x_msite_information_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_INSERT_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_INSERT_FL');
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
     ROLLBACK TO create_msite_information_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_msite_information_pvt;
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

     ROLLBACK TO create_msite_information_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_Msite_Information;

PROCEDURE Update_Msite_Information
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_information_id           IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_msite_information1             IN VARCHAR2,
   p_msite_information2             IN VARCHAR2,
   p_msite_information3             IN VARCHAR2,
   p_msite_information4             IN VARCHAR2,
   p_msite_information5             IN VARCHAR2,
   p_msite_information6             IN VARCHAR2,
   p_msite_information7             IN VARCHAR2,
   p_msite_information8             IN VARCHAR2,
   p_msite_information9             IN VARCHAR2,
   p_msite_information10            IN VARCHAR2,
   p_msite_information11            IN VARCHAR2,
   p_msite_information12            IN VARCHAR2,
   p_msite_information13            IN VARCHAR2,
   p_msite_information14            IN VARCHAR2,
   p_msite_information15            IN VARCHAR2,
   p_msite_information16            IN VARCHAR2,
   p_msite_information17            IN VARCHAR2,
   p_msite_information18            IN VARCHAR2,
   p_msite_information19            IN VARCHAR2,
   p_msite_information20            IN VARCHAR2,
   p_attribute_category             IN VARCHAR2,
   p_attribute1                     IN VARCHAR2,
   p_attribute2                     IN VARCHAR2,
   p_attribute3                     IN VARCHAR2,
   p_attribute4                     IN VARCHAR2,
   p_attribute5                     IN VARCHAR2,
   p_attribute6                     IN VARCHAR2,
   p_attribute7                     IN VARCHAR2,
   p_attribute8                     IN VARCHAR2,
   p_attribute9                     IN VARCHAR2,
   p_attribute10                    IN VARCHAR2,
   p_attribute11                    IN VARCHAR2,
   p_attribute12                    IN VARCHAR2,
   p_attribute13                    IN VARCHAR2,
   p_attribute14                    IN VARCHAR2,
   p_attribute15                    IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Msite_Information';
  l_api_version       CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT update_msite_information_pvt;

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
  --
  -- 1. Validate the input data
  --
  Validate_Update
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_msite_information_id           => p_msite_information_id,
    p_object_version_number          => p_object_version_number,
    p_msite_information1             => p_msite_information1,
    p_msite_information2             => p_msite_information2,
    p_msite_information3             => p_msite_information3,
    p_msite_information4             => p_msite_information4,
    p_msite_information5             => p_msite_information5,
    p_msite_information6             => p_msite_information6,
    p_msite_information7             => p_msite_information7,
    p_msite_information8             => p_msite_information8,
    p_msite_information9             => p_msite_information9,
    p_msite_information10            => p_msite_information10,
    p_msite_information11            => p_msite_information11,
    p_msite_information12            => p_msite_information12,
    p_msite_information13            => p_msite_information13,
    p_msite_information14            => p_msite_information14,
    p_msite_information15            => p_msite_information15,
    p_msite_information16            => p_msite_information16,
    p_msite_information17            => p_msite_information17,
    p_msite_information18            => p_msite_information18,
    p_msite_information19            => p_msite_information19,
    p_msite_information20            => p_msite_information20,
    p_attribute_category             => p_attribute_category,
    p_attribute1                     => p_attribute1,
    p_attribute2                     => p_attribute2,
    p_attribute3                     => p_attribute3,
    p_attribute4                     => p_attribute4,
    p_attribute5                     => p_attribute5,
    p_attribute6                     => p_attribute6,
    p_attribute7                     => p_attribute7,
    p_attribute8                     => p_attribute8,
    p_attribute9                     => p_attribute9,
    p_attribute10                    => p_attribute10,
    p_attribute11                    => p_attribute11,
    p_attribute12                    => p_attribute12,
    p_attribute13                    => p_attribute13,
    p_attribute14                    => p_attribute14,
    p_attribute15                    => p_attribute15,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_INVALID_UPDATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid
  END IF;

  -- 2. update row with section data into section table
  BEGIN
    Ibe_Msite_Information_Pkg.update_row
      (
      p_msite_information_id               => p_msite_information_id,
      p_object_version_number              => p_object_version_number,
      p_msite_information1                 => p_msite_information1,
      p_msite_information2                 => p_msite_information2,
      p_msite_information3                 => p_msite_information3,
      p_msite_information4                 => p_msite_information4,
      p_msite_information5                 => p_msite_information5,
      p_msite_information6                 => p_msite_information6,
      p_msite_information7                 => p_msite_information7,
      p_msite_information8                 => p_msite_information8,
      p_msite_information9                 => p_msite_information9,
      p_msite_information10                => p_msite_information10,
      p_msite_information11                => p_msite_information11,
      p_msite_information12                => p_msite_information12,
      p_msite_information13                => p_msite_information13,
      p_msite_information14                => p_msite_information14,
      p_msite_information15                => p_msite_information15,
      p_msite_information16                => p_msite_information16,
      p_msite_information17                => p_msite_information17,
      p_msite_information18                => p_msite_information18,
      p_msite_information19                => p_msite_information19,
      p_msite_information20                => p_msite_information20,
      p_attribute_category                 => p_attribute_category,
      p_attribute1                         => p_attribute1,
      p_attribute2                         => p_attribute2,
      p_attribute3                         => p_attribute3,
      p_attribute4                         => p_attribute4,
      p_attribute5                         => p_attribute5,
      p_attribute6                         => p_attribute6,
      p_attribute7                         => p_attribute7,
      p_attribute8                         => p_attribute8,
      p_attribute9                         => p_attribute9,
      p_attribute10                        => p_attribute10,
      p_attribute11                        => p_attribute11,
      p_attribute12                        => p_attribute12,
      p_attribute13                        => p_attribute13,
      p_attribute14                        => p_attribute14,
      p_attribute15                        => p_attribute15,
      p_last_update_date                   => sysdate,
      p_last_updated_by                    => FND_GLOBAL.user_id,
      p_last_update_login                  => FND_GLOBAL.login_id
      );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_UPDATE_FL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_UPDATE_FL');
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
     ROLLBACK TO update_msite_information_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_msite_information_pvt;
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

     ROLLBACK TO update_msite_information_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Msite_Information;

PROCEDURE Delete_Msite_Information
  (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                      IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level            IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_msite_information_id        IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_Msite_Information';
  l_api_version       CONSTANT NUMBER        := 1.0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT delete_msite_information_pvt;

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

  -- 1a. Check if msite_information_id is specified
  IF ((p_msite_information_id IS NULL) OR
      (p_msite_information_id = FND_API.G_MISS_NUM))
  THEN
    -- msite_information_id is not specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MINFO_ID_SPEC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- delete for ibe_msite_information
  BEGIN
    Ibe_Msite_Information_Pkg.delete_row(p_msite_information_id);
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_DELETE_FL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_INFO_DELETE_FL');
       FND_MSG_PUB.Add;
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
     ROLLBACK TO delete_msite_information_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_msite_information_pvt;
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

     ROLLBACK TO delete_msite_information_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_Msite_Information;

END Ibe_Msite_Information_Pvt;

/
