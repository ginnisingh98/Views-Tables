--------------------------------------------------------
--  DDL for Package Body OKC_QA_PROCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QA_PROCS" AS
/* $Header: OKCRQAPB.pls 120.0 2005/05/25 22:47:49 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  -- Start of comments
  --
  -- Procedure Name  : check_parties
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_parties(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER,
    p_party_count              IN  NUMBER
  ) IS
    l_count NUMBER := 0;
    CURSOR l_cpl_csr IS
      SELECT count(*)
        FROM OKC_K_PARTY_ROLES_B cpl
       WHERE cpl.dnz_chr_id = p_chr_id
       and cpl.cle_id is NULL;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- get party count
    OPEN  l_cpl_csr;
    FETCH l_cpl_csr INTO l_count;
    CLOSE l_cpl_csr;

    -- check if party count is greater or equal to the required number
    IF (l_count < p_party_count) THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_PARTY_COUNT,
        p_token1        => 'PARTY_COUNT',
        p_token1_value  => p_party_count);
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSE
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
      -- notify caller of success
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
    IF l_cpl_csr%ISOPEN THEN
      CLOSE l_cpl_csr;
    END IF;
  END check_parties;
--
  -- Start of comments
  --
  -- Procedure Name  : check_min_lines
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_min_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER,
    p_line_count               IN  NUMBER
  ) IS
    l_count NUMBER := 0;
    CURSOR l_cle_csr IS
      SELECT count(*)
        FROM OKC_K_LINES_B cle
       WHERE cle.chr_id = p_chr_id;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- get line count
    OPEN  l_cle_csr;
    FETCH l_cle_csr INTO l_count;
    CLOSE l_cle_csr;

    -- check if line count is greater or equal to the required number
    IF (l_count < p_line_count) THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_LINE_COUNT,
        p_token1        => 'LINE_COUNT',
        p_token1_value  => p_line_count);
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSE
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
      -- notify caller of success
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
    IF l_cle_csr%ISOPEN THEN
      CLOSE l_cle_csr;
    END IF;
  END check_min_lines;

END OKC_QA_PROCS;

/
