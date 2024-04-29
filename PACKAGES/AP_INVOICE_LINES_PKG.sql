--------------------------------------------------------
--  DDL for Package AP_INVOICE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INVOICE_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: apinlins.pls 120.15.12010000.3 2010/02/12 07:10:28 asansari ship $ */

TYPE r_dist_info IS RECORD
 (
   dist_line_num        AP_INVOICE_DISTRIBUTIONS.distribution_line_number%TYPE
  ,accounting_date         AP_INVOICE_DISTRIBUTIONS.accounting_date%TYPE
  ,period_name             AP_INVOICE_DISTRIBUTIONS.period_name%TYPE
  ,description             AP_INVOICE_DISTRIBUTIONS.description%TYPE
  ,dist_ccid            AP_INVOICE_DISTRIBUTIONS.dist_code_combination_id%TYPE
  ,charge_applicable_to_dist
       AP_INVOICE_DISTRIBUTIONS.charge_applicable_to_dist_id%TYPE
  ,project_id              AP_INVOICE_DISTRIBUTIONS.project_id%TYPE
  ,task_id                 AP_INVOICE_DISTRIBUTIONS.task_id%TYPE
  ,expenditure_type        AP_INVOICE_DISTRIBUTIONS.expenditure_type%TYPE
  ,expenditure_organization_id
       AP_INVOICE_DISTRIBUTIONS.expenditure_organization_id%TYPE
  ,expenditure_item_date   AP_INVOICE_DISTRIBUTIONS.expenditure_item_date%TYPE
  ,project_accounting_context AP_INVOICE_DISTRIBUTIONS.project_accounting_context%TYPE
  ,pa_quantity             AP_INVOICE_DISTRIBUTIONS.pa_quantity%TYPE
  ,pa_addition_flag        AP_INVOICE_DISTRIBUTIONS.pa_addition_flag%TYPE
  ,award_id                AP_INVOICE_DISTRIBUTIONS.award_id%TYPE
  ,attribute_category      AP_INVOICE_DISTRIBUTIONS.attribute_category%TYPE
  ,attribute1              AP_INVOICE_DISTRIBUTIONS.attribute1%TYPE
  ,attribute2              AP_INVOICE_DISTRIBUTIONS.attribute2%TYPE
  ,attribute3              AP_INVOICE_DISTRIBUTIONS.attribute3%TYPE
  ,attribute4              AP_INVOICE_DISTRIBUTIONS.attribute4%TYPE
  ,attribute5              AP_INVOICE_DISTRIBUTIONS.attribute5%TYPE
  ,attribute6              AP_INVOICE_DISTRIBUTIONS.attribute6%TYPE
  ,attribute7              AP_INVOICE_DISTRIBUTIONS.attribute7%TYPE
  ,attribute8              AP_INVOICE_DISTRIBUTIONS.attribute8%TYPE
  ,attribute9              AP_INVOICE_DISTRIBUTIONS.attribute9%TYPE
  ,attribute10             AP_INVOICE_DISTRIBUTIONS.attribute10%TYPE
  ,attribute11             AP_INVOICE_DISTRIBUTIONS.attribute11%TYPE
  ,attribute12             AP_INVOICE_DISTRIBUTIONS.attribute12%TYPE
  ,attribute13             AP_INVOICE_DISTRIBUTIONS.attribute13%TYPE
  ,attribute14             AP_INVOICE_DISTRIBUTIONS.attribute14%TYPE
  ,attribute15             AP_INVOICE_DISTRIBUTIONS.attribute15%TYPE
  ,amount                  AP_INVOICE_DISTRIBUTIONS.amount%TYPE
  ,base_amount             AP_INVOICE_DISTRIBUTIONS.base_amount%TYPE
  ,rounding_amt            AP_INVOICE_DISTRIBUTIONS.rounding_amt%TYPE
  ,type_1099               AP_INVOICE_DISTRIBUTIONS.type_1099%TYPE
  ,income_tax_region       AP_INVOICE_DISTRIBUTIONS.income_tax_region%TYPE
  ,assets_tracking_flag    AP_INVOICE_DISTRIBUTIONS.assets_tracking_flag%TYPE
  ,asset_book_type_code    AP_INVOICE_DISTRIBUTIONS.asset_book_type_code%TYPE
  ,asset_category_id       AP_INVOICE_DISTRIBUTIONS.asset_category_id%TYPE
  ,awt_group_id            AP_INVOICE_DISTRIBUTIONS.awt_group_id%TYPE
  ,org_id                  AP_INVOICE_DISTRIBUTIONS.org_id%TYPE
  ,set_of_books_id         AP_INVOICE_DISTRIBUTIONS.set_of_books_id%TYPE
  --ETAX: Invwkb
  ,intended_use		   AP_INVOICE_DISTRIBUTIONS.intended_use%TYPE
  --bugfix:4674194
  ,global_attribute3       AP_INVOICE_DISTRIBUTIONS.global_attribute3%TYPE
  --7022001
  ,pay_awt_group_id	   AP_INVOICE_DISTRIBUTIONS.pay_awt_group_id%TYPE
  --Bug9296445
  ,reference_1             AP_INVOICE_DISTRIBUTIONS.reference_1%TYPE
  ,reference_2             AP_INVOICE_DISTRIBUTIONS.reference_2%TYPE
 );


TYPE r_alloc_line IS RECORD
   (
     invoice_line_number AP_ALLOCATION_RULE_LINES.to_invoice_line_number%TYPE
    ,percentage          AP_ALLOCATION_RULE_LINES.percentage%TYPE
    ,amount              AP_ALLOCATION_RULE_LINES.amount%TYPE
    ,sum_amount_dists    AP_ALLOCATION_RULE_LINES.amount%TYPE);

TYPE dist_tab_type IS TABLE OF r_dist_info
        INDEX BY BINARY_INTEGER;

TYPE alloc_line_tab_type IS TABLE of r_alloc_line
        INDEX BY BINARY_INTEGER;


/*==========================================================================*/
/*                                                                          */
/* This FUNCTION may be called from the insert_from_dist_set function of    */
/* invoice lines, or from the import process.  This FUNCTION takes a series */
/* of mandatory parameters.                                                 */
/* The mandatory parameters are:                                            */
/* 1) X_vendor_id                                                           */
/* 2) X_invoice_date                                                        */
/* 3) X_invoice_lines_rec  -- Lines record as defined in AP_INVOICES_PKG    */
/* 4) X_dist_tab           -- Variable to contain the plsql table of dists  */
/* 5) X_dist_set_total_percent - 100 = Full Dist set, <> 100 = Skeleton     */
/* 6) X_exchange_rate                                                       */
/* 7) X_exchange_rate_type                                                  */
/* 8) X_exchange_date                                                       */
/* 9) X_invoice_currency                                                    */
/* 10)X_base_currency                                                       */
/* 11)X_chart_of_accounts_id                                                */
/* 12)X_Error_Code         -- Variable RETURNing error code IF one is found */
/*           Possible Codes are:                                            */
/*               'INVALID ACCOUNT EXISTS' - Invalid account found           */
/*              'CANNOT OVERLAY' - Cannot overlay with overlay info.        */
/* 13)X_Debug_Info         -- Variable RETURNing debug info for fatal error */
/* 14)X_Debug_Context      -- Variable RETURNing context for fatal error    */
/* 15)X_msg_application    -- Variable to RETURN info from errors in PA Val */
/* 16)X_msg_data           -- Variable to RETURN data from errors in PA Val */
/* 17)X_calling_sequence   -- Calling sequence                              */
/* An optional parameter is:                                                */
/* 1) X_line_source   -- Should only be populated with the value 'IMPORT'   */
/*                    -- IF calling from the Open Interface Import Program  */
/*                    -- Should be null otherwise.                          */
/*                                                                          */
/*==========================================================================*/
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
 X_invoice_currency        IN      AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
 X_base_currency           IN      AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
 X_chart_of_accounts_id    IN      GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE,
 X_Error_Code                 OUT NOCOPY VARCHAR2,
 X_Debug_Info                 OUT NOCOPY VARCHAR2,
 X_Debug_Context              OUT NOCOPY VARCHAR2,
 X_msg_application            OUT NOCOPY VARCHAR2,
 X_msg_data                   OUT NOCOPY VARCHAR2,
 X_calling_sequence        IN            VARCHAR2)
 RETURN BOOLEAN;

/*==========================================================================*/
/*                                                                          */
/* This FUNCTION may be called by any process requiring generation of       */
/* an invoice line/distributions from a distribution set.                   */
/* It takes the following parameters:                                       */
/* 1) X_invoice_id - ID of invoice requesting generation of line/dists      */
/* 2) X_line_number - Line NUMBER IF line already exists, NULL otherwise    */
/*                  - This process will error IF a line NUMBER is provided  */
/*                  - and the line does not exist.                          */
/* 3) X_GL_Date - Accounting Date to use in insert of lines/dists.  It is   */
/*              - assumed to have been validated to be in an open period.   */
/*              - You should pass this date IF generating distributions     */
/*              - for a line with a date in a closed period.  This will     */
/*              - ensure the distributions are created in an open period.   */
/* 4) X_period_name - Period corresponding to GL_Date parameter.            */
/* 5) X_Skeleton_Allowed - Indicates whether a check must be performed to   */
/*                       - ensure no skeleton dist set in use.              */
/* 6) X_Generate_Dists - Indicates whether to Generate distributions as part*/
/*                     - of this function.                                  */
/* 7) X_Generate_Permanent - Indicates whether to create distributions in   */
/*                         - permanent or candidate mode.                   */
/* 8) X_Line_Source - 'HEADER DSET' IF called from the Invoice Workbench   */
/*                    'AUTO INVOICE CREATION'  IF called from the           */
/*                    AP_Recurring_Invoices_pkg.Ap_create_Recurring_Invoices*/
/* 9) X_Item_Description| Copied from the Recurring Invoices Template  IF  */
/*     X_Manufacturer    | the Invoice Lines/Dists are created via Recurring*/
/*     X_Model_Number    | Invoices                                         */
/* 10) Out parameters to be used as stated below to handle errors.          */
/* This FUNCTION will:                                                      */
/* 1) validate that IF Skeleton_Allowed is 'N', the given distribution set  */
/*    is not a skeleton distribution set.  If skeleton, set error code to   */
/*    'SKELETON_NOT_ALLOWED' and RETURN FALSE.                              */
/* 2) validate that distribution set is active. If inactive, set error code */
/*    to 'DIST_SET_INACTIVE' and RETURN FALSE.                              */
/* 3) validate that all accounts in the distribution set are valid and/or if*/
/*    overlay information provided, the overlayed                           */
/*    accounts are valid. If an invalid account is found prior to overlay,  */
/*    set error code to 'INVALID_ACCOUNT_EXISTS' and RETURN FALSE.          */
/*    If overlay RETURNs an error set error code to 'CANNOT_OVERLAY' and    */
/*    RETURN FALSE.                                                         */
/* 4) IF no line already exists, create the line with the given parameters  */
/*    and information from the dist set.                                    */
/* 5) call to create distributions                                          */
/* 6) IF at any given time an error is encountered not covered in the error */
/*    codes, populate debug_info with specific error and RETURN the debug   */
/*    info and the calling sequence as debug context with a FUNCTION output */
/*    of FALSE.                                                             */
/*                                                                          */
/*==========================================================================*/
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
              X_calling_sequence    IN         VARCHAR2) RETURN BOOLEAN;

/*==========================================================================*/
/*                                                                          */
/* This FUNCTION RETURNs the maximum distribution line NUMBER for a given   */
/* invoice and invoice line.  If the line contains no distributions, this   */
/* FUNCTION RETURNs 0.                                                      */
/*                                                                          */
/*==========================================================================*/
 FUNCTION Get_Max_Dist_Line_Num(
           X_invoice_id          IN         NUMBER,
           X_line_number         IN         NUMBER) RETURN NUMBER;

 -- table to hols the dist ids that can be adjusted - bug 6892789
TYPE distribution_id_tab_type IS
TABLE OF AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE
INDEX BY BINARY_INTEGER;

-- function modified to get the dists that can be adjusted - bug 6892789
FUNCTION round_base_amts(
                     X_INVOICE_ID           IN NUMBER,
                     X_LINE_NUMBER          IN NUMBER,
                     X_REPORTING_LEDGER_ID  IN NUMBER DEFAULT NULL,
                     X_ROUND_DIST_ID_LIST   OUT NOCOPY distribution_id_tab_type,
                     X_ROUNDED_AMT          OUT NOCOPY NUMBER,
                     X_Debug_Info           OUT NOCOPY VARCHAR2,
                     X_Debug_Context        OUT NOCOPY VARCHAR2,
                     X_Calling_sequence     IN         VARCHAR2 )
RETURN BOOLEAN;

/*=============================================================================
 |  public PROCEDURE Discard_Inv_Line
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
               p_inv_cancellable   IN  VARCHAR2 DEFAULT NULL,
               P_last_updated_by   IN  NUMBER,
               P_last_update_login IN  NUMBER,
               P_error_code        OUT NOCOPY VARCHAR2,
	       P_token		   OUT NOCOPY VARCHAR2,
               P_calling_sequence  IN  VARCHAR2) RETURN BOOLEAN;

-- Bug 5114543
-- Allow discard of an item line with allocated charges. This utility is placed in the spec
-- so that it can be invoked from ap_invoice_lines_pkg and ap_invoice_distributions_pkg.

/*=============================================================================
 |  Public Function Reverse_Charge_distributions
 |
 |      Reverse distributions for an invoice line. This will be called for
 |      a charge line (Freight, Miscellaneous). Returns false when an error
 |      occurs and error code will be populated. Otherwise, Returns False.
 |
 |  Parameters
 |      P_inv_line_rec      - Invoice line record.
 |      p_calling_mode	    - DISCARD, CANCEL
 |      x_error_code        - For error handling
 |      x_debug_info        - For debugging purposes
 |      p_calling_sequence  - For debugging purposes
 |
 *============================================================================*/

FUNCTION Reverse_Charge_Distributions
                        (p_inv_line_rec         IN  AP_INVOICE_LINES_ALL%rowtype,
                         p_calling_mode         IN  VARCHAR2,
			 x_error_code           OUT NOCOPY VARCHAR2,
			 x_debug_info           OUT NOCOPY VARCHAR2,
			 p_calling_sequence     IN  VARCHAR2) RETURN BOOLEAN;

END AP_INVOICE_LINES_PKG;


/
