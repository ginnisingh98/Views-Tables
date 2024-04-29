--------------------------------------------------------
--  DDL for Package Body OKL_LA_PROPERTY_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_PROPERTY_TAX_PVT" AS
 /* $Header: OKLRPTXB.pls 120.3 2005/06/06 17:30:33 rseela noship $ */

  -- Start of comments
  --
  -- Procedure Name  : create_est_prop_tax_rules
  -- Description     : Creates Estimated Property Tax rules basing on the setup
  --                   value.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE create_est_prop_tax_rules(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER)

  IS
    l_rgpv_rec          rgpv_rec_type;
    l_rulv_rec          rulv_rec_type;
    lx_rgpv_rec         rgpv_rec_type;
    lx_rulv_rec         rulv_rec_type;

    l_chr_id  okc_k_headers_b.id%TYPE;
    l_cle_id  okc_k_lines_v.id%TYPE;
    l_rgp_id  NUMBER;
    lv_enable_asset_default okl_property_tax_setups.enable_asset_default%TYPE;
    lv_property_tax_applicable okl_property_tax_setups.property_tax_applicable%TYPE;
    lv_bill_property_tax okl_property_tax_setups.bill_property_tax%TYPE;
	-- Start 4042157 fmiao 12/03/04 added update_from_contract --
    lv_update_from_contract okl_property_tax_setups.update_from_contract%TYPE;
	-- End 4042157 fmiao 12/03/04 added update_from_contract --

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_EST_PROP_TAX_RULES';

	-- Start 4042157 fmiao 12/03/04 added update_from_contract --
    CURSOR get_est_prop_tax_info(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT enable_asset_default, property_tax_applicable,
		   bill_property_tax,update_from_contract
    FROM okl_property_tax_setups
    WHERE org_id = (SELECT authoring_org_id
                    FROM okc_k_headers_b
                    WHERE id = p_chr_id);
	-- End 4042157 fmiao 12/03/04 added update_from_contract --
  BEGIN

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_chr_id := p_chr_id;
      l_cle_id := p_cle_id;
 -- 4374085
/*
      IF okl_context.get_okc_org_id  IS NULL THEN
        okl_context.set_okc_org_context(p_chr_id => l_chr_id);
      END IF;
*/

      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,g_api_type
                               ,x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN get_est_prop_tax_info(l_chr_id);
      FETCH get_est_prop_tax_info into lv_enable_asset_default,
                                       lv_property_tax_applicable,
                                       lv_bill_property_tax,
									   lv_update_from_contract;
      IF (get_est_prop_tax_info%NOTFOUND) THEN
        RETURN;
      END IF;
      CLOSE get_est_prop_tax_info;

      IF(lv_enable_asset_default = 'YES') THEN

        -- Create the rule group for Estimated Property Tax
        l_rgpv_rec.rgd_code      :=  'LAASTX';
        l_rgpv_rec.chr_id        :=   null;
        l_rgpv_rec.dnz_chr_id    :=  l_chr_id;
        l_rgpv_rec.cle_id        :=  l_cle_id;
        l_rgpv_rec.rgp_type      :=  'KRG';

        OKL_RULE_PUB.create_rule_group(
              p_api_version       =>  p_api_version,
              p_init_msg_list     =>  p_init_msg_list,
              x_return_status     =>  x_return_status,
              x_msg_count         =>  x_msg_count,
              x_msg_data          =>  x_msg_data,
              p_rgpv_rec          =>  l_rgpv_rec,
              x_rgpv_rec          =>  lx_rgpv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_rgp_id := lx_rgpv_rec.id;

        -- Create the Estimated Property Tax rule
        l_rulv_rec.sfwt_flag         := 'N';
        l_rulv_rec.dnz_chr_id        := l_chr_id;
        l_rulv_rec.rgp_id            := l_rgp_id;
        l_rulv_rec.std_template_yn   := 'N';
        l_rulv_rec.warn_yn       := 'N';
        l_rulv_rec.template_yn   := 'N';
        l_rulv_rec.rule_information_category := 'LAPRTX';

        IF (lv_property_tax_applicable = 'YES') THEN
          l_rulv_rec.rule_information1 := 'Y';
        ELSE
          l_rulv_rec.rule_information1 := 'N';
        END IF;
        l_rulv_rec.rule_information2 := 'N'; -- Lessee to Report
        l_rulv_rec.rule_information3 := lv_bill_property_tax;

        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

		-- Start 4042157 fmiao 12/03/04 added update_from_contract --
		l_rulv_rec.rule_information_category := 'LAASTK';

        IF (lv_update_from_contract = 'YES') THEN
          l_rulv_rec.rule_information1 := 'Y';
        ELSE
          l_rulv_rec.rule_information1 := 'N';
        END IF;

        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
		-- Start 4042157 fmiao 12/03/04 added update_from_contract --
      END IF;

      OKL_API.END_ACTIVITY (x_msg_count  => x_msg_count,
                            x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF get_est_prop_tax_info%ISOPEN THEN
        CLOSE get_est_prop_tax_info;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF get_est_prop_tax_info%ISOPEN THEN
        CLOSE get_est_prop_tax_info;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      IF get_est_prop_tax_info%ISOPEN THEN
        CLOSE get_est_prop_tax_info;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_est_prop_tax_rules;

   -- Start of comments
  --
  -- Procedure Name  : create_est_prop_tax_rules
  -- Description     : Bug 4086808 added the default value for bill tax
  --                   for user to modify
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE create_est_prop_tax_rules(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER)

  IS
    l_rgpv_rec          rgpv_rec_type;
    l_rulv_rec          rulv_rec_type;
    lx_rgpv_rec         rgpv_rec_type;
    lx_rulv_rec         rulv_rec_type;

    l_chr_id  okc_k_headers_b.id%TYPE;
    l_rgp_id  NUMBER;
    lv_property_tax_applicable okl_property_tax_setups.property_tax_applicable%TYPE;
    lv_bill_property_tax okl_property_tax_setups.bill_property_tax%TYPE;
    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_EST_PROP_TAX_RULES';

	CURSOR get_est_prop_tax_info(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT property_tax_applicable,
		   bill_property_tax
    FROM okl_property_tax_setups
    WHERE org_id = (SELECT authoring_org_id
                    FROM okc_k_headers_b
                    WHERE id = p_chr_id);

  BEGIN

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_chr_id := p_chr_id;

      IF okl_context.get_okc_org_id  IS NULL THEN
        okl_context.set_okc_org_context(p_chr_id => l_chr_id);
      END IF;

      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,g_api_type
                               ,x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN get_est_prop_tax_info(l_chr_id);
      FETCH get_est_prop_tax_info into lv_property_tax_applicable,
                                       lv_bill_property_tax;
      IF (get_est_prop_tax_info%NOTFOUND) THEN
        RETURN;
      END IF;
      CLOSE get_est_prop_tax_info;

        -- Create the rule group for Estimated Property Tax
        l_rgpv_rec.rgd_code      :=  'LAHDTX';
        l_rgpv_rec.chr_id        :=  l_chr_id;
        l_rgpv_rec.dnz_chr_id    :=  l_chr_id;
        l_rgpv_rec.cle_id        :=  null;
        l_rgpv_rec.rgp_type      :=  'KRG';

        OKL_RULE_PUB.create_rule_group(
              p_api_version       =>  p_api_version,
              p_init_msg_list     =>  p_init_msg_list,
              x_return_status     =>  x_return_status,
              x_msg_count         =>  x_msg_count,
              x_msg_data          =>  x_msg_data,
              p_rgpv_rec          =>  l_rgpv_rec,
              x_rgpv_rec          =>  lx_rgpv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_rgp_id := lx_rgpv_rec.id;

        -- Create the Estimated Property Tax rule
        l_rulv_rec.sfwt_flag         := 'N';
        l_rulv_rec.dnz_chr_id        := l_chr_id;
        l_rulv_rec.rgp_id            := l_rgp_id;
        l_rulv_rec.std_template_yn   := 'N';
        l_rulv_rec.warn_yn       := 'N';
        l_rulv_rec.template_yn   := 'N';
        l_rulv_rec.rule_information_category := 'LAPRTX';

        IF (lv_property_tax_applicable = 'YES') THEN
          l_rulv_rec.rule_information1 := 'Y';
        ELSE
          l_rulv_rec.rule_information1 := 'N';
        END IF;
		l_rulv_rec.rule_information3 := lv_bill_property_tax;
		l_rulv_rec.rule_information2 := 'N';

        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      OKL_API.END_ACTIVITY (x_msg_count  => x_msg_count,
                            x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF get_est_prop_tax_info%ISOPEN THEN
        CLOSE get_est_prop_tax_info;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF get_est_prop_tax_info%ISOPEN THEN
        CLOSE get_est_prop_tax_info;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      IF get_est_prop_tax_info%ISOPEN THEN
        CLOSE get_est_prop_tax_info;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_est_prop_tax_rules;


  -- Procedure Name  : sync_contract_property_tax
  -- Description     : Sync the asset property tax rule information with that of
  --                   the contract, if the flag at the asset level is checked.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE sync_contract_property_tax(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER)
  IS
    l_rulv_rec          rulv_rec_type;
    lx_rulv_rec         rulv_rec_type;

    ln_cle_id                     okc_k_lines_v.id%TYPE;

    ln_rule_id                    okc_rules_v.id%TYPE;
    lv_asset_k_rule_information1  okc_rules_v.rule_information1%TYPE;

    lv_k_rule_information1        okc_rules_v.rule_information1%TYPE;
    lv_k_rule_information2        okc_rules_v.rule_information2%TYPE;
    lv_k_rule_information3        okc_rules_v.rule_information3%TYPE;

    l_api_name	CONSTANT VARCHAR2(30) := 'SYNC_CONTRACT_PROPERTY_TAX';

    CURSOR get_contract_property_tax_info(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT rul.rule_information1, rul.rule_information2, rul.rule_information3
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id is NULL
    AND   rgp.rgd_code = 'LAHDTX'
    AND   rul.rule_information_category = 'LAPRTX';

    CURSOR get_contract_lines(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT cle.id
    FROM   OKC_K_LINES_V cle,
           OKC_LINE_STYLES_V lse
    WHERE  cle.lse_id = lse.id
    AND    lse.lty_code = 'FREE_FORM1'
    AND    lse.lse_type = 'TLS'
    AND    cle.dnz_chr_id = p_chr_id;

    CURSOR get_asset_contract_tax_info(p_chr_id  okc_k_headers_b.id%TYPE,
                                       p_cle_id  okc_k_lines_v.id%TYPE) IS
    SELECT rul.rule_information1
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id = p_cle_id
    AND   rgp.rgd_code = 'LAASTX'
    AND   rul.rule_information_category = 'LAASTK';

    CURSOR get_asset_property_tax_info(p_chr_id  okc_k_headers_b.id%TYPE,
                                       p_cle_id  okc_k_lines_v.id%TYPE) IS
    SELECT rul.id
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id = p_cle_id
    AND   rgp.rgd_code = 'LAASTX'
    AND   rul.rule_information_category = 'LAPRTX';

  BEGIN

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      IF okl_context.get_okc_org_id  IS NULL THEN
        okl_context.set_okc_org_context(p_chr_id => p_chr_id);
      END IF;

      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,g_api_type
                               ,x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN  get_contract_property_tax_info(p_chr_id);
      FETCH get_contract_property_tax_info into lv_k_rule_information1,
                                                lv_k_rule_information2,
                                                lv_k_rule_information3;
      IF (get_contract_property_tax_info%NOTFOUND) THEN
        RETURN;
      END IF;
      CLOSE get_contract_property_tax_info;

      FOR r_get_contract_lines IN get_contract_lines(p_chr_id => p_chr_id) LOOP

        OPEN get_asset_contract_tax_info(p_chr_id  => p_chr_id,
                                         p_cle_id  => r_get_contract_lines.id);
        FETCH get_asset_contract_tax_info into lv_asset_k_rule_information1;
        CLOSE get_asset_contract_tax_info;

        IF (lv_asset_k_rule_information1 IS NOT NULL AND
            lv_asset_k_rule_information1 = 'Y') THEN

          lv_asset_k_rule_information1 := null; -- Reset the value

          OPEN get_asset_property_tax_info(p_chr_id  => p_chr_id,
                                           p_cle_id  => r_get_contract_lines.id);
          FETCH get_asset_property_tax_info into ln_rule_id;
          CLOSE get_asset_property_tax_info;

          l_rulv_rec.id := ln_rule_id;
          l_rulv_rec.rule_information1 := lv_k_rule_information1;
          l_rulv_rec.rule_information2 := lv_k_rule_information2;
          l_rulv_rec.rule_information3 := lv_k_rule_information3;

          OKL_RULE_PUB.update_rule(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_rulv_rec            => l_rulv_rec,
            x_rulv_rec            => lx_rulv_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END LOOP;

      OKL_API.END_ACTIVITY (x_msg_count  => x_msg_count,
                            x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_contract_property_tax_info%ISOPEN THEN
      CLOSE get_contract_property_tax_info;
    END IF;
    IF get_asset_contract_tax_info%ISOPEN THEN
      CLOSE get_asset_contract_tax_info;
    END IF;
    IF get_contract_lines%ISOPEN THEN
      CLOSE get_contract_lines;
    END IF;
    IF get_asset_property_tax_info%ISOPEN THEN
      CLOSE get_asset_property_tax_info;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               g_pkg_name,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_contract_property_tax_info%ISOPEN THEN
      CLOSE get_contract_property_tax_info;
    END IF;
    IF get_asset_contract_tax_info%ISOPEN THEN
      CLOSE get_asset_contract_tax_info;
    END IF;
    IF get_contract_lines%ISOPEN THEN
      CLOSE get_contract_lines;
    END IF;
    IF get_asset_property_tax_info%ISOPEN THEN
      CLOSE get_asset_property_tax_info;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              g_pkg_name,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              g_api_type);
    WHEN OTHERS THEN
    IF get_contract_property_tax_info%ISOPEN THEN
      CLOSE get_contract_property_tax_info;
    END IF;
    IF get_asset_contract_tax_info%ISOPEN THEN
      CLOSE get_asset_contract_tax_info;
    END IF;
    IF get_contract_lines%ISOPEN THEN
      CLOSE get_contract_lines;
    END IF;
    IF get_asset_property_tax_info%ISOPEN THEN
      CLOSE get_asset_property_tax_info;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              g_pkg_name,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              g_api_type);
  END sync_contract_property_tax;

END OKL_LA_PROPERTY_TAX_PVT;

/
