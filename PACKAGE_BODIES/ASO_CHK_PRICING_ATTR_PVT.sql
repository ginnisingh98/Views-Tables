--------------------------------------------------------
--  DDL for Package Body ASO_CHK_PRICING_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CHK_PRICING_ATTR_PVT" as
/* $Header: asovpatrb.pls 120.1 2005/06/29 12:42:53 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_CHK_PRICING_ATTR_PVT
-- Purpose          :
-- History          :
-- NOTE             :
--
-- End of Comments

PROCEDURE Check_Pricing_Attributes (
	 P_Api_Version_Number         	IN   NUMBER		:= 1,
	 P_Init_Msg_List              	IN   VARCHAR2     	:= FND_API.G_FALSE,
	 P_Commit                     	IN   VARCHAR2     	:= FND_API.G_FALSE,
	 P_Inventory_Id				IN	NUMBER		:= FND_API.G_MISS_NUM,
	 P_Quote_Line_Id				IN	NUMBER		:= FND_API.G_MISS_NUM,
	 P_Price_List_Id				IN	NUMBER		:= FND_API.G_MISS_NUM,
	 X_Check_Return_Status_qp	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	 X_Check_Return_Status_aso         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	 x_msg_count         		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
	 x_msg_data          		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS

 CURSOR c_check_qpprc_atr IS
 SELECT distinct l.list_line_id
 FROM  qp_list_lines l, qp_pricing_attributes a
 WHERE l.list_line_id = a.list_line_id
 AND l.list_header_id = P_Price_List_Id
 AND   l.list_line_type_code = 'PLL'
 AND   a.product_attribute_context = 'ITEM'
 AND   a.product_attribute = 'PRICING_ATTRIBUTE1'
 AND   a.product_attr_value = P_Inventory_Id
 AND   (price_by_formula_id  IN (SELECT price_formula_id
						  FROM qp_price_formulas_b
						  WHERE EXISTS (SELECT 'x'
									 FROM  qp_price_formula_lines fl, qp_price_formulas_b b
								      WHERE fl.price_formula_line_type_code = 'PRA'
									 AND   fl.price_formula_id = b.price_formula_id)
						  )
 	  OR (a.pricing_attribute_context IS NOT NULL
	   AND  a.pricing_attribute IS NOT NULL )
	  );

CURSOR c_check_asorec IS
SELECT count(rowid) r_count
FROM aso_price_attributes
WHERE quote_line_id = P_Quote_Line_Id;

l_count NUMBER;
l_list_line_id NUMBER;

BEGIN
	aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
	X_Check_Return_Status_qp := FND_API.G_FALSE;
	X_Check_Return_Status_aso := FND_API.G_FALSE;

		OPEN  c_check_qpprc_atr;
		FETCH  c_check_qpprc_atr  INTO l_list_line_id;
	If c_check_qpprc_atr%found THEN
 		X_Check_Return_Status_qp := FND_API.G_TRUE;
		OPEN c_check_asorec;
		FETCH  c_check_asorec INTO l_count;
		CLOSE c_check_asorec;
		IF l_count>0 THEN
			X_Check_Return_Status_aso := FND_API.G_TRUE;
		END IF;
	END If;
	CLOSE  c_check_qpprc_atr;
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add(' X_Check_Return_Status_qp '|| X_Check_Return_Status_qp, 1, 'Y');
   aso_debug_pub.add(' X_Check_Return_Status_aso '|| X_Check_Return_Status_aso, 1, 'Y');
 END IF;
END  Check_Pricing_Attributes;



End ASO_CHK_PRICING_ATTR_PVT;

/
