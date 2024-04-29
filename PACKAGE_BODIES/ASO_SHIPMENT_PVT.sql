--------------------------------------------------------
--  DDL for Package Body ASO_SHIPMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SHIPMENT_PVT" as
/* $Header: asovshpb.pls 120.3.12010000.6 2016/04/05 12:23:09 akushwah ship $ */
--
-- NAME
-- ASO_SHIPMENT_PVT
--
-- HISTORY
--

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_SHIPMENT_PVT';

PROCEDURE Delete_shipment(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_qte_line_rec               IN   aso_quote_pub.qte_line_rec_type
				:= ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    )
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Delete_quote';
    l_api_version_number      CONSTANT NUMBER   := 1.0;

    CURSOR c_freight_charges IS
	SELECT FREIGHT_CHARGE_ID FROM aso_freight_charges
	WHERE QUOTE_SHIPMENT_ID = p_shipment_rec.shipment_id;

    l_return_status	VARCHAR2(240);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SHIPMENT_PVT;

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

      --
      -- Api body
      --
      IF p_shipment_rec.reservation_id <> FND_API.G_MISS_NUM AND
	 p_shipment_rec.reservation_id IS NOT NULL THEN
        ASO_RESERVATION_INT.Delete_Reservation(
		P_Api_Version_Number	=> 1.0,
		P_Init_Msg_List         => FND_API.G_FALSE,
		P_Commit                => FND_API.G_FALSE,
		P_line_Rec		=> p_qte_line_rec,
		p_shipment_rec		=> p_shipment_rec,
		X_Return_Status         => l_Return_Status,
		X_Msg_Count             => X_Msg_Count,
		X_Msg_Data              => X_Msg_Data);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_DELETE_RSV');
	    FND_MSG_PUB.ADD;
	  END IF;
	END IF;
      END IF;

      FOR freight_rec IN c_freight_charges LOOP
	ASO_FREIGHT_CHARGES_PKG.Delete_Row(
		p_FREIGHT_CHARGE_ID => freight_rec.FREIGHT_CHARGE_ID);
      END LOOP;
      -- Invoke table handler(ASO_SHIPMENTS_PKG.Delete_Row)
      ASO_SHIPMENTS_PKG.Delete_Row(
          p_SHIPMENT_ID  => p_shipment_rec.shipment_id);



      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
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
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
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
End Delete_Shipment;


FUNCTION Get_invoice_to_party_site_id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER
		) RETURN NUMBER
IS
    CURSOR c_inv_site1 IS
	SELECT invoice_to_party_site_id FROM ASO_quote_lines_All
	WHERE	quote_line_id = p_qte_line_id
    AND quote_header_id = p_qte_header_id;

    CURSOR c_inv_site2 IS
	SELECT invoice_to_party_site_id FROM ASO_quote_headers_All
	WHERE	quote_header_id = p_qte_header_id;

    l_inv_site_id		NUMBER;

  cursor c_root_model_line_id is
  select /*+ index(ASO_QUOTE_LINE_DETAILS ASO_QUOTE_LINE_DETAILS_N5)*/ quote_line_id -- bug 18612485
  from aso_quote_line_details
  where (config_header_id, config_revision_num) = (select config_header_id,config_revision_num
                                                   from aso_quote_line_details
                                                   where quote_line_id = p_qte_line_id)
  and ref_type_code = 'CONFIG'
  and ref_line_id  is null;

  cursor c_item_type_code is
  select item_type_code
  from aso_quote_lines_all
  where quote_line_id = p_qte_line_id;

  l_model_quote_line_id    NUMBER;
  l_item_type_code         VARCHAR2(30);

BEGIN
    OPEN c_inv_site1;
    FETCH c_inv_site1 INTO l_inv_site_id;

    IF c_inv_site1%FOUND and l_inv_site_id IS NOT NULL and l_inv_site_id <> FND_API.G_MISS_NUM THEN

	    CLOSE c_inv_site1;
	    return l_inv_site_id;

    ELSE

         CLOSE c_inv_site1;

         open  c_item_type_code;
         fetch c_item_type_code into l_item_type_code;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Get_invoice_to_party_site_id: c_item_type_code: l_item_type_code: '||l_item_type_code);
	    END IF;

         IF c_item_type_code%FOUND and l_item_type_code = 'CFG' THEN

              close c_item_type_code;

              open  c_root_model_line_id;
              fetch c_root_model_line_id into l_model_quote_line_id;

		    IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Get_invoice_to_party_site_id: c_root_model_line_id: l_model_quote_line_id: ' ||l_model_quote_line_id);
		    END IF;

              IF c_root_model_line_id%FOUND and l_model_quote_line_id is not null THEN

                  close c_root_model_line_id;

                  l_inv_site_id := Get_invoice_to_party_site_id(p_qte_header_id, l_model_quote_line_id);

			   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Get_invoice_to_party_site_id: Model l_inv_site_id: '||l_inv_site_id);
			   END IF;

                  return l_inv_site_id;

              END IF; --c_root_model_line_id

              close c_root_model_line_id;

         END IF; --c_item_type_code

    END IF;


    OPEN c_inv_site2;
    FETCH c_inv_site2 INTO l_inv_site_id;

    IF c_inv_site2%FOUND and l_inv_site_id IS NOT NULL and l_inv_site_id <> FND_API.G_MISS_NUM THEN

	    CLOSE c_inv_site2;
	    return l_inv_site_id;

    END IF; --c_inv_site2

    return l_inv_site_id;

END Get_invoice_to_party_site_id;


-- Function for getting the site_use_id based on Cust Account ID
FUNCTION Get_cust_to_party_site_id ( p_qte_header_id		NUMBER,
		                           p_qte_line_id		NUMBER
		) RETURN NUMBER
IS

    CURSOR c_inv_site1 IS
    SELECT invoice_to_party_site_id FROM ASO_quote_lines_All
    WHERE	quote_line_id = p_qte_line_id
    AND quote_header_id = p_qte_header_id;

    CURSOR c_inv_site2 IS
    SELECT invoice_to_party_site_id FROM ASO_quote_headers_All
    WHERE	quote_header_id = p_qte_header_id;

    l_inv_site_id		NUMBER;
    l_ship_site_id		NUMBER;
    l_bill_site_use_id  NUMBER;

    CURSOR c_cust_id IS
    SELECT cust_account_id FROM ASO_QUOTE_HEADERS_ALL
    WHERE quote_header_id = p_qte_header_id;

    CURSOR C_site_use(l_cust_id NUMBER, l_inv_site_id NUMBER) IS
    SELECT site_use_id
    FROM hz_cust_site_uses b,hz_cust_acct_sites a
    WHERE b.cust_acct_site_id = a.cust_acct_site_id
    AND b.site_use_code = 'BILL_TO' --and b.primary_flag = 'Y'
    AND a.party_site_id = l_inv_site_id
    AND a.cust_account_id = l_cust_id;

   CURSOR c_inv_cust_id IS
   SELECT INVOICE_TO_CUST_ACCOUNT_ID FROM ASO_QUOTE_LINES_ALL
   WHERE quote_header_id = p_qte_header_id and quote_line_id =p_qte_line_id ;

    CURSOR c_inv_cust_id1 IS
    SELECT INVOICE_TO_CUST_ACCOUNT_ID FROM ASO_QUOTE_HEADERS_ALL
    WHERE quote_header_id = p_qte_header_id ;

    l_cust_id NUMBER;
    p_shipment_id	NUMBER := NULL;

  cursor c_item_type_code is
  select item_type_code
  from aso_quote_lines_all
  where quote_line_id = p_qte_line_id;

  cursor c_root_model_line_id is
 select /*+ index(ASO_QUOTE_LINE_DETAILS ASO_QUOTE_LINE_DETAILS_N5)*/ quote_line_id -- bug 18612485
  from aso_quote_line_details
  where (config_header_id, config_revision_num) = (select config_header_id,config_revision_num
                                                   from aso_quote_line_details
                                                   where quote_line_id = p_qte_line_id)
  and ref_type_code = 'CONFIG'
  and ref_line_id  is null;


  l_model_quote_line_id    NUMBER;
  l_item_type_code         VARCHAR2(30);

BEGIN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_SHIPMENT_PVT: Get_cust_to_party_site_id: Begin');
    END IF;

    OPEN c_inv_site1;
    FETCH c_inv_site1 INTO l_inv_site_id;

    IF c_inv_site1%FOUND AND l_inv_site_id IS NOT NULL and l_inv_site_id <> FND_API.G_MISS_NUM  THEN

	         CLOSE c_inv_site1;

    	    OPEN c_inv_cust_id;
           FETCH c_inv_cust_id into l_cust_id;

           IF c_inv_cust_id%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

                CLOSE c_inv_cust_id;

                OPEN c_inv_cust_id1;
                FETCH c_inv_cust_id1 into l_cust_id;

                IF c_inv_cust_id1%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

                    CLOSE c_inv_cust_id1;

                    --Get the Customer Account from the header

                    OPEN c_cust_id;
                    FETCH c_cust_id INTO l_cust_id;
                    CLOSE c_cust_id;

                    OPEN C_site_use(l_cust_id , l_inv_site_id);
                    FETCH C_site_use into l_bill_site_use_id;
                    CLOSE C_site_use;

                    return l_bill_site_use_id;

                END IF;

                CLOSE c_inv_cust_id1;

                OPEN C_site_use(l_cust_id , l_inv_site_id);
                FETCH C_site_use into l_bill_site_use_id;
                CLOSE C_site_use;
                return l_bill_site_use_id;

            END IF;

            CLOSE c_inv_cust_id;

            --Get the site use id from the HZ_cust_site_uses

            OPEN C_site_use(l_cust_id , l_inv_site_id);
            FETCH C_site_use into l_bill_site_use_id;
            CLOSE C_site_use;

            return l_bill_site_use_id;

    ELSE

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
	             aso_debug_pub.add('Get_cust_to_party_site_id: Else c_inv_site1');
               END IF;

	          CLOSE c_inv_site1;

	          open  c_item_type_code;
	          fetch c_item_type_code into l_item_type_code;

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
	             aso_debug_pub.add('Get_cust_to_party_site_id: c_item_type_code: l_item_type_code: '||l_item_type_code);
               END IF;

	          IF c_item_type_code%FOUND and l_item_type_code = 'CFG' THEN

		          close c_item_type_code;

		          open  c_root_model_line_id;
		          fetch c_root_model_line_id into l_model_quote_line_id;

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
		             aso_debug_pub.add('Get_cust_to_party_site_id: c_root_model_line_id: l_model_quote_line_id: '||l_model_quote_line_id);
                    END IF;

		          IF c_root_model_line_id%FOUND and l_model_quote_line_id is not null THEN

		               close c_root_model_line_id;

			          l_bill_site_use_id := Get_cust_to_party_site_id(p_qte_header_id, l_model_quote_line_id);

			          return l_bill_site_use_id;

                 END IF; --c_root_model_line_id

                 close c_root_model_line_id;
			 -- Start : code change done for Bug 23054502
              Else
			     close c_item_type_code;
			 -- End : code change done for Bug 23054502
			  END IF; --c_item_type_code

    END IF; --c_inv_site1


    OPEN c_inv_site2;
    FETCH c_inv_site2 INTO l_inv_site_id;

    IF c_inv_site2%FOUND  AND l_inv_site_id IS NOT NULL and l_inv_site_id <> FND_API.G_MISS_NUM  THEN

	       CLOSE c_inv_site2;

    	  OPEN c_inv_cust_id;
         FETCH c_inv_cust_id into l_cust_id;

         IF c_inv_cust_id%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

              CLOSE c_inv_cust_id;
              OPEN c_inv_cust_id1;
              FETCH c_inv_cust_id1 into l_cust_id;

              IF c_inv_cust_id1%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

                   CLOSE c_inv_cust_id1;

                   --Get the Customer Account from the header
                   OPEN c_cust_id;
                   FETCH c_cust_id INTO l_cust_id;
                   CLOSE c_cust_id;

                   OPEN C_site_use(l_cust_id , l_inv_site_id);
                   FETCH C_site_use into l_bill_site_use_id;
                   CLOSE C_site_use;

                   return l_bill_site_use_id;

              END IF; --c_inv_cust_id1

              CLOSE c_inv_cust_id1;

              OPEN C_site_use(l_cust_id , l_inv_site_id);
              FETCH C_site_use into l_bill_site_use_id;
              CLOSE C_site_use;

              return l_bill_site_use_id;

         END IF; --c_inv_cust_id

         CLOSE c_inv_cust_id;

         --Get the site use id from the HZ_cust_site_uses

         OPEN C_site_use(l_cust_id , l_inv_site_id);
         FETCH C_site_use into l_bill_site_use_id;
         CLOSE C_site_use;

         return l_bill_site_use_id;

    END IF; --c_inv_site2

    close c_inv_site2;

    return l_bill_site_use_id;

END Get_cust_to_party_site_id;



FUNCTION Get_Ship_To_site_Id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN NUMBER
IS
    CURSOR c_ship_site1 IS
	SELECT ship_to_party_site_id, SHIP_TO_CUST_ACCOUNT_ID  FROM ASO_SHIPMENTS
	WHERE	shipment_id = p_shipment_id AND quote_line_id =
p_qte_line_id AND quote_header_id = p_qte_header_id;

   /* Commented for Bug 12938390(11i Bug 10253993)
    -- performance fix for bug 5596369
    CURSOR c_ship_site2 IS
	SELECT ship_to_party_site_id , SHIP_TO_CUST_ACCOUNT_ID
	FROM ASO_SHIPMENTS
     WHERE quote_header_id = p_qte_header_id
     and shipment_id =p_shipment_id
     AND   quote_line_id IS NULL;
*/

/* Cursor c_ship_site2 modified for Bug 12938390 (11i Bug 10253993) */
    CURSOR c_ship_site2(p_ship_id Number) IS
	SELECT ship_to_party_site_id , SHIP_TO_CUST_ACCOUNT_ID
	FROM   ASO_SHIPMENTS
	WHERE  quote_header_id = p_qte_header_id
	AND    shipment_id     = p_ship_id
	AND    quote_line_id IS NULL;

    l_ship_site_id		NUMBER;
    l_ship_cust_acct_id		NUMBER;
    l_ship_site_use_id  NUMBER;
    CURSOR c_cust_id IS
    SELECT cust_account_id  FROM ASO_QUOTE_HEADERS_ALL
    WHERE quote_header_id = p_qte_header_id;

   CURSOR c_ship_cust_id IS
    SELECT SHIP_TO_CUST_ACCOUNT_ID FROM ASO_SHIPMENTS
    WHERE quote_header_id = p_qte_header_id and quote_line_id =p_qte_line_id and shipment_id =p_shipment_id;

   /* Commented for Bug 12938390(11i Bug 12426838)
    -- bug 5596369
    CURSOR c_ship_cust_id1 IS
    SELECT SHIP_TO_CUST_ACCOUNT_ID
    FROM ASO_SHIPMENTS
    WHERE quote_header_id = p_qte_header_id
    and shipment_id =p_shipment_id
    and quote_line_id IS NULL;
    */

    /* Cursor c_ship_cust_id1 modified for Bug 12938390(11i Bug 12426838) */
    CURSOR c_ship_cust_id1(p_ship_id Number) IS
    SELECT SHIP_TO_CUST_ACCOUNT_ID
    FROM ASO_SHIPMENTS
    WHERE quote_header_id = p_qte_header_id
    and shipment_id       = p_ship_id
    and quote_line_id IS NULL;

    CURSOR C_site_use(l_cust_id NUMBER, l_ship_site_id NUMBER) IS
         SELECT site_use_id
         FROM hz_cust_site_uses b,hz_cust_acct_sites a
         WHERE b.cust_acct_site_id = a.cust_acct_site_id
         AND b.site_use_code = 'SHIP_TO' --and b.primary_flag = 'Y'
         AND a.party_site_id = l_ship_site_id
         AND a.cust_account_id = l_cust_id;

  cursor c_root_model_line_id is
  select /*+ index(ASO_QUOTE_LINE_DETAILS ASO_QUOTE_LINE_DETAILS_N5)*/ quote_line_id -- bug 18612485
  from aso_quote_line_details
  where (config_header_id, config_revision_num) = (select config_header_id,config_revision_num
                                                   from aso_quote_line_details
                                                   where quote_line_id = p_qte_line_id)
  and ref_type_code = 'CONFIG'
  and ref_line_id  is null;

  cursor c_item_type_code is
  select item_type_code
  from aso_quote_lines_all
  where quote_line_id = p_qte_line_id;

  cursor c_shipment_id (p_line_id NUMBER) is
  select shipment_id
  from aso_shipments
  where quote_line_id = p_line_id
  and quote_header_id = p_qte_header_id;

    l_cust_id NUMBER;
    l_inv_cust_id NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count number;
    l_msg_data VARCHAR2(2000);

    l_item_type_code  VARCHAR2(30);
    l_model_quote_line_id   NUMBER;
    l_model_shipment_id     NUMBER;

/* Start : Code change for Bug 12938390(11i Bug 10253993) */
    CURSOR C_SHIPMENT IS
    SELECT SHIPMENT_ID
    FROM   ASO_SHIPMENTS
    WHERE quote_header_id = p_qte_header_id
    AND quote_line_id IS NULL;

    l_shipment_id NUMBER;
    /* End : Code change for Bug 12938390(11i Bug 10253993) */

BEGIN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SHIPMENT_PVT:p_qte_header_id ' || p_qte_header_id, 1, 'N');
    aso_debug_pub.add('ASO_SHIPMENT_PVT:quote_line_id ' || p_qte_line_id, 1, 'N');
    aso_debug_pub.add('ASO_SHIPMENT_PVT:shipment_id ' || p_shipment_id, 1, 'N');
    END IF;

    OPEN c_ship_site1;
    FETCH c_ship_site1 INTO l_ship_site_id, l_ship_cust_acct_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_site1 l_ship_site_id ' || l_ship_site_id, 1, 'N');
    aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_site1 l_ship_cust_acct_id ' || l_ship_cust_acct_id, 1, 'N');
    END IF;

/* Start : Code change for Bug 12938390(11i Bug 12426838) , changed position of this cursor */
    Open C_SHIPMENT;
    Fetch C_SHIPMENT INTO l_shipment_id;
    Close C_SHIPMENT;

    aso_debug_pub.add('ASO_SHIPMENT_PVT: At the start , l_shipment_id : '||l_shipment_id);

    /* End : Code change for Bug 12938390(11i Bug 12426838) */

    IF c_ship_site1%FOUND and l_ship_site_id IS NOT NULL and l_ship_site_id <> FND_API.G_MISS_NUM  THEN

	   CLOSE c_ship_site1;

  	   --Get the ship_to_cust_account if present
        OPEN c_ship_cust_id;
        FETCH c_ship_cust_id into l_cust_id;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_cust_id l_cust_id ' || l_cust_id, 1, 'N');
	   END IF;

        IF c_ship_cust_id%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

           CLOSE c_ship_cust_id;

           --OPEN c_ship_cust_id1;
           OPEN c_ship_cust_id1(l_shipment_id); -- Code change done for Bug 12938390(11i Bug 12426838)
           FETCH c_ship_cust_id1 into l_cust_id;

		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_cust_id1 l_cust_id ' || l_cust_id, 1, 'N');
           END IF;

           IF c_ship_cust_id1%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

                CLOSE c_ship_cust_id1;

                -- Get the Customer Account from the header
                OPEN c_cust_id;
                FETCH c_cust_id INTO l_cust_id;
                CLOSE c_cust_id;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('ASO_SHIPMENT_PVT:c_cust_id l_cust_id ' || l_cust_id, 1, 'N');
                END IF;

                OPEN C_site_use(l_cust_id , l_ship_site_id);
                FETCH C_site_use into l_ship_site_use_id;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('ASO_SHIPMENT_PVT:C_site_use1 l_ship_site_use_id ' || l_ship_site_use_id, 1, 'N');
			 END IF;
                CLOSE C_site_use;

                return l_ship_site_use_id;

           END IF;

           CLOSE c_ship_cust_id1;

           OPEN C_site_use(l_cust_id , l_ship_site_id);
           FETCH C_site_use into l_ship_site_use_id;

		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('ASO_SHIPMENT_PVT:C_site_use2 l_ship_site_use_id ' || l_ship_site_use_id, 1, 'N');
           END IF;
           CLOSE C_site_use;

           return l_ship_site_use_id;

        END IF;

        CLOSE c_ship_cust_id;


        --Get the site use id from the HZ_cust_site_uses

        OPEN C_site_use(l_cust_id , l_ship_site_id);
        FETCH C_site_use into l_ship_site_use_id;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_SHIPMENT_PVT:C_site_use3 l_ship_site_use_id ' || l_ship_site_use_id, 1, 'N');
        END IF;
        CLOSE C_site_use;

  	   return l_ship_site_use_id;

    ELSE

        CLOSE c_ship_site1;

	   open  c_item_type_code;
	   fetch c_item_type_code into l_item_type_code;

	   close c_item_type_code;  -- code chane done for Bug 18244211

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Get_Ship_To_site_Id: c_item_type_code: l_item_type_code: '||l_item_type_code);
        END IF;

	   -- IF c_item_type_code%FOUND and l_item_type_code = 'CFG' THEN
	   IF l_item_type_code = 'CFG' THEN   -- code chane done for Bug 18244211

		   -- close c_item_type_code;

		   open  c_root_model_line_id;
		   fetch c_root_model_line_id into l_model_quote_line_id;

		   close c_root_model_line_id; -- code chane done for Bug 18244211

		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('Get_Ship_To_site_Id: c_root_model_line_id: l_model_quote_line_id: '||l_model_quote_line_id);
             END IF;

		   -- IF c_root_model_line_id%FOUND and l_model_quote_line_id is not null THEN
		   IF l_model_quote_line_id is not null THEN   -- code chane done for Bug 18244211

		       -- close c_root_model_line_id;

			   open  c_shipment_id(l_model_quote_line_id);
			   fetch c_shipment_id into l_model_shipment_id;

 			   close c_shipment_id; -- code chane done for Bug 18244211

			   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		           aso_debug_pub.add('Get_Ship_To_site_Id: c_shipment_id: l_model_shipment_id: '||l_model_shipment_id);
                  END IF;

		      --  IF c_shipment_id%FOUND and l_model_shipment_id is not null THEN
		      IF l_model_shipment_id is not null THEN   -- code chane done for Bug 18244211

		           --  close c_shipment_id;

                       l_ship_site_use_id := Get_Ship_To_site_Id(p_qte_header_id, l_model_quote_line_id, l_model_shipment_id);
				   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		                aso_debug_pub.add('Get_Ship_To_site_Id: l_ship_site_use_id: '||l_ship_site_use_id);
                       END IF;

                       return l_ship_site_use_id;

                  END IF; --c_shipment_id

			-- close c_shipment_id;

             END IF; --c_root_model_line_id

              --  close c_root_model_line_id;

         END IF; --c_item_type_code

	   -- close c_item_type_code;

    END IF; --c_ship_site1

 /* Start : Code change for Bug 12938390(11i Bug 10253993) , changed position of this cursor due to bug 12938390 (11i Bug 12426838)
    Open C_SHIPMENT;
    Fetch C_SHIPMENT INTO l_shipment_id;
    Close C_SHIPMENT;

aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_site2 l_shipment_id : '||l_shipment_id); */

OPEN c_ship_site2(l_shipment_id);
/* End : Code change for Bug 12938390(11i Bug 10253993) */

    --OPEN c_ship_site2;
    FETCH c_ship_site2 INTO l_ship_site_id, l_ship_cust_acct_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_site2 l_ship_site_id ' || l_ship_site_id, 1, 'N');
       aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_site2 l_ship_cust_acct_id ' || l_ship_cust_acct_id, 1, 'N');
    END IF;

    IF c_ship_site2%FOUND AND l_ship_site_id IS NOT NULL and l_ship_site_id <> FND_API.G_MISS_NUM THEN

	   CLOSE c_ship_site2;
    	   --Get the ship_to_cust_account if present
        OPEN c_ship_cust_id;
        FETCH c_ship_cust_id into l_cust_id;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_cust_id l_cust_id ' || l_cust_id, 1, 'N');
        END IF;

        IF c_ship_cust_id%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

            CLOSE c_ship_cust_id;

            -- OPEN c_ship_cust_id1;
            OPEN c_ship_cust_id1(l_shipment_id); -- Code change for Bug 12938390(11i Bug 12426838)

            FETCH c_ship_cust_id1 into l_cust_id;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('ASO_SHIPMENT_PVT:c_ship_cust_id1 l_cust_id ' || l_cust_id, 1, 'N');
            END IF;

            IF c_ship_cust_id1%NOTFOUND or l_cust_id IS NULL or l_cust_id = FND_API.G_MISS_NUM THEN

                CLOSE c_ship_cust_id1;
                --Get the Customer Account from the header
                OPEN c_cust_id;
                FETCH c_cust_id INTO l_cust_id;
                CLOSE c_cust_id;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('ASO_SHIPMENT_PVT:c_cust_id l_cust_id ' || l_cust_id, 1, 'N');
                END IF;

                OPEN C_site_use(l_cust_id , l_ship_site_id);
                FETCH C_site_use into l_ship_site_use_id;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('ASO_SHIPMENT_PVT:C_site_use4 l_ship_site_use_id ' || l_ship_site_use_id, 1, 'N');
                END IF;

                CLOSE C_site_use;
                return l_ship_site_use_id;

            END IF;

            CLOSE c_ship_cust_id1;

            OPEN C_site_use(l_cust_id , l_ship_site_id);
            FETCH C_site_use into l_ship_site_use_id;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('ASO_SHIPMENT_PVT:C_site_use5 l_ship_site_use_id ' || l_ship_site_use_id, 1, 'N');
            END IF;

            CLOSE C_site_use;
            return l_ship_site_use_id;

        END IF;
        CLOSE c_ship_cust_id;

        --Get the site use id from the HZ_cust_site_uses

        OPEN C_site_use(l_cust_id , l_ship_site_id);
        FETCH C_site_use into l_ship_site_use_id;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SHIPMENT_PVT:C_site_use6 l_ship_site_use_id ' || l_ship_site_use_id, 1, 'N');
	   END IF;
        CLOSE C_site_use;

  	   return l_ship_site_use_id;

    END IF;

    CLOSE c_ship_site2;

    return l_ship_site_use_id;

END Get_Ship_To_site_Id;


FUNCTION Get_Ship_To_party_site_Id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN NUMBER
IS
    CURSOR c_ship_site1 IS
    SELECT ship_to_party_site_id FROM ASO_SHIPMENTS
    WHERE  shipment_id = p_shipment_id
	AND quote_line_id = p_qte_line_id
	AND quote_header_id = p_qte_header_id;

    CURSOR c_ship_site2 IS
	SELECT ship_to_party_site_id FROM ASO_SHIPMENTS
	WHERE  quote_line_id IS NULL AND quote_header_id = p_qte_header_id;

  l_ship_site_id		NUMBER;

  cursor c_root_model_line_id is
  select /*+ index(ASO_QUOTE_LINE_DETAILS ASO_QUOTE_LINE_DETAILS_N5)*/ quote_line_id -- bug 18612485
  from aso_quote_line_details
  where (config_header_id, config_revision_num) = (select config_header_id,config_revision_num
                                                   from aso_quote_line_details
                                                   where quote_line_id = p_qte_line_id)
  and ref_type_code = 'CONFIG'
  and ref_line_id  is null;

  cursor c_item_type_code is
  select item_type_code
  from aso_quote_lines_all
  where quote_line_id = p_qte_line_id;

  cursor c_shipment_id (p_line_id NUMBER) is
  select shipment_id
  from aso_shipments
  where quote_line_id = p_line_id
  and quote_header_id = p_qte_header_id;

  l_model_quote_line_id    NUMBER;
  l_item_type_code         VARCHAR2(30);
  l_model_shipment_id      NUMBER;

BEGIN

    OPEN c_ship_site1;
    FETCH c_ship_site1 INTO l_ship_site_id;

    IF c_ship_site1%FOUND and l_ship_site_id IS NOT NULL and l_ship_site_id <> FND_API.G_MISS_NUM THEN

	    CLOSE c_ship_site1;
	    return l_ship_site_id;

    ELSE

      CLOSE c_ship_site1;

	    open  c_item_type_code;
	    fetch c_item_type_code into l_item_type_code;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.add('Get_Ship_To_party_site_Id: c_item_type_code: l_item_type_code: '||l_item_type_code);
	    END IF;

	    IF c_item_type_code%FOUND and l_item_type_code = 'CFG' THEN

		    close c_item_type_code;

		    open  c_root_model_line_id;
		    fetch c_root_model_line_id into l_model_quote_line_id;

		    IF aso_debug_pub.g_debug_flag = 'Y' THEN
		       aso_debug_pub.add('Get_Ship_To_party_site_Id: c_root_model_line_id: l_model_quote_line_id: '||l_model_quote_line_id);
              END IF;

		    IF c_root_model_line_id%FOUND and l_model_quote_line_id is not null THEN

		        close c_root_model_line_id;

			   open  c_shipment_id(l_model_quote_line_id);
			   fetch c_shipment_id into l_model_shipment_id;

			   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		           aso_debug_pub.add('Get_Ship_To_party_site_Id: c_shipment_id: l_model_shipment_id: '||l_model_shipment_id);
                  END IF;

		        IF c_shipment_id%FOUND and l_model_shipment_id is not null THEN

		             close c_shipment_id;

			        l_ship_site_id := Get_Ship_To_party_site_Id(p_qte_header_id, l_model_quote_line_id, l_model_shipment_id);

				   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		                aso_debug_pub.add('Get_Ship_To_party_site_Id: l_ship_site_id: '||l_ship_site_id);
                       END IF;

			        return l_ship_site_id;

                  END IF; --c_shipment_id

                  close c_shipment_id;

              END IF; --c_root_model_line_id

              close c_root_model_line_id;

         END IF; --c_item_type_code

    END IF; --c_ship_site1


    OPEN c_ship_site2;
    FETCH c_ship_site2 INTO l_ship_site_id;

    IF c_ship_site2%FOUND and l_ship_site_id IS NOT NULL and l_ship_site_id <> FND_API.G_MISS_NUM THEN

	    CLOSE c_ship_site2;
	    return l_ship_site_id;

    END IF; --c_ship_site2

    return l_ship_site_id;

END Get_Ship_To_party_site_Id;


FUNCTION Get_party_name (
		p_party_id      NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2
 IS
 CURSOR C1 IS
 select HP.party_id,HP.party_name
  from hz_relationships HPR,hz_parties HP where  hpr.party_id = p_party_id
  and hp.party_id=HPR.object_id
  and SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and HPR.directional_flag = 'B'; -- Added for bug 8634067

  CURSOR C2 IS
   select party_id,party_name
  from hz_parties HP where  party_id = p_party_id;
  l_party_name VARCHAR2(360);
  l_party_id NUMBER;
  BEGIN
   IF p_party_type = 'PARTY_RELATIONSHIP' THEN
     OPEN C1;
     FETCH C1 INTO l_party_id,l_party_name;
        IF C1%NOTFOUND OR l_party_name IS NULL THEN
            CLOSE C1;
            l_party_name := NULL;
            RETURN  l_party_name;
        END IF;
     CLOSE C1;
     RETURN  l_party_name;
   ELSE
         OPEN C2;
         FETCH C2 INTO l_party_id,l_party_name;
        IF C2%NOTFOUND OR l_party_name IS NULL THEN
            CLOSE C2;
            l_party_name := NULL;
            RETURN  l_party_name;
        END IF;
     CLOSE C2;
     RETURN  l_party_name;
   END IF;
  END Get_party_name;


FUNCTION Get_party_first_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2
 IS
 CURSOR C1 IS
 select HP.party_id,HP.person_first_name
  from hz_relationships HPR,hz_parties HP where  hpr.party_id = p_party_id
  and hp.party_id=HPR.subject_id
  and SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and HPR.directional_flag = 'F'; -- 8634067

  CURSOR C2 IS
   select party_id,person_first_name
  from hz_parties HP where  party_id = p_party_id;
  l_f_party_name VARCHAR2(150);
  l_party_id NUMBER;
  BEGIN
   IF p_party_type = 'PARTY_RELATIONSHIP' THEN
     OPEN C1;
     FETCH C1 INTO l_party_id,l_f_party_name;
        IF C1%NOTFOUND OR l_f_party_name IS NULL THEN
            CLOSE C1;
            l_f_party_name := NULL;
            RETURN  l_f_party_name;
        END IF;
     CLOSE C1;
     RETURN  l_f_party_name;
   ELSE
         OPEN C2;
         FETCH C2 INTO l_party_id,l_f_party_name;
        IF C2%NOTFOUND OR l_f_party_name IS NULL THEN
            CLOSE C2;
            l_f_party_name := NULL;
            RETURN  l_f_party_name;
        END IF;
     CLOSE C2;
     RETURN  l_f_party_name;
   END IF;
  END Get_party_first_name;


FUNCTION Get_party_mid_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2
 IS
 CURSOR C1 IS
 select HP.party_id,HP.person_middle_name
  from hz_relationships HPR,hz_parties HP where  hpr.party_id = p_party_id
  and hp.party_id=HPR.subject_id
  and SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and HPR.directional_flag = 'F'; -- 8634067

  CURSOR C2 IS
   select party_id,person_middle_name
  from hz_parties HP where  party_id = p_party_id;
  l_m_party_name VARCHAR2(60);
l_party_id NUMBER;
  BEGIN
   IF p_party_type = 'PARTY_RELATIONSHIP' THEN
     OPEN C1;
     FETCH C1 INTO l_party_id,l_m_party_name;
        IF C1%NOTFOUND OR l_m_party_name IS NULL THEN
            CLOSE C1;
            l_m_party_name := NULL;
            RETURN  l_m_party_name;
        END IF;
     CLOSE C1;
     RETURN  l_m_party_name;
   ELSE
         OPEN C2;
         FETCH C2 INTO l_party_id,l_m_party_name;
        IF C2%NOTFOUND OR l_m_party_name IS NULL THEN
            CLOSE C2;
            l_m_party_name := NULL;
            RETURN  l_m_party_name;
        END IF;
     CLOSE C2;
     RETURN  l_m_party_name;
   END IF;
  END Get_party_mid_name;

  FUNCTION Get_party_last_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2
 IS
 CURSOR C1 IS
 select HP.party_id,HP.person_last_name
  from hz_relationships HPR,hz_parties HP where  hpr.party_id = p_party_id
  and hp.party_id=HPR.subject_id
  and SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
  and HPR.directional_flag = 'F'; -- 8634067

  CURSOR C2 IS
   select party_id,person_last_name
  from hz_parties HP where  party_id = p_party_id;
  l_l_party_name VARCHAR2(150);
  l_party_id NUMBER;
  BEGIN
   IF p_party_type = 'PARTY_RELATIONSHIP' THEN
     OPEN C1;
     FETCH C1 INTO l_party_id,l_l_party_name;
        IF C1%NOTFOUND OR l_l_party_name IS NULL THEN
            CLOSE C1;
            l_l_party_name := NULL;
            RETURN  l_l_party_name;
        END IF;
     CLOSE C1;
     RETURN  l_l_party_name;
   ELSE
         OPEN C2;
         FETCH C2 INTO l_party_id,l_l_party_name;
        IF C2%NOTFOUND OR l_l_party_name IS NULL THEN
            CLOSE C2;
            l_l_party_name := NULL;
            RETURN  l_l_party_name;
        END IF;
     CLOSE C2;
     RETURN  l_l_party_name;
   END IF;
  END Get_party_last_name;


FUNCTION Get_ship_from_org_id (
p_qte_header_id		NUMBER,
p_qte_line_id		NUMBER
) RETURN NUMBER

IS

CURSOR c_line_shipment IS
SELECT ship_from_org_id FROM ASO_shipments
WHERE	quote_line_id = p_qte_line_id
AND quote_header_id = p_qte_header_id;


CURSOR c_header_shipment IS
SELECT ship_from_org_id FROM ASO_shipments
WHERE	quote_header_id = p_qte_header_id
AND quote_line_id IS NULL;

l_ship_from_org_id		NUMBER;


Begin
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_from_org_id: p_qte_header_id :'||p_qte_header_id, 1, 'N');
    aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_from_org_id: p_qte_line_id :'||p_qte_line_id, 1, 'N');
    END IF;

    -- Look for line-shipment level ship_from_org_id

    open c_line_shipment;
    fetch c_line_shipment into l_ship_from_org_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_from_org_id: c_line_shipment: l_ship_from_org_id'||l_ship_from_org_id, 1, 'N');
    END IF;

    -- Line-shipment level ship_from_org_id doesn't exist then look for header-shipment level ship_from_org_id

    IF c_line_shipment%NOTFOUND OR l_ship_from_org_id IS NULL OR l_ship_from_org_id = FND_API.G_MISS_NUM THEN
	    open c_header_shipment;
	    fetch c_header_shipment into l_ship_from_org_id;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_from_org_id: c_header_shipment: l_ship_from_org_id'||l_ship_from_org_id, 1, 'N');
	    END IF;

	    close c_header_shipment;
    END IF;
    close c_line_shipment;
    return l_ship_from_org_id;
End Get_ship_from_org_id;


FUNCTION Get_ship_method_code(p_qte_header_id  NUMBER, p_qte_line_id  NUMBER)
RETURN VARCHAR2

IS

CURSOR c_line_shipment IS
SELECT ship_method_code FROM ASO_shipments
WHERE quote_line_id = p_qte_line_id
AND quote_header_id = p_qte_header_id;


CURSOR c_header_shipment IS
SELECT ship_method_code FROM ASO_shipments
WHERE quote_header_id = p_qte_header_id
AND quote_line_id IS NULL;

l_ship_method_code		varchar2(30) := null;

Begin

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_method_code: p_qte_header_id : '||p_qte_header_id, 1, 'Y');
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_method_code: p_qte_line_id :   '||p_qte_line_id, 1, 'Y');
    END IF;

    -- Look for line-shipment level ship_method_code

    if p_qte_line_id is not null  and  p_qte_header_id is not null then

        open c_line_shipment;
        fetch c_line_shipment into l_ship_method_code;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Get_ship_method_code: c_line_shipment: l_ship_method_code: '||l_ship_method_code, 1, 'N');
        END IF;

        -- Line-shipment level ship_method_code doesn't exist then look for header-shipment level ship_method_code

        IF c_line_shipment%NOTFOUND OR l_ship_method_code IS NULL THEN

	       open c_header_shipment;
	       fetch c_header_shipment into l_ship_method_code;

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('Get_ship_method_code: c_header_shipment: l_ship_method_code: '||l_ship_method_code, 1, 'N');
	       END IF;

	       close c_header_shipment;
        END IF;

        close c_line_shipment;

    elsif p_qte_header_id is not null and p_qte_line_id is null then

	   open c_header_shipment;
	   fetch c_header_shipment into l_ship_method_code;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Get_ship_from_org_id: c_header_shipment: l_ship_method_code: '||l_ship_method_code, 1, 'N');
	   END IF;

	   close c_header_shipment;

    end if;

    return l_ship_method_code;

End Get_ship_method_code;


FUNCTION Get_demand_class_code(p_qte_header_id  NUMBER, p_qte_line_id  NUMBER)
RETURN VARCHAR2

IS

CURSOR c_line_shipment IS
SELECT demand_class_code FROM ASO_shipments
WHERE quote_line_id = p_qte_line_id
AND quote_header_id = p_qte_header_id;


CURSOR c_header_shipment IS
SELECT demand_class_code FROM ASO_shipments
WHERE quote_header_id = p_qte_header_id
AND quote_line_id IS NULL;

l_demand_class_code		varchar2(30) := null;

Begin

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_demand_class_code: p_qte_header_id : '||p_qte_header_id, 1, 'Y');
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_demand_class_code: p_qte_line_id :   '||p_qte_line_id, 1, 'Y');
    END IF;

    -- Look for line-shipment level demand_class_code

    if p_qte_line_id is not null  and  p_qte_header_id is not null then

        open c_line_shipment;
        fetch c_line_shipment into l_demand_class_code;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Get_demand_class_code: c_line_shipment: l_demand_class_code: '||l_demand_class_code, 1, 'N');
        END IF;

        -- Line-shipment level demand_class_code doesn't exist then look for header-shipment level demand_class_code

        IF c_line_shipment%NOTFOUND OR l_demand_class_code IS NULL THEN

	       open c_header_shipment;
	       fetch c_header_shipment into l_demand_class_code;

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('Get_demand_class_code: c_header_shipment: l_demand_class_code: '||l_demand_class_code, 1, 'N');
	       END IF;

	       close c_header_shipment;
        END IF;

        close c_line_shipment;

    elsif p_qte_header_id is not null and p_qte_line_id is null then

	   open c_header_shipment;
	   fetch c_header_shipment into l_demand_class_code;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Get_demand_class_code: c_header_shipment: l_demand_class_code: '||l_demand_class_code, 1, 'N');
	   END IF;

	   close c_header_shipment;

    end if;

    return l_demand_class_code;

End Get_demand_class_code;


FUNCTION Get_ship_to_party_site_id(p_qte_header_id  NUMBER, p_qte_line_id  NUMBER)
RETURN NUMBER

IS

CURSOR c_line_shipment IS
SELECT ship_to_party_site_id FROM ASO_shipments
WHERE quote_line_id = p_qte_line_id
AND quote_header_id = p_qte_header_id;


CURSOR c_header_shipment IS
SELECT ship_to_party_site_id FROM ASO_shipments
WHERE quote_header_id = p_qte_header_id
AND quote_line_id IS NULL;

l_ship_to_party_site_id		number := null;

Begin

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_to_party_site_id: p_qte_header_id : '||p_qte_header_id, 1, 'Y');
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_to_party_site_id: p_qte_line_id :   '||p_qte_line_id, 1, 'Y');
    END IF;

    -- Look for line-shipment level ship_to_party_site_id

    if p_qte_line_id is not null  and  p_qte_header_id is not null then

        open c_line_shipment;
        fetch c_line_shipment into l_ship_to_party_site_id;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Get_ship_to_party_site_id: c_line_shipment: l_ship_to_party_site_id: '||l_ship_to_party_site_id, 1, 'N');
        END IF;

        -- Line-shipment level ship_to_party_site_id doesn't exist then look for header-shipment level ship_to_party_site_id

        IF c_line_shipment%NOTFOUND OR l_ship_to_party_site_id IS NULL THEN

	       open c_header_shipment;
	       fetch c_header_shipment into l_ship_to_party_site_id;

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('Get_ship_to_party_site_id: c_header_shipment: l_ship_to_party_site_id: '||l_ship_to_party_site_id, 1, 'N');
	       END IF;

	       close c_header_shipment;
        END IF;

        close c_line_shipment;

    elsif p_qte_header_id is not null and p_qte_line_id is null then

	   open c_header_shipment;
	   fetch c_header_shipment into l_ship_to_party_site_id;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Get_ship_to_party_site_id: c_header_shipment: l_ship_to_party_site_id: '||l_ship_to_party_site_id, 1, 'N');
	   END IF;

	   close c_header_shipment;

    end if;

    return l_ship_to_party_site_id;

End Get_ship_to_party_site_id;


FUNCTION Get_ship_to_cust_account_id(p_qte_header_id  NUMBER, p_qte_line_id  NUMBER)
RETURN NUMBER

IS

CURSOR c_line_shipment IS
SELECT ship_to_cust_account_id FROM ASO_shipments
WHERE quote_line_id = p_qte_line_id
AND quote_header_id = p_qte_header_id;


CURSOR c_header_shipment IS
SELECT ship_to_cust_account_id FROM ASO_shipments
WHERE quote_header_id = p_qte_header_id
AND quote_line_id IS NULL;

l_ship_to_cust_account_id    number := null;

Begin

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_to_cust_account_id: p_qte_header_id : '||p_qte_header_id, 1, 'Y');
        aso_debug_pub.add('ASO_SHIPMENT_PVT.Get_ship_to_cust_account_id: p_qte_line_id :   '||p_qte_line_id, 1, 'Y');
    END IF;

    -- Look for line-shipment level ship_to_cust_account_id

    if p_qte_line_id is not null  and  p_qte_header_id is not null then

        open c_line_shipment;
        fetch c_line_shipment into l_ship_to_cust_account_id;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Get_ship_to_party_site_id: c_line_shipment: l_ship_to_cust_account_id: '||l_ship_to_cust_account_id, 1, 'N');
        END IF;

        -- Line-shipment level ship_to_cust_account_id doesn't exist then look for header-shipment level ship_to_cust_account_id

        IF c_line_shipment%NOTFOUND OR l_ship_to_cust_account_id IS NULL THEN

	       open c_header_shipment;
	       fetch c_header_shipment into l_ship_to_cust_account_id;

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('Get_ship_to_cust_account_id: c_header_shipment: l_ship_to_cust_account_id: '||l_ship_to_cust_account_id, 1, 'N');
	       END IF;

	       close c_header_shipment;
        END IF;

        close c_line_shipment;

    elsif p_qte_header_id is not null and p_qte_line_id is null then

	   open c_header_shipment;
	   fetch c_header_shipment into l_ship_to_cust_account_id;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Get_ship_to_cust_account_id: c_header_shipment: l_ship_to_cust_account_id: '||l_ship_to_cust_account_id, 1, 'N');
	   END IF;

	   close c_header_shipment;

    end if;

    return l_ship_to_cust_account_id;

End Get_ship_to_cust_account_id;

END ASO_SHIPMENT_PVT;

/
