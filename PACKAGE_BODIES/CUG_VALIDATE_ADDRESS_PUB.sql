--------------------------------------------------------
--  DDL for Package Body CUG_VALIDATE_ADDRESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_VALIDATE_ADDRESS_PUB" AS
/* $Header: CUGVADRB.pls 120.0 2006/03/01 18:39:10 spusegao noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- aneemuch  11-Feb-04 To fix bug 2657648, changed hz_location_pub to hz_location_v2pub


   -- Enter procedure, function bodies as shown below

 G_PKG_NAME	CONSTANT    VARCHAR2(25):=  'CUG_VALIDATE_ADDRESS_PUB';

PROCEDURE   Validate_Incident_Address (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL)
IS
     l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Incident_Address';
     l_api_version                CONSTANT NUMBER          := 2.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

--  To fix bug 2657648, changed hz_location_pub to hz_location_v2pub
--   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_location_id NUMBER;
   l_incident_id NUMBER;

   l_incident_address_rec CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL;
   l_incident_address_index  BINARY_INTEGER;

 Begin

    l_incident_address_rec := p_incident_address_rec;

    l_incident_address_index := l_incident_address_rec.FIRST;

    l_incident_address_rec(l_incident_address_index).jurisdiction_status := 'S';
    l_incident_address_rec(l_incident_address_index).validation_status := 'S';


--  Pre Call to Customer Hook
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Address',
                                'B', 'C')  THEN


   CUG_Validate_Address_CUHK.Validate_Incident_Address_Pre (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALADDR_PRE_CST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Address',
                                'B', 'V')  THEN

   CUG_Validate_Address_VUHK.Validate_Incident_Address_Pre (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALADDR_PRE_VRT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


--    l_return_status := FND_API.G_RET_STS_SUCCESS;
    CUG_Validate_Address_Pvt.Validate_Incident_Address (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

-- Begin of changes by ANEEMUCH
-- Bug fix 2329158

    x_return_status := l_return_status;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_ADDRESS_VALIDATION_FAILED');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
-- End of changes by ANEEMUCH


--  Post Call to Customer Hook
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Address',
                                'A', 'C')  THEN

   CUG_Validate_Address_CUHK.Validate_Incident_Address_Post (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALADDR_PST_CST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;

-- Post call to the Vertical Type User Hook
  --
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Address',
                                'A', 'V')  THEN

   CUG_Validate_Address_VUHK.Validate_Incident_Address_Post (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALADDR_PST_VRT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;

END Validate_Incident_Address;



PROCEDURE   Validate_Incident_Type (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL)
IS
     l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Incident_Type';
     l_api_version                CONSTANT NUMBER          := 2.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

--  To fix bug 2657648, changed hz_location_pub to hz_location_v2pub
--   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_location_id NUMBER;
   l_incident_id NUMBER;

   l_incident_address_rec CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL;
   l_incident_address_index  BINARY_INTEGER;

 Begin

    l_incident_address_rec := p_incident_address_rec;

    l_incident_address_index := l_incident_address_rec.FIRST;

    l_incident_address_rec(l_incident_address_index).jurisdiction_status := 'S';
    l_incident_address_rec(l_incident_address_index).validation_status := 'S';



--  Pre Call to Customer Hook
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Type',
                                'B', 'C')  THEN

   CUG_Validate_Address_CUHK.Validate_Incident_Type_Pre (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALTYPE_PRE_CST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Type',
                                'B', 'V')  THEN

   CUG_Validate_Address_VUHK.Validate_Incident_Type_Pre (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALTYPE_PRE_VRT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


--    l_return_status := FND_API.G_RET_STS_SUCCESS;
    CUG_Validate_Address_Pvt.Validate_Incident_Type (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

-- Begin of changes by ANEEMUCH
-- Bug fix 2329158

    x_return_status := l_return_status;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_TYPE_VALIDATION_FAILED');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
-- End of changes by ANEEMUCH


--  Post Call to Customer Hook
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Type',
                                'A', 'C')  THEN


   CUG_Validate_Address_CUHK.Validate_Incident_Type_Post (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALTYPE_PST_CST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;

-- Post call to the Vertical Type User Hook
  --
   IF jtf_usr_hks.Ok_To_Execute('CUG_Validate_Address_Pub',
                                'Validate_Type',
                                'A', 'V')  THEN

   CUG_Validate_Address_VUHK.Validate_Incident_Type_Post (
                p_api_version => l_api_version,
                p_init_msg_list => p_init_msg_list,
                p_commit => p_commit,
                p_incident_type_id => p_incident_type_id,
                p_incident_address_rec => l_incident_address_rec,
            	x_msg_count	=> l_msg_count,
                x_msg_data => l_msg_data,
            	x_return_status  => l_return_status,
                p_validation_level => p_validation_level);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CUG', 'CUG_API_VALTYPE_PST_VRT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;

END Validate_Incident_Type;



END CUG_VALIDATE_ADDRESS_PUB;

/
