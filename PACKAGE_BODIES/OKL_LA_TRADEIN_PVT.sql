--------------------------------------------------------
--  DDL for Package Body OKL_LA_TRADEIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_TRADEIN_PVT" as
 /* $Header: OKLRTRIB.pls 120.3 2006/09/11 23:21:42 smereddy noship $ */

 --Bug# 5102606
 G_FORMULA_CAP       CONSTANT VARCHAR2(200)  := 'LINE_CAP_AMNT';

 FUNCTION GET_AK_PROMPT(p_ak_region	IN VARCHAR2, p_ak_attribute	IN VARCHAR2)
 RETURN VARCHAR2 IS

  	CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS
	SELECT a.attribute_label_long
	FROM ak_region_items ri, AK_REGIONS r, AK_ATTRIBUTES_vL a
	WHERE ri.region_code = r.region_code
	AND ri.attribute_code = a.attribute_code
	AND ri.region_code  =  p_ak_region
	AND ri.attribute_code = p_ak_attribute;

  	l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
 BEGIN
  	OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
  	FETCH ak_prompt_csr INTO l_ak_prompt;
  	CLOSE ak_prompt_csr;
  	return(l_ak_prompt);
 END;

  PROCEDURE delete_quote_lines (p_api_version           IN         NUMBER,
                                p_init_msg_list         IN         VARCHAR2 DEFAULT G_FALSE,
                                p_transaction_control   IN         VARCHAR2 DEFAULT G_TRUE,
                                p_cle_id_tbl            IN         cle_id_tbl_type,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'delete_quote_lines';
    lx_return_status    VARCHAR2(1);

    l_chr_id            NUMBER;
    line_number         NUMBER;
  -- cursor to retrieve the chr_id( contract id) to set the org
  CURSOR find_chr_id_csr(p_line_id NUMBER) IS
    SELECT dnz_chr_id chr_id
    FROM okc_k_lines_b
    WHERE id = p_line_id;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- pass the quote line id (service, fee, covered assets) to delete the line
    IF(p_cle_id_tbl.COUNT > 0) THEN

       line_number := p_cle_id_tbl.FIRST;

        -- Retrieve the chr_id
        FOR l_chr_id_csr_rec IN find_chr_id_csr(p_line_id =>  p_cle_id_tbl(line_number).cle_id)
        LOOP
            l_chr_id    :=  l_chr_id_csr_rec.chr_id;
        END LOOP;
        -- set the org context
        OKL_CONTEXT.set_okc_org_context(p_chr_id  => l_chr_id );
        -- run the loop
       LOOP

            okl_contract_pvt.delete_contract_line(p_api_version   => G_API_VERSION,
                                                  p_init_msg_list => G_FALSE,
                                                  x_return_status => lx_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_line_id       => p_cle_id_tbl(line_number).cle_id);

             IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

            EXIT WHEN (line_number = p_cle_id_tbl.LAST);
                    line_number := p_cle_id_tbl.NEXT(line_number);
       END LOOP;

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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;


  END delete_quote_lines;


  PROCEDURE create_update_link_assets (p_cle_id             IN         NUMBER,
                                       p_chr_id             IN         NUMBER,
                                       p_capitalize_yn      IN         VARCHAR2,
                                       p_link_asset_tbl     IN  link_asset_tbl_type,
                                       p_derive_assoc_amt   IN  VARCHAR2,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_msg_count          OUT NOCOPY NUMBER,
                                       x_msg_data           OUT NOCOPY VARCHAR2) IS

    l_program_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'create_update_link_assets';

    l_create_line_item_tbl      okl_contract_line_item_pvt.line_item_tbl_type;
    l_update_line_item_tbl      okl_contract_line_item_pvt.line_item_tbl_type;
    lx_line_item_tbl            okl_contract_line_item_pvt.line_item_tbl_type;

    l_link_asset_tbl            link_asset_tbl_type;

    k                           BINARY_INTEGER  := 1;  -- create table index
    m                           BINARY_INTEGER  := 1;  -- update table index

    l_line_amount               NUMBER;
    l_asset_oec                 NUMBER;
    l_oec_total                 NUMBER       := 0;
    l_assoc_amount              NUMBER;
    l_assoc_total               NUMBER       := 0;
    l_currency_code             VARCHAR2(15);
    l_compare_amt               NUMBER;
    l_diff                      NUMBER;
    l_adj_rec                   BINARY_INTEGER;
    lx_return_status            VARCHAR2(1);

  BEGIN

    SELECT NVL(amount, 0)
    INTO   l_line_amount
    FROM   okl_k_lines
    WHERE  id = p_cle_id;

    SELECT currency_code
    INTO   l_currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_link_asset_tbl  :=  p_link_asset_tbl;

    IF (l_link_asset_tbl.COUNT > 0) THEN

      ------------------------------------------------------------------
      -- 1. Loop through to get OEC total of all assets being associated
      ------------------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          SELECT NVL(oec, 0)
          INTO   l_asset_oec
          FROM   okl_k_lines
          WHERE  id = l_link_asset_tbl(i).fin_asset_id;

          l_oec_total := l_oec_total + l_asset_oec;

        END IF;

      END LOOP;

      ----------------------------------------------------------------------------
      -- 2. Loop through to determine associated amounts and round off the amounts
      ----------------------------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          IF p_derive_assoc_amt = 'N' THEN

            l_assoc_amount := l_link_asset_tbl(i).amount;

          ELSIF l_oec_total = 0 THEN

            l_assoc_amount := l_line_amount / l_link_asset_tbl.COUNT;

          ELSE

            -- LLA APIs ensure asset OEC and line amount are rounded

            SELECT NVL(oec, 0)
            INTO   l_asset_oec
            FROM   okl_k_lines
            WHERE  id = l_link_asset_tbl(i).fin_asset_id;

            IF l_link_asset_tbl.COUNT = 1 THEN

              l_assoc_amount := l_line_amount;

            ELSE

              l_assoc_amount := l_line_amount * l_asset_oec / l_oec_total;

            END IF;
          END IF;

          l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                             p_currency_code => l_currency_code);

          l_assoc_total := l_assoc_total + l_assoc_amount;

          l_link_asset_tbl(i).amount := l_assoc_amount;
        END IF;

      END LOOP;

      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_assoc_total <> l_line_amount THEN

        l_diff := ABS(l_assoc_total - l_line_amount);

        FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

          IF l_link_asset_tbl.EXISTS(i) THEN

            -- if the total split amount is less than line amount add the difference amount to the
            -- asset with less amount and if the total split amount is greater than the line amount
            -- than subtract the difference amount from the asset with highest amount

            IF i = l_link_asset_tbl.FIRST THEN

              l_adj_rec     := i; -- Bug#3404844
              l_compare_amt := l_link_asset_tbl(i).amount;

            ELSIF (l_assoc_total < l_line_amount) AND (l_link_asset_tbl(i).amount <= l_compare_amt) OR
                  (l_assoc_total > l_line_amount) AND (l_link_asset_tbl(i).amount >= l_compare_amt) THEN

                l_adj_rec     := i;
                l_compare_amt := l_link_asset_tbl(i).amount;

            END IF;

          END IF;

        END LOOP;

        IF l_assoc_total < l_line_amount THEN

          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount + l_diff;

        ELSE

          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount - l_diff;

        END IF;

      END IF;

      ------------------------------------------------------
      -- 4. Prepare arrays to pass to create and update APIs
      ------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          l_assoc_amount := l_link_asset_tbl(i).amount;

          IF l_link_asset_tbl(i).link_line_id IS NULL THEN

            l_create_line_item_tbl(k).chr_id            := p_chr_id;
            l_create_line_item_tbl(k).parent_cle_id     := p_cle_id;
            l_create_line_item_tbl(k).item_id1          := l_link_asset_tbl(i).fin_asset_id;
            l_create_line_item_tbl(k).item_id2          := '#';
            l_create_line_item_tbl(k).item_object1_code := 'OKX_COVASST';
            l_create_line_item_tbl(k).serv_cov_prd_id   := NULL;

            -- The linked amount is always passed in as 'capital_amount' even though capital amount
            -- is applicable only for CAPITALIZED fee types.  The LLA API will ensure that
            -- the linked amount is stored in the appropriate column (AMOUNT vs CAPITAL_AMOUNT)
            l_create_line_item_tbl(k).capital_amount := l_assoc_amount;

            SELECT txl.asset_number
            INTO   l_create_line_item_tbl(k).name
            FROM   okc_k_lines_b cle,
                   okc_line_styles_b lse,
                   okl_txl_assets_b txl
            WHERE  cle.id = txl.kle_id
            AND    cle.lse_id = lse.id
            AND    lse.lty_code = 'FIXED_ASSET'
            AND    cle.cle_id = l_link_asset_tbl(i).fin_asset_id;

            k := k + 1;

          ELSE

            l_update_line_item_tbl(m).cle_id            := l_link_asset_tbl(i).link_line_id;
            l_update_line_item_tbl(m).item_id           := l_link_asset_tbl(i).link_item_id;
            l_update_line_item_tbl(m).chr_id            := p_chr_id;
            l_update_line_item_tbl(m).parent_cle_id     := p_cle_id;
            l_update_line_item_tbl(m).item_id1          := l_link_asset_tbl(i).fin_asset_id;
            l_update_line_item_tbl(m).item_id2          := '#';
            l_update_line_item_tbl(m).item_object1_code := 'OKX_COVASST';
            l_update_line_item_tbl(m).serv_cov_prd_id   := NULL;

            -- The linked amount is always passed in as 'capital_amount' even though capital amount
            -- is applicable only for CAPITALIZED fee types.  The LLA API will ensure that
            -- the linked amount is stored in the appropriate column (AMOUNT vs CAPITAL_AMOUNT)
            l_update_line_item_tbl(m).capital_amount := l_assoc_amount;

            SELECT txl.asset_number
            INTO   l_update_line_item_tbl(m).name
            FROM   okc_k_lines_b cle,
                   okc_line_styles_b lse,
                   okl_txl_assets_b txl
            WHERE  cle.id = txl.kle_id
            AND    cle.lse_id = lse.id
            AND    lse.lty_code = 'FIXED_ASSET'
            AND    cle.cle_id = l_link_asset_tbl(i).fin_asset_id;

            m := m + 1;

          END IF;

        END IF;

      END LOOP;

      IF l_create_line_item_tbl.COUNT > 0 THEN

        okl_contract_line_item_pvt.create_contract_line_item( p_api_version        => G_API_VERSION,
                                                              p_init_msg_list      => G_FALSE,
                                                              x_return_status      => lx_return_status,
                                                              x_msg_count          => x_msg_count,
                                                              x_msg_data           => x_msg_data,
                                                              p_line_item_tbl      => l_create_line_item_tbl,
                                                              x_line_item_tbl      => lx_line_item_tbl);

        IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

      IF l_update_line_item_tbl.COUNT > 0 THEN

        okl_contract_line_item_pvt.update_contract_line_item( p_api_version        => G_API_VERSION,
                                                              p_init_msg_list      => G_FALSE,
                                                              x_return_status      => lx_return_status,
                                                              x_msg_count          => x_msg_count,
                                                              x_msg_data           => x_msg_data,
                                                              p_line_item_tbl      => l_update_line_item_tbl,
                                                              x_line_item_tbl      => lx_line_item_tbl);

        IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
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

  END create_update_link_assets;



  PROCEDURE allocate_amount1(p_api_version         IN         NUMBER,
                            p_init_msg_list       IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            p_transaction_control IN         VARCHAR2 DEFAULT OKC_API.G_TRUE,
                            p_cle_id              IN         NUMBER,
                            p_chr_id              IN         NUMBER,
                            p_capitalize_yn       IN         VARCHAR2,
                            x_cle_id              OUT NOCOPY NUMBER,
                            x_chr_id              OUT NOCOPY NUMBER,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'allocate_amount';

    CURSOR c_sublines IS
      SELECT cle.id
      FROM   okc_k_lines_b cle,
             okc_line_styles_b lse
      WHERE  cle.cle_id = p_cle_id
      AND    cle.lse_id = lse.id
      AND    lse.lty_code = 'LINK_FEE_ASSET';

    CURSOR c_assets IS
    SELECT cle.cle_id fin_asset_id,
           txl.asset_number
    FROM   okl_txl_assets_b txl,
           okc_k_lines_b cle,
           okc_line_styles_b lse
    WHERE  cle.dnz_chr_id = p_chr_id
      AND  cle.id = txl.kle_id
      AND  cle.lse_id = lse.id
      AND  lse.lty_code = 'FIXED_ASSET'
      AND  cle.sts_code <> 'ABANDONED';

    l_link_asset_tbl        link_asset_tbl_type;
    l_cle_id_tbl            cle_id_tbl_type;

    i                       BINARY_INTEGER;

    lx_return_status        VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    i := 0;

    FOR l_subline IN c_sublines LOOP

      i := i + 1;

      l_cle_id_tbl(i).cle_id := l_subline.id;

    END LOOP;

    IF l_cle_id_tbl.COUNT > 0 THEN

      delete_quote_lines (p_api_version           => G_API_VERSION,
                          p_init_msg_list         => G_FALSE,
                          p_transaction_control   => G_TRUE,
                          p_cle_id_tbl            => l_cle_id_tbl,
                          x_return_status         => lx_return_status,
                          x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data);

      IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    i := 0;

    FOR l_asset IN c_assets LOOP

      i := i + 1;

      l_link_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
      l_link_asset_tbl(i).asset_number := l_asset.asset_number;

    END LOOP;

    IF l_link_asset_tbl.COUNT > 0 THEN

      create_update_link_assets (p_cle_id             => p_cle_id,
                                 p_chr_id             => p_chr_id,
                                 p_capitalize_yn      => p_capitalize_yn,
                                 p_link_asset_tbl     => l_link_asset_tbl,
                                 p_derive_assoc_amt   => 'Y',
                                 x_return_status      => lx_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data);

      IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = G_RET_STS_ERROR THEN
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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END allocate_amount1;


 PROCEDURE update_contract(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_date           IN  okl_k_headers.date_tradein%TYPE,
            p_tradein_amount         IN  okl_k_headers.tradein_amount%TYPE,
            p_tradein_desc           IN  okl_k_headers.tradein_description%TYPE
 )IS

    lp_chrv_rec  okl_okc_migration_pvt.chrv_rec_type;
    lp_khrv_rec  okl_khr_pvt.khrv_rec_type;

    lx_chrv_rec  okl_okc_migration_pvt.chrv_rec_type;
    lx_khrv_rec  okl_khr_pvt.khrv_rec_type;

    l_chr_id            okc_k_headers_b.id%type := p_chr_id;
    l_tradein_date      okl_k_headers.date_tradein%TYPE := p_tradein_date;
    l_tradein_amount    okl_k_headers.tradein_amount%TYPE := p_tradein_amount;
    l_tradein_desc      okl_k_headers.tradein_description%TYPE := p_tradein_desc;

    l_api_name	     CONSTANT VARCHAR2(30) := 'update_contract';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;

  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If(l_chr_id is null or l_chr_id = OKL_API.G_MISS_NUM) Then
     x_return_status := OKC_API.g_ret_sts_error;
     OKC_API.SET_MESSAGE(      p_app_name => g_app_name
        			, p_msg_name => 'OKL_REQUIRED_VALUE'
     				, p_token1 => 'COL_NAME'
     				, p_token1_value => 'DNZ_CHR_ID'
     			   );
     raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If(l_tradein_date is null or l_tradein_date = OKL_API.G_MISS_DATE) Then
     x_return_status := OKC_API.g_ret_sts_error;
     l_ak_prompt := GET_AK_PROMPT('OKL_LA_AST_DTLS', 'OKL_TRADEIN_DATE');
     OKC_API.SET_MESSAGE(      p_app_name => g_app_name
        			, p_msg_name => 'OKL_REQUIRED_VALUE'
     				, p_token1 => 'COL_NAME'
     				, p_token1_value => l_ak_prompt
     			   );
     raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If(l_tradein_amount is null or l_tradein_amount = OKL_API.G_MISS_NUM) Then
     x_return_status := OKC_API.g_ret_sts_error;
     l_ak_prompt := GET_AK_PROMPT('OKL_LA_AST_DTLS', 'OKL_TRADEIN_AMOUNT');
     OKC_API.SET_MESSAGE(      p_app_name => g_app_name
        			, p_msg_name => 'OKL_REQUIRED_VALUE'
     				, p_token1 => 'COL_NAME'
     				, p_token1_value => l_ak_prompt
     			   );
     raise OKC_API.G_EXCEPTION_ERROR;
   End If;


   If okl_context.get_okc_org_id  is null then
      okl_context.set_okc_org_context(p_chr_id => l_chr_id );
   End If;

   lp_chrv_rec.id := l_chr_id;
   lp_khrv_rec.id := l_chr_id;
   lp_khrv_rec.date_tradein := l_tradein_date;
   lp_khrv_rec.tradein_amount := l_tradein_amount;
   lp_khrv_rec.tradein_description := l_tradein_desc;

   OKL_CONTRACT_PUB.update_contract_header(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_restricted_update     => 'F',
        p_chrv_rec       	=> lp_chrv_rec,
        p_khrv_rec       	=> lp_khrv_rec,
        x_chrv_rec       	=> lx_chrv_rec,
        x_khrv_rec       	=> lx_khrv_rec);

   IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;

   x_return_status := OKC_API.g_ret_sts_success;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

--Bug# 5102606
--------------------------------------------------------------------------------
--Name       : recalculate_costs
--Creation   : 17-Mar-2006
--Purpose    : Local procedure to update capital_amount when trade-in is updated
--------------------------------------------------------------------------------
  PROCEDURE recalculate_costs(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  OKL_K_HEADERS.id%TYPE,
            p_cle_id               IN  OKL_K_LINES.id%TYPE
  )IS

    l_cap_amount     NUMBER;

    l_clev_rec       OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_klev_rec       OKL_CONTRACT_PUB.klev_rec_type;
    lx_clev_rec      OKL_OKC_MIGRATION_PVT.clev_rec_type;
    lx_klev_rec      OKL_CONTRACT_PUB.klev_rec_type;

    l_api_name       CONSTANT VARCHAR2(30) := 'RECALCULATE_COSTS';
    l_api_version    CONSTANT NUMBER	  := 1.0;

  BEGIN

    x_return_status := OKL_API.g_ret_sts_success;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name,
        p_pkg_name      => g_pkg_name,
        p_init_msg_list => p_init_msg_list,
        l_api_version   => l_api_version,
        p_api_version   => p_api_version,
        p_api_type      => g_api_type,
        x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_cap_amount := 0;
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_CAP,
                                    p_contract_id   => p_chr_id,
                                    p_line_id       => p_cle_id,
                                    x_value         => l_cap_amount);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---------------------------------------------------------------------
    -- call api to update costs on asset line
    ---------------------------------------------------------------------
    l_clev_rec.id                    := p_cle_id;
    l_klev_rec.id                    := p_cle_id;
    l_klev_rec.capital_amount        := l_cap_amount;

    okl_contract_pub.update_contract_line
         (p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_rec      => l_clev_rec,
          p_klev_rec      => l_klev_rec,
          x_clev_rec      => lx_clev_rec,
          x_klev_rec      => lx_klev_rec
          );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Recalculate Asset depreciation cost when there
    -- is a change to Trade-in during On-line Rebook
    okl_activate_asset_pvt.recalculate_asset_cost
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_chr_id        => p_chr_id,
         p_cle_id        => p_cle_id
         );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

 END recalculate_costs;
 --Bug# 5102606

 PROCEDURE create_tradein(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_rec            IN  tradein_rec_type,
            x_tradein_rec            OUT NOCOPY tradein_rec_type
 )IS

    lp_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type := p_tradein_rec;
    lx_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type;

    lp_klev_rec  okl_kle_pvt.klev_rec_type;
    lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lx_klev_rec  okl_kle_pvt.klev_rec_type;
    lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    l_chr_id            okc_k_headers_b.id%type := p_chr_id;

    l_api_name	     CONSTANT VARCHAR2(30) := 'create_tradein';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;

  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If( lp_tradein_rec.asset_id  is null) Then
     -- program error
     x_return_status := OKC_API.g_ret_sts_error;
     OKC_API.SET_MESSAGE(      p_app_name => g_app_name
         		     , p_msg_name => 'PROGRAM_ERROR_ASSET_ID'
      			   );
    raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  -- on update of a asset line, reset the tradein_amount value to null
  If ( (lp_tradein_rec.id is not null and lp_tradein_rec.id <> OKL_API.G_MISS_NUM)
        and (lp_tradein_rec.id <> lp_tradein_rec.asset_id)) Then

     lp_clev_rec.id := lp_tradein_rec.id;
     lp_klev_rec.id := lp_tradein_rec.id;
     lp_klev_rec.tradein_amount := null;

     okl_contract_pvt.update_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_rec      => lp_clev_rec,
          p_klev_rec      => lp_klev_rec,
          x_clev_rec      => lx_clev_rec,
          x_klev_rec      => lx_klev_rec);


   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   --Bug# 5102606
   recalculate_costs(
       p_api_version   => p_api_version,
       p_init_msg_list => p_init_msg_list,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_chr_id        => p_chr_id,
       p_cle_id        => lp_clev_rec.id);

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;
   --Bug# 5102606

  End If;

  lp_clev_rec.id := lp_tradein_rec.asset_id;
  lp_klev_rec.id := lp_tradein_rec.asset_id;
  lp_klev_rec.tradein_amount := lp_tradein_rec.tradein_amount;

  okl_contract_pvt.update_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_rec      => lp_clev_rec,
          p_klev_rec      => lp_klev_rec,
          x_clev_rec      => lx_clev_rec,
          x_klev_rec      => lx_klev_rec);


  If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  --Bug# 5102606
  recalculate_costs(
       p_api_version   => p_api_version,
       p_init_msg_list => p_init_msg_list,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_chr_id        => p_chr_id,
       p_cle_id        => lp_clev_rec.id);

  If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
  End If;
  --Bug# 5102606

  x_tradein_rec.id := lx_clev_rec.id;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

 PROCEDURE create_tradein(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_tbl            IN  tradein_tbl_type,
            x_tradein_tbl            OUT NOCOPY tradein_tbl_type
 )IS

    lp_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type;
    lx_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lp_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lp_klev_tbl OKL_KLE_PVT.klev_tbl_type;

    lx_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lx_klev_tbl OKL_KLE_PVT.klev_tbl_type;

    l_chr_id     okc_k_headers_b.id%type := p_chr_id;

    l_api_name	     CONSTANT VARCHAR2(30) := 'create_tradein';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;
    i number := 0;


  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If okl_context.get_okc_org_id  is null then
      okl_context.set_okc_org_context(p_chr_id => l_chr_id );
   End If;

   If (p_tradein_tbl.COUNT > 0) Then

       i := p_tradein_tbl.FIRST;

       LOOP

            lp_tradein_rec.id := p_tradein_tbl(i).id;
            lp_tradein_rec.asset_id := p_tradein_tbl(i).asset_id;
            lp_tradein_rec.asset_number := p_tradein_tbl(i).asset_number;
            lp_tradein_rec.tradein_amount := p_tradein_tbl(i).tradein_amount;
/*
 	    If( (lp_tradein_rec.asset_number  is null or lp_tradein_rec.asset_number = OKL_API.G_MISS_CHAR)
 	        and  (lp_tradein_rec.tradein_amount is null or lp_tradein_rec.tradein_amount = OKL_API.G_MISS_NUM) ) Then
 	         break;
            End If;

 	    If( (lp_tradein_rec.asset_number  is null or lp_tradein_rec.asset_number = OKL_API.G_MISS_CHAR)
 	        and  (lp_tradein_rec.tradein_amount is not null and lp_tradein_rec.tradein_amount != OKL_API.G_MISS_NUM) ) Then
         	x_return_status := OKC_API.g_ret_sts_error;
	    	OKC_API.SET_MESSAGE(   p_app_name => g_app_name
	    	       		     , p_msg_name => 'OKL_LLA_ASSET_REQUIRED'
	          			   );
	    	raise OKC_API.G_EXCEPTION_ERROR;
            End If;

 	    If( (lp_tradein_rec.asset_number  is not null and lp_tradein_rec.asset_number != OKL_API.G_MISS_CHAR)
 	        and  (lp_tradein_rec.tradein_amount is null or lp_tradein_rec.tradein_amount = OKL_API.G_MISS_NUM) ) Then
         	x_return_status := OKC_API.g_ret_sts_error;
	    	OKC_API.SET_MESSAGE(   p_app_name => g_app_name
	    	       		     , p_msg_name => 'OKL_AMOUNT_FORMAT'
	          			   );
	    	raise OKC_API.G_EXCEPTION_ERROR;
            End If;
*/
            create_tradein(
	    	p_api_version		=> p_api_version,
	    	p_init_msg_list		=> p_init_msg_list,
	    	x_return_status 	=> x_return_status,
	    	x_msg_count     	=> x_msg_count,
	    	x_msg_data      	=> x_msg_data,
	    	p_chr_id                => l_chr_id,
	    	p_tradein_rec		=> lp_tradein_rec,
	    	x_tradein_rec		=> lx_tradein_rec);

            If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
         	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	    	  raise OKC_API.G_EXCEPTION_ERROR;
            End If;

       EXIT WHEN (i = p_tradein_tbl.LAST);
          i := p_tradein_tbl.NEXT(i);
       END LOOP;

   End If;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;


 PROCEDURE delete_tradein(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_rec            IN  tradein_rec_type,
            x_tradein_rec            OUT NOCOPY tradein_rec_type
 )IS

    lp_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type := p_tradein_rec;
    lx_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type;

    lp_klev_rec  okl_kle_pvt.klev_rec_type;
    lp_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    lx_klev_rec  okl_kle_pvt.klev_rec_type;
    lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;

    l_chr_id            okc_k_headers_b.id%type := p_chr_id;

    l_api_name	     CONSTANT VARCHAR2(30) := 'create_tradein';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;

  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   lp_clev_rec.id := lp_tradein_rec.id;
   lp_klev_rec.id := lp_tradein_rec.id;
   lp_klev_rec.tradein_amount := null;

   okl_contract_pvt.update_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_rec      => lp_clev_rec,
          p_klev_rec      => lp_klev_rec,
          x_clev_rec      => lx_clev_rec,
          x_klev_rec      => lx_klev_rec);


   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   --Bug# 5102606
   recalculate_costs(
       p_api_version   => p_api_version,
       p_init_msg_list => p_init_msg_list,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_chr_id        => p_chr_id,
       p_cle_id        => lp_clev_rec.id);

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
   End If;
   --Bug# 5102606

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

 PROCEDURE delete_tradein(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_tbl            IN  tradein_tbl_type,
            x_tradein_tbl            OUT NOCOPY tradein_tbl_type
 )IS

    lp_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type;
    lx_tradein_rec  OKL_LA_TRADEIN_PVT.tradein_rec_type;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lp_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lp_klev_tbl OKL_KLE_PVT.klev_tbl_type;

    lx_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lx_klev_tbl OKL_KLE_PVT.klev_tbl_type;

    l_chr_id            okc_k_headers_b.id%type := p_chr_id;

    l_api_name	     CONSTANT VARCHAR2(30) := 'create_tradein';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;
    i number := 0;


  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If (p_tradein_tbl.COUNT > 0) Then

       i := p_tradein_tbl.FIRST;

       LOOP

            lp_tradein_rec.id := p_tradein_tbl(i).id;

            delete_tradein(
	    	p_api_version		=> p_api_version,
	    	p_init_msg_list		=> p_init_msg_list,
	    	x_return_status 	=> x_return_status,
	    	x_msg_count     	=> x_msg_count,
	    	x_msg_data      	=> x_msg_data,
	    	p_chr_id                => l_chr_id,
	    	p_tradein_rec		=> lp_tradein_rec,
	    	x_tradein_rec		=> lx_tradein_rec);

            If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
         	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	    	  raise OKC_API.G_EXCEPTION_ERROR;
            End If;

       EXIT WHEN (i = p_tradein_tbl.LAST);
          i := p_tradein_tbl.NEXT(i);
       END LOOP;

   End If;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

  PROCEDURE allocate_amount(p_api_version         IN         NUMBER,
                            p_init_msg_list       IN         VARCHAR2 DEFAULT G_FALSE,
                            p_transaction_control IN         VARCHAR2 DEFAULT G_TRUE,
                            p_cle_id              IN         NUMBER,
                            p_chr_id              IN         NUMBER,
                            p_capitalize_yn       IN         VARCHAR2,
                            x_cle_id              OUT NOCOPY NUMBER,
                            x_chr_id              OUT NOCOPY NUMBER,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_chr_id            okc_k_headers_b.id%type := null;
    l_cl_id             okc_k_headers_b.id%type := null;

    l_api_name		CONSTANT VARCHAR2(30) := 'allocate_amount';
    l_api_version	CONSTANT NUMBER	  := 1.0;


  BEGIN

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

      allocate_amount(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        p_transaction_control   => p_transaction_control,
        p_cle_id                => p_cle_id,
        p_chr_id                => p_chr_id,
        p_capitalize_yn         => p_capitalize_yn,
        x_cle_id                => x_cle_id,
        x_chr_id                => x_chr_id,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data
        );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END allocate_amount;

 PROCEDURE allocate_amount_tradein (
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_derive_assoc_amt       IN  VARCHAR2
) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'allocate_amount';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR c_assets IS
    SELECT cle.cle_id fin_asset_id,
             txl.asset_number
    FROM   okl_txl_assets_b txl,
             okc_k_lines_b cle,
             okc_line_styles_b lse
    WHERE  cle.dnz_chr_id = p_chr_id
    AND  cle.id = txl.kle_id
    AND  cle.lse_id = lse.id
    AND  lse.lty_code = 'FIXED_ASSET'
    AND  cle.sts_code <> 'ABANDONED';

    l_asset_tbl  asset_tbl_type;

    lp_klev_tbl  okl_kle_pvt.klev_tbl_type;
    lp_clev_tbl  okl_okc_migration_pvt.clev_tbl_type;

    lx_klev_tbl  okl_kle_pvt.klev_tbl_type;
    lx_clev_tbl  okl_okc_migration_pvt.clev_tbl_type;

    k                           BINARY_INTEGER  := 1;  -- create table index
    m                           BINARY_INTEGER  := 1;  -- update table index
    i 				number := 0;
    l_chr_id 			okc_k_headers_b.id%type := null;
    l_tradein_amount            NUMBER       := 0;
    l_asset_oec                 NUMBER;
    l_oec_total                 NUMBER       := 0;
    l_assoc_amount              NUMBER;
    l_assoc_total               NUMBER       := 0;
    l_currency_code             VARCHAR2(15);
    l_compare_amt               NUMBER;
    l_diff                      NUMBER;
    l_adj_rec                   BINARY_INTEGER;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
      	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    i := 0;

    FOR l_asset IN c_assets LOOP

       i := i + 1;

       l_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
       l_asset_tbl(i).asset_number := l_asset.asset_number;

    END LOOP;


    SELECT nvl(tradein_amount,0)
    INTO   l_tradein_amount
    FROM okl_k_headers
    WHERE id = p_chr_id;

    SELECT currency_code
    INTO   l_currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    IF (l_asset_tbl.COUNT > 0) THEN

      ------------------------------------------------------------------
      -- 1. Loop through to get OEC total of all assets being associated
      ------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN

          SELECT NVL(oec, 0)
          INTO   l_asset_oec
          FROM   okl_k_lines
          WHERE  id = l_asset_tbl(i).fin_asset_id;

          l_oec_total := l_oec_total + l_asset_oec;

        END IF;

      END LOOP;

      ----------------------------------------------------------------------------
      -- 2. Loop through to determine associated amounts and round off the amounts
      ----------------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN

            -- LLA APIs ensure asset OEC and l_tradein_amount are rounded

            SELECT NVL(oec, 0)
            INTO   l_asset_oec
            FROM   okl_k_lines
            WHERE  id = l_asset_tbl(i).fin_asset_id;

            IF l_asset_tbl.COUNT = 1 THEN

              l_assoc_amount := l_tradein_amount;

            ELSE

              l_assoc_amount := l_tradein_amount * l_asset_oec / l_oec_total;

            END IF;


          l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                             p_currency_code => l_currency_code);

          l_assoc_total := l_assoc_total + l_assoc_amount;

          lp_klev_tbl(i).tradein_amount := l_assoc_amount;
          lp_klev_tbl(i).id := l_asset_tbl(i).fin_asset_id;
          lp_clev_tbl(i).id := l_asset_tbl(i).fin_asset_id;
        END IF;

      END LOOP;

      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_assoc_total <> l_tradein_amount THEN

        l_diff := ABS(l_tradein_amount - l_assoc_total);

        lp_klev_tbl(lp_klev_tbl.FIRST).tradein_amount :=  lp_klev_tbl(lp_klev_tbl.FIRST).tradein_amount + l_diff;

      END IF;

/*
      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_assoc_total <> l_line_amount THEN

        l_diff := ABS(l_assoc_total - l_line_amount);

        FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

          IF l_link_asset_tbl.EXISTS(i) THEN

            -- if the total split amount is less than line amount add the difference amount to the
            -- asset with less amount and if the total split amount is greater than the line amount
            -- than subtract the difference amount from the asset with highest amount

            IF i = l_link_asset_tbl.FIRST THEN

              l_adj_rec     := i; -- Bug#3404844
              l_compare_amt := l_link_asset_tbl(i).amount;

            ELSIF (l_assoc_total < l_line_amount) AND (l_link_asset_tbl(i).amount <= l_compare_amt) OR
                  (l_assoc_total > l_line_amount) AND (l_link_asset_tbl(i).amount >= l_compare_amt) THEN

                l_adj_rec     := i;
                l_compare_amt := l_link_asset_tbl(i).amount;

            END IF;

          END IF;

        END LOOP;

        IF l_assoc_total < l_line_amount THEN

          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount + l_diff;

        ELSE

          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount - l_diff;

        END IF;

      END IF;
*/
      ------------------------------------------------------
      -- 4. Prepare arrays to pass to create and update APIs
      ------------------------------------------------------
/*
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          l_assoc_amount := l_link_asset_tbl(i).amount;

        END IF;

      END LOOP;
*/

      IF lp_klev_tbl.COUNT > 0 THEN

      	okl_contract_pvt.update_contract_line(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_clev_tbl      => lp_clev_tbl,
          p_klev_tbl      => lp_klev_tbl,
          x_clev_tbl      => lx_clev_tbl,
          x_klev_tbl      => lx_klev_tbl);


   	If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
   	        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   	Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
   	        raise OKC_API.G_EXCEPTION_ERROR;
   	End If;

        --Bug# 5102606
        FOR i IN  lp_klev_tbl.FIRST .. lp_klev_tbl.LAST
        LOOP

          recalculate_costs(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_chr_id        => p_chr_id,
            p_cle_id        => lp_klev_tbl(i).id);

          If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
              raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
             raise OKC_API.G_EXCEPTION_ERROR;
          End If;
        END LOOP;
        --Bug# 5102606

      END IF;

    END IF;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END allocate_amount_tradein;

--Bug# 5237504 Added the following procedure to remove trade-in info at
-- contract level
PROCEDURE delete_contract(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE
 )IS

    lp_chrv_rec  okl_okc_migration_pvt.chrv_rec_type;
    lp_khrv_rec  okl_khr_pvt.khrv_rec_type;

    lx_chrv_rec  okl_okc_migration_pvt.chrv_rec_type;
    lx_khrv_rec  okl_khr_pvt.khrv_rec_type;

    l_chr_id            okc_k_headers_b.id%type := p_chr_id;

    l_api_name	     CONSTANT VARCHAR2(30) := 'delete_contract';
    l_api_version    CONSTANT NUMBER	  := 1.0;
    l_ak_prompt      AK_ATTRIBUTES_VL.attribute_label_long%type;


  BEGIN

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If(l_chr_id is null or l_chr_id = OKL_API.G_MISS_NUM) Then
     x_return_status := OKC_API.g_ret_sts_error;
     OKC_API.SET_MESSAGE(      p_app_name => g_app_name
        			, p_msg_name => 'OKL_REQUIRED_VALUE'
     				, p_token1 => 'COL_NAME'
     				, p_token1_value => 'DNZ_CHR_ID'
     			   );
     raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If okl_context.get_okc_org_id  is null then
      okl_context.set_okc_org_context(p_chr_id => l_chr_id );
   End If;

    lp_chrv_rec.id := l_chr_id;
    lp_khrv_rec.id := l_chr_id;
    lp_khrv_rec.date_tradein := null;
    lp_khrv_rec.tradein_amount := null;
    lp_khrv_rec.tradein_description := null;

    OKL_CONTRACT_PUB.update_contract_header(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_restricted_update     => 'F',
        p_chrv_rec       	=> lp_chrv_rec,
        p_khrv_rec       	=> lp_khrv_rec,
        x_chrv_rec       	=> lx_chrv_rec,
        x_khrv_rec       	=> lx_khrv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

   x_return_status := OKC_API.g_ret_sts_success;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;
--Bug# 5237504:end

END OKL_LA_TRADEIN_PVT;

/
