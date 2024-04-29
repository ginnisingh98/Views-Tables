--------------------------------------------------------
--  DDL for Package Body OKC_RGP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RGP_PVT" AS
/* $Header: OKCSRGPB.pls 120.1 2008/02/29 06:05:43 veramach ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  **************************/
  FUNCTION Validate_Attributes
    (p_rgpv_rec IN  rgpv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEn               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN	        CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_VIEW                        CONSTANT VARCHAR2(200) := 'OKC_RULE_GROUPS_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  g_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_rgd_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rgd_code(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_scs_code      IN VARCHAR2,
    p_rgpv_rec      IN    rgpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    l_cnt_rg      NUMBER(9) := 0;

-- Bug 1367397: changed subclass views in cursor to base table

    CURSOR l_rgdv_csr IS
      SELECT 'x'
        FROM FND_LOOKUP_VALUES rgdv
       WHERE (p_rgpv_rec.rgd_code IN
              (SELECT srdv.RGD_CODE
                 FROM OKC_SUBCLASS_RG_DEFS srdv,
                      OKC_SUBCLASSES_B scsv,
                      OKC_K_HEADERS_B chrv
                WHERE srdv.SCS_CODE = scsv.CODE
                  AND scsv.CODE     = chrv.SCS_CODE
                  AND chrv.ID       = p_rgpv_rec.dnz_chr_id) OR
              (p_rgpv_rec.rgp_type = 'SRG'))
         AND rgdv.LOOKUP_CODE = p_rgpv_rec.rgd_code
         AND rgdv.lookup_type = 'OKC_RULE_GROUP_DEF';

-- The following cursor has been changed by MSENGUPT on 12/08/2001 to use dnz_chr_id instead of chr_id

CURSOR csr_chr_rg_cnt IS
SELECT count('X')
FROM okc_rule_groups_b
WHERE rgd_code =  p_rgpv_rec.rgd_code
  AND   (dnz_chr_id =  p_rgpv_rec.chr_id and cle_id IS NULL)
  AND       id <> NVL(p_rgpv_rec.id,-1);

CURSOR csr_cle_rg_cnt IS
SELECT count('X')
FROM okc_rule_groups_b
WHERE rgd_code =  p_rgpv_rec.rgd_code
  AND   (dnz_chr_id =  p_rgpv_rec.dnz_chr_id and cle_id = p_rgpv_rec.cle_id)
  AND       id <> NVL(p_rgpv_rec.id,-1);

CURSOR csr_rg_subject_object (p_scs_code IN VARCHAR2, p_rgd_code IN VARCHAR2) IS
select 'x' from okc_rg_role_defs rrd,
      okc_subclass_rg_defs srd
where srd_id = srd.id
 and scs_code = p_scs_code
 and rgd_code = p_rgd_code
 and rownum < 2;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rgpv_rec.rgd_code = OKC_API.G_MISS_CHAR OR
        p_rgpv_rec.rgd_code IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgd_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_rgdv_csr;
    FETCH l_rgdv_csr INTO l_dummy_var;
    CLOSE l_rgdv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
       --set error message in message stack
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgd_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

-- bug#2241759: Added by Msengupt to bypass check of single occurence of rule group for std articles or
-- if the subject object exists

    IF (p_rgpv_rec.rgp_type = 'SRG') THEN
       return;
    END IF;
    l_dummy_var    := '?';
    OPEN csr_rg_subject_object (p_scs_code, p_rgpv_rec.rgd_code);
    FETCH csr_rg_subject_object INTO l_dummy_var;
    CLOSE csr_rg_subject_object;
    IF l_dummy_var = 'x' THEN
      return;
    END IF;

-- end bug#2241759:

    -- Same Rule Group can be attched only 1 time to k-header
    IF p_rgpv_rec.chr_id IS NOT NULL THEN
      OPEN csr_chr_rg_cnt;
      FETCH csr_chr_rg_cnt INTO l_cnt_rg;
      CLOSE csr_chr_rg_cnt;

      IF l_cnt_rg <> 0 THEN
       --set error message
         OKC_API.set_message(
           p_app_name     => G_APP_NAME,
           p_msg_name     => 'OKC_DUP_RG_KH',
           p_token1       => 'RULEGROUP',
           p_token1_value => p_rgpv_rec.rgd_code);

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;

         -- halt validation
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;
    IF p_rgpv_rec.cle_id IS NOT NULL THEN
      OPEN csr_cle_rg_cnt;
      FETCH csr_cle_rg_cnt INTO l_cnt_rg;
      CLOSE csr_cle_rg_cnt;

      IF l_cnt_rg <> 0 THEN
       --set error message
         OKC_API.set_message(
           p_app_name     => G_APP_NAME,
           p_msg_name     => 'OKC_DUP_RG_KH',
           p_token1       => 'RULEGROUP',
           p_token1_value => p_rgpv_rec.rgd_code);

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;

         -- halt validation
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;




  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
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
    -- verify that cursor was closed
    IF l_rgdv_csr%ISOPEN THEN
      CLOSE l_rgdv_csr;
    END IF;
  END validate_rgd_code;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_sat_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_sat_code(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgpv_rec      IN    rgpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_satv_csr IS
      SELECT 'x'
        FROM FND_LOOKUP_VALUES satv
       WHERE satv.LOOKUP_CODE = p_rgpv_rec.sat_code
         AND satv.lookup_type = 'OKC_ARTICLE_SET';
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required for subtype SRG only
    IF (p_rgpv_rec.rgp_type = 'SRG') THEN
      -- data is required
      IF (p_rgpv_rec.sat_code = OKC_API.G_MISS_CHAR OR
          p_rgpv_rec.sat_code IS NULL) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'rgd_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- enforce foreign key
      OPEN  l_satv_csr;
      FETCH l_satv_csr INTO l_dummy_var;
      CLOSE l_satv_csr;

      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
         --set error message in message stack
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'rgd_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    ELSE
      -- sat_code must be null
      IF (p_rgpv_rec.sat_code <> OKC_API.G_MISS_CHAR OR
          p_rgpv_rec.sat_code IS NOT NULL) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'sat_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
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
    -- verify that cursor was closed
    IF l_satv_csr%ISOPEN THEN
      CLOSE l_satv_csr;
    END IF;
  END validate_sat_code;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_rgp_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rgp_type(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgpv_rec      IN    rgpv_rec_type
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rgpv_rec.rgp_type = OKC_API.G_MISS_CHAR OR
        p_rgpv_rec.rgp_type IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgp_type');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check allowed values
    IF (UPPER(p_rgpv_rec.rgp_type) NOT IN ('SRG','KRG')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgp_type');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
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
  END validate_rgp_type;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_cle_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_cle_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgpv_rec      IN    rgpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_clev_csr IS
      SELECT 'x'
        FROM OKC_K_LINES_B clev
       WHERE clev.ID = p_rgpv_rec.CLE_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is allowed for subtype KRG only
    IF (p_rgpv_rec.rgp_type = 'KRG') THEN
      -- cle id or chr id is required
      IF ((p_rgpv_rec.cle_id = OKC_API.G_MISS_NUM OR
           p_rgpv_rec.cle_id IS NULL) AND
          (p_rgpv_rec.chr_id = OKC_API.G_MISS_NUM OR
           p_rgpv_rec.chr_id IS NULL)) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'chr_id or cle_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      -- cle id or chr id can only be allowed, not both
      ELSIF ((p_rgpv_rec.cle_id <> OKC_API.G_MISS_NUM OR
              p_rgpv_rec.cle_id IS NOT NULL) AND
             (p_rgpv_rec.chr_id <> OKC_API.G_MISS_NUM OR
              p_rgpv_rec.chr_id IS NOT NULL)) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'chr_id and cle_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      --  must be null
      IF (p_rgpv_rec.cle_id <> OKC_API.G_MISS_NUM OR
          p_rgpv_rec.cle_id IS NOT NULL) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'cle_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    -- check for data
    IF (p_rgpv_rec.cle_id <> OKC_API.G_MISS_NUM OR
        p_rgpv_rec.cle_id IS NOT NULL) THEN

      -- enforce foreign key
      OPEN  l_clev_csr;
      FETCH l_clev_csr INTO l_dummy_var;
      CLOSE l_clev_csr;

      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_NO_PARENT_RECORD,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'cle_id',
          p_token2        => G_CHILD_TABLE_TOKEN,
          p_token2_value  => G_VIEW,
          p_token3        => G_PARENT_TABLE_TOKEN,
          p_token3_value  => 'OKC_CONTRACT_LINES_V');
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
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
    -- verify that cursor was closed
    IF l_clev_csr%ISOPEN THEN
      CLOSE l_clev_csr;
    END IF;
  END validate_cle_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_chr_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgpv_rec      IN    rgpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_chrv_csr IS
      SELECT 'x'
        FROM OKC_K_HEADERS_B chrv
       WHERE chrv.ID = p_rgpv_rec.CHR_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is allowed for subtype KRG only
    IF (p_rgpv_rec.rgp_type = 'SRG') THEN
      --  must be null
      IF (p_rgpv_rec.cle_id <> OKC_API.G_MISS_NUM OR
          p_rgpv_rec.cle_id IS NOT NULL) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'chr_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    -- check for data
    IF (p_rgpv_rec.chr_id <> OKC_API.G_MISS_NUM OR
        p_rgpv_rec.chr_id IS NOT NULL) THEN

      -- enforce foreign key
      OPEN  l_chrv_csr;
      FETCH l_chrv_csr INTO l_dummy_var;
      CLOSE l_chrv_csr;

      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_NO_PARENT_RECORD,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'chr_id',
          p_token2        => G_CHILD_TABLE_TOKEN,
          p_token2_value  => G_VIEW,
          p_token3        => G_PARENT_TABLE_TOKEN,
          p_token3_value  => 'OKC_CONTRACT_HEADERS_V');
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
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
    -- verify that cursor was closed
    IF l_chrv_csr%ISOPEN THEN
      CLOSE l_chrv_csr;
    END IF;
  END validate_chr_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_parent_rgp_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_parent_rgp_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgpv_rec      IN    rgpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rgpv_csr IS
      SELECT 'x'
        FROM OKC_RULE_GROUPS_B rgpv
       WHERE rgpv.ID = p_rgpv_rec.PARENT_RGP_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is allowed for subtype KRG only
    IF (p_rgpv_rec.rgp_type = 'SRG') THEN
      --  must be null
      IF (p_rgpv_rec.cle_id <> OKC_API.G_MISS_NUM OR
          p_rgpv_rec.cle_id IS NOT NULL) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'parent_rgp_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    -- check for data
    IF (p_rgpv_rec.parent_rgp_id <> OKC_API.G_MISS_NUM OR
        p_rgpv_rec.parent_rgp_id IS NOT NULL) THEN

      -- enforce foreign key
      OPEN  l_rgpv_csr;
      FETCH l_rgpv_csr INTO l_dummy_var;
      CLOSE l_rgpv_csr;

      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_NO_PARENT_RECORD,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'parent_rgp_id',
          p_token2        => G_CHILD_TABLE_TOKEN,
          p_token2_value  => G_VIEW,
          p_token3        => G_PARENT_TABLE_TOKEN,
          p_token3_value  => 'OKC_RULE_GROUPS_V');
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
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
    -- verify that cursor was closed
    IF l_rgpv_csr%ISOPEN THEN
      CLOSE l_rgpv_csr;
    END IF;
  END validate_parent_rgp_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_dnz_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_dnz_chr_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    x_scs_code OUT NOCOPY   VARCHAR2,
    p_rgpv_rec      IN    rgpv_rec_type
  ) IS
    l_scs_code   VARCHAR2(30) := NULL;
    CURSOR l_chrv_csr IS
      SELECT scs_code
        FROM OKC_K_HEADERS_B chrv
       WHERE chrv.ID = p_rgpv_rec.DNZ_CHR_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is allowed for subtype KRG only
    IF (p_rgpv_rec.rgp_type = 'SRG') THEN
      --  must be null
      IF (p_rgpv_rec.dnz_chr_id <> OKC_API.G_MISS_NUM OR
          p_rgpv_rec.dnz_chr_id IS NOT NULL) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'dnz_chr_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      -- data required
      IF (p_rgpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_rgpv_rec.dnz_chr_id IS NULL) THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'dnz_chr_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- enforce foreign key
      OPEN  l_chrv_csr;
      FETCH l_chrv_csr INTO l_scs_code;
      CLOSE l_chrv_csr;
      x_scs_code := l_scs_code;
      -- if l_dummy_var still set to default, data was not found
      IF (l_scs_code is NULL) THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_NO_PARENT_RECORD,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'dnz_chr_id',
          p_token2        => G_CHILD_TABLE_TOKEN,
          p_token2_value  => G_VIEW,
          p_token3        => G_PARENT_TABLE_TOKEN,
          p_token3_value  => 'OKC_K_HEADERS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
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
    -- verify that cursor was closed
    IF l_chrv_csr%ISOPEN THEN
      CLOSE l_chrv_csr;
    END IF;
  END validate_dnz_chr_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  FUNCTION Validate_Attributes (
    p_rgpv_rec IN  rgpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scs_code	VARCHAR2(50);
  BEGIN
    -- call each column-level validation

    validate_sat_code(
      x_return_status => l_return_status,
      p_rgpv_rec      => p_rgpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_rgp_type(
      x_return_status => l_return_status,
      p_rgpv_rec      => p_rgpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_cle_id(
      x_return_status => l_return_status,
      p_rgpv_rec      => p_rgpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_dnz_chr_id(
      x_return_status => l_return_status,
      x_scs_code      => l_scs_code,
      p_rgpv_rec      => p_rgpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_rgd_code(
      x_return_status => l_return_status,
      p_scs_code      => l_scs_code,
      p_rgpv_rec      => p_rgpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_chr_id(
      x_return_status => l_return_status,
      p_rgpv_rec      => p_rgpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_parent_rgp_id(
      x_return_status => l_return_status,
      p_rgpv_rec      => p_rgpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    -- return status to caller
    RETURN(x_return_status);

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE
      (p_app_name     => G_APP_NAME,
       p_msg_name     => G_UNEXPECTED_ERROR,
       p_token1       => G_SQLCODE_TOKEN,
       p_token1_value => SQLCODE,
       p_token2       => G_SQLERRM_TOKEN,
       p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    -- return status to caller
    RETURN x_return_status;

  END Validate_Attributes;

/***********************  END HAND-CODED  **************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */

    DELETE FROM OKC_RULE_GROUPS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_RULE_GROUPS_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKC_RULE_GROUPS_TL T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKC_RULE_GROUPS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_RULE_GROUPS_TL SUBB, OKC_RULE_GROUPS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKC_RULE_GROUPS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_RULE_GROUPS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_RULE_GROUPS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
    DELETE FROM OKC_RULE_GROUPS_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_RULE_GROUPS_BH B
         WHERE B.ID = T.ID
           AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_RULE_GROUPS_TLH T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKC_RULE_GROUPS_TLH B
                               WHERE B.ID = T.ID
                                 AND B.MAJOR_VERSION = T.MAJOR_VERSION
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.MAJOR_VERSION,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.MAJOR_VERSION,
                  SUBT.LANGUAGE
                FROM OKC_RULE_GROUPS_TLH SUBB, OKC_RULE_GROUPS_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKC_RULE_GROUPS_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.MAJOR_VERSION,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_RULE_GROUPS_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_RULE_GROUPS_TLH T
                     WHERE T.ID = B.ID
                       AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );


  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_GROUPS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rgp_rec                      IN rgp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rgp_rec_type IS
    CURSOR rgp_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            RGD_CODE,
            SAT_CODE,
            RGP_TYPE,
            CHR_ID,
            CLE_ID,
            DNZ_CHR_ID,
            PARENT_RGP_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15
      FROM Okc_Rule_Groups_B
     WHERE okc_rule_groups_b.id = p_id;
    l_rgp_pk                       rgp_pk_csr%ROWTYPE;
    l_rgp_rec                      rgp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rgp_pk_csr (p_rgp_rec.id);
    FETCH rgp_pk_csr INTO
              l_rgp_rec.ID,
              l_rgp_rec.RGD_CODE,
              l_rgp_rec.SAT_CODE,
              l_rgp_rec.RGP_TYPE,
              l_rgp_rec.CHR_ID,
              l_rgp_rec.CLE_ID,
              l_rgp_rec.DNZ_CHR_ID,
              l_rgp_rec.PARENT_RGP_ID,
              l_rgp_rec.OBJECT_VERSION_NUMBER,
              l_rgp_rec.CREATED_BY,
              l_rgp_rec.CREATION_DATE,
              l_rgp_rec.LAST_UPDATED_BY,
              l_rgp_rec.LAST_UPDATE_DATE,
              l_rgp_rec.LAST_UPDATE_LOGIN,
              l_rgp_rec.ATTRIBUTE_CATEGORY,
              l_rgp_rec.ATTRIBUTE1,
              l_rgp_rec.ATTRIBUTE2,
              l_rgp_rec.ATTRIBUTE3,
              l_rgp_rec.ATTRIBUTE4,
              l_rgp_rec.ATTRIBUTE5,
              l_rgp_rec.ATTRIBUTE6,
              l_rgp_rec.ATTRIBUTE7,
              l_rgp_rec.ATTRIBUTE8,
              l_rgp_rec.ATTRIBUTE9,
              l_rgp_rec.ATTRIBUTE10,
              l_rgp_rec.ATTRIBUTE11,
              l_rgp_rec.ATTRIBUTE12,
              l_rgp_rec.ATTRIBUTE13,
              l_rgp_rec.ATTRIBUTE14,
              l_rgp_rec.ATTRIBUTE15;
    x_no_data_found := rgp_pk_csr%NOTFOUND;
    CLOSE rgp_pk_csr;
    RETURN(l_rgp_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rgp_rec                      IN rgp_rec_type
  ) RETURN rgp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rgp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_GROUPS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_groups_tl_rec       IN okc_rule_groups_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_rule_groups_tl_rec_type IS
    CURSOR rgp_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rule_Groups_Tl
     WHERE okc_rule_groups_tl.id = p_id
       AND okc_rule_groups_tl.language = p_language;
    l_rgp_pktl                     rgp_pktl_csr%ROWTYPE;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rgp_pktl_csr (p_okc_rule_groups_tl_rec.id,
                       p_okc_rule_groups_tl_rec.language);
    FETCH rgp_pktl_csr INTO
              l_okc_rule_groups_tl_rec.ID,
              l_okc_rule_groups_tl_rec.LANGUAGE,
              l_okc_rule_groups_tl_rec.SOURCE_LANG,
              l_okc_rule_groups_tl_rec.SFWT_FLAG,
              l_okc_rule_groups_tl_rec.COMMENTS,
              l_okc_rule_groups_tl_rec.CREATED_BY,
              l_okc_rule_groups_tl_rec.CREATION_DATE,
              l_okc_rule_groups_tl_rec.LAST_UPDATED_BY,
              l_okc_rule_groups_tl_rec.LAST_UPDATE_DATE,
              l_okc_rule_groups_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := rgp_pktl_csr%NOTFOUND;
    CLOSE rgp_pktl_csr;
    RETURN(l_okc_rule_groups_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_rule_groups_tl_rec       IN okc_rule_groups_tl_rec_type
  ) RETURN okc_rule_groups_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_rule_groups_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_GROUPS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rgpv_rec                     IN rgpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rgpv_rec_type IS
    CURSOR okc_rgpv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            RGD_CODE,
            SAT_CODE,
            RGP_TYPE,
            CLE_ID,
            CHR_ID,
            DNZ_CHR_ID,
            PARENT_RGP_ID,
            COMMENTS,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rule_Groups_V
     WHERE okc_rule_groups_v.id = p_id;
    l_okc_rgpv_pk                  okc_rgpv_pk_csr%ROWTYPE;
    l_rgpv_rec                     rgpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rgpv_pk_csr (p_rgpv_rec.id);
    FETCH okc_rgpv_pk_csr INTO
              l_rgpv_rec.ID,
              l_rgpv_rec.OBJECT_VERSION_NUMBER,
              l_rgpv_rec.SFWT_FLAG,
              l_rgpv_rec.RGD_CODE,
              l_rgpv_rec.SAT_CODE,
              l_rgpv_rec.RGP_TYPE,
              l_rgpv_rec.CLE_ID,
              l_rgpv_rec.CHR_ID,
              l_rgpv_rec.DNZ_CHR_ID,
              l_rgpv_rec.PARENT_RGP_ID,
              l_rgpv_rec.COMMENTS,
              l_rgpv_rec.ATTRIBUTE_CATEGORY,
              l_rgpv_rec.ATTRIBUTE1,
              l_rgpv_rec.ATTRIBUTE2,
              l_rgpv_rec.ATTRIBUTE3,
              l_rgpv_rec.ATTRIBUTE4,
              l_rgpv_rec.ATTRIBUTE5,
              l_rgpv_rec.ATTRIBUTE6,
              l_rgpv_rec.ATTRIBUTE7,
              l_rgpv_rec.ATTRIBUTE8,
              l_rgpv_rec.ATTRIBUTE9,
              l_rgpv_rec.ATTRIBUTE10,
              l_rgpv_rec.ATTRIBUTE11,
              l_rgpv_rec.ATTRIBUTE12,
              l_rgpv_rec.ATTRIBUTE13,
              l_rgpv_rec.ATTRIBUTE14,
              l_rgpv_rec.ATTRIBUTE15,
              l_rgpv_rec.CREATED_BY,
              l_rgpv_rec.CREATION_DATE,
              l_rgpv_rec.LAST_UPDATED_BY,
              l_rgpv_rec.LAST_UPDATE_DATE,
              l_rgpv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_rgpv_pk_csr%NOTFOUND;
    CLOSE okc_rgpv_pk_csr;
    RETURN(l_rgpv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rgpv_rec                     IN rgpv_rec_type
  ) RETURN rgpv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rgpv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_RULE_GROUPS_V --
  -------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rgpv_rec	IN rgpv_rec_type
  ) RETURN rgpv_rec_type IS
    l_rgpv_rec	rgpv_rec_type := p_rgpv_rec;
  BEGIN
    IF (l_rgpv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.object_version_number := NULL;
    END IF;
    IF (l_rgpv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_rgpv_rec.rgd_code = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.rgd_code := NULL;
    END IF;
    IF (l_rgpv_rec.sat_code = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.sat_code := NULL;
    END IF;
    IF (l_rgpv_rec.rgp_type = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.rgp_type := NULL;
    END IF;
    IF (l_rgpv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.cle_id := NULL;
    END IF;
    IF (l_rgpv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.chr_id := NULL;
    END IF;
    IF (l_rgpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_rgpv_rec.parent_rgp_id = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.parent_rgp_id := NULL;
    END IF;
    IF (l_rgpv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.comments := NULL;
    END IF;
    IF (l_rgpv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute_category := NULL;
    END IF;
    IF (l_rgpv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute1 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute2 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute3 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute4 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute5 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute6 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute7 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute8 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute9 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute10 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute11 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute12 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute13 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute14 := NULL;
    END IF;
    IF (l_rgpv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_rgpv_rec.attribute15 := NULL;
    END IF;
    IF (l_rgpv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.created_by := NULL;
    END IF;
    IF (l_rgpv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rgpv_rec.creation_date := NULL;
    END IF;
    IF (l_rgpv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rgpv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rgpv_rec.last_update_date := NULL;
    END IF;
    IF (l_rgpv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rgpv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_rgpv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKC_RULE_GROUPS_V --
  -----------------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_rgpv_rec IN  rgpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rgpv_rec.id = OKC_API.G_MISS_NUM OR
       p_rgpv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rgpv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_rgpv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rgpv_rec.rgd_code = OKC_API.G_MISS_CHAR OR
          p_rgpv_rec.rgd_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rgd_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rgpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_rgpv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Record for:OKC_RULE_GROUPS_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_rgpv_rec IN rgpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN rgpv_rec_type,
    p_to	IN OUT NOCOPY rgp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgd_code := p_from.rgd_code;
    p_to.sat_code := p_from.sat_code;
    p_to.rgp_type := p_from.rgp_type;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_rgp_id := p_from.parent_rgp_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rgp_rec_type,
    p_to	IN OUT NOCOPY rgpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgd_code := p_from.rgd_code;
    p_to.sat_code := p_from.sat_code;
    p_to.rgp_type := p_from.rgp_type;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_rgp_id := p_from.parent_rgp_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rgpv_rec_type,
    p_to	IN OUT NOCOPY okc_rule_groups_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_rule_groups_tl_rec_type,
    p_to	IN OUT NOCOPY rgpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- validate_row for:OKC_RULE_GROUPS_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN rgpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
    l_rgp_rec                      rgp_rec_type;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_rgpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rgpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:RGPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN rgpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgpv_tbl.COUNT > 0) THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgpv_rec                     => p_rgpv_tbl(i));
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- insert_row for:OKC_RULE_GROUPS_B --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_rec                      IN rgp_rec_type,
    x_rgp_rec                      OUT NOCOPY rgp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgp_rec                      rgp_rec_type := p_rgp_rec;
    l_def_rgp_rec                  rgp_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKC_RULE_GROUPS_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_rgp_rec IN  rgp_rec_type,
      x_rgp_rec OUT NOCOPY rgp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rgp_rec := p_rgp_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_rgp_rec,                         -- IN
      l_rgp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_RULE_GROUPS_B(
        id,
        rgd_code,
        sat_code,
        rgp_type,
        chr_id,
        cle_id,
        dnz_chr_id,
        parent_rgp_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15)
      VALUES (
        l_rgp_rec.id,
        l_rgp_rec.rgd_code,
        l_rgp_rec.sat_code,
        l_rgp_rec.rgp_type,
        l_rgp_rec.chr_id,
        l_rgp_rec.cle_id,
        l_rgp_rec.dnz_chr_id,
        l_rgp_rec.parent_rgp_id,
        l_rgp_rec.object_version_number,
        l_rgp_rec.created_by,
        l_rgp_rec.creation_date,
        l_rgp_rec.last_updated_by,
        l_rgp_rec.last_update_date,
        l_rgp_rec.last_update_login,
        l_rgp_rec.attribute_category,
        l_rgp_rec.attribute1,
        l_rgp_rec.attribute2,
        l_rgp_rec.attribute3,
        l_rgp_rec.attribute4,
        l_rgp_rec.attribute5,
        l_rgp_rec.attribute6,
        l_rgp_rec.attribute7,
        l_rgp_rec.attribute8,
        l_rgp_rec.attribute9,
        l_rgp_rec.attribute10,
        l_rgp_rec.attribute11,
        l_rgp_rec.attribute12,
        l_rgp_rec.attribute13,
        l_rgp_rec.attribute14,
        l_rgp_rec.attribute15);
    -- Set OUT values
    x_rgp_rec := l_rgp_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END insert_row;
  ---------------------------------------
  -- insert_row for:OKC_RULE_GROUPS_TL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_groups_tl_rec       IN okc_rule_groups_tl_rec_type,
    x_okc_rule_groups_tl_rec       OUT NOCOPY okc_rule_groups_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type := p_okc_rule_groups_tl_rec;
    l_def_okc_rule_groups_tl_rec   okc_rule_groups_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -------------------------------------------
    -- Set_Attributes for:OKC_RULE_GROUPS_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_groups_tl_rec IN  okc_rule_groups_tl_rec_type,
      x_okc_rule_groups_tl_rec OUT NOCOPY okc_rule_groups_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_groups_tl_rec := p_okc_rule_groups_tl_rec;
      x_okc_rule_groups_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_rule_groups_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okc_rule_groups_tl_rec,          -- IN
      l_okc_rule_groups_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_rule_groups_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_RULE_GROUPS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_rule_groups_tl_rec.id,
          l_okc_rule_groups_tl_rec.language,
          l_okc_rule_groups_tl_rec.source_lang,
          l_okc_rule_groups_tl_rec.sfwt_flag,
          l_okc_rule_groups_tl_rec.comments,
          l_okc_rule_groups_tl_rec.created_by,
          l_okc_rule_groups_tl_rec.creation_date,
          l_okc_rule_groups_tl_rec.last_updated_by,
          l_okc_rule_groups_tl_rec.last_update_date,
          l_okc_rule_groups_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_rule_groups_tl_rec := l_okc_rule_groups_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END insert_row;
  --------------------------------------
  -- insert_row for:OKC_RULE_GROUPS_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgpv_rec                     rgpv_rec_type;
    l_def_rgpv_rec                 rgpv_rec_type;
    l_rgp_rec                      rgp_rec_type;
    lx_rgp_rec                     rgp_rec_type;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type;
    lx_okc_rule_groups_tl_rec      okc_rule_groups_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rgpv_rec	IN rgpv_rec_type
    ) RETURN rgpv_rec_type IS
      l_rgpv_rec	rgpv_rec_type := p_rgpv_rec;
    BEGIN
      l_rgpv_rec.CREATION_DATE := SYSDATE;
      l_rgpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rgpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rgpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rgpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rgpv_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKC_RULE_GROUPS_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_rgpv_rec IN  rgpv_rec_type,
      x_rgpv_rec OUT NOCOPY rgpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rgpv_rec := p_rgpv_rec;
      x_rgpv_rec.OBJECT_VERSION_NUMBER := 1;
      x_rgpv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec := null_out_defaults(p_rgpv_rec);
    -- Set primary key value
    l_rgpv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rgpv_rec,                        -- IN
      l_def_rgpv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rgpv_rec := fill_who_columns(l_def_rgpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rgpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rgpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rgpv_rec, l_rgp_rec);
    migrate(l_def_rgpv_rec, l_okc_rule_groups_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgp_rec,
      lx_rgp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rgp_rec, l_def_rgpv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_groups_tl_rec,
      lx_okc_rule_groups_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rule_groups_tl_rec, l_def_rgpv_rec);
    -- Set OUT values
    x_rgpv_rec := l_def_rgpv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:RGPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgpv_tbl.COUNT > 0) THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgpv_rec                     => p_rgpv_tbl(i),
          x_rgpv_rec                     => x_rgpv_tbl(i));
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- lock_row for:OKC_RULE_GROUPS_B --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_rec                      IN rgp_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rgp_rec IN rgp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULE_GROUPS_B
     WHERE ID = p_rgp_rec.id
       AND OBJECT_VERSION_NUMBER = p_rgp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rgp_rec IN rgp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULE_GROUPS_B
    WHERE ID = p_rgp_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_RULE_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_RULE_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_rgp_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_rgp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rgp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rgp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END lock_row;
  -------------------------------------
  -- lock_row for:OKC_RULE_GROUPS_TL --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_groups_tl_rec       IN okc_rule_groups_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_rule_groups_tl_rec IN okc_rule_groups_tl_rec_type) IS
    SELECT *
      FROM OKC_RULE_GROUPS_TL
     WHERE ID = p_okc_rule_groups_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okc_rule_groups_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END lock_row;
  ------------------------------------
  -- lock_row for:OKC_RULE_GROUPS_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN rgpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgp_rec                      rgp_rec_type;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_rgpv_rec, l_rgp_rec);
    migrate(p_rgpv_rec, l_okc_rule_groups_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_groups_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:RGPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN rgpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgpv_tbl.COUNT > 0) THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgpv_rec                     => p_rgpv_tbl(i));
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- update_row for:OKC_RULE_GROUPS_B --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_rec                      IN rgp_rec_type,
    x_rgp_rec                      OUT NOCOPY rgp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgp_rec                      rgp_rec_type := p_rgp_rec;
    l_def_rgp_rec                  rgp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rgp_rec	IN rgp_rec_type,
      x_rgp_rec	OUT NOCOPY rgp_rec_type
    ) RETURN VARCHAR2 IS
      l_rgp_rec                      rgp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rgp_rec := p_rgp_rec;
      -- Get current database values
      l_rgp_rec := get_rec(p_rgp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rgp_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.id := l_rgp_rec.id;
      END IF;
      IF (x_rgp_rec.rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.rgd_code := l_rgp_rec.rgd_code;
      END IF;
      IF (x_rgp_rec.sat_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.sat_code := l_rgp_rec.sat_code;
      END IF;
      IF (x_rgp_rec.rgp_type = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.rgp_type := l_rgp_rec.rgp_type;
      END IF;
      IF (x_rgp_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.chr_id := l_rgp_rec.chr_id;
      END IF;
      IF (x_rgp_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.cle_id := l_rgp_rec.cle_id;
      END IF;
      IF (x_rgp_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.dnz_chr_id := l_rgp_rec.dnz_chr_id;
      END IF;
      IF (x_rgp_rec.parent_rgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.parent_rgp_id := l_rgp_rec.parent_rgp_id;
      END IF;
      IF (x_rgp_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.object_version_number := l_rgp_rec.object_version_number;
      END IF;
      IF (x_rgp_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.created_by := l_rgp_rec.created_by;
      END IF;
      IF (x_rgp_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgp_rec.creation_date := l_rgp_rec.creation_date;
      END IF;
      IF (x_rgp_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.last_updated_by := l_rgp_rec.last_updated_by;
      END IF;
      IF (x_rgp_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgp_rec.last_update_date := l_rgp_rec.last_update_date;
      END IF;
      IF (x_rgp_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rgp_rec.last_update_login := l_rgp_rec.last_update_login;
      END IF;
      IF (x_rgp_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute_category := l_rgp_rec.attribute_category;
      END IF;
      IF (x_rgp_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute1 := l_rgp_rec.attribute1;
      END IF;
      IF (x_rgp_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute2 := l_rgp_rec.attribute2;
      END IF;
      IF (x_rgp_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute3 := l_rgp_rec.attribute3;
      END IF;
      IF (x_rgp_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute4 := l_rgp_rec.attribute4;
      END IF;
      IF (x_rgp_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute5 := l_rgp_rec.attribute5;
      END IF;
      IF (x_rgp_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute6 := l_rgp_rec.attribute6;
      END IF;
      IF (x_rgp_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute7 := l_rgp_rec.attribute7;
      END IF;
      IF (x_rgp_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute8 := l_rgp_rec.attribute8;
      END IF;
      IF (x_rgp_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute9 := l_rgp_rec.attribute9;
      END IF;
      IF (x_rgp_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute10 := l_rgp_rec.attribute10;
      END IF;
      IF (x_rgp_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute11 := l_rgp_rec.attribute11;
      END IF;
      IF (x_rgp_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute12 := l_rgp_rec.attribute12;
      END IF;
      IF (x_rgp_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute13 := l_rgp_rec.attribute13;
      END IF;
      IF (x_rgp_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute14 := l_rgp_rec.attribute14;
      END IF;
      IF (x_rgp_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgp_rec.attribute15 := l_rgp_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_RULE_GROUPS_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_rgp_rec IN  rgp_rec_type,
      x_rgp_rec OUT NOCOPY rgp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rgp_rec := p_rgp_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_rgp_rec,                         -- IN
      l_rgp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rgp_rec, l_def_rgp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_RULE_GROUPS_B
    SET RGD_CODE = l_def_rgp_rec.rgd_code,
        SAT_CODE = l_def_rgp_rec.sat_code,
        RGP_TYPE = l_def_rgp_rec.rgp_type,
        CHR_ID = l_def_rgp_rec.chr_id,
        CLE_ID = l_def_rgp_rec.cle_id,
        DNZ_CHR_ID = l_def_rgp_rec.dnz_chr_id,
        PARENT_RGP_ID = l_def_rgp_rec.parent_rgp_id,
        OBJECT_VERSION_NUMBER = l_def_rgp_rec.object_version_number,
        CREATED_BY = l_def_rgp_rec.created_by,
        CREATION_DATE = l_def_rgp_rec.creation_date,
        LAST_UPDATED_BY = l_def_rgp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rgp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rgp_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_rgp_rec.attribute_category,
        ATTRIBUTE1 = l_def_rgp_rec.attribute1,
        ATTRIBUTE2 = l_def_rgp_rec.attribute2,
        ATTRIBUTE3 = l_def_rgp_rec.attribute3,
        ATTRIBUTE4 = l_def_rgp_rec.attribute4,
        ATTRIBUTE5 = l_def_rgp_rec.attribute5,
        ATTRIBUTE6 = l_def_rgp_rec.attribute6,
        ATTRIBUTE7 = l_def_rgp_rec.attribute7,
        ATTRIBUTE8 = l_def_rgp_rec.attribute8,
        ATTRIBUTE9 = l_def_rgp_rec.attribute9,
        ATTRIBUTE10 = l_def_rgp_rec.attribute10,
        ATTRIBUTE11 = l_def_rgp_rec.attribute11,
        ATTRIBUTE12 = l_def_rgp_rec.attribute12,
        ATTRIBUTE13 = l_def_rgp_rec.attribute13,
        ATTRIBUTE14 = l_def_rgp_rec.attribute14,
        ATTRIBUTE15 = l_def_rgp_rec.attribute15
    WHERE ID = l_def_rgp_rec.id;

    x_rgp_rec := l_def_rgp_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END update_row;
  ---------------------------------------
  -- update_row for:OKC_RULE_GROUPS_TL --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_groups_tl_rec       IN okc_rule_groups_tl_rec_type,
    x_okc_rule_groups_tl_rec       OUT NOCOPY okc_rule_groups_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type := p_okc_rule_groups_tl_rec;
    l_def_okc_rule_groups_tl_rec   okc_rule_groups_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_rule_groups_tl_rec	IN okc_rule_groups_tl_rec_type,
      x_okc_rule_groups_tl_rec	OUT NOCOPY okc_rule_groups_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_groups_tl_rec := p_okc_rule_groups_tl_rec;
      -- Get current database values
      l_okc_rule_groups_tl_rec := get_rec(p_okc_rule_groups_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_rule_groups_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rule_groups_tl_rec.id := l_okc_rule_groups_tl_rec.id;
      END IF;
      IF (x_okc_rule_groups_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rule_groups_tl_rec.language := l_okc_rule_groups_tl_rec.language;
      END IF;
      IF (x_okc_rule_groups_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rule_groups_tl_rec.source_lang := l_okc_rule_groups_tl_rec.source_lang;
      END IF;
      IF (x_okc_rule_groups_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rule_groups_tl_rec.sfwt_flag := l_okc_rule_groups_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_rule_groups_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rule_groups_tl_rec.comments := l_okc_rule_groups_tl_rec.comments;
      END IF;
      IF (x_okc_rule_groups_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rule_groups_tl_rec.created_by := l_okc_rule_groups_tl_rec.created_by;
      END IF;
      IF (x_okc_rule_groups_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_rule_groups_tl_rec.creation_date := l_okc_rule_groups_tl_rec.creation_date;
      END IF;
      IF (x_okc_rule_groups_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rule_groups_tl_rec.last_updated_by := l_okc_rule_groups_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_rule_groups_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_rule_groups_tl_rec.last_update_date := l_okc_rule_groups_tl_rec.last_update_date;
      END IF;
      IF (x_okc_rule_groups_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rule_groups_tl_rec.last_update_login := l_okc_rule_groups_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_RULE_GROUPS_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_groups_tl_rec IN  okc_rule_groups_tl_rec_type,
      x_okc_rule_groups_tl_rec OUT NOCOPY okc_rule_groups_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_groups_tl_rec := p_okc_rule_groups_tl_rec;
      x_okc_rule_groups_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_rule_groups_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okc_rule_groups_tl_rec,          -- IN
      l_okc_rule_groups_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_rule_groups_tl_rec, l_def_okc_rule_groups_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_RULE_GROUPS_TL
    SET COMMENTS = l_def_okc_rule_groups_tl_rec.comments,
        CREATED_BY = l_def_okc_rule_groups_tl_rec.created_by,
        CREATION_DATE = l_def_okc_rule_groups_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_rule_groups_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_rule_groups_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_rule_groups_tl_rec.last_update_login
    WHERE ID = l_def_okc_rule_groups_tl_rec.id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_RULE_GROUPS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_rule_groups_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_rule_groups_tl_rec := l_def_okc_rule_groups_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END update_row;
  --------------------------------------
  -- update_row for:OKC_RULE_GROUPS_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
    l_def_rgpv_rec                 rgpv_rec_type;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type;
    lx_okc_rule_groups_tl_rec      okc_rule_groups_tl_rec_type;
    l_rgp_rec                      rgp_rec_type;
    lx_rgp_rec                     rgp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rgpv_rec	IN rgpv_rec_type
    ) RETURN rgpv_rec_type IS
      l_rgpv_rec	rgpv_rec_type := p_rgpv_rec;
    BEGIN
      l_rgpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rgpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rgpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rgpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rgpv_rec	IN rgpv_rec_type,
      x_rgpv_rec	OUT NOCOPY rgpv_rec_type
    ) RETURN VARCHAR2 IS
      l_rgpv_rec                     rgpv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rgpv_rec := p_rgpv_rec;
      -- Get current database values
      l_rgpv_rec := get_rec(p_rgpv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rgpv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.id := l_rgpv_rec.id;
      END IF;
      IF (x_rgpv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.object_version_number := l_rgpv_rec.object_version_number;
      END IF;
      IF (x_rgpv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.sfwt_flag := l_rgpv_rec.sfwt_flag;
      END IF;
      IF (x_rgpv_rec.rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.rgd_code := l_rgpv_rec.rgd_code;
      END IF;
      IF (x_rgpv_rec.sat_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.sat_code := l_rgpv_rec.sat_code;
      END IF;
      IF (x_rgpv_rec.rgp_type = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.rgp_type := l_rgpv_rec.rgp_type;
      END IF;
      IF (x_rgpv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.cle_id := l_rgpv_rec.cle_id;
      END IF;
      IF (x_rgpv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.chr_id := l_rgpv_rec.chr_id;
      END IF;
      IF (x_rgpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.dnz_chr_id := l_rgpv_rec.dnz_chr_id;
      END IF;
      IF (x_rgpv_rec.parent_rgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.parent_rgp_id := l_rgpv_rec.parent_rgp_id;
      END IF;
      IF (x_rgpv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.comments := l_rgpv_rec.comments;
      END IF;
      IF (x_rgpv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute_category := l_rgpv_rec.attribute_category;
      END IF;
      IF (x_rgpv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute1 := l_rgpv_rec.attribute1;
      END IF;
      IF (x_rgpv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute2 := l_rgpv_rec.attribute2;
      END IF;
      IF (x_rgpv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute3 := l_rgpv_rec.attribute3;
      END IF;
      IF (x_rgpv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute4 := l_rgpv_rec.attribute4;
      END IF;
      IF (x_rgpv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute5 := l_rgpv_rec.attribute5;
      END IF;
      IF (x_rgpv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute6 := l_rgpv_rec.attribute6;
      END IF;
      IF (x_rgpv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute7 := l_rgpv_rec.attribute7;
      END IF;
      IF (x_rgpv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute8 := l_rgpv_rec.attribute8;
      END IF;
      IF (x_rgpv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute9 := l_rgpv_rec.attribute9;
      END IF;
      IF (x_rgpv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute10 := l_rgpv_rec.attribute10;
      END IF;
      IF (x_rgpv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute11 := l_rgpv_rec.attribute11;
      END IF;
      IF (x_rgpv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute12 := l_rgpv_rec.attribute12;
      END IF;
      IF (x_rgpv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute13 := l_rgpv_rec.attribute13;
      END IF;
      IF (x_rgpv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute14 := l_rgpv_rec.attribute14;
      END IF;
      IF (x_rgpv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rgpv_rec.attribute15 := l_rgpv_rec.attribute15;
      END IF;
      IF (x_rgpv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.created_by := l_rgpv_rec.created_by;
      END IF;
      IF (x_rgpv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgpv_rec.creation_date := l_rgpv_rec.creation_date;
      END IF;
      IF (x_rgpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.last_updated_by := l_rgpv_rec.last_updated_by;
      END IF;
      IF (x_rgpv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgpv_rec.last_update_date := l_rgpv_rec.last_update_date;
      END IF;
      IF (x_rgpv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rgpv_rec.last_update_login := l_rgpv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_RULE_GROUPS_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_rgpv_rec IN  rgpv_rec_type,
      x_rgpv_rec OUT NOCOPY rgpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rgpv_rec := p_rgpv_rec;
      x_rgpv_rec.OBJECT_VERSION_NUMBER := NVL(x_rgpv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_rgpv_rec,                        -- IN
      l_rgpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rgpv_rec, l_def_rgpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rgpv_rec := fill_who_columns(l_def_rgpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rgpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rgpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rgpv_rec, l_okc_rule_groups_tl_rec);
    migrate(l_def_rgpv_rec, l_rgp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_groups_tl_rec,
      lx_okc_rule_groups_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rule_groups_tl_rec, l_def_rgpv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgp_rec,
      lx_rgp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rgp_rec, l_def_rgpv_rec);
    x_rgpv_rec := l_def_rgpv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:RGPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgpv_tbl.COUNT > 0) THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgpv_rec                     => p_rgpv_tbl(i),
          x_rgpv_rec                     => x_rgpv_tbl(i));
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- delete_row for:OKC_RULE_GROUPS_B --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_rec                      IN rgp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgp_rec                      rgp_rec_type:= p_rgp_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_RULE_GROUPS_B
     WHERE ID = l_rgp_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END delete_row;
  ---------------------------------------
  -- delete_row for:OKC_RULE_GROUPS_TL --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_groups_tl_rec       IN okc_rule_groups_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type:= p_okc_rule_groups_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -------------------------------------------
    -- Set_Attributes for:OKC_RULE_GROUPS_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_groups_tl_rec IN  okc_rule_groups_tl_rec_type,
      x_okc_rule_groups_tl_rec OUT NOCOPY okc_rule_groups_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_groups_tl_rec := p_okc_rule_groups_tl_rec;
      x_okc_rule_groups_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okc_rule_groups_tl_rec,          -- IN
      l_okc_rule_groups_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_RULE_GROUPS_TL
     WHERE ID = l_okc_rule_groups_tl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END delete_row;
  --------------------------------------
  -- delete_row for:OKC_RULE_GROUPS_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN rgpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
    l_okc_rule_groups_tl_rec       okc_rule_groups_tl_rec_type;
    l_rgp_rec                      rgp_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_rgpv_rec, l_okc_rule_groups_tl_rec);
    migrate(l_rgpv_rec, l_rgp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_groups_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:RGPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN rgpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgpv_tbl.COUNT > 0) THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgpv_rec                     => p_rgpv_tbl(i));
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  END delete_row;

---------------------------------------------------------------
-- Procedure for mass insert in OKC_RULE_GROUPS _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_rgpv_tbl rgpv_tbl_type) IS
  l_tabsize NUMBER := p_rgpv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_rgp_type                      OKC_DATATYPES.Var10TabTyp;
  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_rgd_code                      OKC_DATATYPES.Var30TabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_parent_rgp_id                 OKC_DATATYPES.NumberTabTyp;
  in_sat_code                      OKC_DATATYPES.Var30TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i number;
  j number;
BEGIN
   --Initialize return status
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
  i := p_rgpv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_rgpv_tbl(i).id;
    in_object_version_number    (j) := p_rgpv_tbl(i).object_version_number;
    in_rgp_type                 (j) := p_rgpv_tbl(i).rgp_type;
    in_sfwt_flag                (j) := p_rgpv_tbl(i).sfwt_flag;
    in_rgd_code                 (j) := p_rgpv_tbl(i).rgd_code;
    in_cle_id                   (j) := p_rgpv_tbl(i).cle_id;
    in_chr_id                   (j) := p_rgpv_tbl(i).chr_id;
    in_dnz_chr_id               (j) := p_rgpv_tbl(i).dnz_chr_id;
    in_parent_rgp_id            (j) := p_rgpv_tbl(i).parent_rgp_id;
    in_sat_code                 (j) := p_rgpv_tbl(i).sat_code;
    in_comments                 (j) := p_rgpv_tbl(i).comments;
    in_attribute_category       (j) := p_rgpv_tbl(i).attribute_category;
    in_attribute1               (j) := p_rgpv_tbl(i).attribute1;
    in_attribute2               (j) := p_rgpv_tbl(i).attribute2;
    in_attribute3               (j) := p_rgpv_tbl(i).attribute3;
    in_attribute4               (j) := p_rgpv_tbl(i).attribute4;
    in_attribute5               (j) := p_rgpv_tbl(i).attribute5;
    in_attribute6               (j) := p_rgpv_tbl(i).attribute6;
    in_attribute7               (j) := p_rgpv_tbl(i).attribute7;
    in_attribute8               (j) := p_rgpv_tbl(i).attribute8;
    in_attribute9               (j) := p_rgpv_tbl(i).attribute9;
    in_attribute10              (j) := p_rgpv_tbl(i).attribute10;
    in_attribute11              (j) := p_rgpv_tbl(i).attribute11;
    in_attribute12              (j) := p_rgpv_tbl(i).attribute12;
    in_attribute13              (j) := p_rgpv_tbl(i).attribute13;
    in_attribute14              (j) := p_rgpv_tbl(i).attribute14;
    in_attribute15              (j) := p_rgpv_tbl(i).attribute15;
    in_created_by               (j) := p_rgpv_tbl(i).created_by;
    in_creation_date            (j) := p_rgpv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_rgpv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_rgpv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_rgpv_tbl(i).last_update_login;
    i:=p_rgpv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_RULE_GROUPS_B
      (
        id,
        rgd_code,
        chr_id,
        cle_id,
        dnz_chr_id,
        parent_rgp_id,
        sat_code,
        object_version_number,
        rgp_type,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15
-- REMOVE comma from the previous line
     )
     VALUES (
        in_id(i),
        in_rgd_code(i),
        in_chr_id(i),
        in_cle_id(i),
        in_dnz_chr_id(i),
        in_parent_rgp_id(i),
        in_sat_code(i),
        in_object_version_number(i),
        in_rgp_type(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i),
        in_attribute_category(i),
        in_attribute1(i),
        in_attribute2(i),
        in_attribute3(i),
        in_attribute4(i),
        in_attribute5(i),
        in_attribute6(i),
        in_attribute7(i),
        in_attribute8(i),
        in_attribute9(i),
        in_attribute10(i),
        in_attribute11(i),
        in_attribute12(i),
        in_attribute13(i),
        in_attribute14(i),
        in_attribute15(i)
-- REMOVE comma from the previous line
     );

  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..l_tabsize
      INSERT INTO OKC_RULE_GROUPS_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        comments,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
-- REMOVE comma from the previous line
     )
     VALUES (
        in_id(i),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        in_sfwt_flag(i),
        in_comments(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
-- REMOVE comma from the previous line
      );
      END LOOP;
EXCEPTION
  WHEN OTHERS THEN
     -- store SQL error message on message stack
     OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
	p_token2_value    => SQLERRM);
     -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_rule_groups_bh
  (
      major_version,
      id,
      rgd_code,
      chr_id,
      cle_id,
      dnz_chr_id,
      parent_rgp_id,
      sat_code,
      object_version_number,
      rgp_type,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15
)
  SELECT
      p_major_version,
      id,
      rgd_code,
      chr_id,
      cle_id,
      dnz_chr_id,
      parent_rgp_id,
      sat_code,
      object_version_number,
      rgp_type,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15
  FROM okc_rule_groups_b
 WHERE dnz_chr_id = p_chr_id;

-------------------------------
-- Versioning TL Table
-------------------------------

INSERT INTO okc_rule_groups_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      p_major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_rule_groups_tl
 WHERE id in (select id
			from okc_rule_groups_b
			where dnz_chr_id = p_chr_id);

-- Lines changed above Dated 10/06/2000

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_rule_groups_tl
  (
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_rule_groups_tlh
WHERE id in (SELECT id
			FROM okc_rule_groups_bh
		    WHERE dnz_chr_id = p_chr_id)
  AND major_version = p_major_version;

-----------------------------------------
-- Restoring Base Table
-----------------------------------------

INSERT INTO okc_rule_groups_b
  (
      id,
      rgd_code,
      chr_id,
      cle_id,
      dnz_chr_id,
      parent_rgp_id,
      sat_code,
      object_version_number,
      rgp_type,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15
)
  SELECT
      id,
      rgd_code,
      chr_id,
      cle_id,
      dnz_chr_id,
      parent_rgp_id,
      sat_code,
      object_version_number,
      rgp_type,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15
  FROM okc_rule_groups_bh
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END restore_version;

END OKC_RGP_PVT;

/
