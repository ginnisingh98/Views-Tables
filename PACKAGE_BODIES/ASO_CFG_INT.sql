--------------------------------------------------------
--  DDL for Package Body ASO_CFG_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CFG_INT" as
/* $Header: asoicfgb.pls 120.7.12010000.16 2016/04/01 21:30:58 vidsrini ship $ */
-- Start of Comments
-- Package name     : aso_cfg_int
-- Purpose          :
-- History          :
-- NOTE             : 8/21/04 skulkarn: added the MACD changes into the get_config_details API
--                    9/16/04 bmishra:  Made changes in pricing_callback and query_qte_line_rows. Fix for bug#3850782
--                    9/17/04 skulkarn: fixed bug 3883545
--                   11/23/04 skulkarn: fixed bug 3998564
--                   12/06/04 skulkarn: fixed bug3938943
-- End of Comments
 --private variable declaration

 G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASO_CFG_INT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoicfgb.pls';

Procedure  Populate_output_table(
            p_oe_line_tbl      IN            OE_ORDER_PUB.line_tbl_type ,
            x_qte_line_tbl     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.qte_line_tbl_type,
            x_qte_line_dtl_tbl OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.qte_line_dtl_tbl_type,
            x_shipment_tbl     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.shipment_tbl_type) AS
Begin
  If p_oe_line_tbl.count <= 0 Then
     Return;
  End If;

  For i In p_oe_line_tbl.FIRST .. p_oe_line_tbl.LAST Loop

    x_qte_line_tbl(i).inventory_item_id :=
                      p_oe_line_tbl(i).inventory_item_id ;

    x_qte_line_dtl_tbl(i).component_code :=
                         p_oe_line_tbl(i).component_code ;
    x_qte_line_dtl_tbl(i).config_header_id :=
                         p_oe_line_tbl(i).config_header_id ;
    x_qte_line_dtl_tbl(i).config_revision_num :=
                         p_oe_line_tbl(i).config_rev_nbr ;
    x_shipment_tbl(i).shipment_id :=
                         p_oe_line_tbl(i).source_document_line_id ;

  End Loop ;
End Populate_output_table;

PROCEDURE Get_configuration_lines(
    P_Api_Version_Number      IN            NUMBER,
    P_Init_Msg_List           IN            VARCHAR2     := FND_API.G_FALSE,
    p_top_model_line_id       IN            NUMBER,
    x_qte_line_tbl            OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.qte_line_tbl_type,
    x_qte_line_dtl_tbl        OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.qte_line_dtl_tbl_type,
    x_shipment_tbl            OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.shipment_tbl_type ,
    x_return_status           OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_msg_count               OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data                OUT NOCOPY /* file.sql.39 change */     VARCHAR2   )
AS
  l_oe_line_tbl  OE_ORDER_PUB.Line_Tbl_Type ;
  l_api_name     VARCHAR2(30) := 'Get_Configuration_Lines' ;
  l_api_version_number Number := 1.0 ;
BEGIN
  -- Standard Start of API savepoint
      SAVEPOINT GET_CONFIGURATION_LINES_PUB;

  OE_ORDER_GRP.Get_Option_Lines(
                p_api_version_number  => l_api_version_number ,
                p_init_msg_list       => FND_API.G_FALSE ,
                p_top_model_line_id   => p_top_model_line_id ,
                x_line_tbl            => l_oe_line_tbl ,
                x_return_status       => x_return_status ,
                x_msg_count           => x_msg_count ,
                x_msg_data            => x_msg_data ) ;

         If x_return_status <> FND_API.G_RET_STS_SUCCESS Then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        End if;

   Populate_output_table(p_oe_line_tbl => l_oe_line_tbl ,
                         x_qte_line_tbl => x_qte_line_tbl,
                         x_qte_line_dtl_tbl => x_qte_line_dtl_tbl ,
                         x_shipment_tbl => x_shipment_tbl );

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
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END Get_Configuration_Lines;

PROCEDURE Delete_configuration(
	P_Api_version_NUmber    IN	     NUMBER,
	P_Init_msg_List         IN	     VARCHAR2 := FND_API.G_FALSE,
	P_config_hdr_id         IN         NUMBER,
	p_config_rev_nbr        IN         NUMBER,
	x_return_status         OUT NOCOPY /* file.sql.39 change */    	VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */    	NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */    	VARCHAR2)
IS
l_usage_exists    NUMBER;
l_Error_message   VARCHAR2(2000);
l_Return_value    NUMBER;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    cz_cf_api.delete_configuration(P_config_hdr_id,
                               p_config_rev_nbr,
                               l_usage_exists   ,
                               l_Error_message  ,
                               l_Return_value   );

    IF l_Return_value = 0 Then
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('ASO', 'ASO_CZ_DELETE_ERR');
          FND_MESSAGE.Set_token('MSG_TXT' , l_error_message,FALSE);
          FND_MSG_PUB.ADD;
 	  END IF;
    END IF;

END Delete_configuration;


PROCEDURE Delete_configuration_auto(
	P_Api_version_NUmber    IN	     NUMBER,
	P_Init_msg_List         IN	     VARCHAR2 := FND_API.G_FALSE,
	P_config_hdr_id         IN         NUMBER,
	p_config_rev_nbr        IN         NUMBER,
	x_return_status         OUT NOCOPY /* file.sql.39 change */    	VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */    	NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */    	VARCHAR2)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE_CONFIGURATION(
          P_API_VERSION_NUMBER     => 1.0,
          P_INIT_MSG_LIST          => FND_API.G_FALSE,
          P_CONFIG_HDR_ID          => P_config_hdr_id,
          P_CONFIG_REV_NBR         => p_config_rev_nbr,
          X_RETURN_STATUS          => x_return_status,
          X_MSG_COUNT              => x_msg_count,
          X_MSG_DATA               => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS Then
         commit;
    ELSE
         rollback;
    END IF;

END Delete_configuration_auto;

Procedure Copy_Configuration( p_api_version_number   IN           NUMBER,
                              p_init_msg_list        IN           VARCHAR2  :=  FND_API.G_FALSE,
                              p_commit               IN           VARCHAR2  :=  FND_API.G_FALSE,
                              p_config_header_id     IN           NUMBER,
                              p_config_revision_num  IN           NUMBER,
                              p_copy_mode            IN           VARCHAR2,
                              p_handle_deleted_flag  IN           VARCHAR2  :=  NULL,
                              p_new_name             IN           VARCHAR2  :=  NULL,
                              p_autonomous_flag      IN           VARCHAR2  :=  FND_API.G_FALSE,
                              x_config_header_id     OUT NOCOPY /* file.sql.39 change */    NUMBER,
                              x_config_revision_num  OUT NOCOPY /* file.sql.39 change */    NUMBER,
                              x_orig_item_id_tbl     OUT NOCOPY   CZ_API_PUB.number_tbl_type,
                              x_new_item_id_tbl      OUT NOCOPY   CZ_API_PUB.number_tbl_type,
                              x_return_status        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                              x_msg_count            OUT NOCOPY /* file.sql.39 change */    NUMBER,
                              x_msg_data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2
                            )
IS

 l_api_name             CONSTANT  VARCHAR2(30)      :=  'COPY_CONFIGURATION';
 l_api_version_number   CONSTANT  NUMBER            :=  1.0;
 l_config_rev_nbr 	              NUMBER;

-- ER 3177722
 l_autonomous_flag    VARCHAR2(1);
 l_copy_config_profile     varchar2(1):=nvl(fnd_profile.value('ASO_COPY_CONFIG_EFF_DATE'),'Y');

 cursor c_config_rev_nbr is
 select config_rev_nbr
 from   cz_config_details_v
 where  config_hdr_id  =  p_config_header_id
 and    config_rev_nbr =  p_config_revision_num;


 cursor c_config_max_rev_nbr is select max(config_rev_nbr)
 from cz_config_details_v
 where config_hdr_id = p_config_header_id;


BEGIN
     SAVEPOINT COPY_CONFIGURATION_INT;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_CFG_INT: Begin Copy_Configuration');
     END IF;

     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          G_PKG_NAME) THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


     END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('copy_configuration: p_init_msg_list:  '|| p_init_msg_list);
     END IF;

     IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN

         aso_debug_pub.add('copy_configuration: p_config_header_id:    '|| p_config_header_id);
         aso_debug_pub.add('copy_configuration: p_config_revision_num: '|| p_config_revision_num);
         aso_debug_pub.add('copy_configuration: p_copy_mode:           '|| p_copy_mode);
         aso_debug_pub.add('copy_configuration: p_autonomous_flag:     '|| p_autonomous_flag);

     END IF;


     open  c_config_rev_nbr;
     fetch c_config_rev_nbr into l_config_rev_nbr;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('After cursor c_config_rev_nbr l_config_rev_nbr: '||l_config_rev_nbr);
     END IF;

     IF c_config_rev_nbr%NOTFOUND THEN

         open  c_config_max_rev_nbr;
         fetch c_config_max_rev_nbr into l_config_rev_nbr;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('After cursor c_config_max_rev_nbr l_config_rev_nbr: '||l_config_rev_nbr);
         END IF;

         close c_config_max_rev_nbr;

     END IF;
     close c_config_rev_nbr;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Before call to cz_config_api_pub.copy_configuration');
     END IF;
     -- ER 3177722
     l_autonomous_flag := p_autonomous_flag;
     if l_copy_config_profile='N' then
        l_autonomous_flag:=fnd_api.g_true;
     end if;
     IF l_autonomous_flag = fnd_api.g_true THEN

          cz_config_api_pub.copy_configuration_auto( p_api_version          =>  1.0,
                                                     p_config_hdr_id        =>  p_config_header_id,
                                                     p_config_rev_nbr       =>  l_config_rev_nbr,
                                                     p_copy_mode            =>  p_copy_mode,
                                                     p_handle_deleted_flag  =>  p_handle_deleted_flag,
                                                     p_new_name             =>  p_new_name,
                                                     x_config_hdr_id        =>  x_config_header_id,
                                                     x_config_rev_nbr       =>  x_config_revision_num,
                                                     x_orig_item_id_tbl     =>  x_orig_item_id_tbl,
                                                     x_new_item_id_tbl      =>  x_new_item_id_tbl,
                                                     x_return_status        =>  x_return_status,
                                                     x_msg_count            =>  x_msg_count,
                                                     x_msg_data             =>  x_msg_data
                                                   );

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('After call to cz_config_api_pub.copy_configuration_auto');
              aso_debug_pub.add('copy_configuration: x_return_status: '|| x_return_status);
          END IF;

     ELSE

          cz_config_api_pub.copy_configuration( p_api_version          =>  1.0,
                                                p_config_hdr_id        =>  p_config_header_id,
                                                p_config_rev_nbr       =>  l_config_rev_nbr,
                                                p_copy_mode            =>  p_copy_mode,
                                                p_handle_deleted_flag  =>  p_handle_deleted_flag,
                                                p_new_name             =>  p_new_name,
                                                x_config_hdr_id        =>  x_config_header_id,
                                                x_config_rev_nbr       =>  x_config_revision_num,
                                                x_orig_item_id_tbl     =>  x_orig_item_id_tbl,
                                                x_new_item_id_tbl      =>  x_new_item_id_tbl,
                                                x_return_status        =>  x_return_status,
                                                x_msg_count            =>  x_msg_count,
                                                x_msg_data             =>  x_msg_data
                                              );

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('After call to cz_config_api_pub.copy_configuration');
              aso_debug_pub.add('copy_configuration: x_return_status: '|| x_return_status);
          END IF;

     END IF;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN


	     RAISE FND_API.G_EXC_ERROR;

     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN


	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;


     FND_MSG_PUB.Count_And_Get( p_count   =>  x_msg_count,
                                p_data    =>  x_msg_data );


     EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN

              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                                 P_PKG_NAME        => G_PKG_NAME,
                                                 P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                                 P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                                 X_MSG_COUNT       => X_MSG_COUNT,
                                                 X_MSG_DATA        => X_MSG_DATA,
                                                 X_RETURN_STATUS   => X_RETURN_STATUS);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME        => L_API_NAME,
                                                 P_PKG_NAME        => G_PKG_NAME,
                                                 P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                                 P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                                                 X_MSG_COUNT       => X_MSG_COUNT,
                                                 X_MSG_DATA        => X_MSG_DATA,
                                                 X_RETURN_STATUS   => X_RETURN_STATUS);


         WHEN OTHERS THEN

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('ASO_CFG_INT: copy_configuration: Inside when others exception');
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


END Copy_Configuration;



PROCEDURE  Update_revision_num(
            p_quote_header_id    IN            NUMBER ,
            p_config_hdr_id      IN            NUMBER ,
            p_config_rev_nbr     IN            NUMBER ,
            p_to_config_hdr_id   IN            NUMBER ,
            p_to_config_rev_nbr  IN            NUMBER ,
            x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
            x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER ,
            x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2 )  IS
  Cursor c_update_revision IS
        SELECT quote_line_id,
               quote_line_Detail_id
        From   aso_quote_line_details
        Where  config_header_id = p_config_hdr_id
        AND    config_revision_num = p_config_rev_nbr ;

   l_Api_Version_Number  NUMBER := 1.0 ;
   l_Qte_Line_Rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type ;
   l_miss_line_rec       ASO_QUOTE_PUB.Qte_Line_Rec_Type ;
   l_Qte_Line_Dtl_Tbl    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type ;
   l_miss_Line_Dtl_Tbl    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type ;
   X_Qte_Line_Rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type ;
   X_Qte_Line_Dtl_Tbl    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type ;
   X_payment_tbl         ASO_QUOTE_PUB.Payment_tbl_type ;
   X_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type ;
   X_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
   X_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
   X_price_attributes_tbl ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   X_price_adj_attr_tbl  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
   X_line_attribs_ext_tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type;
   X_price_adj_tbl       ASO_QUOTE_PUB.Price_adj_tbl_type ;
   X_Sales_Credit_Tbl    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ;
   X_Quote_Party_Tbl     ASO_QUOTE_PUB.Quote_Party_Tbl_Type ;
Begin

  For i_update_revision IN c_update_revision Loop
    l_qte_line_rec := l_miss_line_rec ;
    l_qte_line_dtl_tbl := l_miss_line_dtl_tbl ;

    l_qte_line_rec.quote_line_id := i_update_revision.quote_line_id ;
    l_qte_line_rec.quote_header_id := p_quote_header_id ;
    l_qte_line_dtl_tbl(1).operation_code := 'UPDATE';
    l_qte_line_dtl_tbl(1).quote_line_id := i_update_revision.quote_line_id;
    l_qte_line_dtl_tbl(1).quote_line_detail_id :=
                          i_update_revision.quote_line_detail_id;
    l_qte_line_dtl_tbl(1).config_revision_num := p_to_config_rev_nbr ;

    ASO_QUOTE_LINES_PVT.Update_Quote_Line(
      P_Api_Version_Number =>  l_api_version_number ,
      P_Init_Msg_List      =>  FND_API.G_FALSE,
      P_Commit             =>  FND_API.G_FALSE,
      P_Validation_Level   =>  FND_API.G_VALID_LEVEL_NONE ,
      P_Qte_Line_Rec       =>  l_qte_line_REC,
      P_Qte_Line_Dtl_Tbl   =>  l_qte_line_dtl_TBL,
      P_Update_Header_Flag =>  FND_API.G_FALSE ,
      X_Qte_Line_Rec       =>  x_Qte_Line_Rec,
      X_payment_tbl        =>  x_payment_tbl,
      X_price_adj_tbl      =>  x_price_adj_tbl ,
      X_Qte_Line_Dtl_Tbl   =>  x_Qte_Line_Dtl_Tbl ,
      X_shipment_tbl       =>  x_shipment_tbl ,
      X_tax_detail_tbl     =>  x_tax_detail_tbl ,
      X_freight_charge_tbl =>  x_freight_charge_tbl ,
      X_price_attributes_tbl => x_price_attributes_tbl ,
      X_price_adj_attr_tbl =>  x_price_adj_attr_tbl ,
      X_line_attribs_ext_tbl => x_line_attribs_ext_tbl ,
      X_Sales_Credit_Tbl     => x_sales_credit_tbl ,
      X_Quote_Party_Tbl      => x_quote_party_tbl ,
      X_Return_Status      =>  x_return_status ,
      X_Msg_Count          =>  x_msg_count,
      X_Msg_Data           =>  x_msg_data     );

     --check for success
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  End Loop;

End Update_Revision_Num ;

PROCEDURE Create_Relationship(parent_quote_line_id  IN            NUMBER ,
                              p_config_item_id      IN            NUMBER ,
                              x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                              x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
                              x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2 ) IS

 l_LINE_RLTSHIP_Rec  ASO_quote_PUB.LINE_RLTSHIP_Rec_Type  :=
                               ASO_QUOTE_PUB.G_MISS_LINE_RLTSHIP_REC ;
 l_api_name Constant Varchar2(30) := 'Create_Relationship' ;
 l_api_version_number  NUMBER  := 1.0 ;
 l_line_relationship_id NUMBER ;
 l_dummy_line_id	NUMBER;
 l_return_status	varchar2(1);

  CURSOR c_rel_exist( p_quote_line_id NUMBER ) is
		select related_quote_line_id
                  from  aso_line_relationships
                  where related_quote_line_id = p_quote_line_id;


BEGIN
  l_return_status := FND_API.G_RET_STS_SUCCESS;
 If G_rtln_tbl.First IS NULL Then
   return;
 end if;

 FOR i IN G_rtln_tbl.FIRST .. G_rtln_tbl.LAST LOOP
   If G_rtln_tbl(i).parent_config_item_id =  p_config_item_id
   AND G_rtln_tbl(i).included_flag = 'N'
   AND G_rtln_tbl(i).parent_config_item_id IS NOT NULL Then

    l_line_rltship_rec := aso_quote_pub.G_MISS_Line_rltship_rec ;

    --populate line relationship record
     l_line_rltship_rec.OPERATION_CODE	:= 'CREATE' ;
     l_line_rltship_rec.QUOTE_LINE_ID   := parent_quote_line_id ;
     l_line_rltship_rec.RELATED_QUOTE_LINE_ID := G_rtln_tbl(i).quote_line_id ;
     l_line_rltship_rec.RELATIONSHIP_TYPE_CODE  := 'CONFIG' ;


    If G_rtln_tbl(i).created_flag = 'N' Then
     ASO_LINE_RLTSHIP_PVT.Create_line_rltship(
          P_Api_Version_Number  => l_api_version_number ,
          P_Init_Msg_List       => FND_API.G_FALSE,
          P_Commit              => FND_API.G_FALSE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          P_LINE_RLTSHIP_Rec    => l_line_rltship_rec ,
          X_LINE_RELATIONSHIP_ID => l_line_relationship_id ,
          X_Return_Status        => x_return_status ,
          X_Msg_Count            => x_msg_count,
          X_Msg_Data             => x_msg_data     );

 	l_return_status  :=  x_return_status;

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    End If;

      G_rtln_tbl(i).included_flag := 'Y';

      Create_relationship(parent_quote_line_id => G_rtln_tbl(i).quote_line_id ,
                          p_config_item_id     => G_rtln_tbl(i).config_item_id,
                          x_return_status      => x_return_status ,
                          x_msg_count          => x_msg_count ,
                          x_msg_data           => x_msg_data ) ;
    End If;
 END LOOP;

 	x_return_status  :=  l_return_status;
END create_relationship ;


Procedure Populate_Rtln_Tbl(p_quote_header_id  IN   NUMBER ,
                            p_quote_line_id    IN   NUMBER ,
                            p_config_hdr_id    IN   NUMBER ,
                            p_config_rev_nbr   IN   NUMBER ) IS

 CURSOR c_options ( l_config_hdr_id  NUMBER ,
                    l_config_rev_nbr NUMBER ) IS
   SELECT qte_dtl.quote_line_id ,
          cfg_dtl.parent_config_item_id ,
          cfg_dtl.config_item_id ,
          cfg_dtl.inventory_item_id ,
          cfg_dtl.organization_id ,
          cfg_dtl.component_code ,
          cfg_dtl.quantity,
	  cfg_dtl.uom_code -- 6661597
   FROM   cz_config_details_v cfg_dtl ,
          aso_quote_line_details qte_dtl
   WHERE  cfg_dtl.config_hdr_id  = l_config_hdr_id
    AND   cfg_dtl.config_rev_nbr = l_config_rev_nbr
    AND   cfg_dtl.config_hdr_id  = qte_dtl.config_header_id
    AND   cfg_dtl.config_rev_nbr = qte_dtl.config_revision_num
    AND   qte_dtl.config_item_id = cfg_dtl.config_item_id ;


 CURSOR c_model ( l_model_line_id  NUMBER ,
                  l_config_hdr_id  NUMBER ,
                  l_config_rev_nbr NUMBER ) IS
   SELECT qte_dtl.quote_line_id ,
          cfg_dtl.parent_config_item_id ,
          cfg_dtl.config_item_id ,
          cfg_dtl.inventory_item_id ,
          cfg_dtl.organization_id ,
          cfg_dtl.component_code ,
          cfg_dtl.quantity,
	  cfg_dtl.uom_code -- 6661597
   FROM   cz_config_details_v cfg_dtl ,
          aso_quote_line_details qte_dtl
   WHERE  qte_dtl.quote_line_id  = l_model_line_id
   AND    cfg_dtl.config_hdr_id  = l_config_hdr_id
   AND    cfg_dtl.config_rev_nbr = l_config_rev_nbr
   AND    cfg_dtl.config_hdr_id  = qte_dtl.config_header_id
   AND    cfg_dtl.config_rev_nbr = qte_dtl.config_revision_num
   AND    qte_dtl.config_item_id = cfg_dtl.config_item_id;

   l_rec_options     c_options%ROWTYPE;
   l_rec_model       c_model%ROWTYPE;
   l_index           BINARY_INTEGER;
   l_dummy_line_id   NUMBER;

     -- added by 6661597
  l_validated_quantity    NUMBER;
  l_primary_quantity       NUMBER;
  l_qty_return_status      VARCHAR2(1);
  p_item_id                NUMBER;
  p_organization_id        NUMBER;
  p_uom_code               VARCHAR2(50);
  p_input_quantity         NUMBER;
  x_output_quantity        NUMBER;
  x_ret_Stat               VARCHAR2(50);
-- end 6661597

BEGIN
     IF  G_rtln_tbl.EXISTS(1) Then

         -- This is the first time Model is configured, hence all the options
         -- are in G_rtln_tbl. No need to populate.
         RETURN ;
     END IF;

     FOR l_rec_model IN c_model (p_quote_line_id,p_config_hdr_id,p_config_rev_nbr)
     LOOP
         -- Assumption is configured items will have only one detail per quote line
         G_rtln_tbl(1).quote_line_id          :=  l_rec_model.quote_line_id;
         G_rtln_tbl(1).parent_config_item_id  :=  NULL;
         G_rtln_tbl(1).config_item_id         :=  l_rec_model.config_item_id;
         G_rtln_tbl(1).inventory_item_id      :=  l_rec_model.inventory_item_id;
         G_rtln_tbl(1).organization_id        :=  l_rec_model.organization_id;
         G_rtln_tbl(1).component_code         :=  l_rec_model.component_code;
	  -- 6661597
         p_item_id:=l_rec_model.inventory_item_id;
         p_organization_id:=l_rec_model.organization_id;
         p_uom_code:=l_rec_model.uom_code;
         p_input_quantity:=l_rec_model.quantity;
         x_output_quantity:=FND_API.G_MISS_NUM;

	 -- inv quantity validation 6661597
         IF (p_input_quantity is not null AND p_input_quantity <> FND_API.G_MISS_NUM) THEN
                inv_decimals_pub.validate_quantity(
		               p_item_id          => p_item_id ,
			             p_organization_id  => p_organization_id   ,
	                 p_input_quantity   => p_input_quantity,
		               p_uom_code         => p_uom_code,
			             x_output_quantity  => l_validated_quantity,
	                 x_primary_quantity => l_primary_quantity,
		               x_return_status    => x_ret_Stat);

		            if x_ret_Stat = 'E' THEN
		              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_FRACTIONAL_QUANTITY');
		                FND_MSG_PUB.ADD;
		              END IF;
		              RAISE FND_API.G_EXC_ERROR;
		            elsif x_ret_Stat = 'W' then
		              x_output_quantity:=   l_validated_quantity;
		            else
		              x_output_quantity:=p_input_quantity;
		          end if;
            END IF; -- quantity not null

	          -- end quantity validation changes 6661597
         G_rtln_tbl(1).quantity               :=  x_output_quantity;  -- 6661597
         --G_rtln_tbl(1).quantity               :=  l_rec_model.quantity;
         G_rtln_tbl(1).included_flag          :=  'N';
         G_rtln_tbl(1).created_flag           :=  'Y';

     END LOOP ;

     l_index := G_rtln_tbl.LAST + 1 ;

     FOR l_rec_options IN c_options (p_config_hdr_id,p_config_rev_nbr)
     LOOP

         G_rtln_tbl(l_index).quote_line_id         := l_rec_options.quote_line_id;
         G_rtln_tbl(l_index).parent_config_item_id := l_rec_options.parent_config_item_id;
         G_rtln_tbl(l_index).config_item_id        := l_rec_options.config_item_id;
         G_rtln_tbl(l_index).inventory_item_id     := l_rec_options.inventory_item_id;
         G_rtln_tbl(l_index).organization_id       := l_rec_options.organization_id;
         G_rtln_tbl(l_index).component_code        := l_rec_options.component_code;
	  -- 6661597
         p_item_id:=l_rec_options.inventory_item_id;
	       p_organization_id:=l_rec_options.organization_id;
	       p_uom_code:=l_rec_options.uom_code;
	       p_input_quantity:=l_rec_options.quantity;
         x_output_quantity:=FND_API.G_MISS_NUM;

        -- inv quantity validation 6661597
         IF (p_input_quantity is not null AND p_input_quantity <> FND_API.G_MISS_NUM) THEN
                inv_decimals_pub.validate_quantity(
		               p_item_id          => p_item_id ,
			             p_organization_id  => p_organization_id   ,
	                 p_input_quantity   => p_input_quantity,
		               p_uom_code         => p_uom_code,
			             x_output_quantity  => l_validated_quantity,
	                 x_primary_quantity => l_primary_quantity,
		               x_return_status    => x_ret_Stat);

		            if x_ret_Stat = 'E' THEN
		              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_FRACTIONAL_QUANTITY');
		                FND_MSG_PUB.ADD;
		              END IF;
		              RAISE FND_API.G_EXC_ERROR;
		            elsif x_ret_Stat = 'W' then
		              x_output_quantity:=   l_validated_quantity;
		            else
		              x_output_quantity:=p_input_quantity;
		          end if;
            END IF; -- quantity not null

	          -- end quantity validation changes 6661597
         G_rtln_tbl(l_index).quantity              := x_output_quantity;--l_rec_options.quantity;
         --G_rtln_tbl(l_index).quantity              := l_rec_options.quantity;
         G_rtln_tbl(l_index).included_flag         := 'N';
         G_rtln_tbl(l_index).created_flag          := 'N';

         l_index := l_index + 1;

     END LOOP ;

END Populate_Rtln_Tbl ;



PROCEDURE Get_config_details(
    p_api_version_number         IN             NUMBER,
    p_init_msg_list              IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                     IN             VARCHAR2  := FND_API.G_FALSE,
    p_control_rec                IN             aso_quote_pub.control_rec_type
									   := aso_quote_pub.G_MISS_control_rec,
    p_qte_header_rec             IN             aso_quote_pub.qte_header_rec_type,
    p_model_line_rec             IN             aso_quote_pub.qte_line_rec_type,
    p_config_rec                 IN             aso_quote_pub.qte_line_dtl_rec_type,
    p_config_hdr_id              IN             NUMBER,
    p_config_rev_nbr             IN             NUMBER,
    x_return_status              OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */      VARCHAR2
)
IS
  CURSOR C_config_details_ins (l_config_hdr_id  NUMBER,
                               l_config_rev_nbr NUMBER ) IS
       SELECT config_hdr_id,
              config_rev_nbr ,
              config_item_id ,
              parent_config_item_id ,
              inventory_item_id ,
              organization_id ,
              component_code ,
              quantity ,
              uom_code,
              bom_sort_order,
              config_delta,
              name,
              line_type,
		    component_sequence_id,
		    ato_config_item_id,
		    model_config_item_id
	  FROM  cz_config_details_v cfg_dtl
       WHERE config_hdr_id  = l_config_hdr_id
       AND   config_rev_nbr = l_config_rev_nbr
       AND   NOT EXISTS (SELECT NULL
                         FROM   ASO_QUOTE_LINE_DETAILS qte_dtl
                         WHERE  qte_dtl.config_header_id    = cfg_dtl.config_hdr_id
                         AND    qte_dtl.config_revision_num = cfg_dtl.config_rev_nbr
                         AND    qte_dtl.config_item_id      = cfg_dtl.config_item_id )
       ORDER BY cfg_dtl.bom_sort_order;

  --assumption is currently we are updating only the qty/uom/the flags and bom_sort_order
  CURSOR C_config_details_upd ( l_config_hdr_id NUMBER ,
                                l_config_rev_nbr NUMBER ,
                                l_complete_configuration_flag VARCHAR2,
                                l_valid_configuration_flag VARCHAR2 ) IS
       SELECT dtl.quote_line_id,
              dtl.quote_line_detail_id,
              cfg.inventory_item_id ,
              cfg.organization_id ,
              cfg.component_code ,
              cfg.quantity ,
              cfg.uom_code,
              cfg.bom_sort_order,
              cfg.config_delta,
              cfg.line_type,
		    cfg.name,
              qte.line_type_source_flag
       FROM   ASO_QUOTE_LINE_DETAILS dtl,
              CZ_CONFIG_DETAILS_V cfg ,
              ASO_QUOTE_LINES_ALL    qte
       WHERE  dtl.config_header_id    = l_config_hdr_id
       AND    cfg.config_rev_nbr      = l_config_rev_nbr
       AND    dtl.config_header_id    = cfg.config_hdr_id
       AND    dtl.config_revision_num = cfg.config_rev_nbr
       AND    dtl.config_item_id      = cfg.config_item_id
       AND    dtl.quote_line_id       = qte.quote_line_id
       AND    ((qte.quantity <> cfg.quantity)
       OR      (qte.uom_code <> cfg.uom_code)
       OR      (dtl.complete_configuration_flag <> l_complete_configuration_flag)
       OR      (dtl.valid_configuration_flag    <> l_valid_configuration_flag)
       OR      (dtl.bom_sort_order <> cfg.bom_sort_order)
	  OR      (dtl.config_instance_name        <>  cfg.name)
       OR      (nvl(dtl.config_delta,-1)        <>  nvl(cfg.config_delta, -1))
       OR      (nvl(qte.order_line_type_id,-1)  <>  nvl(cfg.line_type, -1)));

 CURSOR C_config_details_del( l_config_hdr_id NUMBER ,
                              l_config_rev_nbr NUMBER ) IS
      SELECT dtl.quote_line_id
      FROM   ASO_QUOTE_LINE_DETAILS dtl
      WHERE  dtl.config_header_id    = l_config_hdr_id
      AND    dtl.config_revision_num = l_config_rev_nbr
      AND    NOT EXISTS ( SELECT  NULL
                          FROM   CZ_CONFIG_DETAILS_V cfg
                          WHERE  cfg.config_item_id = dtl.config_item_id
                          AND    cfg.config_hdr_id  = l_config_hdr_id
                          AND    cfg.config_rev_nbr = l_config_rev_nbr );

 CURSOR C_config_all(p_parent_config_item_id number) IS
    SELECT quote_line_id
    FROM   aso_quote_line_details
    WHERE  config_header_id    = p_config_hdr_id
    AND    config_revision_num = p_config_rev_nbr
    AND    config_item_id      = p_parent_config_item_id;

 CURSOR C_Config_Exists( l_config_hdr_id NUMBER ,
                         l_config_rev_nbr NUMBER ) IS
    SELECT quote_line_id
    FROM   aso_quote_line_details
    WHERE  ref_type_code = 'CONFIG'
    AND    ref_line_id IS NULL
    AND    config_header_id    = l_config_hdr_id
    AND    config_revision_num = l_config_rev_nbr;

 CURSOR c_quote(c_qte_header_id NUMBER) IS
    SELECT last_update_date, quote_type
    FROM   ASO_QUOTE_HEADERS_ALL
    WHERE  quote_header_id = c_qte_header_id;

 CURSOR Order_Type_C  IS
    SELECT order_line_type_id, line_category_code, price_list_id, line_number,ship_model_complete_flag,
           config_model_type
    FROM   aso_quote_lines_all
    WHERE  quote_line_id = p_config_rec.quote_line_id;

 CURSOR c_messages  is
  SELECT constraint_type, message
  FROM   cz_config_messages
  WHERE  config_hdr_id  = p_config_hdr_id
  AND    config_rev_nbr = p_config_rev_nbr;

 CURSOR C_diff_Config_Exists IS
    SELECT config_header_id
    FROM   aso_quote_line_details
    WHERE  ref_type_code = 'CONFIG'
    AND    ref_line_id IS NULL
    AND    quote_line_id  = p_config_rec.quote_line_id;

 CURSOR c_config_exist_in_cz (p_config_hdr_id number, p_config_rev_nbr number) IS
   select config_hdr_id
   from cz_config_details_v
   where config_hdr_id = p_config_hdr_id
   and config_rev_nbr = p_config_rev_nbr;

 l_api_name                CONSTANT VARCHAR2(30) := 'Get_Config_Details' ;
 l_api_version_number      CONSTANT NUMBER       := 1.0;
 l_index                            BINARY_INTEGER ;
 l_complete_configuration_flag      VARCHAR2(1);
 l_valid_configuration_flag         VARCHAR2(1);
 l_quote_line_id                    NUMBER;
 l_last_update_date                 date;
 p 			                     NUMBER;
 l_order_line_type_id	           NUMBER;
 l_line_category_code	           VARCHAR2(30);
 l_price_list_id		           NUMBER;
 l_quote_type                       VARCHAR2(1);
 l_line_number		                NUMBER;
 i                                  NUMBER;
 l_len_msg                          NUMBER;
 l_old_config_hdr_id                NUMBER;
l_ship_model_complete_flag          VARCHAR2(1);

 l_control_rec             ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE
			                     := ASO_UTILITY_PVT.Get_Pricing_Control_Rec;
 l_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
 l_qte_line_tbl            ASO_QUOTE_PUB.Qte_Line_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_Qte_Line_Tbl;
 l_qte_line_dtl_tbl        ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Qte_Line_Dtl_Tbl;
-- l_qte_line_dtl_search     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Qte_Line_Dtl_Tbl;
-- bug 11696691
 l_qte_line_dtl_search     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type1 := ASO_QUOTE_PUB.G_MISS_Qte_Line_Dtl_Tbl1;

 l_hd_Price_Attr_Tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
 l_hd_payment_tbl          ASO_QUOTE_PUB.Payment_Tbl_Type;
 l_hd_shipment_rec         ASO_QUOTE_PUB.Shipment_rec_Type;
 l_hd_freight_charge_tbl   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
 l_hd_tax_detail_tbl       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
 l_Line_Attr_Ext_Tbl       ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
 l_line_rltship_tbl        ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
 l_Price_Adjustment_Tbl    ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
 l_Price_Adj_Attr_Tbl      ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
 l_price_adj_rltship_tbl   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
 l_ln_Price_Attr_Tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
 l_ln_payment_tbl          ASO_QUOTE_PUB.Payment_Tbl_Type;
 l_ln_shipment_tbl         ASO_QUOTE_PUB.Shipment_Tbl_Type;
 l_ln_freight_charge_tbl   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
 l_ln_tax_detail_tbl       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
 l_shipment_tbl    	       ASO_QUOTE_PUB.Shipment_tbl_Type;

 lx_qte_header_rec         ASO_QUOTE_PUB.Qte_Header_Rec_Type;
 lx_qte_line_tbl           ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
 lx_qte_line_dtl_tbl       ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
 lx_hd_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
 lx_hd_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
 lx_hd_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
 lx_hd_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
 lx_hd_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
 lx_Line_Attr_Ext_Tbl      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
 lx_line_rltship_tbl       ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
 lx_Price_Adjustment_Tbl   ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
 lx_Price_Adj_Attr_Tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
 lx_price_adj_rltship_tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
 lx_ln_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
 lx_ln_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
 lx_ln_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
 lx_ln_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
 lx_ln_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

 l_file                    varchar2(200);
 lx_return_status          varchar2(10);
 l_config_model_type       varchar2(30);

 -- added by 6661597
l_validated_quantity    NUMBER;
l_primary_quantity       NUMBER;
l_qty_return_status      VARCHAR2(1);
p_item_id                NUMBER;
p_organization_id        NUMBER;
p_uom_code               VARCHAR2(50);
p_input_quantity         NUMBER;
x_output_quantity        NUMBER;
x_ret_Stat               VARCHAR2(50);
-- end 6661597

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT GET_CONFIG_DETAILS_INT;

    /*
    aso_debug_pub.g_debug_flag := 'Y';
    aso_debug_pub.SetDebugLevel(10);
    aso_debug_pub.Initialize;
    l_file    := ASO_DEBUG_PUB.Set_Debug_Mode('FILE');
    aso_debug_pub.debug_on;
    */

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('ASO_CFG_INT: GET_CONFIG_DETAILS: Start %%%%%%%%%%%%%%%%%%%', 1, 'Y');

        aso_debug_pub.add('GET_CONFIG_DETAILS: p_qte_header_rec.quote_header_id: '|| p_qte_header_rec.quote_header_id);
        aso_debug_pub.add('GET_CONFIG_DETAILS: p_config_hdr_id:  '|| p_config_hdr_id);
        aso_debug_pub.add('GET_CONFIG_DETAILS: p_config_rev_nbr: '|| p_config_rev_nbr);
        aso_debug_pub.add('p_config_rec.valid_configuration_flag:    '|| p_config_rec.valid_configuration_flag);
        aso_debug_pub.add('p_config_rec.complete_configuration_flag: '|| p_config_rec.complete_configuration_flag);
    END IF;

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

    -- Set return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --Procedure added by Anoop Rajan on 30/09/2005 to print login details
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Before call to printing login info details', 1, 'Y');
	ASO_UTILITY_PVT.print_login_info;
	aso_debug_pub.add('After call to printing login info details', 1, 'Y');
    END IF;

    -- Change Done By Girish
    -- Procedure added to validate the operating unit
    ASO_VALIDATE_PVT.VALIDATE_OU(p_qte_header_rec);


    -- check whether a different config_header_id is already
    -- associated with this model item. If yes raise an error.

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: Before C_diff_Config_Exists cursor open');
    END IF;

    OPEN  C_diff_Config_Exists;
    FETCH C_diff_Config_Exists INTO l_old_config_hdr_id ;
    CLOSE C_diff_Config_Exists;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: l_old_config_hdr_id: '||l_old_config_hdr_id, 1, 'Y');
    END IF;

    IF l_old_config_hdr_id IS NOT NULL AND l_old_config_hdr_id <> p_config_hdr_id THEN

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: Inside If l_old_config_hdr_id <> p_config_hdr_id cond', 1, 'Y');
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('ASO', 'ASO_DIFFERENT_CONFIG_EXISTS');
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- check whether the config_header_id+config_revision_num is already
    -- associated with other model item. If yes raise an error.

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: Before C_config_exists cursor open');
    END IF;

    OPEN  C_config_exists(l_config_hdr_id  => p_config_hdr_id ,
                          l_config_rev_nbr => p_config_rev_nbr);
    FETCH C_config_exists INTO l_quote_line_id ;
    CLOSE C_config_exists;

    IF l_quote_line_id IS NOT NULL AND l_quote_line_id <> p_config_rec.quote_line_id THEN

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: Inside C_config_exists cursor l_quote_line_id: '||l_quote_line_id);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('ASO', 'ASO_API_CONFIG_EXISTS');
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

    --check if the quote has been modified by someone else

    OPEN  c_quote(p_qte_header_rec.quote_header_id);
    FETCH c_quote INTO l_last_update_date, l_quote_type;
    CLOSE c_quote;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Get_config_details: p_qte_header_rec.last_update_date: ' || to_char(p_qte_header_rec.last_update_date, 'DD-MON-YYYY HH24:MI:SS'));
        aso_debug_pub.add('Get_config_details: l_last_update_date:        ' || to_char(l_last_update_date, 'DD-MON-YYYY HH24:MI:SS'));
        aso_debug_pub.add('ASO_CFG_INT: Get_config_details: l_quote_type: ' || l_quote_type);
    END IF;

    if (p_qte_header_rec.last_update_date is not null) and (p_qte_header_rec.last_update_date <> fnd_api.g_miss_date) then

         If (l_last_update_date <> p_qte_header_rec.last_update_date) Then

	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	          FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
	          FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
	          FND_MSG_PUB.ADD;
	       END IF;
	       raise FND_API.G_EXC_ERROR;

         End if;

    end if;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: After C_config_exists cursor');
    END IF;

    --check if revision number has changed for this configuration.
    --if yes update all the previous selected options to the current
    --revision number.This is necessary as the current revision number
    --will not be the same as in aso_quote_line_details.

    IF ((p_config_rec.config_header_id    <> FND_API.G_Miss_num  AND
         p_config_rec.config_revision_num <> FND_API.G_Miss_Num) AND
        (p_config_rec.config_header_id    IS NOT NULL   AND
         p_config_rec.config_revision_num IS NOT NULL)) AND
        (p_config_rec.config_header_id    <> p_config_hdr_id  OR
         p_config_rec.config_revision_num <> p_config_rev_nbr) THEN
         BEGIN
		    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: Revision number has changed so updating');
              END IF;

              UPDATE aso_quote_line_details
              SET config_revision_num = p_config_rev_nbr,
                  last_update_date    = sysdate,
                  last_updated_by     = FND_GLOBAL.USER_ID,
                  last_update_login   = FND_GLOBAL.CONC_LOGIN_ID
              WHERE config_header_id    = p_config_rec.config_header_id
              AND   config_revision_num = p_config_rec.config_revision_num ;

              EXCEPTION

                  WHEN OTHERS THEN

				  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('Get_config_details: Inside WHEN OTHERS Exception of Update config_revision_num');
                      END IF;
         END;

    END IF;


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: After Update config_revision_num');
    END IF;

    OPEN Order_Type_C;
    FETCH Order_Type_C INTO l_order_line_type_id, l_line_category_code, l_price_list_id, l_line_number,l_ship_model_complete_flag,l_config_model_type;

    IF Order_Type_C%NOTFOUND THEN

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add( 'ASO_CFG_INT: Get_config_details: Cursor Order_Type_C NOTFOUND');
        END IF;

    END IF;
    CLOSE Order_Type_C;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('Get_config_details: Model: p_config_rec.quote_line_id: '|| p_config_rec.quote_line_id);
        aso_debug_pub.add('Get_config_details: Model: l_order_line_type_id: ' || l_order_line_type_id);
        aso_debug_pub.add('Get_config_details: Model: l_line_category_code: ' || l_line_category_code);
        aso_debug_pub.add('Get_config_details: Model: l_price_list_id:      ' || l_price_list_id);
        aso_debug_pub.add('Get_config_details: Model: l_line_number:        ' || l_line_number);
        aso_debug_pub.add('Get_config_details: Model: l_ship_model_complete_flag:        ' || l_ship_model_complete_flag);
        aso_debug_pub.add('Get_config_details: Model: l_config_model_type:        ' || l_config_model_type);
    END IF;

    l_index  := 0;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_CFG_INT: Get_Config_details: Before C_config_details_ins cursor LOOP');
    END IF;

    FOR row IN C_config_details_ins(p_config_hdr_id, p_config_rev_nbr)
    LOOP

        l_index  := l_index + 1;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN

            aso_debug_pub.add('ASO_CFG_INT: Get_Config_details: Inside C_config_details_ins cursor LOOP');
            aso_debug_pub.add('Get_Config_Details: l_index:               '|| l_index);
    	       aso_debug_pub.add('Get_Config_Details: config_header_id:      '|| row.config_hdr_id);
    	       aso_debug_pub.add('Get_Config_Details: config_revision_num:   '|| row.config_rev_nbr);
    	       aso_debug_pub.add('Get_Config_Details: config_item_id:        '|| row.config_item_id);
    	       aso_debug_pub.add('Get_Config_Details: parent_config_item_id: '|| row.parent_config_item_id);
    	       aso_debug_pub.add('Get_Config_Details: inventory_item_id:     '|| row.inventory_item_id);
    	       aso_debug_pub.add('Get_Config_Details: organization_id:       '|| row.organization_id);
    	       aso_debug_pub.add('Get_Config_Details: component_code:        '|| row.component_code);
    	       aso_debug_pub.add('Get_Config_Details: quantity:              '|| row.quantity);
    	       aso_debug_pub.add('Get_Config_Details: uom_code:              '|| row.uom_code);
            aso_debug_pub.add('Get_Config_Details: bom_sort_order:        '|| row.bom_sort_order);
            aso_debug_pub.add('Get_Config_Details: config_delta:          '|| row.config_delta);
            aso_debug_pub.add('Get_Config_Details: name:                  '|| row.name);
            aso_debug_pub.add('Get_Config_Details: line_type:             '|| row.line_type);
            aso_debug_pub.add('Get_Config_Details: component_sequence_id: '|| row.component_sequence_id);
	       aso_debug_pub.add('Get_Config_Details: ato_config_item_id: '|| row.ato_config_item_id);
	       aso_debug_pub.add('Get_Config_Details: model_config_item_id: '|| row.model_config_item_id);
	   END IF;

	p_item_id:=row.inventory_item_id;
	p_organization_id:=row.organization_id;
	p_uom_code:=row.uom_code;
	p_input_quantity:=row.quantity;
        x_output_quantity:=FND_API.G_MISS_NUM;
	-- inv quantity validation 6661597
         IF (p_input_quantity is not null AND p_input_quantity <> FND_API.G_MISS_NUM) THEN
                inv_decimals_pub.validate_quantity(
		        p_item_id          => p_item_id ,
			p_organization_id  => p_organization_id   ,
	                p_input_quantity   => p_input_quantity,
		        p_uom_code         => p_uom_code,
			x_output_quantity  => l_validated_quantity,
	                x_primary_quantity => l_primary_quantity,
		        x_return_status    => x_ret_Stat);
                       x_return_status:= FND_API.G_RET_STS_SUCCESS;
		if x_ret_Stat = 'E' THEN
		   x_return_status:= FND_API.G_RET_STS_ERROR;
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_FRACTIONAL_QUANTITY');
		       FND_MSG_PUB.ADD;
		    END IF;
		    RAISE FND_API.G_EXC_ERROR;
		elsif x_ret_Stat = 'W' then
		     x_output_quantity:=   l_validated_quantity;
		else
		     x_output_quantity:=p_input_quantity;
		end if;
            END IF; -- quantity not null

             -- end quantity validation changes 6661597


         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Get_Config_Details: quantity:  after inv validation            '|| x_output_quantity);
	end if;

        IF to_char( row.inventory_item_id ) = row.component_code THEN

	        l_Qte_Line_Tbl(l_index).item_type_code                  := 'MDL';
	        l_Qte_Line_Tbl(l_index).OPERATION_CODE                  := 'UPDATE';
	        l_Qte_Line_Tbl(l_index).quote_header_id                 := p_qte_header_rec.quote_header_id;
	        l_Qte_Line_Tbl(l_index).quote_line_id                   := p_config_rec.quote_line_id ;
             -- bug 3883545
		   l_Qte_Line_Tbl(l_index).quantity                        :=  x_output_quantity;  --row.quantity ;6661597


	        l_qte_line_dtl_tbl(l_index).operation_code 		    := 'CREATE';
             l_qte_line_dtl_tbl(l_index).qte_line_index		    := l_index;
	        l_qte_line_dtl_tbl(l_index).config_header_id 	         := p_config_hdr_id;
	        l_qte_line_dtl_tbl(l_index).config_revision_num 	    := p_config_rev_nbr;
	        l_qte_line_dtl_tbl(l_index).complete_configuration_flag := p_config_rec.complete_configuration_flag;
	        l_qte_line_dtl_tbl(l_index).valid_configuration_flag    := p_config_rec.valid_configuration_flag;
	        l_qte_line_dtl_tbl(l_index).component_code 		    := row.component_code;
	        l_Qte_Line_dtl_Tbl(l_index).quote_line_id               := p_config_rec.quote_line_id;
             l_Qte_Line_dtl_Tbl(l_index).config_item_id              := row.config_item_id;
             l_Qte_Line_dtl_Tbl(l_index).parent_config_item_id       := NULL;
             l_qte_line_dtl_tbl(l_index).ref_type_code               := 'CONFIG';
             l_qte_line_dtl_tbl(l_index).bom_sort_order              := row.bom_sort_order;
             l_qte_line_dtl_tbl(l_index).config_delta                := row.config_delta;
             l_qte_line_dtl_tbl(l_index).config_instance_name        := row.name;
             l_qte_line_dtl_search(row.config_item_id).quote_line_id := p_config_rec.quote_line_id;
             l_qte_line_dtl_tbl(l_index).component_sequence_id       := row.component_sequence_id;
             IF row.ato_config_item_id IS NOT NULL THEN
		     l_qte_line_dtl_tbl(l_index).ato_line_id               := p_config_rec.quote_line_id;
		   END IF;

		   l_qte_line_dtl_tbl(l_index).top_model_line_id           := p_config_rec.quote_line_id;




	   ELSE

             l_Qte_Line_Tbl(l_index).OPERATION_CODE                    := 'CREATE';
	        l_Qte_Line_Tbl(l_index).quote_header_id                   := p_qte_header_rec.quote_header_id;
	        l_Qte_Line_Tbl(l_index).item_type_code                    := 'CFG';
	        l_Qte_Line_Tbl(l_index).organization_id                   := row.organization_id;
   	        l_Qte_Line_Tbl(l_index).inventory_item_id                 := row.inventory_item_id;
   	        l_Qte_Line_Tbl(l_index).quantity                          := x_output_quantity; --row.quantity; 6661597
   	        l_Qte_Line_Tbl(l_index).uom_code                          := row.uom_code;
   	        --l_Qte_Line_Tbl(l_index).order_line_type_id              := l_order_line_type_id;  -- has been commented
   	        l_Qte_Line_Tbl(l_index).line_category_code                := l_line_category_code;
   	        l_Qte_Line_Tbl(l_index).price_list_id                     := l_price_list_id;
   	        l_Qte_Line_Tbl(l_index).line_number                       := l_line_number;
             l_Qte_Line_Tbl(l_index).ship_model_complete_flag          := l_ship_model_complete_flag;
             l_Qte_Line_Tbl(l_index).config_model_type                 := l_config_model_type;

   	        l_qte_line_dtl_tbl(l_index).operation_code 	           := 'CREATE';
      	   l_qte_line_dtl_tbl(l_index).qte_line_index		      := l_index;
    	        l_qte_line_dtl_tbl(l_index).config_header_id              := p_config_hdr_id;
    	        l_qte_line_dtl_tbl(l_index).config_revision_num           := p_config_rev_nbr;
    	        l_qte_line_dtl_tbl(l_index).complete_configuration_flag   := p_config_rec.complete_configuration_flag;
    	        l_qte_line_dtl_tbl(l_index).valid_configuration_flag      := p_config_rec.valid_configuration_flag;
    	        l_qte_line_dtl_tbl(l_index).component_code 		      := row.component_code;
             l_qte_line_dtl_tbl(l_index).config_item_id 		      := row.config_item_id;
             l_qte_line_dtl_tbl(l_index).parent_config_item_id 	      := row.parent_config_item_id;
             l_qte_line_dtl_tbl(l_index).ref_type_code                 := 'CONFIG';
             l_qte_line_dtl_tbl(l_index).bom_sort_order                := row.bom_sort_order;
             l_qte_line_dtl_tbl(l_index).config_delta                  := row.config_delta;
             l_qte_line_dtl_tbl(l_index).config_instance_name          := row.name;
             l_qte_line_dtl_search(row.config_item_id).qte_line_index  := l_index;
             l_qte_line_dtl_tbl(l_index).component_sequence_id         := row.component_sequence_id;
             l_qte_line_dtl_tbl(l_index).top_model_line_id             := p_config_rec.quote_line_id;


		   IF aso_debug_pub.g_debug_flag = 'Y' THEN

                 aso_debug_pub.add('Get_Config_Details: l_qte_line_dtl_search('||row.config_item_id||').qte_line_index: '||l_qte_line_dtl_search(row.config_item_id).qte_line_index);

             END IF;

             --Creating the parent-child relationship

             IF l_qte_line_dtl_search.EXISTS(row.parent_config_item_id) THEN

			  IF aso_debug_pub.g_debug_flag = 'Y' THEN

                 aso_debug_pub.add('Index of parent: l_qte_line_dtl_search('||row.parent_config_item_id||').qte_line_index:        '||l_qte_line_dtl_search(row.parent_config_item_id).qte_line_index);

                 aso_debug_pub.add('Quote_line_id of parent: l_qte_line_dtl_search('||row.parent_config_item_id||').quote_line_id: '||l_qte_line_dtl_search(row.parent_config_item_id).quote_line_id);

             END IF;

                 l_qte_line_dtl_tbl(l_index).ref_line_index := l_qte_line_dtl_search(row.parent_config_item_id).qte_line_index;
                 l_qte_line_dtl_tbl(l_index).ref_line_id    := l_qte_line_dtl_search(row.parent_config_item_id).quote_line_id;

             ELSE

                 OPEN C_config_all(l_qte_line_dtl_tbl(l_index).parent_config_item_id);
                 FETCH C_config_all INTO l_qte_line_dtl_tbl(l_index).ref_line_id;
                 CLOSE C_config_all;

			  IF aso_debug_pub.g_debug_flag = 'Y' THEN

                     aso_debug_pub.add('l_qte_line_dtl_tbl('||l_index||').ref_line_id: '||l_qte_line_dtl_tbl(l_index).ref_line_id);

                 END IF;
             END IF;

             -- Populating the ato_line_id

             IF l_qte_line_dtl_search.EXISTS(row.ato_config_item_id) THEN

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN

                 aso_debug_pub.add('Index of ato : l_qte_line_dtl_search('||row.ato_config_item_id||').qte_line_index:        '||l_qte_line_dtl_search(row.ato_config_item_id).qte_line_index);

                 aso_debug_pub.add('Quote_line_id of ato: l_qte_line_dtl_search('||row.ato_config_item_id||').quote_line_id: '||l_qte_line_dtl_search(row.ato_config_item_id).quote_line_id);

             END IF;

                 l_qte_line_dtl_tbl(l_index).ato_line_index := l_qte_line_dtl_search(row.ato_config_item_id).qte_line_index;
                 l_qte_line_dtl_tbl(l_index).ato_line_id    := l_qte_line_dtl_search(row.ato_config_item_id).quote_line_id;

             ELSE

                 OPEN C_config_all(row.ato_config_item_id);
                 FETCH C_config_all INTO l_qte_line_dtl_tbl(l_index).ato_line_id;
                 CLOSE C_config_all;

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN

                     aso_debug_pub.add('l_qte_line_dtl_tbl('||l_index||').ato_line_id: '||l_qte_line_dtl_tbl(l_index).ato_line_id);

                 END IF;
             END IF;

             -- End of logic for populating the ato_line_id


             --Populating order_line_type_id value based on CZ line_type value

             IF row.line_type IS NOT NULL THEN

                l_Qte_Line_Tbl(l_index).order_line_type_id     :=  row.line_type;
                l_Qte_Line_Tbl(l_index).Line_type_source_flag  :=  'C';

             ELSE

                l_Qte_Line_Tbl(l_index).order_line_type_id     :=  l_order_line_type_id;

             END IF;

        END IF;
    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add( 'ASO_CFG_INT: Get_Config_details: After C_config_details_ins cursor LOOP l_index: '|| l_index);

        aso_debug_pub.add( 'ASO_CFG_INT: Get_Config_details: Before C_config_details_upd cursor LOOP');

    END IF;

    FOR row IN C_config_details_upd( p_config_hdr_id,
                                     p_config_rev_nbr,
                                     p_config_rec.complete_configuration_flag,
                                     p_config_rec.valid_configuration_flag)
    LOOP

        l_index := l_index + 1;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN

            aso_debug_pub.add('ASO_CFG_INT: Get_Config_details: Inside C_config_details_upd cursor LOOP');
            aso_debug_pub.add('Get_Config_Details: l_index:              '|| l_index);
            aso_debug_pub.add('Get_Config_Details: quote_line_id:        '|| row.quote_line_id);
            aso_debug_pub.add('Get_Config_Details: quote_line_detail_id: '|| row.quote_line_detail_id);
            aso_debug_pub.add('Get_Config_Details: inventory_item_id:    '|| row.inventory_item_id);
            aso_debug_pub.add('Get_Config_Details: organization_id:      '|| row.organization_id);
            aso_debug_pub.add('Get_Config_Details: component_code:       '|| row.component_code);
            aso_debug_pub.add('Get_Config_Details: quantity:             '|| row.quantity);
            aso_debug_pub.add('Get_Config_Details: uom_code:             '|| row.uom_code);
            aso_debug_pub.add('Get_Config_Details: bom_sort_order:       '|| row.bom_sort_order);
            aso_debug_pub.add('Get_Config_Details: config_delta:          '|| row.config_delta);
            aso_debug_pub.add('Get_Config_Details: name:                  '|| row.name);
            aso_debug_pub.add('Get_Config_Details: line_type:             '|| row.line_type);
        END IF;

	-- added by 6661597
	p_item_id:=row.inventory_item_id;
	p_organization_id:=row.organization_id;
	p_uom_code:=row.uom_code;
	p_input_quantity:=row.quantity;
        x_output_quantity:=FND_API.G_MISS_NUM;
	-- inv quantity validation 6661597
         IF (p_input_quantity is not null AND p_input_quantity <> FND_API.G_MISS_NUM) THEN
                inv_decimals_pub.validate_quantity(
		        p_item_id          => p_item_id ,
			p_organization_id  => p_organization_id   ,
	                p_input_quantity   => p_input_quantity,
		        p_uom_code         => p_uom_code,
			x_output_quantity  => l_validated_quantity,
	                x_primary_quantity => l_primary_quantity,
		        x_return_status    => x_ret_Stat);
                       x_return_status:= FND_API.G_RET_STS_SUCCESS;
		if x_ret_Stat = 'E' THEN
		   x_return_status:= FND_API.G_RET_STS_ERROR;
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_FRACTIONAL_QUANTITY');
		       FND_MSG_PUB.ADD;
		    END IF;
		    RAISE FND_API.G_EXC_ERROR;
		elsif x_ret_Stat = 'W' then
		     x_output_quantity:=   l_validated_quantity;
		else
		     x_output_quantity:=p_input_quantity;
		end if;
            END IF; -- quantity not null

             -- end quantity validation changes rassharm 6661597


         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Get_Config_Details: quantity:  after inv validation            '|| x_output_quantity);
	end if;

        l_Qte_Line_Tbl(l_index).quote_header_id 		          := p_qte_header_rec.quote_header_id;
        l_Qte_Line_Tbl(l_index).quote_line_id 			     := row.quote_line_id;
        l_Qte_Line_Tbl(l_index).OPERATION_CODE 			     := 'UPDATE';
        l_Qte_Line_Tbl(l_index).quantity 			          := x_output_quantity; --row.quantity; added by 6661597
        l_Qte_Line_Tbl(l_index).uom_code 			          := row.uom_code;

        l_Qte_Line_dtl_Tbl(l_index).OPERATION_CODE 		     := 'UPDATE';
        l_Qte_Line_dtl_Tbl(l_index).quote_line_detail_id	     := row.quote_line_detail_id;
        l_Qte_Line_dtl_Tbl(l_index).quote_line_id                := row.quote_line_id;
        l_Qte_Line_dtl_Tbl(l_index).complete_configuration_flag  := p_config_rec.complete_configuration_flag;
        l_Qte_Line_dtl_Tbl(l_index).valid_configuration_flag     := p_config_rec.valid_configuration_flag;
        l_qte_line_dtl_tbl(l_index).bom_sort_order               := row.bom_sort_order;
        l_qte_line_dtl_tbl(l_index).config_delta                 := row.config_delta;
	   l_qte_line_dtl_tbl(l_index).config_instance_name         := row.name;

        --Updating order_line_type_id value based on CZ line_type value

        IF row.line_type IS NOT NULL THEN

             l_Qte_Line_Tbl(l_index).order_line_type_id     :=  row.line_type;
             l_Qte_Line_Tbl(l_index).line_type_source_flag  :=  'C';

        ELSIF row.line_type_source_flag = 'C' THEN

             l_Qte_Line_Tbl(l_index).order_line_type_id     :=  NULL;

        END IF;



    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add( 'Get_Config_details: After C_config_details_upd cursor LOOP l_index: '|| l_index);
        aso_debug_pub.add( 'ASO_CFG_INT: Get_Config_details: Before C_config_details_del cursor LOOP');

    END IF;

    FOR row IN C_config_details_del( p_config_hdr_id, p_config_rev_nbr )
    LOOP

        l_index := l_index + 1;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Get_Config_details: Inside C_config_details_del cursor LOOP');
            aso_debug_pub.add('Get_Config_Details: l_index:       '|| l_index);
   	       aso_debug_pub.add('Get_Config_Details: quote_line_id: '|| row.quote_line_id);
        END IF;

        l_Qte_Line_Tbl(l_index).OPERATION_CODE      := 'DELETE';
        l_Qte_Line_Tbl(l_index).quote_line_id 		:= row.quote_line_id;

    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('ASO_CFG_INT: Get_Config_details: After C_config_details_del cursor LOOP l_index: '|| l_index);

        aso_debug_pub.add('ASO_CFG_INT: Get_Config_details: l_quote_type: '|| l_quote_type);
        aso_debug_pub.add('Get_Config_details: p_control_rec.CALCULATE_TAX_FLAG: '|| p_control_rec.CALCULATE_TAX_FLAG);
        aso_debug_pub.add('Get_Config_details: p_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG: '|| p_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG);
        aso_debug_pub.add('Get_Config_details: p_control_rec.pricing_request_type: '|| p_control_rec.pricing_request_type);
        aso_debug_pub.add('Get_Config_details: p_control_rec.header_pricing_event: '|| p_control_rec.header_pricing_event);

    END IF;


    --Populate quote header record

    l_qte_header_rec                              := p_qte_header_rec;
    l_qte_header_rec.last_update_date             := l_last_update_date;
    l_qte_header_rec.CALL_BATCH_VALIDATION_FLAG   := FND_API.G_FALSE;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add( 'Get_Config_details: Before call to Update Quote table count');
	   aso_debug_pub.add( 'Get_Config_details: l_Qte_Line_Tbl.count:     '||l_Qte_Line_Tbl.count);
	   aso_debug_pub.add( 'Get_Config_details: l_Qte_Line_Dtl_Tbl.count: '||l_Qte_Line_Dtl_Tbl.count);

    END IF;
	--ER 7428770  set quote_source_code to null to avoid the validation made in aso_quote_pub.update_quote
	--applies to quotes created from script
	If l_qte_header_rec.quote_source_code = 'ASO' Then
	l_qte_header_rec.quote_source_code := '';
	End If;

    ASO_QUOTE_PUB.Update_Quote(
                p_api_version_number 		=> 1.0,
                p_init_msg_list         	=> FND_API.G_FALSE,
                p_commit              		=> FND_API.G_FALSE,
                p_control_rec           	=> p_control_rec,
                p_qte_header_rec     		=> l_qte_header_rec,
                p_hd_tax_detail_tbl 		=> l_hd_tax_detail_tbl,
                --P_hd_Shipment_Tbl   		=> l_Shipment_tbl,
                P_Qte_Line_Tbl          	=> l_Qte_Line_Tbl,
	           P_Qte_Line_Dtl_Tbl		     => l_Qte_Line_Dtl_Tbl,
                P_ln_Payment_Tbl        	=> l_ln_Payment_Tbl,
                --P_ln_Tax_Detail_Tbl 		=> l_ln_tax_detail_tbl,
                x_Qte_Header_Rec        	=> lx_qte_header_rec,
                X_Qte_Line_Tbl          	=> lx_Qte_Line_Tbl,
                X_Qte_Line_Dtl_Tbl      	=> lx_Qte_Line_Dtl_Tbl,
                X_hd_Price_Attributes_Tbl 	=> lx_hd_Price_Attr_Tbl,
                X_hd_Payment_Tbl        	=> lx_hd_Payment_Tbl,
                X_hd_Shipment_Tbl       	=> lx_hd_Shipment_Tbl,
                X_hd_Freight_Charge_Tbl 	=> lx_hd_Freight_Charge_Tbl,
                X_hd_Tax_Detail_Tbl     	=> lx_hd_Tax_Detail_Tbl,
                x_Line_Attr_Ext_Tbl     	=> lx_Line_Attr_Ext_Tbl,
                X_line_rltship_tbl      	=> lx_line_rltship_tbl,
                X_Price_Adjustment_Tbl  	=> lx_Price_Adjustment_Tbl,
                X_Price_Adj_Attr_Tbl    	=> lx_Price_Adj_Attr_Tbl,
                X_Price_Adj_Rltship_Tbl 	=> lx_Price_Adj_Rltship_Tbl,
                X_ln_Price_Attributes_Tbl 	=> lx_ln_Price_Attr_Tbl,
                X_ln_Payment_Tbl        	=> lx_ln_Payment_Tbl,
                X_ln_Shipment_Tbl       	=> lx_ln_Shipment_Tbl,
                X_ln_Freight_Charge_Tbl 	=> lx_ln_Freight_Charge_Tbl,
                X_ln_Tax_Detail_Tbl     	=> lx_ln_Tax_Detail_Tbl,
                X_Return_Status         	=> x_Return_Status,
                X_Msg_Count             	=> x_Msg_Count,
                X_Msg_Data              	=> x_Msg_Data);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Get_config_details: After call to Update_quote x_Return_Status: ' || x_Return_Status);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Get_config_details: Before deleting the previous version from CZ schema.');
        END IF;

        IF ((p_config_rec.config_header_id    <> FND_API.G_Miss_num  AND
             p_config_rec.config_revision_num <> FND_API.G_Miss_Num) AND
            (p_config_rec.config_header_id    IS NOT NULL   AND
             p_config_rec.config_revision_num IS NOT NULL)) AND
            (p_config_rec.config_header_id    <> p_config_hdr_id  OR
             p_config_rec.config_revision_num <> p_config_rev_nbr) THEN

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Get_config_details: A previous version exist for this configuration so deleting it from CZ');
             END IF;

              ASO_CFG_INT.DELETE_CONFIGURATION( P_API_VERSION_NUMBER  => 1.0,
                                                P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                P_CONFIG_HDR_ID       => p_config_rec.config_header_id,
                                                P_CONFIG_REV_NBR      => p_config_rec.config_revision_num,
                                                X_RETURN_STATUS       => lx_return_status,
                                                X_MSG_COUNT           => x_msg_count,
                                                X_MSG_DATA            => x_msg_data);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION: x_Return_Status: ' || lx_Return_Status);
              END IF;

              IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  x_return_status := lx_return_status;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                     FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                     FND_MSG_PUB.ADD;
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

              END IF;

        END IF;

    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;

    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Get_config_details: Before deleting records from aso_line_relationships table');
    END IF;

    DELETE aso_line_relationships
    WHERE  line_relationship_id IN (SELECT  line_relationship_id
                                    FROM    aso_line_relationships a
                                    WHERE   a.relationship_type_code = 'CONFIG'
                                    START WITH a.quote_line_id = p_config_rec.quote_line_id
                                    CONNECT BY PRIOR  a.related_quote_line_id = a.quote_line_id);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Get_config_details: After deleting records from aso_line_relationships table');
    END IF;

    G_rtln_tbl := G_MISS_rtln_tbl;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('P1 bug 2267635 ASO_CFG_INT: Get_config_details: Before call to populate_rtln_Tbl');
    END IF;

    populate_rtln_Tbl( p_quote_header_id    => p_qte_header_rec.quote_header_id,
				   p_quote_line_id      => p_config_rec.quote_line_id,
				   p_config_hdr_id	    => p_config_hdr_id,
				   p_config_rev_nbr	    => p_config_rev_nbr );


    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('P1 bug 22676353 ASO_CFG_INT: Get_config_details: After call to populate_rtln_Tbl');

        /* commented for Bug 23024914 , replace G_rtln_tbl1 with G_rtln_tbl
		FOR p IN  G_rtln_tbl1.first..G_rtln_tbl1.last LOOP  */

		FOR p IN  G_rtln_tbl.first..G_rtln_tbl.last LOOP

   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').quote_line_id:         '|| G_rtln_tbl(p).quote_line_id);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').parent_config_item_id: '|| G_rtln_tbl(p).parent_config_item_id);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').config_item_id:        '|| G_rtln_tbl(p).config_item_id);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').inventory_item_id:     '|| G_rtln_tbl(p).inventory_item_id);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').organization_id:       '|| G_rtln_tbl(p).organization_id);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').component_code:        '|| G_rtln_tbl(p).component_code);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').quantity:              '|| G_rtln_tbl(p).quantity);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').included_flag:         '|| G_rtln_tbl(p).included_flag);
   		   aso_debug_pub.add( 'Get_config_details: G_rtln_tbl('||p||').created_flag:          '|| G_rtln_tbl(p).created_flag);

        END LOOP;

        aso_debug_pub.add('ASO_CFG_INT: Get_config_details: Before call to Create_Relationship procedure');

    END IF;

    Create_Relationship( parent_quote_line_id  =>  G_rtln_tbl(1).quote_line_id,
                         p_config_item_id	  =>  G_rtln_tbl(1).config_item_id,
				     x_return_status	  =>  x_return_status,
				     x_msg_count		  =>  x_msg_count,
				     x_msg_data		  =>  x_msg_data );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('Get_config_details: After call to Create_Relationship: x_return_status: '|| x_return_status);

    END IF;

    -- Check return status from the above procedure call

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Get_config_details: Before deleting the previous version from CZ schema.');
    END IF;

    IF ((p_config_rec.config_header_id    <> FND_API.G_Miss_num  AND
         p_config_rec.config_revision_num <> FND_API.G_Miss_Num) AND
        (p_config_rec.config_header_id    IS NOT NULL   AND
         p_config_rec.config_revision_num IS NOT NULL)) AND
        (p_config_rec.config_header_id    <> p_config_hdr_id  OR
         p_config_rec.config_revision_num <> p_config_rev_nbr) THEN

         open c_config_exist_in_cz(p_config_rec.config_header_id, p_config_rec.config_revision_num);
         fetch c_config_exist_in_cz into l_old_config_hdr_id;
         if c_config_exist_in_cz%found then

             close c_config_exist_in_cz;

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Get_config_details: A previous version exist for this configuration so deleting it from CZ');
             END IF;

             ASO_CFG_INT.DELETE_CONFIGURATION( P_API_VERSION_NUMBER  => 1.0,
                                               P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                               P_CONFIG_HDR_ID       => p_config_rec.config_header_id,
                                               P_CONFIG_REV_NBR      => p_config_rec.config_revision_num,
                                               X_RETURN_STATUS       => lx_return_status,
                                               X_MSG_COUNT           => x_msg_count,
                                               X_MSG_DATA            => x_msg_data);

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION: x_Return_Status: ' || lx_Return_Status);
             END IF;

             IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 x_return_status := lx_return_status;
                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                    FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                    FND_MSG_PUB.ADD;
                 END IF;

                 RAISE FND_API.G_EXC_ERROR;

             END IF;

         else
             close c_config_exist_in_cz;
         end if;

    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add( 'ASO_CFG_INT: GET_CONFIG_DETAILS: Finish %%%%%%%%%%%%%%%%%%%', 1, 'Y' );
    END IF;

    EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN

           open c_config_exist_in_cz(p_config_hdr_id, p_config_rev_nbr);
           fetch c_config_exist_in_cz into l_old_config_hdr_id;

           if c_config_exist_in_cz%found then

               close c_config_exist_in_cz;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Get_config_details: A previous version exist for this configuration so deleting it from CZ');
               END IF;

               ASO_CFG_INT.DELETE_CONFIGURATION_AUTO( P_API_VERSION_NUMBER  => 1.0,
                                                      P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                      P_CONFIG_HDR_ID       => p_config_hdr_id,
                                                      P_CONFIG_REV_NBR      => p_config_rev_nbr,
                                                      X_RETURN_STATUS       => lx_return_status,
                                                      X_MSG_COUNT           => x_msg_count,
                                                      X_MSG_DATA            => x_msg_data);

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION: x_Return_Status: ' || lx_Return_Status);
               END IF;

               IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                     x_return_status := lx_return_status;
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                      FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                      FND_MSG_PUB.ADD;
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;

               END IF;

           else
               close c_config_exist_in_cz;
           end if;

           ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           open c_config_exist_in_cz(p_config_hdr_id, p_config_rev_nbr);
           fetch c_config_exist_in_cz into l_old_config_hdr_id;

           if c_config_exist_in_cz%found then

               close c_config_exist_in_cz;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Get_config_details: A previous version exist for this configuration so deleting it from CZ');
               END IF;

               ASO_CFG_INT.DELETE_CONFIGURATION_AUTO( P_API_VERSION_NUMBER  => 1.0,
                                                      P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                      P_CONFIG_HDR_ID       => p_config_hdr_id,
                                                      P_CONFIG_REV_NBR      => p_config_rev_nbr,
                                                      X_RETURN_STATUS       => lx_return_status,
                                                      X_MSG_COUNT           => x_msg_count,
                                                      X_MSG_DATA            => x_msg_data);

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION: x_Return_Status: ' || lx_Return_Status);
               END IF;

               IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                   x_return_status := lx_return_status;
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                      FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                      FND_MSG_PUB.ADD;
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;

               END IF;

           else
               close c_config_exist_in_cz;
           end if;

           ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN OTHERS THEN

           open c_config_exist_in_cz(p_config_hdr_id, p_config_rev_nbr);
           fetch c_config_exist_in_cz into l_old_config_hdr_id;

           if c_config_exist_in_cz%found then

               close c_config_exist_in_cz;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Get_config_details: A previous version exist for this configuration so deleting it from CZ');
               END IF;

               ASO_CFG_INT.DELETE_CONFIGURATION_AUTO( P_API_VERSION_NUMBER  => 1.0,
                                                      P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                      P_CONFIG_HDR_ID       => p_config_hdr_id,
                                                      P_CONFIG_REV_NBR      => p_config_rev_nbr,
                                                      X_RETURN_STATUS       => lx_return_status,
                                                      X_MSG_COUNT           => x_msg_count,
                                                      X_MSG_DATA            => x_msg_data);

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION: x_Return_Status: ' || lx_Return_Status);
               END IF;

               IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                   x_return_status := lx_return_status;
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                      FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                      FND_MSG_PUB.ADD;
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;

               END IF;

           else
               close c_config_exist_in_cz;
           end if;

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

END Get_Config_Details;


-- This pricing_callback procedure needs the followings things
-- The cz_prc_callback_util.root_bom_config_item_id function will always return the config_item_id of the
-- root model no matter what the price_type is.
PROCEDURE Pricing_Callback( p_config_session_key    IN      VARCHAR2,
                            p_price_type            IN      VARCHAR2,
                            x_total_price           OUT NOCOPY /* file.sql.39 change */     NUMBER )
IS

  Cursor c_options   is
      Select item_key, cz_atp_callback_util.inv_item_id_from_item_key(item_key) item_id,
             quantity, uom_code,substr(item_key, 1,instr( item_key, ':' ,1)-1) component_code,
             config_item_id
      from   cz_pricing_structures
      Where  configurator_session_key = p_config_session_key
      and    item_key_type = 1;

  Cursor c_quote_hdr_id ( p_quote_line_id NUMBER  ) is
      select a.quote_header_id, a.price_list_id, b.org_id
      from   aso_quote_lines_all a, aso_quote_headers_all b
      where  a.quote_header_id = b.quote_header_id
	 and    a.quote_line_id = p_quote_line_id;

  Cursor c_config_header_id ( p_quote_line_id NUMBER  ) is
      Select config_header_id
      from   aso_quote_line_details
      where  quote_line_id = p_quote_line_id;

  Cursor c_pricelist_id ( p_config_item_id NUMBER, p_config_header_id NUMBER ) is
     Select qtl.price_list_id, qtl.quote_line_id
     from   aso_quote_lines_all qtl,
            aso_quote_line_details qtl_dtl
     where  qtl.quote_line_id        = qtl_dtl.quote_line_id
     and    qtl_dtl.config_item_id   = p_config_item_id
     and    qtl_dtl.config_header_id = p_config_header_id
     and    ref_line_id is not null;

  Cursor c_config_line(p_quote_line_id NUMBER, p_config_header_id NUMBER) is
     Select quote_line_id
     from   aso_quote_line_details
     where  quote_line_id    = p_quote_line_id
     and    config_header_id = p_config_header_id
     and    ref_line_id is not null;

  Cursor c_get_pricing_structure(p_session_key VARCHAR2) is
     select list_price,selling_price,config_item_id
     from cz_pricing_structures
     where configurator_session_key = p_session_key;

  Cursor c_charge_periodicity_code(p_inventory_item_id number, p_organization_id number) is
  select charge_periodicity_code
  from mtl_system_items_b
  where inventory_item_id = p_inventory_item_id
  and organization_id = p_organization_id;

    l_pricing_control_rec        ASO_PRICING_INT.Pricing_Control_rec_Type;
    l_qte_header_rec             ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_hd_shipment_rec            ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_hd_shipment_tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_hd_price_attr_tbl          ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_hd_price_attr_rec          ASO_QUOTE_PUB.Price_Attributes_Rec_Type;
    l_qte_line_rec               ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_qte_line_tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_dtl_rec           ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_qte_line_dtl_tbl           ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_l_qte_line_dtl_tbl         ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_ln_shipment_rec            ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_ln_shipment_tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_l_ln_shipment_tbl          ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_ln_price_attr_tbl          ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_l_ln_price_attr_tbl        ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_ln_price_attr_rec          ASO_QUOTE_PUB.Price_Attributes_rec_Type;
    l_price_adj_tbl              ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    l_l_price_adj_tbl            ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    l_line_rltship_tbl           ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;

    lx_qte_header_rec            ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_qte_line_tbl              ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_qte_line_dtl_tbl          ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lx_price_adj_tbl             ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    lx_price_adj_attr_tbl        ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    lx_price_adj_rltship_tbl     ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

    lx_return_status             VARCHAR2(1);
    lx_msg_count                 NUMBER;
    lx_msg_data                  VARCHAR2(2000);

    l_model_quote_line_id        NUMBER;
    l_quote_line_id              NUMBER;
    l_c_quote_line_id            NUMBER;
    l_quote_header_id            NUMBER;
    l_model_price_list_id        NUMBER;
    i                            NUMBER;
    record_count1                NUMBER := 0;
    l_line_price_list_id         NUMBER;
    l_file                       VARCHAR2(200);
    l_mymsg                      VARCHAR2(2000);
    l_root_model_config_item_id  NUMBER;
    l_config_header_id           NUMBER;
    l_count                      NUMBER := 0;
    l_org_id                     NUMBER;
    l_master_organization_id     NUMBER;

         -- added by 6661597
  l_validated_quantity    NUMBER;
  l_primary_quantity       NUMBER;
  l_qty_return_status      VARCHAR2(1);
  p_item_id                NUMBER;
  p_organization_id        NUMBER;
  p_uom_code               VARCHAR2(50);
  p_input_quantity         NUMBER;
  x_output_quantity        NUMBER;
  x_ret_Stat               VARCHAR2(50);
-- end 6661597

Begin
    /*
    aso_debug_pub.g_debug_flag := 'Y';
    aso_debug_pub.SetDebugLevel(10);
    aso_debug_pub.Initialize;
    l_file    := ASO_DEBUG_PUB.Set_Debug_Mode('FILE');
    aso_debug_pub.debug_on;
    */

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: Start %%%%%%%%%%%%%%%%%%%%' , 1, 'Y' );
        aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: p_config_session_key: '|| p_config_session_key);
        aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: p_price_type:         '|| p_price_type);

    END IF;

    -- Store the derived model item quote_line_id from the p_config_session_key for subsequent use

    l_model_quote_line_id := to_number( substr(p_config_session_key, 1,instr( p_config_session_key, '-') - 1));

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('PRICING CALLBACK: l_model_quote_line_id: ' || l_model_quote_line_id);
    END IF;

    OPEN c_quote_hdr_id( l_model_quote_line_id );
    FETCH c_quote_hdr_id into l_quote_header_id, l_model_price_list_id, l_org_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('PRICING CALLBACK: l_quote_header_id:     ' || l_quote_header_id);
        aso_debug_pub.add('PRICING CALLBACK: l_model_price_list_id: ' || l_model_price_list_id);
        aso_debug_pub.add('PRICING CALLBACK: l_org_id:              ' || l_org_id);
    END IF;

    IF c_quote_hdr_id%FOUND THEN

        l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row ( l_quote_header_id );

        -- The following function returns all other rows of the quote which do not belong to
        -- this configuration plus the model line itself

        l_qte_line_tbl   := Query_Qte_Line_Rows( l_quote_header_id,l_model_quote_line_id );

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('PRICING CALLBACK: After call to Query_Qte_Line_Rows');
            aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl.count: '|| l_qte_line_tbl.count);
        END IF;

	   l_master_organization_id := oe_sys_parameters.value(param_name => 'MASTER_ORGANIZATION_ID', p_org_id => l_org_id);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('PRICING CALLBACK: l_master_organization_id: ' || l_master_organization_id);
        END IF;

    ELSE

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: c_quote_hdr_id NOT FOUND.');
        END IF;

    END IF;

    CLOSE c_quote_hdr_id;

    --Get the config_header_id of the model line. The config_header_id will be null in
    --case it is first time configuration

    OPEN c_config_header_id( l_model_quote_line_id );
    FETCH c_config_header_id into l_config_header_id;
    CLOSE c_config_header_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: l_config_header_id: ' || l_config_header_id);
    END IF;

    IF p_price_type = cz_prc_callback_util.g_prc_type_list THEN

         FOR row IN C_options LOOP

             IF aso_debug_pub.g_debug_flag = 'Y' THEN

                 aso_debug_pub.add( 'PRICING CALLBACK: item_key:       ' || row.item_key);
                 aso_debug_pub.add( 'PRICING CALLBACK: (inv) item_id:  ' || row.item_id);
                 aso_debug_pub.add( 'PRICING CALLBACK: quantity:       ' || row.quantity);
                 aso_debug_pub.add( 'PRICING CALLBACK: uom_code:       ' || row.uom_code);
                 aso_debug_pub.add( 'PRICING CALLBACK: component_code: ' || row.component_code);
                 aso_debug_pub.add( 'PRICING CALLBACK: config_item_id: ' || row.config_item_id);

             END IF;

             record_count1 := record_count1 + 1;

	          -- 6661597
         p_item_id:=row.item_id;
	       p_organization_id:=l_master_organization_id;
	       p_uom_code:=row.uom_code;
	       p_input_quantity:=row.quantity;
         x_output_quantity:=FND_API.G_MISS_NUM;

        -- inv quantity validation 6661597
         IF (p_input_quantity is not null AND p_input_quantity <> FND_API.G_MISS_NUM) THEN
                inv_decimals_pub.validate_quantity(
		               p_item_id          => p_item_id ,
			             p_organization_id  => p_organization_id   ,
	                 p_input_quantity   => p_input_quantity,
		               p_uom_code         => p_uom_code,
			             x_output_quantity  => l_validated_quantity,
	                 x_primary_quantity => l_primary_quantity,
		               x_return_status    => x_ret_Stat);

		            if x_ret_Stat = 'E' THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_FRACTIONAL_QUANTITY');
		                FND_MSG_PUB.ADD;
		              END IF;
		              RAISE FND_API.G_EXC_ERROR;
		            elsif x_ret_Stat = 'W' then
		              x_output_quantity:=   l_validated_quantity;
		            else
		              x_output_quantity:=p_input_quantity;
		          end if;
            END IF; -- quantity not null

             l_qte_line_tbl(record_count1).inventory_item_id   := row.item_id;
             l_qte_line_tbl(record_count1).quantity            := x_output_quantity;--row.quantity; 6661597
             l_qte_line_tbl(record_count1).uom_code            := row.uom_code;
             l_qte_line_dtl_tbl(record_count1).config_item_id  := row.config_item_id;

		   open c_charge_periodicity_code(row.item_id, l_master_organization_id);
		   fetch c_charge_periodicity_code into l_qte_line_tbl(record_count1).charge_periodicity_code;
		   close c_charge_periodicity_code;

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('|| record_count1 ||').charge_periodicity_code: '|| l_qte_line_tbl(record_count1).charge_periodicity_code);
		   End if;

             IF l_config_header_id IS NOT NULL THEN

                OPEN c_pricelist_id(row.config_item_id, l_config_header_id);
                FETCH c_pricelist_id into l_line_price_list_id, l_quote_line_id;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('PRICING CALLBACK: l_line_price_list_id: ' || l_line_price_list_id);
                    aso_debug_pub.add('PRICING CALLBACK: l_quote_line_id:      ' || l_quote_line_id);
                END IF;

                IF c_pricelist_id%FOUND THEN

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('PRICING CALLBACK: Inside c_pricelist_id cursor FOUND');
                    END IF;

                    IF l_line_price_list_id IS NOT NULL THEN
                         l_qte_line_tbl(record_count1).price_list_id := l_line_price_list_id;
                    ELSE
                         l_qte_line_tbl(record_count1).price_list_id := l_model_price_list_id;
                    END IF;

                    l_qte_line_tbl(record_count1).quote_line_id     := l_quote_line_id;

                ELSE

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('PRICING CALLBACK: Inside ELSE c_pricelist_id cursor FOUND');
                    END IF;

                    l_qte_line_tbl(record_count1).quote_line_id := 0;
                    l_qte_line_tbl(record_count1).price_list_id := l_model_price_list_id;

                END IF;

                CLOSE c_pricelist_id;

             ELSE

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('PRICING CALLBACK: Inside ELSE l_config_header_id IS NOT NULL');
                END IF;

                l_qte_line_tbl(record_count1).quote_line_id := 0;
                l_qte_line_tbl(record_count1).price_list_id := l_model_price_list_id;

             END IF;

         END LOOP;

         l_pricing_control_rec.request_type   :=  'ASO';
         l_pricing_control_rec.pricing_event  :=  'PRICE';
         l_pricing_control_rec.price_mode     :=  'QUOTE_LINE';

    ELSE

         -- Get the config_item_id of the root model
         l_root_model_config_item_id := cz_prc_callback_util.root_bom_config_item_id(p_config_session_key);

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add( 'ASO_CFG_INT: PRICING CALLBACK: l_root_model_config_item_id: ' || l_root_model_config_item_id);
         END IF;

         record_count1 := l_qte_line_tbl.count;
         l_count := l_qte_line_tbl.count;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: l_count: ' || l_count);
         END IF;

         FOR row IN C_options LOOP

             IF aso_debug_pub.g_debug_flag = 'Y' THEN

                 aso_debug_pub.add( 'PRICING CALLBACK: item_key:       ' || row.item_key);
                 aso_debug_pub.add( 'PRICING CALLBACK: (inv) item_id:  ' || row.item_id);
                 aso_debug_pub.add( 'PRICING CALLBACK: quantity:       ' || row.quantity);
                 aso_debug_pub.add( 'PRICING CALLBACK: uom_code:       ' || row.uom_code);
                 aso_debug_pub.add( 'PRICING CALLBACK: component_code: ' || row.component_code);
                 aso_debug_pub.add( 'PRICING CALLBACK: config_item_id: ' || row.config_item_id);

             END IF;

	         -- 6661597
         p_item_id:=row.item_id;
	       p_organization_id:=l_master_organization_id;
	       p_uom_code:=row.uom_code;
	       p_input_quantity:=row.quantity;
         x_output_quantity:=FND_API.G_MISS_NUM;

        -- inv quantity validation 6661597
         IF (p_input_quantity is not null AND p_input_quantity <> FND_API.G_MISS_NUM) THEN
                inv_decimals_pub.validate_quantity(
		               p_item_id          => p_item_id ,
			             p_organization_id  => p_organization_id   ,
	                 p_input_quantity   => p_input_quantity,
		               p_uom_code         => p_uom_code,
			             x_output_quantity  => l_validated_quantity,
	                 x_primary_quantity => l_primary_quantity,
		               x_return_status    => x_ret_Stat);

		            if x_ret_Stat = 'E' THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_FRACTIONAL_QUANTITY');
		                FND_MSG_PUB.ADD;
		              END IF;
		              RAISE FND_API.G_EXC_ERROR;
		            elsif x_ret_Stat = 'W' then
		              x_output_quantity:=   l_validated_quantity;
		            else
		              x_output_quantity:=p_input_quantity;
		          end if;
            END IF; -- quantity not null

             IF row.config_item_id <> l_root_model_config_item_id THEN

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('PRICING CALLBACK: It is a child line');
                 END IF;

                 record_count1 := record_count1 + 1;

                 l_qte_line_tbl(record_count1).inventory_item_id     := row.item_id;
                 l_qte_line_tbl(record_count1).quantity              := x_output_quantity; --row.quantity; 6661597
                 l_qte_line_tbl(record_count1).uom_code              := row.uom_code;
                 l_qte_line_dtl_tbl(record_count1).config_item_id    := row.config_item_id;

                 IF l_config_header_id IS NOT NULL THEN

                     OPEN c_pricelist_id(row.config_item_id, l_config_header_id);
                     FETCH c_pricelist_id into l_line_price_list_id, l_quote_line_id;

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('PRICING CALLBACK: l_line_price_list_id: ' || l_line_price_list_id);
                         aso_debug_pub.add('PRICING CALLBACK: l_quote_line_id:      ' || l_quote_line_id);
                     END IF;

                     IF c_pricelist_id%FOUND THEN

                         IF aso_debug_pub.g_debug_flag = 'Y' THEN
                             aso_debug_pub.add('PRICING CALLBACK: Inside c_pricelist_id cursor FOUND');
                         END IF;

                         IF l_line_price_list_id IS NOT NULL THEN
                              l_qte_line_tbl(record_count1).price_list_id := l_line_price_list_id;
                         ELSE
                              l_qte_line_tbl(record_count1).price_list_id := l_model_price_list_id;
                         END IF;
                         l_qte_line_tbl(record_count1).quote_line_id     := l_quote_line_id;

                     ELSE

                         IF aso_debug_pub.g_debug_flag = 'Y' THEN
                             aso_debug_pub.add('PRICING CALLBACK: Inside ELSE c_pricelist_id cursor FOUND');
                         END IF;

                         l_qte_line_tbl(record_count1).quote_line_id := 0;
                         l_qte_line_tbl(record_count1).price_list_id := l_model_price_list_id;

                     END IF;

                     CLOSE c_pricelist_id;

                 ELSE

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('PRICING CALLBACK: Inside ELSE l_config_header_id IS NOT NULL');
                     END IF;

                     l_qte_line_tbl(record_count1).quote_line_id := 0;
                     l_qte_line_tbl(record_count1).price_list_id := l_model_price_list_id;

                 END IF;

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('PRICING CALLBACK: It is a child line: After populating the child line information');
                 END IF;

             ELSE

                 record_count1 := record_count1 + 1;
                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('PRICING CALLBACK: ELSE cond of row.config_item_id <> l_root_model_config_item_id: It is model line');
                 END IF;

                 l_qte_line_tbl(record_count1).inventory_item_id   :=  row.item_id;
                 l_qte_line_tbl(record_count1).quantity            :=  x_output_quantity;--row.quantity;
                 l_qte_line_tbl(record_count1).uom_code            :=  row.uom_code;
                 l_qte_line_tbl(record_count1).price_list_id       :=  l_model_price_list_id;
                 l_qte_line_tbl(record_count1).quote_line_id       :=  l_model_quote_line_id;
                 l_qte_line_dtl_tbl(record_count1).config_item_id  :=  row.config_item_id;

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('PRICING CALLBACK: It is model line: After populating the model information');
                 END IF;

             END IF;

		   open c_charge_periodicity_code(row.item_id, l_master_organization_id);
		   fetch c_charge_periodicity_code into l_qte_line_tbl(record_count1).charge_periodicity_code;
		   close c_charge_periodicity_code;

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('|| record_count1 ||').charge_periodicity_code: '|| l_qte_line_tbl(record_count1).charge_periodicity_code);
		   End if;

         END LOOP;

         l_pricing_control_rec.request_type   :=  'ASO';
         l_pricing_control_rec.pricing_event  :=  'BATCH';
         l_pricing_control_rec.price_mode     :=  'ENTIRE_QUOTE';

    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('PRICING CALLBACK: After C_options cursor loop: l_qte_line_tbl.count: '||l_qte_line_tbl.count);

        FOR i IN 1..l_qte_line_tbl.count LOOP

             aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('||i||').quote_line_id:     '|| l_qte_line_tbl(i).quote_line_id);
             aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('||i||').inventory_item_id: '|| l_qte_line_tbl(i).inventory_item_id);
             aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('||i||').quantity:          '|| l_qte_line_tbl(i).quantity);
             aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('||i||').uom_code:          '|| l_qte_line_tbl(i).uom_code);
             aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('||i||').price_list_id:     '|| l_qte_line_tbl(i).price_list_id);
             aso_debug_pub.add('PRICING CALLBACK: l_qte_line_tbl('||i||').charge_periodicity_code: '|| l_qte_line_tbl(i).charge_periodicity_code);
             --aso_debug_pub.add('PRICING CALLBACK: l_qte_line_dtl_tbl('||i||').config_item_id:'|| l_qte_line_dtl_tbl(i).config_item_id);

        END LOOP;

    END IF;


    --Set the control record parameter values

    l_pricing_control_rec.price_config_flag  :=  'Y';

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

       aso_debug_pub.add('l_pricing_control_rec.request_type:      '||l_pricing_control_rec.request_type);
       aso_debug_pub.add('l_pricing_control_rec.pricing_event:     '||l_pricing_control_rec.pricing_event);
       aso_debug_pub.add('l_pricing_control_rec.price_mode:        '||l_pricing_control_rec.price_mode);
       aso_debug_pub.add('l_pricing_control_rec.price_config_flag: '||l_pricing_control_rec.price_config_flag);

       aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: Before call to ASO_PRICING_INT.Pricing_Order');

    END IF;

    ASO_PRICING_INT.Pricing_Order(
         P_Api_Version_Number    => 1.0,
         P_Init_Msg_List         => FND_API.G_TRUE,
         P_Commit                => FND_API.G_FALSE,
          p_control_rec            => l_pricing_control_rec,
          p_qte_header_rec         => l_qte_header_rec,
          p_hd_shipment_rec        => l_hd_shipment_rec,
          p_hd_price_attr_tbl  => l_hd_price_attr_tbl,
          p_qte_line_tbl           => l_qte_line_tbl,
          p_line_rltship_tbl        => l_line_rltship_tbl,
          p_qte_line_dtl_tbl       => l_l_qte_line_dtl_tbl,
          p_ln_shipment_tbl       => l_l_ln_shipment_tbl,
          p_ln_price_attr_tbl  => l_l_ln_price_attr_tbl,
         --p_price_adj_tbl       => l_l_price_adj_tbl,
          x_qte_header_rec         => lx_qte_header_rec,
          x_qte_line_tbl          => lx_qte_line_tbl,
          x_qte_line_dtl_tbl       => lx_qte_line_dtl_tbl,
          x_price_adj_tbl           => lx_price_adj_tbl,
          x_price_adj_attr_tbl    => lx_price_adj_attr_tbl,
          x_price_adj_rltship_tbl => lx_price_adj_rltship_tbl,
          x_return_status           => lx_return_status     ,
          x_msg_count             => lx_msg_count,
          x_msg_data              => lx_msg_data
         );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('PRICING CALLBACK: After call to ASO_PRICING_INT.Pricing_Order');
        aso_debug_pub.add('PRICING CALLBACK: lx_return_status:      '|| lx_return_status);
        aso_debug_pub.add('PRICING CALLBACK: lx_msg_count:          '|| lx_msg_count);
        aso_debug_pub.add('PRICING CALLBACK: lx_msg_data:           '|| lx_msg_data);
        aso_debug_pub.add('PRICING CALLBACK: lx_qte_line_tbl.count: '|| lx_qte_line_tbl.count);

    END IF;

    IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        fnd_msg_pub.count_and_get( p_encoded   => 'F',
                                   p_count     => lx_msg_count,
                                   p_data      => lx_msg_data);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN

            aso_debug_pub.add('PRICING CALLBACK: After call to fnd_msg_pub.count_and_get');
            aso_debug_pub.add('PRICING CALLBACK: lx_msg_count: '|| lx_msg_count);
            aso_debug_pub.add('PRICING CALLBACK: lx_msg_data:  '|| lx_msg_data);

        END IF;

        FOR k IN 1 .. lx_msg_count LOOP

           lx_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                           p_encoded   => 'F');

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('PRICING CALLBACK: Inside Loop fnd_msg_pub.get: lx_msg_data: ' ||lx_msg_data);
           END IF;

           l_mymsg := l_mymsg || ' ' || lx_msg_data;

        END LOOP;

    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: l_mymsg: ' || l_mymsg);
    END IF;

    -- set the error message in the model line msg_data field of cz_pricing_structure

    IF lx_return_status <> FND_API.G_RET_STS_SUCCESS AND p_price_type <> 'LIST' THEN

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('PRICING CALLBACK: Inside IF condition lx_return_status <> FND_API.G_RET_STS_SUCCESS');
          END IF;

          UPDATE CZ_PRICING_STRUCTURES
          SET MSG_DATA   =  l_mymsg
          WHERE configurator_session_key = p_config_session_key;
          --AND config_item_id = l_root_model_config_item_id;

    END IF;

    -- Assuming that the ASO_PRICING_INT.Pricing_Order will return the same number of lines send as input.
    -- That means the l_qte_line_tbl and lx_qte_line_tbl will have same count and order else the update of
    -- in cz_pricing_structure will have incorrect result.

    FOR i IN l_count+1..lx_qte_line_tbl.count LOOP


       IF aso_debug_pub.g_debug_flag = 'Y' THEN

           aso_debug_pub.add('PRICING CALLBACK: Inside Loop IF quote_line_id = 0');
           aso_debug_pub.add('PRICING CALLBACK: lx_qte_line_tbl('||i||').quote_line_id:    '|| lx_qte_line_tbl(i).quote_line_id);
           aso_debug_pub.add('PRICING CALLBACK: lx_qte_line_tbl('||i||').line_list_price:  '|| lx_qte_line_tbl(i).line_list_price);
           aso_debug_pub.add('PRICING CALLBACK: lx_qte_line_tbl('||i||').line_quote_price: '|| lx_qte_line_tbl(i).line_quote_price);
           aso_debug_pub.add('PRICING CALLBACK: l_count: '|| l_count);

       END IF;
--bug 17227735  changed the below update stmt to l_qte_line_dtl_tbl(i).config_item_id istead of l_qte_line_dtl_tbl(i - l_count).config_item_id
       UPDATE CZ_PRICING_STRUCTURES
       SET    selling_price  =  lx_qte_line_tbl(i).LINE_QUOTE_PRICE,
              list_price     =  lx_qte_line_tbl(i).line_list_price
       WHERE  configurator_session_key = p_config_session_key
       AND    config_item_id           = l_qte_line_dtl_tbl(i).config_item_id;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('PRICING CALLBACK: After Update sql%rowcount: '|| sql%rowcount);
       END IF;

    END LOOP;

    BEGIN

        SELECT sum(selling_price) INTO x_total_price
        FROM   CZ_PRICING_STRUCTURES
        WHERE  configurator_session_key = p_config_session_key;

        EXCEPTION

            WHEN OTHERS THEN

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: Inside When Others Exception for select sum(selling_price)');
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;


    -- Writing Data from CZ table to ASO Debug File

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

         FOR row IN  c_get_pricing_structure(p_config_session_key) LOOP

                 aso_debug_pub.add('PRICING CALLBACK: Data in CZ_PRICING_STRUCTURES table after update to list and selling prices columns.');
                 aso_debug_pub.add('PRICING CALLBACK: CZ_PRICING_STRUCTURES: config_item_id: ' || row.config_item_id);
                 aso_debug_pub.add('PRICING CALLBACK: CZ_PRICING_STRUCTURES: list_price:     ' || row.list_price);
                 aso_debug_pub.add('PRICING CALLBACK: CZ_PRICING_STRUCTURES: selling_price:  ' || row.selling_price);

         END LOOP;

    END IF;


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK End %%%%%%%%%%%%%%%%%%%%', 1, 'Y' );
    END IF;


    EXCEPTION

         WHEN OTHERS THEN

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('ASO_CFG_INT: PRICING CALLBACK: Inside When Others Exception');
             END IF;

             -- set the error message in the model line msg_data field of cz_pricing_structure
             UPDATE CZ_PRICING_STRUCTURES
             SET    MSG_DATA   =  lx_msg_data
             WHERE  configurator_session_key = p_config_session_key;
             --AND    config_item_id           = l_root_model_config_item_id;

END Pricing_Callback;



-- This function returns all the quote lines which belong to the given quote but not belong
-- to the given configuration plus the root model line of the configuration

FUNCTION Query_Qte_Line_Rows (
      P_Qte_Header_Id      IN  NUMBER,
      p_qte_line_id        IN  NUMBER
      ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type
IS

    cursor c_qte_line is
    select quote_line_id,
           inventory_item_id,
           quantity,
           uom_code,
           price_list_id,
		 charge_periodicity_code
    from  aso_quote_lines_all
    where quote_header_id = p_qte_header_id
    and   quote_line_id not in ( select a.quote_line_id
                                 from aso_quote_line_details a
                                 where (a.config_header_id, a.config_revision_num)
                                 = ( select config_header_id, config_revision_num
                                     from aso_quote_line_details
                                     where quote_line_id  =  p_qte_line_id ))
    and quote_line_id <> p_qte_line_id;


    l_Qte_Line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_Qte_Line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

    l_index                    NUMBER  :=  0;

BEGIN

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_CFG_INT: Query_Qte_Line_Rows: P_Qte_Header_Id: '|| P_Qte_Header_Id);
          aso_debug_pub.add('ASO_CFG_INT: Query_Qte_Line_Rows: p_qte_line_id  : '|| p_qte_line_id );
      END IF;

      FOR line_rec IN c_Qte_Line LOOP

           l_qte_line_rec.QUOTE_LINE_ID           := line_rec.QUOTE_LINE_ID;
           l_qte_line_rec.INVENTORY_ITEM_ID       := line_rec.INVENTORY_ITEM_ID;
           l_qte_line_rec.QUANTITY                := line_rec.QUANTITY;
           l_qte_line_rec.UOM_CODE                := line_rec.UOM_CODE;
           l_qte_line_rec.PRICE_LIST_ID           := line_rec.PRICE_LIST_ID;
           l_qte_line_rec.charge_periodicity_code := line_rec.charge_periodicity_code;

           l_index := l_index + 1;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN

              aso_debug_pub.add('Query_Qte_Line_Rows: line_rec.QUOTE_LINE_ID:     '|| line_rec.QUOTE_LINE_ID);
              aso_debug_pub.add('Query_Qte_Line_Rows: line_rec.QUANTITY:          '|| line_rec.QUANTITY);
              aso_debug_pub.add('Query_Qte_Line_Rows: line_rec.UOM_CODE:          '|| line_rec.UOM_CODE);
              aso_debug_pub.add('Query_Qte_Line_Rows: line_rec.PRICE_LIST_ID:     '|| line_rec.PRICE_LIST_ID);
              aso_debug_pub.add('Query_Qte_Line_Rows: line_rec.INVENTORY_ITEM_ID: '|| line_rec.INVENTORY_ITEM_ID);
              aso_debug_pub.add('Query_Qte_Line_Rows: line_rec.charge_periodicity_code: '|| line_rec.charge_periodicity_code);

          END IF;

          l_Qte_Line_tbl(l_index) := l_Qte_Line_rec;

      END LOOP;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_CFG_INT: Query_Qte_Line_Rows: l_Qte_Line_tbl.count: '|| l_Qte_Line_tbl.count);
      END IF;

      RETURN l_Qte_Line_tbl;

END Query_Qte_Line_Rows;


/*-------------------------------------------------------------------------
Procedure Name : Create_hdr_xml
Description    : creates a batch validation header message.
--------------------------------------------------------------------------*/

PROCEDURE Create_hdr_xml
( p_model_line_id       IN       NUMBER,
  x_xml_hdr             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
  x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2 )
IS

      Cursor C_org_id (p_quote_header_id NUMBER) is
      select org_id from aso_quote_headers_all
      where quote_header_id = p_quote_header_id;

      Cursor c_inv_org_id (p_quote_line_id NUMBER) is
	 select organization_id from aso_quote_lines_all
	 where quote_line_id = p_quote_line_id;

      TYPE param_name_type IS TABLE OF VARCHAR2(25)
      INDEX BY BINARY_INTEGER;

      TYPE param_value_type IS TABLE OF VARCHAR2(255)
      INDEX BY BINARY_INTEGER;

      param_name  param_name_type;
      param_value param_value_type;

      l_rec_index BINARY_INTEGER;

      l_model_line_rec                  ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_model_line_dtl_tbl              ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_org_id                          NUMBER;

      --Configurator specific params
      l_calling_application_id          VARCHAR2(30);
      l_responsibility_id               VARCHAR2(30);
      l_database_id                     VARCHAR2(255);
      l_read_only                       VARCHAR2(30)   :=  null;
      l_save_config_behavior            VARCHAR2(30)   :=  'new_revision';
      l_ui_type                         VARCHAR2(30)   :=  null;
      l_msg_behavior                    VARCHAR2(30)   :=  'brief';
      l_icx_session_ticket              VARCHAR2(200);

      --Order Capture specific parameters
      l_context_org_id                  VARCHAR2(30);
      l_config_creation_date            VARCHAR2(30);
      l_inventory_item_id               VARCHAR2(30);
      l_config_header_id                VARCHAR2(30);
      l_config_rev_nbr                  VARCHAR2(30);
      l_model_quantity                  VARCHAR2(30);
      l_count                           NUMBER;
      --l_validation_org_id             NUMBER;

      --message related
      l_xml_hdr                         VARCHAR2(2000):= '<initialize>';
      l_dummy                           VARCHAR2(500) := NULL;


      -- CZ ER  3177722
      l_config_effective_date_prof   VARCHAR2(1):=nvl(fnd_profile.value('ASO_CONFIG_EFFECTIVE_DATE'),'X');
      l_current_date                              VARCHAR2(30);
      l_effective_date                            DATE;   -- bug 20752067
      x_config_effective_date             DATE;
      x_config_lookup_date               DATE;

  BEGIN
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_hdr_xml Begins.', 1, 'Y');
      END IF;

      --Initialize API return status to SUCCESS
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      l_model_line_rec := aso_utility_pvt.Query_Qte_Line_Row( P_Qte_Line_Id  => p_model_line_id );

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_hdr_xml: After call to aso_utility_pvt.Query_Qte_Line_Row');
      END IF;

      l_model_line_dtl_tbl := aso_utility_pvt.Query_Line_Dtl_Rows( P_Qte_Line_Id => p_model_line_id );

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_hdr_xml: After call to aso_utility_pvt.Query_Line_Dtl_Rows');
      END IF;

      /*  Fix for bug 3998564 */
      --OPEN  C_org_id( l_model_line_rec.quote_header_id);
      --FETCH C_org_id INTO l_org_id;
      --CLOSE C_org_id;
        OPEN  c_inv_org_id( l_model_line_rec.quote_line_id);
	   FETCH c_inv_org_id INTO l_org_id;
	   CLOSE c_inv_org_id;
      /* End of fix for bug 3998564 */

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_hdr_xml: After C_org_id cursor: l_org_id: '|| l_org_id, 1, 'N');
      END IF;

      IF l_org_id IS NULL THEN

       --Commented Code Start Yogeshwar(MOAC)
         /* IF SUBSTRB(USERENV('CLIENT_INFO'),1 ,1) = ' ' THEN
              l_org_id := NULL;
          ELSE
              l_org_id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1,10));
          END IF;
         */
       --Commented Code End Yogeshwar (MOAC)

        L_org_id := l_model_line_rec.org_id;   --New Code Yogeshwar MOAC

      END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_hdr_xml: After Defaulting from client info. l_org_id: '|| l_org_id);
      END IF;

      --Set the values from model_line_rec, model_line_dtl_tbl and org_id
      l_context_org_id        := to_char(l_org_id);
      l_inventory_item_id     := to_char(l_model_line_rec.inventory_item_id);
      l_config_header_id      := to_char(l_model_line_dtl_tbl(1).config_header_id);
      l_config_rev_nbr        := to_char(l_model_line_dtl_tbl(1).config_revision_num);
      l_config_creation_date  := to_char(l_model_line_rec.creation_date,'MM-DD-YYYY-HH24-MI-SS');
      l_model_quantity        := to_char(l_model_line_rec.quantity);
      l_current_date:=  to_char(sysdate,'MM-DD-YYYY-HH24-MI-SS');
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Create_hdr_xml: l_context_org_id      :' || l_context_org_id);
          aso_debug_pub.add('Create_hdr_xml: l_inventory_item_id   :' || l_inventory_item_id);
          aso_debug_pub.add('Create_hdr_xml: l_config_header_id    :' || l_config_header_id);
          aso_debug_pub.add('Create_hdr_xml: l_config_rev_nbr      :' || l_config_rev_nbr);
          aso_debug_pub.add('Create_hdr_xml: l_config_creation_date:' || l_config_creation_date);
          aso_debug_pub.add('Create_hdr_xml: l_model_quantity      :' || l_model_quantity);
	  aso_debug_pub.add('Create_hdr_xml: l_current_date      :' || l_current_date);

      END IF;

      -- Set values from profiles and env. variables.
      l_calling_application_id := fnd_global.resp_appl_id;
      l_responsibility_id      := fnd_global.resp_id;
      l_database_id            := fnd_web_config.database_id;
      l_icx_session_ticket     := cz_cf_api.icx_session_ticket;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Create_hdr_xml: l_calling_application_id:' || l_calling_application_id);
          aso_debug_pub.add('Create_hdr_xml: l_responsibility_id     :' || l_responsibility_id);
          aso_debug_pub.add('Create_hdr_xml: l_database_id           :' || l_database_id);
          aso_debug_pub.add('Create_hdr_xml: l_icx_session_ticket    :' || l_icx_session_ticket);
	   aso_debug_pub.add('Create_hdr_xml:  profile value:'|| l_config_effective_date_prof);

      END IF;

      -- set param_names
      param_name(1)  := 'database_id';
      param_name(2)  := 'context_org_id';
      param_name(3)  := 'config_creation_date';
      param_name(4)  := 'calling_application_id';
      param_name(5)  := 'responsibility_id';
      param_name(6)  := 'model_id';
      param_name(7)  := 'config_header_id';
      param_name(8)  := 'config_rev_nbr';
      param_name(9)  := 'read_only';
      param_name(10) := 'save_config_behavior';
      --param_name(11) := 'ui_type';
      --param_name(12) := 'validation_org_id';
      param_name(11) := 'terminate_msg_behavior';
      param_name(12) := 'model_quantity';
      param_name(13) := 'icx_session_ticket';

      -- Added extra parameters for config effective and lookup date ER 3177722
      param_name(14) := 'config_effective_date';
      param_name(15) := 'config_model_lookup_date';
      l_count := 15;
      --l_count := 13;

      -- set parameter values

      param_value(1)  := l_database_id;
      param_value(2)  := l_context_org_id;
      param_value(3)  := l_config_creation_date;
      param_value(4)  := l_calling_application_id;
      param_value(5)  := l_responsibility_id;
      param_value(6)  := l_inventory_item_id;
      param_value(7)  := l_config_header_id;
      param_value(8)  := l_config_rev_nbr;
      param_value(9)  := l_read_only;
      param_value(10) := l_save_config_behavior;
      --param_value(11) := l_ui_type;
      --param_value(12) := l_validation_org_id;
      param_value(11) := l_msg_behavior;
      param_value(12) := l_model_quantity;
      param_value(13) := l_icx_session_ticket;

     -- Added extra parameters for config effective and lookup date ER 3177722 and setting the value based on new profile ASO : Configuration Effective Date
     if  l_config_effective_date_prof='C' then  -- set to creation date
          param_value(14) := l_config_creation_date;
          param_value(15) := l_config_creation_date;
      elsif   l_config_effective_date_prof='S'  then  -- set to current date
           param_value(14) :=to_char(sysdate,'MM-DD-YYYY-HH24-MI-SS');--l_current_date;
           param_value(15) :=to_char(sysdate,'MM-DD-YYYY-HH24-MI-SS');--l_current_date;
     elsif  l_config_effective_date_prof='F'  then  -- set to callback function Add code for callback function
          ASO_QUOTE_HOOK.Get_Model_Configuration_Date
	  ( p_quote_header_id=>l_model_line_rec.quote_header_id,
	    P_QUOTE_LINE_ID=> l_model_line_rec.quote_line_id,
	    X_CONFIG_EFFECTIVE_DATE=> x_config_effective_date,
           X_CONFIG_MODEL_LOOKUP_DATE=> x_config_lookup_date
	  );
	    param_value(14) := to_char(x_config_effective_date,'MM-DD-YYYY-HH24-MI-SS');
           param_value(15) := to_char(x_config_lookup_date,'MM-DD-YYYY-HH24-MI-SS');
      elsif  l_config_effective_date_prof='E'  then -- bug 20752067
       BEGIN
	select effective_date into l_effective_date
	from cz_config_hdrs
	where config_hdr_id=l_config_header_id
	and config_rev_nbr = l_config_rev_nbr;

       Exception
	when no_data_found then
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('In ASO_CFG_INT: Create_hdr_xml l_effective_date Exception block no_data_found ');

		END IF;
       When others then
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('In ASO_CFG_INT: Create_hdr_xml l_effective_date Exception block OTHERS ');

	END IF;
      END;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('In ASO_CFG_INT: Create_hdr_xml l_effective_date:  '|| l_effective_date);
	END IF;

         -- bug 21578214, added date format
	 param_value(14) := to_char(l_effective_date,'MM-DD-YYYY-HH24-MI-SS');
         param_value(15) := to_char(l_effective_date,'MM-DD-YYYY-HH24-MI-SS');



      else  -- profile not set
          param_value(14) := null;
          param_value(15) := null;
      end if;

      l_rec_index := 1;
      -- aso_debug_pub.add('Create_hdr_xml: before forming xml loop ');
      LOOP
         -- ex : <param name="config_header_id">1890</param>

         IF (param_value(l_rec_index) IS NOT NULL) THEN

             l_dummy :=  '<param name=' ||
                         '"' || param_name(l_rec_index) || '"'
                         ||'>'|| param_value(l_rec_index) ||
                         '</param>';
        --   aso_debug_pub.add('Create_hdr_xml: before forming xml loop '||length(l_dummy));
         -- aso_debug_pub.add('Create_hdr_xml: before forming xml loop '||l_dummy);
         -- aso_debug_pub.add('Create_hdr_xml: before forming xml loop '||length(l_xml_hdr));
             l_xml_hdr := l_xml_hdr || l_dummy;

          END IF;

          l_dummy := NULL;

          l_rec_index := l_rec_index + 1;
          EXIT WHEN l_rec_index > l_count;

      END LOOP;

      -- add termination tags

      l_xml_hdr := l_xml_hdr || '</initialize>';
      l_xml_hdr := REPLACE(l_xml_hdr, ' ' , '+');

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Create_hdr_xml: Length of l_xml_hdr mesg: '||length(l_xml_hdr));
          aso_debug_pub.add('Create_hdr_xml: 1st Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr,   1, 100));
          aso_debug_pub.add('Create_hdr_xml: 2nd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 101, 100));
          aso_debug_pub.add('Create_hdr_xml: 3rd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 201, 100));
          aso_debug_pub.add('Create_hdr_xml: 4th Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 301, 100));
          aso_debug_pub.add('Create_hdr_xml: 5st Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 401, 100));
          aso_debug_pub.add('Create_hdr_xml: 6nd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 501, 100));
          aso_debug_pub.add('Create_hdr_xml: 7rd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 601, 100));
          aso_debug_pub.add('Create_hdr_xml: 8th Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 701, 100));

      END IF;

      x_xml_hdr := l_xml_hdr;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('End of Create_hdr_xml.', 1, 'Y');
      END IF;


      EXCEPTION

          when others then

              x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Create_hdr_xml: Inside When Others Exception: x_return_status: '||x_return_status, 1, 'N');
              END IF;

END Create_hdr_xml;



-- create xml message, send it to ui manager
-- get back pieces of xml message
-- process them and generate a long output xml message
-- hardcoded :url,user, passwd, gwyuid,fndnam,two_task

/*-------------------------------------------------------------------------
Procedure Name : Send_input_xml
Description    : sends the xml batch validation message to SPC that has
                 options that are newly inserted/updated/deleted
                 from the model.

                 SPC validation_status :
                 CONFIG_PROCESSED              constant NUMBER :=0;
                 CONFIG_PROCESSED_NO_TERMINATE constant NUMBER :=1;
                 INIT_TOO_LONG                 constant NUMBER :=2;
                 INVALID_OPTION_REQUEST        constant NUMBER :=3;
                 CONFIG_EXCEPTION              constant NUMBER :=4;
                 DATABASE_ERROR                constant NUMBER :=5;
                 UTL_HTTP_INIT_FAILED          constant NUMBER :=6;
                 UTL_HTTP_REQUEST_FAILED       constant NUMBER :=7;


--------------------------------------------------------------------------*/

PROCEDURE Send_input_xml
            ( P_Qte_Line_Tbl        IN            ASO_QUOTE_PUB.Qte_Line_Tbl_Type
					                         := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
              P_Qte_Line_Dtl_Tbl	 IN            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
					                         := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
              P_xml_hdr             IN            VARCHAR2,
              X_out_xml_msg         OUT NOCOPY /* file.sql.39 change */     LONG ,
              X_config_changed  OUT NOCOPY /* file.sql.39 change */     VARCHAR2, -- CZ ER
              X_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
              X_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
              X_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
            )
IS
  l_html_pieces              CZ_CF_API.CFG_OUTPUT_PIECES; -- table of VARCHAR2(2000)
  l_option_rec               CZ_CF_API.INPUT_SELECTION;
  l_batch_val_tbl            CZ_CF_API.CFG_INPUT_LIST;

  l_qte_line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
  l_qte_line_dtl_tbl         ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;

  l_delete_qty                    VARCHAR2(30) := '0';

  --variable to fetch from cursor Get_Options
  l_component_code                VARCHAR2(1000);
  --l_config_item_id              NUMBER;
  l_inventory_item_id             VARCHAR2(30);
  l_option_quantity               VARCHAR2(30);

  -- message related
  l_validation_status             NUMBER;
  l_url                           VARCHAR2(500):= FND_PROFILE.Value('CZ_UIMGR_URL');
  l_xml_hdr                       VARCHAR2(2000);
  l_dummy                         VARCHAR2(2000) := NULL;
  l_long_xml                      LONG := NULL;
  l_item_type_code                VARCHAR2(50);
  l_index                         BINARY_INTEGER;
  i                               NUMBER;
  l_return_status                 VARCHAR2(1);

 BEGIN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_CFG_INT: Send_input_xml Begin.', 1, 'Y');
     END IF;

     --Initialize API return status to SUCCESS
     l_return_status  := FND_API.G_RET_STS_SUCCESS;



     l_xml_hdr := p_xml_hdr;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_CFG_INT: Send_input_xml: Before the quote line Loop.', 1, 'Y');
     END IF;

     FOR i IN 1..P_Qte_Line_Tbl.COUNT LOOP

         l_option_rec.input_seq := i;
         l_option_rec.component_code := p_qte_line_dtl_tbl(i).component_code;
         l_option_rec.config_item_id := p_qte_line_dtl_tbl(i).config_item_id;

         IF P_Qte_Line_Tbl(i).operation_code = 'DELETE' THEN
            l_option_rec.quantity := l_delete_qty;
         ELSIF P_Qte_Line_Tbl(i).operation_code = 'UPDATE' THEN
            l_option_rec.quantity := P_Qte_Line_Tbl(i).quantity;
         END IF;

         l_batch_val_tbl(i) := l_option_rec;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN

             aso_debug_pub.add('l_batch_val_tbl('||i||').input_seq:      '||l_batch_val_tbl(i).input_seq);
             aso_debug_pub.add('l_batch_val_tbl('||i||').component_code: '||l_batch_val_tbl(i).component_code);
             aso_debug_pub.add('l_batch_val_tbl('||i||').quantity:       '||l_batch_val_tbl(i).quantity);
             aso_debug_pub.add('l_batch_val_tbl('||i||').config_item_id: '||l_batch_val_tbl(i).config_item_id);

         END IF;

     END LOOP;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_CFG_INT: Send_input_xml: After the quote line Loop.', 1, 'Y');
     END IF;

     -- delete previous data.
     IF (l_html_pieces.COUNT <> 0) THEN
         l_html_pieces.DELETE;
     END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Send_input_xml: l_html_pieces.COUNT: '||l_html_pieces.COUNT);
         aso_debug_pub.add('Send_input_xml: Before call to CZ_CF_API.Validate');
     END IF;


     CZ_CF_API.Validate( config_input_list => l_batch_val_tbl,
                         init_message      => l_xml_hdr,
		         p_check_config_flag => 'Y',
                         config_messages   => l_html_pieces,
		          x_return_config_changed    => X_config_changed,
                         validation_status => l_validation_status,
                         URL               => l_url );



	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Send_input_xml: After call to CZ_CF_API.Validate: l_validation_status: '||l_validation_status||'Error count'||l_html_pieces.COUNT);
     END IF;


     IF l_validation_status <> 0 THEN

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Send_input_xml: Error returned from CZ_CF_API.Validate');
         END IF;

         FND_MESSAGE.Set_Name('ASO', 'ASO_BATCH_VALIDATE');
         FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from CZ_CF_API.Validate, validation_status <> 0' );
         FND_MSG_PUB.ADD;
         l_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Send_input_xml: After call to CZ_CF_API.Validate: l_html_pieces.COUNT: '||l_html_pieces.COUNT);
     END IF;

     IF (l_html_pieces.COUNT <= 0) THEN

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Send_input_xml: No XML message returned from CZ_CF_API.Validate api', 1, 'Y');
          END IF;

          FND_MESSAGE.Set_Name('ASO', 'ASO_BATCH_VALIDATE');
          FND_MESSAGE.Set_token('ERR_TEXT' , 'Error returned from CZ_CF_API.Validate, config_messages: l_html_pieces.COUNT <= 0' );
          FND_MSG_PUB.ADD;
          l_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

     l_index := l_html_pieces.FIRST;

     LOOP

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Send_input_xml: Part of output_message :'|| SUBSTR(l_html_pieces(l_index), 1, 100));

		END IF;

          l_long_xml := l_long_xml || l_html_pieces(l_index);

          EXIT WHEN l_index = l_html_pieces.LAST;
          l_index := l_html_pieces.NEXT(l_index);

     END LOOP;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN

         aso_debug_pub.add('Send_input_xml: Part of output_message :'|| SUBSTR(l_long_xml, 1, 100));
         aso_debug_pub.add('Send_input_xml: Part of output_message :'|| SUBSTR(l_long_xml, 101, 200));
         aso_debug_pub.add('Send_input_xml: Part of output_message :'|| SUBSTR(l_long_xml, 201, 300));
         aso_debug_pub.add('Send_input_xml: Part of output_message :'|| SUBSTR(l_long_xml, 301, 400));
           aso_debug_pub.add('Send_input_xml: X_config_changed :'|| X_config_changed);
     END IF;

     -- Return the output XML message
     x_out_xml_msg   := l_long_xml;

     x_return_status := l_return_status;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.Add('End of Send_input_xml', 1, 'Y');
     END IF;

     EXCEPTION

          WHEN OTHERS THEN

               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Send_input_xml: Inside When Others Exception:', 1, 'N');
               END IF;

END Send_input_xml;


/*-------------------------------------------------------------------------
Procedure Name : Parse_output_xml
Description    : Parses the output XML message returned from the CZ to get the
                 valid and complete configuration flag.
                 If error is returned then populates CZ messages into ASO
                 message stack.
--------------------------------------------------------------------------*/

PROCEDURE  Parse_output_xml
               (  p_xml_msg                       IN            LONG,
                  x_valid_configuration_flag      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                  x_complete_configuration_flag   OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                  x_config_header_id              OUT NOCOPY /* file.sql.39 change */     NUMBER,
                  x_config_revision_num           OUT NOCOPY /* file.sql.39 change */     NUMBER,
                  x_return_status                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                  x_msg_count                     OUT NOCOPY /* file.sql.39 change */     NUMBER,
                  x_msg_data                      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
               )
IS

  CURSOR c_messages(p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) is
  SELECT constraint_type , message
  FROM   cz_config_messages
  WHERE  config_hdr_id = p_config_hdr_id
  AND    config_rev_nbr = p_config_rev_nbr;

  i                                 NUMBER             := 1;
  l_config_header_id                NUMBER;
  l_config_revision_num             NUMBER;
  l_valid_configuration             VARCHAR2(10);
  l_complete_configuration          VARCHAR2(10);
  l_complete_configuration_flag     VARCHAR2(1);
  l_valid_configuration_flag        VARCHAR2(1);
  l_message_type                    VARCHAR2(100);
  l_message_text                    VARCHAR2(4000);
  l_exit                            VARCHAR2(100);
  l_msg                             VARCHAR2(2000);
  l_len_msg                         NUMBER;
  l_constraint                      VARCHAR2(16);

  l_return_status                   VARCHAR2(1);
  l_msg_count                       NUMBER;
  l_msg_data                        VARCHAR2(2000);

BEGIN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_CFG_INT: Parse_output_xml Begin.', 1, 'Y');
    END IF;

    --Initialize API return status to SUCCESS
    l_return_status  := FND_API.G_RET_STS_SUCCESS;

    l_config_header_id 	    := to_number(substr(p_xml_msg,(instr(p_xml_msg, '<config_header_id>',1,1)+18),
                                                 (instr(p_xml_msg,'</config_header_id>',1,1) -
                                                 (instr(p_xml_msg, '<config_header_id>',1,1)+18))));

    l_config_revision_num    := to_number(substr(p_xml_msg,(instr(p_xml_msg,'<config_rev_nbr>',1,1)+16),
                                                 (instr(p_xml_msg,'</config_rev_nbr>',1,1) -
                                                 (instr(p_xml_msg,'<config_rev_nbr>',1,1)+16))));

    l_valid_configuration    := substr(p_xml_msg,(instr(p_xml_msg,'<valid_configuration>',1,1)+21),
                                                 (instr(p_xml_msg,'</valid_configuration>',1,1) -
                                                 (instr(p_xml_msg,'<valid_configuration>',1,1)+21)));

    l_complete_configuration := substr(p_xml_msg,(instr(p_xml_msg,'<complete_configuration>',1,1)+24),
                                       (instr(p_xml_msg,'</complete_configuration>',1,1) -
                                       (instr(p_xml_msg,'<complete_configuration>',1,1)+24)));

    l_message_type           := substr(p_xml_msg,(instr(p_xml_msg,'<message_type>',1,1)+14),
                                       (instr(p_xml_msg,'</message_type>',1,1) -
                                       (instr(p_xml_msg,'<message_type>',1,1)+14)));

    l_message_text           := substr(p_xml_msg,(instr(p_xml_msg,'<message_text>',1,1)+14),
                                       (instr(p_xml_msg,'</message_text>',1,1) -
                                       (instr(p_xml_msg,'<message_text>',1,1)+14)));

    l_exit                   := substr(p_xml_msg,(instr(p_xml_msg,'<exit>',1,1)+6),
                                       (instr(p_xml_msg,'</exit>',1,1) -
							    (instr(p_xml_msg,'<exit>',1,1)+6)));


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Parse_output_xml: l_message_type: '|| l_message_type);
        aso_debug_pub.add('Parse_output_xml: l_message_text: '|| substr(l_message_text,1,150));
        aso_debug_pub.add('Parse_output_xml: l_exit        : '|| l_exit);
    END IF;

    IF l_exit = 'error' AND l_message_type = 'error' THEN

       i         := 1;
       l_len_msg := Length(l_message_text);

       While l_len_msg >= i Loop

            FND_MESSAGE.Set_Name('ASO', 'ASO_BATCH_VALIDATE');
            FND_MESSAGE.Set_token('ERR_TEXT' , substr(l_message_text,i,240));
            FND_MSG_PUB.ADD;

            i := i + 240;

       End Loop;

       l_return_status := FND_API.G_RET_STS_ERROR;

    END IF;


    IF (nvl(l_valid_configuration, 'N')  <> 'true') THEN
         l_valid_configuration_flag := 'N';
    ELSE
         l_valid_configuration_flag := 'Y';
    END IF ;

    IF (nvl(l_complete_configuration, 'N') <> 'true' ) THEN
         l_complete_configuration_flag := 'N';
    ELSE
         l_complete_configuration_flag := 'Y';
    END IF;


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Parse_output_xml: l_valid_configuration_flag:    '|| l_valid_configuration_flag);
        aso_debug_pub.add('Parse_output_xml: l_complete_configuration_flag: '|| l_complete_configuration_flag);
    END IF;

    IF l_config_header_id is NULL THEN

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Parse_output_xml: Getting messages from cz_config_messages');
         END IF;

         OPEN c_messages(l_config_header_id, l_config_revision_num);

         LOOP

		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Parse_output_xml: CZ message: c_messages%rowcount: '||c_messages%rowcount);
             END IF;

             FETCH c_messages into l_constraint,l_msg;
             EXIT when c_messages%notfound;

             i := 1;
             l_len_msg := Length(l_msg);

             While l_len_msg >= i Loop

                   FND_MESSAGE.Set_Name('ASO', 'ASO_BATCH_VALIDATE');
                   FND_MESSAGE.Set_token('ERR_TEXT' , substr(l_msg,i,240));
                   i := i + 240;
                   FND_MSG_PUB.ADD;

             End Loop;

		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Parse_output_xml: '|| substr(l_msg, 1, 100));
                 aso_debug_pub.add('Parse_output_xml: '|| substr(l_msg, 101, 200));
                 aso_debug_pub.add('Parse_output_xml: '|| substr(l_msg, 201, 300));
             END IF;

         END LOOP;

         l_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    -- if everything ok, set return values

    x_valid_configuration_flag    := l_valid_configuration_flag;
    x_complete_configuration_flag := l_complete_configuration_flag;
    x_return_status               := l_return_status;
    x_config_header_id            := l_config_header_id;
    x_config_revision_num         := l_config_revision_num;
    x_msg_count                   := l_msg_count;
    x_msg_data                    := l_msg_data;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.Add('End of parse_output_xml', 1, 'Y');
    END IF;

EXCEPTION

      WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_Debug_Pub.Add( 'Parse_Output_xml: In WHEN OTHERS exception ', 1, 'N');
         END IF;

END Parse_output_xml;



/*----------------------------------------------------------------------
PROCEDURE      : Validate_configuration
Description    : Checks if the configuration is complete and valid.
                 Returns success/error as status. It calls
                 Create_hdr_xml     : To create the CZ batch validation header xml message
                 Send_input_xml     : Sends the xml message created by Create_hdr_xml to the
                                      CZ configurator along with a pl/sql table which has options
                                      that are updated and deleted from the model.
                 Parse_output_xml   : parses the CZ output xml message to see if the configuration
                                      is valid and complete.
                 Get_config_details : To save options along with the model line in ASO_QUOTE_LINES_ALL
                                      , ASO_QUOTE_LINE_DETAILS and ASO_LINE_RELATIONSHIPS
-----------------------------------------------------------------------*/

PROCEDURE Validate_Configuration
    (P_Api_Version_Number              IN             NUMBER    := FND_API.G_MISS_NUM,
     P_Init_Msg_List                   IN             VARCHAR2  := FND_API.G_FALSE,
     P_Commit                          IN             VARCHAR2  := FND_API.G_FALSE,
     p_control_rec                     IN             aso_quote_pub.control_rec_type
                                                      := aso_quote_pub.G_MISS_control_rec,
     P_model_line_id                   IN             NUMBER,
     P_Qte_Line_Tbl                    IN             ASO_QUOTE_PUB.Qte_Line_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
     P_Qte_Line_Dtl_Tbl	              IN             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
     X_config_header_id               OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_config_revision_num            OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_valid_configuration_flag       OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_complete_configuration_flag    OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_return_status                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_msg_count                      OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_msg_data                       OUT NOCOPY /* file.sql.39 change */       VARCHAR2
     )
IS
  l_api_name             CONSTANT VARCHAR2(30) := 'Validate_Configuration' ;
  l_api_version_number   CONSTANT NUMBER       := 1.0;

  l_model_line_id          NUMBER := p_model_line_id;
  l_qte_header_rec         aso_quote_pub.qte_header_rec_type  := aso_quote_pub.g_miss_qte_header_rec;
  l_model_line_rec         ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
  l_model_line_dtl_tbl     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;

  l_config_header_id       NUMBER;
  l_config_revision_num    NUMBER;
  l_valid_configuration_flag    VARCHAR2(1);
  l_complete_configuration_flag VARCHAR2(1);
  --l_model_qty              NUMBER;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_result_out             VARCHAR2(30);

  -- input xml message
  l_xml_message            LONG   := NULL;
  l_xml_hdr                VARCHAR2(2000);

  -- upgrade stuff
  l_upgraded_flag          VARCHAR2(1);

  -- cz's delete return value
  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_delete_config      VARCHAR2(1) := fnd_api.g_false;
  l_old_config_hdr_id  NUMBER;
  l_config_changed            VARCHAR2(1);
BEGIN
    -- Standard Start of API savepoint
    -- SAVEPOINT VALIDATE_CONFIGURATION_INT;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_CFG_INT: Validate_Configuration Begins', 1, 'Y');
    END IF;

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
		 		                         p_api_version_number,
					                     l_api_name,
					                     G_PKG_NAME) THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	     FND_MSG_PUB.initialize;
    END IF;

    -- Get model line info
    l_model_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_model_line_id);
    l_model_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(p_model_line_id);

    -- Call Create_hdr_xml to create the input header XML message
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Validate_Configuration: Before call to Create_hdr_xml.');
    END IF;

    Create_hdr_xml ( P_model_line_id   =>  P_model_line_id,
                     X_xml_hdr         =>  l_xml_hdr,
                     X_return_status   =>  l_return_status );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('Validate_Configuration: After call to Create_hdr_xml l_return_status: '||l_return_status);
        aso_debug_pub.add('Validate_Configuration: After call to Create_hdr_xml Length of l_xml_hdr : '||length(l_xml_hdr));

    END IF;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- Call Send_Input_Xml to call CZ batch validate procedure and get the output XML message

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_CFG_INT: Validate_Configuration: Before call to Send_input_xml');
        END IF;

        Send_input_xml( P_Qte_Line_Tbl      =>  P_Qte_Line_Tbl,
                        P_Qte_Line_Dtl_Tbl  =>  P_Qte_Line_Dtl_Tbl,
                        P_xml_hdr           =>  l_xml_hdr,
                        X_out_xml_msg       =>  l_xml_message,
			X_config_changed  => l_config_changed, -- CZ ER
                        X_return_status     =>  l_return_status,
                        X_msg_count         =>  l_msg_count,
                        X_msg_data          =>  l_msg_data
                      );

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: After call to Send_input_xml');
            aso_debug_pub.add('Validate_Configuration: l_return_status: '||l_return_status);
	    aso_debug_pub.add('Validate_Configuration: l_config_changed: '||l_config_changed);
        END IF;



        -- extract data from xml message.

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      l_delete_config := fnd_api.g_true;
        END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('Validate_Configuration: Before Call to Parse_Output_xml',1,'N');
            aso_debug_pub.add('Validate_Configuration: l_delete_config: '||l_delete_config);
        END IF;

        Parse_output_xml
                   (  p_xml_msg                      => l_xml_message,
                      x_valid_configuration_flag     => l_valid_configuration_flag,
                      x_complete_configuration_flag  => l_complete_configuration_flag,
                      x_config_header_id             => l_config_header_id,
                      x_config_revision_num          => l_config_revision_num,
                      x_return_status                => l_return_status,
                      x_msg_count                    => l_msg_count,
                      x_msg_data                     => l_msg_data
                   );

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: After call to Parse_output_xml');
            aso_debug_pub.add('Validate_Configuration: l_return_status: '||l_return_status);
        END IF;

    END IF;

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) and (l_delete_config = fnd_api.g_false) THEN

        -- Call GET_CONFIG_DETAILS to update the existing configuration
        -- Set the Call_batch_validation_flag to FND_API.G_FALSE to avoid recursive call to update_quote

        l_model_line_dtl_tbl(1).valid_configuration_flag    := l_valid_configuration_flag;
        l_model_line_dtl_tbl(1).complete_configuration_flag := l_complete_configuration_flag;

	   l_qte_header_rec.quote_header_id  :=  l_model_line_rec.quote_header_id;


	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: Before Call to ASO_CFG_INT.Get_config_details');
        END IF;

        ASO_CFG_INT.Get_config_details(
              p_api_version_number         => 1.0,
              p_init_msg_list              => FND_API.G_FALSE,
              p_commit                     => FND_API.G_FALSE,
              p_control_rec                => p_control_rec,
		    p_qte_header_rec             => l_qte_header_rec,
              p_model_line_rec             => l_model_line_rec,
              p_config_rec                 => l_model_line_dtl_tbl(1),
              p_config_hdr_id              => l_config_header_id,
              p_config_rev_nbr             => l_config_revision_num,
              x_return_status              => l_return_status,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => l_msg_data );

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: After Call to Get_config_details');
            aso_debug_pub.add('Validate_Configuration: l_return_status: '||l_return_status);
	   END IF;

    ELSE
	   l_delete_config := fnd_api.g_true;
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: l_delete_config: '||l_delete_config);
	   END IF;

    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('End of procedure Validate_Configuration');
        aso_debug_pub.add('l_return_status:               '|| l_return_status);
        aso_debug_pub.add('l_valid_configuration_flag:    '|| l_valid_configuration_flag);
        aso_debug_pub.add('l_complete_configuration_flag: '|| l_complete_configuration_flag);
        aso_debug_pub.add('l_config_changed: '|| l_config_changed);
    END IF;

    x_config_header_id             := l_config_header_id;
    x_config_revision_num          := l_config_revision_num;
    x_valid_configuration_flag     := l_valid_configuration_flag;
    x_complete_configuration_flag  := l_complete_configuration_flag;
    x_return_status                := l_return_status;
    x_msg_count                    := l_msg_count;
    x_msg_data                     := l_msg_data;

    if l_delete_config = fnd_api.g_true then

         x_return_status := FND_API.G_RET_STS_ERROR;

    end if;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('End of Validate_Configuration', 1, 'N');
    END IF;

    EXCEPTION

       WHEN OTHERS THEN

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Validate_Configuration: Inside WHEN OTHERS EXCEPTION', 1, 'Y');
		  END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Configuration;


End aso_cfg_int;

/
