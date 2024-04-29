--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_PUB" as
/* $Header: csfpdbfb.pls 120.2 2007/10/17 08:13:35 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_DEBRIEF_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csfpdbfb.pls';

PROCEDURE Convert_Debrief_Value_To_Id (
                p_Debrief_rec          IN  Debrief_REC_TYPE,
                x_pvt_Debrief_rec      OUT NOCOPY CSF_DEBRIEF_PVT.Debrief_REC_TYPE
  )
  IS
      l_any_errors      BOOLEAN := FALSE;
      l_return_status   VARCHAR2(1);
      l_is_duplicate    VARCHAR2(10);
      l_val             varchar2(30);
      l_id              NUMBER;
      l_status_code     VARCHAR2(30) := NULL;

      l_pvt_Debrief_rec     csf_debrief_pvt.Debrief_REC_TYPE;

  BEGIN
      -- Now copy the rest of the columns to the private record




      --
      l_pvt_Debrief_rec.debrief_header_id 		:= 	p_Debrief_rec.debrief_header_id;
      l_pvt_Debrief_rec.debrief_number			:= 	p_Debrief_rec.debrief_number;
      l_pvt_Debrief_rec.debrief_date			:= 	p_Debrief_rec.debrief_date;
      l_pvt_Debrief_rec.debrief_status_id 		:= 	p_Debrief_rec.debrief_status_id;
      l_pvt_Debrief_rec.task_assignment_id		:= 	p_Debrief_rec.task_assignment_id;
      l_pvt_Debrief_rec.attribute_category  		:= 	p_Debrief_rec.attribute_category;
	l_pvt_Debrief_rec.last_Update_date			:=    p_Debrief_rec.last_update_date;
      l_pvt_Debrief_rec.attribute1    			:= 	p_Debrief_rec.attribute1;
      l_pvt_Debrief_rec.attribute2    			:= 	p_Debrief_rec.attribute2;
      l_pvt_Debrief_rec.attribute3    			:= 	p_Debrief_rec.attribute3;
      l_pvt_Debrief_rec.attribute4    			:= 	p_Debrief_rec.attribute4;
      l_pvt_Debrief_rec.attribute5    			:= 	p_Debrief_rec.attribute5;
      l_pvt_Debrief_rec.attribute6    			:= 	p_Debrief_rec.attribute6;
      l_pvt_Debrief_rec.attribute7    			:= 	p_Debrief_rec.attribute7;
      l_pvt_Debrief_rec.attribute8    			:= 	p_Debrief_rec.attribute8;
      l_pvt_Debrief_rec.attribute9    			:= 	p_Debrief_rec.attribute9;
      l_pvt_Debrief_rec.attribute10   			:= 	p_Debrief_rec.attribute10;
      l_pvt_Debrief_rec.attribute11   			:= 	p_Debrief_rec.attribute11;
      l_pvt_Debrief_rec.attribute12   			:= 	p_Debrief_rec.attribute12;
      l_pvt_Debrief_rec.attribute13   			:= 	p_Debrief_rec.attribute13;
      l_pvt_Debrief_rec.attribute14   			:= 	p_Debrief_rec.attribute14;
      l_pvt_Debrief_rec.attribute15   			:= 	p_Debrief_rec.attribute15;
      l_pvt_Debrief_rec.created_by         :=  p_Debrief_rec.created_by;
      l_pvt_Debrief_rec.creation_date      :=  p_Debrief_rec.creation_date;
      l_pvt_Debrief_rec.last_updated_by    :=  p_Debrief_rec.last_updated_by;
      l_pvt_Debrief_rec.last_update_date   :=  p_Debrief_rec.last_update_date;
      l_pvt_Debrief_rec.last_update_login  :=  p_Debrief_rec.last_update_login;

      l_pvt_Debrief_rec.object_version_number		:= 	p_Debrief_rec.object_version_number;
      l_pvt_Debrief_rec.TRAVEL_START_TIME 		:= 	p_Debrief_rec.TRAVEL_START_TIME;
      l_pvt_Debrief_rec.TRAVEL_END_TIME 		:= 	p_Debrief_rec.TRAVEL_END_TIME;
      l_pvt_Debrief_rec.TRAVEL_DISTANCE_IN_KM  		:= 	p_Debrief_rec.TRAVEL_DISTANCE_IN_KM;

	 -- End
      x_pvt_Debrief_rec := l_pvt_Debrief_rec;
      -- If there was an error in processing the row, then raise an error
      --
      IF l_any_errors
      THEN
          raise FND_API.G_EXC_ERROR;
      END IF;

END Convert_Debrief_Value_To_Id;

/********************  need to be deleted later

PROCEDURE Convert_Interest_Values_To_Ids (p_interest_type                 IN  VARCHAR2,
                                            p_interest_type_id              IN  NUMBER,
                                            p_primary_interest_code         IN  VARCHAR2,
                                            p_primary_interest_code_id      IN  NUMBER,
                                            p_secondary_interest_code       IN  VARCHAR2,
                                            p_secondary_interest_code_id    IN  NUMBER,
                                            p_return_status                 OUT NOCOPY VARCHAR2,
                                            p_out_interest_type_id          OUT NOCOPY NUMBER,
                                            p_out_primary_interest_code_id  OUT NOCOPY NUMBER,
                                            p_out_second_interest_code_id   OUT NOCOPY NUMBER
                                            ) IS
    Cursor C_Get_Int_Type (X_Int_Type VARCHAR2) IS
      SELECT  interest_type_id
      FROM  as_interest_types
      WHERE nls_upper(X_Int_Type) = nls_upper(interest_type)
      and (interest_type like nls_upper(substr(X_Int_Type, 1, 1) || '%') or
         interest_type like lower(substr(X_Int_Type, 1, 1) || '%'));

    Cursor C_Get_Int_Code (X_Int_Code VARCHAR2, X_Int_Type_Id NUMBER) IS
      SELECT  interest_code_id
      FROM  as_interest_codes
     WHERE nls_upper(X_Int_Code) = nls_upper(code)
      and   interest_type_id = X_Int_Type_Id;

    l_interest_type_id  NUMBER;
    l_interest_code_id  NUMBER;
    l_secondary_interest_code_id  NUMBER;
  BEGIN

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize Out Variables
    p_out_interest_type_id    := NULL;
    p_out_primary_interest_code_id  := NULL;
    p_out_second_interest_code_id := NULL;

    -- Convert Interest Type
    --
    IF (p_interest_type_id is not NULL and
        p_interest_type_id <> FND_API.G_MISS_NUM)
    THEN
      p_out_interest_type_id := p_interest_type_id;
      l_interest_type_id := p_interest_type_id;

      IF (p_interest_type is not NULL and
          p_interest_type <> FND_API.G_MISS_CHAR)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.Set_Name ('CSF', 'API_ATTRIBUTE_IGNORED');
          FND_MESSAGE.Set_Token ('COLUMN', 'INTEREST_TYPE', FALSE);
          FND_MSG_PUB.Add;
        END IF;
      END IF;

    ELSIF (p_interest_type is not NULL and
          p_interest_type <> FND_API.G_MISS_CHAR)
    THEN
      OPEN C_Get_Int_Type ( p_interest_type );
      FETCH C_Get_Int_Type INTO l_interest_type_id;
      CLOSE C_Get_Int_Type;

      IF (l_interest_type_id IS NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name ('CSF', 'API_ATTRIBUTE_CONVERSION_ERROR');
          FND_MESSAGE.Set_Token ('COLUMN', 'INTEREST_TYPE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_interest_type, FALSE);
          FND_MSG_PUB.Add;
        END IF;

        raise FND_API.G_EXC_ERROR;

      ELSE
        p_out_interest_type_id := l_interest_type_id;
      END IF;

    ELSE
      -- If no interest type (value or id) exists, then this row is invalid
      --
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.Set_Name ('CSF','API_MISSING_ID');
        FND_MESSAGE.Set_Token ('COLUMN', 'INTEREST_TYPE', FALSE);
        FND_MSG_PUB.Add;
      END IF;

      raise FND_API.G_EXC_ERROR;
    END IF;

    -- Convert Primary Code
    --
    IF (p_primary_interest_code_id is not NULL and
        p_primary_interest_code_id <> FND_API.G_MISS_NUM)
    THEN
      p_out_primary_interest_code_id := p_primary_interest_code_id;
      l_interest_code_id := p_primary_interest_code_id;

      IF (p_primary_interest_code is not NULL and
          p_primary_interest_code <> FND_API.G_MISS_CHAR)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.Set_Name ('CSF','API_ATTRIBUTE_IGNORED');
          FND_MESSAGE.Set_Token ('COLUMN', 'PRIMARY_INTEREST_CODE', FALSE);
          FND_MSG_PUB.Add;
        END IF;
      END IF;

    ELSIF (p_primary_interest_code is not NULL and
           p_primary_interest_code <> FND_API.G_MISS_CHAR)
    THEN
      OPEN C_Get_Int_Code ( p_primary_interest_code,
                l_interest_type_id );
      FETCH C_Get_Int_Code INTO l_interest_code_id;
      CLOSE C_Get_Int_Code;

      IF (l_interest_code_id IS NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name ('CSF', 'API_ATTRIBUTE_CONVERSION_ERROR');
          FND_MESSAGE.Set_Token ('COLUMN', 'PRIMARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_primary_interest_code, FALSE);
          FND_MSG_PUB.Add;
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
        p_out_primary_interest_code_id := l_interest_code_id;
      END IF;
    END IF;

    -- Convert Secondary Code
    --
    IF (p_secondary_interest_code_id is not NULL and
        p_secondary_interest_code_id <> FND_API.G_MISS_NUM)
    THEN
      p_out_second_interest_code_id := p_secondary_interest_code_id;
      l_secondary_interest_code_id := p_secondary_interest_code_id;

      IF (p_secondary_interest_code is not NULL and
          p_secondary_interest_code <> FND_API.G_MISS_CHAR)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.Set_Name ('CSF', 'API_ATTRIBUTE_IGNORED');
          FND_MESSAGE.Set_Token ('COLUMN', 'SECONDARY_INTEREST_CODE', FALSE);
          FND_MSG_PUB.Add;
        END IF;
      END IF;

    ELSIF (p_secondary_interest_code is not NULL and
           p_secondary_interest_code <> FND_API.G_MISS_CHAR)
    THEN
      OPEN C_Get_Int_Code ( p_secondary_interest_code,
      			    l_interest_type_id );
      FETCH C_Get_Int_Code INTO l_secondary_interest_code_id;
      CLOSE C_Get_Int_Code;

      IF (l_secondary_interest_code_id IS NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name ('CSF', 'API_ATTRIBUTE_CONVERSION_ERROR');
          FND_MESSAGE.Set_Token ('COLUMN', 'SECONDARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_secondary_interest_code, FALSE);
          FND_MSG_PUB.Add;
        END IF;
        p_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
        p_out_second_interest_code_id := l_secondary_interest_code_id;

      END IF;
    END IF;

END Convert_Interest_Values_To_Ids;

 ****************************/

PROCEDURE Conv_DEBRIEF_LINE_ValToId(
         P_DEBRIEF_LINE_tbl        IN    DEBRIEF_LINE_tbl_Type,
         x_pvt_DEBRIEF_LINE_tbl    OUT NOCOPY   CSF_DEBRIEF_PVT.DEBRIEF_LINE_tbl_Type
)
IS
l_any_errors        BOOLEAN   := FALSE;
l_any_row_errors    BOOLEAN   := FALSE;
l_return_status     VARCHAR2(1);
l_dummy_description VARCHAR2(30);
l_pub_debrief_line_rec     debrief_line_rec_type;
l_pvt_debrief_line_rec     CSF_DEBRIEF_PVT.debrief_line_rec_type;
lx_pvt_debrief_line_tbl		CSF_DEBRIEF_PVT.debrief_line_tbl_type;
l_count             NUMBER := p_debrief_line_tbl.count;
p_debrief_line_rec     debrief_line_rec_type;
x_return_status     VARCHAR2(1);
x_msg_data          VARCHAR2(2000);
x_msg_count         NUMBER;


BEGIN
 /*
lx_pvt_debrief_line_tbl  	:=	p_debrief_line_tbl;
 x_pvt_debrief_line_tbl 	:=    lx_pvt_debrief_line_tbl;
 */


FOR l_curr_row in 1..l_count
LOOP
 BEGIN

  -- Now copy all (the rest ) of the columns to the private record
p_debrief_line_rec	:=	p_debrief_line_tbl(l_curr_row);

x_pvt_DEBRIEF_LINE_tbl(l_curr_row).DEBRIEF_LINE_ID 	:= P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).LAST_UPDATE_DATE 	:= P_DEBRIEF_LINE_Rec.LAST_UPDATE_DATE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).LAST_UPDATED_BY 	:= P_DEBRIEF_LINE_Rec.LAST_UPDATED_BY;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).CREATION_DATE 	:= P_DEBRIEF_LINE_Rec.CREATION_DATE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).CREATED_BY 		:= P_DEBRIEF_LINE_Rec.CREATED_BY;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).LAST_UPDATE_LOGIN 	:= P_DEBRIEF_LINE_Rec.LAST_UPDATE_LOGIN;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).DEBRIEF_HEADER_ID	:= P_DEBRIEF_LINE_Rec.DEBRIEF_HEADER_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).DEBRIEF_LINE_NUMBER := P_DEBRIEF_LINE_Rec. DEBRIEF_LINE_NUMBER ;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).SERVICE_DATE		:= P_DEBRIEF_LINE_Rec.SERVICE_DATE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).BUSINESS_PROCESS_ID := P_DEBRIEF_LINE_Rec.BUSINESS_PROCESS_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).TXN_BILLING_TYPE_ID
					:= P_DEBRIEF_LINE_Rec.TXN_BILLING_TYPE_ID;

x_pvt_DEBRIEF_LINE_tbl(l_curr_row).INVENTORY_ITEM_ID	:= P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).INSTANCE_ID	:= P_DEBRIEF_LINE_Rec.INSTANCE_ID;

x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ISSUING_INVENTORY_ORG_ID
									:= P_DEBRIEF_LINE_Rec.ISSUING_INVENTORY_ORG_ID ;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).RECEIVING_INVENTORY_ORG_ID
									:= P_DEBRIEF_LINE_Rec.RECEIVING_INVENTORY_ORG_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ISSUING_SUB_INVENTORY_CODE
									:= P_DEBRIEF_LINE_Rec.ISSUING_SUB_INVENTORY_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).RECEIVING_SUB_INVENTORY_CODE
									:= P_DEBRIEF_LINE_Rec.RECEIVING_SUB_INVENTORY_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ISSUING_LOCATOR_ID		:= P_DEBRIEF_LINE_Rec.ISSUING_LOCATOR_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).RECEIVING_LOCATOR_ID	:= P_DEBRIEF_LINE_Rec.RECEIVING_LOCATOR_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).PARENT_PRODUCT_ID		:= P_DEBRIEF_LINE_Rec.PARENT_PRODUCT_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).REMOVED_PRODUCT_ID		:= P_DEBRIEF_LINE_Rec.REMOVED_PRODUCT_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).STATUS_OF_RECEIVED_PART	:= P_DEBRIEF_LINE_Rec.STATUS_OF_RECEIVED_PART;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ITEM_SERIAL_NUMBER		:= P_DEBRIEF_LINE_Rec.ITEM_SERIAL_NUMBER;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ITEM_REVISION		:= P_DEBRIEF_LINE_Rec.ITEM_REVISION;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ITEM_LOTNUMBER		:= P_DEBRIEF_LINE_Rec.ITEM_LOTNUMBER;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).UOM_CODE			:= P_DEBRIEF_LINE_Rec.UOM_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).QUANTITY			:= P_DEBRIEF_LINE_Rec.QUANTITY;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE_CATEGORY
										:= P_DEBRIEF_LINE_Rec.ATTRIBUTE_CATEGORY ;
-- x_pvt_DEBRIEF_LINE_tbl(l_curr_row).RMA_NUMBER			:= P_DEBRIEF_LINE_Rec.RMA_NUMBER;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).RMA_HEADER_ID		:= P_DEBRIEF_LINE_Rec.RMA_HEADER_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).DISPOSITION_CODE		:= P_DEBRIEF_LINE_Rec.DISPOSITION_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).MATERIAL_REASON_CODE	:= P_DEBRIEF_LINE_Rec.MATERIAL_REASON_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).LABOR_REASON_CODE		:= P_DEBRIEF_LINE_Rec.LABOR_REASON_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).EXPENSE_REASON_CODE	:= P_DEBRIEF_LINE_Rec.EXPENSE_REASON_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).LABOR_START_DATE		:= P_DEBRIEF_LINE_Rec.LABOR_START_DATE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).LABOR_END_DATE		:= P_DEBRIEF_LINE_Rec.LABOR_END_DATE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).STARTING_MILEAGE		:= P_DEBRIEF_LINE_Rec.STARTING_MILEAGE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ENDING_MILEAGE		:= P_DEBRIEF_LINE_Rec.ENDING_MILEAGE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).EXPENSE_AMOUNT		:= P_DEBRIEF_LINE_Rec.EXPENSE_AMOUNT;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).CURRENCY_CODE		:= P_DEBRIEF_LINE_Rec.CURRENCY_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).DEBRIEF_LINE_STATUS_ID
							:= P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_STATUS_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).CHANNEL_CODE := P_DEBRIEF_LINE_Rec.CHANNEL_CODE ;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).CHARGE_UPLOAD_STATUS
							:= P_DEBRIEF_LINE_Rec.CHARGE_UPLOAD_STATUS ;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).CHARGE_UPLOAD_MSG_CODE
							:= P_DEBRIEF_LINE_Rec.CHARGE_UPLOAD_MSG_CODE ;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).CHARGE_UPLOAD_MESSAGE
								:= P_DEBRIEF_LINE_Rec.CHARGE_UPLOAD_MESSAGE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).IB_UPDATE_STATUS		:= P_DEBRIEF_LINE_Rec.IB_UPDATE_STATUS;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).IB_UPDATE_MSG_CODE		:= P_DEBRIEF_LINE_Rec.IB_UPDATE_MSG_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).IB_UPDATE_MESSAGE 		:= P_DEBRIEF_LINE_Rec.IB_UPDATE_MESSAGE ;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).SPARE_UPDATE_STATUS	:= P_DEBRIEF_LINE_Rec.SPARE_UPDATE_STATUS;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).SPARE_UPDATE_MSG_CODE
							:= P_DEBRIEF_LINE_Rec.SPARE_UPDATE_MSG_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).SPARE_UPDATE_MESSAGE
								:= P_DEBRIEF_LINE_Rec.SPARE_UPDATE_MESSAGE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE1 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE1;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE2 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE2;
   x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE3 		:= P_DEBRIEF_LINE_Rec.ATTRIBUTE3;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE4 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE4;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE5 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE5;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE6 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE6;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE7 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE7;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE8 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE8;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE9 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE9;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE10 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE10;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE11 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE11;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE12 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE12;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE13 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE13;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE14 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE14;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).ATTRIBUTE15 			:= P_DEBRIEF_LINE_Rec.ATTRIBUTE15;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).RETURN_REASON_CODE 		:= P_DEBRIEF_LINE_Rec.RETURN_REASON_CODE;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).TRANSACTION_TYPE_ID
					:= P_DEBRIEF_LINE_Rec.TRANSACTION_TYPE_ID;
x_pvt_DEBRIEF_LINE_tbl(l_curr_row).RETURN_DATE		:= P_DEBRIEF_LINE_Rec.RETURN_DATE;



    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

  EXCEPTION
	   WHEN OTHERS THEN
	        l_any_errors := TRUE;
	        l_any_row_errors  := FALSE;
	        x_pvt_debrief_line_tbl(l_curr_row)  := l_pvt_debrief_line_rec;

END;
END LOOP;


END Conv_DEBRIEF_LINE_ValToId;

PROCEDURE Create_Debrief(
    P_Api_Version_Number         	IN   NUMBER,
    P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
    P_DEBRIEF_Rec    	        	IN    DEBRIEF_Rec_Type  := G_MISS_DEBRIEF_REC,
    P_DEBRIEF_LINE_tbl        	IN    DEBRIEF_LINE_tbl_type  ,
							--	DEFAULT G_MISS_DEBRIEF_LINE_tbl,
    X_DEBRIEF_HEADER_ID             OUT NOCOPY  NUMBER,
    X_Return_Status              	OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  	OUT NOCOPY  NUMBER,
    X_Msg_Data                   	OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_debrief';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_DEBRIEF_rec      	  CSF_DEBRIEF_PVT.DEBRIEF_Rec_Type;
l_count                   CONSTANT NUMBER := p_debrief_line_tbl.count;
p_debrief_line_rec     	  DEBRIEF_LINE_REC_TYPE;
l_pvt_DEBRIEF_LINE_tbl 	  CSF_DEBRIEF_PVT.DEBRIEF_LINE_Tbl_Type;
x_debrief_line_id         NUMBER;
l_return_status           VARCHAR2(1);
 BEGIN
      SAVEPOINT CREATE_DEBRIEF_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- API body
      --
      -- Convert the values to ids
      --
      Convert_DEBRIEF_Value_To_Id (
            p_DEBRIEF_rec       =>  p_DEBRIEF_rec,
            x_pvt_DEBRIEF_rec   =>  l_pvt_DEBRIEF_rec
      );
      Conv_DEBRIEF_LINE_ValToId(
            p_DEBRIEF_LINE_tbl       =>  p_DEBRIEF_LINE_tbl,
            x_pvt_DEBRIEF_LINE_tbl   =>  l_pvt_DEBRIEF_LINE_tbl
      );

    -- Calling Private package: Create_DEBRIEF
      CSF_DEBRIEF_PVT.Create_debrief(
      P_Api_Version_Number         	=> 1.0,
      P_Init_Msg_List              	=> FND_API.G_FALSE,
      P_Commit                     	=> FND_API.G_FALSE,
      P_Validation_Level           	=> FND_API.G_VALID_LEVEL_FULL,
      P_DEBRIEF_Rec             	=> l_pvt_DEBRIEF_Rec ,
      P_DEBRIEF_LINE_tbl        	=> l_pvt_DEBRIEF_LINE_tbl,
      X_DEBRIEF_HEADER_ID     	=> x_DEBRIEF_HEADER_ID,
      X_Return_Status              	=> x_return_status,
      X_Msg_Count                  	=> x_msg_count,
      X_Msg_Data                   	=> x_msg_data);


      -- End of API body.
      --
      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN

		    ROLLBACK TO  CREATE_DEBRIEF_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO  CREATE_DEBRIEF_PUB;

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);
          WHEN OTHERS THEN
		    ROLLBACK TO  CREATE_DEBRIEF_PUB;

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				IF 	FND_MSG_PUB.Check_Msg_Level
					(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			     THEN
				   	FND_MSG_PUB.Add_Exc_Msg (
                   	 	G_PKG_NAME
                  		,L_API_NAME );
				 END IF;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

End Create_debrief;

PROCEDURE Update_debrief(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_DEBRIEF_Rec             IN   DEBRIEF_Rec_Type ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_debrief';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_DEBRIEF_rec      CSF_DEBRIEF_PVT.DEBRIEF_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_DEBRIEF_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- API body
      -- Convert the values to ids
      --
      Convert_DEBRIEF_Value_To_Id (
            p_DEBRIEF_rec       =>  p_DEBRIEF_rec,
            x_pvt_DEBRIEF_rec   =>  l_pvt_DEBRIEF_rec
      );

    CSF_DEBRIEF_PVT.Update_debrief(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_Rec             	=> l_pvt_DEBRIEF_Rec ,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

          WHEN OTHERS THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				IF FND_MSG_PUB.Check_Msg_Level
					 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			     THEN
				   FND_MSG_PUB.Add_Exc_Msg (
                   	 G_PKG_NAME
                  	,L_API_NAME );
				 END IF;

				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

End Update_debrief;

PROCEDURE Create_debrief_lines(
    P_Api_Version_Number        IN   NUMBER,
    P_Init_Msg_List             IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                    IN   VARCHAR2     := FND_API.G_FALSE,
    P_Upd_tskassgnstatus        IN   VARCHAR2   ,
    P_Task_Assignment_status    IN   VARCHAR2   ,
    P_DEBRIEF_LINE_Tbl        	IN   DEBRIEF_LINE_Tbl_Type  := G_MISS_DEBRIEF_LINE_Tbl,
    P_DEBRIEF_HEADER_ID         IN   NUMBER,
    P_SOURCE_OBJECT_TYPE_CODE   IN   VARCHAR2,
    X_Return_Status             OUT NOCOPY  VARCHAR2,
    X_Msg_Count                 OUT NOCOPY  NUMBER,
    X_Msg_Data                  OUT NOCOPY  VARCHAR2
    )
 IS
   l_api_name                   CONSTANT VARCHAR2(30) := 'Create_debrief_lines';
   l_api_version_number         CONSTANT NUMBER   := 1.0;
   l_pvt_DEBRIEF_LINE_tbl    CSF_DEBRIEF_PVT.DEBRIEF_LINE_tbl_Type;

 BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_DEBRIEF_LINE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN FND_MSG_PUB.initialize; END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- API body
      --
      -- Convert the values to ids

      Conv_DEBRIEF_LINE_ValToId(
            p_DEBRIEF_LINE_tbl       =>  p_DEBRIEF_LINE_tbl,
            x_pvt_DEBRIEF_LINE_tbl   =>  l_pvt_DEBRIEF_LINE_tbl
      );

    -- Calling Private package: Create_DEBRIEF_LINE

      CSF_debrief_PVT.Create_debrief_lines(
      P_Api_Version_Number         	=> 1.0,
      P_Init_Msg_List              	=> FND_API.G_FALSE,
      P_Commit                     	=> FND_API.G_FALSE,
      P_Upd_tskassgnstatus              => P_Upd_tskassgnstatus,
      P_Task_Assignment_status          =>  P_Task_Assignment_status      ,
      P_Validation_Level           	=> FND_API.G_VALID_LEVEL_FULL,
      P_DEBRIEF_LINE_tbl        	=> l_pvt_DEBRIEF_LINE_tbl,
      P_DEBRIEF_HEADER_ID          	=> P_DEBRIEF_HEADER_ID,
      P_SOURCE_OBJECT_TYPE_CODE         => P_SOURCE_OBJECT_TYPE_CODE,
      X_Return_Status             	=> x_return_status,
      X_Msg_Count                  	=> x_msg_count,
      X_Msg_Data                   	=> x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- End of API body.
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		    ROLLBACK TO  CREATE_DEBRIEF_LINE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO  CREATE_DEBRIEF_LINE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

          WHEN OTHERS THEN
		    ROLLBACK TO  CREATE_DEBRIEF_LINE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				IF FND_MSG_PUB.Check_Msg_Level
					 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			     THEN
				   FND_MSG_PUB.Add_Exc_Msg (
                   	 G_PKG_NAME
                  	,L_API_NAME );
				 END IF;

				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

End Create_debrief_lines;

PROCEDURE Update_debrief_line(
    P_Api_Version_Number         	IN   NUMBER,
    P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
    P_Upd_tskassgnstatus        IN VARCHAR2   ,
    P_Task_Assignment_status     IN VARCHAR2  ,
    P_DEBRIEF_LINE_Rec        	IN   DEBRIEF_LINE_Rec_Type,
    X_Return_Status              	OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  	OUT NOCOPY  NUMBER,
    X_Msg_Data                   	OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                 CONSTANT VARCHAR2(30) := 'Update_debrief_line';
l_api_version_number       CONSTANT NUMBER   := 1.0;
l_pvt_DEBRIEF_LINE_rec  CSF_DEBRIEF_PVT.DEBRIEF_LINE_Rec_Type;
l_pvt_DEBRIEF_LINE_tbl  CSF_DEBRIEF_PVT.DEBRIEF_LINE_tbl_Type;
p_DEBRIEF_LINE_tbl DEBRIEF_LINE_TBL_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_DEBRIEF_LINE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
                              -- dbms_output.put_line ( 'step 3 PUB');
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
                                               -- dbms_output.put_line ( 'step 4 PUB');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body

      -- Convert the values to ids
      --

      p_DEBRIEF_LINE_tbl(1) := P_DEBRIEF_LINE_Rec;
-- dbms_output.put_line ( 'step 2 PUB');

      Conv_DEBRIEF_LINE_ValToId(
            p_DEBRIEF_LINE_tbl       =>  p_DEBRIEF_LINE_tbl,
            x_pvt_DEBRIEF_LINE_tbl   =>  l_pvt_DEBRIEF_LINE_tbl
      );

 -- dbms_output.put_line ( 'step 1 PUB');

    CSF_DEBRIEF_PVT.Update_debrief_line(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Upd_tskassgnstatus        =>  P_Upd_tskassgnstatus         ,
    P_Task_Assignment_status     =>  P_Task_Assignment_status     ,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_LINE_Rec        => l_pvt_DEBRIEF_LINE_tbl(1),
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);

-- dbms_output.put_line ( 'step 1 PUB');
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then

          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- End of API body
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_LINE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_LINE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

          WHEN OTHERS THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_LINE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				IF FND_MSG_PUB.Check_Msg_Level
					 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			     THEN
				   FND_MSG_PUB.Add_Exc_Msg (
                   	 G_PKG_NAME
                  	,L_API_NAME );
				 END IF;

				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA => X_MSG_DATA);

End Update_debrief_line;
PROCEDURE call_internal_hook (
      p_package_name      IN       VARCHAR2,
      p_api_name          IN       VARCHAR2,
      p_processing_type   IN       VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR c1
      IS
         SELECT hook_package, hook_api
           FROM jtf_hooks_data
          WHERE package_name = p_package_name
            AND api_name = p_api_name
            AND execute_flag = 'Y'
            AND processing_type = p_processing_type
          ORDER BY execution_order;

      v_cursorid   INTEGER;
      v_blockstr   VARCHAR2(2000);
      v_dummy      INTEGER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      FOR i IN c1
      LOOP
         v_cursorid := DBMS_SQL.open_cursor;
         v_blockstr :=
            ' begin ' || i.hook_package || '.' || i.hook_api || '(:1); end; ';
         DBMS_SQL.parse (v_cursorid, v_blockstr, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (v_cursorid, ':1', x_return_status, 20);
         v_dummy := DBMS_SQL.execute (v_cursorid);
         DBMS_SQL.variable_value (v_cursorid, ':1', x_return_status);
         DBMS_SQL.close_cursor (v_cursorid);

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_RETURN_STATUS');
            fnd_message.set_token (
               'P_PROCEDURE',
               i.hook_package || '.' || i.hook_api
            );
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF x_return_status IS NULL
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_RETURN_STATUS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;
End CSF_DEBRIEF_PUB;



/
