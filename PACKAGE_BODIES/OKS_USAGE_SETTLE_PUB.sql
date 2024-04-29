--------------------------------------------------------
--  DDL for Package Body OKS_USAGE_SETTLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_USAGE_SETTLE_PUB" as
/* $Header: OKSPSTLB.pls 120.7 2006/09/13 21:55:34 hvaladip noship $ */

PROCEDURE Calculate_Settlement
 (
  ERRBUF               OUT      NOCOPY VARCHAR2,
  RETCODE              OUT      NOCOPY NUMBER,
  P_DNZ_CHR_ID          IN             NUMBER
  )
IS
 CURSOR line_cur  (p_chr_id     IN      NUMBER)
 IS
 SELECT line.id, rline.settlement_interval, rline.usage_type,rline.usage_period, line.line_number --Bug 5284103
   FROM oks_k_lines_b   rline,
        okc_k_lines_b   line
   WHERE line.dnz_chr_id = p_chr_id
   AND   rline.cle_id    = line.id
   AND   line.lse_id     = 12
   AND   rline.usage_type = 'VRT'
   AND not exists (select 1 from oks_bill_cont_lines bcl
                   where line.id = bcl.cle_id
                   and   bcl.bill_action = 'SRI');

 CURSOR subline_cur (p_cle_id     IN    NUMBER)
  IS
  SELECT line.id,rline.minimum_quantity,
         line.start_date,line.end_date
   FROM OKC_K_LINES_B  line,
        OKS_K_LINES_B  rline
  WHERE line.cle_id = p_cle_id
  AND   line.lse_id = 13
  AND   rline.cle_id = line.id;

 CURSOR max_date_billed(p_cle_id  IN  NUMBER)
 IS
 SELECT max(date_end),max(date_start)
  FROM  oks_level_elements
 WHERE cle_id   = p_cle_id;

 CURSOR bsl_billed(p_cle_id  IN  NUMBER,p_date_billed_From  IN  DATE,
                   p_date_billed_to   IN   DATE)
 IS
 SELECT  id
   FROM oks_bill_sub_lines
   WHERE cle_id = p_cle_id
   AND   trunc(date_billed_From)= trunc(p_date_billed_From)
   AND   trunc(date_billed_to)  = trunc(p_date_billed_to) ;

 CURSOR l_actual_billed_csr(p_cle_id IN NUMBER) Is
  SELECT  NVL(sum(NVL(Result,0)),0)  qty,
          sum(line.amount)           amt,
          max(line.date_billed_to)   max_bill_to
   FROM    oks_bill_sub_line_dtls ldtl
          ,oks_bill_sub_lines line
   WHERE   line.cle_id = p_cle_id
   AND     ldtl.bsl_id = line.id;


Cursor bsl_billed_period (p_cle_id IN NUMBER)
IS
SELECT bsl.id,
       bsl.date_billed_from,
       bsl.date_billed_to,
       bsl.amount,
       bsd.result
  FROM oks_bill_cont_lines    bcl,
       oks_bill_sub_lines     bsl,
       oks_bill_sub_line_dtls bsd
  WHERE bcl.id  =  bsl.bcl_id
  AND   bcl.bill_action = 'RI'
  AND   bsl.cle_id = p_cle_id
  AND   bsd.bsl_id = bsl.id
 ORDER by bsl.date_billed_to desc;

 CURSOR count_bsl_csr(p_cle_id  IN  NUMBER)
 IS
 SELECT date_billed_from,date_billed_to
 FROM  oks_bill_sub_lines
 WHERE cle_id   = p_cle_id;

 CURSOR l_uom_csr IS
  SELECT uom_code
  FROM   Okc_time_code_units_v
  WHERE  tce_code = 'DAY'
  AND    quantity = 1;

 CURSOR l_inv_item_csr(p_cle_id IN NUMBER) Is
  SELECT mtl.primary_uom_code
  FROM   Okc_K_items Item
        ,mtl_system_items_b   mtl  --Okx_system_items_v mtl
        ,okc_k_headers_b      hdr
        ,okc_k_lines_b   line
  WHERE  item.cle_id = line.id     --p_cle_id
  AND    line.id     = p_cle_id
  AND    line.dnz_chr_id = hdr.id
  --AND    mtl.id1 = item.object1_id1
  AND    mtl.inventory_item_id = item.object1_id1
  AND    mtl.organization_id = hdr.inv_organization_id;


--Bug# 5284103

Cursor get_counter_qty(p_id Number, p_lock_read number) IS
        select value_timestamp from cs_counter_values
        where counter_id = p_id
        and   counter_reading = p_lock_read;

 CURSOR get_bp_lookup_meaning_csr Is
	SELECT	Fnd.Meaning
	FROM	FND_LOOKUPS Fnd
	WHERE	Fnd.Lookup_Type = 'OKS_SETTLEMENT_INTERVAL'
	AND	Fnd.Lookup_Code = 'BP';

l_bp_fnd_meaning		varchar2(30);
l_settlement_interval		varchar2(30);

--End Bug# 5284103

l_counter_reading_lock_rec  csi_ctr_datastructures_pub.ctr_reading_lock_rec;
 l_return_status        VARCHAR2(1) := 'S';
 l_qty                  NUMBER;
 l_temp                  NUMBER;
 l_billed_qty           NUMBER;
 l_billed_amt           NUMBER;
 l_max_bill_to          DATE;
 l_credit_amount        NUMBER;
 l_term_amount          NUMBER;
 l_credit_qty           NUMBER;
 l_term_qty             NUMBER;
 l_id                   NUMBER;
 l_counter_value        NUMBER;
 l_counter_date         DATE;
 l_period_start_date    DATE;
 l_period_end_date      DATE;
 l_start_reading        NUMBER;
 l_end_reading          NUMBER;
 l_base_reading         NUMBER;
 l_counter_value_id     NUMBER;
 l_counter_group_id     NUMBER;
 l_counter_id           NUMBER;
 l_minimum              NUMBER;
 l_bsl_count            NUMBER;
 l_uom_code             VARCHAR2(20);
 l_usage_type           VARCHAR2(20);
 l_time_uom             VARCHAR2(20);
 l_primary_uom_code     VARCHAR2(20);
 l_billrep_tbl          OKS_BILL_REC_PUB.bill_report_tbl_type;
 l_billrep_tbl_idx      NUMBER := 0;
 l_billrep_err_tbl       OKS_BILL_REC_PUB.billrep_error_tbl_type;
 l_billrep_errtbl_idx    NUMBER;



 l_lock_id              NUMBER;
 l_msg_cnt              NUMBER;
 l_msg_data             VARCHAR2(2000);


 l_line_rec                 OKS_QP_PKG.Input_details ;
 l_price_rec                OKS_QP_PKG.Price_Details ;
 l_modifier_details         QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 l_price_break_details      OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- local variables for partal periods
-------------------------------------------------------------------------
l_hdr_id              NUMBER;
l_price_uom           OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start        OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type         OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
-------------------------------------------------------------------------

 l_ignore_settlement_msg   varchar2(1000);	--Bug# 5284103

 BEGIN
    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 30-MAY-2005
    -- Call oks_renew_util_pub.get_period_defaults to fetch period start and period type
    -------------------------------------------------------------------------
    IF P_DNZ_CHR_ID IS NOT NULL THEN
      OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => P_DNZ_CHR_ID,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => l_return_status);
    END IF;
    --For usage , the period start should be SERVICE
   l_period_start := 'SERVICE';
   FOR line_Rec in line_cur(p_dnz_chr_id)
   LOOP
   --Bug# 5284103
   IF (line_Rec.settlement_interval = 'EU') THEN

     OPEN  l_inv_item_csr(line_Rec.id);
     FETCH l_inv_item_csr into l_primary_uom_code;
     CLOSE l_inv_item_csr;

     OPEN  l_uom_csr;
     FETCH l_uom_csr into l_time_uom;
     CLOSE l_uom_csr;

     /*Run settlement for each subline */
     FOR subline_Rec in subline_cur(line_rec.id)
     LOOP


       OPEN  max_date_billed(subline_Rec.id);
       FETCH max_date_billed INTO  l_period_end_date,l_period_start_date;
       CLOSE max_date_billed;

       /* Check if the subline is fully billed */
       OPEN  bsl_billed(subline_Rec.id,l_period_start_date,l_period_end_date);
       FETCH bsl_billed INTO l_id;
       IF (bsl_billed%FOUND) THEN
         OKS_BILL_REC_PUB.Counter_Values
           (
          --P_CALLEDFROM        => 3,
	    P_CALLEDFROM        => 4,  --refers to Settlement  Bug# 5235116
            P_START_DATE        => subline_rec.start_date,  --l_period_start_date,
            P_END_DATE          => subline_rec.end_date  ,  --l_period_end_date,
            P_CLE_ID            => subline_rec.id,
            P_USAGE_TYPE        => line_rec.usage_type , --l_usage_type,
            X_VALUE             => l_qty,
            X_COUNTER_VALUE     => l_counter_value,
            X_COUNTER_DATE      => l_counter_date,
            X_UOM_CODE          => l_uom_code,
            X_END_READING       => l_end_reading,
            X_START_READING     => l_start_reading,
            X_BASE_READING      => l_base_reading,
            X_COUNTER_VALUE_ID  => l_counter_value_id,
            X_COUNTER_GROUP_ID  => l_counter_group_id,
            X_COUNTER_ID        => l_counter_id,
            X_RETURN_STATUS     => l_return_status
           );

         OPEN  l_actual_billed_csr(subline_Rec.id);
         FETCH l_actual_billed_csr INTO  l_billed_qty, l_billed_amt, l_max_bill_to;
         CLOSE l_actual_billed_csr;


         IF (l_qty < 0) THEN
           l_minimum := 0;
           /*
           OPEN  count_bsl_csr(subline_Rec.id);
           FETCH count_bsl_csr into l_bsl_count;
           CLOSE count_bsl_csr;

           l_minimum := l_bsl_count * subline_Rec.minimum_quantity;
           */

           FOR bsl_rec in count_bsl_csr(subline_Rec.id)
           LOOP
             /* This Loop is required to calc minimum Qty for entire subline effectivity.
                Loop is required to get minimum qty per billed period which can be of different time length
             */
              -------------------------------------------------------------------------
              -- Begin partial period computation logic
              -- Developer Mani Choudhary
              -- Date 13-JUN-2005
              -- call oks_bill_rec_pub.Get_prorated_Usage_Qty to get the prorated usage
              -------------------------------------------------------------------------
             IF l_period_type IS NOT NULL AND
                l_period_start IS NOT NULL
             THEN
               l_temp := OKS_BILL_REC_PUB.Get_Prorated_Usage_Qty
                       (
                       p_start_date  => bsl_rec.date_billed_from,
                       p_end_date    => bsl_rec.date_billed_to,
                       p_qty         => subline_Rec.minimum_quantity,
                       p_usage_uom   => line_rec.usage_period,
                       p_billing_uom => l_time_uom,
                       p_period_type => l_period_type
                       );
               l_minimum := l_minimum + Round(l_temp,0);
             ELSE
               --Existing logic
               l_temp :=  OKS_TIME_MEASURES_PUB.GET_TARGET_QTY
                          (
                           p_start_date  => bsl_rec.date_billed_from,
                           p_source_qty  => 1,
                           p_source_uom  => line_rec.usage_period,
                           p_target_uom  => l_time_uom,
                           p_round_dec   => 0
                          );

               l_minimum := l_minimum + Round((trunc(bsl_rec.date_billed_to) - trunc(bsl_rec.date_billed_from) + 1)
                                                              * (subline_Rec.minimum_quantity /l_temp) ,0) ;
             END IF; --period start and period type are not null
           END LOOP;

           IF (l_counter_value < l_minimum) THEN
             l_qty := -1 * (l_billed_qty - l_minimum);
           END IF;
         END IF;

         l_line_rec.line_id          := line_Rec.id;
         l_line_rec.intent           := 'USG';
         l_line_rec.usage_qty        := abs(l_qty ); -- qty
         l_line_rec.usage_uom_code   := l_primary_uom_code;
         --l_line_rec.bsl_id           := bsl_price_rec.bsl_id;
         l_line_rec.subline_id       := subline_Rec.id;


              /*Pricing API to calculate amount */
         OKS_QP_PKG.CALC_PRICE
            (
             P_DETAIL_REC          => l_line_rec,
             X_PRICE_DETAILS       => l_price_rec,
             X_MODIFIER_DETAILS    => l_modifier_details,
             X_PRICE_BREAK_DETAILS => l_price_break_details,
             X_RETURN_STATUS       => l_return_status,
             X_MSG_COUNT           => l_msg_cnt,
             X_MSG_DATA            => l_msg_data
             );

         /* If Quantity already billed is greater than actual , then issue credit */
         IF (l_qty <  0 ) THEN -- l_billed_qty) THEN
           --issue credit
           l_credit_amount := l_price_rec.prod_Ext_amount;
           l_credit_qty    := abs(l_qty);
           FOR cur in bsl_billed_period(subline_Rec.id)
           LOOP
             IF (l_credit_amount <= 0) THEN
               EXIT;
             END IF;

             IF (l_credit_amount >= cur.amount) THEN
               l_term_amount :=  cur.amount;
               l_term_qty    :=  cur.result;
             ELSE
               l_term_amount :=  l_credit_amount;
               l_term_qty    :=  l_credit_qty;
             END IF;

             OKS_BILL_REC_PUB.Create_trx_records(
                P_CALLED_FROM          => 3 ,
                P_TOP_LINE_ID          => line_rec.id,
                P_COV_LINE_ID          => subline_Rec.id,
                P_DATE_FROM            => cur.date_billed_from ,
                P_DATE_TO              => cur.date_billed_to,
                P_AMOUNT               => l_term_qty,
                P_OVERRIDE_AMOUNT      => NULL,
                --P_EXISTING_CREDIT      => NULL,
                P_SUPPRESS_CREDIT      => 'N',
                P_CON_TERMINATE_AMOUNT => l_term_amount,
                P_BILL_ACTION          => 'STR',
                X_RETURN_STATUS        => l_return_status
                );
             l_credit_amount := l_credit_amount - cur.amount;
             l_credit_qty    := l_credit_qty - cur.result;
           END LOOP;

         ELSIF (l_qty >  0) THEN
         /* If Quantity already billed is lesser than actual , then issue invoice */
           --issue invoice
           OKS_BILL_REC_PUB.Create_trx_records(
                P_CALLED_FROM          => 3,
                P_TOP_LINE_ID          => line_rec.id,
                P_COV_LINE_ID          => subline_Rec.id,
                P_DATE_FROM            => l_period_start_date ,
                P_DATE_TO              => l_period_end_date,
                P_AMOUNT               => l_qty,
                P_OVERRIDE_AMOUNT      => NULL,
                --P_EXISTING_CREDIT      => NULL,
                P_SUPPRESS_CREDIT      => 'N',
                P_CON_TERMINATE_AMOUNT => l_price_rec.PROD_EXT_AMOUNT,
                P_BILL_ACTION          => 'SRI',
                X_RETURN_STATUS        => l_return_status
                );

         END IF;

       END IF;
       CLOSE bsl_billed ;

          open get_counter_qty(l_counter_id,l_end_reading);
	  fetch get_counter_qty into l_max_bill_to;
	  close get_counter_qty;

           l_counter_reading_lock_rec.reading_lock_date := l_max_bill_to;
           l_counter_reading_lock_rec.counter_id := l_counter_id;
           l_counter_reading_lock_rec.source_line_ref_id := subline_Rec.id;
           l_counter_reading_lock_rec.source_line_ref := 'CONTRACT_LINE';

           Csi_Counter_Pub.create_reading_lock
           (
                    p_api_version          => 1.0,
                    p_commit               => 'F',
                    p_init_msg_list        => 'T',
                    p_validation_level     => 100,
                    p_ctr_reading_lock_rec => l_counter_reading_lock_rec,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_cnt,
                    x_msg_data            => l_msg_data,
                    x_reading_lock_id     => l_lock_id
           );


      END LOOP;

  ELSE  --(line_Rec.settlement_interval = 'EU')
	--Bug# 5284103
	--Print message in output and log file
	If (line_Rec.settlement_interval = 'BP') Then
		Open get_bp_lookup_meaning_csr;
		Fetch get_bp_lookup_meaning_csr into l_bp_fnd_meaning;
		Close get_bp_lookup_meaning_csr;

		l_settlement_interval := l_bp_fnd_meaning;
	Else
		l_settlement_interval := 'NULL';
	End If;

	FND_MESSAGE.CLEAR;
	FND_MESSAGE.SET_NAME('OKS','OKS_IGNORE_SETTLEMENT');
	fnd_message.set_token('LINE_NO', line_Rec.line_number);
	fnd_message.set_token('SETLLEMENT_INTERVAL', l_settlement_interval);
	l_ignore_settlement_msg := FND_MESSAGE.GET;

	FND_FILE.PUT_LINE(FND_FILE.OUTPUT , l_ignore_settlement_msg);
	FND_FILE.PUT_LINE(FND_FILE.LOG, l_ignore_settlement_msg);

	--Line <line_number> is ignored since settlement interval is <Null/ Billing Period>

  END IF; -- (line_Rec.settlement_interval = 'EU')
 --End Bug# 5284103

 END LOOP;


   /* Interface records to AR */
   OKS_ARFEEDER_PUB.Get_REC_FEEDER
            (
             X_RETURN_STATUS            => l_return_status,
             X_MSG_COUNT                => l_msg_cnt,
             X_MSG_DATA                 => l_msg_data,
             P_FLAG                     => 0,  -- checkout
             P_CALLED_FROM              => 1,
             P_DATE                     => sysdate,
             P_CLE_ID                   => NULL,
             P_PRV                      => 3,
             p_billrep_tbl               => l_billrep_tbl,
             p_billrep_tbl_idx           => l_billrep_tbl_idx,
             p_billrep_err_tbl          => l_billrep_err_tbl,
             p_billrep_err_tbl_idx      => l_billrep_errtbl_idx
            ) ;

   COMMIT;
 END Calculate_Settlement;

END OKS_USAGE_SETTLE_PUB;

/
