--------------------------------------------------------
--  DDL for Package Body ASO_TAX_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_TAX_INT" as
/* $Header: asoitaxb.pls 120.23.12010000.24 2016/03/10 06:34:49 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_TAX_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_TAX_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoitaxb.pls';
l_sys_date date := SYSDATE;


/*
 *
 *
PROCEDURE Calculate_Tax(
    P_Api_Version_Number	 IN   NUMBER,
    P_Tax_Control_Rec		 IN   Tax_Control_Rec_Type
					              := G_Miss_Tax_Control_Rec,
    P_Qte_Header_Rec		 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
					              := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec		     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type
					              := ASO_QUOTE_PUB.G_Miss_Qte_Line_Rec,
    P_Shipment_Rec		     IN   ASO_QUOTE_PUB.Shipment_Rec_Type
					              := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    p_tax_detail_rec		 IN   ASO_QUOTE_PUB.Tax_Detail_Rec_Type
					              := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
    x_tax_amount		    OUT NOCOPY    NUMBER,
    x_tax_detail_tbl         OUT NOCOPY   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Return_Status          OUT NOCOPY     VARCHAR2,
    X_Msg_Count              OUT NOCOPY     NUMBER,
    X_Msg_Data               OUT NOCOPY     VARCHAR2)
IS
    l_api_name			CONSTANT VARCHAR2(30) := 'Calculate_Tax';
    l_trx_id			NUMBER := NULL;
    l_trx_line_id		NUMBER := NULL;
    l_charge_line_id	NUMBER := NULL;
    l_arp_tax_tbl		ARP_TAX.tax_rec_tbl_type;

    l_tax_detail_rec		ASO_QUOTE_PUB.Tax_Detail_Rec_Type;

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    CURSOR C_Tax_Code (c_tax_id NUMBER) IS
	SELECT tax_code from AR_VAT_TAX
	WHERE vat_tax_id = c_tax_id;
BEGIN
    SAVEPOINT CALCULATE_TAX_INT;

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_tax_control_rec.tax_level = 'HEADER' THEN
	l_trx_id := p_tax_detail_rec.quote_header_id;
    ELSIF p_tax_control_rec.tax_level = 'SHIPPING' THEN
	l_trx_line_id := p_tax_detail_rec.quote_shipment_id;
    l_trx_id := p_tax_detail_rec.quote_header_id;
--	l_charge_line_id := P_Shipment_Rec.shipment_id;
    END IF;
    BEGIN
      ARP_PROCESS_TAX.Summary(
		p_trx_id 	 => l_trx_id,
                p_trx_line_id    => l_trx_line_id,
                p_charge_line_id => l_charge_line_id,
	        	p_viewname 	 => 'ASO_I_TAX_LINES_SUMMARY_V',
                p_new_tax_amount => x_tax_amount,
                p_tax_rec_tbl	 => l_arp_tax_tbl);
    EXCEPTION
      WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('ASO', 'ASO_API_TAX_EXCEPTION');
        FND_MSG_PUB.Add;
--        x_return_status := FND_API.G_RET_STS_ERROR;
    END;
    FOR i IN 1.. l_arp_tax_tbl.count LOOP
	OPEN c_tax_code(l_arp_tax_tbl(i).vat_tax_id);
	FETCH c_tax_code INTO l_tax_detail_rec.TAX_CODE;
	CLOSE c_tax_code;
	l_tax_detail_rec.QUOTE_HEADER_ID := p_tax_detail_rec.quote_header_id;
	l_tax_detail_rec.QUOTE_LINE_ID := p_tax_detail_rec.quote_line_id;
	l_tax_detail_rec.QUOTE_SHIPMENT_ID := p_tax_detail_rec.quote_shipment_id;
	l_tax_detail_rec.TAX_RATE := l_arp_tax_tbl(i).TAX_RATE;
	l_tax_detail_rec.TAX_DATE := sysdate;
	l_tax_detail_rec.TAX_AMOUNT := l_arp_tax_tbl(i).EXTENDED_AMOUNT;
	l_tax_detail_rec.TAX_EXEMPT_FLAG := l_arp_tax_tbl(i).TAX_EXEMPT_FLAG;
	l_tax_detail_rec.TAX_EXEMPT_NUMBER := l_arp_tax_tbl(i).TAX_EXEMPT_NUMBER;
	l_tax_detail_rec.TAX_EXEMPT_REASON_CODE := l_arp_tax_tbl(i).TAX_EXEMPT_REASON_CODE;
	x_tax_detail_tbl(x_tax_detail_tbl.count+1) := l_tax_detail_rec;
    END LOOP;

    IF p_tax_control_rec.update_DB = 'Y' THEN

    IF  p_tax_control_rec.tax_level = 'SHIPPING' THEN
    DELETE FROM aso_tax_details
	WHERE quote_shipment_id = p_tax_detail_rec.quote_shipment_id and
        quote_line_id = p_tax_detail_rec.quote_line_id and
	quote_header_id = p_tax_detail_rec.quote_header_id;
    END IF;

    IF p_tax_control_rec.tax_level = 'HEADER' THEN
    DELETE FROM aso_tax_details
	WHERE quote_header_id = p_tax_detail_rec.quote_header_id AND
    quote_line_id = p_tax_detail_rec.quote_line_id;
    END IF;
	--	AND orig_tax_code IS NOT NULL;
      FOR i IN 1..x_tax_detail_Tbl.count LOOP
	l_tax_detail_rec := x_tax_detail_tbl(i);

        ASO_TAX_DETAILS_PKG.Insert_Row(
            px_TAX_DETAIL_ID  => x_tax_detail_tbl(i).TAX_DETAIL_ID,
            p_CREATION_DATE  => SYSDATE,
            p_CREATED_BY  => G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  => G_USER_ID,
            p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
            p_REQUEST_ID  => l_tax_detail_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID  => l_tax_detail_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  => l_tax_detail_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_tax_detail_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID  => p_tax_detail_rec.quote_header_id,
            p_QUOTE_LINE_ID  => l_tax_detail_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID  => l_tax_detail_rec.QUOTE_SHIPMENT_ID,
            p_ORIG_TAX_CODE  => l_tax_detail_rec.ORIG_TAX_CODE,
            p_TAX_CODE  => l_tax_detail_rec.TAX_CODE,
            p_TAX_RATE  => l_tax_detail_rec.TAX_RATE,
            p_TAX_DATE  => l_tax_detail_rec.TAX_DATE,
            p_TAX_AMOUNT  => l_tax_detail_rec.TAX_AMOUNT,
            p_TAX_EXEMPT_FLAG  => l_tax_detail_rec.TAX_EXEMPT_FLAG,
            p_TAX_EXEMPT_NUMBER  => l_tax_detail_rec.TAX_EXEMPT_NUMBER,
            p_TAX_EXEMPT_REASON_CODE  => l_tax_detail_rec.TAX_EXEMPT_REASON_CODE,
            p_ATTRIBUTE_CATEGORY  => l_tax_detail_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_tax_detail_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_tax_detail_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_tax_detail_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_tax_detail_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_tax_detail_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_tax_detail_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_tax_detail_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_tax_detail_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_tax_detail_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_tax_detail_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_tax_detail_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_tax_detail_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_tax_detail_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_tax_detail_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_tax_detail_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  => l_tax_detail_rec.ATTRIBUTE16,
		  p_ATTRIBUTE17  => l_tax_detail_rec.ATTRIBUTE17,
		  p_ATTRIBUTE18  => l_tax_detail_rec.ATTRIBUTE18,
		  p_ATTRIBUTE19  => l_tax_detail_rec.ATTRIBUTE19,
		  p_ATTRIBUTE20  => l_tax_detail_rec.ATTRIBUTE20,
		  p_TAX_INCLUSIVE_FLAG  => l_tax_detail_rec.TAX_INCLUSIVE_FLAG,
		  p_OBJECT_VERSION_NUMBER => l_tax_detail_rec.OBJECT_VERSION_NUMBER,
		  p_TAX_RATE_ID => l_tax_detail_rec.TAX_RATE_ID
		  );
        END LOOP;

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
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
END Calculate_Tax;


PROCEDURE Calculate_Tax(
                P_Api_Version_Number	IN   NUMBER,
		p_quote_header_id 	IN   NUMBER,
        p_qte_line_id    IN NUMBER :=NULL,
                P_Tax_Control_Rec       IN   Tax_Control_Rec_Type
					:= G_Miss_Tax_Control_Rec,
          x_tax_amount	         OUT NOCOPY    NUMBER,
    		x_tax_detail_tbl        OUT NOCOPY    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    		X_Return_Status         OUT NOCOPY    VARCHAR2,
    		X_Msg_Count             OUT NOCOPY    NUMBER,
    		X_Msg_Data              OUT NOCOPY    VARCHAR2)
IS
 Cursor C_shipment(l_quote_header_id NUMBER) IS
  select quote_line_id, shipment_id
  from aso_shipments
  where quote_header_id = l_quote_header_id;


    l_api_name			CONSTANT VARCHAR2(30) := 'Calculate_Tax';
  l_tax_detail_rec         ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
  l_tax_detail_tbl         ASO_QUOTE_PUB.Tax_Detail_tbl_Type;
  lx_tax_detail_tbl        ASO_QUOTE_PUB.Tax_Detail_tbl_Type;
  l_count                  NUMBER;

  c_header_id NUMBER;
  c_line_id NUMBER;
  c_shipment_id NUMBER;
l_hd_exempt_flag VARCHAR2(1);
 l_hd_exempt_number VARCHAR2(80);
 l_hd_exempt_reason_code VARCHAR2(30);
l_exempt_flag VARCHAR2(1);
 l_exempt_number VARCHAR2(80);
 l_exempt_reason_code VARCHAR2(30);
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
CURSOR c_hd_tax(qt_hdr_id NUMBER,q_ship_id NUMBER) IS SELECT tax_exempt_flag,tax_exempt_number,tax_exempt_reason_code
FROM
aso_tax_details WHERE quote_header_id= qt_hdr_id
and quote_shipment_id= q_ship_id and quote_line_id IS NULL;

CURSOR c_tax_line(qt_hdr_id NUMBER,q_line_id NUMBER,q_ship_id NUMBER) IS SELECT tax_exempt_flag,tax_exempt_number,tax_exempt_reason_code FROM
aso_tax_details WHERE quote_header_id= qt_hdr_id
and quote_shipment_id= q_ship_id and quote_line_id = q_line_id;

BEGIN
     SAVEPOINT CALCULATE_TAX_PUB;

	aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_tax_detail_rec.quote_header_id := p_quote_header_id;
    FOR i in C_shipment(p_quote_header_id) LOOP
    --l_tax_detail_rec.quote_header_id := p_quote_header_id;
       l_tax_detail_rec.quote_line_id := i.quote_line_id;
       l_tax_detail_rec.quote_shipment_id := i.shipment_id;
        l_tax_detail_tbl(l_tax_detail_tbl.COUNT+1) := l_tax_detail_rec;
   END LOOP;

IF aso_debug_pub.g_debug_flag = 'Y' THEN

    aso_debug_pub.add('After shipment loop',1,'Y');
    aso_debug_pub.add('After shipment loop'||l_tax_detail_tbl.count,1,'Y');

END IF;

FOR j IN 1..l_tax_detail_tbl.count LOOP

    IF l_tax_detail_tbl(j).quote_line_id IS NULL THEN
      c_header_id   :=   l_tax_detail_tbl(j).quote_header_id;
      c_shipment_id := l_tax_detail_tbl(j).quote_shipment_id;
     OPEN c_hd_tax(c_header_id,c_shipment_id);
     FETCH c_hd_tax into l_hd_exempt_flag,l_hd_exempt_number,l_hd_exempt_reason_code;
        IF c_hd_tax%NOTFOUND or l_hd_exempt_flag is null or l_hd_exempt_flag = FND_API.G_MISS_CHAR THEN
           l_hd_exempt_flag := null;
	      l_hd_exempt_number := null;
	      l_hd_exempt_reason_code := null;
        END IF;
    CLOSE c_hd_tax;
    END IF;

END LOOP;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('After header tax detail query ',1,'Y');
END IF;

FOR j IN 1..l_tax_detail_tbl.count LOOP

      c_header_id   :=   l_tax_detail_tbl(j).quote_header_id;
      c_line_id     :=   l_tax_detail_tbl(j).quote_line_id;
      c_shipment_id := l_tax_detail_tbl(j).quote_shipment_id;

	IF l_tax_detail_tbl(j).quote_line_id IS NOT NULL and l_tax_detail_tbl(j).quote_line_id <> FND_API.G_MISS_NUM THEN

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Inside line tax c_header_id '||c_header_id ,1,'Y');
          aso_debug_pub.add('Inside line tax c_line_id '||c_line_id ,1,'Y');
          aso_debug_pub.add('Inside line tax c_shp_id '||c_shipment_id ,1,'Y');

      END IF;
      		OPEN c_tax_line(c_header_id,c_line_id,c_shipment_id);
      		FETCH c_tax_line into l_exempt_flag,l_exempt_number,l_exempt_reason_code;
      		IF c_tax_line%NOTFOUND THEN
      		-- Insert into tax details
               		ASO_TAX_DETAILS_PKG.Insert_Row(
            		px_TAX_DETAIL_ID  => l_tax_detail_tbl(j).TAX_DETAIL_ID,
            		p_CREATION_DATE  => SYSDATE,
            		p_CREATED_BY  => G_USER_ID,
            		p_LAST_UPDATE_DATE  => SYSDATE,
            		p_LAST_UPDATED_BY  => G_USER_ID,
            		p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
            		p_REQUEST_ID  => l_tax_detail_tbl(j).REQUEST_ID,
            		p_PROGRAM_APPLICATION_ID  => l_tax_detail_tbl(j).PROGRAM_APPLICATION_ID,
            		p_PROGRAM_ID  => l_tax_detail_tbl(j).PROGRAM_ID,
            		p_PROGRAM_UPDATE_DATE  => l_tax_detail_tbl(j).PROGRAM_UPDATE_DATE,
            		p_QUOTE_HEADER_ID  => l_tax_detail_tbl(j).quote_header_id,
            		p_QUOTE_LINE_ID  => l_tax_detail_tbl(j).QUOTE_LINE_ID,
            		p_QUOTE_SHIPMENT_ID  => l_tax_detail_tbl(j).QUOTE_SHIPMENT_ID,
            		p_ORIG_TAX_CODE  => l_tax_detail_tbl(j).ORIG_TAX_CODE,
            		p_TAX_CODE  => l_tax_detail_tbl(j).TAX_CODE,
            		p_TAX_RATE  => l_tax_detail_tbl(j).TAX_RATE,
            		p_TAX_DATE  => l_sys_date,--l_tax_detail_tbl(j).TAX_DATE,
            		p_TAX_AMOUNT  => l_tax_detail_tbl(j).TAX_AMOUNT,
            		p_TAX_EXEMPT_FLAG  => l_hd_EXEMPT_FLAG,
            		p_TAX_EXEMPT_NUMBER  => l_hd_exempt_number ,
            		p_TAX_EXEMPT_REASON_CODE  => l_hd_exempt_reason_code ,
            		p_ATTRIBUTE_CATEGORY  => l_tax_detail_tbl(j).ATTRIBUTE_CATEGORY,
            		p_ATTRIBUTE1  => l_tax_detail_tbl(j).ATTRIBUTE1,
            		p_ATTRIBUTE2  => l_tax_detail_tbl(j).ATTRIBUTE2,
            		p_ATTRIBUTE3  => l_tax_detail_tbl(j).ATTRIBUTE3,
            		p_ATTRIBUTE4  => l_tax_detail_tbl(j).ATTRIBUTE4,
            		p_ATTRIBUTE5  => l_tax_detail_tbl(j).ATTRIBUTE5,
            		p_ATTRIBUTE6  => l_tax_detail_tbl(j).ATTRIBUTE6,
            		p_ATTRIBUTE7  => l_tax_detail_tbl(j).ATTRIBUTE7,
            		p_ATTRIBUTE8  => l_tax_detail_tbl(j).ATTRIBUTE8,
            		p_ATTRIBUTE9  => l_tax_detail_tbl(j).ATTRIBUTE9,
            		p_ATTRIBUTE10  => l_tax_detail_tbl(j).ATTRIBUTE10,
            		p_ATTRIBUTE11  => l_tax_detail_tbl(j).ATTRIBUTE11,
            		p_ATTRIBUTE12  => l_tax_detail_tbl(j).ATTRIBUTE12,
            		p_ATTRIBUTE13  => l_tax_detail_tbl(j).ATTRIBUTE13,
            		p_ATTRIBUTE14  => l_tax_detail_tbl(j).ATTRIBUTE14,
            		p_ATTRIBUTE15  => l_tax_detail_tbl(j).ATTRIBUTE15,
                    p_ATTRIBUTE16  => l_tax_detail_tbl(j).ATTRIBUTE16,
                    p_ATTRIBUTE17  => l_tax_detail_tbl(j).ATTRIBUTE17,
                    p_ATTRIBUTE18  => l_tax_detail_tbl(j).ATTRIBUTE18,
                    p_ATTRIBUTE19  => l_tax_detail_tbl(j).ATTRIBUTE19,
                    p_ATTRIBUTE20  => l_tax_detail_tbl(j).ATTRIBUTE20,
				p_TAX_INCLUSIVE_FLAG  => l_tax_detail_tbl(j).TAX_INCLUSIVE_FLAG,
				p_OBJECT_VERSION_NUMBER => l_tax_detail_tbl(j).OBJECT_VERSION_NUMBER,
				p_TAX_RATE_ID => l_tax_detail_tbl(j).TAX_RATE_ID
				);

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Inside line  tax detail after insert ',1,'Y');
                    END IF;

 --     		ELSIF l_exempt_flag is null or l_exempt_flag = FND_API.G_MISS_CHAR or l_exempt_flag <> 'R'  THEN
            ELSIF l_hd_exempt_flag IS NOT NULL AND l_hd_exempt_flag <> FND_API.G_MISS_CHAR THEN

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
			    aso_debug_pub.add('Inside line  tax detail before update ',1,'Y');
               END IF;

        		UPDATE ASO_TAX_DETAILS
        		SET tax_exempt_flag        = l_hd_exempt_flag ,
			    tax_exempt_number      = l_hd_exempt_number,
			    tax_exempt_reason_code = l_hd_exempt_reason_code,
                   last_update_date       = sysdate,
                   last_updated_by        = fnd_global.user_id,
                   last_update_login      = fnd_global.conc_login_id,
			    tax_date 			  = l_sys_date
        		WHERE quote_header_id   = c_header_id
                 and quote_line_id     = c_line_id
        		  and quote_shipment_id = c_shipment_id;

            END IF;

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    aso_debug_pub.add('Inside line  tax detail after update ',1,'Y');
          END IF;

      		--END IF;
		CLOSE c_tax_line;
    END IF;

  END LOOP;


   BEGIN

        IF aso_debug_pub.g_debug_flag = 'Y' THEN

            aso_debug_pub.add('Before calling tax engine: FND_PROFILE.Value(ASO_USE_TAX_VIEW)'||FND_PROFILE.Value('ASO_USE_TAX_VIEW'),1,'Y');
            aso_debug_pub.add('Before new tax call : ' || x_tax_amount, 1, 'Y');

        END IF;

        aso_tax_line( p_api_version_number   => p_api_version_number,
                      p_qte_header_id        => c_header_id,
                      p_qte_line_id          => p_qte_line_id,
                      p_tax_control_rec      => p_tax_control_rec,
                      x_tax_value            => x_tax_amount,
                      x_tax_detail_tbl       => x_tax_detail_tbl,
                      x_return_status        => x_return_status-- Tax engine is not returning msg_count and msg_data to OM. Do we need these?
                    );

        EXCEPTION

           WHEN OTHERS THEN

             x_return_status := FND_API.G_RET_STS_SUCCESS;

	        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	            aso_debug_pub.add('after new tax call in when others: ' || x_tax_amount, 1, 'Y');
             END IF;

    END;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('after new tax call : ' || x_tax_amount, 1, 'Y');
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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Calculate_Tax;



PROCEDURE Calculate_Tax(
		p_trx_id 		IN 	NUMBER,
                p_trx_line_id		IN      NUMBER,
                p_charge_line_id	IN      NUMBER,
		p_viewname 		IN 	VARCHAR2,
                x_tax_amount OUT NOCOPY   	NUMBER,
                x_tax_rec_tbl OUT NOCOPY     ARP_TAX.tax_rec_tbl_type)
IS
BEGIN
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
    ARP_PROCESS_TAX.Summary(
		p_trx_id 	 => p_trx_id,
                p_trx_line_id    => p_trx_line_id,
                p_charge_line_id => p_charge_line_id,
		p_viewname 	 => p_viewname,
                p_new_tax_amount => x_tax_amount,
                p_tax_rec_tbl	 => x_tax_rec_tbl);
END Calculate_Tax;

-- New tax api
Procedure initialize_Tax_info_rec
IS
Begin
    arp_tax.tax_info_rec.ship_to_cust_id := to_number(null);
    arp_tax.tax_info_rec.bill_to_cust_id := to_number(null);
    arp_tax.tax_info_rec.customer_trx_charge_line_id := to_number(null);
    arp_tax.tax_info_rec.customer_trx_line_id := to_number(null);
    arp_tax.tax_info_rec.customer_trx_id := to_number(null);
    arp_tax.tax_info_rec.link_to_cust_trx_line_id := to_number(null);
    arp_tax.tax_info_rec.trx_date := null;
    arp_tax.tax_info_rec.gl_date := NULL;
    arp_tax.tax_info_rec.tax_code := NULL;
    arp_tax.tax_info_rec.tax_rate := NULL;
    arp_tax.tax_info_rec.tax_amount := NULL;
    arp_tax.tax_info_rec.ship_to_site_use_id := to_number(null);
    arp_tax.tax_info_rec.bill_to_site_use_id := to_number(null);
    arp_tax.tax_info_rec.ship_to_postal_code := null;
    arp_tax.tax_info_rec.bill_to_postal_code := null;
    arp_tax.tax_info_rec.inventory_item_id := to_number(null);
    arp_tax.tax_info_rec.memo_line_id := to_number(NULL);
    arp_tax.tax_info_rec.tax_control := null;
    arp_tax.tax_info_rec.xmpt_cert_no := null;
    arp_tax.tax_info_rec.xmpt_reason := null;
    arp_tax.tax_info_rec.ship_to_location_id := to_number(null);
    arp_tax.tax_info_rec.bill_to_location_id := to_number(null);
    arp_tax.tax_info_rec.invoicing_rule_id := to_number(null);
    arp_tax.tax_info_rec.extended_amount := null;
    arp_tax.tax_info_rec.trx_exchange_rate := null;
    arp_tax.tax_info_rec.trx_currency_code := null;
    arp_tax.tax_info_rec.minimum_accountable_unit := null;
    arp_tax.tax_info_rec.precision := null;
    arp_tax.tax_info_rec.default_ussgl_transaction_code := NULL;
    arp_tax.tax_info_rec.default_ussgl_trx_code_context := NULL;
    arp_tax.tax_info_rec.poo_code := null;
    arp_tax.tax_info_rec.poa_code := null;
    arp_tax.tax_info_rec.ship_from_code := null;
    arp_tax.tax_info_rec.ship_to_code := null;
    arp_tax.tax_info_rec.fob_point := null;
    arp_tax.tax_info_rec.taxed_quantity := null;
    arp_tax.tax_info_rec.part_no := null;
    arp_tax.tax_info_rec.tax_line_number := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.qualifier := null;
    arp_tax.tax_info_rec.calculate_tax := null;
    arp_tax.tax_info_rec.tax_precedence := NULL;
    arp_tax.tax_info_rec.tax_exemption_id := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.item_exception_rate_id := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.vdrctrl_exempt := NULL;
    arp_tax.tax_info_rec.userf1 := null;
    arp_tax.tax_info_rec.userf2 := null;
    arp_tax.tax_info_rec.userf3 := NULL;
    arp_tax.tax_info_rec.userf4 := NULL;
    arp_tax.tax_info_rec.userf5 := NULL;
    arp_tax.tax_info_rec.usern1 := null;
    arp_tax.tax_info_rec.usern2 := null;
    arp_tax.tax_info_rec.usern3 := null;
    arp_tax.tax_info_rec.usern4 := null;
    arp_tax.tax_info_rec.usern5 := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.trx_number := NULL;
    arp_tax.tax_info_rec.ship_to_customer_number := NULL;
    arp_tax.tax_info_rec.ship_to_customer_name := NULL;
    arp_tax.tax_info_rec.bill_to_customer_number := NULL;
    arp_tax.tax_info_rec.bill_to_customer_name := NULL;
    arp_tax.tax_info_rec.previous_customer_trx_line_id := to_number(NULL);
    arp_tax.tax_info_rec.previous_customer_trx_id := to_number(null);
    arp_tax.tax_info_rec.previous_trx_number := NULL;
    arp_tax.tax_info_rec.audit_flag := null;
    arp_tax.tax_info_rec.trx_line_type := NULL;
    arp_tax.tax_info_rec.division_code := null;
    arp_tax.tax_info_rec.company_code := null;
    arp_tax.tax_info_rec.tax_header_level_flag := null;
    arp_tax.tax_info_rec.tax_rounding_rule := null;
    arp_tax.tax_info_rec.vat_tax_id := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.trx_type_id := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.amount_includes_tax_flag := null;
    arp_tax.tax_info_rec.ship_from_warehouse_id := null;
    arp_tax.tax_info_rec.poo_id := to_number(null);
    arp_tax.tax_info_rec.poa_id := to_number(null);
    arp_tax.tax_info_rec.payment_term_id := to_number(null);
    arp_tax.tax_info_rec.payment_terms_discount_percent := NULL;
    arp_tax.tax_info_rec.taxable_basis := null;
    arp_tax.tax_info_rec.tax_calculation_plsql_block := null;
    arp_tax.tax_info_rec.userf6 := NULL;
    arp_tax.tax_info_rec.userf7 := NULL;
    arp_tax.tax_info_rec.userf8 := NULL;
    arp_tax.tax_info_rec.userf9 := NULL;
    arp_tax.tax_info_rec.userf10 := NULL;
    arp_tax.tax_info_rec.usern6 := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.usern7 := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.usern8 := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.usern9 := TO_NUMBER(NULL);
    arp_tax.tax_info_rec.usern10 := TO_NUMBER(NULL);
End initialize_Tax_info_rec;


Procedure aso_tax_line( p_api_version_number  IN         NUMBER,
                        p_qte_header_id       IN         NUMBER,
                        p_tax_control_rec     IN         Tax_Control_Rec_Type   :=  G_Miss_Tax_Control_Rec,
                        p_qte_line_id         IN         NUMBER                 :=  NULL,
                        x_tax_value           OUT NOCOPY   NUMBER,
                        x_tax_detail_tbl      OUT NOCOPY   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
                        x_return_status       OUT NOCOPY   VARCHAR2
) is

-- Declare local variables
x_tax_out_tbl                   ARP_TAX.om_tax_out_tab_type;

l_qte_header_rec                ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_qte_line_rec                  ASO_QUOTE_PUB.Qte_Line_rec_Type;
l_qte_line_tbl                  ASO_QUOTE_PUB.Qte_Line_tbl_Type;
l_Shipment_Rec                  ASO_QUOTE_PUB.Shipment_Rec_Type;
l_Shipment_tbl                  ASO_QUOTE_PUB.Shipment_tbl_Type;
l_tax_detail_rec                ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
l_tax_detail_tbl                ASO_QUOTE_PUB.Tax_Detail_tbl_Type;
l_hdr_tax_detail_tbl            ASO_QUOTE_PUB.Tax_Detail_tbl_Type;

l_qte_header_id                 NUMBER;
l_tax_method                    VARCHAR2(15) := NULL;
l_vendor_installed              VARCHAR2(1)  := NULL;

l_tax_rounding_allow_override   VARCHAR2(1);
l_tax_header_level_flag         VARCHAR2(1);
l_tax_rounding_rule             VARCHAR2(30);
l_set_of_books_id               NUMBER;
l_site_use_id                   NUMBER;
l_site_use_id_ship              NUMBER;
l_site_use_id_bill              NUMBER;
l_resource_id                   NUMBER;
l_poo_id                        NUMBER;
l_asgn_org_id                   NUMBER;

--Ship to Info

l_ship_to_site_use_id           NUMBER;
l_ship_to_address_id            NUMBER;
l_ship_to_customer_id           NUMBER;
l_ship_to_postal_code           VARCHAR2(60);
l_ship_to_location_ccid         NUMBER;
l_ship_to_customer_name         VARCHAR2(360);
l_ship_to_customer_number       VARCHAR2(30);
l_ship_to_state                 VARCHAR2(60);
l_ship_tax_header_level_flag    VARCHAR2(1);
l_ship_tax_rounding_rule        VARCHAR2(30);

--Bill to Info

l_bill_to_site_use_id           NUMBER;
l_bill_to_address_id            NUMBER;
l_bill_to_customer_id           NUMBER;
l_bill_to_postal_code           VARCHAR2(60);
l_bill_to_location_ccid         NUMBER;
l_bill_to_customer_name         VARCHAR2(360);
l_bill_to_customer_number       VARCHAR2(30);
l_bill_to_state                 VARCHAR2(60);
l_bill_tax_header_level_flag    VARCHAR2(1);
l_bill_tax_rounding_rule        VARCHAR2(30);
l_party_site_id                 NUMBER;
l_party_site_id_ship            NUMBER;
l_party_site_id_bill            NUMBER;

-- Others  bill to ,ship to
l_bc_tax_header_level_flag      VARCHAR2(1);
l_bc_tax_rounding_rule          VARCHAR2(30);

-- Currency info
l_minimum_accountable_unit      NUMBER;
l_precision                     NUMBER;
l_currency_code                 VARCHAR2(15);

--sales rep info
l_person_id                     NUMBER;
l_sales_tax_geocode             VARCHAR2(30);
l_sales_tax_inside_city_limits  VARCHAR2(1);
l_poa_id                        NUMBER;

--Order type line type
l_in_line_type                  NUMBER;
l_out_line_type                 NUMBER;
l_line_type_id                  NUMBER;
l_cust_trx_type_id              NUMBER;
l_trx_type_id                   NUMBER;
l_om_trx_type_id                NUMBER;
l_tax_code                      VARCHAR2(50);
l_tax_rate                      NUMBER;
l_amount_includes_tax_flag      VARCHAR2(1);
l_taxable_basis                 VARCHAR2(30);
l_tax_calculation_plsql_block   VARCHAR2(2000);
l_ra_cust_trx_type_id           NUMBER;

--Vertex and Taxware related
l_poo_address_code              VARCHAR2(4000) := NULL;
l_poa_address_code              VARCHAR2(4000) := NULL;
l_salesrep_id                   NUMBER;
l_ship_from_address_code        VARCHAR2(4000) := NULL;
l_ship_to_address_code          VARCHAR2(4000) := NULL;
l_part_number                   VARCHAR2(4000) := NULL;
l_vendor_control_exemptions     VARCHAR2(4000) := NULL;
l_attribute1                    VARCHAR2(4000) := NULL;
l_attribute2                    VARCHAR2(4000) := NULL;
l_division_code                 VARCHAR2(30)   := NULL;
l_company_code                  VARCHAR2(30)   := NULL;
l_numeric_attribute1            NUMBER         := NULL;
l_numeric_attribute2            NUMBER         := NULL;
l_numeric_attribute3            NUMBER         := NULL;
l_numeric_attribute4            NUMBER         := NULL;

--Payment term info
l_payment_term_id               NUMBER;

-- Default Tax code
l_vat_tax_id                    NUMBER;
l_amt_incl_tax_flag             VARCHAR2(1);
l_amt_incl_tax_override         VARCHAR2(1);
l_fiscal_classification         VARCHAR2(150);
l_transaction_cond_class        VARCHAR2(150);

l_hdr_tax_date                  DATE;
l_hdr_tax_exempt_flag           VARCHAR2(1);
l_hdr_tax_exempt_number         VARCHAR2(80);
l_hdr_tax_exempt_reason_code    VARCHAR2(30);

l_count                         NUMBER;
l_reason                        VARCHAR2(4000);
l_ship_from_org_id              NUMBER;
l_party_id                      NUMBER;

G_USER_ID                       NUMBER         := FND_GLOBAL.USER_ID;
G_LOGIN_ID                      NUMBER         := FND_GLOBAL.CONC_LOGIN_ID;
l_ship_loc_asgn_id              NUMBER;
l_bill_loc_asgn_id              NUMBER;

l_tax_start_time  number;
l_tax_end_time    number;
l_tax_total_time  number := 0;

cursor getlocinfo is
select s_ship.site_use_id,
       s_ship.cust_acct_site_id,
       acct_site_ship.cust_account_id,
       loc_ship.postal_code,
       loc_assign_ship.loc_id,
       cust_acct.party_id,
       cust_acct.account_number,
       cust_acct.tax_header_level_flag,
       cust_acct.tax_rounding_rule,
       loc_ship.state,
       s_ship.tax_header_level_flag,
       s_ship.tax_rounding_rule
FROM
       hz_cust_site_uses_all       s_ship ,
       hz_cust_acct_sites          acct_site_ship,
       hz_party_sites              party_site_ship,
       hz_locations                loc_ship,
       hz_loc_assignments          loc_assign_ship,
       hz_cust_accounts            cust_acct
WHERE  s_ship.site_use_id              =  l_site_use_id
  and  s_ship.cust_acct_site_id        =  acct_site_ship.cust_acct_site_id
  and  acct_site_ship.cust_account_id  =  cust_acct.cust_account_id
  and  acct_site_ship.party_site_id    =  party_site_ship.party_site_id
  and  party_site_ship.location_id     =  loc_ship.location_id
  and  acct_site_ship.org_id = loc_assign_ship.org_id ;  -- New code Yogeshwar (MOAC)
  --Commented Code Yogeshwar Start (MOAC)
--  and  NVL(acct_site_ship.org_id,
--		 NVL(to_number(decode(substrb(userenv('client_info'),1 ,1), ' ',null,
--               substrb(userenv('client_info'), 1,10))),-99))  =
--       NVL(loc_assign_ship.org_id,
--           NVL(to_number(decode( substrb(userenv('client_info'),1,1), ' ',null,
--               substrb(userenv('client_info'),1,10))), -99));
--End of comments Yogeshwar (MOAC)
--Need ORG striped synonym for HZ_LOC_ASSIGNMENTS
cursor getpartyinfo is
    select  sl.postal_code, sla.loc_id, sl.location_id
    from    hz_party_sites  sps,
            hz_locations sl,
            hz_loc_assignments sla
    where   sps.party_site_id = l_party_site_id
            and SPS.location_id = SL.location_id
            and sl.location_id = sla.location_id ;
            --Commented Code Yogeshwar (MOAC)
--	    and sla.org_id = nvl(to_number(decode(substrb( userenv('CLIENT_INFO'),1,1),' ', null,
--                                 substrb(userenv('CLIENT_INFO'),1,10))),-99);
 --End of commented Code -- Yogeshwar (MOAC)
--Need ORG striped synonym for HZ_LOC_ASSIGNMENTS
cursor c_currency is
    select minimum_accountable_unit,precision
    from   fnd_currencies
    where  currency_code = l_currency_code;

cursor c_person(c_resource_id number) is
    select  person_id,sales_tax_geocode,sales_tax_inside_city_limits, salesrep_id
   -- from    jtf_rs_srp_vl  Commented code Yogeshwar (MOAC)
    from JTF_RS_SALESREPS_MO_V --New Code Yogeshwar (MOAC)
    where   resource_id=c_resource_id ;
--Commented code start yogeshwar (MOAC)
--      and nvl(org_id,nvl(to_number(decode(substrb(userenv('CLIENT_INFO'),1,1), ' ',
--      null, substrb(userenv('CLIENT_INFO'),1,10))),-99)) = nvl(to_number(decode(substrb(
--      userenv('CLIENT_INFO'),1,1), ' ', null, substrb(userenv('CLIENT_INFO'),1,10))),-99);
--Commented code end yogeshwar (MOAC)

cursor c_asgn(c_person_id number) is
    select  organization_id
    from    per_all_assignments_f
    where   person_id = c_person_id
            and  nvl(primary_flag, 'Y') = 'Y'
            and  sysdate  between nvl(effective_start_date,to_date( '01011900', 'DDMMYYYY'))
                                and nvl(effective_end_date,to_date( '31122199', 'DDMMYYYY'));


cursor c_tax_code( c_tax_id number ) is
select tax_code
from  ar_vat_tax
where vat_tax_id = c_tax_id;

cursor getpartyname (p_party_id number) is
select party_name
from   hz_parties
where  party_id = p_party_id;

cursor c_global_attributes( p_inventory_item_id number, p_organization_id number) is
select global_attribute1, global_attribute2
from mtl_system_items_b
where inventory_item_id = p_inventory_item_id
and   organization_id   = p_organization_id;

Begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('ASO_TAX_INT: Begin ASO_TAX_LINE', 1, 'Y');

        aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: p_qte_header_id: '|| p_qte_header_id, 1, 'Y');
        aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: p_qte_line_id:   '|| p_qte_line_id, 1, 'Y');

    END IF;

    -- Retrieve Quote header and line information from database
    l_qte_header_rec    := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_id);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: After call to ASO_UTILITY_PVT.Query_Header_Row', 1, 'Y');
    END IF;

    If p_qte_line_id is null or p_qte_line_id = FND_API.G_MISS_NUM then

        l_qte_line_tbl := ASO_UTILITY_PVT.Query_Qte_Line_Rows(p_qte_header_id);

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_TAX_LINE: After call to ASO_UTILITY_PVT.Query_Qte_Line_Rows', 1, 'Y');
        END IF;

    else

        l_qte_line_rec    := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_qte_line_id);
        l_qte_line_tbl(1) := l_qte_line_rec;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_TAX_LINE: After call to ASO_UTILITY_PVT.Query_Qte_Line_Row', 1, 'Y');
        END IF;

    end if;

    -- Get the tax method

    Begin

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: Before call to ARP_TAX_CRM_INTEGRATION_PKG.tax_method', 1, 'Y');
       END IF;

       arp_tax_crm_integration_pkg.tax_method (l_tax_method,l_vendor_installed);

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_TAX_LINE: After Call to tax_method', 1, 'Y');
           aso_debug_pub.add('ASO_TAX_LINE: l_tax_method:       '|| l_tax_method, 1, 'Y');
           aso_debug_pub.add('ASO_TAX_LINE: l_vendor_installed: '|| l_vendor_installed, 1, 'Y');
       END IF;

       EXCEPTION

	        WHEN OTHERS THEN

                IF aso_debug_pub.g_debug_flag = 'Y' THEN

	               aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: Exception raised in ARP_TAX_CRM_INTEGRATION_PKG.tax_method', 1, 'Y');

			 END IF;

                l_reason := 'ARP_TAX_CRM_INTEGRATION_PKG.tax_method is raising an exception.';

                aso_quote_misc_pvt.debug_tax_info_notification(l_qte_header_rec, l_Shipment_rec, l_reason);
    End;

    IF p_qte_header_id is not null and p_qte_header_id <> FND_API.G_MISS_NUM then

        Begin

            -- Get the AR system parameters

            select  tax_rounding_allow_override,
                    tax_header_level_flag,
                    tax_rounding_rule,
                    set_of_books_id
            into    l_tax_rounding_allow_override,
                    l_tax_header_level_flag,
                    l_tax_rounding_rule,
                    l_set_of_books_id
            from    ar_system_parameters;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_TAX_LINE: NO_DATA_FOUND from AR_SYSTEM_PARAMETERS table', 1, 'Y');
                    END IF;

                    l_reason := 'No Data Found while selecting tax_rounding_rule, set_of_books_id';
                    l_reason := l_reason || 'from ar_system_parameters table.';

                    aso_quote_misc_pvt.debug_tax_info_notification( l_qte_header_rec,
                                                                    l_Shipment_rec, l_reason);

        End;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN

            aso_debug_pub.add('ASO_TAX_LINE: After selecting from AR_SYSTEM_PARAMETERS table.', 1, 'Y');
            aso_debug_pub.add('l_tax_rounding_allow_override: '|| l_tax_rounding_allow_override, 1, 'Y');
            aso_debug_pub.add('l_tax_header_level_flag:       '|| l_tax_header_level_flag, 1, 'Y');
            aso_debug_pub.add('l_tax_rounding_rule:           '|| l_tax_rounding_rule, 1, 'Y');
            aso_debug_pub.add('l_set_of_books_id:             '|| l_set_of_books_id, 1, 'Y');

            aso_debug_pub.add('ASO_TAX_LINE: Before beginng of the  Quote line loop', 1, 'Y');
            aso_debug_pub.add('ASO_TAX_LINE: l_qte_line_tbl.count: '||l_qte_line_tbl.count, 1, 'Y');

        END IF;


        FOR  i  IN  1..l_qte_line_tbl.count  LOOP


            l_shipment_tbl := aso_utility_pvt.query_shipment_rows( p_qte_header_id,
                                                                   l_qte_line_tbl(i).quote_line_id);

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_TAX_LINE: l_shipment_tbl.count: '|| l_shipment_tbl.count, 1, 'Y');
            END IF;

            l_shipment_rec := l_shipment_tbl(1);
            l_qte_line_rec := l_qte_line_tbl(i);

            -- Get ship_from_org_id
		  l_ship_from_org_id := ASO_SHIPMENT_PVT.get_ship_from_org_id(p_qte_header_id,
                                                                        l_qte_line_tbl(i).quote_line_id);

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('ASO_TAX_LINE: After call to Get_ship_from_org_id: l_ship_from_org_id: '||l_ship_from_org_id, 1, 'Y');
		  END IF;

		  IF l_ship_from_org_id IS NULL OR l_ship_from_org_id = FND_API.G_MISS_NUM THEN

		       l_ship_from_org_id := fnd_profile.value( 'ASO_SHIP_FROM_ORG_ID' );

			  IF aso_debug_pub.g_debug_flag = 'Y' THEN
			      aso_debug_pub.add('ASO_TAX_LINE: Profile ASO_SHIP_FROM_ORG_ID value', 1, 'Y');
			      aso_debug_pub.add('ASO_TAX_LINE: l_ship_from_org_id: '|| l_ship_from_org_id, 1, 'Y');
                 END IF;

		  END IF;

            --Get Line type info
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: Before call to get_ra_trx_type_id', 1, 'Y');
            END IF;

            l_trx_type_id := get_ra_trx_type_id(l_qte_header_rec.order_type_id,l_qte_line_rec);

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('After call to get_ra_trx_type_id: l_trx_type_id: '|| l_trx_type_id, 1, 'Y');
            END IF;

            --Get the currency info
            IF l_qte_line_tbl(i).currency_code is not null THEN
                l_currency_code := l_qte_line_tbl(i).currency_code;
            ELSE
                l_currency_code := l_qte_header_rec.currency_code;
            END IF;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_TAX_LINE: l_currency_code: '|| l_currency_code, 1, 'Y');
            END IF;


            --Get site use information
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_TAX_LINE: Before call to aso_shipment_pvt.get_ship_to_site_id', 1, 'Y');
            END IF;

            l_site_use_id_ship := aso_shipment_pvt.get_ship_to_site_id( l_shipment_rec.quote_header_id,
                                                                        l_shipment_rec.quote_line_id,
                                                                        l_shipment_rec.shipment_id );

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('After call: l_site_use_id_ship: ' || l_site_use_id_ship, 1, 'Y');
                aso_debug_pub.add('Before call to aso_shipment_pvt.get_cust_to_party_site_id', 1, 'Y');
            END IF;

            l_site_use_id_bill := aso_shipment_pvt.get_cust_to_party_site_id
                                                                    ( l_qte_line_tbl(i).quote_header_id,
                                                                      l_qte_line_tbl(i).quote_line_id );

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('After call: l_site_use_id_bill: '|| l_site_use_id_bill, 1, 'Y');
                aso_debug_pub.add('Before call to aso_payment_int.get_payment_term_id', 1, 'Y');
            END IF;


            l_payment_term_id := aso_payment_int.get_payment_term_id( p_qte_header_id,
                                                                      l_qte_line_tbl(i).quote_line_id);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('After call: l_payment_term_id: '|| l_payment_term_id, 1, 'Y');
            END IF;

            l_tax_detail_tbl     := aso_utility_pvt.query_tax_detail_Rows( p_qte_header_id,
										                         l_qte_line_tbl(i).quote_line_id,
                                                                           l_shipment_tbl);

            l_hdr_tax_detail_tbl := aso_utility_pvt.query_tax_detail_rows( p_qte_header_id, null,
														     l_shipment_tbl);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_TAX_LINE: l_tax_detail_tbl.count:      '||l_tax_detail_tbl.count, 1, 'Y');
                aso_debug_pub.add('ASO_TAX_LINE: l_hdr_tax_detail_tbl.count : '||l_hdr_tax_detail_tbl.count, 1, 'Y');
            END IF;

            IF l_hdr_tax_detail_tbl.count > 0 THEN

                IF l_hdr_tax_detail_tbl(1).tax_exempt_flag is null  THEN

                     l_hdr_tax_exempt_flag := 'S';
                ELSE
                     l_hdr_tax_exempt_flag := l_hdr_tax_detail_tbl(1).tax_exempt_flag;
                END IF;

                IF l_hdr_tax_detail_tbl(1).tax_exempt_number is null  THEN

                     l_hdr_tax_exempt_number := null;
                ELSE
                     l_hdr_tax_exempt_number := l_hdr_tax_detail_tbl(1).tax_exempt_number;
                END IF;

                IF l_hdr_tax_detail_tbl(1).tax_exempt_reason_code is null  THEN

                     l_hdr_tax_exempt_reason_code := null;
                ELSE
                     l_hdr_tax_exempt_reason_code := l_hdr_tax_detail_tbl(1).tax_exempt_reason_code;
                END IF;

                IF l_hdr_tax_detail_tbl(1).tax_date is null  THEN

                     l_hdr_tax_date := l_sys_date;--sysdate;
                ELSE
                     l_hdr_tax_date := l_hdr_tax_detail_tbl(1).tax_date;
                END IF;

            ELSE

                l_hdr_tax_date                :=  l_sys_date;--sysdate;
                l_hdr_tax_exempt_number       :=  null;
                l_hdr_tax_exempt_reason_code  :=  null;
                l_hdr_tax_exempt_flag         :=  'S';

            END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN

                aso_debug_pub.add('ASO_TAX_LINE: Header level exemption information', 1, 'Y');
                aso_debug_pub.add('l_hdr_tax_date:               '|| l_hdr_tax_date, 1, 'Y');
                aso_debug_pub.add('l_hdr_tax_exempt_number:      '|| l_hdr_tax_exempt_number, 1, 'Y');
                aso_debug_pub.add('l_hdr_tax_exempt_reason_code: '|| l_hdr_tax_exempt_reason_code, 1, 'Y');
                aso_debug_pub.add('l_hdr_tax_exempt_flag:        '|| l_hdr_tax_exempt_flag, 1, 'Y');

                aso_debug_pub.add('Before selecting cust_trx_type_id from ra_cust_trx_types_all table', 1, 'Y');
                aso_debug_pub.add('ASO_TAX_LINE: l_trx_type_id:  '|| l_trx_type_id, 1, 'Y');

            END IF;


            IF l_tax_method <> 'LATIN' THEN

            Begin

                select cust_trx_type_id
                into l_ra_cust_trx_type_id
                --from ra_cust_trx_types_all Commented Code yogeshwar (MOAC)
		from ra_cust_trx_types  --New Code Yogeshwar (MOAC)
                where cust_trx_type_id = l_trx_type_id
                   --Commented Code Start Yogeshwar (MOAC)
--		   and nvl(org_id,
--                       nvl(to_number(decode(substrb(userenv('CLIENT_INFO'),1 ,1), ' ',null,
--                       substrb(userenv('CLIENT_INFO'), 1,10))),-99)) =
--                       nvl(l_qte_header_rec.org_id,
--                       nvl(to_number(decode( substrb(userenv('CLIENT_INFO'),1,1), ' ',null,
--                       substrb(userenv('CLIENT_INFO'),1,10))), -99))
		   --Commented Code End Yogeshwar (MOAC)
                   and ((tax_calculation_flag = 'Y')
                   or  (l_hdr_tax_exempt_flag='R' ) );

                EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
    			            aso_debug_pub.add('ASO_TAX_LINE: NO_DATA_FOUND when selecting cust_trx_type_id', 1, 'Y');
                       END IF;

			        l_reason := 'No Data Found Exception raised while selecting cust_trx_type_id';
			        l_reason := l_reason || 'from ra_cust_trx_types_all. ';
			        l_reason := l_reason || fnd_global.newline();
			        l_reason := l_reason || 'Please check Default order type id profile is correctly';
			        l_reason := l_reason || 'set. Also pl verify the';
			        l_reason := l_reason || fnd_global.newline();
			        l_reason := l_reason || 'the value the profile is returning. No tax call being';
			        l_reason := l_reason || 'being made to tax engine.';

			        aso_quote_misc_pvt.debug_tax_info_notification(l_qte_header_rec,
                                                                      l_Shipment_rec, l_reason);

                       if aso_debug_pub.g_debug_flag = 'Y' then
                           aso_debug_pub.add('ASO_TAX_LINE: Before deleting all tax records for the quote line', 1, 'Y');
                       end if;

                       if l_tax_detail_tbl.count > 0 then

                           delete from aso_tax_details
			            where quote_header_id  = l_tax_detail_tbl(1).quote_header_id
                           and quote_line_id = l_tax_detail_tbl(1).quote_line_id ;

                       end if;

                       if aso_debug_pub.g_debug_flag = 'Y' then
                           aso_debug_pub.add('ASO_TAX_LINE: After deleting all tax records for the quote line', 1, 'Y');
                       end if;

            End;

            open  c_currency;
            fetch c_currency into l_minimum_accountable_unit, l_precision;
            close c_currency;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_TAX_LINE: l_ra_cust_trx_type_id:      '|| l_ra_cust_trx_type_id, 1, 'Y');
                aso_debug_pub.add('ASO_TAX_LINE: After c_currency cursor fetch', 1, 'Y');
                aso_debug_pub.add('ASO_TAX_LINE: l_minimum_accountable_unit: '|| l_minimum_accountable_unit, 1, 'Y');
                aso_debug_pub.add('ASO_TAX_LINE: l_precision:                '|| l_precision, 1, 'Y');
            END IF;

            IF l_qte_header_rec.resource_id is NOT NULL THEN

                open  c_person(l_qte_header_rec.resource_id);
                fetch c_person into l_person_id, l_sales_tax_geocode,
                                    l_sales_tax_inside_city_limits, l_salesrep_id;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: After c_person cursor fetch', 1, 'Y');
                    aso_debug_pub.add('l_person_id:                    '|| l_person_id, 1, 'Y');
                    aso_debug_pub.add('l_sales_tax_geocode:            '|| l_sales_tax_geocode, 1, 'Y');
                    aso_debug_pub.add('l_sales_tax_inside_city_limits: '|| l_sales_tax_inside_city_limits, 1, 'Y');
                    aso_debug_pub.add('l_salesrep_id:                  '|| l_salesrep_id, 1, 'Y');
                END IF;


                IF C_PERSON%NOTFOUND THEN
                    CLOSE C_PERSON;
                    l_POO_ID := l_qte_header_rec.org_id;
                    l_person_id :=NULL;
                    L_SALES_TAX_GEOCODE :=NULL;
                    L_SALES_TAX_INSIDE_CITY_LIMITS := NULL;

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_TAX_LINE: Inside C_PERSON%NOTFOUND: l_POO_ID: '||l_POO_ID, 1, 'Y');
                    END IF;

                ELSE
                    CLOSE C_PERSON;
                    OPEN C_ASGN(l_person_id);
                    FETCH C_ASGN INTO l_asgn_org_id;
                    IF C_ASGN%NOTFOUND THEN
                        l_asgn_org_id := NULL;
                    ELSE
                        l_poo_id := l_asgn_org_id;

				    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Inside c_person%found and c_asgn%found: l_poo_id: '|| l_poo_id, 1, 'Y');
                        END IF;

                    END IF;
                    CLOSE C_ASGN;

                END IF;

            ELSE

                L_POO_ID := l_qte_header_rec.org_id;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: IF l_qte_header_rec.resource_id is NULL then: l_POO_ID: '||l_POO_ID, 1,'Y');
                END IF;

            END IF;


            IF l_site_use_id_ship is not null AND  l_site_use_id_ship <> FND_API.G_MISS_NUM THEN

                l_site_use_id := l_site_use_id_ship;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: Inside l_site_use_id_ship IF Cond: l_site_use_id: ' || l_site_use_id, 1, 'Y');
                END IF;

                OPEN getlocinfo;
                FETCH getlocinfo
                INTO L_SHIP_TO_SITE_USE_ID,
                     L_SHIP_TO_ADDRESS_ID,
                     L_SHIP_TO_CUSTOMER_ID,
                     L_SHIP_TO_POSTAL_CODE,
                     L_SHIP_TO_LOCATION_CCID,
                     L_PARTY_ID,
                     L_SHIP_TO_CUSTOMER_NUMBER,
                     L_BC_TAX_HEADER_LEVEL_FLAG,
                     L_BC_TAX_ROUNDING_RULE,
                     L_SHIP_TO_STATE,
                     L_SHIP_TAX_HEADER_LEVEL_FLAG,
                     L_SHIP_TAX_ROUNDING_RULE;

                IF getlocinfo%NOTFOUND THEN

                     L_SHIP_TO_ADDRESS_ID       := -1;
                     L_SHIP_TO_CUSTOMER_ID      := NULL;
                     L_SHIP_TO_POSTAL_CODE      := NULL;
                     L_SHIP_TO_LOCATION_CCID    := NULL;
                     L_SHIP_TO_CUSTOMER_NAME    := NULL;
                     L_SHIP_TO_CUSTOMER_NUMBER  := NULL;
                     L_BC_TAX_HEADER_LEVEL_FLAG := NULL;
                     L_BC_TAX_ROUNDING_RULE     := NULL;

                ELSE
				 IF aso_debug_pub.g_debug_flag = 'Y' THEN

                         aso_debug_pub.add('ASO_TAX_LINE: Inside else cond of getlocinfo cursor for SHIP_TO', 1, 'Y');
                         aso_debug_pub.add('ASO_TAX_LINE: l_party_id: '|| l_party_id, 1, 'Y');

                     END IF;

                     open  getpartyname (l_party_id);
                     fetch getpartyname into l_ship_to_customer_name;
                     close getpartyname;

				 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('ASO_TAX_LINE: l_ship_to_customer_name: '|| l_ship_to_customer_name, 1, 'Y');
                     END IF;

                END IF;
                CLOSE getlocinfo;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN

                   aso_debug_pub.add('ASO_TAX_LINE: Inside l_site_use_id_ship IF Cond: After fetching getlocinfo cursor.', 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_SITE_USE_ID:      '|| L_SHIP_TO_SITE_USE_ID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_ADDRESS_ID:       '|| L_SHIP_TO_ADDRESS_ID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_CUSTOMER_ID:      '|| L_SHIP_TO_CUSTOMER_ID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_POSTAL_CODE:      '|| L_SHIP_TO_POSTAL_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_LOCATION_CCID:    '|| L_SHIP_TO_LOCATION_CCID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_CUSTOMER_NAME:    '|| L_SHIP_TO_CUSTOMER_NAME, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_CUSTOMER_NUMBER:  '|| L_SHIP_TO_CUSTOMER_NUMBER, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BC_TAX_HEADER_LEVEL_FLAG: '|| L_BC_TAX_HEADER_LEVEL_FLAG, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BC_TAX_ROUNDING_RULE:     '|| L_BC_TAX_ROUNDING_RULE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_STATE:            '|| L_SHIP_TO_STATE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TAX_ROUNDING_RULE:   '|| L_SHIP_TAX_ROUNDING_RULE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TAX_HEADER_LEVEL_FLAG: ' || L_SHIP_TAX_HEADER_LEVEL_FLAG, 1, 'Y');
                END IF;

            END IF; -- l_site_use_id_ship;


            IF l_site_use_id_bill is not null and l_site_use_id_bill <> FND_API.G_MISS_NUM THEN

                l_site_use_id := l_site_use_id_bill;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: Inside l_site_use_id_bill IF Cond: l_site_use_id: ' || l_site_use_id, 1, 'Y');
                END IF;

                OPEN getlocinfo;
                FETCH getlocinfo
                INTO L_BILL_TO_SITE_USE_ID,
                     L_BILL_TO_ADDRESS_ID,
                     L_BILL_TO_CUSTOMER_ID,
                     L_BILL_TO_POSTAL_CODE,
                     L_BILL_TO_LOCATION_CCID,
                     L_PARTY_ID,
                     L_BILL_TO_CUSTOMER_NUMBER,
                     L_BC_TAX_HEADER_LEVEL_FLAG,
                     L_BC_TAX_ROUNDING_RULE,
                     L_BILL_TO_STATE,
                     L_BILL_TAX_HEADER_LEVEL_FLAG,
                     L_BILL_TAX_ROUNDING_RULE;

                IF getlocinfo%NOTFOUND THEN

                     L_BILL_TO_ADDRESS_ID       := -1;
                     L_BILL_TO_CUSTOMER_ID      := NULL;
                     L_BILL_TO_POSTAL_CODE      := NULL;
                     L_BILL_TO_LOCATION_CCID    := NULL;
                     L_BILL_TO_CUSTOMER_NAME    := NULL;
                     L_BILL_TO_CUSTOMER_NUMBER  := NULL;
                     L_BC_TAX_HEADER_LEVEL_FLAG := NULL;
                     L_BC_TAX_ROUNDING_RULE     := NULL;

                ELSE
                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('ASO_TAX_LINE: Inside else cond of getlocinfo cursor for BILL_TO', 1, 'Y');
                         aso_debug_pub.add('ASO_TAX_LINE: l_party_id: '|| l_party_id, 1, 'Y');
                     END IF;

                     OPEN  getpartyname (l_party_id);
                     FETCH getpartyname INTO l_bill_to_customer_name;
                     CLOSE getpartyname;

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('ASO_TAX_LINE: l_bill_to_customer_name: '|| l_bill_to_customer_name, 1, 'Y');
                     END IF;

                END IF;
                CLOSE getlocinfo;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN

                   aso_debug_pub.add('ASO_TAX_LINE: Inside l_site_use_id_bill IF Cond: After fetching getlocinfo cursor.', 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_SITE_USE_ID:      '|| L_BILL_TO_SITE_USE_ID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_ADDRESS_ID:       '|| L_BILL_TO_ADDRESS_ID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_CUSTOMER_ID:      '|| L_BILL_TO_CUSTOMER_ID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_POSTAL_CODE:      '|| L_BILL_TO_POSTAL_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_LOCATION_CCID:    '|| L_BILL_TO_LOCATION_CCID, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_CUSTOMER_NAME:    '|| L_BILL_TO_CUSTOMER_NAME, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_CUSTOMER_NUMBER:  '|| L_BILL_TO_CUSTOMER_NUMBER, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BC_TAX_HEADER_LEVEL_FLAG: '|| L_BC_TAX_HEADER_LEVEL_FLAG, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BC_TAX_ROUNDING_RULE:     '|| L_BC_TAX_ROUNDING_RULE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_STATE:            '|| L_BILL_TO_STATE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TAX_ROUNDING_RULE:   '|| L_BILL_TAX_ROUNDING_RULE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TAX_HEADER_LEVEL_FLAG: '|| L_BILL_TAX_HEADER_LEVEL_FLAG, 1, 'Y');

                END IF;

            END IF; -- l_site_use_id_bill

            IF (l_site_use_id_ship is  null  OR  l_site_use_id_ship = FND_API.G_MISS_NUM) AND
		     (l_site_use_id_bill is  null  OR  l_site_use_id_bill = FND_API.G_MISS_NUM) THEN

                -- Ship to party_site information
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: Before call to ASO_SHIPMENT_PVT.Get_ship_to_party_site_id', 1, 'Y');
                END IF;

                l_party_site_id_ship := ASO_SHIPMENT_PVT.Get_ship_to_party_site_id(l_shipment_rec.quote_header_id, l_shipment_rec.quote_line_id, l_shipment_rec.shipment_id);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: After call to Get_ship_to_party_site_id: l_party_site_id_ship: '|| l_party_site_id_ship, 1, 'Y');
                END IF;

                IF l_party_site_id_ship IS NOT NULL AND l_party_site_id_ship <> FND_API.G_MISS_NUM THEN

                    l_party_site_id := l_party_site_id_ship;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_TAX_LINE: Inside l_party_site_id_ship IF Cond: l_party_site_id: '|| l_party_site_id, 1, 'Y');
                    END IF;

                    OPEN getpartyinfo;
                    FETCH getpartyinfo INTO l_ship_to_postal_code, l_ship_to_location_ccid,l_ship_loc_asgn_id;
                    IF getpartyinfo%NOTFOUND THEN
                        L_SHIP_TO_POSTAL_CODE     := NULL;
                        L_SHIP_TO_LOCATION_CCID   := NULL;
                        L_SHIP_LOC_ASGN_ID        := NULL;
                    END IF;
                    CLOSE getpartyinfo;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN

                        aso_debug_pub.add('ASO_TAX_LINE: Inside l_party_site_id_ship IF Cond: After fetching getpartyinfo cursor.', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_POSTAL_CODE:   ' || L_SHIP_TO_POSTAL_CODE, 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_TO_LOCATION_CCID: ' || L_SHIP_TO_LOCATION_CCID, 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_LINE: L_SHIP_LOC_ASGN_ID:      ' || L_SHIP_LOC_ASGN_ID, 1, 'Y');

                    END IF;

                END IF; --l_party_site_id_ship

                -- Bill to party_site information
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: Before call to ASO_SHIPMENT_PVT.Get_invoice_to_party_site_id', 1,'Y');
                END IF;

                l_party_site_id_bill := ASO_SHIPMENT_PVT.Get_invoice_to_party_site_id( l_shipment_rec.quote_header_id, l_shipment_rec.quote_line_id);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: After call to Get_invoice_to_party_site_id: l_party_site_id_bill: '|| l_party_site_id_bill,1,'Y');
                END IF;

                IF l_party_site_id_bill IS NOT NULL AND l_party_site_id_bill <> FND_API.G_MISS_NUM THEN

                    l_party_site_id := l_party_site_id_bill;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_TAX_LINE: Inside l_party_site_id_bill IF Cond: l_party_site_id: '|| l_party_site_id,1,'Y');
                    END IF;

                    OPEN getpartyinfo;
                    FETCH getpartyinfo INTO l_bill_to_postal_code, l_bill_to_location_ccid,l_bill_loc_asgn_id;

                    IF getpartyinfo%NOTFOUND THEN

                         l_bill_to_postal_code     := null;
                         l_bill_to_location_ccid   := null;
                         l_bill_loc_asgn_id        := null;

                    END IF;

                    CLOSE getpartyinfo;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN

                        aso_debug_pub.add('ASO_TAX_LINE: Inside l_party_site_id_bill IF Cond: After fetching getpartyinfo cursor.', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_POSTAL_CODE:   ' || L_BILL_TO_POSTAL_CODE, 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_LINE: L_BILL_TO_LOCATION_CCID: ' || L_BILL_TO_LOCATION_CCID, 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_LINE: L_BILL_LOC_ASGN_ID:      ' || L_BILL_LOC_ASGN_ID, 1, 'Y');

                    END IF;

                END IF;--l_party_site_id

            END IF; --l_site_use_id bill and l_site_use_id_ship;


            IF nvl(l_tax_rounding_allow_override, 'N') =  'Y' THEN

                l_tax_header_level_flag :=  nvl( l_bill_tax_header_level_flag,
								    nvl( l_bc_tax_header_level_flag,
								    nvl( l_tax_header_level_flag, 'N' )));
            ELSE

                l_tax_header_level_flag :=  nvl( l_tax_header_level_flag, 'N' );

            END IF;

            IF nvl(l_tax_rounding_allow_override, 'N') = 'Y' THEN

                l_tax_rounding_rule := nvl( l_bill_tax_rounding_rule, nvl( l_bc_tax_rounding_rule,
                                                           nvl( l_tax_rounding_rule, 'NEAREST')));
            ELSE

                l_tax_rounding_rule := nvl(l_tax_rounding_rule, 'NEAREST' );

            END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_TAX_LINE: l_tax_header_level_flag: '|| l_tax_header_level_flag, 1, 'Y');
                aso_debug_pub.add('ASO_TAX_LINE: l_tax_rounding_rule:     '|| l_tax_rounding_rule, 1, 'Y');
            END IF;


            IF l_tax_method = 'VERTEX' then

            Begin

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: Inside IF cond l_tax_method = VERTEX ', 1, 'Y');
                END IF;

                L_POO_ADDRESS_CODE := ARP_TAX_VIEW_VERTEX.POO_ADDRESS_CODE('ASO_TAX_LINES_SUMMARY_V_V',
                                                           P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID);

                L_POA_ADDRESS_CODE :=  ARP_TAX_VIEW_VERTEX.POA_ADDRESS_CODE('ASO_TAX_LINES_SUMMARY_V_V',
									P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID,L_SALESREP_ID);

                L_SHIP_FROM_ADDRESS_CODE := ARP_TAX_VIEW_VERTEX.SHIP_FROM_ADDRESS_CODE
                                           ('ASO_TAX_LINES_SUMMARY_V_V',P_QTE_HEADER_ID,
                                            L_SHIPMENT_REC.SHIPMENT_ID,l_ship_from_org_id);

                L_SHIP_TO_ADDRESS_CODE := ARP_TAX_VIEW_VERTEX.SHIP_TO_ADDRESS_CODE
                                         ('ASO_TAX_LINES_SUMMARY_V_V',P_QTE_HEADER_ID,
                                           L_SHIPMENT_REC.SHIPMENT_ID,
                                           nvl(L_SHIP_TO_ADDRESS_ID, L_BILL_TO_ADDRESS_ID),
                                           nvl(L_SHIP_TO_LOCATION_CCID, L_BILL_TO_LOCATION_CCID),
                                           SYSDATE,nvl(L_SHIP_TO_STATE, L_BILL_TO_STATE),
                                           nvl(L_SHIP_TO_postal_code, L_BILL_TO_postal_code));

                L_PART_NUMBER := ARP_TAX_VIEW_VERTEX.PRODUCT_CODE('ASO_TAX_LINES_SUMMARY_V_V',
								 P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID,
                                         l_qte_line_tbl(i).INVENTORY_ITEM_ID,null);

                L_VENDOR_CONTROL_EXEMPTIONS := ARP_TAX_VIEW_VERTEX.VENDOR_CONTROL_EXEMPTIONS('ASO_TAX_LINES_SUMMARY_V_V', P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID, l_trx_type_id);

                L_ATTRIBUTE1 := ARP_TAX_VIEW_VERTEX.TRX_LINE_TYPE('ASO_TAX_LINES_SUMMARY_V_V',
											  P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID);

                L_ATTRIBUTE2 := ARP_TAX_VIEW_VERTEX.CUSTOMER_CLASS('ASO_TAX_LINES_SUMMARY_V_V',
										 P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID,
                                                   nvl(L_SHIP_TO_CUSTOMER_ID,L_BILL_TO_CUSTOMER_ID));

                L_DIVISION_CODE := ARP_TAX_VIEW_VERTEX.DIVISION_CODE('ASO_TAX_LINES_SUMMARY_V_V',
										 P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID);

                L_COMPANY_CODE := ARP_TAX_VIEW_VERTEX.COMPANY_CODE('ASO_TAX_LINES_SUMMARY_V_V',
										 P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID);

                L_NUMERIC_ATTRIBUTE1 := ARP_TAX_VIEW_VERTEX.USE_SECONDARY ('ASO_TAX_LINES_SUMMARY_V_V',
										 P_QTE_HEADER_ID,L_SHIPMENT_REC.SHIPMENT_ID);

                L_NUMERIC_ATTRIBUTE2 := ARP_TAX_VIEW_VERTEX.STATE_TYPE ('ASO_TAX_LINES_SUMMARY_V_V',
										 P_QTE_HEADER_ID,L_SHIPMENT_REC.SHIPMENT_ID);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN

                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_POO_ADDRESS_CODE'||L_POO_ADDRESS_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_POA_ADDRESS_CODE'||L_POA_ADDRESS_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_SHIP_FROM_ADDRESS_CODE'||L_SHIP_FROM_ADDRESS_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_SHIP_TO_ADDRESS_CODE'||L_SHIP_TO_ADDRESS_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_PART_NUMBER'||L_PART_NUMBER, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_VENDOR_CONTROL_EXEMPTIONS'||L_VENDOR_CONTROL_EXEMPTIONS, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_ATTRIBUTE1'||L_ATTRIBUTE1, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_ATTRIBUTE2'||L_ATTRIBUTE2, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_DIVISION_CODE'||L_DIVISION_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_COMPANY_CODE'||L_COMPANY_CODE, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_NUMERIC_ATTRIBUTE1'||L_NUMERIC_ATTRIBUTE1, 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: Inside vertex: L_NUMERIC_ATTRIBUTE2'||L_NUMERIC_ATTRIBUTE2, 1, 'Y');

                END IF;

              End; -- VERTEX

            ELSIF l_tax_method = 'TAXWARE' then

              Begin

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_INT: ASO_TAX_LINE: Inside IF cond l_tax_method = TAXWARE ', 1, 'Y');
                END IF;

                L_POO_ADDRESS_CODE := ARP_TAX_VIEW_TAXWARE.POO_ADDRESS_CODE('ASO_TAX_LINES_SUMMARY_V_A',
									 P_QTE_HEADER_ID,L_SHIPMENT_REC.SHIPMENT_ID,L_SALESREP_ID);

                L_POA_ADDRESS_CODE :=  ARP_TAX_VIEW_TAXWARE.POA_ADDRESS_CODE('ASO_TAX_LINES_SUMMARY_V_A',
									 P_QTE_HEADER_ID,L_SHIPMENT_REC.SHIPMENT_ID);

                L_SHIP_FROM_ADDRESS_CODE := ARP_TAX_VIEW_TAXWARE.SHIP_FROM_ADDRESS_CODE
                                           ('ASO_TAX_LINES_SUMMARY_V_A',P_QTE_HEADER_ID,
									L_SHIPMENT_REC.SHIPMENT_ID, l_ship_from_org_id);

                L_SHIP_TO_ADDRESS_CODE := ARP_TAX_VIEW_TAXWARE.SHIP_TO_ADDRESS_CODE
                                         ('ASO_TAX_LINES_SUMMARY_V_A',P_QTE_HEADER_ID,
                                           L_SHIPMENT_REC.SHIPMENT_ID,
                                           nvl(L_SHIP_TO_ADDRESS_ID, L_BILL_TO_ADDRESS_ID),
                                           nvl(L_SHIP_TO_LOCATION_CCID, L_BILL_TO_LOCATION_CCID),
                                           sysdate,nvl(L_SHIP_TO_STATE, L_BILL_TO_STATE),
                                           nvl(L_SHIP_TO_postal_code, L_BILL_TO_postal_code));

                L_PART_NUMBER := ARP_TAX_VIEW_TAXWARE.PRODUCT_CODE('ASO_TAX_LINES_SUMMARY_V_A',
								 P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID,
                                         l_qte_line_tbl(i).INVENTORY_ITEM_ID,null);

                L_VENDOR_CONTROL_EXEMPTIONS := ARP_TAX_VIEW_TAXWARE.VENDOR_CONTROL_EXEMPTIONS('ASO_TAX_LINES_SUMMARY_V_A', P_QTE_HEADER_ID,L_SHIPMENT_REC.SHIPMENT_ID, L_TRX_TYPE_ID);

                L_ATTRIBUTE1 := ARP_TAX_VIEW_TAXWARE.Calculation_Flag('ASO_TAX_LINES_SUMMARY_V_A',
						                      P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID);

                L_ATTRIBUTE2 := ARP_TAX_VIEW_TAXWARE.USE_NEXPRO('ASO_TAX_LINES_SUMMARY_V_A',
										  P_QTE_HEADER_ID, L_SHIPMENT_REC.SHIPMENT_ID);

                l_numeric_attribute1 := arp_tax_view_taxware.use_secondary('ASO_TAX_LINES_SUMMARY_V_A',
										  p_qte_header_id ,l_shipment_rec.shipment_id);

                l_numeric_attribute2 := arp_tax_view_taxware.tax_sel_parm('ASO_TAX_LINES_SUMMARY_V_A',
										  p_qte_header_id, l_shipment_rec.shipment_id);

                l_numeric_attribute3 := arp_tax_view_taxware.tax_type('ASO_TAX_LINES_SUMMARY_V_A',
										  p_qte_header_id, l_shipment_rec.shipment_id);

                l_numeric_attribute4 := arp_tax_view_taxware.service_indicator('ASO_TAX_LINES_SUMMARY_V_A'                                                    , p_qte_header_id, l_shipment_rec.shipment_id);

                l_division_code      := arp_tax_view_taxware.division_code('ASO_TAX_LINES_SUMMARY_V_A',
                                                   p_qte_header_id, l_shipment_rec.shipment_id);

                l_company_code       := arp_tax_view_taxware.company_code('ASO_TAX_LINES_SUMMARY_V_A',
                                                   p_qte_header_id, l_shipment_rec.shipment_id);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN

                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_POO_ADDRESS_CODE'||L_POO_ADDRESS_CODE, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_POA_ADDRESS_CODE'||L_POA_ADDRESS_CODE, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_SHIP_FROM_ADDRESS_CODE'||L_SHIP_FROM_ADDRESS_CODE, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_SHIP_TO_ADDRESS_CODE'||L_SHIP_TO_ADDRESS_CODE, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_PART_NUMBER'||L_PART_NUMBER, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_VENDOR_CONTROL_EXEMPTIONS'||L_VENDOR_CONTROL_EXEMPTIONS, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_ATTRIBUTE1'||L_ATTRIBUTE1, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_ATTRIBUTE2'||L_ATTRIBUTE2, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_NUMERIC_ATTRIBUTE1'||L_NUMERIC_ATTRIBUTE1, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_NUMERIC_ATTRIBUTE2'||L_NUMERIC_ATTRIBUTE2, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_NUMERIC_ATTRIBUTE3'||L_NUMERIC_ATTRIBUTE3, 1, 'Y');
                    aso_debug_pub.add('ASO_TAX_LINE: Inside TAXWARE: L_NUMERIC_ATTRIBUTE4'||L_NUMERIC_ATTRIBUTE4, 1, 'Y');

                END IF;

              End; -- TAXWARE

            END IF; -- TAXWARE


                arp_tax.tax_info_rec.ship_to_cust_id                := l_ship_to_customer_id;
                arp_tax.tax_info_rec.bill_to_cust_id                := l_bill_to_customer_id;
                arp_tax.tax_info_rec.customer_trx_charge_line_id    := null;
                arp_tax.tax_info_rec.customer_trx_line_id           := l_qte_line_tbl(i).quote_line_id;
                arp_tax.tax_info_rec.customer_trx_id                := p_qte_header_id;
                arp_tax.tax_info_rec.link_to_cust_trx_line_id       := null;
                arp_tax.tax_info_rec.trx_date                       := l_hdr_tax_date;
                arp_tax.tax_info_rec.gl_date                        := null;
                arp_tax.tax_info_rec.tax_code                       := null;
                arp_tax.tax_info_rec.tax_rate                       := null;
                arp_tax.tax_info_rec.tax_amount                     := null;

                if l_ship_to_site_use_id is null and l_bill_to_site_use_id is null then
                   arp_tax.tax_info_rec.ship_to_site_use_id         := l_party_site_id_ship;
                   arp_tax.tax_info_rec.bill_to_site_use_id         := l_party_site_id_bill;
                else
                   arp_tax.tax_info_rec.ship_to_site_use_id         := l_ship_to_site_use_id;
                   arp_tax.tax_info_rec.bill_to_site_use_id         := l_bill_to_site_use_id;
                end if;

                arp_tax.tax_info_rec.ship_to_postal_code            := l_ship_to_postal_code;
                arp_tax.tax_info_rec.bill_to_postal_code            := l_bill_to_postal_code;
                arp_tax.tax_info_rec.inventory_item_id              := l_qte_line_tbl(i).inventory_item_id;
                arp_tax.tax_info_rec.memo_line_id                   := null;
                arp_tax.tax_info_rec.tax_control                    := l_hdr_tax_exempt_flag;
                arp_tax.tax_info_rec.xmpt_cert_no                   := l_hdr_tax_exempt_number;
                arp_tax.tax_info_rec.xmpt_reason                    := l_hdr_tax_exempt_reason_code;
                arp_tax.tax_info_rec.ship_to_location_id            := l_ship_to_location_ccid;
                arp_tax.tax_info_rec.bill_to_location_id            := l_bill_to_location_ccid;
                arp_tax.tax_info_rec.invoicing_rule_id              := l_qte_line_tbl(i).invoicing_rule_id;
                arp_tax.tax_info_rec.extended_amount                := nvl(l_qte_line_tbl(i).line_quote_price,
													          0) * nvl(l_qte_line_tbl(i).quantity,0);
                arp_tax.tax_info_rec.trx_exchange_rate              := l_qte_header_rec.exchange_rate;
                arp_tax.tax_info_rec.trx_currency_code              := l_currency_code;
                arp_tax.tax_info_rec.minimum_accountable_unit       := l_minimum_accountable_unit;
                arp_tax.tax_info_rec.precision                      := l_precision;
                arp_tax.tax_info_rec.default_ussgl_transaction_code := null;
                arp_tax.tax_info_rec.default_ussgl_trx_code_context := null;
                arp_tax.tax_info_rec.poo_code                       := l_poo_address_code;
                arp_tax.tax_info_rec.poa_code                       := l_poa_address_code;
                arp_tax.tax_info_rec.ship_from_code                 := l_ship_from_address_code;
                arp_tax.tax_info_rec.ship_to_code                   := l_ship_to_address_code;
                arp_tax.tax_info_rec.fob_point                      := l_shipment_rec.fob_code;
                arp_tax.tax_info_rec.taxed_quantity                 := l_qte_line_tbl(i).quantity;
                arp_tax.tax_info_rec.part_no                        := l_part_number;
                arp_tax.tax_info_rec.tax_line_number                := to_number(null);
                arp_tax.tax_info_rec.qualifier                      := 'ALL';
                arp_tax.tax_info_rec.calculate_tax                  := 'Y';
                arp_tax.tax_info_rec.tax_precedence                 := null;
                arp_tax.tax_info_rec.tax_exemption_id               := to_number(null);
                arp_tax.tax_info_rec.item_exception_rate_id         := to_number(null);
                arp_tax.tax_info_rec.vdrctrl_exempt                 := l_vendor_control_exemptions;
                arp_tax.tax_info_rec.userf1                         := l_attribute1;
                arp_tax.tax_info_rec.userf2                         := l_attribute2;
                arp_tax.tax_info_rec.userf3                         := null;
                arp_tax.tax_info_rec.userf4                         := null;
                arp_tax.tax_info_rec.userf5                         := null;
                arp_tax.tax_info_rec.usern1                         := l_numeric_attribute1;
                arp_tax.tax_info_rec.usern2                         := l_numeric_attribute2;
                arp_tax.tax_info_rec.usern3                         := l_numeric_attribute3;
                arp_tax.tax_info_rec.usern4                         := l_numeric_attribute4;
                arp_tax.tax_info_rec.usern5                         := to_number(null);
                arp_tax.tax_info_rec.trx_number                     := null;
                arp_tax.tax_info_rec.ship_to_customer_number        := l_ship_to_customer_number;
                arp_tax.tax_info_rec.ship_to_customer_name          := l_ship_to_customer_name;
                arp_tax.tax_info_rec.bill_to_customer_number        := l_bill_to_customer_number;
                arp_tax.tax_info_rec.bill_to_customer_name          := l_bill_to_customer_name;
                arp_tax.tax_info_rec.previous_customer_trx_line_id  := null;
                arp_tax.tax_info_rec.previous_customer_trx_id       := null;
                arp_tax.tax_info_rec.previous_trx_number            := null;
                arp_tax.tax_info_rec.audit_flag                     := 'N';
                arp_tax.tax_info_rec.trx_line_type                  := null;
                arp_tax.tax_info_rec.division_code                  := l_division_code;
                arp_tax.tax_info_rec.company_code                   := l_company_code;
                arp_tax.tax_info_rec.tax_header_level_flag          := l_tax_header_level_flag;
                arp_tax.tax_info_rec.tax_rounding_rule              := l_tax_rounding_rule;
                arp_tax.tax_info_rec.vat_tax_id                     := to_number(null);
                arp_tax.tax_info_rec.trx_type_id                    := l_ra_cust_trx_type_id;
                arp_tax.tax_info_rec.amount_includes_tax_flag       := null;
                arp_tax.tax_info_rec.ship_from_warehouse_id         := l_ship_from_org_id;
                arp_tax.tax_info_rec.poo_id                         := l_poo_id;
                arp_tax.tax_info_rec.poa_id                         := l_qte_header_rec.org_id;
                arp_tax.tax_info_rec.payment_term_id                := l_payment_term_id;

			 if l_ship_to_customer_id is null and l_bill_to_customer_id is null then
                     arp_tax.tax_info_rec.party_flag                := 'Y';
                end if;

                arp_tax.tax_info_rec.payment_terms_discount_percent := null;
                arp_tax.tax_info_rec.taxable_basis                  := null;
                arp_tax.tax_info_rec.tax_calculation_plsql_block    := null;
                arp_tax.tax_info_rec.userf6                         := null;
                arp_tax.tax_info_rec.userf7                         := null;
                arp_tax.tax_info_rec.userf8                         := null;
                arp_tax.tax_info_rec.userf9                         := null;
                arp_tax.tax_info_rec.userf10                        := null;
                arp_tax.tax_info_rec.usern6                         := to_number(null);
                arp_tax.tax_info_rec.usern7                         := to_number(null);
                arp_tax.tax_info_rec.usern8                         := to_number(null);
                arp_tax.tax_info_rec.usern9                         := to_number(null);
                arp_tax.tax_info_rec.usern10                        := to_number(null);


            ELSE -- LATIN

                Begin

			      if aso_debug_pub.g_debug_flag = 'Y' then
                         aso_debug_pub.add('ASO_TAX_LINE: l_trx_type_id:  '|| l_trx_type_id, 1, 'Y');
                     end if;

                     select oe.transaction_type_id
                     into l_om_trx_type_id
                     --from ra_cust_trx_types_all ra Commented Code Yogeshwar (MOAC)
		     from ra_cust_trx_types ra, --New Code Yogeshwar (MOAC)
                          oe_transaction_types_vl oe
                     where ra.cust_trx_type_id = l_trx_type_id
                     and ra.cust_trx_type_id = oe.cust_trx_type_id
		     and oe.transaction_type_id = nvl(l_qte_line_tbl(i).order_line_type_id, l_qte_header_rec.order_type_id)
                     --Commented code start Yogeshwar(MOAC)
--		        and nvl(ra.org_id,
--                         nvl(to_number(decode(substrb(userenv('CLIENT_INFO'),1 ,1), ' ',null,
--                         substrb(userenv('CLIENT_INFO'), 1,10))),-99)) =
--                         nvl(l_qte_header_rec.org_id,
--                         nvl(to_number(decode( substrb(userenv('CLIENT_INFO'),1,1), ' ',null,
--                         substrb(userenv('CLIENT_INFO'),1,10))), -99))
                     --End of commented code  Yogeshwar (MOAC)

                     and (( tax_calculation_flag = 'Y' ) or ( l_hdr_tax_exempt_flag='R' ))
		     and ra.org_id = l_qte_header_rec.org_id ; --New Code Yogeshwar (MOAC)

		     --Need to find org striped synonym for OE_TRANSACTION_TYPES_ALL  Yogeshwar

                     EXCEPTION

                         WHEN NO_DATA_FOUND THEN

                              IF aso_debug_pub.g_debug_flag = 'Y' THEN
    			                  aso_debug_pub.add('ASO_TAX_LINE: NO_DATA_FOUND when selecting transaction_type_id', 1, 'Y');
                              END IF;

			               l_reason := 'No Data Found Exception when selecting transaction_type_id from ';
			               l_reason := l_reason || 'ra_cust_trx_types_all and oe_transaction_types_vl';
			               l_reason := l_reason || fnd_global.newline();
			               l_reason := l_reason || 'Please check Default order type id profile is ';
			               l_reason := l_reason || 'correctly set. Also pl verify the';
			               l_reason := l_reason || fnd_global.newline();
			               l_reason := l_reason || 'the value the profile is returning. No tax call ';
			               l_reason := l_reason || 'being made to tax engine.';

			               aso_quote_misc_pvt.debug_tax_info_notification(l_qte_header_rec,
                                                                             l_shipment_rec, l_reason);

                              if aso_debug_pub.g_debug_flag = 'Y' then
                                  aso_debug_pub.add('ASO_TAX_LINE: Before deleting all tax records for the quote line', 1, 'Y');
                              end if;

                              if l_tax_detail_tbl.count > 0 then

                                 delete from aso_tax_details
			                  where quote_header_id  = l_tax_detail_tbl(1).quote_header_id
                                 and quote_line_id = l_tax_detail_tbl(1).quote_line_id ;

                              end if;

                              if aso_debug_pub.g_debug_flag = 'Y' then
                                  aso_debug_pub.add('ASO_TAX_LINE: After deleting all tax records for the quote line', 1, 'Y');
                              end if;

                End;


                Begin

                     open  c_global_attributes( l_qte_line_tbl(i).inventory_item_id,
                                                l_qte_line_tbl(i).organization_id );
                     fetch c_global_attributes into l_fiscal_classification, l_transaction_cond_class;
                     close c_global_attributes;

			      if aso_debug_pub.g_debug_flag = 'Y' then
                         aso_debug_pub.add('l_fiscal_classification:  '|| l_fiscal_classification, 1, 'Y');
                         aso_debug_pub.add('l_transaction_cond_class: '|| l_transaction_cond_class, 1, 'Y');
                         aso_debug_pub.add('l_site_use_id_ship: '|| l_site_use_id_ship, 1, 'Y');
                         aso_debug_pub.add('l_site_use_id_bill: '|| l_site_use_id_bill, 1, 'Y');
                         aso_debug_pub.add('inventory_item_id:  '|| l_qte_line_tbl(i).inventory_item_id, 1, 'Y');
                         aso_debug_pub.add('organization_id:    '|| l_qte_line_tbl(i).organization_id, 1, 'Y');
                         aso_debug_pub.add('l_ship_from_org_id: '|| l_ship_from_org_id, 1, 'Y');
                         aso_debug_pub.add('l_set_of_books_id:  '|| l_set_of_books_id, 1, 'Y');
                         aso_debug_pub.add('l_hdr_tax_date:     '|| l_hdr_tax_date, 1, 'Y');
                         aso_debug_pub.add('l_trx_type_id:      '|| l_trx_type_id, 1, 'Y');
                         aso_debug_pub.add('ASO_TAX_LINE: Before call to get_crm_default_tax_code', 1, 'Y');
                     end if;

			      arp_tax_crm_integration_pkg.get_crm_default_tax_code(
                            p_ship_to_site_use_id    => l_site_use_id_ship,
                            p_bill_to_site_use_id    => l_site_use_id_bill,
                            p_inventory_item_id      => l_qte_line_tbl(i).inventory_item_id,
                            p_organization_id        => l_qte_line_tbl(i).organization_id,
                            p_warehouse_id           => l_ship_from_org_id,
                            p_set_of_books_id        => l_set_of_books_id,
                            p_trx_date               => l_hdr_tax_date,
                            p_trx_type_id            => l_trx_type_id,
                            p_tax_code               => l_tax_code,
                            p_vat_tax_id             => l_vat_tax_id,
                            p_amt_incl_tax_flag      => l_amt_incl_tax_flag,
                            p_amt_incl_tax_override  => l_amt_incl_tax_override );

			      if aso_debug_pub.g_debug_flag = 'Y' then
                         aso_debug_pub.add('ASO_TAX_LINE: After call to get_crm_default_tax_code', 1, 'Y');
                         aso_debug_pub.add('l_tax_code:              '|| l_tax_code, 1, 'Y');
                         aso_debug_pub.add('l_vat_tax_id:            '|| l_vat_tax_id, 1, 'Y');
                         aso_debug_pub.add('l_amt_incl_tax_flag:     '|| l_amt_incl_tax_flag, 1, 'Y');
                         aso_debug_pub.add('l_amt_incl_tax_override: '|| l_amt_incl_tax_override, 1, 'Y');
                     end if;


                     EXCEPTION

                         when others then

                              if aso_debug_pub.g_debug_flag = 'Y' then
                                  aso_debug_pub.add('ASO_TAX_LINE: Exception in call to get_crm_default_tax_code', 1, 'Y');
                              end if;


                End;


                Begin

			      if aso_debug_pub.g_debug_flag = 'Y' then

                         aso_debug_pub.add('ASO_TAX_LINE: Before call to populate_om_ar_tax_struct', 1, 'Y');
                         aso_debug_pub.add('p_qte_header_id:              '|| p_qte_header_id, 1, 'Y');
                         aso_debug_pub.add('l_currency_code:              '|| l_currency_code, 1, 'Y');
                         aso_debug_pub.add('l_shipment_rec.fob_code:      '|| l_shipment_rec.fob_code, 1, 'Y');
                         aso_debug_pub.add('l_fiscal_classification:      '|| l_fiscal_classification, 1, 'Y');
                         aso_debug_pub.add('l_site_use_id_bill:           '|| l_site_use_id_bill, 1, 'Y');
                         aso_debug_pub.add('l_om_trx_type_id:             '|| l_om_trx_type_id, 1, 'Y');
                         aso_debug_pub.add('l_payment_term_id:            '|| l_payment_term_id, 1, 'Y');
                         aso_debug_pub.add('l_transaction_cond_class:     '|| l_transaction_cond_class, 1, 'Y');
                         aso_debug_pub.add('l_ship_from_org_id:           '|| l_ship_from_org_id, 1, 'Y');
                         aso_debug_pub.add('l_site_use_id_ship:           '|| l_site_use_id_ship, 1, 'Y');
                         aso_debug_pub.add('l_tax_code:                   '|| l_tax_code, 1, 'Y');
                         aso_debug_pub.add('l_hdr_tax_date:               '|| l_hdr_tax_date, 1, 'Y');
                         aso_debug_pub.add('l_hdr_tax_exempt_flag:        '|| l_hdr_tax_exempt_flag, 1, 'Y');
                         aso_debug_pub.add('l_hdr_tax_exempt_number:      '|| l_hdr_tax_exempt_number, 1, 'Y');
                         aso_debug_pub.add('l_hdr_tax_exempt_reason_code: '|| l_hdr_tax_exempt_reason_code, 1, 'Y');

                         aso_debug_pub.add('exchange_rate:     '|| l_qte_header_rec.exchange_rate, 1, 'Y');
                         aso_debug_pub.add('quote_line_id:     '|| l_qte_line_tbl(i).quote_line_id, 1, 'Y');
                         aso_debug_pub.add('inventory_item_id: '|| l_qte_line_tbl(i).inventory_item_id, 1, 'Y');
                         aso_debug_pub.add('invoicing_rule_id: '|| l_qte_line_tbl(i).invoicing_rule_id, 1, 'Y');
                         aso_debug_pub.add('quantity:          '|| l_qte_line_tbl(i).quantity, 1, 'Y');
                         aso_debug_pub.add('line_quote_price:  '|| l_qte_line_tbl(i).line_quote_price, 1, 'Y');

                     end if;
--                     JL_ZZ_TAX_INTEGRATION_PKG.populate_om_ar_tax_struct(
--                                       p_conversion_rate     =>  l_qte_header_rec.exchange_rate,
--                                     p_currency_code       =>  l_currency_code,
--                                     p_fob_point_code      =>  l_shipment_rec.fob_code,
--                                     p_global_attribute5   =>  l_fiscal_classification,
--                                     p_line_id             =>  l_qte_line_tbl(i).quote_line_id,
--                                     p_header_id           =>  p_qte_header_id,
--                                     p_inventory_item_id   =>  l_qte_line_tbl(i).inventory_item_id,
--                                     p_invoice_to_org_id   =>  l_site_use_id_bill,
--                                     p_invoicing_rule_id   =>  l_qte_line_tbl(i).invoicing_rule_id,
--                                     p_line_type_id        =>  l_om_trx_type_id,
--                                     p_pricing_quantity    =>  l_qte_line_tbl(i).quantity,
--                                     p_payment_term_id     =>  l_payment_term_id,
--                                     p_global_attribute6   =>  l_transaction_cond_class,
--                                     p_ship_from_org_id    =>  l_ship_from_org_id,
--                                     p_ship_to_org_id      =>  l_site_use_id_ship,
--                                     p_tax_code            =>  l_tax_code,
--                                     p_tax_date            =>  l_hdr_tax_date,
--                                     p_tax_exempt_flag     =>  l_hdr_tax_exempt_flag,
--                                     p_tax_exempt_number   =>  l_hdr_tax_exempt_number,
--                                     p_tax_exempt_reason   =>  l_hdr_tax_exempt_reason_code,
--                                     p_unit_selling_price  =>  l_qte_line_tbl(i).line_quote_price );

			      if aso_debug_pub.g_debug_flag = 'Y' then
                         aso_debug_pub.add('ASO_TAX_LINE: After call to populate_om_ar_tax_struct', 1, 'Y');
                     end if;

                     EXCEPTION

                         when others then

                              if aso_debug_pub.g_debug_flag = 'Y' then
                                 aso_debug_pub.add('ASO_TAX_LINE: Exception in call to populate_om_ar_tax_struct', 1, 'Y');
                              end if;


                End;

            END IF; --tax_method <> 'LATIN'

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('ASO_TAX_LINE: Before call to print_tax_info_rec', 1, 'Y');
            end if;

            print_tax_info_rec(p_debug_level => 5);

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('ASO_TAX_LINE: After call to print_tax_info_rec', 1, 'Y');
            end if;


            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('arp_tax.tax_info_rec.trx_type_id: '|| arp_tax.tax_info_rec.trx_type_id, 1, 'Y');
            END IF;


            IF arp_tax.tax_info_rec.trx_type_id is not null THEN

                Begin

                   l_tax_start_time := dbms_utility.get_time;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('ASO_TAX_LINE: Before call to arp_tax_crm_integration_pkg.summary', 1, 'Y');
                       aso_debug_pub.add('ASO_TAX_LINE: l_tax_start_time: '|| l_tax_start_time, 1, 'Y');
                   END IF;

                   arp_tax_crm_integration_pkg.summary( p_set_of_books_id => l_set_of_books_id,
                                                        x_crm_tax_out_tbl => x_tax_out_tbl,
                                                        p_new_tax_amount  => x_tax_value);

                   l_tax_end_time := dbms_utility.get_time;
                   l_tax_total_time := l_tax_total_time + (l_tax_end_time - l_tax_start_time);

			    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('ASO_TAX_LINE: After call to arp_tax_crm_integration_pkg.summary', 1, 'Y');
                       aso_debug_pub.add('ASO_TAX_LINE: l_tax_end_time:   '|| l_tax_end_time, 1, 'Y');
                       aso_debug_pub.add('ASO_TAX_LINE: l_tax_total_time: '|| l_tax_total_time, 1, 'Y');
                   END IF;


			    EXCEPTION

                        WHEN OTHERS THEN

                           IF aso_debug_pub.g_debug_flag = 'Y' THEN

                               aso_debug_pub.add('ASO_TAX_LINE: Exception raised after call to ARP_TAX_CRM_INTEGRATION_PKG.summary', 1, 'Y');
                               aso_debug_pub.add('After call to ARP_TAX_CRM_INTEGRATION_PKG.summary: x_tax_out_tbl.count: '||x_tax_out_tbl.count, 1, 'Y');

                           END IF;

				       l_reason := 'Exception in call to tax engine arp_tax_crm_integration_pkg.summary';
				       l_reason := l_reason || fnd_global.newline();
				       l_reason := l_reason || 'Table count returned from tax engine x_tax_out_tbl.count :';
				       l_reason := l_reason || fnd_global.newline();
				       l_reason := l_reason || x_tax_out_tbl.count;

				       FOR i IN 1.. x_tax_out_tbl.count LOOP

					       l_reason := l_reason || 'x_tax_out_tbl('||i||').vat_tax_id : ';
					       l_reason := l_reason || x_tax_out_tbl(i).vat_tax_id;
					       l_reason := l_reason || fnd_global.newline();
					       l_reason := l_reason || 'x_tax_out_tbl('||i||').extended_amount: ';
					       l_reason := l_reason || x_tax_out_tbl(i).extended_amount;
					       l_reason := l_reason || fnd_global.newline();
					       l_reason := l_reason || 'x_tax_out_tbl('||i||').tax_rate: ';
					       l_reason := l_reason || x_tax_out_tbl(i).tax_rate;
					       l_reason := l_reason || fnd_global.newline();
					       l_reason := l_reason || 'x_tax_out_tbl('||i||').tax_amount: ';
					       l_reason := l_reason || x_tax_out_tbl(1).tax_amount;
					       l_reason := l_reason || fnd_global.newline();
					       l_reason := l_reason || 'x_tax_out_tbl('||i||').tax_control: ';
					       l_reason := l_reason || x_tax_out_tbl(1).tax_control;

				       End Loop;

			            aso_quote_misc_pvt.debug_tax_info_notification( l_qte_header_rec,
                                                                           l_shipment_rec, l_reason);
                End;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN

                   aso_debug_pub.add('ASO_TAX_LINE: After call to ARP_TAX_CRM_INTEGRATION_PKG.summary', 1, 'Y');
                   aso_debug_pub.add('ASO_TAX_LINE: After call x_tax_out_tbl.count: '|| x_tax_out_tbl.count, 1, 'Y');

                   FOR i IN 1.. x_tax_out_tbl.count LOOP

                       aso_debug_pub.add('******Out put from ARP_TAX_CRM_INTEGRATION_PKG.summary******');
                       aso_debug_pub.add('x_tax_out_tbl('||i||').vat_tax_id :     '|| x_tax_out_tbl(i).vat_tax_id, 1, 'Y');
                       aso_debug_pub.add('x_tax_out_tbl('||i||').extended_amount: '|| x_tax_out_tbl(i).extended_amount, 1, 'Y');
                       aso_debug_pub.add('x_tax_out_tbl('||i||').tax_rate:        '|| x_tax_out_tbl(i).tax_rate, 1, 'Y');
                       aso_debug_pub.add('x_tax_out_tbl('||i||').tax_amount:      '|| x_tax_out_tbl(i).tax_amount, 1, 'Y');
                       aso_debug_pub.add('x_tax_out_tbl('||i||').tax_control:     '|| x_tax_out_tbl(i).tax_control, 1, 'Y');
                       aso_debug_pub.add('x_tax_out_tbl('||i||').amount_includes_tax_flag: '|| x_tax_out_tbl(i).amount_includes_tax_flag, 1, 'Y');

                   End Loop;

                   aso_debug_pub.add('ASO_TAX_LINE: OUTput from ARP_TAX_CRM_INTEGRATION_PKG.summary: x_tax_value: ' || x_tax_value, 1, 'Y');

                END IF;

		      FOR i IN 1.. x_tax_out_tbl.count LOOP

			    open  c_tax_code(x_tax_out_tbl(i).vat_tax_id);
			    fetch c_tax_code into l_tax_detail_tbl(1).tax_code;
			    close c_tax_code;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN

                      aso_debug_pub.add('l_tax_detail_tbl(1).tax_code:  '||l_tax_detail_tbl(1).tax_code, 1, 'Y');
                      aso_debug_pub.add('x_tax_out_tbl.tax_rate:        '||x_tax_out_tbl(i).tax_rate, 1, 'Y');
                      aso_debug_pub.add('x_tax_out_tbl.tax_amount:      '||x_tax_out_tbl(i).tax_amount, 1, 'Y');
                      aso_debug_pub.add('x_tax_out_tbl.extended_amount: '||x_tax_out_tbl(i).extended_amount, 1, 'Y');
                      aso_debug_pub.add('x_tax_out_tbl.vat_tax_id:      '||x_tax_out_tbl(i).vat_tax_id, 1, 'Y');
                      aso_debug_pub.add('x_tax_out_tbl.tax_control:     '||x_tax_out_tbl(i).tax_control, 1, 'Y');
                      aso_debug_pub.add('x_tax_out_tbl.xmpt_cert_no:    '||x_tax_out_tbl(i).xmpt_cert_no, 1, 'Y');
                      aso_debug_pub.add('x_tax_out_tbl.xmpt_reason:     '||x_tax_out_tbl(i).xmpt_reason, 1, 'Y');

                   END IF;

			    l_tax_detail_tbl(1).tax_rate               := x_tax_out_tbl(i).tax_rate;
			    l_tax_detail_tbl(1).tax_date               := l_sys_date;
   			    l_tax_detail_tbl(1).tax_amount             := x_tax_out_tbl(i).tax_amount;
                   l_tax_detail_tbl(1).tax_exempt_flag        := x_tax_out_tbl(i).tax_control;
			    l_tax_detail_tbl(1).tax_exempt_number      := x_tax_out_tbl(i).xmpt_cert_no;
			    l_tax_detail_tbl(1).tax_exempt_reason_code := x_tax_out_tbl(i).xmpt_reason;
			    l_tax_detail_tbl(1).tax_inclusive_flag     := x_tax_out_tbl(i).amount_includes_tax_flag;

                   x_tax_detail_tbl(x_tax_detail_tbl.count+1) := l_tax_detail_tbl(1);

    		    END LOOP;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('After populating: x_tax_detail_tbl.count: '|| x_tax_detail_tbl.count, 1, 'Y');
	               aso_debug_pub.add('ASO_TAX_LINE: Deleting tax records Before First IF', 1, 'Y');
                END IF;

                IF p_tax_control_rec.update_db = 'Y' THEN

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('ASO_TAX_LINE: Deleting tax records inside first IF before 2nd IF', 1, 'Y');
                    END IF;

			     IF  p_tax_control_rec.tax_level = 'SHIPPING' THEN

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('ASO_TAX_LINE: Deleting tax records inside 2nd IF');
                            aso_debug_pub.add('ASO_TAX_LINE: l_tax_detail_tbl(1).quote_shipment_id'||l_tax_detail_tbl(1).quote_shipment_id, 1, 'Y');
                            aso_debug_pub.add('ASO_TAX_LINE: l_tax_detail_tbl(1).quote_line_id'||l_tax_detail_tbl(1).quote_line_id, 1, 'Y');
                            aso_debug_pub.add('ASO_TAX_LINE: l_tax_detail_tbl(1).quote_header_id'||l_tax_detail_tbl(1).quote_header_id, 1, 'Y');
                        END IF;

   				    DELETE FROM aso_tax_details
				    WHERE quote_shipment_id = l_tax_detail_tbl(1).quote_shipment_id
				    and quote_line_id   = l_qte_line_tbl(i).quote_line_id
				    and quote_header_id = l_tax_detail_tbl(1).quote_header_id;

    		          END IF;

			     IF p_tax_control_rec.tax_level = 'HEADER' THEN

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('ASO_TAX_LINE: Deleting HEADER level tax records inside IF', 1, 'Y');
                        END IF;

    				    DELETE FROM aso_tax_details
				    WHERE quote_header_id = l_qte_line_tbl(i).quote_header_id
				    and quote_line_id = l_qte_line_tbl(i).quote_line_id;

    			    END IF;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Before calling aso_tax_details_pkg.insert_row in loop', 1, 'Y');
                       aso_debug_pub.add('x_tax_detail_Tbl.count: ' || x_tax_detail_Tbl.count, 1, 'Y');
                   END IF;

                   FOR i IN 1..x_tax_detail_Tbl.count LOOP

                       x_tax_detail_tbl(i).tax_detail_id := null;

                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('ASO_TAX_LINE: value of loop index i: ' || i, 1, 'Y');
                           aso_debug_pub.add('tax_detail_id: ' || x_tax_detail_tbl(i).tax_detail_id, 1, 'Y');
                           aso_debug_pub.add('tax_code:      ' || x_tax_detail_tbl(i).tax_code, 1, 'Y');
                           aso_debug_pub.add('tax_rate:      ' || x_tax_detail_tbl(i).tax_rate, 1, 'Y');
                           aso_debug_pub.add('tax_amount:    ' || x_tax_detail_tbl(i).tax_amount, 1, 'Y');
                       END IF;

        	    	        ASO_TAX_DETAILS_PKG.Insert_Row(
            		          px_TAX_DETAIL_ID  => x_tax_detail_tbl(i).TAX_DETAIL_ID,
            		          p_CREATION_DATE  => SYSDATE,
            		          p_CREATED_BY  => G_USER_ID,
            		          p_LAST_UPDATE_DATE  => SYSDATE,
            		          p_LAST_UPDATED_BY  => G_USER_ID,
            		          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
            		          p_REQUEST_ID  => x_tax_detail_tbl(i).REQUEST_ID,
            		          p_PROGRAM_APPLICATION_ID  =>  x_tax_detail_tbl(i).PROGRAM_APPLICATION_ID,
            		          p_PROGRAM_ID  =>  x_tax_detail_tbl(i).PROGRAM_ID,
            		          p_PROGRAM_UPDATE_DATE  =>  x_tax_detail_tbl(i).PROGRAM_UPDATE_DATE,
            		          p_QUOTE_HEADER_ID  => x_tax_detail_tbl(i).quote_header_id,
            		          p_QUOTE_LINE_ID  =>  x_tax_detail_tbl(i).QUOTE_LINE_ID,
            		          p_QUOTE_SHIPMENT_ID  =>  x_tax_detail_tbl(i).QUOTE_SHIPMENT_ID,
            		          p_ORIG_TAX_CODE  =>  x_tax_detail_tbl(i).ORIG_TAX_CODE,
            		          p_TAX_CODE  => x_tax_detail_tbl(i).TAX_CODE,
            		          p_TAX_RATE  => x_tax_detail_tbl(i).TAX_RATE,
            		          p_TAX_DATE  => l_sys_date,--x_tax_detail_tbl(i).TAX_DATE,
            		          p_TAX_AMOUNT  => x_tax_detail_tbl(i).TAX_AMOUNT,
            		          p_TAX_EXEMPT_FLAG  => x_tax_detail_tbl(i).TAX_EXEMPT_FLAG,
            		          p_TAX_EXEMPT_NUMBER  => x_tax_detail_tbl(i).TAX_EXEMPT_NUMBER,
            		          p_TAX_EXEMPT_REASON_CODE  => x_tax_detail_tbl(i).TAX_EXEMPT_REASON_CODE,
            		          p_ATTRIBUTE_CATEGORY  => x_tax_detail_tbl(i).ATTRIBUTE_CATEGORY,
            		          p_ATTRIBUTE1  => x_tax_detail_tbl(i).ATTRIBUTE1,
            		          p_ATTRIBUTE2  => x_tax_detail_tbl(i).ATTRIBUTE2,
            		          p_ATTRIBUTE3  => x_tax_detail_tbl(i).ATTRIBUTE3,
            		          p_ATTRIBUTE4  => x_tax_detail_tbl(i).ATTRIBUTE4,
            		          p_ATTRIBUTE5  => x_tax_detail_tbl(i).ATTRIBUTE5,
            		          p_ATTRIBUTE6  => x_tax_detail_tbl(i).ATTRIBUTE6,
            		          p_ATTRIBUTE7  => x_tax_detail_tbl(i).ATTRIBUTE7,
            		          p_ATTRIBUTE8  => x_tax_detail_tbl(i).ATTRIBUTE8,
            		          p_ATTRIBUTE9  => x_tax_detail_tbl(i).ATTRIBUTE9,
            		          p_ATTRIBUTE10  => x_tax_detail_tbl(i).ATTRIBUTE10,
            		          p_ATTRIBUTE11  => x_tax_detail_tbl(i).ATTRIBUTE11,
            		          p_ATTRIBUTE12  => x_tax_detail_tbl(i).ATTRIBUTE12,
            		          p_ATTRIBUTE13  => x_tax_detail_tbl(i).ATTRIBUTE13,
            		          p_ATTRIBUTE14  => x_tax_detail_tbl(i).ATTRIBUTE14,
            		          p_ATTRIBUTE15  => x_tax_detail_tbl(i).ATTRIBUTE15,
            		          p_ATTRIBUTE16  => l_tax_detail_tbl(i).ATTRIBUTE16,
                              p_ATTRIBUTE17  => l_tax_detail_tbl(i).ATTRIBUTE17,
                              p_ATTRIBUTE18  => l_tax_detail_tbl(i).ATTRIBUTE18,
                              p_ATTRIBUTE19  => l_tax_detail_tbl(i).ATTRIBUTE19,
                              p_ATTRIBUTE20  => l_tax_detail_tbl(i).ATTRIBUTE20,
                              p_TAX_INCLUSIVE_FLAG  => x_tax_detail_tbl(i).TAX_INCLUSIVE_FLAG,
						p_OBJECT_VERSION_NUMBER => x_tax_detail_tbl(i).OBJECT_VERSION_NUMBER,
						p_TAX_RATE_ID => l_tax_detail_tbl(i).TAX_RATE_ID
						);
                    END LOOP;--x_tax_detail_tbl(i)

                END IF;-- p_tax_control_rec.update_db

                -- Call to initialize the AR Global Tax info record.

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: Before call to initialize_tax_info_rec.', 1, 'Y');
                END IF;

                initialize_tax_info_rec;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_TAX_LINE: After call to initialize_tax_info_rec.', 1, 'Y');
                END IF;

                x_tax_detail_Tbl     := aso_quote_pub.g_miss_tax_detail_tbl;
                l_tax_detail_tbl     := aso_quote_pub.g_miss_tax_detail_tbl;
                l_hdr_tax_detail_tbl := aso_quote_pub.g_miss_tax_detail_tbl;

            END IF; --arp_tax.tax_info_rec.trx_type_id

        End Loop; --quote line loop

    END IF; --qte_header_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_TAX_LINE: Total time Tax Engine took: l_tax_total_time: '|| l_tax_total_time, 1,'Y');
    END IF;

    l_tax_total_time := l_tax_total_time/100;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_TAX_LINE: Total time Tax Engine took after dividing by 100: l_tax_total_time: '|| l_tax_total_time, 1,'Y');
        aso_debug_pub.add('ASO_TAX_INT: End ASO_TAX_LINE', 1, 'Y');
    END IF;

End aso_tax_line;
*
*
*/

--Calculate Tax with GTT added as a part of etax By Anoop Rajan om 9 August 2005
--Modified on 11 August with NOCOPY Hint added

Procedure CALCULATE_TAX_WITH_GTT
(
	p_API_VERSION_NUMBER IN NUMBER,
	p_qte_header_id IN NUMBER,
	p_qte_line_id IN NUMBER:=NULL,
	x_return_status OUT NOCOPY VARCHAR2,
	X_Msg_Count OUT	NOCOPY NUMBER,
	X_Msg_Data OUT NOCOPY VARCHAR2

)
is
	G_PKG_NAME 				CONSTANT VARCHAR2(30):= 'ASO_TAX_INT';
	L_API_NAME				CONSTANT VARCHAR2(50):='CALCULATE_TAX_WITH_GTT';
	l_qte_header_rec			ASO_QUOTE_PUB.Qte_Header_Rec_Type;
	l_currency_code 			VARCHAR2(15);
	l_minimum_accountable_unit	NUMBER;
	l_precision  				NUMBER;
	l_qte_line_tbl				ASO_QUOTE_PUB.Qte_Line_tbl_Type;
	l_qte_line_rec				ASO_QUOTE_PUB.Qte_Line_rec_Type;
	l_set_of_books_id			NUMBER;
	l_site_use_id_ship_header	NUMBER;
	l_site_use_id_bill_header	NUMBER;
	l_site_use_id_ship_lines		NUMBER;
	l_site_use_id_bill_lines		NUMBER;
	l_site_use_id				NUMBER;
	l_ra_cust_trx_type_id		NUMBER;
	l_trx_type_id	 			NUMBER;
	l_acct_site_id_ship			NUMBER;
	l_acct_site_id_bill			NUMBER;
	l_acct_site_id_bill_lines	NUMBER;
	l_acct_site_id_ship_lines	NUMBER;
	l_ship_cust_account_id_header	NUMBER;
	l_ship_cust_acct_id_lines	NUMBER;
	l_bill_cust_acct_id_lines	NUMBER;
	l_Shipment_tbl				ASO_QUOTE_PUB.Shipment_tbl_Type;
	l_Shipment_header_tbl		ASO_QUOTE_PUB.Shipment_tbl_Type;
	l_Shipment_Rec				ASO_QUOTE_PUB.Shipment_Rec_Type;
	l_Shipment_header_rec		ASO_QUOTE_PUB.Shipment_Rec_Type;
	l_tax_detail_tbl			ASO_QUOTE_PUB.Tax_Detail_tbl_Type;
	l_hdr_tax_detail_tbl		ASO_QUOTE_PUB.Tax_Detail_tbl_Type;
	l_hdr_tax_exempt_flag		VARCHAR2(1);
	l_hdr_tax_exempt_number		VARCHAR2(80);
	l_hdr_tax_exempt_reason_code	VARCHAR2(30);
	l_product_type				VARCHAR2(15);
	l_fiscal_classification		VARCHAR2(150);
	l_transaction_cond_class		VARCHAR2(150);
	l_SHIP_FROM_LOCATION_ID		NUMBER;
	l_ship_to_location			NUMBER;
	l_bill_to_location			NUMBER;
	l_party_site_id			NUMBER;
	G_USER_ID				     NUMBER := FND_GLOBAL.USER_ID;
	G_LOGIN_ID				NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
	x_legal_entity				XLE_BUSINESSINFO_GRP.otoc_le_rec;
	l_batch_source				NUMBER;
	l_init_msg_list			VARCHAR2(1);
	l_commit				     VARCHAR2(1) :=NULL;
	l_validation_level			NUMBER;
	l_int_org_location			NUMBER;
	l_legal_entity_id			NUMBER;
	l_tax_start_time			NUMBER;
	l_tax_end_time				NUMBER;
	l_tax_total_time			NUMBER;
	l_msg_cnt1				NUMBER;
	l_msg_cnt2				NUMBER;
	l_tax_classification_code     varchar2(50);
	Cursor c_currency is
		select minimum_accountable_unit,precision
		from fnd_currencies
		where currency_code = l_currency_code;

	Cursor c_get_acct_site(l_site_use_id NUMBER) is
		select cust_acct_site_id
		from hz_cust_site_uses
		where site_use_id = l_site_use_id;

	cursor c_getlocinfo(l_site_use_id NUMBER) is
		select site_use.cust_acct_site_id,site.CUST_ACCOUNT_ID
		from HZ_cust_site_uses site_use,hz_cust_acct_sites site
		where site.CUST_ACCT_SITE_ID=site_use.CUST_ACCT_SITE_ID
		and site_use.SITE_USE_ID=l_site_use_id;

	Cursor c_ship_to_cust_account_id is
		select ship_to_cust_account_id
		from aso_shipments
		where quote_header_id = l_qte_header_rec.quote_header_id
		and quote_line_id is null;

	-- Cursor c_location_id is   commented as per Bug 16458565
	Cursor c_location_id(p_ship_from_org_id Number) is
		SELECT LOCATION_ID
		from HR_ORGANIZATION_UNITS
		WHERE ORGANIZATION_ID = p_ship_from_org_id;
		-- WHERE ORGANIZATION_ID = l_Shipment_Rec.ship_from_org_id; commented as per Bug 16458565
		-- WHERE ORGANIZATION_ID = l_qte_line_rec.organization_id;  commented as per Bug 12830088

	Cursor c_int_org_location is
		SELECT LOCATION_ID
		FROM HR_ORGANIZATION_UNITS
		WHERE ORGANIZATION_ID=l_qte_header_rec.ORG_ID;

	Cursor c_product_type is
		Select CLASSIFICATION_CODE
		FROM ZX_PRODUCT_TYPES_DEF_V
		WHERE INVENTORY_ITEM_ID = l_qte_line_rec.INVENTORY_ITEM_ID
		AND ORG_ID= l_qte_line_rec.organization_id;

	Cursor c_shiplocation(l_party_site_id NUMBER) is
		select LOCATION_ID
		FROM hz_party_sites
		WHERE party_site_id=l_party_site_id;

	Cursor c_tax is
		select TAX_EXEMPT_FLAG,TAX_EXEMPT_NUMBER,TAX_EXEMPT_REASON_CODE
		from aso_tax_details
		WHERE QUOTE_LINE_ID is null
		AND quote_header_id=p_qte_header_id;

	Cursor c_cust_trx_type_id(l_trx_type_id NUMBER) is
		select cust_trx_type_id
		from ra_cust_trx_types
		where cust_trx_type_id = l_trx_type_id
		and (tax_calculation_flag = 'Y');

	Cursor c_set_of_books_id is
		select set_of_books_id
		from ar_system_parameters;

	Cursor c_INVOICE_SOURCE_ID is
		select INVOICE_SOURCE_ID
		FROM OE_TRANSACTION_TYPES
		WHERE TRANSACTION_TYPE_ID=l_qte_header_rec.ORDER_TYPE_ID;

     -- new cursors added by suyog bug 5061912

     Cursor c_get_resource_id (l_qte_hdr_id NUMBER) is
          SELECT resource_id
          FROM aso_quote_headers_all trx
          WHERE trx.quote_header_id = l_qte_hdr_id;

     Cursor c_get_org_id ( l_source_id NUMBER) is
          SELECT per.organization_id
          FROM jtf_rs_srp_vl sales, per_all_assignments_f per
          WHERE sales.resource_id =  l_source_id
          AND per.person_id = sales.person_id
          AND nvl(per.primary_flag,'Y') = 'Y'
          AND sysdate  BETWEEN nvl(per.effective_start_date,sysdate) AND nvl(per.effective_end_date,sysdate);

     Cursor c_get_location_id ( l_party_id NUMBER) is
          SELECT hr.location_id
          FROM hr_organization_units hr
          WHERE hr.organization_id = l_party_id;


    -- new variables
    l_resource_id           number;
    l_poo_party_id        number;
    l_poo_location_id     number;
    l_bill_from_location_id        NUMBER; /*** Added for Bug 8474803 and 7408162 ***/

    /* Added for Bug 9558210 */

    CURSOR C_SHIP(p_party_site_id NUMBER) IS
    SELECT a.party_id
        from
        HZ_PARTIES a, HZ_PARTY_SITES b
        WHERE a.status = 'A'
        and b.status = 'A'
        and b.party_site_id = p_party_site_id
        and b.party_id = a.party_id;

   Cursor C_ACC(p_quote_header_id Number) Is
   SELECT CUST_PARTY_ID
   FROM ASO_QUOTE_HEADERS_ALL
   WHERE QUOTE_HEADER_ID = p_quote_header_id;

   /* End for Bug 9558210 */

/* Added for ER 12879412 */

l_PROD_FISC_CLASSIFICATION   VARCHAR2(240) :=NULL;
l_TRX_BUSINESS_CATEGORY      VARCHAR2(240) :=NULL;

/* End for ER 12879412 */

-- bug 14162429
l_MDL_PROD_FISC_CLASS   VARCHAR2(240) :=NULL;
l_MDL_TRX_BUSI_CATE      VARCHAR2(240) :=NULL;

-- rassharm GSI
l_tax_class_tbl  Tax_Class_Rec_Tbl_Type:=G_MISS_Tax_Class_TBL;
l_tax_line_ct   number:=0;

-- Start : Code change done for Bug 19812910
CURSOR C_TAX_ERRORS IS
SELECT MESSAGE_TEXT
FROM   ZX_ERRORS_GT
WHERE  APPLICATION_ID = 697
  AND  TRX_ID = p_qte_header_id
  AND  ENTITY_CODE =  'ASO_QUOTE_HEADERS_ALL'
  AND  EVENT_CLASS_CODE = 'SALES_TRANSACTION_TAX_QUOTE';

l_tax_errors VARCHAR2(2000); -- code change done for Bug 20543604

Cursor C_Product_Detail(p_org_id NUMBER, p_inventory_item_id NUMBER) IS
Select concatenated_segments
  FROM MTL_SYSTEM_ITEMS_VL
 Where inventory_item_id = p_inventory_item_id
   And organization_id = p_org_id;

l_item_name varchar2(2000);
-- End : Code change done for Bug 19812910

Begin

	Savepoint CALCULATE_TAX_WITH_GTT;
	aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF aso_debug_pub.g_debug_flag = 'Y'
	THEN
		aso_debug_pub.add('ASO_TAX_INT: Begin CALCULATE_TAX_WITH_GTT', 1, 'Y');
     		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: p_qte_header_id: '|| p_qte_header_id, 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: p_qte_line_id: '|| p_qte_line_id, 1, 'Y');
     	END IF;
	l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_id);
	IF aso_debug_pub.g_debug_flag = 'Y'
	THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to ASO_UTILITY_PVT.Query_Header_Row ', 1, 'Y');
	END IF;

	l_currency_code := l_qte_header_rec.currency_code;
	IF aso_debug_pub.g_debug_flag = 'Y'
	THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_currency_code: '|| l_currency_code, 1, 'Y');
		aso_debug_pub.add('12879412  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:l_qte_header_rec.PRODUCT_FISC_CLASSIFICATION '||l_qte_header_rec.PRODUCT_FISC_CLASSIFICATION, 1, 'Y');
               aso_debug_pub.add('12879412  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:l_qte_header_rec.TRX_BUSINESS_CATEGORY '||l_qte_header_rec.TRX_BUSINESS_CATEGORY, 1, 'Y');


	END IF;

	l_Shipment_header_tbl:=aso_utility_pvt.query_shipment_rows( p_qte_header_id,null);
 	IF aso_debug_pub.g_debug_flag = 'Y'
	THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to ASO_UTILITY_PVT.query_shipment_rows ', 1, 'Y');
	END IF;

	--Condition added on 20/09/05 by anrajan
	IF l_Shipment_header_tbl.count > 0
	THEN
		l_Shipment_header_rec:=l_Shipment_header_tbl(1);
	END IF;

	/*** Start : Code change done for Bug 16458565 ***/
	If l_Shipment_header_rec.ship_from_org_id IS NULL Or l_Shipment_header_rec.ship_from_org_id = FND_API.G_MISS_NUM Then

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.add('ASO_TAX_INT: Profile ASO_SHIP_FROM_ORG_ID value', 1, 'Y');
           End If;

	   l_Shipment_header_rec.ship_from_org_id := fnd_profile.value( 'ASO_SHIP_FROM_ORG_ID' );

        End If;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_TAX_INT: l_Shipment_header_rec.ship_from_org_id: '|| l_Shipment_header_rec.ship_from_org_id, 1, 'Y');
        End If;
	/*** End : Code change done for Bug 16458565 ***/

	OPEN c_currency;
	FETCH c_currency into l_minimum_accountable_unit,l_precision;
	CLOSE c_currency;

	IF aso_debug_pub.g_debug_flag = 'Y'
	THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to c_currency cursor ', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_minimum_accountable_unit: '||l_minimum_accountable_unit, 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_precision: '||l_precision,1,'Y');
	END IF;

	open c_ship_to_cust_account_id;
	fetch c_ship_to_cust_account_id into l_ship_cust_account_id_header;
	close c_ship_to_cust_account_id;

	IF aso_debug_pub.g_debug_flag = 'Y'
     	THEN
        	aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to c_ship_to_cust_account_id ', 1, 'Y');
          	aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_ship_cust_account_id_header: '||l_ship_cust_account_id_header, 1, 'Y');
     	END IF;

	OPEN c_int_org_location;
	Fetch c_int_org_location into l_int_org_location;
	close c_int_org_location;

	IF aso_debug_pub.g_debug_flag = 'Y'
     	THEN
	    	aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to c_int_org_location ', 1, 'Y');
	    	aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_int_org_location : '||l_int_org_location, 1, 'Y');
	END IF;

	IF p_qte_line_id is null or p_qte_line_id = FND_API.G_MISS_NUM
	THEN
		l_qte_line_tbl := ASO_UTILITY_PVT.Query_Qte_Line_Rows(p_qte_header_id);
	 	IF
			aso_debug_pub.g_debug_flag = 'Y'
		THEN
			aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to ASO_UTILITY_PVT.Query_Qte_Line_Rows', 1, 'Y');
		END IF;
	ELSE
		l_qte_line_rec    := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_qte_line_id);
		IF
		     aso_debug_pub.g_debug_flag = 'Y'
		THEN
		     aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to ASO_UTILITY_PVT.Query_Qte_Line_Row', 1, 'Y');
		END IF;
		l_qte_line_tbl(1) := l_qte_line_rec;
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: Quote Line Id : '||p_qte_line_id, 1, 'Y');
	END IF;

	IF l_qte_line_tbl.count>0
	THEN
		l_qte_line_rec:= l_qte_line_tbl(1);
		IF
			aso_debug_pub.g_debug_flag = 'Y'
		THEN
			aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT:l_qte_line_tbl.count>0 ', 1, 'Y');
		END IF;
	ELSE
		IF
			aso_debug_pub.g_debug_flag = 'Y'
		THEN
			aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT:l_qte_line_tbl.count=0 ', 1, 'Y');
		END IF;
	END IF;

      /*** Added this SQL for Bug 8474803 and 7408162  ***/
	begin
		select location_id
		into l_bill_from_location_id
		from HR_ALL_ORGANIZATION_UNITS
		where organization_id = l_qte_header_rec.ORG_ID; -- l_qte_line_tbl(1).organization_id;
	Exception
		when others then
		l_bill_from_location_id := NULL;
	End;

	IF aso_debug_pub.g_debug_flag = 'Y'
	THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: value for l_bill_from_location_id'||l_bill_from_location_id, 1, 'Y');
	END IF;

	Open c_set_of_books_id;
	FETCH c_set_of_books_id into l_set_of_books_id;
	close c_set_of_books_id;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After selecting from AR_SYSTEM_PARAMETERS table', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_set_of_books_id : '||l_set_of_books_id, 1, 'Y');
	END IF;


	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: Before call to aso_shipment_pvt.get_ship_to_site_id', 1, 'Y');
	END IF;
	l_site_use_id_ship_header := aso_shipment_pvt.get_ship_to_site_id
								(l_qte_header_rec.quote_header_id,null,l_Shipment_header_rec.shipment_id); -- bug 8228519 passing shipment id for quote header
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to aso_shipment_pvt.get_ship_to_site_id', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_site_use_id_ship_header : '||l_site_use_id_ship_header, 1,'Y');
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: Before call to aso_shipment_pvt.get_cust_to_party_site_id', 1, 'Y');
	END IF;
	l_site_use_id_bill_header := aso_shipment_pvt.get_cust_to_party_site_id
								(l_qte_header_rec.quote_header_id, null);
	IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: After call to aso_shipment_pvt.get_cust_to_party_site_id', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT: CALCULATE_TAX_WITH_GTT: l_site_use_id_bill_header : '||l_site_use_id_bill_header, 1,'Y');
	END IF;
	IF l_site_use_id_ship_header is not null THEN
		l_site_use_id:=l_site_use_id_ship_header;
		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: BEFORE CALL TO c_get_acct_site ', 1, 'Y');
		END IF;

		Open c_get_acct_site(l_site_use_id);
		Fetch c_get_acct_site into l_acct_site_id_ship;
		Close c_get_acct_site;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER CALL TO c_get_acct_site ', 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: l_acct_site_id_ship : '||l_acct_site_id_ship, 1, 'Y');
		END IF;
	ELSE
		IF aso_debug_pub.g_debug_flag ='Y' THEN
		     	aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: l_site_use_id is null ', 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: So l_acct_site_id_ship is also null ', 1, 'Y');
		END IF;
		l_acct_site_id_ship:=NULL;
	END IF;

	IF l_site_use_id_bill_header is not null THEN
		l_site_use_id:=l_site_use_id_bill_header;
		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: BEFORE CALL TO c_get_acct_site ', 1, 'Y');
		END IF;

		Open c_get_acct_site(l_site_use_id);
		Fetch c_get_acct_site into l_acct_site_id_bill;
		Close c_get_acct_site;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
		     aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER CALL TO c_get_acct_site ', 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: l_acct_site_id_bill : '||l_acct_site_id_bill, 1, 'Y');
		END IF;
	ELSE
		IF aso_debug_pub.g_debug_flag ='Y' THEN
		    	aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: l_site_use_id is null ', 1, 'Y');
		     aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: So l_acct_site_id_ship is also null ', 1, 'Y');
		END IF;
		l_acct_site_id_bill:=NULL;
	END IF;

	OPEN c_invoice_source_id;
	fetch c_invoice_source_id into l_batch_source;
	CLOSE c_invoice_source_id;

	IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: After CALL TO the c_invoice_source_id ', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: After CALL TO the c_invoice_source_id :l_batch_source '||l_batch_source, 1, 'Y');
       		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: BEFORE CALL TO the l_trx_type_id ', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: BEFORE CALL TO the l_trx_type_id : x_return_status : '||x_return_status, 1, 'Y');
	END IF;

	l_trx_type_id := ASO_TAX_INT.get_ra_trx_type_id(l_qte_header_rec.order_type_id,l_qte_line_rec);

	IF aso_debug_pub.g_debug_flag ='Y' THEN
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: AFTER THE CALL TO  ASO_TAX_INT.get_ra_trx_type_id ', 1, 'Y');
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_trx_type_id : '||l_trx_type_id , 1, 'Y');
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: BEFORE CALL TO the Legal Entity API :BEFORE THE CALL TO c_cust_trx_type_id ', 1, 'Y');
      END IF;

	Open c_cust_trx_type_id(l_trx_type_id);
	fetch c_cust_trx_type_id into l_ra_cust_trx_type_id;
	close c_cust_trx_type_id;

	IF aso_debug_pub.g_debug_flag ='Y' THEN
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: AFTER THE CALL TO c_cust_trx_type_id ' , 1, 'Y');
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_ra_cust_trx_type_id : '||l_ra_cust_trx_type_id , 1, 'Y');
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: BEFORE CALL TO the Legal Entity API ', 1, 'Y');
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: BEFORE CALL TO the Legal Entity API : x_return_status : '||x_return_status, 1, 'Y');
	   aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: BEFORE CALL TO the Legal Entity API : x_msg_data : '||x_msg_data, 1, 'Y');
         aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID :'||l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID, 1, 'Y');
         aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID :'||l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID , 1, 'Y');
	END IF;

	/* Added for bug 9558210 */

	If (l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID Is Null OR
	    l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID = FND_API.G_MISS_NUM) THEN

            IF aso_debug_pub.g_debug_flag ='Y' THEN
	         aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID Is Null ', 1, 'Y');
            End if;

            If (l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID Is Null OR
	          l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID = FND_API.G_MISS_NUM) THEN

	          IF aso_debug_pub.g_debug_flag ='Y' THEN
		       aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID Is Null ', 1, 'Y');
                End if;

		    Open C_ACC(p_qte_header_id);
	          Fetch C_ACC Into l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID;
	          Close C_ACC;
            Else
	          IF aso_debug_pub.g_debug_flag ='Y' THEN
	             aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID Is Not Null ', 1, 'Y');
                End if;

	          Open C_SHIP(l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID);
	          Fetch C_SHIP Into l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID;
	          Close C_SHIP;
            End If;

	      IF aso_debug_pub.g_debug_flag ='Y' THEN
	         aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: 3 l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID: '||l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID, 1, 'Y');
            End if;

	End If;

	/* End for bug 9558210 */

	XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info(
			x_return_status=>x_return_status,
			x_msg_data=>X_Msg_Data,
			P_customer_type=>'SOLD_TO',
			P_customer_id =>l_Shipment_header_rec.SHIP_TO_CUST_PARTY_ID,
			P_transaction_type_id =>l_ra_cust_trx_type_id,
			P_batch_source_id => l_batch_source,
			P_operating_unit_id => l_qte_header_rec.ORG_ID,
			x_otoc_Le_info =>x_legal_entity);

	l_legal_entity_id:= x_legal_entity.legal_entity_id;


	IF aso_debug_pub.g_debug_flag ='Y' THEN
        	aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER  CALL TO the Legal Entity API ', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: LEGAL ENTITY : '||l_legal_entity_id, 1, 'Y');
		--Added by anrajan on 05/10/2005
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER LEGAL ENTITY API : RETURN_STATUS  : '||x_return_status , 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER LEGAL ENTITY API : MESSAGE DATA  : '||X_Msg_Data , 1, 'Y');
	END IF;


	/* Added for Bug 9558210*/

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           IF aso_debug_pub.g_debug_flag ='Y' THEN
   	        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: RAISING FND_API.G_EXC_ERROR ', 1, 'Y');
           End if;
           raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF aso_debug_pub.g_debug_flag ='Y' THEN
	        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: RAISING FND_API.G_EXC_UNEXPECTED_ERROR ', 1, 'Y');
           End if;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	If l_legal_entity_id = -1 Then
         IF aso_debug_pub.g_debug_flag ='Y' THEN
  	      aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: RAISING FND_API.G_EXC_ERROR for l_legal_entity_id = -1', 1, 'Y');
         End if;
         raise FND_API.G_EXC_ERROR;
	End If;

	/* End for Bug 9558210*/

	--Insertion into the Header Temporary Table.

 	IF aso_debug_pub.g_debug_flag ='Y' THEN
                aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: BEFORE INSERTION INTO ZX_TRX_HEADERS_GT temporary table  ', 1, 'Y');
        END IF;

	DELETE FROM ZX_TRX_HEADERS_GT where
	APPLICATION_ID=697 and
	ENTITY_CODE= 'ASO_QUOTE_HEADERS_ALL' and
	EVENT_CLASS_CODE= 'SALES_TRANSACTION_TAX_QUOTE' and
	TRX_ID=	p_qte_header_id;

	insert into ZX_TRX_HEADERS_GT
	(
		INTERNAL_ORGANIZATION_ID,
		INTERNAL_ORG_LOCATION_ID,
		APPLICATION_ID,
		ENTITY_CODE,
		EVENT_CLASS_CODE,
		EVENT_TYPE_CODE,
		TRX_ID,
		TRX_DATE,
		LEDGER_ID,
		TRX_CURRENCY_CODE,
		CURRENCY_CONVERSION_DATE,
		CURRENCY_CONVERSION_RATE,
		CURRENCY_CONVERSION_TYPE,
		MINIMUM_ACCOUNTABLE_UNIT,
		PRECISION,
		LEGAL_ENTITY_ID,
		QUOTE_FLAG,
		TRX_NUMBER,
		FIRST_PTY_ORG_ID,
		TAX_EVENT_TYPE_CODE,
		VALIDATION_CHECK_FLAG,
		TAX_REPORTING_FLAG,
		SHIP_TO_CUST_ACCT_SITE_USE_ID,
		BILL_TO_CUST_ACCT_SITE_USE_ID,
		DOC_LEVEL_RECALC_FLAG,
		SHIP_THIRD_PTY_ACCT_SITE_ID,
		BILL_THIRD_PTY_ACCT_SITE_ID,
		SHIP_THIRD_PTY_ACCT_ID,
		BILL_THIRD_PTY_ACCT_ID,
		ROUNDING_BILL_TO_PARTY_ID
	)
	values
	(
		l_qte_header_rec.ORG_ID,
		l_int_org_location,
		697,
		'ASO_QUOTE_HEADERS_ALL',
		'SALES_TRANSACTION_TAX_QUOTE',
		'CREATE',
		p_qte_header_id,
		sysdate,
		l_set_of_books_id,
		l_qte_header_rec.CURRENCY_CODE,
		l_qte_header_rec.EXCHANGE_RATE_DATE,
		l_qte_header_rec.EXCHANGE_RATE,
		l_qte_header_rec.EXCHANGE_TYPE_CODE,
		l_minimum_accountable_unit,
		l_precision,
		l_legal_entity_id,
		'Y',
		l_qte_header_rec.QUOTE_NUMBER,
		null,
		'CREATE',
		null,
		'N',
		l_site_use_id_ship_header,
		l_site_use_id_bill_header,
		'N',
		l_acct_site_id_ship,
		l_acct_site_id_bill,
		l_ship_cust_account_id_header,
		l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID,
		l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID
	);

	print_tax_info(1,p_qte_header_id);
	IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: BEFORE THE QUOTE LINES LOOP ', 1, 'Y');
	END IF;

	DELETE FROM  Zx_transaction_lines_gt
	WHERE  APPLICATION_ID= 697
	AND ENTITY_CODE=  'ASO_QUOTE_HEADERS_ALL'
	AND EVENT_CLASS_CODE = 'SALES_TRANSACTION_TAX_QUOTE'
	AND TRX_ID = p_qte_header_id
	AND TRX_LEVEL_TYPE= 'LINE';

	FOR i in 1..l_qte_line_tbl.count
	LOOP
		l_SHIP_FROM_LOCATION_ID := NULL; -- Code change done for Bug 18541144

		l_qte_line_rec:=l_qte_line_tbl(i);
		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP : QUOTE LINE ID :'||l_qte_line_rec.QUOTE_LINE_ID, 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO aso_utility_pvt.query_shipment_rows', 1, 'Y');
		END IF;
		l_Shipment_tbl:=aso_utility_pvt.query_shipment_rows( p_qte_header_id,l_qte_line_rec.quote_line_id);

		--Condition added by anrajan on 06/10/2005 for Bug Number :4656728
		IF l_Shipment_tbl.count>0
		THEN
			l_Shipment_Rec:=l_shipment_tbl(1);
		END IF;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :AFTER THE CALL TO aso_utility_pvt.query_shipment_rows', 1, 'Y');
                END IF;

		l_site_use_id_bill_lines:=aso_shipment_pvt.get_cust_to_party_site_id
								(p_qte_header_id,
								l_qte_line_rec.quote_line_id);
		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :AFTER THE CALL TO aso_shipment_pvt.get_cust_to_party_site_id', 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_site_use_id_bill_lines : '||l_site_use_id_bill_lines , 1, 'Y');
		END IF;

		l_site_use_id_ship_lines:= aso_shipment_pvt.get_ship_to_site_id
								(p_qte_header_id,
								l_qte_line_rec.quote_line_id,
								l_Shipment_Rec.SHIPMENT_ID);
		IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :AFTER THE CALL TO aso_shipment_pvt.get_ship_to_site_id', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_site_use_id_ship_lines '||l_site_use_id_ship_lines  , 1, 'Y');
                END IF;

		Open c_getlocinfo(l_site_use_id_bill_lines);
		Fetch c_getlocinfo into l_acct_site_id_bill_lines,l_bill_cust_acct_id_lines;
		Close c_getlocinfo;

		Open c_getlocinfo(l_site_use_id_ship_lines);
		Fetch c_getlocinfo into l_acct_site_id_ship_lines,l_ship_cust_acct_id_lines;
		Close c_getlocinfo;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :AFTER THE CALL TO c_getlocinfo', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_acct_site_id_bill_lines '||l_acct_site_id_bill_lines  , 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_bill_cust_acct_id_lines '||l_bill_cust_acct_id_lines  , 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_acct_site_id_ship_lines '||l_acct_site_id_ship_lines  , 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_ship_cust_acct_id_lines '||l_ship_cust_acct_id_lines  , 1, 'Y');
                END IF;

	 	IF aso_debug_pub.g_debug_flag ='Y' THEN
                       aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO c_shiplocation', 1, 'Y');
                END IF;

		IF
			l_Shipment_Rec.ship_to_party_site_id is not null
		THEN
			OPEN c_shiplocation(l_Shipment_Rec.ship_to_party_site_id);
		ELSE
			OPEN c_shiplocation(l_Shipment_header_rec.ship_to_party_site_id);
		END IF;
		FETCH c_shiplocation into l_ship_to_location;
		close c_shiplocation;

	 	IF aso_debug_pub.g_debug_flag ='Y' THEN
                       	aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :AFTER THE CALL TO c_shiplocation', 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_ship_to_location '||l_ship_to_location  , 1, 'Y');
                END IF;

		IF
			l_qte_line_rec.invoice_to_party_site_id is not null
		THEN
			OPEN c_shiplocation(l_qte_line_rec.invoice_to_party_site_id);
		ELSE
			OPEN c_shiplocation(l_qte_header_rec.invoice_to_party_site_id);
		END IF;

		FETCH c_shiplocation into l_bill_to_location;
		close c_shiplocation;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :AFTER THE CALL TO c_shiplocation', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_bill_to_location '||l_bill_to_location  , 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO ASO_TAX_INT.get_ra_trx_type_id  ', 1, 'Y');
                END IF;

		l_trx_type_id := ASO_TAX_INT.get_ra_trx_type_id(l_qte_header_rec.order_type_id,l_qte_line_rec);
		IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :AFTER THE CALL TO  ASO_TAX_INT.get_ra_trx_type_id ', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:  Bug 19331696 WITHIN THE QUOTE_LINES_LOOP :l_trx_type_id '||l_trx_type_id , 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO c_product_type  ', 1, 'Y');
                END IF;

		Open c_product_type;
		Fetch c_product_type into l_product_type;
		close c_product_type;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :AFTER THE CALL TO c_product_type ' , 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_product_type: '||l_product_type, 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO c_tax ', 1, 'Y');
                END IF;


		Open c_tax;
		fetch c_tax into l_hdr_tax_exempt_flag,l_hdr_tax_exempt_number,l_hdr_tax_exempt_reason_code;
		close c_tax;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
            aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :AFTER THE CALL TO c_tax ' , 1, 'Y');
            aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_HDR_TAX_EXEMPT_FLAG: '||l_hdr_tax_exempt_flag , 1, 'Y');
	  	  aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_HDR_TAX_EXEMPT_NUMBER : '||l_hdr_tax_exempt_number , 1, 'Y');
		  aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_HDR_TAX_EXEMPT_REASON_CODE : '||l_hdr_tax_exempt_reason_code  , 1, 'Y');
            aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO c_cust_trx_type_id ', 1, 'Y');
          END IF;


		Open c_cust_trx_type_id(l_trx_type_id);
		fetch c_cust_trx_type_id into l_ra_cust_trx_type_id;
		close c_cust_trx_type_id;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
            aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :AFTER THE CALL TO c_cust_trx_type_id ' , 1, 'Y');
            aso_debug_pub.add('ASO_TAX_INT :  Bug 19331696 CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_ra_cust_trx_type_id : '||l_ra_cust_trx_type_id , 1, 'Y');
            aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_Shipment_Rec.ship_from_org_id : '||l_Shipment_Rec.ship_from_org_id, 1, 'Y');
            -- aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO c_LOCATION_ID ', 1, 'Y');
          END IF;

	 /* If (l_ra_cust_trx_type_id Is Not Null And l_ra_cust_trx_type_id <> FND_API.G_MISS_NUM ) Then   -- Code change done for Bug 14340122
	    commented this if condition as per Bug 16208600 */

	       IF aso_debug_pub.g_debug_flag ='Y' THEN
	          -- aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_ra_cust_trx_type_id Is Not Null ', 1, 'Y');
            aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE THE CALL TO c_LOCATION_ID ', 1, 'Y');
            aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_Shipment_Rec.ship_from_org_id : '||l_Shipment_Rec.ship_from_org_id , 1, 'Y'); -- added for Bug 16458565
          END IF;


		-- OPEN c_LOCATION_ID; commented for Bug 16458565
		OPEN c_LOCATION_ID(NVL(l_Shipment_Rec.ship_from_org_id,l_Shipment_header_rec.ship_from_org_id));
    	 	Fetch c_LOCATION_ID into l_SHIP_FROM_LOCATION_ID;
	     	close c_LOCATION_ID;

		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :AFTER THE CALL TO c_LOCATION_ID ', 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_SHIP_FROM_LOCATION_ID  : '||l_SHIP_FROM_LOCATION_ID , 1, 'Y');
               --aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE INSERTING INTO Zx_transaction_lines_gt ', 1, 'Y');
          END IF;


          -- new code added by suyog bug 5061912

          -- get the resource id and the trxn date
          OPEN c_get_resource_id(p_qte_header_id);
		FETCH c_get_resource_id into l_resource_id;
		CLOSE c_get_resource_id;

          IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :AFTER THE CALL TO c_get_resource_id ', 1, 'Y');
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_resource_id:  '|| l_resource_id , 1, 'Y');
          END IF;

          -- get the org id based upon the resource id and the trxn date
          OPEN c_get_org_id(l_resource_id);
          FETCH c_get_org_id into l_poo_party_id;
          CLOSE c_get_org_id;

          IF aso_debug_pub.g_debug_flag ='Y' THEN
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :AFTER THE CALL TO c_get_org_id ', 1, 'Y');
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_poo_party_id:  '|| l_poo_party_id , 1, 'Y');
          END IF;

          -- get the location based upon the org id
          OPEN c_get_location_id(l_poo_party_id);
          FETCH c_get_location_id into l_poo_location_id;
          CLOSE c_get_location_id;

          IF aso_debug_pub.g_debug_flag ='Y' THEN
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :AFTER THE CALL TO c_get_location_id  ', 1, 'Y');
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :l_poo_location_id:  '|| l_poo_location_id , 1, 'Y');
          END IF;

          -- POA PARTY ID is same as the internal_organization_id
          -- POA LOCATION ID is same as the l_int_org_location

          IF aso_debug_pub.g_debug_flag ='Y' THEN
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :Value for poa_party_id:     '|| l_qte_header_rec.ORG_ID , 1, 'Y');
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE_LINES_LOOP :Value for poa_location_id:  '|| l_int_org_location , 1, 'Y');
               aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :BEFORE INSERTING INTO Zx_transaction_lines_gt ', 1, 'Y');
	       aso_debug_pub.add('8936101  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:l_qte_line_rec.LINE_QUOTE_PRICE  '|| l_qte_line_rec.LINE_QUOTE_PRICE , 1, 'Y');
               aso_debug_pub.add('8936101  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:l_qte_line_rec.QUANTITY '||l_qte_line_rec.QUANTITY, 1, 'Y');
               aso_debug_pub.add('12879412  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION '||l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION, 1, 'Y');
               aso_debug_pub.add('12879412  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:l_qte_line_rec.TRX_BUSINESS_CATEGORY '||l_qte_line_rec.TRX_BUSINESS_CATEGORY, 1, 'Y');
	       aso_debug_pub.add('12879412  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT:l_qte_line_rec.item_type_code '||l_qte_line_rec.item_type_code, 1, 'Y');

          END IF;

          -- end of new code added by suyog

   If (l_ra_cust_trx_type_id Is Not Null And l_ra_cust_trx_type_id <> FND_API.G_MISS_NUM ) Then   -- Code change done for Bug 12587408
   -- Un-commented this if condition as per Bug 16208600

-- Code changes for Default tax  Classification Code Bug 5177854 BEGIN

   ZX_AR_TAX_CLASSIFICATN_DEF_PKG.GET_DEFAULT_TAX_CLASSIFICATION
      (
 	     p_ship_to_site_use_id => l_site_use_id_ship_lines,
	     p_bill_to_site_use_id => l_site_use_id_bill_lines,
	     p_inventory_item_id   => l_qte_line_rec.Inventory_item_id,
	     p_organization_id     => l_qte_line_rec.organization_id,
	     p_set_of_books_id     => l_set_of_books_id,
	     p_trx_date            => sysdate,
             p_trx_type_id         => l_trx_type_id,
             p_tax_classification_code => l_Tax_Classification_Code,
             p_cust_trx_id         => l_ra_cust_trx_type_id,
             p_customer_id         => nvl(l_shipment_rec.ship_to_cust_party_id,l_shipment_header_rec.ship_to_cust_party_id),
             appl_short_name       => 'ASO',
             p_entity_code         => 'ASO_QUOTE_HEADERS_ALL',
             p_event_class_code    => 'SALES_TRANSACTION_TAX_QUOTE',
	     p_application_id      => 697,
             p_internal_organization_id => l_qte_header_rec.org_id
        );

-- Code Changes for Default tax classification code Bug 5177854 END

  IF aso_debug_pub.g_debug_flag ='Y' THEN
        aso_debug_pub.add('  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_Tax_Classification_Code '||l_Tax_Classification_Code, 1, 'Y');
  end if;

   End If;

-- ER 12879412
if l_qte_line_rec.item_type_code='CFG' then
  BEGIN
	select PRODUCT_FISC_CLASSIFICATION,TRX_BUSINESS_CATEGORY
	into l_MDL_PROD_FISC_CLASS, l_MDL_TRX_BUSI_CATE
	from aso_quote_lines_all where quote_line_id =
	(select top_model_line_id from aso_Quote_line_Details where quote_line_id = l_qte_line_rec.quote_line_id);
	IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('12879412  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: Model PRODUCT_FISC_CLASSIFICATION '||l_MDL_PROD_FISC_CLASS, 1, 'Y');
		aso_debug_pub.add('12879412  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: Model TRX_BUSINESS_CATEGORY '||l_MDL_TRX_BUSI_CATE, 1, 'Y');
	end if;
    EXCEPTION
       WHEN no_data_found then
            null;
        when others then
	   null;
     END;
end if;

if (l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION is not null) and (l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION <> FND_API.G_MISS_CHAR) then
    l_PROD_FISC_CLASSIFICATION := l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION;
else
    if   (l_qte_line_rec.item_type_code='CFG') and (l_MDL_PROD_FISC_CLASS is not null ) then   -- bug 14162429
       l_PROD_FISC_CLASSIFICATION:=l_MDL_PROD_FISC_CLASS;
    else
           if (l_qte_header_rec.PRODUCT_FISC_CLASSIFICATION is not null) and (l_qte_header_rec.PRODUCT_FISC_CLASSIFICATION <> FND_API.G_MISS_CHAR) then
                 l_PROD_FISC_CLASSIFICATION := l_qte_header_rec.PRODUCT_FISC_CLASSIFICATION;
           else
	      -- Picking from inventory bug 22887835
	     Begin
	      SELECT global_attribute1
	      INTO l_PROD_FISC_CLASSIFICATION
	      FROM mtl_system_items
              WHERE inventory_item_id = l_qte_line_rec.inventory_item_id
              AND organization_id     = l_qte_line_rec.organization_id;
             exception
	      when no_data_found then
	       IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: NO DATA FOUND in Inventory for product fiscal classification', 1, 'Y');
	       end if;
               l_PROD_FISC_CLASSIFICATION:=null;
              when others then
	        IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: OTHERS exception in Inventory for product fiscal classification', 1, 'Y');
	       end if;
	       l_PROD_FISC_CLASSIFICATION:=null;
             end;
           end if;
     end if;
end if;

if (l_qte_line_rec.TRX_BUSINESS_CATEGORY is not null) and (l_qte_line_rec.TRX_BUSINESS_CATEGORY <> FND_API.G_MISS_CHAR) then
    l_TRX_BUSINESS_CATEGORY := l_qte_line_rec.TRX_BUSINESS_CATEGORY;
else
    if  (l_qte_line_rec.item_type_code='CFG') and (l_MDL_TRX_BUSI_CATE is not null) then -- bug 14162429
       l_TRX_BUSINESS_CATEGORY:=l_MDL_TRX_BUSI_CATE;
    else
	if (l_qte_header_rec.TRX_BUSINESS_CATEGORY is not null) and (l_qte_header_rec.TRX_BUSINESS_CATEGORY <> FND_API.G_MISS_CHAR) then
		l_TRX_BUSINESS_CATEGORY := l_qte_header_rec.TRX_BUSINESS_CATEGORY;
	else
	  -- Picking from inventory bug 22887835
          BEGIN
	       SELECT global_attribute2
	       INTO l_TRX_BUSINESS_CATEGORY
               FROM mtl_system_items
               WHERE inventory_item_id = l_qte_line_rec.inventory_item_id
               AND organization_id     = l_qte_line_rec.organization_id;
           EXCEPTION
	      when no_data_found then
	       IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: NO DATA FOUND in Inventory for TRX_BUSINESS_CATEGORY', 1, 'Y');
	       end if;
               l_TRX_BUSINESS_CATEGORY:=null;
              when others then
	        IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('  ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: OTHERS exception in Inventory for TRX_BUSINESS_CATEGORY', 1, 'Y');
	       end if;
	       l_TRX_BUSINESS_CATEGORY:=null;
            END;

	end if;
     end if;
end if;

IF aso_debug_pub.g_debug_flag ='Y' THEN

		aso_debug_pub.add('14162429   ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: quote_line_id '||l_qte_line_rec.quote_line_id, 1, 'Y');
		aso_debug_pub.add('14162429   ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: L_PRODUCT_FISC_CLASSIFICATION '||l_PROD_FISC_CLASSIFICATION, 1, 'Y');
		aso_debug_pub.add('14162429   ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_TRX_BUSINESS_CATEGORY '||l_TRX_BUSINESS_CATEGORY, 1, 'Y');
		aso_debug_pub.add('Bug 19331696 : ASO_TAX_INT :l_trx_type_id : '||l_trx_type_id, 1, 'Y');

end if;


-- End ER 12879412

		--Insertion into the Lines Temporary Table
		insert into Zx_transaction_lines_gt
		(
			APPLICATION_ID,
			ENTITY_CODE,
			EVENT_CLASS_CODE,
			TRX_ID,
			TRX_LEVEL_TYPE,
			TRX_LINE_ID,
			LINE_LEVEL_ACTION,
			LINE_CLASS,
			TRX_SHIPPING_DATE,
			TRX_LINE_TYPE,
			TRX_LINE_DATE,
			TRX_BUSINESS_CATEGORY,
			LINE_AMT,
			TRX_LINE_QUANTITY,
			EXEMPT_CERTIFICATE_NUMBER,
			EXEMPT_REASON_CODE,
			PRODUCT_ID,
			PRODUCT_ORG_ID,
			UOM_CODE,
			--PRODUCT_TYPE,
			FOB_POINT,
			SHIP_TO_PARTY_ID,
			SHIP_FROM_PARTY_ID,
			BILL_TO_PARTY_ID,
			SHIP_TO_PARTY_SITE_ID,
			BILL_TO_PARTY_SITE_ID,
			SHIP_TO_LOCATION_ID,
			BILL_TO_LOCATION_ID,
			SHIP_FROM_LOCATION_ID,
			HISTORICAL_FLAG,
			LINE_AMT_INCLUDES_TAX_FLAG,
			EXEMPTION_CONTROL_FLAG,UNIT_PRICE,
			TRX_LINE_GL_DATE,
			RECEIVABLES_TRX_TYPE_ID,
			BILL_TO_CUST_ACCT_SITE_USE_ID,
			SHIP_TO_CUST_ACCT_SITE_USE_ID,
			SHIP_THIRD_PTY_ACCT_SITE_ID,
			BILL_THIRD_PTY_ACCT_SITE_ID,
			SHIP_THIRD_PTY_ACCT_ID,
			BILL_THIRD_PTY_ACCT_ID,
			CTRL_HDR_TX_APPL_FLAG,
			TRX_LINE_NUMBER,
			POO_LOCATION_ID,
			POO_PARTY_ID,
			POA_PARTY_ID,
			POA_LOCATION_ID,
			OUTPUT_TAX_CLASSIFICATION_CODE,
			 BILL_FROM_LOCATION_ID, /*** Added for Bug 8474803 and 7408162 ***/
			 PRODUCT_FISC_CLASSIFICATION -- Added for ER 12879412
		)
		values
		(
			697,
			'ASO_QUOTE_HEADERS_ALL',
			'SALES_TRANSACTION_TAX_QUOTE',
			p_qte_header_id,
			'LINE',
			l_qte_line_rec.QUOTE_LINE_ID,
			'CREATE',
			'INVOICE',
			nvl(l_Shipment_Rec.REQUEST_DATE,l_Shipment_header_rec.request_date),
			'ITEM',
			SYSDATE,
			l_TRX_BUSINESS_CATEGORY,--null, -- Added for ER 12879412
			nvl(l_qte_line_rec.LINE_QUOTE_PRICE,0)*l_qte_line_rec.QUANTITY,   -- bug 8936101
			l_qte_line_rec.QUANTITY,
			l_HDR_TAX_EXEMPT_NUMBER,
			l_HDR_TAX_EXEMPT_REASON_CODE,
			l_qte_line_rec.INVENTORY_ITEM_ID,
			-- l_qte_line_rec.organization_id,
			NVL(l_Shipment_Rec.ship_from_org_id,l_qte_line_rec.organization_id), -- Code change done for Bug 18411837
			l_qte_line_rec.UOM_CODE,
		--	l_product_type,
			nvl(l_Shipment_Rec.fob_code,l_Shipment_header_rec.fob_code),
			nvl(l_Shipment_Rec.ship_to_cust_party_id,l_Shipment_header_rec.ship_to_cust_party_id),
			nvl(l_Shipment_Rec.ship_from_org_id,l_Shipment_header_rec.ship_from_org_id),
			nvl(l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID,l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID),
			nvl(l_Shipment_Rec.SHIP_TO_PARTY_SITE_ID,l_Shipment_header_rec.SHIP_TO_PARTY_SITE_ID),
			nvl(l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID,l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID),
			l_ship_to_location,
			l_bill_to_location,
			l_SHIP_FROM_LOCATION_ID,
			'N',
			'S',
			nvl(l_HDR_TAX_EXEMPT_FLAG,'S'),
			nvl(l_qte_line_rec.LINE_QUOTE_PRICE,0),  -- bug 8936101
			sysdate,
			--l_ra_cust_trx_type_id,  -- Commented for bug 19331696
			l_trx_type_id,            -- Bug 19331696
			l_site_use_id_bill_lines,
			l_site_use_id_ship_lines,
			l_acct_site_id_ship_lines,
			l_acct_site_id_bill_lines,
			l_ship_cust_acct_id_lines,
			l_bill_cust_acct_id_lines,
			'N',
			l_qte_line_rec.LINE_NUMBER,
               l_poo_location_id,
               l_poo_party_id,
               l_qte_header_rec.ORG_ID,
               l_int_org_location,
			l_Tax_Classification_Code,
			l_bill_from_location_id, /*** Added for Bug 8474803 and 7408162 ***/
			l_PROD_FISC_CLASSIFICATION -- Added for ER 12879412
		);

	-- rassharm gsi
       l_tax_class_tbl(i).quote_line_id:= l_qte_line_rec.QUOTE_LINE_ID;
       l_tax_class_tbl(i).tax_classification_code:=l_Tax_Classification_Code;
       IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT:  l_tax_class_tbl('||i||').quote_line_id '||l_tax_class_tbl(i).quote_line_id, 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT:  l_tax_class_tbl('||i||').tax_classification_code  '|| l_tax_class_tbl(i).tax_classification_code, 1, 'Y');
        end if;

        /* Else
             If aso_debug_pub.g_debug_flag ='Y' Then
	        aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: WITHIN THE QUOTE LINES LOOP :l_ra_cust_trx_type_id Is Null ', 1, 'Y');
             End If;
	End If;  -- code change done for Bug 14340122
	commented as per Bug 16208600 */

	END LOOP;
	print_tax_info(2,p_qte_header_id);
	IF aso_debug_pub.g_debug_flag ='Y' THEN
                        aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE QUOTE LINES LOOP ', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: BEFORE CALL TO TAX ENGINE  ', 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: p_api_version_number : '||p_api_version_number , 1, 'Y');
                        aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: l_init_msg_list : '||l_init_msg_list , 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: l_commit : '||l_commit , 1, 'Y');
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: l_validation_level  : '||l_validation_level  , 1, 'Y');
			l_tax_start_time := dbms_utility.get_time;
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: CALLED TAX ENGINE AT : '|| l_tax_start_time, 1, 'Y');
        END IF;

	--Changes done by anrajan on 20/09/05
	l_msg_cnt1:= FND_MSG_PUB.Count_Msg;
	IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: Message Count Before Tax call : '|| l_msg_cnt1, 1, 'Y');
	END IF;

	ZX_API_PUB.calculate_tax(p_api_version => p_api_version_number,
				p_init_msg_list => l_init_msg_list,
				p_commit        => l_commit,
				P_VALIDATION_LEVEL =>l_validation_level,
				X_RETURN_STATUS =>x_return_status,
				X_MSG_COUNT	=>X_Msg_Count,
				X_MSG_DATA	=>X_Msg_Data);

	--Changes done by anrajan on 20/09/05
	l_msg_cnt2:=FND_MSG_PUB.Count_Msg;
	IF aso_debug_pub.g_debug_flag ='Y' THEN
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: Message Count After Tax call : '|| l_msg_cnt2, 1, 'Y');
	END IF;

	IF aso_debug_pub.g_debug_flag ='Y' THEN
		l_tax_end_time := dbms_utility.get_time;
                aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER  CALL TO TAX ENGINE  ', 1, 'Y');
		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER CALL TO TAX ENGINE : X_RETURN_STATUS  : '||x_return_status , 1, 'Y');
		l_tax_total_time := (l_tax_end_time - l_tax_start_time)/100;
  		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: TAX CALL ENDED AT : '|| l_tax_end_time, 1, 'Y');
                aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: TIME TAKEN BY TAX ENGINE IN SECONDS: '|| l_tax_total_time, 1, 'Y');
        END IF;

	print_tax_info(3,p_qte_header_id);

	IF x_return_status='S' THEN

		if p_qte_line_id is not null THEN
			IF aso_debug_pub.g_debug_flag ='Y' THEN
		      		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :RETURN SUCCESSFUL ', 1, 'Y');
				aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :DELETING FROM ASO_TAX_DETAILS :QUOTE HEADER_ID : '||p_qte_header_id||'; QUOTE LINE ID : '||p_qte_line_id , 1, 'Y');
			END IF;
			Delete from
				ASO_TAX_DETAILS
			where
				QUOTE_HEADER_ID=p_qte_header_id
			and
				QUOTE_LINE_ID=p_qte_line_id;
		ELSE
		 	IF aso_debug_pub.g_debug_flag ='Y' THEN
		      		aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :RETURN SUCCESSFUL ', 1, 'Y');
				aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :DELETING FROM ASO_TAX_DETAILS :QUOTE HEADER_ID : '||p_qte_header_id,1, 'Y');
			END IF;
			Delete from ASO_TAX_DETAILS
          	where QUOTE_HEADER_ID=p_qte_header_id
			and   QUOTE_LINE_ID is not null;
		END IF;


		--Inserting the values from output temporary table into the ASO_TAX_DETAILS table.


		insert into Aso_tax_details
		(
			TAX_DETAIL_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,PROGRAM_APPLICATION_ID,PROGRAM_UPDATE_DATE,
			QUOTE_HEADER_ID,QUOTE_LINE_ID,QUOTE_SHIPMENT_ID,TAX_CODE,TAX_RATE,
			TAX_DATE,TAX_AMOUNT,TAX_EXEMPT_NUMBER,TAX_EXEMPT_REASON_CODE,
			TAX_INCLUSIVE_FLAG,OBJECT_VERSION_NUMBER,TAX_RATE_ID,
			TAX_EXEMPT_FLAG	--Added by anrajan on 05/10/2005
		)
		select
			ASO_TAX_DETAILS_S.nextval,SYSDATE,G_USER_ID,SYSDATE,G_USER_ID,
			G_LOGIN_ID,APPLICATION_ID,sysdate,
			a.TRX_ID,a.TRX_LINE_ID,b.SHIPMENT_ID,a.TAX_RATE_CODE,a.TAX_RATE,
			a.TAX_DETERMINE_DATE,a.TAX_AMT,a.EXEMPT_CERTIFICATE_NUMBER,a.EXEMPT_REASON_CODE,
			a.TAX_AMT_INCLUDED_FLAG,a.OBJECT_VERSION_NUMBER,a.TAX_RATE_ID,
			nvl(l_HDR_TAX_EXEMPT_FLAG,'S') --Added by anrajan on 05/10/2005
		FROM
			Zx_detail_tax_lines_gt a,aso_shipments b
		WHERE
			a.TRX_ID=b.QUOTE_HEADER_ID
		AND
			a.APPLICATION_ID=697
		AND
			a.ENTITY_CODE='ASO_QUOTE_HEADERS_ALL'
		AND
			a.EVENT_CLASS_CODE='SALES_TRANSACTION_TAX_QUOTE'
		AND
			a.TRX_ID=p_qte_header_id
		AND
			(
				a.TRX_LINE_ID=b.QUOTE_LINE_ID
				OR
				(a.TRX_LINE_ID is null AND b.QUOTE_LINE_ID is null)
			)

		--AND
			--a.TRX_LEVEL_TYPE='LINE'
		;

		--Changed by Anoop on 14 Sep 2005.
		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :Number of rows inserted : '||sql%rowcount, 1, 'Y');
		END IF;

		-- rassharm gsi
              	IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :updating the inserted records  ', 1, 'Y');
		END IF;

		if sql%rowcount>0 then

		 /*  FORALL i IN l_tax_class_tbl.FIRST..l_tax_class_tbl.LAST

                    UPDATE aso_tax_details
                    SET tax_classification_code = l_tax_class_tbl(i).tax_classification_code
                    WHERE quote_line_id =  l_tax_class_tbl(i).quote_line_id;*/
                    --bug14680025
                     --FOR I IN 1 .. l_tax_class_tbl.COUNT  LOOP

		     -- bug 15995549
                       FOR i IN l_tax_class_tbl.FIRST..l_tax_class_tbl.LAST LOOP
			       UPDATE aso_tax_details
                    SET tax_classification_code = l_tax_class_tbl(i).tax_classification_code
                    WHERE quote_line_id =  l_tax_class_tbl(i).quote_line_id;
                    END LOOP;

                    if aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('No of tax  lines updated is sql%rowcount: '||sql%rowcount);
                    end if;
		end if;
            -- end rassharm gsi


	ELSE
		IF aso_debug_pub.g_debug_flag ='Y' THEN
			aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :RETURN NOT SUCCESSFUL ', 1, 'Y');
		END IF;
		--Changes done by anrajan on 20/09/05
		for i in 1..(l_msg_cnt2-l_msg_cnt1)
		loop
			IF aso_debug_pub.g_debug_flag ='Y' THEN
				FND_MSG_PUB.GET(p_msg_index => l_msg_cnt1+1,
					p_data =>X_Msg_Data,
					p_encoded =>'F',
					p_msg_index_out =>X_Msg_Count);
				aso_debug_pub.add('ASO_TAX_INT : CALCULATE_TAX_WITH_GTT: AFTER THE TAX ENGINE CALL :X_Msg_Data : '||X_Msg_Data, 1, 'Y');
			END IF;
			FND_MSG_PUB.Delete_Msg(l_msg_cnt1+1);
		END LOOP;

		-- Start: Code change done for Bug 19812910
		--x_return_status := FND_API.G_RET_STS_SUCCESS;

		Open C_Product_Detail(l_Shipment_Rec.ship_from_org_id,l_qte_line_rec.inventory_item_id);
                Fetch C_Product_Detail Into l_item_name;
	        Close C_Product_Detail;

		Open C_TAX_ERRORS;
	        Fetch C_TAX_ERRORS Into l_tax_errors;

	        If C_TAX_ERRORS%Found Then
	           IF aso_debug_pub.g_debug_flag ='Y' THEN
		      aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: C_TAX_ERRORS%RowCount = '||C_TAX_ERRORS%RowCount , 1, 'Y');
		      aso_debug_pub.add('ASO_TAX_INT :CALCULATE_TAX_WITH_GTT: l_tax_errors : '||l_tax_errors , 1, 'Y');
		   End If;
 	        End If;
	        Close C_TAX_ERRORS;

		If FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) Then
	           FND_MESSAGE.Set_Name('ASO','ASO_TAX_CALCULATION');
		   FND_MESSAGE.Set_Token('LINE',l_item_name);
                   FND_MESSAGE.Set_Token('TAXERROR',l_tax_errors);
	           FND_MSG_PUB.ADD;
		   x_return_status := FND_API.G_RET_STS_ERROR;
                End If;
		-- End: Code change done for Bug 19812910
	END IF;
	FND_MSG_PUB.Count_And_Get
	(
		p_count          =>   x_msg_count,
		p_data           =>   x_msg_data
	);

 EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
					                  P_API_NAME => L_API_NAME
								  ,P_PKG_NAME => G_PKG_NAME
								  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
								  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
								  ,X_MSG_COUNT => X_MSG_COUNT
								  ,X_MSG_DATA => X_MSG_DATA
								  ,X_RETURN_STATUS => X_RETURN_STATUS);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	                	ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
				                       P_API_NAME => L_API_NAME																											                      ,P_PKG_NAME => G_PKG_NAME
		                     		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
							       ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
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

end CALCULATE_TAX_WITH_GTT;
-- End Calculate Tax with GTT added as a part of etax By Anoop Rajan om 9 August 2005




FUNCTION Get_Tax_Detail_Id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN NUMBER
IS
    CURSOR c_tax1 IS
	SELECT tax_detail_id FROM ASO_TAX_DETAILS
	WHERE	quote_shipment_id = p_shipment_id;
    CURSOR c_tax2 IS
	SELECT tax_detail_id FROM ASO_TAX_DETAILS
	WHERE	quote_header_id = p_qte_header_id and quote_line_id is NULL
    and quote_shipment_id = p_shipment_id;
    CURSOR c_tax3 IS
	SELECT tax_detail_id FROM ASO_TAX_DETAILS
	WHERE	quote_header_id = p_qte_header_id and quote_shipment_id = p_shipment_id
    and quote_line_id = p_qte_line_id ;
    l_tax_detail_id		NUMBER;
BEGIN
    OPEN c_tax3;
    FETCH c_tax3 INTO l_tax_detail_id;
    IF c_tax3%FOUND and l_tax_detail_id is not null and l_tax_detail_id <> FND_API.G_MISS_NUM  THEN
	CLOSE c_tax3;
	return l_tax_detail_id;
    END IF;
    CLOSE c_tax3;
    OPEN c_tax2;
    FETCH c_tax2 INTO l_tax_detail_id ;
    IF c_tax2%FOUND and  l_tax_detail_id is not null and l_tax_detail_id <> FND_API.G_MISS_NUM  THEN
	CLOSE c_tax2;
	return l_tax_detail_id;
    END IF;
    CLOSE c_tax2;
    /*OPEN c_tax1;
    FETCH c_tax1 INTO l_tax_detail_id;
    IF c_tax1%FOUND and  l_tax_detail_id is not null and l_tax_detail_id <> FND_API.G_MISS_NUM  THEN
	CLOSE c_tax1;
	return l_tax_detail_id;
    END IF;
    CLOSE c_tax1;*/
    return l_tax_detail_id;
END Get_Tax_Detail_Id;



FUNCTION Get_Tax_Code (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2
IS
    CURSOR c_tax1 IS
	SELECT tax_code FROM ASO_TAX_DETAILS
	WHERE	quote_shipment_id = p_shipment_id ;
    CURSOR c_tax2 IS
	SELECT tax_code FROM ASO_TAX_DETAILS
	WHERE	quote_line_id = p_qte_line_id ;
    CURSOR c_tax3 IS
	SELECT tax_code FROM ASO_TAX_DETAILS
	WHERE	quote_header_id = p_qte_header_id ;
    l_orig_tax_code		VARCHAR2(240);
BEGIN
    OPEN c_tax1;
    FETCH c_tax1 INTO l_orig_tax_code;
    IF c_tax1%FOUND and l_orig_tax_code IS NOT NULL AND l_orig_tax_code <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax1;
	return l_orig_tax_code;
    END IF;
    CLOSE c_tax1;
    OPEN c_tax2;
    FETCH c_tax2 INTO l_orig_tax_code;
    IF c_tax2%FOUND  and l_orig_tax_code IS NOT NULL AND l_orig_tax_code <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax2;
	return l_orig_tax_code;
    END IF;
    CLOSE c_tax2;
    OPEN c_tax3;
    FETCH c_tax3 INTO l_orig_tax_code;
    IF c_tax3%FOUND  and l_orig_tax_code IS NOT NULL AND l_orig_tax_code <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax3;
	return l_orig_tax_code;
    END IF;
    CLOSE c_tax3;
    return l_orig_tax_code;
END Get_Tax_Code;

FUNCTION Get_Tax_exempt_flag (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2
IS
    CURSOR c_tax1 IS
	SELECT tax_exempt_flag FROM ASO_TAX_DETAILS
	WHERE	quote_shipment_id = p_shipment_id ;
    CURSOR c_tax2 IS
	SELECT tax_exempt_flag FROM ASO_TAX_DETAILS
	WHERE	quote_line_id = p_qte_line_id ;
    CURSOR c_tax3 IS
	SELECT tax_exempt_flag FROM ASO_TAX_DETAILS
	WHERE	quote_header_id = p_qte_header_id ;
    l_tax_exempt_flag		VARCHAR2(1);
BEGIN
    OPEN c_tax1;
    FETCH c_tax1 INTO l_tax_exempt_flag;
    IF c_tax1%FOUND and l_tax_exempt_flag is not null and  l_tax_exempt_flag <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax1;
	return l_tax_exempt_flag;
    END IF;
    CLOSE c_tax1;
    OPEN c_tax2;
    FETCH c_tax2 INTO l_tax_exempt_flag;
    IF c_tax2%FOUND  and l_tax_exempt_flag is not null and  l_tax_exempt_flag <> FND_API.G_MISS_CHAR THEN
	CLOSE c_tax2;
	return l_tax_exempt_flag;
    END IF;
    CLOSE c_tax2;
    OPEN c_tax3;
    FETCH c_tax3 INTO l_tax_exempt_flag;
    IF c_tax3%FOUND and l_tax_exempt_flag is not null and  l_tax_exempt_flag <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax3;
	return l_tax_exempt_flag;
    END IF;
    CLOSE c_tax3;
    return l_tax_exempt_flag;
END Get_Tax_Exempt_Flag;

FUNCTION Get_Tax_exempt_number (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2
IS
    CURSOR c_tax1 IS
	SELECT tax_exempt_number FROM ASO_TAX_DETAILS
	WHERE	quote_shipment_id = p_shipment_id ;
    CURSOR c_tax2 IS
	SELECT tax_exempt_number FROM ASO_TAX_DETAILS
	WHERE	quote_line_id = p_qte_line_id ;
    CURSOR c_tax3 IS
	SELECT tax_exempt_number FROM ASO_TAX_DETAILS
	WHERE	quote_header_id = p_qte_header_id ;
    l_tax_exempt_number		VARCHAR2(80);
BEGIN
    OPEN c_tax1;
    FETCH c_tax1 INTO l_tax_exempt_number;
    IF c_tax1%FOUND and l_tax_exempt_number is not null and  l_tax_exempt_number <> FND_API.G_MISS_CHAR THEN
	CLOSE c_tax1;
	return l_tax_exempt_number;
    END IF;
    CLOSE c_tax1;
    OPEN c_tax2;
    FETCH c_tax2 INTO l_tax_exempt_number;
    IF c_tax2%FOUND and l_tax_exempt_number is not null and  l_tax_exempt_number <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax2;
	return l_tax_exempt_number;
    END IF;
    CLOSE c_tax2;
    OPEN c_tax3;
    FETCH c_tax3 INTO l_tax_exempt_number;
    IF c_tax3%FOUND and l_tax_exempt_number is not null and  l_tax_exempt_number <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax3;
	return l_tax_exempt_number;
    END IF;
    CLOSE c_tax3;
    return l_tax_exempt_number;
END Get_Tax_Exempt_number;

FUNCTION Get_Tax_exempt_REASON_CODE (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2
IS
    CURSOR c_tax1 IS
	SELECT tax_exempt_reason_code FROM ASO_TAX_DETAILS
	WHERE	quote_shipment_id = p_shipment_id ;
    CURSOR c_tax2 IS
	SELECT tax_exempt_reason_code FROM ASO_TAX_DETAILS
	WHERE	quote_line_id = p_qte_line_id ;
    CURSOR c_tax3 IS
	SELECT tax_exempt_reason_code FROM ASO_TAX_DETAILS
	WHERE	quote_header_id = p_qte_header_id ;
    l_tax_exempt_reason_code		VARCHAR2(80);
BEGIN
    OPEN c_tax1;
    FETCH c_tax1 INTO l_tax_exempt_reason_code;
    IF c_tax1%FOUND  and l_tax_exempt_reason_code is not null and l_tax_exempt_reason_code <> FND_API.G_MISS_CHAR  THEN
	CLOSE c_tax1;
	return l_tax_exempt_reason_code;
    END IF;
    CLOSE c_tax1;
    OPEN c_tax2;
    FETCH c_tax2 INTO l_tax_exempt_reason_code;
    IF c_tax2%FOUND and  l_tax_exempt_reason_code is not null and l_tax_exempt_reason_code <> FND_API.G_MISS_CHAR THEN
	CLOSE c_tax2;
	return l_tax_exempt_reason_code;
    END IF;
    CLOSE c_tax2;
    OPEN c_tax3;
    FETCH c_tax3 INTO l_tax_exempt_reason_code;
    IF c_tax3%FOUND and l_tax_exempt_reason_code is not null and l_tax_exempt_reason_code <> FND_API.G_MISS_CHAR THEN
	CLOSE c_tax3;
	return l_tax_exempt_reason_code;
    END IF;
    CLOSE c_tax3;
    return l_tax_exempt_reason_code;
END Get_Tax_Exempt_reason_code;

FUNCTION Get_Tax_Invoice_To (
		p_ln_invoice_id		NUMBER,
		p_hd_invoice_id		NUMBER) RETURN NUMBER
IS
BEGIN
    return NVL(p_ln_invoice_id, p_hd_invoice_id);
END Get_Tax_Invoice_To;

FUNCTION GET_ra_trx_type_ID (p_order_type_id NUMBER,p_qte_line_rec ASO_QUOTE_PUB.Qte_Line_rec_Type) RETURN NUMBER
IS
CURSOR C_OE_trns(l_order_type_Id NUMBER) IS
    SELECT  default_inbound_line_type_id, default_outbound_line_type_id, cust_trx_type_id
    FROM    OE_TRANSACTION_TYPES_VL
    WHERE   transaction_type_id=l_order_type_Id;
l_in_line_type NUMBER;
l_out_line_type NUMBER;
l_cust_trx_type_id NUMBER;
l_inv_cust_trx_type_id NUMBER;
l_line_type_id NUMBER;
l_order_type_id NUMBER := p_order_type_id;
BEGIN

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add(' ASO_TAX_INT :p_order_type_id'||p_order_type_id , 1, 'N');
 END IF;

              IF p_order_type_id is NULL OR p_order_type_id = FND_API.G_MISS_NUM THEN

		-- Change START
		-- Release 12 MOAC Changes : Bug 4500739
		-- Changes Done by : Girish
		-- Comments : Changed to use HR EIT in place of org striped profile.

	       --l_order_type_id  := to_number(fnd_profile.value('ASO_ORDER_TYPE_ID'));
	       l_order_type_id  := to_number(ASO_UTILITY_PVT.get_ou_attribute_value(ASO_UTILITY_PVT.G_DEFAULT_ORDER_TYPE));

	       -- Change END

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add(' ASO_TAX_INT Porder_type id is null:l_order_type_id'||l_order_type_id , 1, 'N');
 END IF;

	      END IF;
              OPEN C_OE_trns(l_order_type_id);
              FETCH C_OE_trns INTO l_in_line_type, l_out_line_type, l_cust_trx_type_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN

   aso_debug_pub.add(' ASO_TAX_INT C_OE_trns:l_in_line_type,l_out_line_type,l_cust_trx_type_id'||l_in_line_type , 1, 'N');
   aso_debug_pub.add(' ASO_TAX_INT C_OE_trns:l_out_line_type'||l_out_line_type , 1, 'N');
   aso_debug_pub.add(' ASO_TAX_INT C_OE_trns:l_cust_trx_type_id'||l_cust_trx_type_id , 1, 'N');

END IF;


              IF C_OE_trns%NOTFOUND THEN
                NULL;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add(' ASO_TAX_INT C_OE_trns:NOT FOUND' , 1, 'N');
                END IF;

              END IF;
              CLOSE C_OE_trns;
              IF p_qte_line_rec.order_line_type_id is NULL or p_qte_line_rec.order_line_type_id = FND_API.G_MISS_NUM THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT   p_qte_line_rec.order_line_type_id is NULL' , 1, 'N');
END IF;

                IF p_qte_line_rec.line_category_code = 'ORDER' THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT   p_qte_line_rec.line_category_code '|| p_qte_line_rec.line_category_code , 1, 'N');
END IF;
                    l_line_type_id := l_out_line_type;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT   p_qte_line_rec.l_out_line_typ '|| l_out_line_type , 1, 'N');
END IF;

                ELSE
                    l_line_type_id := l_in_line_type;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT   p_qte_line_rec.li_n_line_typ '|| l_in_line_type , 1, 'N');
END IF;

                END IF;
              ELSE
                   l_line_type_id := p_qte_line_rec.order_line_type_id ;
              END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  l_line_type_id '|| l_line_type_id , 1, 'N');
END IF;

    IF p_qte_line_rec.line_category_code <> 'RETURN'  THEN  -- Standard Order Line

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  Line Category return ' , 1, 'N');
END IF;

           SELECT NVL(lt.cust_trx_type_id, 0)
           INTO   l_cust_trx_type_id
           FROM   oe_line_types_v lt
           WHERE  lt.line_type_id = l_line_type_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  l_cust_trx_type_id Category return '||l_cust_trx_type_id , 1, 'N');
END IF;

           IF l_cust_trx_type_id = 0 THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  l_cust_trx_type_id =0before  '||l_cust_trx_type_id , 1, 'N');
END IF;

              SELECT NVL(ot.cust_trx_type_id, 0)
              INTO   l_cust_trx_type_id
              FROM   oe_order_types_v ot
              WHERE  ot.order_type_id =l_order_type_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  l_cust_trx_type_id =0after  '||l_cust_trx_type_id , 1, 'N');
END IF;

              IF l_cust_trx_type_id = 0 THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  default from oe_invoice_trans profile   ' , 1, 'N');
END IF;
                /* This profile is obsoleted
                SELECT NVL(FND_PROFILE.VALUE('OE_INVOICE_TRANSACTION_TYPE_ID'), 0)
                INTO l_cust_trx_type_id
                FROM DUAL;
                */

                SELECT NVL(oe_sys_parameters.value('OE_INVOICE_TRANSACTION_TYPE_ID', p_qte_line_rec.org_id), 0)
                INTO l_cust_trx_type_id FROM DUAL;

              END IF;
           END IF;
            RETURN(l_cust_trx_type_id);
     ELSE -- Non Referenced Return Line

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  Non Referenced Return Line   ' , 1, 'N');
END IF;

             SELECT NVL(lt.cust_trx_type_id, 0)
             INTO   l_inv_cust_trx_type_id
             FROM   oe_line_types_v lt
             WHERE  lt.line_type_id = l_line_type_id;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  Non Referenced Return Line l_inv_cust_trx_type_id  '||l_inv_cust_trx_type_id , 1, 'N');
END IF;

             IF l_inv_cust_trx_type_id = 0 THEN
                  SELECT NVL(DECODE(ot.order_category_code, 'RETURN',ot.cust_trx_type_id, 0), 0)
                  INTO   l_inv_cust_trx_type_id
                  FROM   oe_order_types_v ot
                  WHERE  ot.order_type_id = l_order_type_id;
             END IF;
             IF l_inv_cust_trx_type_id <> 0 THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  Non Referenced Return Line credit memo ' , 1, 'N');
END IF;

                SELECT nvl(ctt.credit_memo_type_id, 0)
                INTO l_cust_trx_type_id
                --FROM ra_cust_trx_types_all ctt Commented Code Yogeshwar (MOAC)
                FROM ra_cust_trx_types ctt  --New Code Yogeshwar (MOAC)
		WHERE ctt.cust_trx_type_id = l_inv_cust_trx_type_id
                AND NVL(ctt.org_id, -3114) = DECODE(ctt.cust_trx_type_id,
                                               1, -3113,
                                               2, -3113,
                                               7, -3113,
                                               8, -3113,
                                               NVL(p_qte_line_rec.org_id, -3114));

            END IF;
            IF l_inv_cust_trx_type_id = 0 OR l_cust_trx_type_id = 0 THEN
                  SELECT NVL(FND_PROFILE.VALUE('OE_CREDIT_TRANSACTION_TYPE_ID'), 0)
                  INTO l_cust_trx_type_id
                  FROM DUAL;

            END IF;
            RETURN(l_cust_trx_type_id);
  END IF;

EXCEPTION
   WHEN OTHERS THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' ASO_TAX_INT  GET_RA_TRX In WHEN others ' , 1, 'N');
END IF;

      return(0);
END GET_ra_trx_type_ID;


-- Commenting the following routine as part of release 12. Bug 5044986
/*
 *
 *
PROCEDURE  print_tax_info_rec( p_debug_level in number := 5 ) IS
--  l_IO_flag		CHAR(1);
  dummy varchar2(80) := NULL;
BEGIN

IF ( p_debug_level <= aso_debug_pub.G_Debug_Level) THEN


  --
  -- Dump tax_info_rec
  --

  IF aso_debug_pub.g_debug_flag = 'Y' THEN

  aso_debug_pub.add( '************************************',1, 'Y' );
  aso_debug_pub.add( '**  Begining of Tax Info Record   **',1, 'Y' );
  aso_debug_pub.add( '************************************',1, 'Y' );
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Bill_to_cust_id = '||arp_tax.tax_info_rec.Bill_to_cust_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Ship_to_cust_id = '||arp_tax.tax_info_rec.Ship_to_cust_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Customer_trx_id = '||arp_tax.tax_info_rec.Customer_trx_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Trx_date = '||arp_tax.tax_info_rec.Trx_date);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': GL_date = '||arp_tax.tax_info_rec.gl_date);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Ship_to_site_use_id = '||arp_tax.tax_info_rec.Ship_to_site_use_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Bill_to_site_use_id = '||arp_tax.tax_info_rec.Bill_to_site_use_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Ship_to_postal_code = '||arp_tax.tax_info_rec.Ship_to_postal_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Bill_to_postal_code = '||arp_tax.tax_info_rec.Bill_to_postal_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Ship_to_location_id = '||arp_tax.tax_info_rec.Ship_to_location_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Bill_to_location_id = '||arp_tax.tax_info_rec.Bill_to_location_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Invoicing_rule_id = '||arp_tax.tax_info_rec.Invoicing_rule_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': FOB_point = '||arp_tax.tax_info_rec.FOB_point);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Trx_currency_code = '||arp_tax.tax_info_rec.Trx_currency_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Trx_exchange_rate = '||arp_tax.tax_info_rec.Trx_exchange_rate);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Minimum_accountable_unit = '||arp_tax.tax_info_rec.Minimum_accountable_unit);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Precision = '||arp_tax.tax_info_rec.Precision);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Customer_trx_line_id = '||arp_tax.tax_info_rec.Customer_trx_line_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': link_to_cust_trx_line_id = '||arp_tax.tax_info_rec.link_to_cust_trx_line_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Memo_line_id = '||arp_tax.tax_info_rec.Memo_line_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Taxed_quantity = '||arp_tax.tax_info_rec.Taxed_quantity);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Inventory_item_id = '||arp_tax.tax_info_rec.Inventory_item_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Extended_amount = '||arp_tax.tax_info_rec.Extended_amount);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_code = '||arp_tax.tax_info_rec.Tax_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Vat_tax_id = '||arp_tax.tax_info_rec.Vat_tax_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_exemption_id = '||arp_tax.tax_info_rec.Tax_exemption_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Item_exception_rate_id = '||arp_tax.tax_info_rec.Item_exception_rate_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_rate = '||arp_tax.tax_info_rec.Tax_rate);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Default_ussgl_transaction_code = '||arp_tax.tax_info_rec.Default_ussgl_transaction_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Default_ussgl_trx_code_context = '||arp_tax.tax_info_rec.Default_ussgl_trx_code_context);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_control = '||arp_tax.tax_info_rec.Tax_control);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Qualifier = '||arp_tax.tax_info_rec.Qualifier);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Ship_from_code = '||arp_tax.tax_info_rec.Ship_from_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Ship_to_code = '||arp_tax.tax_info_rec.Ship_to_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Poo_code = '||arp_tax.tax_info_rec.Poo_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Poa_code = '||arp_tax.tax_info_rec.Poa_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Vdrctrl_exempt = '||arp_tax.tax_info_rec.Vdrctrl_exempt);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Xmpt_cert_no = '||arp_tax.tax_info_rec.Xmpt_cert_no);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Xmpt_reason = '||arp_tax.tax_info_rec.Xmpt_reason);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Xmpt_percent = '||arp_tax.tax_info_rec.Xmpt_percent);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Part_no = '||arp_tax.tax_info_rec.Part_no);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf1 = '||arp_tax.tax_info_rec.Userf1);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf2 = '||arp_tax.tax_info_rec.Userf2);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf3 = '||arp_tax.tax_info_rec.Userf3);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf4 = '||arp_tax.tax_info_rec.Userf4);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf5 = '||arp_tax.tax_info_rec.Userf5);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf6 = '||arp_tax.tax_info_rec.Userf6);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf7 = '||arp_tax.tax_info_rec.Userf7);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf8 = '||arp_tax.tax_info_rec.Userf8);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf9 = '||arp_tax.tax_info_rec.Userf9);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Userf10 = '||arp_tax.tax_info_rec.Userf10);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern1 = '||arp_tax.tax_info_rec.Usern1);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern2 = '||arp_tax.tax_info_rec.Usern2);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern3 = '||arp_tax.tax_info_rec.Usern3);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern4 = '||arp_tax.tax_info_rec.Usern4);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern5 = '||arp_tax.tax_info_rec.Usern5);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern6 = '||arp_tax.tax_info_rec.Usern6);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern7 = '||arp_tax.tax_info_rec.Usern7);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern8 = '||arp_tax.tax_info_rec.Usern8);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern9 = '||arp_tax.tax_info_rec.Usern9);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Usern10 = '||arp_tax.tax_info_rec.Usern10);

  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': trx_number = '||arp_tax.tax_info_rec.trx_number);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': previous_customer_trx_line_id = '||arp_tax.tax_info_rec.previous_customer_trx_line_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': previous_customer_trx_id = '||arp_tax.tax_info_rec.previous_customer_trx_id);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': previous_trx_number = '||arp_tax.tax_info_rec.previous_trx_number);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': bill_to_customer_number = '||arp_tax.tax_info_rec.bill_to_customer_number);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': ship_to_customer_number = '||arp_tax.tax_info_rec.ship_to_customer_number);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': bill_to_customer_name = '||arp_tax.tax_info_rec.bill_to_customer_name);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': ship_to_customer_name = '||arp_tax.tax_info_rec.ship_to_customer_name);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Audit_Flag = ' || arp_tax.tax_info_rec.audit_flag);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Trx_Line_Type = ' || arp_tax.tax_info_rec.trx_line_type);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Division Code = ' || arp_tax.tax_info_rec.division_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Company Code = '|| arp_tax.tax_info_rec.company_code);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Calculate_tax = '||arp_tax.tax_info_rec.Calculate_tax);
  aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Status = '||arp_tax.tax_info_rec.Status);
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    IF ( arp_tax.tax_info_rec.tax_type = 0 ) THEN
	 dummy := 'TAX_TYPE_INACTIVE';
    ELSIF ( arp_tax.tax_info_rec.tax_type = 1 ) THEN
	 dummy := 'TAX_TYPE_LOCATION';
    ELSIF ( arp_tax.tax_info_rec.tax_type = 2 ) THEN
	 dummy := 'TAX_TYPE_SALES';
    ELSIF ( arp_tax.tax_info_rec.tax_type = 3 ) THEN
	 dummy := 'TAX_TYPE_VAT';
    ELSE
	 dummy := null;
    END IF;
  END IF;


  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_type = '||arp_tax.tax_info_rec.tax_type||' : '||dummy);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Sales_tax_id = '||arp_tax.tax_info_rec.Sales_tax_id);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Location_segment_id = '||arp_tax.tax_info_rec.Location_segment_id);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_line_number = '||arp_tax.tax_info_rec.Tax_line_number);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_amount = '||arp_tax.tax_info_rec.Tax_amount);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_vendor_return_code = '||dummy);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_precedence = '||arp_tax.tax_info_rec.Tax_precedence);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Compound_amount = '||arp_tax.tax_info_rec.Compound_amount);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_header_level_flag = '||arp_tax.tax_info_rec.Tax_header_level_flag);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Tax_rounding_rule = '||arp_tax.tax_info_rec.Tax_rounding_rule);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Trx_type_id = '||arp_tax.tax_info_rec.Trx_type_id);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Ship_From_Warehouse_id = '||arp_tax.tax_info_rec.Ship_From_Warehouse_id);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Amount_includes_tax_flag = '||arp_tax.tax_info_rec.Amount_includes_tax_flag);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Customer_trx_charge_line_id = '||arp_tax.tax_info_rec.customer_trx_charge_line_id);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Poo_id = '||arp_tax.tax_info_rec.poo_id);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Poa_id = '||arp_tax.tax_info_rec.poa_id);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Taxable_amount = '||arp_tax.tax_info_rec.taxable_amount);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Taxable_basis = '||arp_tax.tax_info_rec.taxable_basis);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Override Tax Rate = '||arp_tax.tax_info_rec.override_tax_rate);
    aso_debug_pub.add( 'arp_tax.tax_info_rec'||': Party Flag = '||arp_tax.tax_info_rec.party_flag);
    aso_debug_pub.add( '*******************************');
    aso_debug_pub.add( '**  End of Tax Info Record   **');
    aso_debug_pub.add( '*******************************');
    aso_debug_pub.add( 'print_tax_info_rec()-' ,1, 'N');
  END IF;

END IF;
END print_tax_info_rec;
*
*
*/

--Procedure added by Anoop on 14 Sep 2005 to print TAX GTT details

Procedure print_tax_info(
	rec in number,
	qte_header_id in number)
IS
cursor c1 is select
	INTERNAL_ORGANIZATION_ID,
	INTERNAL_ORG_LOCATION_ID,
	APPLICATION_ID,
	ENTITY_CODE,
	EVENT_CLASS_CODE,
	EVENT_TYPE_CODE,
	TRX_ID,
	TRX_DATE,
	LEDGER_ID,
	TRX_CURRENCY_CODE,
	CURRENCY_CONVERSION_DATE,
	CURRENCY_CONVERSION_RATE,
	CURRENCY_CONVERSION_TYPE,
	MINIMUM_ACCOUNTABLE_UNIT,
	PRECISION,
	LEGAL_ENTITY_ID,
	QUOTE_FLAG,
	TRX_NUMBER,
	TAX_EVENT_TYPE_CODE,
	TAX_REPORTING_FLAG,
	SHIP_TO_CUST_ACCT_SITE_USE_ID,
	BILL_TO_CUST_ACCT_SITE_USE_ID,
	DOC_LEVEL_RECALC_FLAG,
	SHIP_THIRD_PTY_ACCT_SITE_ID,
	BILL_THIRD_PTY_ACCT_SITE_ID,
	SHIP_THIRD_PTY_ACCT_ID,
	BILL_THIRD_PTY_ACCT_ID,
	ROUNDING_BILL_TO_PARTY_ID
from
	ZX_TRX_HEADERS_GT
where
	TRX_ID=qte_header_id;

Cursor c2 is select
	APPLICATION_ID,
	ENTITY_CODE,
	EVENT_CLASS_CODE,
	TRX_ID,
	TRX_LEVEL_TYPE,
	TRX_LINE_ID,
	LINE_LEVEL_ACTION,
	LINE_CLASS,
	TRX_SHIPPING_DATE,
	TRX_LINE_TYPE,
	TRX_LINE_DATE,
	TRX_BUSINESS_CATEGORY,
	LINE_AMT,
	TRX_LINE_QUANTITY,
	EXEMPT_CERTIFICATE_NUMBER,
	EXEMPT_REASON_CODE,
	PRODUCT_ID,
	PRODUCT_ORG_ID,
	UOM_CODE,
	PRODUCT_TYPE,
	FOB_POINT,
	SHIP_TO_PARTY_ID,
	SHIP_FROM_PARTY_ID,
	BILL_TO_PARTY_ID,
	SHIP_TO_PARTY_SITE_ID,
	BILL_TO_PARTY_SITE_ID,
	SHIP_TO_LOCATION_ID,
	BILL_TO_LOCATION_ID,
	SHIP_FROM_LOCATION_ID,
	HISTORICAL_FLAG,
	LINE_AMT_INCLUDES_TAX_FLAG,
	EXEMPTION_CONTROL_FLAG,
	UNIT_PRICE,
	TRX_LINE_GL_DATE,
	RECEIVABLES_TRX_TYPE_ID,
	BILL_TO_CUST_ACCT_SITE_USE_ID,
	SHIP_TO_CUST_ACCT_SITE_USE_ID,
	SHIP_THIRD_PTY_ACCT_SITE_ID,
	BILL_THIRD_PTY_ACCT_SITE_ID,
	SHIP_THIRD_PTY_ACCT_ID,
	BILL_THIRD_PTY_ACCT_ID,
	CTRL_HDR_TX_APPL_FLAG,
	TRX_LINE_NUMBER,
	BILL_FROM_LOCATION_ID, /*** Added for Bug 8474803 and 7408162 ***/
	PRODUCT_FISC_CLASSIFICATION -- ER 12879412
from
	Zx_transaction_lines_gt
where
	TRX_ID=qte_header_id;

Cursor c3 is select
	TRX_ID,
	TRX_LINE_ID,
	TAX_RATE_CODE,
	TAX_RATE,
	TAX_DETERMINE_DATE,
	TAX_AMT,
	EXEMPT_CERTIFICATE_NUMBER,
	EXEMPT_REASON_CODE,
	TAX_AMT_INCLUDED_FLAG,
	OBJECT_VERSION_NUMBER,
	TAX_RATE_ID
from
	Zx_detail_tax_lines_gt
where
	TRX_ID=qte_header_id;

BEGIN
	IF (aso_debug_pub.g_debug_flag = 'Y' and rec=1) THEN
		for i in c1 LOOP
			aso_debug_pub.add( '******************************************',1, 'Y' );
			aso_debug_pub.add( '*****  After insertion into ZX_TRX_HEADERS_GTT *****',1, 'Y' );
			aso_debug_pub.add( '******************************************',1, 'Y' );
			aso_debug_pub.add(rpad('INTERNAL_ORGANIZATION_ID',50,'------')||'------>'||i.INTERNAL_ORGANIZATION_ID , 1, 'Y');
			aso_debug_pub.add(rpad('INTERNAL_ORG_LOCATION_ID',50,'------')||'------>'||i.INTERNAL_ORG_LOCATION_ID , 1, 'Y');
			aso_debug_pub.add(rpad('APPLICATION_ID',50,'------')||'------>'||i.APPLICATION_ID , 1, 'Y');
			aso_debug_pub.add(rpad('ENTITY_CODE',50,'------')||'------>'||i.ENTITY_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('EVENT_CLASS_CODE',50,'------')||'------>'||i.EVENT_CLASS_CODE  , 1, 'Y');
			aso_debug_pub.add(rpad('EVENT_TYPE_CODE',50,'------')||'------>'||i.EVENT_TYPE_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_ID',50,'------')||'------>'||i.TRX_ID , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_DATE',50,'------')||'------>'||i.TRX_DATE , 1, 'Y');
			aso_debug_pub.add(rpad('LEDGER_ID',50,'------')||'------>'||i.LEDGER_ID , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_CURRENCY_CODE',50,'------')||'------>'||i.TRX_CURRENCY_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('CURRENCY_CONVERSION_DATE',50,'------')||'------>'||i.CURRENCY_CONVERSION_DATE , 1, 'Y');
			aso_debug_pub.add(rpad('CURRENCY_CONVERSION_RATE',50,'------')||'------>'||i.CURRENCY_CONVERSION_RATE , 1, 'Y');
			aso_debug_pub.add(rpad('CURRENCY_CONVERSION_TYPE',50,'------')||'------>'||i.CURRENCY_CONVERSION_TYPE , 1, 'Y');
			aso_debug_pub.add(rpad('MINIMUM_ACCOUNTABLE_UNIT',50,'------')||'------>'||i.MINIMUM_ACCOUNTABLE_UNIT , 1, 'Y');
			aso_debug_pub.add(rpad('PRECISION',50,'------')||'------>'||i.PRECISION , 1, 'Y');
			aso_debug_pub.add(rpad('LEGAL_ENTITY_ID',50,'------')||'------>'||i.LEGAL_ENTITY_ID , 1, 'Y');
			aso_debug_pub.add(rpad('QUOTE_FLAG',50,'------')||'------>'||i.QUOTE_FLAG , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_NUMBER',50,'------')||'------>'||i.TRX_NUMBER , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_EVENT_TYPE_CODE',50,'------')||'------>'||i.TAX_EVENT_TYPE_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_REPORTING_FLAG',50,'------')||'------>'||i.TAX_REPORTING_FLAG , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_TO_CUST_ACCT_SITE_USE_ID',50,'------')||'------>'||i.SHIP_TO_CUST_ACCT_SITE_USE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_TO_CUST_ACCT_SITE_USE_ID',50,'------')||'------>'||i.BILL_TO_CUST_ACCT_SITE_USE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('DOC_LEVEL_RECALC_FLAG',50,'------')||'------>'||i.DOC_LEVEL_RECALC_FLAG , 1, 'Y');
		 	aso_debug_pub.add(rpad('SHIP_THIRD_PTY_ACCT_SITE_ID',50,'------')||'------>'||i.SHIP_THIRD_PTY_ACCT_SITE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_THIRD_PTY_ACCT_SITE_ID',50,'------')||'------>'||i.BILL_THIRD_PTY_ACCT_SITE_ID , 1, 'Y');
	 		aso_debug_pub.add(rpad('SHIP_THIRD_PTY_ACCT_ID',50,'------')||'------>'||i.SHIP_THIRD_PTY_ACCT_ID , 1, 'Y');
		 	aso_debug_pub.add(rpad('BILL_THIRD_PTY_ACCT_ID',50,'------')||'------>'||i.BILL_THIRD_PTY_ACCT_ID , 1, 'Y');
			aso_debug_pub.add(rpad('ROUNDING_BILL_TO_PARTY_ID',50,'------')||'------>'||i.ROUNDING_BILL_TO_PARTY_ID , 1, 'Y');
			aso_debug_pub.add(rpad('*',100,'*'),1, 'Y' );
			--aso_debug_pub.add('*****INSERTED INTO ZX_TRX_HEADERS_GTT*****',1, 'Y' );
			--aso_debug_pub.add('******************************************',1, 'Y' );
		end loop;
	ELSIF (aso_debug_pub.g_debug_flag = 'Y' and rec=2) THEN
		for i in c2 loop
			aso_debug_pub.add( '******************************************',1, 'Y' );
			aso_debug_pub.add( '*****  After insertion into Zx_transaction_lines_gt *****',1, 'Y' );
			aso_debug_pub.add( '******************************************',1, 'Y' );
                	aso_debug_pub.add(rpad('APPLICATION_ID',50,'------')||'------>'||i.APPLICATION_ID , 1, 'Y');
			aso_debug_pub.add(rpad('ENTITY_CODE',50,'------')||'------>'||i.ENTITY_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('EVENT_CLASS_CODE',50,'------')||'------>'||i.EVENT_CLASS_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_ID',50,'------')||'------>'||i.TRX_ID , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LEVEL_TYPE',50,'------')||'------>'||i.TRX_LEVEL_TYPE , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LINE_ID',50,'------')||'------>'||i.TRX_LINE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('LINE_LEVEL_ACTION',50,'------')||'------>'||i.LINE_LEVEL_ACTION , 1, 'Y');
			aso_debug_pub.add(rpad('LINE_CLASS',50,'------')||'------>'||i.LINE_CLASS , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_SHIPPING_DATE',50,'------')||'------>'||i.TRX_SHIPPING_DATE , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LINE_TYPE',50,'------')||'------>'||i.TRX_LINE_TYPE , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LINE_DATE',50,'------')||'------>'||i.TRX_LINE_DATE , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_BUSINESS_CATEGORY',50,'------')||'------>'||i.TRX_BUSINESS_CATEGORY , 1, 'Y');
			aso_debug_pub.add(rpad('LINE_AMT',50,'------')||'------>'||i.LINE_AMT, 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LINE_QUANTITY',50,'------')||'------>'||i.TRX_LINE_QUANTITY , 1, 'Y');
			aso_debug_pub.add(rpad('EXEMPT_CERTIFICATE_NUMBER',50,'------')||'------>'||i.EXEMPT_CERTIFICATE_NUMBER , 1, 'Y');
			aso_debug_pub.add(rpad('EXEMPT_REASON_CODE',50,'------')||'------>'||i.EXEMPT_REASON_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('PRODUCT_ID',50,'------')||'------>'||i.PRODUCT_ID , 1, 'Y');
			aso_debug_pub.add(rpad('PRODUCT_ORG_ID',50,'------')||'------>'||i.PRODUCT_ORG_ID , 1, 'Y');
			aso_debug_pub.add(rpad('UOM_CODE',50,'------')||'------>'||i.UOM_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('PRODUCT_TYPE',50,'------')||'------>'||i.PRODUCT_TYPE , 1, 'Y');
			aso_debug_pub.add(rpad('FOB_POINT',50,'------')||'------>'||i.FOB_POINT , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_TO_PARTY_ID',50,'------')||'------>'||i.SHIP_TO_PARTY_ID , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_FROM_PARTY_ID',50,'------')||'------>'||i.SHIP_FROM_PARTY_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_TO_PARTY_ID',50,'------')||'------>'||i.BILL_TO_PARTY_ID , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_TO_PARTY_SITE_ID',50,'------')||'------>'||i.SHIP_TO_PARTY_SITE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_TO_PARTY_SITE_ID',50,'------')||'------>'||i.BILL_TO_PARTY_SITE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_TO_LOCATION_ID',50,'------')||'------>'||i.SHIP_TO_LOCATION_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_TO_LOCATION_ID',50,'------')||'------>'||i.BILL_TO_LOCATION_ID , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_FROM_LOCATION_ID',50,'------')||'------>'||i.SHIP_FROM_LOCATION_ID , 1, 'Y');
			aso_debug_pub.add(rpad('HISTORICAL_FLAG',50,'------')||'------>'||i.HISTORICAL_FLAG , 1, 'Y');
			aso_debug_pub.add(rpad('LINE_AMT_INCLUDES_TAX_FLAG',50,'------')||'------>'||i.LINE_AMT_INCLUDES_TAX_FLAG , 1, 'Y');
			aso_debug_pub.add(rpad('EXEMPTION_CONTROL_FLAG',50,'------')||'------>'||i.EXEMPTION_CONTROL_FLAG , 1, 'Y');
			aso_debug_pub.add(rpad('UNIT_PRICE',50,'------')||'------>'||i.UNIT_PRICE , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LINE_GL_DATE',50,'------')||'------>'||i.TRX_LINE_GL_DATE , 1, 'Y');
			aso_debug_pub.add(rpad('RECEIVABLES_TRX_TYPE_ID',50,'------')||'------>'||i.RECEIVABLES_TRX_TYPE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_TO_CUST_ACCT_SITE_USE_ID',50,'------')||'------>'||i.BILL_TO_CUST_ACCT_SITE_USE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_TO_CUST_ACCT_SITE_USE_ID',50,'------')||'------>'||i.SHIP_TO_CUST_ACCT_SITE_USE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_THIRD_PTY_ACCT_SITE_ID',50,'------')||'------>'||i.SHIP_THIRD_PTY_ACCT_SITE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_THIRD_PTY_ACCT_SITE_ID',50,'------')||'------>'||i.BILL_THIRD_PTY_ACCT_SITE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('SHIP_THIRD_PTY_ACCT_ID',50,'------')||'------>'||i.SHIP_THIRD_PTY_ACCT_ID , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_THIRD_PTY_ACCT_ID',50,'------')||'------>'||i.BILL_THIRD_PTY_ACCT_ID , 1, 'Y');
			aso_debug_pub.add(rpad('CTRL_HDR_TX_APPL_FLAG ',50,'------')||'------>'||i.CTRL_HDR_TX_APPL_FLAG , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LINE_NUMBER	 ',50,'------')||'------>'||i.TRX_LINE_NUMBER , 1, 'Y');
			aso_debug_pub.add(rpad('BILL_FROM_LOCATION_ID',50,'------')||'------>'||i.BILL_FROM_LOCATION_ID , 1, 'Y'); /*** Added for Bug 8474803 and 7408162 ***/
			aso_debug_pub.add(rpad('PRODUCT_FISC_CLASSIFICATION',50,'------')||'------>'||i.PRODUCT_FISC_CLASSIFICATION , 1, 'Y'); /*** Added for ER 12879412 ***/
			aso_debug_pub.add(rpad('TRX_BUSINESS_CATEGORY',50,'------')||'------>'||i.TRX_BUSINESS_CATEGORY , 1, 'Y'); /*** Added for ER 12879412  ***/
			aso_debug_pub.add(rpad('*',100,'*'),1, 'Y' );
		end loop;
	ELSIF (aso_debug_pub.g_debug_flag = 'Y' and rec=3) THEN
		for i in c3 loop
			aso_debug_pub.add( '******************************************',1, 'Y' );
			aso_debug_pub.add( '*****  After insertion into Zx_detail_tax_lines_gt *****',1, 'Y' );
			aso_debug_pub.add( '******************************************',1, 'Y' );
			aso_debug_pub.add(rpad('TRX_ID',50,'------')||'------>'||i.TRX_ID , 1, 'Y');
			aso_debug_pub.add(rpad('TRX_LINE_ID',50,'------')||'------>'||i.TRX_LINE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_RATE_CODE',50,'------')||'------>'||i.TAX_RATE_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_RATE',50,'------')||'------>'||i.TAX_RATE , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_DETERMINE_DATE',50,'------')||'------>'||i.TAX_DETERMINE_DATE , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_AMT',50,'------')||'------>'||i.TAX_AMT , 1, 'Y');
			aso_debug_pub.add(rpad('EXEMPT_CERTIFICATE_NUMBER',50,'------')||'------>'||i.EXEMPT_CERTIFICATE_NUMBER , 1, 'Y');
			aso_debug_pub.add(rpad('EXEMPT_REASON_CODE',50,'------')||'------>'||i.EXEMPT_REASON_CODE , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_AMT_INCLUDED_FLAG',50,'------')||'------>'||i.TAX_AMT_INCLUDED_FLAG , 1, 'Y');
			aso_debug_pub.add(rpad('OBJECT_VERSION_NUMBER',50,'------')||'------>'||i.OBJECT_VERSION_NUMBER , 1, 'Y');
			aso_debug_pub.add(rpad('TAX_RATE_ID',50,'------')||'------>'||i.TAX_RATE_ID , 1, 'Y');
			aso_debug_pub.add(rpad('*',100,'*'),1, 'Y' );
		end loop;
        END IF;

END print_tax_info;

End ASO_TAX_INT;

/
