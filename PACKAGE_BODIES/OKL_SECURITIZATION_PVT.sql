--------------------------------------------------------
--  DDL for Package Body OKL_SECURITIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SECURITIZATION_PVT" AS
/* $Header: OKLRSZSB.pls 120.17.12010000.3 2009/11/10 10:48:59 rpillay ship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
 G_POC_STS_NEW          CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_NEW;
 G_POC_STS_ACTIVE       CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_ACTIVE;
 G_POC_STS_INACTIVE     CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_INACTIVE;
 G_FINAL_DATE           CONSTANT DATE         := Okl_Pool_Pvt.G_FINAL_DATE;

 G_STY_INV_RENT_BUYBACK     CONSTANT VARCHAR2(30) := 'INVESTOR_RENT_BUYBACK';
 G_STY_INV_RESIDUAL_BUYBACK CONSTANT VARCHAR2(30) := 'INVESTOR_RESIDUAL_BUYBACK';
 G_STY_SUBCLASS_RENT        CONSTANT VARCHAR2(4)  := 'RENT';
 G_STY_SUBCLASS_RESIDUAL    CONSTANT VARCHAR2(10) := 'RESIDUAL';
 G_STM_SGN_CODE_MANUAL      CONSTANT VARCHAR2(4)  := 'MANL';
 G_STM_SAY_CODE_CURR        CONSTANT VARCHAR2(4)  := 'CURR';
 G_STM_ACTIVE_Y             CONSTANT VARCHAR2(1)  := 'Y';
 G_STM_SOURCE_TABLE         CONSTANT VARCHAR2(15) := 'OKL_K_HEADERS';

--ankushar Bug#6740000, Added new Stream type Subclass for Loan Contract
G_STY_SUBCLASS_LOAN_PAYMENT CONSTANT VARCHAR2(20) := 'LOAN_PAYMENT';
G_STY_INV_PRINCIPAL_BUYBACK CONSTANT VARCHAR2(30) := 'INVESTOR_PRINCIPAL_BUYBACK';
G_STY_INV_INTEREST_BUYBACK  CONSTANT VARCHAR2(30) := 'INVESTOR_INTEREST_BUYBACK';
G_STY_INV_PPD_BUYBACK       CONSTANT VARCHAR2(30) := 'INVESTOR_PAYDOWN_BUYBACK';

 G_SECURITIZED_CODE_Y         CONSTANT VARCHAR2(1) := 'Y';
 G_SECURITIZED_CODE_N         CONSTANT VARCHAR2(1) := 'N';
 -- sosharma added codes for tranaction_status
   G_POOL_TRX_STATUS_COMPLETE               CONSTANT VARCHAR2(30) := 'COMPLETE';

----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_khr_securitized
-- Description     : Checks if a contract is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION is_khr_securitized(
   p_khr_id                        IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
 ) RETURN VARCHAR
IS
    l_dummy VARCHAR2(1);
    x_value VARCHAR2(1) := Okl_Api.G_FALSE;
    l_row_found BOOLEAN := FALSE;
    v_sql VARCHAR2(4000);

   -- case 1
  CURSOR c_khr_def(p_khr_id okc_k_headers_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) >= TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );

  -- case 2
  CURSOR c_khr_gr(p_khr_id okc_k_headers_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) > TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );


  -- case 3
  CURSOR c_khr_ls(p_khr_id okc_k_headers_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) < TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );
  -- case 4
  CURSOR c_khr_eq(p_khr_id okc_k_headers_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) = TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );
BEGIN

  IF (p_effective_date_operator = G_GREATER_THAN) THEN

    OPEN c_khr_gr(p_khr_id, p_effective_date);
    FETCH c_khr_gr INTO l_dummy;
    l_row_found := c_khr_gr%FOUND;
    CLOSE c_khr_gr;
  ELSIF (p_effective_date_operator = G_LESS_THAN) THEN

    OPEN c_khr_ls(p_khr_id, p_effective_date);
    FETCH c_khr_ls INTO l_dummy;
    l_row_found := c_khr_ls%FOUND;
    CLOSE c_khr_ls;
  ELSIF (p_effective_date_operator = G_EQUAL_TO) THEN

    OPEN c_khr_eq(p_khr_id, p_effective_date);
    FETCH c_khr_eq INTO l_dummy;
    l_row_found := c_khr_eq%FOUND;
    CLOSE c_khr_eq;

  ELSIF (p_effective_date_operator = G_GREATER_THAN_EQUAL_TO) THEN

    OPEN c_khr_def(p_khr_id, p_effective_date);
    FETCH c_khr_def INTO l_dummy;
    l_row_found := c_khr_def%FOUND;
    CLOSE c_khr_def;

  END IF;


  IF l_row_found THEN
    x_value := Okl_Api.G_TRUE;
  ELSE
    x_value := Okl_Api.G_FALSE;
  END IF;


  RETURN x_value;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END is_khr_securitized;

-----------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : check_khr_securitized
-- Description     : Checks if a contract is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
PROCEDURE check_khr_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
-- cklee 08-08-2003 11.5.10
   ,x_value                        OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'check_khr_securitized_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

CURSOR c_inv_khr(p_khr_id okc_k_headers_b.id%TYPE) IS
  SELECT ph.khr_id -- inv agreemnet id
FROM okl_pools ph
WHERE EXISTS (SELECT '1'
              FROM okl_pool_contents pl
              WHERE pl.pol_id = ph.id
              AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
              AND   pl.khr_id = p_khr_id) -- lease contract id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT check_khr_securitized_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
-- 1. get flag
  x_value := is_khr_securitized
    (p_khr_id                  => p_khr_id
    ,p_effective_date          => p_effective_date
-- cklee 08-08-2003 11.5.10
    ,p_effective_date_operator => p_effective_date_operator
    ,p_stream_type_subclass    => p_stream_type_subclass);
-- cklee 08-08-2003 11.5.10

-- 2. get investor agreement id
    OPEN c_inv_khr(p_khr_id);
    i := 0;
    LOOP

      FETCH c_inv_khr INTO
                       x_inv_agmt_chr_id_tbl(i).khr_id;

      EXIT WHEN c_inv_khr%NOTFOUND;

      i := i+1;
    END LOOP;
    CLOSE c_inv_khr;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO check_khr_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_khr_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO check_khr_securitized_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END check_khr_securitized;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_kle_securitized
-- Description     : Checks if an Asset is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION is_kle_securitized(
   p_kle_id                       IN okc_k_lines_b.ID%TYPE
   ,p_effective_date               IN DATE
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
-- cklee 08-08-2003 11.5.10
 ) RETURN VARCHAR
IS
    l_dummy VARCHAR2(1);
    x_value VARCHAR2(1) := Okl_Api.G_FALSE;
    l_row_found BOOLEAN := FALSE;

 -- case 1
  CURSOR c_kle_def(p_kle_id okc_k_lines_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.kle_id = p_kle_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) >= TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
              AND   stmb.kle_id = pocb.kle_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );

  -- case 2
  CURSOR c_kle_gr(p_kle_id okc_k_lines_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.kle_id = p_kle_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) > TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
              AND   stmb.kle_id = pocb.kle_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );

  -- case 3
  CURSOR c_kle_ls(p_kle_id okc_k_lines_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.kle_id = p_kle_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) < TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
              AND   stmb.kle_id = pocb.kle_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );

  -- case 4
  CURSOR c_kle_eq(p_kle_id okc_k_lines_b.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
  FROM okl_pool_contents pocb,
       okl_pools polb,
       okc_k_headers_b chrb
  WHERE pocb.pol_id = polb.id
  AND   polb.khr_id = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.kle_id = p_kle_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) = TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   EXISTS (SELECT '1'
              FROM okl_streams stmb,
                   okl_strm_type_b styb
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = pocb.khr_id
              AND   stmb.kle_id = pocb.kle_id
			  AND   stmb.id = pocb.stm_id
              AND   NVL(styb.stream_type_subclass,'x')
                     = NVL(p_stream_type_subclass, NVL(styb.stream_type_subclass,'x'))
              );
BEGIN

  IF (p_effective_date_operator = G_GREATER_THAN) THEN

    OPEN c_kle_gr(p_kle_id, p_effective_date);
    FETCH c_kle_gr INTO l_dummy;
    l_row_found := c_kle_gr%FOUND;
    CLOSE c_kle_gr;
  ELSIF (p_effective_date_operator = G_LESS_THAN) THEN

    OPEN c_kle_ls(p_kle_id, p_effective_date);
    FETCH c_kle_ls INTO l_dummy;
    l_row_found := c_kle_ls%FOUND;
    CLOSE c_kle_ls;
  ELSIF (p_effective_date_operator = G_EQUAL_TO) THEN

    OPEN c_kle_eq(p_kle_id, p_effective_date);
    FETCH c_kle_eq INTO l_dummy;
    l_row_found := c_kle_eq%FOUND;
    CLOSE c_kle_eq;

  ELSIF (p_effective_date_operator = G_GREATER_THAN_EQUAL_TO) THEN

    OPEN c_kle_def(p_kle_id, p_effective_date);
    FETCH c_kle_def INTO l_dummy;
    l_row_found := c_kle_def%FOUND;
    CLOSE c_kle_def;

  END IF;

  IF l_row_found THEN
    x_value := Okl_Api.G_TRUE;
  ELSE
    x_value := Okl_Api.G_FALSE;
  END IF;

  RETURN x_value;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;

      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END is_kle_securitized;


-----------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : check_kle_securitized
-- Description     : Checks if an Asset is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
 PROCEDURE check_kle_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_kle_id                       IN okc_k_lines_b.ID%TYPE
   ,p_effective_date               IN DATE
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
-- cklee 08-08-2003 11.5.10
   ,x_value                        OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'check_kle_securitized_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

CURSOR c_inv_khr(p_kle_id okc_k_lines_b.id%TYPE) IS
  SELECT ph.khr_id -- inv agreemnet id
FROM okl_pools ph
WHERE EXISTS (SELECT '1'
              FROM okl_pool_contents pl
              WHERE pl.pol_id = ph.id
              AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
              AND   pl.kle_id = p_kle_id) -- lease contract id
;


BEGIN
  -- Set API savepoint
  SAVEPOINT check_kle_securitized_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

-- 1. get amount
 x_value := is_kle_securitized(
    p_kle_id                   => p_kle_id
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator  => p_effective_date_operator
   ,p_stream_type_subclass     => p_stream_type_subclass
-- cklee 08-08-2003 11.5.10
  ,p_effective_date            => p_effective_date);

-- 2. get investor agreement id
    OPEN c_inv_khr(p_kle_id);
    i := 0;
    LOOP

      FETCH c_inv_khr INTO
                       x_inv_agmt_chr_id_tbl(i).khr_id;

      EXIT WHEN c_inv_khr%NOTFOUND;

      i := i+1;
    END LOOP;
    CLOSE c_inv_khr;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO check_kle_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_kle_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,

       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO check_kle_securitized_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,





                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END check_kle_securitized;



 -----------------------------------------------------------------------
 -- Start of comments
 -- mvasudev, 10/03/2003
 -- Procedure Name  : check_sty_securitized
 -- Description     : Checks if a StreamType is securitized on the given date
 -- Business Rules  :
 -- Parameters      :
 --                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
 -- Version         : 1.0
 -- End of comments
 -----------------------------------------------------------------------
 PROCEDURE check_sty_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_sty_id                       IN okl_strm_type_b.id%TYPE
   ,x_value                        OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id              OUT NOCOPY NUMBER
 )
 IS

  -- Cursor to check if sty is securitized ">" effective_date
  CURSOR l_okl_sty_grt_csr IS
  SELECT DISTINCT polb.khr_id
  FROM   okl_pool_contents pocb,
         okl_pools polb,
         okc_k_headers_b chrb,
		 okl_strm_type_b styb
  WHERE pocb.pol_id   = polb.id
  AND   polb.khr_id   = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id   = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) > TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   pocb.sty_id = styb.id;

  -- Cursor to check if sty is securitized "<" effective_date
  CURSOR l_okl_sty_les_csr IS
  SELECT DISTINCT polb.khr_id
  FROM   okl_pool_contents pocb,
         okl_pools polb,
         okc_k_headers_b chrb,
		 okl_strm_type_b styb
  WHERE pocb.pol_id   = polb.id
  AND   polb.khr_id   = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id   = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) < TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   pocb.sty_id = styb.id;

  -- Cursor to check if sty is securitized "=" effective_date
  CURSOR l_okl_sty_eql_csr IS
  SELECT DISTINCT polb.khr_id
  FROM   okl_pool_contents pocb,
         okl_pools polb,
         okc_k_headers_b chrb,
		 okl_strm_type_b styb
  WHERE pocb.pol_id   = polb.id
  AND   polb.khr_id   = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id   = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) = TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   pocb.sty_id = styb.id;

  -- Cursor to check if sty is securitized ">=" effective_date
  CURSOR l_okl_sty_geq_csr IS
  SELECT DISTINCT polb.khr_id
  FROM   okl_pool_contents pocb,
         okl_pools polb,
         okc_k_headers_b chrb,
		 okl_strm_type_b styb
  WHERE pocb.pol_id   = polb.id
  AND   polb.khr_id   = chrb.id -- inv agreement
  AND   chrb.sts_code = G_STS_CODE_ACTIVE
  AND   pocb.khr_id   = p_khr_id
  AND   TRUNC(NVL(pocb.streams_to_date,G_FINAL_DATE)) >= TRUNC(p_effective_date)
  AND   pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
  AND   pocb.sty_id = styb.id;

    l_api_name         CONSTANT VARCHAR2(30) := 'check_sty_securitized';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

	l_value VARCHAR2(1) := Okl_Api.G_FALSE;

 BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    IF (p_effective_date_operator = G_GREATER_THAN) THEN
	  FOR l_okl_sty_grt_rec IN l_okl_sty_grt_csr
	  LOOP
		l_value := Okl_Api.G_TRUE;
		x_inv_agmt_chr_id := l_okl_sty_grt_rec.khr_id;
	  END LOOP;
    ELSIF (p_effective_date_operator = G_LESS_THAN) THEN
	  FOR l_okl_sty_les_rec IN l_okl_sty_les_csr
	  LOOP
		l_value := Okl_Api.G_TRUE;
		x_inv_agmt_chr_id := l_okl_sty_les_rec.khr_id;
	  END LOOP;
    ELSIF (p_effective_date_operator = G_EQUAL_TO) THEN
	  FOR l_okl_sty_eql_rec IN l_okl_sty_eql_csr
	  LOOP
		l_value := Okl_Api.G_TRUE;
		x_inv_agmt_chr_id := l_okl_sty_eql_rec.khr_id;
	  END LOOP;
    ELSIF (p_effective_date_operator = G_GREATER_THAN_EQUAL_TO) THEN
	  FOR l_okl_sty_geq_rec IN l_okl_sty_geq_csr
	  LOOP
		l_value := Okl_Api.G_TRUE;
		x_inv_agmt_chr_id := l_okl_sty_geq_rec.khr_id;
	  END LOOP;
    END IF; -- p_effective_date_operator

    x_value := l_value;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
 END check_sty_securitized;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_stm_securitized
-- Description     : Checks if any of the Streams Element under a streams header is securitized
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0

-- End of comments
----------------------------------------------------------------------------------
 FUNCTION is_stm_securitized(
   p_stm_id                       IN okl_streams.ID%TYPE
   ,p_effective_date               IN DATE
 ) RETURN VARCHAR
IS
    l_dummy VARCHAR2(1);
    x_value VARCHAR2(1) := Okl_Api.G_FALSE;
    l_row_found BOOLEAN := FALSE;

CURSOR c_stm(p_stm_id okl_streams.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
FROM  okl_streams       strm
      ,okl_pool_contents pl
      ,okl_pools ph
      ,okc_k_headers_b khr
WHERE  -- mvasudev, stm_id changes
/*
strm.KHR_ID   = pl.KHR_ID
AND    strm.KLE_ID   = pl.KLE_ID
AND    strm.STY_ID   = pl.STY_ID
*/
pl.STM_ID = strm.id
-- end, mvasudev, stm_id changes
AND    strm.say_code = 'CURR'
AND    strm.active_yn = 'Y'
AND   pl.pol_id = ph.id
AND   ph.khr_id = khr.id -- inv agreement
AND   khr.sts_code = G_STS_CODE_ACTIVE
AND   strm.id = p_stm_id
--AND   pl.streams_from_date <= p_effective_date
AND   TRUNC(NVL(pl.streams_to_date,G_FINAL_DATE)) >= TRUNC(p_effective_date)
AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
;


BEGIN

  OPEN c_stm(p_stm_id, p_effective_date);
  FETCH c_stm INTO l_dummy;
  l_row_found := c_stm%FOUND;
  CLOSE c_stm;

  IF l_row_found THEN
    x_value := Okl_Api.G_TRUE;
  ELSE
    x_value := Okl_Api.G_FALSE;
  END IF;

  RETURN x_value;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END is_stm_securitized;

-----------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : check_stm_securitized
-- Description     : Checks if any of the Streams Element under a streams header is securitized
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
 PROCEDURE check_stm_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_stm_id                       IN okl_streams.ID%TYPE
   ,p_effective_date               IN DATE
   ,x_value                        OUT NOCOPY VARCHAR2
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'check_stm_securitized_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN
  -- Set API savepoint
  SAVEPOINT check_stm_securitized_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

 x_value := is_stm_securitized(p_stm_id         => p_stm_id
                             ,p_effective_date => p_effective_date);

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO check_stm_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_stm_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get

      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO check_stm_securitized_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END check_stm_securitized;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_sel_securitized
-- Description     : Checks if passed in entity is securitized
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION is_sel_securitized(
   p_sel_id                   IN okl_strm_elements.ID%TYPE
   ,p_effective_date               IN DATE
 ) RETURN VARCHAR
IS
    l_dummy VARCHAR2(1);
    x_value VARCHAR2(1) := Okl_Api.G_FALSE;
    l_row_found BOOLEAN := FALSE;

CURSOR c_sel(p_sel_id okl_strm_elements.ID%TYPE, p_effective_date DATE) IS
  SELECT '1'
FROM  okl_streams       strm
      ,okl_strm_elements ele
      ,okl_pool_contents pl
      ,okl_pools ph
      ,okc_k_headers_b khr
WHERE  strm.id       = ele.stm_id
-- mvasudev, stm_id changes
/*
AND    strm.KHR_ID   = pl.KHR_ID
AND    strm.KLE_ID   = pl.KLE_ID
AND    strm.STY_ID   = pl.STY_ID
*/
-- end, mvasudev, stm_id changes
AND  pl.stm_id = strm.id
AND    strm.say_code = 'CURR'
AND    strm.active_yn = 'Y'
AND   pl.pol_id = ph.id
AND   ph.khr_id = khr.id -- inv agreement
AND   khr.sts_code = G_STS_CODE_ACTIVE
AND   ele.id = p_sel_id
--AND   pl.streams_from_date <= p_effective_date
AND   TRUNC(NVL(pl.streams_to_date,G_FINAL_DATE)) >= TRUNC(p_effective_date)
AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
;


BEGIN

  OPEN c_sel(p_sel_id, p_effective_date);
  FETCH c_sel INTO l_dummy;
  l_row_found := c_sel%FOUND;
  CLOSE c_sel;

  IF l_row_found THEN
    x_value := Okl_Api.G_TRUE;
  ELSE
    x_value := Okl_Api.G_FALSE;
  END IF;

  RETURN x_value;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END is_sel_securitized;

-------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : check_sel_securitized
-- Description     : Checks if a Stream Element is securitized
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
 PROCEDURE check_sel_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_sel_id                       IN okl_strm_elements.ID%TYPE
   ,p_effective_date               IN DATE
   ,x_value                        OUT NOCOPY VARCHAR2
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'check_sel_securitized_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN
  -- Set API savepoint
  SAVEPOINT check_sel_securitized_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

 x_value := is_sel_securitized(p_sel_id         => p_sel_id
                             ,p_effective_date => p_effective_date);

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info

	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN

    ROLLBACK TO check_sel_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_sel_securitized_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO check_sel_securitized_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END check_sel_securitized;

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : check_khr_ia_associated
 -- Description     : Utility API for Accounting and rest of okl to check whether
 --                   a contract is associated with investor agreement.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
PROCEDURE check_khr_ia_associated(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN  NUMBER
   ,p_scs_code                     IN  okc_k_headers_b.scs_code%TYPE DEFAULT NULL
   ,p_trx_date                     IN  DATE
   ,x_fact_synd_code               OUT NOCOPY fnd_lookups.lookup_code%TYPE
   ,x_inv_acct_code                OUT NOCOPY okc_rules_b.RULE_INFORMATION1%TYPE
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'check_khr_ia_associated';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_trx_date         DATE; -- cklee fixed bug: 7017824(R12)/OKL.H bug#6964174

  CURSOR investor_code (p_ia_chr_id IN NUMBER) IS
  SELECT rule_information1
  FROM okc_rules_b
  WHERE dnz_chr_id = p_ia_chr_id
  AND RULE_INFORMATION_CATEGORY='LASEAC';
  l_investor_code okc_rules_b.rule_information1%TYPE;

  CURSOR fact_synd_code IS
  SELECT lookup_code
  FROM fnd_lookups
  WHERE lookup_type = 'OKL_FACTORING_SYNDICATION'
  AND lookup_code = 'INVESTOR';
  l_fact_synd_code fnd_lookups.lookup_code%TYPE;

  CURSOR ia_number (p_chr_id IN NUMBER, p_trx_date IN DATE)IS
  SELECT COUNT(khr_id)
  FROM okl_pools
  WHERE id IN
  (SELECT pol_id
   FROM okl_pool_contents
   WHERE khr_id = p_chr_id
   AND TRUNC(streams_from_date) <= TRUNC(p_trx_date) -- cklee 05/29/08
   AND (TRUNC(streams_to_date) >= TRUNC(p_trx_date) OR -- cklee 05/29/08
	    streams_to_date IS NULL)
   AND STATUS_CODE ='ACTIVE'    -- 5/29/08 cklee fixed bug: 6862849 (R12)/OKL.H # snandiko 6857723
  );
  l_count NUMBER;

  CURSOR ia_id (p_chr_id IN NUMBER, p_trx_date IN DATE)IS
  SELECT khr_id
  FROM okl_pools
  WHERE id IN
  (SELECT pol_id
   FROM okl_pool_contents
   WHERE khr_id = p_chr_id
   AND TRUNC(streams_from_date) <= TRUNC(p_trx_date) -- cklee 05/29/08
   AND (TRUNC(streams_to_date) >= TRUNC(p_trx_date) OR -- cklee 05/29/08
	    streams_to_date IS NULL)
   AND STATUS_CODE ='ACTIVE'    -- 5/29/08 cklee fixed bug: 6862849 (R12)/OKL.H # snandiko 6857723
  );
  l_khr_id NUMBER;
--start:|  05-29-08 cklee -- fixed bug: 6932520(R12)/OKL.H: bug#6869289              |
-- shagarg bug 6869289 start
     -- cursor to get all pools to which contract is attached
     CURSOR csr_get_all_assoc_ia(p_chr_id IN NUMBER) IS
     SELECT ia.ID ia_id, ia.START_DATE ia_start_date,op.ID pool_id,opc.STY_CODE strm_type,
            opc.streams_from_date strm_from_date, opc.streams_to_date strm_to_date
     FROM   okc_k_headers_b ia,okl_pools op, okl_pool_contents opc
     WHERE ia.ID = op.khr_id
     AND   op.id =  opc.pol_id
     AND   opc.khr_id = p_chr_id
     AND   opc.STATUS_CODE ='ACTIVE'
     AND   ia.scs_code = 'INVESTOR'
     ORDER by strm_from_date , ia_start_date;
-- shagarg bug 6869289 end
--end:|  05-29-08 cklee -- fixed bug: 6932520(R12)/OKL.H: bug#6869289              |

  CURSOR scs_code (p_chr_id IN NUMBER) IS
  SELECT scs_code
  FROM okc_k_headers_b
  WHERE id = p_chr_id;
  l_scs_code okc_k_headers_b.scs_code%TYPE;

BEGIN
  -- Set API savepoint
  SAVEPOINT check_khr_ia_associated_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  /*** Begin API body ****************************************************/

  -- scs_code is INVESTOR, return null
  x_fact_synd_code := NULL;
  x_inv_acct_code := NULL;

  IF (p_scs_code IS NULL) THEN
    OPEN scs_code (p_khr_id);
	FETCH scs_code INTO l_scs_code;
	CLOSE scs_code;
  ELSE
    l_scs_code := p_scs_code;
  END IF;

  IF (l_scs_code = 'LEASE')THEN
--start:|  05-29-08 cklee -- fixed bug: 6932520(R12)/OKL.H: bug#6869289              |
-- shagarg commented for bug 6869289
/*
	OPEN ia_number (p_khr_id, p_trx_date);
	FETCH ia_number INTO l_count;
	CLOSE ia_number;

	IF (l_count > 0) THEN
	  OPEN fact_synd_code;
	  FETCH fact_synd_code INTO l_fact_synd_code;
	  CLOSE fact_synd_code;
	  IF (l_fact_synd_code IS NOT NULL) THEN
		x_fact_synd_code := l_fact_synd_code;
	  ELSE
		RAISE G_EXCEPTION_ERROR;
	  END IF;
    END IF;

	IF (l_count = 1) THEN
	  OPEN ia_id (p_khr_id, p_trx_date);
	  FETCH ia_id INTO l_khr_id;
	  CLOSE ia_id;

	  OPEN investor_code (l_khr_id);
	  FETCH investor_code INTO l_investor_code;
	  CLOSE investor_code;
	  IF (l_investor_code IS NOT NULL) THEN
        x_inv_acct_code := l_investor_code;
	  END IF;
	  -- acct code not required field, return null if not present
	END IF;*/
      -- shagarg bug 6869289 start
    l_trx_date := TRUNC(p_trx_date); -- cklee fixed bug: 7017824(R12)/OKL.H bug#6964174-- added Bug# 6964174 to ensure time is not considered for accounting     -- get all pools to which contract is securitized
       for l_all_assoc_ia_rec in csr_get_all_assoc_ia(p_khr_id)
       loop
           -- If the trans date falls b/w the pool contents dates, pick the IA associated with this pool
           -- to get special accounting code. If the trans date does not fall b/w pool contents dates, chk if it
           -- falls b/w IA start date and pool content strm element start dates,If so, use this Ia to get spcl accounting code
           -- as the trans is happening after the IA effective date. Else do regular accounting.
           IF(l_all_assoc_ia_rec.strm_from_date <= l_trx_date
               AND (l_all_assoc_ia_rec.strm_to_date >= l_trx_date OR l_all_assoc_ia_rec.strm_to_date IS NULL))
           --
               OR (l_all_assoc_ia_rec.ia_start_date <= l_trx_date AND l_trx_date <= l_all_assoc_ia_rec.strm_from_date )
           THEN
               OPEN fact_synd_code;
                 FETCH fact_synd_code INTO l_fact_synd_code;
               CLOSE fact_synd_code;
               IF (l_fact_synd_code IS NOT NULL) THEN
                   x_fact_synd_code := l_fact_synd_code;
               ELSE
                   RAISE G_EXCEPTION_ERROR;
               END IF;

               OPEN investor_code (l_all_assoc_ia_rec.ia_id);
                   FETCH investor_code INTO l_investor_code;
                   CLOSE investor_code;
                   IF (l_investor_code IS NOT NULL) THEN
                   x_inv_acct_code := l_investor_code;
                   END IF;
               return;
           END IF;
       end loop;
     -- shagarg bug 6869289 end
--end:|  05-29-08 cklee -- fixed bug: 6932520(R12)/OKL.H: bug#6869289              |
  END IF;

  /*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info

  Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO check_khr_ia_associated_pvt;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_khr_ia_associated_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	   ROLLBACK TO check_khr_ia_associated_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
    Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END check_khr_ia_associated;

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : buyback_asset
 -- Description     : Automatically buy back stream elements based on passed in kle_id
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE buyback_asset(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_kle_id                       IN  OKC_K_LINES_B.ID%TYPE
   ,p_effective_date               IN  DATE
 )
 IS
 BEGIN
    NULL;
    -- mvasudev, Commented until future use discovered, 4/28/2003
 END BUYBACK_ASSET;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : buyback_contract
-- Description     : Automatically buy back stream elements based on passed in khr_id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE buyback_contract(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN  OKC_K_HEADERS_B.ID%TYPE
   ,p_effective_date               IN  DATE
 )
 IS
 BEGIN
    NULL;
    -- mvasudev, Commented until future use discovered, 9/17/2003
 END buyback_contract;




-------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : process_investor_rules
-- Description     : checks the Buyback rule at the Investor Agreement and performs Buyback if required
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------------------------------
 PROCEDURE process_khr_investor_rules(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
   ,p_rgd_code                     IN  VARCHAR2
   ,p_rdf_code                     IN  VARCHAR2
   ,x_process_code                 OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'process_khr_investor_rules';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    l_flag VARCHAR2(1) := Okl_Api.G_FALSE;
    l_action NUMBER;

CURSOR c_action(p_rgd_code okc_rule_groups_b.rgd_code%TYPE,
                p_rdf_code okc_rules_b.RULE_INFORMATION_CATEGORY%TYPE,
                p_khr_id okc_k_headers_b.id%TYPE) IS
SELECT MIN(DECODE(rg.RULE_INFORMATION1, G_PROCESS_AUTO_BACK_BACK, G_PRIORITY_2,
                                    G_PROCESS_NOT_ALLOWED, G_PRIORITY_1,
                                    G_PRIORITY_2))
FROM okc_rule_groups_b rgd,
     okc_rules_b rg
WHERE rgd.id = rg.rgp_id
AND   rgd.rgd_code = p_rgd_code
AND   rg.RULE_INFORMATION_CATEGORY = p_rdf_code -- 'LASEPR'
AND   EXISTS -- investor agreement Ids
          (SELECT '1'
           FROM  okl_pools ph

                 ,okl_pool_contents pl
           WHERE ph.id = pl.pol_id
           AND   pl.khr_id = p_khr_id -- lease contract id
           AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
           AND   ph.khr_id = rg.dnz_chr_id) -- investor agreement contarct id
;


CURSOR c_inv_khr(p_rgd_code okc_rule_groups_b.rgd_code%TYPE,
                p_rdf_code okc_rules_b.RULE_INFORMATION_CATEGORY%TYPE,
                p_khr_id okc_k_headers_b.id%TYPE) IS
SELECT rgd.dnz_chr_id,
       rg.RULE_INFORMATION1
FROM okc_rule_groups_b rgd,
     okc_rules_b rg
WHERE rgd.id = rg.rgp_id
AND   rgd.rgd_code = p_rgd_code
AND   rg.RULE_INFORMATION_CATEGORY = p_rdf_code -- 'LASEPR'
AND   EXISTS -- investor agreement Ids
          (SELECT '1'
           FROM  okl_pools ph
                 ,okl_pool_contents pl
           WHERE ph.id = pl.pol_id
           AND   pl.khr_id = p_khr_id -- lease contract id
           AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
           AND   ph.khr_id = rg.dnz_chr_id) -- investor agreement contarct id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT process_khr_investor_rules;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
/*
Algorithm:

- the calling process passes asset/contract id and the rule group code
- identify the POOLS in which the given asset/contract is securitized - check for only active pools/agreements
- for each pool get the corresponding investor agreement id
- using the investor agreement id and rule group code, get the RULE value
- apply the RULE hierarchy logic ( not allow > buy back)
- execute the rule
- return
*/

-- 1. get flag
  l_flag := is_khr_securitized(p_khr_id         => p_khr_id
                             ,p_effective_date => p_effective_date);

  IF l_flag = Okl_Api.G_TRUE THEN

    OPEN c_action(p_rgd_code
                  ,NVL(p_rdf_code, G_PROCESS_RULE_CODE)

                  ,p_khr_id);
    FETCH c_action INTO l_action;
    CLOSE c_action;

    IF l_action = G_PRIORITY_2 THEN

      x_process_code := G_PROCESS_AUTO_BACK_BACK;
      -- auto buyback
      buyback_contract(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_khr_id         => p_khr_id,
        p_effective_date => p_effective_date);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      -- set message

    ELSIF l_action = G_PRIORITY_1 THEN
      x_process_code := G_PROCESS_NOT_ALLOWED;
      Okl_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_BUYBACK_NOT_ALLOWED');

    END IF;

    -- 2. fill in information table
    OPEN c_inv_khr(p_rgd_code
                  ,NVL(p_rdf_code, G_PROCESS_RULE_CODE)
                  ,p_khr_id);
    i := 0;
    LOOP

      FETCH c_inv_khr INTO
                       x_inv_agmt_chr_id_tbl(i).khr_id,
                       x_inv_agmt_chr_id_tbl(i).process_code;

      EXIT WHEN c_inv_khr%NOTFOUND;

      i := i+1;
    END LOOP;
    CLOSE c_inv_khr;

  END IF;
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info


	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO process_khr_investor_rules;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_khr_investor_rules;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO process_khr_investor_rules;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END process_khr_investor_rules;



-------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : process_investor_rules
-- Description     : checks the Buyback rule at the Investor Agreement and performs Buyback if required
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------------------------------
 PROCEDURE process_kle_investor_rules(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_kle_id                       IN okc_k_lines_b.ID%TYPE
   ,p_effective_date               IN DATE
   ,p_rgd_code                     IN  VARCHAR2
   ,p_rdf_code                     IN  VARCHAR2
   ,x_process_code                 OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'process_kle_investor_rules';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    l_flag VARCHAR2(1) := Okl_Api.G_FALSE;
    l_action NUMBER;

CURSOR c_action(p_rgd_code okc_rule_groups_b.rgd_code%TYPE,
                p_rdf_code okc_rules_b.RULE_INFORMATION_CATEGORY%TYPE,
                p_kle_id okc_k_lines_b.id%TYPE) IS
SELECT MIN(DECODE(rg.RULE_INFORMATION1, G_PROCESS_AUTO_BACK_BACK, G_PRIORITY_2,
                                    G_PROCESS_NOT_ALLOWED, G_PRIORITY_1,
                                    G_PRIORITY_2))
FROM okc_rule_groups_b rgd,
     okc_rules_b rg
WHERE rgd.id = rg.rgp_id
AND   rgd.rgd_code = p_rgd_code
AND   rg.RULE_INFORMATION_CATEGORY = p_rdf_code -- 'LASEPR'
AND   EXISTS -- investor agreement Ids
          (SELECT '1'
           FROM  okl_pools ph
                 ,okl_pool_contents pl
           WHERE ph.id = pl.pol_id
           AND   pl.kle_id = p_kle_id -- lease contract top line Id
           AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
           AND   ph.khr_id = rg.dnz_chr_id) -- investor agreement contarct id
;


CURSOR c_inv_khr(p_rgd_code okc_rule_groups_b.rgd_code%TYPE,
                p_rdf_code okc_rules_b.RULE_INFORMATION_CATEGORY%TYPE,

                p_kle_id okc_k_lines_b.id%TYPE) IS
SELECT rgd.dnz_chr_id,
       rg.RULE_INFORMATION1
FROM okc_rule_groups_b rgd,
     okc_rules_b rg
WHERE rgd.id = rg.rgp_id
AND   rgd.rgd_code = p_rgd_code
AND   rg.RULE_INFORMATION_CATEGORY = p_rdf_code -- 'LASEPR'

AND   EXISTS -- investor agreement Ids
          (SELECT '1'
           FROM  okl_pools ph
                 ,okl_pool_contents pl
           WHERE ph.id = pl.pol_id
           AND   pl.kle_id = p_kle_id -- lease contract top line Id
           AND   pl.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
           AND   ph.khr_id = rg.dnz_chr_id) -- investor agreement contarct id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT process_kle_investor_rules;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;


  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
/*
Algorithm:

- the calling process passes asset/contract id and the rule group code
- identify the POOLS in which the given asset/contract is securitized - check for only active pools/agreements
- for each pool get the corresponding investor agreement id
- using the investor agreement id and rule group code, get the RULE value
- apply the RULE hierarchy logic ( not allow > buy back)
- execute the rule
- return
*/

-- 1. get flag
  l_flag := is_kle_securitized(p_kle_id         => p_kle_id
                             ,p_effective_date => p_effective_date);

  IF l_flag = Okl_Api.G_TRUE THEN

    OPEN c_action(p_rgd_code
                  ,NVL(p_rdf_code, G_PROCESS_RULE_CODE)
                  ,p_kle_id);
    FETCH c_action INTO l_action;
    CLOSE c_action;

    IF l_action = G_PRIORITY_2 THEN

      x_process_code := G_PROCESS_AUTO_BACK_BACK;
      -- auto buyback
      buyback_asset(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_kle_id         => p_kle_id,
        p_effective_date => p_effective_date);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      -- set message

    ELSIF l_action = G_PRIORITY_1 THEN
      x_process_code := G_PROCESS_NOT_ALLOWED;
      Okl_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_BUYBACK_NOT_ALLOWED');

    END IF;

    -- 2. fill in information table
    OPEN c_inv_khr(p_rgd_code
                  ,NVL(p_rdf_code, G_PROCESS_RULE_CODE)
                  ,p_kle_id);
    i := 0;
    LOOP

      FETCH c_inv_khr INTO
                       x_inv_agmt_chr_id_tbl(i).khr_id,
                       x_inv_agmt_chr_id_tbl(i).process_code;

      EXIT WHEN c_inv_khr%NOTFOUND;

      i := i+1;
    END LOOP;
    CLOSE c_inv_khr;

  END IF;
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO process_kle_investor_rules;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_kle_investor_rules;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO process_kle_investor_rules;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END process_kle_investor_rules;

/*
PROCEDURE buyback_streams(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_pol_id                       IN okl_pools.ID%TYPE
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2)
IS
  -- Collect Pool Contents
  CURSOR l_okl_poc_csr
  IS
  SELECT pocb.id
  FROM   okl_pool_contents pocb
        ,okl_strm_type_b   styb
  WHERE  pocb.khr_id = p_khr_id
  AND    pocb.pol_id = p_pol_id
  AND    pocb.sty_id = styb.id
  AND    styb.stream_type_subclass = p_stream_type_subclass;

   l_api_name         CONSTANT VARCHAR2(30) := 'buyback_streams';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    FOR l_okl_poc_rec IN l_okl_poc_csr
    LOOP
        buyback_pool_content(p_api_version    => p_api_version
                            ,p_init_msg_list  => p_init_msg_list
                            ,x_return_status  => l_return_status
                            ,x_msg_count      => x_msg_count
                            ,x_msg_data       => x_msg_data
                            ,p_poc_id         => l_okl_poc_rec.id
                            ,p_effective_date => SYSDATE);

          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
          END IF;

    END LOOP; -- l_okl_poc_csr

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

END buyback_streams;

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : calculate_buyback_content
 -- Description     : Calculate BuyBack amount for a given Pool Content
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE calculate_buyback_content(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,p_poc_id                       IN  NUMBER
   ,x_buyback_amount               OUT NOCOPY NUMBER
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
 )
 IS

   CURSOR l_okl_poc_formula_csr(p_poc_id IN NUMBER)
   IS
   SELECT polb.khr_id khr_id             -- Investor Agreement
		 ,rulb.rule_information1 formula -- BuyBack Formula
		 ,pocb.khr_id dnz_chr_id         -- Lease Contract
--       ,pocb.pol_id pol_id             -- Pool
		 ,pocb.kle_id kle_id             -- Asset
		 ,pocb.sty_id sty_id             -- Stream Type
   FROM  okl_pool_contents pocb
        ,okl_pools         polb
        ,okc_rules_b       rulb
        ,okc_rule_groups_v rgpb
   WHERE pocb.id                        = p_poc_id
   AND   pocb.pol_id                    = polb.id
   AND   polb.khr_id                    = rulb.dnz_chr_id
   AND   rgpb.rgd_code                  = 'LASEBB'
   AND   rulb.rgp_id                    = rgpb.id
   AND   rulb.rule_information_category = 'LASEFM';

   lp_add_parameters   okl_execute_formula_pub.ctxt_val_tbl_type;

   l_api_name         CONSTANT VARCHAR2(30) := 'calculate_buyback_content';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

	FOR l_okl_poc_formula_rec IN l_okl_poc_formula_csr(p_poc_id)
	LOOP

                 lp_add_parameters(1).NAME  := 'p_khr_id';
                 lp_add_parameters(1).VALUE := l_okl_poc_formula_rec.khr_id;
                 lp_add_parameters(2).NAME  := 'p_sty_id';
                 lp_add_parameters(2).VALUE := l_okl_poc_formula_rec.sty_id;

                    OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version           => p_api_version
                                                   ,p_init_msg_list         => p_init_msg_list
                                                   ,x_return_status         => l_return_status
                                                   ,x_msg_count             => x_msg_count
                                                   ,x_msg_data              => x_msg_data
                                                   ,p_formula_name          => l_okl_poc_formula_rec.formula
                                                   ,p_contract_id           => l_okl_poc_formula_rec.dnz_chr_id
                                                   ,p_line_id               => l_okl_poc_formula_rec.kle_id
                                                   ,p_additional_parameters => lp_add_parameters
                                                   ,x_value                 => x_buyback_amount);


                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

	END LOOP;	--l_okl_poc_formula_rec

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);


 END calculate_buyback_content;
*/
  PROCEDURE calculate_buyback_amount(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
    ,p_pol_id                       IN okl_pools.ID%TYPE
    ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE
    ,x_buyback_amount               OUT NOCOPY NUMBER
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
  )
 IS
     -- Cursor to organize api calls by Pools
 	-- also to make sure we have data
     CURSOR l_okl_pol_csr
     IS
     SELECT DISTINCT pocb.pol_id
     FROM   okl_pool_contents pocb
           ,okl_strm_type_b   styb
     WHERE  pocb.khr_id = p_khr_id
     AND    pocb.pol_id = p_pol_id
     AND    pocb.sty_id = styb.id
     AND    styb.stream_type_subclass = p_stream_type_subclass;

 	-- Cursor for Buyback Formula
      CURSOR l_okl_formula_csr
      IS
      SELECT rulb.rule_information1 formula
      FROM  --okl_pool_contents pocb  --changed by abhsaxen for Bug#6174484
           --,
            okl_pools         polb
           ,okc_rules_b       rulb
           ,okc_rule_groups_v rgpb
      WHERE polb.id                    = p_pol_id
      AND   polb.khr_id                    = rulb.dnz_chr_id
      AND   rgpb.rgd_code                  = 'LASEBB'
      AND   rulb.rgp_id                    = rgpb.id
      AND   rulb.rule_information_category = 'LASEFM';

 	 -- Get all the Latest Pool Contents for this Pool
      CURSOR l_okl_poc_csr
      IS
      SELECT pocb.id poc_id
	        ,polb.khr_id khr_id
            ,pocb.kle_id kle_id
            ,pocb.sty_id sty_id
 		    ,pocb.sty_code
 		    ,pocb.streams_from_date
      FROM   okl_pool_contents pocb
	        ,okl_strm_type_b styb
			,okl_pools polb
      WHERE  pocb.khr_id               = p_khr_id
	  AND    pocb.pol_id               = p_pol_id
	  AND    pocb.pol_id               = polb.id
      AND    pocb.status_code          = G_POC_STS_ACTIVE
	  AND    pocb.sty_id               = styb.id
	  AND    styb.stream_type_subclass = p_stream_type_subclass;

   -- the revenue shares for the investor agreement
   CURSOR l_okl_rev_shares_csr(p_khr_id IN NUMBER,p_sty_id IN NUMBER)
   IS
   SELECT kleb.percent_stake percent_stake
   FROM   okl_k_lines kleb
         ,okc_k_lines_b cles
         ,okc_line_styles_b lses
		 ,okc_k_lines_b clet
         ,okc_line_styles_b lset
   WHERE  clet.dnz_chr_id = p_khr_id
   AND    clet.lse_id = lset.id
   AND    lset.lty_code = 'INVESTMENT'
   AND    cles.cle_id = clet.id
   AND    cles.lse_id = lses.id
   AND    lses.lty_code = 'REVENUE_SHARE'
   AND    kleb.id = cles.id
   AND    kleb.sty_id = p_sty_id;

    l_api_name         CONSTANT VARCHAR2(30) := 'calculate_buyback_amount';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    lp_add_parameters   Okl_Execute_Formula_Pub.ctxt_val_tbl_type;
    lx_buyback_amount NUMBER := 0;
    l_amount NUMBER := 0;

    l_formula VARCHAR2(450);

 BEGIN

     l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                               p_pkg_name	   => G_PKG_NAME,
                                               p_init_msg_list  => p_init_msg_list,
                                               l_api_version	   => l_api_version,
                                               p_api_version	   => p_api_version,
                                               p_api_type	   => G_API_TYPE,
                                               x_return_status  => l_return_status);

     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_ERROR;
     END IF;

     FOR l_okl_pol_rec IN l_okl_pol_csr
     LOOP
 	    FOR l_okl_formula_rec IN l_okl_formula_csr
 		LOOP
 		  l_formula := l_okl_formula_rec.formula;
 		END LOOP;

 		IF l_formula IS NOT NULL THEN

           FOR l_okl_poc_rec IN l_okl_poc_csr
           LOOP
                  lp_add_parameters(1).name  := 'p_khr_id';
                  lp_add_parameters(1).value := l_okl_poc_rec.khr_id;
                  lp_add_parameters(2).name  := 'p_sty_id';
                  lp_add_parameters(2).value := l_okl_poc_rec.sty_id;

                     Okl_Execute_Formula_Pub.EXECUTE(p_api_version           => p_api_version
                                                    ,p_init_msg_list         => p_init_msg_list
                                                    ,x_return_status         => l_return_status
                                                    ,x_msg_count             => x_msg_count
                                                    ,x_msg_data              => x_msg_data
                                                    ,p_formula_name          => l_formula
                                                    ,p_contract_id           => p_khr_id
                                                    ,p_line_id               => l_okl_poc_rec.kle_id
                                                    ,p_additional_parameters => lp_add_parameters
                                                    ,x_value                 => l_amount);

                     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                       RAISE Okl_Api.G_EXCEPTION_ERROR;
                     END IF;

  	                  -- calculate the revenue share for each sty
                    FOR l_okl_rev_shares_rec IN l_okl_rev_shares_csr(l_okl_poc_rec.khr_id,l_okl_poc_rec.sty_id)
                    LOOP
                      l_amount :=  ( ((l_okl_rev_shares_rec.percent_stake) / 100) * l_amount);
                    END LOOP; -- revenue shares csr

                     lx_buyback_amount := lx_buyback_amount + l_amount;
       		END LOOP; --	l_okl_poc_formula_rec

 		END IF; -- l_formula


     END LOOP; -- l_okl_pol_csr

 	x_buyback_amount := lx_buyback_amount;

     Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                         ,x_msg_data   => x_msg_data);

     x_return_status := l_return_status;


   EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN

       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);

     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);
     WHEN OTHERS THEN

       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_OTHERS,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);

  END calculate_buyback_amount;

 ----------------------------------------------------------------------------------
 -- Start of comments
 --  mvasudev
 -- Procedure Name  : adjust_pool_contents
 -- Description     : Utility Procedure to Adjust pool contents (DownStream Processing)
 --
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
  PROCEDURE adjust_pool_contents(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_poxv_rec                     IN  poxv_rec_type
	,p_khr_id                       IN  NUMBER DEFAULT NULL
	,p_kle_id                       IN  NUMBER DEFAULT NULL
	,p_stream_type_subclass         IN  VARCHAR2 DEFAULT NULL
	,p_streams_to_date              IN  DATE   DEFAULT NULL
  )
  IS

   -- Cursor to get all Pool Contents for this Lease Contract/Asset Line
   CURSOR l_okl_poc_csr(p_pol_id IN NUMBER)
   IS
   SELECT pocb.id
         ,pocb.kle_id
         ,pocb.sty_id
	     ,pocb.sty_code
	     ,pocb.streams_from_date
   	     ,pocb.streams_to_date
		 ,styb.stream_type_subclass
   FROM   okl_pool_contents pocb
         ,okl_strm_type_b styb
   WHERE pocb.pol_id = p_pol_id
   AND   pocb.khr_id = p_khr_id
   AND   pocb.kle_id = NVL(p_kle_id,pocb.kle_id)
   AND   pocb.sty_id = styb.id
   AND   styb.stream_type_subclass = NVL(p_stream_type_subclass,styb.stream_type_subclass)
   AND   pocb.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE
   AND   pocb.transaction_number_out IS NULL;

   -- Cursor to get Latest Streams for this Lease Contract/Asset Line
   CURSOR l_okl_stm_csr(p_khr_id IN NUMBER, p_kle_id IN NUMBER, p_sty_id IN NUMBER)
   IS
   SELECT id
   FROM   okl_streams
   WHERE  khr_id = p_khr_id
   AND    kle_id = p_kle_id
   AND    sty_id = p_sty_id
   AND    say_code = 'CURR'
   AND    active_yn = 'Y';

   -- Cursor to get the Lease Contract End Date
   CURSOR l_okl_khr_csr
   IS
   SELECT end_date,
          sts_code --Bug 6594724
   FROM   okc_k_headers_b
   WHERE  id = p_khr_id;


   -- Bug# 7590979 - Start
   -- Cursor gets the buy back date of a contract from a pool
   CURSOR c_chk_buy_back_date (cp_pol_id OKL_POOL_CONTENTS.ID%TYPE
                             , cp_khr_id OKC_K_HEADERS_B.ID%TYPE
                             , cp_stream_type_subclass OKL_STRM_TYPE_B.STREAM_TYPE_SUBCLASS%TYPE)   IS
     SELECT POX.TRANSACTION_DATE
       FROM OKL_POOL_CONTENTS POC
          , OKL_POOL_TRANSACTIONS POX
          , OKL_STRM_TYPE_B STY
      WHERE POC.KHR_ID = cp_khr_id
        AND POC.POL_ID = cp_pol_id
        AND STY.STREAM_TYPE_SUBCLASS = NVL(cp_stream_type_subclass,STY.STREAM_TYPE_SUBCLASS)
        AND POC.STY_ID = STY.ID
        AND POX.POL_ID = POC.POL_ID
        AND POC.TRANSACTION_NUMBER_IN = POX.TRANSACTION_NUMBER
        AND POX.TRANSACTION_TYPE='REMOVE'
        AND POX.TRANSACTION_REASON='BUY_BACK'
        AND ROWNUM < 2 ;

   l_buy_back_date DATE;
   -- Bug# 7590979 - End

    l_api_name         CONSTANT VARCHAR2(30) := 'adjust_pool_contents';
    l_api_version      CONSTANT NUMBER       := 1.0;
    i                  NUMBER;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    lp_poxv_rec         poxv_rec_type;
    lx_poxv_rec         poxv_rec_type;
    lp_pocv_rec         pocv_rec_type;
    lx_pocv_rec         pocv_rec_type;

	lp_pocv_rec_cre     pocv_rec_type;
	lp_pocv_rec_upd     pocv_rec_type;

	l_create BOOLEAN := FALSE;

	l_rv_date_updated BOOLEAN := FALSE;

  BEGIN

     l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                               p_pkg_name	   => G_PKG_NAME,
                                               p_init_msg_list  => p_init_msg_list,
                                               l_api_version	   => l_api_version,
                                               p_api_version	   => p_api_version,
                                               p_api_type	   => G_API_TYPE,
                                               x_return_status  => l_return_status);
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_ERROR;
     END IF;

	 lp_poxv_rec := p_poxv_rec;
	 Okl_Pool_Pvt.create_pool_transaction(p_api_version   => p_api_version
 	                                    ,p_init_msg_list => p_init_msg_list
 	                                    ,x_return_status => l_return_status
 	                                    ,x_msg_count     => x_msg_count
 	                                    ,x_msg_data      => x_msg_data
 	                                    ,p_poxv_rec      => lp_poxv_rec
 	                                    ,x_poxv_rec      => lx_poxv_rec);

     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

     -- Bug# 7590979 - Start
     -- Initialize the input stream to date (usually contract end date +1)
     l_buy_back_date := NULL;
     -- Obtain the date on which this contract was bought back from pool
     OPEN c_chk_buy_back_date(p_poxv_rec.pol_id, p_khr_id, p_stream_type_subclass);
       FETCH c_chk_buy_back_date INTO l_buy_back_date;
     CLOSE c_chk_buy_back_date;
     -- Bug# 7590979 - End

     -- Inactivate the corresponding pool contents with this transaction_number OUT
      FOR l_okl_poc_rec IN l_okl_poc_csr(p_poxv_rec.pol_id)
      LOOP
	      lp_pocv_rec.id := l_okl_poc_rec.id;
		  lp_pocv_rec.pol_id := p_poxv_rec.pol_id;
          lp_pocv_rec.date_inactive := lp_poxv_rec.date_effective;
		  lp_pocv_rec.transaction_number_out := lx_poxv_rec.transaction_number;
		  lp_pocv_rec.status_code := G_POC_STS_INACTIVE;

		  l_rv_date_updated := FALSE;
		  IF (l_okl_poc_rec.stream_type_subclass = G_STY_SUBCLASS_RESIDUAL OR l_okl_poc_rec.stream_type_subclass = G_STY_SUBCLASS_LOAN_PAYMENT)
		  THEN
    		  IF (   lp_poxv_rec.transaction_reason = G_TRX_REASON_ASSET_DISPOSAL
                  OR lp_poxv_rec.transaction_reason = G_TRX_REASON_PURCHASE
                  OR lp_poxv_rec.transaction_reason = G_TRX_REASON_REPURCHASE
                  OR lp_poxv_rec.transaction_reason = G_TRX_REASON_SCRAP
                  OR lp_poxv_rec.transaction_reason = G_TRX_REASON_REMARKET
				 )
			  THEN
                    lp_pocv_rec.streams_to_date := p_streams_to_date; -- contract end date+1
                    l_rv_date_updated := TRUE;
			  ELSIF (  lp_poxv_rec.transaction_reason = G_TRX_REASON_EARLY_TERMINATION
		             OR lp_poxv_rec.transaction_reason = G_TRX_REASON_ASSET_TERMINATION
                    )
	    	  THEN
			      FOR l_okl_khr_rec IN l_okl_khr_csr
				  LOOP
                     lp_pocv_rec.streams_to_date := l_okl_khr_rec.end_date;
				  END LOOP;

                  l_rv_date_updated := TRUE;
			  END IF;
		  END IF;

          Okl_Pool_Pvt.update_pool_contents(p_api_version   => p_api_version
 	                                   ,p_init_msg_list => p_init_msg_list
 	                                   ,x_return_status => l_return_status
 	                                   ,x_msg_count     => x_msg_count
 	                                   ,x_msg_data      => x_msg_data
 	                                   ,p_pocv_rec      => lp_pocv_rec
 	                                   ,x_pocv_rec      => lx_pocv_rec);


		  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		    RAISE Okl_Api.G_EXCEPTION_ERROR;
		  END IF;

		  IF (   lp_poxv_rec.transaction_reason = G_TRX_REASON_CONTRACT_REBOOK
		      OR lp_poxv_rec.transaction_reason = G_TRX_REASON_ASSET_SPLIT)
		  THEN
    		  l_create := TRUE;
		  ELSIF (lp_poxv_rec.transaction_reason = G_TRX_REASON_EARLY_TERMINATION
		  OR  lp_poxv_rec.transaction_reason = G_TRX_REASON_ASSET_TERMINATION)
		  AND l_okl_poc_rec.streams_from_date <= lp_poxv_rec.date_effective
		  THEN
    		  l_create := TRUE;
	      ELSIF (lp_poxv_rec.transaction_reason = G_TRX_REASON_BUYBACK
		  AND l_okl_poc_rec.streams_from_date <= SYSDATE )
          THEN
    		  l_create := TRUE;
       /*
         ankushar --Bug 6594724: Unable to terminate Investor Agreement with Residual Streams
         Start changes
        */
           IF (l_okl_poc_rec.stream_type_subclass = G_STY_SUBCLASS_RESIDUAL) THEN
              FOR l_okl_khr_rec IN l_okl_khr_csr
              LOOP
                 IF (l_okl_khr_rec.sts_code IN ('TERMINATED','EXPIRED')) THEN
                    l_create := FALSE;
                 END IF;
              END LOOP;
           END IF;
       /*
         ankushar Bug 6594724
         End Changes
        */

		  END IF;

		  IF(l_create AND NOT l_rv_date_updated) THEN
		          --create  a new poc record with the above poc details
			  lp_pocv_rec_cre.pol_id := p_poxv_rec.pol_id;
			  lp_pocv_rec_cre.khr_id := p_khr_id;
			  lp_pocv_rec_cre.kle_id := l_okl_poc_rec.kle_id;
			  lp_pocv_rec_cre.sty_id := l_okl_poc_rec.sty_id;
			  lp_pocv_rec_cre.sty_code := l_okl_poc_rec.sty_code;
			  lp_pocv_rec_cre.streams_from_date := l_okl_poc_rec.streams_from_date;

			  -- residual poc-s , while created, always have null end date
			  IF  l_okl_poc_rec.stream_type_subclass = G_STY_SUBCLASS_RESIDUAL
			  THEN
                      -- Bug#9001329 - Re-query contract end date for rebook alone as there
                      -- is a chance of change in end date
                      IF lp_poxv_rec.transaction_reason = G_TRX_REASON_CONTRACT_REBOOK THEN

                        FOR l_okl_khr_rec IN l_okl_khr_csr
                        LOOP
                          lp_pocv_rec_cre.streams_from_date := l_okl_khr_rec.end_date;
                        END LOOP;

                      END IF;
                      lp_pocv_rec_cre.streams_to_date := NULL;
		      ELSIF p_streams_to_date IS NOT NULL THEN
                 -- Bug# 7590979 - Start
                 IF lp_poxv_rec.transaction_reason = G_TRX_REASON_CONTRACT_REBOOK THEN
                   -- If the current pool stream to date is the buy back date
                   -- create the new stream to date as buy back date
                   IF TRUNC(l_okl_poc_rec.streams_to_date) = TRUNC(l_buy_back_date)   THEN
                     lp_pocv_rec_cre.streams_to_date := l_buy_back_date;
                   ELSE -- Contract is still securitized
                     lp_pocv_rec_cre.streams_to_date := p_streams_to_date;
                   END IF;

                 ELSE -- if this is not a Rebook transaction call
                  lp_pocv_rec_cre.streams_to_date := p_streams_to_date;
                 END IF;
                  -- Bug# 7590979 - End

			  ELSE
                  lp_pocv_rec_cre.streams_to_date := l_okl_poc_rec.streams_to_date;
			  END IF;

			  lp_pocv_rec_cre.transaction_number_in := lx_poxv_rec.transaction_number;
     /* sosharma 26-11-2007
     Changes to stamp pox_id on okl_pool_contents
     Start Changes
     */
       lp_pocv_rec_cre.pox_id:= lx_poxv_rec.id;
      /* sosharma end changes*/

		      FOR l_okl_stm_rec IN l_okl_stm_csr(p_khr_id,l_okl_poc_rec.kle_id,l_okl_poc_rec.sty_id)
			  LOOP
			    -- there should exactly be one record
			    lp_pocv_rec_cre.stm_id := l_okl_stm_rec.id;
	          END LOOP; -- l_okl_stm_rec

 			  lx_pocv_rec := NULL;
	          Okl_Pool_Pvt.create_pool_contents(p_api_version   => p_api_version
								       ,p_init_msg_list => p_init_msg_list
								       ,x_return_status => l_return_status
								       ,x_msg_count     => x_msg_count
								       ,x_msg_data      => x_msg_data
								       ,p_pocv_rec      => lp_pocv_rec_cre
								       ,x_pocv_rec      => lx_pocv_rec);

			  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
					RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
			        RAISE Okl_Api.G_EXCEPTION_ERROR;
	          END IF;

	          -- Update Status => "Active"
			  lp_pocv_rec_upd.id := lx_pocv_rec.id;
			  lp_pocv_rec_upd.status_code := G_POC_STS_ACTIVE;

			  lx_pocv_rec := NULL;

			  Okl_Pool_Pvt.update_pool_contents(p_api_version   => p_api_version
								       ,p_init_msg_list => p_init_msg_list
								       ,x_return_status => l_return_status
								       ,x_msg_count     => x_msg_count
								       ,x_msg_data      => x_msg_data
								       ,p_pocv_rec      => lp_pocv_rec_upd
								       ,x_pocv_rec      => lx_pocv_rec);

	          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	            RAISE Okl_Api.G_EXCEPTION_ERROR;
	          END IF;

		  END IF; -- l_create

		END LOOP; -- 		l_okl_poc_rec

     Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                         ,x_msg_data   => x_msg_data);

     x_return_status := l_return_status;

   EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);

     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);
     WHEN OTHERS THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_OTHERS,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
END adjust_pool_contents;

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : modify_pool_contents
 -- Description     : Gateway API for DownStream Lease Processes to Modify Pool
 --                   Contents upon some regular changes.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE modify_pool_contents(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,p_transaction_reason           IN  VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_kle_id                       IN OKC_K_LINES_B.ID%TYPE   DEFAULT NULL
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
   ,p_transaction_date             IN DATE
   ,p_effective_date               IN DATE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
 )
IS

   -- Cursor to get all the Pools associated with this Lease Contract/ Asset Line
   CURSOR l_okl_pol_csr
   IS
   SELECT DISTINCT pol_id
   FROM  okl_pool_contents pocb
        ,okl_strm_type_b styb
   WHERE pocb.khr_id = p_khr_id
   AND   pocb.kle_id = NVL(p_kle_id,pocb.kle_id)
   AND   pocb.sty_id = styb.id
   AND   styb.stream_type_subclass = NVL(p_stream_type_subclass,styb.stream_type_subclass)
   AND   pocb.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE
   AND   pocb.transaction_number_out IS NULL;


   -- Cursor to get the Lease Contract End Date
   CURSOR l_okl_khr_csr
   IS
   SELECT end_date
   FROM   okc_k_headers_b
   WHERE  id = p_khr_id;

   -- begin ankushar 29-11-2006 Legal Entity Changes
     -- Cursor to fecth LE associated to the pool
   CURSOR l_okl_legal_entity_id_csr(p_pol_id NUMBER)
   IS
   SELECT legal_entity_id
   FROM   okl_pools
   WHERE  id = p_pol_id;

  -- end ankushar Legal Entity changes

   l_api_name         CONSTANT VARCHAR2(30) := 'modify_pool_contents';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


   lp_pocv_rec         pocv_rec_type;
   lx_pocv_rec         pocv_rec_type;

   lp_pocv_rec_cre     pocv_rec_type;
   lp_poxv_rec         poxv_rec_type;

   l_khr_end_date DATE;

   -- begin ankushar 29-11-2006 Legal Entity Changes
   --   Attribute to store legal_entity_id
   lp_legal_entity_id NUMBER;
   -- end ankushar Legal Entity changes

BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    --Bug# 6788253: During split asset from UI for contracts in Booked status, need
    --              to modify pool contents for all active asset lines after stream
    --              regeneration.
    IF (p_transaction_reason IN (G_TRX_REASON_CONTRACT_REBOOK, G_TRX_REASON_ASSET_SPLIT))
	THEN
		FOR l_okl_pol_rec IN l_okl_pol_csr
		LOOP

       -- begin ankushar 29-11-2006 Legal Entity Changes
           OPEN l_okl_legal_entity_id_csr(l_okl_pol_rec.pol_id);
                FETCH l_okl_legal_entity_id_csr INTO lp_legal_entity_id;
            CLOSE l_okl_legal_entity_id_csr;
       -- end ankushar Legal Entity changes

           lp_poxv_rec.pol_id := l_okl_pol_rec.pol_id;
           lp_poxv_rec.transaction_date := p_transaction_date;
           lp_poxv_rec.transaction_type := G_TRX_TYPE_REPLACE;
           lp_poxv_rec.transaction_reason := p_transaction_reason;
           lp_poxv_rec.date_effective := p_effective_date;

        --sosharma 04/12/2007 added to enable status on pool transaction
		         lp_poxv_rec.transaction_status := G_POOL_TRX_STATUS_COMPLETE;

       -- begin ankushar 29-11-2006 Legal Entity Changes
          -- legal_entity_id populated in the record
           lp_poxv_rec.legal_entity_id := lp_legal_entity_id;
       -- end ankushar Legal Entity changes

		   FOR l_okl_khr_rec IN l_okl_khr_csr
           LOOP
		        --exactly one record
    			adjust_pool_contents(p_api_version   => p_api_version
							    ,p_init_msg_list => p_init_msg_list
							    ,x_return_status => l_return_status
							    ,x_msg_count     => x_msg_count
							    ,x_msg_data      => x_msg_data
								,p_poxv_rec      => lp_poxv_rec
								,p_khr_id        => p_khr_id
								,p_kle_id        => p_kle_id
								,p_stream_type_subclass => p_stream_type_subclass
								-- mvasudev, 02/06/2004
								,p_streams_to_date => l_okl_khr_rec.end_date+1);

		       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	  				 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
					 RAISE Okl_Api.G_EXCEPTION_ERROR;
		       END IF;

		   END LOOP; -- l_okl_khr_csr

		END LOOP ; --l_okl_pol_csr
	ELSIF (p_transaction_reason = G_TRX_REASON_EARLY_TERMINATION)
	THEN
		FOR l_okl_pol_rec IN l_okl_pol_csr
		LOOP

       -- begin ankushar 29-11-2006 Legal Entity Changes
           OPEN l_okl_legal_entity_id_csr(l_okl_pol_rec.pol_id);
                FETCH l_okl_legal_entity_id_csr INTO lp_legal_entity_id;
            CLOSE l_okl_legal_entity_id_csr;
       -- end ankushar Legal Entity changes

           lp_poxv_rec.pol_id := l_okl_pol_rec.pol_id;
           lp_poxv_rec.transaction_date := p_transaction_date;
           lp_poxv_rec.transaction_type := G_TRX_TYPE_REPLACE;
           lp_poxv_rec.transaction_reason := p_transaction_reason;
           lp_poxv_rec.date_effective := p_effective_date;
        --sosharma 04/12/2007 added to enable status on pool transaction
		         lp_poxv_rec.transaction_status := G_POOL_TRX_STATUS_COMPLETE;

       -- begin ankushar 29-11-2006 Legal Entity Changes
          -- legal_entity_id populated in the record
           lp_poxv_rec.legal_entity_id := lp_legal_entity_id;
       -- end ankushar Legal Entity changes

            adjust_pool_contents(p_api_version   => p_api_version
							    ,p_init_msg_list => p_init_msg_list
							    ,x_return_status => l_return_status
							    ,x_msg_count     => x_msg_count
							    ,x_msg_data      => x_msg_data
								,p_poxv_rec      => lp_poxv_rec
								,p_khr_id        => p_khr_id
								,p_kle_id        => p_kle_id
								,p_stream_type_subclass => p_stream_type_subclass
								,p_streams_to_date => p_effective_date);

		       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	  				 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
					 RAISE Okl_Api.G_EXCEPTION_ERROR;
		       END IF;

		END LOOP ; --l_okl_pol_csr
	ELSIF (p_transaction_reason = G_TRX_REASON_ASSET_TERMINATION) THEN
	    IF(p_kle_id IS NOT NULL) THEN
			FOR l_okl_pol_rec IN l_okl_pol_csr
			LOOP

       -- begin ankushar 29-11-2006 Legal Entity Changes
           OPEN l_okl_legal_entity_id_csr(l_okl_pol_rec.pol_id);
                FETCH l_okl_legal_entity_id_csr INTO lp_legal_entity_id;
            CLOSE l_okl_legal_entity_id_csr;
       -- end ankushar Legal Entity changes

	           lp_poxv_rec.pol_id := l_okl_pol_rec.pol_id;
	           lp_poxv_rec.transaction_date := p_transaction_date;
	           lp_poxv_rec.transaction_type := G_TRX_TYPE_REPLACE;
	           lp_poxv_rec.transaction_reason := p_transaction_reason;
	           lp_poxv_rec.date_effective := p_effective_date;

        --sosharma 04/12/2007 added to enable status on pool transaction
		         lp_poxv_rec.transaction_status := G_POOL_TRX_STATUS_COMPLETE;
					  -- begin ankushar 29-11-2006 Legal Entity Changes
          -- legal_entity_id populated in the record
           lp_poxv_rec.legal_entity_id := lp_legal_entity_id;
       -- end ankushar Legal Entity changes

     			adjust_pool_contents(p_api_version   => p_api_version
								    ,p_init_msg_list => p_init_msg_list
								    ,x_return_status => l_return_status
								    ,x_msg_count     => x_msg_count
								    ,x_msg_data      => x_msg_data
									,p_poxv_rec      => lp_poxv_rec
									,p_khr_id        => p_khr_id
     								,p_kle_id        => p_kle_id
		    						,p_stream_type_subclass => p_stream_type_subclass
									,p_streams_to_date => p_effective_date);

			       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		  				 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
						 RAISE Okl_Api.G_EXCEPTION_ERROR;
			       END IF;

			END LOOP ; --l_okl_pol_csr
	    ELSE
	      RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
	ELSIF(p_transaction_reason = G_TRX_REASON_ASSET_DISPOSAL OR
	      p_transaction_reason = G_TRX_REASON_PURCHASE OR
	      p_transaction_reason = G_TRX_REASON_REPURCHASE OR
	      p_transaction_reason = G_TRX_REASON_SCRAP OR
	      p_transaction_reason = G_TRX_REASON_REMARKET
         )
   THEN
          -- These are residual value streams
          --
		  IF (p_transaction_reason = G_TRX_REASON_ASSET_DISPOSAL
		  AND p_kle_id IS NULL) THEN
    	      RAISE Okl_Api.G_EXCEPTION_ERROR;
		  END IF;

          IF(p_effective_date IS NULL) THEN
    	      RAISE Okl_Api.G_EXCEPTION_ERROR;
		  ELSE
			FOR l_okl_pol_rec IN l_okl_pol_csr
			LOOP

       -- begin ankushar 29-11-2006 Legal Entity Changes
           OPEN l_okl_legal_entity_id_csr(l_okl_pol_rec.pol_id);
                FETCH l_okl_legal_entity_id_csr INTO lp_legal_entity_id;
            CLOSE l_okl_legal_entity_id_csr;
       -- end ankushar Legal Entity changes

	           lp_poxv_rec.pol_id := l_okl_pol_rec.pol_id;
	           lp_poxv_rec.transaction_date := p_transaction_date;
	           lp_poxv_rec.transaction_type := G_TRX_TYPE_REMOVAL;
	           lp_poxv_rec.transaction_reason := p_transaction_reason;
	           lp_poxv_rec.date_effective := p_effective_date;
        --sosharma 04/12/2007 added to enable status on pool transaction
		         lp_poxv_rec.transaction_status := G_POOL_TRX_STATUS_COMPLETE;
       -- begin ankushar 29-11-2006 Legal Entity Changes
          -- legal_entity_id populated in the record
           lp_poxv_rec.legal_entity_id := lp_legal_entity_id;
       -- end ankushar Legal Entity changes

		   FOR l_okl_khr_rec IN l_okl_khr_csr
		   LOOP
	    			adjust_pool_contents(p_api_version   => p_api_version
								    ,p_init_msg_list => p_init_msg_list
								    ,x_return_status => l_return_status
								    ,x_msg_count     => x_msg_count
								    ,x_msg_data      => x_msg_data
									,p_poxv_rec      => lp_poxv_rec
									,p_khr_id        => p_khr_id
        							,p_kle_id        => p_kle_id
		     						,p_stream_type_subclass => p_stream_type_subclass
		     						-- mvasudev, 02/06/2004
									,p_streams_to_date => l_okl_khr_rec.end_date+1);

			       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		  				 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
						 RAISE Okl_Api.G_EXCEPTION_ERROR;
			       END IF;
		  END LOOP;

			END LOOP ; --l_okl_pol_csr

          END IF; -- p_effective_date

	END IF; -- p_transaction_reason


    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;


   EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);

     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);
     WHEN OTHERS THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_OTHERS,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
  END modify_pool_contents;

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : modify_pool_contents
 -- Description     : Gateway API for DownStream Lease Processes to Modify Pool
 --                   Contents upon Asset Split.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE modify_pool_contents(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,p_transaction_reason           IN  VARCHAR2
   ,p_khr_id                       IN  OKC_K_HEADERS_B.ID%TYPE
   ,p_kle_id                       IN  OKC_K_LINES_B.ID%TYPE
   ,p_split_kle_ids                IN  cle_tbl_type
   ,p_transaction_date             IN  DATE
   ,p_effective_date               IN  DATE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
 )
IS

   -- Cursor to get all the Pools associated with this Lease Contract/ Asset Line
   CURSOR l_okl_pol_csr
   IS
   SELECT DISTINCT pol_id
   FROM  okl_pool_contents
   WHERE khr_id = p_khr_id
   AND   kle_id = p_kle_id
   AND   status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE
   AND   transaction_number_out IS NULL;

   -- Cursor to get all the Pool Contents for this Asset Line
   CURSOR l_okl_poc_csr(p_pol_id IN NUMBER)
   IS
   SELECT id
		 ,kle_id
		 ,sty_id
		 ,sty_code
		 ,streams_from_date
   		 ,streams_to_date
   FROM  okl_pool_contents
   WHERE pol_id = p_pol_id
   AND   khr_id = p_khr_id
   AND   kle_id = p_kle_id
   AND   status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE
   AND   transaction_number_out IS NULL;

   -- Cursor to get the Latest Streams for this Asset Line
   CURSOR l_okl_stm_csr(p_khr_id IN NUMBER, p_kle_id IN NUMBER, p_sty_id IN NUMBER)
   IS
   SELECT id
   FROM   okl_streams
   WHERE  khr_id = p_khr_id
   AND    kle_id = p_kle_id
   AND    sty_id = p_sty_id
   AND    say_code = 'CURR'
   AND    active_yn = 'Y';

   -- begin ankushar 29-11-2006 Legal Entity Changes
     -- Cursor to fecth LE associated to the pool
   CURSOR l_okl_legal_entity_id_csr(p_pol_id NUMBER)
   IS
   SELECT legal_entity_id
   FROM   okl_pools
   WHERE  id = p_pol_id;
   -- end ankushar Legal Entity Changes

   l_api_name         CONSTANT VARCHAR2(30) := 'modify_pool_contents';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

   -- begin ankushar 29-11-2006 Legal Entity Changes
      -- Attribute to store legal_entity_id
   lp_legal_entity_id NUMBER;
   -- end ankushar Legal Entity changes


   lp_pocv_rec         pocv_rec_type;
   lx_pocv_rec         pocv_rec_type;
   lp_poxv_rec         poxv_rec_type;
   lx_poxv_rec         poxv_rec_type;

   lp_pocv_rec_cre     pocv_rec_type;
   lp_pocv_rec_upd     pocv_rec_type;


BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

	IF(p_transaction_reason = G_TRX_REASON_ASSET_SPLIT)
	THEN
      IF(p_kle_id IS NOT NULL AND p_split_kle_ids.COUNT>0 )
	  THEN
			FOR l_okl_pol_rec IN l_okl_pol_csr
			LOOP

       -- begin ankushar 29-11-2006 Legal Entity Changes
           OPEN l_okl_legal_entity_id_csr(l_okl_pol_rec.pol_id);
                FETCH l_okl_legal_entity_id_csr INTO lp_legal_entity_id;
            CLOSE l_okl_legal_entity_id_csr;
       -- end ankushar Legal Entity changes

		         lp_poxv_rec.pol_id := l_okl_pol_rec.pol_id;
		         lp_poxv_rec.transaction_date := p_transaction_date;
		         lp_poxv_rec.transaction_type := G_TRX_TYPE_REPLACE;
		         lp_poxv_rec.transaction_reason := p_transaction_reason;
        --sosharma 04/12/2007 added to enable status on pool transaction
		         lp_poxv_rec.transaction_status := G_POOL_TRX_STATUS_COMPLETE;
       -- begin ankushar 29-11-2006 Legal Entity Changes
          -- legal_entity_id populated in the record
           lp_poxv_rec.legal_entity_id := lp_legal_entity_id;
       -- end ankushar Legal Entity changes

		         Okl_Pool_Pvt.create_pool_transaction(p_api_version   => p_api_version
		 	                                    ,p_init_msg_list => p_init_msg_list
		 	                                    ,x_return_status => l_return_status
		 	                                    ,x_msg_count     => x_msg_count
		 	                                    ,x_msg_data      => x_msg_data
		 	                                    ,p_poxv_rec      => lp_poxv_rec
		 	                                    ,x_poxv_rec      => lx_poxv_rec);

		          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		            RAISE Okl_Api.G_EXCEPTION_ERROR;
		          END IF;

				FOR l_okl_poc_rec IN l_okl_poc_csr(l_okl_pol_rec.pol_id)
				LOOP
		          -- Inactivate the corresponding pool contents with this transaction_number OUT
					    lp_pocv_rec.id := l_okl_poc_rec.id;
                        lp_pocv_rec.pol_id := l_okl_pol_rec.pol_id;
		                lp_pocv_rec.transaction_number_out := lx_poxv_rec.transaction_number;
		                lp_pocv_rec.status_code := G_POC_STS_INACTIVE;
		                lp_pocv_rec.date_inactive := p_effective_date;

		 	      Okl_Pool_Pvt.update_pool_contents(p_api_version   => p_api_version
		 	                                   ,p_init_msg_list => p_init_msg_list
		 	                                   ,x_return_status => l_return_status
		 	                                   ,x_msg_count     => x_msg_count
		 	                                   ,x_msg_data      => x_msg_data
		 	                                   ,p_pocv_rec      => lp_pocv_rec
		 	                                   ,x_pocv_rec      => lx_pocv_rec);

		          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		            RAISE Okl_Api.G_EXCEPTION_ERROR;
		          END IF;

					FOR i IN 1..p_split_kle_ids.COUNT
					LOOP
				            -- create  a new poc record with the above poc details
					      lp_pocv_rec_cre.pol_id := l_okl_pol_rec.pol_id;
					      lp_pocv_rec_cre.khr_id := p_khr_id;
					      lp_pocv_rec_cre.kle_id := p_split_kle_ids(i).cle_id;
					      lp_pocv_rec_cre.sty_id := l_okl_poc_rec.sty_id;
					      lp_pocv_rec_cre.sty_code := l_okl_poc_rec.sty_code;

						  FOR l_okl_stm_rec IN l_okl_stm_csr(p_khr_id,p_split_kle_ids(i).cle_id,l_okl_poc_rec.sty_id)
	                      LOOP
     					      lp_pocv_rec_cre.stm_id := l_okl_stm_rec.id;
                          END LOOP; -- l_okl_stm_rec

					      lp_pocv_rec_cre.streams_from_date := l_okl_poc_rec.streams_from_date;
					      lp_pocv_rec_cre.streams_to_date := l_okl_poc_rec.streams_to_date;
					      lp_pocv_rec_cre.transaction_number_in := lx_poxv_rec.transaction_number;

             /* sosharma 26-11-2007
              Changes to stamp pox_id on okl_pool_contents
              Start Changes
              */
                lp_pocv_rec_cre.pox_id:= lx_poxv_rec.id;
               /* sosharma end changes*/

					      Okl_Pool_Pvt.create_pool_contents(p_api_version   => p_api_version
									       ,p_init_msg_list => p_init_msg_list
									       ,x_return_status => l_return_status
									       ,x_msg_count     => x_msg_count
									       ,x_msg_data      => x_msg_data
									       ,p_pocv_rec      => lp_pocv_rec_cre
									       ,x_pocv_rec      => lx_pocv_rec);

					      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
						RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
					      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
						RAISE Okl_Api.G_EXCEPTION_ERROR;
					      END IF;

					      -- Update Status => "Active"
					      lp_pocv_rec_upd.id := lx_pocv_rec.id;
					      lp_pocv_rec_upd.status_code := G_POC_STS_ACTIVE;

					      lx_pocv_rec := NULL;

					      Okl_Pool_Pvt.update_pool_contents(p_api_version   => p_api_version
									       ,p_init_msg_list => p_init_msg_list
									       ,x_return_status => l_return_status
									       ,x_msg_count     => x_msg_count
									       ,x_msg_data      => x_msg_data
									       ,p_pocv_rec      => lp_pocv_rec_upd
									       ,x_pocv_rec      => lx_pocv_rec);

					       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
						 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
					       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
						 RAISE Okl_Api.G_EXCEPTION_ERROR;
					       END IF;

					END LOOP; -- p_split_kle_ids

				END LOOP; -- l_okl_poc_csr

			END LOOP ; -- l_okl_pol_csr
	  ELSE
        RAISE G_EXCEPTION_ERROR;
	  END IF;
	ELSE
      RAISE G_EXCEPTION_ERROR;
	END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;


   EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);

     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);
     WHEN OTHERS THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_OTHERS,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
  END modify_pool_contents;

 ----------------------------------------------------------------------------------
 -- Start of comments
 --  mvasudev
 -- Procedure Name  : create_inv_disb_streams
 -- Description     : Utility Procedure to Create Investor Disbursement Streams.
 --
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
  PROCEDURE create_inv_disb_streams(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_khr_id                       IN  NUMBER
	,p_source_id                    IN  NUMBER
	,p_stream_type_subclass         IN  VARCHAR2
	,p_amount                       IN  NUMBER
	,p_stream_element_date          IN  DATE
 ,p_loan_sty_purpose              IN VARCHAR2 DEFAULT NULL
   )
  IS

   -- To get the Transaction Number for Streams
   CURSOR l_okl_seq_csr
   IS
   SELECT okl_sif_seq.NEXTVAL transaction_number
   FROM dual;

   lp_stmv_rec Okl_Streams_Pub.stmv_rec_type;
   lx_stmv_rec Okl_Streams_Pub.stmv_rec_type;
   lp_selv_tbl Okl_Streams_Pub.selv_tbl_type;
   lx_selv_tbl Okl_Streams_Pub.selv_tbl_type;

   l_api_name         CONSTANT VARCHAR2(30) := 'create_inv_disb_streams';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

   l_sty_purpose VARCHAR2(150);
   l_sty_id NUMBER;

  BEGIN

     l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                               p_pkg_name	   => G_PKG_NAME,
                                               p_init_msg_list  => p_init_msg_list,
                                               l_api_version	   => l_api_version,
                                               p_api_version	   => p_api_version,
                                               p_api_type	   => G_API_TYPE,
                                               x_return_status  => l_return_status);
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_ERROR;
     END IF;

     IF p_stream_type_subclass = G_STY_SUBCLASS_RENT THEN
        l_sty_purpose := G_STY_INV_RENT_BUYBACK;
     ELSIF p_stream_type_subclass = G_STY_SUBCLASS_RESIDUAL THEN
       l_sty_purpose := G_STY_INV_RESIDUAL_BUYBACK	;
/* ankushar Bug#6740000 20-Jan-2008
   Added else clause for LOAN_PAYMENT subclass
*/
     ELSIF p_stream_type_subclass = G_STY_SUBCLASS_LOAN_PAYMENT THEN
        l_sty_purpose := p_loan_sty_purpose;
     END IF;
-- End Changes ankushar Bug# 6740000
	 -- Get the primary Stream Type
	 Okl_Streams_Util.get_primary_stream_type(p_khr_id => p_source_id,
	                                          p_primary_sty_purpose => l_sty_purpose,
	                                          x_return_status => l_return_status,
	                                          x_primary_sty_id => l_sty_id);

	     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
	       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
	       RAISE G_EXCEPTION_ERROR;
	     END IF;

	  IF l_sty_id IS NOT NULL THEN

	   lp_stmv_rec.sty_id := l_sty_id;
	   lp_stmv_rec.khr_id := p_khr_id;
	   lp_stmv_rec.source_id := p_source_id;
	   lp_stmv_rec.source_table := G_STM_SOURCE_TABLE;
	   lp_stmv_rec.sgn_code := G_STM_SGN_CODE_MANUAL;
	   lp_stmv_rec.say_code := G_STM_SAY_CODE_CURR;
	   lp_stmv_rec.active_yn := G_STM_ACTIVE_Y;
	   lp_stmv_rec.date_current := SYSDATE;

           FOR l_okl_seq_rec IN l_okl_seq_csr
	   LOOP
	     lp_stmv_rec.transaction_number := l_okl_seq_rec.transaction_number;
	   END LOOP;

	   lp_selv_tbl(1).amount              := p_amount;
	   lp_selv_tbl(1).stream_element_date := p_stream_element_date;
	   lp_selv_tbl(1).se_line_number      := 1;

	   Okl_Streams_Pub.create_streams(p_api_version           => p_api_version
                                   ,p_init_msg_list         => p_init_msg_list
                                   ,x_return_status         => l_return_status
                                   ,x_msg_count             => x_msg_count
                                   ,x_msg_data              => x_msg_data
				   ,p_stmv_rec              => lp_stmv_rec
				   ,p_selv_tbl              => lp_selv_tbl
				   ,x_stmv_rec              => lx_stmv_rec
				   ,x_selv_tbl              => lx_selv_tbl);

	     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		    RAISE Okl_Api.G_EXCEPTION_ERROR;
             END IF;

          END IF; -- l_sty_id


     Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                         ,x_msg_data   => x_msg_data);

     x_return_status := l_return_status;

   EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);

     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                    p_api_type	=> G_API_TYPE);
     WHEN OTHERS THEN
       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                    p_pkg_name	=> G_PKG_NAME,
                                                    p_exc_name   => G_EXC_NAME_OTHERS,
                                                    x_msg_count	=> x_msg_count,
                                                    x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
  END create_inv_disb_streams;


  PROCEDURE buyback_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_pol_id                       IN okl_pools.ID%TYPE
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE
   ,p_effective_date               IN DATE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2)
  IS
    -- Cursor to organize api calls by Pools
	-- also to make sure we have data
    CURSOR l_okl_pol_csr
    IS
    SELECT DISTINCT pocb.pol_id
    FROM   okl_pool_contents pocb
          ,okl_strm_type_b   styb
    WHERE  pocb.khr_id = p_khr_id
    AND    pocb.pol_id = p_pol_id
    AND    pocb.sty_id = styb.id
    AND    styb.stream_type_subclass = p_stream_type_subclass;

    -- Cursor to get the Agreement id and Legal Entity Id
    CURSOR l_okl_agr_csr
    IS
    SELECT khr_id, legal_entity_id
    FROM   okl_pools
	WHERE  id = p_pol_id;

	-- Cursor to check is Lease Contract
	-- is still securitized
	CURSOR l_okl_poc_khr_csr
	IS
	SELECT 1
	FROM   okl_pool_contents pocb
	WHERE  pocb.khr_id = p_khr_id
	AND    pocb.status_code = 'ACTIVE';

 -- cursor to get stream type purposes for a stream_type_subclass
    CURSOR get_sty_id_csr (p_sty_sub_classs VARCHAR2)
    IS
    SELECT id, stream_type_purpose
    FROM OKL_STRM_TYPE_B
    WHERE stream_type_subclass = p_sty_sub_classs;

    lp_poxv_rec         poxv_rec_type;
    lx_poxv_rec         poxv_rec_type;

    lp_chrv_rec Okl_Okc_Migration_Pvt.chrv_rec_type;
    lx_chrv_rec Okl_Okc_Migration_Pvt.chrv_rec_type;
    lp_khrv_rec Okl_Contract_Pub.khrv_rec_type;
    lx_khrv_rec Okl_Contract_Pub.khrv_rec_type;

    l_api_name         CONSTANT VARCHAR2(30) := 'buyback_streams';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    lx_buyback_amount NUMBER;
	lp_effective_date DATE;
	lp_agreement_id   NUMBER;
    --added by abhsaxen for legal Entiy Uptake
    lp_legal_entiy_id NUMBER;
	l_khr_active BOOLEAN := FALSE;

    TYPE l_loan_sty_purpose_rec IS RECORD(
    l_loan_sty_purpose VARCHAR2(40));

    TYPE l_loan_sty_purpose_tbl IS TABLE OF l_loan_sty_purpose_rec INDEX BY BINARY_INTEGER;
    l_loan_sty_purposes l_loan_sty_purpose_tbl;

  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

	FOR l_okl_agr_rec IN l_okl_agr_csr
	LOOP
	  lp_agreement_id := l_okl_agr_rec.khr_id;
	  lp_legal_entiy_id := l_okl_agr_rec.legal_entity_id;
	END LOOP;

	IF lp_agreement_id IS NULL THEN
      RAISE G_EXCEPTION_ERROR;
	END IF;

    FOR l_okl_pol_rec IN l_okl_pol_csr
    LOOP

        -- Calculate the BuyBack Amount
         calculate_buyback_amount(p_api_version   => p_api_version
	                                         ,p_init_msg_list => p_init_msg_list
	                                         ,x_return_status => l_return_status
	                                         ,x_msg_count     => x_msg_count
	                                         ,x_msg_data      => x_msg_data
											 ,p_khr_id        => p_khr_id
											 ,p_pol_id        => p_pol_id
											 ,p_stream_type_subclass => p_stream_type_subclass
											 ,x_buyback_amount       => lx_buyback_amount);
         -- Modify the pool contents as needed
	    IF p_effective_date IS NOT NULL THEN
          lp_effective_date := p_effective_date;
        ELSE
          lp_effective_date := SYSDATE;
        END IF;

	    lp_poxv_rec.pol_id := p_pol_id;
	    lp_poxv_rec.transaction_date := SYSDATE;
	    lp_poxv_rec.transaction_type := G_TRX_TYPE_REMOVAL;
	    lp_poxv_rec.transaction_reason := G_TRX_REASON_BUYBACK;
	    lp_poxv_rec.date_effective := lp_effective_date;
	    lp_poxv_rec.legal_entity_id := lp_legal_entiy_id;
     --sosharma 04/12/2007 added to enable status on pool transaction
     lp_poxv_rec.transaction_status := G_POOL_TRX_STATUS_COMPLETE;

            adjust_pool_contents(p_api_version   => p_api_version
							    ,p_init_msg_list => p_init_msg_list
							    ,x_return_status => l_return_status
							    ,x_msg_count     => x_msg_count
							    ,x_msg_data      => x_msg_data
								,p_poxv_rec      => lp_poxv_rec
								,p_khr_id        => p_khr_id
								,p_stream_type_subclass        => p_stream_type_subclass
								,p_streams_to_date => lp_effective_date);

		       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	  				 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
					 RAISE Okl_Api.G_EXCEPTION_ERROR;
		       END IF;

     IF p_stream_type_subclass = G_STY_SUBCLASS_LOAN_PAYMENT THEN
        l_loan_sty_purposes(1).l_loan_sty_purpose := G_STY_INV_PRINCIPAL_BUYBACK;
        l_loan_sty_purposes(2).l_loan_sty_purpose := G_STY_INV_INTEREST_BUYBACK;
        l_loan_sty_purposes(3).l_loan_sty_purpose := G_STY_INV_PPD_BUYBACK;
        FOR i IN 1 .. l_loan_sty_purposes.count
        LOOP
         --Create Investor Disbursment Streams for the Buyback amount
           create_inv_disb_streams(p_api_version   => p_api_version
                                  ,p_init_msg_list => p_init_msg_list
                                  ,x_return_status => l_return_status
                                  ,x_msg_count     => x_msg_count
                                  ,x_msg_data      => x_msg_data
                                  ,p_khr_id        => p_khr_id
                                  ,p_source_id  => lp_agreement_id
                                  ,p_stream_type_subclass => p_stream_type_subclass
                                  ,p_amount        => lx_buyback_amount
                                  ,p_stream_element_date => SYSDATE
                                  ,p_loan_sty_purpose => l_loan_sty_purposes(i).l_loan_sty_purpose);
       END LOOP;
     ELSE
         --Create Investor Disbursment Streams for the Buyback amount
           create_inv_disb_streams(p_api_version   => p_api_version
                                  ,p_init_msg_list => p_init_msg_list
                                  ,x_return_status => l_return_status
                                  ,x_msg_count     => x_msg_count
                                  ,x_msg_data      => x_msg_data
                                  ,p_khr_id        => p_khr_id
                                  ,p_source_id  => lp_agreement_id
                                  ,p_stream_type_subclass => p_stream_type_subclass
                                  ,p_amount        => lx_buyback_amount
                                  ,p_stream_element_date => SYSDATE
                                  ,p_loan_sty_purpose => NULL);
    END IF;

		 -- Cancel Accrual Streams for 'RENT' and 'LOAN_PAYMENT' subclass only
		 IF p_stream_type_subclass = G_STY_SUBCLASS_RENT OR p_stream_type_subclass = G_STY_SUBCLASS_LOAN_PAYMENT THEN
	    	Okl_Accrual_Sec_Pvt.cancel_streams(p_api_version           => p_api_version
	                                      ,p_init_msg_list         => p_init_msg_list
	                                      ,x_return_status         => l_return_status
	                                      ,x_msg_count             => x_msg_count
	                                      ,x_msg_data              => x_msg_data
	                                      ,p_khr_id                => p_khr_id
	                                      ,p_cancel_date           => lp_effective_date);


	        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	          RAISE Okl_Api.G_EXCEPTION_ERROR;
	        END IF;

		END IF; 	-- p_stream_type_subclass

		-- Update contract header, if needed
		l_khr_active := FALSE;
		FOR l_okl_poc_khr_rec IN l_okl_poc_khr_csr
		LOOP
		  l_khr_active := TRUE;
		END LOOP;

		IF NOT l_khr_active THEN

		    lp_chrv_rec.id := p_khr_id;
		    lp_khrv_rec.id := p_khr_id;
		    lp_khrv_rec.securitized_code := G_SECURITIZED_CODE_N;

		    Okl_Contract_Pub.update_contract_header(
		      p_api_version   => p_api_version,
		      p_init_msg_list => p_init_msg_list,
		      x_return_status => l_return_status,
		      x_msg_count     => x_msg_count,
		      x_msg_data      => x_msg_data,
		      p_chrv_rec      => lp_chrv_rec,
		      p_khrv_rec      => lp_khrv_rec,
		      x_chrv_rec      => lx_chrv_rec,
		      x_khrv_rec      => lx_khrv_rec);

		     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		       RAISE Okl_Api.G_EXCEPTION_ERROR;
		     END IF;

		END IF;


    END LOOP; -- l_okl_pol_csr


    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

  END buyback_pool_contents;


END Okl_Securitization_Pvt;

/
