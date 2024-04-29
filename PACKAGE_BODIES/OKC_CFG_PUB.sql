--------------------------------------------------------
--  DDL for Package Body OKC_CFG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CFG_PUB" as
/* $Header: OKCPCFGB.pls 120.1 2005/06/28 12:10:32 smallya noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  -- -------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  -- -------------------------------------------------------------------------
  --l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_PKG_NAME         CONSTANT VARCHAR2(30)  := 'OKC_CFG_PUB';
  G_API_TYPE         CONSTANT VARCHAR2(4)   := '_PUB';
  G_FILE_NAME        CONSTANT VARCHAR2(12)  := 'OKCPCFGB.pls';
  G_QA_SUCCESS       CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_QA_SUCCESS';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

-- ---------------------------------------------------------------------------
-- FUNCTION      : cle_config_check
-- PURPOSE       : To check whether the contract configuration exists
--                 in the okc_k_lines_v Returns Y or N.
--                 Default return value = N
-- ---------------------------------------------------------------------------
 FUNCTION cle_config_check ( p_line_id         IN NUMBER,
                             p_config_hdr_id   IN NUMBER,
                             p_config_rev_nbr  IN NUMBER)
 RETURN VARCHAR2
 IS
   CURSOR cur_cle_config_check ( l_line_id         NUMBER,
                                 l_config_hdr_id   NUMBER,
                                 l_config_rev_nbr  NUMBER )
   IS
   SELECT 'Y'
   FROM   okc_k_lines_v clev
   WHERE  clev.id                     =  l_line_id
   AND    clev.config_item_type       =  'TOP_MODEL_LINE'
   AND    clev.config_header_id       =  l_config_hdr_id
   AND    clev.config_revision_number =  l_config_rev_nbr;

   l_dummy    VARCHAR2(1) := 'N';
BEGIN
  OPEN  cur_cle_config_check (p_line_id,
                              p_config_hdr_id,
                              p_config_rev_nbr);
  FETCH cur_cle_config_check INTO l_dummy;
  CLOSE cur_cle_config_check;

  RETURN l_dummy;

END cle_config_check;

-- ---------------------------------------------------------------------------
-- PROCEDURE     : build_cle_from_cz
-- PURPOSE       : Create/Update/Delete Contract Lines based on
--                 the termination of the configuration call.
--                 gets the configuration details from the
--                 CZ schema tables join to OKC lines table.
-- ---------------------------------------------------------------------------
PROCEDURE build_cle_from_cz (
                  p_api_version_number IN   NUMBER  ,
                  p_init_msg_list      IN   VARCHAR2,
                  p_commit             IN   VARCHAR2,
                  p_config_complete_yn IN   VARCHAR2,
                  p_config_valid_yn    IN   VARCHAR2,
                  p_au_line_rec        IN   OKC_CFG_PUB.au_rec_type,
                  p_config_rec         IN   OKC_CFG_PUB.config_rec_type,
                  x_cfg_list_price     OUT NOCOPY  NUMBER,
                  x_cfg_net_price      OUT NOCOPY  NUMBER,
                  x_return_status      OUT NOCOPY  VARCHAR2,
                  x_msg_count          OUT NOCOPY  NUMBER,
                  x_msg_data           OUT NOCOPY  VARCHAR2 )
IS
   -- -------------------------------------------------------------------------
   -- To handle new configured rows insertion into the contract lines.
   -- -------------------------------------------------------------------------
       CURSOR cur_cle_ins ( l_dnz_chr_id     NUMBER,
                            l_config_hdr_id  NUMBER,
                            l_config_rev_nbr NUMBER ) IS
       SELECT config_hdr_id,
              config_rev_nbr ,
              config_item_id ,
              parent_config_item_id ,
              inventory_item_id ,
              organization_id ,
              component_code ,
              quantity ,
              uom_code ,
              'INSERT'                                 -- operation
        FROM  okx_config_details_v czdv
        WHERE czdv.config_hdr_id    = l_config_hdr_id
        AND   czdv.config_rev_nbr   = l_config_rev_nbr
        AND   NOT EXISTS (
                 SELECT 'x'
                 FROM    okc_k_lines_v   clev,
                         okc_k_items_v   cimv
                 WHERE   clev.id                     = cimv.cle_id
                 AND     clev.dnz_chr_id             = l_dnz_chr_id
                 AND     clev.config_header_id       = czdv.config_hdr_id
                 AND     clev.config_revision_number = czdv.config_rev_nbr
                 AND     cimv.object1_id1            = czdv.inventory_item_id)
	ORDER BY bom_sort_order;  -- Bug 2654009

  -- --------------------------------------------------------------------
  -- To Delete the earlier configuration revision lines to be replaced
  -- with new config revision that is under process.
  -- --------------------------------------------------------------------
     CURSOR cur_old_config (l_config_hdr_id      NUMBER,
                            l_config_rev_nbr     NUMBER,
                            l_top_model_line_id  NUMBER,
                            l_dnz_chr_id         NUMBER) IS
        SELECT cleb.id
        FROM   okc_k_lines_b cleb
        WHERE  cleb.dnz_chr_id             =  l_dnz_chr_id
        AND    cleb.id                     <> l_top_model_line_id
        AND    cleb.config_header_id       =  l_config_hdr_id
        AND    cleb.config_revision_number =  l_config_rev_nbr;

        -- Bug: 2627343 : Changed the reference from the view, to use the
        -- base table instead, for perfomance.

-- -------------------------------------------------------------------------
-- To prepare pricing call related info
-- -------------------------------------------------------------------------
   CURSOR cur_price_cle ( l_dnz_chr_id      NUMBER,
                          l_config_hdr_id   NUMBER,
                          l_config_rev_nbr  NUMBER) IS

        SELECT cleb.id                     id,
               'P'                         pi_bpi,
               cim.number_of_items         qty,
               cim.uom_code                uom_code,
               cleb.currency_code          currency_code,
               cim.jtot_object1_code       object_code,
               cim.object1_id1             id1,
               cim.object1_id2             id2,
               cleb.price_list_id          price_list_id,
               cleb.dnz_chr_id             dnz_chr_id,
               cleb.pricing_date           pricing_date -- Added for Bug 2393302
        FROM   okc_k_lines_b   cleb,
               okc_k_items     cim
        WHERE  cleb.dnz_chr_id             =  l_dnz_chr_id
        AND    cleb.config_header_id       =  l_config_hdr_id
        AND    cleb.config_revision_number =  l_config_rev_nbr
        AND    cleb.id                     =  cim.cle_id
        AND    cleb.config_item_type       <> 'TOP_MODEL_LINE';

           -- Bug: 2627343 : Changed the reference from the view, to use the
           -- base table instead, for perfomance.

-- -------------------------------------------------------------------------
-- To get top-model-id. This is the top-base-line in contract lines.
-- The top-model-line is just an extra line to store rollup price info.
-- -------------------------------------------------------------------------
   CURSOR cur_get_model_id ( l_dnz_chr_id      NUMBER,
                             l_config_hdr_id   NUMBER,
                             l_config_rev_nbr  NUMBER) IS
        SELECT cleb.id                        top_model_id,
               cleb.config_top_model_line_id  top_model_line_id
        FROM   okc_k_lines_b   cleb
        WHERE  cleb.dnz_chr_id             =  l_dnz_chr_id
        AND    cleb.config_header_id       =  l_config_hdr_id
        AND    cleb.config_revision_number =  l_config_rev_nbr
        AND    cleb.config_item_type       = 'TOP_MODEL_LINE';

           -- Bug: 2627343 : Changed the reference from the view, to use the
           -- base table instead, for perfomance.


-- -------------------------------------------------------------------------
-- To get cle_id. Required to update the pricing info for related lines.
-- -------------------------------------------------------------------------
   CURSOR cur_line_info ( l_line_id NUMBER )
   IS
   SELECT cleb.cle_id,
          cleb.chr_id,
          cleb.line_number,
          cleb.display_sequence
   FROM   okc_k_lines_b cleb
   WHERE  cleb.id = l_line_id;

-- -------------------------------------------------------------------------
-- To get pricing date from OKC_K_HEADERS_B -- Added for Bug 2393302
-- -------------------------------------------------------------------------
   CURSOR cur_hdr_pr_date ( l_dnz_chr_id NUMBER )
   IS
   SELECT chrv.pricing_date
   FROM   okc_k_headers_b chrv
   WHERE  chrv.id = l_dnz_chr_id;

-- -------------------------------------------------------------------------
-- To get price list id. Required to default value for config lines.
-- Modified for Bug 2393302 , getting pricing date also
-- -------------------------------------------------------------------------
   CURSOR cur_pr_list ( l_line_id NUMBER )
   IS
   SELECT clev.price_list_id,clev.pricing_date
   FROM   okc_k_lines_b clev
   WHERE  clev.id = l_line_id;

/* Commented for Bug 2393302
-- -------------------------------------------------------------------------
-- To get price list id. Required to default value for config lines.
-- -------------------------------------------------------------------------
   CURSOR cur_pr_list ( l_line_id NUMBER )
   IS
   SELECT clev.price_list_id
   FROM   okc_k_lines_b clev
   WHERE  clev.id = l_line_id;
*/

-- -------------------------------------------------------------------------
-- build_cle_from_cz variable declarations:
-- -------------------------------------------------------------------------
 l_api_name                    CONSTANT VARCHAR2(30) := 'build_cle_from_cz';
 l_api_version_number          CONSTANT NUMBER       := 1.0;
 l_init_msg_list               VARCHAR2(1)           := OKC_API.G_FALSE;
 l_index                       BINARY_INTEGER        := 0;
 l_complete_configuration_flag VARCHAR2(3);
 l_valid_configuration_flag    VARCHAR2(3);
 l_config_exists               VARCHAR2(1)           := 'N';
 l_cle_id                      NUMBER;
 l_line_id                     NUMBER;
 l_quantity                    NUMBER;
 l_inventory_item_id           NUMBER;
 l_uom_code                    VARCHAR2(3);
 l_org_id                      NUMBER;
 l_top_model_line_id           NUMBER;
 l_top_base_line_id            NUMBER;
 l_config_line_id              NUMBER;
 i                             NUMBER  := 1;
 l_chr_id                      NUMBER  := 0;
 l_cur_chr_id                  NUMBER := -999999999;
 l_cur_cle_id                  NUMBER := -999999999;
 l_cur_line_nbr                NUMBER := 0;
 l_display_sequence            NUMBER := 0;
 l_top_model_id                NUMBER;
 l_tot_negotiated              NUMBER := 0;
 l_tot_list_price              NUMBER := 0;
 l_item_name                   VARCHAR2(240);
 l_price_list_id               NUMBER;
 l_hdr_pricing_date            DATE; -- Added for Bug 2393302
 l_line_pricing_date           DATE; -- Added for Bug 2393302
 l_pricing_date                DATE; -- Added for Bug 2393302
 l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

-- ---------------------------------------------------------------
-- build_cle_from_cz Record type declarations:
-- ---------------------------------------------------------------
 l_config_rec                  OKC_CFG_PUB.config_rec_type;
 cz_track_tbl                  OKC_CFG_PUB.cz_track_tbl_type;
 l_clev_rec                    OKC_CFG_PUB.clev_rec_type;
 l_clev_rec_init               OKC_CFG_PUB.clev_rec_type;
 l_cimv_rec                    OKC_CFG_PUB.cimv_rec_type;
 l_cimv_rec_init               OKC_CFG_PUB.cimv_rec_type;
 x_clev_rec                    OKC_CFG_PUB.clev_rec_type;
 x_cimv_rec                    OKC_CFG_PUB.cimv_rec_type;

-- ---------------------------------------------------------------
-- build_cle_from_cz: Pricing related table of records
-- ---------------------------------------------------------------
 l_control_rec                 OKC_PRICE_PVT.okc_control_rec_type;
 l_CLE_PRICE_TBL               OKC_PRICE_PVT.cle_price_tbl_type;
 l_line_tbl                    OKC_PRICE_PVT.line_tbl_type;
 l_req_line_tbl                QP_PREQ_GRP.line_tbl_type;
 l_req_line_qual_tbl           QP_PREQ_GRP.qual_tbl_type;
 l_req_line_attr_tbl           QP_PREQ_GRP.line_attr_tbl_type;
 l_req_line_detail_tbl         QP_PREQ_GRP.line_detail_tbl_type;
 l_req_line_detail_qual_tbl    QP_PREQ_GRP.line_detail_qual_tbl_type;
 l_req_line_detail_attr_tbl    QP_PREQ_GRP.line_detail_attr_tbl_type;
 l_req_related_line_tbl        QP_PREQ_GRP.related_lines_tbl_type;
 l_pricing_contexts_tbl        QP_PREQ_GRP.line_attr_tbl_type;
 l_qual_contexts_tbl           QP_PREQ_GRP.qual_tbl_type;

BEGIN
     SAVEPOINT build_cle_from_cz;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.set_indentation(l_api_name);
           OKC_DEBUG.log('10: Entered build_cle_from_cz', 2);
     END IF;
     --FND_MSG_PUB.initialize;
okc_api.init_msg_list(p_init_msg_list);

    -- ------------------------------------------------------------
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    -- ------------------------------------------------------------
       l_return_status := OKC_API.START_ACTIVITY(
                                  p_api_name      => l_api_name,
                                  p_pkg_name      => G_PKG_NAME,
                                  p_init_msg_list => p_init_msg_list,
                                  l_api_version   => l_api_version_number,
                                  p_api_version   => p_api_version_number,
                                  p_api_type      => G_API_TYPE,
                                  x_return_status => x_return_status);

    -- Check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  -- -------------------------------------------------------------------
  -- STEP.1:                                  DEBUG: 100 series
  -- Check whether the configuration already exists in okc_k_lines_v
  -- for a given config_header_id and config_revision_number
  -- -------------------------------------------------------------------
  l_config_exists := cle_config_check(p_au_line_rec.id,
                                      p_config_rec.config_hdr_id,
                                      p_config_rec.config_rev_nbr);

  IF l_config_exists = 'Y'
  THEN
      IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('11: Config Exists already in OKC: '||p_au_line_rec.id);
      END IF;
      RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- --------------------------------------------------------------------
  -- STEP.1.1:                                DEBUG: 100 series
  -- Delete the earlier configuration revision lines to be replaced
  -- with new config revision that is under process.
  -- --------------------------------------------------------------------
     IF ( p_au_line_rec.config_hdr_id  <> OKC_API.G_MISS_NUM AND
          p_au_line_rec.config_rev_nbr <> OKC_API.G_MISS_NUM  )
     THEN
         OPEN cur_old_config (p_au_line_rec.config_hdr_id,
                              p_au_line_rec.config_rev_nbr,
                              p_au_line_rec.id,
                              p_au_line_rec.dnz_chr_id);
         LOOP
             FETCH cur_old_config INTO l_line_id;

             EXIT WHEN cur_old_config%NOTFOUND;

             l_clev_rec.id                    := l_line_id;

                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('30: Before delete old revision....');
                END IF;

             OKC_CONTRACT_PUB.delete_contract_line (
                        p_api_version       => l_api_version_number,
                        p_init_msg_list     => l_init_msg_list,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        p_line_id           => l_line_id );

             IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('40: After delete old revision...'||x_return_status);
             END IF;

             FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                       p_data  => x_msg_data);

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('41: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

            -- Check Return Status
            IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

         END LOOP;  -- old config
         CLOSE cur_old_config;

     END IF;     -- earlier config check.

  -- -------------------------------------------------------------------
  -- STEP.2:                                  DEBUG: 100 series
  -- Handle the inserts for the lines that are not existing in OKC.
  -- -------------------------------------------------------------------
      IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('130: Config Hdr Id : '||p_config_rec.config_hdr_id);
            OKC_DEBUG.log('140: Config Rev Nbr: '||p_config_rec.config_rev_nbr);
            OKC_DEBUG.log('150: Line Id       : '||p_au_line_rec.id);
            OKC_DEBUG.log('160: Inv Item Id   : '||p_au_line_rec.inventory_item_id);
      END IF;

     -- Initialize clev record for further process.
     l_clev_rec := l_clev_rec_init;

     OPEN cur_cle_ins ( p_au_line_rec.dnz_chr_id,
                        p_config_rec.config_hdr_id,
                        p_config_rec.config_rev_nbr);
     LOOP
         FETCH cur_cle_ins INTO l_config_rec;

         EXIT WHEN cur_cle_ins%NOTFOUND;
         l_index := l_index + 1;

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('161: l_index = '||l_index);
         END IF;

      -- ------------------------------------------------------------
      -- Added for Bug 2393302.
      -- Getting Pricing_date from Header
      -- ------------------------------------------------------------
         OPEN  cur_hdr_pr_date ( p_au_line_rec.dnz_chr_id );
         FETCH cur_hdr_pr_date INTO l_hdr_pricing_date;
         CLOSE cur_hdr_pr_date;

      -- ------------------------------------------------------------
      -- Determine the price list to be used for config lines.
      -- If the user has selected a pricelist at model line level,
      -- this pricelist will be defaulted to config lines, otherwise
      -- header level pricelist will be defaulted to config lines.
      -- ------------------------------------------------------------
         OPEN  cur_pr_list ( p_au_line_rec.id );
         FETCH cur_pr_list INTO l_price_list_id,l_line_pricing_date;
         -- Getting l_line_pricing_date as per Bug 2393302
         CLOSE cur_pr_list;

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('165: Model Line Pricelist    :'||l_price_list_id);
               OKC_DEBUG.log('166: Header Level Pricelist  :'||p_au_line_rec.hdr_price_list_id);
         END IF;

         l_price_list_id      := NVL(l_price_list_id,
                                     p_au_line_rec.hdr_price_list_id);

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('166: Defaulted Pricelist  :'||l_price_list_id);
         END IF;

         -- Added for Bug 2393302
         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('165.A: Header Pricing Date     :'||l_hdr_pricing_date);
               OKC_DEBUG.log('165.A: Line   Pricing Date     :'||l_line_pricing_date);
         END IF;

         l_pricing_date  := NVL(l_line_pricing_date,
                                      l_hdr_pricing_date);

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('166.A: Defaulted PricingDate  :'||l_pricing_date);
         END IF;

      -- ------------------------------------------------------------

         IF TO_CHAR(l_config_rec.inventory_item_id)=l_config_rec.component_code
         THEN
             -- ------------------------------------------------------------
             -- This is a model item.
             -- Create top model, top base line and top base item.
             -- ------------------------------------------------------------
                IF (l_debug = 'Y') THEN
                      OKC_DEBUG.log('175: Inside Create Model contract lines...'||l_config_rec.inventory_item_id);
                END IF;

         -- -----------------------------------------------------------------
         -- Assign available values to create top model line record
         -- -----------------------------------------------------------------
            l_clev_rec.config_header_id         := p_config_rec.config_hdr_id;
            l_clev_rec.config_revision_number   := p_config_rec.config_rev_nbr;
            l_clev_rec.id                       := p_au_line_rec.id;
            l_clev_rec.dnz_chr_id               := p_au_line_rec.dnz_chr_id;
            l_clev_rec.start_date               := p_au_line_rec.start_date;
            l_clev_rec.end_date                 := p_au_line_rec.end_date;
            l_clev_rec.currency_code            := p_au_line_rec.currency_code;
            l_clev_rec.exception_yn             := 'N';
            l_clev_rec.sts_code                 := 'ENTERED';
            l_clev_rec.sfwt_flag                := 'N';
            l_clev_rec.lse_id                   := p_au_line_rec.lse_id;
            l_clev_rec.config_item_type         := 'TOP_MODEL_LINE';
            l_clev_rec.config_complete_yn       := p_config_complete_yn;
            l_clev_rec.config_valid_yn          := p_config_valid_yn;
            l_clev_rec.config_top_model_line_id := p_au_line_rec.id;
            l_clev_rec.price_level_ind          := 'Y';
            l_clev_rec.item_to_price_yn         := 'Y';
            l_clev_rec.price_list_id            := l_price_list_id;
            l_clev_rec.pricing_date             := l_pricing_date; -- Added for Bug 2393302
         -- -----------------------------------------------------------------

         -- -----------------------------------------------------------------
         -- STEP.2.1:                                      DEBUG: 200 series
         -- CREATE TOP MODEL LINE
         --       To update the user entered row and make it a top model line.
         --       Calls okc_contract_pub.update_contract_line
         --       with the above in-record init values.
         --       No need to create contract item line, as this is update
         --       for the Authoring form row. Form will commit the item row.
         -- -----------------------------------------------------------------
            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('200: Before update contract top model line...');
            END IF;

            OKC_CONTRACT_PUB.update_contract_line
                    ( p_api_version     => l_api_version_number,
                      p_init_msg_list   => l_init_msg_list,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      x_return_status   => x_return_status,
                      p_clev_rec        => l_clev_rec,
                      x_clev_rec        => x_clev_rec);

           IF (l_debug = 'Y') THEN
                 OKC_DEBUG.log('210: Updated contract Top Model Line..'||x_return_status);
           END IF;

           IF (l_debug = 'Y') THEN
                 OKC_DEBUG.log('220: Top Model Line Id : '||x_clev_rec.id);
           END IF;

           FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                     p_data  => x_msg_data);

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('221: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

            -- Check Return Status
            IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

           l_top_model_line_id := x_clev_rec.id;

         -- -----------------------------------------------------------------
         -- STEP.2.2:                                      DEBUG: 300 series
         -- CREATE TOP BASE LINE
         --       Re-Assign above values to create top base line row.
         --       This is the top line of the model hierarchy.
         --       This will contain the same model related information.
         --       Rows starting from here and down,are Query only on the form.
         --       The changes compared to top-model-line are:
         --         - The new line-id is generated by system. g_miss_num now.
         --         - The column config_item_type will have 'TOP_BASE_LINE'
         --         - The display sequence are l_index based for now.
         --         - Config Item Id is populated only for base line and its
         --           children. This is part of the unique key in CZ schema.
         -- -----------------------------------------------------------------
            l_clev_rec.id                    := OKC_API.G_MISS_NUM;  -- init
            l_clev_rec.cle_id                := l_top_model_line_id;
            l_clev_rec.chr_id                := OKC_API.G_MISS_NUM;  -- init
            l_clev_rec.config_item_type      := 'TOP_BASE_LINE';     -- flag
            l_clev_rec.display_sequence      := l_index + 1;
            l_clev_rec.config_item_id        := l_config_rec.config_item_id;

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('300: Before create top base model line...');
            END IF;

            OKC_CONTRACT_PUB.create_contract_line
                    ( p_api_version     => l_api_version_number,
                      p_init_msg_list   => l_init_msg_list,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      x_return_status   => x_return_status,
                      p_clev_rec        => l_clev_rec,
                      x_clev_rec        => x_clev_rec);

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('310: Created Top Base Model Line...'||x_return_status);
            END IF;

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('320:Top Base LineId :'||x_clev_rec.id);
                  OKC_DEBUG.log('330:Config Item Type:'||x_clev_rec.config_item_type);
            END IF;

            FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('391: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

            -- Check Return Status
            IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            l_top_base_line_id := x_clev_rec.id;

            -- -------------------------------------------------------
            -- CZLE: Register top model base details in cz_track_rec.
            -- -------------------------------------------------------
            cz_track_tbl(l_config_rec.config_item_id).config_item_id :=
                         l_config_rec.config_item_id;
            cz_track_tbl(l_config_rec.config_item_id).parent_config_item_id :=
                         l_config_rec.parent_config_item_id;
            cz_track_tbl(l_config_rec.config_item_id).inventory_item_id :=
                         l_config_rec.inventory_item_id;
            cz_track_tbl(l_config_rec.config_item_id).id :=
                         l_top_base_line_id;
            cz_track_tbl(l_config_rec.config_item_id).chr_id :=
                         OKC_API.G_MISS_NUM;
            cz_track_tbl(l_config_rec.config_item_id).dnz_chr_id :=
                         p_au_line_rec.dnz_chr_id;
            cz_track_tbl(l_config_rec.config_item_id).cle_id :=
                         l_top_model_line_id;
            cz_track_tbl(l_config_rec.config_item_id).top_model_line_id :=
                         l_top_model_line_id;
            cz_track_tbl(l_config_rec.config_item_id).component_code :=
                         l_config_rec.component_code;
            cz_track_tbl(l_config_rec.config_item_id).config_hdr_id :=
                         l_config_rec.config_hdr_id;
            cz_track_tbl(l_config_rec.config_item_id).config_rev_nbr:=
                         l_config_rec.config_rev_nbr;
            cz_track_tbl(l_config_rec.config_item_id).line_index := l_index;
            -- -------------------------------------------------------

            FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('400: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

            -- Check Return Status
            IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

         -- -----------------------------------------------------------------
         -- STEP.2.3:                                      DEBUG: 500 series
         -- CREATE TOP BASE LINE ITEM
         -- Assign available values to create corresponding item line record
         -- required for the call to okc_contract_pub.create_item_line
         -- -----------------------------------------------------------------
            l_cimv_rec.cle_id            := l_top_base_line_id;
            l_cimv_rec.dnz_chr_id        := p_au_line_rec.dnz_chr_id;
            l_cimv_rec.object1_id1       := l_config_rec.inventory_item_id;
            l_cimv_rec.object1_id2       := p_au_line_rec.item_object1_id2;
            l_cimv_rec.jtot_object1_code := p_au_line_rec.item_jtot_obj_code;
            l_cimv_rec.number_of_items   := l_config_rec.quantity;
            l_cimv_rec.uom_code          := l_config_rec.uom_code;
            l_cimv_rec.exception_yn      := 'N';
            l_cimv_rec.priced_item_yn    := 'Y';
         -- -----------------------------------------------------------------
            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('500: Before base contract item create ...');
            END IF;

            OKC_CONTRACT_ITEM_PUB.create_contract_item
                                 ( p_api_version   => 1,
                                   p_init_msg_list => OKC_API.G_FALSE,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_cimv_rec      => l_cimv_rec,
                                   x_cimv_rec      => x_cimv_rec);

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('510: Created contract Base model Item ...'||x_return_status);
            END IF;

            FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('511: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

            -- Check Return Status
            IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

         ELSE
            -- -------------------------------------------------------
            -- STEP.2.4:                            DEBUG: 5000 series
            -- This row is a config options line. Child row of a model.
            -- Create sublines and subline item.
            -- -------------------------------------------------------
               IF (l_debug = 'Y') THEN
                     OKC_DEBUG.log('5000: Creating new config line for item ...'||l_config_rec.inventory_item_id);
               END IF;

            -- ----------------------------------------------------------------
            -- STEP.2.4.1                                   DEBUG: 5010 - 5080
            -- Check the validity of the item existance in the Linestyle source
            -- For the linestyle that the user selected, to configure a model,
            -- the same linestyle source should contain the model option items.
            -- The linestyle source should contain the configured system items.
            -- i.e. check for the inventory item is part of the model source.
            -- ----------------------------------------------------------------
               IF (l_debug = 'Y') THEN
                     OKC_DEBUG.log('5010: JTOT Object Code: '||p_au_line_rec.item_jtot_obj_code);
                     OKC_DEBUG.log('5020: Object1 Id1-Item: '||l_config_rec.inventory_item_id);
                     OKC_DEBUG.log('5030: Object1 Id2-Org : '||p_au_line_rec.item_object1_id2);
               END IF;

            -- ---------------------------------------------------------------------------
            -- Call to fetch the item name, with these values
            -- ---------------------------------------------------------------------------
               l_item_name := OKC_UTIL.get_name_from_jtfv
                                     ( p_object_code => p_au_line_rec.item_jtot_obj_code,
                                       p_id1         => l_config_rec.inventory_item_id,
                                       p_id2         => p_au_line_rec.item_object1_id2);

               IF (l_debug = 'Y') THEN
                     OKC_DEBUG.log('5080: Item Name       : '||l_item_name);
               END IF;

               IF l_item_name IS NULL
               THEN
                   -- Item name cannot be found in the selected linestyle source
                   -- Stop processing further, return control to authoring form.
                   ROLLBACK TO SAVEPOINT build_cle_from_cz;

                   OKC_API.SET_MESSAGE( p_app_name     => 'OKC',
                                        p_msg_name     => 'OKC_CONFIG_ERROR',
                                        p_token1       => 'PROCEDURE',
                                        p_token1_value => 'validating linestyle based source item.');

                   -- notify caller of an error
                   x_return_status := OKC_API.G_RET_STS_ERROR;

                   RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;
            -- ----------------------------------------------------------------

         -- -----------------------------------------------------------------
         -- STEP.2.4.2                                     DEBUG: 5100 series
         -- CREATE NEW CONFIG LINE
         --       This is the child line of the model hierarchy.
         --       This will contain the option class and options information.
         --       All the model and option rows are Query only on the form.
         -- -----------------------------------------------------------------
            -- Initialize new contract line input record.
            l_clev_rec := l_clev_rec_init;
            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('5100: New config contract line inited...');
            END IF;

         -- -----------------------------------------------------------------
         -- Assign available values to create config line record
         -- -----------------------------------------------------------------
            l_clev_rec.config_header_id         := p_config_rec.config_hdr_id;
            l_clev_rec.config_revision_number   := p_config_rec.config_rev_nbr;
            l_clev_rec.config_item_id           := l_config_rec.config_item_id;
            l_clev_rec.cle_id                   :=
                       cz_track_tbl(l_config_rec.parent_config_item_id).id;
            l_clev_rec.dnz_chr_id               := p_au_line_rec.dnz_chr_id;
            l_clev_rec.start_date               := p_au_line_rec.start_date;
            l_clev_rec.end_date                 := p_au_line_rec.end_date;
            l_clev_rec.currency_code            := p_au_line_rec.currency_code;
            l_clev_rec.exception_yn             := 'N';
            l_clev_rec.sts_code                 := 'ENTERED';
            l_clev_rec.sfwt_flag                := 'N';
            l_clev_rec.lse_id                   := p_au_line_rec.lse_id;
            l_clev_rec.config_item_type         := 'CONFIG';            -- flag
            l_clev_rec.config_complete_yn       := p_config_complete_yn;
            l_clev_rec.config_valid_yn          := p_config_valid_yn;
            l_clev_rec.config_top_model_line_id := p_au_line_rec.id;
            l_clev_rec.display_sequence         := l_index + 1;
            l_clev_rec.price_level_ind          := 'Y';
            l_clev_rec.item_to_price_yn         := 'Y';
            l_clev_rec.price_list_id            := l_price_list_id;
            l_clev_rec.pricing_date             := l_pricing_date; -- Added for Bug 2393302
         -- -----------------------------------------------------------------

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('5101: Before create config line...');
                  OKC_DEBUG.log('5102: Parent for this line :'||l_clev_rec.cle_id);
            END IF;

            OKC_CONTRACT_PUB.create_contract_line
                    ( p_api_version     => l_api_version_number,
                      p_init_msg_list   => l_init_msg_list,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      x_return_status   => x_return_status,
                      p_clev_rec        => l_clev_rec,
                      x_clev_rec        => x_clev_rec);

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('5110: Created new Config Line...'|| x_return_status);
            END IF;

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('5200: New Cfg line :'||x_clev_rec.cle_id);
                  OKC_DEBUG.log('5210: Cfg Item Type:'||x_clev_rec.config_item_type);
            END IF;

            FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('5290: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

            -- Check Return Status
            IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            l_config_line_id := x_clev_rec.id;


            -- ---------------------------------------------------------------
            -- CZLE: Refresh cz_track_rec details....
            -- ---------------------------------------------------------------
            cz_track_tbl(l_config_rec.config_item_id).config_item_id :=
                         l_config_rec.config_item_id;
            cz_track_tbl(l_config_rec.config_item_id).parent_config_item_id :=
                         l_config_rec.parent_config_item_id;
            cz_track_tbl(l_config_rec.config_item_id).inventory_item_id :=
                         l_config_rec.inventory_item_id;
            cz_track_tbl(l_config_rec.config_item_id).id :=
                         l_config_line_id;
            cz_track_tbl(l_config_rec.config_item_id).chr_id :=
                         OKC_API.G_MISS_NUM;
            cz_track_tbl(l_config_rec.config_item_id).cle_id :=
                         cz_track_tbl(l_config_rec.parent_config_item_id).id;
            cz_track_tbl(l_config_rec.config_item_id).top_model_line_id :=
                         l_top_model_line_id;
            cz_track_tbl(l_config_rec.config_item_id).component_code :=
                         l_config_rec.component_code;
            cz_track_tbl(l_config_rec.config_item_id).config_hdr_id :=
                         l_config_rec.config_hdr_id;
            cz_track_tbl(l_config_rec.config_item_id).config_rev_nbr:=
                         l_config_rec.config_rev_nbr;
            cz_track_tbl(l_config_rec.config_item_id).line_index := l_index;
            -- ---------------------------------------------------------------

         -- -----------------------------------------------------------------
         -- STEP.2.4.3                                     DEBUG: 5300 series
         -- CREATE CONFIG LINE ITEM
         -- Assign available values to create corresponding item line record
         -- required for the call to okc_contract_pub.create_item_line
         -- -----------------------------------------------------------------
            l_cimv_rec.cle_id            := l_config_line_id;
            l_cimv_rec.dnz_chr_id        := p_au_line_rec.dnz_chr_id;
            l_cimv_rec.object1_id1       := l_config_rec.inventory_item_id;
            l_cimv_rec.object1_id2       := p_au_line_rec.item_object1_id2;
            l_cimv_rec.jtot_object1_code := p_au_line_rec.item_jtot_obj_code;
            l_cimv_rec.number_of_items   := l_config_rec.quantity;
            l_cimv_rec.uom_code          := l_config_rec.uom_code;
            l_cimv_rec.exception_yn      := 'N';
            l_cimv_rec.priced_item_yn    := 'Y';
         -- -----------------------------------------------------------------

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('5300: Before config contract item create ...');
            END IF;

            OKC_CONTRACT_ITEM_PUB.create_contract_item
                                 ( p_api_version   => 1,
                                   p_init_msg_list => OKC_API.G_FALSE,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_cimv_rec      => l_cimv_rec,
                                   x_cimv_rec      => x_cimv_rec);

            IF (l_debug = 'Y') THEN
                  OKC_DEBUG.log('5310: Created corresponding Contract Item...'||x_return_status);
            END IF;

            FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('5311: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

            -- Check Return Status
            IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
            THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

         END IF;
     END LOOP;
     CLOSE cur_cle_ins;

  -- -------------------------------------------------------------------
  -- STEP.5:                                  DEBUG: 5600 series
  -- Handle the pricing call and update the line.
  -- -------------------------------------------------------------------
     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5600: Entering Pricing Section ...', 2);
     END IF;

     -- ----------------------------------------------------------
     -- STEP.5.1:
     -- Prepare the contract lines for pricing
     -- ----------------------------------------------------------
        OPEN  cur_price_cle ( p_au_line_rec.dnz_chr_id,
                              p_config_rec.config_hdr_id,
                              p_config_rec.config_rev_nbr);
        LOOP
            FETCH cur_price_cle
            INTO  l_cle_price_tbl(i).id,
                  l_cle_price_tbl(i).pi_bpi,
                  l_cle_price_tbl(i).qty,
                  l_cle_price_tbl(i).uom_code,
                  l_cle_price_tbl(i).currency,
                  l_cle_price_tbl(i).object_code,
                  l_cle_price_tbl(i).id1,
                  l_cle_price_tbl(i).id2,
                  l_cle_price_tbl(i).pricelist_id,
                  l_chr_id,
                  l_cle_price_tbl(i).pricing_date; -- Added for Bug 2393302

             IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('<------------ INPUT LINE - '||i||' ------->');
                   OKC_DEBUG.log('5611: Id      : '||l_cle_price_tbl(i).id);
                   OKC_DEBUG.log('5612: Inv Item: '||l_cle_price_tbl(i).id1);
                   OKC_DEBUG.log('5613: Quantity: '||l_cle_price_tbl(i).qty);
                   OKC_DEBUG.log('5614: UOM Code: '||l_cle_price_tbl(i).uom_code);
                   OKC_DEBUG.log('5615: Currency: '||l_cle_price_tbl(i).currency);
                   OKC_DEBUG.log('5616: Org Id  : '||l_cle_price_tbl(i).id2);
                   OKC_DEBUG.log('5617: Jtot Obj: '||l_cle_price_tbl(i).object_code);
                   OKC_DEBUG.log('5618: Pr List : '||l_cle_price_tbl(i).pricelist_id);
                   OKC_DEBUG.log('5619: Chr Id  : '||l_chr_id);
                   OKC_DEBUG.log('5620: Pricing Date  : '||l_cle_price_tbl(i).pricing_date); -- Added for Bug 2393302
             END IF;

            EXIT WHEN cur_price_cle%NOTFOUND;
            i := i + 1;
        END LOOP;
        CLOSE cur_price_cle;

        -- delete last blank row
        l_cle_price_tbl.DELETE(i);

        -- Fetch Top Model Id for pricing
        OPEN  cur_get_model_id ( p_au_line_rec.dnz_chr_id,
                                 p_config_rec.config_hdr_id,
                                 p_config_rec.config_rev_nbr);
        FETCH cur_get_model_id INTO l_top_model_id,
                                    l_top_model_line_id;
        CLOSE cur_get_model_id;

        IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('5630: Top Model Id for pricing : '||l_top_model_id);
              OKC_DEBUG.log('5635: Total Input Price rows : '||l_cle_price_tbl.count);
        END IF;

     -- ------------------------------------------------------------
     -- STEP.5.2:
     -- Pricing Control Record init values:
     -- ------------------------------------------------------------
        l_control_rec.p_top_model_id               := l_top_model_id;
        l_control_rec.p_config_yn                  :='S';
        l_control_rec.qp_control_rec.pricing_event :='BATCH';

        IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('5640: Pr Ctl.Top-Model :'||l_control_rec.p_top_model_id);
              OKC_DEBUG.log('5641: Pr Ctl.Config YN :'||l_control_rec.p_config_yn);
              OKC_DEBUG.log('5642: Pr Ctl.Pr Event  :'||'BATCH');
        END IF;

     -- --------------------------------------------------------------
     -- STEP.5.3:
     -- OKC Specific Pricing call to calculate list or sell price.
     -- --------------------------------------------------------------
        IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('5650: Before Calculate Price call...');
        END IF;

        OKC_PRICE_PVT.CALCULATE_PRICE(
               p_api_version                 => 1,
               p_init_msg_list               => OKC_API.G_FALSE,
               p_chr_id                      => l_chr_id,
               p_Control_Rec                 => l_control_rec,
               px_req_line_tbl               => l_req_line_tbl,
               px_Req_qual_tbl               => l_req_line_qual_tbl,
               px_Req_line_attr_tbl          => l_req_line_attr_tbl,
               px_Req_LINE_DETAIL_tbl        => l_req_line_detail_tbl,
               px_Req_LINE_DETAIL_qual_tbl   => l_req_line_detail_qual_tbl,
               px_Req_LINE_DETAIL_attr_tbl   => l_req_line_detail_attr_tbl,
               px_Req_RELATED_LINE_TBL       => l_req_related_line_tbl,
               px_CLE_PRICE_TBL              => l_cle_price_tbl,
               x_return_status               => x_return_status,
               x_msg_count                   => x_msg_count,
               x_msg_data                    => x_msg_data);

        IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('5655: Exiting Calculate Price... '||x_return_status);
        END IF;

             -- DEBUG: Print messages from stack
             IF NVL(x_msg_count,0) > 0
             THEN
                FOR i IN 1..x_msg_count
                LOOP
                   x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                                 p_encoded   => 'F');
                   IF (l_debug = 'Y') THEN
                         OKC_DEBUG.log('5660: x_msg_data '||x_msg_data);
                   END IF;
                END LOOP;   -- end of message count loop
             END IF;

        -- Check Return Status
        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
        THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;    -- end of ret status validation

 l_tot_negotiated := 0;
 l_tot_list_price := 0;
 IF l_cle_price_tbl.count > 0
 THEN
   FOR i in l_cle_price_tbl.FIRST..l_cle_price_tbl.LAST
   LOOP
     -- Dump all priced config lines in debug mode
     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5671: <--- OUTPUT LINE - '||(to_number(i))||' ------->');
           OKC_DEBUG.log('5672: List Price : '||l_CLE_PRICE_TBL(i).list_price);
           OKC_DEBUG.log('5673: Nego Price : '||l_CLE_PRICE_TBL(i).negotiated_amt);
           OKC_DEBUG.log('5674: Pr List Id : '||l_CLE_PRICE_TBL(i).pricelist_id);
           OKC_DEBUG.log('5675: Line Id    : '||l_CLE_PRICE_TBL(i).id);
           OKC_DEBUG.log('5676: Pi Bpi     : '||l_CLE_PRICE_TBL(i).pi_bpi);
           OKC_DEBUG.log('5677: Quantity   : '||l_CLE_PRICE_TBL(i).qty);
           OKC_DEBUG.log('5678: Uom Code   : '||l_CLE_PRICE_TBL(i).uom_code);
           OKC_DEBUG.log('5679: Currency   : '||l_CLE_PRICE_TBL(i).currency);
           OKC_DEBUG.log('5680: Obj Code   : '||l_CLE_PRICE_TBL(i).object_code);
           OKC_DEBUG.log('5681: Obj Id1    : '||l_CLE_PRICE_TBL(i).id1);
           OKC_DEBUG.log('5682: Obj Id2    : '||l_CLE_PRICE_TBL(i).id2);
           OKC_DEBUG.log('5690: <------------------------------------------------>');
     END IF;

     -- --------------------------------------------------------------
     -- Calculate the rollup price to be shown for top model line.
     -- --------------------------------------------------------------
     l_tot_negotiated := l_tot_negotiated + l_cle_price_tbl(i).negotiated_amt;
     l_tot_list_price := l_tot_list_price + l_cle_price_tbl(i).list_price;

     -- Initialize clev record for further process.
     l_clev_rec := l_clev_rec_init;

     OPEN  cur_line_info (l_CLE_PRICE_TBL(i).id);
     FETCH cur_line_info INTO l_cur_cle_id,
                              l_cur_chr_id,
                              l_cur_line_nbr,     --> Used to sync-up disp seq.
                              l_display_sequence; --> Not used in this loop.
     CLOSE cur_line_info;

     l_clev_rec.id                     := l_CLE_PRICE_TBL(i).id;
     l_clev_rec.chr_id                 := l_cur_chr_id;
     l_clev_rec.cle_id                 := l_cur_cle_id;
     l_clev_rec.display_sequence       := l_cur_line_nbr;  -- sync up with line
     l_clev_rec.line_list_price        := l_CLE_PRICE_TBL(i).list_price;
     l_clev_rec.price_unit             := l_CLE_PRICE_TBL(i).unit_price;
     l_clev_rec.price_negotiated       := l_CLE_PRICE_TBL(i).negotiated_amt;
     l_clev_rec.price_list_id          := l_CLE_PRICE_TBL(i).pricelist_id;
     l_clev_rec.pricing_date           := l_CLE_PRICE_TBL(i).pricing_date;
     l_clev_rec.price_list_line_id     := l_CLE_PRICE_TBL(i).list_line_id;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5700: Before Update Pricing Info ....');
     END IF;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5710: Priced Line Id  : '||l_clev_rec.id);
           OKC_DEBUG.log('5711: Cle Id          : '||l_clev_rec.cle_id);
           OKC_DEBUG.log('5712: Chr Id          : '||l_clev_rec.chr_id);
           OKC_DEBUG.log('5720: List Price      : '||l_clev_rec.line_list_price);
           OKC_DEBUG.log('5730: Unit Price      : '||l_clev_rec.price_unit);
           OKC_DEBUG.log('5740: Negotiated Price: '||l_clev_rec.price_negotiated);
           OKC_DEBUG.log('5750: Price List Id   : '||l_clev_rec.price_list_id);
           OKC_DEBUG.log('5760: Pricing Date    : '||l_clev_rec.pricing_date);
           OKC_DEBUG.log('5780: Pr List Line Id : '||l_clev_rec.price_list_line_id);
           OKC_DEBUG.log('5785: Config Item Type: '||l_clev_rec.config_item_type);
     END IF;

     OKC_CONTRACT_PUB.update_contract_line
                    ( p_api_version     => l_api_version_number,
                      p_init_msg_list   => l_init_msg_list,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      x_return_status   => x_return_status,
                      p_clev_rec        => l_clev_rec,
                      x_clev_rec        => x_clev_rec);

      IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('5800: Updated Pricing Info...'||x_return_status);
      END IF;

      IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('5810: Priced Line Id  : '||x_clev_rec.id);
            OKC_DEBUG.log('5811: Cle Id          : '||x_clev_rec.cle_id);
            OKC_DEBUG.log('5812: Chr Id          : '||x_clev_rec.chr_id);
            OKC_DEBUG.log('5820: List Price      : '||x_clev_rec.line_list_price);
            OKC_DEBUG.log('5830: Unit Price      : '||x_clev_rec.price_unit);
            OKC_DEBUG.log('5840: Negotiated Price: '||x_clev_rec.price_negotiated);
            OKC_DEBUG.log('5850: Price List Id   : '||x_clev_rec.price_list_id);
            OKC_DEBUG.log('5860: Pricing Date    : '||x_clev_rec.pricing_date);
            OKC_DEBUG.log('5880: Pr List Line Id : '||x_clev_rec.price_list_line_id);
            OKC_DEBUG.log('5885: Config Item Type: '||x_clev_rec.config_item_type);
      END IF;

      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- DEBUG: Print messages from stack
      IF NVL(x_msg_count,0) > 0
      THEN
          FOR i IN 1..x_msg_count
          LOOP
             x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                           p_encoded   => 'F');
             IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('5890: x_msg_data '||x_msg_data);
             END IF;
          END LOOP;   -- end of message count loop
      END IF;

      -- Check Return Status
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
      THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
      THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;   -- return status

   END LOOP;    -- l_cle_price_table rows
END IF;

     -- --------------------------------------------------------------
     -- Update the rollup price to be shown for top model line.
     -- --------------------------------------------------------------
     -- Initialize clev record for further process.
     l_clev_rec := l_clev_rec_init;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5898: Total List Price : '||l_tot_list_price);
           OKC_DEBUG.log('5899: Total Price      : '||l_tot_negotiated);
           OKC_DEBUG.log('5900: Top Model Line   : '||l_top_model_line_id);
     END IF;

     OPEN  cur_line_info (l_top_model_line_id);
     FETCH cur_line_info INTO l_cur_cle_id,
                              l_cur_chr_id,
                              l_cur_line_nbr,     --> not used in this loop.
                              l_display_sequence; --> gets user entered value.
     CLOSE cur_line_info;

     l_clev_rec.id                       := l_top_model_line_id;
     l_clev_rec.chr_id                   := l_cur_chr_id;
     l_clev_rec.cle_id                   := l_cur_cle_id;
     l_clev_rec.display_sequence         := l_display_sequence; -- User value
     l_clev_rec.price_unit               := NULL;              -- Top Model Line
     l_clev_rec.line_list_price          := l_tot_list_price;  -- Rollup Value
     l_clev_rec.price_negotiated         := l_tot_negotiated;  -- Rollup Value
     l_clev_rec.price_list_id            := l_CLE_PRICE_TBL(1).pricelist_id;
     l_clev_rec.pricing_date             := l_CLE_PRICE_TBL(1).pricing_date;
     l_clev_rec.price_list_line_id       := l_CLE_PRICE_TBL(1).list_line_id;
     l_clev_rec.config_top_model_line_id := l_top_model_line_id;
     l_clev_rec.config_complete_yn       := p_config_complete_yn;
     l_clev_rec.config_valid_yn          := p_config_valid_yn;
     l_clev_rec.item_to_price_yn         := 'Y';

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5910: Before Update Top Model Pricing Info ....');
     END IF;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5911: Priced Line Id  : '||l_clev_rec.id);
           OKC_DEBUG.log('5912: Chr Id          : '||l_clev_rec.chr_id);
           OKC_DEBUG.log('5913: Cle Id          : '||l_clev_rec.cle_id);
           OKC_DEBUG.log('5914: List Price      : '||l_clev_rec.line_list_price);
           OKC_DEBUG.log('5915: Unit Price      : '||l_clev_rec.price_unit);
           OKC_DEBUG.log('5916: Negotiated Price: '||l_clev_rec.price_negotiated);
           OKC_DEBUG.log('5917: Price List Id   : '||l_clev_rec.price_list_id);
           OKC_DEBUG.log('5918: Pricing Date    : '||l_clev_rec.pricing_date);
           OKC_DEBUG.log('5919: Pr List Line Id : '||l_clev_rec.price_list_line_id);
     END IF;

     OKC_CONTRACT_PUB.update_contract_line
                    ( p_api_version     => l_api_version_number,
                      p_init_msg_list   => l_init_msg_list,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      x_return_status   => x_return_status,
                      p_clev_rec        => l_clev_rec,
                      x_clev_rec        => x_clev_rec);

      IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('5920: Updated Top Model Pricing Info...'||x_return_status);
      END IF;

      IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('5921: Priced Line Id  : '||x_clev_rec.id);
            OKC_DEBUG.log('5922: Display Sequence: '||x_clev_rec.display_sequence);
            OKC_DEBUG.log('5923: Chr Id          : '||l_clev_rec.chr_id);
            OKC_DEBUG.log('5924: List Price      : '||x_clev_rec.line_list_price);
            OKC_DEBUG.log('5925: Unit Price      : '||x_clev_rec.price_unit);
            OKC_DEBUG.log('5926: Negotiated Price: '||x_clev_rec.price_negotiated);
            OKC_DEBUG.log('5927: Price List Id   : '||x_clev_rec.price_list_id);
            OKC_DEBUG.log('5928: Pricing Date    : '||x_clev_rec.pricing_date);
            OKC_DEBUG.log('5929: Pr List Line Id : '||x_clev_rec.price_list_line_id);
            OKC_DEBUG.log('5930: Cle Id          : '||x_clev_rec.cle_id);
            OKC_DEBUG.log('5931: Config Item Type: '||x_clev_rec.config_item_type);
      END IF;

      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- DEBUG: Print messages from stack
      IF NVL(x_msg_count,0) > 0
      THEN
          FOR i IN 1..x_msg_count
          LOOP
             x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                           p_encoded   => 'F');
             IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('5990: x_msg_data '||x_msg_data);
             END IF;
          END LOOP;   -- end of message count loop
      END IF;

      -- Check Return Status
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
      THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
      THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;   -- return status

   -- ----------------------------------------------------------
   -- Populate the Configured model final rollup totals
   -- to be displayed in the Net-Price column on the Authoring
   -- form header level information. This value will get added
   -- to the value existing before the configurator call.
   -- This is done by the update-price-line for regular lines.
   -- ----------------------------------------------------------
      x_cfg_list_price  := l_tot_list_price;
      x_cfg_net_price   := l_tot_negotiated;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('5990: Exiting Pricing Section ...', 2);
     END IF;
  -- -------------------------------------------------------------------

    -- end activity
    OKC_API.END_ACTIVITY(     x_msg_count         => x_msg_count,
                              x_msg_data          => x_msg_data);

 IF (l_debug = 'Y') THEN
       OKC_DEBUG.log('5999: Exiting build_cle_from_cz...', 2);
       OKC_DEBUG.Reset_Indentation;
 END IF;

EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
          IF (l_debug = 'Y') THEN
                OKC_DEBUG.log('5999:Exception Error in Build Cle...', 2);
                OKC_DEBUG.Reset_Indentation;
          END IF;

          IF cur_cle_ins%ISOPEN
          THEN
            CLOSE cur_cle_ins;
          END IF;

          x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => G_API_TYPE);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          IF (l_debug = 'Y') THEN
                OKC_DEBUG.log('5999:Unexpected Error in Build Cle...', 2);
                OKC_DEBUG.Reset_Indentation;
          END IF;

          IF cur_cle_ins%ISOPEN
          THEN
            CLOSE cur_cle_ins;
          END IF;

          x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => G_API_TYPE);
     WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('5999:Other Exception in Build Cle...', 2);
              OKC_DEBUG.Reset_Indentation;
        END IF;

        IF cur_cle_ins%ISOPEN
        THEN
           CLOSE cur_cle_ins;
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OTHERS',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => G_API_TYPE);
END build_cle_from_cz;

-- ---------------------------------------------------------------------------
-- PROCEDURE     : config_qa_check
-- PURPOSE       : To call from QA check on a contract.
--                 to check whether the contract configuration
--                 is compelte and also valid.
-- INPUT         : Contract Header Id.
-- OUTPUT        : Contract Valid Y/N flag.
-- DEBUG         : 6000 Series
-- ---------------------------------------------------------------------------
PROCEDURE config_qa_check ( p_chr_id         IN         NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2 )
IS
l_line_id        NUMBER;
l_count          NUMBER;
l_msg_token      VARCHAR2(300);
l_line_index     VARCHAR2(200);
l_return_status  VARCHAR2(1);

l_app_id         OKC_K_HEADERS_B.application_id%TYPE;
l_buy_or_sell    OKC_K_HEADERS_B.buy_or_sell%TYPE;
l_valid          OKC_K_LINES_B.config_valid_yn%TYPE;
l_complete       OKC_K_LINES_B.config_complete_yn%TYPE;

-- -----------------------------------------------------
-- Get application Ids to activate config qa check.
-- -----------------------------------------------------
CURSOR get_k_app_id
IS
SELECT application_id,
       buy_or_sell
FROM   okc_k_headers_b
WHERE  id = p_chr_id;

-- -----------------------------------------------------
-- Get configured models count from the contract.
-- dnz_chr_id is used, as the config can be in subline.
-- The null values for the flags are interpreted as Y
-- As for the regular contract lines have NULL value
-- for both config_valid_yn and config_complete_yn.
-- -----------------------------------------------------
CURSOR get_cfg_count
IS
SELECT count(clev.id)
FROM   okc_k_lines_b clev
WHERE  clev.dnz_chr_id       = p_chr_id
AND    clev.config_item_type = 'TOP_MODEL_LINE'
AND (  NVL(clev.config_valid_yn,'Y') = 'N'
    OR NVL(clev.config_complete_yn,'Y') = 'N');

-- -----------------------------------------------------
-- Get configured top model lines from the contract.
-- dnz_chr_id is used, as the config can be in subline.
-- The null values for the flags are interpreted as Y
-- As for the regular contract lines have NULL value
-- -----------------------------------------------------
CURSOR get_cfg_line_info
IS
SELECT clev.id,
       clev.config_valid_yn,
       clev.config_complete_yn
FROM   okc_k_lines_b clev
WHERE  clev.dnz_chr_id       = p_chr_id
AND    clev.config_item_type = 'TOP_MODEL_LINE'
AND (  NVL(clev.config_valid_yn,'Y') = 'N'
    OR NVL(clev.config_complete_yn,'Y') = 'N');

BEGIN
  -- ----------------------------------------------------
  -- Call from QA check, to flag the contract as invalid,
  -- with error status, for the following conditions.
  -- config_compelte_yn = N (or) config_valid_yn = N
  -- ----------------------------------------------------

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.set_indentation('Config_qa_check');
           OKC_DEBUG.log('6000: Entering configuration_qa_check...', 2);
     END IF;

     -- initialize return status.
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- ----------------------------------------------------
  -- Config Validation is to be done only for OKC and OKO.
  -- ----------------------------------------------------
     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('6010: Getting Application Id: ');
     END IF;

     OPEN  get_k_app_id;
     FETCH get_k_app_id INTO l_app_id, l_buy_or_sell;
     CLOSE get_k_app_id;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('6020: Application Id : '||TO_CHAR(l_app_id));
     END IF;
     IF (l_app_id NOT IN (510, 871) OR
         l_buy_or_sell = 'B')
     THEN
         -- No need to set the return status here
         RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

  -- ------------------------------------------------------
  -- Get the invalid or incomplete configured models count.
  -- ------------------------------------------------------
     OPEN  get_cfg_count;
     FETCH get_cfg_count INTO l_count;
     CLOSE get_cfg_count;

  IF (l_count > 0)
  THEN
     -- Process the QA error rows further
     OPEN  get_cfg_line_info;
     LOOP
         FETCH get_cfg_line_info INTO l_line_id,
                                      l_valid,
                                      l_complete;

         EXIT WHEN get_cfg_line_info%NOTFOUND;

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('6030: Line Id            : '||l_line_id);
               OKC_DEBUG.log('6040: Config Valid YN    : '||l_valid);
               OKC_DEBUG.log('6050: Config Complete YN : '||l_complete);
         END IF;

         -- initialize the msg variable
         l_msg_token := NULL;

         -- Prepare the message token string
         l_line_index := OKC_CONTRACT_PUB.get_concat_line_no
                                         (l_line_id,
                                          l_return_status);

         IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
         THEN
             l_line_index := 'Unknown';
         END IF;

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('6060: Line Index  : '||l_line_index);
         END IF;

         -- prefix the config string with above line index value.
         l_msg_token := RTRIM(l_line_index);

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('6070: QA Msg Token: '||l_msg_token);
         END IF;

      -- ----------------------------------------------------------
      -- To prepare message string with appropriate error text.
      -- Handle NN,NY,YN,YY conditions for the two flags.
      -- The case of YY does not come into this loop at all.
      -- This string gets sufixed to the line-index of the token.
      -- ----------------------------------------------------------
         IF ( NVL(l_valid,'Y')    = 'N' ) AND
            ( NVL(l_complete,'Y') = 'N' )
         THEN
             -- Flag this configured model as invalid and incomplete
             IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('6080: Config Invalid and Incomplete');
             END IF;
             OKC_API.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKC_CONFIG_INV_INC',
                     p_token1       => 'CFG_INFO',
                     p_token1_value => l_msg_token);
         ELSIF ( NVL(l_valid,'Y')    = 'N' ) AND
               ( NVL(l_complete,'Y') = 'Y' )
         THEN
             -- Flag this configured model as invalid
             IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('6090: Config Invalid ');
             END IF;
             OKC_API.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKC_CONFIG_INVALID',
                     p_token1       => 'CFG_INFO',
                     p_token1_value => l_msg_token);
         ELSIF ( NVL(l_complete,'Y') = 'N' )
         THEN
             -- Flag this configured model as incomplete
             IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('6100: Config Incomplete ');
             END IF;
             OKC_API.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKC_CONFIG_INCOMPLETE',
                     p_token1       => 'CFG_INFO',
                     p_token1_value => l_msg_token);
         END IF;
     END LOOP;
     CLOSE get_cfg_line_info;

     -- Set the error return status
     x_return_status := OKC_API.G_RET_STS_ERROR;
     RAISE G_EXCEPTION_HALT_VALIDATION;

  ELSE
     -- This is a normal and valid contract.
     -- notify caller of qa success
     OKC_API.set_message(
             p_app_name => G_APP_NAME,
             p_msg_name => G_QA_SUCCESS);
  END IF;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('6200: Config QA Ret Status : '||x_return_status);
           OKC_DEBUG.log('6300: Exiting config_qa_check...', 2);
           OKC_DEBUG.reset_indentation;
     END IF;

EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
          IF (l_debug = 'Y') THEN
                OKC_DEBUG.log('6400: Exiting Config_qa_check', 2);
                OKC_DEBUG.Reset_Indentation;
          END IF;

     WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
                OKC_DEBUG.log('6500: Exiting Config_qa_check', 2);
                OKC_DEBUG.Reset_Indentation;
          END IF;

          -- notify caller of an error as UNEXPETED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

          OKC_API.set_message(
                  p_app_name        => G_APP_NAME,
                  p_msg_name        => G_UNEXPECTED_ERROR,
                  p_token1          => G_SQLCODE_TOKEN,
                  p_token1_value    => SQLCODE,
                  p_token2          => G_SQLERRM_TOKEN,
                  p_token2_value    => SQLERRM);

END config_qa_check;

-- ---------------------------------------------------------------------------
-- PROCEDURE     : okc_pricing_callback
-- PURPOSE       : To calculate LIST or SELL price of the config
--                 items. Callback from the Configurator window.
--                 The price details are for display only.
--                 Configurator is called from the authoring form
--                    OKCAUDET.fmx
--                      -> OKCAUPRC.fmx
--                          -> OKCAUCFG.plx
--                               -> Oracle Configurator Window
--                                    -> Pricing_Callback
-- DEBUG         : 7000 Series
--
-- ------------------------------------------------------------------
-- Pricing Callback scenarios for the Configured Lines:
-- ------------------------------------------------------------------
-- Oracle Configurator makes the Pricing callback calls using
-- our code in OKC_CFG_PUB.okc_pricing_callback. This happens in
-- two cases. Once the CZ calls for only list_price of all model bom.
-- Secondly, when the user preses the Price button. Cases 2,3 mentioned
-- below will have the provision to just call or call and save values.
--
-- 1.  List price only
--     p_control_rec.qp_control_rec.priceing_event='PRICE'
--     p_control_rec.p_config_yn='Y'
--     p_control_rec.p_top_model_id = my_top_model_line_id;
--     px_cle_price_tbl contains all config lines.
--                      uom, currency, pricelist
--                      Search flag = Yes for event 'List price',
--                      object1_id1(inventory item_id),
--                      quantity,
--                      ID- this could be a unique sequence number
--
-- 2.  Adjusted price but do not save adjustment data in
--     database same as above except the following :
--     p_control_rec.qp_control_rec.priceing_event='BATCH
--
-- 3.  Adjusted price and save price adjustment data in database
--     same as 2. except the following
--                      ID - this should be some valid cle_id.
--                      p_control_rec.p_config_yn='S'
--
-- OUTCOME:    You will get back all the request data sent out by the
--             price request. Also the sent in table px_cle_price_tbl
--             will have the various prices and the return status.
-- ---------------------------------------------------------------------------
PROCEDURE okc_pricing_callback( p_config_session_key IN  VARCHAR2,
                                p_price_type         IN  VARCHAR2,
                                x_total_price        OUT NOCOPY NUMBER )
IS
CURSOR  cur_cz_pricing_structures
IS
SELECT  TO_NUMBER(SUBSTR(p_config_session_key,1,
                  INSTR( p_config_session_key, '-' ) - 1 ))      id,
        CZ_ATP_CALLBACK_UTIL.inv_item_id_from_item_key(item_key) item_id,
        quantity                                                 quantity,
        uom_code                                                 uom_code,
        SUBSTR(item_key, 1,INSTR( item_key, ':' ,1)-1)           comp_code
FROM    okx_config_pricing_v
WHERE   configurator_session_key = p_config_session_key
AND     list_price    IS NULL
AND     selling_price IS NULL;

CURSOR  cur_line_details (p_top_model_line_id NUMBER)
IS
SELECT  dnz_chr_id,
        price_list_id
FROM    okc_k_lines_b
WHERE   id = p_top_model_line_id;

CURSOR  cur_get_hdr_det (p_chr_id NUMBER)
IS
SELECT  currency_code,
        authoring_org_id,
        price_list_id          -- If user already selects one
FROM    okc_k_headers_v
WHERE   id = p_chr_id;

l_control_rec                   OKC_PRICE_PVT.okc_control_rec_type;
l_CLE_PRICE_TBL                 OKC_PRICE_PVT.cle_price_tbl_type;
l_line_tbl                      OKC_PRICE_PVT.line_tbl_type;
l_req_line_tbl                  QP_PREQ_GRP.line_tbl_type;
l_req_line_qual_tbl             QP_PREQ_GRP.qual_tbl_type;
l_req_line_attr_tbl             QP_PREQ_GRP.line_attr_tbl_type;
l_req_line_detail_tbl           QP_PREQ_GRP.line_detail_tbl_type;
l_req_line_detail_qual_tbl      QP_PREQ_GRP.line_detail_qual_tbl_type;
l_req_line_detail_attr_tbl      QP_PREQ_GRP.line_detail_attr_tbl_type;
l_req_related_line_tbl          QP_PREQ_GRP.related_lines_tbl_type;
l_pricing_contexts_tbl          QP_PREQ_GRP.line_attr_tbl_type;
l_qual_contexts_tbl             QP_PREQ_GRP.qual_tbl_type;
i                               NUMBER  := 1;
l_chr_id                        NUMBER  := 0;
l_currency                      VARCHAR2(15);
l_org_id                        NUMBER;
l_price_list_id                 NUMBER;
l_hdr_price_list_id             NUMBER;
l_top_model_line_id             NUMBER;
l_item_id                       NUMBER;
l_quantity                      NUMBER;
l_uom_code                      VARCHAR2(3);
l_comp_code                     VARCHAR2(1200);
x_return_status                 VARCHAR2(1);
x_msg_count                     NUMBER;
x_msg_data                      VARCHAR2(240);
l_total_price                   NUMBER := 0;
l_api_name                      CONSTANT VARCHAR2(30) := 'okc_pricing_callback';
l_calc_price_error              VARCHAR2(2000);
l_unit_sell_price               NUMBER;
BEGIN

  -- --------------------------------------------------------------------------
  -- Set the profile values for logging
  -- different sessions debug messages.
  -- --------------------------------------------------------------------------
     IF (l_debug = 'Y') THEN
        OKC_DEBUG.g_session_id := SYS_CONTEXT('USERENV','SESSIONID');
     END IF;
     FND_PROFILE.PUT('AFLOG_ENABLED','Y');             -- Enable the log
     FND_PROFILE.PUT('AFLOG_LEVEL',1);                 -- Set the debug level
     FND_PROFILE.PUT('AFLOG_MODULE','OKC');            -- Set the module name

  -- --------------------------------------------------------------------------
  -- Pricing callback from the Oracle Configurator occurs from a new session
  -- in which configurator applet window operates. This is a non-apps mode.
  -- In the Non-apps mode the value of g_profile_log_level in the okc_debug API
  -- is set to 0. However in the subsequent call to the Fnd_Log.test procedure
  -- the value of G_CURRENT_RUNTIME_LEVEL is used.Hence need to set its value
  -- to 1 by executing the fnd_log_repository.init procedure call.
  -- --------------------------------------------------------------------------
  -- Initialize the current runtime level
     FND_LOG_REPOSITORY.init(OKC_DEBUG.g_session_id,fnd_global.user_id);

     l_debug := 'Y';

        IF (l_debug = 'Y') THEN
           OKC_DEBUG.set_indentation(l_api_name);
           OKC_DEBUG.log('7000: Entered okc_pricing_callback...', 2);
           OKC_DEBUG.log('7001: Config Session Key : '||p_config_session_key);
           OKC_DEBUG.log('7002: Pricing Type       : '||p_price_type);
        END IF;

     -- ----------------------------------------------------------
     -- Prepare the cz temporary table rows for pricing
     -- ----------------------------------------------------------
     OPEN  cur_cz_pricing_structures;
     LOOP
        FETCH cur_cz_pricing_structures
              INTO  l_top_model_line_id,
                    l_item_id,
                    l_quantity,
                    l_uom_code,
                    l_comp_code;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('7010: Top Model Line Id : '||l_top_model_line_id);
           OKC_DEBUG.log('7011: Inventory Item Id : '||l_item_id);
           OKC_DEBUG.log('7012: Quantity          : '||l_quantity);
           OKC_DEBUG.log('7013: UOM Code          : '||l_uom_code);
           OKC_DEBUG.log('7014: Component Code    : '||l_comp_code);
     END IF;

     -- ----------------------------------------------------------
     -- Get corresponding Contract Header Id from top model line.
     -- ----------------------------------------------------------
        OPEN  cur_line_details (l_top_model_line_id);
        FETCH cur_line_details INTO l_chr_id,l_price_list_id;
        CLOSE cur_line_details;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('7015: Contract Hdr Id    : '||l_chr_id);
           OKC_DEBUG.log('7016: Line Price List Id : '||l_price_list_id);
     END IF;

     -- ----------------------------------------------------------
     -- Get corresponding Contract Header details from header row.
     -- ----------------------------------------------------------
        OPEN  cur_get_hdr_det (l_chr_id);
        FETCH cur_get_hdr_det
              INTO  l_currency,
                    l_org_id,
                    l_hdr_price_list_id;
        CLOSE cur_get_hdr_det;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('7020: Currency          : '||l_currency);
           OKC_DEBUG.log('7021: Auth Org Id       : '||l_org_id);
           OKC_DEBUG.log('7022: Hdr Price List Id : '||l_hdr_price_list_id);
     END IF;

     -- -------------------------------------------------------------
     -- If line level pricelist is null, pick header level price list
     -- -------------------------------------------------------------
        l_price_list_id := NVL(l_price_list_id,l_hdr_price_list_id);

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('7023: Final Price List Id : '||l_price_list_id);
     END IF;

     -- ----------------------------------------------------------
     -- Prepare init values for the pricing call
     -- ----------------------------------------------------------
        l_cle_price_tbl(i).id           := i;               -- sequence number
        l_cle_price_tbl(i).qty          := l_quantity;
        l_cle_price_tbl(i).uom_code     := l_uom_code;
        l_cle_price_tbl(i).currency     := l_currency;
        l_cle_price_tbl(i).id1          := l_item_id;
        l_cle_price_tbl(i).id2          := l_org_id;
        l_cle_price_tbl(i).pricelist_id := l_price_list_id;

        EXIT WHEN cur_cz_pricing_structures%NOTFOUND;
        i := i + 1;
   END LOOP;
   CLOSE cur_cz_pricing_structures;

   -- delete last blank row
   l_cle_price_tbl.DELETE(i);

   IF (l_debug = 'Y') THEN
         OKC_DEBUG.log('7050: Total input Pr-Cb rows : '||l_cle_price_tbl.count);
   END IF;

   -- ---------------------------------------------------------------------
   -- Pricing Call init values:
   -- ---------------------------------------------------------------------
     l_control_rec.p_top_model_id               := l_top_model_line_id;
     l_control_rec.p_config_yn                  := 'Y';
     l_control_rec.qp_control_rec.pricing_event := 'PRICE';    -- For ListPrice

     -- --------------------------------------------------------------
     -- STEP:1
     -- OKC Specific Pricing call to calculate list or sell price.
     -- --------------------------------------------------------------
     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('7700: Before Calculate Price call...');
     END IF;

     OKC_PRICE_PVT.CALCULATE_PRICE(
               p_api_version                 => 1,
               p_init_msg_list               => OKC_API.G_FALSE,
               p_chr_id                      => l_chr_id,
               p_Control_Rec                 => l_control_rec,
               px_req_line_tbl               => l_req_line_tbl,
               px_Req_qual_tbl               => l_req_line_qual_tbl,
               px_Req_line_attr_tbl          => l_req_line_attr_tbl,
               px_Req_LINE_DETAIL_tbl        => l_req_line_detail_tbl,
               px_Req_LINE_DETAIL_qual_tbl   => l_req_line_detail_qual_tbl,
               px_Req_LINE_DETAIL_attr_tbl   => l_req_line_detail_attr_tbl,
               px_Req_RELATED_LINE_TBL       => l_req_related_line_tbl,
               px_CLE_PRICE_TBL              => l_cle_price_tbl,
               x_return_status               => x_return_status,
               x_msg_count                   => x_msg_count,
               x_msg_data                    => x_msg_data);

        IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('7750: Exiting Calculate Price... '||x_return_status);
        END IF;
        l_calc_price_error := 'Error in Calculate Price..';

        -- DEBUG: Print messages from stack
        IF NVL(x_msg_count,0) > 0
        THEN
           FOR i IN 1..x_msg_count
           LOOP
              x_msg_data := FND_MSG_PUB.Get(p_msg_index => i,
                                            p_encoded   => 'F');
              IF (l_debug = 'Y') THEN
                    OKC_DEBUG.log('7755: x_msg_data '||x_msg_data);
              END IF;
                 -- Limit size for Error message to Configurator
                 IF LENGTH(l_calc_price_error||x_msg_data) < 2000
                 THEN
                     l_calc_price_error := l_calc_price_error ||
                                           ', '||x_msg_data;
                 END IF;
           END LOOP;   -- end of message count loop
        END IF;

        -- Check Return Status
        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR
        THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;    -- end of ret status validation

 l_total_price := 0;
 IF l_cle_price_tbl.count > 0
 THEN
   FOR i in l_cle_price_tbl.FIRST..l_cle_price_tbl.LAST
   LOOP
     -- Dump all priced config lines in debug mode
     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('7810: <--- OUTPUT LINE - '||(to_number(i)+1)||' ------->');
           OKC_DEBUG.log('7811: List Price : '||l_CLE_PRICE_TBL(i).list_price);
           OKC_DEBUG.log('7812: Nego Price : '||l_CLE_PRICE_TBL(i).negotiated_amt);
           OKC_DEBUG.log('7813: Pr List Id : '||l_CLE_PRICE_TBL(i).pricelist_id);
           OKC_DEBUG.log('7814: Line Id    : '||l_CLE_PRICE_TBL(i).id);
           OKC_DEBUG.log('7815: Pi Bpi     : '||l_CLE_PRICE_TBL(i).pi_bpi);
           OKC_DEBUG.log('7816: Quantity   : '||l_CLE_PRICE_TBL(i).qty);
           OKC_DEBUG.log('7817: Uom Code   : '||l_CLE_PRICE_TBL(i).uom_code);
           OKC_DEBUG.log('7818: Currency   : '||l_CLE_PRICE_TBL(i).currency);
           OKC_DEBUG.log('7819: Obj Code   : '||l_CLE_PRICE_TBL(i).object_code);
           OKC_DEBUG.log('7820: Obj Id1    : '||l_CLE_PRICE_TBL(i).id1);
           OKC_DEBUG.log('7821: Obj Id2    : '||l_CLE_PRICE_TBL(i).id2);
     END IF;

     -- --------------------------------------------------------------
     -- Calculate the rollup price to be shown for top model line.
     -- --------------------------------------------------------------
     l_total_price := l_total_price + l_cle_price_tbl(i).negotiated_amt;

     -- --------------------------------------------------------------
     -- Calculate the unit sell price. The Configurator window
     -- has two columns, one for Sell Price and other Extended Price.
     -- Configurator multiplies sell price with quantity to get
     -- Extended price. Our Pricing API call returns sell price
     -- multiplied by quantity in the column negotiated_amt value.
     -- --------------------------------------------------------------
     IF l_cle_price_tbl(i).qty > 0
     THEN
         l_unit_sell_price := ( l_cle_price_tbl(i).negotiated_amt /
                                l_cle_price_tbl(i).qty);
     ELSE
         l_unit_sell_price := NVL(l_cle_price_tbl(i).negotiated_amt,0);
     END IF;

     -- --------------------------------------------------------------
     -- Update the CZ temporary table with the pricing info.
     -- --------------------------------------------------------------
     UPDATE cz_pricing_structures
     SET    selling_price            =  l_unit_sell_price,
            list_price               =  l_cle_price_tbl(i).list_price
     WHERE  configurator_session_key =  p_config_session_key
     AND    CZ_ATP_CALLBACK_UTIL.inv_item_id_from_item_key(item_key) =
                                        l_cle_price_tbl(i).id1 ;
   END LOOP;   -- l_cle_price_tbl rows
 END IF;

     -- ----------------------------------------------------------
     -- The total price should reflect the quantity change in the
     -- configurator window. The sum sellprice will only produce
     -- the sum of unit-sell-prices of all the items configured.
     -- The following line replaces the select statement below it.
     -- ---------------------------------------------------------
        x_total_price := l_total_price;

     --  BEGIN
     --    SELECT  SUM( selling_price )
     --    INTO    x_total_price
     --    FROM   okx_config_pricing_v
     --    WHERE  configurator_session_key = p_config_session_key ;
     --  EXCEPTION
     --    WHEN OTHERS THEN
     --         RAISE OKC_API.G_EXCEPTION_ERROR;
     --  END;
     -- -------------------------------------------------------------

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.log('7900: Total Sell Price   : '||x_total_price);
           OKC_DEBUG.log('7999: Leaving okc_pricing_callback...', 2);
     END IF;

     IF (l_debug = 'Y') THEN
           OKC_DEBUG.Reset_Indentation;
     END IF;

EXCEPTION
     WHEN OTHERS THEN

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('7995: Sending Pricing Callback Error Message to Configurator...');
               OKC_DEBUG.log('7996: Error Message:  '||l_calc_price_error);
         END IF;

         -- Set the error message
         UPDATE okx_config_pricing_v
         SET    msg_data   =  l_calc_price_error
         WHERE  configurator_session_key = p_config_session_key;

         IF (l_debug = 'Y') THEN
               OKC_DEBUG.log('7997: Pricing Callback Error Message sent to Configurator...');
               OKC_DEBUG.Reset_Indentation;
         END IF;

END okc_pricing_callback;


-- ---------------------------------------------------------------------------
-- PROCEDURE     : copy_config
-- PURPOSE       : Creates new configuration header and revision while
--                 copying a contract. The newly copied contract will point
--                 to the newly created config header and revisions.
--                 This procedure is called from the contract COPY APIs.
--                 Procedure will handle all configured models in a contract.
-- ---------------------------------------------------------------------------
PROCEDURE copy_config ( p_dnz_chr_id     IN  NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2)
AS
-- -------------------------------------------------------
-- Get all the top models in a copied target contract.
-- There can be more than one configuration in a contract.
-- -------------------------------------------------------
CURSOR cur_get_top_models
IS
SELECT clev.id,
       clev.config_header_id,
       clev.config_revision_number
FROM   okc_k_lines_v clev
WHERE  clev.dnz_chr_id       =  p_dnz_chr_id
AND    clev.config_item_type = 'TOP_MODEL_LINE';

l_top_model_line_id   NUMBER;
l_cfg_hdr_id          NUMBER;
l_cfg_rev_nbr         NUMBER;

-- l_new_config_flag     VARCHAR2(1) := '1';
l_copy_mode           VARCHAR2(1) := CZ_API_PUB.G_NEW_HEADER_COPY_MODE;
l_api_version         NUMBER := 1;
i                     BINARY_INTEGER;
x_msg_count           NUMBER;

x_err_msg             VARCHAR2(200);
x_ret_status          VARCHAR2(1);
x_cfg_hdr_id          NUMBER;
x_cfg_rev_nbr         NUMBER;

x_orig_item_id_tbl    CZ_API_PUB.NUMBER_TBL_TYPE;
x_new_item_id_tbl     CZ_API_PUB.NUMBER_TBL_TYPE;


BEGIN
   SAVEPOINT okc_copy_config;
   IF (l_debug = 'Y') THEN
      OKC_DEBUG.set_indentation('copy_config');
   END IF;
   --FND_MSG_PUB.initialize;

   IF (l_debug = 'Y') THEN
      OKC_DEBUG.log('9000: Entering OKC Copy Configuration...');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR cur_get_top_models_rec in cur_get_top_models
   LOOP
      l_top_model_line_id := cur_get_top_models_rec.id;
      l_cfg_hdr_id        := cur_get_top_models_rec.config_header_id;
      l_cfg_rev_nbr       := cur_get_top_models_rec.config_revision_number;

   IF (l_debug = 'Y') THEN
      OKC_DEBUG.log('9100: Config Top Model Id  : '||l_top_model_line_id);
      OKC_DEBUG.log('9110: Old config header id : '||l_cfg_hdr_id);
      OKC_DEBUG.log('9120: Old config Revision  : '||l_cfg_rev_nbr);
   END IF;

   IF l_cfg_hdr_id  IS NOT NULL AND
      l_cfg_rev_nbr IS NOT NULL
   THEN
   IF (l_debug = 'Y') THEN
       OKC_DEBUG.log('9130: Calling CZ Copy Config API...');
   END IF;

          -- Bug 2614950.
          -- The old copy_configuration call has been commented out below.
          -- New signature of copy configuration has been provided in the
          -- CZ_CONFIG_API_PUB package.The new signature returns two more OUT tables,
          -- one having the old config item ids and the other having the corresponding
          -- new config item ids(if there is any change in the config item ids).The
          -- config item ids of the contract lines should also be updated using these
	  -- pl/sql out tables.


/*      CZ_CF_API.copy_configuration
                ( config_hdr_id      => l_cfg_hdr_id,
                  config_rev_nbr     => l_cfg_rev_nbr,
                  new_config_flag    => l_new_config_flag,
                  out_config_hdr_id  => x_cfg_hdr_id,
                  out_config_rev_nbr => x_cfg_rev_nbr,
                  error_message      => x_err_msg,
                  return_value       => x_ret_value);       */

     CZ_CONFIG_API_PUB.copy_configuration
                 ( p_api_version      => l_api_version,
                   p_config_hdr_id    => l_cfg_hdr_id,
                   p_config_rev_nbr   => l_cfg_rev_nbr,
                   p_copy_mode        => l_copy_mode,
                   x_config_hdr_id    => x_cfg_hdr_id,
                   x_config_rev_nbr   => x_cfg_rev_nbr,
                   x_orig_item_id_tbl => x_orig_item_id_tbl,
                   x_new_item_id_tbl  => x_new_item_id_tbl,
                   x_return_status    => x_ret_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_err_msg  );

   END IF;


   IF x_ret_status <> OKC_API.G_RET_STS_SUCCESS
   THEN
       -- This is an error condition for copy configuration
      IF (l_debug = 'Y') THEN
         OKC_DEBUG.log('9250: Error in Copy Configuration...'||x_err_msg);
      END IF;
       RAISE OKC_API.G_EXCEPTION_ERROR;
   ELSE
       -- --------------------------------------------------------
       -- CZ Copy config returned success.
       -- Update contract lines for this config with new pointers
       -- for the columns config_top_model_line_id,
       -- config_header_id,config_revision_number.
       -- --------------------------------------------------------

   IF (l_debug = 'Y') THEN  -- Display all the returned info in debug mode

      OKC_DEBUG.LOG('9200: New config header id : '||x_cfg_hdr_id);
      OKC_DEBUG.LOG('9210: New config Revision  : '||x_cfg_rev_nbr);
      OKC_DEBUG.LOG('9220: Error Message        : '||x_err_msg);
      OKC_DEBUG.LOG('9221: Error Message Count  : '||x_msg_count);
      OKC_DEBUG.LOG('9230: Return Status        : '||x_ret_status);
      OKC_DEBUG.LOG(' ');
      OKC_DEBUG.LOG('9231: The original item ids from the output table');

      IF x_orig_item_id_tbl.count > 0 THEN
         FOR i in x_orig_item_id_tbl.FIRST..x_orig_item_id_tbl.LAST
         LOOP
            OKC_DEBUG.LOG(' ');
            OKC_DEBUG.LOG('Original config item id '||i||' = '||x_orig_item_id_tbl(i));
	 END LOOP;
      END IF;

      OKC_DEBUG.LOG(' ');
      OKC_DEBUG.LOG('9232: The new item ids from the output table');

      IF x_new_item_id_tbl.count > 0 THEN
         FOR i in x_new_item_id_tbl.FIRST..x_new_item_id_tbl.LAST
         LOOP
            OKC_DEBUG.LOG(' ');
            OKC_DEBUG.LOG('New config item id '||i||' = '||x_new_item_id_tbl(i));
	 END LOOP;
      END IF;
   END IF;  -- End display all the returned info in debug mode


       UPDATE okc_k_lines_b
       SET    config_top_model_line_id = l_top_model_line_id,
              config_header_id         = x_cfg_hdr_id,
              config_revision_number   = x_cfg_rev_nbr
       WHERE  dnz_chr_id               = p_dnz_chr_id
       AND    config_header_id         = l_cfg_hdr_id
       AND    config_revision_number   = l_cfg_rev_nbr ;

  END IF;

   IF (l_debug = 'Y') THEN
      OKC_DEBUG.log('9500: Created new Configuration for : '||l_cfg_hdr_id, 2);
   END IF;

   -- ----------------------------------------------------------------------------
   -- Update the contract lines for this configuration with the new config_item_id
   -- with the new config_item_id.
   -- ----------------------------------------------------------------------------

   IF (l_debug = 'Y') THEN
      OKC_DEBUG.log('9501: Updating the CONFIG ITEM IDs : ');
   END IF;

    IF x_orig_item_id_tbl.COUNT > 0 THEN
       FOR i IN x_orig_item_id_tbl.FIRST..x_orig_item_id_tbl.LAST LOOP
          UPDATE okc_k_lines_b
               SET config_item_id  = x_new_item_id_tbl(i)
          WHERE
               dnz_chr_id          = p_dnz_chr_id
          AND config_header_id     = x_cfg_hdr_id
          AND config_revision_number    = x_cfg_rev_nbr
          AND config_item_id            = x_orig_item_id_tbl(i)
          AND config_item_type IN ('CONFIG','TOP_BASE_LINE');
       END Loop;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

END LOOP;

   IF (l_debug = 'Y') THEN
      OKC_DEBUG.log('9999: Exiting Copy Configuration...', 2);
      OKC_DEBUG.Reset_Indentation;
   END IF;

EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      IF (l_debug = 'Y') THEN
         OKC_DEBUG.log('5999:Exception Error in Copy Config...', 2);
         OKC_DEBUG.Reset_Indentation;
      END IF;

          IF cur_get_top_models%ISOPEN
          THEN
            CLOSE cur_get_top_models;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('5999:Other Exception in Copy Config...', 2);
          OKC_DEBUG.Reset_Indentation;
       END IF;

        IF cur_get_top_models%ISOPEN
        THEN
          CLOSE cur_get_top_models;
        END IF;

        OKC_API.set_message(
                p_app_name        => G_APP_NAME,
                p_msg_name        => G_UNEXPECTED_ERROR,
                p_token1          => G_SQLCODE_TOKEN,
                p_token1_value    => SQLCODE,
                p_token2          => G_SQLERRM_TOKEN,
                p_token2_value    => SQLERRM);

        x_return_status := FND_API.G_RET_STS_ERROR;
END copy_config;

END okc_cfg_pub;

/
