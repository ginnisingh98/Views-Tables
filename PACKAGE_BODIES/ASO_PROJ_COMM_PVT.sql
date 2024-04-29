--------------------------------------------------------
--  DDL for Package Body ASO_PROJ_COMM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PROJ_COMM_PVT" as
/* $Header: asovpqcb.pls 120.5.12000000.2 2007/01/30 20:24:40 pkoka ship $ */
-- Start of Comments
-- Package name     : ASO_PROJ_COMM_PVT
-- Purpose         :
-- History         :
-- NOTE       :
-- End of Comments


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'ASO_PROJ_COMM_PVT';


PROCEDURE Calculate_Proj_Commission (
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Resource_Id                IN    NUMBER       := FND_API.G_MISS_NUM,
    X_Last_Update_Date           OUT NOCOPY /* file.sql.39 change */   DATE,
    X_Object_Version_Number      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS

   CURSOR C_Get_Header_Info (l_qte_hdr NUMBER) IS
    SELECT Quote_Number, Last_Update_Date, Quote_Expiration_Date, Quote_Status_Id,
           Pricing_Status_Indicator, Price_Updated_Date, Credit_Update_Date, Object_Version_Number, Org_Id
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE Quote_Header_Id = l_qte_hdr;

   CURSOR C_Check_Qte_Ordered (l_status NUMBER) IS
    SELECT 'Y'
    FROM ASO_QUOTE_STATUSES_B
    WHERE Quote_Status_Id = l_status
    AND Status_Code = 'ORDER SUBMITTED';

   CURSOR C_Check_Res_Team (l_resource NUMBER, l_qte_num NUMBER) IS
    SELECT 'Y'
    FROM ASO_QUOTE_ACCESSES
    WHERE Quote_Number = l_qte_num
    AND Resource_Id = l_resource;

   CURSOR C_Get_Line_Id (l_hdr_id NUMBER) IS
    SELECT Quote_Line_Id
    FROM ASO_QUOTE_LINES_ALL
    WHERE Quote_Header_Id = l_hdr_id;

    C_Header_Info           C_Get_Header_Info%ROWTYPE;

    l_api_name              CONSTANT VARCHAR2 ( 50 ) := 'Calculate_Proj_Commission';
    l_api_version_number    CONSTANT NUMBER := 1.0;
    lx_return_status        VARCHAR2(1);
    l_ordered               VARCHAR2(1) := 'N';
    l_found                 VARCHAR2(1) := 'N';
    l_In_Line_Number_Tbl    ASO_LINE_NUM_INT.In_Line_Number_Tbl_Type;
    l_Out_Line_Number_Tbl   ASO_LINE_NUM_INT.Out_Line_Number_Tbl_Type;
    lx_inc_plnr_disclaimer  cn_repositories.income_planner_disclaimer%TYPE;

    lx_Qte_Header_Rec       ASO_QUOTE_PUB.Qte_Header_Rec_Type;

    l_auto_sales_team_prof  VARCHAR2(50) := NVL(FND_PROFILE.Value('ASO_AUTO_TEAM_ASSIGN'),'NONE');
    l_auto_sales_cred_prof  VARCHAR2(50) := NVL(FND_PROFILE.Value('ASO_AUTO_SALES_CREDIT'),'NONE');
    l_proj_comm_prof        VARCHAR2(50) := NVL(FND_PROFILE.Value('ASO_PROJ_COMMISSION'),'N');

BEGIN

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard Start of API savepoint
      SAVEPOINT CALCULATE_PROJ_COMMISSION_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           1.0,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: Begin ',1,'Y');
aso_debug_pub.add('Calc_Proj_Comm: l_proj_comm_prof: '||l_proj_comm_prof,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: l_auto_sales_team_prof: '||l_auto_sales_team_prof,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: l_auto_sales_cred_prof: '||l_auto_sales_cred_prof,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: p_qte_header_rec.quote_header_id: '||p_qte_header_rec.quote_header_id,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: p_qte_header_rec.last_update_date: '||p_qte_header_rec.last_update_date,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: P_Resource_Id: '||P_Resource_Id,1,'N');
END IF;
     -- Basic Validations
     -- Check If ASO:Calculate Projected Commmission is set
     IF l_proj_comm_prof <> 'Y' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_PROJ_COMM_NOT_SET');
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     OPEN C_Get_Header_Info(P_Qte_Header_Rec.Quote_Header_Id);
     FETCH C_Get_Header_Info INTO C_Header_Info;

     -- Check Whether record has been changed
     IF (C_Get_Header_Info%NOTFOUND) OR
        (C_Header_Info.last_update_date IS NULL OR
         C_Header_Info.last_update_date = FND_API.G_MISS_DATE) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
             FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
             FND_MSG_PUB.ADD;
         END IF;
         CLOSE C_Get_Header_Info;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     CLOSE C_Get_Header_Info;

     IF (p_qte_header_rec.last_update_date IS NOT NULL AND
         p_qte_header_rec.last_update_date <> FND_API.G_MISS_DATE) AND
        (C_Header_Info.last_update_date <> p_qte_header_rec.last_update_date) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if a concurrent lock exists
     ASO_CONC_REQ_INT.Lock_Exists(
      p_quote_header_id => p_qte_header_rec.quote_header_id,
      x_status          => lx_return_status);

     IF (lx_return_status = FND_API.G_TRUE) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
             FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if ASO:Automatic Sales Assign and ASO:Auto Sales Credit Alloc are set
     IF (l_auto_sales_team_prof <> 'FULL' AND l_auto_sales_team_prof <> 'PARTIAL') OR
        (l_auto_sales_cred_prof <> 'FULL' AND l_auto_sales_cred_prof <> 'PARTIAL') THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_TEAM_CRED_PROF_NOT_SET');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if Resource_Id is passed
     IF P_Resource_Id IS NULL OR P_Resource_Id = FND_API.G_MISS_NUM THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_NULL_RESOURCE');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if Resource_Id is in the Sales Team
	OPEN C_Check_Res_Team (P_Resource_Id, C_Header_Info.Quote_Number);
     FETCH C_Check_Res_Team INTO l_found;
     CLOSE C_Check_Res_Team;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: C_Header_Info.Quote_Expiration_Date: '||C_Header_Info.Quote_Expiration_Date,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: C_Header_Info.Quote_Number: '||C_Header_Info.Quote_Number,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: l_found: '||l_found,1,'N');
END IF;

     IF l_found IS NULL OR l_found <> 'Y' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_INV_RESOURCE');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if Quote has expired
     /* Removing the validation for fixing bug 5734955 - PKOKA
     IF C_Header_Info.Quote_Expiration_Date IS NOT NULL AND
        (trunc(SYSDATE) > trunc(C_Header_Info.Quote_Expiration_Date)) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_QUOTE_EXPIRED');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
     */

     -- Check if Quote is ordered
     OPEN C_Check_Qte_Ordered (C_Header_Info.Quote_Status_Id);
     FETCH C_Check_Qte_Ordered INTO l_ordered;
     CLOSE C_Check_Qte_Ordered;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: C_Header_Info.Pricing_Status_Indicator: '||C_Header_Info.Pricing_Status_Indicator,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: C_Header_Info.Credit_Update_Date: '||C_Header_Info.Credit_Update_Date,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: C_Header_Info.Price_Updated_Date: '||C_Header_Info.Price_Updated_Date,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: C_Header_Info.Quote_Status_Id: '||C_Header_Info.Quote_Status_Id,1,'N');
aso_debug_pub.add('Calc_Proj_Comm: l_ordered: '||l_ordered,1,'N');
END IF;
     IF l_ordered IS NOT NULL AND l_ordered = 'Y' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_ORDERED_STATUS_TRANS');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if pricing status is Complete
     IF C_Header_Info.Pricing_Status_Indicator IS NULL OR
        C_Header_Info.Pricing_Status_Indicator <> 'C' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_PRICING_INCOMPLETE');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if credit_update_date is earlier than pricing date
     IF C_Header_Info.Credit_Update_Date IS NULL OR
        (C_Header_Info.Price_Updated_Date IS NOT NULL AND
        C_Header_Info.Credit_Update_Date < C_Header_Info.Price_Updated_Date) THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: Before Allocate_Sales_Credits ',1,'N');
END IF;

          ASO_QUOTE_PUB.Allocate_Sales_Credits
          (
              P_Api_Version_Number  => 1.0,
              P_Init_Msg_List         => FND_API.G_FALSE,
              P_Commit                => FND_API.G_TRUE,
              p_Qte_Header_Rec        => p_qte_header_rec,
              x_Qte_Header_Rec        => lx_qte_header_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data
           );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: After Allocate_Sales_Credits:x_return_status '||x_return_status,1,'N');
END IF;

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          X_Object_Version_Number := lx_qte_header_rec.Object_Version_Number;
          X_Last_Update_Date := lx_qte_header_rec.Last_Update_Date;

     ELSE

         X_Object_Version_Number := C_Header_Info.Object_Version_Number;
         X_Last_Update_Date := C_Header_Info.Last_Update_Date;

     END IF;
     -- END: Basic Validations

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: Before Trucate table ',1,'N');
END IF;
     -- Truncate Temp table
     DELETE FROM CN_PROJ_COMPENSATION_GTT;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: Before Insert into table ',1,'N');
END IF;
     -- Populate input values into temp table
     INSERT INTO CN_PROJ_COMPENSATION_GTT (
                             LINE_NUMBER,
                             RESOURCE_ID,
                             PROJECTION_IDENTIFIER,
                             CALC_DATE,
                             SALES_CREDIT_AMOUNT,
                             CURRENCY_CODE)
                      SELECT A.Quote_Line_Id,
                             B.Resource_Id,
                             A.Inventory_Item_Id,
                             SYSDATE,
                             (DECODE(A.Line_Category_Code,'RETURN',-1,1) * A.Quantity * A.Line_Quote_Price) * (SUM(B.Percent)/100) Sales_Credit_Amount,
                             NVL(A.Currency_Code, C.Currency_Code)
                        FROM ASO_QUOTE_LINES_ALL A, ASO_SALES_CREDITS B, ASO_QUOTE_HEADERS_ALL C
                       WHERE A.Quote_Header_Id = P_Qte_Header_Rec.Quote_Header_Id
                         AND A.Quote_Header_Id = B.Quote_Header_Id
                         AND A.Quote_Header_Id = C.Quote_Header_Id
                         AND B.Resource_Id = P_Resource_Id
                         AND (B.Quote_Line_Id IS NULL OR B.Quote_Line_Id = A.Quote_Line_Id)
                    GROUP BY A.Quote_Line_Id, B.Resource_Id, A.Inventory_Item_Id,
                             A.Quantity, A.Line_Quote_Price, NVL(A.Currency_Code, C.Currency_Code), A.Line_Category_Code;

	INSERT INTO CN_PROJ_COMPENSATION_GTT (
                             LINE_NUMBER,
                             RESOURCE_ID,
                             PROJECTION_IDENTIFIER,
                             CALC_DATE,
                             SALES_CREDIT_AMOUNT,
                             CURRENCY_CODE)
                      SELECT A.Quote_Line_Id,
                             P_Resource_Id,
                             A.Inventory_Item_Id,
                             SYSDATE,
                             0,
                             NVL(A.Currency_Code, B.Currency_Code)
                        FROM ASO_QUOTE_LINES_ALL A, ASO_QUOTE_HEADERS_ALL B
                       WHERE A.Quote_Header_Id = P_Qte_Header_Rec.Quote_Header_Id
                         AND A.Quote_Header_Id = B.Quote_Header_Id
                         AND A.Quote_Line_Id NOT IN
                             (SELECT C.Line_Number
                                FROM CN_PROJ_COMPENSATION_GTT C);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: Before CN_COMMISSION_CALC_PUB.Calculate_Commission ',1,'N');
aso_utility_pvt.print_login_info();
END IF;
     -- Call CN Calculate Commission
     CN_COMMISSION_CALC_PUB.Calculate_Commission (
                           P_Api_Version     => 1.0,
                           P_Init_Msg_List    => FND_API.G_FALSE,
                           P_Org_Id           => C_Header_Info.Org_Id,
                           X_inc_plnr_disclaimer => lx_inc_plnr_disclaimer,
                           X_Return_Status    => X_Return_Status,
                           X_Msg_Count        => X_Msg_Count,
                           X_Msg_Data         => X_Msg_Data );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: After Calculate_Commission: '||x_return_status,1,'N');
aso_utility_pvt.print_login_info();
END IF;
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
          x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: Before Resetting Line No ',1,'N');
END IF;
      -- Reset UI Line Number
      ASO_LINE_NUM_INT.RESET_LINE_NUM;

      OPEN C_Get_Line_Id (p_qte_header_rec.quote_header_id);
      FETCH C_Get_Line_Id INTO l_In_Line_Number_Tbl(1).Quote_Line_Id;
      CLOSE C_Get_Line_Id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: l_In_Line_Number_Tbl(1).Quote_Line_Id: '||l_In_Line_Number_Tbl(1).Quote_Line_Id,1,'N');
END IF;

      ASO_LINE_NUM_INT.ASO_UI_LINE_NUMBER (
                       P_In_Line_Number_Tbl  => l_In_Line_Number_Tbl,
                       X_Out_Line_Number_Tbl => l_Out_Line_Number_Tbl );


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Calc_Proj_Comm: End ',1,'Y');
END IF;
    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );


END Calculate_Proj_Commission;


END ASO_PROJ_COMM_PVT;

/
