--------------------------------------------------------
--  DDL for Package Body JL_AR_AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_AP_WITHHOLDING_PKG" AS
/* $Header: jlarpwhb.pls 120.32.12010000.7 2009/12/02 19:12:17 rsaini ship $ */


/**************************************************************************
 *                    Private Procedures Specification                    *
 **************************************************************************/

-- Define Package Level Debug Variable and Assign the Profile
-- DEBUG_Var varchar2(1) := NVL(FND_PROFILE.value('EXT_AWT_DEBUG_FLAG'), 'N');
  DEBUG_Var varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/**************************************************************************
 *                                                                        *
 * Name       : Do_AWT_Quick_Payment                                      *
 * Purpose    : Withholding Tax Calculation for Quick Payments            *
 *              Processing units to be executed:                          *
 *              1. Create Temporary Distribution Lines                    *
 *              2. Create AWT Distribution Lines                          *
 *              3. Create AWT Invoices                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Do_AWT_Quick_Payment
                    (P_Checkrun_Name            IN     Varchar2,
                     P_Checkrun_Id              IN     Number,
                     P_Check_Id                 IN     Number,
                     P_AWT_Date                 IN     Date,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Do_AWT_Build_Payment_Batch                                *
 * Purpose    : Withholding Tax Calculation for Payment Batches           *
 *              (AutoSelect/Build Payment Stage)                          *
 *              Processing units to be executed:                          *
 *              1. Create Temporary Distribution Lines                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Do_AWT_Build_Payment_Batch
                    (P_Checkrun_Name            IN     Varchar2,
                     p_Checkrun_id              IN     Number,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null);


/**************************************************************************
 *                                                                        *
 * Name       : Do_AWT_Confirm_Payment_Batch                              *
 * Purpose    : Withholding Tax Calculation for Payment Batches           *
 *              (Confirm Payment Stage)                                   *
 *               Processing units to be executed:                         *
 *               2. Create AWT Distribution Lines                         *
 *               3. Create AWT Invoices                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Do_AWT_Confirm_Payment_Batch
                    (P_Checkrun_Name            IN     Varchar2,
                     p_Checkrun_id              IN     Number,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Calculate_AWT_Amounts                                     *
 * Purpose    : This procedure performs all the withholding calculations  *
 *              and generates the temporary distribution lines.           *
 *              It also updates buckets and credit letter amounts.        *
 *                                                                        *
 **************************************************************************/
PROCEDURE Calculate_AWT_Amounts
                    (P_Checkrun_Name            IN     Varchar2,
                     P_Checkrun_ID              IN     Number,
                     P_Check_Id                 IN     Number,
                     P_Selected_Check_Id        IN     Number,
                     P_AWT_Date                 IN     Date,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_Total_Wh_Amount          OUT NOCOPY    Number,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholdings                                   *
 * Purpose    : Obtains all the attributes for the current withholding    *
 *              tax type and name. This procedure also initializes the    *
 *              PL/SQL table to store the withholdings                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholdings
         (P_Vendor_Id             IN     Number,
          P_AWT_Type_Code         IN     Varchar2,
          P_Tax_Id                IN     Number,
          P_Calling_Sequence      IN     Varchar2,
          P_Rec_AWT_Type          OUT NOCOPY    jl_zz_ap_awt_types%ROWTYPE,
          P_Rec_AWT_Name          OUT NOCOPY    Jl_Zz_Ap_Withholding_Pkg.Rec_AWT_Code,
          P_Rec_Suppl_AWT_Type    OUT NOCOPY    jl_zz_ap_supp_awt_types%ROWTYPE,
          P_Rec_Suppl_AWT_Name    OUT NOCOPY    jl_zz_ap_sup_awt_cd%ROWTYPE,
          P_Wh_Table              IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
          P_CODE_ACCOUNTING_DATE  IN            DATE   Default NULL);                       -- Argentina AWT ER




/**************************************************************************
 *                                                                        *
 * Name       : Process_Withholdings                                      *
 * Purpose    : Process the information for the current withholding tax   *
 *              type and name                                             *
 *                                                                        *
 **************************************************************************/
PROCEDURE Process_Withholdings
      (P_Vendor_Id              IN     Number,
       P_Rec_AWT_Type           IN     jl_zz_ap_awt_types%ROWTYPE,
       P_Rec_Suppl_AWT_Type     IN     jl_zz_ap_supp_awt_types%ROWTYPE,
       P_AWT_Date               IN     Date,
       P_GL_Period_Name         IN     Varchar2,
       P_Base_Currency_Code     IN     Varchar2,
       P_Check_Id               IN     Number,
       P_Selected_Check_Id      IN     Number,
       P_Calling_Sequence       IN     Varchar2,
       P_Tab_Withhold           IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
       P_Total_Wh_Amount        IN OUT NOCOPY Number,
       P_AWT_Success            OUT NOCOPY    Varchar2,
       P_Last_Updated_By        IN     Number     Default null,
       P_Last_Update_Login      IN     Number     Default null,
       P_Program_Application_Id IN     Number     Default null,
       P_Program_Id             IN     Number     Default null,
       P_Request_Id             IN     Number     Default null,
       P_Calling_Module         IN     Varchar2   Default null,
       P_Checkrun_Name          IN     Varchar2   Default null,
       P_Checkrun_ID            IN     Number     Default null,
       P_Payment_Num            IN     Number     Default null);



/**************************************************************************
 *                                                                        *
 * Name       : Calculate_Taxable_Base_Amounts                            *
 * Purpose    : Calculates the taxable base amount for each invoice       *
 *              distribution line included within the payment. The steps  *
 *              to do this are:                                           *
 *              1. Prorates the payment amount for each distribution line *
 *              2. Rounds the prorated amount                             *
 *              Taxable base amounts must be calculated all together in   *
 *              order to avoid rounding mistakes (last amount will be     *
 *              obtained by difference).                                  *
 *                                                                        *
 **************************************************************************/
PROCEDURE Calculate_Taxable_Base_Amounts
                     (P_Check_Id                 IN     Number,
                      P_Selected_Check_Id        IN     Number,
                      P_Currency_Code            IN     Varchar2,
                      P_Tab_Inv_Amounts          IN OUT NOCOPY Tab_Amounts,
                      P_Calling_Module           IN     Varchar2,
                      P_Calling_Sequence         IN     Varchar2);




/**************************************************************************
 *                                                                        *
 * Name       : Get_Taxable_Base_Amount                                   *
 * Purpose    : Obtains the taxable base amount for a particular invoice  *
 *              distribution line.                                        *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Taxable_Base_Amount
                     (P_Invoice_Id               IN    Number,
                      P_Distribution_Line_No     IN    Number,
                      P_Invoice_Payment_ID       IN    Number,
                      P_Invoice_Payment_Num      IN    Number,
                      P_Tax_Base_Amount_Basis    IN    Varchar2,
                      P_Tax_Inclusive_Flag       IN    Varchar2,
                      P_Tab_Inv_Amounts          IN    Tab_Amounts,
                      P_Calling_Module           IN    Varchar2,
                      P_Calling_Sequence         IN    Varchar2)
                      RETURN NUMBER;




/**************************************************************************
 *                                                                        *
 * Name       : Get_Credit_Letter_Amount                                  *
 * Purpose    : Obtains the credit letter amount for a particular         *
 *              supplier and withholding tax type                         *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Credit_Letter_Amount
                (P_Vendor_Id          IN     Number,
                 P_AWT_Type_Code      IN     Varchar2,
                 P_Calling_Sequence   IN     Varchar2)
                 RETURN NUMBER;




/**************************************************************************
 *                                                                        *
 * Name       : Update_Credit_Letter                                      *
 * Purpose    : Updates the withheld amount for each tax name contained   *
 *              into the PL/SQL table. The credit letters table is also   *
 *              updated                                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Update_Credit_Letter
      (P_Vendor_Id              IN     Number,
       P_Rec_AWT_Type           IN     jl_zz_ap_awt_types%ROWTYPE,
       P_AWT_Date               IN     Date,
       P_Payment_Num            IN     Number,
       P_Check_Id               IN     Number,
       P_Selected_Check_Id      IN     Number,
       P_Calling_Sequence       IN     Varchar2,
       P_Tab_Withhold           IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
       P_Last_Updated_By        IN     Number     Default null,
       P_Last_Update_Login      IN     Number     Default null,
       P_Program_Application_Id IN     Number     Default null,
       P_Program_Id             IN     Number     Default null,
       P_Request_Id             IN     Number     Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Insert_Credit_Letter_Amount                               *
 * Purpose    : Stores current information about credit letters into the  *
 *              JL_AR_AP_SUP_AWT_CR_LTS table                             *
 *                                                                        *
 **************************************************************************/
PROCEDURE Insert_Credit_Letter_Amount
                (P_Vendor_Id               IN     Number,
                 P_AWT_Type_Code           IN     Varchar2,
                 P_Tax_Id                  IN     Number,
                 P_AWT_Date                IN     Date,
                 P_Withheld_Amount         IN     Number,
                 P_Actual_Withheld_Amount  IN     Number,
                 P_Balance                 IN     Number,
                 P_Status                  IN     Varchar2,
                 P_Payment_Num             IN     Number,
                 P_Check_Id                IN     Number,
                 P_Selected_Check_Id       IN     Number,
                 P_Calling_Sequence        IN     Varchar2,
                 P_Last_Updated_By         IN     Number     Default null,
                 P_Last_Update_Login       IN     Number     Default null,
                 P_Program_Application_Id  IN     Number     Default null,
                 P_Program_Id              IN     Number     Default null,
                 P_Request_Id              IN     Number     Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Undo_Credit_Letter                                        *
 * Purpose    : Reverse all the credit letter amounts for a particular    *
 *              payment. One record will be created for each different    *
 *              supplier and witholding tax type.                         *
 *                                                                        *
 **************************************************************************/
PROCEDURE Undo_Credit_Letter
                (P_Check_Id                IN     Number,
                 P_Selected_Check_Id       IN     Number,
                 P_AWT_Date                IN     Date,
                 P_Payment_Num             IN     Number,
                 P_Calling_Sequence        IN     Varchar2,
                 P_Last_Updated_By         IN     Number     Default null,
                 P_Last_Update_Login       IN     Number     Default null,
                 P_Program_Application_Id  IN     Number     Default null,
                 P_Program_Id              IN     Number     Default null,
                 P_Request_Id              IN     Number     Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Update_Quick_Payment                                      *
 * Purpose    : Updates the payment amount by subtracting the withheld    *
 *              amount.                                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Update_Quick_Payment
                    (P_Check_Id                 IN     Number,
                     P_Calling_Sequence         IN     Varchar2);




/**************************************************************************
 *                                                                        *
 * Name       : Update_Payment_Batch                                      *
 * Purpose    : Updates the amounts of the payment batch by subtracting   *
 *              the withholding amount.                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Update_Payment_Batch
                (P_Checkrun_Name           IN     Varchar2,
                 p_checkrun_id             IN     Number,
                 P_Selected_Check_Id       IN     Number,
                 P_Calling_Sequence        IN     Varchar2);




/**************************************************************************
 *                                                                        *
 * Name       : Withholding_Already_Calculated                            *
 * Purpose    : Checks whether the withholding was already calculated for *
 *              a particular invoice. This is only applicable for those   *
 *              'Invoice Based' withholding taxes.                        *
 *                                                                        *
 **************************************************************************/
FUNCTION Withholding_Already_Calculated
                (P_Invoice_Id                IN     Number,
                 P_Tax_Name                  IN     Varchar2,
                 P_Tax_Id                    IN     Number,
                 P_Taxable_Base_Amount_Basis IN     Varchar2,
                 P_Tab_Withhold              IN     Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
                 P_Inv_Payment_Num           IN     Number,
                 P_Calling_Sequence          IN     Varchar2)
                 RETURN Boolean;




/**************************************************************************
 *                                                                        *
 * Name       : Total_Withholding_Amount                                  *
 * Purpose    : Returns the total withheld amount for the withholding tax *
 *              type (sums up all the prorated amounts).                  *
 *                                                                        *
 **************************************************************************/
FUNCTION Total_Withholding_Amount
             (P_Tab_Withhold     IN     Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
              P_Calling_Sequence IN     Varchar2)
              RETURN Number;




/**************************************************************************
 *                                                                        *
 * Name       : Partial_Payment_Paid_In_Full                              *
 * Purpose    : Checks whether the payment amount is enough to cover the  *
 *              withholding amount.                                       *
 *                                                                        *
 **************************************************************************/
FUNCTION Partial_Payment_Paid_In_Full
                 (P_Check_Id             IN     Number,
                  P_Selected_Check_Id    IN     Number,
                  P_Calling_Module       IN     Varchar2,
                  P_Total_Wh_Amount      IN     Number,
                  P_Calling_Sequence     IN     Varchar2,
                  P_Vendor_Name          OUT NOCOPY    Varchar2,
                  P_Vendor_Site_Code     OUT NOCOPY    Varchar2)
                  RETURN Boolean;




/**************************************************************************
 *                                                                        *
 * Name       : Confirm_Credit_Letters                                    *
 * Purpose    : Updates the credit letters table in order to store the    *
 *              the final check ID, when users confirm a payment batch.   *
 *              This procedure is not called for Quick Payments because   *
 *              the check ID is known from the begining.                  *
 *                                                                        *
 **************************************************************************/
PROCEDURE Confirm_Credit_Letters
                (P_Checkrun_Name           IN     Varchar2,
                 P_Checkrun_ID             IN     Number,
                 P_Calling_Sequence        IN     Varchar2);


/**************************************************************************
 *                                                                        *
 * Name       : Reject_Payment_Batch                                      *
 * Purpose    : Sets the "Ok To Pay" flag for all the selected invoices   *
 *              within the payment when the calculation routine is not    *
 *              successful                                                *
 *                                                                        *
 **************************************************************************/
PROCEDURE Reject_Payment_Batch
                (P_Selected_Check_Id       IN     Number,
                 P_AWT_Success             IN     Varchar2,
                 P_Calling_Sequence        IN     Varchar2);


/**************************************************************************
 *                          Public Procedures                             *
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 * Name       : Jl_Ar_Ap_Do_Withholding                                   *
 * Purpose    : This is the main Argentine withholding tax calculation    *
 *              routine. This procedure can be divided into three         *
 *              processing units (just like the core calculation routine) *
 *              1. Create Temporary Distribution Lines                    *
 *              2. Create AWT Distribution Lines                          *
 *              3. Create AWT Invoices                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Jl_Ar_Ap_Do_Withholding
              (P_Invoice_Id             IN     Number,
               P_Awt_Date               IN     Date,
               P_Calling_Module         IN     Varchar2,
               P_Amount                 IN     Number,
               P_Payment_Num            IN     Number     Default null,
               P_Checkrun_Name          IN     Varchar2   Default null,
               p_Checkrun_id            IN     Number     Default null,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null,
               P_Awt_Success            OUT NOCOPY    Varchar2,
               P_Invoice_Payment_Id     IN     Number     Default null,
               P_Check_Id               IN     Number     Default null)
IS

    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN

    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Jl_Ar_Ap_Do_Withholding';

    -- Debug
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure - Jl_Ar_Ap_Do_Withholding(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Invoice_Id = '||to_char(P_Invoice_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Amount = '||to_char(P_Amount));
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Invoice_Payment_Id = '||to_char(P_Invoice_Payment_Id));
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Check_Id = '||to_char(P_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Calling_Module = '||P_Calling_Module);
    END IF;
    -- End Debug

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;


   /********************************************************
    *                                                      *
    * Withholding Tax Calculation for Quick Payments       *
    * ---------------------------------------------------- *
    * Processing units to be executed:                     *
    * 1. Create Temporary Distribution Lines               *
    * 2. Create AWT Distribution Lines                     *
    * 3. Create AWT Invoices                               *
    *                                                      *
    ********************************************************/
    IF (P_Calling_Module = 'QUICKCHECK') THEN
        l_debug_info := 'Calculating Withholding for Quick Payment';
        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_debug_info);
        END IF;
        -- End Debug
        Do_AWT_Quick_Payment (P_Checkrun_Name,
                              P_Checkrun_ID,
                              P_Check_Id,
                              P_AWT_Date,
                              P_Calling_Module,
                              l_calling_sequence,
                              P_AWT_Success,
                              P_Last_Updated_By,
                              P_Last_Update_Login,
                              P_Program_Application_Id,
                              P_Program_Id,
                              P_Request_Id);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
		   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('P_AWT_Success: '||P_AWT_Success);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Calculating Withholding for Quick Payment');
        END IF;
        -- End Debug
        -------------------------------------------------------
        -- If the calculation did not complete successfully,
        -- sets the error message on the stack to be retrieved
        -- on the client side
        -------------------------------------------------------
        IF (P_AWT_Success <> AWT_SUCCESS) THEN
            Fnd_Message.Set_Name  ('JL', 'JL_AR_AP_AWT_CALC_ERROR');
            Fnd_Message.Set_Token ('ERROR_TEXT', P_AWT_Success);
        END IF;


   /********************************************************
    *                                                      *
    * Withholding Tax Calculation for Payment Batches      *
    * (AutoSelect/Build Payment Stage)                     *
    * ---------------------------------------------------- *
    * Processing units to be executed:                     *
    * 1. Create Temporary Distribution Lines               *
    *                                                      *
    ********************************************************/
    ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
        l_debug_info := 'Calculating Withholding for Payment Batch (Build)';
        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
          JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_debug_info);
        END IF;
        -- End Debug
        Do_AWT_Build_Payment_Batch
                           (P_Checkrun_Name,
                            p_Checkrun_id,
                            P_Calling_Module,
                            l_calling_sequence,
                            P_AWT_Success,
                            P_Last_Updated_By,
                            P_Last_Update_Login,
                            P_Program_Application_Id,
                            P_Program_Id,
                            P_Request_Id);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
		  JL_ZZ_AP_EXT_AWT_UTIL.Debug ('P_AWT_Success: '||P_AWT_Success);
          JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Calculating Withholding for Payment Batch (Build)');
        END IF;
        -- End Debug

   /********************************************************
    *                                                      *
    * Withholding Tax Calculation for Payment Batches      *
    * (Confirm Payment Stage)                              *
    * ---------------------------------------------------- *
    * Processing units to be executed:                     *
    * 2. Create AWT Distribution Lines                     *
    * 3. Create AWT Invoices                               *
    *                                                      *
    ********************************************************/
    ELSIF (P_Calling_Module = 'CONFIRM') THEN
        l_debug_info := 'Calculating Withholding for Payment Batch (Confirm)';
        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
          JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_debug_info);
        END IF;
        -- End Debug
        Do_AWT_Confirm_Payment_Batch
                           (P_Checkrun_Name,
                            p_checkrun_id,
                            P_Calling_Module,
                            l_calling_sequence,
                            P_AWT_Success,
                            P_Last_Updated_By,
                            P_Last_Update_Login,
                            P_Program_Application_Id,
                            P_Program_Id,
                            P_Request_Id);
        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
          JL_ZZ_AP_EXT_AWT_UTIL.Debug('P_AWT_Success: '||P_AWT_Success);
          JL_ZZ_AP_EXT_AWT_UTIL.Debug('After Calculating Withholding for Payment Batch (Confirm)');
        END IF;
        -- End Debug
    END IF;

	IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure - Jl_Ar_Ap_Do_Withholding(-)');
    END IF;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug ('EXCEPTION - Jl_Ar_Ap_Do_Withholding - Error:'||SQLERRM);
            END IF;
            -- End Debug

            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              '  Invoice Id= '          || to_char(P_Invoice_Id)         ||
              ', Awt Date= '            || to_char(P_Awt_Date,'YYYY/MM/DD')  ||
              ', Calling Module= '      || P_Calling_Module              ||
              ', Amount= '              || to_char(P_Amount)             ||
              ', Payment Num= '         || to_char(P_Payment_Num)        ||
              ', Checkrun Name= '       || P_Checkrun_Name               ||
              ', Invoice Payment Id= '  || to_char(P_Invoice_Payment_Id) ||
              ', Check Id= '            || to_char(P_Check_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        P_AWT_Success := AWT_ERROR;

END Jl_Ar_Ap_Do_Withholding;




/**************************************************************************
 *                                                                        *
 * Name       : Jl_Ar_Ap_Undo_Withholding                                 *
 * Purpose    : Routine to reverse withholding taxes which were           *
 *              calculated by the Argentine withholding tax calculation   *
 *              routine (Jl_Ar_Ap_Do_Withholding).                        *
 *              Most of the withholding tax figures will be reversed by   *
 *              the core procedures. This routine will only reverse       *
 *              credit letter amounts and withholding certificates.       *
 *                                                                        *
 **************************************************************************/
PROCEDURE Jl_Ar_Ap_Undo_Withholding
              (P_Parent_Id              IN     Number,
               P_Calling_Module         IN     Varchar2,
               P_Undo_Awt_Date          IN     Date,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_check_id               Number;
    l_payment_num            Number;
    l_selected_check_id      Number;
    l_invoice_payment_id     Number;
    l_invoice_id             Number;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);
    l_payment_id             number;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Jl_Ar_Ap_Undo_Withholding';
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure - Jl_Ar_Ap_Undo_Withholding(+)');
    END IF;
    -- End Debug

    -----------------------------------------------------
    -- Obtains the information to reverse credit letters
    -----------------------------------------------------
    -- Bug 2722913  Modified the below query to refer
    -- to invoice_payment_id instead of invoice_id.

  -- In the confirm CR the payment ID is inserted then changed check id
    SELECT apip.check_id        check_id,
           apip.payment_num     payment_num,
               apip.invoice_id      invoice_id
    INTO   l_check_id,
           l_payment_num,
               l_invoice_id
    FROM   ap_invoice_payments apip
    WHERE  apip.invoice_payment_id = P_Parent_Id;

 -- added to reverse the certificate.
    select ac.payment_id
    into   l_payment_id
    from   ap_checks ac
    where  ac.check_id = l_check_id;



    ----------------------------------
    -- Reverses credit letter amounts
    ----------------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Undo Credit Letter');
    END IF;
    -- End Debug

    Undo_Credit_Letter (l_check_id,
                        null,              -- Selected Check Id
                        P_Undo_AWT_Date,
                        l_payment_num,
                        l_calling_sequence,
                        P_Last_Updated_By,
                        P_Last_Update_Login,
                        P_Program_Application_Id,
                        P_Program_Id,
                        P_Request_Id);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Undo Credit Letter');
    END IF;
    -- End Debug
    ----------------------------------
    -- Voids Withholding Certificates
    ----------------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Procedure Jl_Ar_Ap_Void_Certificates');
    END IF;
    -- End Debug

    Jl_Ar_Ap_Awt_Reports_Pkg.Jl_Ar_Ap_Void_Certificates (l_payment_id,
                                                         l_calling_sequence);
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Procedure Jl_Ar_Ap_Void_Certificates');
    END IF;
    -- End Debug
    -----------------------------------------------
    -- Reverse Exemption_Amount (Global Attribute5)
    -----------------------------------------------

    UPDATE ap_invoice_distributions
       SET Global_Attribute5 = 0
     WHERE invoice_id = l_invoice_id
       and nvl(to_number(Global_Attribute5),0) > 0;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Reverse Exemption Complete');
    END IF;
    -- End Debug

	 -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure - Jl_Ar_Ap_Undo_Withholding(-)');
    END IF;
    -- End Debug

EXCEPTION
    When NO_DATA_FOUND THEN
      -- Debug Information
         IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug ('EXCEPTION - Jl_Ar_Ap_Undo_Withholding - No data Found');
         END IF;
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('EXCEPTION - Jl_Ar_Ap_Undo_Withholding - Error:'||SQLERRM);
            END IF;
            -- End Debug
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              '  Parent_Id= '        || to_char(P_Parent_Id) ||
              ', Calling_Module= '   || P_Calling_Module     ||
              ', Undo_Awt_Date= '    || to_char(P_Undo_Awt_Date,'YYYY/MM/DD'));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Jl_Ar_Ap_Undo_Withholding;


/**************************************************************************
 *                                                                        *
 * Name       : Jl_Ar_Ap_Void_Selec_Cetif                                 *
 * Purpose    : Routine to Void the Certificates corresponding to cancel  *
 *              payments                                                  *
 *              Created for bug 2145634                                   *
 *                                                                        *
 **************************************************************************/
 /* Procedure removed due to Cancel of payments in new process has not generated
    certificates.


PROCEDURE JL_AR_AP_VOID_SELEC_CERTIF(
        p_checkrun_Name         IN     Varchar2,
        p_selected_check_id     IN     Number,
        P_Calling_Sequence      IN     Varchar2)
IS


-----------VARIABLES-----------
    l_debug_info                Varchar2(300);
    l_awt_success               Varchar2(2000) := 'SUCCESS';
    l_calling_sequence          Varchar2(2000);

    l_check_number              Number;
    l_selected_check_id         Number;
    l_lookup_code               Varchar2(300);


BEGIN

    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'JL_AR_AP_VOID_SELEC_CERTIF<--' || P_Calling_Sequence;
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure - JL_AR_AP_VOID_SELEC_CERTIF');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: p_checkrun_name='||p_checkrun_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: p_selected_check_id='||to_char(p_selected_check_id));
    END IF;
    -- End Debug

     UPDATE     jl_ar_ap_awt_certif
     set     status = 'VOID'
     where   checkrun_name   =      p_checkrun_name
     and   check_number    NOT IN (
           SELECT apsi.check_number
           FROM   ap_selected_invoice_checks   apsi
           WHERE  apsi.checkrun_name = P_Checkrun_Name
           AND   (apsi.status_lookup_code ='NEGOTIABLE' or apsi.status_lookup_code='ISSUED') );


EXCEPTION

    WHEN NO_DATA_FOUND THEN
        null;

    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug ('EXCEPTION - JL_AR_AP_VOID_SELEC_CERTIF - Error:'||SQLERRM);
            END IF;
            -- End Debug
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              ', Checkrun Name = '            || P_Checkrun_name);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;


END JL_AR_AP_VOID_SELEC_CERTIF;

*/

/**************************************************************************
 *                                                                        *
 * Name       : Jl_Ar_Ap_Undo_Temp_Withholding                            *
 * Purpose    : Routine to reverse temporary withholding taxes which were *
 *              calculated by the Argentine withholding tax calculation   *
 *              routine (Jl_Ar_Ap_Do_Withholding).                        *
 *              Most of the withholding tax figures will be reversed by   *
 *              the core procedures. This routine will only reverse       *
 *              credit letter amounts.                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Jl_Ar_Ap_Undo_Temp_Withholding
              (P_Invoice_Id             IN     Number,
               P_Payment_Num            IN     Number,
               P_Checkrun_Name          IN     Varchar2,
               p_Checkrun_id            IN     Number,
               P_Undo_Awt_Date          IN     Date,
               P_Calling_Module         IN     Varchar2,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null)
IS

    -------------------------------
    -- Local variables definition
    -------------------------------
    l_selected_check_id      Number;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

    ---------------------
    -- Cursor definition
    ---------------------
    CURSOR c_selected_invoices (P_Invoice_Id    IN     Number,
                                P_Payment_Num   IN     Number,
                                P_Checkrun_Name IN     Varchar2)
    IS
    SELECT Ihd.Payment_id  selected_check_id
    FROM   IBY_Hook_Docs_in_PMT_T ihd
    WHERE  ihd.calling_app_doc_unique_ref2  = P_Invoice_Id
    AND    ihd.calling_app_doc_unique_ref3  = P_Payment_Num
    AND    ihd.calling_App_doc_unique_ref1  = P_Checkrun_ID
    AND    ihd.calling_app_id = 200 ;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Jl_Ar_Ap_Undo_Temp_Withholding';
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure - Jl_Ar_Ap_Undo_Temp_Withholding(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Checkrun_Name = '||P_Checkrun_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Invoice_Id = '||to_char(P_Invoice_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Payment_Num = '||to_char(P_Payment_Num));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Calling_Module = '||P_Calling_Module);
    END IF;
    -- End Debug

    ----------------------------------
    -- Reverses credit letter amounts
    ----------------------------------
    OPEN c_selected_invoices (P_Invoice_Id, P_Payment_Num, P_Checkrun_Name);
    LOOP
        FETCH c_selected_invoices INTO l_selected_check_id;
        EXIT WHEN c_selected_invoices%NOTFOUND;

		IF (DEBUG_Var = 'Y') THEN
	        JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Undo_Credit_Letter');
        END IF;

        Undo_Credit_Letter (null,   -- Check Id
                            l_selected_check_id,
                            P_Undo_AWT_Date,
                            P_Payment_Num,
                            l_calling_sequence,
                            P_Last_Updated_By,
                            P_Last_Update_Login,
                            P_Program_Application_Id,
                            P_Program_Id,
                            P_Request_Id);


    END LOOP;
	    IF (DEBUG_Var = 'Y') THEN
	        JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Cursor c_selected_invoices');
        END IF;

    CLOSE c_selected_invoices;

/*  The Cancelation of Certificates has been moved as it is being in a different stage of
    payment process

   -- Bug 2145634 and Bug# 2319631
   -- Void  certificates when the Payment Batch is canceled, spoilded,
   -- and skipped
   -- Undo_temp_wh could be call also during confirm/cancel remainder
    ----------------------------------
    -- Voids Withholding Certificates
    ----------------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Calling JL_AR_AP_VOID_SELEC_CERTIF');
    END IF;
    -- End Debug


    If (P_Calling_Module='CANCEL') or (P_Calling_Module = 'AUTOSELECT') then
      JL_AR_AP_WITHHOLDING_PKG.JL_AR_AP_VOID_SELEC_CERTIF(p_checkrun_name,
                                                          l_selected_check_id,
                                                          l_calling_sequence);

      -- Debug Information
      IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called JL_AR_AP_VOID_SELEC_CERTIF');
      END IF;
      -- End Debug
    end if;
*/
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure - Jl_Ar_Ap_Undo_Temp_Withholding(-)');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              '  Invoice Id= '      || to_char(P_Invoice_Id)    ||
              ', Payment Num= '     || to_char(P_Payment_Num)   ||
              ', Checkrun Name= '   || P_Checkrun_Name          ||
              ', Undo Awt Date= '   || to_char(P_Undo_Awt_Date,'YYYY/MM/DD') ||
              ', Calling Module= '  || P_Calling_Module);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Jl_Ar_Ap_Undo_Temp_Withholding;


/**************************************************************************
 *                                                                        *
 * Name       : Jl_Ar_Ap_Gen_Certificates                                 *
 * Purpose    : Creates withholding certificates for a particular         *
 *              payment.                                                  *
 *                                                                        *
 **************************************************************************/
/* This function is removed as the new calling point is from IBY
   and the way to handle the call to generate certificates is changed
FUNCTION Jl_Ar_Ap_Gen_Certificates
               (P_Checkrun_Name          IN     Varchar2,
                P_Errmsg                 OUT NOCOPY    Varchar2)
                RETURN Boolean
IS
 .....

END Jl_Ar_Ap_Gen_Certificates;
*/

PROCEDURE Jl_Ar_Ap_Certificates
 ( p_payment_instruction_ID   IN NUMBER,
   p_calling_module           IN VARCHAR2,
   p_api_version              IN NUMBER,
   p_init_msg_list            IN VARCHAR2 ,
   p_commit                   IN VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS
   -------------------------------
    -- Local variables definition
    -------------------------------
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);
    v_errmsg                 Varchar2(2000);
    l_status                  Boolean := TRUE; --bug 8680654

   cursor c_spoiled_pmt (p_pmt_instruction_id IN NUMBER) is
   select pmt.payment_id
   from   iby_fd_payments_v pmt
   where  pmt.payment_instruction_id = p_pmt_instruction_id
   and    pmt.payment_status ='REMOVED_DOCUMENT_SPOILED' ;

   cursor c_reprint_pmt (p_pmt_instruction_id IN NUMBER) is
   select pmt.payment_id
   from   iby_fd_payments_v pmt
   where  pmt.payment_instruction_id = p_pmt_instruction_id
   and    pmt.payment_status ='READY_TO_REPRINT';


BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Jl_Ar_Ap_Gen_Certificates';

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure Jl_Ar_Ap_certificates(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: p_payment_instruction_id = '||p_payment_instruction_id);
    END IF;
    -- End Debug


   ------------------------------
   -- Generates the certificates
   ------------------------------
   l_debug_info := 'Generating Withholding Certificates';
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_debug_info);
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling module '||p_CALLING_MODULE);
    END IF;
    -- End Debug

   IF p_CALLING_MODULE = 'GENERATE' THEN
    l_status := Jl_Ar_Ap_Awt_Reports_Pkg.Jl_Ar_Ap_Gen_Certificates( p_payment_instruction_id,
                                                                    p_calling_module,
                                                                    v_Errmsg);
    ELSIF p_CALLING_MODULE = 'REPRINT' THEN
   -- Cancel Previous Certificates
      FOR rec_reprint_pmt in c_reprint_pmt(p_payment_instruction_id) Loop

       JL_AR_AP_AWT_REPORTS_PKG.jl_ar_ap_void_certificates(rec_reprint_pmt.payment_id,p_calling_module);

      END LOOP;
 -- Generate new certificates
    l_status := Jl_Ar_Ap_Awt_Reports_Pkg.Jl_Ar_Ap_Gen_Certificates( p_payment_instruction_id,
                                                                    p_calling_module,
                                                                    v_Errmsg);


    ELSIF p_CALLING_MODULE = 'SPOILED' THEN

      FOR rec_spoiled_pmt in c_spoiled_pmt(p_payment_instruction_id) Loop

       JL_AR_AP_AWT_REPORTS_PKG.jl_ar_ap_void_certificates(rec_spoiled_pmt.payment_id,p_calling_module);

      END LOOP;
    /* Commented this condition to get in synch with branchline fix*/
    /*
    -- Bug 6736363 - added new value as per IBY team's suggestion
    ELSIF p_CALLING_MODULE = 'CONFIRM' THEN
    l_status := Jl_Ar_Ap_Awt_Reports_Pkg.Jl_Ar_Ap_Gen_Certificates( p_payment_instruction_id,
                                                                    p_calling_module,
                                                                   v_Errmsg);
    */
    END IF;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Generating Withholding Certificates');
    END IF;
    -- End Debug
     IF l_status then
       x_return_status := FND_API.G_RET_STS_SUCCESS;
     else
       x_return_status := fnd_api.g_ret_sts_error;
     END IF;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure Jl_Ar_Ap_certificates(-)');
    END IF;
    -- End Debug

EXCEPTION

    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_MODULE', p_calling_module);
            Fnd_Message.Set_Token('PARAMETERS',
                     '  Payment Instruction ID ' || p_payment_instruction_id );
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        App_Exception.Raise_Exception;

 END Jl_Ar_Ap_Certificates;

/**************************************************************************
 *                          Private Procedures                            *
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 * Name       : Do_AWT_Quick_Payment                                      *
 * Purpose    : Withholding Tax Calculation for Quick Payments            *
 *              Processing units to be executed:                          *
 *              1. Create Temporary Distribution Lines                    *
 *              2. Create AWT Distribution Lines                          *
 *              3. Create AWT Invoices                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Do_AWT_Quick_Payment
                    (P_Checkrun_Name            IN     Varchar2,
                     P_Checkrun_ID              IN     Number,
                     P_Check_Id                 IN     Number,
                     P_AWT_Date                 IN     Date,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_create_distr           Varchar2(25);
    l_create_invoices        Varchar2(25);
    l_invoice_id             Number;
    l_inv_curr_code          Varchar2(50);
    l_payment_num            Number;
    l_total_wh_amount        Number := 0;
    -- l_payment_amount         Number;  Bug# 2807464
    l_vendor_name            Varchar2(240);
    l_vendor_site_code       Varchar2(15);
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);
    l_payment_type           Varchar2(10);

    -------------------------
    -- Exceptions definition
    -------------------------
    Not_Paid_In_Full   Exception;

    -------------------------------------
    -- Cursor to select all the invoices
    -- within the payment
    -------------------------------------
    CURSOR c_invoice_payment (P_Check_Id Number)
    IS
    SELECT apin.invoice_id              invoice_id,
           apin.invoice_currency_code   invoice_currency_code,
           apip.payment_num             payment_num
    FROM   ap_invoice_payments apip,
           ap_invoices         apin
    WHERE  apin.invoice_id = apip.invoice_id
    AND    apip.check_id = P_Check_Id;


BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Do_AWT_Quick_Payment<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' PROCEDURE - Do_AWT_Quick_Payment(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Checkrun_Name = '||P_Checkrun_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Check_Id = '||P_Check_Id);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Calling_Module = '||P_Calling_Module);
    END IF;
    -- End Debug

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    --------------------------------------------------------------
    -- Refund Payments Bug number 1468697.
    -- Withholdings are not calculated for payment type = Refund.
    --------------------------------------------------------------
    Select payment_type_flag
      into l_payment_type
      from ap_checks
     where check_id = P_Check_id;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Getting Payment Type Flag - '||l_payment_type);
    END IF;
    -- End Debug


    IF (l_payment_type = 'R') THEN
       return;
    END IF;

    ----------------------------
    -- Gets Withholding Options
    ----------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Get_Withholding_Options ');
    END IF;
    -- End Debug

    Jl_Zz_Ap_Withholding_Pkg.Get_Withholding_Options (l_create_distr,
                                                      l_create_invoices);

    IF (l_create_distr <> 'PAYMENT') THEN
        -- Nothing to do
        RETURN;
    END IF;

    -----------------------------------------
    -- Executes First Processing Unit
    -- Creates Temporary Distribution Lines
    -----------------------------------------
    SAVEPOINT Before_Calc_Withholding;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Calculate_AWT_Amounts');
    END IF;
    -- End Debug

    Calculate_AWT_Amounts (P_Checkrun_Name,
                           P_Checkrun_ID,
                           P_Check_Id,
                           null,
                           P_AWT_Date,
                           P_Calling_Module,
                           l_calling_sequence,
                           l_total_wh_amount,
                           P_AWT_Success,
                           P_Last_Updated_By,
                           P_Last_Update_Login,
                           P_Program_Id,
                           P_Request_Id);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Called Calculate_AWT_Amounts');
    END IF;
    -- End Debug
    --------------------------------------------------------
    -- Checks whether the calculation finishes successfully
    --------------------------------------------------------
    IF (P_AWT_Success <> AWT_SUCCESS) THEN
        RETURN;
    END IF;

    ---------------------------------------------------
    -- Checks whether the payment amount is enough to
    -- cover the withholding amount
    ---------------------------------------------------
    IF (NOT Partial_Payment_Paid_In_Full(P_Check_Id,
                                         null,
                                         P_Calling_Module,
                                         l_total_wh_amount,
                                         l_calling_sequence,
                                         l_vendor_name,
                                         l_vendor_site_code)) THEN
                                         -- l_payment_amount)) THEN  Bug# 2807464

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('IF (NOT  Partial_Payment_Paid_In_Full) - Function');
        END IF;
        -- End Debug

        ROLLBACK TO Before_Calc_Withholding;
        RAISE Not_Paid_In_Full;
    END IF;

    ----------------------------------------------
    -- Processing each invoice within the payment
    ----------------------------------------------
    OPEN c_invoice_payment(P_Check_Id);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Looping thru the cursor c_invoice_payment');
    END IF;
    -- End Debug

    LOOP
        FETCH c_invoice_payment INTO l_invoice_id,
                                     l_inv_curr_code,
                                     l_payment_num;
        EXIT WHEN c_invoice_payment%NOTFOUND;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_invoice_id'||to_char(l_invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_inv_curr_code'||l_inv_curr_code);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_payment_num'||to_char(l_payment_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling  Ap_Withholding_Pkg.Create_AWT_Distributions');
        END IF;
        -- End Debug

        -----------------------------------------
        -- Executes Second Processing Unit
        -- Creates AWT Distribution Lines
        -----------------------------------------
        Ap_Withholding_Pkg.Create_AWT_Distributions
                            (l_invoice_id,
                             P_Calling_Module,
                             l_create_distr,
                             l_payment_num,
                             l_inv_curr_code,
                             P_Last_Updated_By,
                             P_Last_Update_Login,
                             P_Program_Application_Id,
                             P_Program_Id,
                             P_Request_Id,
                             l_calling_sequence,
       -- Payment Exchange Rate ER 8648739 Start
                             P_Check_Id);
       -- Payment Exchange Rate ER 8648739 End

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Called  Ap_Withholding_Pkg.Create_AWT_Distributions');
        END IF;
        -- End Debug


        -----------------------------------------
        -- Executes Third Processing Unit
        -- Creates AWT Invoices
        -----------------------------------------
        IF (l_create_invoices = 'PAYMENT') THEN

           -- Debug Information
           IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling  Ap_Withholding_Pkg.Create_AWT_Invoices');
           END IF;
           -- End Debug

            Ap_Withholding_Pkg.Create_AWT_Invoices
                            (l_invoice_id,
                             P_AWT_Date,
                             P_Last_Updated_By,
                             P_Last_Update_Login,
                             P_Program_Application_Id,
                             P_Program_Id,
                             P_Request_Id,
                             l_calling_sequence);
                             --P_Calling_Module);  -- bug 6835131 - No change in AP pkg for branchline, only in mainline

           -- Debug Information
           IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Called  Ap_Withholding_Pkg.Create_AWT_Invoices');
           END IF;
           -- End Debug


        END IF;

    END LOOP;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Close c_invoice_payment');
    END IF;
    -- End Debug

    CLOSE c_invoice_payment;

    ---------------------------------------------
    -- Updates all the amounts associated to the
    -- Quick Payment
    ---------------------------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Update_Quick_Payment');
    END IF;
    -- End Debug

    Update_Quick_Payment (P_Check_Id,
                          l_calling_sequence);

        -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug (' PROCEDURE - Do_AWT_Quick_Payment(-)');
    END IF;
    -- End Debug

EXCEPTION
    WHEN Not_Paid_In_Full THEN
        Fnd_Message.Set_Name ('JL', 'JL_AR_AP_PARTIAL_PAY_ERROR');
        Fnd_Message.Set_Token('SUPPLIER',   l_vendor_name);
        Fnd_Message.Set_Token('PAY_SITE',   l_vendor_site_code);
        --Fnd_Message.Set_Token('PAY_AMOUNT', l_payment_amount); Bug# 2807464
        Fnd_Message.Set_Token('WH_AMOUNT',  l_total_wh_amount);
        P_AWT_Success := Fnd_Message.Get;

    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                    '  Checkrun Name= '   || P_Checkrun_Name     ||
                    ', Check Id= '        || to_char(P_Check_Id) ||
                    ', AWT Date= '        || to_char(P_AWT_Date,'YYYY/MM/DD') ||
                    ', Calling Module= '  || P_Calling_Module);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Do_AWT_Quick_Payment;




/**************************************************************************
 *                                                                        *
 * Name       : Do_AWT_Build_Payment_Batch                                *
 * Purpose    : Withholding Tax Calculation for Payment Batches           *
 *              (AutoSelect/Build Payment Stage)                          *
 *              Processing units to be executed:                          *
 *              1. Create Temporary Distribution Lines                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Do_AWT_Build_Payment_Batch
                    (P_Checkrun_Name            IN     Varchar2,
                       P_Checkrun_ID              IN     Number,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null)
IS
    ------------------------------------------------
    -- Cursor to select all the checks ID included
    -- within the payment batch
    ------------------------------------------------
    CURSOR c_selected_checks (P_Checkrun_Name Varchar2)
    IS
/*    SELECT apsic.selected_check_id selected_check_id
    FROM   ap_selected_invoice_checks   apsic
    WHERE  apsic.checkrun_name = P_Checkrun_Name;*/
--RG
   SELECT ipmt.payment_id payment_id, ipmt.payment_date
   from IBY_HOOK_PAYMENTS_T ipmt
   where ipmt.call_app_pay_service_req_code   = P_Checkrun_Name
   and   ipmt.calling_app_id= 200;

    ------------------------------
    -- Local variables definition
    -------------------------------
    rec_selected_checks      c_selected_checks%ROWTYPE;
    l_awt_date               Date;
    l_create_distr           Varchar2(25);
    l_create_invoices        Varchar2(25);
    l_total_wh_amount        Number := 0;
    -- l_payment_amount         Number;  Bug# 2807464
    l_vendor_name            Varchar2(240);
    l_vendor_site_code       Varchar2(15);
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Do_AWT_Build_Payment_Batch<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE - Do_AWT_Build_Payment_Batch(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Checkrun_Name '||P_Checkrun_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Checkrun_ID '||to_number(P_Checkrun_ID));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Calling_Module '||P_Calling_Module);
    END IF;
    -- End Debug

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    ----------------------------
    -- Gets Withholding Options
    ----------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Get_Withholding_Options ');
    END IF;
    -- End Debug

    Jl_Zz_Ap_Withholding_Pkg.Get_Withholding_Options (l_create_distr,
                                                      l_create_invoices);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Withh Options: create_dist and create_invoices: '||l_create_distr||', '||l_create_invoices);
    END IF;
    -- End Debug

    IF (l_create_distr <> 'PAYMENT') THEN
        -- Nothing to do
        RETURN;
    END IF;

    ------------------------
    -- Obtains the AWT Date
    ------------------------
/*    SELECT apisc.check_date
    INTO   l_awt_date
    FROM   ap_invoice_selection_criteria apisc
    WHERE  apisc.checkrun_name = P_Checkrun_Name;

-- RG
   SELECT payment_date
   INTO l_awt_date
   FROM IBY_HOOK_PAYMENTS_T ipmt
   WHERE ipmt.call_app_pay_service_req_code  = P_Checkrun_Name
   AND   ipmt.calling_app_id=200;
*/

   -------------------------------------------------------------
    -- Calculates withholding for each different payment within
    -- the payment batch
    -------------------------------------------------------------
    OPEN c_selected_checks (P_Checkrun_Name);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Looping thru c_selected_checks');
    END IF;
    -- End Debug

    LOOP
        FETCH c_selected_checks INTO rec_selected_checks;
        EXIT WHEN c_selected_checks%NOTFOUND;

        -----------------------------------------
        -- Executes First Processing Unit
        -- Creates Temporary Distribution Lines
        -----------------------------------------
        SAVEPOINT Before_Calc_Withholding;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Calculate_AWT_Amounts');
        END IF;
        -- End Debug

        Calculate_AWT_Amounts (P_Checkrun_Name,
                               P_Checkrun_ID,
                               null,
                               rec_selected_checks.payment_id,
                               rec_selected_checks.payment_date,
                               P_Calling_Module,
                               l_calling_sequence,
                               l_total_wh_amount,
                               P_AWT_Success,
                               P_Last_Updated_By,
                               P_Last_Update_Login,
                               P_Program_Id,
                               P_Request_Id);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('After Called Calculate_AWT_Amounts');
        END IF;
        -- End Debug

        --------------------------------------------------------
        -- Checks whether the calculation finishes successfully
        --------------------------------------------------------
        IF (P_AWT_Success <> AWT_SUCCESS) THEN
           -- Debug Information
           IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Reject_Payment_Batch - P_AWT_Success <> AWT_SUCCESS ');
           END IF;
           -- End Debug

            Reject_Payment_Batch (rec_selected_checks.payment_id,
                                  P_AWT_Success,
                                  l_calling_sequence);

        ---------------------------------------------------
        -- Checks whether the payment amount is enough to
        -- cover the withholding amount
        ---------------------------------------------------
        ELSIF (NOT Partial_Payment_Paid_In_Full(null,
                                       rec_selected_checks.payment_id,
                                       P_Calling_Module,
                                       l_total_wh_amount,
                                       l_calling_sequence,
                                       l_vendor_name,
                                       l_vendor_site_code)) THEN
             --                          l_payment_amount))     Bug# 2807464
             --  AND l_payment_amount > 0 THEN --- Bug 2157401  Bug# 2807464

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling - NOT Partial_Payment_Paid_In_Full');
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ROLLBACK TO Before_Calc_Withholding');
            END IF;
            -- End Debug

            ROLLBACK TO Before_Calc_Withholding;

            Fnd_Message.Set_Name ('JL', 'JL_AR_AP_PARTIAL_BATCH_ERROR');
            Fnd_Message.Set_Token('WH_AMOUNT',  l_total_wh_amount);
            P_AWT_Success := Fnd_Message.Get;

           -- Debug Information
           IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Reject_Payment_Batch - NOT Pay_in_Full');
           END IF;
           -- End Debug

            Reject_Payment_Batch (rec_selected_checks.payment_id,
                                  P_AWT_Success,
                                  l_calling_sequence);

        -----------------------------------------------
        -- Updates payment amounts with the calculated
        -- withholding amount
        -----------------------------------------------
        ELSE

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Update_Payment_Batch');
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: P_Checkrun_Name = '||P_Checkrun_Name);
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter: rec_selected_checks.selected_check_id = '||
                                                         to_char(rec_selected_checks.payment_id));
            END IF;
            -- End Debug

            Update_Payment_Batch (P_Checkrun_Name,
                                  p_checkrun_id,
                                  rec_selected_checks.payment_id,
                                  l_calling_sequence);

        END IF;

    END LOOP;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Close Cursor c_selected_checks');
    END IF;
    -- End Debug

    CLOSE c_selected_checks;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' P_AWT_Success ='||P_AWT_Success);
    END IF;
    -- End Debug

    P_AWT_Success := AWT_SUCCESS;

	 -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE - Do_AWT_Build_Payment_Batch(-)');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Error Do_AWT_Build_Payment_Batch= '||SQLERRM);
        END IF;
        -- End Debug

        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                    '  Checkrun Name= '      || P_Checkrun_Name ||
                    ', Calling Module= '     || P_Calling_Module);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;
        P_AWT_Success := AWT_ERROR;
        App_Exception.Raise_Exception;

END Do_AWT_Build_Payment_Batch;



/**************************************************************************
 *                                                                        *
 * Name       : Do_AWT_Confirm_Payment_Batch                              *
 * Purpose    : Withholding Tax Calculation for Payment Batches           *
 *              (Confirm Payment Stage)                                   *
 *               Processing units to be executed:                         *
 *               2. Create AWT Distribution Lines                         *
 *               3. Create AWT Invoices                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Do_AWT_Confirm_Payment_Batch
                    (P_Checkrun_Name            IN     Varchar2,
                     P_Checkrun_ID              IN     Number,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null)
IS
    -------------------------------
    -- Local Variables Definition
    -------------------------------
    l_create_distr           Varchar2(25);
    l_create_invoices        Varchar2(25);
    --   l_awt_date               Date;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

    ------------------------------------
    -- Cursor to select all the invoices
    -- within the payment
    -------------------------------------
/*    CURSOR c_selected_invoices (P_Checkrun_Name IN Varchar2)
    IS
    SELECT apsi.invoice_id                invoice_id,
           apsi.payment_num               payment_num,
           apin.invoice_currency_code     invoice_curr_code
    FROM   ap_selected_invoices           apsi,
           ap_selected_invoice_checks     apsic,
unique_ref2 invoice_id,
          docs.calling_app_doc_uniq
           ap_invoices                    apin
    WHERE  apsic.checkrun_name           = P_Checkrun_Name
    AND    apsi.checkrun_name            = P_Checkrun_Name
    AND   (apsic.status_lookup_code      = 'NEGOTIABLE'
        OR apsic.status_lookup_code      = 'ISSUED')
    AND    apsic.selected_check_id       = apsi.pay_selected_check_id
    AND    nvl(apsi.ok_to_pay_flag, 'Y') = 'Y'
    AND    apin.invoice_id               = apsi.invoice_id
    AND    apsi.original_invoice_id IS NULL;
*/

 -- R12 Changes uptake IBY
 CURSOR c_selected_invoices (p_checkrun_id IN NUMBER) IS
   SELECT docs.calling_app_doc_unique_ref2 invoice_id,
          docs.calling_app_doc_unique_ref3 payment_num,
          docs.document_currency_code invoice_curr_code,
          docs.payment_date,
          docs.org_id
   FROM IBY_FD_PAYMENTS_V ipmt,
        IBY_FD_DOCS_PAYABLE_V  docs
   WHERE to_number(docs.calling_app_doc_unique_ref1) = p_checkrun_id
   AND   ipmt.payment_id = docs.payment_id
   AND   (ipmt.payment_status      = 'NEGOTIABLE'
        OR ipmt.payment_status      = 'ISSUED'
        OR ipmt.payment_status      = 'FORMATTED'
        OR ipmt.payment_status      = 'TRANSMITTED'
        OR ipmt.payment_status      = 'ACKNOWLEDGED'
        OR ipmt.payment_status      = 'BANK_VALIDATED'
        OR ipmt.payment_status      = 'PAID')
   AND   ipmt.payments_complete_flag ='Y'
   AND   docs.calling_app_id= 200;

    ----------------------
    -- Record Declaration
    ----------------------
    rec_sel_inv   c_selected_invoices%ROWTYPE;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Do_AWT_Confirm_Payment_Batch<--' ||
                           P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Do_AWT_Confirm_Payment_Batch(+)'||
              'Parameter: P_Checkrun_Name = '||P_Checkrun_Name||
              'Parameter: P_Calling_Module = '||P_Calling_Module||
              'Parameter: P_Calling_Sequence = '||P_Calling_Sequence||
              'Parameter: P_Checkrun_ID = '||to_char(P_Checkrun_ID));
    END IF;
    -- End Debug

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    --------------------------------------------------
    -- Confirms each payment within the payment batch
    ---------------------------------------------------
    OPEN c_selected_invoices (P_Checkrun_ID);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Looping Thru c_selected_invoices');
    END IF;
    -- End Debug

    LOOP
        FETCH c_selected_invoices INTO rec_sel_inv;
        EXIT WHEN c_selected_invoices%NOTFOUND;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug
            (' Fetched Values: rec_sel_inv.invoice_id: '||to_char(rec_sel_inv.invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug
            (' Fetched Values: rec_sel_inv.payment_num: '||to_char(rec_sel_inv.payment_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug
         (' Fetched Values: rec_sel_inv.invoice_curr_code: '||rec_sel_inv.invoice_curr_code);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug
             (' Fetched Values: rec_sel_inv.payment_date: '||rec_sel_inv.payment_date);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug
             (' Fetched Values: rec_sel_inv.org_id: '||to_char(rec_sel_inv.org_id));
        END IF;
        -- End Debug

       ----------------------------
       -- Gets Withholding Options
       ----------------------------

       -- Debug Information
       IF (DEBUG_Var = 'Y') THEN
          JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Get_Withholding_Options ');
       END IF;
       -- End Debug

       --Jl_Zz_Ap_Withholding_Pkg.Get_Withholding_Options (l_create_distr,
       --                                               l_create_invoices);
       -- Bug 5442868
       SELECT  nvl(create_awt_dists_type, 'NEVER'),
               nvl(create_awt_invoices_type, 'NEVER')
       INTO    l_create_distr,
               l_create_invoices
       FROM    ap_system_parameters_all
       WHERE   org_id = rec_sel_inv.org_id;

       -- Debug Information
       IF (DEBUG_Var = 'Y') THEN
          JL_ZZ_AP_EXT_AWT_UTIL.Debug
            ('Withholding Opt: l_crte_dst and l_crte_inv: '||l_create_distr||', '||l_create_invoices);
       END IF;
       -- End Debug

       IF (l_create_distr <> 'PAYMENT') THEN
           -- Nothing to do
           RETURN;
       END IF;

       ------------------------
       -- Obtains the AWT Date
       ------------------------
   /*    SELECT apisc.check_date
       INTO   l_awt_date
       FROM   ap_invoice_selection_criteria apisc
       WHERE  apisc.checkrun_name = P_Checkrun_Name;
   */

        -----------------------------------------
        -- Creates AWT Distribution Lines
        -----------------------------------------

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug
             ('==> Calling  Ap_Withholding_Pkg.Create_AWT_Distributions');
        END IF;
        -- End Debug

        Ap_Withholding_Pkg.Create_AWT_Distributions
                                (rec_sel_inv.invoice_id,
                                 P_Calling_Module,
                                 l_create_distr,
                                 rec_sel_inv.payment_num,
                                 rec_sel_inv.invoice_curr_code,
                                 P_Last_Updated_By,
                                 P_Last_Update_Login,
                                 P_Program_Application_Id,
                                 P_Program_Id,
                                 P_Request_Id,
                                 l_calling_sequence);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug
                ('After Called  Ap_Withholding_Pkg.Create_AWT_Distributions');
        END IF;
        -- End Debug

        ------------------------
        -- Creates AWT Invoices
        ------------------------
        IF (l_create_invoices = 'PAYMENT') THEN

           -- Debug Information
           IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Ap_Withholding_Pkg.Create_AWT_Invoices');
           END IF;
           -- End Debug

           Ap_Withholding_Pkg.Create_AWT_Invoices
                                    (rec_sel_inv.invoice_id,
                                     rec_sel_inv.payment_date,
                                     P_Last_Updated_By,
                                     P_Last_Update_Login,
                                     P_Program_Application_Id,
                                     P_Program_Id,
                                     P_Request_Id,
                                     l_calling_sequence);
                                     --P_Calling_Module);
						   -- bug 6835131  No change in AP Pkg for branchline, only in mainline
        END IF;

    END LOOP;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Close Cursor c_selected_invoices');
    END IF;
    -- End Debug

    CLOSE c_selected_invoices;

    ---------------------------
    -- Confirms credit letters
    ---------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Confirm_Credit_Letters');
    END IF;
    -- End Debug

    Confirm_Credit_Letters (P_Checkrun_Name,P_Checkrun_ID, l_calling_sequence);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Do_AWT_Confirm_Payment_Batch (-)');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
      -- Debug Information
         IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Confirm ERROR: '||SQLERRM);
         END IF;
      -- end debug

        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                    '  Checkrun Name= '     || P_Checkrun_Name  ||
                    ', Calling Module= '    || P_Calling_Module);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Do_AWT_Confirm_Payment_Batch;



/**************************************************************************
 *                                                                        *
 * Name       : Calculate_AWT_Amounts                                     *
 * Purpose    : This procedure performs all the withholding calculations  *
 *              and generates the temporary distribution lines.           *
 *              It also updates buckets and credit letter amounts.        *
 *                                                                        *
 **************************************************************************/
PROCEDURE Calculate_AWT_Amounts
                    (P_Checkrun_Name            IN     Varchar2,
                     P_Checkrun_ID              IN     Number,
                     P_Check_Id                 IN     Number,
                     P_Selected_Check_Id        IN     Number,
                     P_AWT_Date                 IN     Date,
                     P_Calling_Module           IN     Varchar2,
                     P_Calling_Sequence         IN     Varchar2,
                     P_Total_Wh_Amount          OUT NOCOPY    Number,
                     P_AWT_Success              OUT NOCOPY    Varchar2,
                     P_Last_Updated_By          IN     Number     Default null,
                     P_Last_Update_Login        IN     Number     Default null,
                     P_Program_Application_Id   IN     Number     Default null,
                     P_Program_Id               IN     Number     Default null,
                     P_Request_Id               IN     Number     Default null)
IS
    ------------------------
    -- Variables Definition
    ------------------------
    l_previous_awt_type_code    Varchar2(30);
    l_previous_tax_id           Number;
    l_previous_invoice_id       Number;
    l_current_vendor_id         Number;
    l_current_awt               Number;
    l_initial_awt               Number;
    l_tax_base_amt              Number;
    l_gl_period_name            Varchar2(100);
    l_base_currency_code        Varchar2(15);
    l_not_found                 Boolean;
    l_total_wh_amount           Number := 0;
    l_debug_info                Varchar2(300);
    l_calling_sequence          Varchar2(2000);
    l_CODE_ACCOUNTING_DATE      DATE;                 -- Argentina AWT ER 6624809

    ------------------------------------------------------------
    -- Cursor to select all the withholding tax types and names
    -- associated to all the invoices within the Quick Payment.
    -- The cursor will be ordered by:
    --  - Withholding tax type, tax name, invoice ID
    --    (For those payment based withholding taxes)
    --  - Invoice ID, withholding tax type, tax name
    --    (For those invoice based withholding taxes)
    ------------------------------------------------------------
    CURSOR c_payment_withholdings (P_Check_Id Number)
    IS
    SELECT
       jlst.awt_type_code                         awt_type_code,
       jlsc.tax_id                                tax_id,
       apin.invoice_id                            invoice_id,
       apin.vendor_id                             vendor_id,
       apid.invoice_distribution_id               invoice_distribution_id, -- Lines
       nvl(apin.invoice_amount, apin.base_amount) invoice_amount,
       -- Payment Exchange Rate ER 8648739 Start 1
       -- nvl(apid.base_amount, apid.amount)         line_amount,
       (apid.amount * nvl(apip.exchange_rate,1))  line_amount,
       -- Payment Exchange Rate ER 8648739 End 1
       apip.amount                                payment_amount,
       apip.invoice_payment_id                    invoice_payment_id,
       apip.payment_num                           payment_num,
       jlty.taxable_base_amount_basis             tax_base_amount_basis
    FROM
       jl_zz_ap_inv_dis_wh         jlwh,
       ap_invoices                 apin,
       ap_invoice_distributions    apid,
       ap_invoice_payments         apip,
       jl_zz_ap_supp_awt_types     jlst,
       jl_zz_ap_sup_awt_cd         jlsc,
       jl_zz_ap_awt_types          jlty
    WHERE
           apid.invoice_id               = jlwh.invoice_id
    -- AND    apid.distribution_line_number = jlwh.distribution_line_number - Lines 4382256
    AND    apid.invoice_distribution_id  = jlwh.invoice_distribution_id -- Lines
    AND    apin.invoice_id               = apid.invoice_id
    AND    apin.invoice_id               = apip.invoice_id
    AND    jlwh.supp_awt_code_id         = jlsc.supp_awt_code_id
    AND    jlsc.supp_awt_type_id         = jlst.supp_awt_type_id
    AND    jlst.awt_type_code            = jlty.awt_type_code
    AND    apip.check_id                 = P_Check_Id
    -- added recently
    AND    NVL(apid.REVERSAL_FLAG,'N') <> 'Y'
    AND    NVL(apip.ACCOUNTING_DATE,sysdate) between                                  -- Argentina AWT ER 6624809
 	                 NVL(jlsc.effective_start_date,To_Date('01-01-1950', 'DD-MM-YYYY'))
 	             and NVL(jlsc.effective_end_date,To_Date('31-12-9999', 'DD-MM-YYYY'))
    ORDER BY
           to_number(decode(jlty.taxable_base_amount_basis, 'INVOICE',
                                                             apin.invoice_id,
                                                             DUMMY_INVOICE_ID)),
           jlst.awt_type_code,
           jlsc.tax_id,
           apin.invoice_id,
           apip.invoice_payment_id;

/* This would be the query needed if for quick payment we use IBY tables
    SELECT
       jlst.awt_type_code                         awt_type_code,
       jlsc.tax_id                                tax_id,
       apin.invoice_id                            invoice_id,
       apin.vendor_id                             vendor_id,
       apid.invoice_distribution_id               invoice_distribution_id,  -- Lines
       nvl(apin.invoice_amount, apin.base_amount) invoice_amount,
       nvl(apid.base_amount, apid.amount)         line_amount,
 --       apsi.payment_amount                     payment_amount,
       docs.document_amount                       payment_amount,
       null                                       invoice_payment_id,
  --     apsi.payment_num                           payment_num,
        to_number(docs.calling_app_doc_unique_ref3)          payment_num,
       jlty.taxable_base_amount_basis             tax_base_amount_basis
    FROM
       jl_zz_ap_inv_dis_wh         jlwh,
       ap_invoices                 apin,
       ap_invoice_distributions    apid,
       iby_hook_docs_in_pmt_t      docs,
       jl_zz_ap_supp_awt_types     jlst,
       jl_zz_ap_sup_awt_cd         jlsc,
       jl_zz_ap_awt_types          jlty
    WHERE  docs.payment_id = P_Check_Id
    AND apid.invoice_id    = jlwh.invoice_id
 -- AND    apid.distribution_line_number = jlwh.distribution_line_number - Lines 4382256
    AND    apid.invoice_distribution_id  = jlwh.invoice_distribution_id -- Lines
    AND    apin.invoice_id               = apid.invoice_id
    AND    apin.invoice_id    = to_number(docs.calling_app_doc_unique_ref2)
    AND    jlwh.supp_awt_code_id         = jlsc.supp_awt_code_id
    AND    jlsc.supp_awt_type_id         = jlst.supp_awt_type_id
    AND    jlst.awt_type_code            = jlty.awt_type_code
    AND    docs.dont_pay_flag  = 'N'
    AND    docs.calling_app_id =200
     ORDER BY
           to_number(decode(jlty.taxable_base_amount_basis, 'INVOICE',
                                                             apin.invoice_id,
                                                             DUMMY_INVOICE_ID)),
           jlst.awt_type_code,
           jlsc.tax_id,
           docs.calling_app_doc_unique_ref2,
           docs.calling_app_doc_unique_ref3;
*/


    ------------------------------------------------------------
    -- Cursor to select all the withholding tax types and names
    -- associated to all the invoices within the Payment Batch.
    -- The cursor will be ordered by:
    --  - Withholding tax type, tax name, invoice ID
    --    (For those payment based withholding taxes)
    --  - Invoice ID, withholding tax type, tax name
    --    (For those invoice based withholding taxes)

    -- Change this cursor to Select Payments in the Payment ID
    ------------------------------------------------------------
    CURSOR c_payment_batch_withholdings (P_Selected_Check_Id  Number)
    IS
    SELECT
       jlst.awt_type_code                         awt_type_code,
       jlsc.tax_id                                tax_id,
       apin.invoice_id                            invoice_id,
       apin.vendor_id                             vendor_id,
       apid.invoice_distribution_id               invoice_distribution_id,  -- Lines
       nvl(apin.invoice_amount, apin.base_amount) invoice_amount,
       -- Payment Exchange Rate ER 8648739 Start 2
       -- nvl(apid.base_amount, apid.amount)         line_amount,
       (apid.amount * nvl(apsi.payment_exchange_rate,1)) line_amount,
       -- Payment Exchange Rate ER 8648739 End 2
 --       apsi.payment_amount                     payment_amount,
       docs.document_amount                       payment_amount,
       null                                       invoice_payment_id,
  --     apsi.payment_num                           payment_num,
        to_number(docs.calling_app_doc_unique_ref3)          payment_num,
       jlty.taxable_base_amount_basis             tax_base_amount_basis
    FROM
       jl_zz_ap_inv_dis_wh         jlwh,
       ap_invoices                 apin,
       ap_invoice_distributions    apid,
       -- Payment Exchange Rate ER 8648739 Start 3
       ap_selected_invoices        apsi,
       -- Payment Exchange Rate ER 8648739 End 3
       iby_hook_docs_in_pmt_t      docs,
       jl_zz_ap_supp_awt_types     jlst,
       jl_zz_ap_sup_awt_cd         jlsc,
       jl_zz_ap_awt_types          jlty
    WHERE  docs.payment_id = P_Selected_Check_Id
    AND apid.invoice_id    = jlwh.invoice_id
 -- AND    apid.distribution_line_number = jlwh.distribution_line_number - Lines 4382256
    AND    apid.invoice_distribution_id  = jlwh.invoice_distribution_id -- Lines
    AND    apin.invoice_id               = apid.invoice_id
--     AND    apin.invoice_id               = apsi.invoice_id
    AND    apin.invoice_id    = to_number(docs.calling_app_doc_unique_ref2)
    AND    jlwh.supp_awt_code_id         = jlsc.supp_awt_code_id
    AND    jlsc.supp_awt_type_id         = jlst.supp_awt_type_id
    AND    jlst.awt_type_code            = jlty.awt_type_code
    AND    docs.dont_pay_flag  = 'N'
    AND    docs.calling_app_id =200
        -- added recently
    AND    NVL(apid.REVERSAL_FLAG,'N') <> 'Y'
--   AND    apsi.pay_selected_check_id    = P_Selected_Check_Id
--   AND    nvl(apsi.ok_to_pay_flag, 'Y') = 'Y'
--    AND    apsi.original_invoice_id IS NULL
    -- Payment Exchange Rate ER 8648739 Start 4
    AND apsi.invoice_id = docs.calling_app_doc_unique_ref2
    -- Payment Exchange Rate ER 8648739 End 4
     ORDER BY
           to_number(decode(jlty.taxable_base_amount_basis, 'INVOICE',
                                                             apin.invoice_id,
                                                             DUMMY_INVOICE_ID)),
           jlst.awt_type_code,
           jlsc.tax_id,
           docs.calling_app_doc_unique_ref2,
           docs.calling_app_doc_unique_ref3;

    ------------------------
    -- Records Declaration
    ------------------------
    rec_payment_wh        Rec_Payment_Withholding;
    rec_awt_type          jl_zz_ap_awt_types%ROWTYPE;
    rec_awt_name          Jl_Zz_Ap_Withholding_Pkg.Rec_AWT_Code;
    rec_suppl_awt_type    jl_zz_ap_supp_awt_types%ROWTYPE;
    rec_suppl_awt_name    jl_zz_ap_sup_awt_cd%ROWTYPE;

    ------------------------
    -- Tables Declaration
    ------------------------
    tab_payment_wh        Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding;
    tab_all_wh            Jl_Zz_Ap_Withholding_Pkg.Tab_All_Withholding;
    tab_inv_amounts       Tab_Amounts;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Calculate_AWT_Amounts<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Calculate_AWT_Amounts(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Checkrun_Name : '||P_Checkrun_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Check_Id : '||to_char(P_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Selected_Check_Id : '||to_char(P_Selected_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_AWT_Date : '||to_char(P_AWT_Date,'YYYY/MM/DD'));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Calling_Module : '||P_Calling_Module);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug


    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    -------------------------------
    -- Initializes output argument
    -------------------------------
    P_Total_Wh_Amount := 0;

    ---------------------------
    -- Gets generic parameters
    ---------------------------
    l_base_currency_code := Jl_Zz_Ap_Withholding_Pkg.Get_Base_Currency_Code;
    l_gl_period_name     := Jl_Zz_Ap_Withholding_Pkg.Get_GL_Period_Name
                                                                (P_AWT_Date);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Generic Parameters: l_base_currency_code: '||l_base_currency_code);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Generic Parameters: l_gl_period_name: '||l_gl_period_name);
    END IF;
    -- End Debug


    -------------------------------------------------------------
    -- Calculates the taxable base amount for each distribution
    -- line included within the payment
    -------------------------------------------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Calculate_Taxable_Base_Amounts');
    END IF;
    -- End Debug

    Calculate_Taxable_Base_Amounts (P_Check_Id,
                                    P_Selected_Check_Id,
                                    l_base_currency_code,
                                    tab_inv_amounts,
                                    P_Calling_Module,
                                    l_calling_sequence);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('After Called Calculate_Taxable_Base_Amounts');
    END IF;
    -- End Debug

    -------------------------------------------------------
    -- Defines a Save Point for the temporary calculations
    -------------------------------------------------------
    SAVEPOINT Before_Temporary_Calculations;

    ----------------------------------------
    -- Opens the cursor to select all the
    -- withholdings to process
    ----------------------------------------

    IF (P_Calling_Module = 'QUICKCHECK') THEN
        OPEN c_payment_withholdings (P_Check_Id);

       -- Debug Information
       IF (DEBUG_Var = 'Y') THEN
          JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Open Cursor c_payment_withholdings for Quick Payments');
       END IF;
       -- End Debug


        FETCH c_payment_withholdings INTO rec_payment_wh;

        IF (c_payment_withholdings%NOTFOUND) THEN

         -- Debug Information
         IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug ('No rows in the cursor c_payment_withholdings');
         END IF;
         -- End Debug
            RETURN;
        END IF;

    ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
        OPEN c_payment_batch_withholdings (P_Selected_Check_Id);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Open Cursor c_payment_batch_withholdings for AutoSelect');
        END IF;
        -- End Debug

        FETCH c_payment_batch_withholdings INTO rec_payment_wh;

        IF (c_payment_batch_withholdings%NOTFOUND) THEN

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('No rows in the cursor c_payment_batch_withholdings');
            END IF;
            -- End Debug
            RETURN;
        END IF;
    ELSE
        RETURN;
    END IF; -- End if (P_Calling_Module = 'QUICKCHECK')

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: awt_type_code= '||rec_payment_wh.awt_type_code);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: tax_id= '||to_char(rec_payment_wh.tax_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_id= '||to_char(rec_payment_wh.invoice_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: vendor_id= '||to_char(rec_payment_wh.vendor_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_distribution_id = '||
                                     to_char(rec_payment_wh.invoice_distribution_id ));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_amount= '||to_char(rec_payment_wh.invoice_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: line_amount= '||to_char(rec_payment_wh.line_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: payment_amount= '||to_char(rec_payment_wh.payment_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_payment_id= '||to_char(rec_payment_wh.invoice_payment_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: payment_num= '||to_char(rec_payment_wh.payment_num));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: tax_base_amount_basis= '||rec_payment_wh.tax_base_amount_basis);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

    ---------------------------------------
    -- Initialize auxiliary variables
    ---------------------------------------
    l_current_vendor_id      := rec_payment_wh.vendor_id;
    l_previous_awt_type_code := rec_payment_wh.awt_type_code;
    l_previous_tax_id        := rec_payment_wh.tax_id;
    l_previous_invoice_id    := rec_payment_wh.invoice_id;

    -------------------------------------------
    -- Obtains the all information associated
    -- to the withholding taxes and initialize
    -- the PL/SQL table to store them
    -------------------------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('==> Calling Initialize_Withholdings');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Invoice_payment_id= '||to_char(rec_payment_wh.invoice_payment_id));
    END IF;
    -- End Debug

/*
       select TO_DATE(apip.ACCOUNTING_DATE, 'DD-MM-YYYY') into l_CODE_ACCOUNTING_DATE          -- Argentina AWT ER
 	     from ap_invoice_payments apip
 	     where apip.INVOICE_PAYMENT_ID = rec_payment_wh.invoice_payment_id;
*/

-- Bug: 8688219. Modified the payment Date Retrieval Logic for PPR
    IF (p_calling_module = 'QUICKCHECK')
      THEN
      -- End Debug
      SELECT TO_DATE (apip.accounting_date, 'DD-MM-YYYY')
        INTO l_code_accounting_date                        -- Argentina AWT ER
        FROM ap_invoice_payments apip
       WHERE apip.invoice_payment_id = rec_payment_wh.invoice_payment_id;
    ELSIF (p_calling_module = 'AUTOSELECT') then
       SELECT TO_DATE (apsc.check_date, 'DD-MM-YYYY')
        INTO l_code_accounting_date                        -- Argentina AWT ER
        FROM ap_inv_selection_criteria_all apsc
       WHERE apsc.checkrun_id = p_checkrun_id;
   END IF;
                                                                                               -- Argentina AWT ER
 	     JL_ZZ_AP_EXT_AWT_UTIL.Debug ('l_CODE_ACCOUNTING_DATE= '||to_char(l_CODE_ACCOUNTING_DATE));

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Calling Initialize_Withholdings');
    END IF;
    -- End Debug

    Initialize_Withholdings (rec_payment_wh.vendor_id,
                             rec_payment_wh.awt_type_code,
                             rec_payment_wh.tax_id,
                             l_calling_sequence,
                             rec_awt_type,
                             rec_awt_name,
                             rec_suppl_awt_type,
                             rec_suppl_awt_name,
                             tab_payment_wh,
                             l_CODE_ACCOUNTING_DATE);          -- Argentina AWT ER 6624809,change for payment date

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Initialize_Withholdings');
    END IF;
    -- End Debug

    l_current_awt := 0;
    l_initial_awt := 1;

    --------------------------------------------
    -- Loop for each withholding tax type and
    -- tax name associated to the payment
    --------------------------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Loop for each withholding tax type and tax name associated to the payment');
    END IF;
    -- End Debug

    LOOP
        ---------------------------------------
        -- Checks whether there are more taxes
        ---------------------------------------
        IF (P_Calling_Module = 'QUICKCHECK') THEN
            l_not_found := c_payment_withholdings%NOTFOUND;
        ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
            l_not_found := c_payment_batch_withholdings%NOTFOUND;
        END IF;

        IF (l_not_found) THEN

            -----------------------------------------------------
            -- Process previous withholding tax name information
            -----------------------------------------------------

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name when l_not_found');
            END IF;
            -- End Debug

            Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name
                                        (l_current_vendor_id,
                                         rec_awt_type,
                                         rec_awt_name,
                                         rec_suppl_awt_type,
                                         rec_suppl_awt_name,
                                         P_AWT_Date,
                                         tab_payment_wh,
                                         l_initial_awt,
                                         l_current_awt,
                                         tab_all_wh,
                                         P_AWT_Success);

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name when l_not_found');
            END IF;
            -- End Debug

            IF (P_AWT_Success <> AWT_SUCCESS) THEN
                ROLLBACK TO Before_Temporary_Calculations;
                RETURN;
            END IF;

            ------------------------------------------------------
            -- Process previous withholding tax type information.
            -- Prorates the withheld amount by invoice and
            -- inserts temporary distribution lines
            ------------------------------------------------------
            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Process_Withholdings when l_not_found');
            END IF;
            -- End Debug

            Process_Withholdings (l_current_vendor_id,
                                  rec_awt_type,
                                  rec_suppl_awt_type,
                                  P_AWT_Date,
                                  l_gl_period_name,
                                  l_base_currency_code,
                                  P_Check_Id,
                                  P_Selected_Check_Id,
                                  l_calling_sequence,
                                  tab_payment_wh,
                                  l_total_wh_amount,
                                  P_AWT_Success,
                                  P_Last_Updated_By,
                                  P_Last_Update_Login,
                                  P_Program_Application_Id,
                                  P_Program_Id,
                                  P_Request_Id,
                                  P_Calling_Module,
                                  P_Checkrun_Name,
                                  P_Checkrun_ID,
                                  rec_payment_wh.payment_num);


            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Process_Withholdings when l_not_found');
            END IF;
            -- End Debug

            IF (P_AWT_Success <> AWT_SUCCESS) THEN
                ROLLBACK TO Before_Temporary_Calculations;
                RETURN;
            END IF;


        ---------------------------------------------------------
        -- Checks whether the withholding tax type has changed
        -- (or whether the invoice has changed for those invoice
        -- based withholding taxes)
        ---------------------------------------------------------
        ELSIF (rec_payment_wh.awt_type_code <> l_previous_awt_type_code OR
               (rec_payment_wh.awt_type_code = l_previous_awt_type_code AND
                rec_payment_wh.invoice_id <> l_previous_invoice_id AND
                rec_awt_type.taxable_base_amount_basis = 'INVOICE')) THEN

            ------------------------------------------------
            -- Process previous withholding tax information
            ------------------------------------------------

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  ==> Calling Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name IN ');
            END IF;
            -- End Debug

            Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name
                                        (l_current_vendor_id,
                                         rec_awt_type,
                                         rec_awt_name,
                                         rec_suppl_awt_type,
                                         rec_suppl_awt_name,
                                         P_AWT_Date,
                                         tab_payment_wh,
                                         l_initial_awt,
                                         l_current_awt,
                                         tab_all_wh,
                                         P_AWT_Success);

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  After Called Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name IN ELSIF');
            END IF;
            -- End Debug

            IF (P_AWT_Success <> AWT_SUCCESS) THEN
                ROLLBACK TO Before_Temporary_Calculations;
                RETURN;
            END IF;

            ------------------------------------------------------
            -- Process previous withholding tax type information.
            -- Prorates the withheld amount by invoice and
            -- inserts temporary distribution lines
            ------------------------------------------------------

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Process_Withholdings IN ELSIF');
            END IF;
            -- End Debug

            Process_Withholdings (l_current_vendor_id,
                                  rec_awt_type,
                                  rec_suppl_awt_type,
                                  P_AWT_Date,
                                  l_gl_period_name,
                                  l_base_currency_code,
                                  P_Check_Id,
                                  P_Selected_Check_Id,
                                  l_calling_sequence,
                                  tab_payment_wh,
                                  l_total_wh_amount,
                                  P_AWT_Success,
                                  P_Last_Updated_By,
                                  P_Last_Update_Login,
                                  P_Program_Application_Id,
                                  P_Program_Id,
                                  P_Request_Id,
                                  P_Calling_Module,
                                  P_Checkrun_Name,
                                  P_Checkrun_ID,
                                  rec_payment_wh.payment_num);

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Process_Withholdings IN ELSIF');
            END IF;
            -- End Debug


            IF (P_AWT_Success <> AWT_SUCCESS) THEN
                ROLLBACK TO Before_Temporary_Calculations;
                RETURN;
            END IF;

            -------------------------------------------
            -- Obtains the all information associated
            -- to the withholding taxes and initialize
            -- the PL/SQL table to store them
            -------------------------------------------

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Initialize_Withholdings IN ELSIF');
            END IF;
            -- End Debug

            Initialize_Withholdings (rec_payment_wh.vendor_id,
                                     rec_payment_wh.awt_type_code,
                                     rec_payment_wh.tax_id,
                                     l_calling_sequence,
                                     rec_awt_type,
                                     rec_awt_name,
                                     rec_suppl_awt_type,
                                     rec_suppl_awt_name,
                                     tab_payment_wh);

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Initialize_Withholdings IN ELSIF');
            END IF;
            -- End Debug

            ----------------------------------
            -- Initialize auxiliary variables
            ----------------------------------
            l_current_awt := 0;
            l_initial_awt := 1;
            l_previous_awt_type_code := rec_payment_wh.awt_type_code;
            l_previous_tax_id        := rec_payment_wh.tax_id;
            l_previous_invoice_id    := rec_payment_wh.invoice_id;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Aux Variables: l_previous_awt_type_code = '||l_previous_awt_type_code);
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Aux Variables: l_previous_tax_id = '||to_char(l_previous_tax_id));
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Aux Variables: l_previous_invoice_id = '||to_char(l_previous_invoice_id));
            END IF;
           -- End Debug


        -------------------------------------------
        -- Checks whether the tax name has changed
        -------------------------------------------
        ELSIF (rec_payment_wh.tax_id <> l_previous_tax_id) THEN

            ------------------------------------------------
            -- Process previous withholding tax information
            ------------------------------------------------

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name when <> Tax Name');
            END IF;
            -- End Debug
            Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name
                                        (l_current_vendor_id,
                                         rec_awt_type,
                                         rec_awt_name,
                                         rec_suppl_awt_type,
                                         rec_suppl_awt_name,
                                         P_AWT_Date,
                                         tab_payment_wh,
                                         l_initial_awt,
                                         l_current_awt,
                                         tab_all_wh,
                                         P_AWT_Success);

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name when Tax Name Changed');
            END IF;
            -- End Debug

            IF (P_AWT_Success <> AWT_SUCCESS) THEN
                ROLLBACK TO Before_Temporary_Calculations;
                RETURN;
            END IF;

            ---------------------------------------------
            -- Obtains the information associated to the
            -- new withholding tax
            ---------------------------------------------

            -- Debug Information
       IF (DEBUG_Var = 'Y') THEN
        JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Name. Getting Tax Code Info');
       END IF;
            -- End Debug

            Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Name
                                        (rec_payment_wh.awt_type_code,
                                         rec_payment_wh.tax_id,
                                         rec_payment_wh.vendor_id,
                                         rec_awt_name,
                                         rec_suppl_awt_name);

            -----------------------------------
            -- Initializes auxiliary variables
            -----------------------------------

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Initializes auxiliary variables: l_previous_tax_id = '||to_char(l_previous_tax_id));
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Initializes auxiliary variables: l_initial_awt = '||to_char(l_initial_awt));
            END IF;
            -- End Debug

            l_previous_tax_id     := rec_payment_wh.tax_id;
            l_initial_awt         := l_current_awt + 1;

        END IF;  -- End If IF (l_not_found)

        ---------------------------------------
        -- Checks whether there are more taxes
        ---------------------------------------

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Exit if there are NO more taxes');
        END IF;
        -- End Debug

        EXIT WHEN l_not_found;

        -------------------------------------------------------
        -- Checks whether withholding tax should be calculated
        -------------------------------------------------------

        IF (NOT Withholding_Already_Calculated (
                          rec_payment_wh.invoice_id,
                          rec_awt_name.name,
                          rec_awt_name.tax_id,
                          rec_awt_type.taxable_base_amount_basis,
                          tab_payment_wh,
                          rec_payment_wh.payment_num,
                          l_calling_sequence)) THEN

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' IF(NOT Withholding_Already_Calculated - rec_awt_name.name: '||rec_awt_name.name);
            END IF;
            -- End Debug

            -------------------------------------
            -- Obtains the taxable base amount
            -------------------------------------

            l_tax_base_amt := Get_Taxable_Base_Amount
                                   (rec_payment_wh.invoice_id,
                                    rec_payment_wh.invoice_distribution_id , -- Lines
                                    rec_payment_wh.invoice_payment_id,
                                    rec_payment_wh.payment_num,
                                    rec_awt_type.taxable_base_amount_basis,
                                    rec_awt_name.Tax_Inclusive,
                                    tab_inv_amounts,
                                    P_Calling_Module,
                                    l_calling_sequence);

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Got Taxable Base Amount for invoice_id = '||
                                              to_char(rec_payment_wh.invoice_id)||' = '||to_char(l_tax_base_amt));
            END IF;
            -- End Debug

            --------------------------------------------------
            -- Stores the information of the current tax name
            -- into the PL/SQL table
            --------------------------------------------------

            l_current_awt := l_current_awt + 1;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Increate l_current_awt = '||to_char(l_current_awt));
               JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==>Calling Jl_Zz_Ap_Withholding_Pkg.Store_Tax_Name');
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('    Invoice_id = '||to_char(rec_payment_wh.invoice_id)||' - '||
                                                 'Tax_id = '||to_char(rec_payment_wh.tax_id)||' - '||
                                                 'Tax Name = '||rec_awt_name.name);
            END IF;
            -- End Debug

            Jl_Zz_Ap_Withholding_Pkg.Store_Tax_Name
                           (tab_payment_wh,
                            l_current_awt,
                            rec_payment_wh.invoice_id,
                            rec_payment_wh.invoice_distribution_id , -- Lines
                            rec_payment_wh.awt_type_code,
                            rec_payment_wh.tax_id,
                            rec_awt_name.name,
                            rec_awt_name.tax_code_combination_id,
                            rec_awt_name.awt_period_type,
                            rec_awt_type.jurisdiction_type,
                            rec_payment_wh.line_amount,
                            l_tax_base_amt,
                            rec_payment_wh.invoice_payment_id,
                         -- By Zmohiudd for bug 1849986
                            rec_payment_wh.payment_num);

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  After Called Jl_Zz_Ap_Withholding_Pkg.Store_Tax_Name');
            END IF;
            -- End Debug

         END IF; -- NOT Withholding_Already_Calculated

        ------------------------------------------------
        -- Fetches next withholding tax type / tax name
        ------------------------------------------------
        IF (P_Calling_Module = 'QUICKCHECK') THEN
            FETCH c_payment_withholdings INTO rec_payment_wh;
        ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
            FETCH c_payment_batch_withholdings INTO rec_payment_wh;
        END IF;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: awt_type_code= '||rec_payment_wh.awt_type_code);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: tax_id= '||to_char(rec_payment_wh.tax_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_id= '||to_char(rec_payment_wh.invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: vendor_id= '||to_char(rec_payment_wh.vendor_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_distribution_id = '||
                                         to_char(rec_payment_wh.invoice_distribution_id ));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_amount= '||to_char(rec_payment_wh.invoice_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: line_amount= '||to_char(rec_payment_wh.line_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: payment_amount= '||to_char(rec_payment_wh.payment_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: invoice_payment_id= '||to_char(rec_payment_wh.invoice_payment_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: payment_num= '||to_char(rec_payment_wh.payment_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: tax_base_amount_basis= '||rec_payment_wh.tax_base_amount_basis);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
        END IF;
        -- End Debug

    END LOOP;

    ---------------------------------
    -- Closes the withholding cursor
    ---------------------------------
    IF (P_Calling_Module = 'QUICKCHECK') THEN

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Close Cursor c_payment_withholdings');
        END IF;
        -- End Debug
        CLOSE c_payment_withholdings;

    ELSIF (P_Calling_Module = 'AUTOSELECT') THEN

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Close Cursor c_payment_batch_withholdings');
        END IF;
        -- End Debug
        CLOSE c_payment_batch_withholdings;

    END IF;

    ------------------------
    -- Sets output argument
    ------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('P_Total_Wh_Amount: '||l_total_wh_amount);
    END IF;
    -- End Debug

    P_Total_Wh_Amount := l_total_wh_amount;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Print_Tax_Names(tab_payment_wh);
       JL_ZZ_AP_EXT_AWT_UTIL.Print_tab_all_wh(tab_all_wh);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procudure Calculate_AWT_Amounts(-) ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                    '  Checkrun Name= '     || P_Checkrun_Name              ||
                    ', Check Id= '          || to_char(P_Check_Id)          ||
                    ', Selected Check_Id= ' || to_char(P_Selected_Check_Id) ||
                    ', AWT Date= '          || to_char(P_AWT_Date,'YYYY/MM/DD')          ||
                    ', Calling Module= '    || P_Calling_Module);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;
        P_AWT_Success := AWT_ERROR;
        App_Exception.Raise_Exception;

END Calculate_AWT_Amounts;


/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholdings                                   *
 * Purpose    : Obtains all the attributes for the current withholding    *
 *              tax type and name. This procedure also initializes the    *
 *              PL/SQL table to store the withholdings                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholdings
         (P_Vendor_Id           IN     Number,
          P_AWT_Type_Code       IN     Varchar2,
          P_Tax_Id              IN     Number,
          P_Calling_Sequence    IN     Varchar2,
          P_Rec_AWT_Type        OUT NOCOPY    jl_zz_ap_awt_types%ROWTYPE,
          P_Rec_AWT_Name        OUT NOCOPY    Jl_Zz_Ap_Withholding_Pkg.Rec_AWT_Code,
          P_Rec_Suppl_AWT_Type  OUT NOCOPY    jl_zz_ap_supp_awt_types%ROWTYPE,
          P_Rec_Suppl_AWT_Name  OUT NOCOPY    jl_zz_ap_sup_awt_cd%ROWTYPE,
          P_Wh_Table            IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
          P_CODE_ACCOUNTING_DATE  IN        DATE  Default NULL)                           -- Argentina AWT ER
IS

    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Initialize_Withholdings<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procudure Initialize_Withholdings(+)');
    END IF;
    -- End Debug

    -----------------------------------------
    -- Initializes records and PL/SQL tables
    -----------------------------------------

    JL_ZZ_AP_EXT_AWT_UTIL.Debug ('ACCOUNTING_DATE = '||to_char(P_CODE_ACCOUNTING_DATE));

    Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Type
                                (P_AWT_Type_Code,
                                 P_Vendor_Id,
                                 P_Rec_AWT_Type,
                                 P_Rec_Suppl_AWT_Type);

    Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Name
                                (P_AWT_Type_Code,
                                 P_Tax_Id,
                                 P_Vendor_Id,
                                 P_Rec_AWT_Name,
                                 P_Rec_Suppl_AWT_Name,
                                 P_CODE_ACCOUNTING_DATE);                             -- Argentina AWT ER

    Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Table
                                (P_Wh_Table);
	-- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	    JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procudure Initialize_Withholdings(-)');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                        '  Vendor Id= '     || to_char(P_Vendor_Id) ||
                        ', AWT Type Code= ' || P_AWT_Type_Code      ||
                        ', Tax Id= '        || to_char(P_Tax_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Initialize_Withholdings;




/**************************************************************************
 *                                                                        *
 * Name       : Process_Withholdings                                      *
 * Purpose    : Process the information for the current withholding tax   *
 *              type and name                                             *
 *                                                                        *
 **************************************************************************/
PROCEDURE Process_Withholdings
      (P_Vendor_Id              IN     Number,
       P_Rec_AWT_Type           IN     jl_zz_ap_awt_types%ROWTYPE,
       P_Rec_Suppl_AWT_Type     IN     jl_zz_ap_supp_awt_types%ROWTYPE,
       P_AWT_Date               IN     Date,
       P_GL_Period_Name         IN     Varchar2,
       P_Base_Currency_Code     IN     Varchar2,
       P_Check_Id               IN     Number,
       P_Selected_Check_Id      IN     Number,
       P_Calling_Sequence       IN     Varchar2,
       P_Tab_Withhold           IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
       P_Total_Wh_Amount        IN OUT NOCOPY Number,
       P_AWT_Success            OUT NOCOPY    Varchar2,
       P_Last_Updated_By        IN     Number     Default null,
       P_Last_Update_Login      IN     Number     Default null,
       P_Program_Application_Id IN     Number     Default null,
       P_Program_Id             IN     Number     Default null,
       P_Request_Id             IN     Number     Default null,
       P_Calling_Module         IN     Varchar2   Default null,
       P_Checkrun_Name          IN     Varchar2   Default null,
       P_Checkrun_ID            IN     Number     Default null,
       P_Payment_Num            IN     Number     Default null)
IS

    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Process_Withholdings<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Process_Withholdings(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Vendor_Id= '||to_char(P_Vendor_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Rec_AWT_Type.AWT_TYPE_CODE= '||P_Rec_AWT_Type.AWT_TYPE_CODE);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Rec_Suppl_AWT_Type.AWT_TYPE_CODE= '||P_Rec_Suppl_AWT_Type.AWT_TYPE_CODE);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_AWT_Date= '||to_char(P_AWT_Date,'YYYY/MM/DD'));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_GL_Period_Name= '||P_GL_Period_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Base_Currency_Code= '||P_Base_Currency_Code);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Selected_Check_Id= '||to_char(P_Selected_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Checkrun_Id= '||to_char(P_Checkrun_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Print_Tax_Names(P_Tab_Withhold);
    END IF;
    -- End Debug



    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    ------------------------------------------------------
    -- Checks whether there are elements within the table
    ------------------------------------------------------
    IF (P_Tab_Withhold.COUNT <= 0) THEN
        -- Nothing to do
        RETURN;
    END IF;

    -----------------------------------------
    -- Defines a Save Point before inserting
    -----------------------------------------
    SAVEPOINT Before_Process_Withholding;

    ------------------------------------------------
    -- Process previous withholding tax type
    ------------------------------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Type');
    END IF;
    -- End Debug

    Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Type
                                (P_Rec_AWT_Type,
                                 P_Rec_Suppl_AWT_Type,
                                 P_AWT_Date,
                                 P_Base_Currency_Code,
                                 P_Tab_Withhold);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Type');
       JL_ZZ_AP_EXT_AWT_UTIL.Print_Tax_Names(P_Tab_Withhold);
    END IF;
    -- End Debug


    --------------------------------------
    -- Updates Credit Letters Information
    --------------------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Update_Credit_Letter');
    END IF;
    -- End Debug

    Update_Credit_Letter (P_Vendor_Id,
                          P_Rec_AWT_Type,
                          P_AWT_Date,
                          P_Payment_Num,
                          P_Check_Id,
                          P_Selected_Check_Id,
                          l_calling_sequence,
                          P_Tab_Withhold,
                          P_Last_Updated_By,
                          P_Last_Update_Login,
                          P_Program_Application_Id,
                          P_Program_Id,
                          P_Request_Id);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Update_Credit_Letter');
    END IF;
    -- End Debug

    ------------------------------------------------
    -- Prorates withholding within the PL/SQL table
    -------------------------------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Jl_Zz_Ap_Withholding_Pkg.Prorate_Withholdings');
       JL_ZZ_AP_EXT_AWT_UTIL.Print_Tax_Names(P_Tab_Withhold);
    END IF;
    -- End Debug

    Jl_Zz_Ap_Withholding_Pkg.Prorate_Withholdings (P_Tab_Withhold,
                                                   P_Base_Currency_Code);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Jl_Zz_Ap_Withholding_Pkg.Prorate_Withholdings');
       JL_ZZ_AP_EXT_AWT_UTIL.Print_Tax_Names(P_Tab_Withhold);
    END IF;
    -- End Debug


    ----------------------------------------
    -- Insert Temporary Distributions Lines
    ----------------------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ==> Calling Jl_Zz_Ap_Withholding_Pkg.Store_Into_Temporary_Table');
    END IF;
    -- End Debug

    Jl_Zz_Ap_Withholding_Pkg.Store_Into_Temporary_Table
                                (P_Tab_Withhold,
                                 P_Vendor_Id,
                                 P_AWT_Date,
                                 P_GL_Period_Name,
                                 P_Base_Currency_Code,
                                 FALSE,               -- Revised Amount Flag
                                 TRUE,                -- Prorated Amount Flag
                                 TRUE,                -- Zero WH Applicable
                                 TRUE,                -- Update Bucket
                                 P_AWT_Success,
                                 P_Last_Updated_By,
                                 P_Last_Update_Login,
                                 P_Program_Application_Id,
                                 P_Program_Id,
                                 P_Request_Id,
                                 P_Calling_Module,
                                 P_Checkrun_Name,
                                 P_Checkrun_ID,
                                 P_Payment_Num);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' After Called Jl_Zz_Ap_Withholding_Pkg.Store_Into_Temporary_Table');
    END IF;
    -- End Debug

    IF (P_AWT_Success <> AWT_SUCCESS) THEN
        ROLLBACK TO Before_Process_Withholding;
        RETURN;
    END IF;

    ----------------------------------------------
    -- Obtains total withheld amount for current
    -- withholding tax type
    ----------------------------------------------
    P_Total_Wh_Amount := nvl(P_Total_Wh_Amount, 0) +
                         nvl(Total_Withholding_Amount(P_Tab_Withhold,
                                                      l_calling_sequence), 0);


    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Total withheld amount for current tax type: '||to_char(P_Total_Wh_Amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Print_Tax_Names(P_Tab_Withhold);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure Process_Withholdings(-)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                 '  Vendor Id= '          || to_char(P_Vendor_Id)         ||
                 ', AWT Date= '           || to_char(P_AWT_Date,'YYYY/MM/DD')          ||
                 ', GL Period Name= '     || P_GL_Period_Name             ||
                 ', Base Currency Code= ' || P_Base_Currency_Code         ||
                 ', Check Id= '           || to_char(P_Check_Id)          ||
                 ', Selected Check_Id= '  || to_char(P_Selected_Check_Id) ||
                 ', Calling Module=  '    || P_Calling_Module             ||
                 ', Checkrun Name= '      || P_Checkrun_Name              ||
                 ', Payment Num= '        || to_char(P_Payment_Num));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Process_Withholdings;


/**************************************************************************
 *                                                                        *
 * Name       : Calculate_Taxable_Base_Amounts                            *
 * Purpose    : Calculates the taxable base amount for each invoice       *
 *              distribution line included within the payment. The steps  *
 *              to do this are:                                           *
 *              1. Prorates the payment amount for each distribution line *
 *              2. Rounds the prorated amount                             *
 *              Taxable base amounts must be calculated all together in   *
 *              order to avoid rounding mistakes (last amount will be     *
 *              obtained by difference).                                  *
 *                                                                        *
 **************************************************************************/
PROCEDURE Calculate_Taxable_Base_Amounts
                     (P_Check_Id                 IN     Number,
                      P_Selected_Check_Id        IN     Number,
                      P_Currency_Code            IN     Varchar2,
                      P_Tab_Inv_Amounts          IN OUT NOCOPY Tab_Amounts,
                      P_Calling_Module           IN     Varchar2,
                      P_Calling_Sequence         IN     Varchar2)
IS
    ------------------------
    -- Variables definition
    ------------------------
    l_not_found             Boolean := TRUE;
    l_invoice_id            Number;
    l_dist_line_no          Number;
    l_invoice_amount        Number;
    l_invo_payment_id       Number;
    l_previous_inv_pay_id   Number;
    l_amount                Number;
    l_tax_inclusive_amount  Number;
    l_payment_amount        Number;
    l_position              Number;
    l_initial_position      Number;
    l_cumulative_amount     Number := 0;
    l_previous_invoice_id   Number;
    l_previous_inv_pay_num  Number;
    l_invo_payment_num      Number;
    l_debug_info            Varchar2(300);
    l_calling_sequence      Varchar2(2000);
    rec_inv_amount          Rec_Invoice_Amount;


    -------------------------------------------------------
    -- Cursor to select the invoices for the Quick Payment
    -------------------------------------------------------
    CURSOR c_invoice_amounts (P_Check_Id IN Number) IS
    SELECT apin.invoice_id                            invoice_id,
           apid.invoice_distribution_id               invoice_distribution_id , -- Lines
           -- Payment Exchange Rate ER 8648739 Start 5
           -- nvl(apid.base_amount, apid.amount)         amount,
           (apid.amount * nvl(apip.exchange_rate,1))     amount,
           -- Payment Exchange Rate ER 8648739 End 5
           nvl(apid.global_attribute4, 0)             tax_inclusive_amount,
           -- Payment Exchange Rate ER 8648739 Start 6
           -- nvl(apip.invoice_base_amount,apip.amount)  payment_amount,
           (apip.amount * nvl(apip.exchange_rate,1))  payment_amount,
           -- Payment Exchange Rate ER 8648739 End 6
           apip.invoice_payment_id                    invo_payment_id
    FROM   ap_invoices apin,
           ap_invoice_distributions apid,
           ap_invoice_payments apip
    WHERE  apin.invoice_id = apid.invoice_id
    AND    apin.invoice_id = apip.invoice_id
    AND    apip.check_id = P_Check_Id
    AND    apid.line_type_lookup_code <> 'AWT'
            -- added recently
    AND    NVL(apid.REVERSAL_FLAG,'N') <> 'Y'
    ORDER BY apin.invoice_id,
             apip.invoice_payment_id,
             apid.invoice_distribution_id ; -- Lines

/* This would be the cursor to use if quick pmt uses IBY tables.
   SELECT apin.invoice_id                            invoice_id,
           apid.invoice_distribution_id               invoice_distribution_id , -- Lines
           nvl(apid.base_amount, apid.amount)         amount,
           nvl(apid.global_attribute4, 0)             tax_inclusive_amount,
--           apsi.payment_amount*nvl(apsi.invoice_exchange_rate,1)           payment_amount,
--          ,apsi.payment_num                           payment_num
            docs.document_amount* nvl(apsi.invoice_exchange_rate,1)  payment_amount,
            docs.calling_app_doc_unique_ref3     payment_num
    FROM   ap_invoices apin,
           ap_invoice_distributions apid,
           ap_selected_invoices apsi,
           iby_hook_docs_in_pmt_t  docs
    WHERE  apin.invoice_id = apid.invoice_id
    AND    apin.invoice_id = apsi.invoice_id
--    AND    apsi.pay_selected_check_id = P_Selected_Check_Id
    and    docs.payment_id = P_Check_Id
    and    apsi.invoice_id = docs.calling_app_doc_unique_ref2
--    AND   apsi.original_invoice_id IS NULL
    AND   docs.dont_pay_flag = 'N'
    AND   apid.line_type_lookup_code <> 'AWT'
    and   docs.calling_app_id = 200
    ORDER BY apin.invoice_id,
             docs.calling_app_doc_unique_ref3,
             apid.invoice_distribution_id ;
*/

    ------------------------------------------------------
    -- Cursor to select the invoices for Payment Batches
    ------------------------------------------------------
    CURSOR c_batch_invoice_amounts (P_Selected_Check_Id IN Number) IS
    SELECT apin.invoice_id                            invoice_id,
           apid.invoice_distribution_id               invoice_distribution_id , -- Lines
           -- Payment Exchange Rate ER 8648739 Start 7
           -- nvl(apid.base_amount, apid.amount)         amount,
           (apid.amount * nvl(apsi.payment_exchange_rate, 1))         amount,
           -- Payment Exchange Rate ER 8648739 End 7
           nvl(apid.global_attribute4, 0)             tax_inclusive_amount,
           -- Payment Exchange Rate ER 8648739 Start 8
           -- docs.document_amount* nvl(apsi.invoice_exchange_rate,1)  payment_amount,
           (docs.document_amount * nvl(apsi.payment_exchange_rate,1))  payment_amount,
           -- Payment Exchange Rate ER 8648739 End 8
           docs.calling_app_doc_unique_ref3     payment_num
    FROM   ap_invoices apin,
           ap_invoice_distributions apid,
           ap_selected_invoices apsi,
           iby_hook_docs_in_pmt_t  docs
    WHERE  apin.invoice_id = apid.invoice_id
    AND    apin.invoice_id = apsi.invoice_id
--    AND    apsi.pay_selected_check_id = P_Selected_Check_Id
    and    docs.payment_id = P_Selected_Check_Id
    and    apsi.invoice_id = docs.calling_app_doc_unique_ref2
--    AND   apsi.original_invoice_id IS NULL
    AND   docs.dont_pay_flag = 'N'
    AND   apid.line_type_lookup_code <> 'AWT'
    AND   docs.calling_app_id = 200
    -- added recently
    AND    NVL(apid.REVERSAL_FLAG,'N') <> 'Y'
    ORDER BY apin.invoice_id,
             docs.calling_app_doc_unique_ref3,
             apid.invoice_distribution_id ; -- Lines

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Calculate_Taxable_Base_Amounts<--' ||
                           P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Calculate_Taxable_Base_Amounts(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Check_Id= '||to_char(P_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Selected_Check_Id= '||to_char(P_Selected_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Currency_Code= '||P_Currency_Code);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Calling_Module= '||P_Calling_Module);
       JL_ZZ_AP_EXT_AWT_UTIL.Print_tab_amounts(P_Tab_Inv_Amounts);
    END IF;
    -- End Debug

    --------------------
    -- Open the cursor
    --------------------
    IF (P_Calling_Module = 'QUICKCHECK') THEN
        OPEN c_invoice_amounts (P_Check_Id);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Open Cursor c_invoice_amounts');
        END IF;
        -- End Debug

    ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
        OPEN c_batch_invoice_amounts (P_Selected_Check_Id);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Open Cursor c_batch_invoice_amounts');
        END IF;
        -- End Debug

    END IF;

    -----------------------------------
    -- Initializes auxiliary variables
    -----------------------------------

    l_invoice_amount := 0;
    l_position := 1;
    l_initial_position := l_position;
    l_previous_invoice_id := null;
    l_previous_inv_pay_id := null;
    l_previous_inv_pay_num := null;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Auxiliary Variables: l_invoice_amount = '||to_char(l_invoice_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Auxiliary Variables: l_position = '||to_char(l_position));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Auxiliary Variables: l_initial_position = '||to_char(l_initial_position));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Auxiliary Variables: l_previous_invoice_id = '||to_char(l_previous_invoice_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Auxiliary Variables: l_previous_inv_pay_id = '||to_char(l_previous_inv_pay_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

    LOOP
        IF (P_Calling_Module = 'QUICKCHECK') THEN
            FETCH c_invoice_amounts INTO l_invoice_id,
                                         l_dist_line_no,
                                         l_amount,
                                         l_tax_inclusive_amount,
                                         l_payment_amount,
                                         l_invo_payment_id;
            l_not_found := c_invoice_amounts%NOTFOUND;

        ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
            FETCH c_batch_invoice_amounts INTO l_invoice_id,
                                               l_dist_line_no,
                                               l_amount,
                                               l_tax_inclusive_amount,
                                               l_payment_amount,
                                               l_invo_payment_num;
            l_not_found := c_batch_invoice_amounts%NOTFOUND;

        END IF;
        EXIT WHEN l_not_found;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' STARTING THE LOOP');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Fetched Values:  Invoice_ID = '||to_char(l_invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Fetched Values:  l_dist_line_no = '||to_char(l_dist_line_no));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Fetched Values:  l_amount = '||to_char(l_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Fetched Values:  l_tax_inclusive_amount = '||l_tax_inclusive_amount);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Fetched Values:  l_payment_amount = '||to_char(l_payment_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Fetched Values:  l_invo_payment_id = '||to_char(l_invo_payment_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Fetched Values:  l_invo_payment_num = '||to_char(l_invo_payment_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Auxiliary Variables: l_invoice_amount = '||to_char(l_invoice_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Auxiliary Variables: l_position = '||to_char(l_position));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Auxiliary Variables: l_initial_position = '||to_char(l_initial_position));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Auxiliary Variables: l_previous_invoice_id = '||to_char(l_previous_invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Auxiliary Variables: l_previous_inv_pay_id = '||to_char(l_previous_inv_pay_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Auxiliary Variables: l_previous_inv_pay_num = '||to_char(l_previous_inv_pay_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
        END IF;
        -- End Debug

        ---------------------------------
        -- Sets the total invoice amount
        -- Bug# 1743594
        ---------------------------------
       IF (P_Calling_Module = 'QUICKCHECK') THEN
         IF ((l_previous_invoice_id IS NOT NULL AND
              l_previous_invoice_id <> l_invoice_id)
            OR (l_previous_invoice_id IS NOT NULL AND
                l_previous_invoice_id = l_invoice_id  AND
                l_invo_payment_id <> l_previous_inv_pay_id))
         THEN

            FOR i IN l_initial_position .. (l_position - 1) LOOP
                P_Tab_Inv_Amounts(i).invoice_amount := l_invoice_amount;
            END LOOP;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug(' QUICKCHECK and l_previous_invoice_id <> l_invoice_id');
            END IF;
            -- End Debug

            l_invoice_amount := 0;
            l_initial_position := l_position;
         END IF;
       ELSIF (P_Calling_Module = 'AUTOSELECT') THEN

              IF ((l_previous_invoice_id IS NOT NULL AND
                  l_previous_invoice_id <> l_invoice_id)
                OR (l_previous_invoice_id IS NOT NULL AND
                    l_previous_invoice_id = l_invoice_id  AND
                    l_invo_payment_num <> l_previous_inv_pay_num))

              THEN

                  FOR i IN l_initial_position .. (l_position - 1) LOOP
                      P_Tab_Inv_Amounts(i).invoice_amount := l_invoice_amount;
                  END LOOP;

                  -- Debug Information
                  IF (DEBUG_Var = 'Y') THEN
                     JL_ZZ_AP_EXT_AWT_UTIL.Debug(' AUTOSELECT and l_previous_invoice_id <> l_invoice_id');
                  END IF;
                  -- End Debug


                  l_invoice_amount := 0;
                  l_initial_position := l_position;
              END IF;
       END IF;

        ---------------------------------------------------
        -- Stores the invoice amount into the PL/SQL table
        ---------------------------------------------------
        rec_inv_amount.invoice_id               := l_invoice_id;
        rec_inv_amount.invoice_distribution_id  := l_dist_line_no; -- Lines
        rec_inv_amount.invoice_amount           := null;
        rec_inv_amount.amount                   := l_amount;
        rec_inv_amount.tax_inclusive_amount     := l_tax_inclusive_amount;
        rec_inv_amount.payment_amount           := l_payment_amount;
        rec_inv_amount.taxable_base_amount      := 0;
        rec_inv_amount.prorated_tax_incl_amt    := 0;
        rec_inv_amount.invoice_payment_id       := l_invo_payment_id;
        rec_inv_amount.invoice_payment_num      := l_invo_payment_num;
        P_Tab_Inv_Amounts(l_position)           := rec_inv_amount;
        l_position := l_position + 1;

        l_invoice_amount := l_invoice_amount + l_amount;
        l_previous_invoice_id := l_invoice_id;
        l_previous_inv_pay_id := l_invo_payment_id;
        l_previous_inv_pay_num := l_invo_payment_num;

    END LOOP;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('After lOOP');
    END IF;
    -- End Debug

    ---------------------------------
    -- Sets the total invoice amount
    ---------------------------------
    FOR i IN l_initial_position .. P_Tab_Inv_Amounts.COUNT LOOP
        P_Tab_Inv_Amounts(i).invoice_amount := l_invoice_amount;
    END LOOP;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug(' Sets the total invoice amount');
       JL_ZZ_AP_EXT_AWT_UTIL.Print_tab_amounts(P_Tab_Inv_Amounts);
    END IF;
    -- End Debug

    ----------------
    -- Close cursor
    ----------------
    IF (P_Calling_Module = 'QUICKCHECK') THEN

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug('Close Cursor c_invoice_amounts');
        END IF;
        -- End Debug
        CLOSE c_invoice_amounts;

    ELSIF (P_Calling_Module = 'AUTOSELECT') THEN

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug('Close Cursor c_invoice_amounts');
        END IF;
        -- End Debug
        CLOSE c_batch_invoice_amounts;

    END IF;

    ------------------------------------------------------
    -- Checks whether there are elements within the table
    ------------------------------------------------------
    IF (P_Tab_Inv_Amounts.COUNT <= 0) THEN
        -- Nothing to do
        RETURN;
    END IF;

    -----------------------------------
    -- Initializes auxiliary variables
    -----------------------------------
    l_cumulative_amount := 0;
    l_previous_invoice_id := P_Tab_Inv_Amounts(1).invoice_id;

    ---------------------------------------------------------------
    -- Calculates taxable base amounts by prorating payment amount
    -- for each different invoice
    ---------------------------------------------------------------
    FOR i IN 1 .. P_Tab_Inv_Amounts.COUNT LOOP
/* Bug 2065366
        IF (l_previous_invoice_id <> P_Tab_Inv_Amounts(i).invoice_id) THEN
            P_Tab_Inv_Amounts(i-1).taxable_base_amount :=
                                 P_Tab_Inv_Amounts(i-1).payment_amount -
                                 l_cumulative_amount;
            l_cumulative_amount := 0;
            l_previous_invoice_id := P_Tab_Inv_Amounts(i).invoice_id;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug('  TBA = tax base amts - l_cumulative_amount');
               JL_ZZ_AP_EXT_AWT_UTIL.Debug('  Invoice_id = '||to_char(P_Tab_Inv_Amounts(i-1).invoice_id)||' '||
                                             'Taxable Base Amount = '||to_char(P_Tab_Inv_Amounts(i-1).taxable_base_amount));
            END IF;
            -- End Debug

        END IF;
*/

        ----------------------------------
        -- Calculates taxable base amount
        ----------------------------------
        -- Bug 2477413
        -- Added the following IF condition to avoid
        -- division by zero, this happens incase of prepayments
        -- applied/unapplied to a invoice and is selected in Payment Batch.

        IF  P_Tab_Inv_Amounts(i).invoice_amount <> 0 THEN
                P_Tab_Inv_Amounts(i).taxable_base_amount :=
                    P_Tab_Inv_Amounts(i).amount *
                    P_Tab_Inv_Amounts(i).payment_amount /
                    P_Tab_Inv_Amounts(i).invoice_amount;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug(' Calculates tax base amts prorating payment amt for each different inv');
               JL_ZZ_AP_EXT_AWT_UTIL.Debug(' Invoice_id = '||to_char(P_Tab_Inv_Amounts(i).invoice_id)||' '||
                                             'Taxable Base Amount = '||to_char(P_Tab_Inv_Amounts(i).taxable_base_amount));
            END IF;
            -- End Debug

        ELSE
                P_Tab_Inv_Amounts(i).taxable_base_amount := 0 ;
        END IF;

        P_Tab_Inv_Amounts(i).taxable_base_amount :=
                    Ap_Utilities_Pkg.Ap_Round_Currency (
                            P_Tab_Inv_Amounts(i).taxable_base_amount,
                            P_Currency_Code);


        --------------------------------------------
        -- Calculates prorated tax inclusive amount
        --------------------------------------------
        -- Bug 2477413
        -- Added the following IF condition to avoid
        -- division by zero, this happens incase of prepayments
        -- applied/unapplied to a invoice and is selected in Payment Batch.

        IF  P_Tab_Inv_Amounts(i).invoice_amount <> 0 THEN
                P_Tab_Inv_Amounts(i).prorated_tax_incl_amt :=
                    P_Tab_Inv_Amounts(i).tax_inclusive_amount *
                    P_Tab_Inv_Amounts(i).payment_amount /
                    P_Tab_Inv_Amounts(i).invoice_amount;
        ELSE
                 P_Tab_Inv_Amounts(i).prorated_tax_incl_amt := 0;
        END IF;

        P_Tab_Inv_Amounts(i).prorated_tax_incl_amt :=
                    Ap_Utilities_Pkg.Ap_Round_Currency (
                            P_Tab_Inv_Amounts(i).prorated_tax_incl_amt,
                            P_Currency_Code);

         -- Debug Information
         IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug(' Calculates prorated tax inclusive amount');
         END IF;
         -- End Debug

        IF (i > 1) THEN
            IF (P_Tab_Inv_Amounts(i-1).invoice_id =
                P_Tab_Inv_Amounts(i).invoice_id) THEN
                l_cumulative_amount := l_cumulative_amount +
                               P_Tab_Inv_Amounts(i-1).taxable_base_amount;

                -- Debug Information
                IF (DEBUG_Var = 'Y') THEN
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug(' Cumulative Amount = '||to_char(l_cumulative_amount));
                END IF;
                -- End Debug

            END IF;
        END IF;

    END LOOP;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug(' END Loop thru Tax Invoice Amounts');
       JL_ZZ_AP_EXT_AWT_UTIL.Print_tab_amounts(P_Tab_Inv_Amounts);
    END IF;
    -- End Debug

/*
    --  Bug#  1743594
    IF (P_Calling_Module = 'AUTOSELECT') THEN
       -------------------------
       -- Processes last amount
       -------------------------
       P_Tab_Inv_Amounts(P_Tab_Inv_Amounts.COUNT).taxable_base_amount :=
                     P_Tab_Inv_Amounts(P_Tab_Inv_Amounts.COUNT).payment_amount -
                     l_cumulative_amount;

         -- Debug Information
         IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug(' Last Row for AUTOSELECT - Payment Amount');
         END IF;
         -- End Debug

    END IF;
*/

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('Procedure Calculate_Taxable_Base_Amounts(-)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug


EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                 '  Check Id= '          || to_char(P_Check_Id)          ||
                 ', Selected Check Id= ' || to_char(P_Selected_Check_Id) ||
                 ', Currency Code= '     || P_Currency_Code              ||
                 ', Calling Module= '    || P_Calling_Module);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Calculate_Taxable_Base_Amounts;


/**************************************************************************
 *                                                                        *
 * Name       : Get_Taxable_Base_Amount                                   *
 * Purpose    : Obtains the taxable base amount for a particular invoice  *
 *              distribution line.                                        *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Taxable_Base_Amount
                     (P_Invoice_Id               IN    Number,
                      P_Distribution_Line_No     IN    Number,
                      P_Invoice_Payment_ID       IN    Number,
                      P_Invoice_Payment_Num      IN    Number,
                      P_Tax_Base_Amount_Basis    IN    Varchar2,
                      P_Tax_Inclusive_Flag       IN    Varchar2,
                      P_Tab_Inv_Amounts          IN    Tab_Amounts,
                      P_Calling_Module           IN     Varchar2,
                      P_Calling_Sequence         IN    Varchar2)
                      RETURN NUMBER
IS

    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Taxable_Base_Amount<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('FUNCTION Get_Taxable_Base_Amount');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Invoice_Id= '||to_char(P_Invoice_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Distribution_Line_No= '||to_char(P_Distribution_Line_No));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Invoice_Payment_ID= '||to_char(P_Invoice_Payment_ID));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Tax_Base_Amount_Basis= '||P_Tax_Base_Amount_Basis);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Tax_Inclusive_Flag= '||P_Tax_Inclusive_Flag);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameters: P_Calling_Module= '||P_Calling_Module);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

    -----------------------------------
    -- Obtains the taxable base amount
    -----------------------------------
    FOR i IN 1 .. P_Tab_Inv_Amounts.COUNT LOOP

      IF (P_Calling_Module = 'QUICKCHECK') THEN
        EXIT WHEN (P_Tab_Inv_Amounts(i).invoice_id > P_Invoice_Id);
       /* Comment the next 4 following lines bug# 1743594
                 OR
                  (P_Tab_Inv_Amounts(i).invoice_id = P_Invoice_Id  AND
                   P_Tab_Inv_Amounts(i).invoice_distribution_id  >
                                        P_Distribution_Line_No);
      */

        -- Bug# 1743594. Add last condition.
        IF (P_Tab_Inv_Amounts(i).invoice_id = P_Invoice_Id AND
            P_Tab_Inv_Amounts(i).invoice_distribution_id  =
                                 P_Distribution_Line_No    AND -- Lines
            P_Tab_Inv_Amounts(i).invoice_payment_id = P_Invoice_Payment_ID) THEN

            ---------------------------------------------------
            -- Returns taxable base amount for 'Invoice Based'
            -- withholding taxes
            ---------------------------------------------------
            IF (P_Tax_Base_Amount_Basis = 'INVOICE') THEN
                IF (nvl(P_Tax_Inclusive_Flag, 'N') = 'Y') THEN

                    -- Debug Information
                    IF (DEBUG_Var = 'Y') THEN
                       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('FUNCTION Get_Taxable_Base_Amount for invoice '||
                                                    to_char(P_Tab_Inv_Amounts(i).invoice_id));
                    END IF;
                    -- End Debug

                    RETURN P_Tab_Inv_Amounts(i).amount;
                ELSE
                    RETURN P_Tab_Inv_Amounts(i).amount -
                           P_Tab_Inv_Amounts(i).tax_inclusive_amount;
                END IF;

            ---------------------------------------------------
            -- Returns taxable base amount for 'Payment Based'
            -- withholding taxes
            ---------------------------------------------------
            ELSIF (P_Tax_Base_Amount_Basis = 'PAYMENT') THEN
                IF (nvl(P_Tax_Inclusive_Flag, 'N') = 'Y') THEN
                    RETURN P_Tab_Inv_Amounts(i).taxable_base_amount;
                ELSE
                    RETURN P_Tab_Inv_Amounts(i).taxable_base_amount -
                           P_Tab_Inv_Amounts(i).prorated_tax_incl_amt;
                END IF;

            END IF;

        END IF;
     -- Bug# 1743594
      ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
        EXIT WHEN (P_Tab_Inv_Amounts(i).invoice_id > P_Invoice_Id);
-- Bug 2065366 Comment next lines
--             OR ((P_Tab_Inv_Amounts(i).invoice_id = P_Invoice_Id)  AND
--                   (P_Tab_Inv_Amounts(i).invoice_distribution_id  >
--                                        P_Distribution_Line_No));

          IF (P_Tab_Inv_Amounts(i).invoice_id = P_Invoice_Id AND
              P_Tab_Inv_Amounts(i).invoice_distribution_id  = P_Distribution_Line_No AND -- Lines
              P_Tab_Inv_Amounts(i).invoice_payment_num = P_Invoice_Payment_Num)
          THEN

              ---------------------------------------------------
              -- Returns taxable base amount for 'Invoice Based'
              -- withholding taxes
              ---------------------------------------------------
              IF (P_Tax_Base_Amount_Basis = 'INVOICE') THEN
                  IF (nvl(P_Tax_Inclusive_Flag, 'N') = 'Y') THEN
                      RETURN P_Tab_Inv_Amounts(i).amount;
                  ELSE
                      RETURN P_Tab_Inv_Amounts(i).amount -
                             P_Tab_Inv_Amounts(i).tax_inclusive_amount;
                  END IF;

              ---------------------------------------------------
              -- Returns taxable base amount for 'Payment Based'
              -- withholding taxes
              ---------------------------------------------------
              ELSIF (P_Tax_Base_Amount_Basis = 'PAYMENT') THEN
                  IF (nvl(P_Tax_Inclusive_Flag, 'N') = 'Y') THEN
                      RETURN P_Tab_Inv_Amounts(i).taxable_base_amount;
                  ELSE
                    RETURN P_Tab_Inv_Amounts(i).taxable_base_amount -
                           P_Tab_Inv_Amounts(i).prorated_tax_incl_amt;
                  END IF;

              END IF;

        END IF;

      END IF;
    END LOOP;

	-- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('FUNCTION Get_Taxable_Base_Amount(-)');
    END IF;
    -- End Debug


    RETURN 0;



EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
             '  Invoice Id= '            || to_char(P_Invoice_Id)           ||
             ', Distribution Line No= '  || to_char(P_Distribution_Line_No) ||
             ', Tax Base Amount Basis= ' || P_Tax_Base_Amount_Basis         ||
             ', Tax Inclusive Flag= '    || P_Tax_Inclusive_Flag);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Taxable_Base_Amount;




/**************************************************************************
 *                                                                        *
 * Name       : Get_Credit_Letter_Amount                                  *
 * Purpose    : Obtains the credit letter amount for a particular         *
 *              supplier and withholding tax type                         *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Credit_Letter_Amount
                (P_Vendor_Id          IN     Number,
                 P_AWT_Type_Code      IN     Varchar2,
                 P_Calling_Sequence   IN     Varchar2)
                 RETURN NUMBER
IS

    l_seq_num                 Number;
    l_credit_letter_amount    Number;
    l_debug_info              Varchar2(300);
    l_calling_sequence        Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Credit_Letter_Amount<--' || P_Calling_Sequence;

        -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('FUNCTION Get_Credit_Letter_Amount(+)');
    END IF;
    -- End Debug



	------------------------------------------------------
    -- Obtains the credit letter amount for the supplier
    -- and the withholding tax type
    ------------------------------------------------------

    SELECT max(seq_num)
    INTO   l_seq_num
    FROM   jl_ar_ap_sup_awt_cr_lts
    WHERE  po_vendor_id = P_Vendor_Id
    AND    awt_type_code = P_AWT_Type_Code;

    IF (l_seq_num IS NULL) THEN
        RETURN 0;
    END IF;

    SELECT balance
    INTO   l_credit_letter_amount
    FROM   jl_ar_ap_sup_awt_cr_lts
    WHERE  po_vendor_id = P_Vendor_Id
    AND    awt_type_code = P_AWT_Type_Code
    AND    seq_num = l_seq_num;

	-- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Return '||l_credit_letter_amount);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('FUNCTION Get_Credit_Letter_Amount(-)');
    END IF;
    -- End Debug

    RETURN l_credit_letter_amount;

EXCEPTION
    WHEN no_data_found THEN
        RETURN 0;

    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                '  Vendor Id= '     || to_char(P_Vendor_Id) ||
                ', AWT Type Code= ' || P_AWT_Type_Code);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Credit_Letter_Amount;




/**************************************************************************
 *                                                                        *
 * Name       : Update_Credit_Letter                                      *
 * Purpose    : Updates the withheld amount for each tax name contained   *
 *              into the PL/SQL table. The credit letters table is also   *
 *              updated                                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Update_Credit_Letter
      (P_Vendor_Id              IN     Number,
       P_Rec_AWT_Type           IN     jl_zz_ap_awt_types%ROWTYPE,
       P_AWT_Date               IN     Date,
       P_Payment_Num            IN     Number,
       P_Check_Id               IN     Number,
       P_Selected_Check_Id      IN     Number,
       P_Calling_Sequence       IN     Varchar2,
       P_Tab_Withhold           IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
       P_Last_Updated_By        IN     Number     Default null,
       P_Last_Update_Login      IN     Number     Default null,
       P_Program_Application_Id IN     Number     Default null,
       P_Program_Id             IN     Number     Default null,
       P_Request_Id             IN     Number     Default null)
IS

    l_credit_letter_amount     Number;
    l_tax_id                   Number;
    l_initial_tax              Number;
    l_withheld_amount          Number := 0;
    l_orig_withheld_amount     Number := 0;
    l_actual_withheld_amount   Number := 0;
    l_debug_info               Varchar2(300);
    l_calling_sequence         Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Update_Credit_Letter<--' || P_Calling_Sequence;

    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('FUNCTION Update_Credit_Letter(+)');
    END IF;
    -- End Debug

    --------------------------------------------
    -- Checks whether there is at least one tax
    --------------------------------------------
    IF (P_Tab_Withhold.COUNT <= 0) THEN
        -- Nothing to do
        RETURN;
    END IF;

    -----------------------------------------------------------
    -- Checks whether the current withholding tax type accepts
    -- credit letters
    -----------------------------------------------------------
    IF (nvl(P_Rec_AWT_Type.credit_letter_flag, 'N') <> 'Y') THEN
        -- Nothing to do
        RETURN;
    END IF;

    -----------------------------------------------------------
    -- Checks whether the supplier has a credit letter for the
    -- current withholding tax type
    -----------------------------------------------------------
    l_credit_letter_amount := Get_Credit_Letter_Amount (P_Vendor_Id,
                                        P_Rec_AWT_Type.awt_type_code,
                                        l_calling_sequence);

    IF (l_credit_letter_amount IS NULL OR
        l_credit_letter_amount <= 0) THEN
        -- Nothing to do
        RETURN;
    END IF;

   -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Withholding Type Code = '||P_Rec_AWT_Type.awt_type_code);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Credit Letter Amount = '||to_char(l_credit_letter_amount));
    END IF;
    -- End Debug


    -----------------------------------
    -- Initializes auxiliary variables
    -----------------------------------
    l_tax_id := P_Tab_Withhold(1).tax_id;
    l_withheld_amount := P_Tab_Withhold(1).withheld_amount;
    l_orig_withheld_amount := l_withheld_amount;
    l_initial_tax := 1;

    -------------------------
    -- Applies credit letter
    -------------------------
    FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP
        EXIT WHEN l_credit_letter_amount <= 0;

        IF (P_Tab_Withhold(i).tax_id <> l_tax_id) THEN

            --------------------------------
            -- Updates credit letter amount
            --------------------------------
            IF (l_withheld_amount >= l_credit_letter_amount) THEN
                l_actual_withheld_amount := l_withheld_amount -
                                            l_credit_letter_amount;
                l_credit_letter_amount   := 0;
            ELSE
                l_credit_letter_amount   := l_credit_letter_amount -
                                            l_withheld_amount;
                l_actual_withheld_amount := 0;
            END IF;

            ---------------------------
            -- Updates withheld amount
            ---------------------------
            FOR j IN l_initial_tax  .. (i - 1) LOOP
                 P_Tab_Withhold(j).withheld_amount := l_actual_withheld_amount;
            END LOOP;

            -------------------------------
            -- Updates credit letter table
            -------------------------------
            Insert_Credit_Letter_Amount (P_Vendor_Id,
                                         P_Rec_AWT_Type.awt_type_code,
                                         l_tax_id,
                                         P_AWT_Date,
                                         l_orig_withheld_amount,
                                         l_actual_withheld_amount,
                                         l_credit_letter_amount,
                                         'AA',
                                         P_Payment_Num,
                                         P_Check_Id,
                                         P_Selected_Check_Id,
                                         l_calling_sequence,
                                         P_Last_Updated_By,
                                         P_Last_Update_Login,
                                         P_Program_Application_Id,
                                         P_Program_Id,
                                         P_Request_Id);

            --------------------------------------
            -- Reinitializes auxiliary variables
            --------------------------------------
            l_withheld_amount := P_Tab_Withhold(i).withheld_amount;
            l_orig_withheld_amount := l_withheld_amount;
            l_initial_tax := i;

        END IF;
        l_tax_id := P_Tab_Withhold(i).tax_id;
    END LOOP;


    IF (l_credit_letter_amount > 0) THEN

        --------------------------------
        -- Updates credit letter amount
        --------------------------------
        IF (l_withheld_amount >= l_credit_letter_amount) THEN
            l_actual_withheld_amount := l_withheld_amount -
                                        l_credit_letter_amount;
            l_credit_letter_amount   := 0;
        ELSE
            l_credit_letter_amount   := l_credit_letter_amount -
                                        l_withheld_amount;
            l_actual_withheld_amount := 0;
        END IF;

        ---------------------------
        -- Updates withheld amount
        ---------------------------
        FOR j IN l_initial_tax  .. P_Tab_Withhold.COUNT LOOP
             P_Tab_Withhold(j).withheld_amount := l_actual_withheld_amount;
        END LOOP;

        -------------------------------
        -- Updates credit letter table
        -------------------------------
        Insert_Credit_Letter_Amount (P_Vendor_Id,
                                     P_Rec_AWT_Type.awt_type_code,
                                     l_tax_id,
                                     P_AWT_Date,
                                     l_orig_withheld_amount,
                                     l_actual_withheld_amount,
                                     l_credit_letter_amount,
                                     'AA',
                                     P_Payment_Num,
                                     P_Check_Id,
                                     P_Selected_Check_Id,
                                     l_calling_sequence,
                                     P_Last_Updated_By,
                                     P_Last_Update_Login,
                                     P_Program_Application_Id,
                                     P_Program_Id,
                                     P_Request_Id);
    END IF;

    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('FUNCTION Update_Credit_Letter(-)');
    END IF;


EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                '  Vendor_Id= '          || to_char(P_Vendor_Id)   ||
                ', AWT_Date= '           || to_char(P_AWT_Date,'YYYY/MM/DD')    ||
                ', Payment_Num= '        || to_char(P_Payment_Num) ||
                ', Check_Id= '           || to_char(P_Check_Id)    ||
                ', Selected_Check_Id= '  || to_char(P_Selected_Check_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Update_Credit_Letter;




/**************************************************************************
 *                                                                        *
 * Name       : Insert_Credit_Letter_Amount                               *
 * Purpose    : Stores current information about credit letters into the  *
 *              JL_AR_AP_SUP_AWT_CR_LTS table                             *
 *                                                                        *
 **************************************************************************/
PROCEDURE Insert_Credit_Letter_Amount
                (P_Vendor_Id               IN     Number,
                 P_AWT_Type_Code           IN     Varchar2,
                 P_Tax_Id                  IN     Number,
                 P_AWT_Date                IN     Date,
                 P_Withheld_Amount         IN     Number,
                 P_Actual_Withheld_Amount  IN     Number,
                 P_Balance                 IN     Number,
                 P_Status                  IN     Varchar2,
                 P_Payment_Num             IN     Number,
                 P_Check_Id                IN     Number,
                 P_Selected_Check_Id       IN     Number,
                 P_Calling_Sequence        IN     Varchar2,
                 P_Last_Updated_By         IN     Number     Default null,
                 P_Last_Update_Login       IN     Number     Default null,
                 P_Program_Application_Id  IN     Number     Default null,
                 P_Program_Id              IN     Number     Default null,
                 P_Request_Id              IN     Number     Default null)
IS

    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Insert_Credit_Letter_Amount<--' ||
                           P_Calling_Sequence;

    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Insert_Credit_Letter_Amount(+)');
    END IF;

    -----------------------------------------------
    -- Inserts record into JL_AR_AP_SUP_AWT_CR_LTS
    -----------------------------------------------
    INSERT INTO jl_ar_ap_sup_awt_cr_lts
        (seq_num,
         po_vendor_id,
         awt_type_code,
         tax_id,
         trx_date,
         calc_wh_amnt,
         act_wheld_amnt,
         balance,
         check_id,
         selected_check_id,
         pay_number,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         program_application_id,
         program_id,
         request_id,
         status)
    VALUES
        (jl_ar_ap_sup_awt_cr_lts_s.nextval,
         P_Vendor_Id,
         P_AWT_Type_Code,
         P_Tax_Id,
         P_AWT_Date,
         P_Withheld_Amount,
         P_Actual_Withheld_Amount,
         P_Balance,
         P_Check_Id,
         P_Selected_Check_Id,
         P_Payment_Num,
         fnd_global.user_id,
         sysdate,
         P_Last_Updated_By,
         sysdate,
         P_Last_Update_Login,
         P_Program_Application_Id,
         P_Program_Id,
         P_Request_Id,
         P_Status);

    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Insert_Credit_Letter_Amount(-)');
    END IF;


EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
             '  Vendor Id= '              || to_char(P_Vendor_Id)              ||
             ', AWT Type Code= '          || P_AWT_Type_Code                   ||
             ', Tax Id= '                 || to_char(P_Tax_Id)                 ||
             ', AWT Date= '               || to_char(P_AWT_Date,'YYYY/MM/DD')               ||
             ', Withheld Amount= '        || to_char(P_Withheld_Amount)        ||
             ', Actual Withheld Amount= ' || to_char(P_Actual_Withheld_Amount) ||
             ', Balance= '                || to_char(P_Balance)                ||
             ', Status= '                 || P_Status                          ||
             ', Payment Num= '            || to_char(P_Payment_Num)            ||
             ', Check Id= '               || to_char(P_Check_Id)               ||
             ', Selected Check Id= '      || to_char(P_Selected_Check_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Insert_Credit_Letter_Amount;



/**************************************************************************
 *                                                                        *
 * Name       : Undo_Credit_Letter                                        *
 * Purpose    : Reverse all the credit letter amounts for a particular    *
 *              payment. One record will be created for each different    *
 *              supplier and witholding tax type.                         *
 *                                                                        *
 **************************************************************************/
PROCEDURE Undo_Credit_Letter
                (P_Check_Id                IN     Number,
                 P_Selected_Check_Id       IN     Number,
                 P_AWT_Date                IN     Date,
                 P_Payment_Num             IN     Number,
                 P_Calling_Sequence        IN     Varchar2,
                 P_Last_Updated_By         IN     Number     Default null,
                 P_Last_Update_Login       IN     Number     Default null,
                 P_Program_Application_Id  IN     Number     Default null,
                 P_Program_Id              IN     Number     Default null,
                 P_Request_Id              IN     Number     Default null)

IS
    ---------------------
    -- Types definition
    ---------------------
    TYPE Rec_Credit_Letter IS RECORD
    (
        vendor_id            Number,
        awt_type_code        Varchar2(30),
        amount_to_reverse    Number
    );

    TYPE Tab_Credit_Letter IS TABLE OF Rec_Credit_Letter
         INDEX BY BINARY_INTEGER;

    ---------------------
    -- Cursor definition
    ---------------------
    CURSOR c_credit_letters (P_Check_Id          IN Number,
                             P_Selected_Check_Id IN Number) IS
    SELECT jlcl.po_vendor_id             vendor_id,
           jlcl.awt_type_code            awt_type_code,
           jlcl.calc_wh_amnt             calc_wh_amnt,
           jlcl.act_wheld_amnt           act_wheld_amnt
    FROM   jl_ar_ap_sup_awt_cr_lts jlcl
    WHERE  jlcl.status = 'AA'
    AND   ((P_Check_Id IS NOT NULL AND
           jlcl.check_id = P_Check_Id) OR
           (P_Selected_Check_Id IS NOT NULL AND
           jlcl.selected_check_id = P_Selected_Check_Id))
    ORDER BY jlcl.po_vendor_id,
             jlcl.awt_type_code,
             jlcl.seq_num
    FOR UPDATE OF jlcl.status;

    ------------------------
    -- Variables definition
    ------------------------
    rec_cr_letter       Rec_Credit_Letter;
    tab_cr_letter       Tab_Credit_Letter;
    rec_credit_letters  c_credit_letters%ROWTYPE;
    l_position          Number := 0;
    l_balance           Number;
    l_debug_info        Varchar2(300);
    l_calling_sequence  Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Undo_Credit_Letter<--' || P_Calling_Sequence;

    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Undo_Credit_Letter(+)');
    END IF;

    ----------------------
    -- Initializes record
    ----------------------
    rec_cr_letter.vendor_id := null;
    rec_cr_letter.awt_type_code := null;
    rec_cr_letter.amount_to_reverse := 0;

    ------------------------------------------
    -- Retrieves all the lines to be reversed
    ------------------------------------------
    OPEN c_credit_letters (P_Check_Id, P_Selected_Check_Id);
    LOOP
        FETCH c_credit_letters INTO rec_credit_letters;
        EXIT WHEN c_credit_letters%NOTFOUND;

        IF ((rec_cr_letter.vendor_id IS NULL AND
             rec_cr_letter.awt_type_code IS NULL) OR
            (rec_cr_letter.vendor_id <> rec_credit_letters.vendor_id OR
             rec_cr_letter.awt_type_code <> rec_credit_letters.awt_type_code))
            THEN
            l_position := l_position + 1;
            rec_cr_letter.vendor_id := rec_credit_letters.vendor_id;
            rec_cr_letter.awt_type_code := rec_credit_letters.awt_type_code;
            rec_cr_letter.amount_to_reverse := 0;
            tab_cr_letter(l_position) := rec_cr_letter;
        END IF;

        ----------------------------------------
        -- Calculates the amount to be reversed
        ----------------------------------------
        tab_cr_letter(l_position).amount_to_reverse :=
                  tab_cr_letter(l_position).amount_to_reverse +
                  nvl(rec_credit_letters.calc_wh_amnt, 0) -
                  nvl(rec_credit_letters.act_wheld_amnt, 0);

        ----------------------------------------------
        -- Changes the status of the reversed records
        ----------------------------------------------
        UPDATE jl_ar_ap_sup_awt_cr_lts
        SET    status = 'AR'
        WHERE  CURRENT OF c_credit_letters;

    END LOOP;
    CLOSE c_credit_letters;


    ---------------------------------------------------------
    -- Inserts the records with the reversion information
    -- (one record for each different vendor and withholding
    -- tax type)
    ---------------------------------------------------------
    FOR i IN 1 .. tab_cr_letter.COUNT LOOP

        --------------------------------------------------------
        -- Obtains current balance for the withholding tax type
        --------------------------------------------------------
        l_balance := Get_Credit_Letter_Amount(tab_cr_letter(i).vendor_id,
                                              tab_cr_letter(i).awt_type_code,
                                              l_calling_sequence);

        -------------------------------------------------------
        -- Calculates new balance for the withholding tax type
        -------------------------------------------------------
        l_balance := nvl(l_balance, 0) +
                     tab_cr_letter(i).amount_to_reverse;

        -----------------------------------
        -- Inserts record with new balance
        -----------------------------------
        Insert_Credit_Letter_Amount(tab_cr_letter(i).vendor_id,
                                    tab_cr_letter(i).awt_type_code,
                                    null,           -- Tax ID
                                    P_AWT_Date,
                                    null,           -- Calc. Withheld Amount
                                    null,           -- Actual Withheld Amount
                                    l_balance,
                                    'AR',           -- Status
                                    P_Payment_Num,
                                    P_Check_Id,
                                    P_Selected_Check_Id,
                                    l_calling_sequence,
                                    P_Last_Updated_By,
                                    P_Last_Update_Login,
                                    P_Program_Application_Id,
                                    P_Program_Id,
                                    P_Request_Id);
    END LOOP;
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Undo_Credit_Letter(-)');
    END IF;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                '  Check Id= '          || to_char(P_Check_Id)          ||
                ', Selected Check Id= ' || to_char(P_Selected_Check_Id) ||
                ', AWT Date= '          || to_char(P_AWT_Date,'YYYY/MM/DD')  ||
                ', Payment Num= '       || to_char(P_Payment_Num));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Undo_Credit_Letter;



/**************************************************************************
 *                                                                        *
 * Name       : Update_Quick_Payment                                      *
 * Purpose    : Updates the payment amount by subtracting the withheld    *
 *              amount.                                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Update_Quick_Payment
                    (P_Check_Id                 IN     Number,
                     P_Calling_Sequence         IN     Varchar2)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_invoice_payment_id    Number;
    l_invoice_id            Number;
    l_pay_exchange_rate     Number;
    l_inv_exchange_rate     Number;
    l_payment_cross_rate    Number;
    l_payment_num           Number;
    l_withhold_amount       Number;
    l_amount                Number;
    l_base_amount           Number;
    l_total_wh_amount       Number := 0;
    l_total_wh_base_amount  Number := 0;
    l_debug_info            Varchar2(300);
    l_calling_sequence      Varchar2(2000);
    l_pay_amount            Number;
    l_payment_base_amount   Number;
    l_invoice_base_amount   Number;
    -- Bug 2886571
    l_payment_currency_code Varchar2(15);
    -------------------------------------
    -- Cursor to select all the invoices
    -- within the payment
    -------------------------------------
    CURSOR c_invoice_payment (P_Check_Id Number)
    IS
    SELECT apip.invoice_payment_id      invoice_payment_id,
           apip.invoice_id              invoice_id,
           apip.exchange_rate           pay_exchange_rate,
           apip.payment_num             payment_num,
           apip.amount                  amount,
           apip.payment_base_amount     payment_base_amount,
           apip.invoice_base_amount     invoice_base_amount
    FROM   ap_invoice_payments apip
    WHERE  apip.check_id = P_Check_Id
    FOR UPDATE OF apip.amount,
                  apip.payment_base_amount,
                  apip.invoice_base_amount;

    --------------------------------
    -- Cursor to select the payment
    --------------------------------
    CURSOR c_checks (P_Check_Id Number)
    IS
    SELECT apch.amount        amount,
           apch.base_amount   base_amount,
           apch.currency_code currency_code    -- Bug 2886571
    FROM   ap_checks          apch
    WHERE  apch.check_id = P_Check_Id
    FOR UPDATE OF apch.amount,
                  apch.base_amount;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Update_Quick_Payment<--' || P_Calling_Sequence;


    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Update_Quick_Payment(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter P_Check_Id: '||to_char(P_Check_Id));
    END IF;
    -- End Debug


    --------------------------------------------
    -- Updates amounts for the invoice payments
    --------------------------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' OPEN c_invoice_payment');
    END IF;
    -- End Debug

    OPEN c_invoice_payment(P_Check_Id);
    LOOP
        FETCH c_invoice_payment INTO l_invoice_payment_id,
                                     l_invoice_id,
                                     l_pay_exchange_rate,
                                     l_payment_num,
                                     l_pay_amount,
                                     l_payment_base_amount,
                                     l_invoice_base_amount;
        EXIT WHEN c_invoice_payment%NOTFOUND;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_invoice_payment_id= '||to_char(l_invoice_payment_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_invoice_id= '||to_char(l_invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_pay_exchange_rate= '||to_char(l_pay_exchange_rate));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_payment_num= '||to_char(l_payment_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_pay_amount= '||to_char(l_pay_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_payment_base_amount= '||to_char(l_payment_base_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_invoice_base_amount= '||to_char(l_invoice_base_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
        END IF;
        -- End Debug

        -------------------------------------------
        -- Obtains withheld amount for the invoice
        -------------------------------------------
        SELECT nvl(sum(apid.amount), 0)
        INTO   l_withhold_amount
        FROM   ap_invoice_distributions apid
        WHERE  apid.invoice_id = l_invoice_id
        AND    apid.awt_invoice_payment_id = l_invoice_payment_id
            -- added recently
        AND    NVL(apid.REVERSAL_FLAG,'N') <> 'Y';

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Obtains withheld amount for the invoice : '||to_char(l_withhold_amount));
        END IF;
        -- End Debug

        IF (l_withhold_amount <> 0) THEN

            --------------------------------
            -- Obtains currency information
            --------------------------------
            SELECT apin.exchange_rate,
                   apps.payment_cross_rate,
                   apin.payment_currency_code
            INTO   l_inv_exchange_rate,
                   l_payment_cross_rate,
                   l_payment_currency_code      -- Bug 2886571
            FROM   ap_invoices          apin,
                   ap_payment_schedules apps
            WHERE  apin.invoice_id    = l_invoice_id
            AND    apps.invoice_id    = l_invoice_id
            AND    apps.payment_num   = l_payment_num;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Obtains currency information: exch rate, pay cross rate, pay curr code'||
                                             to_char(l_inv_exchange_rate)||', '||to_char(l_payment_cross_rate)||
                                             ','||l_payment_currency_code);
            END IF;
            -- End Debug

            -- Bug 2886571 Rounding the amounts.
            --------------------------------------------------------
            -- Updates the amount remaining of the payment schedule
            --------------------------------------------------------
            UPDATE ap_payment_schedules
            SET    amount_remaining = ap_utilities_pkg.ap_round_currency(
                                        amount_remaining - (l_withhold_amount * nvl(l_payment_cross_rate, 1)),
                                        l_payment_currency_code),
                   payment_status_flag = decode( ap_utilities_pkg.ap_round_currency(amount_remaining -
                                                (l_withhold_amount *
                                                 nvl(l_payment_cross_rate, 1)),l_payment_currency_code),
                                                 0, 'Y',
                                                 amount_remaining,
                                                 payment_status_flag, 'P')
            WHERE  invoice_id  = l_invoice_id
            AND    payment_num = l_payment_num;

            ------------------------------------------
            -- Updates the amount paid of the invoice
            -- amount_paid does not affect MRC
            ------------------------------------------
            UPDATE ap_invoices
            SET    amount_paid         = ap_utilities_pkg.ap_round_currency(
                                          nvl(amount_paid, 0) +
                                         (l_withhold_amount *
                                          nvl(l_payment_cross_rate, 1)),l_payment_currency_code),
                   payment_status_flag = AP_INVOICES_UTILITY_PKG.get_payment_status(l_invoice_id)
            WHERE invoice_id = l_invoice_id;

            --------------------------------------------------------------
            -- Updates the payment amount
            -- Calling the AP Table Handler to update ap_invoice_payments.
            -- Bug 1827398
            --------------------------------------------------------------
            l_pay_amount          :=  ap_utilities_pkg.ap_round_currency(
                                        l_pay_amount + (l_withhold_amount *
                                        nvl(l_payment_cross_rate, 1)), l_payment_currency_code);

            l_invoice_base_amount :=  ap_utilities_pkg.ap_round_currency(
                                        l_invoice_base_amount +
                                        (l_withhold_amount * nvl(l_inv_exchange_rate, 1)), l_payment_currency_code);

            l_payment_base_amount :=  ap_utilities_pkg.ap_round_currency(
                                        l_payment_base_amount +
                                       (l_withhold_amount * nvl(l_payment_cross_rate, 1) *
                                          nvl(l_pay_exchange_rate, 1)),l_payment_currency_code);

            AP_AIP_TABLE_HANDLER_PKG.Update_Amounts(
                                   l_invoice_payment_id
                                  ,l_pay_amount
                                  ,l_invoice_base_amount
                                  ,l_payment_base_amount
                                  ,l_calling_sequence);

            --------------------------------------------
            -- Calculates total amounts for the payment
            --------------------------------------------
            l_total_wh_amount      := l_total_wh_amount +
                                      (l_withhold_amount *
                                       nvl(l_payment_cross_rate, 1));

            l_total_wh_base_amount := l_total_wh_base_amount +
                                      (l_withhold_amount *
                                       nvl(l_payment_cross_rate, 1) *
                                       nvl(l_pay_exchange_rate, 1));
        END IF;

    END LOOP;

    CLOSE c_invoice_payment;

    -------------------------------------------------------------------
    -- Updates the payment amount for the check
    -- Calling the AP Table Handler to update ap_checks.
    -- Bug 1827398
    -------------------------------------------------------------------
    IF (l_total_wh_amount <> 0 OR l_total_wh_base_amount <> 0) THEN
        OPEN c_checks (P_Check_Id);
        FETCH c_checks INTO l_amount, l_base_amount, l_payment_currency_code;
        IF (NOT c_checks%NOTFOUND) THEN

           l_amount      := ap_utilities_pkg.ap_round_currency((l_amount + l_total_wh_amount),l_payment_currency_code);
           l_base_amount := ap_utilities_pkg.ap_round_currency((l_base_amount + l_total_wh_base_amount),
                                                                                l_payment_currency_code);

           AP_AC_TABLE_HANDLER_PKG.Update_Amounts(
                       P_check_id
                      ,l_amount
                      ,l_base_amount
                      ,l_calling_sequence);
        END IF;
        CLOSE c_checks;
    END IF;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure Update_Quick_Payment(-)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                    ' Check Id= '  || to_char(P_Check_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Update_Quick_Payment;


/**************************************************************************
 *                                                                        *
 * Name       : Update_Payment_Batch                                      *
 * Purpose    : Updates the amounts of the payment batch by subtracting   *
 *              the withholding amount.                                   *
 *  just update invoices in same payment check                            *
 **************************************************************************/
PROCEDURE Update_Payment_Batch
                (P_Checkrun_Name           IN     Varchar2,
                 P_Checkrun_ID             IN     Number,
                 P_Selected_Check_Id       IN     Number,
                 P_Calling_Sequence        IN     Varchar2)
IS
    ----------------------
    -- Cursor definition
    ----------------------
    CURSOR c_selected_invoices (P_Selected_Check_Id  IN Number) IS

/*  RG  update documents
  SELECT apsi.invoice_id                invoice_id,
           apsi.payment_num                   payment_num,
           apsi.payment_amount                payment_amount,
           nvl(apsi.invoice_exchange_rate, 1) invoice_exchange_rate,
          nvl(apsi.payment_cross_rate, 1)     payment_cross_rate
    FROM   ap_selected_invoices apsi
    WHERE  apsi.pay_selected_check_id = P_Selected_Check_id
    AND    nvl(apsi.ok_to_pay_flag, 'Y') = 'Y'
    AND    apsi.original_invoice_id IS NULL
    FOR UPDATE;
*/
   SELECT docs.CALLING_APP_DOC_UNIQUE_REF2 invoice_id,
      docs.document_payable_id document_payable_id,
      docs.CALLING_APP_DOC_UNIQUE_REF3 payment_num,
      docs.document_amount payment_amount ,
      -- Payment Exchange Rate ER 8648739 Start 9
      -- nvl(apsi.invoice_exchange_rate, 1) invoice_exchange_rate,
      nvl(apsi.payment_exchange_rate, 1) payment_exchange_rate,
      -- Payment Exchange Rate ER 8648739  End 9
      nvl(apsi.payment_cross_rate, 1)    payment_cross_rate
   FROM iby_hook_docs_in_pmt_t docs,
        ap_selected_invoices apsi
   WHERE docs.payment_id = P_Selected_Check_id
   AND   docs.calling_app_id = 200
   AND   apsi.invoice_id = docs.calling_app_doc_unique_ref2
   AND   nvl(docs.dont_pay_flag,'N')='N';


/*  RG
    CURSOR c_selected_invoice_checks (P_Selected_Check_Id  IN Number) IS
    SELECT apsic.check_amount     check_amount,
           apsic.vendor_amount    vendor_amount
    FROM   ap_selected_invoice_checks  apsic
    WHERE  apsic.selected_check_id = P_Selected_Check_Id
    FOR UPDATE OF apsic.check_amount,
                  apsic.vendor_amount;
*/
   -- Update Payments
  CURSOR c_selected_invoice_checks (P_Selected_Check_Id  IN Number) IS
  SELECT ipmt.payment_amount payment_amount
  FROM iby_hook_payments_t ipmt
  WHERE ipmt.payment_id = P_Selected_Check_id
  AND   ipmt.calling_app_id = 200
  FOR UPDATE OF ipmt.payment_amount;


    ------------------------
    -- Variables definition
    ------------------------
    rec_sel_inv              c_selected_invoices%ROWTYPE;
    l_withholding_amount     Number;
    l_check_amount           Number;
    l_vendor_amount          Number;
    l_total_wh_amount        Number := 0;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);
    l_count_inv              Number;

    -- Bug 2176607
    l_payment_currency_code  Varchar2(15);

    l_prop_payment_amount    Number := 0;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Update_Payment_Batch<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Update_Payment_Batch(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter P_Checkrun_Name: '||P_Checkrun_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter P_Selected_Check_Id: '||to_char(P_Selected_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug


    -----------------------------------------------------------------------------
    -- Bug Number: 1480825 -- Just update the invoices in the same payment check.
    -----------------------------------------------------------------------------
     SELECT count(*)
     INTO   l_count_inv
     FROM   iby_hook_docs_in_pmt_t docs,
-- RG ap_selected_invoices apsi,
            ap_awt_temp_distributions awtd
     WHERE  docs.payment_id = P_Selected_Check_Id
      AND  nvl(docs.dont_pay_flag,'N') ='N'
      AND   docs.calling_app_doc_unique_ref2  = awtd.invoice_id
      AND   docs.calling_app_id=200 ;

-- apsi.pay_selected_check_id = P_Selected_Check_Id
--     AND    nvl(apsi.ok_to_pay_flag, 'Y') = 'Y'
--     AND    apsi.original_invoice_id IS NULL


     -- Debug Information
     IF (DEBUG_Var = 'Y') THEN
        JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Just update the invoices in the same payment check: '||to_char(l_count_inv));
     END IF;
     -- End Debug

     IF  (l_count_inv = 0 ) Then
         return;
     END IF;

     -- Bug2175168. Store the the Proposed Payment Amount so that this can be utilized to correct
     -- the check amount. Since the standard AP build only updates the AP_SELECTED_INVOICES while
     -- updating the check amount we need to consider this rather than the existing check amount.
     -- This would however be redundant when we Rebuild the batch.

     SELECT SUM(docs.document_amount)
     INTO   l_prop_payment_amount
     FROM   iby_hook_docs_in_pmt_t docs
-- ap_selected_invoices apsi
     WHERE  docs.payment_id = P_Selected_Check_Id
      AND  nvl(docs.dont_pay_flag,'N') ='N'
      AND docs.calling_app_id =200;

-- apsi.pay_selected_check_id = P_Selected_Check_id
--       AND  nvl(apsi.ok_to_pay_flag, 'Y') = 'Y'
--       AND  apsi.original_invoice_id IS NULL;

     -- Debug Information
     IF (DEBUG_Var = 'Y') THEN
        JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Proposed Payment Amount : '||to_char(l_prop_payment_amount));
     END IF;
     -- End Debug

    --------------------------------------
    -- Updates payment amount information
    --------------------------------------

    -- Debug Information
     IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('OPEN Cursor c_selected_invoices');
     END IF;
    -- End Debug

    OPEN c_selected_invoices (P_Selected_Check_Id);

    LOOP
        FETCH c_selected_invoices INTO rec_sel_inv;
        EXIT WHEN c_selected_invoices%NOTFOUND;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: Invoice_ID= '||to_char(rec_sel_inv.invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: payment_num= '||to_char(rec_sel_inv.payment_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: payment_amount= '||to_char(rec_sel_inv.payment_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: inv exch rate= '||to_char(rec_sel_inv.payment_exchange_rate));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: pay cross rate= '||to_char(rec_sel_inv.payment_cross_rate));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
        END IF;
        -- End Debug

        ------------------------------------
        -- Bug 2176607
        -- Added the following SELECT to get
        -- the currency code for rounding.
        ------------------------------------
 /*  RG
SELECT payment_currency_code
         INTO   l_payment_currency_code
         FROM   ap_invoices_all
         WHERE  invoice_id = rec_sel_inv.invoice_id;
*/

    SELECT document_currency_code
      INTO l_payment_currency_code
      FROM IBY_HOOK_DOCS_IN_PMT_T
     WHERE payment_id = P_Selected_Check_Id
       AND document_payable_id = rec_sel_inv.document_payable_id;
        -----------------------------------------------------
        -- Calculates the withholding amount for the invoice
        -----------------------------------------------------

        SELECT nvl(sum(withholding_amount), 0)
        INTO   l_withholding_amount
        FROM   ap_awt_temp_distributions
        WHERE  checkrun_name = P_Checkrun_Name
        AND    checkrun_id= p_checkrun_id
        AND    invoice_id = rec_sel_inv.invoice_id
        AND    payment_num = rec_sel_inv.payment_num;

        ------------------------------------
        -- Converts to the payment currency
        ------------------------------------
        l_withholding_amount := l_withholding_amount /
       -- Payment Exchange Rate ER 8648739 Start 10
       --                        rec_sel_inv.invoice_exchange_rate *
                                rec_sel_inv.payment_exchange_rate *
       -- Payment Exchange Rate ER 8648739 End 10
                          rec_sel_inv.payment_cross_rate;

       l_withholding_amount := ap_utilities_pkg.ap_round_currency(l_withholding_amount,
                                l_payment_currency_code);



        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Withheld amount for the invoice= '||to_char(l_withholding_amount));
        END IF;
        -- End Debug

        -------------------------------------------------------
        -- Updates proposed payment
        -- Bug 2176607 Rounding the amounts; the withheld amount
        -- will be rounded by AP in create invoice distributions.
        -- using the local variable instead.
        -------------------------------------------------------

 -- RG Update Documents in PMT table
 -- As discussed with Ryan , we will keep updating ap selected invoices

      UPDATE ap_selected_invoices apsi
        SET  apsi.proposed_payment_amount = ap_utilities_pkg.ap_round_currency(
                           apsi.proposed_payment_amount - l_withholding_amount,
                           l_payment_currency_code),
             apsi.payment_amount          = ap_utilities_pkg.ap_round_currency(
                             apsi.payment_amount - l_withholding_amount,
                           l_payment_currency_code),
            -- bug: 9037712 :: Amount_remaining should not be updated.
            -- JL code modified to be in sync with AP side processing for PPRs.
            -- apsi.amount_remaining        = ap_utilities_pkg.ap_round_currency(
            --                   apsi.amount_remaining - l_withholding_amount,
            --                   l_payment_currency_code),
             apsi.withholding_amount      = ap_utilities_pkg.ap_round_currency(
                           l_withholding_amount, l_payment_currency_code)
        WHERE  invoice_id = rec_sel_inv.invoice_id ;
--        WHERE  CURRENT OF c_selected_invoices;


   UPDATE iby_hook_docs_in_pmt_t docs
     SET docs.document_amount = ap_utilities_pkg.ap_round_currency(
                           docs.document_amount - l_withholding_amount,
                           l_payment_currency_code),
         docs.amount_withheld = ap_utilities_pkg.ap_round_currency(
                           l_withholding_amount, l_payment_currency_code)
     WHERE document_payable_id = rec_sel_inv.document_payable_id;

        l_total_wh_amount := l_total_wh_amount +
                             l_withholding_amount;

    END LOOP;

    CLOSE c_selected_invoices;

    -- Bug2175168. Using the Proposed payment amount instead of check amount. Since, the vendor_amount
    -- will always be -1 * total withholding amount ofor the selected check, used this to update the
    -- Vendor_Amount.

    --------------------------------------------
    -- Update the amount for the selected check
    -- Bug 2176607 Rounding the amounts;
    --------------------------------------------
-- RG Not Applicable the vendor amount
-- Update Payments Hook table

    OPEN c_selected_invoice_checks (P_Selected_Check_Id);
    FETCH c_selected_invoice_checks INTO l_check_amount;

    IF (NOT c_selected_invoice_checks%NOTFOUND) THEN

/*  RG
        UPDATE ap_selected_invoice_checks apsic
        SET    apsic.check_amount  = ap_utilities_pkg.ap_round_currency(
                            NVL(l_prop_payment_amount, l_check_amount ) -
                            l_total_wh_amount, apsic.currency_code),
               apsic.vendor_amount = ap_utilities_pkg.ap_round_currency(
                            -1 * l_total_wh_amount, apsic.currency_code)
        WHERE CURRENT OF c_selected_invoice_checks;
 */
    UPDATE iby_hook_payments_t ipmt
    SET ipmt.payment_amount = ap_utilities_pkg.ap_round_currency(
                            NVL(l_prop_payment_amount, l_check_amount ) -
                l_total_wh_amount, ipmt.payment_currency_code)
    WHERE CURRENT OF c_selected_invoice_checks;

  END IF;

    CLOSE c_selected_invoice_checks;

	 -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Update_Payment_Batch(-)');
    END IF;
    -- End Debug


EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                '  Checkrun Name= '      || P_Checkrun_Name ||
                ', Selected Check Id= '  || to_char(P_Selected_Check_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Update_Payment_Batch;




/**************************************************************************
 *                                                                        *
 * Name       : Withholding_Already_Calculated                            *
 * Purpose    : Checks whether the withholding was already calculated for *
 *              a particular invoice. This is only applicable for those   *
 *              'Invoice Based' withholding taxes.                        *
 *                                                                        *
 **************************************************************************/
FUNCTION Withholding_Already_Calculated
                (P_Invoice_Id                IN     Number,
                 P_Tax_Name                  IN     Varchar2,
                 P_Tax_Id                    IN     Number,
                 P_Taxable_Base_Amount_Basis IN     Varchar2,
                 P_Tab_Withhold              IN     Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
                 P_Inv_Payment_Num           IN     Number,
                 P_Calling_Sequence          IN     Varchar2)
                 RETURN Boolean
IS

    l_count               Number;
    l_withheld_amount     Number;
    l_debug_info          Varchar2(300);
    l_calling_sequence    Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Withholding_Already_Calculated<--' ||
                           P_Calling_Sequence;

     -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Function Withholding_Already_Calculated(+)');
    END IF;
    -- End Debug

    --------------------------------------------------------
    -- If the taxable base amount basis for the withholding
    -- is 'Payment', returns FALSE
    --------------------------------------------------------
    IF (nvl(P_Taxable_Base_Amount_Basis, 'PAYMENT') = 'PAYMENT') THEN
        RETURN FALSE;

    ----------------------------------------------------------
    -- If the taxable base amount basis for the withholding
    -- is 'Invoice', we need to check whether the withholding
    -- was calculated previously for the invoice
    ----------------------------------------------------------
    ELSIF (P_Taxable_Base_Amount_Basis = 'INVOICE') THEN

        -------------------------------------------
        -- Checks for PL*SQL Table
        -------------------------------------------
        FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP
           IF (P_Tab_Withhold(i).invoice_id = P_Invoice_Id)  AND
              (P_Tab_Withhold(i).tax_id     = P_Tax_Id)      AND
              (P_Tab_Withhold(i).payment_num <> P_Inv_Payment_Num) THEN

               RETURN TRUE;
           END IF;
        END LOOP;

        -------------------------------------------
        -- Checks for temporary distribution lines
        -------------------------------------------
        SELECT count('Withholding Already Calculated')
        INTO   l_count
        FROM   ap_awt_temp_distributions apatd
        WHERE  apatd.invoice_id = P_Invoice_Id
        AND    apatd.tax_name = P_Tax_Name;

        IF (nvl(l_count, 0) > 0) THEN
            RETURN TRUE;
        END IF;

        --------------------------------------
        -- Checks for real distribution lines
        --------------------------------------
        SELECT nvl(sum(apid.amount), 0)
        INTO   l_withheld_amount
        FROM   ap_invoice_distributions apid
        WHERE  apid.invoice_id = P_Invoice_Id
        AND    apid.line_type_lookup_code = 'AWT'
        AND    apid.withholding_tax_code_id = P_Tax_Id
            -- added recently
        AND    NVL(apid.REVERSAL_FLAG,'N') <> 'Y';

        RETURN (l_withheld_amount <> 0);
    END IF;

	     -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Function Withholding_Already_Calculated(-)');
    END IF;
    -- End Debug


    RETURN FALSE;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
               '  Invoice Id= '                || to_char(P_Invoice_Id) ||
               ', Tax Name= '                  || P_Tax_Name            ||
               ', Taxable Base Amount Basis= ' || P_Taxable_Base_Amount_Basis);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Withholding_Already_Calculated;




/**************************************************************************
 *                                                                        *
 * Name       : Total_Withholding_Amount                                  *
 * Purpose    : Returns the total withheld amount for the withholding tax *
 *              type (sums up all the prorated amounts).                  *
 *                                                                        *
 **************************************************************************/
FUNCTION Total_Withholding_Amount
             (P_Tab_Withhold     IN     Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
              P_Calling_Sequence IN     Varchar2)
              RETURN Number
IS

    l_withholding_amount   Number := 0;
    l_debug_info           Varchar2(300);
    l_calling_sequence     Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Total_Withholding_Amount<--' || P_Calling_Sequence;

         -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Function Total_Withholding_Amount(+)');
    END IF;
    -- End Debug

    -----------------------------------------------------------
    -- Sums up all the prorated amounts included into the table
    -----------------------------------------------------------
    FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP
        l_withholding_amount := l_withholding_amount +
                                nvl(P_Tab_Withhold(i).prorated_amount, 0);
    END LOOP;

	-- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Total Withholding Amount '||l_withholding_amount);
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Function Total_Withholding_Amount(-)');
    END IF;
    -- End Debug

    RETURN l_withholding_amount;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS', null);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Total_Withholding_Amount;




/**************************************************************************
 *                                                                        *
 * Name       : Partial_Payment_Paid_In_Full                              *
 * Purpose    : Checks whether the payment amount is enough to cover the  *
 *              withholding amount.                                       *
 *                                                                        *
 **************************************************************************/
FUNCTION Partial_Payment_Paid_In_Full
                 (P_Check_Id             IN     Number,
                  P_Selected_Check_Id    IN     Number,
                  P_Calling_Module       IN     Varchar2,
                  P_Total_Wh_Amount      IN     Number,
                  P_Calling_Sequence     IN     Varchar2,
                  P_Vendor_Name          OUT NOCOPY    Varchar2,
                  P_Vendor_Site_Code     OUT NOCOPY    Varchar2)
                  --P_Payment_Amount       OUT NOCOPY    Number)  Bug# 2807464
                  RETURN Boolean
IS

    l_payment_amount    Number := 0;
    l_vendor_name       Varchar2(240);
    l_vendor_site_code  Varchar2(15);
    l_debug_info        Varchar2(300);
    l_calling_sequence  Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Partial_Payment_Paid_In_Full<--' ||
                           P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Function Partial_Payment_Paid_In_Full(+)');
    END IF;
    -- End Debug

    --------------------------------------------
    -- Obtains payment amount for Quick Payment
    --------------------------------------------
    IF (P_Calling_Module = 'QUICKCHECK') THEN

        SELECT nvl(apchk.base_amount, apchk.amount),
               apchk.vendor_name,
               apchk.vendor_site_code
        INTO   l_payment_amount,
               l_vendor_name,
               l_vendor_site_code
        FROM   ap_checks apchk
        WHERE  apchk.check_id = P_Check_Id;

    --------------------------------------------
    -- Obtains payment amount for Payment Batch
    --------------------------------------------
    ELSIF (P_Calling_Module = 'AUTOSELECT') THEN
        SELECT nvl(sum(docs.document_amount/
                       nvl(apsi.payment_cross_rate, 1) *
                       nvl(apsi.invoice_exchange_rate, 1)), 0)
        INTO   l_payment_amount
        FROM   iby_hook_docs_in_pmt_t docs,
               ap_selected_invoices apsi
       WHERE  docs.payment_id = P_Selected_Check_id
       AND    apsi.invoice_id = docs.calling_app_doc_unique_ref2
       AND   docs.dont_pay_flag = 'N'
--      AND    apsi.pay_selected_check_id = P_Selected_Check_id
--       AND    apsi.original_invoice_id IS NULL
       AND    docs.calling_app_id=200;

/* RG        SELECT vendor_name,
               vendor_site_code
        INTO   l_vendor_name,
               l_vendor_site_code
        FROM   ap_selected_invoice_checks
        WHERE  selected_check_id = P_Selected_Check_id;


       SELECT asi.vendor_name,
              asi.vendor_site_code
       INTO l_vendor_name,
            l_vendor_site_code
       FROM IBY_HOOK_DOCS_IN_PMT_T docs,
            ap_selected_invoices_all asi
       WHERE docs.payment_id = P_Selected_Check_id
       AND   docs.calling_app_doc_unique_ref2 = asi.invoice_id
       AND   docs.calling_app_id=200;
*/

      select a.vendor_name, b.vendor_site_code
        into l_vendor_name,
             l_vendor_site_code
        from ap_suppliers a, ap_supplier_sites_all b,
             iby_hook_payments_t c
       where c.PAYEE_PARTY_ID = a.party_id
         and c.SUPPLIER_SITE_ID = b.vendor_site_id
         and a.vendor_id = b.vendor_id
         and c.payment_id = P_Selected_Check_id;

    END IF;

    -------------------------
    -- Sets output arguments
    -------------------------
    P_Vendor_Name      := l_vendor_name;
    P_Vendor_Site_Code := l_vendor_site_code;
    --P_Payment_Amount   := l_payment_amount;  Bug# 2807464

	-- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Function Partial_Payment_Paid_In_Full(-)');
    END IF;
    -- End Debug

    RETURN (l_payment_amount >= P_Total_Wh_Amount);

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
               '  Check Id= '          || to_char(P_Check_Id)          ||
               ', Selected Check_Id= ' || to_char(P_Selected_Check_Id) ||
               ', Calling Module= '    || P_Calling_Module             ||
               ', Total Wh Amount= '   || to_char(P_Total_Wh_Amount));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Partial_Payment_Paid_In_Full;



/**************************************************************************
 *                                                                        *
 * Name       : Confirm_Credit_Letters                                    *
 * Purpose    : Updates the credit letters table in order to store the    *
 *              the final check ID, when users confirm a payment batch.   *
 *              This procedure is not called for Quick Payments because   *
 *              the check ID is known from the begining.                  *
 *                                                                        *
 **************************************************************************/
PROCEDURE Confirm_Credit_Letters
                (P_Checkrun_Name           IN     Varchar2,
                 p_checkrun_id             IN     Number,
                 P_Calling_Sequence        IN     Varchar2)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_check_id             Number;
    l_selected_check_id    Number;
    l_debug_info           Varchar2(300);
    l_calling_sequence     Varchar2(2000);

    ------------------------------------------------------
    -- Cursor to select all the payments for a particular
    -- payment batch
    ------------------------------------------------------
    CURSOR c_selected_invoice_checks
    IS
     SELECT distinct(d.payment_id) check_id
       FROM iby_fd_payments_v p,iby_fd_docs_payable_v d
      WHERE to_number(d.calling_app_doc_unique_ref1) = p_checkrun_id
        AND p.payment_id = d.payment_id;

/*
    SELECT apsic.selected_check_id    selected_check_id,
           apsic.check_id             check_id
    FROM   ap_selected_invoice_checks apsic
    WHERE  checkrun_name = P_Checkrun_Name;
*/

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Confirm_Credit_Letters<--' ||
                           P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure Confirm_Credit_Letters(+)');
    END IF;
    -- End Debug

    ------------------------------------------------
    -- Updates credit letter table for each payment
    ------------------------------------------------
    OPEN c_selected_invoice_checks;
    LOOP
        FETCH c_selected_invoice_checks INTO l_check_id;

        EXIT WHEN c_selected_invoice_checks%NOTFOUND;

        ---------------------------------------------------
        -- Updates the credit letter information by
        -- replacing the selected check ID by the check ID
        ---------------------------------------------------
        IF (l_check_id IS NOT NULL) THEN
            UPDATE jl_ar_ap_sup_awt_cr_lts
            SET    check_id          = l_check_id,
                   selected_check_id = null
            WHERE  selected_check_id = l_check_id;
        END IF;

    END LOOP;

    CLOSE c_selected_invoice_checks;

	-- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure Confirm_Credit_Letters(-)');
    END IF;
    -- End Debug

EXCEPTION
    WHEN no_data_found THEN
         -- No credit letters available.
         null;
    WHEN others THEN
      -- Debug Information
         IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Confirm Credit Letters: '||SQLERRM);
         END IF;
      -- end debug

        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                   '  Checkrun Name= ' || P_Checkrun_Name);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Confirm_Credit_Letters;



/**************************************************************************
 *                                                                        *
 * Name       : Reject_Payment_Batch                                      *
 * Purpose    : Sets the "Ok To Pay" flag for all the selected invoices   *
 *              within the payment when the calculation routine is not    *
 *              successful                                                *
 *                                                                        *
 *  RG Sets the DONT_PAY_FLAG for all documents in payment                *
 **************************************************************************/
PROCEDURE Reject_Payment_Batch
                (P_Selected_Check_Id       IN     Number,
                 P_AWT_Success             IN     Varchar2,
                 P_Calling_Sequence        IN     Varchar2)
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_ok_to_pay_flag          Varchar2(10);
    l_dont_pay_reason_code    Varchar2(25);
    l_dont_pay_description    Varchar2(255);
    l_debug_info              Varchar2(300);
    l_calling_sequence        Varchar2(2000);
    l_invoice_id              Number;

    ----------------------
    -- Cursor definition
    ----------------------
    CURSOR c_selected_invoices (P_Selected_Check_Id  IN Number) IS
    SELECT docs.dont_pay_flag dont_pay_flag ,
           docs.dont_pay_reason_code dont_pay_reason,
           docs.calling_app_doc_unique_ref2   invoice_id
-- apsi.ok_to_pay_flag        ok_to_pay_flag,
--           apsi.dont_pay_reason_code  dont_pay_reason_code,
--           apsi.dont_pay_description  dont_pay_description
    FROM   iby_hook_docs_in_pmt_t docs
 -- ap_selected_invoices       apsi
    WHERE  docs.payment_id     =  P_Selected_Check_id
    AND    docs.dont_pay_flag  = 'N'
    AND    docs.calling_app_id = 200
--  apsi.pay_selected_check_id = P_Selected_Check_id
--  AND    nvl(apsi.ok_to_pay_flag, 'Y') = 'Y'
--   AND    apsi.original_invoice_id IS NULL
    FOR UPDATE OF docs.dont_pay_flag,
                  docs.dont_pay_reason_code;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Reject_Payment_Batch<--' ||
                           P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
	   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Reject_Payment_Batch(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter P_Selected_Check_Id: '||to_char(P_Selected_Check_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter P_AWT_Success: '||P_AWT_Success);
    END IF;
    -- End Debug

    -------------------------------------
    -- Updates all the selected invoices
    -------------------------------------
    OPEN c_selected_invoices (P_Selected_Check_Id);
    LOOP
        FETCH c_selected_invoices INTO l_ok_to_pay_flag,
                                       l_dont_pay_reason_code,
                                       l_invoice_id;

        EXIT WHEN c_selected_invoices%NOTFOUND;
        UPDATE iby_hook_docs_in_pmt_t docs
        SET    docs.dont_pay_flag = 'Y',
               docs.dont_pay_reason_code = AWT_ERROR
        WHERE  CURRENT OF c_selected_invoices;

        UPDATE ap_selected_invoices
        SET    ok_to_pay_flag = 'N',
               dont_pay_reason_code =  AWT_ERROR
        WHERE   invoice_id     = l_invoice_id;

    END LOOP;

    CLOSE c_selected_invoices;

    -- RG Update also Payments Table with error
      UPDATE iby_hook_payments_t ipmt
      SET ipmt.dont_pay_flag = 'Y',
          ipmt.dont_pay_reason_code = AWT_ERROR
      WHERE  ipmt.payment_id =  P_Selected_Check_id;

	  -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Reject_Payment_Batch(-)');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                '  Selected Check Id= ' || to_char(P_Selected_Check_Id) ||
                ', AWT Success= '       || P_AWT_Success);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Reject_Payment_Batch;


/**************************************************************************
 *                                                                        *
 * Name       : JL_CALL_DO_AWT                                            *
 * Purpose    : Bug# 1384294 The reason of this procedure is:             *
 *              One store procedure cannot be call from a form and        *
 *              at the same time from the library in a single apps        *
 *              session.                                                  *
 *                                                                        *
 **************************************************************************/
PROCEDURE JL_CALL_DO_AWT
                         (P_Invoice_Id             IN     number
                         ,P_Awt_Date               IN     date
                         ,P_Calling_Module         IN     varchar2
                         ,P_Amount                 IN     number
                         ,P_Payment_Num            IN     number
                                                          default null
                         ,P_Checkrun_Name          IN     varchar2
                                                          default null
                         ,P_Last_Updated_By        IN     number
                         ,P_Last_Update_Login      IN     number
                         ,P_Program_Application_Id IN     number
                                                          default null
                         ,P_Program_Id             IN     number
                                                          default null
                         ,P_Request_Id             IN     number
                                                          default null
                         ,P_Awt_Success            OUT NOCOPY    varchar2
                         ,P_Invoice_Payment_Id     IN     number
                                                          default null
                         ,P_Check_Id               IN     number
                         )
IS
BEGIN

    	  -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE JL_CALL_DO_AWT(+)');
    END IF;
    -- End Debug
            -- Call to core procedure
            Ap_Withholding_Pkg.Ap_Do_Withholding (
                    P_Invoice_Id
                   ,P_AWT_Date
                   ,P_Calling_Module
                   ,P_Amount
                   ,P_Payment_Num
                   ,P_Checkrun_Name
                   ,P_Last_Updated_By
                   ,P_Last_Update_Login
                   ,P_Program_Application_id
                   ,P_Program_Id
                   ,P_Request_Id
                   ,P_Awt_Success
                   ,P_Invoice_Payment_Id
                   ,P_Check_Id
                   );

    	  -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE JL_CALL_DO_AWT(-)');
    END IF;
    -- End Debug
END JL_CALL_DO_AWT;

-- Bug 2722425 Added this new procedure for reissued checks
--             to revert the updates to checks and invoice payments
--             done by Core.
/**************************************************************************
 *                                                                        *
 * Name       : Undo_Quick_Payment                                        *
 * Purpose    : Updates the payment amount by adding the withheld         *
 *              amount.                                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Undo_Quick_Payment
                    (P_Check_Id                 IN     Number,
                     P_Old_Check_Id             IN     Number,
                     P_Calling_Sequence         IN     Varchar2)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_invoice_payment_id    Number;
    l_invoice_id            Number;
    l_pay_exchange_rate     Number;
    l_inv_exchange_rate     Number;
    l_payment_cross_rate    Number;
    l_payment_num           Number;
    l_withhold_amount       Number;
    l_amount                Number;
    l_base_amount           Number;
    l_total_wh_amount       Number := 0;
    l_total_wh_base_amount  Number := 0;
    l_debug_info            Varchar2(300);
    l_calling_sequence      Varchar2(2000);
    l_pay_amount            Number;
    l_payment_base_amount   Number;
    l_invoice_base_amount   Number;

    -------------------------------------
    -- Cursor to select all the invoices
    -- within the payment
    -------------------------------------
    CURSOR c_invoice_payment (P_Check_Id Number)
    IS
    SELECT apip.invoice_payment_id      invoice_payment_id,
           apip.invoice_id              invoice_id,
           apip.exchange_rate           pay_exchange_rate,
           apip.payment_num             payment_num,
           apip.amount                  amount,
           apip.payment_base_amount     payment_base_amount,
           apip.invoice_base_amount     invoice_base_amount
    FROM   ap_invoice_payments apip
    WHERE  apip.check_id = P_Check_Id
    FOR UPDATE OF apip.amount,
                  apip.payment_base_amount,
                  apip.invoice_base_amount;

    --------------------------------
    -- Cursor to select the payment
    --------------------------------
    CURSOR c_checks (P_Check_Id Number)
    IS
    SELECT apch.amount        amount,
           apch.base_amount   base_amount
    FROM   ap_checks          apch
    WHERE  apch.check_id = P_Check_Id
    FOR UPDATE OF apch.amount,
                  apch.base_amount;


 -------------------------------------------------------------
   -- Cursor to get the withheld amount from the old check id
   ------------------------------------------------------------

   CURSOR c_withheld_amount(P_Old_Check_Id Number,
                             P_Invoice_Id   Number)
   IS
   SELECT sum(aid.amount)
   FROM   ap_invoice_distributions aid,
          ap_invoice_payments aip,
          ap_invoices ai
   WHERE  aid.invoice_id  = aip.invoice_id
     AND  ai.invoice_id = aid.invoice_id
     AND  aid.invoice_id  = P_Invoice_Id
     AND  aid.awt_invoice_payment_id = aip.invoice_payment_id
     AND  aid.amount < 0
     AND  aip.check_id   = P_Old_Check_Id
     AND  ai.invoice_type_lookup_code NOT IN ('CREDIT','DEBIT')
     -- added recently
     AND    NVL(aid.REVERSAL_FLAG,'N') <> 'Y'
   UNION
    SELECT sum(aid.amount)
   FROM   ap_invoice_distributions aid,
          ap_invoice_payments aip,
          ap_invoices ai
   WHERE  aid.invoice_id  = aip.invoice_id
     AND  ai.invoice_id = aid.invoice_id
     AND  aid.invoice_id  = P_Invoice_Id
     AND  aid.awt_invoice_payment_id = aip.invoice_payment_id
     AND  aid.amount > 0
     AND  aip.check_id   = P_Old_Check_Id
     AND  ai.invoice_type_lookup_code IN ('CREDIT','DEBIT')
     -- added recently
     AND    NVL(aid.REVERSAL_FLAG,'N') <> 'Y'
   GROUP BY aid.invoice_id;


BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_WITHHOLDING_PKG' || '.' ||
                          'Undo_Quick_Payment<--' || P_Calling_Sequence;


    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Calling Sequence '||l_calling_sequence);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Undo_Quick_Payment(+)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Parameter P_Check_Id: '||to_char(P_Check_Id));
    END IF;
    -- End Debug

    --------------------------------------------
    -- Updates amounts for the invoice payments
    --------------------------------------------

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' OPEN c_invoice_payment');
    END IF;
    -- End Debug

    OPEN c_invoice_payment(P_Check_Id);
    LOOP
        FETCH c_invoice_payment INTO l_invoice_payment_id,
                                     l_invoice_id,
                                     l_pay_exchange_rate,
                                     l_payment_num,
                                     l_pay_amount,
                                     l_payment_base_amount,
                                     l_invoice_base_amount;
        EXIT WHEN c_invoice_payment%NOTFOUND;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_invoice_payment_id= '||to_char(l_invoice_payment_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_invoice_id= '||to_char(l_invoice_id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_pay_exchange_rate= '||to_char(l_pay_exchange_rate));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_payment_num= '||to_char(l_payment_num));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_pay_amount= '||to_char(l_pay_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_payment_base_amount= '||to_char(l_payment_base_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Fetched Values: l_invoice_base_amount= '||to_char(l_invoice_base_amount));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
        END IF;
        -- End Debug
        -------------------------------------------
        -- Obtains withheld amount for the invoice
        -------------------------------------------
        OPEN c_withheld_amount (P_Old_Check_Id, l_invoice_id);
        LOOP
             FETCH c_withheld_amount INTO l_withhold_amount;
             EXIT WHEN c_withheld_amount%NOTFOUND;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Obtains withheld amount for the invoice : '||to_char(l_withhold_amount));
        END IF;
        -- End Debug
        IF (l_withhold_amount <> 0) THEN

            --------------------------------
            -- Obtains currency information
            --------------------------------
            SELECT apin.exchange_rate,
                   apps.payment_cross_rate
            INTO   l_inv_exchange_rate,
                   l_payment_cross_rate
            FROM   ap_invoices          apin,
                   ap_payment_schedules apps
            WHERE  apin.invoice_id    = l_invoice_id
            AND    apps.invoice_id    = l_invoice_id
            AND    apps.payment_num   = l_payment_num;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Obtains currency information: exch rate, pay cross rate '||
                                             to_char(l_inv_exchange_rate)||', '||to_char(l_payment_cross_rate));
            END IF;
            -- End Debug

            --------------------------------------------------------
            -- Updates the amount remaining of the payment schedule
            --------------------------------------------------------
            UPDATE ap_payment_schedules
            SET    amount_remaining = amount_remaining +
                                      (l_withhold_amount *
                                       nvl(l_payment_cross_rate, 1)),
                   payment_status_flag = decode(amount_remaining +
                                                (l_withhold_amount *
                                                 nvl(l_payment_cross_rate, 1)),
                                                 0, 'Y',
                                                 amount_remaining,
                                                 payment_status_flag, 'P')
            WHERE  invoice_id  = l_invoice_id
            AND    payment_num = l_payment_num;

            ------------------------------------------
            -- Updates the amount paid of the invoice
            -- amount_paid does not affect MRC
            ------------------------------------------
            UPDATE ap_invoices
            SET    amount_paid         = nvl(amount_paid, 0) -
                                         (l_withhold_amount *
                                          nvl(l_payment_cross_rate, 1)),
                   payment_status_flag = AP_INVOICES_UTILITY_PKG.get_payment_status(l_invoice_id)
            WHERE invoice_id = l_invoice_id;

            --------------------------------------------------------------
            -- Updates the payment amount
            -- Calling the AP Table Handler to update ap_invoice_payments.
            --------------------------------------------------------------
            l_pay_amount          :=  l_pay_amount - (l_withhold_amount *
                                        nvl(l_payment_cross_rate, 1));

            l_invoice_base_amount :=  l_invoice_base_amount -
                                        (l_withhold_amount * nvl(l_inv_exchange_rate, 1));

            l_payment_base_amount :=  l_payment_base_amount -
                                       (l_withhold_amount * nvl(l_payment_cross_rate, 1) *
                                          nvl(l_pay_exchange_rate, 1));

           IF (Debug_var = 'Y' ) Then
                 JL_ZZ_AP_EXT_AWT_UTIL.Debug('Payment Amt =' || to_char(l_pay_amount) || 'Inv BaseAmt :'
                || to_char(l_withhold_amount));
           END IF;

            AP_AIP_TABLE_HANDLER_PKG.Update_Amounts(
                                   l_invoice_payment_id
                                  ,l_pay_amount
                                  ,l_invoice_base_amount
                                  ,l_payment_base_amount
                                  ,l_calling_sequence);


            --------------------------------------------
            -- Calculates total amounts for the payment
            --------------------------------------------
            l_total_wh_amount      := l_total_wh_amount +
                                      (l_withhold_amount *
                                       nvl(l_payment_cross_rate, 1));

            l_total_wh_base_amount := l_total_wh_base_amount +
                                      (l_withhold_amount *
                                       nvl(l_payment_cross_rate, 1) *
                                       nvl(l_pay_exchange_rate, 1));

        END IF;
       END LOOP; -- end of c_withheld_amount
       CLOSE c_withheld_amount;
    END LOOP;
    CLOSE c_invoice_payment;

    -------------------------------------------------------------------
    -- Updates the payment amount for the check
    -- Calling the AP Table Handler to update ap_checks.
    -------------------------------------------------------------------
    IF (l_total_wh_amount <> 0 OR l_total_wh_base_amount <> 0) THEN
        OPEN c_checks (P_Check_Id);
        FETCH c_checks INTO l_amount, l_base_amount;
        IF (NOT c_checks%NOTFOUND) THEN

           l_amount      := l_amount - l_total_wh_amount;
           l_base_amount := l_base_amount - l_total_wh_base_amount;

           AP_AC_TABLE_HANDLER_PKG.Update_Amounts(
                       P_check_id
                      ,l_amount
                      ,l_base_amount
                      ,l_calling_sequence);

        END IF;
        CLOSE c_checks;
    END IF;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Procedure Undo_Quick_Payment(-)');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                    ' Check Id= '  || to_char(P_Check_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;
        App_Exception.Raise_Exception;

END Undo_Quick_Payment;

END JL_AR_AP_WITHHOLDING_PKG;


/
