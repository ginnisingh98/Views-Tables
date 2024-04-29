--------------------------------------------------------
--  DDL for Package Body OKL_UBB_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UBB_INTEGRATION_PVT" AS
/* $Header: OKLRUBIB.pls 120.8 2007/11/08 21:27:16 avsingh noship $*/

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- Global Variables
   G_INIT_NUMBER NUMBER := -9999;

   SUBTYPE rulv_rec_type                      IS OKL_RULE_PUB.rulv_rec_type;
   SUBTYPE oks_header_rec_type                IS OKS_CONTRACTS_PUB.Header_rec_type;
   SUBTYPE oks_contact_tbl_type               IS OKS_CONTRACTS_PUB.contact_tbl;
   SUBTYPE oks_salescredit_tbl_type           IS OKS_CONTRACTS_PUB.salescredit_tbl;
   SUBTYPE oks_obj_articles_tbl_type          IS OKS_CONTRACTS_PUB.obj_articles_tbl;
   SUBTYPE oks_line_rec_type                  IS OKS_CONTRACTS_PUB.line_rec_type;
   SUBTYPE oks_supp_line_rec_type             IS OKS_CONTRACTS_PUB.line_rec_type;
   SUBTYPE oks_covered_level_rec_type         IS OKS_CONTRACTS_PUB.covered_level_rec_type;
   SUBTYPE oks_pricing_attrb_rec_type         IS OKS_CONTRACTS_PUB.pricing_attributes_type;
   --SUBTYPE oks_StreamHdr_rec_type             IS OKS_BILL_SCH.StreamHdr_type;
   SUBTYPE oks_StreamLvl_tbl_type             IS OKS_BILL_SCH.StreamLvl_tbl;

   SUBTYPE crjv_rec_type                      IS OKC_K_REL_OBJS_PUB.crjv_rec_type;
   SUBTYPE cimv_rec_type                      IS OKC_CONTRACT_ITEM_PUB.cimv_rec_type;


    TYPE header_rec_type IS RECORD (
       id                  okl_k_headers_full_v.id%TYPE,
       inv_organization_id okl_k_headers_full_v.inv_organization_id%TYPE,
       sts_code            okl_k_headers_full_v.sts_code%TYPE,
       qcl_id              okl_k_headers_full_v.qcl_id%TYPE,
       scs_code            okl_k_headers_full_v.scs_code%TYPE,
       contract_number     okl_k_headers_full_v.contract_number%TYPE,
       currency_code       okl_k_headers_full_v.currency_code%TYPE,
       cust_po_number      okl_k_headers_full_v.cust_po_number%TYPE,
       short_description   okl_k_headers_full_v.short_description%TYPE,
       start_date          okl_k_headers_full_v.start_date%TYPE,
       end_date            okl_k_headers_full_v.end_date%TYPE,
       term_duration       okl_k_headers_full_v.term_duration%TYPE,
       authoring_org_id    okl_k_headers_full_v.authoring_org_id%TYPE
    );

-- Cursors
--Fixed Bug # 5484903
   CURSOR usage_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  select *
   from   okl_k_lines_full_v line
   where  line.dnz_chr_id = p_chr_id    and
     --Bug# 6374869: subquesry was fetching multiple records as 'USAGE' line
     --exists for OKS as well as OKL
     line.lse_id = 56
     --line.lse_id = (
      --                    select id
       --                   from   okc_line_styles_b
        --                  where  lty_code = 'USAGE'
         --                )
   -- added to handle abandon line
   and    not exists (
                      select 'Y'
                      from   okc_statuses_b okcsts
                      where  okcsts.code = line.sts_code
                      and    okcsts.ste_code in ('EXPIRED','HOLD','CANCELLED','TERMINATED'));


   g_usage_rec usage_csr%ROWTYPE;

   CURSOR link_asset_csr (p_chr_id        OKC_K_HEADERS_V.ID%TYPE,
                          p_usage_line_id OKC_K_LINES_V.ID%TYPE) IS
   SELECT id,
          name ASSET_NUMBER,
          line_number
   FROM   OKL_K_LINES_FULL_V line
   WHERE  line.dnz_chr_id = p_chr_id
   AND    line.cle_id     = p_usage_line_id
   -- added to handle abandon line
   AND    NOT EXISTS (
                      SELECT 'Y'
                      FROM   okc_statuses_v okcsts
                      WHERE  okcsts.code = line.sts_code
                      AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

   CURSOR ib_csr (p_chr_id      OKC_K_HEADERS_V.ID%TYPE,
                  p_top_line_id OKC_K_LINES_V.ID%TYPE) IS
   SELECT ib_line.id,
          ib_line.line_number
   FROM   okl_k_lines_full_v ib_line,
          okl_k_lines_full_v inst_line,
          okl_k_lines_full_v top_line
   WHERE  ib_line.cle_id      = inst_line.id
   AND    inst_line.cle_id    = top_line.id
   AND    ib_line.lse_id      = (select id from okc_line_styles_v where lty_code = 'INST_ITEM')
   AND    inst_line.lse_id    = (select id from okc_line_styles_v where lty_code = 'FREE_FORM2')
   AND    top_line.lse_id     = (select id from okc_line_styles_v where lty_code = 'FREE_FORM1')
   AND    top_line.id         = p_top_line_id
   AND    top_line.dnz_chr_id = p_chr_id;

   CURSOR counter_csr (p_chr_id        OKC_K_HEADERS_V.ID%TYPE,
                       p_usage_item_id NUMBER,
                       p_ib_line_id    OKC_K_LINES_V.ID%TYPE) IS
   SELECT cc.counter_id,
          cc.uom_code
   FROM   cs_counter_groups csg,
          cs_counters cc,
          okc_k_items cim,
          okc_k_lines_b cle,
          okc_line_styles_b lse
   WHERE  TO_CHAR(csg.source_object_id) = cim.object1_id1
   AND    cim.cle_id                    = cle.id
   AND    cle.lse_id                    = lse.id
   AND    csg.counter_group_id          = cc.counter_group_id
   AND    lse.lty_code                  = 'INST_ITEM'
   AND    cc.usage_item_id              = p_usage_item_id
   AND    cle.dnz_chr_id                = p_chr_id
   AND    cle.id                        = p_ib_line_id;


------------------------------------------------------------------------------
-- PROCEDURE Report_Error
-- It is a generalized routine to display error on Concurrent Manager Log file
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    okl_api.end_activity(
                         X_msg_count => x_msg_count,
                         X_msg_data  => x_msg_data
                        );

    FOR i in 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

      -- DBMS_OUTPUT to be replaced by FND_FILE.PUT_LINE(FND_FILE.LOG, "message to be printed")
      --dbms_output.put_line('Error '||to_char(i)||': '||x_msg_data);
    END LOOP;
    return;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;

------------------------------------------------------------------------------
-- PROCEDURE get_rule_information
--
--  This procedure returns Rule information attached to Contract Header or Line
--
-- Calls:
-- Called By:
--  create_ubb_contract
------------------------------------------------------------------------------
   PROCEDURE get_rule_information(
                                  x_return_status             OUT NOCOPY VARCHAR2,
                                  x_msg_count                 OUT NOCOPY NUMBER,
                                  x_msg_data                  OUT NOCOPY VARCHAR2,
                                  p_rule_information_category IN  OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE,
                                  p_rgd_code                  IN  OKC_RULE_GROUPS_V.RGD_CODE%TYPE,
                                  p_jtot_object1_code         IN  OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE,
                                  p_chr_id                    IN  OKC_K_HEADERS_V.ID%TYPE,
                                  p_cle_id                    IN  OKC_K_LINES_V.ID%TYPE,
                                  x_rulv_rec                  OUT NOCOPY rulv_rec_type
                                 ) IS


    CURSOR rulv_csr (p_rule_info_catg OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE,
                     p_rgd_code       OKC_RULE_GROUPS_V.RGD_CODE%TYPE,
                     p_jtot_code      OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE,
                     p_chr_id         OKC_K_HEADERS_V.ID%TYPE,
                     p_cle_id         OKC_K_LINES_V.ID%TYPE) IS
    SELECT
            rule.ID,
            rule.OBJECT_VERSION_NUMBER,
            rule.SFWT_FLAG,
            rule.OBJECT1_ID1,
            rule.OBJECT2_ID1,
            rule.OBJECT3_ID1,
            rule.OBJECT1_ID2,
            rule.OBJECT2_ID2,
            rule.OBJECT3_ID2,
            rule.JTOT_OBJECT1_CODE,
            rule.JTOT_OBJECT2_CODE,
            rule.JTOT_OBJECT3_CODE,
            rule.DNZ_CHR_ID,
            rule.RGP_ID,
            rule.PRIORITY,
            rule.STD_TEMPLATE_YN,
            rule.COMMENTS,
            rule.WARN_YN,
            rule.ATTRIBUTE_CATEGORY,
            rule.ATTRIBUTE1,
            rule.ATTRIBUTE2,
            rule.ATTRIBUTE3,
            rule.ATTRIBUTE4,
            rule.ATTRIBUTE5,
            rule.ATTRIBUTE6,
            rule.ATTRIBUTE7,
            rule.ATTRIBUTE8,
            rule.ATTRIBUTE9,
            rule.ATTRIBUTE10,
            rule.ATTRIBUTE11,
            rule.ATTRIBUTE12,
            rule.ATTRIBUTE13,
            rule.ATTRIBUTE14,
            rule.ATTRIBUTE15,
            rule.CREATED_BY,
            rule.CREATION_DATE,
            rule.LAST_UPDATED_BY,
            rule.LAST_UPDATE_DATE,
            rule.LAST_UPDATE_LOGIN,
            rule.RULE_INFORMATION_CATEGORY,
            rule.RULE_INFORMATION1,
            rule.RULE_INFORMATION2,
            rule.RULE_INFORMATION3,
            rule.RULE_INFORMATION4,
            rule.RULE_INFORMATION5,
            rule.RULE_INFORMATION6,
            rule.RULE_INFORMATION7,
            rule.RULE_INFORMATION8,
            rule.RULE_INFORMATION9,
            rule.RULE_INFORMATION10,
            rule.RULE_INFORMATION11,
            rule.RULE_INFORMATION12,
            rule.RULE_INFORMATION13,
            rule.RULE_INFORMATION14,
            rule.RULE_INFORMATION15,
            template_yn,
            ans_set_jtot_object_code,
            ans_set_jtot_object_id1,
            ans_set_jtot_object_id2,
            display_sequence
     FROM   okc_rules_v rule,
            okc_rule_groups_v grp
     WHERE  rule_information_category = p_rule_info_catg --'CAN'
     AND    jtot_object1_code         = p_jtot_code      --'OKX_CUSTACCT'
     AND    grp.rgd_code              = p_rgd_code       --'LACAN'
     AND    (grp.dnz_chr_id           = NVL(p_chr_id, G_INIT_NUMBER)
             OR
             grp.cle_id               = NVL(p_cle_id, G_INIT_NUMBER)
            )
     AND    rule.rgp_id               = grp.id;

   l_proc_name VARCHAR2(35) := 'GET_RULE_INFORMATION';
   l_rulv_rec  rulv_csr%ROWTYPE;
   rule_failed EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,p_chr_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'jtot: '||p_jtot_object1_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rgd: '||p_rgd_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'info: '||p_rule_information_category);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN rulv_csr (p_rule_information_category,
                   p_rgd_code,
                   p_jtot_object1_code,
                   p_chr_id,
                   p_cle_id);

    FETCH rulv_csr INTO
              l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
              l_rulv_rec.SFWT_FLAG,
              l_rulv_rec.OBJECT1_ID1,
              l_rulv_rec.OBJECT2_ID1,
              l_rulv_rec.OBJECT3_ID1,
              l_rulv_rec.OBJECT1_ID2,
              l_rulv_rec.OBJECT2_ID2,
              l_rulv_rec.OBJECT3_ID2,
              l_rulv_rec.JTOT_OBJECT1_CODE,
              l_rulv_rec.JTOT_OBJECT2_CODE,
              l_rulv_rec.JTOT_OBJECT3_CODE,
              l_rulv_rec.DNZ_CHR_ID,
              l_rulv_rec.RGP_ID,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.STD_TEMPLATE_YN,
              l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.ATTRIBUTE_CATEGORY,
              l_rulv_rec.ATTRIBUTE1,
              l_rulv_rec.ATTRIBUTE2,
              l_rulv_rec.ATTRIBUTE3,
              l_rulv_rec.ATTRIBUTE4,
              l_rulv_rec.ATTRIBUTE5,
              l_rulv_rec.ATTRIBUTE6,
              l_rulv_rec.ATTRIBUTE7,
              l_rulv_rec.ATTRIBUTE8,
              l_rulv_rec.ATTRIBUTE9,
              l_rulv_rec.ATTRIBUTE10,
              l_rulv_rec.ATTRIBUTE11,
              l_rulv_rec.ATTRIBUTE12,
              l_rulv_rec.ATTRIBUTE13,
              l_rulv_rec.ATTRIBUTE14,
              l_rulv_rec.ATTRIBUTE15,
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN,
              l_rulv_rec.RULE_INFORMATION_CATEGORY,
              l_rulv_rec.RULE_INFORMATION1,
              l_rulv_rec.RULE_INFORMATION2,
              l_rulv_rec.RULE_INFORMATION3,
              l_rulv_rec.RULE_INFORMATION4,
              l_rulv_rec.RULE_INFORMATION5,
              l_rulv_rec.RULE_INFORMATION6,
              l_rulv_rec.RULE_INFORMATION7,
              l_rulv_rec.RULE_INFORMATION8,
              l_rulv_rec.RULE_INFORMATION9,
              l_rulv_rec.RULE_INFORMATION10,
              l_rulv_rec.RULE_INFORMATION11,
              l_rulv_rec.RULE_INFORMATION12,
              l_rulv_rec.RULE_INFORMATION13,
              l_rulv_rec.RULE_INFORMATION14,
              l_rulv_rec.RULE_INFORMATION15,
              l_rulv_rec.TEMPLATE_YN,
              l_rulv_rec.ANS_SET_JTOT_OBJECT_CODE,
              l_rulv_rec.ANS_SET_JTOT_OBJECT_ID1,
              l_rulv_rec.ANS_SET_JTOT_OBJECT_ID2,
              l_rulv_rec.DISPLAY_SEQUENCE;

    IF rulv_csr%NOTFOUND THEN
      RAISE rule_failed;
    END IF;

    CLOSE rulv_csr;

    x_rulv_rec := l_rulv_rec;

   EXCEPTION
      WHEN rule_failed THEN
        IF rulv_csr%ISOPEN THEN
          CLOSE rulv_csr;
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_RULE_ERROR
                           );

      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );

   END get_rule_information;

------------------------------------------------------------------------------
-- PROCEDURE get_party_id
--
--  This procedure gets party id for a contract header/line
--
-- Calls:
-- Called By:
--  populate_header_rec
------------------------------------------------------------------------------

   PROCEDURE get_party_id(
                          x_return_status             OUT NOCOPY VARCHAR2,
                          x_msg_count                 OUT NOCOPY NUMBER,
                          x_msg_data                  OUT NOCOPY VARCHAR2,
                          p_chr_id                    IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_rle_code                  IN  OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE,
                          p_jtot_object1_code         IN  OKC_K_PARTY_ROLES_V.JTOT_OBJECT1_CODE%TYPE,
                          x_party_id                  OUT NOCOPY OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE
                         ) IS
   --Fixed Bug # 5484903
   CURSOR party_csr(p_chr_id            OKC_K_HEADERS_V.ID%TYPE,
                    p_rle_code          OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE,
                    p_jtot_object1_code OKC_K_PARTY_ROLES_V.JTOT_OBJECT1_CODE%TYPE) IS
   SELECT object1_id1
   FROM   okc_k_party_roles_b
   WHERE  rle_code          = p_rle_code
   AND    dnz_chr_id        = p_chr_id
   AND    dnz_chr_id        = chr_id
   AND    jtot_object1_code = p_jtot_object1_code;

   l_proc_name VARCHAR2(35) := 'GET_PARTY_ID';
   party_failed  EXCEPTION;
   l_object1_id1 OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     OPEN party_csr (p_chr_id,
                     p_rle_code,
                     p_jtot_object1_code);
     FETCH party_csr INTO l_object1_id1;

     IF party_csr%NOTFOUND THEN
       raise party_failed;
     END IF;

     x_party_id := l_object1_id1;

     return;
   EXCEPTION
     WHEN party_failed THEN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF party_csr%ISOPEN THEN
          CLOSE party_csr;
        END IF;

        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_PARTY_ROLE_ERROR
                           );

      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
   END get_party_id;

------------------------------------------------------------------------------
-- PROCEDURE get_contract_header
--
--  This procedure returns contract header information
--
-- Calls:
-- Called By:
--  create_ubb_contract
------------------------------------------------------------------------------
   PROCEDURE get_contract_header(
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_chr_id        IN  okl_k_headers_full_v.id%TYPE,
                                 x_header_rec    OUT NOCOPY header_rec_type
                                ) IS
   CURSOR header_csr (p_chr_id okl_k_headers_full_v.id%TYPE) IS
   SELECT id,
          inv_organization_id,
          sts_code,
          qcl_id,
          scs_code,
          contract_number,
          currency_code,
          cust_po_number,
          short_description,
          start_date,
          end_date,
          term_duration,
          authoring_org_id
   FROM   okl_k_headers_full_v
   WHERE  id = p_chr_id;

   header_failed EXCEPTION;
   l_proc_name VARCHAR2(35) := 'GET_CONTRACT_HEADER';

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     OPEN header_csr(p_chr_id);
     FETCH header_csr INTO x_header_rec;
     IF header_csr%NOTFOUND THEN
        RAISE header_failed;
     END IF;
     CLOSE header_csr;

   EXCEPTION
     WHEN header_failed THEN
        IF header_csr%ISOPEN THEN
           CLOSE header_csr;
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_NO_CONTRACT_HEADER
                           );
      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
   END get_contract_header;

------------------------------------------------------------------------------
-- PROCEDURE get_item_uom_code
--
--  This procedure gets UOM code from Item setup, primary_uom_code
--
-- Calls:
-- Called By:
--  create_ubb_contract
------------------------------------------------------------------------------
   PROCEDURE get_item_uom_code(
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               p_item_id        IN  mtl_system_items.inventory_item_id%TYPE,
                               p_org_id         IN  mtl_system_items.organization_id%TYPE,
                               x_uom_code       OUT NOCOPY  mtl_system_items.primary_uom_code%TYPE
                              ) IS

   l_proc_name   VARCHAR2(35) := 'GET_ITEM_UOM_CODE';

   CURSOR uom_csr (p_item_id    mtl_system_items.inventory_item_id%TYPE,
                   p_inv_org_id mtl_system_items.organization_id%TYPE) IS
   SELECT primary_uom_code
   FROM   mtl_system_items
   WHERE  inventory_item_id = p_item_id
   AND    organization_id   = p_inv_org_id;

   l_uom_code mtl_system_items.primary_uom_code%TYPE;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     l_uom_code := NULL;
     OPEN uom_csr (p_item_id,
                   p_org_id);
     FETCH uom_csr INTO l_uom_code;
     CLOSE uom_csr;

     x_uom_code := l_uom_code;

     RETURN;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
       okl_api.set_message(
                    G_APP_NAME,
                    G_UNEXPECTED_ERROR,
                    'OKL_SQLCODE',
                    SQLCODE,
                    'OKL_SQLERRM',
                    SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                   );
       x_uom_code := NULL;

   END get_item_uom_code;

------------------------------------------------------------------------------
-- PROCEDURE get_cust_account
--
--  This procedure returns bill to id from contract header
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_cust_account(
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN  OKC_K_HEADERS_B.ID%TYPE,
                         x_cust_acc_id    OUT NOCOPY  OKC_K_HEADERS_B.CUST_ACCT_ID%TYPE
                        ) IS

   l_proc_name   VARCHAR2(35) := 'GET_CUST_ACCOUNT';

   CURSOR cust_acc_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT cust_acct_id
   FROM   okc_k_headers_b
   WHERE  id = p_chr_id;

   cust_acc_failed EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     x_cust_acc_id := NULL;
     OPEN cust_acc_csr (p_chr_id);
     FETCH cust_acc_csr INTO x_cust_acc_id;
     IF cust_acc_csr%NOTFOUND THEN
        RAISE cust_acc_failed;
     END IF;
     CLOSE cust_acc_csr;

     IF (x_cust_acc_id IS NULL) THEN
        RAISE cust_acc_failed;
     END IF;

     RETURN;

   EXCEPTION

     WHEN cust_acc_failed THEN
        IF cust_acc_csr%ISOPEN THEN
           CLOSE cust_acc_csr;
        END IF;

        x_return_status := OKL_API.G_RET_STS_ERROR;

        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_RULE_ERROR
                           );

     WHEN OTHERS THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
       okl_api.set_message(
                    G_APP_NAME,
                    G_UNEXPECTED_ERROR,
                    'OKL_SQLCODE',
                    SQLCODE,
                    'OKL_SQLERRM',
                    SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                   );

   END get_cust_account;

------------------------------------------------------------------------------
-- PROCEDURE get_bill_to
--
--  This procedure returns bill to id from contract header
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_bill_to(
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN  OKC_K_HEADERS_B.ID%TYPE,
                         x_bill_to_id     OUT NOCOPY  OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE
                        ) IS

   l_proc_name   VARCHAR2(35) := 'GET_BILL_TO';

   CURSOR bill_to_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT bill_to_site_use_id
   FROM   okc_k_headers_b
   WHERE  id = p_chr_id;

   bill_to_failed EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     x_bill_to_id := NULL;
     OPEN bill_to_csr (p_chr_id);
     FETCH bill_to_csr INTO x_bill_to_id;
     IF bill_to_csr%NOTFOUND THEN
        RAISE bill_to_failed;
     END IF;
     CLOSE bill_to_csr;

     IF (x_bill_to_id IS NULL) THEN
        RAISE bill_to_failed;
     END IF;

     RETURN;

   EXCEPTION

     WHEN bill_to_failed THEN
        IF bill_to_csr%ISOPEN THEN
           CLOSE bill_to_csr;
        END IF;

        x_return_status := OKL_API.G_RET_STS_ERROR;

        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_RULE_ERROR
                           );

     WHEN OTHERS THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
       okl_api.set_message(
                    G_APP_NAME,
                    G_UNEXPECTED_ERROR,
                    'OKL_SQLCODE',
                    SQLCODE,
                    'OKL_SQLERRM',
                    SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                   );
   END get_bill_to;

------------------------------------------------------------------------------
-- PROCEDURE populate_header_rec
--
--  This procedure popuates OKS header Record with OKL header Rec values
--
-- Calls:
-- Called By:
--  create_ubb_contract
------------------------------------------------------------------------------
   PROCEDURE populate_header_rec(
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_header_rec     IN  header_rec_type,
                                 x_oks_header_rec OUT NOCOPY oks_header_rec_type
                                ) IS

   l_proc_name   VARCHAR2(35) := 'POPULATE_HEADER_REC';
   x_party_id    NUMBER;
   header_failed EXCEPTION;
   x_rulv_rec    rulv_rec_type;
   l_rule_id     ra_rules.rule_id%TYPE;
   l_qcl_id      okc_qa_check_lists_v.id%TYPE;
   l_pdf_id      okc_process_defs_v.id%TYPE;
   --l_bill_to_id  NUMBER;

/*
   CURSOR ra_rule_csr (p_name ra_rules.name%TYPE) IS
   SELECT rule_id
   FROM   ra_rules
   WHERE  name = p_name;
*/

   CURSOR qcl_csr (p_name okc_qa_check_lists_v.name%TYPE) IS
   SELECT id
   FROM   okc_qa_check_lists_v
   WHERE  name = p_name;
   --Fixed Bug # 5484903
   CURSOR wf_csr (p_name okc_process_defs_v.name%TYPE) IS
   SELECT id
   FROM   okc_process_defs_b
   WHERE  wf_name = p_name;

   l_bill_to_id OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      x_oks_header_rec.contract_number   := p_header_rec.contract_number||'-OKL';
      x_oks_header_rec.start_date        := p_header_rec.start_date;
      x_oks_header_rec.end_date          := p_header_rec.end_date; -- + 1; -- To match with OKS bill Schedule dates
      x_oks_header_rec.sts_code          := 'ACTIVE'; --'SIGNED'; --'ENTERED'; --p_header_rec.sts_code;
      x_oks_header_rec.scs_code          := 'SERVICE'; --p_header_rec.scs_code;
      x_oks_header_rec.authoring_org_id  := p_header_rec.authoring_org_id;
      x_oks_header_rec.short_description := p_header_rec.short_description;
      x_oks_header_rec.currency          := p_header_rec.currency_code;
      x_oks_header_rec.cust_po_number    := p_header_rec.cust_po_number;
      x_oks_header_rec.organization_id   := p_header_rec.inv_organization_id;

/* donot use name, pass qcl_id directly, Bug# 3672188

      OPEN qcl_csr ('DEFAULT QA CHECK LIST');
      FETCH qcl_csr INTO l_qcl_id;
      IF qcl_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_INVALID_VALUE,
                             'COL_NAME',
                             'QA CCHECK NAME'
                            );
         RAISE header_failed;
      END IF;
      CLOSE qcl_csr;
*/

      --x_oks_header_rec.qcl_id            := l_qcl_id; --1; --p_header_rec.qcl_id;
      x_oks_header_rec.qcl_id            := 1; -- Bug 3672188

      OPEN wf_csr('OKCAUKAP');
      FETCH wf_csr INTO l_pdf_id;
      IF wf_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_INVALID_VALUE,
                             'COL_NAME',
                             'WORKFLOW NAME'
                            );
         RAISE header_failed;
      END IF;
      CLOSE wf_csr;

      x_oks_header_rec.pdf_id            := l_pdf_id; --3; -- OKC Approval Workflow default value

/* use rule_id instead
      OPEN ra_rule_csr('IMMEDIATE');
      FETCH ra_rule_csr INTO l_rule_id;
      IF ra_rule_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_INVALID_VALUE,
                             'COL_NAME',
                             'ACCOUNTING RULE TYPE'
                            );
         RAISE header_failed;
      END IF;
      CLOSE ra_rule_csr;
*/
      x_oks_header_rec.accounting_rule_type := 1; -- IMMEDIATE, ra_rules table

/* use rule_id instead
      OPEN ra_rule_csr('ARREARS INVOICE');
      FETCH ra_rule_csr INTO l_rule_id;
      IF ra_rule_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_INVALID_VALUE,
                             'COL_NAME',
                             'INVOICE RULE TYPE'
                            );
         RAISE header_failed;
      END IF;
      CLOSE ra_rule_csr;
*/

      x_oks_header_rec.invoice_rule_type    := -3; -- ARREARS INVOICE, ra_rules table

      get_party_id(
                   x_return_status     => x_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   p_chr_id            => p_header_rec.id,
                   p_rle_code          => 'LESSEE',
                   p_jtot_object1_code => 'OKX_PARTY',
                   x_party_id          => x_party_id
                  );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE header_failed;
      END IF;

      x_oks_header_rec.party_id := x_party_id;

      -- Get BILL_TO information
/* Rule migration
      get_rule_information(
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_rule_information_category => 'BTO',
                           p_rgd_code                  => 'LABILL',
                           p_jtot_object1_code         => 'OKX_BILLTO',
                           p_chr_id                    => p_header_rec.id,
                           p_cle_id                    => NULL,
                           x_rulv_rec                  => x_rulv_rec
                          );
*/
      get_bill_to(
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_chr_id        => p_header_rec.id,
                  x_bill_to_id    => l_bill_to_id
                 );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE header_failed;
      END IF;

      --debug_message('Bill to object1_id1 : '||x_rulv_rec.object1_id1);
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Bill to object1_id1 : '||l_bill_to_id);
      END IF;

      --x_rulv_rec.object1_id1 := 1329; -- ???
      --x_oks_header_rec.bill_to_id := x_rulv_rec.object1_id1;
      x_oks_header_rec.bill_to_id := l_bill_to_id;
      --x_oks_header_rec.ship_to_id := x_rulv_rec.object1_id1; -- 1329; -- ???
      --debug_message(x_rulv_rec.object1_id1);

      -- Get Priceing information

      get_rule_information(
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_rule_information_category => 'LAUSBB',
                           p_rgd_code                  => 'LAUSBB',
                           p_jtot_object1_code         => 'OKX_USAGE',
                           p_chr_id                    => p_header_rec.id,
                           p_cle_id                    => NULL,
                           x_rulv_rec                  => x_rulv_rec
                          );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE header_failed;
      END IF;

      x_oks_header_rec.price_list_id := x_rulv_rec.object2_id1;

   EXCEPTION
      WHEN header_failed THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );

   END populate_header_rec;


------------------------------------------------------------------------------
-- PROCEDURE populate_line_rec
--
--  This procedure popuates OKS Line Record with OKL line Rec values
--
-- Calls:
-- Called By:
--  create_ubb_contract
------------------------------------------------------------------------------
   PROCEDURE populate_line_rec(
                               x_return_status       OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_msg_data            OUT NOCOPY VARCHAR2,
                               p_header_id           IN  NUMBER,
                               p_line_rec            IN  usage_csr%ROWTYPE,
                               p_line_number         IN  NUMBER,
                               p_customer_product_id IN  NUMBER,
                               p_uom_code            IN  VARCHAR2,
                               p_oks_header_id       IN  NUMBER,
                               x_usage_item_id       OUT NOCOPY NUMBER,
                               x_oks_line_rec        OUT NOCOPY oks_line_rec_type
                              ) IS

   l_proc_name      VARCHAR2(35) := 'POPULATE_LINE_REC';
   line_failed      EXCEPTION;

   l_rule_id        ra_rules.rule_id%TYPE;

   x_oks_header_rec header_rec_type;
   x_party_id       NUMBER;
   x_rulv_rec       rulv_rec_type;

   l_oks_start_date DATE;
   l_oks_end_date   DATE;
   l_authoring_org_id NUMBER;

   l_uom_code       mtl_system_items.primary_uom_code%TYPE;

   CURSOR oks_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT start_date,
          end_date,
          authoring_org_id
   FROM   okc_k_headers_v
   WHERE  id = p_chr_id;

/*
   CURSOR ra_rule_csr (p_name ra_rules.name%TYPE) IS
   SELECT rule_id
   FROM   ra_rules
   WHERE  name = p_name;
*/

   l_bill_to_id  OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE;
   l_cust_acc_id OKC_K_HEADERS_B.CUST_ACCT_ID%TYPE;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      get_contract_header(
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_header_id,
                          x_header_rec    => x_oks_header_rec
                         );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE line_failed;
      END IF;

      IF (p_oks_header_id IS NOT NULL) THEN
         x_oks_line_rec.k_hdr_id := p_oks_header_id; -- for second line onward
      END IF;

      x_oks_line_rec.k_line_number          := p_line_number;
      x_oks_line_rec.line_sts_code          := 'ACTIVE'; -- 'SIGNED'; --'ENTERED'; --p_line_rec.sts_code;
      x_oks_line_rec.org_id                 := x_oks_header_rec.authoring_org_id; --204; --??? same as header
      x_oks_line_rec.organization_id        := x_oks_header_rec.authoring_org_id; --204; --??? same as header
      x_oks_line_rec.line_type              := 'U';
      x_oks_line_rec.currency               := p_line_rec.currency_code;
      --x_oks_line_rec.usage_type             := 'FRT'; -- Get usage_type from LAUSBB later
      --x_oks_line_rec.usage_period           := 'MTH'; -- Populated below from LAUSBB
      x_oks_line_rec.customer_product_id    := p_customer_product_id;
      --x_oks_line_rec.uom_code               := p_uom_code; -- Get usage_type from LAUSBB later

/* use rule_id instead
      OPEN ra_rule_csr('IMMEDIATE');
      FETCH ra_rule_csr INTO l_rule_id;
      IF ra_rule_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_INVALID_VALUE,
                             'COL_NAME',
                             'ACCOUNTING RULE TYPE'
                            );
         RAISE line_failed;
      END IF;
      CLOSE ra_rule_csr;
*/

      x_oks_line_rec.accounting_rule_type := 1; -- IMMEDIATE, ra_rules table

/* use rule_id instead
      OPEN ra_rule_csr('ARREARS INVOICE');
      FETCH ra_rule_csr INTO l_rule_id;
      IF ra_rule_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_INVALID_VALUE,
                             'COL_NAME',
                             'INVOICE RULE TYPE'
                            );
         RAISE line_failed;
      END IF;
      CLOSE ra_rule_csr;
*/
      x_oks_line_rec.invoicing_rule_type    := -3; -- ARREARS INVOICE, ra_rules table

      -- Get LAUSBB information
      get_rule_information(
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_rule_information_category => 'LAUSBB',
                           p_rgd_code                  => 'LAUSBB',
                           p_jtot_object1_code         => 'OKX_USAGE',
                           p_chr_id                    => NULL,
                           p_cle_id                    => p_line_rec.id,
                           x_rulv_rec                  => x_rulv_rec
                          );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE line_failed;
      END IF;

      x_usage_item_id           := x_rulv_rec.object1_id1; -- Required to get Counter later
      x_oks_line_rec.srv_id     := x_rulv_rec.object1_id1;
      x_oks_line_rec.usage_type := x_rulv_rec.rule_information6;
      x_oks_line_rec.uom_code   := x_rulv_rec.object3_id1;

      x_oks_line_rec.usage_period := x_rulv_rec.rule_information8;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Service Contract Header :'||p_oks_header_id);
      END IF;

      IF (p_line_rec.start_date IS NULL
          AND
          p_line_rec.end_date IS NULL) THEN

         x_oks_line_rec.srv_sdt := x_oks_header_rec.start_date;
         x_oks_line_rec.srv_edt := x_oks_header_rec.end_date;

      ELSIF (p_line_rec.start_date IS NULL
             AND
             p_line_rec.end_date IS NOT NULL) THEN

         x_oks_line_rec.srv_sdt := x_oks_header_rec.start_date;
         x_oks_line_rec.srv_edt := p_line_rec.end_date; -- + 1;   -- To match OKS need

      ELSIF (p_line_rec.start_date IS NOT NULL
             AND
             p_line_rec.end_date IS NULL) THEN

         x_oks_line_rec.srv_edt := x_oks_header_rec.end_date;
         x_oks_line_rec.srv_sdt := p_line_rec.start_date; -- + 1; -- To match OKS need

      ELSE
         x_oks_line_rec.srv_sdt := p_line_rec.start_date;
         x_oks_line_rec.srv_edt := p_line_rec.end_date; -- + 1;   -- To match OKS need
      END IF;

     get_party_id(
                   x_return_status     => x_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   p_chr_id            => p_header_id,
                   p_rle_code          => 'LESSEE',
                   p_jtot_object1_code => 'OKX_PARTY',
                   x_party_id          => x_party_id
                  );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE line_failed;
      END IF;

      x_oks_line_rec.customer_id := x_party_id;

      -- Get CUSTOMER ACCOUNT information
/* Rule migration
      get_rule_information(
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_rule_information_category => 'CAN',
                           p_rgd_code                  => 'LACAN',
                           p_jtot_object1_code         => 'OKX_CUSTACCT',
                           p_chr_id                    => p_header_id,
                           p_cle_id                    => NULL,
                           x_rulv_rec                  => x_rulv_rec
                          );
*/

      get_cust_account(
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_chr_id        => p_header_id,
                  x_cust_acc_id   => l_cust_acc_id
                 );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE line_failed;
      END IF;

      --x_oks_line_rec.cust_account := x_rulv_rec.object1_id1;
      x_oks_line_rec.cust_account := l_cust_acc_id;

      -- Get BILL_TO information
/* Rule migration
      get_rule_information(
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_rule_information_category => 'BTO',
                           p_rgd_code                  => 'LABILL',
                           p_jtot_object1_code         => 'OKX_BILLTO',
                           p_chr_id                    => p_header_id,
                           p_cle_id                    => NULL,
                           x_rulv_rec                  => x_rulv_rec
                          );
*/

      get_bill_to(
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_chr_id        => p_header_id,
                  x_bill_to_id    => l_bill_to_id
                 );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE line_failed;
      END IF;

      --x_oks_line_rec.bill_to_id := x_rulv_rec.object1_id1;
      x_oks_line_rec.bill_to_id := l_bill_to_id;

      RETURN;

   EXCEPTION

      WHEN line_failed THEN
        IF oks_csr%ISOPEN THEN
           CLOSE oks_csr;
        END IF;
/*
        IF ra_rule_csr%ISOPEN THEN
           CLOSE ra_rule_csr;
        END IF;
*/
        x_return_status := OKC_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );

   END populate_line_rec;

------------------------------------------------------------------------------
-- PROCEDURE populate_covered_rec
--
--  This procedure popuates OKS covered Line Record with OKL Rules
--
-- Calls:
-- Called By:
--  create_ubb_contract
------------------------------------------------------------------------------
   PROCEDURE populate_covered_rec(
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_msg_count         OUT NOCOPY NUMBER,
                                  x_msg_data          OUT NOCOPY VARCHAR2,
                                  p_oks_header_id     IN  NUMBER,
                                  p_counter_id        IN  NUMBER,
                                  p_usage_line_id     IN  NUMBER,
                                  p_usage_start_date  IN  DATE,
                                  p_oks_usage_line_id IN  NUMBER,
                                  p_header_rec        IN  header_rec_type,
                                  x_oks_covered_rec   OUT NOCOPY oks_covered_level_rec_type
                                 ) IS
   l_proc_name    VARCHAR2(35) := 'POPULATE_COVERED_REC';
   x_rulv_rec     rulv_rec_type;
   covered_failed EXCEPTION;

   l_uom_code mtl_system_items.primary_uom_code%TYPE;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     IF (p_oks_header_id IS NOT NULL) THEN
        x_oks_covered_rec.k_id := p_oks_header_id;
     END IF;

     IF (p_oks_usage_line_id IS NOT NULL) THEN
        x_oks_covered_rec.attach_2_line_id := p_oks_usage_line_id;
     END IF;

     -- Get LAUSBB information
     get_rule_information(
                          x_return_status             => x_return_status,
                          x_msg_count                 => x_msg_count,
                          x_msg_data                  => x_msg_data,
                          p_rule_information_category => 'LAUSBB',
                          p_rgd_code                  => 'LAUSBB',
                          p_jtot_object1_code         => 'OKX_USAGE',
                          p_chr_id                    => NULL,
                          p_cle_id                    => p_usage_line_id,
                          x_rulv_rec                  => x_rulv_rec
                         );
     IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE covered_failed;
     END IF;

     x_oks_covered_rec.customer_product_id := p_counter_id;
     x_oks_covered_rec.product_start_date  := p_usage_start_date; --SYSDATE;
     --x_oks_covered_rec.product_end_date    := SYSDATE + 365; -- ??? check without end date, or end date of contract

     --x_oks_covered_rec.uom_code            := x_rulv_rec.rule_information7; dedey, 10/21/2002
     x_oks_covered_rec.uom_code            := x_rulv_rec.object3_id1; -- dedey, 10/21/2002 Bug# 2569732

     x_oks_covered_rec.currency_code       := p_header_rec.currency_code; --'USD'; --??? from header
     x_oks_covered_rec.period              := x_rulv_rec.rule_information8; --'MTH';
     x_oks_covered_rec.amcv_flag           := x_rulv_rec.rule_information3;
     x_oks_covered_rec.fixed_qty           := x_rulv_rec.rule_information7;
     x_oks_covered_rec.level_yn            := x_rulv_rec.rule_information4;
     x_oks_covered_rec.base_reading        := x_rulv_rec.rule_information5;
     x_oks_covered_rec.minimum_qty         := x_rulv_rec.rule_information1;
     x_oks_covered_rec.default_qty         := x_rulv_rec.rule_information2;

     RETURN;

   EXCEPTION

      WHEN covered_failed THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
   END populate_covered_rec;

------------------------------------------------------------------------------
-- PROCEDURE get_top_line_id
--
--  This procedure returns TOP line for a contract with USAGE line
--  from Usage Sub Line ID. Getting the link thru OKC_K_ITEMS.OBJECT1_ID1
--
-- Calls:
-- Called By:
--  create_ubb_contract
------------------------------------------------------------------------------
   PROCEDURE get_top_line_id (
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                              p_link_asset_line_id IN  OKL_K_LINES_FULL_V.ID%TYPE,
                              p_link_asset_line_no IN  OKL_K_LINES_FULL_V.LINE_NUMBER%TYPE,
                              x_top_line_id        OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                            ) IS

   l_id       OKC_K_LINES_V.ID%TYPE;
   top_failed EXCEPTION;
   l_proc_name VARCHAR2(35) := 'GET_TOP_LINE_ID';

   CURSOR top_csr (p_chr_id              OKC_K_HEADERS_V.ID%TYPE,
                   p_link_asset_line_id  OKL_K_LINES_FULL_V.ID%TYPE) IS
   SELECT oki.object1_id1
   FROM   okl_k_lines_full_v oklf,
          okc_k_items oki
   WHERE  oklf.id         = p_link_asset_line_id
   AND    oklf.dnz_chr_id = p_chr_id
   AND    oklf.id         = oki.cle_id;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     OPEN top_csr(p_chr_id,
                  p_link_asset_line_id);
     FETCH top_csr INTO l_id;
     IF top_csr%NOTFOUND THEN
        RAISE top_failed;
     END IF;

     x_top_line_id := l_id;

     CLOSE top_csr;
   EXCEPTION
     WHEN top_failed THEN
        IF top_csr%ISOPEN THEN
           CLOSE top_csr;
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_NO_TOP_LINE,
                            'LINE_NUM',
                            p_link_asset_line_no
                           );
      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
   END get_top_line_id;

------------------------------------------------------------------------------
  --Start of comments
  --Bug#2498796
  --API Name              : update_counter_instance
  --Purpose               : Local API called from Process_IB_Line2
  --                        Will update any CS counter created during
  --                        IB activation.
  --Modification History :
  --13-Aug-2002    avsingh  Created
  --End of Comments
------------------------------------------------------------------------------
procedure update_counter_instance (
	                     x_return_status     OUT NOCOPY VARCHAR2,
	                     x_msg_count         OUT NOCOPY NUMBER,
	                     x_msg_data          OUT NOCOPY VARCHAR2,
                             p_okl_usage_line_id IN  OKC_K_LINES_V.ID%TYPE,
                             p_oks_usage_line_id IN  OKC_K_LINES_V.ID%TYPE) is

  l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_COUNTER_INSTANCE';
  l_api_version	      CONSTANT NUMBER	    := 1.0;


  --cursor to get any counter instances created as part of activation for this line
  Cursor ctr_cur (p_oks_top_line_id IN NUMBER) IS
  select ct.*
         --Bug# 6374869
  from   --CS_COUNTERS    ct,
         CSI_COUNTERS_B  ct,
         OKC_K_ITEMS    ct_item,
         OKC_K_LINES_B  ct_line
  where  ct.counter_id      = to_number(ct_item.object1_id1)
  and    ct_item.cle_id     = ct_line.id
  and    ct_item.dnz_chr_id = ct_line.dnz_chr_id
  and    ct_line.cle_id     = p_oks_top_line_id;



  l_ctr_rec ctr_cur%ROWTYPE;
  l_oks_top_line_id        NUMBER;

  --cursor to get LAUSBB rule values
  Cursor lausbb_cur(p_okl_top_line_id IN NUMBER) is
  Select   to_number(rul.object1_id1)      usage_item_id
          ,to_number(rul.object1_id2)      usage_item_inv_org_id
          ,to_number(rul.object2_id1)      price_list_id
          ,rul.rule_information1           Miminum_Quantity
          ,rul.rule_information2           Default_Quantity
          ,rul.rule_information3           Avg_monthly_Counter_Value
          ,rul.rule_information4           ct_Level
          ,rul.rule_information5           Base_Reading
          ,rul.object3_id1                 base_reading_uom
  From    OKC_RULES_B        rul,
          OKC_RULE_GROUPS_B  rgp,
          OKC_K_LINES_B      usage_cle
  Where   rul.rgp_id                    = rgp.id
  and     rul.rule_information_category = 'LAUSBB'
  and     rul.dnz_chr_id                = rgp.dnz_chr_id
  and     rgp.dnz_chr_id                = usage_cle.dnz_chr_id
  and     rgp.cle_id                    = usage_cle.id
  and     usage_cle.id                  = p_okl_top_line_id;

  l_lausbb_rec lausbb_cur%ROWTYPE;
  l_okl_top_line_id      NUMBER;

  --Bug# 6374869
  --l_csi_ctr_rec    CS_COUNTERS_PUB.ctr_rec_type;
  l_counter_instance_rec      CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec;
  l_ctr_properties_tbl        CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl;
  l_counter_relationships_tbl CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl;
  l_ctr_derived_filters_tbl   CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl;
  l_counter_associations_tbl  CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl;
  --Bug# 6374869 End

  l_object_version_number NUMBER;

  ctr_exception    EXCEPTION;

Begin

   l_oks_top_line_id := p_oks_usage_line_id;
   l_okl_top_line_id := p_okl_usage_line_id;

   OPEN lausbb_cur(p_okl_top_line_id => l_okl_top_line_id);
   FETCH lausbb_cur into l_lausbb_rec;
   IF lausbb_cur%NOTFOUND Then
       Null;
   Else
       OPEN ctr_cur (p_oks_top_line_id => l_oks_top_line_id);
       Loop
           FETCH ctr_cur into l_ctr_rec;
           Exit When ctr_cur%NOTFOUND;
           --Bug# 6374869
           l_counter_instance_rec.counter_id := l_ctr_rec.counter_id;
           IF l_lausbb_rec.base_reading is not null then
              --Bug# 6374869
              --l_csi_ctr_rec.initial_reading := l_lausbb_rec.base_reading;
              l_counter_instance_rec.initial_reading := l_lausbb_rec.base_reading;
           End If;

           IF l_lausbb_rec.base_reading_uom is not null then
              --Bug# 6374869
              --l_csi_ctr_rec.uom_code := l_lausbb_rec.base_reading_uom;
              l_counter_instance_rec.uom_code := l_lausbb_rec.base_reading_uom;
           End If;

           If l_lausbb_rec.usage_item_id is not null then
              --Bug# 6374869
              --l_csi_ctr_rec.usage_item_id := l_lausbb_rec.usage_item_id;
              l_counter_instance_rec.usage_item_id := l_lausbb_rec.usage_item_id;
           End If;

           ---------------------------------------------------------------------
           --Bug# 6374869: R12 IB uptake replacing the call from CS_COUNTERS_PUB
           -- to CSI_COUNTER_PUB
           ---------------------------------------------------------------------
           --call the csi api to update counter
           /*--CS_COUNTERS_PUB.UPDATE_COUNTER
              --(p_api_version              => 1.0,
               --p_init_msg_list            => OKL_API.G_FALSE,
               --p_commit                   => OKL_API.G_FALSE,
               --x_return_status            => x_return_status,
               --x_msg_count                => x_msg_count,
               --x_msg_data                 => x_msg_data,
               --p_ctr_id                   => l_ctr_rec.counter_id,
               --p_object_version_number    => l_ctr_rec.object_version_number,
               --p_ctr_rec                  => l_csi_ctr_rec,
               --p_cascade_upd_to_instances => OKL_API.G_FALSE,
               --x_object_version_number    => l_object_version_number);
            */
               CSI_COUNTER_PUB.update_counter(
                   p_api_version	         => 1.0
                  ,p_init_msg_list	         => OKL_API.G_FALSE
                  ,p_commit		         => OKL_API.G_FALSE
                  ,p_validation_level            => fnd_api.g_valid_level_full
                  ,p_counter_instance_rec	 => l_counter_instance_rec
                  ,P_ctr_properties_tbl          => l_ctr_properties_tbl
                  ,P_counter_relationships_tbl   => l_counter_relationships_tbl
                  ,P_ctr_derived_filters_tbl     => l_ctr_derived_filters_tbl
                  ,P_counter_associations_tbl    => l_counter_associations_tbl
                  ,x_return_status               => x_return_status
                  ,x_msg_count                   => x_msg_count
                  ,x_msg_data                    => x_msg_data
                  );
           IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE ctr_exception;
           END IF;

        End Loop;
        CLOSE ctr_cur;
    END IF;
    CLOSE lausbb_cur;

    EXCEPTION
      WHEN ctr_exception THEN
        If ctr_cur%ISOPEN Then
           CLOSE ctr_cur;
        End If;

    WHEN OTHERS THEN
        If lausbb_cur%ISOPEN Then
           CLOSE lausbb_cur;
        End If;

        If ctr_cur%ISOPEN Then
           CLOSE ctr_cur;
        End If;

End Update_Counter_Instance;

------------------------------------------------------------------------------
-- PROCEDURE create_ubb_contract
--
--  This procedure creats Service Contract corresponding to Usage Base Line
--  for a given contract. It also registers error, if any and it is calling
--  modules responsibility to print error message from error stack
--
-- Calls:
--  get_top_line_id
-- Called By:
--  start process
------------------------------------------------------------------------------
  PROCEDURE create_ubb_contract (
                             p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             p_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                             x_chr_id         OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                           ) IS

   l_proc_name               VARCHAR2(35)          := 'CREATE_UBB_CONTRACT';
   l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_UBB_CONTRACT';
   l_api_version             CONSTANT NUMBER	   := 1;
   l_return_status           VARCHAR2(1)	   := OKC_API.G_RET_STS_SUCCESS;

   x_top_line_id             OKC_K_LINES_V.ID%TYPE;
   x_usage_item_id           CS_COUNTERS.USAGE_ITEM_ID%TYPE;

   l_usage_count             NUMBER := 0;
   l_link_asset_count        NUMBER := 0;
   l_ib_count                NUMBER := 0;
   l_counter_count           NUMBER := 0;
   l_customer_product_id     NUMBER;
   l_usage_id_prev           NUMBER := G_INIT_NUMBER;
   l_usage_item_id           NUMBER;

   l_counter_id              CS_COUNTERS.COUNTER_ID%TYPE;
   l_counter_uom_code        CS_COUNTERS.UOM_CODE%TYPE;
   x_header_rec              header_rec_type;

   --OKS record definition
   l_oks_header_rec           oks_Header_rec_type;
   l_oks_hdr_contact_tbl      oks_contact_tbl_type;
   l_oks_line_contact_tbl     oks_contact_tbl_type;
   l_oks_supp_contact_tbl     oks_contact_tbl_type;
   l_oks_hdr_salescredit_tbl  oks_salescredit_tbl_type;
   l_oks_line_salescredit_tbl oks_salescredit_tbl_type;
   l_oks_supp_salescredit_tbl oks_salescredit_tbl_type;
   l_oks_obj_articles_tbl     oks_obj_articles_tbl_type;
   l_oks_line_rec             oks_line_rec_type;
   l_oks_supp_line_rec        oks_line_rec_type;
   l_oks_covered_level_rec    oks_covered_level_rec_type;
   l_oks_price_attribs_rec    oks_pricing_attrb_rec_type;
   --l_oks_strm_hdr             oks_streamhdr_rec_type;
   l_oks_strm_lvl             oks_streamlvl_tbl_type;
   l_oks_contact_tbl          oks_contact_tbl_type;


   l_streamhdr_rec            oks_bill_sch.streamhdr_type;
   l_streamlvl_tbl            oks_bill_sch.streamlvl_tbl;

   x_oks_usage_line_id        NUMBER;
   x_oks_cp_line_id           NUMBER;
   x_oks_chr_id               NUMBER;

   x_rulv_rec                 rulv_rec_type;

   -- Check for 11.5.9 or 11.5.10 OKS version
   CURSOR check_oks_ver IS
   SELECT 1
   FROM   okc_class_operations
   WHERE  cls_code = 'SERVICE'
   AND    opn_code = 'CHECK_RULE';

   l_dummy NUMBER;
   l_oks_ver VARCHAR2(3);

   BEGIN -- main process starts here
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      l_usage_count   := 0;
      l_usage_id_prev := G_INIT_NUMBER;

      -- get contract header information
      get_contract_header(
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_chr_id,
                          x_header_rec    => x_header_rec
                         );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'STS Code : '||x_header_rec.sts_code);
      END IF;

      -- Create Service Contract Header only
      populate_header_rec(
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_header_rec     => x_header_rec,
                          x_oks_header_rec => l_oks_header_rec
                         );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'STS Code : '||l_oks_header_rec.sts_code);
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'contract: '||l_oks_header_rec.contract_number);
      END IF;

      OKS_CONTRACTS_PUB.create_contract_header(
                                               p_k_header_rec          => l_oks_header_rec,
                                               p_header_contacts_tbl   => l_oks_hdr_contact_tbl,
                                               p_header_sales_crd_tbl  => l_oks_hdr_salescredit_tbl,
                                               p_header_articles_tbl   => l_oks_obj_articles_tbl,
                                               x_chrid                 => x_oks_chr_id,
                                               x_return_status         => x_return_status,
                                               x_msg_count             => x_msg_count,
                                               x_msg_data              => x_msg_data
                                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_chr_id := x_oks_chr_id;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract Header Id: '||x_oks_chr_id);
      END IF;

      FOR usage_rec IN usage_csr (p_chr_id)
      LOOP
         -- Get all Rules associated with this line x_usage_item_id

         l_usage_count := l_usage_count + 1;

         g_usage_rec := usage_rec;
         -- create OKS Service line under the header created above

         populate_line_rec(
                           x_return_status       => x_return_status,
                           x_msg_count           => x_msg_count,
                           x_msg_data            => x_msg_data,
                           p_header_id           => x_header_rec.id,
                           p_line_rec            => g_usage_rec,
                           p_line_number         => l_usage_count,
                           p_customer_product_id => l_customer_product_id,
                           p_uom_code            => 'Ea', -- Not being used now
                           p_oks_header_id       => x_oks_chr_id,
                           x_usage_item_id       => l_usage_item_id,
                           x_oks_line_rec        => l_oks_line_rec
                          );

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         --
         -- Defaults from Contract Header
         --
         l_oks_line_rec.org_id          := x_header_rec.authoring_org_id;
         --Fix Bug# 3008830 :
         --l_oks_line_rec.organization_id := x_header_rec.authoring_org_id;
         l_oks_line_rec.organization_id := x_header_rec.inv_organization_id;

         OKS_CONTRACTS_PUB.create_service_line(
                                                p_k_line_rec            => l_oks_line_rec,
                                                p_contact_tbl           => l_oks_line_contact_tbl,
                                                p_line_sales_crd_tbl    => l_oks_line_salescredit_tbl,
                                                x_service_line_id       => x_oks_usage_line_id,
                                                x_return_status	        => x_return_status,
                                                x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data
                                               );

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKS Usage Line ID: '||x_oks_usage_line_id);
         END IF;

         l_link_asset_count := 0;
         FOR link_asset_rec IN link_asset_csr(p_chr_id,
                                              usage_rec.id)
         LOOP
            l_link_asset_count := l_link_asset_count + 1;

            get_top_line_id (
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             p_chr_id             => p_chr_id,
                             p_link_asset_line_id => link_asset_rec.id,
                             p_link_asset_line_no => link_asset_rec.line_number,
                             x_top_line_id        => x_top_line_id
                            );
            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

            l_ib_count := 0;
            FOR ib_rec IN ib_csr(p_chr_id,
                                 x_top_line_id)
            LOOP
               l_ib_count := l_ib_count + 1;

               l_counter_count := 0;
               FOR counter_rec IN counter_csr(p_chr_id,
                                              l_usage_item_id,
                                              ib_rec.id)
               LOOP

                  l_counter_count    := l_counter_count + 1;

                  l_counter_id       := counter_rec.counter_id;
                  l_counter_uom_code := counter_rec.uom_code;

                  populate_covered_rec(
                                    x_return_status     => x_return_status,
                                    x_msg_count         => x_msg_count,
                                    x_msg_data          => x_msg_data,
                                    p_oks_header_id     => x_oks_chr_id,
                                    p_counter_id        => l_counter_id,
                                    p_usage_line_id     => g_usage_rec.id,
                                    p_usage_start_date  => g_usage_rec.start_date,
                                    p_oks_usage_line_id => x_oks_usage_line_id,
                                    p_header_rec        => x_header_rec,
                                    x_oks_covered_rec   => l_oks_covered_level_rec
                                   );

                  IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

                  l_oks_covered_level_rec.currency_code    := x_header_rec.currency_code;
                  l_oks_covered_level_rec.product_end_date := ADD_MONTHS(x_header_rec.start_date, x_header_rec.term_duration) - 1;

                  IF (l_oks_covered_level_rec.uom_code IS NULL) THEN
                     l_oks_covered_level_rec.uom_code := l_counter_uom_code;
                  END IF;

                  OKS_CONTRACTS_PUB.create_covered_line(
                                                     p_k_covd_rec      => l_oks_covered_level_rec,
                                                     p_price_attribs   => l_oks_price_attribs_rec,
                                                     x_cp_line_id      => x_oks_cp_line_id,
                                                     x_return_status   => x_return_status,
                                                     x_msg_count       => x_msg_count,
                                                     x_msg_data        => x_msg_data
                                                    );
                  IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After covered line');
                  END IF;

               END LOOP; -- counter_csr

            END LOOP; -- ib_csr

         END LOOP; --link_asset_csr


/* Changed after OKS rule migration, see below
         -- Attach Billing Schedule
         l_streamhdr_rec.cle_id := x_oks_usage_line_id;
         l_streamhdr_rec.rule_information_category := 'SLH';
         l_streamhdr_rec.rule_information1         := 'T';

         l_streamlvl_tbl(1).rule_information1 := 10;
         l_streamlvl_tbl(1).rule_information2 := x_header_rec.start_date; -- start date of contract
         l_streamlvl_tbl(1).rule_information3 := x_header_rec.term_duration;
         l_streamlvl_tbl(1).rule_information4 := 1; --30.47222222; -- Average days in a month
         l_streamlvl_tbl(1).object1_id1       := x_rulv_rec.rule_information8; --'MTH'; --'DAY'; --'MTH';
         l_streamlvl_tbl(1).rule_information_category := 'SLL';


         oks_contracts_pub.create_bill_schedule(
                                                p_Strm_hdr_rec    => l_streamhdr_rec,
                                                p_strm_level_tbl  => l_streamlvl_tbl,
                                                p_invoice_rule_id => NULL,
                                                x_return_status   => x_return_status
                                               );

         -- Attach Billing Schedule

         l_streamlvl_tbl(1).cle_id            := x_oks_usage_line_id;
         l_streamlvl_tbl(1).dnz_chr_id        := x_oks_chr_id;
         l_streamlvl_tbl(1).sequence_no       := 10;
         l_streamlvl_tbl(1).uom_code          := 'MTH'; --'DAY'; --'MTH';
         l_streamlvl_tbl(1).start_date        := x_header_rec.start_date; -- start date of contract
         l_streamlvl_tbl(1).level_periods     := x_header_rec.term_duration;
         l_streamlvl_tbl(1).uom_per_period    := 1; --30.47222222; -- Average days in a month
*/
         -- Get LAUSBB information
         get_rule_information(
                              x_return_status             => x_return_status,
                              x_msg_count                 => x_msg_count,
                              x_msg_data                  => x_msg_data,
                              p_rule_information_category => 'LAUSBB',
                              p_rgd_code                  => 'LAUSBB',
                              p_jtot_object1_code         => 'OKX_USAGE',
                              p_chr_id                    => NULL,
                              p_cle_id                    => g_usage_rec.id,
                              x_rulv_rec                  => x_rulv_rec
                             );

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         l_oks_ver := '?';
         OPEN check_oks_ver;
         FETCH check_oks_ver INTO l_dummy;
         IF check_oks_ver%NOTFOUND THEN
            l_oks_ver := '9';
         ELSE
            l_oks_ver := '10';
         END IF;
         CLOSE check_oks_ver;

         IF (l_oks_ver = '10') THEN

            -- Fixed paramter assignment for Bug 4113684
            l_streamlvl_tbl(1).cle_id                    := x_oks_usage_line_id;
            l_streamlvl_tbl(1).rule_information_category := 'SLH';
            l_streamlvl_tbl(1).rule_information1         := 'T';

            l_streamlvl_tbl(1).Sequence_no    := 10;
            l_streamlvl_tbl(1).start_date     := x_header_rec.start_date; -- start date of contract
            l_streamlvl_tbl(1).level_periods  := x_rulv_rec.rule_information9; --x_header_rec.term_duration;
            l_streamlvl_tbl(1).uom_per_period := 1; --30.47222222; -- Average days in a month
            l_streamlvl_tbl(1).uom_code       := x_rulv_rec.rule_information8; --'MTH'; --'DAY'; --'MTH';
            --l_streamlvl_tbl(1).rule_information_category := 'SLL';

            oks_contracts_pub.create_bill_schedule(
                                                   p_billing_sch     => 'T',
                                                   p_strm_level_tbl  => l_streamlvl_tbl,
                                                   p_invoice_rule_id => NULL,
                                                   x_return_status   => x_return_status
                                                  );
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Bill Status : '||x_return_status);
            END IF;

            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

         ELSE -- oks_ver = 9

            -- Attach Billing Schedule
            l_streamhdr_rec.cle_id := x_oks_usage_line_id;
            l_streamhdr_rec.rule_information_category := 'SLH';
            l_streamhdr_rec.rule_information1         := 'T';

            l_streamlvl_tbl(1).rule_information1 := 10;
            l_streamlvl_tbl(1).rule_information2 := x_header_rec.start_date; -- start date of contract
            l_streamlvl_tbl(1).rule_information3 := x_rulv_rec.rule_information9; --x_header_rec.term_duration;
            l_streamlvl_tbl(1).rule_information4 := 1; --30.47222222; -- Average days in a month
            l_streamlvl_tbl(1).object1_id1       := x_rulv_rec.rule_information8; --'MTH'; --'DAY'; --'MTH';
            l_streamlvl_tbl(1).rule_information_category := 'SLL';


            oks_contracts_pub.create_bill_schedule(
                                                   p_Strm_hdr_rec    => l_streamhdr_rec,
                                                   p_strm_level_tbl  => l_streamlvl_tbl,
                                                   p_invoice_rule_id => NULL,
                                                   x_return_status   => x_return_status
                                                  );
         END IF;

         -- check the presence of All lines in proper structure
         IF (l_link_asset_count = 0) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_OKL_NO_LINK_ASSET_LINE
                               );
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

         IF (l_ib_count = 0) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_OKL_NO_IB_LINE
                               );
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

         IF (l_counter_count = 0) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_OKL_NO_COUNTER_INSTANCE
                               );
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

         -- Link OKS Usage line with that of OKL
         link_oks_line(
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data,
                       p_okl_header_id     => p_chr_id,
                       p_okl_usage_line_id => usage_rec.id,         -- OKL Usage Line ID
                       p_oks_usage_line_id => x_oks_usage_line_id   -- OKS Usage Line ID
                      );

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Link Line Done');
         END IF;

         --
         -- Update Counter Instance at OKS Usage Line
         -- Fix Bug# 2498796
         --
         update_counter_instance(
	                         x_return_status     => x_return_status,
	                         x_msg_count         => x_msg_count,
	                         x_msg_data          => x_msg_data,
                                 p_okl_usage_line_id => usage_rec.id,
                                 p_oks_usage_line_id => x_oks_usage_line_id);

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

      END LOOP; -- usage_csr

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      IF (l_usage_count = 0) THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_OKL_NO_USAGE_LINE
                            );
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;


      -- Link OKS Header, create above, with that of OKL
      link_oks_header(
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data,
                       p_okl_header_id     => p_chr_id,
                       p_oks_header_id     => x_chr_id
                      );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Link Header Done');
      END IF;


      -- End activity

      OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
		           x_msg_data	=> x_msg_data);

   Exception
      when OKC_API.G_EXCEPTION_ERROR then

         IF counter_csr%ISOPEN THEN
            CLOSE counter_csr;
         END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);


      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then

         IF counter_csr%ISOPEN THEN
            CLOSE counter_csr;
         END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then

         IF counter_csr%ISOPEN THEN
            CLOSE counter_csr;
         END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_ubb_contract;

------------------------------------------------------------------------------
-- PROCEDURE link_oks_header
--
--  This procedure Links OKS Contract Header with that of OKL. It is called
--  after successful creation of one OKS contract from OKl Usage line
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE link_oks_header(
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_msg_count         OUT NOCOPY NUMBER,
                            x_msg_data          OUT NOCOPY VARCHAR2,
                            p_okl_header_id     IN  OKC_K_HEADERS_V.ID%TYPE,
                            p_oks_header_id     IN  OKC_K_HEADERS_V.ID%TYPE
                           ) IS
   l_proc_name       VARCHAR2(35) := 'LINK_OKS_HEADER';
   l_crjv_rec        crjv_rec_type;
   x_crjv_rec        crjv_rec_type;
   oks_header_failed EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      l_crjv_rec.chr_id            := p_okl_header_id;
      l_crjv_rec.rty_code          := 'OKLUBB';
      l_crjv_rec.object1_id1       := p_oks_header_id;
      l_crjv_rec.object1_id2 := '#';
      l_crjv_rec.jtot_object1_code := 'OKL_SERVICE';

      OKC_K_REL_OBJS_PUB.create_row (
                                     p_api_version => 1.0,
                                     p_init_msg_list => OKC_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_crjv_rec      => l_crjv_rec,
                                     x_crjv_rec      => x_crjv_rec
                                    );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE oks_header_failed;
      END IF;

   EXCEPTION
      WHEN oks_header_failed THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
   END link_oks_header;

------------------------------------------------------------------------------
-- PROCEDURE create_ubb_contract
--
--  This procedure Links OKS Contract service line with that of OKL (Usage Line)
--  after successful creation of one OKS service line
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE link_oks_line(
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2,
                          p_okl_header_id     IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_okl_usage_line_id IN  OKC_K_LINES_V.ID%TYPE,
                          p_oks_usage_line_id IN  OKC_K_LINES_V.ID%TYPE
                         ) IS
  CURSOR item_csr (p_cle_id NUMBER) IS
  SELECT id
  FROM   okc_k_items_v
  WHERE  cle_id            = p_cle_id
  AND    dnz_chr_id        = p_okl_header_id;
  --AND    jtot_object1_code = 'OKL_USAGE';

  l_proc_name     VARCHAR2(35) := 'LINK_OKS_LINE';
  oks_line_failed EXCEPTION;
  l_cimv_rec      cimv_rec_type;
  x_cimv_rec      cimv_rec_type;
  l_item_line_id  NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    OPEN item_csr(p_okl_usage_line_id);
    FETCH item_csr INTO l_item_line_id;

    IF item_csr%NOTFOUND THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_OKL_NO_ITEM_LINK
                          );
       RAISE oks_line_failed;
    END IF;
    CLOSE item_csr;

    l_cimv_rec.id          := l_item_line_id;
    l_cimv_rec.object1_id1 := p_oks_usage_line_id;
    l_cimv_rec.object1_id2 := '#';

    l_cimv_rec.jtot_object1_code := 'OKL_USAGE';   --Rviriyal Added for bug 6270667
----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     okl_la_validation_util_pvt.VALIDATE_STYLE_JTOT (p_api_version    => 1.0,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => l_cimv_rec.jtot_object1_code,
                                                          p_id1            => l_cimv_rec.object1_id1,
                                                          p_id2            => l_cimv_rec.object1_id2);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE oks_line_failed;
    END IF;

----  Changes End

    OKC_CONTRACT_ITEM_PUB.update_contract_item(
                                               p_api_version   => 1.0,
                                               p_init_msg_list => OKC_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_cimv_rec      => l_cimv_rec,
                                               x_cimv_rec      => x_cimv_rec
                                              );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE oks_line_failed;
    END IF;

  EXCEPTION

    WHEN oks_line_failed THEN

       IF item_csr%ISOPEN THEN
         CLOSE item_csr;
       END IF;

       x_return_status := OKC_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
  END link_oks_line;

END OKL_UBB_INTEGRATION_PVT;

/
