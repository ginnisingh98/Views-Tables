--------------------------------------------------------
--  DDL for Package Body AP_GENERATE_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_GENERATE_DISTRIBUTIONS_PKG" AS
/*$Header: apaidutb.pls 120.16.12010000.5 2010/01/20 11:14:02 baole ship $ */

  --Bugfix:3859755, added the below FND_LOG related variables, in order
  --to enable LOGGING for this package.
  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_GENERATE_DISTRIBUTIONS_PKG';
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
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_GENERATE_DISTRIBUTIONS_PKG.';

  CURSOR G_INVOICE_LINES_CURSOR(P_Invoice_ID Number,
			       P_Invoice_Line_Number NUMBER) IS
  SELECT INVOICE_ID,
         LINE_NUMBER,
         LINE_TYPE_LOOKUP_CODE,
         REQUESTER_ID,
         DESCRIPTION,
         LINE_SOURCE,
         ORG_ID,
         LINE_GROUP_NUMBER,
         INVENTORY_ITEM_ID,
         ITEM_DESCRIPTION,
         SERIAL_NUMBER,
         MANUFACTURER,
         MODEL_NUMBER,
         WARRANTY_NUMBER,
         GENERATE_DISTS,
         MATCH_TYPE,
         DISTRIBUTION_SET_ID,
         ACCOUNT_SEGMENT,
         BALANCING_SEGMENT,
         COST_CENTER_SEGMENT,
         OVERLAY_DIST_CODE_CONCAT,
         DEFAULT_DIST_CCID,
         PRORATE_ACROSS_ALL_ITEMS,
         ACCOUNTING_DATE,
         PERIOD_NAME ,
         DEFERRED_ACCTG_FLAG ,
         DEF_ACCTG_START_DATE ,
         DEF_ACCTG_END_DATE,
         DEF_ACCTG_NUMBER_OF_PERIODS,
         DEF_ACCTG_PERIOD_TYPE ,
         SET_OF_BOOKS_ID,
         AMOUNT,
         BASE_AMOUNT,
         ROUNDING_AMT,
         QUANTITY_INVOICED,
         UNIT_MEAS_LOOKUP_CODE ,
         UNIT_PRICE,
         WFAPPROVAL_STATUS,
         DISCARDED_FLAG,
         ORIGINAL_AMOUNT,
         ORIGINAL_BASE_AMOUNT ,
         ORIGINAL_ROUNDING_AMT ,
         CANCELLED_FLAG ,
         INCOME_TAX_REGION,
         TYPE_1099   ,
         STAT_AMOUNT  ,
         PREPAY_INVOICE_ID ,
         PREPAY_LINE_NUMBER  ,
         INVOICE_INCLUDES_PREPAY_FLAG ,
         CORRECTED_INV_ID ,
         CORRECTED_LINE_NUMBER ,
         PO_HEADER_ID,
         PO_LINE_ID  ,
         PO_RELEASE_ID ,
         PO_LINE_LOCATION_ID ,
         PO_DISTRIBUTION_ID,
         RCV_TRANSACTION_ID,
         FINAL_MATCH_FLAG,
         ASSETS_TRACKING_FLAG ,
         ASSET_BOOK_TYPE_CODE ,
         ASSET_CATEGORY_ID ,
         PROJECT_ID ,
         TASK_ID ,
         EXPENDITURE_TYPE ,
         EXPENDITURE_ITEM_DATE ,
         EXPENDITURE_ORGANIZATION_ID ,
         PA_QUANTITY,
         PA_CC_AR_INVOICE_ID ,
         PA_CC_AR_INVOICE_LINE_NUM ,
         PA_CC_PROCESSED_CODE ,
         AWARD_ID,
         AWT_GROUP_ID ,
         REFERENCE_1 ,
         REFERENCE_2 ,
         RECEIPT_VERIFIED_FLAG  ,
         RECEIPT_REQUIRED_FLAG ,
         RECEIPT_MISSING_FLAG ,
         JUSTIFICATION  ,
         EXPENSE_GROUP ,
         START_EXPENSE_DATE ,
         END_EXPENSE_DATE ,
         RECEIPT_CURRENCY_CODE  ,
         RECEIPT_CONVERSION_RATE,
         RECEIPT_CURRENCY_AMOUNT ,
         DAILY_AMOUNT ,
         WEB_PARAMETER_ID ,
         ADJUSTMENT_REASON ,
         MERCHANT_DOCUMENT_NUMBER ,
         MERCHANT_NAME ,
         MERCHANT_REFERENCE ,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID  ,
         COUNTRY_OF_SUPPLY,
         CREDIT_CARD_TRX_ID ,
         COMPANY_PREPAID_INVOICE_ID,
         CC_REVERSAL_FLAG ,
         CREATION_DATE ,
         CREATED_BY,
         LAST_UPDATED_BY ,
         LAST_UPDATE_DATE ,
         LAST_UPDATE_LOGIN ,
         PROGRAM_APPLICATION_ID ,
         PROGRAM_ID ,
         PROGRAM_UPDATE_DATE,
         REQUEST_ID ,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
	 --ETAX: Invwkb
	 INCLUDED_TAX_AMOUNT,
	 PRIMARY_INTENDED_USE,
	 --Bugfix:4673607
	 APPLICATION_ID,
	 PRODUCT_TABLE,
	 REFERENCE_KEY1,
	 REFERENCE_KEY2,
	 REFERENCE_KEY3,
	 REFERENCE_KEY4,
	 REFERENCE_KEY5,
	 --bugfix:4674194
	 SHIP_TO_LOCATION_ID,
	 --bug7022001
	 PAY_AWT_GROUP_ID
  FROM AP_INVOICE_LINES AIL
  WHERE AIL.INVOICE_ID = P_INVOICE_ID
  AND AIL.LINE_NUMBER = NVL(P_INVOICE_LINE_NUMBER,AIL.LINE_NUMBER)
  AND LINE_TYPE_LOOKUP_CODE IN ('ITEM','FREIGHT','MISCELLANEOUS')
  AND NVL(AIL.GENERATE_DISTS,'N') = 'Y'
  ORDER BY DECODE(AIL.LINE_TYPE_LOOKUP_CODE,'ITEM',1,2), LINE_NUMBER;


FUNCTION Generate_Dists_For_Invoice (
                        P_Invoice_Id     	  	IN  NUMBER,
  			P_Batch_Id		   	IN  NUMBER,
			P_Invoice_Date     		IN  DATE,
			P_Vendor_Id	   		IN  NUMBER,
			P_Invoice_Currency_Code 	IN  VARCHAR2,
 			P_Exchange_Rate    		IN  NUMBER,
			P_Exchange_Rate_Type 		IN  VARCHAR2,
			P_Exchange_Date    		IN  DATE,
			P_Calling_Mode			IN  VARCHAR2,
			P_Error_Code			OUT NOCOPY VARCHAR2,
			P_Token1			OUT NOCOPY VARCHAR2,
			P_Token2			OUT NOCOPY VARCHAR2,
                        P_Calling_Sequence 		IN  VARCHAR2)
							 RETURN BOOLEAN IS


--Bug 6802813: Added new cursor to generate tax distributions
--             while navigating from 'All Distributions' button.
CURSOR c_tax_lines IS
SELECT 'Tax Lines not fully distributed'
  FROM AP_INVOICE_LINES_ALL AIL
  WHERE AIL.INVOICE_ID = P_INVOICE_ID
  AND AIL.LINE_TYPE_LOOKUP_CODE = 'TAX'
  AND AIL.amount <>
	(SELECT nvl(sum(amount),0)
	   FROM AP_INVOICE_DISTRIBUTIONS_ALL AID
	  WHERE AID.INVOICE_ID = AIL.INVOICE_ID
	    AND AID.INVOICE_LINE_NUMBER = AIL.LINE_NUMBER);

l_tax_lines VARCHAR2(200);

t_inv_lines_table       AP_INVOICES_PKG.t_invoice_lines_table;
l_success		BOOLEAN := TRUE;
l_error_code            VARCHAR2(4000);
i                       NUMBER;
l_system_user           NUMBER := 5;
l_holds                 AP_APPROVAL_PKG.HOLDSARRAY;
l_hold_count            AP_APPROVAL_PKG.COUNTARRAY;
l_release_count         AP_APPROVAL_PKG.COUNTARRAY;
l_insufficient_data_exist  BOOLEAN := TRUE;
l_debug_info		VARCHAR2(2000);
l_curr_calling_sequence VARCHAR2(2000);
l_debug_context         VARCHAR2(2000);

l_invoice_num	        VARCHAR2(50);
l_line_number   	NUMBER;
l_api_name		CONSTANT VARCHAR2(200) := 'Generate_Dists_For_Invoice';

BEGIN

  l_curr_calling_sequence := 'AP_GENERATE_DISTRIBUTIONS_PKG.'||
	    'Generate_Dists_for_Invoice <- '||p_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_GENERATE_DISTRIBUTIONS_PKG.Generate_Dists_for_Invoice(+)');
  END IF;

  l_debug_info := 'Open G_Invoice_Lines Cursor';

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

  --If some reason the earlier call to generate distributions did not success
  --due to an error in the etax pkgs, which raise the error in those pkgs itself
  --, then we will not be able to close the cursor and exit.
  IF (G_INVOICE_LINES_CURSOR%ISOPEN ) THEN
     CLOSE G_Invoice_Lines_Cursor ;
  END IF;

  OPEN G_Invoice_Lines_Cursor(P_Invoice_Id, NULL);

  FETCH G_Invoice_Lines_Cursor BULK COLLECT INTO t_inv_lines_table;

  CLOSE G_Invoice_Lines_Cursor;

  IF (t_inv_lines_table.count <> 0 ) THEN

    IF (p_calling_mode = 'INVOICE HEADER') THEN

      --Since the invoice is not 'Validated' yet, we will need to
      --Calculate-Tax on the invoice before generating the candidate
      --distributions for the taxable lines.

      l_debug_info := 'Call etax api to Calculate-Tax';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;


      l_success := ap_etax_pkg.calling_etax(
			 p_invoice_id  => p_invoice_id,
                         p_calling_mode => 'CALCULATE',
                         p_all_error_messages => 'N',
                         p_error_code =>  l_error_code,
                         p_calling_sequence => l_curr_calling_sequence);

       --If Tax-Calculation Failed
       IF NOT(l_success) THEN
         l_debug_info := 'Call to EBTax api - Calculate Tax failed';
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;

         P_Error_Code := 'AP_CANNOT_GEN_DIST_DUE_TAX';
         P_Token1 := l_error_code;
         IF (G_Invoice_Lines_Cursor%ISOPEN) THEN
   	   Close G_Invoice_Lines_Cursor;
         End If;

         Return(FALSE);
       END IF;

    END IF; -- p_calling_mode = 'INVOICE HEADER'

    /* Bug 5342316. reopening the cursor again, so that included_tax_amount
       for lines reflected correctly. */

    OPEN G_Invoice_Lines_Cursor(P_Invoice_Id, NULL);

    FETCH G_Invoice_Lines_Cursor BULK COLLECT INTO t_inv_lines_table;

    CLOSE G_Invoice_Lines_Cursor;


    FOR i in t_inv_lines_table.first .. t_inv_lines_table.last LOOP

        IF(t_inv_lines_table.exists(i)) THEN

	   --bugfix:5685469 added the below code to generate allocation rule
           IF t_inv_lines_table(i).line_type_lookup_code in
	                ('FREIGHT', 'MISCELLANEOUS') THEN

               ----------------------------------------------------------------
               l_debug_info := 'Create Allocation Rule ';
               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	       END IF;
               ----------------------------------------------------------------

               IF (t_inv_lines_table(i).prorate_across_all_items='Y') then

                   l_success := AP_ALLOCATION_RULES_PKG.Create_Proration_Rule(
                                         t_inv_lines_table(i).invoice_id,
                                         t_inv_lines_table(i).line_number,
                                         NULL,
                                         'APAIDUTB',
				         l_error_code,
				         l_debug_info,
				         l_debug_context,
				         'Generate_Dists_For_Invoice');

                END IF;
           END IF;


	   IF (t_inv_lines_table(i).generate_dists = 'Y') THEN

	      IF t_inv_lines_table(i).line_type_lookup_code <> 'TAX' THEN

                 l_debug_info := 'Check if sufficient data is provided to generate candidate distributions';

                 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                 END IF;

                 AP_Approval_Pkg.Check_Insufficient_Line_Data(
               		  p_inv_line_rec            => t_inv_lines_table(i),
                    	  p_system_user             => l_system_user,
                          p_holds                   => l_holds,
                          p_holds_count             => l_hold_count,
                          p_release_count           => l_release_count,
                          p_insufficient_data_exist => l_insufficient_data_exist,
                          p_calling_mode            => 'CANDIDATE_DISTRIBUTIONS',
                          p_calling_sequence        => l_curr_calling_sequence );

                 IF ( NOT l_insufficient_data_exist ) THEN

                     l_debug_info := 'Generating Candidate Distributions
				 for Taxable Line';

                     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                     END IF;

                     l_success := AP_Approval_Pkg.Execute_Dist_Generation_Check(
			 p_batch_id           => p_batch_id,
       	                 p_invoice_date       => p_invoice_date,
                         p_vendor_id          => p_vendor_id,
                 	 p_invoice_currency   => p_invoice_currency_code,
                 	 p_exchange_rate      => p_exchange_rate,
                 	 p_exchange_rate_type => p_exchange_rate_type,
                 	 p_exchange_date      => p_exchange_date,
                 	 p_inv_line_rec       => t_inv_lines_table(i),
                 	 p_system_user        => l_system_user,
                 	 p_holds              => l_holds,
                 	 p_holds_count        => l_hold_count,
                 	 p_release_count      => l_release_count,
                 	 p_generate_permanent => 'N',
                 	 p_calling_mode       => 'CANDIDATE_DISTRIBUTIONS',
                 	 p_error_code         => l_error_code,
                 	 p_curr_calling_sequence => l_curr_calling_sequence);

                    IF NOT(l_success) THEN

 		       l_debug_info := 'Could not Generate the Taxable Distributions';
       	               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                       END IF;

                       P_Error_Code := 'AP_CANNOT_GEN_TAXABLE_DISTS';
	               P_Token1     := t_inv_lines_table(i).line_number;

                       -- Bug 7936518: Start
                       --   P_Token2 := l_error_code;

            	       If (substr(l_error_code,1,3) = 'GMS') then
                            P_Token2 := FND_MESSAGE.GET_STRING('GMS',l_error_code);
                       Else
                            P_Token2 := l_error_code;
                       End if;
                       -- Bug 7936518: End

                       IF(G_Invoice_Lines_Cursor%ISOPEN) THEN
                          Close G_Invoice_Lines_Cursor;
                       End if;
	               Return(FALSE);

                    END IF;

               ELSE

	         P_Error_Code := 'AP_INSUFF_TAXABLE_DIST_INFO';
	         P_Token1     := t_inv_lines_table(i).line_number;

                 If(G_Invoice_Lines_Cursor%ISOPEN) THEN
                    Close G_Invoice_Lines_Cursor;
                 End if;

	         Return(FALSE);

              END IF; -- end of sufficient data check
   	   END IF; -- end of line_type_lookup_code check
	  END IF; -- end of generate_dists check

        END IF;  /* t_inv_lines_table(i).exists */

     END LOOP;

     l_debug_info := 'Generate Tax Distributions';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     l_success := ap_etax_pkg.calling_etax (
                     p_invoice_id  => p_invoice_id,
                     p_calling_mode => 'DISTRIBUTE',
                     p_all_error_messages => 'N',
                     p_error_code =>  l_error_code,
                     p_calling_sequence => l_curr_calling_sequence);


     IF (NOT l_success) THEN

	l_debug_info := 'Call to EBTax api Determine Recovery failed';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

    	P_Error_Code := 'AP_CANNOT_DISTRIBUTE_TAX';
    	P_Token1     := l_error_code;
    	IF (G_Invoice_Lines_Cursor%ISOPEN) THEN
      	   Close G_Invoice_Lines_Cursor;
    	End if;
    	Return(FALSE);
     END IF;

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_GENERATE_DISTRIBUTIONS_PKG.Generate_Dists_for_Invoice(-)');
     END IF;

     Return(TRUE);

  ELSE

        l_debug_info := 'Standalone: Item/Freight/Misc Distributions have been generated';

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

     -- Bug 6802813 Start
      OPEN c_tax_lines;
     FETCH c_tax_lines
      INTO l_tax_lines;
     CLOSE c_tax_lines;

     IF l_tax_lines IS NOT NULL THEN

-- bug 9246414: add start
        l_debug_info := 'Call etax api to Calculate-Tax';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        l_success := ap_etax_pkg.calling_etax(
                         p_invoice_id  => p_invoice_id,
                         p_calling_mode => 'CALCULATE',
                         p_all_error_messages => 'N',
                         p_error_code =>  l_error_code,
                         p_calling_sequence => l_curr_calling_sequence);

        --If Tax-Calculation Failed
        IF NOT(l_success) THEN
            l_debug_info := 'Call to EBTax api - Calculate Tax failed';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            P_Error_Code := 'AP_CANNOT_GEN_DIST_DUE_TAX';
            P_Token1 := l_error_code;
            IF (G_Invoice_Lines_Cursor%ISOPEN) THEN
      	         Close G_Invoice_Lines_Cursor;
            End If;

            Return(FALSE);
        END IF;
-- bug 9246414: add end

        l_debug_info := 'Standalone: Generate Tax Distributions';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        l_success := ap_etax_pkg.calling_etax (
	                     p_invoice_id  => p_invoice_id,
	                     p_calling_mode => 'DISTRIBUTE',
	                     p_all_error_messages => 'N',
	                     p_error_code =>  l_error_code,
	                     p_calling_sequence => l_curr_calling_sequence);


        IF (NOT l_success) THEN

	   l_debug_info := 'Standalone: Call to EBTax api Determine Recovery failed';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;

           P_Error_Code := 'AP_CANNOT_DISTRIBUTE_TAX';
           P_Token1     := l_error_code;
           Return(FALSE);

        END IF;

     END IF;
     -- Bug 6802813 End.

     --Do nothing, just return as successful.
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_GENERATE_DISTRIBUTIONS_PKG.Generate_Dists_for_Invoice(-)');
     END IF;

     Return(TRUE);

  END IF; /* t_inv_lines_table.count <> 0 */


EXCEPTION WHEN OTHERS THEN
  IF ( SQLCODE = -54 ) THEN
     FND_MESSAGE.SET_NAME('SQLAP', 'AP_INVOICE_UPDATED_REQUERY');
     IF (G_INVOICE_LINES_CURSOR%ISOPEN ) THEN
       CLOSE G_Invoice_Lines_Cursor ;
     END IF;
  ELSIF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'Invoice Id = '|| to_char(p_invoice_id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

     IF (G_INVOICE_LINES_CURSOR%ISOPEN ) THEN
       CLOSE G_Invoice_Lines_Cursor ;
     END IF;
  END IF;

  APP_EXCEPTION.RAISE_EXCEPTION;

END Generate_Dists_For_Invoice;



FUNCTION Generate_Dists_For_Line (
                        P_Invoice_Id            IN NUMBER,
			P_Invoice_Line_Number   IN NUMBER,
			P_Batch_Id              IN NUMBER,
                        P_Invoice_Date          IN DATE,
                        P_Vendor_Id             IN NUMBER,
                        P_Invoice_Currency_Code IN VARCHAR2,
                        P_Exchange_Rate         IN NUMBER,
                        P_Exchange_Rate_Type    IN VARCHAR2,
                        P_Exchange_Date         IN DATE,
                        P_Error_Code	        OUT NOCOPY VARCHAR2,
			P_Token1		OUT NOCOPY VARCHAR2,
			P_Token2		OUT NOCOPY VARCHAR2,
                        P_Calling_Sequence      IN VARCHAR2) RETURN BOOLEAN IS

t_inv_lines_table       AP_INVOICES_PKG.t_invoice_lines_table;
l_success               BOOLEAN := TRUE;
l_error_code            VARCHAR2(4000);
i                       NUMBER;
l_system_user           NUMBER := 5;
l_holds                 AP_APPROVAL_PKG.HOLDSARRAY;
l_hold_count            AP_APPROVAL_PKG.COUNTARRAY;
l_release_count         AP_APPROVAL_PKG.COUNTARRAY;
l_insufficient_data_exist  BOOLEAN := TRUE ;
l_included_tax_amount   NUMBER;
l_api_name		CONSTANT VARCHAR2(200) := 'Generate_Dists_for_Line';
l_debug_info            VARCHAR2(2000);
l_debug_context         VARCHAR2(2000);
l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_GENERATE_DISTRIBUTIONS_PKG.'||
            'Generate_Dists_for_Line <- '||p_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_GENERATE_DISTRIBUTIONS_PKG.Generate_Dists_for_Line(+)');
  END IF;

  /* Bug 5362316. Move the tax call before Opening Cursor */
  l_debug_info := 'Call etax api to Calculate-Tax for just that invoice line';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  l_success := ap_etax_pkg.calling_etax(
                         p_invoice_id  => p_invoice_id,
                         p_line_number => p_invoice_line_number,
                         p_calling_mode => 'CALCULATE',
                         p_all_error_messages => 'N',
                         p_error_code =>  l_error_code,
                         p_calling_sequence => l_curr_calling_sequence);

  --Tax-Calculation Failed
  IF NOT(l_success) THEN

    l_debug_info := 'Call to EBTax api Calculate Tax failed';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    P_Error_Code := 'AP_CANNOT_GEN_DIST_DUE_TAX';
    P_Token1 := l_error_code;

    IF (G_Invoice_Lines_Cursor%ISOPEN) THEN
       Close G_Invoice_Lines_Cursor;
    END IF;
    RETURN FALSE;

  END IF;

   --If some reason the earlier call to generate distributions did not success
   --due to an error in the etax pkgs, which raise the error in those pkgs itself
   --, then we will not be able to close the cursor and exit.
  IF (G_INVOICE_LINES_CURSOR%ISOPEN ) THEN
    CLOSE G_Invoice_Lines_Cursor ;
  END IF;


  l_debug_info := 'Open G_Invoice_Lines Cursor';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN G_Invoice_Lines_Cursor(P_Invoice_Id ,
			      P_Invoice_Line_Number);

  FETCH G_Invoice_Lines_Cursor BULK COLLECT INTO t_inv_lines_table;

  CLOSE G_Invoice_Lines_Cursor;

  l_debug_info := 'Check if sufficient data is provided to generate candidate distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  i := t_inv_lines_table.first;

  IF (t_inv_lines_table.exists(i)) Then

      IF t_inv_lines_table(i).line_type_lookup_code in
               ('FREIGHT', 'MISCELLANEOUS') THEN

          ----------------------------------------------------------------
          l_debug_info := 'Create Allocation Rule ';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
          ----------------------------------------------------------------

	  --bugfix:5685469 added the below code to generate allocation rule
          IF (t_inv_lines_table(i).prorate_across_all_items='Y') then

                l_success := AP_ALLOCATION_RULES_PKG.Create_Proration_Rule(
                                             t_inv_lines_table(i).invoice_id,
                                             t_inv_lines_table(i).line_number,
                                             NULL,
                                             'APAIDUTB',
                                             l_error_code,
                                             l_debug_info,
                                             l_debug_context,
                                             'Generate_Dists_For_Invoice_Line');

          END IF;
      END IF;


      IF (t_inv_lines_table(i).generate_dists = 'Y') THEN

         AP_Approval_Pkg.Check_Insufficient_Line_Data(
                 p_inv_line_rec            => t_inv_lines_table(i),
                 p_system_user             => l_system_user,
                 p_holds                   => l_holds,
                 p_holds_count             => l_hold_count,
                 p_release_count           => l_release_count,
                 p_insufficient_data_exist => l_insufficient_data_exist,
                 p_calling_mode            => 'CANDIDATE_DISTRIBUTIONS',
                 p_calling_sequence        => l_curr_calling_sequence );

      END IF;

   END IF; /* t_inv_lines_table.exists(i) */


   IF ( NOT l_insufficient_data_exist ) THEN

       l_debug_info := 'Generating Candidate Distributions for Taxable Line';

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       l_success := AP_Approval_Pkg.Execute_Dist_Generation_Check(
                 	p_batch_id           => p_batch_id,
                 	p_invoice_date       => p_invoice_date,
                 	p_vendor_id          => p_vendor_id,
                 	p_invoice_currency   => p_invoice_currency_code,
                 	p_exchange_rate      => p_exchange_rate,
                 	p_exchange_rate_type => p_exchange_rate_type,
                 	p_exchange_date      => p_exchange_date,
                 	p_inv_line_rec       => t_inv_lines_table(i),
                 	p_system_user        => l_system_user,
                 	p_holds              => l_holds,
                 	p_holds_count        => l_hold_count,
                 	p_release_count      => l_release_count,
                 	p_generate_permanent => 'N',
                 	p_calling_mode       => 'CANDIDATE_DISTRIBUTIONS',
                 	p_error_code         => l_error_code,
                 	p_curr_calling_sequence => l_curr_calling_sequence);


        IF NOT(l_success) THEN
	   l_debug_info := 'Cannot Generate Distributions for the Taxable Line';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;

           P_Error_Code := 'AP_CANNOT_GEN_TAXABLE_DISTS';
           P_Token1 := p_invoice_line_number;

-- Bug 7936518: Start
-- 	   P_Token2 := l_error_code;

	   If (substr(l_error_code,1,3) = 'GMS') then
                P_Token2 := FND_MESSAGE.GET_STRING('GMS',l_error_code);
           Else
                P_Token2 := l_error_code;
           End if;
-- Bug 7936518: End

           If(G_Invoice_Lines_Cursor%ISOPEN) THEN
              Close G_Invoice_Lines_Cursor;
           End if;
           return(FALSE);

        END IF;

	SELECT nvl(included_tax_amount,0)
	INTO l_included_tax_amount
	FROM ap_invoice_lines
	WHERE invoice_id = p_invoice_id
	AND line_number = p_invoice_line_number;

        l_debug_info := 'l_included_tax_amount : '||l_included_tax_amount;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        IF (nvl(l_included_tax_amount,0) <> 0) THEN

           l_debug_info := 'Call EBTax api to Determine Recovery for just that invoice line';
	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;

           l_success := ap_etax_pkg.calling_etax(
                         p_invoice_id  => p_invoice_id,
                         p_line_number => p_invoice_line_number,
                         p_calling_mode => 'DISTRIBUTE',
                         p_all_error_messages => 'N',
                         p_error_code =>  l_error_code,
                         p_calling_sequence => l_curr_calling_sequence);

           --Tax-Distribution Failed
           IF NOT(l_success) THEN

              l_debug_info := 'Call to EBTax api Determine Recovery failed';
	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;

              P_Error_Code := 'AP_CANNOT_GEN_DIST_DUE_TAX';
              P_Token1 := l_error_code;

              IF (G_Invoice_Lines_Cursor%ISOPEN) THEN
                 Close G_Invoice_Lines_Cursor;
              END IF;
              RETURN FALSE;

           END IF;

        END IF;

   ELSE

      l_debug_info := 'Insufficent info available to generate distributions for the taxable line';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      P_Error_Code := 'AP_INSUFF_TAXABLE_DIST_INFO';
      P_Token1     := P_Invoice_Line_Number;
      If (G_Invoice_Lines_Cursor%ISOPEN) Then
           Close G_Invoice_Lines_Cursor;
      End if;
      Return(FALSE);

   END IF; -- end of sufficient data check

  RETURN(TRUE);

EXCEPTION WHEN OTHERS THEN
  IF ( SQLCODE = -54 ) THEN
     FND_MESSAGE.SET_NAME('SQLAP', 'AP_INVOICE_UPDATED_REQUERY');
     IF (G_INVOICE_LINES_CURSOR%ISOPEN ) THEN
       CLOSE G_Invoice_Lines_Cursor ;
     END IF;
  ELSIF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
           'Invoice Id = '|| to_char(p_invoice_id)
	  ||'Invoice Line Number = '||to_char(p_invoice_line_number));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     IF (G_Invoice_Lines_Cursor%ISOPEN ) THEN
       CLOSE G_Invoice_Lines_Cursor ;
     END IF;
  END IF;

  APP_EXCEPTION.RAISE_EXCEPTION;

END Generate_Dists_For_Line;

/*=============================================================================
 |  FUNCTION - generateDistsForInvoice()
 |
 |  DESCRIPTION
 |      This API is a wrapper for generate_dists_for_invoice() for JDBC calls,
 |      used by OA based applications.
 |
 *============================================================================*/

FUNCTION generateDistsForInvoice (
                        P_Invoice_Id                    IN  NUMBER,
                        P_Batch_Id                      IN  NUMBER,
                        P_Invoice_Date                  IN  DATE,
                        P_Vendor_Id                     IN  NUMBER,
                        P_Invoice_Currency_Code         IN  VARCHAR2,
                        P_Exchange_Rate                 IN  NUMBER,
                        P_Exchange_Rate_Type            IN  VARCHAR2,
                        P_Exchange_Date                 IN  DATE,
                        P_Calling_Mode                  IN  VARCHAR2,
                        P_Error_Code                    OUT NOCOPY VARCHAR2,
                        P_Token1                        OUT NOCOPY VARCHAR2,
                        P_Token2                        OUT NOCOPY VARCHAR2,
                        P_Calling_Sequence              IN  VARCHAR2)  RETURN NUMBER IS

l_debug_info		VARCHAR2(2000);
l_curr_calling_sequence VARCHAR2(2000);
l_api_name              CONSTANT VARCHAR2(200) := 'generateDistsForInvoice';

BEGIN

  l_curr_calling_sequence := 'AP_GENERATE_DISTRIBUTIONS_PKG.'||
            'Generate_Dists_for_Invoice <- '||p_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_GENERATE_DISTRIBUTIONS_PKG.Generate_Dists_for_Invoice(+)');
  END IF;

  IF ( generate_dists_for_invoice (
               		P_Invoice_Id                    => p_invoice_id,
                        P_Batch_Id                      => p_batch_id,
                        P_Invoice_Date                  => p_invoice_date,
                        P_Vendor_Id                     => p_vendor_id,
                        P_Invoice_Currency_Code         => p_invoice_currency_code,
                        P_Exchange_Rate                 => p_exchange_rate,
                        P_Exchange_Rate_Type            => p_exchange_rate_type,
                        P_Exchange_Date                 => p_exchange_date,
                        P_Calling_Mode                  => p_calling_mode,
                        P_Error_Code                    => p_error_code,
                        P_Token1                        => p_token1,
                        P_Token2                        => p_token2,
                        P_Calling_Sequence              => l_curr_calling_sequence) ) THEN
      RETURN 0;
  ELSE
      RETURN 1;
  END IF;


EXCEPTION WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'Invoice Id = '|| to_char(p_invoice_id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

  END IF;

  APP_EXCEPTION.RAISE_EXCEPTION;

END generateDistsForInvoice;


END AP_GENERATE_DISTRIBUTIONS_PKG;

/
