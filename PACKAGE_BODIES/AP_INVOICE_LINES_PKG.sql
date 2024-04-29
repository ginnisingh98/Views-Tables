--------------------------------------------------------
--  DDL for Package Body AP_INVOICE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICE_LINES_PKG" as
/* $Header: apinlinb.pls 120.64.12010000.37 2010/07/08 06:51:30 baole ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_INVOICE_LINES_PKG';
G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_INVOICE_LINES_PKG.';

PROCEDURE Print (p_api_name IN VARCHAR2, p_debug_info IN VARCHAR2);

-----------------------------------------------------------------------
-- FUNCTION generate_dist_tab_for_dist_set validates distributions
-- to be created by a distribution set and generates a pl/sql table
-- of distributions to be inserted IF need be by the calling module.
-----------------------------------------------------------------------
FUNCTION Generate_Dist_Tab_For_Dist_Set(
 X_vendor_id               IN            AP_INVOICES.VENDOR_ID%TYPE,
 X_invoice_date            IN            AP_INVOICES.INVOICE_DATE%TYPE,
 X_invoice_lines_rec       IN            AP_INVOICES_PKG.r_invoice_line_rec,
 X_line_source             IN            VARCHAR2,
 X_dist_tab                IN OUT NOCOPY AP_INVOICE_LINES_PKG.dist_tab_type,
 X_dist_set_total_percent  IN            NUMBER,
 X_exchange_rate           IN            AP_INVOICES.EXCHANGE_RATE%TYPE,
 X_exchange_rate_type      IN            AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE,
 X_exchange_date           IN            AP_INVOICES.EXCHANGE_DATE%TYPE,
 X_invoice_currency        IN            AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
 X_base_currency           IN            AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
 X_chart_of_accounts_id    IN        GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE,
 X_Error_Code                 OUT NOCOPY VARCHAR2,
 X_Debug_Info                 OUT NOCOPY VARCHAR2,
 X_Debug_Context              OUT NOCOPY VARCHAR2,
 X_msg_application            OUT NOCOPY VARCHAR2,
 X_msg_data                   OUT NOCOPY VARCHAR2,
 X_calling_sequence        IN            VARCHAR2) RETURN BOOLEAN
IS

CURSOR dist_set_lines_cur IS
 SELECT ADSL.distribution_set_line_number,
        ADSL.description,
        ADSL.dist_code_combination_id,
        GL.account_type,
        ADSL.percent_distribution,
        ADSL.project_id,
        ADSL.task_id,
        ADSL.expenditure_type,
        ADSL.expenditure_organization_id,
	ADSL.project_Accounting_context,
        ADSL.award_id,
        ADSL.attribute_category,
        ADSL.attribute1,
        ADSL.attribute2,
        ADSL.attribute3,
        ADSL.attribute4,
        ADSL.attribute5,
        ADSL.attribute6,
        ADSL.attribute7,
        ADSL.attribute8,
        ADSL.attribute9,
        ADSL.attribute10,
        ADSL.attribute11,
        ADSL.attribute12,
        ADSL.attribute13,
        ADSL.attribute14,
        ADSL.attribute15,
        ADSL.type_1099
   FROM AP_Distribution_Set_Lines ADSL,
        GL_Code_combinations GL
  WHERE distribution_set_id = X_invoice_lines_rec.Distribution_Set_id
    AND GL.code_combination_id = ADSL.dist_code_combination_id
ORDER BY distribution_set_line_number;


l_pa_allows_overrides            VARCHAR2(1) := 'N';
l_employee_id                    AP_SUPPLIERS.EMPLOYEE_ID%TYPE;
user_id                          NUMBER;
l_account_type                   GL_CODE_COMBINATIONS.ACCOUNT_TYPE%TYPE;
l_dset_line_ccid
  AP_DISTRIBUTION_SET_LINES.DIST_CODE_COMBINATION_ID%TYPE;
l_dset_dist_line_num
  AP_DISTRIBUTION_SET_LINES.DISTRIBUTION_SET_LINE_NUMBER%TYPE;
l_dset_line_description       AP_DISTRIBUTION_SET_LINES.DESCRIPTION%TYPE;
l_dset_line_type_1099         AP_DISTRIBUTION_SET_LINES.TYPE_1099%TYPE;
l_dset_line_project_id        AP_DISTRIBUTION_SET_LINES.PROJECT_ID%TYPE;
l_dset_line_task_id           AP_DISTRIBUTION_SET_LINES.TASK_ID%TYPE;
l_dset_line_expenditure_type  AP_DISTRIBUTION_SET_LINES.EXPENDITURE_TYPE%TYPE;
l_dset_line_expenditure_org_id
  AP_DISTRIBUTION_SET_LINES.EXPENDITURE_ORGANIZATION_ID%TYPE;
l_dset_line_proj_acct_context
  AP_DISTRIBUTION_SET_LINES.PROJECT_ACCOUNTING_CONTEXT%TYPE;
l_dset_line_award_id             AP_DISTRIBUTION_SET_LINES.AWARD_ID%TYPE;
l_award_id			 AP_DISTRIBUTION_SET_LINES.AWARD_ID%TYPE;
l_dset_line_percent_dist
  AP_DISTRIBUTION_SET_LINES.PERCENT_DISTRIBUTION%TYPE;
l_dset_line_attribute_category
  AP_DISTRIBUTION_SET_LINES.ATTRIBUTE_CATEGORY%TYPE;
l_dset_line_attribute1           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE1%TYPE;
l_dset_line_attribute2           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE2%TYPE;
l_dset_line_attribute3           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE3%TYPE;
l_dset_line_attribute4           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE4%TYPE;
l_dset_line_attribute5           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE5%TYPE;
l_dset_line_attribute6           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE6%TYPE;
l_dset_line_attribute7           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE7%TYPE;
l_dset_line_attribute8           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE8%TYPE;
l_dset_line_attribute9           AP_DISTRIBUTION_SET_LINES.ATTRIBUTE9%TYPE;
l_dset_line_attribute10          AP_DISTRIBUTION_SET_LINES.ATTRIBUTE10%TYPE;
l_dset_line_attribute11          AP_DISTRIBUTION_SET_LINES.ATTRIBUTE11%TYPE;
l_dset_line_attribute12          AP_DISTRIBUTION_SET_LINES.ATTRIBUTE12%TYPE;
l_dset_line_attribute13          AP_DISTRIBUTION_SET_LINES.ATTRIBUTE13%TYPE;
l_dset_line_attribute14          AP_DISTRIBUTION_SET_LINES.ATTRIBUTE14%TYPE;
l_dset_line_attribute15          AP_DISTRIBUTION_SET_LINES.ATTRIBUTE15%TYPE;
l_dist_amount                    AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE;
l_dist_base_amount               AP_INVOICE_DISTRIBUTIONS.BASE_AMOUNT%TYPE;
l_dist_set_percent_number        NUMBER;
l_running_total_pa_quantity      AP_INVOICE_DISTRIBUTIONS.PA_QUANTITY%TYPE := 0;
l_running_total_amount           AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE := 0;
l_running_total_base_amt         AP_INVOICE_DISTRIBUTIONS.BASE_AMOUNT%TYPE := 0;
l_invoice_currency_code		 AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
l_status			 VARCHAR2(10);
l_industry			 VARCHAR2(10);
l_set_of_books_id		 AP_INVOICES.SET_OF_BOOKS_ID%TYPE;
l_pa_installed			 VARCHAR2(1);

l_max_amount                     AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE := 0;
l_max_pa_quantity                AP_INVOICE_DISTRIBUTIONS.PA_QUANTITY%TYPE := 0;
l_max_i                          BINARY_INTEGER := 0;
l_max_pa_qty_i                   BINARY_INTEGER := 0;
i                                BINARY_INTEGER := 0;
l_msg_application                VARCHAR2(25);
l_msg_type                       VARCHAR2(25);
l_msg_token1                     VARCHAR2(30);
l_msg_token2                     VARCHAR2(30);
l_msg_token3                     VARCHAR2(30);
l_msg_count                      NUMBER;
l_msg_data                       VARCHAR2(30);
l_billable_flag                  VARCHAR2(25);
l_unbuilt_flex                   VARCHAR2(240):='';
l_reason_unbuilt_flex            VARCHAR2(2000):='';
debug_context                    VARCHAR2(2000);
current_calling_sequence         VARCHAR2(2000);
debug_info                       VARCHAR2(1000);
l_error_found                    VARCHAR2(1);
l_rounding_exists                VARCHAR2(1) := 'N';
l_rounding_pa_qty_exists         VARCHAR2(1) := 'N';
--For bug2938770
l_invoice_type_lookup_code ap_invoices.invoice_type_lookup_code%TYPE;
l_prepay_dist_code_ccid    ap_invoice_distributions.dist_code_combination_id%TYPE;
--bugfix:5725904
l_sys_link_function        VARCHAR2(2);
l_message_text		   FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
l_api_name		   VARCHAR2(50);


BEGIN

  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_INVOICE_LINES_PKG.generate_dist_tab_for_dist_set<-'
     ||X_calling_sequence;
  l_api_name := 'Generate_Dist_Tab_For_Dist_Set';
  --------------------------------------------------------------
  -- Step 1
  -- Get type of distribution set IF not passed in as a parameter
  --
  --------------------------------------------------------------
  IF (X_dist_Set_total_percent is NULL) then
    BEGIN
      SELECT total_percent_distribution
        INTO l_dist_set_percent_number
        FROM ap_distribution_sets
       WHERE distribution_set_id = X_invoice_lines_rec.distribution_set_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_lines_Rec.invoice_id)
                ||', Invoice Line Number = '||TO_CHAR(X_invoice_lines_Rec.line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
          X_error_code := 'AP_DEBUG';
          RETURN (FALSE);
    END;
  ELSE
    l_dist_set_percent_number := X_dist_set_total_percent;
  END IF;

  --------------------------------------------------------------
  -- Step 2 - Validate distribution level information including
  -- accounting and project level information.  This is done in
  -- a loop that traverses all distribution lines defined in the
  -- distribution set.
  --------------------------------------------------------------
  --bug 2938770 populating the local variables
  SELECT nvl(PVS.prepay_code_combination_id,
             SP.prepay_code_combination_id),
         AI.invoice_type_lookup_code
  INTO   l_prepay_dist_code_ccid,
         l_invoice_type_lookup_code
  FROM ap_invoices AI,
       po_vendor_sites PVS,
       ap_system_parameters SP
  WHERE AI.invoice_id = X_invoice_lines_rec.invoice_id
  AND PVS.vendor_site_id = AI.vendor_site_id;

  i := 0;
  OPEN dist_set_lines_cur;
  LOOP
    FETCH dist_set_lines_cur
     INTO l_dset_dist_line_num,
          l_dset_line_description,
          l_dset_line_ccid,
          l_account_type,
          l_dset_line_percent_dist,
          l_dset_line_project_id,
          l_dset_line_task_id,
          l_dset_line_expenditure_type,
          l_dset_line_expenditure_org_id,
	  l_dset_line_proj_acct_context,
          l_dset_line_award_id,
          l_dset_line_attribute_category,
          l_dset_line_attribute1,
          l_dset_line_attribute2,
          l_dset_line_attribute3,
          l_dset_line_attribute4,
          l_dset_line_attribute5,
          l_dset_line_attribute6,
          l_dset_line_attribute7,
          l_dset_line_attribute8,
          l_dset_line_attribute9,
          l_dset_line_attribute10,
          l_dset_line_attribute11,
          l_dset_line_attribute12,
          l_dset_line_attribute13,
          l_dset_line_attribute14,
          l_dset_line_attribute15,
          l_dset_line_type_1099;

    EXIT WHEN dist_set_lines_cur%NOTFOUND;

    X_dist_tab(i).dist_line_num := l_dset_dist_line_num;
    X_dist_tab(i).description := nvl(l_dset_line_description,
                                     X_invoice_lines_rec.description);
    X_dist_tab(i).accounting_date := X_invoice_lines_rec.accounting_date;
    X_dist_tab(i).period_name := X_invoice_lines_rec.period_name;
    X_dist_tab(i).awt_group_id := X_invoice_lines_rec.awt_group_id;
    X_dist_tab(i).attribute_category := l_dset_line_attribute_category;
    X_dist_tab(i).attribute1 := l_dset_line_attribute1;
    X_dist_tab(i).attribute2 := l_dset_line_attribute2;
    X_dist_tab(i).attribute3 := l_dset_line_attribute3;
    X_dist_tab(i).attribute4 := l_dset_line_attribute4;
    X_dist_tab(i).attribute5 := l_dset_line_attribute5;
    X_dist_tab(i).attribute6 := l_dset_line_attribute6;
    X_dist_tab(i).attribute7 := l_dset_line_attribute7;
    X_dist_tab(i).attribute8 := l_dset_line_attribute8;
    X_dist_tab(i).attribute9 := l_dset_line_attribute9;
    X_dist_tab(i).attribute10 := l_dset_line_attribute10;
    X_dist_tab(i).attribute11 := l_dset_line_attribute11;
    X_dist_tab(i).attribute12 := l_dset_line_attribute12;
    X_dist_tab(i).attribute13 := l_dset_line_attribute13;
    X_dist_tab(i).attribute14 := l_dset_line_attribute14;
    X_dist_tab(i).attribute15 := l_dset_line_attribute15;

    --bugfix : 7022001
    X_dist_tab(i).pay_awt_group_id :=X_invoice_lines_rec.pay_awt_group_id;

    --Bug9296445
    X_dist_tab(i).reference_1 := X_invoice_lines_rec.reference_1;
    X_dist_tab(i).reference_2 := X_invoice_lines_rec.reference_2;

    --bugfix:4674194
    IF (AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_ACTIVE) THEN
       X_dist_tab(i).global_attribute3 := x_invoice_lines_rec.ship_to_location_id;
    END IF;

    --ETAX: Invwkb
    X_dist_tab(i).intended_use := x_invoice_lines_rec.primary_intended_use;

    -- Populate the amounts depending on whether the distribution
    -- set is a skeleton or not.
    IF (l_dist_set_percent_number <> 100) then
      l_dist_amount := 0;
      l_dist_base_amount := NULL;  -- Bug 5199337
    ELSE
      --bug6653070
      l_dist_amount := AP_UTILITIES_PKG.Ap_Round_Currency(
                              NVL(l_dset_line_percent_dist,0)
                              * (NVL(X_invoice_lines_rec.amount,0))/100,
                              X_invoice_currency);
      l_dist_base_amount :=  AP_UTILITIES_PKG.Ap_Round_Currency(
                                 NVL(l_dist_amount, 0) * X_exchange_rate,
                                 X_base_currency);
    END IF;

    X_dist_tab(i).amount       := l_dist_amount;
    X_dist_tab(i).base_amount  := l_dist_base_amount;
    X_dist_tab(i).rounding_amt := 0;

   -- Maintain a running total that will be used for rounding to the
   -- line base amount as well as the total amount.
    l_running_total_amount := l_running_total_amount + l_dist_amount;
    l_running_total_base_amt := l_running_total_base_amt + l_dist_base_amount;

    IF (ABS(l_max_amount) <= ABS(l_dist_amount) OR i = 0) then
      l_max_amount := l_dist_amount;
      l_max_i := i;
    END IF;

    IF  (X_invoice_lines_rec.project_id IS NOT NULL) THEN

	 X_dist_tab(i).project_id := X_invoice_lines_rec.project_id;
	 X_dist_tab(i).task_id := X_invoice_lines_rec.task_id;
	 X_dist_tab(i).expenditure_type := X_invoice_lines_rec.expenditure_type;
	 X_dist_tab(i).expenditure_organization_id := X_invoice_lines_rec.expenditure_organization_id;
	 X_dist_tab(i).expenditure_item_date := X_invoice_lines_rec.expenditure_item_date;

	 IF (X_invoice_lines_rec.pa_quantity IS NOT NULL AND
             X_invoice_lines_rec.amount <> 0) then
             X_dist_tab(i).pa_quantity := X_invoice_lines_rec.pa_quantity * l_dist_amount /
					  X_invoice_lines_rec.amount;
         END IF;

         X_dist_tab(i).pa_addition_flag := 'N';

   ELSIF (l_dset_line_project_id is not null) then

          X_dist_tab(i).project_id := l_dset_line_project_id;
          X_dist_tab(i).task_id := l_dset_line_task_id;
          X_dist_tab(i).expenditure_type := l_dset_line_expenditure_type;
          X_dist_tab(i).expenditure_organization_id := l_dset_line_expenditure_org_id;
          X_dist_tab(i).project_accounting_context := l_dset_line_proj_acct_context;

          IF (X_invoice_lines_rec.pa_quantity is not null AND
              X_invoice_lines_rec.amount <> 0) then

              X_dist_tab(i).pa_quantity := X_invoice_lines_rec.pa_quantity * l_dist_amount /
                                           X_invoice_lines_rec.amount;
          END IF;
          X_dist_tab(i).pa_addition_flag := 'N';
   ELSE
       X_dist_tab(i).pa_addition_flag := 'E';
   END IF;

    l_running_total_pa_quantity :=
      l_running_total_pa_quantity + nvl(X_dist_tab(i).pa_quantity,0);
    IF (ABS(l_max_pa_quantity) <= ABS(nvl(X_dist_tab(i).pa_quantity, 0))
        OR i = 0) THEN
      l_max_pa_quantity := X_dist_tab(i).pa_quantity;
      l_max_pa_qty_i := i;
    END IF;

    X_dist_tab(i).set_of_books_id := X_invoice_lines_rec.set_of_books_id;
    X_dist_tab(i).org_id := X_invoice_lines_rec.org_id;

    X_dist_tab(i).type_1099 := nvl(l_dset_line_type_1099,
                                   X_invoice_lines_rec.type_1099);
    IF (X_dist_tab(i).type_1099 IS NOT NULL) THEN
      X_dist_tab(i).income_tax_region :=
         X_invoice_lines_rec.income_tax_region;
    ELSE
      X_dist_tab(i).income_tax_region := NULL;
    END IF;

    -- Gather the data we need to call validation in PA
    IF (X_dist_tab(i).project_id is not null) then
      user_id := to_number(FND_PROFILE.VALUE('USER_ID'));
      l_pa_allows_overrides :=
        FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES');
      BEGIN
        SELECT employee_id
          INTO l_employee_id
          FROM ap_suppliers /* Bug 4718054 */
         WHERE DECODE(SIGN(TO_DATE(TO_CHAR(START_DATE_ACTIVE,'DD-MM-YYYY'),
               'DD-MM-YYYY') - TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY'),'DD-MM-YYYY')),
               1, 'N', DECODE(SIGN(TO_DATE(TO_CHAR(END_DATE_ACTIVE ,'DD-MM-YYYY'),
               'DD-MM-YYYY') -  TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY'),'DD-MM-YYYY')),
               -1, 'N', 0, 'N', 'Y')) = 'Y'
           AND enabled_flag = 'Y'
           AND vendor_id = X_vendor_id;
       EXCEPTION
         WHEN no_data_found then
           l_employee_id := NULL;
         WHEN OTHERS then
           l_employee_id := NULL;
       END;
    END IF;

    debug_info := 'Get expenditure item date IF null';
    IF (X_dist_tab(i).project_id IS NOT NULL AND
        X_dist_tab(i).expenditure_item_date IS NULL) THEN
      X_dist_tab(i).expenditure_item_date :=
         AP_INVOICES_PKG.get_expenditure_item_date(
         X_invoice_lines_rec.invoice_id,
         X_invoice_date,
         X_invoice_lines_rec.accounting_date,
         null,
         null,
         l_error_found);
      IF (l_error_found = 'Y') THEN
        CLOSE dist_set_lines_cur;
        Debug_info := debug_info
                      || ': cannot read expenditure item date information';
        X_debug_context := current_calling_sequence;
        X_debug_info := debug_info;
        X_error_code := 'AP_DEBUG';
        RETURN(FALSE);
      END IF;
    END IF;

   -- Do not validate project information IF called from the Import since that
   -- should be validated in the import itself.

    IF (X_dist_tab(i).project_id IS NOT NULL AND
        nvl(X_line_source, 'OTHER') <> 'IMPORT') then

      --bugfix:5725904
      If (l_invoice_type_lookup_code ='EXPENSE REPORT') Then
            l_sys_link_function :='ER' ;
      Else
            l_sys_link_function :='VI' ;
      End if;

      PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
        X_PROJECT_ID          => X_dist_tab(i).project_id,
        X_TASK_ID             => X_dist_tab(i).task_id,
        X_EI_DATE             => X_dist_tab(i).expenditure_item_date,
        X_EXPENDITURE_TYPE    => X_dist_tab(i).expenditure_type,
        X_NON_LABOR_RESOURCE  => null,
        X_PERSON_ID           => l_employee_id,
        X_QUANTITY            => nvl(X_dist_tab(i).pa_quantity, '1'),
        X_denom_currency_code => X_invoice_currency,
        X_acct_currency_code  => X_base_currency,
        X_denom_raw_cost      => l_dist_amount,
        X_acct_raw_cost       => l_dist_base_amount,
        X_acct_rate_type      => X_exchange_rate_type,
        X_acct_rate_date      => X_exchange_date,
        X_acct_exchange_rate  => X_exchange_rate,
        X_TRANSFER_EI         => null,
        X_INCURRED_BY_ORG_ID  => X_dist_tab(i).expenditure_organization_id,
        X_NL_RESOURCE_ORG_ID  => null,
        X_TRANSACTION_SOURCE  => l_sys_link_function, --5725904
        X_CALLING_MODULE      => 'apinlinb.pls',
        X_VENDOR_ID           => X_vendor_id,
        X_ENTERED_BY_USER_ID  => user_id,
        X_ATTRIBUTE_CATEGORY  => X_dist_tab(i).attribute_category,
        X_ATTRIBUTE1          => X_dist_tab(i).attribute1,
        X_ATTRIBUTE2          => X_dist_tab(i).attribute2,
        X_ATTRIBUTE3          => X_dist_tab(i).attribute3,
        X_ATTRIBUTE4          => X_dist_tab(i).attribute4,
        X_ATTRIBUTE5          => X_dist_tab(i).attribute5,
        X_ATTRIBUTE6          => X_dist_tab(i).attribute6,
        X_ATTRIBUTE7          => X_dist_tab(i).attribute7,
        X_ATTRIBUTE8          => X_dist_tab(i).attribute8,
        X_ATTRIBUTE9          => X_dist_tab(i).attribute9,
        X_ATTRIBUTE10         => X_dist_tab(i).attribute10,
        X_ATTRIBUTE11         => X_dist_tab(i).attribute11,
        X_ATTRIBUTE12         => X_dist_tab(i).attribute12,
        X_ATTRIBUTE13         => X_dist_tab(i).attribute13,
        X_ATTRIBUTE14         => X_dist_tab(i).attribute14,
        X_ATTRIBUTE15         => X_dist_tab(i).attribute15,
        X_msg_application     => l_msg_application,
        X_msg_type            => l_msg_type,
        X_msg_token1          => l_msg_token1,
        X_msg_token2          => l_msg_token2,
        X_msg_token3          => l_msg_token3,
        X_msg_count           => l_msg_count,
        X_msg_data            => l_msg_data,
        X_BILLABLE_FLAG       => l_billable_flag);

      IF (l_msg_data IS NOT NULL) THEN
        CLOSE dist_set_lines_cur;
        --Bug 7490877 Converting PA error code to AP error code
        x_error_code := 'AP'||substr(l_msg_data,3);

        --Bug 7490877 Commented below code
/*
        X_msg_application := l_msg_application;
        X_msg_data := l_msg_data;

	--bugfix:5725904
	Fnd_Message.Set_Name(l_msg_application, l_msg_data);
        --bug 6682104 setting the token values
            IF (l_msg_token1 IS NOT NULL) THEN
	       fnd_message.set_token('PATC_MSG_TOKEN1',l_msg_token1);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN1',FND_API.G_MISS_CHAR);
	    END IF;

            IF (l_msg_token2 IS NOT NULL) THEN
	        fnd_message.set_token('PATC_MSG_TOKEN2',l_msg_token2);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN2',FND_API.G_MISS_CHAR);
            END IF;

            IF (l_msg_token3 IS NOT NULL) THEN
	         fnd_message.set_token('PATC_MSG_TOKEN3',l_msg_token3);
            ELSE
	          fnd_message.set_token('PATC_MSG_TOKEN3',FND_API.G_MISS_CHAR);
            END IF;

        l_message_text := Fnd_Message.get;
	X_Error_Code := l_message_text;
*/

        RETURN(FALSE);
      END IF;
    END IF;   -- Validate PA IF project related and not called from import

   -- If the distribution will be project related and the project comes from
   -- the invoice line and this process is called from the import, use the
   -- account from the invoice line which has already been overlayed in the
   -- import. Otherwise, use the account from the distribution set line and
   -- overlay as per need be.
   --bug 2938770 For prepayment
   --bug 7483050 added condition to check if dist set is null
  IF (l_invoice_type_lookup_code = 'PREPAYMENT' and l_dset_line_ccid is null) then
       X_dist_tab(i).dist_ccid := l_prepay_dist_code_ccid;

  ElSIF (X_dist_tab(i).project_id IS NOT NULL AND
        l_dset_line_project_id IS NULL AND
        nvl(X_line_source, 'OTHER') = 'IMPORT') THEN
     X_dist_tab(i).dist_ccid := X_invoice_lines_rec.default_dist_ccid;
      BEGIN
        SELECT account_type
          INTO l_account_type
          FROM gl_code_combinations
         WHERE code_combination_id = X_invoice_lines_rec.default_dist_ccid;

      EXCEPTION
        WHEN no_data_found THEN
          CLOSE dist_set_lines_cur;
          Debug_info := debug_info || ': cannot read account type information';
          X_debug_context := current_calling_sequence;
          X_debug_info := debug_info;
          IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_lines_Rec.invoice_id)
                ||', Invoice Line Number = '||TO_CHAR(X_invoice_lines_Rec.line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
          X_error_code := 'AP_DEBUG';
          RETURN(FALSE);
      END;

   ELSE -- project information comes from distribution set line or at least
        -- is not from IMPORT
     X_dist_tab(i).dist_ccid := l_dset_line_ccid;
     IF ((X_dist_tab(i).project_id is not null AND
          l_pa_allows_overrides = 'N')) then
       IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(
                         l_dset_line_ccid,
                         X_chart_of_accounts_id,
                         X_invoice_lines_rec.accounting_date,
                         current_calling_sequence))) then
         X_error_code := 'AP_INVALID_CCID';
         CLOSE dist_set_lines_cur;
         RETURN(FALSE);
       END IF;

     ELSE  -- project allows overrides
       IF (X_invoice_lines_rec.overlay_dist_code_concat is NULL AND
           X_invoice_lines_rec.balancing_segment is NULL AND
           X_invoice_lines_rec.account_segment is NULL AND
            X_invoice_lines_rec.cost_center_segment is NULL) then
          IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(
                               l_dset_line_ccid,
                               X_chart_of_accounts_id,
                               X_invoice_lines_rec.accounting_date,
                               current_calling_sequence))) then
            X_error_code := 'AP_INVALID_CCID';
            CLOSE DIST_SET_LINES_CUR;
            RETURN(FALSE);
          END IF;
       ELSE -- account overlay information is provided at the line
          IF ( NOT (AP_UTILITIES_PKG.OVERLAY_SEGMENTS (
                       X_invoice_lines_rec.balancing_segment,
                       X_invoice_lines_rec.cost_center_segment,
                       X_invoice_lines_rec.account_segment,
                       X_invoice_lines_rec.overlay_dist_code_concat,
                       l_dset_line_ccid,
                       X_invoice_lines_rec.set_of_books_id,
                       'CREATE_COMB_NO_AT',
                       l_unbuilt_flex,
                       l_reason_unbuilt_flex,
                       FND_GLOBAL.RESP_APPL_ID,
                       FND_GLOBAL.RESP_ID,
                       FND_GLOBAL.USER_ID,
                       current_calling_sequence))) then
            X_error_code := 'AP_ACCOUNT_OVERLAY_INVALID';
            CLOSE dist_set_lines_cur;
            RETURN(FALSE);

          ELSE -- overlay segments did not fail
            X_dist_tab(i).dist_ccid := l_dset_line_ccid;
            debug_info := 'Get account type from overlayed account';
            BEGIN
              SELECT account_type
                INTO l_account_type
                FROM gl_code_combinations
               WHERE code_combination_id = l_dset_line_ccid;

            EXCEPTION
              WHEN no_data_found then
                CLOSE dist_set_lines_cur;
                Debug_info := debug_info
                              || ': cannot read account type information';
                X_debug_context := current_calling_sequence;
                X_debug_info := debug_info;
                IF (SQLCODE <> -20001) THEN
                  FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
                  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
                  FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
                  FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_lines_Rec.invoice_id)
                ||', Invoice Line Number = '||TO_CHAR(X_invoice_lines_Rec.line_Number));
                  FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
				  --Bug7539216
				  X_error_code := FND_MESSAGE.GET;
				ELSE
				  X_error_code := 'AP_DEBUG';
				  --End of Bug7539216
                END IF;
                RETURN(FALSE);
            END;
          END IF; -- overlay segments did not fail
        END IF; -- account overlay information is not null
      END IF; -- project allow overrides
    END IF; -- project information comes from distribution set line or
            -- at least is not from IMPORT

   IF (l_account_type = 'A' OR
        (l_account_type = 'E' AND
         X_invoice_lines_rec.assets_tracking_flag = 'Y')) THEN
       X_dist_tab(i).assets_tracking_flag := 'Y';
       X_dist_tab(i).asset_book_type_code :=
                     X_invoice_lines_rec.asset_book_type_code;
       X_dist_tab(i).asset_category_id :=
                     X_invoice_lines_rec.asset_category_id;
    ELSE
       X_dist_tab(i).assets_tracking_flag := 'N';
       X_dist_tab(i).asset_book_type_code := NULL;
       X_dist_tab(i).asset_category_id := NULL;
    END IF;


    --Perform Grant information validation

    IF  (X_invoice_lines_rec.award_id IS NOT NULL) THEN

         X_dist_tab(i).award_id := X_invoice_lines_rec.award_id;

    ELSIF (l_dset_line_award_id is not null) THEN

	   X_dist_tab(i).award_id := gms_ap_api.get_distribution_award(l_dset_line_award_id);

	   GMS_AP_API.validate_transaction
              (x_project_id		=> l_dset_line_project_id,
	       x_task_id       		=> l_dset_line_task_id,
	       x_award_id      		=> l_dset_line_award_id,
	       x_expenditure_type	=> l_dset_line_expenditure_type,
 	       x_expenditure_item_date 	=> x_dist_tab(i).expenditure_item_date,
	       x_calling_sequence 	=> current_calling_sequence,
	       x_msg_application  	=> l_msg_application,
	       x_msg_type         	=> l_msg_type,
	       x_msg_count        	=> l_msg_count,
   	       x_msg_data         	=> l_msg_data);

	   IF (l_msg_data IS NOT NULL) THEN
	       x_error_code := 'AP_INVALID_GRANT_INFO';
	       CLOSE dist_set_lines_cur;
	       X_msg_application := l_msg_application;
	       X_msg_data := l_msg_data;
	       RETURN(FALSE);
	   END IF;
    END IF;

    i := i + 1;

  END LOOP;
  CLOSE dist_set_lines_cur;

  --------------------------------------------------------------
  -- Step 3 -  If any rounding is required on the distribution
  -- amounts and the distribution to round is project related
  -- revalidate PA information.  Also, IF any rounding is
  -- required and we will generate distributions, THEN update
  -- the plsql distributions table.
  -- bug6653070
  --------------------------------------------------------------

  IF (l_dist_set_percent_number = 100) THEN
    IF (l_running_total_amount <> (X_invoice_lines_rec.amount) ) THEN
      X_dist_tab(l_max_i).amount :=
        X_dist_tab(l_max_i).amount + ((X_invoice_lines_rec.amount)
              -  l_running_total_amount);
      l_running_total_base_amt :=
        l_running_total_base_amt - X_dist_tab(l_max_i).base_amount;
      X_dist_tab(l_max_i).base_amount :=
         AP_UTILITIES_PKG.Ap_Round_Currency(
           NVL(X_dist_tab(l_max_i).amount, 0) * X_exchange_rate ,
           X_base_currency);
      l_running_total_base_amt :=
        l_running_total_base_amt + X_dist_tab(l_max_i).base_amount;
      l_rounding_exists := 'Y';
    END IF;
    IF (nvl(l_running_total_base_amt, 0) <>
        nvl(X_invoice_lines_rec.base_amount, 0)) THEN
      X_dist_tab(l_max_i).rounding_amt := X_invoice_lines_rec.base_amount -
                                          l_running_total_base_amt;
      X_dist_tab(l_max_i).base_amount := X_dist_tab(l_max_i).base_amount +
                                         X_dist_tab(l_max_i).rounding_amt;
      l_rounding_exists := 'Y';
    END IF;
    IF (nvl(l_running_total_pa_quantity, 0) <>
        nvl(X_invoice_lines_rec.pa_quantity, 0)) THEN
      X_dist_tab(l_max_pa_qty_i).pa_quantity :=
         X_dist_tab(l_max_pa_qty_i).pa_quantity +
       X_invoice_lines_rec.pa_quantity - l_running_total_pa_quantity;
      l_rounding_pa_qty_exists := 'Y';
     END IF;
  END IF;  -- total percent is 100
  IF (X_dist_tab(l_max_i).project_id IS NOT NULL AND
      l_rounding_exists = 'Y') THEN

    --bugfix:5725904
    If (l_invoice_type_lookup_code ='EXPENSE REPORT') Then
         l_sys_link_function :='ER' ;
    Else
         l_sys_link_function :='VI' ;
    End if;


    PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
        X_PROJECT_ID          => X_dist_tab(l_max_i).project_id,
        X_TASK_ID             => X_dist_tab(l_max_i).task_id,
        X_EI_DATE             => X_dist_tab(l_max_i).expenditure_item_date,
        X_EXPENDITURE_TYPE    => X_dist_tab(l_max_i).expenditure_type,
        X_NON_LABOR_RESOURCE  => null,
        X_PERSON_ID           => l_employee_id,
        X_QUANTITY            => nvl(X_dist_tab(l_max_i).pa_quantity, '1'),
        X_denom_currency_code => X_invoice_currency,
        X_acct_currency_code  => X_base_currency,
        X_denom_raw_cost      => X_dist_tab(l_max_i).amount,
        X_acct_raw_cost       => X_dist_tab(l_max_i).base_amount,
        X_acct_rate_type      => X_exchange_rate_type,
        X_acct_rate_date      => X_exchange_date,
        X_acct_exchange_rate  => X_exchange_rate,
        X_TRANSFER_EI         => null,
        X_INCURRED_BY_ORG_ID => X_dist_tab(l_max_i).expenditure_organization_id,
        X_NL_RESOURCE_ORG_ID  => null,
        X_TRANSACTION_SOURCE  => l_sys_link_function,
        X_CALLING_MODULE      => 'apinlinb.pls',
        X_VENDOR_ID           => X_vendor_id,
        X_ENTERED_BY_USER_ID  => user_id,
        X_ATTRIBUTE_CATEGORY  => X_dist_tab(l_max_i).attribute_category,
        X_ATTRIBUTE1          => X_dist_tab(l_max_i).attribute1,
        X_ATTRIBUTE2          => X_dist_tab(l_max_i).attribute2,
        X_ATTRIBUTE3          => X_dist_tab(l_max_i).attribute3,
        X_ATTRIBUTE4          => X_dist_tab(l_max_i).attribute4,
        X_ATTRIBUTE5          => X_dist_tab(l_max_i).attribute5,
        X_ATTRIBUTE6          => X_dist_tab(l_max_i).attribute6,
        X_ATTRIBUTE7          => X_dist_tab(l_max_i).attribute7,
        X_ATTRIBUTE8          => X_dist_tab(l_max_i).attribute8,
        X_ATTRIBUTE9          => X_dist_tab(l_max_i).attribute9,
        X_ATTRIBUTE10         => X_dist_tab(l_max_i).attribute10,
        X_ATTRIBUTE11         => X_dist_tab(l_max_i).attribute11,
        X_ATTRIBUTE12         => X_dist_tab(l_max_i).attribute12,
        X_ATTRIBUTE13         => X_dist_tab(l_max_i).attribute13,
        X_ATTRIBUTE14         => X_dist_tab(l_max_i).attribute14,
        X_ATTRIBUTE15         => X_dist_tab(l_max_i).attribute15,
        X_msg_application     => l_msg_application,
        X_msg_type            => l_msg_type,
        X_msg_token1          => l_msg_token1,
        X_msg_token2          => l_msg_token2,
        X_msg_token3          => l_msg_token3,
        X_msg_count           => l_msg_count,
        X_msg_data            => l_msg_data,
        X_BILLABLE_FLAG       => l_billable_flag);

    IF (l_msg_data is not null) then

        --Bug 7490877 Converting PA error code to AP error code
        x_error_code := 'AP'||substr(l_msg_data,3);

        --Bug 7490877 Commented below code
/*

      X_msg_application := l_msg_application;
      X_msg_data := l_msg_data;

      --bugfix:5725904
      Fnd_Message.Set_Name(l_msg_application, l_msg_data);
      --bug 6682104 setting the token values
            IF (l_msg_token1 IS NOT NULL) THEN
	       fnd_message.set_token('PATC_MSG_TOKEN1',l_msg_token1);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN1',FND_API.G_MISS_CHAR);
	    END IF;

            IF (l_msg_token2 IS NOT NULL) THEN
	        fnd_message.set_token('PATC_MSG_TOKEN2',l_msg_token2);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN2',FND_API.G_MISS_CHAR);
            END IF;

            IF (l_msg_token3 IS NOT NULL) THEN
	         fnd_message.set_token('PATC_MSG_TOKEN3',l_msg_token3);
            ELSE
	          fnd_message.set_token('PATC_MSG_TOKEN3',FND_API.G_MISS_CHAR);
            END IF;
      l_message_text := Fnd_Message.get;
      x_error_code := l_message_text;
*/

      RETURN(FALSE);
    END IF;
  END IF;       -- project id is not null and there was rounding
  IF ((X_dist_tab(l_max_pa_qty_i).project_id IS NOT NULL) AND
      l_rounding_pa_qty_exists = 'Y' AND
      (l_rounding_exists <> 'Y' OR
       (l_rounding_exists = 'Y' AND
        l_max_i <> l_max_pa_qty_i))) THEN

    --bugfix:5725904
    If (l_invoice_type_lookup_code ='EXPENSE REPORT') Then
        l_sys_link_function :='ER' ;
    Else
        l_sys_link_function :='VI' ;
    End if;


    PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
        X_PROJECT_ID          => X_dist_tab(l_max_pa_qty_i).project_id,
        X_TASK_ID             => X_dist_tab(l_max_pa_qty_i).task_id,
        X_EI_DATE           => X_dist_tab(l_max_pa_qty_i).expenditure_item_date,
        X_EXPENDITURE_TYPE    => X_dist_tab(l_max_pa_qty_i).expenditure_type,
        X_NON_LABOR_RESOURCE  => null,
        X_PERSON_ID           => l_employee_id,
        X_QUANTITY          => nvl(X_dist_tab(l_max_pa_qty_i).pa_quantity, '1'),
        X_denom_currency_code => X_invoice_currency,
        X_acct_currency_code  => X_base_currency,
        X_denom_raw_cost      => X_dist_tab(l_max_pa_qty_i).amount,
        X_acct_raw_cost       => X_dist_tab(l_max_pa_qty_i).base_amount,
        X_acct_rate_type      => X_exchange_rate_type,
        X_acct_rate_date      => X_exchange_date,
        X_acct_exchange_rate  => X_exchange_rate,
        X_TRANSFER_EI         => null,
        X_INCURRED_BY_ORG_ID  =>
             X_dist_tab(l_max_pa_qty_i).expenditure_organization_id,
        X_NL_RESOURCE_ORG_ID  => null,
        X_TRANSACTION_SOURCE  => l_sys_link_function, --5725904
        X_CALLING_MODULE      => 'apinlinb.pls',
        X_VENDOR_ID           => X_vendor_id,
        X_ENTERED_BY_USER_ID  => user_id,
        X_ATTRIBUTE_CATEGORY  => X_dist_tab(l_max_pa_qty_i).attribute_category,
        X_ATTRIBUTE1          => X_dist_tab(l_max_pa_qty_i).attribute1,
        X_ATTRIBUTE2          => X_dist_tab(l_max_pa_qty_i).attribute2,
        X_ATTRIBUTE3          => X_dist_tab(l_max_pa_qty_i).attribute3,
        X_ATTRIBUTE4          => X_dist_tab(l_max_pa_qty_i).attribute4,
        X_ATTRIBUTE5          => X_dist_tab(l_max_pa_qty_i).attribute5,
        X_ATTRIBUTE6          => X_dist_tab(l_max_pa_qty_i).attribute6,
        X_ATTRIBUTE7          => X_dist_tab(l_max_pa_qty_i).attribute7,
        X_ATTRIBUTE8          => X_dist_tab(l_max_pa_qty_i).attribute8,
        X_ATTRIBUTE9          => X_dist_tab(l_max_pa_qty_i).attribute9,
        X_ATTRIBUTE10         => X_dist_tab(l_max_pa_qty_i).attribute10,
        X_ATTRIBUTE11         => X_dist_tab(l_max_pa_qty_i).attribute11,
        X_ATTRIBUTE12         => X_dist_tab(l_max_pa_qty_i).attribute12,
        X_ATTRIBUTE13         => X_dist_tab(l_max_pa_qty_i).attribute13,
        X_ATTRIBUTE14         => X_dist_tab(l_max_pa_qty_i).attribute14,
        X_ATTRIBUTE15         => X_dist_tab(l_max_pa_qty_i).attribute15,
        X_msg_application     => l_msg_application,
        X_msg_type            => l_msg_type,
        X_msg_token1          => l_msg_token1,
        X_msg_token2          => l_msg_token2,
        X_msg_token3          => l_msg_token3,
        X_msg_count           => l_msg_count,
        X_msg_data            => l_msg_data,
        X_BILLABLE_FLAG       => l_billable_flag);

    IF (l_msg_data is not null) then
        --Bug 7490877 Converting PA error code to AP error code
        x_error_code := 'AP'||substr(l_msg_data,3);

        --Bug 7490877 Commented below code
/*

      X_msg_application := l_msg_application;
      X_msg_data := l_msg_data;

      --bugfix:5725904
      Fnd_Message.Set_Name(l_msg_application, l_msg_data);
      --bug 6682104 setting the token values
            IF (l_msg_token1 IS NOT NULL) THEN
	       fnd_message.set_token('PATC_MSG_TOKEN1',l_msg_token1);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN1',FND_API.G_MISS_CHAR);
	    END IF;

            IF (l_msg_token2 IS NOT NULL) THEN
	        fnd_message.set_token('PATC_MSG_TOKEN2',l_msg_token2);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN2',FND_API.G_MISS_CHAR);
            END IF;

            IF (l_msg_token3 IS NOT NULL) THEN
	         fnd_message.set_token('PATC_MSG_TOKEN3',l_msg_token3);
            ELSE
	          fnd_message.set_token('PATC_MSG_TOKEN3',FND_API.G_MISS_CHAR);
            END IF;
      l_message_text := Fnd_Message.get;
      x_error_code := l_message_text;
*/

      RETURN(FALSE);
    END IF;
  END IF; -- Rounding of pa qty existed and it is for a different dist
          -- than rounding of amount IF any.

  IF (X_dist_tab(l_max_i).award_id IS NOT NULL AND
      l_rounding_exists = 'Y') THEN

      GMS_AP_API.validate_transaction
              ( x_project_id		=> x_dist_tab(l_max_i).project_id,
		x_task_id       	=> x_dist_tab(l_max_i).task_id,
		x_award_id      	=> x_dist_tab(l_max_i).award_id,
		x_expenditure_type	=> x_dist_tab(l_max_i).expenditure_type,
		x_expenditure_item_date => x_dist_tab(l_max_i).expenditure_item_date,
		x_calling_sequence	=> 'AWARD_ID',
		x_msg_application	=> l_msg_application,
		x_msg_type		=> l_msg_type,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data ) ;

      IF (l_msg_data is not null) then
            x_error_code := 'AP_INVALID_GRANT_INFO';
	    x_msg_application := l_msg_application;
      	    x_msg_data	      := l_msg_data;
            RETURN(FALSE);
      END IF;
  END IF;

  IF ((X_dist_tab(l_max_pa_qty_i).award_id IS NOT NULL) AND
      l_rounding_pa_qty_exists = 'Y' AND
      (l_rounding_exists <> 'Y' OR
       (l_rounding_exists = 'Y' AND
        l_max_i <> l_max_pa_qty_i))) THEN

       GMS_AP_API.validate_transaction
		( x_project_id		  => X_dist_tab(l_max_pa_qty_i).project_id,
		  x_task_id		  => X_dist_tab(l_max_pa_qty_i).task_id,
		  x_award_id		  => X_dist_tab(l_max_pa_qty_i).award_id,
		  x_expenditure_type	  => X_dist_tab(l_max_pa_qty_i).expenditure_type,
 		  x_expenditure_item_date => X_dist_tab(l_max_pa_qty_i).expenditure_item_date,
		  x_calling_sequence	  => 'AWARD_ID',
		  x_msg_application       => l_msg_application,
		  x_msg_type              => l_msg_type,
		  x_msg_count             => l_msg_count,
		  x_msg_data              => l_msg_data );

       IF (l_msg_data is not null) then
	   x_msg_application := l_msg_application;
	   x_msg_data	     := l_msg_data;
	   RETURN(FALSE);
       END IF;
  END IF;

  RETURN(TRUE);

EXCEPTION
   WHEN OTHERS THEN
     Debug_info := 'Error occurred';
     X_debug_context := current_calling_sequence;
     X_debug_info := debug_info;
     IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_lines_Rec.invoice_id)
          ||', Invoice Line Number =
'||TO_CHAR(X_invoice_lines_Rec.line_Number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
     END IF;
     X_error_code := 'AP_DEBUG';
     RETURN(FALSE);

END generate_dist_tab_for_dist_set;

-----------------------------------------------------------------------
--  FUNCTION insert_from_dist_set validates the distribution_set info
--  and generates distributions
--  by calling ap_invoice_distributions_pkg.insert_from_dist_set.
--
FUNCTION Insert_From_Dist_Set(
              X_invoice_id          IN         NUMBER,
              X_line_number         IN         NUMBER DEFAULT NULL,
              X_GL_Date             IN         DATE,
              X_Period_Name         IN         VARCHAR2,
              X_Skeleton_Allowed    IN         VARCHAR2 DEFAULT 'N',
              X_Generate_Dists      IN         VARCHAR2 DEFAULT 'Y',
              X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
              X_Error_Code          OUT NOCOPY VARCHAR2,
              X_Debug_Info          OUT NOCOPY VARCHAR2,
              X_Debug_Context       OUT NOCOPY VARCHAR2,
              X_Msg_Application     OUT NOCOPY VARCHAR2,
              X_Msg_Data            OUT NOCOPY VARCHAR2,
              X_calling_sequence    IN         VARCHAR2) RETURN BOOLEAN

IS
  CURSOR line_rec(X_line_number NUMBER) IS
  SELECT invoice_id,
        line_number,
        line_type_lookup_code,
        requester_id,
        description,
        line_source,
        org_id,
        line_group_number,
        inventory_item_id,
        item_description,
        serial_number,
        manufacturer,
        model_number,
        warranty_number,
        generate_dists,
        match_type,
        distribution_set_id,
        account_segment,
        balancing_segment,
        cost_center_segment,
        overlay_dist_code_concat,
        default_dist_ccid,
        prorate_across_all_items,
        accounting_date,
        period_name,
        deferred_acctg_flag,
        def_acctg_start_date,
        def_acctg_end_date,
        def_acctg_number_of_periods,
        def_acctg_period_type,
        set_of_books_id,
        amount,
        base_amount,
        rounding_amt,
        quantity_invoiced,
        unit_meas_lookup_code,
        unit_price,
        wfapproval_status,
        discarded_flag,
        original_amount,
        original_base_amount,
        original_rounding_amt,
        cancelled_flag,
        income_tax_region,
        type_1099,
        stat_amount,
        prepay_invoice_id,
        prepay_line_number,
        invoice_includes_prepay_flag,
        corrected_inv_id,
        corrected_line_number,
        po_header_id,
        po_line_id,
        po_release_id,
        po_line_location_id,
        po_distribution_id,
        rcv_transaction_id,
        final_match_flag,
        assets_tracking_flag,
        asset_book_type_code,
        asset_category_id,
        project_id,
        task_id,
        expenditure_type,
        expenditure_item_date,
        expenditure_organization_id,
        pa_quantity,
        pa_cc_ar_invoice_id,
        pa_cc_ar_invoice_line_num ,
        pa_cc_processed_code,
        award_id,
        awt_group_id,
        reference_1,
        reference_2,
        receipt_verified_flag,
        receipt_required_flag,
        receipt_missing_flag,
        justification,
        expense_group,
        start_expense_date,
        end_expense_date,
        receipt_currency_code,
        receipt_conversion_rate,
        receipt_currency_amount,
        daily_amount,
        web_parameter_id,
        adjustment_reason,
        merchant_document_number,
        merchant_name,
        merchant_reference,
        merchant_tax_reg_number,
        merchant_taxpayer_id,
        country_of_supply,
        credit_card_trx_id,
        company_prepaid_invoice_id,
        cc_reversal_flag,
        creation_date,
        created_by,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
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
	--ETAX: Invwkb
	included_tax_amount,
	primary_intended_use,
	--Bugfix:4673607
	application_id,
	product_table,
	reference_key1,
	reference_key2,
	reference_key3,
	reference_key4,
	reference_key5,
	--bugfix:4674194
	ship_to_location_id,
	--bugfix:7022001
	pay_awt_group_id
   FROM AP_INVOICE_LINES
  WHERE invoice_id = X_invoice_id
    AND line_number = X_line_number;


  --ETAX: Invwkb
  CURSOR Invoice_Rec IS
  SELECT *
  FROM AP_INVOICES
  WHERE invoice_id = x_invoice_id;

l_chart_of_accounts_id         GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
l_set_of_books_id              GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE;
l_base_currency_code           AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;

l_invoice_line_rec             AP_INVOICES_PKG.r_invoice_line_rec;

l_dist_set_percent_number      NUMBER := 0;
l_dist_set_description         AP_DISTRIBUTION_SETS.DESCRIPTION%TYPE;
l_dist_set_attribute_category  AP_DISTRIBUTION_SETS.ATTRIBUTE_CATEGORY%TYPE;
l_dist_set_attribute1          AP_DISTRIBUTION_SETS.ATTRIBUTE1%TYPE;
l_dist_set_attribute2          AP_DISTRIBUTION_SETS.ATTRIBUTE2%TYPE;
l_dist_set_attribute3          AP_DISTRIBUTION_SETS.ATTRIBUTE3%TYPE;
l_dist_set_attribute4          AP_DISTRIBUTION_SETS.ATTRIBUTE4%TYPE;
l_dist_set_attribute5          AP_DISTRIBUTION_SETS.ATTRIBUTE5%TYPE;
l_dist_set_attribute6          AP_DISTRIBUTION_SETS.ATTRIBUTE6%TYPE;
l_dist_set_attribute7          AP_DISTRIBUTION_SETS.ATTRIBUTE7%TYPE;
l_dist_set_attribute8          AP_DISTRIBUTION_SETS.ATTRIBUTE8%TYPE;
l_dist_set_attribute9          AP_DISTRIBUTION_SETS.ATTRIBUTE9%TYPE;
l_dist_set_attribute10         AP_DISTRIBUTION_SETS.ATTRIBUTE10%TYPE;
l_dist_set_attribute11         AP_DISTRIBUTION_SETS.ATTRIBUTE11%TYPE;
l_dist_set_attribute12         AP_DISTRIBUTION_SETS.ATTRIBUTE12%TYPE;
l_dist_set_attribute13         AP_DISTRIBUTION_SETS.ATTRIBUTE13%TYPE;
l_dist_set_attribute14         AP_DISTRIBUTION_SETS.ATTRIBUTE14%TYPE;
l_dist_set_attribute15         AP_DISTRIBUTION_SETS.ATTRIBUTE15%TYPE;
l_inactive_date                AP_DISTRIBUTION_SETS.INACTIVE_DATE%TYPE;
l_batch_id                     AP_INVOICES.BATCH_ID%TYPE;
l_vendor_id                    AP_INVOICES.VENDOR_ID%TYPE;
l_vendor_site_id               AP_INVOICES.VENDOR_SITE_ID%TYPE;
l_invoice_date                 AP_INVOICES.INVOICE_DATE%TYPE;
l_exchange_rate                AP_INVOICES.EXCHANGE_RATE%TYPE;
l_exchange_date                AP_INVOICES.EXCHANGE_DATE%TYPE;
l_exchange_rate_type           AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE;
l_invoice_currency_code        AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
l_msg_application              VARCHAR2(25);
l_msg_count                    NUMBER;
l_msg_data                     VARCHAR2(30);
l_error_code                   VARCHAR2(4000);  --Bug7539216

y_dist_tab                     AP_INVOICE_LINES_PKG.dist_tab_type;

current_calling_sequence       VARCHAR2(1000);
debug_info                     VARCHAR2(2000);
debug_context                  VARCHAR2(1000);
l_error_found                  VARCHAR2(1);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'AP_INVOICE_LINES_PKG.insert_from_dist_set<-'
                               ||X_calling_sequence;
  --------------------------------------------------------------
  -- Step 1 - Validate that distribution set was passed or
  -- get it from the line IF line already exists.
  -- If line already exists, THEN use this chance to read other
  -- Line related data we will need (performance).
  -- If a distribution set is not found, or IF inconsistent
  -- information was provided THEN exit the FUNCTION and
  -- RETURN false.
  --------------------------------------------------------------
  debug_info := 'Verify distribution set information available';
  IF (X_line_number IS NULL) THEN
    debug_info := debug_info ||': No Line Info is provided';
    X_debug_context := current_calling_sequence;
    X_debug_info := debug_info;
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_Number));
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
    X_error_code := 'AP_DEBUG';
    RETURN(FALSE);
  ELSE
    BEGIN
      OPEN line_rec(x_line_number);
      FETCH line_rec INTO l_invoice_line_rec;
      IF (line_rec%NOTFOUND) THEN
        CLOSE line_rec;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE line_Rec;

    EXCEPTION
    WHEN no_data_found THEN
      debug_info := debug_info ||': No valid line record was found.';
      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_Number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
     END IF;
     X_error_code := 'AP_DEBUG';
     RETURN(FALSE);
    END;

  END IF; -- Line NUMBER is null

  --------------------------------------------------------------
  -- Step 2 - Now that we have the distribution set, obtain
  -- information required for validation and defaulting.
  -- Also verify that the distribution set is not inactive.
  --------------------------------------------------------------
  debug_info := 'Get total percent for distribution set';
  BEGIN
    SELECT total_percent_distribution,
           description,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           inactive_date
      INTO l_dist_set_percent_number,
           l_dist_set_description,
           l_dist_set_attribute_category,
           l_dist_set_attribute1,
           l_dist_set_attribute2,
           l_dist_set_attribute3,
           l_dist_set_attribute4,
           l_dist_set_attribute5,
           l_dist_set_attribute6,
           l_dist_set_attribute7,
           l_dist_set_attribute8,
           l_dist_set_attribute9,
           l_dist_set_attribute10,
           l_dist_set_attribute11,
           l_dist_set_attribute12,
           l_dist_set_attribute13,
           l_dist_set_attribute14,
           l_dist_set_attribute15,
           l_inactive_date
      FROM ap_distribution_sets
     WHERE distribution_set_id = l_invoice_line_rec.distribution_set_id;

     IF (nvl(l_inactive_date, trunc(sysdate) + 1) <= trunc(sysdate)) THEN
       X_error_code := 'AP_VEN_DIST_SET_INVALID';
       RETURN(FALSE);
     END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Debug_info := debug_info || ': Cannot read Dist Set';
    X_debug_context := current_calling_sequence;
    X_debug_info := debug_info;
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_Number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
    END IF;
    X_error_code := 'AP_DEBUG';
    RETURN(FALSE);
  END;

  --------------------------------------------------------------
  -- Step 3 - Validate that IF the calling module requested not
  -- to allow skeleton distribution sets e.g. when validation
  -- is calling to generate distributions i.e. user intervention
  -- won't be possible, THEN verify that the total percent for the
  -- distribution set is 100.
  -- For these known checks we RETURN specific error codes.
  --------------------------------------------------------------

  /* Bug 4928285. There is no need for this check since we should be
     able to create distributions using skeleton distribution set
  IF (X_Skeleton_Allowed = 'N' AND
           l_dist_set_percent_number <> 100) then
    X_error_code := 'AP_CANT_USE_SKELETON_DIST_SET';
    RETURN(FALSE);
  END IF;
  */

  --------------------------------------------------------------
  -- Step 4 - Obtain information from the invoice header that would
  -- be necessary to validate that generation of distributions
  -- is possible and to create the line IF one does not
  -- exist already.
  -----------------------------------------------------------------
  debug_info := 'Select header, vendor information and amount to distribute';
  BEGIN
      SELECT AI.batch_id,
             AI.vendor_id,
             AI.vendor_site_id,
             AI.invoice_date,
             AI.exchange_rate,
             AI.exchange_date,
             AI.exchange_rate_type,
             AI.invoice_currency_code,
             AI.set_of_books_id
        INTO l_batch_id,
             l_vendor_id,
             l_vendor_site_id,
             l_invoice_date,
             l_exchange_rate,
             l_exchange_date,
             l_exchange_rate_type,
             l_invoice_currency_code,
             l_set_of_books_id
       FROM  ap_invoices AI
       WHERE invoice_id = X_invoice_id;

  EXCEPTION
    When no_data_found then
      Debug_info := debug_info || ': cannot read invoice information';
      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_Number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN(FALSE);

  END;

  --------------------------------------------------------------
  -- Step 5 - Get system level information necessary for
  -- validation and generation of lines.
  --------------------------------------------------------------
  debug_info := 'Get system information';

  BEGIN
    -- get chart_of_accounts_id from ap_system_parameters
    SELECT gsob.chart_of_accounts_id,
           ap.base_currency_code
      INTO l_chart_of_accounts_id,
           l_base_currency_code
      FROM ap_system_parameters ap, gl_sets_of_books gsob
     WHERE ap.set_of_books_id = gsob.set_of_books_id
       AND ap.set_of_books_id = l_set_of_books_id
       AND ap.org_id = l_invoice_line_rec.org_id;

  EXCEPTION
  WHEN no_data_found THEN
    Debug_info := debug_info || ': No GL information was found';
    X_debug_context := current_calling_sequence;
    X_debug_info := debug_info;
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_Number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
     END IF;
     X_error_code := 'AP_DEBUG';
    RETURN(FALSE);
  END;

  --------------------------------------------------------------
  -- Step 6: Set the gl_date and period_name to the
  -- parameters, since they will be used by the FUNCTION to generate
  -- distributions.
  --------------------------------------------------------------

  l_invoice_line_rec.accounting_date := X_GL_Date;
  l_invoice_line_rec.period_name := X_Period_Name;

 --------------------------------------------------------------
 -- Step 9 - Validate distribution level information including
 -- accounting and project level information.
 -- The call RETURNs a plsql table of distributions to be inserted
 -- later.  Note that IF this part fails, the entire trx should
 -- be rolled back to ensure roll back of the line creation.
  --------------------------------------------------------------
   debug_info := 'Calling generate_dist_tab_from_dist_set ';
  IF (NOT (Generate_Dist_Tab_For_Dist_Set(
             l_vendor_id,                   --  IN
             l_invoice_date,                --  IN
             l_invoice_line_rec,            --  IN
             null,                          --  IN
             y_dist_tab,                    --  IN
             l_dist_set_percent_number,     --  IN
             l_exchange_rate,               --  IN
             l_exchange_rate_type,          --  IN
             l_exchange_date ,              --  IN
             l_invoice_currency_code,       --  IN
             l_base_currency_code,          --  IN
             l_chart_of_accounts_id,        --  IN
             l_Error_Code,                  --     OUT NOCOPY VARCHAR2,
             Debug_Info,                    --     OUT NOCOPY VARCHAR2,
             Debug_Context,                 --     OUT NOCOPY VARCHAR2,
             l_msg_application,             --     OUT NOCOPY VARCHAR2,
             l_msg_data,                    --     OUT NOCOPY VARCHAR2,
             current_calling_sequence       --  IN            VARCHAR2,
             ))) then


    IF (l_error_code IS NOT NULL) THEN
      X_error_code := l_error_code;
      RETURN (FALSE);
    ELSIF (l_msg_data IS NOT NULL) THEN
      X_msg_application := l_msg_application;
      X_msg_data := l_msg_data;
      RETURN(FALSE);
    ELSE
      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
      RETURN (FALSE);
    END IF;
  END IF;


  --------------------------------------------------------------
  -- Step 11 - If the calling module requested generation of
  -- distributions call the appropriate FUNCTION to generate
  -- them.
  --------------------------------------------------------------
  IF (X_Generate_Dists = 'Y' ) then

     debug_info := 'Calling AP_INVOICE_DISTRIBUTIONS_PKG.Insert_From_Dist_Set';
    IF ( NOT (AP_INVOICE_DISTRIBUTIONS_PKG.Insert_From_Dist_Set(
               l_batch_id,
               X_invoice_id,
               X_line_number,
               y_dist_tab,
               X_Generate_Permanent,
--             l_error_code,
               debug_info,
               debug_context,
               current_calling_sequence))) then

     IF (l_error_code IS NOT NULL) THEN
        X_error_code := l_error_code;
        RETURN (FALSE);
      ELSE
        X_debug_context := current_calling_sequence;
        X_debug_info := debug_info;
        RETURN (FALSE);
      END IF;

  END IF;


  END IF; -- Generate dists

RETURN(TRUE);

 EXCEPTION
    WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
           'X_GL_Date = '            ||TO_CHAR(X_GL_Date)
           ||', X_Period_Name = '        ||X_Period_Name
           ||', X_Invoice_Id = '         ||TO_CHAR(X_invoice_id)
                                    );
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;

END insert_from_dist_set;

  -----------------------------------------------------------------------
  -- FUNCTION get_max_dist_line_num RETURNs the maximum distribution line
  -- NUMBER given an invoice and line, it RETURNs 0 IF no distributions exist.
  ----------------------------------------------------------------------
  FUNCTION Get_Max_Dist_Line_Num(
              X_invoice_id          IN      NUMBER,
              X_line_number         IN      NUMBER) RETURN NUMBER
  IS
    l_max_dist_line_num NUMBER := 0;
  BEGIN

    SELECT nvl(max(distribution_line_number),0)
      INTO l_max_dist_line_num
      FROM ap_invoice_distributions_all -- Bug 7195488 Moac synonym replaced
     WHERE invoice_id = X_invoice_id
       AND invoice_line_number = X_line_number;

    RETURN(l_max_dist_line_num);

  END get_max_dist_line_num;


 /*===========================================================================
 |  FUNCTION - ROUND_BASE_AMTS
 |
 |  DESCRIPTION
 |      RETURNs the rounded base amount IF there is any. it RETURNs FALSE if
 |      no rounding amount necessary, otherwise it RETURNs TRUE.
 |
 |  Business Assumption
 |      1. Called after all the base amount of each line is populated
 |      2. Same exchange rate for all the lines
 |      3. It will be called by Primary ledger (AP) or Reporting ledger (MRC)
 |
 |  PARAMETERS
 |      X_Invoice_Id - Invoice Id
 |      X_Line_Number - invoice line NUMBER
 |      X_Reporting_Ledger_Id - For ALC/MRC use only.
 |      X_ROUND_DIST_ID_LIST - distribution list that can be adjusted
 |      X_Rounded_Amt - rounded amount
 |      X_Debug_Info - debug information
 |      X_Debug_Context - error context
 |      X_Calling_Sequence - debug usage
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  19-MAY-2008  KPASIKAN           modified for the bug 6892789 to get the
 |                                  dists that can be adjusted
 *===========================================================================*/


FUNCTION round_base_amts(
                     X_INVOICE_ID          IN NUMBER,
                     X_LINE_NUMBER         IN NUMBER,
                     X_REPORTING_LEDGER_ID IN NUMBER DEFAULT NULL,
                     X_ROUND_DIST_ID_LIST  OUT NOCOPY distribution_id_tab_type,
                     X_ROUNDED_AMT         OUT NOCOPY NUMBER,
                     X_Debug_Info          OUT NOCOPY VARCHAR2,
                     X_Debug_Context       OUT NOCOPY VARCHAR2,
                     X_Calling_sequence    IN VARCHAR2)

 RETURN BOOLEAN IS
  l_rounded_amt             NUMBER := 0;
  l_round_dist_id_list      distribution_id_tab_type;
  l_base_currency_code      ap_system_parameters.base_currency_code%TYPE;
  l_line_base_amount        ap_invoice_lines.base_amount%TYPE;
  l_line_amount             ap_invoice_lines.amount%TYPE;
  l_invoice_currency_code   ap_invoices.invoice_currency_code%TYPE;
  l_reporting_currency_code ap_invoices.invoice_currency_code%TYPE;
  l_sum_base_amt            NUMBER;
  l_sum_rpt_base_amt        NUMBER;

  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

  cursor invoice_line_cursor is
      -- inv_line_base_amt/rpt_line_base_amt
    SELECT decode(x_reporting_ledger_id, null, AIL.base_amount, null),
           AIL.amount, -- line_amount
           AI.invoice_currency_code, -- invoice_currency_code
           ASP.base_currency_code -- base_currency_code
      FROM ap_invoices AI, ap_system_parameters ASP, ap_invoice_lines AIL
     WHERE AI.invoice_id = X_invoice_id
       AND AIL.invoice_id = AI.invoice_id
       AND AIL.line_number = X_line_number
       AND ASP.org_id = AI.org_id;
BEGIN

  current_calling_sequence := 'ROUND_BASE_AMTS - Round_Base_Amt for line';

  OPEN invoice_line_cursor;
  FETCH invoice_line_cursor
    INTO l_line_base_amount,
         l_line_amount,
         l_invoice_currency_code,
         l_base_currency_code;
  IF (invoice_line_cursor%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
    CLOSE invoice_line_cursor;
  END IF;
  CLOSE invoice_line_cursor;

  IF (X_Reporting_Ledger_Id IS NULL) THEN
    --------------------------------------------------------------------
    debug_info := 'Round_base_amt Case 1 - Rounding for primary ledger';
    --------------------------------------------------------------------

    IF (l_invoice_currency_code <> l_base_currency_code) THEN

      -- Bug 5469235: Added conditions to eliminate retainage
      --Bug 5555622  and recoupment, and the related tax distributions
      BEGIN
        SELECT SUM(base_amount)
          INTO l_sum_base_amt
          FROM ap_invoice_distributions AID
         WHERE AID.invoice_id = X_INVOICE_ID
           AND AID.invoice_line_number = X_LINE_NUMBER
           AND AID.line_type_lookup_code NOT IN ('RETAINAGE', 'PREPAY')
           AND AID.charge_applicable_to_dist_id NOT IN
               (SELECT AID1.invoice_distribution_id
                  FROM ap_invoice_distributions AID1
                 WHERE AID1.line_type_lookup_code IN ('RETAINAGE', 'PREPAY')
                   AND AID1.invoice_id = X_INVOICE_ID
                   AND AID1.invoice_line_number = X_LINE_NUMBER);

      END;

      l_rounded_amt := l_line_base_amount - l_sum_base_amt;
    ELSE
      ---------------------------------------------------------------------
      debug_info := 'Round_Base_Amt - same inv currency/base currency';
      ---------------------------------------------------------------------
      X_ROUNDED_AMT     := 0;
      X_ROUND_DIST_ID_LIST.delete;
      X_debug_context   := current_calling_sequence;
      X_debug_info      := debug_info;
      RETURN(FALSE);
    END IF; -- end of check currency for primary

  ELSE

    Null; -- Removed the code here due to MRC obsoletion.

  END IF; -- end of check x_reporting_ledger_id

  IF (l_rounded_amt <> 0) THEN
    ------------------------------------------------------------------------
    debug_info := 'Round_Base_Amt - round amt exists and find distribution';
    ------------------------------------------------------------------------
    BEGIN
      --bugfix:4625349
      SELECT invoice_distribution_id
        BULK COLLECT INTO l_round_dist_id_list
        FROM AP_INVOICE_DISTRIBUTIONS aid1
       WHERE aid1.invoice_id = X_INVOICE_ID
         AND aid1.invoice_line_number = X_LINE_NUMBER
         AND nvl(aid1.posted_flag, 'N') = 'N'
         AND NVL(aid1.match_status_flag, 'N') IN ('N', 'S')
         AND NVL(aid1.reversal_flag, 'N') = 'N' /* Bug 4121330 */
         AND LINE_TYPE_LOOKUP_CODE NOT IN ('NONREC_TAX','REC_TAX','TRV','TERV','TIPV') -- bug 9582952
       ORDER BY aid1.base_amount desc;
    END;

    X_ROUNDED_AMT     := l_rounded_amt;
    x_round_dist_id_list := l_round_dist_id_list;
    X_debug_context   := current_calling_sequence;
    X_debug_info      := debug_info;
    RETURN(TRUE);
  ELSE
    ---------------------------------------------------------------------
    debug_info := 'Round_Base_Amt - round_amt is 0 for diff currency';
    ---------------------------------------------------------------------

    X_ROUNDED_AMT     := 0;
    x_round_dist_id_list.delete;
    X_debug_context   := current_calling_sequence;
    X_debug_info      := debug_info;
    RETURN(FALSE);
  END IF; -- end of check l_rounded_amt

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            'Invoice Id = ' || TO_CHAR(X_Invoice_Id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
    END IF;
    debug_info      := debug_info || 'Error occurred';
    X_debug_context := current_calling_sequence;
    X_debug_info    := debug_info;
    RETURN(FALSE);
END round_base_amts;


/*=============================================================================
 |  public FUNCTION Discard_Inv_Line
 |
 |      Discard or cancel the invoice line depending on calling mode. If error
 |      occurs, it return FALSE and error code will be populated. Otherwise,
 |      It return TRUE.
 |
 |  Parameters
 |      P_line_rec - Invoice line record
 |      P_calling_mode - either from DISCARD, CANCEL or UNAPPLY_PREPAY
 |      p_inv_cancellable - 'Y' if invoice is canellable.
 |      P_last_updated_by
 |      P_last_update_login
 |      P_error_code - Error code indicates why it is not discardable
 |      P_calling_sequence - For debugging purpose
 |
 |  PROGRAM FLOW
 |
 |      1. check if line is discardable
 |      2. if line is discardable/cancellable and matched - reverse match
 |      3. reset the encumberance flag, create account event
 |      4. if there is an active distribution - reverse distribution
 |      5. populate the out message and set the return value
 |
 |  NOTES
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  03/07/03     sfeng                Created
 |
 *============================================================================*/

    Function Discard_Inv_Line(
               P_line_rec          IN  ap_invoice_lines%ROWTYPE,
               P_calling_mode      IN  VARCHAR2,
               P_inv_cancellable   IN  VARCHAR2 DEFAULT NULL,
               P_last_updated_by   IN  NUMBER,
               P_last_update_login IN  NUMBER,
               P_error_code        OUT NOCOPY VARCHAR2,
	       P_token		   OUT NOCOPY VARCHAR2,
               P_calling_sequence  IN  VARCHAR2) RETURN BOOLEAN
  IS
    TYPE r_global_attr_arr       IS VARRAY(1000) of VARCHAR2(150);
    l_ok_to_cancel               BOOLEAN := FALSE;
    l_ok_to_discard              BOOLEAN := FALSE;
    l_debug_info                 VARCHAR2(4000);
    l_curr_calling_sequence      VARCHAR2(4000);

    l_po_distribution_id
        ap_invoice_distributions.po_distribution_id%TYPE;

    l_distribution_count         NUMBER := 0;
    l_sum_matched_qty            NUMBER := 0;
    l_sum_matched_amt            NUMBER := 0;
    l_dist_type_lookup_code	 ap_invoice_distributions_all.line_type_lookup_code%TYPE;
    l_matching_basis		 po_line_locations_all.matching_basis%TYPE;
    i 				 NUMBER := 1;
    l_max_line_num
        ap_invoice_distributions.distribution_line_number%TYPE;
    l_matched_uom                VARCHAR2(30);
    l_key_value_list             ap_dbi_pkg.r_dbi_key_value_arr;
    l_key_value_list2            ap_dbi_pkg.r_dbi_key_value_arr;
    l_key_value_list3            ap_dbi_pkg.r_dbi_key_value_arr;
    l_global_attr_category       ap_invoice_distributions.global_attribute_category%TYPE;
    l_open_gl_date               DATE;
    l_result_string              VARCHAR2(4000);
    l_loop_counter               BINARY_INTEGER;
    l_awt_success                VARCHAR2(2000);

    l_invoice_validation_status  VARCHAR2(100);
    l_success			 BOOLEAN;
    l_error_code	         VARCHAR2(4000);
    l_invoice_type_lookup_code   AP_INVOICES_ALL.INVOICE_TYPE_LOOKUP_CODE%TYPE;
    l_payment_status_flag        AP_INVOICES_ALL.PAYMENT_STATUS_FLAG%TYPE;
    l_invoice_amount             AP_INVOICES_ALL.INVOICE_AMOUNT%TYPE;
    l_included_tax_amount	 AP_INVOICE_LINES_ALL.INCLUDED_TAX_AMOUNT%TYPE;
    l_tax_distribution_count     NUMBER;

    --Contract Payments
    l_prepay_dist_info           AP_PREPAY_PKG.prepay_dist_tab_type;
    l_dummy			 BOOLEAN;
    l_prepay_invoice_id		 NUMBER;
    l_prepay_line_number	 NUMBER;
    l_shipment_amt_billed	 NUMBER;
    l_shipment_qty_billed	 NUMBER;
    l_shipment_amt_recouped      NUMBER;
    l_shipment_qty_recouped 	 NUMBER;
    l_shipment_amt_retained	 NUMBER;
    l_shipment_amt_released	 NUMBER;
    l_shipment_amt_financed      NUMBER;
    l_shipment_qty_financed      NUMBER;
    l_po_ap_dist_rec             PO_AP_DIST_REC_TYPE;
    l_po_ap_line_loc_rec         PO_AP_LINE_LOC_REC_TYPE;
    l_api_name    		 VARCHAR2(50);
    l_return_status              VARCHAR2(4000);
    l_msg_data                   VARCHAR2(4000);
    l_prepay_tax_dists_count     NUMBER;

    l_manual_tax_lines       NUMBER; --Bug9133464
    prob_dist_list               VARCHAR2(1000):=NULL; --9100425
    prob_dist_count              NUMBER :=0;           --9100425
    l_cancel_proactive_flag      varchar2(1);          --9100425

    -------------------------------------------------------------
    -- Query trying to find the total qty_invoiced by this inv
    -- line for one or more po_distributions. Only the base match
    -- and the corrections trying to correct this invoice will
    -- be considered. For PRICE CORRECTION, quantity_invoiced
    -- should not be included. For QUANTITY CORRECTION,
    -- corrected_quantity is populated and quantity_invoiced is null.
    -- Although at invoice line level, quantity_invoiced is always
    -- the same as corrected_quantity.
    -------------------------------------------------------------

    --Added below cursor for bug#8928639

    CURSOR prepay_inv_cur IS
     SELECT  distinct aid1.invoice_id,aid1.invoice_line_number
     FROM   ap_invoice_distributions_all AID,  --Inv dists
            ap_invoice_distributions_all AID1  --prepay dists
     WHERE  aid.invoice_id =  p_line_rec.invoice_id
      AND    aid.invoice_line_number = p_line_rec.line_number
      AND    aid1.invoice_distribution_id = aid.prepay_distribution_id;

    CURSOR po_dists_cur IS
    SELECT aid.po_distribution_id,
           aid.matched_uom_lookup_code,
           SUM( decode( AID.dist_match_type,
                        'PRICE_CORRECTION', 0,
                        'AMOUNT_CORRECTION', 0,           /* Amount Based Matching */
                        'ITEM_TO_SERVICE_PO', 0,
                        'ITEM_TO_SERVICE_RECEIPT', 0,
                        NVL( AID.corrected_quantity, 0) +
                        nvl( AID.quantity_invoiced,0 ) ) ) ,
           SUM(NVL(AID.amount, 0)) ,
	   aid.line_type_lookup_code,
	   pll.matching_basis,
	   aid1.invoice_id prepay_invoice_id,
	   aid1.invoice_line_number prepay_line_number
    FROM   ap_invoice_distributions_all AID ,
    	   po_line_locations pll,
	   ap_invoice_distributions_all AID1
    WHERE  aid.invoice_id = p_line_rec.invoice_id
    AND    aid.invoice_line_number = p_line_rec.line_number
    --Contract Payments: Added the 'PREPAY' to the clause
    AND    aid.line_type_lookup_code in ('ITEM','ACCRUAL', 'IPV','ERV','PREPAY','RETAINAGE')
    AND    pll.line_location_id = p_line_rec.po_line_location_id
    AND    aid1.invoice_distribution_id(+) = aid.prepay_distribution_id
    GROUP BY aid1.invoice_id,aid1.invoice_line_number,
          aid.line_type_lookup_code,aid.po_distribution_id,pll.matching_basis,aid.matched_uom_lookup_code;


    -- Bug 5114543
    -- Added to allow discard of invoice lines with allocated charges

    CURSOR c_charge_lines(c_invoice_id       number,
			  c_item_line_number number) Is
    SELECT  ail.*
      FROM  ap_allocation_rule_lines   arl
	   ,ap_invoice_lines_all       ail
     WHERE arl.invoice_id               = c_invoice_id
       AND arl.to_invoice_line_number   = c_item_line_number
       AND arl.invoice_id               = ail.invoice_id
       AND arl.chrg_invoice_line_number = ail.line_number
       AND exists
                (select aid.invoice_line_number
                   from ap_invoice_distributions_all aid
                  where aid.invoice_id          = ail.invoice_id
                    and aid.invoice_line_number = ail.line_number);

    l_chrg_line_rec	ap_invoice_lines_all%rowtype;

    -- Bug 5396138 Start
    cursor c_recouped_shipment IS
    select  pll.line_location_id
           ,aid.matched_uom_lookup_code
           ,sum(nvl(aid.amount,0)) amount
           ,sum(decode(AID.dist_match_type,
                          'PRICE_CORRECTION', 0,
                          'AMOUNT_CORRECTION', 0,
                          'ITEM_TO_SERVICE_PO', 0,
                          'ITEM_TO_SERVICE_RECEIPT', 0,
                          NVL(AID.corrected_quantity, 0) + NVL(AID.quantity_invoiced,0))) quantity
     from  ap_invoice_lines_all ail
          ,ap_invoice_distributions_all aid
          ,po_distributions_all pod
          ,po_line_locations_all pll
     where ail.invoice_id  = p_line_rec.invoice_id
       and ail.line_number = p_line_rec.line_number
       and ail.invoice_id = aid.invoice_id
       and ail.line_number = aid.invoice_line_number
       and ail.line_type_lookup_code IN ('ITEM', 'RETAINAGE RELEASE')
       and aid.line_type_lookup_code = 'PREPAY'
       and aid.po_distribution_id    = pod.po_distribution_id
       and pll.line_location_id      = pod.line_location_id
     group by pll.line_location_id, aid.matched_uom_lookup_code;

    l_recoup_dist_rec     PO_AP_DIST_REC_TYPE;
    l_recoup_line_loc_rec PO_AP_LINE_LOC_REC_TYPE;

    l_recouped_shipment   c_recouped_shipment%rowtype;
    -- Bug 5396138 End

    -- bug 5572121
    cursor dist_debug_cur is
    Select *
    FROM   ap_invoice_distributions_all aid
    WHERE  aid.invoice_id = p_line_rec.invoice_id;

    --bugfix:5638822
    l_recouped_amount ap_invoices_all.invoice_amount%type;
    l_amount_paid number;
    l_error_message varchar2(4000);
    l_payment_currency_code ap_invoices_all.payment_currency_code%TYPE;
    l_amount_remaining      number;

    --bugfix:5697764
    l_tax_line_number       number;
    l_unapplied_tax_amount  number;
    l_unapplied_tax_amt_pay_curr number;
    l_invoice_currency_code ap_invoices_all.invoice_currency_code%type;
    l_payment_cross_rate_date ap_invoices_all.payment_cross_rate_date%type;
    l_payment_cross_rate_type ap_invoices_all.payment_cross_rate_type%type;
    l_prepay_included	      ap_invoice_lines_all.invoice_includes_prepay_flag%type;

    --bug 8361741
    l_itm_dist_count         NUMBER;
    l_invoice_rec            AP_APPROVAL_PKG.Invoice_Rec;
    l_base_currency_code     AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;

    -- Bug 8623061 - Start
    l_award_id	 ap_invoice_distributions_all.award_id%TYPE;

    cursor c_distribution_list_cur is
    SELECT *
    FROM ap_invoice_distributions_all aid
    WHERE aid.parent_reversal_id IS NOT NULL
      AND aid.invoice_id = p_line_rec.invoice_id
      AND aid.invoice_line_number = p_line_rec.line_number
      AND aid.reversal_flag = 'Y'
      AND NOT EXISTS (
                      SELECT invoice_distribution_id
                      FROM gms_award_distributions gad
                      WHERE aid.invoice_distribution_id = gad.invoice_distribution_id
                     );
    -- Bug 8623061 - End

  BEGIN

    SAVEPOINT CANCEL_CHECK; --9100425
    fnd_profile.get('AP_ENHANCED_DEBUGGING',l_cancel_proactive_flag); --9100425

    l_shipment_amt_billed := 0;
    l_shipment_qty_billed := 0;
    l_shipment_amt_recouped  := 0;
    l_shipment_qty_recouped  := 0;
    l_shipment_amt_retained  := 0;
    l_shipment_amt_released  := 0;
    l_prepay_tax_dists_count := 0;
    l_shipment_amt_financed := 0;
    l_shipment_qty_financed := 0;

    l_api_name := 'Discard_Inv_Line';

    l_curr_calling_sequence := 'AP_INVOICE_LINES_PKG.Discard_Inv_Line <-' ||
                               P_calling_sequence;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_LINES_PKG.Discard_Inv_Line(+)');
    END IF;

    -- Added additional columns for bug 8361741
    SELECT ai.invoice_type_lookup_code,
           ai.payment_status_flag,
           ai.invoice_amount,
           ai.payment_currency_code,
           ai.invoice_currency_code,
           ai.payment_cross_rate_date,
           ai.payment_cross_rate_type,
           asp.base_currency_code,
	   ai.invoice_id,
           ai.invoice_num,
           ai.org_id,
           ai.invoice_amount,
           ai.base_amount,
           ai.exchange_rate,
           ai.invoice_currency_code,
           ai.invoice_type_lookup_code,
           ai.exchange_date,
           ai.exchange_rate_type,
           ai.vendor_id,
           ai.invoice_date,
           ai.disc_is_inv_less_tax_flag,
           ai.exclude_freight_from_discount
    INTO   l_invoice_type_lookup_code,
           l_payment_status_flag,
           l_invoice_amount,
           l_payment_currency_code,
           l_invoice_currency_code,
           l_payment_cross_rate_date,
           l_payment_cross_rate_type,
           l_base_currency_code,
	   l_invoice_rec.invoice_id,
           l_invoice_rec.invoice_num,
           l_invoice_rec.org_id,
           l_invoice_rec.invoice_amount,
           l_invoice_rec.base_amount,
           l_invoice_rec.exchange_rate,
           l_invoice_rec.invoice_currency_code,
           l_invoice_rec.invoice_type_lookup_code,
           l_invoice_rec.exchange_date,
           l_invoice_rec.exchange_rate_type,
           l_invoice_rec.vendor_id,
           l_invoice_rec.invoice_date,
           l_invoice_rec.disc_is_inv_less_tax_flag,
           l_invoice_rec.exclude_freight_from_discount
      FROM ap_invoices ai,
           ap_system_parameters_all asp
     WHERE invoice_id = p_line_rec.invoice_id
	   AND ai.org_id = asp.org_id;

    /*-----------------------------------------------------------------+
     |  Step 0. If invoice line is AWT,  undo withholding before       |
     |          any other discard operation                            |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Undo AWT if it is an AWT line';

    IF ( NVL( P_calling_mode, 'DISCARD' ) = 'DISCARD' AND
         p_line_rec.line_type_lookup_code = 'AWT' AND
         p_line_rec.line_source = 'AUTO WITHHOLDING') THEN -- bug 7568031

        -- One AWT dist corresponds to one Invoice Line.
        AP_WITHHOLDING_PKG.Ap_Undo_Withholding (
          P_Parent_Id              =>     P_line_rec.invoice_id,
          P_Calling_Module         =>     'REVERSE DIST',
          P_Awt_Date               =>     P_line_rec.accounting_date,
          P_New_Invoice_Payment_Id =>     NULL,
          P_Last_Updated_By        =>     P_last_updated_by,
          P_Last_Update_Login      =>     P_last_update_login,
          P_Program_Application_Id =>     NULL,
          P_Program_Id             =>     NULL,
          P_Request_Id             =>     NULL,
          P_Awt_Success            =>     l_awt_success,
          P_Inv_Line_No            =>     P_line_rec.line_number,
          P_dist_Line_No           =>     NULL,
          P_New_Invoice_Id         =>     NULL,
          P_New_dist_Line_No       =>     NULL);

     IF ( l_awt_success = 'SUCCESS' ) THEN
     IF nvl(l_cancel_proactive_flag,'N') ='C' THEN   --if proactive cancel profile set
     --9100425
     For I in(select invoice_distribution_id
     from ap_invoice_distributions aid1
     where aid1.invoice_id=P_line_rec.invoice_id
     and aid1.line_type_lookup_code='AWT'
     and aid1.awt_flag='A'
     and aid1.parent_reversal_id is  null --original dist
     --for original dists there is no reversal dist created
     and ( not exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_line_rec.invoice_id
     and aid2.invoice_line_number=aid1.invoice_line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id)
     --the reversal dist does not reverse the amount correctly
     or  exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_line_rec.invoice_id
     and aid2.invoice_line_number=aid1.invoice_line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id
     and -1 * aid2.amount <> aid1.amount))) --dists updated today

     LOOP
       prob_dist_list := prob_dist_list||','||i.invoice_distribution_id;
       prob_dist_count:=prob_dist_count+1;

     end loop;

           IF prob_dist_count > 0 then

           p_error_code :='AP_INV_DIS_CAN_FAIL';
           P_token:=prob_dist_list;
           ROLLBACK TO SAVEPOINT CANCEL_CHECK;
           RETURN(FALSE);

           ELSE
               RETURN(TRUE);
           END IF;
        ELSE  --if cancel proactive profile is not set
           RETURN(TRUE);
        END IF;  --cancel proactive profile
    --9100425

          ELSE
           p_error_code := l_awt_success;
           RETURN(FALSE);
         END IF; --l_awt_success

    END IF;

    /*-----------------------------------------------------------------+
     |   Check if the Line is Discardable or if the Invoice is         |
     |   is Cancelable.                                                |
     +-----------------------------------------------------------------*/

    IF ( NVL( P_calling_mode, 'DISCARD' ) IN ( 'DISCARD', 'UNAPPLY_PREPAY' ) ) THEN
      IF ( NVL(P_line_rec.discarded_flag, 'N') <> 'Y' ) THEN
        /* Base Line ARU Issue */
        l_ok_to_discard := AP_INVOICE_LINES_UTILITY_PKG.Is_Line_Discardable(
                               P_line_rec,
                               l_error_code,
                               l_curr_calling_sequence );

        IF ( l_ok_to_discard = FALSE ) THEN
          p_error_code := l_error_code;
          RETURN (FALSE);

        --Bug9133464  START
        ELSE

          SELECT COUNT(1)
            INTO l_manual_tax_lines
            FROM ap_invoice_lines_all ail
           WHERE invoice_id = P_line_rec.invoice_id
             AND line_type_lookup_code = 'TAX'
             AND summary_tax_line_id IS NULL;

             IF l_manual_tax_lines > 0 THEN

                l_success := ap_etax_pkg.calling_etax(
                             p_invoice_id	  => p_line_rec.invoice_id,
                             p_calling_mode 	  => 'CALCULATE',
                             p_all_error_messages => 'N',
                             p_error_code	  => l_error_code,
                             p_calling_sequence   => l_curr_calling_sequence);

                 IF (NOT l_success) THEN
                    p_error_code := 'AP_ETX_DISC_LINE_CALC_TAX_FAIL';
                    p_token := l_error_code;
                    RETURN FALSE;
                 END IF;

             END IF;
          --Bug9133464 END
        END IF;
      ELSE

        l_ok_to_discard := FALSE;
        p_error_code := 'AP_LINE_ALREADY_DISCARDED';
	RETURN (FALSE);

      END IF;

    END IF;

    IF ( P_calling_mode = 'CANCEL' ) THEN
      IF (  p_inv_cancellable is NOT NULL and
            p_inv_cancellable = 'Y' and
            NVL(p_line_rec.cancelled_flag, 'N') <> 'Y' ) THEN
        l_ok_to_cancel := TRUE;

      ELSIF ( p_inv_cancellable is NULL ) THEN
        l_ok_to_cancel := AP_CANCEL_PKG.Is_Invoice_Cancellable(
                              P_invoice_id       => p_line_rec.invoice_id,
                              P_error_code       => l_error_code,
                              P_debug_info       => l_debug_info,
                              P_calling_sequence => l_curr_calling_sequence );

        IF ( l_ok_to_cancel = FALSE ) THEN
          p_error_code := l_error_code;
          RETURN (FALSE);
        END IF;
      ELSE

        p_error_code := 'AP_INV_CANCELLED';
        l_ok_to_cancel := FALSE;
	RETURN(FALSE);

      END IF;

      -- Block to handle generate distributions for the Item line
      -- where prepay application and prepay unapplication has distributions
      -- and user tried to cancle the invoice bug 8361741

      IF ( l_ok_to_cancel = TRUE AND l_invoice_type_lookup_code <> 'PREPAYMENT' ) THEN

	 l_itm_dist_count := 0;
	 -- query to get the Distributions for that standard invoice
	 SELECT COUNT(*) INTO l_itm_dist_count
	   FROM ap_invoice_distributions_all aid
	  WHERE aid.invoice_id = p_line_rec.invoice_id
	    AND aid.prepay_distribution_id is not null
	    AND NOT EXISTS (SELECT 1
	                      FROM ap_invoice_distributions_all item
                             WHERE item.invoice_id = p_line_rec.invoice_id
		               AND item.prepay_distribution_id is null)
            AND ROWNUM =1;

        IF (l_itm_dist_count = 1) THEN

            AP_APPROVAL_PKG.Generate_Distributions
                                (p_invoice_rec        => l_invoice_rec,
		                 p_base_currency_code => l_base_currency_code,
                                 p_inv_batch_id       => NULL,
                                 p_run_option         => NULL,
                                 p_calling_sequence   => l_curr_calling_sequence,
                                 x_error_code         => l_error_code,
        	                 p_calling_mode       => 'APPROVE' );
         END IF;

      END IF; -- l_ok_to_cancel = TRUE 8361741 ends

    END IF; -- end of check P_calling_mode
    -- Bug 5114543 Start
    IF (l_ok_to_discard = TRUE) THEN

       IF p_line_rec.line_type_lookup_code = 'ITEM' THEN

          ----------------------------------------------------------------------------
          l_debug_info := 'Update allocation rule to pending on related charge lines';
	  Print (l_api_name, l_debug_info);
	  ----------------------------------------------------------------------------

	  update ap_allocation_rules ar
	     set status = 'PENDING'
           where ar.invoice_id = p_line_rec.invoice_id
             and exists (select arl.chrg_invoice_line_number
                           from ap_allocation_rule_lines arl
	                  where arl.invoice_id = p_line_rec.invoice_id
                            and arl.to_invoice_line_number = p_line_rec.line_number
			    and arl.chrg_invoice_line_number =  ar.chrg_invoice_line_number);

          ----------------------------------------------------------------------------
	  l_debug_info := 'Reset generate distributions flag on related charge lines';
          Print (l_api_name, l_debug_info);
          ----------------------------------------------------------------------------

          update ap_invoice_lines_all ail
             set generate_dists = 'Y'
           where ail.invoice_id = p_line_rec.invoice_id
             and exists (select arl.chrg_invoice_line_number
                           from ap_allocation_rule_lines arl
                          where arl.invoice_id = p_line_rec.invoice_id
                            and arl.to_invoice_line_number = p_line_rec.line_number
                            and arl.chrg_invoice_line_number =  ail.line_number);

	  open c_charge_lines (p_line_rec.invoice_id,
			       p_line_rec.line_number);
          loop
             fetch c_charge_lines
	      into l_chrg_line_rec;
	     exit when c_charge_lines%notfound;

             ----------------------------------------------------------------------------
             l_debug_info := 'Reverse charge distributions';
             Print (l_api_name,l_debug_info);
             ----------------------------------------------------------------------------

	     if not ap_invoice_lines_pkg.reverse_charge_distributions
	                        (p_inv_line_rec		=> l_chrg_line_rec
	                        ,p_calling_mode		=> p_calling_mode
	                        ,x_error_code		=> l_error_code
	                        ,x_debug_info		=> l_debug_info
	                        ,p_calling_sequence	=> l_curr_calling_sequence) then

	      	l_ok_to_discard := FALSE;
		p_error_code    := 'AP_REV_CHRG_DIST_FAIL';

        	RETURN FALSE;

	     end if;

            -- 9100425

   IF nvl(l_cancel_proactive_flag,'N') ='C' and NVL(P_calling_mode,'DISCARD') = 'DISCARD'  THEN
   --proactive cancel check profile on

     For I in(select invoice_distribution_id
     from ap_invoice_distributions aid1
     where aid1.invoice_id=l_chrg_line_rec.invoice_id
     and aid1.invoice_line_number=l_chrg_line_rec.line_number --P_line_rec. line_number
     and aid1.parent_reversal_id is  null --original dist
     and   ((line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
             and prepay_distribution_id IS NULL) OR
             prepay_distribution_id IS NOT NULL
                   )
     and   (line_type_lookup_code     <> 'AWT' OR
           (line_type_lookup_code      = 'AWT' AND awt_flag <> 'A'))
     --for original dists there is no reversal dist created
     and ( not exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=l_chrg_line_rec.invoice_id
     and aid2.invoice_line_number=l_chrg_line_rec.line_number --P_line_rec.line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id)
     --the reversal dist does not reverse the amount correctly
     or  exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=l_chrg_line_rec.invoice_id
     and aid2.invoice_line_number=l_chrg_line_rec.line_number --P_line_rec.line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id
     and -1 * aid2.amount <> aid1.amount)) )
        LOOP
          prob_dist_list := prob_dist_list||','||i.invoice_distribution_id;
          prob_dist_count:=prob_dist_count+1;

         end loop;
         END IF;  --proactive cancel check profile on
       --9100425
          end loop;


        -- 9100425  kept the error check outside charge loop so that it fires only once
   IF nvl(l_cancel_proactive_flag,'N') ='C' and NVL(P_calling_mode,'DISCARD') = 'DISCARD'
   and prob_dist_count > 0 THEN

           p_error_code :='AP_INV_DIS_CAN_FAIL';
           P_token:=prob_dist_list;
           ROLLBACK TO SAVEPOINT CANCEL_CHECK;
           RETURN(FALSE);
   END IF;
   -- 9100425
	  close c_charge_lines;

          ----------------------------------------------------------------------------
          l_debug_info := 'Delete allocation rule lines';
          Print (l_api_name,l_debug_info);
          ----------------------------------------------------------------------------

          delete from ap_allocation_rule_lines
           where invoice_id = p_line_rec.invoice_id
             and to_invoice_line_number = p_line_rec.line_number;

       END IF;
    END IF;
    -- Bug 5114543 End

    IF ( l_ok_to_discard = TRUE OR
         l_ok_to_cancel = TRUE ) THEN


     --Start of bug 8733916
     --bug 9293911, added 'UNAPPLY_PREPAY' to the 'IF' condition
    /*-----------------------------------------------------------------+
     |  Step 0. Delete all the unprocessed bc events for this invoice  |
     +-----------------------------------------------------------------*/

     IF(p_calling_mode IN ('DISCARD', 'UNAPPLY_PREPAY')) THEN

       AP_FUNDS_CONTROL_PKG.Encum_Unprocessed_Events_Del
                         (p_invoice_id       => p_line_rec.invoice_id,
                          p_calling_sequence => l_curr_calling_sequence);


     UPDATE ap_invoice_distributions aid
        SET aid.encumbered_flag = 'R'
      WHERE aid.invoice_id = p_line_rec.invoice_id
        AND aid.invoice_line_number = p_line_rec.line_number
        AND nvl(aid.encumbered_flag,'N') IN ('N','H','P')
        AND aid.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
        AND nvl(aid.reversal_flag,'N')<>'Y'
        AND EXISTS (SELECT 1
		      FROM financials_system_params_all fsp
		     WHERE fsp.org_id = aid.org_id
		       AND nvl(fsp.purch_encumbrance_flag, 'N') = 'Y');

    END IF;

      --End of bug 8733916


      /*--------------------------------------------------------------+
      | Step 1. Call the ETAX api to unfreeze the invoice, if the     |
      |         invoice is already validated.			      |
      |---------------------------------------------------------------*/
      --Need not call the UNFREEZE INVOICE when the calling mode = 'CANCE',
      --as the call is already done in CANCEL package before control comes here.
      --The reason the call being placed
      IF (l_ok_to_discard) THEN

        l_invoice_validation_status := ap_invoices_pkg.get_approval_status(
     						l_invoice_id => p_line_rec.invoice_id,
						l_invoice_amount => l_invoice_amount,
						l_payment_status_flag => l_payment_status_flag,
						l_invoice_type_lookup_code => l_invoice_type_lookup_code );

        IF (NVL(l_invoice_validation_status,'NEVER APPROVED') IN
      				('APPROVED','AVAILABLE','UNPAID','FULL')) THEN

            l_success := ap_etax_pkg.calling_etax(
	  			P_Invoice_id => p_line_rec.invoice_id,
				P_Calling_Mode => 'UNFREEZE INVOICE',
				P_All_Error_Messages => 'N',
				P_error_code => l_error_code,
				P_Calling_Sequence => l_curr_calling_sequence);

            IF (not l_success) THEN
              p_error_code := 'AP_ETX_DISC_LINE_UNFRZ_FAIL';
	      p_token := l_error_code;
	      RETURN(FALSE);
	    END IF;

        END IF;

        SELECT included_tax_amount
	INTO l_included_tax_amount
	FROM ap_invoice_lines
	WHERE invoice_id = p_line_rec.invoice_id
	AND line_number = p_line_rec.line_number;

      END IF; /* if l_ok_to_discard = 'Y' */


    /*-----------------------------------------------------------------+
     |  Step 2. Reverse Match if line is matched                       |
     |          a. Reverse adjust po_distributions                     |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Reverse Match - Adjust po_distributions po_line_location_id is '||p_line_rec.po_line_location_id;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      IF ( p_line_rec.po_Line_location_id is not null OR
           p_line_rec.rcv_transaction_id is not null ) AND
           p_calling_mode <> 'UNAPPLY_PREPAY' THEN


          l_po_ap_dist_rec  := PO_AP_DIST_REC_TYPE.create_object();
          l_recoup_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

          l_debug_info := 'Open Cursor Po_Dists_Cur';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          OPEN po_dists_cur;
          LOOP

             FETCH po_dists_cur
             INTO l_po_distribution_id,
                l_matched_uom,
                l_sum_matched_qty,
                l_sum_matched_amt,
	        l_dist_type_lookup_code,
		l_matching_basis,
		l_prepay_invoice_id,
		l_prepay_line_number;
           EXIT WHEN po_dists_cur%NOTFOUND;

           IF (l_dist_type_lookup_code IN ('ITEM','ACCRUAL','IPV','ERV')) THEN

	      l_debug_info := 'Update billed/financed data for po distributions';
	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	      END IF;

	      --Bugfix:5578026
	      IF (l_invoice_type_lookup_code <> 'PREPAYMENT') THEN

                  l_po_ap_dist_rec.add_change(p_po_distribution_id => l_po_distribution_id,
                                p_uom_code           => l_matched_uom,
                                p_quantity_billed    => l_sum_matched_qty*(-1),
                                p_amount_billed      => l_sum_matched_amt*(-1),
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => NULL,
                                p_amount_recouped    => NULL,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);


	          l_shipment_amt_billed := l_shipment_amt_billed + nvl(l_sum_matched_amt,0) * (-1);
	          l_shipment_qty_billed := l_shipment_qty_billed + nvl(l_sum_matched_qty,0) * (-1);

	      ELSIF (l_invoice_type_lookup_code = 'PREPAYMENT') THEN

	          l_po_ap_dist_rec.add_change(p_po_distribution_id => l_po_distribution_id,
		                          p_uom_code           => l_matched_uom,
					  p_quantity_billed    => NULL,
					  p_amount_billed      => NULL,
					  p_quantity_financed  => l_sum_matched_qty*(-1),
					  p_amount_financed    => l_sum_matched_amt*(-1),
					  p_quantity_recouped  => NULL,
					  p_amount_recouped    => NULL,
					  p_retainage_withheld_amt => NULL,
					  p_retainage_released_amt => NULL);

                   l_shipment_amt_financed := l_shipment_amt_financed + nvl(l_sum_matched_amt,0)*(-1);
                   l_shipment_qty_financed := l_shipment_qty_financed + nvl(l_sum_matched_qty,0)*(-1);


	      END IF; /*Bugfix:5578026 */


           ELSIF (l_dist_type_lookup_code = 'PREPAY') THEN

	      l_debug_info := 'Populate recouped data for po distributions ';
	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	      END IF;

              l_po_ap_dist_rec.add_change(p_po_distribution_id => l_po_distribution_id,
                                p_uom_code           => l_matched_uom,
                                p_quantity_billed    => NULL,
                                p_amount_billed      => NULL,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => l_sum_matched_qty,
                                p_amount_recouped    => l_sum_matched_amt,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);

       	      l_shipment_amt_recouped := l_shipment_amt_recouped + nvl(l_sum_matched_amt,0);
	      l_shipment_qty_recouped := l_shipment_qty_recouped + nvl(l_sum_matched_qty,0);

              -- This loop will update amount/quantity recouped at the distribution level.
              -- As, Recouped prepay distributions belong to a different shipment. Cursor
              -- c_recouped_shipment is used for shipment level updates outside the loop.
              -- For this reason, dummy distributions are populated in l_recoup_dist_rec
              -- so that the subsequent call to Update_Document_Ap_Values does not fail.

              l_recoup_dist_rec.add_change(p_po_distribution_id => l_po_distribution_id,
                                p_uom_code           => NULL,
                                p_quantity_billed    => NULL,
                                p_amount_billed      => NULL,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => NULL,
                                p_amount_recouped    => NULL,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);

           ELSIF (l_dist_type_lookup_code = 'RETAINAGE') THEN

	      IF p_line_rec.line_type_lookup_code <> 'RETAINAGE RELEASE' THEN

		 l_debug_info := 'Populate retainage withheld data for po distributions: '||l_po_distribution_id||': '||l_sum_matched_amt;
                 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                 END IF;

                 l_po_ap_dist_rec.add_change(p_po_distribution_id     => l_po_distribution_id,
					     p_uom_code               => NULL,
                                 	     p_quantity_billed        => NULL,
                                 	     p_amount_billed          => NULL,
                                 	     p_quantity_financed      => NULL,
                                	     p_amount_financed        => NULL,
                                	     p_quantity_recouped      => NULL,
                                	     p_amount_recouped        => NULL,
                                	     p_retainage_withheld_amt => l_sum_matched_amt,
                                	     p_retainage_released_amt => NULL);

                 l_shipment_amt_retained := l_shipment_amt_retained + nvl(l_sum_matched_amt,0);

	      ELSIF p_line_rec.line_type_lookup_code = 'RETAINAGE RELEASE' THEN

                 l_debug_info := 'Populate retainage released data for po distributions: '||l_sum_matched_amt;
                 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                 END IF;

                 l_po_ap_dist_rec.add_change(p_po_distribution_id     => l_po_distribution_id,
                                             p_uom_code               => NULL,
                                             p_quantity_billed        => NULL,
                                             p_amount_billed          => NULL,
                                             p_quantity_financed      => NULL,
                                             p_amount_financed        => NULL,
                                             p_quantity_recouped      => NULL,
                                             p_amount_recouped        => NULL,
                                             p_retainage_withheld_amt => NULL,
                                             p_retainage_released_amt => l_sum_matched_amt * (-1));

                 l_shipment_amt_released := l_shipment_amt_released + nvl(l_sum_matched_amt,0) * (-1);

              END IF;
           END IF;

        END LOOP;

	CLOSE PO_Dists_Cur;

        l_debug_info := 'Create l_po_ap_line_loc_rec object and populate the data';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;


        IF (l_shipment_amt_billed   <> 0 OR l_shipment_qty_billed   <> 0 OR
	    l_shipment_amt_financed <> 0 OR l_shipment_qty_financed <> 0 OR  --bugfix:5578026
	    l_shipment_amt_recouped <> 0 OR l_shipment_qty_recouped <> 0 OR
            l_shipment_amt_retained <> 0 OR l_shipment_amt_released <> 0) THEN

	     l_debug_info := ' Call add_change to populate the billed data for po shipments';
	     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	     END IF;

             l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => p_line_rec.po_line_location_id,
                                 p_uom_code            => l_matched_uom,
                                 p_quantity_billed     => l_shipment_qty_billed,
                                 p_amount_billed       => l_shipment_amt_billed,
                                 p_quantity_financed   => l_shipment_qty_financed,
                                 p_amount_financed     => l_shipment_amt_financed,
                                 p_quantity_recouped   => NULL,
                                 p_amount_recouped     => NULL,
                                 p_retainage_withheld_amt => l_shipment_amt_retained,
                                 p_retainage_released_amt => l_shipment_amt_released
                                );

        END IF;

        l_debug_info := 'Call the PO_AP_INVOICE_MATCH_GRP to update the Po Distributions and Po Line Locations';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
                                        P_Api_Version => 1.0,
                                        P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
                                        P_Dist_Changes_Rec     => l_po_ap_dist_rec,
                                        X_Return_Status        => l_return_status,
                                        X_Msg_Data             => l_msg_data);

        IF (l_shipment_amt_recouped <> 0 OR l_shipment_qty_recouped <> 0) THEN

            OPEN  c_recouped_shipment;
            LOOP
               FETCH c_recouped_shipment
               INTO  l_recouped_shipment;
               EXIT WHEN c_recouped_shipment%NOTFOUND;

               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, '1: '||l_recouped_shipment.line_location_id);
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, '2: '||l_recouped_shipment.matched_uom_lookup_code);
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, '3: '||l_recouped_shipment.quantity);
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, '4: '||l_recouped_shipment.amount);
               END IF;

               l_recoup_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
		                                 p_po_line_location_id => l_recouped_shipment.line_location_id,
		                                 p_uom_code            => l_recouped_shipment.matched_uom_lookup_code,
		                                 p_quantity_billed     => NULL,
		                                 p_amount_billed       => NULL,
		                                 p_quantity_financed   => NULL,
		                                 p_amount_financed     => NULL,
		                                 p_quantity_recouped   => l_recouped_shipment.quantity,
		                                 p_amount_recouped     => l_recouped_shipment.amount,
		                                 p_retainage_withheld_amt => NULL,
		                                 p_retainage_released_amt => NULL
		                                );

               PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
                                        P_Api_Version 	       => 1.0,
                                        P_Line_Loc_Changes_Rec => l_recoup_line_loc_rec,
                                        P_Dist_Changes_Rec     => l_recoup_dist_rec,
                                        X_Return_Status        => l_return_status,
                                        X_Msg_Data             => l_msg_data);

          END LOOP;
          CLOSE c_recouped_shipment;
       END IF;

    /*-----------------------------------------------------------------+
     |  Step 1. Reverse Match if line is matched                       |
     |          c. Reverse adjust rcv_transaction                      |
     +-----------------------------------------------------------------*/
       /* Bug 5351931. was <>, modified to 'IS NOT NULL' */

       --bugfix:5638822, add the AND clause below as when we are cancelling a invoice which had
       --TAX related to a receipt matched line (rcv_transaction_id is not null on TAX related to
       --receipt matched line) we were reducing the qty/amt_billed with tax amount too.

       IF ( p_line_rec.rcv_transaction_id IS NOT NULL AND p_line_rec.line_type_lookup_code <> 'TAX' ) THEN
          l_debug_info := 'Reverse Match - Adject rcv_transactions ';

          l_sum_matched_qty := 0;
                          /* Amount Based Matching */
          IF ( p_line_rec.match_type  IN ('AMOUNT_CORRECTION', 'PRICE_CORRECTION',
                               'ITEM_TO_SERVICE_PO', 'ITEM_TO_SERVICE_RECEIPT') ) THEN
            l_sum_matched_qty := 0;
          ELSE
            l_sum_matched_qty := NVL(p_line_rec.quantity_invoiced, 0 );

          END IF;

          RCV_BILL_UPDATING_SV.ap_update_rcv_transactions(
                p_line_rec.rcv_transaction_id ,
                l_sum_matched_qty *(-1),
                p_line_rec.unit_meas_lookup_code,
                NVL(p_line_rec.amount, 0) * (-1));

        END IF; -- end of l_rcv_transaction_id check

      END IF; -- end of l_po_line_location_id/l_rcv_transaction_id check

     /*-------------------------------------------------------------------+
     |  Step 1a. Update retained_amount_remaining on the original invoice |
     +--------------------------------------------------------------------*/
      IF p_line_rec.line_type_lookup_code = 'RETAINAGE RELEASE' AND
         p_line_rec.retained_invoice_id   IS NOT NULL           AND
         p_line_rec.retained_line_number  IS NOT NULL           THEN

         UPDATE ap_invoice_lines_all
            SET retained_amount_remaining = nvl(retained_amount_remaining, 0) + p_line_rec.amount
          WHERE invoice_id  = p_line_rec.retained_invoice_id
            AND line_number = p_line_rec.retained_line_number;

      END IF;


     /*------------------------------------------------------------------
     --bugfix:5638822
     --Update amount_paid on the invoice , if this line had recouped_amount
     -- on it.
     -------------------------------------------------------------------*/
     l_debug_info := 'Update amount_paid on the invoice if the line had recouped amount';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     l_recouped_amount := AP_MATCHING_UTILS_PKG.Get_Inv_Line_Recouped_Amount(p_line_rec.Invoice_Id,p_line_rec.Line_Number);

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Recouped Amount: '||l_recouped_amount);
     END IF;

     --Commented below update for bug #8928639

    /* UPDATE ap_invoices
     SET amount_paid = nvl(amount_paid,0) - abs(l_recouped_amount) ,
         payment_status_flag =
                  AP_INVOICES_UTILITY_PKG.get_payment_status(p_line_rec.invoice_id ),
         last_update_date    = SYSDATE,
         last_updated_by     = fnd_global.user_id,
         last_update_login   = p_line_rec.last_update_login
     WHERE invoice_id        = p_line_rec.invoice_id;  */


     l_dummy := AP_PREPAY_PKG.Update_Payment_Schedule(
     			p_invoice_id        => p_line_rec.invoice_id,
			p_prepay_invoice_id => NULL,
			p_prepay_line_num   => NULL,
			p_apply_amount      => l_recouped_amount,
			p_appl_type         => 'UNAPPLICATION',
			p_payment_currency_code => l_payment_currency_code,
			p_user_id           => FND_GLOBAL.user_id,
			p_last_update_login => p_line_rec.last_update_login,
			p_calling_sequence  => p_calling_sequence,
			p_calling_mode      => 'RECOUPMENT',
			p_error_message     => l_error_message);


     /*-----------------------------------------------------------------+
     |  Step 2. Zero out line level data and MRC data maintainence     |
     +-----------------------------------------------------------------*/
      UPDATE ap_invoice_lines
      SET  original_amount = amount
          ,original_base_amount = base_amount
          ,original_rounding_amt = rounding_amt
          ,amount = 0
          ,base_amount = 0
          ,rounding_amt = 0
	  ,retained_amount = 0
	  ,retained_amount_remaining = 0
          ,included_tax_amount = 0
          ,discarded_flag = decode( p_calling_mode, 'DISCARD', 'Y', 'UNAPPLY_PREPAY','Y',NULL )
          -- Bug 6669048. The cancelled_flag will be updated in the cancel API
          -- ,cancelled_flag = decode( p_calling_mode, 'CANCEL', 'Y', NULL )
          ,generate_dists = decode( generate_dists, 'Y', 'N', generate_dists)
          ,quantity_invoiced = decode( p_calling_mode,
	                               'DISCARD',  quantity_invoiced - quantity_invoiced,  --8560785
   	                               'CANCEL',   quantity_invoiced - quantity_invoiced, --Introduced for bug#9570774
				       quantity_invoiced)
      WHERE invoice_id = p_line_rec.invoice_id
      AND line_number = p_line_rec.line_number;


    /*-----------------------------------------------------------------+
     |  Step 4. Reverse Distribution                                   |
     |          a. Check if there is a valid distribution exists       |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Check if there is a valid distribuition for reversal';

      --Contract Payments: Modified the below WHERE clause to get the TAX related to
      --Prepay distributions , but not the TAX related to ITEM dists, since DETERMINE_RECOVERY
      --will take care of the TAX on ITEM dists.
      SELECT count(*)
        INTO l_distribution_count
        FROM ap_invoice_distributions_all
       WHERE invoice_id = p_line_rec.invoice_id
         AND invoice_line_number = p_line_rec.line_number
         AND ((line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV') and
	        prepay_distribution_id IS NULL) OR
              (prepay_distribution_id IS NOT NULL)
             )
         AND NVL(reversal_flag, 'N') <> 'Y';

      IF ( l_distribution_count <> 0 ) THEN

        l_debug_info := 'Get the maximum distribution line number';
        l_max_line_num := AP_INVOICE_LINES_PKG.get_max_dist_line_num(
                              p_line_rec.invoice_id,
                              p_line_rec.line_number);

     -- Bug fix 4748638
    /*-----------------------------------------------------------------+
     |  Step 4. Reverse Distribution                                   |
     |          c. Create cancellation accounting event when primary   |
     |             accounting metod is Accrual basis.                  |
     |  Note - It has been decided that a single invoice cancellation  |
     |         event will be created per invoice for the uptake of SLA.|
     |         The invoice cancellation event and distributions will   |
     |         use the Invoice Header GL date as was used in 11i.      |
     |  Note 2 - to fix bug 4748638, if we finally goes with the       |
     |           option that create single cancel event. we need to    |
     |           move the event creation to cancel package             |
     +-----------------------------------------------------------------*/
/*
        IF (p_calling_mode = 'CANCEL' ) THEN

          --Bug 4352723 - Added the following select to get Invoice Header
          --GL date to be used for Invoice cancellation event and dists
          SELECT gl_date
          INTO   l_open_gl_date
          FROM   AP_INVOICES
          WHERE  invoice_id = P_Line_Rec.invoice_id;


          AP_ACCOUNTING_EVENTS_PKG.Create_Events (
              'INVOICE CANCELLATION'
              ,NULL   -- p_doc_type
              ,p_line_rec.invoice_id
              ,l_open_gl_date
              ,l_Accounting_event_ID
              ,NULL    -- checkrun_name
              ,P_calling_sequence);

        END IF; -- Events Project - 2 - end

*/
    /*-----------------------------------------------------------------+
     |  Step 4. Reverse Distribution                                   |
     |          d.Insert reversal lines                                |
     +-----------------------------------------------------------------*/
        l_debug_info := 'Insert distribution reversals for existing lines';

	--Contract Payments: Modified the WHERE and HAVING clause to take into
	--consideration 'Prepay' and its related Tax distributions.

	-- Removed the below HAVING clause, for the 7376114, to allow zero amount ITEM lines to be reversed.

        INSERT INTO ap_invoice_distributions_all(
            invoice_id,
            invoice_line_number,
            dist_code_combination_id,
            invoice_distribution_id,
            last_update_date,
            last_updated_by,
            accounting_date,
            period_name,
            set_of_books_id,
            amount,
            description,
            type_1099,
            tax_code_id,
            posted_flag,
            batch_id,
            quantity_invoiced,
            corrected_quantity,
            unit_price,
            match_status_flag,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            prepay_amount_remaining,
	    prepay_distribution_id,
            assets_addition_flag,
            assets_tracking_flag,
            distribution_line_number,
            line_type_lookup_code,
            po_distribution_id,
            base_amount,
            pa_addition_flag,
            encumbered_flag,
            accrual_posted_flag,
            cash_posted_flag,
            last_update_login,
            creation_date,
            created_by,
            stat_amount,
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
            reversal_flag,
            parent_invoice_id,
            income_tax_region,
            final_match_flag,
            expenditure_item_date,
            expenditure_organization_id,
            expenditure_type,
            pa_quantity,
            project_id,
            task_id,
            quantity_variance,
            base_quantity_variance,
            awt_flag,
            awt_group_id,
            awt_tax_rate_id,
            awt_gross_amount,
            reference_1,
            reference_2,
            other_invoice_id,
            awt_invoice_id,
            awt_origin_group_id,
            program_application_id,
            program_id,
            program_update_date,
            request_id,
            tax_recoverable_flag,
            award_id,
            start_expense_date,
            merchant_document_number,
            merchant_name,
            merchant_tax_reg_number,
            merchant_taxpayer_id,
            country_of_supply,
            merchant_reference,
            parent_reversal_id,
            rcv_transaction_id,
            dist_match_type,
            matched_uom_lookup_code,
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
            receipt_verified_flag,
            receipt_required_flag,
            receipt_missing_flag,
            justification,
            expense_Group,
            end_Expense_Date,
            receipt_Currency_Code,
            receipt_Conversion_Rate,
            receipt_Currency_Amount,
            daily_Amount,
            web_Parameter_Id,
            adjustment_Reason,
            credit_Card_Trx_Id,
            company_Prepaid_Invoice_Id,
            org_id,
            rounding_amt,
            charge_applicable_to_dist_id,
            corrected_invoice_dist_id,
            related_id,
            asset_book_type_code,
            asset_category_id,
            accounting_event_id,
            cancellation_flag,
	    distribution_class,
	    intended_use,
	    --Freight and Special Charges
	    rcv_charge_addition_flag,
	    awt_related_id, --bug 8745752
            retained_invoice_dist_id)	                 -- Bug 8824235
            (SELECT
             Invoice_Id,                                 -- invoice_id
             Invoice_Line_Number,                        -- invoice_line_number
             Dist_Code_Combination_Id,                   -- dist_code_combination_id
             ap_invoice_distributions_s.NEXTVAL,         -- distribution_id
              sysdate,                                   -- last_update_date
             p_Last_Updated_By,                          -- last_updated_by
             /* Bug 5584997, Getting the accounting_date from line rec
             --Bug9345786. Commented the following code.
             DECODE(P_calling_mode,'UNAPPLY_PREPAY',p_line_rec.accounting_date,
                    ap_utilities_pkg.get_reversal_gl_date(p_line_rec.accounting_date, org_id)),
                                                         -- accounting_date
             DECODE(P_calling_mode,'UNAPPLY_PREPAY',p_line_rec.period_name,
                    ap_utilities_pkg.get_reversal_period(p_line_rec.accounting_date, org_id)),
                                                         --  period_name, */
             --Bug9345786. Added following code instead.
                (CASE
              WHEN (P_calling_mode = 'UNAPPLY_PREPAY')   THEN  p_line_rec.accounting_date
              WHEN (P_calling_mode <> 'UNAPPLY_PREPAY' AND accounting_date > p_line_rec.accounting_date) THEN
                    ap_utilities_pkg.get_reversal_gl_date(accounting_date, org_id)
              WHEN (P_calling_mode <> 'UNAPPLY_PREPAY' AND accounting_date <= p_line_rec.accounting_date) THEN
                    ap_utilities_pkg.get_reversal_gl_date(p_line_rec.accounting_date, org_id)
               ELSE
                   ap_utilities_pkg.get_reversal_gl_date(p_line_rec.accounting_date, org_id)
              END),                                      -- accounting_date
              (CASE
              WHEN (P_calling_mode = 'UNAPPLY_PREPAY')   THEN  p_line_rec.period_name
              WHEN (P_calling_mode <> 'UNAPPLY_PREPAY' AND accounting_date > p_line_rec.accounting_date) THEN
                    ap_utilities_pkg.get_reversal_period(accounting_date, org_id)
              WHEN (P_calling_mode <> 'UNAPPLY_PREPAY' AND accounting_date <= p_line_rec.accounting_date) THEN
                    ap_utilities_pkg.get_reversal_period(p_line_rec.accounting_date, org_id)
              ELSE
                   ap_utilities_pkg.get_reversal_period(p_line_rec.accounting_date, org_id)
              END ),                                     -- period_name
             Set_Of_Books_Id, -- set_of_book_id
             -1 * Amount,                                -- amount
             Description,                                -- description
             Type_1099,                                  -- type_1099
             Tax_Code_Id,                                -- tax_code_id
             'N',                                        -- posted_flag,
             Batch_Id,                                   -- batch_id
             DECODE(quantity_invoiced, NULL, '', -1 * quantity_invoiced),
                                                         -- quantity_invoiced
             DECODE(corrected_quantity, NULL, '',
                    DECODE(dist_match_type, 'PRICE_CORRECTION',
                           corrected_quantity, (-1)*corrected_quantity) ),
                                                         -- corrected_quanity
             DECODE(unit_price, NULL,'',
                    DECODE(dist_match_type, 'PRICE_CORRECTION',
                           (-1)*unit_price, unit_price) ),
                                                         -- unit_price,
             'N',                                        -- match_status_flag
             attribute_category,                         -- attribute_category
             attribute1,                                 -- attribute1
             attribute2,                                 -- attribute2
             attribute3,                                 -- attribute3
             attribute4,                                 -- attribute4
             attribute5,                                 -- attribute5
             NULL,                                       -- prepay_amount_remaining
             prepay_distribution_id,                     -- prepay_distribution_id
             'U',                                        -- assets_addition_flag
             Assets_Tracking_Flag,                       -- assets_tracking_flag
             Distribution_Line_Number + l_max_line_num , -- distribution_line_number
             Line_Type_Lookup_Code,                      -- line_type_lookup_code
             Po_Distribution_Id,                         -- po_distribution_id
             -1 * Base_Amount,                           -- base_amount
             DECODE(Pa_Addition_Flag, 'E', 'E', 'N'),    -- pa_addition_flag
             DECODE( encumbered_flag, 'R', 'R', 'N'),    -- encumbered_flag,
             'N',                                        -- accrual_posted_flag,
             'N',                                        -- cash_posted_flag,
             p_Last_Update_Login,                        -- last_update_login
             sysdate,                                    -- creation_date,
             FND_GLOBAL.user_id,                         -- created_by,
             -1 * Stat_Amount,                           -- stat_amount
             attribute11,                                -- attribute11,
             attribute12,                                -- attribute12,
             attribute13,                                -- attribute13,
             attribute14,                                -- attribute14,
             attribute6,                                 -- attribute6,
             attribute7,                                 -- attribute7,
             attribute8,                                 -- attribute8,
             attribute9,                                 -- attribute9,
             attribute10,                                -- attribute10,
             attribute15,                                -- attribute15,
             'Y',                                        -- reversal_flag,
             Parent_Invoice_Id,                          -- parent_invoice_id
             Income_Tax_Region,                          -- income_tax_region
             Final_Match_Flag,                           -- final_match_flag
             Expenditure_Item_Date,                      -- expenditure_item_date
             Expenditure_Organization_Id,                -- expenditure_orgnization_id
             Expenditure_Type,                           -- expenditure_type
             -1 * Pa_Quantity,                           -- pa_quantity
             Project_Id,                                 -- project_id
             Task_Id,                                    -- task_id
             -1 * Quantity_Variance,                     -- quantity_variance
             -1 * Base_Quantity_Variance,                -- base quantity_variance
             awt_flag,                                   -- awt_flag
             awt_group_id,                               -- awt_group_id,
             awt_tax_rate_id,                            -- awt_tax_rate_id
             awt_gross_amount,                           -- awt_gross_amount
             reference_1,                                -- reference_1
             reference_2,                                -- reference_2
             other_invoice_id,                           -- other_invoice_id
             awt_invoice_id,                             -- awt_invoice_id
             awt_origin_group_id,                        -- awt_origin_group_id
             FND_GLOBAL.prog_appl_id,                    -- program_application_id
             FND_GLOBAL.conc_program_id,                 -- program_id
             SYSDATE,                                    -- program_update_date,
             FND_GLOBAL.conc_request_id,                 -- request_id
             tax_recoverable_flag,                       -- tax_recoverable_flag
             award_id,                                   -- award_id
             start_expense_date,                         -- start_expense_date
             merchant_document_number,                   -- merchant_document_number
             merchant_name,                              -- merchant_name
             merchant_tax_reg_number,                    -- merchant_tax_reg_number
             merchant_taxpayer_id,                       -- merchant_taxpayer_id
             country_of_supply,                          -- country_of_supply
             merchant_reference,                         -- merchant_reference
             invoice_distribution_id,                    -- Parent_Reversal_Id
             rcv_transaction_id,                         -- rcv_transaction_id
             dist_match_type,                            -- dist_match_type
             matched_uom_lookup_code,                    -- matched_uom_lookup_code
             global_attribute_category,                  -- global_attribute_category
             global_attribute1,                          -- global_attribute1
             global_attribute2,                          -- global_attribute2
             global_attribute3,                          -- global_attribute3
             global_attribute4,                          -- global_attribute4
             global_attribute5,                          -- global_attribute5
             global_attribute6,                          -- global_attribute6
             global_attribute7,                          -- global_attribute7
             global_attribute8,                          -- global_attribute8
             global_attribute9,                          -- global_attribute9
             global_attribute10,                         -- global_attribute10
             global_attribute11,                         -- global_attribute11
             global_attribute12,                         -- global_attribute12
             global_attribute13,                         -- global_attribute13
             global_attribute14,                         -- global_attribute14
             global_attribute15,                         -- global_attribute15
             global_attribute16,                         -- global_attribute16
             global_attribute17,                         -- global_attribute17
             global_attribute18,                         -- global_attribute18
             global_attribute19,                         -- global_attribute19
             global_attribute20,                         -- global_attribute20
             receipt_verified_flag,                      -- receipt_verified_flag
             receipt_required_flag,                      -- receipt_required_flag
             receipt_missing_flag,                       -- receipt_missing_flag
             justification,                              -- justification
             expense_Group,                              -- expense_Group
             end_Expense_Date,                           -- end_Expense_Date
             receipt_Currency_Code,                      -- receipt_Currency_Code
             receipt_Conversion_Rate,                    -- receipt_Conversion_Rate
             receipt_Currency_Amount,                    -- receipt_Currency_Amount
             daily_Amount,                               -- daily_Amount
             web_Parameter_Id,                           -- web_Parameter_Id
             adjustment_Reason,                          -- adjustment_Reason
             credit_Card_Trx_Id,                         -- credit_Card_Trx_Id
             company_Prepaid_Invoice_Id,                 -- company_Prepaid_Invoice_Id
             org_id,                                     -- MOAC project org_id
             -1* rounding_amt,                           -- rounding_amt
             charge_applicable_to_dist_id,               -- charge_applicable_to_dist_id
             corrected_invoice_dist_id,                  -- corrected_invoice_dist_id
             DECODE( related_id, NULL, NULL,
                     invoice_distribution_id,
                     ap_invoice_distributions_s.CURRVAL,
		     --bugfix:4921399
                     NULL ),                 -- related_id
             asset_book_type_code,                       -- asset_book_type_code
             asset_category_id,                          -- asset_category_id
             NULL,                                       -- accounting_event_id
             decode(p_calling_mode, 'CANCEL',decode ( line_type_lookup_code ,'PREPAY' , NULL ,'Y'),null), -- cancellation_flag bug9173973
	     'PERMANENT',
	     intended_use,				 -- intended_use
	     'N',					 -- rcv_charge_addition_flag
	     awt_related_id,				 -- Bug 8745752
             retained_invoice_dist_id                    -- Bug	8824235
             FROM  ap_invoice_distributions_all
             WHERE invoice_id                  = p_line_rec.invoice_id
             AND   invoice_line_number         = p_line_rec.line_number
             AND   line_type_lookup_code NOT IN
                    ('REC_TAX', 'NONREC_TAX', 'TRV', 'TERV', 'TIPV')
             AND   (line_type_lookup_code     <> 'AWT' OR
                   (line_type_lookup_code      = 'AWT' AND awt_flag <> 'A'))
             AND   dist_code_combination_id
                    IN (SELECT   dist_code_combination_id
                         FROM     ap_invoice_distributions_all
                         WHERE    invoice_id          = p_line_rec.invoice_id
                           AND    invoice_line_number = p_line_rec.line_number
                         GROUP BY dist_code_combination_id,
                                  po_distribution_id,
                                  line_type_lookup_code,
				  prepay_distribution_id,
                                  assets_tracking_flag,
                                  type_1099,
                                  project_id,
                                  task_id,
                                  expenditure_organization_id,
                                  expenditure_type,
                                  expenditure_item_date,
                                  pa_addition_flag,
                                  awt_group_id,
				  rcv_transaction_id)   -- Bug 4159731
             AND  nvl(po_distribution_id,-99) IN
	     	   (SELECT
		           NVL(po_distribution_id, -99)
	            FROM     ap_invoice_distributions_all
		    WHERE    invoice_id          = p_line_rec.invoice_id
		    AND    invoice_line_number = p_line_rec.line_number
		    GROUP BY dist_code_combination_id,
		             po_distribution_id,
		             line_type_lookup_code,
			     prepay_distribution_id,
		             assets_tracking_flag,
		             type_1099,
		             project_id,
		             task_id,
		             expenditure_organization_id,
		             expenditure_type,
		             expenditure_item_date,
		             pa_addition_flag,
		             awt_group_id,
			     rcv_transaction_id,   -- Bug 4159731
			     tax_code_id) -- Bug 5191117
	    AND  nvl(reversal_flag,'N') <> 'Y'	-- Bug 8326344
	   ) ;


      --bugfix:4921399
      UPDATE ap_invoice_distributions aid
      SET aid.related_id =
      			(SELECT invoice_distribution_id
      			FROM ap_invoice_distributions aid1
			WHERE aid1.invoice_id = aid.invoice_id
			AND aid1.invoice_line_number = aid.invoice_line_number
			AND aid1.parent_reversal_id =
					(SELECT related_id
					FROM ap_invoice_distributions aid2
					WHERE aid2.invoice_id = aid.invoice_id
					AND aid2.invoice_line_number = aid.invoice_line_number
					AND aid2.invoice_distribution_id = aid.parent_reversal_id)
                       )
      WHERE aid.related_id IS NULL
      AND aid.parent_reversal_id IS NOT NULL
      AND aid.invoice_id = p_line_rec.invoice_id
      AND aid.invoice_line_number = p_line_rec.line_number
      AND aid.reversal_flag = 'Y';

      -- Updating Retained_Amount_Remaining 	8824235
      UPDATE ap_invoice_distributions_all aid
         SET aid.retained_amount_remaining = aid.retained_amount_remaining -
		     NVL((SELECT sum(d2.amount)
 			    FROM ap_invoice_distributions_all d2
			   WHERE d2.parent_reversal_id is not null
			     AND d2.reversal_flag = 'Y'
			     AND d2.invoice_id = p_line_rec.invoice_id
			     AND d2.invoice_line_number = p_line_rec.line_number
                             AND d2.match_status_flag = 'N'
			     AND d2.retained_invoice_dist_id = aid.invoice_distribution_id), 0)
       WHERE invoice_distribution_id in
		         (SELECT DISTINCT retained_invoice_dist_id
			    FROM ap_invoice_distributions_all d3
                           WHERE d3.reversal_flag = 'Y'
	                     AND d3.invoice_id = p_line_rec.invoice_id
			     AND d3.invoice_line_number = p_line_rec.line_number
                             AND d3.parent_reversal_id is not null
                             AND d3.match_status_flag = 'N'
			     AND d3.retained_invoice_dist_id = aid.invoice_distribution_id);

     -- Bug 8623061 - Start
     FOR l_distribution_list_cur in c_distribution_list_cur
     LOOP

        IF l_distribution_list_cur.award_id Is Not Null Then
            l_award_id := GMS_AP_API.GET_DISTRIBUTION_AWARD(l_distribution_list_cur.award_id);

            GMS_AP_API.CREATE_AWARD_DISTRIBUTIONS
               (p_invoice_id => l_distribution_list_cur.invoice_id,
                p_distribution_line_number => l_distribution_list_cur.distribution_line_number,
                p_invoice_distribution_id => l_distribution_list_cur.invoice_distribution_id,
                p_award_id => l_award_id
               );
        End If;

     END LOOP;
     -- Bug 8623061 - End

    /*-----------------------------------------------------------------+
     |  Step 4. Reverse Distribution                                   |
     |          e.Calling JE package - comment out for now             |
     +-----------------------------------------------------------------*/
        l_debug_info := 'Calling JE Hungarian Inv Distribution Reversal';

       /*JE_HU_INV_DIST_REVERSAL.Nullify_Global_attributes
             (P_INVOICE_ID           => p_line_rec.invoice_id,
              P_DIST_MAX_LINE_NUM    => l_max_line_num); */

        -- Call GMS

        l_debug_info := 'Call Create Prepay ADL';

	IF (p_calling_mode = 'UNAPPLY_PREPAY') THEN

	   --bugfix:4542556
	   SELECT invoice_distribution_id,prepay_distribution_id
	   BULK COLLECT INTO l_key_value_list,l_key_value_list3
	   FROM ap_invoice_distributions
	   WHERE invoice_id = p_line_rec.invoice_id
	   AND invoice_line_number = p_line_rec.line_number
	   AND line_type_lookup_code = 'PREPAY'
	   AND nvl(reversal_flag,'N') = 'Y'
	   AND parent_reversal_id IS NOT NULL;

           FOR l_loop_counter IN NVL(l_key_value_list.FIRST,0) .. NVL(l_key_value_list.LAST,0) LOOP
              l_debug_info := 'Update global context code';

              --l_global_attr_category :=  l_key_value_list3(l_loop_counter);
	      IF (AP_EXTENDED_WITHHOLDING_PKG.Ap_Extended_Withholding_Active) THEN
	          AP_EXTENDED_WITHHOLDING_PKG.Ap_Ext_Withholding_Prepay (
	             p_prepay_dist_id    => l_key_value_list3(l_loop_counter),
		     p_invoice_id        => p_line_rec.invoice_id,
		     p_inv_dist_id       => l_key_value_list(l_loop_counter),
		     p_user_id           => fnd_global.user_id,
		     p_last_update_login => p_last_update_login,
		     p_calling_sequence  => p_calling_sequence );
	      END IF;

           END LOOP;

         END IF;

    /*-----------------------------------------------------------------+
     |  Step 4. Reverse Distribution                                   |
     |          g.Set reversal flag to existing distributions          |
     |            for this cancelled invoice                           |
     +-----------------------------------------------------------------*/

        l_debug_info := 'Set reversal_flag to Y for existing distributions';

        UPDATE ap_invoice_distributions
           SET reversal_flag = 'Y'
         WHERE invoice_id = p_line_rec.invoice_id
           AND invoice_line_number = p_line_rec.line_number;

      END IF; -- end of l_distribution_count check

     /*-------------------------------------------------------------------+
     | Step 5. Call ETAX: Discard Tax Distributions			 |
     +-------------------------------------------------------------------*/

     IF (nvl(p_calling_mode, 'DISCARD') <> 'CANCEL') THEN

	 IF (nvl(p_calling_mode, 'DISCARD') = 'DISCARD') THEN

            l_success := ap_etax_pkg.calling_etax(
                               P_Invoice_id         => p_line_rec.invoice_id,
                               P_Line_Number        => p_line_rec.line_number,
                               P_Calling_Mode       => 'DISCARD LINE',
                               P_All_Error_Messages => 'N',
                               P_error_code         => l_error_code,
                               P_Calling_Sequence   => l_curr_calling_sequence);

            IF (NOT l_success) THEN
               p_error_code := 'AP_ETX_DISC_LINE_CALC_TAX_FAIL';
               p_token := l_error_code;
               RETURN FALSE;
            END IF;

	 --bugfix:5697764
         ELSIF p_calling_mode = 'UNAPPLY_PREPAY' THEN

            l_success := ap_etax_pkg.calling_etax(
                               P_Invoice_id         => p_line_rec.invoice_id,
                               P_Line_Number        => p_line_rec.line_number,
                               P_Calling_Mode       => 'UNAPPLY PREPAY',
                               P_All_Error_Messages => 'N',
                               P_error_code         => l_error_code,
                               P_Calling_Sequence   => l_curr_calling_sequence);

            IF (NOT l_success) THEN
               p_error_code := 'AP_ETX_DISC_LINE_CALC_TAX_FAIL';
               p_token := l_error_code;
               RETURN FALSE;
            END IF;

	 END IF;

     END IF;


     --bugfix:5697764 start
     l_debug_info := 'p_calling_mode is  '||p_calling_mode;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     --bugfix:5765073 added the begin/end and exception handler
     BEGIN
      IF (nvl(p_calling_mode,'DISCARD') = 'UNAPPLY_PREPAY') THEN

         SELECT aid.invoice_line_number,nvl(ail1.invoice_includes_prepay_flag,'N')
         INTO l_tax_line_number,l_prepay_included
         FROM ap_invoice_distributions aid, --tax dists
              ap_invoice_lines ail1, --item line
              ap_invoice_distributions aid1 --item distributions
         WHERE ail1.invoice_id = aid1.invoice_id
         AND ail1.invoice_id = p_line_rec.invoice_id
         AND ail1.line_number = p_line_rec.line_number
         AND aid.invoice_id = aid1.invoice_id
         AND ail1.line_number = aid1.invoice_line_number
	 -- bug 7376110
	 -- The below condition added to handle prepayment with inclusive tax.
	 AND aid.invoice_line_number <> aid1.invoice_line_number
         AND aid.charge_applicable_to_dist_id = aid1.invoice_distribution_id
         GROUP BY aid.invoice_line_number,nvl(ail1.invoice_includes_prepay_flag,'N');

         l_debug_info := 'l_tax_line_number is '||l_tax_line_number;
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;

         l_dummy := AP_PREPAY_PKG.Update_Prepayment(
                                 l_prepay_dist_info,
               -- replaced NULLS with correct column values for bug #8897523
                                 l_prepay_invoice_id,     --NULL
                                 l_prepay_line_number,    --NULL
                                 p_line_rec.invoice_id,
                                 l_tax_line_number,
                                 'UNAPPLICATION',
                                 NULL,
                                 l_curr_calling_sequence,
                                 l_error_code);

         IF l_dummy = FALSE THEN
	     RETURN (FALSE);
         END IF;

         --Update the payment schedules with the unapplied tax amount
         IF NVL(l_prepay_included, 'N') = 'N' THEN

               --Bug 7526679
	       -- The query is modified to select the total amount of latest reversed tax distributions.
               SELECT sum(aid1.amount)
               INTO l_unapplied_tax_amount
               FROM ap_invoice_distributions_all aid1,
	            ap_invoice_distributions_all aid2
               WHERE aid1.invoice_id           = p_line_rec.invoice_id
	       AND aid1.invoice_id             = aid2.invoice_id
               AND aid1.invoice_line_number    = l_tax_line_number
	       AND aid2.invoice_line_number    = p_line_rec.line_number
               AND NVL(aid1.reversal_flag,'N') = 'Y'
	       AND NVL(aid2.reversal_flag,'N') = 'Y'
               AND aid1.parent_reversal_id     IS NOT NULL
               AND aid2.parent_reversal_id     IS NOT NULL
	       AND aid1.charge_applicable_to_dist_id = aid2.invoice_distribution_id;
	       --end of Bug 7526679

               IF (l_invoice_currency_code <> l_payment_currency_code) THEN
                   l_unapplied_tax_amt_pay_curr := GL_Currency_API.Convert_Amount
				                         (l_invoice_currency_code,
  				                          l_payment_currency_code,
							  l_payment_cross_rate_date,
							  l_payment_cross_rate_type,
							  (-1)* l_unapplied_tax_amount);
	       ELSE
                   l_unapplied_tax_amt_pay_curr := (-1) * l_unapplied_tax_amount;
               END IF;

               l_debug_info := 'Update the payment schedule with the unapplied exclusive prepay tax amount';

               l_debug_info := 'l_unapplied_tax_amt_pay_curr,l_unapplied_tax_amount '||
                                l_unapplied_tax_amt_pay_curr||','||l_unapplied_tax_amount;
               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
               END IF;

	       l_dummy := AP_PREPAY_PKG.Update_Payment_Schedule (
	                                   p_line_rec.invoice_id,
					   NULL,
					   NULL,
					   l_unapplied_tax_amt_pay_curr,
					   'UNAPPLICATION',
					   l_payment_currency_code,
					   FND_GLOBAL.user_id,
					   p_last_update_login,
					   p_calling_sequence,
					   NULL,
					   l_error_message);

               IF l_dummy = FALSE THEN
                 RETURN (FALSE) ;
               END IF;

           END IF;  /*l_prepay_included... */

         END IF; /*p_calling_mode = 'UNAPPLY PREPAY'...*/

	EXCEPTION WHEN OTHERS THEN
	  NULL;

	END ;
        --bugfix:5697764  end


      /*-----------------------------------------------------------------+
     |  Step 6 Proactive Cancellation Check--fires Based on profile     |
     +-----------------------------------------------------------------*/

--9100425


  BEGIN
  If  (nvl(l_cancel_proactive_flag,'N') ='C') and (NVL( P_calling_mode,'DISCARD') = 'DISCARD') THEN

  For I in(select invoice_distribution_id
     from ap_invoice_distributions aid1
     where aid1.invoice_id=P_line_rec.invoice_id
     and aid1.invoice_line_number=P_line_rec. line_number
     and aid1.parent_reversal_id is  null --original dist
     --for original dists there is no reversal dist created
     and ( not exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_line_rec.invoice_id
     and aid2.invoice_line_number=P_line_rec.line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id)
     --the reversal dist does not reverse the amount correctly
     or  exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_line_rec.invoice_id
     and aid2.invoice_line_number=P_line_rec.line_number
     and aid2.parent_reversal_id =aid1.invoice_distribution_id
     and -1 * aid2.amount <> aid1.amount))
     UNION
     select invoice_distribution_id
     from ap_invoice_distributions aid1
     where aid1.invoice_id=P_line_rec.invoice_id
     and  aid1.charge_applicable_to_dist_id in (
     select aid2.invoice_distribution_id from ap_invoice_distributions aid2
     where aid2.invoice_id=P_line_rec.invoice_id
     and   aid2.invoice_line_number=P_line_rec.line_number)
     and aid1.parent_reversal_id is  null --original dist
     and   aid1.line_type_lookup_code not in('MISCELLANEOUS','FREIGHT')
     --for original dists there is no reversal dist created
     and ( not exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_line_rec.invoice_id
     and aid2.parent_reversal_id =aid1.invoice_distribution_id)
     --the reversal dist does not reverse the amount correctly
     or  exists (select 1 from ap_invoice_distributions aid2
     where aid1.invoice_id=aid2.invoice_id
     and aid2.invoice_id=P_line_rec.invoice_id
     and aid2.parent_reversal_id =aid1.invoice_distribution_id
     and -1 * aid2.amount <> aid1.amount)))

     LOOP
       prob_dist_list := prob_dist_list||','||i.invoice_distribution_id;
       prob_dist_count:=prob_dist_count+1;
     end loop;
          IF prob_dist_count > 0 then
           p_error_code :='AP_INV_DIS_CAN_FAIL';
           P_Token := prob_dist_list;
           ROLLBACK TO SAVEPOINT CANCEL_CHECK;
           RETURN(FALSE);
          end if;

   END IF;
EXCEPTION WHEN OTHERS THEN
	  NULL;
  END;
--9100425

        l_debug_info := 'p_line_rec.invoice_id,p_line_rec.line_number : '
      			||p_line_rec.invoice_id||','||p_line_rec.line_number;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        IF (l_shipment_amt_recouped <> 0 OR l_shipment_qty_recouped <> 0) THEN

         --Start of 8928639
	 l_debug_info := 'Open Cursor prepay_inv_cur';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          OPEN prepay_inv_cur;
          LOOP

             FETCH prepay_inv_cur
             INTO l_prepay_invoice_id,
		  l_prepay_line_number;
             EXIT WHEN prepay_inv_cur%NOTFOUND;

	      l_debug_info := 'l_prepay_invoice_id: '||l_prepay_invoice_id||
	                      'l_prepay_line_number: '||l_prepay_line_number;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

           --End 8928639

             l_dummy := AP_PREPAY_PKG.Update_Prepayment(
                           l_prepay_dist_info,
                 -- replaced NULLS with correct column values for bug #8897523
                           l_prepay_invoice_id,     --NULL
                           l_prepay_line_number,    --NULL
                           p_line_rec.invoice_id,
                           p_line_rec.line_number,
                           'UNAPPLICATION',
                           NULL,
                           l_curr_calling_sequence,
                           l_error_code);

          IF l_dummy = FALSE THEN
             RETURN (FALSE);
          END IF;

	     END LOOP;
           CLOSE  prepay_inv_cur;

      END IF;

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_debug_info := 'After Discard line the distribution look like:';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_api_name,
                       l_debug_info);

         FOR l_inv_dist_rec IN dist_debug_cur
         LOOP
         l_debug_info :='they are '||
                         'dist_type = ' || l_inv_dist_rec.line_type_lookup_code||
                         'amount=' || l_inv_dist_rec.amount ||
                         'base_amount =' || l_inv_dist_rec.base_amount ||
                         'match_status_flag=' ||l_inv_dist_rec.match_status_flag ;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_api_name,
                        l_debug_info);
         END LOOP;
      END IF;

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                         'AP_INVOICE_LINES_PKG.Discard_Inv_Line(-)');
      END IF;

      p_error_code := NULL;
      RETURN (TRUE);

   END IF;  /* l_ok_to_discard OR l_ok_to_cancel */

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || p_line_rec.invoice_id
          ||' P_line_number = '     || p_line_rec.line_number
          ||' P_last_updated_by = '   || P_last_updated_by
          ||' P_last_update_login = ' || P_last_update_login
          ||' P_calling_mode = ' || p_calling_mode);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF ( po_dists_cur%ISOPEN ) THEN
        CLOSE po_dists_cur;
      END IF;

      IF (c_charge_lines%isopen) THEN
	 close c_charge_lines;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Discard_Inv_line;

  FUNCTION Reverse_Charge_Distributions
                        (p_inv_line_rec         IN  AP_INVOICE_LINES_ALL%rowtype,
                         p_calling_mode         IN  VARCHAR2,
                         x_error_code           OUT NOCOPY VARCHAR2,
                         x_debug_info           OUT NOCOPY VARCHAR2,
                         p_calling_sequence     IN  VARCHAR2) RETURN BOOLEAN IS

    l_curr_calling_sequence	VARCHAR2(2000);
    l_debug_info		VARCHAR2(240);
    l_api_name                  VARCHAR2(50);
    l_max_line_num		ap_invoice_distributions.distribution_line_number%TYPE;

  BEGIN
	l_api_name := 'Reverse_Charge_Distributions';
        ------------------------------------------------------
	Print (l_api_name,'Reverse_Charge_Distributions (+)');
        ------------------------------------------------------
        l_curr_calling_sequence := 'AP_INVOICE_LINES_PKG.Reverse_Charge_Distributions <-' || p_calling_sequence;


        l_max_line_num := AP_INVOICE_LINES_PKG.get_max_dist_line_num
						(p_inv_line_rec.invoice_id,
			                         p_inv_line_rec.line_number);

     --Bug 8733916

     UPDATE ap_invoice_distributions aid
        SET aid.encumbered_flag = 'R'
      WHERE aid.invoice_id = p_inv_line_rec.invoice_id
        AND aid.invoice_line_number = p_inv_line_rec.line_number
        AND nvl(aid.match_status_flag,'N') <> 'A'
        AND nvl(aid.encumbered_flag,'N') IN ('N','H','P')
        AND aid.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
        AND nvl(aid.reversal_flag,'N')<>'Y'
	AND EXISTS (SELECT 1
	              FROM financials_system_params_all fsp
		      WHERE fsp.org_id = aid.org_id
		        AND nvl(fsp.purch_encumbrance_flag, 'N') = 'Y');

        ------------------------------------------------------
	l_debug_info := 'Insert reverse charge distributions';
	Print (l_api_name,l_debug_info);
        ------------------------------------------------------

        INSERT INTO ap_invoice_distributions_all(
            invoice_id,
            invoice_line_number,
            dist_code_combination_id,
            invoice_distribution_id,
            last_update_date,
            last_updated_by,
            accounting_date,
            period_name,
            set_of_books_id,
            amount,
            description,
            type_1099,
            tax_code_id,
            posted_flag,
            batch_id,
            quantity_invoiced,
            corrected_quantity,
            unit_price,
            match_status_flag,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            prepay_amount_remaining,
	    prepay_distribution_id,
            assets_addition_flag,
            assets_tracking_flag,
            distribution_line_number,
            line_type_lookup_code,
            po_distribution_id,
            base_amount,
            pa_addition_flag,
            encumbered_flag,
            accrual_posted_flag,
            cash_posted_flag,
            last_update_login,
            creation_date,
            created_by,
            stat_amount,
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
            reversal_flag,
            parent_invoice_id,
            income_tax_region,
            final_match_flag,
            expenditure_item_date,
            expenditure_organization_id,
            expenditure_type,
            pa_quantity,
            project_id,
            task_id,
            quantity_variance,
            base_quantity_variance,
            awt_flag,
            awt_group_id,
            awt_tax_rate_id,
            awt_gross_amount,
            reference_1,
            reference_2,
            other_invoice_id,
            awt_invoice_id,
            awt_origin_group_id,
            program_application_id,
            program_id,
            program_update_date,
            request_id,
            tax_recoverable_flag,
            award_id,
            start_expense_date,
            merchant_document_number,
            merchant_name,
            merchant_tax_reg_number,
            merchant_taxpayer_id,
            country_of_supply,
            merchant_reference,
            parent_reversal_id,
            rcv_transaction_id,
            dist_match_type,
            matched_uom_lookup_code,
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
            receipt_verified_flag,
            receipt_required_flag,
            receipt_missing_flag,
            justification,
            expense_Group,
            end_Expense_Date,
            receipt_Currency_Code,
            receipt_Conversion_Rate,
            receipt_Currency_Amount,
            daily_Amount,
            web_Parameter_Id,
            adjustment_Reason,
            credit_Card_Trx_Id,
            company_Prepaid_Invoice_Id,
            org_id,
            rounding_amt,
            charge_applicable_to_dist_id,
            corrected_invoice_dist_id,
            related_id,
            asset_book_type_code,
            asset_category_id,
            accounting_event_id,
            cancellation_flag,
	    distribution_class,
	    intended_use,
	    --Freight and Special Charges
	    rcv_charge_addition_flag)
            (SELECT
             Invoice_Id,                                 -- invoice_id
             Invoice_Line_Number,                        -- invoice_line_number
             Dist_Code_Combination_Id,                   -- dist_code_combination_id
             ap_invoice_distributions_s.NEXTVAL,         -- distribution_id
             sysdate,                                    -- last_update_date
             fnd_global.user_id,                         -- last_updated_by
              /* Bug 5584997, Getting the accounting_date from line rec */
             DECODE(P_calling_mode,'UNAPPLY_PREPAY',p_inv_line_rec.accounting_date,
                    ap_utilities_pkg.get_reversal_gl_date(p_inv_line_rec.accounting_date, org_id)),
                                                         -- accounting_date
             DECODE(P_calling_mode,'UNAPPLY_PREPAY',p_inv_line_rec.period_name,
                    ap_utilities_pkg.get_reversal_period(p_inv_line_rec.accounting_date, org_id)),
                                                         --  period_name,
             Set_Of_Books_Id, 				 -- set_of_book_id
             -1 * Amount,                                -- amount
             Description,                                -- description
             Type_1099,                                  -- type_1099
             Tax_Code_Id,                                -- tax_code_id
             'N',                                        -- posted_flag,
             Batch_Id,                                   -- batch_id
             DECODE(quantity_invoiced, NULL, '', -1 * quantity_invoiced),
                                                         -- quantity_invoiced
             DECODE(corrected_quantity, NULL, '',
                    DECODE(dist_match_type, 'PRICE_CORRECTION',
                           corrected_quantity, (-1)*corrected_quantity) ),
                                                         -- corrected_quanity
             DECODE(unit_price, NULL,'',
                    DECODE(dist_match_type, 'PRICE_CORRECTION',
                           (-1)*unit_price, unit_price) ),
                                                         -- unit_price,
             'N',                                        -- match_status_flag
             attribute_category,                         -- attribute_category
             attribute1,                                 -- attribute1
             attribute2,                                 -- attribute2
             attribute3,                                 -- attribute3
             attribute4,                                 -- attribute4
             attribute5,                                 -- attribute5
             NULL,                                       -- prepay_amount_remaining
             prepay_distribution_id,                     -- prepay_distribution_id
             'U',                                        -- assets_addition_flag
             Assets_Tracking_Flag,                       -- assets_tracking_flag
             Distribution_Line_Number + l_max_line_num , -- distribution_line_number
             Line_Type_Lookup_Code,                      -- line_type_lookup_code
             Po_Distribution_Id,                         -- po_distribution_id
             -1 * Base_Amount,                           -- base_amount
             DECODE(Pa_Addition_Flag, 'E', 'E', 'N'),    -- pa_addition_flag
             DECODE( encumbered_flag, 'R', 'R', 'N'),    -- encumbered_flag,
             'N',                                        -- accrual_posted_flag,
             'N',                                        -- cash_posted_flag,
             fnd_global.login_id,                        -- last_update_login
             sysdate,                                    -- creation_date,
             FND_GLOBAL.user_id,                         -- created_by,
             -1 * Stat_Amount,                           -- stat_amount
             attribute11,                                -- attribute11,
             attribute12,                                -- attribute12,
             attribute13,                                -- attribute13,
             attribute14,                                -- attribute14,
             attribute6,                                 -- attribute6,
             attribute7,                                 -- attribute7,
             attribute8,                                 -- attribute8,
             attribute9,                                 -- attribute9,
             attribute10,                                -- attribute10,
             attribute15,                                -- attribute15,
             'Y',                                        -- reversal_flag,
             Parent_Invoice_Id,                          -- parent_invoice_id
             Income_Tax_Region,                          -- income_tax_region
             Final_Match_Flag,                           -- final_match_flag
             Expenditure_Item_Date,                      -- expenditure_item_date
             Expenditure_Organization_Id,                -- expenditure_orgnization_id
             Expenditure_Type,                           -- expenditure_type
             -1 * Pa_Quantity,                           -- pa_quantity
             Project_Id,                                 -- project_id
             Task_Id,                                    -- task_id
             -1 * Quantity_Variance,                     -- quantity_variance
             -1 * Base_Quantity_Variance,                -- base quantity_variance
             awt_flag,                                   -- awt_flag
             awt_group_id,                               -- awt_group_id,
             awt_tax_rate_id,                            -- awt_tax_rate_id
             awt_gross_amount,                           -- awt_gross_amount
             reference_1,                                -- reference_1
             reference_2,                                -- reference_2
             other_invoice_id,                           -- other_invoice_id
             awt_invoice_id,                             -- awt_invoice_id
             awt_origin_group_id,                        -- awt_origin_group_id
             FND_GLOBAL.prog_appl_id,                    -- program_application_id
             FND_GLOBAL.conc_program_id,                 -- program_id
             SYSDATE,                                    -- program_update_date,
             FND_GLOBAL.conc_request_id,                 -- request_id
             tax_recoverable_flag,                       -- tax_recoverable_flag
             award_id,                                   -- award_id
             start_expense_date,                         -- start_expense_date
             merchant_document_number,                   -- merchant_document_number
             merchant_name,                              -- merchant_name
             merchant_tax_reg_number,                    -- merchant_tax_reg_number
             merchant_taxpayer_id,                       -- merchant_taxpayer_id
             country_of_supply,                          -- country_of_supply
             merchant_reference,                         -- merchant_reference
             invoice_distribution_id,                    -- Parent_Reversal_Id
             rcv_transaction_id,                         -- rcv_transaction_id
             dist_match_type,                            -- dist_match_type
             matched_uom_lookup_code,                    -- matched_uom_lookup_code
             global_attribute_category,                  -- global_attribute_category
             global_attribute1,                          -- global_attribute1
             global_attribute2,                          -- global_attribute2
             global_attribute3,                          -- global_attribute3
             global_attribute4,                          -- global_attribute4
             global_attribute5,                          -- global_attribute5
             global_attribute6,                          -- global_attribute6
             global_attribute7,                          -- global_attribute7
             global_attribute8,                          -- global_attribute8
             global_attribute9,                          -- global_attribute9
             global_attribute10,                         -- global_attribute10
             global_attribute11,                         -- global_attribute11
             global_attribute12,                         -- global_attribute12
             global_attribute13,                         -- global_attribute13
             global_attribute14,                         -- global_attribute14
             global_attribute15,                         -- global_attribute15
             global_attribute16,                         -- global_attribute16
             global_attribute17,                         -- global_attribute17
             global_attribute18,                         -- global_attribute18
             global_attribute19,                         -- global_attribute19
             global_attribute20,                         -- global_attribute20
             receipt_verified_flag,                      -- receipt_verified_flag
             receipt_required_flag,                      -- receipt_required_flag
             receipt_missing_flag,                       -- receipt_missing_flag
             justification,                              -- justification
             expense_Group,                              -- expense_Group
             end_Expense_Date,                           -- end_Expense_Date
             receipt_Currency_Code,                      -- receipt_Currency_Code
             receipt_Conversion_Rate,                    -- receipt_Conversion_Rate
             receipt_Currency_Amount,                    -- receipt_Currency_Amount
             daily_Amount,                               -- daily_Amount
             web_Parameter_Id,                           -- web_Parameter_Id
             adjustment_Reason,                          -- adjustment_Reason
             credit_Card_Trx_Id,                         -- credit_Card_Trx_Id
             company_Prepaid_Invoice_Id,                 -- company_Prepaid_Invoice_Id
             org_id,                                     -- MOAC project org_id
             -1* rounding_amt,                           -- rounding_amt
             charge_applicable_to_dist_id,               -- charge_applicable_to_dist_id
             corrected_invoice_dist_id,                  -- corrected_invoice_dist_id
             DECODE( related_id, NULL, NULL,
                     invoice_distribution_id,
                     ap_invoice_distributions_s.CURRVAL,
		     --bugfix:4921399
                     NULL ),                 		  -- related_id
             asset_book_type_code,                       -- asset_book_type_code
             asset_category_id,                          -- asset_category_id
             NULL,                                       -- accounting_event_id
             decode(p_calling_mode, 'CANCEL',decode ( line_type_lookup_code ,'PREPAY' , NULL ,'Y'),null), -- cancellation_flag bug9173973
	     'PERMANENT',
	     intended_use,				 -- intended_use
	     'N'					 -- rcv_charge_addition_flag
             FROM  ap_invoice_distributions_all
             WHERE invoice_id                  = p_inv_line_rec.invoice_id
             AND   invoice_line_number         = p_inv_line_rec.line_number
	     AND   (reversal_flag is null
                    or reversal_flag = 'N')
             AND   (
	            (line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
		     and prepay_distribution_id IS NULL) OR
		     prepay_distribution_id IS NOT NULL
                   )
             AND   (line_type_lookup_code     <> 'AWT' OR
                   (line_type_lookup_code      = 'AWT' AND awt_flag <> 'A'))
	   ) ;

        ---------------------------------------------------------------
        l_debug_info := 'Update reversal_flag on charge distributions';
	  Print (l_api_name,l_debug_info);
        ---------------------------------------------------------------
--Bug8733916

        UPDATE ap_invoice_distributions
           SET reversal_flag = 'Y'
         WHERE invoice_id = p_inv_line_rec.invoice_id
           AND invoice_line_number = p_inv_line_rec.line_number
           AND line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV');

        --------------------------------------------------------------
      	Print(l_api_name,'Reverse_Charge_Distributions (-)');
        --------------------------------------------------------------

        RETURN TRUE;

  EXCEPTION
	WHEN OTHERS THEN
	  IF (SQLCODE <> -20001) THEN
	      FND_MESSAGE.SET_NAME  ('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN ('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN ('CALLING_SEQUENCE',l_curr_calling_sequence);
              FND_MESSAGE.SET_TOKEN ('PARAMETERS',
			             	    ' P_invoice_id   = '|| p_inv_line_rec.invoice_id
				          ||' P_line_number  = '|| p_inv_line_rec.line_number
				          ||' P_calling_mode = '|| p_calling_mode);
	     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
          END IF;

          x_debug_info := l_debug_info;

	  RETURN FALSE;

  END Reverse_Charge_Distributions;

  PROCEDURE Print (p_api_name   IN VARCHAR2,
		   p_debug_info IN VARCHAR2) IS
  BEGIN
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||p_api_name,p_debug_info);
        END IF;
  END Print;

END AP_INVOICE_LINES_PKG;


/
