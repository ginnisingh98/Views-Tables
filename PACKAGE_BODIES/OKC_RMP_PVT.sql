--------------------------------------------------------
--  DDL for Package Body OKC_RMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RMP_PVT" AS
/* $Header: OKCSRMPB.pls 120.0 2005/05/25 23:10:04 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  **************************/
  FUNCTION Validate_Attributes
    (p_rmpv_rec IN  rmpv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT VARCHAR2(200) := 'SQLcode';
  G_VIEW             CONSTANT VARCHAR2(200) := 'OKC_RG_PARTY_ROLES_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  g_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_rgp_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rgp_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rmpv_rec      IN    rmpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rgpv_csr IS
/*      SELECT 'x'
        FROM OKC_RULE_GROUPS_V rgpv
       WHERE rgpv.ID = p_rmpv_rec.RGP_ID;
*/
    select 'x'
    from 	okc_rule_groups_b RGP
    where RGP.id = p_rmpv_rec.rgp_id
      and RGP.rgd_code in (
	select SRD.rgd_code
	from okc_rg_role_defs RRD
	, okc_subclass_rg_defs SRD
	, okc_k_headers_b KHD
	where RRD.id = p_rmpv_rec.rrd_id
    	and SRD.id = RRD.srd_id
	and KHD.id = p_rmpv_rec.dnz_chr_id
	and SRD.SCS_CODE = KHD.SCS_CODE)
;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rmpv_rec.rgp_id = OKC_API.G_MISS_NUM OR
        p_rmpv_rec.rgp_id IS NULL)
    THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgp_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

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
        p_token1_value  => 'rgp_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_RULE_GROUPS_V');
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
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	         => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rgpv_csr%ISOPEN THEN
      CLOSE l_rgpv_csr;
    END IF;
  END validate_rgp_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_rrd_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rrd_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rmpv_rec      IN    rmpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rrdv_csr IS
      SELECT 'x'
        FROM OKC_RG_ROLE_DEFS rrdv
       WHERE rrdv.SRE_ID IN
             (SELECT srev.ID
                FROM OKC_SUBCLASS_ROLES srev,
                     OKC_SUBCLASSES_B scsv,
                     OKC_K_HEADERS_B chrv
               WHERE srev.SCS_CODE = scsv.CODE
                 AND scsv.CODE     = chrv.SCS_CODE
                 AND chrv.ID       = p_rmpv_rec.dnz_chr_id)
         AND rrdv.ID   = p_rmpv_rec.RRD_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rmpv_rec.rrd_id = OKC_API.G_MISS_NUM OR
        p_rmpv_rec.rrd_id IS NULL)
    THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rrd_id'
      );
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_rrdv_csr;
    FETCH l_rrdv_csr INTO l_dummy_var;
    CLOSE l_rrdv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value	=> 'rrd_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value	=> G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value	=> 'OKC_RG_MODE_DEFS_V');

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
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	         => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rrdv_csr%ISOPEN THEN
      CLOSE l_rrdv_csr;
    END IF;
  END validate_rrd_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_cpl_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_cpl_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rmpv_rec      IN    rmpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_cplv_csr IS
/*      SELECT 'x'
        FROM OKC_K_PARTY_ROLES_V cplv
       WHERE cplv.RLE_CODE IN
             (SELECT srev.RLE_CODE
                FROM OKC_SUBCLASS_ROLES_B srev,
                     OKC_SUBCLASSES_B scsv,
                     OKC_K_HEADERS_B chrv
               WHERE srev.SCS_CODE = scsv.CODE
                 AND scsv.CODE     = chrv.SCS_CODE
                 AND chrv.ID       = p_rmpv_rec.dnz_chr_id)
         AND cplv.ID = p_rmpv_rec.CPL_ID;
*/
    select 'x'
    from 	okc_k_party_roles_b CPL
    where CPL.id = p_rmpv_rec.cpl_id
    and CPL.rle_code in (
      select SRE.rle_code
      from okc_rg_role_defs RRD
	, okc_subclass_roles SRE
	, okc_k_headers_b KHD
      where RRD.id = p_rmpv_rec.rrd_id
        and SRE.id = RRD.sre_id
	and KHD.id = p_rmpv_rec.dnz_chr_id
	and SRE.SCS_CODE = KHD.SCS_CODE)
;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for datat
    IF (p_rmpv_rec.cpl_id <> OKC_API.G_MISS_NUM OR
        p_rmpv_rec.cpl_id IS NOT NULL)
    THEN

      -- enforce foreign key
      OPEN  l_cplv_csr;
      FETCH l_cplv_csr INTO l_dummy_var;
      CLOSE l_cplv_csr;

      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_NO_PARENT_RECORD,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'cpl_id',
          p_token2        => G_CHILD_TABLE_TOKEN,
          p_token2_value  => G_VIEW,
          p_token3        => G_PARENT_TABLE_TOKEN,
          p_token3_value  => 'OKC_K_PARTY_ROLES_V');

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
      p_token1	         => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_cplv_csr%ISOPEN THEN
      CLOSE l_cplv_csr;
    END IF;
  END validate_cpl_id;
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
    p_rmpv_rec      IN    rmpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_chrv_csr IS
      SELECT 'x'
        FROM OKC_K_HEADERS_B chrv
       WHERE chrv.ID = p_rmpv_rec.DNZ_CHR_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data required
    IF (p_rmpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
        p_rmpv_rec.dnz_chr_id IS NULL) THEN

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
    FETCH l_chrv_csr INTO l_dummy_var;
    CLOSE l_chrv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
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
    p_rmpv_rec IN  rmpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    validate_rgp_id(
      x_return_status => l_return_status,
      p_rmpv_rec      => p_rmpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_rrd_id(
      x_return_status => l_return_status,
      p_rmpv_rec      => p_rmpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_cpl_id(
      x_return_status => l_return_status,
      p_rmpv_rec      => p_rmpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_dnz_chr_id(
      x_return_status => l_return_status,
      p_rmpv_rec      => p_rmpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
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
  -- FUNCTION get_rec for: OKC_RG_PARTY_ROLES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rpr_rec                      IN rpr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rpr_rec_type IS
    CURSOR rpr_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            RGP_ID,
            RRD_ID,
            CPL_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rg_Party_Roles
     WHERE okc_rg_party_roles.id = p_id;
    l_rpr_pk                       rpr_pk_csr%ROWTYPE;
    l_rpr_rec                      rpr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rpr_pk_csr (p_rpr_rec.id);
    FETCH rpr_pk_csr INTO
              l_rpr_rec.ID,
              l_rpr_rec.RGP_ID,
              l_rpr_rec.RRD_ID,
              l_rpr_rec.CPL_ID,
              l_rpr_rec.DNZ_CHR_ID,
              l_rpr_rec.OBJECT_VERSION_NUMBER,
              l_rpr_rec.CREATED_BY,
              l_rpr_rec.CREATION_DATE,
              l_rpr_rec.LAST_UPDATED_BY,
              l_rpr_rec.LAST_UPDATE_DATE,
              l_rpr_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := rpr_pk_csr%NOTFOUND;
    CLOSE rpr_pk_csr;
    RETURN(l_rpr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rpr_rec                      IN rpr_rec_type
  ) RETURN rpr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rpr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RG_PARTY_ROLES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rmpv_rec                     IN rmpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rmpv_rec_type IS
    CURSOR okc_rprv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            RGP_ID,
            RRD_ID,
            CPL_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rg_Party_Roles
     WHERE okc_rg_party_roles.id = p_id;
    l_okc_rprv_pk                  okc_rprv_pk_csr%ROWTYPE;
    l_rmpv_rec                     rmpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rprv_pk_csr (p_rmpv_rec.id);
    FETCH okc_rprv_pk_csr INTO
              l_rmpv_rec.ID,
              l_rmpv_rec.RGP_ID,
              l_rmpv_rec.RRD_ID,
              l_rmpv_rec.CPL_ID,
              l_rmpv_rec.DNZ_CHR_ID,
              l_rmpv_rec.OBJECT_VERSION_NUMBER,
              l_rmpv_rec.CREATED_BY,
              l_rmpv_rec.CREATION_DATE,
              l_rmpv_rec.LAST_UPDATED_BY,
              l_rmpv_rec.LAST_UPDATE_DATE,
              l_rmpv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_rprv_pk_csr%NOTFOUND;
    CLOSE okc_rprv_pk_csr;
    RETURN(l_rmpv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rmpv_rec                     IN rmpv_rec_type
  ) RETURN rmpv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rmpv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_RG_PARTY_ROLES_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rmpv_rec	IN rmpv_rec_type
  ) RETURN rmpv_rec_type IS
    l_rmpv_rec	rmpv_rec_type := p_rmpv_rec;
  BEGIN
    IF (l_rmpv_rec.rgp_id = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.rgp_id := NULL;
    END IF;
    IF (l_rmpv_rec.rrd_id = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.rrd_id := NULL;
    END IF;
    IF (l_rmpv_rec.cpl_id = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.cpl_id := NULL;
    END IF;
    IF (l_rmpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_rmpv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.object_version_number := NULL;
    END IF;
    IF (l_rmpv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.created_by := NULL;
    END IF;
    IF (l_rmpv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rmpv_rec.creation_date := NULL;
    END IF;
    IF (l_rmpv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rmpv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rmpv_rec.last_update_date := NULL;
    END IF;
    IF (l_rmpv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rmpv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_rmpv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKC_RG_PARTY_ROLES_V --
  --------------------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_rmpv_rec IN  rmpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rmpv_rec.id = OKC_API.G_MISS_NUM OR
       p_rmpv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rmpv_rec.rgp_id = OKC_API.G_MISS_NUM OR
          p_rmpv_rec.rgp_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rgp_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rmpv_rec.rrd_id = OKC_API.G_MISS_NUM OR
          p_rmpv_rec.rrd_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rrd_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rmpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_rmpv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rmpv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_rmpv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKC_RG_PARTY_ROLES_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_rmpv_rec IN rmpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN rmpv_rec_type,
    p_to	IN OUT NOCOPY rpr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgp_id := p_from.rgp_id;
    p_to.rrd_id := p_from.rrd_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rpr_rec_type,
    p_to	IN OUT NOCOPY rmpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgp_id := p_from.rgp_id;
    p_to.rrd_id := p_from.rrd_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKC_RG_PARTY_ROLES_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN rmpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_rpr_rec                      rpr_rec_type;
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
    l_return_status := Validate_Attributes(l_rmpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rmpv_rec);
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
  -- PL/SQL TBL validate_row for:RMPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN rmpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rmpv_tbl.COUNT > 0) THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rmpv_rec                     => p_rmpv_tbl(i));
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
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
  ---------------------------------------
  -- insert_row for:OKC_RG_PARTY_ROLES --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpr_rec                      IN rpr_rec_type,
    x_rpr_rec                      OUT NOCOPY rpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpr_rec                      rpr_rec_type := p_rpr_rec;
    l_def_rpr_rec                  rpr_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKC_RG_PARTY_ROLES --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rpr_rec IN  rpr_rec_type,
      x_rpr_rec OUT NOCOPY rpr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpr_rec := p_rpr_rec;
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
      p_rpr_rec,                         -- IN
      l_rpr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_RG_PARTY_ROLES(
        id,
        rgp_id,
        rrd_id,
        cpl_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_rpr_rec.id,
        l_rpr_rec.rgp_id,
        l_rpr_rec.rrd_id,
        l_rpr_rec.cpl_id,
        l_rpr_rec.dnz_chr_id,
        l_rpr_rec.object_version_number,
        l_rpr_rec.created_by,
        l_rpr_rec.creation_date,
        l_rpr_rec.last_updated_by,
        l_rpr_rec.last_update_date,
        l_rpr_rec.last_update_login);
    -- Set OUT values
    x_rpr_rec := l_rpr_rec;
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
  -----------------------------------------
  -- insert_row for:OKC_RG_PARTY_ROLES_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rmpv_rec                     rmpv_rec_type;
    l_def_rmpv_rec                 rmpv_rec_type;
    l_rpr_rec                      rpr_rec_type;
    lx_rpr_rec                     rpr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rmpv_rec	IN rmpv_rec_type
    ) RETURN rmpv_rec_type IS
      l_rmpv_rec	rmpv_rec_type := p_rmpv_rec;
    BEGIN
      l_rmpv_rec.CREATION_DATE := SYSDATE;
      l_rmpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rmpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rmpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rmpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rmpv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKC_RG_PARTY_ROLES_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_rmpv_rec IN  rmpv_rec_type,
      x_rmpv_rec OUT NOCOPY rmpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rmpv_rec := p_rmpv_rec;
      x_rmpv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_rmpv_rec := null_out_defaults(p_rmpv_rec);
    -- Set primary key value
    l_rmpv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rmpv_rec,                        -- IN
      l_def_rmpv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rmpv_rec := fill_who_columns(l_def_rmpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rmpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rmpv_rec, l_rpr_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpr_rec,
      lx_rpr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rpr_rec, l_def_rmpv_rec);
    -- Set OUT values
    x_rmpv_rec := l_def_rmpv_rec;
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
  -- PL/SQL TBL insert_row for:RMPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rmpv_tbl.COUNT > 0) THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rmpv_rec                     => p_rmpv_tbl(i),
          x_rmpv_rec                     => x_rmpv_tbl(i));
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
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
  -------------------------------------
  -- lock_row for:OKC_RG_PARTY_ROLES --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpr_rec                      IN rpr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rpr_rec IN rpr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RG_PARTY_ROLES
     WHERE ID = p_rpr_rec.id
       AND OBJECT_VERSION_NUMBER = p_rpr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rpr_rec IN rpr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RG_PARTY_ROLES
    WHERE ID = p_rpr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_RG_PARTY_ROLES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_RG_PARTY_ROLES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_rpr_rec);
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
      OPEN lchk_csr(p_rpr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rpr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rpr_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKC_RG_PARTY_ROLES_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN rmpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpr_rec                      rpr_rec_type;
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
    migrate(p_rmpv_rec, l_rpr_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpr_rec
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
  -- PL/SQL TBL lock_row for:RMPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN rmpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rmpv_tbl.COUNT > 0) THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rmpv_rec                     => p_rmpv_tbl(i));
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
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
  ---------------------------------------
  -- update_row for:OKC_RG_PARTY_ROLES --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpr_rec                      IN rpr_rec_type,
    x_rpr_rec                      OUT NOCOPY rpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpr_rec                      rpr_rec_type := p_rpr_rec;
    l_def_rpr_rec                  rpr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rpr_rec	IN rpr_rec_type,
      x_rpr_rec	OUT NOCOPY rpr_rec_type
    ) RETURN VARCHAR2 IS
      l_rpr_rec                      rpr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpr_rec := p_rpr_rec;
      -- Get current database values
      l_rpr_rec := get_rec(p_rpr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rpr_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.id := l_rpr_rec.id;
      END IF;
      IF (x_rpr_rec.rgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.rgp_id := l_rpr_rec.rgp_id;
      END IF;
      IF (x_rpr_rec.rrd_id = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.rrd_id := l_rpr_rec.rrd_id;
      END IF;
      IF (x_rpr_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.cpl_id := l_rpr_rec.cpl_id;
      END IF;
      IF (x_rpr_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.dnz_chr_id := l_rpr_rec.dnz_chr_id;
      END IF;
      IF (x_rpr_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.object_version_number := l_rpr_rec.object_version_number;
      END IF;
      IF (x_rpr_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.created_by := l_rpr_rec.created_by;
      END IF;
      IF (x_rpr_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpr_rec.creation_date := l_rpr_rec.creation_date;
      END IF;
      IF (x_rpr_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.last_updated_by := l_rpr_rec.last_updated_by;
      END IF;
      IF (x_rpr_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rpr_rec.last_update_date := l_rpr_rec.last_update_date;
      END IF;
      IF (x_rpr_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rpr_rec.last_update_login := l_rpr_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_RG_PARTY_ROLES --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rpr_rec IN  rpr_rec_type,
      x_rpr_rec OUT NOCOPY rpr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rpr_rec := p_rpr_rec;
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
      p_rpr_rec,                         -- IN
      l_rpr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rpr_rec, l_def_rpr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_RG_PARTY_ROLES
    SET RGP_ID = l_def_rpr_rec.rgp_id,
        RRD_ID = l_def_rpr_rec.rrd_id,
        CPL_ID = l_def_rpr_rec.cpl_id,
        DNZ_CHR_ID = l_def_rpr_rec.dnz_chr_id,
        OBJECT_VERSION_NUMBER = l_def_rpr_rec.object_version_number,
        CREATED_BY = l_def_rpr_rec.created_by,
        CREATION_DATE = l_def_rpr_rec.creation_date,
        LAST_UPDATED_BY = l_def_rpr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rpr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rpr_rec.last_update_login
    WHERE ID = l_def_rpr_rec.id;

    x_rpr_rec := l_def_rpr_rec;
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
  -----------------------------------------
  -- update_row for:OKC_RG_PARTY_ROLES_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_def_rmpv_rec                 rmpv_rec_type;
    l_rpr_rec                      rpr_rec_type;
    lx_rpr_rec                     rpr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rmpv_rec	IN rmpv_rec_type
    ) RETURN rmpv_rec_type IS
      l_rmpv_rec	rmpv_rec_type := p_rmpv_rec;
    BEGIN
      l_rmpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rmpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rmpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rmpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rmpv_rec	IN rmpv_rec_type,
      x_rmpv_rec	OUT NOCOPY rmpv_rec_type
    ) RETURN VARCHAR2 IS
      l_rmpv_rec                     rmpv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rmpv_rec := p_rmpv_rec;
      -- Get current database values
      l_rmpv_rec := get_rec(p_rmpv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rmpv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.id := l_rmpv_rec.id;
      END IF;
      IF (x_rmpv_rec.rgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.rgp_id := l_rmpv_rec.rgp_id;
      END IF;
      IF (x_rmpv_rec.rrd_id = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.rrd_id := l_rmpv_rec.rrd_id;
      END IF;
      IF (x_rmpv_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.cpl_id := l_rmpv_rec.cpl_id;
      END IF;
      IF (x_rmpv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.dnz_chr_id := l_rmpv_rec.dnz_chr_id;
      END IF;
      IF (x_rmpv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.object_version_number := l_rmpv_rec.object_version_number;
      END IF;
      IF (x_rmpv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.created_by := l_rmpv_rec.created_by;
      END IF;
      IF (x_rmpv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rmpv_rec.creation_date := l_rmpv_rec.creation_date;
      END IF;
      IF (x_rmpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.last_updated_by := l_rmpv_rec.last_updated_by;
      END IF;
      IF (x_rmpv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rmpv_rec.last_update_date := l_rmpv_rec.last_update_date;
      END IF;
      IF (x_rmpv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rmpv_rec.last_update_login := l_rmpv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_RG_PARTY_ROLES_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_rmpv_rec IN  rmpv_rec_type,
      x_rmpv_rec OUT NOCOPY rmpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rmpv_rec := p_rmpv_rec;
      x_rmpv_rec.OBJECT_VERSION_NUMBER := NVL(x_rmpv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rmpv_rec,                        -- IN
      l_rmpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rmpv_rec, l_def_rmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rmpv_rec := fill_who_columns(l_def_rmpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rmpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rmpv_rec, l_rpr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpr_rec,
      lx_rpr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rpr_rec, l_def_rmpv_rec);
    x_rmpv_rec := l_def_rmpv_rec;
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
  -- PL/SQL TBL update_row for:RMPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rmpv_tbl.COUNT > 0) THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rmpv_rec                     => p_rmpv_tbl(i),
          x_rmpv_rec                     => x_rmpv_tbl(i));
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
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
  ---------------------------------------
  -- delete_row for:OKC_RG_PARTY_ROLES --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpr_rec                      IN rpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rpr_rec                      rpr_rec_type:= p_rpr_rec;
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
    DELETE FROM OKC_RG_PARTY_ROLES
     WHERE ID = l_rpr_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKC_RG_PARTY_ROLES_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN rmpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_rpr_rec                      rpr_rec_type;
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
    migrate(l_rmpv_rec, l_rpr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rpr_rec
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
  -- PL/SQL TBL delete_row for:RMPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN rmpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rmpv_tbl.COUNT > 0) THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rmpv_rec                     => p_rmpv_tbl(i));
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
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

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_rg_party_roles_h
  (
      major_version,
      id,
      rgp_id,
      rrd_id,
      cpl_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      p_major_version,
      id,
      rgp_id,
      rrd_id,
      cpl_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_rg_party_roles
 WHERE dnz_chr_id = p_chr_id;

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
INSERT INTO okc_rg_party_roles
  (
      id,
      rgp_id,
      rrd_id,
      cpl_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      rgp_id,
      rrd_id,
      cpl_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_rg_party_roles_h
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
--
END OKC_RMP_PVT;

/
