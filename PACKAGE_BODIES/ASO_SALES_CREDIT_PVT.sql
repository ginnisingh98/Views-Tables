--------------------------------------------------------
--  DDL for Package Body ASO_SALES_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SALES_CREDIT_PVT" as
/* $Header: asovscab.pls 120.6 2005/12/16 11:20:57 skulkarn ship $ */
-- Start of Comments
-- Package name     : ASO_SALES_CREDIT_PVT
-- Purpose         :
-- History         :
-- NOTE       :
-- End of Comments


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'ASO_SALES_CREDIT_PVT';
G_USER_ID     NUMBER                := FND_GLOBAL.USER_ID;
G_LOGIN_ID    NUMBER                := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE Allocate_Sales_Credits
(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec         IN   ASO_QUOTE_PUB.SALES_ALLOC_CONTROL_REC_TYPE
                                            :=  ASO_QUOTE_PUB.G_MISS_SALES_ALLOC_CONTROL_REC,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Header_Rec      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS

    l_auto_sales_cred_prof     VARCHAR2(50) := NVL(FND_PROFILE.Value('ASO_AUTO_SALES_CREDIT'),'NONE');
    l_auto_sales_team_prof     VARCHAR2(50) := NVL(FND_PROFILE.Value('ASO_AUTO_TEAM_ASSIGN'),'NONE');

    Leave_Proc                 EXCEPTION;

    l_qte_header_rec           ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_return_status           VARCHAR2(1);
    l_ordered                  VARCHAR2(1) := 'N';
    l_line_exists              VARCHAR2(1) := 'N';
    l_sreps_count              NUMBER := 0;
    l_api_name                 CONSTANT VARCHAR2 ( 30 ) := 'Allocate_Sales_Credits';
    l_api_version_number       CONSTANT NUMBER := 1.0;

    CURSOR C_Check_Qte_Ordered (l_status NUMBER) IS
     SELECT 'Y'
     FROM ASO_QUOTE_STATUSES_B
     WHERE Quote_Status_Id = l_status
     AND Status_Code = 'ORDER SUBMITTED';

    CURSOR C_Check_Qte_Line (l_qte_hdr NUMBER) IS
     SELECT 'Y'
     FROM ASO_QUOTE_LINES_ALL
     WHERE Quote_Header_Id = l_qte_hdr;

    CURSOR C_Get_Sreps_Count (l_qte_num NUMBER) IS
     SELECT Count (Resource_Id)
     FROM ASO_QUOTE_ACCESSES A
     WHERE  A.Quote_Number = l_qte_num
     AND  A.Role_Id IS NOT NULL
     AND  EXISTS
          ( SELECT B.Resource_Id
            /* FROM JTF_RS_SRP_VL B */ --Commented Code Yogeshwar (MOAC)
	    FROM JTF_RS_SALESREPS_MO_V B --New Code Yogeshwar (MOAC)
            WHERE B.Resource_Id = A.Resource_Id
            AND NVL(B.status,'A') = 'A'
            AND nvl(trunc(B.start_date_active), trunc(sysdate)) <= trunc(sysdate)
            AND nvl(trunc(B.end_date_active), trunc(sysdate)) >= trunc(sysdate));
	    --Commented Code Start Yogeshwar (MOAC)
	    /*
            AND NVL(B.org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
                SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
                NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
                SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99));
           */
	   --Commented Code End Yogeshwar (MOAC)


BEGIN

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard Start of API savepoint
      SAVEPOINT ALLOCATE_SALES_CREDITS_PVT;

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
aso_debug_pub.add('Allocate_Sales_Credits: Begin ',1,'Y');
aso_debug_pub.add('Allocate_Sales_Credits: l_auto_sales_cred_prof: '||l_auto_sales_cred_prof,1,'N');
aso_debug_pub.add('Allocate_Sales_Credits: l_auto_sales_team_prof: '||l_auto_sales_team_prof,1,'N');
aso_debug_pub.add('Allocate_Sales_Credits: p_control_rec.submit_quote_flag: '||p_control_rec.submit_quote_flag,1,'N');
aso_debug_pub.add('Allocate_Sales_Credits: p_qte_header_rec.quote_header_id: '||p_qte_header_rec.quote_header_id,1,'N');
aso_debug_pub.add('Allocate_Sales_Credits: p_qte_header_rec.last_update_date: '||p_qte_header_rec.last_update_date,1,'N');
END IF;

     -- Basic Validations
     -- Check is Auto Sales Credit Alloc Prof is valid
     IF l_auto_sales_cred_prof <> 'FULL' AND l_auto_sales_cred_prof <> 'PARTIAL' THEN
         RAISE Leave_Proc;
     END IF;

     -- Check if security profiles are set
     IF (NVL(FND_PROFILE.Value('ASO_API_ENABLE_SECURITY'),'N') = 'N') THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('API_Enable_Sec is N ',1,'Y');
END IF;

         RAISE Leave_Proc;

     END IF;

     IF p_control_rec.submit_quote_flag = FND_API.G_TRUE AND l_auto_sales_cred_prof <> 'FULL' THEN
         RAISE Leave_Proc;
     END IF;

     l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_rec.quote_header_id);

     -- Check Whether record has been changed
     IF (l_qte_header_rec.last_update_date IS NULL OR
         l_qte_header_rec.last_update_date = FND_API.G_MISS_DATE) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
             FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
             FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (p_qte_header_rec.last_update_date IS NOT NULL AND
         p_qte_header_rec.last_update_date <> FND_API.G_MISS_DATE) AND
        (l_qte_header_rec.last_update_date <> p_qte_header_rec.last_update_date) THEN
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

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: l_qte_header_rec.Resource_Id: '||l_qte_header_rec.Resource_Id,1,'N');
aso_debug_pub.add('Allocate_Sales_Credits: l_qte_header_rec.Quote_Status_Id: '||l_qte_header_rec.Quote_Status_Id,1,'N');
aso_debug_pub.add('Allocate_Sales_Credits: l_qte_header_rec.Pricing_Status_Indicator: '||l_qte_header_rec.Pricing_Status_Indicator,1,'N');
END IF;
     -- Check if Primary resource exists in the quote
     IF l_qte_header_rec.Resource_Id IS NULL OR l_qte_header_rec.Resource_Id = FND_API.G_MISS_NUM THEN
         RAISE Leave_Proc;
     END IF;

     -- Check if Quote is ordered
     OPEN C_Check_Qte_Ordered (l_qte_header_rec.Quote_Status_Id);
     FETCH C_Check_Qte_Ordered INTO l_ordered;
     CLOSE C_Check_Qte_Ordered;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: l_ordered: '||l_ordered,1,'N');
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
     IF l_qte_header_rec.Pricing_Status_Indicator IS NOT NULL AND
        l_qte_header_rec.Pricing_Status_Indicator <> 'C' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_PRC_INCOMPLETE');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Check if Atleast one line exists for the quote
     OPEN C_Check_Qte_Line (P_Qte_Header_Rec.Quote_Header_Id);
     FETCH C_Check_Qte_Line INTO l_line_exists;
     CLOSE C_Check_Qte_Line;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: l_line_exists: '||l_line_exists,1,'N');
END IF;
     IF l_line_exists IS NULL OR l_line_exists <> 'Y' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_NO_QUOTE_LINES');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Call Sales Team Assign if required
     IF l_auto_sales_team_prof <> 'FULL' AND l_auto_sales_team_prof <> 'PARTIAL' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_S_TEAM_PROF_NOT_SET');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF P_Control_Rec.Submit_Quote_Flag = FND_API.G_FALSE THEN

         ASO_SALES_TEAM_PVT.Assign_Sales_Team
         (
             P_Init_Msg_List         => FND_API.G_FALSE,
             P_Commit                => FND_API.G_FALSE,
             p_Qte_Header_Rec        => p_qte_header_rec,
             P_Operation             => 'UPDATE',
             x_Qte_Header_Rec        => lx_qte_header_rec,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data
          );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: Assign_Sales_Team:x_return_status: '||x_return_status,1,'N');
END IF;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

     END IF;

     -- Throw error if no valid salesreps were found
     OPEN C_Get_Sreps_Count (l_qte_header_rec.Quote_Number);
     FETCH C_Get_Sreps_Count INTO l_sreps_count;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: l_sreps_count: '||l_sreps_count,1,'N');
END IF;
     IF C_Get_Sreps_Count%NOTFOUND OR l_sreps_count = 0 THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_NO_SALES_CREDIT_RECEIVERS');
              FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Get_Sreps_Count;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: l_sreps_count: '||l_sreps_count,1,'N');
END IF;
     CLOSE C_Get_Sreps_Count;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: Before Get_Credits ',1,'N');
END IF;
     -- Initiate Temp Tables and Call CN API
     ASO_SALES_CREDIT_PVT.Get_Credits
     (
         P_Api_Version_Number    => 1.0,
         P_Init_Msg_List         => FND_API.G_FALSE,
         P_Commit                => FND_API.G_FALSE,
         p_Qte_Header_Rec        => l_qte_header_rec,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
      );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: After Get_Credits:x_return_status: '||x_return_status,1,'N');
END IF;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: Before Update Qte Hdr ',1,'N');
END IF;
     -- Update quote header with the credit_update_date
     UPDATE ASO_QUOTE_HEADERS_ALL
     SET Credit_Update_date = sysdate,
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.conc_login_id,
         object_version_number = object_version_number+1
     WHERE Quote_Header_Id = l_Qte_Header_Rec.Quote_Header_Id
     RETURNING quote_header_id, last_update_date, credit_update_date, object_version_number
     INTO x_qte_header_rec.Quote_Header_Id, x_qte_header_rec.Last_Update_Date,
          x_qte_header_rec.credit_update_date, x_qte_header_rec.object_version_number;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Allocate_Sales_Credits: After Update Qte Hdr ',1,'N');
aso_debug_pub.add('Allocate_Sales_Credits: End ',1,'Y');
END IF;

-- Change START
-- Release 12 TAP Changes
-- Girish Sachdeva 8/30/2005
-- Adding the call to insert record in the ASO_CHANGED_QUOTES

IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('ASO_SALES_CREDIT_PVT.Allocate_Sales_Credits : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_qte_header_rec.Quote_Number, 1, 'Y');
END IF;

-- Call to insert record in ASO_CHANGED_QUOTES
ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_qte_header_rec.Quote_Number);

-- Change END


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    EXCEPTION

        WHEN Leave_Proc THEN
            X_Qte_Header_Rec := P_Qte_Header_Rec;

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


END Allocate_Sales_Credits;


PROCEDURE Get_Credits
(
    P_Api_Version_Number  IN   NUMBER       := 1.0,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2)

IS

    l_cred_upd_lines_prof      VARCHAR2(50) := FND_PROFILE.Value('ASO_SALES_CREDIT_UPDATE');

    l_quota_id                 NUMBER;
    l_non_quota_id             NUMBER;
    l_total_rev                NUMBER := 0;
    l_Line_rev                 NUMBER := 0;
    l_hdr_total                NUMBER;
    l_line_total               NUMBER;
    l_credit_diff              NUMBER;
    l_cred_line_diff           NUMBER;
    l_batch_id                 NUMBER;
    l_PSRep                    NUMBER;
    l_api_name                 CONSTANT VARCHAR2 ( 30 ) := 'Get_Credits';
    l_api_version_number       CONSTANT NUMBER := 1.0;

    CURSOR C_Get_Batch_Id IS
     SELECT CN_SCA_BATCH_S.NextVal
     FROM DUAL;

    CURSOR C_Get_Acct_Info (l_acct_id NUMBER) IS
     SELECT Account_Number
     FROM HZ_CUST_ACCOUNTS
     WHERE Cust_Account_Id = l_acct_id;

    CURSOR C_Get_Party_Info (l_party_id NUMBER) IS
     SELECT Party_Name
     FROM HZ_PARTIES
     WHERE Party_Id = l_party_id;

    CURSOR C_Get_Party_Site_Info (l_party_site NUMBER) IS
     SELECT UPPER(B.city) City, UPPER(B.county) County, UPPER(B.state)State, UPPER(B.province) Province, B.postal_code, B.country
     FROM HZ_PARTY_SITES A, HZ_LOCATIONS B
     WHERE A.Location_Id = B.Location_Id
     AND A.party_site_id = l_party_site;

    CURSOR C_Get_Cust_Cont_Info (l_party_id NUMBER) IS
     SELECT Phone_Area_Code
     FROM HZ_CONTACT_POINTS
     WHERE Owner_Table_Id = l_party_id
     AND Owner_Table_Name = 'HZ_PARTIES'
     AND Contact_Point_Type = 'PHONE'
     AND Status = 'A'
     AND Primary_Flag = 'Y';

    CURSOR C_Get_Quota_Credit_Type IS
     SELECT Sales_Credit_Type_Id
     FROM OE_SALES_CREDIT_TYPES
     WHERE Quota_Flag = 'Y';

    CURSOR C_Get_Non_Quota_Credit_Type IS
     SELECT Sales_Credit_Type_Id
     FROM OE_SALES_CREDIT_TYPES
     WHERE Quota_Flag = 'N';

    CURSOR C_Get_Total_Revenue (l_batch NUMBER) IS
     SELECT SUM (NVL(A.Allocation_Percentage,0))
     FROM CN_SCA_LINES_OUTPUT_GTT A, CN_SCA_HEADERS_INTERFACE_GTT B
     WHERE A.SCA_Batch_Id = l_batch
     AND A.Revenue_Type = 'REVENUE'
     AND B.SCA_Batch_Id = l_batch
     AND B.SCA_Headers_Interface_Id = A.SCA_Headers_Interface_Id
     AND B.Source_Line_Id IS NULL;

    CURSOR C_Get_Line_Revenue (l_batch NUMBER, l_line_id NUMBER) IS
     SELECT SUM (NVL(A.Allocation_Percentage,0))
     FROM CN_SCA_LINES_OUTPUT_GTT A, CN_SCA_HEADERS_INTERFACE_GTT B
     WHERE A.SCA_Batch_Id = l_batch
     AND A.Revenue_Type = 'REVENUE'
     AND B.SCA_Batch_Id = l_batch
     AND B.SCA_Headers_Interface_Id = A.SCA_Headers_Interface_Id
     AND B.Source_Line_Id = l_line_id;

    CURSOR C_Get_Hdr_Total (l_batch NUMBER) IS
     SELECT SUM (NVL(Allocation_Percentage,0))
     FROM CN_SCA_LINES_OUTPUT_GTT A, CN_SCA_HEADERS_INTERFACE_GTT B
     WHERE A.SCA_Batch_Id = l_batch
     AND B.SCA_Batch_Id = l_batch
     AND B.SCA_Headers_Interface_Id = A.SCA_Headers_Interface_Id
     AND B.Source_Line_Id IS NULL;

    CURSOR C_Get_Line_Total (l_batch NUMBER) IS
     SELECT SUM (NVL(Allocation_Percentage,0))
     FROM CN_SCA_LINES_OUTPUT_GTT A, CN_SCA_HEADERS_INTERFACE_GTT B
     WHERE A.SCA_Batch_Id = l_batch
     AND B.SCA_Batch_Id = l_batch
     AND B.SCA_Headers_Interface_Id = A.SCA_Headers_Interface_Id
     AND B.Source_Line_Id IS NOT NULL;

    CURSOR C_PSRep_Credit (l_qte_hdr NUMBER, l_res NUMBER, l_quota NUMBER) IS
     SELECT Resource_Id
     FROM ASO_SALES_CREDITS
     WHERE Resource_Id = l_res
     AND Quote_Header_Id = l_qte_Hdr
     AND Sales_Credit_Type_Id = l_quota
     AND Quote_Line_Id IS NULL;

    CURSOR C_PSRep_Credit_Line (l_qte_hdr NUMBER, l_res NUMBER, l_quota NUMBER, l_qte_line NUMBER) IS
     SELECT Resource_Id
     FROM ASO_SALES_CREDITS
     WHERE Resource_Id = l_res
     AND Quote_Header_Id = l_qte_Hdr
     AND Sales_Credit_Type_Id = l_quota
     AND Quote_Line_Id = l_qte_line;

    CURSOR C_Get_Line (l_qte_hdr NUMBER) IS
     SELECT Quote_Line_Id
     FROM ASO_QUOTE_LINES_ALL
     WHERE Quote_Header_Id = l_qte_hdr;

    CURSOR C_Hd_Inter IS
     SELECT Credit_Rule_Id, Process_Status
     FROM CN_SCA_HEADERS_INTERFACE_GTT;

    C_Acct_Rec              C_Get_Acct_Info%ROWTYPE;
    C_Party_Rec             C_Get_Party_Info%ROWTYPE;
    C_Party_Site_Rec        C_Get_Party_Site_Info%ROWTYPE;
    C_Cust_Cont_Rec         C_Get_Cust_Cont_Info%ROWTYPE;

    l_dumb number := 0;
BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Standard Start of API savepoint
     SAVEPOINT GET_CREDITS_PVT;

     -- Generate sca_batch_id from Sequence
     OPEN C_Get_Batch_Id;
     FETCH C_Get_Batch_Id INTO l_batch_id;
     CLOSE C_Get_Batch_Id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: l_batch_id: '||l_batch_id,1,'N');
aso_debug_pub.add('Get_Credits: l_cred_upd_lines_prof: '||l_cred_upd_lines_prof,1,'N');
aso_debug_pub.add('Get_Credits: p_qte_header_rec.Cust_Account_Id: '||p_qte_header_rec.Cust_Account_Id,1,'N');
aso_debug_pub.add('Get_Credits: p_qte_header_rec.Party_Id: '||p_qte_header_rec.Party_Id,1,'N');
aso_debug_pub.add('Get_Credits: p_qte_header_rec.Cust_Party_Id: '||p_qte_header_rec.Cust_Party_Id,1,'N');
aso_debug_pub.add('Get_Credits: p_qte_header_rec.sold_to_party_site_id: '||p_qte_header_rec.sold_to_party_site_id,1,'N');
aso_debug_pub.add('Get_Credits: attribute1: '||(NVL(p_qte_header_rec.Total_Quote_Price,0) - (NVL(p_qte_header_rec.Total_Tax,0) + NVL(p_qte_header_rec.Total_Shipping_Charge,0))),1,'N');
END IF;

     -- Truncate temp tables
     DELETE FROM CN_SCA_LINES_INTERFACE_GTT;

     DELETE FROM CN_SCA_HEADERS_INTERFACE_GTT;

     DELETE FROM CN_SCA_LINES_OUTPUT_GTT;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After Truncating tables ',1,'N');
END IF;
     -- Get Info to populate attributes
     OPEN C_Get_Acct_Info (p_qte_header_rec.Cust_Account_Id);
     FETCH C_Get_Acct_Info INTO C_Acct_Rec;
     CLOSE C_Get_Acct_Info;

     OPEN C_Get_Party_Info (p_qte_header_rec.Cust_Party_Id);
     FETCH C_Get_Party_Info INTO C_Party_Rec;
     CLOSE C_Get_Party_Info;

     OPEN C_Get_Party_Site_Info (p_qte_header_rec.sold_to_party_site_id);
     FETCH C_Get_Party_Site_Info INTO C_Party_Site_Rec;
     CLOSE C_Get_Party_Site_Info;

     OPEN C_Get_Cust_Cont_Info (p_qte_header_rec.Party_Id);
     FETCH C_Get_Cust_Cont_Info INTO C_Cust_Cont_Rec;
     CLOSE C_Get_Cust_Cont_Info;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: Before insert header info ',1,'N');
aso_debug_pub.add('Get_Credits: C_Party_Site_Rec.Postal_Code: '||C_Party_Site_Rec.Postal_Code,1,'N');
aso_debug_pub.add('Get_Credits: C_Party_Rec.Party_Name: '||C_Party_Rec.Party_Name,1,'N');
aso_debug_pub.add('Get_Credits: C_Cust_Cont_Rec.Phone_Area_Code: '||C_Cust_Cont_Rec.Phone_Area_Code,1,'N');
aso_debug_pub.add('Get_Credits: C_Party_Site_Rec.City: '||C_Party_Site_Rec.City,1,'N');
aso_debug_pub.add('Get_Credits: C_Party_Site_Rec.Country: '||C_Party_Site_Rec.Country,1,'N');
aso_debug_pub.add('Get_Credits: C_Party_Site_Rec.State: '||C_Party_Site_Rec.State,1,'N');
aso_debug_pub.add('Get_Credits: C_Party_Site_Rec.Province: '||C_Party_Site_Rec.Province,1,'N');
aso_debug_pub.add('Get_Credits: C_Party_Site_Rec.County: '||C_Party_Site_Rec.County,1,'N');
aso_debug_pub.add('Get_Credits: p_qte_header_rec.Marketing_Source_Code_Id: '||p_qte_header_rec.Marketing_Source_Code_Id,1,'N');
aso_debug_pub.add('Get_Credits: p_qte_header_rec.Sales_Channel_Code: '||p_qte_header_rec.Sales_Channel_Code,1,'N');
END IF;
     -- Populate CN_SCA_HEADERS_INTERFACE_GTT with header info
     INSERT INTO CN_SCA_HEADERS_INTERFACE_GTT (
                         SCA_HEADERS_INTERFACE_ID,
                         SCA_BATCH_ID,
                         TRANSACTION_SOURCE,
                         SOURCE_TYPE,
                         SOURCE_ID,
                         SOURCE_LINE_ID,
                         PROCESSED_DATE,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         ATTRIBUTE16,
                         ATTRIBUTE17,
                         ATTRIBUTE18,
                         ATTRIBUTE19,
                         ATTRIBUTE20,
                         ATTRIBUTE21,
                         ATTRIBUTE22,
                         ATTRIBUTE23,
                         ATTRIBUTE24 )
                  VALUES ( CN_SCA_HEADERS_INTERFACE_GTT_S.NextVal,
                         l_batch_id,
                         'QOT',
                         NULL,
                         p_qte_header_rec.Quote_Header_Id,
                         NULL,
                         SYSDATE,
                         (NVL(p_qte_header_rec.Total_Quote_Price,0) - (NVL(p_qte_header_rec.Total_Tax,0) + NVL(p_qte_header_rec.Total_Shipping_Charge,0))),
                         p_qte_header_rec.Total_List_Price,
                         p_qte_header_rec.Total_Quote_Price,
                         p_qte_header_rec.Total_Adjusted_Amount,
                         p_qte_header_rec.Total_Adjusted_Percent,
                         C_Acct_Rec.Account_Number,
                         C_Party_Rec.Party_Name,
                         C_Cust_Cont_Rec.Phone_Area_Code,
                         C_Party_Site_Rec.City,
                         C_Party_Site_Rec.Country,
                         C_Party_Site_Rec.State,
                         C_Party_Site_Rec.Province,
                         C_Party_Site_Rec.County,
                         C_Party_Site_Rec.Postal_Code,
                         p_qte_header_rec.Marketing_Source_Code_Id,
                         p_qte_header_rec.Sales_Channel_Code );

     IF l_cred_upd_lines_prof = 'Y' THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: Before insert line info ',1,'N');
END IF;
       -- Populate CN_SCA_HEADERS_INTERFACE_GTT with lines info
       INSERT INTO CN_SCA_HEADERS_INTERFACE_GTT (
                         SCA_HEADERS_INTERFACE_ID,
                         SCA_BATCH_ID,
                         TRANSACTION_SOURCE,
                         SOURCE_TYPE,
                         SOURCE_ID,
                         SOURCE_LINE_ID,
                         PROCESSED_DATE,
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
                         ATTRIBUTE16,
                         ATTRIBUTE17,
                         ATTRIBUTE18,
                         ATTRIBUTE19,
                         ATTRIBUTE20,
                         ATTRIBUTE21,
                         ATTRIBUTE22,
                         ATTRIBUTE23,
                         ATTRIBUTE24 )
                  SELECT CN_SCA_HEADERS_INTERFACE_GTT_S.NextVal,
                         l_batch_id,
                         'QOT',
                         NULL,
                         p_qte_header_rec.Quote_Header_Id,
                         A.Quote_Line_Id,
                         SYSDATE,
                         (A.Line_Quote_Price * A.Quantity),
                         A.Line_List_Price,
                         A.Line_Quote_Price,
                         A.Line_Adjusted_Amount,
                         A.Line_Adjusted_Percent,
                         A.Quantity,
                         A.UOM_Code,
                         A.Inventory_Item_Id,
                         C_Acct_Rec.Account_Number,
                         C_Party_Rec.Party_Name,
                         C_Cust_Cont_Rec.Phone_Area_Code,
                         C_Party_Site_Rec.City,
                         C_Party_Site_Rec.Country,
                         C_Party_Site_Rec.State,
                         C_Party_Site_Rec.Province,
                         C_Party_Site_Rec.County,
                         C_Party_Site_Rec.Postal_Code,
                         p_qte_header_rec.Marketing_Source_Code_Id,
                         p_qte_header_rec.Sales_Channel_Code
                   FROM  ASO_QUOTE_LINES_ALL A
                   WHERE Quote_Header_Id = p_qte_header_rec.Quote_Header_Id;

     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: Before insert line interface tbl ',1,'N');
END IF;
     -- Populate CN_SCA_LINES_INTERFACE_GTT
     INSERT INTO CN_SCA_LINES_INTERFACE_GTT (
                        SCA_LINES_INTERFACE_ID,
                        SCA_HEADERS_INTERFACE_ID,
                        SCA_BATCH_ID,
                        RESOURCE_ID,
                        ROLE_ID,
                        SOURCE_TRX_ID )
                SELECT  CN_SCA_LINES_INTERFACE_GTT_S.NextVal,
                        B.SCA_Headers_Interface_Id,
                        l_batch_id,
                        A.Resource_Id,
                        A.Role_Id,
                        p_qte_header_rec.quote_header_id
                  FROM  ASO_QUOTE_ACCESSES A, CN_SCA_HEADERS_INTERFACE_GTT B
                 WHERE  A.Quote_Number = p_qte_header_rec.Quote_Number
                   AND  A.Role_Id IS NOT NULL
                   AND  EXISTS
                          ( SELECT C.Resource_Id
                            /* FROM JTF_RS_SRP_VL C */ --Commented Code Yogeshwar (MOAC)
			    FROM JTF_RS_SALESREPS_MO_V C  --New Code yogeshwar (MOAC)
                            WHERE C.Resource_Id = A.Resource_Id
                            AND NVL(status,'A') = 'A'
                            AND nvl(trunc(C.start_date_active), trunc(sysdate)) <= trunc(sysdate)
                            AND nvl(trunc(C.end_date_active), trunc(sysdate)) >= trunc(sysdate));
			    --Commented Code Start Yogeshwar (MOAC)
			    /*
                            AND NVL(C.org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
                                SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
                                NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
                                SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99));
                            */
			    --Commented Code End Yogeshwar (MOAC)

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into l_dumb from CN_SCA_HEADERS_INTERFACE_GTT;
aso_debug_pub.add('Get_Credits: l_headers: '||l_dumb,1,'N');
IF l_dumb > 0 THEN
FOR C_Hd_Rec IN C_Hd_Inter LOOP
aso_debug_pub.add('Get_Credits: tmp credit_rule_id: '||C_Hd_Rec.credit_rule_id,1,'N');
aso_debug_pub.add('Get_Credits: tmp process_status: '||C_Hd_Rec.process_status,1,'N');
END LOOP;
END IF;
select count(*) into l_dumb from CN_SCA_LINES_INTERFACE_GTT;
aso_debug_pub.add('Get_Credits: l_lines: '||l_dumb,1,'N');
END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: Before CN_SCA_CREDITS_ONLINE_PUB.Get_Sales_Credits ',1,'N');
aso_utility_pvt.print_login_info();
END IF;
     -- Call CN API to get sales credits
     CN_SCA_CREDITS_ONLINE_PUB.Get_Sales_Credits (
                         p_api_version         =>  1.0,
                         p_init_msg_list       =>  FND_API.G_FALSE,
                         x_batch_id            =>  l_batch_id,
					p_org_id              =>  p_qte_header_rec.org_id,
                         x_return_status       =>  x_return_status,
                         x_msg_count           =>  x_msg_count,
                         x_msg_data            =>  x_msg_data );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After CN_SCA_CREDITS_ONLINE_PUB.Get_Sales_Credits: '||x_return_status,1,'N');
aso_utility_pvt.print_login_info();
END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
select count(*) into l_dumb from CN_SCA_LINES_OUTPUT_GTT;
aso_debug_pub.add('Get_Credits: l_dumb: '||l_dumb,1,'N');
END IF;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Call Get Sales Credit Type for quota and non quota
      OPEN C_Get_Quota_Credit_Type;
      FETCH C_Get_Quota_Credit_Type INTO l_quota_id;
      CLOSE C_Get_Quota_Credit_Type;

      OPEN C_Get_Non_Quota_Credit_Type;
      FETCH C_Get_Non_Quota_Credit_Type INTO l_non_quota_id;
      CLOSE C_Get_Non_Quota_Credit_Type;

      OPEN C_Get_Total_Revenue (l_batch_id);
      FETCH C_Get_Total_Revenue INTO l_total_rev;
      CLOSE C_Get_Total_Revenue;

      OPEN C_Get_Hdr_Total (l_batch_id);
      FETCH C_Get_Hdr_Total INTO l_hdr_total;
      CLOSE C_Get_Hdr_Total;

      OPEN C_Get_Line_Total (l_batch_id);
      FETCH C_Get_Line_Total INTO l_line_total;
      CLOSE C_Get_Line_Total;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: l_quota_id: '||l_quota_id,1,'N');
aso_debug_pub.add('Get_Credits: l_non_quota_id: '||l_non_quota_id,1,'N');
aso_debug_pub.add('Get_Credits: l_total_rev: '||l_total_rev,1,'N');
aso_debug_pub.add('Get_Credits: l_hdr_total: '||l_hdr_total,1,'N');
aso_debug_pub.add('Get_Credits: l_line_total: '||l_line_total,1,'N');
END IF;

      -- Check if atleast some credit has been allocated
      IF (l_hdr_total IS NULL OR l_hdr_total < 1) AND
         (l_line_total IS NULL OR l_line_total < 1) THEN
--          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_NO_CREDIT_ALLOCATED');
              FND_MSG_PUB.ADD;
          END IF;
--          RAISE FND_API.G_EXC_ERROR;
      END IF;

    IF l_hdr_total IS NOT NULL AND l_hdr_total > 0 THEN

      -- Save credit diff if below 100, else diff is 0
      l_credit_diff := 100 - l_total_rev;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: l_credit_diff: '||l_credit_diff,1,'N');
END IF;
      -- Delete existing credits for the quote
      ASO_SALES_CREDITS_PKG.Delete_Header_Row ( P_Quote_Header_Id  => p_Qte_Header_Rec.Quote_Header_Id );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After Delete_Row ',1,'N');
END IF;
      -- Insert new credits for this quote
      INSERT INTO ASO_SALES_CREDITS (
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           SALES_CREDIT_ID,
           QUOTE_HEADER_ID,
           QUOTE_LINE_ID,
           PERCENT,
           RESOURCE_ID,
           RESOURCE_GROUP_ID,
           SALES_CREDIT_TYPE_ID,
           SYSTEM_ASSIGNED_FLAG,
           CREDIT_RULE_ID )
    SELECT SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           ASO_SALES_CREDITS_S.nextval,
           B.Source_Id,
           B.Source_Line_Id,
           A.Allocation_Percentage,
           A.Resource_Id,
           C.Resource_Grp_Id,
           Decode(A.Revenue_Type, 'REVENUE', l_quota_id,l_non_quota_id),
           'Y',
           B.Credit_Rule_Id
     FROM  CN_SCA_LINES_OUTPUT_GTT A,
           CN_SCA_HEADERS_INTERFACE_GTT B,
           ASO_QUOTE_ACCESSES C
     WHERE A.SCA_Batch_Id = l_batch_id
       AND B.SCA_Batch_Id = l_batch_id
       AND B.SCA_Headers_Interface_Id = A.SCA_Headers_Interface_Id
       AND A.Resource_Id = C.Resource_Id
       AND C.Quote_Number = p_qte_header_rec.Quote_Number
       AND B.Source_Line_Id IS NULL;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After Insert_Row to ASO_SALES_CREDITS ',1,'N');
END IF;
     -- Update the primary salesrep percent in aso_sales_credits
     IF l_credit_diff > 0 THEN
         OPEN C_PSRep_Credit (p_Qte_Header_Rec.Quote_Header_Id, p_Qte_Header_Rec.Resource_Id, l_quota_id);
         FETCH C_PSRep_Credit INTO l_PSRep;
         CLOSE C_PSRep_Credit;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: l_PSRep '||l_PSRep,1,'N');
END IF;
         IF l_PSRep IS NOT NULL THEN

             UPDATE ASO_SALES_CREDITS
             SET Percent = Percent + l_credit_diff
             WHERE Resource_Id = l_PSRep
             AND Sales_Credit_Type_Id = l_quota_id
             AND Quote_Header_Id = p_Qte_Header_Rec.Quote_Header_Id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After Update to ASO_SALES_CREDITS PSRep ',1,'N');
END IF;
          ELSE

             INSERT INTO ASO_SALES_CREDITS (
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                SALES_CREDIT_ID,
                QUOTE_HEADER_ID,
                QUOTE_LINE_ID,
                PERCENT,
                RESOURCE_ID,
                RESOURCE_GROUP_ID,
                SALES_CREDIT_TYPE_ID,
                SYSTEM_ASSIGNED_FLAG,
                CREDIT_RULE_ID )
             SELECT SYSDATE,
                G_USER_ID,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                ASO_SALES_CREDITS_S.nextval,
                p_Qte_Header_Rec.Quote_Header_Id,
                NULL,
                l_credit_diff,
                A.Resource_Id,
                A.Resource_Grp_Id,
                l_quota_id,
                'Y',
                NULL
             FROM  ASO_QUOTE_ACCESSES A
             WHERE A.Resource_Id = p_Qte_Header_Rec.Resource_Id
               AND A.Quote_Number = p_qte_header_rec.Quote_Number;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After Insert to ASO_SALES_CREDITS PSRep ',1,'N');
END IF;
          END IF; -- l_PSRep

     END IF; -- l_credit_diff

   END IF; -- l_hdr_total


     IF (l_cred_upd_lines_prof = 'Y') AND (l_line_total IS NOT NULL AND l_line_total > 0) THEN

         FOR C_Get_Line_Rec IN C_Get_Line (p_qte_header_rec.Quote_Header_Id) LOOP

             OPEN C_Get_Line_Revenue (l_batch_id, C_Get_Line_Rec.Quote_Line_Id);
             FETCH C_Get_Line_Revenue INTO l_line_rev;
             CLOSE C_Get_Line_Revenue;

             l_cred_line_diff := 100 - l_line_rev;

             -- Delete existing credits for the quote
             ASO_SALES_CREDITS_PKG.Delete_Row ( P_Quote_Line_Id  => C_Get_Line_Rec.Quote_Line_Id );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After Delete_Row ',1,'N');
END IF;
             -- Insert new credits for this quote
             INSERT INTO ASO_SALES_CREDITS (
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  SALES_CREDIT_ID,
                  QUOTE_HEADER_ID,
                  QUOTE_LINE_ID,
                  PERCENT,
                  RESOURCE_ID,
                  RESOURCE_GROUP_ID,
                  SALES_CREDIT_TYPE_ID,
                  SYSTEM_ASSIGNED_FLAG,
                  CREDIT_RULE_ID )
           SELECT SYSDATE,
                  G_USER_ID,
                  G_USER_ID,
                  SYSDATE,
                  G_LOGIN_ID,
                  ASO_SALES_CREDITS_S.nextval,
                  B.Source_Id,
                  B.Source_Line_Id,
                  A.Allocation_Percentage,
                  A.Resource_Id,
                  C.Resource_Grp_Id,
                  Decode(A.Revenue_Type, 'REVENUE', l_quota_id,l_non_quota_id),
                  'Y',
                  B.Credit_Rule_Id
            FROM  CN_SCA_LINES_OUTPUT_GTT A,
                  CN_SCA_HEADERS_INTERFACE_GTT B,
                  ASO_QUOTE_ACCESSES C
            WHERE A.SCA_Batch_Id = l_batch_id
              AND B.SCA_Batch_Id = l_batch_id
              AND B.SCA_Headers_Interface_Id = A.SCA_Headers_Interface_Id
              AND A.Resource_Id = C.Resource_Id
              AND C.Quote_Number = p_qte_header_rec.Quote_Number
              AND B.Source_Line_Id = C_Get_Line_Rec.Quote_Line_Id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Get_Credits: After Insert_Row to ASO_SALES_CREDITS ',1,'N');
END IF;
           -- Update the primary salesrep percent in aso_sales_credits
           IF l_cred_line_diff > 0 THEN

               l_PSRep := NULL;

               OPEN C_PSRep_Credit_Line (p_Qte_Header_Rec.Quote_Header_Id, p_Qte_Header_Rec.Resource_Id,
                                         l_quota_id, C_Get_Line_Rec.Quote_Line_Id);
               FETCH C_PSRep_Credit_Line INTO l_PSRep;
               CLOSE C_PSRep_Credit_Line;

               IF l_PSRep IS NOT NULL THEN

                   UPDATE ASO_SALES_CREDITS
                   SET Percent = Percent + l_credit_diff
                   WHERE Resource_Id = l_PSRep
                   AND Sales_Credit_Type_Id = l_quota_id
                   AND Quote_Header_Id = p_Qte_Header_Rec.Quote_Header_Id
                   AND Quote_Line_Id = C_Get_Line_Rec.Quote_Line_Id;

                ELSE

                   INSERT INTO ASO_SALES_CREDITS (
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATE_LOGIN,
                      SALES_CREDIT_ID,
                      QUOTE_HEADER_ID,
                      QUOTE_LINE_ID,
                      PERCENT,
                      RESOURCE_ID,
                      RESOURCE_GROUP_ID,
                      SALES_CREDIT_TYPE_ID,
                      SYSTEM_ASSIGNED_FLAG,
                      CREDIT_RULE_ID )
                   SELECT SYSDATE,
                      G_USER_ID,
                      G_USER_ID,
                      SYSDATE,
                      G_LOGIN_ID,
                      ASO_SALES_CREDITS_S.nextval,
                      p_Qte_Header_Rec.Quote_Header_Id,
                      C_Get_Line_Rec.Quote_Line_Id,
                      l_cred_line_diff,
                      A.Resource_Id,
                      A.Resource_Grp_Id,
                      l_quota_id,
                      'Y',
                      NULL
                   FROM  ASO_QUOTE_ACCESSES A
                   WHERE A.Resource_Id = p_Qte_Header_Rec.Resource_Id
                     AND A.Quote_Number = p_qte_header_rec.Quote_Number;

                END IF; -- l_PSRep

            END IF; -- l_credit_line_diff

         END LOOP;

     END IF; -- credit_upd_prof or l_line_total

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

END Get_Credits;


END ASO_SALES_CREDIT_PVT;

/
