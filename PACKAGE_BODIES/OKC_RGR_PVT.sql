--------------------------------------------------------
--  DDL for Package Body OKC_RGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RGR_PVT" AS
/* $Header: OKCSRGRB.pls 120.0 2005/05/25 23:11:25 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  **************************/

  g_insert_mode boolean := FALSE;

  FUNCTION Validate_Attributes
    (p_rgrv_rec IN  rgrv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD          CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR          CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	          CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_VIEW                      CONSTANT  VARCHAR2(200) := 'OKC_RG_DEF_RULES_V';
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  G_RETURN_STATUS	          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_uniqueness
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_uniqueness(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgrv_rec      IN    rgrv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 -- l_unq_tbl  OKC_UTIL.unq_tbl_type;

    -- ------------------------------------------------------
    -- To check for any matching row, for unique check
    -- ------------------------------------------------------
    CURSOR cur_rgr IS
    SELECT 'x'
    FROM   okc_rg_def_rules
    WHERE  rgd_code  = p_rgrv_rec.RGD_CODE
    AND    rdf_code  = p_rgrv_rec.RDF_CODE;

    l_row_found   BOOLEAN := False;
    l_dummy       VARCHAR2(1);

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('100: Entered validate_uniqueness', 2);
    END IF;

    -- ------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call earlier was not using
    -- the bind variables and parses everytime, replaced with
    -- the explicit cursors above, for identical function.
    -- ------------------------------------------------------
    IF (     p_rgrv_rec.RGD_CODE IS NOT NULL
         AND p_rgrv_rec.RDF_CODE IS NOT NULL
	    AND p_rgrv_rec.RGD_CODE <> OKC_API.G_MISS_CHAR
	    AND p_rgrv_rec.RDF_CODE <> OKC_API.G_MISS_CHAR )
    THEN
        OPEN  cur_rgr;
	   FETCH cur_rgr INTO l_dummy;
	   l_row_found := cur_rgr%FOUND;
	   CLOSE cur_rgr;
    END IF;

    IF (l_row_found)
    THEN
	   -- Display the newly defined error message
	   OKC_API.set_message(G_APP_NAME,
	                      'OKC_DUP_RG_DEF_RULES');
        l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

        -- notify caller of the return status
        x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving validate_uniqueness', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('300: Exiting validate_uniqueness:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        -- store SQL error message on message stack
        OKC_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1	     => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

        -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_uniqueness;

  --
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
    p_rgrv_rec      IN    rgrv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rgdv_csr IS
      SELECT 'x'
        FROM FND_LOOKUP_VALUES rgdv
       WHERE rgdv.LOOKUP_CODE = p_rgrv_rec.rgd_code
         AND rgdv.lookup_type = 'OKC_RULE_GROUP_DEF';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('400: Entered validate_rgd_code', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rgrv_rec.rgd_code = OKC_API.G_MISS_CHAR OR
        p_rgrv_rec.rgd_code IS NULL) THEN
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

    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving validate_rgd_code', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_rgd_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_rgd_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- Procedure Name  : validate_rdf_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rdf_code(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgrv_rec      IN    rgrv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
/* -- /striping/
    CURSOR l_rdfv_csr IS
      SELECT 'x'
        FROM FND_LOOKUP_VALUES rdfv
       WHERE rdfv.LOOKUP_CODE = p_rgrv_rec.rdf_code
         AND rdfv.lookup_type = 'OKC_RULE_DEF';
*/
-- /striping/
    CURSOR l_rdfv_csr IS
      SELECT 'x'
        FROM okc_rule_defs_b rdfv
       WHERE rdfv.RULE_CODE = p_rgrv_rec.rdf_code;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('800: Entered validate_rdf_code', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rgrv_rec.rdf_code = OKC_API.G_MISS_CHAR OR
        p_rgrv_rec.rdf_code IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rdf_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_rdfv_csr;
    FETCH l_rdfv_csr INTO l_dummy_var;
    CLOSE l_rdfv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
       --set error message in message stack
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rdf_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('900: Leaving validate_rdf_code', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Exiting validate_rdf_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Exiting validate_rdf_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
    IF l_rdfv_csr%ISOPEN THEN
      CLOSE l_rdfv_csr;
    END IF;

  END validate_rdf_code;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_optional_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_optional_yn(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgrv_rec      IN    rgrv_rec_type
  ) IS
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('1200: Entered validate_optional_yn', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data
    IF (p_rgrv_rec.optional_yn <> OKC_API.G_MISS_CHAR OR
        p_rgrv_rec.optional_yn IS NOT NULL) THEN

      -- check allowed values
      IF (UPPER(p_rgrv_rec.optional_yn) NOT IN ('Y','N')) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'optional_yn');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1300: Leaving validate_optional_yn', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1400: Exiting validate_optional_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_optional_yn:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
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
    -- verify that cursor was closed

  END validate_optional_yn;
--
  PROCEDURE validate_min_cardinality(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgrv_rec      IN    rgrv_rec_type
  ) IS
/*
     Validations :
  1. If OPTIONAL_YN = 'N' then MIN_CARDINALITY > 0
  2. If OPTIONAL_YN = 'Y' then MIN_CARDINALITY = 0
  3. MIN_CARDINALITY <= MAX_CARDINALITY
*/

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('1600: Entered validate_min_cardinality', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- min_cardinality > 0 for optional_yn = N
    IF ( NVL(p_rgrv_rec.optional_yn,'Y') = 'N' AND
         p_rgrv_rec.min_cardinality  IS NOT NULL ) THEN

        IF p_rgrv_rec.min_cardinality <= 0 THEN
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_INVALID_VALUE,
            p_token1       => G_COL_NAME_TOKEN,
            p_token1_value => 'Minimum');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

          -- halt validation
          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;  -- error message

    END IF; -- case 1

    -- min_cardinality = 0 for optional_yn = Y
    IF ( NVL(p_rgrv_rec.optional_yn,'Y') = 'Y' AND
         p_rgrv_rec.min_cardinality  IS NOT NULL ) THEN

        IF p_rgrv_rec.min_cardinality <> 0 THEN
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_INVALID_VALUE,
            p_token1       => G_COL_NAME_TOKEN,
            p_token1_value => 'Minimum');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

          -- halt validation
          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;  -- error message

    END IF; -- case 2


   -- min_cardinality <= max_cardinality
   IF ( p_rgrv_rec.min_cardinality IS NOT NULL AND
        p_rgrv_rec.max_cardinality IS NOT NULL ) THEN

        IF p_rgrv_rec.min_cardinality > p_rgrv_rec.max_cardinality THEN
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_INVALID_VALUE,
            p_token1       => G_COL_NAME_TOKEN,
            p_token1_value => 'Minimum');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

          -- halt validation
          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;  -- error message

   END IF; -- case 3

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Leaving validate_min_cardinality', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting validate_min_cardinality:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting validate_min_cardinality:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1          => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


  END validate_min_cardinality;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_pricing_related_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_pricing_related_yn(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgrv_rec      IN    rgrv_rec_type
  ) IS
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('2000: Entered validate_pricing_related_yn', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data
    IF (p_rgrv_rec.pricing_related_yn <> OKC_API.G_MISS_CHAR OR
        p_rgrv_rec.pricing_related_yn IS NOT NULL) THEN

      -- check allowed values
      IF (UPPER(p_rgrv_rec.pricing_related_yn) NOT IN ('Y','N')) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'pricing_related_yn');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Leaving validate_pricing_related_yn', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting validate_pricing_related_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Exiting validate_pricing_related_yn:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed

  END validate_pricing_related_yn;
--

--
  -- Start of comments
  --
  -- Procedure Name  : validate_access_level
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_access_level(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rgrv_rec      IN    rgrv_rec_type
  ) IS

    l_dummy_var   VARCHAR2(1) := '?';

    CURSOR l_rgdv_csr IS
      SELECT 'x'
        FROM FND_LOOKUP_VALUES rgdv
       WHERE rgdv.LOOKUP_CODE = p_rgrv_rec.access_level
         AND rgdv.lookup_type = 'OKC_SEED_ACCESS_LEVEL_SU';

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('2400: Entered validate_access_level', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data
    IF (p_rgrv_rec.access_level <> OKC_API.G_MISS_CHAR OR
        p_rgrv_rec.access_level IS NOT NULL) THEN

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
          p_token1_value => 'access_level');


        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Leaving validate_access_level', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting validate_access_level:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2700: Exiting validate_access_level:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed

  END validate_access_level;
--

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
    p_rgrv_rec IN  rgrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('2800: Entered Validate_Attributes', 2);
    END IF;

    -- call each column-level validation

    validate_rgd_code(
      x_return_status => l_return_status,
      p_rgrv_rec      => p_rgrv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_rdf_code(
      x_return_status => l_return_status,
      p_rgrv_rec      => p_rgrv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_optional_yn(
      x_return_status => l_return_status,
      p_rgrv_rec      => p_rgrv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_min_cardinality
    (
     x_return_status => l_return_status,
     p_rgrv_rec      => p_rgrv_rec
    );

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_pricing_related_yn(
      x_return_status => l_return_status,
      p_rgrv_rec      => p_rgrv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_access_level(
      x_return_status => l_return_status,
      p_rgrv_rec      => p_rgrv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    -- Only call validate uniqueness when inserting a record
    -- calling when updating a record will cause an error.
    IF g_insert_mode THEN
      validate_uniqueness(
        x_return_status => l_return_status,
        p_rgrv_rec      => p_rgrv_rec);

      -- store the highest degree of error
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
      END IF;
    END IF;
--
    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Leaving Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- return status to caller
    RETURN(x_return_status);

  EXCEPTION
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting Validate_Attributes:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- FUNCTION get_rec for: OKC_RG_DEF_RULES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rgr_rec                      IN rgr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rgr_rec_type IS
    CURSOR rgr_pk_csr (p_rgd_code           IN VARCHAR2,
                       p_rdf_code           IN VARCHAR2) IS
    SELECT
            RGD_CODE,
            RDF_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            OPTIONAL_YN,
            LAST_UPDATE_LOGIN,
            MIN_CARDINALITY,
            MAX_CARDINALITY,
            PRICING_RELATED_YN,
            ACCESS_LEVEL
      FROM Okc_Rg_Def_Rules
     WHERE okc_rg_def_rules.rgd_code = p_rgd_code
       AND okc_rg_def_rules.rdf_code = p_rdf_code;
    l_rgr_pk                       rgr_pk_csr%ROWTYPE;
    l_rgr_rec                      rgr_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('3500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rgr_pk_csr (p_rgr_rec.rgd_code,
                     p_rgr_rec.rdf_code);
    FETCH rgr_pk_csr INTO
              l_rgr_rec.RGD_CODE,
              l_rgr_rec.RDF_CODE,
              l_rgr_rec.OBJECT_VERSION_NUMBER,
              l_rgr_rec.CREATED_BY,
              l_rgr_rec.CREATION_DATE,
              l_rgr_rec.LAST_UPDATED_BY,
              l_rgr_rec.LAST_UPDATE_DATE,
              l_rgr_rec.OPTIONAL_YN,
              l_rgr_rec.LAST_UPDATE_LOGIN,
              l_rgr_rec.MIN_CARDINALITY,
              l_rgr_rec.MAX_CARDINALITY,
              l_rgr_rec.PRICING_RELATED_YN,
              l_rgr_rec.ACCESS_LEVEL;
    x_no_data_found := rgr_pk_csr%NOTFOUND;
    CLOSE rgr_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Leaving Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_rgr_rec);

  END get_rec;

  FUNCTION get_rec (
    p_rgr_rec                      IN rgr_rec_type
  ) RETURN rgr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_rgr_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RG_DEF_RULES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rgrv_rec                     IN rgrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rgrv_rec_type IS
    CURSOR okc_rgrv_pk_csr (p_rgd_code           IN VARCHAR2,
                            p_rdf_code           IN VARCHAR2) IS
    SELECT
            RGD_CODE,
            RDF_CODE,
            OBJECT_VERSION_NUMBER,
            OPTIONAL_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            MIN_CARDINALITY,
            MAX_CARDINALITY,
            PRICING_RELATED_YN,
            ACCESS_LEVEL
      FROM Okc_Rg_Def_Rules_V
     WHERE okc_rg_def_rules_v.rgd_code = p_rgd_code
       AND okc_rg_def_rules_v.rdf_code = p_rdf_code;
    l_okc_rgrv_pk                  okc_rgrv_pk_csr%ROWTYPE;
    l_rgrv_rec                     rgrv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('3700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rgrv_pk_csr (p_rgrv_rec.rgd_code,
                          p_rgrv_rec.rdf_code);
    FETCH okc_rgrv_pk_csr INTO
              l_rgrv_rec.RGD_CODE,
              l_rgrv_rec.RDF_CODE,
              l_rgrv_rec.OBJECT_VERSION_NUMBER,
              l_rgrv_rec.OPTIONAL_YN,
              l_rgrv_rec.CREATED_BY,
              l_rgrv_rec.CREATION_DATE,
              l_rgrv_rec.LAST_UPDATED_BY,
              l_rgrv_rec.LAST_UPDATE_DATE,
              l_rgrv_rec.LAST_UPDATE_LOGIN,
              l_rgrv_rec.MIN_CARDINALITY,
              l_rgrv_rec.MAX_CARDINALITY,
              l_rgrv_rec.PRICING_RELATED_YN,
              l_rgrv_rec.ACCESS_LEVEL;
    x_no_data_found := okc_rgrv_pk_csr%NOTFOUND;
    CLOSE okc_rgrv_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_rgrv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_rgrv_rec                     IN rgrv_rec_type
  ) RETURN rgrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_rgrv_rec, l_row_notfound));

  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_RG_DEF_RULES_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rgrv_rec	IN rgrv_rec_type
  ) RETURN rgrv_rec_type IS
    l_rgrv_rec	rgrv_rec_type := p_rgrv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('3900: Entered null_out_defaults', 2);
    END IF;

    IF (l_rgrv_rec.rgd_code = OKC_API.G_MISS_CHAR) THEN
      l_rgrv_rec.rgd_code := NULL;
    END IF;
    IF (l_rgrv_rec.rdf_code = OKC_API.G_MISS_CHAR) THEN
      l_rgrv_rec.rdf_code := NULL;
    END IF;
    IF (l_rgrv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rgrv_rec.object_version_number := NULL;
    END IF;
    IF (l_rgrv_rec.optional_yn = OKC_API.G_MISS_CHAR) THEN
      l_rgrv_rec.optional_yn := NULL;
    END IF;
    IF (l_rgrv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rgrv_rec.created_by := NULL;
    END IF;
    IF (l_rgrv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rgrv_rec.creation_date := NULL;
    END IF;
    IF (l_rgrv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rgrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rgrv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rgrv_rec.last_update_date := NULL;
    END IF;
    IF (l_rgrv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rgrv_rec.last_update_login := NULL;
    END IF;
    IF (l_rgrv_rec.min_cardinality = OKC_API.G_MISS_NUM) THEN
      l_rgrv_rec.min_cardinality := NULL;
    END IF;
    IF (l_rgrv_rec.max_cardinality = OKC_API.G_MISS_NUM) THEN
      l_rgrv_rec.max_cardinality := NULL;
    END IF;
    IF (l_rgrv_rec.pricing_related_yn = OKC_API.G_MISS_CHAR) THEN
      l_rgrv_rec.pricing_related_yn := NULL;
    END IF;
    IF (l_rgrv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_rgrv_rec.access_level := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('500: Leaving  null_out_defaults ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_rgrv_rec);

  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_RG_DEF_RULES_V --
  ------------------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_rgrv_rec IN  rgrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('4000: Entered Validate_Attributes', 2);
    END IF;

    IF p_rgrv_rec.rgd_code = OKC_API.G_MISS_CHAR OR
       p_rgrv_rec.rgd_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rgd_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rgrv_rec.rdf_code = OKC_API.G_MISS_CHAR OR
          p_rgrv_rec.rdf_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rdf_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rgrv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_rgrv_rec.object_version_number IS NULL
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
  --------------------------------------------
  -- Validate_Record for:OKC_RG_DEF_RULES_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_rgrv_rec IN rgrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN rgrv_rec_type,
    p_to	IN OUT NOCOPY rgr_rec_type
  ) IS
  BEGIN

    p_to.rgd_code := p_from.rgd_code;
    p_to.rdf_code := p_from.rdf_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.optional_yn := p_from.optional_yn;
    p_to.last_update_login := p_from.last_update_login;
    p_to.min_cardinality := p_from.min_cardinality;
    p_to.max_cardinality := p_from.max_cardinality;
    p_to.pricing_related_yn := p_from.pricing_related_yn;
    p_to.access_level := p_from.access_level;

  END migrate;
  PROCEDURE migrate (
    p_from	IN rgr_rec_type,
    p_to	IN OUT NOCOPY rgrv_rec_type
  ) IS
  BEGIN

    p_to.rgd_code := p_from.rgd_code;
    p_to.rdf_code := p_from.rdf_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.optional_yn := p_from.optional_yn;
    p_to.last_update_login := p_from.last_update_login;
    p_to.min_cardinality := p_from.min_cardinality;
    p_to.max_cardinality := p_from.max_cardinality;
    p_to.pricing_related_yn := p_from.pricing_related_yn;
    p_to.access_level := p_from.access_level;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKC_RG_DEF_RULES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgrv_rec                     rgrv_rec_type := p_rgrv_rec;
    l_rgr_rec                      rgr_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('4400: Entered validate_row', 2);
    END IF;

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
    l_return_status := Validate_Attributes(l_rgrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rgrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4500: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4600: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:RGRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('4900: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgrv_tbl.COUNT > 0) THEN
      i := p_rgrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgrv_rec                     => p_rgrv_tbl(i));
        EXIT WHEN (i = p_rgrv_tbl.LAST);
        i := p_rgrv_tbl.NEXT(i);
      END LOOP;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('5000: Leaving validate_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5100: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5200: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- insert_row for:OKC_RG_DEF_RULES --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgr_rec                      IN rgr_rec_type,
    x_rgr_rec                      OUT NOCOPY rgr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgr_rec                      rgr_rec_type := p_rgr_rec;
    l_def_rgr_rec                  rgr_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKC_RG_DEF_RULES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_rgr_rec IN  rgr_rec_type,
      x_rgr_rec OUT NOCOPY rgr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_rgr_rec := p_rgr_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('5500: Entered insert_row', 2);
    END IF;

    g_insert_mode := TRUE;
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
      p_rgr_rec,                         -- IN
      l_rgr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_RG_DEF_RULES(
        rgd_code,
        rdf_code,
        object_version_number,
	   application_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        optional_yn,
        last_update_login,
        min_cardinality,
        max_cardinality,
        pricing_related_yn,
        access_level)
      VALUES (
        l_rgr_rec.rgd_code,
        l_rgr_rec.rdf_code,
        l_rgr_rec.object_version_number,
	   fnd_global.resp_appl_id,
        l_rgr_rec.created_by,
        l_rgr_rec.creation_date,
        l_rgr_rec.last_updated_by,
        l_rgr_rec.last_update_date,
        l_rgr_rec.optional_yn,
        l_rgr_rec.last_update_login,
        l_rgr_rec.min_cardinality,
        l_rgr_rec.max_cardinality,
        l_rgr_rec.pricing_related_yn,
        l_rgr_rec.access_level);
    -- Set OUT values
    x_rgr_rec := l_rgr_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5600: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5700: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- insert_row for:OKC_RG_DEF_RULES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type,
    x_rgrv_rec                     OUT NOCOPY rgrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgrv_rec                     rgrv_rec_type;
    l_def_rgrv_rec                 rgrv_rec_type;
    l_rgr_rec                      rgr_rec_type;
    lx_rgr_rec                     rgr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rgrv_rec	IN rgrv_rec_type
    ) RETURN rgrv_rec_type IS
      l_rgrv_rec	rgrv_rec_type := p_rgrv_rec;
    BEGIN

      l_rgrv_rec.CREATION_DATE := SYSDATE;
      l_rgrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rgrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rgrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rgrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rgrv_rec);

    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKC_RG_DEF_RULES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rgrv_rec IN  rgrv_rec_type,
      x_rgrv_rec OUT NOCOPY rgrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_rgrv_rec := p_rgrv_rec;
      x_rgrv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('6200: Entered insert_row', 2);
    END IF;

    g_insert_mode := TRUE;
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
    l_rgrv_rec := null_out_defaults(p_rgrv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rgrv_rec,                        -- IN
      l_def_rgrv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rgrv_rec := fill_who_columns(l_def_rgrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rgrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rgrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rgrv_rec, l_rgr_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgr_rec,
      lx_rgr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rgr_rec, l_def_rgrv_rec);
    -- Set OUT values
    x_rgrv_rec := l_def_rgrv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6300: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6400: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6500: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:RGRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type,
    x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('6700: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgrv_tbl.COUNT > 0) THEN
      i := p_rgrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgrv_rec                     => p_rgrv_tbl(i),
          x_rgrv_rec                     => x_rgrv_tbl(i));
        EXIT WHEN (i = p_rgrv_tbl.LAST);
        i := p_rgrv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- lock_row for:OKC_RG_DEF_RULES --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgr_rec                      IN rgr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rgr_rec IN rgr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RG_DEF_RULES
     WHERE RGD_CODE = p_rgr_rec.rgd_code
       AND RDF_CODE = p_rgr_rec.rdf_code
       AND OBJECT_VERSION_NUMBER = p_rgr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rgr_rec IN rgr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RG_DEF_RULES
    WHERE RGD_CODE = p_rgr_rec.rgd_code
       AND RDF_CODE = p_rgr_rec.rdf_code;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_RG_DEF_RULES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_RG_DEF_RULES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('7200: Entered lock_row', 2);
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('7300: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_rgr_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

 IF (l_debug = 'Y') THEN
    okc_debug.log('7400: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7500: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_rgr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rgr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rgr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('7600: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7700: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7900: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- lock_row for:OKC_RG_DEF_RULES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgr_rec                      rgr_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('8000: Entered lock_row', 2);
    END IF;

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
    migrate(p_rgrv_rec, l_rgr_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('8100: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8300: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:RGRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('8500: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgrv_tbl.COUNT > 0) THEN
      i := p_rgrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgrv_rec                     => p_rgrv_tbl(i));
        EXIT WHEN (i = p_rgrv_tbl.LAST);
        i := p_rgrv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8700: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8800: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- update_row for:OKC_RG_DEF_RULES --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgr_rec                      IN rgr_rec_type,
    x_rgr_rec                      OUT NOCOPY rgr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgr_rec                      rgr_rec_type := p_rgr_rec;
    l_def_rgr_rec                  rgr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rgr_rec	IN rgr_rec_type,
      x_rgr_rec	OUT NOCOPY rgr_rec_type
    ) RETURN VARCHAR2 IS
      l_rgr_rec                      rgr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('9000: Entered populate_new_record', 2);
    END IF;

      x_rgr_rec := p_rgr_rec;
      -- Get current database values
      l_rgr_rec := get_rec(p_rgr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rgr_rec.rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgr_rec.rgd_code := l_rgr_rec.rgd_code;
      END IF;
      IF (x_rgr_rec.rdf_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgr_rec.rdf_code := l_rgr_rec.rdf_code;
      END IF;
      IF (x_rgr_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rgr_rec.object_version_number := l_rgr_rec.object_version_number;
      END IF;
      IF (x_rgr_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgr_rec.created_by := l_rgr_rec.created_by;
      END IF;
      IF (x_rgr_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgr_rec.creation_date := l_rgr_rec.creation_date;
      END IF;
      IF (x_rgr_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgr_rec.last_updated_by := l_rgr_rec.last_updated_by;
      END IF;
      IF (x_rgr_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgr_rec.last_update_date := l_rgr_rec.last_update_date;
      END IF;
      IF (x_rgr_rec.optional_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rgr_rec.optional_yn := l_rgr_rec.optional_yn;
      END IF;
      IF (x_rgr_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rgr_rec.last_update_login := l_rgr_rec.last_update_login;
      END IF;
      IF (x_rgr_rec.min_cardinality = OKC_API.G_MISS_NUM)
      THEN
        x_rgr_rec.min_cardinality := l_rgr_rec.min_cardinality;
      END IF;
      IF (x_rgr_rec.max_cardinality = OKC_API.G_MISS_NUM)
      THEN
        x_rgr_rec.max_cardinality := l_rgr_rec.max_cardinality;
      END IF;
      IF (x_rgr_rec.pricing_related_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rgr_rec.pricing_related_yn := l_rgr_rec.pricing_related_yn;
      END IF;
      IF (x_rgr_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_rgr_rec.access_level := l_rgr_rec.access_level;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_RG_DEF_RULES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_rgr_rec IN  rgr_rec_type,
      x_rgr_rec OUT NOCOPY rgr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_rgr_rec := p_rgr_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('9200: Entered update_row', 2);
    END IF;

    g_insert_mode := FALSE;
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
      p_rgr_rec,                         -- IN
      l_rgr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rgr_rec, l_def_rgr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_RG_DEF_RULES
    SET OBJECT_VERSION_NUMBER = l_def_rgr_rec.object_version_number,
        CREATED_BY = l_def_rgr_rec.created_by,
        CREATION_DATE = l_def_rgr_rec.creation_date,
        LAST_UPDATED_BY = l_def_rgr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rgr_rec.last_update_date,
        OPTIONAL_YN = l_def_rgr_rec.optional_yn,
        LAST_UPDATE_LOGIN = l_def_rgr_rec.last_update_login,
        MIN_CARDINALITY = l_def_rgr_rec.min_cardinality,
        MAX_CARDINALITY = l_def_rgr_rec.max_cardinality,
        PRICING_RELATED_YN = l_def_rgr_rec.pricing_related_yn,
        ACCESS_LEVEL = l_def_rgr_rec.access_level
    WHERE RGD_CODE = l_def_rgr_rec.rgd_code
      AND RDF_CODE = l_def_rgr_rec.rdf_code;

    x_rgr_rec := l_def_rgr_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9300: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9400: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9500: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- update_row for:OKC_RG_DEF_RULES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type,
    x_rgrv_rec                     OUT NOCOPY rgrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgrv_rec                     rgrv_rec_type := p_rgrv_rec;
    l_def_rgrv_rec                 rgrv_rec_type;
    l_rgr_rec                      rgr_rec_type;
    lx_rgr_rec                     rgr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rgrv_rec	IN rgrv_rec_type
    ) RETURN rgrv_rec_type IS
      l_rgrv_rec	rgrv_rec_type := p_rgrv_rec;
    BEGIN

      l_rgrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rgrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rgrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rgrv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rgrv_rec	IN rgrv_rec_type,
      x_rgrv_rec	OUT NOCOPY rgrv_rec_type
    ) RETURN VARCHAR2 IS
      l_rgrv_rec                     rgrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('9800: Entered populate_new_record', 2);
    END IF;

      x_rgrv_rec := p_rgrv_rec;
      -- Get current database values
      l_rgrv_rec := get_rec(p_rgrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rgrv_rec.rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgrv_rec.rgd_code := l_rgrv_rec.rgd_code;
      END IF;
      IF (x_rgrv_rec.rdf_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rgrv_rec.rdf_code := l_rgrv_rec.rdf_code;
      END IF;
      IF (x_rgrv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rgrv_rec.object_version_number := l_rgrv_rec.object_version_number;
      END IF;
      IF (x_rgrv_rec.optional_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rgrv_rec.optional_yn := l_rgrv_rec.optional_yn;
      END IF;
      IF (x_rgrv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgrv_rec.created_by := l_rgrv_rec.created_by;
      END IF;
      IF (x_rgrv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgrv_rec.creation_date := l_rgrv_rec.creation_date;
      END IF;
      IF (x_rgrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rgrv_rec.last_updated_by := l_rgrv_rec.last_updated_by;
      END IF;
      IF (x_rgrv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rgrv_rec.last_update_date := l_rgrv_rec.last_update_date;
      END IF;
      IF (x_rgrv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rgrv_rec.last_update_login := l_rgrv_rec.last_update_login;
      END IF;
      IF (x_rgrv_rec.min_cardinality = OKC_API.G_MISS_NUM)
      THEN
        x_rgrv_rec.min_cardinality := l_rgrv_rec.min_cardinality;
      END IF;
      IF (x_rgrv_rec.max_cardinality = OKC_API.G_MISS_NUM)
      THEN
        x_rgrv_rec.max_cardinality := l_rgrv_rec.max_cardinality;
      END IF;
      IF (x_rgrv_rec.pricing_related_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rgrv_rec.pricing_related_yn := l_rgrv_rec.pricing_related_yn;
      END IF;
      IF (x_rgrv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_rgrv_rec.access_level := l_rgrv_rec.access_level;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_RG_DEF_RULES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rgrv_rec IN  rgrv_rec_type,
      x_rgrv_rec OUT NOCOPY rgrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_rgrv_rec := p_rgrv_rec;
      x_rgrv_rec.OBJECT_VERSION_NUMBER := NVL(x_rgrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    g_insert_mode := FALSE;
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
      p_rgrv_rec,                        -- IN
      l_rgrv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rgrv_rec, l_def_rgrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rgrv_rec := fill_who_columns(l_def_rgrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rgrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rgrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rgrv_rec, l_rgr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgr_rec,
      lx_rgr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rgr_rec, l_def_rgrv_rec);
    x_rgrv_rec := l_def_rgrv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10100: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10200: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:RGRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type,
    x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('10500: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgrv_tbl.COUNT > 0) THEN
      i := p_rgrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgrv_rec                     => p_rgrv_tbl(i),
          x_rgrv_rec                     => x_rgrv_tbl(i));
        EXIT WHEN (i = p_rgrv_tbl.LAST);
        i := p_rgrv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10600: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10700: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10800: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- delete_row for:OKC_RG_DEF_RULES --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgr_rec                      IN rgr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgr_rec                      rgr_rec_type:= p_rgr_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('11000: Entered delete_row', 2);
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_RG_DEF_RULES
     WHERE RGD_CODE = l_rgr_rec.rgd_code AND
     RDF_CODE = l_rgr_rec.rdf_code;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11200: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11400: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- delete_row for:OKC_RG_DEF_RULES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rgrv_rec                     rgrv_rec_type := p_rgrv_rec;
    l_rgr_rec                      rgr_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('11500: Entered delete_row', 2);
    END IF;

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
    migrate(l_rgrv_rec, l_rgr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rgr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11600: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11700: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11800: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11900: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:RGRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RGR_PVT');
       okc_debug.log('12000: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rgrv_tbl.COUNT > 0) THEN
      i := p_rgrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rgrv_rec                     => p_rgrv_tbl(i));
        EXIT WHEN (i = p_rgrv_tbl.LAST);
        i := p_rgrv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('12100: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12200: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12300: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12400: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

END OKC_RGR_PVT;

/
