--------------------------------------------------------
--  DDL for Package Body CUG_VALIDATE_ADDRESS_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_VALIDATE_ADDRESS_TYPE" AS
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- aneemuch  11-Feb-04 To fix bug 2657648 changed hz_location_pub to hz_location_v2_pub
--
--
   -- Enter procedure, function bodies as shown below
 G_PKG_NAME	CONSTANT    VARCHAR2(25):=  'CUG_VALIDATE_ADDRESS_TYPE';

PROCEDURE   Validate_Incident_Address_Type (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_TYPE.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL)
IS
     l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Incident_Address_Type';
     l_api_version                CONSTANT NUMBER          := 2.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

-- To fix bug 2657648 changed hz_location_pub to hz_location_v2pub, aneemuch 11-Feb-2004
--   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_location_id NUMBER;
   l_incident_id NUMBER;

   l_incident_address_rec CUG_VALIDATE_ADDRESS_TYPE.INCIDENT_ADDRESS_TBL;
   l_incident_address_index  BINARY_INTEGER;

   CURSOR l_ValidateAddressFlag_csr IS
      SELECT validate_address_flag
      FROM   cug_sr_type_dup_chk_info_v
      WHERE  incident_type_id = p_incident_type_id;
   l_Validate_Address_Flag VARCHAR2(1);


 Begin

    l_incident_address_rec := p_incident_address_rec;

    l_incident_address_index := l_incident_address_rec.FIRST;

    l_incident_address_rec(l_incident_address_index).jurisdiction_status := 'S';
    l_incident_address_rec(l_incident_address_index).validation_status := 'S';
    l_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check if the validate_address flag is turned on for the given incident type
--   If yes, only then call CUG_VALIDATE_ADDRESS_PKG.Validate_Incident_Address
--   Else, do not call anything. Just return success status

    OPEN l_ValidateAddressFlag_csr;
    FETCH l_ValidateAddressFlag_csr INTO l_Validate_Address_Flag;
    IF (l_ValidateAddressFlag_csr%NOTFOUND) THEN
      l_Validate_Address_Flag := 'N';
      FND_MESSAGE.Set_Name('CUG', 'CUG_ADDRESS_VALIDATION_FAILED');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
    END IF;
    CLOSE     l_ValidateAddressFlag_csr;

    IF(l_Validate_Address_Flag = 'Y') THEN
        CUG_Validate_Address_Pkg.Validate_Incident_Address (
                    p_api_version => l_api_version,
                    p_init_msg_list => p_init_msg_list,
                    p_commit => p_commit,
                    p_incident_type_id => p_incident_type_id,
                    p_incident_address_rec => l_incident_address_rec,
                	x_msg_count	=> l_msg_count,
                    x_msg_data => l_msg_data,
                	x_return_status  => l_return_status,
                    p_validation_level => p_validation_level);

        x_return_status := l_return_status;
        p_incident_address_rec := l_incident_address_rec;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.Set_Name('CUG', 'CUG_ADDRESS_VALIDATION_FAILED');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
            l_incident_address_index := l_incident_address_rec.FIRST;

            IF(l_incident_address_rec(l_incident_address_index).jurisdiction_status is NULL) THEN
                CUG_Validate_Type_Pkg.Validate_Incident_Type (
                        p_api_version => l_api_version,
                        p_init_msg_list => p_init_msg_list,
                        p_commit => p_commit,
                        p_incident_type_id => p_incident_type_id,
                        p_incident_address_rec => l_incident_address_rec,
                    	x_msg_count	=> l_msg_count,
                        x_msg_data => l_msg_data,
                    	x_return_status  => l_return_status,
                        p_validation_level => p_validation_level);

            x_return_status := l_return_status;
            p_incident_address_rec := l_incident_address_rec;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.Set_Name('CUG', 'CUG_TYPE_VALIDATION_FAILED');
              FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
              FND_MSG_PUB.Add;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;  -- Jurisdiction check (only of address validation api did not do jurisdiction check)
        END IF; -- If return status from Address Validation was succesful
    END IF; -- If validate_address_flag = 'Y'

            x_return_status := l_return_status;
            p_incident_address_rec := l_incident_address_rec;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MESSAGE.Set_Name('CUG', 'CUG_ADDRESS_VALIDATION_FAILED');
    FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
    FND_MSG_PUB.Add;
    x_return_status := 'E';
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
--     raise FND_API.G_EXC_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MESSAGE.Set_Name('CUG', 'CUG_ADDRESS_VALIDATION_FAILED');
    FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
    FND_MSG_PUB.Add;
    x_return_status := 'E';
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
--     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('CUG', 'CUG_ADDRESS_VALIDATION_FAILED');
    FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
    FND_MSG_PUB.Add;
    x_return_status := 'U';
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
--     raise FND_API.G_EXC_ERROR;

END Validate_Incident_Address_Type;
   -- Enter further code below as specified in the Package spec.
END; -- Package Body CUG_VALIDATE_ADDRESS_TYPE

/
