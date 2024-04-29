--------------------------------------------------------
--  DDL for Package JG_EXTENDED_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_EXTENDED_WITHHOLDING_PKG" AUTHID CURRENT_USER AS
/* $Header: jgexawts.pls 120.3 2005/10/26 00:14:51 dbetanco ship $ */


/**************************************************************************
 *                                                                        *
 * Name       : Jg_Do_Extended_Withholding                                *
 * Purpose    : Regional Extended Routine for the Withholding Tax         *
 *              Calculation                                               *
 *                                                                        *
 **************************************************************************/
FUNCTION JG_DO_EXTENDED_WITHHOLDING
              (P_Invoice_Id             IN     Number,
               P_Awt_Date               IN     Date,
               P_Calling_Module         IN     Varchar2,
               P_Amount                 IN     Number,
               P_Payment_Num            IN     Number     Default null,
               P_Checkrun_Name          IN     Varchar2   Default null,
               P_Checkrun_id            IN     Number     Default null,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null,
               P_Invoice_Payment_Id     IN     Number     Default null,
               P_Check_Id               IN     Number     Default null)
               RETURN NUMBER;



/**************************************************************************
 *                                                                        *
 * Name       : Jg_Undo_Extended_Withholding                              *
 * Purpose    : Regional Extended Routine for the Withholding Tax         *
 *              Reversion                                                 *
 *                                                                        *
 **************************************************************************/
FUNCTION JG_UNDO_EXTENDED_WITHHOLDING
              (P_Parent_Id              IN     Number,
               P_Calling_Module         IN     Varchar2,
               P_Awt_Date               IN     Date,
               P_New_Invoice_Payment_Id IN     Number     Default null,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null,
               P_Dist_Line_No           IN     Number     Default null,
               P_New_Invoice_Id         IN     Number     Default null,
               P_New_Dist_Line_No       IN     Number     Default null)
               RETURN NUMBER;




/**************************************************************************
 *                                                                        *
 * Name       : Jg_Undo_Temp_Ext_Withholding                              *
 * Purpose    : Regional Extended Routine to Reverse Temporary            *
 *              Withholding Distributions                                 *
 *                                                                        *
 **************************************************************************/
FUNCTION JG_UNDO_TEMP_EXT_WITHHOLDING
              (P_Invoice_Id             IN     Number,
               P_Vendor_Id              IN     Number     Default null,
               P_Payment_Num            IN     Number,
               P_Checkrun_Name          IN     Varchar2,
               P_Checkrun_id            IN     Number,
               P_Undo_Awt_Date          IN     Date,
               P_Calling_Module         IN     Varchar2,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null)
               RETURN NUMBER;




/**************************************************************************
 *                                                                        *
 * Name       : Jg_Ext_Withholding_Default                                *
 * Purpose    : Regional Extended Routine to Default Withholding Tax      *
 *              Information                                               *
 *              -- Bug 4559472                                            *
 **************************************************************************/
FUNCTION JG_EXT_WITHHOLDING_DEFAULT (P_Invoice_Id     IN   Number,
                                     P_Inv_Line_Num   IN   Number,
                                     P_Inv_Dist_Id    IN   ap_invoice_distributions_all.invoice_distribution_id%TYPE,
                                     P_Calling_Module IN   Varchar2,
                                     P_Parent_Dist_ID IN   Number)
                                     RETURN NUMBER;

/**************************************************************************
 *                                                                        *
 * Name       : Jg_Extended_Match                                         *
 * Purpose    : Regional Extended Routine for Matching                    *
 *              -- Bug 4559478                                            *
 **************************************************************************/
PROCEDURE JG_EXTENDED_MATCH
                    (P_Credit_Id	      IN     Number,
                     P_Invoice_Id             IN     Number	Default null,
                     P_Inv_Line_Num           IN     Number     Default null,
                     P_Distribution_id        IN     Number     Default null,
                     P_Parent_Dist_ID         IN     Number     Default null);


/**************************************************************************
 *                                                                        *
 * Name       : Jg_Extended_Insert_Dist                                   *
 * Purpose    : Regional Extended Routine for Insertion                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE JG_EXTENDED_INSERT_DIST
                    (P_Invoice_Id               IN      Number,
                     P_Invoice_Distribution_id  IN      Number,   -- Add new Column
                     P_Distribution_Line_Number IN      Number,
                     P_Line_Type                IN      Varchar2,
                     P_GL_Date                  IN      Date,
                     P_Period_Name              IN      Varchar2,
                     P_Type_1099                IN      Varchar2,
                     P_Income_Tax_Region        IN      Varchar2,
                     P_Amount                   IN      Number,
                     P_Tax_Code_ID              IN      Number,   -- Add new Column
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
                     P_Attribute13		IN	Varchar2,
                     P_Attribute14		IN	Varchar2,
                     P_Attribute15		IN	Varchar2,
 		     P_Calling_Sequence		IN	Varchar2
 		     );

/**************************************************************************
 *                                                                        *
 * Name       : Jg_Ext_Withholdings_Prepay                                *
 * Purpose    : Regional Extended Routine for Insertion on Prepay line    *
 *                                                                        *
 **************************************************************************/
FUNCTION Jg_Ext_Withholding_Prepay
                  (P_prepay_dist_id            IN Number,
         	   P_invoice_id   	       IN Number,
                   -- Bug 4559474
                   P_inv_dist_id               IN Number,
         	   P_user_id                   IN Number,
         	   P_last_update_login         IN Number,
                   P_calling_sequence          IN Varchar2
                   )
          RETURN NUMBER;


END JG_EXTENDED_WITHHOLDING_PKG;

 

/
