--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AP_WITHHOLDING_PKG" AS
/* $Header: jlzzpwhb.pls 120.22.12010000.7 2010/04/22 06:09:13 mkandula ship $ */



/**************************************************************************
 *                   Private Procedure Specification                      *
 **************************************************************************/
-- Define Package Level Debug Variable and Assign the Profile
-- DEBUG_Var varchar2(1) := NVL(FND_PROFILE.value('EXT_AWT_DEBUG_FLAG'), 'N');
   DEBUG_Var varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/**************************************************************************
 *                                                                        *
 * Name       : Get_Period_Name                                           *
 * Purpose    : Returns the name of the AWT period for a particular tax   *
 *              name and period type                                      *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Period_Name
              (P_Tax_Name                IN      Varchar2,
               P_Period_Type             IN      Varchar2,
               P_AWT_Date                IN      Date,
               P_Calling_Sequence        IN      Varchar2,
               P_AWT_Success             OUT NOCOPY     Varchar2)
               RETURN Varchar2;




/**************************************************************************
 *                                                                        *
 * Name       : Get_Cumulative_Figures                                    *
 * Purpose    : Obtains the cumulative gross amount to date and the       *
 *              cumulative withheld amount to date for a particular       *
 *              supplier, tax name and period.                            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Get_Cumulative_Figures
                  (P_Vendor_Id                 IN     Number,
                   P_Tax_Name                  IN     Varchar2,
                   P_AWT_Period_Type           IN     Varchar2,
                   P_AWT_Date                  IN     Date,
                   P_Calling_Sequence          IN     Varchar2,
                   P_Gross_Amount_To_Date      OUT NOCOPY    Number,
                   P_Withheld_Amount_To_Date   OUT NOCOPY    Number,
                   P_AWT_Success               OUT NOCOPY    Varchar2);




/**************************************************************************
 *                                                                        *
 * Procedure  : Get_Tax_Rate                                              *
 * Description: Obtains the tax rate for the current tax name and for the *
 *              calculated taxable base amount.                           *
 *                                                                        *
 **************************************************************************/
PROCEDURE Get_Tax_Rate
                 (P_Tax_Name              IN     Varchar2,
                  P_Date                  IN     Date,
                  P_Taxable_Base_Amount   IN     Number,
                  P_Calling_Sequence      IN     Varchar2,
                  P_Rec_AWT_Rate          OUT NOCOPY    Rec_AWT_Rate,
                  P_AWT_Success           OUT NOCOPY    Varchar2);




/**************************************************************************
 *                                                                        *
 * Name       : Update_Withheld_Amount                                    *
 * Purpose    : Prorates the withheld amount for each tax name included   *
 *              into the PL/SQL table. These values will also be rounded. *
 *                                                                        *
 **************************************************************************/
PROCEDURE Update_Withheld_Amount
               (P_Original_Withheld_Amt  IN     Number,
                P_Updated_Withheld_Amt   IN     Number,
                P_Currency_Code          IN     Varchar2,
                P_Calling_Sequence       IN     Varchar2,
                P_Tab_Withhold           IN OUT NOCOPY Tab_Withholding);




/**************************************************************************
 *                                                                        *
 * Name       : Get_Revised_Tax_Base_Amount                               *
 * Purpose    : 1 Retrieves the taxable base amount from the PL/SQL table *
 *              2 Applies all the validations like income tax rate,       *
 *                reduction percentage etc., and generates a revised      *
 *                taxable base amount.                                    *
 *              3 Updates the PL/SQL table to store the revised amount    *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Revised_Tax_Base_Amount
                (P_Rec_AWT_Name                 IN      Rec_AWT_CODE,
                 P_Tab_Withhold                 IN OUT NOCOPY  Tab_Withholding,
                 P_Tax_Name_From                IN      Number,
                 P_Tax_Name_To                  IN      Number,
                 P_Taxable_Base_Amount          IN      Number,
                 P_Tab_All_Withhold             IN      Tab_All_Withholding,
                 P_Calling_Sequence             IN      Varchar2)
                 RETURN NUMBER;




/**************************************************************************
 *                                                                        *
 * Name       : Bool_To_Char                                              *
 * Purpose    : Converts the Boolean value received as a parameter to a   *
 *              Varchar2 character string. This function is only used     *
 *              for debug purposes.                                       *
 *                                                                        *
 **************************************************************************/
FUNCTION Bool_To_Char (P_Bool_Value IN Boolean)
                       RETURN Varchar2;

/**************************************************************************
 *                                                                        *
 * Name       : Get_Cumulative_Supp_Exemp                                 *
 * Purpose    : Obtains the cumulative supplier's exemption amount        *
 *              to date for a particular period                           *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Cumulative_Supp_Exemp
                  (P_Vendor_Id                 IN     Number,
                   P_Tax_Name                  IN     Varchar2,
                   P_AWT_Period_Type           IN     Varchar2,
                   P_AWT_Date                  IN     Date,
                   P_Calling_Sequence          IN     Varchar2)
         RETURN NUMBER;

/**************************************************************************
 *                          Public Procedures                             *
 **************************************************************************/



/**************************************************************************
 *                                                                        *
 * Name       : Get_Withholding_Options                                   *
 * Purpose    : Obtains all the withholding setup options from AP_SYSTEM_ *
 *              PARAMETERS table                                          *
 *                                                                        *
 **************************************************************************/
PROCEDURE Get_Withholding_Options (P_Create_Distr     OUT NOCOPY    Varchar2,
                                   P_Create_Invoices  OUT NOCOPY    Varchar2)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_create_distr           Varchar2(25);
    l_create_invoices        Varchar2(25);
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Withholding_Options';

    ----------------------------
    -- Obtains Payables Options
    ----------------------------
    SELECT  nvl(create_awt_dists_type, 'NEVER'),
            nvl(create_awt_invoices_type, 'NEVER')
    INTO    l_create_distr,
            l_create_invoices
    FROM    ap_system_parameters;

    P_Create_Distr    := l_create_distr;
    P_Create_Invoices := l_create_invoices;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS', 'NO INPUT ARGUMENTS');
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Withholding_Options;




/**************************************************************************
 *                                                                        *
 * Name       : Get_GL_Period_Name                                        *
 * Purpose    : Returns the period name for a particular date.            *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_GL_Period_Name (P_AWT_Date  IN  Date)
                             RETURN VARCHAR2
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_gl_period_name         Varchar2(15);
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_GL_Period_Name';

    ----------------------------------
    -- Obtains the name of the period
    ----------------------------------
    SELECT gps.period_name
    INTO   l_gl_period_name
    FROM   gl_period_statuses gps,
           ap_system_parameters asp
    WHERE  gps.application_id = 200
    AND    gps.set_of_books_id = asp.set_of_books_id
    AND    P_AWT_Date BETWEEN gps.start_date AND gps.end_date
    AND    gps.closing_status IN ('O', 'F');

    RETURN l_gl_period_name;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                     '  AWT Date= ' || to_char(P_AWT_Date,'YYYY/MM/DD'));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_GL_Period_Name;




/**************************************************************************
 *                                                                        *
 * Name       : Get_Base_Currency_Code                                    *
 * Purpose    : Returns the functional currency code (from AP_SYSTEM_     *
 *              PARAMETERS)                                               *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Base_Currency_Code RETURN VARCHAR2
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_base_currency_code     Varchar2(15);
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Base_Currency_Code';

    ------------------------------------
    -- Obtains functional currency code
    ------------------------------------
    SELECT base_currency_code
    INTO   l_base_currency_code
    FROM   ap_system_parameters;

    RETURN l_base_currency_code;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS', 'NO INPUT ARGUMENTS');
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Base_Currency_Code;




/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholding_Table                              *
 * Purpose    : Initialize the PL/SQL table to store the withholding tax  *
 *              names.                                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholding_Table (P_Wh_Table  IN OUT NOCOPY  Tab_Withholding)
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Initialize_Withholding_Table';

    -----------------------------------
    -- Initializing withholding table
    -----------------------------------
    IF (P_Wh_Table IS NOT NULL) THEN
        P_Wh_Table.DELETE;
    END IF;

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

END Initialize_Withholding_Table;




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
                   (P_AWT_Type_Code       IN   Varchar2,
                    P_Vendor_Id           IN   Number,
                    P_Rec_AWT_Type        OUT NOCOPY  jl_zz_ap_awt_types%ROWTYPE,
                    P_Rec_Suppl_AWT_Type  OUT NOCOPY  jl_zz_ap_supp_awt_types%ROWTYPE)
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Initialize_Withholding_Type';

    -----------------------------------------------------------
    -- Obtains all the attributes for the withholding tax type
    -----------------------------------------------------------
    l_debug_info := 'Obtains withholding tax type attributes';
    SELECT *
    INTO   P_Rec_AWT_Type
    FROM   jl_zz_ap_awt_types
    WHERE  awt_type_code = P_AWT_Type_Code;

    -----------------------------------------------------------
    -- Obtains all the attributes for the withholding tax type
    -- and for the supplier
    -----------------------------------------------------------
    l_debug_info := 'Obtains withholding tax type attributes for the supplier';
    SELECT *
    INTO   P_Rec_Suppl_AWT_Type
    FROM   jl_zz_ap_supp_awt_types
    WHERE  awt_type_code = P_AWT_Type_Code
    AND    vendor_id = P_Vendor_Id;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                   '  AWT Type Code= '      || P_AWT_Type_Code ||
                   ', Vendor Id= '          || to_char(P_Vendor_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Initialize_Withholding_Type;




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
                   P_CODE_ACCOUNTING_DATE  IN   DATE  Default  NULL)                -- Argentina AWT ER 6624809
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_glattr6                    Varchar2(150);
    l_glattr7                    Varchar2(150);
    l_glattr8                    Varchar2(150);
    l_glattr9                    Varchar2(150);
    l_glattr10                   Varchar2(150);
    l_glattr11                   Varchar2(150);
    l_glattr12                   Varchar2(150);
    l_glattr13                   Varchar2(150);
    l_glattr14                   Varchar2(150);
    l_glattr15                   Varchar2(150);
    l_glattr16                   Varchar2(150);
    l_glattr17                   Varchar2(150);
    l_glattr18                   Varchar2(150);
    l_attr1_type_error           Boolean := FALSE;
    l_attr2_type_error           Boolean := FALSE;
    l_attr3_type_error           Boolean := FALSE;
    l_debug_info                 Varchar2(300);
    l_calling_sequence           Varchar2(2000);
    Tax_Name_Attributes_Error    Exception;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Initialize_Withholding_Name';

    -----------------------------------------------------------
    -- Obtains all the attributes for the tax name
    -----------------------------------------------------------
    l_debug_info := 'Obtain all tax name attributes';
    SELECT tax_id,
           name,
           tax_code_combination_id,
           awt_period_type,
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
           global_attribute18
    INTO   P_AWT_Name.Tax_Id,
           P_AWT_Name.Name,
           P_AWT_Name.Tax_Code_Combination_Id,
           P_AWT_Name.AWT_Period_Type,
           l_glattr6,
           l_glattr7,
           l_glattr8,
           l_glattr9,
           l_glattr10,
           l_glattr11,
           l_glattr12,
           l_glattr13,
           l_glattr14,
           l_glattr15,
           l_glattr16,
           l_glattr17,
           l_glattr18
    FROM   ap_tax_codes
    WHERE  tax_id = P_Tax_Id;

    --------------------------
    -- Sets common attributes
    --------------------------
    BEGIN
        P_AWT_Name.Foreign_Rate_Ind := substr(l_glattr6,  1, 1);
        P_AWT_Name.Zone_Code        := substr(l_glattr7,  1, 30);
        P_AWT_Name.Item_Applic      := substr(l_glattr8,  1, 1);
        P_AWT_Name.Freight_Applic   := substr(l_glattr9,  1, 1);
        P_AWT_Name.Misc_Applic      := substr(l_glattr10, 1, 1);
        P_AWT_Name.Tax_Applic       := substr(l_glattr11, 1, 1);
        P_AWT_Name.Min_Tax_Base_Amt := fnd_number.canonical_to_number(l_glattr12);
        P_AWT_Name.Min_Withheld_Amt := fnd_number.canonical_to_number(l_glattr13);
    EXCEPTION
        WHEN others THEN
            l_attr1_type_error := TRUE;
    END;

    ---------------------------------
    -- Sets attributes for Argentina
    ---------------------------------
    BEGIN
        P_AWT_Name.Adj_Min_Base            := substr(l_glattr14, 1, 30);
        P_AWT_Name.Cumulative_Payment_Flag := substr(l_glattr15, 1, 1);
        P_AWT_Name.Tax_Inclusive           := substr(l_glattr16, 1, 1);
    EXCEPTION
        WHEN others THEN
            l_attr2_type_error := TRUE;
    END;

    ---------------------------------
    -- Sets attributes for Colombia
    ---------------------------------
    BEGIN
        P_AWT_Name.Income_Tax_Rate  := fnd_number.canonical_to_number(l_glattr14);
        P_AWT_Name.First_Tax_Type   := substr(l_glattr15, 1, 30);
        P_AWT_Name.Second_Tax_Type  := substr(l_glattr16, 1, 30);
        P_AWT_Name.Municipal_Type   := substr(l_glattr17, 1, 1);
        P_AWT_Name.Reduction_Perc   := fnd_number.canonical_to_number(l_glattr18);
    EXCEPTION
        WHEN others THEN
            l_attr3_type_error := TRUE;
    END;

    -------------------------------------------------
    -- Checks for any possible type conversion error
    -------------------------------------------------
    IF (l_attr1_type_error OR (l_attr2_type_error AND l_attr3_type_error)) THEN
        l_debug_info := 'Obtain tax name attributes';
        RAISE Tax_Name_Attributes_Error;
    END IF;

    -----------------------------------------------------------
    -- Obtains all the attributes for the tax name and for
    -- the supplier
    -----------------------------------------------------------
    l_debug_info := 'Obtain tax name attributes for the supplier';

    JL_ZZ_AP_EXT_AWT_UTIL.Debug ('ACCOUNTING_DATE_before1  = '||to_char(P_CODE_ACCOUNTING_DATE));   -- Argentina AWT ER 6624809

    IF P_CODE_ACCOUNTING_DATE IS NOT NULL then

      JL_ZZ_AP_EXT_AWT_UTIL.Debug ('ACCOUNTING_DATE_before2 = '||to_char(P_CODE_ACCOUNTING_DATE));

      SELECT *
      INTO   P_Rec_Suppl_AWT_Name
      FROM   jl_zz_ap_sup_awt_cd jlsc
      WHERE  jlsc.tax_id = P_Tax_Id                                                               -- Argentina AWT code change
      AND    jlsc.supp_awt_type_id =
                     (SELECT jlst.supp_awt_type_id
                      FROM   jl_zz_ap_supp_awt_types jlst
                      WHERE  jlst.awt_type_code = P_AWT_Type_Code
                      AND    jlst.vendor_id = P_Vendor_Id)
      AND   NVL(To_Date(P_CODE_ACCOUNTING_DATE),sysdate) between
                NVL(jlsc.effective_start_date,To_Date('01-01-1950', 'DD-MM-YYYY'))
      and NVL(jlsc.effective_end_date,To_Date('31-12-9999', 'DD-MM-YYYY'));


    ELSE

    JL_ZZ_AP_EXT_AWT_UTIL.Debug ('ACCOUNTING_DATE_after3 = '||to_char(P_CODE_ACCOUNTING_DATE));


      SELECT *
      INTO   P_Rec_Suppl_AWT_Name
      FROM   jl_zz_ap_sup_awt_cd jlsc
      WHERE  jlsc.tax_id = P_Tax_Id
      AND    jlsc.supp_awt_type_id =
                     (SELECT jlst.supp_awt_type_id
                      FROM   jl_zz_ap_supp_awt_types jlst
                      WHERE  jlst.awt_type_code = P_AWT_Type_Code
                      AND    jlst.vendor_id = P_Vendor_Id);

    END IF;                                                                                        -- Argentina AWT ER 6624809

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                  '  AWT Type Code= '    ||   P_AWT_Type_Code    ||
                  ', Tax Id= '           ||   to_char(P_Tax_Id)  ||
                  ', Vendor Id= '        ||   to_char(P_Vendor_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Initialize_Withholding_Name;




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
                P_Tax_Base_Amount_Basis    IN    Varchar2) RETURN NUMBER
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Taxable_Base_Amount';

    ----------------------------------------------------------------
    -- This procedure is no longer used for Argentina. It will only
    -- be called from the Colombian withholding calculation routine.
    -- Argentine calculation will call a private procedure to obtain
    -- taxable base amount.
    ----------------------------------------------------------------
    IF (P_Tax_Base_Amount_Basis = 'INVOICE') THEN
        RETURN P_Line_Amount;

    ELSIF (P_Tax_Base_Amount_Basis = 'PAYMENT') THEN
        RETURN P_Line_Amount * P_Payment_Amount / P_Invoice_Amount;

    END IF;

    RETURN 0;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
               '  Invoice Id= '             || to_char(P_Invoice_Id)     ||
               ', Distr Line No= '          || to_char(P_Distr_Line_No)  ||
               ', Line Amount= '            || to_char(P_Line_Amount)    ||
               ', Payment Amount= '         || to_char(P_Payment_Amount) ||
               ', Invoice Amount= '         || to_char(P_Invoice_Amount) ||
               ', Tax Base Amount Basis= '  || P_Tax_Base_Amount_Basis);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Taxable_Base_Amount;




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
-- By zmohiudd for bug 1849986 for handling null
                  P_Payment_Num          IN       Number Default null)
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_rec                    Rec_Withholding;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Store_Tax_Name';

    ----------------------------------------
    -- Stores the information into the table
    ----------------------------------------
    l_rec.invoice_id               := P_Invoice_Id;
    l_rec.invoice_distribution_id  := P_Distr_Line_No;
    l_rec.awt_type_code            := P_AWT_Type_Code;
    l_rec.jurisdiction_type        := P_Jurisdiction_Type;
    l_rec.tax_id                   := P_Tax_Id;
    l_rec.tax_name                 := P_Tax_Name;
    l_rec.tax_code_combination_id  := P_Tax_Code_Comb_id;
    l_rec.awt_period_type          := P_AWT_Period_Type;
    l_rec.rate_id                  := null;
    l_rec.line_amount              := P_Line_Amount;
    l_rec.taxable_base_amount      := P_Taxable_Base_Amount;
    l_rec.revised_tax_base_amount  := 0;
    l_rec.withheld_amount          := 0;
    l_rec.prorated_amount          := 0;
    l_rec.invoice_payment_id       := P_Invoice_Payment_Id;
    l_rec.payment_num              := P_Payment_Num;  -- By Zmohiudd for bug 1849986
    l_rec.applicable_flag          := 'Y';
    l_rec.exemption_amount         := 0;

    P_Tab_Withhold(P_Current_AWT)  := l_rec;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                 '  Current AWT= '         || to_char(P_Current_AWT)         ||
                 ', Invoice Id= '          || to_char(P_Invoice_Id)          ||
                 ', Distr Line No= '       || to_char(P_Distr_Line_No)       ||
                 ', AWT Type Code= '       || P_AWT_Type_Code                ||
                 ', Tax Id= '              || to_char(P_Tax_Id)              ||
                 ', Tax Name= '            || P_Tax_Name                     ||
                 ', Tax Code Comb Id= '    || to_char(P_Tax_Code_Comb_Id)    ||
                 ', AWT Period Type= '     || P_AWT_Period_Type              ||
                 ', Jurisdiction Type= '   || P_Jurisdiction_Type            ||
                 ', Line Amount= '         || to_char(P_Line_Amount)         ||
                 ', Taxable Base Amount= ' || to_char(P_Taxable_Base_Amount) ||
                 ', Invoice Payment Id= '  || to_char(P_Invoice_Payment_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Store_Tax_Name;




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
                P_AWT_Success         OUT NOCOPY     Varchar2)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_withholding_is_required     Boolean := TRUE;
    l_cumulative_gross_amount     Number  := 0;
    l_cumulative_withheld_amount  Number  := 0;
    l_taxable_base_amount         Number  := 0;
    l_subject_amount              Number  := 0;
    l_withheld_amount             Number  := 0;
    l_debug_info                  Varchar2(300);
    l_calling_sequence            Varchar2(2000);
    rec_tax_rate                  Rec_AWT_Rate;
    l_cum_exemption_amt           Number := 0;
    l_exemption_amount            Number := 0;
    l_tem_withheld_amount         Number := 0;

BEGIN

    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Process_Withholding_Name';

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Process_Withholding_Name');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Param: P_Vendor_Id: '||to_char(P_Vendor_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Param: Tax Name: '||P_Rec_AWT_Name.Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Param: Zone_Code: '||P_Rec_AWT_Name.Zone_Code);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Param: Min_Tax_Base_Amt: '||to_char(P_Rec_AWT_Name.Min_Tax_Base_Amt));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Param: Min_Withheld_Amt: '||to_char(P_Rec_AWT_Name.Min_Withheld_Amt));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Param: P_Tax_Name_From: '||to_char(P_Tax_Name_From));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' Param: P_Tax_Name_To: '||to_char(P_Tax_Name_To));
    END IF;
    -- End Debug

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    ---------------------------------------
    -- Obtains the cumulative gross amount
    -- and the cumulative withheld amount
    ---------------------------------------
    IF (nvl(P_Rec_AWT_Type.Cumulative_Payment_Flag, 'N') = 'Y'  AND
        nvl(P_Rec_AWT_Name.Cumulative_Payment_Flag, 'N') = 'Y') THEN

        Get_Cumulative_Figures(P_Vendor_Id,
                               P_Rec_AWT_Name.Name,
                               P_Rec_AWT_Name.AWT_Period_Type,
                               P_AWT_Date,
                               l_calling_sequence,
                               l_cumulative_gross_amount,
                               l_cumulative_withheld_amount,
                               P_AWT_Success);

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Cumulative_Figs P_Rec_AWT_Name.Name = '||P_Rec_AWT_Name.Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Cumulative_Figs P_Rec_AWT_Name.AWT_Period_Type = '||P_Rec_AWT_Name.AWT_Period_Type);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('    Param: l_cumulative_gross_amount: '||to_char(l_cumulative_gross_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('    Param: l_cumulative_withheld_amount: '||to_char(l_cumulative_withheld_amount));
    END IF;
    -- End Debug

         l_cum_exemption_amt := Get_Cumulative_Supp_Exemp
                                 (P_Vendor_Id,
                                  P_Rec_AWT_Name.Name,
                                  P_Rec_AWT_Name.AWT_Period_Type,
                                  P_AWT_Date,
                                  l_calling_sequence);

        l_cumulative_withheld_amount := l_cumulative_withheld_amount + l_cum_exemption_amt;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('  Cumulative_Figs After Get Exemption Amount');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('    Param: l_cumulative_withheld_amount: '||to_char(l_cumulative_withheld_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('    Param: l_cum_exemption_amt: '||to_char(l_cum_exemption_amt));
    END IF;
    -- End Debug

        IF (P_AWT_Success <> AWT_SUCCESS) THEN
            RETURN;
        END IF;

    END IF;


    -------------------------------------------------------
    -- Calculates the taxable base amount by summing up
    -- all the base amounts included into the PL/SQL table
    -------------------------------------------------------
    FOR i IN P_Tax_Name_From .. P_Tax_Name_To LOOP
        l_taxable_base_amount := l_taxable_base_amount +
                                 P_Tab_Withhold(i).taxable_base_amount;
    END LOOP;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Taxable base amount: l_taxable_base_amount = '||to_char(l_taxable_base_amount));
    END IF;
    -- End Debug

    ------------------------------------------------
    -- Calculates the amount subject to withholding
    ------------------------------------------------

    l_subject_amount := l_taxable_base_amount + l_cumulative_gross_amount;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Amount subject to withh: l_subject_amount = '||to_char(l_subject_amount));
    END IF;
    -- End Debug

    ---------------------------------------------------------------------
    -- Obtains the revised amount subject to withholding, if applicable.
    -- This procedure is invoked only for Remittance Tax Type.
    ---------------------------------------------------------------------
    IF (nvl(P_Rec_AWT_Type.user_defined_formula_flag,'N') = 'Y') THEN

        l_subject_amount := Get_Revised_Tax_Base_Amount
                                        (P_Rec_AWT_Name,
                                         P_Tab_Withhold,
                                         P_Tax_Name_From,
                                         P_Tax_Name_To,
                                         l_subject_amount,
                                         P_Tab_All_Withhold,
                                         l_calling_sequence);
    END IF;

    -------------------------------------
    -- Applies multilateral contribution
    -------------------------------------
    IF (nvl(P_Rec_AWT_Type.multilat_contrib_flag, 'N') = 'Y') THEN
        IF (nvl(P_Rec_Suppl_AWT_Type.multilat_start_date, P_AWT_Date) <=
            P_AWT_Date AND
            nvl(P_Rec_Suppl_AWT_Type.multilat_end_date, P_AWT_Date) >=
            P_AWT_Date AND
            P_Rec_Suppl_AWT_Type.multilateral_rate IS NOT NULL) THEN
            l_subject_amount := l_subject_amount *
                                P_Rec_Suppl_AWT_Type.multilateral_rate / 100;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Amount subject to withh for multilateral contribution ');
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Amount subject to withh MC: l_subject_amount = '||to_char(l_subject_amount));
            END IF;
            -- End Debug

        END IF;
    END IF;

    ------------------------------------------
    -- Checks the minimum taxable base amount
    ------------------------------------------
    IF (nvl(P_Rec_AWT_Type.min_tax_amount_level, 'N/A') = 'CATEGORY') THEN

       -------------------------------------------------
       -- Compares with the minimum taxable base amount
       -------------------------------------------------
       IF (ABS(l_subject_amount) < P_Rec_AWT_Name.Min_Tax_Base_Amt) THEN

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   l_subject_amount < P_Rec_AWT_Name.Min_Tax_Base_Amt');
            END IF;
            -- End Debug

           l_withholding_is_required := FALSE;

           -------------------------------------------------------
           -- Obtains the tax rate and its attributes. This rate
           -- will only be used to be able to insert distribution
           -- lines with zero withheld amount. The obtained tax
           -- rate will not be used by the calculation.
           -------------------------------------------------------
            Get_Tax_Rate (P_Rec_AWT_Name.Name,
                          P_AWT_Date,
                          P_Rec_AWT_Name.Min_Tax_Base_Amt,
                          l_calling_sequence,
                          rec_tax_rate,
                          P_AWT_Success);

            IF (P_AWT_Success <> AWT_SUCCESS) THEN
                RETURN;
            END IF;

       --------------------------------------------
       -- Subtract the minimum taxable base amount
       --------------------------------------------
       ELSIF (nvl(P_Rec_AWT_Name.Adj_Min_Base, 'X') = 'S') THEN
           l_subject_amount := l_subject_amount -
                               P_Rec_AWT_Name.Min_Tax_Base_Amt;

            -- Debug Information
            IF (DEBUG_Var = 'Y') THEN
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Subtract the minimum taxable base amount');
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   l_subject_amount = '||to_char(l_subject_amount));
               JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   P_Rec_AWT_Name.Min_Tax_Base_Amt = '||to_char(P_Rec_AWT_Name.Min_Tax_Base_Amt));
            END IF;
            -- End Debug

       END IF;

    END IF;


    IF (l_withholding_is_required) THEN

        -------------------------------------------
        -- Obtains the tax rate and its attributes
        -- which will be used by the calculation
        -------------------------------------------

        Get_Tax_Rate (P_Rec_AWT_Name.Name,
                      P_AWT_Date,
                      l_subject_amount,
                      l_calling_sequence,
                      rec_tax_rate,
                      P_AWT_Success);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Rate Information: Tax_Rate_Id = '||to_char(rec_tax_rate.Tax_Rate_Id));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Rate Information: Tax_Rate = '||to_char(rec_tax_rate.Tax_Rate));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Rate Information: Rate_Type = '||rec_tax_rate.Rate_Type);
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Rate Information: Amount_To_Subtract = '||to_char(rec_tax_rate.Amount_To_Subtract));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Rate Information: Amount_To_Add = '||to_char(rec_tax_rate.Amount_To_Add));
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
        END IF;
        -- End Debug

        IF (P_AWT_Success <> AWT_SUCCESS) THEN
            RETURN;
        END IF;

        ----------------------------------
        -- Calculates the withheld amount
        ----------------------------------
        l_withheld_amount := (l_subject_amount -
                              nvl(rec_tax_rate.amount_to_subtract, 0)) *
                              rec_tax_rate.Tax_Rate / 100 +
                              nvl(rec_tax_rate.amount_to_add, 0);

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Withheld amount: '||to_char(l_withheld_amount));
        END IF;
        -- End Debug

-- Added the changes for the bug 2211795 by zmohiudd..
        -----------------------------------------------------------
        -- Adjusts the withheld amount by subtracting the withheld
        -- amount of the period (only when cumulative payments are
        -- applicable)
        -----------------------------------------------------------

        l_withheld_amount := l_withheld_amount - l_cumulative_withheld_amount;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   l_withheld_amount := l_withheld_amount - l_cumulative_withheld_amount');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Withheld amount: '||to_char(l_withheld_amount));
        END IF;
        -- End Debug

        -------------------------------------------------
        -- Applies supplier exemptions at tax name level
        -------------------------------------------------
        IF (nvl(P_Rec_AWT_Type.supplier_exempt_level, 'N/A') = 'CATEGORY') THEN
            IF (nvl(P_Rec_Suppl_AWT_Name.exemption_start_date, P_AWT_Date) <=
                P_AWT_Date AND
                nvl(P_Rec_Suppl_AWT_Name.exemption_end_date, P_AWT_Date) >=
                P_AWT_Date AND
                P_Rec_Suppl_AWT_Name.exemption_rate IS NOT NULL) THEN

                l_tem_withheld_amount := l_withheld_amount * (1 -
                                 (P_Rec_Suppl_AWT_Name.exemption_rate / 100));
                l_exemption_amount := l_withheld_amount - l_tem_withheld_amount;
                l_withheld_amount  := l_tem_withheld_amount;

                -- Debug Information
                IF (DEBUG_Var = 'Y') THEN
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Applies Supplier Exemptions at Tax NAME Level');
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption Start Date = '||to_char(P_Rec_Suppl_AWT_Name.exemption_start_date));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption End Date = '||to_char(P_Rec_Suppl_AWT_Name.exemption_end_date));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption Rate = '||to_char(P_Rec_Suppl_AWT_Name.exemption_rate));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Withheld Amount: '||to_char(l_withheld_amount));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption Amount: '||to_char(l_exemption_amount));
                END IF;
                -- End Debug

            END IF;
        END IF;

        -------------------------------------------------
        -- Applies supplier exemptions at tax type level
        -------------------------------------------------
        IF (nvl(P_Rec_AWT_Type.supplier_exempt_level, 'N/A') = 'TYPE') THEN
            IF (nvl(P_Rec_Suppl_AWT_Type.exemption_start_date, P_AWT_Date) <=
                P_AWT_Date AND
                nvl(P_Rec_Suppl_AWT_Type.exemption_end_date, P_AWT_Date) >=
                P_AWT_Date AND
                P_Rec_Suppl_AWT_Type.exemption_rate IS NOT NULL) THEN

                l_tem_withheld_amount := l_withheld_amount * (1 -
                                        (P_Rec_Suppl_AWT_Type.exemption_rate / 100));
                l_exemption_amount := l_withheld_amount - l_tem_withheld_amount;
                l_withheld_amount  := l_tem_withheld_amount;

                -- Debug Information
                IF (DEBUG_Var = 'Y') THEN
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Applies supplier exemptions at tax TYPE level');
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption Start Date = '||to_char(P_Rec_Suppl_AWT_Type.exemption_start_date));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption End Date = '||to_char(P_Rec_Suppl_AWT_Type.exemption_end_date));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption Rate = '||to_char(P_Rec_Suppl_AWT_Type.exemption_rate));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Withheld Amount: '||to_char(l_withheld_amount));
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Exemption Amount: '||to_char(l_exemption_amount));
                END IF;
                -- End Debug

            END IF;
        END IF;

--This part of the code is commented and moved above for bug2211795 by zmohiudd.
/*
        -----------------------------------------------------------
        -- Adjusts the withheld amount by subtracting the withheld
        -- amount of the period (only when cumulative payments are
        -- applicable)
        -----------------------------------------------------------

        l_withheld_amount := l_withheld_amount - l_cumulative_withheld_amount;
*/

        --------------------------------------
        -- Checks the minimum withheld amount
        --------------------------------------
        IF (nvl(P_Rec_AWT_Type.min_wh_amount_level, 'N/A') = 'CATEGORY') THEN

           ---------------------------------------------
           -- Compares with the minimum withheld amount
           ---------------------------------------------
           IF (ABS(l_withheld_amount) < P_Rec_AWT_Name.Min_Withheld_Amt) THEN

                -- Debug Information
                IF (DEBUG_Var = 'Y') THEN
                   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Withheld Amount is less that  P_Rec_AWT_Name.Min_Withheld_Amt');
                END IF;
                -- End Debug

               l_withholding_is_required := FALSE;

           END IF;

        END IF;

    END IF;


    -------------------------------------------------------
    -- Updates the amounts contained into the PL/SQL table
    -- in order to store the withheld amount (and the used
    -- tax rate)
    -------------------------------------------------------
    FOR i IN P_Tax_Name_From .. P_Tax_Name_To LOOP
        P_Tab_Withhold(i).rate_id := rec_tax_rate.Tax_Rate_Id;
        IF (l_withholding_is_required) THEN
            P_Tab_Withhold(i).withheld_amount  := l_withheld_amount;
            P_Tab_Withhold(i).applicable_flag  := 'Y';
            P_Tab_Withhold(i).exemption_amount := l_exemption_amount;
        ELSE
            P_Tab_Withhold(i).withheld_amount := 0;
            P_Tab_Withhold(i).applicable_flag := 'N';
        END IF;
    END LOOP;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
               '  Vendor Id= '        || to_char(P_Vendor_Id)      ||
               ', AWT Date= '         || to_char(P_AWT_Date,'YYYY/MM/DD')       ||
               ', Tax Name From= '    || to_char(P_Tax_Name_From)  ||
               ', Tax Name To= '      || to_char(P_Tax_Name_To));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Process_Withholding_Name;




/**************************************************************************
 *                                                                        *
 * Name       : Prorate_Withholdings                                      *
 * Purpose    : Prorates all the withholdings included into the PL/SQL    *
 *              table.                                                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Prorate_Withholdings
                    (P_Tab_Withhold         IN OUT NOCOPY Tab_Withholding,
                     P_Currency_Code        IN     Varchar2)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_previous_tax_id             Number       := null;
    l_taxable_base_amount         Number       := 0;
    l_initial_tax_name            Number       := 1;
    l_cumulative_wh_amount        Number       := 0;
    l_debug_info                  Varchar2(300);
    l_calling_sequence            Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Prorate_Withholdings';

    --------------------------------------------
    -- Checks whether there is at least one tax
    --------------------------------------------
    IF (P_Tab_Withhold.COUNT <= 0) THEN
        -- Nothing to do
        RETURN;
    END IF;

    ---------------------------------------------
    -- Prorates the withheld amounts by tax name
    ---------------------------------------------
    l_previous_tax_id :=  P_Tab_Withhold(1).tax_id;
    FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP

        IF (P_Tab_Withhold(i).tax_id <> l_previous_tax_id) THEN

            ---------------------------------------------
            -- Prorates amounts for the current tax name
            ---------------------------------------------
            l_cumulative_wh_amount := 0;
            FOR j IN l_initial_tax_name .. (i - 1) LOOP
                IF (l_taxable_base_amount = 0) THEN
                    P_Tab_Withhold(j).prorated_amount := 0;
                ELSE
                    -------------------------------------------
                    -- Prorates amount except for the last one
                    -------------------------------------------
                    IF (j < (i-1)) THEN
                        P_Tab_Withhold(j).prorated_amount :=
                                  P_Tab_Withhold(j).taxable_base_amount *
                                  P_Tab_Withhold(j).withheld_amount /
                                  l_taxable_base_amount;

                        P_Tab_Withhold(j).prorated_amount :=
                                  Ap_Utilities_Pkg.Ap_Round_Currency
                                       (P_Tab_Withhold(j).prorated_amount,
                                        P_Currency_Code);

                        l_cumulative_wh_amount := l_cumulative_wh_amount +
                                        P_Tab_Withhold(j).prorated_amount;

                    -----------------------------------------------
                    -- Calculates prorated amount for the last one
                    -----------------------------------------------
                    ELSE
                        P_Tab_Withhold(j).prorated_amount :=
                                       P_Tab_Withhold(j).withheld_amount -
                                       l_cumulative_wh_amount;
                    END IF;

                END IF;
            END LOOP;

            ------------------------------------
            -- Initializes auxiliary variables
            ------------------------------------
            l_previous_tax_id := P_Tab_Withhold(i).tax_id;
            l_taxable_base_amount := 0;
            l_initial_tax_name := i;

        END IF;

        --------------------------------------------
        -- Calculates total taxable base amount by
        -- tax name
        --------------------------------------------
        l_taxable_base_amount := l_taxable_base_amount +
                                 P_Tab_Withhold(i).taxable_base_amount;
    END LOOP;

    --------------------------
    -- Prorates last tax name
    --------------------------
    l_cumulative_wh_amount := 0;
    FOR j IN l_initial_tax_name .. P_Tab_Withhold.COUNT LOOP
        IF (l_taxable_base_amount = 0) THEN
            P_Tab_Withhold(j).prorated_amount := 0;
        ELSE
            -------------------------------------------
            -- Prorates amount except for the last one
            -------------------------------------------
            IF (j < P_Tab_Withhold.COUNT) THEN
                P_Tab_Withhold(j).prorated_amount :=
                          P_Tab_Withhold(j).taxable_base_amount *
                          P_Tab_Withhold(j).withheld_amount /
                          l_taxable_base_amount;

                P_Tab_Withhold(j).prorated_amount :=
                          Ap_Utilities_Pkg.Ap_Round_Currency
                               (P_Tab_Withhold(j).prorated_amount,
                                P_Currency_Code);

                l_cumulative_wh_amount := l_cumulative_wh_amount +
                                P_Tab_Withhold(j).prorated_amount;

            -----------------------------------------------
            -- Calculates prorated amount for the last one
            -----------------------------------------------
            ELSE
                P_Tab_Withhold(j).prorated_amount :=
                               P_Tab_Withhold(j).withheld_amount -
                               l_cumulative_wh_amount;
            END IF;

        END IF;
   END LOOP;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                          '  Currency Code= ' || P_Currency_Code);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Prorate_Withholdings;




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
               P_NIT_Number               IN     Varchar2   Default null)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_invoice_id               Number := null;
    l_tax_id                   Number := null;
    l_tax_name                 Varchar2(15);
    l_tax_code_comb_id         Number;
    l_awt_period_type          Varchar2(15);
    l_awt_period_name          Varchar2(15);
    l_tax_rate_id              Number;
    l_gross_amount             Number := 0;
    l_withheld_amount          Number := 0;
    l_applicable_flag          Varchar2(10);
    l_invoice_payment_id       Number;
    l_handle_bucket            Varchar2(10);
    l_debug_info               Varchar2(300);
    l_calling_sequence         Varchar2(1000);
    l_temerr                   Varchar2(100);
--  By zmohiudd for 1849986
    l_payment_num              Number;
    l_exemption_amount         Number;
    l_awt_related_id           Number; -- Bug 6347255
    l_line_type                Varchar2(25); -- Bug 7491394
    l_related_id               Number := null; -- Bug 7491394
BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Store_Into_Temporary_Table';

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('PROCEDURE Store_Into_Temporary_Table');
       JL_ZZ_AP_EXT_AWT_UTIL.Print_Tax_Names(P_Tab_Withhold);
    END IF;
    -- End Debug

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    ----------------------------------
    -- Defines the initial Save Point
    ----------------------------------
    SAVEPOINT Before_Inserting_Lines;

    --------------------------------------------
    -- Checks whether there is at least one tax
    --------------------------------------------
    IF (P_Tab_Withhold.COUNT <= 0) THEN
        -- Nothing to do
        RETURN;
    END IF;

    ---------------------------
    -- Sets handle bucket flag
    ---------------------------
    IF (P_Handle_Bucket) THEN
       l_handle_bucket := 'Y';
    ELSE
       l_handle_bucket := 'N';
    END IF;

  --------------------------------------------
  -- Bug 7491394: Start of logic flow changes
  --------------------------------------------

  FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP

  -----------------------------------
  -- Initializes auxiliary variables
  -----------------------------------
  l_invoice_id         := P_Tab_Withhold(i).invoice_id;
  l_tax_id             := P_Tab_Withhold(i).tax_id;
  l_tax_name           := P_Tab_Withhold(i).tax_name;
  l_tax_code_comb_id   := P_Tab_Withhold(i).tax_code_combination_id;
  l_awt_period_type    := P_Tab_Withhold(i).awt_period_type;
-- Bug 7491394  l_awt_related_id     := P_Tab_Withhold(i).invoice_distribution_id; -- Bug 6347255
  l_tax_rate_id        := P_Tab_Withhold(i).rate_id;
  l_invoice_payment_id := P_Tab_Withhold(i).invoice_payment_id;
  l_applicable_flag    := P_Tab_Withhold(i).applicable_flag;
  l_exemption_amount   := P_Tab_Withhold(i).exemption_amount;
  -- By zmohiudd for Bug1849986
  l_payment_num := P_Tab_Withhold(i).payment_num;

  -----------------------------------
  -- Bug 7491394: ERV changes start
  -----------------------------------
  select line_type_lookup_code, related_id
    into l_line_type, l_related_id
    from ap_invoice_distributions
   where invoice_distribution_id = P_Tab_Withhold(i).invoice_distribution_id;

  IF l_line_type = 'ERV' THEN
     l_awt_related_id := l_related_id;
  ELSE
     l_awt_related_id := P_Tab_Withhold(i).invoice_distribution_id;
  END IF;
  -----------------------------------
  -- Bug 7491394: ERV changes end
  -----------------------------------

  -----------------------------------
  -- Check Withholding applicability
  -----------------------------------

  IF (P_Zero_WH_Applicable OR l_applicable_flag = 'Y') THEN

    l_awt_period_name    := Get_Period_Name(l_tax_name,
                                            l_awt_period_type,
                                            P_AWT_Date,
                                            l_calling_sequence,
                                            P_AWT_Success);

    IF (P_AWT_Success <> AWT_SUCCESS) THEN
        ROLLBACK TO Before_Inserting_Lines;
        RETURN;
    END IF;

    -----------------------
    -- Stores gross amount
    -----------------------
    IF (P_Revised_Amount_Flag) THEN
        l_gross_amount := P_Tab_Withhold(i).revised_tax_base_amount;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Stores Gross Amount if P_Revised_Amount_Flag');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Gross Amount = '||to_char(l_gross_amount));
        END IF;
        -- End Debug

    ELSE
        l_gross_amount := P_Tab_Withhold(i).taxable_base_amount;

           -- Debug Information
           IF (DEBUG_Var = 'Y') THEN
              JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
              JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Stores gross amount if NOT P_Revised_Amount_Flag');
              JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Gross Amount = '||to_char(l_gross_amount));
           END IF;
           -- End Debug

    END IF;

    --------------------------
    -- Stores withheld amount
    --------------------------
    IF (P_Prorated_Amount_Flag) THEN
        l_withheld_amount := P_Tab_Withhold(i).prorated_amount;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Stores Withheld Amount if P_Prorated_Amount_Flag');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Withheld Amount = '||to_char(l_withheld_amount));
        END IF;
        -- End Debug

    ELSE
        l_withheld_amount := P_Tab_Withhold(i).withheld_amount;

        -- Debug Information
        IF (DEBUG_Var = 'Y') THEN
           JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Stores Withheld Amount if NOT P_Prorated_Amount_Flag');
           JL_ZZ_AP_EXT_AWT_UTIL.Debug ('   Withheld Amount = '||to_char(l_withheld_amount));
        END IF;
        -- End Debug

    END IF;

    ------------------------------------------------------
    -- Inserts temporary distribution lines
    -- Changed from dynamic to static call.  Bug# 2107329
    ------------------------------------------------------

                -- Bug 5257162
                IF l_withheld_amount = 0 and l_exemption_amount > 0 THEN
                   l_exemption_amount:= 0;
                END IF;

                Ap_Calc_Withholding_Pkg.Insert_Temp_Distribution
                          (l_invoice_id,
                           P_Vendor_Id,
                           -- By zmohiudd Bug1849986 changed P_Payment_Num to l_Payment_Num
                           nvl(l_Payment_Num,P_PAYMENT_NUM),
                           -1,                    -- Group ID
                           l_tax_name,
                           l_tax_code_comb_id,
                           l_gross_amount,
                           l_withheld_amount,
                           P_AWT_Date,
                           P_GL_Period_Name,
                           l_awt_period_type,
                           l_awt_period_name,
                           -- l_awt_related_id, Commented for bug 6885098
                           P_Checkrun_Name,
                           l_tax_rate_id,
                           null,
                           P_Base_Currency_Code,
                           P_Base_Currency_Code,
                           null,                   -- Offset
                           l_calling_sequence,
                           l_handle_bucket,
                           P_Last_Updated_By,
                           P_Last_Update_Login,
                           P_Program_Application_Id,
                           P_Program_Id,
                           P_Request_Id,
                           P_Calling_Module,
                           l_invoice_payment_id,
                           null,                   -- Invoice exchange rate
                           P_Global_Attr_Category, -- Global attribute category
                           null,                   -- Global attribute1
                           P_NIT_Number,           -- Global Attribute2
                           null,                   -- Global Attribute3
                           null,                   -- Global Attribute4
                           l_exemption_amount,   -- Global Attribute5
                           P_checkrun_id => p_checkrun_id,
                           P_awt_related_id => l_awt_related_id); --Added for 6885098

  END IF;  -- P_Zero_WH_Applicable

  END LOOP;

  ------------------------------------------
  -- Bug 7491394: End of logic flow changes
  ------------------------------------------

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
            '  Vendor Id= '           || to_char(P_Vendor_Id)                 ||
            ', AWT Date= '            || to_char(P_AWT_Date,'YYYY/MM/DD')                  ||
            ', GL Period Name= '      || P_GL_Period_Name                     ||
            ', Base Currency Code= '  || P_Base_Currency_Code                 ||
            ', Revised Amount Flag= ' || Bool_To_Char(P_Revised_Amount_Flag)  ||
            ', Prorated Amount Flag= '|| Bool_To_Char(P_Prorated_Amount_Flag) ||
            ', Zero WH Applicable= '  || Bool_To_Char(P_Zero_WH_Applicable)   ||
            ', Handle Bucket= '       || Bool_To_Char(P_Handle_Bucket)        ||
            ', Calling Module= '      || P_Calling_Module                     ||
            ', Checkrun Name= '       || P_Checkrun_Name                      ||
            ', Payment Num= '         || to_char(P_Payment_Num)               ||
            ', Global Attr Category= '|| P_Global_Attr_Category               ||
            ', NIT Number= '          || P_NIT_Number);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Store_Into_Temporary_Table;



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
                P_Tab_Withhold         IN OUT NOCOPY  Tab_Withholding)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_previous_wh_amount          Number;
    l_withheld_amount             Number       := 0;
    l_previous_tax_id             Number       := null;
    l_withholding_is_required     Boolean      := TRUE;
    l_debug_info                  Varchar2(300);
    l_calling_sequence            Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Process_Withholding_Type';

    -------------------------------------------
    -- Calculates the withheld amount for the
    -- withholding tax type
    -------------------------------------------
    FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP
        IF (l_previous_tax_id IS NULL OR
            P_Tab_Withhold(i).tax_id <> l_previous_tax_id) THEN
            l_withheld_amount := l_withheld_amount +
                                 P_Tab_Withhold(i).withheld_amount;
            l_previous_tax_id := P_Tab_Withhold(i).tax_id;
        END IF;
    END LOOP;

    ---------------------------------
    -- Store current withheld amount
    ---------------------------------
    l_previous_wh_amount := l_withheld_amount;

    --------------------------------------
    -- Checks the minimum withheld amount
    --------------------------------------
    IF (nvl(P_Rec_AWT_Type.min_wh_amount_level, 'N/A') = 'TYPE') THEN
       IF (ABS(l_withheld_amount) < P_Rec_AWT_Type.min_wh_amount) THEN
           l_withholding_is_required := FALSE;
       END IF;
    END IF;

    ----------------------------------------------------
    -- Updates the tax name information stored into the
    -- PL/SQL table
    ----------------------------------------------------
    IF (NOT l_withholding_is_required) THEN
        FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP
            P_Tab_Withhold(i).withheld_amount := 0;
            P_Tab_Withhold(i).applicable_flag := 'N';
        END LOOP;
    ELSE
        Update_Withheld_Amount (l_previous_wh_amount,
                                l_withheld_amount,
                                P_Currency_Code,
                                l_calling_sequence,
                                P_Tab_Withhold);
    END IF;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                   '  AWT Date= '       || to_char(P_AWT_Date,'YYYY/MM/DD')  ||
                   ', Currency Code= '  || P_Currency_Code);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Process_Withholding_Type;




/**************************************************************************
 *                                                                        *
 * Name       : Store_Prorated_Withholdings                               *
 * Purpose    : Transfers the Prorated Withholding details, from one      *
 *              PL/SQL table to another                                   *
 *                                                                        *
 **************************************************************************/
PROCEDURE Store_Prorated_Withholdings
                (P_Tab_Withhold         IN      Tab_Withholding,
                 P_Tab_All_Withhold     IN OUT NOCOPY  Tab_All_Withholding)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_last_rec_number        Number:=0;
    pos                      Number;
    tab                      Tab_Withholding := P_Tab_Withhold;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN

    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Store_Prorated_Withholdings';

    ------------------------------------------------------
    -- Obtains the last record number of the PL/SQL table
    ------------------------------------------------------
    l_last_rec_number := P_Tab_All_Withhold.COUNT;
    pos := l_last_rec_number;

    -----------------------------------------
    -- Stores the information into the table
    -----------------------------------------
    FOR i IN 1..tab.COUNT LOOP
        pos := pos + 1;
        P_Tab_All_Withhold(pos).invoice_id :=
                                         tab(i).invoice_id;
        P_Tab_All_Withhold(pos).invoice_distribution_id :=
                                         tab(i).invoice_distribution_id;
        P_Tab_All_Withhold(pos).awt_type_code :=
                                         tab(i).awt_type_code;
        P_Tab_All_Withhold(pos).tax_id :=
                                         tab(i).tax_id;
        P_Tab_All_Withhold(pos).jurisdiction_type :=
                                         tab(i).jurisdiction_type;
        P_Tab_All_Withhold(pos).prorated_amount :=
                                         tab(i).prorated_amount;
     END LOOP;

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

END Store_Prorated_Withholdings;




/**************************************************************************
 *                                                                        *
 * Name       : Print_Tax_Names                                           *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/

PROCEDURE Print_Tax_Names (P_Tab_Payment_Wh    IN   Tab_Withholding)
IS
    tab   Tab_Withholding := P_Tab_Payment_Wh;
    pos   Number;


BEGIN
   NULL;
END Print_Tax_Names;




/**************************************************************************
 *                                                                        *
 * Name       : Jl_Zz_Ap_Extended_Match                                   *
 * Purpose    : Regional Extended Routine for Matching                    *
 *                                                                        *
 **************************************************************************/
--
-- Bug 4559478 : R12 KI
--
PROCEDURE Jl_Zz_Ap_Extended_Match
                    (P_Credit_Id              IN     Number,
                     P_Invoice_Id             IN     Number     Default null,
                     -- Bug 4559478
                     P_Inv_Line_Num           IN     Number     Default null,
                     P_Distribution_id        IN     Number     Default null,
                     P_Parent_Dist_ID         IN     Number     Default null)
IS

 ------------------------------
 -- Local variables definition
 ------------------------------
 l_parent_dist_num       Varchar2(100);

 -- Bug 4559478
 -- l_dist_line_num         ap_invoice_distributions.invoice_distribution_id%TYPE;
 l_inv_dist_id           ap_invoice_distributions.invoice_distribution_id%TYPE;

 l_po_distribution_id    ap_invoice_distributions.po_distribution_id%TYPE;
 l_ship_to_location_id   po_line_locations.ship_to_location_id%TYPE;
 l_debug_info            Varchar2(300);
 l_calling_sequence      Varchar2(2000);
 v_country_code          Varchar2(100);

 l_ou_id                 Number;

 ---------------
 -- WHO Columns
 ---------------
 v_last_update_by        NUMBER;
 v_last_update_login     NUMBER;

 --------------------------------------------------------
 -- Cursor to select all distribution lines for which the
 -- tax names has to be associated
 ---------------------------------------------------------
 --
 -- Bug 4559478
 --
/*
 CURSOR c_distributions(P_Credit_Id     Number,
                        P_Inv_Line_Num  Number)
 IS
 SELECT apid.invoice_distribution_id,
        apid.po_distribution_id,
        apid.global_attribute20     -- What is gdf20?
 FROM   ap_invoice_distributions    apid
 WHERE  apid.invoice_id = P_Credit_Id
 AND    apid.invoice_line_number = P_Inv_Line_Num;
*/

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Jl_Zz_Ap_Extended_Match';

    -------------------------------------------------------
    --  Get the information of WHO Columns from FND_GLOBAL
    -------------------------------------------------------
    v_last_update_by := FND_GLOBAL.User_ID;
    v_last_update_login := FND_GLOBAL.Login_Id;

    --------------------------------------------------------------------
    -- If distribution lines are created by matching against an invoice
    --------------------------------------------------------------------
    l_debug_info := 'Distribution lines are created by matching ' ||
                    'against an invoice';


  /* No need to loop if all parameters are passed.

   -- Bug 4559478
   -- Passing P_Inv_Line_Num in stead of P_Start_Dist_Line_Num
   OPEN c_distributions(nvl(P_Credit_Id,P_Invoice_Id),
                        P_Inv_Line_Num);

   ----------------------------------------
   -- Loop for each distribution obtained
   ----------------------------------------
   LOOP

        FETCH c_distributions INTO l_inv_dist_id,
                                   l_po_distribution_id,
                                   l_parent_dist_num;  -- ap_dist.gdf20
        EXIT WHEN c_distributions%NOTFOUND;
*/
        ---------------------------------------------------------------
        -- Creates lines in JL_ZZ_AP_INV_DIS_WH_ALL table for the
        -- distribution lines created in ap_invoice_distributions
        ---------------------------------------------------------------
        IF (P_Parent_Dist_ID IS NOT NULL) THEN

            ----------------------------------------------------------
            -- Copies the tax names from the parent distribution line
            ----------------------------------------------------------
            INSERT INTO jl_zz_ap_inv_dis_wh (
                         inv_distrib_awt_id
                        ,invoice_id
                        -- Bug 4559478
                        ,invoice_distribution_id
                        ,distribution_line_number
                        ,supp_awt_code_id
                        ,created_by
                        ,creation_date
                        ,last_updated_by
                        ,last_update_date
                        ,last_update_login
                        ,org_id
                        )
            SELECT
                        jl_zz_ap_inv_dis_wh_s.nextval
                        ,P_Credit_Id
                        ,P_distribution_id
                        -- Bug 4559478 : -99 for distribution_line_number
                        ,-99
                        ,jlid.Supp_Awt_Code_Id
                        ,v_last_update_by
                        ,sysdate
                        ,v_last_update_by
                        ,sysdate
                        ,v_last_update_login
                        ,jlid.org_id
            FROM
                        jl_zz_ap_inv_dis_wh       jlid
            WHERE       jlid.invoice_distribution_id = P_Parent_Dist_ID
            AND         jlid.invoice_id = P_Invoice_Id;


        ELSE
/*
            ----------------------------------------------------------
            -- Obtains the ship to location for the distribution line
            ----------------------------------------------------------
            SELECT poll.ship_to_location_id
            INTO   l_ship_to_location_id
            FROM   po_line_locations poll
            WHERE  line_location_id = (SELECT line_location_id
                                       FROM   po_distributions
                                       WHERE  po_distribution_id = l_po_distribution_id);
*/

            ----------------------------------------------------------------
            -- Get the country code to update the global attribute category
            ----------------------------------------------------------------
            --FND_PROFILE.GET('ORG_ID',l_ou_id);
            --R12: Commented to overcome build errors. These changes still pending to be
            --properly implemented.
            v_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_ou_id);

            -----------------------------------------------------------
            -- Updates the distribution line to hold ship to location
            -- for defaulting the tax names
            -----------------------------------------------------------
            UPDATE ap_invoice_distributions
            SET
                --  global_attribute3 = l_ship_to_location_id,
                global_attribute_category = decode(v_country_code,'AR','JL.AR.APXINWKB.DISTRIBUTIONS',
                                                                  'CO','JL.CO.APXINWKB.DISTRIBUTIONS','')
            where invoice_id  = nvl(P_Credit_Id,P_Invoice_Id) -- Bug 2906487, Added an nvl clause.
            and invoice_distribution_id = P_distribution_id;

            ---------------------------------------------------------------
            -- Defaults the tax names for the distributions created.
            ---------------------------------------------------------------
            --
            --  Bug 4559478
            --
            Jl_Zz_Ap_Awt_Default_Pkg.Supp_Wh_Def(
                                                 P_Invoice_Id,
                                                 P_Inv_Line_Num,
                                                 P_Distribution_id,
                                                 null,
                                                 null  -- check if we need should pass parent id
                                                );

       END IF;

   --   END LOOP;

   --   CLOSE c_distributions;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              '  Credit  Id  = '          || to_char(P_Credit_Id)  ||
              ', Invoice_Id  = '          || to_char(P_Invoice_Id) ||
              -- Bug 4559478
              -- ', Start Dist Line Num  = ' || to_char(P_Start_Dist_Line_Num));
              ', Inv Line Num  = ' || to_char(P_Inv_Line_Num));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Jl_Zz_Ap_Extended_Match;



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
                     P_Calling_Sequence           IN    Varchar2)
IS
BEGIN
    ----------------------------------------------------------
    -- Stubbed OUT JL will not longer insert in AP Dist Table
    -- R12
    ----------------------------------------------------------
    NULL;

EXCEPTION
        WHEN OTHERS THEN
             IF (SQLCODE <> -20001) THEN
                 FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
                 FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

END Jl_Zz_Ap_Ext_Insert_Dist;




/**************************************************************************
 *                          Private Procedure                             *
 **************************************************************************/


/**************************************************************************
 *                                                                        *
 * Name       : Get_Period_Name                                           *
 * Purpose    : Returns the name of the AWT period for a particular tax   *
 *              name and period type                                      *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Period_Name
              (P_Tax_Name                IN      Varchar2,
               P_Period_Type             IN      Varchar2,
               P_AWT_Date                IN      Date,
               P_Calling_Sequence        IN      Varchar2,
               P_AWT_Success             OUT NOCOPY     Varchar2)
               RETURN Varchar2
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_period_name            Varchar2(15);
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Period_Name<--' || P_Calling_Sequence;

   JL_ZZ_AP_EXT_AWT_UTIL.Debug ('Inside Get_Period_Name - parameters, P_Tax_Name'||P_Tax_Name);         -- Argentina AWT ER
    JL_ZZ_AP_EXT_AWT_UTIL.Debug ('P_Period_Type'||P_Period_Type||'P_AWT_Date'||P_AWT_Date||'P_AWT_Success'||P_AWT_Success);

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    --------------------------------------
    -- Obtains the name of the AWT period
    --------------------------------------
    IF (P_Period_Type IS NULL) THEN
        RETURN null;
    ELSE
        SELECT period_name
        INTO   l_period_name
        FROM   ap_other_periods
        WHERE  application_id = 200
        AND    module = 'AWT'
        AND    period_type = P_Period_Type
        AND    start_date <= trunc(P_AWT_Date)
        AND    end_date   >= trunc(P_AWT_Date);

        RETURN l_period_name;
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        Fnd_Message.Set_Name  ('JL', 'JL_AR_AP_AWT_PERIOD_ERROR');
        Fnd_Message.Set_Token ('TAX_NAME',    P_Tax_Name);
        Fnd_Message.Set_Token ('PERIOD_TYPE', P_Period_Type);
        Fnd_Message.Set_Token ('AWT_DATE',    P_AWT_Date);
        P_AWT_Success := Fnd_Message.Get;
        RETURN null;

    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              '  Tax Name= '          || P_Tax_Name      ||
              ', Period Type= '       || P_Period_Type   ||
              ', AWT Date= '          || to_char(P_AWT_Date,'YYYY/MM/DD'));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Period_Name;




/**************************************************************************
 *                                                                        *
 * Name       : Get_Cumulative_Figures                                    *
 * Purpose    : Obtains the cumulative gross amount to date and the       *
 *              cumulative withheld amount to date for a particular       *
 *              supplier, tax name and period.                            *
 *                                                                        *
 **************************************************************************/
PROCEDURE Get_Cumulative_Figures
                  (P_Vendor_Id                 IN     Number,
                   P_Tax_Name                  IN     Varchar2,
                   P_AWT_Period_Type           IN     Varchar2,
                   P_AWT_Date                  IN     Date,
                   P_Calling_Sequence          IN     Varchar2,
                   P_Gross_Amount_To_Date      OUT NOCOPY    Number,
                   P_Withheld_Amount_To_Date   OUT NOCOPY    Number,
                   P_AWT_Success               OUT NOCOPY    Varchar2)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_period_name                 Varchar2(15);
    l_gross_amount_to_date        Number;
    l_withheld_amount_to_date     Number;
    l_debug_info                  Varchar2(300);
    l_calling_sequence            Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Cumulative_Figures<--' || P_Calling_Sequence;

    --------------------------------------
    -- Obtains the name of the awt period
    --------------------------------------
    l_period_name := Get_Period_Name(P_Tax_Name,
                                     P_AWT_Period_Type,
                                     P_AWT_Date,
                                     l_calling_sequence,
                                     P_AWT_Success);

    IF (P_AWT_Success <> AWT_SUCCESS) THEN
        RETURN;
    END IF;

    ------------------------------
    -- Obtains cumulative figures
    ------------------------------
    SELECT gross_amount_to_date,
           withheld_amount_to_date
    INTO   l_gross_amount_to_date,
           l_withheld_amount_to_date
    FROM   ap_awt_buckets
    WHERE  period_name = l_period_name
    AND    tax_name    = P_Tax_Name
    AND    vendor_id   = P_Vendor_Id;

    --------------------------
    -- Sets output parameters
    --------------------------
    P_Gross_Amount_To_Date    := l_gross_amount_to_date;
    P_Withheld_Amount_To_Date := l_withheld_amount_to_date;

EXCEPTION
    WHEN no_data_found THEN
        P_Gross_Amount_To_Date    := 0;
        P_Withheld_Amount_To_Date := 0;

    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                 '  Vendor Id= '          || to_char(P_Vendor_Id) ||
                 ', Tax Name= '           || P_Tax_Name           ||
                 ', AWT Period Type= '    || P_AWT_Period_Type    ||
                 ', AWT Date= '           || to_char(P_AWT_Date,'YYYY/MM/DD'));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Cumulative_Figures;




/**************************************************************************
 *                                                                        *
 * Procedure  : Get_Tax_Rate                                              *
 * Description: Obtains the tax rate for the current tax name and for the *
 *              calculated taxable base amount.                           *
 *                                                                        *
 **************************************************************************/
PROCEDURE Get_Tax_Rate
                 (P_Tax_Name              IN     Varchar2,
                  P_Date                  IN     Date,
                  P_Taxable_Base_Amount   IN     Number,
                  P_Calling_Sequence      IN     Varchar2,
                  P_Rec_AWT_Rate          OUT NOCOPY    Rec_AWT_Rate,
                  P_AWT_Success           OUT NOCOPY    Varchar2)
IS
    ------------------------------
    -- Local variables definition
    ------------------------------
    l_tax_rate_found         Boolean := FALSE;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

    ----------------------
    -- Cursor Definition
    ----------------------
    CURSOR c_tax_rates (P_Tax_Name IN Varchar2,
                        P_Date     IN Date) IS
    SELECT tax_rate,
           tax_rate_id,
           rate_type,
           start_amount,
           end_amount,
           global_attribute1,
           global_attribute2
    FROM   ap_awt_tax_rates
    WHERE  tax_name = P_Tax_Name
    AND    rate_type = 'STANDARD'
    AND    P_Date BETWEEN nvl(start_date, P_Date - 1)
                  AND     nvl(end_date, P_Date + 1)
    ORDER BY start_amount asc;

    ---------------------
    -- Record Definition
    ---------------------
    rec_tax_rates    c_tax_rates%ROWTYPE;

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Tax_Rate<--' || P_Calling_Sequence;

    -----------------------------------
    -- Assumes successfully completion
    -----------------------------------
    P_AWT_Success := AWT_SUCCESS;

    -----------------------------------------
    -- Opens the cursor to get all the rates
    -- for the tax name
    -----------------------------------------
    OPEN c_tax_rates (P_Tax_Name, P_Date);
    LOOP
        FETCH c_tax_rates INTO rec_tax_rates;
        EXIT WHEN c_tax_rates%NOTFOUND
             OR   c_tax_rates%NOTFOUND IS NULL
             OR   l_tax_rate_found;

        ----------------------------------
        -- Checks the taxable base amount
        ----------------------------------
        IF (ABS(P_Taxable_Base_Amount) >= nvl(rec_tax_rates.start_amount,
                                         ABS(P_Taxable_Base_Amount)) AND
            ABS(P_Taxable_Base_Amount) <= nvl(rec_tax_rates.end_amount,
                                         ABS(P_Taxable_Base_Amount))) THEN
          P_Rec_AWT_Rate.Tax_Rate_Id        := rec_tax_rates.tax_rate_id;
          P_Rec_AWT_Rate.Tax_Rate           := rec_tax_rates.tax_rate;
          P_Rec_AWT_Rate.Rate_Type          := rec_tax_rates.rate_type;
          P_Rec_AWT_Rate.Amount_To_Subtract := rec_tax_rates.global_attribute1;
          P_Rec_AWT_Rate.Amount_To_Add      := rec_tax_rates.global_attribute2;
          l_tax_rate_found := TRUE;
        END IF;
    END LOOP;

    CLOSE c_tax_rates;

    IF (NOT l_tax_rate_found) THEN
        Fnd_Message.Set_Name  ('JL', 'JL_ZZ_AP_TAX_RATE_NOT_FOUND');
        Fnd_Message.Set_Token ('TAX_NAME',    P_Tax_Name);
        Fnd_Message.Set_Token ('AWT_DATE',    P_Date);
        Fnd_Message.Set_Token ('BASE_AMOUNT', P_Taxable_Base_Amount);
        P_AWT_Success := Fnd_Message.Get;
        RETURN;
    END IF;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              '  Tax Name= '            || P_Tax_Name      ||
              ', Date= '                || to_char(P_Date) ||
              ', Taxable Base Amount= ' || to_char(P_Taxable_Base_Amount));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Tax_Rate;




/**************************************************************************
 *                                                                        *
 * Name       : Update_Withheld_Amount                                    *
 * Purpose    : Prorates the withheld amount for each tax name included   *
 *              into the PL/SQL table. These values will also be rounded. *
 *                                                                        *
 **************************************************************************/
PROCEDURE Update_Withheld_Amount
               (P_Original_Withheld_Amt  IN     Number,
                P_Updated_Withheld_Amt   IN     Number,
                P_Currency_Code          IN     Varchar2,
                P_Calling_Sequence       IN     Varchar2,
                P_Tab_Withhold           IN OUT NOCOPY Tab_Withholding)
IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_withheld_amount        Number   := 0;
    l_cumulative_amount      Number   := 0;
    l_previous_tax_id        Number   := null;
    l_updated_withheld_amt   Number;
    l_debug_info             Varchar2(300);
    l_calling_sequence       Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Update_Withheld_Amount<--' || P_Calling_Sequence;

    ---------------------------------------------------
    -- Checks whether the original withheld amount is
    -- different from zero
    ---------------------------------------------------
    IF (P_Original_Withheld_Amt = 0) THEN
        RETURN;
    END IF;

    --------------------------------------
    -- Rounds the updated withheld amount
    --------------------------------------
    l_updated_withheld_amt := Ap_Utilities_Pkg.Ap_Round_Currency
                                   (P_Updated_Withheld_Amt, P_Currency_Code);

    -----------------------------------------------------------
    -- Updates the withheld amount for each different tax name
    -----------------------------------------------------------
    FOR i IN 1 .. P_Tab_Withhold.COUNT LOOP

        IF (l_previous_tax_id IS NULL OR
            P_Tab_Withhold(i).tax_id <> l_previous_tax_id) THEN

            ----------------------------------------------------
            -- Calculates the withheld amount for each tax name
            -- except for the last one
            ----------------------------------------------------
            IF (P_Tab_Withhold(i).tax_id <>
                P_Tab_Withhold(P_Tab_Withhold.COUNT).tax_id) THEN

                l_withheld_amount := P_Tab_Withhold(i).withheld_amount *
                                     l_updated_withheld_amt /
                                     P_Original_Withheld_Amt;
                l_withheld_amount := Ap_Utilities_Pkg.Ap_Round_Currency
                                      (l_withheld_amount, P_Currency_Code);
                l_cumulative_amount := l_cumulative_amount + l_withheld_amount;

            --------------------------------------------------------
            -- Calculates the withheld amount for the last tax name
            --------------------------------------------------------
            ELSE
                l_withheld_amount := l_updated_withheld_amt -
                                     l_cumulative_amount;
            END IF;

            l_previous_tax_id := P_Tab_Withhold(i).tax_id;

        END IF;

        ---------------------------------------------------
        -- Updates the withheld amount in the PL/SQL table
        ---------------------------------------------------
        P_Tab_Withhold(i).withheld_amount := l_withheld_amount;

    END LOOP;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
             '  Original Withheld Amt= ' || to_char(P_Original_Withheld_Amt) ||
             ', Updated Withheld Amt= '  || to_char(P_Updated_Withheld_Amt)  ||
             ', Currency Code= '         || P_Currency_Code);
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Update_Withheld_Amount;




/**************************************************************************
 *                                                                        *
 * Name       : Get_Revised_Tax_Base_Amount                               *
 * Purpose    : 1 Retrieves the taxable base amount from the PL/SQL table *
 *              2 Applies all the validations like income tax rate,       *
 *                reduction percentage etc., and generates a revised      *
 *                taxable base amount.                                    *
 *              3 Updates the PL/SQL table to store the revised amount    *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Revised_Tax_Base_Amount
                (P_Rec_AWT_Name                 IN      Rec_AWT_CODE,
                 P_Tab_Withhold                 IN OUT NOCOPY  Tab_Withholding,
                 P_Tax_Name_From                IN      Number,
                 P_Tax_Name_To                  IN      Number,
                 P_Taxable_Base_Amount          IN      Number,
                 P_Tab_All_Withhold             IN      Tab_All_Withholding,
                 P_Calling_Sequence             IN      Varchar2)
                 RETURN NUMBER
IS
    ------------------------------
    -- Local Variables Definition
    ------------------------------
    tab                         Tab_All_Withholding := P_Tab_All_Withhold;
    ctr                         Number;
    pos                         Number;
    l_revised_tax_base_amt      Number := 0;
    l_debug_info                Varchar2(300);
    l_calling_sequence          Varchar2(2000);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                       'Get_Revised_Tax_Base_Amount<--' || P_Calling_Sequence;

    ----------------------------------------------------------------
    -- Reduces the taxable base amount by income tax rate percentage
    ----------------------------------------------------------------
    l_revised_tax_base_amt := P_Taxable_Base_Amount -
                              (P_Taxable_Base_Amount *
                               nvl(P_Rec_AWT_Name.Income_Tax_Rate/100,1));

    ----------------------------------------------------------------
    -- Applies all the validations that are applicable to the tax
    -- name, on the revised taxable base amount
    ----------------------------------------------------------------

    FOR pos IN P_Tax_Name_From..P_Tax_Name_To LOOP

       FOR ctr IN 1..tab.COUNT LOOP

         IF (P_Tab_All_Withhold(ctr).invoice_distribution_id =
                        P_Tab_Withhold(pos).invoice_distribution_id) THEN

          IF ((P_Rec_AWT_Name.First_Tax_Type IS NOT NULL) AND
                (P_Tab_All_Withhold(ctr).awt_type_code =
                        P_Rec_AWT_Name.First_Tax_Type)) THEN

              l_revised_tax_base_amt := l_revised_tax_base_amt -
                        nvl(P_Tab_All_Withhold(ctr).prorated_amount,0);

          ELSIF ((P_Rec_AWT_Name.Second_Tax_Type IS NOT NULL) AND
                (P_Tab_All_Withhold(ctr).awt_type_code =
                        P_Rec_AWT_Name.Second_Tax_Type)) THEN

              l_revised_tax_base_amt := l_revised_tax_base_amt -
                        nvl(P_Tab_All_Withhold(ctr).prorated_amount,0);

          ELSIF ((P_Rec_AWT_Name.Municipal_Type = 'Y') AND
                (UPPER(P_Tab_All_Withhold(ctr).jurisdiction_type) =
                 'MUNICIPAL')) THEN

              l_revised_tax_base_amt := l_revised_tax_base_amt -
                        nvl(P_Tab_All_Withhold(ctr).prorated_amount,0);

          END IF;

         END IF;

       END LOOP;

    END LOOP;

    ----------------------------------------------------------------
    -- Multiplies the revised taxable base amount by the reduction
    -- percentage
    ----------------------------------------------------------------
    IF (P_Rec_AWT_Name.Reduction_Perc = 0) THEN
        l_revised_tax_base_amt := l_revised_tax_base_amt * 1;
    ELSE
        l_revised_tax_base_amt := l_revised_tax_base_amt *
                                (nvl(P_Rec_AWT_Name.Reduction_Perc/100,1));
    END IF;


    ----------------------------------------------------------------
    -- Updates the amount contained in the PL/SQL table inorder to
    -- store the revised taxable base amount
    ----------------------------------------------------------------
    FOR pos IN P_Tax_Name_From..P_Tax_Name_To LOOP

       P_Tab_Withhold(pos).revised_tax_base_amount := l_revised_tax_base_amt;

    END LOOP;

    RETURN l_revised_tax_base_amt;

EXCEPTION
    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                '  Tax Name From= '       || to_char(P_Tax_Name_From) ||
                ', Tax Name To= '         || to_char(P_Tax_Name_To)   ||
                ', Taxable Base Amount= ' || to_char(P_Taxable_Base_Amount));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;

END Get_Revised_Tax_Base_Amount;




/**************************************************************************
 *                                                                        *
 * Name       : Bool_To_Char                                              *
 * Purpose    : Converts the Boolean value received as a parameter to a   *
 *              Varchar2 character string. This function is only used     *
 *              for debug purposes.                                       *
 *                                                                        *
 **************************************************************************/
FUNCTION Bool_To_Char (P_Bool_Value IN Boolean) RETURN Varchar2
IS
BEGIN
    IF (P_Bool_Value IS NULL) THEN
        RETURN null;
    ELSIF (P_Bool_Value) THEN
        RETURN 'Yes';
    ELSE
        RETURN 'No';
    END IF;
END Bool_To_Char;


 /*************************************************************************
 * Name       : Validate_Multiple_Bal_Seg                                 *
 * Purpose    : Rountine to check whether there exists multiple balancing *
 *              segments within invoice distributions or tax code         *
 *                                                                        *
 **************************************************************************/

FUNCTION Validate_Multiple_Bal_Seg
            (P_Invoice_Id ap_invoices.invoice_id%TYPE
             ) return Varchar2
IS

 t_bal_seg varchar2(200);
 Curr_Bal  varchar2(200);
 Pre_Bal   varchar2(200);
 l_liability_post_lookup_code AP_SYSTEM_PARAMETERS.liability_post_lookup_code%TYPE;
 counter number :=1 ;


 ----------------------------------------------------------------------
 -- Cursor to get CCID from AP_Invoice_Distributions_ID
 ----------------------------------------------------------------------
 CURSOR Bal_Seg IS
 SELECT dist_code_combination_id
 FROM   ap_invoice_distributions
 WHERE  invoice_id = P_Invoice_id
     -- added recently
 AND    NVL(REVERSAL_FLAG,'N') <> 'Y';

 ----------------------------------------------------------------------
 -- Cursor to get the distinct tax codes for the given invoice
 ----------------------------------------------------------------------
 CURSOR tax_code IS
 SELECT distinct atc.name, atc.tax_code_combination_id
 FROM jl_zz_ap_inv_dis_wh jid,
      jl_zz_ap_sup_awt_cd jsw,
      ap_tax_codes atc
 WHERE jid.invoice_id = P_Invoice_Id
 AND   jsw.supp_awt_code_id = jid.supp_awt_code_id
 AND   atc.tax_id           = jsw.tax_id;

  -------------------------------------------------------------------------
  -- Validate for multiple balancing segments in distribution lines.
  -------------------------------------------------------------------------
BEGIN

   ----------------------------------------------------------------------------------------
   -- Get Set of Books and Auto-offsets Option info
   ----------------------------------------------------------------------------------------

   SELECT nvl(liability_post_lookup_code, 'NONE')
   INTO   l_liability_post_lookup_code
   FROM   ap_system_parameters;

   IF (l_Liability_Post_Lookup_Code = 'BALANCING_SEGMENT') AND
      (Ap_Extended_Withholding_Pkg.Ap_Extended_Withholding_Active)  THEN

      For my_reg IN Bal_Seg LOOP

          Curr_BaL := Dynamic_Call_Get_BalSeg(my_reg.dist_code_combination_id);

          IF counter > 1 THEN
             IF Curr_Bal <> Pre_Bal Then
                Return('Error');
             END IF;
          ELSE
             Pre_Bal := Curr_Bal;
          End IF;
          counter := counter + 1;
      End Loop;

      ------------------------------------------------------------------------
      -- Check for mulitiple balancing segments in the applicable tax codes
      ------------------------------------------------------------------------
      FOR cur_rec IN tax_code LOOP

         t_bal_seg := Dynamic_Call_Get_BalSeg(cur_rec.tax_code_combination_id);

         ------------------------------------------------------------------
         -- Check if the balancing segment for the tax code is different
         ------------------------------------------------------------------
         IF t_bal_seg <> Curr_Bal THEN
            return('Error');
         END IF;
      END LOOP;
      -- Return Success
      return('Success');
   END IF; -- Balancing Segement
   -- No Balancing Segment
   return('Success');
END Validate_Multiple_Bal_Seg;

 /*************************************************************************
 * Name       : Validate_Mult_BS_GateWay                                  *
 * Purpose    : Rountine to check whether there exists multiple balancing *
 *              segments within invoice distributions or tax code         *
 *              for Invoice Gateway                                       *
 *                                                                        *
 **************************************************************************/

FUNCTION Validate_Mult_BS_GateWay
            (P_Invoice_Id ap_invoices.invoice_id%TYPE
             ) return Varchar2
IS

 t_bal_seg varchar2(200);
 l_liability_post_lookup_code AP_SYSTEM_PARAMETERS.liability_post_lookup_code%TYPE;
 Curr_Bal  varchar2(200);
 Pre_Bal   varchar2(200);
 counter number :=1 ;

 ----------------------------------------------------------------------
 -- Cursor to get CCID from AP_Invoice_Distributions_ID
 ----------------------------------------------------------------------
 CURSOR Bal_Seg IS
 SELECT dist_code_combination_id
 FROM   ap_invoice_lines_interface
 WHERE  invoice_id = P_Invoice_id;

 ----------------------------------------------------------------------
 -- Cursor to get the distinct tax codes for the given invoice
 ----------------------------------------------------------------------
 CURSOR tax_code IS
 SELECT distinct atc.name, atc.tax_code_combination_id
 FROM jl_zz_ap_sup_awt_cd jsw,
      jl_zz_ap_supp_awt_types jst,
      ap_tax_codes atc,
      ap_invoices_interface aii
 WHERE aii.invoice_id       = P_Invoice_id
 AND   jst.vendor_id        = aii.vendor_id
 AND   jst.supp_awt_type_id = jsw.supp_awt_type_id
 AND   atc.tax_id           = jsw.tax_id
 AND   jsw.primary_tax_flag = 'Y';

  -------------------------------------------------------------------------
  -- Validate for multiple balancing segments in distribution lines.
  -------------------------------------------------------------------------
BEGIN
   ----------------------------------------------------------------------------------------
   -- Get Set of Books and Auto-offsets Option info
   ----------------------------------------------------------------------------------------

   SELECT nvl(liability_post_lookup_code, 'NONE')
   INTO   l_liability_post_lookup_code
   FROM   ap_system_parameters;


   IF (l_Liability_Post_Lookup_Code = 'BALANCING_SEGMENT') AND
      (Ap_Extended_Withholding_Pkg.Ap_Extended_Withholding_Active)  THEN

      For my_reg IN Bal_Seg LOOP
          Curr_BaL := Dynamic_Call_Get_BalSeg(my_reg.dist_code_combination_id);
          IF counter > 1 THEN
             IF Curr_Bal <> Pre_Bal Then
                Return('Error');
             END IF;
          ELSE
             Pre_Bal := Curr_Bal;
          End IF;
          counter := counter + 1;
      End Loop;

      ------------------------------------------------------------------------
      -- Check for mulitiple balancing segments in the applicable tax codes
      ------------------------------------------------------------------------
      FOR cur_rec in tax_code LOOP

         t_bal_seg := Dynamic_Call_Get_BalSeg(cur_rec.tax_code_combination_id);

         ------------------------------------------------------------------
         -- Check if the balancing segment for the tax code is different
         ------------------------------------------------------------------
         IF t_bal_seg <> Curr_Bal THEN
            return('Error');
         END IF;
      END LOOP;
      return('Success');
   END IF; -- Balancing Segement

   -- No Balancing Segment
   return('Success');

END Validate_Mult_BS_GateWay;

 /*************************************************************************
 * Name       : Dynamic_Call_Get_BalSeg                                   *
 * Purpose    : Encapsulate Dynamic Call to get_auto_offsets_segments     *
 *                                                                        *
 **************************************************************************/

FUNCTION Dynamic_Call_Get_BalSeg
            (P_ccid IN Number ) return Varchar2
IS
  Curr_Bal     Varchar2(200):= null;
  l_cursor     NUMBER;
  l_sqlstmt    VARCHAR2(1000);
  l_ignore    NUMBER;

  Begin
    ------------------------------------------
    -- Dynamic Call
    ------------------------------------------
    -- Create the SQL statement
    l_cursor := dbms_sql.open_cursor;
    l_sqlstmt := 'BEGIN :Curr_BaL := ' ||
                 'ap_utilities_pkg.get_auto_offsets_segments (:l_code_combination_id); END;';

    -- Parse the SQL statement
    dbms_sql.parse (l_cursor, l_sqlstmt, dbms_sql.native);

    -- Define the variables
    dbms_sql.bind_variable (l_cursor, 'Curr_BaL', Curr_BaL,200);
    dbms_sql.bind_variable (l_cursor, 'l_code_combination_id', P_ccid);

    -- Execute the SQL statement
    l_ignore := dbms_sql.execute (l_cursor);

    -- Get the return value (success)
    dbms_sql.variable_value (l_cursor, 'Curr_BaL', Curr_BaL);

    -- Close the cursor
    dbms_sql.close_cursor (l_cursor);

    -- Function Return Values
    return (Curr_Bal);

  EXCEPTION
    WHEN others THEN
        IF (dbms_sql.is_open(l_cursor)) THEN
            dbms_sql.close_cursor(l_cursor);
        END IF;
        return (Curr_Bal);
END Dynamic_Call_Get_BalSeg;

/**************************************************************************
 *                                                                        *
 * Name       : Get_Cumulative_Supp_Exemp                                 *
 * Purpose    : Obtains the cumulative supplier's exemption amount        *
 *              to date for a particular period                           *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Cumulative_Supp_Exemp
                  (P_Vendor_Id                 IN     Number,
                   P_Tax_Name                  IN     Varchar2,
                   P_AWT_Period_Type           IN     Varchar2,
                   P_AWT_Date                  IN     Date,
                   P_Calling_Sequence          IN     Varchar2)
 RETURN NUMBER IS

    ------------------------------
    -- Local variables definition
    ------------------------------
    l_period_name                 Varchar2(15);
    l_exemption_amount             Number := 0;
    l_start_date                  Date;
    l_end_date                    Date;
    l_tax_id                      Number;
    l_debug_info                  Varchar2(300);
    l_calling_sequence            Varchar2(2000);
    P_AWT_Success                 Varchar2(10);

BEGIN
    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_ZZ_AP_WITHHOLDING_PKG' || '.' ||
                          'Get_Cumulative_Supp_Exemp<--' || P_Calling_Sequence;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('    Function Get_Cumulative_Supp_Exemp');
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Param: P_Vendor_Id: '||to_char(P_Vendor_Id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Param: Tax Name: '||P_Tax_Name);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Param: P_AWT_Period_Type: '||P_AWT_Period_Type);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Param: P_AWT_Date: '||to_char(P_AWT_Date,'YYYY/MM/DD'));
    END IF;
    -- End Debug

    --------------------------------------
    -- Obtains the name of the awt period
    --------------------------------------
    P_AWT_Success := AWT_SUCCESS;

    l_period_name := Get_Period_Name(P_Tax_Name,
                                     P_AWT_Period_Type,
                                     P_AWT_Date,
                                     l_calling_sequence,
                                     P_AWT_Success);


    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Period Name '||l_period_name);
    END IF;
    -- End Debug

    -------------------------------------------------
    -- Obtains start and end date for a given period
    -------------------------------------------------
    SELECT start_date, end_date
      INTO l_start_date, l_end_date
      FROM ap_other_periods
     WHERE application_id = 200
       AND module = 'AWT'
       AND period_type = P_AWT_Period_Type
       AND period_name = l_period_name;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Start and End Dates for Withh Period '||to_char(l_start_date)||' '||
                                    to_char(l_end_date));
    END IF;
    -- End Debug

    -------------------------------------------------
    -- Obtains start and end date for a given period
    -------------------------------------------------
    SELECT Tax_Id
      INTO l_tax_id
      FROM ap_tax_codes
     WHERE name = P_Tax_Name;

    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Tax ID : '||to_char(l_tax_id));
    END IF;
    -- End Debug

    --------------------------------------------------------------------------
    -- Obtains cumulative supplier exemption amount to day for a given period
    --------------------------------------------------------------------------
    SELECT NVL(sum(to_number(aid.global_attribute5)),0)
    INTO   l_exemption_amount
    FROM   ap_invoices ai,
           ap_invoice_distributions aid
    WHERE  ai.vendor_id = P_Vendor_Id
    AND    ai.invoice_id = aid.invoice_id
    AND    trunc(aid.accounting_date) >= l_start_date
    AND    trunc(aid.accounting_date) <= l_end_date
    AND    aid.line_type_lookup_code = 'AWT'
    AND    aid.withholding_tax_code_id = l_tax_id
        -- added recently
    AND    NVL(aid.REVERSAL_FLAG,'N') <> 'Y';

    --------------------------
    -- Sets output parameters
    --------------------------
    -- Debug Information
    IF (DEBUG_Var = 'Y') THEN
       JL_ZZ_AP_EXT_AWT_UTIL.Debug ('      Return Cumulative Exemption Amount = '||to_char(l_exemption_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug (' ');
    END IF;
    -- End Debug

    Return(l_exemption_amount);

EXCEPTION
    WHEN no_data_found THEN
         Return(0);

    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
                 '  Vendor Id= '          || to_char(P_Vendor_Id) ||
                 ', Tax Name= '           || P_Tax_Name           ||
                 ', AWT Period Type= '    || P_AWT_Period_Type    ||
                 ', AWT Date= '           || to_char(P_AWT_Date,'YYYY/MM/DD'));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

        App_Exception.Raise_Exception;
END Get_Cumulative_Supp_Exemp;

END JL_ZZ_AP_WITHHOLDING_PKG;

/
