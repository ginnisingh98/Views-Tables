--------------------------------------------------------
--  DDL for Package Body AP_CALC_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CALC_WITHHOLDING_PKG" AS
/* $Header: apclawtb.pls 120.20.12010000.13 2010/02/25 20:37:06 gagrawal ship $ */

-- ====================================================================
--          P R I V A T E - G L O B A L V A R I A B L E S
-- ====================================================================
-- BUG 7232736  : shifted the org_id declaration to the pachage spec
--     g_org_id           NUMBER(15); /* Bug3700128. MOAC Project */

-- =====================================================================
--                   P R I V A T E    O B J E C T S
-- =====================================================================

FUNCTION Do_AWT_Cut_Off(
         P_Awt_Date          IN DATE,
         P_Amount_Subject    IN NUMBER,
         P_Amount_Withheld   IN NUMBER,
         P_Vendor_Id         IN NUMBER,
         P_Tax_Name          IN VARCHAR2,
         P_Awt_Period_Name   IN VARCHAR2,
         P_Period_Limit      IN NUMBER,
         P_Calling_Sequence  IN VARCHAR2)
RETURN  NUMBER
IS
  /*

        NAME:           Do_AWT_Cut_Off
        FUNCTION:       To cut off amounts to be withheld  WHERE appropriate
        HISTORY:        atassoni.IT modIFied 04/25/95
                                   (bucket manipulation extracted   FROM this
                                    code to make up the new PROCEDURE
                                    H   ANDLE_BUCKET; as a consequence, the
                                    Manual hypothesis IS no more needed).
                        mhtaylor.UK created 04/17/95
        NOTES:

  Withholding DATE IS passed in to determine which period we are in.
  Amount subject    AND amount withheld are passed in to carry out the
  actual calculation with. Vendor id    AND tax name allow us to find
  the appropriate bucket records. The NUMBER passed out IS the amount
  to be withheld.  If no cut off has been applied this will be the
  same as the amount withheld passed in.  */

  l_awt_period_type         ap_tax_codes.awt_period_type%TYPE;
  l_awt_period_name         ap_other_periods.period_name%TYPE
                            := P_Awt_Period_Name;
  l_awt_period_limit        ap_tax_codes.awt_period_limit%TYPE
                            := P_Period_Limit;
  l_withheld_amount_to_date ap_awt_buckets.withheld_amount_to_date%TYPE;
  l_amount_withheld         NUMBER;

  CURSOR  c_get_bucket (PerName IN VARCHAR2)
  IS
  SELECT  bk.withheld_amount_to_date
    FROM  ap_awt_buckets bk
   WHERE  bk.period_name = PerName
     AND  bk.tax_name    = P_Tax_Name
     AND  bk.vendor_id   = P_Vendor_Id
     AND  bk.org_id      = g_org_id;    -- bug 7301484


  DBG_Loc                      VARCHAR2(30) := 'Do_Awt_Cut_Off';
  current_calling_sequence     VARCHAR2(2000);
  debug_info                   VARCHAR2(100);

BEGIN

  current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Do_AWT_Cut_Off<-' ||
                              P_Calling_Sequence;
  IF ( (P_Amount_Withheld IS NULL)
       OR
       (P_Amount_Withheld = 0)) THEN
     RETURN(0);  -- Immediately RETURN ZERO IF withholding amount to
                 -- cut off IS NULLOR zero
  END IF;

  IF (l_awt_period_type = '' OR l_awt_period_limit = '') THEN
    -- No period exists: do nothing    AND RETURN the same amount withheld
    RETURN (P_Amount_Withheld);
  ELSE
    -- Find the appropriate bucket record IF one exists.
    debug_info := 'Open CURSOR c_get_bucket';

    OPEN  c_get_bucket(l_awt_period_name);
    debug_info := 'Fetch CURSOR c_get_bucket';

    FETCH  c_get_bucket
       INTO  l_withheld_amount_to_date;

    IF c_get_bucket%FOUND THEN

      -- Does the bucket amount withheld so far WHEN added to the
      -- package amount withheld before period limits have been
      -- applied break the period limit ?
      IF (P_Amount_Withheld + l_withheld_amount_to_date
             > l_awt_period_limit) THEN
        -- It does. Calculate actual amount to withhold
        l_amount_withheld := l_awt_period_limit -
                             l_withheld_amount_to_date;
      ELSE
        -- It doesn't. Amount to withhold leaved unchanged.
        l_amount_withheld := NVL(P_Amount_Withheld, 0);
      END IF;
    ELSE
      -- Just checking that the amount withheld doesn't immediately
      -- break the limit.
      IF (P_Amount_Withheld > l_awt_period_limit) THEN
         -- It does. Calculate actual amount to withhold.
         l_amount_withheld := l_awt_period_limit;
      ELSE
         -- It doesn't. Amount to withhold leaved unchanged.
         l_amount_withheld := NVL(P_Amount_Withheld, 0);
      END IF;
    END IF;

    debug_info := 'Close CURSOR c_get_bucket';
    CLOSE c_get_bucket;

    -- End: Return the amount to be withheld after cut off
    RETURN (l_amount_withheld);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  P_Awt_Date  = '       || to_char(P_Awt_Date) ||
                      ', P_Amount_Subject  = ' || to_char(P_Amount_Subject) ||
                      ', P_Amount_Withheld = ' || to_char(P_Amount_Withheld) ||
                      ', P_Vendor_Id = '       || to_char(P_Vendor_Id) ||
                      ', P_Tax_Name  = '       || P_Tax_Name ||
                      ', P_Awt_Period_Name = ' || P_Awt_Period_Name ||
                      ', P_Period_limit  = '   || to_char(P_Period_limit));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
END Do_AWT_Cut_Off;

-- =====================================================================
--                    P U B L I C   O B J E C T S
-- =====================================================================


PROCEDURE Handle_Bucket (
          P_Awt_Period_Name        IN VARCHAR2,
          P_Amount_Subject         IN NUMBER,
          P_Amount_Withheld        IN NUMBER,
          P_Vendor_Id              IN NUMBER,
          P_Tax_Name               IN VARCHAR2,
          P_Calling_Module         IN VARCHAR2,
          P_Last_Updated_By        IN NUMBER,
          P_Last_Update_Login      IN NUMBER,
          P_Program_Application_Id IN NUMBER,
          P_Program_Id             IN NUMBER,
          P_Request_Id             IN NUMBER,
          P_Calling_Sequence       IN VARCHAR2)
IS
  DBG_Loc                      VARCHAR2(30) := 'Handle_Bucket';
  dummy                        CHAR(1);
  current_calling_sequence     VARCHAR2(2000);
  debug_info                   VARCHAR2(100);

  CURSOR  c_get_bucket IS
  SELECT  'Y'
    FROM  ap_awt_buckets bk
   WHERE  bk.period_name = P_Awt_Period_Name
     AND  bk.tax_name    = P_Tax_Name
     AND  bk.vendor_id   = P_Vendor_Id
     AND  bk.org_id      = g_org_id    -- bug 7301484
  FOR     UPDATE;

  DO_NOT_UPDATE EXCEPTION;

BEGIN
  current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Handle_Bucket<-' ||
                               P_calling_sequence;

  -- Check if UPDATE is allowed

  IF (P_Calling_Module = 'INVOICE INQUIRY') THEN
    RAISE DO_NOT_UPDATE;
  END IF;

  -- Find the appropriate bucket record IF one exists.
  -- Ap_Logging_Pkg.Ap_Begin_Block (DBG_Loc);

  debug_info := 'Open CURSOR to get buckets';
  OPEN  c_get_bucket;

  debug_info := 'Fetch   FROM CURSOR to get buckets';
  FETCH c_get_bucket   INTO dummy;

  IF c_get_bucket%FOUND THEN

    -- Update existing bucket
    debug_info := 'Update existing bucket';

    UPDATE  ap_awt_buckets
       SET  gross_amount_to_date    = gross_amount_to_date +
                                      NVL(P_Amount_Subject, 0),
            withheld_amount_to_date = withheld_amount_to_date +
                                      NVL(P_Amount_Withheld, 0),
            last_update_date        = SYSDATE,
            last_updated_by         = P_Last_Updated_By,
            last_update_login       = P_Last_Update_Login,
            program_update_date     = SYSDATE,
            program_application_id  = P_Program_Application_Id,
            program_id              = P_Program_Id,
            request_id              = P_Request_Id
     WHERE  CURRENT OF c_get_bucket;
  ELSE
    -- Create new bucket
    debug_info := 'Create new bucket';

    INSERT INTO ap_awt_buckets
           (period_name
           ,tax_name
           ,vendor_id
           ,withheld_amount_to_date
           ,gross_amount_to_date
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,creation_date
           ,created_by
           ,program_update_date
           ,program_application_id
           ,program_id
           ,request_id
           ,org_id                  /* Bug 3700128. MOAC Project */
           )
    VALUES (P_Awt_Period_Name
           ,P_Tax_Name
           ,P_Vendor_Id
           ,NVL(P_Amount_Withheld, 0)
           ,NVL(P_Amount_Subject, 0)
           ,SYSDATE
           ,P_Last_Updated_By
           ,P_Last_Update_Login
           ,SYSDATE
           ,P_Last_Updated_By
           ,SYSDATE
           ,P_Program_Application_Id
           ,P_Program_Id
           ,P_Request_Id
           ,g_org_id);              /* Bug 3700128. MOAC Project */
  END IF;

  debug_info := 'Close CURSOR to get buckets';
  CLOSE c_get_bucket;

EXCEPTION
  WHEN DO_NOT_UPDATE THEN
    NULL;
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  P_Awt_Period_Name = ' || P_Awt_Period_Name ||
                      ', P_Amount_Subject  = ' || to_char(P_Amount_Subject) ||
                      ', P_Amount_Withheld = ' || to_char(P_Amount_Withheld) ||
                      ', P_Vendor_Id = '       || to_char(P_Vendor_Id) ||
                      ', P_Tax_Name = '        || P_Tax_Name ||
                      ', P_Calling_Module  = ' || P_Calling_Module);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Handle_Bucket;


PROCEDURE Insert_Temp_Distribution(
          InvoiceId                 IN NUMBER,
          SuppId                    IN NUMBER,
          PaymentNum                IN NUMBER,
          GroupId                   IN NUMBER,
          TaxName                   IN VARCHAR2,
          CodeCombinationId         IN NUMBER,
          GrossAmount               IN NUMBER,
          WithheldAmount            IN NUMBER,
          AwtDate                   IN DATE,
          GLPeriodName              IN VARCHAR2,
          AwtPeriodType             IN VARCHAR2,
          AwtPeriodName             IN VARCHAR2,
         -- P_Awt_Related_Id        IN NUMBER   DEFAULT NULL,   --Bug 6168793
          CheckrunName              IN VARCHAR2,
          WithheldRateId            IN NUMBER,
          ExchangeRate              IN NUMBER,
          CurrCode                  IN VARCHAR2,
          BaseCurrCode              IN VARCHAR2,
          auto_offset_segs          IN VARCHAR2,
          P_Calling_Sequence        IN VARCHAR2,
          HandleBucket              IN VARCHAR2 DEFAULT 'N',
          LastUpdatedBy             IN NUMBER   DEFAULT NULL,
          LastUpdateLogin           IN NUMBER   DEFAULT NULL,
          ProgramApplicationId      IN NUMBER   DEFAULT NULL,
          ProgramId                 IN NUMBER   DEFAULT NULL,
          RequestId                 IN NUMBER   DEFAULT NULL,
          CallingModule             IN VARCHAR2 DEFAULT NULL,
          P_Invoice_Payment_Id      IN NUMBER   DEFAULT NULL,
          invoice_exchange_rate     IN NUMBER   DEFAULT NULL,
          GLOBAL_ATTRIBUTE_CATEGORY IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE1         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE2         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE3         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE4         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE5         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE6         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE7         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE8         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE9         IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE10        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE11        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE12        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE13        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE14        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE15        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE16        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE17        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE18        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE19        IN VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE20        IN VARCHAR2 DEFAULT NULL,
          p_checkrun_id             in number   default null,
          P_Awt_Related_Id        IN NUMBER   DEFAULT NULL --bug6524425
          )
  IS
    base_WT_amount              NUMBER;
    Withheld_Amt                NUMBER;
    DBG_Loc                     VARCHAR2(30) := 'Insert_Temp_Distribution';

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
    l_reason                    VARCHAR2(100);
    l_proration_divisor         NUMBER;
    l_proration_base_divisor    NUMBER;
    l_awt_related_id            NUMBER(15);

    -- bug8588459, changed the cursor for getting the
    -- distribution type and the related_id. In case
    -- it is an ERV distribution, we want the awt_
    -- related_id to be the related_id for the ERV
    -- distributions.
    --
    -- This is to avoid accounting issues, because
    -- of ERV dist missing a representation in
    -- the secondary ledger XLA_Distribution_Links
    --
    CURSOR c_prorate_awt_lines (
          P_invoice_id            IN NUMBER,
          proration_divisor       IN NUMBER,
          P_awt_group_id          IN NUMBER,
          P_exchange_rate         IN NUMBER,
          P_base_curr_code        IN VARCHAR2,
          P_tax_name              IN VARCHAR2,
          withheld_amt            IN NUMBER,
          Proration_base_divisor  IN NUMBER)
    IS
    SELECT (aid.amount * Withheld_amt / proration_divisor) prorated_awt_amt,
           (NVL(aid.base_amount,amount) * Withheld_amt/ proration_base_divisor) prorated_base_awt_amt,
            invoice_distribution_id, line_type_lookup_code, related_id
      FROM ap_invoice_distributions  AID
     WHERE aid.invoice_id             = p_invoice_id
       --Bug 7217385 modified the below line
       --AND aid.line_type_lookup_code  NOT IN ('AWT','PREPAY')
         AND aid.line_type_lookup_code <> 'AWT'
         AND nvl(aid.reversal_flag,'N') <>'Y' --Bug 8731982
       --Bug6660355
       AND ((    aid.awt_group_id      IS NOT NULL
            AND aid.awt_group_id      = p_awt_group_id)
            OR
           ( aid.pay_awt_group_id      IS NOT NULL
            AND aid.pay_awt_group_id      = p_awt_group_id));


    rec_prorate_awt_lines       c_prorate_awt_lines%ROWTYPE;

    l_total_pro_withheld_amt           NUMBER := 0;
    l_total_base_pro_withheld_amt      NUMBER := 0;
    l_prorated_withheld_amt            NUMBER;
    l_prorated_base_withheld_amt       NUMBER;
    l_round_withheld_amt               NUMBER;
    l_round_base_withheld_amt          NUMBER;

  BEGIN

    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.<-Insert_Temp_Distribution' ||
                                 P_Calling_Sequence;


    /* Bug 4743558. We need to populate the g_org_id in this procedure since this
       procedure is called by JG directly and in such cases the g_org_id is not
       populated causing security policy violation error */

    IF g_org_id IS NULL THEN

       SELECT org_id
       INTO   g_org_id
       FROM   AP_Invoices
       WHERE  Invoice_ID = InvoiceId;

    END IF;


    /* bug3589682  we always pass withheld amt in base currency code only
    Values passed to CurrCode and BaseCurrCode  is always base currency code
    convertion is not required. Hence delete the if condition below */
/* Bug 4721994  commented the below code as rounding should be done after prorating the awt amount*/
--      base_WT_amount := Ap_Utilities_Pkg.ap_round_currency(WithheldAmount,BaseCurrCode);                                  -- R11: Xcurr

        base_WT_amount := WithheldAmount;    --Bug 4721994


    Withheld_Amt := WithheldAmount;

    IF Ap_Extended_Withholding_Pkg.Ap_Extended_Withholding_Active  THEN

      AP_CUSTOM_WITHHOLDING_PKG.Ap_Special_Withheld_Amt (
          Withheld_Amt,
          base_WT_amount,
          CurrCode,
          BaseCurrCode,
          Invoice_exchange_rate,
          TaxName,
          P_Calling_Sequence );
    END IF;

    IF (NOT Ap_ExtENDed_Withholding_Pkg.Ap_ExtENDed_Withholding_Active)  THEN

       SELECT SUM(NVL(AID.amount,0)),
              SUM(NVL(NVL(AID.base_amount,aid.amount),0))
         INTO l_proration_divisor,
              l_proration_base_divisor
         FROM ap_invoice_distributions AID
        WHERE aid.invoice_id              = Invoiceid
        --Bug 7217385 modified the below line
        --AND aid.line_type_lookup_code  NOT IN ('AWT','PREPAY')
          AND aid.line_type_lookup_code <> 'AWT'
          --Bug6660355
          AND ((     aid.awt_group_id      IS NOT NULL
               AND  aid.awt_group_id      = groupid)
              OR
                (aid.pay_awt_group_id      IS NOT NULL
            AND aid.pay_awt_group_id      = groupid));

       OPEN c_prorate_awt_lines(InvoiceId,
                                l_proration_divisor,
                                groupid,
                                ExchangeRate,
                                BaseCurrCode,
                                TaxName,
                                Withheld_amt,
                                l_proration_base_divisor);

       LOOP
         FETCH c_prorate_awt_lines   INTO rec_prorate_awt_lines ;

         EXIT WHEN c_prorate_awt_lines%NOTFOUND;

         l_prorated_withheld_amt := rec_prorate_awt_lines.prorated_awt_amt;    --bug 3589682

         -- bug8879522, removed rounding on base amount
         l_prorated_base_withheld_amt := rec_prorate_awt_lines.prorated_base_awt_amt;


         l_total_pro_withheld_amt := l_total_pro_withheld_amt +
                                     l_prorated_withheld_amt;
         l_total_base_pro_withheld_amt := l_total_base_pro_withheld_amt +
                                     l_prorated_base_withheld_amt;

         -- bug8588459
         IF rec_prorate_awt_lines.line_type_lookup_code = 'ERV' THEN
           l_awt_related_id := rec_prorate_awt_lines.related_id;
         ELSE
           l_awt_related_id := rec_prorate_awt_lines.invoice_distribution_id;
         END IF;
         AP_CUSTOM_WITHHOLDING_PKG.Ap_Special_Withheld_Amt (
                   l_prorated_withheld_amt,
                   l_prorated_base_withheld_amt,
                   CurrCode,
                   BaseCurrCode,
                   Invoice_exchange_rate,
                   TaxName,
                   P_Calling_Sequence);

         debug_info := 'Insert  INTO ap_awt_temp_distributions';

         INSERT INTO ap_awt_temp_distributions_all
            (invoice_id
            ,payment_num
            ,group_id
            ,tax_name
            ,tax_code_combination_id
            ,gross_amount
            ,withholding_amount
            ,base_withholding_amount
            ,accounting_date
            ,period_name
            ,checkrun_name
            ,tax_rate_id
            ,invoice_payment_id
            ,awt_related_id
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
            ,ORG_ID /* bug 3700128. MOAC Project */
            ,checkrun_id)
            VALUES
            (InvoiceId
            ,PaymentNum
            ,GroupId
            ,TaxName
            ,CodeCombinationId
            ,GrossAmount
            ,l_prorated_withheld_amt
            ,l_prorated_base_withheld_amt
            ,AwtDate
            ,GLPeriodName
            ,CheckrunName
            ,WithheldRateId
            ,P_Invoice_Payment_Id
            ,l_awt_related_id
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
            ,g_org_id  /* Bug 3700128. MOAC Project */
            ,p_checkrun_id);

       END LOOP;

       CLOSE c_prorate_awt_lines;

       -- We need to update the last AWT_TEMP_DISTRIBUTION with any
       -- rounding difference.

       l_round_withheld_amt := withheld_amt -
                               l_total_pro_withheld_amt;

       l_round_base_withheld_amt := base_WT_amount -
                                    l_total_base_pro_withheld_amt;

       IF NVL(l_round_withheld_amt,0) <> 0 OR
          NVL(l_round_base_withheld_amt,0) <> 0 THEN

           --bug 8411621 modified the update statement  by putting nvl.

          UPDATE ap_awt_temp_distributions_all
             SET withholding_amount = (withholding_amount +
                                       l_round_withheld_amt),
                 base_withholding_amount  = (base_withholding_amount +
                                             l_round_base_withheld_amt)

            WHERE  invoice_id                     = InvoiceId
            AND  nvl(payment_num , -99)         = nvl(PaymentNum , -99)
            AND  group_id                       = GroupId
            AND  tax_name                       = TaxName
            AND  tax_code_combination_id        = CodeCombinationId
            AND  gross_amount                   = GrossAmount
            AND  withholding_amount             = l_prorated_withheld_amt
            AND  base_withholding_amount        = l_prorated_base_withheld_amt
            AND  accounting_date                = AwtDate
            AND  period_name                    = GLPeriodName
            AND  nvl(checkrun_name , '-99')     = nvl(CheckrunName , '-99')
            AND  tax_rate_id                    = WithheldRateId
            AND  nvl(invoice_payment_id , -99)  = nvl(P_Invoice_Payment_Id , -99)
            AND  nvl(checkrun_id , -99)         = nvl(p_checkrun_id , -99)
            AND  awt_related_id                 = l_awt_related_id;


       END IF;

     --bugfix:4716059
     ELSE
     /* Bug 4721994 Prorating not done here. so rounding the base_wt_amount*/
      base_WT_amount := Ap_Utilities_Pkg.ap_round_currency(WithheldAmount,BaseCurrCode);


        debug_info := 'Insert into ap_awt_temp_distributions';
        insert into ap_awt_temp_distributions_all
            (invoice_id
            ,payment_num
            ,group_id
            ,tax_name
            ,tax_code_combination_id
            ,gross_amount
            ,withholding_amount
            ,base_withholding_amount
            ,accounting_date
            ,period_name
            ,checkrun_name
            ,tax_rate_id
            ,invoice_payment_id
            ,awt_related_id             --Added Bug 6168793
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
            ,ORG_ID
            ,CHECKRUN_ID
             )
      values
            (InvoiceId
            ,PaymentNum
            ,GroupId
            ,TaxName
            ,CodeCombinationId
            ,GrossAmount
            ,Withheld_Amt
            ,base_WT_amount
            ,AwtDate
            ,GLPeriodName
            ,CheckrunName
            ,WithheldRateId
            ,P_Invoice_Payment_Id
            ,P_Awt_Related_Id           --Added Bug 6168793
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
            ,G_ORG_ID
            ,P_CHECKRUN_ID --4759533
             );


     END IF;

     IF (HandleBucket = 'Y' AND
         AwtPeriodType IS NOT NULL) THEN

        Handle_Bucket (
          AwtPeriodName,
          GrossAmount,
          WithheldAmount,
          SuppId,
          TaxName,
          CallingModule,
          LastUpdatedBy,
          LastUpdateLogin,
          ProgramApplicationId,
          ProgramId,
          RequestId,
          current_calling_sequence);
     END IF;

EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id  = '       || to_char(InvoiceId) ||
                      ', Supplier Id  = '      || to_char(SuppId) ||
                      ', Payment Num = '       || to_char(PaymentNum) ||
                      ', Group Id = '          || to_char(GroupId) ||
                      ', Tax Name  = '         || TaxName ||
                      ', CodeCombinationId = ' || to_char(CodeCombinationId));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Temp_Distribution;


PROCEDURE AP_Calculate_AWT_Amounts (
          P_Invoice_Id             IN     NUMBER,
          P_Awt_Date               IN     DATE,
          P_Calling_Module         IN     VARCHAR2,
          P_Create_Dists           IN     VARCHAR2,
          P_Amount                 IN     NUMBER,
          P_Payment_Num            IN     NUMBER,
          P_Checkrun_Name          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          P_AWT_Success            IN OUT NOCOPY VARCHAR2,
          P_Calling_Sequence       IN VARCHAR2,
          P_Invoice_Payment_Id     IN     NUMBER DEFAULT NULL,
          P_checkrun_id            in     number default null,
          p_org_id                 in     number default null) --4742265
IS
/*

   Copyright (c) 1995 by Oracle Corporation

   NAME
     AP_Calculate_AWT_Amounts - First Unit of general Ap_Do_Withholding
   DESCRIPTION
     Calculate WT amounts that will be stored in temporary distributions
   NOTES
     This PROCEDURE IS part of the AP_AWT PL/SQL package
   HISTORY                            (YY/MM/DD)
     atassoni.it                       95/04/26  Code refinements
     mhtaylor.uk atassoni.it           95/04/21  First executable version
     atassoni.it                       95/04/12  Creation

<< Beginning of AP_Calculate_AWT_Amounts program documentation >>

Flow chart of this PROCEDURE:

*--------------------------------*
| BEGIN AP_Calculate_AWT_Amounts |
*--------------------------------*
   |
   v
*----------------------------------------------------------------------------*
| Set up withholding environment:                                            |
|  - Get INVOICE basic information and supplier identification               |
|  - Get GROUP AMOUNTS and set number of GROUPS found                        |
|  - Calculate TOTAL INVOICE AMOUNT from distribution lines                  |
|  - Adjust figures for possible discount on invoice                         |
|  - Recalculate the amounts subject to WT in proportion to the payment      |
|  - Set starting group FOR WT calculation, excluding the exempt if existent |
*----------------------------------------------------------------------------*
   |
   |   *---------------------------------*
+->+-> | Loop for each withholding Group |
|      *---------------------------------*
|         |
|         v
|      *-------------------------------------------------------*
|      | Reset amount subject for tax, rank and rank cumulator |
|      *-------------------------------------------------------*
|         |
|         |   *----------------------------*
|  +----->+-> | Loop for each tax in group |
|  |          *----------------------------*
|  |             |
|  |             v
|  |          *----------------------------------------*
|  |          | Check if tax has valid characteristics |
|  |          *----------------------------------------*
|  |             |
|  |             v
|  |          *------------------------------------------------------------*
|  |          | (Re-)Calculate rank, cumulator and amount subject FOR tax  |
|  |          *------------------------------------------------------------*
|  |             |
|  |             v
|  |          *--------------------------------------*
|  |          | Check for CUSTOM withholding figures | ===> goto next tax
|  |          *--------------------------------------*      when found
|  |             |
|  |             v
|  |          *-------------------------------------------------*
|  |          | Get withholding figures FOR EXCEPTION    AND apply |
|  |          | Cut Off (VALUES could be NULL)                  |
|  |          *-------------------------------------------------*
|  |             |
|  |             v
|  |          *-----------------------------------------*
|  |       +--| Get withholding figures FOR CERTIFICATE |
|  |       |  | (VALUES could be NULL)                  |
|  |       |  *-----------------------------------------*
|  |       |
|  |       +--> Withholding Tax Rate FOR Certificate IS not NULL?
|  |
|  |            ,'`.          *--------------------------------------------*
|  |       +-- < IF > ------> | Calculate proper WT amount FOR CERTIFICATE |
|  |       |    `.,'    Yes   | applying Cut Off                           |
|  |       | No               *--------------------------------------------*
|  |       v                             |
|  |    *----------------------------*   |    *----------------------------*
|  |    |   Set to NULL the WT       |   +--> | Confirm WT Rate    AND Amount |
|  |    |   amount FOR CERTIFICATE   |        | (the greater between       |
|  |    *----------------------------*        | CertIFicate    AND Exception) |
|  |       |                                  *----------------------------*
|  |       v                                                            |
|  |    *----------------------------*                                  |
|  |    |         SAVEPOINT          |                                  |
|  |    |         ~~~~~~~~~          |                                  |
|  |    |  BEFORE the AMOUNT RANGES  |                                  |
|  |    |    have been processed     |                                  |
|  |    *----------------------------*                                  |
|  |       |                                                            |
|  |       v                                                            |
|  |    *-----------------------------*                                 |
|  |    | Get withholding figures FOR |                                 |
|  |    | AMOUNT RANGES, manipulating |                                 |
|  |    | the database IF necessary   |                                 v
|  |    *-----------------------------*      *-------------------------------*
|  |       |                                 | Insert Temporary Distribution |
|  |       |                                 |    AND Update Bucket             |
|  |       +--> Were RANGES applicable?      *-------------------------------*
|  |                                                                    |
|  |            ,'`.                                                    |
|  |      +--- < IF > -----------+                                      |
|  |      | No  `.,'    Yes      |                                      |
|  |      |                      v                                      |
|  |      v                 *------------------------------------*      |
|  |  *------------------*  | Single amounts withheld on RANGES  |      |
|  |  | Calculate amount |  | have already been INSERTed as tem- |      |
|  |  | withheld in the  |  | porary distributions, with bucket, |      |
|  |  | normal case,     |  | while getting withholding figures  |      |
|  |  | round    AND apply  |  | FOR ranges (two steps above)       |      |
|  |  | CUT OFF          |  *------------------------------------*      |
|  |  *------------------*     |                                        |
|  |      |                    +--> WT Amount withheld FOR Ranges       |
|  |      v                         IS less THEN                        |
|  |  *------------------*          WT Amount withheld FOR Exception?   |
|  |  | Confirm WT Rate  |                                              |
|  |  |    AND Amount (the  |          ,'`.       *---------------------*  |
|  |  | greater between  |         < IF > ---> | Undo changes due to |  |
|  |  | Normal    AND Ex-   |          `.,'  Yes  | ranges (rollback to |  |
|  |  | ception)         |           |         | the savepoint)      |  |
|  |  *------------------*           | No      *---------------------*  |
|  |      |                          |            |                     |
|  |      |                          |            v                     |
|  |      v                          |         *---------------------*  |
|  |  *------------------*           |         | Insert Temporary    |  |
|  |  | Insert Temporary |           |         | Distribution with   |  |
|  |  | Distribution    AND |           |         | EXCEPTION data THEN |  |
|  |  | Update Bucket    |           |         | Update Bucket       |  |
|  |  *------------------*           |         *---------------------*  |
|  |      |                          |            |                     |
|  |      |                          |            v                     |
|  |      |                          +----------->+                     |
|  |      |                                       |                     |
|  |      +<--------------------------------------+<--------------------+
|  |      |
|  |      +--> Is there another Tax in this Group?
|  |
|  |           ,'`.
|  |   Yes   ,'    `.
|  +------- <End Loop>
|            `.    ,'
|              `.,'
|            No |
|               +--> Is there another Withholding Group FOR this invoice?
|
|                   ,'`.
|           Yes   ,'    `.
+--------------- <End Loop>
                  `.    ,'
                    `.,'
                  No |
                     v
       *------------------------------*
       | END AP_Calculate_AWT_Amounts |
       *------------------------------*


<< End of AP_Calculate_AWT_Amounts program documentation >>

*/

  -- PL/SQL Main Block Constants    AND Variables:

  currency_code                  ap_invoices.invoice_currency_code%TYPE;
  payment_currency_code          ap_invoices.payment_currency_code%TYPE;
  payment_cross_rate             ap_invoices.payment_cross_rate%TYPE;
  FUNCTIONal_currency            ap_system_parameters.base_currency_code%TYPE;
  invoice_exchange_rate          ap_invoices.exchange_rate%TYPE;
  invoice_number                 ap_invoices.invoice_num%TYPE;
  supplier_id                    ap_invoices.vendor_id%TYPE;
  supplier_site_id               ap_invoices.vendor_site_id%TYPE;
  NUMBER_of_awt_groups           integer := 0;
  gl_period_name                 ap_invoice_distributions.period_name%TYPE;
  gl_awt_date                    DATE;

  max_gl_dist_date               DATE;   /* Added for bug#6605368 */
  max_gl_date_period             gl_period_statuses.period_name%TYPE;  /* Added for bug#6605368 */

  -- Invalid Situations Variables
  invalid_group                  ap_awt_groups.group_id%TYPE;
  invalid_tax                    ap_tax_codes.name%TYPE;

  -- PL/SQL debugging/logging Objects:

  DBG_Loc                        VARCHAR2(30)  := 'AP_Calculate_AWT_Amounts';

  -- see also PROCEDURE 'Log' below
  current_calling_sequence       VARCHAR2(2000);
  debug_info                     VARCHAR2(100);

  -- PL/SQL Main Block Exceptions:

  NOT_AN_OPEN_GL_PERIOD          EXCEPTION;
  ONE_TAX_MISSING_PERIOD         EXCEPTION;
  ONE_INVALID_GROUP              EXCEPTION;
  ONE_INVALID_TAX                EXCEPTION;
  ONE_INVALID_TAX_ACCOUNT        EXCEPTION;
  NO_VALID_TAX_RATES             EXCEPTION;
  INVALID_RANGE_DATES            EXCEPTION;
  INVALID_RANGE                  EXCEPTION;
  ALL_GROUPS_ZERO                EXCEPTION;
  INV_CURR_MUST_BE_BASE          EXCEPTION;

  -- PL/SQL Main Block Tables:

  TYPE Group_Id_TabTyp IS
       TABLE OF ap_awt_groups.group_id%TYPE
       INDEX BY binary_integer;
  tab_group_id Group_Id_TabTyp;

  TYPE Amount_By_Group_TabTyp IS
       TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
  tab_amount_by_group Amount_By_Group_TabTyp;

  TYPE Vat_By_Group_TabTyp IS
       TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
  tab_vat_by_group Vat_By_Group_TabTyp;

  /* Added for bug6605368 Start */
  /* Declaring Table types for Gldate and GL period. These table will */
  /* store the maximum of the GL date and the GL period for that date */
  /* present on the item/tax lines per withholding tax group : bug6605368 */

  /*type for the max gl date period*/
  TYPE Max_gl_date_TabTyp IS
       TABLE OF DATE INDEX BY BINARY_INTEGER;

  tab_max_gl_date Max_gl_date_TabTyp;

  /*type for the max gl date period*/
  TYPE Max_gl_period_TabTyp IS
       TABLE OF gl_period_statuses.period_name%TYPE INDEX BY binary_integer;

  tab_max_gl_period Max_gl_period_TabTyp;

  /* Added for bug6605368 End */

  -- PL/SQL Main Block CURSORs    AND records:
  -- Not Defined

  -- AP_Calculate_AWT_Amounts:
  -- PL/SQL Main Block PROCEDUREs    AND FUNCTIONs:

  FUNCTION Proportional_Amount (
           Amount        IN NUMBER,
           Numerator     IN NUMBER,
           Denominator   IN NUMBER,
           CurrCode      IN VARCHAR2,
           P_Calling_Sequence IN VARCHAR2)
  RETURN NUMBER
  IS
    proportional_value NUMBER;
    current_calling_sequence     VARCHAR2(2000);
    debug_info                   VARCHAR2(100);
  BEGIN
    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Proportional_Amount<-' ||
                                 P_Calling_Sequence;

   proportional_value := Amount; -- Bug7043937

   if Denominator <> 0 then    -- Bug7043937

     proportional_value := (Amount * (Numerator / Denominator));

   end if;

    -- proportional_value := Ap_Utilities_Pkg.Ap_Round_Currency
    --                      (Amount * (Numerator / Denominator) ,CurrCode);
    RETURN(proportional_value);
  END Proportional_Amount;

  FUNCTION Get_Group_Name (
           GroupId            IN NUMBER,
           P_Calling_Sequence IN VARCHAR2)
  RETURN VARCHAR2
  IS
  CURSOR c_group_name IS
  SELECT name
    FROM   ap_awt_groups
   WHERE (group_id = GroupId);

   group_name ap_awt_groups.name%TYPE;
   current_calling_sequence     VARCHAR2(2000);
   debug_info                   VARCHAR2(100);
  BEGIN
    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Get_Group_Name<-' ||
                              P_Calling_Sequence;
    debug_info := 'Open CURSOR c_group_name';
    OPEN  c_group_name;

    debug_info := 'Fetch CURSOR c_group_name';
    FETCH c_group_name   INTO group_name;
    debug_info := 'Close CURSOR c_group_name';

    CLOSE c_group_name;
    RETURN(group_name);
  EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      'Group_Id  = ' || to_char(GroupId));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
  END Get_Group_Name;

  FUNCTION GL_Account_INVALID (
           CodeCombinationId  IN NUMBER,
           AccountingDate     IN DATE,
           P_Calling_Sequence IN VARCHAR2)
  RETURN BOOLEAN
  IS
  CURSOR c_test_acct_id IS
  SELECT detail_posting_allowed_flag,
         start_date_active,
         end_date_active,
         template_id,
         enabled_flag,
         summary_flag
    FROM gl_code_combinations
   WHERE CodeCombinationId = code_combination_id;

    rec_test_acct_id             c_test_acct_id%ROWTYPE;
    acct_invalid                 BOOLEAN := FALSE;
    current_calling_sequence     VARCHAR2(2000);
    debug_info                   VARCHAR2(100);
  BEGIN
    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.GL_Account_INVALID<-' ||
                              P_Calling_Sequence;

    debug_info := 'Open CURSOR c_test_acct_id';
    OPEN  c_test_acct_id;

    debug_info := 'Fetch CURSOR c_test_acct_id';
    FETCH c_test_acct_id   INTO rec_test_acct_id;

    IF (
        (c_test_acct_id%NOTFOUND)
       OR
        (rec_test_acct_id.detail_posting_allowed_flag = 'N')
       OR
        (rec_test_acct_id.start_date_active > AccountingDate)
       OR
        (rec_test_acct_id.end_date_active  <= AccountingDate)
       OR
        (rec_test_acct_id.template_id IS not NULL)
       OR
        (rec_test_acct_id.enabled_flag <> 'Y')
       OR
        (rec_test_acct_id.summary_flag <> 'N')
       ) THEN
      acct_invalid := TRUE;
    END IF;

    debug_info := 'Close CURSOR c_test_acct_id';
    CLOSE c_test_acct_id;
    RETURN(acct_invalid);

  EXCEPTION
  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Code Combination Id  = ' || to_char(CodeCombinationId) ||
                      ', Accounting Date  = ' || to_char(AccountingDate));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
  END GL_Account_INVALID;

  PROCEDURE Get_Withholding_On_Exception (
           InvNum                IN  VARCHAR2,
           TaxName               IN  VARCHAR2,
           AmtSubject            IN  NUMBER,
           CurrCode              IN  VARCHAR2,
           OpDate                IN  DATE,
           SuppId                IN  NUMBER,
           SuppSiteId            IN  NUMBER,
           Rate                  OUT NOCOPY NUMBER,
           RateId                OUT NOCOPY NUMBER,
           Amount                OUT NOCOPY NUMBER,
           ExceptionRateNOTFOUND OUT NOCOPY BOOLEAN,
           P_Calling_Sequence    IN  VARCHAR2)
  IS
    amt     NUMBER;
    rt      ap_awt_tax_rates.tax_rate%TYPE;
    CURSOR  c_exception_rate IS
    SELECT  tax_rate,
            tax_rate_id
      FROM  ap_awt_tax_rates
     WHERE  invoice_num          = InvNum
       AND  vendor_id            = SuppId
       AND  vendor_site_id       = SuppSiteId
       AND  tax_name             = TaxName
       AND  OpDate  BETWEEN NVL(start_date, OpDate - 1)
                        AND NVL(end_date, OpDate + 1)
       AND  rate_type            = 'EXCEPTION'
       AND  org_id               = g_org_id;    -- bug 7301484

    DBG_Loc                      VARCHAR2(30) := 'Get_Withholding_On_Exception';
    current_calling_sequence     VARCHAR2(2000);
    debug_info                   VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Get_Withholding_On_Exception<-' ||
                                 P_Calling_Sequence;

    debug_info := 'Open CURSOR c_EXCEPTION_rate';
    OPEN  c_EXCEPTION_rate;

    debug_info := 'Fetch CURSOR c_EXCEPTION_rate';
    FETCH c_EXCEPTION_rate   INTO rt, RateId;

    ExceptionRateNOTFOUND := c_EXCEPTION_rate%NOTFOUND;
    IF c_EXCEPTION_rate%NOTFOUND THEN
      Rate   := NULL;
      RateId := NULL;
      Amount := NULL;
    ELSE
      Rate   := rt;
      amt    := AmtSubject * (rt / 100);
      Amount := amt;
    END IF;

    debug_info := 'Close CURSOR c_EXCEPTION_rate';
    CLOSE c_EXCEPTION_rate;

  EXCEPTION
    WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Num  = ' || InvNum ||
                      ', Tax Name  = '    || TaxName ||
                      ', Amt Subject = '  || to_char(AmtSubject) ||
                      ', Curr Code = '    || CurrCode ||
                      ', Op Date = '      || to_char(OpDate)  ||
                      ', Supp Id = '      || to_char(SuppId) ||
                      ', Supp Site Id = ' || to_char(SuppSiteId));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Withholding_On_Exception;

  PROCEDURE Get_Normal_Withholding(
          TaxName            IN  VARCHAR2,
          AmtSubject         IN  NUMBER,
          CurrCode           IN  VARCHAR2,
          OpDate             IN  DATE,
          Rate               OUT NOCOPY NUMBER,
          RateId             OUT NOCOPY NUMBER,
          Amount             OUT NOCOPY NUMBER,
          NormalRateNOTFOUND OUT NOCOPY BOOLEAN,
          P_Calling_Sequence IN  VARCHAR2)
  IS
    amt     NUMBER;
    rt      ap_awt_tax_rates.tax_rate%TYPE;

    CURSOR c_normal_rate
    IS
    SELECT tax_rate,
           tax_rate_id
      FROM ap_awt_tax_rates
     WHERE tax_name       = TaxName
       AND OpDate         BETWEEN NVL(start_date, OpDate - 1)
                          AND     NVL(end_date, OpDate + 1)
       AND rate_type      = 'STANDARD'
       AND org_id         = g_org_id;    -- bug 7301484

    DBG_Loc      VARCHAR2(30) := 'Get_Normal_Withholding';
    current_calling_sequence     VARCHAR2(2000);
    debug_info                   VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Get_Normal_Withholding<-' ||
                                 P_Calling_Sequence;

    debug_info := 'Open CURSOR c_normal_rate';
    OPEN  c_normal_rate;

    debug_info := 'Fetch CURSOR c_normal_rate';
    FETCH c_normal_rate   INTO rt, RateId;

    NormalRateNOTFOUND := c_normal_rate%NOTFOUND;

    IF c_normal_rate%NOTFOUND THEN
      Rate   := NULL;
      RateId := NULL;
      Amount := NULL;
    ELSE
      Rate   := rt;
      amt    := AmtSubject * (rt / 100);

      -- amt    := Ap_Utilities_Pkg.Ap_Round_Currency(amt, CurrCode);
      Amount := amt;

    END IF;
    debug_info := 'Close CURSOR c_normal_rate';
    CLOSE c_normal_rate;

  EXCEPTION
    WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Tax Name  = '       || TaxName ||
                      ', Amount Subject  = ' || to_char(AmtSubject) ||
                      ', Currency Code = ' || CurrCode ||
                      ', Op Date  = '       || to_char(OpDate));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
  END Get_Normal_Withholding;

  PROCEDURE Get_Withholding_On_Certificate (
          TaxName          IN  VARCHAR2,
          AmtSubject       IN  NUMBER,
          CurrCode         IN  VARCHAR2,
          OpDate           IN  DATE,
          SuppId           IN  NUMBER,
          SuppSiteId       IN  NUMBER,
          Rate             OUT NOCOPY NUMBER,
          RateId           OUT NOCOPY NUMBER,
          Amount           OUT NOCOPY NUMBER,
          CertRateNOTFOUND OUT NOCOPY BOOLEAN,
          P_Calling_Sequence IN VARCHAR2)
  IS
    amt     NUMBER;
    rt      ap_awt_tax_rates.tax_rate%TYPE;
    CURSOR c_certificate_rate
    IS
    SELECT tax_rate,
           tax_rate_id
      FROM ap_awt_tax_rates
     WHERE tax_name             = TaxName
       AND vendor_id            = SuppId
       AND vendor_site_id       = SuppSiteId
       AND OpDate         BETWEEN NVL(start_date, OpDate - 1)
                          AND     NVL(end_date, OpDate + 1)
       AND rate_type            = 'CERTIFICATE'
       AND org_id               = g_org_id    -- bug 730148
   ORDER BY     priority ASC;

    DBG_Loc      VARCHAR2(30) := 'Get_Withholding_On_Certificate';
    current_calling_sequence     VARCHAR2(2000);
    debug_info                   VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Get_Withholding_On_Certificate<-' ||
                                 P_Calling_Sequence;

    debug_info := 'Open CURSOR c_certificate_rate';
    OPEN  c_certificate_rate;

    debug_info := 'Fetch CURSOR c_certificate_rate';
    FETCH c_certificate_rate   INTO rt, RateId;

    CertRateNOTFOUND := c_certificate_rate%NOTFOUND;

    IF c_certificate_rate%NOTFOUND THEN
      Rate   := NULL;
      RateId := NULL;
      Amount := NULL;
    ELSE
      Rate   := rt;
      amt    := AmtSubject * (rt / 100);
      Amount := amt;
    END IF;

    debug_info := 'Close CURSOR c_certificate_rate';
    CLOSE c_certificate_rate;

  EXCEPTION
    WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Tax Name  = '       || TaxName ||
                      ', Amount Subject  = ' || to_char(AmtSubject) ||
                      ', Currency Code = ' || CurrCode ||
                      ', Op Date  = '       || to_char(OpDate) ||
                      ', Supplier Id = '    || to_char(SuppId) ||
                      ', Supp Site Id = '   || to_char(SuppSiteId) );

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Withholding_On_Certificate;

  /* Added for bug#6605368 */
  /* Added the parameter GlDate which would be used for stamping the GL date on the AWT dists */
  /* New parameter is required since the DATE Opdate is only meant for the AWT calculations */

  PROCEDURE Get_Withholding_On_Ranges (
          GroupId              IN  NUMBER,
          TaxName              IN  VARCHAR2,
          CodeCombinationId    IN  NUMBER,
          GLPeriodName         IN  VARCHAR2,
          AwtPeriodName        IN  VARCHAR2,
          AwtPeriodType        IN  VARCHAR2,
          PeriodLimit          IN  NUMBER,
          InvoiceId            IN  NUMBER,
          PaymentNum           IN  NUMBER,
          AmtSubject           IN  NUMBER,
          ExchangeRate         IN  NUMBER,
          CurrCode             IN  VARCHAR2,
          BaseCurrCode         IN  VARCHAR2,
          OpDate               IN  DATE,
          GlDate               IN  DATE,   /* Added for bug#6605368 */
          SuppId               IN  NUMBER,
          SuppSiteId           IN  NUMBER,
          AmountBasis          IN  VARCHAR2,
          PeriodBasis          IN  VARCHAR2,
          CheckrunName         IN  VARCHAR2,
          LastUpdatedBy        IN  NUMBER,
          LastUpdateLogin      IN  NUMBER,
          ProgramApplicationId IN  NUMBER,
          ProgramId            IN  NUMBER,
          RequestId            IN  NUMBER,
          CallingModule        IN  VARCHAR2,
          RangesWTAmount       OUT NOCOPY NUMBER,
          RangesNumber         OUT NOCOPY NUMBER,
          RangesRateNOTFOUND   OUT NOCOPY BOOLEAN,
          RangesINVALID        OUT NOCOPY BOOLEAN,
          RangesDatesINVALID   OUT NOCOPY BOOLEAN,
          P_Calling_Sequence   IN VARCHAR2,
          P_Invoice_Payment_Id IN NUMBER DEFAULT NULL,
          auto_offset_segs     IN VARCHAR2,
          cert_withholding_rate    IN NUMBER,
          cert_withholding_rate_id IN NUMBER,
          p_checkrun_id            in number default null)
  IS
    -- This PROCEDURE also INSERTs temporary distribution lines due
    -- to the ranges    AND triggers the corresponding bucket INSERT OR
    -- UPDATE.

    DBG_Loc                   VARCHAR2(30)      := 'Get_Withholding_On_Ranges';
    current_calling_sequence  VARCHAR2(2000);
    debug_info                VARCHAR2(100);
    amt                       NUMBER            := 0;
    nr                        NUMBER            := 0;
    DO_HANDLE_BUCKET          CONSTANT CHAR(1)  := 'Y';

    TYPE Start_Amount_TabTyp IS
         TABLE OF ap_awt_tax_rates.start_amount%TYPE
         INDEX BY BINARY_INTEGER;
    tab_start_amount Start_Amount_TabTyp;

    TYPE End_Amount_TabTyp IS
         TABLE OF ap_awt_tax_rates.end_amount%TYPE
         INDEX BY BINARY_INTEGER;
    tab_end_amount End_Amount_TabTyp;

    TYPE Tax_Rate_TabTyp IS
         TABLE OF ap_awt_tax_rates.tax_rate%TYPE
         INDEX BY BINARY_INTEGER;
    tab_tax_rate Tax_Rate_TabTyp;

    TYPE Tax_Rate_Id_TabTyp IS
         TABLE OF ap_awt_tax_rates.tax_rate_id%TYPE
         INDEX BY BINARY_INTEGER;
    tab_tax_rate_id Tax_Rate_Id_TabTyp;

    CURSOR c_amount_ranges (
          TaxCode  IN VARCHAR2,
          OpDate IN DATE)
    IS
    SELECT tax_rate
    ,      tax_rate_id
    ,      start_amount
    ,      end_amount
    ,      NVL(start_date, OpDate - 1) start_date
    ,      NVL(end_date,   OpDate + 1) end_date
      FROM  ap_awt_tax_rates
     WHERE  tax_name        = TaxCode
       AND  rate_type       = 'STANDARD'
       AND  OpDate         BETWEEN NVL(start_date, OpDate - 1)
                           AND     NVL(end_date, OpDate + 1)
       AND  org_id          = g_org_id    -- bug 7301484
   ORDER BY     start_amount asc;

    rec_amount_ranges c_amount_ranges%ROWTYPE;

    -- Start assuming DATEs in ranges    AND the ranges are valid
    invalid_range_dates   BOOLEAN := FALSE;
    invalid_ranges        BOOLEAN := FALSE;

    NO_RANGES             EXCEPTION;
    WRONG_CURRENCY        EXCEPTION;

  BEGIN
    current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.Get_Withholding_On_Ranges<-' ||
                                 P_Calling_Sequence;

    debug_info := 'Open CURSOR c_amount_ranges';
    OPEN  c_amount_ranges (TaxName, OpDate);

    <<Count_Ranges>>
    DECLARE
      i        binary_integer := 1;
      DateFrom DATE;
      DateTo   DATE;
      DBG_Loc  VARCHAR2(30) := 'Count_Ranges';
    BEGIN
      LOOP
        debug_info := 'Fetch CURSOR c_amount_ranges';
        FETCH c_amount_ranges   INTO rec_amount_ranges;
        EXIT WHEN c_amount_ranges%NOTFOUND OR
                  c_amount_ranges%NOTFOUND IS NULL;
        IF (i = 1) THEN
          DateFrom := rec_amount_ranges.start_date;
          DateTo   := rec_amount_ranges.end_date;
          IF (rec_amount_ranges.start_amount <> 0) THEN
            invalid_ranges := TRUE; -- First range must start from zero.
          END IF;
        ELSIF (
               (DateFrom <> rec_amount_ranges.start_date)
              OR
               (DateTo   <> rec_amount_ranges.end_date)
              ) THEN
           invalid_range_dates := TRUE; -- Selected ranges MUST have identical
                                        -- effectivity DATEs.
        ELSIF
             (rec_amount_ranges.start_amount <> tab_end_amount(i-1)) THEN
           invalid_ranges := TRUE;
        END IF;

        IF (NVL(cert_withholding_rate,0) <> 0)    AND
           (rec_amount_ranges.tax_rate > cert_withholding_rate) THEN

          tab_tax_rate(i)     := cert_withholding_rate;
          tab_tax_rate_id(i)  := cert_withholding_rate_id;
          tab_start_amount(i) := rec_amount_ranges.start_amount;
          tab_end_amount(i)   := rec_amount_ranges.end_amount;

        ELSE

          tab_tax_rate(i)     := rec_amount_ranges.tax_rate;
          tab_tax_rate_id(i)  := rec_amount_ranges.tax_rate_id;
          tab_start_amount(i) := rec_amount_ranges.start_amount;
          tab_end_amount(i)   := rec_amount_ranges.end_amount;

        END IF;
        nr := c_amount_ranges%ROWCOUNT;
        i  := nr + 1;
      END LOOP;

       IF nr>0 THEN
          rollback to BEFORE_CERTIFICATE;
       END IF;

      IF tab_end_amount(nr) IS not NULL THEN
        invalid_ranges := TRUE;
      END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        invalid_ranges := TRUE;

  END Count_Ranges;

  debug_info := 'Close CURSOR c_amount_ranges';
  CLOSE c_amount_ranges;

  RangesRateNOTFOUND := FALSE;
  RangesINVALID := invalid_ranges;
  RangesDatesINVALID := invalid_range_dates;
  IF (
        (invalid_ranges)
       OR
        (invalid_range_dates)
       ) THEN
    RAISE NO_RANGES;
  END IF;

  IF (currency_code <> FUNCTIONal_currency) THEN
    RAISE WRONG_CURRENCY;
  END IF;

  -- Check IF amount basis IS WITHHELD
  IF (AmountBasis = 'WITHHELD') THEN
      -- Example:
      --
      -- The following ranges expressed in WT:
      --
      --           Got at
      -- WT Ranges   Rate
      -- --------- ------
      --   0 - 100    10%
      -- 100 - 200    20%
      -- 200 - 500    25%
      -- 500 +        30%
      --
      -- will be transformed in the equivalent:
      --
      -- Subjected
      -- Amt.Ranges    Rate
      -- -----------  -----
      --    0 - 1000    10%
      -- 1000 - 1500    20%
      -- 1500 - 2700    25%
      -- 2700 +         30%
      --
      -- The next upper limit IS calculated by adding the result of the
      -- ratio (wt_range_width / rate) to the lower range limit. The
      -- next lower range limit IS substituted by the previous upper
      -- range limit.
      --
      <<Amount_Basis_Is_Withheld>>
      DECLARE
        DBG_Loc          VARCHAR2(30) := 'Amount_Basis_Is_Withheld';
        range_width      NUMBER;
        new_start_amount NUMBER := 0;
        new_end_amount   NUMBER;
      BEGIN
        FOR j in 1..nr LOOP
          range_width           := tab_end_amount(j) -
                                   tab_start_amount(j);
          tab_start_amount(j)   := new_start_amount;
          new_end_amount        := tab_start_amount(j) +
                                  (range_width * 100 /
                                                 tab_tax_rate(j));
          tab_end_amount(j)     := Ap_Utilities_Pkg.Ap_Round_Currency
                                   (new_end_amount ,CurrCode);
          new_start_amount      := tab_end_amount(j);

        END LOOP;
      END Amount_Basis_Is_Withheld;
    END IF;  -- Whether the amount basis was WITHHELD

    -- Check IF period basis IS PERIOD
    IF (PeriodBasis = 'PERIOD') THEN

      -- If the range basis IS PERIOD, each amount range limit IS to
      -- be decreased by the amount already withheld. This could cause
      -- vacuum ranges that will be skipped.

      <<Period_Basis_Is_Period>>
      DECLARE
        CURSOR c_gross_amount_to_date IS
        SELECT gross_amount_to_date
          FROM   ap_awt_buckets
         WHERE  (period_name = AwtPeriodName)
           AND    (tax_name    = TaxName)
           AND    (vendor_id   = SuppId);
        gross_amount_to_date ap_awt_buckets.gross_amount_to_date%TYPE;
        new_number_of_ranges NUMBER         := 0;
        i                    binary_integer := 1;
        DBG_Loc              VARCHAR2(30)   := 'Period_Basis_Is_Period';
      BEGIN
        debug_info := 'Open CURSOR c_gross_amount_to_date';
        OPEN  c_gross_amount_to_date;

        debug_info := 'Fetch CURSOR c_gross_amount_to_date';
        FETCH c_gross_amount_to_date   INTO gross_amount_to_date;

        IF c_gross_amount_to_date%NOTFOUND THEN
          gross_amount_to_date := 0;
        END IF;

        debug_info := 'Close CURSOR c_gross_amount_to_date';
        CLOSE c_gross_amount_to_date;

        FOR j in 1..nr LOOP
          tab_start_amount(i) := tab_start_amount(j) -
                                 gross_amount_to_date;
          IF (tab_start_amount(i) < 0) THEN
            tab_start_amount(i) := 0;
          END IF;
          tab_end_amount(i) := tab_end_amount(j) -
                               gross_amount_to_date;
          IF (tab_end_amount(i) < 0) THEN
            tab_end_amount(i) := 0;
          END IF;
          tab_tax_rate(i)    := tab_tax_rate(j);
          tab_tax_rate_id(i) := tab_tax_rate_id(j);
          IF (
              (tab_end_amount(i) > 0)
             OR
              (tab_end_amount(i) IS NULL)
             ) THEN

            new_number_of_ranges := i;
            i := i + 1;
          END IF;
        END LOOP;
        nr := new_number_of_ranges;
      END Period_Basis_Is_Period;
    END IF; -- Whether the period basis was PERIOD

    -- Loop on the ranges
    -- ==================

    <<Processing_Ranges>>
    DECLARE
      amount_subject_for_ranges      NUMBER;
      range_width                    NUMBER;
      current_amount_to_withhold     NUMBER;
      current_amount_withheld        NUMBER;
      DBG_Loc                        VARCHAR2(30) := 'Processing_Ranges';
    BEGIN

      amount_subject_for_ranges := Abs(AmtSubject);
      <<FOR_EACH_RANGE>>
      FOR k in 1..nr LOOP
        range_width           := tab_end_amount(k) -
                                 tab_start_amount(k);
        IF (amount_subject_for_ranges > range_width) THEN
          current_amount_to_withhold := range_width;
          amount_subject_for_ranges  := amount_subject_for_ranges -
                                        range_width;
        ELSE
          current_amount_to_withhold := amount_subject_for_ranges;
          amount_subject_for_ranges  := 0;
        END IF;
        current_amount_withheld := (current_amount_to_withhold / 100) *
                                   tab_tax_rate(k);
        current_amount_withheld := Ap_Utilities_Pkg.Ap_Round_Currency
                                   (current_amount_withheld ,CurrCode);

        -- Apply Cut Off to this amount:
        current_amount_withheld := Do_AWT_Cut_Off (
                  OpDate,
                  current_amount_to_withhold,
                  current_amount_withheld,
                  SuppId,
                  TaxName,
                  AwtPeriodName,
                  PeriodLimit,
                  current_calling_sequence);

        IF (Amtsubject < 0) THEN
                amt := amt - current_amount_withheld;
        ELSE
                amt := amt + current_amount_withheld;
        END IF;

        IF (Amtsubject < 0) THEN
           current_amount_withheld := (-1) * current_amount_withheld;
        -- Start of code fix for the bug 5236191 by suchhabr
           current_amount_to_withhold := (-1) * current_amount_to_withhold;
        -- End of code fix for the bug 5236191 by suchhabr
        END IF;


        -- Insert the temporary distribution line for this amount withheld:
        IF (current_amount_withheld <> 0OR tab_tax_rate(k) = 0) THEN

          Insert_Temp_Distribution (
                    InvoiceId,
                    SuppId,
                    PaymentNum,
                    GroupId,
                    TaxName,
                    CodeCombinationId,
                    current_amount_to_withhold,
                    current_amount_withheld,
                    GlDate,             /* Changed OpDate with GlDate for bug#6605368 */
                    GLPeriodName,
                    AwtPeriodType,
                    AwtPeriodName,
                    CheckrunName,
                    tab_tax_rate_id(k),
                    ExchangeRate,
                    CurrCode,
                    BaseCurrCode,
                    NULL,
                    current_calling_sequence,
                    DO_HANDLE_BUCKET,
                    LastUpdatedBy,
                    LastUpdateLogin,
                    ProgramApplicationId,
                    ProgramId,
                    RequestId,
                    CallingModule,
                    P_Invoice_Payment_Id,
                    p_checkrun_id => p_checkrun_id);
        END IF;
      END LOOP FOR_EACH_RANGE;

      -- Set the OUT arguments:
      RangesNumber   := nr;
      RangesWTAmount := amt;

    END Processing_Ranges;
  EXCEPTION
    WHEN NO_RANGES THEN
      -- Simply RETURN RangesNumber    AND RangesWTAmount both    SET to ZERO
      RangesNumber       := 0;
      RangesWTAmount     := 0;
      -- Return boolean notfound test    SET to TRUE, too:
      RangesRateNOTFOUND := TRUE;

    WHEN WRONG_CURRENCY THEN
      RangesNumber       := nr;
      RangesWTAmount     := 0;

    WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  GroupId  = '       || to_char(GroupId) ||
                      ', Tax Name  = '       || TaxName ||
                      ', CodeCombinationId = ' || to_char(CodeCombinationId) ||
                      ', GLPeriodName  = '       || GLPeriodName ||
                      ', AwtPeriodName  = '       || AwtPeriodName ||
                      ', AwtPeriodType = '       || AwtPeriodType ||
                      ', PeriodLimit = ' || to_char(PeriodLimit) ||
                      ', InvoiceId = ' || to_char(InvoiceId) ||
                      ', PaymentNum = ' || to_char(PaymentNum) ||
                      ', AmtSubject = ' || to_char(AmtSubject) ||
                      ', ExchangeRate = ' || to_char(ExchangeRate));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Withholding_On_Ranges;

  --            _______
  --           |       |
  --           |       |
  --           |       |
  --  _________|       |_________
  --  \                         /
  --   \ Calculate_AWT_Amounts /
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

  current_calling_sequence := 'AP_CALC_WITHHOLDING_PKG.AP_Calculate_AWT_Amounts<-' ||
                               P_calling_sequence;

  --    SET UP WITHHOLDING ENVIRONMENT:

  <<Getting_Basic_Info>>
  DECLARE
    DBG_Loc VARCHAR2(30) := 'Getting_Basic_Info';
  BEGIN

    /* BEGIN Commented Begin for bug#6605368 */
      -- Change this SQL to use appropriate PL/SQL FUNCTIONs WHEN available
      -- in the utilities package!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      debug_info := 'Set up Withholding Environment';


      /* Gl_Awt_date is the date that would be on basis of which the calculation would
         be happening, and not the one that would be stamped on the dists as the accounting
         date, hence need not be in an open period
         Same logic has been moved below, while checking the GL date for each group */
      /* Commented for bug#6605368 Start
      SELECT   GPS.period_name,
               P_Awt_Date
        INTO   gl_period_name,
               gl_awt_date
        FROM   gl_period_statuses GPS,
               ap_system_parameters ASP
       WHERE   GPS.application_id = 200
         AND   GPS.set_of_books_id       = ASP.set_of_books_id
         AND   P_Awt_Date          BETWEEN GPS.start_date
                                       AND GPS.end_date
         AND  (
                (GPS.closing_status      IN ('O', 'F'))
               OR
                (P_Calling_Module        IN ('INVOICE INQUIRY','AWT REPORT'))
               )
         AND   NVL(GPS.ADJUSTMENT_PERIOD_FLAG, 'N') = 'N'
         AND   ASP.ORG_ID = nvl(P_ORG_ID, asp.org_id); --4742265
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ap_utilities_pkg.get_OPEN_gl_date(P_Awt_Date, gl_period_name, gl_awt_date);

        IF gl_awt_date IS NULL THEN
          RAISE NOT_AN_OPEN_GL_PERIOD;
        END IF;
    END;
    Commented for bug#6605368 End */

    gl_awt_date := p_awt_date; /* Added to establish the calculation date for bug#6605368 */

    -- Get INVOICE basic information    AND SUPPLIER identIFication:

    debug_info := 'Get INVOICE basic information    AND SUPPLIER identIFication';
    SELECT invoice_currency_code,
           payment_currency_code,
           payment_cross_rate,
           exchange_rate,
           invoice_num,
           vendor_id,
           vendor_site_id,
           org_id                  /* Bug 3700128. MOAC Project */
      INTO currency_code,
           payment_currency_code,
           payment_cross_rate,
           invoice_exchange_rate,
           invoice_number,
           supplier_id,
           supplier_site_id,
           g_org_id                /* Bug 3700128. MOAC Project */
      FROM ap_invoices_all
     WHERE invoice_id = P_Invoice_Id;

    -- Get base currency code:

    debug_info := 'Get base currency code';
    SELECT base_currency_code
      INTO functional_currency
      FROM ap_system_parameters_all
     WHERE org_id = g_org_id; --4742265

  END Getting_Basic_Info;

  -- Get GROUP AMOUNTS    AND    SET NUMBER of GROUPS found:
  --Bug6660355
  <<Get_Groups>>
  DECLARE

  /* Changed this cursor, added the max_gl_date to retrieve the max of the distributions GL date */
  /* per group which would be used to stamp the GL for the withholding distributions of the group */

    CURSOR c_group_amounts (InvId IN NUMBER, WTDate IN DATE)
    IS
    SELECT D.group_id
           ,DECODE (SIGN(WTDate - G.inactive_date),
                   0, 'Y',
                   1, 'Y', 'N')  non_valid_group,
           SUM(D.amount * NVL(invoice_exchange_rate,1))  group_amount,
           SUM(DECODE (D.line_type_lookup_code,
                'TAX', NVL(D.base_amount, D.amount) ,0)) vat_amount,
           max(D.accounting_date) max_gl_date  /* Added for bug#6605368 */
    FROM (select DECODE(AIP.create_awt_dists_type,'BOTH',decode(p_calling_module,'AUTOAPPROVAL',
                                                          AID.awt_group_id,AID.pay_awt_group_id),
                                             'PAYMENT',AID.pay_awt_group_id,AID.awt_group_id) group_id,
            AID.amount,AID.base_amount,AID.line_type_lookup_code, AID.accounting_date /* Added AID.accounting_date for bug#6605368 */
            from ap_invoice_distributions_all AID,ap_system_parameters_all AIP
            where AID.invoice_id = InvId
            AND AID.org_id       = AIP.org_id  ) D,
            ap_awt_groups                G
    where  D.group_id  = G.group_id(+)
    AND D.line_type_lookup_code <> 'AWT'
    GROUP BY D.group_id,
             DECODE ( SIGN(WTDate - G.inactive_date),
                      0, 'Y',
                      1, 'Y','N')

    HAVING SUM(D.amount) <> 0
    ORDER BY  DECODE(D.group_id, NULL, 0, 1);

    rec_group_amounts c_group_amounts%ROWTYPE;

    DBG_Loc                        VARCHAR2(30) := 'Get_Groups';
    i                              binary_integer := 0;
    total_invoice_amount           ap_invoices.invoice_amount%TYPE;
    total_vat_amount               NUMBER  := 0;
    gross_exempt_amount            NUMBER  := 0;
    gross_amount_on_all_awt_groups NUMBER  := 0;
    gross_amount_allbutlast_group  NUMBER  := 0;
    one_invalid_group_exists       boolean := FALSE;

  BEGIN
    debug_info := 'Open CURSOR to get group amounts';
    OPEN  c_group_amounts(P_Invoice_Id, gl_awt_date);

    LOOP
      debug_info := 'Fetch CURSOR to get group amounts';

      FETCH c_group_amounts   INTO rec_group_amounts;
      EXIT WHEN c_group_amounts%NOTFOUND;

      IF (rec_group_amounts.non_valid_group = 'Y') THEN
        one_invalid_group_exists := TRUE;
        invalid_group            := rec_group_amounts.group_id;
      END IF;

      EXIT WHEN one_invalid_group_exists;
      i                                := c_group_amounts%ROWCOUNT;
      tab_group_id(i)                  := rec_group_amounts.group_id;
      tab_amount_by_group(i)           := rec_group_amounts.group_amount;
      tab_vat_by_group(i)              := rec_group_amounts.vat_amount;

      /* Added for bug#6605368 Start */
      /* Bug7240465: Modified fix of bug#6605368 */

       IF p_calling_module = 'AUTOAPPROVAL' THEN
          tab_max_gl_date(i)               := rec_group_amounts.max_gl_date; --bug6605368
       ELSE
          tab_max_gl_date(i)               := gl_awt_date;
       END IF;

      /* Retrieve the period name per group for the max of the distributions gl date */
      /* This also ensures that the period is open for the gl date, else it raises exception */

      BEGIN
        SELECT glps.period_name
          INTO tab_max_gl_period(i)
          FROM gl_period_statuses glps,
               ap_invoices_all ai
         WHERE glps.application_id = 200
           AND nvl(glps.adjustment_period_flag, 'N') <>'Y'
           AND  (
                   (GLPS.closing_status      IN ('O', 'F'))
                   OR
                   (P_Calling_Module        IN ('INVOICE INQUIRY','AWT REPORT'))
                )
           AND tab_max_gl_date(i) BETWEEN glps.start_date AND glps.end_date
           AND ai.set_of_books_id = glps.set_of_books_id
           AND ai.invoice_id = p_invoice_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          /* If there is no period found then check for the next available open period and date */
         /* Bug 7175689, Added g_org_id */
          ap_utilities_pkg.get_open_gl_date
          (
            tab_max_gl_date(i),
            max_gl_date_period,
            max_gl_dist_date,
            g_org_id
          );

          IF max_gl_dist_date IS NULL THEN
             /* No future period open, raise */
               RAISE NOT_AN_OPEN_GL_PERIOD;
          ELSE
             /* If there is a new date found then populate the pl/sql table for dates and period with it */
             tab_max_gl_date(i)   := max_gl_dist_date;
             tab_max_gl_period(i) := max_gl_date_period;
          END IF;
      END;

      /* Added for bug#6605368 End */

      total_vat_amount                 := total_vat_amount +
                                          rec_group_amounts.vat_amount;
      IF (rec_group_amounts.group_id IS NULL) THEN
        gross_exempt_amount            := rec_group_amounts.group_amount;
      ELSE
        gross_amount_on_all_awt_groups := gross_amount_on_all_awt_groups +
                                          rec_group_amounts.group_amount;
      END IF;
    END LOOP;

    debug_info := 'Close CURSOR to get group amounts';
    CLOSE c_group_amounts;

    IF (i = 0) THEN
      RAISE ALL_GROUPS_ZERO;
    END IF;

    IF one_invalid_group_exists THEN
      RAISE ONE_INVALID_GROUP;
    END IF;

    NUMBER_of_awt_groups := i;

    -- To be sure, the total invoice amount IS calculated rather than
    -- SELECTed   FROM the database:
    -- Calculate TOTAL INVOICE AMOUNT   FROM distribution lines:

    total_invoice_amount := gross_amount_on_all_awt_groups +
                            gross_exempt_amount;

    -- Adjust figures FOR possible discount on invoice

     IF (P_Create_Dists in('PAYMENT','BOTH')) THEN --Bug6660355
     <<Check_For_Discount>>
      DECLARE
        CURSOR c_total_discount_on_invoice
              (InvId   IN NUMBER,
               PaymNum IN NUMBER) IS
        SELECT SUM
               (NVL(S.discount_amount_available, 0)
               +NVL(S.second_disc_amt_available, 0)
               +NVL(S.third_disc_amt_available, 0)) discount,
               P.disc_is_inv_less_tax_flag
          FROM ap_payment_schedules S,
               ap_system_parameters P
         WHERE S.invoice_id               = InvId
        /* Next condition is to make ok the projected withholding screen */
           AND  S.payment_num              = NVL(PaymNum, S.payment_num)
           AND  P.awt_include_discount_amt = 'N'
           AND  P.org_id = p_org_id
           AND  P.org_id = s.org_id --4742265
--bug5052436 modifies the above predicate
        GROUP BY     P.disc_is_inv_less_tax_flag;

        discount_amount NUMBER;
        tax_excluded    char(1);
        DBG_Loc         VARCHAR2(30) := 'Check_For_Discount';
        NO_DISCOUNT     EXCEPTION;

      BEGIN
        debug_info := 'Open CURSOR to check FOR discounts';
        OPEN  c_total_discount_on_invoice(P_Invoice_Id, P_Payment_Num);

        debug_info := 'Fetch CURSOR to check FOR discounts';
        FETCH c_total_discount_on_invoice   INTO discount_amount, tax_excluded;

        IF c_total_discount_on_invoice%NOTFOUND THEN
          discount_amount := 0;
        END IF;

        debug_info := 'Close CURSOR to check FOR discounts';
        CLOSE c_total_discount_on_invoice;

        IF (discount_amount = 0) THEN
          RAISE NO_DISCOUNT;
        END IF;

        discount_amount := discount_amount / payment_cross_rate
                           * NVL(invoice_exchange_rate,1);

        -- A discount must be taken on this invoice.
        -- Thus EACH actual amount by group in the PL/SQL tables needs to be
        -- adjusted taking consideration of this discount, according to the
        -- following FORmula:
        --
        --                                           (OldAmount - GV)
        -- NewAmount = OldAmount - WholeDiscount * --------------------
        --                                         (InvoiceAmount - TV)
        --  WHERE:
        --
        -- GV = Group Vat IF (tax_excluded = 'Y'), ELSE ZERO
        -- TV = Total Vat IF (tax_excluded = 'Y'), ELSE ZERO
        --
        -- The amounts by group have come   FROM the c_group_amounts CURSOR
        -- as figures including tax amounts. If there IS a discount, this
        -- applies to each group decreasing only the part on which the
        -- discount calculation was extENDed during the payment schedule
        -- routines. This IS the meaning of the above FORmula.

        <<Loop_On_Group_Amounts>>

        FOR j in 1..number_of_awt_groups LOOP
          -- This LOOP MUST include alse the withholding exempt group
          DECLARE
            gv NUMBER := tab_vat_by_group(j);
            tv NUMBER := total_vat_amount;
          BEGIN
            IF (tax_excluded <> 'Y') THEN
              gv := 0; tv := 0;
            END IF;
            IF ((total_invoice_amount - total_vat_amount) > 0) THEN
              tab_amount_by_group(j) := (tab_amount_by_group(j)
                                         - ((discount_amount*(tab_amount_by_group(j)
                                            -tab_vat_by_group(j))/(total_invoice_amount-total_vat_amount))));
            END IF; -- avoid division by zero
          END;
        END LOOP Loop_On_Group_Amounts;

        -- Finally adjust invoice level data:

        total_invoice_amount := total_invoice_amount - discount_amount;

        IF (tab_group_id(1) IS NULL) THEN
          gross_exempt_amount          := tab_amount_by_group(1);
        ELSE
          gross_exempt_amount          := 0;
        END IF;
        gross_amount_on_all_awt_groups := total_invoice_amount -
                                          gross_exempt_amount;
      EXCEPTION
        WHEN NO_DISCOUNT THEN
             NULL;
      END Check_For_Discount;

    -- Bug: 2958713 Commented out the end if and added after splitting the payment.
    -- END IF; -- Discount was checked only FOR withholding at PAYMENT time

    -- Amounts applicable to each AWT group must now be recalculated on
    -- the basis of the current payment amount (which IS in the P_Amount
    -- parameter). For rounding purposes, the last group amount will be
    -- derived as a dIFference.
    --
    -- Consider the following example:
    --
    -- Invoice amount....: 300
    -- Group Distribution: Null Group --> 150 (WT exempt)
    --                     Group 1    --> 100
    --                     Group 2    -->  50
    -- Actual payment....: 75.25
    --
    -- Since only a part of the invoice amount IS subject to WT, the
    -- amount to withhold IS 75.25 * (150 / 300) = 75.25 / 2 = 37.625 =
    -- = (rounded) 37.63.
    -- The payment amount subject to WT FOR group 1 IS:
    -- 75.25 * (100 / 300) = 25.0833333... = (rounded) 25.08.
    -- The amount FOR group 2 should be 75.25 * (50 / 300) = 12.5416666... =
    -- = (rounded) 12.54; but, since 25.08 (WT group 1) + 12.54 (WT group 2)
    -- = 37.62    AND NOT 37.63, the last term IS calculated by subtracting   FROM
    -- the total amount subject to WT the SUM of the preceding calculated
    -- amounts: 37.63 - 25.08 = 12.55.

    -- Recalculate the amounts subject to WT in proportion to the payment:

    <<Gross_Amounts_By_Payment>>
    DECLARE
      payment_amount NUMBER         := P_Amount;
      DBG_Loc        VARCHAR2(30)   := 'Gross_Amounts_By_Payment';
      log_text       VARCHAR2(2000);
    BEGIN
      log_text := 'Prorating ';
      IF (
          (P_Payment_Num IS NULL)
         OR
          (P_Calling_Module in ('INVOICE INQUIRY', 'AWT REPORT'))
         ) THEN
        payment_amount := total_invoice_amount;
        log_text       := log_text||'invoice ';
      ELSE
        log_text       := log_text||'payment ';
      END IF;
      log_text         := log_text||'amount ['||
                          ltrim(
                             to_char(payment_amount
                                    , '999,999,999,999,999,999.99'
                                    )
                               )||'] through ';
      IF (tab_group_id(1) IS NULL) THEN
        log_text       := log_text||to_char(number_of_awt_groups-1);
      ELSE
        log_text       := log_text||to_char(number_of_awt_groups);
      END IF;
      log_text         := log_text||' AWT groups';

      gross_amount_on_all_awt_groups :=
              Proportional_Amount(
                   payment_amount,
                   gross_amount_on_all_awt_groups,
                   total_invoice_amount,
                   functional_currency,
                   current_calling_sequence);

      FOR j in 1..number_of_awt_groups - 1 LOOP
        IF tab_group_id(j) IS not NULL THEN
          tab_amount_by_group(j) :=
              Proportional_Amount(
                   payment_amount,
                   tab_amount_by_group(j),
                   total_invoice_amount,
                   functional_currency,
                   current_calling_sequence);

          gross_amount_allbutlast_group := gross_amount_allbutlast_group +
                                           tab_amount_by_group(j);
        END IF;
      END LOOP;

      -- Get the last group amount by dIFference:

      tab_amount_by_group(number_of_awt_groups) :=
          gross_amount_on_all_awt_groups - gross_amount_allbutlast_group;

    END Gross_Amounts_By_Payment;
   end if; -- For bug 2958713

  END Get_Groups;

  <<Process_Withholding>>
  DECLARE
    current_amount_subject_for_tax NUMBER;
    current_rank_tax_cumulator     NUMBER;
    current_rank                   integer;
    starting_group                 integer(1);
    EXCEPTION_withholding_rate     ap_awt_tax_rates.tax_rate%TYPE;
    EXCEPTION_withholding_rate_id  ap_awt_tax_rates.tax_rate_id%TYPE;
    EXCEPTION_withholding_amount   NUMBER;
    NUMBER_of_ranges               NUMBER;
    ranges_withholding_amount      NUMBER;
    normal_withholding_amount      NUMBER;
    normal_withholding_rate        NUMBER;
    normal_withholding_rate_id     NUMBER;
    cert_withholding_amount        NUMBER;
    cert_withholding_rate          NUMBER;
    cert_withholding_rate_id       NUMBER;
    withheld_amount                NUMBER;
    withheld_rate_id               NUMBER;
    one_tax_missing_period_exists  boolean := FALSE;
    one_invalid_tax_exists         boolean := FALSE;
    one_invalid_gl_acct_exists     boolean := FALSE;
    no_valid_rates_exist           boolean := FALSE;
    incorrect_ranges               boolean := FALSE;
    incorrect_range_dates          boolean := FALSE;
    must_be_base_currency          boolean := FALSE;
    custom_rate_NOTFOUND           boolean := TRUE;
    EXCEPTION_rate_NOTFOUND        boolean := TRUE;
    certIFicate_rate_NOTFOUND      boolean := TRUE;
    normal_rate_NOTFOUND           boolean := TRUE;
    ranges_rate_NOTFOUND           boolean := TRUE;

    DBG_Loc                        VARCHAR2(30) := 'Process_Withholding';
    DO_HANDLE_BUCKET               CONSTANT CHAR(1) := 'Y';

    CURSOR c_group_taxes (
              GrpId  IN NUMBER,
              WTDate IN DATE)
    IS
    SELECT AAGT.rank
    ,      AAGT.tax_name
    ,      ATC.range_amount_basis
    ,      ATC.range_period_basis
    ,      AOP.period_name
    ,      ATC.awt_period_type
    ,      ATC.awt_period_limit
    ,      ATC.inactive_date
    ,      ATC.tax_code_combination_id
     FROM ap_awt_group_taxes  AAGT
    ,     ap_tax_codes        ATC
    ,     ap_other_periods    AOP
     WHERE    (AAGT.group_id = GrpId)
       AND    (AAGT.tax_name = ATC.name)
       AND    (ATC.tax_type = 'AWT')         -- BUG 3665866
       AND    (AOP.application_id (+) =  200)
       AND    (AOP.module         (+) =  'AWT')
       AND    (AOP.period_type    (+) =  ATC.awt_period_type)
       AND    (AOP.start_date     (+) <= TRUNC(gl_awt_date))
       AND    (AOP.end_date       (+) >= TRUNC(gl_awt_date))
       AND    (AAGT.org_id            =  ATC.org_id)  -- bug 7301484
       AND    (ATC.org_id             =  g_org_id)    -- bug 7301484
     ORDER BY rank ASC, ATC.name;

    rec_group_taxes c_group_taxes%ROWTYPE;

  BEGIN
    -- Set starting group FOR WT Calculation, excluding the exempt
    -- IF existent:

    IF tab_group_id(1) IS NULL THEN
      starting_group := 2;
    ELSE
      starting_group := 1;
    END IF;

    <<For_Each_Withholding_Group>>
    FOR g in starting_group..number_of_awt_groups LOOP

      -- Reset amount subject FOR tax, rank    AND rank cumulator:

      current_amount_subject_for_tax := tab_amount_by_group(g);
      current_rank_tax_cumulator     := 0;
      withheld_amount                := 0;

      /* Added for bug#6605368 Start */
      /* Retrieve the GL date and the GL period for the AWT lines for the current Group */
      max_gl_dist_date   := tab_max_gl_date(g);
      max_gl_date_period := tab_max_gl_period(g);
      /* Added for bug#6605368 End */

      <<Get_Starting_Rank>>

      DECLARE
        CURSOR c_init_rank
        IS
        SELECT MIN(rank)
          FROM ap_awt_group_taxes
         WHERE group_id = tab_group_id(g);
      BEGIN

        debug_info := 'Open CURSOR to get starting rank ';
        OPEN  c_init_rank;

        debug_info := 'Fetch CURSOR to get starting rank ';
        FETCH c_init_rank   INTO current_rank;

        debug_info := 'Close CURSOR to get starting rank ';
        CLOSE c_init_rank;
      END Get_Starting_Rank;

      debug_info := 'Open CURSOR c_group_taxes';
      OPEN c_group_taxes(tab_group_id(g),
                         gl_awt_date);

      <<For_Each_Tax_In_Group>>
      LOOP
        <<Consider_One_Withholding_Tax>>
        DECLARE
          DBG_Loc VARCHAR2(30) := 'Consider_One_Withholding_Tax';
        BEGIN

          debug_info := 'Fetch CURSOR c_roup_taxes';
          FETCH c_group_taxes   INTO rec_group_taxes;

          EXIT WHEN c_group_taxes%NOTFOUND;

          -- Check for TAX INACTIVE:

          IF (gl_awt_date >= rec_group_taxes.inactive_date) THEN
            one_invalid_tax_exists := TRUE;
            invalid_group          := tab_group_id(g);
            invalid_tax            := rec_group_taxes.tax_name;
          END IF;
          EXIT WHEN one_invalid_tax_exists;

          -- Check FOR INVALID GL ACCOUNT:
          /* The Validity of the Account has to be checked */
          /* against the GL date used on the distribution */

          IF GL_Account_INVALID (
                        rec_group_taxes.tax_code_combination_id,
                        /* gl_awt_date, Commented for bug#6605368 */
                        max_gl_dist_date,  /* Added for bug#6605368 */
                        current_calling_sequence) THEN
            one_invalid_gl_acct_exists := TRUE;
            invalid_group              := tab_group_id(g);
            invalid_tax                := rec_group_taxes.tax_name;
          END IF;
          EXIT WHEN one_invalid_gl_acct_exists;

          -- Check FOR INVALID PERIOD:

          IF (
              (rec_group_taxes.awt_period_type IS not NULL)
                 AND
              (rec_group_taxes.period_name IS NULL)
             ) THEN
            one_tax_missing_period_exists := TRUE;
            invalid_group                 := tab_group_id(g);
            invalid_tax                   := rec_group_taxes.tax_name;
          END IF;
          EXIT WHEN one_tax_missing_period_exists;

          -- Check FOR invoice CURRENCY against amount ranges/limits:

          IF (
              (rec_group_taxes.awt_period_limit IS not NULL)
                 AND
              (currency_code <> FUNCTIONal_currency)
             ) THEN
            must_be_base_currency := TRUE;
            invalid_group         := tab_group_id(g);
            invalid_tax           := rec_group_taxes.tax_name;
          END IF;
          EXIT WHEN must_be_base_currency;

          -- One of following will turn to FALSE IF at least one valid
          -- Withholding Tax Rate row exist in AP_AWT_TAX_RATES table
          -- FOR current tax in current group:
          custom_rate_NOTFOUND      := TRUE;
          EXCEPTION_rate_NOTFOUND   := TRUE;
          certIFicate_rate_NOTFOUND := TRUE;
          normal_rate_NOTFOUND      := TRUE;
          ranges_rate_NOTFOUND      := TRUE;

          -- (Re-)Calculate rank, cumulator    AND amount subject FOR tax

          current_rank_tax_cumulator := current_rank_tax_cumulator +
                                        withheld_amount;
          IF (rec_group_taxes.rank <> current_rank) THEN
            current_amount_subject_for_tax :=
                 current_amount_subject_for_tax - current_rank_tax_cumulator;
            current_rank_tax_cumulator     := 0;
          END IF;
          current_rank := rec_group_taxes.rank;
          withheld_amount := 0;

          -- HOOK FOR custom withholding routines:
          -- Try to get a rate_id   FROM the withholding custom package: IF
          -- successful, confirm that rate, apply cut off, INSERT the
          -- corresponding temporary withholding line,    AND go to terminate
          -- the current tax processing, looking FOR the next tax.

          <<Custom_Withholding_Hook>>
          DECLARE
            DBG_Loc                VARCHAR2(30) := 'Custom_Withholding_Hook';
            custom_awt_tax_rate_id ap_awt_tax_rates.tax_rate_id%TYPE;
            INVALID_TAX_RATE_ID    EXCEPTION;
          BEGIN

            custom_awt_tax_rate_id :=
                Ap_Custom_Withholding_Pkg.Ap_Special_Rate (
                          rec_group_taxes.tax_name,
                          P_Invoice_Id,
                          P_Payment_Num,
                          gl_awt_date,
                          current_amount_subject_for_tax);
            IF (custom_awt_tax_rate_id IS not NULL) THEN

              custom_rate_NOTFOUND := FALSE;

              <<Store_Custom_Withholding>>
              DECLARE
                CURSOR c_custom_rate (TaxRateId IN NUMBER)
                IS
                SELECT tax_rate
                  FROM ap_awt_tax_rates
                 WHERE tax_rate_id = TaxRateId;

                custom_wt_amount     NUMBER;
                custom_wt_rate       ap_awt_tax_rates.tax_rate%TYPE;
                custom_rate_notfound boolean;
              BEGIN
                debug_info := 'Open CURSOR FOR custom rate';
                OPEN  c_custom_rate(custom_awt_tax_rate_id);

                debug_info := 'Fetch CURSOR FOR custom rate';
                FETCH c_custom_rate   INTO custom_wt_rate;

                custom_rate_notfound := c_custom_rate%NOTFOUND;

                debug_info := 'Close CURSOR FOR custom rate';
                CLOSE c_custom_rate;

                IF (
                    (custom_rate_notfound)
                  OR
                    (custom_wt_rate IS NULL)
                   ) THEN
                  RAISE INVALID_TAX_RATE_ID;
                ELSE
                  custom_wt_amount := current_amount_subject_for_tax *
                                      (custom_wt_rate / 100);
                  custom_wt_amount := Ap_Utilities_Pkg.Ap_Round_Currency
                                      (custom_wt_amount
                                      ,currency_code);
                END IF;
                -- Apply cut off:
                custom_wt_amount := Do_AWT_Cut_Off
                                    (gl_awt_date,
                                     current_amount_subject_for_tax,
                                     custom_wt_amount,
                                     supplier_id,
                                     rec_group_taxes.tax_name,
                                     rec_group_taxes.period_name,
                                     rec_group_taxes.awt_period_limit,
                                     current_calling_sequence);
                -- Insert this custom information:
                Insert_Temp_Distribution (P_Invoice_Id,
                                          supplier_id,
                                          P_Payment_Num,
                                          tab_group_id(g),
                                          rec_group_taxes.tax_name,
                                          rec_group_taxes.tax_code_combination_id,
                                          current_amount_subject_for_tax,
                                          custom_wt_amount,
                                          max_gl_dist_date,   /* Changed from gl_awt_date to max_gl_dist_date for bug#6605368 */
                                          max_gl_date_period, /* Changed from gl_period_name to max_gl_date_period for bug#6605368 */
                                          rec_group_taxes.awt_period_type,
                                          rec_group_taxes.period_name,
                                          P_Checkrun_Name,
                                          custom_awt_tax_rate_id,
                                          invoice_exchange_rate,
                                          FUNCTIONal_currency,
                                          FUNCTIONal_currency,
                                          NULL,
                                          current_calling_sequence,
                                          DO_HANDLE_BUCKET,
                                          P_Last_Updated_By,
                                          P_Last_Update_Login,
                                          P_Program_Application_Id,
                                          P_Program_Id,
                                          P_Request_Id,
                                          P_Calling_Module,
                                          P_Invoice_Payment_Id,
                                          p_checkrun_id => p_checkrun_id);
              END Store_Custom_Withholding;

              -- Skip anyORdinary withholding processing:
              goto End_Processing_Current_Tax;

            END IF;
          EXCEPTION
            WHEN INVALID_TAX_RATE_ID THEN
              custom_rate_NOTFOUND := TRUE;
          END Custom_Withholding_Hook;

          -- CUSTOM rate unexistent. Continue with core AWT calculations:
          -- Get withholding figures FOR EXCEPTION    AND apply Cut Off (VALUES
          -- could be NULL):
          Get_Withholding_On_Exception (invoice_number,
                                        rec_group_taxes.tax_name,
                                        current_amount_subject_for_tax,
                                        functional_currency,
                                        gl_awt_date,
                                        supplier_id,
                                        supplier_site_id,
                                        exception_withholding_rate,
                                        exception_withholding_rate_id,
                                        exception_withholding_amount,
                                        exception_rate_notfound,
                                        current_calling_sequence);
          EXCEPTION_withholding_amount := Do_AWT_Cut_Off(
                                         gl_awt_date,
                                         current_amount_subject_for_tax,
                                         exception_withholding_amount,
                                         supplier_id,
                                         rec_group_taxes.tax_name,
                                         rec_group_taxes.period_name,
                                         rec_group_taxes.awt_period_limit,
                                         current_calling_sequence) ;

          -- Get withholding figures FOR CERTIFICATE (VALUES could be NULL):
          Get_Withholding_On_CertIFicate(rec_group_taxes.tax_name,
                                         current_amount_subject_for_tax,
                                         functional_currency,
                                         gl_awt_date,
                                         supplier_id,
                                         supplier_site_id,
                                         cert_withholding_rate,
                                         cert_withholding_rate_id,
                                         cert_withholding_amount,
                                         certificate_rate_notfound,
                                         current_calling_sequence);
          Savepoint BEFORE_CERTIFICATE;

          -- Withholding Tax Rate FOR CertIFicate IS not NULL?

          IF (cert_withholding_rate IS not NULL) THEN
            -- CertIFicate EXISTS
            -- Calculate proper WT amount FOR CERTIFICATE applying Cut Off:

            cert_withholding_amount := Do_AWT_Cut_Off
                                      (gl_awt_date,
                                       current_amount_subject_for_tax,
                                       cert_withholding_amount,
                                       supplier_id,
                                       rec_group_taxes.tax_name,
                                       rec_group_taxes.period_name,
                                       rec_group_taxes.awt_period_limit,
                                       current_calling_sequence);

            -- Confirm WT Rate    AND Amount

            IF (EXCEPTION_withholding_rate IS NULL) THEN
              withheld_amount  := cert_withholding_amount;
              withheld_rate_id := cert_withholding_rate_id;
            ELSE
              withheld_amount  := EXCEPTION_withholding_amount;
              withheld_rate_id := EXCEPTION_withholding_rate_id;
            END IF;

            Insert_Temp_Distribution(P_Invoice_Id,
                                     supplier_id,
                                     P_Payment_Num,
                                     tab_group_id(g),
                                     rec_group_taxes.tax_name,
                                     rec_group_taxes.tax_code_combination_id,
                                     current_amount_subject_for_tax,
                                     withheld_amount,
                                     max_gl_dist_date,   /* Changed from gl_awt_date to max_gl_dist_date for bug#6605368 */
                                     max_gl_date_period, /* Changed from gl_period_name to max_gl_date_period for bug#6605368 */
                                     rec_group_taxes.awt_period_type,
                                     rec_group_taxes.period_name,
                                     P_Checkrun_Name,
                                     withheld_rate_id,
                                     invoice_exchange_rate,
                                     functional_currency,
                                     functional_currency,
                                     NULL,
                                     current_calling_sequence,
                                     DO_HANDLE_BUCKET,
                                     P_Last_Updated_By,
                                     P_Last_Update_Login,
                                     P_Program_Application_Id,
                                     P_Program_Id,
                                     P_Request_Id,
                                     P_Calling_Module,
                                     P_Invoice_Payment_Id,
                                     p_checkrun_id => p_checkrun_id);

         -- END IF;
         ELSE -- cert_withholding_rate is null Bug 6894755

           -- CertIFicate NOT exists - Set Amount to Null:
           cert_withholding_amount := NULL;

           -- SAVEPOINT:
           -- situation BEFORE the amount ranges have been processed

           -- Get withholding figures FOR RANGES eventually INSERTing
           -- temporary distributions    AND updating bucket:

           Get_Withholding_On_Ranges (
              tab_group_id(g),
              rec_group_taxes.tax_name,
              rec_group_taxes.tax_code_combination_id,
              max_gl_date_period,  /* Changed from gl_period_name to max_gl_date_period bug#6605368 */
              rec_group_taxes.period_name,
              rec_group_taxes.awt_period_type,
              rec_group_taxes.awt_period_limit,
              P_Invoice_Id,
              P_Payment_Num,
              current_amount_subject_for_tax,
              invoice_exchange_rate,
              functional_currency,
              functional_currency,
              gl_awt_date,
              max_gl_dist_date, /* Added for bug#6605368 */
              supplier_id,
              supplier_site_id,
              rec_group_taxes.range_amount_basis,
              rec_group_taxes.range_period_basis,
              P_Checkrun_Name,
              P_Last_Updated_By,
              P_Last_Update_Login,
              P_Program_Application_Id,
              P_Program_Id,
              P_Request_Id,
              P_Calling_Module,
              ranges_withholding_amount,
              number_of_ranges,
              ranges_rate_notfound,
              incorrect_ranges,
              incorrect_range_dates,
              current_calling_sequence,
              P_Invoice_Payment_Id,
              NULL,
              cert_withholding_rate ,
              cert_withholding_rate_id,
              p_checkrun_id);

            IF incorrect_range_dates OR incorrect_ranges THEN
              invalid_group          := tab_group_id(g);
              invalid_tax            := rec_group_taxes.tax_name;
              EXIT;  -- Stop processing taxes/group/invoice: error
            END IF;

            IF (
                (currency_code <> FUNCTIONal_currency)
                   AND
                (number_of_ranges > 1)
               ) THEN
              must_be_base_currency := TRUE;
              invalid_group         := tab_group_id(g);
              invalid_tax           := rec_group_taxes.tax_name;
              EXIT;
            END IF;

            -- Were RANGES applicable?

            IF (number_of_ranges > 0
                  AND
               currency_code = FUNCTIONal_currency) THEN
              -- Ranges were APPLICABLE ...

              IF (EXCEPTION_withholding_rate IS not NULL) THEN

                --     If EXCEPTION exists THEN always take the EXCEPTION even
                --     IF it's less than range.
                --     Made changes FOR Bug # 429166.

                -- ... but the EXCEPTION IS stronger. Undo anything FOR
                --     the ranges,    AND INSERT FOR EXCEPTION updating the
                --     corresponding bucket:

                ROLLBACK TO BEFORE_CERTIFICATE ;

                Insert_Temp_Distribution (
                       P_Invoice_Id,
                       supplier_id,
                       P_Payment_Num,
                       tab_group_id(g),
                       rec_group_taxes.tax_name,
                       rec_group_taxes.tax_code_combination_id,
                       current_amount_subject_for_tax,
                       EXCEPTION_withholding_amount,
                       max_gl_dist_date,    /* Changed from gl_awt_date to max_gl_dist_date for bug#6605368 */
                       max_gl_date_period,  /* Added for bug#6605368 */
                       --gl_period_name,    bug6877813
                       rec_group_taxes.awt_period_type,
                       rec_group_taxes.period_name,
                       P_Checkrun_Name,
                       EXCEPTION_withholding_rate_id,
                       invoice_exchange_rate,
                       FUNCTIONal_currency,
                       FUNCTIONal_currency,
                       NULL,
                       current_calling_sequence,
                       DO_HANDLE_BUCKET,
                       P_Last_Updated_By,
                       P_Last_Update_Login,
                       P_Program_Application_Id,
                       P_Program_Id,
                       P_Request_Id,
                       P_Calling_Module,
                       P_Invoice_Payment_Id,
                       p_checkrun_id => p_checkrun_id);

                withheld_amount := EXCEPTION_withholding_amount;
              ELSE
                withheld_amount := ranges_withholding_amount;
              END IF;
            ELSE
              -- Ranges were NOT applicable
              -- Get withholding figures FOR the normal case:

              Get_Normal_Withholding (
                       rec_group_taxes.tax_name,
                       current_amount_subject_for_tax,
                       functional_currency,
                       gl_awt_date,
                       normal_withholding_rate,
                       normal_withholding_rate_id,
                       normal_withholding_amount,
                       normal_rate_notfound,
                       current_calling_sequence);

              normal_withholding_amount := Do_AWT_Cut_Off(
                       gl_awt_date,
                       current_amount_subject_for_tax,
                       normal_withholding_amount,
                       supplier_id,
                       rec_group_taxes.tax_name,
                       rec_group_taxes.period_name,
                       rec_group_taxes.awt_period_limit,
                       current_calling_sequence);

              -- Confirm WT Rate    AND Amount
              -- If there IS an EXCEPTION THEN always take EXCEPTION rate
              -- even IF it's less than normal.

              IF (EXCEPTION_withholding_rate IS NULL) THEN
                withheld_amount  := normal_withholding_amount;
                withheld_rate_id := normal_withholding_rate_id;
              ELSE
                withheld_amount  := EXCEPTION_withholding_amount;
                withheld_rate_id := EXCEPTION_withholding_rate_id;
              END IF;

              Insert_Temp_Distribution (
                       P_Invoice_Id,
                       supplier_id,
                       P_Payment_Num,
                       tab_group_id(g),
                       rec_group_taxes.tax_name,
                       rec_group_taxes.tax_code_combination_id,
                       current_amount_subject_for_tax,
                       withheld_amount,
                       max_gl_dist_date,    /* Changed from gl_awt_date to max_gl_dist_date for bug#6605368 */
                       max_gl_date_period,  /* Added for bug#6605368 */
                       --gl_period_name,      bug6877813
                       rec_group_taxes.awt_period_type,
                       rec_group_taxes.period_name,
                       P_Checkrun_Name,
                       withheld_rate_id,
                       invoice_exchange_rate,
                       functional_currency,
                       functional_currency,
                       NULL,
                       current_calling_sequence,
                       DO_HANDLE_BUCKET,
                       P_Last_Updated_By,
                       P_Last_Update_Login,
                       P_Program_Application_Id,
                       P_Program_Id,
                       P_Request_Id,
                       P_Calling_Module,
                       P_Invoice_Payment_Id,
                       p_checkrun_id => p_checkrun_id);

            END IF;  -- Whether Ranges were applicable OR not
          END IF; -- cert_withholding_rateis not null Bug 6894755

          <<End_Processing_Current_Tax>>

          IF (
              custom_rate_NOTFOUND
                AND
              EXCEPTION_rate_NOTFOUND
                AND
              certIFicate_rate_NOTFOUND
                AND
              normal_rate_NOTFOUND
                AND
              ranges_rate_NOTFOUND
             ) THEN
            no_valid_rates_exist := TRUE;
            invalid_group        := tab_group_id(g);
            invalid_tax          := rec_group_taxes.tax_name;
          END IF;
          EXIT WHEN no_valid_rates_exist;

        END Consider_One_Withholding_Tax;
      END LOOP For_Each_Tax_In_Group;

      debug_info := 'Close CURSOR c_group_taxes';
      CLOSE c_group_taxes;

      IF incorrect_ranges THEN
        RAISE INVALID_RANGE;
      END IF;

      IF one_invalid_tax_exists THEN
        RAISE ONE_INVALID_TAX;
      END IF;

      IF one_invalid_gl_acct_exists THEN
        RAISE ONE_INVALID_TAX_ACCOUNT;
      END IF;

      IF one_tax_missing_period_exists THEN
        RAISE ONE_TAX_MISSING_PERIOD;
      END IF;

      IF no_valid_rates_exist THEN
        RAISE NO_VALID_TAX_RATES;
      END IF;

      IF incorrect_range_dates THEN
        RAISE INVALID_RANGE_DATES;
      END IF;

      IF must_be_base_currency THEN
        RAISE INV_CURR_MUST_BE_BASE;
      END IF;

    END LOOP For_Each_Withholding_Group;
  END Process_Withholding;

EXCEPTION
  WHEN NOT_AN_OPEN_GL_PERIOD THEN
    DECLARE
      error_text VARCHAR2(2000);
    BEGIN
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR',
                                               'GL PERIOD NOT OPEN');
      P_AWT_Success := error_text;
    END;

  WHEN INVALID_RANGE THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN

      invalid_group_name := Get_Group_Name(invalid_group
                                           ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR'
                                               ,'AWT TAX RANGE INVALID')||
                    ' - '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'TAX')||
                    ' '||invalid_tax||' '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'GROUP')||
                    ' '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN ONE_INVALID_GROUP THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN
      invalid_group_name := Get_Group_Name(invalid_group
                                           ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR',
                                                 'AWT GROUP INACTIVE')||
                    ' - '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN ONE_INVALID_TAX THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN
      invalid_group_name := Get_Group_Name(invalid_group
                                           ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR'
                                                       ,'AWT TAX INACTIVE')||
                    ' - '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'TAX')||
                    ' '||invalid_tax||' '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'GROUP')||
                    ' '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN ONE_INVALID_TAX_ACCOUNT THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN
      invalid_group_name := Get_Group_Name(invalid_group
                                          ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR'
                                           ,'AWT TAX ACCOUNT INVALID')||
                    ' - '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'TAX')||
                    ' '||invalid_tax||' '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'GROUP')||
                    ' '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN ONE_TAX_MISSING_PERIOD THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN
      invalid_group_name := Get_Group_Name(invalid_group
                                          ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR'
                                                          ,'NO AWT PERIOD')||
                    ' - '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'TAX')||
                    ' '||invalid_tax||' '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'GROUP')||
                    ' '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN NO_VALID_TAX_RATES THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN
      invalid_group_name := Get_Group_Name(invalid_group
                                           ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR'
                                                          ,'NO AWT RATE')||
                    ' - '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'TAX')||
                    ' '||invalid_tax||' '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'GROUP')||
                    ' '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN INVALID_RANGE_DATES THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN
      invalid_group_name := Get_Group_Name(invalid_group
                                          ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR'
                                                    ,'INVALID RANGE DATES')||
                    ' - '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'TAX')||
                    ' '||invalid_tax||' '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'GROUP')||
                    ' '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN INV_CURR_MUST_BE_BASE THEN
    DECLARE
      invalid_group_name ap_awt_groups.name%TYPE;
      error_text         VARCHAR2(2000);
    BEGIN
      invalid_group_name := Get_Group_Name(invalid_group
                                          ,current_calling_sequence);
      error_text := Ap_Utilities_Pkg.Ap_Get_Displayed_Field('AWT ERROR'
                                                    ,'INV CURR MUST BE BASE')||
                    ' - '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'TAX')||
                    ' '||invalid_tax||' '||
                    Ap_Utilities_Pkg.Ap_Get_Displayed_Field('NLS TRANSLATION'
                                                           ,'GROUP')||
                    ' '||invalid_group_name;
      P_AWT_Success := error_text;
    END;

  WHEN ALL_GROUPS_ZERO THEN
    NULL;

  WHEN OTHERS THEN
    DECLARE
      error_text VARCHAR2(512) := SUBSTR(SQLERRM, 1, 512);
    BEGIN
      P_AWT_Success := error_text;

           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id = '        || to_char(P_Invoice_Id) ||
                      ', Awt Date  = '         || to_char(P_Awt_Date) ||
                      ', Calling Module = '    || P_Calling_Module ||
                      ', Create Dists = '      || P_Create_Dists ||
                      ', Amount  = '           || to_char(P_Amount) ||
                      ', Payment Num = '       || to_char(P_Payment_Num) ||
                      ', Checkrun Name = '     || P_Checkrun_Name);

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
    END;

END AP_Calculate_AWT_Amounts;


END AP_CALC_WITHHOLDING_PKG;

/
