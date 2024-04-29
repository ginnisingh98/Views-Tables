--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_TMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_TMPL_PVT" AS
/* $Header: asovqtmb.pls 120.3.12010000.6 2010/11/22 08:07:18 rassharm ship $ */

-- Start of Comments
-- Package name     : ASO_QUOTE_TMPL_PVT
-- Purpose          :
-- End of Comments



G_PKG_NAME           CONSTANT    VARCHAR2(30)                             := 'ASO_QUOTE_TMPL_PVT';
G_FILE_NAME          CONSTANT    VARCHAR2(12)                             := 'asovqtmb.pls';






PROCEDURE Add_Template_To_Quote(
    P_API_VERSION_NUMBER    IN   NUMBER,
    P_INIT_MSG_LIST         IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_COMMIT                IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN   NUMBER                                   := FND_API.G_VALID_LEVEL_FULL,
    P_UPDATE_FLAG           IN   VARCHAR2                                 := 'Y',
    P_TEMPLATE_ID_TBL       IN   ASO_QUOTE_TMPL_INT.LIST_TEMPLATE_TBL_TYPE,
    P_QTE_HEADER_REC        IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_CONTROL_REC           IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE           := ASO_QUOTE_PUB.G_MISS_control_REC,
    x_Qte_Line_Tbl         OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    x_Qte_Line_Dtl_Tbl     OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

    G_USER_ID                    NUMBER                                   := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                   NUMBER                                   := FND_GLOBAL.CONC_LOGIN_ID;

    L_API_NAME                   VARCHAR2(50)                             := 'Add_Template_To_Quote';
    L_API_VERSION    CONSTANT    NUMBER                                   := 1.0;

    l_template_line_count        NUMBER                                   := 0;
    l_conc_segments              VARCHAR2(40);
    l_top_model_line_id          NUMBER                                   := FND_API.G_MISS_NUM;
    l_dropped_flag               VARCHAR2(1)                              := 'N';
    l_service_flag               VARCHAR2(1)                              := 'N';
    l_config_header_id           NUMBER;
    l_config_rev_number          NUMBER;
    lx_config_header_id          NUMBER;
    lx_config_rev_number         NUMBER;
    lx_line_relationship_id      NUMBER;

    l_dropped_line_id_tbl        ASO_QUOTE_TMPL_INT.List_Template_Tbl_Type                   := ASO_QUOTE_TMPL_INT.G_Miss_List_Template_Tbl;
    l_search_line_id_tbl         ASO_QUOTE_TMPL_INT.List_Template_Tbl_Type                   := ASO_QUOTE_TMPL_INT.G_Miss_List_Template_Tbl;
    l_temp_line_dtl_tbl          ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_cfg_control_rec            ASO_CFG_INT.Control_rec_Type             := ASO_CFG_INT.G_Miss_Control_Rec;
    l_line_rltship_rec           ASO_QUOTE_PUB.Line_Rltship_Rec_Type      := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Rec;

    -- Variables to hold values to be passed to ASO_VALIDATE_PRICING_PVT.Validate_Pricing_Order()
    l_pricing_control_rec        ASO_PRICING_INT.Pricing_Control_Rec_Type;
    lp_Qte_Line_Tbl              ASO_QUOTE_PUB.Qte_Line_Tbl_Type          := ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl;
    lpx_Qte_Header_Rec           ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lpx_Qte_Line_Tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lpx_Qte_Line_Dtl_Tbl         ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lpx_Price_Adjustment_Tbl     ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    lpx_Price_Adj_Attr_Tbl       ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    lpx_Price_Adj_Rltship_Tbl    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

    -- Variables to hold values to be passed to ASO_QUOTE_PUB.Update_Quote()
    l_qte_header_rec             ASO_QUOTE_PUB.Qte_Header_Rec_type        := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
    l_qte_line_tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type          := ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl;
    l_qte_line_dtl_tbl           ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    X_Qte_Header_Rec             ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    --X_Qte_Line_Tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    --X_Qte_Line_Dtl_Tbl           ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    X_Hd_Price_Attributes_Tbl    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    X_Hd_Payment_Tbl             ASO_QUOTE_PUB.Payment_Tbl_Type;
    X_Hd_Shipment_Tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;
    X_Hd_Freight_Charge_Tbl      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    X_Hd_Tax_Detail_Tbl          ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    X_Line_Attr_Ext_Tbl          ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    X_line_rltship_tbl           ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
    X_Price_Adjustment_Tbl       ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    X_Price_Adj_Attr_Tbl         ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    X_Price_Adj_Rltship_Tbl      ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
    X_Ln_Price_Attributes_Tbl    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    X_Ln_Payment_Tbl             ASO_QUOTE_PUB.Payment_Tbl_Type;
    X_Ln_Shipment_Tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;
    X_Ln_Freight_Charge_Tbl      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    X_Ln_Tax_Detail_Tbl          ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    lx_orig_item_id_tbl CZ_API_PUB.number_tbl_type;
    lx_new_item_id_tbl  CZ_API_PUB.number_tbl_type;

    	TYPE search_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	l_orig_config_id_tbl search_type;

   -- ER 9433340
    l_validate_item    boolean;
    l_tmpl_org_id      number;
    l_prof_temp_filter  varchar2(1):=nvl(fnd_profile.value('ASO_FILTER_QUOTE_TEMPLATE_BY'),'Q');
    l_qte_organization_id number;

    CURSOR c_conc_segments (l_inventory_item_id NUMBER) IS
    SELECT concatenated_segments
      FROM MTL_SYSTEM_ITEMS_VL
     WHERE inventory_item_id = l_inventory_item_id;

    CURSOR c_config_lines (l_quote_line_id NUMBER) IS
    SELECT A.quote_line_id
      FROM ASO_QUOTE_LINE_DETAILS A
      WHERE (config_header_id, config_revision_num) = ( SELECT config_header_id, config_revision_num FROM ASO_QUOTE_LINE_DETAILS WHERE quote_line_id = l_quote_line_id );

    CURSOR c_service_lines (l_quote_line_id NUMBER) IS
    SELECT quote_line_id
      FROM ASO_QUOTE_LINE_DETAILS
     WHERE service_ref_line_id = l_quote_line_id;

    CURSOR c_service_items (l_inventory_item_id NUMBER, l_organization_id NUMBER) IS
    SELECT service_item_flag
      FROM MTL_SYSTEM_ITEMS_VL
     WHERE inventory_item_id = l_inventory_item_id
       AND organization_id = l_organization_id;

    CURSOR c_get_org_id ( l_qte_hdr_id NUMBER) IS
    SELECT org_id
    FROM   aso_quote_headers_all
    WHERE  quote_header_id = l_qte_hdr_id;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Add_Template_To_Quote_PVT;

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('******   Start of Add_Template_To_Quote API ******', 1, 'Y');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
        L_API_VERSION       ,
        P_API_VERSION_NUMBER,
        L_API_NAME          ,
        G_PKG_NAME
    ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    l_qte_header_rec                    := p_qte_header_rec;

    IF (p_qte_header_rec.org_id is null or p_qte_header_rec.org_id = fnd_api.g_miss_num ) then
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Input ogr_id is null or g_miss', 1, 'Y');
         aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: p_qte_header_rec.quote_header_id: ' || p_qte_header_rec.quote_header_id, 1, 'Y');
       END IF;

        open c_get_org_id(p_qte_header_rec.quote_header_id);
	   fetch c_get_org_id into l_qte_header_rec.org_id;
	   close c_get_org_id;



    END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: l_qte_header_rec.org_id: '|| l_qte_header_rec.org_id, 1, 'Y');
	 aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: p_qte_header_rec.org_id: '|| p_qte_header_rec.org_id, 1, 'Y');
	  aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:template filter profile value: '|| l_prof_temp_filter, 1, 'Y');
	    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: before setting org context '||p_template_id_tbl.count);
       END IF;



    FOR i IN 1..p_template_id_tbl.count LOOP
           -- ER 9433340
	   if l_prof_temp_filter<>'Q' then

	      -- Setting MOAC to pick lines data from other org
	      select org_id into l_tmpl_org_id from aso_quote_headers_all
	      where quote_header_id=p_template_id_tbl(i);
              mo_global.set_policy_context('S', l_tmpl_org_id);
        end if;
        l_qte_line_tbl := ASO_UTILITY_PVT.Query_Qte_Line_Rows_sort(p_template_id_tbl(i));
	 -- ER 9433340
	if l_tmpl_org_id=l_qte_header_rec.org_id then  -- same org id
            l_prof_temp_filter:='Q';
        end if;

	FOR j IN 1..l_qte_line_tbl.count LOOP
              -- Quote operating unit is same as template operating unit
	       if l_prof_temp_filter='Q' then
			l_validate_item:=true;
               else
	        --aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: entered else of profile');
	        -- validate item based on new operating unit
	         l_validate_item:=Validate_Item(
						p_qte_header_rec    => l_qte_header_rec,
						p_quote_line_id    =>     l_qte_line_tbl(j).quote_line_id,
						p_inventory_item_id => l_qte_line_tbl(j).inventory_item_id,
						--p_organization_id   => l_qte_line_tbl(j).organization_id,
						p_quantity          => l_qte_line_tbl(j).quantity,
						p_uom_code          => l_qte_line_tbl(j).uom_code);
                end if;

	    if  l_validate_item = true then
		l_template_line_count                  := l_template_line_count + 1;
		lp_qte_line_tbl(l_template_line_count) := l_qte_line_tbl(j);
		--  Updating the lines table with new organization id in case operating unit is different
		if l_prof_temp_filter<>'Q' then
		   if l_qte_header_rec.org_id<>l_tmpl_org_id then
		      mo_global.set_policy_context('S',  l_qte_header_rec.org_id);
                   end if;
		      l_qte_organization_id:=oe_sys_parameters.value(param_name => 'MASTER_ORGANIZATION_ID',p_org_id => l_qte_header_rec.org_id);
                      lp_qte_line_tbl(l_template_line_count).organization_id:=l_qte_organization_id;
		      lp_qte_line_tbl(l_template_line_count).org_id:=l_qte_header_rec.org_id;
		end if;
           end if;
        END LOOP;
        l_qte_line_tbl := ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl;
    END LOOP;

    l_pricing_control_rec.request_type  := 'ASO';
    l_pricing_control_rec.pricing_event := 'BATCH';

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: before Validate_Pricing_Order', 1, 'Y');
    END IF;

    ASO_VALIDATE_PRICING_PVT.Validate_Pricing_Order(
        p_api_version_number       => 1.0,
        p_init_msg_list            => FND_API.G_FALSE,
        p_commit                   => FND_API.G_FALSE,
        p_control_rec              => l_pricing_control_rec,
        p_qte_header_rec           => l_qte_header_rec,
        p_qte_line_tbl             => lp_qte_line_tbl,
        x_qte_header_rec           => lpx_qte_header_rec,
        x_qte_line_tbl             => lpx_qte_line_tbl,
        x_qte_line_dtl_tbl         => lpx_qte_line_dtl_tbl,
        x_price_adj_tbl            => lpx_price_adjustment_tbl,
        x_price_adj_attr_tbl       => lpx_price_adj_attr_tbl,
        x_price_adj_rltship_tbl    => lpx_price_adj_rltship_tbl,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:  after Validate_Pricing_Order', 1, 'Y');
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: start validated lines loop', 1, 'Y');
    END IF;

    FOR i IN 1..lpx_qte_line_tbl.count LOOP
        IF lpx_qte_line_tbl(i).pricing_status_code <> FND_API.G_RET_STS_SUCCESS THEN
            l_dropped_line_id_tbl(lpx_qte_line_tbl(i).quote_line_id) := lpx_qte_line_tbl(i).quote_line_id;

            FOR conc_segments_rec IN c_conc_segments(lpx_qte_line_tbl(i).inventory_item_id) LOOP
                l_conc_segments := conc_segments_rec.concatenated_segments;
            END LOOP;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: item has pricing error: ' || lpx_qte_line_tbl(i).pricing_status_text, 1, 'N');
		  END IF;
            FND_MESSAGE.Set_Name('ASO', 'ASO_QTM_INVALID_PRICELIST');
            FND_MESSAGE.Set_Token('INVITEM', l_conc_segments, FALSE);
            FND_MSG_PUB.ADD;

            IF lpx_qte_line_tbl(i).item_type_code IN ('MDL','CFG') THEN
                FOR config_lines_rec IN c_config_lines(lpx_qte_line_tbl(i).quote_line_id) LOOP
                    IF config_lines_rec.quote_line_id <> lpx_qte_line_tbl(i).quote_line_id THEN
                        l_dropped_line_id_tbl(config_lines_rec.quote_line_id) := config_lines_rec.quote_line_id;
                    END IF;
                END LOOP;
            END IF;

            FOR service_lines_rec IN c_service_lines(lpx_qte_line_tbl(i).quote_line_id) LOOP
                l_dropped_line_id_tbl(service_lines_rec.quote_line_id) := service_lines_rec.quote_line_id;
            END LOOP;
        END IF;
    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:   end validated lines loop', 1, 'Y');
    END IF;

    l_template_line_count := 0;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: start drop items loop', 1, 'Y');
    END IF;

    FOR i IN 1..lpx_qte_line_tbl.count LOOP
        l_dropped_flag := 'N';

        IF l_dropped_line_id_tbl.EXISTS(lpx_qte_line_tbl(i).quote_line_id) THEN
            l_dropped_flag := 'Y';
        END IF;

        IF l_dropped_flag = 'N' THEN
            l_template_line_count                                   := l_template_line_count + 1;
            l_qte_line_tbl(l_template_line_count)                   := lpx_qte_line_tbl(i);
            l_search_line_id_tbl(lpx_qte_line_tbl(i).quote_line_id) := l_template_line_count;
        END IF;
    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:   end drop items loop', 1, 'Y');
    END IF;

    l_template_line_count := 0;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: start line details loop', 1, 'Y');
    END IF;

    FOR i IN 1..l_qte_line_tbl.count LOOP
        IF l_qte_line_tbl(i).item_type_code IN ('MDL','CFG') THEN
            l_temp_line_dtl_tbl := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl;
            l_temp_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_tbl(i).quote_line_id);

            IF l_temp_line_dtl_tbl.count > 0 THEN
                l_template_line_count                                    := l_template_line_count + 1;
                l_qte_line_dtl_tbl(l_template_line_count)                := l_temp_line_dtl_tbl(1);
                l_qte_line_dtl_tbl(l_template_line_count).operation_code := 'CREATE';
                l_qte_line_dtl_tbl(l_template_line_count).qte_line_index := i;
                l_qte_line_dtl_tbl(l_template_line_count).quote_line_id  := NULL;

                IF l_search_line_id_tbl.EXISTS(l_qte_line_dtl_tbl(l_template_line_count).ref_line_id) THEN
                    l_qte_line_dtl_tbl(l_template_line_count).ref_line_index := l_search_line_id_tbl(l_qte_line_dtl_tbl(l_template_line_count).ref_line_id);
                    l_qte_line_dtl_tbl(l_template_line_count).ref_line_id    := NULL;
                END IF;

		       -- P1 10261431
		IF l_search_line_id_tbl.EXISTS(l_qte_line_dtl_tbl(l_template_line_count).top_model_line_id) THEN
                    l_qte_line_dtl_tbl(l_template_line_count).top_model_line_index := l_search_line_id_tbl(l_qte_line_dtl_tbl(l_template_line_count).top_model_line_id);
                    l_qte_line_dtl_tbl(l_template_line_count).top_model_line_id    := NULL;
                END IF;
                         -- P1 10261431
		IF l_search_line_id_tbl.EXISTS(l_qte_line_dtl_tbl(l_template_line_count).ato_line_id) THEN
                    l_qte_line_dtl_tbl(l_template_line_count).ato_line_index := l_search_line_id_tbl(l_qte_line_dtl_tbl(l_template_line_count).ato_line_id);
                    l_qte_line_dtl_tbl(l_template_line_count).ato_line_id    := NULL;
                END IF;

            END IF;
        ELSE
            l_service_flag := 'N';

            FOR service_items_rec in c_service_items(l_qte_line_tbl(i).inventory_item_id, l_qte_line_tbl(i).organization_id) LOOP
                l_service_flag := service_items_rec.service_item_flag;
            END LOOP;

            IF l_service_flag = 'Y' THEN
                l_temp_line_dtl_tbl := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl;
                l_temp_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_tbl(i).quote_line_id);

                IF l_temp_line_dtl_tbl.count > 0 THEN
                    l_template_line_count                                    := l_template_line_count + 1;
                    l_qte_line_dtl_tbl(l_template_line_count)                := l_temp_line_dtl_tbl(1);
                    l_qte_line_dtl_tbl(l_template_line_count).qte_line_index := i;
                    l_qte_line_dtl_tbl(l_template_line_count).operation_code := 'CREATE';
                    l_qte_line_dtl_tbl(l_template_line_count).quote_line_id  := NULL;
                    l_qte_line_dtl_tbl(l_template_line_count).quote_line_detail_id  := NULL;

                    IF l_search_line_id_tbl.EXISTS(l_qte_line_dtl_tbl(l_template_line_count).service_ref_line_id) THEN
                        l_qte_line_dtl_tbl(l_template_line_count).service_ref_qte_line_index := l_search_line_id_tbl(l_qte_line_dtl_tbl(l_template_line_count).service_ref_line_id);
                        l_qte_line_dtl_tbl(l_template_line_count).service_ref_line_id        := NULL;
                    END IF;
                END IF;

			 l_qte_line_tbl(i).start_date_active := sysdate;
			 l_qte_line_tbl(i).end_date_active   := null;

            END IF;
        END IF;

    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:   end line details loop', 1, 'Y');
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: start copy configuration loop', 1, 'Y');
    END IF;

    FOR i IN 1..l_qte_line_tbl.count LOOP
        IF l_qte_line_tbl(i).item_type_code = 'MDL' THEN
            FOR j IN 1..l_qte_line_dtl_tbl.count LOOP
                IF l_qte_line_dtl_tbl(j).qte_line_index = i THEN
                    IF (l_qte_line_dtl_tbl(j).config_header_id <> FND_API.G_MISS_NUM AND l_qte_line_dtl_tbl(j).config_header_id IS NOT NULL) AND
                        (l_qte_line_dtl_tbl(j).config_revision_num <> FND_API.G_MISS_NUM AND l_qte_line_dtl_tbl(j).config_revision_num IS NOT NULL) THEN

                        l_config_header_id  := l_qte_line_dtl_tbl(j).config_header_id;
                        l_config_rev_number := l_qte_line_dtl_tbl(j).config_revision_num;


                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: before Copy_Configuration', 1, 'Y');
				    END IF;


                             /*ASO_CFG_INT.Copy_Configuration(
                            p_api_version_number => 1.0,
                            p_control_rec        => l_cfg_control_rec,
                            p_config_hdr_id      => l_config_header_id,
                            p_config_rev_nbr     => l_config_rev_number,
                            x_config_hdr_id      => lx_config_header_id,
                            x_config_rev_nbr     => lx_config_rev_number,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data
                        );*/

                        ASO_CFG_INT.Copy_Configuration(
                              p_api_version_number  =>  1.0,
                              p_init_msg_list       =>  FND_API.G_FALSE,
                              p_commit              =>  FND_API.G_FALSE,
                              p_config_header_id    =>  l_config_header_id,
                              p_config_revision_num =>  l_config_rev_number,
                              p_copy_mode           =>  CZ_API_PUB.G_NEW_HEADER_COPY_MODE,
                              p_handle_deleted_flag =>  NULL,
                              p_new_name            =>  NULL,
                              x_config_header_id    =>  lx_config_header_id,
                              x_config_revision_num =>  lx_config_rev_number,
                              x_orig_item_id_tbl    =>  lx_orig_item_id_tbl,
                              x_new_item_id_tbl     =>  lx_new_item_id_tbl,
                              x_return_status       =>  x_return_status,
                              x_msg_count           =>  x_msg_count,
                              x_msg_data            =>  x_msg_data
                            );

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:  after Copy_Configuration', 1, 'Y');
				    END IF;

                        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                            RAISE FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

				    -- Changes for Config item Id

		  IF (lx_orig_item_id_tbl.count > 0)  AND (lx_new_item_id_tbl.count > 0) THEN
				   FOR i IN lx_orig_item_id_tbl.FIRST ..lx_orig_item_id_tbl.LAST LOOP
						IF (lx_orig_item_id_tbl.exists(i)) and (lx_orig_item_id_tbl(i) is not null) THEN
							l_orig_config_id_tbl(lx_new_item_id_tbl(i)) := lx_new_item_id_tbl(i);
						END IF;
				   END LOOP;
	   		end if;


                        FOR k IN 1..l_qte_line_dtl_tbl.count LOOP
                            IF l_qte_line_dtl_tbl(k).config_header_id = l_config_header_id AND  l_qte_line_dtl_tbl(k).config_revision_num = l_config_rev_number THEN
                                l_qte_line_dtl_tbl(k).config_header_id    := lx_config_header_id;
                                l_qte_line_dtl_tbl(k).config_revision_num := lx_config_rev_number;
						  l_qte_line_dtl_tbl(k).quote_line_detail_id := null;
					  IF l_orig_config_id_tbl.exists(l_qte_line_dtl_tbl(k).config_item_id) THEN
							l_qte_line_dtl_tbl(k).config_item_id := l_orig_config_id_tbl(l_qte_line_dtl_tbl(k).config_item_id);
					  end if;
                            END IF;
                        END LOOP;-- loop to assign new header and rev

                    END IF;
                END IF;
            END LOOP;  --  loop on line detail tbl
        END IF;

		l_qte_line_tbl(i).quote_header_id := p_qte_header_rec.quote_header_id;
		l_qte_line_tbl(i).operation_code  := 'CREATE';
		l_qte_line_tbl(i).quote_line_id   := NULL;
		l_qte_line_tbl(i).line_number     := FND_API.G_MISS_NUM;
    END LOOP;

    -- Template Manager Changes
    IF p_update_flag = 'N' THEN
         x_qte_line_tbl := l_qte_line_tbl;
	    x_qte_line_dtl_tbl := l_qte_line_dtl_tbl;
    ELSE

    		IF aso_debug_pub.g_debug_flag = 'Y' THEN
    			aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:   end copy configuration loop', 1, 'Y');
    			aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: before Update_Quote', 1, 'Y');

          END IF;

                 --mo_global.set_policy_context('S',  l_qte_header_rec.org_id);
    		ASO_QUOTE_PUB.Update_Quote(
       		P_Api_Version_Number      => 1.0,
        		P_Init_Msg_List           => FND_API.G_FALSE,
        		P_Commit                  => FND_API.G_FALSE,
        		P_Control_Rec             => p_control_rec,
        		P_Qte_Header_Rec          => l_qte_header_rec,
        		P_Qte_Line_Tbl            => l_qte_line_tbL,
        		P_Qte_Line_Dtl_Tbl        => l_qte_line_dtl_tbl,
        		X_Qte_Header_Rec          => X_Qte_Header_Rec,
        		X_Qte_Line_Tbl            => X_Qte_Line_Tbl,
        		X_Qte_Line_Dtl_Tbl        => X_Qte_Line_Dtl_Tbl,
        		X_Hd_Price_Attributes_Tbl => X_Hd_Price_Attributes_Tbl,
        		X_Hd_Payment_Tbl          => X_Hd_Payment_Tbl,
        		X_Hd_Shipment_Tbl         => X_Hd_Shipment_Tbl,
        		X_Hd_Freight_Charge_Tbl   => X_Hd_Freight_Charge_Tbl,
        		X_Hd_Tax_Detail_Tbl       => X_Hd_Tax_Detail_Tbl,
        		X_Line_Attr_Ext_Tbl       => X_Line_Attr_Ext_Tbl,
        		X_line_rltship_tbl        => X_line_rltship_tbl,
        		X_Price_Adjustment_Tbl    => X_Price_Adjustment_Tbl,
        		X_Price_Adj_Attr_Tbl      => X_Price_Adj_Attr_Tbl,
        		X_Price_Adj_Rltship_Tbl   => X_Price_Adj_Rltship_Tbl,
        		X_Ln_Price_Attributes_Tbl => X_Ln_Price_Attributes_Tbl,
        		X_Ln_Payment_Tbl          => X_Ln_Payment_Tbl,
        		X_Ln_Shipment_Tbl         => X_Ln_Shipment_Tbl,
        		X_Ln_Freight_Charge_Tbl   => X_Ln_Freight_Charge_Tbl,
        		X_Ln_Tax_Detail_Tbl       => X_Ln_Tax_Detail_Tbl,
        		X_Return_Status           => x_return_status,
        		X_Msg_Count               => x_msg_count,
        		X_Msg_Data                => x_msg_data
    			);

                         --mo_global.set_policy_context('M', null);

    			IF aso_debug_pub.g_debug_flag = 'Y' THEN
    				aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:  after Update_Quote', 1, 'Y');
    			END IF;

    			IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       			 RAISE FND_API.G_EXC_ERROR;
    			ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    			END IF;

 -- Commented for bug no 6731701 so that only the record for newly inserted line go into relationship table
/*    				x_qte_line_tbl := ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl;
				x_qte_line_tbl := ASO_UTILITY_PVT.Query_Qte_Line_Rows_sort(p_qte_header_rec.quote_header_id);
*/
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			For l in x_qte_line_tbl.FIRST..x_qte_line_tbl.LAST  LOOP
				aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:quote line id :'||x_qte_line_tbl(l).quote_line_id,1,'Y');
			END LOOP;
		end if;

    			IF aso_debug_pub.g_debug_flag = 'Y' THEN
    				aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: start line relationships loop', 1, 'Y');
    			END IF;

    			FOR i in 1..x_qte_line_tbl.count LOOP
        			l_line_rltship_rec := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Rec;
        			x_qte_line_dtl_tbl := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl;
        			x_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(x_qte_line_tbl(i).quote_line_id);

        		IF x_qte_line_dtl_tbl.count > 0 THEN

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
					For k in x_qte_line_dtl_tbl.FIRST..x_qte_line_dtl_tbl.LAST LOOP
						 aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:quote line detail id :'||x_qte_line_dtl_tbl(k).quote_line_detail_id,1,'Y');
				 	END LOOP;
				 end if;



            		IF x_qte_line_dtl_tbl(1).ref_line_id IS NOT NULL AND x_qte_line_dtl_tbl(1).ref_line_id <> FND_API.G_MISS_NUM THEN
                		l_line_rltship_rec.OPERATION_CODE         := 'CREATE';
                		l_line_rltship_rec.QUOTE_LINE_ID          := x_qte_line_dtl_tbl(1).ref_line_id;
                		l_line_rltship_rec.RELATED_QUOTE_LINE_ID  := x_qte_line_dtl_tbl(1).quote_line_id;
                		l_line_rltship_rec.RELATIONSHIP_TYPE_CODE := 'CONFIG';

			 	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                		aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: before Create_Line_Rltship', 1, 'Y');
			       END IF;

                	ASO_LINE_RLTSHIP_PVT.Create_Line_Rltship(
                    P_Api_Version_Number   => 1.0,
                    P_Init_Msg_List        => FND_API.G_FALSE,
                    P_Commit               => FND_API.G_FALSE,
                    P_Validation_Level     => p_validation_level,
                    P_Line_Rltship_Rec     => l_line_rltship_rec,
                    X_LINE_RELATIONSHIP_ID => lx_line_relationship_id,
                    X_Return_Status        => x_return_status,
                    X_Msg_Count            => x_msg_count,
                    X_Msg_Data             => x_msg_data
                );

			 	IF aso_debug_pub.g_debug_flag = 'Y' THEN
               		aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:  after Create_Line_Rltship: lx_line_relationship_id: '||lx_line_relationship_id, 1, 'Y');
                	END IF;

               	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   		RAISE FND_API.G_EXC_ERROR;
               	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               	END IF;
            	END IF;
           END IF;
    END LOOP;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT:   end line relationships loop', 1, 'Y');

   END IF;
END IF;--Template manager


    -- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('****** End of Add_Template_To_Quote API ******', 1, 'Y');
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Add_Template_To_Quote;

-- 9433340  Suner2
FUNCTION Validate_Item(
    p_qte_header_rec    IN       ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_quote_line_id        IN      NUMBER,
    p_inventory_item_id IN       NUMBER,
    --p_organization_id   IN       NUMBER,
    p_quantity          IN       NUMBER,
    p_uom_code          IN       VARCHAR2
) RETURN BOOLEAN
is
 CURSOR c_conc_segments (l_inventory_item_id NUMBER) IS
 SELECT concatenated_segments
 FROM MTL_SYSTEM_ITEMS_VL
 WHERE inventory_item_id = l_inventory_item_id;

 CURSOR c_orderable_items (l_inventory_item_id NUMBER, l_organization_id NUMBER) IS
 SELECT bom_item_type,
        primary_uom_code,
        service_item_flag
 FROM MTL_SYSTEM_ITEMS_VL
 WHERE inventory_item_id = l_inventory_item_id
 AND organization_id = l_organization_id
 AND customer_order_enabled_flag = 'Y'
 AND bom_item_type <> 2
 AND NVL(start_date_active, SYSDATE) <= SYSDATE
 AND NVL(end_date_active, SYSDATE) >= SYSDATE;

 cursor c_in_org_in_master_org(l_inventory_item_id NUMBER, l_organization_id NUMBER) IS
 select segment1
 from mtl_system_items_vl
 WHERE inventory_item_id = l_inventory_item_id
 AND organization_id = l_organization_id;

  l_conc_segments     VARCHAR2(40);
 l_orderable_flag    VARCHAR2(1) := 'N';
 l_uom_code          MTL_SYSTEM_ITEMS_B.primary_uom_code%TYPE;
 l_resp_id           NUMBER;
 l_resp_appl_id      NUMBER;
 l_ui_def_id         NUMBER;
 l_output_qty        NUMBER;
 l_primary_qty       NUMBER;
 l_return_status     VARCHAR2(30);

 lx_return_status    VARCHAR2(50);
 lx_msg_count        NUMBER;
 lx_msg_data         VARCHAR2(2000);
 l_master_organization_id NUMBER;
 l_segment1          VARCHAR2(240);

cursor c_service_ref_quote (l_Quote_line_id number) is
select service_ref_line_id
from aso_quote_line_Details
where quote_line_id=  l_Quote_line_id
and service_ref_type_code ='QUOTE';

cursor c_service_ref_quote_line (l_Quote_line_id number) is
select inventory_item_id
from aso_quote_lines_All
where quote_line_id = l_quote_line_id;


 lprof varchar2(10) := nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N');
 l_inv_id     number;
l_service_ref_line_id number;
 l_check_service_rec ASO_SERVICE_CONTRACTS_INT.CHECK_SERVICE_REC_TYPE;
 l_cust    number;
l_Available_YN VARCHAR2(1);



-- end service items

begin
aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: *** Start of API body ***', 1, 'Y');
   aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: p_inventory_item_id: '|| p_inventory_item_id, 1, 'N');
   --aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: p_organization_id:   '|| p_organization_id, 1, 'N');
   aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: p_quantity:          '|| p_quantity, 1, 'N');
   aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: p_uom_code:          '|| p_uom_code, 1, 'N');
END IF;


FOR conc_segments_rec IN c_conc_segments(p_inventory_item_id) LOOP
    l_conc_segments := conc_segments_rec.concatenated_segments;
END LOOP;


    l_master_organization_id := oe_sys_parameters.value(param_name => 'MASTER_ORGANIZATION_ID',
                                                               p_org_id => p_qte_header_rec.org_id);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('l_master_organization_id: ' || l_master_organization_id);
              aso_debug_pub.add(' p_qte_header_rec.org_id: ' ||  p_qte_header_rec.org_id);
           END IF;

 open c_in_org_in_master_org(p_inventory_item_id,l_master_organization_id);
 fetch c_in_org_in_master_org into l_segment1;
 if c_in_org_in_master_org%NOTFOUND THEN
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Item does not exist in the master org',1,'N');
             END IF;

             RETURN FALSE;

 end if;
 close c_in_org_in_master_org;


FOR orderable_items_rec IN c_orderable_items(p_inventory_item_id, l_master_organization_id) LOOP
    l_orderable_flag := 'Y';
    IF p_uom_code IS NULL THEN
       l_uom_code := orderable_items_rec.primary_uom_code;

    ELSIF p_uom_code IS NOT NULL AND p_uom_code <> FND_API.G_MISS_CHAR  THEN
      l_uom_code  := p_uom_code;

    END IF;


    IF orderable_items_rec.service_item_flag = 'Y' THEN
       IF (fnd_profile.value('ASO_REQUIRE_SERVICE_REFERENCE') <> 'N')     OR (fnd_profile.value('ASO_REQUIRE_SERVICE_REFERENCE') is null) THEN
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: item is of type service:'  || p_inventory_item_id, 1, 'N');
	      END IF;
               open c_service_ref_quote(p_quote_line_id);
	       fetch c_service_ref_quote into l_service_ref_line_id;
	       close c_service_ref_quote;

	        if l_service_ref_line_id is not null then
		      open c_service_ref_quote_line(l_service_ref_line_id);
		      fetch c_service_ref_quote_line into l_inv_id;
		      close c_service_ref_quote_line;
	      end if;

               if lprof='Y' then
		    l_cust :=p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
		    if l_cust is null then
		          l_cust := p_qte_header_rec.cust_account_id;
                    end if;
               else
                    l_cust := p_qte_header_rec.cust_account_id;
               end if;

	       l_check_service_rec.product_item_id := l_inv_id;
	       l_check_service_rec.service_item_id := p_inventory_item_id;
	       l_check_service_rec.customer_id :=  l_cust;
	       ASO_SERVICE_CONTRACTS_INT.Is_Service_Available(
        					P_Api_Version_Number	=> 1.0 ,
        					P_init_msg_list	=>FND_API.G_FALSE,
						X_msg_Count     => lx_msg_count ,
        					X_msg_Data	=> lx_msg_data	 ,
        					X_Return_Status	=> lx_return_status  ,
						p_check_service_rec => l_check_service_rec,
						X_Available_YN	    => l_Available_YN
					       );
	      IF l_Available_YN = 'N' THEN
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('UPDATE_QUOTE:SERVICE_not available');
		END IF;
                return false;
            end if;

   end if;

    END IF;

       -- Top model item
    IF orderable_items_rec.bom_item_type = 1 THEN
       l_resp_id := FND_PROFILE.Value('RESP_ID');
       l_resp_appl_id := FND_PROFILE.Value('RESP_APPL_ID');
       l_ui_def_id := CZ_CF_API.UI_FOR_ITEM(
                               p_inventory_item_id,
                               l_master_organization_id,
                               SYSDATE,
                               'APPLET',
                               FND_API.G_MISS_NUM,
                               FND_PROFILE.Value('RESP_ID'),
                               FND_PROFILE.Value('RESP_APPL_ID')
                           );

       IF l_ui_def_id IS NULL THEN
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: item does not have a configurable ui:'
		                      || p_inventory_item_id, 1, 'N');
          END IF;


          RETURN FALSE;
       END IF;
    END IF;

    INV_DECIMALS_PUB.Validate_Quantity(
            p_inventory_item_id,
            l_master_organization_id,
            p_quantity,
            l_uom_code,
            l_output_qty,
            l_primary_qty,
            l_return_status
    );
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item:p_quantity'|| p_quantity, 1, 'N');
	     aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item:l_return_status'|| l_return_status, 1, 'N');
         aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item:l_uom_code'|| l_uom_code, 1, 'N');
         aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item:l_output_qty'|| l_output_qty, 1, 'N');
         aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item:l_primary_qty'|| l_primary_qty, 1, 'N');
       END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR p_quantity <= 0 THEN
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: item has invalid quantity:'
		                   || p_inventory_item_id, 1, 'N');
       END IF;


       RETURN FALSE;
    END IF;

END LOOP;

/*IF l_orderable_flag = 'N' THEN
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: item not orderable:'|| p_inventory_item_id, 1, 'N');
   END IF;
   RETURN FALSE;
END IF;
*/

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('ASO_QUOTE_TMPL_PVT: Validate_Item: *** End of API body ***', 1, 'Y');
END IF;

  return true;
end Validate_Item;

END ASO_QUOTE_TMPL_PVT;


/
