--------------------------------------------------------
--  DDL for Package AP_EXTENDED_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_EXTENDED_WITHHOLDING_PKG" AUTHID CURRENT_USER AS
/* $Header: apexawts.pls 120.6 2005/10/25 22:07:30 dbetanco noship $ */


/**************************************************************************
 *                              Constants                                 *
 **************************************************************************/

TRUE_VALUE  CONSTANT NUMBER  := 1;
FALSE_VALUE CONSTANT NUMBER  := 0;



/**************************************************************************
 *                                                                        *
 * Name       : Ap_Do_Extended_Withholding                                *
 * Purpose    : This is a dummy procedure which will verify whether the   *
 *              Regional Extended Package is installed (JG_EXTENDED_      *
 *              WITHHOLDING_PKG). If installed, then the Extended         *
 *              Withholding Routine will be executed dynamically.         *
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
                     p_checkrun_id            in     number     default null);




/**************************************************************************
 *                                                                        *
 * Name       : Ap_Undo_Extended_Withholding                              *
 * Purpose    : This is a dummy procedure which will verify whether the   *
 *              Regional Extended Package is installed (JG_EXTENDED_      *
 *              WITHHOLDING_PKG). If installed, then the Extended         *
 *              Withholding Routine (for reversion) will be executed      *
 *              dynamically.                                              *
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
                  P_New_Dist_Line_No       IN     Number     Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Ap_Undo_Temp_Ext_Withholding                              *
 * Purpose    : This is a dummy procedure which will verify whether the   *
 *              Regional Extended Package is installed (JG_EXTENDED_      *
 *              WITHHOLDING_PKG). If installed, then the Extended         *
 *              Withholding Routine to reverse the temporary withholding  *
 *              distribution lines will be executed dynamically.          *
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
                     p_checkrun_id            in     number    default null);




/**************************************************************************
 *                                                                        *
 * Name       : Ap_Ext_Withholding_Default                                *
 * Purpose    : This is a dummy procedure which will verify whether the   *
 *              Regional Extended Package is installed (JG_EXTENDED_      *
 *              WITHHOLDING_PKG). If installed, then the routine to       *
 *              default withholding information will be executed          *
 *              dynamically.                                              *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Ext_Withholding_Default
                    (P_Invoice_Id             IN     Number,
                     P_Inv_Line_Num           IN     Number,   --Bug 4554163
                     P_Inv_Dist_Id IN   ap_invoice_distributions_all.invoice_distribution_id%TYPE,
                     P_Calling_Module         IN     Varchar2, --Bug 4554163
                     P_Parent_Dist_ID         IN     Number,
                     P_Awt_Success            OUT NOCOPY    Varchar2);

/**************************************************************************
 *                                                                        *
 * Name       : Ap_Extended_Match                                         *
 * Purpose    : This is a dummy procedure which will verify whether the   *
 *              Regional Extended Package is installed (JG_EXTENDED_      *
 *              WITHHOLDING_PKG). If installed, then the Extended         *
 *              Matching Routine will be executed dynamically.            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Extended_Match
                    (P_Credit_Id              IN     Number,
                     P_Invoice_Id             IN     Number     Default null,
                     P_Inv_Line_Num           IN     Number     Default null,  --Bug 4554163
                     P_Distribution_id        IN     Number     Default null,
                     P_Parent_Dist_ID         IN     Number     Default null);



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
                     P_Calling_Sequence         IN      Varchar2);




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
FUNCTION Ap_Extended_Withholding_Active RETURN Boolean;
PRAGMA Restrict_References(Ap_Extended_Withholding_Active, WNDS);




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
FUNCTION Ap_Extended_Withholding_Option RETURN Varchar2;
PRAGMA Restrict_References(Ap_Extended_Withholding_Option, WNDS);


/**************************************************************************
 *                                                                        *
 * Name       : Ap_Ext_Withholding_Prepay                                 *
 * Purpose    : Extended Routine for carry over the withholdings from     *
 *              Prepayment invoice Item line to Invoice Prepay Line.      *
 *                                                                        *
 **************************************************************************/
PROCEDURE Ap_Ext_Withholding_Prepay
               (P_prepay_dist_id      IN Number,
                P_invoice_id          IN Number,
                P_inv_dist_id         IN Number,  --Bug 4554163
                P_user_id             IN Number,
                P_last_update_login   IN Number,
                P_calling_sequence    IN Varchar2);

/**************************************************************************
 *                                                                        *
 * Name       : Check_With_Dis                                            *
 * Purpose    : Extended Routine to validate whether a Withholding Tax    *
 *              Code has been calculated or not for a given invoice       *
 *              distribution line.                                        *
 *                                                                        *
 **************************************************************************/
FUNCTION Check_With_Dis
            (P_Invoice_Distribution_Id ap_invoice_distributions.invoice_distribution_id%TYPE
            ,P_Tax_Name ap_tax_codes.name%TYPE
            ,P_Global_Attribute2 ap_invoice_distributions.global_attribute2%TYPE
            ,P_Global_Attribute3 ap_invoice_distributions.global_attribute3%TYPE
             ) return Varchar2;

END AP_EXTENDED_WITHHOLDING_PKG;

 

/
