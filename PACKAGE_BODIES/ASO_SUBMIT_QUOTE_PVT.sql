--------------------------------------------------------
--  DDL for Package Body ASO_SUBMIT_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SUBMIT_QUOTE_PVT" as
/* $Header: asovsubb.pls 120.12.12010000.6 2014/12/04 05:24:23 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_SUBMIT_QUOTE_PVT
-- Purpose         :
-- History         :
-- 09/07/2007  vidsrini --Fix for bug 5847316
--             02/01/2007     gkeshava - Fix for perf bug 5714535
-- NOTE       :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'ASO_SUBMIT_QUOTE_PVT';


-- NAME
--   Submit_Quote
--
-- PURPOSE
--   Validate the quote and quote lines,
--   If validation is successful, insert the quote and quote lines
--   to OE's interface tables. Submit a concurrent request to order
--   the quote.
--

PROCEDURE Submit_Quote
(
    P_Api_Version_Number	 IN   NUMBER,
    P_Init_Msg_List		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Commit			 IN   VARCHAR2	   := FND_API.G_FALSE,
    p_validation_level	 IN   NUMBER	   := FND_API.G_VALID_LEVEL_FULL,
    p_control_rec		 IN   ASO_QUOTE_PUB.SUBMIT_Control_Rec_Type
						             :=  ASO_QUOTE_PUB.G_MISS_SUBMIT_CONTROL_REC,
    P_Qte_Header_Rec	 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Order_Header_Rec	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Order_Header_Rec_Type,
    X_Return_Status		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count 		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */  VARCHAR2)

IS
    CURSOR C_Validate_Quote (x_qte_header_id NUMBER) IS
	SELECT 'X'
	FROM ASO_QUOTE_HEADERS_ALL
	WHERE quote_header_id = x_qte_header_id;

    CURSOR c_line_relation (x_quote_header_id NUMBER) IS
	SELECT a.LINE_RELATIONSHIP_ID, a.QUOTE_LINE_ID, a.RELATED_QUOTE_LINE_ID,
		a.RELATIONSHIP_TYPE_CODE, a.RECIPROCAL_FLAG
	FROM ASO_LINE_RELATIONSHIPS a, aso_quote_lines_all b
	WHERE  a.quote_line_id = b.quote_line_id
	and b.quote_header_id = x_quote_header_id;

    CURSOR C_Qte_Status_Id (c_status_code VARCHAR2) IS
	SELECT quote_status_id
	FROM ASO_QUOTE_STATUSES_B
	WHERE status_code = c_status_code;

    CURSOR C_Qte_Status_Trans (from_id NUMBER, to_id NUMBER) IS
	SELECT enabled_flag
	FROM ASO_QUOTE_STATUS_TRANSITIONS
	WHERE from_status_id = from_id AND to_status_id = to_id;

    CURSOR C_check_pymnt_type(qte_hdr_id NUMBER) IS
     SELECT payment_type_code
     FROM ASO_PAYMENTS
     WHERE quote_header_id = qte_hdr_id ;

    CURSOR C_payment_amount(qte_hdr_id NUMBER) IS
     SELECT nvl(total_quote_price ,0)
     FROM ASO_QUOTE_HEADERS_ALL
     WHERE quote_header_id = qte_hdr_id ;

-- 2469621 vtariker
    CURSOR C_Get_Config_Flag(qte_line_id NUMBER) IS
     SELECT complete_configuration_flag, valid_configuration_flag, instance_id
     FROM aso_quote_line_details
     WHERE quote_line_id = qte_line_id;
-- 2469621 vtariker

    CURSOR C_Get_Update_Date(qte_hdr_id NUMBER) IS
	SELECT Last_Update_Date
	FROM ASO_QUOTE_HEADERS_ALL
	WHERE Quote_Header_Id = qte_hdr_id;

    l_last_upd_date           DATE;
    l_complete_config         VARCHAR2(1);
    l_valid_config            VARCHAR2(1);
    l_instance_id             NUMBER;
    l_api_name				CONSTANT VARCHAR2(30) := 'Submit_Quote';
    l_api_version_number		CONSTANT NUMBER 	:= 1.0;
    l_return_status			VARCHAR2(1);
    l_qte_header_rec		ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_qte_header_rec		ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_out_qte_header_rec	ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_qte_line_tbl			ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_dtl_tbl	  	ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_hd_payment_tbl	  	ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_hd_payment_tbl_out	  	ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_hd_shipment_tbl	  	ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_hd_freight_charge_tbl  	ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    l_hd_tax_detail_tbl	  	ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    l_hd_Price_Attr_Tbl	  	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_hd_Price_Adj_Tbl	  	ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    l_hd_Price_Adj_Attr_Tbl   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    l_hd_Price_Adj_Rltship_tbl ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
   -- l_hd_sales_credit_tbl	ASO_ORDER_INT.Sales_credit_tbl_type;
    l_ln_payment_tbl	  	ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_ln_shipment_tbl	  	ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_ln_freight_charge_tbl	ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    l_ln_tax_detail_tbl	  	ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    l_ln_Price_Attr_Tbl	  	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_ln_Price_Adj_Rltship_tbl	ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
    l_ln_Price_Adj_Tbl	  	ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    l_ln_Price_Adj_Attr_Tbl	ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    l_Line_Attr_Ext_Tbl		ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    l_line_rltship_tbl	  	ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
   -- l_LN_sales_credit_tbl	ASO_ORDER_INT.Sales_credit_tbl_type;
    l_tmp_qte_line_dtl_tbl	ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_tmp_Line_Attr_Ext_Tbl	ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    l_tmp_payment_tbl	  	ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_tmp_shipment_tbl	  	ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_tmp_freight_charge_tbl	ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    l_tmp_tax_detail_tbl	  	ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    l_tmp_Price_Attr_Tbl	  	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_tmp_Price_Adj_Tbl	  	ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

    l_order_control_rec	  ASO_ORDER_INT.CONTROL_REC_TYPE;
    lx_order_header_rec	  ASO_ORDER_INT.Order_Header_Rec_Type;
    lx_order_line_tbl	  ASO_ORDER_INT.Order_Line_Tbl_Type;

    l_qte_line_rec			ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_shipment_rec	  		ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_hd_sales_credit_tbl     ASO_QUOTE_PUB.Sales_Credit_tbl_Type;
    l_ln_sales_credit_tbl     ASO_QUOTE_PUB.Sales_Credit_tbl_Type;
    l_tmp_sales_credit_tbl    ASO_QUOTE_PUB.Sales_Credit_tbl_Type;
    l_hd_quote_party_tbl      ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type;
    l_ln_quote_party_tbl      ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type;
    l_tmp_quote_party_tbl     ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type;
    l_Header_ATTRIBS_EXT_Tbl  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    l_Lot_Serial_Tbl          ASO_QUOTE_PUB.Lot_Serial_Tbl_Type   ;
    l_qte_line_id			NUMBER;
    l_qte_status_id			NUMBER;
    l_val			  		VARCHAR2(1);
    l_enabled_flag		  	VARCHAR2(1);
    l_index				NUMBER;
    l_quan_reserved			NUMBER;
    l_reservation_id		NUMBER;
    l_related_obj_id		NUMBER;
    l_related_obj_rec		ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type;
    count_rel                 NUMBER := 1;
    l_payment_type_code 		VARCHAR2(30);
    l_payment_amount 		NUMBER ;

	x_current_state          NUMBER;
--	lx_return_status		VARCHAR2(1);  -- 1966456
/** Bug# 4045135. Removing this check since deferred scheduling may book orders at a later stage.
	l_book_flag			VARCHAR2(1);
**/
     l_sales_team_prof        VARCHAR2(30) := FND_PROFILE.value('ASO_AUTO_TEAM_ASSIGN');
     l_sales_cred_prof        VARCHAR2(50) := FND_PROFILE.value('ASO_AUTO_SALES_CREDIT');

     l_Sales_Alloc_Control_Rec ASO_QUOTE_PUB.SALES_ALLOC_CONTROL_REC_TYPE
                                := ASO_QUOTE_PUB.G_MISS_SALES_ALLOC_CONTROL_REC;

-- Change START
-- Release 12 MOAC Changes : Bug 4500739
-- Changes Done by : Girish
-- Comments : Changed the reference from ASO_I_OE_ORDER_HEADERS_V to OE_ORDER_HEADERS_V
/** Bug# 4045135. Removing this check since deferred scheduling may book orders at a later stage.
    CURSOR C_book_flag IS
     SELECT booked_flag
     FROM OE_ORDER_HEADERS_V
     WHERE  header_id = lx_order_header_rec.order_header_id;
**/
-- Change END

    l_om_defaulting_prof      VARCHAR2(2) := FND_PROFILE.Value('ASO_OM_DEFAULTING');

    lx_status VARCHAR2(1);  -- 2692785

    l_index_rlt               NUMBER; -- pbh/prg
    l_tmp_Price_Adj_Rltship_tbl    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

    l_istore_source          VARCHAR2(1) := 'N';
    l_status                 VARCHAR2(1) := 'S';

    l_frm_istore             VARCHAR2(1) := 'N'; -- bug 20124165
    l_quote_source_code      varchar2(240);  -- bug 20124165

     -- ER 3177722
    l_order_status_prof     varchar2(10);
    l_mdl_count             number:=0;
    lx_config_tbl           ASO_QUOTE_PUB.Config_Vaild_Tbl_Type;
    l_Update_Allowed_Flg    varchar2(1):='F';
    l_ct_invalid            number:=0;
    l_ct_changed            number:=0;
    l_warning_config_exception EXCEPTION;

    CURSOR C_Check_Qte_Status (l_qte_hdr NUMBER) IS
     SELECT 'Y'
     FROM ASO_QUOTE_HEADERS_ALL A, ASO_QUOTE_STATUSES_B B
     WHERE A.Quote_Header_Id = l_qte_hdr
     AND A.Quote_Status_Id = B.Quote_Status_Id
     AND B.Status_Code = 'STORE DRAFT';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT	SUBMIT_QUOTE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					   p_api_version_number,
    	    	    	    	    	   l_api_name,
			    	    	   G_PKG_NAME) THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
	  FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	  FND_MESSAGE.Set_Name('ASO', 'Copy Quote API: Start');
	  FND_MSG_PUB.Add;
      END IF;

      --Procedure added by Anoop Rajan on 30/09/2005 to print login details
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Before call to printing login info details', 1, 'Y');
		ASO_UTILITY_PVT.print_login_info;
		aso_debug_pub.add('After call to printing login info details', 1, 'Y');
      END IF;

      -- Change Done By Girish
      -- Procedure added to validate the operating unit
      ASO_VALIDATE_PVT.VALIDATE_OU(P_Qte_Header_Rec);


      --  Initialize API return status to success
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'UT_CANNOT_GET_PROFILE_VALUE');
    	      FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
	      FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- ******************************************************************

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Submit_Q: Begin ', 1, 'N');
	aso_debug_pub.add('l_om_defaulting_prof: '||l_om_defaulting_prof,1,'N');
	END IF;

-- vtariker - Check Whether record has been changed
     OPEN C_Get_Update_Date(P_Qte_Header_Rec.Quote_Header_Id);
	FETCH C_Get_Update_Date INTO l_last_upd_date;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Submit_Q: l_last_upd_date: '||l_last_upd_date, 1, 'N');
     aso_debug_pub.add('Submit_Q: p_qte_header_rec.last_update_date: '||p_qte_header_rec.last_update_date, 1, 'N');
     END IF;

	IF (C_Get_Update_Date%NOTFOUND) OR
        (l_last_upd_date IS NULL OR l_last_upd_date = FND_API.G_MISS_DATE) THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
	      FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
	      FND_MSG_PUB.ADD;
	  END IF;
       CLOSE C_Get_Update_Date;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	CLOSE C_Get_Update_Date;

     IF (p_qte_header_rec.last_update_date IS NOT NULL AND
         p_qte_header_rec.last_update_date <> FND_API.G_MISS_DATE) AND
        (l_last_upd_date <> p_qte_header_rec.last_update_date) Then
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
	      FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
	      FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
     END IF;
-- vtariker - Check Whether record has been changed

-- 2692785
    ASO_CONC_REQ_INT.Lock_Exists(
      p_quote_header_id => p_qte_header_rec.quote_header_id,
      x_status          => lx_status);

    IF (lx_status = FND_API.G_TRUE) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
-- 2692785


      IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN
	  OPEN C_Validate_Quote (p_qte_header_rec.quote_header_id);
	  FETCH C_Validate_Quote into l_val;
	  IF C_Validate_Quote%NOTFOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
		  FND_MESSAGE.Set_Token('COLUMN', 'ORIGINAL_QUOTE_ID', FALSE);
		  FND_MESSAGE.Set_Token('VALUE', TO_CHAR(p_qte_header_rec.quote_header_id), FALSE);
		  FND_MSG_PUB.ADD;
	      END IF;
	      CLOSE C_Validate_Quote;
	      RAISE FND_API.G_EXC_ERROR;
	  END IF;
	  CLOSE C_Validate_Quote;
      END IF;

    -- vtariker
      -- assign the missing customer accounts to the quote
      ASO_CHECK_TCA_PVT.Assign_Customer_Accounts (
        p_init_msg_list              => fnd_api.g_false,
        p_qte_header_id              => p_qte_header_rec.quote_header_id,
        p_calling_api_flag           => 2,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
    );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    -- vtariker

   l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_rec.quote_header_id);

  -- hyang new okc
    IF p_qte_header_rec.Customer_Name_And_Title <> FND_API.G_MISS_CHAR
    THEN
      l_qte_header_rec.Customer_Name_And_Title := p_qte_header_rec.Customer_Name_And_Title;
    END IF;

    IF p_qte_header_rec.Customer_Signature_Date <> FND_API.G_MISS_DATE
    THEN
      l_qte_header_rec.Customer_Signature_Date := p_qte_header_rec.Customer_Signature_Date;
    END IF;

    IF p_qte_header_rec.Supplier_Name_And_Title <> FND_API.G_MISS_CHAR
    THEN
      l_qte_header_rec.Supplier_Name_And_Title := p_qte_header_rec.Supplier_Name_And_Title;
    END IF;

    IF p_qte_header_rec.Supplier_Signature_Date <> FND_API.G_MISS_DATE
    THEN
      l_qte_header_rec.Supplier_Signature_Date := p_qte_header_rec.Supplier_Signature_Date;
    END IF;

    /* contract_template_id is not stored in database. It should always be set to the value
     * as passed.
     */
    l_qte_header_rec.Contract_Template_ID := p_qte_header_rec.Contract_Template_ID;

  -- end of hyang new okc

-- rahsan 2269789

        ASO_VALIDATE_PVT.Validate_Quote_Exp_date(
            p_init_msg_list         => FND_API.G_FALSE,
            p_quote_expiration_date => l_qte_header_rec.quote_expiration_date,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
        );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_SUB_EXPIRATION_DATE');
                FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

--  end rahsan 2269789


   IF (NVL(l_om_defaulting_prof, 'N') = 'Y') THEN
	IF l_qte_header_rec.contract_id is null then
	   l_qte_header_rec.contract_id := FND_API.G_MISS_NUM;
     end if;
	IF l_qte_header_rec.quote_category_code is null then
	   l_qte_header_rec.quote_category_code := FND_API.G_MISS_CHAR;
     end if;
	IF l_qte_header_rec.accounting_rule_id is null then
	   l_qte_header_rec.accounting_rule_id := FND_API.G_MISS_NUM;
     end if;
	IF l_qte_header_rec.invoicing_rule_id is null then
	   l_qte_header_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
     end if;
   end if;

-- hyang quote_status
    OPEN c_qte_status_id ('ORDER SUBMITTED');
    FETCH c_qte_status_id INTO l_qte_status_id;
    CLOSE c_qte_status_id;

	  ASO_VALIDATE_PVT.Validate_Status_Transition(
  		p_init_msg_list	    => FND_API.G_FALSE,
  		p_source_status_id  => l_qte_header_rec.quote_status_id,
  		p_dest_status_id    => l_qte_status_id,
  		x_return_status     => x_return_status,
  		x_msg_count	        => x_msg_count,
  		x_msg_data	        => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	    IF l_qte_header_rec.quote_status_id = l_qte_status_id then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_ORDERED_STATUS_TRANS');
           FND_MSG_PUB.ADD;
	     END IF;
         END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Submit_Q: After validate_status_transition: ORDER SUBMITEED ', 1, 'N');
    END IF;
-- end of hyang quote_status

    FOR count_main in c_line_relation(p_qte_header_rec.quote_header_id) LOOP
         l_line_rltship_tbl(count_rel).LINE_RELATIONSHIP_ID
				:= count_main.LINE_RELATIONSHIP_ID;
         l_line_rltship_tbl(count_rel).QUOTE_LINE_ID
				:= count_main.QUOTE_LINE_ID;
         l_line_rltship_tbl(count_rel).RELATED_QUOTE_LINE_ID
				:= count_main.RELATED_QUOTE_LINE_ID;
         l_line_rltship_tbl(count_rel).RELATIONSHIP_TYPE_CODE
				:= count_main.RELATIONSHIP_TYPE_CODE;
         l_line_rltship_tbl(count_rel).RECIPROCAL_FLAG
				:= count_main.RECIPROCAL_FLAG;
    		count_rel := count_rel+1;
     END LOOP;


      l_hd_price_adj_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Price_Adj_Hdr_Rows(
		p_qte_header_id => p_qte_header_rec.quote_header_id,
		p_qte_line_id	=> NULL);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After hd_price_adj_tbl ', 1, 'N');
aso_debug_pub.add('Submit_Q: After l_hd_price_adj_tbl.count: '||l_hd_price_adj_tbl.count, 1, 'N');
END IF;

-- pbh/prg
      l_hd_Price_Adj_Attr_Tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows(
          p_price_adj_tbl => l_hd_price_adj_tbl);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('vtariker: After l_hd_Price_Adj_Attr_Tbl.count: '||l_hd_Price_Adj_Attr_Tbl.count, 1, 'N');
END IF;
-- pbh/prg

      l_hd_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(
		p_qte_header_id => p_qte_header_rec.quote_header_id,
		p_qte_line_id	=> NULL);

      l_Header_ATTRIBS_EXT_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_header_Rows(
		P_Qte_header_Id	=> p_qte_header_rec.quote_header_id);

      l_hd_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(
		p_qte_header_id => p_qte_header_rec.quote_header_id,
		p_qte_line_id	=> NULL);

      FOR i in 1..l_hd_payment_tbl.count LOOP
           IF (l_hd_payment_tbl(i).payment_amount is NULL OR
              l_hd_payment_tbl(i).payment_amount = FND_API.G_MISS_NUM) AND
		    (l_hd_payment_tbl(i).payment_type_code IS NOT NULL AND
		    l_hd_payment_tbl(i).payment_type_code <> FND_API.G_MISS_CHAR) THEN
                l_hd_payment_tbl(i).payment_amount :=
                                       l_qte_header_rec.total_quote_price;
           END IF;
      END LOOP;

      l_hd_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows(
		p_qte_header_id => p_qte_header_rec.quote_header_id,
		p_qte_line_id	=> NULL,
		p_shipment_tbl	=> ASO_QUOTE_PUB.g_miss_shipment_tbl);

      l_hd_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(
		p_qte_header_id => p_qte_header_rec.quote_header_id,
		p_qte_line_id	=> NULL);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After hd_shipment_tbl init ', 1, 'N');
END IF;

      l_hd_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows(
                         		P_Shipment_Tbl => l_hd_shipment_tbl);

      l_hd_sales_credit_tbl   := ASO_UTILITY_PVT.Query_Sales_Credit_Row (
							p_qte_header_id => p_qte_header_rec.quote_header_id,
                                  	p_qte_line_id	=> NULL);

      l_hd_quote_party_tbl  := ASO_UTILITY_PVT.Query_Quote_Party_Row (
							P_Qte_header_Id => p_qte_header_rec.quote_header_id,
                                   p_qte_line_id	=> NULL) ;


/* Start : Code Change done for Bug 13391823 */
aso_debug_pub.add('Submit_Quote - P_Control_Rec.application_type_code : '  || P_Control_Rec.application_type_code,1,'N');

if (P_Control_Rec.application_type_code=FND_API.G_MISS_CHAR) then -- bug 20124165
   select quote_source_code into l_quote_source_code
   from aso_quote_headers_all
   where quote_header_id=p_qte_header_rec.quote_header_id;

   if (upper(l_quote_source_code) like 'ISTORE%') then
       l_frm_istore:='Y';
    else
      l_frm_istore:='N';
   end if;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Submit_Quote - l_frm_istore: '||l_frm_istore, 1, 'N');
   END IF;

end if;

If (P_Control_Rec.application_type_code <> 'QUOTING FORM') and  (l_frm_istore='N')Then

/* End : Code Change done for Bug 13391823 */

/* ER 3177722 */
        l_order_status_prof:=fnd_profile.value('ASO_DEFAULT_ORDER_STATE');
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Submit_Quote - l_order_status_prof: '||l_order_status_prof, 1, 'N');
	END IF;
	if l_order_status_prof='ENTERED' then
            select count(*) into l_mdl_count
	     from aso_Quote_lines_all
	     where quote_header_id=p_qte_header_rec.quote_header_id
	     and item_type_code='MDL';
	      IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Submit_Quote - mdl.count: '||to_char(l_mdl_count), 1, 'N');
	      END IF;

	       if l_mdl_count>0 then

                  -- Checking whether the quote is updatable or not
			select decode(update_allowed_flag,'Y','T','F') into l_Update_Allowed_Flg
			from aso_quote_statuses_vl
			where QUOTE_STATUS_ID = l_qte_header_rec.quote_status_id;

			if l_Update_Allowed_Flg='F' then
				if NVL(FND_PROFILE.VALUE('ASO_STATUS_OVERRIDE'),'N') = 'Y' THEN
					l_Update_Allowed_Flg := 'T';
			end if;
		      end if;-- l_update_allowed_flag



			IF aso_debug_pub.g_debug_flag = 'Y' THEN
				aso_debug_pub.add('Submit_Quote - l_Update_Allowed_Flg:  '||l_Update_Allowed_Flg, 1, 'N');

			END IF;
			ASO_QUOTE_PUB.validate_model_configuration
			(
			P_Api_Version_Number  => 1.0,
			P_Init_Msg_List       => FND_API.G_FALSE,
			P_Commit              =>  FND_API.G_FALSE,
                        P_Quote_header_id     =>p_qte_header_rec.quote_header_id,
			P_UPDATE_QUOTE        =>l_Update_Allowed_Flg,
			P_CONFIG_EFFECTIVE_DATE      => FND_API.G_MISS_DATE,
			P_CONFIG_model_lookup_DATE   => FND_API.G_MISS_DATE,
			X_Config_tbl          => lx_config_tbl,
			X_Return_Status       => x_return_status,
			X_Msg_Count           => x_msg_count,
			X_Msg_Data            => x_msg_data
                       );

                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Submit_Quote -After  ASO_QUOTE_PUB.validate_model_configuration return status:  '||X_Return_Status, 1, 'N');
		    END IF;

		    if (X_Return_Status = FND_API.G_RET_STS_SUCCESS) and (lx_config_tbl.count>0) then

                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Submit_Quote -After  ASO_QUOTE_PUB.validate_model_configuration sucess lx_config_tbl:  '||lx_config_tbl.count, 1, 'N');
		      END IF;
		      l_ct_invalid:=0;
		      l_ct_changed:=0;
                      for i in 1..lx_config_tbl.count loop
		       if lx_config_tbl(i).IS_CFG_VALID='N' or lx_config_tbl(i).IS_CFG_COMPLETE='N' then
                           l_ct_invalid:=l_ct_invalid+1;
                       end if;
		       if lx_config_tbl(i).IS_CFG_CHANGED_flag='Y' then
                             l_ct_changed:=l_ct_changed+1;
			  end if;
		     end loop;
		     if l_ct_invalid<>0 or l_ct_changed <>0 then -- there is invalid,incomplete and changed configurations

			  if  l_Update_Allowed_Flg ='T' then
			       --commit work;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				       FND_MESSAGE.Set_Name('ASO', 'ASO_CHANGED_MODEL_LINES_REVIEW');
				       FND_MSG_PUB.ADD;
			       END IF;
			       IF aso_debug_pub.g_debug_flag = 'Y' THEN
			         aso_debug_pub.add('rassharm Submit_Quote -After  ASO_QUOTE_PUB.validate_model_configuration sucess user defined exception:  ', 1, 'N');
		         END IF;
			       RAISE l_warning_config_exception;


			  else
			     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				     FND_MESSAGE.Set_Name('ASO', 'ASO_CHANGED_MODEL_LINES_REVIEW');
				     FND_MSG_PUB.ADD;
			     END IF;

			     RAISE FND_API.G_EXC_ERROR;
                        end if;  -- l_Update_Allowed_Flg
		      end if;  -- l_ct_invalid
		 end if;  --sucess

             end if;  --l_mdl_count

	end if; -- l_order_status_prof
      /* End ER 3177722 */

End If;  -- application_type_code

     ASO_LINE_NUM_INT.RESET_LINE_NUM;

	l_qte_line_tbl := ASO_UTILITY_PVT.Query_Qte_Line_Rows_Submit (p_qte_header_rec.quote_header_id);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Submit_Quote - qte_line_tbl.count: '||to_char(l_qte_line_tbl.count), 1, 'N');
	END IF;

	FOR i IN 1..l_qte_line_tbl.count LOOP
	    l_qte_line_id := l_qte_line_tbl(i).quote_line_id;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Submit_Quote - l_qte_line_id: '||l_qte_line_id, 1, 'N');
	    END IF;
         -- 2469621 vtariker
         IF l_qte_line_tbl(i).item_type_code = 'MDL' THEN

            OPEN C_Get_Config_Flag(l_qte_line_id);
            FETCH C_Get_Config_Flag INTO l_complete_config, l_valid_config, l_instance_id;

            IF C_Get_Config_Flag%NOTFOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_INCOMPLETE_CONFIGURATION');
                  FND_MSG_PUB.ADD;
              END IF;
              CLOSE C_Get_Config_Flag;
              RAISE FND_API.G_EXC_ERROR;
            ELSE
              IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Submit_Quote - l_complete_config: '||l_complete_config, 1, 'N');
              aso_debug_pub.add('Submit_Quote - l_valid_config: '||l_valid_config, 1, 'N');
              aso_debug_pub.add('Submit_Quote - l_instance_id: '||l_instance_id, 1, 'N');
              END IF;

              IF (l_instance_id IS NULL) OR (l_instance_id = FND_API.G_MISS_NUM) THEN -- 2498776 vtariker

                IF (NVL(l_complete_config,'N') = 'N' OR NVL(l_valid_config,'N') = 'N') THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_INCOMPLETE_CONFIGURATION');
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE C_Get_Config_Flag;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

               END IF;  -- 2498776 vtariker

            END IF;
            CLOSE C_Get_Config_Flag;

         END IF;
         -- 2469621 vtariker

	    IF (NVL(l_om_defaulting_prof, 'N') = 'Y') THEN
            IF l_qte_line_tbl(i).line_category_code is null then
			l_qte_line_tbl(i).line_category_code  := FND_API.G_MISS_CHAR;
            END IF;
		  IF l_qte_line_tbl(i).invoicing_rule_id is null then
			l_qte_line_tbl(i).invoicing_rule_id := FND_API.G_MISS_NUM;
            end if;
		  IF l_qte_line_tbl(i).accounting_rule_id is null then
			l_qte_line_tbl(i).accounting_rule_id := FND_API.G_MISS_NUM;
            end if;
         END IF;

         l_status := ASO_SUBMIT_QUOTE_PVT.Query_Line_Dtl_Rows(
							 l_qte_line_id, i, l_qte_line_dtl_tbl);

       /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
        FOR j IN 1..l_qte_line_dtl_tbl.count LOOP
          if l_qte_line_dtl_tbl(j).SERVICE_REF_TYPE_CODE= 'PRODUCT_CATALOG' then
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_SERVICE_REF_NOT_VALID');
			FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          end if;
        end loop;
    /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/

	    l_line_attr_Ext_Tbl := ASO_SUBMIT_QUOTE_PVT.Query_Line_Attribs_Ext_Rows(
				                 l_qte_line_id, i, l_line_attr_ext_tbl);

	    l_status := ASO_SUBMIT_QUOTE_PVT.Query_Price_Adj_Rows(p_qte_header_rec.quote_header_id,
                                                                         l_qte_line_tbl(i), i,
                                                                         l_ln_price_adj_rltship_tbl,
                                                                         l_ln_price_adj_tbl );

/*	    l_index := l_ln_price_adj_tbl.count+1;
	    FOR j IN 1..l_tmp_price_adj_tbl.count LOOP
		l_tmp_price_adj_tbl(j).qte_line_index := i;
		l_tmp_price_adj_tbl(j).operation_code := 'CREATE';

-- pbh/prg
          l_ln_price_adj_rltship_tbl
            := ASO_SUBMIT_QUOTE_PVT.Query_Price_Adj_Rltship_Rows(
				l_tmp_price_adj_tbl(j).price_adjustment_id, i, l_ln_price_adj_rltship_tbl);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After l_ln_Price_Adj_Rltship_tbl.count: '||l_ln_Price_Adj_Rltship_tbl.count, 1, 'N');
END IF;
-- pbh/prg

		-- 2800749 vtariker
		IF l_qte_line_tbl(i).line_category_code = 'RETURN' AND
		   l_tmp_price_adj_tbl(j).modifier_line_type_code = 'FREIGHT_CHARGE' THEN
           l_tmp_price_adj_tbl(j).Credit_Or_Charge_Flag := 'C';
		END IF;
		-- 2800749 vtariker
		l_ln_price_adj_tbl(l_index) := l_tmp_price_adj_tbl(j);
		l_index := l_index+1;
	    END LOOP;
*/
	    l_ln_price_attr_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Price_Attr_Rows(
						       p_qte_header_rec.quote_header_id, l_qte_line_id,
							  i, l_ln_price_attr_tbl);

	    l_index := l_ln_payment_tbl.count+1;
	    l_tmp_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(p_qte_header_rec.quote_header_id, L_QTE_LINE_ID);
	    FOR j IN 1..l_tmp_payment_tbl.count LOOP
		l_tmp_payment_tbl(j).qte_line_index := i;
                IF (NVL(l_om_defaulting_prof, 'N') = 'Y') THEN
                  IF l_tmp_payment_tbl(j).payment_term_id is null then
                    l_tmp_payment_tbl(j).payment_term_id := FND_API.G_MISS_NUM;
                  end if;
                end if;
		l_ln_payment_tbl(l_index) := l_tmp_payment_tbl(j);
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Submit_Q: l_tmp_payment_tbl:l_index '||l_index, 1, 'N');
            aso_debug_pub.add('Submit_Q: l_tmp_payment_tbl(j).qte_line_index '||l_tmp_payment_tbl(j).qte_line_index, 1, 'N');
           END IF;

	--	l_index := l_index+1;
	    END LOOP;

	    l_status := ASO_SUBMIT_QUOTE_PVT.Query_Shipment_Rows(
						    p_qte_header_rec.quote_header_id, L_QTE_LINE_ID,
						    i, l_ln_shipment_tbl);
/*
	    l_ln_freight_charge_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Freight_Charge_Rows(
								 l_ln_shipment_tbl, i, l_ln_freight_charge_tbl);
*/
	    l_ln_tax_detail_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Tax_Detail_Rows(
							 p_qte_header_rec.quote_header_id,
						      L_QTE_LINE_ID, l_ln_shipment_tbl.count,
							 i, l_ln_tax_detail_tbl);

        FOR j IN 1..l_line_rltship_tbl.count LOOP
            IF l_line_rltship_tbl(j).quote_line_id = l_qte_line_id THEN
               l_line_rltship_tbl(j).qte_line_index := i;
            END IF;
            IF l_line_rltship_tbl(j).related_quote_line_id = l_qte_line_id THEN
               l_line_rltship_tbl(j).related_qte_line_index := i;
             END IF;
        END LOOP;

	   l_ln_sales_credit_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Sales_Credit_Row (
						  	  p_qte_header_rec.quote_header_id, l_qte_line_id,
							  i, l_ln_sales_credit_tbl);

	   l_ln_quote_party_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Quote_Party_Row(
							 p_qte_header_rec.quote_header_id, l_qte_line_id,
							 i, l_ln_quote_party_tbl);

	END LOOP;  -- Line_Tbl loop

-- pbh/prg
   l_ln_Price_Adj_Attr_Tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows(l_ln_price_adj_tbl);
aso_debug_pub.add('vtariker: l_ln_Price_Adj_Attr_Tbl.count: '||l_ln_Price_Adj_Attr_Tbl.count, 1, 'N');
-- pbh/prg

/*** Will not be required after CC condolidation
    OPEN C_check_pymnt_type(p_qte_header_rec.quote_header_id);
    LOOP
    FETCH C_check_pymnt_type into l_payment_type_code;
    IF C_check_pymnt_type%NOTFOUND THEN
      CLOSE C_check_pymnt_type;
      EXIT;
    END IF;

    IF l_payment_type_code = 'CREDIT_CARD' THEN
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Submit_Quote - payment_type is CC ', 1, 'N');
	END IF;

      IF NVL(FND_PROFILE.Value('ASO_CC_AUTHORIZATION_ENABLED'), 'N') = 'Y' THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: CC_Authorization_enabled ', 1, 'N');
END IF;

        IF p_control_rec.CVV2 IS NOT NULL AND p_control_rec.CVV2 <> FND_API.G_MISS_CHAR THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: Before Authorize_payment p_control_rec.CVV2: '|| p_control_rec.CVV2, 1, 'N');
END IF;
		  FOR i in 1..l_hd_payment_tbl.count LOOP
		       l_hd_payment_tbl(i).CVV2 := p_control_rec.CVV2;
            END LOOP;

	   END IF;

	   ASO_PAYMENT_INT.Authorize_Payment(
		P_Api_Version_Number	=> 1.0,
		P_Qte_Header_Rec	=> l_qte_header_rec,
		P_Payment_Tbl		=> l_hd_payment_tbl,
		x_Payment_Tbl		=> l_hd_payment_tbl_out,
		X_Return_Status 	=> x_Return_Status,
		X_Msg_Count		=> X_Msg_Count,
		X_Msg_Data		=> X_Msg_Data );

     l_hd_payment_tbl  :=  l_hd_payment_tbl_out;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After Authorize_payment x_return_status: '|| x_return_status, 1, 'N');
END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
      END IF;
     END IF;
   END LOOP;
***/

-- SalesTeam
  OPEN C_Check_Qte_Status (l_qte_header_rec.quote_header_id);
  FETCH C_Check_Qte_Status INTO l_istore_source;
  CLOSE C_Check_Qte_Status;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Submit_Q: Before Assign_Team: l_qte_header_rec.resource_id: ' || l_qte_header_rec.resource_id, 1, 'Y');
    aso_debug_pub.add('Submit_Q: Before Assign_Team: l_istore_source: ' || l_istore_source, 1, 'Y');
    END IF;

  IF l_istore_source <> 'Y' OR (l_istore_source = 'Y' AND
    (l_qte_header_rec.resource_id IS NOT NULL AND l_qte_header_rec.resource_id <> FND_API.G_MISS_NUM)) THEN

    IF NVL(FND_PROFILE.Value('ASO_API_ENABLE_SECURITY'),'N') = 'Y' THEN

        IF (l_sales_team_prof = 'FULL') THEN

            ASO_SALES_TEAM_PVT.Assign_Sales_Team
            (
                P_Init_Msg_List         => FND_API.G_FALSE,
                P_Commit                => FND_API.G_FALSE,
                p_Qte_Header_Rec        => l_qte_header_rec,
                P_Operation             => 'SUBMIT',
                x_Qte_Header_Rec        => lx_qte_header_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
             );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

		IF (l_sales_cred_prof = 'FULL') THEN

              l_Sales_Alloc_Control_Rec.Submit_Quote_Flag := 'Y';

              ASO_QUOTE_PUB.Allocate_Sales_Credits
              (
                  P_Api_Version_Number  => 1.0,
                  P_Init_Msg_List         => FND_API.G_FALSE,
                  P_Commit                => FND_API.G_FALSE,
                  P_Control_Rec           => l_Sales_Alloc_Control_Rec,
                  p_Qte_Header_Rec        => lx_qte_header_rec,
                  x_Qte_Header_Rec        => lx_out_qte_header_rec,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data
               );
			 lx_qte_header_rec   :=  lx_out_qte_header_rec;  --nocopy changes
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

          END IF;

        END IF; -- sales team

    END IF; -- security

  END IF; -- l_istore_source

-- hyang okc
-- contract renewal is removed.
-- end of hyang okc

      l_order_control_rec.CC_By_Fax := p_control_rec.CC_By_Fax;

      l_order_control_rec.BOOK_FLAG := p_control_rec.BOOK_FLAG;
--	l_order_control_rec.RESERVE_FLAG := p_control_rec.RESERVE_FLAG;
      l_order_control_rec.CALCULATE_PRICE := p_control_rec.CALCULATE_PRICE;
      l_order_control_rec.SERVER_ID := p_control_rec.SERVER_ID;

      -- Code for updating the Payment Amount
      OPEN C_payment_amount(p_qte_header_rec.quote_header_id);
      FETCH C_payment_amount into l_payment_amount;
      CLOSE C_payment_amount;

      l_Qte_Header_Rec.payment_amount  :=   l_payment_amount;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Quote - before create_order l_payment_amount: '||l_payment_amount, 1, 'Y');
END IF;

      ASO_ORDER_INT.Create_order(
		P_Api_Version				=> 1.0,
          P_Init_Msg_List   			=> FND_API.G_FALSE,
		p_Control_Rec				=> l_order_control_rec,
          P_Commit   				=> FND_API.G_FALSE,
		p_Qte_Rec					=> l_Qte_Header_Rec,
		p_Header_Payment_Tbl		=> l_Hd_Payment_Tbl,
		p_Header_Price_Adj_Tbl		=> l_hd_Price_Adj_Tbl,
		p_Header_Price_Attributes_Tbl	=> l_hd_Price_Attr_Tbl,
		p_Header_Price_Adj_rltship_Tbl	=> l_hd_Price_Adj_rltship_Tbl,
		p_Header_Price_Adj_Attr_Tbl	=> l_hd_Price_Adj_Attr_Tbl,
		p_Header_Shipment_Tbl		=> l_hd_Shipment_Tbl,
		p_Header_TAX_DETAIL_Tbl		=> l_hd_TAX_DETAIL_Tbl,
		p_Header_FREIGHT_CHARGE_Tbl	=> l_hd_FREIGHT_CHARGE_Tbl,
		p_Header_sales_credit_TBL	=> l_hd_sales_credit_TBL,
        	P_Header_ATTRIBS_EXT_Tbl    	=> l_Header_ATTRIBS_EXT_Tbl,
        	P_Header_Quote_Party_Tbl  	=> l_hd_Quote_Party_Tbl,
		p_Qte_Line_Tbl				=> l_Qte_Line_Tbl,
		p_Qte_Line_Dtl_Tbl			=> l_Qte_Line_Dtl_Tbl,
		p_Line_Payment_Tbl			=> l_ln_Payment_Tbl,
		p_Line_Price_Adj_Tbl		=> l_ln_Price_Adj_Tbl,
		p_Line_Price_Attributes_Tbl	=> l_ln_Price_Attr_Tbl,
		p_Line_Price_Adj_rltship_Tbl	=> l_ln_Price_Adj_rltship_Tbl,
		p_Line_Price_Adj_Attr_Tbl	=> l_ln_Price_Adj_Attr_Tbl,
		p_Line_Shipment_Tbl			=> l_ln_Shipment_Tbl,
		p_Line_TAX_DETAIL_Tbl		=> l_ln_TAX_DETAIL_Tbl,
		p_Line_FREIGHT_CHARGE_Tbl	=> l_ln_FREIGHT_CHARGE_Tbl,
		P_LINE_ATTRIBS_EXT_TBL		=> l_line_attr_ext_tbl,
        	p_Line_Rltship_Tbl			=> l_line_Rltship_Tbl,
		P_Line_sales_credit_TBL		=> l_ln_sales_credit_TBL,
        	P_Line_Quote_Party_Tbl   	=>    l_ln_Quote_Party_Tbl,
        	P_Lot_Serial_Tbl         	=> l_Lot_Serial_Tbl,
		X_Order_Header_Rec			=> lx_Order_Header_Rec,
		X_Order_Line_Tbl			=> lx_Order_Line_Tbl,
		X_Return_Status			=> X_Return_Status,
		X_Msg_Count				=> X_Msg_Count,
		X_Msg_Data				=> X_Msg_Data);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After Create_Order x_return_status: '||x_return_status, 1, 'N');
END IF;
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_ORDERING');
	    FND_MSG_PUB.ADD;
	  END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	END IF;

-- If book flag is set to 'Y' OM returns success even if the order
-- is not booked. We raise an error in case the order is not booked.
/** Bug# 4045135. Removing this check since deferred scheduling may book orders at a later stage.
   IF x_return_status = FND_API.G_RET_STS_SUCCESS
      AND l_order_control_rec.BOOK_FLAG = FND_API.G_TRUE THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After create_order Success and Book_flag = true ', 1, 'N');
END IF;
	  OPEN C_book_flag;
          FETCH C_book_flag into l_book_flag;
          IF C_book_flag%NOTFOUND THEN
             RAISE FND_API.G_EXC_ERROR;
	     END IF;
          IF l_book_flag = 'N' or l_book_flag IS NULL THEN
      	     RAISE FND_API.G_EXC_ERROR;
          END IF;
          CLOSE C_book_flag;
   END IF;
**/

-- EDU
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Quote - before ASO_EDUCATION_INT.Update_OTA_With_OrderLine ', 1, 'N');
END IF;
     ASO_EDUCATION_INT.Update_OTA_With_OrderLine(
          P_Init_Msg_List          => FND_API.G_FALSE,
          P_Commit                 => FND_API.G_FALSE,
          P_Order_Line_Tbl         => lx_order_line_tbl,
          X_Return_Status          => x_return_status,
          X_Msg_Count              => x_msg_count,
          X_Msg_Data               => x_msg_data);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Quote - after ASO_EDUCATION_INT.Update_OTA_With_OrderLine: '||x_return_status, 1, 'N');
END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
-- EDU

-- bug 1749828 hyang
	  -- create object relationships between quote and order

       l_related_obj_rec.QUOTE_OBJECT_TYPE_CODE    := 'HEADER';
       l_related_obj_rec.QUOTE_OBJECT_ID	   := p_qte_header_rec.quote_header_id  ;
       l_related_obj_rec.OBJECT_TYPE_CODE	   := 'ORDER'	 ;
       l_related_obj_rec.OBJECT_ID
				  := lx_order_header_rec.ORDER_HEADER_ID  ;
       l_related_obj_rec.RELATIONSHIP_TYPE_CODE    := 'QUOTE_ORDER';
       l_related_obj_rec.RECIPROCAL_FLAG	   := 'N'      ;

	   ASO_RELATED_OBJ_PVT.Create_related_obj(
   		 P_Api_Version_Number	=> 1.0,
    		 P_Init_Msg_List	=>  FND_API.G_FALSE,
    		 P_Commit		=>   FND_API.G_FALSE,
    		 p_validation_level	=>  FND_API.G_VALID_LEVEL_NONE,
    		 P_RELATED_OBJ_Rec	=> l_related_obj_rec,
    		 X_RELATED_OBJECT_ID	=> l_related_obj_id,
    		 X_RETURN_STATUS	=> X_RETURN_STATUS,
		 X_MSG_COUNT		=> X_MSG_COUNT 	,
		 X_MSG_DATA		=> X_MSG_DATA
	   );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After Create_Related_Obj x_return_status: '||x_return_status, 1, 'N');
END IF;
	IF X_RETURN_STATUS <>  FND_API.G_RET_STS_SUCCESS THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_CREATE_RLTN');
         FND_MESSAGE.Set_Token('COLUMN', l_related_obj_rec.RELATIONSHIP_TYPE_CODE, TRUE);
	    FND_MSG_PUB.ADD;
	  END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	END IF;

-- end of bug 1749828 hyang code

    x_order_header_rec.ORDER_NUMBER := lx_Order_Header_Rec.ORDER_NUMBER;
    x_order_header_rec.ORDER_HEADER_ID := lx_Order_Header_Rec.ORDER_HEADER_ID;
    x_order_header_rec.STATUS := lx_Order_Header_Rec.STATUS;

	-- update order line id for quote lines
-- hyang quote_status
    -- update quote_status to 'ORDER SUBMITTED'.
    OPEN c_qte_status_id ('ORDER SUBMITTED');
    FETCH c_qte_status_id INTO l_qte_status_id;
    CLOSE c_qte_status_id;
-- end of hyang quote_status

	UPDATE ASO_QUOTE_HEADERS_ALL
	SET order_Id           =  x_order_header_rec.order_header_id,
         quote_status_id    =  l_qte_status_id,
         last_update_date   =  sysdate,
         last_updated_by    =  fnd_global.user_id,
         last_update_login  =  fnd_global.conc_login_id
	WHERE quote_header_id = p_qte_header_rec.quote_header_id;

    FOR i IN 1..lx_order_line_tbl.count LOOP
	-- update order line id for quote lines

	UPDATE ASO_SHIPMENTS
	SET order_line_id      =  lx_order_line_tbl(i).order_line_id,
         last_update_date   =  sysdate,
         last_updated_by    =  fnd_global.user_id,
         last_update_login  =  fnd_global.conc_login_id
	WHERE shipment_id = lx_order_line_tbl(i).quote_shipment_line_id;

	-- update installment details
	-- hyang 1935614 csi integration
	  ASO_INSTBASE_INT.Update_Inst_Details_ORDER(
		P_Api_Version_Number	=> 1.0,
		P_Init_Msg_List 	=> FND_API.G_FALSE,
		P_Commit		=> FND_API.G_FALSE,
		P_Quote_Line_Shipment_id=> lx_order_line_tbl(i).quote_shipment_line_id,
		P_Order_Line_Id		=> lx_order_line_tbl(i).order_line_id,
		X_Return_Status 	=> x_Return_Status,
		X_Msg_Count		=> X_Msg_Count,
		X_Msg_Data		=> X_Msg_Data );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After Update_Inst_Details x_return_status: '||x_return_status, 1, 'N');
END IF;
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_UPDATE_INST');
	    FND_MSG_PUB.ADD;
	  END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	END IF;

	l_shipment_rec := ASO_UTILITY_PVT.Query_shipment_Row(lx_order_line_tbl(i).quote_shipment_Line_id);
	l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(l_shipment_rec.quote_line_id);

	-- transfer reservation
	IF l_shipment_rec.reservation_id IS NOT NULL
	    AND l_shipment_rec.reservation_id <> FND_API.G_MISS_NUM  THEN
	    ASO_RESERVATION_INT.Transfer_Reservation(
		P_Api_Version_Number	=> 1.0,
		P_Init_Msg_List 	=> FND_API.G_FALSE,
		P_Commit		=> FND_API.G_FALSE,
		P_header_rec		=> l_qte_header_rec,
		P_line_Rec		=> l_qte_line_rec,
		p_shipment_rec		=> l_shipment_rec,
		X_Return_Status 	=> x_Return_Status,
		X_Msg_Count		=> X_Msg_Count,
		X_Msg_Data		=> X_Msg_Data,
		X_new_RESERVATION_ID	=> l_reservation_id);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After Transfer_Reservation x_return_status: '||x_return_status, 1, 'N');
END IF;
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    			FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_TRANS_RSV');
	    			FND_MSG_PUB.ADD;
	  		END IF;
		     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              		RAISE FND_API.G_EXC_ERROR;
  			END IF;
  			IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  			END IF;
		END IF;
	END IF;
    END LOOP;  -- lx_order_line_tbl
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After lx_order_line_tbl loop x_return_status: '||x_return_status, 1, 'N');
END IF;


--  lx_return_status := x_return_status  -- 1966456
   -- copy attachment to order
  aso_attachment_int.copy_attachments_to_order
  (  p_api_version_number   => p_api_version_number
     ,p_init_msg_list       => FND_API.G_FALSE  --P_Init_Msg_List  --1966456
     ,p_commit              => FND_API.G_FALSE
     ,p_quote_header_id     => p_qte_header_rec.quote_header_id
     ,p_order_id            => x_order_header_rec.order_header_id
     ,p_order_line_tbl      => lx_Order_Line_Tbl
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
  );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After Copy_Attachments_to_order x_return_status: '||x_return_status, 1, 'N');
END IF;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
  END if;
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

--	x_return_status := lx_return_status; -- 1966456

-- Changes for High Availability

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: HA Test 10 ', 1, 'N');
END IF;

        JTF_HA_STATE_PKG.GET_CURRENT_STATE (
                                X_CURRENT_STATE => X_Current_State,
                                X_RETURN_STATUS => X_Return_Status);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: After JTF_HA_STATE_PKG.GET_CURRENT_STATE x_return_status: '||x_return_status, 1, 'N');
END IF;
        IF x_return_Status = FND_API.G_RET_STS_SUCCESS THEN

                IF X_Current_State IN (3,4) THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: In HA: X_Current_State: '||X_Current_State, 1, 'N');
END IF;
                    ROLLBACK TO SUBMIT_QUOTE_PVT;

                    ASO_SUBMIT_QUOTE_PVT.Raise_Quote_Event (
                              P_Quote_Header_Id   =>   p_qte_header_rec.quote_header_id,
                              P_Control_Rec       =>   p_control_rec,
                              X_Return_Status     =>   x_return_status );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: Raise_Quote_Event: X_Current_State: '||X_Current_State, 1, 'N');
END IF;
                    IF x_return_Status = FND_API.G_RET_STS_SUCCESS THEN

                         UPDATE ASO_QUOTE_HEADERS_ALL
                         SET Order_Id           =  x_order_header_rec.order_header_id,
                             last_update_date   =  sysdate,
                             last_updated_by    =  fnd_global.user_id,
                             last_update_login  =  fnd_global.conc_login_id
                         WHERE quote_header_id = p_qte_header_rec.quote_header_id;

                    END IF;

               END IF;
        ELSE
               x_return_Status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;

        END IF;
-- HA

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Submit_Q: End of submit_quote x_return_status: '||x_return_status, 1, 'N');
END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
	  FND_MESSAGE.Set_Name('ASO', 'Submit Quote API: End');
	  FND_MSG_PUB.Add;
      END IF;

      FND_MSG_PUB.Count_And_Get
      ( p_count 	  =>	  x_msg_count,
	  p_data	    =>	    x_msg_data
      );

-- HA
 -- Standard check for p_commit
 IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
 END IF;
-- HA

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO SUBMIT_QUOTE_PVT;

  	    BEGIN
	      IF FND_API.To_Boolean( p_commit )
	      THEN
		COMMIT WORK;
	      END IF;

	    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		NULL;
	    END;

	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count	  	=>	x_msg_count,
		  p_data	  	=>	x_msg_data
    		);


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO SUBMIT_QUOTE_PVT;

  	    BEGIN
	      IF FND_API.To_Boolean( p_commit )
	      THEN
		COMMIT WORK;
	      END IF;

	    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		NULL;
	    END;

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count	  	=>	x_msg_count,
		  p_data	  	=>	x_msg_data
    		);


     WHEN l_warning_config_exception THEN

        Begin
          COMMIT WORK;
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Submit_Quote: Commited configuration data End of submit_quote in User defined exception block l_warning_config_exception    ', 1, 'N');
          END IF;
        Exception
	  WHEN NO_DATA_FOUND THEN
	   NULL;
	End;

         x_return_status := FND_API.G_RET_STS_SUCCESS ;

         FND_MSG_PUB.Count_And_Get
    		( p_count	  	=>	x_msg_count,
		  p_data	  	=>	x_msg_data
    	        );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Submit_Quote: End of submit_quote in User defined exception block l_warning_config_exception    ', 1, 'N');
          END IF;


      WHEN OTHERS THEN

	  ROLLBACK TO SUBMIT_QUOTE_PVT;

  	    BEGIN
	      IF FND_API.To_Boolean( p_commit )
	      THEN
		COMMIT WORK;
	      END IF;

	    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		NULL;
	    END;

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg
    	    		( G_PKG_NAME,
    	    		  l_api_name
	    		);
	  END IF;

	  FND_MSG_PUB.Count_And_Get
    		( p_count	 	=>	x_msg_count,
		  p_data	  	=>	x_msg_data
    		);

END Submit_Quote;


FUNCTION Query_Tax_Detail_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Shipment_Tbl_Cnt   IN  NUMBER,
    P_Line_Index         IN  NUMBER,
    lx_tax_detail_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
IS
   CURSOR c_tax1 IS
    SELECT
	TAX_DETAIL_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	QUOTE_SHIPMENT_ID,
	ORIG_TAX_CODE,
	TAX_CODE,
	TAX_RATE,
	TAX_DATE,
	TAX_AMOUNT,
	TAX_EXEMPT_FLAG,
	TAX_EXEMPT_NUMBER,
	TAX_EXEMPT_REASON_CODE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
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
	TAX_INCLUSIVE_FLAG,
	TAX_RATE_ID,
	TAX_CLASSIFICATION_CODE  -- rassharm gsi
  FROM ASO_TAX_DETAILS
  WHERE quote_header_id = p_qte_header_id
  AND quote_line_id IS NULL ;

   CURSOR c_tax2 IS
    SELECT
     TAX_DETAIL_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	QUOTE_SHIPMENT_ID,
	ORIG_TAX_CODE,
	TAX_CODE,
	TAX_RATE,
	TAX_DATE,
	TAX_AMOUNT,
	TAX_EXEMPT_FLAG,
	TAX_EXEMPT_NUMBER,
	TAX_EXEMPT_REASON_CODE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
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
     TAX_INCLUSIVE_FLAG,
	TAX_RATE_ID,
	TAX_CLASSIFICATION_CODE  -- rassharm gsi
    FROM ASO_TAX_DETAILS
    WHERE quote_line_id = p_qte_line_id;

--    l_tax_detail_rec             ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
	l_tax_det_count NUMBER;

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Begin ASO_SUBMIT_QUOTE_PVT.Query_Tax_Detail_Rows', 1, 'N');
     END IF;

   IF P_Qte_Line_Id is NULL or P_Qte_Line_Id = FND_API.G_MISS_NUM THEN

      FOR tax_rec IN c_tax1 LOOP
	   l_tax_det_count := lx_tax_detail_tbl.COUNT+1;
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Query_Tax_Detail_Rows - l_tax_det_count: ' || l_tax_det_count, 1, 'N');
	   END IF;

	   lx_tax_detail_tbl(l_tax_det_count).TAX_DETAIL_ID := tax_rec.TAX_DETAIL_ID;
	   lx_tax_detail_tbl(l_tax_det_count).CREATION_DATE := tax_rec.CREATION_DATE;
	   lx_tax_detail_tbl(l_tax_det_count).CREATED_BY := tax_rec.CREATED_BY;
	   lx_tax_detail_tbl(l_tax_det_count).LAST_UPDATE_DATE := tax_rec.LAST_UPDATE_DATE;
	   lx_tax_detail_tbl(l_tax_det_count).LAST_UPDATED_BY := tax_rec.LAST_UPDATED_BY;
	   lx_tax_detail_tbl(l_tax_det_count).LAST_UPDATE_LOGIN := tax_rec.LAST_UPDATE_LOGIN;
	   lx_tax_detail_tbl(l_tax_det_count).REQUEST_ID := tax_rec.REQUEST_ID;
	   lx_tax_detail_tbl(l_tax_det_count).PROGRAM_APPLICATION_ID := tax_rec.PROGRAM_APPLICATION_ID;
	   lx_tax_detail_tbl(l_tax_det_count).PROGRAM_ID := tax_rec.PROGRAM_ID;
	   lx_tax_detail_tbl(l_tax_det_count).PROGRAM_UPDATE_DATE := tax_rec.PROGRAM_UPDATE_DATE;
	  lx_tax_detail_tbl(l_tax_det_count).QUOTE_HEADER_ID := tax_rec.QUOTE_HEADER_ID;
	  lx_tax_detail_tbl(l_tax_det_count).QUOTE_LINE_ID := tax_rec.QUOTE_LINE_ID;
	  lx_tax_detail_tbl(l_tax_det_count).QUOTE_SHIPMENT_ID := tax_rec.QUOTE_SHIPMENT_ID;
	  lx_tax_detail_tbl(l_tax_det_count).ORIG_TAX_CODE := tax_rec.ORIG_TAX_CODE;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_CODE := tax_rec.TAX_CODE;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_RATE := tax_rec.TAX_RATE;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_DATE := tax_rec.TAX_DATE;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_AMOUNT := tax_rec.TAX_AMOUNT;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_EXEMPT_FLAG := tax_rec.TAX_EXEMPT_FLAG;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_EXEMPT_NUMBER := tax_rec.TAX_EXEMPT_NUMBER;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_EXEMPT_REASON_CODE := tax_rec.TAX_EXEMPT_REASON_CODE;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE_CATEGORY := tax_rec.ATTRIBUTE_CATEGORY;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE1 := tax_rec.ATTRIBUTE1;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE2 := tax_rec.ATTRIBUTE2;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE3 := tax_rec.ATTRIBUTE3;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE4 := tax_rec.ATTRIBUTE4;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE5 := tax_rec.ATTRIBUTE5;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE6 := tax_rec.ATTRIBUTE6;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE7 := tax_rec.ATTRIBUTE7;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE8 := tax_rec.ATTRIBUTE8;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE9 := tax_rec.ATTRIBUTE9;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE10 := tax_rec.ATTRIBUTE10;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE11 := tax_rec.ATTRIBUTE11;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE12 := tax_rec.ATTRIBUTE12;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE13 := tax_rec.ATTRIBUTE13;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE14 := tax_rec.ATTRIBUTE14;
	  lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE15 := tax_rec.ATTRIBUTE15;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_INCLUSIVE_FLAG := tax_rec.TAX_INCLUSIVE_FLAG;
	  lx_tax_detail_tbl(l_tax_det_count).TAX_RATE_ID := tax_rec.TAX_RATE_ID;
           lx_tax_detail_tbl(l_tax_det_count).TAX_CLASSIFICATION_CODE := tax_rec.TAX_CLASSIFICATION_CODE;  -- rassharm GSI
--	  lx_tax_detail_tbl(lx_tax_detail_tbl.COUNT+1) := l_tax_detail_rec;
      END LOOP;
	 ELSIF P_Qte_Line_Id is NOT NULL OR P_Qte_Line_Id <> FND_API.G_MISS_NUM THEN
	  FOR tax_rec IN c_tax2 LOOP
	  l_tax_det_count := lx_tax_detail_tbl.COUNT+1;

	   lx_tax_detail_tbl(l_tax_det_count).TAX_DETAIL_ID := tax_rec.TAX_DETAIL_ID;
        lx_tax_detail_tbl(l_tax_det_count).shipment_index := p_shipment_tbl_cnt;
	   lx_tax_detail_tbl(l_tax_det_count).CREATION_DATE := tax_rec.CREATION_DATE;
	   lx_tax_detail_tbl(l_tax_det_count).CREATED_BY := tax_rec.CREATED_BY;
	   lx_tax_detail_tbl(l_tax_det_count).LAST_UPDATE_DATE := tax_rec.LAST_UPDATE_DATE;
	   lx_tax_detail_tbl(l_tax_det_count).LAST_UPDATED_BY := tax_rec.LAST_UPDATED_BY;
	   lx_tax_detail_tbl(l_tax_det_count).LAST_UPDATE_LOGIN := tax_rec.LAST_UPDATE_LOGIN;
	   lx_tax_detail_tbl(l_tax_det_count).REQUEST_ID := tax_rec.REQUEST_ID;
	   lx_tax_detail_tbl(l_tax_det_count).PROGRAM_APPLICATION_ID := tax_rec.PROGRAM_APPLICATION_ID;
	   lx_tax_detail_tbl(l_tax_det_count).PROGRAM_ID := tax_rec.PROGRAM_ID;
	   lx_tax_detail_tbl(l_tax_det_count).PROGRAM_UPDATE_DATE := tax_rec.PROGRAM_UPDATE_DATE;
	     lx_tax_detail_tbl(l_tax_det_count).QUOTE_HEADER_ID := tax_rec.QUOTE_HEADER_ID;
	     lx_tax_detail_tbl(l_tax_det_count).QUOTE_LINE_ID := tax_rec.QUOTE_LINE_ID;
	     lx_tax_detail_tbl(l_tax_det_count).QUOTE_SHIPMENT_ID := tax_rec.QUOTE_SHIPMENT_ID;
	     lx_tax_detail_tbl(l_tax_det_count).ORIG_TAX_CODE := tax_rec.ORIG_TAX_CODE;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_CODE := tax_rec.TAX_CODE;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_RATE := tax_rec.TAX_RATE;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_DATE := tax_rec.TAX_DATE;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_AMOUNT := tax_rec.TAX_AMOUNT;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_EXEMPT_FLAG := tax_rec.TAX_EXEMPT_FLAG;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_EXEMPT_NUMBER := tax_rec.TAX_EXEMPT_NUMBER;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_EXEMPT_REASON_CODE := tax_rec.TAX_EXEMPT_REASON_CODE;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE_CATEGORY := tax_rec.ATTRIBUTE_CATEGORY;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE1 := tax_rec.ATTRIBUTE1;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE2 := tax_rec.ATTRIBUTE2;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE3 := tax_rec.ATTRIBUTE3;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE4 := tax_rec.ATTRIBUTE4;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE5 := tax_rec.ATTRIBUTE5;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE6 := tax_rec.ATTRIBUTE6;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE7 := tax_rec.ATTRIBUTE7;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE8 := tax_rec.ATTRIBUTE8;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE9 := tax_rec.ATTRIBUTE9;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE10 := tax_rec.ATTRIBUTE10;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE11 := tax_rec.ATTRIBUTE11;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE12 := tax_rec.ATTRIBUTE12;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE13 := tax_rec.ATTRIBUTE13;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE14 := tax_rec.ATTRIBUTE14;
	     lx_tax_detail_tbl(l_tax_det_count).ATTRIBUTE15 := tax_rec.ATTRIBUTE15;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_INCLUSIVE_FLAG := tax_rec.TAX_INCLUSIVE_FLAG;
	     lx_tax_detail_tbl(l_tax_det_count).TAX_RATE_ID := tax_rec.TAX_RATE_ID;
             lx_tax_detail_tbl(l_tax_det_count).TAX_CLASSIFICATION_CODE := tax_rec.TAX_CLASSIFICATION_CODE; --rassharm GSI
	     lx_tax_detail_tbl(l_tax_det_count).QTE_LINE_INDEX := P_Line_Index;
--	     lx_tax_detail_tbl(lx_tax_detail_tbl.COUNT+1) := l_tax_detail_rec;
       END LOOP;
	 END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_SUBMIT_QUOTE_PVT.Query_Tax_Detail_Rows - end', 1, 'N');
	END IF;
      RETURN lx_tax_detail_tbl;
END Query_Tax_Detail_Rows;


FUNCTION Query_Shipment_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_shipment_tbl      IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type
    ) RETURN VARCHAR2
IS
    CURSOR c_shipment IS
	SELECT
        SHIPMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   PROMISE_DATE,
	   REQUEST_DATE,
	   SCHEDULE_SHIP_DATE,
	   SHIP_TO_PARTY_SITE_ID,
	   SHIP_TO_PARTY_ID,
        SHIP_TO_CUST_ACCOUNT_ID,
	   SHIP_PARTIAL_FLAG,
	   SHIP_SET_ID,
	   SHIP_METHOD_CODE,
	   FREIGHT_TERMS_CODE,
	   FREIGHT_CARRIER_CODE,
	   FOB_CODE,
	   SHIPPING_INSTRUCTIONS,
	   PACKING_INSTRUCTIONS,
	   QUANTITY,
	   RESERVED_QUANTITY,
	   RESERVATION_ID,
	   ORDER_LINE_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
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
           SHIPMENT_PRIORITY_CODE,
           SHIP_QUOTE_PRICE,
           SHIP_FROM_ORG_ID,
		 SHIP_TO_CUST_PARTY_ID,
           REQUEST_DATE_TYPE,
           DEMAND_CLASS_CODE,
           OBJECT_VERSION_NUMBER,
           SHIP_METHOD_CODE_FROM,
           FREIGHT_TERMS_CODE_FROM
      FROM ASO_SHIPMENTS
	WHERE quote_header_id = p_qte_header_id AND quote_line_id IS NULL;
--	   ((quote_line_id = p_qte_line_id) OR (quote_line_id IS NULL AND p_qte_line_id IS NULL));

--created a new cursor for bug 5093289

    CURSOR c_line_shipment IS
	SELECT
        SHIPMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   PROMISE_DATE,
	   REQUEST_DATE,
	   SCHEDULE_SHIP_DATE,
	   SHIP_TO_PARTY_SITE_ID,
	   SHIP_TO_PARTY_ID,
        SHIP_TO_CUST_ACCOUNT_ID,
	   SHIP_PARTIAL_FLAG,
	   SHIP_SET_ID,
	   SHIP_METHOD_CODE,
	   FREIGHT_TERMS_CODE,
	   FREIGHT_CARRIER_CODE,
	   FOB_CODE,
	   SHIPPING_INSTRUCTIONS,
	   PACKING_INSTRUCTIONS,
	   QUANTITY,
	   RESERVED_QUANTITY,
	   RESERVATION_ID,
	   ORDER_LINE_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
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
           SHIPMENT_PRIORITY_CODE,
           SHIP_QUOTE_PRICE,
           SHIP_FROM_ORG_ID,
		 SHIP_TO_CUST_PARTY_ID,
           REQUEST_DATE_TYPE,
           DEMAND_CLASS_CODE,
           OBJECT_VERSION_NUMBER,
           SHIP_METHOD_CODE_FROM,
           FREIGHT_TERMS_CODE_FROM
      FROM ASO_SHIPMENTS
	WHERE quote_line_id = p_qte_line_id;

--    l_shipment_rec             ASO_QUOTE_PUB.Shipment_Rec_Type;
	l_ship_count    NUMBER;
	l_status   VARCHAR2(1) := 'S';

BEGIN

--Changes for bug5093289. If quote_line_id is not null use cursor c_line_shipment
--else use c_shipment

--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

   IF p_qte_line_id IS NOT NULL THEN
     FOR shipment_rec IN c_line_shipment LOOP
	   l_ship_count := lx_shipment_tbl.COUNT+1;

        lx_shipment_tbl(l_ship_count).SHIPMENT_ID := shipment_rec.SHIPMENT_ID;
	   lx_shipment_tbl(l_ship_count).CREATION_DATE := shipment_rec.CREATION_DATE;
	   lx_shipment_tbl(l_ship_count).CREATED_BY := shipment_rec.CREATED_BY;
	   lx_shipment_tbl(l_ship_count).LAST_UPDATE_DATE := shipment_rec.LAST_UPDATE_DATE;
	   lx_shipment_tbl(l_ship_count).LAST_UPDATED_BY := shipment_rec.LAST_UPDATED_BY;
	   lx_shipment_tbl(l_ship_count).LAST_UPDATE_LOGIN := shipment_rec.LAST_UPDATE_LOGIN;
	   lx_shipment_tbl(l_ship_count).REQUEST_ID := shipment_rec.REQUEST_ID;
	   lx_shipment_tbl(l_ship_count).PROGRAM_APPLICATION_ID := shipment_rec.PROGRAM_APPLICATION_ID;
	   lx_shipment_tbl(l_ship_count).PROGRAM_ID := shipment_rec.PROGRAM_ID;
	   lx_shipment_tbl(l_ship_count).PROGRAM_UPDATE_DATE := shipment_rec.PROGRAM_UPDATE_DATE;
	  lx_shipment_tbl(l_ship_count).QUOTE_HEADER_ID := shipment_rec.QUOTE_HEADER_ID;
	  lx_shipment_tbl(l_ship_count).QUOTE_LINE_ID := shipment_rec.QUOTE_LINE_ID;
	  lx_shipment_tbl(l_ship_count).PROMISE_DATE := shipment_rec.PROMISE_DATE;
	  lx_shipment_tbl(l_ship_count).REQUEST_DATE := shipment_rec.REQUEST_DATE;
	  lx_shipment_tbl(l_ship_count).SCHEDULE_SHIP_DATE := shipment_rec.SCHEDULE_SHIP_DATE;
	  lx_shipment_tbl(l_ship_count).SHIP_TO_PARTY_SITE_ID := shipment_rec.SHIP_TO_PARTY_SITE_ID;
	  lx_shipment_tbl(l_ship_count).SHIP_TO_PARTY_ID := shipment_rec.SHIP_TO_PARTY_ID;
          lx_shipment_tbl(l_ship_count).SHIP_TO_CUST_ACCOUNT_ID := shipment_rec.SHIP_TO_CUST_ACCOUNT_ID;
	  lx_shipment_tbl(l_ship_count).SHIP_PARTIAL_FLAG := shipment_rec.SHIP_PARTIAL_FLAG;
	  lx_shipment_tbl(l_ship_count).SHIP_SET_ID := shipment_rec.SHIP_SET_ID;
	  lx_shipment_tbl(l_ship_count).SHIP_METHOD_CODE := shipment_rec.SHIP_METHOD_CODE;
	  lx_shipment_tbl(l_ship_count).FREIGHT_TERMS_CODE := shipment_rec.FREIGHT_TERMS_CODE;
	  lx_shipment_tbl(l_ship_count).FREIGHT_CARRIER_CODE := shipment_rec.FREIGHT_CARRIER_CODE;
	  lx_shipment_tbl(l_ship_count).FOB_CODE := shipment_rec.FOB_CODE;
	  lx_shipment_tbl(l_ship_count).SHIPPING_INSTRUCTIONS := shipment_rec.SHIPPING_INSTRUCTIONS;
	  lx_shipment_tbl(l_ship_count).PACKING_INSTRUCTIONS := shipment_rec.PACKING_INSTRUCTIONS;
	  lx_shipment_tbl(l_ship_count).QUANTITY := shipment_rec.QUANTITY;
	  lx_shipment_tbl(l_ship_count).RESERVED_QUANTITY := shipment_rec.RESERVED_QUANTITY;
	  lx_shipment_tbl(l_ship_count).RESERVATION_ID := shipment_rec.RESERVATION_ID;
	  lx_shipment_tbl(l_ship_count).ORDER_LINE_ID := shipment_rec.ORDER_LINE_ID;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE_CATEGORY := shipment_rec.ATTRIBUTE_CATEGORY;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE1 := shipment_rec.ATTRIBUTE1;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE2 := shipment_rec.ATTRIBUTE2;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE3 := shipment_rec.ATTRIBUTE3;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE4 := shipment_rec.ATTRIBUTE4;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE5 := shipment_rec.ATTRIBUTE5;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE6 := shipment_rec.ATTRIBUTE6;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE7 := shipment_rec.ATTRIBUTE7;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE8 := shipment_rec.ATTRIBUTE8;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE9 := shipment_rec.ATTRIBUTE9;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE10 := shipment_rec.ATTRIBUTE10;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE11 := shipment_rec.ATTRIBUTE11;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE12 := shipment_rec.ATTRIBUTE12;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE13 := shipment_rec.ATTRIBUTE13;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE14 := shipment_rec.ATTRIBUTE14;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE15 := shipment_rec.ATTRIBUTE15;
	  lx_shipment_tbl(l_ship_count).SHIPMENT_PRIORITY_CODE := shipment_rec.SHIPMENT_PRIORITY_CODE;
	  lx_shipment_tbl(l_ship_count).SHIP_QUOTE_PRICE := shipment_rec.SHIP_QUOTE_PRICE;
       lx_shipment_tbl(l_ship_count).SHIP_FROM_ORG_ID := shipment_rec.SHIP_FROM_ORG_ID;
       lx_shipment_tbl(l_ship_count).SHIP_TO_CUST_PARTY_ID := shipment_rec.SHIP_TO_CUST_PARTY_ID;
        lx_shipment_tbl(l_ship_count).REQUEST_DATE_TYPE := shipment_rec.REQUEST_DATE_TYPE;
        lx_shipment_tbl(l_ship_count).DEMAND_CLASS_CODE := shipment_rec.DEMAND_CLASS_CODE;
        lx_shipment_tbl(l_ship_count).OBJECT_VERSION_NUMBER := shipment_rec.OBJECT_VERSION_NUMBER;
        lx_shipment_tbl(l_ship_count).SHIP_METHOD_CODE_FROM := shipment_rec.SHIP_METHOD_CODE_FROM;
        lx_shipment_tbl(l_ship_count).FREIGHT_TERMS_CODE_FROM := shipment_rec.FREIGHT_TERMS_CODE_FROM;

       lx_shipment_tbl(l_ship_count).QTE_LINE_INDEX := P_Line_Index;

--	  lx_shipment_tbl(lx_shipment_tbl.COUNT+1) := l_shipment_rec;
      END LOOP;
   ELSE
	FOR shipment_rec IN c_shipment LOOP
	   l_ship_count := lx_shipment_tbl.COUNT+1;

	   lx_shipment_tbl(l_ship_count).SHIPMENT_ID := shipment_rec.SHIPMENT_ID;
	   lx_shipment_tbl(l_ship_count).CREATION_DATE := shipment_rec.CREATION_DATE;
	   lx_shipment_tbl(l_ship_count).CREATED_BY := shipment_rec.CREATED_BY;
	   lx_shipment_tbl(l_ship_count).LAST_UPDATE_DATE := shipment_rec.LAST_UPDATE_DATE;
	   lx_shipment_tbl(l_ship_count).LAST_UPDATED_BY := shipment_rec.LAST_UPDATED_BY;
	   lx_shipment_tbl(l_ship_count).LAST_UPDATE_LOGIN := shipment_rec.LAST_UPDATE_LOGIN;
	   lx_shipment_tbl(l_ship_count).REQUEST_ID := shipment_rec.REQUEST_ID;
	   lx_shipment_tbl(l_ship_count).PROGRAM_APPLICATION_ID := shipment_rec.PROGRAM_APPLICATION_ID;
	   lx_shipment_tbl(l_ship_count).PROGRAM_ID := shipment_rec.PROGRAM_ID;
	   lx_shipment_tbl(l_ship_count).PROGRAM_UPDATE_DATE := shipment_rec.PROGRAM_UPDATE_DATE;
	  lx_shipment_tbl(l_ship_count).QUOTE_HEADER_ID := shipment_rec.QUOTE_HEADER_ID;
	  lx_shipment_tbl(l_ship_count).QUOTE_LINE_ID := shipment_rec.QUOTE_LINE_ID;
	  lx_shipment_tbl(l_ship_count).PROMISE_DATE := shipment_rec.PROMISE_DATE;
	  lx_shipment_tbl(l_ship_count).REQUEST_DATE := shipment_rec.REQUEST_DATE;
	  lx_shipment_tbl(l_ship_count).SCHEDULE_SHIP_DATE := shipment_rec.SCHEDULE_SHIP_DATE;
	  lx_shipment_tbl(l_ship_count).SHIP_TO_PARTY_SITE_ID := shipment_rec.SHIP_TO_PARTY_SITE_ID;
	  lx_shipment_tbl(l_ship_count).SHIP_TO_PARTY_ID := shipment_rec.SHIP_TO_PARTY_ID;
		lx_shipment_tbl(l_ship_count).SHIP_TO_CUST_ACCOUNT_ID := shipment_rec.SHIP_TO_CUST_ACCOUNT_ID;
	  lx_shipment_tbl(l_ship_count).SHIP_PARTIAL_FLAG := shipment_rec.SHIP_PARTIAL_FLAG;
	  lx_shipment_tbl(l_ship_count).SHIP_SET_ID := shipment_rec.SHIP_SET_ID;
	  lx_shipment_tbl(l_ship_count).SHIP_METHOD_CODE := shipment_rec.SHIP_METHOD_CODE;
	  lx_shipment_tbl(l_ship_count).FREIGHT_TERMS_CODE := shipment_rec.FREIGHT_TERMS_CODE;
	  lx_shipment_tbl(l_ship_count).FREIGHT_CARRIER_CODE := shipment_rec.FREIGHT_CARRIER_CODE;
	  lx_shipment_tbl(l_ship_count).FOB_CODE := shipment_rec.FOB_CODE;
	  lx_shipment_tbl(l_ship_count).SHIPPING_INSTRUCTIONS := shipment_rec.SHIPPING_INSTRUCTIONS;
	  lx_shipment_tbl(l_ship_count).PACKING_INSTRUCTIONS := shipment_rec.PACKING_INSTRUCTIONS;
	  lx_shipment_tbl(l_ship_count).QUANTITY := shipment_rec.QUANTITY;
	  lx_shipment_tbl(l_ship_count).RESERVED_QUANTITY := shipment_rec.RESERVED_QUANTITY;
	  lx_shipment_tbl(l_ship_count).RESERVATION_ID := shipment_rec.RESERVATION_ID;
	  lx_shipment_tbl(l_ship_count).ORDER_LINE_ID := shipment_rec.ORDER_LINE_ID;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE_CATEGORY := shipment_rec.ATTRIBUTE_CATEGORY;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE1 := shipment_rec.ATTRIBUTE1;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE2 := shipment_rec.ATTRIBUTE2;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE3 := shipment_rec.ATTRIBUTE3;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE4 := shipment_rec.ATTRIBUTE4;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE5 := shipment_rec.ATTRIBUTE5;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE6 := shipment_rec.ATTRIBUTE6;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE7 := shipment_rec.ATTRIBUTE7;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE8 := shipment_rec.ATTRIBUTE8;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE9 := shipment_rec.ATTRIBUTE9;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE10 := shipment_rec.ATTRIBUTE10;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE11 := shipment_rec.ATTRIBUTE11;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE12 := shipment_rec.ATTRIBUTE12;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE13 := shipment_rec.ATTRIBUTE13;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE14 := shipment_rec.ATTRIBUTE14;
	  lx_shipment_tbl(l_ship_count).ATTRIBUTE15 := shipment_rec.ATTRIBUTE15;
	  lx_shipment_tbl(l_ship_count).SHIPMENT_PRIORITY_CODE := shipment_rec.SHIPMENT_PRIORITY_CODE;
	  lx_shipment_tbl(l_ship_count).SHIP_QUOTE_PRICE := shipment_rec.SHIP_QUOTE_PRICE;
	  lx_shipment_tbl(l_ship_count).SHIP_FROM_ORG_ID := shipment_rec.SHIP_FROM_ORG_ID;
	  lx_shipment_tbl(l_ship_count).SHIP_TO_CUST_PARTY_ID := shipment_rec.SHIP_TO_CUST_PARTY_ID;

        lx_shipment_tbl(l_ship_count).REQUEST_DATE_TYPE := shipment_rec.REQUEST_DATE_TYPE;
        lx_shipment_tbl(l_ship_count).DEMAND_CLASS_CODE := shipment_rec.DEMAND_CLASS_CODE;
        lx_shipment_tbl(l_ship_count).OBJECT_VERSION_NUMBER := shipment_rec.OBJECT_VERSION_NUMBER;
        lx_shipment_tbl(l_ship_count).SHIP_METHOD_CODE_FROM := shipment_rec.SHIP_METHOD_CODE_FROM;
        lx_shipment_tbl(l_ship_count).FREIGHT_TERMS_CODE_FROM := shipment_rec.FREIGHT_TERMS_CODE_FROM;

	  lx_shipment_tbl(l_ship_count).QTE_LINE_INDEX := P_Line_Index;

--	  lx_shipment_tbl(lx_shipment_tbl.COUNT+1) := l_shipment_rec;
	END LOOP;
   END IF;
   RETURN l_status;

END Query_Shipment_Rows;


FUNCTION Query_Freight_Charge_Rows (
    P_Shipment_Tbl		IN  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Line_Index         IN  NUMBER,
    lx_freight_charge_tbl  IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
IS
   CURSOR c_freight_charge (c_shipment_id NUMBER) IS
    SELECT
     FREIGHT_CHARGE_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_SHIPMENT_ID,
	FREIGHT_CHARGE_TYPE_ID,
	CHARGE_AMOUNT,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15
    FROM ASO_FREIGHT_CHARGES
    WHERE quote_shipment_id = c_shipment_id;

--    l_freight_charge_rec             ASO_QUOTE_PUB.Freight_Charge_Rec_Type;
	l_frt_chrg_count     NUMBER;

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

   FOR i IN 1..P_shipment_tbl.count LOOP
      FOR freight_charge_rec IN c_freight_charge(P_shipment_tbl(i).shipment_id) LOOP
	  l_frt_chrg_count := lx_freight_charge_tbl.COUNT+1;

	  lx_freight_charge_tbl(l_frt_chrg_count).FREIGHT_CHARGE_ID :=
						freight_charge_rec.FREIGHT_CHARGE_ID;
	  lx_freight_charge_tbl(l_frt_chrg_count).shipment_index := i;
	   lx_freight_charge_tbl(l_frt_chrg_count).CREATION_DATE := freight_charge_rec.CREATION_DATE;
	   lx_freight_charge_tbl(l_frt_chrg_count).CREATED_BY := freight_charge_rec.CREATED_BY;
	   lx_freight_charge_tbl(l_frt_chrg_count).LAST_UPDATE_DATE := freight_charge_rec.LAST_UPDATE_DATE;
	   lx_freight_charge_tbl(l_frt_chrg_count).LAST_UPDATED_BY := freight_charge_rec.LAST_UPDATED_BY;
	   lx_freight_charge_tbl(l_frt_chrg_count).LAST_UPDATE_LOGIN := freight_charge_rec.LAST_UPDATE_LOGIN;
	   lx_freight_charge_tbl(l_frt_chrg_count).REQUEST_ID := freight_charge_rec.REQUEST_ID;
	   lx_freight_charge_tbl(l_frt_chrg_count).PROGRAM_APPLICATION_ID := freight_charge_rec.PROGRAM_APPLICATION_ID;
	   lx_freight_charge_tbl(l_frt_chrg_count).PROGRAM_ID := freight_charge_rec.PROGRAM_ID;
	   lx_freight_charge_tbl(l_frt_chrg_count).PROGRAM_UPDATE_DATE := freight_charge_rec.PROGRAM_UPDATE_DATE;
	  lx_freight_charge_tbl(l_frt_chrg_count).QUOTE_SHIPMENT_ID :=
						freight_charge_rec.QUOTE_SHIPMENT_ID;

	  lx_freight_charge_tbl(l_frt_chrg_count).CHARGE_AMOUNT := freight_charge_rec.CHARGE_AMOUNT;
	  lx_freight_charge_tbl(l_frt_chrg_count).FREIGHT_CHARGE_TYPE_ID :=
						freight_charge_rec.FREIGHT_CHARGE_TYPE_ID;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE1 := freight_charge_rec.ATTRIBUTE1;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE2 := freight_charge_rec.ATTRIBUTE2;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE3 := freight_charge_rec.ATTRIBUTE3;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE4 := freight_charge_rec.ATTRIBUTE4;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE5 := freight_charge_rec.ATTRIBUTE5;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE6 := freight_charge_rec.ATTRIBUTE6;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE7 := freight_charge_rec.ATTRIBUTE7;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE8 := freight_charge_rec.ATTRIBUTE8;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE9 := freight_charge_rec.ATTRIBUTE9;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE10 := freight_charge_rec.ATTRIBUTE10;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE11 := freight_charge_rec.ATTRIBUTE11;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE12 := freight_charge_rec.ATTRIBUTE12;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE13 := freight_charge_rec.ATTRIBUTE13;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE14 := freight_charge_rec.ATTRIBUTE14;
	  lx_freight_charge_tbl(l_frt_chrg_count).ATTRIBUTE15 := freight_charge_rec.ATTRIBUTE15;
	  lx_freight_charge_tbl(l_frt_chrg_count).QTE_LINE_INDEX := P_Line_Index;
--	  lx_freight_charge_tbl(lx_freight_charge_tbl.COUNT+1) := l_freight_charge_rec;
     END LOOP;
   END LOOP;
   RETURN lx_freight_charge_tbl;
END Query_Freight_Charge_Rows;


FUNCTION  Query_Sales_Credit_Row (
    P_qte_header_Id		 IN   NUMBER,
    P_qte_line_id         IN   NUMBER,
    P_Line_Index          IN   NUMBER,
    lx_sales_credit_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_tbl_Type
    ) RETURN ASO_QUOTE_PUB.Sales_Credit_tbl_Type
IS

--  l_sales_credit_rec        ASO_QUOTE_PUB.Sales_Credit_rec_Type;
  l_sls_crdt_count  NUMBER;

 CURSOR C1 IS
SELECT
CREATION_DATE,
CREATED_BY,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
SALES_CREDIT_ID,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
PERCENT,
RESOURCE_ID,
RESOURCE_GROUP_ID,
EMPLOYEE_PERSON_ID,
SALES_CREDIT_TYPE_ID,
ATTRIBUTE_CATEGORY_CODE,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
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
OBJECT_VERSION_NUMBER
FROM ASO_SALES_CREDITS
WHERE  quote_header_id = p_qte_header_id AND
	   ((quote_line_id = p_qte_line_id) OR (quote_line_id IS NULL AND p_qte_line_id IS NULL));

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

 FOR sales_rec IN c1 LOOP
l_sls_crdt_count := lx_sales_credit_tbl.COUNT+1;

lx_sales_credit_tbl(l_sls_crdt_count).CREATION_DATE :=                  sales_rec.CREATION_DATE;
lx_sales_credit_tbl(l_sls_crdt_count).CREATED_BY :=                     sales_rec.CREATED_BY;
lx_sales_credit_tbl(l_sls_crdt_count).LAST_UPDATED_BY :=                sales_rec.LAST_UPDATED_BY;
lx_sales_credit_tbl(l_sls_crdt_count).LAST_UPDATE_DATE :=               sales_rec.LAST_UPDATE_DATE;
lx_sales_credit_tbl(l_sls_crdt_count).LAST_UPDATE_LOGIN :=              sales_rec.LAST_UPDATE_LOGIN;
lx_sales_credit_tbl(l_sls_crdt_count).REQUEST_ID :=                     sales_rec.REQUEST_ID;
lx_sales_credit_tbl(l_sls_crdt_count).PROGRAM_APPLICATION_ID :=         sales_rec.PROGRAM_APPLICATION_ID;
lx_sales_credit_tbl(l_sls_crdt_count).PROGRAM_ID :=                     sales_rec.PROGRAM_ID;
lx_sales_credit_tbl(l_sls_crdt_count).PROGRAM_UPDATE_DATE :=            sales_rec.PROGRAM_UPDATE_DATE;
lx_sales_credit_tbl(l_sls_crdt_count).SALES_CREDIT_ID :=                sales_rec.SALES_CREDIT_ID;
lx_sales_credit_tbl(l_sls_crdt_count).QUOTE_HEADER_ID :=                sales_rec.QUOTE_HEADER_ID;
lx_sales_credit_tbl(l_sls_crdt_count).QUOTE_LINE_ID :=                  sales_rec.QUOTE_LINE_ID;
lx_sales_credit_tbl(l_sls_crdt_count).PERCENT :=                        sales_rec.PERCENT;
lx_sales_credit_tbl(l_sls_crdt_count).RESOURCE_ID :=                    sales_rec.RESOURCE_ID;
lx_sales_credit_tbl(l_sls_crdt_count).RESOURCE_GROUP_ID :=              sales_rec.RESOURCE_GROUP_ID;
lx_sales_credit_tbl(l_sls_crdt_count).EMPLOYEE_PERSON_ID :=             sales_rec.EMPLOYEE_PERSON_ID;
lx_sales_credit_tbl(l_sls_crdt_count).SALES_CREDIT_TYPE_ID :=           sales_rec.SALES_CREDIT_TYPE_ID;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE_CATEGORY_CODE :=        sales_rec.ATTRIBUTE_CATEGORY_CODE;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE1 :=                     sales_rec.ATTRIBUTE1;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE2 :=                     sales_rec.ATTRIBUTE2;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE3 :=                     sales_rec.ATTRIBUTE3;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE4 :=                     sales_rec.ATTRIBUTE4;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE5 :=                     sales_rec.ATTRIBUTE5;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE6 :=                     sales_rec.ATTRIBUTE6;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE7 :=                     sales_rec.ATTRIBUTE7;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE8 :=                     sales_rec.ATTRIBUTE8;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE9 :=                     sales_rec.ATTRIBUTE9;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE10 :=                    sales_rec.ATTRIBUTE10;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE11 :=                    sales_rec.ATTRIBUTE11;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE12 :=                    sales_rec.ATTRIBUTE12;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE13 :=                    sales_rec.ATTRIBUTE13;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE14 :=                    sales_rec.ATTRIBUTE14;
lx_sales_credit_tbl(l_sls_crdt_count).ATTRIBUTE15 :=                    sales_rec.ATTRIBUTE15;
lx_sales_credit_tbl(l_sls_crdt_count).QTE_LINE_INDEX :=                 P_Line_Index;
--lx_sales_credit_tbl(lx_sales_credit_tbl.COUNT+1) := l_sales_credit_rec;
END LOOP;
RETURN lx_sales_credit_tbl;
END Query_Sales_Credit_Row;


FUNCTION  Query_Quote_Party_Row (
    P_Qte_header_Id		 IN   NUMBER,
    P_Qte_line_Id		 IN   NUMBER,
    P_Line_Index          IN   NUMBER,
    lx_quote_party_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type
    ) RETURN ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type
IS

--  l_quote_party_rec        ASO_QUOTE_PUB.QUOTE_PARTY_rec_Type;
  l_quote_party_count    NUMBER;

CURSOR C1 is
SELECT QUOTE_PARTY_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
LAST_UPDATED_BY,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
QUOTE_SHIPMENT_ID,
PARTY_TYPE,
PARTY_ID,
PARTY_OBJECT_TYPE,
PARTY_OBJECT_ID,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15
FROM ASO_QUOTE_PARTIES WHERE quote_header_id = p_qte_header_id AND
	   ((quote_line_id = p_qte_line_id) OR (quote_line_id IS NULL AND p_qte_line_id IS NULL));

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

 FOR qpt_rec in C1 LOOP
l_quote_party_count := lx_quote_party_tbl.COUNT+1;

lx_quote_party_tbl(l_quote_party_count).QUOTE_PARTY_ID :=                 qpt_rec.QUOTE_PARTY_ID;
lx_quote_party_tbl(l_quote_party_count).CREATION_DATE :=                  qpt_rec.CREATION_DATE;
lx_quote_party_tbl(l_quote_party_count).CREATED_BY :=                     qpt_rec.CREATED_BY;
lx_quote_party_tbl(l_quote_party_count).LAST_UPDATE_DATE :=               qpt_rec.LAST_UPDATE_DATE;
lx_quote_party_tbl(l_quote_party_count).LAST_UPDATE_LOGIN :=              qpt_rec.LAST_UPDATE_LOGIN;
lx_quote_party_tbl(l_quote_party_count).LAST_UPDATED_BY :=                qpt_rec.LAST_UPDATED_BY;
lx_quote_party_tbl(l_quote_party_count).REQUEST_ID :=                     qpt_rec.REQUEST_ID;
lx_quote_party_tbl(l_quote_party_count).PROGRAM_APPLICATION_ID :=         qpt_rec.PROGRAM_APPLICATION_ID;
lx_quote_party_tbl(l_quote_party_count).PROGRAM_ID :=                     qpt_rec.PROGRAM_ID;
lx_quote_party_tbl(l_quote_party_count).PROGRAM_UPDATE_DATE :=            qpt_rec.PROGRAM_UPDATE_DATE;
lx_quote_party_tbl(l_quote_party_count).QUOTE_HEADER_ID :=                qpt_rec.QUOTE_HEADER_ID;
lx_quote_party_tbl(l_quote_party_count).QUOTE_LINE_ID :=                  qpt_rec.QUOTE_LINE_ID;
lx_quote_party_tbl(l_quote_party_count).QUOTE_SHIPMENT_ID :=              qpt_rec.QUOTE_SHIPMENT_ID;
lx_quote_party_tbl(l_quote_party_count).PARTY_TYPE :=                     qpt_rec.PARTY_TYPE;
lx_quote_party_tbl(l_quote_party_count).PARTY_ID :=                       qpt_rec.PARTY_ID;
lx_quote_party_tbl(l_quote_party_count).PARTY_OBJECT_TYPE :=              qpt_rec.PARTY_OBJECT_TYPE;
lx_quote_party_tbl(l_quote_party_count).PARTY_OBJECT_ID :=                qpt_rec.PARTY_OBJECT_ID;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE_CATEGORY :=             qpt_rec.ATTRIBUTE_CATEGORY;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE1 :=                     qpt_rec.ATTRIBUTE1;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE2 :=                     qpt_rec.ATTRIBUTE2;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE3 :=                     qpt_rec.ATTRIBUTE3;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE4 :=                     qpt_rec.ATTRIBUTE4;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE5 :=                     qpt_rec.ATTRIBUTE5;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE6 :=                     qpt_rec.ATTRIBUTE6;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE7 :=                     qpt_rec.ATTRIBUTE7;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE8 :=                     qpt_rec.ATTRIBUTE8;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE9 :=                     qpt_rec.ATTRIBUTE9;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE10 :=                    qpt_rec.ATTRIBUTE10;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE11 :=                    qpt_rec.ATTRIBUTE11;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE12 :=                    qpt_rec.ATTRIBUTE12;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE13 :=                    qpt_rec.ATTRIBUTE13;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE14 :=                    qpt_rec.ATTRIBUTE14;
lx_quote_party_tbl(l_quote_party_count).ATTRIBUTE15 :=                    qpt_rec.ATTRIBUTE15;
lx_quote_party_tbl(l_quote_party_count).QTE_LINE_INDEX :=                 P_Line_Index;
--lx_quote_party_tbl(lx_quote_party_tbl.COUNT+1) := l_quote_party_rec;
END LOOP;
RETURN lx_quote_party_tbl;

END Query_Quote_Party_Row;


FUNCTION Query_Line_Dtl_Rows (
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_Line_Dtl_tbl      IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    ) RETURN VARCHAR2
IS
   CURSOR c_Line_Dtl IS
	SELECT
	QUOTE_LINE_DETAIL_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_LINE_ID,
	CONFIG_HEADER_ID,
	CONFIG_REVISION_NUM,
	CONFIG_ITEM_ID,
	COMPLETE_CONFIGURATION_FLAG,
	VALID_CONFIGURATION_FLAG,
	COMPONENT_CODE,
	SERVICE_COTERMINATE_FLAG,
	SERVICE_DURATION,
	SERVICE_PERIOD,
	SERVICE_UNIT_SELLING_PERCENT,
	SERVICE_UNIT_LIST_PERCENT,
	SERVICE_NUMBER,
	UNIT_PERCENT_BASE_PRICE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
     ATTRIBUTE4,
	ATTRIBUTE5,
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
	SERVICE_REF_TYPE_CODE,
	SERVICE_REF_ORDER_NUMBER,
	SERVICE_REF_LINE_NUMBER,
	SERVICE_REF_LINE_ID,
	SERVICE_REF_SYSTEM_ID,
	SERVICE_REF_OPTION_NUMB,
	SERVICE_REF_SHIPMENT_NUMB,
	RETURN_REF_TYPE,
	RETURN_REF_HEADER_ID,
	RETURN_REF_LINE_ID,
	RETURN_REASON_CODE,
	RETURN_ATTRIBUTE1,
	RETURN_ATTRIBUTE2,
	RETURN_ATTRIBUTE3,
	RETURN_ATTRIBUTE4,
	RETURN_ATTRIBUTE5,
	RETURN_ATTRIBUTE6,
	RETURN_ATTRIBUTE7,
	RETURN_ATTRIBUTE8,
	RETURN_ATTRIBUTE9,
	RETURN_ATTRIBUTE10,
	RETURN_ATTRIBUTE11,
	RETURN_ATTRIBUTE12,
	RETURN_ATTRIBUTE13,
	RETURN_ATTRIBUTE14,
	RETURN_ATTRIBUTE15,
     REF_TYPE_CODE,
     REF_LINE_ID,
	INSTANCE_ID,
	BOM_SORT_ORDER
    FROM ASO_Quote_Line_Details
    WHERE quote_line_id = p_qte_line_id;

--    l_Line_Dtl_rec             ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
	l_line_dtl_count     NUMBER;
	l_status   VARCHAR2(1) := 'S';

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

      FOR Line_Dtl_rec IN c_Line_Dtl LOOP
	   l_line_dtl_count := lx_Line_dtl_tbl.COUNT+1;
	   lx_line_dtl_tbl(l_line_dtl_count).QUOTE_LINE_DETAIL_ID := line_dtl_rec.QUOTE_LINE_DETAIL_ID;
	   lx_line_dtl_tbl(l_line_dtl_count).QUOTE_LINE_ID := line_dtl_rec.QUOTE_LINE_ID;
	   lx_line_dtl_tbl(l_line_dtl_count).CREATION_DATE := line_dtl_rec.CREATION_DATE;
	   lx_line_dtl_tbl(l_line_dtl_count).CREATED_BY := line_dtl_rec.CREATED_BY;
	   lx_line_dtl_tbl(l_line_dtl_count).LAST_UPDATE_DATE := line_dtl_rec.LAST_UPDATE_DATE;
	   lx_line_dtl_tbl(l_line_dtl_count).LAST_UPDATED_BY := line_dtl_rec.LAST_UPDATED_BY;
	   lx_line_dtl_tbl(l_line_dtl_count).LAST_UPDATE_LOGIN := line_dtl_rec.LAST_UPDATE_LOGIN;
	   lx_line_dtl_tbl(l_line_dtl_count).REQUEST_ID := line_dtl_rec.REQUEST_ID;
	   lx_line_dtl_tbl(l_line_dtl_count).PROGRAM_APPLICATION_ID := line_dtl_rec.PROGRAM_APPLICATION_ID;
	   lx_line_dtl_tbl(l_line_dtl_count).PROGRAM_ID := line_dtl_rec.PROGRAM_ID;
	   lx_line_dtl_tbl(l_line_dtl_count).PROGRAM_UPDATE_DATE := line_dtl_rec.PROGRAM_UPDATE_DATE;
	  lx_line_dtl_tbl(l_line_dtl_count).CONFIG_HEADER_ID := line_dtl_rec.CONFIG_HEADER_ID;
	  lx_line_dtl_tbl(l_line_dtl_count).COMPLETE_CONFIGURATION_FLAG :=
						line_dtl_rec.COMPLETE_CONFIGURATION_FLAG;
	  lx_line_dtl_tbl(l_line_dtl_count).CONFIG_REVISION_NUM := line_dtl_rec.CONFIG_REVISION_NUM;
	  lx_line_dtl_tbl(l_line_dtl_count).VALID_CONFIGURATION_FLAG :=
						line_dtl_rec.VALID_CONFIGURATION_FLAG;
	  lx_line_dtl_tbl(l_line_dtl_count).COMPONENT_CODE := line_dtl_rec.COMPONENT_CODE;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_COTERMINATE_FLAG :=
						line_dtl_rec.SERVICE_COTERMINATE_FLAG;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_DURATION := line_dtl_rec.SERVICE_DURATION;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_UNIT_SELLING_PERCENT :=
						line_dtl_rec.SERVICE_UNIT_SELLING_PERCENT;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_UNIT_LIST_PERCENT :=
						line_dtl_rec.SERVICE_UNIT_LIST_PERCENT;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_NUMBER := line_dtl_rec.SERVICE_NUMBER;
	  lx_line_dtl_tbl(l_line_dtl_count).UNIT_PERCENT_BASE_PRICE := line_dtl_rec.UNIT_PERCENT_BASE_PRICE;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_PERIOD := line_dtl_rec.SERVICE_PERIOD;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE_CATEGORY := line_dtl_rec.ATTRIBUTE_CATEGORY;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE1 := line_dtl_rec.ATTRIBUTE1;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE2 := line_dtl_rec.ATTRIBUTE2;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE3 := line_dtl_rec.ATTRIBUTE3;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE4 := line_dtl_rec.ATTRIBUTE4;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE5 := line_dtl_rec.ATTRIBUTE5;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE6 := line_dtl_rec.ATTRIBUTE6;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE7 := line_dtl_rec.ATTRIBUTE7;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE8 := line_dtl_rec.ATTRIBUTE8;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE9 := line_dtl_rec.ATTRIBUTE9;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE10 := line_dtl_rec.ATTRIBUTE10;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE11 := line_dtl_rec.ATTRIBUTE11;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE12 := line_dtl_rec.ATTRIBUTE12;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE13 := line_dtl_rec.ATTRIBUTE13;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE14 := line_dtl_rec.ATTRIBUTE14;
	  lx_line_dtl_tbl(l_line_dtl_count).ATTRIBUTE15 := line_dtl_rec.ATTRIBUTE15;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_REF_TYPE_CODE     := line_dtl_rec.SERVICE_REF_TYPE_CODE;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_REF_ORDER_NUMBER  := line_dtl_rec.SERVICE_REF_ORDER_NUMBER;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_REF_LINE_NUMBER   := line_dtl_rec.SERVICE_REF_LINE_NUMBER;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_REF_LINE_ID       := line_dtl_rec.SERVICE_REF_LINE_ID;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_REF_SYSTEM_ID     := line_dtl_rec.SERVICE_REF_SYSTEM_ID;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_REF_OPTION_NUMB   := line_dtl_rec.SERVICE_REF_OPTION_NUMB;
	  lx_line_dtl_tbl(l_line_dtl_count).SERVICE_REF_SHIPMENT_NUMB := line_dtl_rec.SERVICE_REF_SHIPMENT_NUMB;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_REF_TYPE      := line_dtl_rec.RETURN_REF_TYPE;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_REF_HEADER_ID := line_dtl_rec.RETURN_REF_HEADER_ID;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_REF_LINE_ID   := line_dtl_rec.RETURN_REF_LINE_ID;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_REASON_CODE   := line_dtl_rec.RETURN_REASON_CODE;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE1    := line_dtl_rec.RETURN_ATTRIBUTE1;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE2    := line_dtl_rec.RETURN_ATTRIBUTE2;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE3    := line_dtl_rec.RETURN_ATTRIBUTE3;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE4    := line_dtl_rec.RETURN_ATTRIBUTE4;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE5    := line_dtl_rec.RETURN_ATTRIBUTE5;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE6    := line_dtl_rec.RETURN_ATTRIBUTE6;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE7    := line_dtl_rec.RETURN_ATTRIBUTE7;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE8    := line_dtl_rec.RETURN_ATTRIBUTE8;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE9    := line_dtl_rec.RETURN_ATTRIBUTE9;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE10   := line_dtl_rec.RETURN_ATTRIBUTE10;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE11   := line_dtl_rec.RETURN_ATTRIBUTE11;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE12   := line_dtl_rec.RETURN_ATTRIBUTE12;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE13   := line_dtl_rec.RETURN_ATTRIBUTE13;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE14   := line_dtl_rec.RETURN_ATTRIBUTE14;
	  lx_line_dtl_tbl(l_line_dtl_count).RETURN_ATTRIBUTE15   := line_dtl_rec.RETURN_ATTRIBUTE15;
	  lx_line_dtl_tbl(l_line_dtl_count).CONFIG_ITEM_ID       := line_dtl_rec.CONFIG_ITEM_ID;
       lx_line_dtl_tbl(l_line_dtl_count).REF_TYPE_CODE        := line_dtl_rec.REF_TYPE_CODE;
       lx_line_dtl_tbl(l_line_dtl_count).REF_LINE_ID          := line_dtl_rec.REF_LINE_ID;
       lx_line_dtl_tbl(l_line_dtl_count).INSTANCE_ID          := line_dtl_rec.INSTANCE_ID;
       lx_line_dtl_tbl(l_line_dtl_count).BOM_SORT_ORDER       := line_dtl_rec.BOM_SORT_ORDER;
       lx_line_dtl_tbl(l_line_dtl_count).QTE_LINE_INDEX       := P_Line_Index;

--	  lx_line_dtl_tbl(lx_Line_dtl_tbl.COUNT+1) := l_Line_dtl_rec;
      END LOOP;
      RETURN l_status;
END Query_Line_Dtl_Rows;


FUNCTION Query_Line_Attribs_Ext_Rows(
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_Line_Attr_Ext_Tbl IN OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
IS
  CURSOR c_Line_Attr_Ext IS
   SELECT
     LINE_ATTRIBUTE_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	APPLICATION_ID,
	QUOTE_LINE_ID,
	ATTRIBUTE_TYPE_CODE,
	NAME,
	VALUE,
	VALUE_TYPE,
	STATUS,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	QUOTE_HEADER_ID,
	QUOTE_SHIPMENT_ID
    FROM ASO_QUOTE_LINE_ATTRIBS_EXT
    WHERE quote_line_id = p_qte_line_id;

--    l_Line_Attr_Ext_Rec		ASO_QUOTE_PUB.Line_Attribs_Ext_Rec_Type;

    l_line_attr_ext_count     NUMBER;

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

      FOR Line_Attr_Ext_rec IN c_Line_Attr_Ext LOOP
	   l_line_attr_ext_count := lx_line_attr_ext_tbl.COUNT+1;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).LINE_ATTRIBUTE_ID := line_attr_ext_rec.LINE_ATTRIBUTE_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).QUOTE_LINE_ID := line_attr_ext_rec.QUOTE_LINE_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).CREATION_DATE := line_attr_ext_rec.CREATION_DATE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).CREATED_BY := line_attr_ext_rec.CREATED_BY;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).LAST_UPDATE_DATE := line_attr_ext_rec.LAST_UPDATE_DATE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).LAST_UPDATED_BY := line_attr_ext_rec.LAST_UPDATED_BY;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).LAST_UPDATE_LOGIN := line_attr_ext_rec.LAST_UPDATE_LOGIN;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).REQUEST_ID := line_attr_ext_rec.REQUEST_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).PROGRAM_APPLICATION_ID := line_attr_ext_rec.PROGRAM_APPLICATION_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).PROGRAM_ID := line_attr_ext_rec.PROGRAM_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).PROGRAM_UPDATE_DATE := line_attr_ext_rec.PROGRAM_UPDATE_DATE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).ATTRIBUTE_TYPE_CODE := line_attr_ext_rec.ATTRIBUTE_TYPE_CODE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).NAME := line_attr_ext_rec.NAME;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).VALUE := line_attr_ext_rec.VALUE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).START_DATE_ACTIVE := line_attr_ext_rec.START_DATE_ACTIVE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).END_DATE_ACTIVE := line_attr_ext_rec.END_DATE_ACTIVE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).QUOTE_HEADER_ID := line_attr_ext_rec.QUOTE_HEADER_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).QUOTE_SHIPMENT_ID := line_attr_ext_rec.QUOTE_SHIPMENT_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).APPLICATION_ID := line_attr_ext_rec.APPLICATION_ID;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).STATUS := line_attr_ext_rec.STATUS;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).VALUE_TYPE := line_attr_ext_rec.VALUE_TYPE;
	   lx_line_attr_ext_tbl(l_line_attr_ext_count).QTE_LINE_INDEX := P_Line_Index;

--	  lx_line_attr_ext_tbl(lx_line_attr_ext_tbl.COUNT+1) := l_line_attr_ext_rec;

      END LOOP;
      RETURN lx_line_attr_ext_tbl;

END Query_Line_Attribs_Ext_Rows;


FUNCTION Query_Price_Attr_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_price_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
IS
    CURSOR c_price_attr IS
	SELECT
PRICE_ATTRIBUTE_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
REQUEST_ID,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
FLEX_TITLE,
PRICING_CONTEXT,
PRICING_ATTRIBUTE1,
PRICING_ATTRIBUTE2,
PRICING_ATTRIBUTE3,
PRICING_ATTRIBUTE4,
PRICING_ATTRIBUTE5,
PRICING_ATTRIBUTE6,
PRICING_ATTRIBUTE7,
PRICING_ATTRIBUTE8,
PRICING_ATTRIBUTE9,
PRICING_ATTRIBUTE10,
PRICING_ATTRIBUTE11,
PRICING_ATTRIBUTE12,
PRICING_ATTRIBUTE13,
PRICING_ATTRIBUTE14,
PRICING_ATTRIBUTE15,
PRICING_ATTRIBUTE16,
PRICING_ATTRIBUTE17,
PRICING_ATTRIBUTE18,
PRICING_ATTRIBUTE19,
PRICING_ATTRIBUTE20,
PRICING_ATTRIBUTE21,
PRICING_ATTRIBUTE22,
PRICING_ATTRIBUTE23,
PRICING_ATTRIBUTE24,
PRICING_ATTRIBUTE25,
PRICING_ATTRIBUTE26,
PRICING_ATTRIBUTE27,
PRICING_ATTRIBUTE28,
PRICING_ATTRIBUTE29,
PRICING_ATTRIBUTE30,
PRICING_ATTRIBUTE31,
PRICING_ATTRIBUTE32,
PRICING_ATTRIBUTE33,
PRICING_ATTRIBUTE34,
PRICING_ATTRIBUTE35,
PRICING_ATTRIBUTE36,
PRICING_ATTRIBUTE37,
PRICING_ATTRIBUTE38,
PRICING_ATTRIBUTE39,
PRICING_ATTRIBUTE40,
PRICING_ATTRIBUTE41,
PRICING_ATTRIBUTE42,
PRICING_ATTRIBUTE43,
PRICING_ATTRIBUTE44,
PRICING_ATTRIBUTE45,
PRICING_ATTRIBUTE46,
PRICING_ATTRIBUTE47,
PRICING_ATTRIBUTE48,
PRICING_ATTRIBUTE49,
PRICING_ATTRIBUTE50,
PRICING_ATTRIBUTE51,
PRICING_ATTRIBUTE52,
PRICING_ATTRIBUTE53,
PRICING_ATTRIBUTE54,
PRICING_ATTRIBUTE55,
PRICING_ATTRIBUTE56,
PRICING_ATTRIBUTE57,
PRICING_ATTRIBUTE58,
PRICING_ATTRIBUTE59,
PRICING_ATTRIBUTE60,
PRICING_ATTRIBUTE61,
PRICING_ATTRIBUTE62,
PRICING_ATTRIBUTE63,
PRICING_ATTRIBUTE64,
PRICING_ATTRIBUTE65,
PRICING_ATTRIBUTE66,
PRICING_ATTRIBUTE67,
PRICING_ATTRIBUTE68,
PRICING_ATTRIBUTE69,
PRICING_ATTRIBUTE70,
PRICING_ATTRIBUTE71,
PRICING_ATTRIBUTE72,
PRICING_ATTRIBUTE73,
PRICING_ATTRIBUTE74,
PRICING_ATTRIBUTE75,
PRICING_ATTRIBUTE76,
PRICING_ATTRIBUTE77,
PRICING_ATTRIBUTE78,
PRICING_ATTRIBUTE79,
PRICING_ATTRIBUTE80,
PRICING_ATTRIBUTE81,
PRICING_ATTRIBUTE82,
PRICING_ATTRIBUTE83,
PRICING_ATTRIBUTE84,
PRICING_ATTRIBUTE85,
PRICING_ATTRIBUTE86,
PRICING_ATTRIBUTE87,
PRICING_ATTRIBUTE88,
PRICING_ATTRIBUTE89,
PRICING_ATTRIBUTE90,
PRICING_ATTRIBUTE91,
PRICING_ATTRIBUTE92,
PRICING_ATTRIBUTE93,
PRICING_ATTRIBUTE94,
PRICING_ATTRIBUTE95,
PRICING_ATTRIBUTE96,
PRICING_ATTRIBUTE97,
PRICING_ATTRIBUTE98,
PRICING_ATTRIBUTE99,
PRICING_ATTRIBUTE100,
CONTEXT,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15
     FROM ASO_PRICE_ATTRIBUTES
	WHERE quote_header_id = p_qte_header_id AND
	   (quote_line_id = p_qte_line_id OR
		(quote_line_id IS NULL AND p_qte_line_id IS NULL));

--    l_price_attr_rec             ASO_QUOTE_PUB.Price_Attributes_Rec_Type;
	l_price_attr_count  NUMBER;

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

      FOR price_attr_rec IN c_price_attr LOOP
	   l_price_attr_count := lx_price_attr_tbl.COUNT+1;

	   lx_price_attr_tbl(l_price_attr_count).PRICE_ATTRIBUTE_ID := price_attr_rec.PRICE_ATTRIBUTE_ID;
	   lx_price_attr_tbl(l_price_attr_count).CREATION_DATE := price_attr_rec.CREATION_DATE;
	   lx_price_attr_tbl(l_price_attr_count).CREATED_BY := price_attr_rec.CREATED_BY;
	   lx_price_attr_tbl(l_price_attr_count).LAST_UPDATE_DATE := price_attr_rec.LAST_UPDATE_DATE;
	   lx_price_attr_tbl(l_price_attr_count).LAST_UPDATED_BY := price_attr_rec.LAST_UPDATED_BY;
	   lx_price_attr_tbl(l_price_attr_count).LAST_UPDATE_LOGIN := price_attr_rec.LAST_UPDATE_LOGIN;
	   lx_price_attr_tbl(l_price_attr_count).REQUEST_ID := price_attr_rec.REQUEST_ID;
	   lx_price_attr_tbl(l_price_attr_count).PROGRAM_APPLICATION_ID := price_attr_rec.PROGRAM_APPLICATION_ID;
	   lx_price_attr_tbl(l_price_attr_count).PROGRAM_ID := price_attr_rec.PROGRAM_ID;
	   lx_price_attr_tbl(l_price_attr_count).PROGRAM_UPDATE_DATE := price_attr_rec.PROGRAM_UPDATE_DATE;
	   lx_price_attr_tbl(l_price_attr_count).QUOTE_HEADER_ID := price_attr_rec.QUOTE_HEADER_ID;
	   lx_price_attr_tbl(l_price_attr_count).QUOTE_LINE_ID := price_attr_rec.QUOTE_LINE_ID;
	   lx_price_attr_tbl(l_price_attr_count).FLEX_TITLE := price_attr_rec.FLEX_TITLE;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_CONTEXT := price_attr_rec.PRICING_CONTEXT;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE1 := price_attr_rec.PRICING_ATTRIBUTE1;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE2 := price_attr_rec.PRICING_ATTRIBUTE2;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE3 := price_attr_rec.PRICING_ATTRIBUTE3;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE4 := price_attr_rec.PRICING_ATTRIBUTE4;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE5 := price_attr_rec.PRICING_ATTRIBUTE5;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE6 := price_attr_rec.PRICING_ATTRIBUTE6;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE7 := price_attr_rec.PRICING_ATTRIBUTE7;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE8 := price_attr_rec.PRICING_ATTRIBUTE8;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE9 := price_attr_rec.PRICING_ATTRIBUTE9;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE10 := price_attr_rec.PRICING_ATTRIBUTE10;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE11 := price_attr_rec.PRICING_ATTRIBUTE11;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE12 := price_attr_rec.PRICING_ATTRIBUTE12;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE13 := price_attr_rec.PRICING_ATTRIBUTE13;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE14 := price_attr_rec.PRICING_ATTRIBUTE14;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE15 := price_attr_rec.PRICING_ATTRIBUTE15;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE16 := price_attr_rec.PRICING_ATTRIBUTE16;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE17 := price_attr_rec.PRICING_ATTRIBUTE17;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE18 := price_attr_rec.PRICING_ATTRIBUTE18;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE19 := price_attr_rec.PRICING_ATTRIBUTE19;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE20 := price_attr_rec.PRICING_ATTRIBUTE20;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE21 := price_attr_rec.PRICING_ATTRIBUTE21;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE22 := price_attr_rec.PRICING_ATTRIBUTE22;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE23 := price_attr_rec.PRICING_ATTRIBUTE23;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE24 := price_attr_rec.PRICING_ATTRIBUTE24;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE25 := price_attr_rec.PRICING_ATTRIBUTE25;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE26 := price_attr_rec.PRICING_ATTRIBUTE26;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE27 := price_attr_rec.PRICING_ATTRIBUTE27;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE28 := price_attr_rec.PRICING_ATTRIBUTE28;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE29 := price_attr_rec.PRICING_ATTRIBUTE29;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE30 := price_attr_rec.PRICING_ATTRIBUTE30;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE31 := price_attr_rec.PRICING_ATTRIBUTE31;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE32 := price_attr_rec.PRICING_ATTRIBUTE32;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE33 := price_attr_rec.PRICING_ATTRIBUTE33;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE34 := price_attr_rec.PRICING_ATTRIBUTE34;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE35 := price_attr_rec.PRICING_ATTRIBUTE35;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE36 := price_attr_rec.PRICING_ATTRIBUTE36;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE37 := price_attr_rec.PRICING_ATTRIBUTE37;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE38 := price_attr_rec.PRICING_ATTRIBUTE38;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE39 := price_attr_rec.PRICING_ATTRIBUTE39;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE40 := price_attr_rec.PRICING_ATTRIBUTE40;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE41 := price_attr_rec.PRICING_ATTRIBUTE41;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE42 := price_attr_rec.PRICING_ATTRIBUTE42;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE43 := price_attr_rec.PRICING_ATTRIBUTE43;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE44 := price_attr_rec.PRICING_ATTRIBUTE44;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE45 := price_attr_rec.PRICING_ATTRIBUTE45;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE46 := price_attr_rec.PRICING_ATTRIBUTE46;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE47 := price_attr_rec.PRICING_ATTRIBUTE47;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE48 := price_attr_rec.PRICING_ATTRIBUTE48;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE49 := price_attr_rec.PRICING_ATTRIBUTE49;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE50 := price_attr_rec.PRICING_ATTRIBUTE50;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE51 := price_attr_rec.PRICING_ATTRIBUTE51;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE52 := price_attr_rec.PRICING_ATTRIBUTE52;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE53 := price_attr_rec.PRICING_ATTRIBUTE53;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE54 := price_attr_rec.PRICING_ATTRIBUTE54;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE55 := price_attr_rec.PRICING_ATTRIBUTE55;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE56 := price_attr_rec.PRICING_ATTRIBUTE56;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE57 := price_attr_rec.PRICING_ATTRIBUTE57;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE58 := price_attr_rec.PRICING_ATTRIBUTE58;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE59 := price_attr_rec.PRICING_ATTRIBUTE59;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE60 := price_attr_rec.PRICING_ATTRIBUTE60;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE61 := price_attr_rec.PRICING_ATTRIBUTE61;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE62 := price_attr_rec.PRICING_ATTRIBUTE62;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE63 := price_attr_rec.PRICING_ATTRIBUTE63;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE64 := price_attr_rec.PRICING_ATTRIBUTE64;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE65 := price_attr_rec.PRICING_ATTRIBUTE65;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE66 := price_attr_rec.PRICING_ATTRIBUTE66;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE67 := price_attr_rec.PRICING_ATTRIBUTE67;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE68 := price_attr_rec.PRICING_ATTRIBUTE68;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE69 := price_attr_rec.PRICING_ATTRIBUTE69;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE70 := price_attr_rec.PRICING_ATTRIBUTE70;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE71 := price_attr_rec.PRICING_ATTRIBUTE71;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE72 := price_attr_rec.PRICING_ATTRIBUTE72;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE73 := price_attr_rec.PRICING_ATTRIBUTE73;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE74 := price_attr_rec.PRICING_ATTRIBUTE74;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE75 := price_attr_rec.PRICING_ATTRIBUTE75;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE76 := price_attr_rec.PRICING_ATTRIBUTE76;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE77 := price_attr_rec.PRICING_ATTRIBUTE77;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE78 := price_attr_rec.PRICING_ATTRIBUTE78;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE79 := price_attr_rec.PRICING_ATTRIBUTE79;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE80 := price_attr_rec.PRICING_ATTRIBUTE80;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE81 := price_attr_rec.PRICING_ATTRIBUTE81;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE82 := price_attr_rec.PRICING_ATTRIBUTE82;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE83 := price_attr_rec.PRICING_ATTRIBUTE83;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE84 := price_attr_rec.PRICING_ATTRIBUTE84;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE85 := price_attr_rec.PRICING_ATTRIBUTE85;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE86 := price_attr_rec.PRICING_ATTRIBUTE86;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE87 := price_attr_rec.PRICING_ATTRIBUTE87;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE88 := price_attr_rec.PRICING_ATTRIBUTE88;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE89 := price_attr_rec.PRICING_ATTRIBUTE89;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE90 := price_attr_rec.PRICING_ATTRIBUTE90;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE91 := price_attr_rec.PRICING_ATTRIBUTE91;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE92 := price_attr_rec.PRICING_ATTRIBUTE92;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE93 := price_attr_rec.PRICING_ATTRIBUTE93;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE94 := price_attr_rec.PRICING_ATTRIBUTE94;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE95 := price_attr_rec.PRICING_ATTRIBUTE95;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE96 := price_attr_rec.PRICING_ATTRIBUTE96;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE97 := price_attr_rec.PRICING_ATTRIBUTE97;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE98 := price_attr_rec.PRICING_ATTRIBUTE98;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE99 := price_attr_rec.PRICING_ATTRIBUTE99;
 	  lx_price_attr_tbl(l_price_attr_count).PRICING_ATTRIBUTE100 := price_attr_rec.PRICING_ATTRIBUTE100;
	  lx_price_attr_tbl(l_price_attr_count).CONTEXT := price_attr_rec.CONTEXT;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE1 := price_attr_rec.ATTRIBUTE1;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE2 := price_attr_rec.ATTRIBUTE2;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE3 := price_attr_rec.ATTRIBUTE3;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE4 := price_attr_rec.ATTRIBUTE4;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE5 := price_attr_rec.ATTRIBUTE5;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE6 := price_attr_rec.ATTRIBUTE6;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE7 := price_attr_rec.ATTRIBUTE7;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE8 := price_attr_rec.ATTRIBUTE8;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE9 := price_attr_rec.ATTRIBUTE9;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE10 := price_attr_rec.ATTRIBUTE10;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE11 := price_attr_rec.ATTRIBUTE11;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE12 := price_attr_rec.ATTRIBUTE12;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE13 := price_attr_rec.ATTRIBUTE13;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE14 := price_attr_rec.ATTRIBUTE14;
	  lx_price_attr_tbl(l_price_attr_count).ATTRIBUTE15 := price_attr_rec.ATTRIBUTE15;
	  lx_price_attr_tbl(l_price_attr_count).QTE_LINE_INDEX := P_Line_Index;

--	  lx_price_attr_tbl(lx_price_attr_tbl.COUNT+1) := l_price_attr_rec;

      END LOOP;
      RETURN lx_price_attr_tbl;

END Query_Price_Attr_Rows;


FUNCTION Query_Price_Adj_Rltship_Rows (
    P_Price_Adjustment_Id     IN  NUMBER,
    P_Line_Index              IN  NUMBER,
    lx_price_adj_rltd_tbl     IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
IS
  CURSOR C_Price_Adj_Rltd IS
   SELECT
	ADJ_RELATIONSHIP_ID
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,PROGRAM_APPLICATION_ID
	,PROGRAM_ID
	,PROGRAM_UPDATE_DATE
	,REQUEST_ID
	,QUOTE_LINE_ID
	,PRICE_ADJUSTMENT_ID
	,RLTD_PRICE_ADJ_ID
	,QUOTE_SHIPMENT_ID
	,SECURITY_GROUP_ID
	,OBJECT_VERSION_NUMBER
    FROM aso_price_adj_relationships
    WHERE price_adjustment_id = P_Price_Adjustment_Id;

--	l_price_adj_rltd_rec         ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
	l_price_adj_rltd_count   NUMBER;

BEGIN
--Fix for bug 5714535.  Setting the output table structure directly instead of
--setting it through  the local record structure.

FOR C_Price_Adj_Rltd_Rec IN C_Price_Adj_Rltd LOOP
l_price_adj_rltd_count := lx_price_adj_rltd_tbl.COUNT+1;

lx_price_adj_rltd_tbl(l_price_adj_rltd_count).ADJ_RELATIONSHIP_ID := C_Price_Adj_Rltd_Rec.ADJ_RELATIONSHIP_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).CREATION_DATE := C_Price_Adj_Rltd_Rec.CREATION_DATE;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).CREATED_BY := C_Price_Adj_Rltd_Rec.CREATED_BY;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).LAST_UPDATE_DATE := C_Price_Adj_Rltd_Rec.LAST_UPDATE_DATE;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).LAST_UPDATED_BY := C_Price_Adj_Rltd_Rec.LAST_UPDATED_BY;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).LAST_UPDATE_LOGIN := C_Price_Adj_Rltd_Rec.LAST_UPDATE_LOGIN;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).PROGRAM_APPLICATION_ID := C_Price_Adj_Rltd_Rec.PROGRAM_APPLICATION_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).PROGRAM_ID := C_Price_Adj_Rltd_Rec.PROGRAM_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).PROGRAM_UPDATE_DATE := C_Price_Adj_Rltd_Rec.PROGRAM_UPDATE_DATE;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).REQUEST_ID := C_Price_Adj_Rltd_Rec.REQUEST_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).QUOTE_LINE_ID := C_Price_Adj_Rltd_Rec.QUOTE_LINE_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).PRICE_ADJUSTMENT_ID := C_Price_Adj_Rltd_Rec.PRICE_ADJUSTMENT_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).RLTD_PRICE_ADJ_ID := C_Price_Adj_Rltd_Rec.RLTD_PRICE_ADJ_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).QUOTE_SHIPMENT_ID := C_Price_Adj_Rltd_Rec.QUOTE_SHIPMENT_ID;
lx_price_adj_rltd_tbl(l_price_adj_rltd_count).QTE_LINE_INDEX := P_Line_Index;

--lx_price_adj_rltd_tbl(lx_price_adj_rltd_tbl.COUNT+1) := l_price_adj_rltd_rec;

END LOOP;
RETURN lx_price_adj_rltd_tbl;

END  Query_Price_Adj_Rltship_Rows;


FUNCTION Query_Price_Adj_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Rec		IN  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Line_Index         IN  NUMBER,
    Lx_price_adj_rltship_tbl  IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    Lx_price_adj_tbl          IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type
    ) RETURN VARCHAR2
IS
--Begin fix for bug 5575844.
--Original cursor has been split into separate cursors for
--header and line adjustments for performance reasons.

   CURSOR c_price_adj_hdr IS
   SELECT
     PRICE_ADJUSTMENT_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	REQUEST_ID,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	MODIFIER_HEADER_ID,
	MODIFIER_LINE_ID,
	MODIFIER_LINE_TYPE_CODE,
	MODIFIER_MECHANISM_TYPE_CODE,
	MODIFIED_FROM,
     MODIFIED_TO,
	OPERAND,
	ARITHMETIC_OPERATOR,
	AUTOMATIC_FLAG,
	UPDATE_ALLOWABLE_FLAG,
     UPDATED_FLAG,
	APPLIED_FLAG,
	ON_INVOICE_FLAG,
	PRICING_PHASE_ID,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
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
	TAX_CODE,
	TAX_EXEMPT_FLAG,
	TAX_EXEMPT_NUMBER,
	TAX_EXEMPT_REASON_CODE,
	PARENT_ADJUSTMENT_ID,
	INVOICED_FLAG,
	ESTIMATED_FLAG,
	INC_IN_SALES_PERFORMANCE,
	SPLIT_ACTION_CODE,
	ADJUSTED_AMOUNT,
	CHARGE_TYPE_CODE,
	CHARGE_SUBTYPE_CODE,
	RANGE_BREAK_QUANTITY,
	ACCRUAL_CONVERSION_RATE,
	PRICING_GROUP_SEQUENCE,
	ACCRUAL_FLAG,
	LIST_LINE_NO,
	SOURCE_SYSTEM_CODE,
	BENEFIT_QTY,
	BENEFIT_UOM_CODE,
	PRINT_ON_INVOICE_FLAG,
	EXPIRATION_DATE,
	REBATE_TRANSACTION_TYPE_CODE,
	REBATE_TRANSACTION_REFERENCE,
	REBATE_PAYMENT_SYSTEM_CODE,
	REDEEMED_DATE,
	REDEEMED_FLAG,
	MODIFIER_LEVEL_CODE,
	PRICE_BREAK_TYPE_CODE,
	SUBSTITUTION_ATTRIBUTE,
	PRORATION_TYPE_CODE,
	INCLUDE_ON_RETURNS_FLAG,
	CREDIT_OR_CHARGE_FLAG,
	ORIG_SYS_DISCOUNT_REF,
	CHANGE_REASON_CODE,
	CHANGE_REASON_TEXT,
	COST_ID,
	LIST_LINE_TYPE_CODE,
	UPDATE_ALLOWED,
	CHANGE_SEQUENCE,
	LIST_HEADER_ID,
	LIST_LINE_ID,
	QUOTE_SHIPMENT_ID
    FROM ASO_PRICE_ADJUSTMENTS
    WHERE quote_header_id = p_qte_header_id AND
	   quote_line_id is null AND
	   (applied_flag IS NOT NULL AND applied_flag = 'Y')
    UNION ALL
    SELECT
     PRICE_ADJUSTMENT_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID,
     QUOTE_HEADER_ID,
     QUOTE_LINE_ID,
     MODIFIER_HEADER_ID,
     MODIFIER_LINE_ID,
     MODIFIER_LINE_TYPE_CODE,
     MODIFIER_MECHANISM_TYPE_CODE,
     MODIFIED_FROM,
     MODIFIED_TO,
     OPERAND,
     ARITHMETIC_OPERATOR,
     AUTOMATIC_FLAG,
     UPDATE_ALLOWABLE_FLAG,
     UPDATED_FLAG,
     APPLIED_FLAG,
     ON_INVOICE_FLAG,
     PRICING_PHASE_ID,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
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
     TAX_CODE,
     TAX_EXEMPT_FLAG,
     TAX_EXEMPT_NUMBER,
     TAX_EXEMPT_REASON_CODE,
     PARENT_ADJUSTMENT_ID,
     INVOICED_FLAG,
     ESTIMATED_FLAG,
     INC_IN_SALES_PERFORMANCE,
     SPLIT_ACTION_CODE,
     ADJUSTED_AMOUNT,
     CHARGE_TYPE_CODE,
     CHARGE_SUBTYPE_CODE,
     RANGE_BREAK_QUANTITY,
     ACCRUAL_CONVERSION_RATE,
     PRICING_GROUP_SEQUENCE,
     ACCRUAL_FLAG,
     LIST_LINE_NO,
     SOURCE_SYSTEM_CODE,
     BENEFIT_QTY,
     BENEFIT_UOM_CODE,
     PRINT_ON_INVOICE_FLAG,
     EXPIRATION_DATE,
     REBATE_TRANSACTION_TYPE_CODE,
     REBATE_TRANSACTION_REFERENCE,
     REBATE_PAYMENT_SYSTEM_CODE,
     REDEEMED_DATE,
     REDEEMED_FLAG,
     MODIFIER_LEVEL_CODE,
     PRICE_BREAK_TYPE_CODE,
     SUBSTITUTION_ATTRIBUTE,
     PRORATION_TYPE_CODE,
     INCLUDE_ON_RETURNS_FLAG,
     CREDIT_OR_CHARGE_FLAG,
     ORIG_SYS_DISCOUNT_REF,
     CHANGE_REASON_CODE,
     CHANGE_REASON_TEXT,
     COST_ID,
     LIST_LINE_TYPE_CODE,
     UPDATE_ALLOWED,
     CHANGE_SEQUENCE,
     LIST_HEADER_ID,
	LIST_LINE_ID,
     QUOTE_SHIPMENT_ID
    FROM ASO_PRICE_ADJUSTMENTS c
    WHERE quote_header_id = p_qte_header_id AND
          quote_line_id IS NULL AND
		 EXISTS
		   (select NULL
		    from aso_price_adjustments a, aso_price_adj_relationships b
			where a.price_adjustment_id = b.price_adjustment_id
			and c.price_adjustment_id = b.rltd_price_adj_id
                        and a.quote_header_id = p_qte_header_id
                        and a.quote_line_id IS NULL
			and a.modifier_line_type_code = 'PBH'
			and (a.applied_flag IS NOT NULL AND a.applied_flag = 'Y'));

   CURSOR c_price_adj_line IS
    SELECT
     PRICE_ADJUSTMENT_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	REQUEST_ID,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	MODIFIER_HEADER_ID,
	MODIFIER_LINE_ID,
	MODIFIER_LINE_TYPE_CODE,
	MODIFIER_MECHANISM_TYPE_CODE,
	MODIFIED_FROM,
     MODIFIED_TO,
	OPERAND,
	ARITHMETIC_OPERATOR,
	AUTOMATIC_FLAG,
	UPDATE_ALLOWABLE_FLAG,
     UPDATED_FLAG,
	APPLIED_FLAG,
	ON_INVOICE_FLAG,
	PRICING_PHASE_ID,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
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
	TAX_CODE,
	TAX_EXEMPT_FLAG,
	TAX_EXEMPT_NUMBER,
	TAX_EXEMPT_REASON_CODE,
	PARENT_ADJUSTMENT_ID,
	INVOICED_FLAG,
	ESTIMATED_FLAG,
	INC_IN_SALES_PERFORMANCE,
	SPLIT_ACTION_CODE,
	ADJUSTED_AMOUNT,
	CHARGE_TYPE_CODE,
	CHARGE_SUBTYPE_CODE,
	RANGE_BREAK_QUANTITY,
	ACCRUAL_CONVERSION_RATE,
	PRICING_GROUP_SEQUENCE,
	ACCRUAL_FLAG,
	LIST_LINE_NO,
	SOURCE_SYSTEM_CODE,
	BENEFIT_QTY,
	BENEFIT_UOM_CODE,
	PRINT_ON_INVOICE_FLAG,
	EXPIRATION_DATE,
	REBATE_TRANSACTION_TYPE_CODE,
	REBATE_TRANSACTION_REFERENCE,
	REBATE_PAYMENT_SYSTEM_CODE,
	REDEEMED_DATE,
	REDEEMED_FLAG,
	MODIFIER_LEVEL_CODE,
	PRICE_BREAK_TYPE_CODE,
	SUBSTITUTION_ATTRIBUTE,
	PRORATION_TYPE_CODE,
	INCLUDE_ON_RETURNS_FLAG,
	CREDIT_OR_CHARGE_FLAG,
	ORIG_SYS_DISCOUNT_REF,
	CHANGE_REASON_CODE,
	CHANGE_REASON_TEXT,
	COST_ID,
	LIST_LINE_TYPE_CODE,
	UPDATE_ALLOWED,
	CHANGE_SEQUENCE,
	LIST_HEADER_ID,
	LIST_LINE_ID,
	QUOTE_SHIPMENT_ID
    FROM ASO_PRICE_ADJUSTMENTS
    WHERE quote_header_id = p_qte_header_id AND
          quote_line_id = p_qte_line_rec.quote_line_id AND
          (applied_flag IS NOT NULL AND applied_flag = 'Y')
    UNION ALL
    SELECT
     PRICE_ADJUSTMENT_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID,
     QUOTE_HEADER_ID,
     QUOTE_LINE_ID,
     MODIFIER_HEADER_ID,
     MODIFIER_LINE_ID,
     MODIFIER_LINE_TYPE_CODE,
     MODIFIER_MECHANISM_TYPE_CODE,
     MODIFIED_FROM,
     MODIFIED_TO,
     OPERAND,
     ARITHMETIC_OPERATOR,
     AUTOMATIC_FLAG,
     UPDATE_ALLOWABLE_FLAG,
     UPDATED_FLAG,
     APPLIED_FLAG,
     ON_INVOICE_FLAG,
     PRICING_PHASE_ID,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
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
     TAX_CODE,
     TAX_EXEMPT_FLAG,
     TAX_EXEMPT_NUMBER,
     TAX_EXEMPT_REASON_CODE,
     PARENT_ADJUSTMENT_ID,
     INVOICED_FLAG,
     ESTIMATED_FLAG,
     INC_IN_SALES_PERFORMANCE,
     SPLIT_ACTION_CODE,
     ADJUSTED_AMOUNT,
     CHARGE_TYPE_CODE,
     CHARGE_SUBTYPE_CODE,
     RANGE_BREAK_QUANTITY,
     ACCRUAL_CONVERSION_RATE,
     PRICING_GROUP_SEQUENCE,
     ACCRUAL_FLAG,
     LIST_LINE_NO,
     SOURCE_SYSTEM_CODE,
     BENEFIT_QTY,
     BENEFIT_UOM_CODE,
     PRINT_ON_INVOICE_FLAG,
     EXPIRATION_DATE,
     REBATE_TRANSACTION_TYPE_CODE,
     REBATE_TRANSACTION_REFERENCE,
     REBATE_PAYMENT_SYSTEM_CODE,
     REDEEMED_DATE,
     REDEEMED_FLAG,
     MODIFIER_LEVEL_CODE,
     PRICE_BREAK_TYPE_CODE,
     SUBSTITUTION_ATTRIBUTE,
     PRORATION_TYPE_CODE,
     INCLUDE_ON_RETURNS_FLAG,
     CREDIT_OR_CHARGE_FLAG,
     ORIG_SYS_DISCOUNT_REF,
     CHANGE_REASON_CODE,
     CHANGE_REASON_TEXT,
     COST_ID,
     LIST_LINE_TYPE_CODE,
     UPDATE_ALLOWED,
     CHANGE_SEQUENCE,
     LIST_HEADER_ID,
     LIST_LINE_ID,
     QUOTE_SHIPMENT_ID
    FROM ASO_PRICE_ADJUSTMENTS c
    WHERE quote_header_id = p_qte_header_id AND
          quote_line_id = p_qte_line_rec.quote_line_id AND
		 EXISTS
		   (select NULL
		    from aso_price_adjustments a, aso_price_adj_relationships b
			where a.price_adjustment_id = b.price_adjustment_id
			and c.price_adjustment_id = b.rltd_price_adj_id
                        and a.quote_header_id = p_qte_header_id
                        and a.quote_line_id = p_qte_line_rec.quote_line_id
			and a.modifier_line_type_code = 'PBH'
			and (a.applied_flag IS NOT NULL AND a.applied_flag = 'Y'));

--End fix for bug 5575844.

	l_price_adj_count	NUMBER;
	l_status	VARCHAR2(1) := 'S';

BEGIN
--Fix for bug 5736820.  Setting the output table structure directly instead of
--setting it through  the local record structure.

--Begin fix for bug 5575844.
	IF p_qte_line_rec.quote_line_id IS NULL THEN
      FOR price_adj_rec IN c_price_adj_hdr LOOP
	  l_price_adj_count := lx_price_adj_tbl.COUNT+1;

	  lx_price_adj_tbl(l_price_adj_count).PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
	  lx_price_adj_tbl(l_price_adj_count).CREATION_DATE := price_adj_rec.CREATION_DATE;
	  lx_price_adj_tbl(l_price_adj_count).CREATED_BY := price_adj_rec.CREATED_BY;
	  lx_price_adj_tbl(l_price_adj_count).LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
	  lx_price_adj_tbl(l_price_adj_count).LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
	  lx_price_adj_tbl(l_price_adj_count).LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
	  lx_price_adj_tbl(l_price_adj_count).REQUEST_ID := price_adj_rec.REQUEST_ID;
	  lx_price_adj_tbl(l_price_adj_count).PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
	  lx_price_adj_tbl(l_price_adj_count).PROGRAM_ID := price_adj_rec.PROGRAM_ID;
	  lx_price_adj_tbl(l_price_adj_count).PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
	  lx_price_adj_tbl(l_price_adj_count).QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
	  lx_price_adj_tbl(l_price_adj_count).QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_MECHANISM_TYPE_CODE
	  	  	  	  	:= price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIED_TO := price_adj_rec.MODIFIED_TO;
	  lx_price_adj_tbl(l_price_adj_count).OPERAND := price_adj_rec.OPERAND;
	  lx_price_adj_tbl(l_price_adj_count).ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
	  lx_price_adj_tbl(l_price_adj_count).AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
	  lx_price_adj_tbl(l_price_adj_count).QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
     lx_price_adj_tbl(l_price_adj_count).TAX_CODE   := price_adj_rec.TAX_CODE;
	lx_price_adj_tbl(l_price_adj_count).TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
	lx_price_adj_tbl(l_price_adj_count).TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
	lx_price_adj_tbl(l_price_adj_count).TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
	lx_price_adj_tbl(l_price_adj_count).PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
	lx_price_adj_tbl(l_price_adj_count).INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
	lx_price_adj_tbl(l_price_adj_count).ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
	lx_price_adj_tbl(l_price_adj_count).INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
	lx_price_adj_tbl(l_price_adj_count).SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
	lx_price_adj_tbl(l_price_adj_count).ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
	lx_price_adj_tbl(l_price_adj_count).CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
	lx_price_adj_tbl(l_price_adj_count).ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
	lx_price_adj_tbl(l_price_adj_count).PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
	lx_price_adj_tbl(l_price_adj_count).ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
	lx_price_adj_tbl(l_price_adj_count).LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
	lx_price_adj_tbl(l_price_adj_count).SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
	lx_price_adj_tbl(l_price_adj_count).BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
	lx_price_adj_tbl(l_price_adj_count).BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
	lx_price_adj_tbl(l_price_adj_count).PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
	lx_price_adj_tbl(l_price_adj_count).EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
	lx_price_adj_tbl(l_price_adj_count).REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
	lx_price_adj_tbl(l_price_adj_count).REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
	lx_price_adj_tbl(l_price_adj_count).REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
	lx_price_adj_tbl(l_price_adj_count).REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
	lx_price_adj_tbl(l_price_adj_count).MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
	lx_price_adj_tbl(l_price_adj_count).PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
	lx_price_adj_tbl(l_price_adj_count).PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
	lx_price_adj_tbl(l_price_adj_count).CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
	lx_price_adj_tbl(l_price_adj_count).ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
	lx_price_adj_tbl(l_price_adj_count).CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
	lx_price_adj_tbl(l_price_adj_count).CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
	lx_price_adj_tbl(l_price_adj_count).COST_ID := price_adj_rec.COST_ID;
	--lx_price_adj_tbl(l_price_adj_count).LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
	lx_price_adj_tbl(l_price_adj_count).CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
	--lx_price_adj_tbl(l_price_adj_count).LIST_HEADER_ID := price_adj_rec.LIST_HEADER_ID;
	--lx_price_adj_tbl(l_price_adj_count).LIST_LINE_ID := price_adj_rec.LIST_LINE_ID;
	lx_price_adj_tbl(l_price_adj_count).QTE_LINE_INDEX := P_Line_Index;

     -- 2800749 vtariker
     IF p_qte_line_rec.line_category_code = 'RETURN' AND
        lx_price_adj_tbl(l_price_adj_count).modifier_line_type_code = 'FREIGHT_CHARGE' THEN
         lx_price_adj_tbl(l_price_adj_count).Credit_Or_Charge_Flag := 'C';
     END IF;
     -- 2800749 vtariker

     lx_price_adj_rltship_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Price_Adj_Rltship_Rows(
                                         lx_price_adj_tbl(l_price_adj_count).price_adjustment_id,
                                         P_Line_Index,
                                         lx_price_adj_rltship_tbl);

--	lx_price_adj_tbl(lx_price_adj_tbl.COUNT+1) := l_price_adj_rec;

   END LOOP;
  ELSE
      FOR price_adj_rec IN c_price_adj_line LOOP
	  l_price_adj_count := lx_price_adj_tbl.COUNT+1;

	  lx_price_adj_tbl(l_price_adj_count).PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
	  lx_price_adj_tbl(l_price_adj_count).CREATION_DATE := price_adj_rec.CREATION_DATE;
	  lx_price_adj_tbl(l_price_adj_count).CREATED_BY := price_adj_rec.CREATED_BY;
	  lx_price_adj_tbl(l_price_adj_count).LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
	  lx_price_adj_tbl(l_price_adj_count).LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
	  lx_price_adj_tbl(l_price_adj_count).LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
	  lx_price_adj_tbl(l_price_adj_count).REQUEST_ID := price_adj_rec.REQUEST_ID;
	  lx_price_adj_tbl(l_price_adj_count).PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
	  lx_price_adj_tbl(l_price_adj_count).PROGRAM_ID := price_adj_rec.PROGRAM_ID;
	  lx_price_adj_tbl(l_price_adj_count).PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
	  lx_price_adj_tbl(l_price_adj_count).QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
	  lx_price_adj_tbl(l_price_adj_count).QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIER_MECHANISM_TYPE_CODE
	  	  	  	  	:= price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
	  lx_price_adj_tbl(l_price_adj_count).MODIFIED_TO := price_adj_rec.MODIFIED_TO;
	  lx_price_adj_tbl(l_price_adj_count).OPERAND := price_adj_rec.OPERAND;
	  lx_price_adj_tbl(l_price_adj_count).ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
	  lx_price_adj_tbl(l_price_adj_count).AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
	  lx_price_adj_tbl(l_price_adj_count).PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
	  lx_price_adj_tbl(l_price_adj_count).QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
	  lx_price_adj_tbl(l_price_adj_count).ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
     lx_price_adj_tbl(l_price_adj_count).TAX_CODE   := price_adj_rec.TAX_CODE;
	lx_price_adj_tbl(l_price_adj_count).TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
	lx_price_adj_tbl(l_price_adj_count).TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
	lx_price_adj_tbl(l_price_adj_count).TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
	lx_price_adj_tbl(l_price_adj_count).PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
	lx_price_adj_tbl(l_price_adj_count).INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
	lx_price_adj_tbl(l_price_adj_count).ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
	lx_price_adj_tbl(l_price_adj_count).INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
	lx_price_adj_tbl(l_price_adj_count).SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
	lx_price_adj_tbl(l_price_adj_count).ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
	lx_price_adj_tbl(l_price_adj_count).CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
	lx_price_adj_tbl(l_price_adj_count).ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
	lx_price_adj_tbl(l_price_adj_count).PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
	lx_price_adj_tbl(l_price_adj_count).ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
	lx_price_adj_tbl(l_price_adj_count).LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
	lx_price_adj_tbl(l_price_adj_count).SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
	lx_price_adj_tbl(l_price_adj_count).BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
	lx_price_adj_tbl(l_price_adj_count).BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
	lx_price_adj_tbl(l_price_adj_count).PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
	lx_price_adj_tbl(l_price_adj_count).EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
	lx_price_adj_tbl(l_price_adj_count).REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
	lx_price_adj_tbl(l_price_adj_count).REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
	lx_price_adj_tbl(l_price_adj_count).REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
	lx_price_adj_tbl(l_price_adj_count).REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
	lx_price_adj_tbl(l_price_adj_count).MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
	lx_price_adj_tbl(l_price_adj_count).PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
	lx_price_adj_tbl(l_price_adj_count).PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
	lx_price_adj_tbl(l_price_adj_count).CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
	lx_price_adj_tbl(l_price_adj_count).ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
	lx_price_adj_tbl(l_price_adj_count).CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
	lx_price_adj_tbl(l_price_adj_count).CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
	lx_price_adj_tbl(l_price_adj_count).COST_ID := price_adj_rec.COST_ID;
	--lx_price_adj_tbl(l_price_adj_count).LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
	lx_price_adj_tbl(l_price_adj_count).UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
	lx_price_adj_tbl(l_price_adj_count).CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
	--lx_price_adj_tbl(l_price_adj_count).LIST_HEADER_ID := price_adj_rec.LIST_HEADER_ID;
	--lx_price_adj_tbl(l_price_adj_count).LIST_LINE_ID := price_adj_rec.LIST_LINE_ID;
	lx_price_adj_tbl(l_price_adj_count).QTE_LINE_INDEX := P_Line_Index;

     -- 2800749 vtariker
     IF p_qte_line_rec.line_category_code = 'RETURN' AND
        lx_price_adj_tbl(l_price_adj_count).modifier_line_type_code = 'FREIGHT_CHARGE' THEN
         lx_price_adj_tbl(l_price_adj_count).Credit_Or_Charge_Flag := 'C';
     END IF;
     -- 2800749 vtariker

     lx_price_adj_rltship_tbl := ASO_SUBMIT_QUOTE_PVT.Query_Price_Adj_Rltship_Rows(
                                         lx_price_adj_tbl(l_price_adj_count).price_adjustment_id,
                                         P_Line_Index,
                                         lx_price_adj_rltship_tbl);

   END LOOP;
  END IF;
--End fix for bug 5575844.

   RETURN l_status;

END Query_Price_Adj_Rows;


FUNCTION Query_Price_Adj_Hdr_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type
IS
   CURSOR c_price_adj IS
    SELECT
     PRICE_ADJUSTMENT_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	REQUEST_ID,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	MODIFIER_HEADER_ID,
	MODIFIER_LINE_ID,
	MODIFIER_LINE_TYPE_CODE,
	MODIFIER_MECHANISM_TYPE_CODE,
	MODIFIED_FROM,
     MODIFIED_TO,
	OPERAND,
	ARITHMETIC_OPERATOR,
	AUTOMATIC_FLAG,
	UPDATE_ALLOWABLE_FLAG,
     UPDATED_FLAG,
	APPLIED_FLAG,
	ON_INVOICE_FLAG,
	PRICING_PHASE_ID,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
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
	TAX_CODE,
	TAX_EXEMPT_FLAG,
	TAX_EXEMPT_NUMBER,
	TAX_EXEMPT_REASON_CODE,
	PARENT_ADJUSTMENT_ID,
	INVOICED_FLAG,
	ESTIMATED_FLAG,
	INC_IN_SALES_PERFORMANCE,
	SPLIT_ACTION_CODE,
	ADJUSTED_AMOUNT,
	CHARGE_TYPE_CODE,
	CHARGE_SUBTYPE_CODE,
	RANGE_BREAK_QUANTITY,
	ACCRUAL_CONVERSION_RATE,
	PRICING_GROUP_SEQUENCE,
	ACCRUAL_FLAG,
	LIST_LINE_NO,
	SOURCE_SYSTEM_CODE,
	BENEFIT_QTY,
	BENEFIT_UOM_CODE,
	PRINT_ON_INVOICE_FLAG,
	EXPIRATION_DATE,
	REBATE_TRANSACTION_TYPE_CODE,
	REBATE_TRANSACTION_REFERENCE,
	REBATE_PAYMENT_SYSTEM_CODE,
	REDEEMED_DATE,
	REDEEMED_FLAG,
	MODIFIER_LEVEL_CODE,
	PRICE_BREAK_TYPE_CODE,
	SUBSTITUTION_ATTRIBUTE,
	PRORATION_TYPE_CODE,
	INCLUDE_ON_RETURNS_FLAG,
	CREDIT_OR_CHARGE_FLAG,
	ORIG_SYS_DISCOUNT_REF,
	CHANGE_REASON_CODE,
	CHANGE_REASON_TEXT,
	COST_ID,
	LIST_LINE_TYPE_CODE,
	UPDATE_ALLOWED,
	CHANGE_SEQUENCE,
	LIST_HEADER_ID,
	LIST_LINE_ID,
	QUOTE_SHIPMENT_ID
    FROM ASO_PRICE_ADJUSTMENTS
    WHERE quote_header_id = p_qte_header_id AND
          (quote_line_id = p_qte_line_id OR
          (quote_line_id IS NULL AND p_qte_line_id IS NULL)) AND
          (applied_flag IS NOT NULL AND applied_flag = 'Y');
    l_price_adj_rec             ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_tbl             ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
BEGIN
      FOR price_adj_rec IN c_price_adj LOOP
	  l_price_adj_rec.PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
	   l_price_adj_rec.CREATION_DATE := price_adj_rec.CREATION_DATE;
	   l_price_adj_rec.CREATED_BY := price_adj_rec.CREATED_BY;
	   l_price_adj_rec.LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
	   l_price_adj_rec.LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
	   l_price_adj_rec.LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
	   l_price_adj_rec.REQUEST_ID := price_adj_rec.REQUEST_ID;
	   l_price_adj_rec.PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
	   l_price_adj_rec.PROGRAM_ID := price_adj_rec.PROGRAM_ID;
	   l_price_adj_rec.PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
	  l_price_adj_rec.QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
	  l_price_adj_rec.QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
	  l_price_adj_rec.MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
	  l_price_adj_rec.MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
	  l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
	  l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
	  	  	  	  	:= price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
	  l_price_adj_rec.MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
	  l_price_adj_rec.MODIFIED_TO := price_adj_rec.MODIFIED_TO;
	  l_price_adj_rec.OPERAND := price_adj_rec.OPERAND;
	  l_price_adj_rec.ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
	  l_price_adj_rec.AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
	  l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
	  l_price_adj_rec.UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
	  l_price_adj_rec.APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
	  l_price_adj_rec.ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
	  l_price_adj_rec.PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
	  l_price_adj_rec.QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
	  l_price_adj_rec.ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
	  l_price_adj_rec.ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
	  l_price_adj_rec.ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
	  l_price_adj_rec.ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
	  l_price_adj_rec.ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
	  l_price_adj_rec.ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
	  l_price_adj_rec.ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
	  l_price_adj_rec.ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
	  l_price_adj_rec.ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
	  l_price_adj_rec.ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
	  l_price_adj_rec.ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
	  l_price_adj_rec.ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
	  l_price_adj_rec.ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
	  l_price_adj_rec.ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
	  l_price_adj_rec.ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
	  l_price_adj_rec.ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
          l_price_adj_rec.TAX_CODE   := price_adj_rec.TAX_CODE;
	l_price_adj_rec.TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
	l_price_adj_rec.TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
	l_price_adj_rec.TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
	l_price_adj_rec.PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
	l_price_adj_rec.INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
	l_price_adj_rec.ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
	l_price_adj_rec.INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
	l_price_adj_rec.SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
	l_price_adj_rec.ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
	l_price_adj_rec.CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
	l_price_adj_rec.CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
	l_price_adj_rec.RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
	l_price_adj_rec.ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
	l_price_adj_rec.PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
	l_price_adj_rec.ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
	l_price_adj_rec.LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
	l_price_adj_rec.SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
	l_price_adj_rec.BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
	l_price_adj_rec.BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
	l_price_adj_rec.PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
	l_price_adj_rec.EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
	l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
	l_price_adj_rec.REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
	l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
	l_price_adj_rec.REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
	l_price_adj_rec.REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
	l_price_adj_rec.MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
	l_price_adj_rec.PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
	l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
	l_price_adj_rec.PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
	l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
	l_price_adj_rec.CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
	l_price_adj_rec.ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
	l_price_adj_rec.CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
	l_price_adj_rec.CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
	l_price_adj_rec.COST_ID := price_adj_rec.COST_ID;
	--l_price_adj_rec.LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
	l_price_adj_rec.UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
	l_price_adj_rec.CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
	--l_price_adj_rec.LIST_HEADER_ID := price_adj_rec.LIST_HEADER_ID;
	--l_price_adj_rec.LIST_LINE_ID := price_adj_rec.LIST_LINE_ID;
	  l_price_adj_tbl(l_price_adj_tbl.COUNT+1) := l_price_adj_rec;
     END LOOP;
   RETURN l_price_adj_tbl;

END Query_Price_Adj_Hdr_Rows;



PROCEDURE Raise_Quote_Event(
                        P_Quote_Header_id       IN      NUMBER,
                        P_Control_Rec           IN      ASO_QUOTE_PUB.SUBMIT_Control_Rec_Type,
                        X_Return_Status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2 )
IS

l_Event wf_event_t;

BEGIN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Raise_Quote_Event: P_Quote_Header_id: '||P_Quote_Header_id, 1, 'N');
aso_debug_pub.add('Raise_Quote_Event: P_Control_Rec.Calculate_Price: '||P_Control_Rec.Calculate_Price, 1, 'N');
aso_debug_pub.add('Raise_Quote_Event: P_Control_Rec.Book_Flag: '||P_Control_Rec.Book_Flag, 1, 'N');
aso_debug_pub.add('Raise_Quote_Event: P_Control_Rec.Server_Id: '||P_Control_Rec.Server_Id, 1, 'N');
END IF;

X_Return_Status := FND_API.G_RET_STS_SUCCESS;

wf_event_t.initialize(l_Event);

l_Event.AddParameterToList(
                                pname   =>      'ECX_MAP_CODE',
                                pvalue  =>      'ASOQuoteOutBoundPVT' );

l_event.AddParameterToList(
                                pname   =>      'ECX_DOCUMENT_ID',
                                pvalue  =>      P_Quote_Header_Id );

l_event.AddParameterToList(
                                pname   =>      'ECX_PARAMETER1',
                                pvalue  =>      P_Control_Rec.Calculate_Price );

l_event.AddParameterToList(
                                pname   =>      'ECX_PARAMETER2',
                                pvalue  =>      P_Control_Rec.Book_Flag );

l_event.AddParameterToList(
                                pname   =>      'ECX_PARAMETER3',
                                pvalue  =>      P_Control_Rec.Server_Id );

l_event.AddParameterToList(
                                pname   =>      'ECX_PARAMETER4',
                                pvalue  =>      FND_GLOBAL.Resp_Id );

l_event.AddParameterToList(
                                pname   =>      'ECX_PARAMETER5',
                                pvalue  =>      FND_GLOBAL.Resp_Appl_Id );

wf_event.raise(
                    p_event_name    =>      'oracle.apps.wf.replay.aso.submitquote',
                    p_event_key     =>      to_char(P_Quote_Header_Id),
                    p_parameters    =>      l_event.getParameterList );

EXCEPTION
     WHEN OTHERS THEN
          x_return_Status :=FND_API.G_RET_STS_ERROR;

END Raise_Quote_Event;


PROCEDURE Quote_Order_High_Availability(
     P_Quote_Header_Id        IN   NUMBER,
     P_Book_Flag              IN   VARCHAR2,
     P_Calculate_Flag         IN   VARCHAR2,
     P_Server_Id              IN   NUMBER,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */      NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */      VARCHAR2
)
IS

     l_Control_Rec            ASO_QUOTE_PUB.SUBMIT_Control_Rec_Type
                                   :=  ASO_QUOTE_PUB.G_MISS_SUBMIT_CONTROL_REC;
     lx_Order_Header_Rec      ASO_QUOTE_PUB.Order_Header_Rec_Type;
     l_Qte_Header_Rec         ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec;

BEGIN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Quote_Order_High_Availability: P_Quote_Header_id: '||P_Quote_Header_id, 1, 'N');
aso_debug_pub.add('Quote_Order_High_Availability: P_Book_Flag: '||P_Book_Flag, 1, 'N');
aso_debug_pub.add('Quote_Order_High_Availability: P_Calculate_Flag: '||P_Calculate_Flag, 1, 'N');
aso_debug_pub.add('Quote_Order_High_Availability: P_Server_Id: '||P_Server_Id, 1, 'N');
END IF;

     l_Control_Rec.Book_Flag := P_Book_Flag;
     l_Control_Rec.Calculate_Price := P_Calculate_Flag;
     l_Control_Rec.Server_Id := P_Server_Id;
	l_Qte_Header_Rec.Quote_Header_Id := P_Quote_Header_Id;

     ASO_SUBMIT_QUOTE_PVT.Submit_Quote(
          P_Api_Version_Number     =>   1.0,
          P_Control_Rec            =>   l_Control_Rec,
          P_Qte_Header_Rec         =>   l_Qte_Header_Rec,
          X_Order_Header_Rec       =>   lx_Order_Header_Rec,
          X_Return_Status          =>   X_Return_Status,
          X_Msg_Count              =>   X_Msg_Count,
          X_Msg_Data               =>   X_Msg_Data );

END Quote_Order_High_Availability;


End ASO_SUBMIT_QUOTE_PVT;

/
