--------------------------------------------------------
--  DDL for Package Body OKL_SIMPLE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIMPLE_PRICING_PVT" AS
/* $Header: OKLRSPRB.pls 115.27 2003/02/24 21:26:13 rgalipo noship $ */

  FUNCTION compute_periodic_payment
    (p_term             IN NUMBER
    ,p_frequency        IN NUMBER
    ,p_rate             IN NUMBER
    ,p_principal        IN NUMBER
    ,p_residual_percent IN NUMBER
    ,p_arrears          IN VARCHAR2
    ,x_return_status    OUT NOCOPY VARCHAR2
    ) RETURN NUMBER IS

  /* Variables */
  l_residual_percent   NUMBER;
  l_rate               NUMBER;
  l_Repayment          NUMBER;
  l_Factor             NUMBER;
  l_Arrears            NUMBER  := 0; -- 0:Arrears=Yes;
                                     -- 1:Arrears=No i.e. Advance payment
  l_periods            NUMBER;
  l_payments_per_annum NUMBER := p_frequency;
  /* Variables */




  l_return_status   VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    IF p_arrears = 'N' THEN
       l_Arrears := 1; -- payment in Advance.
    END IF;

    IF p_frequency=12 THEN
       l_periods:=1;
    ELSIF p_frequency=3 THEN
       l_periods:=3;
    ELSIF p_frequency=2 THEN
       l_periods:=6;
    ELSIF p_frequency=1 THEN
       l_periods:=12;
    ELSE
      NULL;
    END IF;

    IF p_frequency = 3 THEN -- correction for quartly payments
       l_payments_per_annum := 4;
    END IF;

    l_residual_percent := nvl(p_residual_percent,0) / 100;
    l_periods          := p_term / l_periods;
    l_rate             := p_rate/(100*l_payments_per_annum);

    l_factor := (1-l_residual_percent)
               *
             ( l_rate * POWER(1+l_rate,l_periods-l_Arrears)
               /
              (POWER(1+ l_Rate,l_periods)-1)
               + l_residual_percent
               * l_Rate
               * (1- l_Rate)
             );

  l_Repayment := p_principal * l_Factor;

  x_return_status := l_return_status;

  RETURN l_Repayment;

  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END compute_periodic_payment;

END OKL_SIMPLE_PRICING_PVT;

/
