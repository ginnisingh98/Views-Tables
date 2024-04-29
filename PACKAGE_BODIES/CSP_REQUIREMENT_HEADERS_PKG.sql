--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_HEADERS_PKG" as
/* $Header: csptrqhb.pls 120.1.12010000.4 2012/02/13 07:32:59 htank ship $ */
-- Start of Comments
-- Package name     : CSP_REQUIREMENT_HEADERS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_HEADERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptrqhb.pls';

PROCEDURE Insert_Row(
          px_REQUIREMENT_HEADER_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OPEN_REQUIREMENT    VARCHAR2,
          p_SHIP_TO_LOCATION_ID    NUMBER,
          p_TASK_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_SHIPPING_METHOD_CODE    VARCHAR2,
          p_NEED_BY_DATE    DATE,
          p_DESTINATION_ORGANIZATION_ID    NUMBER,
          p_PARTS_DEFINED    VARCHAR2,
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
          p_ATTRIBUTE15    VARCHAR2,
          p_ORDER_TYPE_ID  NUMBER,
          p_ADDRESS_TYPE   VARCHAR2,
          p_RESOURCE_ID    NUMBER,
          p_RESOURCE_TYPE  VARCHAR2,
          p_TIMEZONE_ID    NUMBER,
          p_DESTINATION_SUBINVENTORY varchar2,
          p_SHIP_TO_CONTACT_ID NUMBER,
          p_DML_MODE VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSP_REQUIREMENT_HEADERS_S1.nextval FROM sys.dual;
   l_requirement_header CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSP_REQUIREMENT_HEADERS_PKG.INSERT_ROW';
   l_dml_mode    varchar2(10) :=p_DML_MODE;
BEGIN
       l_requirement_header.REQUIREMENT_HEADER_ID  :=     px_REQUIREMENT_HEADER_ID;
       l_requirement_header.CREATED_BY             :=     p_CREATED_BY;
       l_requirement_header.CREATION_DATE          :=     p_CREATION_DATE;
       l_requirement_header.LAST_UPDATED_BY        :=     p_LAST_UPDATED_BY ;
       l_requirement_header.LAST_UPDATE_DATE       :=     p_LAST_UPDATE_DATE ;
       l_requirement_header.LAST_UPDATE_LOGIN      :=     p_LAST_UPDATE_LOGIN  ;
       l_requirement_header.OPEN_REQUIREMENT       :=     p_OPEN_REQUIREMENT   ;
       l_requirement_header.SHIP_TO_LOCATION_ID    :=     p_SHIP_TO_LOCATION_ID  ;
       l_requirement_header.TASK_ID                :=     p_TASK_ID  ;
       l_requirement_header.TASK_ASSIGNMENT_ID     :=     p_TASK_ASSIGNMENT_ID ;
       l_requirement_header.SHIPPING_METHOD_CODE    :=    p_SHIPPING_METHOD_CODE;
       l_requirement_header.NEED_BY_DATE            :=    p_NEED_BY_DATE   ;
       l_requirement_header.DESTINATION_ORGANIZATION_ID  :=     p_DESTINATION_ORGANIZATION_ID;
       l_requirement_header.PARTS_DEFINED                :=     p_PARTS_DEFINED;
       l_requirement_header.ATTRIBUTE_CATEGORY           :=     p_ATTRIBUTE_CATEGORY;
       l_requirement_header.ATTRIBUTE1                   :=     p_ATTRIBUTE1;
       l_requirement_header.ATTRIBUTE2                   :=     p_ATTRIBUTE2;
       l_requirement_header.ATTRIBUTE3                   :=     p_ATTRIBUTE3;
       l_requirement_header.ATTRIBUTE4                   :=     p_ATTRIBUTE4;
       l_requirement_header.ATTRIBUTE5                   :=     p_ATTRIBUTE5;
       l_requirement_header.ATTRIBUTE6                   :=     p_ATTRIBUTE6;
       l_requirement_header.ATTRIBUTE7                   :=     p_ATTRIBUTE7;
       l_requirement_header.ATTRIBUTE8                   :=     p_ATTRIBUTE8;
       l_requirement_header.ATTRIBUTE9                   :=     p_ATTRIBUTE9;
       l_requirement_header.ATTRIBUTE10                  :=     p_ATTRIBUTE10;
       l_requirement_header.ATTRIBUTE11                  :=     p_ATTRIBUTE11;
       l_requirement_header.ATTRIBUTE12                  :=     p_ATTRIBUTE12;
       l_requirement_header.ATTRIBUTE13                  :=     p_ATTRIBUTE13;
       l_requirement_header.ATTRIBUTE14                  :=     p_ATTRIBUTE14;
       l_requirement_header.ATTRIBUTE15                  :=     p_ATTRIBUTE15;
       l_requirement_header.ORDER_TYPE_ID                :=     p_ORDER_TYPE_ID;
       l_requirement_header.ADDRESS_TYPE                 :=     p_ADDRESS_TYPE;
       l_requirement_header.RESOURCE_ID                  :=     p_RESOURCE_ID ;
       l_requirement_header.RESOURCE_TYPE                :=     p_RESOURCE_TYPE;
       l_requirement_header.TIMEZONE_ID                  :=     p_TIMEZONE_ID;
       l_requirement_header.DESTINATION_SUBINVENTORY     :=     p_DESTINATION_SUBINVENTORY;
       l_requirement_header.SHIP_TO_CONTACT_ID           :=     p_SHIP_TO_CONTACT_ID;
    --Check for DML Mode
    IF l_dml_mode is null then
       l_dml_mode := 'BOTH';
    END IF;
    --Pre hook
    IF l_dml_mode <> 'POST' THEN
      IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                        'Insert_Row',
                                        'B', 'C')  THEN

              csp_requirement_headers_cuhk.Create_requirement_header_Pre
                  ( px_requirement_header     => l_requirement_header,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data
                  ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
        FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_CUST_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;


  -- Pre call to the Vertical Type User Hook
  --
    IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                        'Insert_Row',
                                        'B', 'V')  THEN
      csp_requirement_headers_vuhk.Create_requirement_header_Pre
                  ( px_requirement_header     => l_requirement_header,
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

  csp_requirement_headers_iuhk.Create_requirement_header_Pre
                ( x_return_status          => l_return_status
                ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
        FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     If (l_requirement_header.REQUIREMENT_HEADER_ID IS NULL) OR (l_requirement_header.REQUIREMENT_HEADER_ID = FND_API.G_MISS_NUM) then
         OPEN C2;
         FETCH C2 INTO px_REQUIREMENT_HEADER_ID;
         CLOSE C2;
     End If;
  END IF;
   	l_requirement_header.REQUIREMENT_HEADER_ID  :=     px_REQUIREMENT_HEADER_ID;
	user_hooks_rec.REQUIREMENT_HEADER_ID   := l_requirement_header.REQUIREMENT_HEADER_ID;
  IF l_dml_mode = 'BOTH' THEN
   INSERT INTO CSP_REQUIREMENT_HEADERS(
           REQUIREMENT_HEADER_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OPEN_REQUIREMENT,
           SHIP_TO_LOCATION_ID,
           TASK_ID,
           TASK_ASSIGNMENT_ID,
           SHIPPING_METHOD_CODE,
           NEED_BY_DATE,
           DESTINATION_ORGANIZATION_ID,
           PARTS_DEFINED,
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
           ATTRIBUTE15,
           ORDER_TYPE_ID,
           ADDRESS_TYPE,
           RESOURCE_ID,
           RESOURCE_TYPE,
           --TIMEZONE_ID,
           DESTINATION_SUBINVENTORY,
           SHIP_TO_CONTACT_ID
         ) VALUES (
           px_REQUIREMENT_HEADER_ID,
           decode( l_requirement_header.CREATED_BY, FND_API.G_MISS_NUM, NULL, l_requirement_header.CREATED_BY),
           decode( l_requirement_header.CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_requirement_header.CREATION_DATE),
           decode( l_requirement_header.LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, l_requirement_header.LAST_UPDATED_BY),
           decode( l_requirement_header.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_requirement_header.LAST_UPDATE_DATE),
           decode( l_requirement_header.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, l_requirement_header.LAST_UPDATE_LOGIN),
           decode( l_requirement_header.OPEN_REQUIREMENT, FND_API.G_MISS_CHAR, NULL, l_requirement_header.OPEN_REQUIREMENT),
           decode( l_requirement_header.SHIP_TO_LOCATION_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.SHIP_TO_LOCATION_ID),
           decode( l_requirement_header.TASK_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.TASK_ID),
           decode( l_requirement_header.TASK_ASSIGNMENT_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.TASK_ASSIGNMENT_ID),
           decode( l_requirement_header.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR, NULL, l_requirement_header.SHIPPING_METHOD_CODE),
           decode( l_requirement_header.NEED_BY_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_requirement_header.NEED_BY_DATE),
           decode( l_requirement_header.DESTINATION_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.DESTINATION_ORGANIZATION_ID),
           decode( l_requirement_header.PARTS_DEFINED, FND_API.G_MISS_CHAR, NULL, l_requirement_header.PARTS_DEFINED),
           decode( l_requirement_header.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE_CATEGORY),
           decode( l_requirement_header.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE1),
           decode( l_requirement_header.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE2),
           decode( l_requirement_header.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE3),
           decode( l_requirement_header.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE4),
           decode( l_requirement_header.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE5),
           decode( l_requirement_header.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE6),
           decode( l_requirement_header.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE7),
           decode( l_requirement_header.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE8),
           decode( l_requirement_header.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE9),
           decode( l_requirement_header.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE10),
           decode( l_requirement_header.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE11),
           decode( l_requirement_header.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE12),
           decode( l_requirement_header.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( l_requirement_header.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE14),
           decode( l_requirement_header.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ATTRIBUTE15),
           decode( l_requirement_header.ORDER_TYPE_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.ORDER_TYPE_ID),
           decode( l_requirement_header.ADDRESS_TYPE, FND_API.G_MISS_CHAR, NULL, l_requirement_header.ADDRESS_TYPE),
           decode( l_requirement_header.RESOURCE_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.RESOURCE_ID),
           decode( l_requirement_header.RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, l_requirement_header.RESOURCE_TYPE),
           --decode( l_requirement_header.TIMEZONE_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.TIMEZONE_ID),
           decode( l_requirement_header.DESTINATION_SUBINVENTORY, FND_API.G_MISS_CHAR, NULL, l_requirement_header.DESTINATION_SUBINVENTORY),
           decode( l_requirement_header.SHIP_TO_CONTACT_ID, FND_API.G_MISS_NUM, NULL, l_requirement_header.SHIP_TO_CONTACT_ID)
           );
     END IF;

     --Post hook
     IF l_dml_mode <> 'PRE' THEN
           IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                      'Insert_Row',
                                      'A', 'C')  THEN

   csp_requirement_headers_cuhk.Create_requirement_header_post
                ( px_requirement_header     => l_requirement_header,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                      'Insert_Row',
                                      'A', 'V')  THEN

    csp_requirement_headers_vuhk.Create_requirement_header_post
                ( px_requirement_header     => l_requirement_header,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csp_requirement_headers_iuhk.Create_requirement_header_post
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
End Insert_Row;

PROCEDURE Update_Row(
          p_REQUIREMENT_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OPEN_REQUIREMENT    VARCHAR2,
          p_SHIP_TO_LOCATION_ID    NUMBER,
          p_TASK_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_SHIPPING_METHOD_CODE    VARCHAR2,
          p_NEED_BY_DATE    DATE,
          p_DESTINATION_ORGANIZATION_ID    NUMBER,
          p_PARTS_DEFINED    VARCHAR2,
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
          p_ATTRIBUTE15    VARCHAR2,
          p_ORDER_TYPE_ID  NUMBER,
          p_ADDRESS_TYPE   VARCHAR2,
          p_resource_id     NUMBER,
          p_resource_type   VARCHAR2,
          p_TIMEZONE_ID     NUMBER,
          P_DESTINATION_SUBINVENTORY VARCHAR2,
          p_SHIP_TO_CONTACT_ID  NUMBER,
          p_DML_MODE VARCHAR2)

 IS
   l_requirement_header CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSP_REQUIREMENT_HEADERS_PKG.UPDATE_ROW';
   l_dml_mode  varchar2(10) := p_dml_mode;
 BEGIN
        l_requirement_header.REQUIREMENT_HEADER_ID  :=     p_REQUIREMENT_HEADER_ID;
       l_requirement_header.CREATED_BY             :=     p_CREATED_BY;
       l_requirement_header.CREATION_DATE          :=     p_CREATION_DATE;
       l_requirement_header.LAST_UPDATED_BY        :=     p_LAST_UPDATED_BY ;
       l_requirement_header.LAST_UPDATE_DATE       :=     p_LAST_UPDATE_DATE ;
       l_requirement_header.LAST_UPDATE_LOGIN      :=     p_LAST_UPDATE_LOGIN  ;
       l_requirement_header.OPEN_REQUIREMENT       :=     p_OPEN_REQUIREMENT   ;
       l_requirement_header.SHIP_TO_LOCATION_ID    :=     p_SHIP_TO_LOCATION_ID  ;
       l_requirement_header.TASK_ID                :=     p_TASK_ID  ;
       l_requirement_header.TASK_ASSIGNMENT_ID     :=     p_TASK_ASSIGNMENT_ID ;
       l_requirement_header.SHIPPING_METHOD_CODE    :=    p_SHIPPING_METHOD_CODE;
       l_requirement_header.NEED_BY_DATE            :=    p_NEED_BY_DATE   ;
       l_requirement_header.DESTINATION_ORGANIZATION_ID  :=     p_DESTINATION_ORGANIZATION_ID;
       l_requirement_header.PARTS_DEFINED                :=     p_PARTS_DEFINED;
       l_requirement_header.ATTRIBUTE_CATEGORY           :=     p_ATTRIBUTE_CATEGORY;
       l_requirement_header.ATTRIBUTE1                   :=     p_ATTRIBUTE1;
       l_requirement_header.ATTRIBUTE2                   :=     p_ATTRIBUTE2;
       l_requirement_header.ATTRIBUTE3                   :=     p_ATTRIBUTE3;
       l_requirement_header.ATTRIBUTE4                   :=     p_ATTRIBUTE4;
       l_requirement_header.ATTRIBUTE5                   :=     p_ATTRIBUTE5;
       l_requirement_header.ATTRIBUTE6                   :=     p_ATTRIBUTE6;
       l_requirement_header.ATTRIBUTE7                   :=     p_ATTRIBUTE7;
       l_requirement_header.ATTRIBUTE8                   :=     p_ATTRIBUTE8;
       l_requirement_header.ATTRIBUTE9                   :=     p_ATTRIBUTE9;
       l_requirement_header.ATTRIBUTE10                  :=     p_ATTRIBUTE10;
       l_requirement_header.ATTRIBUTE11                  :=     p_ATTRIBUTE11;
       l_requirement_header.ATTRIBUTE12                  :=     p_ATTRIBUTE12;
       l_requirement_header.ATTRIBUTE13                  :=     p_ATTRIBUTE13;
       l_requirement_header.ATTRIBUTE14                  :=     p_ATTRIBUTE14;
       l_requirement_header.ATTRIBUTE15                  :=     p_ATTRIBUTE15;
       l_requirement_header.ORDER_TYPE_ID                :=     p_ORDER_TYPE_ID;
       l_requirement_header.ADDRESS_TYPE                 :=     p_ADDRESS_TYPE;
       l_requirement_header.RESOURCE_ID                  :=     p_RESOURCE_ID ;
       l_requirement_header.RESOURCE_TYPE                :=     p_RESOURCE_TYPE;
       l_requirement_header.TIMEZONE_ID                  :=     p_TIMEZONE_ID;
       l_requirement_header.DESTINATION_SUBINVENTORY     :=     p_DESTINATION_SUBINVENTORY;
       l_requirement_header.SHIP_TO_CONTACT_ID           :=     p_SHIP_TO_CONTACT_ID;

    IF l_dml_mode is null THEN
      l_dml_mode := 'BOTH';
    END IF;

    IF L_dml_mode <> 'POST' THEN
      IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                        'Update_Row',
                                        'B', 'C')  THEN

              csp_requirement_headers_cuhk.update_requirement_header_Pre
                  ( px_requirement_header     => l_requirement_header,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data
                  ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
        FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_CUST_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;


  -- Pre call to the Vertical Type User Hook
  --
    IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                        'Update_Row',
                                        'B', 'V')  THEN
      csp_requirement_headers_vuhk.update_requirement_header_Pre
                  ( px_requirement_header     => l_requirement_header,
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
      user_hooks_rec.REQUIREMENT_HEADER_ID   := l_requirement_header.REQUIREMENT_HEADER_ID;
    csp_requirement_headers_iuhk.update_requirement_header_Pre
                  ( x_return_status          => l_return_status
                  ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
        FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF l_dml_mode = 'BOTH' THEN
    Update CSP_REQUIREMENT_HEADERS
    SET
              CREATED_BY = decode( l_requirement_header.CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, l_requirement_header.CREATED_BY),
              CREATION_DATE = decode( l_requirement_header.CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, l_requirement_header.CREATION_DATE),
              LAST_UPDATED_BY = decode( l_requirement_header.LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, l_requirement_header.LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( l_requirement_header.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, l_requirement_header.LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( l_requirement_header.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, l_requirement_header.LAST_UPDATE_LOGIN),
              OPEN_REQUIREMENT = decode( l_requirement_header.OPEN_REQUIREMENT, FND_API.G_MISS_CHAR, OPEN_REQUIREMENT, l_requirement_header.OPEN_REQUIREMENT),
              SHIP_TO_LOCATION_ID = decode( l_requirement_header.SHIP_TO_LOCATION_ID, FND_API.G_MISS_NUM, SHIP_TO_LOCATION_ID, l_requirement_header.SHIP_TO_LOCATION_ID),
              TASK_ID = decode( l_requirement_header.TASK_ID, FND_API.G_MISS_NUM, TASK_ID, l_requirement_header.TASK_ID),
              TASK_ASSIGNMENT_ID = decode( l_requirement_header.TASK_ASSIGNMENT_ID, FND_API.G_MISS_NUM, TASK_ASSIGNMENT_ID, l_requirement_header.TASK_ASSIGNMENT_ID),
              SHIPPING_METHOD_CODE = decode( l_requirement_header.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR, SHIPPING_METHOD_CODE, l_requirement_header.SHIPPING_METHOD_CODE),
              NEED_BY_DATE = decode( l_requirement_header.NEED_BY_DATE, FND_API.G_MISS_DATE, NEED_BY_DATE, l_requirement_header.NEED_BY_DATE),
              DESTINATION_ORGANIZATION_ID = decode( l_requirement_header.DESTINATION_ORGANIZATION_ID, FND_API.G_MISS_NUM, DESTINATION_ORGANIZATION_ID, l_requirement_header.DESTINATION_ORGANIZATION_ID),
              PARTS_DEFINED = decode( l_requirement_header.PARTS_DEFINED, FND_API.G_MISS_CHAR, PARTS_DEFINED, l_requirement_header.PARTS_DEFINED),
              ATTRIBUTE_CATEGORY = decode( l_requirement_header.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, l_requirement_header.ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( l_requirement_header.ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, l_requirement_header.ATTRIBUTE1),
              ATTRIBUTE2 = decode( l_requirement_header.ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, l_requirement_header.ATTRIBUTE2),
              ATTRIBUTE3 = decode( l_requirement_header.ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, l_requirement_header.ATTRIBUTE3),
              ATTRIBUTE4 = decode( l_requirement_header.ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, l_requirement_header.ATTRIBUTE4),
              ATTRIBUTE5 = decode( l_requirement_header.ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, l_requirement_header.ATTRIBUTE5),
              ATTRIBUTE6 = decode( l_requirement_header.ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, l_requirement_header.ATTRIBUTE6),
              ATTRIBUTE7 = decode( l_requirement_header.ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, l_requirement_header.ATTRIBUTE7),
              ATTRIBUTE8 = decode( l_requirement_header.ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, l_requirement_header.ATTRIBUTE8),
              ATTRIBUTE9 = decode( l_requirement_header.ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, l_requirement_header.ATTRIBUTE9),
              ATTRIBUTE10 = decode( l_requirement_header.ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, l_requirement_header.ATTRIBUTE10),
              ATTRIBUTE11 = decode( l_requirement_header.ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, l_requirement_header.ATTRIBUTE11),
              ATTRIBUTE12 = decode( l_requirement_header.ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, l_requirement_header.ATTRIBUTE12),
              ATTRIBUTE13 = decode( l_requirement_header.ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, l_requirement_header.ATTRIBUTE13),
              ATTRIBUTE14 = decode( l_requirement_header.ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, l_requirement_header.ATTRIBUTE14),
              ATTRIBUTE15 = decode( l_requirement_header.ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, l_requirement_header.ATTRIBUTE15),
              ORDER_TYPE_ID = decode( l_requirement_header.ORDER_TYPE_ID, FND_API.G_MISS_NUM, ORDER_TYPE_ID, l_requirement_header.ORDER_TYPE_ID),
              ADDRESS_TYPE = decode( l_requirement_header.ADDRESS_TYPE, FND_API.G_MISS_CHAR, ADDRESS_TYPE, l_requirement_header.ADDRESS_TYPE),
              RESOURCE_ID = decode( l_requirement_header.RESOURCE_ID, FND_API.G_MISS_NUM, RESOURCE_ID, l_requirement_header.RESOURCE_ID),
              RESOURCE_TYPE = decode( l_requirement_header.RESOURCE_TYPE, FND_API.G_MISS_CHAR,RESOURCE_TYPE, l_requirement_header.RESOURCE_TYPE),
              --TIMEZONE_ID = decode( l_requirement_header.TIMEZONE_ID, FND_API.G_MISS_NUM, TIMEZONE_ID, l_requirement_header.TIMEZONE_ID),
              DESTINATION_SUBINVENTORY = decode( l_requirement_header.DESTINATION_SUBINVENTORY, FND_API.G_MISS_CHAR, DESTINATION_SUBINVENTORY, l_requirement_header.DESTINATION_SUBINVENTORY),
              SHIP_TO_CONTACT_ID = decode( l_requirement_header.SHIP_TO_CONTACT_ID, FND_API.G_MISS_NUM, SHIP_TO_CONTACT_ID, l_requirement_header.SHIP_TO_CONTACT_ID)
    where REQUIREMENT_HEADER_ID = l_requirement_header.REQUIREMENT_HEADER_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
    END IF;
    --Post hook
    IF l_dml_mode <> 'PRE' THEN
      IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                        'Update_Row',
                                        'A', 'C')  THEN

              csp_requirement_headers_cuhk.update_requirement_header_post
                  ( px_requirement_header     => l_requirement_header,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data
                  ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
        FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_CUST_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;


    -- Pre call to the Vertical Type User Hook
    --
    IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                        'Update_Row',
                                        'A', 'V')  THEN
      csp_requirement_headers_vuhk.update_requirement_header_post
                  ( px_requirement_header     => l_requirement_header,
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
    csp_requirement_headers_iuhk.update_requirement_header_post
                  ( x_return_status          => l_return_status
                  ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
        FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_REQUIREMENT_HEADER_ID  NUMBER,
    p_DML_MODE VARCHAR2)
 IS
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSP_REQUIREMENT_HEADERS_PKG.DELETE_ROW';
   l_dml_mode  varchar2(10) := p_DML_MODE;
 BEGIN
    IF l_dml_mode is null THEN
      l_dml_mode := 'BOTH';
    END IF;

    IF l_dml_mode <> 'POST' THEN
     IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                      'Delete_Row',
                                      'B', 'C')  THEN

            csp_requirement_headers_cuhk.Delete_requirement_header_pre
                  (
                  p_header_id              => p_REQUIREMENT_HEADER_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                      'Delete_Row',
                                      'B', 'V')  THEN
    csp_requirement_headers_vuhk.Delete_requirement_header_pre
                  (
                  p_header_id              => p_REQUIREMENT_HEADER_ID,
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
    user_hooks_rec.REQUIREMENT_HEADER_ID   := p_REQUIREMENT_HEADER_ID;
  csp_requirement_headers_iuhk.delete_requirement_header_Pre
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF l_dml_mode = 'BOTH' THEN
   DELETE FROM CSP_REQUIREMENT_HEADERS
    WHERE REQUIREMENT_HEADER_ID = p_REQUIREMENT_HEADER_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
   END IF;

   IF l_dml_mode <> 'PRE' THEN
    IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                      'Delete_Row',
                                      'A', 'C')  THEN

            csp_requirement_headers_cuhk.Delete_requirement_header_post
                  (
                  p_header_id              => p_REQUIREMENT_HEADER_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_HEADERS_PKG',
                                      'Delete_Row',
                                      'A', 'V')  THEN
    csp_requirement_headers_vuhk.Delete_requirement_header_post
                  (
                  p_header_id              => p_REQUIREMENT_HEADER_ID,
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
  csp_requirement_headers_iuhk.delete_requirement_header_post
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_REQUIREMENT_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OPEN_REQUIREMENT    VARCHAR2,
          p_SHIP_TO_LOCATION_ID    NUMBER,
          p_TASK_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_SHIPPING_METHOD_CODE    VARCHAR2,
          p_NEED_BY_DATE    DATE,
          p_DESTINATION_ORGANIZATION_ID    NUMBER,
          p_PARTS_DEFINED    VARCHAR2,
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
          p_ATTRIBUTE15    VARCHAR2,
          p_ORDER_TYPE_ID  NUMBER,
          p_ADDRESS_TYPE   VARCHAR2,
          p_resource_id     NUMBER,
          p_resource_type   VARCHAR2,
          p_TIMEZONE_ID	    NUMBER,
          P_DESTINATION_SUBINVENTORY VARCHAR2,
          p_SHIP_TO_CONTACT_ID NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_REQUIREMENT_HEADERS
        WHERE REQUIREMENT_HEADER_ID =  p_REQUIREMENT_HEADER_ID
        FOR UPDATE of REQUIREMENT_HEADER_ID NOWAIT;
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
           (      Recinfo.REQUIREMENT_HEADER_ID = p_REQUIREMENT_HEADER_ID)
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
       AND (    ( Recinfo.OPEN_REQUIREMENT = p_OPEN_REQUIREMENT)
            OR (    ( Recinfo.OPEN_REQUIREMENT IS NULL )
                AND (  p_OPEN_REQUIREMENT IS NULL )))
       AND (    ( Recinfo.SHIP_TO_LOCATION_ID = p_SHIP_TO_LOCATION_ID)
            OR (    ( Recinfo.SHIP_TO_LOCATION_ID IS NULL )
                AND (  p_SHIP_TO_LOCATION_ID IS NULL )))
       AND (    ( Recinfo.TASK_ID = p_TASK_ID)
            OR (    ( Recinfo.TASK_ID IS NULL )
                AND (  p_TASK_ID IS NULL )))
       AND (    ( Recinfo.TASK_ASSIGNMENT_ID = p_TASK_ASSIGNMENT_ID)
            OR (    ( Recinfo.TASK_ASSIGNMENT_ID IS NULL )
                AND (  p_TASK_ASSIGNMENT_ID IS NULL )))
       AND (    ( Recinfo.SHIPPING_METHOD_CODE = p_SHIPPING_METHOD_CODE)
            OR (    ( Recinfo.SHIPPING_METHOD_CODE IS NULL )
                AND (  p_SHIPPING_METHOD_CODE IS NULL )))
       AND (    ( Recinfo.NEED_BY_DATE = p_NEED_BY_DATE)
            OR (    ( Recinfo.NEED_BY_DATE IS NULL )
                AND (  p_NEED_BY_DATE IS NULL )))
       AND (    ( Recinfo.DESTINATION_ORGANIZATION_ID = p_DESTINATION_ORGANIZATION_ID)
            OR (    ( Recinfo.DESTINATION_ORGANIZATION_ID IS NULL )
                AND (  p_DESTINATION_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.PARTS_DEFINED = p_PARTS_DEFINED)
            OR (    ( Recinfo.PARTS_DEFINED IS NULL )
                AND (  p_PARTS_DEFINED IS NULL )))
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
       AND (    ( Recinfo.ORDER_TYPE_ID = p_ORDER_TYPE_ID)
            OR (    ( Recinfo.ORDER_TYPE_ID IS NULL )
                AND (  p_ORDER_TYPE_ID IS NULL )))
       AND (    ( Recinfo.ADDRESS_TYPE = p_ADDRESS_TYPE)
            OR (    ( Recinfo.ADDRESS_TYPE IS NULL )
                AND (  p_ADDRESS_TYPE IS NULL )))
       AND (    ( Recinfo.RESOURCE_ID = p_RESOURCE_ID)
            OR (    ( Recinfo.RESOURCE_ID IS NULL )
                AND (  p_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.RESOURCE_TYPE = p_RESOURCE_TYPE)
            OR (    ( Recinfo.RESOURCE_TYPE IS NULL )
                AND (  p_RESOURCE_TYPE IS NULL )))
       /*AND (    ( Recinfo.TIMEZONE_ID = p_TIMEZONE_ID)
            OR (    ( Recinfo.TIMEZONE_ID IS NULL )
                AND (  p_TIMEZONE_ID IS NULL )))*/
       AND (    ( Recinfo.DESTINATION_SUBINVENTORY = p_DESTINATION_SUBINVENTORY)
            OR (    ( Recinfo.DESTINATION_SUBINVENTORY IS NULL )
                AND (  p_DESTINATION_SUBINVENTORY IS NULL )))
        AND (    ( Recinfo.SHIP_TO_CONTACT_ID = p_SHIP_TO_CONTACT_ID)
                    OR (    ( Recinfo.SHIP_TO_CONTACT_ID IS NULL )
                        AND (  p_SHIP_TO_CONTACT_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_REQUIREMENT_HEADERS_PKG;

/
