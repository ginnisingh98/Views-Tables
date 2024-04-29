--------------------------------------------------------
--  DDL for Package Body OKL_OA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OA_DATA_INTEGRITY" AS
/* $Header: OKLROAQB.pls 120.0 2005/09/15 18:23:08 manumanu noship $ */


  -- Start of comments
  --
  -- Procedure Name  : check_functional_constraints
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_functional_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

    p_api_version     NUMBER;
    p_init_msg_list   VARCHAR2(256) DEFAULT OKC_API.G_FALSE;
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(256);

    l_exists  VARCHAR2(1);


  BEGIN

    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
      OKL_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
    END IF;


  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
  NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed

  END check_functional_constraints;


END OKL_OA_DATA_INTEGRITY;

/
