--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_PRICING_PVT" AS
/* $Header: OKLRQUPB.pls 120.20 2006/04/16 17:39:01 asawanka noship $ */
  -------------------------------------------------------------------------------
  -- FUNCTION populate_quote_rec
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : populate_quote_rec
  -- Description     : Populate the lease quote Records
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  FUNCTION populate_quote_rec(p_quote_id         IN  NUMBER
                             ,x_return_status    OUT NOCOPY VARCHAR2)
    RETURN lease_qte_rec_type IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'POPULATE_QUOTE_REC';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    -- Record/Table Type Declarations
    l_lsqv_rec           lease_qte_rec_type;

  BEGIN
    SELECT id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,reference_number
      ,status
      ,parent_object_code
      ,parent_object_id
      ,valid_from
      ,valid_to
      ,customer_bookclass
      ,customer_taxowner
      ,expected_start_date
      ,expected_funding_date
      ,expected_delivery_date
      ,pricing_method
      ,term
      ,product_id
      ,end_of_term_option_id
      ,rate_card_id
      ,rate_template_id
      ,target_rate_type
      ,target_rate
      ,target_amount
      ,target_frequency
      ,target_arrears_yn
      ,target_periods
      ,iir
      ,booking_yield
      ,pirr
      ,airr
      ,sub_iir
      ,sub_booking_yield
      ,sub_pirr
      ,sub_airr
      ,usage_category
      ,usage_industry_class
      ,usage_industry_code
      ,usage_amount
      ,usage_location_id
      ,property_tax_applicable
      ,property_tax_billing_type
      ,upfront_tax_treatment
      ,upfront_tax_stream_type
      ,transfer_of_title
      ,age_of_equipment
      ,purchase_of_lease
      ,sale_and_lease_back
      ,interest_disclosed
      ,structured_pricing
      ,line_level_pricing
      ,short_description
      ,description
      ,comments
      ,PRIMARY_QUOTE
    INTO
      l_lsqv_rec.id
      ,l_lsqv_rec.object_version_number
      ,l_lsqv_rec.attribute_category
      ,l_lsqv_rec.attribute1
      ,l_lsqv_rec.attribute2
      ,l_lsqv_rec.attribute3
      ,l_lsqv_rec.attribute4
      ,l_lsqv_rec.attribute5
      ,l_lsqv_rec.attribute6
      ,l_lsqv_rec.attribute7
      ,l_lsqv_rec.attribute8
      ,l_lsqv_rec.attribute9
      ,l_lsqv_rec.attribute10
      ,l_lsqv_rec.attribute11
      ,l_lsqv_rec.attribute12
      ,l_lsqv_rec.attribute13
      ,l_lsqv_rec.attribute14
      ,l_lsqv_rec.attribute15
      ,l_lsqv_rec.reference_number
      ,l_lsqv_rec.status
      ,l_lsqv_rec.parent_object_code
      ,l_lsqv_rec.parent_object_id
      ,l_lsqv_rec.valid_from
      ,l_lsqv_rec.valid_to
      ,l_lsqv_rec.customer_bookclass
      ,l_lsqv_rec.customer_taxowner
      ,l_lsqv_rec.expected_start_date
      ,l_lsqv_rec.expected_funding_date
      ,l_lsqv_rec.expected_delivery_date
      ,l_lsqv_rec.pricing_method
      ,l_lsqv_rec.term
      ,l_lsqv_rec.product_id
      ,l_lsqv_rec.end_of_term_option_id
      ,l_lsqv_rec.rate_card_id
      ,l_lsqv_rec.rate_template_id
      ,l_lsqv_rec.target_rate_type
      ,l_lsqv_rec.target_rate
      ,l_lsqv_rec.target_amount
      ,l_lsqv_rec.target_frequency
      ,l_lsqv_rec.target_arrears_yn
      ,l_lsqv_rec.target_periods
      ,l_lsqv_rec.iir
      ,l_lsqv_rec.booking_yield
      ,l_lsqv_rec.pirr
      ,l_lsqv_rec.airr
      ,l_lsqv_rec.sub_iir
      ,l_lsqv_rec.sub_booking_yield
      ,l_lsqv_rec.sub_pirr
      ,l_lsqv_rec.sub_airr
      ,l_lsqv_rec.usage_category
      ,l_lsqv_rec.usage_industry_class
      ,l_lsqv_rec.usage_industry_code
      ,l_lsqv_rec.usage_amount
      ,l_lsqv_rec.usage_location_id
      ,l_lsqv_rec.property_tax_applicable
      ,l_lsqv_rec.property_tax_billing_type
      ,l_lsqv_rec.upfront_tax_treatment
      ,l_lsqv_rec.upfront_tax_stream_type
      ,l_lsqv_rec.transfer_of_title
      ,l_lsqv_rec.age_of_equipment
      ,l_lsqv_rec.purchase_of_lease
      ,l_lsqv_rec.sale_and_lease_back
      ,l_lsqv_rec.interest_disclosed
      ,l_lsqv_rec.structured_pricing
      ,l_lsqv_rec.line_level_pricing
      ,l_lsqv_rec.short_description
      ,l_lsqv_rec.description
      ,l_lsqv_rec.comments
      ,l_lsqv_rec.PRIMARY_QUOTE
    FROM OKL_LEASE_QUOTES_V
    WHERE id = p_quote_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_lsqv_rec;

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END populate_quote_rec;

  -------------------------------------------------------------------------------
  -- FUNCTION populate_fee_rec
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : populate_fee_rec
  -- Description     : Populate the lease fee Records
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  FUNCTION populate_fee_rec(p_fee_id             IN NUMBER
                           ,x_return_status    OUT NOCOPY VARCHAR2)
	RETURN fee_rec_type IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'POPULATE_FEE_REC';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    -- Record/Table Type Declarations
    l_feev_rec           fee_rec_type;

  BEGIN
    SELECT id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,parent_object_code
      ,parent_object_id
      ,stream_type_id
      ,fee_type
      ,rate_card_id
      ,rate_template_id
      ,structured_pricing
      ,target_arrears
      ,effective_from
      ,effective_to
      ,supplier_id
      ,rollover_quote_id
      ,initial_direct_cost
      ,fee_amount
      ,target_amount
      ,target_frequency
      ,payment_type_id
    INTO
      l_feev_rec.id
      ,l_feev_rec.object_version_number
      ,l_feev_rec.attribute_category
      ,l_feev_rec.attribute1
      ,l_feev_rec.attribute2
      ,l_feev_rec.attribute3
      ,l_feev_rec.attribute4
      ,l_feev_rec.attribute5
      ,l_feev_rec.attribute6
      ,l_feev_rec.attribute7
      ,l_feev_rec.attribute8
      ,l_feev_rec.attribute9
      ,l_feev_rec.attribute10
      ,l_feev_rec.attribute11
      ,l_feev_rec.attribute12
      ,l_feev_rec.attribute13
      ,l_feev_rec.attribute14
      ,l_feev_rec.attribute15
      ,l_feev_rec.parent_object_code
      ,l_feev_rec.parent_object_id
      ,l_feev_rec.stream_type_id
      ,l_feev_rec.fee_type
      ,l_feev_rec.rate_card_id
      ,l_feev_rec.rate_template_id
      ,l_feev_rec.structured_pricing
      ,l_feev_rec.target_arrears
      ,l_feev_rec.effective_from
      ,l_feev_rec.effective_to
      ,l_feev_rec.supplier_id
      ,l_feev_rec.rollover_quote_id
      ,l_feev_rec.initial_direct_cost
      ,l_feev_rec.fee_amount
      ,l_feev_rec.target_amount
      ,l_feev_rec.target_frequency
      ,l_feev_rec.payment_type_id
    FROM okL_fees_V
    WHERE id = p_fee_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_feev_rec;

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);

         -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END populate_fee_rec;

  -------------------------------------------------------------------------------
  -- FUNCTION populate_asset_rec
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : populate_asset_rec
  -- Description     : Populate the lease Asset Records
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  FUNCTION populate_asset_rec (p_asset_id      IN  NUMBER
                              ,x_return_status OUT NOCOPY VARCHAR2)
	  RETURN asset_rec_type IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'POPULATE_ASSET_REC';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    -- Record/Table Type Declarations
    l_assv_rec            asset_rec_type;

  BEGIN
    SELECT id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,parent_object_code
      ,parent_object_id
      ,asset_number
      ,install_site_id
      ,rate_card_id
      ,rate_template_id
      ,oec
      ,end_of_term_value_default
      ,end_of_term_value
      ,oec_percentage
      ,target_amount
      ,target_frequency
      ,short_description
      ,description
      ,comments
    INTO
      l_assv_rec.id
      ,l_assv_rec.object_version_number
      ,l_assv_rec.attribute_category
      ,l_assv_rec.attribute1
      ,l_assv_rec.attribute2
      ,l_assv_rec.attribute3
      ,l_assv_rec.attribute4
      ,l_assv_rec.attribute5
      ,l_assv_rec.attribute6
      ,l_assv_rec.attribute7
      ,l_assv_rec.attribute8
      ,l_assv_rec.attribute9
      ,l_assv_rec.attribute10
      ,l_assv_rec.attribute11
      ,l_assv_rec.attribute12
      ,l_assv_rec.attribute13
      ,l_assv_rec.attribute14
      ,l_assv_rec.attribute15
      ,l_assv_rec.parent_object_code
      ,l_assv_rec.parent_object_id
      ,l_assv_rec.asset_number
      ,l_assv_rec.install_site_id
      ,l_assv_rec.rate_card_id
      ,l_assv_rec.rate_template_id
      ,l_assv_rec.oec
      ,l_assv_rec.end_of_term_value_default
      ,l_assv_rec.end_of_term_value
      ,l_assv_rec.oec_percentage
      ,l_assv_rec.target_amount
      ,l_assv_rec.target_frequency
      ,l_assv_rec.short_description
      ,l_assv_rec.description
      ,l_assv_rec.comments
    FROM OKL_ASSETS_V
    WHERE id = p_asset_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_assv_rec;

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END populate_asset_rec;
  --Bug # 4688662 ssdeshpa start
  --Moved this method to OKL_SALES_QUOTE_QA_PVT
  /*FUNCTION are_all_lines_overriden(p_quote_id           IN  NUMBER
                                  ,p_pricing_method     IN  VARCHAR2
                                  ,p_line_level_pricing IN VARCHAR2
                                  ,x_return_status      OUT NOCOPY VARCHAR2)
    RETURN VARCHAR2 IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'all_lns_ovr';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_all_lines_overriden                 VARCHAR2(3) := 'N';
    l_ovr_cnt                           NUMBER;
    l_ast_cnt                           NUMBER;
    CURSOR llo_flag_csr IS
     SELECT count(*) overriden_assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   (    AST.RATE_TEMPLATE_ID IS NOT NULL
             OR AST.STRUCTURED_PRICING = 'Y' )
     AND   QTE.ID = p_quote_id
     AND   p_line_level_pricing = 'Y';

    CURSOR rc_llo_flag_csr IS
     SELECT count(*) overriden_assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   (    AST.RATE_CARD_ID IS NOT NULL
             OR AST.LEASE_RATE_FACTOR IS NOT NULL )
     AND   QTE.ID = p_quote_id
     AND   p_line_level_pricing = 'Y';

    CURSOR sy_llo_flag_csr IS
     SELECT count(*) overriden_assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   (  AST.STRUCTURED_PRICING = 'Y')
     AND   QTE.ID = p_quote_id
     AND   p_line_level_pricing = 'Y';

    CURSOR ast_cnt_csr IS
     SELECT count(*) assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   QTE.ID = p_quote_id;

  BEGIN
    IF p_pricing_method = 'SY' THEN
       OPEN sy_llo_flag_csr;
       FETCH sy_llo_flag_csr INTO l_ovr_cnt;
       CLOSE sy_llo_flag_csr;
    ELSIF p_pricing_method = 'RC' THEN
       OPEN rc_llo_flag_csr;
       FETCH rc_llo_flag_csr INTO l_ovr_cnt;
       CLOSE rc_llo_flag_csr;
    ELSIF p_pricing_method <> 'TR' THEN
       OPEN llo_flag_csr;
       FETCH llo_flag_csr INTO l_ovr_cnt;
       CLOSE llo_flag_csr;
    END IF;
    OPEN ast_cnt_csr;
    FETCH ast_cnt_csr INTO l_ast_cnt;
    CLOSE ast_cnt_csr;
    IF l_ast_cnt = 0 THEN
     l_all_lines_overriden := 'N';
    ELSIF l_Ast_cnt = l_ovr_cnt THEN
     l_all_lines_overriden := 'Y';
    ELSE
     l_all_lines_overriden := 'N';
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_all_lines_overriden;

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END are_all_lines_overriden;*/
  --Bug # 4688662 ssdeshpa start

  FUNCTION are_qte_pricing_opts_entered(p_lease_qte_rec    IN  lease_qte_rec_type
                                       ,p_payment_count    IN  NUMBER
                                       ,x_return_status    OUT NOCOPY VARCHAR2)
    RETURN VARCHAR2 IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'qte_pr_entr';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_falg                 VARCHAR2(3) := 'N';
  BEGIN
    IF p_lease_qte_rec.pricing_method = 'SY' THEN
       IF  p_payment_count <> 0 THEN
         return 'Y';
       END IF;
    ELSIF p_lease_qte_rec.pricing_method = 'RC' THEN
       IF p_lease_qte_rec.structured_pricing = 'N' AND  p_lease_qte_rec.rate_card_id IS NOT NULL
          OR p_lease_qte_rec.structured_pricing = 'Y' AND  p_lease_qte_rec.lease_rate_factor IS NOT NULL
       THEN
         return 'Y';
       END IF;
    ELSIF p_lease_qte_rec.pricing_method = 'SM' THEN
       IF (p_lease_qte_rec.structured_pricing = 'N' AND  ( p_lease_qte_rec.rate_template_id IS NOT NULL OR p_payment_count <> 0 ) )
          OR ( p_lease_qte_rec.structured_pricing = 'Y' AND  p_payment_count <> 0 )
       THEN
         return 'Y';
       END IF;
    ELSIF p_lease_qte_rec.pricing_method <> 'TR' THEN
       IF p_lease_qte_rec.structured_pricing = 'N' AND  p_lease_qte_rec.rate_template_id IS NOT NULL
          OR p_lease_qte_rec.structured_pricing = 'Y' AND  p_payment_count <> 0
       THEN
         return 'Y';
       END IF;
    END IF;


    x_return_status := G_RET_STS_SUCCESS;
    RETURN 'N';

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END are_qte_pricing_opts_entered;
  -------------------------------------------------------------------------------
  -- PROCEDURE validate
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate
  -- Description     : Validate the lease quote and call the validation set wrapper API
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE validate (p_api_version             IN  NUMBER
                     ,p_init_msg_list           IN  VARCHAR2
                     ,p_quote_id                IN  NUMBER
                     ,x_qa_result               OUT NOCOPY VARCHAR2
                     ,x_return_status           OUT NOCOPY VARCHAR2
                     ,x_msg_count               OUT NOCOPY NUMBER
                     ,x_msg_data                OUT NOCOPY VARCHAR2) IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'VALIDATE';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    l_object_type          VARCHAR2(15):= 'LEASEQUOTE';

    -- Record/Table Type Declarations
    l_lease_qte_rec        lease_qte_rec_type;
    lx_lease_qte_rec       lease_qte_rec_type;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Pupulate lease quote rec
    l_lease_qte_rec := populate_quote_rec(p_quote_id,x_return_status);

    IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF(x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_SALES_QUOTE_QA_PVT.run_qa_checker'
      ,'begin debug call run_qa_checker');
    END IF;
    OKL_SALES_QUOTE_QA_PVT.run_qa_checker(
                           p_api_version     => G_API_VERSION
                          ,p_init_msg_list   => G_FALSE
                          ,p_object_type   => l_object_type
                          ,p_object_id       => p_quote_id
                          ,x_qa_result       => x_qa_result
                          ,x_return_status   => x_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data);
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_SALES_QUOTE_QA_PVT.run_qa_checker'
      ,'end debug call run_qa_checker');
    END IF;

    IF(x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF(x_return_status = G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END validate;
  -------------------------------------------------------------------------------
  -- PROCEDURE price
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : price
  -- Description     : Price the lease quote and call the validation API
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE price(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'PRICE';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    l_quote_id             OKL_LEASE_QUOTES_B.ID%TYPE;

    -- Record/Table Type Declarations


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_quote_id := p_quote_id;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_PRICING_UTILS_PVT.price_standard_quote'
     ,'begin debug call price_standard_quote');
    END IF;
    OKL_PRICING_UTILS_PVT.price_standard_quote(
                          x_return_status    => x_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_api_version     => G_API_VERSION
                          ,p_init_msg_list   => G_FALSE
                          ,p_qte_id          => l_quote_id);
    IF(l_debug_enabled='Y') THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_PRICING_UTILS_PVT.price_standard_quote'
     ,'end debug call price_standard_quote');
    END IF;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END price;

  -------------------------------------------------------------------------------
  -- PROCEDURE calculate_tax
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : calculate_tax
  -- Description     : calculate the upfront tax
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE calculate_tax(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CALCULATE TAX';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    l_source_table         VARCHAR2(30):= 'OKL_LEASE_QUOTES_B';
    l_source_trx_name      VARCHAR2(15):='Quoting';
    l_quote_id             OKL_LEASE_QUOTES_B.ID%TYPE;

    -- Record/Table Type Declarations


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_quote_id := p_quote_id;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_PROCESS_SALES_TAX_PVT.calculate_sales_tax'
      ,'begin debug call validate');
    END IF;
    OKL_PROCESS_SALES_TAX_PVT.calculate_sales_tax(
                           p_api_version      => G_API_VERSION
                          ,p_init_msg_list    => G_FALSE
                          ,x_return_status    => x_return_status
                          ,x_msg_count        => x_msg_count
                          ,x_msg_data         => x_msg_data
                          ,p_source_trx_id    => l_quote_id
                          ,p_source_trx_name  => l_source_trx_name
                          ,p_source_table     => l_source_table);

    IF(l_debug_enabled='Y') THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_PROCESS_SALES_TAX_PVT.calculate_sales_tax'
     ,'end debug call price_standard_quote');
    END IF;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END calculate_tax;
  -------------------------------------------------------------------------------
  -- PROCEDURE handle_parent_object_status
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : handle_parent_object_status
  -- Description     : Update status of parent of lease quote
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-NOV-2005 ASAWANKA created
  -- End of comments

  PROCEDURE handle_parent_object_status(
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_parent_object_code      IN  VARCHAR2
    ,p_parent_object_id        IN  NUMBER
    ) IS

     -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'HNDL_PRNT_STS';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    lx_return_status              VARCHAR2(1);

    x_lapv_rec                    OKL_LAP_PVT.LAPV_REC_TYPE;
    lx_lsqv_rec                   lease_qte_rec_type;
    lx_lapv_rec                   OKL_LAP_PVT.LAPV_REC_TYPE;
    l_lsqv_rec                    lease_qte_rec_type;
    l_quote_id                    NUMBER;

    CURSOR get_primary_quote
    IS
    SELECT ID
    FROM   OKL_LEASE_QUOTES_B
    WHERE parent_object_id =p_parent_object_id
    AND   primary_quote = 'Y';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_APP_PVT.populate_lease_app'
       ,'begin debug  call populate_lease_app');
    END IF;

    IF p_parent_object_code = 'LEASEAPP' THEN

        OPEN  get_primary_quote;
        FETCH get_primary_quote into l_quote_id;
        CLOSE get_primary_quote;

        l_lsqv_rec := populate_quote_rec ( p_quote_id       => l_quote_id,
    				                       x_return_status  => x_return_status );

        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_lsqv_rec.STATUS := 'PR-INCOMPLETE';

         OKL_LEASE_QUOTE_PVT.update_lease_qte(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_transaction_control  => G_FALSE
         ,p_lease_qte_rec        => l_lsqv_rec
         ,x_lease_qte_rec        => lx_lsqv_rec
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        OKL_LEASE_APP_PVT.populate_lease_app(p_api_version     => p_api_version,
                                             p_init_msg_list   => p_init_msg_list,
                                             x_return_status   => x_return_status,
                                             x_msg_count       => x_msg_count,
                                             x_msg_data        => x_msg_data,
                                             p_lap_id          => p_parent_object_id,
                                             x_lapv_rec        => x_lapv_rec,
                                             x_lsqv_rec        => lx_lsqv_rec);
         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_APP_PVT.populate_lease_app'
           ,'end debug call populate_lease_app');
         END IF;
         IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         IF x_lapv_rec.APPLICATION_STATUS IN ('PR-COMPLETE', 'PR-APPROVED','PR-REJECTED') THEN
            x_lapv_rec.APPLICATION_STATUS := 'INCOMPLETE';
            IF(l_debug_enabled='Y') THEN
                okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_APP_PVT.lease_app_upd'
                ,'begin debug  call lease_app_upd');
            END IF;

            OKL_LEASE_APP_PVT.set_lease_app_status(p_api_version    => p_api_version,
                                            p_init_msg_list         => p_init_msg_list,
                                            x_return_status         => x_return_status,
                                            x_msg_count             => x_msg_count,
                                            x_msg_data              => x_msg_data,
                                            p_lap_id                => x_lapv_rec.id,
                                            p_lap_status            => x_lapv_rec.APPLICATION_STATUS
                                            );
             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_APP_PVT.lease_app_upd'
               ,'end debug call lease_app_upd');
             END IF;
             IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;
    END IF;

     x_return_status := okc_api.G_RET_STS_SUCCESS;
     OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

  END handle_parent_object_status;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_update_payment
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_update_payment
  -- Description     : Create/Update Lease Quote pricing options and payments
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_update_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_lease_qte_rec           IN lease_qte_rec_type
    ,p_payment_header_rec      IN cashflow_hdr_rec_type
    ,p_payment_level_tbl       IN cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CREATE_UPDATE_PAYMENT';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    -- Record/Table Type Declarations
    l_payment_header_rec   cashflow_hdr_rec_type;
    l_payment_level_tbl    cashflow_level_tbl_type;
    l_lease_qte_rec        lease_qte_rec_type;
    lx_lease_qte_rec       lease_qte_rec_type;
    l_fee_rec              fee_rec_type;
    lx_fee_rec             fee_rec_type;
    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;

    lv_cash_flow_exists    VARCHAR2(3);
    l_all_lines_overriden                 VARCHAR2(3);
    l_entered              VARCHAR2(3);

    CURSOR c_check_cash_flow(p_quote_id OKL_LEASE_QUOTES_B.ID%TYPE)
    IS
    SELECT 'YES'
    FROM   OKL_CASH_FLOW_OBJECTS
    WHERE  OTY_CODE     = 'LEASE_QUOTE'
    AND    SOURCE_TABLE = 'OKL_LEASE_QUOTES_B'
    AND    SOURCE_ID    = p_quote_id;

    CURSOR quote_assets_csr(lc_quote_id IN NUMBER) IS
     SELECT ID
     FROM OKL_ASSETS_B
     WHERE parent_object_id = lc_quote_id
     AND   parent_object_code = 'LEASEQUOTE';

    CURSOR quote_fees_csr(lc_quote_id IN NUMBER) IS
     SELECT ID
     FROM OKL_FEES_B
     WHERE parent_object_id = lc_quote_id
     AND   parent_object_code = 'LEASEQUOTE'
     AND   fee_type <> 'CAPITALIZED';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Pupulate quote record
    l_lease_qte_rec := populate_quote_rec(p_lease_qte_rec.id,x_return_status);

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lease_qte_rec.TARGET_RATE_TYPE   := p_lease_qte_rec.TARGET_RATE_TYPE;
    l_lease_qte_rec.TARGET_RATE        := p_lease_qte_rec.TARGET_RATE;
    l_lease_qte_rec.TARGET_AMOUNT      := p_lease_qte_rec.TARGET_AMOUNT;
    l_lease_qte_rec.TARGET_FREQUENCY   := p_lease_qte_rec.TARGET_FREQUENCY;
    l_lease_qte_rec.TARGET_ARREARS_YN  := p_lease_qte_rec.TARGET_ARREARS_YN;
    l_lease_qte_rec.TARGET_PERIODS     := p_lease_qte_rec.TARGET_PERIODS;
    l_lease_qte_rec.STRUCTURED_PRICING := p_lease_qte_rec.STRUCTURED_PRICING;
    l_lease_qte_rec.LINE_LEVEL_PRICING := p_lease_qte_rec.LINE_LEVEL_PRICING;
    l_lease_qte_rec.LEASE_RATE_FACTOR  := p_lease_qte_rec.LEASE_RATE_FACTOR;
    l_lease_qte_rec.rate_template_id   := p_lease_qte_rec.rate_template_id;
    l_lease_qte_rec.rate_card_id       := p_lease_qte_rec.rate_card_id;

    l_all_lines_overriden := okl_sales_quote_qa_pvt.are_all_lines_overriden(l_lease_qte_rec.id,l_lease_qte_rec.pricing_method,l_lease_qte_rec.LINE_LEVEL_PRICING ,x_return_status);

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_all_lines_overriden = 'Y' THEN
      l_entered := are_qte_pricing_opts_entered(l_lease_qte_rec,p_payment_level_tbl.count,x_return_status);

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_entered = 'Y' THEN

       OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_QTE_PMT_ENTERED');
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_lease_qte_rec.TARGET_RATE_TYPE   := NULL;
      l_lease_qte_rec.TARGET_RATE        := NULL;
      l_lease_qte_rec.TARGET_AMOUNT      := NULL;
      l_lease_qte_rec.TARGET_FREQUENCY   := NULL;
      l_lease_qte_rec.TARGET_ARREARS_YN  := NULL;
      l_lease_qte_rec.TARGET_PERIODS     := NULL;
      l_lease_qte_rec.STRUCTURED_PRICING := NULL;
      l_lease_qte_rec.LEASE_RATE_FACTOR  := NULL;
      l_lease_qte_rec.rate_template_id   := NULL;
      l_lease_qte_rec.rate_card_id       := NULL;
    ELSE
      IF l_lease_qte_rec.pricing_method NOT IN ( 'TR','RC','SY') THEN
           IF l_lease_qte_rec.structured_pricing = 'N' AND  l_lease_qte_rec.rate_template_id IS  NULL THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_SRT_MANDATORY');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           ELSIF l_lease_qte_rec.structured_pricing = 'N' AND  l_lease_qte_rec.target_amount IS  NULL
                 AND l_lease_qte_rec.pricing_method NOT IN  ('SP','SM')
           THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_PA_MANDATORY');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
      END IF;
    END IF;
    IF l_all_lines_overriden = 'N' OR l_entered = 'N' THEN
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_PVT.update_lease_qte'
          ,'begin debug call update_lease_qte');
        END IF;
        OKL_LEASE_QUOTE_PVT.update_lease_qte(
              p_api_version          => G_API_VERSION
             ,p_init_msg_list        => G_FALSE
             ,p_transaction_control  => G_FALSE
             ,p_lease_qte_rec        => l_lease_qte_rec
             ,x_lease_qte_rec        => lx_lease_qte_rec
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data);
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_PVT.update_lease_qte'
          ,'end debug call update_lease_qte');
        END IF;

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF l_all_lines_overriden = 'Y' THEN
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
            ,'begin debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
          END IF;
          okl_lease_quote_cashflow_pvt.delete_cashflows(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_transaction_control  => G_FALSE
         ,p_source_object_code   => 'LEASE_QUOTE'
         ,p_source_object_id     => p_lease_qte_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
             ,'End debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
          END IF;

          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSE
            l_payment_header_rec := p_payment_header_rec;
            l_payment_level_tbl  := p_payment_level_tbl;

            l_payment_header_rec.parent_object_id := l_lease_qte_rec.id;
            l_payment_header_rec.quote_id := l_lease_qte_rec.id;
            l_payment_header_rec.type_code:= 'INFLOW';

            IF ((l_payment_level_tbl.COUNT > 0 AND l_payment_header_rec.stream_type_id IS NULL) OR
                (l_payment_header_rec.stream_type_id IS NOT NULL AND l_payment_level_tbl.COUNT = 0 ))
            THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_EPT_PAYMENT_NA');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSE
            -- Check if the Cash flows already exists
            OPEN  c_check_cash_flow(p_quote_id => l_payment_header_rec.quote_id);
            FETCH c_check_cash_flow into lv_cash_flow_exists;
            CLOSE c_check_cash_flow;

               IF (lv_cash_flow_exists = 'YES') THEN

                IF(l_debug_enabled='Y') THEN
                 okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow'
                 ,'begin debug call update_cashflow');
                END IF;
                OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow (
                                    p_api_version         => G_API_VERSION
                                   ,p_init_msg_list       => G_FALSE
                                   ,p_transaction_control => G_FALSE
                                   ,p_cashflow_header_rec => l_payment_header_rec
                                   ,p_cashflow_level_tbl  => l_payment_level_tbl
                                   ,x_return_status       => x_return_status
                                   ,x_msg_count           => x_msg_count
                                   ,x_msg_data            => x_msg_data);
                IF(l_debug_enabled='Y') THEN
                 okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow'
                 ,'end debug call update_cashflow');
                END IF;

                IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF x_return_status = G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              ELSE
                IF(l_debug_enabled='Y') THEN
                 okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow'
                 ,'begin debug call create_cashflow');
                END IF;
                OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
                                    p_api_version   => G_API_VERSION
                                   ,p_init_msg_list => G_FALSE
                                   ,p_transaction_control => G_FALSE
                                   ,p_cashflow_header_rec => l_payment_header_rec
                                   ,p_cashflow_level_tbl => l_payment_level_tbl
                                   ,x_return_status => x_return_status
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data);
                IF(l_debug_enabled='Y') THEN
                 okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow'
                 ,'end debug call create_cashflow');
                END IF;

                IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF x_return_status = G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
            END IF;
         END IF;
    END IF;
    IF p_lease_qte_rec.line_level_pricing = 'N' THEN
      FOR l_quote_asset_rec IN quote_assets_csr(l_lease_qte_rec.id) LOOP

         delete_line_payment(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_source_object_code   => 'QUOTED_ASSET'
         ,p_source_object_id     => l_quote_asset_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END LOOP;
  /*    FOR l_quote_fees_rec IN quote_fees_csr(l_lease_qte_rec.id) LOOP

         delete_line_payment(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_source_object_code   => 'QUOTED_FEE'
         ,p_source_object_id     => l_quote_fees_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END LOOP; */
    END IF;

   /*handle_parent_object_status(
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_parent_object_code       => l_lease_qte_rec.parent_object_code
     ,p_parent_object_id       => l_lease_qte_rec.parent_object_id
     );

   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;*/


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_update_payment;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_update_payment
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_update_payment
  -- Description     : Create/Update Lease Quote pricing options
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_update_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_lease_qte_rec           IN lease_qte_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CREATE_UPDATE_PAYMENT';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);

    -- Record/Table Type Declarations
    l_payment_header_rec   cashflow_hdr_rec_type;
    l_payment_level_tbl    cashflow_level_tbl_type;
    l_lease_qte_rec        lease_qte_rec_type;
    lx_lease_qte_rec       lease_qte_rec_type;
    l_fee_rec              fee_rec_type;
    lx_fee_rec             fee_rec_type;
    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;
    l_all_lines_overriden                 VARCHAR2(3);
    l_entered              VARCHAR2(3);

    CURSOR quote_assets_csr(lc_quote_id IN NUMBER) IS
     SELECT ID
     FROM OKL_ASSETS_B
     WHERE parent_object_id = lc_quote_id
     AND   parent_object_code = 'LEASEQUOTE';

    CURSOR quote_fees_csr(lc_quote_id IN NUMBER) IS
     SELECT ID
     FROM OKL_FEES_B
     WHERE parent_object_id = lc_quote_id
     AND   parent_object_code = 'LEASEQUOTE'
     AND   fee_type <> 'CAPITALIZED';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Populate quote record
    l_lease_qte_rec := populate_quote_rec(p_lease_qte_rec.id,x_return_status);

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lease_qte_rec.TARGET_RATE_TYPE   := p_lease_qte_rec.TARGET_RATE_TYPE;
    l_lease_qte_rec.TARGET_RATE        := p_lease_qte_rec.TARGET_RATE;
    l_lease_qte_rec.TARGET_AMOUNT      := p_lease_qte_rec.TARGET_AMOUNT;
    l_lease_qte_rec.TARGET_FREQUENCY   := p_lease_qte_rec.TARGET_FREQUENCY;
    l_lease_qte_rec.TARGET_ARREARS_YN  := p_lease_qte_rec.TARGET_ARREARS_YN;
    l_lease_qte_rec.TARGET_PERIODS     := p_lease_qte_rec.TARGET_PERIODS;
    l_lease_qte_rec.STRUCTURED_PRICING := p_lease_qte_rec.STRUCTURED_PRICING;
    l_lease_qte_rec.LINE_LEVEL_PRICING := p_lease_qte_rec.LINE_LEVEL_PRICING;
    l_lease_qte_rec.LEASE_RATE_FACTOR  := p_lease_qte_rec.LEASE_RATE_FACTOR;
    l_lease_qte_rec.rate_template_id   := p_lease_qte_rec.rate_template_id;
    l_lease_qte_rec.rate_card_id       := p_lease_qte_rec.rate_card_id;
    l_all_lines_overriden := okl_sales_quote_qa_pvt.are_all_lines_overriden(l_lease_qte_rec.id,l_lease_qte_rec.pricing_method,l_lease_qte_rec.LINE_LEVEL_PRICING ,x_return_status);

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_all_lines_overriden = 'Y' THEN
      l_entered := are_qte_pricing_opts_entered(l_lease_qte_rec,0,x_return_status);

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_entered = 'Y' THEN

       OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_QTE_PMT_ENTERED');
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_lease_qte_rec.TARGET_RATE_TYPE   := NULL;
      l_lease_qte_rec.TARGET_RATE        := NULL;
      l_lease_qte_rec.TARGET_AMOUNT      := NULL;
      l_lease_qte_rec.TARGET_FREQUENCY   := NULL;
      l_lease_qte_rec.TARGET_ARREARS_YN  := NULL;
      l_lease_qte_rec.TARGET_PERIODS     := NULL;
      l_lease_qte_rec.STRUCTURED_PRICING := NULL;
      l_lease_qte_rec.LEASE_RATE_FACTOR  := NULL;
      l_lease_qte_rec.rate_template_id   := NULL;
      l_lease_qte_rec.rate_card_id       := NULL;
    ELSE

      IF l_lease_qte_rec.pricing_method = 'RC' THEN
           IF l_lease_qte_rec.structured_pricing = 'N' AND  l_lease_qte_rec.rate_card_id IS NULL THEN
             OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_RC_MANDATORY');
             RAISE OKL_API.G_EXCEPTION_ERROR;
           ELSIF l_lease_qte_rec.structured_pricing = 'Y' AND  l_lease_qte_rec.lease_rate_factor IS  NULL THEN
             OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_RF_MANDATORY');
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
      ELSIF l_lease_qte_rec.pricing_method NOT IN  ('TR','SY') THEN
           IF l_lease_qte_rec.structured_pricing = 'N' AND  l_lease_qte_rec.rate_template_id IS  NULL THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_SRT_MANDATORY');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           ELSIF l_lease_qte_rec.structured_pricing = 'N' AND  l_lease_qte_rec.target_amount IS  NULL
                 AND l_lease_qte_rec.pricing_method NOT IN  ('SP','SM')
           THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_PA_MANDATORY');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
      END IF;
    END IF;
    IF l_all_lines_overriden = 'N' OR l_entered = 'N' THEN
        IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_PVT.update_lease_qte'
           ,'begin debug call update_lease_qte');
        END IF;
        OKL_LEASE_QUOTE_PVT.update_lease_qte(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_transaction_control  => G_FALSE
         ,p_lease_qte_rec        => l_lease_qte_rec
         ,x_lease_qte_rec        => lx_lease_qte_rec
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);
        IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_PVT.update_lease_qte'
             ,'End debug call update_lease_qte');
        END IF;

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
            ,'begin debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
        END IF;
        okl_lease_quote_cashflow_pvt.delete_cashflows(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_transaction_control  => G_FALSE
         ,p_source_object_code   => 'LEASE_QUOTE'
         ,p_source_object_id     => p_lease_qte_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);
        IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
            ,'End debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
        END IF;

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    IF p_lease_qte_rec.line_level_pricing = 'N' THEN
      FOR l_quote_asset_rec IN quote_assets_csr(l_lease_qte_rec.id) LOOP

         delete_line_payment(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_source_object_code   => 'QUOTED_ASSET'
         ,p_source_object_id     => l_quote_asset_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END LOOP;
   /*   FOR l_quote_fees_rec IN quote_fees_csr(l_lease_qte_rec.id) LOOP

         delete_line_payment(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_source_object_code   => 'QUOTED_FEE'
         ,p_source_object_id     => l_quote_fees_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END LOOP; */
    END IF;

    /*handle_parent_object_status(
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_parent_object_code       => l_lease_qte_rec.parent_object_code
     ,p_parent_object_id       => l_lease_qte_rec.parent_object_id
     );

   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;*/

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END create_update_payment;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_update_line_payment
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_update_line_payment
  -- Description     : Create/Update Lease Quote Aseet/Fee Pricing options and payments
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_update_line_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_fee_rec                 IN fee_rec_type
    ,p_asset_rec               IN asset_rec_type
    ,p_payment_header_rec      IN cashflow_hdr_rec_type
    ,p_payment_level_tbl       IN cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CREATE3';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);


    -- Record/Table Type Declarations
    l_payment_header_rec   cashflow_hdr_rec_type;
    l_payment_level_tbl    cashflow_level_tbl_type;
    l_lease_qte_rec        lease_qte_rec_type;
    lx_lease_qte_rec       lease_qte_rec_type;
    l_fee_rec              fee_rec_type;
    lx_fee_rec             fee_rec_type;
    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;
    l_sp                   VARCHAR2(10);
    l_missing              varchar2(3):= 'N';
    l_pricing_method       VARCHAR2(30);
    l_srt                  NUMBER;
    lv_cash_flow_exists    VARCHAR2(3);
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);

    CURSOR c_check_asset_cash_flow(p_asset_id OKL_ASSETS_B.ID%TYPE)
    IS
    SELECT 'YES'
    FROM   OKL_CASH_FLOW_OBJECTS
    WHERE OTY_CODE = 'QUOTED_ASSET'
    AND   SOURCE_TABLE = 'OKL_ASSETS_B'
    AND   SOURCE_ID    = p_asset_id;

    CURSOR c_check_fee_cash_flow(p_fee_id OKL_FEES_B.ID%TYPE)
    IS
    SELECT 'YES'
    FROM   OKL_CASH_FLOW_OBJECTS
    WHERE OTY_CODE = 'QUOTED_FEE'
    AND   SOURCE_TABLE = 'OKL_FEES_B'
    AND   SOURCE_ID    = p_fee_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   IF  p_payment_header_rec.parent_object_code = 'QUOTED_FEE' THEN
     --Populate fee record
     l_fee_rec := populate_fee_rec(p_fee_rec.id,x_return_status);

     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_fee_rec.RATE_CARD_ID       := p_fee_rec.RATE_CARD_ID;
     l_fee_rec.RATE_TEMPLATE_ID   := p_fee_rec.RATE_TEMPLATE_ID;
     l_fee_rec.STRUCTURED_PRICING := p_fee_rec.STRUCTURED_PRICING;
     l_fee_rec.TARGET_ARREARS     := p_fee_rec.TARGET_ARREARS;
     l_fee_rec.LEASE_RATE_FACTOR  := p_fee_rec.LEASE_RATE_FACTOR;
     l_fee_rec.TARGET_AMOUNT      := p_fee_rec.TARGET_AMOUNT;
     l_fee_rec.TARGET_FREQUENCY   := p_fee_rec.TARGET_FREQUENCY;
     l_fee_rec.PAYMENT_TYPE_ID    := p_fee_rec.PAYMENT_TYPE_ID;

     l_payment_header_rec := p_payment_header_rec;
     l_payment_level_tbl  := p_payment_level_tbl;

     l_payment_header_rec.parent_object_id := l_fee_rec.id;
     l_payment_header_rec.quote_id := l_fee_rec.parent_object_id;
     l_payment_header_rec.type_code:= 'INFLOW';

     IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_FEE_PVT.update_row'
        ,'begin debug call update_row');
     END IF;
     OKL_FEE_PVT.update_row(
        p_api_version    => G_API_VERSION
       ,p_init_msg_list  => G_FALSE
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
       ,p_feev_rec       => l_fee_rec
       ,x_feev_rec       => lx_fee_rec
       );
     IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_FEE_PVT.update_row'
        ,'end debug call update_row');
     END IF;

     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Check if the Cash flows already exists
     OPEN  c_check_fee_cash_flow(p_fee_id => lx_fee_rec.id);
     FETCH c_check_fee_cash_flow into lv_cash_flow_exists;
     CLOSE c_check_fee_cash_flow;
     l_sp := l_fee_rec.structured_pricing;
     l_srt := l_fee_rec.rate_template_id;
     SELECT pricing_method
     INTO l_pricing_method
     FROM okl_lease_quotes_b
     where id = l_fee_Rec.parent_object_id;
   ELSIF  p_payment_header_rec.parent_object_code = 'QUOTED_ASSET' THEN
     l_asset_rec := populate_asset_rec(p_asset_rec.id,x_return_status);

     l_asset_rec.RATE_CARD_ID       := p_asset_rec.RATE_CARD_ID;
     l_asset_rec.RATE_TEMPLATE_ID   := p_asset_rec.RATE_TEMPLATE_ID;
     l_asset_rec.STRUCTURED_PRICING := p_asset_rec.STRUCTURED_PRICING;
     l_asset_rec.TARGET_ARREARS     := p_asset_rec.TARGET_ARREARS;
     l_asset_rec.LEASE_RATE_FACTOR  := p_asset_rec.LEASE_RATE_FACTOR;
     l_asset_rec.TARGET_AMOUNT      := p_asset_rec.TARGET_AMOUNT;
     l_asset_rec.TARGET_FREQUENCY   := p_asset_rec.TARGET_FREQUENCY;

     l_payment_header_rec := p_payment_header_rec;
     l_payment_level_tbl  := p_payment_level_tbl;

     l_payment_header_rec.parent_object_id := l_asset_rec.id;
     l_payment_header_rec.quote_id := l_asset_rec.parent_object_id;
     l_payment_header_rec.type_code:= 'INFLOW';
     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_ASS_PVT.update_row'
         ,'begin debug call update_row');
     END IF;
     OKL_ASS_PVT.update_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec
                           ,x_assv_rec      => lx_asset_rec );
     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_ASS_PVT.update_row'
         ,'end debug call update_row');
     END IF;
     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Check if the Cash flows already exists
     OPEN  c_check_asset_cash_flow(p_asset_id => lx_asset_rec.id);
     FETCH c_check_asset_cash_flow into lv_cash_flow_exists;
     CLOSE c_check_asset_cash_flow;
     l_sp := l_asset_rec.structured_pricing;
     l_srt := l_asset_rec.rate_template_id;
     SELECT pricing_method
     INTO l_pricing_method
     FROM okl_lease_quotes_b
     where id = l_asset_rec.parent_object_id;
   END IF;
    IF l_pricing_method = 'SM' THEN
     FOR k IN l_payment_level_tbl.FIRST..l_payment_level_tbl.LAST LOOP
       IF l_payment_level_tbl.exists(k) THEN
        IF (l_payment_level_tbl(k).stub_days IS NOT NULL AND l_payment_level_tbl(k).stub_amount IS NULL )
        OR (l_payment_level_tbl(k).periods IS NOT NULL AND l_payment_level_tbl(k).periodic_amount IS NULL )
        THEN
         l_missing := 'Y';
         EXIT;
        END IF;
       END IF;
     END LOOP;
     IF l_missing = 'N' THEN
      IF l_sp = 'N' THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_NO_MP_STR');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     END IF;
     IF l_missing = 'Y' THEN
      IF l_sp = 'N' AND l_srt IS NULL THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_SRT_MANDATORY');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     END IF;
   END IF;
   IF ((l_payment_level_tbl.COUNT > 0 AND l_payment_header_rec.stream_type_id IS NULL) OR
      (l_payment_header_rec.stream_type_id IS NOT NULL AND l_payment_level_tbl.COUNT = 0 )) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_EPT_PAYMENT_NA');
      RAISE OKL_API.G_EXCEPTION_ERROR;
   ELSE
     IF (lv_cash_flow_exists = 'YES') THEN

       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow'
         ,'begin debug call update_cashflow');
       END IF;
       OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,p_transaction_control => G_FALSE
                           ,p_cashflow_header_rec => l_payment_header_rec
                           ,p_cashflow_level_tbl => l_payment_level_tbl
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data);
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow'
         ,'end debug call update_cashflow');
       END IF;

       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     ELSE

       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow'
         ,'begin debug call create_cashflow');
       END IF;
       OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,p_transaction_control => G_FALSE
                           ,p_cashflow_header_rec => l_payment_header_rec
                           ,p_cashflow_level_tbl => l_payment_level_tbl
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data);
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow'
         ,'end debug call create_cashflow');
       END IF;

       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
   END IF;

   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   /*SELECT parent_object_id,parent_object_code INTO l_p_id,l_p_code
   FROM okl_lease_quotes_b where ID = nvl(l_fee_rec.parent_object_id,l_Asset_rec.parent_object_id);

   handle_parent_object_status(
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_parent_object_code       => l_p_code
     ,p_parent_object_id       => l_p_id
     );

   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;*/

   OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END create_update_line_payment;
  -------------------------------------------------------------------------------
  -- PROCEDURE create_update_line_payment
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_update_line_payment
  -- Description     : Create/Update Lease Quote Fee Pricing options
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_update_line_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_fee_rec                 IN fee_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

   -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CREAT2';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);


    -- Record/Table Type Declarations

    l_payment_header_rec   cashflow_hdr_rec_type;
    l_payment_level_tbl    cashflow_level_tbl_type;
    l_lease_qte_rec        lease_qte_rec_type;
    lx_lease_qte_rec       lease_qte_rec_type;
    l_fee_rec              fee_rec_type;
    lx_fee_rec             fee_rec_type;
    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --populate fee record
    l_fee_rec := populate_fee_rec(p_fee_rec.id,x_return_status);

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_fee_rec.RATE_CARD_ID       := p_fee_rec.RATE_CARD_ID;
    l_fee_rec.RATE_TEMPLATE_ID   := p_fee_rec.RATE_TEMPLATE_ID;
    l_fee_rec.STRUCTURED_PRICING := p_fee_rec.STRUCTURED_PRICING;
    l_fee_rec.TARGET_ARREARS     := p_fee_rec.TARGET_ARREARS;
    l_fee_rec.LEASE_RATE_FACTOR  := p_fee_rec.LEASE_RATE_FACTOR;
    l_fee_rec.TARGET_AMOUNT      := p_fee_rec.TARGET_AMOUNT;
    l_fee_rec.TARGET_FREQUENCY   := p_fee_rec.TARGET_FREQUENCY;
    l_fee_rec.PAYMENT_TYPE_ID    := p_fee_rec.PAYMENT_TYPE_ID;

    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_FEE_PVT.update_row'
         ,'begin debug call update_row');
    END IF;
    OKL_FEE_PVT.update_row(
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_feev_rec       => l_fee_rec
     ,x_feev_rec       => lx_fee_rec
     );
     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_FEE_PVT.update_row'
         ,'end debug call update_row');
     END IF;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
         ,'begin debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
     END IF;
        okl_lease_quote_cashflow_pvt.delete_cashflows(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_transaction_control  => G_FALSE
         ,p_source_object_code   => 'QUOTED_FEE'
         ,p_source_object_id     => p_fee_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
         ,'End debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
    END IF;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*SELECT parent_object_id,parent_object_code INTO l_p_id,l_p_code
   FROM okl_lease_quotes_b where ID = l_fee_rec.parent_object_id;

   handle_parent_object_status(
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_parent_object_code       => l_p_code
     ,p_parent_object_id       => l_p_id
     );

   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;*/



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_update_line_payment;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_update_line_payment
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_update_line_payment
  -- Description     : Create/Update Lease Quote Asset Pricing options
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_update_line_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_asset_rec               IN asset_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CREATE1';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);


    -- Record/Table Type Declarations
    l_payment_header_rec   cashflow_hdr_rec_type;
    l_payment_level_tbl    cashflow_level_tbl_type;
    l_lease_qte_rec        lease_qte_rec_type;
    lx_lease_qte_rec       lease_qte_rec_type;
    l_fee_rec              fee_rec_type;
    lx_fee_rec             fee_rec_type;
    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_asset_rec := populate_asset_rec(p_asset_rec.id,x_return_status);

    l_asset_rec.RATE_CARD_ID       := p_asset_rec.RATE_CARD_ID;
    l_asset_rec.RATE_TEMPLATE_ID   := p_asset_rec.RATE_TEMPLATE_ID;
    l_asset_rec.STRUCTURED_PRICING := p_asset_rec.STRUCTURED_PRICING;
    l_asset_rec.TARGET_ARREARS     := p_asset_rec.TARGET_ARREARS;
    l_asset_rec.LEASE_RATE_FACTOR  := p_asset_rec.LEASE_RATE_FACTOR;
    l_asset_rec.TARGET_AMOUNT      := p_asset_rec.TARGET_AMOUNT;
    l_asset_rec.TARGET_FREQUENCY   := p_asset_rec.TARGET_FREQUENCY;

    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_ASS_PVT.update_row'
        ,'begin debug call update_row');
    END IF;
    OKL_ASS_PVT.update_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec
                           ,x_assv_rec      => lx_asset_rec );
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_ASS_PVT.update_row'
         ,'begin debug call update_row');
    END IF;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
         ,'begin debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
     END IF;
        okl_lease_quote_cashflow_pvt.delete_cashflows(
          p_api_version          => G_API_VERSION
         ,p_init_msg_list        => G_FALSE
         ,p_transaction_control  => G_FALSE
         ,p_source_object_code   => 'QUOTED_ASSET'
         ,p_source_object_id     => p_asset_rec.id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_lease_quote_cashflow_pvt.delete_cash_flows'
         ,'End debug call okl_lease_quote_cashflow_pvt.delete_cash_flows');
    END IF;

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*SELECT parent_object_id,parent_object_code INTO l_p_id,l_p_code
   FROM okl_lease_quotes_b where ID = l_asset_rec.parent_object_id;

   handle_parent_object_status(
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_parent_object_code       => l_p_code
     ,p_parent_object_id       => l_p_id
     );

   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;*/



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_update_line_payment;

  -------------------------------------------------------------------------------
  -- PROCEDURE delete_line_payment
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_line_payment
  -- Description     : Delete Lease Quote Aseet/Fee Pricing options and payments
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE delete_line_payment(
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_source_object_code      IN  VARCHAR2
    ,p_source_object_id        IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'DELETE_LINE_PAYMENT';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled        VARCHAR2(10);


    -- Record/Table Type Declarations
    l_source_object_code   okl_cash_flow_objects.OTY_CODE%TYPE;
    l_source_object_id     okl_cash_flow_objects.SOURCE_ID%TYPE;
    l_lease_qte_rec        lease_qte_rec_type;
    lx_lease_qte_rec       lease_qte_rec_type;
    l_fee_rec              fee_rec_type;
    lx_fee_rec             fee_rec_type;
    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;

     lv_cash_flow_exists    VARCHAR2(3);

    CURSOR c_check_cash_flow(p_source_id NUMBER,p_source_code VARCHAR2)
    IS
    SELECT 'YES'
    FROM   OKL_CASH_FLOW_OBJECTS
    WHERE OTY_CODE = p_source_code
    AND   SOURCE_ID = p_source_id;


  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     l_source_object_id   := p_source_object_id;
     l_source_object_code := p_source_object_code;

   IF  l_source_object_code = 'QUOTED_FEE' THEN
     --Populate fee record
     l_fee_rec := populate_fee_rec(l_source_object_id,x_return_status);

     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_fee_rec.RATE_CARD_ID       := NULL;
     l_fee_rec.RATE_TEMPLATE_ID   := NULL;
     l_fee_rec.STRUCTURED_PRICING := NULL;
     l_fee_rec.TARGET_ARREARS     := NULL;
     l_fee_rec.LEASE_RATE_FACTOR  := NULL;
     l_fee_rec.TARGET_AMOUNT  := NULL;

     IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_FEE_PVT.update_row'
        ,'begin debug call update_row');
     END IF;
     OKL_FEE_PVT.update_row(
        p_api_version    => G_API_VERSION
       ,p_init_msg_list  => G_FALSE
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
       ,p_feev_rec       => l_fee_rec
       ,x_feev_rec       => lx_fee_rec
       );
     IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_FEE_PVT.update_row'
        ,'end debug call update_row');
     END IF;

     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

   ELSIF  l_source_object_code = 'QUOTED_ASSET' THEN
     l_asset_rec := populate_asset_rec(l_source_object_id,x_return_status);

     l_asset_rec.RATE_CARD_ID       := NULL;
     l_asset_rec.RATE_TEMPLATE_ID   := NULL;
     l_asset_rec.STRUCTURED_PRICING := NULL;
     l_asset_rec.TARGET_ARREARS     := NULL;
     l_asset_rec.LEASE_RATE_FACTOR  := NULL;
     l_asset_rec.TARGET_AMOUNT  := NULL;

     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_ASS_PVT.update_row'
         ,'begin debug call update_row');
     END IF;
     OKL_ASS_PVT.update_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec
                           ,x_assv_rec      => lx_asset_rec );

     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_ASS_PVT.update_row'
         ,'end debug call update_row');
     END IF;
     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
   END IF;
    -- Check if the Cash flows already exists
     OPEN  c_check_cash_flow(p_source_id => l_source_object_id,p_source_code => l_source_object_code);
     FETCH c_check_cash_flow into lv_cash_flow_exists;
     CLOSE c_check_cash_flow;

     IF lv_cash_flow_exists = 'YES' THEN

       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows'
         ,'begin debug call delete_cashflows');
       END IF;
       OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,p_transaction_control => G_FALSE
                           ,p_source_object_code => l_source_object_code
                           ,p_source_object_id => l_source_object_id
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data);

       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows'
         ,'end debug call delete_cashflows');
       END IF;

       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;

   IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = G_RET_STS_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END delete_line_payment;

  -------------------------------------------------------------------------------
  -- FUNCTION get_periods
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_periods
  -- Description     : returns the periods for line pricing options table
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SKGAUTAM created
  -- End of comments
  FUNCTION get_periods(p_casflow_id    IN  NUMBER)
      RETURN VARCHAR2 IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'GET PERIODS';

    CURSOR check_stub(l_cashflow_id NUMBER) IS
         SELECT   STUB_DAYS,
                  STUB_AMOUNT
         FROM   OKL_CASH_FLOW_LEVELS
         WHERE  CAF_ID = l_cashflow_id;

    CURSOR get_periods(l_cashflow_id NUMBER) IS
           SELECT SUM(NUMBER_OF_PERIODS)
           FROM   OKL_CASH_FLOW_LEVELS
           WHERE  CAF_ID = l_cashflow_id;

    l_stub_days       NUMBER;
    l_stub_amount     NUMBER;
    l_count           NUMBER;
    l_periods         VARCHAR2(10);
    l_stub_flg        VARCHAR2(1):= 'N';


  BEGIN

     OPEN get_periods(p_casflow_id);
     FETCH get_periods INTO l_periods;
     CLOSE get_periods;
     FOR l_stub_rec IN check_stub(p_casflow_id) LOOP
     IF (l_stub_rec.stub_days IS NOT NULL OR
         l_stub_rec.stub_amount IS NOT NULL) THEN
         l_stub_flg := 'Y';
     END IF;
     END LOOP;

     IF l_stub_flg = 'Y' THEN
        RETURN OKL_ACCOUNTING_UTIL.get_lookup_meaning('OKL_QUOTE_PRICING_OPTIONS','STU');
     ELSE
        RETURN l_periods;
     END IF;

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);
         RETURN NULL;


  END;

  -------------------------------------------------------------------------------
  -- FUNCTION get_amount
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_amount
  -- Description     : returns the periodic amount for line pricing options table
  --
  -- Business Rules  :
  --
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-SEP-2005 SK

  FUNCTION get_amount(p_casflow_id         IN  NUMBER)
      RETURN VARCHAR2 IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'GET_AMOUNT';

    CURSOR check_stub(l_cashflow_id NUMBER) IS
         SELECT   STUB_DAYS,
                  STUB_AMOUNT
         FROM   OKL_CASH_FLOW_LEVELS
         WHERE  CAF_ID = l_cashflow_id;

    CURSOR check_count(l_cashflow_id NUMBER) IS
           SELECT COUNT(ID)
           FROM   OKL_CASH_FLOW_LEVELS
           WHERE  CAF_ID = l_cashflow_id;

    CURSOR get_amount(l_cashflow_id NUMBER) IS
           SELECT AMOUNT
           FROM   OKL_CASH_FLOW_LEVELS
           WHERE  CAF_ID = l_cashflow_id;

    l_stub_days       NUMBER;
    l_stub_amount     NUMBER;
    l_count           NUMBER;
    l_amount          VARCHAR2(10);
    l_stub_flg        VARCHAR2(1):= 'N';


  BEGIN

     OPEN check_count(p_casflow_id);
     FETCH check_count INTO l_count;
     CLOSE check_count;

     OPEN get_amount(p_casflow_id);
     FETCH get_amount INTO l_amount;
     CLOSE get_amount;
     FOR l_stub_rec IN check_stub(p_casflow_id) LOOP
     IF (l_stub_rec.stub_days IS NOT NULL OR
         l_stub_rec.stub_amount IS NOT NULL) THEN
         l_stub_flg := 'Y';
     END IF;
     END LOOP;

     IF l_stub_flg = 'Y' THEN
        RETURN OKL_ACCOUNTING_UTIL.get_lookup_meaning('OKL_QUOTE_PRICING_OPTIONS','VAR');
     ELSIF l_count > 1 THEN
        RETURN OKL_ACCOUNTING_UTIL.get_lookup_meaning('OKL_QUOTE_PRICING_OPTIONS','VAR');
     ELSE
        RETURN l_amount;
     END IF;

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);
         RETURN NULL;


  END;

END OKL_LEASE_QUOTE_PRICING_PVT;

/
