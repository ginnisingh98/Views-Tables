--------------------------------------------------------
--  DDL for Package Body ASO_CHECK_TCA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CHECK_TCA_PVT" as
/* $Header: asovctcb.pls 120.13.12010000.10 2012/06/28 05:42:58 vidsrini ship $ */
-- Start of Comments
-- Package name     : ASO_CHECK_TCA_PVT
-- Purpose         :
-- History         :
-- NOTE       :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_CHECK_TCA_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovctcb.pls';

PROCEDURE check_tca(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
    P_Qte_Rec             IN OUT NOCOPY    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Header_Shipment_Tbl IN OUT NOCOPY    ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Operation_Code      IN  VARCHAR2  := FND_API.G_MISS_CHAR,
    p_application_type_code IN  VARCHAR2  := FND_API.G_MISS_CHAR,
    x_return_status		 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
    x_msg_count		 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
    x_msg_data		      OUT NOCOPY /* file.sql.39 change */  	VARCHAR2
)
IS

    CURSOR C_Get_Party_From_Acct(acct_id NUMBER) IS
     SELECT party_id
     FROM HZ_CUST_ACCOUNTS
     WHERE cust_account_id = acct_id
     AND status = 'A'
     AND sysdate BETWEEN NVL(account_activation_date, sysdate) AND NVL(account_termination_date, sysdate);

    CURSOR C_Party_Type(pty_id NUMBER) IS
     SELECT party_type
     FROM HZ_PARTIES
     WHERE party_id = pty_id;

    CURSOR C_Get_Cust_Party(pty_id NUMBER) IS
     SELECT object_id
     FROM HZ_RELATIONSHIPS
     WHERE party_id = pty_id
     AND object_type = 'ORGANIZATION'
	AND object_table_name = 'HZ_PARTIES';

    l_api_version       CONSTANT NUMBER       := 1.0;
    l_api_name          CONSTANT VARCHAR2(45) := 'Check_tca';
    l_org_contact           NUMBER;
    l_org_contact_party_id  NUMBER;
    l_sold_to_contact_id    NUMBER;
    lx_cust_account_id      NUMBER;
    l_party_type            VARCHAR2(30);

	l_qte_header_rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
     l_shipment_rec          ASO_QUOTE_PUB.shipment_rec_type  := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;

BEGIN

  SAVEPOINT CHECK_TCA_PVT;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Tca: begin', 1, 'N');
aso_debug_pub.add('Check_Tca: p_qte_rec.party_id: '||p_qte_rec.party_id, 1, 'N');
aso_debug_pub.add('Check_Tca: p_qte_rec.cust_party_id: '||p_qte_rec.cust_party_id, 1, 'N');
aso_debug_pub.add('Check_Tca: p_qte_rec.cust_account_id: '||p_qte_rec.cust_account_id, 1, 'N');
END IF;

    IF (p_application_type_code = 'QUOTING HTML' AND p_operation_code = 'UPDATE') THEN
      l_qte_header_rec := ASO_UTILITY_PVT.query_header_row (p_qte_rec.quote_header_id);

      IF p_qte_rec.party_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.cust_party_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.cust_account_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.sold_to_party_site_id <> FND_API.G_MISS_NUM AND
         p_qte_rec.org_contact_id <> FND_API.G_MISS_NUM THEN

        IF p_qte_rec.party_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.party_id := l_qte_header_rec.party_id;
        END IF;
        IF p_qte_rec.cust_party_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.cust_party_id := l_qte_header_rec.cust_party_id;
        END IF;
        IF p_qte_rec.cust_account_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.cust_account_id := l_qte_header_rec.cust_account_id;
        END IF;
        IF p_qte_rec.sold_to_party_site_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.sold_to_party_site_id := l_qte_header_rec.sold_to_party_site_id;
        END IF;

        IF p_qte_rec.org_contact_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.org_contact_id := l_qte_header_rec.org_contact_id;
        END IF;

      END IF;

      IF p_qte_rec.invoice_to_party_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.invoice_to_cust_party_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.invoice_to_cust_account_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM THEN

        IF p_qte_rec.invoice_to_party_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.invoice_to_party_id := l_qte_header_rec.invoice_to_party_id;
        END IF;
        IF p_qte_rec.invoice_to_cust_party_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.invoice_to_cust_party_id := l_qte_header_rec.invoice_to_cust_party_id;
        END IF;
        IF p_qte_rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.invoice_to_cust_account_id := l_qte_header_rec.invoice_to_cust_account_id;
        END IF;
        IF p_qte_rec.invoice_to_party_site_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.invoice_to_party_site_id := l_qte_header_rec.invoice_to_party_site_id;
        END IF;
      END IF;

      IF p_qte_rec.End_Customer_party_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.End_Customer_cust_party_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.End_Customer_cust_account_id <> FND_API.G_MISS_NUM OR
         p_qte_rec.End_Customer_party_site_id <> FND_API.G_MISS_NUM THEN

        IF p_qte_rec.End_Customer_party_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.End_Customer_party_id := l_qte_header_rec.End_Customer_party_id;
        END IF;
        IF p_qte_rec.End_Customer_cust_party_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.End_Customer_cust_party_id := l_qte_header_rec.End_Customer_cust_party_id;
        END IF;
        IF p_qte_rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.End_Customer_cust_account_id := l_qte_header_rec.End_Customer_cust_account_id;
        END IF;
        IF p_qte_rec.End_Customer_party_site_id = FND_API.G_MISS_NUM THEN
          p_qte_rec.End_Customer_party_site_id := l_qte_header_rec.End_Customer_party_site_id;
        END IF;
      END IF;

      IF P_Header_Shipment_Tbl.count > 0 THEN
       IF P_Header_Shipment_Tbl(1).operation_code = 'UPDATE' AND
          (P_Header_Shipment_Tbl(1).shipment_id IS NOT NULL AND P_Header_Shipment_Tbl(1).shipment_id <> FND_API.G_MISS_NUM) THEN
         IF P_Header_Shipment_Tbl(1).ship_to_party_id <> FND_API.G_MISS_NUM OR
           P_Header_Shipment_Tbl(1).ship_to_cust_party_id <> FND_API.G_MISS_NUM OR
           P_Header_Shipment_Tbl(1).ship_to_cust_account_id <> FND_API.G_MISS_NUM OR
           P_Header_Shipment_Tbl(1).ship_to_party_site_id <> FND_API.G_MISS_NUM THEN

           l_shipment_rec := ASO_UTILITY_PVT.query_shipment_row (P_Header_Shipment_Tbl(1).shipment_id);
           IF P_Header_Shipment_Tbl(1).ship_to_cust_party_id = FND_API.G_MISS_NUM THEN
             P_Header_Shipment_Tbl(1).ship_to_cust_party_id := l_shipment_rec.ship_to_cust_party_id;
           END IF;
           IF P_Header_Shipment_Tbl(1).ship_to_cust_account_id = FND_API.G_MISS_NUM THEN
             P_Header_Shipment_Tbl(1).ship_to_cust_account_id := l_shipment_rec.ship_to_cust_account_id;
           END IF;
           IF P_Header_Shipment_Tbl(1).ship_to_party_id = FND_API.G_MISS_NUM THEN
             P_Header_Shipment_Tbl(1).ship_to_party_id := l_shipment_rec.ship_to_party_id;
           END IF;
           IF P_Header_Shipment_Tbl(1).ship_to_party_site_id = FND_API.G_MISS_NUM THEN
             P_Header_Shipment_Tbl(1).ship_to_party_site_id := l_shipment_rec.ship_to_party_site_id;
           END IF;
         END IF;
  	  END IF;
     END IF;

    END IF; -- UPDATE

   IF p_qte_rec.party_id IS NULL OR p_qte_rec.party_id = FND_API.G_MISS_NUM THEN

       IF p_qte_rec.cust_party_id IS NOT NULL AND p_qte_rec.cust_party_id <> FND_API.G_MISS_NUM THEN

           p_qte_rec.party_id := p_qte_rec.cust_party_id;

       ELSIF p_qte_rec.cust_account_id IS NOT NULL AND p_qte_rec.cust_account_id <> FND_API.G_MISS_NUM THEN

            OPEN C_Get_Party_From_Acct(p_qte_rec.cust_account_id);
            FETCH C_Get_Party_From_Acct INTO p_qte_rec.party_id;
            IF C_Get_Party_From_Acct%NOTFOUND THEN
                x_Return_Status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'CUST_ACCOUNT_ID', FALSE);
                    FND_MESSAGE.Set_Token('VALUE', to_char(p_qte_rec.cust_account_id), FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE C_Get_Party_From_Acct;
                raise FND_API.G_EXC_ERROR;
            END IF;
            CLOSE C_Get_Party_From_Acct;

       END IF;

   END IF;  -- party_id is null

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Tca: p_qte_rec.party_id: '||p_qte_rec.party_id, 1, 'N');
END IF;

   IF p_qte_rec.party_id IS NOT NULL AND p_qte_rec.party_id <> FND_API.G_MISS_NUM THEN

       IF p_qte_rec.cust_party_id IS NULL OR p_qte_rec.cust_party_id = FND_API.G_MISS_NUM THEN

           OPEN C_Party_Type(p_qte_rec.party_id);
           FETCH C_Party_Type INTO l_party_type;
           CLOSE C_Party_Type;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Tca: l_party_type: '||l_party_type, 1, 'N');
END IF;

           IF l_party_type = 'PERSON' OR l_party_type = 'ORGANIZATION' THEN

               p_qte_rec.cust_party_id := p_qte_rec.party_id;

           ELSIF l_party_type = 'PARTY_RELATIONSHIP' THEN

               OPEN C_Get_Cust_Party(p_qte_rec.party_id);
               FETCH C_Get_Cust_Party INTO p_qte_rec.cust_party_id;
               CLOSE C_Get_Cust_Party;

           END IF;

       END IF;  -- cust_party_id

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Tca: p_qte_rec.cust_party_id: '||p_qte_rec.cust_party_id, 1, 'N');
END IF;

       IF p_qte_rec.cust_account_id IS NULL OR p_qte_rec.cust_account_id = FND_API.G_MISS_NUM THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Tca: before customer account:p_qte_rec.party_id '||p_qte_rec.party_id, 1, 'N');
END IF;

            Customer_Account(
                p_api_version       => 1.0,
                p_Party_Id          => p_qte_rec.cust_party_id,
			 p_calling_api_flag  => 0,
                x_Cust_Acct_Id      => p_qte_rec.cust_account_id,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Tca: after customer account:x_Return_Status '||x_Return_Status, 1, 'N');
END IF;
            IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
            END IF;

       END IF;  -- cust_account_id

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Tca: p_qte_rec.cust_account_id: '||p_qte_rec.cust_account_id, 1, 'N');
END IF;

   END IF;  -- party_id is not null

   lx_cust_account_id := p_qte_rec.cust_account_id;

  IF lx_cust_account_id IS NOT NULL AND lx_cust_account_id <> FND_API.G_MISS_NUM THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('before org contact', 1, 'N');
    END IF;
    IF p_qte_rec.party_id is not null and
	    p_qte_rec.party_id <> FND_API.G_MISS_NUM THEN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('before org contact:p_qte_rec.org_contact_id: '||p_qte_rec.org_contact_id, 1, 'N');
    END IF;
        IF p_qte_rec.org_contact_id is NULL OR
		    p_qte_rec.org_contact_id = FND_API.G_MISS_NUM THEN
            ASO_MAP_QUOTE_ORDER_INT.get_org_contact(p_party_id => p_qte_rec.party_id,
				            x_org_contact => l_org_contact);
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('after org contact:l_org_contact: '||l_org_contact, 1, 'N');
    END IF;
        ELSE
            l_org_contact := p_qte_rec.org_contact_id;
        END IF;
        IF l_org_contact is not NULL AND l_org_contact <> FND_API.G_MISS_NUM THEN
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('deriving org_contact_role:l_org_contact: ' || l_org_contact,1, 'N');
		  END IF;
            ASO_MAP_QUOTE_ORDER_INT.get_org_contact_role(
                p_Org_Contact_Id   => l_org_contact
                ,p_Cust_account_id  => lx_cust_account_id
                ,x_return_status    => x_return_status
                ,x_party_id         => l_org_contact_party_id
                ,x_cust_account_role_id => l_sold_to_contact_id
                );
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('after get org contact. l_org_contact_party_id = ' || l_org_contact_party_id ,1, 'N');
             aso_debug_pub.add('after get org contact. sold_to_contact_id = ' || l_sold_to_contact_id ,1, 'N');
		   END IF;
              if p_qte_rec.org_contact_id is not null and p_qte_rec.org_contact_id <> FND_API.G_MISS_NUM then
                p_qte_rec.party_id := l_org_contact_party_id;
              end if;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_ORG_CON_ACT_CRS');
                    -- FND_MESSAGE.Set_Token('ID', to_char(p_qte_rec.org_contact_id),FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
                raise FND_API.G_EXC_ERROR;
            END IF;
            IF l_sold_to_contact_id is NULL OR
                l_sold_to_contact_id = FND_API.G_MISS_NUM THEN
			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('calling create contact role for org contact ',1, 'N');
			 END IF;
                ASO_PARTY_INT.Create_Contact_Role (
  		            p_api_version       => 1.0
                    ,p_party_id         =>l_org_contact_party_id
         		    ,p_Cust_account_id  =>  lx_cust_account_id
 	                ,x_return_status    => x_return_status
		            ,x_msg_count        => x_msg_count
 		            ,x_msg_data         => x_msg_data
 		            ,x_cust_account_role_id  => l_sold_to_contact_id
  	            );
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('after create contact role. sold_to_contact_id = ' || l_sold_to_contact_id ,1, 'N');
                aso_debug_pub.add('after create contact role. x_return_status = ' || x_return_status ,1, 'N');
			 END IF;
                IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_ORG_CONTACT');
                        FND_MESSAGE.Set_Token('ID', to_char(p_qte_rec.party_id), FALSE);
                       FND_MSG_PUB.ADD;
                    END IF;
                    raise FND_API.G_EXC_ERROR;
                END IF;
            END IF;

        END IF;

    END IF;

  END IF; -- lx_cust_account not null

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before check hdr info ',1, 'N');
END IF;
    check_header_account_info(
        p_api_version         => 1.0,
        p_init_msg_list       => p_init_msg_list,
        p_cust_account_id     => lx_cust_account_id,
        p_qte_rec             => p_qte_rec,
        p_header_shipment_tbl => p_header_shipment_tbl,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after check hdr info:x_return_status: '||x_return_status,1, 'N');
END IF;
    IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END check_tca;


PROCEDURE check_header_account_info(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
    p_cust_account_id     IN  NUMBER,
    P_Qte_Rec             IN OUT NOCOPY  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Header_Shipment_Tbl IN OUT NOCOPY    ASO_QUOTE_PUB.Shipment_Tbl_Type,
    x_return_status		 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
    x_msg_count		 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
    x_msg_data		      OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

   CURSOR get_cust_acct_site_id(l_site_use_id number) IS
     select cust_acct_site_id from hz_cust_site_uses
     where site_use_id = l_site_use_id;

   CURSOR C_Site_Use(l_sold_to_party_site NUMBER) IS
     SELECT party_site_use_id
     FROM hz_party_site_uses
     WHERE party_site_id = l_sold_to_party_site
     AND site_use_type = 'SOLD_TO';

   CURSOR c_get_cust_account_id IS
     SELECT invoice_to_cust_account_id
	FROM   aso_quote_headers_all
	WHERE  Quote_header_id = P_Qte_Rec.quote_header_id;


    l_api_version       CONSTANT NUMBER       := 1.0;
    l_api_name          CONSTANT VARCHAR2(45) := 'Check_Header_Account_Info';
    l_site_use_id               NUMBER;
    l_invoice_cust_account_id   NUMBER;
    l_End_cust_account_id   NUMBER;
    l_invoice_contact_party_id  NUMBER;
    l_invoice_to_contact_id     NUMBER;
    l_End_Customer_contact_id   NUMBER;
    l_ship_cust_account_id      NUMBER;
    l_invoice_cust_account_site NUMBER;
    l_ship_contact_party_id     NUMBER;
    l_ship_to_contact_id        NUMBER;
    l_ship_cust_account_site    NUMBER;
    l_invoice_to_org_id		  NUMBER;
    l_End_Customer_org_id	  NUMBER;
    l_ship_to_org_id            NUMBER;
    l_invoice_to_party_id       NUMBER;
    l_ship_to_party_id          NUMBER;

    l_party_site_use_id         NUMBER;
    l_inv_cust_acct_site_id	  NUMBER;
    l_end_cust_acct_site_id	  NUMBER;
    l_shp_cust_acct_site_id	  NUMBER;

BEGIN

  SAVEPOINT CHECK_HEADER_ACCOUNT_INFO_PVT;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Hdr_Acct: begin ', 1, 'Y');
aso_debug_pub.add('Check_Hdr_Acct: before sold to party site id '|| p_qte_rec.sold_to_party_site_id, 1, 'N');
aso_debug_pub.add('Check_Hdr_Acct: p_qte_rec.invoice_to_cust_account_id: '|| p_qte_rec.invoice_to_cust_account_id, 1, 'N');
aso_debug_pub.add('Check_Hdr_Acct: p_qte_rec.invoice_to_cust_party_id: '|| p_qte_rec.invoice_to_cust_party_id, 1, 'N');
aso_debug_pub.add('Check_Hdr_Acct: p_qte_rec.invoice_to_party_site_id: '|| p_qte_rec.invoice_to_party_site_id, 1, 'N');
END IF;

    IF p_qte_rec.sold_to_party_site_id is not NULL
        AND p_qte_rec.sold_to_party_site_id <> FND_API.G_MISS_NUM THEN

         OPEN C_Site_Use(p_qte_rec.sold_to_party_site_id);
         FETCH C_Site_Use INTO l_party_site_use_id;
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('chk_hdr:party_site_use_id  = ' || l_party_site_use_id,1,'N');
	END IF;
         IF C_Site_Use%NOTFOUND THEN
              ASO_PARTY_INT.Create_Party_Site_Use(
                p_api_version          => 1.0,
            	 p_party_site_id	    => p_qte_rec.sold_to_party_site_id,
                p_party_site_use_type  => 'SOLD_TO',
            	 x_party_site_use_id    => l_party_site_use_id,
           	 x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('chk_hdr:party_site_use_id after sold_to = ' || l_party_site_use_id,1,'N');
		END IF;
        		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            		raise FND_API.G_EXC_ERROR;
        		END IF;

         END IF;

    END IF;  -- sold_to_party_site

    ASO_CHECK_TCA_PVT.Populate_Acct_Party (
         p_hdr_cust_acct_id   => p_qte_rec.cust_account_id,
         p_hdr_party_id       => p_qte_rec.cust_party_id,
         p_party_site_id      => p_qte_rec.invoice_to_party_site_id,
         p_cust_account_id    => p_qte_rec.invoice_to_cust_account_id,
         p_cust_party_id      => p_qte_rec.invoice_to_cust_party_id,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('chk_hdr:after populate_acct_party: ' || x_return_status,1,'N');
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF (p_qte_rec.invoice_to_cust_party_id is NOT NULL AND
        p_qte_rec.invoice_to_cust_party_id <> FND_API.G_MISS_NUM) AND
        (p_qte_rec.invoice_to_cust_account_id IS NULL OR
       p_qte_rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM) THEN


       IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Check_Tca: before customer account:p_qte_rec.invoice_to_cust_party_id '
                             ||p_qte_rec.invoice_to_cust_party_id, 1, 'N');
       END IF;
       Customer_Account(
            p_api_version       => 1.0,
            p_Party_Id          => p_qte_rec.invoice_to_cust_party_id,
            p_calling_api_flag  => 0,
            x_Cust_Acct_Id      => p_qte_rec.invoice_to_cust_account_id,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_Tca: after customer account:x_Return_Status '
                           ||x_Return_Status, 1, 'N');
      END IF;
      IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

    END IF;  -- invoice_to_cust_account_id

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Check_Tca: p_qte_rec.invoice_to_cust_account_id: '
                        ||p_qte_rec.invoice_to_cust_account_id, 1, 'N');
    END IF;


   IF p_qte_rec.invoice_to_cust_account_id is not NULL AND
       p_qte_rec.invoice_to_cust_account_id <> FND_API.G_MISS_NUM THEN
        l_invoice_cust_account_id := p_qte_rec.invoice_to_cust_account_id;
   ELSE
	  IF p_qte_rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM THEN
        OPEN c_get_cust_account_id;
	   FETCH c_get_cust_account_id INTO l_invoice_cust_account_id;
	   CLOSE c_get_cust_account_id;
	  END IF;
   END IF;
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('chk_hdr:l_invoice_cust_acccount_id = ' || l_invoice_cust_account_id,1,'N' );
      aso_debug_pub.add('chk_hdr:before invoice to party site id '|| p_qte_rec.invoice_to_party_site_id, 1, 'Y');
      aso_debug_pub.add('chk_hdr:invoice_to_cust_account = ' || p_qte_rec.invoice_to_cust_account_id,1,'N');
	 END IF;
   IF l_invoice_cust_account_id IS NOT NULL AND l_invoice_cust_account_id <> FND_API.G_MISS_NUM THEN

    IF p_qte_rec.invoice_to_party_site_id is not NULL
        AND p_qte_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM THEN

    	Customer_Account_Site(
          p_api_version     => 1.0
    	    ,p_party_site_id => p_qte_rec.invoice_to_party_site_id
    	    ,p_acct_site_type => 'BILL_TO'
    	    ,p_cust_account_id => l_invoice_cust_account_id
	    ,x_cust_acct_site_id => l_inv_cust_acct_site_id
    	    ,x_return_status   => x_return_status
         ,x_msg_count       => x_msg_count
         ,x_msg_data        => x_msg_data
    	    ,x_site_use_id  => l_invoice_to_org_id);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('chk_hdr:site_use_id after deriving invoice = ' || l_invoice_to_org_id,1,'N');
        aso_debug_pub.add('chk_hdr:cust_acct_site_id after deriving invoice = ' || l_inv_cust_acct_site_id,1,'N');
	   END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
	           FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
	    END IF;

    END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_hdr: invoice_to_party = ' || p_qte_rec.invoice_to_party_id,1, 'N' );
aso_debug_pub.add('chk_hdr: invoice_to_party_site = ' || p_qte_rec.invoice_to_party_site_id,1, 'N' );
aso_debug_pub.add('chk_hdr: before Cust_Acct_Contact_Addr:l_invoice_cust_account_id: '||l_invoice_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_qte_rec.invoice_to_party_site_id,
     p_role_type         =>  'BILL_TO',
     p_cust_account_id   =>  l_invoice_cust_account_id,
     p_party_id          =>  p_qte_rec.invoice_to_party_id,
     p_cust_account_site =>  l_inv_cust_acct_site_id,
     x_return_status     =>  x_return_status,
     x_msg_count         =>  x_msg_count,
     x_msg_data          =>  x_msg_data,
     x_cust_account_role_id      =>  l_invoice_to_contact_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after Cust_Acct_Contact_Addr:l_invoice_to_contact_id: '||l_invoice_to_contact_id,1,'N');
END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

  END IF; -- l_invoice_cust_account_id not null

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_hdr:beginning of mapping for header end user ', 1, 'N' );
END IF;

    ASO_CHECK_TCA_PVT.Populate_Acct_Party (
         p_hdr_cust_acct_id   => p_qte_rec.cust_account_id,
         p_hdr_party_id       => p_qte_rec.cust_party_id,
         p_party_site_id      => p_qte_rec.End_Customer_party_site_id,
         p_cust_account_id    => p_qte_rec.End_Customer_cust_account_id,
         p_cust_party_id      => p_qte_rec.End_Customer_cust_party_id,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('chk_hdr:after populate_acct_party: ' || x_return_status,1,'N');
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF (p_qte_rec.End_Customer_cust_party_id is NOT NULL AND
        p_qte_rec.End_Customer_cust_party_id <> FND_API.G_MISS_NUM) AND
        (p_qte_rec.End_Customer_cust_account_id IS NULL OR
       p_qte_rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM) THEN


       IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Check_Tca: before customer account:p_qte_rec.End_Customer_cust_party_id '
                             ||p_qte_rec.End_Customer_cust_party_id, 1, 'N');
       END IF;
       Customer_Account(
            p_api_version       => 1.0,
            p_Party_Id          => p_qte_rec.End_Customer_cust_party_id,
            p_calling_api_flag  => 0,
            x_Cust_Acct_Id      => p_qte_rec.End_Customer_cust_account_id,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_Tca: after customer account:x_Return_Status '
                           ||x_Return_Status, 1, 'N');
      END IF;
      IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

    END IF;  -- End_Customer_cust_account_id

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Check_Tca: p_qte_rec.End_Customer_cust_account_id: '
                        ||p_qte_rec.End_Customer_cust_account_id, 1, 'N');
    END IF;


   IF p_qte_rec.End_Customer_cust_account_id is not NULL AND
       p_qte_rec.End_Customer_cust_account_id <> FND_API.G_MISS_NUM THEN
        l_End_cust_account_id := p_qte_rec.End_Customer_cust_account_id;
   ELSE
       IF p_qte_rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM THEN
        OPEN c_get_cust_account_id;
        FETCH c_get_cust_account_id INTO l_End_cust_account_id;
        CLOSE c_get_cust_account_id;
       END IF;
   END IF;
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('chk_hdr:l_End_Customer_cust_acccount_id = ' || l_End_cust_account_id,1,'N' );
      aso_debug_pub.add('chk_hdr:before End_Customer party site id '|| p_qte_rec.End_Customer_party_site_id, 1, 'Y');
      aso_debug_pub.add('chk_hdr:End_Customer_cust_account = ' || p_qte_rec.End_Customer_cust_account_id,1,'N');
	 END IF;
   IF l_End_cust_account_id IS NOT NULL AND l_End_cust_account_id <> FND_API.G_MISS_NUM THEN

    IF p_qte_rec.End_Customer_party_site_id is not NULL
        AND p_qte_rec.End_Customer_party_site_id <> FND_API.G_MISS_NUM THEN

    	Customer_Account_Site(
          p_api_version     => 1.0
    	    ,p_party_site_id => p_qte_rec.End_Customer_party_site_id
    	    ,p_acct_site_type => 'END_USER'
    	    ,p_cust_account_id => l_End_cust_account_id
	    ,x_cust_acct_site_id => l_end_cust_acct_site_id
    	    ,x_return_status   => x_return_status
         ,x_msg_count       => x_msg_count
         ,x_msg_data        => x_msg_data
    	    ,x_site_use_id  => l_End_Customer_org_id);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('chk_hdr:site_use_id after deriving End_Customer = ' || l_End_Customer_org_id,1,'N');
        aso_debug_pub.add('chk_hdr:cust_acct_site_id after deriving End_Customer = ' || l_end_cust_acct_site_id,1,'N');
	   END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_END_SITE_AC_CRS');
	           FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
	    END IF;

    END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_hdr: End_Customer_to_party = ' || p_qte_rec.End_Customer_party_id,1, 'N' );
aso_debug_pub.add('chk_hdr: End_Customer_party_site = ' || p_qte_rec.End_Customer_party_site_id,1, 'N' );
aso_debug_pub.add('chk_hdr: before Cust_Acct_Contact_Addr:l_End_cust_account_id: '||l_End_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_qte_rec.End_Customer_party_site_id,
     p_role_type         =>  'END_USER',
     p_cust_account_id   =>  l_End_cust_account_id,
     p_party_id          =>  p_qte_rec.End_Customer_party_id,
     p_cust_account_site =>  l_end_cust_acct_site_id,
     x_return_status     =>  x_return_status,
     x_msg_count         =>  x_msg_count,
     x_msg_data          =>  x_msg_data,
     x_cust_account_role_id      =>  l_End_Customer_contact_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after Cust_Acct_Contact_Addr:l_End_Customer_contact_id: '||l_End_Customer_contact_id,1,'N');
END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

  END IF; -- l_End_cust_account_id not null

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_hdr:beginning of mapping for header shipping ', 1, 'N' );
END IF;

    IF p_header_shipment_tbl.count > 0 THEN
        -- OM takes in only one shipment at the header level

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Hdr_Acct: p_header_shipment_tbl(1).ship_to_cust_account_id: '
                   || p_header_shipment_tbl(1).ship_to_cust_account_id, 1, 'N');
aso_debug_pub.add('Check_Hdr_Acct: p_header_shipment_tbl(1).ship_to_cust_party_id: '
                   || p_header_shipment_tbl(1).ship_to_cust_party_id, 1, 'N');
aso_debug_pub.add('Check_Hdr_Acct: p_header_shipment_tbl(1).ship_to_party_site_id: '
                   || p_header_shipment_tbl(1).ship_to_party_site_id, 1, 'N');
END IF;

    ASO_CHECK_TCA_PVT.Populate_Acct_Party (
         p_hdr_cust_acct_id   => p_qte_rec.cust_account_id,
         p_hdr_party_id       => p_qte_rec.cust_party_id,
         p_party_site_id      => p_header_shipment_tbl(1).ship_to_party_site_id,
         p_cust_account_id    => p_header_shipment_tbl(1).ship_to_cust_account_id,
         p_cust_party_id      => p_header_shipment_tbl(1).ship_to_cust_party_id,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('chk_hdr:(ship)after populate_acct_party: ' || x_return_status,1,'N');
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF (p_header_shipment_tbl(1).ship_to_cust_party_id IS NOT NULL AND
        p_header_shipment_tbl(1).ship_to_cust_party_id <> FND_API.G_MISS_NUM) AND
        (p_header_shipment_tbl(1).ship_to_cust_account_id IS NULL OR
       p_header_shipment_tbl(1).ship_to_cust_account_id = FND_API.G_MISS_NUM) THEN


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_Tca: before customer account:p_header_shipment_tbl(1).
         ship_to_cust_party_id '||p_header_shipment_tbl(1).ship_to_cust_party_id
, 1, 'N');
      END IF;
      Customer_Account(
             p_api_version       => 1.0,
            p_Party_Id          => p_header_shipment_tbl(1).ship_to_cust_party_id,
                p_calling_api_flag  => 0,
                x_Cust_Acct_Id      => p_header_shipment_tbl(1).ship_to_cust_account_id,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Check_Tca: after customer account:x_Return_Status '
           ||x_Return_Status, 1, 'N');
     END IF;
     IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
     END IF;

   END IF;  -- cust_account_id

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Check_Tca: p_header_shipment_tbl(1).ship_to_cust_account_id: '||
                      p_header_shipment_tbl(1).ship_to_cust_account_id, 1, 'N');
   END IF;


       IF p_header_shipment_tbl(1).ship_to_cust_account_id is not NULL AND
          p_header_shipment_tbl(1).ship_to_cust_account_id <> FND_API.G_MISS_NUM THEN
            l_ship_cust_account_id := p_header_shipment_tbl(1).ship_to_cust_account_id;
       ELSE
         IF p_header_shipment_tbl(1).ship_to_cust_account_id = FND_API.G_MISS_NUM THEN
           OPEN c_get_cust_account_id;
           FETCH c_get_cust_account_id INTO l_ship_cust_account_id;
           CLOSE c_get_cust_account_id;
         END IF;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_hdr:ship cust acccount = ' || l_ship_cust_account_id ,1, 'N');
aso_debug_pub.add('chk_hdr:ship to party site = ' || p_header_shipment_tbl(1).ship_to_party_site_id, 1, 'N');
END IF;
	  IF l_ship_cust_account_id IS NOT NULL AND l_ship_cust_account_id <> FND_API.G_MISS_NUM THEN

        IF p_header_shipment_tbl(1).ship_to_party_site_id is not NULL
            AND p_header_shipment_tbl(1).ship_to_party_site_id <> FND_API.G_MISS_NUM THEN

            Customer_Account_Site(
      		    p_api_version     => 1.0
                ,p_party_site_id => p_header_shipment_tbl(1).ship_to_party_site_id
                ,p_acct_site_type => 'SHIP_TO'
                ,p_cust_account_id => l_ship_cust_account_id
		      ,x_cust_acct_site_id => l_shp_cust_acct_site_id
                ,x_return_status => x_return_status
     		 ,x_msg_count       => x_msg_count
     		 ,x_msg_data        => x_msg_data
                ,x_site_use_id  => l_ship_to_org_id);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('chk_hdr:ship to org after deriving = ' || l_ship_to_org_id, 1, 'Y');
            aso_debug_pub.add('chk_hdr:ship cust acct site after deriving = ' || l_shp_cust_acct_site_id, 1, 'Y');
		  END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_SHP_SITE_AC_CRS');
                    -- FND_MESSAGE.Set_Token('ID', to_char(p_header_shipment_tbl(1).ship_to_party_site_id),FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
                raise FND_API.G_EXC_ERROR;
            END IF;

        END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_hdr:beginning of map 2:ship_party_id:' || p_header_shipment_tbl(1).ship_to_party_id,1,'N');
aso_debug_pub.add('chk_hdr: before Cust_Acct_Contact_Addr:l_ship_cust_account_id: '||l_ship_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_header_shipment_tbl(1).ship_to_party_site_id,
     p_role_type         =>  'SHIP_TO',
     p_cust_account_id   =>  l_ship_cust_account_id,
     p_party_id          =>  p_header_shipment_tbl(1).ship_to_party_id,
     p_cust_account_site =>  l_shp_cust_acct_site_id,
     x_return_status     =>  x_return_status,
     x_msg_count         =>  x_msg_count,
     x_msg_data          =>  x_msg_data,
     x_cust_account_role_id      =>  l_ship_to_contact_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_hdr: after Cust_Acct_Contact_Addr:l_ship_to_contact_id: '||l_ship_to_contact_id,1,'N');
aso_debug_pub.add('chk_hdr: after Cust_Acct_Contact_Addr:l_shp_cust_acct_site_id: '||l_shp_cust_acct_site_id,1,'N');
END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

   END IF;  -- l_ship_cust_account_id is not null

  END IF;  -- shipment tbl count

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('end chk_hdr:after map 2 for header',1,'N');
    END IF;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END check_header_account_info;


PROCEDURE check_line_account_info(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
    p_cust_account_id   IN  NUMBER,
    P_Qte_Line_Rec      IN OUT NOCOPY   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Line_Shipment_Tbl IN OUT NOCOPY    ASO_QUOTE_PUB.Shipment_Tbl_Type,
    p_application_type_code IN  VARCHAR2  := FND_API.G_MISS_CHAR,
    x_return_status	    OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count	    OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data		    OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_api_name          CONSTANT VARCHAR2(45) := 'Check_Line_Account_Info';
    l_site_use_id               NUMBER;
    l_invoice_cust_account_id   NUMBER;
    l_End_cust_account_id   NUMBER;
    l_invoice_contact_party_id  NUMBER;
    l_invoice_to_contact_id     NUMBER;
    l_End_Customer_contact_id   NUMBER;
    l_ship_cust_account_id      NUMBER;
    l_invoice_cust_account_site NUMBER;
    l_End_cust_account_site NUMBER;
    l_ship_contact_party_id     NUMBER;
    l_ship_to_contact_id        NUMBER;
    l_ship_cust_account_site    NUMBER;
    l_invoice_to_org_id	    	  NUMBER;
    l_End_Customer_org_id	  NUMBER;
    l_inv_cust_acct_site_id	  NUMBER;
    l_end_cust_acct_site_id	  NUMBER;
    l_shp_cust_acct_site_id	  NUMBER;

    l_cust_party_id             NUMBER := NULL;
    l_cust_acct_id              NUMBER := NULL;
    j                           NUMBER := 1;

	l_qte_line_rec          ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Line_Rec;
     l_shipment_rec          ASO_QUOTE_PUB.shipment_rec_type  := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;

   CURSOR get_cust_acct_site_id(l_site_use_id number) IS
     select cust_acct_site_id from hz_cust_site_uses
     where site_use_id = l_site_use_id;

    CURSOR C_Get_Sold_To_Info(qte_hdr NUMBER) IS
     SELECT cust_account_id, cust_party_id
     FROM ASO_QUOTE_HEADERS_ALL
     WHERE quote_header_id = qte_hdr;

    CURSOR C_Get_Party_From_Acct(acct_id NUMBER) IS
     SELECT party_id
     FROM HZ_CUST_ACCOUNTS
     WHERE cust_account_id = acct_id
     AND status = 'A'
     AND sysdate BETWEEN NVL(account_activation_date, sysdate) AND NVL(account_termination_date, sysdate);

   CURSOR C_line_cust IS
   SELECT invoice_to_cust_account_id,end_customer_cust_account_id
   FROM ASO_QUOTE_LINES_ALL
   WHERE quote_line_id = P_Qte_Line_Rec.quote_line_id;

   CURSOR C_ship_cust(l_shipment_id NUMBER) IS
   SELECT ship_to_cust_account_id
   FROM ASO_SHIPMENTS
   WHERE shipment_id = l_shipment_id;




BEGIN

  SAVEPOINT CHECK_LINE_ACCOUNT_INFO_PVT;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('line account info:begin ',1,'Y');
aso_debug_pub.add('line account info:P_line_Shipment_Tbl.count: '||P_line_Shipment_Tbl.count,1,'N');
END IF;

    FOR j in 1..P_line_Shipment_Tbl.count LOOP

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('line account info:p_qte_line_rec.invoice_to_cust_account_id: '||p_qte_line_rec.invoice_to_cust_account_id,1,'N');
aso_debug_pub.add('line account info:p_qte_line_rec.invoice_to_cust_party_id: '||p_qte_line_rec.invoice_to_cust_party_id,1,'N');
aso_debug_pub.add('line account info:p_qte_line_rec.invoice_to_party_site_id: '||p_qte_line_rec.invoice_to_party_site_id,1,'N');
END IF;

    IF (P_Qte_Line_Rec.operation_code = 'UPDATE' AND P_Application_Type_Code = 'QUOTING HTML') THEN
      l_qte_line_rec := ASO_UTILITY_PVT.query_qte_line_row (P_Qte_Line_Rec.quote_line_id);

      IF P_Qte_Line_Rec.invoice_to_party_id <> FND_API.G_MISS_NUM OR
         P_Qte_Line_Rec.invoice_to_cust_party_id <> FND_API.G_MISS_NUM OR
         P_Qte_Line_Rec.invoice_to_cust_account_id <> FND_API.G_MISS_NUM OR
         P_Qte_Line_Rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM THEN

        IF P_Qte_Line_Rec.invoice_to_party_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.invoice_to_party_id := l_qte_line_rec.invoice_to_party_id;
        END IF;
        IF P_Qte_Line_Rec.invoice_to_cust_party_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.invoice_to_cust_party_id := l_qte_line_rec.invoice_to_cust_party_id;
        END IF;
        IF P_Qte_Line_Rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.invoice_to_cust_account_id := l_qte_line_rec.invoice_to_cust_account_id;
        END IF;
        IF P_Qte_Line_Rec.invoice_to_party_site_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.invoice_to_party_site_id := l_qte_line_rec.invoice_to_party_site_id;
        END IF;
      END IF;

      IF P_Qte_Line_Rec.End_Customer_party_id <> FND_API.G_MISS_NUM OR
         P_Qte_Line_Rec.End_Customer_cust_party_id <> FND_API.G_MISS_NUM OR
         P_Qte_Line_Rec.End_Customer_cust_account_id <> FND_API.G_MISS_NUM OR
         P_Qte_Line_Rec.End_Customer_party_site_id <> FND_API.G_MISS_NUM THEN

        IF P_Qte_Line_Rec.End_Customer_party_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.End_Customer_party_id := l_qte_line_rec.End_Customer_party_id;
        END IF;
        IF P_Qte_Line_Rec.End_Customer_cust_party_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.End_Customer_cust_party_id := l_qte_line_rec.End_Customer_cust_party_id;
        END IF;
        IF P_Qte_Line_Rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.End_Customer_cust_account_id := l_qte_line_rec.End_Customer_cust_account_id;
        END IF;
        IF P_Qte_Line_Rec.End_Customer_party_site_id = FND_API.G_MISS_NUM THEN
          P_Qte_Line_Rec.End_Customer_party_site_id := l_qte_line_rec.End_Customer_party_site_id;
        END IF;
      END IF;

      IF P_line_Shipment_Tbl(j).operation_code = 'UPDATE' THEN
       IF P_line_Shipment_Tbl(j).shipment_id IS NOT NULL AND P_line_Shipment_Tbl(j).shipment_id <> FND_API.G_MISS_NUM THEN
         IF P_line_Shipment_Tbl(j).ship_to_party_id <> FND_API.G_MISS_NUM OR
            P_line_Shipment_Tbl(j).ship_to_cust_party_id <> FND_API.G_MISS_NUM OR
            P_line_Shipment_Tbl(j).ship_to_cust_account_id <> FND_API.G_MISS_NUM OR
            P_line_Shipment_Tbl(j).ship_to_party_site_id <> FND_API.G_MISS_NUM THEN

           l_shipment_rec := ASO_UTILITY_PVT.query_shipment_row (P_line_Shipment_Tbl(j).shipment_id);
           IF P_line_Shipment_Tbl(j).ship_to_party_id = FND_API.G_MISS_NUM THEN
             P_line_Shipment_Tbl(j).ship_to_party_id := l_shipment_rec.ship_to_party_id;
           END IF;
           IF P_line_Shipment_Tbl(j).ship_to_cust_party_id = FND_API.G_MISS_NUM THEN
             P_line_Shipment_Tbl(j).ship_to_cust_party_id := l_shipment_rec.ship_to_cust_party_id;
           END IF;
           IF P_line_Shipment_Tbl(j).ship_to_cust_account_id = FND_API.G_MISS_NUM THEN
             P_line_Shipment_Tbl(j).ship_to_cust_account_id := l_shipment_rec.ship_to_cust_account_id;
           END IF;
           IF P_line_Shipment_Tbl(j).ship_to_party_site_id = FND_API.G_MISS_NUM THEN
             P_line_Shipment_Tbl(j).ship_to_party_site_id := l_shipment_rec.ship_to_party_site_id;
           END IF;
         END IF;
  	  END IF;
     END IF;

    END IF; -- UPDATE

/* bug5132989
        l_cust_acct_id  :=  p_qte_line_rec.invoice_to_cust_account_id;
	   l_cust_party_id := p_qte_line_rec.invoice_to_cust_party_id;


       IF l_cust_acct_id IS NULL OR l_cust_party_id IS NULL THEN

           OPEN C_Get_Sold_To_Info(p_qte_line_rec.quote_header_id);
           FETCH C_Get_Sold_To_Info INTO l_cust_acct_id, l_cust_party_id;
           CLOSE C_Get_Sold_To_Info;

       END IF;

       ASO_CHECK_TCA_PVT.Populate_Acct_Party (
            p_hdr_cust_acct_id   => l_cust_acct_id,
            p_hdr_party_id       => l_cust_party_id,
            p_party_site_id      => p_qte_line_rec.invoice_to_party_site_id,
            p_cust_account_id    => p_qte_line_rec.invoice_to_cust_account_id,
            p_cust_party_id      => p_qte_line_rec.invoice_to_cust_party_id,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data );

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('chk_lin:after populate_acct_party: ' || x_return_status,1,'N');
	  END IF;
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
       END IF;
*/

    IF  (p_qte_line_rec.invoice_to_cust_party_id IS NOT NULL AND
         p_qte_line_rec.invoice_to_cust_party_id <> FND_API.G_MISS_NUM) AND
        (p_qte_line_rec.invoice_to_cust_account_id IS NULL OR
          p_qte_line_rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM) THEN


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Check_Tca: before customer account: p_qte_line_rec.invoice_to_cust_party_id '
                             || p_qte_line_rec.invoice_to_cust_party_id, 1, 'N')
;
      END IF;
      Customer_Account(
            p_api_version       => 1.0,
            p_Party_Id          =>  p_qte_line_rec.invoice_to_cust_party_id,
            p_calling_api_flag  => 0,
            x_Cust_Acct_Id      => p_qte_line_rec.invoice_to_cust_account_id,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_Tca: after customer account:x_Return_Status '
                           ||x_Return_Status, 1, 'N');
      END IF;
      IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

    END IF;  -- invoice_to_cust_account_id
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Check_Tca: p_qte_line_rec.invoice_to_cust_account_id: '
                        ||p_qte_line_rec.invoice_to_cust_account_id, 1, 'N');
    END IF;


               IF p_qte_line_rec.invoice_to_cust_account_id is not NULL AND
                  p_qte_line_rec.invoice_to_cust_account_id <> FND_API.G_MISS_NUM THEN
                    l_invoice_cust_account_id := p_qte_line_rec.invoice_to_cust_account_id;
               ELSE
				IF p_qte_line_rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM THEN
                        OPEN C_line_cust;
				    FETCH C_line_cust INTO l_invoice_cust_account_id,l_End_cust_account_id;
				    CLOSE C_line_cust;
                    END IF;
               END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: l_invoice_cust_account_id: '||l_invoice_cust_account_id,1,'N');
aso_debug_pub.add('chk_ln: l_End_cust_account_id: '||l_End_cust_account_id,1,'N');
aso_debug_pub.add('line account info: inside shipment loop:party_site: '||p_qte_line_rec.invoice_to_party_site_id,1,'N');
END IF;

			IF l_invoice_cust_account_id IS NOT NULL AND l_invoice_cust_account_id <> FND_API.G_MISS_NUM THEN

                IF p_qte_line_rec.invoice_to_party_site_id is not NULL
                    AND p_qte_line_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM THEN

                    Customer_Account_Site(
         		          p_api_version     => 1.0
                        ,p_party_site_id => p_qte_line_rec.invoice_to_party_site_id
                        ,p_acct_site_type => 'BILL_TO'
                        ,p_cust_account_id => l_invoice_cust_account_id
			         ,x_cust_acct_site_id => l_inv_cust_acct_site_id
                        ,x_return_status => x_return_status
         		         ,x_msg_count       => x_msg_count
         		         ,x_msg_data        => x_msg_data
                        ,x_site_use_id  => l_site_use_id);

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
                            FND_MSG_PUB.ADD;
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                    END IF;
				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('line account info: site use after cust account site: '||l_site_use_id,1,'N');
                    aso_debug_pub.add('line account info: cust_acct_site after cust account site: '||l_inv_cust_acct_site_id,1,'N');
				END IF;
                END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: before Cust_Acct_Contact_Addr:l_invoice_cust_account_id: '||l_invoice_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_qte_line_rec.invoice_to_party_site_id,
     p_role_type         =>  'BILL_TO',
     p_cust_account_id   =>  l_invoice_cust_account_id,
     p_party_id          =>  p_qte_line_rec.invoice_to_party_id,
     p_cust_account_site =>  l_inv_cust_acct_site_id,
     x_return_status     =>  x_return_status,
     x_msg_count         =>  x_msg_count,
     x_msg_data          =>  x_msg_data,
     x_cust_account_role_id      =>  l_invoice_to_contact_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: after Cust_Acct_Contact_Addr:l_invoice_to_contact_id: '||l_invoice_to_contact_id,1,'N');
aso_debug_pub.add('chk_ln: after Cust_Acct_Contact_Addr:l_inv_cust_acct_site_id: '||l_inv_cust_acct_site_id,1,'N');
END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

  END IF;  -- l_invoice_cust_account_id is not null


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('line account info:p_qte_line_rec.End_Customer_cust_account_id: '||p_qte_line_rec.End_Customer_cust_account_id,1,'N');
aso_debug_pub.add('line account info:p_qte_line_rec.End_Customer_cust_party_id: '||p_qte_line_rec.End_Customer_cust_party_id,1,'N');
aso_debug_pub.add('line account info:p_qte_line_rec.End_Customer_party_site_id: '||p_qte_line_rec.End_Customer_party_site_id,1,'N');
END IF;

      /*--bug  5132989
        l_cust_acct_id  :=  p_qte_line_rec.End_Customer_cust_account_id;
        l_cust_party_id :=  p_qte_line_rec.End_Customer_cust_party_id;

        IF l_cust_acct_id IS NULL AND  l_cust_party_id IS NOT  NULL AND l_cust_party_id <> FND_API.G_MISS_NUM THEN

           OPEN C_Get_Sold_To_Info(p_qte_line_rec.quote_header_id);
           FETCH C_Get_Sold_To_Info INTO l_cust_acct_id, l_cust_party_id;
           CLOSE C_Get_Sold_To_Info;


       ASO_CHECK_TCA_PVT.Populate_Acct_Party (
            p_hdr_cust_acct_id   => l_cust_acct_id,
            p_hdr_party_id       => l_cust_party_id,
            p_party_site_id      => p_qte_line_rec.End_Customer_party_site_id,
            p_cust_account_id    => p_qte_line_rec.End_Customer_cust_account_id,
            p_cust_party_id      => p_qte_line_rec.End_Customer_cust_party_id,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data );

       END IF;
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('chk_lin:after populate_acct_party: ' || x_return_status,1,'N');
	  END IF;
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
       END IF;

     */
    IF  (p_qte_line_rec.End_Customer_cust_party_id IS NOT NULL AND
         p_qte_line_rec.End_Customer_cust_party_id <> FND_API.G_MISS_NUM) AND
        (p_qte_line_rec.End_Customer_cust_account_id IS NULL OR
          p_qte_line_rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM) THEN


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Check_Tca: before customer account: p_qte_line_rec.End_Customer_cust_party_id '
                             || p_qte_line_rec.End_Customer_cust_party_id, 1, 'N')
;
      END IF;
      Customer_Account(
            p_api_version       => 1.0,
            p_Party_Id          =>  p_qte_line_rec.End_Customer_cust_party_id,
            p_calling_api_flag  => 0,
            x_Cust_Acct_Id      => p_qte_line_rec.End_Customer_cust_account_id,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_Tca: after customer account:x_Return_Status '
                           ||x_Return_Status, 1, 'N');
      END IF;
      IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

    END IF;  -- End_Customer_cust_account_id
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Check_Tca: p_qte_line_rec.End_Customer_cust_account_id: '
                        ||p_qte_line_rec.End_Customer_cust_account_id, 1, 'N');
    END IF;


               IF p_qte_line_rec.End_Customer_cust_account_id is not NULL AND
                  p_qte_line_rec.End_Customer_cust_account_id <> FND_API.G_MISS_NUM THEN
                    l_End_cust_account_id := p_qte_line_rec.End_Customer_cust_account_id;
               ELSE
				IF p_qte_line_rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM THEN
                        OPEN C_line_cust;
                        FETCH C_line_cust INTO l_invoice_cust_account_id,l_End_cust_account_id;
                        CLOSE C_line_cust;
                    END IF;
               END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: l_End_cust_account_id: '||l_End_cust_account_id,1,'N');
aso_debug_pub.add('line account info: inside shipment loop:party_site: '||p_qte_line_rec.End_Customer_party_site_id,1,'N');
END IF;

			IF l_End_cust_account_id IS NOT NULL AND l_End_cust_account_id <> FND_API.G_MISS_NUM THEN

                IF p_qte_line_rec.End_Customer_party_site_id is not NULL
                    AND p_qte_line_rec.End_Customer_party_site_id <> FND_API.G_MISS_NUM THEN

                    Customer_Account_Site(
         		          p_api_version     => 1.0
                        ,p_party_site_id => p_qte_line_rec.End_Customer_party_site_id
                        ,p_acct_site_type => 'END_USER'
                        ,p_cust_account_id => l_End_cust_account_id
			         ,x_cust_acct_site_id => l_end_cust_acct_site_id
                        ,x_return_status => x_return_status
         		         ,x_msg_count       => x_msg_count
         		         ,x_msg_data        => x_msg_data
                        ,x_site_use_id  => l_site_use_id);

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_END_SITE_AC_CRS');
                            FND_MSG_PUB.ADD;
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                    END IF;
				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('line account info: site use after cust account site: '||l_site_use_id,1,'N');
                    aso_debug_pub.add('line account info: cust_acct_site after cust account site: '||l_end_cust_acct_site_id,1,'N');
				END IF;
                END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: before Cust_Acct_Contact_Addr:l_End_cust_account_id: '||l_End_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_qte_line_rec.End_Customer_party_site_id,
     p_role_type         =>  'END_USER',
     p_cust_account_id   =>  l_End_cust_account_id,
     p_party_id          =>  p_qte_line_rec.End_Customer_party_id,
     p_cust_account_site =>  l_end_cust_acct_site_id,
     x_return_status     =>  x_return_status,
     x_msg_count         =>  x_msg_count,
     x_msg_data          =>  x_msg_data,
     x_cust_account_role_id      =>  l_End_Customer_contact_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: after Cust_Acct_Contact_Addr:l_End_Customer_contact_id: '||l_End_Customer_contact_id,1,'N');
aso_debug_pub.add('chk_ln: after Cust_Acct_Contact_Addr:l_end_cust_acct_site_id: '||l_end_cust_acct_site_id,1,'N');
END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

  END IF;  -- l_End_cust_account_id is not null

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: p_line_shipment_tbl(j).ship_to_cust_account_id: '
			    ||p_line_shipment_tbl(j).ship_to_cust_account_id,1,'N');
aso_debug_pub.add('chk_ln: p_line_shipment_tbl(j).ship_to_cust_party_id: '
			    ||p_line_shipment_tbl(j).ship_to_cust_party_id,1,'N');
aso_debug_pub.add('chk_ln: p_line_shipment_tbl(j).ship_to_party_site_id: '
			    ||p_line_shipment_tbl(j).ship_to_party_site_id,1,'N');
END IF;
-- bug 5132989
/*
       ASO_CHECK_TCA_PVT.Populate_Acct_Party (
            p_hdr_cust_acct_id   => l_cust_acct_id,
            p_hdr_party_id       => l_cust_party_id,
            p_party_site_id      => p_line_shipment_tbl(j).ship_to_party_site_id,
            p_cust_account_id    => p_line_shipment_tbl(j).ship_to_cust_account_id,
            p_cust_party_id      => p_line_shipment_tbl(j).ship_to_cust_party_id,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data );

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('chk_lin:(ship)after populate_acct_party: ' || x_return_status,1,'N');
	  END IF;
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
       END IF;
*/
    IF (p_line_shipment_tbl(j).ship_to_cust_party_id IS NOT NULL AND
        p_line_shipment_tbl(j).ship_to_cust_party_id <> FND_API.G_MISS_NUM) AND
       (p_line_shipment_tbl(j).ship_to_cust_account_id IS NULL OR
        p_line_shipment_tbl(j).ship_to_cust_account_id = FND_API.G_MISS_NUM) THEN


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Check_Tca: before customer account:p_header_shipment_tbl(j).
         ship_to_cust_party_id '||p_line_shipment_tbl(j).ship_to_cust_party_id,
1, 'N');
      END IF;
      Customer_Account(
             p_api_version       => 1.0,
            p_Party_Id          => p_line_shipment_tbl(j).ship_to_cust_party_id,
                         p_calling_api_flag  => 0,
                x_Cust_Acct_Id      => p_line_shipment_tbl(j).ship_to_cust_account_id,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Check_Tca: after customer account:x_Return_Status '
           ||x_Return_Status, 1, 'N');
     END IF;
     IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
     END IF;

   END IF;  -- ship cust_account_id

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Check_Tca: p_line_shipment_tbl(j).ship_to_cust_account_id: '||
                      p_line_shipment_tbl(j).ship_to_cust_account_id, 1, 'N');
   END IF;

                IF p_line_shipment_tbl(j).ship_to_cust_account_id is not NULL AND
                   p_line_shipment_tbl(j).ship_to_cust_account_id <> FND_API.G_MISS_NUM THEN
                    l_ship_cust_account_id := p_line_shipment_tbl(j).ship_to_cust_account_id;
                ELSE
				IF p_line_shipment_tbl(j).ship_to_cust_account_id = FND_API.G_MISS_NUM THEN
                         OPEN C_ship_cust(p_line_shipment_tbl(j).shipment_id);
                         FETCH C_ship_cust INTO l_ship_cust_account_id ;
                         CLOSE C_ship_cust;
                    END IF;
                END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('line acct info: before cust_acct_site:l_ship_cust_account_id: '||l_ship_cust_account_id,1,'N');
END IF;

			IF l_ship_cust_account_id IS NOT NULL AND l_ship_cust_account_id <> FND_API.G_MISS_NUM THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('line acct info: before cust_acct_site:p_line_shipment_tbl(j).ship_to_party_site_id: '||p_line_shipment_tbl(j).ship_to_party_site_id,1,'N');
END IF;
                IF p_line_shipment_tbl(j).ship_to_party_site_id is not NULL AND
                    p_line_shipment_tbl(j).ship_to_party_site_id <> FND_API.G_MISS_NUM THEN

                    Customer_Account_Site(
      		          p_api_version     => 1.0
                        ,p_party_site_id => p_line_shipment_tbl(j).ship_to_party_site_id
                        ,p_acct_site_type => 'SHIP_TO'
                        ,p_cust_account_id => l_ship_cust_account_id
			         ,x_cust_acct_site_id => l_shp_cust_acct_site_id
                        ,x_return_status => x_return_status
     	              ,x_msg_count       => x_msg_count
     	              ,x_msg_data        => x_msg_data
                        ,x_site_use_id  => l_site_use_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('line acct info: after cust_acct_site:l_site_use_id: '||l_site_use_id,1,'N');
aso_debug_pub.add('line acct info: after cust_acct_site:l_shp_cust_acct_site_id: '||l_shp_cust_acct_site_id,1,'N');
END IF;
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
                            -- FND_MESSAGE.Set_Token('ID', to_char(p_line_shipment_tbl(j).ship_to_party_site_id),FALSE);
                            FND_MSG_PUB.ADD;
                        END IF;
                        raise FND_API.G_EXC_ERROR;
                    END IF;

                END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: before Cust_Acct_Contact_Addr:l_ship_cust_account_id: '||l_ship_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_line_shipment_tbl(j).ship_to_party_site_id,
     p_role_type         =>  'SHIP_TO',
     p_cust_account_id   =>  l_ship_cust_account_id,
     p_party_id          =>  p_line_shipment_tbl(j).ship_to_party_id,
     p_cust_account_site =>  l_shp_cust_acct_site_id,
     x_return_status     =>  x_return_status,
     x_msg_count         =>  x_msg_count,
     x_msg_data          =>  x_msg_data,
     x_cust_account_role_id      =>  l_ship_to_contact_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('chk_ln: after Cust_Acct_Contact_Addr:l_ship_to_contact_id: '||l_ship_to_contact_id,1,'N');
aso_debug_pub.add('chk_ln: after Cust_Acct_Contact_Addr:l_shp_cust_acct_site_id: '||l_shp_cust_acct_site_id,1,'N');
END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

   END IF;  -- l_ship_cust_account_id is not null

  END LOOP;  -- for shipment


   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END check_line_account_info;


PROCEDURE Customer_Account(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    p_Party_Id          IN      NUMBER,
    p_error_ret         IN      VARCHAR2  := FND_API.G_TRUE,
    p_calling_api_flag  IN      NUMBER    := 0,
    x_Cust_Acct_Id      OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */       VARCHAR2)
    IS

    CURSOR C_Get_Account_Count(l_party_id NUMBER) IS
	   SELECT count(rowid)
	   FROM hz_cust_accounts
	   WHERE party_id = l_party_id
	   AND status = 'A'
        AND sysdate BETWEEN NVL(account_activation_date, sysdate) AND NVL(account_termination_date, sysdate);

    CURSOR C_Get_Account_User_Count(l_party_id NUMBER) IS
        SELECT count(a.rowid)
        from hz_cust_accounts a, hz_relationships b
        where a.party_id = b.object_id
        and a.status = 'A'
	   AND sysdate BETWEEN NVL(a.account_activation_date, sysdate) AND NVL(a.account_termination_date, sysdate)
        and b.party_id = l_party_id
        and b.subject_table_name = 'HZ_PARTIES'
        and b.subject_type = 'PERSON';

    CURSOR C_get_cust_id_from_party_id(l_Party_Id NUMBER) IS
        SELECT cust_account_id
        FROM hz_cust_accounts
        WHERE party_id = l_Party_Id
        AND status = 'A'
	   AND sysdate BETWEEN NVL(account_activation_date, sysdate) AND NVL(account_termination_date, sysdate)
	   ORDER BY creation_date ASC;

    CURSOR party_rec(l_party_id NUMBER) IS
        select party_type
        from hz_parties
        where party_id = l_party_id;

    CURSOR party_rel_cur(l_party_id number) IS
        select object_id
        from hz_relationships
        where party_id = l_party_id
        and object_table_name = 'HZ_PARTIES'
	   and subject_table_name = 'HZ_PARTIES'
	   and subject_type = 'PERSON';

    CURSOR account_user_cur(l_party_id NUMBER) IS
        select a.cust_account_id
        from hz_cust_accounts a, hz_relationships b
        where a.party_id = b.object_id
        and a.status = 'A'
	   AND sysdate BETWEEN NVL(a.account_activation_date, sysdate) AND NVL(a.account_termination_date, sysdate)
        and b.party_id = l_party_id
	   and b.subject_table_name = 'HZ_PARTIES'
	   and b.subject_type = 'PERSON'
	   ORDER BY a.creation_date ASC;

    l_acct_count        NUMBER  := 0;
    lx_cust_id          NUMBER  := NULL;
    cust_account_id     NUMBER;
    l_return_status     VARCHAR2(1);
    l_party_type        VARCHAR2(30);
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_api_name          CONSTANT VARCHAR2(45) := 'Customer_Account';
    l_object_party_id   NUMBER;
    l_create_acct_prof  VARCHAR2(30) := NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED');

BEGIN

     ---- Initialize---------------------

     SAVEPOINT CUSTOMER_ACCOUNT_PVT;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
    ) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Chk_TCA.Customer_Account Begin ',1,'N');
aso_debug_pub.add('Customer_Account: p_party_id '||p_party_id,1,'N');
aso_debug_pub.add('Customer_Account: p_error_ret '||p_error_ret,1,'N');
aso_debug_pub.add('Customer_Account: p_calling_api_flag '||p_calling_api_flag,1,'N');
END IF;

    OPEN party_rec(p_party_id);
    FETCH party_rec INTO l_party_type;
    CLOSE party_rec;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_Acct:party type for sold_to = '|| l_party_type,1,'N');
END IF;
    IF l_party_type = 'PERSON' OR l_party_type ='ORGANIZATION' THEN

      IF p_error_ret = FND_API.G_TRUE AND p_calling_api_flag NOT IN (1,2) THEN
          OPEN C_Get_Account_Count(p_party_id);
          FETCH C_Get_Account_Count INTO l_acct_count;
          CLOSE C_Get_Account_Count;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_Acct:l_acct_count: '|| l_acct_count,1,'N');
END IF;
        IF l_acct_count > 1 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ASO', 'ASO_MULTIPLE_CUST_ACCOUNT');
            FND_MESSAGE.Set_Token('ID', to_char(p_Party_Id), FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
	   END IF;
      END IF;

      -- derive customer account
      OPEN C_get_cust_id_from_party_id(p_Party_Id);
      FETCH C_get_cust_id_from_party_id INTO lx_cust_id;
      CLOSE C_get_cust_id_from_party_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_Acct:cust acct id for sold_to = '|| lx_cust_id,1,'N');
END IF;

    ELSIF l_party_type = 'PARTY_RELATIONSHIP' THEN   -- party_type

      IF p_error_ret = FND_API.G_TRUE AND p_calling_api_flag NOT IN (1,2) THEN
          OPEN C_Get_Account_User_Count(p_party_id);
          FETCH C_Get_Account_User_Count INTO l_acct_count;
          CLOSE C_Get_Account_User_Count;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_Acct:l_acct_count: '|| l_acct_count,1,'N');
END IF;
        IF l_acct_count > 1 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ASO', 'ASO_MULTIPLE_CUST_ACCOUNT');
            FND_MESSAGE.Set_Token('ID', to_char(p_Party_Id), FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      OPEN account_user_cur(p_party_id);
      FETCH account_user_cur INTO lx_cust_id;
      CLOSE account_user_cur;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('cust acct id for sold_to = '|| lx_cust_id,1,'N');
END IF;
   END IF;  -- party_type

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('checking for object id of relationship',1,'N');
aso_debug_pub.add('lx_cust_id in rel = ' || lx_cust_id,1,'N');
END IF;

   IF lx_cust_id is NULL OR lx_cust_id = FND_API.G_MISS_NUM THEN

       OPEN party_rel_cur(p_party_id);
       FETCH party_rel_cur INTO l_object_party_id;
	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('object_id = ' || l_object_party_id,1,'N');
	  END IF;
       IF party_rel_cur%NOTFOUND THEN
--           x_return_status := FND_API.G_RET_STS_ERROR;
           CLOSE party_rel_cur;
       ELSE
         IF p_error_ret = FND_API.G_TRUE AND p_calling_api_flag NOT IN (1,2) THEN
             OPEN C_Get_Account_Count(l_object_party_id);
             FETCH C_Get_Account_Count INTO l_acct_count;
             CLOSE C_Get_Account_Count;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_Acct:l_acct_count: '|| l_acct_count,1,'N');
END IF;

             IF l_acct_count > 1 THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.Set_Name('ASO', 'ASO_MULTIPLE_CUST_ACCOUNT');
                 FND_MESSAGE.Set_Token('ID', to_char(l_object_party_id), FALSE);
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
         END IF;

         OPEN account_user_cur(l_object_party_id);
         FETCH account_user_cur INTO lx_cust_id;
         CLOSE account_user_cur;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('cust acct id for sold_to = '|| lx_cust_id,1,'N');
END IF;

      END IF; -- party_rel_cur

    END IF;  -- lx_cust_id
    -- create customer account
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('creating customer account',1,'N');
END IF;
    IF lx_cust_id IS NULL OR lx_cust_id = FND_API.G_MISS_NUM THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_Acct:l_create_acct_prof: '|| l_create_acct_prof,1,'N');
END IF;
        IF p_calling_api_flag = 1 AND (l_create_acct_prof = 'PLACE_ORDER') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- ER 5484749
	IF p_calling_api_flag = 2 AND (l_create_acct_prof = 'NEVER') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF (l_create_acct_prof = 'ALWAYS') OR
           (l_create_acct_prof = 'AS_REQUIRED' AND p_calling_api_flag = 1) OR
           (p_calling_api_flag = 2) THEN -- ER 5484749
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('creating customer account: create_acct_prof: '||l_create_acct_prof,1,'N');
		  END IF;
            IF p_Party_Id is not NULL
                AND p_Party_Id <> FND_API.G_MISS_NUM THEN
			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('creating cust account',1,'N');
			 END IF;
                ASO_PARTY_INT.Create_Customer_Account(
                    p_api_version   => 1.0,
                    P_Party_id      => p_Party_Id,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    x_cust_acct_id       => cust_account_id);
                IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
                        FND_MESSAGE.Set_Token('ID', to_char(p_Party_Id), FALSE);
                        FND_MSG_PUB.ADD;
                    END IF;
                    raise FND_API.G_EXC_ERROR;
                END IF;
                x_Cust_Acct_Id := cust_account_id;
            END IF; -- end party if
          ELSIF p_calling_api_flag <> 0 THEN -- profile is N raise error
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
                FND_MESSAGE.Set_Token('ID', to_char(p_Party_Id), FALSE);
                FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
         END IF; -- end profile condition

        ELSE  -- lx_cust_id not null

             x_Cust_Acct_Id := lx_cust_id;

        END IF;  -- lx_cust_id

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('x_cust_acct_id = '|| x_cust_acct_id,1,'N');
   END IF;
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Customer_Account;



PROCEDURE Customer_Account_Site
(
p_api_version       IN  NUMBER,
p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
p_commit            IN  VARCHAR2  := FND_API.g_false,
p_party_site_id     IN  NUMBER,
p_acct_site_type    IN  VARCHAR2,
p_cust_account_id   IN  NUMBER,
x_cust_acct_site_id OUT NOCOPY /* file.sql.39 change */  NUMBER,
x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
x_site_use_id       OUT NOCOPY /* file.sql.39 change */  number
)
IS
    CURSOR party_cur IS
        SELECT a.party_type, a.party_id
        from
        HZ_PARTIES a, HZ_PARTY_SITES b
        where
        a.status = 'A'
        and b.status = 'A'
        and b.party_site_id = p_party_site_id
        and b.party_id = a.party_id;

    CURSOR active_site_cur IS
        select cust_acct_site_id, status
        from
        hz_cust_acct_sites
        where
        cust_account_id = p_cust_account_id
        and party_site_id = p_party_site_id
	   and status = 'A';

    CURSOR inactive_site_cur IS
        select cust_acct_site_id, status
        from
        hz_cust_acct_sites
        where
        cust_account_id = p_cust_account_id
        and party_site_id = p_party_site_id
        and status <> 'A';

    CURSOR active_site_use_cur(l_acct_site_id NUMBER, l_site_type VARCHAR2) IS
        select site_use_id, status
        from
        hz_cust_site_uses
        where
        cust_acct_site_id = l_acct_site_id
        and site_use_code = l_site_type
        and status = 'A';

    CURSOR inactive_site_use_cur(l_acct_site_id NUMBER, l_site_type VARCHAR2) IS
        select site_use_id, status
        from
        hz_cust_site_uses
        where
        cust_acct_site_id = l_acct_site_id
        and site_use_code = l_site_type
        and status <> 'A';


/*
    CURSOR site_use_cur(cust_acct NUMBER, party_site NUMBER, site_type VARCHAR2) IS
        select a.site_use_id, b.status,a.status
        from
        hz_cust_site_uses a, hz_cust_acct_sites b
        where
        b.cust_account_id = cust_acct
        and b.party_site_id = party_site
        and a.cust_acct_site_id = b.cust_acct_site_id
        and a.site_use_code = site_type;
*/
    l_party_id number;
    cur_party_id number;
    l_cust_account_id number;
    cust_acct_site_status varchar2(1);
    cust_site_use_status varchar2(1);

    CURSOR  relationship_cur IS
        select a.object_id
        from
        hz_relationships a, hz_cust_accounts  b
        where  a.party_id = l_party_id
        and a.object_id = b.party_id
        and b.cust_account_id = p_cust_account_id;

    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(45) := 'Customer_Account_Site';

    l_party_type VARCHAR2(30);
    l_acct_site_type VARCHAR2(50);
    l_site_use_id number;

    lx_cust_acct_site_id NUMBER;

BEGIN

     ---- Initialize---------------------

     SAVEPOINT CUSTOMER_ACCOUNT_SITE_PVT;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
    ) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('site type in Customer_Account_Site = ' || p_acct_site_type,1,'N');
END IF;

    IF p_acct_site_type = 'END_USER' THEN
        l_acct_site_type := 'SHIP_TO';
    ELSE
        l_acct_site_type := p_acct_site_type;
    END IF;

    OPEN party_cur;
      FETCH party_cur INTO l_party_type, l_party_id;
      IF (party_cur%NOTFOUND) THEN
         l_party_type := NULL;

         x_return_status := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
                   FND_MSG_PUB.ADD;
         END IF;
         raise FND_API.G_EXC_ERROR;
      END IF;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('party_type in Customer_Account_Site = ' || l_party_type,1,'N');
    END IF;
    CLOSE party_cur;

    IF l_party_type = 'PARTY_RELATIONSHIP' THEN
        OPEN relationship_cur;
        FETCH relationship_cur INTO cur_party_id;
        IF (relationship_cur%NOTFOUND) THEN
          cur_party_id := NULL;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
                       FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
        END IF;
        CLOSE relationship_cur;
    ELSE
        cur_party_id := l_party_id;
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('cur_party_id = ' || cur_party_id,1,'N');
    END IF;

    -- bug 4947772
    OPEN active_site_cur;
    FETCH active_site_cur  INTO x_cust_acct_site_id, cust_acct_site_status;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('x_cust_acct_site_id in Customer_Account_Site = ' || x_cust_acct_site_id,1,'N');
    aso_debug_pub.add('Customer_Account_Site: cust_acct_site_status: ' || cust_acct_site_status,1,'N');
    END IF;

    IF active_site_cur%NOTFOUND THEN

      -- this means there are no active sites
         OPEN inactive_site_cur;
         FETCH inactive_site_cur INTO x_cust_acct_site_id, cust_acct_site_status;

         IF inactive_site_cur%FOUND THEN
            x_cust_acct_site_id := NULL;
            x_site_use_id := NULL;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF p_acct_site_type = 'BILL_TO' THEN
               FND_MESSAGE.Set_Name('ASO','ASO_INV_CUST_SITE_INACTIVE');
            ELSIF p_acct_site_type = 'END_USER' THEN
               FND_MESSAGE.Set_Name('ASO','ASO_END_CUST_SITE_INACTIVE');
            ELSIF p_acct_site_type = 'SHIP_TO' THEN
               FND_MESSAGE.Set_Name('ASO','ASO_SHP_CUST_SITE_INACTIVE');
            END IF;
            FND_MSG_PUB.ADD;
	       raise FND_API.G_EXC_ERROR;
          END IF;
          CLOSE inactive_site_cur;
    END IF;  -- active_site_cur%NOTFOUND end if
    CLOSE active_site_cur;




    IF (x_cust_acct_site_id IS NOT NULL) AND
        (x_cust_acct_site_id <> FND_API.G_MISS_NUM) THEN


        OPEN active_site_use_cur(x_cust_acct_site_id, l_acct_site_type);
        FETCH active_site_use_cur INTO x_site_use_id, cust_site_use_status;
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('Customer_Account_Site: cust_site_use_status: ' || cust_site_use_status,1,'N');
        aso_debug_pub.add('Customer_Account_Site: x_site_use_id: ' || x_site_use_id,1,'N');
	   END IF;
        IF (active_site_use_cur%NOTFOUND) THEN
            -- this means there are no active site uses
            OPEN inactive_site_use_cur(x_cust_acct_site_id, l_acct_site_type);
            FETCH inactive_site_use_cur INTO x_site_use_id, cust_site_use_status;
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add(' Inactive Customer_Account_Site: cust_site_use_status: ' || cust_site_use_status,1,'N');
               aso_debug_pub.add(' Inactive Customer_Account_Site: x_site_use_id: ' || x_site_use_id,1,'N');
	    END IF;

            IF inactive_site_use_cur%FOUND THEN
                 x_site_use_id := NULL;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 IF p_acct_site_type = 'BILL_TO' THEN
                    FND_MESSAGE.Set_Name('ASO','ASO_INV_CUST_SITE_INACTIVE');
                 ELSIF p_acct_site_type = 'END_USER' THEN
                    FND_MESSAGE.Set_Name('ASO','ASO_END_CUST_SITE_INACTIVE');
                 ELSIF p_acct_site_type = 'SHIP_TO' THEN
                    FND_MESSAGE.Set_Name('ASO','ASO_SHP_CUST_SITE_INACTIVE');
                 END IF;
                 FND_MSG_PUB.ADD;
                 raise FND_API.G_EXC_ERROR;
             ELSE
               -- this means that there no site uses , either active or inactive
                 x_site_use_id := NULL;
             END IF;
             CLOSE  inactive_site_use_cur;
        END IF;
        CLOSE active_site_use_cur;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('site_use_id in Customer_Account_Site = ' || x_site_use_id,1,'N');
	   END IF;

    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Customer_Account_Site: x_site_use_id: ' || x_site_use_id,1,'N');
    END IF;
    IF x_site_use_id is NULL OR
	   x_site_use_id = FND_API.G_MISS_NUM THEN

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('calling create accsite uses ',1, 'N');
	  END IF;
       ASO_PARTY_INT.Create_ACCT_SITE_USES (
  		  p_api_version     => 1.0
 		 ,P_Cust_Account_Id => p_cust_account_id
 		 ,P_Party_Site_Id   => p_party_site_id
         	 ,P_cust_acct_site_id => x_cust_acct_site_id
           ,P_Acct_Site_type  => l_Acct_Site_Type
		 ,x_cust_acct_site_id => lx_cust_acct_site_id
 		 ,x_return_status   => x_return_status
 		 ,x_msg_count       => x_msg_count
 		 ,x_msg_data        => x_msg_data
 		 ,x_site_use_id     => x_site_use_id
  	   );

	   x_cust_acct_site_id := lx_cust_acct_site_id;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('site_use_id after deriving invoice = ' || x_site_use_id,1, 'Y');
	   END IF;
        IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'ASO_ACCT_SITE_USE');
                      FND_MESSAGE.Set_Token('ID', to_char(p_party_site_id),FALSE);
                      FND_MSG_PUB.ADD;
            END IF;
                raise FND_API.G_EXC_ERROR;
         END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Customer_Account_Site;



PROCEDURE Cust_Acct_Relationship(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
  p_commit            IN  VARCHAR2  := FND_API.g_false,
  p_sold_to_cust_account	IN NUMBER,
  p_related_cust_account	IN NUMBER,
  p_relationship_type		IN VARCHAR2,
  x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ) IS

l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'CUST_ACCT_RELATIONSHIP';

-- TRUE if there are matching row for the cust_account_id and relate_cust_account_id.
l_cust_acct_match VARCHAR2(1) := FND_API.G_FALSE;
-- TRUE if the matching rows also match the bill_to_flag or ship_to_flag.
l_cust_acct_flag_match VARCHAR2(1) := FND_API.G_FALSE;

l_bill_to_flag VARCHAR2(1);
l_ship_to_flag VARCHAR2(1);
l_last_update_date DATE;

CURSOR c_cust_acct_relate IS
  SELECT bill_to_flag, ship_to_flag, last_update_date
  FROM hz_cust_acct_relate
  WHERE cust_account_id = p_related_cust_account
    AND related_cust_account_id = p_sold_to_cust_account
 AND STATUS = 'A';
BEGIN
  ---- Initialize---------------------

   SAVEPOINT CUST_ACCT_RELATIONSHIP_PVT;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
    ) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  x_return_status := FND_API.g_ret_sts_success;
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('Entering cust acct relationship ',1, 'Y');
  END IF;

  OPEN c_cust_acct_relate;
  FETCH c_cust_acct_relate
    INTO l_bill_to_flag, l_ship_to_flag, l_last_update_date;
  IF c_cust_acct_relate%FOUND THEN
    l_cust_acct_match := FND_API.G_TRUE;
  END IF;
  CLOSE c_cust_acct_relate;

  IF FND_API.TO_Boolean(l_cust_acct_match) THEN
    IF (p_relationship_type = 'BILL_TO') AND (l_bill_to_flag = 'Y') THEN
      l_cust_acct_flag_match := FND_API.G_TRUE;
    ELSIF (p_relationship_type = 'SHIP_TO') AND (l_ship_to_flag = 'Y') THEN
      l_cust_acct_flag_match := FND_API.G_TRUE;
    END IF;
  END IF;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('cust acct relationship: l_cust_acct_match is ' || l_cust_acct_match,1, 'N');
  END IF;
  IF NOT FND_API.TO_Boolean(l_cust_acct_flag_match) THEN
    -- no matching rows
      IF NOT FND_API.TO_Boolean(l_cust_acct_match) THEN
        -- the account ids are not matched.
        ASO_PARTY_INT.Create_Cust_Acct_Relationship(

            p_api_version => 1.0,
            p_sold_to_cust_account => p_sold_to_cust_account,
            p_related_cust_account => p_related_cust_account,
            p_relationship_type => p_relationship_type,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
        );
        IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
      /*bug 8239850*/
      IF  FND_API.TO_Boolean(l_cust_acct_match) THEN
     IF NOT FND_API.TO_Boolean(l_cust_acct_flag_match) THEN
     aso_debug_pub.add('before update_Cust_Acct_Relationship: l_cust_acct_match is ' || l_cust_acct_match,1, 'N');
     ASO_PARTY_INT.update_Cust_Acct_Relationship(
            p_api_version => 1.0,
            p_sold_to_cust_account => p_sold_to_cust_account,
            p_related_cust_account => p_related_cust_account,
            p_relationship_type => p_relationship_type,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
        );

     end if;
     end if;
        -- the account ids are matched but bill_to_flag or ship_to_flag is not matched.
        -- and the profile is 'Y'.
	  --- x_return_status := FND_API.G_RET_STS_ERROR;
        --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        --  FND_MESSAGE.Set_Name(' + appShortName +', 'ASO_INVALID_ACCT_RELTN');
         -- FND_MESSAGE.Set_Token('TYPE', p_relationship_type, FALSE);
         -- FND_MSG_PUB.ADD;
      --  END IF;
       -- RAISE FND_API.G_EXC_ERROR;

      END IF;
/*else
 x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name(' + appShortName +', 'ASO_INVALID_ACCT_RELTN');
          FND_MESSAGE.Set_Token('TYPE', p_relationship_type, FALSE);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR; */



  END IF; -- l_cust_acct_flag_match


    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

 END Cust_Acct_Relationship;


PROCEDURE Cust_Acct_Contact_Addr
(
p_api_version       IN  NUMBER,
p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
p_commit            IN  VARCHAR2  := FND_API.g_false,
p_party_site_id     IN  NUMBER,
p_role_type    IN  VARCHAR2,
p_cust_account_id   IN  NUMBER,
p_party_id          IN NUMBER,
p_cust_account_site IN NUMBER,
x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_cust_account_role_id      OUT NOCOPY /* file.sql.39 change */   number
)
IS
l_contact_id  NUMBER;
l_contact_party_id NUMBER;
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'Cust_Acct_Contact_Addr';
l_role_type   VARCHAR2(50);

BEGIN
     ---- Initialize---------------------
     SAVEPOINT CUST_ACCT_CONTACT_ADDR_PVT;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
    ) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_acct_contact_Addr: p_role_type: '||p_role_type,1,'N');
END IF;

IF p_role_type = 'END_USER' THEN
    l_role_type := 'SHIP_TO';
ELSE
    l_role_type := p_role_type;
END IF;

IF p_party_id is not NULL
   AND p_party_id<> FND_API.G_MISS_NUM THEN

   IF p_party_site_id is not NULL AND
       p_party_site_id <> FND_API.G_MISS_NUM THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('deriving cust acct role for party id  ',1,'N');
END IF;

     ASO_MAP_QUOTE_ORDER_INT.get_cust_acct_roles(
             p_party_id  =>p_party_id
            ,p_party_site_id => p_party_site_id
            ,p_acct_site_type => l_role_type
            ,p_cust_account_id => p_cust_account_id
            ,x_return_status => x_return_status
            ,x_party_id      => l_contact_party_id
            ,x_cust_account_role_id => l_contact_id);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('status after get cust acct roles in Cust_Acct_Contact_Addr = ' || x_return_status,1,'N');
END IF;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		IF p_role_type = 'BILL_TO' THEN
          	FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_PARTY_AC_CRS');
          ELSIF p_role_type = 'END_USER' THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_END_PARTY_AC_CRS');
		ELSIF p_role_type = 'SHIP_TO' THEN
          	FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_SHP_PARTY_AC_CRS');
		END IF;
          FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;

      ELSE  -- x_ret_status = success
        IF l_contact_party_id <> FND_API.G_MISS_NUM THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('cust account site = ' ||p_cust_account_site,1,'N');
END IF;
          ASO_PARTY_INT.Create_Contact_Role (
                         p_api_version     => 1.0
                        ,p_party_id      => l_contact_party_id
                        ,p_Cust_account_id   => p_cust_account_id
                        ,p_cust_account_site_id => p_cust_account_site
                        ,p_responsibility_type  => l_role_type
                        ,p_role_id           => l_contact_id
                        ,x_return_status     =>x_return_status
                        ,x_msg_count         => x_msg_count
                        ,x_msg_data        => x_msg_data
                        ,x_cust_account_role_id => x_cust_account_role_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('status after create contact role ship = '|| x_return_status,1,'N');
END IF;

          IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_CREATE_CONTACT');
              FND_MESSAGE.Set_Token('ID', to_char(
                       l_contact_party_id), FALSE);
              FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
          END IF; -- for creatE_contact_role

        END IF; -- for contact_party_id

      END IF; -- x_ret_status

    END IF; -- for party site

  END IF; -- for party id

    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Cust_Acct_Contact_Addr;



PROCEDURE Assign_Customer_Accounts(
    p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
    p_qte_header_id     IN            NUMBER,
    p_calling_api_flag  IN            NUMBER    := 0,
    x_return_status     OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */      VARCHAR2
  )
IS

CURSOR C_Validate_Quote (qte_hdr NUMBER) IS
 SELECT 'X'
 FROM aso_quote_headers_all
 WHERE quote_header_id = qte_hdr;

CURSOR C_Get_Hdr_Acct(qte_hdr NUMBER) IS
 SELECT a.cust_account_id, a.invoice_to_cust_account_id, a.cust_party_id,
        a.invoice_to_cust_party_id, a.party_id, a.sold_to_party_site_id,
        a.invoice_to_party_id, a.invoice_to_party_site_id,
        a.End_Customer_party_id, a.End_Customer_party_site_id,
        a.End_Customer_cust_party_id, a.End_Customer_cust_account_id,
        b.ship_to_party_id, b.ship_to_party_site_id,
        b.ship_to_cust_party_id, b.ship_to_cust_account_id,
        b.shipment_id
 FROM aso_quote_headers_all a, aso_shipments b
 WHERE a.quote_header_id = qte_hdr
 AND a.quote_header_id = b.quote_header_id
 AND b.quote_line_id is NULL;


CURSOR C_Get_Line_Acct(qte_hdr NUMBER) IS
 SELECT a.invoice_to_cust_account_id, a.invoice_to_cust_party_id, a.quote_line_id,
 a.invoice_to_party_id, a.invoice_to_party_site_id,
 a.End_Customer_cust_account_id, a.End_Customer_cust_party_id,
 a.End_Customer_party_id, a.End_Customer_party_site_id,
 b.ship_to_cust_account_id, b.ship_to_cust_party_id, b.shipment_id,
 b.ship_to_party_id, b.ship_to_party_site_id
 FROM aso_quote_lines_all a, aso_shipments b
 WHERE a.quote_header_id = qte_hdr
 AND a.quote_line_id = b.quote_line_id
 AND ((a.invoice_to_cust_account_id IS NULL
       AND a.invoice_to_cust_party_id IS NOT NULL)
 OR  (a.End_Customer_cust_account_id is NULL
       AND a.End_Customer_cust_party_id IS NOT NULL)
 OR  (b.ship_to_cust_account_id is NULL
       AND b.ship_to_cust_party_id IS NOT NULL));

l_end_cust_acct  NUMBER;
l_end_cust_party NUMBER;
l_cust_acct      NUMBER;
l_inv_cust_acct  NUMBER;
l_cust_party     NUMBER;
l_inv_cust_party NUMBER;
l_account_id     NUMBER;
l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_header_shipment_tbl ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_line_shipment_tbl ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_header_check_tca_flag VARCHAR(1) := 'N';
l_dummy          VARCHAR2(1) := NULL;
l_last_update_date date := SYSDATE;
l_g_user_id number :=  fnd_global.user_id;
l_g_login_id number := fnd_global.conc_login_id;
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'Assign_Customer_Accounts';

BEGIN

-- Standard Start of API savepoint
SAVEPOINT Assign_Customer_Accounts_PVT;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts - Begin p_qte_header_id:'|| p_qte_header_id, 1, 'Y');
END IF;

OPEN C_Validate_Quote (p_qte_header_id);
FETCH C_Validate_Quote into l_dummy;
IF C_Validate_Quote%NOTFOUND THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
       FND_MESSAGE.Set_Token('COLUMN', 'ORIGINAL_QUOTE_ID', FALSE);
       FND_MESSAGE.Set_Token('VALUE', TO_CHAR(p_qte_header_id), FALSE);
       FND_MSG_PUB.ADD;
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Assign_Customer_Accounts - Invalid qte_hdr_id', 1, 'Y');
    END IF;

    CLOSE C_Validate_Quote;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE C_Validate_Quote;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts - After qte_hdr_id check', 1, 'Y');
END IF;

OPEN C_Get_Hdr_Acct(p_qte_header_id);
FETCH C_Get_Hdr_Acct INTO
      l_qte_header_rec.cust_account_id,
      l_qte_header_rec.invoice_to_cust_account_id,
      l_qte_header_rec.cust_party_id,
      l_qte_header_rec.invoice_to_cust_party_id,
      l_qte_header_rec.party_id,
      l_qte_header_rec.sold_to_party_site_id,
      l_qte_header_rec.invoice_to_party_id,
      l_qte_header_rec.invoice_to_party_site_id,
      l_qte_header_rec.End_Customer_party_id,
      l_qte_header_rec.End_Customer_party_site_id,
      l_qte_header_rec.End_Customer_cust_party_id,
      l_qte_header_rec.End_Customer_cust_account_id,
      l_header_shipment_tbl(1).ship_to_party_id,
      l_header_shipment_tbl(1).ship_to_party_site_id,
      l_header_shipment_tbl(1).ship_to_cust_party_id,
      l_header_shipment_tbl(1).ship_to_cust_account_id,
      l_header_shipment_tbl(1).shipment_id;
CLOSE C_Get_Hdr_Acct;

 l_end_cust_acct := l_qte_header_rec.End_Customer_cust_account_id;
 l_end_cust_party := l_qte_header_rec.End_Customer_cust_party_id;
 l_cust_acct :=  l_qte_header_rec.cust_account_id;
 l_inv_cust_acct := l_qte_header_rec.invoice_to_cust_account_id;
 l_cust_party  := l_qte_header_rec.cust_party_id;
 l_inv_cust_party :=  l_qte_header_rec.invoice_to_cust_party_id;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts: p_qte_header_id: '||p_qte_header_id, 1, 'N');
aso_debug_pub.add('Assign_Customer_Accounts: p_calling_api_flag: '||p_calling_api_flag, 1, 'N');
aso_debug_pub.add('Assign_Customer_Accounts: l_cust_acct: '||l_cust_acct, 1, 'N');
aso_debug_pub.add('Assign_Customer_Accounts: l_inv_cust_acct: '||l_inv_cust_acct, 1, 'N');
aso_debug_pub.add('Assign_Customer_Accounts: l_cust_party: '||l_cust_party, 1, 'N');
aso_debug_pub.add('Assign_Customer_Accounts: l_inv_cust_party: '||l_inv_cust_party, 1, 'N');
aso_debug_pub.add('Assign_Customer_Accounts: l_end_cust_acct: '||l_end_cust_acct, 1, 'N');
aso_debug_pub.add('Assign_Customer_Accounts: l_end_cust_party: '||l_end_cust_party, 1, 'N');
aso_debug_pub.add('l_qte_header_rec.party_id = ' || l_qte_header_rec.party_id,1,'N');
aso_debug_pub.add('l_qte_header_rec.sold_to_party_site_id = '||l_qte_header_rec.sold_to_party_site_id,1,'N');
aso_debug_pub.add('l_qte_header_rec.invoice_to_party_id = ' || l_qte_header_rec.invoice_to_party_id,1,'N');
aso_debug_pub.add('l_qte_header_rec.invoice_to_party_site_id = '|| l_qte_header_rec.invoice_to_party_site_id,1,'N');
aso_debug_pub.add('l_qte_header_rec.End_Customer_party_id = ' || l_qte_header_rec.End_Customer_party_id,1,'N');
aso_debug_pub.add('l_qte_header_rec.End_Customer_party_site_id = '|| l_qte_header_rec.End_Customer_party_site_id,1,'N');
aso_debug_pub.add('l_header_shipment_tbl.count '|| l_header_shipment_tbl.count,1,'N');
IF l_header_shipment_tbl.count > 0 THEN
aso_debug_pub.add('l_header_shipment_tbl(1).shipment_id = '|| l_header_shipment_tbl(1).shipment_id,1,'N');
aso_debug_pub.add('l_header_shipment_tbl(1).ship_to_party_id = '|| l_header_shipment_tbl(1).ship_to_party_id,1,'N');
aso_debug_pub.add('l_header_shipment_tbl(1).ship_to_party_site_id = '|| l_header_shipment_tbl(1).ship_to_party_site_id,1,'N');
aso_debug_pub.add('l_header_shipment_tbl(1).ship_to_cust_party_id = '||l_header_shipment_tbl(1).ship_to_cust_party_id,1,'N');
aso_debug_pub.add('l_header_shipment_tbl(1).ship_to_cust_account_id = '|| l_header_shipment_tbl(1).ship_to_cust_account_id,1,'N');
END IF;
END IF;

IF l_cust_acct IS NULL THEN
  l_header_check_tca_flag := 'Y';

  IF l_cust_party IS NOT NULL THEN

     ASO_CHECK_TCA_PVT.Customer_Account(
         p_api_version       => 1.0,
         p_Party_Id          => l_cust_party,
         p_calling_api_flag  => p_calling_api_flag,
         x_Cust_Acct_Id      => l_account_id,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts 1: x_return_status: '||x_return_status, 1, 'N');
aso_debug_pub.add('header sold to customer = ' || l_account_id);
END IF;


     IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	  if  NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED')<>'NEVER' then  -- ER 5484749
           FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
           FND_MESSAGE.Set_Token('ID', to_char( l_cust_party), FALSE);
           FND_MSG_PUB.ADD;
          end if;
        END IF;
        raise FND_API.G_EXC_ERROR;

     ELSE

	   UPDATE ASO_QUOTE_HEADERS_ALL
	   SET cust_account_id = l_account_id
              ,last_update_date = l_last_update_date
              ,last_updated_by = l_g_user_id
              ,last_update_login = l_g_login_id
	   WHERE quote_header_id = p_qte_header_id;
        l_qte_header_rec.cust_account_id := l_account_id;


     END IF;

  END IF;

END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('after header sold_to, l_header_check = ' || l_header_check_tca_flag,1,'N');
END IF;


IF l_inv_cust_acct IS NULL THEN
  l_header_check_tca_flag := 'Y';

  IF l_inv_cust_party IS NOT NULL THEN

     ASO_CHECK_TCA_PVT.Customer_Account(
         p_api_version       => 1.0,
         p_Party_Id          => l_inv_cust_party,
         p_calling_api_flag  => p_calling_api_flag,
         x_Cust_Acct_Id      => l_account_id,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts 2: x_return_status: '||x_return_status, 1, 'N');
aso_debug_pub.add('header invoice to account = ' || l_account_id,1,'N');
END IF;


     IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	  if  NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED')<>'NEVER' then  -- ER 5484749
           FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
           FND_MESSAGE.Set_Token('ID', to_char( l_inv_cust_party), FALSE);
           FND_MSG_PUB.ADD;
          end if;
        END IF;
        raise FND_API.G_EXC_ERROR;

     ELSE

        UPDATE ASO_QUOTE_HEADERS_ALL
        SET invoice_to_cust_account_id = l_account_id
              ,last_update_date = l_last_update_date
              ,last_updated_by = l_g_user_id
              ,last_update_login = l_g_login_id

        WHERE quote_header_id = p_qte_header_id;
        l_qte_header_rec.invoice_to_cust_account_id := l_account_id;


     END IF;

  END IF;

END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('after header sold_to, l_header_check = ' || l_header_check_tca_flag,1,'N');
END IF;

IF l_end_cust_acct IS NULL THEN
  l_header_check_tca_flag := 'Y';

  IF l_end_cust_party IS NOT NULL THEN

     ASO_CHECK_TCA_PVT.Customer_Account(
         p_api_version       => 1.0,
         p_Party_Id          => l_end_cust_party,
         p_calling_api_flag  => p_calling_api_flag,
         x_Cust_Acct_Id      => l_account_id,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts 2: x_return_status: '||x_return_status, 1, 'N');
aso_debug_pub.add('header  end customer account = ' || l_account_id,1,'N');
END IF;


     IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	  if  NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED')<>'NEVER' then  -- ER 5484749
           FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
           FND_MESSAGE.Set_Token('ID', to_char( l_end_cust_party), FALSE);
           FND_MSG_PUB.ADD;
          end if;
        END IF;
        raise FND_API.G_EXC_ERROR;

     ELSE

        UPDATE ASO_QUOTE_HEADERS_ALL
        SET end_customer_cust_account_id = l_account_id
              ,last_update_date = l_last_update_date
              ,last_updated_by = l_g_user_id
              ,last_update_login = l_g_login_id
        WHERE quote_header_id = p_qte_header_id;

        l_qte_header_rec.end_customer_cust_account_id := l_account_id;


     END IF;

  END IF;

END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('after header sold_to, l_header_check = ' || l_header_check_tca_flag,1,'N');
END IF;

IF l_header_shipment_tbl.count > 0 THEN

		IF l_header_shipment_tbl(1).ship_to_cust_account_id IS NULL THEN
   			 l_header_check_tca_flag := 'Y';
    			IF l_header_shipment_tbl(1).ship_to_cust_party_id IS NOT NULL THEN

       		ASO_CHECK_TCA_PVT.Customer_Account(
           		p_api_version       => 1.0,
           		p_Party_Id          => l_header_shipment_tbl(1).ship_to_cust_party_id,
           		p_calling_api_flag  => p_calling_api_flag,
           		x_Cust_Acct_Id      => l_account_id,
           		x_return_status     => x_return_status,
           		x_msg_count         => x_msg_count,
           		x_msg_data          => x_msg_data);

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
				aso_debug_pub.add('Assign_Customer_Accounts 4: x_return_status: '||x_return_status, 1, 'N');
				aso_debug_pub.add('header ship to cust party = '||l_header_shipment_tbl(1).ship_to_cust_party_id,1,'N');
                    aso_debug_pub.add('header ship to account = ' || l_account_id,1,'N');
               END IF;

                IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		     if  NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED')<>'NEVER' then  -- ER 5484749
                     FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
                     FND_MESSAGE.Set_Token('ID', to_char( l_header_shipment_tbl(1).ship_to_cust_party_id), FALSE);
                     FND_MSG_PUB.ADD;
                    END IF;
		    end if;
                   raise FND_API.G_EXC_ERROR;

                ELSE
                UPDATE ASO_SHIPMENTS
                SET ship_to_cust_account_id = l_account_id
				   ,last_update_date = l_last_update_date
				  ,last_updated_by = l_g_user_id
				 ,last_update_login = l_g_login_id

               WHERE shipment_id = l_header_shipment_tbl(1).shipment_id;

                l_header_shipment_tbl(1).ship_to_cust_account_id := l_account_id;
               END IF;

    END IF;

  END IF;

END IF; --l_header_shipment_tbl.count

IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('after header sold_to, l_header_check = ' || l_header_check_tca_flag,1,'N');
END IF;



IF l_header_check_tca_flag = 'Y' then
  check_tca(
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            P_Qte_Rec           => l_qte_header_rec,
            p_Header_Shipment_Tbl  => l_header_Shipment_Tbl,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data);
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('after check tca '||x_return_status, 1, 'N');
  END IF;
  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts : checking for lines ', 1, 'N');
end if;

FOR Line_Acct IN C_Get_Line_Acct(p_qte_header_id) LOOP

  l_qte_line_rec := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
  l_line_shipment_tbl :=  ASO_QUOTE_PUB.G_MISS_Shipment_TBL;

  l_qte_line_rec.quote_header_id := p_qte_header_id;
  l_qte_line_rec.invoice_to_cust_account_id := Line_Acct.invoice_to_cust_account_id;
  l_qte_line_rec.invoice_to_party_site_id := Line_Acct.invoice_to_party_site_id;
  l_qte_line_rec.invoice_to_cust_party_id := Line_Acct.invoice_to_cust_party_id;
  l_qte_line_rec.invoice_to_party_id := Line_Acct.invoice_to_party_id;
  l_qte_line_rec.quote_line_id := Line_Acct.quote_line_id;

  l_qte_line_rec.End_Customer_cust_account_id := Line_Acct.End_Customer_cust_account_id;
  l_qte_line_rec.End_Customer_party_site_id := Line_Acct.End_Customer_party_site_id;
  l_qte_line_rec.End_Customer_cust_party_id := Line_Acct.End_Customer_cust_party_id;
  l_qte_line_rec.End_Customer_party_id := Line_Acct.End_Customer_party_id;

  l_line_shipment_tbl(1).ship_to_cust_account_id :=  Line_Acct.ship_to_cust_account_id;
  l_line_shipment_tbl(1).ship_to_cust_party_id :=   Line_Acct.ship_to_cust_party_id;
  l_line_shipment_tbl(1).ship_to_party_id :=  Line_Acct.ship_to_party_id;
  l_line_shipment_tbl(1).ship_to_party_site_id :=  Line_Acct.ship_to_party_site_id;
  l_line_shipment_tbl(1).shipment_id :=  Line_Acct.shipment_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_qte_line_rec.quote_line_id = '|| l_qte_line_rec.quote_line_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.invoice_to_cust_account_id = '|| l_qte_line_rec.invoice_to_cust_account_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.invoice_to_party_site_id = '|| l_qte_line_rec.invoice_to_party_site_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.invoice_to_cust_party_id = ' || l_qte_line_rec.invoice_to_cust_party_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.invoice_to_party_id = ' || l_qte_line_rec.invoice_to_party_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.End_Customer_cust_account_id = '|| l_qte_line_rec.End_Customer_cust_account_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.End_Customer_party_site_id = '|| l_qte_line_rec.End_Customer_party_site_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.End_Customer_cust_party_id = ' || l_qte_line_rec.End_Customer_cust_party_id,1,'N');
aso_debug_pub.add('l_qte_line_rec.End_Customer_party_id = ' || l_qte_line_rec.End_Customer_party_id,1,'N');
aso_debug_pub.add('l_line_shipment_tbl(1).shipment_id = ' || l_line_shipment_tbl(1).shipment_id,1,'N');
aso_debug_pub.add('l_line_shipment_tbl(1).ship_to_cust_account_id = '|| l_line_shipment_tbl(1).ship_to_cust_account_id,1,'N');
aso_debug_pub.add('l_line_shipment_tbl(1).ship_to_cust_party_id = '|| l_line_shipment_tbl(1).ship_to_cust_party_id,1,'N');
aso_debug_pub.add('l_line_shipment_tbl(1).ship_to_party_id = '|| l_line_shipment_tbl(1).ship_to_party_id,1,'N');
aso_debug_pub.add('l_line_shipment_tbl(1).ship_to_party_site_id = '|| l_line_shipment_tbl(1).ship_to_party_site_id,1,'N');
end if;


  IF l_qte_line_rec.invoice_to_cust_account_id IS NULL THEN
    IF l_qte_line_rec.invoice_to_cust_party_id IS NOT NULL THEN

      ASO_CHECK_TCA_PVT.Customer_Account(
          p_api_version       => 1.0,
          p_Party_Id          => l_qte_line_rec.invoice_to_cust_party_id,
          p_calling_api_flag  => p_calling_api_flag,
          x_Cust_Acct_Id      => l_account_id,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts 3: x_return_status: '||x_return_status, 1, 'N');
aso_debug_pub.add('line invoice to customer party = ' ||
                   l_qte_line_rec.invoice_to_cust_party_id,1,'N');

aso_debug_pub.add('line invoice to customer account = ' ||
                   l_account_id,1,'N');
END IF;

      IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   if  NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED')<>'NEVER' then  -- ER 5484749
            FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
            FND_MESSAGE.Set_Token('ID', to_char( l_qte_line_rec.invoice_to_cust_party_id), FALSE);
            FND_MSG_PUB.ADD;
           end if;
         END IF;
         raise FND_API.G_EXC_ERROR;

      ELSE

        UPDATE ASO_QUOTE_LINES_ALL
        SET invoice_to_cust_account_id = l_account_id
				 ,last_update_date = l_last_update_date
				,last_updated_by = l_g_user_id
			    ,last_update_login = l_g_login_id

        WHERE quote_line_id = l_qte_line_rec.quote_line_id;

        l_qte_line_rec.invoice_to_cust_account_id := l_account_id;

      END IF;

    END IF;

  END IF;

  IF l_qte_line_rec.End_Customer_cust_account_id IS NULL THEN
    IF l_qte_line_rec.End_Customer_cust_party_id IS NOT NULL THEN

      ASO_CHECK_TCA_PVT.Customer_Account(
          p_api_version       => 1.0,
          p_Party_Id          => l_qte_line_rec.End_Customer_cust_party_id,
          p_calling_api_flag  => p_calling_api_flag,
          x_Cust_Acct_Id      => l_account_id,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts 3: x_return_status: '||x_return_status, 1, 'N');
aso_debug_pub.add('line End_Customer customer party = ' ||
                   l_qte_line_rec.End_Customer_cust_party_id,1,'N');

aso_debug_pub.add('line End_Customer customer account = ' ||
                   l_account_id,1,'N');
END IF;

      IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	  if  NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED')<>'NEVER' then  -- ER 5484749
            FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
            FND_MESSAGE.Set_Token('ID', to_char( l_qte_line_rec.End_Customer_cust_party_id), FALSE);
            FND_MSG_PUB.ADD;
          end if;
         END IF;
         raise FND_API.G_EXC_ERROR;

      ELSE

        UPDATE ASO_QUOTE_LINES_ALL
        SET End_Customer_cust_account_id = l_account_id
                     ,last_update_date = l_last_update_date
                    ,last_updated_by = l_g_user_id
                   ,last_update_login = l_g_login_id
        WHERE quote_line_id = l_qte_line_rec.quote_line_id;

        l_qte_line_rec.End_Customer_cust_account_id := l_account_id;

      END IF;

    END IF;

  END IF;

  IF Line_Acct.ship_to_cust_account_id IS NULL THEN

    IF Line_Acct.ship_to_cust_party_id IS NOT NULL THEN

       ASO_CHECK_TCA_PVT.Customer_Account(
           p_api_version       => 1.0,
           p_Party_Id          => Line_Acct.ship_to_cust_party_id,
           p_calling_api_flag  => p_calling_api_flag,
           x_Cust_Acct_Id      => l_account_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts 4: x_return_status: '||x_return_status, 1, 'N');
aso_debug_pub.add('line ship to customer party = ' ||
                   Line_Acct.ship_to_cust_party_id,1,'N');

aso_debug_pub.add('line ship to customer account = ' ||
                   l_account_id,1,'N');
END IF;

       IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    if  NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED')<>'NEVER' then  -- ER 5484749
             FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
             FND_MESSAGE.Set_Token('ID', to_char( Line_Acct.ship_to_cust_party_id), FALSE);
             FND_MSG_PUB.ADD;
            end if;
          END IF;
          raise FND_API.G_EXC_ERROR;

       ELSE

          UPDATE ASO_SHIPMENTS
          SET ship_to_cust_account_id = l_account_id
				   ,last_update_date = l_last_update_date
				  ,last_updated_by = l_g_user_id
				 ,last_update_login = l_g_login_id

          WHERE shipment_id = Line_Acct.shipment_id;

          l_line_shipment_tbl(1).ship_to_cust_account_id := l_account_id;

       END IF;

    END IF;

  END IF;

  Check_Line_Account_Info(
                p_api_version       => 1.0,
                p_cust_account_id   => l_qte_header_rec.cust_account_id,
                p_qte_line_rec      => l_qte_line_rec,
                p_line_shipment_tbl => l_line_shipment_tbl,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('after check line account info '||x_return_status, 1, 'N
');
  END IF;
  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


END LOOP;  -- line_Acct






IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Assign_Customer_Accounts: End ', 1, 'N');
END IF;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Assign_Customer_Accounts;



PROCEDURE Populate_Acct_Party (
    p_init_msg_list     IN      VARCHAR2  := FND_API.G_FALSE,
    p_hdr_cust_acct_id  IN      NUMBER,
    p_hdr_party_id      IN      NUMBER,
    p_party_site_id     IN      NUMBER,
    p_cust_account_id   IN OUT NOCOPY  NUMBER,
    p_cust_party_id     IN OUT NOCOPY  NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */      VARCHAR2
  )

IS

   CURSOR C_Get_Party_From_Acct(acct_id NUMBER) IS
     SELECT party_id
     FROM HZ_CUST_ACCOUNTS
     WHERE cust_account_id = acct_id
     AND status = 'A'
     AND sysdate BETWEEN NVL(account_activation_date, sysdate) AND NVL(account_termination_date, sysdate);

   l_inv_cust_id    NUMBER := NULL;

BEGIN

    IF p_cust_account_id is not NULL AND
       p_cust_account_id <> FND_API.G_MISS_NUM THEN
        IF p_cust_party_id IS NULL OR
           p_cust_party_id = FND_API.G_MISS_NUM THEN

            OPEN C_Get_Party_From_Acct(p_cust_account_id);
            FETCH C_Get_Party_From_Acct INTO p_cust_party_id;
            CLOSE C_Get_Party_From_Acct;

        ELSE

            OPEN C_Get_Party_From_Acct(p_cust_account_id);
            FETCH C_Get_Party_From_Acct INTO l_inv_cust_id;
            CLOSE C_Get_Party_From_Acct;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Hdr_Acct: l_inv_cust_id: '|| l_inv_cust_id, 1, 'N');
END IF;
            IF l_inv_cust_id <> p_cust_party_id THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'CUST_PARTY_ID',FALSE);
                    FND_MESSAGE.Set_Token('VALUE', to_char(p_cust_party_id),FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
                raise FND_API.G_EXC_ERROR;
            END IF;

        END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Hdr_Acct: p_cust_party_id:1: '|| p_cust_party_id, 1, 'N');
END IF;

    ELSE  -- inv_to_cust_acct_id is null

        IF p_cust_party_id IS NULL OR
           p_cust_party_id = FND_API.G_MISS_NUM THEN
            IF p_party_site_id IS NOT NULL AND
               p_party_site_id <> FND_API.G_MISS_NUM THEN

                p_cust_account_id := p_hdr_cust_acct_id;
                p_cust_party_id := p_hdr_party_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Check_Hdr_Acct: p_cust_account_id: '|| p_cust_account_id, 1, 'N');
aso_debug_pub.add('Check_Hdr_Acct: p_cust_party_id:2: '|| p_cust_party_id, 1, 'N');
END IF;

            END IF;
        END IF;

    END IF;  -- inv_to_cust_acct_id


END Populate_Acct_Party;


PROCEDURE Check_Customer_Accounts(
    p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
    p_qte_header_id     IN            NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  )
IS

CURSOR C_Validate_Quote (qte_hdr NUMBER) IS
 SELECT 'X'
 FROM aso_quote_headers_all
 WHERE quote_header_id = qte_hdr;

CURSOR C_Get_Hdr_CustAcct (qte_hdr NUMBER) IS
 SELECT cust_party_id
 FROM aso_quote_headers_all
 WHERE quote_header_id = qte_hdr
 AND (cust_account_id IS NULL
      AND cust_party_id IS NOT NULL);

CURSOR C_Get_Hdr_InvCustAcct (qte_hdr NUMBER) IS
 SELECT invoice_to_cust_party_id
 FROM aso_quote_headers_all
 WHERE quote_header_id = qte_hdr
 AND (invoice_to_cust_account_id IS NULL
      AND invoice_to_cust_party_id IS NOT NULL);

CURSOR C_Get_Hdr_EndCustAcct (qte_hdr NUMBER) IS
 SELECT End_Customer_cust_party_id
 FROM aso_quote_headers_all
 WHERE quote_header_id = qte_hdr
 AND (End_Customer_cust_account_id IS NULL
      AND End_Customer_cust_party_id IS NOT NULL);

CURSOR C_Get_Line_Acct (qte_hdr NUMBER) IS
 SELECT invoice_to_cust_party_id
 FROM aso_quote_lines_all
 WHERE quote_header_id = qte_hdr
 AND invoice_to_cust_account_id IS NULL
 AND invoice_to_cust_party_id IS NOT NULL;

CURSOR C_Get_Line_EndCustAcct (qte_hdr NUMBER) IS
 SELECT End_Customer_cust_party_id
 FROM aso_quote_lines_all
 WHERE quote_header_id = qte_hdr
 AND End_Customer_cust_account_id IS NULL
 AND End_Customer_cust_party_id IS NOT NULL;

CURSOR C_Get_Ship_Acct (qte_hdr NUMBER) IS
 SELECT ship_to_cust_party_id
 FROM aso_shipments
 WHERE quote_header_id = qte_hdr
 AND ship_to_cust_account_id IS NULL
 AND ship_to_cust_party_id IS NOT NULL;

CURSOR C_Chk_Party_Acct (pty_id NUMBER) IS
 SELECT cust_account_id
 FROM hz_cust_accounts
 WHERE party_id = pty_id
 AND status = 'A'
 AND sysdate BETWEEN NVL(account_activation_date, sysdate) AND NVL(account_termination_date, sysdate);

l_create_acct_prof  VARCHAR2(30) := NVL(FND_PROFILE.Value('ASO_AUTO_ACCOUNT_CREATE'), 'AS_REQUIRED');
l_dummy             VARCHAR2(1) := NULL;
l_party             NUMBER := NULL;
l_cust_acct         NUMBER := NULL;
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'Check_Customer_Accounts';

BEGIN

-- Standard Start of API savepoint
SAVEPOINT Check_Customer_Accounts_INT;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts - Begin', 1, 'Y');
END IF;

OPEN C_Validate_Quote (p_qte_header_id);
FETCH C_Validate_Quote into l_dummy;
IF C_Validate_Quote%NOTFOUND THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
       FND_MESSAGE.Set_Token('COLUMN', 'ORIGINAL_QUOTE_ID', FALSE);
       FND_MESSAGE.Set_Token('VALUE', TO_CHAR(p_qte_header_id), FALSE);
       FND_MSG_PUB.ADD;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Check_Customer_Accounts - Invalid qte_hdr_id', 1, 'Y');
    END IF;

    CLOSE C_Validate_Quote;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE C_Validate_Quote;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts - After qte_hdr_id check', 1, 'Y');
  aso_debug_pub.add('Check_Customer_Accounts - l_create_acct_prof: '||l_create_acct_prof, 1, 'N');
END IF;

l_party := NULL;
l_cust_acct := NULL;

IF (l_create_acct_prof = 'PLACE_ORDER' or l_create_acct_prof = 'NEVER') THEN -- ER 5484749

    OPEN C_Get_Hdr_CustAcct(p_qte_header_id);
    FETCH C_Get_Hdr_CustAcct INTO l_party;
    CLOSE C_Get_Hdr_CustAcct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:hdr_CustAcct - l_party: '||l_party, 1, 'N');
END IF;

    IF l_party IS NOT NULL AND l_party <> FND_API.G_MISS_NUM THEN

        OPEN C_Chk_Party_Acct (l_party);
        FETCH C_Chk_Party_Acct INTO l_cust_acct;
        CLOSE C_Chk_Party_Acct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:hdr_CustAcct - l_cust_acct: '||l_cust_acct, 1, 'N');
END IF;

        IF l_cust_acct IS NULL OR l_cust_acct = FND_API.G_MISS_NUM THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

l_party := NULL;
l_cust_acct := NULL;

    OPEN C_Get_Hdr_InvCustAcct(p_qte_header_id);
    FETCH C_Get_Hdr_InvCustAcct INTO l_party;
    CLOSE C_Get_Hdr_InvCustAcct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:hdr_InvCustAcct - l_party: '||l_party, 1, 'N');
END IF;

    IF l_party IS NOT NULL AND l_party <> FND_API.G_MISS_NUM THEN

        OPEN C_Chk_Party_Acct (l_party);
        FETCH C_Chk_Party_Acct INTO l_cust_acct;
        CLOSE C_Chk_Party_Acct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:hdr_InvCustAcct - l_cust_acct: '||l_cust_acct, 1, 'N');
END IF;

        IF l_cust_acct IS NULL OR l_cust_acct = FND_API.G_MISS_NUM THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

l_party := NULL;
l_cust_acct := NULL;

    OPEN C_Get_Hdr_EndCustAcct(p_qte_header_id);
    FETCH C_Get_Hdr_EndCustAcct INTO l_party;
    CLOSE C_Get_Hdr_EndCustAcct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:hdr_EndCustAcct - l_party: '||l_party, 1, 'N');
END IF;

    IF l_party IS NOT NULL AND l_party <> FND_API.G_MISS_NUM THEN

        OPEN C_Chk_Party_Acct (l_party);
        FETCH C_Chk_Party_Acct INTO l_cust_acct;
        CLOSE C_Chk_Party_Acct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:hdr_EndCustAcct - l_cust_acct: '||l_cust_acct, 1, 'N');
END IF;

        IF l_cust_acct IS NULL OR l_cust_acct = FND_API.G_MISS_NUM THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;


FOR Line_Acct IN C_Get_Line_Acct(p_qte_header_id) LOOP

l_party := NULL;
l_cust_acct := NULL;
l_party := Line_Acct.invoice_to_cust_party_id;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:line_Acct - l_party: '||l_party, 1, 'N');
END IF;

    IF l_party IS NOT NULL AND l_party <> FND_API.G_MISS_NUM THEN

        OPEN C_Chk_Party_Acct (l_party);
        FETCH C_Chk_Party_Acct INTO l_cust_acct;
        CLOSE C_Chk_Party_Acct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:lin_Acct - l_cust_acct: '||l_cust_acct, 1, 'N');
END IF;

        IF l_cust_acct IS NULL OR l_cust_acct = FND_API.G_MISS_NUM THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

END LOOP;


FOR Line_EndCustAcct IN C_Get_Line_EndCustAcct(p_qte_header_id) LOOP

l_party := NULL;
l_cust_acct := NULL;
l_party := Line_EndCustAcct.End_Customer_cust_party_id;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:line_EndCustAcct - l_party: '||l_party, 1, 'N');
END IF;

    IF l_party IS NOT NULL AND l_party <> FND_API.G_MISS_NUM THEN

        OPEN C_Chk_Party_Acct (l_party);
        FETCH C_Chk_Party_Acct INTO l_cust_acct;
        CLOSE C_Chk_Party_Acct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:lin_EndCustAcct - l_cust_acct: '||l_cust_acct, 1, 'N');
END IF;

        IF l_cust_acct IS NULL OR l_cust_acct = FND_API.G_MISS_NUM THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

END LOOP;


FOR Ship_Acct IN C_Get_Ship_Acct(p_qte_header_id) LOOP

l_party := NULL;
l_cust_acct := NULL;
l_party := Ship_Acct.ship_to_cust_party_id;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:shp_Acct - l_party: '||l_party, 1, 'N');
END IF;

    IF l_party IS NOT NULL AND l_party <> FND_API.G_MISS_NUM THEN

        OPEN C_Chk_Party_Acct (l_party);
        FETCH C_Chk_Party_Acct INTO l_cust_acct;
        CLOSE C_Chk_Party_Acct;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts:shp_Acct - l_cust_acct: '||l_cust_acct, 1, 'N');
END IF;

        IF l_cust_acct IS NULL OR l_cust_acct = FND_API.G_MISS_NUM THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_CREATE_ACCOUNT');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

END LOOP;

END IF; -- 'Place Order'

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts: End ', 1, 'N');
END IF;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Check_Customer_Accounts;



END ASO_CHECK_TCA_PVT;

/
