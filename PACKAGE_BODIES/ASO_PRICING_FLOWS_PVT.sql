--------------------------------------------------------
--  DDL for Package Body ASO_PRICING_FLOWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PRICING_FLOWS_PVT" as
/* $Header: asovpflb.pls 120.7.12010000.10 2015/06/02 06:37:35 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_FLOWS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASO_PRICING_FLOWS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovpflb.pls';
--G_ADJ_NUM   CONSTANT NUMBER := 999;

/******************************************************************************
 *                                                                            *
 *  Code Path when price mode is ENTIRE_QUOTE                                 *
 *                                                                            *
 ******************************************************************************/

PROCEDURE Price_Entire_Quote(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
	p_internal_call_flag       IN   VARCHAR2 := 'N',
	x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Price_Entire_Quote';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_req_control_rec             QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_prc_control_rec             ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
    l_qte_line_id                 NUMBER;
    l_qte_line_dtl_rec            ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_shipment_rec                ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_return_status               VARCHAR2(1);
    l_return_status_text          VARCHAR2(2000);
    l_message_text                VARCHAR2(2000);
    i                             BINARY_INTEGER;
    j                             BINARY_INTEGER;
    l_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_dtl_tbl            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_shipment_tbl                ASO_QUOTE_PUB.Shipment_Tbl_Type;
    x_pass_line                   VARCHAR2(10);
    l_qte_line_id_tbl             JTF_NUMBER_TABLE;
    l_qte_adj_id_tbl              JTF_NUMBER_TABLE;
    l_service_qte_line_id_tbl     JTF_NUMBER_TABLE;
    l_index_counter               Number; -- This is used to keep track of lx_index_counter
    lx_index_counter              Number;
    lx_order_status_rec           QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
    l_adj_id_tbl                  Index_Link_Tbl_Type;
    l_price_index                 Number;
    px_line_index_search_tbl      ASO_PRICING_CORE_PVT.Index_Link_Tbl_Type;
    l_global_pls_tbl              QP_PREQ_GRP.pls_integer_type;
    l_global_num_tbl              QP_PREQ_GRP.NUMBER_TYPE;
    l_pricing_start_time          NUMBER;
    l_pricing_end_time            NUMBER;
    l_accum_aso_time              NUMBER;
    l_accum_qp_time               NUMBER;


BEGIN

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  l_pricing_start_time := dbms_utility.get_time;
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Start of Price_Entire_Quote',1,'Y');
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.request_type:'||p_control_rec.request_type,1,'Y');
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.pricing_event:'||p_control_rec.pricing_event,1,'Y');
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_control_rec.calculate_flag:'||p_control_rec.calculate_flag,1,'Y');
END IF;

l_prc_control_rec := p_control_rec;
l_price_index := 1;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('********************* PROCESSING HEADER STARTS *******************************',1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_internal_call_flag: '||p_internal_call_flag,1,'Y');
   END IF;

   If p_internal_call_flag = 'N' then
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Set_Global_Rec  - Header Level...  ',1,'Y');
   END IF;
   ASO_PRICING_INT.G_HEADER_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
          p_qte_header_rec     => p_qte_header_rec,
          p_shipment_rec       => p_hd_shipment_rec);
   end If;--If p_internal_call_flag = 'N' then

   ASO_PRICING_CORE_PVT.Print_G_Header_Rec;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      l_pricing_end_time := dbms_utility.get_time;
      l_accum_aso_time := l_pricing_end_time - l_pricing_start_time;
   END IF;

   QP_Price_Request_Context.Set_Request_Id;

   QP_ATTR_MAPPING_PUB.Build_Contexts (
      P_REQUEST_TYPE_CODE          => p_control_rec.request_type,
      P_PRICING_TYPE_CODE          => 'H',
      P_line_index                 => l_price_index,
      P_pricing_event              => p_control_rec.pricing_event,
      p_check_line_flag            => 'N',
      x_pass_line                  => x_pass_line);


   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     l_pricing_start_time := dbms_utility.get_time;
     l_accum_qp_time := l_pricing_start_time - l_pricing_end_time;
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Header_To_Request...',1,'Y');
   END IF;


   ASO_PRICING_CORE_PVT.Copy_Header_To_Request(
       p_Request_Type                   => p_control_rec.request_type,
       p_price_line_index               => l_price_index,
       px_index_counter                 => 1);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Append_asked_for...',1,'Y');
   END IF;

   lx_index_counter:= 1;
   ASO_PRICING_CORE_PVT.Append_asked_for(
        p_pricing_event                   => p_control_rec.pricing_event,
        p_price_line_index                => l_price_index,
        p_header_id                       => p_qte_header_rec.quote_header_id,
        px_index_counter                  => lx_index_counter);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:After Append Ask for lx_index_counter:'
                        ||lx_index_counter,1,'Y');
   END IF;
    --increment the line index
   l_price_index:= l_price_index+1;

   -- Header ends here

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('************************ HEADER LEVEL ENDS *******************************',1,'Y');
     aso_debug_pub.add('  ',1,'Y');
     aso_debug_pub.add('************************ LINE LEVEL BEGINS *******************************',1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of ASO UTL PVT Query_Pricing_Line_Rows...',1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Before call Get_Order_Lines_Status:p_control_rec.pricing_event:'
                        ||p_control_rec.pricing_event,1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Before call Get_Order_Lines_Status:p_control_rec.request_type:'
                        ||p_control_rec.request_type,1,'Y');
	l_pricing_end_time := dbms_utility.get_time;
	l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
   END IF;

   QP_UTIL_PUB.Get_Order_Lines_Status(p_event_code         => p_control_rec.pricing_event,
                                      x_order_status_rec   => lx_order_status_rec,
							   p_freight_call_flag  => 'Y',
							   p_request_type_code  => p_control_rec.request_type);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      l_pricing_start_time := dbms_utility.get_time;
	 l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);

      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:lx_order_status_rec.all_lines_flag:'
                         ||lx_order_status_rec.all_lines_flag,1,'Y');
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:lx_order_status_rec.changed_lines_flag:'
                         ||lx_order_status_rec.changed_lines_flag,1,'Y');
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:lx_order_status_rec.summary_line_flag:'
                         ||lx_order_status_rec.summary_line_flag,1,'Y');
   END IF;

   If lx_order_status_rec.all_lines_flag = 'N' then
     l_prc_control_rec.PRG_REPRICE_MODE := 'F';
   else
     l_prc_control_rec.PRG_REPRICE_MODE := 'A';
   end if;

   l_qte_line_tbl := ASO_UTILITY_PVT.Query_Pricing_Line_Rows(p_qte_header_rec.quote_header_id);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl.count :'||NVL(l_qte_line_tbl.count,0),1,'Y');
     l_pricing_end_time := dbms_utility.get_time;
     l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
   END IF;

   --  Added this code to delete all the adjustments when there are no items in the cart
   If l_qte_line_tbl.count = 0 Then
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:No lines in the database',1,'Y');
      END IF;

   Else
      -- Line Count <> 0.

      For i in 1..l_qte_line_tbl.count Loop

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_start_time := dbms_utility.get_time;
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Line_Dtl_Rows...',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).quote_line_id:'
					      ||NVL(l_qte_line_tbl(i).quote_line_id,0),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).pricing_line_type_indicator:'
					      ||l_qte_line_tbl(i).pricing_line_type_indicator,1,'Y');
          END IF;

  		l_qte_line_id := l_qte_line_tbl(i).quote_line_id;
		l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_id);

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Defaulting Hdr Lvl Price List and Currency..',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.currency_code :'
					      ||NVL(p_qte_header_rec.currency_code,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.price_list_id :'
					      ||NVL(to_char(p_qte_header_rec.price_list_id),'NULL'),1,'Y');
          END IF;
  		-- Pass header_level currency_code to line level by default.
  		l_qte_line_tbl(i).currency_code := p_qte_header_rec.currency_code;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).price_list_id :'
					      ||NVL(to_char(l_qte_line_tbl(i).price_list_id),'NULL'),1,'Y');
          END IF;
	     -- Pass Header level price list by default.
		IF l_qte_line_tbl(i).pricing_line_type_indicator = 'F' then
		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Free line so not defaulting of the price list',1,'Y');
			  END IF;
          ELSE
		   /*Default the price list*/
  		   If (l_qte_line_tbl(i).price_list_id is null
		      OR l_qte_line_tbl(i).price_list_id= FND_API.G_MISS_NUM) Then
        	   	    l_qte_line_tbl(i).price_list_id := p_qte_header_rec.price_list_id;
                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Price list id defaulted from Header:'
				   	         ||NVL(to_char(l_qte_line_tbl(i).price_list_id),'NULL'),1,'Y');
                   END IF;
  		   End if;
          END IF;--l_qte_line_tbl(i).pricing_line_type_indicator = 'F'

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_dtl_tbl.count :'
					      ||NVL(l_qte_line_dtl_tbl.count,0),1,'Y');
          END IF;
  		IF l_qte_line_dtl_tbl.count = 1 THEN
        		l_qte_line_dtl_rec := l_qte_line_dtl_tbl(1);
                ELSE
  			l_qte_line_dtl_rec := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_REC ;
  		END IF;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Shipment_Rows..',1,'Y');
          END IF;
  		l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows
				                        (p_qte_header_rec.quote_header_id, l_QTE_LINE_ID);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_shipment_tbl.count :'
					      ||NVL(l_shipment_tbl.count,0),1,'Y');
          END IF;
  		IF l_shipment_tbl.count = 1 THEN
        		l_shipment_rec := l_shipment_tbl(1);
		else
  		     l_shipment_rec := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
  		END IF;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Set_Global_Rec - Line Level...', 1, 'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:These values will be defaulted from header for pricing qualification only:',1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_line_tbl(i).invoice_to_party_site_id:'
						 ||NVL(to_char(l_qte_line_tbl(i).invoice_to_party_site_id),'NULL'),1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.ship_to_party_site_id:'
						 ||NVL(to_char(l_shipment_rec.ship_to_party_site_id),'NULL'),1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_line_tbl(i).agreement_id:'
						 ||NVL(to_char(l_qte_line_tbl(i).agreement_id),'NULL'),1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.ship_method_code:'
						 ||NVL(l_shipment_rec.ship_method_code,'NULL'),1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.freight_terms_code:'
						 ||NVL(l_shipment_rec.freight_terms_code,'NULL'),1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.FREIGHT_CARRIER_CODE:'
						 ||NVL(l_shipment_rec.FREIGHT_CARRIER_CODE,'NULL'),1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.FOB_CODE:'
						 ||NVL(l_shipment_rec.FOB_CODE,'NULL'),1,'Y');
		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.REQUEST_DATE:'
						 ||NVL(to_char(l_shipment_rec.REQUEST_DATE),'NULL'),1,'Y');
          END IF;

          ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
                	p_qte_line_rec               => l_qte_line_tbl(i),
                	p_qte_line_dtl_rec           => l_qte_line_dtl_rec,
                	p_shipment_rec               => l_shipment_rec);

          ASO_PRICING_CORE_PVT.Print_G_Line_Rec;

    		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP Build_Contexts - Line Level...',1,'Y');
            l_pricing_end_time := dbms_utility.get_time;
		  l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
    		END IF;
          QP_ATTR_MAPPING_PUB.Build_Contexts (
                    p_request_type_code          => p_control_rec.request_type,
                    p_line_index                 => l_price_index,
                    p_check_line_flag            => 'N',
                    p_pricing_event              => p_control_rec.pricing_event,
                    p_pricing_type_code          => 'L',
                    p_price_list_validated_flag  => 'N',
                    x_pass_line                  => x_pass_line);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_start_time := dbms_utility.get_time;
		  l_accum_qp_time := l_accum_qp_time +(l_pricing_start_time - l_pricing_end_time);
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
    		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Line_To_Request...',1,'Y');
          END IF;

    		ASO_PRICING_CORE_PVT.Copy_Line_To_Request(
    			p_Request_Type         => p_control_rec.request_type,
               p_price_line_index    => l_price_index,
    			px_index_counter       => i+1);


    		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    		  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Append_asked_for...',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Before Append Ask for lx_index_counter:'
                               ||lx_index_counter,1,'Y');
    		END IF;
		l_index_counter := lx_index_counter;
          ASO_PRICING_CORE_PVT.Append_asked_for(
        		                p_pricing_event   => p_control_rec.pricing_event,
                               p_price_line_index => l_price_index,
       			           p_header_id       => p_qte_header_rec.quote_header_id,
       			           p_line_id         => l_qte_line_tbl(i).quote_line_id,
    			                px_index_counter  => lx_index_counter);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:After Append Ask for lx_index_counter:'
                               ||lx_index_counter,1,'Y');
          END IF;
		If lx_index_counter = 0 then
		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Assigning the value of l_index_counter back to lx_index_counter:'||l_index_counter,1,'Y');
		   END IF;
		   lx_index_counter := l_index_counter;
		end if;

          /*Store the line_id of all the service_lines*/
          If l_qte_line_tbl(i).service_item_flag = 'Y' then
             if l_service_qte_line_id_tbl.EXISTS(1) then
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    		         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of l_service_qte_line_id_tbl.extend...',1,'Y');
                 END IF;
                 l_service_qte_line_id_tbl.extend;
                 l_service_qte_line_id_tbl(l_service_qte_line_id_tbl.count)
								            := l_qte_line_tbl(i).quote_line_id;
              else
                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    		          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: First quote_line_id in l_service_qte_line_id_tbl',1,'Y');
                 END IF;
                 l_service_qte_line_id_tbl:= JTF_NUMBER_TABLE(l_qte_line_tbl(i).quote_line_id);
             end if;
          end if;-- l_qte_line_tbl(i).service_item_flag = 'Y'

          /*Store all the quote_line_id processed*/
   		IF l_Qte_Line_id_tbl.EXISTS(1) THEN
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    		      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of l_qte_line_id_tbl.extend...',1,'Y');
             END IF;
     	   l_Qte_Line_id_tbl.extend;
     	   l_Qte_Line_id_tbl(l_Qte_Line_id_tbl.count) := l_qte_line_tbl(i).quote_line_id;
   		 ELSE
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    		      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: First quote_line_id in l_qte_line_id_tbl',1,'Y');
             END IF;
     	   l_Qte_Line_id_tbl := JTF_NUMBER_TABLE(l_qte_line_tbl(i).quote_line_id);
   	    END IF;
         --increment the line index
           px_line_index_search_tbl(l_qte_line_id) := l_price_index;
           l_price_index:= l_price_index+1;
		 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             l_pricing_end_time := dbms_utility.get_time;
		   l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
		 END IF;
      End Loop; -- l_Qte_Line_tbl.count checking.

  	 -- Call to Price Adjustment Relationships and Service Relationships
    	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      l_pricing_start_time := dbms_utility.get_time;
    	   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Price_Adjustments...',1,'Y');
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_id_tbl.count :'
					  ||NVL(l_qte_line_id_tbl.count,0),1,'Y');
    	 END IF;
	 ASO_PRICING_CORE_PVT.Query_Price_Adjustments
		(p_quote_header_id	     => p_qte_header_rec.quote_header_id,
 		 p_qte_line_id_tbl       => l_qte_line_id_tbl,
		 x_adj_id_tbl            => l_qte_adj_id_tbl);

      If l_qte_adj_id_tbl.exists(1) OR l_service_qte_line_id_tbl.exists(1) Then
         -- Adjustment and line Relationships and services...
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Adj_rltship_Bulk...',1,'Y');
		  If l_qte_adj_id_tbl is not null then
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_adj_id_tbl.count :'
					         ||NVL(l_qte_adj_id_tbl.count,0),1,'Y');
            end if;
		  If l_service_qte_line_id_tbl is not null then
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_qte_line_id_tbl.count :'
					         ||NVL(l_service_qte_line_id_tbl.count,0),1,'Y');
            end if;
         END IF;
         ASO_PRICING_CORE_PVT.Query_relationships
		(p_qte_adj_id_tbl           => l_qte_adj_id_tbl,
           p_service_qte_line_id_tbl  => l_service_qte_line_id_tbl);
      else
	  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: There are no service lines or manual related Adjustments',1,'Y');
       END IF;
      end if;--If l_qte_adj_id_tbl.exists(1) OR l_service_qte_line_id_tbl.exists(1)

  END IF; -- l_qte_line_tbl.count = 0 check.


  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin bulk collect adj ids', 1, 'Y');
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	--If nvl(l_qte_adj_id_tbl.count,0) > 0 then
	  If l_qte_adj_id_tbl is not null then
	   For i in 1..l_qte_adj_id_tbl.count loop
	   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Querying for the following adjustment  ids:',1,'Y');
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_adj_id_tbl(i):'||l_qte_adj_id_tbl(i),1,'Y');
	   end loop;
	  end if;
  END IF;

  SELECT adj.PRICE_ADJUSTMENT_ID
  BULK COLLECT INTO
  l_adj_id_tbl
  FROM ASO_PRICE_ADJUSTMENTS adj
  WHERE adj.quote_header_id = p_qte_header_rec.quote_header_id
  AND adj.price_adjustment_id NOT IN (SELECT column_value
  							   FROM TABLE (CAST(l_qte_adj_id_tbl AS JTF_NUMBER_TABLE)) passed_adj);

  if aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: No. of adjustment lines selected is sql%rowcount: '||sql%rowcount,1,'Y');
  end if;

  if aso_debug_pub.g_debug_flag = 'Y' THEN

     if l_adj_id_tbl.count > 0 then

        for k in l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST loop
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_adj_id_tbl('||k||'): ' || l_adj_id_tbl(k),1,'Y');
        end loop;

     end if;

  end if;

  if l_adj_id_tbl.count > 0 then
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJ_ATTRIBS', 1, 'Y');
     END IF;
     FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
            DELETE FROM ASO_PRICE_ADJ_ATTRIBS
            WHERE PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i);

     if aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:No of adjustment attribute lines deleted is sql%rowcount: '||sql%rowcount,1,'Y');
     end if;

 end if;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS', 1, 'Y');
  END IF;
  DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
  WHERE QUOTE_LINE_ID in (SELECT quote_line_id
                          FROM ASO_PRICE_ADJUSTMENTS
                          WHERE quote_header_id = p_qte_header_rec.quote_header_id
                          AND quote_line_id IS NOT NULL);

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Rltd adj Lines deleted '||sql%ROWCOUNT,1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJUSTMENTS', 1, 'Y');
  END IF;

  DELETE FROM ASO_PRICE_ADJUSTMENTS
  WHERE quote_header_id = p_qte_header_rec.quote_header_id;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Adjustment Lines deleted '||sql%ROWCOUNT,1,'Y');
  END IF;


  If (l_qte_line_tbl.count <> 0 ) OR (p_control_rec.pricing_event = 'ORDER') then
--Condition was placed because engine call was not necessary if the event is price and there are no lines

   --Need to modify the global index table of pls integer types
  l_global_pls_tbl := ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL;
  ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_PlsIndex_Table(
                                                    p_global_tbl => l_global_pls_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
  l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL;
  ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
  l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL;
  ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Populate_QP_Temp_tables...',1,'Y');
    l_pricing_end_time := dbms_utility.get_time;
    l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
  END IF;

  ASO_PRICING_CORE_PVT.populate_qp_temp_tables;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     l_pricing_start_time := dbms_utility.get_time;
     l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
  END IF;


  -- Set the control rec for QP

  l_req_control_rec.pricing_event := p_control_rec.pricing_event;
  l_req_control_rec.calculate_flag := p_control_rec.calculate_flag;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_req_control_rec.calculate_flag:'||l_req_control_rec.calculate_flag,1,'Y');
  END IF;
  l_req_control_rec.simulation_flag := p_control_rec.simulation_flag;
  l_req_control_rec.TEMP_TABLE_INSERT_FLAG := 'N';  ---- Modified
  l_req_control_rec.source_order_amount_flag := 'Y';
  l_req_control_rec.GSA_CHECK_FLAG := 'Y';
  l_req_control_rec.GSA_DUP_CHECK_FLAG := 'Y';
  l_req_control_rec.REQUEST_TYPE_CODE := p_control_rec.request_type;
  l_req_control_rec.rounding_flag := 'Q';

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
    l_pricing_end_time := dbms_utility.get_time;
    l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
  END IF;

/*   Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar (MOAC)  */

	l_req_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

/*				End of Change                                (MOAC)  */



  QP_PREQ_PUB.PRICE_REQUEST
          	(p_control_rec           =>l_req_control_rec
          	,x_return_status         =>l_return_status
          	,x_return_status_Text    =>l_return_status_Text
          	);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_return_status := l_return_status;
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
	FND_MESSAGE.Set_Token('MSG_TXT', substr(l_return_status_text, 1,255), FALSE);
     FND_MSG_PUB.ADD;
  END IF;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    l_pricing_start_time := dbms_utility.get_time;
    l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: End of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status:'
                       ||l_return_status, 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status_text '
                       ||l_return_status_text,1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Post_Price_Request...',1,'Y');
  END IF;


  ASO_PRICING_CORE_PVT.Copy_Price_To_Quote(
     		P_Api_Version_Number       => 1.0,
     		P_Init_Msg_List            => FND_API.G_FALSE,
     		P_Commit                   => FND_API.G_FALSE,
     		p_control_rec		       => l_prc_control_rec,
     		p_qte_header_rec           => p_qte_header_rec,
     		x_return_status            => x_return_status,
     		x_msg_count                => x_msg_count,
     		x_msg_data                 => x_msg_data);
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Copy_Price_To_Quote : x_return_status: '
		    ||nvl(x_return_status,'NULL'),1,'Y');
 END IF;

 If p_internal_call_flag = 'N' then
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       ASO_PRICING_CORE_PVT.Process_PRG(
     		P_Api_Version_Number       => 1.0,
     		P_Init_Msg_List            => FND_API.G_FALSE,
     		P_Commit                   => FND_API.G_FALSE,
     		p_control_rec		       => l_prc_control_rec,
     		p_qte_header_rec           => p_qte_header_rec,
			x_qte_line_tbl             => x_qte_line_tbl,
     		x_return_status            => x_return_status,
     		x_msg_count                => x_msg_count,
     		x_msg_data                 => x_msg_data);

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Process_PRG : x_return_status: '
                             ||nvl(x_return_status,'NULL'),1,'Y');
       END IF;

    END IF;--x_return_status = FND_API.G_RET_STS_SUCCESS

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After Process_PRG : x_qte_line_tbl.count: '
                             ||x_qte_line_tbl.count,1,'Y');
       END IF;

       ASO_PRICING_CORE_PVT.Process_Charges(
               P_Api_Version_Number       => 1.0,
               P_Init_Msg_List            => FND_API.G_FALSE,
               P_Commit                   => FND_API.G_FALSE,
               p_control_rec              => l_prc_control_rec,
               p_qte_header_rec           => p_qte_header_rec,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data);
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Process_Charges : x_return_status: '
                            ||nvl(x_return_status,'NULL'),1,'Y');
      END IF;

    END IF;--x_return_status = FND_API.G_RET_STS_SUCCESS

 End If;--p_internal_call_flag = 'N'
 End if;--(l_qte_line_tbl.count <> 0 ) OR (p_control_rec.pricing_event = 'ORDER')


FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

FOR l IN 1 .. x_msg_count LOOP
    x_msg_data := FND_MSG_PUB.GET( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
END LOOP;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   l_pricing_end_time := dbms_utility.get_time;
   l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:**********Timing in Price Entire Quote**************',1,'Y');
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Total time taken (in secs) in Price Entire Quote(Besides Pricing):'||l_accum_aso_time/100,1,'Y');
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Total time taken (in secs) in Pricing+BuildContext:'||l_accum_qp_time/100,1,'Y');
END IF;

END Price_Entire_Quote;


/******************************************************************************
 *                                                                            *
 *  Code Path when price mode is QUOTE_LINE                                   *
 *                                                                            *
 ******************************************************************************/


PROCEDURE Price_Quote_Line(

     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Price_Quote_Line';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    --l_request_type                VARCHAR2(60);
    l_req_control_rec             QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_qte_line_id                 NUMBER;
    l_child_qte_line_id           NUMBER;
    l_found                       NUMBER;
    l_qte_line_dtl_rec            ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_shipment_rec                ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_return_status               VARCHAR2(1);
    l_return_status_text          VARCHAR2(2000);
    l_message_text                VARCHAR2(2000);
    i                             BINARY_INTEGER;
    j                             BINARY_INTEGER;
    l_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_dtl_tbl            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_shipment_tbl                ASO_QUOTE_PUB.Shipment_Tbl_Type;
    x_pass_line                   VARCHAR2(10);
    l_qte_line_id_tbl             JTF_NUMBER_TABLE;
    l_qte_adj_id_tbl              JTF_NUMBER_TABLE;
    l_service_qte_line_id_tbl     JTF_NUMBER_TABLE;
    l_qte_line_rec            	  ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_ref_type_code               ASO_QUOTE_LINE_DETAILS.SERVICE_REF_TYPE_CODE%TYPE;
    l_service_ref_line_id         ASO_QUOTE_LINE_DETAILS.SERVICE_REF_LINE_ID%TYPE;
    l_service_proc_done_flag      VARCHAR2(1);
    l_service_product_id_tbl      Index_Link_Tbl_Type;
    l_service_ref_line_id_tbl     Index_Link_Tbl_Type;
    l_service_id_tbl              Index_Link_Tbl_Type;
    lx_index_counter              Number;
    l_index_counter               Number; -- This is used to keep track of lx_index_counter
    l_price_index                 Number;
    px_line_index_search_tbl      ASO_PRICING_CORE_PVT.Index_Link_Tbl_Type;
    l_global_pls_tbl              QP_PREQ_GRP.pls_integer_type;
    l_global_num_tbl              QP_PREQ_GRP.NUMBER_TYPE;

    -- The following three cursors are needed for service lines processing.
    CURSOR c_Qte_Line_SVC_ref(p_qte_line_id IN NUMBER) IS
	 SELECT service_ref_type_code , service_ref_line_id
	 FROM   ASO_QUOTE_LINE_DETAILS
	 WHERE  quote_line_id = p_qte_line_id;

    CURSOR c_order_line (p_order_line_id IN NUMBER) IS
	 SELECT line_id, inventory_item_id, pricing_quantity, pricing_quantity_uom,
	        unit_list_price, price_list_id, UNIT_LIST_PRICE_PER_PQTY -- bug 17517305
	 FROM OE_ORDER_LINES_ALL
	 WHERE line_id = p_order_line_id;

    -- Cursors used for the customer account (Sold_to_org_id)
    /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
    CURSOR c_get_cust_acct_id IS
         select decode(nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N'),'Y',nvl(END_CUSTOMER_CUST_ACCOUNT_ID,cust_account_id),cust_account_id) cust_account_id
         from ASO_QUOTE_HEADERS_ALL
         WHERE quote_header_id = p_qte_header_rec.quote_header_id;

     CURSOR c_get_cust_acct_id_ln(p_qte_line_id number) IS
	select decode(nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N'),'Y',END_CUSTOMER_CUST_ACCOUNT_ID) cust_account_id
         from ASO_QUOTE_LINES_ALL
         WHERE quote_line_id = p_qte_line_id;

     cursor c_get_price_list(p_qte_hdr_id number) is
     select  price_list_id
     from    aso_quote_headers_all
     where   quote_header_id = p_qte_hdr_id;

     l_cust_account_id number;
     /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/


    CURSOR c_csi_line(p_instance_id IN NUMBER, p_cust_account_id NUMBER) IS
	 SELECT   original_order_line_id
	 FROM     csi_instance_accts_rg_v
	 WHERE    customer_product_id = p_instance_id
	 AND      account_id          = p_cust_account_id;


/******  Start SUN Changes ER: 3802859 **********/

     l_order_found BOOLEAN := FALSE;

-- changed cursor for bug 12839557
     CURSOR c_csi_line_details(p_instance_id IN NUMBER, p_cust_account_id NUMBER) IS
         SELECT si.concatenated_segments product, si.inventory_item_id, cii.quantity, cii.unit_of_measure
	FROM mtl_system_items_kfv si, csi_item_instances cii
	WHERE NVL(cii.active_end_date, (SYSDATE + 1)) > SYSDATE
	AND cii.inventory_item_id = si.inventory_item_id
	AND si.organization_id = cii.inv_master_organization_id
	AND cii.instance_id =p_instance_id;

	/* SELECT   distinct a.product,b.inventory_item_id,a.quantity,a.unit_of_measure_code
      FROM     csi_instance_accts_rg_v a ,mtl_system_items_vl  b
      where    a.product = b.concatenated_segments
	 AND      a.customer_product_id = p_instance_id;
	 --AND      a.account_id          = p_cust_account_id;
*/

     l_prod     varchar2(1000);
     l_item_id  number;
     l_qty      number;
     l_uom      varchar2(30);

/******* End SUN  Changes ER: 3802859 ***********/

-- Coded for sun GSI
l_service_item_flg varchar2(1):='N';
l_service_item_flg1 varchar2(1):='N';
l_servicable_item_flg varchar2(1):='N';
l_servicable_item_flg1 varchar2(1):='N';


BEGIN


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Start of Price_Quote_Line',1,'Y');
END IF;
-- Standard Start of API savepoint
SAVEPOINT PRICE_QUOTE_LINE_PVT;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('p_control_rec.request_type:'||p_control_rec.request_type,1,'Y');
  aso_debug_pub.add('p_control_rec.pricing_event:'||p_control_rec.pricing_event,1,'Y');
END IF;


l_price_index := 1;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Set_Global_Rec  - Header Level...  ',1,'Y');
END IF;
ASO_PRICING_INT.G_HEADER_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
  p_qte_header_rec     => p_qte_header_rec,
  p_shipment_rec       => p_hd_shipment_rec);

ASO_PRICING_CORE_PVT.Print_G_Header_Rec;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP Build Contexts  - Header Level ...  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.quote_header_id: '
                     ||NVL(to_char(p_qte_header_rec.quote_header_id),'NULL'),1,'Y');
END IF;

QP_Price_Request_Context.Set_Request_Id;

QP_ATTR_MAPPING_PUB.Build_Contexts (
  P_REQUEST_TYPE_CODE          => p_control_rec.request_type,
  P_PRICING_TYPE_CODE          => 'H',
  P_line_index                 => l_price_index,
  P_pricing_event              => p_control_rec.pricing_event,
  p_check_line_flag            => 'N',
  x_pass_line                  => x_pass_line);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Header_To_Request...',1,'Y');
END IF;


ASO_PRICING_CORE_PVT.Copy_Header_To_Request(
  p_Request_Type                => p_control_rec.request_type,
  p_price_line_index            => l_price_index,
  px_index_counter              => 1);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Append_asked_for...',1,'Y');
END IF;

lx_index_counter := 1;
ASO_PRICING_CORE_PVT.Append_asked_for(
  p_pricing_event                => p_control_rec.pricing_event,
  p_price_line_index             => l_price_index,
  p_header_id                    => p_qte_header_rec.quote_header_id,
  px_index_counter               => lx_index_counter);
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After Header Append_asked_for: lx_index_counter:'
                     ||lx_index_counter,1,'Y');
END IF;

IF ( p_control_rec.pricing_event = 'BATCH' ) THEN
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Price_Adj_Header...',1,'Y');
   END IF;
   ASO_PRICING_CORE_PVT.Query_Price_Adj_Header(
   p_quote_header_id        => p_qte_header_rec.quote_header_id) ;
END IF;
--increment the line index
l_price_index:= l_price_index+1;

-- Header ends here

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('************************ HEADER LEVEL ENDS *******************************',1,'Y');
  aso_debug_pub.add('Code Path PRICE_MODE = QUOTE_LINE where  Line Count <> 0 ',1,'Y');
  aso_debug_pub.add('************************ LINE LEVEL BEGINS *******************************',1,'Y');
END IF;

--  Added this code to delete all the adjustments when there are no items in the cart
IF NVL(p_qte_line_tbl.count,0) = 0 THEN
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Deleting from ASO_PRICE_ADJUSTMENTS if p_qte_line_tbl.count = 0',1,'Y');
   END IF;

   IF p_control_rec.pricing_event = 'BATCH' THEN
      DELETE FROM aso_price_adjustments
      WHERE quote_header_id = p_qte_header_rec.quote_header_id
      AND   quote_line_id IS NULL;
    End if;--p_control_rec.pricing_event = 'BATCH'

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Adjustment Lines deleted if p_qte_line_tbl.count = 0 '||sql%ROWCOUNT,1,'Y');
    END IF;
END IF; -- p_qte_line_tbl.count = 0


IF p_qte_line_tbl.count IS NOT NULL AND
   p_qte_line_tbl.count > 0
THEN
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_line_tbl.count                      :'||NVL(p_qte_line_tbl.count,0),1,'Y');
     END IF;


     -- Filtering OUT NOCOPY /* file.sql.39 change */ deleted and updated lines from p_qte_line_tbl.

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Filtering Quote lines that are deleted...',1,'Y');
     END IF;
     l_service_proc_done_flag := 'N';
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Initialize... l_service_proc_done_flag     :'||NVL(l_service_proc_done_flag,'null'),1,'Y');
     END IF;
     For i in 1..p_qte_line_tbl.count Loop
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_line_tbl('||i||').quote_line_id           :'||NVL(to_char(p_qte_line_tbl(i).quote_line_id),'NULL'),1,'Y');
	   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_line_tbl('||i||').operation_code          :'||NVL(p_qte_line_tbl(i).operation_code,'null'),1,'Y');
	   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_line_tbl('||i||').service_item_flag       :'||NVL(p_qte_line_tbl(i).service_item_flag,'null'),1,'Y');
	  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_line_tbl('||i||').serviceable_product_flag:'||NVL(p_qte_line_tbl(i).serviceable_product_flag,'null'),1,'Y');
	END IF;
	IF p_qte_line_tbl(i).operation_code = 'DELETE' THEN
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_line_tbl('||i||').quote_line_id - deleted :'||NVL(to_char(p_qte_line_tbl(i).quote_line_id),'NULL'),1,'Y');
              END IF;
	   -- This Quote Line is not added to the l_quote_line_tbl.
	ELSE
	   -- Operation is either CREATE or UPDATE.

	   if  p_qte_line_tbl(i).operation_code='UPDATE' then

	     select nvl(service_item_flag,'N'), nvl(serviceable_product_flag,'N')
	     into  l_service_item_flg, l_servicable_item_flg
	     from aso_quote_lines_all
	     where quote_line_id=p_qte_line_tbl(i).quote_line_id;
         else
           l_service_item_flg:= NVL(p_qte_line_tbl(i).service_item_flag,'N') ;
           l_servicable_item_flg:=nvl(p_qte_line_tbl(i).serviceable_product_flag,'N');

          end if;
	   -- Service Processing Logic Begins Here...

      aso_debug_pub.add('rassharm ASO_PRICING_FLOWS_PVT: quote_line_id:'||p_qte_line_tbl(i).quote_line_id,1,'Y');
      aso_debug_pub.add('rassharm ASO_PRICING_FLOWS_PVT: l_service_item_flg:'||l_service_item_flg,1,'Y');
      aso_debug_pub.add('rassharm ASO_PRICING_FLOWS_PVT: l_servicable_item_flg:'||l_servicable_item_flg,1,'Y');

	--	IF NVL(p_qte_line_tbl(i).serviceable_product_flag,'N') = 'Y'  AND
	if  l_servicable_item_flg='Y' and
                   NVL(l_service_proc_done_flag,'N') = 'N'
		THEN
		    l_service_product_id_tbl(p_qte_line_tbl(i).quote_line_id) := p_qte_line_tbl(i).quote_line_id;
                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_product_id_tbl('||p_qte_line_tbl(i).quote_line_id||').           :'||NVL(to_char(l_service_product_id_tbl(p_qte_line_tbl(i).quote_line_id)),'null'),1,'Y');
		    END IF;
		END IF;

	--	IF NVL(p_qte_line_tbl(i).service_item_flag,'N') = 'Y'  THEN
	       If l_service_item_flg='Y' then
		    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Service lines processing........ ',1,'Y');
		    END IF;
		    IF NVL(l_service_proc_done_flag,'N') = 'N' THEN
			   FOR j IN i..p_qte_line_tbl.COUNT LOOP

				  if  p_qte_line_tbl(j).operation_code='UPDATE' then

					select nvl(service_item_flag,'N'), nvl(serviceable_product_flag,'N')
					into  l_service_item_flg1, l_servicable_item_flg1
					from aso_quote_lines_all
					where quote_line_id=p_qte_line_tbl(j).quote_line_id;
				else
					l_service_item_flg1:= NVL(p_qte_line_tbl(j).service_item_flag,'N');
					l_servicable_item_flg1:=nvl(p_qte_line_tbl(j).serviceable_product_flag,'N');

				end if;
                                aso_debug_pub.add('rassharm ASO_PRICING_FLOWS_PVT: quote_line_id:'||p_qte_line_tbl(j).quote_line_id,1,'Y');
				aso_debug_pub.add('rassharm ASO_PRICING_FLOWS_PVT: l_service_item_flg1:'||l_service_item_flg1,1,'Y');
				aso_debug_pub.add('rassharm ASO_PRICING_FLOWS_PVT: l_servicable_item_flg1:'||l_servicable_item_flg1,1,'Y');

				IF l_servicable_item_flg1 = 'Y' THEN
				   l_service_product_id_tbl(p_qte_line_tbl(j).quote_line_id) := p_qte_line_tbl(j).quote_line_id;
				   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_product_id_tbl('||p_qte_line_tbl(j).quote_line_id||').            :'||NVL(to_char(l_service_product_id_tbl(p_qte_line_tbl(j).quote_line_id)),'null'),1,'Y');
				   END IF;
				END IF;
				IF l_service_item_flg1 = 'Y' THEN
				   l_service_id_tbl(p_qte_line_tbl(j).quote_line_id) := p_qte_line_tbl(j).quote_line_id;
				   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_id_tbl('||p_qte_line_tbl(j).quote_line_id||').                  :'||NVL(to_char(l_service_id_tbl(p_qte_line_tbl(j).quote_line_id)),'null'),1,'Y');
				   END IF;
				END IF;
			   END LOOP;
			   l_service_proc_done_flag := 'Y';
		    END IF;
		    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_proc_done_flag: '||NVL(l_service_proc_done_flag,'null'),1,'Y');
			IF (l_service_id_tbl.exists(1)) THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_id_tbl.count: '||NVL(l_service_id_tbl.count,0),1,'Y');
			END IF;
			IF (l_service_product_id_tbl.exists(1)) THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_product_id_tbl.count: '||NVL(l_service_product_id_tbl.count,0),1,'Y');
			END IF;
		    END IF;

		    OPEN c_qte_line_SVC_ref(p_qte_line_tbl(i).quote_line_id);
		    FETCH c_qte_line_SVC_ref INTO l_ref_type_code, l_service_ref_line_id;
		    CLOSE c_qte_line_SVC_ref;

		    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_ref_type_code: '||NVL(l_ref_type_code,'null'),1,'Y');
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_ref_line_id: '||NVL(to_char(l_service_ref_line_id),'NULL'),1,'Y');
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Service Line collection  to pass for Query Relationships procedure... ',1,'Y');
		    END IF;

		    -- l_service_qte_line_id_tbl is used to collect all quote line id(s) of service lines only.
		    -- l_service_qte_line_id_tbl is one of the parameter for ASO_PRICING_CORE_PVT.Query_Relationships procedure.
		    IF l_service_qte_line_id_tbl.exists(1) THEN
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Service Qte Line ID Tbl already exists... ',1,'Y');
			END IF;
			l_service_qte_line_id_tbl.extend;
			l_service_qte_line_id_tbl(l_service_qte_line_id_tbl.COUNT) := p_qte_line_tbl(i).quote_line_id;
		    ELSE
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Service Qte Line ID Tbl NOT exists... ',1,'Y');
			END IF;
			l_service_qte_line_id_tbl := JTF_NUMBER_TABLE(p_qte_line_tbl(i).quote_line_id);
		    END IF;

		    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Service Line collection ... ',1,'Y');
		    END IF;


 		    -- l_service_ref_line_id_tbl is used for parent line id collection and its different
		    -- from l_service_qte_line_id_tbl.

		    IF l_ref_type_code = 'ORDER' THEN
			IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
				IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Order Line exists in p_qte_line_tbl. ',1,'Y');
				END IF;
			ELSE
				FOR c_order_line_rec IN c_order_line(l_service_ref_line_id) LOOP
				    l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
    				    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Order Line Not Exists... ', 1, 'N');
				       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_ref_line_id_tbl('||l_service_ref_line_id||').: '||NVL(to_char(l_service_ref_line_id_tbl(l_service_ref_line_id)),'null'),1,'Y');
				    END IF;
				    l_qte_line_rec.QUOTE_LINE_ID := c_order_line_rec.LINE_ID;
				    l_qte_line_rec.INVENTORY_ITEM_ID := c_order_line_rec.INVENTORY_ITEM_ID;
				    l_qte_line_rec.QUANTITY := c_order_line_rec.PRICING_QUANTITY;
				    l_qte_line_rec.UOM_CODE := c_order_line_rec.PRICING_QUANTITY_UOM;
				    l_qte_line_rec.PRICE_LIST_ID := c_order_line_rec.PRICE_LIST_ID;
				    l_qte_line_rec.LINE_LIST_PRICE := c_order_line_rec.UNIT_LIST_PRICE;
				    --l_qte_line_rec.UNIT_PRICE := c_order_line_rec.UNIT_LIST_PRICE_PER_PQTY;  -- bug 17517305
				    l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_ORDER_LINE';

				    l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
				    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Order Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
				    END IF;
				END LOOP;
			END IF; -- Parent line already exists.
		    ELSIF l_ref_type_code = 'CUSTOMER_PRODUCT' THEN
			IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
				IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Instance Line exists in p_qte_line_tbl. ',1,'Y');
				END IF;
			ELSE
				-- FOR c_get_cust_acct_id_rec IN c_get_cust_acct_id LOOP
				    /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
				     open c_get_cust_acct_id_ln(p_qte_line_tbl(i).quote_line_id);
				     fetch c_get_cust_acct_id_ln into l_cust_account_id;
				     if (c_get_cust_acct_id_ln%NOTFOUND) or (l_cust_account_id is null) THEN
					  open c_get_cust_acct_id;
					  fetch c_get_cust_acct_id into l_cust_account_id;
					  if c_get_cust_acct_id%NOTFOUND THEN
						l_cust_account_id := NULL;
					  end if;
					  close c_get_cust_acct_id;
				     end if;
				     close c_get_cust_acct_id_ln;
				     /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
				     FOR c_csi_line_rec IN c_csi_line
				          (l_service_ref_line_id,l_cust_account_id) LOOP
					IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
						aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_cust_account_id'||l_cust_account_id, 1, 'N');
					END IF;
					l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
					IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
						aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Instance Line not exists...', 1, 'N');
						aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_ref_line_id_tbl('||l_service_ref_line_id||').: '||NVL(to_char(l_service_ref_line_id_tbl(l_service_ref_line_id)),'null'),1,'Y');
					END IF;
					FOR c_order_line_rec IN c_order_line(c_csi_line_rec.original_order_line_id) LOOP
                                                l_order_found := TRUE;
						l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
						l_qte_line_rec.INVENTORY_ITEM_ID := c_order_line_rec.INVENTORY_ITEM_ID;
						l_qte_line_rec.QUANTITY := c_order_line_rec.PRICING_QUANTITY;
						l_qte_line_rec.UOM_CODE := c_order_line_rec.PRICING_QUANTITY_UOM;
						l_qte_line_rec.PRICE_LIST_ID := c_order_line_rec.PRICE_LIST_ID;
						l_qte_line_rec.LINE_LIST_PRICE := c_order_line_rec.UNIT_LIST_PRICE;
						--l_qte_line_rec.UNIT_PRICE := c_order_line_rec.UNIT_LIST_PRICE_PER_PQTY;  -- bug 17517305
						l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
						l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
						IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
							aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Instance Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
						END IF;
					END LOOP;--c_order_line
                                       /******* Start SUN Changes ER: 3802859 ***********/

					IF l_order_found = FALSE THEN -- this means no order line was found then
					  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ******  Inside new  condition', 1, 'N');
					    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ****** l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
                                            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ****** l_cust_account_id: '|| l_cust_account_id, 1, 'N');
					  END IF;

					  open c_csi_line_details(l_service_ref_line_id,l_cust_account_id);
					  fetch c_csi_line_details into l_prod,l_item_id,l_qty,l_uom;

					  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
						   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ******  After getting the csi line details', 1, 'N');
					  END IF;

					  l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
					  l_qte_line_rec.INVENTORY_ITEM_ID := l_item_id;
					  l_qte_line_rec.QUANTITY := l_qty;
					  l_qte_line_rec.UOM_CODE := l_uom;

				          -- Get the price list from the header
                                          open c_get_price_list(p_qte_header_rec.quote_header_id);
                                          fetch c_get_price_list INTO l_qte_line_rec.PRICE_LIST_ID;
                                          CLOSE c_get_price_list;

					  l_qte_line_rec.LINE_LIST_PRICE := 0;
					 -- l_qte_line_rec.UNIT_PRICE := 0;  -- bug 17517305
					  l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
					  l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;

					  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
							aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ******  l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
							aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ******  l_item_id: '|| l_item_id, 1, 'N');
							aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ******  l_qty: '|| l_qty, 1, 'N');
							aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ******  l_uom: '|| l_uom, 1, 'N');
							aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ****** l_qte_line_rec.PRICE_LIST_ID: '||l_qte_line_rec.PRICE_LIST_ID, 1, 'N');
							aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** ER: 3802859 ****** Instance Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
					 END IF;

                                         close c_csi_line_details;
                                       END IF;

                                   /******* End SUN  Changes ER: 3802859 ***********/



				     END LOOP;--c_csi_line
				--END LOOP;-- c_get_cust_acct_id
			END IF; -- Parent line already exists.
		    ELSIF l_ref_type_code = 'QUOTE' THEN
			IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) OR
			   l_service_product_id_tbl.exists(l_service_ref_line_id)
			THEN
				IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Quote Line exists in p_qte_line_tbl. ',1,'Y');
				END IF;
			ELSE
				l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
				IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Quote Line NOT exists in p_qte_line_tbl. ',1,'Y');
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_ref_line_id_tbl('||l_service_ref_line_id||').                       :'||NVL(to_char(l_service_ref_line_id_tbl(l_service_ref_line_id)),'null'),1,'Y');
				END IF;
				l_qte_line_tbl(l_qte_line_tbl.COUNT+1) := ASO_UTILITY_PVT.Query_Qte_Line_Row(l_service_ref_line_id);
				IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Quote Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
				END IF;
			END IF;-- Parent line already exists.
		  /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
                  ELSIF l_ref_type_code = 'PRODUCT_CATALOG' THEN
                     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ER  PRODUCT CATALOG ****** ', 1, 'N');
		     END IF;
                     IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
				     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					 aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Parent Instance Line exists in p_qte_line_tbl. ',1,'Y');
				     END IF;
		     ELSE
			l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
			l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
			l_qte_line_rec.INVENTORY_ITEM_ID := l_service_ref_line_id;
			l_qte_line_rec.QUANTITY :=p_qte_line_tbl(i).QUANTITY;
			l_qte_line_rec.UOM_CODE := p_qte_line_tbl(i).UOM_CODE;

				-- Get the price list from the header
			open c_get_price_list(p_qte_header_rec.quote_header_id);
			fetch c_get_price_list INTO l_qte_line_rec.PRICE_LIST_ID;
			CLOSE c_get_price_list;

				l_qte_line_rec.LINE_LIST_PRICE := 0;
			      --  l_qte_line_rec.UNIT_PRICE := 0;  -- bug 17517305
				l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
				l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;

				IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ER  PRODUCT CATALOG ******  l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ER  PRODUCT CATALOG ******  l_item_id: '|| l_service_ref_line_id, 1, 'N');
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ER  PRODUCT CATALOG ******  l_qty: '|| p_qte_line_tbl(i).QUANTITY, 1, 'N');
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ER  PRODUCT CATALOG ******  l_uom: '|| p_qte_line_tbl(i).UOM_CODE, 1, 'N');
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ER  PRODUCT CATALOG ****** l_qte_line_rec.PRICE_LIST_ID: '||l_qte_line_rec.PRICE_LIST_ID, 1, 'N');
					aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: **** SUN ER  PRODUCT CATALOG ****** Instance Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
				END IF;
                      END IF;-- l_service_ref_line_id_tbl
		    /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
		    END IF; -- ref_type_code check.
		END IF; -- Service Item Flag Check.
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start the Process of adding the service(child)or any normal lines into l_qte_line_tbl ...',1,'Y');
		END IF;
		IF l_qte_line_tbl.exists(1) THEN
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: One or more records exists in l_qte_line_tbl...',1,'Y');
     		END IF;
			--changes for bug 4353654
			l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_qte_line_tbl(i).quote_line_id);
			l_qte_line_tbl(l_qte_line_tbl.COUNT+1) := l_qte_line_rec;
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After adding a new record in l_qte_line_tbl...',1,'Y');
			END IF;
		ELSE
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: No record exists in l_qte_line_tbl...',1,'Y');
			END IF;
			l_qte_line_tbl(1) := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_qte_line_tbl(i).quote_line_id);
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After adding a new record in l_qte_line_tbl...',1,'Y');
			END IF;
		END IF; -- l_qte_line_tbl.exists.
	END IF; -- operation code check
     END LOOP;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: TOTAL Number of records in  l_qte_line_tbl...   :'||NVL(l_qte_line_tbl.count,0),1,'Y');
	aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: *************** l_qte_line_tbl List ****************   ',1,'Y');
	For i in 1..l_qte_line_tbl.count Loop
		aso_debug_pub.add('ASO_PRICING_FLOWS_PVT : l_qte_line_tbl('||i||').quote_line_id       :'||NVL(l_qte_line_tbl(i).quote_line_id,0),1,'Y');
		aso_debug_pub.add('ASO_PRICING_FLOWS_PVT : l_qte_line_tbl('||i||').serviceable_product_flag:'||NVL(l_qte_line_tbl(i).serviceable_product_flag,'null'),1,'Y');
		aso_debug_pub.add('ASO_PRICING_FLOWS_PVT : l_qte_line_tbl('||i||').service_item_flag:'||NVL(l_qte_line_tbl(i).service_item_flag,'null'),1,'Y');
	END LOOP;
	aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: *************** l_qte_line_tbl List End ****************   ',1,'Y');
    END IF;

    IF (l_service_qte_line_id_tbl.exists(1)) THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_qte_line_id_tbl.count                 :'||NVL(l_service_qte_line_id_tbl.count,0),1,'Y');
	END IF;
    ELSE
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: No service lines exists',1,'Y');
	END IF;
    END IF;

    For i in 1..l_qte_line_tbl.count Loop

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Line_Dtl_Rows...',1,'Y');
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl('||i||').quote_line_id               :'||NVL(l_qte_line_tbl(i).quote_line_id,0),1,'Y');
		END IF;
		l_qte_line_id := l_qte_line_tbl(i).quote_line_id;
		l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_id);


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Defaulting Hdr Lvl Price List and Currency..',1,'Y');
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.currency_code                :'||NVL(p_qte_header_rec.currency_code,'NULL'),1,'Y');
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.price_list_id                :'||NVL(to_char(p_qte_header_rec.price_list_id),'NULL'),1,'Y');
		END IF;
		-- Pass header_level currency_code to line level by default.
		l_qte_line_tbl(i).currency_code := p_qte_header_rec.currency_code;


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).price_list_id               :'||NVL(to_char(l_qte_line_tbl(i).price_list_id),'NULL'),1,'Y');
		END IF;
		-- Pass Header level price list by default.
		IF (l_qte_line_tbl(i).price_list_id is null OR
		    l_qte_line_tbl(i).price_list_id= FND_API.G_MISS_NUM) THEN
		    l_qte_line_tbl(i).price_list_id := p_qte_header_rec.price_list_id;
		END IF;


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_dtl_tbl.count                      :'||NVL(l_qte_line_dtl_tbl.count,0),1,'Y');
		END IF;
		IF l_qte_line_dtl_tbl.count = 1 THEN
			l_qte_line_dtl_rec := l_qte_line_dtl_tbl(1);
		ELSE
			l_qte_line_dtl_rec := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_REC ;
		END IF;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Shipment_Rows..',1,'Y');
		END IF;
		l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows
				  (p_qte_header_rec.quote_header_id, l_QTE_LINE_ID);
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_shipment_tbl.count                          :'||NVL(l_shipment_tbl.count,0),1,'Y');
		END IF;
		l_shipment_rec := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
		IF l_shipment_tbl.count = 1 THEN
			l_shipment_rec := l_shipment_tbl(1);
		END IF;


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Set_Global_Rec - Line Level...', 1, 'Y');
		END IF;
		ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
			p_qte_line_rec               => l_qte_line_tbl(i),
			p_qte_line_dtl_rec           => l_qte_line_dtl_rec,
			p_shipment_rec               => l_shipment_rec);

		ASO_PRICING_CORE_PVT.Print_G_Line_Rec;


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP Build_Contexts - Line Level...',1,'Y');
		END IF;

         QP_ATTR_MAPPING_PUB.Build_Contexts (
              p_request_type_code          => p_control_rec.request_type,
              p_line_index                 => l_price_index,
              p_check_line_flag            => 'N',
              p_pricing_event              => p_control_rec.pricing_event,
              p_pricing_type_code          => 'L',
              p_price_list_validated_flag  => 'N',
              x_pass_line                  => x_pass_line);


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line                                   : '||nvl(x_pass_line,'null'),1,'Y');
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Line_To_Request...',1,'Y');
		END IF;

-- Begin fix for bug 5951790.
-- We should send null as selling_price to pricing engine when the pricing_event is PRICE.

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN

        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_control_rec.pricing_event: ' || p_control_rec.pricing_event,1,'Y');
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Old ASO_PRICING_INT.G_LINE_REC.line_quote_price: ' || ASO_PRICING_INT.G_LINE_REC.line_quote_price,1,'Y');

    END IF;

    IF (p_control_rec.pricing_event = 'PRICE') THEN
        ASO_PRICING_INT.G_LINE_REC.line_quote_price :=  null;
    END IF;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: New ASO_PRICING_INT.G_LINE_REC.line_quote_price: ' ||   ASO_PRICING_INT.G_LINE_REC.line_quote_price,1,'Y');
   END IF;

-- End fix for bug 5951790.

		ASO_PRICING_CORE_PVT.Copy_Line_To_Request(
			p_Request_Type         => p_control_rec.request_type,
               p_price_line_index    => l_price_index,
			px_index_counter       => i+1);


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Append_asked_for...',1,'Y');
		END IF;

		l_index_counter := lx_index_counter;
		ASO_PRICING_CORE_PVT.Append_asked_for(
			p_pricing_event       => p_control_rec.pricing_event
              ,p_price_line_index    => l_price_index
              ,p_header_id           => p_qte_header_rec.quote_header_id
              ,p_line_id             => l_qte_line_tbl(i).quote_line_id
              ,px_index_counter      => lx_index_counter);
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After Line Append_asked_for: lx_index_counter : '||NVL(lx_index_counter,0),1,'Y');
		END IF;
		IF lx_index_counter = 0 THEN
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Assigning the value of l_index_counter back to lx_index_counter:'||l_index_counter,1,'Y');
			END IF;
			lx_index_counter := l_index_counter;
                END IF;

		IF ( i = 1 ) THEN
			l_Qte_Line_id_tbl := JTF_NUMBER_TABLE(l_qte_line_tbl(i).quote_line_id);
		ELSE
			l_Qte_Line_id_tbl.extend;
			l_Qte_Line_id_tbl(i) := l_qte_line_tbl(i).quote_line_id;
		END IF;

          --increment the line index
          px_line_index_search_tbl(l_qte_line_id) := l_price_index;
          l_price_index:= l_price_index+1;

     END LOOP;

     -- Call to Price Adjustment Relationships and Service Relationships
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Price_Adjustments...',1,'Y');
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_id_tbl.count                               : '||NVL(l_qte_line_id_tbl.count,0),1,'Y');
     END IF;

     IF p_control_rec.pricing_event = 'BATCH' THEN
		ASO_PRICING_CORE_PVT.Query_Price_Adjustments(
			p_quote_header_id => p_qte_header_rec.quote_header_id,
			p_qte_line_id_tbl => l_qte_line_id_tbl,
			x_adj_id_tbl      => l_qte_adj_id_tbl);
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_adj_id_tbl.count                                : '||NVL(l_qte_adj_id_tbl.count,0),1,'Y');
		END IF;
     END IF;--p_control_rec.pricing_event = 'BATCH'

     -- Adjustment,line,Services Relationships.
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Relationships...',1,'Y');
     END IF;
     ASO_PRICING_CORE_PVT.Query_Relationships(
       p_qte_adj_id_tbl  => l_qte_adj_id_tbl,
       p_service_qte_line_id_tbl => l_service_qte_line_id_tbl);

     FOR i IN 1..l_qte_line_tbl.count LOOP
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJ_ATTRIBS', 1, 'Y');
	END IF;
	IF p_control_rec.pricing_event = 'BATCH' THEN
		DELETE FROM ASO_PRICE_ADJ_ATTRIBS
		WHERE  PRICE_ADJUSTMENT_ID IN (SELECT PRICE_ADJUSTMENT_ID
								 FROM ASO_PRICE_ADJUSTMENTS
								 WHERE QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
								 AND QUOTE_LINE_ID = l_qte_line_tbl(i).quote_line_id);

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Adj Attribs Lines deleted '||sql%ROWCOUNT,1,'Y');
		     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS', 1, 'Y');
		END IF;
		DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
		WHERE QUOTE_LINE_ID = l_qte_line_tbl(i).quote_line_id;
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Rltd adj Lines deleted '||sql%ROWCOUNT,1,'Y');
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJUSTMENTS', 1, 'Y');
		END IF;

		DELETE FROM ASO_PRICE_ADJUSTMENTS
		WHERE quote_line_id = l_qte_line_tbl(i).quote_line_id;
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Adjustment Lines deleted '||sql%ROWCOUNT,1,'Y');
		END IF;
	END IF;--p_control_rec.pricing_event = 'BATCH'
     END LOOP;

END IF;  -- p_qte_line_tbl.count > 0.

    If l_qte_line_tbl.count >0 then

       --Need to modify the global index table of pls integer types
       l_global_pls_tbl := ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL;
       ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_PlsIndex_Table(
                                                    p_global_tbl => l_global_pls_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
       l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL;
       ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
       l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL;
       ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);

    End If; -- l_qte_line_tbl.count >0

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Populate_QP_Temp_tables...',1,'Y');
    END IF;

    ASO_PRICING_CORE_PVT.populate_qp_temp_tables;

	-- Set the control rec for QP

	l_req_control_rec.pricing_event := p_control_rec.pricing_event;
	l_req_control_rec.calculate_flag := p_control_rec.calculate_flag;
	l_req_control_rec.simulation_flag := p_control_rec.simulation_flag;
	l_req_control_rec.TEMP_TABLE_INSERT_FLAG := 'N';  ---- Modified
	l_req_control_rec.source_order_amount_flag := 'Y';
	l_req_control_rec.GSA_CHECK_FLAG := 'Y';
	l_req_control_rec.GSA_DUP_CHECK_FLAG := 'Y';
	l_req_control_rec.REQUEST_TYPE_CODE := p_control_rec.request_type;
	l_req_control_rec.rounding_flag := 'Q';

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
	END IF;

     /*   Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar (MOAC) */

	            l_req_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

    /*				End of Change                                    (MOAC) */



     QP_PREQ_PUB.PRICE_REQUEST
	          (p_control_rec           =>l_req_control_rec
	          ,x_return_status         =>l_return_status
	          ,x_return_status_Text    =>l_return_status_Text
	          );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   x_return_status := l_return_status;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
	   FND_MESSAGE.Set_Token('MSG_TXT', substr(l_return_status_text, 1,255), FALSE);
        FND_MSG_PUB.ADD;
     END IF;
	   RAISE FND_API.G_EXC_ERROR;
     END IF;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: End of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
	  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status:'
					 ||l_return_status, 1, 'Y');
	  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status_text '
					 ||l_return_status_text,1,'Y');
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Price_To_Quote...',1,'Y');
	END IF;


	ASO_PRICING_CORE_PVT.Copy_Price_To_Quote(
	     P_Api_Version_Number       => 1.0,
	     P_Init_Msg_List            => FND_API.G_FALSE,
	     P_Commit                   => p_commit,
	     p_control_rec		       => p_control_rec,
	     p_qte_header_rec           => p_qte_header_rec,
	     x_return_status            => x_return_status,
	     x_msg_count                => x_msg_count,
	     x_msg_data                 => x_msg_data);
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Copy_Price_To_Quote : x_return_status: '
					 ||NVL(x_return_status,'X'),1,'Y');
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Copy_Price_To_Quote : x_msg_count: '
					 ||NVL(x_msg_count,0),1,'Y');
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Copy_Price_To_Quote : x_msg_data: '
					 ||NVL(x_msg_data,'X'),1,'Y');
    END IF;

IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

ASO_PRICING_CORE_PVT.Process_Charges(
               P_Api_Version_Number       => 1.0,
               P_Init_Msg_List            => FND_API.G_FALSE,
               P_Commit                   => p_commit,
               p_control_rec              => p_control_rec,
               p_qte_header_rec           => p_qte_header_rec,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data);
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Process_Charges : x_return_status: '
              ||nvl(x_return_status,'NULL'),1,'Y');
 END IF;

END IF;--x_return_status = FND_API.G_RET_STS_SUCCESS
FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

FOR l IN 1 .. x_msg_count LOOP
    x_msg_data := FND_MSG_PUB.GET( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
END LOOP;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('after inside EXCEPTION  return status'||x_return_status, 1, 'Y');
      END IF;
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

END Price_Quote_Line;


/******************************************************************************
 *                                                                            *
 *  Code Path with change lines logic                                         *
 *                                                                            *
 ******************************************************************************/

PROCEDURE Price_Quote_With_Change_Lines(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
	p_internal_call_flag       IN   VARCHAR2 := 'N',
	x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Price_Quote_With_Change_Lines';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_req_control_rec             QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_prc_control_rec             ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
    l_qte_line_id                 NUMBER;
    l_qte_line_dtl_rec            ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_shipment_rec                ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_return_status               VARCHAR2(1);
    l_return_status_text          VARCHAR2(2000);
    l_message_text                VARCHAR2(2000);
    i                             BINARY_INTEGER;
    j                             BINARY_INTEGER;
    l_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_Qte_Line_Tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_dtl_tbl            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_shipment_tbl                ASO_QUOTE_PUB.Shipment_Tbl_Type;
    x_pass_line                   VARCHAR2(10);
    l_qte_line_id_tbl             JTF_NUMBER_TABLE;
    l_qte_adj_id_tbl              JTF_NUMBER_TABLE;
    l_service_qte_line_id_tbl     JTF_NUMBER_TABLE;
    l_index_counter               Number; -- This is used to keep track of lx_index_counter
    lx_index_counter              Number;
    lx_order_status_rec           QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
    l_adj_id_tbl                  Index_Link_Tbl_Type;
    l_price_index                 Number;
    px_line_index_search_tbl      ASO_PRICING_CORE_PVT.Index_Link_Tbl_Type;
    l_global_pls_tbl              QP_PREQ_GRP.pls_integer_type;
    l_global_num_tbl              QP_PREQ_GRP.NUMBER_TYPE;

    l_changed_qte_line_tbl        ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_changed_line_index          NUMBER;
    l_check_line_flag             VARCHAR2(1);
    l_complete_qte_flag           VARCHAR2(1);
    l_db_ln_counter               NUMBER;
    l_processed_flag              VARCHAR2(1);

    l_pricing_start_time          NUMBER;
    l_pricing_end_time            NUMBER;
    l_accum_aso_time              NUMBER;
    l_accum_qp_time               NUMBER;

     l_item_type_code                VARCHAR2(30);

-- bug 13482837
       ls_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
       ls                                         number:=0;


BEGIN

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  l_pricing_start_time := dbms_utility.get_time;
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Start of Price_Quote_With_Change_Lines',1,'Y');
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.request_type:'||p_control_rec.request_type,1,'Y');
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.pricing_event:'||p_control_rec.pricing_event,1,'Y');
  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.price_mode:'||p_control_rec.price_mode,1,'Y');
END IF;

l_prc_control_rec := p_control_rec;
l_price_index := 1;
l_complete_qte_flag := 'Y';

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_prc_control_rec.price_mode:'||l_prc_control_rec.price_mode,1,'Y');
END IF;

--Always process and send the summary line

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('********************* PROCESSING HEADER STARTS *******************************',1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_internal_call_flag: '||p_internal_call_flag,1,'Y');
   END IF;

   If p_internal_call_flag = 'N' then
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Set_Global_Rec  - Header Level...  ',1,'Y');
   END IF;
   ASO_PRICING_INT.G_HEADER_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
          p_qte_header_rec     => p_qte_header_rec,
          p_shipment_rec       => p_hd_shipment_rec);
   end If;--If p_internal_call_flag = 'N' then

   ASO_PRICING_CORE_PVT.Print_G_Header_Rec;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Build_Context  - Header Level...  ',1,'Y');
     l_pricing_end_time := dbms_utility.get_time;
     l_accum_aso_time := l_pricing_end_time - l_pricing_start_time;
   END IF;

   QP_Price_Request_Context.Set_Request_Id;


   QP_ATTR_MAPPING_PUB.Build_Contexts (
      P_REQUEST_TYPE_CODE          => p_control_rec.request_type,
      P_PRICING_TYPE_CODE          => 'H',
      P_line_index                 => l_price_index,
      P_pricing_event              => p_control_rec.pricing_event,
      p_check_line_flag            => 'N',
      x_pass_line                  => x_pass_line);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     l_pricing_start_time := dbms_utility.get_time;
     l_accum_qp_time := l_pricing_start_time - l_pricing_end_time;
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Header_To_Request...',1,'Y');
   END IF;


   ASO_PRICING_CORE_PVT.Copy_Header_To_Request(
       p_Request_Type                   => p_control_rec.request_type,
       p_price_line_index               => l_price_index,
       px_index_counter                 => 1);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Append_asked_for...',1,'Y');
   END IF;

   lx_index_counter:= 1;
   ASO_PRICING_CORE_PVT.Append_asked_for(
        p_pricing_event                   => p_control_rec.pricing_event,
        p_price_line_index                => l_price_index,
        p_header_id                       => p_qte_header_rec.quote_header_id,
        px_index_counter                  => lx_index_counter);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:After Append Ask for lx_index_counter:'
                        ||lx_index_counter,1,'Y');
   END IF;
   --increment the line index
   l_price_index:= l_price_index+1;

   -- Header ends here

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('************************ HEADER LEVEL ENDS *******************************',1,'Y');
     aso_debug_pub.add('  ',1,'Y');
     aso_debug_pub.add('************************ LINE LEVEL BEGINS *******************************',1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Before call Get_Order_Lines_Status:p_control_rec.pricing_event:'
                        ||p_control_rec.pricing_event,1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Before call Get_Order_Lines_Status:p_control_rec.request_type:'
                        ||p_control_rec.request_type,1,'Y');
     l_pricing_end_time := dbms_utility.get_time;
     l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
   END IF;

   QP_UTIL_PUB.Get_Order_Lines_Status(p_event_code         => p_control_rec.pricing_event,
                                      x_order_status_rec   => lx_order_status_rec,
							   p_freight_call_flag  => 'Y',
							   p_request_type_code  => p_control_rec.request_type);

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      l_pricing_start_time := dbms_utility.get_time;
      l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);

      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:lx_order_status_rec.all_lines_flag:'
                         ||lx_order_status_rec.all_lines_flag,1,'Y');
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:lx_order_status_rec.changed_lines_flag:'
                         ||lx_order_status_rec.changed_lines_flag,1,'Y');
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:lx_order_status_rec.summary_line_flag:'
                         ||lx_order_status_rec.summary_line_flag,1,'Y');
   END IF;

   If lx_order_status_rec.all_lines_flag = 'N' then
     l_prc_control_rec.PRG_REPRICE_MODE := 'F';
   else
     l_prc_control_rec.PRG_REPRICE_MODE := 'A';
   end if;

   -- Initialize the id tables
   if l_qte_line_id_tbl is not NULL then
      l_qte_line_id_tbl.delete;
   end if;
   if l_qte_adj_id_tbl is not NULL then
      l_qte_adj_id_tbl.delete;
   end if;
   if l_service_qte_line_id_tbl is not NULL then
	 l_service_qte_line_id_tbl.delete;
   end if;

   --Query all lines and Serviceable lines
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Pricing_Line_Rows...',1,'Y');
   END IF;

   l_qte_line_tbl := ASO_UTILITY_PVT.Query_Pricing_Line_Rows(P_Qte_Header_Id => p_qte_header_rec.quote_header_id,
                                                             P_change_line_flag => FND_API.G_TRUE);
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After Query_Lines_lineIdlocation l_qte_line_tbl.count :'
                           ||NVL(l_qte_line_tbl.count,0),1,'Y');
      l_pricing_end_time := dbms_utility.get_time;
      l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
   END IF;

   If l_qte_line_tbl.count > 0 Then
      --l_qte_line_tbl.count > 0
      --Set Check line flag from the given QP matrix
      --If the line is not changed and the all_lines_flag is 'Y' then only l_check_line_flag = 'Y'
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         l_pricing_start_time := dbms_utility.get_time;
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Count of passed table p_qte_line_tbl.count:'
                            ||nvl(p_qte_line_tbl.count,0),1,'Y');
      END IF;

      For i in 1..p_qte_line_tbl.count loop
	     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Operation code:'||p_qte_line_tbl(i).operation_code,1,'Y');
             aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_qte_line_tbl(i).quote_line_id:'
	                           ||p_qte_line_tbl(i).quote_line_id,1,'Y');
		END IF;
          if p_qte_line_tbl(i).operation_code <> 'DELETE' Then
             --changed line
             --assign all the Is_line_changed_flag to 'N' for the ones that are created and updated i.e. are the chg lines
		   --Is Line Changed flag is set to 'N' because this value is what needs to be sent to BuildContext
		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Assign the Is_line_changed_flag to N',1,'Y');
		   END IF;
             l_qte_line_tbl(p_qte_line_tbl(i).quote_line_id).Is_line_changed_flag := 'N';
		   l_changed_qte_line_tbl(p_qte_line_tbl(i).quote_line_id) := l_qte_line_tbl(p_qte_line_tbl(i).quote_line_id);

		    -- Code added for option lines bug 8976983
		   select nvl(item_type_code,'X') into l_item_type_code
		   from aso_quote_lines_all
		   where quote_line_id = p_qte_line_tbl(i).quote_line_id;

		    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                               aso_debug_pub.add('8976983 ASO_PRICING_FLOWS_PVT:MODEL ITEM header id :'||p_qte_line_tbl(i).item_type_code,1,'Y');
					        aso_debug_pub.add('8976983 ASO_PRICING_FLOWS_PVT:MODEL ITEM line id :'||p_qte_line_tbl(i).operation_code,1,'Y');
						 aso_debug_pub.add('8976983 ASO_PRICING_FLOWS_PVT:l_item_type_code :'||l_item_type_code,1,'Y');
		    END IF;

		    -- bug 13482837  rassharm
		    if p_qte_line_tbl(i).item_type_code='SRV'  and (p_qte_line_tbl(i).operation_code='CREATE'  or p_qte_line_tbl(i).operation_code = 'UPDATE') then
                              If (lx_order_status_rec.all_lines_flag = 'N') AND (lx_order_status_rec.changed_lines_flag = 'Y') then
		                  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                       aso_debug_pub.add(' rassharm ASO_PRICING_FLOWS_PVT:service ITEM line id :'||p_qte_line_tbl(i).quote_line_id,1,'Y');
                                   end if;
		                   ls_qte_line_tbl:=ASO_UTILITY_PVT.Query_Pricing_Line_Row(P_Qte_Header_Id => p_qte_header_rec.quote_header_id, p_qte_line_id=>p_qte_line_tbl(i).quote_line_id);
                                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                           aso_debug_pub.add(' ASO_PRICING_FLOWS_PVT:ls_qte_line_tbl count :'||ls_qte_line_tbl.count,1,'Y');
                                     end if;
		                     for ls in 1..ls_qte_line_tbl.count loop
                                          l_qte_line_tbl(ls_qte_line_tbl(ls).quote_line_id).Is_line_changed_flag := 'N';
			                  l_changed_qte_line_tbl(ls_qte_line_tbl(ls).quote_line_id) := l_qte_line_tbl(ls_qte_line_tbl(ls).quote_line_id);

		                    end loop;
                              end if; -- all lines flag
                    end if;  -- item code ='SRV'
--- end bug 13482837  rassharm

                      if (l_item_type_code='MDL') and (p_qte_line_tbl(i).operation_code = 'UPDATE') then
		           If (lx_order_status_rec.all_lines_flag = 'N') AND (lx_order_status_rec.changed_lines_flag = 'Y') then
			        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                               aso_debug_pub.add('8976983 ASO_PRICING_FLOWS_PVT:MODEL ITEM header id :'||p_qte_line_tbl(i).quote_header_id,1,'Y');
					        aso_debug_pub.add('8976983 ASO_PRICING_FLOWS_PVT:MODEL ITEM line id :'||p_qte_line_tbl(i).quote_line_id,1,'Y');
		                 END IF;
				for opt_cursor in (
				         SELECT quote_line_id
                                         FROM   aso_quote_line_details
					  WHERE  ref_type_code = 'CONFIG'
						AND    top_model_line_id = p_qte_line_tbl(i).quote_line_id
						AND    quote_line_id  in (
						select quote_line_id from aso_quote_lines_all
						where quote_header_id=p_qte_line_tbl(i).quote_header_id
						and item_type_code in ('CFG')))
				loop
				         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                               aso_debug_pub.add('8976983 ASO_PRICING_FLOWS_PVT:MODEL ITEM:'||opt_cursor.quote_line_id,1,'Y');
		                        END IF;
					  l_qte_line_tbl(opt_cursor.quote_line_id).Is_line_changed_flag := 'N';
					  l_changed_qte_line_tbl(opt_cursor.quote_line_id) := l_qte_line_tbl(opt_cursor.quote_line_id);
				end loop;
			end if; --  changed flags
		 end if;  -- model item
            -- end Code added for option lines bug 8976983
          end if;
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_line_tbl(p_qte_line_tbl(i).quote_line_id).Is_line_changed_flag:'
		                      ||l_qte_line_tbl(p_qte_line_tbl(i).quote_line_id).Is_line_changed_flag,1,'Y');
		END IF;
      end loop;

	 --If all lines flag is 'N' and changed lines flag 'Y' then in the table just have the changed lines.
	 If (lx_order_status_rec.all_lines_flag = 'N') AND (lx_order_status_rec.changed_lines_flag = 'Y') then
	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_changed_qte_line_tbl.count:'
		                     ||NVL(l_changed_qte_line_tbl.count,0),1,'Y');
	    END IF;
	    l_qte_line_tbl := l_changed_qte_line_tbl;
	 End If;

      i := l_qte_line_tbl.first;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         l_pricing_end_time := dbms_utility.get_time;
         l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
      END IF;

      While i is not null Loop
	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_start_time := dbms_utility.get_time;
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:--------------Start line loop---------------',1,'Y');
	    END IF;
	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).quote_line_id:'
	                         ||NVL(l_qte_line_tbl(i).quote_line_id,0),1,'Y');
	    END IF;

         l_check_line_flag := l_qte_line_tbl(i).Is_line_changed_flag;
	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_check_line_flag passed to Build Context:'
                               ||l_check_line_flag,1,'Y');
	    END IF;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Defaulting Hdr Lvl Price List and Currency..',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.currency_code :'
                               ||NVL(p_qte_header_rec.currency_code,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.price_list_id :'
                               ||NVL(to_char(p_qte_header_rec.price_list_id),'NULL'),1,'Y');
         END IF;

         -- Pass header_level currency_code to line level by default.
         l_qte_line_tbl(i).currency_code := p_qte_header_rec.currency_code;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).price_list_id :'
                               ||NVL(to_char(l_qte_line_tbl(i).price_list_id),'NULL'),1,'Y');
         END IF;
         -- Pass Header level price list by default.
         IF l_qte_line_tbl(i).pricing_line_type_indicator = 'F' then
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Free line so not defaulting of the price list',1,'Y');
            END IF;
         ELSE
            /*Default the price list*/
            If l_qte_line_tbl(i).price_list_id is null Then
               l_qte_line_tbl(i).price_list_id := p_qte_header_rec.price_list_id;
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Price list id defaulted from Header:'
                                    ||NVL(to_char(l_qte_line_tbl(i).price_list_id),'NULL'),1,'Y');
               END IF;
            End if;
         END IF;--l_qte_line_tbl(i).pricing_line_type_indicator = 'F'

         l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_tbl(i).quote_line_id);
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_dtl_tbl.count :'
                               ||NVL(l_qte_line_dtl_tbl.count,0),1,'Y');
         END IF;
         IF l_qte_line_dtl_tbl.count = 1 THEN
            l_qte_line_dtl_rec := l_qte_line_dtl_tbl(1);
         ELSE
            l_qte_line_dtl_rec := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_REC ;
         END IF;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Shipment_Rows..',1,'Y');
         END IF;
         l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows
                                           (p_qte_header_rec.quote_header_id, l_qte_line_tbl(i).quote_line_id);
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_shipment_tbl.count :'
                               ||NVL(l_shipment_tbl.count,0),1,'Y');
         END IF;
         IF l_shipment_tbl.count = 1 THEN
            l_shipment_rec := l_shipment_tbl(1);
         else
            l_shipment_rec := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
         END IF;
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Set_Global_Rec - Line Level...', 1, 'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:These values will be defaulted from header for pricing qualification only:',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_line_tbl(i).invoice_to_party_site_id:'
                               ||NVL(to_char(l_qte_line_tbl(i).invoice_to_party_site_id),'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.ship_to_party_site_id:'
                               ||NVL(to_char(l_shipment_rec.ship_to_party_site_id),'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_line_tbl(i).agreement_id:'
                               ||NVL(to_char(l_qte_line_tbl(i).agreement_id),'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.ship_method_code:'
                               ||NVL(l_shipment_rec.ship_method_code,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.freight_terms_code:'
                               ||NVL(l_shipment_rec.freight_terms_code,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.FREIGHT_CARRIER_CODE:'
                               ||NVL(l_shipment_rec.FREIGHT_CARRIER_CODE,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.FOB_CODE:'
                               ||NVL(l_shipment_rec.FOB_CODE,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.REQUEST_DATE:'
                               ||NVL(to_char(l_shipment_rec.REQUEST_DATE),'NULL'),1,'Y');
         END IF;

         ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
                    p_qte_line_rec               => l_qte_line_tbl(i),
                    p_qte_line_dtl_rec           => l_qte_line_dtl_rec,
                    p_shipment_rec               => l_shipment_rec);

         ASO_PRICING_CORE_PVT.Print_G_Line_Rec;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP Build_Contexts - Line Level...',1,'Y');
            l_pricing_end_time := dbms_utility.get_time;
            l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
         END IF;

         QP_ATTR_MAPPING_PUB.Build_Contexts (
                         p_request_type_code          => p_control_rec.request_type,
                         p_line_index                 => l_price_index,
                         p_check_line_flag            => l_check_line_flag,
                         p_pricing_event              => p_control_rec.pricing_event,
                         p_pricing_type_code          => 'L',
                         p_price_list_validated_flag  => 'N',
                         x_pass_line                  => x_pass_line);

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_start_time := dbms_utility.get_time;
            l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
         END IF;

         --Note: If the line has been changed, we have to send this line to pricing engine
         --Also, if the line has not been changed but x_pass_line is 'Y' then we have to send this line to PE
         If (x_pass_line = 'Y' AND l_check_line_flag = 'Y') OR (l_check_line_flag = 'N') then
            --Store this in the processed id table and put it in the PE structure
            /*Store all the quote_line_id processed*/
            IF l_Qte_Line_id_tbl.EXISTS(1) THEN
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of l_qte_line_id_tbl.extend...',1,'Y');
               END IF;
               l_Qte_Line_id_tbl.extend;
               l_Qte_Line_id_tbl(l_Qte_Line_id_tbl.count) := l_qte_line_tbl(i).quote_line_id;
            ELSE
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: First quote_line_id in l_qte_line_id_tbl',1,'Y');
               END IF;
               l_Qte_Line_id_tbl := JTF_NUMBER_TABLE(l_qte_line_tbl(i).quote_line_id);
            END IF;

            --Store all the service lines processed in the service line id table
	       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).service_item_flag: '
		                       ||l_qte_line_tbl(i).service_item_flag,1,'Y');
		  END IF;
            If l_qte_line_tbl(i).service_item_flag = 'Y' then
               if l_service_qte_line_id_tbl.EXISTS(1) then
                  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of l_service_qte_line_id_tbl.extend...',1,'Y');
                  END IF;
                  l_service_qte_line_id_tbl.extend;
                  l_service_qte_line_id_tbl(l_service_qte_line_id_tbl.count) := l_qte_line_tbl(i).quote_line_id;
               else
                  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: First quote_line_id in l_service_qte_line_id_tbl',1,'Y');
                  END IF;
                  l_service_qte_line_id_tbl:= JTF_NUMBER_TABLE(l_qte_line_tbl(i).quote_line_id);
               end if;
            end if;-- l_qte_line_tbl(i).service_item_flag = 'Y'

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Line_To_Request...',1,'Y');
            END IF;
            ASO_PRICING_CORE_PVT.Copy_Line_To_Request(
                      p_Request_Type         => p_control_rec.request_type,
                      p_price_line_index    => l_price_index,
                      px_index_counter       => l_price_index);

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Append_asked_for...',1,'Y');
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Before Append Ask for lx_index_counter:'
                                  ||lx_index_counter,1,'Y');
            END IF;
            l_index_counter := lx_index_counter;
            ASO_PRICING_CORE_PVT.Append_asked_for(
                                       p_pricing_event   => p_control_rec.pricing_event,
                                       p_price_line_index => l_price_index,
                                       p_header_id       => p_qte_header_rec.quote_header_id,
                                       p_line_id         => l_qte_line_tbl(i).quote_line_id,
                                       px_index_counter  => lx_index_counter);
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:After Append Ask for lx_index_counter:'
                                  ||lx_index_counter,1,'Y');
            END IF;
            If lx_index_counter = 0 then
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Assigning l_index_counter back to lx_index_counter:'
		                           ||l_index_counter,1,'Y');
               END IF;
               lx_index_counter := l_index_counter;
            end if;

            px_line_index_search_tbl(l_qte_line_tbl(i).quote_line_id) := l_price_index;--Used for modify globals
            --end of building one line
            i:= l_qte_line_tbl.next(i);
            l_price_index:= l_price_index+1;
         Else
            -- x_pass_line = 'N' OR l_check_line_flag = 'Y'
            l_complete_qte_flag := 'N';
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   	     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:This line is not passed to PE:'
		                     ||l_qte_line_tbl(i).quote_line_id,1,'Y');
            END IF;
            i:= l_qte_line_tbl.next(i);
         end If;--x_pass_line = 'Y' AND l_check_line_flag = 'Y'
	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_end_time := dbms_utility.get_time;
            l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
	    END IF;

      End Loop;--End of While loop

   End If; --l_qte_line_tbl.count > 0


   --- Need to track the changed lines counter.....
   If (lx_order_status_rec.all_lines_flag = 'N') AND (lx_order_status_rec.changed_lines_flag = 'Y') then
        --If l_price_index = 2 then there were no changed lines as all the records
        --in p_qte_line_tbl were deletes.
        --Check no of lines in the db and the (l_price_index - 2), if <> then l_complete_qte_flag is 'N'

        SELECT count(rowid)
        INTO   l_db_ln_counter
        FROM ASO_QUOTE_LINES_ALL
        WHERE quote_header_id = p_qte_header_rec.quote_header_id;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_db_ln_counter:'||l_db_ln_counter,1,'Y');
           aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_price_index:'||l_price_index,1,'Y');
        END IF;
        If (l_db_ln_counter <> (l_price_index - 2)) Then
            l_complete_qte_flag := 'N';
        end if;
   elsif (lx_order_status_rec.all_lines_flag = 'N') AND (lx_order_status_rec.changed_lines_flag = 'N') then
      --Changed Lines flag = 'N'
      --then pass only header to Price_Request
	 --Since we are only sending the summary line to pricing the quote is not completely priced
	 l_complete_qte_flag := 'N';

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:All line flag is N and changed line flag is N',1,'Y');
      END IF;

  End If;

  -- Call to Price Adjustments, Adjustments Relationships, and Service Relationships
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     l_pricing_start_time := dbms_utility.get_time;
  END IF;
  IF l_Qte_Line_id_tbl.EXISTS(1) THEN
  	 -- Call to Price Adjustment Relationships and Service Relationships
    	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    	   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Price_Adjustments...',1,'Y');
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_id_tbl.count :'
					  ||NVL(l_qte_line_id_tbl.count,0),1,'Y');
    	 END IF;
	 ASO_PRICING_CORE_PVT.Query_Price_Adjustments
		(p_quote_header_id	     => p_qte_header_rec.quote_header_id,
 		 p_qte_line_id_tbl       => l_qte_line_id_tbl,
		 x_adj_id_tbl            => l_qte_adj_id_tbl);

      If l_qte_adj_id_tbl.exists(1) OR l_service_qte_line_id_tbl.exists(1) Then
         -- Adjustment and line Relationships and services...
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Adj_rltship_Bulk...',1,'Y');
		  If l_qte_adj_id_tbl is not null then
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_adj_id_tbl.count :'
					         ||NVL(l_qte_adj_id_tbl.count,0),1,'Y');
            end if;
		  If l_service_qte_line_id_tbl is not null then
               aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_service_qte_line_id_tbl.count :'
					         ||NVL(l_service_qte_line_id_tbl.count,0),1,'Y');
            end if;
         END IF;
         ASO_PRICING_CORE_PVT.Query_relationships
		(p_qte_adj_id_tbl           => l_qte_adj_id_tbl,
           p_service_qte_line_id_tbl  => l_service_qte_line_id_tbl);
      else
	  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: There are no service lines or manual related Adjustments',1,'Y');
       END IF;
      end if;--If l_qte_adj_id_tbl.exists(1) OR l_service_qte_line_id_tbl.exists(1)
  ELSIF (lx_order_status_rec.summary_line_flag = 'Y') THEN
        --Just send the header level manual adjustments
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Price_Adj_Header...',1,'Y');
        END IF;
        ASO_PRICING_CORE_PVT.Query_Price_Adj_Header
            (p_quote_header_id       => p_qte_header_rec.quote_header_id);

  END IF; -- l_Qte_Line_id_tbl.EXISTS(1) check.

-- Start of  Deleting of attributes logic

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin bulk collect adj ids that are not passed to PE', 1, 'Y');
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	If l_qte_adj_id_tbl is not null then
	   For i in 1..l_qte_adj_id_tbl.count loop
	       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Querying for the following adjustment  ids:',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_adj_id_tbl(i):'||l_qte_adj_id_tbl(i),1,'Y');
	   end loop;
	end if;
  END IF;

  If l_qte_adj_id_tbl.EXISTS(1) then
    SELECT adj.PRICE_ADJUSTMENT_ID
    BULK COLLECT INTO
    l_adj_id_tbl
    FROM ASO_PRICE_ADJUSTMENTS adj
    WHERE adj.quote_header_id = p_qte_header_rec.quote_header_id
    AND adj.price_adjustment_id NOT IN (SELECT column_value
    							     FROM TABLE (CAST(l_qte_adj_id_tbl AS JTF_NUMBER_TABLE)) passed_adj);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: No. of adjustment lines selected is sql%rowcount(Both hdr and lines): '
                          ||sql%rowcount,1,'Y');
    END IF;
  Elsif (lx_order_status_rec.summary_line_flag = 'Y') Then
     SELECT adj.PRICE_ADJUSTMENT_ID
     BULK COLLECT INTO
     l_adj_id_tbl
     FROM ASO_PRICE_ADJUSTMENTS adj
     WHERE adj.quote_header_id = p_qte_header_rec.quote_header_id
     AND adj.quote_line_id IS NULL;
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: No. of adjustment lines selected is sql%rowcount(Header): '
                          ||sql%rowcount,1,'Y');
     END IF;
  END If;--l_qte_adj_id_tbl.EXISTS(1)

  IF aso_debug_pub.g_debug_flag = 'Y' THEN

     if l_adj_id_tbl.count > 0 then

        for k in l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST loop
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_adj_id_tbl('||k||'): ' || l_adj_id_tbl(k),1,'Y');
        end loop;

     end if;

  END IF;

  if l_adj_id_tbl.count > 0 then
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJ_ATTRIBS', 1, 'Y');
     END IF;
     FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
           DELETE FROM ASO_PRICE_ADJ_ATTRIBS
           WHERE PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:No of adjustment attribute lines deleted is sql%rowcount: '
	                    ||sql%rowcount,1,'Y');
     END IF;

  end if;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_complete_qte_flag before delete:'||l_complete_qte_flag,1,'Y');
  END IF;

-- End Deleting of attributes

  if l_complete_qte_flag = 'Y' then
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS', 1, 'Y');
    END IF;
    DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
    WHERE QUOTE_LINE_ID in (SELECT quote_line_id
                           FROM ASO_PRICE_ADJUSTMENTS
                           WHERE quote_header_id = p_qte_header_rec.quote_header_id
                           AND quote_line_id IS NOT NULL);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Rltd adj Lines deleted '||sql%ROWCOUNT,1,'Y');
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJUSTMENTS', 1, 'Y');
    END IF;

    DELETE FROM ASO_PRICE_ADJUSTMENTS
    WHERE quote_header_id = p_qte_header_rec.quote_header_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Adjustment Lines deleted '||sql%ROWCOUNT,1,'Y');
    END IF;

  else
    --l_complete_qte_flag is 'N'

    IF l_Qte_Line_id_tbl.EXISTS(1) THEN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS', 1, 'Y');
          For i in 1..l_qte_line_id_tbl.count loop
              aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE for l_qte_line_id_tbl(i):'
  		                      ||l_qte_line_id_tbl(i), 1, 'Y');
         end loop;
       END IF;

       DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
       WHERE quote_line_id IN (SELECT column_value
                              FROM TABLE (CAST(l_qte_line_id_tbl AS JTF_NUMBER_TABLE)));

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Rltd adj Lines deleted '||sql%ROWCOUNT,1,'Y');
       END IF;

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Begin DELETE FROM ASO_PRICE_ADJUSTMENTS', 1, 'Y');
       END IF;
       DELETE FROM ASO_PRICE_ADJUSTMENTS
       WHERE quote_line_id IN (SELECT column_value
                              FROM TABLE (CAST(l_qte_line_id_tbl AS JTF_NUMBER_TABLE)))
       AND quote_header_id = p_qte_header_rec.quote_header_id;
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Adjustment Lines deleted '||sql%ROWCOUNT,1,'Y');
       END IF;

       DELETE FROM ASO_PRICE_ADJUSTMENTS
	  WHERE quote_header_id = p_qte_header_rec.quote_header_id
	  AND quote_line_id is NULL;

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Header Adjustment deleted '||sql%ROWCOUNT,1,'Y');
       END IF;
   ELSIF (lx_order_status_rec.summary_line_flag = 'Y') Then
      DELETE FROM ASO_PRICE_ADJUSTMENTS
      WHERE quote_header_id = p_qte_header_rec.quote_header_id
      AND quote_line_id is NULL;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Header Adjustment deleted '||sql%ROWCOUNT,1,'Y');
      END IF;

   END IF;--l_Qte_Line_id_tbl.EXISTS(1)


end if;--l_complete_qte_flag = 'Y'


  If (l_Qte_Line_id_tbl.EXISTS(1))
     OR (p_control_rec.pricing_event = 'ORDER')
     OR (lx_order_status_rec.summary_line_flag = 'Y') then
--Condition was placed because engine call was not necessary if the event is price and there are no lines

   --Need to modify the global index table of pls integer types
  l_global_pls_tbl := ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Modifying G_LDET_LINE_INDEX_TBL',1,'Y');
  END IF;
  ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_PlsIndex_Table(
                                                    p_global_tbl => l_global_pls_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
  l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Modifying G_RLTD_LINE_INDEX_TBL',1,'Y');
  END IF;
  ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
  l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Modifying G_RLTD_RELATED_LINE_IND_TBL',1,'Y');
  END IF;
  ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Populate_QP_Temp_tables...',1,'Y');
    l_pricing_end_time := dbms_utility.get_time;
    l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
  END IF;

  ASO_PRICING_CORE_PVT.populate_qp_temp_tables;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     l_pricing_start_time := dbms_utility.get_time;
     l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
  END IF;
  -- Set the control rec for QP

  l_req_control_rec.pricing_event := p_control_rec.pricing_event;
  l_req_control_rec.calculate_flag := p_control_rec.calculate_flag;
  l_req_control_rec.simulation_flag := p_control_rec.simulation_flag;
  l_req_control_rec.TEMP_TABLE_INSERT_FLAG := 'N';  ---- Modified
  l_req_control_rec.source_order_amount_flag := 'Y';
  l_req_control_rec.GSA_CHECK_FLAG := 'Y';
  l_req_control_rec.GSA_DUP_CHECK_FLAG := 'Y';
  l_req_control_rec.REQUEST_TYPE_CODE := p_control_rec.request_type;
  l_req_control_rec.rounding_flag := 'Q';
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_req_control_rec.calculate_flag:'||l_req_control_rec.calculate_flag,1,'Y');
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
    l_pricing_end_time := dbms_utility.get_time;
    l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
  END IF;

  /*   Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar  (MOAC) */

	          l_req_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

 /*				End of Change                                  (MOAC) */


  QP_PREQ_PUB.PRICE_REQUEST
          	(p_control_rec           =>l_req_control_rec
          	,x_return_status         =>l_return_status
          	,x_return_status_Text    =>l_return_status_Text
          	);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_return_status := l_return_status;
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
	FND_MESSAGE.Set_Token('MSG_TXT', substr(l_return_status_text, 1,255), FALSE);
     FND_MSG_PUB.ADD;
  END IF;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    l_pricing_start_time := dbms_utility.get_time;
    l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: End of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status:'
                       ||l_return_status, 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status_text '
                       ||l_return_status_text,1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Post_Price_Request...',1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_complete_qte_flag:'||l_complete_qte_flag,1,'Y');
  END IF;
  /*Insert all the applied adjustments and the nonapplied manual adjustments*/
  ASO_PRICING_CORE_PVT.Copy_Price_To_Quote(
     		P_Api_Version_Number       => 1.0,
     		P_Init_Msg_List            => FND_API.G_FALSE,
     		P_Commit                   => FND_API.G_FALSE,
     		p_control_rec		       => l_prc_control_rec,
     		p_qte_header_rec           => p_qte_header_rec,
			P_Insert_Type              => 'HDR',
     		x_return_status            => x_return_status,
     		x_msg_count                => x_msg_count,
     		x_msg_data                 => x_msg_data);
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Copy_Price_To_Quote : x_return_status: '
	   	       ||nvl(x_return_status,'NULL'),1,'Y');
  END IF;

 If p_internal_call_flag = 'N' then
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       ASO_PRICING_CORE_PVT.Process_PRG(
     		P_Api_Version_Number       => 1.0,
     		P_Init_Msg_List            => FND_API.G_FALSE,
     		P_Commit                   => FND_API.G_FALSE,
     		p_control_rec		       => l_prc_control_rec,
     		p_qte_header_rec           => p_qte_header_rec,
			x_qte_line_tbl             => x_qte_line_tbl,
     		x_return_status            => x_return_status,
     		x_msg_count                => x_msg_count,
     		x_msg_data                 => x_msg_data);

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Process_PRG : x_return_status: '
                             ||nvl(x_return_status,'NULL'),1,'Y');
       END IF;

    END IF;--x_return_status = FND_API.G_RET_STS_SUCCESS

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After Process_PRG : x_qte_line_tbl.count: '
                             ||x_qte_line_tbl.count,1,'Y');
       END IF;

       ASO_PRICING_CORE_PVT.Process_Charges(
               P_Api_Version_Number       => 1.0,
               P_Init_Msg_List            => FND_API.G_FALSE,
               P_Commit                   => FND_API.G_FALSE,
               p_control_rec              => l_prc_control_rec,
               p_qte_header_rec           => p_qte_header_rec,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data);
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Process_Charges : x_return_status: '
                            ||nvl(x_return_status,'NULL'),1,'Y');
      END IF;

    END IF;--x_return_status = FND_API.G_RET_STS_SUCCESS
 End If;--p_internal_call_flag = 'N'??????????Is this okay????

    -- After the code review according to SPGOPAL if the summary line flag is 'N' then we don't need to make
    -- the calculate flag. Also we cannot compare the percentage of the header level since in future if there
    -- is a bucketing implementation for the header level modifier ASO does not have a way to compare the percentages.
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       l_pricing_end_time := dbms_utility.get_time;
       l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:**********Timing Before Calculate Call****************',1,'Y');

       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Total time taken (in secs) in Price Entire Quote(Besides Pricing):'||l_accum_aso_time/100,1,'Y');
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Total time taken (in secs) in Pricing+BuildContext:'||l_accum_qp_time/100,1,'Y');
END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Before Calling Calculate Call l_complete_qte_flag:'
		                  ||l_complete_qte_flag,1,'Y');
		aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Before Calling Calculate Call lx_order_status_rec.summary_line_flag:'
		                  ||lx_order_status_rec.summary_line_flag,1,'Y');
	  END IF;
    If (l_complete_qte_flag = 'N') then
      If (lx_order_status_rec.summary_line_flag <> 'N') then
        --If the l_processed_flag value is 'C' reprice the whole quote with all the lines with calculate only option
	   --Since the processed flag is not coded for Order Capture, Current work around is such that Order Capture should
        --always make the second call except in the above two conditions of complete qte flag and summary line flag.

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Price Request should be called again to get header level adj',1,'Y');
          END IF;

          l_prc_control_rec.calculate_flag := QP_PREQ_GRP.G_CALCULATE_ONLY;

          --Call Calculate only call

          Price_Quote_Calculate_Call(
                 P_Api_Version_Number      => P_Api_Version_Number,
                 P_Init_Msg_List           => FND_API.G_FALSE,
                 P_Commit                  => FND_API.G_FALSE,
                 p_control_rec             => l_prc_control_rec,
                 p_qte_header_rec          => p_qte_header_rec,
                 p_delta_line_id_tbl       => l_qte_line_id_tbl,
			  x_qte_line_tbl            => lx_Qte_Line_Tbl,
                 x_return_status           => x_return_status,
                 x_msg_count               => x_msg_count,
                 x_msg_data                => x_msg_data);

	    End If; -- If (lx_order_status_rec.summary_line_flag <> 'N')

	   End If;-- If l_complete_qte_flag = 'N'


    END IF;-- x_return_status = FND_API.G_RET_STS_SUCCESS


 --End If;--p_internal_call_flag = 'N'
 End if;-- (l_Qte_Line_id_tbl.EXISTS(1)) OR (p_control_rec.pricing_event = 'ORDER')


FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

FOR l IN 1 .. x_msg_count LOOP
    x_msg_data := FND_MSG_PUB.GET( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
END LOOP;

END Price_Quote_With_Change_Lines;

PROCEDURE Price_Quote_Calculate_Call(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_delta_line_id_tbl        IN   JTF_NUMBER_TABLE,
	x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_api_name                    CONSTANT VARCHAR2(30) := 'Price_Quote_Calculate_Call';
  l_api_version_number          CONSTANT NUMBER   := 1.0;
  l_price_index                 NUMBER;
  l_req_control_rec             QP_PREQ_GRP.CONTROL_RECORD_TYPE;
  l_prc_control_rec             ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
  x_pass_line                   VARCHAR2(10);
  l_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
  l_qte_line_id                 NUMBER;
  l_qte_line_dtl_rec            ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
  l_qte_line_dtl_tbl            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
  l_shipment_tbl                ASO_QUOTE_PUB.Shipment_Tbl_Type;
  l_shipment_rec                ASO_QUOTE_PUB.Shipment_Rec_Type;
  lx_index_counter              Number;
  l_index_counter               Number;
  l_return_status_text          VARCHAR2(2000);
  l_message_text                VARCHAR2(2000);
  l_return_status               VARCHAR2(1);

  l_service_qte_line_id_tbl     JTF_NUMBER_TABLE;
  l_qte_line_id_tbl             JTF_NUMBER_TABLE;
  l_qte_adj_id_tbl              JTF_NUMBER_TABLE;
  px_line_index_search_tbl      ASO_PRICING_CORE_PVT.Index_Link_Tbl_Type;
  l_global_pls_tbl              QP_PREQ_GRP.pls_integer_type;
  l_global_num_tbl              QP_PREQ_GRP.NUMBER_TYPE;

  l_pricing_start_time          NUMBER;
  l_pricing_end_time            NUMBER;
  l_accum_aso_time                  NUMBER;
  l_accum_qp_time                  NUMBER;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    l_pricing_start_time := dbms_utility.get_time;
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Start of Price_Quote_Calculate_Call',1,'Y');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.request_type:'||p_control_rec.request_type,1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.pricing_event:'||p_control_rec.pricing_event,1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_control_rec.calculate_flag:'||p_control_rec.calculate_flag,1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_qte_header_rec.quote_header_id:'||p_qte_header_rec.quote_header_id,1,'Y');
    IF p_delta_line_id_tbl is not null THEN
      for i in 1..p_delta_line_id_tbl.count loop
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:p_delta_line_id_tbl(i):'||p_delta_line_id_tbl(i), 1, 'Y');
      end loop;
    END IF;
  END IF;
  l_prc_control_rec := p_control_rec;
  l_price_index := 1;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('********************* PROCESSING HEADER STARTS *******************************',1,'Y');
  END IF;
  ASO_PRICING_CORE_PVT.Print_G_Header_Rec;
  /*Initialize the global tables*/
  ASO_PRICING_CORE_PVT.Initialize_Global_Tables;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      l_pricing_end_time := dbms_utility.get_time;
      l_accum_aso_time := l_pricing_end_time - l_pricing_start_time;
  END IF;

  QP_Price_Request_Context.Set_Request_Id;

  QP_ATTR_MAPPING_PUB.Build_Contexts (
      P_REQUEST_TYPE_CODE          => p_control_rec.request_type,
      P_PRICING_TYPE_CODE          => 'H',
      P_line_index                 => l_price_index,
      P_pricing_event              => p_control_rec.pricing_event,
      p_check_line_flag            => 'N',
      x_pass_line                  => x_pass_line);

  l_price_index := 1;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     l_pricing_start_time := dbms_utility.get_time;
     l_accum_qp_time := l_pricing_start_time - l_pricing_end_time;
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Header_To_Request...',1,'Y');
  END IF;
  ASO_PRICING_CORE_PVT.Copy_Header_To_Request(
       p_Request_Type                   => p_control_rec.request_type,
       p_price_line_index               => l_price_index,
       px_index_counter                 => 1);


  -- Do we need to do append ask for in the calculate only call????
  --increment the line index
   l_price_index:= l_price_index+1;

  -- Header ends here

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('************************ HEADER LEVEL ENDS *******************************',1,'Y');
     aso_debug_pub.add('  ',1,'Y');
     aso_debug_pub.add('************************ LINE LEVEL BEGINS *******************************',1,'Y');
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of ASO UTL PVT Query_Pricing_Line_Rows...',1,'Y');
   END IF;

   l_qte_line_tbl := ASO_UTILITY_PVT.Query_Pricing_Line_Rows(p_qte_header_rec.quote_header_id);
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl.count :'||NVL(l_qte_line_tbl.count,0),1,'Y');
     l_pricing_end_time := dbms_utility.get_time;
     l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
   END IF;

   If l_qte_line_tbl.count = 0 Then
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:No lines in the database',1,'Y');
      END IF;

   Else
      -- Line Count <> 0.
        For i in 1..l_qte_line_tbl.count Loop

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_start_time := dbms_utility.get_time;
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Line_Dtl_Rows...',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).quote_line_id:'
                               ||NVL(l_qte_line_tbl(i).quote_line_id,0),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).pricing_line_type_indicator:'
                               ||l_qte_line_tbl(i).pricing_line_type_indicator,1,'Y');
          END IF;

          l_qte_line_id := l_qte_line_tbl(i).quote_line_id;
          l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_id);

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Defaulting Hdr Lvl Price List and Currency..',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.currency_code :'
                               ||NVL(p_qte_header_rec.currency_code,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: p_qte_header_rec.price_list_id :'
                               ||NVL(to_char(p_qte_header_rec.price_list_id),'NULL'),1,'Y');
          END IF;
          -- Pass header_level currency_code to line level by default.
          l_qte_line_tbl(i).currency_code := p_qte_header_rec.currency_code;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_tbl(i).price_list_id :'
                               ||NVL(to_char(l_qte_line_tbl(i).price_list_id),'NULL'),1,'Y');
          END IF;
          -- Pass Header level price list by default.
          IF l_qte_line_tbl(i).pricing_line_type_indicator = 'F' then
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Free line so not defaulting of the price list',1,'Y');
                 END IF;
          ELSE
             /*Default the price list*/
             If l_qte_line_tbl(i).price_list_id is null Then
                l_qte_line_tbl(i).price_list_id := p_qte_header_rec.price_list_id;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Price list id defaulted from Header:'
                                  ||NVL(to_char(l_qte_line_tbl(i).price_list_id),'NULL'),1,'Y');
                END IF;
             End if;
          END IF;--l_qte_line_tbl(i).pricing_line_type_indicator = 'F'

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_qte_line_dtl_tbl.count :'
                               ||NVL(l_qte_line_dtl_tbl.count,0),1,'Y');
          END IF;
          IF l_qte_line_dtl_tbl.count = 1 THEN
               l_qte_line_dtl_rec := l_qte_line_dtl_tbl(1);
                ELSE
               l_qte_line_dtl_rec := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_REC ;
          END IF;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Shipment_Rows..',1,'Y');
          END IF;
          l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows
                                            (p_qte_header_rec.quote_header_id, l_QTE_LINE_ID);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: l_shipment_tbl.count :'
                               ||NVL(l_shipment_tbl.count,0),1,'Y');
          END IF;
          IF l_shipment_tbl.count = 1 THEN
               l_shipment_rec := l_shipment_tbl(1);
          else
               l_shipment_rec := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
          END IF;


          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Set_Global_Rec - Line Level...', 1, 'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:These values will be defaulted from header for pricing qualification only:',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_line_tbl(i).invoice_to_party_site_id:'
                               ||NVL(to_char(l_qte_line_tbl(i).invoice_to_party_site_id),'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.ship_to_party_site_id:'
                               ||NVL(to_char(l_shipment_rec.ship_to_party_site_id),'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_qte_line_tbl(i).agreement_id:'
                               ||NVL(to_char(l_qte_line_tbl(i).agreement_id),'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.ship_method_code:'
                               ||NVL(l_shipment_rec.ship_method_code,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.freight_terms_code:'
                               ||NVL(l_shipment_rec.freight_terms_code,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.FREIGHT_CARRIER_CODE:'
                               ||NVL(l_shipment_rec.FREIGHT_CARRIER_CODE,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.FOB_CODE:'
                               ||NVL(l_shipment_rec.FOB_CODE,'NULL'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:l_shipment_rec.REQUEST_DATE:'
                               ||NVL(to_char(l_shipment_rec.REQUEST_DATE),'NULL'),1,'Y');
          END IF;

          ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
                    p_qte_line_rec               => l_qte_line_tbl(i),
                    p_qte_line_dtl_rec           => l_qte_line_dtl_rec,
                    p_shipment_rec               => l_shipment_rec);

          ASO_PRICING_CORE_PVT.Print_G_Line_Rec;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP Build_Contexts - Line Level...',1,'Y');
            l_pricing_end_time := dbms_utility.get_time;
            l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
          END IF;

          QP_ATTR_MAPPING_PUB.Build_Contexts (
                    p_request_type_code          => p_control_rec.request_type,
                    p_line_index                 => l_price_index,
                    p_check_line_flag            => 'N',
                    p_pricing_event              => p_control_rec.pricing_event,
                    p_pricing_type_code          => 'L',
                    p_price_list_validated_flag  => 'N',
                    x_pass_line                  => x_pass_line);
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_start_time := dbms_utility.get_time;
            l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Copy_Line_To_Request...',1,'Y');
          END IF;

          ASO_PRICING_CORE_PVT.Copy_Line_To_Request(
               p_Request_Type         => p_control_rec.request_type,
               p_price_line_index    => l_price_index,
               px_index_counter       => i+1);


          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Append_asked_for...',1,'Y');
            aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Before Append Ask for lx_index_counter:'
                               ||lx_index_counter,1,'Y');
          END IF;
          l_index_counter := lx_index_counter;

          --Do we need to call append ask for at line level

          /*Store the line_id of all the service_lines*/
          If l_qte_line_tbl(i).service_item_flag = 'Y' then
             if l_service_qte_line_id_tbl.EXISTS(1) then
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of l_service_qte_line_id_tbl.extend...',1,'Y');
                 END IF;
                 l_service_qte_line_id_tbl.extend;
                 l_service_qte_line_id_tbl(l_service_qte_line_id_tbl.count)
                                                    := l_qte_line_tbl(i).quote_line_id;
              else
                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: First quote_line_id in l_service_qte_line_id_tbl',1,'Y');
                 END IF;
                 l_service_qte_line_id_tbl:= JTF_NUMBER_TABLE(l_qte_line_tbl(i).quote_line_id);
             end if;
          end if;-- l_qte_line_tbl(i).service_item_flag = 'Y'

          /*Store all the quote_line_id processed*/
          IF l_Qte_Line_id_tbl.EXISTS(1) THEN
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of l_qte_line_id_tbl.extend...',1,'Y');
             END IF;
             l_Qte_Line_id_tbl.extend;
             l_Qte_Line_id_tbl(l_Qte_Line_id_tbl.count) := l_qte_line_tbl(i).quote_line_id;
           ELSE
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: First quote_line_id in l_qte_line_id_tbl',1,'Y');
             END IF;
             l_Qte_Line_id_tbl := JTF_NUMBER_TABLE(l_qte_line_tbl(i).quote_line_id);
         END IF;
         --increment the line index
         px_line_index_search_tbl(l_qte_line_id) := l_price_index;
         l_price_index:= l_price_index+1;
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            l_pricing_end_time := dbms_utility.get_time;
            l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
         END IF;

      End Loop; -- l_Qte_Line_tbl.count checking.

       -- Call to Price Adjustment Relationships and Service Relationships
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        l_pricing_start_time := dbms_utility.get_time;
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Price_Adj_All...',1,'Y');
      END IF;

	 ASO_PRICING_CORE_PVT.Query_Price_Adj_All
	 (p_quote_header_id    => p_qte_header_rec.quote_header_id,
	  x_adj_id_tbl         => l_qte_adj_id_tbl);


     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Query_Relationships...',1,'Y');
     END IF;

     ASO_PRICING_CORE_PVT.Query_Relationships(
       p_qte_adj_id_tbl  => l_qte_adj_id_tbl,
       p_service_qte_line_id_tbl => l_service_qte_line_id_tbl);


  END IF; -- l_qte_line_tbl.count = 0 check.

  -- Delete only the header level adj that are applied or updated because
  -- line level modifiers will not change in Calculate only call
  DELETE FROM ASO_PRICE_ADJUSTMENTS
  WHERE quote_header_id = p_qte_header_rec.quote_header_id
  AND quote_line_id IS NULL
  AND (applied_flag = 'Y' OR updated_flag = 'Y');
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Adjustment Lines deleted '||sql%ROWCOUNT,1,'Y');
  END IF;
  DELETE FROM ASO_PRICE_ADJ_ATTRIBS
  WHERE  PRICE_ADJUSTMENT_ID IN (SELECT PRICE_ADJUSTMENT_ID
                                 FROM ASO_PRICE_ADJUSTMENTS
                                 WHERE QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
                                 AND QUOTE_LINE_ID is NULL
						   AND (applied_flag = 'Y' OR updated_flag = 'Y'));
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Hdr Adjustment Attributes deleted '||sql%ROWCOUNT,1,'Y');
  END IF;

 --Need to modify the global index table of pls integer types
  l_global_pls_tbl := ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL;
  ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_PlsIndex_Table(
                                                    p_global_tbl => l_global_pls_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
  l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL;
  ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
  l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL;
  ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Populate_QP_Temp_tables...',1,'Y');
    l_pricing_end_time := dbms_utility.get_time;
    l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
  END IF;

  ASO_PRICING_CORE_PVT.populate_qp_temp_tables;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     l_pricing_start_time := dbms_utility.get_time;
     l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
  END IF;
  -- Set the control rec for QP

  l_req_control_rec.pricing_event := '';
  l_req_control_rec.calculate_flag := p_control_rec.calculate_flag;
  l_req_control_rec.simulation_flag := p_control_rec.simulation_flag;
  l_req_control_rec.TEMP_TABLE_INSERT_FLAG := 'N';  ---- Modified
  l_req_control_rec.source_order_amount_flag := 'Y';
  l_req_control_rec.GSA_CHECK_FLAG := 'Y';
  l_req_control_rec.GSA_DUP_CHECK_FLAG := 'Y';
  l_req_control_rec.REQUEST_TYPE_CODE := p_control_rec.request_type;
  l_req_control_rec.rounding_flag := 'Q';

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
    l_pricing_end_time := dbms_utility.get_time;
    l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
  END IF;

  /*   Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar (MOAC) */

	        l_req_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

 /*				End of Change                                 (MOAC) */




  QP_PREQ_PUB.PRICE_REQUEST
               (p_control_rec           =>l_req_control_rec
               ,x_return_status         =>l_return_status
               ,x_return_status_Text    =>l_return_status_Text
               );
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := l_return_status;
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
     FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
     FND_MESSAGE.Set_Token('MSG_TXT', substr(l_return_status_text, 1,255), FALSE);
     FND_MSG_PUB.ADD;
  END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    l_pricing_start_time := dbms_utility.get_time;
    l_accum_qp_time := l_accum_qp_time + (l_pricing_start_time - l_pricing_end_time);
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: End of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status:'
                       ||l_return_status, 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: After PRICE_REQUEST l_return_status_text '
                       ||l_return_status_text,1,'Y');
    aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Start of Post_Price_Request...',1,'Y');
  END IF;

  ASO_PRICING_CORE_PVT.Copy_Price_To_Quote(
               P_Api_Version_Number       => 1.0,
               P_Init_Msg_List            => FND_API.G_FALSE,
               P_Commit                   => FND_API.G_FALSE,
               p_control_rec              => l_prc_control_rec,
               p_qte_header_rec           => p_qte_header_rec,
               p_insert_type              => 'HDR_ONLY',
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data);
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Copy_Price_To_Quote : x_return_status: '
              ||nvl(x_return_status,'NULL'),1,'Y');
 END IF;
 IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
  ASO_PRICING_CORE_PVT.Process_Charges(
               P_Api_Version_Number       => 1.0,
               P_Init_Msg_List            => FND_API.G_FALSE,
               P_Commit                   => FND_API.G_FALSE,
               p_control_rec              => l_prc_control_rec,
               p_qte_header_rec           => p_qte_header_rec,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data);
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Process_Charges : x_return_status: '
                            ||nvl(x_return_status,'NULL'),1,'Y');
      END IF;
 END IF;

FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

FOR l IN 1 .. x_msg_count LOOP
    x_msg_data := FND_MSG_PUB.GET( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
END LOOP;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   l_pricing_end_time := dbms_utility.get_time;
   l_accum_aso_time := l_accum_aso_time + (l_pricing_end_time - l_pricing_start_time);
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:********Timing in Calculate Call**************',1,'Y');
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Total time taken (in secs) in Calculate call(Besides Pricing):'||l_accum_aso_time/100,1,'Y');
   aso_debug_pub.add('ASO_PRICING_FLOWS_PVT:Total time taken (in secs) in Pricing+BuildContext:'||l_accum_qp_time/100,1,'Y');
END IF;



END Price_Quote_Calculate_Call;



End ASO_PRICING_FLOWS_PVT;

/
