--------------------------------------------------------
--  DDL for Package Body ARP_LLCA_ADJUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_LLCA_ADJUST_PKG" AS
/* $Header: ARLLADJB.pls 120.2.12010000.4 2009/03/17 06:53:42 nproddut ship $ */


/*=======================================================================+
 |  Package Globals
 +=======================================================================*/

  PG_DEBUG        varchar2(1);

/* init accounting structure */
PROCEDURE init_ae_struct(
            p_ae_sys_rec IN OUT NOCOPY arp_acct_main.ae_sys_rec_type) IS
BEGIN
  SELECT sob.set_of_books_id,
         sob.chart_of_accounts_id,
         sob.currency_code,
         c.precision,
         c.minimum_accountable_unit,
         sysp.code_combination_id_gain,
         sysp.code_combination_id_loss,
         sysp.code_combination_id_round
  INTO   p_ae_sys_rec.set_of_books_id,
         p_ae_sys_rec.coa_id,
         p_ae_sys_rec.base_currency,
         p_ae_sys_rec.base_precision,
         p_ae_sys_rec.base_min_acc_unit,
         p_ae_sys_rec.gain_cc_id,
         p_ae_sys_rec.loss_cc_id,
         p_ae_sys_rec.round_cc_id
 FROM   ar_system_parameters sysp,
         gl_sets_of_books sob,
         fnd_currencies c
  WHERE  sob.set_of_books_id = sysp.set_of_books_id
  AND    sob.currency_code   = c.currency_code;
END init_ae_struct;

/*=============================================================================
 |  PROCEDURE  LLCA_Adjustments
 |
 |  DESCRIPTION
 |    This procedure will populate the ar_activity_details for a line level
 |    adjustment and then populate the required GT tables for accting calls
 |    if required.
 |
 |  PARAMETERS:
 |         IN :
 |        OUT :
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  23-AUG-2005     Debbie Sue Jancis   Created
 |
 *===========================================================================*/
PROCEDURE LLCA_Adjustments(
              p_customer_trx_line_id        IN  NUMBER,
              p_customer_trx_id             IN  NUMBER,
              p_line_adjusted               IN  NUMBER,
              p_tax_adjusted                IN  NUMBER,
              p_adj_id                      IN  NUMBER,
              p_inv_currency_code           IN  VARCHAR2,
              p_gt_id                       IN OUT NOCOPY NUMBER ) IS

 l_apply_to                NUMBER;
 l_line_rem                NUMBER;
 l_tax_rem                 NUMBER;
 l_rowid                   NUMBER;
 l_gt_id                   NUMBER;
 l_return_status_service   VARCHAR2(4000);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(4000);
 l_msg                     VARCHAR2(4000);

 l_adj_rec                ar_adjustments%ROWTYPE;
 l_trx_rec                ra_customer_trx%ROWTYPE;
 l_ae_sys_rec             arp_acct_main.ae_sys_rec_type;
 l_line_id                NUMBER;

 -- Added for Line Level Adjustment
 l_from_llca_call	 VARCHAR2(1);

BEGIN
  arp_util.debug('ARP_LLCA_ADJUST_PKG.LLCA_Adjustments()+');
  arp_util.debug('line adjusted : ' || to_char(p_line_adjusted));
  arp_util.debug('tax adjusted : ' || to_char(p_tax_adjusted));

  -- At the point this is called, it is assumed that the
  -- adjustment record has been inserted and the payment
  -- schedule of the invoice has been updated.
  -- we now need to create the record in the ar_activity_details
  -- table.

  -- Commented for Line level adjustment, inserting into AD after insert of adjustment
  /*
   Select sum(DECODE( lines.line_type,
                      'TAX',0,
                      'FREIGHT', 0,
                      1) * lines.amount_due_remaining) l_line_rem,
          sum(DECODE (lines.line_type,
                      'TAX', 1, 0) * lines.amount_due_remaining) l_tax_rem,
          MAX(DECODE(lines.line_type, 'LINE',
                     lines.line_number, 0))
      INTO
          l_line_rem,
          l_tax_rem,
          l_apply_to
      FROM ra_customer_trx ct,
           ra_customer_trx_lines lines
     WHERE (lines.customer_Trx_line_id = p_customer_trx_line_id or
            lines.link_to_cust_trx_line_id = p_customer_trx_line_id)
       AND  ct.customer_Trx_id = lines.customer_trx_id
       AND  ct.customer_trx_id = p_customer_trx_id;


   SELECT ar_activity_details_s.nextval
    INTO l_line_id
    FROM dual;

   INSERT INTO AR_ACTIVITY_DETAILS (
        LINE_ID,
        APPLY_TO,
        customer_trx_line_id,
        CASH_RECEIPT_ID,
        GROUP_ID,
        AMOUNT,
        TAX,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        SOURCE_ID,
        SOURCE_TABLE
    )

    VALUES (
        l_line_id,                         -- line_id
        1,                                 -- APPLY_TO
        p_customer_trx_line_id,            -- customer_Trx_line_id
        NULL,                              -- cash_Receipt_id
        NULL,                              -- Group_ID (ll grp adj not implem)
        p_line_adjusted,                   -- Amount
        p_tax_adjusted,                    -- TAX
        NVL(FND_GLOBAL.user_id,-1),        -- Created_by
        SYSDATE,                           -- Creation_date
        decode(FND_GLOBAL.conc_login_id,
               null,FND_GLOBAL.login_id,
               -1, FND_GLOBAL.login_id,
               FND_GLOBAL.conc_login_id),  -- Last_update_login
        SYSDATE,                           -- Last_update_date
        NVL(FND_GLOBAL.user_id,-1),        -- last_updated_by
        0,                                 -- object_version_number
        'ARXTWADJ',                        -- created_by_module
        p_adj_id,                          -- source_id
        'ADJ'                              -- source_table
           );

*/
    /*  if p_Gt_id is 0 then we have to populate the gt table */

    IF ( p_gt_id = 0 ) THEN
       arp_util.debug('LLCA_Adjustments: populating the GT table ');

       /* Get sequence for line level distributions API */
       arp_det_dist_pkg.get_gt_sequence (l_gt_id,
                                         l_return_status_service,
                                         l_msg_count,
                                         l_msg_data);

        p_gt_id := l_gt_id;

        arp_util.debug('l_gt_id = ' || l_gt_id);

      /* Insert lines into GT table for processing- if we have a line amt */
      IF (p_line_adjusted <> 0) THEN
         INSERT INTO AR_LINE_DIST_INTERFACE_GT
         (  GT_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            CUSTOMER_TRX_ID,
            CUSTOMER_TRX_LINE_ID,
            LINE_TYPE,
            LINE_AMOUNT,
            ED_LINE_AMOUNT,
            UNED_LINE_AMOUNT)
         VALUES (
            l_gt_id,                  -- gt_id
            p_adj_id,                 -- source_id
            'ADJ'  ,                  -- source_table
            p_customer_trx_id,        -- customer_trx_id
            p_customer_trx_line_id,   -- customer_Trx_line_id
            'LINE',                   -- line_type
            p_line_adjusted,          -- line_amount
            NULL,                     -- ed_line_amount
            NULL                      -- uned_line_amount
         );
      END IF;

       --  call to prorate the amount over the tax lines.
       --  then insert the records into the GT table.
      IF (p_tax_adjusted <> 0 ) then
         arp_llca_adjust_pkg.prorate_tax_amount(
              p_customer_trx_line_id => p_customer_trx_line_id,
              p_customer_trx_id      => p_customer_trx_id,
              p_tax_adjusted         => p_tax_adjusted,
              p_adjustment_id        => p_adj_id,
              p_gt_id                => p_gt_id,
              p_inv_currency_code    => p_inv_currency_code);
      END IF;

      SELECT *
        INTO l_adj_rec
        FROM ar_adjustments
       WHERE adjustment_id = p_adj_id;

      SELECT *
            INTO   l_trx_rec
            FROM   ra_customer_trx
            WHERE  customer_trx_id = p_customer_trx_id;

      -- Now initialize the acct engine and
      -- call the distribution routine (adjustments)
      init_ae_struct(l_ae_sys_rec);

-- Added parameter for LIne Level Adjustment
   l_from_llca_call	:= 'Y';

      arp_det_dist_pkg.adjustment_with_interface(
              p_customer_trx => l_trx_rec,
              p_adj_rec      => l_adj_rec,
              p_ae_sys_rec   => l_ae_sys_rec,
              p_gt_id        => l_gt_id,
              p_line_flag    => 'INTERFACE',
              p_tax_flag     => 'INTERFACE',
	      x_return_status=> l_return_status_service,
              x_msg_count    => l_msg_count,
              x_msg_data     => l_msg_data,
	      p_llca_from_call => l_from_llca_call,
	      p_customer_trx_line_id => p_customer_trx_line_id);


       IF ( l_return_status_service <> FND_API.G_RET_STS_SUCCESS) THEN
           /* Retrieve and log errors */
           IF (l_msg_count = 1) THEN
              arp_standard.debug(l_msg_data);
              p_gt_id := 0;
           ELSIF (l_msg_count > 1) THEN
              LOOP
                 l_msg := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                                          FND_API.G_FALSE);
                 IF (l_msg IS NULL) THEN
                    EXIT;
                 ELSE
                    arp_standard.debug(l_msg);
                 END IF;
              END LOOP;
              p_gt_id := 0;
           END IF;
         END IF;

    END IF;   -- if gt_id is 0

  arp_util.debug('ARP_LLCA_ADJUST_PKG.LLCA_Adjustments()-');
END LLCA_Adjustments;

/*=============================================================================
 |  PROCEDURE  Prorate_tax_Amount
 |
 |  DESCRIPTION
 |    This procedure will prorate the tax adjusted amount (non-recoverable)
 |    over all tax lines which belong to a LINE
 |
 |  PARAMETERS:
 |         IN :
 |        OUT :
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  24-AUG-2005     Debbie Sue Jancis   Created
 |
 *===========================================================================*/
PROCEDURE Prorate_tax_amount(
              p_customer_trx_line_id        IN  NUMBER,
              p_customer_trx_id             IN  NUMBER,
              p_tax_adjusted                IN  NUMBER,
              p_adjustment_id               IN  NUMBER,
              p_gt_id                       IN  NUMBER,
              p_inv_currency_code           IN  VARCHAR2
                ) IS

    l_sum                NUMBER;
    l_total_tax_lines    NUMBER;
    l_rounding_rule      VARCHAR2(30);
    l_precision          NUMBER;
    l_extended_precision NUMBER;
    l_min_acct_unit      NUMBER;
    l_tax_proration      NUMBER;
    l_total_proration    NUMBER;
    l_row                NUMBER;

    CURSOR tax_lines (p_customer_trx_line_id NUMBER) IS
     SELECT  lines.extended_amount tax_amt,
             customer_trx_line_id
       FROM  ra_customer_trx_lines lines
      WHERE lines.line_type = 'TAX'
        AND lines.link_to_cust_trx_line_id = p_customer_trx_line_id;


BEGIN
  arp_util.debug('ARP_LLCA_ADJUST_PKG.Prorate_tax_amount()+');

  /* get the divisor for the proration equation */
  SELECT
       sum(tl.extended_amount),
       Count(tl.customer_Trx_line_id)
    INTO    l_sum,
            l_total_tax_lines
    FROM    ra_customer_trx_lines tl
   WHERE  tl.customer_trx_id = p_customer_trx_id
     AND  tl.link_to_cust_trx_line_id = p_customer_trx_line_id;

   IF (PG_DEBUG in ('Y','C')) THEN
      arp_standard.debug('sum (divisor) for proration calc = ' || l_sum);
      arp_standard.debug('Number of tax lines = ' || l_total_tax_lines);
   END IF;

  -- get rounding rule
-- Bug 5514473 : Handled no data found so that tax_rounding_rule will be defaulted if there is no data in zx_product_options for the org
-- Bug 5514473 : When application tax options are not defined through tax manager for newly created orgs there will no data in zx_product_options
BEGIN
   SELECT tax_rounding_rule
     INTO l_rounding_rule
     FROM zx_product_options
    WHERE application_id = 222;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_rounding_rule := NULL;
      arp_util.debug('tax_rounding_rule will be defaulted because there is no row in zx_product_options');
      arp_util.debug('Ideal Default Tax Rounding Rule will be : NEAREST');
END;

   -- get currency information
   fnd_currency.Get_info(p_inv_currency_code,
                         l_precision,
                         l_extended_precision,
                         l_min_acct_unit);

   l_tax_proration   := 0;
   l_total_proration := 0;

   FOR c_tl in tax_lines(p_customer_trx_line_id)
   LOOP
        l_row := l_row + 1;

        /* calculate prorated adj for tax lines */
        l_tax_proration :=  arp_etax_util.tax_curr_round(
                                (p_tax_adjusted * (c_tl.tax_amt / l_sum)),
                                p_inv_currency_code,
                                l_precision,
                                l_min_acct_unit,
                                l_rounding_rule);


        l_total_proration := l_total_proration + l_tax_proration;

        /* if l_row is the number of tax lines.. then we have to check
           the rounding before inserting into the gt table.  */
        IF ( l_row = l_total_tax_lines) THEN
           l_tax_proration := p_tax_adjusted - l_total_proration;
        END IF;

        /* now we have to populate the GT table for tax lines */
        INSERT INTO AR_LINE_DIST_INTERFACE_GT
         (  GT_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            CUSTOMER_TRX_ID,
            CUSTOMER_TRX_LINE_ID,
            LINE_TYPE,
            TAX_AMOUNT,
            ED_TAX_AMOUNT,
            UNED_TAX_AMOUNT)
         VALUES (
            p_gt_id,                  -- gt_id
            p_adjustment_id,          -- source_id
            'ADJ'  ,                  -- source_table
            p_customer_trx_id,        -- customer_trx_id
            c_tl.customer_trx_line_id,   -- customer_Trx_line_id
            'TAX',                    -- line_type
            l_tax_proration,          -- tax_amount
            NULL,                     -- ed_tax_amount
            NULL                      -- uned_tax_amount
         );

   END LOOP;

  arp_util.debug('ARP_LLCA_ADJUST_PKG.Prorate_tax_amount()-');
END Prorate_tax_amount;

END ARP_LLCA_ADJUST_PKG;


/
