--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_ASSET_PVT" AS
/* $Header: OKLRQUAB.pls 120.44.12010000.2 2008/10/23 14:53:28 kkorrapo ship $ */

  ------------------------------------------------------------------------------
  -- GLOBAL OKL MESSAGES
  ------------------------------------------------------------------------------
  G_UNITS_VALUE             CONSTANT  VARCHAR2(200) := 'OKL_LLA_ITEM_RECORD';

--Bug#7291307 :Adding start
 	   -----------------------------------
 	   -- PROCEDURE sync_tradein_description
 	   -----------------------------------

 	    PROCEDURE sync_tradein_description(p_api_version   IN  NUMBER,
 	                                           p_init_msg_list IN  VARCHAR2,
 	                                       x_msg_count     OUT NOCOPY NUMBER,
 	                                       x_msg_data      OUT NOCOPY VARCHAR2,
 	                                       x_return_status OUT NOCOPY VARCHAR2,
 	                                                                   p_quote_id          IN  NUMBER,
 	                                                                   p_description   IN VARCHAR2
 	                                                         ) IS

 	         l_api_version        CONSTANT NUMBER := 1;
 	         l_api_name        CONSTANT VARCHAR2(30)  := 'sync_tradein_description';

 	        cursor adj_csr is
 	           SELECT costadj.id
 	           FROM   okl_cost_adjustments_b costadj,
 	                  okl_assets_b asset
 	           WHERE costadj.adjustment_source_type = 'TRADEIN'
 	           AND  costadj.parent_object_id = asset.id
 	           AND  costadj.parent_object_code = 'ASSET'
 	           AND  asset.parent_object_id = p_quote_id
 	           AND  asset.parent_object_code = 'LEASEQUOTE';

 	          type rowid_tbl is table of okl_cost_adjustments_b.ID%TYPE
 	               index  by binary_integer ;
 	          l_rowid_tbl       rowid_tbl;
 	          L_FETCH_SIZE      NUMBER := 5000;
 	         l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

 	     begin
 	         ------------------------------------------------------------
 	         -- Start processing
 	         ------------------------------------------------------------

 	         x_return_status := Okl_Api.G_RET_STS_SUCCESS;

 	         l_return_status := Okl_Api.START_ACTIVITY(
 	                 p_api_name        => l_api_name,
 	                 p_pkg_name        => G_PKG_NAME,
 	                 p_init_msg_list        => p_init_msg_list,
 	                 l_api_version        => l_api_version,
 	                 p_api_version        => p_api_version,
 	                 p_api_type        => '_PVT',
 	                 x_return_status        => l_return_status);

 	         IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
 	                 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
 	         ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
 	                 RAISE Okl_Api.G_EXCEPTION_ERROR;
 	         END IF;

 	     OPEN  adj_csr;
 	         LOOP
 	       EXIT WHEN adj_csr%NOTFOUND;
 	       l_rowid_tbl.delete;
 	       FETCH adj_csr BULK COLLECT INTO l_rowid_tbl limit L_FETCH_SIZE;

 	       IF l_rowid_tbl.count > 0 then

 	             forall indx in l_rowid_tbl.first..l_rowid_tbl.last
 	             UPDATE OKL_COST_ADJUSTMENTS_TL
 	             SET
 	             description = p_description
 	             WHERE ID = l_rowid_tbl(indx)
 	                 and  userenv('LANG') in (LANGUAGE, SOURCE_LANG);
 	       end if;
 	     end loop;

 	         Okl_Api.END_ACTIVITY (
 	                 x_msg_count        => x_msg_count,
 	                 x_msg_data        => x_msg_data);

 	    EXCEPTION
 	         WHEN OKL_API.G_EXCEPTION_ERROR THEN
 	           x_return_status := G_RET_STS_ERROR;
 	         WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
 	           x_return_status := G_RET_STS_UNEXP_ERROR;
 	         WHEN OTHERS THEN
 	           OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
 	                                p_msg_name     => G_DB_ERROR,
 	                                p_token1       => G_PROG_NAME_TOKEN,
 	                                p_token1_value => 'OKLRQUAB.sync_tradein',
 	                                p_token2       => G_SQLCODE_TOKEN,
 	                                p_token2_value => sqlcode,
 	                                p_token3       => G_SQLERRM_TOKEN,
 	                                p_token3_value => sqlerrm);

 	           x_return_status := G_RET_STS_UNEXP_ERROR;
 	   END sync_tradein_description;
   --Bug#7291307 :Adding end

  --Bug # 5142940 ssdeshpa start
  -----------------------------------
  -- PROCEDURE process_adj_cashflows
  -----------------------------------
   PROCEDURE process_adj_cashflows(p_cdjv_rec      IN okl_cdj_pvt.cdjv_rec_type
                                  ,p_event_mode    IN VARCHAR2
                                  ,x_msg_count               OUT NOCOPY NUMBER
                                  ,x_msg_data                OUT NOCOPY VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2) IS

     l_p_id  NUMBER;
     l_start_date DATE;
     l_cf_hdr_rec           cashflow_hdr_rec_type;
     l_cashflow_level_tbl   cashflow_level_tbl_type;
     l_adj_assets_rec       okl_cdj_pvt.cdjv_rec_type;
     lv_parent_object_code  okl_lease_quotes_b.parent_object_code%TYPE;

     CURSOR get_quote_rec(p_quote_id NUMBER) IS
      SELECT qte.id, qte.expected_start_date, qte.parent_object_code
      FROM okl_assets_b ast,
           okl_lease_quotes_b qte
     WHERE qte.id = ast.parent_object_id
     AND   ast.id= p_quote_id;

     BEGIN
     l_adj_assets_rec := p_cdjv_rec;
     OPEN get_quote_rec(l_adj_assets_rec.parent_object_id);
     FETCH get_quote_rec INTO l_p_id, l_start_date, lv_parent_object_code;
     CLOSE get_quote_rec;
     IF(p_event_mode ='delete') THEN
        IF(l_adj_assets_rec.adjustment_source_type='DOWN_PAYMENT') THEN
           OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (
                                 p_api_version   => G_API_VERSION
                                ,p_init_msg_list => G_FALSE
                                ,p_transaction_control => 'T'
                                ,p_source_object_code  => 'QUOTED_ASSET_DOWN_PAYMENT'
                                ,p_source_object_id    => l_adj_assets_rec.parent_object_id
                                ,x_return_status       => x_return_status
                                ,x_msg_count           => x_msg_count
                                ,x_msg_data            => x_msg_data);

            IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
      END IF;
     ELSIF(p_event_mode ='create') THEN
       --Create Rec Structure for Cash flows

       l_cf_hdr_rec.type_code      :='INFLOW'; -- mandatory.  Allowable values: 'INFLOW' 'OUTFLOW'
       l_cf_hdr_rec.stream_type_id := l_adj_assets_rec.stream_type_id;-- optional for quick quotes only
       l_cf_hdr_rec.status_code    :='CURRENT'; -- status code for cashflow
       l_cf_hdr_rec.arrears_flag   :='N';-- mandatory
       l_cf_hdr_rec.frequency_code :='M';-- mandatory
       --,dnz_periods              VARCHAR2(80)    -- used for possible display in lease quote UI (TBD)
       --,dnz_periodic_amount      VARCHAR2(80)    -- used for possible display in lease quote UI (TBD)
       l_cf_hdr_rec.parent_object_code := 'QUOTED_ASSET_DOWN_PAYMENT';-- mandatory (see 'insert_rows' procedure for possible values)
       l_cf_hdr_rec.parent_object_id   := l_adj_assets_rec.parent_object_id; -- mandatory

       IF (lv_parent_object_code = 'LEASEOPP') THEN
         l_cf_hdr_rec.quote_type_code    := 'LQ'; -- mandatory  Allowable values: 'LQ' 'QQ' 'LA'
       ELSIF (lv_parent_object_code = 'LEASEAPP') THEN
         l_cf_hdr_rec.quote_type_code    := 'LA'; -- mandatory  Allowable values: 'LQ' 'QQ' 'LA'
       END IF;

       l_cf_hdr_rec.quote_id           := l_p_id;-- mandatory
       --Create end
       l_cashflow_level_tbl(1).start_date := l_start_date;
       l_cashflow_level_tbl(1).periods := 1;
       l_cashflow_level_tbl(1).periodic_amount := l_adj_assets_rec.value;
       l_cashflow_level_tbl(1).record_mode := 'CREATE';
       --Create Cash Flow for Asset
       OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
                          p_api_version   => G_API_VERSION
                         ,p_init_msg_list => G_FALSE
                         ,p_transaction_control => 'T'
                         ,p_cashflow_header_rec => l_cf_hdr_rec
                         ,p_cashflow_level_tbl => l_cashflow_level_tbl
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data);

              IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

     ELSIF(p_event_mode ='update') THEN
      IF(l_adj_assets_rec.adjustment_source_type='DOWN_PAYMENT') THEN
       OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (
                             p_api_version   => G_API_VERSION
                            ,p_init_msg_list => G_FALSE
                            ,p_transaction_control => 'T'
                            ,p_source_object_code  => 'QUOTED_ASSET_DOWN_PAYMENT'
                            ,p_source_object_id    => l_adj_assets_rec.parent_object_id
                            ,x_return_status       => x_return_status
                            ,x_msg_count           => x_msg_count
                            ,x_msg_data            => x_msg_data);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      IF(l_adj_assets_rec.adjustment_source_type='DOWN_PAYMENT' AND
         l_adj_assets_rec.processing_type='BILL' AND
         l_adj_assets_rec.stream_type_id IS NOT NULL) THEN

           --Create Rec Structure for Cash flows
           l_cf_hdr_rec.type_code      :='INFLOW'; -- mandatory.  Allowable values: 'INFLOW' 'OUTFLOW'
           l_cf_hdr_rec.stream_type_id := l_adj_assets_rec.stream_type_id;-- optional for quick quotes only
           l_cf_hdr_rec.status_code    :='CURRENT'; -- status code for cashflow
           l_cf_hdr_rec.arrears_flag   :='N';-- mandatory
           l_cf_hdr_rec.frequency_code :='M';-- mandatory

           l_cf_hdr_rec.parent_object_code := 'QUOTED_ASSET_DOWN_PAYMENT';-- mandatory (see 'insert_rows' procedure for possible values)
           l_cf_hdr_rec.parent_object_id   := l_adj_assets_rec.parent_object_id; -- mandatory


       	   IF (lv_parent_object_code = 'LEASEOPP') THEN
         	 l_cf_hdr_rec.quote_type_code    := 'LQ'; -- mandatory  Allowable values: 'LQ' 'QQ' 'LA'
       	   ELSIF (lv_parent_object_code = 'LEASEAPP') THEN
         	 l_cf_hdr_rec.quote_type_code    := 'LA'; -- mandatory  Allowable values: 'LQ' 'QQ' 'LA'
       	   END IF;

           l_cf_hdr_rec.quote_id           := l_p_id;-- mandatory
           --Create end
           l_cashflow_level_tbl(1).start_date := l_start_date;
           l_cashflow_level_tbl(1).periods := 1;
           l_cashflow_level_tbl(1).periodic_amount := l_adj_assets_rec.value;
           l_cashflow_level_tbl(1).record_mode := 'CREATE';
           --Create Cash Flow for Down Payment
           OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
                              p_api_version   => G_API_VERSION
                             ,p_init_msg_list => G_FALSE
                             ,p_transaction_control => 'T'
                             ,p_cashflow_header_rec => l_cf_hdr_rec
                             ,p_cashflow_level_tbl => l_cashflow_level_tbl
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data);

            IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = G_RET_STS_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

      END IF;

     END IF;
     EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          x_return_status := G_RET_STS_ERROR;
        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status := G_RET_STS_UNEXP_ERROR;
        WHEN OTHERS THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => G_DB_ERROR,
                               p_token1       => G_PROG_NAME_TOKEN,
                               p_token1_value => 'OKLRQUAB.pr_adj_cfl',
                               p_token2       => G_SQLCODE_TOKEN,
                               p_token2_value => sqlcode,
                               p_token3       => G_SQLERRM_TOKEN,
                               p_token3_value => sqlerrm);

          x_return_status := G_RET_STS_UNEXP_ERROR;
   END process_adj_cashflows;

  -----------------------------------
  -- FUNCTION is_pricing_method_equal
  -----------------------------------
  FUNCTION is_pricing_method_equal(p_source_quote_id IN NUMBER,
  								   p_target_quote_id IN NUMBER)
	RETURN VARCHAR2 IS

	lv_source_pricing_type	VARCHAR2(15);
	lv_target_pricing_type	VARCHAR2(15);
  BEGIN
    select pricing_method
    into lv_source_pricing_type
    from okl_lease_quotes_b
    where id = p_source_quote_id;

    select pricing_method
    into lv_target_pricing_type
    from okl_lease_quotes_b
    where id = p_target_quote_id;

    IF (lv_source_pricing_type = lv_target_pricing_type) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
	END IF;
  END is_pricing_method_equal;

  ---------------------------------------
  -- PROCEDURE process_link_asset_amounts
  ---------------------------------------
  --Fixing Bug # 4735811 Start
  PROCEDURE process_link_asset_amounts (
    p_adj_amount       IN NUMBER,
    p_assoc_assets_tbl IN OUT NOCOPY asset_adjustment_tbl_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS

    l_program_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'process_link_asset_amounts';
    l_line_amount               NUMBER;
    l_assoc_assets_tbl          asset_adjustment_tbl_type;
    l_assoc_amount              NUMBER;
    l_assoc_total               NUMBER;
    l_currency_code             VARCHAR2(15);
    lv_parent_object_code       VARCHAR2(30);
    l_compare_amt               NUMBER;
    l_diff                      NUMBER;
    l_adj_rec                   BINARY_INTEGER;
    lx_return_status            VARCHAR2(1);
    lv_pricing_method       OKL_LEASE_QUOTES_B.PRICING_METHOD%TYPE;
    l_quote_id                  NUMBER;

    ln_index					NUMBER;

   CURSOR c_get_quote_id(p_asset_id NUMBER) IS
       SELECT PARENT_OBJECT_ID
       FROM OKL_ASSETS_B
       WHERE ID = p_asset_id
       AND PARENT_OBJECT_CODE='LEASEQUOTE';

   CURSOR c_get_parent_object_code(p_quote_id NUMBER) IS
      SELECT parent_object_code
      FROM   okl_lease_quotes_b
      WHERE  id = p_quote_id;
   BEGIN

    l_assoc_total := 0;
    l_assoc_assets_tbl := p_assoc_assets_tbl;

    ln_index := l_assoc_assets_tbl.FIRST;

    OPEN c_get_quote_id(l_assoc_assets_tbl(ln_index).parent_object_id);
    FETCH c_get_quote_id INTO l_quote_id;
    CLOSE c_get_quote_id;

    IF(l_quote_id IS NOT NULL) THEN
       OPEN c_get_parent_object_code(l_quote_id);
       FETCH c_get_parent_object_code INTO lv_parent_object_code;
       CLOSE c_get_parent_object_code;
    ELSE
       RETURN;
    END IF;
    IF (lv_parent_object_code = 'LEASEOPP') THEN
      SELECT currency_code
      INTO   l_currency_code
      FROM   okl_lease_opportunities_b lop,
             okl_lease_quotes_b lsq
      WHERE  lsq.parent_object_code = lv_parent_object_code
      AND    lsq.parent_object_id = lop.id
      AND    lsq.id = l_quote_id;
    ELSIF (lv_parent_object_code = 'LEASEAPP') THEN
      SELECT currency_code
      INTO   l_currency_code
      FROM   okl_lease_applications_b lap,
             okl_lease_quotes_b lsq
      WHERE  lsq.parent_object_code = lv_parent_object_code
      AND    lsq.parent_object_id = lap.id
      AND    lsq.id = l_quote_id;
    END IF;

    l_line_amount     := p_adj_amount;

   ----------------------------------------------------------------------------
    -- 2. Loop through to determine associated amounts and round off the amounts
   ----------------------------------------------------------------------------
    FOR i IN l_assoc_assets_tbl.FIRST .. l_assoc_assets_tbl.LAST LOOP

      IF l_assoc_assets_tbl.EXISTS(i) THEN
        --Fixing Bug # 4735811 Start
        --GIVING NPE when Quick Allocate
        IF (l_assoc_assets_tbl(i).value IS NULL) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_LINKASSET_NULL_FOUND');
            RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Fixing Bug # 4735811 End
       l_assoc_amount := l_assoc_assets_tbl(i).value;

        l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                           p_currency_code => l_currency_code);

        l_assoc_assets_tbl(i).value := l_assoc_amount;

        l_assoc_total := l_assoc_total + l_assoc_amount;

      END IF;

    END LOOP;

----------------------------------------------------------------------------------------------------
    -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
----------------------------------------------------------------------------------------------------
    IF l_assoc_total <> l_line_amount THEN

      l_diff := ABS(l_assoc_total - l_line_amount);

      FOR i IN l_assoc_assets_tbl.FIRST .. l_assoc_assets_tbl.LAST LOOP

        IF l_assoc_assets_tbl.EXISTS(i) THEN

          -- if the total split amount is less than line amount add the difference amount to the
          -- asset with less amount and if the total split amount is greater than the line amount
          -- than subtract the difference amount from the asset with highest amount

          IF i = l_assoc_assets_tbl.FIRST THEN

            l_adj_rec     := i;
            l_compare_amt := l_assoc_assets_tbl(i).value;

          ELSIF (l_assoc_total < l_line_amount) AND (l_assoc_assets_tbl(i).value <= l_compare_amt) OR
                (l_assoc_total > l_line_amount) AND (l_assoc_assets_tbl(i).value >= l_compare_amt) THEN

              l_adj_rec     := i;
              l_compare_amt := l_assoc_assets_tbl(i).value;

          END IF;

        END IF;

      END LOOP;

      IF l_assoc_total < l_line_amount THEN

        l_assoc_assets_tbl(l_adj_rec).value := l_assoc_assets_tbl(l_adj_rec).value + l_diff;

      ELSE

        l_assoc_assets_tbl(l_adj_rec).value := l_assoc_assets_tbl(l_adj_rec).value - l_diff;

      END IF;

    END IF;

    p_assoc_assets_tbl := l_assoc_assets_tbl;
    x_return_status  := G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_link_asset_amounts;
  --Fixing Bug # 4735811 End

  ------------------------------------------------------------------------------
    --Fixing Bug # 4759578 Start
      PROCEDURE process_link_assets(p_api_version          IN  NUMBER,
                                 p_init_msg_list           IN  VARCHAR2,
                                 p_transaction_control     IN  VARCHAR2,
                                 p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                                 x_asset_adj_tbl           OUT NOCOPY  asset_adjustment_tbl_type,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY VARCHAR2) IS

      l_program_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'process_link_asset_amounts';
      l_line_amount               NUMBER;
      l_asset_adj_tbl             asset_adjustment_tbl_type;
      l_assoc_amount              NUMBER;
      l_assoc_total               NUMBER;
      l_currency_code             VARCHAR2(15);
      lv_parent_object_code       VARCHAR2(30);
      l_compare_amt               NUMBER;
      l_diff                      NUMBER;
      l_adj_rec                   BINARY_INTEGER;
      lx_return_status            VARCHAR2(1);
      lv_pricing_method       	  OKL_LEASE_QUOTES_B.PRICING_METHOD%TYPE;
      l_quote_id                  NUMBER;
      ln_index					  NUMBER;

      BEGIN
      IF p_transaction_control = G_TRUE THEN
        SAVEPOINT l_program_name;
      END IF;

      IF p_init_msg_list = G_TRUE THEN
        FND_MSG_PUB.initialize;
      END IF;

      l_asset_adj_tbl := p_asset_adj_tbl;

      -- Validate Adjustment assets amount
      ln_index := l_asset_adj_tbl.FIRST;
      IF (l_asset_adj_tbl IS NOT NULL AND l_asset_adj_tbl.COUNT>0 ) THEN

        process_link_asset_amounts(p_adj_amount        =>  l_asset_adj_tbl(ln_index).adjustment_amount,
                                   p_assoc_assets_tbl  =>  l_asset_adj_tbl,
                                   x_return_status     =>  x_return_status);

         IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
       x_asset_adj_tbl := l_asset_adj_tbl;
       x_return_status := G_RET_STS_SUCCESS;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN

        x_return_status := G_RET_STS_ERROR;

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        x_return_status := G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DB_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_program_name,
                             p_token2       => G_SQLCODE_TOKEN,
                             p_token2_value => sqlcode,
                             p_token3       => G_SQLERRM_TOKEN,
                             p_token3_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
    END process_link_assets;
  --Fixing Bug # 4759578 End
  ---------------------------------------------------------------------------------------------------
  -------------------------------------------
  -- PROCEDURE validate_subsidy_applicability
  -------------------------------------------
  FUNCTION validate_subsidy_applicability(p_inv_item_id     IN NUMBER,
                                          p_subsidy_id      IN NUMBER,
                                          p_exp_start_date  IN DATE,
                                          p_inv_org_id      IN NUMBER,
                                          p_currency_code   IN VARCHAR2,
                                          p_authoring_org_id  IN NUMBER,
                                          p_cust_acct_id    IN NUMBER,
                                          p_product_id      IN NUMBER,
                                          p_sales_rep_id    IN NUMBER)
    RETURN VARCHAR2 IS

    lv_asset_applicable   VARCHAR2(1);
  halt_validation     EXCEPTION;

  BEGIN
  lv_asset_applicable := okl_asset_subsidy_pvt.validate_subsidy_applicability
        (p_subsidy_id          => p_subsidy_id,
                 p_start_date          => p_exp_start_date,
                 p_inv_item_id         => p_inv_item_id,
                 p_inv_org_id          => p_inv_org_id,
                 p_currency_code       => p_currency_code,
                 p_authoring_org_id    => p_authoring_org_id,
                 p_cust_account_id     => p_cust_acct_id,
                 p_pdt_id              => p_product_id,
                 p_sales_rep_id        => p_sales_rep_id);

    RETURN  lv_asset_applicable;
  EXCEPTION
    When halt_validation then
        Return(lv_asset_applicable);
    When others then
        lv_asset_applicable := 'N';
        Return(lv_asset_applicable);
  END validate_subsidy_applicability;

  -----------------------------------
  -- PROCEDURE validate_subsidy_usage
  -----------------------------------
  PROCEDURE validate_subsidy_usage(p_asset_id         IN NUMBER,
  								   p_input_adj_tbl    IN asset_adj_tbl_type,
                                   x_return_status    OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'validate_subsidy_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    ld_start_date     	DATE;
    lv_currency_code    VARCHAR2(15);
    ln_product_id     	NUMBER;
    ln_cust_acct_id     NUMBER;
    ln_sales_rep_id     NUMBER;
    ln_org_id       	NUMBER;
    ln_inv_org_id     	NUMBER;
    ln_inv_item_id      NUMBER;

    lv_parent_code				VARCHAR2(30);
    ln_total_subsidy_amount		NUMBER := 0;
    ln_subsidy_amount			NUMBER;
    ln_subsidy_id				NUMBER;
    lv_asset_number				okl_assets_b.asset_number%TYPE;
    lv_asset_sub_applicable		VARCHAR2(1);

    CURSOR c_get_quote_lop_info IS
    SELECT quote.expected_start_date,
         assetcomp.INV_ITEM_ID,
         leaseopp.inv_org_id,
         leaseopp.currency_code,
         leaseopp.ORG_ID,
         leaseopp.CUST_ACCT_ID,
         quote.product_id,
         leaseopp.SALES_REP_ID
    FROM
      okl_assets_b asset,
      okl_asset_components_b assetcomp,
      okl_lease_quotes_b quote,
      okl_lease_opportunities_b leaseopp
    WHERE
      asset.id = p_asset_id
    AND asset.id = assetcomp.asset_id
    AND assetcomp.PRIMARY_COMPONENT = 'YES'
    AND asset.parent_object_id = quote.id
    AND asset.parent_object_code = 'LEASEQUOTE'
    AND quote.parent_object_id = leaseopp.id;

    CURSOR c_get_quote_lap_info IS
    SELECT quote.expected_start_date,
         assetcomp.INV_ITEM_ID,
         leaseapp.inv_org_id,
         leaseapp.currency_code,
         leaseapp.ORG_ID,
         leaseapp.CUST_ACCT_ID,
         quote.product_id,
         leaseapp.SALES_REP_ID
    FROM
      okl_assets_b asset,
      okl_asset_components_b assetcomp,
      okl_lease_quotes_b quote,
      okl_lease_applications_b leaseapp
    WHERE
      asset.id = p_asset_id
    AND asset.id = assetcomp.asset_id
    AND assetcomp.PRIMARY_COMPONENT = 'YES'
    AND asset.parent_object_id = quote.id
    AND asset.parent_object_code = 'LEASEQUOTE'
    AND quote.parent_object_id = leaseapp.id;

	CURSOR c_get_asset_number(p_asset_id  IN NUMBER) IS
   	SELECT asset_number
   	FROM okl_assets_b
   	WHERE id = p_asset_id;

    l_input_adj_tbl  asset_adj_tbl_type;

  BEGIN
    l_input_adj_tbl := p_input_adj_tbl;

  	SELECT lsq.parent_object_code
  	INTO lv_parent_code
  	FROM okl_assets_b ast, okl_lease_quotes_b lsq
  	where ast.parent_object_id = lsq.id
	and   ast.parent_object_code = 'LEASEQUOTE'
	and   ast.id = p_asset_id;

  	IF (lv_parent_code = 'LEASEOPP') THEN
      OPEN  c_get_quote_lop_info;
      FETCH c_get_quote_lop_info into ld_start_date, ln_inv_item_id, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lop_info;
    ELSIF (lv_parent_code = 'LEASEAPP') THEN
      OPEN  c_get_quote_lap_info;
      FETCH c_get_quote_lap_info into ld_start_date, ln_inv_item_id, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lap_info;
    END IF;

    FOR i IN l_input_adj_tbl.FIRST .. l_input_adj_tbl.LAST LOOP
      IF l_input_adj_tbl.EXISTS(i) THEN

        OPEN c_get_asset_number(p_asset_id  =>  l_input_adj_tbl(i).parent_object_id);
        FETCH c_get_asset_number INTO lv_asset_number;
        CLOSE c_get_asset_number;

        IF (l_input_adj_tbl(i).value IS NOT NULL) THEN
          ln_total_subsidy_amount := ln_total_subsidy_amount + l_input_adj_tbl(i).value;
          ln_subsidy_amount := l_input_adj_tbl(i).value;
        ELSE
          ln_total_subsidy_amount := ln_total_subsidy_amount + l_input_adj_tbl(i).default_subsidy_amount;
          ln_subsidy_amount := l_input_adj_tbl(i).default_subsidy_amount;
        END IF;

        ln_subsidy_id := l_input_adj_tbl(i).adjustment_source_id;

        -- Check for Subsidy Pool Usage
        lv_asset_sub_applicable :=  okl_asset_subsidy_pvt.validate_subsidy_applicability
        		(p_subsidy_id          => ln_subsidy_id,
                 p_start_date          => ld_start_date,
                 p_inv_item_id         => ln_inv_item_id,
                 p_inv_org_id          => ln_inv_org_id,
                 p_currency_code       => lv_currency_code,
                 p_authoring_org_id    => ln_org_id,
                 p_cust_account_id     => ln_cust_acct_id,
                 p_pdt_id              => ln_product_id,
                 p_sales_rep_id        => ln_sales_rep_id,
				 p_tot_subsidy_amount  => ln_total_subsidy_amount,
				 p_subsidy_amount      => ln_subsidy_amount,
				 p_filter_flag         => 'N',
				 p_dnz_asset_number    => lv_asset_number);

        IF (lv_asset_sub_applicable = 'N') THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;
    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_subsidy_usage;

  -----------------------------------
  -- PROCEDURE validate_subsidy_usage
  -----------------------------------
  PROCEDURE validate_subsidy_usage(p_asset_id         IN NUMBER,
  						   		   p_total_subsidy_amount  IN NUMBER,
  								   p_input_adj_rec    IN okl_cdj_pvt.cdjv_rec_type,
                                   x_return_status    OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'validate_subsidy_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    ld_start_date     	DATE;
    lv_currency_code    VARCHAR2(15);
    ln_product_id     	NUMBER;
    ln_cust_acct_id     NUMBER;
    ln_sales_rep_id     NUMBER;
    ln_org_id       	NUMBER;
    ln_inv_org_id     	NUMBER;
    ln_inv_item_id      NUMBER;

    lv_parent_code				VARCHAR2(30);
    ln_total_subsidy_amount		NUMBER := 0;
    ln_subsidy_amount			NUMBER;
    ln_subsidy_id				NUMBER;
    lv_asset_number				okl_assets_b.asset_number%TYPE;
    lv_asset_sub_applicable		VARCHAR2(1);

    CURSOR c_get_quote_lop_info IS
    SELECT quote.expected_start_date,
         assetcomp.INV_ITEM_ID,
         leaseopp.inv_org_id,
         leaseopp.currency_code,
         leaseopp.ORG_ID,
         leaseopp.CUST_ACCT_ID,
         quote.product_id,
         leaseopp.SALES_REP_ID
    FROM
      okl_assets_b asset,
      okl_asset_components_b assetcomp,
      okl_lease_quotes_b quote,
      okl_lease_opportunities_b leaseopp
    WHERE
      asset.id = p_asset_id
    AND asset.id = assetcomp.asset_id
    AND assetcomp.PRIMARY_COMPONENT = 'YES'
    AND asset.parent_object_id = quote.id
    AND asset.parent_object_code = 'LEASEQUOTE'
    AND quote.parent_object_id = leaseopp.id;

    CURSOR c_get_quote_lap_info IS
    SELECT quote.expected_start_date,
         assetcomp.INV_ITEM_ID,
         leaseapp.inv_org_id,
         leaseapp.currency_code,
         leaseapp.ORG_ID,
         leaseapp.CUST_ACCT_ID,
         quote.product_id,
         leaseapp.SALES_REP_ID
    FROM
      okl_assets_b asset,
      okl_asset_components_b assetcomp,
      okl_lease_quotes_b quote,
      okl_lease_applications_b leaseapp
    WHERE
      asset.id = p_asset_id
    AND asset.id = assetcomp.asset_id
    AND assetcomp.PRIMARY_COMPONENT = 'YES'
    AND asset.parent_object_id = quote.id
    AND asset.parent_object_code = 'LEASEQUOTE'
    AND quote.parent_object_id = leaseapp.id;

	CURSOR c_get_asset_number(p_asset_id  IN NUMBER) IS
   	SELECT asset_number
   	FROM okl_assets_b
   	WHERE id = p_asset_id;

    l_input_adj_rec  okl_cdj_pvt.cdjv_rec_type;

  BEGIN
    l_input_adj_rec := p_input_adj_rec;

  	SELECT lsq.parent_object_code
  	INTO lv_parent_code
  	FROM okl_assets_b ast, okl_lease_quotes_b lsq
  	where ast.parent_object_id = lsq.id
	and   ast.parent_object_code = 'LEASEQUOTE'
	and   ast.id = p_asset_id;

  	IF (lv_parent_code = 'LEASEOPP') THEN
      OPEN  c_get_quote_lop_info;
      FETCH c_get_quote_lop_info into ld_start_date, ln_inv_item_id, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lop_info;
    ELSIF (lv_parent_code = 'LEASEAPP') THEN
      OPEN  c_get_quote_lap_info;
      FETCH c_get_quote_lap_info into ld_start_date, ln_inv_item_id, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lap_info;
    END IF;

    IF (l_input_adj_rec.parent_object_id IS NOT NULL) THEN

      OPEN c_get_asset_number(p_asset_id  =>  l_input_adj_rec.parent_object_id);
      FETCH c_get_asset_number INTO lv_asset_number;
      CLOSE c_get_asset_number;

      IF (l_input_adj_rec.value IS NOT NULL) THEN
        ln_total_subsidy_amount := ln_total_subsidy_amount + l_input_adj_rec.value;
        ln_subsidy_amount := l_input_adj_rec.value;
      ELSE
        ln_total_subsidy_amount := ln_total_subsidy_amount + l_input_adj_rec.default_subsidy_amount;
        ln_subsidy_amount := l_input_adj_rec.default_subsidy_amount;
      END IF;

      ln_subsidy_id := l_input_adj_rec.adjustment_source_id;

      -- Check for Subsidy Pool Usage
      lv_asset_sub_applicable :=  okl_asset_subsidy_pvt.validate_subsidy_applicability
        		(p_subsidy_id          => ln_subsidy_id,
                 p_start_date          => ld_start_date,
                 p_inv_item_id         => ln_inv_item_id,
                 p_inv_org_id          => ln_inv_org_id,
                 p_currency_code       => lv_currency_code,
                 p_authoring_org_id    => ln_org_id,
                 p_cust_account_id     => ln_cust_acct_id,
                 p_pdt_id              => ln_product_id,
                 p_sales_rep_id        => ln_sales_rep_id,
				 p_tot_subsidy_amount  => p_total_subsidy_amount,
				 p_subsidy_amount      => ln_subsidy_amount,
				 p_filter_flag         => 'N',
				 p_dnz_asset_number    => lv_asset_number);

      IF (lv_asset_sub_applicable = 'N') THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_subsidy_usage;

  -----------------------------------
  -- PROCEDURE sync_asset_comp_values
  -----------------------------------
  PROCEDURE sync_asset_comp_values(x_asset_comp_tbl     IN OUT NOCOPY component_tbl_type,
                                   p_input_comp_tbl     IN asset_component_tbl_type,
                                   x_return_status    OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'sync_asset_comp_values';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_input_comp_tbl  asset_component_tbl_type;
    l_output_comp_tbl   component_tbl_type;

  BEGIN

    l_input_comp_tbl := p_input_comp_tbl;
    l_output_comp_tbl := x_asset_comp_tbl;

    FOR i IN l_input_comp_tbl.FIRST .. l_input_comp_tbl.LAST LOOP
      IF l_input_comp_tbl.EXISTS(i) THEN
        FOR j IN l_output_comp_tbl.FIRST .. l_output_comp_tbl.LAST LOOP
          IF l_output_comp_tbl.EXISTS(j) THEN
            IF (l_output_comp_tbl(j).id = l_input_comp_tbl(i).id) THEN

          IF (l_input_comp_tbl(i).unit_cost IS NOT NULL) THEN
              l_output_comp_tbl(j).unit_cost := l_input_comp_tbl(i).unit_cost;
        END IF;

          IF (l_input_comp_tbl(i).number_of_units IS NOT NULL) THEN
              l_output_comp_tbl(j).number_of_units := l_input_comp_tbl(i).number_of_units;
        END IF;

            END IF;
          END IF;
    END LOOP;
      END IF;
    END LOOP;

    x_asset_comp_tbl := l_output_comp_tbl;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END sync_asset_comp_values;

  ------------------------------
  -- PROCEDURE sync_asset_values
  ------------------------------
  PROCEDURE sync_asset_values(x_asset_rec      IN OUT NOCOPY asset_rec_type,
                              p_input_rec      IN asset_rec_type,
                              x_return_status  OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'sync_asset_values';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    IF (p_input_rec.id IS NOT NULL) THEN
      x_asset_rec.id := p_input_rec.id;
    END IF;

    IF (p_input_rec.object_version_number IS NOT NULL) THEN
      x_asset_rec.object_version_number := p_input_rec.object_version_number;
    END IF;

    IF (p_input_rec.parent_object_id IS NOT NULL) THEN
      x_asset_rec.parent_object_id := p_input_rec.parent_object_id;
    END IF;

    IF (p_input_rec.parent_object_code IS NOT NULL) THEN
      x_asset_rec.parent_object_code := p_input_rec.parent_object_code;
    END IF;

    IF (p_input_rec.rate_card_id IS NOT NULL) THEN
      x_asset_rec.rate_card_id := p_input_rec.rate_card_id;
    END IF;

    IF (p_input_rec.rate_template_id IS NOT NULL) THEN
      x_asset_rec.rate_template_id := p_input_rec.rate_template_id;
    END IF;

    IF (p_input_rec.structured_pricing IS NOT NULL) THEN
      x_asset_rec.structured_pricing := p_input_rec.structured_pricing;
    END IF;

    IF (p_input_rec.target_arrears IS NOT NULL) THEN
      x_asset_rec.target_arrears := p_input_rec.target_arrears;
    END IF;

    IF (p_input_rec.oec IS NOT NULL) THEN
      x_asset_rec.oec := p_input_rec.oec;
    END IF;

    IF (p_input_rec.oec_percentage IS NOT NULL) THEN
      x_asset_rec.oec_percentage := p_input_rec.oec_percentage;
    END IF;

    IF (p_input_rec.lease_rate_factor IS NOT NULL) THEN
      x_asset_rec.lease_rate_factor := p_input_rec.lease_rate_factor;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END  sync_asset_values;

  ----------------------------------
  -- PROCEDURE get_eot_default_value
  ----------------------------------
  FUNCTION get_eot_default_value(p_asset_rec      IN  asset_rec_type,
                   				 p_asset_comp_tbl IN  asset_component_tbl_type,
                   				 x_return_status  OUT NOCOPY VARCHAR2)
    RETURN NUMBER IS

  ln_eot_default_value  NUMBER  := null;
  halt_validation     	EXCEPTION;
  l_asset_comp_tbl    asset_component_tbl_type;
  lv_eot_type_code    	VARCHAR2(30);
  ln_cost         		NUMBER;
  ln_number_of_units	NUMBER;
  l_asset_rec			asset_rec_type;

  CURSOR c_get_eot_category_code(p_quote_id  IN NUMBER)
  IS
  SELECT
     EOT.EOT_TYPE_CODE
  FROM OKL_FE_EO_TERMS_ALL_B EOT,
       OKL_FE_EO_TERM_VERS EOT_VER,
       OKL_LEASE_QUOTES_B QTE
  WHERE
      EOT_VER.END_OF_TERM_VER_ID = QTE.END_OF_TERM_OPTION_ID
  AND EOT_VER.END_OF_TERM_ID = EOT.END_OF_TERM_ID
  AND QTE.ID = p_quote_id;

  BEGIN
    OPEN c_get_eot_category_code(p_quote_id  => p_asset_rec.parent_object_id);
    FETCH c_get_eot_category_code INTO lv_eot_type_code;
    CLOSE c_get_eot_category_code;

    l_asset_comp_tbl := p_asset_comp_tbl;
    l_asset_rec		 := p_asset_rec;

    -- Get the Inv Item Id of asset
    FOR i IN l_asset_comp_tbl.FIRST .. l_asset_comp_tbl.LAST LOOP
      IF l_asset_comp_tbl.EXISTS(i) THEN
        IF (l_asset_comp_tbl(i).primary_component = 'YES') THEN
          ln_cost := l_asset_comp_tbl(i).unit_cost * l_asset_comp_tbl(i).number_of_units;
          ln_number_of_units	:= l_asset_comp_tbl(i).number_of_units;
        END IF;
      END IF;
    END LOOP;

    -- Calculate the EOT value
    IF (lv_eot_type_code IN ('PERCENT', 'RESIDUAL_PERCENT')) THEN
      ln_eot_default_value := l_asset_rec.end_of_term_value_default;
    ELSIF (lv_eot_type_code IN ('AMOUNT', 'RESIDUAL_AMOUNT')) THEN
      IF (l_asset_rec.end_of_term_value_default IS NOT NULL) THEN
        ln_eot_default_value := l_asset_rec.end_of_term_value_default * ln_number_of_units;
      END IF;
    END IF;

  RETURN ln_eot_default_value;

  EXCEPTION
    When halt_validation then
        Return(ln_eot_default_value);
    When others then
        ln_eot_default_value := null;
        Return(ln_eot_default_value);
  END get_eot_default_value;

  -----------------------------
  -- PROCEDURE validate_subsidy
  -----------------------------
  FUNCTION validate_subsidy(p_quote_id  IN  NUMBER,
                            p_subsidy_id  IN NUMBER)
    RETURN VARCHAR2 IS

	ld_start_date			DATE;
	lv_currency_code		VARCHAR2(15);
	ln_product_id			NUMBER;
	ln_cust_acct_id			NUMBER;
	ln_sales_rep_id			NUMBER;
	ln_org_id				NUMBER;
	ln_inv_org_id			NUMBER;
	ln_inv_item_id			NUMBER;

	lv_asset_applicable		VARCHAR2(1);
	lb_asset_applicable		BOOLEAN := FALSE;
	lv_parent_code			VARCHAR2(30);
	halt_validation 		EXCEPTION;

	CURSOR c_get_quote_lop_info IS
	SELECT quote.expected_start_date,
	       leaseopp.inv_org_id,
	       leaseopp.currency_code,
	       leaseopp.ORG_ID,
	       leaseopp.CUST_ACCT_ID,
	       quote.product_id,
	       leaseopp.SALES_REP_ID
	FROM
		okl_lease_quotes_b quote,
		okl_lease_opportunities_b leaseopp
	WHERE
		quote.id = p_quote_id
	AND quote.parent_object_id = leaseopp.id
	AND quote.parent_object_code = 'LEASEOPP';

	CURSOR c_get_quote_lap_info IS
	SELECT quote.expected_start_date,
	       leaseapp.inv_org_id,
	       leaseapp.currency_code,
	       leaseapp.ORG_ID,
	       leaseapp.CUST_ACCT_ID,
	       quote.product_id,
	       leaseapp.SALES_REP_ID
	FROM
		okl_lease_quotes_b quote,
		okl_lease_applications_b leaseapp
	WHERE
		quote.id = p_quote_id
	AND quote.parent_object_id = leaseapp.id
	AND quote.parent_object_code = 'LEASEAPP';

	CURSOR c_get_inv_items IS
	SELECT assetcomp.INV_ITEM_ID
	FROM okl_assets_b asset,
		 okl_asset_components_b assetcomp
	WHERE
		 asset.id = assetcomp.asset_id
	 AND assetcomp.PRIMARY_COMPONENT = 'YES'
	 AND asset.parent_object_id = p_quote_id
	 AND asset.parent_object_code = 'LEASEQUOTE';

  BEGIN
  	SELECT parent_object_code
  	INTO lv_parent_code
  	FROM okl_lease_quotes_b
  	where id = p_quote_id;

  	IF (lv_parent_code = 'LEASEOPP') THEN
      OPEN  c_get_quote_lop_info;
      FETCH c_get_quote_lop_info into ld_start_date, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lop_info;
    ELSIF (lv_parent_code = 'LEASEAPP') THEN
      OPEN  c_get_quote_lap_info;
      FETCH c_get_quote_lap_info into ld_start_date, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lap_info;
    END IF;

    FOR l_get_inv_items IN c_get_inv_items LOOP

	  lv_asset_applicable := okl_asset_subsidy_pvt.validate_subsidy_applicability
				(p_subsidy_id          =>	p_subsidy_id,
                 p_start_date          =>	ld_start_date,
                 p_inv_item_id         =>	l_get_inv_items.inv_item_id,
                 p_inv_org_id          =>	ln_inv_org_id,
                 p_currency_code       =>	lv_currency_code,
                 p_authoring_org_id    =>	ln_org_id,
                 p_cust_account_id     =>	ln_cust_acct_id,
                 p_pdt_id              =>	ln_product_id,
                 p_sales_rep_id        =>	ln_sales_rep_id);


	  IF (lv_asset_applicable = 'Y') THEN
	    lb_asset_applicable := TRUE;
	  END IF;

	  EXIT WHEN (lb_asset_applicable = TRUE);
	END LOOP;

    RETURN 	lv_asset_applicable;
  EXCEPTION
    When halt_validation then
        Return(lv_asset_applicable);
    When others then
        lv_asset_applicable := 'N';
        Return(lv_asset_applicable);
  END validate_subsidy;

  -------------------------------------------
  -- PROCEDURE validate_subsidy_applicability
  -------------------------------------------
  FUNCTION validate_subsidy_applicability(p_asset_id  IN  NUMBER,
                                          p_subsidy_id  IN NUMBER)
    RETURN VARCHAR2 IS

  ld_start_date     DATE;
  lv_currency_code    VARCHAR2(15);
  ln_product_id     NUMBER;
  ln_cust_acct_id     NUMBER;
  ln_sales_rep_id     NUMBER;
  ln_org_id       NUMBER;
  ln_inv_org_id     NUMBER;
  ln_inv_item_id      NUMBER;

  lv_asset_applicable   VARCHAR2(1);
  lv_parent_code		VARCHAR2(30);
  halt_validation     EXCEPTION;

  CURSOR c_get_quote_lop_info IS
  SELECT quote.expected_start_date,
         assetcomp.INV_ITEM_ID,
         leaseopp.inv_org_id,
         leaseopp.currency_code,
         leaseopp.ORG_ID,
         leaseopp.CUST_ACCT_ID,
         quote.product_id,
         leaseopp.SALES_REP_ID
  FROM
    okl_assets_b asset,
    okl_asset_components_b assetcomp,
    okl_lease_quotes_b quote,
    okl_lease_opportunities_b leaseopp
  WHERE
    asset.id = p_asset_id
  AND asset.id = assetcomp.asset_id
  AND assetcomp.PRIMARY_COMPONENT = 'YES'
  AND asset.parent_object_id = quote.id
  AND asset.parent_object_code = 'LEASEQUOTE'
  AND quote.parent_object_id = leaseopp.id;

  CURSOR c_get_quote_lap_info IS
  SELECT quote.expected_start_date,
         assetcomp.INV_ITEM_ID,
         leaseapp.inv_org_id,
         leaseapp.currency_code,
         leaseapp.ORG_ID,
         leaseapp.CUST_ACCT_ID,
         quote.product_id,
         leaseapp.SALES_REP_ID
  FROM
    okl_assets_b asset,
    okl_asset_components_b assetcomp,
    okl_lease_quotes_b quote,
    okl_lease_applications_b leaseapp
  WHERE
    asset.id = p_asset_id
  AND asset.id = assetcomp.asset_id
  AND assetcomp.PRIMARY_COMPONENT = 'YES'
  AND asset.parent_object_id = quote.id
  AND asset.parent_object_code = 'LEASEQUOTE'
  AND quote.parent_object_id = leaseapp.id;

  BEGIN
  	SELECT lsq.parent_object_code
  	INTO lv_parent_code
  	FROM okl_assets_b ast, okl_lease_quotes_b lsq
  	where ast.parent_object_id = lsq.id
	and   ast.parent_object_code = 'LEASEQUOTE'
	and   ast.id = p_asset_id;

  	IF (lv_parent_code = 'LEASEOPP') THEN
      OPEN  c_get_quote_lop_info;
      FETCH c_get_quote_lop_info into ld_start_date, ln_inv_item_id, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lop_info;
    ELSIF (lv_parent_code = 'LEASEAPP') THEN
      OPEN  c_get_quote_lap_info;
      FETCH c_get_quote_lap_info into ld_start_date, ln_inv_item_id, ln_inv_org_id,
								  lv_currency_code, ln_org_id, ln_cust_acct_id,
								  ln_product_id, ln_sales_rep_id;
      CLOSE c_get_quote_lap_info;
    END IF;

  lv_asset_applicable := okl_asset_subsidy_pvt.validate_subsidy_applicability
        (p_subsidy_id          => p_subsidy_id,
                 p_start_date          => ld_start_date,
                 p_inv_item_id         => ln_inv_item_id,
                 p_inv_org_id          => ln_inv_org_id,
                 p_currency_code       => lv_currency_code,
                 p_authoring_org_id    => ln_org_id,
                 p_cust_account_id     => ln_cust_acct_id,
                 p_pdt_id              => ln_product_id,
                 p_sales_rep_id        => ln_sales_rep_id);

    RETURN  lv_asset_applicable;
  EXCEPTION
    When halt_validation then
        Return(lv_asset_applicable);
    When others then
        lv_asset_applicable := 'N';
        Return(lv_asset_applicable);
  END validate_subsidy_applicability;


  -------------------------------
  -- PROCEDURE get_adjust_tbl
  -------------------------------
  PROCEDURE get_adjust_tbl (p_source_quote_id           IN  NUMBER
               ,x_adjust_tbl                OUT NOCOPY cdj_tbl_type
               ,x_return_status             OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_adjust_tbl';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    i                      BINARY_INTEGER := 0;

    CURSOR c_db_adjust IS
      SELECT
         attribute_category
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
        ,adjustment_source_type
        ,adjustment_source_id
        ,basis
        ,value
        ,processing_type
        ,supplier_id
        ,default_subsidy_amount
        --Bug # 5142940 ssdeshpa start
        ,stream_type_id
        --Bug # 5142940 ssdeshpa start
        ,short_description
        ,description
        ,comments
      from okl_cost_adjustments_v
      where parent_object_code = 'ASSET'
      and adjustment_source_type in ('DOWN_PAYMENT', 'TRADEIN', 'SUBSIDY')
      and parent_object_id IN (select id
                     from okl_assets_b
                     where parent_object_id = p_source_quote_id
                     and parent_object_code = 'LEASEQUOTE');

  BEGIN
    FOR l_db_adjust IN c_db_adjust LOOP
      x_adjust_tbl(i).attribute_category := l_db_adjust.attribute_category;
      x_adjust_tbl(i).attribute1 := l_db_adjust.attribute1;
      x_adjust_tbl(i).attribute2 := l_db_adjust.attribute2;
      x_adjust_tbl(i).attribute3 := l_db_adjust.attribute3;
      x_adjust_tbl(i).attribute4 := l_db_adjust.attribute4;
      x_adjust_tbl(i).attribute5 := l_db_adjust.attribute5;
      x_adjust_tbl(i).attribute6 := l_db_adjust.attribute6;
      x_adjust_tbl(i).attribute7 := l_db_adjust.attribute7;
      x_adjust_tbl(i).attribute8 := l_db_adjust.attribute8;
      x_adjust_tbl(i).attribute9 := l_db_adjust.attribute9;
      x_adjust_tbl(i).attribute10 := l_db_adjust.attribute10;
      x_adjust_tbl(i).attribute11 := l_db_adjust.attribute11;
      x_adjust_tbl(i).attribute12 := l_db_adjust.attribute12;
      x_adjust_tbl(i).attribute13 := l_db_adjust.attribute13;
      x_adjust_tbl(i).attribute14 := l_db_adjust.attribute14;
      x_adjust_tbl(i).attribute15 := l_db_adjust.attribute15;
      x_adjust_tbl(i).parent_object_code := l_db_adjust.parent_object_code;
      x_adjust_tbl(i).parent_object_id := l_db_adjust.parent_object_id;
      x_adjust_tbl(i).adjustment_source_type := l_db_adjust.adjustment_source_type;
      x_adjust_tbl(i).adjustment_source_id := l_db_adjust.adjustment_source_id;
      x_adjust_tbl(i).basis := l_db_adjust.basis;
      x_adjust_tbl(i).value := l_db_adjust.value;
      x_adjust_tbl(i).processing_type := l_db_adjust.processing_type;
      x_adjust_tbl(i).supplier_id := l_db_adjust.supplier_id;
      x_adjust_tbl(i).default_subsidy_amount := l_db_adjust.default_subsidy_amount;
      --Bug # 5142940 ssdeshpa start
      x_adjust_tbl(i).stream_type_id := l_db_adjust.stream_type_id;
      --Bug # 5142940 ssdeshpa start
      x_adjust_tbl(i).short_description := l_db_adjust.short_description;
      x_adjust_tbl(i).description := l_db_adjust.description;
      x_adjust_tbl(i).comments := l_db_adjust.comments;
      i := i + 1;
    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_adjust_tbl;

  -------------------------------
  -- PROCEDURE get_deleted_addons
  -------------------------------
  PROCEDURE get_deleted_addons (p_asset_id            IN  NUMBER,
                                p_component_tbl       IN  asset_component_tbl_type,
                                x_deleted_addon_tbl   OUT NOCOPY component_tbl_type,
                                x_return_status       OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_deleted_addons';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_db_addons IS
      SELECT id
      FROM   okl_asset_components_b
      WHERE  asset_id = p_asset_id
      AND    primary_component = 'NO';

    l_addon_tbl            component_tbl_type;
    l_delete_flag          VARCHAR2(1);
    i                      BINARY_INTEGER := 0;

  BEGIN

    FOR l_db_addon IN c_db_addons LOOP

      l_delete_flag := 'Y';

      FOR j IN p_component_tbl.FIRST .. p_component_tbl.LAST LOOP
        IF p_component_tbl.EXISTS(j) THEN
          IF l_db_addon.id = p_component_tbl(j).id THEN
            l_delete_flag := 'N';
          END IF;
        END IF;
      END LOOP;

      IF l_delete_flag = 'Y' THEN
        l_addon_tbl(i).id := l_db_addon.id;
        i := i + 1;
      END IF;

    END LOOP;

    x_deleted_addon_tbl := l_addon_tbl;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_deleted_addons;

  --------------------------------------
  -- PROCEDURE is_asset_adj_defined
  --------------------------------------
  FUNCTION is_asset_adj_defined(p_assoc_assets_tbl  IN asset_adjustment_tbl_type,
  								x_asset_id			OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS

  l_program_name         CONSTANT VARCHAR2(30) := 'is_asset_adj_defined';
  l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  CURSOR c_check_asset_adj (p_asset_id IN NUMBER, p_adj_type IN VARCHAR2) IS
  SELECT 'Y'
  FROM OKL_COST_ADJUSTMENTS_B
  WHERE PARENT_OBJECT_ID = p_asset_id
  AND PARENT_OBJECT_CODE = 'ASSET'
  AND ADJUSTMENT_SOURCE_TYPE = p_adj_type;

  c_check_flag	VARCHAR2(1)	:= 'N';

  BEGIN

    IF p_assoc_assets_tbl.COUNT > 0 THEN
      FOR i IN p_assoc_assets_tbl.FIRST .. p_assoc_assets_tbl.LAST LOOP
        IF p_assoc_assets_tbl.EXISTS(i) THEN
          OPEN c_check_asset_adj(p_asset_id  => p_assoc_assets_tbl(i).parent_object_id,
		  						 p_adj_type  => p_assoc_assets_tbl(i).adjustment_source_type);
		  FETCH c_check_asset_adj INTO c_check_flag;
		  CLOSE c_check_asset_adj;

		  IF (c_check_flag = 'Y') THEN
		    x_asset_id := p_assoc_assets_tbl(i).parent_object_id;
		    RETURN c_check_flag;
          END IF;

        END IF;
      END LOOP;
    END IF;

    RETURN c_check_flag;

  END is_asset_adj_defined;

  -----------------------------------
  -- PROCEDURE validate_adjust_assets
  -----------------------------------
  PROCEDURE validate_adjust_assets (p_adj_amount       IN NUMBER,
                                    p_assoc_assets_tbl IN asset_adjustment_tbl_type,
                                    x_return_status    OUT NOCOPY VARCHAR2) IS

  l_program_name         CONSTANT VARCHAR2(30) := 'validate_adjust_assets';
  l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  l_link_exists_yn    VARCHAR2(1);
  l_assoc_total       NUMBER := 0;
  l_null_found        VARCHAR2(1) := 'N';
  l_amt_flag          VARCHAR2(1) := 'N';
  BEGIN

    IF p_assoc_assets_tbl.COUNT > 0 THEN
      FOR i IN p_assoc_assets_tbl.FIRST .. p_assoc_assets_tbl.LAST LOOP
        IF p_assoc_assets_tbl.EXISTS(i) THEN

          IF p_assoc_assets_tbl(i).value IS NOT NULL THEN
            l_amt_flag       := 'Y';
            l_assoc_total    := l_assoc_total + p_assoc_assets_tbl(i).value;
          ELSE
            l_null_found := 'Y';
          END IF;

          IF (p_assoc_assets_tbl(i).value IS NULL) AND l_amt_flag = 'Y' THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_LINKASSET_NULL_FOUND');

            RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF (l_null_found = 'Y' AND l_amt_flag = 'Y') THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_LINKASSET_NULL_FOUND');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END LOOP;
      IF p_assoc_assets_tbl.exists(p_assoc_assets_tbl.FIRST) THEN
        IF p_assoc_assets_tbl(p_assoc_assets_tbl.FIRST).basis = 'FIXED' THEN
          IF l_amt_flag = 'Y' AND l_assoc_total <> p_adj_amount THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_SALES_ADJ_AMT_MISMATCH',
                                 p_token1       => 'LINE_COST',
                                 p_token1_value => p_adj_amount,
                                 p_token2       => 'ASSOC_TOTAL',
                                 p_token2_value => l_assoc_total);

            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_adjust_assets;

  ----------------------------------------
  -- PROCEDURE get_deleted_adjusted_assets
  ----------------------------------------
  PROCEDURE get_deleted_adjusted_assets (p_adj_type            IN  VARCHAR2,
                                         p_quote_id            IN  NUMBER,
                                         p_adjustment_tbl      IN  asset_adjustment_tbl_type,
                                         x_deleted_adjust_tbl  OUT NOCOPY asset_adj_tbl_type,
                                         x_return_status       OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_deleted_adjusted_assets';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_db_adj_assets IS
      SELECT costadj.id, costadj.parent_object_id
      FROM   okl_cost_adjustments_b costadj,
             okl_assets_b asset
      WHERE  costadj.adjustment_source_type = p_adj_type
      AND  costadj.parent_object_id = asset.id
      AND  costadj.parent_object_code = 'ASSET'
      AND  asset.parent_object_id = p_quote_id
      AND  asset.parent_object_code = 'LEASEQUOTE';

    CURSOR c_db_subs_assets(p_adj_source_id IN  NUMBER) IS
      SELECT costadj.id, costadj.parent_object_id
      FROM   okl_cost_adjustments_b costadj,
             okl_assets_b asset
      WHERE  costadj.adjustment_source_type = p_adj_type
      AND  costadj.adjustment_source_id = p_adj_source_id
      AND  costadj.parent_object_id = asset.id
      AND  costadj.parent_object_code = 'ASSET'
      AND  asset.parent_object_id = p_quote_id
      AND  asset.parent_object_code = 'LEASEQUOTE';

    l_asset_adj_tbl        asset_adj_tbl_type;
    l_delete_flag          VARCHAR2(1);
    i                      BINARY_INTEGER := 0;
    ln_index			   NUMBER;

  BEGIN

    IF (p_adj_type IN ('DOWN_PAYMENT', 'TRADEIN')) THEN

      FOR l_db_adj_assets IN c_db_adj_assets LOOP

        l_delete_flag := 'Y';

        FOR j IN p_adjustment_tbl.FIRST .. p_adjustment_tbl.LAST LOOP
          IF p_adjustment_tbl.EXISTS(j) THEN
            IF l_db_adj_assets.id = p_adjustment_tbl(j).id THEN
              l_delete_flag := 'N';
            END IF;
          END IF;
        END LOOP;

        IF l_delete_flag = 'Y' THEN
          l_asset_adj_tbl(i).id := l_db_adj_assets.id;
          i := i + 1;
        END IF;

      END LOOP;
    ELSIF (p_adj_type = 'SUBSIDY') THEN

	  ln_index := p_adjustment_tbl.FIRST;

      IF (p_adjustment_tbl.COUNT > 0) THEN
        FOR l_db_subs_assets IN c_db_subs_assets(p_adj_source_id => p_adjustment_tbl(ln_index).adjustment_source_id) LOOP

          l_delete_flag := 'Y';

          FOR j IN p_adjustment_tbl.FIRST .. p_adjustment_tbl.LAST LOOP
            IF p_adjustment_tbl.EXISTS(j) THEN
              IF l_db_subs_assets.id = p_adjustment_tbl(j).id THEN
                l_delete_flag := 'N';
              END IF;
            END IF;
          END LOOP;

          IF l_delete_flag = 'Y' THEN
            l_asset_adj_tbl(i).id := l_db_subs_assets.id;
            i := i + 1;
          END IF;
        END LOOP;
      END IF;
    END IF;

    x_deleted_adjust_tbl := l_asset_adj_tbl;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_deleted_adjusted_assets;

  -------------------------
  -- PROCEDURE set_defaults
  -------------------------
  PROCEDURE set_defaults (p_asset_rec       IN  OUT NOCOPY asset_rec_type,
                          p_component_tbl   IN  OUT NOCOPY asset_component_tbl_type,
                          x_return_status   OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'set_defaults';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_units                PLS_INTEGER;
    l_currency_code        VARCHAR2(15);
    l_oec                  NUMBER;
    lv_parent_object_code   VARCHAR2(30);

    CURSOR c_get_parent_object_code(parent_object_id   NUMBER) IS
      SELECT parent_object_code
      FROM   okl_lease_quotes_b
      WHERE  id = p_asset_rec.parent_object_id;

  BEGIN

    FOR i IN p_component_tbl.FIRST .. p_component_tbl.LAST LOOP
      IF p_component_tbl.EXISTS(i) THEN
        IF p_component_tbl(i).primary_component = 'YES' THEN
          l_units := p_component_tbl(i).number_of_units;
        END IF;
      END IF;
    END LOOP;

    l_oec := 0;
    FOR i IN p_component_tbl.FIRST .. p_component_tbl.LAST LOOP
      IF p_component_tbl.EXISTS(i) THEN
          l_oec := l_oec + p_component_tbl(i).unit_cost * l_units;
      END IF;
    END LOOP;

    IF l_oec = 0 THEN
      p_asset_rec.oec := 0;
    ELSE
      OPEN c_get_parent_object_code(parent_object_id    => p_asset_rec.parent_object_id);
      FETCH c_get_parent_object_code INTO lv_parent_object_code;
      CLOSE c_get_parent_object_code;

      IF (lv_parent_object_code = 'LEASEOPP') THEN
        SELECT currency_code
        INTO   l_currency_code
        FROM   okl_lease_opportunities_b lop,
               okl_lease_quotes_b lsq
        WHERE  lsq.parent_object_code = lv_parent_object_code
        AND    lsq.parent_object_id = lop.id
        AND    lsq.id = p_asset_rec.parent_object_id;
      ELSIF (lv_parent_object_code = 'LEASEAPP') THEN
        SELECT currency_code
        INTO   l_currency_code
        FROM   okl_lease_applications_b lap,
               okl_lease_quotes_b lsq
        WHERE  lsq.parent_object_code = lv_parent_object_code
        AND    lsq.parent_object_id = lap.id
        AND    lsq.id = p_asset_rec.parent_object_id;
      END IF;

      p_asset_rec.oec := okl_accounting_util.validate_amount(p_amount => l_oec, p_currency_code => l_currency_code);
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END set_defaults;

  -------------------------------------
  -- PROCEDURE duplicate_adjustments
  -------------------------------------
  PROCEDURE duplicate_adjustments(p_api_version             IN  NUMBER,
                                  p_init_msg_list           IN  VARCHAR2,
                  				  p_source_quote_id         IN  NUMBER,
                  				  p_target_quote_id		    IN  NUMBER,
                  				  x_msg_count               OUT NOCOPY NUMBER,
                                  x_msg_data                OUT NOCOPY VARCHAR2,
                                  x_return_status           OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'duplicate_adjustments';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_adjust_tbl    cdj_tbl_type;
    lx_adjust_tbl   cdj_tbl_type;

    CURSOR c_get_new_asset_id (p_source_asset_id IN NUMBER) IS
    SELECT id
    FROM OKL_ASSETS_B
    WHERE ORIG_ASSET_ID = p_source_asset_id
    AND PARENT_OBJECT_ID = p_target_quote_id;

  BEGIN

    get_adjust_tbl (p_source_quote_id    => p_source_quote_id
             		,x_adjust_tbl         => l_adjust_tbl
           			,x_return_status      => x_return_status);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_adjust_tbl.COUNT > 0) THEN
      FOR i IN l_adjust_tbl.FIRST .. l_adjust_tbl.LAST LOOP
        IF l_adjust_tbl.EXISTS(i) THEN
          OPEN c_get_new_asset_id(p_source_asset_id  => l_adjust_tbl(i).parent_object_id);
          FETCH c_get_new_asset_id INTO l_adjust_tbl(i).parent_object_id;
          CLOSE c_get_new_asset_id;
        END IF;
      END LOOP;

      -- Validate Subsidy Usage
      IF (l_adjust_tbl(0).adjustment_source_type = 'SUBSIDY') THEN
        validate_subsidy_usage(p_asset_id         =>  l_adjust_tbl(0).parent_object_id,
 				       		   p_input_adj_tbl    =>  l_adjust_tbl,
                               x_return_status    =>  x_return_status);
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      okl_cdj_pvt.insert_row (p_api_version   => G_API_VERSION
                             ,p_init_msg_list => G_FALSE
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_cdjv_tbl      => l_adjust_tbl
                             ,x_cdjv_tbl      => lx_adjust_tbl );
      --Bug # 5142940 ssdeshpa start
       l_adjust_tbl := lx_adjust_tbl;
       IF (l_adjust_tbl.COUNT > 0) THEN
         FOR i IN l_adjust_tbl.FIRST .. l_adjust_tbl.LAST LOOP
           IF l_adjust_tbl.EXISTS(i) THEN
              IF(l_adjust_tbl(i).adjustment_source_type='DOWN_PAYMENT' AND
                  l_adjust_tbl(i).processing_type='BILL' AND
                  l_adjust_tbl(i).stream_type_id IS NOT NULL) THEN
                  --Create Rec Structure for Cash flows
                  process_adj_cashflows(p_cdjv_rec  => l_adjust_tbl(i)
                                       ,p_event_mode    => 'create'
                                       ,x_msg_count     => x_msg_count
                                       ,x_msg_data      => x_msg_data
                                       ,x_return_status => x_return_status);

                  IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF x_return_status = G_RET_STS_ERROR THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
               END IF;
            END IF;
         END LOOP;
        END IF;

    --Bug # 5142940 ssdeshpa end
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END duplicate_adjustments;

  ---------------------
  -- PROCEDURE validate
  ---------------------
  PROCEDURE validate (p_asset_rec       IN  OUT NOCOPY asset_rec_type,
                      p_component_tbl   IN  OUT NOCOPY asset_component_tbl_type,
                      x_return_status   OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'validate';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  lv_pricing_method        OKL_LEASE_QUOTES_B.PRICING_METHOD%TYPE;
  ln_check_pec_percentage    NUMBER;
  ln_sum_oec_percentage    NUMBER;

  BEGIN
    FOR i IN p_component_tbl.FIRST .. p_component_tbl.LAST LOOP
      IF p_component_tbl.EXISTS(i) THEN
        IF p_component_tbl(i).primary_component = 'YES' THEN
          IF (TRUNC(p_component_tbl(i).number_of_units) <> p_component_tbl(i).number_of_units) OR
             (p_component_tbl(i).number_of_units <= 0) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNITS_VALUE);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- Validate Asset percentage in case of 'Solve for Financed Amount'
          -- pricng method scenario
          SELECT PRICING_METHOD
          INTO lv_pricing_method
          FROM OKL_LEASE_QUOTES_B
          WHERE ID = p_asset_rec.parent_object_id;

          IF (lv_pricing_method = 'SF') THEN

            -- Check if the Asset OEC percentage is less than '0' and greater
            -- than '100'
            IF (p_asset_rec.oec_percentage <= 0 OR
          p_asset_rec.oec_percentage > 100) THEN
              OKL_API.set_message(p_app_name => G_APP_NAME,
                                  p_msg_name => 'OKL_CHECK_ASSET_PERCENTAGE');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            -- Check if the sum of all Asset OEC percentages greater than '100'
            SELECT SUM(OEC_PERCENTAGE)
            INTO ln_sum_oec_percentage
            FROM OKL_ASSETS_B
            WHERE PARENT_OBJECT_ID = p_asset_rec.parent_object_id
            AND ID NOT IN (SELECT ID FROM OKL_ASSETS_B WHERE ID = p_asset_rec.id);

            IF (ln_sum_oec_percentage IS NULL) THEN
              ln_sum_oec_percentage := 0;
            END IF;

            ln_check_pec_percentage :=
        ln_sum_oec_percentage + p_asset_rec.oec_percentage;

            IF (ln_check_pec_percentage > 100) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME
                      ,p_msg_name     => 'OKL_CHECK_TOTAL_ASSET_PERCENT'
                    ,p_token1       => 'TOTAL'
                    ,p_token1_value => ln_check_pec_percentage );
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
          -- End

        END IF;
      END IF;
    END LOOP;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate;


  ------------------------------
  -- PROCEDURE create_adjustment
  ------------------------------
  PROCEDURE create_adjustment (p_api_version             IN  NUMBER,
                               p_init_msg_list           IN  VARCHAR2,
                               p_transaction_control     IN  VARCHAR2,
                               p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_adjustment';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_asset_adj_tbl        asset_adjustment_tbl_type;
    l_adj_assets_tbl       asset_adj_tbl_type;
    lx_adj_assets_tbl      asset_adj_tbl_type;
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);
    lb_validate_subsidy_usage BOOLEAN;

    asset_adj_defined	   VARCHAR2(1) := 'N';
    x_asset_id			   okl_cost_adjustments_b.adjustment_source_id%type;
    lv_asset_number		   okl_assets_b.asset_number%TYPE;
    ln_index			   NUMBER;

    --Bug 7291307 : Adding starts
 	     cursor get_quote_id_csr(p_asset_id NUMBER) IS
 	     select PARENT_OBJECT_ID
 	     from okl_assets_b
 	     where id=p_asset_id
 	     and parent_object_code='LEASEQUOTE';

 	     l_cost_adj_desc okl_cost_adjustments_tl.description%TYPE;
 	     l_sync_desc   VARCHAR2(1):='N';
 	     l_quote_id okl_lease_quotes_b.id%TYPE;
   --Bug 7291307 : Adding end

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_asset_adj_tbl := p_asset_adj_tbl;

    ln_index := l_asset_adj_tbl.FIRST;
    -- Validate Adjustment assets amount
    IF (l_asset_adj_tbl(ln_index).adjustment_source_type <> 'SUBSIDY') THEN
      ----Fixing Bug # 4735811 ssdeshpa Start
      /*
      process_link_asset_amounts(p_adj_amount        =>  l_asset_adj_tbl(ln_index).adjustment_amount,
                                 p_assoc_assets_tbl  =>  l_asset_adj_tbl,
                                 x_return_status     =>  x_return_status);

       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      */
      --Fixing Bug # 4735811 ssdeshpa End
      validate_adjust_assets(p_adj_amount        =>  l_asset_adj_tbl(ln_index).adjustment_amount,
                             p_assoc_assets_tbl  =>  l_asset_adj_tbl,
                             x_return_status     =>  x_return_status);
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Check not to create multiple Down payment or Trade-in for an Asset
      -- Bug 5028117
      asset_adj_defined	:= is_asset_adj_defined(p_assoc_assets_tbl  =>  l_asset_adj_tbl,
	  											x_asset_id			=>  x_asset_id);

      IF (asset_adj_defined = 'Y') THEN

	    SELECT asset_number
	    INTO lv_asset_number
	    FROM okl_assets_b
	    where id = x_asset_id;

        IF (l_asset_adj_tbl(ln_index).adjustment_source_type = 'DOWN_PAYMENT') THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_SALES_DP_DUP_ENTRY',
                               p_token1       => 'ASSET_NUMBER',
                               p_token1_value => lv_asset_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSIF (l_asset_adj_tbl(ln_index).adjustment_source_type = 'TRADEIN') THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_SALES_TI_DUP_ENTRY',
                               p_token1       => 'ASSET_NUMBER',
                               p_token1_value => lv_asset_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      -- End fix for Bug 5028117

    END IF;
    lb_validate_subsidy_usage := TRUE;
    FOR i IN l_asset_adj_tbl.FIRST .. l_asset_adj_tbl.LAST LOOP
      IF l_asset_adj_tbl.EXISTS(i) THEN
        --asawanka bug 5025239 fix starts

        IF (l_asset_adj_tbl(i).value IS NOT NULL AND l_asset_adj_tbl(i).value < 0) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_ADJ_AMOUNT_NEGATIVE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --asawanka bug 5025239 fix ends
        l_adj_assets_tbl(i).parent_object_code := l_asset_adj_tbl(i).parent_object_code;
        l_adj_assets_tbl(i).parent_object_id := l_asset_adj_tbl(i).parent_object_id;
        l_adj_assets_tbl(i).adjustment_source_type := l_asset_adj_tbl(i).adjustment_source_type;
        l_adj_assets_tbl(i).adjustment_source_id := l_asset_adj_tbl(i).adjustment_source_id;
        l_adj_assets_tbl(i).basis := l_asset_adj_tbl(i).basis;
        l_adj_assets_tbl(i).value := l_asset_adj_tbl(i).value;
        l_adj_assets_tbl(i).default_subsidy_amount := l_asset_adj_tbl(i).default_subsidy_amount;
        l_adj_assets_tbl(i).processing_type := l_asset_adj_tbl(i).processing_type;
        l_adj_assets_tbl(i).supplier_id := l_asset_adj_tbl(i).supplier_id;
        --Bug # 5142940 ssdeshpa start
        l_adj_assets_tbl(i).stream_type_id := l_asset_adj_tbl(i).stream_type_id;
        --Bug # 5142940 ssdeshpa end
        l_adj_assets_tbl(i).short_description := l_asset_adj_tbl(i).short_description;
        l_adj_assets_tbl(i).description := l_asset_adj_tbl(i).description;
        l_adj_assets_tbl(i).comments := l_asset_adj_tbl(i).comments;
        l_adj_assets_tbl(i).percent_basis_value := l_asset_adj_tbl(i).percent_basis_value;
        IF l_asset_adj_tbl(i).adjustment_source_id IS NULL THEN
          lb_validate_subsidy_usage := FALSE;
        END IF;
     --Bug 7291307 : get the description-adding start
	   IF (l_asset_adj_tbl(i).adjustment_source_type = 'TRADEIN')
	       and (l_sync_desc<>'Y') THEN
	       l_cost_adj_desc :=l_asset_adj_tbl(i).description;
	       l_sync_desc:='Y';

	       open get_quote_id_csr(l_adj_assets_tbl(i).parent_object_id);
	       fetch get_quote_id_csr into l_quote_id;
	       close get_quote_id_csr;
	   END IF;
     --Bug 7291307 : get the description-adding end
      END IF;
    END LOOP;


    -- Validate Subsidy Usage
    IF (l_adj_assets_tbl.COUNT > 0) THEN

      ln_index := l_adj_assets_tbl.FIRST;

      IF (l_adj_assets_tbl(ln_index).adjustment_source_type = 'SUBSIDY' AND lb_validate_subsidy_usage) THEN
        validate_subsidy_usage(p_asset_id         =>  l_adj_assets_tbl(ln_index).parent_object_id,
  						       p_input_adj_tbl    =>  l_adj_assets_tbl,
                               x_return_status    =>  x_return_status);
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      okl_cdj_pvt.insert_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_cdjv_tbl      => l_adj_assets_tbl
                           ,x_cdjv_tbl      => lx_adj_assets_tbl );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    --Bug # 5142940 ssdeshpa start
    l_adj_assets_tbl := lx_adj_assets_tbl;
    IF (l_adj_assets_tbl.COUNT > 0) THEN
     FOR i IN l_adj_assets_tbl.FIRST .. l_adj_assets_tbl.LAST LOOP
        IF l_adj_assets_tbl.EXISTS(i) THEN
           IF(l_adj_assets_tbl(i).adjustment_source_type='DOWN_PAYMENT' AND
              l_adj_assets_tbl(i).processing_type='BILL' AND
              l_adj_assets_tbl(i).stream_type_id IS NOT NULL) THEN
              --Create Rec Structure for Cash flows
              process_adj_cashflows(p_cdjv_rec  => l_adj_assets_tbl(i)
                                   ,p_event_mode    => 'create'
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data
                                   ,x_return_status => x_return_status);

              IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;
        END IF;
     END LOOP;
    END IF;

    --Bug # 5142940 ssdeshpa end

    /*SELECT qte.parent_object_id,qte.parent_object_code
    INTO l_p_id,l_p_code
    FROM okl_assets_b ast,okl_lease_quotes_b qte
    WHERE qte.id = ast.parent_object_id
    AND   ast.id= l_asset_adj_tbl(1).parent_object_id;


    OKL_LEASE_QUOTE_PRICING_PVT.handle_parent_object_status(
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

   --Bug 7291307 :Adding start
    IF l_sync_desc='Y' and
	l_quote_id is not null THEN
	sync_tradein_description ( p_api_version   => G_API_VERSION,
				   p_init_msg_list => G_FALSE,
				   x_msg_count     => x_msg_count,
				   x_msg_data      => x_msg_data,
				   x_return_status => x_return_status,
								   p_quote_id          => l_quote_id,
								   p_description   => l_cost_adj_desc
								   );
     END IF;

     IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
  --Bug 7291307 :Adding end


    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END;

  ------------------------------
  -- PROCEDURE update_adjustment
  ------------------------------
  PROCEDURE update_adjustment (p_api_version             IN  NUMBER,
                               p_init_msg_list           IN  VARCHAR2,
                               p_transaction_control     IN  VARCHAR2,
                               p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_adjustment';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_asset_adj_tbl        asset_adjustment_tbl_type;
    l_adj_assets_tbl       asset_adj_tbl_type;
    lx_adj_assets_tbl      asset_adj_tbl_type;
    l_deleted_adjust_tbl   asset_adj_tbl_type;
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);
    ln_total_subsidy_amount	NUMBER := 0;
    ln_index				NUMBER;
    --Bug 7291307 : Adding start
     l_cost_adj_desc okl_cost_adjustments_tl.description%TYPE;
     l_sync_desc   VARCHAR2(1):='N';
     l_quote_id okl_lease_quotes_b.id%TYPE;
     --Bug 7291307 : Adding end

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_asset_adj_tbl := p_asset_adj_tbl;

    ln_index := l_asset_adj_tbl.FIRST;
  /*
    -- Validate Adjustment assets amount
    IF (l_asset_adj_tbl(ln_index).adjustment_source_type <> 'SUBSIDY') THEN
    --Fixing Bug # 4735811 ssdeshpa Start

      process_link_asset_amounts(p_adj_amount        =>  l_asset_adj_tbl(ln_index).adjustment_amount,
                                 p_assoc_assets_tbl  =>  l_asset_adj_tbl,
                                 x_return_status     =>  x_return_status);

       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Fixing Bug # 4735811 ssdeshpa End
      validate_adjust_assets(p_adj_amount        =>  l_asset_adj_tbl(ln_index).adjustment_amount,
                             p_assoc_assets_tbl  =>  l_asset_adj_tbl,
                             x_return_status     =>  x_return_status);
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
*/
    IF (l_asset_adj_tbl(ln_index).adjustment_source_type = 'SUBSIDY') THEN
      get_deleted_adjusted_assets (p_adj_type             => l_asset_adj_tbl(ln_index).adjustment_source_type,
                                   p_quote_id             => l_asset_adj_tbl(ln_index).quote_id,
                                   p_adjustment_tbl       => l_asset_adj_tbl,
                                   x_deleted_adjust_tbl   => l_deleted_adjust_tbl,
                                   x_return_status        => x_return_status );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_deleted_adjust_tbl.COUNT > 0 THEN
        okl_cdj_pvt.delete_row (p_api_version   => G_API_VERSION
                               ,p_init_msg_list => G_FALSE
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_cdjv_tbl      => l_deleted_adjust_tbl );

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      END IF;
    IF (l_asset_adj_tbl.COUNT > 0 AND l_asset_adj_tbl(ln_index).adjustment_source_type = 'SUBSIDY') THEN
      FOR j IN l_asset_adj_tbl.FIRST .. l_asset_adj_tbl.LAST LOOP
     	IF l_asset_adj_tbl.EXISTS(j) THEN
          IF (l_asset_adj_tbl(j).value IS NOT NULL) THEN
            ln_total_subsidy_amount := ln_total_subsidy_amount + l_asset_adj_tbl(j).value;
          ELSE
            ln_total_subsidy_amount := ln_total_subsidy_amount + l_asset_adj_tbl(j).default_subsidy_amount;
          END IF;
        END IF;
      END LOOP;
    END IF;

    FOR i IN l_asset_adj_tbl.FIRST .. l_asset_adj_tbl.LAST LOOP
      IF l_asset_adj_tbl.EXISTS(i) THEN
        IF l_asset_adj_tbl(i).record_mode = 'create' THEN
          --asawanka bug 5025239 fix starts
          IF (l_asset_adj_tbl(i).value IS NOT NULL AND l_asset_adj_tbl(i).value < 0) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_ADJ_AMOUNT_NEGATIVE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --asawanka bug 5025239 fix ends
          l_adj_assets_tbl(i).parent_object_code := l_asset_adj_tbl(i).parent_object_code;
          l_adj_assets_tbl(i).parent_object_id := l_asset_adj_tbl(i).parent_object_id;
          l_adj_assets_tbl(i).adjustment_source_type := l_asset_adj_tbl(i).adjustment_source_type;
          l_adj_assets_tbl(i).adjustment_source_id := l_asset_adj_tbl(i).adjustment_source_id;
          l_adj_assets_tbl(i).basis := l_asset_adj_tbl(i).basis;
          l_adj_assets_tbl(i).value := l_asset_adj_tbl(i).value;
          l_adj_assets_tbl(i).default_subsidy_amount := l_asset_adj_tbl(i).default_subsidy_amount;
          l_adj_assets_tbl(i).processing_type := l_asset_adj_tbl(i).processing_type;
          l_adj_assets_tbl(i).supplier_id := l_asset_adj_tbl(i).supplier_id;
          --bug # 5142940 ssdeshpa start
          l_adj_assets_tbl(i).stream_type_id := l_asset_adj_tbl(i).stream_type_id;
          --bug # 5142940 ssdeshpa end
          l_adj_assets_tbl(i).short_description := l_asset_adj_tbl(i).short_description;
          l_adj_assets_tbl(i).description := l_asset_adj_tbl(i).description;
          l_adj_assets_tbl(i).comments := l_asset_adj_tbl(i).comments;
          l_adj_assets_tbl(i).percent_basis_value := l_asset_adj_tbl(i).percent_basis_value;
          IF (l_asset_adj_tbl(i).adjustment_source_type = 'SUBSIDY') THEN
      	    validate_subsidy_usage(p_asset_id         =>  l_adj_assets_tbl(i).parent_object_id,
      	  				  		   p_total_subsidy_amount  =>  ln_total_subsidy_amount,
  						     	   p_input_adj_rec    =>  l_adj_assets_tbl(i),
                             	   x_return_status    =>  x_return_status);
      	    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	    ELSIF x_return_status = G_RET_STS_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_ERROR;
      	    END IF;
      	  END IF;

          okl_cdj_pvt.insert_row (p_api_version   => G_API_VERSION
                                 ,p_init_msg_list => G_FALSE
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_cdjv_rec      => l_adj_assets_tbl(i)
                                 ,x_cdjv_rec      => lx_adj_assets_tbl(i));

           IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF x_return_status = G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           --Bug # 5142940 ssdeshpa start
           IF(lx_adj_assets_tbl(i).adjustment_source_type='DOWN_PAYMENT' AND
              lx_adj_assets_tbl(i).processing_type='BILL' AND
              lx_adj_assets_tbl(i).stream_type_id IS NOT NULL) THEN
              --Create Rec Structure for Cash flows
              process_adj_cashflows(p_cdjv_rec      => lx_adj_assets_tbl(i)
                                   ,p_event_mode    => 'create'
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data
                                   ,x_return_status => x_return_status);

              IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;
        ELSIF l_asset_adj_tbl(i).record_mode = 'update' THEN

           --asawanka bug 5025239 fix starts
          IF (l_asset_adj_tbl(i).value IS NULL) THEN
            IF l_asset_adj_tbl(i).adjustment_source_type = 'SUBSIDY' THEN
              IF   l_asset_adj_tbl(i).default_subsidy_amount  IS NULL  THEN
                OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_LINKASSET_NULL_FOUND');
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            ELSE
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_LINKASSET_NULL_FOUND');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
          IF (l_asset_adj_tbl(i).value IS NOT NULL AND l_asset_adj_tbl(i).value < 0) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_ADJ_AMOUNT_NEGATIVE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

	  --Bug 7291307 : Adding start
	   IF (l_asset_adj_tbl(i).adjustment_source_type = 'TRADEIN')
	       and (l_sync_desc<>'Y') THEN
	       l_cost_adj_desc :=l_asset_adj_tbl(i).description;
	       l_sync_desc:='Y';
	       l_quote_id:=l_asset_adj_tbl(i).quote_id;
	   END IF;
	  --Bug 7291307 : Adding  end

          --asawanka bug 5025239 fix ends
          l_adj_assets_tbl(i).id := l_asset_adj_tbl(i).id;
          l_adj_assets_tbl(i).object_version_number := l_asset_adj_tbl(i).object_version_number;
          l_adj_assets_tbl(i).parent_object_code := l_asset_adj_tbl(i).parent_object_code;
          l_adj_assets_tbl(i).parent_object_id := l_asset_adj_tbl(i).parent_object_id;
          l_adj_assets_tbl(i).adjustment_source_type := l_asset_adj_tbl(i).adjustment_source_type;
          l_adj_assets_tbl(i).adjustment_source_id := l_asset_adj_tbl(i).adjustment_source_id;
          l_adj_assets_tbl(i).basis := l_asset_adj_tbl(i).basis;
          l_adj_assets_tbl(i).value := l_asset_adj_tbl(i).value;
          l_adj_assets_tbl(i).default_subsidy_amount := l_asset_adj_tbl(i).default_subsidy_amount;
          l_adj_assets_tbl(i).processing_type := l_asset_adj_tbl(i).processing_type;
          l_adj_assets_tbl(i).supplier_id := l_asset_adj_tbl(i).supplier_id;
          --bug # 5142940 ssdeshpa start
          l_adj_assets_tbl(i).stream_type_id := l_asset_adj_tbl(i).stream_type_id;
          --bug # 5142940 ssdeshpa end
          l_adj_assets_tbl(i).short_description := l_asset_adj_tbl(i).short_description;
          l_adj_assets_tbl(i).description := l_asset_adj_tbl(i).description;
          l_adj_assets_tbl(i).comments := l_asset_adj_tbl(i).comments;
          l_adj_assets_tbl(i).percent_basis_value := l_asset_adj_tbl(i).percent_basis_value;

          IF (l_asset_adj_tbl(i).adjustment_source_type = 'SUBSIDY') THEN
      	  	validate_subsidy_usage(p_asset_id         =>  l_adj_assets_tbl(i).parent_object_id,
      	  				  		   p_total_subsidy_amount  =>  ln_total_subsidy_amount,
  						     	   p_input_adj_rec    =>  l_adj_assets_tbl(i),
                             	   x_return_status    =>  x_return_status);
      	    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	    ELSIF x_return_status = G_RET_STS_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_ERROR;
      	    END IF;
      	  END IF;

          okl_cdj_pvt.update_row (p_api_version   => G_API_VERSION
                                 ,p_init_msg_list => G_FALSE
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_cdjv_rec      => l_adj_assets_tbl(i)
                                 ,x_cdjv_rec      => lx_adj_assets_tbl(i));
          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	    ELSIF x_return_status = G_RET_STS_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_ERROR;
      	    END IF;

      	  process_adj_cashflows(p_cdjv_rec      => lx_adj_assets_tbl(i)
                               ,p_event_mode    => 'update'
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,x_return_status => x_return_status);

          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  ELSIF x_return_status = G_RET_STS_ERROR THEN
        	  RAISE OKL_API.G_EXCEPTION_ERROR;
      	  END IF;


        END IF;--l_asset_adj_tbl(i).record_mode = 'create'
      END IF;
    END LOOP;

   --Bug 7291307 - Adding start
    IF l_sync_desc='Y' and
	l_quote_id is not null THEN
	sync_tradein_description ( p_api_version   => G_API_VERSION,
				   p_init_msg_list => G_FALSE,
				   x_msg_count     => x_msg_count,
				   x_msg_data      => x_msg_data,
				   x_return_status => x_return_status,
								   p_quote_id          => l_quote_id,
								   p_description   => l_cost_adj_desc
								   );
    END IF;
   --Bug 7291307 - Adding end

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*SELECT qte.parent_object_id,qte.parent_object_code
    INTO l_p_id,l_p_code
    FROM okl_assets_b ast,okl_lease_quotes_b qte
    WHERE qte.id = ast.parent_object_id
    AND   ast.id= l_asset_adj_tbl(1).parent_object_id;


    OKL_LEASE_QUOTE_PRICING_PVT.handle_parent_object_status(
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


    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END;

  ------------------------------
  -- PROCEDURE delete_adjustment
  ------------------------------
  PROCEDURE delete_adjustment (p_api_version             IN  NUMBER,
                               p_init_msg_list           IN  VARCHAR2,
                               p_transaction_control     IN  VARCHAR2,
                               p_adjustment_type         IN  VARCHAR2,
                               p_adjustment_id           IN  NUMBER,
                               p_quote_id                IN  NUMBER,
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_adjustment';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_adj_assets_tbl       asset_adj_tbl_type;
    i                      BINARY_INTEGER := 0;
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);

    CURSOR c_db_adj_assets IS
      SELECT costadj.id, costadj.adjustment_source_id
      FROM   okl_cost_adjustments_b costadj,
             okl_assets_b asset
      WHERE  costadj.adjustment_source_type = p_adjustment_type
      AND  costadj.parent_object_id = asset.id
      AND  costadj.parent_object_code = 'ASSET'
      AND  asset.parent_object_id = p_quote_id
      AND  asset.parent_object_code = 'LEASEQUOTE';

    CURSOR c_db_adj_asset(p_asset_id  IN NUMBER) IS
      SELECT costadj.id,costadj.adjustment_source_type,costadj.processing_type,costadj.stream_type_id
      FROM   okl_cost_adjustments_b costadj
      WHERE  costadj.adjustment_source_type = p_adjustment_type
      AND  costadj.parent_object_id = p_asset_id
      AND  costadj.parent_object_code = 'ASSET';
  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;
    --Bug # 5142940 ssdeshpa start
    --Fix Bug # 4894844 Start
    IF p_adjustment_type = 'SUBSIDY'  THEN
      IF p_adjustment_id IS NULL THEN
          FOR l_db_adj_assets IN c_db_adj_assets LOOP
             l_adj_assets_tbl(i).id := l_db_adj_assets.id;
             i := i + 1;
          END LOOP;
      ELSE
        FOR l_db_adj_assets IN c_db_adj_assets LOOP
          IF l_db_adj_assets.adjustment_source_id = p_adjustment_id THEN
            l_adj_assets_tbl(i).id := l_db_adj_assets.id;
            i := i + 1;
          END IF;
        END LOOP;
      END IF;
    ELSIF(p_adjustment_type IN ('DOWN_PAYMENT', 'TRADEIN')) THEN
      OPEN c_db_adj_asset(p_asset_id  =>  p_adjustment_id);
      FETCH c_db_adj_asset INTO l_adj_assets_tbl(i).id , l_adj_assets_tbl(i).adjustment_source_type, l_adj_assets_tbl(i).processing_type,l_adj_assets_tbl(i).stream_type_id;
      CLOSE c_db_adj_asset;
      --Bug # 5142940 ssdeshpa start
      l_adj_assets_tbl(i).parent_object_id := p_adjustment_id;
      --Bug # 5142940 ssdeshpa start
    END IF;
    --Fix Bug # 4894844 end
    --Bug # 5142940 ssdeshpa end
    IF l_adj_assets_tbl.COUNT > 0 THEN
      okl_cdj_pvt.delete_row (p_api_version   => G_API_VERSION
                             ,p_init_msg_list => G_FALSE
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_cdjv_tbl      => l_adj_assets_tbl);
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Bug # 5142940 ssdeshpa start
      FOR i IN l_adj_assets_tbl.FIRST .. l_adj_assets_tbl.LAST LOOP
        IF l_adj_assets_tbl.EXISTS(i) THEN
           IF(l_adj_assets_tbl(i).adjustment_source_type='DOWN_PAYMENT' AND
              l_adj_assets_tbl(i).processing_type='BILL' AND
              l_adj_assets_tbl(i).stream_type_id IS NOT NULL) THEN
              --Delete Rec Structure for Cash flows
              process_adj_cashflows(p_cdjv_rec      => l_adj_assets_tbl(i)
                                   ,p_event_mode    => 'delete'
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data
                                   ,x_return_status => x_return_status);

              IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;
        END IF;
     END LOOP;
      --Bug # 5142940 ssdeshpa start
    END IF;

   /*SELECT parent_object_id,parent_object_code INTO l_p_id,l_p_code
   FROM okl_lease_quotes_b where ID = p_quote_id;

   OKL_LEASE_QUOTE_PRICING_PVT.handle_parent_object_status(
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


    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END;

  --------------------------------------
  -- PROCEDURE duplicate_asset_cashflows
  --------------------------------------
  PROCEDURE duplicate_asset_cashflows (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_object           IN  VARCHAR2
    ,p_source_id               IN  NUMBER
    ,p_target_id               IN  NUMBER
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'duplicate_asset_cashflows';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_cashflow_header_rec            cashflow_hdr_rec_type;
    l_cashflow_level_tbl             cashflow_level_tbl_type;

    l_return_status        VARCHAR2(1);
    l_cashflow_object_id   NUMBER;
    lv_cft_code            VARCHAR2(30);
    lv_frq_code            VARCHAR2(30);
    lv_stream_type_purpose VARCHAR2(150);
    i                      BINARY_INTEGER := 0;
    j                      BINARY_INTEGER := 0;
    lv_parent_object_code  VARCHAR2(30);
    --Fix Bug # 5021724 ssdeshpa start
    --Cursor is not fetching the correct source cashflows;added where conditions.
    CURSOR c_get_cashflow_object_info(p_src_id OKL_CASH_FLOW_OBJECTS.SOURCE_ID%TYPE)
    IS
    SELECT ID
    FROM   OKL_CASH_FLOW_OBJECTS
    WHERE SOURCE_ID = p_src_id
    AND   OTY_CODE = 'QUOTED_ASSET'
    AND SOURCE_TABLE='OKL_ASSETS_B';
    --Fix Bug # 5021724 ssdeshpa end

    CURSOR c_get_cashflow_info(p_cfo_id OKL_CASH_FLOWS.CFO_ID%TYPE)
    IS
    SELECT CFLOW.ID, CFLOW.STY_ID, CFLOW.DUE_ARREARS_YN, CFLOW.CFT_CODE, STRMTYP.STREAM_TYPE_PURPOSE
    FROM   OKL_CASH_FLOWS CFLOW,
           OKL_STRMTYP_SOURCE_V STRMTYP
    WHERE CFO_ID = p_cfo_id
    AND CFLOW.STY_ID = STRMTYP.ID1;

    CURSOR c_get_cashflow_levels(p_caf_id OKL_CASH_FLOWS.ID%TYPE)
    IS
    SELECT AMOUNT, NUMBER_OF_PERIODS, FQY_CODE, STUB_DAYS, STUB_AMOUNT
    FROM   OKL_CASH_FLOW_LEVELS
    WHERE CAF_ID = p_caf_id;

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    FOR l_get_cashflow_object_info IN c_get_cashflow_object_info(p_src_id => p_source_id) LOOP
      l_cashflow_object_id := l_get_cashflow_object_info.id;

      OPEN  c_get_cashflow_info(p_cfo_id => l_cashflow_object_id);
      FETCH c_get_cashflow_info INTO l_cashflow_header_rec.cashflow_header_id,
                                     l_cashflow_header_rec.stream_type_id,
                                     l_cashflow_header_rec.arrears_flag,
                                     lv_cft_code, lv_stream_type_purpose;
      CLOSE c_get_cashflow_info;

      IF (lv_stream_type_purpose = 'RENT') THEN
        l_cashflow_header_rec.parent_object_code := p_source_object;
        l_cashflow_header_rec.parent_object_id := p_target_id;
        l_cashflow_header_rec.quote_id := p_quote_id;

        IF (lv_cft_code = 'PAYMENT_SCHEDULE') THEN
          l_cashflow_header_rec.type_code := 'INFLOW';
        ELSIF (lv_cft_code = 'OUTFLOW_SCHEDULE') THEN
          l_cashflow_header_rec.type_code := 'OUTFLOW';
        END IF;

        SELECT parent_object_code
        INTO lv_parent_object_code
        FROM okl_lease_quotes_b
        where id = p_quote_id;

        IF (lv_parent_object_code = 'LEASEOPP') THEN
          l_cashflow_header_rec.quote_type_code := 'LQ';
        ELSIF (lv_parent_object_code = 'LEASEAPP') THEN
          l_cashflow_header_rec.quote_type_code := 'LA';
        END IF;

        FOR l_get_cashflow_levels IN c_get_cashflow_levels(p_caf_id => l_cashflow_header_rec.cashflow_header_id) LOOP
          l_cashflow_level_tbl(j).record_mode := 'create';
          l_cashflow_level_tbl(j).periods := l_get_cashflow_levels.number_of_periods;
          l_cashflow_level_tbl(j).periodic_amount := l_get_cashflow_levels.amount;
          l_cashflow_level_tbl(j).stub_days := l_get_cashflow_levels.stub_days;
          l_cashflow_level_tbl(j).stub_amount := l_get_cashflow_levels.stub_amount;
          lv_frq_code := l_get_cashflow_levels.fqy_code;
          j := j + 1;
        END LOOP;

        l_cashflow_header_rec.frequency_code := lv_frq_code;

        okl_lease_quote_cashflow_pvt.create_cashflow ( p_api_version          => p_api_version
                                                      ,p_init_msg_list        => p_init_msg_list
                                                      ,p_transaction_control  => p_transaction_control
                                                      ,p_cashflow_header_rec  => l_cashflow_header_rec
                                                      ,p_cashflow_level_tbl   => l_cashflow_level_tbl
                                                      ,x_return_status        => l_return_status
                                                      ,x_msg_count            => x_msg_count
                                                      ,x_msg_data             => x_msg_data);
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      i := i + 1;
    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END duplicate_asset_cashflows;

  --------------------------
  -- PROCEDURE get_asset_rec
  --------------------------
  PROCEDURE get_asset_rec (
    p_asset_id                  IN  NUMBER
   ,x_asset_rec                 OUT NOCOPY asset_rec_type
   ,x_return_status             OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_asset_rec';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

      SELECT
         attribute_category
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
        ,object_version_number
        ,asset_number
        ,parent_object_id
        ,parent_object_code
        ,install_site_id
        ,rate_card_id
        ,rate_template_id
        ,oec
        ,end_of_term_value_default
        ,end_of_term_value
        ,oec_percentage
    	,structured_pricing
    	,target_arrears
    	,lease_rate_factor
    	,target_amount
    	,target_frequency
        ,short_description
        ,description
        ,comments
      INTO
         x_asset_rec.attribute_category
        ,x_asset_rec.attribute1
        ,x_asset_rec.attribute2
        ,x_asset_rec.attribute3
        ,x_asset_rec.attribute4
        ,x_asset_rec.attribute5
        ,x_asset_rec.attribute6
        ,x_asset_rec.attribute7
        ,x_asset_rec.attribute8
        ,x_asset_rec.attribute9
        ,x_asset_rec.attribute10
        ,x_asset_rec.attribute11
        ,x_asset_rec.attribute12
        ,x_asset_rec.attribute13
        ,x_asset_rec.attribute14
        ,x_asset_rec.attribute15
        ,x_asset_rec.object_version_number
        ,x_asset_rec.asset_number
        ,x_asset_rec.parent_object_id
        ,x_asset_rec.parent_object_code
        ,x_asset_rec.install_site_id
        ,x_asset_rec.rate_card_id
        ,x_asset_rec.rate_template_id
        ,x_asset_rec.oec
        ,x_asset_rec.end_of_term_value_default
        ,x_asset_rec.end_of_term_value
        ,x_asset_rec.oec_percentage
    	,x_asset_rec.structured_pricing
    	,x_asset_rec.target_arrears
    	,x_asset_rec.lease_rate_factor
    	,x_asset_rec.target_amount
    	,x_asset_rec.target_frequency
        ,x_asset_rec.short_description
        ,x_asset_rec.description
        ,x_asset_rec.comments
      FROM okl_assets_v
      WHERE id = p_asset_id;

      x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_asset_rec;

  -----------------------------------
  -- PROCEDURE populate_asset_attribs
  -----------------------------------
  PROCEDURE populate_asset_attribs (
    p_source_asset_id           IN  NUMBER
   ,x_asset_rec                 IN OUT NOCOPY asset_rec_type
   ,x_return_status             OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'populate_asset_attribs';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_asset_rec            asset_rec_type;

  BEGIN

      SELECT
         rate_card_id
        ,rate_template_id
        ,structured_pricing
    	,target_arrears
	    ,lease_rate_factor
    	,target_amount
	    ,target_frequency
      INTO
         x_asset_rec.rate_card_id
        ,x_asset_rec.rate_template_id
    	,x_asset_rec.structured_pricing
    	,x_asset_rec.target_arrears
    	,x_asset_rec.lease_rate_factor
    	,x_asset_rec.target_amount
    	,x_asset_rec.target_frequency
      FROM okl_assets_v
      WHERE id = p_source_asset_id;

      x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END populate_asset_attribs;

  -------------------------------
  -- PROCEDURE get_asset_comp_tbl
  -------------------------------
  PROCEDURE get_asset_comp_tbl (
    p_asset_id                  IN  NUMBER
   ,x_asset_comp_tbl            OUT NOCOPY component_tbl_type
   ,x_return_status             OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_asset_comp_tbl';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    i                      BINARY_INTEGER := 0;

    CURSOR c_db_asset_comp IS
      SELECT
         id
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
        ,asset_id
        ,object_version_number
        ,inv_item_id
        ,supplier_id
        ,primary_component
        ,unit_cost
        ,number_of_units
        ,manufacturer_name
        ,year_manufactured
        ,model_number
        ,short_description
        ,description
        ,comments
      FROM okl_asset_components_v
      WHERE asset_id = p_asset_id;
  BEGIN
    FOR l_db_asset_comp IN c_db_asset_comp LOOP
      x_asset_comp_tbl(i).id := l_db_asset_comp.id;
      x_asset_comp_tbl(i).attribute_category := l_db_asset_comp.attribute_category;
      x_asset_comp_tbl(i).attribute1 := l_db_asset_comp.attribute1;
      x_asset_comp_tbl(i).attribute2 := l_db_asset_comp.attribute2;
      x_asset_comp_tbl(i).attribute3 := l_db_asset_comp.attribute3;
      x_asset_comp_tbl(i).attribute4 := l_db_asset_comp.attribute4;
      x_asset_comp_tbl(i).attribute5 := l_db_asset_comp.attribute5;
      x_asset_comp_tbl(i).attribute6 := l_db_asset_comp.attribute6;
      x_asset_comp_tbl(i).attribute7 := l_db_asset_comp.attribute7;
      x_asset_comp_tbl(i).attribute8 := l_db_asset_comp.attribute8;
      x_asset_comp_tbl(i).attribute9 := l_db_asset_comp.attribute9;
      x_asset_comp_tbl(i).attribute10 := l_db_asset_comp.attribute10;
      x_asset_comp_tbl(i).attribute11 := l_db_asset_comp.attribute11;
      x_asset_comp_tbl(i).attribute12 := l_db_asset_comp.attribute12;
      x_asset_comp_tbl(i).attribute13 := l_db_asset_comp.attribute13;
      x_asset_comp_tbl(i).attribute14 := l_db_asset_comp.attribute14;
      x_asset_comp_tbl(i).attribute15 := l_db_asset_comp.attribute15;
      x_asset_comp_tbl(i).asset_id := l_db_asset_comp.asset_id;
      x_asset_comp_tbl(i).object_version_number := l_db_asset_comp.object_version_number;
      x_asset_comp_tbl(i).inv_item_id := l_db_asset_comp.inv_item_id;
      x_asset_comp_tbl(i).supplier_id := l_db_asset_comp.supplier_id;
      x_asset_comp_tbl(i).primary_component := l_db_asset_comp.primary_component;
      x_asset_comp_tbl(i).unit_cost := l_db_asset_comp.unit_cost;
      x_asset_comp_tbl(i).number_of_units := l_db_asset_comp.number_of_units;
      x_asset_comp_tbl(i).manufacturer_name := l_db_asset_comp.manufacturer_name;
      x_asset_comp_tbl(i).year_manufactured := l_db_asset_comp.year_manufactured;
      x_asset_comp_tbl(i).model_number := l_db_asset_comp.model_number;
      x_asset_comp_tbl(i).short_description := l_db_asset_comp.short_description;
      x_asset_comp_tbl(i).description := l_db_asset_comp.description;
      x_asset_comp_tbl(i).comments := l_db_asset_comp.comments;
      i := i + 1;
    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_asset_comp_tbl;

  ----------------------------
  -- PROCEDURE duplicate_asset
  ----------------------------
  PROCEDURE duplicate_asset (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_asset_id         IN  NUMBER
    ,p_target_quote_id         IN  NUMBER
    ,x_target_asset_id         OUT NOCOPY NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2 ) IS

      l_program_name         CONSTANT VARCHAR2(30) := 'duplicate_asset';
      l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

      l_asset_rec            asset_rec_type;
      lx_asset_rec           asset_rec_type;

      l_component_tbl        component_tbl_type;
      lx_component_tbl       component_tbl_type;

	  lv_pricing_type_equal	VARCHAR2(1) := 'Y';
      lb_copy_cashflow       BOOLEAN  := TRUE;
      lb_default_eot		 BOOLEAN  := TRUE;
      lb_dup_asset		 	 BOOLEAN  := TRUE;
      ld_src_start_date      DATE;
      ld_tgt_start_date      DATE;
      ln_src_pdt_id        NUMBER;
      ln_tgt_pdt_id        NUMBER;
      lv_src_pricing_type	VARCHAR2(30);
      lv_tgt_pricing_type	VARCHAR2(30);
      l_parent_object_code  okl_lease_quotes_b.parent_object_code%TYPE;
      ln_src_eot_id		   NUMBER;
      ln_tgt_eot_id		   NUMBER;

    BEGIN

      IF p_transaction_control = G_TRUE THEN
        SAVEPOINT l_program_name;
      END IF;

      IF p_init_msg_list = G_TRUE THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Validation to check if the product and expected start date for source
      -- and target contracts are equal, if not cash flows are not copied.
      SELECT quote.expected_start_date,
             quote.product_id,
             quote.pricing_method,
             quote.end_of_term_option_id
      INTO ld_src_start_date, ln_src_pdt_id, lv_src_pricing_type, ln_src_eot_id
      FROM
           okl_assets_b asset,
           okl_lease_quotes_b quote
      WHERE
         asset.id = p_source_asset_id
      AND asset.parent_object_id = quote.id
      AND asset.parent_object_code = 'LEASEQUOTE';

      SELECT expected_start_date,
             product_id,
             pricing_method,
             parent_object_code,
             end_of_term_option_id
      INTO ld_tgt_start_date, ln_tgt_pdt_id, lv_tgt_pricing_type,l_parent_object_code, ln_tgt_eot_id
      FROM
           okl_lease_quotes_b
      WHERE
           id = p_target_quote_id;

      IF ((ld_src_start_date <> ld_tgt_start_date) OR (ln_src_pdt_id <> ln_tgt_pdt_id)) THEN
        lb_copy_cashflow := FALSE;
        lb_default_eot := FALSE;
      END IF;

      IF (ln_src_eot_id <> ln_tgt_eot_id) THEN
	    lb_dup_asset := FALSE;
	  END IF;

      IF (lb_dup_asset) THEN -- Duplicate Asset

        -- Fetch Asset Header
        get_asset_rec (
          p_asset_id      => p_source_asset_id
         ,x_asset_rec     => l_asset_rec
         ,x_return_status => x_return_status);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Check for duplicate from/to 'Solve for Financed Amount' quote
        IF (lv_src_pricing_type <> 'SF' AND lv_tgt_pricing_type = 'SF') THEN
          l_asset_rec.oec := null;
        ELSIF (lv_src_pricing_type = 'SF' AND lv_tgt_pricing_type <> 'SF') THEN
          l_asset_rec.oec_percentage := null;
        END IF;
        -- End

        -- Check if the Source and Target Quote's Pricing type are equal
        -- if not cash flows are not copied.
        IF (lb_copy_cashflow) THEN
          lv_pricing_type_equal := is_pricing_method_equal(p_source_quote_id => l_asset_rec.parent_object_id,
    	  											       p_target_quote_id => p_target_quote_id);

          IF (l_parent_object_code <> 'LEASEAPP' AND lv_pricing_type_equal = 'N') THEN
            lb_copy_cashflow := FALSE;

            -- Nullify Pricing Params when the Pricing method is changed
    	    l_asset_rec.structured_pricing := null;
    	    l_asset_rec.target_arrears := null;
    	    l_asset_rec.lease_rate_factor := null;
    	    l_asset_rec.target_amount := null;
    	    l_asset_rec.target_frequency := null;
    	    --Bug # 5021937
    	    --Duplicate Copying the Pricing Parameters
    	    l_asset_rec.rate_card_id := null;
            l_asset_rec.rate_template_id := null;
            --Bug #5021937
          END IF;
        END IF;
        -- End

        -- Generate the Asset number from the sequence
        SELECT okl_qua_ref_seq.nextval INTO l_asset_rec.asset_number FROM DUAL;
        l_asset_rec.parent_object_id := p_target_quote_id;
        l_asset_rec.orig_asset_id := p_source_asset_id;

        -- If product or start date changed for target quote, do not default the
        -- end of term option for the asset, as it may not be valid.
        IF (NOT lb_default_eot) THEN
          l_asset_rec.end_of_term_value_default := NULL;
        END IF;
       --bug 5172808
        IF(lv_tgt_pricing_type = 'SY') THEN
         l_asset_rec.structured_pricing := 'Y';
        END IF;
           -- Duplicate Asset header
        okl_ass_pvt.insert_row (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec
                           ,x_assv_rec      => lx_asset_rec );

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        x_target_asset_id := lx_asset_rec.id;

        -- Fetch Asset Components
        get_asset_comp_tbl (
          p_asset_id       => p_source_asset_id
         ,x_asset_comp_tbl => l_component_tbl
         ,x_return_status  => x_return_status);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Update the Asset Components table with the created asset_id
        FOR i IN l_component_tbl.FIRST .. l_component_tbl.LAST LOOP
          IF l_component_tbl.EXISTS(i) THEN
            l_component_tbl(i).asset_id := x_target_asset_id;
            l_component_tbl(i).id := null;

            IF (l_component_tbl(i).primary_component = 'YES') THEN
        	  -- Check for duplicate from/to 'Solve for Financed Amount' quote
       		  IF (lv_src_pricing_type <> 'SF' AND lv_tgt_pricing_type = 'SF') THEN
        	    l_component_tbl(i).unit_cost := null;
      		  END IF;
      	      -- End
            END IF;
          END IF;
        END LOOP;

        -- Component table must contain at least 1 row for Asset
        okl_aso_pvt.insert_row (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_asov_tbl      => l_component_tbl
                           ,x_asov_tbl      => lx_component_tbl);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (lb_copy_cashflow) THEN
          okl_lease_quote_cashflow_pvt.duplicate_cashflows (
          p_api_version          => p_api_version
         ,p_init_msg_list        => p_init_msg_list
         ,p_transaction_control  => p_transaction_control
         ,p_source_object_code   => 'QUOTED_ASSET'
         ,p_source_object_id     => p_source_asset_id
         ,p_target_object_id     => x_target_asset_id
         ,p_quote_id             => p_target_quote_id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data        );

          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;  -- Duplicate Asset

      x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_asset;

  ----------------------------
  -- PROCEDURE duplicate_asset
  ----------------------------
  PROCEDURE duplicate_asset (p_api_version             IN  NUMBER,
                             p_init_msg_list           IN  VARCHAR2,
                             p_transaction_control     IN  VARCHAR2,
                             p_source_asset_id         IN  NUMBER,
                             p_asset_rec               IN  asset_rec_type,
                             p_component_tbl           IN  asset_component_tbl_type,
                             p_cf_hdr_rec              IN  cashflow_hdr_rec_type,
                             p_cf_level_tbl            IN  cashflow_level_tbl_type,
                             x_return_status           OUT NOCOPY VARCHAR2,
                             x_msg_count               OUT NOCOPY NUMBER,
                             x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'duplicate_asset';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;

    l_component_tbl        component_tbl_type;
    lx_component_tbl       component_tbl_type;

    l_asset_comp_tbl       asset_component_tbl_type;

    l_cf_hdr_rec           cashflow_hdr_rec_type;
    l_cashflow_level_tbl   cashflow_level_tbl_type;

    l_return_status        VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_asset_rec      := p_asset_rec;
    l_asset_comp_tbl := p_component_tbl;
    l_cf_hdr_rec     := p_cf_hdr_rec;
    l_cashflow_level_tbl := p_cf_level_tbl;

    -- Generate the Asset number from the sequence
    SELECT okl_qua_ref_seq.nextval INTO l_asset_rec.asset_number FROM DUAL;

    set_defaults ( p_asset_rec     => l_asset_rec
                  ,p_component_tbl => l_asset_comp_tbl
                  ,x_return_status => l_return_status );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    validate ( p_asset_rec     => l_asset_rec
              ,p_component_tbl => l_asset_comp_tbl
              ,x_return_status => l_return_status );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Assign EOT default value
    l_asset_rec.end_of_term_value_default := get_eot_default_value(
                p_asset_rec      => l_asset_rec,
                p_asset_comp_tbl => l_asset_comp_tbl,
                x_return_status  => l_return_status);
    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- End

    -- This populates other asset attributes which are not visible from the
    -- duplicate asset page
    populate_asset_attribs(p_source_asset_id => p_source_asset_id,
                           x_asset_rec       => l_asset_rec,
                           x_return_status   => l_return_status);
    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_ass_pvt.insert_row (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec
                           ,x_assv_rec      => lx_asset_rec
                           );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Update the Asset Components table with the created asset_id
    FOR i IN l_asset_comp_tbl.FIRST .. l_asset_comp_tbl.LAST LOOP
      IF l_asset_comp_tbl.EXISTS(i) THEN
        l_component_tbl(i).asset_id := lx_asset_rec.id;
        l_component_tbl(i).inv_item_id := l_asset_comp_tbl(i).inv_item_id;
        l_component_tbl(i).supplier_id := l_asset_comp_tbl(i).supplier_id;
        l_component_tbl(i).primary_component := l_asset_comp_tbl(i).primary_component;
        l_component_tbl(i).unit_cost := l_asset_comp_tbl(i).unit_cost;
        l_component_tbl(i).number_of_units := l_asset_comp_tbl(i).number_of_units;
        l_component_tbl(i).manufacturer_name := l_asset_comp_tbl(i).manufacturer_name;
        l_component_tbl(i).year_manufactured := l_asset_comp_tbl(i).year_manufactured;
        l_component_tbl(i).model_number := l_asset_comp_tbl(i).model_number;
        l_component_tbl(i).short_description := l_asset_comp_tbl(i).short_description;
        l_component_tbl(i).description := l_asset_comp_tbl(i).description;
        l_component_tbl(i).comments := l_asset_comp_tbl(i).comments;
      END IF;
    END LOOP;

    -- Component table must contain at least 1 row for Asset
    okl_aso_pvt.insert_row (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_asov_tbl      => l_component_tbl
                           ,x_asov_tbl      => lx_component_tbl );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    duplicate_asset_cashflows (
        p_api_version          => p_api_version
       ,p_init_msg_list        => p_init_msg_list
       ,p_transaction_control  => p_transaction_control
       ,p_source_object        => 'QUOTED_ASSET'
       ,p_source_id            => p_source_asset_id
       ,p_target_id            => lx_asset_rec.id
       ,p_quote_id             => lx_asset_rec.parent_object_id
       ,x_return_status        => x_return_status
       ,x_msg_count            => x_msg_count
       ,x_msg_data             => x_msg_data );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Estimated Property Tax Payment
    IF ((l_cashflow_level_tbl.COUNT > 0 AND l_cf_hdr_rec.stream_type_id IS NULL) OR
        (l_cf_hdr_rec.stream_type_id IS NOT NULL AND l_cashflow_level_tbl.COUNT = 0 )) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_EPT_PAYMENT_NA');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_cashflow_level_tbl.COUNT > 0 AND l_cf_hdr_rec.stream_type_id IS NOT NULL) THEN
      l_cf_hdr_rec.parent_object_id := lx_asset_rec.id;
      OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,p_transaction_control => 'T'
                           ,p_cashflow_header_rec => l_cf_hdr_rec
                           ,p_cashflow_level_tbl => l_cashflow_level_tbl
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_asset;

  -------------------------
  -- PROCEDURE create_asset
  -------------------------
  PROCEDURE create_asset (p_api_version             IN  NUMBER,
                          p_init_msg_list           IN  VARCHAR2,
                          p_transaction_control     IN  VARCHAR2,
                          p_asset_rec               IN  asset_rec_type,
                          p_component_tbl           IN  asset_component_tbl_type,
                          p_cf_hdr_rec              IN  cashflow_hdr_rec_type,
                          p_cf_level_tbl            IN  cashflow_level_tbl_type,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_asset';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;

    l_component_tbl        component_tbl_type;
    lx_component_tbl       component_tbl_type;

    l_asset_comp_tbl       asset_component_tbl_type;

    l_cf_hdr_rec           cashflow_hdr_rec_type;
    l_cashflow_level_tbl   cashflow_level_tbl_type;

    l_return_status        VARCHAR2(1);
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_asset_rec      := p_asset_rec;
    l_asset_comp_tbl := p_component_tbl;
    l_cf_hdr_rec     := p_cf_hdr_rec;
    l_cashflow_level_tbl := p_cf_level_tbl;

    -- Generate the Asset number from the sequence
    SELECT okl_qua_ref_seq.nextval INTO l_asset_rec.asset_number FROM DUAL;

    set_defaults (p_asset_rec     => l_asset_rec
                 ,p_component_tbl => l_asset_comp_tbl
                 ,x_return_status => l_return_status );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    validate (p_asset_rec     => l_asset_rec
             ,p_component_tbl => l_asset_comp_tbl
             ,x_return_status => l_return_status );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Assign EOT default value
    l_asset_rec.end_of_term_value_default := get_eot_default_value(
                	p_asset_rec      => l_asset_rec,
                    p_asset_comp_tbl => l_asset_comp_tbl,
                	x_return_status  => l_return_status);
    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- End

    okl_ass_pvt.insert_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec
                           ,x_assv_rec      => lx_asset_rec );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Update the Asset Components table with the created asset_id
    FOR i IN l_asset_comp_tbl.FIRST .. l_asset_comp_tbl.LAST LOOP
      IF l_asset_comp_tbl.EXISTS(i) THEN
        l_component_tbl(i).asset_id := lx_asset_rec.id;
        l_component_tbl(i).inv_item_id := l_asset_comp_tbl(i).inv_item_id;
        l_component_tbl(i).supplier_id := l_asset_comp_tbl(i).supplier_id;
        l_component_tbl(i).primary_component := l_asset_comp_tbl(i).primary_component;
        l_component_tbl(i).unit_cost := l_asset_comp_tbl(i).unit_cost;
        l_component_tbl(i).number_of_units := l_asset_comp_tbl(i).number_of_units;
        l_component_tbl(i).manufacturer_name := l_asset_comp_tbl(i).manufacturer_name;
        l_component_tbl(i).year_manufactured := l_asset_comp_tbl(i).year_manufactured;
        l_component_tbl(i).model_number := l_asset_comp_tbl(i).model_number;
        l_component_tbl(i).short_description := l_asset_comp_tbl(i).short_description;
        l_component_tbl(i).description := l_asset_comp_tbl(i).description;
        l_component_tbl(i).comments := l_asset_comp_tbl(i).comments;
      END IF;
    END LOOP;

    -- Component table must contain at least 1 row for Asset
    okl_aso_pvt.insert_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_asov_tbl      => l_component_tbl
                           ,x_asov_tbl      => lx_component_tbl );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Estimated Property Tax Payment
    IF ((l_cashflow_level_tbl.COUNT > 0 AND l_cf_hdr_rec.stream_type_id IS NULL) OR
        (l_cf_hdr_rec.stream_type_id IS NOT NULL AND l_cashflow_level_tbl.COUNT = 0 )) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_EPT_PAYMENT_NA');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_cf_hdr_rec.stream_type_id IS NOT NULL AND l_cashflow_level_tbl.COUNT > 0 ) THEN
      l_cf_hdr_rec.parent_object_id := lx_asset_rec.id;
      OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,p_transaction_control => 'T'
                           ,p_cashflow_header_rec => l_cf_hdr_rec
                           ,p_cashflow_level_tbl => l_cashflow_level_tbl
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

   /*SELECT parent_object_id,parent_object_code INTO l_p_id,l_p_code
   FROM okl_lease_quotes_b where ID = l_asset_rec.parent_object_id;

   OKL_LEASE_QUOTE_PRICING_PVT.handle_parent_object_status(
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

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_asset;


  -------------------------
  -- PROCEDURE delete_asset
  -------------------------
  PROCEDURE delete_asset (p_api_version             IN  NUMBER,
                          p_init_msg_list           IN  VARCHAR2,
                          p_transaction_control     IN  VARCHAR2,
                          p_asset_id                IN  NUMBER,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_asset';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_component_tbl        component_tbl_type;
    l_cashflow_object_rec  cf_object_rec_type;
    l_cashflow_hdr_rec     cf_header_rec_type;
    l_cashflow_level_tbl   cf_level_tbl_type;
    l_asset_rec            asset_rec_type;

    l_return_status        VARCHAR2(1);
    i                      BINARY_INTEGER := 0;
    l_asset_id             OKL_ASSETS_B.ID%TYPE;
    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);

    -- Cursors to check the existence of asset information
    CURSOR c_get_asset_components(p_asset_id OKL_ASSETS_B.ID%TYPE)
    IS
    SELECT ID
    FROM   OKL_ASSET_COMPONENTS_B
    WHERE  ASSET_ID = p_asset_id;

    CURSOR c_get_line_relationships(p_asset_id OKL_ASSETS_B.ID%TYPE)
    IS
    SELECT ID
    FROM   OKL_LINE_RELATIONSHIPS_B
    WHERE  SOURCE_LINE_ID = p_asset_id;

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_asset_id := p_asset_id;

    -- Asset primary component and addon information
    FOR l_asset_components IN c_get_asset_components(p_asset_id => l_asset_id) LOOP
      l_component_tbl(i).id := l_asset_components.id;
      i := i + 1;
    END LOOP;

    IF l_component_tbl.COUNT > 0 THEN
      okl_aso_pvt.delete_row (
                              p_api_version   => G_API_VERSION
                             ,p_init_msg_list => G_FALSE
                             ,x_return_status => l_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_asov_tbl      => l_component_tbl);
      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- End

    -- Cash Flow information
    okl_lease_quote_cashflow_pvt.delete_cashflows (
      p_api_version          => G_API_VERSION
     ,p_init_msg_list        => G_FALSE
     ,p_transaction_control  => G_FALSE
     ,p_source_object_code   => 'QUOTED_ASSET'
     ,p_source_object_id     => p_asset_id
     ,x_return_status        => l_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- End

    -- Delete Asset information
    l_asset_rec.id := l_asset_id;
    OKL_ASS_PVT.delete_row (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- End

   /*SELECT qte.parent_object_id,qte.parent_object_code
   INTO l_p_id,l_p_code
   FROM okl_lease_quotes_b qte,
        okl_assets_b ast
   WHERE ast.parent_object_id = qte.id
   AND   ast.ID = l_asset_id;

   OKL_LEASE_QUOTE_PRICING_PVT.handle_parent_object_status(
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


   x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_asset;

  -------------------------
  -- PROCEDURE update_asset
  -------------------------
  PROCEDURE update_asset (p_api_version             IN  NUMBER,
                          p_init_msg_list           IN  VARCHAR2,
                          p_transaction_control     IN  VARCHAR2,
                          p_asset_rec               IN  asset_rec_type,
                          p_component_tbl           IN  asset_component_tbl_type,
                          p_cf_hdr_rec              IN  cashflow_hdr_rec_type,
                          p_cf_level_tbl            IN  cashflow_level_tbl_type,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_asset';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_asset_rec            asset_rec_type;
    lx_asset_rec           asset_rec_type;
    l_copy_asset_rec       asset_rec_type;

    l_component_tbl        component_tbl_type;
    lx_component_tbl       component_tbl_type;
    l_deleted_addon_tbl    component_tbl_type;

    l_asset_comp_tbl       asset_component_tbl_type;
    l_copy_asset_comp_tbl  component_tbl_type;

    l_cf_hdr_rec           cashflow_hdr_rec_type;
    l_cashflow_level_tbl   cashflow_level_tbl_type;

    l_return_status        VARCHAR2(1);
    lv_cash_flow_exists    VARCHAR2(3);

    l_p_id                 NUMBER;
    l_p_code               VARCHAR2(30);

    CURSOR c_check_cash_flow(p_asset_id OKL_ASSETS_B.ID%TYPE)
    IS
    SELECT 'YES'
    FROM   OKL_CASH_FLOW_OBJECTS
    WHERE OTY_CODE = 'QUOTED_ASSET'
    AND   SOURCE_TABLE = 'OKL_ASSETS_B'
    AND   SOURCE_ID    = p_asset_id;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Check if the asset is modified through process other than asset ui
    IF (p_asset_rec.parent_object_code IS NULL OR
        p_asset_rec.object_version_number IS NULL) THEN

    -- Fetch Asset Info
    get_asset_rec ( p_asset_id       => p_asset_rec.id,
            x_asset_rec      => l_copy_asset_rec,
            x_return_status  => l_return_status );
      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Sync Asset Info
      sync_asset_values(x_asset_rec      => l_copy_asset_rec,
                        p_input_rec      => p_asset_rec,
                        x_return_status  => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_asset_rec := l_copy_asset_rec;

      -- Fetch Asset Components info
      IF (p_component_tbl.COUNT > 0) THEN
        get_asset_comp_tbl (p_asset_id       => p_asset_rec.id
                 ,x_asset_comp_tbl => l_copy_asset_comp_tbl
                 ,x_return_status  => l_return_status);
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Sync Asset Components Info
        sync_asset_comp_values(x_asset_comp_tbl      => l_copy_asset_comp_tbl,
                               p_input_comp_tbl      => p_component_tbl,
                               x_return_status     => l_return_status);
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        FOR i IN l_copy_asset_comp_tbl.FIRST .. l_copy_asset_comp_tbl.LAST LOOP
          IF l_copy_asset_comp_tbl.EXISTS(i) THEN
            l_asset_comp_tbl(i).id := l_copy_asset_comp_tbl(i).id;
            l_asset_comp_tbl(i).object_version_number := l_copy_asset_comp_tbl(i).object_version_number;
            l_asset_comp_tbl(i).asset_id := l_copy_asset_comp_tbl(i).asset_id;
            l_asset_comp_tbl(i).inv_item_id := l_copy_asset_comp_tbl(i).inv_item_id;
            l_asset_comp_tbl(i).supplier_id := l_copy_asset_comp_tbl(i).supplier_id;
            l_asset_comp_tbl(i).primary_component := l_copy_asset_comp_tbl(i).primary_component;
            l_asset_comp_tbl(i).unit_cost := l_copy_asset_comp_tbl(i).unit_cost;
            l_asset_comp_tbl(i).number_of_units := l_copy_asset_comp_tbl(i).number_of_units;
            l_asset_comp_tbl(i).manufacturer_name := l_copy_asset_comp_tbl(i).manufacturer_name;
            l_asset_comp_tbl(i).year_manufactured := l_copy_asset_comp_tbl(i).year_manufactured;
            l_asset_comp_tbl(i).model_number := l_copy_asset_comp_tbl(i).model_number;
            l_asset_comp_tbl(i).short_description := l_copy_asset_comp_tbl(i).short_description;
            l_asset_comp_tbl(i).description := l_copy_asset_comp_tbl(i).description;
            l_asset_comp_tbl(i).comments := l_copy_asset_comp_tbl(i).comments;
            l_asset_comp_tbl(i).record_mode := 'update';
          END IF;
        END LOOP;
      END IF;

    ELSE
    l_asset_rec := p_asset_rec;
    l_asset_comp_tbl := p_component_tbl;
    END IF;
    -- end

    l_cf_hdr_rec     := p_cf_hdr_rec;
    l_cashflow_level_tbl := p_cf_level_tbl;

    IF (l_asset_comp_tbl.COUNT > 0) THEN
      get_deleted_addons (p_asset_id          => l_asset_rec.id
                         ,p_component_tbl     => l_asset_comp_tbl
                         ,x_deleted_addon_tbl => l_deleted_addon_tbl
                         ,x_return_status     => l_return_status );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_deleted_addon_tbl.COUNT > 0 THEN
        okl_aso_pvt.delete_row (p_api_version   => G_API_VERSION
                               ,p_init_msg_list => G_FALSE
                               ,x_return_status => l_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_asov_tbl      => l_deleted_addon_tbl );

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      set_defaults (p_asset_rec     => l_asset_rec
                   ,p_component_tbl => l_asset_comp_tbl
                   ,x_return_status => l_return_status );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      validate (p_asset_rec     => l_asset_rec
               ,p_component_tbl => l_asset_comp_tbl
               ,x_return_status => l_return_status );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Assign EOT default value
      l_asset_rec.end_of_term_value_default := get_eot_default_value(
                p_asset_rec      => l_asset_rec,
                p_asset_comp_tbl => l_asset_comp_tbl,
                x_return_status  => l_return_status);
      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- End

    END IF;

    okl_ass_pvt.update_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_rec      => l_asset_rec
                           ,x_assv_rec      => lx_asset_rec );
    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_asset_comp_tbl.COUNT > 0) THEN
      -- Update or Create Add-ons basing on the record mode
      FOR i IN l_asset_comp_tbl.FIRST .. l_asset_comp_tbl.LAST LOOP
        IF l_asset_comp_tbl.EXISTS(i) THEN
          IF l_asset_comp_tbl(i).record_mode = 'create' THEN

            l_component_tbl(i).asset_id := l_asset_comp_tbl(i).asset_id;
            l_component_tbl(i).inv_item_id := l_asset_comp_tbl(i).inv_item_id;
            l_component_tbl(i).supplier_id := l_asset_comp_tbl(i).supplier_id;
            l_component_tbl(i).primary_component := l_asset_comp_tbl(i).primary_component;
            l_component_tbl(i).unit_cost := l_asset_comp_tbl(i).unit_cost;
            l_component_tbl(i).number_of_units := l_asset_comp_tbl(i).number_of_units;
            l_component_tbl(i).manufacturer_name := l_asset_comp_tbl(i).manufacturer_name;
            l_component_tbl(i).year_manufactured := l_asset_comp_tbl(i).year_manufactured;
            l_component_tbl(i).model_number := l_asset_comp_tbl(i).model_number;
            l_component_tbl(i).short_description := l_asset_comp_tbl(i).short_description;
            l_component_tbl(i).description := l_asset_comp_tbl(i).description;
            l_component_tbl(i).comments := l_asset_comp_tbl(i).comments;

            okl_aso_pvt.insert_row (  p_api_version   => G_API_VERSION
                                     ,p_init_msg_list => G_FALSE
                                     ,x_return_status => l_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,p_asov_rec      => l_component_tbl(i)
                                     ,x_asov_rec      => lx_component_tbl(i));
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
          ELSIF l_asset_comp_tbl(i).record_mode = 'update' THEN

            l_component_tbl(i).id := l_asset_comp_tbl(i).id;
            l_component_tbl(i).object_version_number := l_asset_comp_tbl(i).object_version_number;
            l_component_tbl(i).asset_id := l_asset_comp_tbl(i).asset_id;
            l_component_tbl(i).inv_item_id := l_asset_comp_tbl(i).inv_item_id;
            l_component_tbl(i).supplier_id := l_asset_comp_tbl(i).supplier_id;
            l_component_tbl(i).primary_component := l_asset_comp_tbl(i).primary_component;
            l_component_tbl(i).unit_cost := l_asset_comp_tbl(i).unit_cost;
            l_component_tbl(i).number_of_units := l_asset_comp_tbl(i).number_of_units;
            l_component_tbl(i).manufacturer_name := l_asset_comp_tbl(i).manufacturer_name;
            l_component_tbl(i).year_manufactured := l_asset_comp_tbl(i).year_manufactured;
            l_component_tbl(i).model_number := l_asset_comp_tbl(i).model_number;
            l_component_tbl(i).short_description := l_asset_comp_tbl(i).short_description;
            l_component_tbl(i).description := l_asset_comp_tbl(i).description;
            l_component_tbl(i).comments := l_asset_comp_tbl(i).comments;

            okl_aso_pvt.update_row (  p_api_version   => G_API_VERSION
                                     ,p_init_msg_list => G_FALSE
                                     ,x_return_status => l_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,p_asov_rec      => l_component_tbl(i)
                                     ,x_asov_rec      => lx_component_tbl(i));
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
          END IF;
        END IF;
      END LOOP;
    END IF;

    -- Estimated Property Tax Payment
    IF ((l_cashflow_level_tbl.COUNT > 0 AND l_cf_hdr_rec.stream_type_id IS NULL) OR
        (l_cf_hdr_rec.stream_type_id IS NOT NULL AND l_cashflow_level_tbl.COUNT = 0 )) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_EPT_PAYMENT_NA');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_cf_hdr_rec.stream_type_id IS NOT NULL AND l_cashflow_level_tbl.COUNT > 0 ) THEN
    -- Check if the Cash flows already exists
      OPEN  c_check_cash_flow(p_asset_id => lx_asset_rec.id);
      FETCH c_check_cash_flow into lv_cash_flow_exists;
      CLOSE c_check_cash_flow;

      l_cf_hdr_rec.parent_object_id := lx_asset_rec.id;
      IF (lv_cash_flow_exists = 'YES') THEN
        OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,p_transaction_control => 'T'
                           ,p_cashflow_header_rec => l_cf_hdr_rec
                           ,p_cashflow_level_tbl => l_cashflow_level_tbl
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data);

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
                            p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,p_transaction_control => 'T'
                           ,p_cashflow_header_rec => l_cf_hdr_rec
                           ,p_cashflow_level_tbl => l_cashflow_level_tbl
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data);

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;

   /*SELECT parent_object_id,parent_object_code INTO l_p_id,l_p_code
   FROM okl_lease_quotes_b where ID = l_asset_rec.parent_object_id;

   OKL_LEASE_QUOTE_PRICING_PVT.handle_parent_object_status(
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


    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_asset;

  -------------------------------------------
  -- PROCEDURE create_assets_with_adjustments
  -------------------------------------------
  PROCEDURE create_assets_with_adjustments (p_api_version             IN  NUMBER,
                                            p_init_msg_list           IN  VARCHAR2,
                                            p_transaction_control     IN  VARCHAR2,
                                            p_asset_tbl               IN  asset_tbl_type,
                                            p_component_tbl           IN  asset_component_tbl_type,
                                            p_asset_adj_tbl           IN  asset_adjustment_tbl_type,
                                            x_return_status           OUT NOCOPY VARCHAR2,
                                            x_msg_count               OUT NOCOPY NUMBER,
                                            x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_assets_adj';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_asset_tbl            asset_tbl_type;
    lx_asset_tbl           asset_tbl_type;

    l_component_tbl        component_tbl_type;
    lx_component_tbl       component_tbl_type;

    l_asset_comp_tbl       asset_component_tbl_type;

    l_asset_adj_tbl        asset_adjustment_tbl_type;
    l_adj_assets_tbl       asset_adj_tbl_type;
    lx_adj_assets_tbl      asset_adj_tbl_type;
    l_supplier_id          NUMBER := NULL;

    l_return_status        VARCHAR2(1);
    ln_index			   NUMBER;

    CURSOR c_get_supplier_id(p_qte_id IN OKL_LEASE_QUOTES_B.ID%TYPE) IS
    SELECT  LOP.SUPPLIER_ID  supplier_id
    FROM OKL_LEASE_OPPORTUNITIES_B LOP,
         OKL_LEASE_QUOTES_B QTE
    WHERE LOP.ID = QTE.parent_object_id
    AND  qte.id = p_qte_id;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_asset_tbl      := p_asset_tbl;
    l_asset_comp_tbl := p_component_tbl;
    l_asset_adj_tbl := p_asset_adj_tbl;

    okl_ass_pvt.insert_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_assv_tbl      => l_asset_tbl
                           ,x_assv_tbl      => lx_asset_tbl );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_asset_comp_tbl.EXISTS(l_asset_comp_tbl.FIRST) THEN
     FOR l_sup_rec IN c_get_supplier_id(l_asset_tbl(l_asset_tbl.FIRST).parent_object_id) LOOP
       l_supplier_id := l_sup_rec.supplier_id;
     END LOOP;
    END IF;
    -- Update the Asset Components table with the created asset_id
    FOR i IN l_asset_comp_tbl.FIRST .. l_asset_comp_tbl.LAST LOOP
      IF l_asset_comp_tbl.EXISTS(i) THEN
        l_component_tbl(i).asset_id := lx_asset_tbl(i).id;
        l_component_tbl(i).inv_item_id := l_asset_comp_tbl(i).inv_item_id;
        l_component_tbl(i).supplier_id := l_asset_comp_tbl(i).supplier_id;
        l_component_tbl(i).primary_component := l_asset_comp_tbl(i).primary_component;
        l_component_tbl(i).unit_cost := l_asset_comp_tbl(i).unit_cost;
        l_component_tbl(i).number_of_units := l_asset_comp_tbl(i).number_of_units;
        l_component_tbl(i).manufacturer_name := l_asset_comp_tbl(i).manufacturer_name;
        l_component_tbl(i).year_manufactured := l_asset_comp_tbl(i).year_manufactured;
        l_component_tbl(i).model_number := l_asset_comp_tbl(i).model_number;
        l_component_tbl(i).short_description := l_asset_comp_tbl(i).short_description;
        l_component_tbl(i).description := l_asset_comp_tbl(i).description;
        l_component_tbl(i).comments := l_asset_comp_tbl(i).comments;
        l_component_tbl(i).supplier_id := l_supplier_id;
      END IF;
    END LOOP;

    -- Component table must contain at least 1 row for Asset
    okl_aso_pvt.insert_row (p_api_version   => G_API_VERSION
                           ,p_init_msg_list => G_FALSE
                           ,x_return_status => l_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_asov_tbl      => l_component_tbl
                           ,x_asov_tbl      => lx_component_tbl );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_asset_adj_tbl.COUNT > 0 THEN
      FOR i IN l_asset_adj_tbl.FIRST .. l_asset_adj_tbl.LAST LOOP
        IF l_asset_adj_tbl.EXISTS(i) THEN
           --asawanka bug 5025239 fix starts
          IF (l_asset_adj_tbl(i).value IS NOT NULL AND l_asset_adj_tbl(i).value < 0) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_ADJ_AMOUNT_NEGATIVE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --asawanka bug 5025239 fix ends
          l_adj_assets_tbl(i).parent_object_code := l_asset_adj_tbl(i).parent_object_code;
          l_adj_assets_tbl(i).parent_object_id := l_asset_adj_tbl(i).parent_object_id;
          l_adj_assets_tbl(i).adjustment_source_type := l_asset_adj_tbl(i).adjustment_source_type;
          l_adj_assets_tbl(i).adjustment_source_id := l_asset_adj_tbl(i).adjustment_source_id;
          l_adj_assets_tbl(i).basis := l_asset_adj_tbl(i).basis;
          l_adj_assets_tbl(i).value := l_asset_adj_tbl(i).value;
          l_adj_assets_tbl(i).default_subsidy_amount := l_asset_adj_tbl(i).default_subsidy_amount;
          l_adj_assets_tbl(i).processing_type := l_asset_adj_tbl(i).processing_type;
          l_adj_assets_tbl(i).supplier_id := l_asset_adj_tbl(i).supplier_id;
          --bug # 5142940 ssdeshpa start
          l_adj_assets_tbl(i).stream_type_id := l_asset_adj_tbl(i).stream_type_id;
          --bug # 5142940 ssdeshpa end
          l_adj_assets_tbl(i).short_description := l_asset_adj_tbl(i).short_description;
          l_adj_assets_tbl(i).description := l_asset_adj_tbl(i).description;
          l_adj_assets_tbl(i).comments := l_asset_adj_tbl(i).comments;
          l_adj_assets_tbl(i).percent_basis_value := l_asset_adj_tbl(i).percent_basis_value;
        END IF;
      END LOOP;


      -- Validate Subsidy Usage
      ln_index := l_adj_assets_tbl.FIRST;

      IF (l_adj_assets_tbl(ln_index).adjustment_source_type = 'SUBSIDY') THEN
        validate_subsidy_usage(p_asset_id         =>  l_adj_assets_tbl(ln_index).parent_object_id,
 				       		   p_input_adj_tbl    =>  l_adj_assets_tbl,
                               x_return_status    =>  x_return_status);
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      okl_cdj_pvt.insert_row (p_api_version   => G_API_VERSION
                             ,p_init_msg_list => G_FALSE
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_cdjv_tbl      => l_adj_assets_tbl
                             ,x_cdjv_tbl      => lx_adj_assets_tbl );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --Bug # 5142940 ssdeshpa start
    --Insert Cash flows for Adjustment for Type 'DOWN_APYMENT'
    l_adj_assets_tbl := lx_adj_assets_tbl;
    IF (l_adj_assets_tbl.COUNT > 0) THEN
     FOR i IN l_adj_assets_tbl.FIRST .. l_adj_assets_tbl.LAST LOOP
        IF l_adj_assets_tbl.EXISTS(i) THEN
           IF(l_adj_assets_tbl(i).adjustment_source_type='DOWN_PAYMENT' AND
              l_adj_assets_tbl(i).processing_type='BILL' AND
              l_adj_assets_tbl(i).stream_type_id IS NOT NULL) THEN
              --Create Rec Structure for Cash flows
              process_adj_cashflows(p_cdjv_rec  => l_adj_assets_tbl(i)
                                   ,p_event_mode    => 'create'
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data
                                   ,x_return_status => x_return_status);

              IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;
        END IF;
     END LOOP;
    END IF;
   --Bug # 5142940 ssdeshpa end

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

  END create_assets_with_adjustments;

--veramach bug 6622178 start
----------------------------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       veramach
    -- Procedure Name:  calculate_subsidy_amount
    -- Description:  returns the subsidy amount for given asset on a lease sales quote when subsidy calculation
    --               basis is Financed Amount
    -- Dependencies:
    -- Parameters: p_asset_id - the asset id for which to calculate subsidy amount
    -- Parameters: p_subsidy_id - the subsidy id
    -- Version: 1.0
    -- End of Commnets
----------------------------------------------------------------------------------------------------
 PROCEDURE calculate_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_id                     IN  NUMBER,
    p_subsidy_id                   IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    CURSOR sub_dtls_csr IS
    Select   PERCENT, MAXIMUM_FINANCED_AMOUNT, MAXIMUM_SUBSIDY_AMOUNT
    FROM     okl_subsidies_b
    WHERE id = p_subsidy_id;

   sub_dtls_rec               sub_dtls_csr%ROWTYPE;
   l_prog_name                VARCHAR2(61) := 'OKL_LEASE_QUOTE_ASSET_PVT.calculate_subsidy_amount';
   l_additional_parameters    OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;
   l_financed_amount          NUMBER;
   l_subsidy_amount           NUMBER;

BEGIN

    IF p_asset_id IS NULL THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_additional_parameters(1).name  := 'ASSET_ID';
    l_additional_parameters(1).value := p_asset_id;
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
					    p_init_msg_list => p_init_msg_list,
					    x_return_status => x_return_status,
					    x_msg_count     => x_msg_count,
					    x_msg_data      => x_msg_data,
					    p_formula_name  => 'FRONT_END_FINANCED_AMOUNT',
					    p_contract_id   => null,
					    p_line_id       => null,
					    p_additional_parameters  => l_additional_parameters,
					    x_value         => l_financed_amount);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	     RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OPEN  sub_dtls_csr;
     FETCH sub_dtls_csr into sub_dtls_rec;
     CLOSE sub_dtls_csr;

     IF (sub_dtls_rec.MAXIMUM_FINANCED_AMOUNT IS NOT NULL) THEN
       IF (l_financed_amount > sub_dtls_rec.MAXIMUM_FINANCED_AMOUNT) THEN
           l_financed_amount := sub_dtls_rec.MAXIMUM_FINANCED_AMOUNT;
       END IF;
     END IF;

     l_subsidy_amount :=   l_financed_amount * (sub_dtls_rec.PERCENT/100);

     IF (sub_dtls_rec.MAXIMUM_SUBSIDY_AMOUNT IS NOT NULL) THEN
       IF (l_subsidy_amount > sub_dtls_rec.MAXIMUM_SUBSIDY_AMOUNT) THEN
           l_subsidy_amount := sub_dtls_rec.MAXIMUM_SUBSIDY_AMOUNT;
       END IF;
     END IF;

     x_subsidy_amount := l_subsidy_amount;

 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
        OKL_API.SET_MESSAGE (p_app_name     => 'OKL',
                             p_msg_name     => 'OKL_DB_ERROR',
                             p_token1       => 'PROG_NAME',
                             p_token1_value => l_prog_name,
                             p_token2       => 'SQLCODE',
                             p_token2_value => sqlcode,
                             p_token3       => 'SQLERRM',
                             p_token3_value => sqlerrm);

        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END calculate_subsidy_amount;
 --veramach bug 6622178 end

END OKL_LEASE_QUOTE_ASSET_PVT;

/
