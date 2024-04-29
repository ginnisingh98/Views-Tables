--------------------------------------------------------
--  DDL for Package Body AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WITHHOLDING_PKG" AS
/* $Header: apdoawtb.pls 120.36.12010000.35 2010/04/20 01:53:23 vbondada ship $ */

-- =====================================================================
--                   P U B L I C    O B J E C T S
-- =====================================================================

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'AP.PLSQL.AP_WITHHOLDING_PKG.';

PROCEDURE Create_AWT_Distributions(
          P_Invoice_Id             IN     NUMBER,
          P_Calling_Module         IN     VARCHAR2,
          P_Create_dists           IN     VARCHAR2,
          P_Payment_Num            IN     NUMBER,
          P_Currency_Code          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          P_Calling_Sequence       IN     VARCHAR2,
	  P_Check_Id		   IN     NUMBER DEFAULT NULL) -- 8590059
IS
  withholding_total          NUMBER := 0;
  base_withholding_total     NUMBER := 0;
  l_invoice_distribution_id  ap_invoice_distributions.invoice_distribution_id%TYPE;

  --Bug 8266021 Changed Cursor to include two additional parameters GRP_ID and TAXID
  --and included these two parameters in the where clause
  CURSOR C_temp_dists (InvId IN NUMBER,GRP_ID IN NUMBER,TAXID IN NUMBER) IS
  SELECT AATD.invoice_id
  ,      AATD.payment_num
  ,      AATD.group_id
  ,      AATD.tax_name
  ,      AATD.tax_code_combination_id
  ,      AATD.gross_amount
  ,      AATD.withholding_amount
  ,      AATD.base_withholding_amount
  ,      AATD.accounting_date
  ,      AATD.period_name
  ,      AATD.checkrun_name
  ,      AATD.tax_rate_id
  ,      AATD.invoice_payment_id
  ,      TC.tax_id tax_code_id
  ,      AATD.GLOBAL_ATTRIBUTE_CATEGORY
  ,      AATD.GLOBAL_ATTRIBUTE1
  ,      AATD.GLOBAL_ATTRIBUTE2
  ,      AATD.GLOBAL_ATTRIBUTE3
  ,      AATD.GLOBAL_ATTRIBUTE4
  ,      AATD.GLOBAL_ATTRIBUTE5
  ,      AATD.GLOBAL_ATTRIBUTE6
  ,      AATD.GLOBAL_ATTRIBUTE7
  ,      AATD.GLOBAL_ATTRIBUTE8
  ,      AATD.GLOBAL_ATTRIBUTE9
  ,      AATD.GLOBAL_ATTRIBUTE10
  ,      AATD.GLOBAL_ATTRIBUTE11
  ,      AATD.GLOBAL_ATTRIBUTE12
  ,      AATD.GLOBAL_ATTRIBUTE13
  ,      AATD.GLOBAL_ATTRIBUTE14
  ,      AATD.GLOBAL_ATTRIBUTE15
  ,      AATD.GLOBAL_ATTRIBUTE16
  ,      AATD.GLOBAL_ATTRIBUTE17
  ,      AATD.GLOBAL_ATTRIBUTE18
  ,      AATD.GLOBAL_ATTRIBUTE19
  ,      AATD.GLOBAL_ATTRIBUTE20
  ,      AI.org_id
  ,      AATD.awt_related_id
  ,      aatd.checkrun_id
  ,      TC.description --Bug5502917
  FROM   ap_awt_temp_distributions_all AATD,
         ap_invoices_all AI,
         ap_tax_codes_all TC,
		 ap_invoice_distributions_all AID			--bug 7930936
  WHERE  AATD.invoice_id          = InvId
    AND  AATD.group_id		  = GRP_ID
    AND  AATD.invoice_id          = AI.invoice_id
    AND	 TC.TAX_ID		  = TAXID
    AND  AATD.tax_name            = TC.name(+)
    AND  TC.org_id                = AI.org_id    -- Bug5902006
    AND  TC.tax_type = 'AWT'                     -- Bug3665866
    AND  NVL(TC.enabled_flag,'Y') = 'Y'
    AND  (   P_Payment_Num           IS NULL
          OR AATD.payment_num = P_Payment_Num)
    AND  NVL(AI.invoice_date,SYSDATE) BETWEEN
             NVL(TC.start_date,NVL(AI.invoice_date,SYSDATE)) AND
             NVL(TC.inactive_date,NVL(AI.invoice_date,SYSDATE))
    AND  AATD.invoice_id = AID.invoice_id						--bug 7930936
    AND  AATD.awt_related_id = AID.invoice_distribution_id		--bug 7930936
    AND  AID.prepay_distribution_id is NULL  					--bug 7930936
  ORDER BY AATD.tax_name,
         AATD.tax_rate_id
  FOR UPDATE of AATD.invoice_id;
  rec_temp_dists c_temp_dists%ROWTYPE;

  CURSOR c_invoice (InvId IN NUMBER) IS
  SELECT AI.set_of_books_id
  ,	 AI.org_id				--bug 8266021
  ,      AI.accts_pay_code_combination_id
  ,      AI.batch_id
  ,      AI.description
  ,      AI.invoice_amount
  ,      NVL(AI.payment_cross_rate,1) payment_cross_rate
  ,      AI.payment_currency_code
  ,      AI.exchange_date
  ,      NVL(AI.exchange_rate, 1) exchange_rate
  ,      AI.exchange_rate_type
--,      AI.ussgl_transaction_code - Bug 4277744
--,      AI.ussgl_trx_code_context - Bug 4277744
  ,      AI.vat_code
  ,      NVL(PV.federal_reportable_flag, 'N') federal_reportable_flag
  ,      AI.vendor_site_id vendor_site_id
  ,      AI.amount_applicable_to_discount
  FROM   ap_invoices_all AI,
         po_vendors PV
  WHERE  PV.vendor_id(+)  = DECODE(AI.invoice_type_lookup_code,'PAYMENT REQUEST', NULL, AI.vendor_id) --bug8272564
  AND    AI.invoice_id = InvId
  FOR UPDATE of AI.invoice_id;

  rec_invoice c_invoice%ROWTYPE;

  --Bug 8266021 added new cursor
  CURSOR C_line_cursor (InvId IN NUMBER) IS
  SELECT AATD.group_id
  ,      AATD.invoice_payment_id
  ,		 TC.TAX_ID
  ,      SUM(AATD.withholding_amount) AMOUNT
  ,      SUM(AATD.base_withholding_amount) BASE_AMOUNT
  ,      MIN(AATD.accounting_date) ACCOUNTING_DATE
  FROM   ap_awt_temp_distributions_all AATD,
         ap_invoices_all AI,
         ap_tax_codes_all TC,
		 ap_invoice_distributions_all AID			--bug 7930936
  WHERE  AATD.invoice_id          = InvId
    AND  AATD.invoice_id          = AI.invoice_id
    AND  AATD.tax_name            = TC.name(+)
    AND  TC.org_id                = AI.org_id    -- Bug5902006
    AND  TC.tax_type = 'AWT'                     -- Bug3665866
    AND  NVL(TC.enabled_flag,'Y') = 'Y'
    AND  (   P_Payment_Num           IS NULL
          OR AATD.payment_num = P_Payment_Num)
    AND  NVL(AI.invoice_date,SYSDATE) BETWEEN
             NVL(TC.start_date,NVL(AI.invoice_date,SYSDATE)) AND
             NVL(TC.inactive_date,NVL(AI.invoice_date,SYSDATE))
    AND  AATD.invoice_id = AID.invoice_id						--bug 7930936
    AND  AATD.awt_related_id = AID.invoice_distribution_id    	--bug 7930936
    AND  AID.prepay_distribution_id is NULL  					--bug 7930936
  GROUP BY  AATD.group_id,AATD.invoice_payment_id,TC.tax_id;

  rec_temp_lines C_line_cursor%ROWTYPE;

  CURSOR C_Current_Line (InvId IN NUMBER)
  IS
  SELECT MAX(line_number) curr_inv_line_number
    FROM ap_invoice_lines_all
   WHERE (invoice_id = InvId);

  curr_inv_line_number ap_invoice_lines_all.line_number%TYPE;
  --bug 8266021
  curr_inv_dist_line_number ap_invoice_distributions_all.distribution_line_number%TYPE;

--bug 7930936
  CURSOR C_NONPREPAY_AWT (InvId IN NUMBER)
  IS
  SELECT AATD.*
    FROM ap_awt_temp_distributions_all AATD,
	     ap_invoice_distributions_all AID
   WHERE AATD.invoice_id = InvId
     AND AATD.invoice_id = AID.invoice_id
	 AND AATD.awt_related_id = AID.invoice_distribution_id
     AND AID.prepay_distribution_id is NULL;

  rec_nonprepay_awt C_NONPREPAY_AWT%ROWTYPE;

/* bug 7930936  added the above cursor to include to select all non prepay awt distributions
against which the prepay awt amount should be prorated*/

  l_prepay_awt_amount                 NUMBER;  -- bug7930936
  l_prepay_awt_base_amount            NUMBER;  -- bug7930936
  l_non_prepay_awt_amount             NUMBER;  -- bug7930936
  l_non_prepay_awt_base_amount        NUMBER;  -- bug7930936
  l_pro_prepay_awt_amt                NUMBER;  -- bug7930936
  l_pro_prepay_awt_base_amt           NUMBER;  -- bug7930936
  l_sum_prorated_awt_amt              NUMBER := 0;  -- bug7930936
  l_sum_prorated_awt_base_amt         NUMBER := 0;  -- bug7930936
  l_awt_related_id                    NUMBER;  -- bug7930936
  l_tax_rate_id                       NUMBER;  -- bug7930936
  l_amt_diff                          NUMBER;  -- bug7930936
  l_base_amt_diff                     NUMBER;  -- bug7930936

--bug 7930936

  DBG_Loc                    VARCHAR2(30) := 'Create_AWT_distributions';

  current_calling_sequence   VARCHAR2(2000);
  debug_info                 VARCHAR2(1000);
  l_disc_amt_factor            NUMBER;
  l_disc_amt_divisor		 NUMBER; -- BUG 7000143
  l_basecur                  ap_system_parameters.base_currency_code%TYPE;
  l_enable_1099_on_awt_flag  ap_system_parameters.enable_1099_on_awt_flag%TYPE;
  l_type_1099                ap_invoice_distributions.type_1099%TYPE;
  l_combined_filing_flag     ap_system_parameters.combined_filing_flag%TYPE;
  l_income_tax_region_asp    ap_system_parameters.income_tax_region%TYPE;
  l_income_tax_region_pvs    ap_system_parameters.income_tax_region%TYPE;
  l_income_tax_region_flag   ap_system_parameters.income_tax_region_flag%TYPE;
  l_income_tax_region        ap_system_parameters.income_tax_region%TYPE;

  l_period_name		     gl_period_statuses.period_name%TYPE;    --added for bug 8266021

  l_exchange_rate	     ap_checks_all.exchange_rate%type;  -- added for bug 8590059

  l_withhold_amount	     NUMBER;  --8726501

  -- bug8879522
  l_sum_dists                NUMBER;
  l_sum_dists_base           NUMBER;
  l_line_amt                 NUMBER;
  l_line_base_amt            NUMBER;
  l_round_amt                NUMBER;
  l_round_base_amt           NUMBER;
  l_dist_id_to_round         NUMBER;



BEGIN
  current_calling_sequence := 'AP_WITHHOLDING_PKG.Create_AWT_distributions<-' ||
                               P_Calling_Sequence;


  debug_info := 'Get 1099 Info From ASP';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;


  SELECT NVL(enable_1099_on_awt_flag, 'N'),
         combined_filing_flag,
         income_tax_region_flag,
         income_tax_region,
         base_currency_code
  INTO   l_enable_1099_on_awt_flag,
         l_combined_filing_flag,
         l_income_tax_region_flag,
         l_income_tax_region_asp,
         l_basecur
  FROM   ap_system_parameters_all asp,
         ap_invoices_all ai
  WHERE  ai.org_id = asp.org_id
    and  ai.invoice_id = p_invoice_id;

 --bug 7930936
 SELECT nvl(sum(AATD.withholding_amount),0),nvl(sum(AATD.base_withholding_amount),0)
    INTO l_prepay_awt_amount,l_prepay_awt_base_amount
    FROM ap_awt_temp_distributions_all AATD,
	     ap_invoice_distributions_all AID
   WHERE AATD.invoice_id = P_Invoice_Id
     AND AATD.invoice_id = AID.invoice_id
	 AND AATD.awt_related_id = AID.invoice_distribution_id
	 AND AID.prepay_distribution_id is not NULL;

/* bug 7930936  The above query will select the total prepay awt amount from
ap_awt_temp_distributions table and this will be prorated against other
non prepay awt distributions */

  SELECT sum(AATD.withholding_amount),sum(AATD.base_withholding_amount)
    INTO l_non_prepay_awt_amount,l_non_prepay_awt_base_amount
    FROM ap_awt_temp_distributions_all AATD,
	     ap_invoice_distributions_all AID
   WHERE AATD.invoice_id = P_Invoice_Id
     AND AATD.invoice_id = AID.invoice_id
	 AND AATD.awt_related_id = AID.invoice_distribution_id
     AND AID.prepay_distribution_id is NULL;

/* bug 7930936  The above query will select the total non prepay awt amount from
ap_awt_temp_distributions table and this will be used in the proration formula */

  debug_info := 'l_prepay_awt_amount -- '||l_prepay_awt_amount;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  debug_info := 'l_non_prepay_awt_amount -- '||l_non_prepay_awt_amount;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  IF (l_prepay_awt_amount <> 0 AND l_prepay_awt_base_amount <> 0 AND
      (l_prepay_awt_amount + l_non_prepay_awt_amount) > 0) THEN

/* bug 7930936  Enter into proration logic only if prepay awt amount exists
and the prepay awt amount is not more than standard invoice awt amount.
Here the awt amount sign would be opposite to what we see in ap_invoie_distributions_all table. */

  debug_info := 'l_prepay_awt_amount + l_non_prepay_awt_amount -- '||(l_prepay_awt_amount+l_non_prepay_awt_amount);
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  debug_info := 'OPEN CURSOR C_NONPREPAY_AWT';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  OPEN C_NONPREPAY_AWT(P_Invoice_Id);

  <<FOR_EACH_NONPREPAY_AWT>>

  LOOP

  debug_info := 'Fetch CURSOR C_NONPREPAY_AWT';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  FETCH C_NONPREPAY_AWT INTO rec_nonprepay_awt;

  EXIT WHEN C_NONPREPAY_AWT%NOTFOUND;

  l_pro_prepay_awt_amt := (rec_nonprepay_awt.withholding_amount * l_prepay_awt_amount)
                                  /l_non_prepay_awt_amount;

  debug_info := 'l_pro_prepay_awt_amt -- '||l_pro_prepay_awt_amt;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  l_pro_prepay_awt_base_amt := (rec_nonprepay_awt.base_withholding_amount * l_prepay_awt_base_amount)
                                  /l_non_prepay_awt_base_amount;

/* bug 7930936  Above is the proration formula */

  debug_info := 'l_pro_prepay_awt_base_amt -- '||l_pro_prepay_awt_base_amt;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  l_sum_prorated_awt_amt := l_sum_prorated_awt_amt + l_pro_prepay_awt_amt;

  debug_info := 'l_sum_prorated_awt_amt -- '||l_sum_prorated_awt_amt;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  l_sum_prorated_awt_base_amt := l_sum_prorated_awt_base_amt + l_pro_prepay_awt_base_amt;

  debug_info := 'l_sum_prorated_awt_base_amt -- '||l_sum_prorated_awt_base_amt;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  update ap_awt_temp_distributions_all
     set withholding_amount = withholding_amount + l_pro_prepay_awt_amt,
	     base_withholding_amount = base_withholding_amount + l_pro_prepay_awt_base_amt
   where invoice_id = rec_nonprepay_awt.invoice_id
     and awt_related_id = rec_nonprepay_awt.awt_related_id
	 and tax_rate_id = rec_nonprepay_awt.tax_rate_id;

   l_tax_rate_id := rec_nonprepay_awt.tax_rate_id;
   l_awt_related_id := rec_nonprepay_awt.awt_related_id;

  END LOOP FOR_EACH_NONPREPAY_AWT;

/* bug 7930936  Added the below check to handle any rounding diff if created due to this
proration and adjust that rounding diff against the last non prepay awt distribution */

  IF (l_sum_prorated_awt_amt <> l_prepay_awt_amount OR
      l_sum_prorated_awt_base_amt <> l_prepay_awt_base_amount)
  THEN
      l_amt_diff := l_prepay_awt_amount-l_sum_prorated_awt_amt;
	  l_base_amt_diff := l_prepay_awt_base_amount-l_sum_prorated_awt_base_amt;
  debug_info := 'l_amt_diff -- '||l_amt_diff;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  debug_info := 'l_base_amt_diff -- '||l_base_amt_diff;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

	  update ap_awt_temp_distributions_all
         set withholding_amount = withholding_amount + l_amt_diff,
             base_withholding_amount = base_withholding_amount + l_base_amt_diff
       where invoice_id = P_INVOICE_ID
         and awt_related_id = l_awt_related_id
         and tax_rate_id = l_tax_rate_id;
  END IF;

  debug_info := 'CLSOE CURSOR C_NONPREPAY_AWT';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  CLOSE C_NONPREPAY_AWT;
  END IF; --l_prepay_awt_amount<>0

--bug 7930936

  debug_info := 'OPEN CURSOR C_Current_Line';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  OPEN  C_Current_line (P_Invoice_Id);

  debug_info := 'Fetch CURSOR c_current_line';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  FETCH C_Current_line INTO curr_inv_line_number;

  debug_info := 'CLOSE CURSOR C_Current_Line';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  CLOSE C_Current_Line;

  debug_info := 'OPEN CURSOR c_invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  OPEN  c_invoice (P_Invoice_Id);

  debug_info := 'Fetch CURSOR c_invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  FETCH c_invoice INTO rec_invoice;

  debug_info := 'Check 1099 Info From Rec_Invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  IF (l_enable_1099_on_awt_flag = 'Y')  THEN
      IF (rec_invoice.federal_reportable_flag = 'Y') THEN

         l_type_1099 := 'MISC4';
         IF (l_combined_filing_flag = 'Y') THEN
             IF (l_income_tax_Region_flag = 'Y') THEN
                BEGIN
                  SELECT SUBSTR(state, 1, 10)
                  INTO   l_income_tax_region
                  FROM   po_vendor_sites_all
                  WHERE  vendor_site_id = rec_invoice.vendor_site_id
                  AND    NVL(tax_reporting_site_flag, 'N') = 'Y';

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  l_income_tax_region := NULL;
                END;
             ELSE
                l_income_tax_region := l_income_tax_region_asp;
             END IF;
         ELSE
             l_income_tax_region := NULL;
         END IF;
      ELSE
         l_type_1099 := NULL;
      END IF;
  END IF;

   -- bug 8266021 Opened line cursor
  debug_info := 'OPEN CURSOR C_line_cursor';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  OPEN  C_line_cursor (P_Invoice_Id);

 <<FOR_EACH_TEMPORARY_LINE>>
  LOOP
    debug_info := 'Fetch CURSOR C_line_cursor';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
    FETCH C_line_cursor INTO rec_temp_lines;

    EXIT WHEN C_line_cursor%NOTFOUND;

    -- Increment the Invoice Line Number
    curr_inv_line_number := curr_inv_line_number + 1;

    SELECT DISTINCT gps.Period_Name
      INTO l_period_name
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
     WHERE gps.Application_Id = 200
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND rec_temp_lines.accounting_date BETWEEN Trunc(gps.Start_Date)
                              AND Trunc(gps.End_Date)
       AND Nvl(Asp.Org_Id,- 99) = Nvl(rec_invoice.org_id,- 99)
       AND gps.closing_Status in ('O', 'F');

    debug_info := 'group_id'||rec_temp_lines.group_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;

  debug_info := 'P_Calling_Module -- '||P_Calling_Module;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

    -- Now we have obtained all the required information AND we can
    -- create lines

--pay_wht_project  8590059
IF (P_Calling_Module = 'QUICKCHECK') then

    debug_info := 'Inside QUICKCHECK';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

	SELECT exchange_rate
	INTO   l_exchange_rate
	FROM   ap_checks_all
	WHERE  check_id = P_Check_Id;
ELSIF (P_Calling_Module = 'CONFIRM') then

    debug_info := 'Inside CONFIRM';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

	SELECT payment_exchange_rate
	INTO   l_exchange_rate
	FROM   ap_selected_invoices_all
	WHERE  invoice_id = P_Invoice_Id;
ELSE
    debug_info := 'Inside VALIDATION';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

	l_exchange_rate := rec_invoice.exchange_rate;
END IF;
--pay_wht_project  8590059

--bug 8726501
IF (P_Calling_Module = 'AUTOAPPROVAL') then
    l_withhold_amount := -rec_temp_lines.amount/nvl(l_exchange_rate,1);
ELSE
    l_withhold_amount := -rec_temp_lines.amount/(nvl(l_exchange_rate,1)*rec_invoice.payment_cross_rate);
END IF;
--bug 8726501

--Bug 8266021 insert in ap_invoice_lines is changed to insert single line per tax code/group id

    debug_info := 'Insert INTO ap_invoice_lines_all';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;

    INSERT INTO AP_INVOICE_LINES_all (
      invoice_id,
      line_number,
      line_type_lookup_code,
      description,
      line_source,
      generate_dists,
      match_type,
      prorate_across_all_items,
      accounting_date,
      period_name,
      deferred_acctg_flag,
      set_of_books_id,
      amount,
      base_amount,
      rounding_amt,
      wfapproval_status,
   -- ussgl_transaction_code, - Bug 4277744
      discarded_flag,
      cancelled_flag,
      income_tax_region,
      type_1099,
      final_match_flag,
      assets_tracking_flag,
      awt_group_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_application_id,
      program_id,
      program_UPDATE_date,
      request_id,
      org_id,            --7230158
      pay_awt_group_id)  --7230158
      VALUES
    ( P_Invoice_ID,
      curr_inv_line_number,
      'AWT',
      rec_invoice.description,
      'AUTO WITHHOLDING',
      'D',
      'NOT_MATCHED',
      'N',
      rec_temp_lines.accounting_date,
      l_period_name,
      'N',
      rec_invoice.set_of_books_id,
      ap_utilities_pkg.ap_round_currency(
                  l_withhold_amount,		-- bug 8726501
                  p_currency_code),   		-- bug 8590059
      ap_utilities_pkg.ap_round_currency(
                  -rec_temp_lines.base_amount,
                  l_basecur),
      0,
      'NOT REQUIRED', /*bug 4994642, was 'NOT_REQUIRED' */
   -- rec_invoice.ussgl_transaction_code, - Bug 4277744
      'N',
      'N',
      l_income_tax_region,
      l_type_1099,
      'N',
      'N',
      decode (rec_temp_lines.invoice_payment_id,NULL, rec_temp_lines.group_id,NULL),  --7230158,
      SYSDATE,
      P_Last_Updated_By,
      SYSDATE,
      P_Last_Updated_By,
      P_Last_Update_Login,
      P_Program_Application_ID,
      P_Program_ID,
      SYSDATE,
      P_request_ID,
      rec_invoice.org_id,							      --7230158
      decode (rec_temp_lines.invoice_payment_id,NULL,NULL,rec_temp_lines.group_id));  --7230158

      -- bug8879522
    l_line_amt :=  ap_utilities_pkg.ap_round_currency
                        (l_withhold_amount,
                         p_currency_code);
    l_line_base_amt := ap_utilities_pkg.ap_round_currency
                            (-rec_temp_lines.base_amount,
                             l_basecur);
    l_sum_dists := 0;
    l_sum_dists_base := 0;

    debug_info := ' After Initializing the line amounts and setting '||
                  ' dist running totals to 0 for line '||curr_inv_line_number||
                  ' l_line_amt :'||l_line_amt||' l_line_base_amt :'||l_line_base_amt;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;



--Bug 8266021 now the distributions related to this line will be inserted
  debug_info := 'OPEN CURSOR c_temp_dists';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
  OPEN  c_temp_dists (P_Invoice_Id ,rec_temp_lines.group_id,rec_temp_lines.tax_id);

  <<FOR_EACH_TEMPORARY_DIST>>
  curr_inv_dist_line_number := 0 ;

  LOOP
    debug_info := 'Fetch CURSOR c_temp_dists';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
    FETCH c_temp_dists INTO rec_temp_dists;

    EXIT WHEN c_temp_dists%NOTFOUND;

    -- Increment the distribution Line Number
    curr_inv_dist_line_number := curr_inv_dist_line_number + 1;

--bug 8726501
IF (P_Calling_Module = 'AUTOAPPROVAL') then
    l_withhold_amount := -rec_temp_dists.withholding_amount/nvl(l_exchange_rate,1);
ELSE
    l_withhold_amount := -rec_temp_dists.withholding_amount/(nvl(l_exchange_rate,1)*rec_invoice.payment_cross_rate);
END IF;
--bug 8726501

    debug_info := 'dist_num'||curr_inv_dist_line_number;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;

    debug_info := 'Insert INTO ap_invoice_distributions';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;

    INSERT INTO ap_invoice_distributions_all (
     accounting_date
    ,accrual_posted_flag
    ,assets_addition_flag
    ,assets_tracking_flag
    ,cash_posted_flag
    ,distribution_line_number
    ,dist_code_combination_id
    ,invoice_id
    ,invoice_line_number
    ,last_updated_by
    ,last_update_date
    ,line_type_lookup_code
    ,period_name
    ,set_of_books_id
    ,amount
    ,base_amount
    ,batch_id
    ,created_by
    ,creation_date
    ,description
    ,last_update_login
    ,match_status_flag
    ,posted_flag
    ,program_application_id
    ,program_id
    ,program_UPDATE_date
    ,request_id
    ,withholding_tax_code_id  /* Bug 5382525 */
    ,encumbered_flag
    ,pa_addition_flag
    ,posted_amount
    ,posted_base_amount
 -- ,ussgl_transaction_code - Bug 4277744
 -- ,ussgl_trx_code_context - Bug 4277744
    ,awt_flag
    ,awt_tax_rate_id
    ,awt_gross_amount
    ,awt_origin_group_id
    ,awt_invoice_payment_id
    ,invoice_distribution_id
    ,GLOBAL_ATTRIBUTE_CATEGORY
    ,GLOBAL_ATTRIBUTE1
    ,GLOBAL_ATTRIBUTE2
    ,GLOBAL_ATTRIBUTE3
    ,GLOBAL_ATTRIBUTE4
    ,GLOBAL_ATTRIBUTE5
    ,GLOBAL_ATTRIBUTE6
    ,GLOBAL_ATTRIBUTE7
    ,GLOBAL_ATTRIBUTE8
    ,GLOBAL_ATTRIBUTE9
    ,GLOBAL_ATTRIBUTE10
    ,GLOBAL_ATTRIBUTE11
    ,GLOBAL_ATTRIBUTE12
    ,GLOBAL_ATTRIBUTE13
    ,GLOBAL_ATTRIBUTE14
    ,GLOBAL_ATTRIBUTE15
    ,GLOBAL_ATTRIBUTE16
    ,GLOBAL_ATTRIBUTE17
    ,GLOBAL_ATTRIBUTE18
    ,GLOBAL_ATTRIBUTE19
    ,GLOBAL_ATTRIBUTE20
    ,type_1099
    ,income_tax_region
    ,org_id
    ,awt_related_id
    --Freight and Special Charges
    ,rcv_charge_addition_flag
    ,distribution_class -- bug 8620272
    )
    VALUES
    (
     rec_temp_dists.accounting_date
    ,'N'
    ,'N'
    ,'N'
    ,'N'
    ,curr_inv_dist_line_number                        -- distribution_line_number
    ,rec_temp_dists.tax_code_combination_id
    ,P_Invoice_Id
    ,curr_inv_line_number     -- invoice_line_number
    ,P_Last_Updated_By
    ,SYSDATE
    ,'AWT'
    ,rec_temp_dists.period_name
    ,rec_invoice.set_of_books_id
    ,ap_utilities_pkg.ap_round_currency(
       l_withhold_amount,		-- bug 8726501
       p_currency_code)			-- bug 8590059
    ,ap_utilities_pkg.ap_round_currency(-rec_temp_dists.base_withholding_amount,
                           l_basecur)
    ,rec_invoice.batch_id
    ,P_Last_Updated_By
    ,SYSDATE
    ,rec_temp_dists.description --Bug5502917 Replaced rec_invoice.description
    ,P_Last_Update_Login
    ,decode (P_Calling_Module, 'INVOICE ENTRY','N',
                               'INVOICE INQUIRY','N',
                               'A')
    ,'N'
    ,P_Program_Application_Id
    ,P_Program_Id
    ,decode (P_Program_Id,NULL,NULL,SYSDATE)
    ,P_Request_Id
    ,rec_temp_dists.tax_code_id
    ,'T'
    ,'E'
    ,0
    ,0
 -- ,rec_invoice.ussgl_transaction_code - Bug 4277744
 -- ,rec_invoice.ussgl_trx_code_context - Bug 4277744
    ,decode (P_Calling_Module, 'AWT REPORT', 'P',
                               'A')
    ,rec_temp_dists.tax_rate_id
    ,ap_utilities_pkg.ap_round_currency(
        rec_temp_dists.gross_amount/nvl(l_exchange_rate,1),  --bug 8590059
        P_currency_code)
    ,rec_temp_dists.group_id
    ,rec_temp_dists.invoice_payment_id
    ,ap_invoice_distributions_s.nextval
    ,rec_temp_dists.GLOBAL_ATTRIBUTE_CATEGORY
    ,rec_temp_dists.GLOBAL_ATTRIBUTE1
    ,rec_temp_dists.GLOBAL_ATTRIBUTE2
    ,rec_temp_dists.GLOBAL_ATTRIBUTE3
    ,rec_temp_dists.GLOBAL_ATTRIBUTE4
    ,rec_temp_dists.GLOBAL_ATTRIBUTE5
    ,rec_temp_dists.GLOBAL_ATTRIBUTE6
    ,rec_temp_dists.GLOBAL_ATTRIBUTE7
    ,rec_temp_dists.GLOBAL_ATTRIBUTE8
    ,rec_temp_dists.GLOBAL_ATTRIBUTE9
    ,rec_temp_dists.GLOBAL_ATTRIBUTE10
    ,rec_temp_dists.GLOBAL_ATTRIBUTE11
    ,rec_temp_dists.GLOBAL_ATTRIBUTE12
    ,rec_temp_dists.GLOBAL_ATTRIBUTE13
    ,rec_temp_dists.GLOBAL_ATTRIBUTE14
    ,rec_temp_dists.GLOBAL_ATTRIBUTE15
    ,rec_temp_dists.GLOBAL_ATTRIBUTE16
    ,rec_temp_dists.GLOBAL_ATTRIBUTE17
    ,rec_temp_dists.GLOBAL_ATTRIBUTE18
    ,rec_temp_dists.GLOBAL_ATTRIBUTE19
    ,rec_temp_dists.GLOBAL_ATTRIBUTE20
    ,l_type_1099
    ,l_income_tax_region
    ,rec_temp_dists.org_id
    ,rec_temp_dists.awt_related_id
    ,'N'
    ,'PERMANENT' -- distribution_class bug 8620272
    );

    -- bug8879522
    debug_info := 'Adding the dist amount and dist base amount to running total';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;

    l_sum_dists :=  l_sum_dists +
                      ap_utilities_pkg.ap_round_currency
                          (l_withhold_amount,
                           p_currency_code);
    l_sum_dists_base := l_sum_dists_base +
                          ap_utilities_pkg.ap_round_currency
                           (-rec_temp_dists.base_withholding_amount,
                             l_basecur);

    debug_info := ' After processing awt_related_id '||rec_temp_dists.awt_related_id||
                  ' the totals are, '||
                  ' l_sum_dists : '||l_sum_dists||
                  ' l_sum_dists_base : '||l_sum_dists_base;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;


    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
            ( p_table_name        => 'AP_INVOICE_DISTRIBUTIONS',
              p_operation         => 'I',
              p_key_value1        =>  P_invoice_id,
              p_key_value2        =>  l_Invoice_distribution_id,
              p_calling_sequence  =>  current_calling_sequence);


    withholding_total      := withholding_total +
                              ap_utilities_pkg.ap_round_currency(
                                 rec_temp_dists.withholding_amount/
                                 nvl(l_exchange_rate,1),	--bug 8899204
                              p_currency_code);      --bug 8590059
    base_withholding_total := base_withholding_total +
                              rec_temp_dists.base_withholding_amount;


debug_info := 'withholding_total -- '||to_char(withholding_total);
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;


  END LOOP For_Each_Temporary_dist;

   debug_info := 'CLOSE CURSOR c_temp_dists';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;
  CLOSE c_temp_dists;

  -- bug8879522
  debug_info := 'Calculating the difference between the dist totals and line amount';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  l_round_amt := l_line_amt - l_sum_dists;
  l_round_base_amt := l_line_base_amt - l_sum_dists_base;

  debug_info := ' l_round_amt : '||to_char(l_round_amt)||
                ' l_round_base_amt  :'||to_char(l_round_base_amt);
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

--bug 9258669

  withholding_total := withholding_total - l_round_amt;
  base_withholding_total := base_withholding_total - l_round_base_amt;

  debug_info := ' withholding_total : '||to_char(withholding_total)||
                ' base_withholding_total  :'||to_char(base_withholding_total);
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;
--bug 9258669

  BEGIN

    SELECT max(aid.invoice_distribution_id)
      INTO l_dist_id_to_round
      FROM ap_invoice_distributions_all aid
     WHERE aid.invoice_id = P_Invoice_Id
       AND aid.line_type_lookup_code = 'AWT'
       AND abs(aid.amount) =
        (SELECT max(abs(aid1.amount))
           FROM ap_invoice_distributions_all aid1
          WHERE aid1.invoice_id = P_Invoice_Id
            AND aid1.invoice_line_number = curr_inv_line_number
            AND aid1.line_type_lookup_code = 'AWT');

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  debug_info := 'Max dist_id to round off is :'||l_dist_id_to_round;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  UPDATE ap_invoice_distributions_all aid
     SET aid.amount = aid.amount + l_round_amt,
         aid.base_amount = aid.base_amount + l_round_base_amt
   WHERE aid.invoice_id = P_Invoice_Id
     AND aid.invoice_distribution_id = l_dist_id_to_round;


  END LOOP For_Each_Temporary_line;

  debug_info := 'CLOSE CURSOR c_temp_lines';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;
  CLOSE c_line_cursor;

  -- delete temp withholding lines for thIS invoice

  debug_info := 'Delete From ap_awt_temp_distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  DELETE  ap_awt_temp_distributions_all
   WHERE  invoice_id = p_invoice_id
     AND  (P_Payment_Num IS NULL OR payment_num = P_Payment_Num);

  <<Update_Payment_Schedules>>
  DECLARE
    --Bug7707630:Cursor c_payment_sched: Added decode for BOTH
    CURSOR c_payment_sched --bug6660355
          (Createdists IN VARCHAR2
          ,PaymNum     IN NUMBER
          ,InvId       IN NUMBER
          ) IS
    SELECT gross_amount
    ,      amount_remaining
    ,      NVL(inv_curr_gross_amount, gross_Amount) inv_curr_gross_amount
    FROM ap_payment_schedules_all
    WHERE (invoice_id  = InvId)
    AND   (payment_num = decode(Createdists
                               ,'APPROVAL',payment_num, 'BOTH',
	            	       decode(P_Calling_Module,'CONFIRM',PaymNum,'QUICKCHECK',PaymNum,payment_num)
                               ,PaymNum
                               ))
   FOR UPDATE of amount_remaining;
    rec_payment_sched c_payment_sched%ROWTYPE;

    DBG_Loc VARCHAR2(30) := 'Update_Payment_Schedules';

  BEGIN
    debug_info := 'OPEN CURSOR c_payment_sched';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;

    OPEN  c_payment_sched(P_Create_dists
                         ,P_Payment_Num
                         ,P_Invoice_Id);
    --Bug7707630: Removed BOTH from the if condition
    IF (P_Create_dists in ('APPROVAL')) THEN
      -- When withholding at approval time, LOOP on all possible payments
      DECLARE
        inv_amount_before_withholding NUMBER := rec_invoice.invoice_amount;
        amount_to_subtract            NUMBER;
        pay_curr_amount_to_subtract   NUMBER;
        subtracting_cumulator         NUMBER := 0;
        CURSOR c_how_many_payments (InvId IN NUMBER)
        IS
        SELECT count(*) payments
          FROM ap_payment_schedules_all
         WHERE invoice_id  = InvId;

        num_payments NUMBER;
      BEGIN
        debug_info := 'OPEN CURSOR c_how_many_payments';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	END IF;
        OPEN  c_how_many_payments (P_Invoice_Id);

        debug_info := 'Fetch CURSOR c_how_many_payments';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;
        FETCH c_how_many_payments INTO num_payments;

        debug_info := 'CLOSE CURSOR c_how_many_payments';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;
        CLOSE c_how_many_payments;

        <<FOR_EACH_PAYMENT>>

        FOR j IN 1..num_payments LOOP

          debug_info := 'Fetch CURSOR c_payment_sched';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;
          FETCH c_payment_sched INTO rec_payment_sched;

          IF (inv_amount_before_withholding = 0) THEN
            amount_to_subtract := 0;
            l_disc_amt_factor    := 0;
          ELSE
            amount_to_subtract := withholding_total *
                                 (rec_payment_sched.inv_curr_gross_amount /
                                  inv_amount_before_withholding
                                 );
            amount_to_subtract := Ap_Utilities_Pkg.Ap_Round_Currency
                                 (amount_to_subtract ,P_Currency_Code);


	-- BUG 7000143 Old Code.
        --    l_disc_amt_factor := withholding_total /
        --                       NVL(rec_invoice.amount_applicable_to_discount,
        --                       inv_amount_before_withholding);

	-- BUG 7000143 New Code Start
			l_disc_amt_divisor := NVL(rec_invoice.amount_applicable_to_discount,
                               inv_amount_before_withholding);
			if l_disc_amt_divisor = 0 then
			  l_disc_amt_factor := 0;
			else
			  l_disc_amt_factor := withholding_total /l_disc_amt_divisor;
			end if;
        -- BUG 7000143 End
          END IF;

          IF (j < num_payments) THEN
            subtracting_cumulator := subtracting_cumulator +
                                     amount_to_subtract;
          ELSE
            -- Get last amount to subtract FROM payments amounts by difference
            -- (this is due to rounding reasons):
            amount_to_subtract    := withholding_total - subtracting_cumulator;
          END IF;

          pay_curr_amount_to_subtract := ap_utilities_pkg.ap_round_currency(
                    amount_to_subtract  * rec_invoice.payment_cross_rate,
                    rec_invoice.payment_currency_code);

          -- Update current payment schedule:
          debug_info := 'Update current payment schedule';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          UPDATE ap_payment_schedules_all
             SET amount_remaining          = amount_remaining -
                                             pay_curr_amount_to_subtract,
                 -- iyas: Following code IS in DLD but was not found originally in file:
                 discount_amount_available = discount_amount_available -
                                             ap_utilities_pkg.ap_round_currency(
                                               discount_amount_available * l_disc_amt_factor,
                                               rec_invoice.payment_currency_code),
                 second_disc_amt_available = second_disc_amt_available -
                                             ap_utilities_pkg.ap_round_currency(
                                               second_disc_amt_available *  l_disc_amt_factor,
                                               rec_invoice.payment_currency_code) ,
                 third_disc_amt_available  = third_disc_amt_available -
                                               ap_utilities_pkg.ap_round_currency(
                                               third_disc_amt_available * l_disc_amt_factor,
                                               rec_invoice.payment_currency_code)
           WHERE CURRENT of c_payment_sched;

        END LOOP For_Each_Payment;
      END;
    ELSIF (P_Calling_Module <> 'AWT REPORT') THEN
      -- otherwise subtract total withholding FROM current payment
      debug_info := 'Fetch CURSOR c_payment_sched';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;


      FETCH c_payment_sched INTO rec_payment_sched;
      debug_info := 'Update current payment schedule';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

      -- The withholding_total should be converted to payment
      -- currency before substracting it FROM the amount remaining.

      UPDATE ap_payment_schedules_all
         SET amount_remaining = (amount_remaining -
                 ap_utilities_pkg.ap_round_currency(
                 withholding_total * rec_invoice.payment_cross_rate,
                 rec_invoice.payment_currency_code))
      WHERE  current of c_payment_sched;

    END IF;  -- whether withholding at approval time or not

    debug_info := 'CLOSE CURSOR c_payment_sched';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    CLOSE c_payment_sched;
  END Update_Payment_Schedules;

  <<UPDATE_INVOICE>>
  debug_info := 'Update ap_invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  UPDATE  ap_invoices_all
     SET  awt_flag = DECODE(P_Create_dists, 'APPROVAL', 'Y','BOTH','Y', NULL), --Bug6660355
          amount_applicable_to_discount = decode (sign(invoice_amount),
                              -1, amount_applicable_to_discount,
                                  amount_applicable_to_discount
                                  - withholding_total)

   WHERE  CURRENT OF c_invoice;

  debug_info := 'CLOSE CURSOR c_invoice';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  CLOSE c_invoice;

EXCEPTION
  WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      '  Invoice Id  = '    || to_char(P_Invoice_Id) ||
                      ', Calling module = ' || P_Calling_Module ||
                      ', Create dists = '   || P_Create_dists ||
                      ', Payment Num  = '   || to_char(P_Payment_Num) ||
                      ', Currency code = '  || P_Currency_Code);

              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

END Create_AWT_distributions;

PROCEDURE Create_AWT_Invoices(
          P_Invoice_Id             IN     NUMBER,
          P_Payment_Date           IN     DATE,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          P_Calling_Sequence       IN     VARCHAR2,
          P_Calling_Module         IN     VARCHAR2 DEFAULT NULL, --Bug6660355 -- bug 8266021
          P_Inv_Line_No            IN     NUMBER DEFAULT NULL,
          P_Dist_Line_No           IN     NUMBER DEFAULT NULL,
          P_New_Invoice_Id         IN     NUMBER DEFAULT NULL,
          P_create_dists           IN     VARCHAR2 DEFAULT NULL) --Bug7685907 bug8207324 bug8236169
IS
  new_invoice_id             ap_invoices.invoice_id%TYPE;
  tax_authority_id           ap_tax_codes.awt_vendor_id%TYPE;
  tax_authority_site_id      ap_tax_codes.awt_vendor_site_id%TYPE;
  base_currency              ap_system_parameters.base_currency_code%TYPE;
  new_invoice_base_descr     ap_invoices.description%TYPE;
  inv_terms_date             DATE;
  ta_terms_id                po_vendor_sites.terms_id%TYPE;
  ta_payment_priority        po_vendor_sites.payment_priority%TYPE;
  ta_terms_date_basIS        po_vendor_sites.terms_date_basIS%TYPE;
  ta_pay_group_lookup_code   po_vendor_sites.pay_group_lookup_code%TYPE;
  ta_accts_pay_code_comb_id  po_vendor_sites.accts_pay_code_combination_id%TYPE;
  ta_payment_currency_code   po_vendor_sites.payment_currency_code%TYPE;
  c_payment_cross_rate       ap_invoices.payment_cross_rate%TYPE;
  c_payment_cross_rate_type  ap_invoices.payment_cross_rate_type%TYPE;
  l_invoice_distribution_id  ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_legal_entity_id          ap_invoices_all.legal_entity_id%type;

  l_set_of_books_id	ap_invoices_all.set_of_books_id%type;
  l_batch_id		ap_invoices_all.batch_id%type;
  l_org_id		ap_invoices_all.org_id%type;
  l_period_name		gl_period_statuses.period_name%type;

  l_line_number		ap_invoice_lines_all.line_number%type;
  l_dist_number		ap_invoice_distributions_all.distribution_line_number%type;



  l_IBY_PAYMENT_METHOD        varchar2(80);
  l_PAYMENT_REASON            varchar2(80);
  l_BANK_CHARGE_BEARER_DSP    varchar2(80);
  l_DELIVERY_CHANNEL          varchar2(80);
  l_SETTLEMENT_PRIORITY_DSP   varchar2(80);
  l_bank_account_num          varchar2(100);
  l_bank_account_name         varchar2(80);
  l_bank_branch_name          varchar2(360);
  l_bank_branch_num           varchar2(30);
  l_bank_name                 varchar2(360);
  l_bank_number               varchar2(30);
  l_PAYMENT_METHOD_CODE       varchar2(30);
  l_PAYMENT_REASON_CODE       varchar2(30);
  l_BANK_CHARGE_BEARER        varchar2(30);
  l_DELIVERY_CHANNEL_CODE     varchar2(30);
  l_SETTLEMENT_PRIORITY       varchar2(30);
  l_PAY_ALONE                 varchar2(30);
  l_external_bank_account_id  number;
  l_exclusive_payment_flag    varchar2(1);
  l_party_id                  number;
  l_party_site_id             number;
  l_payment_reason_comments   varchar2(240); --4874927

  --bug 7699166
  l_remit_party_id            NUMBER;
  l_relationship_id           NUMBER;
  l_invoice_date              DATE;
  l_remit_to_supplier_name    AP_SUPPLIERS.VENDOR_NAME%TYPE;
  l_remit_to_supplier_id      AP_SUPPLIERS.VENDOR_ID%TYPE;
  l_remit_to_supplier_site    AP_SUPPLIER_SITES.VENDOR_SITE_CODE%TYPE;
  l_remit_to_supplier_site_id AP_SUPPLIER_SITES.VENDOR_SITE_ID%TYPE;
  l_remit_to_party_site_id	  AP_SUPPLIER_SITES.PARTY_SITE_ID%TYPE; --7721149
  --bug 7699166

                                                                   --
  --8266021 changed cursor                                                                   --
  CURSOR c_awt_lines (InvId IN NUMBER,line_num in number) IS
  SELECT APID.accounting_date          accounting_date
  ,      APID.invoice_line_number      invoice_line_number
  ,      APID.distribution_line_number distribution_line_number
  ,      APID.set_of_books_id          set_of_books_id
  ,      APID.dist_code_combination_id dist_code_combination_id
  ,      APID.period_name              period_name
  ,      APID.withholding_tax_code_id  tax_code_id   /* Bug 5382525 */
  ,      APID.amount                   amount
  ,      APID.base_amount              base_amount
  ,      APID.batch_id                 batch_id
--,      APID.ussgl_transaction_code   ussgl_transaction_code - Bug 4277744
--,      APID.ussgl_trx_code_context   ussgl_trx_code_context - Bug 4277744
  ,      APID.org_id
  FROM   ap_invoice_distributions_all APID,
	 ap_invoice_distributions_all APID1,
         ap_tax_codes_all             ATC,
         ap_invoices_all              AI
  WHERE  (APID.invoice_id               = InvId)
  AND    (APID.invoice_line_number      = NVL(P_Inv_Line_No,line_num))
  AND    (APID.distribution_line_number = NVL(P_dist_Line_No,APID.distribution_line_number))
  AND    (APID.line_type_lookup_code    = 'AWT')
  AND    APID.invoice_id = APID1.invoice_id
  AND    APID.awt_related_id = APID1.invoice_distribution_id
  AND    ((APID.awt_invoice_id          IS NULL)
           OR (APID.awt_invoice_id      = P_New_Invoice_Id))
  AND    (NVL(APID.awt_flag , 'M' )     = 'A' )
  AND    APID.invoice_id                    = AI.invoice_id
  AND    APID.WITHHOLDING_TAX_CODE_ID   = ATC.tax_id  /* Bug 5382525 */
  AND    APID.amount                   <> decode (NVL(ATC.suppress_zero_amount_flag,
                                                      'N'), 'Y', 0 , APID.amount +1)
  AND    NVL(APID.reversal_flag, 'N') <> 'Y'
  AND    APID.AWT_ORIGIN_GROUP_ID        = nvl(DECODE(P_calling_module,'AUTOAPPROVAL',APID1.awt_group_id,
                                           'CANCEL INVOICE',APID1.awt_group_id,'REVERSE DIST',APID1.awt_group_id,
					   'CONFIRM',DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id, APID1.pay_awt_group_id),
					   'QUICKCHECK', DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id,APID1.pay_awt_group_id), APID1.pay_awt_group_id),-1) --6660355 --9093973
					   --Bug 7685907 Added Decode for Confirm and Quickcheck
  FOR UPDATE of APID.awt_invoice_id;



 --8266021 added new cursor
   CURSOR c_awt_lines_rev (InvId IN NUMBER,line_num in number) IS
  SELECT APID.accounting_date          accounting_date
  ,      APID.invoice_line_number      invoice_line_number
  ,      APID.distribution_line_number distribution_line_number
  ,      APID.set_of_books_id          set_of_books_id
  ,      APID.dist_code_combination_id dist_code_combination_id
  ,      APID.period_name              period_name
  ,      APID.withholding_tax_code_id  tax_code_id   /* Bug 5382525 */
  ,      APID.amount                   amount
  ,      APID.base_amount              base_amount
  ,      APID.batch_id                 batch_id
--,      APID.ussgl_transaction_code   ussgl_transaction_code - Bug 4277744
--,      APID.ussgl_trx_code_context   ussgl_trx_code_context - Bug 4277744
  ,      APID.org_id
  FROM   ap_invoice_distributions_all APID,
	 ap_invoice_distributions_all APID1,
         ap_tax_codes_all             ATC,
         ap_invoices_all              AI
  WHERE  (APID.invoice_id               = InvId)
  AND    (APID.invoice_line_number      = NVL(P_Inv_Line_No,line_num))
  AND    (APID.distribution_line_number = NVL(P_dist_Line_No,APID.distribution_line_number))
  AND    (APID.line_type_lookup_code    = 'AWT')
  AND    APID.invoice_id = APID1.invoice_id
  AND    APID.awt_related_id = APID1.invoice_distribution_id
  AND    ((APID.awt_invoice_id          IS NULL)
           OR (APID.awt_invoice_id      = P_New_Invoice_Id)
	   )
  AND    (NVL(APID.awt_flag , 'M' )     = 'A' )
  AND    APID.invoice_id                    = AI.invoice_id
  AND    APID.WITHHOLDING_TAX_CODE_ID   = ATC.tax_id  /* Bug 5382525 */
  AND    APID.amount                   <> decode (NVL(ATC.suppress_zero_amount_flag,
                                                      'N'), 'Y', 0 , APID.amount +1)
  AND    nvl(APID.parent_reversal_id,-99) <> -99
  AND    NVL(APID.reversal_flag, 'N') = 'Y'
  AND    APID.AWT_ORIGIN_GROUP_ID        = nvl(DECODE(P_calling_module,'AUTOAPPROVAL',APID1.awt_group_id,
                                           'CANCEL INVOICE',APID1.awt_group_id,'REVERSE DIST',APID1.awt_group_id,
					   'CONFIRM',DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id, APID1.pay_awt_group_id),
					   'QUICKCHECK', DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id,APID1.pay_awt_group_id), APID1.pay_awt_group_id),-1) --6660355 --9093973
					   --Bug 7685907 Added Decode for Confirm and Quickcheck
  FOR UPDATE of APID.awt_invoice_id;

  rec_awt_lines c_awt_lines%ROWTYPE;

  -- bug8266021 added 2 new cursors
  CURSOR c_awt_invs (InvId IN NUMBER) IS
  SELECT min(APID.accounting_date)          accounting_date
  ,      APID.withholding_tax_code_id  tax_code_id
  ,      sum(-1 * NVL(APID.base_amount,APID.amount))  invoice_amount  --bug 8597105
  ,	     APID.invoice_line_number
  FROM   ap_invoice_distributions_all APID,
	 ap_invoice_distributions_all APID1,
         ap_tax_codes_all             ATC,
	 AP_INVOICES_ALL	      AI
  WHERE  (APID.invoice_id               = InvId)
  AND    (APID.line_type_lookup_code    = 'AWT')
  AND    (NVL(APID.awt_flag , 'M' )     = 'A' )
  AND    APID.WITHHOLDING_TAX_CODE_ID   = ATC.tax_id
  AND    APID.invoice_id = APID1.invoice_id
  --AND    (APID.invoice_line_number      = NVL(P_Inv_Line_No,APID.invoice_line_number))
  AND    APID.awt_related_id = APID1.invoice_distribution_id
  AND    APID.amount                   <> decode (NVL(ATC.suppress_zero_amount_flag,
                                                      'N'), 'Y', 0 , APID.amount +1)
  AND    NVL(APID.reversal_flag, 'N') <> 'Y'
  AND    APID.invoice_id                    = AI.invoice_id
  AND    ((APID.awt_invoice_id          IS NULL)
           OR (APID.awt_invoice_id      = P_New_Invoice_Id)
           )		--bug 8659829
  AND    APID.AWT_ORIGIN_GROUP_ID        = nvl(DECODE(P_calling_module,'AUTOAPPROVAL',APID1.awt_group_id,
                                           'CANCEL INVOICE',APID1.awt_group_id,'REVERSE DIST',APID1.awt_group_id,
					   'CONFIRM',DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id, APID1.pay_awt_group_id),
					   'QUICKCHECK', DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id,APID1.pay_awt_group_id), APID1.pay_awt_group_id),-1)  --9093973
  GROUP By APID.withholding_tax_code_id
           ,APID.invoice_line_number;

  CURSOR c_awt_invs_rev (InvId IN NUMBER) IS
  SELECT min(APID.accounting_date)          accounting_date
  ,      APID.withholding_tax_code_id  tax_code_id
  ,      sum(-1 * NVL(APID.base_amount,APID.amount))  invoice_amount  --bug 8597105
  ,	     APID.invoice_line_number
  FROM   ap_invoice_distributions_all APID,
	 ap_invoice_distributions_all APID1,
         ap_tax_codes_all             ATC,
	 AP_INVOICES_ALL	      AI
  WHERE  (APID.invoice_id               = InvId)
  AND    (APID.line_type_lookup_code    = 'AWT')
  AND    (NVL(APID.awt_flag , 'M' )     = 'A' )
  AND    APID.WITHHOLDING_TAX_CODE_ID   = ATC.tax_id
  AND    APID.invoice_id = APID1.invoice_id
  --AND    (APID.invoice_line_number      = NVL(P_Inv_Line_No,APID.invoice_line_number))
  AND    APID.awt_related_id = APID1.invoice_distribution_id
  AND    APID.amount                   <> decode (NVL(ATC.suppress_zero_amount_flag,
                                                      'N'), 'Y', 0 , APID.amount +1)
  AND    NVL(APID.reversal_flag, 'N') = 'Y'
  AND    nvl(APID.parent_reversal_id,-99) <> -99
  AND    APID.invoice_id                    = AI.invoice_id
  AND    ((APID.awt_invoice_id          IS NULL)
           OR (APID.awt_invoice_id      = P_New_Invoice_Id)
           )		--bug 8659829
 AND    APID.AWT_ORIGIN_GROUP_ID        = nvl(DECODE(P_calling_module,'AUTOAPPROVAL',APID1.awt_group_id,
                                           'CANCEL INVOICE',APID1.awt_group_id,'REVERSE DIST',APID1.awt_group_id,
					   'CONFIRM',DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id, APID1.pay_awt_group_id),
					   'QUICKCHECK', DECODE(P_create_dists,'APPROVAL',
					   APID1.awt_group_id,APID1.pay_awt_group_id), APID1.pay_awt_group_id),-1)   --9093973
  GROUP By APID.withholding_tax_code_id
           ,APID.invoice_line_number;

  rec_awt_invs c_awt_invs%ROWTYPE;

  --bug 8266021    added last 3 more values                                                                    --
  CURSOR c_base_invoice_description (InvId IN NUMBER) IS
  SELECT substrb(
          substrb(Ap_Utilities_Pkg.Ap_Get_DISplayed_Field('NLS TRANSLATION'  , 'AWT'),1,25)||
                ' - '||
                v.vendor_name||
                ' - '||
                i.invoice_num||
                ' /' --4940604
               ,1
               , 234
               ) description,
         i.legal_entity_id,
	 i.set_of_books_id,
	 i.batch_id,
	 i.org_id
  FROM   po_vendors  v
  ,      ap_invoices_all i
  WHERE  (v.vendor_id  = i.vendor_id)
  AND    (i.invoice_id = InvId);

  DBG_Loc                     VARCHAR2(30) := 'Create_AWT_Invoices';
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  goods_received_date         DATE;
  invoice_received_date       DATE;

BEGIN

  current_calling_sequence := 'AP_WITHHOLDING_PKG.Create_AWT_Invoices<-' ||
                              P_Calling_Sequence;

  -- Get base invoice description to insert in every new generated invoice

  debug_info := 'OPEN CURSOR c_base_invoice_description';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  OPEN  c_base_invoice_description (P_Invoice_Id);

  debug_info := 'Fetch CURSOR c_base_invoice_description';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
--bug 8266021 added 3 more variables
  FETCH c_base_invoice_description
  INTO  new_invoice_base_descr,
	l_legal_entity_id,
	l_set_of_books_id,
	l_batch_id,
	l_org_id;

  debug_info := 'CLOSE CURSOR c_base_invoice_description';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  CLOSE c_base_invoice_description;


  --Bug 8266021 inv cursor called based on calling module
  --This cursor will fetch info required to insert into
  --ap_invoices_all and ap_invoice_lines_all
   debug_info := 'OPEN CURSOR c_awt_invs';

   IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST','VOID PAYMENT')) THEN
      OPEN  c_awt_invs_rev (P_Invoice_Id);
    ELSE
      OPEN  c_awt_invs (P_Invoice_Id);
    END IF;



  <<FOR_EACH_NEGATIVE_LINE>>
  LOOP
    debug_info := 'Fetch CURSOR for invoices (c_awt_invs_rev or c_awt_invs )';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

	   debug_info := 'P_Calling_Module '|| P_Calling_Module;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;



    IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST','VOID PAYMENT')) THEN
      FETCH c_awt_invs_rev INTO rec_awt_invs;
      EXIT WHEN c_awt_invs_rev%NOTFOUND;

       debug_info := 'c_awt_invs_rev rows chosen'||c_awt_invs_rev%ROWCOUNT;
   	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
    ELSE
      FETCH c_awt_invs INTO rec_awt_invs;
      EXIT WHEN c_awt_invs%NOTFOUND;

      debug_info := 'c_awt_invs rows chosen'||c_awt_invs%ROWCOUNT;
   	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
    END IF;

    -- Start: Create invoice payable to Tax Authority for thIS negative line:
    -- First get tax authority site AND new invoice_id from sequence:

    <<TAX_AUTHORITY_INFO>>
    DECLARE
      CURSOR c_tax_authority (TaxId IN NUMBER)
      IS
      SELECT t.awt_vendor_id,
             t.awt_vendor_site_id,
             NVL(s.payment_currency_code, s.invoice_currency_code),
             NVL(P_New_Invoice_Id, ap_invoices_s.nextval),
             p.base_currency_code,
             s.terms_id,
             s.payment_priority,
             s.terms_date_basis,
             s.pay_group_lookup_code,
             s.accts_pay_code_combination_id,
             s.party_site_id,
             pv.party_id
      FROM   ap_tax_codes_all         t,
             ap_system_parameters_all p,
             po_vendor_sites_all      s,
             po_vendors               pv
      WHERE  t.tax_id         = TaxId
        AND  pv.vendor_id     = s.vendor_id /* Bug 4724120 */
        AND  s.vendor_id      = t.awt_vendor_id
        AND  s.vendor_site_id = t.awt_vendor_site_id
        AND  p.org_id         = t.org_id;
    BEGIN
      debug_info := 'OPEN CURSOR c_tax_authority';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

     --bug 8266021 changed cursor parameter
      OPEN  c_tax_authority(rec_awt_invs.tax_code_id);

      debug_info := 'Fetch CURSOR c_tax_authority';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

      FETCH c_tax_authority
      INTO  tax_authority_id,
            tax_authority_site_id,
            ta_payment_currency_code,
            new_invoice_id,
            base_currency,
            ta_terms_id,
            ta_payment_priority,
            ta_terms_date_basis,
            ta_pay_group_lookup_code,
            ta_accts_pay_code_comb_id,
            l_party_site_id,
            l_party_id;

      IF c_tax_authority%NOTFOUND THEN
        NULL;
      END IF;

      debug_info := 'CLOSE CURSOR c_tax_authority';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

      CLOSE c_tax_authority;
    END Tax_Authority_Info;


	 /**
	    bug 7699166 -- The following call is made to set the remittance details
	    related to Third Party Payments
	 */
	 --bug 8266021 changed cursor parameter
	   l_invoice_date := NVL(P_Payment_Date,rec_awt_invs.accounting_date);

	   IBY_EXT_PAYEE_RELSHIPS_PKG.default_Ext_Payee_Relationship(
	   p_party_id => l_party_id,
	   p_supplier_site_id => tax_authority_site_id,
	   p_date => l_invoice_date,
	   x_remit_party_id => l_remit_party_id,
	   x_remit_supplier_site_id => l_remit_to_supplier_site_id,
	   x_relationship_id => l_relationship_id
	  );

	  -- Added if else condition as part of bug 8345877
	  IF (l_relationship_id <> -1) THEN
		select vendor_id, vendor_name into l_remit_to_supplier_id, l_remit_to_supplier_name
		from ap_suppliers where party_id = l_remit_party_id and rownum<2;

		select party_site_id, vendor_site_code into l_remit_to_party_site_id,
		l_remit_to_supplier_site from ap_supplier_sites where vendor_site_id = l_remit_to_supplier_site_id
		and rownum<2;
	  ELSE
		l_remit_party_id := null;
		l_remit_to_party_site_id := null;
		l_remit_to_supplier_id := null;
		l_remit_to_supplier_name := null;
		l_remit_to_supplier_site_id := null;
		l_remit_to_supplier_site := null;
	  END IF;
	  -- retrieving party_site_id also as part of bug 7721149

	  --bug 7699166


    --4610924, added this call to get payment attributes
    -- Added nvl conditions for p_payee_party_id, p_payee_party_site_id, p_supplier_site_id
    -- as part of bug 8345877
    ap_invoices_pkg.get_payment_attributes(
        p_le_id                     =>l_legal_entity_id,
        p_org_id                    =>rec_awt_lines.org_id,
        p_payee_party_id            =>   nvl(l_remit_party_id, l_party_id), --bug 	7721149, replacing l_party_id for Third Party Payments
        p_payee_party_site_id       => nvl(l_remit_to_party_site_id, l_party_site_id), --bug 	7721149, replacing l_party_site_id for Third Party Payments
        p_supplier_site_id          => nvl(l_remit_to_supplier_site_id, tax_authority_site_id), -- bug 	7721149 replacing tax_authority_site_id
        p_payment_currency          =>ta_payment_currency_code,
        p_payment_amount            =>rec_awt_invs.invoice_amount,    --bug 8266021
        p_payment_function          =>'PAYABLES_DISB',
        p_pay_proc_trxn_type_code   =>'PAYABLES_DOC',

        p_PAYMENT_METHOD_CODE       => l_payment_method_code,
        p_PAYMENT_REASON_CODE       => l_payment_reason_code,
        p_BANK_CHARGE_BEARER        => l_bank_charge_bearer,
        p_DELIVERY_CHANNEL_CODE     => l_delivery_channel_code,
        p_SETTLEMENT_PRIORITY       => l_settlement_priority,
        p_PAY_ALONE                 => l_exclusive_payment_flag,
        p_external_bank_account_id  => l_external_bank_account_id,

        p_IBY_PAYMENT_METHOD        => l_IBY_PAYMENT_METHOD,
        p_PAYMENT_REASON            => l_PAYMENT_REASON,
        p_BANK_CHARGE_BEARER_DSP    => l_BANK_CHARGE_BEARER_DSP,
        p_DELIVERY_CHANNEL          => l_DELIVERY_CHANNEL,
        p_SETTLEMENT_PRIORITY_DSP   => l_SETTLEMENT_PRIORITY_DSP,
        p_bank_account_num          => l_bank_account_num,
        p_bank_account_name         => l_bank_account_name,
        p_bank_branch_name          => l_bank_branch_name,
        p_bank_branch_num           => l_bank_branch_num,
        p_bank_name                 => l_bank_name,
        p_bank_number               => l_bank_number,
        p_payment_reason_comments   => l_payment_reason_comments); --4874927


    debug_info := 'Get Exchange Rate'||'pc: '||ta_payment_currency_code||
                  ' bc: '||base_currency||' date: '||
                   to_char(rec_awt_lines.accounting_date, 'DD-MON-YYYY');
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    --bug 8266021 changed the parameters from rec_awt_lines to rec_awt_invs
    IF ( gl_currency_api.is_fixed_rate(ta_payment_currency_code,
                                       base_currency,
                                       rec_awt_invs.accounting_date) = 'Y'  AND
         ta_payment_currency_code <> base_currency ) THEN

         c_payment_cross_rate := gl_currency_api.get_rate(base_currency,
                                     ta_payment_currency_code,
                                     rec_awt_invs.accounting_date,
                                     'EMU FIXED');
         c_payment_cross_rate_type := 'EMU FIXED';
    ELSE
         c_payment_cross_rate      :=  1;
         ta_payment_currency_code  := base_currency;
         c_payment_cross_rate_type := '';
    END IF;

    IF ta_terms_date_basis IN ('Goods Received', 'Invoice Received') THEN
       SELECT  invoice_received_date,
               goods_received_date
         INTO  invoice_received_date,
               goods_received_date
         FROM  ap_invoices_all
        WHERE  invoice_id = P_Invoice_Id;
    END IF;

     --added for bug 8266021 to fetch period
    SELECT DISTINCT gps.Period_Name
      INTO l_period_name
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
     WHERE gps.Application_Id = 200
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND rec_awt_invs.accounting_date BETWEEN Trunc(gps.Start_Date)
                              AND Trunc(gps.End_Date)
       AND Nvl(Asp.Org_Id,- 99) = Nvl(l_org_id,- 99);
   --    AND gps.closing_Status in ('O', 'F');
--bug 9304565 commented the above condition as part of this bug.

    debug_info := 'Insert Into ap_invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

   INSERT INTO ap_invoices_all
    (invoice_id
    ,last_UPDATE_date
    ,last_UPDATEd_by
    ,vendor_id
    ,invoice_num
    ,set_of_books_id
    ,invoice_currency_code
    ,payment_currency_code
    ,payment_cross_rate
    ,invoice_amount
    ,pay_curr_invoice_amount
    ,payment_cross_rate_type
    ,payment_cross_rate_date
    ,vendor_site_id
    ,amount_paid
    ,discount_amount_taken
    ,invoice_date
    ,source
    ,invoice_type_lookup_code
    ,description
    ,batch_id
    ,amount_applicable_to_discount
    ,terms_id
    ,terms_date
    ,pay_group_lookup_code
    ,accts_pay_code_combination_id
    ,payment_status_flag
    ,creation_date
    ,created_by
    ,last_UPDATE_login
    ,doc_sequence_id
    ,doc_sequence_value
    ,doc_category_code
    ,posting_status
 -- ,ussgl_transaction_code - Bug 4277744
 -- ,ussgl_trx_code_context - Bug 4277744
    ,payment_amount_total
    ,gl_date
    ,approval_ready_flag
    ,wfapproval_status
    ,org_id
    ,legal_entity_id
    ,auto_tax_calc_flag     -- BUG 3007085
    ,PAYMENT_METHOD_CODE
    ,PAYMENT_REASON_CODE
    ,BANK_CHARGE_BEARER
    ,DELIVERY_CHANNEL_CODE
    ,SETTLEMENT_PRIORITY
    ,exclusive_payment_flag
    ,external_bank_account_id
    ,party_id
    ,party_site_id
    ,payment_reason_comments
	--bug 7699166 changes for Third Party Payments
	,remit_to_supplier_name
	,remit_to_supplier_id
	,remit_to_supplier_site
	,remit_to_supplier_site_id
	,relationship_id
	--bug 7699166
    )
    VALUES
    (new_invoice_id
    ,SYSDATE
    ,5
    ,tax_authority_id
    ,DECODE( p_calling_sequence, 'AP_WITHHOLDING_PKG.AP_Undo_Withholding',
             substrb(Ap_Utilities_Pkg.Ap_Get_DISplayed_Field('NLS TRANSLATION', 'AWT'),1,25)
             ||' - '||to_char(P_invoice_id)||' - ' || to_char(rec_awt_invs.invoice_line_number)
             || ' - ' ||  Ap_Utilities_Pkg.Ap_Get_DISplayed_Field('NLS TRANSLATION','CANCELLED'),
             substrb(Ap_Utilities_Pkg.Ap_Get_DISplayed_Field('NLS TRANSLATION', 'AWT'),1,25)||
             ' - '||to_char(P_invoice_id)||' - ' || to_char(rec_awt_invs.invoice_line_number)
           )
    ,l_set_of_books_id
    ,base_currency
    ,ta_payment_currency_code
    ,c_payment_cross_rate
    ,rec_awt_invs.invoice_amount
    ,gl_currency_api.convert_amount(
                        base_currency,
                        ta_payment_currency_code,
                        rec_awt_invs.accounting_date,
                        c_payment_cross_rate_type,
                        rec_awt_invs.invoice_amount)
    ,c_payment_cross_rate_type
    ,rec_awt_invs.accounting_date
    ,tax_authority_site_id
    ,0
    ,0
    ,NVL(P_Payment_Date,rec_awt_invs.accounting_date)
    ,substrb(Ap_Utilities_Pkg.Ap_Get_DISplayed_Field('NLS TRANSLATION', 'AWT'),1,25)
    ,'AWT'
    ,new_invoice_base_descr
    ,l_batch_id
    ,decode(sign(rec_awt_invs.invoice_amount),
         -1, 0, rec_awt_invs.invoice_amount)
    ,ta_terms_id
    ,decode(ta_terms_date_basIS
            ,'Current', SYSDATE
            ,'Invoice', NVL(p_payment_date,
                        rec_awt_invs.accounting_date)
            ,'Goods Received', NVL(goods_received_date,
                        rec_awt_invs.accounting_date)
            ,'Invoice Received', NVL(invoice_received_date,
                        rec_awt_invs.accounting_date)
            ,NULL)
    ,ta_pay_group_lookup_code
    ,ta_accts_pay_code_comb_id
    ,'N'
    ,SYSDATE
    ,5
    ,P_Last_Update_Login
    ,NULL
    ,NULL
    ,NULL
    ,'N'
 -- ,rec_awt_lines.ussgl_transaction_code - Bug 4277744
 -- ,rec_awt_lines.ussgl_trx_code_context - Bug 4277744
    ,NULL
    ,NVL(P_Payment_Date,rec_awt_invs.accounting_date)
    ,'Y'
    ,'NOT REQUIRED'
    ,l_org_id
    ,l_legal_entity_id
    ,'N'       -- BUG 3007085
    ,nvl(l_payment_method_code,'CHECK')
    ,l_payment_reason_code
    ,l_bank_charge_bearer
    ,l_delivery_channel_code
    ,l_settlement_priority
    ,l_exclusive_payment_flag
    ,l_external_bank_account_id
    ,l_party_id
    ,l_party_site_id
    ,l_payment_reason_comments --4874927
	--bug 7699166 changes for Third Party Payments
    ,l_remit_to_supplier_name
	,l_remit_to_supplier_id
	,l_remit_to_supplier_site
	,l_remit_to_supplier_site_id
	,l_relationship_id
	--bug 7699166
   );

     --Bug 4539462 DBI logging
     AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name        => 'AP_INVOICES',
               p_operation         => 'I',
               p_key_value1        => new_invoice_id,
               p_calling_sequence  => current_calling_sequence);


    -- Insert Invoice Lines for each invoice inserted (bug 8266021)

     debug_info := 'Insert INTO ap_invoice_lines_all';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

     INSERT INTO AP_INVOICE_LINES_all (
       invoice_id,
       line_number,
       line_type_lookup_code,
       description,
       line_source,
       generate_dists,
       match_type,
       prorate_across_all_items,
       accounting_date,
       period_name,
       deferred_acctg_flag,
       set_of_books_id,
       amount,
       base_amount,
       rounding_amt,
       wfapproval_status,
    -- ussgl_transaction_code, - Bug 4277744
       discarded_flag,
       cancelled_flag,
       final_match_flag,
       assets_tracking_flag,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       org_id
       )
     VALUES
       (
       new_invoice_id,
       1,
       'ITEM'
       ,new_invoice_base_descr||to_char(rec_awt_invs.invoice_line_number),
       'AUTO INVOICE CREATION',
       'D',
       'NOT MATCHED',
       'N',
       NVL(P_Payment_Date,rec_awt_invs.accounting_date),
       NVL(ap_utilities_pkg.get_current_gl_date(P_Payment_Date, l_org_id),
           l_period_name),
       'N',
       l_set_of_books_id,
       rec_awt_invs.invoice_amount,
       null, -- bug 5190989
       0,
       'NOT REQUIRED',
    -- rec_awt_lines.ussgl_transaction_code, - Bug 4277744
       'N',
       'N',
       'N',
       'N',
       SYSDATE,
       P_Last_Updated_By,
       SYSDATE,
       P_Last_Updated_By,
       P_Last_Update_Login,
       P_Program_Application_ID,
       P_Program_ID,
       SYSDATE,
       P_request_ID,
       l_org_id);

--To be resolved by DBI forward porting project.
/*
    AP_DBI_PKG.Maintain_DBI_Summary
           (p_table_name          => 'AP_INVOICE_DISTRIBUTIONS',
              p_operation         => 'I',
              p_key_value1        => new_invoice_id,
              p_key_value2        => l_Invoice_distribution_Id,
              p_calling_sequence  => current_calling_sequence); */


  debug_info := 'invoice_id = '||P_Invoice_Id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;


   debug_info := 'invoiceline_number =  '||rec_awt_invs.invoice_line_number;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;


    IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST','VOID PAYMENT')) THEN
       OPEN  c_awt_lines_rev (P_Invoice_Id,rec_awt_invs.invoice_line_number);

       debug_info := 'c_awt_lines_rev chosen';
   	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

	  debug_info := 'rows chosen'||c_awt_lines_rev%ROWCOUNT;
   	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
    ELSE
      OPEN  c_awt_lines (P_Invoice_Id,rec_awt_invs.invoice_line_number);
      debug_info := 'c_awt_lines chosen';
   	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

	  debug_info := 'rows chosen'||c_awt_lines%ROWCOUNT;
   	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
    END IF;
    l_dist_number := 0;

   ---Bug 8266021 now the distributions are inserted for the Withholding invoice
   --Here also we will decide the cursor based on the calling module
    LOOP
    debug_info := 'Fetch CURSOR c_awt_lines';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;



    IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST','VOID PAYMENT')) THEN
     FETCH c_awt_lines_rev INTO rec_awt_lines;
    EXIT WHEN c_awt_lines_rev%NOTFOUND;


    ELSE
     FETCH c_awt_lines INTO rec_awt_lines;
    EXIT WHEN c_awt_lines%NOTFOUND;

    END IF;

    l_dist_number := l_dist_number + 1 ;

    debug_info := 'Insert INTO ap_invoice_distributions';
 	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    SELECT ap_invoice_distributions_s.nextval
    INTO   l_invoice_distribution_id
    FROM DUAL;


      INSERT INTO ap_invoice_distributions_all (
     accounting_date
    ,accrual_posted_flag
    ,assets_addition_flag
    ,assets_tracking_flag
    ,cash_posted_flag
    ,distribution_line_number
    ,dist_code_combination_id
    ,invoice_id
    ,invoice_line_number
    ,last_updated_by
    ,last_update_date
    ,line_type_lookup_code
    ,period_name
    ,set_of_books_id
    ,amount
    ,base_amount
    ,batch_id
    ,created_by
    ,creation_date
    ,description
    ,last_update_login
    ,match_status_flag
    ,posted_flag
    ,program_application_id
    ,program_id
    ,program_UPDATE_date
    ,request_id
    ,tax_code_id
    ,encumbered_flag
    ,pa_addition_flag
    ,posted_amount
    ,posted_base_amount
    ,awt_flag
    ,awt_tax_rate_id
    ,awt_gross_amount
    ,awt_origin_group_id
    ,awt_invoice_payment_id
    ,invoice_distribution_id
    ,GLOBAL_ATTRIBUTE_CATEGORY
    ,GLOBAL_ATTRIBUTE1
    ,GLOBAL_ATTRIBUTE2
    ,GLOBAL_ATTRIBUTE3
    ,GLOBAL_ATTRIBUTE4
    ,GLOBAL_ATTRIBUTE5
    ,GLOBAL_ATTRIBUTE6
    ,GLOBAL_ATTRIBUTE7
    ,GLOBAL_ATTRIBUTE8
    ,GLOBAL_ATTRIBUTE9
    ,GLOBAL_ATTRIBUTE10
    ,GLOBAL_ATTRIBUTE11
    ,GLOBAL_ATTRIBUTE12
    ,GLOBAL_ATTRIBUTE13
    ,GLOBAL_ATTRIBUTE14
    ,GLOBAL_ATTRIBUTE15
    ,GLOBAL_ATTRIBUTE16
    ,GLOBAL_ATTRIBUTE17
    ,GLOBAL_ATTRIBUTE18
    ,GLOBAL_ATTRIBUTE19
    ,GLOBAL_ATTRIBUTE20
    ,type_1099
    ,income_tax_region
    ,org_id
    ,awt_related_id
    --Freight and Special Charges
    ,rcv_charge_addition_flag
    ,distribution_class)        --bug7719929
     VALUES
    (
     NVL(P_Payment_Date,rec_awt_lines.accounting_date)
    ,'N'
    ,'N'
    ,'N'
    ,'N'
    ,l_dist_number                        -- distribution_line_number
    ,rec_awt_lines.dist_code_combination_id
    ,new_Invoice_Id
    ,1                        -- invoice_line_number
    ,P_Last_Updated_By
    ,SYSDATE
    ,'ITEM'
    , NVL(ap_utilities_pkg.get_current_gl_date(P_Payment_Date, rec_awt_lines.org_id),
           rec_awt_lines.period_name)
    ,rec_awt_lines.set_of_books_id
    ,-NVL(rec_awt_lines.base_amount, rec_awt_lines.amount)
    ,NULL   -- base amount bug 5190989
    ,NULL   -- batch_id
    ,P_Last_Updated_By
    ,SYSDATE
    ,new_invoice_base_descr||to_char(rec_awt_lines.distribution_line_number)
    ,P_Last_Update_Login
    ,NULL         -- match_status_flag
    ,'N'         -- posted_flag
    ,P_Program_Application_Id
    ,P_Program_Id
    ,decode (P_Program_Id,NULL,NULL,SYSDATE)
    ,P_Request_Id
    ,NULL        -- tax_code_id
    ,'T'         -- encumbered_flag
    ,'E'         -- pa_addition_flag
    ,0
    ,0
    ,NULL   -- awt_flag
    ,NULL   -- awt_tax_rate_id
    ,NULL   -- awt_gross_amount
    ,NULL   -- awt_origin_group_id
    ,NULL   -- awt_invoice_payment_id
    ,l_invoice_distribution_id
    ,NULL   -- Global Attribute Category
    ,NULL   -- Global Attribute1
    ,NULL
    ,NULL
    ,NULL
    ,NULL   -- Global Attribute5
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL   -- Global Attribute10
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL   -- Global Attribute15
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL   -- Global Attribute20
    ,NULL   -- type_1099
    ,NULL   -- income_tax_region
    ,rec_awt_lines.org_id
    ,NULL   -- awt_related_id
    ,'N'
    ,'PERMANENT'); -- bug 8304036: modify

     AP_DBI_PKG.Maintain_DBI_Summary
            ( p_table_name        => 'AP_INVOICE_DISTRIBUTIONS',
              p_operation         => 'I',
              p_key_value1        =>  new_invoice_id,
              p_key_value2        =>  l_invoice_distribution_id,
              p_calling_sequence  =>  current_calling_sequence);

    --bug 8266021
    debug_info := 'Update ap_invoice_distributions';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
    END IF;

    IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST','VOID PAYMENT')) THEN
     UPDATE  ap_invoice_distributions_all
       SET  awt_invoice_id = new_invoice_id
     WHERE  current of c_awt_lines_rev;
    ELSE
     UPDATE  ap_invoice_distributions_all
       SET  awt_invoice_id = new_invoice_id
     WHERE  current of c_awt_lines;

     END IF;


   end loop;

    IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST','VOID PAYMENT')) THEN
     close c_awt_lines_rev;
    ELSE
     close c_awt_lines;

    END IF;
    -- Prepare Terms_Date argument for Payment Schedule Creation
    -- PL/SQL

    IF (ta_terms_date_basIS = 'Current') THEN
      inv_terms_date := SYSDATE;
    ELSIF (ta_terms_date_basIS = 'Invoice') THEN
      inv_terms_date := NVL(p_payment_date, rec_awt_lines.accounting_date);
    ELSIF (ta_terms_date_basIS = 'Goods Received') THEN
      inv_terms_date := NVL(goods_received_date, rec_awt_lines.accounting_date);
    ELSIF (ta_terms_date_basIS = 'Invoice Received') THEN
      inv_terms_date := NVL(invoice_received_date,
                        rec_awt_lines.accounting_date);
    ELSE
      inv_terms_date := NULL;
    END IF;

    -- Create payment schedule for thIS new invoice:

    Ap_Create_Pay_Scheds_Pkg.Ap_Create_From_Terms
                            (new_invoice_id
                            ,ta_terms_id
                            ,P_Last_Updated_By
                            ,P_Last_Updated_By
                            ,ta_payment_priority
                            ,l_batch_id                   --bug 8266021
                            ,inv_terms_date
                            ,rec_awt_invs.invoice_amount   --bug 8266021
                            ,gl_currency_api.convert_amount(
                                base_currency,
                                ta_payment_currency_code,
                                rec_awt_invs.accounting_date,   --bug 8266021
                                c_payment_cross_rate_type,
                                rec_awt_invs.invoice_amount)   --bug 8266021
                            ,c_payment_cross_rate
                            ,NULL
                            ,nvl(l_PAYMENT_METHOD_CODE,'CHECK')
                            ,base_currency
                            ,ta_payment_currency_code
                            ,'ap_do_withholding');

    -- End: Update original negative distribution with new invoice id:

   /* commented in bug 8266021 ,this update has been moved up
    debug_info := 'Update ap_invoice_distributions';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    UPDATE  ap_invoice_distributions_all
       SET  awt_invoice_id = new_invoice_id
     WHERE  current of c_awt_lines;
   */

  END LOOP For_Each_Negative_Line;

  --bug 8266021
  debug_info := 'CLOSE CURSOR c_awt_invs (or c_awt_invs_rev) ';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
   IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST','VOID PAYMENT')) THEN
        CLOSE c_awt_invs_rev;
    ELSE
      CLOSE c_awt_invs;

    END IF;

EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      '  Invoice Id  = '    || to_char(P_Invoice_Id) ||
                      ', dist line no  = '  || to_char(P_dist_Line_No) ||
                      ', New Invoice Id = ' || to_char(P_New_Invoice_Id));

              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Create_AWT_Invoices;


PROCEDURE Ap_Do_Withholding (
          P_Invoice_Id             IN     NUMBER,
          P_Awt_Date               IN     DATE,
          P_Calling_Module         IN     VARCHAR2,
          P_Amount                 IN     NUMBER,
          P_Payment_Num            IN     NUMBER   DEFAULT NULL,
          P_Checkrun_Name          IN     VARCHAR2 DEFAULT NULL,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER   DEFAULT NULL,
          P_Program_Id             IN     NUMBER   DEFAULT NULL,
          P_Request_Id             IN     NUMBER   DEFAULT NULL,
          P_Awt_Success            OUT NOCOPY    VARCHAR2,
          P_Invoice_Payment_Id     IN     NUMBER   DEFAULT NULL,
          P_Check_Id               IN     NUMBER   DEFAULT NULL,
          p_checkrun_id            in     number   default null)
IS
  l_awt_flag       ap_invoices.awt_flag%TYPE;
  l_inv_curr_code  ap_invoices.invoice_currency_code%TYPE;
  l_tax_name       ap_tax_codes.name%TYPE;
  l_payment_date   DATE := p_awt_date;
  l_org_id         number; --4742265

  -- The variable "l_AWT_success" checks general WT calculations in the first
  -- processing unit (Create Temporary AWT distributions), causing a return
  -- error message in the following cases:
  -- o  The invoice has one inactive group
  -- o  One Tax in any group IS inactive
  -- o  One Tax Account IS invalid
  -- o  One Tax has no valid rate

  l_AWT_success    VARCHAR2(2000) := 'SUCCESS';

  DBG_Loc     VARCHAR2(30)  := 'Ap_Do_Withholding';
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
                                                                         --
/*

<< Beginning of Ap_Do_Withholding program documentation >>

   ThIS IS the core PROCEDURE of the Automatic Withholding Tax feature. It
   can be invoked by five possible originating events:

   - Invoice Autoapproval
   - AutoSELECT / Build Payments
   - Confirm Payment Batch
   - Invoice Entry / Inquiry
   - QuickCheck

   Three dIFferent processing units ("Create Temporary AWT distributions",
   "Create AWT distributions" AND "Create AWT Invoices") are conditionally
   executed depENDing on the originating event triggering the Ap_Do_Withholding
   PROCEDURE, as represented in the following flow diagrams:

+=========================+
|                         |
|      AutoApproval       |
|                         |
+=========================+
             |
             |
             ^
           /   \
          /     \
         /       \
        / create_ \        +------------------------------------+
       / dists =   \_______|                                    |
       \ APPROVAL  /  Yes  | Create Temporary AWT distributions |
        \/BOTH    /        |                                    |
         \   ?   /         +------------------+-----------------+
          \     /                             |
           \   /                              |
             v                                |
          No |                                |
             |             +------------------+-----------------+
             |             |                                    |
             |             | Create AWT distributions           |
             |             |                                    |
             |             +------------------+-----------------+
             |                                |
             +--------------------------------+
             |
             ^
           /   \
          /     \
         /       \
        / create_ \        +------------------------------------+
       / invoices  \_______|                                    |
       \= APPROVAL /  Yes  | Create AWT Invoices                |
        \ /BOTH   /        |                                    |
         \   ?   /         +------------------+-----------------+
          \     /                             |
           \   /                              |
             v                                |
          No |                                |
             |                                |
             +--------------------------------+
             |
        +----+----+
        |  DONE   |
        +---------+

+===========================+
|                           |
| AutoSelect/Build Payments |
|                           |
+===========================+
             |
             |
             ^
           /   \
          /     \
         /       \
        / create_ \        +------------------------------------+
       / dists =   \_______|                                    |
       \  PAYMENT  / Yes   | Create Temporary AWT distributions |
        \ /BOTH   /        |                                    |
         \   ?   /         +------------------+-----------------+
          \     /                             |
           \   /                              |
             v                                |
          No |                                |
             +--------------------------------+
             |
             |             +------------------------------------+
             |             |                                    |
             |             | Create AWT distributions           |
             |             |                                    |
             |             +------------------------------------+
             |
             |             +------------------------------------+
             |             |                                    |
             |             | Create AWT Invoices                |
             |             |                                    |
             |             +------------------------------------+
             |
        +----+----+
        |  DONE   |
        +---------+


+=========================+
|                         |
|  Confirm Payment Batch  |
|                         |
+=========================+
             |
             |             +------------------------------------+
             |             |                                    |
             |             | Create Temporary AWT distributions |
             |             |                                    |
             |             +------------------------------------+
             ^
           /   \
          /     \
         /       \
        / create_ \        +------------------------------------+
       / dists =   \_______|                                    |
       \  PAYMENT  / Yes   | Create AWT distributions           |
        \ /BOTH   /        |                                    |
         \   ?   /         +------------------+-----------------+
          \     /                             |
           \   /                              |
             v                                |
          No |                                |
             +--------------------------------+
             |
             ^
           /   \
          /     \
         /       \
        / create_ \        +------------------------------------+
       / invoices  \_______|                                    |
       \ = PAYMENT / Yes   | Create AWT Invoices                |
        \ /BOTH   /        |                                    |
         \   ?   /         +------------------+-----------------+
          \     /                             |
           \   /                              |
             v                                |
          No |                                |
             +--------------------------------+
             |
        +----+----+
        |  DONE   |
        +---------+


+=========================+
|                         |
|  Invoice Entry/Inquiry  |
|                         |
+=========================+
             |             +------------------------------------+
             |_____________|                                    |
                           | Create Temporary AWT distributions |
                           |                                    |
                           +------------------+-----------------+
                                              |
             +--------------------------------+
             |
             |             +------------------------------------+
             |             |                                    |
             |             | Create AWT distributions           |
             |             |                                    |
             |             +------------------------------------+
             |
             |             +------------------------------------+
             |             |                                    |
             |             | Create AWT Invoices                |
             |             |                                    |
             |             +------------------------------------+
        +----+----+
        |  DONE   |
        +---------+


+=========================+
|                         |
|       QuickCheck        |
|                         |
+=========================+
             |
             |
             ^
           /   \
          /     \
         /       \
        / create_ \        +------------------------------------+
       / dists =   \_______|                                    |
       \  PAYMENT  / Yes   | Create Temporary AWT distributions |
        \ /BOTH   /        |                                    |
         \   ?   /         +------------------+-----------------+
          \     /                             |
           \   /                              |
             v                                |
          No |                                |
             |             +------------------+-----------------+
             |             |                                    |
             |             | Create AWT distributions           |
             |             |                                    |
             |             +------------------+-----------------+
             |                                |
             +--------------------------------+
             |
             ^
           /   \
          /     \
         /       \
        / create_ \        +------------------------------------+
       / invoices  \_______|                                    |
       \ = PAYMENT / Yes   | Create AWT Invoices                |
        \ /BOTH   /        |                                    |
         \   ?   /         +------------------+-----------------+
          \     /                             |
           \   /                              |
             v                                |
          No |                                |
             +--------------------------------+
             |
        +----+----+
        |  DONE   |
        +---------+

<< End of Ap_Do_Withholding program documentation >>

*/

BEGIN
  current_calling_sequence := 'AP_WITHHOLDING_PKG.AP_Do_Withholding';

  -- Execute the ExtENDed Withholding Calculation (IF active)
  IF (Ap_ExtENDed_Withholding_Pkg.Ap_ExtENDed_Withholding_Active) THEN
      Ap_ExtENDed_Withholding_Pkg.Ap_Do_ExtENDed_Withholding
                                 (P_Invoice_Id,
                                  P_Awt_Date,
                                  P_Calling_Module,
                                  P_Amount,
                                  P_Payment_Num,
                                  P_Checkrun_Name,
                                  P_Last_Updated_By,
                                  P_Last_Update_Login,
                                  P_Program_Application_Id,
                                  P_Program_Id,
                                  P_Request_Id,
                                  P_Awt_Success,
                                  P_Invoice_Payment_Id,
                                  P_Check_Id,
                                  p_checkrun_id);
      RETURN;
  END IF;

  -- Read the AWT flag for the current invoice (i.e. whether AWT
  -- calculation has already been performed by AUTOAPPROVAL on thIS
  -- invoice):

  -- Read setup information
  debug_info := 'Read Setup information';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  SELECT  create_awt_dists_type,
          create_awt_invoices_type,
          NVL(ai.awt_flag, 'N') awt_flag,
          ai.invoice_currency_code,
          ai.org_id --4742265
  INTO    l_create_dists,
          l_create_invoices,
          l_awt_flag,
          l_inv_curr_code,
          l_org_id --4742265
  FROM    ap_system_parameters_all asp,
          ap_invoices_all ai
  WHERE   ai.org_id = asp.org_id
    and   ai.invoice_id = p_invoice_id;

  --Bug6660355
  -- Starts Automatic Withholding Processing on the invoice
  IF (
      ( (l_create_dists   in ('APPROVAL', 'BOTH'))
       AND
       (P_Calling_Module = 'AUTOAPPROVAL')
       AND
       (l_awt_flag       <> 'Y'))
      OR
      ( (l_create_dists   in ( 'PAYMENT','BOTH'))
       AND
       (P_Calling_Module in ('AUTOSELECT', 'QUICKCHECK') ))
      OR
      ( P_Calling_Module in ('INVOICE ENTRY', 'INVOICE INQUIRY', 'AWT REPORT'))
     ) THEN

    savepoint BEFORE_TEMPORARY_CALCULATIONS;

	debug_info := 'AP_CALC_Withholding_PKG.AP_Calculate_AWT_Amounts';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    --  Create Temporary AWT distributions:
    AP_CALC_Withholding_PKG.AP_Calculate_AWT_Amounts
                         (P_Invoice_Id
                         ,P_Awt_Date
                         ,P_Calling_Module
                         ,l_create_dists
                         ,P_Amount
                         ,P_Payment_Num
                         ,P_Checkrun_Name
                         ,P_Last_Updated_By
                         ,P_Last_Update_Login
                         ,P_Program_Application_Id
                         ,P_Program_Id
                         ,P_Request_Id
                         ,l_AWT_success
                         ,current_calling_sequence
                         ,P_Invoice_Payment_Id
                         ,p_checkrun_id
                         ,l_org_id);  --4742265

    IF (l_AWT_success <> 'SUCCESS') THEN
      rollback to BEFORE_TEMPORARY_CALCULATIONS;
    END IF;
  END IF;
  --Bug6660355
 IF ( ( ( (l_create_dists   in ('APPROVAL','BOTH'))
        AND
        (P_Calling_Module = 'AUTOAPPROVAL')
        AND
        (l_awt_flag       <> 'Y'))
       OR
       ( (l_create_dists   in ('PAYMENT','BOTH'))
        AND
        (P_Calling_Module in ('CONFIRM', 'QUICKCHECK')))
       OR
       (P_Calling_Module = 'AWT REPORT'))
      AND
      (l_AWT_success = 'SUCCESS'))
     THEN

	debug_info := 'Create_AWT_Distributions';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    --  Create AWT distributions:
    Create_AWT_distributions
                         (P_Invoice_Id
                         ,P_Calling_Module
                         ,l_create_dists
                         ,P_Payment_Num
                         ,l_inv_curr_code
                         ,P_Last_Updated_By
                         ,P_Last_Update_Login
                         ,P_Program_Application_Id
                         ,P_Program_Id
                         ,P_Request_Id
                         ,current_calling_sequence
			 ,P_Check_Id);		--bug 8590059

  END IF;
  --Bug6660355
     IF ( ( ( (l_create_invoices in ('APPROVAL','BOTH'))
        AND
        (P_Calling_Module  = 'AUTOAPPROVAL')
        AND
        (l_awt_flag        <> 'Y'))
       OR
       ( (l_create_invoices in('PAYMENT','BOTH'))
        AND
        (P_Calling_Module in ('CONFIRM', 'QUICKCHECK'))
       ))
      AND
      (l_AWT_success = 'SUCCESS')) THEN
    --  Create AWT Invoices:

    IF  (P_Calling_Module NOT IN ('CONFIRM', 'QUICKCHECK')) THEN
       l_payment_date := NULL;
    END IF;

	 debug_info := 'Create_AWT_Invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    -- Bug 8254604 Modified method call to populate all the input parameters.
    Create_AWT_Invoices(
          P_Invoice_Id             => P_Invoice_Id,
          P_Payment_Date           => l_payment_date,
          P_Last_Updated_By        => P_Last_Updated_By,
          P_Last_Update_Login      => P_Last_Update_Login,
          P_Program_Application_Id => P_Program_Application_Id,
          P_Program_Id             => P_Program_Id,
          P_Request_Id             => P_Request_Id,
          P_Calling_Sequence       => current_calling_sequence,
          P_Calling_Module         => p_calling_module, --Bug6660355
          P_Inv_Line_No            => NULL,
          P_Dist_Line_No           => NULL,
          P_New_Invoice_Id         => NULL,
          P_create_dists           => l_create_dists);  --Bug7685907
  END IF;

  -- Set general response for thIS Ap_Do_Withholding execution:
  P_Awt_Success := l_AWT_success;

EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      '  Invoice Id  = '       || to_char(P_Invoice_Id) ||
                      ', AWT Date    = '       || to_char(P_Awt_Date) ||
                      ', Calling module  = '   || P_Calling_Module ||
                      ', Amount  = '           || to_char(P_Amount) ||
                      ', Payment Num = '       || to_char(P_Payment_Num) ||
                      ', Checkrun Name = '     || P_Checkrun_Name);

              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Ap_Do_Withholding;


PROCEDURE Ap_Withhold_AutoSelect (
          P_Checkrun_Name          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          p_checkrun_id            in     number)
IS
  DBG_Loc                     VARCHAR2(30) := 'Ap_Withhold_AutoSelect';
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
BEGIN
  current_calling_sequence := 'AP_WITHHOLDING_PKG.AP_Withhold_AutoSelect';

	debug_info := 'AP_WITHHOLDING_PKG.AP_Withhold_AutoSelect';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  -- Undo Withholding for all SELECTed invoices in thIS checkrun

  DECLARE
    CURSOR c_all_sel_invs (l_checkrun_name IN VARCHAR2, l_checkrun_id in number)
    IS
    SELECT invoice_id
    ,      vendor_id
    ,      payment_num
    FROM   ap_SELECTed_invoices_all ASI,
           ap_system_parameters_all asp
    WHERE  checkrun_name = l_checkrun_name
      AND  original_invoice_id IS NULL
      AND  asp.org_id = asi.org_id
      and  checkrun_id = l_checkrun_id
      --Bug6660355
       AND  decode(nvl(ASP.allow_awt_flag, 'N'), 'Y',
                  decode(ASP.create_awt_dists_type, 'PAYMENT',
                         'Y','BOTH','Y',decode(ASP.create_awt_invoices_type, 'PAYMENT',
                                     'Y','BOTH','Y','N'),
                         'N'),
                  'N') = 'Y';


    rec_all_sel_invs c_all_sel_invs%ROWTYPE;

  BEGIN
    debug_info := 'OPEN CURSOR for all SELECTed invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    OPEN c_all_sel_invs (P_Checkrun_Name, p_checkrun_id);

    LOOP
      debug_info := 'Fetch CURSOR for all SELECTed invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

      FETCH c_all_sel_invs INTO rec_all_sel_invs;
      EXIT WHEN c_all_sel_invs%NOTFOUND;

      DECLARE
        undo_output VARCHAR2(2000);
      BEGIN
        Ap_Undo_Temp_Withholding
                     (P_Invoice_Id             => rec_all_sel_invs.invoice_id
                     ,P_VENDor_Id              => rec_all_sel_invs.vendor_id
                     ,P_Payment_Num            => rec_all_sel_invs.payment_num
                     ,P_Checkrun_Name          => P_Checkrun_Name
                     ,P_Undo_Awt_Date          => SYSDATE
                     ,P_Calling_Module         => 'AUTOSELECT'
                     ,P_Last_Updated_By        => P_Last_Updated_By
                     ,P_Last_Update_Login      => P_Last_Update_Login
                     ,P_Program_Application_Id => P_Program_Application_Id
                     ,P_Program_Id             => P_Program_Id
                     ,P_Request_Id             => P_Request_Id
                     ,P_Awt_Success            => undo_output
                     ,P_checkrun_id            => p_checkrun_id );
      END;
    END LOOP;

    debug_info := 'CLOSE CURSOR for all SELECTed invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    CLOSE c_all_sel_invs;

  END;

  -- DO Withholding for all OK to pay SELECTed invoices in thIS checkrun
  -- that have No Manual AWT dists

  UPDATE ap_SELECTed_invoices_all
     SET ok_to_pay_flag = 'Y',
         proposed_payment_amount = invoice_amount * payment_cross_rate,
         -- We cannot round the proposed_payment_amount here since we don't
         -- have payment_currency_code. We will round it later.
         dont_pay_reason_code = NULL,
         dont_pay_description = NULL
  WHERE  checkrun_name = P_Checkrun_Name AND
         ok_to_pay_flag = 'N'            AND
         checkrun_id = p_checkrun_id     and
         dont_pay_reason_code = 'AWT ERROR';

  -- Execute Core Withholding Calculation Routine

  IF (NOT Ap_ExtENDed_Withholding_Pkg.Ap_ExtENDed_Withholding_Active) THEN
     DECLARE
       CURSOR c_ok_sel_invs (l_checkrun_name IN VARCHAR2, l_checkrun_id in number)
       IS
       SELECT ASI.invoice_id
       ,      ASI.payment_num
       ,      ASI.payment_amount
       ,      ASI.discount_amount
       ,      NVL(ASI.invoice_exchange_rate, 1) invoice_exchange_rate
       ,      NVL(ASI.payment_cross_rate,1) payment_cross_rate
       ,      AI.payment_currency_code
       ,      NVL(asp.awt_include_discount_amt, 'N') include_discount_amt
       ,      asp.base_currency_code
       ,      NVL(ASI.payment_exchange_rate,1) payment_exchange_rate		--bug 8590059
       FROM   ap_SELECTed_invoices_all ASI,
              ap_invoices_all AI,
              ap_system_parameters_all asp
       WHERE  ASI.checkrun_name = l_checkrun_name
         AND  asi.checkrun_id = l_checkrun_id
         AND  AI.invoice_id = ASI.invoice_id
         AND  AI.org_id = asp.org_id
         AND  NVL(ASI.ok_to_pay_flag,'Y') IN ( 'Y','F')
         AND  NOT EXISTS (SELECT 'Manual AWT dists exist'
                            FROM   ap_invoice_distributions AID
                            WHERE  AID.invoice_id            = ASI.invoice_id
                            AND    AID.line_type_lookup_code = 'AWT'
                            AND    AID.awt_flag              = 'M')
        AND ((ASP.create_awt_dists_type ='PAYMENT' --Bug6660355
             AND  NOT EXISTS (SELECT 'Invoice already withheld by AutoApproval'
                        FROM   ap_invoices AI
                           WHERE  AI.invoice_id         = ASI.invoice_id
                               AND    NVL(AI.awt_flag, 'N') = 'Y'))
             OR
             ASP.create_awt_dists_type ='BOTH')

         AND EXISTS (SELECT 'At least one dist exists with AWT_GROUP_ID'
                       FROM  ap_invoice_distributions AID
                      WHERE  AID.invoice_id         = ASI.invoice_id
                        AND  AID.pay_awt_group_id       IS NOT NULL) --Bug8631142
       AND ASI.original_invoice_id IS NULL        --Bug6660355
       AND  decode(nvl(ASP.allow_awt_flag, 'N'), 'Y',
                   decode(ASP.create_awt_dists_type, 'PAYMENT',
                          'Y','BOTH','Y', decode(ASP.create_awt_invoices_type, 'PAYMENT',
                                      'Y','BOTH','Y','N'),
                          'N'),
                  'N') = 'Y'
       FOR UPDATE OF
              ASI.proposed_payment_amount
       ,      ASI.payment_amount
       ,      ASI.withholding_amount
       ,      ASI.ok_to_pay_flag
       ,      ASI.dont_pay_reason_code
       ,      ASI.dont_pay_description;

       rec_ok_sel_invs c_ok_sel_invs%ROWTYPE;

       l_awt_date             DATE;
       l_withholding_amount   NUMBER;
       l_subject_amount       NUMBER;
       l_awt_success          VARCHAR2(2000);
       l_invoice_amount       NUMBER;
       l_amount_remaining     NUMBER;
       l_total_amount         NUMBER;
       l_count                NUMBER;
       l_amountapplied        NUMBER;
       l_update_indicator     number:=0;
       l_total_awt_amount     NUMBER;--6660355
       l_amount_payable       NUMBER;

     BEGIN

       debug_info := 'Select check_date for thIS checkrun';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

       SELECT  AISC.check_date
         INTO  l_awt_date
         FROM  ap_inv_SELECTion_criteria_all AISC
        WHERE  AISC.checkrun_name = P_Checkrun_Name
          and  aisc.checkrun_id = p_checkrun_id;


       debug_info := 'OPEN CURSOR for all ok to pay invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

       OPEN c_ok_sel_invs (P_Checkrun_Name, p_checkrun_id);

       LOOP
         debug_info := 'Fetch CURSOR for all ok to pay invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

         FETCH c_ok_sel_invs INTO rec_ok_sel_invs;
         EXIT WHEN c_ok_sel_invs%NOTFOUND;

         if l_update_indicator = 0 then
           --if we are here the cursor got data, so we need to set the
           --batches rejection levels to request

           -- Bug 7492768 We need to set the inv_awt_exists_flag which indicates if the
           -- check run contains invoice that has awt. If the flag is set we would
           -- pass the rejection_level_code as 'REQUEST' to IBY.
           -- We will not update the rejection levels directly so that we can retrieve
           -- the initial values for these if the user removes awt invoices during
           -- the review stage from the selected invoices.
           update ap_inv_selection_criteria_all
           set /*document_rejection_level_code = 'REQUEST',
               payment_rejection_level_code = 'REQUEST'*/
               inv_awt_exists_flag = 'Y'
           where checkrun_id = p_checkrun_id;

           l_update_indicator := 1;
         end if;


         IF (rec_ok_sel_invs.include_discount_amt = 'Y') THEN
           l_subject_amount := rec_ok_sel_invs.payment_amount +
                              rec_ok_sel_invs.discount_amount;
         ELSE
           l_subject_amount := rec_ok_sel_invs.payment_amount;
         END IF;

         SELECT invoice_amount, amount_remaining
           INTO  l_invoice_amount, l_amount_remaining
           FROM  ap_selected_invoices_all
          WHERE  invoice_id    = rec_ok_sel_invs.invoice_id
            AND  checkrun_name = p_checkrun_name
            and  checkrun_id = p_checkrun_id
            AND  payment_num   = rec_ok_sel_invs.payment_num;
          --Bug6660355
          SELECT  sum(nvl(aid.base_amount,aid.amount))
          INTO   l_total_awt_amount
          FROM   ap_invoice_distributions aid,ap_invoices ai
          WHERE  aid.invoice_id = ai.invoice_id
          AND    aid.invoice_id =rec_ok_sel_invs.invoice_id
          AND    aid.line_type_lookup_code in ('AWT')
          AND    aid.awt_origin_group_id = ai.awt_group_id;
           --Get the total amount of the invoices SELECTed in the batch.

         --Get the total amount of the invoices SELECTed in the batch.

         SELECT SUM(NVL(payment_amount,0)) +
                SUM((-1) * NVL(withholding_amount,0))
           INTO  l_total_amount
           FROM  ap_SELECTed_invoices_all
          WHERE  checkrun_name = p_checkrun_name
            and  checkrun_id = p_checkrun_id
            AND  NVL(ok_to_pay_flag,'Y') in ( 'Y','F');

         --Get the count of credit AND debit memos in the batch.
         Select COUNT(*)
         INTO   l_count
         FROM   ap_selected_invoices_all
         WHERE  checkrun_name = p_checkrun_name
         and    checkrun_id = p_checkrun_id
         AND    NVL(ok_to_pay_flag,'Y') IN ( 'Y','F')
         AND    invoice_amount < 0;

         -- The following statements should be executed only for credit memos with
         -- amount remaining equals to payment amount AND total amount <> 0. Because IF
         -- total amount IS zero, withholding tax should be calculated for whole invoice
         -- amount. If amount remaining IS not equal to payment amount, withholding tax
         -- should be calculated for payment amount AND need not to go inside thIS LOOP.

         IF l_invoice_amount < 0 AND l_amount_remaining = rec_ok_sel_invs.payment_amount
            AND l_total_amount <> 0 THEN

            SELECT  (-1) * (SUM(NVL(payment_amount,0) +
                    NVL(ABS(withholding_amount),0)))
              INTO  l_subject_amount
              FROM  ap_selected_invoices_all
             WHERE  payment_amount > 0
               AND  NVL(ok_to_pay_flag,'Y') in ( 'Y','F')
               AND  checkrun_name = p_checkrun_name
               and  checkrun_id = p_checkrun_id;

            -- If the batch contains more than one credit memo, get the applied amount AND
            -- subtract it FROM subject amount.

            IF l_count > 1 THEN
               SELECT (-1) * (SUM(NVL(ABS(payment_amount),0) +
                      NVL(withholding_amount,0)))
                 INTO  l_amountapplied
                 FROM  ap_selected_invoices_all
                WHERE  NVL(withholding_amount,0) > 0
                  AND  NVL(ok_to_pay_flag,'Y') in ( 'Y','F')
                  AND  checkrun_name = p_checkrun_name
                  and  checkrun_id = p_checkrun_id;

               IF ABS(l_amountapplied) > 0 THEN
                  l_subject_amount := l_subject_amount - l_amountapplied;
               END IF;
            END IF;

            -- If the subject amount IS greater than amount remaining, subject amount
            -- should be replaced with amount remaining.

            IF ABS(l_subject_amount) > Abs(l_amount_remaining) THEN
               l_subject_amount := l_amount_remaining;
            END IF;

         END IF;
        /* Bug 4990575 removed the round currency function from  below statement */
        /* l_subject_amount := ap_utilities_pkg.ap_round_currency(
                               l_subject_amount /
                               rec_ok_sel_invs.payment_cross_rate *
                               rec_ok_sel_invs.invoice_exchange_rate,
                               rec_ok_sel_invs.base_currency_code);*/
         l_subject_amount := l_subject_amount * rec_ok_sel_invs.payment_exchange_rate;  -- bug 8590059
         l_amount_payable :=l_invoice_amount + nvl(l_total_awt_amount,0); --Bug8631142
         l_subject_amount := ap_utilities_pkg.ap_round_currency((l_subject_amount * l_invoice_amount/l_amount_payable)
                                                                 ,rec_ok_sel_invs.payment_currency_code); --6660355

 	debug_info := 'AP_DO_WITHHOLDING';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

         Ap_Do_Withholding
                   (P_Invoice_Id             => rec_ok_sel_invs.invoice_id
                   ,P_Awt_Date               => l_awt_date
                   ,P_Calling_Module         => 'AUTOSELECT'
                   ,P_Amount                 => l_subject_amount
                   ,P_Payment_Num            => rec_ok_sel_invs.payment_num
                   ,P_Checkrun_Name          => P_Checkrun_Name
                   ,P_Last_Updated_By        => P_Last_Updated_By
                   ,P_Last_Update_Login      => P_Last_Update_Login
                   ,P_Program_Application_Id => P_Program_Application_Id
                   ,P_Program_Id             => P_Program_Id
                   ,P_Request_Id             => P_Request_Id
                   ,P_Awt_Success            => l_awt_success
                   ,P_checkrun_id            => p_checkrun_id
                   );

         IF (l_awt_success = 'SUCCESS') THEN

           debug_info := 'Select sum of withholding amount for thIS invoice';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

           SELECT   NVL(SUM(AATD.withholding_amount), 0)
             INTO   l_withholding_amount
             FROM   ap_awt_temp_distributions_all AATD
            WHERE   AATD.checkrun_name = P_Checkrun_Name
              AND   AATD.invoice_id    = rec_ok_sel_invs.invoice_id
              AND   AATD.payment_num   = rec_ok_sel_invs.payment_num
              and   aatd.checkrun_id   = p_checkrun_id;

           l_withholding_amount := ap_utilities_pkg.ap_round_currency(
                                   l_withholding_amount /
                                   rec_ok_sel_invs.payment_exchange_rate,
                               --  *  rec_ok_sel_invs.payment_cross_rate,   -- bug 8590059
                                   rec_ok_sel_invs.payment_currency_code);

           debug_info := 'Update proposed payment in ap_selected_invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

           UPDATE ap_selected_invoices_all ASI
              SET /*ASI.proposed_payment_amount =
                      ap_utilities_pkg.ap_round_currency(
                         ASI.proposed_payment_amount,rec_ok_sel_invs.payment_currency_code) -
                      l_withholding_amount
                  -- We round proposed_payment_amount here because we couldn't round it earlier.
                 ,ASI.payment_amount =
                      ASI.payment_amount          - l_withholding_amount
                 ,ASI.amount_remaining =
                      ASI.amount_remaining        - l_withholding_amount
                 ,ASI.withholding_amount          = l_withholding_amount */
                 --Bug#8281225 Wrong Amount Remaining in Case of Inv Payment Through PPR
                 ASI.proposed_payment_amount = ap_utilities_pkg.ap_round_currency(ASI.proposed_payment_amount,rec_ok_sel_invs.payment_currency_code)
                                               - nvl(l_withholding_amount, 0)
                ,ASI.payment_amount = ap_utilities_pkg.ap_round_currency(ASI.proposed_payment_amount,rec_ok_sel_invs.payment_currency_code)
                                               - nvl(l_withholding_amount, 0)
                ,ASI.withholding_amount = l_withholding_amount
           WHERE  current of c_ok_sel_invs;
         ELSE
           debug_info := 'Update AWT error in ap_selected_invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

           UPDATE ap_SELECTed_invoices_all ASI
              SET ASI.ok_to_pay_flag       = 'N',
                  ASI.dont_pay_reason_code = 'AWT ERROR',
                  ASI.dont_pay_description = substr(l_awt_success, 1, 255)
           WHERE  current of c_ok_sel_invs;
         END IF;
       END LOOP;

       debug_info := 'CLOSE CURSOR for all ok to pay invoices';
 	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

       CLOSE c_ok_sel_invs;
     END;

  ELSE --extended awt is used, set the rejection levels for the batch

    -- Bug 7492768 We need to set the inv_awt_exists_flag which indicates if the
    -- check run contains invoice that has awt. If the flag is set we would
    -- pass the rejection_level_code as 'REQUEST' to IBY.
    -- We will not update the rejection levels directly so that we can retrieve
    -- the initial values for these if the user removes awt invoices during
    -- the review stage from the selected invoices.
    update ap_inv_selection_criteria_all
    set /*document_rejection_level_code = 'REQUEST',
        payment_rejection_level_code = 'REQUEST'*/
		inv_awt_exists_flag = 'Y'
    where checkrun_id = p_checkrun_id;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      '  Checkrun Name  = '  || P_Checkrun_Name ||
                      ', Program_Id = '      || to_char(P_Program_Id) ||
                      ', Request_Id = '      || to_char(P_Request_Id));

              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Ap_Withhold_AutoSelect;

PROCEDURE Ap_Withhold_Confirm (
         P_Checkrun_Name          IN     VARCHAR2,
         P_Last_Updated_By        IN     NUMBER,
         P_Last_Update_Login      IN     NUMBER,
         P_Program_Application_Id IN     NUMBER,
         P_Program_Id             IN     NUMBER,
         P_Request_Id             IN     NUMBER,
         p_checkrun_id            in     number,
         p_completed_pmts_group_id in    number,
         p_org_id                  in    number,
         p_check_date              in    date
         )
IS
  -- DO Withholding for all OK to pay selected invoices in this checkrun
  CURSOR c_ok_sel_invs  IS
  SELECT ASI.invoice_id,
         ASI.payment_num,
         p_check_date payment_date
  FROM   ap_selected_invoices_all ASI,
         iby_fd_docs_payable_v ibydocs
  WHERE  ASI.checkrun_name  = p_checkrun_name
  AND    ASI.original_invoice_id IS NULL
  and    asi.checkrun_id = p_checkrun_id
  and    ibydocs.calling_app_doc_unique_ref1 = to_char(asi.checkrun_id) /* Added to_char for bug#8462020 */
  AND    ibydocs.calling_app_doc_unique_ref2 = to_char(asi.invoice_id) /* Added to_char for bug#8462020 */
  AND    ibydocs.calling_app_doc_unique_ref3 = to_char(asi.payment_num) /* Added to_char for bug#8462020 */
  and    ibydocs.completed_pmts_group_id = p_completed_pmts_group_id
  and    ibydocs.org_id = p_org_id
  and    ibydocs.calling_app_id = 200; /* Added calling_app_id condition for bug#8462020 */


  rec_ok_sel_invs             c_ok_sel_invs%ROWTYPE;
  l_awt_success               VARCHAR2(2000);
  DBG_Loc                     VARCHAR2(30) := 'Ap_Withhold_Confirm';
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
BEGIN
  current_calling_sequence := 'AP_WITHHOLDING_PKG.AP_Withhold_Confirm';

  -- Execute Core Withholding Routine for each invoice within
  -- the payment batch

  IF (NOT Ap_ExtENDed_Withholding_Pkg.Ap_ExtENDed_Withholding_Active) THEN

     debug_info := 'OPEN CURSOR for all OK to pay invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

     OPEN c_ok_sel_invs ;

     LOOP
       debug_info := 'Fetch CURSOR for all OK to pay invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

       FETCH c_ok_sel_invs INTO rec_ok_sel_invs;
       EXIT WHEN c_ok_sel_invs%NOTFOUND;
       Ap_Do_Withholding
                   (P_Invoice_Id             => rec_ok_sel_invs.invoice_id
                   ,P_Awt_Date               => rec_ok_sel_invs.payment_date
                   ,P_Calling_Module         => 'CONFIRM'
                   ,P_Amount                 => NULL
                   ,P_Payment_Num            => rec_ok_sel_invs.payment_num
                   ,P_Checkrun_Name          => P_Checkrun_Name
                   ,P_Last_Updated_By        => P_Last_Updated_By
                   ,P_Last_Update_Login      => P_Last_Update_Login
                   ,P_Program_Application_Id => P_Program_Application_Id
                   ,P_Program_Id             => P_Program_Id
                   ,P_Request_Id             => P_Request_Id
                   ,P_Awt_Success            => l_awt_success
                   ,p_checkrun_id            => p_checkrun_id
                   );
     END LOOP;

     debug_info := 'CLOSE CURSOR for all OK to pay invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

     CLOSE c_ok_sel_invs;

  -- Execute ExtENDed Withholding Routine for the entire payment)
  --
  ELSE
      Ap_Do_Withholding
                (P_Invoice_Id             => NULL
                ,P_Awt_Date               => NULL
                ,P_Calling_Module         => 'CONFIRM'
                ,P_Amount                 => NULL
                ,P_Payment_Num            => NULL
                ,P_Checkrun_Name          => P_Checkrun_Name
                ,P_Last_Updated_By        => P_Last_Updated_By
                ,P_Last_Update_Login      => P_Last_Update_Login
                ,P_Program_Application_Id => P_Program_Application_Id
                ,P_Program_Id             => P_Program_Id
                ,P_Request_Id             => P_Request_Id
                ,P_Awt_Success            => l_awt_success
                ,p_checkrun_id            => p_checkrun_id
                );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      '  Checkrun Name  = '  || P_Checkrun_Name ||
                      ', Program_Id = '      || to_char(P_Program_Id) ||
                      ', Request_Id = '      || to_char(P_Request_Id));
              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Ap_Withhold_Confirm;


PROCEDURE Ap_Withhold_Cancel (
          P_Checkrun_Name          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          p_checkrun_id            in     number,
          p_completed_pmts_group_id in    number default null,
          p_org_id                  in    number default null)
IS
  -- UNDO Withholding for all selected invoices in thIS checkrun
  CURSOR c_all_sel_invs (l_checkrun_name IN VARCHAR2, l_checkrun_id in number)
  IS
  SELECT ASI.invoice_id
  ,      ASI.payment_num
  ,      AI.vendor_id
  FROM   ap_SELECTed_invoices_all ASI
  ,      ap_invoices_all AI
  WHERE  ASI.checkrun_name  = l_checkrun_name
  AND    AI.invoice_id      = ASI.invoice_id
  and    asi.checkrun_id    = l_checkrun_id;

  rec_all_sel_invs c_all_sel_invs%ROWTYPE;

  CURSOR C_sel_invs is
  SELECT ASI.invoice_id
  ,      ASI.payment_num
  ,      AI.vendor_id
  FROM   ap_SELECTed_invoices_all ASI
  ,      ap_invoices_all AI
  ,      iby_fd_docs_payable_v ibydocs
  WHERE  ASI.checkrun_name  = p_checkrun_name
  AND    AI.invoice_id      = ASI.invoice_id
  and    asi.checkrun_id    = p_checkrun_id
  and    ibydocs.completed_pmts_group_id = p_completed_pmts_group_id
  and    ibydocs.org_id = p_org_id
  and    ibydocs.calling_app_doc_unique_ref1 = asi.checkrun_id
  AND    ibydocs.calling_app_doc_unique_ref2 = asi.invoice_id
  AND    ibydocs.calling_app_doc_unique_ref3 = asi.payment_num;



  l_awt_success               VARCHAR2(2000);
  DBG_Loc                     VARCHAR2(30) := 'Ap_Withhold_Cancel';
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(1000);
BEGIN
  current_calling_sequence := 'AP_WITHHOLDING_PKG.AP_Withhold_Cancel';
  debug_info := 'Open Cursor for all selected invoices';
 	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  if p_completed_pmts_group_id is null then
    OPEN c_all_sel_invs (P_Checkrun_Name, p_checkrun_id);
  else
    OPEN C_SEL_INVS;
  end if;


  LOOP
    debug_info := 'Fetch CURSOR for all SELECTed invoices -- invoice_id = '||to_char(rec_all_sel_invs.invoice_id);
 	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;


    if p_completed_pmts_group_id is null then
      FETCH c_all_sel_invs INTO rec_all_sel_invs;
      EXIT WHEN c_all_sel_invs%NOTFOUND;
    else
      fetch c_sel_invs into rec_all_sel_invs;
      exit when c_sel_invs%notfound;
    end if;


    Ap_Undo_Temp_Withholding
                     (P_Invoice_Id             => rec_all_sel_invs.invoice_id
                     ,P_VENDor_Id              => rec_all_sel_invs.vendor_id
                     ,P_Payment_Num            => rec_all_sel_invs.payment_num
                     ,P_Checkrun_Name          => P_Checkrun_Name
                     ,P_Undo_Awt_Date          => SYSDATE
                     ,P_Calling_Module         => 'CANCEL'
                     ,P_Last_Updated_By        => P_Last_Updated_By
                     ,P_Last_Update_Login      => P_Last_Update_Login
                     ,P_Program_Application_Id => P_Program_Application_Id
                     ,P_Program_Id             => P_Program_Id
                     ,P_Request_Id             => P_Request_Id
                     ,P_Awt_Success            => l_awt_success
                     ,P_checkrun_id            => p_checkrun_id);
  END LOOP;

  debug_info := 'CLOSE CURSOR for all SELECTed invoices';
  	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  if p_completed_pmts_group_id is null then
    CLOSE c_all_sel_invs;
  else
    CLOSE c_sel_invs;
  end if;


EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      '  Checkrun Name  = '  || P_Checkrun_Name ||
                      ', Program_Id = '      || to_char(P_Program_Id) ||
                      ', Request_Id = '      || to_char(P_Request_Id));
              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Ap_Withhold_Cancel;


PROCEDURE Ap_Undo_Temp_Withholding (
          P_Invoice_Id             IN     NUMBER,
          P_Vendor_Id              IN     NUMBER DEFAULT NULL,
          P_Payment_Num            IN     NUMBER,
          P_Checkrun_Name          IN     VARCHAR2,
          P_Undo_Awt_Date          IN     DATE,
          P_Calling_Module         IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER DEFAULT NULL,
          P_Program_Id             IN     NUMBER DEFAULT NULL,
          P_Request_Id             IN     NUMBER DEFAULT NULL,
          P_Awt_Success            OUT NOCOPY    VARCHAR2,
          P_checkrun_id            in     number default null)
IS
  DBG_Loc                     VARCHAR2(30)  := 'Ap_Undo_Temp_Withholding';
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  l_withholding_amount        NUMBER;
  l_proposed_payment_amount   NUMBER; --Added for Bug#8281225

BEGIN
  current_calling_sequence := 'AP_WITHHOLDING_PKG.AP_Undo_Temp_Withholding';

  P_AWT_Success := 'SUCCESS';

  IF (P_Calling_Module in ('AUTOSELECT', 'CANCEL', 'PROJECTED')) THEN
    <<Undo_During_AutoSELECT>>
    DECLARE
      CURSOR c_temp (InvId IN NUMBER
                    ,PaymNum IN NUMBER
                    ,CheckrunName in VARCHAR2
                    ,Calling_Module in VARCHAR2
                    ,checkrun_id in number) IS
      SELECT AATD.invoice_id
      ,      AATD.payment_num
      ,      AATD.group_id
      ,      AATD.tax_name
      ,      AATD.tax_code_combination_id
      ,      AATD.gross_amount
      ,      AATD.withholding_amount
      ,      AATD.base_withholding_amount
      ,      AATD.accounting_date
      ,      AATD.period_name
      ,      AATD.checkrun_name
      ,      AATD.tax_rate_id
      ,      TC.tax_id tax_code_id
      ,      aatd.checkrun_id
      FROM   ap_awt_temp_distributions_all AATD,
             ap_invoices_all AI,
             ap_tax_codes_all TC
      WHERE  AATD.invoice_id              = InvId
        AND  AATD.invoice_id              = AI.invoice_id
        AND  TC.name(+)                   = AATD.tax_name
        AND  TC.tax_type = 'AWT'                               -- BUG 3665866
        AND  NVL(TC.enabled_flag,'Y')     = 'Y'
        AND  NVL(AI.invoice_date,SYSDATE) BETWEEN
               NVL(TC.start_date,  NVL(AI.invoice_date,SYSDATE)) AND
               NVL(TC.inactive_date,  NVL(AI.invoice_date,SYSDATE))
        AND  (((AATD.checkrun_name         = NVL(CheckrunName, AATD.checkrun_name))
                AND    (AATD.payment_num   = NVL(PaymNum, AATD.payment_num))
                and    (aatd.checkrun_id   = nvl(checkrun_id, aatd.checkrun_id)))
                OR
               (AATD.checkrun_name         IS NULL
                AND AATD.payment_num       IS NULL
                and aatd.checkrun_id       is null
                AND calling_module         = 'PROJECTED'))
	AND  TC.org_id = AI.org_id              -- Bug 8772252
      FOR UPDATE;
      rec_temp c_temp%ROWTYPE;

      FUNCTION Period_Limit_ExISt_For_Tax (
                 TaxId IN NUMBER,
                 P_Calling_Sequence in VARCHAR2)
      RETURN BOOLEAN
      IS
        ret BOOLEAN;

        CURSOR  c_get_limit IS
        SELECT  'Limit ExISts'
          FROM  ap_tax_codes_all
         WHERE  tax_id = TaxId
           AND  awt_period_type IS not NULL;

        dummy                       CHAR(12);
        current_calling_sequence    VARCHAR2(2000);
        debug_info                  VARCHAR2(100);
      BEGIN
        current_calling_sequence := 'AP_WITHHOLDING_PKG.Period_Limit_ExISt_For_Tax<-' ||
                              P_Calling_Sequence;
        debug_info := 'OPEN CURSOR c_get_limit';
 	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        OPEN  c_get_limit;

        debug_info := 'Fetch CURSOR c_get_limit';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        FETCH c_get_limit INTO dummy;

        ret        := c_get_limit%FOUND;
        debug_info := 'CLOSE CURSOR c_get_limit';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        CLOSE c_get_limit;

        RETURN(ret);
      EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                                    'Tax Code Id = ' || TaxId);

              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

      END Period_Limit_ExISt_For_Tax;

    BEGIN
      debug_info := 'OPEN CURSOR for AWT temp distributions';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

      OPEN  c_temp (P_Invoice_Id, P_Payment_Num, P_Checkrun_Name, P_Calling_Module, p_checkrun_id);
      <<For_Each_Temporary_dist>>
      LOOP
        -- Read one temporary distribution line:
        debug_info := 'Fetch CURSOR for AWT temp distributions';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        FETCH c_temp INTO rec_temp;
        EXIT WHEN c_temp%NOTFOUND;

        -- Decrease corresponding bucket unless called FROM PROJECTED:
        -- (PROJECTED doesn't affect buckets)

        IF (P_Calling_Module in ('AUTOSELECT', 'CANCEL') AND
            Period_Limit_ExISt_For_Tax(rec_temp.tax_code_id
                                      ,current_calling_sequence)) THEN
          DECLARE
            CURSOR c_get_awt_period IS
            SELECT p.period_name
              FROM   ap_other_periods  P,
                     ap_tax_codes_all      C
            WHERE  (rec_temp.accounting_date BETWEEN
                    p.start_date AND p.end_date)
              AND   p.period_type = c.awt_period_type
              AND   c.name        = rec_temp.tax_name
              AND   p.module      = 'AWT';

            awt_period ap_other_periods.period_name%TYPE;
          BEGIN
            debug_info := 'OPEN CURSOR c_get_awt_period';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            OPEN  c_get_awt_period;

            debug_info := 'Fetch CURSOR c_get_awt_period';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            FETCH c_get_awt_period INTO awt_period;

            debug_info := 'CLOSE CURSOR c_get_awt_period';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            CLOSE c_get_awt_period;

            debug_info := 'Update ap_awt_buckets';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            UPDATE ap_awt_buckets_all
               SET gross_amount_to_date    = gross_amount_to_date -
                                             NVL(rec_temp.gross_amount,0)
            ,      withheld_amount_to_date = withheld_amount_to_date -
                                             NVL(rec_temp.withholding_amount,0)
            ,      last_UPDATE_date        = SYSDATE
            ,      last_UPDATEd_by         = P_Last_Updated_By
            ,      last_UPDATE_login       = P_Last_Update_Login
            ,      program_UPDATE_date     = SYSDATE
            ,      program_application_id  = P_Program_Application_Id
            ,      program_id              = P_Program_Id
            ,      request_id              = P_Request_Id
            WHERE  period_name             = awt_period
              AND  tax_name                = rec_temp.tax_name
              AND  vendor_id               = P_vendor_Id;
          END;
        END IF;

        -- Update ap_selected_invoices IF P_Calling_Modules
        -- is AUTOSELECT

        IF (P_Calling_Module = 'AUTOSELECT') THEN
            DECLARE

            CURSOR c_curr_code (l_checkrun_name IN VARCHAR2,
                      l_invoice_id    IN NUMBER,
                      l_payment_num   IN NUMBER,
                      l_checkrun_id   in number) IS
            SELECT ASI.payment_currency_code,
                   ASI.invoice_exchange_rate,
                   ASI.payment_cross_rate,
   		   ASI.payment_exchange_rate   -- bug 8590059
            FROM   ap_SELECTed_invoices_all ASI
            WHERE  ASI.checkrun_name        = l_checkrun_name
              AND  ASI.invoice_id            = l_invoice_id
              AND  ASI.payment_num           = l_payment_num
              and  asi.checkrun_id           = l_checkrun_id;

            curr_code c_curr_code%ROWTYPE;
         BEGIN

            debug_info := 'OPEN CURSOR c_curr_code';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            OPEN  c_curr_code (rec_temp.checkrun_name,
                               rec_temp.invoice_id,
                               rec_temp.payment_num,
                               rec_temp.checkrun_id);

            debug_info := 'Fetch CURSOR c_curr_code';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            FETCH c_curr_code INTO curr_code;

            debug_info := 'CLOSE CURSOR c_curr_code';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            CLOSE c_curr_code;

	-- Added NVL condition to curr_code.payment_exchange_rate for bug 8772252
            l_withholding_amount := ap_utilities_pkg.ap_round_currency(
                                    (rec_temp.withholding_amount
				    / nvl(curr_code.payment_exchange_rate,1)), -- bug 8590059
                                   -- * curr_code.payment_cross_rate,    -- bug 8590059
                                     curr_code.payment_currency_code);
          END ;
          --Added for Bug#8281225 PPR is calculating wrong PPR amount.
          BEGIN
             SELECT proposed_payment_amount
             INTO   l_proposed_payment_amount
             FROM   ap_selected_invoices_all
             WHERE  checkrun_name = rec_temp.checkrun_name
             AND    invoice_id    = rec_temp.invoice_id
             AND    payment_num   = rec_temp.payment_num
             and    checkrun_id   = rec_temp.checkrun_id;
          EXCEPTION
             WHEN OTHERS THEN
                IF (SQLCODE <> -20001) THEN
                   FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
                   FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
                   FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
                   FND_MESSAGE.set_TOKEN('PARAMETERS',
                       'Checkrun Id = ' || to_char(rec_temp.checkrun_id) ||
                       'Proposed Payment Amount = '||
                        to_char(l_proposed_payment_amount));
                   FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
                END IF;
                APP_EXCEPTION.RAISE_EXCEPTION;
          END;
          debug_info := 'Update ap SELECTed invoices';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          UPDATE ap_SELECTed_invoices_all
             SET /*payment_amount          = payment_amount +
                                           NVL(l_withholding_amount,0),
                 proposed_payment_amount = proposed_payment_amount +
                                           NVL(l_withholding_amount,0),
                 amount_remaining        = amount_remaining +
                                           NVL(l_withholding_amount,0),
                 withholding_amount      = 0 */
                 --Bug#8281225 Wrong Amount Remaining in Case of Inv Payment Through PPR
                 proposed_payment_amount = l_proposed_payment_amount + NVL(l_withholding_amount,0)
                ,payment_amount          = l_proposed_payment_amount + NVL(l_withholding_amount,0)
                ,withholding_amount      = 0
           WHERE checkrun_name = rec_temp.checkrun_name
             AND invoice_id    = rec_temp.invoice_id
             AND payment_num   = rec_temp.payment_num
             and checkrun_id   = rec_temp.checkrun_id;

        END IF;
          -- Drop that temporary line:
          debug_info := 'Delete the AWT temp distribution';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          DELETE ap_awt_temp_distributions_all
           WHERE  invoice_id  = rec_temp.invoice_id
             AND  group_id    = rec_temp.group_id
             AND  tax_name    = rec_temp.tax_name
             AND  (   (    (checkrun_name = NVL(rec_temp.checkrun_name, checkrun_name))
                       AND (payment_num   = NVL(rec_temp.payment_num, payment_num))
                       and (checkrun_id   = nvl(rec_temp.checkrun_id,checkrun_id)))
                      OR
                       (    checkrun_name    IS NULL
                        and checkrun_id      is null
                        AND payment_num      IS NULL
                        AND P_calling_module = 'PROJECTED'));
      END LOOP For_Each_Temporary_dist;

      debug_info := 'CLOSE CURSOR c_temp';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

      CLOSE c_temp;
    END Undo_During_AutoSELECT;
  END IF;

  -- Execute the ExtENDed Withholding Reversion (IF active)
  --
  IF (Ap_ExtENDed_Withholding_Pkg.Ap_ExtENDed_Withholding_Active) THEN
      Ap_ExtENDed_Withholding_Pkg.Ap_Undo_Temp_Ext_Withholding
                                 (P_Invoice_Id,
                                  P_VENDor_Id,
                                  P_Payment_Num,
                                  P_Checkrun_Name,
                                  P_Undo_Awt_Date,
                                  P_Calling_Module,
                                  P_Last_Updated_By,
                                  P_Last_Update_Login,
                                  P_Program_Application_Id,
                                  P_Program_Id,
                                  P_Request_Id,
                                  P_Awt_Success,
                                  p_checkrun_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DECLARE
      error_text VARCHAR2(512) := substr(sqlerrm, 1, 512);
    BEGIN
     P_Awt_Success := error_text;
     IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      ', Invoice_Id = '        || to_char(P_Invoice_Id) ||
                      ', VENDor_Id = '         || to_char(P_VENDor_Id) ||
                      ', Payment_Num = '       || to_char(P_Payment_Num) ||
                      ', Checkrun_Name = '     || P_Checkrun_Name ||
                      '  Undo_Awt_Date  = '    || to_char(P_Undo_Awt_Date));

              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
    END;
END Ap_Undo_Temp_Withholding;


PROCEDURE Ap_Undo_Withholding (
          P_Parent_Id              IN     NUMBER,
          P_Calling_Module         IN     VARCHAR2,
          P_Awt_Date               IN     DATE,
          P_New_Invoice_Payment_Id IN     NUMBER DEFAULT NULL,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER DEFAULT NULL,
          P_Program_Id             IN     NUMBER DEFAULT NULL,
          P_Request_Id             IN     NUMBER DEFAULT NULL,
          P_Awt_Success            OUT NOCOPY    VARCHAR2,
          P_Inv_Line_No            IN     NUMBER DEFAULT NULL,
          P_dist_Line_No           IN     NUMBER DEFAULT NULL,
          P_New_Invoice_Id         IN     NUMBER DEFAULT NULL,
          P_New_dist_Line_No       IN     NUMBER DEFAULT NULL)
IS
/*

   Copyright (c) 1995 by Oracle Corporation

   NAME
     Ap_Undo_Withholding
   DESCRIPTION
     Reverses AWT distribution lines, buckets, tax authority invoices
     for a full invoice or for a payment depENDing upon the calling module
   NOTES
     ThIS PROCEDURE IS part of the AP_WITHHOLDING_PKG PL/SQL package
   HISTORY              (YY/MM/DD)
     atassoni.it         95/07/14  Creation
     mhtaylor            95/08/21  Adapted for Adjust distributions

<< Beginning of Undo_Awt_By_Invoice_Payment program documentation >>

Flow of thIS PROCEDURE:

*---------------------------*
| BEGIN Ap_Undo_Withholding |
*---------------------------*
      |
      v
*---------------------------------------------------*
| Get one AWT distribution line for current invoice | <------------------+
| or invoice payment                                |                    |
*---------------------------------------------------*                    |
      |                                                                  |
      v                                                                  |
*------------------------------------------------------*                 |
| Get line accounting DATE AND corresponding WT period |                 |
*------------------------------------------------------*                 |
      |                                                                  |
      v                                                                  |
*-----------------------------------*                                    |
| Reverse the AWT distribution line |                                    |
*-----------------------------------*                                    |
      |                                                                  |
      v                                                                  |
*--------------------------------------------*                           |
| Adjust invoice amount AND payment schedule |                           |
*--------------------------------------------*                           |
      |                                                                  |
*--------------------------------------------*                           |
| Decrease corresponding bucket, IF exISting |                           |
*--------------------------------------------*                           |
      |                                                                  |
      +--> An invoice to a tax authority exISts?                         |
                                               ,'`.                      |
*-----------------------------*        Yes   ,'    `.                    |
| Reverse that invoice:       | <---------- <End Loop>                   |
| ~~~~~~~~~~~~~~~~~~~~        |              `.    ,'                    |
| - Reverse invoice line      |                `.,'                      |
| - Reverse distribution line |               No |                       |
| - Reverse payment schedules |                  |                       |
*-----------------------------*                  |                       |
                     |                           |                       |
                     +<--------------------------+                       |
                     |                                                   |
                     v                                                   |
                    ,'`.                                                 |
                  ,'    `.   No                                          |
                 <End Loop> ---------------------------------------------+
                  `.    ,'
                    `.,'
                 Yes |
                     v
          *-------------------------*
          | END Ap_Undo_Withholding |
          *-------------------------*


<< End of Ap_Undo_Withholding program documentation >>

*/

  -- PL/SQL Main Block Constants AND Variables:

  awt_period                 ap_other_periods.period_name%TYPE;
  gl_period_name             ap_invoice_distributions.period_name%TYPE;
  gl_awt_date                DATE;
  DBG_Loc                    VARCHAR2(30)  := 'Ap_Undo_Withholding';
  current_calling_sequence   VARCHAR2(2000);
  debug_info                 VARCHAR2(100);
  l_org_id                   NUMBER; /* Bug 4759178, added org_id */

  -- PL/SQL Main Block Exceptions:

  INVALID_CALLING_MODULE exception;
  NOT_AN_OPEN_GL_PERIOD  exception;

  -- PL/SQL Main Block Tables:

  -- PL/SQL Main Block CURSORs AND records:

  CURSOR c_awt_dists_inv (ParentId IN NUMBER)
  IS
  SELECT AID.accounting_date
  ,      AID.accrual_posted_flag
  ,      AID.assets_addition_flag
  ,      AID.assets_tracking_flag
  ,      AID.cash_posted_flag
  ,      AID.invoice_line_number
  ,      AID.distribution_line_number
  ,      AID.dist_code_combination_id
  ,      AID.invoice_id
  ,      AID.last_UPDATEd_by
  ,      AID.last_UPDATE_date
  ,      AID.line_type_lookup_code
  ,      AID.period_name
  ,      AID.set_of_books_id
  ,      AID.accts_pay_code_combination_id
  ,      AID.amount
  ,      AID.base_amount
  ,      AID.base_invoice_price_variance
  ,      AID.batch_id
  ,      AID.created_by
  ,      AID.creation_date
  ,      AID.description
  ,      AID.exchange_rate_variance
  ,      AID.final_match_flag
  ,      AID.income_tax_region
  ,      AID.invoice_price_variance
  ,      AID.last_UPDATE_login
  ,      AID.match_status_flag
  ,      AID.posted_flag
  ,      AID.po_distribution_id
  ,      AID.program_application_id
  ,      AID.program_id
  ,      AID.program_UPDATE_date
  ,      AID.quantity_invoiced
  ,      AID.rate_var_code_combination_id
  ,      AID.request_id
  ,      AID.reversal_flag
  ,      AID.type_1099
  ,      AID.unit_price
  ,      AID.withholding_tax_code_id  /* Bug 5382525 */
  ,      TC.name vat_code
  ,      AID.amount_encumbered
  ,      AID.base_amount_encumbered
  ,      AID.encumbered_flag
  ,      AID.price_adjustment_flag
  ,      AID.price_var_code_combination_id
  ,      AID.quantity_unencumbered
  ,      AID.stat_amount
  ,      AID.amount_to_post
  ,      AID.attribute1
  ,      AID.attribute10
  ,      AID.attribute11
  ,      AID.attribute12
  ,      AID.attribute13
  ,      AID.attribute14
  ,      AID.attribute15
  ,      AID.attribute2
  ,      AID.attribute3
  ,      AID.attribute4
  ,      AID.attribute5
  ,      AID.attribute6
  ,      AID.attribute7
  ,      AID.attribute8
  ,      AID.attribute9
  ,      AID.attribute_category
  ,      AID.base_amount_to_post
  ,      AID.cash_je_batch_id
  ,      AID.expenditure_item_date
  ,      AID.expenditure_organization_Id
  ,      AID.expenditure_type
  ,      AID.je_batch_id
  ,      AID.parent_invoice_id
  ,      AID.pa_addition_flag
  ,      AID.pa_quantity
  ,      AID.posted_amount
  ,      AID.posted_base_amount
  ,      AID.prepay_amount_remaining
  ,      AID.project_accounting_context
  ,      AID.project_id
  ,      AID.task_id
--,      AID.ussgl_transaction_code - Bug 4277744
--,      AID.ussgl_trx_code_context - Bug 4277744
  ,      AID.earliest_settlement_date
  ,      AID.req_distribution_id
  ,      AID.quantity_variance
  ,      AID.base_quantity_variance
  ,      AID.packet_id
  ,      AID.awt_flag
  ,      AID.awt_group_id
  ,      AID.awt_tax_rate_id
  ,      AID.awt_gross_amount
  ,      AID.awt_invoice_id
  ,      AID.awt_origin_group_id
  ,      AID.reference_1
  ,      AID.reference_2
  ,      AID.org_id
  ,      AID.other_invoice_id
  ,      AID.awt_invoice_payment_id
  ,      AID.invoice_distribution_id
  ,      AID.awt_related_id
        /* Start of fix for bug#8462050*/
  ,      AID.global_attribute_category
  ,      AID.global_attribute1
  ,      AID.global_attribute2
  ,      AID.global_attribute3
  ,      AID.global_attribute4
  ,      AID.global_attribute5
  ,      AID.global_attribute6
  ,      AID.global_attribute7
  ,      AID.global_attribute8
  ,      AID.global_attribute9
  ,      AID.global_attribute10
  ,      AID.global_attribute11
  ,      AID.global_attribute12
  ,      AID.global_attribute13
  ,      AID.global_attribute14
  ,      AID.global_attribute15
  ,      AID.global_attribute16
  ,      AID.global_attribute17
  ,      AID.global_attribute18
  ,      AID.global_attribute19
  ,      AID.global_attribute20
      /* End of fix for bug#8462050*/
  FROM   ap_invoice_distributions AID,
         ap_tax_codes TC
         --,ap_invoices  AI  --Bug8547506
  WHERE  AID.invoice_id               = ParentId
    AND  TC.tax_id (+)                = AID.withholding_tax_code_id  /* Bug 5382525 */
    --Bug8547506 Undoing changes done for bug6660355
    --AND  AID.invoice_id               = AI.invoice_id --6660355
    --AND  AID.awt_origin_group_id      = AI.awt_group_id
    AND  AID.invoice_line_number      = NVL(P_Inv_Line_No,
                                            AID.invoice_line_number)
    AND  AID.distribution_line_number = NVL(P_dist_Line_No,
                                            AID.distribution_line_number)
    AND  NVL(AID.reversal_flag, 'N') <> 'Y' -- bug 7606072
    AND  NVL(AID.awt_flag, 'M')     = 'A';

 -- only auto-generated AWT lines are to be considered

  CURSOR c_awt_dists_pay (ParentId IN NUMBER) IS
  SELECT AID.accounting_date
  ,      AID.accrual_posted_flag
  ,      AID.assets_addition_flag
  ,      AID.assets_tracking_flag
  ,      AID.cash_posted_flag
  ,      AID.invoice_line_number
  ,      AID.distribution_line_number
  ,      AID.dist_code_combination_id
  ,      AID.invoice_id
  ,      AID.last_UPDATEd_by
  ,      AID.last_UPDATE_date
  ,      AID.line_type_lookup_code
  ,      AID.period_name
  ,      AID.set_of_books_id
  ,      AID.accts_pay_code_combination_id
  ,      AID.amount
  ,      AID.base_amount
  ,      AID.base_invoice_price_variance
  ,      AID.batch_id
  ,      AID.created_by
  ,      AID.creation_date
  ,      AID.description
  ,      AID.exchange_rate_variance
  ,      AID.final_match_flag
  ,      AID.income_tax_region
  ,      AID.invoice_price_variance
  ,      AID.last_UPDATE_login
  ,      AID.match_status_flag
  ,      AID.posted_flag
  ,      AID.po_distribution_id
  ,      AID.program_application_id
  ,      AID.program_id
  ,      AID.program_UPDATE_date
  ,      AID.quantity_invoiced
  ,      AID.rate_var_code_combination_id
  ,      AID.request_id
  ,      AID.reversal_flag
  ,      AID.type_1099
  ,      AID.unit_price
  ,      AID.withholding_tax_code_id   /* Bug 5382525 */
  ,      TC.name vat_code
  ,      AID.amount_encumbered
  ,      AID.base_amount_encumbered
  ,      AID.encumbered_flag
  ,      AID.price_adjustment_flag
  ,      AID.price_var_code_combination_id
  ,      AID.quantity_unencumbered
  ,      AID.stat_amount
  ,      AID.amount_to_post
  ,      AID.attribute1
  ,      AID.attribute10
  ,      AID.attribute11
  ,      AID.attribute12
  ,      AID.attribute13
  ,      AID.attribute14
  ,      AID.attribute15
  ,      AID.attribute2
  ,      AID.attribute3
  ,      AID.attribute4
  ,      AID.attribute5
  ,      AID.attribute6
  ,      AID.attribute7
  ,      AID.attribute8
  ,      AID.attribute9
  ,      AID.attribute_category
  ,      AID.base_amount_to_post
  ,      AID.cash_je_batch_id
  ,      AID.expenditure_item_date
  ,      AID.expenditure_organization_Id
  ,      AID.expenditure_type
  ,      AID.je_batch_id
  ,      AID.parent_invoice_id
  ,      AID.pa_addition_flag
  ,      AID.pa_quantity
  ,      AID.posted_amount
  ,      AID.posted_base_amount
  ,      AID.prepay_amount_remaining
  ,      AID.project_accounting_context
  ,      AID.project_id
  ,      AID.task_id
--,      AID.ussgl_transaction_code - Bug 4277744
--,      AID.ussgl_trx_code_context - Bug 4277744
  ,      AID.earliest_settlement_date
  ,      AID.req_distribution_id
  ,      AID.quantity_variance
  ,      AID.base_quantity_variance
  ,      AID.packet_id
  ,      AID.awt_flag
  ,      AID.awt_group_id
  ,      AID.awt_tax_rate_id
  ,      AID.awt_gross_amount
  ,      AID.awt_invoice_id
  ,      AID.awt_origin_group_id
  ,      AID.reference_1
  ,      AID.reference_2
  ,      AID.org_id
  ,      AID.other_invoice_id
  ,      AID.awt_invoice_payment_id
  ,      AID.invoice_distribution_id
  ,      awt_related_id
      /* Start of fix for bug#8462050*/
  ,      AID.global_attribute_category
  ,      AID.global_attribute1
  ,      AID.global_attribute2
  ,      AID.global_attribute3
  ,      AID.global_attribute4
  ,      AID.global_attribute5
  ,      AID.global_attribute6
  ,      AID.global_attribute7
  ,      AID.global_attribute8
  ,      AID.global_attribute9
  ,      AID.global_attribute10
  ,      AID.global_attribute11
  ,      AID.global_attribute12
  ,      AID.global_attribute13
  ,      AID.global_attribute14
  ,      AID.global_attribute15
  ,      AID.global_attribute16
  ,      AID.global_attribute17
  ,      AID.global_attribute18
  ,      AID.global_attribute19
  ,      AID.global_attribute20
    /* End of fix for bug#8462050*/
  FROM   ap_invoice_distributions AID,
         ap_tax_codes TC
  WHERE  AID.awt_invoice_payment_id    = ParentId
    AND  TC.tax_id(+)                  = AID.withholding_tax_code_id  /* 5382525 */
    AND  AID.invoice_line_number       = NVL(P_Inv_Line_No,
                                             AID.invoice_line_number)
    AND  AID.distribution_line_number  = NVL(P_dist_Line_No,
                                            AID.distribution_line_number)
    AND  NVL(AID.awt_flag, 'M')        = 'A';

    -- only auto-generated AWT lines are to be considered

  rec_awt_dists c_awt_dists_pay%ROWTYPE;

  l_invoice_exchange_rate  ap_invoices.exchange_rate%type;
  l_func_currency_code     ap_system_parameters.base_currency_code%TYPE;
  l_old_inv_line_num       ap_invoice_lines_all.line_number%TYPE;

  -- Ap_Undo_Withholding:
  -- PL/SQL Main Block PROCEDUREs AND functions:

  --            _______
  --           |       |
  --           |       |
  --           |       |
  --  _________|       |_________
  --  \                         /
  --   \  Ap_Undo_Withholding  /
  --    \                     /
  --     \       _____       /
  --      \     |     |     /
  --       \    |     |    /
  --        \___|     |___/
  --         \           /
  --          \  BEGIN  /
  --           \       /
  --            \     /
  --             \   /
  --              \ /
  --               v

BEGIN
  current_calling_sequence := 'AP_WITHHOLDING_PKG.AP_Undo_Withholding';
  P_Awt_Success := 'SUCCESS'; -- Assumes successfully completion

  IF ( (P_Calling_Module NOT IN
               ('VOID PAYMENT', 'CANCEL INVOICE', 'REVERSE DIST'))
      OR
       (P_Calling_Module IS NULL)) THEN
    RAISE INVALID_CALLING_MODULE;
  END IF;

  SAVEPOINT BEFORE_UNDO_WITHHOLDING;
  /* Bug 4759178, get  org_id */
  debug_info := 'Select Org Id';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST')) THEN
    SELECT AI.org_id
    INTO   l_org_id
    FROM   AP_INVOICES_ALL AI
    WHERE  invoice_id = P_Parent_Id;

  ELSIF (P_Calling_Module = 'VOID PAYMENT') THEN
    SELECT AIP.org_id
    INTO   l_org_id
    FROM   AP_INVOICE_PAYMENTS_ALL AIP
    WHERE  AIP.invoice_payment_id = P_Parent_Id;

  END IF;

  debug_info := 'Select GL Period Name';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

  BEGIN
    SELECT   GPS.period_name,
             P_Awt_Date
      INTO   gl_period_name,
             gl_awt_date
      FROM   gl_period_statuses GPS,
             ap_system_parameters_all ASP
     WHERE   GPS.application_id                  = 200
       AND   GPS.set_of_books_id                 = ASP.set_of_books_id
       AND   P_Awt_Date BETWEEN GPS.start_date   AND GPS.END_date
       AND   GPS.closing_status                  IN ('O', 'F')
       AND   NVL(gps.ADJUSTMENT_PERIOD_FLAG,'N') = 'N'
       AND   ASP.org_id = l_org_id; /* Bug 4759178, added org_id condition*/

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ap_utilities_pkg.get_open_gl_date(P_Awt_Date, gl_period_name, gl_awt_date);
      IF gl_awt_date IS NULL THEN
        RAISE NOT_AN_OPEN_GL_PERIOD;
      END IF;
  END;

  <<Process_Withholding_dists>>
  DECLARE
    DBG_Loc VARCHAR2(30) := 'Process_Withholding_dists';
  BEGIN
    debug_info := 'OPEN CURSOR c_awt_dists';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST')) THEN
      OPEN  c_awt_dists_inv (P_Parent_Id);
    ELSIF (P_Calling_Module = 'VOID PAYMENT') THEN
      OPEN  c_awt_dists_pay (P_Parent_Id);
    END IF;

    <<For_Each_Withholding_Line>>
    LOOP
      debug_info := 'Fetch CURSOR c_get_awt_period';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

      IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST')) THEN
        FETCH c_awt_dists_inv INTO rec_awt_dists;
        EXIT WHEN c_awt_dists_inv%NOTFOUND;
      ELSIF (P_Calling_Module = 'VOID PAYMENT') THEN
        FETCH c_awt_dists_pay INTO rec_awt_dists;
        EXIT WHEN c_awt_dists_pay%NOTFOUND;
      END IF;
                                                                         --
      <<Get_Withholding_Period>>
      DECLARE
        DBG_Loc VARCHAR2(30) := 'Get_Withholding_Period';
        msg     VARCHAR2(240);
        CURSOR c_get_period (distDate IN DATE, TaxId IN NUMBER) IS
             SELECT period_name
             FROM   ap_other_periods  P,
                    ap_tax_codes      T
             WHERE  t.tax_id         = TaxId
               AND  p.period_type    = t.awt_period_type
               AND  p.application_id =  200
               AND  p.module         =  'AWT'
               AND  p.start_date     <= TRUNC(distDate)
               AND  p.end_date       >= TRUNC(distDate);
      BEGIN
        debug_info := 'OPEN CURSOR c_get_period';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        OPEN  c_get_period (rec_awt_dists.accounting_date
                           ,rec_awt_dists.withholding_tax_code_id);
        debug_info := 'Fetch CURSOR c_get_period';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        FETCH c_get_period INTO awt_period;

        IF c_get_period%FOUND THEN
          msg := 'AWT period '||awt_period||' found for tax id '||
                 rec_awt_dists.withholding_tax_code_id;
        ELSE
          msg := 'No AWT period found for tax id '||rec_awt_dists.withholding_tax_code_id;
        END IF;

        debug_info := 'CLOSE CURSOR c_get_period';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        CLOSE c_get_period;

      END Get_Withholding_Period;

      <<Reverse_Current_Line>>
      DECLARE
        DBG_Loc VARCHAR2(30) := 'Reverse_Current_Line';

        CURSOR c_invoice (InvId IN NUMBER) IS
        SELECT vendor_id
        ,      set_of_books_id
        ,      accts_pay_code_combination_id
        ,      batch_id
        ,      description
        ,      invoice_amount
        ,      invoice_currency_code
        ,      exchange_date
        ,      exchange_rate
        ,      exchange_rate_type
     -- ,      ussgl_transaction_code - Bug 4277744
     -- ,      ussgl_trx_code_context - Bug 4277744
        ,      vat_code
          FROM ap_invoices
         WHERE invoice_id = InvId
           FOR UPDATE;
        rec_invoice c_invoice%ROWTYPE;

        CURSOR c_curr_dist (InvId      IN NUMBER,
                            InvLineNum IN NUMBER) IS
        SELECT MAX(distribution_line_number)+1 curr_line_number
          FROM ap_invoice_distributions
         WHERE invoice_id          = InvId
           AND invoice_line_number = InvLineNum;

        curr_line_number           ap_invoice_distributions.distribution_line_number%TYPE;
        l_invoice_distribution_id  ap_invoice_distributions.invoice_distribution_id%TYPE;

     BEGIN
        debug_info := 'OPEN CURSOR c_curr_dist';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        OPEN  c_curr_dist (rec_awt_dists.invoice_id,
                           rec_awt_dists.invoice_line_number);

        debug_info := 'Fetch CURSOR c_curr_dist';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        FETCH c_curr_dist INTO curr_line_number;

        debug_info := 'CLOSE CURSOR c_curr_dist';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        CLOSE c_curr_dist;

        debug_info := 'OPEN CURSOR c_invoice';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        OPEN  c_invoice (rec_awt_dists.invoice_id);

        debug_info := 'Fetch CURSOR c_invoice';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

	FETCH c_invoice INTO rec_invoice;

        debug_info := 'Discard the Line';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        /* Bug  5202248. Added the Nvl */
        IF nvl(l_old_inv_line_num, 0) <> rec_awt_dists.invoice_line_number THEN
          UPDATE  ap_invoice_lines_all
             SET  discarded_flag          = DECODE(p_calling_module,'CANCEL INVOICE','N','Y'),
                  /* Bug 5299720. Comment out the following line */
                --  Cancelled_flag          = DECODE(p_calling_module,'CANCEL INVOICE','Y','N'),
                  Original_amount         = amount,
                  Original_base_amount    = base_amount,
                  Original_rounding_amt   = rounding_amt,
                  Amount                  = 0,
                  Base_amount             = 0,
                  Rounding_amt            = 0,
                  Last_update_date        = SYSDATE,
                  Last_Updated_By         = P_Last_Updated_By,
                  Last_Update_Login       = P_Last_Update_Login,
                  Program_application_id  = P_Program_application_id,
                  Program_id              = P_Program_id,
                  Program_update_date     = DECODE(p_program_id,NULL,NULL,SYSDATE),
                  Request_id              = P_Request_id
           WHERE  invoice_id              = rec_awt_dists.invoice_id
             AND  line_number             = rec_awt_dists.invoice_line_number;

          l_old_inv_line_num := rec_awt_dists.invoice_line_number;
        END IF;

        -- IF (P_Calling_module not in ('REVERSE DIST')) THEN
        -- From now there will be no difference between REVERSE DIST and CANCEL INVOICE
        -- except when REVERSE DIST IS passed match status flag of newly created
        -- awt lines will be N else it will be Y.

        debug_info := 'Insert reverse AWT line INTO ap_invoice_distributions';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        INSERT INTO ap_invoice_distributions
           (
            accounting_date
           ,accrual_posted_flag
           ,assets_addition_flag
           ,assets_tracking_flag
           ,cash_posted_flag
           ,distribution_line_number
           ,invoice_line_number
           ,dist_code_combination_id
           ,invoice_id
           ,last_UPDATEd_by
           ,last_UPDATE_date
           ,line_type_lookup_code
           ,period_name
           ,set_of_books_id
           ,amount
           ,base_amount
           ,batch_id
           ,created_by
           ,creation_date
           ,description
           ,last_UPDATE_login
           ,match_status_flag
           ,posted_flag
           ,program_application_id
           ,program_id
           ,program_update_date
           ,request_id
           ,withholding_tax_code_id    /* Bug 5382525 */
           ,encumbered_flag
           ,pa_addition_flag
           ,posted_amount
           ,posted_base_amount
        -- ,ussgl_transaction_code - Bug 4277744
        -- ,ussgl_trx_code_context - Bug 4277744
           ,awt_flag
           ,awt_tax_rate_id
           ,awt_gross_amount
           ,awt_origin_group_id
           ,awt_invoice_payment_id
           ,tax_code_override_flag
           ,tax_recovery_rate
           ,tax_recovery_override_flag
           ,tax_recoverable_flag
           ,invoice_distribution_id
           ,reversal_flag
           ,parent_reversal_id
           ,type_1099
           ,income_tax_region
           ,org_id
           ,awt_related_id
	   --Freight and Special Charges
	   ,rcv_charge_addition_flag
	   /* Start of fix for bug#8462050*/
	   ,global_attribute_category
           ,global_attribute1
           ,global_attribute2
           ,global_attribute3
           ,global_attribute4
           ,global_attribute5
           ,global_attribute6
           ,global_attribute7
           ,global_attribute8
           ,global_attribute9
           ,global_attribute10
           ,global_attribute11
           ,global_attribute12
           ,global_attribute13
           ,global_attribute14
           ,global_attribute15
           ,global_attribute16
           ,global_attribute17
           ,global_attribute18
           ,global_attribute19
           ,global_attribute20
         /* End of fix for bug#8462050*/
           )
           values
           (
            gl_awt_date
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,curr_line_number   /*bug 5202248. invoice_line_number was inserted before */
           ,rec_awt_dists.invoice_line_number
           ,rec_awt_dists.dISt_code_combination_id
           ,rec_awt_dists.invoice_id
           ,P_Last_Updated_By
           ,SYSDATE
           ,'AWT'
           ,gl_period_name
           ,rec_invoice.set_of_books_id
           ,-rec_awt_dists.amount
           ,-rec_awt_dists.base_amount
           ,rec_invoice.batch_id
           ,P_Last_Updated_By
           ,SYSDATE
           ,rec_awt_dists.description
           ,P_Last_Update_Login
           ,decode(p_calling_module,'REVERSE DIST','N','A') -- BUG 6720284
           ,'N'
           ,P_Program_Application_Id
           ,P_Program_Id
           ,decode (P_Program_Id,NULL,NULL,SYSDATE)
           ,P_Request_Id
           ,rec_awt_dists.withholding_tax_code_id
           ,'T'
           ,'E'
           ,0
           ,0
        -- ,rec_invoice.ussgl_transaction_code - Bug 4277744
        -- ,rec_invoice.ussgl_trx_code_context - Bug 4277744
           ,'A'
           ,rec_awt_dists.awt_tax_rate_id
           ,rec_awt_dists.awt_gross_amount * -1
           ,rec_awt_dists.awt_origin_group_id
           ,P_New_Invoice_Payment_Id
           ,'N'
           ,''
           ,'N'
           ,'N'
           ,ap_invoice_distributions_s.nextval
           ,'N'
           ,rec_awt_dists.invoice_distribution_id
           ,rec_awt_dists.type_1099
           ,rec_awt_dists.income_tax_region
           ,rec_awt_dists.org_id
           ,rec_awt_dists.awt_related_id
	   ,'N'
	   /* Start of fix for bug#8462050*/
	   ,rec_awt_dists.global_attribute_category
	   ,rec_awt_dists.global_attribute1
	   ,rec_awt_dists.global_attribute2
	   ,rec_awt_dists.global_attribute3
	   ,rec_awt_dists.global_attribute4
	   ,rec_awt_dists.global_attribute5
	   ,rec_awt_dists.global_attribute6
	   ,rec_awt_dists.global_attribute7
	   ,rec_awt_dists.global_attribute8
	   ,rec_awt_dists.global_attribute9
	   ,rec_awt_dists.global_attribute10
           ,rec_awt_dists.global_attribute11
	   ,rec_awt_dists.global_attribute12
	   ,rec_awt_dists.global_attribute13
	   ,rec_awt_dists.global_attribute14
	   ,rec_awt_dists.global_attribute15
	   ,rec_awt_dists.global_attribute16
	   ,rec_awt_dists.global_attribute17
	   ,rec_awt_dists.global_attribute18
	   ,rec_awt_dists.global_attribute19
	   ,rec_awt_dists.global_attribute20
	  /* End of fix for bug#8462050*/
           );

	--Bug 4539462 DBI logging
        AP_DBI_PKG.Maintain_DBI_Summary
            ( p_table_name        => 'AP_INVOICE_DISTRIBUTIONS',
              p_operation         => 'I',
              p_key_value1        => rec_awt_dists.invoice_id,
              p_key_value2        => l_Invoice_distribution_ID,
              p_calling_sequence  => current_calling_sequence);


        <<Update_Payment_Schedule>>
        DECLARE

          reversed_withholding NUMBER := -rec_awt_dists.amount;

          CURSOR  c_payment_num (InvPaymId IN NUMBER) IS
          SELECT  payment_num
            FROM  ap_invoice_payments
           WHERE  invoice_payment_id = InvPaymId;

          paym_num ap_invoice_payments.payment_num%TYPE;

          CURSOR c_payment_sched (PaymNum IN NUMBER, InvId IN NUMBER) IS

          SELECT  APS.gross_amount
          ,       NVL(APS.inv_curr_gross_amount, APS.gross_Amount) inv_curr_gross_amount
          ,       APS.amount_remaining
          ,       AI.payment_currency_code
            FROM  ap_payment_schedules APS,
                  ap_invoices AI
           WHERE  AI.invoice_id     = InvId
             AND  AI.invoice_id     = APS.invoice_id
             AND  APS.payment_num   = NVL(PaymNum, APS.payment_num) /* Bug 5300858 */
             FOR UPDATE of APS.gross_amount, APS.inv_curr_gross_amount, APS.amount_remaining;

          rec_payment_sched    c_payment_sched%ROWTYPE;

          DBG_Loc VARCHAR2(30) := 'Update_Payment_Schedule';

          NOTHING_TO_DO exception;

        BEGIN

          /* Bug 5300858 */
          IF (P_Calling_Module NOT IN ('REVERSE DIST', 'VOID PAYMENT')) THEN
            RAISE NOTHING_TO_DO;
          END IF;

          /* Bug 5300858 */
          IF (P_Calling_Module = 'VOID PAYMENT') THEN

            debug_info := 'OPEN CURSOR c_payment_num';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            OPEN  c_payment_num(P_Parent_Id);

            debug_info := 'Fetch CURSOR c_payment_num';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            FETCH c_payment_num INTO paym_num;

            debug_info := 'CLOSE CURSOR c_payment_num';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            CLOSE c_payment_num;

          END IF;

          debug_info := 'OPEN CURSOR c_payment_sched';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          OPEN  c_payment_sched(paym_num, rec_awt_dists.invoice_id);

          debug_info := 'Fetch CURSOR c_payment_sched';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          FETCH c_payment_sched INTO rec_payment_sched;

          IF (c_payment_sched%FOUND) THEN
            debug_info := 'Update the payment schedule';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

            UPDATE ap_payment_schedules
               SET amount_remaining = (amount_remaining +
                                       ap_utilities_pkg.ap_round_currency(
                                          reversed_withholding *
                                          payment_cross_rate,
                                          rec_payment_sched.payment_currency_code))
		, payment_status_flag = decode(amount_remaining +      -- Bug 8300099/4959558
                  ap_utilities_pkg.ap_round_currency(reversed_withholding * payment_cross_rate,
                  rec_payment_sched.payment_currency_code),gross_amount,'N','P')
            WHERE  CURRENT of c_payment_sched;

	    -- Bug 8300099/7518063 : Added below update statement
	    UPDATE ap_invoices
	    SET    payment_status_flag = AP_INVOICES_UTILITY_PKG.get_payment_status( rec_awt_dists.invoice_id )
	    WHERE  invoice_id = rec_awt_dists.invoice_id ;

	  ELSE
            NULL;
          END IF;

          debug_info := 'CLOSE CURSOR c_payment_sched';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          CLOSE c_payment_sched;

        EXCEPTION
          WHEN NOTHING_TO_DO THEN
           NULL;

        END Update_Payment_Schedule;

        <<Update_Bucket>>
        DECLARE
          CURSOR c_awt_bucket (VendorId IN NUMBER,
                               Period   IN VARCHAR2,
                               TaxCode  IN VARCHAR2) IS
          SELECT gross_amount_to_date,
                 withheld_amount_to_date
            FROM ap_awt_buckets
           WHERE vendor_id   = VendorId
             AND period_name = Period
             AND tax_name    = TaxCode
          FOR UPDATE;

          gross_amt_to_date    ap_awt_buckets.gross_amount_to_date%TYPE;
          withheld_amt_to_date ap_awt_buckets.withheld_amount_to_date%TYPE;

          DBG_Loc VARCHAR2(30) := 'Update_Bucket';
          NOTHING_TO_DO exception;
        BEGIN
          IF awt_period IS NULL THEN
            raISe NOTHING_TO_DO;
          END IF;

          debug_info := ' Fetching the functional currency AND exchange rate ' ;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          SELECT base_currency_code
            INTO l_func_currency_code
            FROM ap_system_parameters
	    WHERE org_id = l_org_id;

          IF (P_Calling_Module in ('CANCEL INVOICE','REVERSE DIST')) THEN
              l_invoice_exchange_rate := rec_invoice.exchange_rate;
          ELSIF (P_Calling_Module = 'VOID PAYMENT') THEN

          SELECT  ai.exchange_rate
            INTO  l_invoice_exchange_rate
            FROM  ap_invoices ai, ap_invoice_payments aip
           WHERE  ai.invoice_id          = aip.invoice_id
             AND  aip.invoice_payment_id = rec_awt_dists.awt_invoice_payment_id;
          END IF;

          debug_info := 'OPEN CURSOR c_awt_bucket';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          OPEN  c_awt_bucket(rec_invoice.vendor_id
                            ,awt_period
                            ,rec_awt_dists.vat_code
                            );
          debug_info := 'Fetch CURSOR c_awt_bucket';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          FETCH c_awt_bucket INTO gross_amt_to_date, withheld_amt_to_date;

          IF (c_awt_bucket%FOUND) THEN
            debug_info := 'Update the AWT bucket';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

              UPDATE ap_awt_buckets
                 SET gross_amount_to_date = (gross_amt_to_date -
                                             ap_utilities_pkg.ap_round_currency(
                                               rec_awt_dists.awt_gross_amount*
                                               NVL(l_invoice_exchange_rate,1),
                                             l_func_currency_code )),
                     withheld_amount_to_date = (withheld_amt_to_date+
                                                ap_utilities_pkg.ap_round_currency(
                                                  rec_awt_dists.amount*NVL(l_invoice_exchange_rate,1),
                                                  l_func_currency_code ))
               WHERE CURRENT OF c_awt_bucket;
          ELSE
            NULL;
          END IF;

          debug_info := 'CLOSE CURSOR c_awt_bucket';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          CLOSE c_awt_bucket;

        EXCEPTION
          WHEN NOTHING_TO_DO THEN NULL;
        END Update_Bucket;

        debug_info := 'CLOSE CURSOR c_invoice';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

        CLOSE c_invoice;

        -- Create/Reverse the invoice to the Tax Authority
        DECLARE
          CURSOR  c_read_setup
          IS
          SELECT  create_awt_invoices_type,create_awt_dists_type    --bug7685907
            FROM  ap_system_parameters;
        BEGIN
          debug_info := 'OPEN CURSOR c_read_setup';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          OPEN  c_read_setup;

          debug_info := 'Fetch CURSOR c_read_setup';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          FETCH c_read_setup INTO l_create_invoices,l_create_dists;   --bug7685907

          debug_info := 'CLOSE CURSOR c_read_setup';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

          CLOSE c_read_setup;
          --Bug6660355

	  /* bug 8266021 the following call to create awt invoices
	  is moved outside the loop

          IF (l_create_invoices in('APPROVAL','BOTH')) THEN
            -- Bug 8254604
            Create_AWT_Invoices(
          P_Invoice_Id             => rec_awt_dists.invoice_id,
          P_Payment_Date           => NULL,
          P_Last_Updated_By        => P_Last_Updated_By,
          P_Last_Update_Login      => P_Last_Update_Login,
          P_Program_Application_Id => P_Program_Application_Id,
          P_Program_Id             => P_Program_Id,
          P_Request_Id             => P_Request_Id,
          P_Calling_Sequence       => current_calling_sequence,
          P_Calling_Module         => p_calling_module,
          P_Inv_Line_No            => rec_awt_dists.invoice_line_number,
          P_Dist_Line_No           => curr_line_number,
          P_New_Invoice_Id         => P_New_Invoice_Id,
          P_create_dists           => l_create_dists);     --bug7685907

          ELSIF (l_create_invoices in('PAYMENT','BOTH') AND
                 rec_awt_dists.awt_invoice_id IS NOT NULL) THEN
            -- Bug 8254604
            Create_AWT_Invoices(
          P_Invoice_Id             => rec_awt_dists.invoice_id,
          P_Payment_Date           => NULL,
          P_Last_Updated_By        => P_Last_Updated_By,
          P_Last_Update_Login      => P_Last_Update_Login,
          P_Program_Application_Id => P_Program_Application_Id,
          P_Program_Id             => P_Program_Id,
          P_Request_Id             => P_Request_Id,
          P_Calling_Sequence       => current_calling_sequence,
          P_Calling_Module         => p_calling_module,
          P_Inv_Line_No            => rec_awt_dists.invoice_line_number,
          P_Dist_Line_No           => NVL(P_New_dist_Line_No, P_dist_Line_No),
          P_New_Invoice_Id         => P_New_Invoice_Id,
          P_create_dists           => l_create_dists);     --bug7685907

           END IF;

	   */

           UPDATE  ap_invoice_distributions
              SET  reversal_flag='Y'
            WHERE  invoice_distribution_id = rec_awt_dists.invoice_distribution_id
               OR  parent_reversal_id=rec_awt_dists.invoice_distribution_id;

        END;
      END Reverse_Current_Line;
    END LOOP For_Each_Withholding_Line;

debug_info := 'rec_awt_dists.awt_invoice_id '|| rec_awt_dists.awt_invoice_id;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

debug_info := 'rec_awt_dists.invoice_id '|| rec_awt_dists.invoice_id;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

debug_info := 'P_Parent_Id '|| P_Parent_Id;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;


debug_info := 'l_create_invoices '||l_create_invoices;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    IF (l_create_invoices in('APPROVAL','BOTH') and p_calling_module <> 'VOID PAYMENT') THEN
            -- Bug 8254604
            Create_AWT_Invoices(
          P_Invoice_Id             => P_Parent_Id,			--bug 8266021
          P_Payment_Date           => NULL,
          P_Last_Updated_By        => P_Last_Updated_By,
          P_Last_Update_Login      => P_Last_Update_Login,
          P_Program_Application_Id => P_Program_Application_Id,
          P_Program_Id             => P_Program_Id,
          P_Request_Id             => P_Request_Id,
          P_Calling_Sequence       => current_calling_sequence,
          P_Calling_Module         => p_calling_module,
          P_Inv_Line_No            => NULL,
          P_Dist_Line_No           => NULL,
          P_New_Invoice_Id         => P_New_Invoice_Id,			--bug 8266021
          P_create_dists           => l_create_dists);     --bug7685907

          ELSIF (l_create_invoices in('PAYMENT','BOTH')
	  --AND rec_awt_dists.awt_invoice_id IS NOT NULL (commented in bug 8266021)
	  ) THEN
            -- Bug 8254604
            Create_AWT_Invoices(
          P_Invoice_Id             => rec_awt_dists.invoice_id,
          P_Payment_Date           => NULL,
          P_Last_Updated_By        => P_Last_Updated_By,
          P_Last_Update_Login      => P_Last_Update_Login,
          P_Program_Application_Id => P_Program_Application_Id,
          P_Program_Id             => P_Program_Id,
          P_Request_Id             => P_Request_Id,
          P_Calling_Sequence       => current_calling_sequence,
          P_Calling_Module         => p_calling_module,
          P_Inv_Line_No            => NULL,
          P_Dist_Line_No           => NULL,
          P_New_Invoice_Id         => P_New_Invoice_Id,
          P_create_dists           => l_create_dists);     --bug7685907

           END IF;

    debug_info := 'CLOSE CURSOR c_awt_dists';
    	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;

    IF (P_Calling_Module IN ('CANCEL INVOICE','REVERSE DIST')) THEN
      CLOSE c_awt_dists_inv;

      UPDATE  ap_invoice_distributions
         SET  awt_withheld_amt         = NULL
       WHERE  invoice_id               = P_parent_id
         AND  NVL(awt_withheld_amt,0) <> 0;

    ELSIF (P_Calling_Module = 'VOID PAYMENT') THEN
      CLOSE c_awt_dists_pay;
    END IF;

  END Process_Withholding_dists;

  -- Execute the ExtENDed Withholding Reversion (IF active)

  IF (Ap_ExtENDed_Withholding_Pkg.Ap_ExtENDed_Withholding_Active) THEN
      Ap_ExtENDed_Withholding_Pkg.Ap_Undo_ExtENDed_Withholding
                            (P_Parent_Id,
                             P_Calling_Module,
                             P_Awt_Date,
                             P_New_Invoice_Payment_Id,
                             P_Last_Updated_By,
                             P_Last_Update_Login,
                             P_Program_Application_Id,
                             P_Program_Id,
                             P_Request_Id,
                             P_Awt_Success,
                             P_dist_Line_No,
                             P_New_Invoice_Id,
                             P_New_dist_Line_No);
  END IF;


EXCEPTION
  WHEN INVALID_CALLING_MODULE THEN
    P_Awt_Success := 'Error: Invalid Calling Module ['||P_Calling_Module||']';

  WHEN NOT_AN_OPEN_GL_PERIOD THEN
    DECLARE
      error_text VARCHAR2(2000);
    BEGIN
      error_text := Ap_Utilities_Pkg.Ap_Get_DISplayed_Field('AWT ERROR',
                                               'GL PERIOD NOT OPEN');
      P_AWT_Success := error_text;
    END;
                                                                         --
  WHEN OTHERS THEN
    DECLARE
      error_text VARCHAR2(512) := substr(sqlerrm, 1, 512);
    BEGIN
      ROLLBACK TO BEFORE_UNDO_WITHHOLDING;
                                                                         --
      P_Awt_Success := error_text;

           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      '  Parent Id  = '       || to_char(P_Parent_Id) ||
                      ', Calling_Module = '   || P_Calling_Module ||
                      ', Awt_Date = '         || P_Awt_Date ||
                      ', New_Invoice_Payment_Id  = ' || to_char(P_New_Invoice_Payment_Id) ||
                      ', dist_Line_No = ' || to_char(P_dist_Line_No) ||
                      ', New_Invoice_Id = '       || to_char(P_New_Invoice_Id) ||
                      ', New_dist_Line_No  = '   || to_char(P_New_dist_Line_No));

              FND_MESSAGE.set_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
    END;
END Ap_Undo_Withholding;

END AP_WITHHOLDING_PKG;

/
