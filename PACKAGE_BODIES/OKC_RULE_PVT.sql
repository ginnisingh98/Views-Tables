--------------------------------------------------------
--  DDL for Package Body OKC_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RULE_PVT" AS
/* $Header: OKCCRULB.pls 120.1 2005/08/16 16:22:39 jkodiyan noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_EXCEPTION_CANNOT_DELETE    EXCEPTION;
  G_NO_RULE_ALLOWED            EXCEPTION;
  G_CANNOT_DELETE_MASTER       CONSTANT VARCHAR2(200) := 'OKC_CANNOT_DELETE_MASTER';
  g_package                    varchar2(33) := '  OKC_RULE_PVT.';

-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

  -- Start of comments
  --
  -- Procedure Name  : update_minor_version
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE update_minor_version(p_chr_id NUMBER) IS
    l_api_version                NUMBER := 1;
    l_init_msg_list              VARCHAR2(1) := 'F';
    x_return_status              VARCHAR2(1);
    x_msg_count                  NUMBER;
    x_msg_data                   VARCHAR2(2000);
    x_out_rec                    OKC_CVM_PVT.cvmv_rec_type;
    l_cvmv_rec                   OKC_CVM_PVT.cvmv_rec_type;
   --
   l_proc varchar2(72) := g_package||'update_minor_version';
   --
  BEGIN

    -- assign/populate contract header id
    l_cvmv_rec.chr_id := p_chr_id;

    OKC_CVM_PVT.update_contract_version(
      p_api_version    => l_api_version,
      p_init_msg_list  => l_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cvmv_rec       => l_cvmv_rec,
      x_cvmv_rec       => x_out_rec);

    IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --Bug 4149131 Raising the validation so that
    --it will be handled in the calling API.
    RAISE;
  WHEN OTHERS THEN


    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_minor_version;

  -- Start of comments
  --
  -- Procedure Name  : is_rule_allowed
  -- Description     : Checks if rules are allowed for contracts class,
  -- Business Rules  :
  -- Version         : 1.0
  -- End of comments

Procedure is_rule_allowed(p_id number,
					 p_object          varchar2,
					 P_rule_code       varchar2,
					 x_return       out NOCOPY varchar2,
					 x_rule_meaning out NOCOPY varchar2) IS

 Cursor cur_k_appl_id is
   Select application_id
   from okc_k_headers_b
   where id = p_id;


 CURSOR cur_rul_appl_id IS
   SELECT application_id,meaning
   FROM   okc_rule_defs_v
   where rule_code = P_rule_code;

   k_appl_id number;
   r_appl_id number;

Begin

   Open cur_k_appl_id;
   Fetch cur_k_appl_id into k_appl_id;
   Close cur_k_appl_id;

--For OKS ks no rule/rule group allowed
   If k_appl_id =515 Then
       x_return :='N';
--For OKL ks , rule groups are allowed
--rules for OKC categories are not allowed

   Elsif k_appl_id = 540 and p_object='RUL' Then
        open cur_rul_appl_id;
        Fetch cur_rul_appl_id into r_appl_id,x_rule_meaning;
        Close cur_rul_appl_id;
        If r_appl_id = 510 Then
          x_return :='N';
        End If ;
   End If;

   If x_return is null then
	x_return := 'Y';
   End If;

End Is_rule_allowed;

--
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type,
    p_euro_conv_yn                 IN VARCHAR2)
  IS

    l_rulv_rec okc_rule_pub.rulv_rec_type;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_euro_rate         NUMBER;
    l_rate              NUMBER;
    l_meaning      VARCHAR2(80) ;
    lx_return_status	VARCHAR2(1) ;

    CURSOR l_chr_csr IS
      SELECT chr.*
        FROM OKC_K_HEADERS_B chr
       WHERE chr.id = p_rulv_rec.dnz_chr_id;
    l_chr_rec l_chr_csr%ROWTYPE;
   --
   l_proc varchar2(72) := g_package||'create_rule';
   --
  BEGIN

    l_rulv_rec := p_rulv_rec;

    --/Rules Migration/
    Is_rule_allowed(p_rulv_rec.dnz_chr_id,
				'RUL',
				p_rulv_rec.rule_information_category,
				lx_return_status,
				l_meaning);

    If lx_return_status = 'N' Then
	 Raise G_NO_RULE_ALLOWED;
    End If;
--
    IF p_euro_conv_yn = 'Y' THEN
      IF p_rulv_rec.rule_information_category = 'CVN' THEN

        -- Get Contract Header info
        OPEN l_chr_csr;
        FETCH l_chr_csr INTO l_chr_rec;
        CLOSE l_chr_csr;

        okc_currency_api.get_rate(
          p_FROM_CURRENCY   => l_chr_rec.currency_code
         ,p_TO_CURRENCY     => okc_currency_api.get_ou_currency(l_chr_rec.authoring_org_id)
         ,p_CONVERSION_DATE => fnd_date.canonical_to_date(l_rulv_rec.rule_information2)
         ,p_CONVERSION_TYPE => l_rulv_rec.object1_id1
         ,x_CONVERSION_RATE => l_rate
         ,x_EURO_RATE       => l_euro_rate
         ,x_return_status   => l_return_status);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          RETURN;
        END IF;

        l_rulv_rec.rule_information1 := l_rate;

        IF l_euro_rate IS NOT NULL THEN
          l_rulv_rec.rule_information3 := p_rulv_rec.rule_information1;
          l_rulv_rec.rule_information1 := l_euro_rate;
        END IF;
      END IF;
    END IF;

    OKC_RUL_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec,
      x_rulv_rec      => x_rulv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rulv_rec.dnz_chr_id);
    END IF;

  EXCEPTION
  WHEN okc_currency_api.no_rate then

    x_return_status := OKC_API.g_ret_sts_error;
    OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_NO_CONVERSION_RATE');
  WHEN okc_currency_api.invalid_currency then

    x_return_status := OKC_API.g_ret_sts_error;
    OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_INVALID_CURRENCY');

  WHEN G_NO_RULE_ALLOWED then
      x_return_status := OKC_API.g_ret_sts_error;
	 OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_NO_RUL_ALLOWED','VALUE1',l_meaning);

  --Bug 4149131/4190812 Added logic to handle G_EXCEPTION_HALT_VALIDATION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status := OKC_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN


    IF l_chr_csr%ISOPEN THEN
      CLOSE l_chr_csr;
    END IF;
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
  END create_rule;

  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'update_rule';
   --/Rules Migration/
   l_meaning      VARCHAR2(80) ;
   lx_return_status	VARCHAR2(1) ;
  BEGIN

--/Rules Migration/
    Is_rule_allowed(p_rulv_rec.dnz_chr_id,
                    'RUL',
                    p_rulv_rec.rule_information_category,
                    lx_return_status,
                    l_meaning);

    If lx_return_status = 'N' Then
      Raise G_NO_RULE_ALLOWED;
    End If;
--

   OKC_RUL_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec,
      x_rulv_rec      => x_rulv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rulv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
  WHEN G_NO_RULE_ALLOWED then
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_NO_RUL_ALLOWED','VALUE1',l_meaning);

  --Bug 4149131/4190812 Added logic to handle G_EXCEPTION_HALT_VALIDATION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
  END update_rule;

  PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS

    l_dummy_var VARCHAR(1) := NULL;
    i NUMBER := 0;
    CURSOR l_ctiv_csr IS
      SELECT *
        FROM OKC_COVER_TIMES_V ctiv
       WHERE ctiv.RUL_ID = p_rulv_rec.id;

    CURSOR l_atnv_csr IS
      SELECT 'x'
        FROM OKC_ARTICLE_TRANS_V atnv
       WHERE atnv.RUL_ID = p_rulv_rec.id;

    CURSOR l_rilv_csr IS
      SELECT *
        FROM OKC_REACT_INTERVALS_V rilv
       WHERE rilv.RUL_ID = p_rulv_rec.id;
    l_ctiv_tbl ctiv_tbl_type;
    l_rilv_tbl rilv_tbl_type;

  L_RIC OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE;

  CURSOR l_ric_csr IS
    SELECT RULE_INFORMATION_CATEGORY
    FROM OKC_RULES_B
    WHERE ID = p_rulv_rec.id;
  l_col_vals  okc_time_util_pub.t_col_vals;


   --
   l_proc varchar2(72) := g_package||'delete_rule';
   --
  BEGIN

     OPEN l_atnv_csr;
    FETCH l_atnv_csr into l_dummy_var;
    CLOSE l_atnv_csr;
    IF l_dummy_var = 'x' THEN
      RAISE G_EXCEPTION_CANNOT_DELETE;
    END IF;

    --populate the Foreign key of the detail
    FOR l_ctiv_rec in l_ctiv_csr LOOP
      i := i + 1;
      l_ctiv_tbl(i).rul_id := l_ctiv_rec.rul_id;
      l_ctiv_tbl(i).tve_id := l_ctiv_rec.tve_id;
    END LOOP;

    IF i > 0 THEN
      --Delete the details
      -- call Public delete procedure
      OKC_RULE_PUB.delete_cover_time(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_ctiv_tbl      => l_ctiv_tbl);

      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        -- stop delete process
        RETURN;
      END IF;
    END IF;

    i := 0;
    --populate the Foreign key of the detail
    FOR l_rilv_rec in l_rilv_csr LOOP
      i := i + 1;
      l_rilv_tbl(i).rul_id := l_rilv_rec.rul_id;
      l_rilv_tbl(i).tve_id := l_rilv_rec.tve_id;
    END LOOP;

    IF i > 0 THEN
      --Delete the details
      -- call Public delete procedure
      OKC_RULE_PUB.delete_react_interval(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_rilv_tbl      => l_rilv_tbl);

      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        -- stop delete process
        RETURN;
      END IF;
    END IF;
--
-- added for tve_id
--
   open l_ric_csr;
   fetch l_ric_csr into L_RIC;
   close l_ric_csr;

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(L_RIC);
p_dff_name := okc_rld_pvt.get_dff_name(L_RIC);

--   okc_time_util_pub.get_dff_column_values( p_app_id => 510,          -- /striping/
   okc_time_util_pub.get_dff_column_values( p_app_id => p_appl_id,
--                      p_dff_name => 'OKC Rule Developer DF',          -- /striping/
                      p_dff_name => p_dff_name,
                      p_rdf_code => l_ric,
                      p_fvs_name =>'OKC_TIMEVALUES',
                      p_rule_id  =>p_rulv_rec.id,
                      p_col_vals => l_col_vals,
                      p_no_of_cols =>i );
   if (l_col_vals.COUNT>0) then
     i := l_col_vals.FIRST;
     LOOP
       if (l_col_vals(i).col_value is not NULL) then
         okc_time_pub.delete_timevalues_n_tasks(
           p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
	     p_tve_id	   => l_col_vals(i).col_value);
         IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           -- stop delete process
           RETURN;
         END IF;
     end if;
     EXIT WHEN (i=l_col_vals.LAST);
     i := l_col_vals.NEXT(i);
    END LOOP;
  end if;
--
-- /tve_id
--
    OKC_RUL_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rulv_rec.dnz_chr_id);
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_CANNOT_DELETE THEN

    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_CANNOT_DELETE_MASTER);
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

  --Bug 4149131/4190812 Added logic to handle G_EXCEPTION_HALT_VALIDATION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
    -- verify that cursor was closed
    IF l_ctiv_csr%ISOPEN THEN
      CLOSE l_ctiv_csr;
    END IF;
    IF l_atnv_csr%ISOPEN THEN
      CLOSE l_atnv_csr;
    END IF;
    IF l_rilv_csr%ISOPEN THEN
      CLOSE l_rilv_csr;
    END IF;
  END delete_rule;

  PROCEDURE lock_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_rule';
   --
  BEGIN

    OKC_RUL_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec);

  END lock_rule;

  PROCEDURE validate_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'validate_rule';
   --
  BEGIN

    OKC_RUL_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec);

  END validate_rule;

  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type)
  IS
   --
   l_proc varchar2(72) := g_package||'create_rule_group';
   --
    l_meaning      VARCHAR2(80) ;
    lx_return_status     VARCHAR2(1) ;

  BEGIN

    Is_rule_allowed(p_rgpv_rec.dnz_chr_id,
                    'RGP',
                    NULL,
                    lx_return_status,
                    l_meaning);

    If lx_return_status = 'N' Then
      Raise G_NO_RULE_ALLOWED;
    End If;

    OKC_RGP_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rgpv_rec.dnz_chr_id);
    END IF;


  EXCEPTION
  WHEN G_NO_RULE_ALLOWED then
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_NO_RGP_ALLOWED');

   --Bug 4149131/4190812 Added logic to handle G_EXCEPTION_HALT_VALIDATION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
  END create_rule_group;

  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'update_rule_group';
   --/Rules Migration/
   l_meaning      VARCHAR2(80) ;
   lx_return_status	VARCHAR2(1) ;
  BEGIN

   --/ Rules Migration/

    Is_rule_allowed(p_rgpv_rec.dnz_chr_id,
                    'RGP',
                    NULL,
                    lx_return_status,
                    l_meaning);

    If lx_return_status = 'N' Then
      Raise G_NO_RULE_ALLOWED;
    End If;

  --

    OKC_RGP_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rgpv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
  WHEN G_NO_RULE_ALLOWED then
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_NO_RGP_ALLOWED');

  --Bug 4149131/4190812 Added logic to handle G_EXCEPTION_HALT_VALIDATION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS

    i NUMBER;

    CURSOR l_rgpv_csr IS
      SELECT rgp_type
        FROM OKC_RULE_GROUPS_B rgpv
       WHERE rgpv.ID = p_rgpv_rec.id;
    l_rgpv_rec l_rgpv_csr%ROWTYPE;

    CURSOR l_prgpv_csr IS
      SELECT id
        FROM OKC_RULE_GROUPS_B rgpv
       WHERE rgpv.PARENT_RGP_ID = p_rgpv_rec.id;
    l_prgpv_rec l_prgpv_csr%ROWTYPE;

    CURSOR l_rulv_csr IS
      SELECT id
        FROM OKC_RULES_B rulv
       WHERE rulv.RGP_ID = p_rgpv_rec.id;
    l_rulv_rec l_rulv_csr%ROWTYPE;
    l_rulv_tbl OKC_RULE_PUB.rulv_tbl_type;

    CURSOR l_rmpv_csr IS
      SELECT id
        FROM OKC_RG_PARTY_ROLES_V rmpv
       WHERE rmpv.RGP_ID = p_rgpv_rec.id;
    l_rmpv_rec l_rmpv_csr%ROWTYPE;
    l_rmpv_tbl OKC_RULE_PUB.rmpv_tbl_type;
   --
   l_proc varchar2(72) := g_package||'delete_rule_group';
   --
  BEGIN


    -- check whether detail records exists
     OPEN l_prgpv_csr;
    FETCH l_prgpv_csr into l_prgpv_rec;
    CLOSE l_prgpv_csr;
    IF l_prgpv_rec.id IS NOT NULL THEN
      RAISE G_EXCEPTION_CANNOT_DELETE;
    END IF;
      i := 0;
      --populate the Foreign key of the detail
      FOR l_rmpv_rec in l_rmpv_csr LOOP
        i := i + 1;
        l_rmpv_tbl(i).id := l_rmpv_rec.id;
        l_rmpv_tbl(i).dnz_chr_id := p_rgpv_rec.dnz_chr_id;
      END LOOP;

      IF i > 0 THEN
        --Delete the details
        -- call Public delete procedure
        OKC_RULE_PUB.delete_rg_mode_pty_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rmpv_tbl      => l_rmpv_tbl);

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          -- stop delete process
          RETURN;
        END IF;
      END IF;

      i := 0;
      --populate the Foreign key of the detail
      FOR l_rulv_rec in l_rulv_csr LOOP
        i := i + 1;
        l_rulv_tbl(i).id := l_rulv_rec.id;
        l_rulv_tbl(i).dnz_chr_id := p_rgpv_rec.dnz_chr_id;
      END LOOP;

      IF i > 0 THEN
        --Delete the details
        -- call Public delete procedure
        OKC_RULE_PUB.delete_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_tbl      => l_rulv_tbl);

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          -- stop delete process
          RETURN;
        END IF;
      END IF;

    OKC_RGP_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rgpv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
  WHEN G_EXCEPTION_CANNOT_DELETE THEN


    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_CANNOT_DELETE_MASTER);
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

  --Bug 4149131/4190812 Added logic to handle G_EXCEPTION_HALT_VALIDATION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
    -- verify that cursor was closed
    IF l_rgpv_csr%ISOPEN THEN
      CLOSE l_rgpv_csr;
    END IF;
    IF l_prgpv_csr%ISOPEN THEN
      CLOSE l_prgpv_csr;
    END IF;
    IF l_rulv_csr%ISOPEN THEN
      CLOSE l_rulv_csr;
    END IF;
    IF l_rmpv_csr%ISOPEN THEN
      CLOSE l_rmpv_csr;
    END IF;
  END delete_rule_group;

  PROCEDURE lock_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_rule_group';
   --
  BEGIN




    OKC_RGP_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);
  END lock_rule_group;

  PROCEDURE validate_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'validate_rule_group';
   --
  BEGIN




    OKC_RGP_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);




  END validate_rule_group;

  PROCEDURE create_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type)
  IS
   --
   l_proc varchar2(72) := g_package||'create_rg_mode_pty_role';
   --
  BEGIN




    OKC_RMP_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec,
      x_rmpv_rec      => x_rmpv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rmpv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END create_rg_mode_pty_role;

  PROCEDURE update_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'update_rg_mode_pty_role';
   --
  BEGIN




    OKC_RMP_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec,
      x_rmpv_rec      => x_rmpv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rmpv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END update_rg_mode_pty_role;

  PROCEDURE delete_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'delete_rg_mode_pty_role';
   --
  BEGIN




    OKC_RMP_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rmpv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END delete_rg_mode_pty_role;

  PROCEDURE lock_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_rg_mode_pty_role';
   --
  BEGIN




    OKC_RMP_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec);




  END lock_rg_mode_pty_role;

  PROCEDURE validate_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'validate_rg_mode_pty_role';
   --
  BEGIN




    OKC_RMP_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec);




  END validate_rg_mode_pty_role;

  PROCEDURE create_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type)
  IS
   --
   l_proc varchar2(72) := g_package||'create_cover_time';
   --
  BEGIN




    OKC_CTI_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec,
      x_ctiv_rec      => x_ctiv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_ctiv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END create_cover_time;

  PROCEDURE update_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'update_cover_time';
   --
  BEGIN




    OKC_CTI_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec,
      x_ctiv_rec      => x_ctiv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_ctiv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END update_cover_time;

  PROCEDURE delete_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'delete_cover_time';
   --
  BEGIN




    OKC_CTI_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_ctiv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END delete_cover_time;

  PROCEDURE lock_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_cover_time';
   --
  BEGIN




    OKC_CTI_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec);
  END lock_cover_time;

  PROCEDURE validate_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'validate_cover_time';
   --
  BEGIN




    OKC_CTI_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec);




  END validate_cover_time;

  PROCEDURE create_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type)
  IS
   --
   l_proc varchar2(72) := g_package||'create_react_interval';
   --
  BEGIN




    OKC_RIL_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec,
      x_rilv_rec      => x_rilv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rilv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END create_react_interval;

  PROCEDURE update_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'update_react_interval';
   --
  BEGIN




    OKC_RIL_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec,
      x_rilv_rec      => x_rilv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rilv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END update_react_interval;

  PROCEDURE delete_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'delete_react_interval';
   --
  BEGIN




    OKC_RIL_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec);

    -- Update minor version
    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      update_minor_version(p_rilv_rec.dnz_chr_id);
    END IF;




  EXCEPTION
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
  END delete_react_interval;

  PROCEDURE lock_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_react_interval';
   --
  BEGIN




    OKC_RIL_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec);
  END lock_react_interval;

  PROCEDURE validate_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'validate_react_interval';
   --
  BEGIN




    OKC_RIL_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec);




  END validate_react_interval;

  PROCEDURE add_language IS
   --
   l_proc varchar2(72) := g_package||'add_language';
   --
  BEGIN




    OKC_RUL_PVT.add_language;
    OKC_RGP_PVT.add_language;




  END add_language;

END OKC_RULE_PVT;

/
