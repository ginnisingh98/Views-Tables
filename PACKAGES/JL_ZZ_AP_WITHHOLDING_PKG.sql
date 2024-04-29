--------------------------------------------------------
--  DDL for Package JL_ZZ_AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AP_WITHHOLDING_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzpwhs.pls 120.8.12010000.2 2009/01/06 11:39:30 nivnaray ship $ */



/**************************************************************************
 *                         Constants Definition                           *
 **************************************************************************/

AWT_SUCCESS     CONSTANT   Varchar2(10) := 'SUCCESS';
AWT_ERROR       CONSTANT   Varchar2(10) := 'AWT ERROR';



/**************************************************************************
 *                      PL/SQL Records Definition                         *
 **************************************************************************/


-------------------------------------------
-- Invoice/Payment Withholding Information
-------------------------------------------
TYPE Rec_Withholding IS RECORD
(
    invoice_id                   Number,
    invoice_distribution_id     Number,
    awt_type_code                Varchar2(30),
    jurisdiction_type            Varchar2(30),
    tax_id                       Number,
    tax_name                     Varchar2(15),
    tax_code_combination_id      Number,
    awt_period_type              Varchar2(15),
    rate_id                      Number,
    line_amount                  Number,
    taxable_base_amount          Number,
    revised_tax_base_amount      Number,
    withheld_amount              Number,
    prorated_amount              Number,
    invoice_payment_id           Number,
    applicable_flag              Varchar2(1),
 -- by zmohiudd for 1849986
    payment_num                  Number,
    exemption_amount             Number);


-------------------------------
-- Amount Withheld Information
-------------------------------
TYPE Rec_All_Withholding IS RECORD
(
    invoice_id                   Number,
    invoice_distribution_id     Number,
    awt_type_code                Varchar2(30),
    tax_id                       Number,
    jurisdiction_type            Varchar2(30),
    prorated_amount              Number
);


-----------------------
-- Tax Name Attributes
-----------------------
TYPE Rec_AWT_Code IS RECORD
(
    Tax_Id                       Number,
    Name                         Varchar2(15),
    Tax_Code_Combination_Id      Number,
    AWT_Period_Type              Varchar2(15),
    Foreign_Rate_Ind             Varchar2(1),
    Zone_Code                    Varchar2(30),
    Item_Applic                  Varchar2(1),
    Freight_Applic               Varchar2(1),
    Misc_Applic                  Varchar2(1),
    Tax_Applic                   Varchar2(1),
    Min_Tax_Base_Amt             Number,
    Min_Withheld_Amt             Number,
    Adj_Min_Base                 Varchar2(30),
    Cumulative_Payment_Flag      Varchar2(1),
    Tax_Inclusive                Varchar2(1),
    Income_Tax_Rate              Number,
    First_Tax_Type               Varchar2(30),
    Second_Tax_Type              Varchar2(30),
    Municipal_Type               Varchar2(1),
    Reduction_Perc               Number
);



-----------------------
-- Tax Rate Attributes
-----------------------
TYPE Rec_AWT_Rate IS RECORD
(
    Tax_Rate_Id                  Number,
    Tax_Rate                     Number,
    Rate_Type                    Varchar2(25),
    Amount_To_Subtract           Number,
    Amount_To_Add                Number
);



/**************************************************************************
 *                      PL/SQL Tables Definition                          *
 **************************************************************************/


-------------------------------------
-- Invoice/Payment Withholding Table
-------------------------------------
TYPE Tab_Withholding IS TABLE OF Rec_Withholding
     INDEX BY BINARY_INTEGER;


--------------------------
-- Amount Withheld Table
--------------------------
TYPE Tab_All_Withholding IS TABLE OF Rec_All_Withholding
     INDEX BY BINARY_INTEGER;




/**************************************************************************
 *                            Public Procedures                           *
 **************************************************************************/



/**************************************************************************
 *                                                                        *
 * Name       : Get_Withholding_Options                                   *
 * Purpose    : Obtains all the withholding setup options from AP_SYSTEM_ *
 *              PARAMETERS table                                          *
 *                                                                        *
 **************************************************************************/
PROCEDURE Get_Withholding_Options (P_Create_Distr     OUT NOCOPY    Varchar2,
                                   P_Create_Invoices  OUT NOCOPY    Varchar2);




/**************************************************************************
 *                                                                        *
 * Name       : Get_GL_Period_Name                                        *
 * Purpose    : Returns the period name for a particular date.            *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_GL_Period_Name (P_AWT_Date  IN  Date)
                             RETURN VARCHAR2;




/**************************************************************************
 *                                                                        *
 * Name       : Get_Base_Currency_Code                                    *
 * Purpose    : Returns the functional currency code (from AP_SYSTEM_     *
 *              PARAMETERS)                                               *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Base_Currency_Code RETURN VARCHAR2;




/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholding_Table                              *
 * Purpose    : Initialize the PL/SQL table to store the withholding tax  *
 *              names.                                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholding_Table (P_Wh_Table  IN OUT NOCOPY  Tab_Withholding);




/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholding_Type                               *
 * Purpose    : Obtains all the information associated to the current     *
 *              withholding tax type and for a particular supplier:       *
 *              1. Minimum taxable base amount                            *
 *              2. Minimum withheld amount                                *
 *              3. Associated attributes (from JL_ZZ_AP_AWT_TYPES)        *
 *              4. Supplier exemptions                                    *
 *              5. Multilateral contribution                              *
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholding_Type
                   (P_AWT_Type_Code      IN   Varchar2,
                    P_Vendor_Id          IN   Number,
                    P_Rec_AWT_Type       OUT NOCOPY  jl_zz_ap_awt_types%ROWTYPE,
                    P_Rec_Suppl_AWT_Type OUT NOCOPY  jl_zz_ap_supp_awt_types%ROWTYPE);




/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholding_Name                               *
 * Purpose    : Obtains all the information associated to the current     *
 *              tax name and for a particular supplier:                   *
 *              1. Minimum taxable base amount                            *
 *              2. Minimum withheld amount                                *
 *              3. Associated global attributes (from AP_TAX_CODES)       *
 *              4. Supplier exemptions                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholding_Name
                  (P_AWT_Type_Code       IN    Varchar2,
                   P_Tax_Id              IN    Number,
                   P_Vendor_Id           IN    Number,
                   P_AWT_Name            OUT NOCOPY   Rec_AWT_Code,
                   P_Rec_Suppl_AWT_Name  OUT NOCOPY   jl_zz_ap_sup_awt_cd%ROWTYPE,
                   P_CODE_ACCOUNTING_DATE  IN   DATE  Default  NULL);               -- Argentina AWT ER 6624809




/**************************************************************************
 *                                                                        *
 * Name       : Get_Taxable_Base_Amount                                   *
 * Purpose    : Obtains the taxable base amount for a particular tax name *
 *              This amount is calculated as follows:                     *
 *              * The distribution line amount for those invoice based    *
 *                withholding taxes                                       *
 *              * The proportional payment amount for those payment based *
 *                withholding taxes                                       *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Taxable_Base_Amount
               (P_Invoice_Id               IN    Number,
                P_Distr_Line_No            IN    Number,
                P_Line_Amount              IN    Number,
                P_Payment_Amount           IN    Number     Default null,
                P_Invoice_Amount           IN    Number,
                P_Tax_Base_Amount_Basis    IN    Varchar2) RETURN NUMBER;




/**************************************************************************
 *                                                                        *
 * Name       : Store_Tax_Name                                            *
 * Purpose    : Put the information regarding the current tax name of the *
 *              payment into the PL/SQL table                             *
 *                                                                        *
 **************************************************************************/
PROCEDURE Store_Tax_Name
                 (P_Tab_Withhold        IN OUT NOCOPY  Tab_Withholding,
                  P_Current_AWT         IN      Number,
                  P_Invoice_Id          IN      Number,
                  P_Distr_Line_No       IN      Number,
                  P_AWT_Type_Code       IN      Varchar2,
                  P_Tax_Id              IN      Number,
                  P_Tax_Name            IN      Varchar2,
                  P_Tax_Code_Comb_Id    IN      Number,
                  P_AWT_Period_Type     IN      Varchar2,
                  P_Jurisdiction_Type   IN      Varchar2,
                  P_Line_Amount         IN      Number,
                  P_Taxable_Base_Amount IN      Number,
                  P_Invoice_Payment_Id  IN      Number       Default null,
 -- by Zmohiudd for bug 1849986
                  P_Payment_Num  IN             Number       Default null);



/**************************************************************************
 *                                                                        *
 * Name       : Process_Withholding_Name                                  *
 * Purpose    : Process the information for each different tax name for   *
 *              a particular withholding tax type. It means:              *
 *              1. Obtains cumulative figures (when applicable)           *
 *              2. Gets the tax rate (checking the effective dates and    *
 *                 taxable base amount)                                   *
 *              3. Performs the calculation to obtain the withheld amount *
 *                 and applies all the validations that are applicable    *
 *                 at withholding tax name level.                         *
 *                                                                        *
 **************************************************************************/
PROCEDURE Process_Withholding_Name
               (P_Vendor_Id           IN      Number,
                P_Rec_AWT_Type        IN      jl_zz_ap_awt_types%ROWTYPE,
                P_Rec_AWT_Name        IN      Rec_AWT_CODE,
                P_Rec_Suppl_AWT_Type  IN      jl_zz_ap_supp_awt_types%ROWTYPE,
                P_Rec_Suppl_AWT_Name  IN      jl_zz_ap_sup_awt_cd%ROWTYPE,
                P_AWT_Date            IN      Date,
                P_Tab_Withhold        IN OUT NOCOPY  Tab_Withholding,
                P_Tax_Name_From       IN      Number,
                P_Tax_Name_To         IN      Number,
                P_Tab_All_Withhold    IN OUT NOCOPY  Tab_All_Withholding,
                P_AWT_Success         OUT NOCOPY     Varchar2);




/**************************************************************************
 *                                                                        *
 * Name       : Prorate_Withholdings                                      *
 * Purpose    : Prorates all the withholdings included into the PL/SQL    *
 *              table.                                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Prorate_Withholdings
                    (P_Tab_Withhold         IN OUT NOCOPY Tab_Withholding,
                     P_Currency_Code        IN     Varchar2);




/**************************************************************************
 *                                                                        *
 * Name       : Store_Into_Temporary_Table                                *
 * Purpose    : Transfers all the withholding taxes stored into the PL/SQL*
 *              table to the temporary table (AP_AWT_TEMP_DISTRIBUTIONS)  *
 *                                                                        *
 **************************************************************************/
PROCEDURE Store_Into_Temporary_Table
              (P_Tab_Withhold             IN     Tab_Withholding,
               P_Vendor_Id                IN     Number,
               P_AWT_Date                 IN     Date,
               P_GL_Period_Name           IN     Varchar2,
               P_Base_Currency_Code       IN     Varchar2,
               P_Revised_Amount_Flag      IN     Boolean,
               P_Prorated_Amount_Flag     IN     Boolean,
               P_Zero_WH_Applicable       IN     Boolean,
               P_Handle_Bucket            IN     Boolean,
               P_AWT_Success              OUT NOCOPY    Varchar2,
               P_Last_Updated_By          IN     Number     Default null,
               P_Last_Update_Login        IN     Number     Default null,
               P_Program_Application_Id   IN     Number     Default null,
               P_Program_Id               IN     Number     Default null,
               P_Request_Id               IN     Number     Default null,
               P_Calling_Module           IN     Varchar2   Default null,
               P_Checkrun_Name            IN     Varchar2   Default null,
               P_Checkrun_id              IN     Number     Default null,
               P_Payment_Num              IN     Number     Default null,
               P_Global_Attr_Category     IN     Varchar2   Default null,
               P_NIT_Number               IN     Varchar2   Default null);




/**************************************************************************
 *                                                                        *
 * Name       : Process_Withholding_Type                                  *
 * Purpose    : Process the information for each different withholding    *
 *              tax type included within the payment.                     *
 *                                                                        *
 **************************************************************************/
PROCEDURE Process_Withholding_Type
               (P_Rec_AWT_Type         IN      jl_zz_ap_awt_types%ROWTYPE,
                P_Rec_Suppl_AWT_Type   IN      jl_zz_ap_supp_awt_types%ROWTYPE,
                P_AWT_Date             IN      Date,
                P_Currency_Code        IN      Varchar2,
                P_Tab_Withhold         IN OUT NOCOPY  Tab_Withholding);




/**************************************************************************
 *                                                                        *
 * Name       : Store_Prorated_Withholdings                               *
 * Purpose    : Transfers the Prorated Withholding details, from one      *
 *              PL/SQL table to another                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Store_Prorated_Withholdings
                (P_Tab_Withhold         IN      Tab_Withholding,
                 P_Tab_All_Withhold     IN OUT NOCOPY  Tab_All_Withholding);




/**************************************************************************
 *                                                                        *
 * Name       : Print_Tax_Names                                           *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/
PROCEDURE Print_Tax_Names (P_Tab_Payment_Wh    IN   Tab_Withholding);




/**************************************************************************
 *                                                                        *
 * Name       : Jl_Zz_Ap_Extended_Match                                   *
 * Purpose    : Regional Extended Routine for Matching                    *
 *                                                                        *
 **************************************************************************/
--
-- R12 KI
--
PROCEDURE Jl_Zz_Ap_Extended_Match
                    (P_Credit_Id              IN     Number,
                     P_Invoice_Id             IN     Number     Default null, -- Bug 4559478
                     P_Inv_Line_Num    IN     Number     Default null,
                     P_Distribution_id        IN     Number     Default null,
                     P_Parent_Dist_ID         IN     Number     Default null);

/**************************************************************************
 *                                                                        *
 * Name       : Jl_Zz_Ap_Ext_Insert_Dist                                  *
 * Purpose    : Regional Extended Routine for Insertion                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Jl_Zz_Ap_Ext_Insert_Dist
                    (P_Invoice_Id                 IN    Number,
                     P_Invoice_Distribution_id    IN    Number,    -- Add new Column
                     P_Distribution_Line_Number   IN    Number,
                     P_Line_Type                  IN    Varchar2,
                     P_GL_Date                    IN    Date,
                     P_Period_Name                IN    Varchar2,
                     P_Type_1099                  IN    Varchar2,
                     P_Income_Tax_Region          IN    Varchar2,
                     P_Amount                     IN    Number,
                     P_Tax_Code_ID                IN    Number,   -- Add new Column
                     P_Code_Combination_Id        IN    Number,
                     P_PA_Quantity                IN    Number,
                     P_Description                IN    Varchar2,
                     P_tax_recoverable_flag       IN    Varchar2, -- Add new Column
                     P_tax_recovery_rate          IN    Number,   -- Add new Column
                     P_tax_code_override_flag     IN    Varchar2, -- Add new Column
                     P_tax_recovery_override_flag IN    Varchar2, -- Add new Column
                     P_po_distribution_id         IN    Number,   -- Add new Column
                     P_Attribute_Category         IN    Varchar2,
                     P_Attribute1                 IN    Varchar2,
                     P_Attribute2                 IN    Varchar2,
                     P_Attribute3                 IN    Varchar2,
                     P_Attribute4                 IN    Varchar2,
                     P_Attribute5                 IN    Varchar2,
                     P_Attribute6                 IN    Varchar2,
                     P_Attribute7                 IN    Varchar2,
                     P_Attribute8                 IN    Varchar2,
                     P_Attribute9                 IN    Varchar2,
                     P_Attribute10                IN    Varchar2,
                     P_Attribute11                IN    Varchar2,
                     P_Attribute12                IN    Varchar2,
                     P_Attribute13                IN    Varchar2,
                     P_Attribute14                IN    Varchar2,
                     P_Attribute15                IN    Varchar2,
                     P_Calling_Sequence           IN    Varchar2);

/*************************************************************************
 * Name       : Validate_Multiple_Bal_Seg                                 *
 * Purpose    : Rountine to check whether there exists multiple balancing *
 *              segments within invoice distributions or tax code         *
 *                                                                        *
 **************************************************************************/

-- Fix for bug  1770433
FUNCTION Validate_Multiple_Bal_Seg
            (P_Invoice_Id ap_invoices.invoice_id%TYPE
             ) return Varchar2;

 /*************************************************************************
 * Name       : Validate_Mult_BS_GateWay                                  *
 * Purpose    : Rountine to check whether there exists multiple balancing *
 *              segments within invoice distributions or tax code         *
 *              for Invoice Gateway                                       *
 *                                                                        *
 **************************************************************************/
-- Fix for bug 1770433
FUNCTION Validate_Mult_BS_GateWay
            (P_Invoice_Id ap_invoices.invoice_id%TYPE
             ) return Varchar2;

 /*************************************************************************
 * Name       : Dynamic_Call_Get_BalSeg                                   *
 * Purpose    : Encapsulate Dynamic Call to get_auto_offsets_segments     *
 *                                                                        *
 **************************************************************************/

FUNCTION Dynamic_Call_Get_BalSeg
            (P_ccid IN Number ) return Varchar2;

END JL_ZZ_AP_WITHHOLDING_PKG;

/
