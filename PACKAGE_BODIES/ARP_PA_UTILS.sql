--------------------------------------------------------
--  DDL for Package Body ARP_PA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PA_UTILS" AS
/* $Header: ARXPAUTB.pls 120.1.12010000.2 2008/11/24 07:57:56 rsamanta ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC Procedure get_line_applied
 |
 | DESCRIPTION
 |       This function returns the total line amount applied and
 |       corresponding exchange rate gain and/or loss as of given date for the
 |       the given invoice.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |       IN
 |         p_customer_trx_id
 |         p_as_of_date
 |       OUT NOCOPY
 |         x_line_applied           - Line applied
 |         x_line_acctd_applied     - Line applied in Functional Currency
 |         x_xchange_gain           - Exchange Gain
 |         x_xchange_loss           - Exchange Loss
 |         x_return_status          - Standard return status
 |         x_msg_data               - Standard msg data
 |         x_msg_count              - Standard msg count
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 22-Jul-2002           Ramakant Alat  Created
 | 22-Aug-2002           MGOWDA         Added MRC logic
 |
 *=======================================================================*/
 PROCEDURE get_line_applied(
               p_application_id IN
                   ar_receivable_applications.applied_customer_trx_id%TYPE,
               p_customer_trx_id IN
                   ar_receivable_applications.applied_customer_trx_id%TYPE,
               p_as_of_date      IN ar_receivable_applications.apply_date%TYPE,
               p_process_rsob    IN VARCHAR2,
               x_applied_amt_list  OUT NOCOPY ARP_PA_UTILS.r_appl_amt_list,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_msg_count       OUT NOCOPY NUMBER,
               x_msg_data        OUT NOCOPY VARCHAR2
               ) AS
   r_amount_applied         num_arr  := num_arr();
   r_acctd_amount_applied   num_arr := num_arr();
   r_xchange_gain           num_arr := num_arr();
   r_xchange_loss           num_arr := num_arr();
   r_rsob_id           num_arr := num_arr();
   l_psob_id            number;
   l_total number;
   l_amount_applied         number;
   l_acctd_amount_applied   number;
   l_xchange_gain           number;
   l_xchange_loss           number;
   l_rep_no_data            BOOLEAN := FALSE;
   /* Added for FP bug6673099 */
      l_line_adjusted          number;
      l_acctd_line_adjusted    number;
     -- r_mrc_line_adjusted      num_arr := num_arr();


 BEGIN
    l_rep_no_data   := FALSE;
    l_psob_id := arp_global.sysparam.set_of_books_id;

    /*  Get primary data */
    /*** We need the line_applied and corresponding xchange gain or loss ***/

    BEGIN
        SELECT
          NVL(SUM(NVL(line_applied,0) ), 0)
        , NVL(SUM(arpcurr.currround((line_applied * acctd_amount_applied_to)/
                                                            amount_applied )), 0)
        , NVL(SUM(DECODE(SIGN(acctd_amount_applied_from -
                              acctd_amount_applied_to),
                         1,
                         arpcurr.currround(((acctd_amount_applied_from -
                                             acctd_amount_applied_to) *
                                             line_applied)/amount_applied),0)),                          0)
        , NVL(SUM(DECODE(SIGN(acctd_amount_applied_from -
                              acctd_amount_applied_to),
                         -1,
                         arpcurr.currround(((acctd_amount_applied_from -
                                             acctd_amount_applied_to) *  -1 *
                                             line_applied)/amount_applied),0)),
                         0)
      INTO  l_amount_applied
           ,l_acctd_amount_applied
           ,l_xchange_gain
           ,l_xchange_loss
      FROM ar_receivable_applications app,
           ar_cash_receipts cr,
           ra_customer_trx cm,
           ra_customer_trx inv
      WHERE
         applied_customer_trx_id = p_customer_trx_id
    AND applied_customer_trx_id = inv.customer_trx_id
    AND app.status in ('APP')
    AND app.cash_receipt_id = cr.cash_receipt_id (+)
    AND app.customer_trx_id = cm.customer_trx_id (+)
    AND nvl(app.confirmed_flag,'Y') = 'Y'
    AND display = 'Y'
    AND apply_date <= p_as_of_date
    GROUP BY app.set_of_books_id;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_amount_applied := 0;
      l_acctd_amount_applied := 0;
      l_xchange_gain := 0;
      l_xchange_loss := 0;
    WHEN others THEN
      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
            'ar_pa_utils.get_line_applied:' ||SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;

      FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                 p_count  =>  x_msg_count,
                                 p_data   => x_msg_data
                               );
      x_return_status := FND_API.G_RET_STS_ERROR;

    END;
 /* Added for FP bug6673099 */
         BEGIN

            SELECT sum(adj.line_adjusted) ,
                   sum(adj.line_adjusted*ra.exchange_rate)
              INTO l_line_adjusted ,
                   l_acctd_line_adjusted
              FROM ar_adjustments_all adj ,
                   ra_customer_trx_all ra
             WHERE adj.customer_trx_id = ra.customer_trx_id
               AND adj.customer_trx_id = p_customer_trx_id
               AND adj.status='A'
               AND adj.apply_date <= p_as_of_date;

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_line_adjusted :=0;
                 l_acctd_line_adjusted := 0;

             WHEN OTHERS THEN
                 FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                 FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
                        'ar_pa_utils.get_line_applied:' ||SQLERRM(SQLCODE));
                 FND_MSG_PUB.ADD;

                 FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                    p_count  =>  x_msg_count,
                                    p_data   => x_msg_data);
                 x_return_status := FND_API.G_RET_STS_ERROR;

         END;
        /* Added for FP bug6673099 */

    /* Get reporting data */
--{BUG4301323
/*
    IF NVL(p_process_rsob, 'N') = 'Y' AND
       NVL(l_psob_id, -99) <> -99
    THEN
      BEGIN
        SELECT  amr.set_of_books_id
              , NVL(SUM(NVL(app.line_applied,0) ), 0)
              , NVL(SUM(arpcurr.currround((app.line_applied * amr.acctd_amount_applied_to)/
                                                            app.amount_applied )), 0)
              , NVL(SUM(DECODE(SIGN(amr.acctd_amount_applied_from -
                              amr.acctd_amount_applied_to),
                         1,
                         GL_MC_CURRENCY_PKG.CURRROUND((((amr.acctd_amount_applied_from -
                                  amr.acctd_amount_applied_to) *
                                  app.line_applied)
                                  /app.amount_applied),glr.TARGET_CURRENCY_CODE),0)),0)
              , NVL(SUM(DECODE(SIGN(amr.acctd_amount_applied_from -
                              amr.acctd_amount_applied_to), -1,
                         GL_MC_CURRENCY_PKG.CURRROUND((((amr.acctd_amount_applied_from -
                              amr.acctd_amount_applied_to) *  -1 *
                              app.line_applied)/app.amount_applied),glr.TARGET_CURRENCY_CODE),0)),0)
        BULK COLLECT INTO
              r_rsob_id
             ,r_amount_applied
             ,r_acctd_amount_applied
             ,r_xchange_gain
             ,r_xchange_loss
        FROM ar_receivable_applications app,
             ar_mc_receivable_apps amr,
             ar_cash_receipts cr,
             gl_ledger_relationships glr,
             ra_customer_trx cm,
             ra_customer_trx inv
      WHERE applied_customer_trx_id = p_customer_trx_id
        AND applied_customer_trx_id = inv.customer_trx_id
        AND app.status in ('APP')
        AND app.cash_receipt_id = cr.cash_receipt_id (+)
        AND app.customer_trx_id = cm.customer_trx_id (+)
        AND nvl(app.confirmed_flag,'Y') = 'Y'
        AND app.display = 'Y'
        AND apply_date <= p_as_of_date
        AND glr.TARGET_LEDGER_ID = amr.set_of_books_id
        AND glr.SOURCE_LEDGER_ID = l_psob_id
        AND glr.RELATIONSHIP_ENABLED_FLAG = 'Y'
        AND glr.application_id = p_application_id
        AND target_ledger_category_code = 'ALC'
        AND relationship_type_code = 'SUBLEDGER'
        AND app.receivable_application_id = amr.receivable_application_id
      GROUP BY amr.set_of_books_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_rep_no_data := TRUE;
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
              'ar_public_utils.get_amount_applied:'||SQLERRM(SQLCODE));
          FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                 p_count  =>  x_msg_count,
                                 p_data   => x_msg_data
                                              );
          x_return_status := FND_API.G_RET_STS_ERROR;
      END;

      IF l_rep_no_data
      THEN
        BEGIN
          SELECT target_ledger_id
              ,0
              ,0
              ,0
              ,0
          BULK COLLECT INTO
              r_rsob_id
             ,r_amount_applied
             ,r_acctd_amount_applied
             ,r_xchange_gain
             ,r_xchange_loss
         FROM  gl_ledger_relationships glr
         WHERE glr.source_ledger_id = l_psob_id
           AND target_ledger_category_code = 'ALC'
           AND relationship_type_code = 'SUBLEDGER'
           AND glr.RELATIONSHIP_ENABLED_FLAG = 'Y'
           AND glr.application_id = p_application_id;
        EXCEPTION
          WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME ('AR','NO_RSOB_FOUND');
           FND_MESSAGE.SET_TOKEN('PSOB_ID', l_psob_id);
       END;
      END IF;
    END IF;
*/


    /* Store primary values in array of records */

    IF NVL(l_psob_id, -99) <> -99
    THEN
      x_applied_amt_list(l_psob_id).sob_id := l_psob_id;
      x_applied_amt_list(l_psob_id).amount_applied :=  l_amount_applied;
      x_applied_amt_list(l_psob_id).acctd_amount_applied := l_acctd_amount_applied;
      x_applied_amt_list(l_psob_id).exchange_gain := l_xchange_gain;
      x_applied_amt_list(l_psob_id).exchange_loss := l_xchange_loss;
      /* Added for FP bug6673099 */
         x_applied_amt_list(l_psob_id).line_adjusted := l_line_adjusted ;
         x_applied_amt_list(l_psob_id).acctd_line_adjusted := l_acctd_line_adjusted ;
--{BUG4301323
/*
      IF r_amount_applied.count > 0
      THEN
        FOR i IN 1..r_amount_applied.count
        LOOP
          x_applied_amt_list(r_rsob_id(i)).sob_id := r_rsob_id(i);
          x_applied_amt_list(r_rsob_id(i)).amount_applied :=  r_amount_applied(i);
          x_applied_amt_list(r_rsob_id(i)).acctd_amount_applied := r_acctd_amount_applied(i);
          x_applied_amt_list(r_rsob_id(i)).exchange_gain := r_xchange_gain(i);
          x_applied_amt_list(r_rsob_id(i)).exchange_loss := r_xchange_loss(i);
        END LOOP;
      END IF;
*/
    END IF;
 END get_line_applied;
END ARP_PA_UTILS;

/
