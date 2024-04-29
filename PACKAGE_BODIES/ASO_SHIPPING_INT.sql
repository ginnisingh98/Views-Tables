--------------------------------------------------------
--  DDL for Package Body ASO_SHIPPING_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SHIPPING_INT" as
/* $Header: asoishpb.pls 120.3 2006/02/07 11:53:58 skulkarn ship $ */
-- Start of Comments
-- Package name     : ASO_SHIPPING_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_SHIPPING_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoishpb.pls';

--wli_start
FUNCTION Get_Total_Freight_Charges(p_qte_header_id NUMBER)
RETURN NUMBER
IS
   l_index                 NUMBER := 0;
   l_total_freight_charge  NUMBER := 0;

   CURSOR header_freight_cursor(l_quote_header_id NUMBER) IS
      SELECT APA.operand            ,
             APA.arithmetic_operator
      FROM aso_price_adjustments APA
      WHERE APA.modifier_line_type_code = 'FREIGHT_CHARGE'
        AND APA.quote_header_id = l_quote_header_id
        AND APA.quote_line_id IS NULL
	   AND APA.APPLIED_FLAG = 'Y';

   CURSOR line_freight_cursor(l_quote_header_id NUMBER) IS
      SELECT APA.operand            ,
             APA.arithmetic_operator,
             AQLA.quantity          ,
             AQLA.line_list_price
      FROM aso_price_adjustments APA,
           aso_quote_lines_all   AQLA
      WHERE APA.modifier_line_type_code = 'FREIGHT_CHARGE'
        AND APA.quote_header_id = l_quote_header_id
--        AND APA.quote_header_id = AQLA.quote_header_id
        AND APA.quote_line_id   = AQLA.quote_line_id
	   AND APA.APPLIED_FLAG = 'Y';
BEGIN

   FOR header_freight IN header_freight_cursor(p_qte_header_id) LOOP
      IF header_freight.arithmetic_operator = 'LUMPSUM' THEN
         l_total_freight_charge := l_total_freight_charge + header_freight.operand;
      END IF;
   END LOOP;

   FOR line_freight IN line_freight_cursor(p_qte_header_id) LOOP
      IF line_freight.arithmetic_operator = '%' THEN
         l_total_freight_charge := l_total_freight_charge + line_freight.line_list_price * line_freight.operand * line_freight.quantity/100.0;
      END IF;

      IF line_freight.arithmetic_operator = 'AMT' THEN
         l_total_freight_charge := l_total_freight_charge + line_freight.operand * line_freight.quantity;
      END IF;

      IF line_freight.arithmetic_operator = 'LUMPSUM' THEN
         l_total_freight_charge := l_total_freight_charge + line_freight.operand;
      END IF;
   END LOOP;

   RETURN l_total_freight_charge;
END Get_Total_Freight_Charges;


FUNCTION Get_line_Freight_charges(
	p_qte_header_id	 NUMBER := FND_API.G_MISS_NUM
	,p_qte_line_id	 NUMBER := FND_API.G_MISS_NUM )
RETURN number
is

l_operand	number;
l_arithmetic_operator  varchar2(20);
l_quantity	number;
l_line_list_price	number;
l_adjusted_amount NUMBER;

cursor c_line_charge(l_qte_header_id number, l_qte_line_id number ) is
   select p.operand, p.arithmetic_operator, l.quantity, l.line_list_price,p.ADJUSTED_AMOUNT
   from aso_price_adjustments p, aso_quote_lines_all l
   where p.modifier_line_type_code = 'FREIGHT_CHARGE'
   and p.quote_line_id = l.quote_line_id
   and p.quote_header_id = l_qte_header_id
   and p.quote_line_id = l_qte_line_id
   AND p.APPLIED_FLAG = 'Y';


   l_index	number:=0;
   l_charge_amount number :=0;
begin

   open c_line_charge(p_qte_header_id, p_qte_line_id);
   loop
   fetch c_line_charge
    into l_operand, l_arithmetic_operator, l_quantity, l_line_list_price, l_adjusted_amount;
   exit when c_line_charge%notfound;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_SHIPPING_INT:c_line_charge - l_quantity:'||l_quantity,1,'Y');
      aso_debug_pub.add('ASO_SHIPPING_INT:c_line_charge - l_line_list_price:'||l_line_list_price,1,'Y');
      aso_debug_pub.add('ASO_SHIPPING_INT:c_line_charge - l_adjusted_amount:'||l_adjusted_amount,1,'Y');
      aso_debug_pub.add('ASO_SHIPPING_INT:c_line_charge - l_arithmetic_operator:'||l_arithmetic_operator,1,'Y');
      aso_debug_pub.add('ASO_SHIPPING_INT:c_line_charge - l_operand:'||l_operand,1,'Y');
   END IF;

   if (l_arithmetic_operator = '%') then
	l_charge_amount := l_charge_amount +  (l_adjusted_amount*l_quantity) ;
   end if;

   if (l_arithmetic_operator = 'AMT' ) then
	l_charge_amount := l_charge_amount + l_operand*l_quantity;
   end if;

   if (l_arithmetic_operator = 'LUMPSUM' ) then
      l_charge_amount := l_charge_amount + l_operand;
   end if;

   end loop;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_SHIPPING_INT:c_line_charge - l_charge_amount:'||NVL(l_charge_amount,0),1,'Y');
   END IF;
   return nvl(l_charge_amount,0);
end get_line_freight_charges;
--wli_end





PROCEDURE Calculate_Freight_Charges(
    P_Api_Version_Number	 IN   NUMBER,
    P_Charge_Control_Rec	 IN   Charge_Control_Rec_Type
					:= G_Miss_Charge_Control_Rec,
    P_Qte_Header_Rec		 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec		 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Line_Rec,
    P_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    x_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
    l_api_name			CONSTANT VARCHAR2(30) := 'Calculate_Freight_Charges';
    l_freight_charge_rec	ASO_QUOTE_PUB.Freight_Charge_Rec_Type;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR i IN 1..P_Shipment_Tbl.count LOOP
        l_freight_charge_rec.operation_code := 'CREATE';
        l_freight_charge_rec.QUOTE_LINE_ID := P_Qte_Line_Rec.quote_line_id;
        l_freight_charge_rec.QUOTE_SHIPMENT_ID := P_Shipment_Tbl(i).shipment_id;
	l_freight_charge_rec.SHIPMENT_INDEX := i;
        l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID := -1;
        l_freight_charge_rec.CHARGE_AMOUNT := 0;
        x_Freight_Charge_Tbl(x_Freight_Charge_Tbl.count+1) := l_freight_charge_rec;
    END LOOP;

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
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Calculate_Freight_Charges;

FUNCTION Get_Header_Freight_Charges(p_qte_header_id NUMBER)
RETURN NUMBER
IS
   l_index                 NUMBER := 0;
   l_total_freight_charge  NUMBER := 0;

   CURSOR header_freight_cursor(l_quote_header_id NUMBER) IS
      SELECT APA.operand            ,
             APA.arithmetic_operator
      FROM aso_price_adjustments APA
      WHERE APA.modifier_line_type_code = 'FREIGHT_CHARGE'
        AND APA.quote_header_id = l_quote_header_id
        AND APA.quote_line_id IS NULL
	   AND APA.APPLIED_FLAG = 'Y';


BEGIN

   FOR header_freight IN header_freight_cursor(p_qte_header_id) LOOP
      IF header_freight.arithmetic_operator = 'LUMPSUM' THEN
         l_total_freight_charge := l_total_freight_charge + header_freight.operand;
      END IF;
   END LOOP;



   RETURN nvl(l_total_freight_charge,0);
END Get_Header_Freight_Charges;


End ASO_SHIPPING_INT;

/
