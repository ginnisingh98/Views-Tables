--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_SAVESHARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_SAVESHARE_PVT" as
/* $Header: IBEVQSSB.pls 120.3 2006/07/18 11:00:01 aannamal ship $ */
-- Start of Comments
-- Package name     : IBE_QUOTE_SAVESHARE_pvt
-- Purpose      :
-- NOTE       :

-- End of Comments

-- Default number of records fetch per call
G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_QUOTE_SAVESHARE_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBEVQSSB.pls';
l_true VARCHAR2(1) := FND_API.G_TRUE;

cursor c_is_shared_cart(c_qte_hdr_id NUMBER) is
     select count(*) yes_shared_cart
     from ibe_sh_quote_access
     where quote_header_id = c_qte_hdr_id
     and nvl(end_date_active,sysdate+1) > sysdate;

rec_is_shared_cart c_is_shared_cart%rowtype;

FUNCTION get_Config_Rev_Nbr(p_config_hdr_id IN NUMBER,
   		   p_config_rev_nbr IN NUMBER)
RETURN NUMBER IS
  CURSOR c_chk_rev_nbr IS
    SELECT config_rev_nbr
	 FROM cz_config_details_v
     WHERE config_hdr_id = p_config_hdr_id
	  AND config_rev_nbr = p_config_rev_nbr;

  CURSOR c_max_rev_nbr IS
    SELECT MAX(config_rev_nbr)
	 FROM cz_config_details_v
     WHERE config_hdr_id = p_config_hdr_id;

  l_result_rev_nbr     NUMBER;

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('   => get_Config_Rev_Nbr(' || p_config_hdr_id || ', ' || p_config_rev_nbr || ') Begins');
  END IF;
  OPEN c_chk_rev_nbr;
  FETCH c_chk_rev_nbr INTO l_result_rev_nbr;
  IF c_chk_rev_nbr%NOTFOUND THEN
    -- If revision nbr doesn't exist get the max from config
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.Debug('   => get_Config_Rev_Nbr   Revision Not Found. Looking for Max revision');
    END IF;
    OPEN c_max_rev_nbr;
    FETCH c_max_rev_nbr INTO l_result_rev_nbr;
    CLOSE c_max_rev_nbr;
    l_result_rev_nbr := NVL(l_result_rev_nbr, p_config_rev_nbr);
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('   => get_Config_Rev_Nbr  Ends [ Result=' || l_result_rev_nbr || ' ] ');
  END IF;
  CLOSE c_chk_rev_nbr;

  RETURN l_result_rev_nbr;
END get_Config_Rev_Nbr;

FUNCTION getLineTblForControlledCopy(
  p_quote_header_Id            IN  NUMBER
) RETURN  ASO_QUOTE_PUB.QTE_LINE_TBL_TYPE
IS

  l_qte_line_rec     ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;
  l_qte_line_tbl     ASO_QUOTE_PUB.QTE_LINE_TBL_TYPE;
  CURSOR c_getlinetbl(l_quote_header_id number) IS
           SELECT l.QUOTE_LINE_ID
     	 ,l.CREATION_DATE
         ,l.CREATED_BY
         ,l.LAST_UPDATE_DATE
         ,l.LAST_UPDATED_BY
         ,l.LAST_UPDATE_LOGIN
         ,l.REQUEST_ID
         ,l.PROGRAM_APPLICATION_ID
         ,l.PROGRAM_ID
         ,l.PROGRAM_UPDATE_DATE
         ,l.QUOTE_HEADER_ID
         ,l.ORG_ID
         ,l.LINE_CATEGORY_CODE
         ,l.ITEM_TYPE_CODE
         ,l.LINE_NUMBER
         ,l.START_DATE_ACTIVE
         ,l.END_DATE_ACTIVE
         ,l.ORDER_LINE_TYPE_ID
         ,l.ORGANIZATION_ID
         ,l.INVENTORY_ITEM_ID
         ,l.QUANTITY
         ,l.UOM_CODE
         ,l.MARKETING_SOURCE_CODE_ID
         ,l.CURRENCY_CODE
         ,l.RELATED_ITEM_ID
         ,l.ITEM_RELATIONSHIP_TYPE
         ,l.ACCOUNTING_RULE_ID
         ,l.INVOICING_RULE_ID
         ,l.SPLIT_SHIPMENT_FLAG
         ,l.BACKORDER_FLAG
         ,l.agreement_id -- agreement
         ,l.commitment_id -- commitment
  From  aso_quote_lines l
  Where l.QUOTE_HEADER_ID = l_QUOTE_HEADER_ID
  Order by l.quote_line_id;
begin

  open c_getlinetbl(p_quote_header_id);
  loop
  fetch c_getlinetbl into
   	l_qte_line_rec.QUOTE_LINE_ID
        ,l_qte_line_rec.CREATION_DATE
        ,l_qte_line_rec.CREATED_BY
        ,l_qte_line_rec.LAST_UPDATE_DATE
        ,l_qte_line_rec.LAST_UPDATED_BY
        ,l_qte_line_rec.LAST_UPDATE_LOGIN
        ,l_qte_line_rec.REQUEST_ID
        ,l_qte_line_rec.PROGRAM_APPLICATION_ID
        ,l_qte_line_rec.PROGRAM_ID
        ,l_qte_line_rec.PROGRAM_UPDATE_DATE
        ,l_qte_line_rec.QUOTE_HEADER_ID
        ,l_qte_line_rec.ORG_ID
        ,l_qte_line_rec.LINE_CATEGORY_CODE
        ,l_qte_line_rec.ITEM_TYPE_CODE
        ,l_qte_line_rec.LINE_NUMBER
        ,l_qte_line_rec.START_DATE_ACTIVE
        ,l_qte_line_rec.END_DATE_ACTIVE
        ,l_qte_line_rec.ORDER_LINE_TYPE_ID
        ,l_qte_line_rec.ORGANIZATION_ID
        ,l_qte_line_rec.INVENTORY_ITEM_ID
        ,l_qte_line_rec.QUANTITY
        ,l_qte_line_rec.UOM_CODE
        ,l_qte_line_rec.MARKETING_SOURCE_CODE_ID
        ,l_qte_line_rec.CURRENCY_CODE
        ,l_qte_line_rec.RELATED_ITEM_ID
        ,l_qte_line_rec.ITEM_RELATIONSHIP_TYPE
        ,l_qte_line_rec.ACCOUNTING_RULE_ID
        ,l_qte_line_rec.INVOICING_RULE_ID
        ,l_qte_line_rec.SPLIT_SHIPMENT_FLAG
        ,l_qte_line_rec.BACKORDER_FLAG
        ,l_qte_line_rec.AGREEMENT_ID
        ,l_qte_line_rec.COMMITMENT_ID;
	EXIT WHEN c_getlinetbl%NOTFOUND;
        l_qte_line_tbl(l_qte_line_tbl.count+1) := l_qte_line_rec;
   END LOOP;
   CLOSE  c_getlinetbl;
   RETURN l_qte_line_tbl;
END getLineTblForControlledCopy;

Procedure Copy_Lines(
  p_api_version_number       IN  NUMBER
  ,p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                  IN  VARCHAR2 := FND_API.G_FALSE
  ,X_Return_Status           OUT NOCOPY VARCHAR2
  ,X_Msg_Count               OUT NOCOPY NUMBER
  ,X_Msg_Data                OUT NOCOPY VARCHAR2

  ,p_from_quote_header_id    IN  NUMBER
  ,p_to_quote_header_id      IN  NUMBER
  ,p_mode                    IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_qte_line_tbl            OUT NOCOPY ASO_Quote_Pub.qte_line_tbl_type
  ,x_qte_line_dtl_tbl        OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type
  ,x_line_attr_ext_tbl       OUT NOCOPY ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type
  ,x_line_rltship_tbl        OUT NOCOPY ASO_Quote_Pub.Line_Rltship_tbl_Type
  ,x_ln_price_attributes_tbl OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_Price_Adjustment_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Tbl_Type
  ,x_Price_Adj_Rltship_Tbl   IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
)
IS

  l_api_name                    CONSTANT VARCHAR2(30)   := 'Copy_lines';
  l_api_version                 CONSTANT NUMBER         := 1.0;

  l_qte_line_dtl_tbl            ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type;
  l_line_rltship_tbl            ASO_Quote_Pub.Line_Rltship_tbl_Type;
  l_line_attr_ext_tbl           ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type;
  l_ln_price_attributes_tbl     ASO_Quote_Pub.Price_Attributes_Tbl_Type;

  l_old_config_hdr_id           NUMBER;
  l_old_config_rev_nbr          NUMBER;

  l_new_config_hdr_id           NUMBER;
  l_new_config_rev_nbr          NUMBER;
  --l_return_value                NUMBER;

  -- added 12/22/03: PRG, no line merge
  l_Price_Adjustment_Tbl_ALL    ASO_Quote_Pub.Price_Adj_Tbl_Type;
  l_Price_Adjustment_Tbl        ASO_Quote_Pub.Price_Adj_Tbl_Type;
  l_Price_Adj_Rltship_Tbl       ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

  --added for 11.5.11 Duplicate Cart feature
  l_permission_to_create_agrmt BOOLEAN;
  l_use_line_agrmts            VARCHAR2(2);
  l_use_commitments            VARCHAR2(2);


  -- ER#4025142
  l_ret_status VARCHAR2(1);
  l_msg_count  INTEGER;
  l_orig_item_id_tbl  CZ_API_PUB.number_tbl_type;
  l_new_item_id_tbl   CZ_API_PUB.number_tbl_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    COPY_LINES_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('p_mode='|| p_mode);
   END IF;

   -- New api call to get line tbl in p_mode = 'CONTROLLED_COPY', currently this mode is used in
   -- duplicate cart of shared carts/quotes.
   IF p_mode = 'CONTROLLED_COPY' THEN
     x_qte_line_tbl := getLineTblForControlledCopy(p_from_quote_header_id);

     -- To check user has create agreement permission.
     l_permission_to_create_agrmt :=   ibe_util.check_user_permission(
                                      p_permission => 'IBE_USE_PRICING_AGREEMENT' );
     -- To check Line level agreement feature is enabled.
     l_use_line_agrmts  :=  FND_Profile.Value('IBE_USE_LINE_AGREEMENTS');

     -- To check Commitment feature is enabled
     l_use_commitments  := FND_Profile.Value('IBE_USE_COMMITMENTS');

     -- Check if user has agreement permission and profile is ON, then if agreement is available then erase it from line record.
     IF (l_permission_to_create_agrmt) and (l_use_line_agrmts = 'Y') THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('user has agreement permission and agreement feature is turned on, so keep the agrmt info');
       END IF;
     ELSE
       -- check if agreementId is not null then erase agreement and pricelist.
         FOR k IN 1..x_qte_line_tbl.COUNT LOOP
           IF x_qte_line_tbl(k).agreement_id is not null THEN
             x_qte_line_tbl(k).agreement_id :=  null;
             x_qte_line_tbl(k).price_list_id := null;
           END IF;
         END LOOP;
     END IF;
   ELSE
     x_qte_line_tbl := IBE_Quote_Misc_pvt.getLineTbl
                         (p_from_quote_header_id);
     l_Price_Adjustment_Tbl_ALL := IBE_Quote_Misc_pvt.getAllLinesPrcAdjTbl (p_from_quote_header_id);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('reusing x_Price_Adjustment_Tbl -- size='|| x_Price_Adjustment_Tbl.count);
      ibe_util.debug('reusing x_Price_Adj_Rltship_Tbl -- size='|| x_Price_Adj_Rltship_Tbl.count);
      ibe_util.debug('l_Price_Adjustment_Tbl_ALL size is='|| l_Price_Adjustment_Tbl_ALL.count);
     END IF;

   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('line number is='|| x_qte_line_tbl.count);
   END IF;


  FOR i IN 1..x_qte_line_tbl.COUNT LOOP

       l_qte_line_dtl_tbl := IBE_Quote_Misc_pvt.getlineDetailTbl
                             (x_qte_line_tbl(i).quote_line_id);
       FOR j IN 1..l_qte_line_dtl_tbl.COUNT LOOP
	    IF l_qte_line_dtl_tbl(j).service_ref_line_id <> fnd_api.g_miss_num THEN
           l_qte_line_dtl_tbl(j).service_ref_qte_line_index :=
  		   IBE_Quote_Misc_pvt.getLineIndexFromLineId(l_qte_line_dtl_tbl(j).service_ref_line_id,
		  								     x_qte_line_tbl);
           l_qte_line_dtl_tbl(j).service_ref_line_id := fnd_api.g_miss_num;
         END IF;
         l_qte_line_dtl_tbl(j).quote_line_detail_id := fnd_api.g_miss_num;
         l_qte_line_dtl_tbl(j).operation_code := 'CREATE';
         l_qte_line_dtl_tbl(j).qte_line_index := i;
         l_qte_line_dtl_tbl(j).quote_line_id := fnd_api.g_miss_num;
         x_qte_line_dtl_tbl(x_qte_line_dtl_tbl.count+1)
               := l_qte_line_dtl_tbl(j);
        END LOOP;


       l_line_rltship_tbl := IBE_Quote_Misc_pvt.getlineRelationshipTbl(x_qte_line_tbl(i).quote_line_id);

       FOR j IN 1..l_line_rltship_tbl.COUNT LOOP
		IF NVL(l_line_rltship_tbl(j).relationship_type_code, '*') <> 'SERVICE' THEN
            l_line_rltship_tbl(j).line_relationship_id := fnd_api.g_miss_num;
            l_line_rltship_tbl(j).operation_code := 'CREATE';

            l_line_rltship_tbl(j).qte_line_index := i;
            l_line_rltship_tbl(j).related_qte_line_index
                            := IBE_Quote_Misc_pvt.getLineIndexFromLineId
                               (  l_line_rltship_tbl(j).related_quote_line_id
                                  ,x_qte_line_tbl
                                );
            l_line_rltship_tbl(j).quote_line_id := fnd_api.g_miss_num;
            l_line_rltship_tbl(j).related_quote_line_id := fnd_api.g_miss_num;
            x_line_rltship_tbl(x_line_rltship_tbl.count+1)
                 := l_line_rltship_tbl(j);
          END IF;

       END LOOP;

      -- Setup the line attr ext and price attributes table only if p_mode <> 'CONTROLLED_COPY'

       IF p_mode <> 'CONTROLLED_COPY' THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('regulat copy lines and copying line attr and price attributes');
          END IF;

          l_line_attr_ext_tbl := IBE_Quote_Misc_pvt.getLineAttrExtTbl
                              (x_qte_line_tbl(i).quote_line_id);

          FOR j IN 1..l_line_attr_ext_tbl.COUNT LOOP
            l_line_attr_ext_tbl(j).line_attribute_id := fnd_api.g_miss_num;
            l_line_attr_ext_tbl(j).operation_code := 'CREATE';
            l_line_attr_ext_tbl(j).qte_line_index := i;
            l_line_attr_ext_tbl(j).quote_line_id := fnd_api.g_miss_num;
--           l_line_attr_ext_tbl(j).quote_header_id := p_to_quote_header_id;

           x_line_attr_ext_tbl(x_line_attr_ext_tbl.count+1)
               := l_line_attr_ext_tbl(j);
          END LOOP;

         l_ln_price_attributes_tbl := IBE_Quote_Misc_pvt.getlinePrcAttrTbl
                                    (x_qte_line_tbl(i).quote_line_id);

         FOR j IN 1..l_ln_price_attributes_tbl.COUNT LOOP
           l_ln_price_attributes_tbl(j).price_attribute_id := fnd_api.g_miss_num;
           l_ln_price_attributes_tbl(j).operation_code := 'CREATE';
           l_ln_price_attributes_tbl(j).qte_line_index := i;
           l_ln_price_attributes_tbl(j).quote_line_id := fnd_api.g_miss_num;
           l_ln_price_attributes_tbl(j).quote_header_id := p_to_quote_header_id;
           x_ln_price_attributes_tbl(x_ln_price_attributes_tbl.count+i)
                      := l_ln_price_attributes_tbl(j);
         END LOOP;

       -- added 12/22/03: PRG, no line merge
        -- for each quote_line_id, get the price adjustment info
       l_Price_Adjustment_Tbl := IBE_Quote_Misc_pvt.getLinePrcAdjTbl (x_qte_line_tbl(i).quote_line_id);
       FOR j IN 1..l_Price_Adjustment_Tbl.COUNT LOOP

         -- if Free Line, for each PRICE_ADJUSTMENT_ID, get the related info
         if (x_qte_line_tbl(i).pricing_line_type_indicator = 'F') then
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              ibe_util.debug('x_qte_line_tbl(i).pricing_line_type_indicator='|| x_qte_line_tbl(i).pricing_line_type_indicator);
              ibe_util.debug('before calling getLinePrcAdjRelTbl: l_Price_Adjustment_Tbl(j).PRICE_ADJUSTMENT_ID='|| l_Price_Adjustment_Tbl(j).PRICE_ADJUSTMENT_ID);
           END IF;
           l_Price_Adj_Rltship_Tbl := IBE_Quote_Misc_pvt.getLinePrcAdjRelTbl (l_Price_Adjustment_Tbl(j).PRICE_ADJUSTMENT_ID);
           FOR k IN 1..l_Price_Adj_Rltship_Tbl.COUNT LOOP
             l_Price_Adj_Rltship_Tbl(k).ADJ_RELATIONSHIP_ID := fnd_api.g_miss_num;
             l_Price_Adj_Rltship_Tbl(k).operation_code := 'CREATE';

             l_Price_Adj_Rltship_Tbl(k).RLTD_PRICE_ADJ_INDEX := x_Price_Adjustment_Tbl.count+j;

             -- the following two values are for Qual Lines, we have to search the indices
             l_Price_Adj_Rltship_Tbl(k).PRICE_ADJ_INDEX      := IBE_Quote_Misc_pvt.getPrcAdjIndexFromPrcAdjId
                                                                 (l_Price_Adj_Rltship_Tbl(k).PRICE_ADJUSTMENT_ID, l_Price_Adjustment_Tbl_ALL);
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              ibe_util.debug('New... need to pass qte_line_index');
             END IF;
             l_Price_Adj_Rltship_Tbl(k).QTE_LINE_INDEX       := IBE_Quote_Misc_pvt.getLineIndexFromLineId(l_Price_Adj_Rltship_Tbl(k).quote_line_id, x_qte_line_tbl);
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              ibe_util.debug('New... and the qte_line_index is:'||l_Price_Adj_Rltship_Tbl(k).QTE_LINE_INDEX);
             END IF;
             -- clear out the other id's
             l_Price_Adj_Rltship_Tbl(k).RLTD_PRICE_ADJ_Id := fnd_api.g_miss_num;
             l_Price_Adj_Rltship_Tbl(k).PRICE_ADJUSTMENT_ID := fnd_api.g_miss_num;
             l_Price_Adj_Rltship_Tbl(k).QUOTE_LINE_ID       := fnd_api.g_miss_num;

             x_Price_Adj_Rltship_Tbl(x_Price_Adj_Rltship_Tbl.count+1) := l_Price_Adj_Rltship_Tbl(k);
           end loop;  -- Looping through price adjustment relationships
         end if;      -- if Free Line

         l_Price_Adjustment_Tbl(j).PRICE_ADJUSTMENT_ID := fnd_api.g_miss_num;
         l_Price_Adjustment_Tbl(j).operation_code      := 'CREATE';

         l_Price_Adjustment_Tbl(j).qte_line_index      := i;
         l_Price_Adjustment_Tbl(j).quote_line_id       := fnd_api.g_miss_num;
         l_Price_Adjustment_Tbl(j).quote_header_id     := p_to_quote_header_id;
         x_Price_Adjustment_Tbl(x_Price_Adjustment_Tbl.count+1) := l_Price_Adjustment_Tbl(j);
        END LOOP;      -- Looping through price adjustments
      END IF; -- for p_mode<>
  END LOOP; -- end of get line information

  FOR i in 1..x_qte_line_tbl.count loop
      x_qte_line_tbl(i).operation_code := 'CREATE';
      x_qte_line_tbl(i).quote_line_id := fnd_api.g_miss_num;
      x_qte_line_tbl(i).quote_header_id := p_to_quote_header_id;
      x_qte_line_tbl(i).line_number := fnd_api.g_miss_num;
  END LOOP;

  -- takes care of configuraton item
  FOR i IN 1..x_qte_line_dtl_tbl.COUNT LOOP
      IF x_qte_line_tbl(x_qte_line_dtl_tbl(i).qte_line_index).item_type_code
          = 'MDL' THEN
         l_old_config_hdr_id  := x_qte_line_dtl_tbl(i).config_header_id;
         l_old_config_rev_nbr := x_qte_line_dtl_tbl(i).config_revision_num;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('old config id = '|| l_old_config_hdr_id);
            IBE_UTIL.debug('old config rev number = '|| l_old_config_rev_nbr);
         END IF;


         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('call CZ_CONFIG_API_PUB.copy_configuration at'
                 || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         --ER#4025142
         CZ_CONFIG_API_PUB.copy_configuration(p_api_version => l_api_version
                            ,p_config_hdr_id        => l_old_config_hdr_id
                            ,p_config_rev_nbr       => Get_Config_Rev_Nbr(l_old_config_hdr_id,
                                                        l_old_config_rev_nbr)
                            ,p_copy_mode            => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
                            ,x_config_hdr_id        => l_new_config_hdr_id
                            ,x_config_rev_nbr       => l_new_config_rev_nbr
                            ,x_orig_item_id_tbl     => l_orig_item_id_tbl
                            ,x_new_item_id_tbl      => l_new_item_id_tbl
                            ,x_return_status        => l_ret_status
                            ,x_msg_count            => l_msg_count
                            ,x_msg_data             => x_msg_data);
		 IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS OR l_orig_item_id_tbl.count > 0) THEN
            	RAISE FND_API.G_EXC_ERROR;
  		 END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('done CZ_CONFIG_API_PUB.Copy_Configuration at'
                 || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('new config id = '|| l_new_config_hdr_id);
            IBE_UTIL.debug('new config rev number = '|| l_new_config_rev_nbr);
         END IF;

         -- update all other dtl table
         FOR j in 1..x_qte_line_dtl_tbl.COUNT LOOP
            IF ( x_qte_line_dtl_tbl(j).config_header_id = l_old_config_hdr_id
               and x_qte_line_dtl_tbl(j).config_revision_num = l_old_config_rev_nbr )
            THEN
               x_qte_line_dtl_tbl(j).config_header_id    := l_new_config_hdr_id;
               x_qte_line_dtl_tbl(j).config_revision_num := l_new_config_rev_nbr;
            END IF;
         END LOOP;
      END IF;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('before out line number is='|| x_qte_line_tbl.count);
  END IF;
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in copy_lines');
      END IF;
      ROLLBACK TO COPY_LINES_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unexpected exception in copy_lines');
      END IF;
      ROLLBACK TO COPY_LINES_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unknown exception in copy_lines');
      END IF;
      ROLLBACK TO COPY_LINES_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Copy_Lines;



PROCEDURE SaveSharee (
  P_Api_Version_Number      IN   NUMBER
  ,p_Init_Msg_List          IN   VARCHAR2 := FND_API.G_FALSE
  ,p_Commit                 IN   VARCHAR2 := FND_API.G_FALSE
  ,p_Quote_Header_id        IN   NUMBER
  ,p_emailAddress           IN   varchar2
  ,p_privilegeType          IN   varchar2
  ,p_recip_party_id         IN   NUMBER   := FND_API.G_MISS_NUM
  ,p_recip_cust_account_id  IN   NUMBER   := FND_API.G_MISS_NUM
  ,x_qte_access_rec         OUT NOCOPY  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Rec_Type
  ,X_Return_Status          OUT NOCOPY  VARCHAR2
  ,X_Msg_Count              OUT NOCOPY  NUMBER
  ,X_Msg_Data               OUT NOCOPY  VARCHAR2
)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Savesharee';
  l_api_version           CONSTANT NUMBER   := 1.0;
  l_quote_sharee_id       NUMBER;
  l_quote_sharee_number   NUMBER;
  l_contact_point_id      NUMBER;
  l_quote_access_rec      IBE_QUOTE_SAVESHARE_pvt.quote_access_rec_type
                          := IBE_QUOTE_SAVESHARE_pvt.g_miss_quote_access_rec;
  l_qte_access_table      IBE_QUOTE_SAVESHARE_pvt.quote_access_tbl_type
                          := IBE_QUOTE_SAVESHARE_pvt.g_miss_quote_access_tbl;

  cursor c_get_sharee_id is
    select quote_sharee_number
    from ibe_sh_quote_access
    where quote_sharee_id = (select max(quote_sharee_id)
                             from ibe_sh_quote_access I, hz_contact_points h
                             where i.contact_point_id = h.contact_point_id
                             and upper(h.owner_table_name) = 'IBE_SH_QUOTE_ACCESS'
                             and UPPER(h.email_address) = upper(p_emailaddress)
                             and quote_header_id = p_quote_header_id
                             and i.update_privilege_type_code = p_privilegeType);

  rec_get_sharee_id   c_get_sharee_id%rowtype;

BEGIN
   -- Standard Start of API savepoint
  SAVEPOINT    SAVESHAREE_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                             P_Api_Version_Number,
                                   l_api_name,
                       G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_quote_access_rec.quote_header_id            := p_quote_header_id;
  l_quote_access_rec.update_privilege_type_code := p_privilegeType;
  l_quote_access_rec.party_id                   := p_recip_party_id;
  l_quote_access_rec.cust_account_id            := p_recip_cust_account_id;
  l_quote_access_rec.email_contact_address      := p_emailAddress;
  l_quote_access_rec.operation_code             := 'CREATE';
  l_qte_access_table(1)                         := l_quote_access_rec;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Calling save_recipients to save recipient information');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('Calling save_recipients to save recipient information ');
  IF(nvl(l_qte_access_table.count,0) > 0) THEN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Calling save_recipients to save recipient information');
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('l_qte_access_table(1).quote_header_id: '||l_qte_access_table(1).quote_header_id);
      IBE_UTIL.DEBUG('l_qte_access_table(1).update_privilege_type_code: '|| l_qte_access_table(1).update_privilege_type_code);
      IBE_UTIL.DEBUG('l_qte_access_table(1).party_id: '||l_qte_access_table(1).party_id);
      IBE_UTIL.DEBUG('l_qte_access_table(1).cust_account_id: '||l_qte_access_table(1).cust_account_id);
      IBE_UTIL.DEBUG('l_qte_access_table(1).email_contact_address: '||l_qte_access_table(1).email_contact_address);
    END IF;
    IBE_QUOTE_SAVESHARE_V2_PVT.save_recipients(
        p_quote_access_tbl   => l_qte_access_table   ,
        p_quote_header_id    => p_quote_header_id    ,
        p_send_notif         => FND_API.G_FALSE      ,
        p_api_version        => P_Api_Version_Number ,
        p_init_msg_list      => fnd_api.g_false      ,
        p_commit             => fnd_api.g_false      ,
        x_return_status      => x_return_status      ,
        x_msg_count          => x_msg_count          ,
        x_msg_data           => x_msg_data           );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

  END IF; -- IF(nvl(p_quote_access_tbl.count,0)

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Done calling save_recipients to save recipient information');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('Done calling save_recipients to save recipient information ');
  for rec_get_sharee_id in c_get_sharee_id loop
    l_quote_access_rec.quote_sharee_number := rec_get_sharee_id.quote_sharee_number;
    exit when c_get_sharee_id%notfound;
  end loop;

  x_qte_access_rec := l_quote_access_rec;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and IF count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (     p_encoded =>    FND_API.G_FALSE,
        p_count   =>    x_msg_count,
        p_data    =>    x_msg_data
  );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.SaveSharee');
      END IF;
      ROLLBACK TO SAVESHAREE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unexpected exception in IBE_QUOTE_SAVESHARE_PVT.SaveSharee');
      END IF;
      ROLLBACK TO SAVESHAREE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unknown exception in IBE_QUOTE_SAVESHARE_PVT.SaveSharee');
      END IF;
      ROLLBACK TO SAVESHAREE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END SAVESHAREE;

PROCEDURE SaveAsAndShare(
   p_api_version_number     IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
  ,p_from_quote_header_id   IN  NUMBER
  ,p_from_last_update_date  IN DATE
  ,p_copy_only_header       IN  VARCHAR2 := FND_API.G_FALSE
  ,p_to_Control_Rec         IN  ASO_Quote_Pub.Control_Rec_Type
                                   := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_to_Qte_Header_Rec      IN  ASO_Quote_Pub.Qte_Header_Rec_Type
  ,p_to_hd_Shipment_rec     IN  ASO_Quote_Pub.Shipment_rec_Type
                                   := ASO_Quote_Pub.G_MISS_SHIPMENT_rec
  ,p_url                    IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_sharee_email_address   IN  jtf_varchar2_table_2000 := NULL
  ,p_sharee_privilege_type  IN  jtf_varchar2_table_100  := NULL
  ,p_comments               IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_quote_retrieval_number IN  NUMBER := FND_API.G_MISS_NUM
  ,p_minisite_id	        IN  NUMBER := FND_API.G_MISS_NUM
  ,p_validate_user          IN  VARCHAR2   := FND_API.G_FALSE
  ,x_to_quote_header_id     OUT NOCOPY NUMBER
  ,x_to_last_update_date    OUT NOCOPY DATE
)
IS
  l_api_name                   CONSTANT VARCHAR2(30)   := 'SAVEASANDSHARE';
  l_api_version                CONSTANT NUMBER         := 1.0;

  l_party_id                   NUMBER ;
  l_cust_account_id            NUMBER ;
  l_quote_number               NUMBER := null;
  l_quote_status_id            NUMBER := null;

  l_to_qte_header_rec          ASO_Quote_Pub.qte_header_rec_type;

  l_to_hd_shipment_tbl         ASO_Quote_Pub.shipment_tbl_type;

  l_to_qte_line_tbl            ASO_Quote_Pub.qte_line_tbl_type;
  l_to_line_rltship_tbl        ASO_Quote_Pub.Line_Rltship_tbl_Type;
  l_to_qte_line_dtl_tbl        ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type;
  l_to_line_attr_ext_tbl       ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type;
  l_to_ln_price_attributes_tbl ASO_Quote_Pub.Price_Attributes_Tbl_Type;

  -- added 12/22/03: PRG, no line merge
  l_Price_Adjustment_Tbl       ASO_Quote_Pub.Price_Adj_Tbl_Type;
  l_Price_Adj_Rltship_Tbl      ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

  CURSOR c_order_type(p_quote_header_id NUMBER) IS
    SELECT order_type_id
	 FROM aso_quote_headers
	WHERE quote_header_id = p_quote_header_id;
  l_order_type_id              NUMBER;


BEGIN
   -- --IBE_UTIL.ENABLE_DEBUG;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Begin IBE_QUOTE_SAVESHARE_pvt.SaveAsAndShare() at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
   END IF;
  -- Standard Start of API savepoint
  SAVEPOINT    SAVEASANDSHARE_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                            P_Api_Version_Number,
                                  l_api_name,
                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- User Authentication
   IBE_Quote_Misc_pvt.Validate_User_Update(
	  p_init_msg_list           => p_init_msg_list
	  ,p_quote_header_id         => p_from_quote_header_id
	  ,p_party_id               => p_to_Qte_Header_Rec.party_id
	  ,p_cust_account_id        => p_to_Qte_Header_Rec.cust_account_id
	  ,p_quote_retrieval_number => p_quote_retrieval_number
	  ,p_validate_user	    => p_validate_user
	  ,x_return_status          => x_return_status
	  ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
  );
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


 l_to_qte_header_rec := p_to_qte_header_rec;
    -- get party_id and cust_account_id of quote_header_id
   IBE_Quote_Misc_pvt.getQuoteOwner
   (     p_api_version_number  => p_api_version_number
	 ,p_quote_header_id    => p_from_quote_header_id
	 ,x_party_id           => l_Party_id
	 ,x_cust_account_id    => l_Cust_account_id
	 ,X_Return_Status      => x_return_status
	 ,X_Msg_Count          => x_msg_count
         ,X_Msg_Data           => x_msg_data
   );
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


   IF ( l_party_id = p_to_qte_header_rec.party_id
     and l_cust_account_id = p_to_qte_header_rec.cust_account_id )
    or ( p_to_qte_header_rec.party_id = fnd_api.g_miss_num or
         p_to_qte_header_rec.cust_account_id = fnd_api.g_miss_num)
   THEN
      IF (l_to_qte_header_rec.quote_status_id <> fnd_api.g_miss_num) THEN
         l_quote_status_id := l_to_qte_header_rec.quote_status_id;
      END IF;

      IF (l_to_qte_header_rec.quote_number <> fnd_api.g_miss_num) THEN
        l_quote_number := l_to_qte_header_rec.quote_number;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('ASO_Quote_Pub.Copy_Quote() starts   at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      END IF;

      ASO_Quote_Pub.Copy_Quote(
         p_api_version_number      => p_api_version_number
         ,p_init_msg_list          => FND_API.G_FALSE
         ,p_commit                 => FND_API.G_FALSE
         ,p_qte_header_id          => p_from_quote_header_id
         ,p_last_update_date       => p_from_last_update_date
	    ,p_copy_only_header       => p_copy_only_header
          --,P_New_Version	   =>
         ,P_Qte_Status_Id	   => l_quote_status_id -- default to null
         ,P_Qte_Number		   => l_quote_number    -- default to null
         ,x_qte_header_id          => l_to_qte_header_rec.quote_header_id
         ,x_Return_Status          => x_Return_Status
         ,x_Msg_Count              => x_Msg_Count
         ,x_Msg_Data               => x_Msg_Data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('ASO_Quote_Pub.Copy_Quote() finishes at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    -- copy change the lastupdatedate, but order capture does not return it.
    l_to_qte_header_rec.last_update_date
              := IBE_Quote_Misc_pvt.getQuotelastUpdateDate
                 (l_to_qte_header_rec.quote_header_id);
  ELSE
  -- get order_type_id from the original quote header
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Getting order_type_id from original quote header ' || p_from_quote_header_id);
    END IF;
    OPEN c_order_type(p_from_quote_header_id);
    FETCH c_order_type INTO l_order_type_id;
    IF l_order_type_id IS NOT NULL
    THEN
      l_to_qte_header_rec.order_type_id := l_order_type_id;
    END IF;
    CLOSE c_order_type;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('order_type_id=' || l_order_type_id);
    END IF;

  -- get all line related information from original quote header id
    Copy_Lines
    (  p_api_version_number       => p_api_version_number
       ,p_init_msg_list           => FND_API.G_FALSE
       ,p_commit                  => FND_API.G_FALSE
       ,x_Return_Status           => x_Return_Status
       ,x_Msg_Count               => x_Msg_Count
       ,x_Msg_Data                => x_Msg_Data

       ,p_from_quote_header_id    => p_from_quote_header_id
       ,p_to_quote_header_id      => l_to_qte_header_rec.quote_header_id
       ,x_qte_line_tbl            => l_to_qte_line_tbl
       ,x_qte_line_dtl_tbl        => l_to_qte_line_dtl_tbl
       ,x_line_attr_ext_tbl       => l_to_line_attr_ext_tbl
       ,x_line_rltship_tbl        => l_to_line_rltship_tbl
       ,x_ln_price_attributes_tbl => l_to_ln_price_attributes_tbl

       ,x_Price_Adjustment_tbl    => l_Price_Adjustment_tbl
       ,x_Price_Adj_Rltship_tbl   => l_Price_Adj_Rltship_tbl
    );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  l_to_hd_shipment_tbl(1) 					:= p_to_hd_shipment_rec;
  l_to_hd_shipment_tbl(1).quote_header_id 	:= l_to_qte_header_rec.quote_header_id;

  IBE_Quote_Save_pvt.save
  (   p_api_version_number        => p_api_version_number
      ,p_init_msg_list            => FND_API.G_FALSE
      ,p_commit                   => FND_API.G_FALSE
      ,p_qte_header_rec           => l_to_qte_header_rec
      ,p_Qte_Line_Tbl             => l_to_qte_line_tbl
      ,p_Qte_Line_Dtl_Tbl         => l_to_Qte_Line_Dtl_Tbl
      ,p_Line_Attr_Ext_Tbl        => l_to_Line_Attr_Ext_Tbl
      ,p_Line_rltship_tbl         => l_to_Line_rltship_tbl
      ,p_control_rec              => p_to_control_rec
      ,p_hd_shipment_tbl          => l_to_hd_shipment_tbl

      ,p_Price_Adjustment_tbl     => l_Price_Adjustment_tbl
      ,p_Price_Adj_Rltship_tbl    => l_Price_Adj_Rltship_tbl

      ,x_quote_header_id          => x_to_quote_header_id
      ,x_last_update_date         => x_to_last_update_date
      ,x_return_status            => x_return_status
      ,x_msg_count                => x_msg_count
      ,x_msg_data                 => x_msg_data
  );
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IBE_QUOTE_SAVESHARE_pvt.sharequote
  (     p_api_version_number        => 1.0
        ,p_init_msg_list             => FND_API.G_FALSE
        ,p_commit                    => FND_API.G_FALSE
        ,p_quote_header_id           => x_to_quote_header_id
        ,p_url                       => p_url
        ,p_sharee_email_address      => p_sharee_email_address
        ,p_sharee_privilege_Type     => p_sharee_privilege_Type
        ,p_comments                  => p_comments
        ,X_Return_Status             => x_Return_Status
        ,X_Msg_Count                 => x_Msg_Count
        ,X_Msg_Data                  => x_Msg_Data
  );
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End   IBE_QUOTE_SAVESHARE_pvt.SaveAsAndShare() at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
   END IF;
   --IBE_UTIL.DISABLE_DEBUG;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.SaveAsAndShare');
      END IF;
      ROLLBACK TO SAVEASANDSHARE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unexpected exception in IBE_QUOTE_SAVESHARE_PVT.SaveAsAndShare');
      END IF;
      ROLLBACK TO SAVEASANDSHARE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
  WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unknown exception in IBE_QUOTE_SAVESHARE_PVT.SaveAsAndShare');
      END IF;
      ROLLBACK TO SAVEASANDSHARE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_QUOTE_SAVESHARE_pvt.SaveAsAndShare() at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      END IF;
      --IBE_UTIL.DISABLE_DEBUG;
END SaveAsAndShare;

PROCEDURE AppendToReplaceShare(
   p_api_version_number       IN  NUMBER                         ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_mode                     IN  VARCHAR2 := 'APPENDTO'         ,
   p_combinesameitem          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_increaseversion          IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_original_quote_header_id IN  NUMBER                         ,
   p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_rep_app_quote_header_id  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_new_quote_password       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_url                      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sharee_email_address     IN  jtf_varchar2_table_2000 := NULL,
   p_sharee_privilege_type    IN  jtf_varchar2_table_100  := NULL,
   p_currency_code            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_list_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_control_rec              IN  ASO_Quote_Pub.Control_Rec_Type := ASO_Quote_Pub.G_MISS_Control_Rec,
   p_comments                 IN VARCHAR2 := FND_API.G_MISS_CHAR ,
   p_rep_app_invTo_partySiteId IN  NUMBER := FND_API.G_MISS_NUM  ,
   p_Hd_Price_Attributes_Tbl  IN  ASO_Quote_Pub.Price_Attributes_Tbl_Type := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl,
   p_Hd_Payment_Tbl           IN  ASO_Quote_Pub.Payment_Tbl_Type          := ASO_Quote_Pub.G_MISS_PAYMENT_TBL,
   p_Hd_Shipment_Tbl          IN  ASO_Quote_Pub.Shipment_Tbl_Type         := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL,
   p_Hd_Freight_Charge_Tbl    IN  ASO_Quote_Pub.Freight_Charge_Tbl_Type   := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl,
   p_Hd_Tax_Detail_Tbl        IN  ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE       := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl,
   p_Price_Adjustment_Tbl     IN  ASO_Quote_Pub.Price_Adj_Tbl_Type        := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl,
   p_Price_Adj_Attr_Tbl       IN  ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type   := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl,
   p_Price_Adj_Rltship_Tbl    IN  ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type:= ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl,
   p_quote_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_party_id                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_cust_account_id          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_validate_user            IN  VARCHAR2 := FND_API.G_FALSE,
   p_minisite_id              IN  NUMBER   := FND_API.G_MISS_NUM,
   x_quote_header_id          OUT NOCOPY NUMBER                         ,
   x_last_update_date         OUT NOCOPY DATE
)
is
  l_api_name                    CONSTANT VARCHAR2(30)   := 'APPENDTOREPLACESHARE';
  l_api_version                 CONSTANT NUMBER         := 1.0;

  l_to_qte_header_rec           ASO_Quote_Pub.qte_header_rec_type;
  l_to_qte_line_tbl             ASO_Quote_Pub.qte_line_tbl_type;
  l_to_line_rltship_tbl         ASO_Quote_Pub.Line_Rltship_tbl_Type;
  l_to_qte_line_dtl_tbl         ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type;
  l_to_line_attr_ext_tbl        ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type;
  l_to_ln_price_attributes_tbl  ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  q_ver							number(5);
  q_num 						number(5);
  l_quote_to_copy		NUMBER;
  l_quote_header_id_tmp NUMBER;
  l_last_update_date_tmp DATE;

  CURSOR c_q_datenumber (c_quote_header_id number) is
  select last_update_date, quote_number
  from ASO_QUOTE_HEADERS
  where quote_header_id = c_quote_header_id;


  CURSOR c_q_date (c_quote_header_id number) is
  select last_update_date
  from ASO_QUOTE_HEADERS
  where quote_header_id = c_quote_header_id;

  CURSOR c_q_number (c_quote_header_id number) is
  select quote_number
  from ASO_QUOTE_HEADERS
  where quote_header_id = c_quote_header_id;


   /* Cursor to select the cart name used for "Replace Cart" functionality*/
  CURSOR c_cart_name(p_quote_header_id number) is
 	SELECT  quote_name, quote_number
	FROM  aso_quote_headers
	WHERE quote_header_id =p_quote_header_id;

  /* Cursor to select the quote owners used for "Replace Cart" functionality done by a recepient(sharee)*/

  cursor c_check_cart_owner(p_quote_header_id number) is
	select created_by from aso_quote_headers_all
	where quote_header_id = p_quote_header_id;

  rec_cart_name			    c_cart_name%rowtype;
  l_target_cart_owner		number;
  l_source_cart_owner		number;

  -- added 12/22/03: PRG, no line merge
  l_Price_Adjustment_Tbl       ASO_Quote_Pub.Price_Adj_Tbl_Type;
  l_Price_Adj_Rltship_Tbl      ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

BEGIN
   --IBE_UTIL.ENABLE_DEBUG;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Begin **new** IBE_QUOTE_SAVESHARE_pvt.AppendToReplaceShare() at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      IBE_Util.Debug('Parameters pased to IBE_QUOTE_SAVESHARE_pvt.AppendToReplaceShare() are');
      IBE_Util.Debug('P_ORIGINAL_QUOTE_HEADER_ID: '||P_ORIGINAL_QUOTE_HEADER_ID);
      IBE_Util.Debug('P_REP_APP_QUOTE_HEADER_ID: '||P_REP_APP_QUOTE_HEADER_ID);
      IBE_Util.Debug('P_INCREASEVERSION: '||P_INCREASEVERSION);
   END IF;


    -- Standard Start of API savepoint
  SAVEPOINT    APPENDTOREPLACESHARE_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version_Number,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('APPENDTOREPLACESHARE: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('APPENDTOREPLACESHARE: After Calling log_environment_info');
   END IF;

    -- User Authentication
  IBE_Quote_Misc_pvt.Validate_User_Update(
    p_init_msg_list          => p_init_msg_list
   ,p_quote_header_id        => p_original_quote_header_id
   ,p_party_id               => p_party_id
   ,p_cust_account_id        => p_cust_account_id
   ,p_quote_retrieval_number => p_quote_retrieval_number
   ,p_validate_user	         => p_validate_user
   ,p_last_update_date       => p_last_update_date
   ,x_return_status          => x_return_status
   ,x_msg_count              => x_msg_count
   ,x_msg_data               => x_msg_data
  );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Removing this validation as this is already being done in validate_user_update
  /*IF (p_last_update_date is not null
      and p_last_update_date <> fnd_api.g_miss_date) THEN

     IBE_Quote_Misc_pvt.validateQuoteLastUpdateDate
     (   p_api_version_number   => p_api_version_number
         ,p_quote_header_id     => p_original_quote_header_id
         ,p_last_update_date    => p_last_update_date
         ,X_Return_Status       => x_return_status
         ,X_Msg_Count           => x_msg_count
         ,X_Msg_Data            => x_msg_data
     );
     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;*/

  l_to_qte_header_rec.quote_header_id := p_rep_app_quote_header_id;
  -- p_new_quote_password is not null
  IF (p_new_quote_password <> fnd_api.g_miss_char) THEN
      l_to_qte_header_rec.quote_password  := p_new_quote_password;
  END IF;

  IF (p_currency_code is not null
      and p_currency_code <> fnd_api.g_miss_char) THEN
      l_to_qte_header_rec.currency_code   := p_currency_code;
  END IF;

-- Modified by mannamra for the bug 1936844
--  IF (p_price_list_id is not null
  IF p_price_list_id <> fnd_api.g_miss_num THEN
      l_to_qte_header_rec.price_list_id   := p_price_list_id;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Parameter values just before checking "REPLACE" or "APPEND" condition');
     IBE_Util.Debug('p_MODE:                     '||p_MODE);
     IBE_Util.Debug('P_ORIGINAL_QUOTE_HEADER_ID: '||P_ORIGINAL_QUOTE_HEADER_ID);
     IBE_Util.Debug('P_REP_APP_QUOTE_HEADER_ID:  '||P_REP_APP_QUOTE_HEADER_ID);
     IBE_Util.Debug('P_INCREASEVERSION:          '||P_INCREASEVERSION);
  END IF;

  /*Obtain cart name here*/
  OPEN c_cart_name(p_rep_app_quote_header_id);
    FETCH c_cart_name INTO
	 l_to_Qte_Header_Rec.quote_name,
	 l_to_Qte_Header_Rec.quote_number;
  CLOSE c_cart_name;
  /*Obtain the target cart owner */
  OPEN c_check_cart_owner(p_rep_app_quote_header_id);
    FETCH c_check_cart_owner INTO
	 l_target_cart_owner;
  CLOSE c_check_cart_owner;

  /*Obtain the source cart owner */
  OPEN c_check_cart_owner(p_original_quote_header_id);
    FETCH c_check_cart_owner INTO
	 l_source_cart_owner;
  CLOSE c_check_cart_owner;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('quote number obtained from the cursor is: '||l_to_Qte_Header_Rec.quote_name);
     IBE_Util.Debug('quote name obtained from the cursor is: '|| l_to_Qte_Header_Rec.quote_number);
  END IF;

  if (((p_mode = 'REPLACE') and (l_target_cart_owner <> l_source_cart_owner)) or
      ((p_mode = 'APPENDTO') and (fnd_api.to_Boolean(p_increaseversion)))) then
    l_quote_to_copy := p_rep_app_quote_header_id;

    OPEN c_q_datenumber(p_rep_app_quote_header_id);
    FETCH c_q_datenumber INTO
          l_to_qte_header_rec.last_update_date
          , l_to_qte_header_rec.quote_number;
    CLOSE c_q_datenumber;
  else
    l_quote_to_copy := p_original_quote_header_id;

    OPEN c_q_date(p_original_quote_header_id);
    FETCH c_q_date INTO
          l_to_qte_header_rec.last_update_date;
    CLOSE c_q_date;
    OPEN c_q_number(p_rep_app_quote_header_id);
    FETCH c_q_number INTO
          l_to_qte_header_rec.quote_number;
    CLOSE c_q_number;
  end if;

  if ((p_mode = 'REPLACE') or
      ((p_mode = 'APPENDTO') and (fnd_api.to_Boolean(p_increaseversion)))) then


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('ASO_Quote_Pub.Copy_Quote() starts');
    END IF;
    aso_quote_pub.copy_quote(
      p_api_version_number => P_Api_Version_Number
      ,p_init_msg_list      => fnd_api.g_false
      ,p_commit             => fnd_api.g_false
      ,p_qte_header_id      => l_quote_to_copy
      ,p_last_update_date   => l_to_qte_header_rec.last_update_date
      ,P_Qte_Number         => l_to_qte_header_rec.quote_number
      ,p_new_version        => FND_API.G_TRUE
      ,x_qte_header_id      => l_to_qte_header_rec.quote_header_id
      ,X_Return_Status      => x_Return_Status
      ,X_Msg_Count          => x_Msg_Count
      ,X_Msg_Data           => x_Msg_Data);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('ASO_Quote_Pub.Copy_Quote() finishes');
       IBE_Util.Debug('x_qte_header_id: ' || l_to_qte_header_rec.quote_header_id);
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_to_qte_header_rec.last_update_date
      := IBE_Quote_Misc_pvt.getQuotelastUpdateDate
      (l_to_qte_header_rec.quote_header_id);

  else
    -- we are in a sort of update mode updating the target cart
    l_to_qte_header_rec.quote_header_id := p_rep_app_quote_header_id;
    l_to_qte_header_rec.last_update_date
      := IBE_Quote_Misc_pvt.getQuotelastUpdateDate
      (l_to_qte_header_rec.quote_header_id);
  end if; -- end of copy_quote if

  IF ((p_mode = 'REPLACE' )
      and (l_target_cart_owner <> l_source_cart_owner)) THEN
    /*Delete lines from the cart created in the above call to copy quote*/

    IBE_Quote_Save_pvt.deletealllines(
      P_Api_Version_Number   => p_api_version_number
      ,p_Init_Msg_List        => fnd_api.g_false
      ,p_Commit               => fnd_api.g_false
      ,p_Quote_Header_Id      => l_to_qte_header_rec.quote_header_id
      ,p_last_update_date     => l_to_qte_header_rec.last_update_date
      ,x_quote_header_id      => l_quote_header_id_tmp
      ,x_last_update_date     => l_last_update_date_tmp
      ,X_Return_Status        => x_return_status
      ,X_Msg_Count            => x_msg_count
      ,X_Msg_Data             => x_msg_data);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_to_qte_header_rec.quote_header_id := l_quote_header_id_tmp;
    l_to_qte_header_rec.last_update_date := l_last_update_date_tmp;

  end if;

  -- added 12/22/03: PRG, no line merge
  l_Price_Adjustment_Tbl       := p_Price_Adjustment_Tbl;
  l_Price_Adj_Rltship_Tbl      := p_Price_Adj_Rltship_Tbl;

  if ((p_mode = 'APPENDTO') or
      ((p_mode = 'REPLACE' ) and
       (l_target_cart_owner <> l_source_cart_owner))) THEN
    /* unless we're replacing for common owner,
       copy lines from the source cart to target cart */
    Copy_Lines(
      p_api_version_number       => p_api_version_number
      ,p_init_msg_list           => FND_API.G_FALSE
      ,p_commit                  => FND_API.G_FALSE
      ,x_Return_Status           => x_Return_Status
      ,x_Msg_Count               => x_Msg_Count
      ,x_Msg_Data                => x_Msg_Data
      ,p_from_quote_header_id    => p_original_quote_header_id
      ,p_to_quote_header_id      => l_to_qte_header_rec.quote_header_id
      ,x_qte_line_tbl            => l_to_qte_line_tbl
      ,x_qte_line_dtl_tbl        => l_to_qte_line_dtl_tbl
      ,x_line_attr_ext_tbl       => l_to_line_attr_ext_tbl
      ,x_line_rltship_tbl        => l_to_line_rltship_tbl
      ,x_ln_price_attributes_tbl => l_to_ln_price_attributes_tbl
      ,x_Price_Adjustment_tbl    => l_Price_Adjustment_tbl
      ,x_Price_Adj_Rltship_tbl   => l_Price_Adj_Rltship_tbl);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  end if;


   	/*To identify the name of the destination cart*/

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('parameter values before calling SAVE');
      IBE_Util.Debug('l_to_Qte_Header_Rec.quote_name : '||l_to_Qte_Header_Rec.quote_name);
      IBE_Util.Debug('l_to_Qte_Header_Rec.quote_number : '|| l_to_Qte_Header_Rec.quote_number);
      IBE_Util.Debug('l_to_Qte_Header_Rec.quote_header_id : '|| l_to_Qte_Header_Rec.quote_header_id);
      IBE_Util.Debug('quote version q_ver is: '||q_ver);
   END IF;

   --8/12/02: Default Feature:
   if ((p_rep_app_invTo_partySiteId is not null) and (p_rep_app_invTo_partySiteId <> FND_API.G_MISS_NUM) ) then
      l_to_qte_header_rec.invoice_to_party_site_id := p_rep_app_invTo_partySiteId;
   end if;
   IBE_Quote_Save_pvt.save(
      p_api_version_number            => p_api_version_number
           ,p_init_msg_list            => fnd_api.g_false
           ,p_commit                   => fnd_api.g_false
           ,p_combineSameItem          => p_combineSameItem
           ,p_qte_header_rec           => l_to_qte_header_rec
           ,p_control_rec              => p_control_rec
           ,p_Qte_Line_Tbl             => l_to_qte_line_tbl
           ,p_Qte_Line_Dtl_Tbl         => l_to_Qte_Line_Dtl_Tbl
           ,p_Line_Attr_Ext_Tbl        => l_to_Line_Attr_Ext_Tbl
           ,p_Line_rltship_tbl         => l_to_Line_rltship_tbl

           -- 8/12/02: added for Default Feature
           ,p_hd_price_attributes_tbl  => p_Hd_Price_Attributes_Tbl
           ,p_hd_payment_tbl           => p_Hd_Payment_Tbl
           ,p_hd_shipment_tbl          => p_Hd_Shipment_Tbl
           ,p_hd_freight_charge_tbl    => p_Hd_Freight_Charge_Tbl
           ,p_hd_tax_detail_tbl        => p_Hd_Tax_Detail_Tbl
           ,p_price_adjustment_tbl     => l_Price_Adjustment_Tbl
           ,p_price_adj_attr_tbl       => p_Price_Adj_Attr_Tbl
           ,p_price_adj_rltship_tbl    => l_Price_Adj_Rltship_Tbl

           ,x_quote_header_id          => x_quote_header_id
           ,x_last_update_date         => x_last_update_date
           ,x_return_status            => x_return_status
           ,x_msg_count                => x_msg_count
           ,x_msg_data                 => x_msg_data);

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IBE_QUOTE_SAVESHARE_pvt.sharequote(
      p_api_version_number        => 1.0
        ,p_init_msg_list             => FND_API.G_false
        ,p_commit                    => FND_API.G_false
        ,p_quote_header_id           => x_quote_header_id
        ,p_url                       => p_url
        ,p_sharee_email_address      => p_sharee_email_address
        ,p_sharee_privilege_Type     => p_sharee_privilege_Type
	   ,p_comments                  => p_comments
        ,X_Return_Status             => x_Return_Status
        ,X_Msg_Count                 => x_Msg_Count
        ,X_Msg_Data                  => x_Msg_Data);

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End   IBE_QUOTE_SAVESHARE_pvt.AppendToReplaceShare() at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.AppendToReplaceShare');
      END IF;
      ROLLBACK TO APPENDTOREPLACESHARE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
      --IBE_UTIL.DISABLE_DEBUG;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unexpected exception in IBE_QUOTE_SAVESHARE_PVT.AppendToReplaceShare');
      END IF;
      ROLLBACK TO APPENDTOREPLACESHARE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unknown exception in IBE_QUOTE_SAVESHARE_PVT.AppendToReplaceShare');
      END IF;
      ROLLBACK TO APPENDTOREPLACESHARE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END AppendToReplaceShare;



PROCEDURE ShareQuote(
   p_api_version_number    IN  NUMBER   := 1                  ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status         OUT NOCOPY VARCHAR2                ,
   x_msg_count             OUT NOCOPY NUMBER                  ,
   x_msg_data              OUT NOCOPY VARCHAR2                ,
   p_quote_header_id       IN  NUMBER                         ,
   p_url                   IN  VARCHAR2                       ,
   p_sharee_email_address  IN  JTF_VARCHAR2_TABLE_2000 := NULL,
   p_sharee_privilege_type IN  JTF_VARCHAR2_TABLE_100  := NULL,
   p_comments              IN  VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'ShareQuote';
  l_api_version             CONSTANT NUMBER   := 1.0;

  l_contact_point_id           NUMBER := fnd_api.g_miss_num;
  l_contact_lastupdatedate     DATE   := fnd_api.g_miss_date;
  l_qte_access_rec             IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Rec_Type
                               :=IBE_QUOTE_SAVESHARE_pvt.g_miss_quote_access_rec;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT    SAVEASANDSHARE_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                             P_Api_Version_Number,
                                   l_api_name,
                       G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('SAVEASANDSHARE: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('SAVEASANDSHARE: After Calling log_environment_info');
   END IF;

  /*IF (P_URL is not null and P_URL <> FND_API.G_MISS_CHAR) THEN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('call IBE_QUOTE_SAVESHARE_pvt.savecontactpoint at '
                 || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;

      saveContactPoint
      (   p_api_version_number  => P_Api_Version_Number
          ,p_init_msg_list      => FND_API.G_FALSE
          ,p_commit             => FND_API.G_FALSE
          ,P_URL                => p_url
          ,p_owner_table_id     => p_quote_header_id
          ,p_mode               => 'WEB'
          ,x_contact_point_id   => l_contact_point_id
          ,x_return_status      => x_return_status
          ,x_msg_count          => x_msg_count
          ,x_msg_data           => x_msg_data
     );
     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('done IBE_QUOTE_SAVESHARE_pvt.savecontactpoint at '
                 || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
    END IF;

  END IF;  -- end of url*/

  IF (P_sharee_email_Address is not null) THEN
      FOR i IN 1..P_sharee_email_Address.count LOOP
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('call IBE_QUOTE_SAVESHARE_pvt.savesharee '|| i || ' at '
                 || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         IBE_QUOTE_SAVESHARE_pvt.SaveSharee
         (  p_api_version_number => P_Api_Version_Number
            ,p_init_msg_list     => FND_API.G_FALSE
            ,p_commit            => FND_API.G_FALSE
            ,P_Quote_Header_id   => p_quote_header_id
            ,P_emailAddress      => p_sharee_email_Address(i)
            ,P_privilegeType     => p_sharee_privilege_Type(i)
            ,x_Qte_access_rec    => l_qte_access_rec
            ,x_return_status     => x_return_status
            ,x_msg_count         => x_msg_count
            ,x_msg_data          => x_msg_data );
         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('call IBE_QUOTE_SAVESHARE_pvt.emailsharee at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         IBE_QUOTE_SAVESHARE_pvt.EmailSharee
         (  p_api_version_number  => P_Api_Version_Number
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,P_Quote_Header_id    => p_quote_header_id
            ,P_emailAddress       => p_sharee_email_Address(i)
            ,P_privilegeType      => p_sharee_privilege_Type(i)
            ,p_url                => p_url
            ,p_qte_access_rec     => l_qte_access_rec
            ,p_comments           => p_comments
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
         );
         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('done IBE_QUOTE_SAVESHARE_pvt.emailsharee at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

     END LOOP;
  END IF;
END ShareQuote;


--- only for account user
Procedure ActivateQuote(
   p_api_version_number IN  NUMBER   := 1                  ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id    IN  NUMBER                         ,
   p_last_update_date   IN  DATE     := FND_API.G_MISS_DATE,
   p_increaseversion    IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE
)
IS
  l_api_name             CONSTANT VARCHAR2(30)   := 'ActivateQuote';
  l_api_version          CONSTANT NUMBER         := 1.0;
  l_qte_header_rec       ASO_Quote_Pub.qte_header_rec_type
                         := ASO_Quote_Pub.g_miss_qte_header_rec;
  l_control_rec          aso_quote_pub.control_rec_type
                         := aso_quote_pub.g_miss_control_rec;
  l_party_id             NUMBER;
  l_cust_account_id      NUMBER;

  l_quote_header_id_tmp NUMBER;
  l_last_update_date_tmp DATE;

  cursor c_owner_party(c_quote_header_id number) is
     select party_id, cust_account_id, quote_header_id
     from aso_quote_headers_all
     where quote_header_id = c_quote_header_id;

  rec_owner_party       c_owner_party%rowtype;



BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    ActivateQuote_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version_number,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('ActivateQuote: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('ActivateQuote: After Calling log_environment_info');
   END IF;

   -- User Authentication
   IBE_Quote_Misc_pvt.Validate_User_Update(
	p_init_msg_list     => p_init_msg_list
	,p_quote_header_id   => p_quote_header_id
	,p_validate_user    => FND_API.G_TRUE
	,x_return_status    => x_return_status
    ,x_msg_count        => x_msg_count
    ,x_msg_data         => x_msg_data   );

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --IBE_UTIL.ENABLE_DEBUG;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Begin IBE_QUOTE_SAVESHARE_pvt.ActivateQuote() at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
   END IF;

   l_qte_header_rec.quote_header_id  := p_quote_header_id;
   l_qte_header_rec.last_update_date := p_last_update_date;

   IF l_qte_header_rec.last_update_date IS NULL
   OR l_qte_header_rec.last_update_date = FND_API.G_MISS_DATE THEN
      l_qte_header_rec.last_update_date := IBE_Quote_Misc_pvt.GetQuoteLastUpdateDate(l_qte_header_rec.quote_header_id);
   END IF;


   IF FND_API.To_Boolean(p_increaseVersion) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('ASO_Quote_Pub.Copy_Quote() starts   at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      END IF;

      ASO_Quote_Pub.Copy_Quote(
         P_Api_Version_Number => P_Api_Version_Number
        ,P_Init_Msg_List      => FND_API.G_FALSE
        ,P_Commit             => FND_API.G_FALSE
        ,P_Qte_Header_Id      => l_qte_header_rec.quote_header_id
        ,P_Last_Update_Date   => l_qte_header_rec.last_update_date
        ,X_Qte_Header_Id      => l_quote_header_id_tmp
        ,X_Return_Status      => x_return_status
        ,X_Msg_Count          => x_msg_count
        ,X_Msg_Data           => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('ASO_Quote_Pub.Copy_Quote() finishes at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_qte_header_rec.quote_header_id := l_quote_header_id_tmp;

      l_qte_header_rec.last_update_date := IBE_Quote_Misc_pvt.GetQuoteLastUpdateDate(l_qte_header_rec.quote_header_id);
   END IF;

   l_qte_header_rec.quote_name        := 'IBE_PRMT_SC_UNNAMED';
   l_qte_header_rec.quote_source_code := 'IStore Account';
   --Adding re-pricing parameters for bug #2267005
    --mannamra:Removing references to obsoleted profile IBE_PRICE_REQUEST_TYPE see bug 2594529 for details
   l_control_rec.pricing_request_type          := 'ASO';--FND_Profile.Value('IBE_PRICE_REQUEST_TYPE');
   l_control_rec.header_pricing_event          := FND_Profile.Value('IBE_INCART_PRICING_EVENT');
   l_control_rec.line_pricing_event            := FND_API.G_MISS_CHAR;
   l_control_rec.calculate_freight_charge_flag := 'Y';
   l_control_rec.calculate_tax_flag            := 'Y';
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Activate quote: l_control_rec.pricing_request_type '||l_control_rec.pricing_request_type);
      ibe_util.debug('Activate quote: l_control_rec.header_pricing_event  '||l_control_rec.header_pricing_event );
      ibe_util.debug('Activate quote: l_control_rec.line_pricing_event  '||l_control_rec.line_pricing_event );
   END IF;
   IBE_Quote_Save_pvt.save(
      p_api_version_number        => p_api_version_number
      ,p_init_msg_list            => FND_API.G_FALSE
      ,p_commit                   => FND_API.G_FALSE
      ,p_qte_header_rec           => l_qte_header_rec
      ,p_control_rec              => l_control_rec
      ,x_quote_header_id          => x_quote_header_id
      ,x_last_update_date         => x_last_update_date
      ,x_return_status            => x_return_status
      ,x_msg_count                => x_msg_count
      ,x_msg_data                 => x_msg_data);

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   FOR rec_owner_party in c_owner_party(l_qte_header_rec.quote_header_id) LOOP
     l_party_id        := rec_owner_party.party_id;
     l_cust_account_id := rec_owner_party.cust_account_id;
     exit when c_owner_party%notfound;
   END LOOP;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Owner party_id:        '||l_party_id);
      IBE_UTIL.DEBUG('Owner cust_account_id: '||l_cust_account_id);
   END IF;

   --DBMS_OUTPUT.PUT_LINE('Calling IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE ');
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Calling IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE ');
   END IF;
   IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE(
               P_Quote_header_rec  => l_qte_header_rec                ,
               P_Party_id         => l_party_id                       ,
               P_Cust_account_id  => l_cust_account_id                ,
               P_api_version      => p_api_version_number             ,
               P_init_msg_list    => FND_API.G_FALSE                  ,
               P_commit           => FND_API.G_FALSE                  ,
               x_return_status    => x_return_status                  ,
               x_msg_count        => x_msg_count                      ,
               x_msg_data         => x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   --DBMS_OUTPUT.PUT_LINE('Finished calling IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE ');
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Finished calling IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE ');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End   IBE_QUOTE_SAVESHARE_pvt.ActivateQuote() at ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
   END IF;
   --IBE_UTIL.DISABLE_DEBUG;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.ActivateQuote');
      END IF;
      ROLLBACK TO ActivateQuote_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unexpected exception in IBE_QUOTE_SAVESHARE_PVT.ActivateQuote');
      END IF;
      ROLLBACK TO ActivateQuote_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('unknown exception in IBE_QUOTE_SAVESHARE_PVT.ActivateQuote');
      END IF;
      ROLLBACK TO ActivateQuote_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END ActivateQuote;


PROCEDURE RetrieveShareQuote(
   p_api_version_number     IN  NUMBER                         ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status          OUT NOCOPY VARCHAR2                       ,
   x_msg_count              OUT NOCOPY NUMBER                         ,
   x_msg_data               OUT NOCOPY VARCHAR2                       ,
   p_quote_password         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_number           IN  NUMBER                         ,
   p_quote_version          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_sharee_number          IN  NUMBER                         ,
   p_sharee_party_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_sharee_cust_account_id IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_currency_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_list_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_control_rec            IN  ASO_Quote_Pub.Control_Rec_Type := ASO_Quote_Pub.G_MISS_Control_Rec,
   p_minisite_id            IN NUMBER    := FND_API.G_MISS_NUM ,
   x_quote_header_id        OUT NOCOPY NUMBER                         ,
   x_last_update_date       OUT NOCOPY DATE                           ,
   x_privilege_type_code    OUT NOCOPY VARCHAR2
)
is

  l_api_name             CONSTANT VARCHAR2(30)  := 'Retrievesharequote';
  l_api_version          CONSTANT NUMBER  := 1.0;
  l_expiration_date_tmp  DATE;
  l_pricebasedonowner    varchar2(30);

  l_qte_header_rec          ASO_Quote_Pub.qte_header_rec_type
                            := ASO_Quote_Pub.g_miss_qte_header_rec;
-- temp var for NOCOPY OUT parameter

  l_qte_header_rec_tmp          ASO_Quote_Pub.qte_header_rec_type
                            := ASO_Quote_Pub.g_miss_qte_header_rec;
  lx_qte_line_tbl            ASO_Quote_Pub.qte_line_tbl_type
                            := ASO_Quote_Pub.g_miss_qte_line_tbl;
begin

   -- Standard Start of API savepoint
  SAVEPOINT    RETRIEVESHAREQUOTE_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('RETRIEVESHAREQUOTE: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('RETRIEVESHAREQUOTE: After Calling log_environment_info');
   END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('call IBE_Quote_Misc_pvt.get_Shared_Quote at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;

  IBE_Quote_Misc_pvt.get_Shared_Quote
  (    p_api_version_number => p_api_version_number
       ,p_quote_password    => p_quote_password
       ,p_quote_number      => p_quote_number
       ,p_quote_version     => p_quote_version
       ,x_quote_header_id   => l_qte_header_rec.quote_header_id
       ,x_last_update_date  => l_qte_header_rec.last_update_date
       ,x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
  );
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('done IBE_Quote_Misc_pvt.getShareQuote at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;

  x_privilege_type_code   := IBE_Quote_Misc_pvt.getShareePrivilege
                           (   p_quote_header_id => l_qte_header_rec.quote_header_id
                               ,p_sharee_number  => p_sharee_number
                           );
  l_pricebasedonowner :=   fnd_profile.value('IBE_SC_PRICE_BASED_ON_OWNER');

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('l_pricebasedonowner='||l_pricebasedonowner);
  END IF;
  if( (P_Sharee_Number is not null and P_Sharee_Number <> fnd_api.g_miss_num)
       and (l_pricebasedonowner = 'N')
       and (x_privilege_type_code = 'A'
            or x_privilege_type_code = 'F')) THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('call IBE_Quote_Save_pvt.updatequoteforshare');
     END IF;
     l_qte_header_rec.price_list_id := p_price_list_id;
     l_qte_header_rec.currency_code := p_currency_code;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('call IBE_Quote_Save_pvt.updatequoteforsharee at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
     END IF;

     IBE_Quote_Save_pvt.get_quote_expiration_date(
              p_api_version      => 1.0                     ,
              p_init_msg_list    => FND_API.G_TRUE          ,
              p_commit           => FND_API.G_FALSE         ,
              x_return_status    => x_return_status         ,
              x_msg_count        => x_msg_count             ,
              x_msg_data         => x_msg_data              ,
              p_quote_header_rec => l_qte_header_rec        ,
              x_expiration_date  => l_expiration_date_tmp   );
     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_qte_header_rec.quote_expiration_date := l_expiration_date_tmp;

     IBE_Quote_Save_pvt.UpdateQuoteForSharee
     (      p_api_version_number         => p_api_version_number
            ,p_init_msg_list             => FND_API.G_FALSE
            ,p_commit                    => FND_API.G_FALSE
            ,p_sharee_party_id           => p_sharee_party_id
            ,p_sharee_cust_account_id    => p_sharee_cust_account_id
            ,p_control_rec               => p_control_rec
            ,p_qte_header_rec            => l_qte_header_rec
            ,x_qte_header_rec            => l_qte_header_rec_tmp
            ,x_qte_line_tbl              => lx_qte_line_tbl
            ,X_Return_Status             => X_Return_Status
            ,X_Msg_Count                 => X_Msg_Count
            ,X_Msg_Data                  => X_Msg_Data
     );
     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     l_qte_header_rec := l_qte_header_rec_tmp;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('done IBE_Quote_Save_pvt.updatequoteforsharee at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
     END IF;
  END IF;

  x_quote_header_id  := l_qte_header_rec.quote_header_id;
  x_last_update_date := l_qte_header_rec.last_update_date;

   -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

    -- Standard call to get message count and IF count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.RetrieveShareQuote');
      END IF;
      ROLLBACK TO RETRIEVESHAREQUOTE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unexpected exception in IBE_QUOTE_SAVESHARE_PVT.RetrieveShareQuote');
      END IF;
      ROLLBACK TO RETRIEVESHAREQUOTE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unknown exception in IBE_QUOTE_SAVESHARE_PVT.RetrieveShareQuote');
      END IF;
      ROLLBACK TO RETRIEVESHAREQUOTE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END RetrieveshareQuote;

PROCEDURE MergeActiveQuote(
   p_api_version_number IN  NUMBER                         ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id    IN  NUMBER                         ,
   p_last_update_date   IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_mode               IN  VARCHAR2 := 'MERGE'            ,
   p_combinesameitem    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_id           IN  NUMBER                         ,
   p_cust_account_id    IN  NUMBER                         ,
   p_quote_source_code  IN  VARCHAR2 := 'IStore Account'   ,
   p_minisite_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_currency_code      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_list_id      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_control_rec        IN  ASO_Quote_Pub.Control_Rec_Type := ASO_Quote_Pub.G_MISS_Control_Rec,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE                           ,
   x_retrieval_number   OUT NOCOPY NUMBER
)
IS
   l_api_name             CONSTANT VARCHAR2(30)   := 'MergeActiveQuote';
   l_api_version          CONSTANT NUMBER         := 1.0;
   l_db_qte_header_rec     ASO_Quote_Pub.qte_header_rec_type
                          := ASO_Quote_Pub.g_miss_qte_header_rec;

   l_in_qte_header_rec     ASO_Quote_Pub.qte_header_rec_type
                          :=  ASO_Quote_Pub.g_miss_qte_header_rec;

   l_default_save_qte_hdr_rec     ASO_Quote_Pub.qte_header_rec_type
                          := ASO_Quote_Pub.g_miss_qte_header_rec;

   l_quote_header_id       number;

   l_promote_guest_cart   VARCHAR2(2) := FND_API.G_FALSE;
   l_retrieval_number     NUMBER;
   l_resource_id          NUMBER;
   l_publish_flag         VARCHAR2(1);
   l_currency_code        VARCHAR2(100);
   l_control_rec          ASO_Quote_Pub.Control_Rec_Type
                          := ASO_Quote_Pub.G_MISS_Control_Rec;

   cursor c_getHdr(p_quote_header_id number) is
   select quote_header_id,
          last_update_date,
          quote_name,
          party_id,
          cust_account_id,
          currency_code
   from aso_quote_headers
   where quote_header_id = p_quote_header_id;

   cursor c_getIdDate(p_party_id number
                     ,p_cust_account_id number
                     ,p_quote_source_code varchar2) is
   select quote_header_id,last_update_date
   from aso_quote_headers
   where party_id = p_party_id
   and cust_account_id = p_cust_account_id
   and quote_name = 'IBEACTIVECART'
   and quote_source_code = p_quote_source_code
   and trunc(quote_expiration_date) >= trunc(sysdate) --QUOTE EXPIRATION CHECK.
   and order_id is null;

   cursor c_get_retrieval_num(c_party_id        number,
                              c_cust_account_id number,
                              c_quote_header_id number)   is
   select quote_sharee_number
   from ibe_sh_quote_access
   where quote_header_id = c_quote_header_id
   and party_id = c_party_id
   and cust_account_id = c_cust_account_id;

   cursor c_get_quote_details(c_quote_header_id number) is
	select resource_id, publish_flag
	from aso_quote_headers
	where quote_header_id = c_quote_header_id;

   rec_getHdr                  c_getHdr%rowtype;
   rec_get_retrieval_num       c_get_retrieval_num%rowtype;
   -- 8/12/02: added the following parameters for Default Feature
   lx_Hd_Price_Attributes_Tbl  ASO_Quote_Pub.Price_Attributes_Tbl_Type  := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl;
   lx_Hd_Payment_Tbl           ASO_Quote_Pub.Payment_Tbl_Type           := ASO_Quote_Pub.G_MISS_PAYMENT_TBL;
   lx_Hd_Shipment_Tbl          ASO_Quote_Pub.Shipment_Tbl_Type          := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL;
   lx_Hd_Freight_Charge_Tbl    ASO_Quote_Pub.Freight_Charge_Tbl_Type    := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl;
   lx_Hd_Tax_Detail_Tbl        ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE        := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl;
   lx_Price_Adjustment_Tbl     ASO_Quote_Pub.Price_Adj_Tbl_Type         := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl;
   lx_Price_Adj_Attr_Tbl       ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type    := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl;
   lx_Price_Adj_Rltship_Tbl    ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl;

    -- temp vars for OUT params (NOCOPY chngs)
   l_quote_header_id_tmp number;
   l_last_update_date_tmp DATE;
   lx_Hd_Price_Attributes_Tbl_tmp  ASO_Quote_Pub.Price_Attributes_Tbl_Type  := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl;
   lx_Hd_Payment_Tbl_tmp           ASO_Quote_Pub.Payment_Tbl_Type           := ASO_Quote_Pub.G_MISS_PAYMENT_TBL;
   lx_Hd_Shipment_Tbl_tmp          ASO_Quote_Pub.Shipment_Tbl_Type          := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL;
   lx_Hd_Freight_Charge_Tbl_tmp    ASO_Quote_Pub.Freight_Charge_Tbl_Type    := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl;
   lx_Hd_Tax_Detail_Tbl_tmp        ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE        := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl;
   lx_Price_Adjustment_Tbl_tmp     ASO_Quote_Pub.Price_Adj_Tbl_Type         := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl;
   lx_Price_Adj_Attr_Tbl_tmp       ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type    := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl;
   lx_Price_Adj_Rltship_Tbl_tmp    ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl;
   l_db_qte_header_rec_tmp         ASO_Quote_Pub.qte_header_rec_type
                                   := ASO_Quote_Pub.g_miss_qte_header_rec;

   --end of default feature params
   --MANNAMRA: 09/16/02 for save/share
   l_saveshare_control_rec       IBE_QUOTE_SAVESHARE_V2_PVT.saveshare_control_rec_type
                                 := IBE_QUOTE_SAVESHARE_V2_PVT.g_miss_saveshare_control_rec;

   cursor c_get_line_msiteId (l_quote_header_id number)
   is
     select minisite_id
       from aso_quote_lines
       where QUOTE_HEADER_ID = l_quote_header_id
       order by quote_line_id;
   rec_get_line_msiteId          c_get_line_msiteId%rowtype;

   -- Added for the bug 3346204.
   l_handle_exception  number; -- 0 for Save both the carts, 1 for promoting guest cart as account active cart

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('MergeActiveQuote: Start');
  END IF;
  -- Standard Start of API savepoint
  SAVEPOINT    MergeActiveQuote_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('MergeActiveQuote: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('MergeActiveQuote: After Calling log_environment_info');
   END IF;

  open c_getHdr(p_quote_header_id);
  fetch c_getHdr into
       l_in_qte_header_rec.quote_header_id
       ,l_in_qte_header_rec.last_update_date
       ,l_in_qte_header_rec.quote_name
       ,l_in_qte_header_rec.party_id
       ,l_in_qte_header_rec.cust_account_id
       ,l_currency_code;
  close c_getHdr;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('MergeActiveQuote: look at quote_source_code');
  END IF;
  IF (p_quote_source_code is null
      or p_quote_source_code = fnd_api.g_miss_char) THEN
        l_in_qte_header_rec.quote_source_code := 'IStore Account';
    else
        l_in_qte_header_rec.quote_source_code := p_quote_source_code;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('MergeActiveQuote: checking guest cart id');
  END IF;
  IF ( l_in_qte_header_rec.quote_header_id <> fnd_api.g_miss_num
       and l_in_qte_header_rec.quote_header_id is not null
       and l_in_qte_header_rec.quote_name <> 'IBE_PRMT_SC_UNNAMED' ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_SC_ERR_ACTIVECART');
      FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*open c_getIDDate(p_party_id, p_cust_account_id, l_in_qte_header_rec.quote_source_code);
  fetch c_getIDDate into*/

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('MergeActiveQuote: before getActiveQuote');
  END IF;
  --Retrieve the database(account active cart) quote header id
  l_db_qte_header_rec.quote_header_id
  := IBE_Quote_Misc_pvt.get_active_quote_id(
                         p_party_id        => p_party_id ,
                         p_cust_account_id => p_cust_account_id);

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('MergeActiveQuote: l_db_qte_header_rec.quote_header_id='||l_db_qte_header_rec.quote_header_id);
  END IF;
  -- 8/12/02: Default Feature: Added to get values for db acct active cart: to be passed to get default api's
  open c_getHdr(l_db_qte_header_rec.quote_header_id);
  fetch c_getHdr into
       l_db_qte_header_rec.quote_header_id
       ,l_db_qte_header_rec.last_update_date
       ,l_db_qte_header_rec.quote_name
       ,l_db_qte_header_rec.party_id
       ,l_db_qte_header_rec.cust_account_id
       ,l_currency_code;
  close c_getHdr;

  -- try to get the minsite Id

  -- 9/9/02: Defaulting feature
  --  for the case when the user doesn't have an Account Active Cart
  if ((l_db_qte_header_rec.quote_header_id <> fnd_api.g_miss_num) and (l_db_qte_header_rec.quote_header_id is not null) ) then
    l_quote_header_id := l_db_qte_header_rec.quote_header_id;
  else
    l_quote_header_id := l_in_qte_header_rec.quote_header_id;
  end if;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('MergeActiveQutoe: get minisiteId#1 -- use quoteHeaderId='||l_quote_header_id);
  END IF;
  --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: get minisiteId#1 -- use quoteHeaderId='||l_quote_header_id);
  open c_get_line_msiteId (l_quote_header_id);
  fetch c_get_line_msiteId into rec_get_line_msiteId;
  close c_get_line_msiteId;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('MergeActiveQutoe: get minisiteId#1:'||rec_get_line_msiteId.minisite_id);
  END IF;
  --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: get minisiteId#1:'||rec_get_line_msiteId.minisite_id);

  -- 9/9/02: Defaulting feature
  --  for the case when the user has an empty Account Active Cart
  if ((rec_get_line_msiteId.minisite_id = fnd_api.g_miss_num) or (rec_get_line_msiteId.minisite_id is null) ) then
    l_quote_header_id := l_in_qte_header_rec.quote_header_id;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('MergeActiveQutoe: get minisiteId#2 -- use quoteHeaderId='||l_quote_header_id);
    END IF;
    --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: get minisiteId#2 -- use quoteHeaderId='||l_quote_header_id);
    open c_get_line_msiteId (l_quote_header_id);
    fetch c_get_line_msiteId into rec_get_line_msiteId;
    close c_get_line_msiteId;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('MergeActiveQutoe: get minisiteId#2:'||rec_get_line_msiteId.minisite_id);
    END IF;
    --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: get minisiteId#2:'||rec_get_line_msiteId.minisite_id);
  end if;

  l_saveshare_control_rec.control_rec        := p_control_rec;
  l_saveshare_control_rec.combinesameitem    := p_combinesameitem;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('mergeActiveQuote: start the conditions');
     IBE_Util.Debug('input price list id: ' || p_price_list_id);
  END IF;
  IF ( l_in_qte_header_rec.quote_header_id <> fnd_api.g_miss_num
       and l_in_qte_header_rec.quote_header_id is not null ) THEN --If passed in cart is not null

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('qte_in is not null');
      END IF;
      IF (l_db_qte_header_rec.quote_header_id <> fnd_api.g_miss_num --If database cart is not null
            and l_db_qte_header_rec.quote_header_id is not null
            and l_db_qte_header_rec.quote_header_id <> 0) THEN

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('qte_db is not null');
         END IF;
         IF (l_in_qte_header_rec.quote_header_id <>
                     l_db_qte_header_rec.quote_header_id ) THEN
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.DEBUG('input quote_header_id <> quote_header_id in db');
             END IF;
            IF (p_mode = 'MERGE') THEN   -- combine two cart
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE:Mode is merge');
              END IF;
              -- added 8/11/02: for Default Feature: we have to see if we need to default by calling getHdrDefaultValues:
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_Util.Debug('MergeActiveQutoe: check to see if we can call getHdrDefaultValues');
              END IF;
               --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: check to see if we can call getHdrDefaultValues');
              FOR rec_is_shared_cart in c_is_shared_cart(l_db_qte_header_rec.quote_header_id) LOOP
              /*If the destination cart is a shared cart then promote guest cart as the
              active cart, this is because a guest cart cannot be merged into a shared active cart*/
                IF (nvl(rec_is_shared_cart.yes_shared_cart,0) > 0) THEN
                  l_promote_guest_cart := FND_API.G_TRUE;
                END IF;
               END LOOP;

               /* If the destination cart is a Published Quote then promote guest cart as the active cart. */
               	OPEN c_get_quote_details(l_db_qte_header_rec.quote_header_id);
	        	FETCH c_get_quote_details into l_resource_id, l_publish_flag;
            	CLOSE c_get_quote_details;

	            IF (l_resource_id is not null and l_publish_flag ='Y') THEN
                  l_promote_guest_cart := FND_API.G_TRUE;
            	END IF;

               IF(l_promote_guest_cart <> FND_API.G_TRUE) THEN

                  if ((rec_get_line_msiteId.minisite_id is not null) or
                     (rec_get_line_msiteId.minisite_id <> fnd_api.g_miss_num) ) then
                   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                      IBE_Util.Debug('MergeActiveQuote : About to call getHdrDefaultValues');
                      IBE_Util.Debug(' partyid       :'||l_db_qte_header_rec.party_id);
                      IBE_Util.Debug(' accountid     :'||l_db_qte_header_rec.cust_account_id);
                      IBE_Util.Debug(' quoteheaderid :'||l_db_qte_header_rec.quote_header_id);
                   END IF;
                   --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: About to call getHdrDefaultValues');
                    IBE_Quote_Save_pvt.getHdrDefaultValues(
                      P_Api_Version_Number          => p_api_version_number
                     ,p_Init_Msg_List               => p_init_msg_list
                     ,p_Commit                      => p_commit
                     ,p_minisite_id                 => rec_get_line_msiteId.minisite_id
                     ,p_Qte_Header_Rec              => l_db_qte_header_rec
                     ,p_hd_price_attributes_tbl     => lx_Hd_Price_Attributes_Tbl
                     ,p_hd_payment_tbl              => lx_Hd_Payment_Tbl
                     ,p_hd_shipment_tbl             => lx_Hd_Shipment_Tbl
                     ,p_hd_freight_charge_tbl       => lx_Hd_Freight_Charge_Tbl
                     ,p_hd_tax_detail_tbl           => lx_Hd_Tax_Detail_Tbl
                     ,p_price_adjustment_tbl        => lx_Price_Adjustment_Tbl
                     ,p_price_adj_attr_tbl          => lx_Price_Adj_Attr_Tbl
                     ,p_price_adj_rltship_tbl       => lx_Price_Adj_Rltship_Tbl
                     ,x_Qte_Header_Rec              => l_db_qte_header_rec_tmp
                     ,x_Hd_Price_Attributes_Tbl     => lx_Hd_Price_Attributes_Tbl_tmp
                     ,x_Hd_Payment_Tbl              => lx_Hd_Payment_Tbl_tmp
                     ,x_Hd_Shipment_Tbl             => lx_Hd_Shipment_Tbl_tmp
                     ,x_Hd_Freight_Charge_Tbl       => lx_Hd_Freight_Charge_Tbl_tmp
                     ,x_Hd_Tax_Detail_Tbl           => lx_Hd_Tax_Detail_Tbl_tmp
                     ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl_tmp
                     ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl_tmp
                     ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl_tmp
                     ,x_last_update_date            => x_last_update_date
                     ,x_Return_Status               => x_Return_Status
                     ,x_Msg_Count                   => x_Msg_Count
                     ,x_Msg_Data                    => x_Msg_Data);
                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                      IBE_Util.Debug('MergeActiveQutoe: Back from calling getHdrDefaultValues');
                      IBE_Util.Debug('MergeActiveQuote: Assigning OUT params here');
                    END IF;
                    l_db_qte_header_rec := l_db_qte_header_rec_tmp;
                    lx_Hd_Price_Attributes_Tbl := lx_Hd_Price_Attributes_Tbl_tmp;
                    lx_Hd_Payment_Tbl := lx_Hd_Payment_Tbl_tmp;
                    lx_Hd_Shipment_Tbl := lx_Hd_Shipment_Tbl_tmp;
                    lx_Hd_Freight_Charge_Tbl := lx_Hd_Freight_Charge_Tbl_tmp;
                    lx_Hd_Tax_Detail_Tbl := lx_Hd_Tax_Detail_Tbl_tmp;
                    lx_Price_Adjustment_Tbl := lx_Price_Adjustment_Tbl_tmp;
                    lx_Price_Adj_Attr_Tbl := lx_Price_Adj_Attr_Tbl_tmp;
                    lx_Price_Adj_Rltship_Tbl := lx_Price_Adj_Rltship_Tbl_tmp;
                    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                      IBE_Util.Debug('DB Quote info: ' || l_db_qte_header_rec.party_id ||'##' ||l_db_qte_header_rec.quote_header_id);
                    End if;
                    --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: Back from calling getHdrDefaultValues');
                  end if; -- if we can find the minisiteId

                IBE_QUOTE_SAVESHARE_pvt.AppendToReplaceShare
                  (  P_Api_Version_Number       => p_api_version_number
                    ,p_Init_Msg_List            => fnd_api.g_false
                    ,P_Commit                   => fnd_api.g_false
                    ,p_Original_Quote_Header_Id => l_in_qte_header_rec.quote_header_id
                    ,p_last_update_date         => l_in_qte_header_rec.last_update_date
                    ,P_REP_App_Quote_Header_id  => l_db_qte_header_rec.quote_header_id
                    ,p_currency_code            => p_currency_code
                    ,p_price_list_id            => p_price_list_id
                    ,p_control_rec              => p_control_rec
                    ,p_combinesameitem          => p_combinesameitem
                    ,p_mode                     => 'APPENDTO'
                    ,p_rep_app_invTo_partySiteId => l_db_qte_header_rec.invoice_to_party_site_id
                    ,p_hd_price_attributes_tbl  => lx_Hd_Price_Attributes_Tbl
                    ,p_hd_payment_tbl           => lx_Hd_Payment_Tbl
                    ,p_hd_shipment_tbl          => lx_Hd_Shipment_Tbl
                    ,p_hd_freight_charge_tbl    => lx_Hd_Freight_Charge_Tbl
                    ,p_hd_tax_detail_tbl        => lx_Hd_Tax_Detail_Tbl
                    ,p_price_adjustment_tbl     => lx_Price_Adjustment_Tbl
                    ,p_price_adj_attr_tbl       => lx_Price_Adj_Attr_Tbl
                    ,p_price_adj_rltship_tbl    => lx_Price_Adj_Rltship_Tbl
                    ,X_Quote_Header_Id          => l_quote_header_id_tmp
                    ,x_last_update_date         => l_last_update_date_tmp
                    ,X_Return_Status            => x_return_status
                    ,X_Msg_Count                => x_msg_count
                    ,X_Msg_Data                 => x_msg_data);

                    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                      l_handle_exception := 0;
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                      IBE_UTIL.DEBUG('Assigns OUT params');
                    END IF;
                    l_db_qte_header_rec.quote_header_id := l_quote_header_id_tmp;
                    l_db_qte_header_rec.last_update_date := l_last_update_date_tmp;

                    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                       IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE: done merge');
                    END IF;


                   IBE_Quote_Save_pvt.Delete
                    (   p_api_version_number  => p_api_version_number
                       ,p_init_msg_list       => FND_API.G_false
                       ,p_commit              => FND_API.G_false
                       ,p_quote_header_id     => l_in_qte_header_rec.quote_header_id
                       ,p_last_update_date    => l_in_qte_header_rec.last_update_date
                       ,p_expunge_flag        => FND_API.G_true
                       ,X_Return_Status       => x_Return_Status
                       ,X_Msg_Count           => x_Msg_Count
                       ,X_Msg_Data            => x_Msg_Data);

                    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                       IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE: done merge: +delete');
                    END IF;

                    x_quote_header_id := l_db_qte_header_rec.quote_header_id;
                    x_last_update_date := l_db_qte_header_rec.last_update_date;
                  END IF;

             elsif (p_mode ='KEEP') THEN

               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE: mode is keep');
                  --IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE: Calling delete on account active cart');
               END IF;
               if (l_db_qte_header_rec.quote_name = 'IBE_PRMT_SC_UNNAMED') then
                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                   IBE_UTIL.DEBUG('Active cart was unnamed, calling IBE_Quote_Save_pvt.SAVE to default save the active cart');
                 END IF;
                 l_default_save_qte_hdr_rec.quote_header_id := l_db_qte_header_rec.quote_header_id;
                 l_default_save_qte_hdr_rec.last_update_date := l_db_qte_header_rec.last_update_date;
                 l_default_save_qte_hdr_rec.quote_name := 'IBE_PRMT_SC_DEFAULTNAMED';

                 IBE_Quote_Save_pvt.save(
                   p_api_version_number => p_api_version_number               ,
                   p_init_msg_list      => fnd_api.g_false                    ,
                   p_commit             => fnd_api.g_false                    ,
                   p_qte_header_rec     => l_default_save_qte_hdr_rec         ,
                   x_quote_header_id    => l_quote_header_id_tmp              ,
                   x_last_update_date   => l_last_update_date_tmp             ,

                   x_return_status      => x_return_status                    ,
                   x_msg_count          => x_msg_count                        ,
                   x_msg_data           => x_msg_data);

                 IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
                 l_db_qte_header_rec.quote_header_id := l_quote_header_id_tmp;
                 l_db_qte_header_rec.last_update_date := l_last_update_date_tmp;

                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                   IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE: Done keep: updating cart name to defaultnamed');
                 END IF;
               end if; -- end if quote name was unnamed
               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE: Deactivating account active cart (since mode = KEEP)');
               END IF;
               IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
                 P_Quote_header_id  => l_db_qte_header_rec.quote_header_id ,
                 P_Party_id         => l_db_qte_header_rec.party_id        ,
                 P_Cust_account_id  => l_db_qte_header_rec.Cust_account_id ,
--                 P_minisite_id      => p_minisite_id                      ,
                 p_api_version      => p_api_version_number               ,
                 p_init_msg_list    => fnd_api.g_false                    ,
                 p_commit           => fnd_api.g_false                    ,
                 x_return_status    => x_return_status                    ,
                 x_msg_count        => x_msg_count                        ,
                 x_msg_data         => x_msg_data                         );

               IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               l_promote_guest_cart := FND_API.G_TRUE;
               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('keep: done');
               END IF;

             elsif (p_mode ='REMOVE') THEN

                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                   IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE:start remove');
                END IF;
                IBE_Quote_Save_pvt.Delete
                (   p_api_version_number  => p_api_version_number
                     ,p_init_msg_list     => FND_API.G_false
                     ,p_commit            => FND_API.G_false
                     ,p_quote_header_id   => l_in_qte_header_rec.quote_header_id
                     ,p_last_update_date  => l_in_qte_header_rec.last_update_date
                     ,p_expunge_flag      => FND_API.g_true  --added expunge_flag param
                     ,X_Return_Status     => x_Return_Status
                     ,X_Msg_Count         => x_Msg_Count
                     ,X_Msg_Data          => x_Msg_Data
                );
                IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                x_quote_header_id := l_db_qte_header_rec.quote_header_id;
                x_last_update_date := l_db_qte_header_rec.last_update_date;

                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                   IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE: remove: after delete');
                END IF;
             END IF;
         else -- pass in quote is same as quote in db

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('in = db');
            END IF;
            x_quote_header_id := l_in_qte_header_rec.quote_header_id;
            x_last_update_date := l_in_qte_header_rec.last_update_date;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('in = db: done');
            END IF;
         END IF;


      else -- no quote id in database
        l_promote_guest_cart := FND_API.G_TRUE;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('No quote in database hence promoting guest cart ');
        END IF;
      END IF;

  ELSE -- no quote_id passed in
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('no q_in');
     END IF;
     -- 8/13/02: Default Feature: the case when there is no guest cart.
     IF (l_db_qte_header_rec.quote_header_id <> fnd_api.g_miss_num
            and l_db_qte_header_rec.quote_header_id is not null
            and l_db_qte_header_rec.quote_header_id <> 0) THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_Util.Debug('MergeActiveQutoe -- when no quoteId is passed in: check to see if we can call getHdrDefaultValues');
              END IF;
              --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe -- when no quoteId is passed in: check to see if we can call getHdrDefaultValues');

              if ((rec_get_line_msiteId.minisite_id is not null) or (rec_get_line_msiteId.minisite_id <> fnd_api.g_miss_num) ) then
                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_Util.Debug('MergeActiveQuote: About to call getHdrDefaultValues');
                 END IF;
                 --DBMS_OUTPUT.PUT_LINE('MergeActiveQuote: About to call getHdrDefaultValues');
                 IBE_Quote_Save_pvt.getHdrDefaultValues(
                   P_Api_Version_Number          => p_api_version_number
                  ,p_Init_Msg_List               => p_init_msg_list
                  ,p_Commit                      => p_commit
                  ,p_minisite_id                 => rec_get_line_msiteId.minisite_id
                  ,p_Qte_Header_Rec              => l_db_qte_header_rec
                  ,p_hd_price_attributes_tbl     => lx_Hd_Price_Attributes_Tbl
                  ,p_hd_payment_tbl              => lx_Hd_Payment_Tbl
                  ,p_hd_shipment_tbl             => lx_Hd_Shipment_Tbl
                  ,p_hd_freight_charge_tbl       => lx_Hd_Freight_Charge_Tbl
                  ,p_hd_tax_detail_tbl           => lx_Hd_Tax_Detail_Tbl
                  ,p_price_adjustment_tbl        => lx_Price_Adjustment_Tbl
                  ,p_price_adj_attr_tbl          => lx_Price_Adj_Attr_Tbl
                  ,p_price_adj_rltship_tbl       => lx_Price_Adj_Rltship_Tbl
                  ,x_Qte_Header_Rec              => l_db_qte_header_rec_tmp
                  ,x_Hd_Price_Attributes_Tbl     => lx_Hd_Price_Attributes_Tbl_tmp
                  ,x_Hd_Payment_Tbl              => lx_Hd_Payment_Tbl_tmp
                  ,x_Hd_Shipment_Tbl             => lx_Hd_Shipment_Tbl_tmp
                  ,x_Hd_Freight_Charge_Tbl       => lx_Hd_Freight_Charge_Tbl_tmp
                  ,x_Hd_Tax_Detail_Tbl           => lx_Hd_Tax_Detail_Tbl_tmp
                  ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl_tmp
                  ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl_tmp
                  ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl_tmp
                  ,x_last_update_date            => x_last_update_date
                  ,X_Return_Status               => x_Return_Status
                  ,X_Msg_Count                   => x_Msg_Count
                  ,X_Msg_Data                    => x_Msg_Data
                  );
                 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

                 l_db_qte_header_rec := l_db_qte_header_rec_tmp;
                 lx_Hd_Price_Attributes_Tbl := lx_Hd_Price_Attributes_Tbl_tmp;
                 lx_Hd_Payment_Tbl := lx_Hd_Payment_Tbl_tmp;
                 lx_Hd_Shipment_Tbl := lx_Hd_Shipment_Tbl_tmp;
                 lx_Hd_Freight_Charge_Tbl := lx_Hd_Freight_Charge_Tbl_tmp;
                 lx_Hd_Tax_Detail_Tbl := lx_Hd_Tax_Detail_Tbl_tmp;
                 lx_Price_Adjustment_Tbl := lx_Price_Adjustment_Tbl_tmp;
                 lx_Price_Adj_Attr_Tbl := lx_Price_Adj_Attr_Tbl_tmp;
                 lx_Price_Adj_Rltship_Tbl := lx_Price_Adj_Rltship_Tbl_tmp;

                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_Util.Debug('SUCCESS! MergeActiveQutoe: Back from calling getHdrDefaultValues');
                 END IF;
                 --DBMS_OUTPUT.PUT_LINE('MergeActiveQutoe: Back from calling getHdrDefaultValues');

                 -- 8/12/02: for Default Feature: added some more parameters
                 --Adding the currency code validation here.
                 /*IF (l_currency_code <> p_currency_code) THEN
                   l_control_rec.pricing_request_type          := 'ASO';--FND_Profile.Value('IBE_PRICE_REQUEST_TYPE');
                   l_control_rec.header_pricing_event          := FND_Profile.Value('IBE_INCART_PRICING_EVENT');
                   l_control_rec.line_pricing_event            := FND_Profile.Value('IBE_INCARTLINE_PRICING_EVENT');
                   l_control_rec.calculate_freight_charge_flag := 'Y';
                   l_control_rec.calculate_tax_flag            := 'Y';
                 END IF:*/
                 -- added for bug 3217154 - really price list id was being passed in the right places except here
                 l_db_qte_header_rec.price_list_id := p_price_list_id;
                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_Util.Debug('price list id: ' || l_db_qte_header_rec.price_list_id);
                 END IF;
                 IBE_Quote_Save_pvt.save
                 (   p_api_version_number       => p_api_version_number
                    ,p_init_msg_list            => FND_API.G_FALSE
                    ,p_commit                   => FND_API.G_FALSE
                    ,p_control_rec              => p_control_rec
                    ,p_qte_header_rec           => l_db_qte_header_rec
                    ,p_hd_price_attributes_tbl  => lx_Hd_Price_Attributes_Tbl
                    ,p_hd_payment_tbl           => lx_Hd_Payment_Tbl
                    ,p_hd_shipment_tbl          => lx_Hd_Shipment_Tbl
                    ,p_hd_freight_charge_tbl    => lx_Hd_Freight_Charge_Tbl
                    ,p_hd_tax_detail_tbl        => lx_Hd_Tax_Detail_Tbl
                    ,p_price_adjustment_tbl     => lx_Price_Adjustment_Tbl
                    ,p_price_adj_attr_tbl       => lx_Price_Adj_Attr_Tbl
                    ,p_price_adj_rltship_tbl    => lx_Price_Adj_Rltship_Tbl
                    ,x_quote_header_id          => l_quote_header_id_tmp
                    ,x_last_update_date         => l_last_update_date_tmp
                    ,x_return_status            => x_return_status
                    ,x_msg_count                => x_msg_count
                    ,x_msg_data                 => x_msg_data
                 );
                 IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   l_handle_exception := 0; -- No guest cart id passed in, exception in repricing the current cart
                   RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

                 l_db_qte_header_rec.quote_header_id := l_quote_header_id_tmp;
                 l_db_qte_header_rec.last_update_date := l_last_update_date_tmp;

              end if; -- if we can find the minisiteId

              for rec_getHdr in c_getHdr(l_db_qte_header_rec.quote_header_id) loop
                IF (p_party_id <> rec_getHdr.party_id) THEN
                  FOR rec_get_retrieval_num in c_get_retrieval_num(p_party_id,
                                                                   p_cust_account_id,
                                                                   l_db_qte_header_rec.quote_header_id) LOOP
                    l_retrieval_number := rec_get_retrieval_num.quote_sharee_number;
                    x_retrieval_number := l_retrieval_number;
                    EXIT  when c_get_retrieval_num%NOTFOUND;
                  END LOOP;
                END IF;
                EXIT  when c_getHdr%NOTFOUND;
              END LOOP;


     end if; -- db quote is valid
     x_quote_header_id  := l_db_qte_header_rec.quote_header_id;
     x_last_update_date := l_db_qte_header_rec.last_update_date;
  END IF;

  --Code for promoting a guest cart
  IF (l_promote_guest_cart = FND_API.G_TRUE) THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('*****************Code for promoting a guest cart*******************');
       IBE_UTIL.DEBUG('********MergeActiveQutoe:Promote guest cart flag is set to true**********');
       IBE_UTIL.DEBUG('MergeActiveQutoe:Guest party_id is: '||p_party_id);
       IBE_UTIL.DEBUG('MergeActiveQutoe:Guest cust_account_id is: '||p_cust_account_id);
       IBE_UTIL.DEBUG('MergeActiveQutoe:Guest header id: '||l_in_qte_header_rec.quote_header_id);
       IBE_UTIL.DEBUG('MergeActiveQutoe:quote name      : '||l_in_qte_header_rec.quote_name);

    END IF;

    l_in_qte_header_rec.party_id          := p_party_id;
    l_in_qte_header_rec.cust_account_id   := p_cust_account_id;
    l_in_qte_header_rec.quote_source_code := 'IStore Account';
    l_in_qte_header_rec.price_list_id     := p_price_list_id;
    l_in_qte_header_rec.currency_code     := p_currency_code;
    IF(l_in_qte_header_rec.quote_name <> 'IBE_PRMT_SC_UNNAMED') THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('MergeActiveQutoe:Changing guest cart name frm: '||l_in_qte_header_rec.quote_name||
                                         ' to IBE_PRMT_SC_UNNAMED');
      END IF;
      l_in_qte_header_rec.quote_name := 'IBE_PRMT_SC_UNNAMED';
    END IF;

    if ((rec_get_line_msiteId.minisite_id is not null) or
      (rec_get_line_msiteId.minisite_id <> fnd_api.g_miss_num) ) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('MergeActiveQuote: About to call getHdrDefaultValues during promotion');
      END IF;
      --DBMS_OUTPUT.PUT_LINE('MergeActiveQuote: About to call getHdrDefaultValues');
      IBE_Quote_Save_pvt.getHdrDefaultValues(
      P_Api_Version_Number          => p_api_version_number
     ,p_Init_Msg_List               => p_init_msg_list
     ,p_Commit                      => p_commit
     ,p_minisite_id                 => rec_get_line_msiteId.minisite_id
     ,p_Qte_Header_Rec              => l_in_qte_header_rec
     ,p_hd_price_attributes_tbl     => lx_Hd_Price_Attributes_Tbl
     ,p_hd_payment_tbl              => lx_Hd_Payment_Tbl
     ,p_hd_shipment_tbl             => lx_Hd_Shipment_Tbl
     ,p_hd_freight_charge_tbl       => lx_Hd_Freight_Charge_Tbl
     ,p_hd_tax_detail_tbl           => lx_Hd_Tax_Detail_Tbl
     ,p_price_adjustment_tbl        => lx_Price_Adjustment_Tbl
     ,p_price_adj_attr_tbl          => lx_Price_Adj_Attr_Tbl
     ,p_price_adj_rltship_tbl       => lx_Price_Adj_Rltship_Tbl
     ,x_Qte_Header_Rec              => l_db_qte_header_rec_tmp
     ,x_Hd_Price_Attributes_Tbl     => lx_Hd_Price_Attributes_Tbl_tmp
     ,x_Hd_Payment_Tbl              => lx_Hd_Payment_Tbl_tmp
     ,x_Hd_Shipment_Tbl             => lx_Hd_Shipment_Tbl_tmp
     ,x_Hd_Freight_Charge_Tbl       => lx_Hd_Freight_Charge_Tbl_tmp
     ,x_Hd_Tax_Detail_Tbl           => lx_Hd_Tax_Detail_Tbl_tmp
     ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl_tmp
     ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl_tmp
     ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl_tmp
     ,x_last_update_date            => x_last_update_date
     ,x_Return_Status               => x_Return_Status
     ,x_Msg_Count                   => x_Msg_Count
     ,x_Msg_Data                    => x_Msg_Data);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_in_qte_header_rec := l_db_qte_header_rec_tmp;
      lx_Hd_Price_Attributes_Tbl := lx_Hd_Price_Attributes_Tbl_tmp;
      lx_Hd_Payment_Tbl := lx_Hd_Payment_Tbl_tmp;
      lx_Hd_Shipment_Tbl := lx_Hd_Shipment_Tbl_tmp;
      lx_Hd_Freight_Charge_Tbl := lx_Hd_Freight_Charge_Tbl_tmp;
      lx_Hd_Tax_Detail_Tbl := lx_Hd_Tax_Detail_Tbl_tmp;
      lx_Price_Adjustment_Tbl := lx_Price_Adjustment_Tbl_tmp;
      lx_Price_Adj_Attr_Tbl := lx_Price_Adj_Attr_Tbl_tmp;
      lx_Price_Adj_Rltship_Tbl := lx_Price_Adj_Rltship_Tbl_tmp;


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('MergeActiveQuote: Back from calling getHdrDefaultValues');
      END IF;
      --DBMS_OUTPUT.PUT_LINE('MergeActiveQuote: Back from calling getHdrDefaultValues');
    else
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('MergeActiveQuote:Cannot find a minisite_id while calling getHdrDefaultValues');
      END IF;
    end if; -- if we can find the minisiteId

    --save the guest cart into account active cart of the user
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('MergeActiveQuote:saving the guest cart as account active cart of the user');
    END IF;
    IBE_Quote_Save_pvt.save(
        p_api_version_number       => p_api_version_number     ,
        p_init_msg_list            => fnd_api.g_false          ,
        p_commit                   => fnd_api.g_false          ,

         -- Mannamra: fix for 4374289
        p_hd_price_attributes_tbl  => lx_Hd_Price_Attributes_Tbl,
        p_hd_payment_tbl           => lx_Hd_Payment_Tbl         ,
        p_hd_shipment_tbl          => lx_Hd_Shipment_Tbl        ,
        p_hd_freight_charge_tbl    => lx_Hd_Freight_Charge_Tbl  ,
        p_hd_tax_detail_tbl        => lx_Hd_Tax_Detail_Tbl      ,
        p_price_adjustment_tbl     => lx_Price_Adjustment_Tbl   ,
        p_price_adj_attr_tbl       => lx_Price_Adj_Attr_Tbl     ,
        p_price_adj_rltship_tbl    => lx_Price_Adj_Rltship_Tbl  ,
        -- Mannamra:End of fix for 4374289

        p_qte_header_rec           => l_in_qte_header_rec      ,
        p_control_rec              => p_control_rec            ,
        x_quote_header_id          => l_quote_header_id_tmp    ,
        x_last_update_date         => l_last_update_date_tmp   ,

        x_return_status            => x_return_status          ,
        x_msg_count                => x_msg_count              ,
        x_msg_data                 => x_msg_data                );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        IF (p_mode = 'KEEP') THEN
          /* This is to save the current active cart in case of KEEP Option. */
          l_handle_exception := 0;
        ELSE
          l_handle_exception := 1;
        END IF;
        /* Promoting guest cart failed with exception, so promote guest cart and save the cart for that user */
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_in_qte_header_rec.quote_header_id := l_quote_header_id_tmp;
      l_in_qte_header_rec.last_update_date := l_last_update_date_tmp;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('MergeActiveQuote:DONE saving the guest cart as account active cart of the user');
       IBE_UTIL.DEBUG('MergeActiveQuote:Calling IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote');
       IBE_UTIL.DEBUG('MergeActiveQuote:l_in_qte_header_rec.quote_header_id: '||l_in_qte_header_rec.quote_header_id);
    END IF;
    IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE(
       P_Quote_header_rec => l_in_qte_header_rec                ,
       P_Party_id         => P_party_id                         ,
       P_Cust_account_id  => P_cust_account_id                  ,
       P_api_version      => p_api_version_number               ,
       P_init_msg_list    => FND_API.G_FALSE                    ,
       P_commit           => FND_API.G_FALSE                    ,
       x_return_status    => x_return_status                    ,
       x_msg_count        => x_msg_count                        ,
       x_msg_data         => x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('MergeActiveQutoe:DONE calling IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote');
    END IF;
  x_quote_header_id  := l_in_qte_header_rec.quote_header_id;
  x_last_update_date := l_in_qte_header_rec.last_update_date;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('MergeActiveQutoe:x_quote_header_id: '||x_quote_header_id);
     IBE_UTIL.DEBUG('MergeActiveQutoe:x_last_update_date: '||x_last_update_date);
  END IF;

  END IF;


  IF (x_quote_header_id = FND_API.G_MISS_NUM
      or x_quote_header_id = 0) THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('cant find quote header id -> return null');
     END IF;
     x_quote_header_id := NULL;
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('mergeActiveQuote: End');
  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.mergeActiveQuote');
      END IF;
      ROLLBACK TO MergeActiveQuote_pvt;
      -- Handle saving the carts...
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Exception:l_handle_exception = '||l_handle_exception);
      END IF;
      IF (l_handle_exception = 0) THEN
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('New exception handling, in case of few expected exception save the carts');
           END IF;
            if (l_db_qte_header_rec.quote_name = 'IBE_PRMT_SC_UNNAMED') then
                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                   IBE_UTIL.DEBUG('Exception: Active cart was unnamed, calling IBE_Quote_Save_pvt.SAVE to default save the active cart');
                 END IF;
                 l_default_save_qte_hdr_rec.quote_header_id := l_db_qte_header_rec.quote_header_id;
                 l_default_save_qte_hdr_rec.last_update_date := l_db_qte_header_rec.last_update_date;
                 l_default_save_qte_hdr_rec.quote_name := 'IBE_PRMT_SC_DEFAULTNAMED';

                 IBE_Quote_Save_pvt.save(
                   p_api_version_number => p_api_version_number               ,
                   p_init_msg_list      => fnd_api.g_false                    ,
                   p_commit             => fnd_api.g_true                    ,
                   p_qte_header_rec     => l_default_save_qte_hdr_rec         ,
                   x_quote_header_id    => l_quote_header_id_tmp              ,
                   x_last_update_date   => l_last_update_date_tmp             ,

                   x_return_status      => x_return_status                    ,
                   x_msg_count          => x_msg_count                        ,
                   x_msg_data           => x_msg_data);

                 l_db_qte_header_rec.quote_header_id := l_quote_header_id_tmp;
                 l_db_qte_header_rec.last_update_date := l_last_update_date_tmp;

                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                   IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE Exception: Done keep: updating cart name to defaultnamed');
                 END IF;
               end if; -- end if quote name was unnamed
               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_pvt.MERGE_QUOTE Exception: Deactivating account active cart (since mode = KEEP)');
               END IF;
               IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
                 P_Quote_header_id  => l_db_qte_header_rec.quote_header_id ,
                 P_Party_id         => l_db_qte_header_rec.party_id        ,
                 P_Cust_account_id  => l_db_qte_header_rec.Cust_account_id ,
                 p_api_version      => p_api_version_number               ,
                 p_init_msg_list    => fnd_api.g_false                    ,
                 p_commit           => fnd_api.g_true                    ,
                 x_return_status    => x_return_status                    ,
                 x_msg_count        => x_msg_count                        ,
                 x_msg_data         => x_msg_data                         );
       END IF; -- l_handle_exception is 0, to handle merge of 2 carts.

       IF (l_handle_exception = 0 OR l_handle_exception = 1) THEN

        IF ( l_in_qte_header_rec.quote_header_id <> fnd_api.g_miss_num
        and l_in_qte_header_rec.quote_header_id is not null ) THEN

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('*****************Code for promoting a guest cart in case of expected exception *******************');
          IBE_UTIL.DEBUG('********MergeActiveQutoe:Exception:Promote guest cart flag is set to true**********');
          IBE_UTIL.DEBUG('MergeActiveQutoe:Exception:Guest party_id is: '||p_party_id);
          IBE_UTIL.DEBUG('MergeActiveQutoe:Exception:Guest cust_account_id is: '||p_cust_account_id);
          IBE_UTIL.DEBUG('MergeActiveQutoe:Exception:Guest header id: '||l_in_qte_header_rec.quote_header_id);
          IBE_UTIL.DEBUG('MergeActiveQutoe:Exception:quote name      : '||l_in_qte_header_rec.quote_name);
        END IF;
        l_in_qte_header_rec.party_id          := p_party_id;
        l_in_qte_header_rec.cust_account_id   := p_cust_account_id;
        l_in_qte_header_rec.quote_source_code := 'IStore Account';
        l_in_qte_header_rec.price_list_id     := p_price_list_id;
        l_in_qte_header_rec.currency_code     := p_currency_code;
        l_in_qte_header_rec.quote_name := 'IBE_PRMT_SC_DEFAULTNAMED';

        if ((rec_get_line_msiteId.minisite_id is not null) or
         (rec_get_line_msiteId.minisite_id <> fnd_api.g_miss_num) ) then
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('MergeActiveQuote:Exception: About to call getHdrDefaultValues during promotion');
           END IF;

           IBE_Quote_Save_pvt.getHdrDefaultValues(
           P_Api_Version_Number          => p_api_version_number
           ,p_Init_Msg_List               => p_init_msg_list
           ,p_Commit                      => p_commit
           ,p_minisite_id                 => rec_get_line_msiteId.minisite_id
           ,p_Qte_Header_Rec              => l_in_qte_header_rec
           ,p_hd_price_attributes_tbl     => lx_Hd_Price_Attributes_Tbl
           ,p_hd_payment_tbl              => lx_Hd_Payment_Tbl
           ,p_hd_shipment_tbl             => lx_Hd_Shipment_Tbl
           ,p_hd_freight_charge_tbl       => lx_Hd_Freight_Charge_Tbl
           ,p_hd_tax_detail_tbl           => lx_Hd_Tax_Detail_Tbl
           ,p_price_adjustment_tbl        => lx_Price_Adjustment_Tbl
           ,p_price_adj_attr_tbl          => lx_Price_Adj_Attr_Tbl
           ,p_price_adj_rltship_tbl       => lx_Price_Adj_Rltship_Tbl
           ,x_Qte_Header_Rec              => l_db_qte_header_rec_tmp
           ,x_Hd_Price_Attributes_Tbl     => lx_Hd_Price_Attributes_Tbl_tmp
           ,x_Hd_Payment_Tbl              => lx_Hd_Payment_Tbl_tmp
           ,x_Hd_Shipment_Tbl             => lx_Hd_Shipment_Tbl_tmp
           ,x_Hd_Freight_Charge_Tbl       => lx_Hd_Freight_Charge_Tbl_tmp
           ,x_Hd_Tax_Detail_Tbl           => lx_Hd_Tax_Detail_Tbl_tmp
           ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl_tmp
           ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl_tmp
           ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl_tmp
           ,x_last_update_date            => x_last_update_date
           ,x_Return_Status               => x_Return_Status
           ,x_Msg_Count                   => x_Msg_Count
           ,x_Msg_Data                    => x_Msg_Data);
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
           IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           l_in_qte_header_rec := l_db_qte_header_rec_tmp;
           lx_Hd_Price_Attributes_Tbl := lx_Hd_Price_Attributes_Tbl_tmp;
           lx_Hd_Payment_Tbl := lx_Hd_Payment_Tbl_tmp;
           lx_Hd_Shipment_Tbl := lx_Hd_Shipment_Tbl_tmp;
           lx_Hd_Freight_Charge_Tbl := lx_Hd_Freight_Charge_Tbl_tmp;
           lx_Hd_Tax_Detail_Tbl := lx_Hd_Tax_Detail_Tbl_tmp;
           lx_Price_Adjustment_Tbl := lx_Price_Adjustment_Tbl_tmp;
           lx_Price_Adj_Attr_Tbl := lx_Price_Adj_Attr_Tbl_tmp;
           lx_Price_Adj_Rltship_Tbl := lx_Price_Adj_Rltship_Tbl_tmp;


       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('MergeActiveQuote:Exception: Back from calling getHdrDefaultValues');
      END IF;
      --DBMS_OUTPUT.PUT_LINE('MergeActiveQuote: Back from calling getHdrDefaultValues');
    else
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('MergeActiveQuote:Exception:Cannot find a minisite_id while calling getHdrDefaultValues');
      END IF;
    end if; -- if we can find the minisiteId

    --save the guest cart into account active cart of the user
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('MergeActiveQuote:Exception:saving the guest cart as account active cart of the user');
    END IF;
    IBE_Quote_Save_pvt.save(
        p_api_version_number => p_api_version_number               ,
        p_init_msg_list      => fnd_api.g_false                    ,
        p_commit             => fnd_api.g_true                    ,

        p_qte_header_rec     => l_in_qte_header_rec                ,
        x_quote_header_id    => l_quote_header_id_tmp              ,
        x_last_update_date   => l_last_update_date_tmp             ,

        x_return_status      => x_return_status                    ,
        x_msg_count          => x_msg_count                        ,
        x_msg_data           => x_msg_data                          );

       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       END IF;
       IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
          FND_Message.Set_Name('IBE', 'IBE_SC_MERGE_CART_ERROR');
          FND_Msg_Pub.Add;
       END IF;

      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.mergeActiveQuote');
      END IF;
      ROLLBACK TO MergeActiveQuote_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unknown exception in IBE_QUOTE_SAVESHARE_PVT.mergeActiveQuote');
      END IF;
      ROLLBACK TO MergeActiveQuote_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END MergeActiveQuote;

PROCEDURE EmailSharee(
  p_Api_Version_Number         IN   NUMBER
  ,p_Init_Msg_List             IN   VARCHAR2 := FND_API.G_FALSE
  ,p_Commit                    IN   VARCHAR2 := FND_API.G_FALSE

  ,p_Quote_Header_id           IN   NUMBER
  ,p_emailAddress              IN   varchar2
  ,p_privilegeType             IN   varchar2

  ,p_url                       IN   varchar2
  ,p_qte_access_rec            IN   IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Rec_Type
  ,p_comments                  IN   VARCHAR2 := FND_API.G_MISS_CHAR
  ,X_Return_Status             OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                 OUT NOCOPY  NUMBER
  ,X_Msg_Data                  OUT NOCOPY  VARCHAR2
)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'Emailsharee';
  l_api_version         CONSTANT NUMBER   := 1.0;
  l_url                 varchar2(2000);

  l_qte_header_rec      ASO_Quote_Pub.QTE_HEADER_REC_TYPE
                        := ASO_Quote_Pub.g_miss_qte_header_rec;

  cursor C_GETHEADERREC(qte_header_id number) is
  select quote_password, quote_number, quote_version
  from aso_quote_headers
  where quote_header_id = qte_header_id;

BEGIN

 -- Standard Start of API savepoint
  SAVEPOINT    EMAILSHAREE_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                            P_Api_Version_Number,
                                  l_api_name,
                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  open C_getheaderrec(P_Quote_Header_id);
  fetch c_getheaderrec into l_qte_header_rec.quote_password
                            ,l_qte_header_rec.quote_number
                            ,l_qte_header_rec.quote_version;
  close c_getheaderrec;

  if(l_qte_header_rec.quote_password = null or
   --  l_qte_header_rec.quote_password = ''   or
     l_qte_header_rec.quote_number = FND_API.g_miss_num or
     l_qte_header_rec.quote_version = FND_API.g_miss_num) THEN

     fnd_message.set_name('IBE', 'IBE_SH_INVALID_QUOTE_SHARE');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;

  END IF;

  l_url := '';
  l_url := l_url || 'retSharTSharNum=' || p_qte_access_rec.quote_sharee_number || '&';
  l_url := l_url || 'retSharTQuoteNum=' || l_qte_header_rec.quote_number || '&';
  l_url := l_url || 'retSharTVersion=' || l_qte_header_rec.quote_version;
  l_url := p_url || '&' || l_url;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('call IBE_WORKFLOW_pvt.NotifyForSharedCart starts');
  END IF;

  IBE_WORKFLOW_pvt.NotifyForSharedCart(
     p_api_version           => p_api_version_number
    ,p_init_msg_list         => p_init_msg_list
    ,p_msite_id              => NULL
    ,p_quote_header_id       => p_quote_header_id
    ,p_emailAddress          => p_emailAddress
    ,p_quoteShareeNum        => p_qte_access_rec.quote_sharee_number
    ,p_privilegeType         => p_privilegeType
    ,p_url                   => l_url
    ,p_comments              => p_comments
    ,x_return_status         => x_return_status
    ,x_msg_count             => x_msg_count
    ,x_msg_data              => x_msg_data
  );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('call IBE_WORKFLOW_PVT.NotifyForSharedCart finishes');
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('done IBE_WFNOTIFICATION.send_email at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;


   -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Expected exception in IBE_QUOTE_SAVESHARE_PVT.EmailSharee');
      END IF;
      ROLLBACK TO EMAILSHAREE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unexpected exception in IBE_QUOTE_SAVESHARE_PVT.EmailSharee');
      END IF;
      ROLLBACK TO EMAILSHAREE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Unknown exception in IBE_QUOTE_SAVESHARE_PVT.EmailSharee');
      END IF;
      ROLLBACK TO EMAILSHAREE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END emailsharee;

-- This procedure generates a random sharee number for quote.
PROCEDURE GenerateShareeNumber
(
    p_quote_header_id IN  NUMBER,
    p_recip_id        IN  NUMBER,
    x_sharee_number   OUT NOCOPY NUMBER
)
IS
   l_seed     NUMBER;
   l_rand     NUMBER;
   l_num_rows NUMBER;
BEGIN


    l_rand := FND_CRYPTO.SmallRandomNumber;
    IF l_rand < 0 THEN
        l_rand := l_rand * -1;
    END IF;
    x_sharee_number := to_number(substr((to_char(p_recip_id)||to_char(l_rand)),1,15));
END GenerateShareeNumber;

END IBE_QUOTE_SAVESHARE_pvt;

/
