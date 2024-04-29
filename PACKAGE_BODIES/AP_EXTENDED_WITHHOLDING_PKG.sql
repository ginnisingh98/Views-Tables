--------------------------------------------------------
--  DDL for Package Body AP_EXTENDED_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_EXTENDED_WITHHOLDING_PKG" AS
/* $Header: apexawtb.pls 120.7 2005/10/26 22:43:22 dbetanco noship $ */


/**************************************************************************
 *                                                                        *
 * Name       : Ap_Do_Extended_Withholding                                *
 * Purpose    : This is a dummy procedure to Encapsulate the calls for    *
 *               Regional Extended Package                                *
 *              (JG_EXTENDED_WITHHOLDING_PKG).                            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Do_Extended_Withholding
                    (P_Invoice_Id             IN     Number,
                     P_Awt_Date               IN     Date,
                     P_Calling_Module         IN     Varchar2,
                     P_Amount                 IN     Number,
                     P_Payment_Num            IN     Number     Default null,
                     P_Checkrun_Name          IN     Varchar2   Default null,
                     P_Last_Updated_By        IN     Number,
                     P_Last_Update_Login      IN     Number,
                     P_Program_Application_Id IN     Number     Default null,
                     P_Program_Id             IN     Number     Default null,
                     P_Request_Id             IN     Number     Default null,
                     P_Awt_Success            OUT NOCOPY    Varchar2,
                     P_Invoice_Payment_Id     IN     Number     Default null,
                     P_Check_Id               IN     Number     Default null,
                     p_checkrun_id            in     number     default null)

IS

   l_return_value           NUMBER := 0;

BEGIN
    --------------------------------
    -- Initializes output arguments
    --------------------------------
    P_Awt_Success := 'AWT Error';

    l_return_value :=  JG_EXTENDED_WITHHOLDING_PKG.Jg_Do_Extended_Withholding
                               (
                                P_Invoice_Id
                               ,P_Awt_Date
                               ,P_Calling_module
                               ,P_Amount
                               ,P_Payment_Num
                               ,P_Checkrun_Name
                               ,p_checkrun_id
                               ,P_Last_Updated_By
                               ,P_Last_Update_Login
                               ,P_Program_Application_Id
                               ,P_Program_Id
                               ,P_Request_Id
                               ,P_Invoice_Payment_Id
                               ,P_Check_Id);

    IF (l_return_value = TRUE_VALUE) THEN
        P_Awt_Success := 'SUCCESS';
    END IF;

END Ap_Do_Extended_Withholding;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Undo_Extended_Withholding                              *
 * Purpose    : This is a dummy procedure to Encapsulate the calls for    *
 *               Regional Extended Package                                *
 *              (JG_EXTENDED_WITHHOLDING_PKG).                            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Undo_Extended_Withholding
                 (P_Parent_Id              IN     Number,
                  P_Calling_Module         IN     Varchar2,
                  P_Awt_Date               IN     Date,
                  P_New_Invoice_Payment_Id IN     Number     Default null,
                  P_Last_Updated_By        IN     Number,
                  P_Last_Update_Login      IN     Number,
                  P_Program_Application_Id IN     Number     Default null,
                  P_Program_Id             IN     Number     Default null,
                  P_Request_Id             IN     Number     Default null,
                  P_Awt_Success            OUT NOCOPY    Varchar2 ,
                  P_Dist_Line_No           IN     Number     Default null,
                  P_New_Invoice_Id         IN     Number     Default null,
                  P_New_Dist_Line_No       IN     Number     Default null)

IS
   l_return_value           NUMBER := 0;

BEGIN
    --------------------------------
    -- Initializes output arguments
    --------------------------------
    P_Awt_Success := 'AWT Error';

    l_return_value := JG_EXTENDED_WITHHOLDING_PKG.Jg_Undo_Extended_Withholding
                            (
                             P_Parent_Id
                            ,P_Calling_Module
                            ,P_Awt_Date
                            ,P_New_Invoice_Payment_Id
                            ,P_Last_Updated_By
                            ,P_Last_Update_Login
                            ,P_Program_Application_Id
                            ,P_Program_Id
                            ,P_Request_Id
                            ,P_Dist_Line_No
                            ,P_New_Invoice_Id
                            ,P_New_Dist_Line_No);

    IF (l_return_value = TRUE_VALUE) THEN
        P_Awt_Success := 'SUCCESS';
    END IF;
END Ap_Undo_Extended_Withholding;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Undo_Temp_Ext_Withholding                              *
 * Purpose    : This is a dummy procedure to Encapsulate the calls for    *
 *               Regional Extended Package                                *
 *              (JG_EXTENDED_WITHHOLDING_PKG).                            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Undo_Temp_Ext_Withholding
                    (P_Invoice_Id             IN     Number,
                     P_Vendor_Id              IN     Number    Default null,
                     P_Payment_Num            IN     Number,
                     P_Checkrun_Name          IN     Varchar2,
                     P_Undo_Awt_Date          IN     Date,
                     P_Calling_Module         IN     Varchar2,
                     P_Last_Updated_By        IN     Number,
                     P_Last_Update_Login      IN     Number,
                     P_Program_Application_Id IN     Number    Default null,
                     P_Program_Id             IN     Number    Default null,
                     P_Request_Id             IN     Number    Default null,
                     P_Awt_Success            OUT NOCOPY    Varchar2,
                     P_checkrun_id            in     number    default null)
IS
   l_return_value           NUMBER := 0;

BEGIN
    --------------------------------
    -- Initializes output arguments
    --------------------------------
    P_Awt_Success := 'AWT Error';

    l_return_value := JG_EXTENDED_WITHHOLDING_PKG.Jg_Undo_Temp_Ext_Withholding
                                 (
                                  P_Invoice_Id
                                 ,P_Vendor_Id
                                 ,P_Payment_Num
                                 ,P_Checkrun_Name
                                 ,P_checkrun_id
                                 ,P_Undo_Awt_Date
                                 ,P_Calling_Module
                                 ,P_Last_Updated_By
                                 ,P_Last_Update_Login
                                 ,P_Program_Application_Id
                                 ,P_Program_Id
                                 ,P_Request_Id);

    IF (l_return_value = TRUE_VALUE) THEN
        P_Awt_Success := 'SUCCESS';
    END IF;

END Ap_Undo_Temp_Ext_Withholding;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Ext_Withholding_Default                                *
 * Purpose    : This is a dummy procedure to Encapsulate the calls for    *
 *               Regional Extended Package                                *
 *              (JG_EXTENDED_WITHHOLDING_PKG).                            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Ext_Withholding_Default
                    (P_Invoice_Id             IN     Number,
                     P_Inv_Line_Num           IN     Number, --Bug 4554163
                     P_Inv_Dist_Id IN   ap_invoice_distributions_all.invoice_distribution_id%TYPE,
                     P_Calling_Module         IN     Varchar2, --Bug 4554163
                     P_Parent_Dist_ID         IN     Number,
                     P_Awt_Success            OUT NOCOPY    Varchar2)

IS

   l_return_value           NUMBER := 0;
   l_country_code           Varchar2(10);
BEGIN
    ------------------------
    -- Get the Country Code
    ------------------------
    -- Bug# 1683944
    -- Verify country code to avoid not necessary
    -- calls.
    -------------------------------

    fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
    IF (P_Calling_Module <> 'IMPORT') and ((l_country_code = 'AR') OR (l_country_code = 'CO')) THEN
       --------------------------------
       -- Initializes output arguments
       --------------------------------
       P_Awt_Success := 'AWT Error';

       l_return_value := JG_EXTENDED_WITHHOLDING_PKG.Jg_Ext_Withholding_Default
                             (P_Invoice_Id,
                              P_Inv_Line_Num,   -- Bug 4554163
                              P_Inv_Dist_Id,
                              P_Calling_Module,
                              P_Parent_Dist_ID);

       IF (l_return_value = TRUE_VALUE) THEN
           P_Awt_Success := 'SUCCESS';
       END IF;
    ELSIF (P_Calling_Module = 'IMPORT') and (l_country_code = 'BR') Then
          --------------------------------
          -- Initializes output arguments
          --------------------------------
          P_Awt_Success := 'AWT Error';

          l_return_value := JG_EXTENDED_WITHHOLDING_PKG.Jg_Ext_Withholding_Default
                             (P_Invoice_Id,
                              P_Inv_Line_Num,   -- Bug 4554163
                              P_Inv_Dist_Id,
                              P_Calling_Module,
                              P_Parent_Dist_ID);

          IF (l_return_value = TRUE_VALUE) THEN
              P_Awt_Success := 'SUCCESS';
          END IF;
    END IF;
END Ap_Ext_Withholding_Default;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Extended_Match                                         *
 * Purpose    : This is a dummy procedure to Encapsulate the calls for    *
 *               Regional Extended Package                                *
 *              (JG_EXTENDED_WITHHOLDING_PKG).                            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Extended_Match
                    (P_Credit_Id	      IN     Number,
                     P_Invoice_Id             IN     Number	Default null,
                     P_Inv_Line_Num           IN     Number 	Default null,
                     P_Distribution_id        IN     Number     Default null,
                     P_Parent_Dist_ID         IN     Number 	Default null)
IS
BEGIN

     JG_EXTENDED_WITHHOLDING_PKG.Jg_Extended_Match
         ( P_Credit_Id
          ,P_Invoice_Id
          ,P_Inv_Line_Num  --Bug 4554163
          ,P_Distribution_id
          ,P_Parent_Dist_ID);

END Ap_Extended_Match;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Extended_Insert_Dist                                   *
 * Purpose    : This is a dummy procedure which will verify whether the   *
 *              Regional Extended Package is installed (JG_EXTENDED_      *
 *              WITHHOLDING_PKG). If installed, then the routine to       *
 *              insert distribution lines will be executed dynamically.   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Extended_Insert_Dist
                    (P_Invoice_Id               IN      Number,
                     P_Invoice_Distribution_id  IN      Number,    -- Add new Column
                     P_Distribution_Line_Number IN      Number,
                     P_Line_Type                IN      Varchar2,
                     P_GL_Date                  IN      Date,
                     P_Period_Name              IN      Varchar2,
                     P_Type_1099                IN      Varchar2,
                     P_Income_Tax_Region        IN      Varchar2,
                     P_Amount                   IN      Number,
                     P_Tax_Code_ID              IN      Number,    -- Add new Column
                     P_Code_Combination_Id      IN      Number,
                     P_PA_Quantity              IN      Number,
                     P_Description              IN      Varchar2,
                     P_tax_recoverable_flag     IN      Varchar2, -- Add new Column
                     P_tax_recovery_rate        IN      Number,   -- Add new Column
                     P_tax_code_override_flag   IN      Varchar2, -- Add new Column
                     P_tax_recovery_override_flag IN    Varchar2, -- Add new Column
                     P_po_distribution_id       IN      Number,   -- Add new Column
                     P_Attribute_Category       IN      Varchar2,
                     P_Attribute1               IN      Varchar2,
                     P_Attribute2               IN      Varchar2,
                     P_Attribute3               IN      Varchar2,
                     P_Attribute4               IN      Varchar2,
                     P_Attribute5               IN      Varchar2,
                     P_Attribute6               IN      Varchar2,
                     P_Attribute7               IN      Varchar2,
                     P_Attribute8               IN      Varchar2,
                     P_Attribute9               IN      Varchar2,
                     P_Attribute10              IN      Varchar2,
                     P_Attribute11              IN      Varchar2,
                     P_Attribute12              IN      Varchar2,
                     P_Attribute13              IN      Varchar2,
                     P_Attribute14              IN      Varchar2,
                     P_Attribute15              IN      Varchar2,
                     P_Calling_Sequence         IN      Varchar2)
IS
    l_Calling_Sequence         VARCHAR2(150);

BEGIN
    JG_EXTENDED_WITHHOLDING_PKG.Jg_Extended_Insert_Dist
        (P_Invoice_Id
        ,P_Invoice_Distribution_id
        ,P_Distribution_Line_Number
        ,P_Line_Type
        ,P_GL_Date
        ,P_Period_Name
        ,P_Type_1099
        ,P_Income_Tax_Region
        ,P_Amount
        ,P_Tax_Code_ID
        ,P_Code_Combination_Id
        ,P_PA_Quantity
        ,P_Description
        ,P_Tax_Recoverable_Flag
        ,P_Tax_recovery_rate
        ,P_Tax_code_override_flag
        ,P_Tax_recovery_override_flag
        ,P_Po_distribution_id
        ,P_Attribute_Category
        ,P_Attribute1
        ,P_Attribute2
        ,P_Attribute3
        ,P_Attribute4
        ,P_Attribute5
        ,P_Attribute6
        ,P_Attribute7
        ,P_Attribute8
        ,P_Attribute9
        ,P_Attribute10
        ,P_Attribute11
        ,P_Attribute12
        ,P_Attribute13
        ,P_Attribute14
        ,P_Attribute15
        ,P_Calling_Sequence);

END Ap_Extended_Insert_Dist;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Extended_Withholding_Active                            *
 * Purpose    : This function checks whether the extended withholding     *
 *              calculation routine will be called, depending on the      *
 *              value of the "JG: Extended AWT Calculation" profile       *
 *              option. The values returned by this function can be:      *
 *              - TRUE:  If the "JG: Extended AWT Calculation" profile    *
 *                       option exists and is set to 'Yes'.               *
 *              - FALSE: If the "JG: Extended AWT Calculation" profile    *
 *                       option does not exist, or is set to 'No', or     *
 *                       is null.                                         *
 *                                                                        *
 **************************************************************************/
FUNCTION Ap_Extended_Withholding_Active RETURN Boolean
IS
BEGIN
    IF (Fnd_Profile.Defined('JGZZ_EXTENDED_AWT_CALC')) THEN
        IF (nvl(Fnd_Profile.Value('JGZZ_EXTENDED_AWT_CALC'), 'N') = 'Y') THEN

            RETURN TRUE;

        END IF;
    END IF;
    RETURN FALSE;

END Ap_Extended_Withholding_Active;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Extended_Withholding_Option                            *
 * Purpose    : This function returns the value of the "JG: Extended AWT  *
 *              Calculation" profile option. They can be:                 *
 *              - 'Y': If the "JG: Extended AWT Calculation" profile      *
 *                     option exists and is set to 'Yes'.                 *
 *              - 'N': If the "JG: Extended AWT Calculation" profile      *
 *                     option does not exist, or is set to 'No', or       *
 *                     is null.                                           *
 *                                                                        *
 **************************************************************************/
FUNCTION Ap_Extended_Withholding_Option RETURN Varchar2
IS
BEGIN

    IF (Ap_Extended_Withholding_Active) THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

END Ap_Extended_Withholding_Option;

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Ext_Withholding_Prepay                                 *
 * Purpose    : Extended Routine for carry over the withholdings from     *
 *              Prepayment invoice Item line to Invoice Prepay Line.      *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Ext_Withholding_Prepay
             (P_prepay_dist_id          IN Number,
              P_invoice_id              IN Number,
              P_inv_dist_id             IN Number,  --Bug 4554163
              P_user_id                 IN Number,
              P_last_update_login       IN Number,
              P_calling_sequence        IN Varchar2)
IS

l_return_value          NUMBER := 0;
l_calling_sequence      VARCHAR2(1000);

BEGIN
    --------------------------------
    -- Initializes output arguments
    --------------------------------
    l_calling_sequence := p_calling_sequence||'AP_EXT_WITHHOLDING_PREPAY';

    l_return_value := JG_EXTENDED_WITHHOLDING_PKG.Jg_Ext_Withholding_Prepay
                            (
                             P_prepay_dist_id
                            ,P_invoice_id
                            ,P_inv_dist_id    --Bug 4554163
                            ,P_user_id
                            ,P_last_update_login
                            ,l_calling_sequence);
END Ap_Ext_Withholding_Prepay;

/**************************************************************************
 *                                                                        *
 * Name       : Check_With_Dis                                            *
 * Purpose    : Extended Routine to validate whether a Withholding Tax    *
 *              Code has been calculated or not for a given invoice       *
 *              distribution line.                                        *
 *              This routine is for Long-Term Offset vs Ext AWT           *
 *              The solution has not been developed yet.                  *
 *                                                                        *
 **************************************************************************/

FUNCTION Check_With_Dis
            (P_Invoice_Distribution_Id ap_invoice_distributions.invoice_distribution_id%TYPE
            ,P_Tax_Name ap_tax_codes.name%TYPE
            ,P_Global_Attribute2 ap_invoice_distributions.global_attribute2%TYPE
            ,P_Global_Attribute3 ap_invoice_distributions.global_attribute3%TYPE
             ) return Varchar2
IS
  -------------------------------------------------------------------------
  -- Select 'EXIST' from jl_zz_ap_inv_dis_wh
  -------------------------------------------------------------------------
  CURSOR Invoice_Dis_Withholdings IS
  SELECT 'EXIST' Awt
  FROM   ap_invoice_distributions apid
        ,jl_zz_ap_inv_dis_wh jid
        ,jl_zz_ap_sup_awt_cd jsw
        ,ap_tax_codes apc
  WHERE apid.invoice_distribution_id = P_Invoice_Distribution_Id
  AND   apid.invoice_id              = jid.invoice_id
  AND   apid.distribution_line_number= jid.distribution_line_number
  AND   jid.supp_awt_code_id         = jsw.supp_awt_code_id
  AND   apc.tax_id                   = jsw.tax_id
  AND   apc.name                     = P_Tax_Name
  AND   nvl(apid.global_attribute2,-1)       = nvl(P_Global_Attribute2,-1);

  find_awt Varchar2(10):= 'N';

 BEGIN
    IF (Ap_Extended_Withholding_Pkg.Ap_Extended_Withholding_Active) THEN
      FOR db_reg IN Invoice_Dis_Withholdings LOOP
            IF db_reg.awt = 'EXIST' THEN
               find_awt := 'Y';
               return(find_awt);
            END IF;
      END LOOP;
    END IF;
      return(find_awt);
  EXCEPTION
      WHEN OTHERS THEN
           return(find_awt);
END Check_With_Dis;

END AP_EXTENDED_WITHHOLDING_PKG;

/
