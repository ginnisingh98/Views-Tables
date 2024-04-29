--------------------------------------------------------
--  DDL for Package Body OKS_AVG_SET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_AVG_SET_PUB" AS
/* $Header: OKSPAVGB.pls 120.4 2006/06/20 01:43:20 hvaladip noship $ */

------------------------------------------------------------------------
  -- FUNCTION avg_api
------------------------------------------------------------------------
PROCEDURE  average_api(
                  p_called_from    IN             NUMBER,
                  p_cle_id         IN             NUMBER,
                  p_hdr_id         IN             NUMBER,
                  p_avg_interval   IN             NUMBER,
                  X_return_status  IN OUT NOCOPY  VARCHAR2)

IS
Cursor get_curr_csr (p_hdr_id  IN   NUMBER)
 IS
 SELECT currency_code FROM okc_k_headers_b
 WHERE id = p_hdr_id;

Cursor get_avg_date (p_cle_id  IN   NUMBER)
 IS
 SELECT trunc(date_billed_from) date_billed_from FROM oks_bill_cont_lines
 WHERE  cle_id = p_cle_id
 order by date_billed_to desc;

Cursor sub_line_csr (p_cle_id        IN  NUMBER,
                     p_date  IN  DATE)
 IS
 SELECT sum(bsd.result)           qty_billed,
        min(bsl.date_billed_from) date_billed_from,
        max(bsl.date_billed_to)   date_billed_to,
        sum(bsl.amount)           amt_billed,
        bsl.cle_id
 FROM
       oks_bill_sub_line_dtls  bsd,
       oks_bill_sub_lines      bsl
 WHERE bsd.bsl_id   =  bsl.id
 AND   bsl.bcl_id in
       (select bcl.id from oks_bill_cont_lines bcl
        where  bcl.averaged_yn  is null
        AND    trunc(bcl.date_billed_from) >= p_date
        and    bcl.cle_id = p_cle_id )
 group by bsl.cle_id;

Cursor process_avg_csr (p_cle_id            IN   NUMBER,
                        p_date_billed_from  IN   DATE,
                        p_date_billed_to    IN   DATE)
IS
 SELECT id                     bcl_id
       ,Date_Billed_from       Date_Billed_from
       ,Date_Billed_to         Date_Billed_to
 FROM oks_bill_cont_lines
 Where cle_id = p_cle_id
 AND  trunc(date_billed_from ) >= trunc(p_date_billed_from)
 AND  trunc(date_billed_to ) <= trunc(p_date_billed_to)
 AND  averaged_yn is NULL;

Cursor subline_credit_csr(p_cle_id             IN   NUMBER)
 IS
 SELECT  bsd.unit_of_measure    uom_code,
         bsd.amcv_yn            amcv_yn,
         bsl.date_billed_from   date_from,
         bsl.date_billed_to     date_to
    FROM  oks_bill_sub_lines     bsl,
          oks_bill_sub_line_dtls bsd
    WHERE bsl.cle_id = p_cle_id
    AND   bsl.id = bsd.bsl_id
    order by bsl.date_billed_to desc;

 l_bill_qty              NUMBER;
 l_avg_amount            NUMBER;
 l_temp_average          NUMBER;
 l_average               NUMBER;
 l_term_amount           NUMBER;
 l_total_credit          NUMBER := 0;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_curr_code             VARCHAR2(15);
 l_return_status         VARCHAR2(1) := 'S';
 l_called_from  CONSTANT NUMBER      := 1;

 l_process_rec           process_avg_csr%ROWTYPE;

 l_cov_tbl                   OKS_BILL_REC_PUB.COVERED_TBL;
 l_line_rec                  OKS_QP_PKG.INPUT_DETAILS ;
 l_price_rec                 OKS_QP_PKG.PRICE_dETAILS ;
 l_modifier_details          QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 l_price_break_details       OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
 l_billrep_tbl	             OKS_BILL_REC_PUB.bill_report_tbl_type;
 l_billrep_tbl_idx	     NUMBER := 0;
 l_billrep_err_tbl       OKS_BILL_REC_PUB.billrep_error_tbl_type;
 l_billrep_errtbl_idx    NUMBER;
 l_bcl_id    NUMBER;

 l_term_tbl                  OKS_BILL_REC_PUB.TERMINATE_TBL;

l_uom_code   varchar2(30);
l_amcv_yn    varchar2(3);
l_date_from    date;
l_date_to      date;
l_date_to_average      date;
j   number;



BEGIN

 j := 1;

  FOR get_avg_csr in get_avg_date(p_cle_id)
  LOOP
   if j = p_avg_interval Then
       l_date_to_average := get_avg_csr.date_billed_from;
       exit;
   End if;
   j := j + 1;
  END LOOP;



  /* Check if there is sufficient periods to process */
  OPEN  get_curr_csr (p_hdr_id);
  FETCH get_curr_csr into l_curr_code;
  CLOSE get_curr_csr;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'cle_id '||p_cle_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG,' avg '||p_avg_interval);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Dt to be averaged from '||l_date_to_average);

    /*While loop is to process multiple slots. It will take care
      of past periods  where averaging was not run
    */
  FOR sub_line_rec in sub_line_csr(p_cle_id, l_date_to_average)
  LOOP

    /* Get total qty billed for line in averaging interval that is
       being processed
    */
    l_average := round(sub_line_rec.qty_billed / p_avg_interval,0);
    l_avg_amount := 0;


    OPEN  subline_credit_csr(sub_line_rec.cle_id);
    FETCH subline_credit_csr into l_uom_code, l_amcv_yn, l_date_from, l_date_to;
    CLOSE subline_credit_csr;

    l_line_rec.line_id          := p_cle_id;
    l_line_rec.intent           := 'USG';
    l_line_rec.usage_qty        := l_average;
    l_line_rec.usage_uom_code   := l_uom_code;
    l_line_rec.bsl_id           := -99; --- no price breaks for average

    l_avg_amount := 0;

    OKS_QP_PKG.CALC_PRICE
    (
           P_DETAIL_REC          => l_line_rec,
           X_PRICE_DETAILS       => l_price_rec,
           X_MODIFIER_DETAILS    => l_modifier_details,
           X_PRICE_BREAK_DETAILS => l_price_break_details,
           X_RETURN_STATUS       => l_return_status,
           X_MSG_COUNT           => l_msg_count,
           X_MSG_DATA            => l_msg_data
    );

    FND_FILE.PUT_LINE(FND_FILE.LOG,'pricing engine amt '||l_price_rec.PROD_EXT_AMOUNT);

    l_avg_amount := l_price_rec.PROD_EXT_AMOUNT * p_avg_interval;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'averaged amt '||l_avg_amount);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount billed '||sub_line_rec.amt_billed);


    IF NVL(l_avg_amount,0) < sub_line_rec.amt_billed Then
       l_avg_amount := sub_line_rec.amt_billed - l_avg_amount;
       l_total_credit :=  l_total_credit + l_avg_amount;
       l_avg_amount :=  l_avg_amount * -1;

       l_cov_tbl(1).fixed              := 0;
       l_cov_tbl(1).result             := l_average;
       l_cov_tbl(1).actual             := l_average;
       l_cov_tbl(1).estimated_quantity := 0;
       l_cov_tbl(1).sign               := 1;
       l_cov_tbl(1).average            := 0;
       l_cov_tbl(1).unit_of_measure    := l_uom_code;
       l_cov_tbl(1).amount             := l_avg_amount;
       l_cov_tbl(1).amcv_yn            := l_amcv_yn;
       l_cov_tbl(1).id                 := sub_line_rec.cle_id;
       l_cov_tbl(1).date_billed_from   := l_date_from;
       l_cov_tbl(1).date_billed_to     := l_date_to;


       OKS_BILL_REC_PUB.Insert_bcl
               (P_CALLEDFROM        => 1,
                X_RETURN_STAT       => l_return_status,
                P_CLE_ID            => p_cle_id,
                P_DATE_BILLED_FROM  => l_date_from,
                P_DATE_BILLED_TO    => l_date_to,
                P_DATE_NEXT_INVOICE => sysdate,
                P_BILL_ACTION       => 'AV',
                P_OKL_FLAG          => 2,
                P_PRV               => 1,
                P_MSG_COUNT         => l_msg_count,
                P_MSG_DATA          => l_msg_data,
                X_BCL_ID            => l_bcl_id);

       IF (l_return_status <> 'S')  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in insert bcl');
         ROLLBACK;
       End if;

       FND_FILE.PUT_LINE( FND_FILE.LOG, 'bcl '||l_bcl_id);

       l_cov_tbl(1).bcl_id                 := l_bcl_id;

       OKS_BILL_REC_PUB.Insert_all_subline
             (
              P_CALLEDFROM     => 1,
              X_RETURN_STAT    => l_return_status,
              P_COVERED_TBL    => l_cov_tbl,
              P_CURRENCY_CODE  => l_curr_code,
              P_DNZ_CHR_ID     => p_hdr_id,
              P_PRV            => 1,
              P_MSG_COUNT      => l_msg_count,
              P_MSG_DATA       => l_msg_data
              );

       IF (l_return_status <> 'S')  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in insert bsl');
         ROLLBACK;
       End if;

    End if;


    END LOOP;

if l_total_credit > 0 then

    UPDATE oks_bill_cont_lines
    Set averaged_YN = 'Y'
    WHERE cle_id = p_cle_id;

    OKS_ARFEEDER_PUB.Get_REC_FEEDER
       (
         x_return_status             => l_return_status,
         x_msg_count                 => l_msg_count,
         x_msg_data                  => l_msg_data,
         p_flag                      => 2,
         p_called_from               => 1,
         p_date                      => trunc(sysdate),
         p_cle_id                    => p_cle_id,
         p_prv                       => 1,-- to interface termination records
         p_billrep_tbl               => l_billrep_tbl,
         p_billrep_tbl_idx           => l_billrep_tbl_idx,
         p_billrep_err_tbl          => l_billrep_err_tbl,
         p_billrep_err_tbl_idx      => l_billrep_errtbl_idx
       ) ;

       IF (l_return_status   <>  OKC_API.G_RET_STS_SUCCESS) Then
          FND_FILE.PUT_LINE( FND_FILE.LOG, 'Average => Failed in AR FEEDER :'||p_cle_id);
         ROLLBACK;
      End if;
  End if;

   Exception
      WHEN  OTHERS THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'Average => Failed in AR FEEDER :'||p_cle_id);
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'Average => Error is  :'||sqlerrm);
           ROLLBACK;

END average_api;


/*------------------------------------------------------------------
Concurrent Program Wrapper for Usage Biling Averaging and Settlement
--------------------------------------------------------------------*/
PROCEDURE	Average_Main
       (ERRBUF  	  OUT NOCOPY VARCHAR2,
	RETCODE     	  OUT NOCOPY NUMBER,
	P_CONTRACT_ID     IN         NUMBER)
IS
Cursor line_cur(p_id IN  NUMBER) is
SELECT averaging_interval,
       settlement_interval,
       cle_id
    FROM oks_k_lines_b
    WHERE dnz_chr_id  = p_id
    and averaging_interval is not null;


CONC_STATUS		BOOLEAN;
l_return_status		VARCHAR2(1) := 'S';
l_msg_data 		VARCHAR2(2000);
l_msg_count 	        NUMBER;
l_user_id   	        NUMBER;
l_called_from  CONSTANT NUMBER      := 1;

BEGIN

  l_user_id    := FND_GLOBAL.USER_ID;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'User_Id ='||to_char(l_user_id));

  FOR line_Rec in line_cur(p_contract_id)
  LOOP
    IF (line_rec.averaging_interval IS NOT NULL) THEN
      average_api(
                  p_called_from     => l_called_from ,
                  p_cle_id          => line_rec.cle_id ,
                  p_hdr_id          => p_contract_id ,
                  p_avg_interval    => line_rec.averaging_interval ,
                  X_return_status   => l_return_status
                  );
      IF (l_return_status <> 'S') THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,
                'Error in processing averaging for line = '||line_rec.cle_id );
      END IF;

    END IF;
  END LOOP;

  COMMIT;


EXCEPTION
  WHEN OTHERS THEN
       FND_FILE.PUT_LINE( FND_FILE.LOG, 'Average => Failed in AR FEEDER :'||p_contract_id);
       FND_FILE.PUT_LINE( FND_FILE.LOG, 'Average => Error is  :'||sqlerrm);
       ROLLBACK;

END Average_Main;

END OKS_AVG_SET_PUB;

/
