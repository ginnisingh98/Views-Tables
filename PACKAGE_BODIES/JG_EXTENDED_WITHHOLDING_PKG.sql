--------------------------------------------------------
--  DDL for Package Body JG_EXTENDED_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_EXTENDED_WITHHOLDING_PKG" AS
/* $Header: jgexawtb.pls 120.15.12010000.2 2009/05/13 18:08:35 nivnaray ship $ */



/**************************************************************************
 *                          Public Procedures                             *
 **************************************************************************/


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
               RETURN NUMBER
IS

    l_country_code    Varchar2(10);
    l_awt_success     Varchar2(2000);

    l_ou_id           NUMBER;

BEGIN

    l_awt_success     := 'SUCCESS';

    ------------------------
    -- Get the Country Code
    ------------------------
    --fnd_profile.get('ORG_ID',l_ou_id);

    l_ou_id  :=  MO_GLOBAL.get_current_org_id;				--bug 8501685

    l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL);

    -------------------------------------------------
    -- Execute the Argentine Withholding Tax Routine
    -------------------------------------------------
    IF (l_country_code = 'AR') THEN
        Jl_Ar_Ap_Withholding_Pkg.Jl_Ar_Ap_Do_Withholding
                       (P_Invoice_Id,
                        P_Awt_Date,
                        P_Calling_Module,
                        P_Amount,
                        P_Payment_Num,
                        P_Checkrun_Name,
                        p_checkrun_id,
                        P_Last_Updated_By,
                        P_Last_Update_Login,
                        P_Program_Application_Id,
                        P_Program_Id,
                        P_Request_Id,
                        l_awt_success,
                        P_Invoice_Payment_Id,
                        P_Check_Id);
    -------------------------------------------------
    -- Execute the Colombian Withholding Tax Routine
    -------------------------------------------------
    ELSIF (l_country_code = 'CO') THEN
           Jl_Co_Ap_Withholding_Pkg.Jl_Co_Ap_Do_Withholding
                       (P_Invoice_Id,
                        P_Awt_Date,
                        P_Calling_Module,
                        P_Amount,
                        P_Payment_Num,
                        P_Last_Updated_By,
                        P_Last_Update_Login,
                        P_Program_Application_Id,
                        P_Program_Id,
                        P_Request_Id,
                        l_awt_success);

    END IF;

    ----------------------------
    -- Return AWT Success Value
    ----------------------------
    IF (l_awt_success = 'SUCCESS') THEN
        RETURN Ap_Extended_Withholding_Pkg.TRUE_VALUE;
    ELSE
        RETURN Ap_Extended_Withholding_Pkg.FALSE_VALUE;
    END IF;

END JG_DO_EXTENDED_WITHHOLDING;


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
               RETURN NUMBER
IS
    l_country_code    Varchar2(10);
    l_awt_success     Varchar2(2000);

    l_ou_id          NUMBER;

BEGIN

    l_awt_success     := 'SUCCESS';

    ------------------------
    -- Get the Country Code
    ------------------------
    --fnd_profile.get('ORG_ID',l_ou_id);

    l_ou_id  :=  MO_GLOBAL.get_current_org_id;				--bug 8501685

    l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL);

    -------------------------------------------------
    -- Execute the Argentine Withholding Tax Routine
    -------------------------------------------------
    IF (l_country_code = 'AR') THEN
        Jl_Ar_Ap_Withholding_Pkg.Jl_Ar_Ap_Undo_Withholding
                                   (P_Parent_Id,
                                    P_Calling_Module,
                                    P_Awt_Date,
                                    P_Last_Updated_By,
                                    P_Last_Update_Login,
                                    P_Program_Application_Id,
                                    P_Program_Id,
                                    P_Request_Id);

    -------------------------------------------------
    -- Execute the Colombian Withholding Tax Routine
    -------------------------------------------------
    ELSIF (l_country_code = 'CO') THEN
        null;

    END IF;

    ----------------------------
    -- Return AWT Success Value
    ----------------------------
    IF (l_AWT_Success = 'SUCCESS') THEN
        RETURN Ap_Extended_Withholding_Pkg.TRUE_VALUE;
    ELSE
        RETURN Ap_Extended_Withholding_Pkg.FALSE_VALUE;
    END IF;

END JG_UNDO_EXTENDED_WITHHOLDING;




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
               P_Checkrun_ID            IN     Number,
               P_Undo_Awt_Date          IN     Date,
               P_Calling_Module         IN     Varchar2,
               P_Last_Updated_By        IN     Number,
               P_Last_Update_Login      IN     Number,
               P_Program_Application_Id IN     Number     Default null,
               P_Program_Id             IN     Number     Default null,
               P_Request_Id             IN     Number     Default null)
               RETURN NUMBER
IS
    l_country_code    Varchar2(10);
    l_awt_success     Varchar2(2000);

    l_ou_id           NUMBER;

BEGIN

    l_awt_success     := 'SUCCESS';

    ------------------------
    -- Get the Country Code
    ------------------------
    --fnd_profile.get('ORG_ID',l_ou_id);

    l_ou_id  :=  MO_GLOBAL.get_current_org_id;				--bug 8501685

    l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL);

    -------------------------------------------------
    -- Execute the Argentine Withholding Tax Routine
    -------------------------------------------------
    IF (l_country_code = 'AR') THEN
        Jl_Ar_Ap_Withholding_Pkg.Jl_Ar_Ap_Undo_Temp_Withholding
                                   (P_Invoice_Id,
                                    P_Payment_Num,
                                    P_Checkrun_Name,
                                    p_Checkrun_id,
                                    P_Undo_Awt_Date,
                                    P_Calling_Module,
                                    P_Last_Updated_By,
                                    P_Last_Update_Login,
                                    P_Program_Application_Id,
                                    P_Program_Id,
                                    P_Request_Id);
    -------------------------------------------------
    -- Execute the Colombian Withholding Tax Routine
    -------------------------------------------------
    ELSIF (l_country_code = 'CO') THEN
        null;

    END IF;

    ----------------------------
    -- Return AWT Success Value
    ----------------------------
    IF (l_AWT_Success = 'SUCCESS') THEN
        RETURN Ap_Extended_Withholding_Pkg.TRUE_VALUE;
    ELSE
        RETURN Ap_Extended_Withholding_Pkg.FALSE_VALUE;
    END IF;

END JG_UNDO_TEMP_EXT_WITHHOLDING;




/**************************************************************************
 *                                                                        *
 * Name       : Jg_Ext_Withholding_Default                                *
 * Purpose    : Regional Extended Routine to Default Withholding Tax      *
 *              Information                                               *
 *               -- Bug 4559472 : R12 KI                                  *
 **************************************************************************/
FUNCTION JG_EXT_WITHHOLDING_DEFAULT (P_Invoice_Id     IN   Number,
                                     P_Inv_Line_Num   IN   Number,
                                     P_Inv_Dist_Id    IN   ap_invoice_distributions_all.invoice_distribution_id%TYPE,
                                     P_Calling_Module IN   Varchar2,
                                     P_Parent_Dist_ID IN   Number)
                                     RETURN NUMBER
IS

    l_country_code    Varchar2(10);

    l_ou_id           NUMBER;

BEGIN
    ------------------------
    -- Get the Country Code
    ------------------------
    --fnd_profile.get('ORG_ID',l_ou_id);

    l_ou_id  :=  MO_GLOBAL.get_current_org_id;				--bug 8501685

    l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL);

    ------------------------------------------------
    -- Execute the Argentine/Colombian Withholding
    -- Tax Defaulting Routine
    --
    -- Payment Schedules Defaulting for Brazil
    -- Validate DUE_DATE for Business Day Calendar for Brazil
    -- Carry out Bank Transfer CollDoc Association for Brazil
    ------------------------------------------------
    IF (l_country_code = 'AR' OR
        l_country_code = 'CO') THEN

        --
        -- Bug 4559472 : R12 KI
        --
        Jl_Zz_Ap_Awt_Default_Pkg.Supp_Wh_Def(P_Invoice_Id,
                                             P_Inv_Line_Num,
                                             P_Inv_Dist_Id,
                                             P_Calling_Module,
                                             P_Parent_Dist_ID);
    ELSIF (l_country_code = 'BR') THEN
        Jl_Br_Ap_Pay_Sched_GDF_PKG.Suppl_Def_Pay_Sched_GDF(P_Invoice_Id);
        -- Brazilian AP/PO Tax has been obsolete in R12
        -- bug#4535578- obsolete Brazilian AP/PO tax feature
        -- Jl_Br_Ap_Create_Tax_PKG.call_match_nomatch_proc(P_Invoice_Id);
    END IF;

    ----------------------------
    -- Return AWT Success Value
    ----------------------------
    RETURN Ap_Extended_Withholding_Pkg.TRUE_VALUE;

END JG_EXT_WITHHOLDING_DEFAULT;


/**************************************************************************
 *                                                                        *
 * Name       : Jg_Extended_Match                                         *
 * Purpose    : Regional Extended Routine for Matching                    *
 *              Bug 4559478 : R12 KI                                      *
 **************************************************************************/
PROCEDURE JG_EXTENDED_MATCH
                    (P_Credit_Id	      IN     Number,
                     P_Invoice_Id             IN     Number	Default null,
                     P_Inv_Line_Num           IN     Number     Default null,
                     P_Distribution_id        IN     Number     Default null,
                     P_Parent_Dist_ID         IN     Number     Default null)

IS

    l_country_code    Varchar2(10);

    l_ou_id           NUMBER;

BEGIN
    ------------------------
    -- Get the Country Code
    ------------------------
    --fnd_profile.get('ORG_ID',l_ou_id);

    l_ou_id  :=  MO_GLOBAL.get_current_org_id;				--bug 8501685

    l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL);

    -------------------------------------------------
    -- Execute the Extended Matching Routine
    -------------------------------------------------
    IF (l_country_code = 'AR' OR l_country_code = 'CO') THEN

        --
        -- Bug 4559478 : R12 KI
        --
        Jl_Zz_Ap_Withholding_Pkg.Jl_Zz_Ap_Extended_Match
                    (P_Credit_Id,
                     P_Invoice_Id,
                     P_Inv_Line_Num,
                     P_Distribution_id,
                     P_Parent_Dist_ID
                     );
    END IF;

END JG_EXTENDED_MATCH;


/**************************************************************************
 *                                                                        *
 * Name       : Jg_Extended_Insert_Dist                                   *
 * Purpose    : Regional Extended Routine for Insertion                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE JG_EXTENDED_INSERT_DIST
                    (P_Invoice_Id	      	IN	Number,
                     P_Invoice_Distribution_id  IN      Number,    -- Add new Column
                     P_Distribution_Line_Number	IN      Number,
                     P_Line_Type		IN	Varchar2,
                     P_GL_Date			IN	Date,
                     P_Period_Name		IN	Varchar2,
                     P_Type_1099		IN	Varchar2,
                     P_Income_Tax_Region	IN	Varchar2,
                     P_Amount			IN	Number,
                     P_Tax_Code_ID              IN      Number,   -- Add new Column
                     P_Code_Combination_Id	IN	Number,
                     P_PA_Quantity		IN 	Number,
                     P_Description		IN	Varchar2,
                     P_tax_recoverable_flag     IN      Varchar2, -- Add new Column
                     P_tax_recovery_rate        IN      Number,   -- Add new Column
                     P_tax_code_override_flag   IN      Varchar2, -- Add new Column
                     P_tax_recovery_override_flag IN    Varchar2, -- Add new Column
                     P_po_distribution_id       IN      Number,   -- Add new Column
                     P_Attribute_Category	IN	Varchar2,
                     P_Attribute1		IN	Varchar2,
                     P_Attribute2		IN	Varchar2,
                     P_Attribute3		IN	Varchar2,
                     P_Attribute4		IN	Varchar2,
                     P_Attribute5		IN	Varchar2,
                     P_Attribute6		IN	Varchar2,
                     P_Attribute7		IN	Varchar2,
                     P_Attribute8		IN	Varchar2,
                     P_Attribute9		IN	Varchar2,
                     P_Attribute10		IN	Varchar2,
                     P_Attribute11		IN	Varchar2,
                     P_Attribute12		IN	Varchar2,
                     P_Attribute13		IN	Varchar2,
                     P_Attribute14		IN	Varchar2,
                     P_Attribute15		IN	Varchar2,
 		     P_Calling_Sequence		IN	Varchar2
 		     )
IS
    l_country_code    Varchar2(10);

    l_ou_id           NUMBER;

BEGIN
    -------------------------------------------
    -- Stubbed out
    -------------------------------------------
    NULL;
    ------------------------
    -- Get the Country Code
    ------------------------
    -- fnd_profile.get('ORG_ID',l_ou_id);
    -- l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL);

    -------------------------------------------------
    -- Execute the Extended Insertion Routine
    -------------------------------------------------
    /* Bug 4535582
    IF (l_country_code = 'AR' OR l_country_code = 'CO') THEN
        Jl_Zz_Ap_Withholding_Pkg.Jl_Zz_Ap_Ext_Insert_Dist
                    (P_Invoice_Id,
                     P_Invoice_Distribution_id,    -- Add new column
                     P_Distribution_Line_Number,
                     P_Line_Type,
                     P_GL_Date,
                     P_Period_Name,
                     P_Type_1099,
                     P_Income_Tax_Region,
                     P_Amount,
                     P_Tax_Code_ID,                -- Add new column
                     P_Code_Combination_Id,
                     P_PA_Quantity,
                     P_Description,
                     P_tax_recoverable_flag,       -- Add new Column
                     P_tax_recovery_rate,          -- Add new Column
                     P_tax_code_override_flag,     -- Add new Column
                     P_tax_recovery_override_flag, -- Add new Column
                     P_po_distribution_id,         -- Add new Column
                     P_Attribute_Category,
                     P_Attribute1,
                     P_Attribute2,
                     P_Attribute3,
                     P_Attribute4,
                     P_Attribute5,
                     P_Attribute6,
                     P_Attribute7,
                     P_Attribute8,
                     P_Attribute9,
                     P_Attribute10,
                     P_Attribute11,
                     P_Attribute12,
                     P_Attribute13,
                     P_Attribute14,
                     P_Attribute15,
 		     P_Calling_Sequence
 		     );
    END IF;
    */
END JG_EXTENDED_INSERT_DIST;

/**************************************************************************
 *                                                                        *
 * Name       : Jg_Withholding_Prepay                                     *
 * Purpose    : Regional Extended Routine for Insertion on Prepay line    *
 *                                                                        *
 **************************************************************************/

FUNCTION Jg_Ext_Withholding_Prepay
               (P_prepay_dist_id      IN Number,
          	P_invoice_id          IN Number,
                -- Bug 4559474 : R12 KI
                P_inv_dist_id         IN Number,
          	P_user_id             IN Number,
          	P_last_update_login   IN Number,
                P_calling_sequence    IN Varchar2
                )
RETURN NUMBER
IS

l_country_code            VARCHAR2(10);
l_calling_sequence        VARCHAR2(2000);

l_ou_id                   NUMBER;

BEGIN
    ------------------------
     --  Return the value in P_calling_sequece.
     -----------------------
     l_calling_sequence := p_calling_sequence||'Jg_Ext_Withholding_Prepay';
    ------------------------
    -- Get the Country Code
    ------------------------
    --fnd_profile.get('ORG_ID',l_ou_id);

    l_ou_id  :=  MO_GLOBAL.get_current_org_id;				--bug 8501685

    l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL);

    ------------------------------------------------
    -- Execute the Argentine/Colombian Withholding
    -- Tax Defaulting Prepayment Routine
    ------------------------------------------------
    IF (l_country_code = 'AR' OR
        l_country_code = 'CO') THEN

        --
        -- Bug 4559474 : R12 KI
        --
        Jl_Zz_Ap_Awt_Default_PKG.Carry_Withholdings_Prepay(
                                                           P_prepay_dist_id,
                                                           P_Invoice_Id,
                                                           -- Bug 4559474
                                                           P_inv_dist_id,
                                                           P_user_id,
                                                           P_last_update_login,
                                                           P_calling_sequence
                                                           );
    END IF;

    ----------------------------
    -- Return AWT Success Value
    ----------------------------
    RETURN Ap_Extended_Withholding_Pkg.TRUE_VALUE;

END JG_EXT_WITHHOLDING_PREPAY;

END JG_EXTENDED_WITHHOLDING_PKG;

/
