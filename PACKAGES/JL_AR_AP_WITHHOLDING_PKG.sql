--------------------------------------------------------
--  DDL for Package JL_AR_AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_AP_WITHHOLDING_PKG" AUTHID CURRENT_USER AS
/* $Header: jlarpwhs.pls 120.6 2005/08/25 23:57:01 rguerrer ship $ */



/**************************************************************************
 *                         Constants Definition                           *
 **************************************************************************/

AWT_SUCCESS      CONSTANT Varchar2(10) := Jl_Zz_Ap_Withholding_Pkg.AWT_SUCCESS;
AWT_ERROR        CONSTANT Varchar2(10) := Jl_Zz_Ap_Withholding_Pkg.AWT_ERROR;
DUMMY_INVOICE_ID CONSTANT Number       := -1;



/**************************************************************************
 *                     Records and Tables Definition                      *
 **************************************************************************/


TYPE Rec_Payment_Withholding IS RECORD
(
    awt_type_code               Varchar2(30),
    tax_id                      Number,
    invoice_id                  Number,
    vendor_id                   Number,
    invoice_distribution_id    Number, -- Lines
    invoice_amount              Number,
    line_amount                 Number,
    payment_amount              Number,
    invoice_payment_id          Number,
    payment_num                 Number,
    tax_base_amount_basis       Varchar2(30)
);

TYPE Rec_Invoice_Amount IS RECORD
(
    invoice_id                  Number,
    invoice_distribution_id    Number, -- Lines
    invoice_amount              Number,
    amount                      Number,
    tax_inclusive_amount        Number,
    payment_amount              Number,
    taxable_base_amount         Number,
    prorated_tax_incl_amt       Number,
    invoice_payment_id          Number,
    invoice_payment_num         Number);

TYPE Tab_Amounts IS TABLE OF Rec_Invoice_Amount
     INDEX BY BINARY_INTEGER;




/**************************************************************************
 *                    Public Procedures Definition                        *
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
               P_Check_Id               IN     Number     Default null);




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
               P_Request_Id             IN     Number     Default null);


/**************************************************************************
 *                                                                        *
 * Name       : Jl_Ar_Ap_Void_Selec_Cetif                                 *
 * Purpose    : Routine to Void the Certificates corresponding to cancel  *
 *              payments                                                  *
 *              Created for bug 2145634                                   *
 *                                                                        *
 **************************************************************************/

/*  Removed to Cancel of payments in new process has not generated
    certificates.

PROCEDURE JL_AR_AP_VOID_SELEC_CERTIF(
        p_checkrun_Name         IN     Varchar2,
        p_selected_check_id     IN     Number,
        P_Calling_Sequence      IN     Varchar2);
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
               P_Checkrun_Id            IN     Number,
               P_Undo_Awt_Date          IN     Date,
               P_Calling_Module         IN     Varchar2,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null);




/**************************************************************************
 * New release 12.0 procedure                                                                       *
 * Name       : Jl_Ar_Ap_Certificates                                     *
 * Purpose    : Handles creation and void of withholding certificates     *
 *              for a particular payment.                                 *
 *                                                                        *
 **************************************************************************/
PROCEDURE Jl_Ar_Ap_Certificates
 ( p_payment_instruction_ID   IN NUMBER,
   p_calling_module           IN VARCHAR2,
   p_api_version              IN NUMBER,
   p_init_msg_list            IN VARCHAR2 ,
   p_commit                   IN VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2);

/**************************************************************************
 *                                                                        *
 * Name       : JL_CALL_DO_AWT                                            *
 * Purpose    : Bug# 1428033 The reason of this procedure is:             *
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
                         );


-- Bug 2722425
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
                     P_Calling_Sequence         IN     Varchar2);

END JL_AR_AP_WITHHOLDING_PKG;

 

/
