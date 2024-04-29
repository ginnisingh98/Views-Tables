--------------------------------------------------------
--  DDL for Package Body CSP_INV_LOC_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_INV_LOC_ASSIGNMENTS_PKG" AS
/* $Header: cspttreb.pls 120.0 2005/05/25 11:37:41 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_INV_LOC_ASSIGNMENTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_INV_LOC_ASSIGNMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspttreb.pls';

PROCEDURE Insert_Row(
          px_CSP_INV_LOC_ASSIGNMENT_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_LOCATOR_ID    NUMBER,
          p_RESOURCE_TYPE    VARCHAR2,
          p_EFFECTIVE_DATE_START    DATE,
          p_EFFECTIVE_DATE_END    DATE,
          p_DEFAULT_CODE    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSP_INV_LOC_ASSIGNMENTS_S1.nextval FROM sys.dual;
   l_inv_loc_assignment  CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSP_INV_LOC_ASSIGNMENTS_PKG.INSERT_ROW';
BEGIN
          l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID := px_CSP_INV_LOC_ASSIGNMENT_ID;
          l_inv_loc_assignment.CREATED_BY                 := p_CREATED_BY    ;
          l_inv_loc_assignment.CREATION_DATE              := p_CREATION_DATE   ;
          l_inv_loc_assignment.LAST_UPDATED_BY            := p_LAST_UPDATED_BY    ;
          l_inv_loc_assignment.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE    ;
          l_inv_loc_assignment.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN    ;
          l_inv_loc_assignment.RESOURCE_ID                := p_RESOURCE_ID    ;
          l_inv_loc_assignment.ORGANIZATION_ID            := p_ORGANIZATION_ID    ;
          l_inv_loc_assignment.SUBINVENTORY_CODE          := p_SUBINVENTORY_CODE    ;
          l_inv_loc_assignment.LOCATOR_ID                 := p_LOCATOR_ID    ;
          l_inv_loc_assignment.RESOURCE_TYPE              := p_RESOURCE_TYPE    ;
          l_inv_loc_assignment.EFFECTIVE_DATE_START       := p_EFFECTIVE_DATE_START   ;
          l_inv_loc_assignment.EFFECTIVE_DATE_END         := p_EFFECTIVE_DATE_END    ;
          l_inv_loc_assignment.DEFAULT_CODE               := p_DEFAULT_CODE    ;
          l_inv_loc_assignment.ATTRIBUTE_CATEGORY         := p_ATTRIBUTE_CATEGORY    ;
          l_inv_loc_assignment.ATTRIBUTE1                 := p_ATTRIBUTE1    ;
          l_inv_loc_assignment.ATTRIBUTE2                 := p_ATTRIBUTE2 ;
          l_inv_loc_assignment.ATTRIBUTE3                 := p_ATTRIBUTE3    ;
          l_inv_loc_assignment.ATTRIBUTE4                 := p_ATTRIBUTE4;
          l_inv_loc_assignment.ATTRIBUTE5                 := p_ATTRIBUTE5;
          l_inv_loc_assignment.ATTRIBUTE6                 := p_ATTRIBUTE6;
          l_inv_loc_assignment.ATTRIBUTE7                 := p_ATTRIBUTE7;
          l_inv_loc_assignment.ATTRIBUTE8                 := p_ATTRIBUTE8;
          l_inv_loc_assignment.ATTRIBUTE9                 := p_ATTRIBUTE9;
          l_inv_loc_assignment.ATTRIBUTE10                := p_ATTRIBUTE10;
          l_inv_loc_assignment.ATTRIBUTE11                := p_ATTRIBUTE11;
          l_inv_loc_assignment.ATTRIBUTE12                := p_ATTRIBUTE12;
          l_inv_loc_assignment.ATTRIBUTE13                := p_ATTRIBUTE13;
          l_inv_loc_assignment.ATTRIBUTE14                := p_ATTRIBUTE14;
          l_inv_loc_assignment.ATTRIBUTE15                := p_ATTRIBUTE15;

  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Insert_Row',
                                      'B', 'C')  THEN
    csp_inv_loc_assignments_cuhk.create_inventory_location_Pre
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Insert_Row',
                                      'B', 'V')  THEN
    csp_inv_loc_assignments_vuhk.create_inventory_location_Pre
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

    csp_inv_loc_assignments_iuhk.create_inventory_location_Pre
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   If (l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID IS NULL) OR (l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_CSP_INV_LOC_ASSIGNMENT_ID;
       CLOSE C2;
   End If;
   l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID := px_CSP_INV_LOC_ASSIGNMENT_ID;
   user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID  := l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID ;
   INSERT INTO CSP_INV_LOC_ASSIGNMENTS(
           CSP_INV_LOC_ASSIGNMENT_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           RESOURCE_ID,
           ORGANIZATION_ID,
           SUBINVENTORY_CODE,
           LOCATOR_ID,
           RESOURCE_TYPE,
           EFFECTIVE_DATE_START,
           EFFECTIVE_DATE_END,
           DEFAULT_CODE,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
          ) VALUES (
           px_CSP_INV_LOC_ASSIGNMENT_ID,
           decode( l_inv_loc_assignment.CREATED_BY, FND_API.G_MISS_NUM, NULL, l_inv_loc_assignment.CREATED_BY),
           decode(l_inv_loc_assignment.CREATION_DATE,fnd_api.g_miss_date,to_date(null),l_inv_loc_assignment.creation_date),
           decode( l_inv_loc_assignment.LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, l_inv_loc_assignment.LAST_UPDATED_BY),
           decode(l_inv_loc_assignment.LAST_UPDATE_DATE,fnd_api.g_miss_date,to_date(null),l_inv_loc_assignment.last_update_date),
           decode( l_inv_loc_assignment.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, l_inv_loc_assignment.LAST_UPDATE_LOGIN),
           decode( l_inv_loc_assignment.RESOURCE_ID, FND_API.G_MISS_NUM, NULL, l_inv_loc_assignment.RESOURCE_ID),
           decode( l_inv_loc_assignment.ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, l_inv_loc_assignment.ORGANIZATION_ID),
           decode( l_inv_loc_assignment.SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.SUBINVENTORY_CODE),
           decode( l_inv_loc_assignment.LOCATOR_ID, FND_API.G_MISS_NUM, NULL, l_inv_loc_assignment.LOCATOR_ID),
           decode( l_inv_loc_assignment.RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.RESOURCE_TYPE),
           decode( l_inv_loc_assignment.EFFECTIVE_DATE_START, FND_API.G_MISS_DATE, to_date(null), l_inv_loc_assignment.EFFECTIVE_DATE_START),
           decode( l_inv_loc_assignment.EFFECTIVE_DATE_END, FND_API.G_MISS_DATE, to_date(null), l_inv_loc_assignment.EFFECTIVE_DATE_END),
           decode( l_inv_loc_assignment.DEFAULT_CODE, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.DEFAULT_CODE),
           decode( l_inv_loc_assignment.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE_CATEGORY),
           decode( l_inv_loc_assignment.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE1),
           decode( l_inv_loc_assignment.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE2),
           decode( l_inv_loc_assignment.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE3),
           decode( l_inv_loc_assignment.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE4),
           decode( l_inv_loc_assignment.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE5),
           decode( l_inv_loc_assignment.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE6),
           decode( l_inv_loc_assignment.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE7),
           decode( l_inv_loc_assignment.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE8),
           decode( l_inv_loc_assignment.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE9),
           decode( l_inv_loc_assignment.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE10),
           decode( l_inv_loc_assignment.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE11),
           decode( l_inv_loc_assignment.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE12),
           decode( l_inv_loc_assignment.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE13),
           decode( l_inv_loc_assignment.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE14),
           decode( l_inv_loc_assignment.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, l_inv_loc_assignment.ATTRIBUTE15));

  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Insert_Row',
                                      'A', 'C')  THEN
    csp_inv_loc_assignments_cuhk.create_inventory_location_Post
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Insert_Row',
                                      'A', 'V')  THEN
    csp_inv_loc_assignments_vuhk.create_inventory_location_Post
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csp_inv_loc_assignments_iuhk.create_inventory_location_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
End Insert_Row;

PROCEDURE Update_Row(
          p_CSP_INV_LOC_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_LOCATOR_ID    NUMBER,
          p_RESOURCE_TYPE    VARCHAR2,
          p_EFFECTIVE_DATE_START    DATE,
          p_EFFECTIVE_DATE_END    DATE,
          p_DEFAULT_CODE    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2)

 IS
     l_inv_loc_assignment  CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type;
     l_return_status    varchar2(100);
     l_msg_count        NUMBER;
     l_msg_data         varchar2(1000);
     l_api_name_full    varchar2(50) := 'CSP_INV_LOC_ASSIGNMENTS_PKG.UPDATE_ROW';
 BEGIN


          l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID := p_CSP_INV_LOC_ASSIGNMENT_ID;
          l_inv_loc_assignment.CREATED_BY                 := p_CREATED_BY    ;
          l_inv_loc_assignment.CREATION_DATE              := p_CREATION_DATE   ;
          l_inv_loc_assignment.LAST_UPDATED_BY            := p_LAST_UPDATED_BY    ;
          l_inv_loc_assignment.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE    ;
          l_inv_loc_assignment.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN    ;
          l_inv_loc_assignment.RESOURCE_ID                := p_RESOURCE_ID    ;
          l_inv_loc_assignment.ORGANIZATION_ID            := p_ORGANIZATION_ID    ;
          l_inv_loc_assignment.SUBINVENTORY_CODE          := p_SUBINVENTORY_CODE    ;
          l_inv_loc_assignment.LOCATOR_ID                 := p_LOCATOR_ID    ;
          l_inv_loc_assignment.RESOURCE_TYPE              := p_RESOURCE_TYPE    ;
          l_inv_loc_assignment.EFFECTIVE_DATE_START       := p_EFFECTIVE_DATE_START   ;
          l_inv_loc_assignment.EFFECTIVE_DATE_END         := p_EFFECTIVE_DATE_END    ;
          l_inv_loc_assignment.DEFAULT_CODE               := p_DEFAULT_CODE    ;
          l_inv_loc_assignment.ATTRIBUTE_CATEGORY         := p_ATTRIBUTE_CATEGORY    ;
          l_inv_loc_assignment.ATTRIBUTE1                 := p_ATTRIBUTE1    ;
          l_inv_loc_assignment.ATTRIBUTE2                 := p_ATTRIBUTE2 ;
          l_inv_loc_assignment.ATTRIBUTE3                 := p_ATTRIBUTE3    ;
          l_inv_loc_assignment.ATTRIBUTE4                 := p_ATTRIBUTE4;
          l_inv_loc_assignment.ATTRIBUTE5                 := p_ATTRIBUTE5;
          l_inv_loc_assignment.ATTRIBUTE6                 := p_ATTRIBUTE6;
          l_inv_loc_assignment.ATTRIBUTE7                 := p_ATTRIBUTE7;
          l_inv_loc_assignment.ATTRIBUTE8                 := p_ATTRIBUTE8;
          l_inv_loc_assignment.ATTRIBUTE9                 := p_ATTRIBUTE9;
          l_inv_loc_assignment.ATTRIBUTE10                := p_ATTRIBUTE10;
          l_inv_loc_assignment.ATTRIBUTE11                := p_ATTRIBUTE11;
          l_inv_loc_assignment.ATTRIBUTE12                := p_ATTRIBUTE12;
          l_inv_loc_assignment.ATTRIBUTE13                := p_ATTRIBUTE13;
          l_inv_loc_assignment.ATTRIBUTE14                := p_ATTRIBUTE14;
          l_inv_loc_assignment.ATTRIBUTE15                := p_ATTRIBUTE15;
          user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID  := l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID ;
  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Update_Row',
                                      'B', 'C')  THEN
    csp_inv_loc_assignments_cuhk.update_inventory_location_Pre
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Update_Row',
                                      'B', 'V')  THEN
    csp_inv_loc_assignments_vuhk.update_inventory_location_Pre
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

    csp_inv_loc_assignments_iuhk.update_inventory_location_Pre
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Update CSP_INV_LOC_ASSIGNMENTS
    SET
              CREATED_BY = decode( l_inv_loc_assignment.CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, l_inv_loc_assignment.CREATED_BY),
              CREATION_DATE = decode(l_inv_loc_assignment.CREATION_DATE,fnd_api.g_miss_date,creation_date,l_inv_loc_assignment.creation_date),
              LAST_UPDATED_BY = decode( l_inv_loc_assignment.LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, l_inv_loc_assignment.LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(l_inv_loc_assignment.LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,l_inv_loc_assignment.last_update_date),
              LAST_UPDATE_LOGIN = decode( l_inv_loc_assignment.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, l_inv_loc_assignment.LAST_UPDATE_LOGIN),
              RESOURCE_ID = decode( l_inv_loc_assignment.RESOURCE_ID, FND_API.G_MISS_NUM, RESOURCE_ID, l_inv_loc_assignment.RESOURCE_ID),
              ORGANIZATION_ID = decode( l_inv_loc_assignment.ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, l_inv_loc_assignment.ORGANIZATION_ID),
              SUBINVENTORY_CODE = decode( l_inv_loc_assignment.SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, SUBINVENTORY_CODE, l_inv_loc_assignment.SUBINVENTORY_CODE),
              LOCATOR_ID = decode( l_inv_loc_assignment.LOCATOR_ID, FND_API.G_MISS_NUM, LOCATOR_ID, l_inv_loc_assignment.LOCATOR_ID),
              RESOURCE_TYPE = decode( l_inv_loc_assignment.RESOURCE_TYPE, FND_API.G_MISS_CHAR, RESOURCE_TYPE, l_inv_loc_assignment.RESOURCE_TYPE),
              EFFECTIVE_DATE_START = decode( l_inv_loc_assignment.EFFECTIVE_DATE_START, FND_API.G_MISS_DATE, EFFECTIVE_DATE_START, l_inv_loc_assignment.EFFECTIVE_DATE_START),
              EFFECTIVE_DATE_END = decode( l_inv_loc_assignment.EFFECTIVE_DATE_END, FND_API.G_MISS_DATE, EFFECTIVE_DATE_END, l_inv_loc_assignment.EFFECTIVE_DATE_END),
              DEFAULT_CODE = decode( l_inv_loc_assignment.DEFAULT_CODE, FND_API.G_MISS_CHAR, DEFAULT_CODE, l_inv_loc_assignment.DEFAULT_CODE),
              ATTRIBUTE_CATEGORY = decode( l_inv_loc_assignment.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, l_inv_loc_assignment.ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( l_inv_loc_assignment.ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, l_inv_loc_assignment.ATTRIBUTE1),
              ATTRIBUTE2 = decode( l_inv_loc_assignment.ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, l_inv_loc_assignment.ATTRIBUTE2),
              ATTRIBUTE3 = decode( l_inv_loc_assignment.ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, l_inv_loc_assignment.ATTRIBUTE3),
              ATTRIBUTE4 = decode( l_inv_loc_assignment.ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, l_inv_loc_assignment.ATTRIBUTE4),
              ATTRIBUTE5 = decode( l_inv_loc_assignment.ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, l_inv_loc_assignment.ATTRIBUTE5),
              ATTRIBUTE6 = decode( l_inv_loc_assignment.ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, l_inv_loc_assignment.ATTRIBUTE6),
              ATTRIBUTE7 = decode( l_inv_loc_assignment.ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, l_inv_loc_assignment.ATTRIBUTE7),
              ATTRIBUTE8 = decode( l_inv_loc_assignment.ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, l_inv_loc_assignment.ATTRIBUTE8),
              ATTRIBUTE9 = decode( l_inv_loc_assignment.ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, l_inv_loc_assignment.ATTRIBUTE9),
              ATTRIBUTE10 = decode( l_inv_loc_assignment.ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, l_inv_loc_assignment.ATTRIBUTE10),
              ATTRIBUTE11 = decode( l_inv_loc_assignment.ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, l_inv_loc_assignment.ATTRIBUTE11),
              ATTRIBUTE12 = decode( l_inv_loc_assignment.ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, l_inv_loc_assignment.ATTRIBUTE12),
              ATTRIBUTE13 = decode( l_inv_loc_assignment.ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, l_inv_loc_assignment.ATTRIBUTE13),
              ATTRIBUTE14 = decode( l_inv_loc_assignment.ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, l_inv_loc_assignment.ATTRIBUTE14),
              ATTRIBUTE15 = decode( l_inv_loc_assignment.ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, l_inv_loc_assignment.ATTRIBUTE15)
    where CSP_INV_LOC_ASSIGNMENT_ID = l_inv_loc_assignment.CSP_INV_LOC_ASSIGNMENT_ID;

    If (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    End If;

 IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Update_Row',
                                      'A', 'C')  THEN
    csp_inv_loc_assignments_cuhk.update_inventory_location_post
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Update_Row',
                                      'A', 'V')  THEN
    csp_inv_loc_assignments_vuhk.update_inventory_location_Post
                ( px_inv_loc_assignment     => l_inv_loc_assignment ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csp_inv_loc_assignments_iuhk.update_inventory_location_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_CSP_INV_LOC_ASSIGNMENT_ID  NUMBER)
 IS
     l_inv_loc_assignment_id NUMBER;
     l_return_status    varchar2(100);
     l_msg_count        NUMBER;
     l_msg_data         varchar2(1000);
        l_api_name_full    varchar2(50) := 'CSP_INV_LOC_ASSIGNMENTS_PKG.DELETE_ROW';
 BEGIN
	user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID  := p_CSP_INV_LOC_ASSIGNMENT_ID ;
   IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Delete_Row',
                                      'B', 'C')  THEN
    csp_inv_loc_assignments_cuhk.delete_inventory_location_pre
                ( p_inv_loc_assignment_id     => p_CSP_INV_LOC_ASSIGNMENT_ID ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Update_Row',
                                      'B', 'V')  THEN
    csp_inv_loc_assignments_vuhk.delete_inventory_location_pre
                ( p_inv_loc_assignment_id     => p_CSP_INV_LOC_ASSIGNMENT_ID ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csp_inv_loc_assignments_iuhk.delete_inventory_location_Pre
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   DELETE FROM CSP_INV_LOC_ASSIGNMENTS
    WHERE CSP_INV_LOC_ASSIGNMENT_ID = p_CSP_INV_LOC_ASSIGNMENT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Delete_Row',
                                      'A', 'C')  THEN
    csp_inv_loc_assignments_cuhk.delete_inventory_location_post
                ( p_inv_loc_assignment_id     => p_CSP_INV_LOC_ASSIGNMENT_ID ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_INV_LOC_ASSIGNMENTS_PKG',
                                      'Delete_Row',
                                      'A', 'V')  THEN
    csp_inv_loc_assignments_vuhk.delete_inventory_location_Post
                ( p_inv_loc_assignment_id    => p_CSP_INV_LOC_ASSIGNMENT_ID ,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  csp_inv_loc_assignments_iuhk.delete_inventory_location_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

 END Delete_Row;

PROCEDURE Lock_Row(
          p_CSP_INV_LOC_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_LOCATOR_ID    NUMBER,
          p_RESOURCE_TYPE    VARCHAR2,
          p_EFFECTIVE_DATE_START    DATE,
          p_EFFECTIVE_DATE_END    DATE,
          p_DEFAULT_CODE    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_INV_LOC_ASSIGNMENTS
        WHERE CSP_INV_LOC_ASSIGNMENT_ID =  p_CSP_INV_LOC_ASSIGNMENT_ID
        FOR UPDATE of CSP_INV_LOC_ASSIGNMENT_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.CSP_INV_LOC_ASSIGNMENT_ID = p_CSP_INV_LOC_ASSIGNMENT_ID)
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.RESOURCE_ID = p_RESOURCE_ID)
            OR (    ( Recinfo.RESOURCE_ID IS NULL )
                AND (  p_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.SUBINVENTORY_CODE = p_SUBINVENTORY_CODE)
            OR (    ( Recinfo.SUBINVENTORY_CODE IS NULL )
                AND (  p_SUBINVENTORY_CODE IS NULL )))
       AND (    ( Recinfo.LOCATOR_ID = p_LOCATOR_ID)
            OR (    ( Recinfo.LOCATOR_ID IS NULL )
                AND (  p_LOCATOR_ID IS NULL )))
       AND (    ( Recinfo.RESOURCE_TYPE = p_RESOURCE_TYPE)
            OR (    ( Recinfo.RESOURCE_TYPE IS NULL )
                AND (  p_RESOURCE_TYPE IS NULL )))
       AND (    ( Recinfo.EFFECTIVE_DATE_START = p_EFFECTIVE_DATE_START)
            OR (    ( Recinfo.EFFECTIVE_DATE_START IS NULL )
                AND (  p_EFFECTIVE_DATE_START IS NULL )))
       AND (    ( Recinfo.EFFECTIVE_DATE_END = p_EFFECTIVE_DATE_END)
            OR (    ( Recinfo.EFFECTIVE_DATE_END IS NULL )
                AND (  p_EFFECTIVE_DATE_END IS NULL )))
       AND (    ( Recinfo.DEFAULT_CODE = p_DEFAULT_CODE)
            OR (    ( Recinfo.DEFAULT_CODE IS NULL )
                AND (  p_DEFAULT_CODE IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_INV_LOC_ASSIGNMENTS_PKG;

/
