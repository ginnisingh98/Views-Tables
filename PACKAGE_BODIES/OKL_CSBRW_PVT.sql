--------------------------------------------------------
--  DDL for Package Body OKL_CSBRW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSBRW_PVT" AS
/* $Header: OKLRFBRB.pls 120.2 2005/10/30 04:33:43 appldev noship $ */
FUNCTION cust_amount_info(  p_api_version                  IN NUMBER,
     			             p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_cust_account_id              IN  NUMBER,
                              x_amnt_applied   	     OUT NOCOPY NUMBER,
                              x_amnt_outstanding   	     OUT NOCOPY NUMBER
        		    ) RETURN VARCHAR2 AS

x_return_status      VARCHAR2(1) ;
l_api_name CONSTANT VARCHAR2(30) := 'cust_amount_info';
l_api_version         CONSTANT NUMBER := 1;

--skgautam added NVL for bug:3527642
cursor cust_amnt_applied is
SELECT
NVL(SUM (ARA.amount_applied),0)
FROM
ar_receivable_applications_all ARA,
ar_cash_receipts_all ACR
WHERE
ARA.status IN ( 'ACC' , 'UNAPP') AND
ARA.cash_receipt_id = ACR.cash_receipt_id AND
ACR.pay_from_customer = p_cust_account_id AND
ACR.status IN ( 'APP', 'UNAPP')
GROUP BY ACR.pay_from_customer;

--skgautam added NVL for bug:3527642
cursor cust_amnt_outstnading is
SELECT
NVL(SUM (APS.amount_due_remaining),0)
FROM
ar_payment_schedules_all APS,
ra_customer_trx_all RAC
WHERE
APS.class = 'INV' AND
APS.status = 'OP' AND
APS.customer_trx_id = RAC.customer_trx_id AND
RAC.bill_to_customer_id = p_cust_account_id;


 BEGIN

   x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                          G_PKG_NAME,
                                                         p_init_msg_list,
                                                         l_api_version,
                                                         p_api_version,
                                                         '_PROCESS',
                                                         x_return_status);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


  open cust_amnt_applied;
  fetch cust_amnt_applied into  x_amnt_applied;
               CLOSE cust_amnt_applied ;

  open cust_amnt_outstnading;
    fetch cust_amnt_outstnading into  x_amnt_outstanding;
               CLOSE cust_amnt_outstnading ;


  return (x_return_status);
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
                    '_PROCESS'
                  );
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                  x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                  (
                    l_api_name,
                    G_PKG_NAME,
                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                    x_msg_count,
                    x_msg_data,
                    '_PROCESS'
            );
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return (x_return_status);
END cust_amount_info;

END OKL_CSBRW_PVT;

/
