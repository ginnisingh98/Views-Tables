--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_LINES_PKG" as
/* $Header: csptrqlb.pls 120.0.12010000.2 2011/05/27 10:08:10 vmandava ship $ */
-- Start of Comments
-- Package name     : CSP_REQUIREMENT_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptrqlb.pls';
PROCEDURE Insert_Row(
          px_REQUIREMENT_LINE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUIREMENT_HEADER_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_REQUIRED_QUANTITY    NUMBER,
          p_SHIP_COMPLETE_FLAG    VARCHAR2,
          p_LIKELIHOOD    NUMBER,
          p_REVISION    VARCHAR2,
          p_SOURCE_ORGANIZATION_ID    NUMBER,
          p_SOURCE_SUBINVENTORY    VARCHAR2,
          p_ORDERED_QUANTITY    NUMBER,
          p_ORDER_LINE_ID    NUMBER,
          p_RESERVATION_ID    NUMBER,
          p_ORDER_BY_DATE    DATE,
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
          p_ARRIVAL_DATE  DATE,
          p_ITEM_SCRATCHPAD VARCHAR2,
          --p_ITEM_NOT_KNOWN VARCHAR2,
          p_SHIPPING_METHOD_CODE VARCHAR2,
          p_LOCAL_RESERVATION_ID NUMBER,
          p_SOURCED_FROM    VARCHAR2,
          p_DML_MODE VARCHAR2)
 IS
   CURSOR C2 IS SELECT CSP_REQUIREMENT_LINES_S1.nextval FROM sys.dual;
    l_requirement_line CSP_REQUIREMENT_LINES_PVT.Requirement_line_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSP_REQUIREMENT_LINES_PKG.INSERT_ROW';
   l_dml_mode varchar2(10) := p_dml_mode;
BEGIN
          l_requirement_line.REQUIREMENT_LINE_ID := px_REQUIREMENT_LINE_ID ;
          l_requirement_line.CREATED_BY          := p_CREATED_BY;
          l_requirement_line.CREATION_DATE                  := p_CREATION_DATE;
          l_requirement_line.LAST_UPDATED_BY                :=p_LAST_UPDATED_BY;
          l_requirement_line.LAST_UPDATE_DATE               :=p_LAST_UPDATE_DATE;
          l_requirement_line.LAST_UPDATE_LOGIN              :=p_LAST_UPDATE_LOGIN ;
          l_requirement_line.REQUIREMENT_HEADER_ID           :=p_REQUIREMENT_HEADER_ID;
          l_requirement_line.INVENTORY_ITEM_ID               :=p_INVENTORY_ITEM_ID;
          l_requirement_line.UOM_CODE                        := p_UOM_CODE;
          l_requirement_line.REQUIRED_QUANTITY               :=p_REQUIRED_QUANTITY;
          l_requirement_line.SHIP_COMPLETE_FLAG              :=p_SHIP_COMPLETE_FLAG;
          l_requirement_line.LIKELIHOOD                      :=p_LIKELIHOOD ;
          l_requirement_line.REVISION                        :=p_REVISION;
          l_requirement_line.SOURCE_ORGANIZATION_ID          :=p_SOURCE_ORGANIZATION_ID;
          l_requirement_line.SOURCE_SUBINVENTORY             :=p_SOURCE_SUBINVENTORY;
          l_requirement_line.ORDERED_QUANTITY                :=p_ORDERED_QUANTITY ;
          l_requirement_line.ORDER_LINE_ID                   :=p_ORDER_LINE_ID;
          l_requirement_line.RESERVATION_ID                  :=p_RESERVATION_ID;
          l_requirement_line.ORDER_BY_DATE                   :=p_ORDER_BY_DATE;
          l_requirement_line.ATTRIBUTE_CATEGORY              :=p_ATTRIBUTE_CATEGORY;
          l_requirement_line.ATTRIBUTE1                      :=p_ATTRIBUTE1;
          l_requirement_line.ATTRIBUTE2                      :=p_ATTRIBUTE2 ;
          l_requirement_line.ATTRIBUTE3                      :=p_ATTRIBUTE3;
          l_requirement_line.ATTRIBUTE4                      :=p_ATTRIBUTE4;
          l_requirement_line.ATTRIBUTE5                      :=p_ATTRIBUTE5;
          l_requirement_line.ATTRIBUTE6                      :=p_ATTRIBUTE6;
          l_requirement_line.ATTRIBUTE7                      :=p_ATTRIBUTE7;
          l_requirement_line.ATTRIBUTE8                      :=p_ATTRIBUTE8;
          l_requirement_line.ATTRIBUTE9                      :=p_ATTRIBUTE9;
          l_requirement_line.ATTRIBUTE10                     :=p_ATTRIBUTE10;
          l_requirement_line.ATTRIBUTE11                     :=p_ATTRIBUTE11;
          l_requirement_line.ATTRIBUTE12                     :=p_ATTRIBUTE12 ;
          l_requirement_line.ATTRIBUTE13                     :=p_ATTRIBUTE13;
          l_requirement_line.ATTRIBUTE14                     :=p_ATTRIBUTE14;
          l_requirement_line.ATTRIBUTE15                     :=p_ATTRIBUTE15;
          l_requirement_line.ARRIVAL_DATE                    :=p_ARRIVAL_DATE;
          l_requirement_line.ITEM_SCRATCHPAD                 :=p_ITEM_SCRATCHPAD;
          --l_requirement_line.ITEM_NOT_KNOWN VARCHAR2,
          l_requirement_line.SHIPPING_METHOD_CODE            :=p_SHIPPING_METHOD_CODE;
          l_requirement_line.LOCAL_RESERVATION_ID            :=p_LOCAL_RESERVATION_ID;
          l_requirement_line.SOURCED_FROM                    :=p_SOURCED_FROM;

    IF l_dml_mode is null THEN
     l_dml_mode :='BOTH';
    END IF;

    --Pre hook
    IF l_dml_mode <> 'POST' THEN
     IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Insert_Row',
                                      'B', 'C')  THEN

            csp_requirement_lines_cuhk.Create_requirement_line_Pre
                ( px_requirement_line     => l_requirement_line,
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
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Insert_Row',
                                      'B', 'V')  THEN
    csp_requirement_lines_vuhk.Create_requirement_line_Pre
                ( px_requirement_line     => l_requirement_line,
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
    csp_requirement_lines_iuhk.Create_requirement_line_Pre
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_INT_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   If (l_requirement_line.REQUIREMENT_LINE_ID IS NULL) OR (l_requirement_line.REQUIREMENT_LINE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO  px_REQUIREMENT_LINE_ID;
       CLOSE C2;
   End If;
   END IF;
   l_requirement_line.REQUIREMENT_LINE_ID := px_REQUIREMENT_LINE_ID ;
   user_hook_rec.REQUIREMENT_LINE_ID  := l_requirement_line.REQUIREMENT_LINE_ID;
   IF l_dml_mode = 'BOTH' THEN
   INSERT INTO CSP_REQUIREMENT_LINES(
           REQUIREMENT_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUIREMENT_HEADER_ID,
           INVENTORY_ITEM_ID,
           UOM_CODE,
           REQUIRED_QUANTITY,
           SHIP_COMPLETE_FLAG,
           LIKELIHOOD,
           REVISION,
           SOURCE_ORGANIZATION_ID,
           SOURCE_SUBINVENTORY,
           ORDERED_QUANTITY,
           ORDER_LINE_ID,
           RESERVATION_ID,
           ORDER_BY_DATE,
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
           ARRIVAL_DATE,
           ITEM_SCRATCHPAD,
           --ITEM_NOT_KNOWN,
           SHIPPING_METHOD_CODE,
           LOCAL_RESERVATION_ID,
           SOURCED_FROM
         ) VALUES (
            px_REQUIREMENT_LINE_ID,
           decode( l_requirement_line.CREATED_BY, FND_API.G_MISS_NUM, NULL, l_requirement_line.CREATED_BY),
           decode( l_requirement_line.CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_requirement_line.CREATION_DATE),
           decode( l_requirement_line.LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, l_requirement_line.LAST_UPDATED_BY),
           decode( l_requirement_line.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_requirement_line.LAST_UPDATE_DATE),
           decode( l_requirement_line.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, l_requirement_line.LAST_UPDATE_LOGIN),
           decode( l_requirement_line.REQUIREMENT_HEADER_ID, FND_API.G_MISS_NUM, NULL, l_requirement_line.REQUIREMENT_HEADER_ID),
           decode( l_requirement_line.INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, l_requirement_line.INVENTORY_ITEM_ID),
           decode( l_requirement_line.UOM_CODE, FND_API.G_MISS_CHAR, NULL, l_requirement_line.UOM_CODE),
           decode( l_requirement_line.REQUIRED_QUANTITY, FND_API.G_MISS_NUM, NULL, l_requirement_line.REQUIRED_QUANTITY),
           decode( l_requirement_line.SHIP_COMPLETE_FLAG, FND_API.G_MISS_CHAR, NULL, l_requirement_line.SHIP_COMPLETE_FLAG),
           decode( l_requirement_line.LIKELIHOOD, FND_API.G_MISS_NUM, NULL, l_requirement_line.LIKELIHOOD),
           decode( l_requirement_line.REVISION, FND_API.G_MISS_CHAR, NULL, l_requirement_line.REVISION),
           decode( l_requirement_line.SOURCE_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, l_requirement_line.SOURCE_ORGANIZATION_ID),
           decode( l_requirement_line.SOURCE_SUBINVENTORY, FND_API.G_MISS_CHAR, NULL, l_requirement_line.SOURCE_SUBINVENTORY),
           decode( l_requirement_line.ORDERED_QUANTITY, FND_API.G_MISS_NUM, NULL, l_requirement_line.ORDERED_QUANTITY),
           decode( l_requirement_line.ORDER_LINE_ID, FND_API.G_MISS_NUM, NULL, l_requirement_line.ORDER_LINE_ID),
           decode( l_requirement_line.RESERVATION_ID, FND_API.G_MISS_NUM, NULL, l_requirement_line.RESERVATION_ID),
           decode( l_requirement_line.ORDER_BY_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_requirement_line.ORDER_BY_DATE),
           decode( l_requirement_line.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE_CATEGORY),
           decode( l_requirement_line.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE1),
           decode( l_requirement_line.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE2),
           decode( l_requirement_line.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE3),
           decode( l_requirement_line.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE4),
           decode( l_requirement_line.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE5),
           decode( l_requirement_line.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE6),
           decode( l_requirement_line.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE7),
           decode( l_requirement_line.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE8),
           decode( l_requirement_line.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE9),
           decode( l_requirement_line.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE10),
           decode( l_requirement_line.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE11),
           decode( l_requirement_line.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE12),
           decode( l_requirement_line.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE13),
           decode( l_requirement_line.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE14),
           decode( l_requirement_line.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ATTRIBUTE15),
           decode( l_requirement_line.ARRIVAL_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_requirement_line.ARRIVAL_DATE),
           decode( l_requirement_line.ITEM_SCRATCHPAD, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ITEM_SCRATCHPAD),
           --decode( l_requirement_line.ITEM_NOT_KNOWN, FND_API.G_MISS_CHAR, NULL, l_requirement_line.ITEM_NOT_KNOWN),
           decode( l_requirement_line.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR, NULL, l_requirement_line.SHIPPING_METHOD_CODE),
           decode( l_requirement_line.LOCAL_RESERVATION_ID, FND_API.G_MISS_NUM, NULL, l_requirement_line.LOCAL_RESERVATION_ID),
           decode( l_requirement_line.SOURCED_FROM, FND_API.G_MISS_CHAR, NULL, l_requirement_line.SOURCED_FROM)
           );
           END IF;

           --Post hooks
         IF l_dml_mode <> 'PRE' THEN
           IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Insert_Row',
                                      'A', 'C')  THEN

   csp_requirement_lines_cuhk.Create_requirement_line_post
                ( px_requirement_line     => l_requirement_line,
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
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Insert_Row',
                                      'A', 'V')  THEN

    csp_requirement_lines_vuhk.Create_requirement_line_post
                ( px_requirement_line     => l_requirement_line,
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
    user_hook_rec.REQUIREMENT_LINE_ID  := l_requirement_line.REQUIREMENT_LINE_ID;
  csp_requirement_lines_iuhk.Create_requirement_line_post
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
End Insert_Row;
PROCEDURE Update_Row(
          p_REQUIREMENT_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUIREMENT_HEADER_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_REQUIRED_QUANTITY    NUMBER,
          p_SHIP_COMPLETE_FLAG    VARCHAR2,
          p_LIKELIHOOD    NUMBER,
          p_REVISION    VARCHAR2,
          p_SOURCE_ORGANIZATION_ID    NUMBER,
          p_SOURCE_SUBINVENTORY    VARCHAR2,
          p_ORDERED_QUANTITY    NUMBER,
          p_ORDER_LINE_ID    NUMBER,
          p_RESERVATION_ID    NUMBER,
          p_ORDER_BY_DATE    DATE,
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
          p_ARRIVAL_DATE  DATE,
          p_ITEM_SCRATCHPAD VARCHAR2,
          --p_ITEM_NOT_KNOWN VARCHAR2,
          p_SHIPPING_METHOD_CODE VARCHAR2,
          p_LOCAL_RESERVATION_ID NUMBER,
          p_SOURCED_FROM VARCHAR2,
          p_DML_MODE VARCHAR2)
 IS
  l_requirement_line CSP_REQUIREMENT_lines_PVT.Requirement_LINE_Rec_Type;
  l_api_name_full    varchar2(50) := 'CSP_REQUIREMENT_LINES_PKG.UPDATE_ROW';
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_dml_mode varchar2(10) := p_dml_mode;
 BEGIN
    l_requirement_line.REQUIREMENT_LINE_ID := p_REQUIREMENT_LINE_ID ;
          l_requirement_line.CREATED_BY          := p_CREATED_BY;
          l_requirement_line.CREATION_DATE                  := p_CREATION_DATE;
          l_requirement_line.LAST_UPDATED_BY                :=p_LAST_UPDATED_BY;
          l_requirement_line.LAST_UPDATE_DATE               :=p_LAST_UPDATE_DATE;
          l_requirement_line.LAST_UPDATE_LOGIN              :=p_LAST_UPDATE_LOGIN ;
          l_requirement_line.REQUIREMENT_HEADER_ID           :=p_REQUIREMENT_HEADER_ID;
          l_requirement_line.INVENTORY_ITEM_ID               :=p_INVENTORY_ITEM_ID;
          l_requirement_line.UOM_CODE                        := p_UOM_CODE;
          l_requirement_line.REQUIRED_QUANTITY               :=p_REQUIRED_QUANTITY;
          l_requirement_line.SHIP_COMPLETE_FLAG              :=p_SHIP_COMPLETE_FLAG;
          l_requirement_line.LIKELIHOOD                      :=p_LIKELIHOOD ;
          l_requirement_line.REVISION                        :=p_REVISION;
          l_requirement_line.SOURCE_ORGANIZATION_ID          :=p_SOURCE_ORGANIZATION_ID;
          l_requirement_line.SOURCE_SUBINVENTORY             :=p_SOURCE_SUBINVENTORY;
          l_requirement_line.ORDERED_QUANTITY                :=p_ORDERED_QUANTITY ;
          l_requirement_line.ORDER_LINE_ID                   :=p_ORDER_LINE_ID;
          l_requirement_line.RESERVATION_ID                  :=p_RESERVATION_ID;
          l_requirement_line.ORDER_BY_DATE                   :=p_ORDER_BY_DATE;
          l_requirement_line.ATTRIBUTE_CATEGORY              :=p_ATTRIBUTE_CATEGORY;
          l_requirement_line.ATTRIBUTE1                      :=p_ATTRIBUTE1;
          l_requirement_line.ATTRIBUTE2                      :=p_ATTRIBUTE2 ;
          l_requirement_line.ATTRIBUTE3                      :=p_ATTRIBUTE3;
          l_requirement_line.ATTRIBUTE4                      :=p_ATTRIBUTE4;
          l_requirement_line.ATTRIBUTE5                      :=p_ATTRIBUTE5;
          l_requirement_line.ATTRIBUTE6                      :=p_ATTRIBUTE6;
          l_requirement_line.ATTRIBUTE7                      :=p_ATTRIBUTE7;
          l_requirement_line.ATTRIBUTE8                      :=p_ATTRIBUTE8;
          l_requirement_line.ATTRIBUTE9                      :=p_ATTRIBUTE9;
          l_requirement_line.ATTRIBUTE10                     :=p_ATTRIBUTE10;
          l_requirement_line.ATTRIBUTE11                     :=p_ATTRIBUTE11;
          l_requirement_line.ATTRIBUTE12                     :=p_ATTRIBUTE12 ;
          l_requirement_line.ATTRIBUTE13                     :=p_ATTRIBUTE13;
          l_requirement_line.ATTRIBUTE14                     :=p_ATTRIBUTE14;
          l_requirement_line.ATTRIBUTE15                     :=p_ATTRIBUTE15;
          l_requirement_line.ARRIVAL_DATE                    :=p_ARRIVAL_DATE;
          l_requirement_line.ITEM_SCRATCHPAD                 :=p_ITEM_SCRATCHPAD;
          --l_requirement_line.ITEM_NOT_KNOWN VARCHAR2,
          l_requirement_line.SHIPPING_METHOD_CODE            :=p_SHIPPING_METHOD_CODE;
          l_requirement_line.LOCAL_RESERVATION_ID            :=p_LOCAL_RESERVATION_ID;
          l_requirement_line.SOURCED_FROM                    :=p_SOURCED_FROM;
    IF l_dml_mode is null THEN
     l_dml_mode :='BOTH';
    END IF;

    IF l_dml_mode <> 'POST' THEN
    IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Update_Row',
                                      'B', 'C')  THEN

            csp_requirement_lines_cuhk.update_requirement_line_Pre
                ( px_requirement_line     => l_requirement_line,
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
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Update_Row',
                                      'B', 'V')  THEN
    csp_requirement_lines_vuhk.update_requirement_line_Pre
                ( px_requirement_line     => l_requirement_line,
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
   user_hook_rec.REQUIREMENT_LINE_ID  := l_requirement_line.REQUIREMENT_LINE_ID;
    csp_requirement_lines_iuhk.update_requirement_line_Pre
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;
   IF l_dml_mode = 'BOTH' THEN
    Update CSP_REQUIREMENT_LINES
    SET
              CREATED_BY = decode( l_requirement_line.CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, l_requirement_line.CREATED_BY),
              CREATION_DATE = decode( l_requirement_line.CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, l_requirement_line.CREATION_DATE),
              LAST_UPDATED_BY = decode( l_requirement_line.LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, l_requirement_line.LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( l_requirement_line.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, l_requirement_line.LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( l_requirement_line.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, l_requirement_line.LAST_UPDATE_LOGIN),
              REQUIREMENT_HEADER_ID = decode( l_requirement_line.REQUIREMENT_HEADER_ID, FND_API.G_MISS_NUM, REQUIREMENT_HEADER_ID, l_requirement_line.REQUIREMENT_HEADER_ID),
              INVENTORY_ITEM_ID = decode( l_requirement_line.INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, l_requirement_line.INVENTORY_ITEM_ID),
              UOM_CODE = decode( l_requirement_line.UOM_CODE, FND_API.G_MISS_CHAR, UOM_CODE, l_requirement_line.UOM_CODE),
              REQUIRED_QUANTITY = decode( l_requirement_line.REQUIRED_QUANTITY, FND_API.G_MISS_NUM, REQUIRED_QUANTITY, l_requirement_line.REQUIRED_QUANTITY),
              SHIP_COMPLETE_FLAG = decode( l_requirement_line.SHIP_COMPLETE_FLAG, FND_API.G_MISS_CHAR, SHIP_COMPLETE_FLAG, l_requirement_line.SHIP_COMPLETE_FLAG),
              LIKELIHOOD = decode( l_requirement_line.LIKELIHOOD, FND_API.G_MISS_NUM, LIKELIHOOD, l_requirement_line.LIKELIHOOD),
              REVISION = decode( l_requirement_line.REVISION, FND_API.G_MISS_CHAR, REVISION, l_requirement_line.REVISION),
              SOURCE_ORGANIZATION_ID = decode( l_requirement_line.SOURCE_ORGANIZATION_ID, FND_API.G_MISS_NUM, SOURCE_ORGANIZATION_ID, l_requirement_line.SOURCE_ORGANIZATION_ID),
              SOURCE_SUBINVENTORY = decode( l_requirement_line.SOURCE_SUBINVENTORY, FND_API.G_MISS_CHAR, SOURCE_SUBINVENTORY, l_requirement_line.SOURCE_SUBINVENTORY),
              ORDERED_QUANTITY = decode( l_requirement_line.ORDERED_QUANTITY, FND_API.G_MISS_NUM, ORDERED_QUANTITY, l_requirement_line.ORDERED_QUANTITY),
              ORDER_LINE_ID = decode( l_requirement_line.ORDER_LINE_ID, FND_API.G_MISS_NUM, ORDER_LINE_ID, l_requirement_line.ORDER_LINE_ID),
              RESERVATION_ID = decode( l_requirement_line.RESERVATION_ID, FND_API.G_MISS_NUM, RESERVATION_ID, l_requirement_line.RESERVATION_ID),
              ORDER_BY_DATE = decode( l_requirement_line.ORDER_BY_DATE, FND_API.G_MISS_DATE, ORDER_BY_DATE, l_requirement_line.ORDER_BY_DATE),
              ATTRIBUTE_CATEGORY = decode( l_requirement_line.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, l_requirement_line.ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( l_requirement_line.ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, l_requirement_line.ATTRIBUTE1),
              ATTRIBUTE2 = decode( l_requirement_line.ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, l_requirement_line.ATTRIBUTE2),
              ATTRIBUTE3 = decode( l_requirement_line.ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, l_requirement_line.ATTRIBUTE3),
              ATTRIBUTE4 = decode( l_requirement_line.ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, l_requirement_line.ATTRIBUTE4),
              ATTRIBUTE5 = decode( l_requirement_line.ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, l_requirement_line.ATTRIBUTE5),
              ATTRIBUTE6 = decode( l_requirement_line.ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, l_requirement_line.ATTRIBUTE6),
              ATTRIBUTE7 = decode( l_requirement_line.ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, l_requirement_line.ATTRIBUTE7),
              ATTRIBUTE8 = decode( l_requirement_line.ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, l_requirement_line.ATTRIBUTE8),
              ATTRIBUTE9 = decode( l_requirement_line.ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, l_requirement_line.ATTRIBUTE9),
              ATTRIBUTE10 = decode( l_requirement_line.ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, l_requirement_line.ATTRIBUTE10),
              ATTRIBUTE11 = decode( l_requirement_line.ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, l_requirement_line.ATTRIBUTE11),
              ATTRIBUTE12 = decode( l_requirement_line.ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, l_requirement_line.ATTRIBUTE12),
              ATTRIBUTE13 = decode( l_requirement_line.ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, l_requirement_line.ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, l_requirement_line.ATTRIBUTE14),
              ATTRIBUTE15 = decode( l_requirement_line.ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, l_requirement_line.ATTRIBUTE15),
              ARRIVAL_DATE = decode( l_requirement_line.ARRIVAL_DATE, FND_API.G_MISS_DATE, ARRIVAL_DATE, l_requirement_line.ARRIVAL_DATE),
              ITEM_SCRATCHPAD = decode( l_requirement_line.ITEM_SCRATCHPAD, FND_API.G_MISS_CHAR, ITEM_SCRATCHPAD, l_requirement_line.ITEM_SCRATCHPAD),
              --ITEM_NOT_KNOWN = decode( l_requirement_line.ITEM_NOT_KNOWN, FND_API.G_MISS_CHAR, ITEM_NOT_KNOWN, l_requirement_line.ITEM_NOT_KNOWN),
              SHIPPING_METHOD_CODE = decode( l_requirement_line.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR, SHIPPING_METHOD_CODE, l_requirement_line.SHIPPING_METHOD_CODE),
              LOCAL_RESERVATION_ID = decode( l_requirement_line.LOCAL_RESERVATION_ID, FND_API.G_MISS_NUM, LOCAL_RESERVATION_ID, l_requirement_line.LOCAL_RESERVATION_ID),
              SOURCED_FROM = decode( l_requirement_line.SOURCED_FROM, FND_API.G_MISS_CHAR, SOURCED_FROM, l_requirement_line.SOURCED_FROM)
    where REQUIREMENT_LINE_ID = l_requirement_line.REQUIREMENT_LINE_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
    END IF;

    IF l_dml_mode <> 'PRE' THEN
    IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Update_Row',
                                      'A', 'C')  THEN

            csp_requirement_lines_cuhk.update_requirement_line_post
                ( px_requirement_line     => l_requirement_line,
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
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Update_Row',
                                      'A', 'V')  THEN
    csp_requirement_lines_vuhk.update_requirement_line_post
                ( px_requirement_line     => l_requirement_line,
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
 csp_requirement_lines_iuhk.update_requirement_line_post
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END IF;
END Update_Row;
PROCEDURE Delete_Row(
    p_REQUIREMENT_LINE_ID  NUMBER,
    p_DML_MODE VARCHAR2)
 IS
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
      l_api_name_full    varchar2(50) := 'CSP_REQUIREMENT_LINES_PKG.DELETE_ROW';
  l_dml_mode varchar2(10) :=p_dml_mode;
 BEGIN
    IF l_dml_mode is null THEN
     l_dml_mode :='BOTH';
    END IF;

    IF l_dml_mode <> 'POST' THEN
    IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Delete_Row',
                                      'B', 'C')  THEN

            csp_requirement_lines_cuhk.delete_requirement_line_Pre
                ( p_line_id                => p_REQUIREMENT_LINE_ID,
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
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Delete_Row',
                                      'B', 'V')  THEN
    csp_requirement_lines_vuhk.delete_requirement_line_Pre
                ( p_line_id                => p_REQUIREMENT_LINE_ID,
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
   user_hook_rec.REQUIREMENT_LINE_ID  := p_REQUIREMENT_LINE_ID;
 csp_requirement_lines_iuhk.delete_requirement_line_Pre
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF l_dml_mode = 'BOTH' THEN
   DELETE FROM CSP_REQUIREMENT_LINES
    WHERE REQUIREMENT_LINE_ID = p_REQUIREMENT_LINE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
   END IF;

   IF l_dml_mode <> 'PRE' THEN
   IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Delete_Row',
                                      'A', 'C')  THEN

            csp_requirement_lines_cuhk.delete_requirement_line_Post
                ( p_line_id                => p_REQUIREMENT_LINE_ID,
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
  IF jtf_usr_hks.Ok_To_Execute('CSP_REQUIREMENT_LINES_PKG',
                                      'Delete_Row',
                                      'A', 'V')  THEN
    csp_requirement_lines_vuhk.delete_requirement_line_post
                ( p_line_id                => p_REQUIREMENT_LINE_ID,
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
     user_hook_rec.REQUIREMENT_LINE_ID  := p_REQUIREMENT_LINE_ID;
  csp_requirement_lines_iuhk.delete_requirement_line_post
                ( x_return_status          => l_return_status
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END IF;
 END Delete_Row;
PROCEDURE Lock_Row(
          p_REQUIREMENT_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUIREMENT_HEADER_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_REQUIRED_QUANTITY    NUMBER,
          p_SHIP_COMPLETE_FLAG    VARCHAR2,
          p_LIKELIHOOD    NUMBER,
          p_REVISION    VARCHAR2,
          p_SOURCE_ORGANIZATION_ID    NUMBER,
          p_SOURCE_SUBINVENTORY    VARCHAR2,
          p_ORDERED_QUANTITY    NUMBER,
          p_ORDER_LINE_ID    NUMBER,
          p_RESERVATION_ID    NUMBER,
          p_ORDER_BY_DATE    DATE,
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
          p_ARRIVAL_DATE  DATE,
          p_ITEM_SCRATCHPAD VARCHAR2,
          --p_ITEM_NOT_KNOWN VARCHAR2,
          p_SHIPPING_METHOD_CODE VARCHAR2,
          p_LOCAL_RESERVATION_ID NUMBER,
          p_SOURCED_FROM VARCHAR2,
          p_SOURCE_LINE_ID NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM CSP_REQUIREMENT_LINES
        WHERE REQUIREMENT_LINE_ID =  p_REQUIREMENT_LINE_ID
        FOR UPDATE of REQUIREMENT_LINE_ID NOWAIT;
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
           (      Recinfo.REQUIREMENT_LINE_ID = p_REQUIREMENT_LINE_ID)
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
       AND (    ( Recinfo.REQUIREMENT_HEADER_ID = p_REQUIREMENT_HEADER_ID)
            OR (    ( Recinfo.REQUIREMENT_HEADER_ID IS NULL )
                AND (  p_REQUIREMENT_HEADER_ID IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.UOM_CODE = p_UOM_CODE)
            OR (    ( Recinfo.UOM_CODE IS NULL )
                AND (  p_UOM_CODE IS NULL )))
       AND (    ( Recinfo.REQUIRED_QUANTITY = p_REQUIRED_QUANTITY)
            OR (    ( Recinfo.REQUIRED_QUANTITY IS NULL )
                AND (  p_REQUIRED_QUANTITY IS NULL )))
       AND (    ( Recinfo.SHIP_COMPLETE_FLAG = p_SHIP_COMPLETE_FLAG)
            OR (    ( Recinfo.SHIP_COMPLETE_FLAG IS NULL )
                AND (  p_SHIP_COMPLETE_FLAG IS NULL )))
       AND (    ( Recinfo.LIKELIHOOD = p_LIKELIHOOD)
            OR (    ( Recinfo.LIKELIHOOD IS NULL )
                AND (  p_LIKELIHOOD IS NULL )))
       AND (    ( Recinfo.REVISION = p_REVISION)
            OR (    ( Recinfo.REVISION IS NULL )
                AND (  p_REVISION IS NULL )))
       AND (    ( Recinfo.ORDERED_QUANTITY = p_ORDERED_QUANTITY)
            OR (    ( Recinfo.ORDERED_QUANTITY IS NULL )
                AND (  p_ORDERED_QUANTITY IS NULL )))
       AND (    ( Recinfo.ORDER_LINE_ID = p_ORDER_LINE_ID)
            OR (    ( Recinfo.ORDER_LINE_ID IS NULL )
                AND (  p_ORDER_LINE_ID IS NULL )))
       AND (    ( Recinfo.RESERVATION_ID = p_RESERVATION_ID)
            OR (    ( Recinfo.RESERVATION_ID IS NULL )
                AND (  p_RESERVATION_ID IS NULL )))
       AND (    ( Recinfo.ORDER_BY_DATE = p_ORDER_BY_DATE)
            OR (    ( Recinfo.ORDER_BY_DATE IS NULL )
                AND (  p_ORDER_BY_DATE IS NULL )))
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
       AND (    ( Recinfo.ARRIVAL_DATE = p_ARRIVAL_DATE)
            OR (    ( Recinfo.ARRIVAL_DATE IS NULL )
                AND (  p_ARRIVAL_DATE IS NULL )))
       AND (    ( Recinfo.ITEM_SCRATCHPAD = p_ITEM_SCRATCHPAD)
            OR (    ( Recinfo.ITEM_SCRATCHPAD IS NULL )
                AND (  p_ITEM_SCRATCHPAD IS NULL )))
    /*   AND (    ( Recinfo.ITEM_NOT_KNOWN = p_ITEM_NOT_KNOWN)
            OR (    ( Recinfo.ITEM_NOT_KNOWN IS NULL )
                AND (  p_ITEM_NOT_KNOWN IS NULL ))) */
       AND (    ( Recinfo.SHIPPING_METHOD_CODE = p_SHIPPING_METHOD_CODE)
            OR (    ( Recinfo.SHIPPING_METHOD_CODE IS NULL )
                AND (  p_SHIPPING_METHOD_CODE IS NULL )))
       AND (    ( Recinfo.LOCAL_RESERVATION_ID = p_LOCAL_RESERVATION_ID)
            OR (    ( Recinfo.LOCAL_RESERVATION_ID IS NULL )
                AND (  p_LOCAL_RESERVATION_ID IS NULL )))
       AND (    ( Recinfo.SOURCED_FROM = p_SOURCED_FROM)
            OR (    ( Recinfo.SOURCED_FROM IS NULL )
                AND (  p_SOURCED_FROM IS NULL )))
       ) then
       if (p_source_line_id IS NULL) then
         if (  ( Recinfo.SOURCE_ORGANIZATION_ID = p_SOURCE_ORGANIZATION_ID)
               OR (    ( Recinfo.SOURCE_ORGANIZATION_ID IS NULL )
                    AND (  p_SOURCE_ORGANIZATION_ID IS NULL )))
              AND (    ( Recinfo.SOURCE_SUBINVENTORY = p_SOURCE_SUBINVENTORY)
                     OR (    ( Recinfo.SOURCE_SUBINVENTORY IS NULL )
                          AND (  p_SOURCE_SUBINVENTORY IS NULL ))) then
           return;
         else
           FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
           APP_EXCEPTION.RAISE_EXCEPTION;
         end if;
       end if;
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
End CSP_REQUIREMENT_LINES_PKG;

/
