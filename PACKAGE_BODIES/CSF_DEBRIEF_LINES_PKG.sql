--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_LINES_PKG" as
/* $Header: csftdblb.pls 120.2.12010000.2 2008/08/05 18:21:24 syenduri ship $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_DEBRIEF_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csftdblb.pls';

PROCEDURE Insert_Row(
          px_DEBRIEF_LINE_ID   IN OUT NOCOPY NUMBER,
          p_DEBRIEF_HEADER_ID    NUMBER,
          p_DEBRIEF_LINE_NUMBER    NUMBER,
          p_SERVICE_DATE    DATE,
          p_BUSINESS_PROCESS_ID    NUMBER,
          p_TXN_BILLING_TYPE_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_INSTANCE_ID          NUMBER,
          p_ISSUING_INVENTORY_ORG_ID    NUMBER,
          p_RECEIVING_INVENTORY_ORG_ID    NUMBER,
          p_ISSUING_SUB_INVENTORY_CODE    VARCHAR2,
          p_RECEIVING_SUB_INVENTORY_CODE    VARCHAR2,
          p_ISSUING_LOCATOR_ID    NUMBER,
          p_RECEIVING_LOCATOR_ID    NUMBER,
          p_PARENT_PRODUCT_ID    NUMBER,
          p_REMOVED_PRODUCT_ID    NUMBER,
          p_STATUS_OF_RECEIVED_PART    VARCHAR2,
          p_ITEM_SERIAL_NUMBER    VARCHAR2,
          p_ITEM_REVISION    VARCHAR2,
          p_ITEM_LOTNUMBER    VARCHAR2,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_RMA_HEADER_ID    NUMBER,
          p_DISPOSITION_CODE    VARCHAR2,
          p_MATERIAL_REASON_CODE    VARCHAR2,
          p_LABOR_REASON_CODE    VARCHAR2,
          p_EXPENSE_REASON_CODE    VARCHAR2,
          p_LABOR_START_DATE    DATE,
          p_LABOR_END_DATE    DATE,
          p_STARTING_MILEAGE    NUMBER,
          p_ENDING_MILEAGE    NUMBER,
          p_EXPENSE_AMOUNT    NUMBER,
          p_CURRENCY_CODE    VARCHAR2,
          p_DEBRIEF_LINE_STATUS_ID    NUMBER,
          p_RETURN_REASON_CODE VARCHAR2,
          p_CHANNEL_CODE    VARCHAR2,
          p_CHARGE_UPLOAD_STATUS    VARCHAR2,
          p_CHARGE_UPLOAD_MSG_CODE    VARCHAR2,
          p_CHARGE_UPLOAD_MESSAGE    VARCHAR2,
          p_IB_UPDATE_STATUS    VARCHAR2,
          p_IB_UPDATE_MSG_CODE    VARCHAR2,
          p_IB_UPDATE_MESSAGE    VARCHAR2,
          p_SPARE_UPDATE_STATUS    VARCHAR2,
          p_SPARE_UPDATE_MSG_CODE    VARCHAR2,
          p_SPARE_UPDATE_MESSAGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          P_TRANSACTION_TYPE_ID NUMBER,
          P_RETURN_DATE     DATE,
          p_DML_mode            VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSF_DEBRIEF_LINES_S.nextval FROM sys.dual;

   l_debrief_line   CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSF_DEBRIEF_LINES_PKG.INSERT_ROW';
   l_dml_mode 		  varchar2(10) := p_DML_mode;
BEGIN
--dbms_output.put_line('Inserting Row ');
          l_debrief_line.DEBRIEF_LINE_ID:= px_DEBRIEF_LINE_ID  ;
           l_debrief_line.DEBRIEF_HEADER_ID:= p_DEBRIEF_HEADER_ID    ;
          l_debrief_line.DEBRIEF_LINE_NUMBER:=p_DEBRIEF_LINE_NUMBER    ;
          l_debrief_line.SERVICE_DATE:=p_SERVICE_DATE   ;
          l_debrief_line.BUSINESS_PROCESS_ID:=p_BUSINESS_PROCESS_ID    ;
          l_debrief_line.TXN_BILLING_TYPE_ID:=p_TXN_BILLING_TYPE_ID    ;
          l_debrief_line.INVENTORY_ITEM_ID:=p_INVENTORY_ITEM_ID    ;
          l_debrief_line.INSTANCE_ID:=p_INSTANCE_ID          ;
          l_debrief_line.ISSUING_INVENTORY_ORG_ID:=p_ISSUING_INVENTORY_ORG_ID    ;
          l_debrief_line.RECEIVING_INVENTORY_ORG_ID:=p_RECEIVING_INVENTORY_ORG_ID    ;
          l_debrief_line.ISSUING_SUB_INVENTORY_CODE:=p_ISSUING_SUB_INVENTORY_CODE    ;
          l_debrief_line.RECEIVING_SUB_INVENTORY_CODE:=p_RECEIVING_SUB_INVENTORY_CODE    ;
          l_debrief_line.ISSUING_LOCATOR_ID :=p_ISSUING_LOCATOR_ID   ;
          l_debrief_line.RECEIVING_LOCATOR_ID:=p_RECEIVING_LOCATOR_ID   ;
          l_debrief_line.PARENT_PRODUCT_ID:=p_PARENT_PRODUCT_ID    ;
          l_debrief_line.REMOVED_PRODUCT_ID:=p_REMOVED_PRODUCT_ID    ;
          l_debrief_line.STATUS_OF_RECEIVED_PART:=p_STATUS_OF_RECEIVED_PART   ;
          l_debrief_line.ITEM_SERIAL_NUMBER:=p_ITEM_SERIAL_NUMBER    ;
          l_debrief_line.ITEM_REVISION :=p_ITEM_REVISION    ;
          l_debrief_line.ITEM_LOTNUMBER:=p_ITEM_LOTNUMBER    ;
          l_debrief_line.UOM_CODE:=p_UOM_CODE    ;
          l_debrief_line.QUANTITY:=p_QUANTITY    ;
          l_debrief_line.RMA_HEADER_ID:=p_RMA_HEADER_ID    ;
          l_debrief_line.DISPOSITION_CODE:=p_DISPOSITION_CODE    ;
          l_debrief_line.MATERIAL_REASON_CODE:=p_MATERIAL_REASON_CODE   ;
          l_debrief_line.LABOR_REASON_CODE:=p_LABOR_REASON_CODE   ;
          l_debrief_line.EXPENSE_REASON_CODE:=p_EXPENSE_REASON_CODE    ;
          l_debrief_line.LABOR_START_DATE:=p_LABOR_START_DATE    ;
          l_debrief_line.LABOR_END_DATE:=p_LABOR_END_DATE    ;
          l_debrief_line.STARTING_MILEAGE:=p_STARTING_MILEAGE   ;
          l_debrief_line.ENDING_MILEAGE:=p_ENDING_MILEAGE    ;
          l_debrief_line.EXPENSE_AMOUNT:=p_EXPENSE_AMOUNT    ;
          l_debrief_line.CURRENCY_CODE:=p_CURRENCY_CODE    ;
          l_debrief_line.DEBRIEF_LINE_STATUS_ID:=p_DEBRIEF_LINE_STATUS_ID    ;
           l_debrief_line.RETURN_REASON_CODE:=p_RETURN_REASON_CODE ;
          l_debrief_line.CHANNEL_CODE:=p_CHANNEL_CODE    ;
          l_debrief_line.CHARGE_UPLOAD_STATUS:=p_CHARGE_UPLOAD_STATUS   ;
          l_debrief_line.CHARGE_UPLOAD_MSG_CODE:=p_CHARGE_UPLOAD_MSG_CODE    ;
          l_debrief_line.CHARGE_UPLOAD_MESSAGE:=p_CHARGE_UPLOAD_MESSAGE    ;
          l_debrief_line.IB_UPDATE_STATUS:=p_IB_UPDATE_STATUS    ;
          l_debrief_line.IB_UPDATE_MSG_CODE:=p_IB_UPDATE_MSG_CODE    ;
          l_debrief_line.IB_UPDATE_MESSAGE:=p_IB_UPDATE_MESSAGE    ;
          l_debrief_line.SPARE_UPDATE_STATUS:=p_SPARE_UPDATE_STATUS    ;
          l_debrief_line.SPARE_UPDATE_MSG_CODE:=p_SPARE_UPDATE_MSG_CODE    ;
          l_debrief_line.SPARE_UPDATE_MESSAGE:=p_SPARE_UPDATE_MESSAGE    ;
          l_debrief_line.CREATED_BY:=p_CREATED_BY    ;
          l_debrief_line.CREATION_DATE:=p_CREATION_DATE    ;
          l_debrief_line.LAST_UPDATED_BY:=p_LAST_UPDATED_BY    ;
          l_debrief_line.LAST_UPDATE_DATE:=p_LAST_UPDATE_DATE    ;
          l_debrief_line.LAST_UPDATE_LOGIN :=p_LAST_UPDATE_LOGIN    ;
          l_debrief_line.ATTRIBUTE1:=p_ATTRIBUTE1    ;
          l_debrief_line.ATTRIBUTE2 :=p_ATTRIBUTE2    ;
          l_debrief_line.ATTRIBUTE3 :=p_ATTRIBUTE3    ;
          l_debrief_line.ATTRIBUTE4 :=p_ATTRIBUTE4    ;
          l_debrief_line.ATTRIBUTE5 :=p_ATTRIBUTE5    ;
          l_debrief_line.ATTRIBUTE6 :=p_ATTRIBUTE6    ;
          l_debrief_line.ATTRIBUTE7 :=p_ATTRIBUTE7    ;
          l_debrief_line.ATTRIBUTE8 :=p_ATTRIBUTE8    ;
          l_debrief_line.ATTRIBUTE9 :=p_ATTRIBUTE9    ;
          l_debrief_line.ATTRIBUTE10 :=p_ATTRIBUTE10    ;
          l_debrief_line.ATTRIBUTE11 :=p_ATTRIBUTE11    ;
          l_debrief_line.ATTRIBUTE12 :=p_ATTRIBUTE12    ;
          l_debrief_line.ATTRIBUTE13 :=p_ATTRIBUTE13    ;
          l_debrief_line.ATTRIBUTE14 :=p_ATTRIBUTE14    ;
          l_debrief_line.ATTRIBUTE15 :=p_ATTRIBUTE15    ;
          l_debrief_line.ATTRIBUTE_CATEGORY :=p_ATTRIBUTE_CATEGORY    ;
          l_debrief_line.TRANSACTION_TYPE_ID := P_TRANSACTION_TYPE_ID;
          l_debrief_line.RETURN_DATE:=p_RETURN_DATE   ;
--dbms_output.put_line('Calling jtf_usr_hks.Ok_To_Execute ');

    if l_dml_mode is null then
      l_dml_mode := 'BOTH';
    end if;

    if l_dml_mode <> 'POST' then
      IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                        'Insert_Row',
                                        'B', 'C')  THEN
--dbms_output.put_line('Calling csf_debrief_lines_cuhk.Create_debrief_line_Pre ');
              csf_debrief_lines_cuhk.Create_debrief_line_Pre
                  ( px_debrief_line     => l_debrief_line,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data
                  ) ;
                  --dbms_output.put_line('csf_debrief_lines_cuhk.Create_debrief_line_Pre Status '||l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
        FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_CUST_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;


--dbms_output.put_line('Again Hook ');
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Insert_Row',
                                      'B', 'V')  THEN
--dbms_output.put_line('Pre Called ');
    csf_debrief_lines_vuhk.Create_debrief_line_Pre
                ( px_debrief_line     => l_debrief_line,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

--dbms_output.put_line('PRE CALLED STATUS  '||l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  --dbms_output.put_line('csf_debrief_lines_iuhk ');

    csf_debrief_lines_iuhk.Create_debrief_line_Pre
                ( x_return_status          => l_return_status
                ) ;

--dbms_output.put_line('csf_debrief_lines_iuhk status  '||l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    end if;

--dbms_output.put_line('SOME IF  ');
  if l_dml_mode = 'BOTH' then
   If (l_debrief_line.DEBRIEF_LINE_ID IS NULL) OR (l_debrief_line.DEBRIEF_LINE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_DEBRIEF_LINE_ID;
       CLOSE C2;
   End If;
  end if;
--dbms_output.put_line('INSERTING ');
--change dthe decode for service_date for timezone fix 3409128
 l_debrief_line.DEBRIEF_LINE_ID:= px_DEBRIEF_LINE_ID  ;
user_hooks_rec.DEBRIEF_LINE_ID := l_debrief_line.DEBRIEF_LINE_ID;

   if l_dml_mode = 'BOTH' then
   INSERT INTO CSF_DEBRIEF_LINES(
           DEBRIEF_LINE_ID,
           DEBRIEF_HEADER_ID,
           DEBRIEF_LINE_NUMBER,
           SERVICE_DATE,
           BUSINESS_PROCESS_ID,
           TXN_BILLING_TYPE_ID,
           INVENTORY_ITEM_ID,
           INSTANCE_ID,
           ISSUING_INVENTORY_ORG_ID,
           RECEIVING_INVENTORY_ORG_ID,
           ISSUING_SUB_INVENTORY_CODE,
           RECEIVING_SUB_INVENTORY_CODE,
           ISSUING_LOCATOR_ID,
           RECEIVING_LOCATOR_ID,
           PARENT_PRODUCT_ID,
           REMOVED_PRODUCT_ID,
           STATUS_OF_RECEIVED_PART,
           ITEM_SERIAL_NUMBER,
           ITEM_REVISION,
           ITEM_LOTNUMBER,
           UOM_CODE,
           QUANTITY,
           RMA_HEADER_ID,
           DISPOSITION_CODE,
           MATERIAL_REASON_CODE,
           LABOR_REASON_CODE,
           EXPENSE_REASON_CODE,
           LABOR_START_DATE,
           LABOR_END_DATE,
           STARTING_MILEAGE,
           ENDING_MILEAGE,
           EXPENSE_AMOUNT,
           CURRENCY_CODE,
           DEBRIEF_LINE_STATUS_ID,
           RETURN_REASON_CODE,
           CHANNEL_CODE,
           CHARGE_UPLOAD_STATUS,
           CHARGE_UPLOAD_MSG_CODE,
           CHARGE_UPLOAD_MESSAGE,
           IB_UPDATE_STATUS,
           IB_UPDATE_MSG_CODE,
           IB_UPDATE_MESSAGE,
           SPARE_UPDATE_STATUS,
           SPARE_UPDATE_MSG_CODE,
           SPARE_UPDATE_MESSAGE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
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
           ATTRIBUTE_CATEGORY,
           TRANSACTION_TYPE_ID,
           RETURN_DATE
          ) VALUES (
           px_DEBRIEF_LINE_ID,
           decode( l_debrief_line.DEBRIEF_HEADER_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.DEBRIEF_HEADER_ID),
           decode( l_debrief_line.DEBRIEF_LINE_NUMBER, FND_API.G_MISS_NUM, NULL, l_debrief_line.DEBRIEF_LINE_NUMBER),
           decode( l_debrief_line.SERVICE_DATE, FND_API.G_MISS_DATE, to_date(null), l_debrief_line.SERVICE_DATE),
           decode( l_debrief_line.BUSINESS_PROCESS_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.BUSINESS_PROCESS_ID),
           decode( l_debrief_line.TXN_BILLING_TYPE_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.TXN_BILLING_TYPE_ID),
           decode( l_debrief_line.INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.INVENTORY_ITEM_ID),
           decode( l_debrief_line.INSTANCE_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.INSTANCE_ID),
           decode( l_debrief_line.ISSUING_INVENTORY_ORG_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.ISSUING_INVENTORY_ORG_ID),
           decode( l_debrief_line.RECEIVING_INVENTORY_ORG_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.RECEIVING_INVENTORY_ORG_ID),
           decode( l_debrief_line.ISSUING_SUB_INVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ISSUING_SUB_INVENTORY_CODE),
           decode( l_debrief_line.RECEIVING_SUB_INVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.RECEIVING_SUB_INVENTORY_CODE),
           decode( l_debrief_line.ISSUING_LOCATOR_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.ISSUING_LOCATOR_ID),
           decode( l_debrief_line.RECEIVING_LOCATOR_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.RECEIVING_LOCATOR_ID),
           decode( l_debrief_line.PARENT_PRODUCT_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.PARENT_PRODUCT_ID),
           decode( l_debrief_line.REMOVED_PRODUCT_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.REMOVED_PRODUCT_ID),
           decode( l_debrief_line.STATUS_OF_RECEIVED_PART, FND_API.G_MISS_CHAR, NULL, l_debrief_line.STATUS_OF_RECEIVED_PART),
           decode( l_debrief_line.ITEM_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ITEM_SERIAL_NUMBER),
           decode( l_debrief_line.ITEM_REVISION, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ITEM_REVISION),
           decode( l_debrief_line.ITEM_LOTNUMBER, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ITEM_LOTNUMBER),
           decode( l_debrief_line.UOM_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.UOM_CODE),
           decode( l_debrief_line.QUANTITY, FND_API.G_MISS_NUM, NULL, l_debrief_line.QUANTITY),
           decode( l_debrief_line.RMA_HEADER_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.RMA_HEADER_ID),
           decode( l_debrief_line.DISPOSITION_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.DISPOSITION_CODE),
           decode( l_debrief_line.MATERIAL_REASON_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.MATERIAL_REASON_CODE),
           decode( l_debrief_line.LABOR_REASON_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.LABOR_REASON_CODE),
           decode( l_debrief_line.EXPENSE_REASON_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.EXPENSE_REASON_CODE),
           decode( l_debrief_line.LABOR_START_DATE, FND_API.G_MISS_DATE, to_date(null),l_debrief_line.labor_start_date),
           decode( l_debrief_line.LABOR_END_DATE, FND_API.G_MISS_DATE, to_date(null), l_debrief_line.labor_end_date),
           decode( l_debrief_line.STARTING_MILEAGE, FND_API.G_MISS_NUM, NULL, l_debrief_line.STARTING_MILEAGE),
           decode( l_debrief_line.ENDING_MILEAGE, FND_API.G_MISS_NUM, NULL, l_debrief_line.ENDING_MILEAGE),
           decode( l_debrief_line.EXPENSE_AMOUNT, FND_API.G_MISS_NUM, NULL, l_debrief_line.EXPENSE_AMOUNT),
           decode( l_debrief_line.CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.CURRENCY_CODE),
           decode( l_debrief_line.DEBRIEF_LINE_STATUS_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.DEBRIEF_LINE_STATUS_ID),
           decode( l_debrief_line.RETURN_REASON_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.RETURN_REASON_CODE),
           decode( l_debrief_line.CHANNEL_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.CHANNEL_CODE),
           decode( l_debrief_line.CHARGE_UPLOAD_STATUS, FND_API.G_MISS_CHAR, NULL, l_debrief_line.CHARGE_UPLOAD_STATUS),
           decode( l_debrief_line.CHARGE_UPLOAD_MSG_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.CHARGE_UPLOAD_MSG_CODE),
           decode( l_debrief_line.CHARGE_UPLOAD_MESSAGE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.CHARGE_UPLOAD_MESSAGE),
           decode( l_debrief_line.IB_UPDATE_STATUS, FND_API.G_MISS_CHAR, NULL, l_debrief_line.IB_UPDATE_STATUS),
           decode( l_debrief_line.IB_UPDATE_MSG_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.IB_UPDATE_MSG_CODE),
           decode( l_debrief_line.IB_UPDATE_MESSAGE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.IB_UPDATE_MESSAGE),
           decode( l_debrief_line.SPARE_UPDATE_STATUS, FND_API.G_MISS_CHAR, NULL, l_debrief_line.SPARE_UPDATE_STATUS),
           decode( l_debrief_line.SPARE_UPDATE_MSG_CODE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.SPARE_UPDATE_MSG_CODE),
           decode( l_debrief_line.SPARE_UPDATE_MESSAGE, FND_API.G_MISS_CHAR, NULL, l_debrief_line.SPARE_UPDATE_MESSAGE),
           decode( l_debrief_line.CREATED_BY, FND_API.G_MISS_NUM, fnd_global.user_id, l_debrief_line.CREATED_BY),
           decode( l_debrief_line.CREATION_DATE, FND_API.G_MISS_DATE, sysdate, l_debrief_line.creation_date),
           decode( l_debrief_line.LAST_UPDATED_BY, FND_API.G_MISS_NUM, fnd_global.user_id, l_debrief_line.LAST_UPDATED_BY),
           decode( l_debrief_line.last_update_date, FND_API.G_MISS_DATE, sysdate, l_debrief_line.last_update_date),
           decode( l_debrief_line.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, fnd_global.conc_login_id, l_debrief_line.LAST_UPDATE_LOGIN),
           decode( l_debrief_line.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE1),
           decode( l_debrief_line.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE2),
           decode( l_debrief_line.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE3),
           decode( l_debrief_line.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE4),
           decode( l_debrief_line.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE5),
           decode( l_debrief_line.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE6),
           decode( l_debrief_line.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE7),
           decode( l_debrief_line.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE8),
           decode( l_debrief_line.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE9),
           decode( l_debrief_line.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE10),
           decode( l_debrief_line.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE11),
           decode( l_debrief_line.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE12),
           decode( l_debrief_line.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE13),
           decode( l_debrief_line.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE14),
           decode( l_debrief_line.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE15),
           decode( l_debrief_line.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, l_debrief_line.ATTRIBUTE_CATEGORY),
           decode( l_debrief_line.TRANSACTION_TYPE_ID, FND_API.G_MISS_NUM, NULL, l_debrief_line.TRANSACTION_TYPE_ID),
           decode( l_debrief_line.RETURN_DATE, FND_API.G_MISS_DATE, NULL, l_debrief_line.RETURN_DATE)
        );
        end if;

          -- dbms_output.put_line('INSERTED ');
          if l_dml_mode <> 'PRE' then
            IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Insert_Row',
                                      'B', 'C')  THEN
--dbms_output.put_line('CREATE LINE POST ');
            csf_debrief_lines_cuhk.Create_debrief_line_post
                ( px_debrief_line     => l_debrief_line,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
                --dbms_output.put_line('POST  '||l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Insert_Row',
                                      'B', 'V')  THEN
    csf_debrief_lines_vuhk.Create_debrief_line_post
                ( px_debrief_line     => l_debrief_line,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

    csf_debrief_lines_iuhk.Create_debrief_line_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    end if;
--dbms_output.put_line('END INSERT ROW ');
End Insert_Row;

PROCEDURE Update_Row(
          p_DEBRIEF_LINE_ID    NUMBER,
          p_DEBRIEF_HEADER_ID    NUMBER,
          p_DEBRIEF_LINE_NUMBER    NUMBER,
          p_SERVICE_DATE    DATE,
          p_BUSINESS_PROCESS_ID    NUMBER,
          p_TXN_BILLING_TYPE_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          P_INSTANCE_ID          NUMBER,
          p_ISSUING_INVENTORY_ORG_ID    NUMBER,
          p_RECEIVING_INVENTORY_ORG_ID    NUMBER,
          p_ISSUING_SUB_INVENTORY_CODE    VARCHAR2,
          p_RECEIVING_SUB_INVENTORY_CODE    VARCHAR2,
          p_ISSUING_LOCATOR_ID    NUMBER,
          p_RECEIVING_LOCATOR_ID    NUMBER,
          p_PARENT_PRODUCT_ID    NUMBER,
          p_REMOVED_PRODUCT_ID    NUMBER,
          p_STATUS_OF_RECEIVED_PART    VARCHAR2,
          p_ITEM_SERIAL_NUMBER    VARCHAR2,
          p_ITEM_REVISION    VARCHAR2,
          p_ITEM_LOTNUMBER    VARCHAR2,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_RMA_HEADER_ID    NUMBER,
          p_DISPOSITION_CODE    VARCHAR2,
          p_MATERIAL_REASON_CODE    VARCHAR2,
          p_LABOR_REASON_CODE    VARCHAR2,
          p_EXPENSE_REASON_CODE    VARCHAR2,
          p_LABOR_START_DATE    DATE,
          p_LABOR_END_DATE    DATE,
          p_STARTING_MILEAGE    NUMBER,
          p_ENDING_MILEAGE    NUMBER,
          p_EXPENSE_AMOUNT    NUMBER,
          p_CURRENCY_CODE    VARCHAR2,
          p_DEBRIEF_LINE_STATUS_ID    NUMBER,
          P_RETURN_REASON_CODE    VARCHAR2,
          p_CHANNEL_CODE    VARCHAR2,
          p_CHARGE_UPLOAD_STATUS    VARCHAR2,
          p_CHARGE_UPLOAD_MSG_CODE    VARCHAR2,
          p_CHARGE_UPLOAD_MESSAGE    VARCHAR2,
          p_IB_UPDATE_STATUS    VARCHAR2,
          p_IB_UPDATE_MSG_CODE    VARCHAR2,
          p_IB_UPDATE_MESSAGE    VARCHAR2,
          p_SPARE_UPDATE_STATUS    VARCHAR2,
          p_SPARE_UPDATE_MSG_CODE    VARCHAR2,
          p_SPARE_UPDATE_MESSAGE    VARCHAR2,
          p_error_text varchar2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          P_TRANSACTION_TYPE_ID  NUMBER,
          P_RETURN_DATE     DATE,
          p_DML_mode            VARCHAR2)

 IS
   l_debrief_line  CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSF_DEBRIEF_LINES_PKG.UPDATE_ROW';
   l_dml_mode		  varchar2(10) := p_DML_mode;
 BEGIN
           l_debrief_line.DEBRIEF_LINE_ID:= p_DEBRIEF_LINE_ID  ;
           l_debrief_line.DEBRIEF_HEADER_ID:= p_DEBRIEF_HEADER_ID    ;
          l_debrief_line.DEBRIEF_LINE_NUMBER:=p_DEBRIEF_LINE_NUMBER    ;
          l_debrief_line.SERVICE_DATE:=p_SERVICE_DATE   ;
          l_debrief_line.BUSINESS_PROCESS_ID:=p_BUSINESS_PROCESS_ID    ;
          l_debrief_line.TXN_BILLING_TYPE_ID:=p_TXN_BILLING_TYPE_ID    ;
          l_debrief_line.INVENTORY_ITEM_ID:=p_INVENTORY_ITEM_ID    ;
          l_debrief_line.INSTANCE_ID:=p_INSTANCE_ID          ;
          l_debrief_line.ISSUING_INVENTORY_ORG_ID:=p_ISSUING_INVENTORY_ORG_ID    ;
          l_debrief_line.RECEIVING_INVENTORY_ORG_ID:=p_RECEIVING_INVENTORY_ORG_ID    ;
          l_debrief_line.ISSUING_SUB_INVENTORY_CODE:=p_ISSUING_SUB_INVENTORY_CODE    ;
          l_debrief_line.RECEIVING_SUB_INVENTORY_CODE:=p_RECEIVING_SUB_INVENTORY_CODE    ;
          l_debrief_line.ISSUING_LOCATOR_ID :=p_ISSUING_LOCATOR_ID   ;
          l_debrief_line.RECEIVING_LOCATOR_ID:=p_RECEIVING_LOCATOR_ID   ;
          l_debrief_line.PARENT_PRODUCT_ID:=p_PARENT_PRODUCT_ID    ;
          l_debrief_line.REMOVED_PRODUCT_ID:=p_REMOVED_PRODUCT_ID    ;
          l_debrief_line.STATUS_OF_RECEIVED_PART:=p_STATUS_OF_RECEIVED_PART   ;
          l_debrief_line.ITEM_SERIAL_NUMBER:=p_ITEM_SERIAL_NUMBER    ;
          l_debrief_line.ITEM_REVISION :=p_ITEM_REVISION    ;
          l_debrief_line.ITEM_LOTNUMBER:=p_ITEM_LOTNUMBER    ;
          l_debrief_line.UOM_CODE:=p_UOM_CODE    ;
          l_debrief_line.QUANTITY:=p_QUANTITY    ;
          l_debrief_line.RMA_HEADER_ID:=p_RMA_HEADER_ID    ;
          l_debrief_line.DISPOSITION_CODE:=p_DISPOSITION_CODE    ;
          l_debrief_line.MATERIAL_REASON_CODE:=p_MATERIAL_REASON_CODE   ;
          l_debrief_line.LABOR_REASON_CODE:=p_LABOR_REASON_CODE   ;
          l_debrief_line.EXPENSE_REASON_CODE:=p_EXPENSE_REASON_CODE    ;
          l_debrief_line.LABOR_START_DATE:=p_LABOR_START_DATE    ;
          l_debrief_line.LABOR_END_DATE:=p_LABOR_END_DATE    ;
          l_debrief_line.STARTING_MILEAGE:=p_STARTING_MILEAGE   ;
          l_debrief_line.ENDING_MILEAGE:=p_ENDING_MILEAGE    ;
          l_debrief_line.EXPENSE_AMOUNT:=p_EXPENSE_AMOUNT    ;
          l_debrief_line.CURRENCY_CODE:=p_CURRENCY_CODE    ;
          l_debrief_line.DEBRIEF_LINE_STATUS_ID:=p_DEBRIEF_LINE_STATUS_ID    ;
           l_debrief_line.RETURN_REASON_CODE:=p_RETURN_REASON_CODE ;
          l_debrief_line.CHANNEL_CODE:=p_CHANNEL_CODE    ;
          l_debrief_line.CHARGE_UPLOAD_STATUS:=p_CHARGE_UPLOAD_STATUS   ;
          l_debrief_line.CHARGE_UPLOAD_MSG_CODE:=p_CHARGE_UPLOAD_MSG_CODE    ;
          l_debrief_line.CHARGE_UPLOAD_MESSAGE:=p_CHARGE_UPLOAD_MESSAGE    ;
          l_debrief_line.IB_UPDATE_STATUS:=p_IB_UPDATE_STATUS    ;
          l_debrief_line.IB_UPDATE_MSG_CODE:=p_IB_UPDATE_MSG_CODE    ;
          l_debrief_line.IB_UPDATE_MESSAGE:=p_IB_UPDATE_MESSAGE    ;
          l_debrief_line.SPARE_UPDATE_STATUS:=p_SPARE_UPDATE_STATUS    ;
          l_debrief_line.SPARE_UPDATE_MSG_CODE:=p_SPARE_UPDATE_MSG_CODE    ;
          l_debrief_line.SPARE_UPDATE_MESSAGE:=p_SPARE_UPDATE_MESSAGE    ;
          l_debrief_line.error_text:=p_error_text;
          l_debrief_line.CREATED_BY:=p_CREATED_BY    ;
          l_debrief_line.CREATION_DATE:=p_CREATION_DATE    ;
          l_debrief_line.LAST_UPDATED_BY:=p_LAST_UPDATED_BY    ;
          l_debrief_line.LAST_UPDATE_DATE:=p_LAST_UPDATE_DATE    ;
          l_debrief_line.LAST_UPDATE_LOGIN :=p_LAST_UPDATE_LOGIN    ;
          l_debrief_line.ATTRIBUTE1:=p_ATTRIBUTE1    ;
          l_debrief_line.ATTRIBUTE2 :=p_ATTRIBUTE2    ;
          l_debrief_line.ATTRIBUTE3 :=p_ATTRIBUTE3    ;
          l_debrief_line.ATTRIBUTE4 :=p_ATTRIBUTE4    ;
          l_debrief_line.ATTRIBUTE5 :=p_ATTRIBUTE5    ;
          l_debrief_line.ATTRIBUTE6 :=p_ATTRIBUTE6    ;
          l_debrief_line.ATTRIBUTE7 :=p_ATTRIBUTE7    ;
          l_debrief_line.ATTRIBUTE8 :=p_ATTRIBUTE8    ;
          l_debrief_line.ATTRIBUTE9 :=p_ATTRIBUTE9    ;
          l_debrief_line.ATTRIBUTE10 :=p_ATTRIBUTE10    ;
          l_debrief_line.ATTRIBUTE11 :=p_ATTRIBUTE11    ;
          l_debrief_line.ATTRIBUTE12 :=p_ATTRIBUTE12    ;
          l_debrief_line.ATTRIBUTE13 :=p_ATTRIBUTE13    ;
          l_debrief_line.ATTRIBUTE14 :=p_ATTRIBUTE14    ;
          l_debrief_line.ATTRIBUTE15 :=p_ATTRIBUTE15    ;
          l_debrief_line.ATTRIBUTE_CATEGORY :=p_ATTRIBUTE_CATEGORY    ;
          l_debrief_line.TRANSACTION_TYPE_ID := P_TRANSACTION_TYPE_ID;
          l_debrief_line.RETURN_DATE:=p_RETURN_DATE   ;

          if l_dml_mode is null then
            l_dml_mode := 'BOTH';
          end if;


    if l_dml_mode <> 'POST' then

    IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Update_Row',
                                      'B', 'C')  THEN

            csf_debrief_lines_cuhk.update_debrief_line_Pre
                ( px_debrief_line     => l_debrief_line,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Insert_Row',
                                      'B', 'V')  THEN
    csf_debrief_lines_vuhk.update_debrief_line_Pre
                ( px_debrief_line     => l_debrief_line,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
     user_hooks_rec.DEBRIEF_LINE_ID := l_debrief_line.DEBRIEF_LINE_ID;
    csf_debrief_lines_iuhk.update_debrief_line_Pre
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    end if;

    if l_dml_mode = 'BOTH' then

    Update CSF_DEBRIEF_LINES
    SET
              DEBRIEF_HEADER_ID = decode( l_debrief_line.DEBRIEF_HEADER_ID, FND_API.G_MISS_NUM, DEBRIEF_HEADER_ID, l_debrief_line.DEBRIEF_HEADER_ID),
              DEBRIEF_LINE_NUMBER = decode( l_debrief_line.DEBRIEF_LINE_NUMBER, FND_API.G_MISS_NUM, DEBRIEF_LINE_NUMBER, l_debrief_line.DEBRIEF_LINE_NUMBER),
              SERVICE_DATE = decode( l_debrief_line.SERVICE_DATE, FND_API.G_MISS_DATE, SERVICE_DATE, l_debrief_line.SERVICE_DATE),
              BUSINESS_PROCESS_ID = decode( l_debrief_line.BUSINESS_PROCESS_ID, FND_API.G_MISS_NUM, BUSINESS_PROCESS_ID, l_debrief_line.BUSINESS_PROCESS_ID),
              TXN_BILLING_TYPE_ID = decode( l_debrief_line.TXN_BILLING_TYPE_ID, FND_API.G_MISS_NUM, TXN_BILLING_TYPE_ID, l_debrief_line.TXN_BILLING_TYPE_ID),
              INVENTORY_ITEM_ID = decode( l_debrief_line.INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, l_debrief_line.INVENTORY_ITEM_ID),
              INSTANCE_ID = decode( l_debrief_line.INSTANCE_ID, FND_API.G_MISS_NUM, INSTANCE_ID, l_debrief_line.INSTANCE_ID),
              ISSUING_INVENTORY_ORG_ID = decode( l_debrief_line.ISSUING_INVENTORY_ORG_ID, FND_API.G_MISS_NUM, ISSUING_INVENTORY_ORG_ID, l_debrief_line.ISSUING_INVENTORY_ORG_ID),
              RECEIVING_INVENTORY_ORG_ID = decode( l_debrief_line.RECEIVING_INVENTORY_ORG_ID, FND_API.G_MISS_NUM, RECEIVING_INVENTORY_ORG_ID, l_debrief_line.RECEIVING_INVENTORY_ORG_ID),
              ISSUING_SUB_INVENTORY_CODE = decode( l_debrief_line.ISSUING_SUB_INVENTORY_CODE, FND_API.G_MISS_CHAR, ISSUING_SUB_INVENTORY_CODE, l_debrief_line.ISSUING_SUB_INVENTORY_CODE),
              RECEIVING_SUB_INVENTORY_CODE = decode( l_debrief_line.RECEIVING_SUB_INVENTORY_CODE, FND_API.G_MISS_CHAR, RECEIVING_SUB_INVENTORY_CODE, l_debrief_line.RECEIVING_SUB_INVENTORY_CODE),
              ISSUING_LOCATOR_ID = decode( l_debrief_line.ISSUING_LOCATOR_ID, FND_API.G_MISS_NUM, ISSUING_LOCATOR_ID, l_debrief_line.ISSUING_LOCATOR_ID),
              RECEIVING_LOCATOR_ID = decode( l_debrief_line.RECEIVING_LOCATOR_ID, FND_API.G_MISS_NUM, RECEIVING_LOCATOR_ID, l_debrief_line.RECEIVING_LOCATOR_ID),
              PARENT_PRODUCT_ID = decode( l_debrief_line.PARENT_PRODUCT_ID, FND_API.G_MISS_NUM, PARENT_PRODUCT_ID, l_debrief_line.PARENT_PRODUCT_ID),
              REMOVED_PRODUCT_ID = decode( l_debrief_line.REMOVED_PRODUCT_ID, FND_API.G_MISS_NUM, REMOVED_PRODUCT_ID, l_debrief_line.REMOVED_PRODUCT_ID),
              STATUS_OF_RECEIVED_PART = decode( l_debrief_line.STATUS_OF_RECEIVED_PART, FND_API.G_MISS_CHAR, STATUS_OF_RECEIVED_PART, l_debrief_line.STATUS_OF_RECEIVED_PART),
              ITEM_SERIAL_NUMBER = decode( l_debrief_line.ITEM_SERIAL_NUMBER, FND_API.G_MISS_CHAR, ITEM_SERIAL_NUMBER, l_debrief_line.ITEM_SERIAL_NUMBER),
              ITEM_REVISION = decode( l_debrief_line.ITEM_REVISION, FND_API.G_MISS_CHAR, ITEM_REVISION, l_debrief_line.ITEM_REVISION),
              ITEM_LOTNUMBER = decode( l_debrief_line.ITEM_LOTNUMBER, FND_API.G_MISS_CHAR, ITEM_LOTNUMBER, l_debrief_line.ITEM_LOTNUMBER),
              UOM_CODE = decode( l_debrief_line.UOM_CODE, FND_API.G_MISS_CHAR, UOM_CODE, l_debrief_line.UOM_CODE),
              QUANTITY = decode( l_debrief_line.QUANTITY, FND_API.G_MISS_NUM, QUANTITY, l_debrief_line.QUANTITY),
              RMA_HEADER_ID = decode( l_debrief_line.RMA_HEADER_ID, FND_API.G_MISS_NUM, RMA_HEADER_ID, l_debrief_line.RMA_HEADER_ID),
              DISPOSITION_CODE = decode( l_debrief_line.DISPOSITION_CODE, FND_API.G_MISS_CHAR, DISPOSITION_CODE, l_debrief_line.DISPOSITION_CODE),
              MATERIAL_REASON_CODE = decode( l_debrief_line.MATERIAL_REASON_CODE, FND_API.G_MISS_CHAR, MATERIAL_REASON_CODE, l_debrief_line.MATERIAL_REASON_CODE),
              LABOR_REASON_CODE = decode( l_debrief_line.LABOR_REASON_CODE, FND_API.G_MISS_CHAR, LABOR_REASON_CODE, l_debrief_line.LABOR_REASON_CODE),
              EXPENSE_REASON_CODE = decode( l_debrief_line.EXPENSE_REASON_CODE, FND_API.G_MISS_CHAR, EXPENSE_REASON_CODE, l_debrief_line.EXPENSE_REASON_CODE),
              LABOR_START_DATE = decode(l_debrief_line.LABOR_START_DATE,fnd_api.g_miss_date,labor_start_date,l_debrief_line.labor_start_date),
              LABOR_END_DATE = decode(l_debrief_line.LABOR_END_DATE,fnd_api.g_miss_date,labor_end_date,l_debrief_line.labor_end_date),
              STARTING_MILEAGE = decode( l_debrief_line.STARTING_MILEAGE, FND_API.G_MISS_NUM, STARTING_MILEAGE, l_debrief_line.STARTING_MILEAGE),
              ENDING_MILEAGE = decode( l_debrief_line.ENDING_MILEAGE, FND_API.G_MISS_NUM, ENDING_MILEAGE, l_debrief_line.ENDING_MILEAGE),
              EXPENSE_AMOUNT = decode( p_EXPENSE_AMOUNT, FND_API.G_MISS_NUM, EXPENSE_AMOUNT, l_debrief_line.EXPENSE_AMOUNT),
              CURRENCY_CODE = decode( l_debrief_line.CURRENCY_CODE, FND_API.G_MISS_CHAR, CURRENCY_CODE, l_debrief_line.CURRENCY_CODE),
              DEBRIEF_LINE_STATUS_ID = decode( l_debrief_line.DEBRIEF_LINE_STATUS_ID, FND_API.G_MISS_NUM, DEBRIEF_LINE_STATUS_ID, l_debrief_line.DEBRIEF_LINE_STATUS_ID),
              RETURN_REASON_CODE = decode( l_debrief_line.RETURN_REASON_CODE, FND_API.G_MISS_CHAR, RETURN_REASON_CODE, l_debrief_line.return_reason_CODE),
              CHANNEL_CODE = decode( l_debrief_line.CHANNEL_CODE, FND_API.G_MISS_CHAR, CHANNEL_CODE, l_debrief_line.CHANNEL_CODE),
              CHARGE_UPLOAD_STATUS = decode( l_debrief_line.CHARGE_UPLOAD_STATUS, FND_API.G_MISS_CHAR, CHARGE_UPLOAD_STATUS, l_debrief_line.CHARGE_UPLOAD_STATUS),
              CHARGE_UPLOAD_MSG_CODE = decode( l_debrief_line.CHARGE_UPLOAD_MSG_CODE, FND_API.G_MISS_CHAR, CHARGE_UPLOAD_MSG_CODE, l_debrief_line.CHARGE_UPLOAD_MSG_CODE),
              CHARGE_UPLOAD_MESSAGE = decode( l_debrief_line.CHARGE_UPLOAD_MESSAGE, FND_API.G_MISS_CHAR, CHARGE_UPLOAD_MESSAGE, l_debrief_line.CHARGE_UPLOAD_MESSAGE),
              IB_UPDATE_STATUS = decode( l_debrief_line.IB_UPDATE_STATUS, FND_API.G_MISS_CHAR, IB_UPDATE_STATUS, l_debrief_line.IB_UPDATE_STATUS),
              IB_UPDATE_MSG_CODE = decode( l_debrief_line.IB_UPDATE_MSG_CODE, FND_API.G_MISS_CHAR, IB_UPDATE_MSG_CODE, l_debrief_line.IB_UPDATE_MSG_CODE),
              IB_UPDATE_MESSAGE = decode( l_debrief_line.IB_UPDATE_MESSAGE, FND_API.G_MISS_CHAR, IB_UPDATE_MESSAGE, l_debrief_line.IB_UPDATE_MESSAGE),
              SPARE_UPDATE_STATUS = decode( l_debrief_line.SPARE_UPDATE_STATUS, FND_API.G_MISS_CHAR, SPARE_UPDATE_STATUS, l_debrief_line.SPARE_UPDATE_STATUS),
              SPARE_UPDATE_MSG_CODE = decode( l_debrief_line.SPARE_UPDATE_MSG_CODE, FND_API.G_MISS_CHAR, SPARE_UPDATE_MSG_CODE, l_debrief_line.SPARE_UPDATE_MSG_CODE),
              SPARE_UPDATE_MESSAGE = decode( l_debrief_line.SPARE_UPDATE_MESSAGE, FND_API.G_MISS_CHAR, SPARE_UPDATE_MESSAGE, l_debrief_line.SPARE_UPDATE_MESSAGE),
              error_text = decode( l_debrief_line.error_text, FND_API.G_MISS_CHAR, error_text, l_debrief_line.error_text),
              CREATED_BY = decode( l_debrief_line.CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, l_debrief_line.CREATED_BY),
              CREATION_DATE = decode( l_debrief_line.CREATION_DATE, FND_API.G_MISS_DATE,creation_date,l_debrief_line.creation_date),
              LAST_UPDATED_BY = decode( l_debrief_line.LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, l_debrief_line.LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(l_debrief_line.LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,l_debrief_line.last_update_date),
              LAST_UPDATE_LOGIN = decode( l_debrief_line.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, l_debrief_line.LAST_UPDATE_LOGIN),
              ATTRIBUTE1 = decode( l_debrief_line.ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, l_debrief_line.ATTRIBUTE1),
              ATTRIBUTE2 = decode( l_debrief_line.ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, l_debrief_line.ATTRIBUTE2),
              ATTRIBUTE3 = decode( l_debrief_line.ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, l_debrief_line.ATTRIBUTE3),
              ATTRIBUTE4 = decode( l_debrief_line.ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, l_debrief_line.ATTRIBUTE4),
              ATTRIBUTE5 = decode( l_debrief_line.ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, l_debrief_line.ATTRIBUTE5),
              ATTRIBUTE6 = decode( l_debrief_line.ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, l_debrief_line.ATTRIBUTE6),
              ATTRIBUTE7 = decode( l_debrief_line.ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, l_debrief_line.ATTRIBUTE7),
              ATTRIBUTE8 = decode( l_debrief_line.ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, l_debrief_line.ATTRIBUTE8),
              ATTRIBUTE9 = decode( l_debrief_line.ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, l_debrief_line.ATTRIBUTE9),
              ATTRIBUTE10 = decode( l_debrief_line.ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, l_debrief_line.ATTRIBUTE10),
              ATTRIBUTE11 = decode( l_debrief_line.ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, l_debrief_line.ATTRIBUTE11),
              ATTRIBUTE12 = decode( l_debrief_line.ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, l_debrief_line.ATTRIBUTE12),
              ATTRIBUTE13 = decode( l_debrief_line.ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, l_debrief_line.ATTRIBUTE13),
              ATTRIBUTE14 = decode( l_debrief_line.ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, l_debrief_line.ATTRIBUTE14),
              ATTRIBUTE15 = decode( l_debrief_line.ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, l_debrief_line.ATTRIBUTE15),
              ATTRIBUTE_CATEGORY = decode( l_debrief_line.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, l_debrief_line.ATTRIBUTE_CATEGORY),
              TRANSACTION_TYPE_ID = decode( l_debrief_line.TRANSACTION_TYPE_ID, FND_API.G_MISS_NUM, TRANSACTION_TYPE_ID, l_debrief_line.TRANSACTION_TYPE_ID),
              RETURN_DATE = decode( l_debrief_line.RETURN_DATE, FND_API.G_MISS_DATE, RETURN_DATE, l_debrief_line.RETURN_DATE)

    where DEBRIEF_LINE_ID = l_debrief_line.DEBRIEF_LINE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

    end if;

    if l_dml_mode <> 'PRE' then

     IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Insert_Row',
                                      'A', 'C')  THEN

            csf_debrief_lines_cuhk.update_debrief_line_Post
                ( px_debrief_line     => l_debrief_line,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Insert_Row',
                                      'A', 'V')  THEN
    csf_debrief_lines_vuhk.update_debrief_line_post
                ( px_debrief_line     => l_debrief_line,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

    csf_debrief_lines_iuhk.update_debrief_line_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    end if;

END Update_Row;

PROCEDURE Delete_Row(
    p_DEBRIEF_LINE_ID  NUMBER,
    p_DML_mode            VARCHAR2)
 IS
     l_debrief_line  CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSF_DEBRIEF_LINES_PKG.DELETE_ROW';
   l_dml_mode		  varchar2(10) := p_DML_mode;
 BEGIN
    if l_dml_mode is null then
      l_dml_mode := 'BOTH';
    end if;

    if l_dml_mode <> 'POST' then
    IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Delete_Row',
                                      'B', 'C')  THEN

            csf_debrief_lines_cuhk.delete_debrief_line_Pre
                ( p_line_id                => p_DEBRIEF_LINE_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Delete_Row',
                                      'B', 'V')  THEN
    csf_debrief_lines_vuhk.delete_debrief_line_Pre
                ( p_line_id     => p_DEBRIEF_LINE_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
      user_hooks_rec.DEBRIEF_LINE_ID := p_DEBRIEF_LINE_ID;
    csf_debrief_lines_iuhk.delete_debrief_line_Pre
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    end if;

   if l_dml_mode = 'BOTH' then

   DELETE FROM CSF_DEBRIEF_LINES
    WHERE DEBRIEF_LINE_ID = p_DEBRIEF_LINE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
   end if;

   if l_dml_mode <> 'PRE' then

   IF jtf_usr_hks.Ok_To_Execute('CSF_debrief_lineS_PKG',
                                      'Delete_Row',
                                      'A', 'C')  THEN

            csf_debrief_lines_cuhk.delete_debrief_line_post
                ( p_line_id     => p_DEBRIEF_LINE_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_LINES_PKG',
                                      'Insert_Row',
                                      'A', 'V')  THEN
    csf_debrief_lines_vuhk.delete_debrief_line_post
                ( p_line_id                => p_DEBRIEF_LINE_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

    csf_debrief_lines_iuhk.delete_debrief_line_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    end if;

 END Delete_Row;

PROCEDURE Lock_Row(
          p_DEBRIEF_LINE_ID    NUMBER,
          p_DEBRIEF_HEADER_ID    NUMBER,
          p_DEBRIEF_LINE_NUMBER    NUMBER,
          p_SERVICE_DATE    DATE,
          p_BUSINESS_PROCESS_ID    NUMBER,
          p_TXN_BILLING_TYPE_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          P_INSTANCE_ID          NUMBER,
          p_ISSUING_INVENTORY_ORG_ID    NUMBER,
          p_RECEIVING_INVENTORY_ORG_ID    NUMBER,
          p_ISSUING_SUB_INVENTORY_CODE    VARCHAR2,
          p_RECEIVING_SUB_INVENTORY_CODE    VARCHAR2,
          p_ISSUING_LOCATOR_ID    NUMBER,
          p_RECEIVING_LOCATOR_ID    NUMBER,
          p_PARENT_PRODUCT_ID    NUMBER,
          p_REMOVED_PRODUCT_ID    NUMBER,
          p_STATUS_OF_RECEIVED_PART    VARCHAR2,
          p_ITEM_SERIAL_NUMBER    VARCHAR2,
          p_ITEM_REVISION    VARCHAR2,
          p_ITEM_LOTNUMBER    VARCHAR2,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_RMA_HEADER_ID    NUMBER,
          p_DISPOSITION_CODE    VARCHAR2,
          p_MATERIAL_REASON_CODE    VARCHAR2,
          p_LABOR_REASON_CODE    VARCHAR2,
          p_EXPENSE_REASON_CODE    VARCHAR2,
          p_LABOR_START_DATE    DATE,
          p_LABOR_END_DATE    DATE,
          p_STARTING_MILEAGE    NUMBER,
          p_ENDING_MILEAGE    NUMBER,
          p_EXPENSE_AMOUNT    NUMBER,
          p_CURRENCY_CODE    VARCHAR2,
          p_DEBRIEF_LINE_STATUS_ID    NUMBER,
          P_RETURN_REASON_CODE  VARCHAR2,
          p_CHANNEL_CODE    VARCHAR2,
          p_CHARGE_UPLOAD_STATUS    VARCHAR2,
          p_CHARGE_UPLOAD_MSG_CODE    VARCHAR2,
          p_CHARGE_UPLOAD_MESSAGE    VARCHAR2,
          p_IB_UPDATE_STATUS    VARCHAR2,
          p_IB_UPDATE_MSG_CODE    VARCHAR2,
          p_IB_UPDATE_MESSAGE    VARCHAR2,
          p_SPARE_UPDATE_STATUS    VARCHAR2,
          p_SPARE_UPDATE_MSG_CODE    VARCHAR2,
          p_SPARE_UPDATE_MESSAGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          P_TRANSACTION_TYPE_ID  NUMBER,
          P_RETURN_DATE     DATE
        )

 IS
   CURSOR C IS
        SELECT *
         FROM CSF_DEBRIEF_LINES
        WHERE DEBRIEF_LINE_ID =  p_DEBRIEF_LINE_ID
        FOR UPDATE of DEBRIEF_LINE_ID NOWAIT;
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
           (      Recinfo.DEBRIEF_LINE_ID = p_DEBRIEF_LINE_ID)
       AND (    ( Recinfo.DEBRIEF_HEADER_ID = p_DEBRIEF_HEADER_ID)
            OR (    ( Recinfo.DEBRIEF_HEADER_ID IS NULL )
                AND (  p_DEBRIEF_HEADER_ID IS NULL )))
       AND (    ( Recinfo.DEBRIEF_LINE_NUMBER = p_DEBRIEF_LINE_NUMBER)
            OR (    ( Recinfo.DEBRIEF_LINE_NUMBER IS NULL )
                AND (  p_DEBRIEF_LINE_NUMBER IS NULL )))
       AND (    ( Recinfo.SERVICE_DATE = p_SERVICE_DATE)
            OR (    ( Recinfo.SERVICE_DATE IS NULL )
                AND (  p_SERVICE_DATE IS NULL )))
       AND (    ( Recinfo.BUSINESS_PROCESS_ID = p_BUSINESS_PROCESS_ID)
            OR (    ( Recinfo.BUSINESS_PROCESS_ID IS NULL )
                AND (  p_BUSINESS_PROCESS_ID IS NULL )))
       AND (    ( Recinfo.TXN_BILLING_TYPE_ID = p_TXN_BILLING_TYPE_ID)
            OR (    ( Recinfo.TXN_BILLING_TYPE_ID IS NULL )
                AND (  p_TXN_BILLING_TYPE_ID IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.INSTANCE_ID = p_INSTANCE_ID)
            OR (    ( Recinfo.INSTANCE_ID IS NULL )
                AND (  p_INSTANCE_ID IS NULL )))
       AND (    ( Recinfo.ISSUING_INVENTORY_ORG_ID = p_ISSUING_INVENTORY_ORG_ID)
            OR (    ( Recinfo.ISSUING_INVENTORY_ORG_ID IS NULL )
                AND (  p_ISSUING_INVENTORY_ORG_ID IS NULL )))
       AND (    ( Recinfo.RECEIVING_INVENTORY_ORG_ID = p_RECEIVING_INVENTORY_ORG_ID)
            OR (    ( Recinfo.RECEIVING_INVENTORY_ORG_ID IS NULL )
                AND (  p_RECEIVING_INVENTORY_ORG_ID IS NULL )))
       AND (    ( Recinfo.ISSUING_SUB_INVENTORY_CODE = p_ISSUING_SUB_INVENTORY_CODE)
            OR (    ( Recinfo.ISSUING_SUB_INVENTORY_CODE IS NULL )
                AND (  p_ISSUING_SUB_INVENTORY_CODE IS NULL )))
       AND (    ( Recinfo.RECEIVING_SUB_INVENTORY_CODE = p_RECEIVING_SUB_INVENTORY_CODE)
            OR (    ( Recinfo.RECEIVING_SUB_INVENTORY_CODE IS NULL )
                AND (  p_RECEIVING_SUB_INVENTORY_CODE IS NULL )))
       AND (    ( Recinfo.ISSUING_LOCATOR_ID = p_ISSUING_LOCATOR_ID)
            OR (    ( Recinfo.ISSUING_LOCATOR_ID IS NULL )
                AND (  p_ISSUING_LOCATOR_ID IS NULL )))
       AND (    ( Recinfo.RECEIVING_LOCATOR_ID = p_RECEIVING_LOCATOR_ID)
            OR (    ( Recinfo.RECEIVING_LOCATOR_ID IS NULL )
                AND (  p_RECEIVING_LOCATOR_ID IS NULL )))
       AND (    ( Recinfo.PARENT_PRODUCT_ID = p_PARENT_PRODUCT_ID)
            OR (    ( Recinfo.PARENT_PRODUCT_ID IS NULL )
                AND (  p_PARENT_PRODUCT_ID IS NULL )))
       AND (    ( Recinfo.REMOVED_PRODUCT_ID = p_REMOVED_PRODUCT_ID)
            OR (    ( Recinfo.REMOVED_PRODUCT_ID IS NULL )
                AND (  p_REMOVED_PRODUCT_ID IS NULL )))
       AND (    ( Recinfo.STATUS_OF_RECEIVED_PART = p_STATUS_OF_RECEIVED_PART)
            OR (    ( Recinfo.STATUS_OF_RECEIVED_PART IS NULL )
                AND (  p_STATUS_OF_RECEIVED_PART IS NULL )))
       AND (    ( Recinfo.ITEM_SERIAL_NUMBER = p_ITEM_SERIAL_NUMBER)
            OR (    ( Recinfo.ITEM_SERIAL_NUMBER IS NULL )
                AND (  p_ITEM_SERIAL_NUMBER IS NULL )))
       AND (    ( Recinfo.ITEM_REVISION = p_ITEM_REVISION)
            OR (    ( Recinfo.ITEM_REVISION IS NULL )
                AND (  p_ITEM_REVISION IS NULL )))
       AND (    ( Recinfo.ITEM_LOTNUMBER = p_ITEM_LOTNUMBER)
            OR (    ( Recinfo.ITEM_LOTNUMBER IS NULL )
                AND (  p_ITEM_LOTNUMBER IS NULL )))
       AND (    ( Recinfo.UOM_CODE = p_UOM_CODE)
            OR (    ( Recinfo.UOM_CODE IS NULL )
                AND (  p_UOM_CODE IS NULL )))
       AND (    ( Recinfo.QUANTITY = p_QUANTITY)
            OR (    ( Recinfo.QUANTITY IS NULL )
                AND (  p_QUANTITY IS NULL )))
       AND (    ( Recinfo.RMA_HEADER_ID = p_RMA_HEADER_ID)
            OR (    ( Recinfo.RMA_HEADER_ID IS NULL )
                AND (  p_RMA_HEADER_ID IS NULL )))
       AND (    ( Recinfo.DISPOSITION_CODE = p_DISPOSITION_CODE)
            OR (    ( Recinfo.DISPOSITION_CODE IS NULL )
                AND (  p_DISPOSITION_CODE IS NULL )))
       AND (    ( Recinfo.MATERIAL_REASON_CODE = p_MATERIAL_REASON_CODE)
            OR (    ( Recinfo.MATERIAL_REASON_CODE IS NULL )
                AND (  p_MATERIAL_REASON_CODE IS NULL )))
       AND (    ( Recinfo.LABOR_REASON_CODE = p_LABOR_REASON_CODE)
            OR (    ( Recinfo.LABOR_REASON_CODE IS NULL )
                AND (  p_LABOR_REASON_CODE IS NULL )))
       AND (    ( Recinfo.EXPENSE_REASON_CODE = p_EXPENSE_REASON_CODE)
            OR (    ( Recinfo.EXPENSE_REASON_CODE IS NULL )
                AND (  p_EXPENSE_REASON_CODE IS NULL )))
       AND (    ( Recinfo.LABOR_START_DATE = p_LABOR_START_DATE)
            OR (    ( Recinfo.LABOR_START_DATE IS NULL )
                AND (  p_LABOR_START_DATE IS NULL )))
       AND (    ( Recinfo.LABOR_END_DATE = p_LABOR_END_DATE)
            OR (    ( Recinfo.LABOR_END_DATE IS NULL )
                AND (  p_LABOR_END_DATE IS NULL )))
       AND (    ( Recinfo.STARTING_MILEAGE = p_STARTING_MILEAGE)
            OR (    ( Recinfo.STARTING_MILEAGE IS NULL )
                AND (  p_STARTING_MILEAGE IS NULL )))
       AND (    ( Recinfo.ENDING_MILEAGE = p_ENDING_MILEAGE)
            OR (    ( Recinfo.ENDING_MILEAGE IS NULL )
                AND (  p_ENDING_MILEAGE IS NULL )))
       AND (    ( Recinfo.EXPENSE_AMOUNT = p_EXPENSE_AMOUNT)
            OR (    ( Recinfo.EXPENSE_AMOUNT IS NULL )
                AND (  p_EXPENSE_AMOUNT IS NULL )))
       AND (    ( Recinfo.CURRENCY_CODE = p_CURRENCY_CODE)
            OR (    ( Recinfo.CURRENCY_CODE IS NULL )
                AND (  p_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.DEBRIEF_LINE_STATUS_ID = p_DEBRIEF_LINE_STATUS_ID)
            OR (    ( Recinfo.DEBRIEF_LINE_STATUS_ID IS NULL )
                AND (  p_DEBRIEF_LINE_STATUS_ID IS NULL )))
       AND (    ( Recinfo.RETURN_REASON_CODE = p_RETURN_REASON_CODE)
            OR (    ( Recinfo.RETURN_REASON_CODE IS NULL )
                AND (  p_RETURN_REASON_CODE IS NULL )))
       AND (    ( Recinfo.CHANNEL_CODE = p_CHANNEL_CODE)
            OR (    ( Recinfo.CHANNEL_CODE IS NULL )
                AND (  p_CHANNEL_CODE IS NULL )))
       AND (    ( Recinfo.CHARGE_UPLOAD_STATUS = p_CHARGE_UPLOAD_STATUS)
            OR (    ( Recinfo.CHARGE_UPLOAD_STATUS IS NULL )
                AND (  p_CHARGE_UPLOAD_STATUS IS NULL )))
       AND (    ( Recinfo.CHARGE_UPLOAD_MSG_CODE = p_CHARGE_UPLOAD_MSG_CODE)
            OR (    ( Recinfo.CHARGE_UPLOAD_MSG_CODE IS NULL )
                AND (  p_CHARGE_UPLOAD_MSG_CODE IS NULL )))
       AND (    ( Recinfo.CHARGE_UPLOAD_MESSAGE = p_CHARGE_UPLOAD_MESSAGE)
            OR (    ( Recinfo.CHARGE_UPLOAD_MESSAGE IS NULL )
                AND (  p_CHARGE_UPLOAD_MESSAGE IS NULL )))
       AND (    ( Recinfo.IB_UPDATE_STATUS = p_IB_UPDATE_STATUS)
            OR (    ( Recinfo.IB_UPDATE_STATUS IS NULL )
                AND (  p_IB_UPDATE_STATUS IS NULL )))
       AND (    ( Recinfo.IB_UPDATE_MSG_CODE = p_IB_UPDATE_MSG_CODE)
            OR (    ( Recinfo.IB_UPDATE_MSG_CODE IS NULL )
                AND (  p_IB_UPDATE_MSG_CODE IS NULL )))
       AND (    ( Recinfo.IB_UPDATE_MESSAGE = p_IB_UPDATE_MESSAGE)
            OR (    ( Recinfo.IB_UPDATE_MESSAGE IS NULL )
                AND (  p_IB_UPDATE_MESSAGE IS NULL )))
       AND (    ( Recinfo.SPARE_UPDATE_STATUS = p_SPARE_UPDATE_STATUS)
            OR (    ( Recinfo.SPARE_UPDATE_STATUS IS NULL )
                AND (  p_SPARE_UPDATE_STATUS IS NULL )))
       AND (    ( Recinfo.SPARE_UPDATE_MSG_CODE = p_SPARE_UPDATE_MSG_CODE)
            OR (    ( Recinfo.SPARE_UPDATE_MSG_CODE IS NULL )
                AND (  p_SPARE_UPDATE_MSG_CODE IS NULL )))
       AND (    ( Recinfo.SPARE_UPDATE_MESSAGE = p_SPARE_UPDATE_MESSAGE)
            OR (    ( Recinfo.SPARE_UPDATE_MESSAGE IS NULL )
                AND (  p_SPARE_UPDATE_MESSAGE IS NULL )))
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
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID)
            OR (    ( Recinfo.TRANSACTION_TYPE_ID IS NULL )
                AND (  p_TRANSACTION_TYPE_ID IS NULL )))
       AND (    ( Recinfo.RETURN_DATE = p_RETURN_DATE)
            OR (    ( Recinfo.RETURN_DATE IS NULL )
                AND (  p_RETURN_DATE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

FUNCTION GET_RESOURCE_NAME(
    p_resource_id   number,
    p_resource_type varchar2)
    RETURN varchar2 is

    cursor resource_name is
    select resource_name from jtf_rs_all_resources_vl
    where  resource_id = p_resource_id
    and    resource_type = p_resource_type;

    l_resource_name varchar2(200);

    begin
      open resource_name;
      fetch resource_name into l_resource_name;
      close resource_name;
      return l_resource_name;
    end;


End CSF_DEBRIEF_LINES_PKG;


/
