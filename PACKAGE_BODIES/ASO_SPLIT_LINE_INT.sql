--------------------------------------------------------
--  DDL for Package Body ASO_SPLIT_LINE_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SPLIT_LINE_INT" as
/* $Header: asoisplb.pls 120.6.12010000.2 2012/04/17 08:18:01 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_SPLIT_LINE_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30)  :=  'ASO_SPLIT_LINE_INT';
G_FILE_NAME CONSTANT VARCHAR2(12)  :=  'asoisplb.pls';

PROCEDURE Split_Quote_line (
    P_Api_Version_Number         IN      NUMBER,
    P_Init_Msg_List              IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN      VARCHAR2     := FND_API.G_FALSE,
    p_qte_line_id                IN      NUMBER,
    P_Qte_Line_Tbl               IN      ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    P_ln_Shipment_Tbl            IN      ASO_QUOTE_PUB.Shipment_Tbl_Type
                                         := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    X_Qte_Line_Tbl               OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    )
IS

l_qte_header_rec  aso_quote_pub.qte_header_rec_type  :=  aso_quote_pub.g_miss_qte_header_rec;
l_qte_line_rec    aso_quote_pub.qte_line_rec_type    :=  aso_quote_pub.g_miss_qte_line_rec;
l_control_rec     aso_quote_pub.control_rec_type     :=  aso_quote_pub.g_miss_control_rec;

cursor c_qte_header_id is
select quote_header_id
from aso_quote_lines_all
where quote_line_id = p_qte_line_id;

Begin

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');


	x_return_status := fnd_api.g_ret_sts_success;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_SPLIT_LINE_INT: Split_Quote_line Begin', 1, 'Y');
     END IF;

     l_control_rec.pricing_request_type           :=  'ASO';
     l_control_rec.header_pricing_event           :=  'BATCH';
     l_control_rec.calculate_tax_flag             :=  'Y';
     l_control_rec.calculate_freight_charge_flag  :=  'Y';

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Split_Quote_line: p_qte_line_id: '|| p_qte_line_id);
     END IF;

     l_qte_line_rec.quote_line_id := p_qte_line_id;

     open  c_qte_header_id;
     fetch c_qte_header_id into l_qte_header_rec.quote_header_id;
     close c_qte_header_id;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Split_Quote_line: l_qte_header_rec.quote_header_id: '|| l_qte_header_rec.quote_header_id);
     END IF;

     split_quote_line(
          p_api_version_number      =>  p_api_version_number,
          p_init_msg_list           =>  fnd_api.g_false,
          p_commit                  =>  p_commit,
          p_control_rec             =>  l_control_rec,
          p_qte_header_rec          =>  l_qte_header_rec,
          p_original_qte_line_rec   =>  l_qte_line_rec,
          p_qte_line_tbl            =>  p_qte_line_tbl,
          p_ln_shipment_tbl         =>  p_ln_shipment_tbl,
          x_qte_line_tbl            =>  x_qte_line_tbl,
          x_return_status           =>  x_return_status,
          x_msg_count               =>  x_msg_count,
          x_msg_data                =>  x_msg_data );

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Split_Quote_line: After call to the overloaded split_quote_line procedure');
       aso_debug_pub.add('Split_Quote_line: x_return_status: '|| x_return_status);
     END IF;

     EXCEPTION

           WHEN OTHERS THEN
                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('Split_Quote_line: Inside when others exception', 1, 'N');
                   END IF;

End Split_Quote_line;


PROCEDURE split_quote_line(
       p_api_version_number         IN      number,
       p_init_msg_list              IN      varchar2        := fnd_api.g_false,
       p_commit                     IN      varchar2        := fnd_api.g_false,
       p_control_rec                IN      aso_quote_pub.control_rec_type
                                                            := aso_quote_pub.g_miss_control_rec,
       p_qte_header_rec             IN      aso_quote_pub.qte_header_rec_type
                                                            := aso_quote_pub.g_miss_qte_header_rec,
       p_original_qte_line_rec      IN      aso_quote_pub.qte_line_rec_type,
       p_qte_line_tbl               IN      aso_quote_pub.qte_line_tbl_type,
       p_ln_shipment_tbl            IN      aso_quote_pub.shipment_tbl_type
                                                            := aso_quote_pub.g_miss_shipment_tbl,
       x_qte_line_tbl               OUT NOCOPY /* file.sql.39 change */     aso_quote_pub.qte_line_tbl_type,
       x_return_status              OUT NOCOPY /* file.sql.39 change */     varchar2,
       x_msg_count                  OUT NOCOPY /* file.sql.39 change */     number,
       x_msg_data                   OUT NOCOPY /* file.sql.39 change */     varchar2
)
IS

l_api_name                   CONSTANT VARCHAR2(30)      :=  'Split_Quote_line';
l_api_version_number         NUMBER                     :=  1.0;
l_file                       VARCHAR2(300);
l_config_header_id           NUMBER;
l_serviceable_item           VARCHAR2(1)                :=  FND_API.G_FALSE;
l_call_do_split_line         VARCHAR2(1)                :=  FND_API.G_FALSE;
l_quote_header_id            NUMBER;
l_call_lock_exist            VARCHAR2(1)                :=  FND_API.G_FALSE;
l_x_status                   VARCHAR2(1);

l_qte_line_rec      ASO_QUOTE_PUB.Qte_Line_Rec_Type     :=  ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
l_qte_line_dtl_tbl  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type :=  ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;

lx_qte_line_tbl     ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

l_split_model_line           VARCHAR2(1)                :=  FND_API.G_FALSE;

Cursor c_config_exist is
select config_header_id
from  aso_quote_line_details
where quote_line_id = p_original_qte_line_rec.quote_line_id;

cursor c_quote_header_id is
select quote_header_id
from aso_quote_lines_all
where quote_line_id = p_original_qte_line_rec.quote_line_id;

Begin

  aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');


   --Standard Start of API savepoint
   SAVEPOINT SPLIT_QUOTE_LINE_INT;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN

     aso_debug_pub.add('ASO_SPLIT_LINE_INT: Begin Split_Quote_line', 1, 'Y');
     aso_debug_pub.add('P_Qte_Header_Rec.pricing_status_indicator:   '||P_Qte_Header_Rec.pricing_status_indicator, 1, 'Y');
     aso_debug_pub.add('P_Qte_Header_Rec.tax_status_indicator:       '||P_Qte_Header_Rec.tax_status_indicator, 1, 'Y');
     aso_debug_pub.add('P_Qte_Header_Rec.quote_header_id:            '||P_Qte_Header_Rec.quote_header_id, 1, 'Y');
     aso_debug_pub.add('P_Qte_Header_Rec.last_update_date:           '||P_Qte_Header_Rec.last_update_date, 1, 'Y');
     aso_debug_pub.add('P_Qte_Header_Rec.price_updated_date:         '||P_Qte_Header_Rec.price_updated_date, 1, 'Y');
     aso_debug_pub.add('P_Qte_Header_Rec.tax_updated_date:           '||P_Qte_Header_Rec.tax_updated_date, 1, 'Y');
     aso_debug_pub.add('P_Qte_Header_Rec.recalculate_flag:           '||P_Qte_Header_Rec.recalculate_flag, 1, 'Y');
     aso_debug_pub.add('P_Control_Rec.pricing_request_type:          '||P_Control_Rec.pricing_request_type, 1, 'Y');
     aso_debug_pub.add('P_Control_Rec.header_pricing_event:          '||P_Control_Rec.header_pricing_event, 1, 'Y');
     aso_debug_pub.add('P_Control_Rec.line_pricing_event:            '||P_Control_Rec.line_pricing_event, 1, 'Y');
     aso_debug_pub.add('P_Control_Rec.CALCULATE_TAX_FLAG:            '||P_Control_Rec.CALCULATE_TAX_FLAG, 1, 'Y');
     aso_debug_pub.add('P_Control_Rec.CALCULATE_FREIGHT_CHARGE_FLAG: '||P_Control_Rec.CALCULATE_FREIGHT_CHARGE_FLAG, 1, 'Y');
     aso_debug_pub.add('P_Control_Rec.PRICE_MODE:                    '||P_Control_Rec.PRICE_MODE, 1, 'Y');

   END IF;

   --Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
					               l_api_name,
					               G_PKG_NAME) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   --Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN

	  FND_MSG_PUB.initialize;

   END IF;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN

       aso_debug_pub.add('Split_Quote_line: p_qte_header_rec.quote_header_id:      '|| p_qte_header_rec.quote_header_id);
       aso_debug_pub.add('Split_Quote_line: p_original_qte_line_rec.quote_line_id: '|| p_original_qte_line_rec.quote_line_id);

   END IF;

   IF p_qte_header_rec.quote_header_id is not null OR
      p_qte_header_rec.quote_header_id <> fnd_api.g_miss_num THEN

         l_call_lock_exist := fnd_api.g_true;
         l_quote_header_id := p_qte_header_rec.quote_header_id;

   ELSIF p_original_qte_line_rec.quote_line_id is not null OR
         p_original_qte_line_rec.quote_line_id <> fnd_api.g_miss_num THEN

         open  c_quote_header_id;
         fetch c_quote_header_id into l_quote_header_id;

         IF c_quote_header_id%found and l_quote_header_id is not null THEN
             l_call_lock_exist := fnd_api.g_true;
         END IF;

         close c_quote_header_id;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('split_quote_line: l_quote_header_id: '|| l_quote_header_id);
         END IF;

   ELSE

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Split_Quote_line: Both quote_header_id and quote_line_id is null
 or g_miss_num');
         END IF;

   END IF;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('split_quote_line: l_call_lock_exist: '|| l_call_lock_exist);
   END IF;

   IF l_call_lock_exist = fnd_api.g_true THEN

       aso_conc_req_int.lock_exists( p_quote_header_id  =>  l_quote_header_id,
                                     x_status           =>  l_x_status );

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('split_quote_line: l_x_status: '|| l_x_status);
       END IF;

       if l_x_status = fnd_api.g_true then

           if fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) then
               fnd_message.set_name('ASO', 'ASO_CONC_REQUEST_RUNNING');
               fnd_msg_pub.add;
           end if;

           x_return_status := fnd_api.g_ret_sts_error;
           raise fnd_api.g_exc_error;

       end if;

   END IF;

   IF p_original_qte_line_rec.quote_line_id is null OR
	 p_original_qte_line_rec.quote_line_id = FND_API.G_MISS_NUM THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('Split_Quote_line: p_original_qte_line_rec.quote_line_id is null or G_MISS_NUM');
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN

             FND_MESSAGE.Set_Name ('ASO',    'ASO_API_INVALID_ID');
             FND_MESSAGE.Set_Token('COLUMN', 'quote_line_id', FALSE);
             FND_MESSAGE.Set_Token('VALUE',   p_original_qte_line_rec.quote_line_id,  FALSE);
             FND_MSG_PUB.ADD;

        END IF;

   	RAISE FND_API.G_EXC_ERROR;

   ELSIF p_qte_line_tbl.count = 0  THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Split_Quote_line: p_qte_line_tbl.count: '|| p_qte_line_tbl.count);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN

		   FND_MESSAGE.Set_Name ('ASO',     'ASO_ERR_NO_REC');
		   FND_MESSAGE.Set_Token('TBLNAME', 'p_qte_line_tbl', FALSE);
		   FND_MSG_PUB.ADD;

	   END IF;

   	   RAISE FND_API.G_EXC_ERROR;

   ELSIF p_qte_line_tbl.count = 1 AND p_qte_line_tbl(1).quantity <= 0 THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Split_Quote_line: Only one record in p_qte_line_tbl with zero line quantity');
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

             FND_MESSAGE.Set_Name ('ASO',     'ASO_ERR_SPLITLINE_QTY');
             FND_MESSAGE.Set_Token('TBLNAME', 'p_qte_line_tbl',            FALSE);
             FND_MESSAGE.Set_Token('VALUE',    p_qte_line_tbl(1).quantity, FALSE);
             FND_MSG_PUB.ADD;

        END IF;

   	RAISE FND_API.G_EXC_ERROR;

   ELSE

        l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_original_qte_line_rec.quote_line_id);

        IF l_qte_line_rec.line_category_code = 'RETURN' THEN

            l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_rec.quote_line_id);

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Split_Quote_Line: l_qte_line_dtl_tbl.count: '||l_qte_line_dtl_tbl.count);
            END IF;

            IF l_qte_line_dtl_tbl.count > 0 AND
               l_qte_line_dtl_tbl(1).return_ref_type = 'SALES ORDER' AND
               l_qte_line_dtl_tbl(1).return_ref_line_id is not null  AND
               l_qte_line_dtl_tbl(1).instance_id is not null THEN

                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Quote line created from install base having line_category_code = RETURN and refer to an order, can not be spilted.');
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN

                     FND_MESSAGE.Set_Name('ASO', 'ASO_API_CANNOT_SPLIT');
		           FND_MSG_PUB.ADD;

	           END IF;

                RAISE FND_API.G_EXC_ERROR;

            END IF;

        END IF;

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Split_Quote_line: After querying quote line row');
        END IF;

        IF l_qte_line_rec.item_type_code = 'CFG' THEN

             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Split_Quote_line: Quote line item type code is CFG split of this line is not allowed', 1, 'N');
             END IF;

             x_return_status := FND_API.G_RET_STS_ERROR;

             IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN

                  FND_MESSAGE.Set_Name('ASO', 'ASO_API_CANNOT_SPLIT');
                  FND_MSG_PUB.ADD;

             END IF;

             RAISE FND_API.G_EXC_ERROR;

        ELSIF l_qte_line_rec.item_type_code = 'MDL' THEN

             OPEN c_config_exist;
             FETCH c_config_exist INTO l_config_header_id;

             IF c_config_exist%FOUND AND l_config_header_id is not null THEN

                 CLOSE c_config_exist;

                 --Calling the split_model_line API in Copy_Quote

                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('Calling the Split Model Line API in Copy Quote',1,'N');
                 END IF;

                 aso_copy_quote_pvt.split_model_line (
                        p_api_version_number     =>  p_api_version_number,
                        p_init_msg_list          =>  fnd_api.g_false,
                        p_commit                 =>  fnd_api.g_false,
                        p_control_rec            =>  p_control_rec,
                        p_qte_header_rec         =>  p_qte_header_rec,
                        p_original_qte_line_rec  =>  l_qte_line_rec,
                        p_qte_line_tbl           =>  p_qte_line_tbl,
                        x_quote_line_tbl         =>  lx_qte_line_tbl,
                        x_return_status          =>  x_return_status,
                        x_msg_count              =>  x_msg_count,
                        x_msg_data               =>  x_msg_data );

                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('After call to the Split Model Line API in Copy Quote',1,'N');
                   aso_debug_pub.add('Split_Quote_line: x_return_status: '|| x_return_status );
                 END IF;

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                      x_return_status := FND_API.G_RET_STS_ERROR;
                      RAISE FND_API.G_EXC_ERROR;

                 END IF;

			  l_split_model_line := FND_API.G_TRUE;

             ELSE

                 CLOSE c_config_exist;

                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('Split_Quote_line: Model item but not configured');
                 END IF;

                 l_call_do_split_line := FND_API.G_TRUE;

             END IF;

        END IF;


        IF l_qte_line_rec.service_item_flag  =  'Y' THEN

             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Split_Quote_line: Split of service item line is not allowed');
             END IF;

             x_return_status := FND_API.G_RET_STS_ERROR;

             IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN

                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_CANNOT_SPLIT');
                 FND_MSG_PUB.ADD;

             END IF;

             RAISE FND_API.G_EXC_ERROR;

        ELSIF l_qte_line_rec.serviceable_product_flag  =  'Y' THEN

             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Split_Quote_line: Serviceable item line');
             END IF;

             l_serviceable_item   := FND_API.G_TRUE;
             l_call_do_split_line := FND_API.G_TRUE;

        ELSE

             l_call_do_split_line  := FND_API.G_TRUE;

        END IF;


        IF l_call_do_split_line = FND_API.G_TRUE AND l_split_model_line = FND_API.G_FALSE THEN

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Split_Quote_line: Before call to Do_Split_line');
            END IF;

            Do_Split_line( p_qte_header_rec         => p_qte_header_rec,
                           p_control_rec            => p_control_rec,
                           p_original_qte_line_rec  => l_qte_line_rec,
                           p_serviceable_item       => l_serviceable_item,
                           p_qte_line_tbl           => p_qte_line_tbl,
                           p_ln_shipment_tbl        => p_ln_shipment_tbl,
                           p_commit                 => fnd_api.g_false,
                           x_qte_line_tbl           => lx_qte_line_tbl,
                           x_return_status          => x_return_status,
                           x_msg_count              => x_msg_count,
                           x_msg_data               => x_msg_data
                         );

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Split_Quote_line: After call to Do_Split_line');
              aso_debug_pub.add('Split_Quote_line: After call to Do_Split_line: x_return_status: '|| x_return_status);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('Split_Quote_Line: Error in Do_Split_Line');
                 END IF;

                 IF x_return_status = FND_API.G_RET_STS_ERROR THEN

                       RAISE FND_API.G_EXC_ERROR;

                 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                 END IF;

            END IF;

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Split_Quote_line: l_qte_line_rec.quote_line_id: '|| l_qte_line_rec.quote_line_id);
            END IF;

        ELSE

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Split_Quote_line: No call to Do_Split_line', 1, 'N');
            END IF;

        END IF;

   END IF;

   X_Qte_Line_Tbl  := lx_Qte_Line_Tbl;

   --Standard check for p_commit

   IF FND_API.to_Boolean( p_commit ) THEN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Split_Quote_line: Commiting work.', 1, 'N');
        END IF;
        COMMIT;

   END IF;

   --Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get( p_count   =>   x_msg_count,
                              p_data    =>   x_msg_data  );

   EXCEPTION

          WHEN FND_API.G_EXC_ERROR THEN

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Split_Quote_line: WHEN FND_API.G_EXC_ERROR', 1, 'N');
               END IF;

               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                                  P_PKG_NAME        => G_PKG_NAME,
                                                  P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                                  P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                                  X_MSG_COUNT       => X_MSG_COUNT,
                                                  X_MSG_DATA        => X_MSG_DATA,
                                                  X_RETURN_STATUS   => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Split_Quote_line: WHEN FND_API.G_EXC_UNEXPECTED_ERROR', 1, 'N');
               END IF;

               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                                  P_PKG_NAME        => G_PKG_NAME,
                                                  P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                                  P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                                  X_MSG_COUNT       => X_MSG_COUNT,
                                                  X_MSG_DATA        => X_MSG_DATA,
                                                  X_RETURN_STATUS   => X_RETURN_STATUS);


          WHEN OTHERS THEN

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Split_Quote_line: WHEN OTHERS', 1, 'N');
               END IF;

               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                                  P_PKG_NAME        => G_PKG_NAME,
                                                  P_SQLERRM         => SQLERRM,
                                                  P_SQLCODE         => SQLCODE,
                                                  P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                                                  P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                                  X_MSG_COUNT       => X_MSG_COUNT,
                                                  X_MSG_DATA        => X_MSG_DATA,
                                                  X_RETURN_STATUS   => X_RETURN_STATUS);

End Split_Quote_line;


PROCEDURE Do_Split_line (
    p_qte_header_rec           IN            ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_control_rec              IN            aso_quote_pub.control_rec_type,
    p_original_qte_line_rec    IN            ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_serviceable_item         IN            VARCHAR2  :=  FND_API.G_FALSE,
    P_Qte_Line_Tbl	           IN            ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    P_ln_Shipment_Tbl          IN            ASO_QUOTE_PUB.Shipment_Tbl_Type,
    p_commit                   IN            VARCHAR2,
    X_Qte_Line_Tbl             OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    )
IS

cursor get_service_lines (p_service_ref_line_id number) is
select quote_line_id from aso_quote_line_details
where  service_ref_line_id   = p_service_ref_line_id
and    service_ref_type_code = 'QUOTE';


--l_control_rec                  ASO_QUOTE_PUB.Control_Rec_Type;
--l_qte_header_rec               ASO_QUOTE_PUB.Qte_Header_Rec_Type   := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
l_qte_line_rec                 ASO_QUOTE_PUB.Qte_Line_Rec_Type     := p_original_qte_line_rec;
l_srv_qte_line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_qte_line_tbl                 ASO_QUOTE_PUB.Qte_Line_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
l_map_qte_line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;

l_ln_shipment_rec              ASO_QUOTE_PUB.Shipment_Rec_Type     := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;
l_ln_Shipment_Tbl              ASO_QUOTE_PUB.Shipment_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;
l_srv_ln_Shipment_Tbl          ASO_QUOTE_PUB.Shipment_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;
l_qte_line_dtl_tbl             ASO_QUOTE_PUB.qte_line_dtl_tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
l_srv_qte_line_dtl_tbl         ASO_QUOTE_PUB.qte_line_dtl_tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
l_qte_line_dtl_rec             ASO_QUOTE_PUB.qte_line_dtl_rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_REC;
l_payment_tbl                  ASO_QUOTE_PUB.payment_tbl_Type      := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
l_srv_payment_tbl              ASO_QUOTE_PUB.payment_tbl_Type      := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
l_payment_rec                  ASO_QUOTE_PUB.payment_rec_Type      := ASO_QUOTE_PUB.G_MISS_PAYMENT_REC;
l_sales_credit_tbl             ASO_QUOTE_PUB.sales_credit_tbl_Type := ASO_QUOTE_PUB.G_MISS_SALES_CREDIT_TBL;
l_srv_sales_credit_tbl         ASO_QUOTE_PUB.sales_credit_tbl_Type := ASO_QUOTE_PUB.G_MISS_SALES_CREDIT_TBL;
l_sales_credit_rec             ASO_QUOTE_PUB.sales_credit_rec_Type := ASO_QUOTE_PUB.G_MISS_SALES_CREDIT_REC;
l_price_attr_tbl               ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
									  := ASO_QUOTE_PUB.G_MISS_PRICE_ATTRIBUTES_TBL;
l_srv_price_attr_tbl           ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
									  := ASO_QUOTE_PUB.G_MISS_PRICE_ATTRIBUTES_TBL;
l_price_attr_rec               ASO_QUOTE_PUB.Price_Attributes_Rec_Type
									  := ASO_QUOTE_PUB.G_MISS_PRICE_ATTRIBUTES_REC;
l_price_adj_tbl                ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_TBL;
l_srv_price_adj_tbl            ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_TBL;
l_price_adj_rec                ASO_QUOTE_PUB.Price_Adj_Rec_Type := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_REC;

l_price_adj_rltship_tbl        ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_TBL;
l_srv_price_adj_rltship_tbl    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_TBL;
l_price_adj_rltship_rec        ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_REC;

l_price_adj_attr_tbl           ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type    := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_ATTR_TBL;
l_srv_price_adj_attr_tbl       ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type    := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_ATTR_TBL;
l_price_adj_attr_rec           ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Rec_Type    := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_ATTR_REC;

l_to_create_sales_credit_tbl   ASO_QUOTE_PUB.sales_credit_tbl_Type := ASO_QUOTE_PUB.G_MISS_SALES_CREDIT_TBL;
l_to_create_payment_tbl        ASO_QUOTE_PUB.Payment_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
l_to_create_quote_line_tbl     ASO_QUOTE_PUB.Qte_Line_Tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
l_to_create_quote_line_rec     ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
l_to_create_shipment_tbl       ASO_QUOTE_PUB.Shipment_Tbl_Type := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;
l_to_create_shipment_rec       ASO_QUOTE_PUB.Shipment_Rec_Type := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;
l_to_create_qte_line_dtl_tbl   ASO_QUOTE_PUB.qte_line_dtl_tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
l_to_create_price_attr_tbl     ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
									  := ASO_QUOTE_PUB.G_MISS_PRICE_ATTRIBUTES_TBL;
l_to_create_price_adj_tbl      ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_TBL;
l_create_price_adj_rltn_tbl    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_TBL;
l_create_price_adj_attr_tbl    ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Tbl_Type    := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_ATTR_TBL;

l_search_index                 search_tbl_type;

l_ln_quantity_before_spilt     NUMBER;

-- Output parameters
lx_qte_header_rec            ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_qte_line_tbl              ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
lx_qte_line_dtl_tbl          ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
lx_hd_price_attr_tbl         ASO_QUOTE_PUB.Price_Attributes_tbl_Type;
lx_hd_payment_tbl            ASO_QUOTE_PUB.payment_tbl_type;
lx_hd_shipment_tbl           ASO_QUOTE_PUB.shipment_tbl_type;
lx_hd_freight_charge_tbl     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_hd_tax_detail_tbl         ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
lx_line_attr_ext_tbl         ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_line_rltship_tbl          ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
lx_price_adjustment_tbl      ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lx_price_adj_attr_tbl        ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_type;
lx_price_adj_rltship_tbl     ASO_QUOTE_PUB.Price_Adj_rltship_Tbl_Type;
lx_ln_price_attr_tbl         ASO_QUOTE_PUB.Price_Attributes_Tbl_type;
lx_ln_payment_tbl            ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_ln_shipment_tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_ln_freight_charge_tbl     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_ln_tax_detail_tbl         ASO_QUOTE_PUB.Tax_Detail_Tbl_type;
lx_ln_sales_credit_tbl       ASO_QUOTE_PUB.sales_credit_tbl_Type;
lx_hd_sales_credit_tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lx_hd_Attr_Ext_Tbl           ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_hd_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lx_Ln_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;

l_srv_line_index             NUMBER        :=  P_Qte_Line_Tbl.count + 1;
l_line_count                 NUMBER        :=  P_Qte_Line_Tbl.count + 1;
l_api_name       CONSTANT    VARCHAR2(30)  :=  'Do_Split_line';

l_line_index_link_tbl        ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type;
l_control_rec                ASO_QUOTE_PUB.Control_Rec_Type;
l_orig_payment_tbl           ASO_QUOTE_PUB.payment_tbl_Type      := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
l_orig_line_deleted          varchar2(1) := 'N';

Begin

    --Standard Start of API savepoint
    SAVEPOINT DO_SPLIT_LINE_INT;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_SPLIT_LINE_INT: Begin Do_Split_Line procedure', 1, 'Y');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    /*
    l_qte_header_rec := aso_utility_pvt.query_header_row(l_qte_line_rec.quote_header_id);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Do_Split_Line: After querying quote header row', 1, 'N');
    END IF;
    */

    l_ln_quantity_before_spilt := l_qte_line_rec.quantity;
    l_ln_Shipment_Tbl          := aso_utility_pvt.Query_Shipment_Rows(l_qte_line_rec.quote_header_id,
														l_qte_line_rec.quote_line_id);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Do_Split_Line: After querying shipment rows', 1, 'N');
    END IF;

    l_qte_line_dtl_tbl := aso_utility_pvt.query_line_dtl_rows(l_qte_line_rec.quote_line_id);
    /* l_payment_tbl      := aso_utility_pvt.query_payment_rows(l_qte_line_rec.quote_header_id,
												 l_qte_line_rec.quote_line_id); */
    l_sales_credit_tbl := aso_utility_pvt.query_sales_credit_row(l_qte_line_rec.quote_header_id,
													l_qte_line_rec.quote_line_id);
    l_price_attr_tbl   := aso_utility_pvt.query_price_attr_rows(l_qte_line_rec.quote_header_id,
												    l_qte_line_rec.quote_line_id);
    l_price_adj_tbl    := aso_utility_pvt.query_price_adj_nonPRG_rows(l_qte_line_rec.quote_header_id,
												   l_qte_line_rec.quote_line_id);
    l_price_adj_rltship_tbl := aso_utility_pvt.Query_Price_Adj_Rltn_Rows(l_qte_line_rec.quote_line_id);
    l_price_adj_attr_tbl    := aso_utility_pvt.Query_Price_Adj_Attr_Rows(l_price_adj_tbl);

    FOR i IN 1 .. P_Qte_Line_Tbl.count LOOP

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Do_Split_Line: Inside quote line loop', 1, 'N');
        END IF;

        IF (p_qte_line_tbl(i).quantity <= 0) OR (p_qte_line_tbl(i).quantity > l_qte_line_rec.quantity) THEN

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: Line quantity is <= 0 OR New quote line to be created qty > original line quantity', 1, 'N');
           END IF;

           x_return_status := FND_API.G_RET_STS_ERROR;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_SPLITLINE_QTY');
                FND_MSG_PUB.ADD;
           END IF;

           RAISE FND_API.G_EXC_ERROR;

        ELSE

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: Inside quote line loop Line quantity Else condition', 1, 'N');
           END IF;

           l_to_create_quote_line_rec                :=  l_qte_line_rec;
           l_to_create_quote_line_rec.quantity       :=  p_qte_line_tbl(i).quantity;
           l_to_create_quote_line_rec.operation_code :=  'CREATE';
           l_to_create_quote_line_rec.quote_line_id  :=  FND_API.G_MISS_NUM;
           l_to_create_quote_line_rec.line_number    :=  FND_API.G_MISS_NUM;
           l_to_create_quote_line_tbl(i)             :=  l_to_create_quote_line_rec;
           l_qte_line_rec.quantity                   :=  l_qte_line_rec.quantity - p_qte_line_tbl(i).quantity;
		 l_map_qte_line_tbl(i).quote_line_id     :=  l_qte_line_rec.quote_line_id;

           --Populate Shipment records

           l_to_create_shipment_rec                  :=  l_ln_Shipment_Tbl(1);
           l_to_create_shipment_rec.operation_code   :=  'CREATE';
           l_to_create_shipment_rec.shipment_id      :=  FND_API.G_MISS_NUM;
           l_to_create_shipment_rec.quote_line_id    :=  FND_API.G_MISS_NUM;
           l_to_create_shipment_rec.qte_line_index   :=  i;
           l_to_create_shipment_rec.quantity         :=  l_to_create_quote_line_rec.quantity;


           --Loop thru the input shipment table to check If the user has passed a input
           --shipment rec for this line.

           --If shipment line exist for the current quote line then check for the value
           --of ship_to_cust_account_id,
           --ship_to_party_site_id, ship_to_party_id, ship_method_code and shipping_instructions
           --and override with the input value (If exist).

           FOR j IN 1 .. P_ln_Shipment_Tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside shipment loop', 1, 'N');
               END IF;

               IF P_ln_Shipment_Tbl(j).qte_line_index = i THEN

                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('Do_Split_Line: Inside shipment loop, shipment record exist for given line ');
                   END IF;

                   IF P_ln_Shipment_Tbl(j).ship_to_cust_account_id <> FND_API.G_MISS_NUM THEN

                       l_to_create_shipment_rec.ship_to_cust_account_id := P_ln_Shipment_Tbl(j).ship_to_cust_account_id;
                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('Do_Split_Line: l_to_create_shipment_rec.ship_to_cust_account_id :'||l_to_create_shipment_rec.ship_to_cust_account_id);
                       END IF;

                   END IF;


                   IF P_ln_Shipment_Tbl(j).ship_to_party_site_id <> FND_API.G_MISS_NUM THEN

                       l_to_create_shipment_rec.ship_to_party_site_id := P_ln_Shipment_Tbl(j).ship_to_party_site_id;
                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('Do_Split_Line: l_to_create_shipment_rec.ship_to_party_site_id :'||l_to_create_shipment_rec.ship_to_party_site_id);
                       END IF;

                   END IF;


                   IF P_ln_Shipment_Tbl(j).ship_to_party_id <> FND_API.G_MISS_NUM THEN

                       l_to_create_shipment_rec.ship_to_party_id := P_ln_Shipment_Tbl(j).ship_to_party_id;

                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('Do_Split_Line: l_to_create_shipment_rec.ship_to_party_id :'||l_to_create_shipment_rec.ship_to_party_id);
                       END IF;

                   END IF;


                   IF P_ln_Shipment_Tbl(j).ship_method_code <> FND_API.G_MISS_CHAR THEN

                       l_to_create_shipment_rec.ship_method_code := P_ln_Shipment_Tbl(j).ship_method_code;
                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('Do_Split_Line: l_to_create_shipment_rec.ship_method_code :'||l_to_create_shipment_rec.ship_method_code);
                       END IF;

                   END IF;


                   IF P_ln_Shipment_Tbl(j).shipping_instructions <> FND_API.G_MISS_CHAR THEN

                       l_to_create_shipment_rec.shipping_instructions := P_ln_Shipment_Tbl(j).shipping_instructions;
                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('Do_Split_Line: l_to_create_shipment_rec.shipping_instructions :'||l_to_create_shipment_rec.shipping_instructions);
                       END IF;

                   END IF;


                   IF P_ln_Shipment_Tbl(j).packing_instructions <> FND_API.G_MISS_CHAR THEN

                       l_to_create_shipment_rec.packing_instructions := P_ln_Shipment_Tbl(j).packing_instructions;
                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('Do_Split_Line: l_to_create_shipment_rec.packing_instructions :'||l_to_create_shipment_rec.packing_instructions);
                       END IF;

                   END IF;

               END IF;

           END LOOP;

           l_to_create_shipment_tbl(nvl(l_to_create_shipment_tbl.count,0)+1) := l_to_create_shipment_rec;


           --Populate quote line details records

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: l_qte_line_dtl_tbl.count :'||l_qte_line_dtl_tbl.count, 1, 'N');
           END IF;

           FOR k IN 1 .. l_qte_line_dtl_tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside l_qte_line_dtl_tbl loop', 1, 'N');
               END IF;

               l_qte_line_dtl_rec                            :=  l_qte_line_dtl_tbl(k);
               l_qte_line_dtl_rec.operation_code             :=  'CREATE';
               l_qte_line_dtl_rec.quote_line_detail_id       :=  FND_API.G_MISS_NUM;
               l_qte_line_dtl_rec.quote_line_id              :=  FND_API.G_MISS_NUM;
               l_qte_line_dtl_rec.qte_line_index             :=  i;
               l_qte_line_dtl_rec.service_ref_qte_line_index :=  FND_API.G_MISS_NUM;
               l_qte_line_dtl_rec.service_ref_line_id        :=  FND_API.G_MISS_NUM;

               l_to_create_qte_line_dtl_tbl(nvl(l_to_create_qte_line_dtl_tbl.count,0)+1) := l_qte_line_dtl_rec;
           END LOOP;

           --Populate payment records
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: l_payment_tbl.count :'||l_payment_tbl.count, 1, 'N');
           END IF;

           /* FOR k IN 1 .. l_payment_tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside l_payment_tbl loop', 1, 'N');
               END IF;

               l_payment_rec                           :=  l_payment_tbl(k);
               l_payment_rec.operation_code            :=  'CREATE';
               l_payment_rec.payment_id                :=  FND_API.G_MISS_NUM;
               l_payment_rec.quote_line_id             :=  FND_API.G_MISS_NUM;
               l_payment_rec.quote_shipment_id         :=  FND_API.G_MISS_NUM;
               l_payment_rec.qte_line_index            :=  i;
               l_payment_rec.credit_card_approval_code :=  FND_API.G_MISS_CHAR;
               l_payment_rec.credit_card_approval_date :=  FND_API.G_MISS_DATE;

               l_to_create_payment_tbl(nvl(l_to_create_payment_tbl.count,0)+1) := l_payment_rec;

           END LOOP; */

           --Populate sales credit records

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: l_sales_credit_tbl.count :'||l_sales_credit_tbl.count, 1, 'N');
           END IF;

           FOR k IN 1 .. l_sales_credit_tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside l_sales_credit_tbl', 1, 'N');
               END IF;

               l_sales_credit_rec                 :=  l_sales_credit_tbl(k);
               l_sales_credit_rec.operation_code  :=  'CREATE';
               l_sales_credit_rec.sales_credit_id :=  FND_API.G_MISS_NUM;
               l_sales_credit_rec.quote_line_id   :=  FND_API.G_MISS_NUM;
               l_sales_credit_rec.qte_line_index  :=  i;

               l_to_create_sales_credit_tbl(nvl(l_to_create_sales_credit_tbl.count,0)+1) := l_sales_credit_rec;
           END LOOP;

           --Populate price attributes records

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: l_price_attr_tbl.count :'||l_price_attr_tbl.count, 1, 'N');
           END IF;

           FOR k IN 1 .. l_price_attr_tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside l_price_attr_tbl loop', 1, 'N');
               END IF;

               l_price_attr_rec                    :=  l_price_attr_tbl(k);
               l_price_attr_rec.operation_code     :=  'CREATE';
               l_price_attr_rec.price_attribute_id :=  FND_API.G_MISS_NUM;
               l_price_attr_rec.quote_line_id      :=  FND_API.G_MISS_NUM;
               l_price_attr_rec.qte_line_index     :=  i;

               l_to_create_price_attr_tbl(nvl(l_to_create_price_attr_tbl.count,0)+1) := l_price_attr_rec;

           END LOOP;

           --Populate price adjustments records
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: l_price_adj_tbl.count :'||l_price_adj_tbl.count, 1, 'N');
           END IF;

           FOR k IN 1 .. l_price_adj_tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Do_Split_Line: Inside l_price_adj_tbl loop', 1, 'N');
                  aso_debug_pub.add('l_price_adj_tbl(k).modifier_line_type_code :'||l_price_adj_tbl(k).modifier_line_type_code, 1, 'N');
               END IF;


               l_price_adj_rec  :=  l_price_adj_tbl(k);


			l_search_index(l_price_adj_rec.price_adjustment_id) := nvl(l_to_create_price_adj_tbl.count,0)+1; --k;

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: l_search_index(' || l_price_adj_rec.price_adjustment_id || ')' || l_search_index(l_price_adj_rec.price_adjustment_id));
               END IF;

               l_price_adj_rec.operation_code      :=  'CREATE';
               l_price_adj_rec.price_adjustment_id :=  FND_API.G_MISS_NUM;
               l_price_adj_rec.creation_date       :=  FND_API.G_MISS_DATE;
               l_price_adj_rec.quote_line_id       :=  FND_API.G_MISS_NUM;
               l_price_adj_rec.quote_shipment_id   :=  FND_API.G_MISS_NUM;
               l_price_adj_rec.qte_line_index      :=  i;
               l_price_adj_rec.shipment_index      :=  FND_API.G_MISS_NUM;

               l_to_create_price_adj_tbl(nvl(l_to_create_price_adj_tbl.count,0)+1) := l_price_adj_rec;


           END LOOP;

           FOR k IN 1 .. l_price_adj_rltship_tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside l_price_adj_rltship_tbl loop', 1, 'N');
               END IF;

               l_price_adj_rltship_rec  :=  l_price_adj_rltship_tbl(k);

               IF l_search_index.exists(l_price_adj_rltship_rec.price_adjustment_id) THEN

                   IF l_search_index.exists(l_price_adj_rltship_rec.rltd_price_adj_id) THEN

			       l_price_adj_rltship_rec.price_adj_index      := l_search_index(l_price_adj_rltship_rec.price_adjustment_id);
			       l_price_adj_rltship_rec.rltd_price_adj_index := l_search_index(l_price_adj_rltship_rec.rltd_price_adj_id);

                      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('l_price_adj_rltship_rec.price_adj_index :'||l_price_adj_rltship_rec.price_adj_index, 1, 'N');
                         aso_debug_pub.add('l_price_adj_rltship_rec.rltd_price_adj_index :'||l_price_adj_rltship_rec.rltd_price_adj_index, 1, 'N');
                      END IF;

	       		  l_price_adj_rltship_rec.operation_code      :=  'CREATE';
			       l_price_adj_rltship_rec.adj_relationship_id :=  fnd_api.g_miss_num;
			       l_price_adj_rltship_rec.creation_date       :=  fnd_api.g_miss_date;
			       l_price_adj_rltship_rec.quote_line_id       :=  fnd_api.g_miss_num;
			       l_price_adj_rltship_rec.qte_line_index      :=  i;
			       l_price_adj_rltship_rec.quote_shipment_id   :=  fnd_api.g_miss_num;
			       l_price_adj_rltship_rec.price_adjustment_id :=  fnd_api.g_miss_num;
			       l_price_adj_rltship_rec.rltd_price_adj_id   :=  fnd_api.g_miss_num;

                      l_create_price_adj_rltn_tbl(nvl(l_create_price_adj_rltn_tbl.count,0)+1) := l_price_adj_rltship_rec;

                   END IF;

               END IF;

           END LOOP;


           FOR k IN 1 .. l_price_adj_attr_tbl.count LOOP

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside l_price_adj_attr_tbl loop', 1, 'N');
               END IF;

               l_price_adj_attr_rec  :=  l_price_adj_attr_tbl(k);

               IF l_search_index.exists(l_price_adj_attr_rec.price_adjustment_id) THEN
                  l_price_adj_attr_rec.price_adj_index := l_search_index(l_price_adj_attr_rec.price_adjustment_id);
               END IF;

               l_price_adj_attr_rec.operation_code      :=  'CREATE';
               l_price_adj_attr_rec.price_adj_attrib_id :=  fnd_api.g_miss_num;
               l_price_adj_attr_rec.creation_date       :=  fnd_api.g_miss_date;
               l_price_adj_attr_rec.qte_line_index      :=  i;
               l_price_adj_attr_rec.price_adjustment_id :=  fnd_api.g_miss_num;

               l_create_price_adj_attr_tbl(nvl(l_create_price_adj_attr_tbl.count,0)+1) := l_price_adj_attr_rec;

           END LOOP;

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: l_srv_line_index: '|| l_srv_line_index, 1, 'N');
             aso_debug_pub.add('Do_Split_Line: l_line_count:     '|| l_line_count, 1, 'N');
           END IF;

           IF l_srv_line_index <> l_line_count THEN

               l_srv_line_index := l_to_create_quote_line_tbl.LAST + 1;

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Inside IF l_srv_line_index <> l_line_count Condition. l_srv_line_index: '||l_srv_line_index, 1, 'N');
               END IF;

           END IF;

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: p_serviceable_item: '||p_serviceable_item, 1, 'N');
           END IF;

           IF p_serviceable_item = FND_API.G_TRUE THEN

              FOR row IN get_service_lines(l_qte_line_rec.quote_line_id) LOOP

                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Do_Split_Line: Inside service items quote line loop', 1, 'N');
                END IF;

                l_srv_qte_line_rec     := ASO_UTILITY_PVT.Query_Qte_Line_Row(row.quote_line_id);

                l_srv_ln_Shipment_Tbl  := ASO_UTILITY_PVT.Query_Shipment_Rows( l_srv_qte_line_rec.quote_header_id, row.quote_line_id);

                l_srv_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(row.quote_line_id);

                l_srv_payment_tbl      := ASO_UTILITY_PVT.Query_Payment_Rows( l_srv_qte_line_rec.quote_header_id, row.quote_line_id);

                l_srv_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row( l_srv_qte_line_rec.quote_header_id, row.quote_line_id);

                l_srv_price_attr_tbl   := ASO_UTILITY_PVT.Query_Price_Attr_Rows( l_srv_qte_line_rec.quote_header_id, row.quote_line_id);

                l_srv_price_adj_tbl    := ASO_UTILITY_PVT.Query_Price_Adj_nonPRG_Rows( l_srv_qte_line_rec.quote_header_id, row.quote_line_id);
                l_srv_price_adj_rltship_tbl := aso_utility_pvt.Query_Price_Adj_Rltn_Rows(row.quote_line_id);
                l_srv_price_adj_attr_tbl    := aso_utility_pvt.Query_Price_Adj_Attr_Rows(l_srv_price_adj_tbl);

                l_to_create_quote_line_rec                :=  l_srv_qte_line_rec;
                l_to_create_quote_line_rec.quantity       :=  p_qte_line_tbl(i).quantity;
                l_to_create_quote_line_rec.operation_code :=  'CREATE';
                l_to_create_quote_line_rec.quote_line_id  :=  FND_API.G_MISS_NUM;
                l_to_create_quote_line_rec.line_number    :=  FND_API.G_MISS_NUM;

                IF l_srv_line_index <> l_line_count THEN

                    l_to_create_quote_line_tbl(l_to_create_quote_line_tbl.LAST + 1) := l_to_create_quote_line_rec;
                    l_map_qte_line_tbl(l_map_qte_line_tbl.last + 1).quote_line_id   := l_srv_qte_line_rec.quote_line_id;
                ELSE
                    l_to_create_quote_line_tbl(l_srv_line_index)       := l_to_create_quote_line_rec;
                    l_map_qte_line_tbl(l_srv_line_index).quote_line_id := l_srv_qte_line_rec.quote_line_id;

                END IF;

                --Populate Service Shipment records

                l_to_create_shipment_rec                :=  l_srv_ln_Shipment_Tbl(1);
                l_to_create_shipment_rec.operation_code :=  'CREATE';
                l_to_create_shipment_rec.shipment_id    :=  FND_API.G_MISS_NUM;
                l_to_create_shipment_rec.quote_line_id  :=  FND_API.G_MISS_NUM;
                l_to_create_shipment_rec.qte_line_index :=  l_srv_line_index;
                l_to_create_shipment_rec.quantity       :=  p_qte_line_tbl(i).quantity;

                l_to_create_shipment_tbl(nvl(l_to_create_shipment_tbl.count,0)+1) := l_to_create_shipment_rec;

                --Populate service quote line details records
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Do_Split_Line: l_srv_qte_line_dtl_tbl.count :'||l_srv_qte_line_dtl_tbl.count, 1, 'N');
                END IF;
                FOR k IN 1 .. l_srv_qte_line_dtl_tbl.count LOOP

                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('Do_Split_Line: Inside l_srv_qte_line_dtl_tbl loop', 1, 'N');
                    END IF;

                    l_qte_line_dtl_rec                            :=  l_srv_qte_line_dtl_tbl(k);
                    l_qte_line_dtl_rec.operation_code             :=  'CREATE';
                    l_qte_line_dtl_rec.quote_line_detail_id       :=  FND_API.G_MISS_NUM;
                    l_qte_line_dtl_rec.quote_line_id              :=  FND_API.G_MISS_NUM;
                    l_qte_line_dtl_rec.qte_line_index             :=  l_srv_line_index;
                    l_qte_line_dtl_rec.service_ref_qte_line_index :=  i;
                    l_qte_line_dtl_rec.service_ref_line_id        :=  FND_API.G_MISS_NUM;

                    l_to_create_qte_line_dtl_tbl(nvl(l_to_create_qte_line_dtl_tbl.count,0)+1) := l_qte_line_dtl_rec;
                END LOOP;

                --Populate Service payment records
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Do_Split_Line: l_srv_payment_tbl.count :'||l_srv_payment_tbl.count, 1, 'N');
                END IF;
                /* FOR k IN 1 .. l_srv_payment_tbl.count LOOP

                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('Do_Split_Line: Inside l_srv_payment_tbl loop', 1, 'N');
                    END IF;

                    l_payment_rec                           :=  l_srv_payment_tbl(k);
                    l_payment_rec.operation_code            :=  'CREATE';
                    l_payment_rec.payment_id                :=  FND_API.G_MISS_NUM;
                    l_payment_rec.quote_line_id             :=  FND_API.G_MISS_NUM;
                    l_payment_rec.quote_shipment_id         :=  FND_API.G_MISS_NUM;
                    l_payment_rec.qte_line_index            :=  l_srv_line_index;
                    l_payment_rec.credit_card_approval_code :=  FND_API.G_MISS_CHAR;
                    l_payment_rec.credit_card_approval_date :=  FND_API.G_MISS_DATE;

                    l_to_create_payment_tbl(nvl(l_to_create_payment_tbl.count,0)+1) := l_payment_rec;

                END LOOP; */

                --Populate service sales credit records
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Do_Split_Line: l_srv_sales_credit_tbl.count :'||l_srv_sales_credit_tbl.count, 1, 'N');
                END IF;

                FOR k IN 1 .. l_srv_sales_credit_tbl.count LOOP

                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('Do_Split_Line: Inside l_srv_sales_credit_tbl', 1, 'N');
                    END IF;

                    l_sales_credit_rec                 :=  l_srv_sales_credit_tbl(k);
                    l_sales_credit_rec.operation_code  :=  'CREATE';
                    l_sales_credit_rec.sales_credit_id :=  FND_API.G_MISS_NUM;
                    l_sales_credit_rec.quote_line_id   :=  FND_API.G_MISS_NUM;
                    l_sales_credit_rec.qte_line_index  :=  l_srv_line_index;

                    l_to_create_sales_credit_tbl(nvl(l_to_create_sales_credit_tbl.count,0)+1) := l_sales_credit_rec;
                END LOOP;

                --Populate Service price attributes records
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Do_Split_Line: l_srv_price_attr_tbl.count :'||l_srv_price_attr_tbl.count, 1, 'N');
                END IF;

                FOR k IN 1 .. l_srv_price_attr_tbl.count LOOP

                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('Do_Split_Line: Inside l_srv_price_attr_tbl loop', 1, 'N');
                    END IF;

                    l_price_attr_rec                    :=  l_srv_price_attr_tbl(k);
                    l_price_attr_rec.operation_code     :=  'CREATE';
                    l_price_attr_rec.price_attribute_id :=  FND_API.G_MISS_NUM;
                    l_price_attr_rec.quote_line_id      :=  FND_API.G_MISS_NUM;
                    l_price_attr_rec.qte_line_index     :=  l_srv_line_index;

                    l_to_create_price_attr_tbl(nvl(l_to_create_price_attr_tbl.count,0)+1) := l_price_attr_rec;
                END LOOP;

                --Populate Service price adjustments records
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Do_Split_Line: l_srv_price_adj_tbl.count :'||l_srv_price_adj_tbl.count, 1, 'N');
                END IF;
                FOR k IN 1 .. l_srv_price_adj_tbl.count LOOP

                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('Do_Split_Line: Inside l_srv_price_adj_tbl loop', 1, 'N');
                    END IF;

                    l_price_adj_rec                     :=  l_srv_price_adj_tbl(k);

                    l_search_index(l_price_adj_rec.price_adjustment_id) := k;

                    l_price_adj_rec.operation_code      :=  'CREATE';
                    l_price_adj_rec.price_adjustment_id :=  FND_API.G_MISS_NUM;
                    l_price_adj_rec.creation_date       :=  FND_API.G_MISS_DATE;
                    l_price_adj_rec.quote_line_id       :=  FND_API.G_MISS_NUM;
                    l_price_adj_rec.quote_shipment_id   :=  FND_API.G_MISS_NUM;
                    l_price_adj_rec.qte_line_index      :=  l_srv_line_index;
                    l_price_adj_rec.shipment_index      :=  FND_API.G_MISS_NUM;

                    l_to_create_price_adj_tbl(nvl(l_to_create_price_adj_tbl.count,0)+1) := l_price_adj_rec;

                END LOOP;


                FOR k IN 1 .. l_srv_price_adj_rltship_tbl.count LOOP

                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('Do_Split_Line: Inside l_srv_price_adj_rltship_tbl loop', 1, 'N');
                    END IF;

                    l_price_adj_rltship_rec  :=  l_srv_price_adj_rltship_tbl(k);

                    IF l_search_index.exists(l_price_adj_rltship_rec.price_adjustment_id) THEN
                       l_price_adj_rltship_rec.price_adj_index := l_search_index(l_price_adj_rltship_rec.price_adjustment_id);
                    END IF;

                    IF l_search_index.exists(l_price_adj_rltship_rec.rltd_price_adj_id) THEN
                       l_price_adj_rltship_rec.rltd_price_adj_index := l_search_index(l_price_adj_rltship_rec.rltd_price_adj_id);
                    END IF;

                    l_price_adj_rltship_rec.operation_code      :=  'CREATE';
                    l_price_adj_rltship_rec.adj_relationship_id :=  fnd_api.g_miss_num;
                    l_price_adj_rltship_rec.creation_date       :=  fnd_api.g_miss_date;
                    l_price_adj_rltship_rec.quote_line_id       :=  fnd_api.g_miss_num;
                    l_price_adj_rltship_rec.qte_line_index      :=  l_srv_line_index;
                    l_price_adj_rltship_rec.quote_shipment_id   :=  fnd_api.g_miss_num;
                    l_price_adj_rltship_rec.price_adjustment_id :=  fnd_api.g_miss_num;
                    l_price_adj_rltship_rec.rltd_price_adj_id   :=  fnd_api.g_miss_num;

                    l_create_price_adj_rltn_tbl(nvl(l_create_price_adj_rltn_tbl.count,0)+1) := l_price_adj_rltship_rec;

                END LOOP;


                FOR k IN 1 .. l_srv_price_adj_attr_tbl.count LOOP

                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('Do_Split_Line: Inside l_srv_price_adj_attr_tbl loop', 1, 'N');
                    END IF;

                    l_price_adj_attr_rec  :=  l_srv_price_adj_attr_tbl(k);

                    IF l_search_index.exists(l_price_adj_attr_rec.price_adjustment_id) THEN
                       l_price_adj_attr_rec.price_adj_index := l_search_index(l_price_adj_attr_rec.price_adjustment_id);
                    END IF;

                    l_price_adj_attr_rec.operation_code      :=  'CREATE';
                    l_price_adj_attr_rec.price_adj_attrib_id :=  fnd_api.g_miss_num;
                    l_price_adj_attr_rec.creation_date       :=  fnd_api.g_miss_date;
                    l_price_adj_attr_rec.qte_line_index      :=  l_srv_line_index;
                    l_price_adj_attr_rec.price_adjustment_id :=  fnd_api.g_miss_num;

                    l_create_price_adj_attr_tbl(nvl(l_create_price_adj_attr_tbl.count,0)+1) := l_price_adj_attr_rec;

                END LOOP;

                l_srv_line_index := l_srv_line_index + 1;

              END LOOP;

           END IF;

        END IF;

    END LOOP;

    IF l_to_create_quote_line_tbl.count > 0 THEN

       IF  l_qte_line_rec.quantity = 0 THEN
           l_qte_line_rec.operation_code := 'DELETE';

           l_orig_payment_tbl := aso_utility_pvt.query_payment_rows(l_qte_line_rec.quote_header_id,
                                                                    l_qte_line_rec.quote_line_id);

           l_orig_line_deleted := 'Y';

	  ELSE
           l_qte_line_rec.operation_code := 'UPDATE';
       END IF;

       l_to_create_quote_line_tbl(l_to_create_quote_line_tbl.LAST + 1) := l_qte_line_rec;

       -- set the defaulting fwk off so that no new records are created by defaulting
       l_control_rec := p_control_rec;

       l_control_rec.DEFAULTING_FLAG := FND_API.G_FALSE;
	  l_control_rec.DEFAULTING_FWK_FLAG := 'N';


       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('Do_Split_Line: Before call to Update Quote', 1, 'Y');
       END IF;

       ASO_QUOTE_PUB.Update_quote(
              P_Api_Version_Number       => 1.0,
              P_Init_Msg_List            => FND_API.G_FALSE,
              P_Commit                   => P_Commit,
              P_Validation_Level         => FND_API.G_VALID_LEVEL_FULL,
              P_Control_Rec              => l_control_rec,
              P_Qte_Header_Rec           => p_qte_header_rec,
              P_hd_Price_Attributes_Tbl  => ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
              P_hd_Payment_Tbl           => ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
              P_hd_Shipment_Tbl          => ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
              P_hd_Freight_Charge_Tbl    => ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
              P_hd_Tax_Detail_Tbl        => ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
              P_hd_Attr_Ext_Tbl          => ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
              P_hd_Sales_Credit_Tbl      => ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
              P_hd_Quote_Party_Tbl       => ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
              P_Qte_Line_Tbl             => l_to_create_quote_line_tbl,
              P_Qte_Line_Dtl_Tbl         => l_to_create_qte_line_dtl_tbl,
              P_Line_Attr_Ext_Tbl        => ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
              P_line_rltship_tbl         => ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl,
              P_Price_Adjustment_Tbl     => l_to_create_price_adj_tbl,
              P_Price_Adj_Attr_Tbl       => l_create_price_adj_attr_tbl,
              P_Price_Adj_Rltship_Tbl    => l_create_price_adj_rltn_tbl,
              P_Ln_Price_Attributes_Tbl  => l_to_create_price_attr_tbl,
              P_Ln_Payment_Tbl           => ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
              P_Ln_Shipment_Tbl          => l_to_create_shipment_tbl,
              P_Ln_Freight_Charge_Tbl    => ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
              P_Ln_Tax_Detail_Tbl        => ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
              P_ln_Sales_Credit_Tbl      => l_to_create_sales_credit_tbl,
              P_ln_Quote_Party_Tbl       => ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
              x_Qte_Header_Rec           => lx_qte_header_rec,
              X_Qte_Line_Tbl             => lx_Qte_Line_Tbl,
              X_Qte_Line_Dtl_Tbl         => lx_Qte_Line_Dtl_Tbl,
              X_Hd_Price_Attributes_Tbl  => lx_hd_price_attr_tbl,
              X_Hd_Payment_Tbl		 => lx_hd_Payment_Tbl,
              X_Hd_Shipment_Tbl		 => lx_hd_Shipment_Tbl,
              X_Hd_Freight_Charge_Tbl    => lx_hd_Freight_Charge_Tbl,
              X_Hd_Tax_Detail_Tbl        => lx_hd_Tax_Detail_Tbl,
              X_hd_Attr_Ext_Tbl          => lx_hd_Attr_Ext_Tbl,
              X_hd_Sales_Credit_Tbl      => lx_hd_sales_credit_tbl,
              X_hd_Quote_Party_Tbl       => lx_hd_Quote_Party_Tbl,
              x_Line_Attr_Ext_Tbl        => lx_Line_Attr_Ext_Tbl,
              X_line_rltship_tbl         => lx_line_rltship_tbl,
              X_Price_Adjustment_Tbl     => lx_Price_Adjustment_Tbl,
              X_Price_Adj_Attr_Tbl       => lx_Price_Adj_Attr_Tbl,
              X_Price_Adj_Rltship_Tbl	 => lx_Price_Adj_Rltship_Tbl,
              X_Ln_Price_Attributes_Tbl  => lx_ln_price_attr_tbl,
              X_Ln_Payment_Tbl           => lx_ln_Payment_Tbl,
              X_Ln_Shipment_Tbl          => lx_ln_Shipment_Tbl,
              X_Ln_Freight_Charge_Tbl    => lx_ln_Freight_Charge_Tbl,
              X_Ln_Tax_Detail_Tbl        => lx_ln_Tax_Detail_Tbl,
              X_Ln_Sales_Credit_Tbl      => lx_ln_sales_credit_tbl,
              X_Ln_Quote_Party_Tbl       => lx_Ln_Quote_Party_Tbl,
              X_Return_Status            => x_Return_Status,
              X_Msg_Count                => x_Msg_Count,
              X_Msg_Data                 => x_Msg_Data
       );

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('Do_Split_Line: After call to Update Quote');
         aso_debug_pub.add('Do_Split_Line: x_Return_Status :'||x_Return_Status, 1, 'N');
       END IF;

       IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Do_Split_Line: Error in Update_Quote', 1, 'N');
           END IF;

  	      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
                   FND_MSG_PUB.ADD;
               END IF;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

           ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_EXP_ERROR');
                   FND_MSG_PUB.ADD;
               END IF;

               RAISE FND_API.G_EXC_ERROR;

           END IF;

       END IF;

       X_Qte_Line_Tbl  := lx_Qte_Line_Tbl;


      -- Copy the header payment record

       IF ( l_orig_line_deleted = 'Y' ) THEN
          l_payment_tbl := l_orig_payment_tbl;
       ELSE
          l_payment_tbl      := aso_utility_pvt.query_payment_rows(l_qte_line_rec.quote_header_id,
                                                             l_qte_line_rec.quote_line_id);
       END IF;

             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Do_Split_Line: l_orig_line_deleted: '|| l_orig_line_deleted);
               aso_debug_pub.add('Do_Split_Line: l_orig_payment_tbl.count: '|| l_orig_payment_tbl.count);
               aso_debug_pub.add('Do_Split_Line: l_payment_tbl.count: '|| l_payment_tbl.count);
             END IF;


       FOR i IN 1 .. lx_Qte_Line_Tbl.count LOOP

             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Do_Split_Line: lx_qte_line_tbl('||i||').quote_line_id: '|| lx_qte_line_tbl(i).quote_line_id);
             END IF;


   If l_orig_line_deleted =  'N' then -- if condition added for Bug 13969184

   -- if original line is deleted then there will be no payment records in IBY tables which will raise error

     --  Start Copy payment record
   IF ((l_qte_line_rec.quote_line_id <> lx_Qte_Line_Tbl(i).quote_line_id) and (l_payment_tbl.count > 0))  then
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Do_Split_Line: Creating the payment record ', 1, 'N');
               END IF;

               l_payment_rec                           :=  l_payment_tbl(1);
               l_payment_rec.payment_id                :=  null;
               l_payment_rec.quote_header_id           := l_qte_line_rec.quote_header_id;
               l_payment_rec.quote_line_id             :=  lx_qte_line_tbl(i).quote_line_id;
               l_payment_rec.credit_card_approval_code :=  FND_API.G_MISS_CHAR;
               l_payment_rec.credit_card_approval_date :=  FND_API.G_MISS_DATE;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Do_Split_Line: Before  call to copy_payment_row ', 1, 'Y');
       END IF;

         aso_copy_quote_pvt.copy_payment_row(p_payment_rec =>  l_payment_rec ,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Copy_Header: After call to copy_payment_row: x_return_status: '||x_return_status, 1, 'Y');
       END IF;
      IF ( x_return_status  = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   End if;

     --  End Copy payment record

   End If;

             IF l_qte_line_rec.quote_line_id <> lx_Qte_Line_Tbl(i).quote_line_id
			 and (lx_Qte_Line_Tbl(i).pricing_line_type_indicator is null or
                     lx_Qte_Line_Tbl(i).pricing_line_type_indicator = fnd_api.g_miss_char) THEN

                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('Do_Split_Line: Before call to Copy_Attachments');
                   END IF;

                   ASO_ATTACHMENT_INT.Copy_Attachments(
                                p_api_version       => 1.0,
                                p_init_msg_list     => FND_API.G_FALSE,
                                p_commit            => FND_API.G_FALSE,
                                p_old_object_code   => 'ASO_QUOTE_LINES_ALL',
                                p_new_object_code   => 'ASO_QUOTE_LINES_ALL',
                                p_old_object_id     => l_map_qte_line_tbl(i).quote_line_id,
                                p_new_object_id     => lx_qte_line_tbl(i).quote_line_id,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data
                               );

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Do_Split_Line: After call to Copy_Attachments');
                     aso_debug_pub.add('Do_Split_Line: x_return_status: '|| x_return_status);
                   END IF;

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                          aso_debug_pub.add('Do_Split_Line: Error in Copy_Attachments');
                        END IF;

                        IF x_return_status = FND_API.G_RET_STS_ERROR THEN

                              RAISE FND_API.G_EXC_ERROR;

                        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                        END IF;

                   END IF;

                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('Do_Split_Line: Attachment copied from quote_line_id: '||l_map_qte_line_tbl(i).quote_line_id);
                       aso_debug_pub.add('Do_Split_Line: Attachment copied to quote_line_id:   '||lx_qte_line_tbl(i).quote_line_id);
                   END IF;


			    -- changes for sales supp enhancement see bug 2940126
                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Do_Split_Line: Before call to Copy_Line_Level_Sales_Supp');
                   END IF;

                                ASO_COPY_QUOTE_PVT.INSERT_SALES_SUPP_DATA
                                  (
                                    P_Api_Version_Number          =>  1.0,
                                    P_Init_Msg_List               => FND_API.G_FALSE,
                                    P_Commit                      => P_Commit,
                                    P_OLD_QUOTE_LINE_ID           => l_map_qte_line_tbl(i).quote_line_id,
                                    P_NEW_QUOTE_LINE_ID           => lx_qte_line_tbl(i).quote_line_id,
                                    X_Return_Status               => x_return_status,
                                    X_Msg_Count                   => X_Msg_Count,
                                    X_Msg_Data                    => X_Msg_Data );

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Do_Split_Line: After call to Copy_Line_Level_Sales_Supp');
                     aso_debug_pub.add('Do_Split_Line: x_return_status: '|| x_return_status);
                   END IF;

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                          aso_debug_pub.add('Do_Split_Line: Error in Copy_Line_Level_Sales_Supp');
                        END IF;

                        IF x_return_status = FND_API.G_RET_STS_ERROR THEN

                              RAISE FND_API.G_EXC_ERROR;

                        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                        END IF;

                   END IF;

             END IF;

       END LOOP;

    ELSE

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('Do_Split_Line: No call made to Update_Quote');
       END IF;

    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count          =>   x_msg_count,
                                p_data           =>   x_msg_data );


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Do_Split_Line: WHEN FND_API.G_EXC_ERROR', 1, 'N');
            END IF;

            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                               P_PKG_NAME        => G_PKG_NAME,
                                               P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                               P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                               X_MSG_COUNT       => X_MSG_COUNT,
                                               X_MSG_DATA        => X_MSG_DATA,
                                               X_RETURN_STATUS   => X_RETURN_STATUS
                                             );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Do_Split_Line: WHEN FND_API.G_EXC_UNEXPECTED_ERROR', 1, 'N');
            END IF;

            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                               P_PKG_NAME        => G_PKG_NAME,
                                               P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                               P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                               X_MSG_COUNT       => X_MSG_COUNT,
                                               X_MSG_DATA        => X_MSG_DATA,
                                               X_RETURN_STATUS   => X_RETURN_STATUS
                                             );

        WHEN OTHERS THEN

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('Do_Split_Line: WHEN OTHERS', 1, 'N');
            END IF;

            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                               P_PKG_NAME        => G_PKG_NAME,
                                               P_SQLERRM         => SQLERRM,
                                               P_SQLCODE         => SQLCODE,
                                               P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                                               P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                               X_MSG_COUNT       => X_MSG_COUNT,
                                               X_MSG_DATA        => X_MSG_DATA,
                                               X_RETURN_STATUS   => X_RETURN_STATUS
                                             );

End Do_Split_line;

End ASO_SPLIT_LINE_INT;

/
