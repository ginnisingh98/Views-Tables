--------------------------------------------------------
--  DDL for Package Body OKL_COMMON_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COMMON_FUNCTIONS" AS
/* $Header: OKLRCOMB.pls 120.2 2006/07/11 09:43:24 dkagrawa noship $ */

  ---------------------------------------------------------------------------
  -- FUNCTION get_unrefunded_cures
  ---------------------------------------------------------------------------
  FUNCTION get_unrefunded_cures(
     p_contract_id		IN NUMBER,
     x_unrefunded_cures	      OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS

    -- Get unrefunded cures for a contract
    /*CURSOR unrefunded_cures_csr(p_contract_id NUMBER) IS
      SELECT SUM(amount)
      FROM   OKL_cure_payment_lines
      WHERE  chr_id = p_contract_id
      AND    status = 'CURES_IN_POSSESSION'; */

    l_unrefunded_cures NUMBER := 0;
    l_api_version      NUMBER;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

  BEGIN

    --OPEN  unrefunded_cures_csr(p_contract_id);
    --FETCH unrefunded_cures_csr INTO l_unrefunded_cures;
    --CLOSE unrefunded_cures_csr;

    x_unrefunded_cures := l_unrefunded_cures;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_unrefunded_cures;

  ---------------------------------------------------------------------------
  -- FUNCTION get_unrefunded_cures
  ---------------------------------------------------------------------------
  FUNCTION get_cured_status (p_contract_number IN NUMBER)
    RETURN VARCHAR2 IS
  CURSOR c_cured (p_chr_id NUMBER)  is
    SELECT 'Y'
    FROM    OKL_CURE_PAYMENT_LINES
    WHERE EXISTS (SELECT 1
                  FROM   OKL_CURE_PAYMENT_LINES
                  WHERE  status = 'CURES_IN_POSSESSION'
                  AND    cured_flag = 'Y'
                  AND    chr_id = p_chr_id);
    ls_cured_flag  VARCHAR2(1) := 'N';
  BEGIN
    OPEN c_cured(p_contract_number );
    FETCH c_cured INTO ls_cured_flag;
    IF(c_cured%NOTFOUND) THEN
       ls_cured_flag := 'N' ;
         CLOSE c_cured ;
         return(ls_cured_flag);
    END if ;
    CLOSE c_cured;
      return(ls_cured_flag);
  END get_cured_status;

END OKL_COMMON_FUNCTIONS;

/
