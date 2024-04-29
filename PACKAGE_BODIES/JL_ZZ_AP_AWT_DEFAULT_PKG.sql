--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AP_AWT_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AP_AWT_DEFAULT_PKG" AS
/* $Header: jlzzpwdb.pls 120.23.12010000.8 2010/04/22 06:32:46 mkandula ship $ */
/*

   Copyright (c) 1995 by Oracle Corporation

   NAME
     JL_ZZ_AP_AWT_DEFAULT_PKG - PL/SQL Package Body Validate the Global Attributes
     for Import Process.
   DESCRIPTION
     This package validate the Global Attributes in the import process.
   NOTES
     This package body must be created under Global Applications Development.
   HISTORY                            (DD/MM/YY)
    dbetanco                           09/11/98  Creation
    dbetanco                           11/12/98  Update
    dbetanco                           19/01/98  Update Include the Del_Wh_Def Proc.

*/

-- =====================================================================
--                   P R I V A T E    O B J E C T S
-- =====================================================================
--
-- Insert_AWT_Default insert in jl_zz_ap_inv_dis_wh_all the withholdings after the validation.
--
-- Define Package Level Debug Variable and Assign the Profile
  DEBUG_Var varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
--
-- R12 KI
--

PROCEDURE Insert_AWT_Default(
        P_Invoice_Id                IN        ap_invoices_all.invoice_id%TYPE,
        P_Inv_Dist_Id           IN      ap_invoice_distributions_all.invoice_distribution_id%TYPE,
        P_Supp_Awt_Code_Id        IN        jl_zz_ap_sup_awt_cd.supp_awt_code_id%TYPE,
        p_calling_sequence      IN            VARCHAR2,
        P_Org_Id                IN      jl_zz_ap_sup_awt_cd.org_id%TYPE)  IS

        Seq_Inv_Dis_Awt_Id      NUMBER;
        l_debug_loc             VARCHAR2(30) := ' Insert_AWT_Default ';
        l_curr_calling_sequence VARCHAR2(2000);
        l_debug_info            VARCHAR2(100);
        -- WHO Columns
        v_last_update_by        NUMBER;
        v_last_update_login     NUMBER;

  BEGIN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','Start PROCEDURE Insert_AWT_Default');
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','Parameters are :');
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        P_Invoice_Id='||P_Invoice_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        P_Inv_Dist_Id='||P_Inv_Dist_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        P_Supp_Awt_Code_Id='||P_Supp_Awt_Code_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        p_calling_sequence='||p_calling_sequence);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        P_Org_Id='||P_Org_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        P_Invoice_Id='||P_Invoice_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        Seq_Inv_Dis_Awt_Id='||Seq_Inv_Dis_Awt_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        l_debug_loc='||l_debug_loc);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        l_curr_calling_sequence='||l_curr_calling_sequence);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        l_debug_info='||l_debug_info);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        v_last_update_by='||v_last_update_by);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','        v_last_update_login='||v_last_update_login);
    END IF;
    -------------------------- DEBUG INFORMATION ------------------------------
    l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;

    l_debug_info := 'Insert rejection information to ap_interface_rejections';
    ---------------------------------------------------------------------------

    --  Get the information of WHO Columns from FND_GLOBAL
    v_last_update_by := FND_GLOBAL.User_ID;
    v_last_update_login := FND_GLOBAL.Login_Id;

    -- Select next value from the sequence.
    SELECT jl_zz_ap_inv_dis_wh_s.nextval
    INTO   Seq_Inv_Dis_Awt_Id
    FROM   dual;

    --
    -- Insert into  JL_ZZ_AP_INV_DIS_WH_ALL
    --
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','Inserting this record to JL_ZZ_AP_INV_DIS_WH_ALL with inv_distrib_awt_id='||Seq_Inv_Dis_Awt_Id);
    END IF;

    INSERT INTO jl_zz_ap_inv_dis_wh (
                 inv_distrib_awt_id
                ,invoice_id
                -- Bug 4559472
                ,distribution_line_number
                ,invoice_distribution_id
                ,supp_awt_code_id
                ,created_by
                ,creation_date
                ,last_updated_by
                ,last_update_date
                ,last_update_login
                ,org_id                          -- Add org_id for MOAC
                )
         VALUES (
                 Seq_Inv_Dis_Awt_Id
                ,P_Invoice_Id
                -- Bug 4559472
                --,P_Dis_Line_Number
                -- Populate distribution_line_number with -99 for R12 records
                -- as it is NOT NULL column in jl_zz_ap_inv_dis_wh_all
                ,-99
                , P_Inv_Dist_Id
                ,P_Supp_Awt_Code_Id
                ,v_last_update_by
                ,sysdate
                ,v_last_update_by
                ,sysdate
                ,v_last_update_login
                ,P_Org_Id                       -- Add org_id for MOAC
                );
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','End PROCEDURE Insert_AWT_Default');
                END IF;

  EXCEPTION
  WHEN OTHERS then
            IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default','Exception Occured in PROCEDURE Insert_AWT_Default');
            END IF;
            IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR', 'SQLERRM');
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                             ' P_Invoice_ID = '||to_char(P_Invoice_ID)
                                -- Bug 4559472 ||', P_Dis_Line_Number = '||to_char(P_Dis_Line_Number )
                                ||', P_Inv_Dist_Id  = '||to_char(P_Inv_Dist_Id)
                                ||', P_Supp_Awt_Code_Id = '||to_char(P_Supp_Awt_Code_Id)
                                ||', Last Updated By = '||to_char(v_last_update_by)
                                ||', Last Update Date = '||to_char(v_last_update_login));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
            END IF;
            APP_EXCEPTION.RAISE_EXCEPTION;
  END;



/*-------------------------------------------------------------------------
  Ver_Territorial_Flag return true if the province is territorial.
---------------------------------------------------------------------------*/

FUNCTION Ver_Territorial_Flag
            (P_Province_Code jl_ar_ap_provinces.province_code%TYPE
             ) return boolean is
  -------------------------------------------------------------------------
  -- Select the flag for province Territory
  -------------------------------------------------------------------------
  CURSOR Province_Territory IS
    SELECT territorial_flag
      FROM jl_ar_ap_provinces
     WHERE province_code = P_Province_Code;

  v_territory boolean;
  v_province_terr  jl_ar_ap_provinces.territorial_flag%TYPE;

  BEGIN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag','Start FUNCTION Ver_Territorial_Flag');
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag','Parameters are :');
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag','        P_Province_Code='||P_Province_Code);
    END IF;
    v_territory := FALSE;
    OPEN Province_Territory;
       LOOP
          FETCH Province_Territory
           INTO v_province_terr;
           EXIT when Province_Territory%NOTFOUND;
                IF v_province_terr = 'Y' THEN
                   v_territory := TRUE;
                END IF;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        IF v_territory THEN
                                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag','FUNCTION Ver_Territorial_Flag returns TRUE');
                        ELSE
                                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag','FUNCTION Ver_Territorial_Flag returns FALSE');
                        END IF;
                END IF;
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag','End FUNCTION Ver_Territorial_Flag');
                END IF;
                return (v_territory);
       END LOOP;
    CLOSE Province_Territory;
  EXCEPTION
      WHEN OTHERS THEN
           IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag','Exception in FUNCTION Ver_Territorial_Flag');
                NULL;
           END IF;
  END Ver_Territorial_Flag;

/*----------------------------------------------------------------------------------------------
The Following function return the vendor_id for the Distribution Line.
If tax_payerid is not null  find the vendor_id for this tax_payerid Else
return the vendor id from the invoice.
------------------------------------------------------------------------------------------------*/
FUNCTION Get_Vendor_Id  ( P_Tax_Payer_Id ap_invoice_distributions_all.global_attribute2%TYPE
                        , P_Invoice_Id   ap_invoices_all.invoice_id%TYPE
                         )
    return number is
   --------------------------------------------------------------------
   -- Get the information from po_vendors when tax_payerid is not null
   --------------------------------------------------------------------
    CURSOR  TaxPayerID_Po_Ven IS
    SELECT   Vendor_Id
      FROM   po_vendors
     WHERE   segment1  = P_Tax_Payer_Id;  -- R12 KI : Need to uptake PTP?

   --------------------------------------------------------------------
   -- Get the information from ap_invoices_all when tax_payerid is null.
   --------------------------------------------------------------------
   CURSOR   Invoice_Vendor   IS
   SELECT   Vendor_Id
     FROM   ap_invoices
    WHERE   invoice_id = P_Invoice_Id;

    v_vendor_id  po_vendors.vendor_id%TYPE;

  BEGIN
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','Start FUNCTION Get_Vendor_Id');
             FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','Parameters are :');
             FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','        P_Tax_Payer_Id='||P_Tax_Payer_Id);
             FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','        P_Invoice_Id='||P_Invoice_Id);
     END IF;
     IF P_Tax_Payer_Id IS NOT NULL THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','Inside IF P_Tax_Payer_Id IS NOT NULL THEN');
        END IF;
        OPEN TaxPayerID_Po_Ven;
          LOOP
             FETCH TaxPayerID_Po_Ven
                INTO v_vendor_id;
                EXIT when TaxPayerID_Po_Ven%NOTFOUND;
          END LOOP;
        CLOSE TaxPayerID_Po_Ven;
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','FUNCTION Get_Vendor_Id returns v_vendor_id='||v_vendor_id);
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','End FUNCTION Get_Vendor_Id');
        END IF;
        return (v_vendor_id);
     ELSE
        OPEN Invoice_Vendor;
           LOOP
              FETCH Invoice_Vendor
                 INTO v_vendor_id;
                 EXIT when Invoice_Vendor%NOTFOUND;
           END LOOP;
           CLOSE Invoice_Vendor;
           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','FUNCTION Get_Vendor_Id returns v_vendor_id='||v_vendor_id);
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','End FUNCTION Get_Vendor_Id');
           END IF;
           return (v_vendor_id);
     END IF;
  EXCEPTION
      WHEN OTHERS THEN
           IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Get_Vendor_Id','Exception in FUNCTION Get_Vendor_Id');
           END IF;
  END;

/*----------------------------------------------------------------------------------------------
The Following function verify if the company is agent for a withholding type.
The function receive the Supplier Withholding Type as parameter.
------------------------------------------------------------------------------------------------*/

FUNCTION Company_Agent  (P_Awt_Type_Code jl_zz_ap_awt_types.awt_type_code%TYPE,
                         P_Invoice_Id ap_invoices_all.invoice_id%TYPE)
    return boolean is

    Cursor Company_Awt_Types (PC_Legal_Entity_ID xle_entity_profiles.legal_entity_id%TYPE)
        IS
    SELECT   awt_type_code
      FROM   jl_zz_ap_comp_awt_types
     WHERE   legal_entity_id = PC_Legal_Entity_ID
             --location_id    = PC_Location_ID
       AND   wh_agent_flag  = 'Y';

     Cursor legal_entity IS
     SELECT legal_entity_id
      FROM  ap_invoices
     WHERE  invoice_id = P_Invoice_ID;

    find_type boolean;
    -- v_location  hr_locations_all.location_id%TYPE;
    l_legal_entity_id xle_entity_profiles.legal_entity_id%TYPE;

  BEGIN
       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','Start FUNCTION Company_Agent');
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','Parameters are :');
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','        P_Awt_Type_Code='||P_Awt_Type_Code);
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','        P_Invoice_Id='||P_Invoice_Id);
        END IF;
       find_type := FALSE;
        -----------------------------------------------------------
        -- Get the Company information from the Legal Entity
        ----------------------------------------------------------
        -- v_location := jg_zz_company_info.get_location_id; -- LE
        SELECT  legal_entity_id
          INTO  l_legal_entity_id
          FROM  ap_invoices
         WHERE  invoice_id = P_Invoice_ID;
        ----------------------------------------------------------
        -- Loop verify the withholding type.
        ----------------------------------------------------------
        FOR db_reg IN Company_Awt_Types (l_legal_entity_id) LOOP
            IF db_reg.awt_type_code = P_Awt_Type_Code THEN
               find_type := TRUE;
               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','FUNCTION Company_Agent returns TRUE');
                       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','End FUNCTION Company_Agent');
                END IF;
               return(find_type);
            END IF;
        END LOOP;
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','FUNCTION Company_Agent returns FALSE');
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','End FUNCTION Company_Agent');
        END IF;
        return(find_type);
  EXCEPTION
      WHEN OTHERS THEN
           IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent','Exception in FUNCTION Company_Agent');
                NULL;
           END IF;
  END;

/*------------------------------------------------------
The Following function is to find out whether the Tax Name is applicable to the Line_type
TAX-ID and Line Type  are passed as a parameter for this function.
-----------------------------------------------------*/

FUNCTION Validate_Line_Type
           (v_dist_type  varchar2
           ,v_tax_id   ap_tax_codes_all.tax_id%type)
 return boolean is
       v_item_type              ap_tax_codes_all.global_attribute8%type;
       v_freight_type           ap_tax_codes_all.global_attribute9%type;
       v_misc_type              ap_tax_codes_all.global_attribute10%type;
       v_tax_type               ap_tax_codes_all.global_attribute11%type;
       find_type boolean;

  CURSOR cur_validate_line_type is
     SELECT global_attribute8, -- Type ITEM
            global_attribute9, -- Type FREIGHT
            global_attribute10,-- Type MISCELLANEOUS
            global_attribute11 -- Type TAX
       FROM ap_tax_codes
      WHERE tax_id =v_tax_id;

 BEGIN
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','Start FUNCTION Validate_Line_Type');
           FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','Parameters are :');
           FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','        v_dist_type='||v_dist_type);
           FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','        v_tax_id='||v_tax_id);
   END IF;
   find_type :=false;
   OPEN cur_validate_line_type ;
      LOOP
         FETCH cur_validate_line_type INTO
               v_item_type,
               v_freight_type,
               v_misc_type,
               v_tax_type;
         EXIT WHEN cur_validate_line_type%NOTFOUND;
         --bug 6232172 -  v_dist_type = 'ACCRUAL' is added
         IF (v_dist_type = 'ITEM'
                OR v_dist_type = 'ACCRUAL'
                OR v_dist_type = 'IPV'
                OR v_dist_type = 'ERV') AND  (v_item_type='Y') THEN
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','FUNCTION Validate_Line_Type returns TRUE');
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','End FUNCTION Validate_Line_Type');
            END IF;
            find_type :=true ; return(find_type);
         ELSIF (v_dist_type = 'FREIGHT') AND (v_freight_type ='Y') THEN
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','FUNCTION Validate_Line_Type returns TRUE');
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','End FUNCTION Validate_Line_Type');
            END IF;
         find_type :=true ; return(find_type);
         ELSIF (v_dist_type = 'MISCELLANEOUS') AND (v_misc_type ='Y') THEN
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','FUNCTION Validate_Line_Type returns TRUE');
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','End FUNCTION Validate_Line_Type');
             END IF;
         find_type :=true ; return(find_type);
         ELSIF (v_dist_type = 'TAX'
                OR v_dist_type = 'NONREC_TAX'
                OR v_dist_type = 'REC_TAX'
                OR v_dist_type = 'TRV'
                OR v_dist_type = 'TIPV'
                OR v_dist_type = 'TERV') AND (v_tax_type ='Y') THEN
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','FUNCTION Validate_Line_Type returns TRUE');
                    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','End FUNCTION Validate_Line_Type');
            END IF;
               find_type :=true ; return(find_type);
         END IF;
      END LOOP;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','FUNCTION Validate_Line_Type returns FALSE');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','End FUNCTION Validate_Line_Type');
      END IF;
      return(find_type);
   CLOSE cur_validate_line_type;
 EXCEPTION
     WHEN OTHERS THEN
          IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type','Exception in FUNCTION Validate_Line_Type');
                NULL;
          END IF;
 END;

/*-----------------------------------------------------------------
The Procedure Province_zone_city is used to select region_1,region_2,town_or_city from
hr_locations for a ship_to_location_id.
-------------------------------------------------------------------*/
PROCEDURE  Province_Zone_City
              (p_ship_to_location_id hr_locations_all.location_id%TYPE
              ,v_hr_zone out NOCOPY hr_locations_all.region_1%TYPE
              ,v_hr_province out NOCOPY  hr_locations_all.region_2%TYPE
              ,v_city_code out NOCOPY hr_locations_all.town_or_city%TYPE) is

   CURSOR   cur_province_zone_city  IS
     SELECT region_1, region_2, town_or_city
       FROM hr_locations_all
      WHERE location_id = p_ship_to_location_id;
  BEGIN
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','Start PROCEDURE  Province_Zone_City');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','Parameters are :');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','        p_ship_to_location_id='||p_ship_to_location_id);
      END IF;
      OPEN cur_province_zone_city ;
         LOOP
            FETCH cur_province_zone_city
             INTO v_hr_zone , v_hr_province, v_city_code;
             EXIT when cur_province_zone_city%NOTFOUND;
         END LOOP;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','Out Parameters are :');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','        v_hr_zone='||v_hr_zone);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','        v_hr_province='||v_hr_province);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','        v_city_code='||v_city_code);
      END IF;
      CLOSE cur_province_zone_city ;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','End PROCEDURE  Province_Zone_City');
      END IF;
  EXCEPTION
     WHEN OTHERS THEN
          IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City','Exception in PROCEDURE  Province_Zone_City');
                NULL;
          END IF;
  END;

/*-----------------------------------------------------------------
The Procedure Del_Wh_Def Delete the records in JL_ZZ_AP_INV_DIS_WH
for the Invoice_ID Parameter and the Dis_Lin_Number.
-------------------------------------------------------------------*/
--
-- R12 KI
--
PROCEDURE Del_Wh_Def
             (
               p_inv_dist_id   ap_invoice_distributions_all.invoice_distribution_id%TYPE
             ) IS
   Begin
        /*
        DELETE JL_ZZ_AP_INV_DIS_WH
        WHERE invoice_id = P_Invoice_Id
          AND invoice_distribution_id = P_Dis_Lin_Num;
        */
        -- Bug 4559472
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Del_Wh_Def','Start PROCEDURE Del_Wh_Def');
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Del_Wh_Def','Parameters are :');
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Del_Wh_Def','        p_inv_dist_id='||p_inv_dist_id);
        END IF;
        DELETE jl_zz_ap_inv_dis_wh
        WHERE  invoice_distribution_id = p_inv_dist_id;
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Del_Wh_Def','End PROCEDURE Del_Wh_Def');
        END IF;
   EXCEPTION
       WHEN OTHERS THEN
            IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Del_Wh_Def','Exception in PROCEDURE Del_Wh_Def');
                NULL;
            END IF;
   End;


-- =====================================================================
--                   P U B L I C    O B J E C T S
-- =====================================================================
--
--

--
-- R12 KI
--
PROCEDURE Supp_Wh_Def_Line
            ( p_invoice_id    NUMBER,
              p_inv_dist_id   NUMBER,
              p_tax_payer_id  NUMBER,
              p_ship_to_loc   VARCHAR2,
              p_line_type     VARCHAR2,
              p_vendor_id     NUMBER
             ) IS
   ---------------------------------------------------------------------
   -- Cursor  Supplier Withholding Types.
   ---------------------------------------------------------------------
   CURSOR Supp_Wh_Types(C_Vendor_Id jl_zz_ap_supp_awt_types.vendor_id%TYPE) Is
   SELECT swt.supp_awt_type_id ,
          swt.awt_type_code,
          swc.supp_awt_code_id,
          swc.org_id,                    -- Add Org_ID for MOAC
          tca.tax_id,
          tca.global_attribute7,         -- Zone
          awt.jurisdiction_type,
          awt.province_code,
          awt.city_code
     FROM jl_zz_ap_supp_awt_types       swt,
          jl_zz_ap_sup_awt_cd           swc,
          ap_tax_codes_ALL              tca,                    -- Add _ALL for MOAC
          jl_zz_ap_awt_types            awt
    WHERE swt.vendor_id           =  C_vendor_id                  -- Select only for this Supplier
      AND swt.wh_subject_flag     =  'Y'                          -- Supp subject to the withholding tax type
      AND swc.supp_awt_type_id    =  swt.supp_awt_type_id        -- Join
      AND swc.tax_id              =  tca.tax_id                        -- Join
      AND (tca.inactive_date      >  sysdate                    -- Verify Tax Name Inactive Date
           OR tca.inactive_date   IS NULL)
      AND swc.primary_tax_flag    =  'Y'                          -- Verify the Primary Withholding Tax
      AND awt.awt_type_code       =  swt.awt_type_code                 -- Join
      AND sysdate between nvl(swc.effective_start_date,sysdate) and nvl(swc.effective_end_date,sysdate)
 	    ;                                                                  -- Argentine AWT ER 6624809


   v_provincial_code  jl_ar_ap_provinces.province_code%TYPE;

   v_hr_zone          hr_locations_all.region_1%TYPE;
   v_hr_province      hr_locations_all.region_2%TYPE;
   v_hr_city          hr_locations_all.town_or_city%TYPE;
   v_hr_city_name     hz_geographies.geography_name%TYPE; --Added Bug 6147511
   pc_vendor_id       number;
   p_calling_sequence varchar2(2000):= 'Supp_Wh_Def_Line';


  Begin

      ------------------------------------------------------------------------------------------
      -- Delete the lines in JL_ZZ_AP_INV_DIS.
      ------------------------------------------------------------------------------------------
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Start PROCEDURE Supp_Wh_Def_Line');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Parameters are :');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','        p_invoice_id='||p_invoice_id);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','        p_inv_dist_id='||p_inv_dist_id);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','        p_tax_payer_id='||p_tax_payer_id);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','        p_ship_to_loc='||p_ship_to_loc);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','        p_line_type='||p_line_type);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','        p_vendor_id='||p_vendor_id);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Del_Wh_Def');
      END IF;
      Del_Wh_Def(
                 /*
                 P_Invoice_Id
                ,P_Dis_Lin_Num
                */
                -- Bug 4559472
                p_inv_dist_id);
     ------------------------------------------------------------------------------------------
      --  Get the Vendor_Id from the Vendor_Num (Taxpayer_ID) or Invoice
     ------------------------------------------------------------------------------------------
     IF P_Vendor_Id IS NULL Then
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside IF P_Vendor_Id IS NULL Then');
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Get_Vendor_Id');
        END IF;
        pc_vendor_id := Get_Vendor_Id (/*
                                       v_tax_payer_id,
                                       p_invoice_id
                                       */
                                       p_tax_payer_id,
                                       p_invoice_id);
     Else
        pc_vendor_id := p_vendor_id;
     End IF;
     ------------------------------------------------------------------------------------------
      -- Loop for each Supplier Withholding Type
      -----------------------------------------------------------------------------------------
      FOR  db_reg  IN Supp_Wh_Types(pc_vendor_id) LOOP
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside db_reg  IN Supp_Wh_Types(pc_vendor_id) for pc_vendor_id='||pc_vendor_id);
           END IF;
           ---------------------------------------------------------------------------------
           -- The cursor verify the Supplier Withholding Applicability
           -- Each Supp Withholding Type in the Cursor needs to be check.
           -- Company Agent says if the company have to withhold by this Withholding Type.
           ---------------------------------------------------------------------------------
           IF   ( Company_Agent(db_reg.awt_type_code,
                                -- Added p_invoice_id for R12 LE changes
                                p_invoice_id)) THEN
                                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside IF   ( Company_Agent(db_reg.awt_type_code ..');
                                END IF;
                ----------------------------------------------------------------------------
                -- Validate the withholding type is according to distribution line.
                ----------------------------------------------------------------------------
                IF Validate_Line_Type(
                                      /*
                                      v_line_type,
                                      db_reg.tax_id
                                      */
                                      p_line_type,
                                      db_reg.tax_id) THEN
                                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                              FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside IF Validate_Line_Type( ..');
                                      END IF;
                   -----------------------------------------------------------------------
                   -- Get the information from Zone, Province and City
                   -----------------------------------------------------------------------
                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                           FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Province_Zone_City');
                   END IF;
                   Province_Zone_City
                        (
                         /*
                         v_ship_to_loc  -- IN
                         */
                         p_ship_to_loc  -- IN
                        ,v_hr_zone      -- OUT NOCOPY
                        ,v_hr_province  -- OUT NOCOPY
                        ,v_hr_city
                         );     -- OUT NOCOPY
                   -----------------------------------------------------------------------
                   -- Validate the Jurisdiction
                   -----------------------------------------------------------------------
                   IF ( db_reg.jurisdiction_type = 'PROVINCIAL') THEN
                       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                       FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside  IF ( db_reg.jurisdiction_type = PROVINCIAL)');
                        END IF;
                       --------------------------------------------------------------------
                       --  Verify if the Withholding Tax for the Province is TERRITORY
                       --------------------------------------------------------------------
                       IF Ver_Territorial_Flag (db_reg.province_code)  THEN
                                       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside IF Ver_Territorial_Flag (db_reg.province_code)');
                                END IF;
                          -----------------------------------------------------------------
                          -- Validate if the Ship to Location from Inv Dis Line is in the province.
                          -----------------------------------------------------------------
                          IF db_reg.province_code = v_hr_province THEN
                                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside IF db_reg.province_code = v_hr_province THEN');
                                     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Insert_AWT_Default - 1');
                                END IF;
                                    Insert_AWT_Default
                                  (P_Invoice_Id
                                   -- Bug 4559472
                                      -- ,P_Dis_Lin_Num
                                  , p_inv_dist_id
                                  , db_reg. supp_awt_code_id
                                  , p_calling_sequence
                                  , db_reg.org_id );             -- Add org_Id for MOAC

                          END IF;
                       ELSE -- v_territorial_flag = 'N' is Country Wide
                             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside ELSE Ver_Territorial_Flag (db_reg.province_code)');
                                     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Insert_AWT_Default - 2');
                             END IF;
                             Insert_AWT_Default
                                  (P_Invoice_Id
                                   -- Bug 4559472
                                   -- ,P_Dis_Lin_Num
                                  , p_inv_dist_id
                                  , db_reg. supp_awt_code_id
                                  , p_calling_sequence
                                  , db_reg.org_id );             -- Add org_Id for MOAC

                       END IF; -- PROVINCE Class
                   ELSIF db_reg.jurisdiction_type = 'ZONAL' THEN
                         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                 FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside ELSIF db_reg.jurisdiction_type = ZONAL THEN');
                         END IF;
                         ---------------------------------------------------------------
                         -- The name of the zone is taken from AP_TAX_CODES Global Att 7
                         ---------------------------------------------------------------
                         IF db_reg.global_attribute7 = v_hr_zone     THEN
                            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside IF db_reg.global_attribute7 = v_hr_zone     THEN');
                                    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Insert_AWT_Default - 3');
                            END IF;
                            Insert_AWT_Default
                                 (P_Invoice_Id
                                  -- Bug 4559472
                                  -- ,P_Dis_Lin_Num
                                 , p_inv_dist_id
                                 , db_reg. supp_awt_code_id
                                 , p_calling_sequence
                                 , db_reg.org_id );             -- Add org_Id for MOAC

                         END IF; --Tax_Zone

                   ELSIF db_reg.jurisdiction_type = 'MUNICIPAL' THEN
                         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside ELSIF db_reg.jurisdiction_type = MUNICIPAL THEN');
                         END IF;
                         ---------------------------------------------------------------
                         -- Compare the Withholding Type City with the city in the line
                         ---------------------------------------------------------------
                         --Bug no: 6147511. Added this query to get the city name from geographies table
                        select geography_name
                           into v_hr_city_name
                        from hz_geographies
                        where geography_code= db_reg.city_code
                        and geography_type='CITY';
                        --Bug no: 6147511, Previous condition : IF db_reg.city_code = v_hr_city THEN
                         IF v_hr_city_name = v_hr_city THEN
                            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Insert_AWT_Default - 4');
                            END IF;
                            Insert_AWT_Default
                                 (P_Invoice_Id
                                  -- Bug 4559472
                                  -- ,P_Dis_Lin_Num
                                 , p_inv_dist_id
                                 , db_reg. supp_awt_code_id
                                 , p_calling_sequence
                                 , db_reg.org_id );             -- Add org_Id for MOAC

                         END IF;

                   ELSE -- db_reg.jurisdiction_type = 'FEDERAL'
                           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Inside ELSE FOR db_reg.jurisdiction_type = FEDERAL');
                                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Calling Insert_AWT_Default - 5');
                           END IF;
                           Insert_AWT_Default
                                (P_Invoice_Id
                                 -- Bug 4559472
                                 -- ,P_Dis_Lin_Num
                                , p_inv_dist_id
                                , db_reg. supp_awt_code_id
                                , p_calling_sequence
                                , db_reg.org_id );             -- Add org_Id for MOAC

                   END IF;--jurisdiction type
                END IF;--validate line_type
           END IF;--withholding applicability
      END LOOP; -- Loop for each Supplier Withholding Type
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','End PROCEDURE Supp_Wh_Def_Line');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
           IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def_Line','Exception in PROCEDURE Supp_Wh_Def_Line');
                NULL;
           END IF;
END Supp_Wh_Def_Line;

/*----------------------------------------------------------------------------------------------
   Supp_Wh_Def receive as parameters the P_Invoice_Id and P_Dis_Lin_Num
   If P_Dis_Lin_Num IS NULL this procedure process all the lines in the invoice
   Else Only process the line that receive as parameter.
------------------------------------------------------------------------------------------------*/

--
-- R12 KI
--

PROCEDURE Supp_Wh_Def
             ( P_Invoice_Id        ap_invoices_all.invoice_id%TYPE
             , P_Inv_Line_Num      ap_invoice_lines_all.line_number%TYPE
             , P_Inv_Dist_Id       ap_invoice_distributions_all.invoice_distribution_id%TYPE
             , P_Calling_Module    VARCHAR2
             , P_Parent_Dist_ID    IN Number Default null
             ) IS

   --
   -- R12 KI Changes : 4559472
   --
   CURSOR  Invoice_Distrib IS
   SELECT  invoice_distribution_id
     FROM  ap_invoice_distributions
    WHERE  invoice_id = P_Invoice_ID
    AND    invoice_line_number = P_Inv_Line_Num;

-- Added Cursor  for bug 6869263
   CURSOR c_default_wh_dist (p_related_dist_id number) IS
    SELECT Supp_Awt_Code_Id,
           org_id
      FROM jl_zz_ap_inv_dis_wh
      WHERE invoice_id = p_invoice_id
        AND invoice_distribution_id = p_related_dist_id;

   -- The following variables are used to get the information from the invoice
   -- ditribution lines.
   v_tax_payer_id     ap_invoice_distributions_all.global_attribute2%TYPE;
   v_ship_to_loc      ap_invoice_distributions_all.global_attribute3%TYPE;
   v_line_type        ap_invoice_distributions_all.line_type_lookup_code %TYPE;
   v_last_update_login number := FND_GLOBAL.Login_Id;
   v_last_update_by    number := FND_GLOBAL.User_ID;
   DistWithholdings   Number := 0;
  -- Variable added for bug 6869263
   v_related_dist_id  ap_invoice_distributions_all.related_id%TYPE;

Begin
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Start PROCEDURE Supp_Wh_Def');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Parameters are :');
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','        P_Invoice_Id='||P_Invoice_Id);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','        P_Inv_Line_Num='||P_Inv_Line_Num);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','        P_Inv_Dist_Id='||P_Inv_Dist_Id);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','        P_Calling_Module='||P_Calling_Module);
              FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','        P_Parent_Dist_ID='||P_Parent_Dist_ID);
      END IF;

/*
**  R12 KI Changes :  Pseudo Logic
**
**
**


-- ***** CALLER *****
-- JLZZPIDW for redefault witholding applicability
IF p_inv_dist_id IS NOT NULL THEN


-- ***** CALLER *****
-- Validation Processes
-- APXINWKB (JL.pld) for ship to location change
ELSE p_inv_dist_id IS NULL THEN

   -- ***** CALLER *****
   -- Validate Process in UI
   IF p_calling_module = 'NO_OVERRIDE' THEN
     -- Check if extended withholding distribution line exists for this invoice line

   -- ***** CALLER *****
   -- Validate Process in Invoice Import
   -- APXINWKB (JL.pld) for ship to location change
   ELSE
     -- For each distribution for an invoice line loop

       -- Get ship to location       : LINE
       -- Get taxpayer id            : DIST
       -- Get distribution line type : DIST
       -- Call supp_wh_def_line
       --   p_invoice_id
       --   p_dis_lin_num -> p_dist_line_id
       --   p_tax_payer_id
       --   p_ship_to_loc
       --   p_line_type
       --   p_vendor_id

     -- End loop
   END IF;

END IF;

**
**
** End of Pseudo logic
**
**
*/
      ---------------------------------------------------------------------
      -- Checking calling point
      ---------------------------------------------------------------------
      --Bug no : 6159617 -Removed the IF condition. The P_Calling_Module was
      -- called with null values and the changes made to the witholdings
      -- were overridden by default values on validation.
--      IF P_Calling_Module = 'NO_OVERRIDE' THEN
      --Bug no : 6395850 - Added the following code for handling Redefault withholding button.
         IF p_calling_module = 'JLZZPIDW' THEN
             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','IF p_calling_module = JLZZPIDW THEN');
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Redefaulting the withholdings for distibution id '||P_Inv_Dist_Id);
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Calling Del_Wh_Def');
             END IF;
                 Del_Wh_Def(P_Inv_Dist_Id);
         END IF;
      --Bug no : 6395850 - The existing withholdings are erased and then redefaulted.
         ------------------------------------------------------------------
         -- Checking if the distribution line has withholdings
         ------------------------------------------------------------------
         --Bug no : 6215810 - Changed the query
--         Select 1
           SELECT COUNT(*)
           INTO DistWithholdings
           From jl_zz_ap_inv_dis_wh
          Where invoice_id = P_Invoice_ID
            And invoice_distribution_id = P_Inv_Dist_Id;
--            And rownum = 1;
         --Bug no : 6215810 -Commented the above line
         -- Debug
         IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug ('AWT Defaulting Exist  No Override - Returning');
         END IF;
         -- End Debug
         --Bug no : 6159617 - Changed the IF Condition
--         IF DistWithholdings = 1 Then
         IF DistWithholdings <> 0 THEN
                 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                               FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside IF DistWithholdings <> 0 THEN');
                END IF;
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','End PROCEDURE Supp_Wh_Def - 1');
                END IF;
            Return;
         End IF;
--      End IF;
      --Bug no : 6159617 -Removed the IF condition.
      ---------------------------------------------------------------------
      -- Cheking if parent distribution id is not null
      --------------------------------------------------------------------
      IF P_Parent_Dist_ID IS NOT NULL Then
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside IF P_Parent_Dist_ID IS NOT NULL Then');
         END IF;
         ----------------------------------------------------------
         -- Copy the tax names from the parent distribution line
          ----------------------------------------------------------
         -- Debug
         IF (DEBUG_Var = 'Y') THEN
             JL_ZZ_AP_EXT_AWT_UTIL.Debug ('AWT Defaulting from Parent Dist ID');
         END IF;
         -- End Debug
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','INSERT INTO jl_zz_ap_inv_dis_wh (...');
         END IF;
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
                     ,P_Invoice_Id
                     ,P_Inv_Dist_Id
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
          WHERE      jlid.invoice_distribution_id = P_Parent_Dist_ID
            AND      jlid.invoice_id = P_Invoice_Id;
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','End PROCEDURE Supp_Wh_Def - 2');
            END IF;
            RETURN;
      END IF;
      ----------------------------------------------------------------------
      -- Validate if the parameter P_Inv_Dis_Id IS NULL
      ----------------------------------------------------------------------
      IF p_inv_dist_id IS NOT NULL THEN
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside IF p_inv_dist_id IS NOT NULL THEN');
         END IF;
         -------------------------------------------------------------------
         -- Information Invoice Distributions
         -------------------------------------------------------------------
         -- Bug 4559472
         -- Revert changes for R12 - Bug 4674638
         -- Debug
          IF (DEBUG_Var = 'Y') THEN
            JL_ZZ_AP_EXT_AWT_UTIL.Debug ('AWT Defaulting From Param Inv Dist ID');
          END IF;
         -- End Debug

          SELECT    apid.global_attribute2     -- Taxpayer Id for Colombia
                  ,apid.global_attribute3     -- Ship to Location Argentina/Colombia
          --      , apil.ship_to_location_id   -- Ship to Location Argentina/Colombia
                  , apid.line_type_lookup_code -- Line Type
            INTO  v_tax_payer_id,
                  v_ship_to_loc,
                  v_line_type
            FROM  AP_Invoice_Distributions apid,
                  AP_Invoice_Lines apil
           WHERE  apid.invoice_id               = p_invoice_id
             AND  apid.invoice_distribution_id  = p_inv_dist_id
             AND  apid.invoice_line_number      = apil.line_number
             AND  apid.invoice_id               = apil.invoice_id;
             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Calling Supp_Wh_Def_Line - 1');
             END IF;
            Supp_Wh_Def_Line(  P_Invoice_Id
                             , P_Inv_Dist_id
                             , v_tax_payer_id
                             , v_ship_to_loc
                             , v_line_type
                             , null
                            );

        ELSE
             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside ELSE p_inv_dist_id IS NOT NULL THEN');
             END IF;
             -------------------------------------------------------------
             -- Loop for each Invoice Distribution Line.
             -------------------------------------------------------------
             -- Debug
             IF (DEBUG_Var = 'Y') THEN
                JL_ZZ_AP_EXT_AWT_UTIL.Debug ('AWT Defaulting for distributions');
             END IF;
             -- End Debug
            FOR db_reg IN Invoice_Distrib LOOP
                 -------------------------------------------------------------------
                 -- Information Invoice Distribution Lines.
                 -------------------------------------------------------------------
                SELECT    apid.global_attribute2      -- Taxpayer Id for Colombia
                        ,apid.global_attribute3     -- Ship to Location Argentina/Colombia
                    --  , apil.ship_to_location_id    -- Ship to Location Argentina/Colombia
                        , apid.line_type_lookup_code  -- Line Type
                INTO  v_tax_payer_id,
                      v_ship_to_loc,
                      v_line_type
                FROM  AP_Invoice_Distributions   apid,
                      AP_Invoice_Lines           apil
                WHERE  apid.invoice_id                = P_Invoice_Id
                AND  apid.invoice_distribution_id   = db_reg.invoice_distribution_id
                AND  apid.invoice_line_number       = apil.line_number
                AND  apid.invoice_id                = apil.invoice_id;
                --bug 6346106 changes - The following code is added
                SELECT COUNT(*)
                INTO DistWithholdings
                FROM jl_zz_ap_inv_dis_wh
                WHERE invoice_id = P_Invoice_ID
                AND invoice_distribution_id = db_reg.invoice_distribution_id;
                IF (DEBUG_Var = 'Y') THEN
                         JL_ZZ_AP_EXT_AWT_UTIL.Debug ('AWT Defaulting Exist  No Override - Returning');
                END IF;

                IF DistWithholdings <> 0 THEN
                        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                       FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside IF DistWithholdings <> 0 THEN');
                        END IF;
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','End PROCEDURE Supp_Wh_Def - 3');
                        END IF;
                        --Return;
                --End IF;
                ELSE
                  -- Code added for bug 6869263
                  IF upper(p_calling_module) = upper('AP_APPROVAL_PKG.Approval<-APXINWKB') and  DistWithholdings = 0 AND
                           v_line_type NOT IN ('IPV','ERV','TRV','TIPV','TERV') THEN

                     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside call to ap_approval_pkg and Distwith =0 and line type not in variance');
                     END IF;

                  ELSIF upper(p_calling_module) = upper('AP_APPROVAL_PKG.Approval<-APXINWKB') and  DistWithholdings = 0 AND
                     v_line_type IN ('IPV','ERV','TRV','TIPV','TERV') THEN

                     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside call to ap_approval_pkg and Distwith =0 and line type in variance');
                     END IF;

                    SELECT related_id
                      INTO v_related_dist_id
                      FROM ap_invoice_distributions
                     WHERE invoice_id = P_Invoice_Id
                       AND invoice_distribution_id = db_reg.invoice_distribution_id;

                     FOR l_def_wh_dist IN c_default_wh_dist(v_related_dist_id) LOOP

                        INSERT INTO jl_zz_ap_inv_dis_wh (
                                     inv_distrib_awt_id
                                    ,invoice_id
                                    ,distribution_line_number
                                    ,invoice_distribution_id
                                    ,supp_awt_code_id
                                    ,created_by
                                    ,creation_date
                                    ,last_updated_by
                                    ,last_update_date
                                    ,last_update_login
                                    ,org_id                          -- Add org_id for MOAC
                                    )
                             VALUES (
                                    jl_zz_ap_inv_dis_wh_s.nextval
                                   ,P_Invoice_Id
                                   ,-99
                                   , db_reg.invoice_distribution_id
                                   ,l_def_wh_dist.Supp_Awt_Code_Id
                                   ,v_last_update_by
                                   ,sysdate
                                   ,v_last_update_by
                                   ,sysdate
                                   ,v_last_update_login
                                   ,l_def_wh_dist.Org_Id
                                   );

                      END LOOP;

                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Inside call to ap_approval_pkg and Distwith =0 and line type in variance, inserted record into jl_zz_ap_inv_dis_wh table ');
                     END IF;

                  ELSE
                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                         FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Calling Supp_Wh_Def_Line - 2');
                       END IF;
                       --bug 6346106 changes end
                      Supp_Wh_Def_Line(
                                   P_Invoice_Id
                                 , db_reg.invoice_distribution_id
                                 , v_tax_payer_id
                                 , v_ship_to_loc
                                 , v_line_type
                                 , null
                                      );
                  END IF; -- upper(p_calling_module)
                END IF; -- DistWithholings <> 0
           END LOOP; -- Invoice Distribution Line
         END IF; -- P_Dis_Lin_Num IS NULL
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','End PROCEDURE Supp_Wh_Def - 4');
      END IF;
EXCEPTION
      WHEN OTHERS THEN
           IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_Def','Exception in PROCEDURE Supp_Wh_Def');
                   NULL;
           END IF;
END Supp_Wh_Def;

/*----------------------------------------------------------------------------------------------
   Carry_Withholdings_Prepay copy the withholdings from Prepayment Invoice
   Item Line to Standard Invoice PREPAY line.
------------------------------------------------------------------------------------------------*/
--
-- R12 KI
--

PROCEDURE Carry_Withholdings_Prepay
                    (P_prepay_dist_id     Number
                    ,P_Invoice_Id         Number
                    ,P_inv_dist_id        Number
                    ,P_User_Id            Number
                    ,P_last_update_login  Number
                    ,P_Calling_Sequence   Varchar2
                    ) IS
    l_prepay_id   Number;

    l_prepay_dist_line_num Number;

    l_calling_sequence Varchar2(2000);
Begin
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','Start PROCEDURE Carry_Withholdings_Prepay');
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','Parameters are :');
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','        P_prepay_dist_id='||P_prepay_dist_id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','        P_Invoice_Id='||P_Invoice_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','        P_inv_dist_id='||P_inv_dist_id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','        P_User_Id='||P_User_Id);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','        P_last_update_login='||P_last_update_login);
            FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','        P_Calling_Sequence='||P_Calling_Sequence);
    END IF;
    -----------------------------------
    -- Value for p_calling_sequence
    -----------------------------------
   l_calling_sequence := P_calling_sequence||'Carry_Withholdings_Prepay';

   ------------------------------------------------------------------------
   -- Get invoice_id and invoice_distribution_id from p_prepay_dist_id (PK)
   ------------------------------------------------------------------------
   /*
   **   Bug 4559474
   **
   **   Commented out the query as invoice_id and invoice_distribution_id
   **   for payment_distribution_id is passed from AP through
   **   input parameters.
   **
      SELECT  invoice_id,
              invoice_distribution_id
        INTO  l_prepay_id,
              l_prepay_dist_line_num
        FROM  ap_invoice_distributions
       WHERE  invoice_distribution_id   =   P_prepay_dist_id;
   */

   -----------------------------------------------------------------------
   -- Copy the withholdings to the new PREPAY line.
   -- Insert Withholdings in the table.
   ----------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','INSERT INTO jl_zz_ap_inv_dis_wh ...');
        END IF;
        INSERT INTO jl_zz_ap_inv_dis_wh
         (INV_DISTRIB_AWT_ID,
          INVOICE_ID,
          distribution_line_number,  -- Bug 4559474
          invoice_distribution_id,   -- Bug 4559474
          SUPP_AWT_CODE_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          ORG_ID,
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
          ATTRIBUTE15)
       SELECT
          JL_ZZ_AP_INV_DIS_WH_S.nextval,
          P_Invoice_Id,
          -99,            -- Bug 4559474
          p_inv_dist_id,  -- Bug 4559474
          idw.supp_awt_code_id,
          P_user_id,
          SYSDATE,
          DECODE(P_last_update_login,-999,P_user_id,P_last_update_login),
          SYSDATE,
          DECODE(P_last_update_login,-999,P_user_id,P_last_update_login),
          idw.ORG_ID,
          idw.ATTRIBUTE_CATEGORY,
          idw.ATTRIBUTE1,
          idw.ATTRIBUTE2,
          idw.ATTRIBUTE3,
          idw.ATTRIBUTE4,
          idw.ATTRIBUTE5,
          idw.ATTRIBUTE6,
          idw.ATTRIBUTE7,
          idw.ATTRIBUTE8,
          idw.ATTRIBUTE9,
          idw.ATTRIBUTE10,
          idw.ATTRIBUTE11,
          idw.ATTRIBUTE12,
          idw.ATTRIBUTE13,
          idw.ATTRIBUTE14,
          idw.ATTRIBUTE15
       FROM jl_zz_ap_inv_dis_wh idw
      WHERE idw.invoice_distribution_id = p_prepay_dist_id; -- Bug 4559474
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','End PROCEDURE Carry_Withholdings_Prepay');
      END IF;
EXCEPTION
     WHEN OTHERS THEN
          IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Carry_Withholdings_Prepay','Exception in PROCEDURE Carry_Withholdings_Prepay');
                  NULL;
          END IF;
END Carry_Withholdings_Prepay;
/*----------------------------------------------------------------------------------------------
   Supp_Wh_ReDef receive as parameters the P_Invoice_Id and P_Vendor_ID
   Bug 3609925
------------------------------------------------------------------------------------------------*/
PROCEDURE Supp_Wh_ReDefault
             ( P_Invoice_Id  ap_invoices_all.invoice_id%TYPE
             , P_Vendor_ID   po_vendors.vendor_id%TYPE
             ) IS

   CURSOR  Invoice_Distrib IS
   SELECT  invoice_distribution_id
     FROM  ap_invoice_distributions
    WHERE  invoice_id = P_Invoice_ID;
   -- The following variables are used to get the information from the invoice
   -- ditribution lines.
   v_tax_payer_id     ap_invoice_distributions_all.global_attribute2%TYPE;
   v_ship_to_loc      ap_invoice_distributions_all.global_attribute3%TYPE;
   v_line_type        ap_invoice_distributions_all. line_type_lookup_code%TYPE;

   Begin
       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','Start PROCEDURE Supp_Wh_ReDefault');
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','Parameters are :');
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','        P_Invoice_Id='||P_Invoice_Id);
               FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','        P_Vendor_ID='||P_Vendor_ID);
       END IF;
       -------------------------------------------------------------
       -- Loop for each Invoice Distribution Line.
       -------------------------------------------------------------
       FOR db_reg IN Invoice_Distrib LOOP
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','Inside FOR db_reg IN Invoice_Distrib LOOP');
         END IF;
       -------------------------------------------------------------------
       -- Information Invoice Distribution Lines.
       -------------------------------------------------------------------
       -- Revert changes for R12 - Bug 4674638
         SELECT apid.global_attribute2     -- Taxpayer Id for Colombia
               ,apid.global_attribute3          -- Ship to Location Argentina/Colombia
               ,apid.line_type_lookup_code -- Line Type
          INTO  v_tax_payer_id,
                v_ship_to_loc,
                v_line_type
          FROM  AP_Invoice_Distributions apid,
                AP_Invoice_Lines apil
          WHERE apid.invoice_id               = P_Invoice_Id
          AND apid.invoice_distribution_id = db_reg.invoice_distribution_id
          AND apil.line_number = apid.invoice_line_number
          AND apid.invoice_id = apil.invoice_id;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','Calling Supp_Wh_Def_Line');
          END IF;
          Supp_Wh_Def_Line(P_Invoice_Id
                          ,db_reg.invoice_distribution_id
                          ,v_tax_payer_id
                          ,v_ship_to_loc
                          ,v_line_type
                          ,p_vendor_id
                          );

       END LOOP; -- Invoice Distribution Line
       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','End PROCEDURE Supp_Wh_ReDefault');
       END IF;
   EXCEPTION
      WHEN OTHERS THEN
           IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_ZZ_AP_AWT_DEFAULT_PKG.Supp_Wh_ReDefault','Exception in PROCEDURE Supp_Wh_ReDefault');
                   NULL;
           END IF;
 END Supp_Wh_ReDefault;


END JL_ZZ_AP_AWT_DEFAULT_PKG; -- Package


/
