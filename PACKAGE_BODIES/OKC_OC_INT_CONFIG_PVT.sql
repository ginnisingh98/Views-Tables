--------------------------------------------------------
--  DDL for Package Body OKC_OC_INT_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OC_INT_CONFIG_PVT" AS
/* $Header: OKCRCFGB.pls 120.0 2005/05/25 23:00:21 appldev noship $        */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

------------------------------------------------------------------------------
-- Procedure:       create_config_sublines
-- Purpose:         To create the sublines in contract corresponding to child lines of a Model Item in Order/quote.
--                  One Model will have many Option class as child Item and Each Option classes have many standard items as there child.
--                  All these Item will be maped to recursive line  style which was choosen for Model line.
--                  This procedure will call itself recursively untill all the Items in order/Contract are covered

-- In Parameters:   P_source_inf_rec  This Consists of 1.o_flag   Flag to determine If Child needs to be created for Order Model line.
--                                                     2.q_flag            Flag to determine If Child needs to be created for quote Model Line .
--                                                     3.line_id           Line Id of Top Model Line from Order/Quote.
--                                                     4.line_numer          Line number of quote/order Line
--                                                     5.object_number     Order/Quote Number.
--                  p_parent_clev_rec   K Line record of Parent Line
--                  p_parent_cimv_rec   K Line Item Record of Prent Line.
--                  p_line_inf_tab      PL/SQL table to store Relationship of Contract Line and Order/quote line.

-- Out Parameters:  x_return_status      return Status
-------------------------------------------------------------------------------
PROCEDURE create_config_sublines(p_source_inf_rec     IN  SOURCE_INF_REC_TYPE,
                                 p_parent_clev_rec    IN OUT NOCOPY  okc_contract_pub.clev_rec_type,
                                 p_parent_cimv_rec    IN  okc_contract_item_pub.cimv_rec_type,
                                 p_line_inf_tab       IN OUT NOCOPY line_inf_tbl_type,
                                 x_return_status      OUT NOCOPY VARCHAR2
                                 ) IS

-- Cursor to get Child reecord for one line in Order or Quote.This cursor only gets child just one level below the line.
CURSOR c_child_line_info(b_o_flag VARCHAR2,b_q_flag VARCHAR2,b_line_id NUMBER) IS
SELECT id1 line_id
       ,header_id
       ,ship_from_org_id organization_id  -- Bug 2225305
       ,line_number  line_number
       ,order_quantity_uom uom
       ,ordered_quantity quantity
       ,inventory_item_id
       ,unit_list_price
       ,price_list_id
       ,unit_selling_price
       ,config_header_id
       ,config_rev_nbr
       ,to_number(NULL) config_item_id
       ,'Y' config_valid_yn
       ,'Y' config_complete_yn
       ,nvl(to_number(sort_order),0) seq   -- Bug 2087912
FROM   OKX_ORDER_LINES_V
WHERE  b_o_flag = OKC_API.G_TRUE
AND    link_to_line_id = b_line_id
AND    item_type_code in ('OPTION','CLASS')
UNION ALL
SELECT a.id1 line_id
      ,a.quote_header_id header_id
      ,a.organization_id organization_id  -- Bug 2225305
      ,a.line_number  line_number
      ,uom_code uom
      ,quantity quantity
      ,inventory_item_id
      ,a.line_list_price/decode(quantity,0,1,quantity) unit_list_price
      ,a.price_list_id price_list_id
      ,a.line_quote_price/decode(quantity,0,1,quantity) unit_selling_price
      ,c.config_header_id config_header_id
      ,c.config_revision_num config_rev_nbr
      ,c.config_item_id config_item_id
      ,c.valid_configuration_flag    config_valid_yn
      ,c.complete_configuration_flag config_complete_yn
      ,a.line_number  seq   -- for sorting  Bug 2087912
-- Changed refrence to ASO tables to OKX views
FROM OKX_QUOTE_LINES_V a,OKX_QTE_LINE_RLSHPS_V b,OKX_QUOTE_LINE_DETAIL_V c
WHERE b_q_flag = OKC_API.G_TRUE
AND   a.id1 = b.related_quote_line_id
AND   a.id1 = c.quote_line_id
AND   b.quote_line_id= b_line_id
AND   b.relationship_type_code ='CONFIG'
AND   a.item_type_code = 'CFG'
order by 16;

l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
child_line_rec          c_child_line_info%ROWTYPE;
l_child_cimv_rec        OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE;
l_child_clev_rec        OKC_CONTRACT_PUB.CLEV_REC_TYPE;
lx_child_cimv_rec       OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE;
lx_child_clev_rec       OKC_CONTRACT_PUB.CLEV_REC_TYPE;
temp_child_cimv_rec     OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE;
temp_child_clev_rec     OKC_CONTRACT_PUB.CLEV_REC_TYPE;
l_source_inf_rec        SOURCE_INF_REC_TYPE;
l_subline_num           NUMBER :=0;
line_inf_tab_counter    NUMBER :=0;


no_child_left  EXCEPTION;

BEGIN
 IF (l_debug = 'Y') THEN
    okc_util.print_trace(0, 'CREATE CHILD LINE FOR THE MODEL LINE ');
    okc_util.print_trace(0, '===================================================');
    okc_util.print_trace(1, ' ');
    okc_util.print_trace(1, '>START - OKO_OC_INT_CONFGI_PVT.create_config_sublines - create Sublines');
    okc_util.print_trace(1, ' ');
 END IF;
 x_return_status := OKC_API.G_RET_STS_SUCCESS;
 l_child_cimv_rec  := temp_child_cimv_rec;
 l_child_clev_rec  := temp_child_clev_rec;
 l_subline_num := 0;
 OPEN c_child_line_info(p_source_inf_rec.o_flag,p_source_inf_rec.q_flag,p_source_inf_rec.line_id);
    LOOP
       FETCH c_child_line_info into child_line_rec;
        IF c_child_line_info%NOTFOUND then
           close c_child_line_info;
-- No child are present at level below this line
           raise no_child_left;
        END IF;

        l_subline_num := l_subline_num+1;
         -- build up contract line
        l_child_clev_rec.dnz_chr_id       := P_PARENT_CLEV_REC.dnz_chr_id;
        l_child_clev_rec.cle_id           := P_PARENT_CLEV_REC.id;
        l_child_clev_rec.lse_id           := P_PARENT_CLEV_REC.lse_id;
--Bug 2222830
        l_child_clev_rec.price_level_ind  := P_PARENT_CLEV_REC.price_level_ind;
        l_child_clev_rec.item_to_price_yn := P_PARENT_CLEV_REC.item_to_price_yn;
        l_child_clev_rec.price_basis_yn   := P_PARENT_CLEV_REC.price_basis_yn;
--End Bug 2222830
        l_child_clev_rec.price_list_id    := child_line_rec.price_list_id;
        l_child_clev_rec.price_unit       := child_line_rec.unit_list_price;
        l_child_clev_rec.price_negotiated := nvl(child_line_rec.unit_selling_price,0)*nvl(child_line_rec.quantity,0);
        l_child_clev_rec.line_list_price  := nvl(child_line_rec.unit_list_price,0)*nvl(child_line_rec.quantity,0);
        l_child_clev_rec.display_sequence := l_subline_num;
        l_child_clev_rec.line_number      := to_char(l_subline_num);
        l_child_clev_rec.hidden_ind       := 'N';
        l_child_clev_rec.EXCEPTION_yn     := 'N';
        l_child_clev_rec.sts_code         := P_PARENT_CLEV_REC.sts_code;
        l_child_clev_rec.start_date       := P_PARENT_CLEV_REC.start_date;
        l_child_clev_rec.end_date         := P_PARENT_CLEV_REC.end_date;
        l_child_clev_rec.currency_code    := P_PARENT_CLEV_REC.currency_code;
        l_child_clev_rec.config_header_id := child_line_rec.config_header_id;
        l_child_clev_rec.config_revision_number := child_line_rec.config_rev_nbr;
        l_child_clev_rec.config_complete_yn := child_line_rec.config_complete_yn;
--        l_child_clev_rec.config_complete_yn := 'Y'; --GF: bugs#2440369,2440237
        l_child_clev_rec.config_valid_yn := child_line_rec.config_valid_yn;
--        l_child_clev_rec.config_valid_yn := 'Y'; --GF: bugs#2440369,2440237
        l_child_clev_rec.config_top_model_line_id := P_PARENT_CLEV_REC.config_top_model_line_id;
        l_child_clev_rec.config_item_type := G_NORMAL_LINE;
        l_child_clev_rec.config_item_id := child_line_rec.config_item_id; --BUG 1958006
        l_child_clev_rec.last_update_login:=UID;
        l_child_clev_rec.orig_system_id1 := child_line_rec.line_id;
        l_child_clev_rec.orig_system_source_code := p_parent_clev_rec.orig_system_source_code;

-- Add prices to update final prices at TOP_MODEL_LINE level

--        rolledup_line_list_price :=  rolledup_line_list_price +  l_child_clev_rec.price_negotiated ;
--        rolledup_price_negotiated := rolledup_price_negotiated + l_child_clev_rec.line_list_price ;

--2007583 Problem was becouse of price negoiated was getting added to list price and list price to proce negotiated.See above.Its being correcetd now
        rolledup_line_list_price :=  rolledup_line_list_price +   l_child_clev_rec.line_list_price;
        rolledup_price_negotiated := rolledup_price_negotiated + l_child_clev_rec.price_negotiated;

        IF (l_debug = 'Y') THEN
           okc_util.print_trace(3, 'INPUT RECORD - Contract Line Record(Configurator Lines):');
           okc_util.print_trace(3, '========================================');
           okc_util.print_trace(4, 'Contract Line Number  = '||l_child_clev_rec.line_number);
           okc_util.print_trace(4, 'Contract Header Id    = '||l_child_clev_rec.dnz_chr_id);
           okc_util.print_trace(4, 'Contract Line   Id    = '||l_child_clev_rec.cle_id);
           okc_util.print_trace(4, 'Line Style Id         = '||l_child_clev_rec.lse_id);
           okc_util.print_trace(4, 'Display Sequence      = '||l_child_clev_rec.display_sequence);
           okc_util.print_trace(4, 'Currency code         = '||l_child_clev_rec.currency_code);
           okc_util.print_trace(4, 'Price Level Ind.      = '||l_child_clev_rec.price_level_ind);
           okc_util.print_trace(4, 'Unit Price            = '||l_child_clev_rec.price_unit);
           okc_util.print_trace(4, 'Negotiated price      = '||l_child_clev_rec.price_negotiated);
           okc_util.print_trace(4, 'Hidden Ind.           = '||l_child_clev_rec.hidden_ind);
           okc_util.print_trace(4, 'EXCEPTION Y/N         = '||l_child_clev_rec.exception_yn);
           okc_util.print_trace(4, 'Status Code           = '||l_child_clev_rec.sts_code);
           okc_util.print_trace(4, 'Start Date            = '||l_child_clev_rec.start_date);
           okc_util.print_trace(4, 'End Date              = '||l_child_clev_rec.END_date);
           okc_util.print_trace(1, '----------------------------');
           okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
           okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
           okc_util.print_trace(1, '----------------------------');
           okc_util.print_trace(1, '--------------------------------------------------------');
           okc_util.print_trace(1, '>START - ******* OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE -');
        END IF;

        okc_contract_pub.create_contract_line(p_api_version   => 1
                                             ,p_init_msg_list => OKC_API.G_FALSE
                                             ,x_return_status => l_return_status
                                             ,x_msg_count     => l_msg_count
                                             ,x_msg_data      => l_msg_data
                                             ,p_clev_rec      => l_child_clev_rec
                                             ,x_clev_rec      => lx_child_clev_rec
                                             );

       IF (l_debug = 'Y') THEN
          okc_util.print_trace(1, '<END - ******* OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE -');
          okc_util.print_trace(1, '----------------------------');
          okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
          okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
          okc_util.print_trace(1, '----------------------------');
       END IF;

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN

         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGLINE',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'OLNUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'ITEM',
                             p_token3_value  => child_line_rec.inventory_item_id,
                             p_token4        => 'LINETYPE',
                             p_token4_value  => l_child_clev_rec.config_item_type
                          );
      END IF;

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         okc_util.print_trace(3, 'OUTPUT RECORD - Contract Line Record:');
         okc_util.print_trace(3, '=========================================');
         okc_util.print_trace(3, 'Contract Header Id    = '||lx_child_clev_rec.dnz_chr_id);
         okc_util.print_trace(4, 'Contract Line Id      = '||lx_child_clev_rec.id);
         okc_util.print_trace(4, 'Line Number           = '||lx_child_clev_rec.line_number);
         okc_util.print_trace(4, 'Line Style Id         = '||lx_child_clev_rec.lse_id);
      END IF;


--      record mapping of contract line to Order/quote line for contract relationship

       line_inf_tab_counter := p_line_inf_tab.count+1;
       p_line_inf_tab(line_inf_tab_counter).object1_id1   := child_line_rec.line_id;
       p_line_inf_tab(line_inf_tab_counter).line_type     := G_NORMAL_LINE;
       p_line_inf_tab(line_inf_tab_counter).cle_id        := lx_child_clev_rec.id;
       p_line_inf_tab(line_inf_tab_counter).line_num      := lx_child_clev_rec.line_number;
       p_line_inf_tab(line_inf_tab_counter).subline       := 0;
       p_line_inf_tab(line_inf_tab_counter).lse_id        := lx_child_clev_rec.lse_id;
       p_line_inf_tab(line_inf_tab_counter).line_qty     := child_line_rec.quantity;
       p_line_inf_tab(line_inf_tab_counter).line_uom     := child_line_rec.uom;



      IF (l_debug = 'Y') THEN
         okc_util.print_trace(0, ' ');
         okc_util.print_trace(0, '================================================');
         okc_util.print_trace(0, 'CREATE CONTRACT LINE ITEM ');
         okc_util.print_trace(0, '================================================');
         okc_util.print_trace(0, ' ');
      END IF;

      -- create contract item
      l_child_cimv_rec.cle_id            := lx_child_clev_rec.id;
      l_child_cimv_rec.dnz_chr_id        := lx_child_clev_rec.dnz_chr_id;
      l_child_cimv_rec.jtot_object1_code := p_parent_cimv_rec.jtot_object1_code;
      l_child_cimv_rec.number_of_items   := child_line_rec.quantity;
      l_child_cimv_rec.uom_code          := child_line_rec.uom;
      l_child_cimv_rec.priced_item_yn    := 'Y';
      l_child_cimv_rec.EXCEPTION_yn      := 'N';
      l_child_cimv_rec.object1_id1       := child_line_rec.inventory_item_id;
      l_child_cimv_rec.object1_id2       := child_line_rec.organization_id;

      IF (l_debug = 'Y') THEN
         okc_util.print_trace(3, 'INPUT RECORD - Contract Top Line Item Record:');
         okc_util.print_trace(3, '=============================================');
         okc_util.print_trace(4, 'Contract Line Id      = '||l_child_cimv_rec.cle_id);
         okc_util.print_trace(4, 'Dnz Contract Header Id= '||l_child_cimv_rec.dnz_chr_id);
         okc_util.print_trace(4, 'Object1 Id1           = '||l_child_cimv_rec.object1_id1);
         okc_util.print_trace(4, 'Object1 Id2           = '||l_child_cimv_rec.object1_id2);
         okc_util.print_trace(4, 'Object Code           = '||l_child_cimv_rec.jtot_object1_code);
         okc_util.print_trace(4, 'No. of Items          = '||l_child_cimv_rec.number_of_items);
         okc_util.print_trace(4, 'UoM Code              = '||l_child_cimv_rec.uom_code);
         okc_util.print_trace(4, 'Item Priced           = '||l_child_cimv_rec.priced_item_yn);
      END IF;

      -- insert contract item
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(1, '----------------------------');
         okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
         okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
         okc_util.print_trace(1, '----------------------------');
      END IF;

      IF (l_debug = 'Y') THEN
         okc_util.print_trace(1, '--------------------------------------------------------');
         okc_util.print_trace(1, '>START - ******* OKC_CONTRACT_ITEM_PUB.CREATE_CONTRACT_ITEM -');
      END IF;

      okc_contract_item_pub.create_contract_item(p_api_version   => 1
                                                ,p_init_msg_list => OKC_API.G_FALSE
                                              ,x_return_status => l_return_status
                                                ,x_msg_count     => l_msg_count
                                                ,x_msg_data      => l_msg_data
                                                ,p_cimv_rec      => l_child_cimv_rec
                                                ,x_cimv_rec      => lx_child_cimv_rec
                                                 );

      IF (l_debug = 'Y') THEN
         okc_util.print_trace(1, '<END - ******* OKC_CONTRACT_ITEM_PUB.CREATE_CONTRACT_ITEM -');
         okc_util.print_trace(1, '--------------------------------------------------------');
      END IF;

      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN

         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGITEM',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'OLNUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'ITEM',
                             p_token3_value  => l_child_cimv_rec.object1_id1,
                             p_token4        => 'INVORG',
                             p_token4_value  => l_child_cimv_rec.object1_id2,
                             p_token5        => 'LINETYPE',
                             p_token5_value  => l_child_clev_rec.config_item_type
                            );
     END IF;
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         okc_util.print_trace(3, 'OUTPUT RECORD - Contract Top Line Item Record:');
         okc_util.print_trace(3, '==============================================');
         okc_util.print_trace(3, 'Id                    = '||to_char(lx_child_cimv_rec.id));
         okc_util.print_trace(3, 'Contract Line Id      = '||lx_child_cimv_rec.cle_id);
         okc_util.print_trace(3, 'Contract Header Id    = '||to_char(lx_child_cimv_rec.chr_id));
         okc_util.print_trace(3, 'Dnz Contract Header Id= '||lx_child_cimv_rec.dnz_chr_id);
         okc_util.print_trace(3, 'Object1 Id1           = '||lx_child_cimv_rec.object1_id1);
         okc_util.print_trace(3, 'Object1 Id2           = '||lx_child_cimv_rec.object1_id2);
         okc_util.print_trace(3, 'Object Code           = '||lx_child_cimv_rec.jtot_object1_code);
         okc_util.print_trace(3, 'No. of Items          = '||lx_child_cimv_rec.number_of_items);
         okc_util.print_trace(3, 'UoM Code              = '||lx_child_cimv_rec.uom_code);
         okc_util.print_trace(3, 'EXCEPTION Y/N         = '||lx_child_cimv_rec.exception_yn);
         okc_util.print_trace(3, 'Priced Item Y/N       = '||lx_child_cimv_rec.priced_item_yn);
      END IF;

     l_source_inf_rec := p_source_inf_rec;

-- This will ensure that in next call to this procedure child of this line are created
     l_source_inf_rec.line_id := child_line_rec.line_id;

     l_source_inf_rec.line_number := child_line_rec.line_number;

--  Call to Create Remaining childs of line  being processed right now
      create_config_sublines( p_source_inf_rec    => l_source_inf_rec,
                              p_parent_clev_rec    => lx_child_clev_rec,
                              p_parent_cimv_rec    => lx_child_cimv_rec,
                              p_line_inf_tab       => p_line_inf_tab,
                              x_return_status      => l_return_status);

      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN
         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGCREATE',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'LINENUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'ITEM',
                             p_token3_value  => child_line_rec.inventory_item_id,
                             p_token4        => 'LINETYPE',
                             p_token4_value  => G_NORMAL_LINE
                            );
      END IF;

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END LOOP;

EXCEPTION
    WHEN no_child_left THEN
    NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(OKC_API.G_APP_NAME,
                          'OKC_CONTRACTS_UNEXP_ERROR',
                          'SQLCODE',
                          SQLCODE,
                          'SQLERRM',
                          SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END create_config_sublines;


------------------------------------------------------------------------------
-- Procedure:       create_k_config_lines
-- Purpose:         To create the lines in contract corresponding to lines of a Model Item in Order or Quote.
--                  For Each Model Item line in quote and Order 2 Contract lines will be created.One Contract Line will be
--                  having config_item_type_code ='TOP_MODEL_LINE' and other one which is child of this one will have
--                  having config_item_type_code ='TOP_BASE_LINE'
--
--                 This Procedure then calls create_config_sublines to transfer Option class and Option Item lines
--                 from order or quote to Contract.

-- In Parameters:   p_source_inf_rec     It will contain info like order/quote header id and Flag stating that If this
--                                      proceedure is being called for Order or Contract.
--                  p_clev_rec           Contract Line rec of Top line
--                  p_cimv_rec           Contract Item rec of Top line
--                  p_line_inf_tab       PL/sql table to return relationship between K Line and Quote/Order Line
--
-- Out Parameters:  x_return_status      return Status
--                  x_clev_rec           Contract Line rec of Top line
--------------------------------------------------------------------------------
Procedure create_k_config_lines( p_source_inf_rec IN  SOURCE_INF_REC_TYPE,
                                 p_clev_rec       IN  OKC_CONTRACT_PUB.CLEV_REC_TYPE,
                                 p_cimv_rec       IN  OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE,
                                 p_line_inf_tab   IN OUT NOCOPY LINE_INF_TBL_TYPE,
                                 x_clev_rec       OUT NOCOPY  OKC_CONTRACT_PUB.CLEV_REC_TYPE,
                                 x_return_status  OUT NOCOPY  VARCHAR2
                                ) IS

l_clev_rec              OKC_CONTRACT_PUB.CLEV_REC_TYPE;
model_clev_rec          OKC_CONTRACT_PUB.CLEV_REC_TYPE;
xmodel_clev_rec         OKC_CONTRACT_PUB.CLEV_REC_TYPE;
lx_clev_rec             OKC_CONTRACT_PUB.CLEV_REC_TYPE;
l_cimv_rec              OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE;
model_cimv_rec          OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE;
lx_cimv_rec             OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE;
line_inf_tab_counter    NUMBER := 0;
l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (l_debug = 'Y') THEN
         okc_util.print_trace(0, 'Starting Configurator API');
         okc_util.print_trace(0, ' ');
         okc_util.print_trace(0, '>START - OKO_OC_INT_CONFGI_PVT.create_config_sublines - create Sublines');
         okc_util.print_trace(1, 'CREATE TOP MODEL LINE');
         okc_util.print_trace(1, '=====================');
      END IF;

      model_clev_rec := p_clev_rec;
      model_cimv_rec := p_cimv_rec;

      model_clev_rec.config_item_type := G_MODEL_LINE;
      model_clev_rec.price_unit := NULL;
      model_clev_rec.line_List_price := NULL;
      model_clev_rec.price_negotiated := NULL;
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(1, ' ');
         okc_util.print_trace(1, 'INPUT RECORD - Contract Top Line Record:');
         okc_util.print_trace(1, '========================================');
         okc_util.print_trace(1, 'Contract Line Number     = '||model_clev_rec.line_number);
         okc_util.print_trace(1, 'Contract Header Id       = '||model_clev_rec.chr_id);
         okc_util.print_trace(1, 'Dnz Contract Header Id   = '||model_clev_rec.dnz_chr_id);
         okc_util.print_trace(1, 'Display Sequence         = '||model_clev_rec.display_sequence);
         okc_util.print_trace(1, 'Line Style Id            = '||model_clev_rec.lse_id);
         okc_util.print_trace(1, 'Currency code            = '||model_clev_rec.currency_code);
         okc_util.print_trace(1, 'Price Level Ind.         = '||model_clev_rec.price_level_ind);
         okc_util.print_trace(1, 'Unit Price               = '||model_clev_rec.price_unit);
         okc_util.print_trace(1, 'Negotiated price         = '||model_clev_rec.price_negotiated);
         okc_util.print_trace(1, 'Hidden Ind.              = '||model_clev_rec.hidden_ind);
         okc_util.print_trace(1, 'EXCEPTION Y/N            = '||model_clev_rec.exception_yn);
         okc_util.print_trace(1, 'Status Code              = '||model_clev_rec.sts_code);
         okc_util.print_trace(1, 'Start Date               = '||model_clev_rec.start_date);
         okc_util.print_trace(1, 'End Date                 = '||model_clev_rec.END_date);
         okc_util.print_trace(1, 'Orig system source code  = '||model_clev_rec.orig_system_source_code);
         okc_util.print_trace(1, 'Orig system id           = '||model_clev_rec.orig_system_id1);
         okc_util.print_trace(1, 'Orig system reference    = '||model_clev_rec.orig_system_reference1);
         okc_util.print_trace(1, 'Config Header Id         = '||model_clev_rec.config_header_id);
         okc_util.print_trace(1, 'Config Revison Number    = '||model_clev_rec.config_revision_number);
         okc_util.print_trace(1, 'Config Item Type         = '||model_clev_rec.config_item_type);
         okc_util.print_trace(1, 'Config Complete          = '||model_clev_rec.config_complete_yn);
         okc_util.print_trace(1, 'Config valid             = '||model_clev_rec.config_valid_yn);
         okc_util.print_trace(1, '----------------------------');
         okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
         okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
         okc_util.print_trace(1, '----------------------------');
         okc_util.print_trace(1, '--------------------------------------------------------');
         okc_util.print_trace(1, '>START - ******* OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE -');
      END IF;

      okc_contract_pub.create_contract_line(p_api_version   => 1
                                           ,p_init_msg_list => OKC_API.G_FALSE
                                           ,x_return_status => l_return_status
                                           ,x_msg_count     => l_msg_count
                                           ,x_msg_data      => l_msg_data
                                           ,p_clev_rec      => model_clev_rec
                                           ,x_clev_rec      => lx_clev_rec
                                            );
     xmodel_clev_rec := lx_clev_rec;
     IF (l_debug = 'Y') THEN
        okc_util.print_trace(1, '<END - ******* OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE -');
        okc_util.print_trace(1, '----------------------------');
        okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
        okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
        okc_util.print_trace(1, '----------------------------');
     END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN

         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGLINE',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'OLNUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'ITEM',
                             p_token3_value  => p_cimv_rec.object1_id1,
                             p_token4        => 'LINETYPE',
                             p_token4_value  => model_clev_rec.config_item_type
                          );
    END IF;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    line_inf_tab_counter := p_line_inf_tab.count+1;
    p_line_inf_tab(line_inf_tab_counter).object1_id1 := lx_clev_rec.orig_system_id1;
    p_line_inf_tab(line_inf_tab_counter).line_type   := G_MODEL_LINE;
    p_line_inf_tab(line_inf_tab_counter).cle_id      := lx_clev_rec.id;
    p_line_inf_tab(line_inf_tab_counter).line_num    := lx_clev_rec.line_number;
    p_line_inf_tab(line_inf_tab_counter).subline     := 0;
    p_line_inf_tab(line_inf_tab_counter).lse_id      := lx_clev_rec.lse_id;
    p_line_inf_tab(line_inf_tab_counter).line_qty    := model_cimv_rec.number_of_items;
    p_line_inf_tab(line_inf_tab_counter).line_uom    := model_cimv_rec.uom_code;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, 'OUTPUT RECORD - Contract Top Line Record:');
       okc_util.print_trace(1, '=========================================');
       okc_util.print_trace(1, 'Contract Header Id    = '||to_char(lx_clev_rec.chr_id));
       okc_util.print_trace(1, 'Contract DNZ Header Id= '||to_char(lx_clev_rec.dnz_chr_id));
       okc_util.print_trace(1, 'Contract Line Id      = '||lx_clev_rec.cle_id);
       okc_util.print_trace(1, 'Line Number           = '||lx_clev_rec.line_number);
       okc_util.print_trace(1, 'Line Style Id         = '||lx_clev_rec.lse_id);
       okc_util.print_trace(1, '-->Order Line Id        = '||lx_clev_rec.orig_system_id1);
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, '================================================');
       okc_util.print_trace(1, 'CREATE CONTRACT LINE ITEM ');
       okc_util.print_trace(1, '================================================');
       okc_util.print_trace(1, ' ');
    END IF;

     -- create contract item
    model_cimv_rec.cle_id            := lx_clev_rec.id;
    model_cimv_rec.dnz_chr_id        := lx_clev_rec.chr_id;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, 'INPUT RECORD - Contract Top Line Item Record:');
       okc_util.print_trace(1, '=============================================');
       okc_util.print_trace(1, 'Contract Line Id      = '||model_cimv_rec.cle_id);
       okc_util.print_trace(1, 'Dnz Contract Header Id= '||model_cimv_rec.dnz_chr_id);
       okc_util.print_trace(1, 'Object1 Id1           = '||model_cimv_rec.object1_id1);
       okc_util.print_trace(1, 'Object1 Id2           = '||model_cimv_rec.object1_id2);
       okc_util.print_trace(1, 'Object Code           = '||model_cimv_rec.jtot_object1_code);
       okc_util.print_trace(1, 'No. of Items          = '||model_cimv_rec.number_of_items);
       okc_util.print_trace(1, 'UoM Code              = '||model_cimv_rec.uom_code);
       okc_util.print_trace(1, 'Item Priced           = '||model_cimv_rec.priced_item_yn);
    END IF;

-- insert contract item
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, '----------------------------');
       okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
       okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
       okc_util.print_trace(1, '----------------------------');
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, '--------------------------------------------------------');
       okc_util.print_trace(1, '>START - ******* OKC_CONTRACT_ITEM_PUB.CREATE_CONTRACT_ITEM -');
    END IF;

    okc_contract_item_pub.create_contract_item(p_api_version   => 1
                                              ,p_init_msg_list => OKC_API.G_FALSE
                                              ,x_return_status => l_return_status
                                              ,x_msg_count     => l_msg_count
                                              ,x_msg_data      => l_msg_data
                                              ,p_cimv_rec      => model_cimv_rec
                                              ,x_cimv_rec      => lx_cimv_rec
                                              );

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, '<END - ******* OKC_CONTRACT_ITEM_PUB.CREATE_CONTRACT_ITEM -');
       okc_util.print_trace(1, '--------------------------------------------------------');
       okc_util.print_trace(1, '----------------------------');
       okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
       okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
       okc_util.print_trace(1, '----------------------------');
    END IF;

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN
         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGLINE',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'OLNUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'INVITEMID',
                             p_token3_value  => model_cimv_rec.object1_id1,
                             p_token4        => 'INVORG',
                             p_token4_value  => model_cimv_rec.object1_id2,
                             p_token5        => 'LINETYPE',
                             p_token5_value  => model_clev_rec.config_item_type
                          );
    END IF;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, 'OUTPUT RECORD - Contract Top Line Item Record:');
       okc_util.print_trace(1, '==============================================');
       okc_util.print_trace(1, 'Id                    = '||to_char(lx_cimv_rec.id));
       okc_util.print_trace(1, 'Contract Line Id      = '||lx_cimv_rec.cle_id);
       okc_util.print_trace(1, 'Contract Header Id    = '||to_char(lx_cimv_rec.chr_id));
       okc_util.print_trace(1, 'Dnz Contract Header Id= '||lx_cimv_rec.dnz_chr_id);
       okc_util.print_trace(1, 'Contract Line Id For  = '||to_char(lx_cimv_rec.cle_id_for));
       okc_util.print_trace(1, 'Object1 Id1           = '||lx_cimv_rec.object1_id1);
       okc_util.print_trace(1, 'Object1 Id2           = '||lx_cimv_rec.object1_id2);
       okc_util.print_trace(1, 'Object Code           = '||lx_cimv_rec.jtot_object1_code);
       okc_util.print_trace(1, 'No. of Items          = '||lx_cimv_rec.number_of_items);
       okc_util.print_trace(1, 'UoM Code              = '||lx_cimv_rec.uom_code);
       okc_util.print_trace(1, 'EXCEPTION Y/N         = '||lx_cimv_rec.exception_yn);
       okc_util.print_trace(1, 'Priced Item Y/N       = '||lx_cimv_rec.priced_item_yn);
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, '================================================');
    END IF;

--       Creating TOP_BASE_LINE which will be child of TOP MODEL LINE
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(1, 'CREATE TOP BASE LINE');
         okc_util.print_trace(1, '=====================');
      END IF;

      l_clev_rec := p_clev_rec;
      l_cimv_rec := p_cimv_rec;

      rolledup_price_negotiated :=  nvl(p_clev_rec.price_negotiated,0);
      rolledup_line_list_price  :=  nvl(p_clev_rec.line_list_price,0);

      l_clev_rec.config_item_type := G_BASE_LINE;
      l_clev_rec.config_top_model_line_id := lx_clev_rec.id;
      l_clev_rec.chr_id           := NULL;
--      l_clev_rec.dnz_chr_id     := lx_clev_rec.dnz_chr_id;
      l_clev_rec.cle_id           := lx_clev_rec.id;
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(1, ' ');
         okc_util.print_trace(1, 'INPUT RECORD - Contract Top Line Record:');
         okc_util.print_trace(1, '========================================');
         okc_util.print_trace(1, 'Contract Line Number     = '||l_clev_rec.line_number);
         okc_util.print_trace(1, 'Contract Header Id       = '||l_clev_rec.chr_id);
         okc_util.print_trace(1, 'Dnz Contract Header Id   = '||l_clev_rec.dnz_chr_id);
         okc_util.print_trace(1, 'Display Sequence         = '||l_clev_rec.display_sequence);
         okc_util.print_trace(1, 'Line Style Id            = '||l_clev_rec.lse_id);
         okc_util.print_trace(1, 'Currency code            = '||l_clev_rec.currency_code);
         okc_util.print_trace(1, 'Price Level Ind.         = '||l_clev_rec.price_level_ind);
         okc_util.print_trace(1, 'Unit Price               = '||l_clev_rec.price_unit);
         okc_util.print_trace(1, 'Negotiated price         = '||l_clev_rec.price_negotiated);
         okc_util.print_trace(1, 'Hidden Ind.              = '||l_clev_rec.hidden_ind);
         okc_util.print_trace(1, 'EXCEPTION Y/N            = '||l_clev_rec.exception_yn);
         okc_util.print_trace(1, 'Status Code              = '||l_clev_rec.sts_code);
         okc_util.print_trace(1, 'Start Date               = '||l_clev_rec.start_date);
         okc_util.print_trace(1, 'End Date                 = '||l_clev_rec.END_date);
         okc_util.print_trace(1, 'Orig system source code  = '||l_clev_rec.orig_system_source_code);
         okc_util.print_trace(1, 'Orig system id           = '||l_clev_rec.orig_system_id1);
         okc_util.print_trace(1, 'Orig system reference    = '||l_clev_rec.orig_system_reference1);
         okc_util.print_trace(1, 'Config Header Id         = '||l_clev_rec.config_header_id);
         okc_util.print_trace(1, 'Config Revison Number    = '||l_clev_rec.config_revision_number);
         okc_util.print_trace(1, 'Config Item Type         = '||l_clev_rec.config_item_type);
         okc_util.print_trace(1, 'Config Complete          = '||l_clev_rec.config_complete_yn);
         okc_util.print_trace(1, 'Config valid             = '||l_clev_rec.config_valid_yn);
         okc_util.print_trace(1, '----------------------------');
         okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
         okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
         okc_util.print_trace(1, '----------------------------');
         okc_util.print_trace(1, '--------------------------------------------------------');
         okc_util.print_trace(1, '>START - ******* OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE -');
      END IF;

      okc_contract_pub.create_contract_line(p_api_version   => 1
                                           ,p_init_msg_list => OKC_API.G_FALSE
                                           ,x_return_status => l_return_status
                                           ,x_msg_count     => l_msg_count
                                           ,x_msg_data      => l_msg_data
                                           ,p_clev_rec      => l_clev_rec
                                           ,x_clev_rec      => lx_clev_rec
                                            );

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(1, '<END - ******* OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE -');
        okc_util.print_trace(1, '----------------------------');
        okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
        okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
        okc_util.print_trace(1, '----------------------------');
     END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN

         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGLINE',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'OLNUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'ITEM',
                             p_token3_value  => l_cimv_rec.object1_id1,
                             p_token4        => 'LINETYPE',
                             p_token4_value  => l_clev_rec.config_item_type
                          );
    END IF;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    line_inf_tab_counter := p_line_inf_tab.count+1;
    p_line_inf_tab(line_inf_tab_counter).object1_id1 := lx_clev_rec.orig_system_id1;
    p_line_inf_tab(line_inf_tab_counter).line_type   := G_BASE_LINE;
    p_line_inf_tab(line_inf_tab_counter).cle_id      := lx_clev_rec.id;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, 'OUTPUT RECORD - Contract Top Line Record:');
       okc_util.print_trace(1, '=========================================');
       okc_util.print_trace(1, 'Contract Header Id    = '||to_char(lx_clev_rec.chr_id));
       okc_util.print_trace(1, 'Contract DNZ Header Id= '||to_char(lx_clev_rec.dnz_chr_id));
       okc_util.print_trace(1, 'Contract Line Id      = '||lx_clev_rec.cle_id);
       okc_util.print_trace(1, 'Line Number           = '||lx_clev_rec.line_number);
       okc_util.print_trace(1, 'Line Style Id         = '||lx_clev_rec.lse_id);
       okc_util.print_trace(1, '-->Order Line Id        = '||lx_clev_rec.orig_system_id1);
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, '================================================');
       okc_util.print_trace(1, 'CREATE CONTRACT LINE ITEM ');
       okc_util.print_trace(1, '================================================');
       okc_util.print_trace(1, ' ');
    END IF;

     -- create contract item
    l_cimv_rec.cle_id            := lx_clev_rec.id;
    l_cimv_rec.dnz_chr_id        := lx_clev_rec.dnz_chr_id;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, 'INPUT RECORD - Contract Top Line Item Record:');
       okc_util.print_trace(1, '=============================================');
       okc_util.print_trace(1, 'Contract Line Id      = '||l_cimv_rec.cle_id);
       okc_util.print_trace(1, 'Dnz Contract Header Id= '||l_cimv_rec.dnz_chr_id);
       okc_util.print_trace(1, 'Object1 Id1           = '||l_cimv_rec.object1_id1);
       okc_util.print_trace(1, 'Object1 Id2           = '||l_cimv_rec.object1_id2);
       okc_util.print_trace(1, 'Object Code           = '||l_cimv_rec.jtot_object1_code);
       okc_util.print_trace(1, 'No. of Items          = '||l_cimv_rec.number_of_items);
       okc_util.print_trace(1, 'UoM Code              = '||l_cimv_rec.uom_code);
       okc_util.print_trace(1, 'Item Priced           = '||l_cimv_rec.priced_item_yn);
    END IF;

-- insert contract item
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, '----------------------------');
       okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
       okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
       okc_util.print_trace(1, '----------------------------');
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, '--------------------------------------------------------');
       okc_util.print_trace(1, '>START - ******* OKC_CONTRACT_ITEM_PUB.CREATE_CONTRACT_ITEM -');
    END IF;

    okc_contract_item_pub.create_contract_item(p_api_version   => 1
                                              ,p_init_msg_list => OKC_API.G_FALSE
                                              ,x_return_status => l_return_status
                                              ,x_msg_count     => l_msg_count
                                              ,x_msg_data      => l_msg_data
                                              ,p_cimv_rec      => l_cimv_rec
                                              ,x_cimv_rec      => lx_cimv_rec
                                              );

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, '<END - ******* OKC_CONTRACT_ITEM_PUB.CREATE_CONTRACT_ITEM -');
       okc_util.print_trace(1, '--------------------------------------------------------');
       okc_util.print_trace(1, '----------------------------');
       okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
       okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
       okc_util.print_trace(1, '----------------------------');
    END IF;

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN
         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGLINE',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'OLNUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'INVITEMID',
                             p_token3_value  => l_cimv_rec.object1_id1,
                             p_token4        => 'INVORG',
                             p_token4_value  => l_cimv_rec.object1_id2,
                             p_token5        => 'LINETYPE',
                             p_token5_value  => l_clev_rec.config_item_type
                          );
    END IF;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, 'OUTPUT RECORD - Contract Top Line Item Record:');
       okc_util.print_trace(1, '==============================================');
       okc_util.print_trace(1, 'Id                    = '||to_char(lx_cimv_rec.id));
       okc_util.print_trace(1, 'Contract Line Id      = '||lx_cimv_rec.cle_id);
       okc_util.print_trace(1, 'Contract Header Id    = '||to_char(lx_cimv_rec.chr_id));
       okc_util.print_trace(1, 'Dnz Contract Header Id= '||lx_cimv_rec.dnz_chr_id);
       okc_util.print_trace(1, 'Contract Line Id For  = '||to_char(lx_cimv_rec.cle_id_for));
       okc_util.print_trace(1, 'Object1 Id1           = '||lx_cimv_rec.object1_id1);
       okc_util.print_trace(1, 'Object1 Id2           = '||lx_cimv_rec.object1_id2);
       okc_util.print_trace(1, 'Object Code           = '||lx_cimv_rec.jtot_object1_code);
       okc_util.print_trace(1, 'No. of Items          = '||lx_cimv_rec.number_of_items);
       okc_util.print_trace(1, 'UoM Code              = '||lx_cimv_rec.uom_code);
       okc_util.print_trace(1, 'EXCEPTION Y/N         = '||lx_cimv_rec.exception_yn);
       okc_util.print_trace(1, 'Priced Item Y/N       = '||lx_cimv_rec.priced_item_yn);
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, '================================================');
    END IF;


-- Call to create Child Items for TOP_BASE_LINE
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, '>START CREATING CHILD RECORDS FOR TOP BASE LINE');
       okc_util.print_trace(1, '===============================================');
    END IF;
    create_config_sublines(p_source_inf_rec    => p_source_inf_rec,
                           p_parent_clev_rec   => lx_clev_rec ,
                           p_parent_cimv_rec   => lx_cimv_rec,
                           p_line_inf_tab      => p_line_inf_tab,
                           x_return_status     => l_return_status
                           ) ;
  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN
         okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                             p_msg_name      => 'OKC_CONFIGCREATE',
                             p_token1        => 'ONUMBER',
                             p_token1_value  => p_source_inf_rec.object_number,
                             p_token2        => 'LINENUMBER',
                             p_token2_value  => p_source_inf_rec.line_number,
                             p_token3        => 'ITEM',
                             p_token3_value  => lx_cimv_rec.object1_id1,
                             p_token4        => 'LINETYPE',
                             p_token4_value  => G_NORMAL_LINE
                            );
  END IF;
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, '<END CREATING CHILD RECORDS FOR TOP BASE LINE');
     okc_util.print_trace(1, '=============================================');
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, ' ');
  END IF;

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;

-- Call to Update Rolledup List Price and Rolled up negotiated Price
   xmodel_clev_rec.line_list_price  := rolledup_line_list_price;
   xmodel_clev_rec.price_negotiated := rolledup_price_negotiated;
--  TO Update CONFIG_TOP_MODEL_LINE_ID on TOP_MODEL_LINE
   xmodel_clev_rec.config_top_model_line_id := lx_clev_rec.config_top_model_line_id;
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, ' ');
       okc_util.print_trace(1, '>START UPDATING TOP_MODEL_LINE ROLLEDUP PRICE');
       okc_util.print_trace(1, '=============================================');
       okc_util.print_trace(1, '-----------------------------------------------------------------');
       okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
       okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
       okc_util.print_trace(1, '-----------------------------------------------------------------');
       okc_util.print_trace(1, 'Rolled Up Line List Price  : '||model_clev_rec.line_list_price );
       okc_util.print_trace(1, 'Rolled Up Price Negotiated : '||model_clev_rec.price_negotiated);
       okc_util.print_trace(1, '--------------------------------------------------------');
       okc_util.print_trace(1, '>START - ******* OKC_CONTRACT_PUB.UPDATE_CONTRACT_LINE -');
    END IF;

    okc_contract_pub.update_contract_line(p_api_version   => 1
                                         ,p_init_msg_list => OKC_API.G_FALSE
                                         ,x_return_status => l_return_status
                                         ,x_msg_count     => l_msg_count
                                         ,x_msg_data      => l_msg_data
                                         ,p_clev_rec      => xmodel_clev_rec
                                         ,x_clev_rec      => x_clev_rec
                                          );


    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR l_return_status = OKC_API.G_RET_STS_ERROR THEN

      okc_api.set_message(p_app_name      => OKC_API.G_APP_NAME,
                          p_msg_name      => 'OKC_UPD_PRICE',
                          p_token1        => 'ONUMBER',
                          p_token1_value  => p_source_inf_rec.object_number,
                          p_token2        => 'OLNUMBER',
                          p_token2_value  => p_source_inf_rec.line_number
                          );
   END IF;
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(1, '<END - ******* OKC_CONTRACT_PUB.UPDATE_CONTRACT_LINE -');
       okc_util.print_trace(1, '----------------------------');
       okc_util.print_trace(1, 'Context org_id          = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID'));
       okc_util.print_trace(1, 'Context organization_id = '|| SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID'));
       okc_util.print_trace(1, '----------------------------');
    END IF;
   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;

      IF (l_debug = 'Y') THEN
         okc_util.print_trace(0, 'Normal Exit From Configurator API');
      END IF;
EXCEPTION
WHEN OTHERS THEN
-- store SQL error message on message stack for caller
OKC_API.set_message(OKC_API.G_APP_NAME,
                   'OKC_CONTRACTS_UNEXP_ERROR',
                   'SQLCODE',
                    SQLCODE,
                   'SQLERRM',
                    SQLERRM);
 IF (l_debug = 'Y') THEN
    okc_util.print_trace(0, 'Abnormal Exit From Configurator API');
 END IF;
x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END create_k_config_lines;



-- =====================================================================================
--
-- Purpose: To build the relationship between quote lines which is
--          populated in the aso_line_relationships table
--
-- IN parameters: px_k2q_line_tbl       - holds k to q relation
--                px_qte_line_tbl       - holds quote line information
--                px_qte_line_dtl_tbl   - holds quote line detail information
--
-- OUT parameters: x_line_rltship_tab   - holds the information about relationship
--                                        between quote lines.
--                 x_return_status      - Return status of the procedure executed.
--
-- =====================================================================================

PROCEDURE quote_line_relationship( px_k2q_line_tbl     IN line_rel_tab_type
                         	,px_qte_line_tbl       IN ASO_QUOTE_PUB.qte_line_tbl_type
			 	,px_qte_line_dtl_tbl   IN ASO_QUOTE_PUB.qte_line_dtl_tbl_type
                         	,x_line_rltship_tab    OUT NOCOPY ASO_QUOTE_PUB.line_rltship_tbl_type
                         	,x_return_status       OUT NOCOPY  VARCHAR2
                                  ) IS

i BINARY_INTEGER := 0;
k BINARY_INTEGER;
p BINARY_INTEGER := 0;

e_exit EXCEPTION;

l_config_rltship_code	CONSTANT VARCHAR2(30) := 'CONFIG';
l_service_rltship_code	CONSTANT VARCHAR2(30) := 'SERVICE';

CURSOR c_qte_line_rlt(b_rlted_qle_id IN NUMBER) IS
	SELECT
	   quote_line_id,
	   line_relationship_id
	FROM
	   okx_qte_line_rlshps_v
	 --    aso_line_relationships
	WHERE
	   related_quote_line_id = b_rlted_qle_id
	AND relationship_type_code = 'CONFIG';

l_qte_line_rlt	c_qte_line_rlt%ROWTYPE;

l_line_rltship_tab   ASO_QUOTE_PUB.line_rltship_tbl_type;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2,'  ');
     okc_util.print_trace(2,' START: OKC_OC_INT_CONFIG_PVT.quote_line_relationship ');
     okc_util.print_trace(2,'  ');
  END IF;


--
-- housekeeping
--

  x_line_rltship_tab.DELETE;
  l_line_rltship_tab.DELETE;

--

 IF px_k2q_line_tbl.FIRST IS NOT NULL THEN
    FOR i IN  px_k2q_line_tbl.FIRST.. px_k2q_line_tbl.LAST LOOP
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(2,' px_k2q_line_tbl('||i||').q_item_type_code = '||px_k2q_line_tbl(i).q_item_type_code);
      END IF;

       IF px_k2q_line_tbl(i).q_item_type_code = g_aso_model_item THEN     -- 'MDL'
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'Inside item type code = MDL check ');
		END IF;
	  NULL;			-- No relation has to be created for the Top model line
       ELSIF
	  px_k2q_line_tbl(i).q_item_type_code = g_aso_config_item THEN     -- 'CFG'

		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'Inside item type code = CFG check ');
		END IF;
	--
	-- Need to check the operation code of the config item
	--
	     IF px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code = g_aso_op_code_create THEN

		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'Oper code of config item = '||px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code);
		END IF;

		p := p + 1;
		l_line_rltship_tab(p).operation_code 	     := g_aso_op_code_create;
		l_line_rltship_tab(p).related_qte_line_index := px_k2q_line_tbl(i).q_line_idx;
		l_line_rltship_tab(p).relationship_type_code := l_config_rltship_code;	-- CONFIG

	    -- Need to get the parent line id by
	    -- Looping through px_k2q_line_tbl to get the corresponding index.
	    --
		FOR k in px_k2q_line_tbl.FIRST..px_k2q_line_tbl.LAST LOOP

		   IF px_k2q_line_tbl(k).k_line_id = px_k2q_line_tbl(i).k_parent_line_id THEN

		      -- Need to check on the operation code of the quote line of the parent line

		        IF (l_debug = 'Y') THEN
   		        okc_util.print_trace(2,'Checking on the oper code of parent line');
		        END IF;

		      IF px_qte_line_tbl(px_k2q_line_tbl(k).q_line_idx).operation_code = g_aso_op_code_create THEN

			 l_line_rltship_tab(p).qte_line_index := px_k2q_line_tbl(k).q_line_idx;

		        IF (l_debug = 'Y') THEN
   		        okc_util.print_trace(2,'Oper code of parent line is CREATE - q_line_idx found');
		        END IF;
		      ELSE
			 l_line_rltship_tab(p).quote_line_id := px_qte_line_tbl(px_k2q_line_tbl(k).q_line_idx).quote_line_id;
		        IF (l_debug = 'Y') THEN
   		        okc_util.print_trace(2,'Oper code of parent line is UPDATE - q_line_id found');
		        END IF;

		      END IF;  -- IF px_qte_line_tbl(px_k2q_line_tbl(k).q_line_idx

		      EXIT;
		   END IF;  -- IF px_k2q_line_tbl(k).k_line_id
		END LOOP; -- FOR k in px_k2q_line_tbl.FIRST..

  		IF (l_debug = 'Y') THEN
     		okc_util.print_trace(2,'  ');
     		okc_util.print_trace(2,' Values in the l_line_rltship_tab for the item type code CFG and operation code create is ');
     		okc_util.print_trace(2,'  ');
     		okc_util.print_trace(2,'Operation code   = '||l_line_rltship_tab(p).operation_code);
     		okc_util.print_trace(2,'Rltd qte line idx= '||l_line_rltship_tab(p).related_qte_line_index);
     		okc_util.print_trace(2,'Rltshp type code = '||l_line_rltship_tab(p).relationship_type_code);
     		okc_util.print_trace(2,'Qte line index   = '||l_line_rltship_tab(p).qte_line_index);
     		okc_util.print_trace(2,'Qte line id      = '||l_line_rltship_tab(p).quote_line_id);
  		END IF;

	     ELSE	-- px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code ( UPDATE )

		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'Oper code of config item UPDATE');
		END IF;

		p := p + 1;
		--
		-- The operation code is not required here as it's been identified as an update
		--
--		l_line_rltship_tab(p).operation_code := g_aso_op_code_create;
		l_line_rltship_tab(p).related_quote_line_id := px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).quote_line_id;
		l_line_rltship_tab(p).relationship_type_code := l_config_rltship_code;

	    --
	    -- Need to get the parent line id by
	    -- Looping through px_k2q_line_tbl to get the corresponding index.
	    --
		FOR k in px_k2q_line_tbl.FIRST..px_k2q_line_tbl.LAST LOOP

		   IF px_k2q_line_tbl(k).k_line_id = px_k2q_line_tbl(i).k_parent_line_id THEN

		      -- Need to check on the operation code of the quote line of the parent line

		      IF px_qte_line_tbl(px_k2q_line_tbl(k).q_line_idx).operation_code = g_aso_op_code_create THEN

			 l_line_rltship_tab(p).qte_line_index := px_k2q_line_tbl(k).q_line_idx;

		         IF (l_debug = 'Y') THEN
   		         okc_util.print_trace(2,'Oper code of parent line is CREATE - q_line_idx found');
		         END IF;
		      ELSE
			 l_line_rltship_tab(p).quote_line_id := px_qte_line_tbl(px_k2q_line_tbl(k).q_line_idx).quote_line_id;
		        IF (l_debug = 'Y') THEN
   		        okc_util.print_trace(2,'Oper code of parent line is UPDATE - q_line_id found');
		        END IF;

		      END IF;  -- IF px_qte_line_tbl(px_k2q_line_tbl(k).q_line_idx

		      EXIT;
		   END IF;  -- IF px_k2q_line_tbl(k).k_line_id
		END LOOP; -- FOR k in px_k2q_line_tbl.FIRST..

  		IF (l_debug = 'Y') THEN
     		okc_util.print_trace(2,'  ');
     		okc_util.print_trace(2,' Values in the l_line_rltship_tab for the item type code CFG and operation code update is ');
     		okc_util.print_trace(2,'  ');
     		okc_util.print_trace(2,'Rltd qte line id = '||l_line_rltship_tab(p).related_quote_line_id);
     		okc_util.print_trace(2,'Rltshp type code = '||l_line_rltship_tab(p).relationship_type_code);
     		okc_util.print_trace(2,'Qte line index   = '||l_line_rltship_tab(p).qte_line_index);
     		okc_util.print_trace(2,'Qte line id      = '||l_line_rltship_tab(p).quote_line_id);
  		END IF;
	    --
	    -- Need to check the existance of a relationship in the ASO_LINE_RELATIONSHIPS table
	    -- (i.e. okx_line_relationships_v)
	    --
		   OPEN c_qte_line_rlt(l_line_rltship_tab(p).related_quote_line_id);
		   FETCH c_qte_line_rlt INTO l_qte_line_rlt;
		   IF c_qte_line_rlt%FOUND THEN

			IF l_qte_line_rlt.quote_line_id = l_line_rltship_tab(p).related_quote_line_id THEN
			--
			-- Delete the constructed record,because the entry has been found in the table
			-- and doesnot require any processing.
			--
  			IF (l_debug = 'Y') THEN
     			okc_util.print_trace(2,'Validated the existing relationship and deleting the ');
     			okc_util.print_trace(2,'constructed entry, as no further processing is required');
  			END IF;

			    l_line_rltship_tab.DELETE(p);
			ELSE
			--
			-- The record is in the table and it is for a different quote id
			-- and since it is an update,it is not valid and so raise an exception
			--
  			IF (l_debug = 'Y') THEN
     			okc_util.print_trace(2,'Rltn exists for a diff quote id, raising an exception');
  			END IF;

			  OKC_API.set_message(p_app_name => OKC_API.G_APP_NAME,
                          p_msg_name      => 'OKC_UPD_LINERLTN',
                          p_token1        => 'QUOTELINEID',
                          p_token1_value  => l_qte_line_rlt.quote_line_id,
                          p_token2        => 'RLTDQTELINEID',
                          p_token2_value  => l_line_rltship_tab(p).related_quote_line_id,
                          p_token3        => 'RLTSHPTYPECODE',
                          p_token3_value  => l_config_rltship_code
                          			);
			  x_return_status := OKC_API.G_RET_STS_ERROR;
			  RAISE e_exit;
			END IF;
		   ELSE		-- IF c_qte_line_rlt%FOUND
			--
			-- This is the case of an update and the record is not found
			-- Set an error message and raise an exception
			--
  			IF (l_debug = 'Y') THEN
     			okc_util.print_trace(2,'No rec found while trying to validate the rltnshp, raising an exception');
  			END IF;
			  OKC_API.set_message(p_app_name => OKC_API.G_APP_NAME,
                          p_msg_name      => 'OKC_UPD_LINERLTNOTFOUND',
                          p_token1        => 'RLTDQTELINEID',
                          p_token1_value  => l_line_rltship_tab(p).related_quote_line_id,
                          p_token2        => 'RLTSHPTYPECODE',
                          p_token2_value  => l_config_rltship_code
                          			);
			  x_return_status := OKC_API.G_RET_STS_ERROR;
		    	  RAISE e_exit;
		   END IF; 	-- IF c_qte_line_rlt%FOUND

	           CLOSE c_qte_line_rlt;

	     END IF; -- px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code ( create or update )

       ELSIF    -- px_k2q_line_tbl(i).q_item_type_code  -- CFG

	    px_k2q_line_tbl(i).q_item_type_code = g_aso_service_item  THEN     -- 'SRV' -- Bug 1970133
	   IF (l_debug = 'Y') THEN
   	   okc_util.print_trace(2,'px_qte_line_tbl - operation code = '||px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code);
	   END IF;

	  IF px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code = g_aso_op_code_create THEN

	--
	-- Need to check the quote detail line to ensure that there is a covered line
	--
	-- Loop through the px_qte_line_dtl_tbl to retrieve the attached index k
	-- using px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx)
	--
	  IF (l_debug = 'Y') THEN
   	  okc_util.print_trace(2,'Looping through through the px_qte_line_dtl_tbl to retrieve the attached QDL');
	  END IF;
	   IF px_qte_line_dtl_tbl.FIRST IS NOT NULL THEN
	      FOR k IN px_qte_line_dtl_tbl.FIRST..px_qte_line_dtl_tbl.LAST LOOP

		 IF px_qte_line_dtl_tbl(k).qte_line_index = px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).line_number THEN
		    --
		    -- Need to ensure that qdl(k) has a covered line
		    --
		    IF px_qte_line_dtl_tbl(k).service_ref_type_code  = okc_oc_int_ktq_pvt.g_qte_ref_quote THEN
		  	-- Now this is a covered line and hence the relationship needs to be created
		   	-- Need to use the index of the related quote line (service line).

		       IF NVL(px_qte_line_dtl_tbl(k).service_ref_qte_line_index,OKC_API.G_MISS_NUM) <>
						OKC_API.G_MISS_NUM THEN
			  IF (l_debug = 'Y') THEN
   			  okc_util.print_trace(2,'Create the relationship for the cov line using index');
			  END IF;
		          p := p+1;
		          l_line_rltship_tab(p).operation_code    := g_aso_op_code_create;
                          l_line_rltship_tab(p).related_qte_line_index := px_k2q_line_tbl(i).q_line_idx;
                          l_line_rltship_tab(p).relationship_type_code := l_service_rltship_code;  -- SERVICE
			  l_line_rltship_tab(p).qte_line_index := px_qte_line_dtl_tbl(k).service_ref_qte_line_index;

			  IF (l_debug = 'Y') THEN
   			  okc_util.print_trace(2,'Quote line index = '||l_line_rltship_tab(p).qte_line_index);
			  END IF;

		       ELSE	-- ( update )need to use the id of the covered line

			  IF (l_debug = 'Y') THEN
   			  okc_util.print_trace(2,'Create the relationship for the cov line using id');
			  END IF;

			  p := p+1;
			  l_line_rltship_tab(p).operation_code    := g_aso_op_code_create;
			  l_line_rltship_tab(p).related_qte_line_index := px_k2q_line_tbl(i).q_line_idx;
			  l_line_rltship_tab(p).relationship_type_code := l_service_rltship_code;  -- SERVICE
			  l_line_rltship_tab(p).quote_line_id := px_qte_line_dtl_tbl(k).service_ref_line_id;

			  IF (l_debug = 'Y') THEN
   			  okc_util.print_trace(2,'Quote line id    = '||l_line_rltship_tab(p).quote_line_id);
			  END IF;

		       END IF;  -- IF NVL(px_qte_line_dtl_tbl...

			  IF (l_debug = 'Y') THEN
   			  okc_util.print_trace(2,'Operation code    = '||l_line_rltship_tab(p).operation_code);
   			  okc_util.print_trace(2,'Rltd qte line idx = '||l_line_rltship_tab(p).related_qte_line_index);
   			  okc_util.print_trace(2,'rltshp type code  = '||l_line_rltship_tab(p).relationship_type_code);
			  END IF;

		    END IF;	-- IF px_qte_line_dtl_tbl(k).service_ref_type_code  = okc_oc_int_ktq_pvt.g_qte_ref_quote

		  EXIT;

		 END IF;  -- px_qte_line_dtl_tbl(k).qte_line_index = px_qte_line_tbl(px

	      END LOOP; -- FOR k IN px_qte_line_dtl_tbl.FIRST..px_

	   END IF;  -- IF px_qte_line_dtl_tbl.FIRST

	  ELSE	-- px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code = g  (update)
	--
	-- Need to check the quote detail line to ensure that there is a covered line
	--
	-- Loop through the px_qte_line_dtl_tbl to retrieve the attached index k
	-- using px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx)
	--
         IF px_qte_line_dtl_tbl.FIRST IS NOT NULL THEN
	    FOR k IN px_qte_line_dtl_tbl.FIRST..px_qte_line_dtl_tbl.LAST LOOP

	      IF px_qte_line_dtl_tbl(k).qte_line_index = px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).line_number THEN
		    --
		    -- Need to ensure that qdl(k) has a covered line
		    --
	        IF px_qte_line_dtl_tbl(k).service_ref_type_code  = okc_oc_int_ktq_pvt.g_qte_ref_quote THEN

		   	-- Need to use the id of the related quote line (service line).

		       IF NVL(px_qte_line_dtl_tbl(k).service_ref_qte_line_index,OKC_API.G_MISS_NUM) <>
						OKC_API.G_MISS_NUM THEN
			   p := p + 1;
			   l_line_rltship_tab(p).qte_line_index := px_qte_line_dtl_tbl(k).service_ref_qte_line_index;
			  IF (l_debug = 'Y') THEN
   			  okc_util.print_trace(2,'Update the relationship for the cov line using index');
			  END IF;
		        ELSE
			   p := p + 1;
			   l_line_rltship_tab(p).quote_line_id := px_qte_line_dtl_tbl(k).service_ref_line_id;
			  IF (l_debug = 'Y') THEN
   			  okc_util.print_trace(2,'Update the relationship for the cov line using id');
			  END IF;
		        END IF;

		    --
		    -- Need to check the existance of any relationship for the service line id
		    --
		     IF (l_debug = 'Y') THEN
   		     okc_util.print_trace(2,'Checking  the existance of any relationship in okx_line_relationships_v ');
		     END IF;
		   OPEN c_qte_line_rlt(px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).quote_line_id);
		   FETCH c_qte_line_rlt INTO l_qte_line_rlt;
		   IF c_qte_line_rlt%NOTFOUND THEN
		      l_line_rltship_tab(p).operation_code := g_aso_op_code_create;
		     IF (l_debug = 'Y') THEN
   		     okc_util.print_trace(2,'Didnot find any relationship in okx_line_relationships_v, creating one ');
		     END IF;
		   ELSE
		      l_line_rltship_tab(p).operation_code := g_aso_op_code_update;
		      l_line_rltship_tab(p).line_relationship_id := l_qte_line_rlt.line_relationship_id;
		     IF (l_debug = 'Y') THEN
   		     okc_util.print_trace(2,'Found a  relationship in okx_line_relationships_v, updating');
   		     okc_util.print_trace(2,'l_line_rltship_tab('||p||').line_relationship_id = '||l_line_rltship_tab(p).line_relationship_id);
		     END IF;
		   END IF;
		   CLOSE c_qte_line_rlt;

		      l_line_rltship_tab(p).related_quote_line_id := px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).quote_line_id;
                      l_line_rltship_tab(p).relationship_type_code := l_service_rltship_code;  -- SERVICE
		      IF (l_debug = 'Y') THEN
   		      okc_util.print_trace(2,'l_line_rltship_tab('||p||').related_quote_line_id = '||l_line_rltship_tab(p).related_quote_line_id);
   		      okc_util.print_trace(2,'l_line_rltship_tab('||p||').relationship_type_code = '||l_line_rltship_tab(p).relationship_type_code);
		      END IF;


	         ELSE   -- delete
	            --
                    -- Need to check the existance of any relationship for the service line id
                    --
                   OPEN c_qte_line_rlt(px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).quote_line_id);
                   FETCH c_qte_line_rlt INTO l_qte_line_rlt;
                   IF c_qte_line_rlt%FOUND THEN
			p := p+1;
			l_line_rltship_tab(p).operation_code := g_aso_op_code_delete;
			l_line_rltship_tab(p).line_relationship_id := l_qte_line_rlt.line_relationship_id;
			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'Deleting the relationship ');
   			okc_util.print_trace(2,'l_line_rltship_tab('||p||').line_relationship_id = '||l_line_rltship_tab(p).line_relationship_id);
			END IF;

		   END IF;
		   CLOSE c_qte_line_rlt;

		  END IF; -- IF px_qte_line_dtl_tbl(k).service_ref_type_code  = okc_oc_int_ktq_pvt.g_qte_ref_quote THEN

		 END IF;  -- px_qte_line_dtl_tbl(k).qte_line_index = px_qte_li

	      END LOOP;  -- FOR k IN px_qte_line_dtl_tbl.FIRST..px_q

	   END IF; -- IF px_qte_line_dtl_tbl.FIRST IS NOT NULL THEN

	END IF; -- ELSE  -- px_qte_line_tbl(px_k2q_line_tbl(i).q_line_idx).operation_code = g  (update)

       END IF;  -- px_k2q_line_tbl(i).q_item_type_code	-- MDL
    END LOOP;  -- FOR i IN  px_k2q_line_tbl.FIRST
 END IF;  -- IF px_k2q_line_tbl.FIRST IS NOT NULL


  x_line_rltship_tab := l_line_rltship_tab;


  x_return_status := OKC_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN e_exit THEN
 IF c_qte_line_rlt%ISOPEN THEN
    CLOSE c_qte_line_rlt;
 END IF;

WHEN OTHERS THEN

 IF c_qte_line_rlt%ISOPEN THEN
    CLOSE c_qte_line_rlt;
 END IF;

 OKC_API.set_message(G_APP_NAME,
                     G_UNEXPECTED_ERROR,
                     G_SQLCODE_TOKEN,
                     SQLCODE,
                     G_SQLERRM_TOKEN,
                     SQLERRM);
           -- notify caller of an UNEXPECTED error

 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END quote_line_relationship;

END OKC_OC_INT_CONFIG_PVT;

/
