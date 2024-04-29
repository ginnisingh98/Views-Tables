--------------------------------------------------------
--  DDL for Package Body OKL_VP_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_RULE_PVT" AS
/* $Header: OKLRRLGB.pls 120.7 2005/11/14 04:55:51 gboomina noship $ */
  G_EXCEPTION_CANNOT_DELETE    EXCEPTION;
  G_CANNOT_DELETE_MASTER       CONSTANT VARCHAR2(200) := 'OKC_CANNOT_DELETE_MASTER';
  G_API_TYPE	VARCHAR2(3) := 'PVT';

  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type)
  IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'create_rule_group';
  l_cnt_rg      NUMBER(9) := 0;
  CURSOR csr_chr_rg_cnt IS
  SELECT count('X')
  FROM okc_rule_groups_b
  WHERE rgd_code =  p_rgpv_rec.rgd_code
  AND   (dnz_chr_id =  p_rgpv_rec.chr_id and cle_id IS NULL)
  AND       id <> NVL(p_rgpv_rec.id,-1);

  BEGIN
  -- Not null Validation for Terms and Conditions
  IF ((p_rgpv_rec.rgd_code = OKL_API.G_MISS_CHAR) OR (p_rgpv_rec.rgd_code IS NULL)) THEN
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_TERMS_AND_COND_REQUIRED');
    x_return_status :=okl_api.g_ret_sts_error;
    RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

  -- Same Terms and Condition can be attched only 1 time to the contract.
  IF p_rgpv_rec.chr_id IS NOT NULL THEN
    OPEN csr_chr_rg_cnt;
    FETCH csr_chr_rg_cnt INTO l_cnt_rg;
    CLOSE csr_chr_rg_cnt;

    IF l_cnt_rg <> 0 THEN
      --set error message
      OKC_API.set_message(
           p_app_name     => G_APP_NAME,
           p_msg_name     => 'OKL_DUP_TERMS_AND_COND',
           p_token1       => 'RULEGROUP',
           p_token1_value => p_rgpv_rec.rgd_code);

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      -- halt validation
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

  OKL_OKC_MIGRATION_A_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);

   -- Bug# 3477560
   IF (p_rgpv_rec.dnz_chr_id is NOT NULL) AND
        (p_rgpv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => p_rgpv_rec.dnz_chr_id);

      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;
    END IF;

  EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.G_RET_STS_ERROR;
    /*   x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
    */
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rule_group;

  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS

    -- gboomina: Added for bug 4723775 to populate mandatory values
    -- which are getting nullified in the pl/sql rosetta wrapper call
    -- START of code changes
    l_rgpv_rec rgpv_rec_type := p_rgpv_rec;
    CURSOR csr_init_attr_column(p_id IN NUMBER) IS
    SELECT chr_id,
           dnz_chr_id,
           created_by,
           creation_date
    FROM okc_rule_groups_b
    WHERE ID = p_id ;

    l_chr_id                            okc_k_headers_b.id%TYPE;
    l_dnz_chr_id                        okc_k_headers_b.id%TYPE;
    l_created_by                        okc_rule_groups_b.created_by%type;
    l_creation_date                     okc_rule_groups_b.creation_date%type;
    -- END of code changes for bug 4723775

  BEGIN
    -- gboomina: bug fix for populating the mandatory fields that are
    -- accidentally being nullified in the pl/sql wrapper of okl_vp_rule_pub_w
    -- since these fields are not updatable in the ui, derive the values from the
    -- database only when the passed in id ( rgp_id ) is not null and is also not
    -- equal to okl_api.g_miss_num
    -- START of code changes for bug 4723775
    IF(p_rgpv_rec.id IS NOT NULL AND p_rgpv_rec.id <> OKL_API.G_MISS_NUM)THEN
      OPEN csr_init_attr_column(p_rgpv_rec.id);
      FETCH csr_init_attr_column INTO l_chr_id, l_dnz_chr_id, l_created_by, l_creation_date;
      CLOSE csr_init_attr_column;

      l_rgpv_rec.chr_id := l_chr_id;
      l_rgpv_rec.dnz_chr_id := l_dnz_chr_id;
      l_rgpv_rec.created_by := l_created_by;
      l_rgpv_rec.creation_date := l_creation_date;

    OKL_OKC_MIGRATION_A_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- END of code changes for bug 4723775

    -- Bug# 3477560
    IF (x_rgpv_rec.dnz_chr_id is NOT NULL) AND
        (x_rgpv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => x_rgpv_rec.dnz_chr_id);

      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;
    END IF;

  EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rule_group;

PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
    i NUMBER;


     -- Bug# 3477560
     ln_chr_id                    OKC_RULE_GROUPS_B.DNZ_CHR_ID%TYPE;
     CURSOR get_chr_id(p_rgd_id OKC_RULE_GROUPS_B.ID%TYPE)
     IS
     SELECT to_char(rgd.dnz_chr_id)
     FROM okc_rule_groups_b rgd
     WHERE rgd.id = p_rgd_id;

BEGIN

    -- Bug# 3477560
    OPEN get_chr_id(p_rgpv_rec.Id);
    FETCH get_chr_id INTO ln_chr_id;
    CLOSE get_chr_id;

    OKL_OKC_MIGRATION_A_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);

    -- Bug# 3477560
    IF (ln_chr_id is NOT NULL) AND
       (ln_chr_id <> OKL_API.G_MISS_NUM) THEN

       --cascade edit status on to lines
       okl_contract_status_pub.cascade_lease_status_edit
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_chr_id          => ln_chr_id);

       If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
         raise OKL_API.G_EXCEPTION_ERROR;
       End If;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_CANNOT_DELETE THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_CANNOT_DELETE_MASTER);
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END delete_rule_group;

  PROCEDURE process_vrs_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_rgp_id                       IN NUMBER,
    p_vrs_tbl                      IN vrs_tbl_type) IS

    l_api_name	       VARCHAR2(30) := 'process_vrs_rules';
    l_api_version      CONSTANT NUMBER	  := 1.0;

    i NUMBER;
    l_rgp_id number;
    l_cpl_id VARCHAR2(250) := null;
    l_rle_code VARCHAR2(50) := null;

    lp_vrs_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_vrs_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;

    lp_vrs_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_vrs_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    cursor RULE_GROUP_CSR(P_CHR_ID IN NUMBER, P_RGD_CODE IN VARCHAR2) is
        SELECT ID
        FROM OKC_RULE_GROUPS_B
        WHERE  CHR_ID     = P_CHR_ID AND
               DNZ_CHR_ID = P_CHR_ID AND
               CLE_ID     IS NULL    AND
           RGD_CODE   = P_RGD_CODE;

    cursor RULE_CSR(P_RUL_ID IN NUMBER) is
        SELECT RULE_INFORMATION1
        FROM OKC_RULES_B
        WHERE  ID = P_RUL_ID;

    cursor RLE_CSR(P_CPL_ID IN VARCHAR2) is
        SELECT RLE_CODE
        FROM OKC_K_PARTY_ROLES_B
        WHERE  ID = TO_NUMBER(P_CPL_ID);

  BEGIN

      x_return_status := OKC_API.START_ACTIVITY(
    			p_api_name      => l_api_name,
    			p_pkg_name      => g_pkg_name,
    			p_init_msg_list => p_init_msg_list,
    			l_api_version   => l_api_version,
    			p_api_version   => p_api_version,
    			p_api_type      => g_api_type,
    			x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    l_rgp_id := null;
    open  RULE_GROUP_CSR(p_chr_id,'VGLRS');
    fetch RULE_GROUP_CSR into l_rgp_id;
    close RULE_GROUP_CSR;

    IF (l_rgp_id IS NULL) THEN

        lp_vrs_rgpv_rec.id := NULL;
        lp_vrs_rgpv_rec.rgd_code := 'VGLRS';
        lp_vrs_rgpv_rec.dnz_chr_id := p_chr_id;
        lp_vrs_rgpv_rec.chr_id := p_chr_id;
        lp_vrs_rgpv_rec.rgp_type := 'KRG';

        OKL_RULE_PUB.create_rule_group(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rgpv_rec       => lp_vrs_rgpv_rec,
            x_rgpv_rec       => lx_vrs_rgpv_rec);

          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

      l_rgp_id := lx_vrs_rgpv_rec.id;

     END IF;

     If (p_vrs_tbl.COUNT > 0) Then

     	 i := p_vrs_tbl.FIRST;

     	 IF(p_rgp_id IS NOT NULL) THEN
     	   l_rgp_id := p_rgp_id;
     	 END IF;

	 LOOP

         IF (p_vrs_tbl(i).rul_id IS NULL ) THEN

         lp_vrs_rulv_rec.id := NULL;
         lp_vrs_rulv_rec.rgp_id := l_rgp_id;
         lp_vrs_rulv_rec.rule_information_category := 'VGLRSP';
         lp_vrs_rulv_rec.dnz_chr_id := p_chr_id;
         lp_vrs_rulv_rec.rule_information1 := p_vrs_tbl(i).rule_info1;
         lp_vrs_rulv_rec.rule_information2 := p_vrs_tbl(i).rule_info2;
         lp_vrs_rulv_rec.WARN_YN := 'N';
         lp_vrs_rulv_rec.STD_TEMPLATE_YN := 'N';

         OKL_RULE_PUB.create_rule(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_rulv_rec       => lp_vrs_rulv_rec,
             x_rulv_rec       => lx_vrs_rulv_rec);

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

           lx_vrs_rulv_rec.id := lx_vrs_rulv_rec.id;

        ELSIF (p_vrs_tbl(i).rul_id IS NOT NULL ) THEN

         l_cpl_id := null;
         OPEN  RULE_CSR(p_vrs_tbl(i).rul_id);
         FETCH RULE_CSR into l_cpl_id;
         CLOSE RULE_CSR;

         IF(l_cpl_id IS NOT NULL) THEN
          l_rle_code := null;
          OPEN  RLE_CSR(l_cpl_id);
          FETCH RLE_CSR into l_rle_code;
          CLOSE RLE_CSR;
         END IF;

         IF(l_rle_code IS NOT NULL AND l_rle_code = 'LESSOR') THEN
           IF(p_vrs_tbl(i).rle_code <> 'LESSOR' ) THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
            			p_msg_name => 'OKL_INVALID_ROLE_UPDATE');
	    x_return_status := OKC_API.g_ret_sts_error;
	    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
         END IF;

         lp_vrs_rulv_rec.id := p_vrs_tbl(i).rul_id;
         lp_vrs_rulv_rec.rgp_id := l_rgp_id;
         lp_vrs_rulv_rec.rule_information_category := 'VGLRSP';
         lp_vrs_rulv_rec.dnz_chr_id := p_chr_id;
         lp_vrs_rulv_rec.rule_information1 := p_vrs_tbl(i).rule_info1;
         lp_vrs_rulv_rec.rule_information2 := p_vrs_tbl(i).rule_info2;
         lp_vrs_rulv_rec.WARN_YN := 'N';
         lp_vrs_rulv_rec.STD_TEMPLATE_YN := 'N';

         OKL_RULE_PUB.update_rule(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_rulv_rec       => lp_vrs_rulv_rec,
             x_rulv_rec       => lx_vrs_rulv_rec);

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

          END IF;


       EXIT WHEN (i = p_vrs_tbl.LAST);
      		i := p_vrs_tbl.NEXT(i);
       END LOOP;


    END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      WHEN OTHERS THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OTHERS',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END;

PROCEDURE delete_vrs_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rul_id                       IN  NUMBER) IS

    l_api_name	       VARCHAR2(30) := 'delete_vrs_rule';
    l_api_version      CONSTANT NUMBER	  := 1.0;

    i NUMBER;
    l_cpl_id VARCHAR2(250) := null;
    l_rle_code VARCHAR2(50) := null;

    lp_vrs_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    cursor RULE_CSR(P_RUL_ID IN NUMBER) is
        SELECT RULE_INFORMATION1
        FROM OKC_RULES_B
        WHERE  ID = P_RUL_ID;

    cursor RLE_CSR(P_CPL_ID IN VARCHAR2) is
        SELECT RLE_CODE
        FROM OKC_K_PARTY_ROLES_B
        WHERE  ID = TO_NUMBER(P_CPL_ID);

BEGIN

        x_return_status := OKC_API.START_ACTIVITY(
    			p_api_name      => l_api_name,
    			p_pkg_name      => g_pkg_name,
    			p_init_msg_list => p_init_msg_list,
    			l_api_version   => l_api_version,
    			p_api_version   => p_api_version,
    			p_api_type      => g_api_type,
    			x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        l_cpl_id := null;
        OPEN  RULE_CSR(p_rul_id);
        FETCH RULE_CSR into l_cpl_id;
        CLOSE RULE_CSR;

        IF(l_cpl_id is NOT NULL) THEN
         l_rle_code := null;
         OPEN  RLE_CSR(l_cpl_id);
         FETCH RLE_CSR into l_rle_code;
         CLOSE RLE_CSR;
        END IF;

        IF(l_rle_code IS NOT NULL AND l_rle_code = 'LESSOR') THEN
           x_return_status := OKC_API.g_ret_sts_error;
	   OKC_API.SET_MESSAGE(p_app_name => g_app_name,
	                          p_msg_name => 'OKL_INVALID_ROLE_DELETE');
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        lp_vrs_rulv_rec.id := p_rul_id;

        OKL_RULE_PUB.delete_rule(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_rulv_rec       => lp_vrs_rulv_rec
             );

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      WHEN OTHERS THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OTHERS',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END;

PROCEDURE validate_vrs_percent(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER
) IS

    l_api_name	       VARCHAR2(30) := 'validate_vrs_percent';
    l_api_version      CONSTANT NUMBER	  := 1.0;

    l_percent NUMBER;

    cursor RESI_PERCENT_CSR is
        SELECT sum(to_number(nvl(RULE_INFORMATION2,0)))
        FROM OKC_RULES_B rul,
             okc_rule_groups_b rgp
        WHERE  rgp.ID = rul.rgp_id
        AND    rgp.dnz_chr_id = rul.dnz_chr_id
        AND    rgp.chr_id = p_chr_id;

BEGIN

        x_return_status := OKC_API.START_ACTIVITY(
    			p_api_name      => l_api_name,
    			p_pkg_name      => g_pkg_name,
    			p_init_msg_list => p_init_msg_list,
    			l_api_version   => l_api_version,
    			p_api_version   => p_api_version,
    			p_api_type      => g_api_type,
    			x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        l_percent := null;
        OPEN  RESI_PERCENT_CSR;
        FETCH RESI_PERCENT_CSR into l_percent;
        CLOSE RESI_PERCENT_CSR;

        IF(l_percent IS NULL OR l_percent <> 100) THEN
           x_return_status := OKC_API.g_ret_sts_error;
	   OKC_API.SET_MESSAGE(p_app_name => g_app_name,
	                          p_msg_name => 'OKL_VN_INCORRECT_RESIDUAL');
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      WHEN OTHERS THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OTHERS',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END;

END OKL_VP_RULE_PVT;

/
