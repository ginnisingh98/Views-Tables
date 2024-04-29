--------------------------------------------------------
--  DDL for Package Body ARP_BALANCE_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BALANCE_CHECK" AS
/* $Header: ARBALCHB.pls 120.4.12010000.5 2010/06/19 06:53:49 vpusulur ship $ */

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  PG_BAL_CHECK_ENABLED varchar2(1) := NVL(FND_PROFILE.value('AR_ENABLE_JOURNAL_BAL_CHECK'),'Y');
 /*PG_AUTO_CORRECT_ENABLED varchar2(1) := NVL(FND_PROFILE.value('AR_ENABLE_AUTO_CORRECTION_CHECK'),'Y');*/
/* =======================================================================
 | PROCEDURE Check_Transaction_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for transactions
 |      and tallies that debits equal credits, if not then it sets a
 |      message on the message stack indicating that items are out of
 |      balance.
 |
 | PARAMETERS
 |      p_customer_trx_id       IN      Cash receipt id
 |      p_called_from_api       IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_TRANSACTION_BALANCE(p_customer_trx_id IN VARCHAR2,
                                    p_called_from_api IN VARCHAR2 default 'N') IS

CURSOR C1(p_cust_trx_id NUMBER) IS
   SELECT sum(decode(ctlgd.account_class,
              'REC', nvl(amount,0) * -1,
              nvl(amount,0)))       net_amount,
          sum(decode(ctlgd.account_class,
              'REC', nvl(acctd_amount,0) * -1,
              nvl(acctd_amount,0))) net_acctd_amount,
          gl_date
   from ra_cust_trx_line_gl_dist ctlgd
   where ctlgd.customer_trx_id = p_cust_trx_id
   and ctlgd.account_set_flag = 'N'
   and ctlgd.posting_control_id = -3
   and not exists (select 'x'
                   from ra_customer_trx_lines ctl
                   where ctl.customer_trx_id = p_customer_trx_id
                   and ctl.autorule_complete_flag||'' = 'N'
                   group by ctl.customer_trx_id)
   group by customer_trx_id, gl_date;

l_amount NUMBER;
l_acctd_amount NUMBER;
l_no_balance VARCHAR2(1):= 'N';
-- OKL LLCA Bug 6129910
l_return_status  VARCHAR2(1)   := fnd_api.g_ret_sts_success;
l_msg_data       VARCHAR2(2000);
l_msg_count      NUMBER;
l_customer_rec ra_customer_trx%ROWTYPE;
l_gen_line_level_bal_flag VARCHAR(1) := 'N';
excep_set_org_rem_amt_r12 EXCEPTION;


BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.Check_Transaction_Balance (+)' );
END IF;

IF p_customer_trx_id IS NOT NULL THEN

--- OKL LLCA Bug 6129910
   l_customer_rec.customer_trx_id := p_customer_trx_id;
-- Check the batch source flag

   SELECT NVL(gen_line_level_bal_flag,'N')
   INTO  l_gen_line_level_bal_flag
   FROM  ra_batch_sources ra, ra_customer_trx rt
   WHERE ra.batch_source_id = rt.batch_source_id
	AND rt.customer_trx_id = p_customer_trx_id;

IF l_gen_line_level_bal_flag = 'Y' THEN
	   ARP_DET_DIST_PKG.set_original_rem_amt_r12
	   (	p_customer_trx     => l_customer_rec,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		p_from_llca => 'Y');


	  IF l_return_status <> fnd_api.g_ret_sts_success THEN
		RAISE excep_set_org_rem_amt_r12;
	  END IF;

  END IF;
 ---  OKL LLCA End
--bug6762463
  IF PG_BAL_CHECK_ENABLED = 'Y' THEN
     FOR c2 in c1(p_customer_trx_id) LOOP

       l_amount       := c2.net_amount;
       l_acctd_amount := c2.net_acctd_amount;

       IF l_amount <> 0 OR l_acctd_amount <> 0 THEN
        /* The exception could have been raised here, but continuing to
           print the debug messages */
         l_no_balance := 'Y' ;
       END IF;
       IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('GL_DATE : '||to_char(c2.gl_date,'DD-MON-YYYY'));
         arp_standard.debug('Net Amount :' || l_amount);
         arp_standard.debug('Net Acctd Amount :' || l_acctd_amount);
       END IF;
     END LOOP;

     --------------------------------------------------------
     --Set the message on the message stack
     --------------------------------------------------------
     IF l_no_balance = 'Y' THEN

       IF p_called_from_api = 'Y' THEN
          fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
          fnd_msg_pub.Add;
       END IF;

       RAISE out_of_balance;

    END IF;

 ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Profile AR: Enable Journal Balance Check is disabled ');
    END IF;
 END IF;
END IF; -- p_customer_trx_id is not null , bug6762463

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.Check_Transaction_Balance (-)' );
END IF;

EXCEPTION
  WHEN out_of_balance THEN
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('ARP_BALANCE_CHK.Check_Transaction_Balance - OUT_OF_BALANCE');
     END IF;
     fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
     app_exception.raise_exception;
  WHEN NO_DATA_FOUND THEN
     /* Case for invoice with rules */
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ARP_BALANCE_CHK.Check_Transaction_Balance - NO_DATA_FOUND' );
     END IF;
     WHEN excep_set_org_rem_amt_r12 THEN --LLCA
	 IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug('EXCEPTION_set_original_rem_amt_r12 error count:'||l_msg_count);
	arp_standard.debug('last error:'||l_msg_data);
	END IF;
	 RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ARP_BALANCE_CHK.Check_Transaction_Balance - OTHERS' );
     END IF;
     RAISE;

END CHECK_TRANSACTION_BALANCE;

/* =======================================================================
 | PROCEDURE Check_Recp_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for receipts and
 |      adjustments including discounts and tallies that debits equal
 |      credits, if not then it sets a message on the message stack
 |      indicating that items are out of balance.
 |
 | PARAMETERS
 |      p_cr_id                 IN      Cash receipt id
 |      p_request_id            IN      Request id
 |      p_called_from_api       IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_RECP_BALANCE(
                  p_cr_id           IN  NUMBER,
                  p_request_id      IN  NUMBER,
                  p_called_from_api IN  VARCHAR2 default 'N') IS
 cursor c1(p_cr_id IN NUMBER) is
    select sum(nvl(amount_dr,0)) sum_amount_dr,
           sum(nvl(amount_cr,0)) sum_amount_cr,
           sum(nvl(acctd_amount_dr,0)) sum_acctd_amount_dr,
           sum(nvl(acctd_amount_cr,0)) sum_acctd_amount_cr,
           max(src.cc_flag) cc_flag, src.gl_date
      from (select cash_receipt_id cr_id,
                   misc_cash_distribution_id src_id,
                   'MCD' src_tab,
                   'N' cc_flag,
                   gl_date
             from  ar_misc_cash_distributions
            where  cash_receipt_id = p_cr_id
              and  posting_control_id = -3
              UNION ALL
            select cash_receipt_id cr_id,
                   cash_receipt_history_id src_id,
                   'CRH'  src_tab,
                   'N'  cc_flag,
                   gl_date
              from ar_cash_receipt_history
            where  cash_receipt_id = p_cr_id
              and  posting_control_id = -3
              and  nvl(postable_flag,'Y') = 'Y'
              UNION ALL
            select cash_receipt_id cr_id,
                   receivable_application_id src_id,
                   'RA' src_tab,
                   decode(amount_applied_from,NULL,
                          'N',
                          'Y') cc_flag,
                   gl_date
              from ar_receivable_applications
             where cash_receipt_id = p_cr_id
               and nvl(confirmed_flag,'Y') = 'Y'
               and nvl(postable,'Y') = 'Y'
               and posting_control_id = -3) src,
            ar_distributions ard
      where ard.source_id = src.src_id
        and ard.source_table = src.src_tab
      group by src.gl_date;

l_no_balance   VARCHAR2(1) := 'N';

 l_corrupt_type             VARCHAR2(20);
 ps_data_corrupted  EXCEPTION;

 l_gl_date_closed   DATE;
 l_actual_date_closed  DATE;
 l_corruption_exists BOOLEAN := FALSE;
 l_corruption_string VARCHAR2(50);

  l_check_amount_dr	NUMBER;
  l_check_amount_cr	NUMBER;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_RECP_BALANCE (+)');
END IF;

IF PG_BAL_CHECK_ENABLED = 'Y' THEN

  IF p_cr_id IS NOT NULL AND arp_global.sysparam.accounting_method = 'ACCRUAL' THEN

   FOR c2 in c1(p_cr_id) LOOP

     IF (c2.sum_amount_dr <> c2.sum_amount_cr AND c2.cc_flag = 'N') OR
        (c2.sum_acctd_amount_dr <> c2.sum_acctd_amount_cr) THEN

        /* Exception Out_of_balance could have been raised here. But continuing the flow
          to print debug messages */
        l_no_balance := 'Y' ;
	l_check_amount_dr :=  c2.sum_acctd_amount_dr;
	l_check_amount_cr :=  c2.sum_acctd_amount_cr;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('GL_DATE : '||to_char(c2.gl_date,'DD-MON-YYYY'));
        arp_standard.debug('Sum_amount_dr :' || c2.sum_amount_dr);
        arp_standard.debug('Sum_amount_cr :' || c2.sum_amount_cr);
        arp_standard.debug('Sum_acctd_amount_dr : '||c2.sum_acctd_amount_dr);
        arp_standard.debug('Sum_acctd_amount_cr : '||c2.sum_acctd_amount_cr);
        arp_standard.debug('CC_flag : '||c2.cc_flag);
     END IF;
   END LOOP;

   --------------------------------------------------------
   --Set the message on the message stack
   --------------------------------------------------------
   IF l_no_balance = 'Y' THEN

      IF p_called_from_api = 'Y' THEN
         fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
         fnd_msg_pub.Add;
      END IF;

      RAISE out_of_balance;

   END IF;

  END IF; --p_receipt id is NOT NULL

ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Profile AR: Enable Journal Balance Check is disabled ');
    END IF;
END IF;

IF ((p_ps_rec.payment_schedule_id is not null or p_ps_rec_pmt.payment_schedule_id is not null)
     AND p_request_id is null
     AND p_called_from_api = 'N'
   ) THEN
      BEGIN
       arp_standard.debug('Class :' || p_ps_rec.class);
       arp_standard.debug('p_request_id :' || p_request_id);
       arp_standard.debug('p_called_from_api :' || p_called_from_api);
       arp_standard.debug('psid1 :' || p_ps_rec.payment_schedule_id);
       arp_standard.debug('psid2 :' || p_ps_rec_pmt.payment_schedule_id);

         IF p_ps_rec.payment_schedule_id is not null THEN
                CHECK_PS_DATE(
           p_ps_rec        => p_ps_rec,
           p_corrupt_type   => l_corrupt_type,
           p_gl_date_closed  => l_gl_date_closed,
           p_actual_date_closed      => l_actual_date_closed);
         END IF;

         IF p_ps_rec_pmt.payment_schedule_id is not null THEN
                CHECK_PS_DATE(
           p_ps_rec        => p_ps_rec_pmt,
           p_corrupt_type   => l_corrupt_type,
           p_gl_date_closed  => l_gl_date_closed,
           p_actual_date_closed      => l_actual_date_closed);
         END IF;




           ARP_BALANCE_CHECK.P_ps_rec.payment_schedule_id  := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.customer_trx_id      := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.cash_receipt_id      := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.class                := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.actual_date_closed   := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.status               := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.trx_number           := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.gl_date_closed       := NULL;

           ARP_BALANCE_CHECK.P_ps_rec_pmt.payment_schedule_id  := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.customer_trx_id      := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.cash_receipt_id      := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.class                := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.actual_date_closed   := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.status               := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.trx_number           := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.gl_date_closed       := NULL;

         IF l_corrupt_type is not null then
           l_corruption_exists :=TRUE;
           RAISE ps_data_corrupted;
         END IF;

      EXCEPTION
          WHEN ps_data_corrupted THEN
          fnd_message.set_name('AR','GENERIC_MESSAGE');

          IF l_corrupt_type = 'ACTUAL_DATE' THEN
                l_corruption_string := 'Actual Date Closed';
          ELSIF l_corrupt_type = 'GL_DATE' THEN
                l_corruption_string := 'GL Date Closed';
          ELSIF l_corrupt_type = 'BOTH_ACT_GL' THEN
                l_corruption_string := 'Actual Date Closed and GL Date Closed';
          END IF;

          fnd_message.set_token ( token => 'GENERIC_TEXT',
                            value => 'The Value Is Incorrect for '||l_corruption_string ||' .Please Contact Oracle Support');
          app_exception.raise_exception;
      END;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_RECP_BALANCE (-)');
END IF;

EXCEPTION
  WHEN out_of_balance THEN
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('ARP_BALANCE_CHK.CHECK_RECP_BALANCE - OUT_OF_BALANCE');
     END IF;

     if CHECK_PRECISION(l_check_amount_dr) then
        FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     elsif CHECK_PRECISION(l_check_amount_cr) then
        FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     else
     fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
     end if;

     app_exception.raise_exception;

  WHEN ps_data_corrupted THEN
       app_exception.raise_exception;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_RECP_BALANCE - OTHERS');
     END IF;
     RAISE;

END CHECK_RECP_BALANCE;


/* =======================================================================
 | PROCEDURE Check_Recp_Balance_Bulk
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for receipts
 |      including discounts and tallies that debits equal credits, if
 |      not then it sets a message on the message stack indicating that
 |      items are out of balance.
 |
 | PARAMETERS
 |      p_cr_id_low             IN		Cash Receipt Id Low.
 |      p_cr_id_high            IN              Cash Receipt Id High.
 |      p_unbalanced_cr_tbl     OUT NOCOPY	Unbalanced CR Id's.
 * ======================================================================*/
PROCEDURE CHECK_RECP_BALANCE_BULK(
                  p_cr_id_low        IN  NUMBER,
		  p_cr_id_high       IN  NUMBER,
                  p_unbalanced_cr_tbl OUT NOCOPY unbalanced_receipts) IS

 cursor c1(p_cr_id_low   IN  NUMBER,
           p_cr_id_high  IN  NUMBER) is
      select sum(nvl(amount_dr,0)) sum_amount_dr,
           sum(nvl(amount_cr,0)) sum_amount_cr,
           sum(nvl(acctd_amount_dr,0)) sum_acctd_amount_dr,
           sum(nvl(acctd_amount_cr,0)) sum_acctd_amount_cr,
           max(src.cc_flag) cc_flag, src.gl_date, src.cr_id
      from (	     select mcd.cash_receipt_id cr_id,
                   mcd.misc_cash_distribution_id src_id,
                   'MCD' src_tab,
                   'N' cc_flag,
                   mcd.gl_date
             from  ar_cash_receipts cr, ar_misc_cash_distributions mcd
            where  cr.cash_receipt_id between p_cr_id_low and p_cr_id_high
	      and  cr.cash_receipt_id = mcd.cash_receipt_id
              and  mcd.posting_control_id = -3
              UNION ALL
            select crh.cash_receipt_id cr_id,
                   crh.cash_receipt_history_id src_id,
                   'CRH'  src_tab,
                   'N'  cc_flag,
                   crh.gl_date
              from ar_cash_receipts cr, ar_cash_receipt_history crh
            where  cr.cash_receipt_id between p_cr_id_low and p_cr_id_high
	      and  cr.cash_receipt_id = crh.cash_receipt_id
              and  crh.posting_control_id = -3
              and  nvl(crh.postable_flag,'Y') = 'Y'
              UNION ALL
            select ra.cash_receipt_id cr_id,
                   ra.receivable_application_id src_id,
                   'RA' src_tab,
                   decode(ra.amount_applied_from,NULL,
                          'N',
                          'Y') cc_flag,
                   ra.gl_date
              from ar_cash_receipts cr, ar_receivable_applications ra
             where cr.cash_receipt_id between p_cr_id_low and p_cr_id_high
	       and cr.cash_receipt_id = ra.cash_receipt_id
               and nvl(ra.confirmed_flag,'Y') = 'Y'
               and nvl(ra.postable,'Y') = 'Y'
               and ra.posting_control_id = -3) src,
            ar_distributions ard
      where ard.source_id = src.src_id
        and ard.source_table = src.src_tab
      group by src.gl_date, src.cr_id
      having ((sum(nvl(amount_dr,0)) <> sum(nvl(amount_cr,0)) AND max(src.cc_flag) = 'N')
             OR (sum(nvl(acctd_amount_dr,0)) <> sum(nvl(acctd_amount_cr,0))))
      order by src.cr_id;

 l_bulk_index     NUMBER := 0;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHECK.CHECK_RECP_BALANCE_BULK (+)');
END IF;

IF PG_BAL_CHECK_ENABLED = 'Y' THEN

  IF p_cr_id_low IS NOT NULL AND p_cr_id_high IS NOT NULL AND arp_global.sysparam.accounting_method = 'ACCRUAL' THEN

   FOR c2 in c1(p_cr_id_low, p_cr_id_high) LOOP

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHECK.CHECK_RECP_BALANCE_BULK - OUT_OF_BALANCE');
        arp_standard.debug('Cash Receipt Id: '     || c2.cr_id);
        arp_standard.debug('GL Date: '             || to_char(c2.gl_date,'DD-MON-YYYY'));
        arp_standard.debug('Sum Amount Dr: '       || c2.sum_amount_dr);
        arp_standard.debug('Sum Amount Cr: '       || c2.sum_amount_cr);
        arp_standard.debug('Sum Acctd Amount Dr: ' || c2.sum_acctd_amount_dr);
        arp_standard.debug('Sum Acctd Amount Cr: ' || c2.sum_acctd_amount_cr);
        arp_standard.debug('Cross Currency Flag: ' || c2.cc_flag);
     END IF;

     l_bulk_index := l_bulk_index + 1;
     p_unbalanced_cr_tbl(l_bulk_index).cash_receipt_id := c2.cr_id;

     IF CHECK_PRECISION(c2.sum_acctd_amount_dr)
        OR CHECK_PRECISION(c2.sum_acctd_amount_cr)
     THEN
        p_unbalanced_cr_tbl(l_bulk_index).message_code := 'AR_APP_CURR_PRECISION';
     ELSE
        p_unbalanced_cr_tbl(l_bulk_index).message_code := 'AR_AMOUNTS_NO_MATCH';
     END IF;

   END LOOP;

  END IF;

ELSE

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Profile AR: Enable Journal Balance Check is disabled ');
    END IF;

END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHECK.CHECK_RECP_BALANCE_BULK (-)');
END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHECK.CHECK_RECP_BALANCE_BULK - OTHERS');
     END IF;
     RAISE;
END CHECK_RECP_BALANCE_BULK;


/* =======================================================================
 | PROCEDURE Check_Adj_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for adjustments
 |      tallies that debits equal credits, if not then it sets a message
 |      on the message stack indicating that items are out of balance.
 |      For Non postable adjustments, it makes sure that the amount is
 |      equal to the amounts assigned to different buckets
 |
 | PARAMETERS
 |      p_adj_id                IN      Adjustment id
 |      p_request_id            IN      Request id
 |      p_called_from_api       IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_ADJ_BALANCE(
                  p_adj_id          IN  NUMBER,
                  p_request_id      IN  NUMBER,
                  p_called_from_api IN  VARCHAR2 default 'N') IS


l_amt_dr       NUMBER;
l_amt_cr       NUMBER;
l_acctd_amt_dr NUMBER;
l_acctd_amt_cr NUMBER;
l_amount       NUMBER;
l_calc_amount  NUMBER;
l_status       VARCHAR2(1); /*5017553*/
 l_corrupt_type             VARCHAR2(20);
 ps_data_corrupted  EXCEPTION;
 l_gl_date_closed   DATE;
 l_actual_date_closed  DATE;
 l_corruption_exists BOOLEAN := FALSE;
 l_corruption_string VARCHAR2(50);
 l_check_amount_dr	NUMBER;
 l_check_amount_cr	NUMBER;

BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_ADJ_BALANCE (+)');
END IF;

IF PG_BAL_CHECK_ENABLED = 'Y' THEN

  IF p_adj_id IS NOT NULL AND arp_global.sysparam.accounting_method = 'ACCRUAL' THEN

   /* Check amount_dr equals to amount_cr */

   select sum(nvl(amount_dr,0)), sum(nvl(amount_cr,0)),
          sum(nvl(acctd_amount_dr,0)), sum(nvl(acctd_amount_cr,0))
   into l_amt_dr, l_amt_cr, l_acctd_amt_dr, l_acctd_amt_cr
   from (select  adjustment_id src_id,
                'ADJ' src_tab
         from  ar_adjustments
         where  adjustment_id = p_adj_id
         and   nvl(postable,'Y') = 'Y'
         and posting_control_id = -3) src,
   ar_distributions ard
   where ard.source_id = src.src_id
   and ard.source_table = src.src_tab;

   --------------------------------------------------------
   --Set the message on the message stack
   --------------------------------------------------------
   IF (l_amt_dr <> l_amt_cr) OR (l_acctd_amt_dr <> l_acctd_amt_cr) THEN

      IF p_called_from_api = 'Y' THEN

         fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
         fnd_msg_pub.Add;

      END IF;
	l_check_amount_dr := l_acctd_amt_dr;
	l_check_amount_cr := l_acctd_amt_cr;
      RAISE out_of_balance;

   END IF;

   /* Check that Amount = line_adjusted+tax+adjusted+freight_adjusted+
                 receivables_charges_adjusted */
   select nvl(amount,0), nvl(line_adjusted,0)+nvl(tax_adjusted,0)+
          nvl(freight_adjusted,0)+nvl(receivables_charges_adjusted,0),
          status
     into l_amount, l_calc_amount,l_status
   from   ar_adjustments
   where  adjustment_id = p_adj_id;

   IF l_amount <> l_calc_amount AND l_status = 'A' THEN
     IF p_called_from_api = 'Y' THEN

         fnd_message.set_name('AR','AR_ADJ_AMT_NO_MATCH');
         fnd_msg_pub.Add;

      END IF;

      RAISE amount_mismatch;
   END IF;

  END IF; --adjustment id is not null

ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Profile AR: Enable Journal Balance Check is disabled ');
    END IF;
END IF;

IF (p_ps_rec.payment_schedule_id is not null
    AND p_request_id is null
    AND p_called_from_api = 'N'
   ) THEN

      BEGIN
           CHECK_PS_DATE(
           p_ps_rec        => p_ps_rec,
           p_corrupt_type   => l_corrupt_type,
           p_gl_date_closed  => l_gl_date_closed,
           p_actual_date_closed      => l_actual_date_closed);

           ARP_BALANCE_CHECK.P_ps_rec.payment_schedule_id  := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.customer_trx_id      := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.cash_receipt_id      := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.class                := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.actual_date_closed   := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.status               := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.trx_number           := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.gl_date_closed       := NULL;

         IF l_corrupt_type is not null then
           l_corruption_exists :=TRUE;
           RAISE ps_data_corrupted;
         END IF;
      EXCEPTION
          WHEN ps_data_corrupted THEN
          fnd_message.set_name('AR','GENERIC_MESSAGE');

          IF l_corrupt_type = 'ACTUAL_DATE' THEN
                l_corruption_string := 'Actual Date Closed';
          ELSIF l_corrupt_type = 'GL_DATE' THEN
                l_corruption_string := 'GL Date Closed';
          ELSIF l_corrupt_type = 'BOTH_ACT_GL' THEN
                l_corruption_string := 'Actual Date Closed and GL Date Closed';
          END IF;

          fnd_message.set_token ( token => 'GENERIC_TEXT',
                            value => 'The Value Is Incorrect for '||l_corruption_string ||' .Please Contact Oracle Support');
          app_exception.raise_exception;
      END;
END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_ADJ_BALANCE (-)');
 END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_ADJ_BALANCE - NO_DATA_FOUND');
     END IF;
     RAISE;
  WHEN out_of_balance THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_ADJ_BALANCE - OUT_OF_BALANCE');
        arp_standard.debug('Adjustment_id = '||p_adj_id);
        arp_standard.debug('Amount Debit = '||l_amt_dr);
        arp_standard.debug('Amount Credit = '||l_amt_cr);
        arp_standard.debug('Acctd Amount Debit = '||l_acctd_amt_dr);
        arp_standard.debug('Acctd AmountCredit = '||l_acctd_amt_cr);
     END IF;

     if CHECK_PRECISION(l_check_amount_dr) then
     FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     elsif CHECK_PRECISION(l_check_amount_cr) then
     FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     else
     fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
     end if;

     app_exception.raise_exception;

  WHEN amount_mismatch THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_ADJ_BALANCE -AMOUNT_MISMATCH');
        arp_standard.debug('Adjustment_id = '||p_adj_id);
        arp_standard.debug('Amount = '||l_amount);
        arp_standard.debug('Sum of Buckets = '||l_calc_amount);
     END IF;
     fnd_message.set_name('AR','AR_ADJ_AMT_NO_MATCH');
     app_exception.raise_exception;

  WHEN ps_data_corrupted THEN
       app_exception.raise_exception;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_RECP_BALANCE - OTHERS');
     END IF;
     RAISE;

END CHECK_ADJ_BALANCE;

/* =======================================================================
 | PROCEDURE Check_Appln_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for CM Applications
 |      tallies that debits equal credits, if not then it sets a message
 |      on the message stack indicating that items are out of balance.
 |
 | PARAMETERS
 |      p_receivable_application_id    IN      Receivable Application ID
 |      p_request_id                   IN      Request id
 |      p_called_from_api              IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_APPLN_BALANCE(
                  p_receivable_application_id    IN  NUMBER,
                  p_request_id                   IN  NUMBER,
                  p_called_from_api              IN  VARCHAR2 default 'N') IS

l_amt_dr       NUMBER;
l_amt_cr       NUMBER;
l_acctd_amt_dr NUMBER;
l_acctd_amt_cr NUMBER;
 l_corrupt_type             VARCHAR2(20);
 ps_data_corrupted  EXCEPTION;
 l_gl_date_closed   DATE;
 l_actual_date_closed  DATE;
 l_corruption_exists BOOLEAN := FALSE;
 l_corruption_string VARCHAR2(50);
 l_check_amount_dr	NUMBER;
 l_check_amount_cr	NUMBER;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE (+)');
END IF;

IF PG_BAL_CHECK_ENABLED = 'Y' THEN

   IF p_receivable_application_id IS NOT NULL
       AND arp_global.sysparam.accounting_method = 'ACCRUAL' THEN

      select sum(nvl(amount_dr,0)), sum(nvl(amount_cr,0)),
             sum(nvl(acctd_amount_dr,0)), sum(nvl(acctd_amount_cr,0))
      into l_amt_dr, l_amt_cr, l_acctd_amt_dr, l_acctd_amt_cr
      from (select receivable_application_id  src_id,
                   'RA' src_tab
            from  ar_receivable_applications
            where  receivable_application_id = p_receivable_application_id
            and   nvl(postable,'Y') = 'Y'
            and posting_control_id = -3) src,
      ar_distributions ard
      where ard.source_id = src.src_id
      and ard.source_table = src.src_tab;

     --------------------------------------------------------
     --Set the message on the message stack
     --------------------------------------------------------
     IF (l_amt_dr <> l_amt_cr) OR (l_acctd_amt_dr <> l_acctd_amt_cr) THEN
        IF p_called_from_api = 'Y' THEN

           fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
           fnd_msg_pub.Add;

        END IF;
	l_check_amount_dr := l_acctd_amt_dr;
	l_check_amount_cr := l_acctd_amt_cr;
        RAISE out_of_balance;

     END IF;

   END IF; --receivable application id is not null

ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Profile AR: Enable Journal Balance Check is disabled ');
    END IF;
END IF;
arp_standard.debug('Request id  '||p_request_id);
arp_standard.debug('Called from API '||p_called_from_api);

IF ((p_ps_rec.payment_schedule_id is not null or p_ps_rec_pmt.payment_schedule_id is not null)
     AND p_request_id is null
     AND p_called_from_api = 'N'
   ) THEN
      BEGIN

         IF p_ps_rec.payment_schedule_id is not null THEN
                CHECK_PS_DATE(
           p_ps_rec        => p_ps_rec,
           p_corrupt_type   => l_corrupt_type,
           p_gl_date_closed  => l_gl_date_closed,
           p_actual_date_closed      => l_actual_date_closed);
         END IF;

         IF p_ps_rec_pmt.payment_schedule_id is not null THEN
                CHECK_PS_DATE(
           p_ps_rec        => p_ps_rec_pmt,
           p_corrupt_type   => l_corrupt_type,
           p_gl_date_closed  => l_gl_date_closed,
           p_actual_date_closed      => l_actual_date_closed);
         END IF;

           ARP_BALANCE_CHECK.P_ps_rec.payment_schedule_id  := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.customer_trx_id      := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.cash_receipt_id      := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.class                := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.actual_date_closed   := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.status               := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.trx_number           := NULL;
           ARP_BALANCE_CHECK.p_ps_rec.gl_date_closed       := NULL;

           ARP_BALANCE_CHECK.P_ps_rec_pmt.payment_schedule_id  := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.customer_trx_id      := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.cash_receipt_id      := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.class                := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.actual_date_closed   := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.status               := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.trx_number           := NULL;
           ARP_BALANCE_CHECK.P_ps_rec_pmt.gl_date_closed       := NULL;

         IF l_corrupt_type is not null then
           l_corruption_exists :=TRUE;
           RAISE ps_data_corrupted;
         END IF;

      EXCEPTION
          WHEN ps_data_corrupted THEN
          fnd_message.set_name('AR','GENERIC_MESSAGE');

          IF l_corrupt_type = 'ACTUAL_DATE' THEN
                l_corruption_string := 'Actual Date Closed';
          ELSIF l_corrupt_type = 'GL_DATE' THEN
                l_corruption_string := 'GL Date Closed';
          ELSIF l_corrupt_type = 'BOTH_ACT_GL' THEN
                l_corruption_string := 'Actual Date Closed and GL Date Closed';
          END IF;

          fnd_message.set_token ( token => 'GENERIC_TEXT',
                            value => 'The Value Is Incorrect for '||l_corruption_string ||' .Please Contact Oracle Support');
          app_exception.raise_exception;
      END;
   ELSE
     ARP_BALANCE_CHECK.P_reg_cm := 'N';
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE (-)');
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     /* Exception need not be raised as this can happen when the Application
        is non postable */
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE - NO_DATA_FOUND');
     END IF;
  WHEN out_of_balance THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE - OUT_OF_BALANCE');
        arp_standard.debug('Receivable Application_id = '||p_receivable_application_id);
        arp_standard.debug('Amount Debit = '||l_amt_dr);
        arp_standard.debug('Amount Credit = '||l_amt_cr);
        arp_standard.debug('Acctd Amount Debit = '||l_acctd_amt_dr);
        arp_standard.debug('Acctd AmountCredit = '||l_acctd_amt_cr);
     END IF;

     if CHECK_PRECISION(l_check_amount_dr) then
     FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     elsif CHECK_PRECISION(l_check_amount_cr) then
     FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     else
     fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
     end if;

     app_exception.raise_exception;


  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE - OTHERS');
     END IF;
     RAISE;

END CHECK_APPLN_BALANCE;

/* =======================================================================
 | PROCEDURE Check_Appln_Balance
 |
 | DESCRIPTION
 |      This procedure takes sum of debits and credits for Receipt Applications.
 |      tallies that debits equal credits, if not then it sets a message
 |      on the message stack indicating that items are out of balance.
 |
 | PARAMETERS
 |      p_receivable_application_id1   IN      Receivable Application ID
 |      p_receivable_application_id2   IN      Receivable Application ID of the pair
 |      p_request_id                   IN      Request id
 |      p_called_from_api              IN      Y-api call out
 * ======================================================================*/
PROCEDURE CHECK_APPLN_BALANCE(
                  p_receivable_application_id1   IN  NUMBER,
                  p_receivable_application_id2   IN  NUMBER,
                  p_request_id                   IN  NUMBER,
                  p_called_from_api              IN  VARCHAR2 default 'N') IS

l_amt_dr       NUMBER;
l_amt_cr       NUMBER;
l_acctd_amt_dr NUMBER;
l_acctd_amt_cr NUMBER;
l_cc_flag      VARCHAR2(1);
l_check_amount_dr	NUMBER;
l_check_amount_cr	NUMBER;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE (+) -> for Receipt Applications');
END IF;

IF PG_BAL_CHECK_ENABLED = 'Y' THEN

  IF p_receivable_application_id1 IS NOT NULL
        AND p_receivable_application_id2 IS NOT NULL
        AND arp_global.sysparam.accounting_method = 'ACCRUAL' THEN

    select sum(nvl(amount_dr,0)), sum(nvl(amount_cr,0)),
           sum(nvl(acctd_amount_dr,0)), sum(nvl(acctd_amount_cr,0)),
           max(src.cc_flag) cc_flag
    into l_amt_dr, l_amt_cr, l_acctd_amt_dr, l_acctd_amt_cr, l_cc_flag
    from (select receivable_application_id  src_id,
                'RA' src_tab,
                 decode(amount_applied_from,NULL,
                          'N',
                          'Y') cc_flag
         from  ar_receivable_applications
         where ( receivable_application_id = p_receivable_application_id1
                 or  receivable_application_id = p_receivable_application_id2)
         and   nvl(postable,'Y') = 'Y'
         and posting_control_id = -3) src,
   ar_distributions ard
   where ard.source_id = src.src_id
   and ard.source_table = src.src_tab;

   --------------------------------------------------------
   --Set the message on the message stack
   --------------------------------------------------------
   IF (((l_amt_dr <> l_amt_cr) AND (l_cc_flag = 'N'))
       OR (l_acctd_amt_dr <> l_acctd_amt_cr)) THEN
        IF p_called_from_api = 'Y' THEN

         fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
         fnd_msg_pub.Add;

        END IF;
	l_check_amount_dr := l_acctd_amt_dr;
	l_check_amount_cr := l_acctd_amt_cr;
      RAISE out_of_balance;

   END IF;

  END IF; --receivable application ids are not null

ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Profile AR: Enable Journal Balance Check is disabled ');
    END IF;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE (-) -> for Receipt Applications');
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     /* Exception need not be raised as this can happen when the Application
        is non postable */
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE - NO_DATA_FOUND');
     END IF;
  WHEN out_of_balance THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE - OUT_OF_BALANCE');
        arp_standard.debug('Receivable Application_id1 = '||p_receivable_application_id1);
        arp_standard.debug('Receivable Application_id2 = '||p_receivable_application_id2);
        arp_standard.debug('Amount Debit = '||l_amt_dr);
        arp_standard.debug('Amount Credit = '||l_amt_cr);
        arp_standard.debug('Acctd Amount Debit = '||l_acctd_amt_dr);
        arp_standard.debug('Acctd AmountCredit = '||l_acctd_amt_cr);
     END IF;

     if CHECK_PRECISION(l_check_amount_dr) then
     FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     elsif CHECK_PRECISION(l_check_amount_cr) then
     FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );

     else
     fnd_message.set_name('AR','AR_AMOUNTS_NO_MATCH');
     end if;

     app_exception.raise_exception;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_APPLN_BALANCE - OTHERS -> for Receipt Applications');
     END IF;
     RAISE;

END CHECK_APPLN_BALANCE;
/* =======================================================================
 | PROCEDURE Check_Ps_Date
 |
 | DESCRIPTION
 |       This Procedure checks if the gl_date_closed and actual_date_closed
 |       are stamped correctly in ar_payment_schedules when the payment schedule
 |       is closed. It returns the correct values which can can then be sent to the
 |       Fix_Ps_Date procedure to correct the data corruption
 |
 | PARAMETERS
 |      p_ps_id                 IN      Payment Schedule id
 |      p_corrupt_type          OUT     Corruption Type
 |      p_gl_date_closed        OUT     New Value for GL Closed Date
 |      p_actual_date_closed    OUT     New Value for Actual Closed Date
 * ======================================================================*/
PROCEDURE CHECK_PS_DATE(
                  p_ps_rec               IN  ar_payment_schedules%ROWTYPE,
                  p_corrupt_type         OUT NOCOPY VARCHAR2,
                  p_gl_date_closed       OUT NOCOPY DATE,
                  p_actual_date_closed   OUT NOCOPY DATE) IS

  l_max_apply_date   DATE;
  l_max_gl_date   DATE;
BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_PS_DATE (+)');
END IF;





--IF PG_AUTO_CORRECT_ENABLED = 'Y' AND p_ps_rec.status = 'CL' THEN  --checking for the profile option


  IF p_ps_rec.payment_schedule_id is not null THEN
     l_max_apply_date := NULL;
     l_max_gl_date := NULL;

       IF p_ps_rec.class <> 'PMT'  THEN
          SELECT MAX(apply_date)
            INTO l_max_apply_date
           FROM (
           SELECT MAX(apply_date) apply_date
            FROM   ar_receivable_applications ra
            WHERE  status = 'APP'
            AND    ra.payment_schedule_id = p_ps_rec.payment_schedule_id
            UNION ALL
           SELECT MAX(apply_date) apply_date
            FROM   ar_receivable_applications ra
            WHERE  status = 'APP'
            AND    ra.applied_payment_schedule_id = p_ps_rec.payment_schedule_id
            UNION ALL
            SELECT MAX(apply_date) apply_date
            FROM   ar_adjustments adj
            WHERE  status = 'A'
            AND    adj.payment_schedule_id = p_ps_rec.payment_schedule_id
               );
       ELSE
           SELECT MAX(apply_date)
           INTO l_max_apply_date
           FROM   ar_receivable_applications ra
           WHERE  payment_schedule_id  = p_ps_rec.payment_schedule_id;
       END IF;

        IF NVL(l_max_apply_date,p_ps_rec.actual_date_closed) > p_ps_rec.actual_date_closed  THEN
          p_corrupt_type := 'ACTUAL_DATE';

           IF PG_DEBUG in ('Y', 'C') THEN
              IF p_ps_rec.class <> 'PMT' THEN
                arp_standard.debug('Customer_Trx_Id : '||p_ps_rec.customer_trx_id);
              ELSE
                arp_standard.debug('Cash_Receipt_Id : '||p_ps_rec.cash_receipt_id);
              END IF;
                arp_standard.debug('Class :' || p_ps_rec.class);
                arp_standard.debug('Payment_schedule_id :' || p_ps_rec.payment_schedule_id);
                arp_standard.debug('Status : '||p_ps_rec.status);
                arp_standard.debug('Transaction Number : '||p_ps_rec.trx_number);
                arp_standard.debug('Current Value (Actual Date Closed) : '||p_ps_rec.actual_date_closed);
                arp_standard.debug('New Value (Actual Date Closed) : '||l_max_apply_date);
           END IF;
        END IF;

        IF p_ps_rec.class <> 'PMT'  THEN
          SELECT MAX(gl_date)
            INTO l_max_gl_date
           FROM (
           SELECT MAX(gl_date) gl_date
            FROM   ar_receivable_applications ra
            WHERE  status = 'APP'
            AND    ra.payment_schedule_id = p_ps_rec.payment_schedule_id
            UNION ALL
           SELECT MAX(gl_date) gl_date
            FROM   ar_receivable_applications ra
            WHERE  status = 'APP'
            AND    ra.applied_payment_schedule_id = p_ps_rec.payment_schedule_id
            UNION ALL
            SELECT MAX(gl_date) gl_date
            FROM   ar_adjustments adj
            WHERE  status = 'A'
            AND    adj.payment_schedule_id = p_ps_rec.payment_schedule_id
            );
       ELSE
           SELECT MAX(gl_date)
           INTO l_max_gl_date
           FROM   ar_receivable_applications ra
           WHERE  payment_schedule_id  = p_ps_rec.payment_schedule_id;
        END IF;

        IF NVL(l_max_gl_date,p_ps_rec.gl_date_closed) > p_ps_rec.gl_date_closed  THEN
             IF p_corrupt_type =  'ACTUAL_DATE' THEN
                p_corrupt_type := 'BOTH_ACT_GL';
             ELSE
                p_corrupt_type := 'GL_DATE';
             END IF;

           IF PG_DEBUG in ('Y', 'C') THEN
              IF p_ps_rec.class <> 'PMT' THEN
                arp_standard.debug('Customer_Trx_Id : '||p_ps_rec.customer_trx_id);
              ELSE
                arp_standard.debug('Cash_Receipt_Id : '||p_ps_rec.cash_receipt_id);
              END IF;
                arp_standard.debug('Class :' || p_ps_rec.class);
                arp_standard.debug('Payment_schedule_id :' || p_ps_rec.payment_schedule_id);
                arp_standard.debug('Status : '||p_ps_rec.status);
                arp_standard.debug('Transaction Number : '||p_ps_rec.trx_number);
                arp_standard.debug('Current Value (GL Date Closed) : '||p_ps_rec.gl_date_closed);
                arp_standard.debug('New Value (GL Date Closed) : '||l_max_gl_date);
           END IF;
        END IF;

END IF;
--END IF;
p_gl_date_closed := l_max_gl_date;
p_actual_date_closed := l_max_apply_date;

IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug('Corruption Type :'||p_corrupt_type);
   arp_standard.debug('ARP_BALANCE_CHK.CHECK_PS_DATE (-)');
END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.CHECK_PS_DATE - OTHERS');
     END IF;
     RAISE;
END CHECK_PS_DATE;
/* =======================================================================
 | PROCEDURE Fix_Ps_Date
 |
 | DESCRIPTION
 |        This procedure corrects the data for the fields gl_date_closed and actual_date_closed
 |        in ar_payment_schedules. The correct values need to be fetched from the procedure
 |        CHECK_PS_DATE
 |
 |
 | PARAMETERS
 |      p_ps_id                 IN      Payment Schedule id
 |      p_corrupt_type          IN      Corruption Type
 |      p_gl_date_closed        IN      New Value for GL Closed Date
 |      p_actual_date_closed    IN      New Value for Actual Closed Date
 * ======================================================================*/
PROCEDURE FIX_PS_DATE(  p_ps_id                IN  NUMBER,
                  p_corrupt_type               IN VARCHAR2,
                  p_gl_date_closed             IN DATE,
                  p_actual_date_closed         IN DATE) IS
l_ps_rec		ar_payment_schedules%ROWTYPE;
BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.FIX_PS_DATE (+)');
END IF;

--IF PG_AUTO_CORRECT_ENABLED = 'Y' THEN  --checking for the profile option
   arp_ps_pkg.fetch_p(p_ps_id,l_ps_rec);

  IF p_corrupt_type = 'ACTUAL_DATE' THEN
     l_ps_rec.actual_date_closed := p_actual_date_closed;
  ELSE
     IF p_corrupt_type = 'GL_DATE'  THEN
      l_ps_rec.gl_date_closed := p_gl_date_closed;
     ELSE
        IF p_corrupt_type = 'BOTH_ACT_GL'  THEN
         l_ps_rec.actual_date_closed := p_actual_date_closed;
         l_ps_rec.gl_date_closed := p_gl_date_closed;
       END IF;
     END IF;
  END IF;

  l_ps_rec.last_update_date := SYSDATE;
  l_ps_rec.payment_schedule_id := p_ps_id;
  IF p_corrupt_type IS NOT NULL THEN
       arp_ps_pkg.update_p(l_ps_rec);
  END IF;

--END IF;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_BALANCE_CHK.FIX_PS_DATE (-)');
END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BALANCE_CHK.FIX_PS_DATE - OTHERS');
     END IF;
     RAISE;
END FIX_PS_DATE;


FUNCTION Check_Precision(  p_amount	IN NUMBER )
			   RETURN BOOLEAN IS

p_actual_amount		NUMBER;
p_FunctionalCurrency	Varchar2(20);

BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
 arp_standard.debug('ARP_BALANCE_CHK.Check_Precision (+)');
 arp_standard.debug('p_amount ' || p_amount);
END IF;

	SELECT  sob.currency_code
	INTO    p_FunctionalCurrency
	FROM    ar_system_parameters    sp,
		gl_sets_of_books        sob
	WHERE   sob.set_of_books_id = sp.set_of_books_id;

p_actual_amount := ARPCURR.CurrRound(p_amount, p_FunctionalCurrency) ;

IF PG_DEBUG in ('Y', 'C') THEN
 arp_standard.debug('p_actual_amount ' || p_actual_amount);
 arp_standard.debug('p_FunctionalCurrency ' || p_amount);
END IF;

IF p_amount <> p_actual_amount then
 arp_standard.debug('Application amount precision do not match current FND currency precision');
	Return TRUE;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
 arp_standard.debug('Application amount precision matches with FND currency precision');
 arp_standard.debug('ARP_BALANCE_CHK.Check_Precision (-)');
END IF;
	Return FALSE;

EXCEPTION WHEN OTHERS THEN
 arp_standard.debug('ARP_BALANCE_CHK.Check_Precision HANDLED EXCEPTION Return FALSE');
	Return FALSE;
END;


END ARP_BALANCE_CHECK;

/
