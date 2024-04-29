--------------------------------------------------------
--  DDL for Package Body OKL_BPD_CREDIT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_CREDIT_CHECK_PVT" AS
/* $Header: OKLRCCFB.pls 115.5 2003/09/23 21:25:24 cklee noship $ */

FUNCTION credit_check(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_creditline_id   IN  NUMBER
	,p_credit_max       IN  NUMBER
    ,P_trx_date         IN DATE)
    RETURN NUMBER IS

    l_credit_remain       NUMBER := 0;
    l_disbursement_tot    NUMBER := 0;
    l_is_revolving_credit BOOLEAN := false;
    l_dummy               NUMBER;
    l_principal_tot       NUMBER := 0;

cursor c_disb_tot is
--  SELECT NVL(SUM(NVL(TAP.AMOUNT,0)),0)
  SELECT TAP.AMOUNT,
         TAP.KHR_ID
FROM   OKL_TRX_AP_INVOICES_B TAP
WHERE  TAP.TRX_STATUS_CODE in ('APPROVED','PROCESSED') -- push to AP
AND    TAP.FUNDING_TYPE_CODE IS NOT NULL
--AND    TRUNC(DATE_INVOICED) <= TRUNC(p_trx_date)
;
--AND OKL_CREDIT_PUB.get_creditline_by_chrid(TAP.KHR_ID) = p_creditline_id;

/* comment out for now
cursor c_is_revolv_crd(p_creditline_id number) is
select 1 -- Revloving line of credit line
from   okl_k_headers REV
where  rev.id = p_creditline_id
and    REV.REVOLVING_CREDIT_YN = 'Y'
;

cursor c_princ_tot(p_creditline_id number) is
SELECT
--  NVL(SUM(NVL(PS.AMOUNT_APPLIED,0)),0)
  NVL(PS.AMOUNT_APPLIED,0),
  CN.ID KHR_ID
FROM
  AR_PAYMENT_SCHEDULES_ALL PS,
  OKL_CNSLD_AR_STRMS_B ST,
  OKL_STRM_TYPE_TL SM,
  OKC_K_HEADERS_B CN
WHERE
  PS.CLASS IN ('INV') AND
  ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID AND
  SM.ID = ST.STY_ID AND
  SM.LANGUAGE = USERENV ('LANG') AND
  CN.ID = ST.KHR_ID     AND
  SM.NAME = 'PRINCIPAL PAYMENT' AND
  TRUNC(NVL(PS.TRX_DATE, SYSDATE)) <= TRUNC(p_trx_date)
AND
;
*/
--AND OKL_CREDIT_PUB.get_creditline_by_chrid(CN.ID) = p_creditline_id;

begin

   FOR r_ast IN c_disb_tot LOOP

     IF (OKL_CREDIT_PUB.get_creditline_by_chrid(r_ast.KHR_ID) = p_creditline_id) THEN
       l_disbursement_tot := l_disbursement_tot + NVL(r_ast.AMOUNT,0);
     END IF;

   END LOOP;

/*
  OPEN c_disb_tot(p_creditline_id);
  FETCH c_disb_tot into l_disbursement_tot;
  CLOSE c_disb_tot;

  OPEN c_is_revolv_crd(p_creditline_id);
  FETCH c_is_revolv_crd into l_dummy;
  l_is_revolving_credit := c_is_revolv_crd%FOUND;
  CLOSE c_is_revolv_crd;

  IF (l_is_revolving_credit) THEN

    OPEN c_princ_tot(p_creditline_id);
    FETCH c_princ_tot into l_principal_tot;
    CLOSE c_princ_tot;

    l_credit_remain := nvl(p_credit_max, 0) - l_disbursement_tot + l_principal_tot;
  ELSE
    l_credit_remain := nvl(p_credit_max, 0) - l_disbursement_tot;
  END IF;
*/
  l_credit_remain := nvl(p_credit_max, 0) - l_disbursement_tot;
  x_return_status := okl_api.G_RET_STS_SUCCESS;

  RETURN l_credit_remain;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      RETURN NULL;


END credit_check;

END OKL_BPD_CREDIT_CHECK_PVT;

/
