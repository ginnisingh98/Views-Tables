--------------------------------------------------------
--  DDL for Package Body AP_APPROVAL_MATCHED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APPROVAL_MATCHED_PKG" AS
/* $Header: aprmtchb.pls 120.43.12010000.24 2010/03/26 12:02:33 sbonala ship $ */

/*===========================================================================
 | Private (Non Public) Procedure Specifications
 *==========================================================================*/
-- 7922826 Enc Project
Procedure Print_Debug(
		p_api_name		IN VARCHAR2,
		p_debug_info		IN VARCHAR2);

PROCEDURE Check_Receipt_Exception(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_match_option        IN            VARCHAR2,
              p_rcv_transaction_id  IN            NUMBER,
              p_system_user         IN            NUMBER,
              p_holds               IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Calc_Shipment_Qty_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_qty_billed         IN OUT NOCOPY NUMBER,
        p_calling_sequence   IN            VARCHAR2);

PROCEDURE Calc_Total_Shipment_Qty_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_qty_billed         IN OUT NOCOPY NUMBER,
        p_invoice_type_lookup_code IN   VARCHAR2,
              p_calling_sequence   IN            VARCHAR2);

--Contract Payments: Tolerances Redesign
PROCEDURE Calc_Shipment_Amt_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_amt_billed         IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2);

PROCEDURE Calc_Total_Shipment_Amt_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_amt_billed         IN OUT NOCOPY NUMBER,
              p_invoice_type_lookup_code IN   VARCHAR2,
              p_calling_sequence   IN            VARCHAR2);

PROCEDURE Check_Price(
              p_invoice_id            IN            NUMBER,
              p_line_location_id      IN            NUMBER,
              p_rcv_transaction_id    IN            NUMBER,
              p_match_option          IN            VARCHAR2,
              p_txn_uom               IN            VARCHAR2,
              p_po_uom                IN            VARCHAR2,
              p_item_id               IN            NUMBER,
              p_invoice_currency_code IN            VARCHAR2,
              p_po_unit_price         IN            NUMBER,
              p_price_tolerance       IN            NUMBER,
              p_system_user           IN            NUMBER,
              p_holds                 IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_holds_count           IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence      IN VARCHAR2);

PROCEDURE CHECK_AVERAGE_PRICE(
              p_invoice_id            IN            NUMBER,
              p_line_location_id      IN            NUMBER,
              p_match_option          IN            VARCHAR2,
              p_txn_uom               IN            VARCHAR2,
              p_po_uom                IN            VARCHAR2,
              p_item_id               IN            NUMBER,
              p_price_tolerance       IN            NUMBER ,
              p_po_unit_price         IN            NUMBER ,
              p_invoice_currency_code IN            VARCHAR2,
              p_price_error_exists    IN OUT NOCOPY VARCHAR2,
              p_calling_sequence      IN            VARCHAR2);

PROCEDURE Calc_Ship_Trx_Amt(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_ship_trx_amt       IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2);

PROCEDURE Calc_Ship_Total_Trx_Amt_Var(
              p_invoice_id            IN            NUMBER,
              p_line_location_id      IN            NUMBER,
              p_match_option          IN            VARCHAR2,
              p_po_price              IN            NUMBER,
              p_ship_amount           OUT NOCOPY    NUMBER, -- 3488259 (3110072)
              p_match_basis           IN            VARCHAR2,
              p_ship_trx_amt_var      IN OUT NOCOPY NUMBER,
              p_calling_sequence      IN            VARCHAR2,
              p_org_id                IN            NUMBER); -- 5500101

PROCEDURE Calc_Max_Rate_Var(
              p_invoice_id           IN            NUMBER,
              p_line_location_id     IN            NUMBER,
              p_rcv_transaction_id   IN            NUMBER,
              p_match_option         IN            VARCHAR2,
              p_rate_amt_var         IN OUT NOCOPY NUMBER,
              p_calling_sequence     IN            VARCHAR2);

PROCEDURE Calc_Ship_Trx_Base_Amt(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_inv_curr_code      IN            VARCHAR2,
              p_base_curr_code     IN            VARCHAR2,
              p_ship_base_amt      IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2);

PROCEDURE Calc_Ship_Total_Base_Amt_Var(
              p_invoice_id           IN            NUMBER,
              p_line_location_id     IN            NUMBER,
              p_match_option         IN            VARCHAR2,
              p_po_price             IN            NUMBER,
              p_match_basis          IN            VARCHAR2,
              p_inv_curr_code        IN            VARCHAR2,
              p_base_curr_code       IN            VARCHAR2,
              p_ship_base_amt_var    IN OUT NOCOPY NUMBER,
              p_calling_sequence     IN            VARCHAR2);

--
-- Bug 5077550
-- Added a new procedure to check to see if the pay item is milestone pay
-- item and the unit price on the invoice line should be same as that
-- of the PO shipment. Also the quantity should be an integer and should not
-- have decimals tied to it.
--

FUNCTION Check_Milestone_Price_Qty(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_po_unit_price      IN            NUMBER,
              p_calling_sequence   IN            VARCHAR2) RETURN VARCHAR2;


/*===========================================================================
 |Procedure Definitions
 *==========================================================================*/


/*============================================================================
 |  PUBLIC PROCEDURE  EXEC_MATCHED_VARIANCE_CHECKS
 |
 |  DESCRIPTION:
 |                Procedure to calculate IPV, ERV and QV and compare the
 |                values to the system tolerances and place or release holds
 |                depending on the condition.
 |
 |  PARAMETERS
 |      p_invoice_id - Invoice Id
 |      p_inv_line_number - Invoice Line number
 |      p_base_currency_code - Base Currency Code
 |      p_sys_xrate_gain_ccid - System Exchange Rate Gain Ccid
 |      p_sys_xrate_loss_ccid - System Exchange Rate Loss Ccid
 |      p_ship_amt_tolerance - System Shipment Amount Tolerance
 |      p_rate_amt_tolerance - System Rate Amount Tolerance
 |      p_total_amt_tolerance - System Total Amount Tolerance
 |      p_system_user - Approval Program User Id
 |      p_holds - Holds Array
 |      p_hold_count - Hold Count Array
 |      p_release_count - Release Count Array
 |      p_calling_sequence - Debugging string to indicate path of module calls
 |                           to beprinted out upon error.

   NOTE : EXTRA_PO_ERV Calculation details:
 | --  |-----------------------------------------------------------------+
 | --  | EXAMPLE                                                         |
 | --  |   DOC           QTY   UOM    EXCH.RATE   UNIT_PRICE BASE_AMT    |
 | --  |   po             2    dozen  0.5         10         $10         |
 | --  |   rect           2    dozen  0.55        10         $11         |
 | --  |  inv(to rect)   2    dozen  0.7         10         $14          |
 | --  |  when Accrue on Receipt = 'N' and match to receipt              |
 | --  |  po creation - encumber $10                                     |
 | --  |  rect creation - encumber 0                                     |
 | --  |  inv creation - unencumber PO type - $14- $4 = $10              |
 | --  |                encumber INV type - qty * rxtn_rate * pirce = $11|
 | --  |  po_erv = (inv_rate - po_rate) * qty_invoiced * po_price = $4   |
 | --  |  erv = (inv_rate -rxtn_rate ) * qty_invoiced * rxtn_price = $3  |
 | --  |  unencumbered po amt = po_qty * po_price * po_rate              |
 | --  |                      = inv_rate * qty * unit_price - po_erv     |
 | --  |  when Accrue on Receipt = 'N' and PO encumb.type=INV encumb.type|
 | --  |  actual_encumbrance_amt = po_erv - erv (match for receipt )     |
 | --  |-----------------------------------------------------------------+
 |
 |   PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |  --------------------------------------------------------------------------
 |  --                                                                      --
 |  -- Meaning of dist_enc_flag:                                            --
 |  --   Y: Regular line, has already been successfully encumbered by AP.   --
 |  --   W: Regular line, has been encumbered in advisory mode even though  --
 |  --      insufficient funds existed.                                     --
 |  --   H: Line has not been encumbered yet, since it was put on hold.     --
 |  --   N or Null : Line not yet seen by this code.                        --
 |  --   D: Same as Y for reversal distribution line.                       --
 |  --   X: Same as W for reversal distribution line.                       --
 |  --   P: Same as H for reversal distribution line.                       --
 |  --   R: Same as N for reversal distribution line.                       --
 |  -- 'R' is currently IGNORED by all approval code because it is part     --
 |  -- of a reversal pair.  Since they cancel each other out, it doesn't    --
 |  -- need to be seen by this code.                                        --
 |  --------------------------------------------------------------------------
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Exec_Matched_Variance_Checks(
              p_invoice_id                IN NUMBER,
              p_inv_line_number           IN NUMBER,
              p_base_currency_code        IN VARCHAR2,
              p_inv_currency_code         IN VARCHAR2,
              p_sys_xrate_gain_ccid       IN NUMBER,
              p_sys_xrate_loss_ccid       IN NUMBER,
              p_system_user               IN NUMBER,
              p_holds               IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_hold_count          IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence    IN VARCHAR2) IS

  -- Project LCM 7588322
  l_lcm_enabled                   VARCHAR2(1) := 'N';
  l_rcv_transaction_id            NUMBER;
  l_lcm_account_id                NUMBER;
  l_tax_variance_account_id       NUMBER;
  l_def_charges_account_id        NUMBER;
  l_exchange_variance_account_id  NUMBER;
  l_inv_variance_account_id       NUMBER;
  l_ipv_exsts_flg VARCHAR2(1) := 'N';  --Introduced for bug#9252266



  CURSOR Distribution_Cur IS
    SELECT   D.Invoice_Distribution_Id
            ,D.line_type_lookup_code
            ,D.dist_code_combination_id
            ,D.distribution_line_number
            ,D.related_id
            ,D.reversal_flag
            ,DECODE(l_lcm_enabled,'Y',l_inv_variance_account_id,DECODE(PD.destination_type_code,
                   'EXPENSE', DECODE(PD.accrue_on_receipt_flag,
                                     'Y', PD.code_combination_id,
                                     D.dist_code_combination_id),
                  PD.variance_account_id))      -- l_po_variance_ccid
           ,PD.destination_type_code            -- l_po_destination_type
           ,NVL(PD.accrue_on_receipt_flag,'N')  -- l_accrue_on_receipt_flag
     ,D.matched_uom_lookup_code           -- rtxn_uom
     ,PL.unit_meas_lookup_code    -- po_uom
     ,nvl(PLL.match_option, 'P')    -- match_option
         ,RSL.item_id                         -- rtxn_item_id
     ,nvl(D.quantity_invoiced, 0)          -- qty_invoiced
     ,D.corrected_invoice_dist_id          -- corrected_invoice_dist_id
     ,decode(I.invoice_currency_code,
             p_base_currency_code,1,
             nvl(PD.rate,1))              -- po_rate
           ,nvl(I.exchange_rate, 1)    -- inv_rate
     ,nvl(PLL.price_override,0)          -- po_price
           ,PLL.matching_basis                  -- matching basis./*Amount Based Matching*/
    FROM    ap_invoice_distributions D,
            ap_invoices I,
            po_distributions PD,
      po_line_locations PLL,
      po_lines PL,
      rcv_transactions RTXN,
      rcv_shipment_lines RSL
    WHERE  I.invoice_id = p_invoice_id
    AND    I.invoice_id = D.invoice_id
    AND    D.invoice_line_number = p_inv_line_number
    AND    D.po_distribution_id = PD.po_distribution_id
    AND    PL.po_line_id = PD.po_line_id
    AND    PLL.line_location_id = PD.line_location_id
    AND    NVL(D.match_status_flag,'N') IN ('N', 'S', 'A')
    AND    NVL(D.posted_flag, 'N') IN ('N', 'P')
    AND    NVL(D.encumbered_flag, 'N') not in ('Y','R') --bug6921447
    --Retropricing: The ERV/IPV calculation is only done for
    --RetroItem with match_type 'PO_PRICE_ADJUSTMENT'
    --Exec_Matched_Variance_Checks is not called for lines with
    --match_type 'ADJUSTMENT_CORRECTION'
    AND    D.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'IPV',
                                       'RETROEXPENSE', 'RETROACCRUAL')
    AND    D.rcv_transaction_id = RTXN.transaction_id (+)
    AND    RTXN.shipment_line_id = RSL.shipment_line_id (+)
    ORDER BY D.po_distribution_id, D.distribution_line_number;

    CURSOR Check_Variance_Cur(
               x_invoice_distribution_id IN NUMBER,
               x_variance_type           IN VARCHAR2) IS
    SELECT D.Invoice_Distribution_Id,
           NVL(D.amount, 0),
           NVL(D.base_amount, D.amount)
      FROM ap_invoice_distributions D
     WHERE D.related_id = x_invoice_distribution_id
       AND D.line_type_lookup_code = x_variance_type;


  l_invoice_distribution_id
      ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_reversal_flag
      ap_invoice_distributions.reversal_flag%TYPE;
  l_distribution_line_number
      ap_invoice_distributions.distribution_line_number%TYPE;
  l_dist_code_combination_id
      ap_invoice_distributions.dist_code_combination_id%TYPE;
  l_related_id
      ap_invoice_distributions.related_id%TYPE;
  l_amount
      ap_invoice_distributions.amount%TYPE;
  l_base_amount
      ap_invoice_distributions.base_amount%TYPE;
  l_ipv_distribution_id
      ap_invoice_distributions.invoice_distribution_id%TYPE := -1;
  l_erv_distribution_id
      ap_invoice_distributions.invoice_distribution_id%TYPE := -1;
  l_line_type_lookup_code
      ap_invoice_distributions.line_type_lookup_code%TYPE;

  l_po_variance_ccid        NUMBER;
  l_accrue_on_receipt_flag  VARCHAR2(1);
  l_destination_type        VARCHAR2(25);

  l_ipv                     NUMBER;
  l_bipv                    NUMBER;
  l_erv                     NUMBER;
  l_amount_holder           NUMBER;
  l_erv_ccid                NUMBER(15);
  l_erv_acct_invalid_exists VARCHAR2(1) := 'N';
  l_variance_success        BOOLEAN := FALSE;
  l_po_uom        PO_LINES.UNIT_MEAS_LOOKUP_CODE%TYPE;
  l_rtxn_uom        PO_LINES.UNIT_MEAS_LOOKUP_CODE%TYPE;
  l_match_option      PO_LINE_LOCATIONS.MATCH_OPTION%TYPE;
  l_qty_invoiced      AP_INVOICE_DISTRIBUTIONS.QUANTITY_INVOICED%TYPE;
  l_rtxn_item_id      RCV_SHIPMENT_LINES.ITEM_ID%TYPE;
  l_corrected_invoice_dist_id AP_INVOICE_DISTRIBUTIONS.INVOICE_DISTRIBUTION_ID%TYPE;
  l_uom_conv_rate      NUMBER := NULL;
  l_inv_qty        AP_INVOICE_DISTRIBUTIONS.QUANTITY_INVOICED%TYPE :=0;
  l_inv_rate        AP_INVOICES.EXCHANGE_RATE%TYPE := 0;
  l_po_rate        AP_INVOICES.EXCHANGE_RATE%TYPE := 0;
  l_po_price        PO_LINE_LOCATIONS.PRICE_OVERRIDE%TYPE := 0;
  l_po_erv        NUMBER := 0;
  l_extra_po_erv      AP_INVOICE_DISTRIBUTIONS.EXTRA_PO_ERV%TYPE ;

  l_key_value               NUMBER;
  l_max_dist_line_number AP_INVOICE_DISTRIBUTIONS.DISTRIBUTION_LINE_NUMBER%TYPE;

  l_debug_loc               VARCHAR2(30) := 'Exec_Matched_Variance_Checks';
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(100);
  l_debug_context           VARCHAR2(2000);
  l_match_basis             PO_LINE_LOCATIONS.matching_basis%TYPE; /*Amount Based Matching */

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  IF ( AP_APPROVAL_PKG.g_debug_mode = 'Y' ) THEN
    g_debug_mode := 'Y';
  END IF;

  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    AP_Debug_Pkg.Print(g_debug_mode, 'Invoice id: '|| TO_CHAR(p_invoice_id));
    AP_Debug_Pkg.Print(g_debug_mode, 'Invoice line number: '||
                       TO_CHAR(p_inv_line_number));
    AP_Debug_Pkg.Print(g_debug_mode, 'base currency code: '||
                       p_base_currency_code);
    AP_Debug_Pkg.Print(g_debug_mode, 'invoice currency code: '||
                       p_inv_currency_code);
    AP_Debug_Pkg.Print(g_debug_mode, 'sys gain ccid: '||
                       TO_CHAR(p_sys_xrate_gain_ccid));
    AP_Debug_Pkg.Print(g_debug_mode, 'sys loss ccid: '||
                       TO_CHAR(p_sys_xrate_loss_ccid));
  END IF;


  -- Project LCM 7588322

  BEGIN
   SELECT ail.rcv_transaction_id
	 INTO   l_rcv_transaction_id
	 FROM   ap_invoice_lines ail
	 WHERE  ail.invoice_id  = p_invoice_id
	 AND    ail.line_number = p_inv_line_number;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  END;

  BEGIN
	 SELECT 'Y'
	 INTO   l_lcm_enabled
	 FROM   RCV_TRANSACTIONS
	 WHERE  TRANSACTION_ID = l_rcv_transaction_id
	 AND    LCM_SHIPMENT_LINE_ID IS NOT NULL;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  END;

	 IF(l_lcm_enabled = 'Y') THEN
	   RCV_UTILITIES.Get_RtLcmInfo(
	              p_rcv_transaction_id           => l_rcv_transaction_id,
	              x_lcm_account_id               => l_lcm_account_id,
								x_tax_variance_account_id      => l_tax_variance_account_id,
								x_def_charges_account_id       => l_def_charges_account_id,
								x_exchange_variance_account_id => l_exchange_variance_account_id,
								x_inv_variance_account_id      => l_inv_variance_account_id
								);

     END IF;
	 -- End Project LCM 7588322


	/*------------------------------------------------------------------+
    |  Open Cursor and initialize data for all distribution Line and   |
    |  loop through for calculation                                    |
    +-----------------------------------------------------------------*/


  IF (g_debug_mode = 'Y') THEN
    l_debug_info := 'Open Distribution_Cur';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  OPEN Distribution_Cur;
  LOOP
    FETCH Distribution_Cur
     INTO   l_invoice_distribution_id
           ,l_line_type_lookup_code
           ,l_dist_code_combination_id
           ,l_distribution_line_number
           ,l_related_id
           ,l_reversal_flag
           ,l_po_variance_ccid
           ,l_destination_type
           ,l_accrue_on_receipt_flag
     ,l_rtxn_uom
     ,l_po_uom
     ,l_match_option
     ,l_rtxn_item_id
     ,l_qty_invoiced
     ,l_corrected_invoice_dist_id
     ,l_po_rate
     ,l_inv_rate
     ,l_po_price
           ,l_match_basis;

    EXIT WHEN Distribution_Cur%NOTFOUND;

    IF (l_reversal_flag <> 'Y') THEN

   /*-----------------------------------------------------------------+
    | if distribution is not a reversal (bipv, ipv, and erv are       |
    | negated in reversal lines when the reversals are created )      |
    +-----------------------------------------------------------------*/

      IF (g_debug_mode = 'Y') THEN
        l_debug_info := 'Calculate IPV and ERV';
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

   /*-----------------------------------------------------------------+
    | Step 1 - Open check variance cursor to check if ERV already     |
    |          exists. Otherwise l_erv_distribution_id = -1            |
    +-----------------------------------------------------------------*/
      OPEN Check_Variance_Cur(
               l_invoice_distribution_id,
               'ERV');
      FETCH Check_Variance_Cur
      INTO l_erv_distribution_id,
           l_amount_holder,
           l_erv;
      IF Check_Variance_Cur%NOTFOUND THEN
        l_erv_distribution_id := -1;
        l_erv := 0;
      END IF;
      CLOSE Check_Variance_Cur;

   /*-----------------------------------------------------------------+
    | Step 2 - Open check variance cursor to check if IPV already     |
    |          exists for non-IPV type line. If not exists,           |
    |          l_ipv_distribution_id = -1                             |
    +-----------------------------------------------------------------*/
      IF ( l_line_type_lookup_code <> 'IPV' ) THEN
        OPEN Check_Variance_Cur(
                 l_invoice_distribution_id,
                 'IPV');
        FETCH Check_Variance_Cur
        INTO l_ipv_distribution_id,
             l_ipv,
             l_bipv;
        IF Check_Variance_Cur%NOTFOUND THEN
          l_ipv_distribution_id := -1;
          l_ipv := 0;
          l_bipv := 0;
        END IF;

       --Start of bug#9252266
	IF (Check_Variance_Cur%ROWCOUNT <>0)THEN
          l_ipv_exsts_flg := 'Y';
        ELSE
          l_ipv_exsts_flg := 'N';
        END IF;
       --End bug#9252266

        CLOSE Check_Variance_Cur;
      END IF;

   /*-----------------------------------------------------------------+
    | Step 3 - Calculate Variance                                     |
    +-----------------------------------------------------------------*/

      l_variance_success := AP_INVOICE_DISTRIBUTIONS_PKG.Calculate_Variance(
                                  l_invoice_distribution_id,
                                  NULL,
                                  l_amount,
                                  l_base_amount,
                                  l_ipv,
                                  l_bipv,
                                  l_erv,
                                  l_debug_info,
                                  l_debug_context,
                                  l_curr_calling_sequence);

      IF (g_debug_mode = 'Y') THEN
        l_debug_info := 'After calling Calculate_variance' || l_debug_info;
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_context );
      END IF;

      /*--------------------------------------------------------------+
      | Step 3.1: Calculate extra_po_erv for the ITEM distribution    |
      |            or IPV distribution of a correction distribution.  |
      +--------------------------------------------------------------*/

      --ETAX: Validation.
      --Added the following logic to calculate extra_po_erv along
      --with IPV and ERV and store it in the new column extra_po_erv
      --bugfix:3881673
      IF (l_line_type_lookup_code IN ('ITEM','ACCRUAL') OR
          (l_line_type_lookup_code ='IPV'
            AND l_corrected_invoice_dist_id IS NOT NULL)) THEN
         IF (l_accrue_on_receipt_flag = 'N' and l_match_option = 'R') THEN

            IF (g_debug_mode = 'Y') THEN
         l_debug_info := l_debug_loc ||
                        'receipt match line when accrue on receipt is N' ||
                        'calculate po_erv';
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info);
      END IF;

            -- Amount Based Matching
            IF l_match_basis = 'QUANTITY' THEN

              IF (l_po_uom <> l_rtxn_uom) THEN
          l_uom_conv_rate := po_uom_s.po_uom_convert (
                                l_rtxn_uom,
              l_po_uom,
              l_rtxn_item_id);

                l_inv_qty :=  round(l_qty_invoiced *l_uom_conv_rate, 15);
              ELSE
          l_inv_qty := l_qty_invoiced;
        END IF;

        l_po_erv := AP_UTILITIES_PKG.ap_round_currency(
                     (( l_inv_rate - l_po_rate) * l_inv_qty
               * l_po_price),
            p_base_currency_code);

            ELSE  -- Amount Based Matching

              l_po_erv := AP_UTILITIES_PKG.ap_round_currency(
                           (( l_inv_rate - l_po_rate) * l_amount),
                              p_base_currency_code);

            END IF;  -- End l_matching_basis. /* Amount Based Matching */

         END IF; /*l_accrue_on_receipt_flag = 'N' and l_match_option = 'R'*/

      END IF; /*l_line_type_lookup_code  ='ITEM' OR ...*/

   /*-----------------------------------------------------------------+
    | Step 4 - Process Variance Line                                  |
    +-----------------------------------------------------------------*/

      IF ( l_variance_success ) THEN

   /*--------------------------------------------------------------+
   |  Step 4.1a - Since variance exists, calculate the extra_po_erv|
   ---------------------------------------------------------------*/

  --ETAX: Validation
  IF (l_accrue_on_receipt_flag = 'N' and l_match_option = 'R') THEN
           l_extra_po_erv := l_po_erv - nvl(l_erv,0);
        END IF;

   /*-----------------------------------------------------------------+
    | Step 4.1.a - Variance exists and get variance ccid information  |
    |              call API to get ERV ccid                           |
    |              ipv ccid is either charge acct ccid or po variance |
    |              ccid                                               |
    +-----------------------------------------------------------------*/

        IF (g_debug_mode = 'Y') THEN
          l_debug_info := 'Exec_Matched_Variance_Checks - variance exists ' ||
                          'calling get_erv_ccid ';
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF ( NVL(l_erv,0 ) <> 0 ) THEN

     --Etax : Validation project
     --Removed the logic to flexbuild the erv_ccid when automatic
           --offsets is turned on

     --bugfix:5718702 added the NULL assignment stmt so that the
     --variable doesn't carry over the previous distribution's erv_ccid
     l_erv_ccid := NULL;


			 -- Project LCM 7588322
			 IF (l_lcm_enabled = 'Y') THEN
			   l_erv_ccid := l_exchange_variance_account_id;
			 ELSE
		           AP_FUNDS_CONTROL_PKG.GET_ERV_CCID(
		                p_sys_xrate_gain_ccid,
		                p_sys_xrate_loss_ccid,
		                l_dist_code_combination_id,
		                l_po_variance_ccid,
		                l_destination_type,
		                l_invoice_distribution_id,
		                l_related_id,
		                l_erv,
		                l_erv_ccid,
		                l_curr_calling_sequence);
		     END IF;

        END IF;

   /*-----------------------------------------------------------------+
    | Step 4.1.b - Check if INVALID ERV CCID HOLD needs to be put     |
    +-----------------------------------------------------------------*/

        IF ( (l_erv <> 0) AND (l_erv_ccid = -1)) THEN
          l_erv_acct_invalid_exists := 'Y';
        END IF;

   /*-----------------------------------------------------------------+
    | Step 4.1.c - Process IPV variance line for distribution         |
    +-----------------------------------------------------------------*/

        IF ( l_line_type_lookup_code <> 'IPV' ) THEN

	--Introduced 'OR' condition for bug#9252266
          IF (( l_ipv <> 0 ) OR l_ipv_exsts_flg = 'Y') THEN

	    ------------------------------------------------------------
            -- Case A - There is IPV Variance
            ------------------------------------------------------------
            IF ( l_ipv_distribution_id = -1 ) THEN
              -----------------------------------------------------------
              -- Case A.1 - There is no existing IPV line - insert
              -----------------------------------------------------------
              IF (g_debug_mode = 'Y') THEN
                l_debug_info := 'Non reversal dist line - Insert IPV line';
                AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              l_related_id := l_invoice_distribution_id;

        l_max_dist_line_number := AP_INVOICE_LINES_PKG.get_max_dist_line_num(
                                      p_invoice_id,
                                p_inv_line_number) + 1;

              INSERT INTO ap_invoice_distributions (
                    invoice_id,
                    invoice_line_number,
                    distribution_class,
                    invoice_distribution_id,
                    dist_code_combination_id,
                    last_update_date,
                    last_updated_by,
                    accounting_date,
                    period_name,
                    set_of_books_id,
                    amount,
                    description,
                    type_1099,
                    posted_flag,
                    batch_id,
                    quantity_invoiced,
                    unit_price,
                    match_status_flag,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    assets_addition_flag,
                    assets_tracking_flag,
                    distribution_line_number,
                    line_type_lookup_code,
                    po_distribution_id,
                    base_amount,
                    encumbered_flag,
                    accrual_posted_flag,
                    cash_posted_flag,
                    last_update_login,
                    creation_date,
                    created_by,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute15,
                    final_match_flag,
                    expenditure_item_date,
                    expenditure_organization_id,
                    expenditure_type,
                    project_id,
                    task_id,
        award_id,
        pa_addition_flag, --4591003
                    quantity_variance,
                    base_quantity_variance,
                    packet_id,
                    reference_1,
                    reference_2,
                    program_application_id,
                    program_id,
                    program_update_date,
                    request_id,
                    rcv_transaction_id,
                    dist_match_type,
                    global_attribute_category,
                    global_attribute1,
                    global_attribute2,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    global_attribute10,
                    global_attribute11,
                    global_attribute12,
                    global_attribute13,
                    global_attribute14,
                    global_attribute15,
                    global_attribute16,
                    global_attribute17,
                    global_attribute18,
                    global_attribute19,
                    global_attribute20,
                    org_id,
                    related_id,
                    asset_book_type_code,
                    asset_category_id,
                    accounting_event_id,
                    cancellation_flag ,
              --Freight and Special Charges
        rcv_charge_addition_flag,
                    awt_group_id,  -- bug6843734
					pay_awt_group_id) -- bug8222382
              (SELECT invoice_id,
                    invoice_line_number,
                    distribution_class,
                    ap_invoice_distributions_s.NEXTVAL, -- distribution_id
                    l_Po_variance_ccid, -- dist_code_combination_id
                    SYSDATE, -- last_update_date
                    p_system_user, -- last_updated_by
                    accounting_date, -- accounting_date
                    period_name,  -- period_name
                    Set_Of_Books_Id, -- set_of_book_id
                    l_ipv,  -- Amount
                    Description,  -- description
                    Type_1099, -- type_1099
                    'N',       -- posted_flag
                    batch_id,
                    NULL, -- quantity_invoiced
                    NULL, -- unit_price,
                    'N',  -- match_status_flag
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    'U', -- assets_addition_flag
                    assets_tracking_flag,
                    l_max_dist_line_number,  --distribution_line_number,
                    'IPV', --line_type_lookup_code,
                    po_distribution_id,
                    l_bipv, --base_amount,
                    'N', -- encumbered_flag
                    'N', -- accrual_posted_flag
                    'N', -- cash_posted_flag
                    fnd_global.login_id, -- last_update_login
                    SYSDATE, --Creation_Date,
                    FND_GLOBAL.user_id, --Created_By,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute15,
                    final_match_flag,
                    expenditure_item_date,
                    expenditure_organization_id,
                    expenditure_type,
                    project_id,
                    task_id,
                    award_id,
		    decode(project_id,NULL,'E','N'), --Modified for bug#9504423 pa_addition_flag
	              -- pa_addition_flag, --4591003
                    NULL, -- quantity_variance,
                    NULL, -- base_quantity_variance,
                    NULL, -- packet_id
                    reference_1,
                    reference_2,
                    FND_GLOBAL.prog_appl_id, -- program_application_id
                    FND_GLOBAL.conc_program_id, -- program_id
                    SYSDATE, -- program_update_date
                    FND_GLOBAL.conc_request_id, --request_id
                    rcv_transaction_id,
                    dist_match_type,
                    global_attribute_category,
                    global_attribute1,
                    global_attribute2,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    global_attribute10,
                    global_attribute11,
                    global_attribute12,
                    global_attribute13,
                    global_attribute14,
                    global_attribute15,
                    global_attribute16,
                    global_attribute17,
                    global_attribute18,
                    global_attribute19,
                    global_attribute20,
                    org_id,
                    l_related_id, --related_id,
                    asset_book_type_code,
                    asset_category_id,
                    NULL,        -- accounting_event_id
                    cancellation_flag ,
        'N',   --rcv_charge_addition_flag
                    awt_group_id,  -- bug6843734
					pay_awt_group_id -- bug8222382
                 FROM ap_invoice_distributions
                WHERE invoice_distribution_id = l_invoice_distribution_id );


            ELSE
              ------------------------------------------------------------
              -- Case A.2 - There is an existing IPV line - update
              ------------------------------------------------------------
              IF (g_debug_mode = 'Y') THEN
                l_debug_info := 'Non reversal line - UPDATE exist ipv line';
                AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              -----------------------------------------------------------
              -- Update the existing IPV line for newly calculated IPV
              -- Although IPV is not going to change, bipv might be
              -- changed because of exchange rate changes
              ------------------------------------------------------------

              UPDATE ap_invoice_distributions
                 SET base_amount = l_bipv,
		     amount      = l_ipv,  --Introduced for bug# 9252266
                     last_updated_by = p_system_user,
                     last_update_login = fnd_global.login_id
               WHERE invoice_distribution_id = l_ipv_distribution_id;

            END IF; -- end of check l_ipv_distribution_id = -1 for case A
          END IF; -- end of check l_ipv <> 0
        END IF; -- end of check l_line_type_lookup_code <> 'IPV'

   /*-----------------------------------------------------------------+
    | Step 4.1.d - Process ERV variance line for distribution         |
    +-----------------------------------------------------------------*/

        IF ( l_erv <> 0 ) THEN
          -----------------------------------------------------------
          -- Case A - there is ERV in this round calculation
          -----------------------------------------------------------

          IF ( l_erv_distribution_id = -1 ) THEN
            -----------------------------------------------------------
            -- No existing ERV line - insert
            -----------------------------------------------------------

            IF (g_debug_mode = 'Y') THEN
              l_debug_info := 'Non reversal dist line - Insert ERV line';
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            l_related_id := l_invoice_distribution_id;

      l_max_dist_line_number := AP_INVOICE_LINES_PKG.get_max_dist_line_num(
                                                              p_invoice_id,
                    p_inv_line_number) + 1;

            INSERT INTO ap_invoice_distributions (
                    invoice_id,
                    invoice_line_number,
                    distribution_class,
                    invoice_distribution_id,
                    dist_code_combination_id,
                    last_update_date,
                    last_updated_by,
                    accounting_date,
                    period_name,
                    set_of_books_id,
                    amount,
                    description,
                    type_1099,
                    posted_flag,
                    batch_id,
                    quantity_invoiced,
                    unit_price,
                    match_status_flag,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    assets_addition_flag,
                    assets_tracking_flag,
                    distribution_line_number,
                    line_type_lookup_code,
                    po_distribution_id,
                    base_amount,
                    encumbered_flag,
                    accrual_posted_flag,
                    cash_posted_flag,
                    last_update_login,
                    creation_date,
                    created_by,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute15,
                    final_match_flag,
                    expenditure_item_date,
                    expenditure_organization_id,
                    expenditure_type,
                    project_id,
                    task_id,
        award_id,
        pa_addition_flag,
                    quantity_variance,
                    base_quantity_variance,
                    packet_id,
                    reference_1,
                    reference_2,
                    program_application_id,
                    program_id,
                    program_update_date,
                    request_id,
                    rcv_transaction_id,
                    dist_match_type,
                    global_attribute_category,
                    global_attribute1,
                    global_attribute2,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    global_attribute10,
                    global_attribute11,
                    global_attribute12,
                    global_attribute13,
                    global_attribute14,
                    global_attribute15,
                    global_attribute16,
                    global_attribute17,
                    global_attribute18,
                    global_attribute19,
                    global_attribute20,
                    org_id,
                    related_id,
                    asset_book_type_code,
                    asset_category_id,
                    accounting_event_id,
                    cancellation_flag,
        --Freight and Special Charges
        rcv_charge_addition_flag,
                    awt_group_id,  -- bug6843734
					pay_awt_group_id) -- bug8222382
            (SELECT  Invoice_Id, -- invoice_id
                     Invoice_Line_Number, -- invoice_line_number
                     distribution_class,
                     ap_invoice_distributions_s.NEXTVAL, -- distribution_id
                     l_erv_ccid, -- dist_code_combination_id
                     SYSDATE, -- last_update_date
                     p_system_user, -- last_updated_by
                     accounting_date, -- accounting_date
                     period_name,  -- period_name
                     Set_Of_Books_Id, -- set_of_book_id
                     0, --amount
                     description, -- description
                     type_1099, -- type_1099
                     'N',  -- posted_flag
                     batch_id, -- batch_id
                     NULL, -- quantity_invoiced,
                     NULL, -- unit_price,
                     'N',  -- match_status_flag
                     attribute_category,
                     attribute1,
                     attribute2,
                     attribute3,
                     attribute4,
                     attribute5,
                     'U', -- assets_addition_flag
                     assets_tracking_flag,
                     l_max_dist_line_number, --distribution_line_number,
                     'ERV', -- line_type_lookup_code,
                     po_distribution_id,
                     l_erv, -- base_amount,
                     'N', -- encumbered_flag
                     'N', -- accrual_posted_flag
                     'N', -- cash_posted_flag
                     fnd_global.login_id, --last_update_login,
                     SYSDATE,  --creation_date,
                     p_system_user,  --created_by,
                     attribute11,
                     attribute12,
                     attribute13,
                     attribute14,
                     attribute6,
                     attribute7,
                     attribute8,
                     attribute9,
                     attribute10,
                     attribute15,
                     final_match_flag,
                     expenditure_item_date,
                     expenditure_organization_id,
                     expenditure_type,
                     project_id,
                     task_id,
                     award_id,
		     decode(project_id,NULL,'E','N'), --Modified for bug#9504423 pa_addition_flag
	              -- pa_addition_flag,
                     NULL, --quantity_variance,
                     NULL, --base_quantity_variance,
                     NULL, -- packet_id
                     reference_1,
                     reference_2,
                     FND_GLOBAL.prog_appl_id, -- program_application_id
                     FND_GLOBAL.conc_program_id, -- program_id
                     SYSDATE, -- program_update_date
                     FND_GLOBAL.conc_request_id, --request_id
                     rcv_transaction_id,
                     dist_match_type,
                     global_attribute_category,
                     global_attribute1,
                     global_attribute2,
                     global_attribute3,
                     global_attribute4,
                     global_attribute5,
                     global_attribute6,
                     global_attribute7,
                     global_attribute8,
                     global_attribute9,
                     global_attribute10,
                     global_attribute11,
                     global_attribute12,
                     global_attribute13,
                     global_attribute14,
                     global_attribute15,
                     global_attribute16,
                     global_attribute17,
                     global_attribute18,
                     global_attribute19,
                     global_attribute20,
                     org_id,
                     l_related_id, --related_id
                     asset_book_type_code,
                     asset_category_id,
                     NULL,        -- accounting_event_id
                     cancellation_flag ,
         'N',         -- rcv_charge_addition_flag
                     awt_group_id,  -- bug6843734
					pay_awt_group_id -- bug8222382
                FROM ap_invoice_distributions
               WHERE invoice_distribution_id = l_invoice_distribution_id );

          ELSE
            -----------------------------------------------------------
            -- Existing ERV line - Update
            -----------------------------------------------------------

            IF (g_debug_mode = 'Y') THEN
              l_debug_info := 'Non reversal dist line-process exist ERV line';
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            -------------------------------------------------------------
            -- UPDATE the existing ERV line for newly calculated ERV
            -- because of exchange rate changes
            -------------------------------------------------------------
            BEGIN
              UPDATE ap_invoice_distributions
                 SET base_amount = l_erv,
                     last_updated_by = p_system_user,
                     last_update_login = fnd_global.login_id
               WHERE invoice_distribution_id = l_erv_distribution_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;
          END IF; -- end of check l_erv_distribution_id = -1 for case A

        ELSE

          -----------------------------------------------------------
          -- Case B - l_erv = 0 No ERV in this round calculation
          -----------------------------------------------------------
          IF ( l_erv_distribution_id <> -1 ) THEN
            -----------------------------------------------------------
            -- Existing ERV line - Delete
            -----------------------------------------------------------
            BEGIN
              DELETE ap_invoice_distributions
              WHERE invoice_distribution_id = l_erv_distribution_id;
            END;

          END IF; -- end of check l_erv_distribution_id <> -1 for Case B

        END IF; -- end of check l_erv <> 0

   /*-----------------------------------------------------------------+
    | Step 4.1.e - Update the Parent line when variance exists        |
    |              if variance exists, related id of parent is always |
    |              populated otherwise clear it                       |
    +-----------------------------------------------------------------*/

  IF (l_extra_po_erv = 0) THEN
    l_extra_po_erv := NULL;
  END IF;

        IF ( l_erv <> 0 OR l_ipv <> 0 ) THEN
          ---------------------------------------------------------------
          -- Update the parent line with related id and reduced base amt
          ---------------------------------------------------------------

    l_debug_info := 'Updating the amounts on ap_invoice_distributions';
          BEGIN
            UPDATE ap_invoice_distributions AID
               SET amount = l_amount,                   -- modified entered amt
                   base_amount = l_base_amount,         -- modified base amt
                   related_id = l_invoice_distribution_id,
       extra_po_erv = l_extra_po_erv,
                   last_updated_by = p_system_user,
                   last_update_login = fnd_global.login_id
            WHERE  invoice_id = p_invoice_id
              AND  invoice_line_number = p_inv_line_number
              AND  distribution_line_number = l_distribution_line_number;
          END;

        ELSE
          ---------------------------------------------------------------
          -- Clear the parent line with related id
          ---------------------------------------------------------------
          BEGIN

      l_debug_info := 'Updating the amounts and related_id on ap_invoice_distributions'||l_invoice_distribution_id;
            UPDATE ap_invoice_distributions AID
               SET amount = l_amount,
                   base_amount = l_base_amount,
                   related_id = NULL,
       extra_po_erv = l_extra_po_erv,
                   last_updated_by = p_system_user,
                   last_update_login = fnd_global.login_id
             WHERE invoice_id = p_invoice_id
               AND invoice_line_number = p_inv_line_number
               AND distribution_line_number = l_distribution_line_number;
          END;

        END IF; -- end of check l_erv <> 0 or l_ipv <> 0

      ELSE
   /*-----------------------------------------------------------------+
    |  Error occured during Variance Calculation                      |
    +-----------------------------------------------------------------*/
        APP_EXCEPTION.RAISE_EXCEPTION;

      END IF; -- end of l_variance_success check

   /*-----------------------------------------------------------------+
    |  Step 6 - Re-initialize the variable value for next interation  |
    |           of the loop                                           |
    +-----------------------------------------------------------------*/

      l_erv_distribution_id := -1;
      l_ipv_distribution_id := -1;

    END IF;  -- end of check l_reversal_flag

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Inside the Distribution Cursor - finish one interate';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

  END LOOP;
  CLOSE Distribution_Cur;

   /*-----------------------------------------------------------------+
    |  Process ERV ACCT INVALID Hold                                  |
    +-----------------------------------------------------------------*/

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Process ERV ACCT INVALID hold for the invoice';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

     /* Bug 5230770. We should not process any invalid acct holds since it
       does not make any sense with SLA
    AP_APPROVAL_PKG.Process_Inv_Hold_Status(
            p_invoice_id,
            NULL,
            NULL,
            'ERV ACCT INVALID',
            l_erv_acct_invalid_exists,
            NULL,
            p_system_user,
            p_holds,
            p_hold_count,
            p_release_count,
            l_curr_calling_sequence);
     */

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Sys Xrate Gain Ccid = '|| to_char(p_sys_xrate_gain_ccid)
              ||', Sys Xrate Loss Ccid = '|| to_char(p_sys_xrate_loss_ccid));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( Distribution_Cur%ISOPEN ) THEN
      CLOSE Distribution_Cur;
    END IF;

    IF ( Check_Variance_Cur%ISOPEN ) THEN
      CLOSE Check_Variance_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END Exec_Matched_Variance_Checks;

/*============================================================================
 |  PUBLIC PROCEDURE  EXEC_QTY_VARIANCE_CHECK
 |
 |  DESCRIPTION:
 |                Procedure to calculate quantity variance for a paticular
 |                invoice. No hold or release will be put.
 |
 |  PARAMETERS
 |      p_invoice_id - Invoice Id
 |      p_base_currency_code - Base Currency Code
 |      p_inv_currency_code - Invoice currency code
 |      p_system_user - system user Id for invoice validation
 |      p_calling_sequence - Debugging string to indicate path of module calls
 |                           to beprinted out upon error.
 |
 |  PROGRAM FLOW: Loop through all the distributions and calculated Quantity
 |                Variance for each different po distribtutions. Update the
 |                corresponding distribution with line number and distribution
 |                line number combined.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Exec_Qty_Variance_Check(
              p_invoice_id                IN NUMBER,
              p_base_currency_code        IN VARCHAR2,
              p_inv_currency_code         IN VARCHAR2,
              p_system_user               IN NUMBER,
              p_calling_sequence          IN VARCHAR2) IS

    CURSOR Distribution_Cur IS
    SELECT   D.Invoice_Distribution_Id
            ,D.po_distribution_id
            ,D.invoice_line_number
            ,D.distribution_line_number
            ,NVL(PD.accrue_on_receipt_flag,'N')  -- l_accrue_on_receipt_flag
            ,nvl(PD.quantity_ordered,0)
                 - nvl(PD.quantity_cancelled,0)  -- l_po_qty
            ,nvl(PLL.price_override, 0)          -- l_po_price
            ,RSL.item_id                         -- l_rtxn_item_id
            ,PL.unit_meas_lookup_code            -- l_po_uom
            ,PLL.match_option                    -- l_match_option
    FROM    ap_invoice_distributions D,
            po_distributions_ap_v PD,
            rcv_transactions RTXN,
            rcv_shipment_lines RSL,
            po_lines PL,
            po_line_locations PLL
    WHERE  D.invoice_id = p_invoice_id
    AND    D.po_distribution_id = PD.po_distribution_id
    AND    NVL(D.match_status_flag, 'N') IN ('N', 'S', 'A')
    AND    NVL(D.posted_flag, 'N') IN ('N', 'P')
    AND    NVL(D.encumbered_flag, 'N') not in ('Y','R') --bug6921447
    AND    D.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
    AND    PD.line_location_id = PLL.line_location_id
    AND    PL.po_header_id = PD.po_header_id
    AND    PLL.matching_basis = 'QUANTITY'
    AND    PL.po_line_id = PD.po_line_id
    AND    D.rcv_transaction_id = RTXN.transaction_id(+)
    AND    RTXN.shipment_line_id = RSL.shipment_line_id(+)
    ORDER BY D.po_distribution_id, D.invoice_line_number, D.distribution_line_number;


  l_invoice_distribution_id
      ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_distribution_line_number
      ap_invoice_distributions.distribution_line_number%TYPE;
  l_invoice_line_number
      ap_invoice_distributions.invoice_line_number%TYPE;

  l_prev_po_dist_id         NUMBER(15)    := -1;
  l_po_dist_id              NUMBER(15);
  l_po_qty                  NUMBER;
  l_po_price                NUMBER;
  l_accrue_on_receipt_flag  VARCHAR2(1);
  l_po_UOM                  VARCHAR2(30);
  l_match_option            VARCHAR2(25);
  l_rtxn_item_id            NUMBER;

  l_qv                      NUMbER;
  l_bqv                     NUMBER;
  l_update_line_num         NUMBER;
  l_update_dist_num         NUMBER;
  l_po_dist_qv              NUMBER;
  l_po_dist_bqv             NUMBER;

  -- TQV
  l_inv_dist_id_upd  NUMBER;
  l_qv_upd    NUMBER;
  l_amount_upd    NUMBER;
  l_base_qv_upd    NUMBER;
  l_base_amount_upd  NUMBER;
  l_qv_ratio    NUMBER;
  l_base_qv_ratio  NUMBER;

  l_debug_loc               VARCHAR2(30) := 'Exec_Qty_Variance_Check';
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(100);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  IF ( AP_APPROVAL_PKG.g_debug_mode = 'Y' ) THEN
    g_debug_mode := 'Y';
  END IF;

  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    AP_Debug_Pkg.Print(g_debug_mode, 'Invoice id: '|| TO_CHAR(p_invoice_id));
    AP_Debug_Pkg.Print(g_debug_mode, 'base currency code: '||
                       p_base_currency_code);
    AP_Debug_Pkg.Print(g_debug_mode, 'invoice currency code: '||
                       p_inv_currency_code);
  END IF;

   /*-----------------------------------------------------------------+
    |  Step 1 - Open Cursor and initialize data for all distribution   |
    |           Line and loop through for calculation                  |
    +-----------------------------------------------------------------*/

  IF (g_debug_mode = 'Y') THEN
    l_debug_info := 'Open Distribution_Cur';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  OPEN Distribution_Cur;
  LOOP
    FETCH Distribution_Cur
     INTO   l_invoice_distribution_id
           ,l_po_dist_id
           ,l_invoice_line_number
           ,l_distribution_line_number
           ,l_accrue_on_receipt_flag
           ,l_po_qty
           ,l_po_price
           ,l_rtxn_item_id
           ,l_po_uom
           ,l_match_option;

    EXIT WHEN Distribution_Cur%NOTFOUND;

    IF ( l_accrue_on_receipt_flag = 'N' and
         l_po_dist_id <> l_prev_po_dist_id ) THEN

   /*-----------------------------------------------------------------+
    | Calculate the Quantity Variance                                 |
    +-----------------------------------------------------------------*/

      IF (g_debug_mode = 'Y') THEN
         l_debug_info := 'Exec_Qty_Variance_Check- call Calculate_QV';
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      AP_FUNDS_CONTROL_PKG.Calc_QV(
              p_invoice_id,
              l_po_dist_id,
              p_inv_currency_code,
              p_base_currency_code,
              l_po_price,
              l_po_qty,
              l_match_option,
              l_po_uom,
              l_rtxn_item_id,
              l_po_dist_qv,
              l_po_dist_bqv,
              l_update_line_num,
              l_update_dist_num,
              l_curr_calling_sequence);
    END IF;

    l_prev_po_dist_id := l_po_dist_id;

    /*-----------------------------------------------------------------+
    | Quantity variance amount is set for line that we want to update  |
    | only                                                             |
    +-----------------------------------------------------------------*/

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Set inv dist qv if right dist_line_num to be updated ';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (l_distribution_line_number = l_update_dist_num AND
        l_invoice_line_number = l_update_line_num ) THEN
      l_qv  := l_po_dist_qv;
      l_bqv := l_po_dist_bqv;
    ELSE
      l_qv  := 0;
      l_bqv := 0;
    END IF;

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Exec_Qty_Variance_Checks-update line with dist_line_num'
                       || '=' || to_char(l_distribution_line_number)
                       || 'line_number' || to_char(l_invoice_line_number);
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    UPDATE ap_invoice_distributions
      SET    quantity_variance = decode(nvl(quantity_variance,0)+l_qv,0,
                                        NULL,nvl(quantity_variance,0)+l_qv),
             base_quantity_variance = decode(nvl(base_quantity_variance,0)
                                             +l_bqv, 0, NULL,
                                             nvl(base_quantity_variance,0)
                                             +l_bqv),
             last_updated_by = p_system_user,
             last_update_login = fnd_global.login_id
      WHERE  invoice_id = p_invoice_id
      AND    invoice_line_number = l_invoice_line_number
      AND    distribution_line_number = l_distribution_line_number
    RETURNING invoice_distribution_id, quantity_variance, amount, base_quantity_variance, base_amount
         INTO l_inv_dist_id_upd, l_qv_upd, l_amount_upd, l_base_qv_upd, l_base_amount_upd;

  IF nvl(l_amount_upd,0) <> 0 and nvl(l_base_amount_upd,0) <> 0 then --bug 7533602

    l_qv_ratio      := l_qv_upd/l_amount_upd;
    l_base_qv_ratio := l_base_qv_upd/l_base_amount_upd;

    UPDATE  ap_invoice_distributions_all aid
       SET  quantity_variance      = ap_utilities_pkg.ap_round_currency
          (aid.amount * l_qv_ratio, p_inv_currency_code)
           ,base_quantity_variance = ap_utilities_pkg.ap_round_currency
          (aid.base_amount * l_base_qv_ratio, p_base_currency_code)
     WHERE  invoice_id       = p_invoice_id
       AND  charge_applicable_to_dist_id = l_inv_dist_id_upd
       AND  line_type_lookup_code   IN ('NONREC_TAX', 'TRV', 'TIPV');

   END IF; --bug 7533602

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Exec_Qty_Variance_Checks-finish update the distribution'
                       || 'for each distribution line';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

  END LOOP;
  CLOSE Distribution_Cur;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id) );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( Distribution_Cur%ISOPEN ) THEN
      CLOSE Distribution_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Exec_Qty_Variance_Check;


/*============================================================================
 |  PUBLIC PROCEDURE  EXEC_AMT_VARIANCE_CHECK
 |
 |  DESCRIPTION:
 |                Procedure to calculate amount variance for a paticular
 |                invoice. No hold or release will be put. This procedure
 |                is related to new amount based matching
 |
 |  PARAMETERS
 |      p_invoice_id - Invoice Id
 |      p_base_currency_code - Base Currency Code
 |      p_inv_currency_code - Invoice currency code
 |      p_system_user - system user Id for invoice validation
 |      p_calling_sequence - Debugging string to indicate path of module calls
 |                           to beprinted out upon error.
 |
 |  PROGRAM FLOW: Loop through all the distributions and calculated Amount
 |                Variance for each different po distribtutions. Update the
 |                corresponding distribution with line number and distribution
 |                line number combined.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  August, 2004 bghose             Created
 |
 *==========================================================================*/

PROCEDURE Exec_Amt_Variance_Check(
              p_invoice_id                IN NUMBER,
              p_base_currency_code        IN VARCHAR2,
              p_inv_currency_code         IN VARCHAR2,
              p_system_user               IN NUMBER,
              p_calling_sequence          IN VARCHAR2) IS

    CURSOR Distribution_Cur IS
    SELECT   D.Invoice_Distribution_Id
            ,D.po_distribution_id
            ,D.invoice_line_number
            ,D.distribution_line_number
            ,NVL(PD.accrue_on_receipt_flag,'N')  -- l_accrue_on_receipt_flag
            ,nvl(PD.amount_ordered,0)
                 - nvl(PD.amount_cancelled,0)    -- l_po_amt
            ,PLL.match_option                    -- l_match_option
    FROM    ap_invoice_distributions D,
            po_distributions_ap_v PD,
            rcv_transactions RTXN,
            rcv_shipment_lines RSL,
            po_lines PL,
            po_line_locations PLL
    WHERE  D.invoice_id = p_invoice_id
    AND    D.po_distribution_id = PD.po_distribution_id
    AND    NVL(D.match_status_flag, 'N') IN ('N', 'S', 'A')
    AND    NVL(D.posted_flag, 'N')       IN ('N', 'P')
    AND    NVL(D.encumbered_flag, 'N')  not in ('Y','R') --bug6921447
    AND    D.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
    AND    PD.line_location_id = PLL.line_location_id
    AND    PL.po_header_id = PD.po_header_id
    AND    PL.po_line_id = PD.po_line_id
    AND    PLL.matching_basis = 'AMOUNT'
    AND    D.rcv_transaction_id = RTXN.transaction_id(+)
    AND    RTXN.shipment_line_id = RSL.shipment_line_id(+)
    ORDER BY D.po_distribution_id, D.invoice_line_number, D.distribution_line_number;

  l_invoice_distribution_id
      ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_distribution_line_number
      ap_invoice_distributions.distribution_line_number%TYPE;
  l_invoice_line_number
      ap_invoice_distributions.invoice_line_number%TYPE;

  l_prev_po_dist_id         NUMBER(15)    := -1;
  l_po_dist_id              NUMBER(15);
  l_po_amt                  NUMBER;
  l_accrue_on_receipt_flag  VARCHAR2(1);
  l_match_option            VARCHAR2(25);
  l_rtxn_item_id            NUMBER;

  l_av                      NUMBER;
  l_bav                     NUMBER;
  l_update_line_num         NUMBER;
  l_update_dist_num         NUMBER;
  l_po_dist_av              NUMBER;
  l_po_dist_bav             NUMBER;
  l_key_value
      AP_INVOICE_DISTRIBUTIONS.invoice_distribution_id%TYPE;

  -- TAV
  l_inv_dist_id_upd     NUMBER;
  l_av_upd              NUMBER;
  l_amount_upd          NUMBER;
  l_base_av_upd         NUMBER;
  l_base_amount_upd     NUMBER;
  l_av_ratio            NUMBER;
  l_base_av_ratio       NUMBER;

  l_debug_loc               VARCHAR2(30) := 'Exec_Amt_Variance_Check';
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(100);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  IF ( AP_APPROVAL_PKG.g_debug_mode = 'Y' ) THEN
    g_debug_mode := 'Y';
  END IF;

  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    AP_Debug_Pkg.Print(g_debug_mode, 'Invoice id: '|| TO_CHAR(p_invoice_id));
    AP_Debug_Pkg.Print(g_debug_mode, 'base currency code: '||
                       p_base_currency_code);
    AP_Debug_Pkg.Print(g_debug_mode, 'invoice currency code: '||
                       p_inv_currency_code);
  END IF;

   /*-----------------------------------------------------------------+
    |  Step 1 - Open Cursor and initialize data for all distribution   |
    |           Line and loop through for calculation                  |
    +-----------------------------------------------------------------*/

  IF (g_debug_mode = 'Y') THEN
    l_debug_info := 'Open Distribution_Cur';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  OPEN Distribution_Cur;
  LOOP
    FETCH Distribution_Cur
     INTO   l_invoice_distribution_id
           ,l_po_dist_id
           ,l_invoice_line_number
     ,l_distribution_line_number
           ,l_accrue_on_receipt_flag
           ,l_po_amt
           ,l_match_option;

    EXIT WHEN Distribution_Cur%NOTFOUND;

    IF ( l_accrue_on_receipt_flag = 'N' and
         l_po_dist_id <> l_prev_po_dist_id ) THEN

   /*-----------------------------------------------------------------+
    | Calculate the Amount Variance                                   |
    +-----------------------------------------------------------------*/

      IF (g_debug_mode = 'Y') THEN
         l_debug_info := 'Exec_Amt_Variance_Check- call Calculate_AV';
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      AP_FUNDS_CONTROL_PKG.Calc_AV(
              p_invoice_id,
              l_po_dist_id,
              p_inv_currency_code,
              p_base_currency_code,
              l_po_amt,
              l_po_dist_av,
              l_po_dist_bav,
              l_update_line_num,
              l_update_dist_num,
              l_curr_calling_sequence);
    END IF;

    l_prev_po_dist_id := l_po_dist_id;

    /*-----------------------------------------------------------------+
    | Amount variance amount is set for line that we want to update    |
    | only                                                             |
    +-----------------------------------------------------------------*/

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Set inv dist av if right dist_line_num to be updated ';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (l_distribution_line_number = l_update_dist_num AND
        l_invoice_line_number = l_update_line_num ) THEN
      l_av  := l_po_dist_av;
      l_bav := l_po_dist_bav;
    ELSE
      l_av  := 0;
      l_bav := 0;
    END IF;

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Exec_Amt_Variance_Checks-update line with dist_line_num'
                       || '=' || to_char(l_distribution_line_number)
                       || 'line_number' || to_char(l_invoice_line_number);
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    UPDATE ap_invoice_distributions
      SET    amount_variance = decode(nvl(amount_variance,0)+l_av,0,
                                        NULL,nvl(amount_variance,0)+l_av),
             base_amount_variance = decode(nvl(base_amount_variance,0)
                                             +l_bav, 0, NULL,
                                             nvl(base_amount_variance,0)
                                             +l_bav),
             last_updated_by = p_system_user,
             last_update_login = fnd_global.login_id
      WHERE  invoice_id = p_invoice_id
      AND    invoice_line_number = l_invoice_line_number
      AND    distribution_line_number = l_distribution_line_number
    RETURNING invoice_distribution_id, amount_variance, amount, base_amount_variance, base_amount
         INTO l_inv_dist_id_upd, l_av_upd, l_amount_upd, l_base_av_upd, l_base_amount_upd;

 IF nvl(l_amount_upd,0) <> 0 and nvl(l_base_amount_upd,0) <> 0 then --bug 7533602

    l_av_ratio      := l_av_upd/l_amount_upd;
    l_base_av_ratio := l_base_av_upd/l_base_amount_upd;

    UPDATE  ap_invoice_distributions_all aid
       SET  amount_variance      = ap_utilities_pkg.ap_round_currency
                                        (aid.amount * l_av_ratio, p_inv_currency_code)
           ,base_amount_variance = ap_utilities_pkg.ap_round_currency
                                        (aid.base_amount * l_base_av_ratio, p_base_currency_code)
     WHERE  invoice_id                   = p_invoice_id
       AND  charge_applicable_to_dist_id = l_inv_dist_id_upd
       AND  line_type_lookup_code       IN ('NONREC_TAX', 'TRV', 'TIPV');

  END IF; --bug 7533602

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'Exec_Amt_Variance_Checks-finish update the distribution'
                       || 'for each distribution line';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

  END LOOP;
  CLOSE Distribution_Cur;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id) );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( Distribution_Cur%ISOPEN ) THEN
      CLOSE Distribution_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Exec_Amt_Variance_Check;

/*============================================================================
 |  PUBLIC PROCEDURE EXECUTE_MATCHED_CHECKS
 |
 |  DESCRIPTION
 |      Procedure to perfrom general matched checks on an invoice
 |      and place or release holds depending on the condition.
 |
 |  PARAMETERS
 |      p_invoice_id - Invoice_Id
 |      p_base_currency_code - system base currency code
 |      p_price_tol - System Price Tolerance
 |      p_qty_tol - System Quantity Ordered Tolerance
 |      p_qty_rec_tol - System Quantity Received Tolerance
 |      p_max_qty_ord_tol - System Max Quantity Ordered Tolerance
 |      p_max_qty_rec_tol - System Max Quantity Received Tolerance
 |      p_amt_tol - System Amount Ordered Tolerance
 |      p_amt_rec_tol - System Amount Received Tolerance
 |  p_max_amt_ord_tol - System Max Amount Ordered Tolerance
 |  p_max_amt_rec_tol - System Max Amount Received Tolerance
 |      p_ship_amt_tolerance - shipment amount tolerance
 |      p_rate_amt_tolerance -
 |      p_total_amt_tolerance -
 |      p_system_user - Approval Program User Id
 |      p_conc_flag - ('Y' or 'N') indicating whether this is called as a
 |                    concurrent program or not.
 |      p_holds - Holds Array
 |      p_holds_count - Holds Count Array
 |      p_release_count - Release Count Array
 |      p_calling_sequence - Debugging string to indicate path of module
 |                           calls to be printed out upon error.
 |   PROGRAM FLOW
 |
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Execute_Matched_Checks(
              p_invoice_id           IN            NUMBER,
              p_base_currency_code   IN            VARCHAR2,
              p_price_tol            IN            NUMBER,
              p_qty_tol              IN            NUMBER,
              p_qty_rec_tol          IN            NUMBER,
              p_max_qty_ord_tol      IN            NUMBER,
              p_max_qty_rec_tol      IN            NUMBER,
        p_amt_tol         IN       NUMBER,
        p_amt_rec_tol       IN       NUMBER,
        p_max_amt_ord_tol      IN      NUMBER,
        p_max_amt_rec_tol      IN       NUMBER,
              p_goods_ship_amt_tolerance     IN            NUMBER,
              p_goods_rate_amt_tolerance     IN            NUMBER,
              p_goods_total_amt_tolerance    IN            NUMBER,
        p_services_ship_amt_tolerance  IN            NUMBER,
        p_services_rate_amt_tolerance  IN            NUMBER,
        p_services_total_amt_tolerance IN            NUMBER,
              p_system_user          IN            NUMBER,
              p_conc_flag            IN            VARCHAR2,
              p_holds                IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_holds_count          IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count        IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence     IN            VARCHAR2) IS

  CURSOR Matched_Cur IS
  SELECT PLL.line_location_id,
         PLL.po_line_id,
         SUM(L.amount),
         NVL(AP_INVOICE_LINES_UTILITY_PKG.get_approval_status(p_invoice_id,L.line_number),'N'),
                                                                                    --bug 5182413
         SUM(nvl(L.quantity_invoiced,0)),
         PLL.price_override,              -- BUG 4123171
         ROUND((nvl(PLL.quantity,0) - nvl(PLL.quantity_cancelled,0)), 15),
         ROUND(nvl(PLL.quantity_received, 0), 15),
         ROUND(nvl(PLL.quantity_accepted, 0), 15),
         nvl(PLL.amount,0) - nvl(PLL.amount_cancelled,0), --Amount Based Matching
   nvl(PLL.amount_received, 0),  --Amount Based Matching
   nvl(PLL.amount_cancelled,0),  --Contract Payments
         NVL(PLL.cancel_flag, 'N'),
         NVL(PLL.receipt_required_flag, 'N'),
         NVL(PLL.inspection_required_flag, 'N'),
         I.invoice_currency_code,
         PH.currency_code,
         PLL.approved_flag,
         PLL.closed_code,
         decode(PLL.final_match_flag, 'Y', 'D', nvl(L.final_match_flag, 'N')), --Bug 3489536
         nvl(L.final_match_flag, 'N'),--Bug 5759169
         decode(PH.type_lookup_code, 'STANDARD', 'PO', 'RELEASE'),
         decode(L.po_release_id, null, PH.type_lookup_code, PR.release_type),
         nvl(PLL.accrue_on_receipt_flag, 'N'),
         DECODE(L.po_release_id, null, L.po_header_id, L.po_release_id),
         PH.segment1,
         nvl(PLL.match_option,'P'),
         L.rcv_transaction_id,
         L.unit_meas_lookup_code,
         RSL.item_id,
         decode(PLL.unit_meas_lookup_code,null,PL.unit_meas_lookup_code,PLL.unit_meas_lookup_code),   -- BUG 4184044
         L.discarded_flag,
         L.cancelled_flag,
         PLL.matching_basis,  -- Amount Based Matching
   --bugfix:4709926 added the NVL condition
   nvl(PLL.payment_type,'DUMMY'),-- Contract Payments: Tolerances Redesign
         I.invoice_type_lookup_code, --Contract Payments: Tolerances Redesign
         I.org_id -- Bug 5500101
  FROM   po_lines PL,
         rcv_transactions RTXN,
         rcv_shipment_lines RSL,
         ap_invoice_lines L,
         ap_invoices I,
         po_line_locations PLL,
         po_headers PH,
         po_releases PR
  WHERE  I.invoice_id = L.invoice_id
  AND    L.po_line_location_id = PLL.line_location_id
  AND    L.match_type in ( 'PRICE_CORRECTION', 'QTY_CORRECTION',
                           'ITEM_TO_PO', 'ITEM_TO_RECEIPT',
                           'ITEM_TO_SERVICE_PO', 'ITEM_TO_SERVICE_RECEIPT', -- ABM
                           'AMOUNT_CORRECTION',  -- Amount Based Matching
                           'PO_PRICE_ADJUSTMENT') --Retropricing
  AND    L.po_release_id = PR.po_release_id(+)
  AND    PLL.po_line_id = PL.po_line_id
  AND    PH.po_header_id = PL.po_header_id
  AND    L.rcv_transaction_id = RTXN.transaction_id(+)
  AND    RTXN.shipment_line_id = RSL.shipment_line_id(+)
  AND    (I.payment_status_flag IN ('N', 'P')
           OR EXISTS (SELECT 'Holds have to be released'
                       FROM   ap_holds H
                       WHERE  H.invoice_id = I.invoice_id
                       AND    H.release_lookup_code is null
                       AND    H.hold_lookup_code in
                                   ('QTY ORD', 'QTY REC',
            'AMT ORD', 'AMT REC',
                                    'QUALITY', 'PRICE',
                                    'CURRENCY DIFFERENCE',
                                    'REC EXCEPTION', 'PO NOT APPROVED',
                                    'MAX QTY REC', 'MAX QTY ORD',
            'MAX AMT REC', 'MAX AMT ORD',
                                    'FINAL MATCHING',
                                    'MAX SHIP AMOUNT',
                                    'MAX RATE AMOUNT',
                                    'MAX TOTAL AMOUNT'))
           OR EXISTS (SELECT 'Unapproved matched dist'
                        FROM   ap_invoice_distributions AID2
                        WHERE  AID2.invoice_id = I.invoice_id
                        AND    AID2.invoice_line_number = L.line_number
                        AND    nvl(AID2.match_status_flag, 'X') <> 'A'))
  AND     I.invoice_id = p_invoice_id
  GROUP BY PLL.line_location_id, L.rcv_transaction_id,
           nvl(PLL.match_option,'P'),PLL.po_line_id,
           I.invoice_currency_code,
           ROUND((nvl(PLL.quantity,0) - nvl(PLL.quantity_cancelled,0)), 15),
           PLL.quantity_received,
           PLL.price_override, PLL.quantity_billed, PLL.quantity_accepted,
           nvl(PLL.amount,0) - nvl(PLL.amount_cancelled,0),
           PLL.amount_received,
     PLL.amount_cancelled,
           PLL.amount_billed,
           PLL.cancel_flag, PLL.receipt_required_flag,
           PLL.inspection_required_flag,
           PH.currency_code,
           PLL.approved_flag, PLL.closed_code,
           decode(PLL.final_match_flag, 'Y', 'D', nvl(L.final_match_flag, 'N')),  --Bug 3489536
           nvl(L.final_match_flag, 'N'),--Bug 5759169
           PLL.accrue_on_receipt_flag,
           decode(PH.type_lookup_code, 'STANDARD', 'PO', 'RELEASE'),
           DECODE(L.po_release_id, null, L.po_header_id, L.po_release_id),
           decode(L.po_release_id, null, PH.type_lookup_code, PR.release_type),
           PH.segment1, L.unit_meas_lookup_code,RSL.item_id,
           decode(PLL.unit_meas_lookup_code,null,PL.unit_meas_lookup_code,PLL.unit_meas_lookup_code),    -- BUG 4184044
           L.discarded_flag,L.cancelled_flag,
           PLL.matching_basis,PLL.payment_type,I.invoice_type_lookup_code,
           I.org_id,
           NVL(AP_INVOICE_LINES_UTILITY_PKG.get_approval_status(p_invoice_id,L.line_number),'N');-- Bug 5182413
                                                                                  l_line_location_id            NUMBER(15);
  l_po_line_id                  NUMBER(15);
  l_inv_line_amount             NUMBER;
  l_adj_qty_invoiced            NUMBER;
  l_po_unit_price               NUMBER;
  l_qty_ordered                 NUMBER;
  l_qty_billed                  NUMBER;
  l_qty_received                NUMBER;
  l_qty_accepted                NUMBER;
  l_amt_ordered                 NUMBER;   -- Amount Based Matching
  l_amt_billed                  NUMBER;   -- Amount Based Matching
  l_amt_received                NUMBER;   -- Amount Based Matching
  l_amt_cancelled    NUMBER;
  l_cancel_flag                 VARCHAR2(1);
  l_receipt_required_flag       VARCHAR2(1);
  l_inspection_required_flag    VARCHAR2(1);
  l_inv_currency_code           VARCHAR2(15);
  l_po_currency_code            VARCHAR2(15);
  l_po_approved_flag            VARCHAR2(1);
  l_po_closed_code              VARCHAR2(25);
  l_final_match_flag            VARCHAR2(1);
  l_dist_final_match_flag       VARCHAR2(1);--bug5759169
  l_po_doc_type                 VARCHAR2(25);
  l_po_sub_type                 VARCHAR2(25);
  l_accrue_on_receipt_flag      VARCHAR2(1);
  l_po_header_id                NUMBER;
  l_po_num                      VARCHAR2(20);
  l_final_matching_exists       VARCHAR2(1) ;
  l_currency_difference_exists  VARCHAR2(1) ;
  l_po_not_approved_exists      VARCHAR2(1) ;
  l_qty_ord_error_exists        VARCHAR2(1) ;
  l_max_qty_ord_error_exists    VARCHAR2(1) ;
  l_qty_rec_error_exists        VARCHAR2(1) ;
  l_max_qty_rec_error_exists    VARCHAR2(1) ;
  l_amt_ord_error_exists        VARCHAR2(1) ;
  l_max_amt_ord_error_exists    VARCHAR2(1) ;
  l_amt_rec_error_exists        VARCHAR2(1) ;
  l_max_amt_rec_error_exists    VARCHAR2(1) ;
  l_milestone_error_exists      VARCHAR2(1) ;
  l_qty_overbilled_exists       VARCHAR2(1) ;
  l_max_ship_amt_exceeded       VARCHAR2(1) ;
  l_max_rate_amt_exceeded       VARCHAR2(1) ;
  l_max_total_amt_exceeded      VARCHAR2(1) ;
  l_action                      VARCHAR2(25);
  l_return_code                 VARCHAR2(25);
  l_ship_trx_amt_var            NUMBER ;
  l_rate_amt_var                NUMBER ;
  l_ship_base_amt_var           NUMBER ;
  l_match_option                VARCHAR2(25);
  l_rcv_transaction_id          NUMBER;
  l_ordered_po_qty              NUMBER;
  l_cancelled_po_qty            NUMBER;
  l_received_po_qty             NUMBER;
  l_corrected_po_qty            NUMBER;
  l_delivered_po_qty            NUMBER;
  l_rtv_po_qty                  NUMBER;
  l_billed_po_qty               NUMBER;
  l_accepted_po_qty             NUMBER;
  l_rejected_po_qty             NUMBER;
  l_ordered_txn_qty             NUMBER;
  l_cancelled_txn_qty           NUMBER;
  l_received_qty                NUMBER;
  l_corrected_qty               NUMBER;
  l_delivered_txn_qty           NUMBER;
  l_rtv_txn_qty                 NUMBER;
  l_billed_txn_qty              NUMBER;
  l_accepted_txn_qty            NUMBER;
  l_rejected_txn_qty            NUMBER;
  l_received_quantity_used      NUMBER;
  l_billed_quantity_used        NUMBER;
  l_accepted_quantity_used      NUMBER;
  l_received_amount_used        NUMBER;
  l_billed_amount_used          NUMBER;
  l_txn_uom                     VARCHAR2(25);
  l_po_uom                      VARCHAR2(25);
  l_item_id                     NUMBER;
  l_discarded_flag              ap_invoice_lines.discarded_flag%TYPE;
  l_cancelled_flag              ap_invoice_lines.cancelled_flag%TYPE;
  l_matching_basis              po_line_locations.matching_basis%TYPE;  -- Amount Based Matching

  --Contract Payments: Tolerances Redesign
  l_invoice_type_lookup_code    ap_invoices_all.invoice_type_lookup_code%TYPE;
  l_payment_type    po_line_locations_all.payment_type%TYPE;
  l_billed_amt      NUMBER;
  l_amt_delivered    NUMBER;
  l_amt_corrected    NUMBER;
  l_ret_status       VARCHAR2(100);
  l_msg_count         NUMBER;
  l_msg_data         VARCHAR2(250);

  l_debug_loc                   VARCHAR2(30) := 'Execute_Matched_Checks';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(100);

  -- 3488259 (3110072) Starts
  l_ship_amount                 NUMBER := 0;
  l_org_id                      NUMBER;
  l_fv_tol_check                VARCHAR2(1);
  -- 3488259 (3110072) Ends

  l_line_match_status_flag   VARCHAR2(25);  -- BUG 5182413

  -- Bug 5077550
  l_check_milestone_diff VARCHAR2(100);
  l_amt_billed_receipt                  NUMBER; --8894586


BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  IF ( AP_APPROVAL_PKG.g_debug_mode = 'Y' ) THEN
    g_debug_mode := 'Y';
  END IF;

  l_action := 'UPDATE_CLOSE_STATE';

  -----------------------------------------
  l_debug_info := 'Open Matched_Cur';
  -----------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  OPEN Matched_Cur;
  LOOP

    ---------------------------------------
    l_debug_info := 'Fetch Matched_Cur';
    ---------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    FETCH Matched_Cur
    INTO l_line_location_id,
         l_po_line_id,
         l_inv_line_amount,
         l_line_match_status_flag, -- bug 5182413
         l_adj_qty_invoiced,
         l_po_unit_price,
         l_qty_ordered,
         l_qty_received,
         l_qty_accepted,
         l_amt_ordered,             -- Amount Based Matching
         l_amt_received,            -- Amount Based Matching
   l_amt_cancelled,      -- Contract Payments
         l_cancel_flag,
         l_receipt_required_flag,
         l_inspection_required_flag,
         l_inv_currency_code,
         l_po_currency_code,
         l_po_approved_flag,
         l_po_closed_code,
         l_final_match_flag,
   l_dist_final_match_flag,--bug5759169
         l_po_doc_type,
         l_po_sub_type,
         l_accrue_on_receipt_flag,
         l_po_header_id,
         l_po_num,
         l_match_option,
         l_rcv_transaction_id,
         l_txn_uom,
         l_item_id,
         l_po_uom,
         l_discarded_flag,
         l_cancelled_flag,
         l_matching_basis,         -- Amount Based Matching
   l_payment_type,          --Contract Payments: Tolerances Redesign
         l_invoice_type_lookup_code,   --Contract Payments: Tolerances Redesign
         l_org_id; -- 5500101

    EXIT WHEN Matched_Cur%NOTFOUND;

    l_final_matching_exists      := 'N';
    l_currency_difference_exists := 'N';
    l_po_not_approved_exists     := 'N';
    l_qty_ord_error_exists       := 'N';
    l_max_qty_ord_error_exists   := 'N';
    l_qty_rec_error_exists       := 'N';
    l_max_qty_rec_error_exists   := 'N';
    l_amt_ord_error_exists       := 'N';
    l_max_amt_ord_error_exists   := 'N';
    l_amt_rec_error_exists       := 'N';
    l_max_amt_rec_error_exists   := 'N';
    l_milestone_error_exists     := 'N';
    l_qty_overbilled_exists      := 'N';
    l_max_ship_amt_exceeded      := 'N';
    l_max_rate_amt_exceeded      := 'N';
    l_max_total_amt_exceeded     := 'N';
    l_ship_trx_amt_var           := 0;
    l_rate_amt_var               := 0;
    l_ship_base_amt_var          := 0;

    l_debug_info := 'Get receipt quantites for' ||
                      to_char(l_rcv_transaction_id);

    If ( l_match_option = 'R' ) Then

      If l_matching_basis = 'QUANTITY' Then  -- Amount Based Matching

        RCV_INVOICE_MATCHING_SV.get_quantities (
                top_transaction_id  => l_rcv_transaction_id,  -- IN
                ordered_po_qty      => l_ordered_po_qty,      -- IN OUT
                cancelled_po_qty    => l_cancelled_po_qty,    -- IN OUT
                received_po_qty     => l_received_po_qty,     -- IN OUT
                corrected_po_qty    => l_corrected_po_qty,    -- IN OUT
                delivered_po_qty    => l_delivered_po_qty,    -- IN OUT
                rtv_po_qty          => l_rtv_po_qty,          -- IN OUT
                billed_po_qty       => l_billed_po_qty,       -- IN OUT
                accepted_po_qty     => l_accepted_po_qty,     -- IN OUT
                rejected_po_qty     => l_rejected_po_qty,     -- IN OUT
                ordered_txn_qty     => l_ordered_txn_qty,     -- IN OUT
                cancelled_txn_qty   => l_cancelled_txn_qty,   -- IN OUT
                received_txn_qty    => l_received_qty,        -- IN OUT
                corrected_txn_qty   => l_corrected_qty,       -- IN OUT
                delivered_txn_qty   => l_delivered_txn_qty,   -- IN OUT
                rtv_txn_qty         => l_rtv_txn_qty,         -- IN OUT
                billed_txn_qty      => l_billed_txn_qty,      -- IN OUT
                accepted_txn_qty    => l_accepted_txn_qty,    -- IN OUT
                rejected_txn_qty    => l_rejected_txn_qty);   -- IN OUT

      Elsif l_matching_basis = 'AMOUNT' Then

  --For the case of service orders, eventhough UOM is allowed on PO for certain line types
  --like Rate Based cannot be different on the receipt.
  --So we don't have to worry about the coversions between
  --different UOMs for the case of service order receipts.

  RCV_INVOICE_MATCHING_SV.Get_ReceiveAmount(
    P_Api_version => 1.0,
    P_Init_Msg_List => 'T',
    x_return_status => l_ret_status,
    x_msg_count  => l_msg_count,
    x_msg_data  => l_msg_data,
    P_receive_transaction_id =>  l_rcv_transaction_id  ,
    x_billed_amt  => l_amt_billed,
    x_received_amt    =>l_amt_received,
                x_delivered_amt   =>l_amt_delivered,
    x_corrected_amt   =>l_amt_corrected);

   l_amt_billed_receipt := l_amt_billed ; --8894586
      End If;     -- Amount Based Matching

    End if;

    ---------------------------------------
    l_debug_info := 'Check PO closed code';
    ---------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

   /*-----------------------------------------------------------------+
    |  Set final_matching_exists to 'Y' when po_close_code is final   |
    |  and final_match_flag is not 'Done' and invoice line is Matched |
    |  and not discarded or cancelled. Because system does allow 0    |
    |  amount and 0 unit price matching. line amount <> 0 is not      |
    |  sufficient to determine if invoice line is an effective        |
    |  matching line                                                  |
    +-----------------------------------------------------------------*/
    --bug5759169.Added the below IF statement
    --added the code to place hold on all invoices with final_match flag as 'R'
    --which indicates that the invoice has been created after the
    --final matching is done already.
    --Hold is also placed on the invoice if the PO has already been closed
    --and if the final match flag is not equal to 'D'


    IF (l_dist_final_match_flag='R') THEN  --bug5759169

    l_final_matching_exists := 'Y';  --bug5759169

    --Bug8917261: Changed value not equal to Y for discarded_flag
    --and cancelled_flag
    ELSIF ((l_po_closed_code = 'FINALLY CLOSED') AND
        (l_final_match_flag <> 'D') AND
        (l_line_match_status_flag <> 'APPROVED') AND      -- BUG 5182413
        (NVL(l_discarded_flag, 'N' ) <> 'Y') AND
        (NVL(l_cancelled_flag, 'N' ) <> 'Y') )THEN

      l_final_matching_exists := 'Y';

    END IF;


    -----------------------------------------------------------------
    l_debug_info := 'Process FINAL MATCHING hold for shipment match';
    -----------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'FINAL MATCHING',
              l_final_matching_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

    ------------------------------------------------
    l_debug_info := 'Check for Currency Difference';
    ------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (l_inv_currency_code <> l_po_currency_code) THEN

      l_currency_difference_exists := 'Y';

    END IF;

    ----------------------------------------------------------------------
    l_debug_info := 'Process CURRENCY DIFFERENCE hold for shipment match';
    ----------------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'CURRENCY DIFFERENCE',
               l_currency_difference_exists,
               null,
               p_system_user,
               p_holds,
               p_holds_count,
               p_release_count,
               l_curr_calling_sequence);

    -----------------------------------------
    l_debug_info := 'Check PO Approval Flag';
    -----------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    --Bug8971070: Corrected the conditional operator from '<>' to '='
    --for l_discarded_flag and l_cancelled_flag
    IF ((l_po_approved_flag <> 'Y') AND
        (NVL(l_discarded_flag, 'N' ) = 'N') AND
        (NVL(l_cancelled_flag, 'N' ) = 'N') )THEN

      l_po_not_approved_exists := 'Y';

    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Process PO NOT APPROVED hold for shipment match';
    ------------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'PO NOT APPROVED',
              l_po_not_approved_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

    ------------------------------------------
    l_debug_info := 'Check Receipt Exception';
    ------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    Check_Receipt_Exception(
            p_invoice_id,
            l_line_location_id,
            l_match_option,
            l_rcv_transaction_id,
            p_system_user,
            p_holds,
            p_holds_count,
            p_release_count,
            l_curr_calling_sequence);

    -------------------------------------------------------------
     l_debug_info := 'Calculate Invoice Shipment Quantity Billed';
    -------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (l_payment_type <> 'MILESTONE') THEN

       If l_matching_basis = 'QUANTITY' Then   -- Amount Based Matching

          Calc_Total_Shipment_Qty_Billed(
                p_invoice_id,
            l_line_location_id,
            l_match_option,
            l_rcv_transaction_id,
            l_qty_billed,
      l_invoice_type_lookup_code, --Contract Payments
           l_curr_calling_sequence);

         -----------------------------------------
         l_debug_info := 'Check Quantity Ordered';
         -----------------------------------------
         IF (g_debug_mode = 'Y') THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (p_qty_tol IS NOT NULL) THEN
            IF (l_qty_billed > (p_qty_tol * l_qty_ordered)) THEN

               l_qty_ord_error_exists := 'Y';

            END IF;
         ELSE
            l_qty_ord_error_exists := 'N';
         END IF;

         ----------------------------------------------------------
         l_debug_info := 'Process QTY ORD hold for shipment match';
         ----------------------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'QTY ORD',
              l_qty_ord_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

         -------------------------------------------------
         l_debug_info := 'Check Maximim Quantity Ordered';
         -------------------------------------------------

         IF (p_max_qty_ord_tol IS NOT NULL) THEN
           IF (l_qty_billed > (p_max_qty_ord_tol + l_qty_ordered)) THEN
             l_max_qty_ord_error_exists := 'Y';
           END IF;
         ELSE
           l_max_qty_ord_error_exists := 'N';
         END IF;

         --------------------------------------------------------------
         l_debug_info := 'Process MAX QTY ORD hold for shipment match';
         --------------------------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'MAX QTY ORD',
              l_max_qty_ord_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

         ------------------------------------------
         l_debug_info := 'Check Quantity Received ';
         ------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

        /*-----------------------------------------------------------------+
         |  Calculate the net quantity received. the values are got from   |
         |  calling the PO api earlier on. the same tolerance is used to   |
         |  check if it needs to be put on hold. Note however that if      |
         |  matched to receipt, quantites are in Receipt UOM and if        |
         |  matching to PO quantities are in PO UOM.                       |
         +-----------------------------------------------------------------*/

         If (l_match_option = 'R') then
            l_received_quantity_used:= nvl(l_received_qty,0)
                                   + nvl(l_corrected_qty,0)
                                   - nvl(l_rtv_txn_qty,0);
            l_billed_quantity_used := nvl(l_billed_txn_qty,0);

         Elsif (l_match_option = 'P') then

            l_received_quantity_used := l_qty_received;
            l_billed_quantity_used := l_qty_billed;

         End if;


         IF (p_qty_rec_tol IS NOT NULL) THEN
           IF ((l_billed_quantity_used >(p_qty_rec_tol * l_received_quantity_used))
             AND (l_receipt_required_flag = 'Y')) THEN

             l_qty_rec_error_exists := 'Y';

           END IF;
         ELSE
           l_qty_rec_error_exists := 'N';
         END IF;

         ----------------------------------------------------------
         l_debug_info := 'Process QTY REC hold for shipment match';
         ----------------------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'QTY REC',
              l_qty_rec_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

         --------------------------------------------------
         l_debug_info := 'Check Maximum Quantity Received';
         --------------------------------------------------
         IF (g_debug_mode = 'Y') THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (p_max_qty_rec_tol IS NOT NULL) THEN
            IF ( (l_billed_quantity_used >
               (p_max_qty_rec_tol + l_received_quantity_used))
               AND (l_receipt_required_flag = 'Y')) THEN

               l_max_qty_rec_error_exists := 'Y';

            END IF;
         ELSE
            l_max_qty_rec_error_exists := 'N';
         END IF;

         --------------------------------------------------------------
         l_debug_info := 'Process MAX QTY REC hold for shipment match';
         --------------------------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'MAX QTY REC',
              l_max_qty_rec_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

         ------------------------------
         l_debug_info := 'Check Price';
         ------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         Check_Price(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              l_match_option,
              l_txn_uom,
              l_po_uom,
              l_item_id,
              l_inv_currency_code,
              l_po_unit_price,
              p_price_tol,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

         -------------------------------------------
         l_debug_info := 'Check Quantity Inspected';
         -------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (l_match_option = 'R') THEN
            l_billed_quantity_used := nvl(l_billed_txn_qty,0); -- from po api
            l_accepted_quantity_used := nvl(l_accepted_txn_qty,0);
         ELSIF (l_match_option = 'P') THEN
            l_billed_quantity_used := l_qty_billed; -- calculated earlier
            l_accepted_quantity_used := l_qty_accepted; -- from cursor
         END IF;

         IF ((l_billed_quantity_used > l_accepted_quantity_used) AND
             (l_inspection_required_flag = 'Y')) THEN
            l_qty_overbilled_exists := 'Y';

         END IF;

         ----------------------------------------------------------
         l_debug_info := 'Process QUALITY hold for shipment match';
         ----------------------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'QUALITY',
              l_qty_overbilled_exists,
              NULL,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);


       --Contract Payment: Tolerances Redesign
       ELSIF l_matching_basis = 'AMOUNT' THEN

           Calc_Total_Shipment_Amt_Billed(
            p_invoice_id,
            l_line_location_id,
            l_match_option,
            l_rcv_transaction_id,
            l_amt_billed,
            l_invoice_type_lookup_code,
            l_curr_calling_sequence);

           -----------------------------------------
           l_debug_info := 'Check Amount Ordered';
           -----------------------------------------
           IF (g_debug_mode = 'Y') THEN
             AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           IF (p_amt_tol IS NOT NULL) THEN
              IF (l_amt_billed > (p_amt_tol * l_amt_ordered)) THEN

                 l_amt_ord_error_exists := 'Y';

              END IF;
           ELSE
              l_amt_ord_error_exists := 'N';
           END IF;

           ----------------------------------------------------------
           l_debug_info := 'Process AMT ORD hold for shipment match';
           ----------------------------------------------------------
           IF (g_debug_mode = 'Y') THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'AMT ORD',
              l_amt_ord_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

           -------------------------------------------------
           l_debug_info := 'Check Maximum Amount Ordered';
           -------------------------------------------------

           IF (p_max_amt_ord_tol IS NOT NULL) THEN
              IF (l_amt_billed > (p_max_amt_ord_tol + l_amt_ordered)) THEN
                  l_max_amt_ord_error_exists := 'Y';
              END IF;
           ELSE
              l_max_amt_ord_error_exists := 'N';
           END IF;

           --------------------------------------------------------------
           l_debug_info := 'Process MAX AMT ORD hold for shipment match';
           --------------------------------------------------------------
           IF (g_debug_mode = 'Y') THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'MAX AMT ORD',
              l_max_amt_ord_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

           ------------------------------------------
           l_debug_info := 'Check Amount Received ';
           ------------------------------------------
           IF (g_debug_mode = 'Y') THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           /*-----------------------------------------------------------------+
            |  Calculate the net amount received. the values are got from     |
            |  calling the PO api earlier on. the same tolerance is used to   |
            |  check if it needs to be put on hold.                           |
            +-----------------------------------------------------------------*/

            If (l_match_option = 'R') then
               l_received_amount_used:= nvl(l_amt_received,0)
                                       + nvl(l_amt_corrected,0) ;
             --  l_billed_amount_used := nvl(l_amt_billed,0);
	     --  8894586 commented and added below statement
	       l_billed_amount_used := nvl(l_amt_billed_receipt,0) ;--8894586
            Elsif (l_match_option = 'P') then
               l_received_amount_used := nvl(l_amt_received,0);
               l_billed_amount_used := nvl(l_amt_billed,0);
            End if;


            IF (p_amt_rec_tol IS NOT NULL) THEN
               IF ((l_billed_amount_used >(p_amt_rec_tol * l_received_amount_used))
                  AND (l_receipt_required_flag = 'Y')) THEN
                  l_amt_rec_error_exists := 'Y';

               END IF;
            ELSE
               l_amt_rec_error_exists := 'N';
            END IF;

            ----------------------------------------------------------
            l_debug_info := 'Process AMT REC hold for shipment match';
            ----------------------------------------------------------
            IF (g_debug_mode = 'Y') THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'AMT REC',
              l_amt_rec_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

            --------------------------------------------------
            l_debug_info := 'Check Maximum Amount Received';
            --------------------------------------------------
            IF (g_debug_mode = 'Y') THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            IF (p_max_amt_rec_tol IS NOT NULL) THEN
               IF ( (l_billed_amount_used >
                    (p_max_amt_rec_tol + l_received_amount_used))
                  AND (l_receipt_required_flag = 'Y')) THEN

                  l_max_amt_rec_error_exists := 'Y';

               END IF;
            ELSE
               l_max_amt_rec_error_exists := 'N';
            END IF;

            --------------------------------------------------------------
            l_debug_info := 'Process MAX AMT REC hold for shipment match';
            --------------------------------------------------------------
            IF (g_debug_mode = 'Y') THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            AP_APPROVAL_PKG.Process_Inv_Hold_Status(
                        p_invoice_id,
                  l_line_location_id,
                       l_rcv_transaction_id,
                 'MAX AMT REC',
                  l_max_amt_rec_error_exists,
                 null,
                   p_system_user,
                       p_holds,
                       p_holds_count,
                       p_release_count,
                       l_curr_calling_sequence);

       END IF;   -- Amount Based Matching. Matchiing Basis is QUANTITY

    --Contract Payments
    ELSIF (l_payment_type = 'MILESTONE') THEN

       IF (l_matching_basis = 'QUANTITY') THEN

           Calc_Total_Shipment_Qty_Billed(
                p_invoice_id,
            l_line_location_id,
            l_match_option,
            l_rcv_transaction_id,
            l_qty_billed,
      l_invoice_type_lookup_code, --Contract Payments
           l_curr_calling_sequence);

           --
           -- Bug 5077550
           --
           l_check_milestone_diff :=
             Check_Milestone_Price_Qty(p_invoice_id,
                                           l_line_location_id,
                                           l_po_unit_price,
                                           l_curr_calling_sequence);

            -----------------------------------------------------------
            l_debug_info := 'Check for Milestone Hold for Quantity Ordered';
            -----------------------------------------------------------
            IF (g_debug_mode = 'Y') THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;
            --
            -- Bug 5077550
            -- When the pay item type is milestone and the match basis is
            -- quantity, we should allow partial billing.
            -- we will not allow over billing
            -- we will not allow amount to be anything other than that of the
            -- value of the pay item.
            -- since we are supporting partial billing and rounding of
            -- amounts/price involved we will verify
            -- only the following:
            --   1) total quantity billed for this shipment should be less than
            --      that of the ordered qty.
            --   2) unit price should be same at the invoice line and the
            --      PO Shipment
            --   3) The quantity invoiced should be an integer and cannot
            --      have decimals tied to it. /*7356651 modified below if */

            IF (l_qty_billed > l_qty_ordered) OR
               (l_check_milestone_diff =
                -- 'Price Difference or Quantity Has Decimals' and l_qty_billed<>0)    ..  bug8704810
                'Price Difference' and l_qty_billed<>0)                                --  bug8704810
               THEN
                l_milestone_error_exists := 'Y';
            ELSE
    l_milestone_error_exists := 'N';
            END IF;

            ----------------------------------------------------------
            l_debug_info := 'Process MILESTONE hold for shipment match';
            ----------------------------------------------------------
            IF (g_debug_mode = 'Y') THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            AP_APPROVAL_PKG.Process_Inv_Hold_Status(
                p_invoice_id,
                l_line_location_id,
                l_rcv_transaction_id,
                'MILESTONE',
                l_milestone_error_exists,
                null,
                p_system_user,
                p_holds,
                p_holds_count,
                p_release_count,
                l_curr_calling_sequence);

         -- BUG6777765 START
         ------------------------------------------
         l_debug_info := 'Check Quantity Received ';
         ------------------------------------------


         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

        /*-----------------------------------------------------------------+
         |  Calculate the net quantity received. the values are got from   |
         |  calling the PO api earlier on. the same tolerance is used to   |
         |  check if it needs to be put on hold. Note however that if      |
         |  matched to receipt, quantites are in Receipt UOM and if        |
         |  matching to PO quantities are in PO UOM.                       |
         +-----------------------------------------------------------------*/

         If (l_match_option = 'R') then
            l_received_quantity_used:= nvl(l_received_qty,0)
                                   + nvl(l_corrected_qty,0)
                                   - nvl(l_rtv_txn_qty,0);
            l_billed_quantity_used := nvl(l_billed_txn_qty,0);

         Elsif (l_match_option = 'P') then

            l_received_quantity_used := l_qty_received;
            l_billed_quantity_used := l_qty_billed;

         End if;


         IF (p_qty_rec_tol IS NOT NULL) THEN
           IF ((l_billed_quantity_used >(p_qty_rec_tol * l_received_quantity_used))
             AND (l_receipt_required_flag = 'Y')) THEN

             l_qty_rec_error_exists := 'Y';

           END IF;
         ELSE
           l_qty_rec_error_exists := 'N';
         END IF;

         ----------------------------------------------------------
         l_debug_info := 'Process QTY REC hold for shipment match';
         ----------------------------------------------------------
         IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'QTY REC',
              l_qty_rec_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

         --BUG6777765 END


       ELSIF (l_matching_basis = 'AMOUNT') THEN

          Calc_Total_Shipment_Amt_Billed(
            p_invoice_id,
            l_line_location_id,
            l_match_option,
            l_rcv_transaction_id,
            l_amt_billed,
            l_invoice_type_lookup_code,
            l_curr_calling_sequence);

           -----------------------------------------
           l_debug_info := 'Check Amount Ordered';
           -----------------------------------------
           IF (g_debug_mode = 'Y') THEN
             AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

--Bug6830703
--added the condition l_amt_billed<>0 to avoid checking
--the milestone hold condition for cancellation event
--because for cancellation of invoice line amount is updated to 0
--this results in the unnecessary hold placement
--


           IF (l_amt_billed<>0 and l_amt_billed <> l_amt_ordered) THEN
              l_milestone_error_exists := 'Y';
           ELSE
              l_milestone_error_exists := 'N';
           END IF;

           ----------------------------------------------------------
           l_debug_info := 'Process AMT ORD hold for shipment match';
           ----------------------------------------------------------
           IF (g_debug_mode = 'Y') THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'MILESTONE',
              l_milestone_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);


         --BUG6777765 START

           ------------------------------------------
           l_debug_info := 'Check Amount Received ';
           ------------------------------------------
           IF (g_debug_mode = 'Y') THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           /*-----------------------------------------------------------------+
            |  Calculate the net amount received. the values are got from     |
            |  calling the PO api earlier on. the same tolerance is used to   |
            |  check if it needs to be put on hold.                           |
            +-----------------------------------------------------------------*/

            If (l_match_option = 'R') then
               l_received_amount_used:= nvl(l_amt_received,0)
                                       + nvl(l_amt_corrected,0) ;
               l_billed_amount_used := nvl(l_amt_billed,0);
            Elsif (l_match_option = 'P') then
               l_received_amount_used := nvl(l_amt_received,0);
               l_billed_amount_used := nvl(l_amt_billed,0);
            End if;


            IF (p_amt_rec_tol IS NOT NULL) THEN
               IF ((l_billed_amount_used >(p_amt_rec_tol * l_received_amount_used))
                  AND (l_receipt_required_flag = 'Y')) THEN
                  l_amt_rec_error_exists := 'Y';

               END IF;
            ELSE
               l_amt_rec_error_exists := 'N';
            END IF;

            ----------------------------------------------------------
            l_debug_info := 'Process AMT REC hold for shipment match';
            ----------------------------------------------------------
            IF (g_debug_mode = 'Y') THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'AMT REC',
              l_amt_rec_error_exists,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

          --BUG6777765 END

       END IF;  /* l_matching_basis = 'QUANTITY' */

    END IF;  /* l_payment_type <> 'MILESTONE' */


    ---------------------------------------
    l_debug_info := 'Check PO closed code';
    ---------------------------------------
 -- BUG 3486887 : Added parameter p_origin_doc_id=> p_invoice_id in Close_PO()

    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (l_final_match_flag NOT IN ('Y', 'D')) THEN

      IF (NOT(PO_ACTIONS.Close_PO(
                        p_docid        => l_po_header_id,
                        p_doctyp       => l_po_doc_type,
                        p_docsubtyp    => l_po_sub_type,
                        p_lineid       => l_po_line_id,
                        p_shipid       => l_line_location_id,
                        p_action       => l_action,
                        p_reason       => NULL,
                        p_calling_mode => 'AP',
                        p_conc_flag    => p_conc_flag,
                        p_return_code  => l_return_code,
                        p_auto_close   => 'Y',
                        p_origin_doc_id=> p_invoice_id))) THEN
        APP_EXCEPTION.Raise_Exception;
      END IF;
    END IF;  -- Not a final match invoice --

    --------------------------------------------------
    l_debug_info := 'Check for ship amount tolerance';
    --------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;


    IF (l_payment_type <> 'MILESTONE') THEN

       Calc_Ship_Total_Trx_Amt_Var(
            p_invoice_id,
            l_line_location_id,
            l_match_option,
            l_po_unit_price,
            l_ship_amount, -- 3488259 (3110072)
            l_matching_basis,
            l_ship_trx_amt_var,
            l_curr_calling_sequence,
            l_org_id);


      l_max_ship_amt_exceeded := 'N' ;   --Bug 5292808

      -- Bug 5292808. Modified the check for shipment amt tolerance

      IF (l_matching_basis = 'QUANTITY') THEN

         IF (p_goods_ship_amt_tolerance IS NOT NULL) THEN
            IF (nvl(l_ship_trx_amt_var, 0) > p_goods_ship_amt_tolerance) THEN
               l_max_ship_amt_exceeded := 'Y';
            END IF;

          END IF;
      END IF;


/* 5292808 commented the below check for shipment amt tolerance
           in case of amt based matching
      ELSIF (l_matching_basis = 'AMOUNT') THEN

         IF (p_services_ship_amt_tolerance IS NOT NULL) THEN
      IF (nvl(l_ship_trx_amt_var, 0) > p_services_ship_amt_tolerance) THEN
         l_max_ship_amt_exceeded := 'Y';
      ELSE
         l_max_ship_amt_exceeded := 'N';
      END IF;
   ELSE
      l_max_ship_amt_exceeded := 'N';
   END IF;

      END IF;   */

       -----------------------------------------------------------------------
       l_debug_info := 'Process MAX SHIP AMOUNT Hold for this shipment match';
       -----------------------------------------------------------------------
       IF (g_debug_mode = 'Y') THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'MAX SHIP AMOUNT',
              l_max_ship_amt_exceeded,
              NULL,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

       -----------------------------------------------------------
       l_debug_info := 'Compare erv with exchange rate tolerance';
       -----------------------------------------------------------
       IF (g_debug_mode = 'Y') THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF ((l_matching_basis = 'QUANTITY' and p_goods_rate_amt_tolerance IS NOT NULL)
           OR (l_matching_basis = 'AMOUNT' and p_services_rate_amt_tolerance IS NOT NULL))
                         THEN
          Calc_Max_Rate_Var(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              l_match_option,
              l_rate_amt_var,
              l_curr_calling_sequence);

   IF (l_matching_basis = 'QUANTITY') THEN
            IF (nvl(l_rate_amt_var, 0) > p_goods_rate_amt_tolerance) THEN
               l_max_rate_amt_exceeded := 'Y';
            ELSE
               l_max_rate_amt_exceeded := 'N';
            END IF;
   ELSIF (l_matching_basis = 'AMOUNT') THEN
            IF (nvl(l_rate_amt_var, 0) > p_services_rate_amt_tolerance) THEN
         l_max_rate_amt_exceeded := 'Y';
      ELSE
         l_max_rate_amt_exceeded := 'N';
      END IF;
   END IF;

       ELSE
         l_max_rate_amt_exceeded := 'N';
       END IF;

       -----------------------------------------------------------------------
       l_debug_info := 'Process MAX RATE AMOUNT Hold for this shipment match';
       -----------------------------------------------------------------------
       IF (g_debug_mode = 'Y') THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'MAX RATE AMOUNT',
              l_max_rate_amt_exceeded,
              NULL,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

       --------------------------------------------------
       l_debug_info := 'Check for total amount tolerance';
       --------------------------------------------------
       IF (g_debug_mode = 'Y') THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF ((l_matching_basis = 'QUANTITY' and p_goods_total_amt_tolerance IS NOT NULL) OR
           (l_matching_basis = 'AMOUNT' and p_services_total_amt_tolerance IS NOT NULL)
          AND
          l_inv_currency_code <> p_base_currency_code) THEN

          Calc_Ship_Total_Base_Amt_Var(
            p_invoice_id,
            l_line_location_id,
            l_match_option,
            l_po_unit_price,
            l_matching_basis,
            l_inv_currency_code,
            p_base_currency_code,
            l_ship_base_amt_var,
            l_curr_calling_sequence);

   IF (l_matching_basis = 'QUANTITY') THEN
            IF (nvl(l_ship_base_amt_var, 0) > p_goods_total_amt_tolerance) THEN
               l_max_total_amt_exceeded := 'Y';
            ELSE
               l_max_total_amt_exceeded := 'N';
            END IF;
         ELSIF (l_matching_basis = 'AMOUNT') THEN
            IF (nvl(l_ship_base_amt_var, 0) > p_services_total_amt_tolerance) THEN
               l_max_total_amt_exceeded := 'Y';
            ELSE
               l_max_total_amt_exceeded := 'N';
            END IF;
   END IF;

       ELSE
         l_max_total_amt_exceeded := 'N';
       END IF;

       -----------------------------------------------------------------------
       l_debug_info := 'Process MAX TOTAL AMOUNT Hold for this shipment match';
       -----------------------------------------------------------------------
       IF (g_debug_mode = 'Y') THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       AP_APPROVAL_PKG.Process_Inv_Hold_Status(
              p_invoice_id,
              l_line_location_id,
              l_rcv_transaction_id,
              'MAX TOTAL AMOUNT',
              l_max_total_amt_exceeded,
              null,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

    END IF; /*l_payment_type <> 'MILESTONE' */

  END LOOP;

  CLOSE Matched_Cur;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Dist_line_num = '|| to_char(p_price_tol)
              ||', Packet_id = '|| to_char(p_qty_tol)
              ||', Fundscheck mode = '|| to_char(p_qty_rec_tol)
              ||', Partial_reserv_flag = '|| to_char(p_max_qty_ord_tol)
        ||', Max QTY REC Tol = '|| to_char(p_max_qty_rec_tol));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Execute_Matched_Checks;


/*============================================================================
 |  PUBLIC PROCEDURE  Get_PO_Closed_Code
 |
 |  DESCRIPTION:
 |              Procedure to retrieve the PO Closed Code for a given
 |              line_location_id after the Close_PO API has been  called.
 |
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Get_PO_Closed_Code(
              p_line_location_id    IN            NUMBER,
              p_po_closed_code      IN OUT NOCOPY VARCHAR2,
              p_calling_sequence    IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) := 'Get_PO_Closed_Code';
  l_curr_calling_sequence  VARCHAR2(2000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc ||'<-'||
                              p_calling_sequence;

  SELECT   PLL.closed_code
  INTO     p_po_closed_code
  FROM     po_line_locations PLL
  WHERE    line_location_id = p_line_location_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_po_closed_code := null;
    return;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_PO_Closed_Code;


/*============================================================================
 |  FUNCTION INV_HAS_HOLDS_OTHER_THAN
 |
 |  DESCRIPTION:
 |              Function that indicates whether an invoice has other holds
 |              other than the 2 hold_codes
 |
 *==========================================================================*/

FUNCTION Inv_Has_Holds_Other_Than(
             p_invoice_id       IN NUMBER,
             p_hold_code        IN VARCHAR2,
             p_hold_code2       IN VARCHAR2,
             p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS

  l_holds_exist            VARCHAR2(1);
  l_debug_loc              VARCHAR2(30) := 'Inv_Has_Holds_Other_Than';
  l_curr_calling_sequence  VARCHAR2(2000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  SELECT 'Y'
  INTO   l_holds_exist
  FROM   sys.dual
  WHERE  EXISTS (SELECT DISTINCT 'Invoice has unreleased holds'
                   FROM ap_holds AH
                  WHERE AH.invoice_id = p_invoice_id
                   AND AH.hold_lookup_code NOT IN (p_hold_code, p_hold_code2)
                   AND AH.release_lookup_code IS NULL);

  IF (l_holds_exist = 'Y') THEN
    return(TRUE);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return(FALSE);
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Hold Code1 = '|| p_hold_code
              ||', Hold Code2 = '|| p_hold_code2);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Inv_Has_Holds_Other_Than;

/*============================================================================
 |  FUNCTION    INV_HAS_UNRELEASED_HOLDS
 |
 |  DESCRIPTION:
 |              Function that indicates that an invoice has the two holds
 |              passed in and they haven't been released
 |
 *==========================================================================*/

FUNCTION Inv_Has_Unreleased_Holds(
             p_invoice_id       IN NUMBER,
             p_hold_code        IN VARCHAR2,
             p_hold_code2       IN VARCHAR2,
             p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS

  l_holds_exist            VARCHAR2(1) := 'N';
  l_debug_loc              VARCHAR2(30) := 'Inv_Has_Unreleased_Holds';
  l_curr_calling_sequence  VARCHAR2(2000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  SELECT 'Y'
    INTO  l_holds_exist
    FROM  sys.dual
   WHERE  EXISTS (SELECT DISTINCT 'Invoice has unreleased holds'
                    FROM ap_holds AH
                   WHERE AH.invoice_id = p_invoice_id
                     AND AH.hold_lookup_code IN (p_hold_code, p_hold_code2)
                     AND AH.release_lookup_code IS NULL);

  IF (l_holds_exist = 'Y') THEN
    return(TRUE);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return(FALSE);
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Hold Code1 = '|| p_hold_code
              ||', Hold Code2 = '|| p_hold_code2);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Inv_Has_Unreleased_Holds;


/*============================================================================
 |  PROCEDURE  GET_SHIPMENT_QTY_DELIVERED
 |
 |  DESCRIPTION:
 |              Procedure given a line_location_id retrieves the
 |              quantity_delivered for that shipment.
 |
 *==========================================================================*/

PROCEDURE Get_Shipment_Qty_Delivered(
              p_line_location_id    IN            NUMBER,
              p_qty_delivered       IN OUT NOCOPY NUMBER,
              p_calling_sequence    IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) := 'Get_Shipment_Qty_Delivered';
  l_curr_calling_sequence  VARCHAR2(2000);
BEGIN


  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  SELECT   ROUND(SUM(nvl(PD.quantity_delivered, 0)), 5)
  INTO     p_qty_delivered
  FROM     po_distributions_ap_v PD
  WHERE    PD.line_location_id = p_line_location_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_qty_delivered := NULL;
    return;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Shipment_Qty_Delivered;

/*============================================================================
 |  PROCEDURE  UPDATE_FINAL_MATCH_FLAG
 |
 |  DESCRIPTION:
 |              Procedure to update the final_match_flag to a given value for
 |              a invoice_distribution
 |
 *==========================================================================*/

--BugFix 3489536.Added the parameter p_invoice_id to the function call
PROCEDURE Update_Final_Match_Flag(
              p_line_location_id  IN NUMBER,
              p_final_match_flag  IN VARCHAR2,
              p_calling_sequence  IN VARCHAR2,
              p_invoice_id        IN NUMBER) IS

  l_debug_loc              VARCHAR2(30) := 'Update_Final_Match_Flag';
  l_curr_calling_sequence  VARCHAR2(2000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  UPDATE   ap_invoice_distributions AID
     SET   final_match_flag = p_final_match_flag
   WHERE   AID.invoice_id = p_invoice_id  -- Bug 3489536
   AND     AID.po_distribution_id IN
              (SELECT PD.po_distribution_id
               FROM   po_distributions_ap_v PD
               WHERE  line_location_id = p_line_location_id);

  UPDATE   ap_invoice_lines AIL
     SET   final_match_flag = p_final_match_flag
   WHERE   AIL.po_line_location_id = p_line_location_id
   AND     AIL.invoice_id=p_invoice_id;--bug5759169

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Update_Final_Match_Flag;


/*============================================================================
 |  PUBLIC PROCEDURE  EXEC_PO_FINAL_CLOSE
 |
 |  DESCRIPTION:
 |                Procedure that performs po final close on an invoice
 |                and places or releases 'CANT CLOSE PO' and/oR
 |                'CANT TRY PO CLOSE' holds depending on the condition.
 |
 |   PROGRAM FLOW
 |
 | FOR each 'CANT CLOSE PO' hold associated with distributions
 |     where final_match_flag <> 'Y' DO
 |     Release 'CANT CLOSE PO' hold for this match
 |    AND
 | FOR each match where final_match_flag = 'Y' and the sum of the
 |     distribution amounts is 0 (the final match has been reversed)
 |     and the invoice is on 'CANT TRY PO CLOSE' hold DO
 |     Release 'CANT TRY PO CLOSE' hold for this match
 | END FOR
 |
 | FOR each 'not-yet-done' final match on the invoice DO
 |     IF first_final_match = TRUE THEN
 |        first_final_match := FALSE
 |        at_least_one_final_match := TRUE
 |        IF the invoice has unreleased holds (other than either
 |                                         of the 2 holds above) THEN
 |           IF the invoice doesn't have any unreleased
 |                                         'CANT CLOSE PO' or
 |                             'CANT TRY PO CLOSE' holds THEN
 |                 Invoice should have 'CANT TRY PO CLOSE' hold
 |           END IF
 |             Break out of FOR loop
 |       END IF
 |     END IF
 |     Get quantity delivered for this PO shipment
 |     IF ((accrue_on_receipt_flag = 'N') OR
 |           (quantity_delivered >= quantity_received)) THEN
 |         IF call to PO Final Close returns failure THEN
 |             Raise Exception
 |         END IF;
 |         IF the Final Close failed THEN
 |           Invoice should be on 'CANT CLOSE PO' hold
 |              for this match,
 |         ELSE (PO Final Close succeeded)
 |             Get the PO closed code for this shipment
 |             IF closed_code = 'FINALLY CLOSED' THEN
 |               Update final_match_flag to 'D' for
 |               ALL invoice distributions matched to
 |                this PO shipment
 |             ELSE (closed_code <> 'FINALLY CLOSED')
 |               Raise Exception
 |             END IF
 |          END IF
 |     ELSE (quantity_delivered < quantity_received)
 |         Invoice should be on 'CANT TRY PO CLOSE' hold
 |   Exit Loop;
 |     END IF
 |
 |     Process Inv Hold Status for 'CANT CLOSE PO' hold - place a hold if
 |     condition exists and this invoice shipment match doesn't already have
 |     hold, or release if invoice has the hold and contiton doesn't exists.
 |
 | END LOOP;
 |
 | IF at_least_one_final_match == FALSE THEN
 |   Invoice shouldn't be on 'CANT TRY PO CLOSE' hold
 | END IF
 |
 | Process Invoice Hold Status for 'CANT TRY PO CLOSE' hold - place a hold if
 | condition exists and this invoice doesn't already have the hold, or release
 | the hold if invoice has the hold and condition doesn't exist.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Exec_PO_Final_Close(
              p_invoice_id        IN            NUMBER,
              p_system_user       IN            NUMBER,
              p_conc_flag         IN            VARCHAR2,
              p_holds             IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_holds_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count     IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence  IN            VARCHAR2) IS

   /*-----------------------------------------------------------------+
    |  1. Select each 'CANT CLOSE PO' hold associated with            |
    |     distributions where final_match_flag <> 'Y'                 |
    |  2. SELECT each match where final_match_flag = 'Y' and the sum  |
    |     of the distribution amount is 0                             |
    |     (final match has been reversed ) and the invoice is on      |
    |     'CANT TRY PO CLOSE' hold  - To release                      |
    +-----------------------------------------------------------------*/

  CURSOR Final_Match_Release_Cur IS
  SELECT PD.line_location_id,
         'CANT CLOSE PO'
    FROM ap_invoice_distributions AID,
         ap_holds AH,
         po_distributions_ap_v PD,
         po_line_locations PLL                                                             --Bug 3489536
   WHERE AH.invoice_id = p_invoice_id
     AND AH.hold_lookup_code = 'CANT CLOSE PO'
     AND AH.release_lookup_code IS NULL
     AND AH.invoice_id = AID.invoice_id
     AND AID.po_distribution_id = PD.po_distribution_id
     AND PLL.line_location_id   = PD.line_location_id                                      --Bug 3489536
     AND decode(PLL.final_match_flag, 'Y', 'D', NVL(AID.final_match_flag, 'N')) <> 'Y'     --Bug 3489536
     -- AND NVL(AID.final_match_flag, 'N') <> 'Y'--3489536
    GROUP BY PD.line_location_id
  UNION
  SELECT  PD.line_location_id,
          'CANT TRY PO CLOSE'
    FROM  ap_invoice_distributions AID,
          ap_holds AH,
          po_distributions_ap_v PD,
         po_line_locations PLL                                                             --Bug 3489536
   WHERE  AH.invoice_id = p_invoice_id
     AND  AH.hold_lookup_code = 'CANT TRY PO CLOSE'
     AND  AH.release_lookup_code IS NULL
     AND  AH.invoice_id = AID.invoice_id
     AND  AID.po_distribution_id = PD.po_distribution_id
     AND  AID.final_match_flag = 'Y'
     AND  PLL.line_location_id   = PD.line_location_id                                      --Bug 3489536
     AND  decode(PLL.final_match_flag, 'Y', 'D', NVL(AID.final_match_flag, 'N')) = 'Y'      --Bug 3489536
     GROUP BY  PD.line_location_id
     HAVING    SUM(AID.amount) = 0;

-------------------------------------------------------
-- Select each match with a not-yet-done Final Match --
-------------------------------------------------------

  CURSOR Final_Match_Cur IS
  SELECT PLL.line_location_id,
         PLL.po_line_id,
         ROUND(NVL(PLL.quantity_received, 0), 5),
         DECODE(PH.type_lookup_code, 'STANDARD', 'PO', 'RELEASE'),
         DECODE(PD.po_release_id, NULL, PH.type_lookup_code,
                PR.release_type),
         NVL(PLL.accrue_on_receipt_flag, 'N'),
         DECODE(PD.po_release_id, NULL, PD.po_header_id,
                PD.po_release_id),
         PH.segment1,
         MAX(aid.accounting_date) Accounting_date
    FROM po_distributions_ap_v PD,
         ap_invoice_distributions AID,
         po_line_locations PLL,
         po_headers PH,
         po_releases PR
   WHERE AID.invoice_id = p_invoice_id
     AND AID.final_match_flag = 'Y'
     AND AID.po_distribution_id = PD.po_distribution_id
     AND PD.line_location_id = PLL.line_location_id
     AND PD.po_release_id = PR.po_release_id(+)
     AND PLL.po_header_id = PH.po_header_id
     AND decode(PLL.final_match_flag, 'Y', 'D', NVL(AID.final_match_flag, 'N')) = 'Y'     --Bug 3489536
     -- Bug 5441016. made the last condition to be = , was <> before
     GROUP BY  PLL.line_location_id,
               PLL.po_line_id,
               ROUND(NVL(PLL.quantity_received, 0), 5),
               DECODE(PH.type_lookup_code, 'STANDARD', 'PO', 'RELEASE'),
               DECODE(PD.po_release_id, NULL, PH.type_lookup_code,
                      PR.release_type),
               NVL(PLL.accrue_on_receipt_flag, 'N'),
               DECODE(PD.po_release_id, NULL, PD.po_header_id,
                      PD.po_release_id),
               PH.segment1
     HAVING    SUM(AID.amount) <> 0;


  l_line_location_id            NUMBER(15);
  l_hold_code                   VARCHAR2(25);
  l_cant_po_close_exists        VARCHAR2(1);
  l_cant_try_po_close_exists    VARCHAR2(1);
  l_first_final_match           BOOLEAN := TRUE;
  l_at_least_one_final_match    BOOLEAN := FALSE;
  l_po_line_id                  NUMBER(15);
  l_qty_delivered               NUMBER;
  l_qty_received                NUMBER;
  l_po_doc_type                 VARCHAR2(25);
  l_po_sub_type                 VARCHAR2(25);
  l_accrue_on_receipt_flag      VARCHAR2(1);
  l_po_header_id                VARCHAR2(15);
  l_return_code                 VARCHAR2(30);
  l_po_num                      VARCHAR2(20);
  l_po_closed_code              VARCHAR2(30);
  l_action                      VARCHAR2(25);
  l_debug_loc                   VARCHAR2(30) := 'Exec_PO_Final_Close';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(100);
  l_inv_accounting_date         DATE;
  error                         EXCEPTION;

 -- Start Bug 3489536
  l_ret_status                  VARCHAR2(100);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(4000);
  l_po_line_loc_tab             PO_TBL_NUMBER;
  l_po_api_exc                  EXCEPTION;
  -- End Bug 3489536

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  IF ( AP_APPROVAL_PKG.g_debug_mode = 'Y' ) THEN
    g_debug_mode := 'Y';
  END IF;

  l_cant_try_po_close_exists := 'N';
  l_action := 'FINALLY CLOSE';

  -----------------------------------------------
  l_debug_info := 'Open Final_Match_Release_Cur';
  -----------------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  OPEN Final_Match_Release_Cur;
  LOOP

    ------------------------------------------------
    l_debug_info := 'Fetch Final_Match_Release_Cur';
    ------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    FETCH Final_Match_Release_Cur
     INTO l_line_location_id,
          l_hold_code;
    EXIT WHEN Final_Match_Release_Cur%NOTFOUND;

    -------------------------------------------------------------------------
    -- Release 'CANT PO CLOSE' or 'CANT TRY PO CLOSE' hold for this match  --
    -------------------------------------------------------------------------
    AP_APPROVAL_PKG.Release_Hold(
            p_invoice_id,
            l_line_location_id,
            '', -- rcv_transaction_id
            l_hold_code,
            p_holds,
            p_release_count,
            l_curr_calling_sequence);
  END LOOP;
  CLOSE Final_Match_Release_Cur;


  -----------------------------------------
  l_debug_info := 'Open Final_Match_Cur';
  -----------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  OPEN Final_Match_Cur;
  LOOP

    l_cant_po_close_exists := 'N';
    ---------------------------------------
    l_debug_info := 'Fetch Final_Match_Cur';
    ---------------------------------------

    Fetch Final_Match_Cur
     INTO l_line_location_id,
          l_po_line_id,
          l_qty_received,
          l_po_doc_type,
          l_po_sub_type,
          l_accrue_on_receipt_flag,
          l_po_header_id,
          l_po_num,
          l_inv_accounting_date;
    EXIT WHEN Final_Match_Cur%NOTFOUND;

   ------------------------------------------------------------
   --  FOR each 'not-yet-done' final match on the invoice DO --
   ------------------------------------------------------------

    IF (l_first_final_match) THEN
      l_first_final_match := FALSE;
      l_at_least_one_final_match := TRUE;

      IF ( Inv_Has_Holds_Other_Than(
               p_invoice_id,
               'CANT CLOSE PO',
               'CANT TRY PO CLOSE',
               l_curr_calling_sequence)) THEN
        l_cant_try_po_close_exists := 'Y';
        EXIT; -- drop out of the loop
      END IF;
    END IF; -- l_first_final_match = TRUE --

    ------------------------------------------------
    l_debug_info := 'Start Final Match Processing';
    ------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    Get_Shipment_Qty_Delivered(
        l_line_location_id,
        l_qty_delivered,
        l_curr_calling_sequence);

    IF ( (l_accrue_on_receipt_flag = 'N') OR
         (l_qty_delivered >= l_qty_received) ) THEN

      --------------------------------------------------------
      -- Not accrue_on_receipt and l_quantity_delivered >=  --
      -- l_quantity_received so ...                         --
      --------------------------------------------------------
      l_debug_info := 'Call PO Close API';
      ------------------------------------

 -- BUG 3486887 : Added parameter p_origin_doc_id=> p_invoice_id in Close_PO()

      IF (g_debug_mode = 'Y') THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (NOT(PO_ACTIONS.Close_PO(
                   p_docid        => l_po_header_id,
                   p_doctyp       => l_po_doc_type,
                   p_docsubtyp    => l_po_sub_type,
                   p_lineid       => l_po_line_id,
                   p_shipid       => l_line_location_id,
                   p_action       => l_action,
                   p_reason       => NULL,
                   p_calling_mode => 'AP',
                   p_conc_flag    => p_conc_flag,
                   p_return_code  => l_return_code,
                   p_auto_close   => 'N',
                   p_action_date  => l_inv_accounting_date,
                   p_origin_doc_id=> p_invoice_id)))
         THEN APP_EXCEPTION.Raise_Exception;
      END IF;

      -----------------------------------------------
      l_debug_info := 'Process PO Close retrun code';
      -----------------------------------------------
      IF (g_debug_mode = 'Y') THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (l_return_code IN ('SUBMISSION_FAILED', 'STATE_FAILED')) THEN

        -------------------------------------------------
        l_debug_info := 'PO Closed with failure';
        -------------------------------------------------
        IF (g_debug_mode = 'Y') THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        l_cant_po_close_exists := 'Y';
      ELSE
        -------------------------------------------------
        l_debug_info := 'Get PO Closed Code after success';
        -------------------------------------------------
        IF (g_debug_mode = 'Y') THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        Get_PO_Closed_Code(
            l_line_location_id,
            l_po_closed_code,
            l_curr_calling_sequence);

        IF (l_po_closed_code = 'FINALLY CLOSED') THEN
          -------------------------------------------------------------
          l_debug_info := 'Update Inv Dist/Line Final_Match_Flag to D';
          -------------------------------------------------------------
          IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
          END IF;

            -- Start Bug 3489536

             l_po_line_loc_tab := po_tbl_number();
             l_po_line_loc_tab.extend;
             l_po_line_loc_tab(l_po_line_loc_tab.last) := l_line_location_id;

 --bug 7696098 removed the quotes in  p_api_version => '1.0'
             PO_AP_INVOICE_MATCH_GRP.set_final_match_flag
                                (p_api_version          => 1.0,
                                 p_entity_type          => 'PO_LINE_LOCATIONS',
                                 p_entity_id_tbl        => l_po_line_loc_tab,
                                 p_final_match_flag     => 'Y',
                                 p_init_msg_list        => FND_API.G_FALSE ,
                                 p_commit               => FND_API.G_FALSE ,
                                 x_ret_status           => l_ret_status,
                                 x_msg_count            => l_msg_count,
                                 x_msg_data             => l_msg_data);

             IF l_ret_status = FND_API.G_RET_STS_SUCCESS THEN


               Update_Final_Match_Flag(l_line_location_id, 'D',
                                             l_curr_calling_sequence, p_invoice_id);

             ELSE

                l_cant_po_close_exists := 'Y';

             END IF;

             -- End Bug 3489536

        ELSE
          -------------------------------------------------------------
          l_debug_info := 'Error l_po_closed_code not finally closed';
          -------------------------------------------------------------
          IF (g_debug_mode = 'Y') THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
          END IF;

          Raise Error;

        END IF; -- l_po_closed_code <> 'FINALLY CLOSED' --
      END IF; -- PO Final Close Succeeded --

    ELSIF ( l_qty_delivered < l_qty_received ) THEN

      ------------------------------------------------------------
      -- Quantity_delivered < quantity_received so place inv on --
      -- CANT TRY PO CLOSE hold                                 --
      ------------------------------------------------------------
      l_cant_try_po_close_exists := 'Y';

      EXIT;  -- drop out of loop

    END IF;

    --------------------------------------------------------------
    l_debug_info := 'Process the CANT CLOSE PO hold status';
    --------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    AP_APPROVAL_PKG.Process_Inv_Hold_Status(
            p_invoice_id,
            l_line_location_id,
            null,
            'CANT CLOSE PO',
            l_cant_po_close_exists,
            null,
            p_system_user,
            p_holds,
            p_holds_count,
            p_release_count,
            p_calling_sequence);

  END LOOP;

  ----------------------------------------
  l_debug_info := 'CLOSE Final_Match_Cur';
  ----------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  CLOSE Final_Match_Cur;

  IF (NOT l_at_least_one_final_match) THEN

    l_cant_try_po_close_exists := 'N';

  END IF;

  ------------------------------------------------------------------------
  l_debug_info := 'Process CANT TRY PO CLOSE hold status for the invoice';
  ------------------------------------------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  AP_APPROVAL_PKG.Process_Inv_Hold_Status(
          p_invoice_id,
          null,
          null,
          'CANT TRY PO CLOSE',
          l_cant_try_po_close_exists,
          null,
          p_system_user,
          p_holds,
          p_holds_count,
          p_release_count,
          p_calling_sequence);

EXCEPTION
  WHEN Error THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Exec_PO_Final_Close;


/*============================================================================
 |  PROCEDURE  CHECK_RECEIPT_EXCEPTION
 |
 |  DESCRIPTION:
 |               For a given invoice shipment match check if there should be a
 |               'RECEIPT EXCEPTION' hold and place or release the hold
 |               depending on the conditon.
 |
 *==========================================================================*/

PROCEDURE Check_Receipt_Exception(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_match_option        IN            VARCHAR2,
              p_rcv_transaction_id  IN            NUMBER,
              p_system_user         IN            NUMBER,
              p_holds               IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2) IS

  l_rec_exception_exists   VARCHAR2(1) := 'N';
  l_rec_exception_count    NUMBER := 0;
  l_debug_loc              VARCHAR2(30) := 'Check_Recipt_Exception';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(100);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  IF g_debug_mode = 'Y' THEN
    l_debug_info := 'Check if Rec Exception Exists';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info);
  END IF;

   /*-----------------------------------------------------------------+
    | Query is done at invoice line level for release 11.6 trying to  |
    | gain a bit performance. Query was done at distribution level    |
    | for release 11.5                                                |
    +-----------------------------------------------------------------*/

  IF (p_match_option = 'P') THEN
    BEGIN
      SELECT count(*)
      INTO   l_rec_exception_count
      FROM   rcv_transactions rt,
             ap_invoice_lines ail
      WHERE  rt.receipt_exception_flag = 'Y'
      AND    rt.transaction_type = 'RECEIVE'
      AND    rt.po_line_location_id = ail.po_line_location_id
      AND    ail.po_line_location_id = p_line_location_id
      AND    ail.invoice_id = p_invoice_id ;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          null;
    END;
    IF ( l_rec_exception_count > 0 ) THEN
      l_rec_exception_exists := 'y';
    END IF;
  ELSIF (p_match_option = 'R') THEN
    BEGIN
      SELECT 'Y'
        INTO l_rec_exception_exists
        FROM rcv_transactions rtxn
       WHERE rtxn.transaction_id = p_rcv_transaction_id
         AND rtxn.receipt_exception_flag = 'Y';

    EXCEPTION
      WHEN NO_DATA_FOUND Then
        null;
    END;
  END IF;

  IF g_debug_mode = 'Y' THEN
    l_debug_info := 'Process Invoice Hold Status for REC EXCEPTION';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info);
  END IF;

  AP_APPROVAL_PKG.Process_Inv_Hold_Status(
          p_invoice_id,
          p_line_location_id,
          p_rcv_transaction_id,
          'REC EXCEPTION',
          l_rec_exception_exists,
          null,
          p_system_user,
          p_holds,
          p_holds_count,
          p_release_count,
          l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Line Location Id = '|| to_char(p_line_location_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Receipt_Exception;


/*============================================================================
 |  PROCEDURE  CHECK_PRICE
 |
 |  DESCRIPTION:
 |
 |     For a given invoice shipment match, check for price error
 |     and place or release the 'PRICE' hold depending on the condition.
 |     1. Try to determine if the passed in invoice is base match only or it
 |        is trying to correct some other invoices.
 |     2. if no correctings get involved, we call function to check price of
 |        this invoice only
 |     3. if there are correctings, we need to loop through a list of
 |        invoices this invoice is trying to correct, and check the price of
 |        those invoice one by one to see if any hold needs to be put as a
 |        result of this passed in invoice.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Check_Price(
          p_invoice_id            IN NUMBER,
          p_line_location_id      IN NUMBER,
          p_rcv_transaction_id    IN NUMBER,
          p_match_option          IN VARCHAR2,
          p_txn_uom               IN VARCHAR2,
          p_po_uom                IN VARCHAR2,
          p_item_id               IN NUMBER,
          p_invoice_currency_code IN VARCHAR2,
          p_po_unit_price         IN NUMBER,
          p_price_tolerance       IN NUMBER,
          p_system_user           IN NUMBER,
          p_holds                 IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
          p_holds_count           IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
          p_release_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
          p_calling_sequence      IN VARCHAR2) IS


  l_price_error_exists          VARCHAR2(1):='N';
  l_debug_loc                   VARCHAR2(30) := 'Check_Price';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(100);

  l_correction_count            NUMBER;
  l_check_other_inv_price_flag  VARCHAR2(1);
  l_base_invoice_id             NUMBER;

   /*-----------------------------------------------------------------+
    |  A list of invoices this invoice  is trying to correct          |
    |  We are considering both qty correction and price correction    |
    |  because both will affect the average price for the AMOUNT part |
    +-----------------------------------------------------------------*/

  CURSOR corrected_invoices IS
  SELECT distinct corrected_inv_id
    FROM ap_invoice_lines AIL
   WHERE AIL.invoice_id = p_invoice_id
     AND (  ( AIL.po_line_location_id is not null and
              AIL.po_line_location_id = p_line_location_id )
          OR( AIL.rcv_transaction_id is not null and
              AIL.rcv_transaction_id = p_rcv_transaction_id) )
     AND AIL.corrected_inv_id is not null
     AND AIL.corrected_inv_id <> p_invoice_id;

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  ---------------------------------------------------------
  l_debug_info := 'Check if invoice is a price correction';
  ---------------------------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

   /*-----------------------------------------------------------------+
    |  To check if the match is a base match only or has corrections  |
    |  that trying to correct other invoices which not includes       |
    |  itself.                                                        |
    |  Qty correction or price correction both affect average price   |
   +------------------------------------------------------------------*/

  SELECT count(*)
    INTO l_correction_count
    FROM ap_invoice_lines AIL
   WHERE AIL.invoice_id = p_invoice_id
     AND po_line_location_id = p_line_location_id
     AND corrected_inv_id is not null
     AND corrected_inv_id <> p_invoice_id;

  IF ( l_correction_count = 0 ) THEN
    l_check_other_inv_price_flag := 'N';
  ELSE
    l_check_other_inv_price_flag := 'Y';
  END IF;

   /*-----------------------------------------------------------------+
    |  If it is a base match only or a base match with 1 or more      |
    |  correction lines. It does not have any correcting lines which  |
    |  try to correct other invoices. In this case, price check is    |
    |  needed to be done only to this invoice ( with p_invoice_id )   |
    +-----------------------------------------------------------------*/

    IF l_check_other_inv_price_flag = 'N' THEN

       CHECK_AVERAGE_PRICE(
             p_invoice_id  ,
             p_line_location_id  ,
             p_match_option,
             p_txn_uom ,
             p_po_uom ,
             P_item_id,
             p_price_tolerance ,
             p_po_unit_price  ,
             p_invoice_currency_code ,
             l_price_error_exists,
             p_calling_sequence);

    END IF;

   /*-----------------------------------------------------------------+
    |  If it is a match with correctings that are trying to correct   |
    |  other invoice. In this case, a list of invoices are affected   |
    |  by this invoice. We need to check if the average price of the  |
    |  corrected invoices which are matching to this po shipment      |
    |  exceeded price tolerance. If yes, the hold needs to be put on  |
    |  originating invoice                                            |
    +-----------------------------------------------------------------*/

  IF ( l_check_other_inv_price_flag = 'Y'  and
       l_price_error_exists = 'N' ) THEN

    OPEN corrected_invoices;
    LOOP
      FETCH corrected_invoices
       INTO l_base_invoice_id;
       EXIT WHEN corrected_invoices%NOTFOUND OR l_price_error_exists = 'Y';

      CHECK_AVERAGE_PRICE(
            l_base_invoice_id,
            p_line_location_id,
            p_match_option,
            p_txn_uom ,
            p_po_uom ,
            p_item_id,
            p_price_tolerance,
            p_po_unit_price,
            p_invoice_currency_code,
            l_price_error_exists,
            p_calling_sequence);
    END LOOP;
    CLOSE corrected_invoices;
  END IF;

  --------------------------------------
  l_debug_info := 'Process PRICE hold ';
  --------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  AP_APPROVAL_PKG.Process_Inv_Hold_Status(
                p_invoice_id,
                p_line_location_id,
                p_rcv_transaction_id,
                'PRICE',
                l_price_error_exists,
                null,
                p_system_user,
                p_holds,
                p_holds_count,
                p_release_count,
                l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Line_Location_id = '|| to_char(p_line_location_id)
              ||', Inv_Currency_Code= '|| p_invoice_currency_code
              ||', rcv_transaction_id = '|| to_char(p_rcv_transaction_id)
              ||', PO_Unit_Price = '|| to_char(p_po_unit_price)
              ||', Price_Tolerance = '|| to_char(p_price_tolerance));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( corrected_invoices%ISOPEN ) THEN
      CLOSE corrected_invoices;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Price;


/*============================================================================
 |  PROCEDURE CHECK_AVERAGE_PRICE
 |
 |  DESCRIPTION
 |      Procedure to calculate the average price for a po matched invoice.
 |
 |  PROGRAM FLOW
 |      It sums up all the base match without any correction to other invoices
 |      and the lines that are trying to correct it.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      1. Ensure that we don't divide by zero. if l_sum_qty_invoiced is
 |        zero we still need to place a hold if there is an outstanding
 |        amount left that is matched. this could happen when an invoice
 |        is po matched a credit memo matched to the invoice backs out
 |        the quantity and a price correction is entered against the
 |        invoice for a positive amount, in this case the total quantity
 |        is zero but a price hold should still be placed if using price
 |        tolerances.
 |
 |      2. calculate at invoice line level
 |
 |      3. We might have a situation that two invoice lines match to different
 |         receipts which are against the same PO shipment. We need to be
 |         careful when try to do the UOM conversion. Although we only
 |         concern the po shipment when we calculate the average price.
 |
 |      4. PRICE CORRECTION will not affect the total Quantity Invoiced
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE CHECK_AVERAGE_PRICE(
              p_invoice_id            IN            NUMBER,
              p_line_location_id      IN            NUMBER,
              p_match_option          IN            VARCHAR2,
              p_txn_uom               IN            VARCHAR2,
              p_po_uom                IN            VARCHAR2,
              p_item_id               IN            NUMBER,
              p_price_tolerance       IN            NUMBER ,
              p_po_unit_price         IN            NUMBER ,
              p_invoice_currency_code IN            VARCHAR2,
              p_price_error_exists    IN OUT NOCOPY VARCHAR2,
              p_calling_sequence      IN            VARCHAR2) IS

  l_sum_pc_inv_amount     NUMBER;
  l_sum_qty_invoiced      NUMBER;
  l_avg_price             NUMBER ;
  l_qty_ratio             NUMBER;
  l_total_price_variance  NUMBER;
  l_debug_info            varchar2(100);
  l_curr_calling_sequence varchar2(2000);

BEGIN

  l_curr_calling_sequence := 'CHECK_AVERAGE_PRICE <- '||
                              p_calling_sequence;

  ---------------------------------------------------------------
  l_debug_info := 'calculate average price for a invoice ';
  ---------------------------------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF ( p_match_option = 'P' ) THEN

     ---------------------------------------------------------------
     l_debug_info := 'CHECK_AVERAGE_PRICE <- match to PO';
     ---------------------------------------------------------------

     IF (g_debug_mode = 'Y') THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

    SELECT sum( decode( nvl(AIL.unit_price,0) * nvl(AIL.quantity_invoiced,0),
                      0, nvl(AIL.amount, 0),
                      nvl(AIL.unit_price,0) * nvl(AIL.quantity_invoiced,0) ) ),
           sum( decode( AIL.match_type, 'PRICE_CORRECTION', 0,
                        nvl(AIL.quantity_invoiced,0)) )
    INTO l_sum_pc_inv_amount,
         l_sum_qty_invoiced
    FROM ap_invoice_lines AIL
    WHERE AIL.po_line_location_id  = p_line_location_id
    AND  ( AIL.corrected_inv_id = p_invoice_id
          OR (AIL.invoice_id = p_invoice_id and
              AIL.corrected_inv_id is null) )
         and nvl(AIL.discarded_flag,'N') = 'N'; --for the bug 6882864;

  ELSE
    ------------------------------------------------------------------
     l_debug_info := 'Check_Average_Price - get qty ratio match to R';
    ------------------------------------------------------------------

    IF (p_txn_uom <> p_po_uom) THEN
      l_qty_ratio := po_uom_s.po_uom_convert(
                           p_txn_uom,
                           p_po_uom,
                           p_item_id);
    ELSE
      l_qty_ratio := 1;
    END IF;

     ---------------------------------------------------------------
     l_debug_info := 'CHECK_AVERAGE_PRICE <- match to receipt';
     ---------------------------------------------------------------

     IF (g_debug_mode = 'Y') THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

      -- bug8518421
     SELECT sum (decode(nvl(AIL.unit_price,0) * nvl(AIL.quantity_invoiced,0),
                       0, NVL(AIL.amount, 0),
                       nvl(AIL.unit_price,0) * nvl(AIL.quantity_invoiced,0)
                      )
                ),
           sum (decode( AIL.match_type, 'PRICE_CORRECTION', 0,
                           (nvl(AIL.quantity_invoiced,0) * l_qty_ratio)
                       )
               )
    INTO l_sum_pc_inv_amount,
         l_sum_qty_invoiced
    FROM ap_invoice_lines AIL
    WHERE AIL.po_line_location_id  = p_line_location_id
    AND  ( AIL.corrected_inv_id = p_invoice_id
           OR (AIL.invoice_id = p_invoice_id and
               AIL.corrected_inv_id is null) )
    AND nvl(AIL.discarded_flag,'N') = 'N';   --for the bug 6908761

  END IF;

  IF (l_sum_qty_invoiced is null and l_sum_pc_inv_amount is null)   THEN -- Bug 7161683
    p_price_error_exists := 'N';
    return;
  END IF;


  IF (l_sum_qty_invoiced <> 0) THEN
    l_avg_price := l_sum_pc_inv_amount / l_sum_qty_invoiced ;
  ELSIF (l_sum_qty_invoiced = 0 and l_sum_pc_inv_amount = 0) THEN
    l_avg_price := 0;
  ELSIF (p_price_tolerance is not null) THEN
    p_price_error_exists := 'Y';
  END IF;

  IF (l_sum_qty_invoiced > 0) THEN
  /* Start of fix for bug8474680 */
  /*  l_total_price_variance := nvl(ap_utilities_pkg.ap_round_currency(
                                      l_avg_price -
                                      (p_price_tolerance * p_po_unit_price),
                                       p_invoice_currency_code), 0); */
   l_total_price_variance := nvl(l_avg_price -
                              (p_price_tolerance * p_po_unit_price),0);
 /*End of fix for bug8474680 */
  ELSE
    l_total_price_variance := 0;
  END IF;

  IF ((l_total_price_variance > 0) AND (p_price_tolerance IS NOT NULL)) THEN
    p_price_error_exists := 'Y';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Line_Location_id = '|| to_char(p_line_location_id)
              ||', Inv_Currency_Code= '|| p_invoice_currency_code
              ||', PO_Unit_Price = '|| to_char(p_po_unit_price)
              ||', Price_Tolerance = '|| to_char(p_price_tolerance));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END CHECK_AVERAGE_PRICE;


/*============================================================================
 |  PROCEDURE CALC_TOTAL_SHIPMENT_QTY_BILLED
 |
 |  DESCRIPTION:
 |    Procedure given an invoice id and line_location_id calculateds the
 |    the quantity billed affected by this invoice via matching to the given
 |    shipment. If the net Quantity billed via this invoice is 0, means no
 |    net effect from this invoice, just return the total quantity billed of
 |    the system that currently recorded.
 |
 |  PARAMETERS
 |    p_invoice_id - The invoice being validated
 |    p_line_location_id - po shimpent line
 |    p_match_option - 'R' or 'P'
 |    p_rcv_transaction_id - for receipt matching
 |    p_qty_billed - out for the total qty billed
 |    p_calling_sequence - calling sequence for debug
 |
 |  PROGRAM FLOW
 |    It determine if the invoice line is Quantity correction or Regular base
 |    match. Then it will calculate the total quantiy billed. If it is not a
 |    correction, in case of the sum of its base match sum up to 0, total qty
 |    billed by this invoice is 0. Otherwise, it should be the sum of any
 |    invoice that has been matched to this shipment. It applies to both PO
 |    match or receipt match.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    Quantity Billed via this invoice = 0 MEANS
 |      1) Invoice base matches against shipment + any QTY corrections
 |         against this base matches is 0  and
 |      2) Invoice QTY Corrections + Base Matches and its other corrections
 |         against this shipment is 0
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Calc_Total_Shipment_Qty_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_qty_billed         IN OUT NOCOPY NUMBER,
        p_invoice_type_lookup_code IN      VARCHAR2,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) := 'Calc_Total_Shipment_Qty_Billed';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_inv_qty_billed         NUMBER;
  l_corrected_invoice_id   NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

   Calc_Shipment_Qty_Billed(
       p_invoice_id,
       p_line_location_id,
       p_match_option,
       p_rcv_transaction_id,
       l_inv_qty_billed,
       l_curr_calling_sequence);
/*
   SELECT ROUND(DECODE(l_inv_qty_billed,0,
                       0, NVL(DECODE(p_invoice_type_lookup_code,'PREPAYMENT',
                      PLL.quantity_financed,PLL.quantity_billed)
                  ,0)
          )
    ,5)
     INTO p_qty_billed
     FROM po_line_locations PLL
    WHERE PLL.line_location_id = p_line_location_id;
*/

   SELECT ROUND(DECODE(l_inv_qty_billed,0,
                       0, (nvl(pll.quantity_financed,0) + nvl(pll.quantity_billed,0) - nvl(pll.quantity_recouped,0))
                      )
                ,5)
     INTO p_qty_billed
     FROM po_line_locations PLL
    WHERE PLL.line_location_id = p_line_location_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Dist_line_num = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Total_Shipment_Qty_Billed;


/*============================================================================
 |  PROCEDURE CALC_SHIPMENT_QTY_BILLED
 |
 |  DESCRIPTION:
 |    Procedure given an invoice id and line_location_id calculates the
 |    quantity billed between this match.
 |
 |  PARAMETERS
 |    p_invoice_id - The invoice being validated
 |    p_line_location_id - po shimpent line
 |    p_match_option - 'R' or 'P'
 |    p_rcv_transaction_id - for receipt matching
 |    p_qty_billed - out for the total qty billed by this invoice
 |    p_calling_sequence - calling sequence for debug
 |
 |  PROGRAM FLOW
 |    It sums up the quantity billed via BASE MATCH of this invoice and all its
 |    quantity corrections to this invoice for a particular shipment;
 |    If there is an QUANTITY CORRECTION line exists in this invoice, we need
 |    to sum up the quantity billed via BASE MATCH and QUANTITY CORRECTION of all
 |    the invoices it was trying to correct for this shipment, plus the
 |    QUANTITY CORRECTION line of this invoce itself. Please note, there might
 |    a case that this invoice has one correcting line which is trying to correct
 |    itself, with our query, it will be included.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/


PROCEDURE Calc_Shipment_Qty_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_qty_billed         IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) := 'Calc_Shipment_Qty_Billed';
  l_curr_calling_sequence  VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

   /*-----------------------------------------------------------------+
    |  The Meaning fo the following query conditions indicates:-      |
    |    Query condition 1 - all the base match lines of this         |
    |                        invoice itself with p_invoice_id         |
    |    Query condition 2 - all the qty correction lines against this|
    |                        particular invoice itself (p_invoice_id) |
    |    Query condition 3 - all the base match lines of a list of    |
    |                        invoices that invoice with p_invoice_id  |
    |                        is trying to do quantity correction      |
    |    Query condition 4 - all the qty correction lines trying to   |
    |                        correct a list of invoices that invoice  |
    |                        with p_invoice_id is trying to do        |
    |                        quantity corrections                     |
    +-----------------------------------------------------------------*/

  IF (p_match_option = 'P') THEN


     SELECT nvl(trunc(sum(quantity_invoiced),5),0) --7021414
      INTO p_qty_billed
      FROM ap_invoice_lines L
     WHERE L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type = 'ITEM_TO_PO' )           -- query condition 1
            or (L.corrected_inv_id = p_invoice_id and
                L.match_type = 'QTY_CORRECTION')        -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.invoice_id = p_invoice_id
                                AND L2.po_line_location_id = p_line_location_id
                                AND L2.match_type = 'QTY_CORRECTION') and
                L.match_type = 'ITEM_TO_PO' )           -- query condition 3
            or ( L.corrected_inv_id IN
                            ( SELECT corrected_inv_id
                                FROM ap_invoice_lines L3
                               WHERE L3.invoice_id = p_invoice_id
                                 AND L3.po_line_location_id = p_line_location_id
                                 AND L3.match_type = 'QTY_CORRECTION') and
                L.match_type = 'QTY_CORRECTION' ) )   -- query condition 4
      AND nvl(L.discarded_flag,'N')='N'; --bug 7021414


  ELSIF (p_match_option = 'R') THEN


    SELECT nvl(trunc(sum(quantity_invoiced),5),0)
      INTO p_qty_billed
      FROM ap_invoice_lines L
     WHERE L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type = 'ITEM_TO_RECEIPT' )        -- query condition 1
            or (L.corrected_inv_id = p_invoice_id and
                L.match_type = 'QTY_CORRECTION')          -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.invoice_id = p_invoice_id
                                AND L2.po_line_location_id = p_line_location_id
                                AND L2.match_type = 'QTY_CORRECTION') and
                L.match_type = 'ITEM_TO_RECEIPT' )         -- query condition 3
            or (L.corrected_inv_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L3
                              WHERE L3.invoice_id = p_invoice_id
                                AND L3.po_line_location_id = p_line_location_id
                                AND L3.match_type = 'QTY_CORRECTION') and
                L.match_type = 'QTY_CORRECTION' ) )      -- query condition 4
       AND nvl(L.discarded_flag,'N')='N'; --bug 7021414

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', po_line_location_id = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Shipment_Qty_Billed;



/*============================================================================
 |  PROCEDURE CALC_TOTAL_SHIPMENT_AMT_BILLED
 |
 |  DESCRIPTION:
 |    Procedure given an invoice id and line_location_id calculateds the
 |    the amount billed affected by this invoice via matching to the given
 |    shipment. If the net Amount billed via this invoice is 0, means no
 |    net effect from this invoice, just return the total amount billed of
 |    the system that currently recorded.
 |
 |  PARAMETERS
 |    p_invoice_id - The invoice being validated
 |    p_line_location_id - po shimpent line
 |    p_match_option - 'R' or 'P'
 |    p_rcv_transaction_id - for receipt matching
 |    p_amt_billed - out for the total amt billed
 |    p_invoice_type_lookup_code - in for invoice_type
 |    p_calling_sequence - calling sequence for debug
 |
 |  PROGRAM FLOW
 |    It determine if the invoice line is Amount correction or Regular base
 |    match. Then it will calculate the total amount billed. If it is not a
 |    correction, in case of the sum of its base match sum up to 0, total amt
 |    billed by this invoice is 0. Otherwise, it should be the sum of any
 |    invoice that has been matched to this shipment. It applies to both PO
 |    match or receipt match.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    Amount Billed via this invoice = 0 MEANS
 |      1) Invoice base matches against shipment + any AMT corrections
 |         against this base matches is 0  and
 |      2) Invoice AMT Corrections + Base Matches and its other corrections
 |         against this shipment is 0
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  19-Apr-2005  Surekha Myadam    Created
 *==========================================================================*/

PROCEDURE Calc_Total_Shipment_Amt_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_amt_billed         IN OUT NOCOPY NUMBER,
        p_invoice_type_lookup_code IN      VARCHAR2,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) ;
  l_curr_calling_sequence  VARCHAR2(2000);
  l_inv_amt_billed         NUMBER;
  l_corrected_invoice_id   NUMBER;

BEGIN

  l_debug_loc := 'Calc_Total_Shipment_Qty_Billed';
  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

   Calc_Shipment_Amt_Billed(
       p_invoice_id,
       p_line_location_id,
       p_match_option,
       p_rcv_transaction_id,
       l_inv_amt_billed,
       l_curr_calling_sequence);
/*
   SELECT ROUND(DECODE(l_inv_amt_billed,0,
                       0, NVL(DECODE(p_invoice_type_lookup_code,'PREPAYMENT',
                      PLL.amount_financed,PLL.amount_billed)
                  ,0)
          )
    ,5)
     INTO p_amt_billed
     FROM po_line_locations PLL
    WHERE PLL.line_location_id = p_line_location_id;
*/

   SELECT ROUND(DECODE(l_inv_amt_billed,0,
                       0, (nvl(PLL.amount_financed,0) + nvl(PLL.amount_billed,0) - nvl(PLL.amount_recouped,0))
                      )
                ,5)
     INTO p_amt_billed
     FROM po_line_locations PLL
    WHERE PLL.line_location_id = p_line_location_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Dist_line_num = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Total_Shipment_Amt_Billed;


/*============================================================================
 |  PROCEDURE CALC_SHIPMENT_AMT_BILLED
 |
 |  DESCRIPTION:
 |    Procedure given an invoice id and line_location_id calculates the
 |    amount billed between this match.
 |
 |  PARAMETERS
 |    p_invoice_id - The invoice being validated
 |    p_line_location_id - po shimpent line
 |    p_match_option - 'R' or 'P'
 |    p_rcv_transaction_id - for receipt matching
 |    p_amt_billed - out for the total amt billed by this invoice
 |    p_calling_sequence - calling sequence for debug
 |
 |  PROGRAM FLOW
 |    It sums up the amount billed via BASE MATCH of this invoice and all its
 |    amount corrections to this invoice for a particular shipment;
 |    If there is an AMOUNT CORRECTION line exists in this invoice, we need
 |    to sum up the amount billed via BASE MATCH and AMOUNT CORRECTION of all
 |    the invoices it was trying to correct for this shipment, plus the
 |    AMOUNT CORRECTION line of this invoce itself. Please note, there might
 |    a case that this invoice has one correcting line which is trying to correct
 |    itself, with our query, it will be included.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 | 19-Apr-2005   Surekha Myadam    Created
 *===========================================================================*/
PROCEDURE Calc_Shipment_Amt_Billed(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rcv_transaction_id IN            NUMBER,
              p_amt_billed         IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) ;
  l_curr_calling_sequence  VARCHAR2(2000);

BEGIN

  l_debug_loc := 'Calc_Shipment_Amt_Billed';
  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

   /*-----------------------------------------------------------------+
    |  The Meaning fo the following query conditions indicates:-      |
    |    Query condition 1 - all the base match lines of this         |
    |                        invoice itself with p_invoice_id         |
    |    Query condition 2 - all the amt correction lines against this|
    |                        particular invoice itself (p_invoice_id) |
    |    Query condition 3 - all the base match lines of a list of    |
    |                        invoices that invoice with p_invoice_id  |
    |                        is trying to do amount correction        |
    |    Query condition 4 - all the amt correction lines trying to   |
    |                        correct a list of invoices that invoice  |
    |                        with p_invoice_id is trying to do        |
    |                        amount corrections                       |
    +-----------------------------------------------------------------*/

  IF (p_match_option = 'P') THEN


     SELECT trunc(sum(amount),5)
      INTO p_amt_billed
      FROM ap_invoice_lines L
     WHERE L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type = 'ITEM_TO_PO' )           -- query condition 1
            or (L.corrected_inv_id = p_invoice_id and
                L.match_type = 'AMOUNT_CORRECTION')        -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.invoice_id = p_invoice_id
                                AND L2.po_line_location_id = p_line_location_id
                                AND L2.match_type = 'AMOUNT_CORRECTION') and
                L.match_type = 'ITEM_TO_PO' )           -- query condition 3
            or ( L.corrected_inv_id IN
                            ( SELECT corrected_inv_id
                                FROM ap_invoice_lines L3
                               WHERE L3.invoice_id = p_invoice_id
                                 AND L3.po_line_location_id = p_line_location_id
                                 AND L3.match_type = 'AMOUNT_CORRECTION') and
                L.match_type = 'AMOUNT_CORRECTION' ) );   -- query condition 4


  ELSIF (p_match_option = 'R') THEN


    SELECT trunc(sum(amount),5)
      INTO p_amt_billed
      FROM ap_invoice_lines L
     WHERE L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type = 'ITEM_TO_RECEIPT' )        -- query condition 1
            or (L.corrected_inv_id = p_invoice_id and
                L.match_type = 'AMOUNT_CORRECTION')          -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.invoice_id = p_invoice_id
                                AND L2.po_line_location_id = p_line_location_id
                                AND L2.match_type = 'AMOUNT_CORRECTION') and
                L.match_type = 'ITEM_TO_RECEIPT' )         -- query condition 3
            or (L.corrected_inv_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L3
                              WHERE L3.invoice_id = p_invoice_id
                                AND L3.po_line_location_id = p_line_location_id
                                AND L3.match_type = 'AMOUNT_CORRECTION') and
                L.match_type = 'AMOUNT_CORRECTION' ) );      -- query condition 4

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', po_line_location_id = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Shipment_Amt_Billed;



/*============================================================================
 |  PROCEDURE  CALC_SHIP_TOTAL_TRX_AMT_VAR
 |
 |  DESCRIPTION:
 |                Procedure that given a shipment it calculates total amount
 |                invoiced against the shipment in transaction currency minus
 |                the valid po qty (ordered-cancelled) times its unit price.
 |
 |  PROGRAM FLOW
 |    It will calculate the total amount billed. If it is 0, return 0,
 |    Otherwise, it should be the sum of any invoice that has been matched
 |    to this shipment. It applies to both PO match or receipt match.
 |
 |  NOTES:
 |         It should all be in the same currency. since we can not do
 |         cross-curr matching.
 |        -----------------------------------------------------------------
 |        -- If the total matched to the shipment from this invoice      --
 |        -- is 0, then return with 0 since this invoice should not be   --
 |        -- placed on max shipment hold.                                --
 |        -- Otherwise, move on to calculating the full shipment amount  --
 |        -- transactional currency matched to this shipment.            --
 |        -----------------------------------------------------------------
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 *==========================================================================*/

PROCEDURE Calc_Ship_Total_Trx_Amt_Var(
             p_invoice_id         IN            NUMBER,
             p_line_location_id   IN            NUMBER,
             p_match_option       IN            VARCHAR2,
             p_po_price           IN            NUMBER,
             p_ship_amount        OUT NOCOPY    NUMBER, -- 3488259 (3110072)
             p_match_basis        IN            VARCHAR2,  -- Amount Based Matching
             p_ship_trx_amt_var   IN OUT NOCOPY NUMBER,
             p_calling_sequence   IN            VARCHAR2,
             p_org_id             IN            NUMBER) IS -- 5500101

  l_debug_loc                   VARCHAR2(30) := 'Calc_Ship_Total_Trx_Amt_Var';
  l_debug_info                  VARCHAR2(100);
  l_curr_calling_sequence       VARCHAR2(2000);
  l_po_total                    NUMBER;
  l_ship_trx_amt                NUMBER;
  l_freight_total               NUMBER; -- 3488259 (3110072)

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;
  --------------------------------------------------------
  l_debug_info := 'Calculate Shipment Total for the invoice';
  --------------------------------------------------------
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

   /*-----------------------------------------------------------------+
    |  Calculate the total shipment transaction amt billed by this    |
    |  invoice and its corrections. If it is 0, further check is      |
    |  not needed.                                                    |
    +-----------------------------------------------------------------*/

  Calc_Ship_Trx_Amt(
      p_invoice_id,
      p_line_location_id,
      p_match_option,
      l_ship_trx_amt,
      l_curr_calling_sequence);

  IF ( l_ship_trx_amt = 0  ) THEN
    -----------------------------------------------------------------
    l_debug_info := 'Calc_Ship_Total_Trx_Amt_Var->shipment amt is 0';
    -----------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;
    p_ship_trx_amt_var := 0;
  ELSE
    IF p_match_basis  = 'QUANTITY' THEN  -- Amount Based Matching
      SELECT DECODE(FC.minimum_accountable_unit, NULL,
                  ROUND(((NVL(PLL.quantity, 0) -
                          NVL(PLL.quantity_cancelled, 0)) * p_po_price),
                        FC.precision),
                  ROUND(((NVL(PLL.quantity, 0) -
                          NVL(PLL.quantity_cancelled, 0))* p_po_price)
                        / FC.minimum_accountable_unit)
                        * FC.minimum_accountable_unit)
      INTO   l_po_total
      FROM   fnd_currencies FC,
           po_line_locations PLL,
           po_headers PH
      WHERE  PLL.line_location_id = p_line_location_id
      AND   PH.po_header_id = PLL.po_header_id
      AND   FC.currency_code = PH.currency_code;

    ELSE  /* for match_basis 'AMOUNT' need to get amounts on po_shipments
         rather than multiplying quantity_invoiced and unit_price */

      SELECT DECODE(FC.minimum_accountable_unit, null,
                     ROUND((NVL(PLL.amount, 0) -
                             NVL(PLL.amount_cancelled, 0)),
                           FC.precision),
                     ROUND((NVL(PLL.amount, 0) -
                             NVL(PLL.amount_cancelled, 0))
                           / FC.minimum_accountable_unit)
                           * FC.minimum_accountable_unit)
      INTO   l_po_total
      FROM   fnd_currencies FC, po_line_locations PLL, po_headers PH
      WHERE  PLL.line_location_id = p_line_location_id
      AND    PH.po_header_id = PLL.po_header_id
      AND    FC.currency_code = PH.currency_code;

    END IF; --p_match_basis = 'QUANTITY'. AMount Based Matching

    --Contract Payments: Added the decode clause
    SELECT SUM(decode(PD.distribution_type,'PREPAYMENT',
              nvl(PD.amount_financed,0),
          nvl(PD.amount_billed,0)
         )
         )
    INTO   p_ship_trx_amt_var
    FROM   po_distributions_ap_v PD
    WHERE  PD.line_location_id = p_line_location_id;

    p_ship_trx_amt_var := p_ship_trx_amt_var - l_po_total;

  END IF;


  IF FV_INSTALL.Enabled(p_org_id) THEN -- 5500101

    BEGIN

     SELECT     nvl(sum(nvl(AIDF.amount,0)),0)
     INTO       l_freight_total
     FROM       ap_invoice_distributions AIDF,
                ap_invoice_distributions AIDI,
                po_distributions_all POD
     WHERE      AIDF.charge_applicable_to_dist_id = AIDI.invoice_distribution_id
     AND        AIDF.line_type_lookup_code = 'FREIGHT'
     AND        AIDI.line_type_lookup_code = 'ITEM'
     AND        AIDI.po_distribution_id = POD.po_distribution_id
     AND        POD.line_location_id = p_line_location_id;

    EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_freight_total := 0;
         WHEN OTHERS THEN
              l_freight_total := 0;

    END;

     p_ship_trx_amt_var := p_ship_trx_amt_var + l_freight_total;
     p_ship_amount := l_po_total;

  END IF;

    -- 3488259 (3110072) Ends

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Shipment_id = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Ship_Total_Trx_Amt_Var;

/*============================================================================
 |  PROCEDURE  CALC_SHIP_TRX_AMT
 |
 |  DESCRIPTION:
 |                Procedure that given a shipment it calculates total amount
 |                invoiced against the shipment by this particular invoice
 |                in transaction currency.
 |
 |  PROGRAM FLOW
 |    It sums up the amount billed via BASE MATCH of this invoice and all its
 |    qty/price corrections to this invoice for a particular shipment;
 |    If there is an QTY/PRICE CORRECTION line exists in this invoice, we need
 |    to sum up the amount billed via BASE MATCH and QTY/PRICE CORRECTIONS of
 |    all the invoices it was trying to correct for this shipment, plus the
 |    QTY/PRICE CORRECTION line of this invoce itself. Please note, there might
 |    a case that this invoice has one correcting line which is trying to
 |    correct itself, with our query, it will be included.
 |
 |  NOTES:
 |    1. It should all be in the same currency. since we can not do
 |       cross-curr matching.
 |    2. both Quantity correction and Price correction should be considered
 |       when calculate the amount.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 *==========================================================================*/

PROCEDURE Calc_Ship_Trx_Amt(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_ship_trx_amt       IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc                   VARCHAR2(30) := 'Calc_Ship_Trx_Amt';
  l_debug_info                  VARCHAR2(100);
  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;
  ------------------------------------------------------------------
  l_debug_info := 'Calculate Shipment Total amount for the invoice';
  --------------------------------------------------------------=---
  IF (g_debug_mode = 'Y') THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

   /*-----------------------------------------------------------------+
    |  The Meaning fo the following query conditions indicates:-      |
    |    Query condition 1 - all the base match lines of this         |
    |                        invoice itself with p_invoice_id         |
    |    Query condition 2 - all the qty/price correction lines       |
    |                        against this particular invoice itself   |
    |                        (p_invoice_id)                           |
    |    Query condition 3 - all the base match lines of a list of    |
    |                        invoices that invoice with p_invoice_id  |
    |                        is trying to do qty/price correction     |
    |    Query condition 4 - all the qty/price correction lines       |
    |                        trying to correct a list of invoices     |
    |                        that invoice with p_invoice_id is trying |
    |                        to do corrections                        |
    +-----------------------------------------------------------------*/

  IF (p_match_option = 'P') THEN

    -------------------------------------------------------
    l_debug_info := 'Calc_Ship_Trx_Amt - Match to PO';
    -------------------------------------------------------

    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    SELECT sum( NVL(L.amount, 0) )
      INTO p_ship_trx_amt
      FROM ap_invoice_lines L
     WHERE L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type IN ('ITEM_TO_PO',           -- query condition 1
                                 'ITEM_TO_SERVICE_PO'))  -- Amount Based Matching
            or (L.corrected_inv_id = p_invoice_id )      -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.po_line_location_id = p_line_location_id
                                AND L2.invoice_id = p_invoice_id
                                AND L2.corrected_inv_id is not null ) and
                L.match_type IN ('ITEM_TO_PO',            -- query condition 3
                                 'ITEM_TO_SERVICE_PO'))   -- Amount Based Matching
            or (L.corrected_inv_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L3
                              WHERE L3.po_line_location_id = p_line_location_id
                                AND L3.invoice_id = p_invoice_id
                                AND L3.corrected_inv_id is not null ) ) );
                                                         -- query condition 4

  ELSIF (p_match_option = 'R') THEN

    -------------------------------------------------------
    l_debug_info := 'Calc_Ship_Trx_Amt - Match to RECEIPT';
    -------------------------------------------------------

    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    SELECT sum(NVL(L.amount, 0))
      INTO p_ship_trx_amt
      FROM ap_invoice_lines L
     WHERE L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type IN ('ITEM_TO_RECEIPT',      -- query condition 1
                                 'ITEM_TO_SERVICE_RECEIPT')) -- Amount Based Matching
            or (L.corrected_inv_id = p_invoice_id )      -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.po_line_location_id = p_line_location_id
                                AND L2.invoice_id = p_invoice_id
                                AND L2.corrected_inv_id is not null ) and
                L.match_type IN ('ITEM_TO_RECEIPT',        -- query condition 3
                                 'ITEM_TO_SERVICE_RECEIPT')) -- Amount Based Matching
            or (L.corrected_inv_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L3
                              WHERE L3.po_line_location_id = p_line_location_id
                                AND L3.invoice_id = p_invoice_id
                                AND L3.corrected_inv_id is not null ) ) );
                                                         -- query condition 4
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Shipment_id = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Ship_Trx_Amt;


/*=============================================================================
 |  PROCEDURE  CALC_MAX_RATE_VAR
 |
 |  DESCRIPTION:
 |                Procedure that given a shipment, finds the erv for the
 |                shipment in an invoice
 |
 |   PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Calc_Max_Rate_Var(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_rcv_transaction_id IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_rate_amt_var       IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc                   VARCHAR2(30) := 'Calc_Max_Rate_Var';
  l_debug_info                  VARCHAR2(100);
  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  -------------------------------------------------------------------------
  l_debug_info := 'Calculate ERV total for Shipment/receipt in the invoice';
  -------------------------------------------------------------------------

  IF g_debug_mode = 'Y' THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    AP_Debug_Pkg.Print(g_debug_mode, 'Invoice id: '|| TO_CHAR(p_invoice_id));
    AP_Debug_Pkg.Print(g_debug_mode, 'line location id: '||
                       TO_CHAR(p_line_location_id));
  END IF;

  IF (p_match_option = 'P') THEN

    -------------------------------------------------------
    l_debug_info := 'Calc_Max_Rate_Var - Match to RECEIPT';
    -------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    SELECT SUM( NVL(D.base_amount, 0))
      INTO p_rate_amt_var
      FROM ap_invoice_distributions D, po_distributions_ap_v PD
     WHERE D.po_distribution_id = PD.po_distribution_id
       AND PD.line_location_id = p_line_location_id
       AND D.invoice_id = p_invoice_id
       AND D.line_type_lookup_code = 'ERV';

  ELSIF (p_match_option = 'R') THEN

    -------------------------------------------------------
    l_debug_info := 'Calc_Max_Rate_Var - Match to RECEIPT';
    -------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    SELECT SUM(NVL(D.base_amount, 0))
      INTO p_rate_amt_var
      FROM ap_invoice_distributions D
     WHERE D.rcv_transaction_id = p_rcv_transaction_id
       AND D.invoice_id = p_invoice_id
       AND D.line_type_lookup_code = 'ERV';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Shipment_id = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Max_Rate_Var;


/*=============================================================================
 |  PROCEDURE  CALC_SHIP_TOTAL_BASE_AMT_VAR
 |
 |  DESCRIPTION:
 |                Procedure that given a shipment, it calculates total amount
 |                invoiced against the shipment in base currency minus the
 |                valid po qty (ordered-cancelled) times its unit price at
 |                base currency.
 |
 |  PROGRAM FLOW
 |    It will calculate the total BASE amount billed. If it is 0, return 0,
 |    Otherwise, it should be the sum of any invoice that has been matched
 |    to this shipment. It applies to both PO match or receipt match.
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Calc_Ship_Total_Base_Amt_Var(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_po_price           IN            NUMBER,
              p_match_basis        IN            VARCHAR2,
              p_inv_curr_code      IN            VARCHAR2,
              p_base_curr_code     IN            VARCHAR2,
              p_ship_base_amt_var  IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc                   VARCHAR2(30) := 'Calc_Ship_Total_Base_Amt_Var';
  l_debug_info                  VARCHAR2(100);
  l_curr_calling_sequence       VARCHAR2(2000);
  l_po_total                    NUMBER;
  l_ship_trx_base_amt           NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  ----------------------------------------------------------------
  l_debug_info := 'Calculate Base Shipment Total for the invoice';
  ----------------------------------------------------------------

  IF g_debug_mode = 'Y' THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

   /*-----------------------------------------------------------------+
    |  Calculate the total shipment transaction amt billed by this    |
    |  invoice and its corrections. If it is 0, further check is      |
    |  not needed.                                                    |
    +-----------------------------------------------------------------*/

  Calc_Ship_Trx_Base_Amt(
      p_invoice_id,
      p_line_location_id,
      p_match_option,
      p_inv_curr_code,
      p_base_curr_code,
      l_ship_trx_base_amt,
      l_curr_calling_sequence);

  l_ship_trx_base_amt := AP_UTILITIES_PKG.Ap_Round_Currency(
                             l_ship_trx_base_amt,
                             p_base_curr_code);


  IF ( l_ship_trx_base_amt = 0 ) THEN
    ---------------------------------------------------------------------------
    l_debug_info := 'Calc_Ship_Total_base_Trx_Amt_Var->base shipment amt is 0';
    ---------------------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    p_ship_base_amt_var := 0;

  ELSE

    ---------------------------------------------------------------------------
    l_debug_info := 'Calc_Ship_Total_base_Trx_Amt_Var->base shipment amt <> 0';
    ---------------------------------------------------------------------------
    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    --Amount-Based Matching Project, added the IF condition

    IF (p_match_basis ='QUANTITY') THEN

      SELECT SUM((NVL(PD.quantity_ordered, 0) -
                NVL(PD.quantity_cancelled, 0)) * p_po_price
                * DECODE(p_inv_curr_code, p_base_curr_code,1, PD.rate))
      INTO   l_po_total
      FROM   po_distributions_ap_v PD
      WHERE  PD.line_location_id = p_line_location_id;

    ELSE

      --match_basis ='AMOUNT'--

      SELECT SUM((NVL(PD.amount_ordered, 0) -
                 NVL(PD.amount_cancelled, 0))
                  * DECODE(p_inv_curr_code, p_base_curr_code,1,
                    PD.rate))
      INTO   l_po_total
      FROM   po_distributions_ap_v PD
      WHERE  PD.line_location_id = p_line_location_id;

    END IF;  -- Amount Based Matching If condition ends


     --Bug6824860 this SQl should not consider lines which are not matched, but
     --have PO dist ID stamped,
    --for instance, the Tax lines(passed as MISC lines) to AP by India
    --Localization, non-rec tax lines in AP. India localization
    --passes NOT MATCHED as match_type for misc lines, while AP uses
    --NOT_MATCHED, hence adding both in match_type condition
    SELECT SUM(DECODE(p_inv_curr_code, p_base_curr_code, nvl(D.amount,0),
               nvl(D.base_amount,(D.amount * DECODE(I.exchange_rate, null,
                                             PD.rate, I.exchange_rate)))))
    INTO   p_ship_base_amt_var
    FROM   ap_invoice_distributions D
           , po_distributions_ap_v PD
           , ap_invoices I
     , ap_invoice_lines L --Bug6824860
    WHERE  D.po_distribution_id = PD.po_distribution_id
    AND    PD.line_location_id = p_line_location_id
    AND    D.invoice_id = I.invoice_id
    AND     L.invoice_id = I.invoice_id --Bug6824860
    AND    L.line_number = D.invoice_line_number --Bug6824860
    AND     L.match_type not in ('NOT MATCHED','NOT_MATCHED'); --Bug6824860

    p_ship_base_amt_var := AP_UTILITIES_PKG.Ap_Round_Currency(
                           p_ship_base_amt_var - l_po_total,
                           p_base_curr_code);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Shipment_id = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Ship_Total_Base_Amt_Var;

/*============================================================================
 |  PROCEDURE  CALC_SHIP_TRX_BASE_AMT
 |
 |  DESCRIPTION:
 |                Procedure that given a shipment it calculates total base amt
 |                invoiced against the shipment by this particular invoice and
 |                its corrections in transaction currency.
 |
 |  PROGRAM FLOW
 |    It sums up the BASE amount billed via BASE MATCH of this invoice and all
 |    its QTY/PRICE CORRECTIONS to this invoice for a particular shipment;
 |    If there is an QTY/PRICE CORRECTION line exists in this invoice, we need
 |    to sum up the base amount billed via BASE MATCH and QTY/PRICE CORRECTIONS
 |    of all the invoices it was trying to correct for this shipment, plus the
 |    QTY/PRICE CORRECTION line of this invoce itself. Please note, there might
 |    bbe a case that this invoice has one correcting line which is trying to
 |    correct itself, with our query, it should be included.
 |
 |  NOTES:
 |         It should all be in the same currency. since we can not do
 |         cross-curr matching.
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 *==========================================================================*/

PROCEDURE Calc_Ship_Trx_Base_Amt(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_match_option       IN            VARCHAR2,
              p_inv_curr_code      IN            VARCHAR2,
              p_base_curr_code     IN            VARCHAR2,
              p_ship_base_amt      IN OUT NOCOPY NUMBER,
              p_calling_sequence   IN            VARCHAR2) IS

  l_debug_loc                   VARCHAR2(30) := 'Calc_Ship_Trx_Base_Amt';
  l_debug_info                  VARCHAR2(100);
  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;
  ------------------------------------------------------------------
  l_debug_info := 'Calculate base Shipment amount  for the invoice';
  ------------------------------------------------------------------

  IF g_debug_mode = 'Y' THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;


   /*-----------------------------------------------------------------+
    |  The Meaning fo the following query conditions indicates:-      |
    |    Query condition 1 - all the base match lines of this         |
    |                        invoice itself with p_invoice_id         |
    |    Query condition 2 - all the qty/price correction lines of    |
    |                        this particular invoice itself           |
    |                        (p_invoice_id)                           |
    |    Query condition 3 - all the base match lines of a list of    |
    |                        invoices that invoice with p_invoice_id  |
    |                        is trying to do qty/price correction     |
    |    Query condition 4 - all the qty/price correction lines       |
    |                        trying to correct a list of invoices     |
    |                        that this invoice with p_invoice_id is   |
    |                        trying to do qty/price corrections       |
    +-----------------------------------------------------------------*/

  IF (p_match_option = 'P') THEN

    ----------------------------------------------------------
    l_debug_info := 'Calc_Ship_BASE_Trx_Amt - Match to PO';
    ----------------------------------------------------------

    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    SELECT SUM( DECODE( p_inv_curr_code
                       ,p_base_curr_code
                       ,nvl(L.amount,0)
                       ,nvl(L.base_amount, (L.amount * AI.exchange_rate )) )
               )
      INTO p_ship_base_amt
      FROM ap_invoice_lines L,
           ap_invoices AI
     WHERE AI.invoice_id = L.invoice_id
      AND  L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type IN ('ITEM_TO_PO',           -- query condition 1
                                 'ITEM_TO_SERVICE_PO'))  -- Amount Based Matching
            or (L.corrected_inv_id = p_invoice_id )      -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.po_line_location_id = p_line_location_id
                                AND L2.invoice_id = p_invoice_id
                                AND L2.corrected_inv_id is not null ) and
                L.match_type IN ('ITEM_TO_PO',           -- query condition 3
                                 'ITEM_TO_SERVICE_PO'))  -- Amount Based Matching
            or (L.corrected_inv_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L3
                              WHERE L3.po_line_location_id = p_line_location_id
                                AND L3.invoice_id = p_invoice_id
                                AND L3.corrected_inv_id is not null ) ) );
                                                        -- query condition 4

  ELSIF (p_match_option = 'R') THEN

    ------------------------------------------------------------
    l_debug_info := 'Calc_Ship_Trx_BASE_Amt - Match to RECEIPT';
    ------------------------------------------------------------

    IF (g_debug_mode = 'Y') THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    SELECT SUM( DECODE( p_inv_curr_code
                       ,p_base_curr_code
                       ,nvl(L.amount,0)
                       ,nvl(L.base_amount, (L.amount * AI.exchange_rate )) )
               )
      INTO p_ship_base_amt
      FROM ap_invoice_lines L,
           ap_invoices AI
     WHERE AI.invoice_id = L.invoice_id
      AND  L.po_line_location_id = p_line_location_id
      AND  (   (L.invoice_id = p_invoice_id and
                L.match_type IN ('ITEM_TO_RECEIPT',      -- query condition 1
                                 'ITEM_TO_SERVICE_RECEIPT')) -- Amount Based Matching
            or (L.corrected_inv_id = p_invoice_id )      -- query condition 2
            or (L.invoice_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L2
                              WHERE L2.po_line_location_id = p_line_location_id
                                AND L2.invoice_id = p_invoice_id
                                AND L2.corrected_inv_id is not null ) and
                L.match_type  IN ('ITEM_TO_RECEIPT',      -- query condition 3
                                 'ITEM_TO_SERVICE_RECEIPT')) -- Amount Based Matching
            or (L.corrected_inv_id IN
                           ( SELECT corrected_inv_id
                               FROM ap_invoice_lines L3
                              WHERE L3.po_line_location_id = p_line_location_id
                                AND L3.invoice_id = p_invoice_id
                                AND L3.corrected_inv_id is not null ) ) );
                                                         -- query condition 4
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Shipment_id = '|| to_char(p_line_location_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Ship_Trx_Base_Amt;

--Bug 5077550

FUNCTION Check_Milestone_Price_Qty(
              p_invoice_id         IN            NUMBER,
              p_line_location_id   IN            NUMBER,
              p_po_unit_price      IN            NUMBER,
              p_calling_sequence   IN            VARCHAR2) RETURN VARCHAR2 IS

  l_debug_loc              VARCHAR2(30) := 'Calc_Milestone_Price_Qty';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_check                  VARCHAR2(100);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  BEGIN
    -- bug8704810
    -- SELECT 'Price Difference or Quantity Has Decimals'    ..  bug8704810
    SELECT 'Price Difference'                                --  bug8704810
    INTO   l_check
    FROM   ap_invoice_lines_all
    WHERE  invoice_id = p_invoice_id
    AND    po_line_location_id = p_line_location_id
    AND    unit_price <> p_po_unit_price;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_check := 'No Price or Quantity Issues';
    WHEN TOO_MANY_ROWS THEN
      -- l_check := 'Price Difference or Quantity Has Decimals';    ..  bug8704810
      l_check := 'Price Difference';                                --  bug8704810
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                    'Invoice_id  = '|| to_char(p_invoice_id));
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END;

  return (l_check);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Milestone_Price_Qty;

-- 7299826 EnC Project
PROCEDURE exec_pay_when_paid_check(p_invoice_id        IN NUMBER,
                                    p_system_user      IN NUMBER,
                                    p_holds            IN OUT NOCOPY AP_APPROVAL_PKG.holdsarray,
                                    p_holds_count      IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                    p_release_count    IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                    p_calling_sequence IN VARCHAR2) IS

  l_debug_loc               VARCHAR2(30) := 'exec_pay_when_paid_check';
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(100);
  l_api_version             NUMBER := 1.0;
  l_hold_required           VARCHAR2(1) := 'N';
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                varchar2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  Print_Debug(l_debug_loc,  'exec_pay_when_paid_check - begin for invoice_id : '|| p_invoice_id);

  FOR i IN (SELECT DISTINCT po_header_id
              FROM ap_invoice_lines
             WHERE invoice_id = p_invoice_id
               AND po_header_id is NOT NULL)
  LOOP

   Print_Debug(l_debug_loc,  'pay when paid check for po_heade_id : '||i.po_header_id );
   po_invoice_hold_check.pay_when_paid(p_api_version   => l_api_version,
                                       p_po_header_id  => i.po_header_id,
                                       p_invoice_id    => p_invoice_id,
                                       x_return_status => l_return_status,
                                       x_msg_count     => l_msg_count,
                                       x_msg_data      => l_msg_data,
                                       x_pay_when_paid => l_hold_required);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      Print_Debug(l_debug_loc, 'error occured while pay when paid check for po_heade_id : '||i.po_header_id );
      APP_EXCEPTION.raise_exception;
   END IF;

   EXIT WHEN l_hold_required = 'Y';

  END LOOP;

  Print_Debug(l_debug_loc,  'pay when paid hold required for invoice id : '||p_invoice_id||' - '||l_hold_required );

  AP_APPROVAL_PKG.process_inv_hold_status(p_invoice_id,
                                          NULL,
                                          NULL,
                                          'Pay When Paid',
                                          l_hold_required,
                                          NULL,
                                          p_system_user,
                                          p_holds,
                                          p_holds_count,
                                          p_release_count,
                                          p_calling_sequence);

   Print_Debug(l_debug_loc,  'exec_pay_when_paid_check - end for invoice_id : '|| p_invoice_id);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.set_name('SQLAP','AP_DEBUG');
      FND_MESSAGE.set_token('ERROR',SQLERRM);
      FND_MESSAGE.set_token('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.set_token('PARAMETERS', 'Invoice_id  = '|| to_char(p_invoice_id) );
      FND_MESSAGE.set_token('DEBUG_INFO',l_debug_info);
    END IF;

    APP_EXCEPTION.raise_exception;

END exec_pay_when_paid_check;

-- 7299826 EnC Project
PROCEDURE exec_po_deliverable_check(p_invoice_id       IN NUMBER,
                                    p_system_user      IN NUMBER,
                                    p_holds            IN OUT NOCOPY AP_APPROVAL_PKG.holdsarray,
                                    p_holds_count      IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                    p_release_count    IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                    p_calling_sequence IN VARCHAR2
                                    ) IS

  l_debug_loc               VARCHAR2(30) := 'exec_po_deliverable_check';
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(100);
  l_api_version             NUMBER := 1.0;
  l_hold_required           VARCHAR2(1) := 'N';
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                varchar2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  Print_Debug(l_debug_loc,'exec_po_deliverable_check - begin for invoice_id : '|| p_invoice_id);

  FOR i IN (SELECT DISTINCT po_header_id
              FROM ap_invoice_lines
             WHERE invoice_id = p_invoice_id
               AND po_header_id is NOT NULL)
  LOOP

    Print_Debug(l_debug_loc,  'po deliverable check for po_heade_id : '||i.po_header_id );
    po_invoice_hold_check.deliverable_overdue_check(p_api_version   => l_api_version,
                                                   p_po_header_id  => i.po_header_id,
                                                   p_invoice_id    => p_invoice_id,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => l_msg_count,
                                                   x_msg_data      => l_msg_data,
                                                   x_hold_required => l_hold_required);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      Print_Debug(l_debug_loc, 'error occured while po deliverable check for po_heade_id : '||i.po_header_id );
      APP_EXCEPTION.raise_exception;
    END IF;

    EXIT WHEN l_hold_required = 'Y';

  END LOOP;

  Print_Debug(l_debug_loc, 'po deliverable hold required for invoice id : '||p_invoice_id||' - '||l_hold_required );

  AP_APPROVAL_PKG.process_inv_hold_status(p_invoice_id,
                                          NULL,
                                          NULL,
                                          'PO Deliverable',
                                          l_hold_required,
                                          NULL,
                                          p_system_user,
                                          p_holds,
                                          p_holds_count,
                                          p_release_count,
                                          p_calling_sequence);

  AP_Debug_Pkg.Print(g_debug_mode, 'exec_po_deliverable_check - end for invoice_id : '|| p_invoice_id);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.set_name('SQLAP','AP_DEBUG');
      FND_MESSAGE.set_token('ERROR',SQLERRM);
      FND_MESSAGE.set_token('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.set_token('PARAMETERS', 'Invoice_id  = '|| to_char(p_invoice_id) );
      FND_MESSAGE.set_token('DEBUG_INFO',l_debug_info);
    END IF;

    APP_EXCEPTION.raise_exception;

END exec_po_deliverable_check;

-- 7299826 EnC Project
Procedure Print_Debug(
		p_api_name		  IN VARCHAR2,
		p_debug_info		IN VARCHAR2) IS
BEGIN

  IF AP_APPROVAL_PKG.g_debug_mode = 'Y' THEN
    AP_Debug_Pkg.Print('Y', p_debug_info );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'AP.PLSQL.AP_APPROVAL_MATCHED_PKG'||p_api_name,p_debug_info);
  END IF;

END Print_Debug;


--for CLM project - bug 9494400

PROCEDURE exec_partial_funds_check (p_invoice_id       IN NUMBER,
                                    p_system_user      IN NUMBER,
                                    p_holds            IN OUT NOCOPY
AP_APPROVAL_PKG.holdsarray,
                                    p_holds_count      IN OUT NOCOPY
AP_APPROVAL_PKG.countarray,
                                    p_release_count    IN OUT NOCOPY
AP_APPROVAL_PKG.countarray,
                                    p_calling_sequence IN VARCHAR2)
IS

  l_debug_loc              VARCHAR2(30):='exec_partial_funds_check';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(100);
  l_api_version            NUMBER := 1.0;
  l_hold_required          VARCHAR2(1) := 'N';
  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               varchar2(2000);

l_distribution_type        PO_DISTRIBUTIONS_ALL.destination_type_code%TYPE ;
l_accrue_on_receipt_flag   PO_DISTRIBUTIONS_ALL.accrue_on_receipt_flag%TYPE ;
l_code_combination_id      PO_DISTRIBUTIONS_ALL.code_combination_id%TYPE ;
l_budget_account_id        PO_DISTRIBUTIONS_ALL.budget_account_id%TYPE ;
l_partial_funded_flag      PO_DISTRIBUTIONS_ALL.partial_funded_flag%TYPE ;
l_funded_value             PO_DISTRIBUTIONS_ALL.funded_value%TYPE ;
l_quantity_funded          PO_DISTRIBUTIONS_ALL.quantity_funded%TYPE ;
l_amount_funded            PO_DISTRIBUTIONS_ALL.amount_funded%TYPE ;
l_quantity_delivered       PO_DISTRIBUTIONS_ALL.quantity_delivered%TYPE ;
l_amount_delivered         PO_DISTRIBUTIONS_ALL.amount_delivered%TYPE ;
l_quantity_billed          PO_DISTRIBUTIONS_ALL.quantity_billed%TYPE ;
l_amount_billed            PO_DISTRIBUTIONS_ALL.amount_billed%TYPE ;
l_matching_basis           PO_LINE_LOCATIONS.matching_basis%TYPE;
l_quantity_received        PO_LINE_LOCATIONS.quantity_received%TYPE;
l_amount_received          PO_LINE_LOCATIONS.amount_received%TYPE;
l_hold_name                VARCHAR2(30);
l_unit_meas_lookup_code    PO_LINE_LOCATIONS_ALL.unit_meas_lookup_code%TYPE;
l_quantity_cancelled       PO_DISTRIBUTIONS_ALL.quantity_cancelled%TYPE ;
l_amount_cancelled         PO_DISTRIBUTIONS_ALL.amount_cancelled%TYPE ;
l_po_header_id             ap_invoice_lines_all.po_header_id%TYPE;


BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_MATCHED_PKG.'||
l_debug_loc||'<-'||p_calling_sequence;
  Print_Debug(l_debug_loc,  'exec_partial_funds_check - begin for invoice_id :
'|| p_invoice_id);

    IF (AP_CLM_PVT_PKG.is_clm_installed = 'Y' )then
    --PO Matched, Non Tax distributions of the Invoice

    FOR rec_part_funds_check IN (select distinct po_distribution_id
                                 from ap_invoice_distributions
                                 where  invoice_id = p_invoice_id
                                 and  po_distribution_id is not null
                                 and  line_type_lookup_code not in
                                          ('REC_TAX', 'NONREC_TAX',
                                           'TERV','TIPV','TRV')
                                ) LOOP
  Print_Debug(l_debug_loc,  'exec_partial_funds_check - po_distribution_id: '||
rec_part_funds_check.po_distribution_id);

    --Call the Partial Funding Information API
        AP_CLM_PVT_PKG.Get_Funding_Info(
         P_PO_DISTRIBUTION_ID     =>  rec_part_funds_check.po_distribution_id
        ,X_DISTRIBUTION_TYPE      =>  l_distribution_type
        ,X_MATCHING_BASIS         =>  l_matching_basis
        ,X_ACCRUE_ON_RECEIPT_FLAG =>  l_accrue_on_receipt_flag
        ,X_CODE_COMBINATION_ID    =>  l_code_combination_id
        ,X_BUDGET_ACCOUNT_ID      =>  l_budget_account_id
        ,X_PARTIAL_FUNDED_FLAG    =>  l_partial_funded_flag
        ,x_UNIT_MEAS_LOOKUP_CODE  =>  l_unit_meas_lookup_code
        ,X_FUNDED_VALUE           =>  l_funded_value
        ,X_QUANTITY_FUNDED        =>  l_quantity_funded
        ,X_AMOUNT_FUNDED          =>  l_amount_funded
        ,X_QUANTITY_RECEIVED      =>  l_quantity_received
        ,X_AMOUNT_RECEIVED        =>  l_amount_received
        ,X_QUANTITY_DELIVERED     =>  l_quantity_delivered
        ,X_AMOUNT_DELIVERED       =>  l_amount_delivered
        ,X_QUANTITY_BILLED        =>  l_quantity_billed
        ,X_AMOUNT_BILLED          =>  l_amount_billed
        ,x_QUANTITY_CANCELLED     =>  l_quantity_cancelled
        ,X_AMOUNT_CANCELLED       =>  l_amount_cancelled
        ,X_RETURN_STATUS          =>  l_return_status    );


    IF L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_debug_info := 'Partial funds check failed:
AP_INTG_DOCUMENT_FUNDS_GRP.Get_Funding_Info returned invalid status.';
        Print_Debug(l_debug_loc,  l_debug_info);
        APP_EXCEPTION.raise_exception;
    END IF    ;


    IF l_partial_funded_flag = 'Y' THEN

        IF l_matching_basis = 'QUANTITY' THEN
           l_hold_name :='Quantity Funded';
           IF l_quantity_billed > l_quantity_funded THEN
                l_hold_required := 'Y'   ;
           END IF;
        ELSIF l_matching_basis = 'AMOUNT' THEN
              l_hold_name :='Amount Funded';
              IF l_amount_billed > l_amount_funded THEN
                l_hold_required := 'Y';
              END IF;
        END IF;

    END IF;

      IF l_hold_required = 'Y' THEN
          Print_Debug(l_debug_loc,  'exec_partial_funds_check - Hold
Name'||l_hold_name|| 'required for invoice_id : '|| p_invoice_id);
      END IF;

      Print_Debug(l_debug_loc,  'exec_partial_funds_check - end for invoice_id :
'|| p_invoice_id);
       EXIT WHEN l_hold_required = 'Y';

    END LOOP;
        --Apply the Hold;
END IF;

    AP_APPROVAL_PKG.process_inv_hold_status(  p_invoice_id,
                                              NULL,
                                              NULL,
                                              l_hold_name,
                                              l_hold_required,
                                              NULL,
                                              p_system_user,
                                              p_holds,
                                              p_holds_count,
                                              p_release_count,
                                              p_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
        l_debug_info := 'Partial funds check failed';
        Print_Debug(l_debug_loc,  l_debug_info);
        APP_EXCEPTION.raise_exception;
END exec_partial_funds_check;
--end for CLM project - bug 9494400


END AP_APPROVAL_MATCHED_PKG;

/
