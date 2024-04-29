--------------------------------------------------------
--  DDL for Package Body OKL_BLK_AST_UPD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BLK_AST_UPD_PVT" AS
/* $Header: OKLRBAUB.pls 120.18.12010000.3 2010/03/25 12:22:08 smadhava ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;


  SUBTYPE instance_rec             IS CSI_DATASTRUCTURES_PUB.instance_rec;
  SUBTYPE extend_attrib_values_tbl IS CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
  SUBTYPE party_tbl                IS CSI_DATASTRUCTURES_PUB.party_tbl;
  SUBTYPE account_tbl              IS CSI_DATASTRUCTURES_PUB.party_account_tbl;
  SUBTYPE pricing_attribs_tbl      IS CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
  SUBTYPE organization_units_tbl   IS CSI_DATASTRUCTURES_PUB.organization_units_tbl;
  SUBTYPE instance_asset_tbl       IS CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
  SUBTYPE transaction_rec          IS CSI_DATASTRUCTURES_PUB.transaction_rec;
  SUBTYPE id_tbl                   IS CSI_DATASTRUCTURES_PUB.id_tbl;

  l_instance_rec           instance_rec;
  l_ext_attrib_values_tbl  extend_attrib_values_tbl;
  l_party_tbl              party_tbl;
  l_account_tbl            account_tbl;
  l_pricing_attrib_tbl     pricing_attribs_tbl;
  l_org_assignments_tbl    organization_units_tbl;
  l_asset_assignment_tbl   instance_asset_tbl;
  l_txn_rec                transaction_rec;
  l_instance_id_lst        id_tbl;


  PROCEDURE create_txl_itm_insts(
    p_api_version         IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2,
    p_date_from           IN   DATE,
    p_itiv_rec            IN   itiv_rec_type,
    p_request_id          IN   NUMBER,
    x_trxv_rec            OUT  NOCOPY trxv_rec_type,
    x_itiv_rec            OUT  NOCOPY itiv_rec_type);

  PROCEDURE Create_asset_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type) ;

  PROCEDURE Update_asset_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type);

 FUNCTION get_try_id(p_try_name  IN  OKL_TRX_TYPES_V.NAME%TYPE,
                     x_try_id    OUT NOCOPY OKC_LINE_STYLES_V.ID%TYPE)
 RETURN VARCHAR2 ;

-----------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_trx_rec
  --Purpose               : Gets source transaction record for IB interface
  --Modification History  :
  --15-Jun-2001    ashish.singh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
  PROCEDURE get_trx_rec
           (p_api_version                  IN  NUMBER,
            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            p_cle_id                       IN  NUMBER,
            p_transaction_type             IN  VARCHAR2,
            x_trx_rec                      OUT NOCOPY transaction_rec) IS

     l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_TRX_REC';
     l_api_version           CONSTANT NUMBER    := 1.0;

--Following cursor assumes that a transaction type called
--'OKL LINE ACTIVATION' and 'OKL SPLIT ASSET' will be seeded in IB

     -- Bug# 8459840 - Cursor changed to retrieve from base tables
     -- commenting the code below and added the changed cursor.
     /*
     Cursor okl_trx_type_curs(p_transaction_type IN VARCHAR2)is
            select transaction_type_id
            from   CS_TRANSACTION_TYPES_V
            where  Name = p_transaction_type;
     */
	 -- Note: Not using Name column in tt as it can be null.
     Cursor okl_trx_type_curs(p_transaction_type IN VARCHAR2)is
       SELECT tt.transaction_type_id
         FROM  cs_transaction_types_b tt,
               cs_transaction_types_tl ttl
        WHERE  tt.transaction_type_id = ttl.transaction_type_id
           AND ttl.language = 'US'
           AND ttl.NAME = p_transaction_type;
     -- end bug 8459840.

     l_trx_type_id NUMBER;
 begin
    -- Bug# 8459840 - Start actvity
    x_return_status := OKC_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);
    --Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- end bug 8459840

     open okl_trx_type_curs(p_transaction_type);
        Fetch okl_trx_type_curs
        into  l_trx_type_id;
        If okl_trx_type_curs%NotFound Then
           --OKL LINE ACTIVATION not seeded as a source transaction in IB
           Raise OKC_API.G_EXCEPTION_ERROR;
        End If;
     close okl_trx_type_curs;

     --Assign transaction Type id to seeded value in cs_lookups
     x_trx_rec.transaction_type_id := l_trx_type_id;

     --Assign Source Line Ref id to contract line id of IB instance line
     x_trx_rec.source_line_ref_id := p_cle_id;
     x_trx_rec.transaction_date := SYSDATE;
     x_trx_rec.source_transaction_date := sysdate;

    Exception
    When OKC_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
   );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END get_trx_rec;

  PROCEDURE update_location(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
       p_loc_rec                        IN  OKL_LOC_REC_TYPE,
       x_return_status                  OUT NOCOPY VARCHAR2,
       x_msg_count                      OUT NOCOPY NUMBER,
       x_msg_data                       OUT NOCOPY VARCHAR2) IS

    CURSOR c_free_form2(p_parent_line_id IN NUMBER) IS
    SELECT  A.ID
    FROM    OKC_K_LINES_V A,
           OKC_LINE_STYLES_B B
    WHERE   A.CLE_ID = p_parent_line_id
    AND     A.LSE_ID = B.ID
    AND     B.LTY_CODE = 'FREE_FORM2';

    CURSOR c_inst_item(p_line_id  IN  NUMBER) IS
      SELECT  A.ID,
              A.DNZ_CHR_ID
      FROM    OKC_K_LINES_V A,
           OKC_LINE_STYLES_B B
      WHERE   A.CLE_ID = p_line_id
      AND     A.LSE_ID = B.ID
      AND     B.LTY_CODE = 'INST_ITEM';

    CURSOR c_items(p_inst_itm_id IN NUMBER) is
   SELECT  *
   FROM    OKC_K_ITEMS_V
   WHERE   CLE_ID = p_inst_itm_id
   AND     JTOT_OBJECT1_CODE = 'OKX_IB_ITEM';


   CURSOR  c_ib_inst(p_object1_id1  IN VARCHAR2,p_object1_id2 IN VARCHAR2) IS
   SELECT  *
   FROM    OKX_INSTALL_ITEMS_V A
   WHERE   ID1 = p_object1_id1
   AND     ID2 = p_object1_id2;

--RKUTTIYA added for bug: 3569441
   CURSOR c_loc_typecode(p_instance_id IN NUMBER) IS
   SELECT LOCATION_TYPE_CODE,
          INSTALL_LOCATION_TYPE_CODE
   FROM csi_item_instances
   WHERE INSTANCE_ID = p_instance_id;

--Added by rkuttiya for Sales Tax project
  CURSOR c_bill_upfront_tax(p_contract_id IN NUMBER,
                            p_line_id     IN NUMBER)
  IS
  SELECT RUL.RULE_INFORMATION11
  FROM OKC_RULES_B RUL,
       OKC_RULE_GROUPS_B RGP
  WHERE RUL.RGP_ID = RGP.ID
  AND RGP.DNZ_CHR_ID =  p_contract_id
  AND RGP.CLE_ID = p_line_id
  AND RUL.RULE_INFORMATION_CATEGORY = 'LAASTX'
  AND RGP.RGD_CODE = 'LAASTX';

  CURSOR c_asset_upfront_tax(p_contract_id IN NUMBER)
  IS
  SELECT RUL.RULE_INFORMATION1
  FROM   OKC_RULES_B RUL,
         OKC_RULE_GROUPS_B RGP
  WHERE RUL.RGP_ID = RGP.ID
  AND RGP.DNZ_CHR_ID =  p_contract_id
  AND RUL.RULE_INFORMATION_CATEGORY = 'LASTPR'
  AND RGP.RGD_CODE = 'LAHDTX';

  -- dcshanmu bug 6673102 start
  CURSOR c_upfront_tax_calc(p_contract_id IN NUMBER)
  IS
  SELECT 'X'
  FROM OKL_TAX_SOURCES
  WHERE KHR_ID = p_contract_id
  AND TAX_CALL_TYPE_CODE = 'UPFRONT_TAX'
  AND TAX_LINE_STATUS_CODE = 'ACTIVE';
  -- dcshanmu bug 6673102 end
--
  --asawanka added for ebtax start
  CURSOR c_get_entered_alc_trx(cp_kle_id IN NUMBER)
  IS
  SELECT 'X'
  FROM OKL_TRX_ASSETS TRX,
    OKL_TXL_ITM_INSTS TXL,
    OKL_TRX_TYPES_B TRY
  WHERE TRX.ID = TXL.TAS_ID
    AND TRX.TRY_ID = TRY.ID
    AND TRY.TRX_TYPE_CLASS = 'ASSET_RELOCATION'
    AND TRX.TSU_CODE = 'ENTERED'
    AND TRX.TAS_TYPE = 'ALG'
    AND TXL.dnz_cle_id = cp_kle_id;

  CURSOR c_get_chr_id (p_kle_id IN NUMBER) IS
   SELECT kle.dnz_chr_id,
          khr.org_id,
          khr.currency_code
   FROM okc_k_lines_v kle,
        okc_k_headers_all_b khr
   WHERE kle.id = p_kle_id
   AND  kle.dnz_chr_id = khr.id;

 CURSOR check_item_csr (p_line_id IN NUMBER) IS      -- p_line_id is FREE_FORM1
   SELECT mtl.serial_number_control_code
   FROM   okc_k_lines_b line,
                  okc_line_styles_b style,
                  okc_k_items kitem,
                  mtl_system_items mtl
   WHERE  line.lse_id                    = style.id
   AND    style.lty_code                 = 'ITEM'
   AND    line.id                        = kitem.cle_id
   AND    kitem.jtot_object1_code        = 'OKX_SYSITEM'
   AND    kitem.object1_id1              = mtl.inventory_item_id
   AND    kitem.object1_id2              = TO_CHAR(mtl.organization_id)
   AND    line.cle_id                    = p_line_id;

  CURSOR c_get_ast_instances(p_parent_line_id IN NUMBER) IS
  SELECT  count(*)
  FROM    okc_k_lines_v okcl,
          okc_line_styles_v lse
  WHERE   okcl.cle_id = p_parent_line_id
  AND     okcl.lse_id = lse.id
  AND     lse.lty_code = 'FREE_FORM2';

  l_entered  VARCHAR2(3);
  --asawanka ebtax changes end
--added for bug:3569441
  l_inst_loc_type_code   VARCHAR2(30);
  l_loc_type_code        VARCHAR2(30);

  l_c_ib_inst             c_ib_inst%ROWTYPE;
  l_ctr                   NUMBER;
  l_obj_no                NUMBER;

  l_trqv_rec              okl_trx_requests_pub.trqv_rec_type;
  x_trqv_rec              okl_trx_requests_pub.trqv_rec_type;
  l_org_id                NUMBER;
  l_currency_code         VARCHAR2(30);
  l_try_id                NUMBER;
  l_serialized_yn         VARCHAR2(3);
  l_count                 mtl_system_items.serial_number_control_code%TYPE;
  l_ser_count             NUMBER;

    l_trxv_rec             trxv_rec_type;
    lm_trxv_rec            trxv_rec_type;
    l_itiv_rec             itiv_rec_type;
    l_out_rec              itiv_rec_type;
    l_rulv_rec             okl_rule_pub.rulv_rec_type;
    l_rulv_empty_rec           okl_rule_pub.rulv_rec_type;

    l_api_name              CONSTANT VARCHAR2(30)  := 'UPDATE_LOCATION';
    l_chr_id                 NUMBER;
    l_parent_line_id        NUMBER;
    l_loc_id                NUMBER;
    l_party_site_id         NUMBER;
    l_newsite_id1           NUMBER;
    l_newsite_id2           VARCHAR2(1);
    l_oldsite_id1           NUMBER;
    l_oldsite_id2           VARCHAR2(1);
    l_bill_upfront_tax      VARCHAR2(450);
    l_asset_upfront_tax     VARCHAR2(450);
    l_tax_call_type         VARCHAR2(30);
    l_alc_final_call        VARCHAR2(1) := 'N';
    -- dcshanmu bug 6673102 start
    l_upfront_tax_calc  VARCHAR2(1);
    -- dcshanmu bug 6673102 end
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_BLK_AST_UPD_PVT.Update_Location','Begin(+)');
  END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Input variables in Update Location');
   END IF;
--Print Input Variables
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_parent_line_id :'||p_loc_rec.parent_line_id);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_loc_id :'||p_loc_rec.loc_id);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_party_site_id :'||p_loc_rec.party_site_id);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_newsite_id1 :'||p_loc_rec.newsite_id1);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_newsite_id2 :'||p_loc_rec.newsite_id2);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_oldsite_id1 :'||p_loc_rec.oldsite_id1);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_oldsite_id2 :'||p_loc_rec.oldsite_id2);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_date_from   :'||p_loc_rec.date_from);
   END IF;

    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  --asawanka ebtax changes start

   OPEN c_get_entered_alc_trx(p_loc_rec.parent_line_id);
   FETCH c_get_entered_alc_trx INTO l_entered;
   IF c_get_entered_alc_trx%FOUND THEN
     OKL_API.set_message( p_app_name      => 'OKL',
                          p_msg_name      => 'OKL_ASTLOC_CHNG_NA_ENT');
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OPEN c_get_chr_id(p_loc_rec.parent_line_id);
   FETCH c_get_chr_id INTO l_chr_id,l_org_id ,l_currency_code;
   CLOSE c_get_chr_id;

   OPEN c_bill_upfront_tax(l_chr_id,p_loc_rec.parent_line_id);
   FETCH c_bill_upfront_tax INTO l_bill_upfront_tax;
   CLOSE c_bill_upfront_tax;

   IF l_bill_upfront_tax IS NOT NULL THEN
     IF l_bill_upfront_tax <> 'BILLED' THEN
        OKL_API.set_message( p_app_name      => 'OKL',
                          p_msg_name      => 'OKL_ASTLOC_CHNG_NA_AST');
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
   ELSE
     -- dcshanmu bug 6673102 start
     OPEN c_upfront_tax_calc(l_chr_id);
     FETCH c_upfront_tax_calc INTO l_upfront_tax_calc;
     IF (c_upfront_tax_calc%FOUND) THEN
     -- dcshanmu bug 6673102 end
	OPEN c_asset_upfront_tax(l_chr_id);
	FETCH c_asset_upfront_tax INTO l_asset_upfront_tax;
	CLOSE c_asset_upfront_tax;
	IF l_asset_upfront_tax IS NULL OR l_asset_upfront_tax <> 'BILLED' THEN
	OKL_API.set_message( p_app_name      => 'OKL',
			    p_msg_name      => 'OKL_ASTLOC_CHNG_NA_KHR');
	RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
     -- dcshanmu bug 6673102 start
     END IF;
     CLOSE c_upfront_tax_calc;
     -- dcshanmu bug 6673102 end
   END IF;

   OPEN check_item_csr(p_loc_rec.parent_line_id);
   FETCH check_item_csr INTO l_count;
   CLOSE check_item_csr;

   IF l_count = 1 THEN
     l_serialized_yn := 'N';
   ELSE
     l_serialized_yn := 'Y';
   END IF;

   IF (l_serialized_yn = 'Y') THEN
     OPEN c_get_ast_instances(p_loc_rec.parent_line_id);
     FETCH c_get_ast_instances INTO l_ser_count;
     CLOSE c_get_ast_instances;
   END IF;

   x_return_status := get_try_id(p_try_name => G_TRY_NAME,
                                  x_try_id   => l_try_id);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_trqv_rec.request_status_code :=  'ENTERED';
   l_trqv_rec.request_type_code := 'ASSET_RELOCATION';

   l_trqv_rec.dnz_khr_id :=  l_chr_id;
   l_trqv_rec.org_id := l_org_id;
   l_trqv_rec.legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_chr_id);
   l_trqv_rec.currency_code := l_currency_code;
   l_trqv_rec.start_date := p_loc_rec.date_from;
   l_trqv_rec.try_id   := l_try_id;
   okl_trx_requests_pub.insert_trx_requests(p_api_version     => p_api_version,
                                            p_init_msg_list   => p_init_msg_list,
                                            x_return_status   => x_return_status,
                                            x_msg_count       => x_msg_count,
                                            x_msg_data        => x_msg_data,
                                            p_trqv_rec        => l_trqv_rec,
                                            x_trqv_rec        => x_trqv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   G_CTR := 1;
   --asawanka ebtax changes end
    FOR l_c_free_form2 in c_free_form2(p_loc_rec.parent_line_id) LOOP
      FOR l_c_inst_item IN c_inst_item(l_c_free_form2.id) LOOP
          l_chr_id := l_c_inst_item.dnz_chr_id;
        FOR l_c_item IN c_items(l_c_inst_item.id) LOOP
          OPEN c_ib_inst(l_c_item.object1_id1,l_c_item.object1_id2);
            FETCH c_ib_inst INTO l_c_ib_inst;
            IF c_ib_inst%FOUND THEN

                  ---Creating records in Okl_txl_itm_insts

                  l_itiv_rec.kle_id                := l_c_item.cle_id;
                  l_itiv_rec.dnz_cle_id            := p_loc_rec.parent_line_id;
                  l_itiv_rec.line_number           := G_CTR;
                  l_itiv_rec.instance_number_ib    := l_c_ib_inst.name;
                  l_itiv_rec.object_id1_new        := p_loc_rec.newsite_id1;
                  l_itiv_rec.object_id2_new        := p_loc_rec.newsite_id2;
                  l_itiv_rec.jtot_object_code_new  := 'OKX_PARTSITE';

                  l_itiv_rec.object_id1_old        := p_loc_rec.oldsite_id1;
                  l_itiv_rec.object_id2_old        := p_loc_rec.oldsite_id2;
                  l_itiv_rec.jtot_object_code_old  := 'OKX_PARTSITE';
                  l_itiv_rec.inventory_item_id     := l_c_ib_inst.inventory_item_id;

              /** populate the Mandatory parameters **/
                  l_itiv_rec.CREATED_BY            := FND_API.G_MISS_NUM;
                  l_itiv_rec.CREATION_DATE         := FND_API.G_MISS_DATE;
                  l_itiv_rec.LAST_UPDATED_BY       := FND_API.G_MISS_NUM;
                  l_itiv_rec.LAST_UPDATE_DATE      := FND_API.G_MISS_DATE;
                  l_itiv_rec.LAST_UPDATE_LOGIN     := FND_API.G_MISS_NUM;
                 create_txl_itm_insts(p_api_version     => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_date_from      => p_loc_rec.date_from,
                                       p_itiv_rec       => l_itiv_rec,
                                       p_request_id     => x_trqv_rec.id,
                                       x_trxv_rec       => l_trxv_rec,
                                       x_itiv_rec       => l_out_rec
                                      );


                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                  IF l_serialized_yn = 'Y' AND G_CTR = 1 THEN
                    IF G_CTR = l_ser_count  THEN
                      l_alc_final_call := 'Y';
                    ELSE
                      l_alc_final_call := null;
                    END IF;
                  ELSIF l_serialized_yn = 'Y' AND (G_CTR > 1 AND G_CTR < l_ser_count) THEN
                    l_alc_final_call := 'N';
                  ELSIF l_serialized_yn = 'Y' AND G_CTR = l_ser_count THEN
                    l_alc_final_call := 'Y';
                  END IF;

                  --asawanka ebtax changes start
                  OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
                              p_api_version            =>          p_api_version,
                              p_init_msg_list          =>          p_init_msg_list,
                              x_return_status          =>          x_return_status,
                              x_msg_count              =>          x_msg_count,
                              x_msg_data               =>          x_msg_data,
                              p_source_trx_id          =>          l_trxv_rec.id,
                              p_source_trx_name        =>          G_TRY_NAME,
                              p_source_table           =>          G_TRX_TABLE,
                              p_tax_call_type          =>          'ESTIMATED' ,
                              p_request_id             =>          x_trqv_rec.id,
                              p_serialized_asset       =>          l_serialized_yn,
                              p_alc_final_call         =>          l_alc_final_call);

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return status from Tax API '||x_return_status);
                  END IF;

                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

    END IF; -- If _ib_inst found
    CLOSE c_ib_inst;
  END LOOP;
 END LOOP;
 G_CTR := G_CTR + 1;
END LOOP;

 OKL_API.END_ACTIVITY (x_msg_count,
                       x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END update_location;

  PROCEDURE create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_date_from                    IN DATE,
    p_itiv_rec                     IN itiv_rec_type,
    p_request_id                   IN NUMBER,
    x_trxv_rec                     OUT NOCOPY trxv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type) IS

    l_trxv_rec               trxv_rec_type;
    lm_itiv_rec               itiv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXL_ITM_INSTS';
  BEGIN
    x_return_status   := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Create New Header record and new Line record
    -- Before creating Header record
    -- we should make sure atleast the required record is given

    l_trxv_rec.tas_type            := 'ALG';

    x_return_status := get_try_id(p_try_name => G_TRY_NAME,
                                  x_try_id   => l_trxv_rec.try_id);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_trxv_rec.tsu_code            := 'ENTERED';
    l_trxv_rec.date_trans_occurred := p_date_from;
    l_trxv_rec.legal_entity_id     := OKL_LEGAL_ENTITY_UTIL.get_khr_line_le_id(p_itiv_rec.kle_id);  --dkagrawa added to derive le_id from kle_id
    l_trxv_rec.req_asset_id        := p_request_id;
    -- Now creating the new header record
    Create_asset_header(p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_trxv_rec       => l_trxv_rec,
                        x_trxv_rec       => x_trxv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       l_trxv_rec                     :=  x_trxv_rec;
       l_trxv_rec.tsu_code            := 'ERROR';
       Update_asset_header(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_trxv_rec       => l_trxv_rec,
                           x_trxv_rec       => x_trxv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       l_trxv_rec                     :=  x_trxv_rec;
       l_trxv_rec.tsu_code            := 'ERROR';


       Update_asset_header(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_trxv_rec       => l_trxv_rec,
                           x_trxv_rec       => x_trxv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are creating the new line record
    lm_itiv_rec := p_itiv_rec;
    lm_itiv_rec.tas_id          := x_trxv_rec.id;
    IF (lm_itiv_rec.tal_type = OKL_API.G_MISS_CHAR OR
       lm_itiv_rec.tal_type IS NUll) THEN
       lm_itiv_rec.tal_type       := 'AGL';
    END IF;


    IF G_CTR > 1 THEN
       lm_itiv_rec.mfg_serial_number_yn := 'Y';
    ELSE
       lm_itiv_rec.mfg_serial_number_yn := 'N';
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue

    OKL_TXL_ITM_INSTS_PUB.create_txl_itm_insts(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_iipv_rec       => lm_itiv_rec,
                       x_iipv_rec       => x_itiv_rec);



    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_txl_itm_insts;

  PROCEDURE Create_asset_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSET_HEADER';
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => p_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_asset_header;

  PROCEDURE Update_asset_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSET_HEADER';
  BEGIN
    x_return_status        := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => p_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_asset_header;

  FUNCTION get_try_id(p_try_name  IN  OKL_TRX_TYPES_V.NAME%TYPE,x_try_id    OUT NOCOPY OKC_LINE_STYLES_V.ID%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR c_get_try_id(p_try_name  OKL_TRX_TYPES_V.NAME%TYPE) IS
    SELECT id
    FROM OKL_TRX_TYPES_TL
    WHERE upper(name) = upper(p_try_name)
    AND language = 'US';
 BEGIN
   IF (p_try_name = OKC_API.G_MISS_CHAR) OR
       (p_try_name IS NULL) THEN
       -- store SQL error message on message stack
       OKC_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Try Name');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    OPEN c_get_try_id(p_try_name);
    FETCH c_get_try_id INTO x_try_id;
    IF c_get_try_id%NOTFOUND THEN
       OKC_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_PARENT_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Try Name');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_try_id;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
     IF c_get_try_id%ISOPEN THEN
        CLOSE c_get_try_id;
     END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_try_id%ISOPEN THEN
        CLOSE c_get_try_id;
     END IF;
     RETURN(x_return_status);
 END get_try_id;

 /*========================================================================
 | PUBLIC PROCEDURE Create_Tax_Schedule
 |
 | DESCRIPTION
 |      This procedure will query all streams for a contract, pass the stream amounts to
 |      the Global Tax Engine for calculating tax for each of the amounts and create tax schedules in
 |      OKL_TAX_LINES. This procedure takes parameters in the table structure.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and cuntions which
 |      this package calls.
 |
 | PARAMETERS
 |      p_contract_id    IN      Contract Identifier
 |      p_trx_date       IN      Schedule Request Date
 |      p_date_from      IN      Date From
 |      p_date_to        IN      Date To
 |      x_return_status  OUT     Return Status
 |
 | KNOWN ISSUES
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-MAY-2004           RKUTTIYA             Created
 |
 *=======================================================================*/

 PROCEDURE update_location(p_api_version                    IN  NUMBER,
                           p_init_msg_list                      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           p_loc_tbl                        IN  okl_loc_tbl_type,
                           x_return_status                      OUT NOCOPY VARCHAR2,
                           x_msg_count                          OUT NOCOPY NUMBER,
                           x_msg_data                           OUT NOCOPY VARCHAR2)
IS
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name              CONSTANT VARCHAR2(30) := 'Update_Location';
   l_api_version           CONSTANT NUMBER := 1;
   l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   i                       NUMBER;
BEGIN
  l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);
    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;
    -- Make sure PL/SQL table has records in it before passing
    IF (p_loc_tbl.COUNT > 0) THEN
      i := p_loc_tbl.FIRST;
      --Print Input Variables
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
            'parent_line_id :'||p_loc_tbl(i).parent_line_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
           'loc_id :'||p_loc_tbl(i).loc_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
           'party_site_id :'||p_loc_tbl(i).party_site_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
           'newsite_id1 :'||p_loc_tbl(i).newsite_id1);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
           'newsite_id2 :'||p_loc_tbl(i).newsite_id2);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
           'oldsite_id1 :'||p_loc_tbl(i).oldsite_id1);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
           'oldsite_id2 :'||p_loc_tbl(i).oldsite_id2);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_BLK_AST_UPD_PVT.Update_Location',
           'date_from :'||p_loc_tbl(i).date_from);
      END IF;
      LOOP
        update_location (
                  p_api_version                  => l_api_version,
                  p_init_msg_list                => OKL_API.G_FALSE,
                  x_return_status                => x_return_status,
                  x_msg_count                    => x_msg_count,
                  x_msg_data                     => x_msg_data,
                  p_loc_rec                      => p_loc_tbl(i));
        -- store the highest degree of error
                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;
        EXIT WHEN (i = p_loc_tbl.LAST);
        i := p_loc_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;
    END IF;
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;
   OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_BLK_AST_UPD_PVT.Update_Location ','End(-)');
  END IF;
EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_BLK_AST_UPD_PVT.Update_Location ',
                  'EXCEPTION :'|| 'OKL_API.G_EXCEPTION_ERROR');
   END IF;
   x_return_status := OKL_API.G_RET_STS_ERROR;
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_BLK_AST_UPD_PVT.Update_Location ',
                  'EXCEPTION :'|| 'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
   END IF;
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_BLK_AST_UPD_PVT.Update_Location ',
                  'EXCEPTION :'||sqlerrm);
   END IF;
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- unexpected error
   OKL_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
END Update_Location;

  --Bug# 6619311 Start
  -- Start of comments
  --
  -- Procedure Name  : populate_account_api_data
  -- Description     :  This is a private procedure used by create_upfront_tax_accounting
  -- to populate accounting data tables prior to calling central OKL a/c API
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE populate_account_data(
                    p_api_version        IN  NUMBER
                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                    ,p_trxh_out_rec      IN  Okl_Trx_Contracts_Pvt.tcnv_rec_type
                    ,p_tclv_tbl          IN  okl_trx_contracts_pvt.tclv_tbl_type
                    ,p_acc_gen_tbl       IN  OUT NOCOPY okl_account_dist_pvt.ACC_GEN_TBL_TYPE
                    ,p_tmpl_identify_tbl IN  OUT NOCOPY okl_account_dist_pvt.tmpl_identify_tbl_type
                    ,p_dist_info_tbl     IN  OUT NOCOPY okl_account_dist_pvt.dist_info_tbl_type
                    ,x_return_status     OUT NOCOPY VARCHAR2
                    ,x_msg_count         OUT NOCOPY NUMBER
                    ,x_msg_data          OUT NOCOPY VARCHAR2)
  IS

  CURSOR fnd_pro_csr
  IS
  SELECT mo_global.get_current_org_id() l_fnd_profile
  FROM   dual;

  fnd_pro_rec fnd_pro_csr%ROWTYPE;

  CURSOR ra_cust_csr
  IS
  SELECT cust_trx_type_id l_cust_trx_type_id
  FROM   ra_cust_trx_types
  WHERE  name = 'Invoice-OKL';

  ra_cust_rec ra_cust_csr%ROWTYPE;

  CURSOR salesP_csr
  IS
  SELECT  ct.object1_id1           id
         ,chr.scs_code             scs_code
  FROM   okc_contacts              ct,
         okc_contact_sources       csrc,
         okc_k_party_roles_b       pty,
         okc_k_headers_b           chr
  WHERE  ct.cpl_id               = pty.id
  AND    ct.cro_code             = csrc.cro_code
  AND    ct.jtot_object1_code    = csrc.jtot_object_code
  AND    ct.dnz_chr_id           = chr.id
  AND    pty.rle_code            = csrc.rle_code
  AND    csrc.cro_code           = 'SALESPERSON'
  AND    csrc.rle_code           = 'LESSOR'
  AND    csrc.buy_or_sell        = chr.buy_or_sell
  AND    pty.dnz_chr_id          = chr.id
  AND    pty.chr_id              = chr.id
  AND    chr.id                  = p_trxh_out_rec.khr_id;

  l_salesP_rec salesP_csr%ROWTYPE;

  CURSOR custBillTo_csr
  IS
  SELECT bill_to_site_use_id cust_acct_site_id
  FROM   okc_k_headers_b
  WHERE  id = p_trxh_out_rec.khr_id;

  l_custBillTo_rec custBillTo_csr%ROWTYPE;

  l_acc_gen_primary_key_tbl   okl_account_dist_pvt.acc_gen_primary_key;
  l_fact_synd_code            FND_LOOKUPS.Lookup_code%TYPE;
  l_inv_acct_code             OKC_RULES_B.Rule_Information1%TYPE;

  account_data_exception  EXCEPTION;

  --Bug# 6619311
  CURSOR assetBillTo_csr(p_cle_id IN NUMBER)
  IS
  SELECT bill_to_site_use_id cust_acct_site_id
  FROM   okc_k_lines_b
  WHERE  id = p_cle_id;

  l_assetBillTo_rec assetBillTo_csr%ROWTYPE;
  l_acc_gen_primary_key_tbl1 okl_account_dist_pvt.acc_gen_primary_key;

  BEGIN

    okl_debug_pub.logmessage('OKL: populate_account_data : START');

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_acc_gen_primary_key_tbl(1).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
    OPEN  fnd_pro_csr;
    FETCH fnd_pro_csr INTO fnd_pro_rec;
    IF ( fnd_pro_csr%NOTFOUND )
    THEN
      l_acc_gen_primary_key_tbl(1).primary_key_column := '';
    ELSE
      l_acc_gen_primary_key_tbl(1).primary_key_column := fnd_pro_rec.l_fnd_profile;
    End IF;
    CLOSE fnd_pro_csr;

    l_acc_gen_primary_key_tbl(2).source_table := 'AR_SITE_USES_V';
    OPEN  custBillTo_csr;
    FETCH custBillTo_csr INTO l_custBillTo_rec;
    CLOSE custBillTo_csr;
    l_acc_gen_primary_key_tbl(2).primary_key_column := l_custBillTo_rec.cust_acct_site_id;

    l_acc_gen_primary_key_tbl(3).source_table := 'RA_CUST_TRX_TYPES';
    OPEN  ra_cust_csr;
    FETCH ra_cust_csr INTO ra_cust_rec;
    IF ( ra_cust_csr%NOTFOUND ) THEN
      l_acc_gen_primary_key_tbl(3).primary_key_column := '';
    ELSE
      l_acc_gen_primary_key_tbl(3).primary_key_column := TO_CHAR(ra_cust_rec.l_cust_trx_type_id);
    END IF;
    CLOSE ra_cust_csr;

    l_acc_gen_primary_key_tbl(4).source_table := 'JTF_RS_SALESREPS_MO_V';
    OPEN  salesP_csr;
    FETCH salesP_csr INTO l_salesP_rec;
    CLOSE salesP_csr;
    l_acc_gen_primary_key_tbl(4).primary_key_column := l_salesP_rec.id;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              , 'OKL: populate_account_data Procedure: Calling OKL_SECURITIZATION_PVT ');
    END IF;

    OKL_SECURITIZATION_PVT.Check_Khr_ia_associated(
                                  p_api_version             => p_api_version,
                                  p_init_msg_list           => p_init_msg_list,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_khr_id                  => p_trxh_out_rec.khr_id,
                                  p_scs_code                => l_salesP_rec.scs_code,
                                  p_trx_date                => p_trxh_out_rec.date_transaction_occurred,
                                  x_fact_synd_code          => l_fact_synd_code,
                                  x_inv_acct_code           => l_inv_acct_code
                                  );


    okl_debug_pub.logmessage('OKL: populate_account_data : OKL_SECURITIZATION_PVT : '||x_return_status);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
    THEN
      RAISE account_data_exception;
    END IF;

    FOR i in p_tclv_tbl.FIRST..p_tclv_tbl.LAST
    LOOP

      --Bug# 6619311: Populate asset level bill-to site if defined
      l_acc_gen_primary_key_tbl1 := l_acc_gen_primary_key_tbl;
      IF p_tclv_tbl(i).kle_id IS NOT NULL THEN
        l_assetBillTo_rec := NULL;
        OPEN  assetBillTo_csr(p_cle_id => p_tclv_tbl(i).kle_id);
        FETCH assetBillTo_csr INTO l_assetBillTo_rec;
        CLOSE assetBillTo_csr;

        IF l_assetBillTo_rec.cust_acct_site_id IS NOT NULL THEN
          l_acc_gen_primary_key_tbl1(2).primary_key_column := l_assetBillTo_rec.cust_acct_site_id;
        END IF;
      END IF;

      -- Populate account source
      p_acc_gen_tbl(i).acc_gen_key_tbl            := l_acc_gen_primary_key_tbl1;
      p_acc_gen_tbl(i).source_id                  := p_tclv_tbl(i).id;

      -- Populate template info
      p_tmpl_identify_tbl(i).product_id          := p_trxh_out_rec.pdt_id;
      p_tmpl_identify_tbl(i).transaction_type_id := p_trxh_out_rec.try_id;
      p_tmpl_identify_tbl(i).stream_type_id      := p_tclv_tbl(i).sty_id;
      p_tmpl_identify_tbl(i).advance_arrears     := NULL;
      p_tmpl_identify_tbl(i).prior_year_yn       := 'N';
      p_tmpl_identify_tbl(i).memo_yn             := 'N';
      p_tmpl_identify_tbl(i).factoring_synd_flag := l_fact_synd_code;
      p_tmpl_identify_tbl(i).investor_code       := l_inv_acct_code;

      -- Populate distribution info
      p_dist_info_tbl(i).SOURCE_ID                := p_tclv_tbl(i).id;
      p_dist_info_tbl(i).amount                   := p_tclv_tbl(i).amount;
      p_dist_info_tbl(i).ACCOUNTING_DATE          := p_trxh_out_rec.date_transaction_occurred;
      p_dist_info_tbl(i).SOURCE_TABLE             := 'OKL_TXL_CNTRCT_LNS';
      p_dist_info_tbl(i).GL_REVERSAL_FLAG         := 'N';
      p_dist_info_tbl(i).POST_TO_GL               := 'Y';
      p_dist_info_tbl(i).CONTRACT_ID              := p_trxh_out_rec.khr_id;
      p_dist_info_tbl(i).currency_conversion_rate := p_trxh_out_rec.currency_conversion_rate;
      p_dist_info_tbl(i).currency_conversion_type := p_trxh_out_rec.currency_conversion_type;
      p_dist_info_tbl(i).currency_conversion_date := p_trxh_out_rec.currency_conversion_date;
      p_dist_info_tbl(i).currency_code            := p_trxh_out_rec.currency_code;
      okl_debug_pub.logmessage('OKL: populate_account_data : p_tclv_tbl loop : l_dist_info_tbl(i).amount : '||p_dist_info_tbl(i).amount);

    END LOOP;

    okl_debug_pub.logmessage('OKL: populate_account_data : END');

  EXCEPTION
    WHEN account_data_exception
    THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

  END populate_account_data;

  -- Start of comments
  --
  -- Procedure Name  : create_upfront_tax_accounting
  -- Description     :  This procedure creates a/c journal entries for upfront tax lines.
  -- This procedure logic will be executed in its entirety, only if SLA accounting
  -- option AMB is enabled.
  -- When enabled, it creates:
  --      1. TRX header in OKL_TRX_CONTRACTS for type 'Upfront Tax'
  --      2. TRX lines in OKL_TXL_CNTRCT_LNS for each line in ZX_LINES,
  --         store values for cle-id, tax_line_id, tax_amount, etc.
  --      3. Identify tax treatment for each asset line, to derive stream type
  --      4. Call a/c API for upfront tax records in OKL_TXL_CNTRCT_LNS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE create_upfront_tax_accounting(
                    p_api_version       IN  NUMBER
                    ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                    ,p_contract_id      IN  okc_k_headers_all_b.id%TYPE
                    ,p_line_id          IN  okc_k_lines_b.id%TYPE
                    ,p_transaction_id   IN  okl_trx_contracts_all.khr_id%TYPE
                    ,p_transaction_type IN  VARCHAR2
                    ,p_transaction_date IN  DATE
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2)
  IS

  CURSOR contract_csr (p_contract_id OKC_K_HEADERS_B.ID%TYPE)
  IS
  SELECT  khr.pdt_id                    product_id
         ,khr.start_date                start_date
         ,khr.currency_code             currency_code
         ,khr.authoring_org_id          authoring_org_id
         ,khr.currency_conversion_rate  currency_conversion_rate
         ,khr.currency_conversion_type  currency_conversion_type
         ,khr.currency_conversion_date  currency_conversion_date
         ,khr.contract_number           contract_number
  FROM    okl_k_headers_full_v  khr
  WHERE   khr.id = p_contract_id;

  l_contract_rec  contract_csr%ROWTYPE;

  CURSOR fnd_lookups_csr( lkp_type VARCHAR2, mng VARCHAR2 ) IS
  select description,  lookup_code
  from   fnd_lookup_values
  where  language     = 'US'
  AND    lookup_type  = lkp_type
  AND    meaning      = mng;

  CURSOR Transaction_Type_csr (p_transaction_type IN okl_trx_types_v.name%TYPE ) IS
  SELECT id
  FROM  okl_trx_types_tl
  WHERE  name = p_transaction_type
  AND language = 'US';

  l_Trx_Type_rec     Transaction_Type_csr%ROWTYPE;

  -- Cursor to check system level accounting option
  -- Upfront tax a/c is done if AMB is enabled
  CURSOR acct_opt_csr
  IS
  SELECT account_derivation
  FROM   okl_sys_acct_opts;

  l_acct_opt okl_sys_acct_opts.account_derivation%TYPE;

  CURSOR tax_line_csr1
  IS
  SELECT   'BILLED'                  tax_treatment
         , txs.kle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     okl_tax_sources   txs
         , zx_lines          txl
  WHERE  txs.khr_id                       = p_contract_id
  AND    txs.kle_id                       = p_line_id
  AND    txs.trx_id                       = p_transaction_id
  AND    txs.tax_line_status_code         = 'ACTIVE'
  AND    txs.tax_call_type_code           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  = 'ASSETS'
  AND    txl.event_class_code             = 'ASSET_RELOCATION'
  AND    txs.entity_code                  = txl.entity_code
  AND    txs.event_class_code             = txl.event_class_code
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type;

  l_tclv_tbl                  okl_trx_contracts_pvt.tclv_tbl_type;
  x_tclv_tbl                  okl_trx_contracts_pvt.tclv_tbl_type;

  l_tmpl_identify_rec         okl_account_dist_pvt.tmpl_identify_rec_type;
  l_tmpl_identify_tbl         okl_account_dist_pvt.tmpl_identify_tbl_type;
  l_template_tbl              okl_account_dist_pvt.avlv_tbl_type;
  l_dist_info_tbl             okl_account_dist_pvt.dist_info_tbl_type;
  l_template_out_tbl          okl_account_dist_pvt.avlv_out_tbl_type;
  l_amount_tbl                okl_account_dist_pvt.amount_out_tbl_type;
  l_ctxt_val_tbl              okl_account_dist_pvt.CTXT_VAL_TBL_TYPE;
  l_acc_gen_tbl               okl_account_dist_pvt.ACC_GEN_TBL_TYPE;
  l_ctxt_tbl                  okl_account_dist_pvt.CTXT_TBL_TYPE;

  j                           NUMBER := 0;
  l_trx_id                    NUMBER;
  l_lkp_tcn_type_rec          fnd_lookups_csr%ROWTYPE;
  l_lkp_trx_status_rec        fnd_lookups_csr%ROWTYPE;
  SUBTYPE ac_tax_line_rec     IS tax_line_csr1%ROWTYPE;
  TYPE ac_tax_line_tbl        IS TABLE OF ac_tax_line_rec INDEX BY BINARY_INTEGER;
  l_accoutable_tax_lines      ac_tax_line_tbl;
  l_fact_synd_code            FND_LOOKUPS.Lookup_code%TYPE;
  l_inv_acct_code             OKC_RULES_B.Rule_Information1%TYPE;
  upfront_tax_acct_exception  EXCEPTION;

  l_billed_sty_id             NUMBER;
  l_transaction_amount        NUMBER;

  l_trxH_in_rec               Okl_Trx_Contracts_Pvt.tcnv_rec_type;
  l_trxH_out_rec              Okl_Trx_Contracts_Pvt.tcnv_rec_type;

  l_legal_entity_id           NUMBER;
  l_func_curr_code            okl_k_headers_full_v.CURRENCY_CODE%TYPE;
  l_chr_curr_code             okl_k_headers_full_v.CURRENCY_CODE%TYPE;
  l_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
  l_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
  l_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;

  BEGIN

    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_BLK_AST_UPD_PVT.Create_Upfront_Tax_Accounting','Begin(+)');
    END IF;

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              , 'OKL: create_upfront_tax_accounting Procedure: deriving Accounting option ');
    END IF;

    OPEN acct_opt_csr;
    FETCH acct_opt_csr INTO l_acct_opt;

    IF acct_opt_csr%NOTFOUND
    THEN
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LA_ST_ACCT_ERROR');
      CLOSE acct_opt_csr;
      RAISE upfront_tax_acct_exception;
    END IF;

    CLOSE acct_opt_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              , 'OKL: create_upfront_tax_accounting Procedure: Validating Accounting option ');
    END IF;

    IF (l_acct_opt IS NULL)
    THEN
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LA_ST_ACCT_ERROR');
      RAISE upfront_tax_acct_exception;
    END IF;

    -- execute the whole logic only if AMB is enabled, otherwise get out
    IF (l_acct_opt <> 'AMB' )
    THEN
      NULL;
    ELSE

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: before fnd_lookups_csr ');
      END IF;

      l_lkp_tcn_type_rec := NULL;
      OPEN  fnd_lookups_csr('OKL_TCN_TYPE', 'Upfront Tax');
      FETCH fnd_lookups_csr INTO l_lkp_tcn_type_rec;
      IF fnd_lookups_csr%NOTFOUND
      THEN
        Okl_Api.SET_MESSAGE( G_APP_NAME
                            ,OKL_API.G_INVALID_VALUE
                            ,'TRANSACTION_TYPE'
                            ,'Upfront Tax');
        CLOSE fnd_lookups_csr;
        RAISE upfront_tax_acct_exception;
      END IF;
      CLOSE fnd_lookups_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: before Transaction_Type_csr ');
      END IF;

      l_Trx_Type_rec := NULL;
      OPEN  Transaction_Type_csr('Upfront Tax');
      FETCH Transaction_Type_csr INTO l_Trx_Type_rec;
      IF Transaction_Type_csr%NOTFOUND THEN
        Okl_Api.SET_MESSAGE(G_APP_NAME,
                            OKL_API.G_INVALID_VALUE,
                            'TRANSACTION_TYPE',
                            'Upfront Tax');
        CLOSE Transaction_Type_csr;
        RAISE upfront_tax_acct_exception;
      END IF;
      CLOSE Transaction_Type_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: deriving billed stream ID ');
      END IF;

      OKL_STREAMS_UTIL.get_primary_stream_type(
    			p_khr_id              => p_contract_id,
    			p_primary_sty_purpose => 'UPFRONT_TAX_BILLED',
    			x_return_status       => x_return_status,
    			x_primary_sty_id      => l_billed_sty_id);

      okl_debug_pub.logmessage('OKL: create_upfront_tax_accounting Procedure: UPFRONT_TAX_BILLED : '||l_billed_sty_id);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        RAISE upfront_tax_acct_exception;
      End If;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                                ,G_MODULE
                                ,'OKL: create_upfront_tax_accounting Procedure: deriving asset tax information ');
      END IF;

      l_accoutable_tax_lines.DELETE;
      j := 0;
      l_transaction_amount := 0;
      FOR i IN tax_line_csr1
      LOOP
        j                         := j+1;
        l_accoutable_tax_lines(j) := i;
        l_transaction_amount := l_transaction_amount + l_accoutable_tax_lines(j).tax_amount;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                                ,G_MODULE
                                ,'OKL: create_upfront_tax_accounting Procedure: l_transaction_amount : '||l_transaction_amount);
      END IF;

      OPEN  contract_csr (p_contract_id);
      FETCH contract_csr INTO l_contract_rec;
      CLOSE contract_csr;

      l_chr_curr_code  := l_contract_rec.currency_code;
      l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(l_contract_rec.authoring_org_id);

      l_currency_conversion_rate := NULL;
      l_currency_conversion_type := NULL;
      l_currency_conversion_date := NULL;

      If ( ( l_func_curr_code IS NOT NULL) AND
           ( l_chr_curr_code <> l_func_curr_code ) ) Then

        l_currency_conversion_type := l_contract_rec.currency_conversion_type;
        l_currency_conversion_date := l_contract_rec.start_date;

        If ( l_contract_rec.currency_conversion_type = 'User') Then
          l_currency_conversion_rate := l_contract_rec.currency_conversion_rate;
          l_currency_conversion_date := l_contract_rec.currency_conversion_date;
        Else
          l_currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
	                                       p_from_curr_code => l_chr_curr_code,
	                                       p_to_curr_code   => l_func_curr_code,
                                             p_con_date       => l_contract_rec.start_date,
                                             p_con_type       => l_contract_rec.currency_conversion_type);
        End If;
      End If;

      l_trxH_in_rec.pdt_id                     := l_contract_rec.product_id;
      l_trxH_in_rec.currency_code              := l_contract_rec.currency_code;
      l_trxH_in_rec.currency_conversion_rate   := l_currency_conversion_rate;
      l_trxH_in_rec.currency_conversion_type   := l_currency_conversion_type;
      l_trxH_in_rec.currency_conversion_date   := l_currency_conversion_date;

      l_trxH_in_rec.khr_id                       := p_contract_id;
      l_trxH_in_rec.source_trx_id                := p_transaction_id;
      l_trxH_in_rec.source_trx_type              := p_transaction_type;
      l_trxH_in_rec.date_transaction_occurred    := p_transaction_date;
      l_trxH_in_rec.try_id                       := l_Trx_Type_rec.id;
      l_trxH_in_rec.tcn_type                     := l_lkp_tcn_type_rec.lookup_code;
      l_trxH_in_rec.amount                       := l_transaction_amount;

      l_lkp_trx_status_rec := NULL;
      OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Processed');
      FETCH fnd_lookups_csr INTO l_lkp_trx_status_rec;
      CLOSE fnd_lookups_csr;

      l_trxH_in_rec.tsu_code       := l_lkp_trx_status_rec.lookup_code;
      l_trxH_in_rec.description    := l_lkp_trx_status_rec.description;

      l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_contract_id) ;
      IF  l_legal_entity_id IS NOT NULL THEN
        l_trxH_in_rec.legal_entity_id :=  l_legal_entity_id;
      ELSE

	  Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
	                      p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => l_contract_rec.contract_number);
         RAISE upfront_tax_acct_exception;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                                      , G_MODULE
                                      ,'OKL: create_upfront_tax_accounting Procedure: before Okl_Trx_Contracts_Pub.create_trx_contracts ');
      END IF;

      -- Create Transaction Header, Lines
      Okl_Trx_Contracts_Pub.create_trx_contracts(
             p_api_version      => p_api_version
            ,p_init_msg_list    => p_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

      okl_debug_pub.logmessage('OKL: create_upfront_tax_accounting Procedure: create_trx_contracts : '||x_return_status);

      -- check transaction creation was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

      FOR i IN l_accoutable_tax_lines.FIRST..l_accoutable_tax_lines.LAST
      LOOP

        -- Populate TRX line array
        l_tclv_tbl(i).line_number   := i;
        l_tclv_tbl(i).tcn_id        := l_trxH_out_rec.id;
        l_tclv_tbl(i).khr_id        := p_contract_id;
        l_tclv_tbl(i).kle_id        := l_accoutable_tax_lines(i).asset_id;
        l_tclv_tbl(i).tcl_type      := l_lkp_tcn_type_rec.lookup_code;
        l_tclv_tbl(i).tax_line_id   := l_accoutable_tax_lines(i).tax_line_id;
        l_tclv_tbl(i).amount        := l_accoutable_tax_lines(i).tax_amount;
        l_tclv_tbl(i).currency_code := l_trxh_out_rec.currency_code;
        l_tclv_tbl(i).sty_id        := l_billed_sty_id;

      END LOOP;

      -- Create TRX lines with the data gathered

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              , 'OKL: create_upfront_tax_accounting Procedure: Calling Okl_Trx_Contracts_Pub.create_trx_cntrct_lines ');
      END IF;

      Okl_Trx_Contracts_Pub.create_trx_cntrct_lines(
                                      p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_tclv_tbl      => l_tclv_tbl,
                                      x_tclv_tbl      => x_tclv_tbl);

      okl_debug_pub.logmessage('OKL: create_upfront_tax_accounting Procedure: create_trx_cntrct_lines : '||x_return_status);

      -- check transaction line creation was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

      -- Populate accounting API data structures
      populate_account_data(
                    p_api_version
                    ,p_init_msg_list
                    ,l_trxh_out_rec
                    ,x_tclv_tbl
                    ,l_acc_gen_tbl
                    ,l_tmpl_identify_tbl
                    ,l_dist_info_tbl
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

      okl_debug_pub.logmessage('OKL: create_upfront_tax_accounting Procedure: populate_account_data : '||x_return_status);

      -- check transaction line creation was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: Calling Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST');
      END IF;

      -- Call Accounting API to create distributions
      okl_account_dist_pvt.create_accounting_dist(
                                  p_api_version             => p_api_version,
                                  p_init_msg_list           => p_init_msg_list,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                                  p_dist_info_tbl           => l_dist_info_tbl,
                                  p_ctxt_val_tbl            => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl            => l_template_out_tbl,
                                  x_amount_tbl              => l_amount_tbl,
                                  p_trx_header_id           => l_trxh_out_rec.id);

      okl_debug_pub.logmessage('OKL: create_upfront_tax_accounting Procedure:  create_accounting_dist : '|| x_return_status);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

    END IF; -- AMB Check

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_BLK_AST_UPD_PVT.Create_Upfront_Tax_Accounting','End(+)');
    END IF;

  EXCEPTION
    WHEN upfront_tax_acct_exception
    THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

  END create_upfront_tax_accounting;
  --Bug# 6619311 End


PROCEDURE process_update_location(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
       p_kle_id                         IN  NUMBER,
       x_return_status                  OUT NOCOPY VARCHAR2,
       x_msg_count                      OUT NOCOPY NUMBER,
       x_msg_data                       OUT NOCOPY VARCHAR2) IS

    CURSOR c_free_form2(p_parent_line_id IN NUMBER) IS
    SELECT  A.ID, K.org_id
    FROM    OKC_K_LINES_V A,
           OKC_LINE_STYLES_B B,
           okc_k_headers_all_b K
    WHERE   A.CLE_ID = p_parent_line_id
    AND     A.LSE_ID = B.ID
    AND     B.LTY_CODE = 'FREE_FORM2'
    AND     k.id = a.dnz_chr_id;

    CURSOR c_inst_item(p_line_id  IN  NUMBER) IS
      SELECT  A.ID,
              A.DNZ_CHR_ID
      FROM    OKC_K_LINES_V A,
           OKC_LINE_STYLES_B B
      WHERE   A.CLE_ID = p_line_id
      AND     A.LSE_ID = B.ID
      AND     B.LTY_CODE = 'INST_ITEM';

    CURSOR c_items(p_inst_itm_id IN NUMBER) is
   SELECT  *
   FROM    OKC_K_ITEMS_V
   WHERE   CLE_ID = p_inst_itm_id
   AND     JTOT_OBJECT1_CODE = 'OKX_IB_ITEM';


   CURSOR  c_ib_inst(p_object1_id1  IN VARCHAR2,p_object1_id2 IN VARCHAR2) IS
   SELECT  *
   FROM    OKX_INSTALL_ITEMS_V A
   WHERE   ID1 = p_object1_id1
   AND     ID2 = p_object1_id2;


   CURSOR c_loc_typecode(p_instance_id IN NUMBER) IS
   SELECT LOCATION_TYPE_CODE,
          INSTALL_LOCATION_TYPE_CODE
   FROM csi_item_instances
   WHERE INSTANCE_ID = p_instance_id;

   CURSOR c_get_entered_alc_trx(cp_kle_id IN NUMBER)   IS
   SELECT TRX.ID,TRX.TSU_CODE, TXL.object_id1_new, TXL.object_id2_new,
          TXL.object_id1_old,object_id2_old,psu.location_id, psu.party_site_id,
          TRX.DATE_TRANS_OCCURRED,TRX.req_asset_id
   FROM OKL_TRX_ASSETS TRX,
     OKL_TXL_ITM_INSTS TXL,
     OKL_TRX_TYPES_B TRY,
     OKX_PARTY_SITE_USES_V psu
   WHERE TRX.ID = TXL.TAS_ID
     AND TRX.TRY_ID = TRY.ID
     AND TRY.TRX_TYPE_CLASS = 'ASSET_RELOCATION'
     AND TRX.TSU_CODE = 'ENTERED'
     AND TRX.TAS_TYPE = 'ALG'
     AND TXL.KLE_ID = cp_kle_id
     AND psu.ID1 = TXL.object_id1_new
     AND PSU.ID2 = TXL.object_id2_new;

   CURSOR  c_systemparams_csr(cp_org_id  IN NUMBER) IS
   SELECT  tax_upfront_yn
   FROM    OKL_SYSTEM_PARAMS_ALL
   WHERE  org_id = cp_org_id;

   CURSOR c_get_tax_amt_csr(cp_trx_id IN NUMBER,cp_khr_id IN NUMBER,cp_kle_id IN NUMBER) IS
   SELECT nvl(sum(total_tax) ,0)
   FROM  okl_tax_sources TAXS
   WHERE TAXS.TAX_LINE_STATUS_CODE = 'ACTIVE'
   AND TAXS.TAX_CALL_TYPE_CODE = 'UPFRONT_TAX'
   AND TAXS.ENTITY_CODE = 'ASSETS'
   AND TAXS.APPLICATION_ID = 540
   AND EVENT_CLASS_CODE = 'ASSET_RELOCATION'
   AND TRX_ID =  cp_trx_id
   And khr_id = cp_khr_id
   And kle_id = cp_kle_id
   And trx_level_type = 'LINE';

   l_inst_loc_type_code   VARCHAR2(30);
   l_loc_type_code        VARCHAR2(30);

   l_c_ib_inst             c_ib_inst%ROWTYPE;
   l_ctr                   NUMBER;
   l_obj_no                NUMBER;
   l_trqv_rec              okl_trx_requests_pub.trqv_rec_type;
   x_trqv_rec              okl_trx_requests_pub.trqv_rec_type;



   l_trx_rec             c_get_entered_alc_trx%ROWTYPE;
   l_trxv_rec            trxv_rec_type;
   x_trxv_rec            trxv_rec_type;

   l_api_name              CONSTANT VARCHAR2(30)  := 'PROC_UPD_LOC';
   l_chr_id                 NUMBER;
   l_parent_line_id        NUMBER;
   l_ou_flag               VARCHAR2(2);
   l_tax_amt               NUMBER;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_BLK_AST_UPD_PVT.Update_Location','Begin(+)');
  END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Input variables in Update Location');
   END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_kle_id :'|| p_kle_id);
   END IF;

    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR l_c_free_form2 in c_free_form2(p_kle_id) LOOP
      FOR l_c_inst_item IN c_inst_item(l_c_free_form2.id) LOOP
          l_chr_id := l_c_inst_item.dnz_chr_id;
        FOR l_c_item IN c_items(l_c_inst_item.id) LOOP
          OPEN c_ib_inst(l_c_item.object1_id1,l_c_item.object1_id2);
            FETCH c_ib_inst INTO l_c_ib_inst;
            IF c_ib_inst%FOUND THEN

              OPEN c_get_entered_alc_trx(l_c_inst_item.id);
              FETCH c_get_entered_alc_trx INTO l_trx_rec;
              IF c_get_entered_alc_trx%NOTFOUND THEN
                  OKL_API.set_message( p_app_name      => 'OKL',
                                       p_msg_name      => 'OKL_ASTLOC_TRX_NF');
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              CLOSE c_get_entered_alc_trx;

              -- updating installed base item.

              SELECT object_version_number
              INTO l_obj_no
              FROM csi_item_instances
              WHERE instance_id = l_c_ib_inst.id1;


              OPEN c_loc_typecode(l_c_ib_inst.id1);
              FETCH c_loc_typecode INTO l_loc_type_code,l_inst_loc_type_code;
              CLOSE c_loc_typecode;

              IF (l_loc_type_code = 'HZ_LOCATIONS') THEN
                 l_instance_rec.LOCATION_ID      := l_trx_Rec.location_id;
              ELSIF l_loc_type_code = 'HZ_PARTY_SITES' THEN
                 l_instance_rec.LOCATION_ID      := l_trx_rec.party_site_id;
              END IF;

              IF (l_inst_loc_type_code = 'HZ_LOCATIONS') THEN
                 l_instance_rec.INSTALL_LOCATION_ID      := l_trx_Rec.location_id;
              ELSIF l_inst_loc_type_code = 'HZ_PARTY_SITES' THEN
                 l_instance_rec.INSTALL_LOCATION_ID      := l_trx_rec.party_site_id;
              END IF;

              l_instance_rec.instance_id                  := l_c_ib_inst.id1;
              l_instance_rec.instance_number              := l_c_ib_inst.name;
              l_instance_rec.object_version_number        := l_obj_no;

              l_instance_rec.EXTERNAL_REFERENCE           :=      FND_API.G_MISS_CHAR;
              l_instance_rec.INVENTORY_ITEM_ID            :=      FND_API.G_MISS_NUM;
              l_instance_rec.VLD_ORGANIZATION_ID          :=      FND_API.G_MISS_NUM;
              l_instance_rec.INVENTORY_REVISION           :=      FND_API.G_MISS_CHAR;
              l_instance_rec.INV_MASTER_ORGANIZATION_ID   :=      FND_API.G_MISS_NUM;
              l_instance_rec.MFG_SERIAL_NUMBER_FLAG       :=      FND_API.G_MISS_CHAR;
              l_instance_rec.LOT_NUMBER                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.QUANTITY                     :=      FND_API.G_MISS_NUM;
              l_instance_rec.UNIT_OF_MEASURE              :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ACCOUNTING_CLASS_CODE        :=      FND_API.G_MISS_CHAR;
              l_instance_rec.INSTANCE_CONDITION_ID        :=      FND_API.G_MISS_NUM;
              l_instance_rec.INSTANCE_STATUS_ID           :=      FND_API.G_MISS_NUM;
              l_instance_rec.CUSTOMER_VIEW_FLAG           :=      FND_API.G_MISS_CHAR;
              l_instance_rec.MERCHANT_VIEW_FLAG           :=      FND_API.G_MISS_CHAR;
              l_instance_rec.SELLABLE_FLAG                :=      FND_API.G_MISS_CHAR;
              l_instance_rec.SYSTEM_ID                    :=      FND_API.G_MISS_NUM;
              l_instance_rec.INSTANCE_TYPE_CODE           :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ACTIVE_START_DATE            :=      FND_API.G_MISS_DATE;
              l_instance_rec.ACTIVE_END_DATE              :=      FND_API.G_MISS_DATE;
              l_instance_rec.INV_ORGANIZATION_ID          :=      FND_API.G_MISS_NUM;
              l_instance_rec.INV_SUBINVENTORY_NAME        :=      FND_API.G_MISS_CHAR;
              l_instance_rec.INV_LOCATOR_ID               :=      FND_API.G_MISS_NUM;
              l_instance_rec.PA_PROJECT_ID                :=      FND_API.G_MISS_NUM;
              l_instance_rec.PA_PROJECT_TASK_ID           :=      FND_API.G_MISS_NUM;
              l_instance_rec.IN_TRANSIT_ORDER_LINE_ID     :=      FND_API.G_MISS_NUM;
              l_instance_rec.WIP_JOB_ID                   :=      FND_API.G_MISS_NUM;
              l_instance_rec.PO_ORDER_LINE_ID             :=      FND_API.G_MISS_NUM;
              l_instance_rec.LAST_OE_ORDER_LINE_ID        :=      FND_API.G_MISS_NUM;
              l_instance_rec.LAST_OE_RMA_LINE_ID          :=      FND_API.G_MISS_NUM;
              l_instance_rec.LAST_PO_PO_LINE_ID           :=      FND_API.G_MISS_NUM;
              l_instance_rec.LAST_OE_PO_NUMBER            :=      FND_API.G_MISS_CHAR;
              l_instance_rec.LAST_WIP_JOB_ID              :=      FND_API.G_MISS_NUM;
              l_instance_rec.LAST_PA_PROJECT_ID           :=      FND_API.G_MISS_NUM;
              l_instance_rec.LAST_PA_TASK_ID              :=      FND_API.G_MISS_NUM;
              l_instance_rec.LAST_OE_AGREEMENT_ID         :=      FND_API.G_MISS_NUM;
              l_instance_rec.INSTALL_DATE                 :=      FND_API.G_MISS_DATE;
              l_instance_rec.MANUALLY_CREATED_FLAG        :=      FND_API.G_MISS_CHAR;
              l_instance_rec.RETURN_BY_DATE               :=      FND_API.G_MISS_DATE;
              l_instance_rec.ACTUAL_RETURN_DATE           :=      FND_API.G_MISS_DATE;
              l_instance_rec.CREATION_COMPLETE_FLAG       :=      FND_API.G_MISS_CHAR;
              l_instance_rec.COMPLETENESS_FLAG            :=      FND_API.G_MISS_CHAR;
              l_instance_rec.VERSION_LABEL                :=      FND_API.G_MISS_CHAR;
              l_instance_rec.VERSION_LABEL_DESCRIPTION    :=      FND_API.G_MISS_CHAR;
              l_instance_rec.CONTEXT                      :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE1                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE2                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE3                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE4                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE5                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE6                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE7                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE8                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE9                   :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE10                  :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE11                  :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE12                  :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE13                  :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE14                  :=      FND_API.G_MISS_CHAR;
              l_instance_rec.ATTRIBUTE15                  :=      FND_API.G_MISS_CHAR;
              l_instance_rec.LAST_TXN_LINE_DETAIL_ID      :=      FND_API.G_MISS_NUM;

              l_instance_rec.INSTANCE_USAGE_CODE          :=      FND_API.G_MISS_CHAR;
              l_instance_rec.CHECK_FOR_INSTANCE_EXPIRY    :=      FND_API.G_TRUE;

              get_trx_rec(p_api_version      => p_api_version,
                          p_init_msg_list    => p_init_msg_list,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data,
                          p_cle_id           => NULL,
                          p_transaction_type => 'New',
                          x_trx_rec          => l_txn_rec);

              l_txn_rec.transaction_id   := FND_API.G_MISS_NUM;
              l_txn_rec.transaction_date := sysdate - 10;


              csi_item_instance_pub.update_item_instance(p_api_version           =>  p_api_version,
                                                         p_commit                =>  fnd_api.g_false,
                                                         p_init_msg_list         =>  p_init_msg_list,
                                                         p_validation_level      =>  fnd_api.g_valid_level_full,
                                                         p_instance_rec          =>  l_instance_rec,
                                                         p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                         p_party_tbl             =>  l_party_tbl,
                                                         p_account_tbl           =>  l_account_tbl,
                                                         p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                         p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                         p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                         p_txn_rec               =>  l_txn_rec,
                                                         x_instance_id_lst       =>  l_instance_id_lst,
                                                         x_return_status         =>  x_return_status,
                                                         x_msg_count             =>  x_msg_count,
                                                         x_msg_data              =>  x_msg_data);

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return status from updating in Install Base '||x_return_status);
              END IF;

              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;


    -- ER# 9327076 - Added condition to perform upfront tax calculation
	-- only if prior upfront tax calculation was done
	IF (OKL_LA_SALES_TAX_PVT.check_prior_upfront_tax(l_chr_id)) THEN

              OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
                      p_api_version            =>          p_api_version,
                      p_init_msg_list          =>          p_init_msg_list,
                      x_return_status          =>          x_return_status,
                      x_msg_count              =>          x_msg_count,
                      x_msg_data               =>          x_msg_data,
                      p_source_trx_id          =>          l_trx_rec.id,
                      p_source_trx_name        =>          G_TRY_NAME,
                      p_source_table           =>          G_TRX_TABLE,
                      p_tax_call_type          =>          'ACTUAL');

              --asawanka ebtax changes end
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return status from Tax API '||x_return_status);
              END IF;

              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

              --Bug# 6619311
              OKL_BLK_AST_UPD_PVT.create_upfront_tax_accounting(
                     p_api_version        => p_api_version
                    ,p_init_msg_list      => p_init_msg_list
                    ,p_contract_id        => l_chr_id
                    ,p_line_id            => p_kle_id
                    ,p_transaction_id     => l_trx_rec.id
                    ,p_transaction_type   => 'TAS'
                    ,p_transaction_date   => l_trx_rec.date_trans_occurred
                    ,x_return_status      => x_return_status
                    ,x_msg_count          => x_msg_count
                    ,x_msg_data           => x_msg_data);

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return status from create_upfront_tax_accounting API '||x_return_status);
              END IF;

              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

              -- 27-May-2008 SECHAWLA  6619311 l_parent_line_id was being passed to
              -- cursor, but there was no value being assigned to this variable
              -- Changed l_parent_line_id to p_kle_id
              --OPEN c_get_tax_amt_csr(l_trx_rec.id,l_chr_id,l_parent_line_id);
              OPEN c_get_tax_amt_csr(l_trx_rec.id,l_chr_id,p_kle_id);
              FETCH c_get_tax_amt_csr INTO l_tax_amt;
              CLOSE c_get_tax_amt_csr;

              IF l_tax_amt <> 0 THEN
                      Okl_Bill_Upfront_Tax_Pvt.Bill_Upfront_Tax(
                                                           p_api_version        => p_api_version,
                                                           p_init_msg_list      => p_init_msg_list,
                                                           p_khr_id             => l_chr_id,
                                                           p_trx_id             => l_trx_rec.id,
                                                           p_invoice_date       => l_trx_rec.date_trans_occurred,
                                                           x_return_status      => x_return_status,
                                                           x_msg_count          => x_msg_count,
                                                           x_msg_data           => x_msg_data);
                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return Status after creating Tax only invoice' || x_return_status);
                      END IF;
                      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                      END IF;
              ELSE
                      OKL_API.set_message( p_app_name      => 'OKL',
                                           p_msg_name      => 'OKL_ASTLOC_TAX_NOT_BILLED');
              END IF;

        END IF; -- ER# 9327076

              l_trxv_rec.id                     :=  l_trx_rec.id;
              l_trxv_rec.tsu_code            := 'PROCESSED';


              Update_asset_header(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_trxv_rec       => l_trxv_rec,
                           x_trxv_rec       => x_trxv_rec);


              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
    END IF; -- If _ib_inst found
    CLOSE c_ib_inst;
  END LOOP;
 END LOOP;
 IF l_trx_rec.req_asset_id IS NOT NULL THEN
   l_trqv_rec.id := l_trx_rec.req_asset_id;
   l_trqv_rec.request_status_code :=  'PROCESSED';
   SELECT object_version_number INTO l_trqv_rec.object_version_number
   FROM okl_trx_requests
   WHERE ID = l_trqv_rec.id;
    okl_trx_requests_pub.update_trx_requests(p_api_version     => p_api_version,
                                            p_init_msg_list   => p_init_msg_list,
                                            x_return_status   => x_return_status,
                                            x_msg_count       => x_msg_count,
                                            x_msg_data        => x_msg_data,
                                            p_trqv_rec        => l_trqv_rec,
                                            x_trqv_rec        => x_trqv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

 END IF;
 G_CTR := G_CTR + 1;
END LOOP;

 OKL_API.END_ACTIVITY (x_msg_count,
                       x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END process_update_location;

END OKL_BLK_AST_UPD_PVT;

/
