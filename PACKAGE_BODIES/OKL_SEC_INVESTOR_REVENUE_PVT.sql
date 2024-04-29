--------------------------------------------------------
--  DDL for Package Body OKL_SEC_INVESTOR_REVENUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_INVESTOR_REVENUE_PVT" AS
 /* $Header: OKLRSZRB.pls 120.2 2005/10/30 04:38:35 appldev noship $ */

  PROCEDURE VALIDATE(p_szr_rec IN  szr_rec_type,
                     x_return_status OUT NOCOPY VARCHAR2
  )
  IS

    -- mvasudev, 10/12/2004, Bug#3909240
    /*
    CURSOR l_okl_sty_percent_csr(p_khr_id IN NUMBER, p_sty_id IN NUMBER)
    IS
    SELECT kleb.percent_stake percent_stake
    FROM   okl_k_lines kleb,
           okc_k_lines_b cles
    WHERE  kleb.id = cles.id
    AND    cles.dnz_chr_id = p_khr_id
    AND    cles.cle_id IS NOT NULL
    AND    kleb.sty_id = p_sty_id
    AND    kleb.id <> p_szr_rec.id;
    */
    CURSOR l_okl_sty_percent_csr(p_khr_id IN NUMBER, p_sty_subclass IN VARCHAR2)
    IS
    SELECT kleb.percent_stake percent_stake
    FROM   okl_k_lines kleb,
           okc_k_lines_b cles
    WHERE  kleb.id = cles.id
    AND    cles.dnz_chr_id = p_khr_id
    AND    cles.cle_id IS NOT NULL
    AND    kleb.stream_type_subclass = p_sty_subclass
    AND    kleb.id <> p_szr_rec.id;

	-- To check only one row exists for a subclass for an Investor
    CURSOR l_okl_sty_subclass_csr(p_khr_id IN NUMBER, p_top_line_id IN NUMBER,p_sty_subclass IN VARCHAR2)
    IS
    SELECT '1'
    FROM   okl_k_lines kleb,
           okc_k_lines_b cles
    WHERE  kleb.id = cles.id
    AND    cles.dnz_chr_id = p_khr_id
    AND    cles.cle_id = p_top_line_id
    AND    kleb.stream_type_subclass = p_sty_subclass
    AND    kleb.id <> p_szr_rec.id;

     l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
     l_total_percent NUMBER := 0;

  BEGIN
        -- mvasudev, 10/12/2004, Bug#3909240
        /*
        -- check for stream type
        IF(p_szr_rec.kle_sty_id IS NULL OR  p_szr_rec.kle_sty_id = OKC_API.G_MISS_NUM) THEN
            x_return_status := G_RET_STS_ERROR;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_STREAM_TYPE');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => l_ak_prompt);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        */
        -- check for stream type subclass
        IF(p_szr_rec.kle_sty_subclass IS NULL OR  p_szr_rec.kle_sty_subclass = OKC_API.G_MISS_CHAR) THEN
            x_return_status := G_RET_STS_ERROR;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_STREAM_TYPE_SUBCLASS');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => l_ak_prompt);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        -- end,mvasudev, 10/12/2004, Bug#3909240

        -- check for top line id
        IF(p_szr_rec.top_line_id IS NULL OR  p_szr_rec.top_line_id = OKC_API.G_MISS_NUM) THEN
            x_return_status := G_RET_STS_ERROR;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_INVESTOR');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => l_ak_prompt);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        -- check for percent_stake
        IF(p_szr_rec.kle_percent_stake IS NULL OR  p_szr_rec.kle_percent_stake = OKC_API.G_MISS_NUM) THEN
            x_return_status := G_RET_STS_ERROR;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_SHARE_PERCENT');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => l_ak_prompt);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF p_szr_rec.kle_percent_stake > 100 THEN
            x_return_status := G_RET_STS_ERROR;
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_PERCENT');
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

		-- mvasudev, 10/12/2004, Bug#3909240
		-- Check for unique Subclass for an Investor
		FOR l_okl_sty_subclass_rec IN l_okl_sty_subclass_csr(p_szr_rec.dnz_chr_id, p_szr_rec.top_line_id,p_szr_rec.kle_sty_subclass)
		LOOP
            x_return_status := G_RET_STS_ERROR;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_STREAM_TYPE_SUBCLASS');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_INV_STY_UNIQUE',
                          p_token1       => 'STY_SUBCLASS',
                          p_token1_value => l_ak_prompt);
            RAISE OKC_API.G_EXCEPTION_ERROR;
		END LOOP;


        -- mvasudev, v115.5
        l_total_percent := p_szr_rec.kle_percent_stake;
        -- mvasudev, 10/12/2004, Bug#3909240
	--FOR l_okl_sty_percent_rec IN l_okl_sty_percent_csr(p_szr_rec.dnz_chr_id, p_szr_rec.kle_sty_id)
	FOR l_okl_sty_percent_rec IN l_okl_sty_percent_csr(p_szr_rec.dnz_chr_id, p_szr_rec.kle_sty_subclass)
	LOOP
          l_total_percent := l_total_percent + l_okl_sty_percent_rec.percent_stake;
	END LOOP;

        IF l_total_percent > 100 THEN
            x_return_status := G_RET_STS_ERROR;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_STREAM_TYPE');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_REV_SHARE_PERCENT',
                          p_token1       => 'TITLE',
                          p_token1_value => l_ak_prompt);
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
  END VALIDATE;

  PROCEDURE migrate_records(p_szr_rec                      IN  szr_rec_type,
                            x_clev_rec                     OUT NOCOPY clev_rec_type,
                            x_klev_rec                     OUT NOCOPY klev_rec_type)
  IS

   CURSOR l_okl_top_line_details_csr(p_tl_id IN NUMBER)
   IS
   SELECT clet.start_date
         ,clet.end_date
		 ,clet.currency_code
   FROM   okc_k_lines_b clet
         ,okc_line_styles_b lseb
   WHERE  clet.id = p_tl_id
   AND    clet.lse_id = lseb.id
   AND    lseb.lty_code = 'INVESTMENT';

   l_clev_rec    clev_rec_type;
   l_klev_rec    klev_rec_type;

  BEGIN

    l_clev_rec.id               := p_szr_rec.id;
    l_clev_rec.cle_id           := p_szr_rec.top_line_id;
    l_clev_rec.dnz_chr_id       := p_szr_rec.dnz_chr_id;
	-- other implicit details
	FOR l_okl_top_line_details_rec IN l_okl_top_line_details_csr(p_szr_rec.top_line_id)
	LOOP
      l_clev_rec.start_date     := l_okl_top_line_details_rec.start_date;
      l_clev_rec.end_date       := l_okl_top_line_details_rec.end_date;
      l_clev_rec.currency_code  := l_okl_top_line_details_rec.currency_code;
	END LOOP;

    l_klev_rec.id                             := p_szr_rec.id;

    -- mvasudev, 10/12/2004, Bug#3909240
    --l_klev_rec.sty_id                         := p_szr_rec.kle_sty_id;
    l_klev_rec.stream_type_subclass           := p_szr_rec.kle_sty_subclass;

    l_klev_rec.percent_stake                  := p_szr_rec.kle_percent_stake;

    x_clev_rec := l_clev_rec;
    x_klev_rec := l_klev_rec;

  END migrate_records;

  PROCEDURE CREATE_INVESTOR_REVENUE(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_rec                      IN  szr_rec_type,
                            x_szr_rec                      OUT NOCOPY szr_rec_type)
  IS
     CURSOR l_okl_lse_csr(p_lty_code IN VARCHAR2) IS
     SELECT ID
     FROM   okc_line_styles_v
     WHERE  lty_code = p_lty_code;

    -- mvasudev, 10/12/2004, Bug#3909240
    /*
     CURSOR l_okl_cle_sty_csr(p_cle_id IN NUMBER, p_sty_id IN NUMBER) IS
     SELECT '1'
     FROM
	  OKL_K_LINES KLEB,
	  OKC_K_LINES_B CLET,
	  OKC_K_LINES_B CLES
     WHERE
	     KLEB.ID = CLES.ID
	 AND CLES.CLE_ID = CLET.ID
	 AND CLET.ID = p_cle_id
	 AND KLEB.STY_ID = p_sty_id;
     */
          CURSOR l_okl_cle_sty_csr(p_cle_id IN NUMBER, p_sty_subclass IN VARCHAR2) IS
          SELECT '1'
          FROM
     	  OKL_K_LINES KLEB,
     	  OKC_K_LINES_B CLET,
     	  OKC_K_LINES_B CLES
          WHERE
     	     KLEB.ID = CLES.ID
     	 AND CLES.CLE_ID = CLET.ID
     	 AND CLET.ID = p_cle_id
	 AND KLEB.stream_type_subclass = p_sty_subclass;


/* Taken care in migrate function
     CURSOR l_okl_cle_start_date_csr(p_cle_id IN NUMBER) IS
     SELECT CLET.START_DATE
     FROM
	  OKL_K_LINES KLEB,
	  OKC_K_LINES_B CLET,
	  OKC_K_LINES_B CLES
     WHERE
	     KLEB.ID = CLES.ID
	 AND CLES.CLE_ID = CLET.ID
	 AND CLET.ID = p_cle_id;
*/
     l_clev_rec    clev_rec_type;
     l_klev_rec    klev_rec_type;
     lx_clev_rec    clev_rec_type;
     lx_klev_rec    klev_rec_type;
     l_szr_rec     szr_rec_type;
     l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_INVESTOR_REVENUE';
     l_api_version            CONSTANT NUMBER    := 1.0;
     l_found BOOLEAN := FALSE;
     l_dummy VARCHAR2(1) := '?';
  BEGIN

        x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        VALIDATE(p_szr_rec       =>  p_szr_rec,
                 x_return_status => x_return_status);
        IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OPEN l_okl_cle_sty_csr(p_szr_rec.top_line_id,p_szr_rec.kle_sty_subclass);
        FETCH l_okl_cle_sty_csr INTO l_dummy;
        l_found := l_okl_cle_sty_csr%FOUND;
        CLOSE l_okl_cle_sty_csr;

        IF(l_found) THEN
		OKL_API.set_message(G_APP_NAME,'OKL_STY_NOT_UNIQUE');
		x_return_status := G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        migrate_records(p_szr_rec       => p_szr_rec,
                        x_clev_rec      => l_clev_rec,
                        x_klev_rec      => l_klev_rec);

        OPEN l_okl_lse_csr('REVENUE_SHARE');
        FETCH l_okl_lse_csr INTO l_clev_rec.lse_id;
        CLOSE l_okl_lse_csr;

/*  taken care in migrate function
        OPEN l_okl_cle_start_date_csr(p_szr_rec.top_line_id);
        FETCH l_okl_cle_start_date_csr INTO l_clev_rec.start_date;
        CLOSE l_okl_cle_start_date_csr;
*/
        l_clev_rec.line_number := '1';
        l_clev_rec.display_sequence := 1;
        l_clev_rec.exception_yn     := 'N';
        l_clev_rec.sts_code         := 'NEW';

        OKL_CONTRACT_PUB.create_contract_line(
          p_api_version        => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_clev_rec           => l_clev_rec,
          p_klev_rec           => l_klev_rec,
          x_clev_rec           => lx_clev_rec,
          x_klev_rec           => lx_klev_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

       --Call End Activity
       OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         IF l_okl_lse_csr%ISOPEN
         THEN
           CLOSE l_okl_lse_csr;
         END IF;
         IF l_okl_cle_sty_csr%ISOPEN
         THEN
           CLOSE l_okl_cle_sty_csr;
         END IF;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF l_okl_lse_csr%ISOPEN
         THEN
           CLOSE l_okl_lse_csr;
         END IF;
         IF l_okl_cle_sty_csr%ISOPEN
         THEN
           CLOSE l_okl_cle_sty_csr;
         END IF;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         IF l_okl_lse_csr%ISOPEN
         THEN
           CLOSE l_okl_lse_csr;
         END IF;
         IF l_okl_cle_sty_csr%ISOPEN
         THEN
           CLOSE l_okl_cle_sty_csr;
         END IF;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END  CREATE_INVESTOR_REVENUE;

  PROCEDURE UPDATE_INVESTOR_REVENUE(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_rec                      IN  szr_rec_type,
                            x_szr_rec                      OUT NOCOPY szr_rec_type)
  IS
	  l_clev_rec    clev_rec_type;
	  l_klev_rec    klev_rec_type;

	  lx_clev_rec    clev_rec_type;
	  lx_klev_rec    klev_rec_type;


	  l_szr_rec     szr_rec_type;

	  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	  l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_INVESTOR_REVENUE';
	  l_api_version            CONSTANT NUMBER    := 1.0;

  BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        VALIDATE(p_szr_rec       =>  p_szr_rec,
                 x_return_status => x_return_status);
        IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        migrate_records(p_szr_rec       => p_szr_rec,
                        x_clev_rec      => l_clev_rec,
                        x_klev_rec      => l_klev_rec);

    OKL_CONTRACT_PUB.update_contract_line(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_clev_rec           => l_clev_rec,
        p_klev_rec           => l_klev_rec,
        x_clev_rec           => lx_clev_rec,
        x_klev_rec           => lx_klev_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Call End Activity
      OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);



  END  UPDATE_INVESTOR_REVENUE;

  PROCEDURE DELETE_INVESTOR_REVENUE(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_rec                      IN  szr_rec_type)
  IS
	  l_clev_rec    clev_rec_type;
	  l_klev_rec    klev_rec_type;

	  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	  l_api_name               CONSTANT VARCHAR2(30) := 'DELETE_INVESTOR_REVENUE';
	  l_api_version            CONSTANT NUMBER    := 1.0;

  BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        migrate_records(p_szr_rec       => p_szr_rec,
                        x_clev_rec      => l_clev_rec,
                        x_klev_rec      => l_klev_rec);

    OKL_CONTRACT_PUB.delete_contract_line(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_clev_rec           => l_clev_rec,
        p_klev_rec           => l_klev_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END  DELETE_INVESTOR_REVENUE;

  PROCEDURE CREATE_INVESTOR_REVENUE(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_tbl                      IN  szr_tbl_type,
                            x_szr_tbl                      OUT NOCOPY szr_tbl_type)
   IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'CREATE_INVESTOR_REVENUE_TBL';
    rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
   BEGIN

      	FOR rec_num	IN 1..p_szr_tbl.COUNT
	LOOP
		create_investor_revenue(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_szr_rec                     => p_szr_tbl(rec_num),
         x_szr_rec                     => x_szr_tbl(rec_num) );
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
	END LOOP;
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END  CREATE_INVESTOR_REVENUE;

  PROCEDURE UPDATE_INVESTOR_REVENUE(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_tbl                      IN  szr_tbl_type,
                            x_szr_tbl                      OUT NOCOPY szr_tbl_type)
  IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'UPDATE_INVESTOR_REVENUE_TBL';
    rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
   BEGIN

      	FOR rec_num	IN 1..p_szr_tbl.COUNT
	LOOP
		update_investor_revenue(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_szr_rec                     => p_szr_tbl(rec_num),
         x_szr_rec                     => x_szr_tbl(rec_num) );
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
	END LOOP;
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END  UPDATE_INVESTOR_REVENUE;

  PROCEDURE DELETE_INVESTOR_REVENUE(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_szr_tbl                      IN  szr_tbl_type)
  IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'DELETE_INVESTOR_REVENUE_TBL';
    rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
   BEGIN

      	FOR rec_num	IN 1..p_szr_tbl.COUNT
	LOOP
		DELETE_INVESTOR_REVENUE(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_szr_rec                     => p_szr_tbl(rec_num));
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
	END LOOP;
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END  DELETE_INVESTOR_REVENUE;

END Okl_Sec_Investor_Revenue_Pvt;

/
