--------------------------------------------------------
--  DDL for Package Body ASO_TRADEIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_TRADEIN_PVT" as
/* $Header: asovtrdb.pls 120.4 2005/09/02 13:09:51 hagrawal ship $ */
-- Start of Comments
-- Package name     : ASO_TRADEIN_PVT
-- Purpose          :
-- History          :
--                  10/07/2002 hyang - 2611381, performance fix for 1158
--				10/18/2002 hyang - 2633507, performance fix
-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'ASO_TRADEIN_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovtrdb.pls';


PROCEDURE Validate_Line_Tradein(
	p_init_msg_list      IN   VARCHAR2,
	p_qte_header_rec	 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Qte_Line_rec		 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
	x_return_status      OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count          OUT NOCOPY /* file.sql.39 change */    NUMBER,
	x_msg_data           OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS

/* 2633507 - hyang: use mtl_system_items_b instead of vl */

    CURSOR C_Validate_Item(l_inv_item_id NUMBER) IS
     SELECT returnable_flag, customer_order_enabled_flag, serviceable_product_flag FROM MTL_SYSTEM_ITEMS_B
     WHERE inventory_item_id = l_inv_item_id
	 AND organization_id = p_qte_line_rec.organization_id;

     CURSOR C_inventory_item is
      SELECT inventory_item_id, line_category_code from aso_quote_lines_all
      where quote_line_id = p_qte_line_rec.quote_line_id;

    CURSOR C_item_type IS
     SELECT item_type_code FROM aso_quote_lines_all
     WHERE quote_line_id = p_qte_line_rec.quote_line_id;

    CURSOR C_Service_Available IS
     SELECT count(related_quote_line_id) FROM aso_line_relationships
     WHERE quote_line_id = p_qte_line_rec.quote_line_id
	AND relationship_type_code = 'SERVICE';

    CURSOR C_workflow IS
	SELECT start_date_active, end_date_active
	FROM OE_WF_LINE_ASSIGN_V
	WHERE order_type_id = p_qte_header_rec.order_type_id
	and line_type_id = p_qte_line_rec.order_line_type_id
     and (trunc(sysdate) BETWEEN NVL(start_date_active, sysdate) AND
		   NVL(end_date_active, sysdate));

    l_serviceable_product_flag      VARCHAR2(1);
    l_returnable_flag               VARCHAR2(1);
    l_order_line_type_id            NUMBER;
    l_line_category_code            VARCHAR2(30);
    l_inventory_item_id             NUMBER;
    l_customer_order_enabled_flag   VARCHAR2(1);
    l_item_type_code                VARCHAR2(30);
    l_service_count                 NUMBER;
    l_start_date date;
    l_end_date date;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Entering Validate_Line_Tradein ', 2, 'Y');
aso_debug_pub.add('Quote category code = ' || p_qte_header_rec.quote_category_code, 2, 'N');
aso_debug_pub.add('Line category code = ' || p_qte_line_rec.line_category_code, 2, 'N');
aso_debug_pub.add('order type id = ' || p_qte_header_rec.order_type_id, 2, 'N');
aso_debug_pub.add('Line Type = ' || p_qte_line_rec.order_line_type_id, 2, 'N');
END IF;


    IF p_qte_line_rec.operation_code = 'UPDATE' then
      OPEN C_inventory_item;
      FETCH C_inventory_item into l_inventory_item_id, l_line_category_code;

      IF p_qte_line_rec.line_category_code is not null and
         p_qte_line_rec.line_category_code <> FND_API.G_MISS_CHAR then
         l_line_category_code := p_qte_line_rec.line_category_code;
      end if;
      IF p_qte_line_rec.inventory_item_id is not null and
         p_qte_line_rec.inventory_item_id <> FND_API.G_MISS_NUM then
         l_inventory_item_id := p_qte_line_rec.inventory_item_id;
      end if;
      CLOSE C_inventory_item;
    else
      IF p_qte_line_rec.line_category_code is not null and
         p_qte_line_rec.line_category_code <> FND_API.G_MISS_CHAR then
         l_line_category_code := p_qte_line_rec.line_category_code;
      end if;
      IF p_qte_line_rec.inventory_item_id is not null and
         p_qte_line_rec.inventory_item_id <> FND_API.G_MISS_NUM then
         l_inventory_item_id := p_qte_line_rec.inventory_item_id;
      end if;
    end if; -- end check update operation.

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Line category code after update check = ' || l_line_category_code, 2, 'N');
aso_debug_pub.add('inventory item after update check = ' || l_inventory_item_id,2, 'N');
END IF;


    --  Check if item is returnable
    OPEN C_Validate_Item(l_inventory_item_id);
    FETCH C_Validate_Item INTO l_returnable_flag, l_customer_order_enabled_flag, l_serviceable_product_flag;
    CLOSE C_Validate_Item;

    --  Line level validations
        IF l_line_category_code = 'RETURN' THEN
           IF (p_qte_header_rec.quote_category_code <> 'MIXED') THEN

                 x_return_status := FND_API.G_RET_STS_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_LINE_CATEGORY_CODE');
                    FND_MSG_PUB.ADD;
                 END IF;
            END IF;

            --  Check if item is returnable
            IF (NVL(l_returnable_flag,'Y') = 'N') THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_NOT_RETURNABLE');
                    FND_MSG_PUB.ADD;
                END IF;
            END IF;

            IF p_qte_line_rec.operation_code = 'UPDATE' AND
                 l_serviceable_product_flag = 'Y' THEN
/*               p_qte_line_rec.item_type_code = 'SVA' THEN  */
                OPEN C_Service_Available;
                FETCH C_Service_Available INTO l_service_count;
                CLOSE C_Service_Available;

                IF l_service_count > 0 THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_SERVICE_NOT_RETURNABLE');
                        FND_MSG_PUB.ADD;
                     END IF;
                END IF;
            END IF;

         ELSE  -- RETURN

          IF (NVL(l_customer_order_enabled_flag,'Y') = 'N') THEN
           IF p_qte_line_rec.operation_code = 'CREATE' THEN
                IF p_qte_line_rec.item_type_code <> 'CFG' AND
                   p_qte_line_rec.item_type_code IS NOT NULL AND
                   p_qte_line_rec.item_type_code <> FND_API.G_MISS_CHAR THEN

                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_NOT_ORDERABLE');
                        FND_MSG_PUB.ADD;
                    END IF;

                 END IF;
            ELSE  -- 'CREATE'
              IF p_qte_line_rec.operation_code = 'UPDATE' THEN
                  IF p_qte_line_rec.item_type_code <> 'CFG' AND
                   p_qte_line_rec.item_type_code IS NOT NULL AND
                   p_qte_line_rec.item_type_code <> FND_API.G_MISS_CHAR THEN

                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_NOT_ORDERABLE');
                        FND_MSG_PUB.ADD;
                    END IF;

                   ELSE   -- 'CFG'

                    IF p_qte_line_rec.item_type_code IS NULL OR
                       p_qte_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN
                        OPEN C_item_type;
                        FETCH C_item_type INTO l_item_type_code;
                        CLOSE C_item_type;

                        IF l_item_type_code <> 'CFG' AND
                           l_item_type_code IS NOT NULL AND
                           l_item_type_code <> FND_API.G_MISS_CHAR THEN

                            x_return_status := FND_API.G_RET_STS_ERROR;
                            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                FND_MESSAGE.Set_Name('ASO', 'ASO_NOT_ORDERABLE');
                                FND_MSG_PUB.ADD;
                            END IF;
                          END IF;
                       END IF;

                     END IF; -- 'CFG'

                 END IF;  -- 'UPDATE'

               END IF;  -- 'CREATE'

            END IF;   -- order_enabled_flag

          END IF;  -- 'RETURN'



		-- Check if the workflow exists for this line type
/*	IF p_qte_line_rec.order_line_type_id IS NOT NULL AND
	   p_qte_line_rec.order_line_type_id <> FND_API.G_MISS_NUM THEN

		OPEN C_workflow;
		FETCH C_Workflow into l_start_date, l_end_Date;
		IF C_workflow%NOTFOUND THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('ASO', 'ASO_NO_WORKFLOW');
			FND_MSG_PUB.ADD;
		   END IF;
          END IF;
	END IF; */

END Validate_Line_Tradein;



PROCEDURE OrderType(
	p_init_msg_list		IN	VARCHAR2,
	p_qte_header_rec	IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Header_Rec_Type,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

/*
 * 2633507 - hyang: use oe_transaction_types_all instead of aso_i_order_types_v
 */

        CURSOR C_Order_Type(l_order_type_id NUMBER) IS
	SELECT order_category_code, start_date_active, end_date_active
	--FROM OE_TRANSACTION_TYPES_ALL   Commented Code yogeshwar (MOAC)
	FROM	OE_TRANSACTION_TYPES_VL   --New Code Yogeshwar (MOAC)
	WHERE transaction_type_id = l_order_type_id
	and Transaction_type_code = 'ORDER' ;
	--Commented Code Start Yogeshwar
	/*
	and NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
        */
	--Commented Code End Yogeshwar
    l_order_category_code   VARCHAR2(30);
    l_start_date	DATE;
    l_end_date		DATE;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Entering OrderType ', 2, 'Y');
aso_debug_pub.add('Quote category code = ' || p_qte_header_rec.quote_category_code, 2, 'N');
aso_debug_pub.add('order type id = ' || p_qte_header_rec.order_type_id, 2, 'N');
END IF;

    IF (p_qte_header_rec.order_type_id IS NOT NULL AND p_qte_header_rec.order_type_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Order_Type(p_qte_header_rec.order_type_id);
	    FETCH C_Order_Type INTO l_order_category_code, l_start_date, l_end_date;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_Quote category code = ' || l_order_category_code , 2, 'N');
aso_debug_pub.add('start date= ' || l_start_date, 2, 'N');
aso_debug_pub.add('end date  = ' || l_end_date, 2, 'N');
END IF;

        IF (C_Order_Type%NOTFOUND OR
    	    (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
				 NVL(l_end_date, sysdate))) THEN
	        CLOSE C_Order_Type;
	        x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'ORDER_TYPE_ID', FALSE);
                FND_MSG_PUB.ADD;
    	    END IF;
        ELSE
            IF (p_qte_header_rec.quote_category_code IS NULL OR
                p_qte_header_rec.quote_category_code = FND_API.G_MISS_CHAR) THEN
                    p_qte_header_rec.quote_category_code := l_order_category_code;

            ELSE
                IF (p_qte_header_rec.quote_category_code <> l_order_category_code) THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                   FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                       FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_CATEGORY_CODE', FALSE);
                       FND_MSG_PUB.ADD;
    	            END IF;
                END IF;
            END IF;
	    CLOSE C_Order_Type;

	END IF;
    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Quote category code = ' || p_qte_header_rec.quote_category_code, 2, 'N');
aso_debug_pub.add('order type id = ' || p_qte_header_rec.order_type_id, 2, 'N');
END IF;

END OrderType;


PROCEDURE LineType(
	p_init_msg_list		IN	VARCHAR2,
    p_qte_header_rec	IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_qte_line_rec	    IN OUT NOCOPY  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
/*
 * 2633507 - hyang: use oe_transaction_types_all instead of aso_i_line_types_v
 */

    CURSOR C_Order_Line_Type(l_order_line_type_id NUMBER) IS
	SELECT order_category_code, start_date_active, end_date_active
	--FROM OE_TRANSACTION_TYPES_ALL  Commented Code yogeshwar (MOAC)
	FROM	OE_TRANSACTION_TYPES_VL  --New Code Yogeshwar (MOAC)
	WHERE transaction_type_id = l_order_line_type_id
	and Transaction_type_code = 'LINE' ;
	--Commented Code Start Yogeshwar (MOAC)
	/*
	and NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
        */
        --Commented Code End Yogeshwar (MOAC)

    l_line_category_code    VARCHAR2(30);
    l_start_date	DATE;
    l_end_date		DATE;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Entering LineType ', 2, 'Y');
aso_debug_pub.add('Line category code = ' || p_qte_line_rec.line_category_code, 2, 'N');
aso_debug_pub.add('Line Type = ' || p_qte_line_rec.order_line_type_id, 2, 'N');
END IF;

    IF (p_qte_line_rec.order_line_type_id IS NOT NULL AND p_qte_line_rec.order_line_type_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Order_Line_Type(p_qte_line_rec.order_line_type_id);
	    FETCH C_Order_Line_Type INTO l_line_category_code, l_start_date, l_end_date;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l Line category code = ' || l_line_category_code, 2, 'N');
aso_debug_pub.add('start date= ' || l_start_date, 2, 'N');
aso_debug_pub.add('start date= ' || l_start_date, 2, 'N');
END IF;
        IF (C_Order_Line_Type%NOTFOUND OR
	    (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
				 NVL(l_end_date, sysdate))) THEN
	        CLOSE C_Order_Line_Type;
	        x_return_status := FND_API.G_RET_STS_ERROR;
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('Create_Quote_lines - check line type 1', 1, 'Y');
	  END IF;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	        FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'ORDER_LINE_TYPE_ID', FALSE);
                FND_MSG_PUB.ADD;
    	    END IF;
        ELSE
            IF (p_qte_line_rec.line_category_code IS NULL OR
                p_qte_line_rec.line_category_code = FND_API.G_MISS_CHAR) THEN
                    p_qte_line_rec.line_category_code := l_line_category_code;

            ELSE
                IF (p_qte_line_rec.line_category_code <> l_line_category_code) THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                   FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                       FND_MESSAGE.Set_Token('COLUMN', 'LINE_CATEGORY_CODE', FALSE);
                       FND_MSG_PUB.ADD;
    	            END IF;
                END IF;
        	    CLOSE C_Order_Line_Type;
	         END IF;
        END IF;
   ELSE -- order_line_type_id is null
        IF ((p_qte_line_rec.line_category_code IS NULL OR
            p_qte_line_rec.line_category_code = FND_API.G_MISS_CHAR)
		  AND p_qte_line_rec.operation_code = 'CREATE') THEN
                p_qte_line_rec.line_category_code := 'ORDER';
        END IF;
   END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Line category code = ' || p_qte_line_rec.line_category_code, 2, 'N');
aso_debug_pub.add('Line Type = ' || p_qte_line_rec.order_line_type_id, 2, 'N');
END IF;
END LineType;


PROCEDURE Add_Lines_from_InstallBase(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec         IN   ASO_QUOTE_PUB.Control_Rec_Type
                         := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
                         := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_instance_tbl        IN   ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type
					:= ASO_QUOTE_HEADERS_PVT.G_MISS_Instance_Tbl,
    X_Qte_Header_Rec      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Line_Tbl        OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_ln_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */    VARCHAR2
)

IS


  /*
   *  2611381: using base table instead of vl view
   */
  CURSOR C_Get_Item_Details(l_instance_id NUMBER, l_organization_id NUMBER) IS
   SELECT a.inventory_item_id, a.quantity, a.unit_of_measure,
          a.last_oe_order_line_id, b.bom_item_type, b.returnable_flag
   FROM CSI_ITEM_INSTANCES a, MTL_SYSTEM_ITEMS_B b
   WHERE a.inventory_item_id = b.inventory_item_id
   AND a.instance_id = l_instance_id
   AND b.organization_id = l_organization_id;

  CURSOR C_Get_Children(l_instance_id NUMBER) IS
   SELECT subject_id
   FROM CSI_II_RELATIONSHIPS
   WHERE relationship_type_code='COMPONENT-OF'
   START WITH object_id = l_instance_id
   CONNECT BY object_id = prior subject_id;

  CURSOR C_Ln_Dtl_Instances(l_instance_id NUMBER, l_header_id NUMBER) IS
   SELECT 'Y'
   FROM ASO_QUOTE_LINES_ALL a, ASO_QUOTE_LINE_DETAILS b
   WHERE a.quote_line_id = b.quote_line_id
   AND a.quote_header_id = l_header_id
   AND b.instance_id = l_instance_id;

  CURSOR C_Get_Order_Header(l_line_id NUMBER) IS
   SELECT header_id
   FROM OE_ORDER_LINES_ALL
   WHERE line_id = l_line_id;

  CURSOR C_Get_Header_Org(l_header_id NUMBER) IS
   SELECT org_id
   FROM ASO_QUOTE_HEADERS_ALL
   WHERE quote_header_id = l_header_id;

   l_Cur_Inst                C_Get_Item_Details%ROWTYPE;
   l_Cur_Child               C_Get_Item_Details%ROWTYPE;
   l_used_inst_tbl           ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type
                             := ASO_QUOTE_HEADERS_PVT.G_MISS_Instance_Tbl;

   l_qte_line_tbl            ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
   l_qte_line_dtl_tbl        ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
   l_ln_shipment_tbl	    ASO_QUOTE_PUB.Shipment_Tbl_Type;
   lx_hd_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   lx_hd_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
   lx_hd_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
   lx_hd_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
   lx_hd_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
   lX_hd_Attr_Ext_Tbl        ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
   lx_Line_Attr_Ext_Tbl      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
   lx_line_rltship_tbl       ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
   lx_Price_Adjustment_Tbl   ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
   lx_Price_Adj_Attr_Tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
   lx_price_adj_rltship_tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
   lx_hd_Sales_Credit_Tbl    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
   lx_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
   lX_Ln_Sales_Credit_Tbl    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
   lX_Ln_Quote_Party_Tbl     ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
   lx_ln_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   lx_ln_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
   lx_ln_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
   lx_ln_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
   lx_ln_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

   l_used                    VARCHAR2(1);
   j                         NUMBER := 0;
   l_org_id                  NUMBER;
   l_ord_hdr                 NUMBER;
   l_top_model_index         NUMBER;

   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_api_name                CONSTANT VARCHAR2(45) := 'Add_Lines_from_InstallBase';
-- 2929469
   l_organization_id         NUMBER;

   l_control_rec  ASO_QUOTE_PUB.Control_Rec_Type := p_control_rec;
   l_prof_val varchar2(240);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Add_Lines_from_InstallBase_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
			 		                  p_api_version_number,
					                  l_api_name,
					                  G_PKG_NAME) THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
	     FND_MSG_PUB.initialize;
      END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Add_Lines_from_InstallBase - Begin ', 1, 'Y');
	 END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_qte_header_rec.org_id IS NULL OR
        p_qte_header_rec.org_id = FND_API.G_MISS_NUM THEN

         OPEN C_Get_Header_Org(p_qte_header_rec.quote_header_id);
         FETCH C_Get_Header_Org INTO l_org_id;
         CLOSE C_Get_Header_Org;
     ELSE
         l_org_id := p_qte_header_rec.org_id;
     END IF;

     l_organization_id := oe_profile.value('OE_ORGANIZATION_ID', l_org_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - l_org_id '||l_org_id, 1, 'N');
aso_debug_pub.add('Add_Lines_from_InstallBase - l_organization_id '||l_organization_id, 1, 'N');
aso_debug_pub.add('Add_Lines_from_InstallBase - P_instance_tbl.count '||P_instance_tbl.count, 1, 'N');
END IF;

	FOR i IN 1..P_instance_tbl.count LOOP

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - P_Instance_Tbl(i).Instance_Id: '||P_Instance_Tbl(i).Instance_Id, 1, 'N');
END IF;

         l_used := 'N';
         OPEN C_Ln_Dtl_Instances(P_Instance_Tbl(i).Instance_Id, P_Qte_Header_Rec.quote_header_id);
         FETCH C_Ln_Dtl_Instances INTO l_used;
         CLOSE C_Ln_Dtl_Instances;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - exists in quote: '||l_used, 1, 'N');
END IF;

         IF l_used = 'N' THEN

             FOR k IN 1..l_used_inst_tbl.count LOOP
                 IF l_used_inst_tbl(k).Instance_Id = P_Instance_Tbl(i).Instance_Id THEN
                     l_used := 'Y';
                     EXIT;
                 END IF;
             END LOOP;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - already in quote: '||l_used, 1, 'N');
END IF;

         END IF;

         IF l_used = 'N' THEN

             l_used_inst_tbl(l_used_inst_tbl.count+1).Instance_Id := P_Instance_Tbl(i).Instance_Id;

             OPEN C_Get_Item_Details(P_instance_tbl(i).Instance_Id, l_organization_id);
             FETCH C_Get_Item_Details INTO l_Cur_Inst;

             IF C_Get_Item_Details%NOTFOUND THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - Invalid instance: ', 1, 'N');
END IF;

                 CLOSE C_Get_Item_Details;
                 x_return_status := FND_API.G_RET_STS_ERROR;

                 FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INSTANCE');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;

             END IF;

             CLOSE C_Get_Item_Details;

             IF NVL(l_Cur_Inst.Returnable_Flag, 'Y') <> 'Y' THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - Not Returnable instance: ', 1, 'N');
END IF;

                 x_return_status := FND_API.G_RET_STS_ERROR;

                 FND_MESSAGE.Set_Name('ASO', 'ASO_NOT_RETURNABLE');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;

             ELSE

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Inst.Inventory_Item_Id: '||l_Cur_Inst.Inventory_Item_Id, 1, 'N');
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Inst.Quantity: '||l_Cur_Inst.Quantity, 1, 'N');
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Inst.Unit_Of_Measure: '||l_Cur_Inst.Unit_Of_Measure, 1, 'N');
END IF;

                 j := j + 1;
                 l_qte_line_tbl(j).quote_header_id := p_qte_header_rec.quote_header_id;
                 l_qte_line_tbl(j).inventory_item_id := l_Cur_Inst.Inventory_Item_Id;
                 l_qte_line_tbl(j).organization_id := l_organization_id;
                 l_qte_line_tbl(j).Quantity := l_Cur_Inst.Quantity;
                 l_qte_line_tbl(j).UOM_Code := l_Cur_Inst.Unit_Of_Measure;
                 l_qte_line_tbl(j).Line_Category_Code := 'RETURN';
                 l_qte_line_tbl(j).Operation_Code := 'CREATE';
			  IF P_Instance_Tbl(i).Price_List_Id <> FND_API.G_MISS_NUM AND
				P_Instance_Tbl(i).Price_List_Id IS NOT NULL THEN
                     l_qte_line_tbl(j).Price_List_Id := P_Instance_Tbl(i).Price_List_Id;
                 ELSE
				 l_qte_line_tbl(j).Price_List_Id := FND_API.G_MISS_NUM;
                 END IF;
/*
                 IF l_Cur_Inst.last_oe_order_line_id IS NOT NULL THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Inst.last_oe_order_line_id: '||l_Cur_Inst.last_oe_order_line_id, 1, 'N');
END IF;

                     OPEN C_Get_Order_Header(l_Cur_Inst.last_oe_order_line_id);
                     FETCH C_Get_Order_Header INTO l_ord_hdr;
                     CLOSE C_Get_Order_Header;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - referenced ord hdr: '||l_ord_hdr, 1, 'N');
END IF;

                     l_qte_line_dtl_tbl(j).return_ref_type := 'ORDER';
                     l_qte_line_dtl_tbl(j).return_ref_header_id := l_ord_hdr;
                     l_qte_line_dtl_tbl(j).return_ref_line_id := l_Cur_Inst.last_oe_order_line_id;
                     l_qte_line_dtl_tbl(j).return_attribute1 := l_ord_hdr;
                     l_qte_line_dtl_tbl(j).return_attribute2 := l_Cur_Inst.last_oe_order_line_id;

                 END IF;
*/
                 l_qte_line_dtl_tbl(j).instance_id := P_Instance_Tbl(i).Instance_Id;
                 l_qte_line_dtl_tbl(j).Operation_Code := 'CREATE';
                 l_qte_line_dtl_tbl(j).qte_line_index := j;

                 l_ln_shipment_tbl(j).qte_line_index := j;

                 IF l_Cur_Inst.BOM_Item_Type = 1 THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - model ', 1, 'N');
END IF;

                     l_qte_line_dtl_tbl(j).ref_type_code :='TOP_MODEL';
                     l_top_model_index := j;

                     FOR Inst_Children IN C_Get_Children(P_Instance_Tbl(i).Instance_Id) LOOP

                         l_used := 'N';
                         OPEN C_Ln_Dtl_Instances(Inst_Children.Subject_Id, P_Qte_Header_Rec.quote_header_id);
                         FETCH C_Ln_Dtl_Instances INTO l_used;
                         CLOSE C_Ln_Dtl_Instances;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - exists in quote: '||l_used, 1, 'N');
END IF;

                         FOR k IN 1..l_used_inst_tbl.count LOOP
                             IF l_used_inst_tbl(k).Instance_Id = Inst_Children.Subject_Id THEN
                                 l_used := 'Y';
                                 EXIT;
                              END IF;
                         END LOOP;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - already in quote: '||l_used, 1, 'N');
END IF;

                         IF l_used = 'N' THEN

                             l_used_inst_tbl(l_used_inst_tbl.count+1).Instance_Id := Inst_Children.Subject_Id;

                             OPEN C_Get_Item_Details(Inst_Children.Subject_Id, l_organization_id);
                             FETCH C_Get_Item_Details INTO l_Cur_Child;

                             IF C_Get_Item_Details%NOTFOUND THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - Invalid child instance: ', 1, 'N');
END IF;

                                 CLOSE C_Get_Item_Details;
                                 x_return_status := FND_API.G_RET_STS_ERROR;

                                 FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INSTANCE');
                                 FND_MSG_PUB.ADD;
                                 RAISE FND_API.G_EXC_ERROR;

                             END IF;

                             CLOSE C_Get_Item_Details;

                             IF NVL(l_Cur_Child.Returnable_Flag, 'Y') = 'Y' THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Child.Inventory_Item_Id: '||l_Cur_Child.Inventory_Item_Id, 1, 'N');
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Child.Quantity: '||l_Cur_Child.Quantity, 1, 'N');
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Child.Unit_Of_Measure: '||l_Cur_Child.Unit_Of_Measure, 1, 'N');
END IF;

                                 j := j + 1;
                                 l_qte_line_tbl(j).quote_header_id := p_qte_header_rec.quote_header_id;
                                 l_qte_line_tbl(j).inventory_item_id := l_Cur_Child.Inventory_Item_Id;
                                 l_qte_line_tbl(j).organization_id := l_organization_id;
                                 l_qte_line_tbl(j).Quantity := l_Cur_Child.Quantity;
                                 l_qte_line_tbl(j).UOM_Code := l_Cur_Child.Unit_Of_Measure;
                                 l_qte_line_tbl(j).Line_Category_Code := 'RETURN';
                                 l_qte_line_tbl(j).Operation_Code := 'CREATE';
                                 IF P_Instance_Tbl(i).Price_List_Id <> FND_API.G_MISS_NUM AND
                                    P_Instance_Tbl(i).Price_List_Id IS NOT NULL THEN
                                     l_qte_line_tbl(j).Price_List_Id := P_Instance_Tbl(i).Price_List_Id;
                                 ELSE
                                     l_qte_line_tbl(j).Price_List_Id := FND_API.G_MISS_NUM;
                                 END IF;

                                 l_qte_line_tbl(j).Price_List_Id := P_Instance_Tbl(i).Price_List_Id;
/*
                                 IF l_Cur_Child.last_oe_order_line_id IS NOT NULL THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - l_Cur_Inst.last_oe_order_line_id: '||l_Cur_Inst.last_oe_order_line_id, 1, 'N');
END IF;

                                     OPEN C_Get_Order_Header(l_Cur_Child.last_oe_order_line_id);
                                     FETCH C_Get_Order_Header INTO l_ord_hdr;
                                     CLOSE C_Get_Order_Header;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - referenced ord hdr: '||l_ord_hdr, 1, 'N');
END IF:

                                     l_qte_line_dtl_tbl(j).return_ref_type := 'ORDER';
                                     l_qte_line_dtl_tbl(j).return_ref_header_id := l_ord_hdr;
                                     l_qte_line_dtl_tbl(j).return_ref_line_id := l_Cur_Child.last_oe_order_line_id;
                                     l_qte_line_dtl_tbl(j).return_attribute1 := l_ord_hdr;
                                     l_qte_line_dtl_tbl(j).return_attribute2 := l_Cur_Child.last_oe_order_line_id;

                                 END IF;
*/
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - Inst_Children.Subject_Id: '||Inst_Children.Subject_Id, 1, 'N');
END IF;

                                 l_qte_line_dtl_tbl(j).instance_id := Inst_Children.Subject_Id;
                                 l_qte_line_dtl_tbl(j).Operation_Code := 'CREATE';
                                 l_qte_line_dtl_tbl(j).qte_line_index := j;

                                 l_qte_line_dtl_tbl(j).ref_type_code :='TOP_MODEL';
                                 l_qte_line_dtl_tbl(j).ref_line_index := l_top_model_index;

                                 l_ln_shipment_tbl(j).qte_line_index := j;

                             END IF;

                         END IF;  -- used = N

                     END LOOP;  -- Inst_Children

                 END IF;

             END IF;  -- Returnable

         END IF; -- used = N

     END LOOP;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('p_qte_header_rec.last_update_date = '||
                to_char(p_qte_header_rec.last_update_date,'DD-MM-YYYY HH:MI:SS'),1,'N');
aso_debug_pub.add('l_Qte_line_tbl.count = '|| l_Qte_line_tbl.count,1,'N');
END IF;


     IF j > 0 THEN

	   l_prof_val := fnd_profile.value('ASO_ENABLE_DEFAULTING_RULE');

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('l_prof_val: '|| l_prof_val,1,'N');
	   END IF;

        if l_prof_val = 'Y' then
	      l_control_rec.DEFAULTING_FWK_FLAG := 'Y';
	      l_control_rec.DEFAULTING_FLAG := FND_API.G_TRUE;
		 l_control_rec.APPLICATION_TYPE_CODE := 'QUOTING HTML';
        else
	      l_control_rec.DEFAULTING_FWK_FLAG := 'N';
	      l_control_rec.DEFAULTING_FLAG := FND_API.G_FALSE;
	   end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - calling ASO_QUOTE_PUB.Update_Quote: ', 1, 'N');
END IF;

       ASO_QUOTE_PUB.Update_Quote(
          p_api_version_number     => 1.0,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => p_commit,
          p_control_rec            => l_control_rec,
          p_qte_header_rec         => p_qte_header_rec,
          P_Qte_Line_Tbl           => l_Qte_Line_Tbl,
          P_Qte_Line_dtl_Tbl       => l_Qte_Line_dtl_Tbl,
          P_ln_Shipment_Tbl        => l_ln_shipment_tbl,
          X_Qte_Header_Rec         => x_qte_header_rec,
          X_Qte_Line_Tbl           => x_Qte_Line_Tbl,
          X_Qte_Line_Dtl_Tbl       => x_Qte_Line_Dtl_Tbl,
          X_hd_Price_Attributes_Tbl => lx_hd_Price_Attr_Tbl,
          X_hd_Payment_Tbl         => lx_hd_Payment_Tbl,
          X_hd_Shipment_Tbl        => lx_hd_Shipment_Tbl,
          X_hd_Freight_Charge_Tbl  => lx_hd_Freight_Charge_Tbl,
          X_hd_Tax_Detail_Tbl      => lx_hd_Tax_Detail_Tbl,
          X_hd_Attr_Ext_Tbl        => lX_hd_Attr_Ext_Tbl,
          X_hd_Sales_Credit_Tbl    => lx_hd_Sales_Credit_Tbl,
          X_hd_Quote_Party_Tbl     => lx_Quote_Party_Tbl,
          X_Line_Attr_Ext_Tbl      => lx_Line_Attr_Ext_Tbl,
          X_line_rltship_tbl       => lx_line_rltship_tbl,
          X_Price_Adjustment_Tbl   => lx_Price_Adjustment_Tbl,
          X_Price_Adj_Attr_Tbl     => lx_Price_Adj_Attr_Tbl,
          X_Price_Adj_Rltship_Tbl  => lx_Price_Adj_Rltship_Tbl,
          X_ln_Price_Attributes_Tbl => lx_ln_Price_Attr_Tbl,
          X_ln_Payment_Tbl         => lx_ln_Payment_Tbl,
          X_ln_Shipment_Tbl        => x_ln_Shipment_Tbl,
          X_ln_Freight_Charge_Tbl  => lx_ln_Freight_Charge_Tbl,
          X_ln_Tax_Detail_Tbl      => lx_ln_Tax_Detail_Tbl,
          X_Ln_Sales_Credit_Tbl    => lX_Ln_Sales_Credit_Tbl,
          X_Ln_Quote_Party_Tbl     => lX_Ln_Quote_Party_Tbl,
          X_Return_Status          => x_Return_Status,
          X_Msg_Count              => x_Msg_Count,
          X_Msg_Data               => x_Msg_Data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_Lines_from_InstallBase - after update_quote: x_ret_status: '||x_return_status, 1, 'N');
END IF;

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

   ELSE
     x_qte_header_rec := p_qte_header_rec;

     END IF; -- end j >0

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('x_qte_header_rec.last_update_date = '||
                to_char(x_qte_header_rec.last_update_date,'DD-MM-YYYY HH:MI:SS'),1,'N');
aso_debug_pub.add('x_Qte_line_tbl.count = '|| x_Qte_line_tbl.count,1,'N');
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

END Add_Lines_from_InstallBase;


PROCEDURE Validate_IB_Return_Qty(
            p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
            p_Qte_Line_rec       IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
            p_Qte_Line_Dtl_Tbl   IN   ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type,
  	       x_return_status	   OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
            x_msg_count		   OUT NOCOPY /* file.sql.39 change */    NUMBER,
            x_msg_data		   OUT NOCOPY /* file.sql.39 change */    VARCHAR2)

IS

CURSOR C_Get_Dtl_Info(l_line_id NUMBER) IS
 SELECT instance_id, return_ref_type, return_ref_line_id
 FROM ASO_QUOTE_LINE_DETAILS
 WHERE quote_line_id = l_line_id;

CURSOR C_Get_Qot_Qty(l_line_id NUMBER) IS
 SELECT quantity
 FROM ASO_QUOTE_LINES_ALL
 WHERE quote_line_id = l_line_id;

CURSOR C_Get_Ord_Qty(l_line_id NUMBER) IS
 SELECT ordered_quantity
 FROM OE_ORDER_LINES_ALL
 WHERE line_id = l_line_id;

CURSOR C_Get_Inst_Qty(l_inst_id NUMBER) IS
 SELECT quantity
 FROM CSI_ITEM_INSTANCES
 WHERE instance_id = l_inst_id;

CURSOR C_Get_Inst_Ret_Info(l_inst_id NUMBER) IS
 SELECT last_oe_order_line_id
 FROM CSI_ITEM_INSTANCES
 WHERE instance_id = l_inst_id;

l_qty             NUMBER;
l_qte_quantity    NUMBER;
l_inst_id         NUMBER;
l_ref_id          NUMBER;
l_ref_type        VARCHAR2(30);

BEGIN

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Entering Validate_IB_Return_Qty ', 2, 'Y');
aso_debug_pub.add('Validate_IB_Return_Qty - p_qte_line_rec.operation_code: '||p_qte_line_rec.operation_code, 1, 'N');
aso_debug_pub.add('Validate_IB_Return_Qty - p_qte_line_rec.operation_code: '||p_qte_line_rec.operation_code, 1, 'N');
aso_debug_pub.add('Validate_IB_Return_Qty - p_qte_line_rec.quantity: '||p_qte_line_rec.quantity, 1, 'N');
END IF;

 IF p_qte_line_rec.operation_code = 'UPDATE' THEN

  OPEN C_Get_Dtl_Info(p_qte_line_rec.quote_line_id);
  FETCH C_Get_Dtl_Info INTO l_inst_id, l_ref_type, l_ref_id;
  CLOSE C_Get_Dtl_Info;

  IF p_qte_line_rec.quantity IS NOT NULL AND p_qte_line_rec.quantity <> FND_API.G_MISS_NUM THEN
      l_qte_quantity := p_qte_line_rec.quantity;
  ELSE
      OPEN C_Get_Qot_Qty(p_qte_line_rec.quote_line_id);
      FETCH C_Get_Qot_Qty INTO l_qte_quantity;
      CLOSE C_Get_Qot_Qty;
  END IF;

 ELSE
  IF p_qte_line_rec.operation_code = 'CREATE' THEN
    IF p_Qte_Line_Dtl_Tbl.count > 0 THEN
      l_inst_id := p_qte_line_dtl_tbl(1).instance_id;

      IF l_inst_id IS NOT NULL THEN

        OPEN C_Get_Inst_Ret_Info(l_inst_id);
        FETCH C_Get_Inst_Ret_Info INTO l_ref_id;
        CLOSE C_Get_Inst_Ret_Info;

        IF l_ref_id IS NOT NULL THEN
          l_ref_type := 'ORDER';
        ELSE

          l_ref_type := p_qte_line_dtl_tbl(1).return_ref_type;
          l_ref_id := p_qte_line_dtl_tbl(1).return_ref_line_id;
        END IF;

      END IF;

    ELSE
	 l_inst_id := NULL;
	 l_ref_type := NULL;
	 l_ref_id := NULL;
    END IF; -- ln_dtl_tbl.count

    l_qte_quantity := p_qte_line_rec.quantity;

  END IF; -- 'CREATE'

 END IF;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Validate_IB_Return_Qty - l_inst_id: '||l_inst_id, 1, 'N');
aso_debug_pub.add('Validate_IB_Return_Qty - l_ref_type: '||l_ref_type, 1, 'N');
aso_debug_pub.add('Validate_IB_Return_Qty - l_ref_id: '||l_ref_id, 1, 'N');
aso_debug_pub.add('Validate_IB_Return_Qty - l_qte_quantity: '||l_qte_quantity, 1, 'N');
END IF;

IF l_qte_quantity IS NOT NULL AND
   l_qte_quantity <> FND_API.G_MISS_NUM THEN

 IF l_inst_id IS NOT NULL AND
    l_inst_id <> FND_API.G_MISS_NUM THEN

  IF p_qte_line_rec.line_category_code IS NOT NULL AND
      p_qte_line_rec.line_category_code <> FND_API.G_MISS_CHAR THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Validate_IB_Return_Qty - p_qte_line_rec.line_category_code: '||p_qte_line_rec.line_category_code, 1, 'N');
END IF;

      IF p_qte_line_rec.line_category_code <> 'RETURN' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_INST_RETURN_CODE');
              FND_MSG_PUB.ADD;
 	      END IF;
      END IF;
  END IF;
/*
  IF l_ref_type = 'ORDER' THEN
      IF l_ref_id IS NOT NULL AND
	    l_ref_id <> FND_API.G_MISS_NUM THEN

          OPEN C_Get_Ord_Qty(l_ref_id);
          FETCH C_Get_Ord_Qty INTO l_qty;
          CLOSE C_Get_Ord_Qty;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Validate_IB_Return_Qty - l_qty: '||l_qty, 1, 'N');
END IF;
          IF l_qty <> l_qte_quantity THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	              FND_MESSAGE.Set_Name('ASO', 'ASO_REFERENCED_RET_QTY');
                  FND_MSG_PUB.ADD;
    	      END IF;
          END IF;
       END IF;

  ELSE
*/
      OPEN C_Get_Inst_Qty(l_inst_id);
      FETCH C_Get_Inst_Qty INTO l_qty;
      CLOSE C_Get_Inst_Qty;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Validate_IB_Return_Qty - l_qty: '||l_qty, 1, 'N');
END IF;
      IF l_qty < l_qte_quantity THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_NOT_REFERENCED_RET_QTY');
              FND_MSG_PUB.ADD;
   	      END IF;
      END IF;
/*
  END IF;
*/
 END IF; -- Instance_id

END IF; -- quantity

END Validate_IB_Return_Qty;


END ASO_TRADEIN_PVT;

/
