--------------------------------------------------------
--  DDL for Package Body FTE_FPA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_FPA_UTIL" AS
/* $Header: FTEFPUTB.pls 120.12 2006/05/16 22:22:37 schennal noship $ */



G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_FPA_UTIL';


PROCEDURE GET_PAYMENT_METHOD(p_init_msg_list IN  VARCHAR2 default FND_API.G_FALSE,
			     p_invoice_header_id  in NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2,
		 	     x_payment_method OUT NOCOPY VARCHAR2)
IS

	CURSOR C_GET_BILL_DETAILS(p_inv_head_id NUMBER)
	IS
	SELECT PV.PARTY_ID,PVS.PARTY_SITE_ID,
	       FH.SUPPLIER_SITE_ID,FH.ORG_ID,
	       NULL PAYMENT_METHOD_LOOKUP_CODE
	FROM   FTE_INVOICE_HEADERS FH,
	       PO_VENDORS PV,
	       PO_VENDOR_SITES_ALL PVS
	WHERE
	    FH.SUPPLIER_ID       = PV.VENDOR_ID
	AND PV.VENDOR_ID         = PVS.VENDOR_ID
	AND FH.SUPPLIER_SITE_ID  = PVS.VENDOR_SITE_ID
	AND FH.INVOICE_HEADER_ID = p_inv_head_id;


	l_organization_type  CONSTANT VARCHAR2(20) := 'OPERATING_UNIT';
	l_payment_function   CONSTANT VARCHAR2(20) := 'PAYABLES_DISB';
	l_default_pay_method CONSTANT VARCHAR2(100) := 'CHECK';

	l_Trxn_Attributes_rec    IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
	l_Default_Pmt_Attrs_rec  IBY_DISBURSEMENT_COMP_PUB.Default_Pmt_Attrs_Rec_Type;
	l_payment_method_rec     IBY_DISBURSEMENT_COMP_PUB.Payment_Method_Rec_Type;

	l_vendor_pay_method VARCHAR2(100);
	l_pay_method	VARCHAR2(100);


	l_return_status      VARCHAR2(1);
	l_msg_data           VARCHAR2(2000);
	l_msg_count          NUMBER;

	l_file_name  VARCHAR2(100);


	l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'GET_PAYMENT_METHOD';


BEGIN

      /*--- Test Code Begins -------------------------------------------------------------
      WSH_DEBUG_INTERFACE.g_debug := TRUE;
	WSH_DEBUG_SV.start_debugger
	    (x_file_name     =>  l_file_name,
	     x_return_status =>  l_return_status,
	     x_msg_count     =>  l_msg_count,
	     x_msg_data      =>  l_msg_data);
      --- Test Code Ends ---------------------------------------------------------------
      */



	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    WSH_DEBUG_SV.log(l_module_name,'p_invoice_header_id',p_invoice_header_id);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
	--
	--
	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;


	-- Start Of Code

	OPEN  C_GET_BILL_DETAILS(p_invoice_header_id);

	FETCH C_GET_BILL_DETAILS INTO
	   l_Trxn_Attributes_rec.Payee_Party_Id,
	   l_Trxn_Attributes_rec.Payee_Party_Site_Id,
	   l_Trxn_Attributes_rec.Supplier_Site_Id,
	   l_Trxn_Attributes_rec.Payer_Org_Id,
	   l_vendor_pay_method;

	CLOSE C_GET_BILL_DETAILS;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'l_Trxn_Attributes_rec.Payee_Party_Id',l_Trxn_Attributes_rec.Payee_Party_Id);
	    WSH_DEBUG_SV.log(l_module_name,'l_Trxn_Attributes_rec.Payee_Party_Site_Id',l_Trxn_Attributes_rec.Payee_Party_Site_Id);
	    WSH_DEBUG_SV.log(l_module_name,'l_Trxn_Attributes_rec.Supplier_Site_Id',l_Trxn_Attributes_rec.Supplier_Site_Id);
	    WSH_DEBUG_SV.log(l_module_name,'l_Trxn_Attributes_rec.Payer_Org_Id',l_Trxn_Attributes_rec.Payer_Org_Id);
	    WSH_DEBUG_SV.log(l_module_name,'l_vendor_pay_method',l_vendor_pay_method);
	END IF;


	l_Trxn_Attributes_rec.Payer_Org_Type   := l_organization_type;
	l_Trxn_Attributes_rec.payment_function := l_payment_function;

	IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes(
		    p_api_version             => 1.0,
		    p_init_msg_list           => FND_API.G_FALSE,
		    p_ignore_payee_pref       => NULL,
		    p_trxn_attributes_rec     => l_Trxn_Attributes_rec,
		    x_return_status           => l_return_status,
		    x_msg_count               => l_msg_count,
		    x_msg_data                => l_msg_data,
		    x_default_pmt_attrs_rec   => l_Default_Pmt_Attrs_rec);

	FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );



	l_payment_method_rec := l_Default_Pmt_Attrs_rec.Payment_Method;
        l_pay_method := l_payment_method_rec.Payment_Method_Code;
	x_payment_method := nvl(l_pay_method,nvl(l_vendor_pay_method,l_default_pay_method));

        IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'l_pay_method',l_pay_method);
	    WSH_DEBUG_SV.log(l_module_name,'l_vendor_pay_method',l_vendor_pay_method);
	    WSH_DEBUG_SV.log(l_module_name,'l_default_pay_method',l_default_pay_method);
	    WSH_DEBUG_SV.log(l_module_name,'x_payment_method',x_payment_method);
	END IF;


	-- End of Code

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

    EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );


		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;


END GET_PAYMENT_METHOD;




FUNCTION GET_FREIGHT_COST_TRUCK (p_trip_id             IN NUMBER,
			         p_delivery_detail_id  IN NUMBER,
			         p_inventory_item_id   IN NUMBER,
                                 p_delivery_leg_id     IN NUMBER,
				 p_bol                 IN VARCHAR2,
				 p_container_flag      IN VARCHAR2,
				 p_gross_weight        IN NUMBER,
				 p_weight_uom          IN VARCHAR2,
			         g_currency_code       IN VARCHAR2)

RETURN NUMBER
IS

     -- 1 Gets the Total BOL Approved Amount

	CURSOR C_APPROVED_AMOUNT(p_bol_no VARCHAR2)
	IS
        SELECT nvl(APPROVED_AMOUNT,0),
	       CURRENCY_CODE
	FROM   FTE_INVOICE_HEADERS
	WHERE  BOL = p_bol_no;

     -- 2 Gets the Total Rated Amount for the Trip

	CURSOR C_TOTAL_AMOUNT (p_trip NUMBER)
	IS
        SELECT
	       nvl(WFC.TOTAL_AMOUNT,0),
	       WFC.CURRENCY_CODE
	FROM   WSH_FREIGHT_COSTS WFC,
	       WSH_FREIGHT_COST_TYPES CT
	WHERE
	        WFC.FREIGHT_COST_TYPE_ID = CT.FREIGHT_COST_TYPE_ID
	   AND  WFC.LINE_TYPE_CODE =  'SUMMARY'
	   AND  CT.NAME =  'SUMMARY'
	   AND  WFC.TRIP_ID = p_trip;

     -- 3 Gets the Total Rate Amount At Delivery Leg Level...

	CURSOR C_DLEG_AMOUNT (p_trip NUMBER,p_dleg_id NUMBER)
	IS
	SELECT   nvl(WFC.TOTAL_AMOUNT,0),
		 WFC.CURRENCY_CODE
	FROM
		WSH_DELIVERY_LEGS WDL ,
		WSH_TRIP_STOPS WT,
		WSH_FREIGHT_COSTS  WFC
	WHERE
		   WT.STOP_ID = WDL.PICK_UP_STOP_ID
	       AND WFC.DELIVERY_LEG_ID =  WDL.DELIVERY_LEG_ID
	       AND WT.TRIP_ID = p_trip
	       AND WFC.DELIVERY_DETAIL_ID IS NULL
	       AND WFC.LINE_TYPE_CODE = 'SUMMARY'
	       AND WFC.DELIVERY_LEG_ID = p_dleg_id;

     -- 4 Gets the Gross Weight of Delivery Detail Including Containers..

	CURSOR C_GROSS_WEIGHT( p_detail_id NUMBER, g_wt_uom VARCHAR2)
	IS
	SELECT nvl(SUM(WSH_WV_UTILS.CONVERT_UOM(
			WEIGHT_UOM_CODE,
             		g_wt_uom,
			WDD.GROSS_WEIGHT,
       			WDD.INVENTORY_ITEM_ID)),0)
        FROM  WSH_DELIVERY_DETAILS WDD
	WHERE WDD.DELIVERY_DETAIL_ID
	   IN (
	        SELECT DELIVERY_DETAIL_ID
		FROM WSH_DELIVERY_ASSIGNMENTS
       	        START WITH DELIVERY_DETAIL_ID = p_detail_id
 	        CONNECT BY PRIOR PARENT_DELIVERY_DETAIL_ID= DELIVERY_DETAIL_ID
	       );


    -- 5 Gets the Top Level Parent Delivery Detail..

	CURSOR C_PARENT_DETAIL(p_detail_id NUMBER)
	IS
	SELECT DELIVERY_DETAIL_ID
	FROM
	    (SELECT
	          DELIVERY_DETAIL_ID,
		  LEVEL
		  FROM WSH_DELIVERY_ASSIGNMENTS
		  START WITH DELIVERY_DETAIL_ID = p_detail_id
                  CONNECT BY PRIOR PARENT_DELIVERY_DETAIL_ID = DELIVERY_DETAIL_ID ORDER BY LEVEL DESC
	     ) A
        WHERE ROWNUM = 1;

    -- 6 Gets the Detail Rate Amount
	CURSOR C_DETAIL_AMOUNT( p_detail_id NUMBER, p_dleg_id NUMBER,
	                        p_cont_flag VARCHAR2, p_container_detail_id NUMBER)
	IS
	SELECT
	      nvl(WFC.TOTAL_AMOUNT,0) ,
	      WFC.CURRENCY_CODE
	FROM
	      WSH_FREIGHT_COSTS  WFC
	WHERE
	      WFC.DELIVERY_LEG_ID = p_dleg_id
	  AND WFC.DELIVERY_DETAIL_ID = DECODE (p_cont_flag,'Y',p_container_detail_id,'N',p_detail_id)
	  AND WFC.LINE_TYPE_CODE = 'SUMMARY';


	l_approved_amount    NUMBER;
	l_currency_code      VARCHAR2(15);
	l_total_amount       NUMBER;
	l_dleg_header_amount NUMBER;
	l_dleg_approved_amount NUMBER;
	l_container_flag     VARCHAR2(1);
	l_gross_weight       NUMBER;
	l_container_delivery_detail NUMBER;
	l_detail_amount          NUMBER;
	l_detail_approved_amount NUMBER;
	l_result_amount          NUMBER;
	--

	l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'GET_FREIGHT_COST_TRUCK';




BEGIN
	   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

	   IF l_debug_on IS NULL  THEN
	       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	   END IF;


	   IF l_debug_on THEN
	       WSH_DEBUG_SV.push(l_module_name);
	   END IF;

           IF l_debug_on THEN

              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');
	      WSH_DEBUG_SV.log(l_module_name,' Printing Parameters Below... ');
              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');

	      WSH_DEBUG_SV.log(l_module_name,' p_trip_id  ',p_trip_id);
	      WSH_DEBUG_SV.log(l_module_name,' p_delivery_detail_id  ',p_delivery_detail_id);
      	      WSH_DEBUG_SV.log(l_module_name,' p_inventory_item_id  ',p_inventory_item_id);
      	      WSH_DEBUG_SV.log(l_module_name,' p_delivery_leg_id  ',p_delivery_leg_id);
	      WSH_DEBUG_SV.log(l_module_name,' p_bol ',p_bol);
	      WSH_DEBUG_SV.log(l_module_name,' p_container_flag  ',p_container_flag);
	      WSH_DEBUG_SV.log(l_module_name,' p_gross_weight  ',p_gross_weight);
	      WSH_DEBUG_SV.log(l_module_name,' p_weight_uom  ',p_weight_uom);
	      WSH_DEBUG_SV.log(l_module_name,' g_currency_code  ',g_currency_code);

           END IF;

        OPEN   C_APPROVED_AMOUNT (p_bol);
	FETCH  C_APPROVED_AMOUNT INTO l_approved_amount,l_currency_code;
	CLOSE  C_APPROVED_AMOUNT;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_APPROVED_AMOUNT  ');
             WSH_DEBUG_SV.log(l_module_name,' l_approved_amount  ',l_approved_amount);
	     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
         END IF;


        l_approved_amount :=GL_CURRENCY_API.convert_amount (
			     x_from_currency	 => l_currency_code,
			     x_to_currency       => g_currency_code,
			     x_conversion_date   => sysdate,
			     x_amount            => l_approved_amount);

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_APPROVED_AMOUNT == After Currency Conversion ');
             WSH_DEBUG_SV.log(l_module_name,' l_approved_amount  ',l_approved_amount);
	     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',g_currency_code);
         END IF;



	OPEN  C_TOTAL_AMOUNT (p_trip_id);
	FETCH C_TOTAL_AMOUNT INTO l_total_amount,l_currency_code;
	CLOSE C_TOTAL_AMOUNT;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_AMOUNT  ');
             WSH_DEBUG_SV.log(l_module_name,' l_total_amount  ',l_total_amount);
	     WSH_DEBUG_SV.log(l_module_name,' l_currency_code ',l_currency_code);
         END IF;


        l_total_amount := GL_CURRENCY_API.convert_amount (
				x_from_currency	  => l_currency_code,
				x_to_currency     => g_currency_code,
				x_conversion_date => sysdate,
				x_amount          => l_total_amount);

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_AMOUNT == After Currency Conversion ');
             WSH_DEBUG_SV.log(l_module_name,' l_total_amount  ',l_total_amount);
	     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',g_currency_code);
         END IF;



       OPEN  C_DLEG_AMOUNT (p_trip_id,p_delivery_leg_id);
       FETCH C_DLEG_AMOUNT INTO l_dleg_header_amount,l_currency_code;
       CLOSE C_DLEG_AMOUNT;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DLEG_AMOUNT  ');
             WSH_DEBUG_SV.log(l_module_name,' l_dleg_header_amount ',l_dleg_header_amount);
	     WSH_DEBUG_SV.log(l_module_name,' l_currency_code ',l_currency_code);
         END IF;


       l_dleg_header_amount := GL_CURRENCY_API.convert_amount (
				x_from_currency	  => l_currency_code,
				x_to_currency     => g_currency_code,
				x_conversion_date => sysdate,
				x_amount          => l_dleg_header_amount);

	 IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DLEG_AMOUNT  ');
	     WSH_DEBUG_SV.log(l_module_name,' l_dleg_header_amount  ',l_dleg_header_amount);
	     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
	 END IF;


	IF( l_total_amount = 0) THEN
	    l_dleg_approved_amount := 0;
	ELSE
	    l_dleg_approved_amount := nvl((l_dleg_header_amount * l_approved_amount / l_total_amount),0);
	END IF;


         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' After Pro-Ration to Delivery Leg Level  ');
             WSH_DEBUG_SV.log(l_module_name,' l_dleg_approved_amount  ',l_dleg_approved_amount);
         END IF;


      IF p_container_flag = 'Y' THEN

            OPEN  C_GROSS_WEIGHT(p_delivery_detail_id, p_weight_uom);
	    FETCH C_GROSS_WEIGHT into l_gross_weight;
	    CLOSE C_GROSS_WEIGHT;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_GROSS_WEIGHT  ');
             WSH_DEBUG_SV.log(l_module_name,' l_gross_weight ',l_gross_weight);
         END IF;

	    OPEN  C_PARENT_DETAIL(p_delivery_detail_id);
	    FETCH C_PARENT_DETAIL INTO l_container_delivery_detail;
	    CLOSE C_PARENT_DETAIL;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_PARENT_DETAIL  ');
             WSH_DEBUG_SV.log(l_module_name,' l_container_delivery_detail  ',l_container_delivery_detail);
         END IF;


	    IF p_delivery_detail_id <> l_container_delivery_detail  THEN
	        l_container_flag := 'Y';
	    ELSE
		l_container_flag := 'N';
  	    END IF;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' l_container_flag  ',l_container_flag);
         END IF;



      END IF;

      OPEN  C_DETAIL_AMOUNT(p_delivery_detail_id,p_delivery_leg_id,l_container_flag, l_container_delivery_detail);
      FETCH C_DETAIL_AMOUNT INTO l_detail_amount,l_currency_code;
      CLOSE C_DETAIL_AMOUNT;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_AMOUNT  ');
             WSH_DEBUG_SV.log(l_module_name,' l_detail_amount  ',l_detail_amount);
             WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
         END IF;

         l_detail_amount :=     GL_CURRENCY_API.convert_amount (
				x_from_currency	  => l_currency_code,
				x_to_currency     => g_currency_code,
				x_conversion_date => sysdate,
				x_amount          => l_detail_amount);

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_AMOUNT ==> After Conversion ');
             WSH_DEBUG_SV.log(l_module_name,' l_detail_amount  ',l_detail_amount);
             WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',g_currency_code);
         END IF;

	IF (l_dleg_header_amount = 0 ) THEN
	     l_detail_approved_amount := 0;
	ELSE
	     l_detail_approved_amount := NVL((l_detail_amount * l_dleg_approved_amount / l_dleg_header_amount),0);
	END IF;

      IF l_container_flag = 'Y' THEN
	IF l_gross_weight = 0 THEN
		l_detail_approved_amount := 0;
	ELSE
		l_detail_approved_amount :=NVL(( l_detail_approved_amount * p_gross_weight / l_gross_weight),0);
	END IF ;
      END IF;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' After Pro-Ration to Delivery Detail Level  ');
             WSH_DEBUG_SV.log(l_module_name,' l_detail_approved_amount  ',l_detail_approved_amount);
         END IF;

	   IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	   END IF;

      RETURN l_detail_approved_amount;


END GET_FREIGHT_COST_TRUCK;




FUNCTION GET_FREIGHT_COST_LTL (p_delivery_leg_id       IN NUMBER,
			       p_delivery_detail_id    IN NUMBER,
			       p_commodity_category_id IN NUMBER,
                               p_bol                   IN VARCHAR2,
			       g_currency_code         IN VARCHAR2,
			       p_invoice_header_id	IN NUMBER)


RETURN NUMBER
IS


-- Get the total rate amount on the freight class

     CURSOR C_TOTAL_SUMMARY_AMT
     IS
     SELECT
	  nvl( SUM(TOTAL_AMOUNT),0),
	  MAX(CURRENCY_CODE)
     FROM WSH_FREIGHT_COSTS
     WHERE
	     DELIVERY_LEG_ID = p_delivery_leg_id
	AND  LINE_TYPE_CODE = 'SUMMARY'
	AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE';


     CURSOR C_TOTAL_DISCOUNT_AMT
     IS
     SELECT
	  nvl( SUM(TOTAL_AMOUNT),0),
	  MAX(CURRENCY_CODE)
     FROM WSH_FREIGHT_COSTS
     WHERE
	     DELIVERY_LEG_ID = p_delivery_leg_id
	AND  LINE_TYPE_CODE = 'DISCOUNT'
	AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE';


     CURSOR C_TOTAL_SURCHARGE_AMT
     IS
     SELECT
	  nvl( SUM(TOTAL_AMOUNT),0),
	  MAX(CURRENCY_CODE)
     FROM WSH_FREIGHT_COSTS
     WHERE
	     DELIVERY_LEG_ID = p_delivery_leg_id
	AND  LINE_TYPE_CODE = 'CHARGE'
	AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE';

     CURSOR C_TOTAL_AMT
     IS
     SELECT
	  nvl( SUM(TOTAL_AMOUNT),0),
	  MAX(CURRENCY_CODE)
     FROM WSH_FREIGHT_COSTS
     WHERE
	     DELIVERY_LEG_ID = p_delivery_leg_id
	AND  LINE_TYPE_CODE = 'PRICE'
	AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE'
	AND  COMMODITY_CATEGORY_ID = p_commodity_category_id;

-- Get the Total Approved Amount on the BOL for the Freight Class

     CURSOR C_LINE_APPROVED_AMT
     IS
     SELECT
	    NVL( SUM(FL.APPROVED_AMOUNT),0 ),
            MAX(FH.CURRENCY_CODE)
     FROM   FTE_INVOICE_HEADERS FH,
            FTE_INVOICE_LINES FL,
	    MTL_CATEGORIES_KFV C,
	    MTL_CATEGORY_SETS S
     WHERE  FH.INVOICE_HEADER_ID  = FL.INVOICE_HEADER_ID
         AND  FH.BOL              = p_bol
	 AND  FL.FREIGHT_CLASS    = C.CONCATENATED_SEGMENTS
	 AND  FH.BILL_STATUS      <> 'OBSOLETE'
	 AND  S.STRUCTURE_ID      = C.STRUCTURE_ID
	 AND  S.CATEGORY_SET_NAME = 'WSH_COMMODITY_CODE'
	 AND  C.ENABLED_FLAG      = 'Y'
	 AND  C.CATEGORY_ID       = p_commodity_category_id
	 AND FL.INVOICE_LINE_TYPE = 'LINE';

	-- Approved discount
     CURSOR C_TOTAL_APPROVED_DISCOUNT
     IS
     SELECT
	    NVL( SUM(FL.APPROVED_AMOUNT),0 ),
            MAX(FH.CURRENCY_CODE)
     FROM   FTE_INVOICE_HEADERS FH,
            FTE_INVOICE_LINES FL
     WHERE  FH.INVOICE_HEADER_ID  = FL.INVOICE_HEADER_ID
         AND  FH.BOL              = p_bol
	 AND  FH.BILL_STATUS      <> 'OBSOLETE'
	 AND FL.INVOICE_LINE_TYPE = 'DISCOUNT';

	-- Approved charge
     CURSOR C_TOTAL_APPROVED_SURCHARGE
     IS
     SELECT
	    NVL( SUM(FL.APPROVED_AMOUNT),0 ),
            MAX(FH.CURRENCY_CODE)
     FROM   FTE_INVOICE_HEADERS FH,
            FTE_INVOICE_LINES FL
     WHERE  FH.INVOICE_HEADER_ID  = FL.INVOICE_HEADER_ID
         AND  FH.BOL              = p_bol
	 AND  FH.BILL_STATUS      <> 'OBSOLETE'
	 AND FL.INVOICE_LINE_TYPE = 'SURCHARGE';


     CURSOR C_LINE_APPROVED_DISCOUNT(p_dleg_id NUMBER,p_bol_no VARCHAR2,p_commodity_id NUMBER)
     IS
     SELECT
     (SELECT SUM(TOTAL_AMOUNT) FROM WSH_FREIGHT_COSTS
      WHERE  DELIVERY_LEG_ID = p_dleg_id
        AND  LINE_TYPE_CODE = 'DISCOUNT'
        AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE'
	AND  COMMODITY_CATEGORY_ID = p_commodity_id
      )	/
      (SELECT SUM(TOTAL_AMOUNT)   FROM WSH_FREIGHT_COSTS
       WHERE DELIVERY_LEG_ID = p_dleg_id
	AND  LINE_TYPE_CODE = 'DISCOUNT'
	AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE'
      ) * FL.APPROVED_AMOUNT FROM FTE_INVOICE_LINES FL ,FTE_INVOICE_HEADERS FH
      WHERE     FL.INVOICE_LINE_TYPE  ='DISCOUNT'
            AND FH.INVOICE_HEADER_ID = FL.INVOICE_HEADER_ID
	    AND FH.BOL = p_bol_no;


     CURSOR C_LINE_APPROVED_SURCHARGE(p_dleg_id NUMBER,p_bol_no VARCHAR2,p_commodity_id NUMBER)
     IS
     SELECT
     (SELECT SUM(TOTAL_AMOUNT) FROM WSH_FREIGHT_COSTS
      WHERE  DELIVERY_LEG_ID = p_dleg_id
        AND  LINE_TYPE_CODE = 'CHARGE'
        AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE'
	AND  COMMODITY_CATEGORY_ID = p_commodity_id
      )	/
      (SELECT SUM(TOTAL_AMOUNT)   FROM WSH_FREIGHT_COSTS
       WHERE DELIVERY_LEG_ID = p_dleg_id
	AND  LINE_TYPE_CODE = 'CHARGE'
	AND  CHARGE_SOURCE_CODE= 'PRICING_ENGINE'
      ) * FL.APPROVED_AMOUNT FROM FTE_INVOICE_LINES FL ,FTE_INVOICE_HEADERS FH
      WHERE     FL.INVOICE_LINE_TYPE  ='SURCHARGE'
            AND FH.INVOICE_HEADER_ID = FL.INVOICE_HEADER_ID
	    AND FH.BOL = p_bol_no;


-- Get the Detail Amount

        CURSOR C_DETAIL_AMOUNT
	IS
	SELECT  nvl(total_amount,0),
	        currency_code
        FROM    wsh_freight_costs
        WHERE   DELIVERY_LEG_ID      = p_delivery_leg_id
           AND DELIVERY_DETAIL_ID    = p_delivery_detail_id
           AND LINE_TYPE_CODE        = 'PRICE'
	   AND CHARGE_SOURCE_CODE    = 'PRICING_ENGINE'
	   AND COMMODITY_CATEGORY_ID = p_commodity_category_id;

	-- Detail discount amount

        CURSOR C_DETAIL_DISCOUNT_AMOUNT
	IS
	SELECT  nvl(total_amount,0),
	        currency_code
        FROM    wsh_freight_costs
        WHERE   DELIVERY_LEG_ID      = p_delivery_leg_id
           AND DELIVERY_DETAIL_ID    = p_delivery_detail_id
           AND LINE_TYPE_CODE        = 'DISCOUNT'
	   AND CHARGE_SOURCE_CODE    = 'PRICING_ENGINE'
	   AND COMMODITY_CATEGORY_ID = p_commodity_category_id;


        CURSOR C_DETAIL_SURCHARGE_AMOUNT
	IS
	SELECT  nvl(total_amount,0),
	        currency_code
        FROM    wsh_freight_costs
        WHERE   DELIVERY_LEG_ID      = p_delivery_leg_id
           AND DELIVERY_DETAIL_ID    = p_delivery_detail_id
           AND LINE_TYPE_CODE        = 'CHARGE'
	   AND CHARGE_SOURCE_CODE    = 'PRICING_ENGINE'
	   AND COMMODITY_CATEGORY_ID = p_commodity_category_id;


-- Get line level audit value

	CURSOR C_GET_LINE_LEVEL_AUDIT_VALUE
	IS
	SELECT nvl(freight_audit_line_level,'N'),FTE_INVOICE_HEADERS.APPROVED_AMOUNT
	FROM WSH_CARRIERS, FTE_INVOICE_HEADERS
	WHERE WSH_CARRIERS.CARRIER_ID =  FTE_INVOICE_HEADERS.CARRIER_ID
	AND FTE_INVOICE_HEADERS.INVOICE_HEADER_ID = p_invoice_header_id;



      l_summary_amount          NUMBER;
      l_currency_code           VARCHAR2(15);
      l_line_approved_amount    NUMBER;
      l_line_approved_discount  NUMBER;
      l_line_approved_surcharge NUMBER;
      l_detail_approved_amount  NUMBER;
      l_total_amount            NUMBER;


      l_total_dleg_approved_amount		NUMBER;
      l_total_dleg_approved_discount		NUMBER;
      l_total_dleg_approved_charge		NUMBER;
      l_total_commd_approved_amount		NUMBER;

      l_line_audit_level	VARCHAR2(1);

      l_cal_dleg_amount       	NUMBER;
      l_cal_detail_amount	NUMBER;

      l_cal_dleg_discount	NUMBER;
      l_cal_detail_discount	NUMBER;

      l_cal_dleg_charge		NUMBER;
      l_cal_detail_charge	NUMBER;

      l_cal_commodity_amount	NUMBER;

      l_prorated_detail_discount	NUMBER;
      l_prorated_detail_charge		NUMBER;


	l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'GET_FREIGHT_COST_LTL';


BEGIN

	   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

	   IF l_debug_on IS NULL  THEN
	       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	   END IF;



	OPEN  C_GET_LINE_LEVEL_AUDIT_VALUE;
	FETCH C_GET_LINE_LEVEL_AUDIT_VALUE INTO l_line_audit_level,l_total_dleg_approved_amount;
	CLOSE C_GET_LINE_LEVEL_AUDIT_VALUE;

 	   l_detail_approved_amount :=  0;

	   IF l_debug_on THEN
	       WSH_DEBUG_SV.push(l_module_name);
	   END IF;

           IF l_debug_on THEN

              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');
	      WSH_DEBUG_SV.log(l_module_name,' Printing Parameters Below... ');
              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');
	      WSH_DEBUG_SV.log(l_module_name,' p_delivery_leg_id ',p_delivery_leg_id);
	      WSH_DEBUG_SV.log(l_module_name,' p_delivery_detail_id ',p_delivery_detail_id);
      	      WSH_DEBUG_SV.log(l_module_name,' p_commodity_category_id ',p_commodity_category_id);
	      WSH_DEBUG_SV.log(l_module_name,' p_bol ',p_bol);
	      WSH_DEBUG_SV.log(l_module_name,' g_currency_code ',g_currency_code);
	      WSH_DEBUG_SV.log(l_module_name,' l_line_audit_level ',l_line_audit_level);

           END IF;


	IF (l_line_audit_level = 'N')
	THEN
	--{
		-- There is not approved amount at line level so we have to prorate it
		-- based on the ratio of rated delivery detail amount / total summary amount
		-- to the total approved amount. Because both total summary and
		-- approved amount consists of discount and surcharge
		OPEN  C_TOTAL_SUMMARY_AMT;
		FETCH C_TOTAL_SUMMARY_AMT INTO l_cal_dleg_amount,l_currency_code;
		CLOSE C_TOTAL_SUMMARY_AMT;

		-- Convert currency
		l_cal_dleg_amount :=  GL_CURRENCY_API.convert_amount (
					x_from_currency	  => l_currency_code,
					x_to_currency     => g_currency_code,
					x_conversion_date => sysdate,
					x_amount          => l_cal_dleg_amount);

	        -- Get the Detail Amount
		OPEN  C_DETAIL_AMOUNT;
		FETCH C_DETAIL_AMOUNT INTO l_cal_detail_amount,l_currency_code;
		CLOSE C_DETAIL_AMOUNT;

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_AMOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_detail_amount  ',l_cal_detail_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		 IF (l_cal_detail_amount <> 0)
		 THEN

			-- Convert delivery detail amount
			l_cal_detail_amount :=  GL_CURRENCY_API.convert_amount (
						x_from_currency	  => l_currency_code,
						x_to_currency     => g_currency_code,
						x_conversion_date => sysdate,
						x_amount          => l_cal_detail_amount);
		 END IF;

		 IF (l_total_dleg_approved_amount <> 0)
		 THEN

			-- Convert invoice amount
			l_total_dleg_approved_amount :=  GL_CURRENCY_API.convert_amount (
						x_from_currency	  => l_currency_code,
						x_to_currency     => g_currency_code,
						x_conversion_date => sysdate,
						x_amount          => l_total_dleg_approved_amount);
		 END IF;

		IF (l_cal_dleg_amount <> 0)
		THEN
			l_detail_approved_amount := nvl(((l_total_dleg_approved_amount * l_cal_detail_amount) / l_cal_dleg_amount),0);
		END IF;

	--}
	ELSE -- Line level audit is Y
	--{
		-- We have to prorate delivery detail amount based on the
		-- amount that is approved at commodity level and
		-- also include discount and surchage prorate

		-- Get the total rate amount on the freight class
	--{ Initial detail calculation

		OPEN  C_TOTAL_AMT;
		FETCH C_TOTAL_AMT INTO l_cal_commodity_amount,l_currency_code;
		CLOSE C_TOTAL_AMT;

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_commodity_amount  ',l_cal_commodity_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;


		l_cal_commodity_amount :=    GL_CURRENCY_API.convert_amount (
					x_from_currency	=> l_currency_code,
					x_to_currency => g_currency_code,
					x_conversion_date => sysdate,
					x_amount => l_cal_commodity_amount);

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' After Conversion ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_commodity_amount  ',l_cal_commodity_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',g_currency_code);
		 END IF;



	     -- Get the Detail Amount
		OPEN  C_DETAIL_AMOUNT;
		FETCH C_DETAIL_AMOUNT INTO l_cal_detail_amount,l_currency_code;
		CLOSE C_DETAIL_AMOUNT;

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_AMOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_detail_amount  ',l_cal_detail_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;


		l_cal_detail_amount :=  GL_CURRENCY_API.convert_amount (
					x_from_currency	  => l_currency_code,
					x_to_currency     => g_currency_code,
					x_conversion_date => sysdate,
					x_amount          => l_cal_detail_amount);

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_AMOUNT ==> After Conversion ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_detail_amount ',l_cal_detail_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code ',g_currency_code);
		 END IF;




		-- Get the Total Approved Amount on the BOL for the Freight Class

	       -- Line Amount (Base Rate )
		OPEN  C_LINE_APPROVED_AMT;
		FETCH C_LINE_APPROVED_AMT INTO l_total_commd_approved_amount,l_currency_code;
		CLOSE C_LINE_APPROVED_AMT;

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_LINE_APPROVED_AMT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_total_commd_approved_amount  ',l_total_commd_approved_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;


		l_total_commd_approved_amount := GL_CURRENCY_API.convert_amount (
					x_from_currency	  => l_currency_code,
					x_to_currency     => g_currency_code,
					x_conversion_date => sysdate,
					x_amount          => l_total_commd_approved_amount);

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_APPROVED_AMT  ==> After Conversion ');
		     WSH_DEBUG_SV.log(l_module_name,' l_total_commd_approved_amount  ',l_total_commd_approved_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code ',g_currency_code);
		 END IF;

		 -- Initial Calculation without discount
		 If (l_cal_commodity_amount <> 0)
		 THEN
 		  l_detail_approved_amount := nvl(((l_total_commd_approved_amount * l_cal_detail_amount) / l_cal_commodity_amount),0);
		 END IF;
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'l_detail_approved_amount before discount / surcharge ' , l_detail_approved_amount);
		 END IF;


	--} Initial detail calculation
		 -- Prorating Discount
	--{ Discount Calculation

	        -- Get detail discount
		OPEN  C_DETAIL_DISCOUNT_AMOUNT;
		FETCH C_DETAIL_DISCOUNT_AMOUNT INTO l_cal_detail_discount,l_currency_code;
		CLOSE C_DETAIL_DISCOUNT_AMOUNT;

		l_cal_detail_discount := nvl(l_cal_detail_discount,0);

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_DISCOUNT_AMOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_detail_discount  ',l_cal_detail_discount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;


		l_cal_detail_discount := GL_CURRENCY_API.convert_amount (
					x_from_currency	  => l_currency_code,
					x_to_currency     => g_currency_code,
					x_conversion_date => sysdate,
					x_amount          => l_cal_detail_discount);

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_DISCOUNT_AMOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_detail_discount  ',l_cal_detail_discount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;


	        -- Get calcualted summary  discount
		OPEN  C_TOTAL_DISCOUNT_AMT;
		FETCH C_TOTAL_DISCOUNT_AMT INTO l_cal_dleg_discount,l_currency_code;
		CLOSE C_TOTAL_DISCOUNT_AMT;

		l_cal_dleg_discount := nvl(l_cal_dleg_discount,0);

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_DISCOUNT_AMT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_dleg_discount  ',l_cal_dleg_discount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		IF (l_cal_dleg_discount <> 0)
		THEN

			l_cal_dleg_discount := GL_CURRENCY_API.convert_amount (
						x_from_currency	  => l_currency_code,
						x_to_currency     => g_currency_code,
						x_conversion_date => sysdate,
						x_amount          => l_cal_dleg_discount);
		END IF;


		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_DISCOUNT_AMT After conversion  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_dleg_discount  ',l_cal_dleg_discount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

	        -- Get approved discount
		OPEN  C_TOTAL_APPROVED_DISCOUNT;
		FETCH C_TOTAL_APPROVED_DISCOUNT INTO l_total_dleg_approved_discount,l_currency_code ;
		CLOSE C_TOTAL_APPROVED_DISCOUNT;


		l_total_dleg_approved_discount := nvl(l_total_dleg_approved_discount,0);


		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_APPROVED_DISCOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_total_dleg_approved_discount  ',l_total_dleg_approved_discount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		IF (l_total_dleg_approved_discount <> 0)
		THEN

			l_total_dleg_approved_discount := GL_CURRENCY_API.convert_amount (
						x_from_currency	  => l_currency_code,
						x_to_currency     => g_currency_code,
						x_conversion_date => sysdate,
						x_amount          => l_total_dleg_approved_discount);
		 END IF;


		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_APPROVED_DISCOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_total_dleg_approved_discount  ',l_total_dleg_approved_discount);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		 IF (l_cal_dleg_discount <> 0)
		 THEN
		 -- Prorated Discount calculation
			 l_prorated_detail_discount := nvl(((l_total_dleg_approved_discount * l_cal_detail_discount) / l_cal_dleg_discount),0);
		 END IF;
	--} -- Discount Calculation

	--{ Surcharge Calculation

	        -- Get detail discount
		OPEN  C_DETAIL_SURCHARGE_AMOUNT;
		FETCH C_DETAIL_SURCHARGE_AMOUNT INTO l_cal_detail_charge,l_currency_code;
		CLOSE C_DETAIL_SURCHARGE_AMOUNT;


		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_SURCHARGE_AMOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_detail_charge  ',l_cal_detail_charge);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		l_cal_detail_charge := nvl(l_cal_detail_charge,0);

		IF (l_cal_detail_charge <> 0)
		THEN

			l_cal_detail_charge := GL_CURRENCY_API.convert_amount (
						x_from_currency	  => l_currency_code,
						x_to_currency     => g_currency_code,
						x_conversion_date => sysdate,
						x_amount          => l_cal_detail_charge);
		END IF;

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_SURCHARGE_AMOUNT After Conversion ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_detail_discount  ',l_cal_detail_charge);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;


	        -- Get calcualted summary charge
		OPEN  C_TOTAL_SURCHARGE_AMT;
		FETCH C_TOTAL_SURCHARGE_AMT INTO l_cal_dleg_charge,l_currency_code ;
		CLOSE C_TOTAL_SURCHARGE_AMT;

		l_cal_dleg_charge := nvl(l_cal_dleg_charge,0);


		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_SURCHARGE_AMOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_dleg_charge  ',l_cal_dleg_charge);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		IF (l_cal_dleg_charge <> 0)
		THEN

			l_cal_dleg_charge := GL_CURRENCY_API.convert_amount (
						x_from_currency	  => l_currency_code,
						x_to_currency     => g_currency_code,
						x_conversion_date => sysdate,
						x_amount          => l_cal_dleg_charge);

		END IF;

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_DETAIL_SURCHARGE_AMOUNT  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_cal_dleg_charge  ',l_cal_dleg_charge);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

	        -- Get approved discount
		OPEN  C_TOTAL_APPROVED_SURCHARGE;
		FETCH C_TOTAL_APPROVED_SURCHARGE INTO l_total_dleg_approved_charge,l_currency_code ;
		CLOSE C_TOTAL_APPROVED_SURCHARGE;

		l_total_dleg_approved_charge := nvl(l_total_dleg_approved_charge,0);

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_APPROVED_SURCHARGE  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_total_dleg_approved_charge  ',l_total_dleg_approved_charge);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		 IF (l_total_dleg_approved_charge <> 0)
		 THEN

			l_total_dleg_approved_charge := GL_CURRENCY_API.convert_amount (
						x_from_currency	  => l_currency_code,
						x_to_currency     => g_currency_code,
						x_conversion_date => sysdate,
						x_amount          => l_total_dleg_approved_charge);
		 END IF;
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' CURSOR C_TOTAL_APPROVED_SURCHARGE  ');
		     WSH_DEBUG_SV.log(l_module_name,' l_total_dleg_approved_charge  ',l_total_dleg_approved_charge);
		     WSH_DEBUG_SV.log(l_module_name,' l_currency_code  ',l_currency_code);
		 END IF;

		 IF (l_cal_dleg_charge <> 0)
		 THEN
		 -- Prorated Discount calculation
			 l_prorated_detail_charge := nvl(((l_total_dleg_approved_charge * l_cal_detail_charge) / l_cal_dleg_charge),0);

		 END IF;

	--} -- Surcharge Calculation
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' Initial l_detail_approved_amount ',l_detail_approved_amount);
		     WSH_DEBUG_SV.log(l_module_name,' l_prorated_detail_discount  ',l_prorated_detail_discount);
		     WSH_DEBUG_SV.log(l_module_name,' l_prorated_detail_charge ',l_prorated_detail_charge);
		 END IF;

		l_detail_approved_amount := nvl(l_detail_approved_amount,0) - nvl(l_prorated_detail_discount,0) +
						nvl(l_prorated_detail_charge,0);

	--}
	END IF;




	IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' After Pro-Ration at Delivery Detail Level  ');
	     WSH_DEBUG_SV.log(l_module_name,' l_detail_approved_amount ',l_detail_approved_amount);
             WSH_DEBUG_SV.log(l_module_name,' l_currency_code ',g_currency_code);
        END IF;

	   IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	   END IF;


      RETURN l_detail_approved_amount;


END GET_FREIGHT_COST_LTL;


  PROCEDURE CALCULATE_FREIGHT_FOR_LTL (p_bol                   IN VARCHAR2,
	 			       p_invoice_header_id     IN NUMBER,
	 			       x_return_status         OUT NOCOPY VARCHAR2,
				       x_msg_data              OUT NOCOPY VARCHAR2,
				       x_msg_count	       OUT NOCOPY NUMBER)
  IS

  CURSOR C_SOURCE_LINES ( p_bol_no VARCHAR2 )
  IS
  SELECT DISTINCT WDD.SOURCE_LINE_ID,
  		  WDD.CURRENCY_CODE,
		  WDD.WEIGHT_UOM_CODE,
		  WDD.RCV_SHIPMENT_LINE_ID
  FROM
	WSH_DELIVERY_DETAILS WDD,
	WSH_DELIVERY_ASSIGNMENTS WDA,
	WSH_DELIVERY_LEGS WDL,
	WSH_DOCUMENT_INSTANCES WDI
  WHERE
	    WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
	AND (WDA.DELIVERY_ID        = WDL.DELIVERY_ID OR WDA.PARENT_DELIVERY_ID = WDL.DELIVERY_ID)
	AND WDD.LINE_DIRECTION     = 'I'
	AND WDI.ENTITY_ID         =  WDL.DELIVERY_LEG_ID
	AND WDI.ENTITY_NAME        = 'WSH_DELIVERY_LEGS'
	AND WDI.DOCUMENT_TYPE      = 'BOL'
	AND WDI.SEQUENCE_NUMBER    = p_bol_no;

  CURSOR C_SOURCE_LINE_BOLS ( p_source_line_id NUMBER,p_bol VARCHAR2)
   IS
      SELECT SUM(A.bol_flag) FROM (
	    SELECT distinct wdl.delivery_leg_id,
	       decode( (select distinct WDI.sequence_number from wsh_document_instances WDI,FTE_INVOICE_HEADERS FH
			where
				 WDI.ENTITY_ID    = DECODE(WT.MODE_OF_TRANSPORT,'LTL',WDL.DELIVERY_LEG_ID,'TRUCK',WT.TRIP_ID)
			     AND WDI.ENTITY_NAME  = DECODE(WT.MODE_OF_TRANSPORT,'LTL','WSH_DELIVERY_LEGS','TRUCK','WSH_TRIPS')
			     AND WDI.SEQUENCE_NUMBER = FH.BOL
			     AND FH.BILL_STATUS <> 'OBSOLETE'
			     AND FH.BILL_STATUS = decode(FH.BOL,p_bol,FH.BILL_STATUS,'APPROVED')
			),NULL,1,0)   bol_flag
	   FROM
		 WSH_DELIVERY_DETAILS WDD,
		  WSH_DELIVERY_ASSIGNMENTS WDA,
		  WSH_DELIVERY_LEGS WDL,
		  WSH_TRIP_STOPS WTS,
		  WSH_TRIPS WT
	  WHERE
	      WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
	  AND (WDA.DELIVERY_ID       = WDL.DELIVERY_ID  OR WDA.PARENT_DELIVERY_ID = WDL.DELIVERY_ID)
	  AND WDL.PARENT_DELIVERY_LEG_ID IS NULL
	  AND WDL.PICK_UP_STOP_ID    = WTS.STOP_ID
	  AND WT.TRIP_ID             = WTS.TRIP_ID
	  AND WDD.LINE_DIRECTION     = 'I'
	  AND WDD.SOURCE_LINE_ID     =  p_source_line_id
	 ) A;



        CURSOR C_DETAIL_INFO (p_source_line_id NUMBER)
        IS
        SELECT
           DISTINCT WDL.DELIVERY_LEG_ID,
	           WDD.DELIVERY_DETAIL_ID,
		   WDD.INVENTORY_ITEM_ID,
                   WT.MODE_OF_TRANSPORT,
		   WT.TRIP_ID,
		   MIC.CATEGORY_ID AS COMMODITY_CATEGORY_ID,
		   DECODE(WDA.PARENT_DELIVERY_DETAIL_ID,NULL,'Y','N') AS CONTAINER_FLAG,
                   WDD.GROSS_WEIGHT,
		   WDD.WEIGHT_UOM_CODE,
		   WDD.CURRENCY_CODE,
		   (SELECT WDI.SEQUENCE_NUMBER FROM WSH_DOCUMENT_INSTANCES WDI
	  	    WHERE WDI.ENTITY_ID    = DECODE(WT.MODE_OF_TRANSPORT,'LTL',NVL(WDL.PARENT_DELIVERY_LEG_ID,WDL.DELIVERY_LEG_ID),'TRUCK',WT.TRIP_ID)
	              AND WDI.ENTITY_NAME  = DECODE(WT.MODE_OF_TRANSPORT,'LTL','WSH_DELIVERY_LEGS','TRUCK','WSH_TRIPS')
		   ) SEQUENCE_NUMBER
       FROM
	 WSH_DELIVERY_DETAILS WDD,
	 WSH_DELIVERY_ASSIGNMENTS WDA,
	 WSH_DELIVERY_LEGS WDL,
	 WSH_TRIP_STOPS WTS,
	 WSH_TRIPS WT,
	 MTL_ITEM_CATEGORIES MIC,
	 MTL_CATEGORIES_KFV C,
	 MTL_CATEGORY_SETS S
        WHERE
	       S.STRUCTURE_ID = C.STRUCTURE_ID
	  AND  S.CATEGORY_SET_NAME ='WSH_COMMODITY_CODE'
	  AND  C.ENABLED_FLAG ='Y'
	  AND  C.CATEGORY_ID        = MIC.CATEGORY_ID
          AND  MIC.INVENTORY_ITEM_ID = WDD.INVENTORY_ITEM_ID
          AND  MIC.ORGANIZATION_ID   = WDD.ORG_ID
          AND  WDD.DELIVERY_DETAIL_ID  = WDA.DELIVERY_DETAIL_ID
	  AND WDA.DELIVERY_ID        = WDL.DELIVERY_ID
	  AND WDA.DELIVERY_ID        = WDL.DELIVERY_ID
	  AND WDL.PICK_UP_STOP_ID     = WTS.STOP_ID
	  AND WT.TRIP_ID              = WTS.TRIP_ID
	  AND WDD.LINE_DIRECTION      = 'I'
	  AND WDD.SOURCE_LINE_ID      = p_source_line_id;

        CURSOR C_VENDOR_INFO(p_source_line_id NUMBER) IS
	SELECT VENDOR_ID,SHIP_FROM_SITE_ID
	FROM WSH_DELIVERY_DETAILS
	WHERE SOURCE_LINE_ID = p_source_line_id
	AND ROWNUM <= 1;



    l_all_approved_line_cnt NUMBER DEFAULT  0;
    l_approved_amount NUMBER DEFAULT  0;
    l_wFItemKey NUMBER;
    l_parameter_list     wf_parameter_list_t;
    l_current_amount NUMBER;
    i NUMBER;
    j NUMBER;

    l_return_status      VARCHAR2(1);
    l_msg_data           VARCHAR2(2000);
    l_msg_count          NUMBER;
    l_vendor_id          NUMBER;
    l_vendor_site_id     NUMBER;

    l_po_rcv_charges  po_rcv_charges%rowtype;

    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_FREIGHT_FOR_LTL';

	l_bill_type VARCHAR2(10);
	l_inc_parent_bol VARCHAR2(1000);

	l_bill_status VARCHAR2(30);

  BEGIN

	   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

	   IF l_debug_on IS NULL  THEN
	       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	   END IF;

	   --  Initialize API return status to success
	   x_return_status      := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	   x_msg_count		:= 0;
	   x_msg_data		:= '';


	   IF l_debug_on THEN
	       WSH_DEBUG_SV.push(l_module_name);
	   END IF;

           IF l_debug_on THEN

              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');
	      WSH_DEBUG_SV.log(l_module_name,' Printing Parameters Below... ');
              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');
	      WSH_DEBUG_SV.log(l_module_name,' p_bol ',p_bol);
	      WSH_DEBUG_SV.log(l_module_name,' p_invoice_header_id ',p_invoice_header_id);

           END IF;

	SELECT BILL_STATUS INTO l_bill_status
	FROM FTE_INVOICE_HEADERS
	WHERE invoice_header_id = p_invoice_header_id;


	   IF l_debug_on THEN

	      WSH_DEBUG_SV.log(l_module_name,' Invoice Bill number ', l_bill_status);
	  END IF;

	IF (l_bill_status <> 'APPROVED')
	THEN
	   IF l_debug_on THEN

	      WSH_DEBUG_SV.log(l_module_name,' Bill approved returning back ');
	  END IF;
		RETURN;
	END IF;


        i := 0;

	FOR src_line in C_SOURCE_LINES(p_bol) LOOP

	    i := i + 1;

	     IF l_debug_on THEN
		  WSH_DEBUG_SV.log(l_module_name,' LOOP CURSOR C_SOURCE_LINES ==> Iteration ',to_char(i));
--		  WSH_DEBUG_SV.log(l_module_name,' src_line.SOURCE_LINE_ID ',src_line.SOURCE_LINE_ID);
		  WSH_DEBUG_SV.log(l_module_name,' src_line.RCV_SHIPMENT_LINE_ID ',src_line.RCV_SHIPMENT_LINE_ID);
	     END IF;


           OPEN  C_SOURCE_LINE_BOLS(src_line.SOURCE_LINE_ID,p_bol);
           FETCH C_SOURCE_LINE_BOLS INTO l_all_approved_line_cnt;
	   CLOSE C_SOURCE_LINE_BOLS;

	   IF l_debug_on THEN
	        WSH_DEBUG_SV.log(l_module_name,' CURSOR ss C_SOURCE_LINE_BOLS ==> Iteration ',i);
		WSH_DEBUG_SV.log(l_module_name,' l_all_approved_line_cnt ',l_all_approved_line_cnt);
	   END IF;


          IF l_all_approved_line_cnt = 0 THEN

                l_approved_amount := 0;
		j := 0;

	      FOR src_det in C_DETAIL_INFO(src_line.SOURCE_LINE_ID) LOOP

	         j := j + 1;
		 l_current_amount := 0;

		 IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_module_name,' LOOP CURSOR C_DETAIL_INFO ==> Iteration ',j);
		      WSH_DEBUG_SV.log(l_module_name,' src_det.MODE_OF_TRANSPORT ',src_det.MODE_OF_TRANSPORT);
		 END IF;


	         IF    src_det.MODE_OF_TRANSPORT = 'LTL' THEN

			SELECT BILL_TYPE, BOL INTO l_bill_type, l_inc_parent_bol
			FROM FTE_INVOICE_HEADERS
			WHERE INVOICE_HEADER_ID = p_invoice_header_id;


			 IF l_debug_on THEN
			      WSH_DEBUG_SV.log(l_module_name,' BILL type ',l_bill_type);
			      WSH_DEBUG_SV.log(l_module_name,' l_inc_parent_bol ',l_inc_parent_bol);
			      WSH_DEBUG_SV.log(l_module_name,' src_det.SEQUENCE_NUMBER ',src_det.SEQUENCE_NUMBER);
			 END IF;
                        -- Commented by Suresh to verify the fix Bug#4996996
			--IF (l_bill_type = 'INC' AND
		        --   l_inc_parent_bol = src_det.SEQUENCE_NUMBER)
			--THEN

	                       l_current_amount :=  GET_FREIGHT_COST_LTL
		                                               (p_delivery_leg_id       => src_det.DELIVERY_LEG_ID,
							        p_delivery_detail_id    => src_det.DELIVERY_DETAIL_ID  ,
							        p_commodity_category_id => src_det.COMMODITY_CATEGORY_ID,
							        p_bol                   => src_det.SEQUENCE_NUMBER,
							        g_currency_code         => src_det.CURRENCY_CODE,
							        p_invoice_header_id	=> p_invoice_header_id);


				IF l_debug_on THEN
				   WSH_DEBUG_SV.log(l_module_name,' LTL approved_amount For Delivery Detail ',src_det.DELIVERY_DETAIL_ID);
				   WSH_DEBUG_SV.log(l_module_name,' l_current_amount ',l_current_amount);
				END IF;
			--END IF;

		 ELSIF src_det.MODE_OF_TRANSPORT = 'TRUCK' THEN

                     l_current_amount  :=   GET_FREIGHT_COST_TRUCK
							     (p_trip_id            =>  src_det.TRIP_ID  ,
						              p_delivery_detail_id =>  src_det.DELIVERY_DETAIL_ID,
							      p_inventory_item_id  =>  src_det.INVENTORY_ITEM_ID,
							      p_delivery_leg_id    =>  src_det.DELIVERY_LEG_ID ,
							      p_bol                =>  src_det.SEQUENCE_NUMBER,
							      p_container_flag     =>  src_det.CONTAINER_FLAG,
							      p_gross_weight       =>  src_det.GROSS_WEIGHT,
							      p_weight_uom         =>  src_det.WEIGHT_UOM_CODE,
							      g_currency_code      =>  src_det.CURRENCY_CODE);

			IF l_debug_on THEN
			   WSH_DEBUG_SV.log(l_module_name,' TRUCK approved_amount For Delivery Detail ',src_det.DELIVERY_DETAIL_ID);
			   WSH_DEBUG_SV.log(l_module_name,' l_current_amount ',l_current_amount);
			END IF;


		 END IF;

                 l_approved_amount := l_approved_amount + nvl(l_current_amount,0);

	      END LOOP; -- END of C_DETAIL_INFO

    		IF l_debug_on THEN
--		   WSH_DEBUG_SV.log(l_module_name,' TOTAL Approved Amount For RCV LINE ',src_line.RCV_SHIPMENT_LINE_ID);
		   WSH_DEBUG_SV.log(l_module_name,' l_approved_amount ',l_approved_amount);
		END IF;




		OPEN  C_VENDOR_INFO(src_line.SOURCE_LINE_ID);
		FETCH C_VENDOR_INFO into l_vendor_id,l_vendor_site_id;
		CLOSE C_VENDOR_INFO;


		IF l_debug_on THEN
		   WSH_DEBUG_SV.log(l_module_name,' ************ API Parameters ********************* ');
	--	   WSH_DEBUG_SV.log(l_module_name,' src_line.SOURCE_LINE_ID ',src_line.SOURCE_LINE_ID);
		   WSH_DEBUG_SV.log(l_module_name,' src_line.RCV_SHIPMENT_LINE_ID ',src_line.RCV_SHIPMENT_LINE_ID);
		   WSH_DEBUG_SV.log(l_module_name,' l_approved_amount ',l_approved_amount);
		   WSH_DEBUG_SV.log(l_module_name,' src_line.CURRENCY_CODE ',src_line.CURRENCY_CODE);
		   WSH_DEBUG_SV.log(l_module_name,' l_vendor_id ',l_vendor_id);
		   WSH_DEBUG_SV.log(l_module_name,' l_vendor_site_id ',l_vendor_site_id);
		   WSH_DEBUG_SV.log(l_module_name,' *************************************************** ');
		END IF;


	      IF l_approved_amount <> 0 THEN

		 l_po_rcv_charges.SHIPMENT_LINE_ID := src_line.RCV_SHIPMENT_LINE_ID;
		 l_po_rcv_charges.CURRENCY_CODE    := src_line.CURRENCY_CODE;
		 l_po_rcv_charges.ACTUAL_AMOUNT    := l_approved_amount;
		 l_po_rcv_charges.VENDOR_ID        := l_vendor_id;
		 l_po_rcv_charges.VENDOR_SITE_ID   := l_vendor_site_id;


				PO_CHARGES_GRP.Capture_FTE_Actual_Charges(
				  p_api_version        => 1.0,
				  p_init_msg_list      => FND_API.G_FALSE,
				  x_return_status      => l_return_status,
				  x_msg_count          => l_msg_count,
				  x_msg_data           => l_msg_data,
				  p_fte_actual_charge  => l_po_rcv_charges);

--			END IF;


		   IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' Called PO_CHARGES_GRP.Capture_FTE_Actual_Charges');
		     WSH_DEBUG_SV.log(l_module_name,' l_return_status ',l_return_status);
		   END IF;


	       ELSE
		    IF l_debug_on THEN
			   WSH_DEBUG_SV.log(l_module_name,' Approved Amount is Zero , PO API Not called ');
		    END IF;

	       END IF;




	   END IF; -- End of Count 0 Check

	END LOOP; -- End of C_SOURCE_LINES

        IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	EXCEPTION
	 WHEN OTHERS THEN
  	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	   x_msg_data      := ' Error Message = '||SQLERRM||' Code = '||SQLCODE;

	   IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,x_msg_data);
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;



  END CALCULATE_FREIGHT_FOR_LTL;


  PROCEDURE CALCULATE_FREIGHT_FOR_TRUCK(p_bol                 IN VARCHAR2,
				        p_invoice_header_id   IN NUMBER,
	 			        x_return_status       OUT NOCOPY VARCHAR2,
				        x_msg_data            OUT NOCOPY VARCHAR2,
				        x_msg_count	      OUT NOCOPY NUMBER)
  IS

	CURSOR C_SOURCE_LINES ( p_bol_no VARCHAR2 )
	IS
	SELECT DISTINCT   WDD.SOURCE_LINE_ID,
			  WDD.CURRENCY_CODE,
			  WDD.WEIGHT_UOM_CODE
	FROM
		WSH_DELIVERY_DETAILS WDD,
		WSH_DELIVERY_ASSIGNMENTS WDA,
		WSH_DELIVERY_LEGS WDL,
		WSH_TRIP_STOPS WTS,
		WSH_TRIPS WT,
		WSH_DOCUMENT_INSTANCES WDI
	WHERE
		    WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
		AND WDD.LINE_DIRECTION     = 'I'
		AND WDA.DELIVERY_ID        = WDL.DELIVERY_ID
		AND WTS.STOP_ID            = WDL.PICK_UP_STOP_ID
		AND WT.TRIP_ID             = WTS.TRIP_ID
		AND WDI.ENTITY_ID          = WT.TRIP_ID
		AND WDI.ENTITY_NAME        = 'WSH_TRIPS'
		AND WDI.DOCUMENT_TYPE      = 'MBOL'
		AND WDI.SEQUENCE_NUMBER    = p_bol_no;


	  CURSOR C_SOURCE_LINE_BOLS ( p_source_line_id NUMBER,p_bol VARCHAR2)
	  IS
	    SELECT SUM(A.bol_flag) FROM (
	    SELECT distinct wdl.delivery_leg_id,
               decode( (select WDI.sequence_number from wsh_document_instances WDI,FTE_INVOICE_HEADERS FH
			where
				 WDI.ENTITY_ID    = DECODE(WT.MODE_OF_TRANSPORT,'LTL',WDL.DELIVERY_LEG_ID,'TRUCK',WT.TRIP_ID)
	                     AND WDI.ENTITY_NAME  = DECODE(WT.MODE_OF_TRANSPORT,'LTL','WSH_DELIVERY_LEGS','TRUCK','WSH_TRIPS')
			     AND WDI.SEQUENCE_NUMBER = FH.BOL
			     AND FH.BILL_STATUS = decode(FH.BOL,p_bol,FH.BILL_STATUS,'APPROVED')
			),NULL,1,0)   bol_flag
	   FROM
		 WSH_DELIVERY_DETAILS WDD,
		  WSH_DELIVERY_ASSIGNMENTS WDA,
		  WSH_DELIVERY_LEGS WDL,
		  WSH_TRIP_STOPS WTS,
		  WSH_TRIPS WT
	  WHERE
              WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
	  AND (WDA.DELIVERY_ID       = WDL.DELIVERY_ID  OR WDA.PARENT_DELIVERY_ID = WDL.DELIVERY_ID)
	  AND WDL.PARENT_DELIVERY_LEG_ID IS NULL
	  AND WDL.PICK_UP_STOP_ID    = WTS.STOP_ID
	  AND WT.TRIP_ID             = WTS.TRIP_ID
	  AND WDD.LINE_DIRECTION     = 'I'
	  AND WDD.SOURCE_LINE_ID     =  p_source_line_id
         ) A;



        CURSOR C_DETAIL_INFO (p_source_line_id NUMBER)
        IS
        SELECT
           DISTINCT WDL.DELIVERY_LEG_ID,
	           WDD.DELIVERY_DETAIL_ID,
		   WDD.INVENTORY_ITEM_ID,
                   WT.MODE_OF_TRANSPORT,
		   WT.TRIP_ID,
		   MIC.CATEGORY_ID AS COMMODITY_CATEGORY_ID,
		   DECODE(WDA.PARENT_DELIVERY_DETAIL_ID,NULL,'Y','N') AS CONTAINER_FLAG,
                   WDD.GROSS_WEIGHT,
		   WDD.WEIGHT_UOM_CODE,
		   WDD.CURRENCY_CODE,
		   (SELECT WDI.SEQUENCE_NUMBER FROM WSH_DOCUMENT_INSTANCES WDI
	  	    WHERE WDI.ENTITY_ID    = DECODE(WT.MODE_OF_TRANSPORT,'LTL',NVL(WDL.PARENT_DELIVERY_LEG_ID,WDL.DELIVERY_LEG_ID),'TRUCK',WT.TRIP_ID)
	              AND WDI.ENTITY_NAME  = DECODE(WT.MODE_OF_TRANSPORT,'LTL','WSH_DELIVERY_LEGS','TRUCK','WSH_TRIPS')
		   ) SEQUENCE_NUMBER
       FROM
	 WSH_DELIVERY_DETAILS WDD,
	 WSH_DELIVERY_ASSIGNMENTS WDA,
	 WSH_DELIVERY_LEGS WDL,
	 WSH_TRIP_STOPS WTS,
	 WSH_TRIPS WT,
	 MTL_ITEM_CATEGORIES MIC,
	 MTL_CATEGORIES_KFV C,
	 MTL_CATEGORY_SETS S
        WHERE
	       S.STRUCTURE_ID = C.STRUCTURE_ID
	  AND  S.CATEGORY_SET_NAME ='WSH_COMMODITY_CODE'
	  AND  C.ENABLED_FLAG ='Y'
	  AND  C.CATEGORY_ID        = MIC.CATEGORY_ID
          AND  MIC.INVENTORY_ITEM_ID = WDD.INVENTORY_ITEM_ID
          AND  MIC.ORGANIZATION_ID   = WDD.ORG_ID
          AND  WDD.DELIVERY_DETAIL_ID  = WDA.DELIVERY_DETAIL_ID
	  AND WDA.DELIVERY_ID        = WDL.DELIVERY_ID
	  AND WDA.DELIVERY_ID        = WDL.DELIVERY_ID
	  AND WDL.PICK_UP_STOP_ID     = WTS.STOP_ID
	  AND WT.TRIP_ID              = WTS.TRIP_ID
	  AND WDD.LINE_DIRECTION      = 'I'
	  AND WDD.SOURCE_LINE_ID      = p_source_line_id;


        CURSOR C_VENDOR_INFO(p_source_line_id NUMBER) IS
	SELECT VENDOR_ID,SHIP_FROM_SITE_ID
	FROM WSH_DELIVERY_DETAILS
	WHERE SOURCE_LINE_ID = p_source_line_id
	AND ROWNUM <= 1;



    l_all_approved_line_cnt NUMBER DEFAULT  0;
    l_approved_amount NUMBER DEFAULT  0;
    l_wFItemKey NUMBER;
    l_parameter_list     wf_parameter_list_t;

    l_current_amount NUMBER;
    i NUMBER;
    j NUMBER;

    l_return_status      VARCHAR2(1);
    l_msg_data           VARCHAR2(2000);
    l_msg_count          NUMBER;
    l_vendor_id          NUMBER;
    l_vendor_site_id     NUMBER;

    l_po_rcv_charges  po_rcv_charges%rowtype;

    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_FREIGHT_FOR_TRUCK';

    l_inc_parent_bol	VARCHAR2(2000);
    l_bill_type		VARCHAR2(30);

  BEGIN


	   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

	   IF l_debug_on IS NULL  THEN
	       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	   END IF;

	   --  Initialize API return status to success
	   x_return_status      := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	   x_msg_count		:= 0;
	   x_msg_data		:= '';


	   IF l_debug_on THEN
	       WSH_DEBUG_SV.push(l_module_name);
	   END IF;

           IF l_debug_on THEN

              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');
	      WSH_DEBUG_SV.log(l_module_name,' Printing Parameters Below...... ');
              WSH_DEBUG_SV.log(l_module_name,' *****************************.. ');
	      WSH_DEBUG_SV.log(l_module_name,' p_bol ',p_bol);
	      WSH_DEBUG_SV.log(l_module_name,' p_invoice_header_id ',p_invoice_header_id);

           END IF;


        i := 0;

        FOR src_line in C_SOURCE_LINES(p_bol) LOOP

	    i := i + 1;

	     IF l_debug_on THEN
		  WSH_DEBUG_SV.log(l_module_name,' LOOP CURSOR C_SOURCE_LINES ==> Iteration '||i);
		  WSH_DEBUG_SV.log(l_module_name,' src_line.SOURCE_LINE_ID ',src_line.SOURCE_LINE_ID);
	     END IF;


           OPEN  C_SOURCE_LINE_BOLS(src_line.SOURCE_LINE_ID,p_bol);
	   FETCH C_SOURCE_LINE_BOLS INTO l_all_approved_line_cnt;
	   CLOSE C_SOURCE_LINE_BOLS;

	   IF l_debug_on THEN
	        WSH_DEBUG_SV.log(l_module_name,' CURSOR C_SOURCE_LINE_BOLS ==> Iteration ',i);
		WSH_DEBUG_SV.log(l_module_name,' l_all_approved_line_cnt ',l_all_approved_line_cnt);
	   END IF;


	   IF l_all_approved_line_cnt = 0 THEN

                l_approved_amount := 0;
		j := 0;


	      FOR src_det in C_DETAIL_INFO(src_line.SOURCE_LINE_ID) LOOP

		 j := j + 1;
		 l_current_amount := 0;

		 IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_module_name,' LOOP CURSOR C_DETAIL_INFO ==> Iteration ',j);
		      WSH_DEBUG_SV.log(l_module_name,' src_det.MODE_OF_TRANSPORT ',src_det.MODE_OF_TRANSPORT);
		 END IF;



	         IF    src_det.MODE_OF_TRANSPORT = 'LTL'
	         THEN

			SELECT BILL_TYPE, BOL INTO l_bill_type, l_inc_parent_bol
			FROM FTE_INVOICE_HEADERS
			WHERE INVOICE_HEADER_ID = p_invoice_header_id;


			 IF l_debug_on THEN
			      WSH_DEBUG_SV.log(l_module_name,' BILL type ',l_bill_type);
			      WSH_DEBUG_SV.log(l_module_name,' l_inc_parent_bol ',l_inc_parent_bol);
			      WSH_DEBUG_SV.log(l_module_name,' src_det.SEQUENCE_NUMBER ',src_det.SEQUENCE_NUMBER);
			 END IF;

			IF (l_bill_type = 'INC' AND
				l_inc_parent_bol = src_det.SEQUENCE_NUMBER)
			THEN

	                       l_current_amount :=  GET_FREIGHT_COST_LTL
		                                               (p_delivery_leg_id       => src_det.DELIVERY_LEG_ID,
							        p_delivery_detail_id    => src_det.DELIVERY_DETAIL_ID  ,
							        p_commodity_category_id => src_det.COMMODITY_CATEGORY_ID,
							        p_bol                   => src_det.SEQUENCE_NUMBER,
							        g_currency_code         => src_det.CURRENCY_CODE,
							        p_invoice_header_id	=> p_invoice_header_id);


				IF l_debug_on THEN
				   WSH_DEBUG_SV.log(l_module_name,' LTL approved_amount For Delivery Detail ',src_det.DELIVERY_DETAIL_ID);
				   WSH_DEBUG_SV.log(l_module_name,' l_current_amount ',l_current_amount);
				END IF;
			END IF;

		 ELSIF src_det.MODE_OF_TRANSPORT = 'TRUCK' THEN

                       l_current_amount :=  GET_FREIGHT_COST_TRUCK
							     (p_trip_id            => src_det.TRIP_ID  ,
						              p_delivery_detail_id => src_det.DELIVERY_DETAIL_ID,
							      p_inventory_item_id  => src_det.INVENTORY_ITEM_ID,
							      p_delivery_leg_id    =>  src_det.DELIVERY_LEG_ID ,
							      p_bol                =>  src_det.SEQUENCE_NUMBER,
							      p_container_flag     =>  src_det.CONTAINER_FLAG,
							      p_gross_weight       =>  src_det.GROSS_WEIGHT,
							      p_weight_uom         =>  src_det.WEIGHT_UOM_CODE,
							      g_currency_code      =>  src_det.CURRENCY_CODE);

			IF l_debug_on THEN
			   WSH_DEBUG_SV.log(l_module_name,' TRUCK approved_amount For Delivery Detail ',src_det.DELIVERY_DETAIL_ID);
			   WSH_DEBUG_SV.log(l_module_name,' l_current_amount ',l_current_amount);
			END IF;

		 END IF;

                 l_approved_amount := l_approved_amount + nvl(l_current_amount,0);

	      END LOOP; -- END of C_DETAIL_INFO



		OPEN  C_VENDOR_INFO(src_line.SOURCE_LINE_ID);
		FETCH C_VENDOR_INFO into l_vendor_id,l_vendor_site_id;
		CLOSE C_VENDOR_INFO;


		IF l_debug_on THEN
		   WSH_DEBUG_SV.log(l_module_name,' ************ API Parameters ********************* ');
		   WSH_DEBUG_SV.log(l_module_name,' src_line.SOURCE_LINE_ID ',src_line.SOURCE_LINE_ID);
		   WSH_DEBUG_SV.log(l_module_name,' l_approved_amount ',l_approved_amount);
		   WSH_DEBUG_SV.log(l_module_name,' src_line.CURRENCY_CODE ',src_line.CURRENCY_CODE);
		   WSH_DEBUG_SV.log(l_module_name,' l_vendor_id ',l_vendor_id);
		   WSH_DEBUG_SV.log(l_module_name,' l_vendor_site_id ',l_vendor_site_id);
		   WSH_DEBUG_SV.log(l_module_name,' *************************************************** ');
		END IF;


	      IF l_approved_amount <> 0 THEN

		 l_po_rcv_charges.SHIPMENT_LINE_ID := src_line.SOURCE_LINE_ID;
		 l_po_rcv_charges.CURRENCY_CODE    := src_line.CURRENCY_CODE;
		 l_po_rcv_charges.ACTUAL_AMOUNT    := l_approved_amount;
		 l_po_rcv_charges.VENDOR_ID        := l_vendor_id;
		 l_po_rcv_charges.VENDOR_SITE_ID   := l_vendor_site_id;


			PO_CHARGES_GRP.Capture_FTE_Actual_Charges(
			  p_api_version        => 1.0,
			  p_init_msg_list      => FND_API.G_FALSE,
			  x_return_status      => l_return_status,
			  x_msg_count          => l_msg_count,
			  x_msg_data           => l_msg_data,
			  p_fte_actual_charge  => l_po_rcv_charges);

		   IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,' Called PO_CHARGES_GRP.Capture_FTE_Actual_Charges');
		     WSH_DEBUG_SV.log(l_module_name,' l_return_status ',l_return_status);
		   END IF;


	       ELSE
		    IF l_debug_on THEN
			   WSH_DEBUG_SV.log(l_module_name,' Approved Amount is Zero , PO API Not called ');
		    END IF;

	       END IF;



	   END IF; -- End of Count 0 Check

	END LOOP; -- End of C_SOURCE_LINES

        IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	EXCEPTION

	 WHEN OTHERS THEN
  	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	   x_msg_data      := ' Error Message = '||SQLERRM||' Code = '||SQLCODE;

	   IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,x_msg_data);
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;



  END CALCULATE_FREIGHT_FOR_TRUCK;


 PROCEDURE CALCULATE_PO_FREIGHT(p_bol_no IN VARCHAR2,
                                p_inv_header_id IN NUMBER,
				p_mode_of_transport IN VARCHAR2)
IS

l_file_name VARCHAR2(300);
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

l_debug_on BOOLEAN;

BEGIN


        -- Test Code
        wsh_debug_interface.g_Debug := TRUE;
	WSH_DEBUG_SV.start_debugger
	    (x_file_name     =>  l_file_name,
	     x_return_status =>  l_return_status,
	     x_msg_count     =>  l_msg_count,
	     x_msg_data      =>  l_msg_data);

--       insert into dbg_value values(' File name = '||l_file_name);

	   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

	   IF l_debug_on IS NULL  THEN
	       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	   END IF;


	  IF    p_mode_of_transport = 'LTL' THEN

		CALCULATE_FREIGHT_FOR_LTL (p_bol                => p_bol_no,
					   p_invoice_header_id  => p_inv_header_id,
					   x_return_status      => l_return_status,
					   x_msg_data           => l_msg_data,
					   x_msg_count		=> l_msg_count);

	  ELSIF p_mode_of_transport = 'TL' THEN

		CALCULATE_FREIGHT_FOR_TRUCK (p_bol                => p_bol_no,
					     p_invoice_header_id  => p_inv_header_id,
					     x_return_status      => l_return_status,
					     x_msg_data           => l_msg_data,
					     x_msg_count	  => l_msg_count) ;


	  END IF;

       WSH_DEBUG_SV.stop_debugger;

END CALCULATE_PO_FREIGHT;


 PROCEDURE callDBI
 (p_invoice_header_id  IN    NUMBER,
  p_dml_type           IN    VARCHAR2,
  p_return_status      OUT  NOCOPY VARCHAR2) IS

     v_tab ISC_DBI_CHANGE_LOG_PKG.log_tab_type;

   BEGIN
     v_tab(1) := p_invoice_header_id;

     ISC_DBI_CHANGE_LOG_PKG.UPDATE_FTE_INVOICE_LOG(v_tab, p_dml_type, p_return_status);
       NULL;
   END;


  PROCEDURE Get_Legal_Entity(p_org_id IN NUMBER,
                             x_legal_entity_id OUT NOCOPY NUMBER,
			     x_return_status   OUT NOCOPY VARCHAR2,
			     x_msg_data OUT NOCOPY VARCHAR2,
			     x_msg_count OUT NOCOPY NUMBER)
     IS
	/*BEGIN
	x_return_status := 'S';
	x_msg_data :=' ';
	x_msg_count := 0; */

	l_inv_org_rec XLE_BUSINESSINFO_GRP.Inv_Org_Rec_Type;

	--
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Get_Legal_Entity';

	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_number_of_warnings	    NUMBER;
	l_number_of_errors	    NUMBER;


    BEGIN

    NULL;

	     SAVEPOINT GET_LEGAL_ENTITY_PUB;

	     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	     x_msg_data  := '';
	     x_msg_count := 0;
  	     l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	     l_number_of_warnings := 0;
  	     l_number_of_errors	:= 0;



   	     FND_MSG_PUB.initialize;

	     IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	     END IF;


	     XLE_BUSINESSINFO_GRP.Get_InvOrg_Info(
	      x_return_status  => l_return_status,
	      x_msg_data       => l_msg_data,
	      P_InvOrg_ID      => p_org_id,
	      P_Le_ID          => NULL,
	      P_Party_ID       => NULL,
	      x_Inv_Le_info    => l_inv_org_rec
	    );

            x_legal_entity_id := l_inv_org_rec(1).legal_entity_id;

    	     wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);


	IF l_number_of_errors > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0 	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	IF l_debug_on THEN
	  WSH_DEBUG_SV.pop(l_module_name);
	END IF;

    EXCEPTION

       	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO GET_LEGAL_ENTITY_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO GET_LEGAL_ENTITY_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		ROLLBACK TO GET_LEGAL_ENTITY_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;


    END Get_Legal_Entity;


 -- ------------------------------------------------------------------------------- --
 -- PROCEDURE                                                                       --
 -- NAME:                Update_Status                                    --
 -- TYPE:                PROCEDURE                                                  --
 -- PARAMETERS (IN):     itemtype	VARCHAR2 (wf item type's internal name)	    --
 --                      itemkey        VARCHAR2 (wf block instance label)          --
 --                      actid		NUMBER	 (wf function/activity id)          --
 --			 funcmode	VARCHAR	 (execution mode)		    --
 --										    --
 -- PARAMETERS (OUT):    resultout      VARCHAR2 (completion status)                --
 -- PARAMETERS (IN OUT): none                                                       --
 -- RETURN:              none                                                       --
 -- DESCRIPTION:         This procedure will update Invoice Payment Status In FTE   --
 --			 with the payment status retrieved from account payables.   --
 --                      This is procedure is invoked from PAYMENT_STATUS_UPDATE    --
 --			 Process of FTEPSUPD workflow item type.                    --
 -- CHANGE CONTROL LOG                                                              --
 -- ------------------                                                              --
 --                                                                                 --
 -- DATE        VERSION  BY        BUG      DESCRIPTION                             --
 -- ----------  -------  --------  -------  --------------------------------------- --
 -- 2003        11.5.1   SAMUTHUK           Created                                 --
 --                                                                                 --
 -- ------------------------------------------------------------------------------- --


 PROCEDURE Update_Status(itemtype  IN         VARCHAR2,
                         itemkey   IN         VARCHAR2,
                         actid     IN         NUMBER,
                         funcmode  IN         VARCHAR2,
                         resultout OUT NOCOPY VARCHAR2) IS


	CURSOR C_INVOICE(p_check_id NUMBER)  IS
	SELECT
	INV.INVOICE_NUM,
	INV.PAYMENT_STATUS_FLAG
	FROM
	AP_INVOICES_ALL INV,
	AP_INVOICE_PAYMENTS_ALL PAY,
	AP_CHECKS_ALL CHK
	WHERE
	PAY.INVOICE_ID = INV.INVOICE_ID
	AND CHK.CHECK_ID = PAY.CHECK_ID
	AND PAY.CHECK_ID = p_check_id;



	l_check_id              NUMBER;
	l_invoice_number        VARCHAR2(30);
	l_payment_status        VARCHAR2(1);
	l_error                 VARCHAR2(100);
	l_invoice_id            NUMBER;

	l_api_name              CONSTANT VARCHAR2(30) := 'Update_Status';
	l_api_version           CONSTANT NUMBER       := 1.0;
	l_debug_on              CONSTANT BOOLEAN      := WSH_DEBUG_SV.is_debug_enabled;

	l_userName		VARCHAR2(100);
	returnStatus 		VARCHAR2(10);

	l_role_name		VARCHAR2(100);
	l_display_name		VARCHAR2(1000);
	hz_party_display_name 	varchar2(1000);
	l_email_address 	VARCHAR2(1000);
	l_notif			VARCHAR2(1000);
	l_lang			VARCHAR2(100);
	l_ter			VARCHAR2(1000);



 BEGIN
	      IF funcmode = 'RUN' THEN

	           IF l_debug_on THEN
	      	       WSH_DEBUG_SV.push(l_api_name);
	           END IF;


		   l_payment_status := 'N';

	           WF_DIRECTORY.GETROLEINFO (
					role => FND_GLOBAL.USER_NAME,
					display_name => hz_party_display_name,
					email_address => l_email_address,
					notification_preference => l_notif,
					language => l_lang,
					territory => l_ter);

		   IF (hz_party_display_name IS NOT NULL) THEN
			   wf_engine.SetItemOwner(itemtype,itemkey,FND_GLOBAL.USER_NAME);
		   END IF;

		   l_check_id    := wf_engine.GetItemAttrNumber(itemtype  => itemtype,
		        					itemkey   => itemkey,
		        					aname     => 'CHECK_ID');

                   IF l_debug_on THEN
        	     WSH_DEBUG_SV.logmsg(l_api_name,to_char(l_check_id),WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;


		   FOR get_c_invoice_rec IN c_invoice(l_check_id)
			LOOP
			--{
				l_invoice_number := get_c_invoice_rec.invoice_num;
				l_payment_status := get_c_invoice_rec.payment_status_flag;

				SELECT invoice_header_id into l_invoice_id
				FROM fte_invoice_headers
				WHERE bill_number = l_invoice_number;

				IF    l_payment_status = 'Y' THEN
					UPDATE FTE_INVOICE_HEADERS
					SET BILL_STATUS  = 'PAID'
					WHERE BILL_NUMBER = l_invoice_number;
					callDBI(l_invoice_id, 'UPDATE', returnStatus);
				ELSIF l_payment_status = 'P' THEN
					UPDATE FTE_INVOICE_HEADERS
					SET BILL_STATUS  = 'PARTIAL_PAID'
					WHERE BILL_NUMBER = l_invoice_number;

					callDBI(l_invoice_id, 'UPDATE', returnStatus);
				END IF;

			--}
		   END LOOP;


		   IF c_invoice%ISOPEN THEN
			CLOSE c_invoice;
		   END IF;

		   /**
		   OPEN C_INVOICE(l_check_id);
		   FETCH C_INVOICE INTO l_invoice_number,l_payment_status;

		   IF C_INVOICE%NOTFOUND THEN
		       resultout := 'COMPLETE:N';
		       RETURN;
		   END IF;

		   CLOSE C_INVOICE;

		   select invoice_header_id into l_invoice_id
		   from fte_invoice_headers
		   where bill_number = l_invoice_number;

		   IF    l_payment_status = 'Y' THEN
				UPDATE FTE_INVOICE_HEADERS
				SET BILL_STATUS  = 'PAID'
	     			WHERE BILL_NUMBER = l_invoice_number;

				callDBI(l_invoice_id, 'UPDATE', returnStatus);

		   ELSIF l_payment_status = 'P' THEN
		        	UPDATE FTE_INVOICE_HEADERS
				SET BILL_STATUS  = 'PARTIALLY PAID'
				WHERE BILL_NUMBER = l_invoice_number;

		                callDBI(l_invoice_id, 'UPDATE', returnStatus);
		   END IF;
		   */

	     END IF;

		   IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_api_name);
		   END IF;


	           resultout := 'COMPLETE:Y';

	     EXCEPTION
	        WHEN OTHERS THEN
	           resultout := 'COMPLETE:N';

	           wf_core.context('FTE_FPA_UTIL',
	                           'Update_Status',
	                           itemtype,
	                           itemkey,
	                           actid,
	                           funcmode);
                  RAISE;

 END Update_Status;

-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                START_FRACCT_WF_PROCESS                               --
-- TYPE:                FUNCTION                                              --
-- PARAMETERS (IN):     p_carrier_id       NUMBER                             --
--                      p_ship_from_org_id NUMBER                             --
-- PARAMETERS (OUT):    x_return_ccid      NUMBER                             --
--                      p_ship_to_org_id   NUMBER                             --
--                      p_supplier_id      NUMBER                             --
--                      p_supplier_site_id NUMBER                             --
--                      p_trip_id          NUMBER                             --
--                      p_delivery_id      NUMBER                             --
--                      x_concat_segs      VARCHAR2                           --
--                      x_concat_ids       VARCHAR2                           --
--                      x_concat_descrs    VARCHAR2                           --
--                      x_msg_count        VARCHAR2                           --
--                      x_msg_data         VARCHAR2                           --
-- PARAMETERS (IN OUT): none                                                  --
-- RETURN:              VARCHAR2                                              --
-- DESCRIPTION:         This function is used to start the Workflow Process   --
--                      for the Distribution Account Generator                --
--                                                                            --
--                                                                            --
-- -------------------------------------------------------------------------- --




FUNCTION START_FRACCT_WF_PROCESS
(
    p_carrier_id        IN              NUMBER,
    p_ship_from_org_id  IN              NUMBER,
    p_ship_to_org_id    IN              NUMBER,
    p_supplier_id       IN              NUMBER,
    p_supplier_site_id  IN              NUMBER,
    p_trip_id           IN              NUMBER,
    p_delivery_id       IN              NUMBER,
    x_return_ccid       OUT     NOCOPY  NUMBER,
    x_concat_segs       OUT     NOCOPY  VARCHAR2,
    x_concat_ids        OUT     NOCOPY  VARCHAR2,
    x_concat_descrs     OUT     NOCOPY  VARCHAR2,
    x_msg_count         OUT     NOCOPY  NUMBER,
    x_msg_data          OUT     NOCOPY  VARCHAR2)
RETURN VARCHAR2
IS
    l_chart_of_accounts_id  NUMBER;
    l_itemkey               VARCHAR2(38);
    l_itemtype              VARCHAR2(30);
    lx_return_ccid          NUMBER;
    lx_concat_segs          VARCHAR2(1000);
    lx_concat_ids           VARCHAR2(1000);
    lx_concat_descrs        VARCHAR2(1000);
    lx_msg_count            NUMBER;
    lx_msg_data             VARCHAR2(1000);
    l_errmsg                VARCHAR2(2000);
    l_result                BOOLEAN;
    l_new_combination       BOOLEAN;
    l_return_status         VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'START_FRACCT_WF_PROCESS';

BEGIN

 --

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
   END IF;


    l_itemtype := 'FTEDIST';
    BEGIN
        SELECT GSOB.CHART_OF_ACCOUNTS_ID
        INTO    l_chart_of_accounts_id
        FROM
        HR_ORGANIZATION_INFORMATION HOI2,
        GL_SETS_OF_BOOKS GSOB
        WHERE HOI2.ORG_INFORMATION1 = TO_CHAR(GSOB.SET_OF_BOOKS_ID)
        AND   (HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
        AND   HOI2.ORGANIZATION_ID = p_ship_from_org_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,' Chart of Account is not defined for the Organization' , p_ship_from_org_id);
        END IF;
    END;

     -- Bug # 3401364
     WF_ITEM.CLEARCACHE;

     IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FND_FLEX_WORKFLOW.INITIALIZE',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

    l_itemkey := FND_FLEX_WORKFLOW.INITIALIZE
                ('SQLGL',
                'GL#',
                l_chart_of_accounts_id,
                l_itemtype
                );

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Item Key' , l_itemkey);
    END IF;


    /* Initialize the workflow item attributes  */
    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'SHIP_FROM_ORG_ID',
            avalue   => p_ship_from_org_id);

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'SHIP_TO_ORG_ID',
            avalue   => p_ship_to_org_id);

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'CARRIER_ID',
            avalue   => p_carrier_id);

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'SUPPLIER_ID',
            avalue   => p_supplier_id);

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'SUPPLIER_SITE_ID',
            avalue   => p_supplier_site_id);

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'TRIP_ID',
            avalue   => p_trip_id);

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'DELIVERY_ID',
            avalue   => p_delivery_id);

     IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FND_FLEX_WORKFLOW.GENERATE(',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     l_result := FND_FLEX_WORKFLOW.GENERATE(
                    itemtype        => l_itemtype,
                    itemkey         => l_itemkey,
                    insert_if_new   => FALSE,
                    ccid            => lx_return_ccid,
                    concat_segs     => lx_concat_segs,
                    concat_ids      => lx_concat_ids,
                    concat_descrs   => lx_concat_descrs,
                    error_message   => l_errmsg,
                    new_combination => l_new_combination
                    );


     IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'ccid : ' , lx_return_ccid);
          WSH_DEBUG_SV.log(l_module_name,'Concatenated Segments : ' , lx_concat_segs);
          WSH_DEBUG_SV.log(l_module_name,'Error Message' , l_errmsg);
     END IF;







    x_return_ccid   := lx_return_ccid;
    x_concat_segs   := lx_concat_segs;
    x_concat_ids    := lx_concat_ids;
    x_concat_descrs := lx_concat_descrs;




    IF      l_result THEN
        l_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    ELSE

        l_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN

            WSH_DEBUG_SV.log(l_module_name,'Error Message' , l_errmsg);
        END IF;


    END IF;


    IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    RETURN l_return_status;

    EXCEPTION
        WHEN OTHERS THEN
	l_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Unexpected Error occured in START_FRACCT_WF_PROCESS' || SQLERRM);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	return l_return_status;


END START_FRACCT_WF_PROCESS;



-- -----------------------------------------------------------------------------
--                                                                            --
-- NAME:                GET_FRACCT_CCID                                       --
-- TYPE:                PROCEDURE                                             --
-- PARAMETERS (IN):     itemtype         NUMBER                               --
--                      itemkey          VARCHAR2                             --
--                      actid            NUMBER                               --
--                      funcmode         VARCHAR2                             --
-- PARAMETERS (OUT):    result           VARCHAR2                             --
-- PARAMETERS (IN OUT): none                                                  --
-- RETURN:              NONE                                                  --
-- DESCRIPTION:         This procedure gets the ORGANIZATION_ID which is a    --
--                      Workflow Attributes and determines the                --
--			default freight account from the Shipping Parameters  --
--                      (WSH_SHIPPING_PARAMETERS. The Workflow attribute      --
--                      'GENERATED_CCID' is set accordingly                   --
--                      for the Distribution Account Generator                --
--                                                                            --
--                                                                            --
-- -------------------------------------------------------------------------- --







PROCEDURE GET_FRACCT_CCID
(
    itemtype    IN VARCHAR2,
    itemkey     IN VARCHAR2,
    actid       IN NUMBER,
    funcmode    IN VARCHAR2,
    result      OUT NOCOPY VARCHAR2) IS

    l_freight_code      VARCHAR2(25);
    l_carrier_id        NUMBER;
    l_organization_id   NUMBER;
    l_ccid              NUMBER;
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'START_FRACCT_WF_PROCESS';

BEGIN

 --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
   --
   --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
    END IF;

    IF funcmode = 'RUN' THEN

    l_organization_id   := wf_engine.getItemAttrNumber(itemtype,itemkey,'SHIP_FROM_ORG_ID');

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Ship From Org : ' , l_organization_id);
    END IF;



	SELECT FPA_DEFAULT_FREIGHT_ACCOUNT
	INTO l_ccid
	FROM wsh_shipping_parameters
	WHERE organization_id  = l_organization_id;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, ' Freight Account from Shipping Paramters (CCID) : ' , l_ccid);
    END IF;



    wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',l_ccid);

    result :=  'COMPLETE:SUCCESS';
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;

    END IF;

    IF funcmode = 'CANCEL' THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
        return;
    END IF;

EXCEPTION

       WHEN OTHERS THEN

         wf_core.context('FTE_FPA_UTIL','GET_FRACCT_CCID',
                        itemtype,itemkey,TO_CHAR(actid),funcmode);
         result :=  'COMPLETE:FAILURE';
         RAISE;


end GET_FRACCT_CCID;


PROCEDURE LOG_FAILURE_REASON(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_parent_name		  IN	 VARCHAR2,
			p_parent_id		  IN	 NUMBER,
			p_failure_type		  IN	 VARCHAR2,
			p_failure_reason	  IN	 VARCHAR2,
	        	x_return_status           OUT   NOCOPY VARCHAR2,
	        	x_msg_count               OUT   NOCOPY NUMBER,
	        	x_msg_data                OUT   NOCOPY VARCHAR2) IS
	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'LOG_FAILURE_REASON';
        l_api_version           CONSTANT NUMBER         := 1.0;

	--}


	--{
BEGIN
	--
	-- Standard Start of API savepoint
	SAVEPOINT   LOG_FAILURE_REASON_PUB;
	--
	--
	-- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
	--
	--
	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;

	INSERT INTO FTE_FAILURE_REASONS
	 (INVOICE_REJECT_ID,
	  PARENT_NAME,
	  PARENT_ID,
	  BOL,
	  FAILURE_TYPE,
	  FAILURE_REASON,
	  CREATED_BY,
	  CREATION_DATE,
          LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN)
	VALUES
	(FTE_FAILURE_REASONS_S.nextval,
	 p_parent_name,
	 p_parent_id,
	 NULL,
	 p_failure_type,
	 p_failure_reason,
	 FND_GLOBAL.USER_ID,
	 SYSDATE,
	 FND_GLOBAL.USER_ID,
	 SYSDATE,
	 FND_GLOBAL.USER_ID);


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );
	--
	--


--}
EXCEPTION
	--{
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO LOG_FAILURE_REASON_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO LOG_FAILURE_REASON_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO LOG_FAILURE_REASON_PUB;
		wsh_util_core.default_handler('FTE_TENDER_PVT.TAKE_TENDER_SNAPSHOT_PUB');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	--}

END LOG_FAILURE_REASON;



END FTE_FPA_UTIL;

/
