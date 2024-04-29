--------------------------------------------------------
--  DDL for Package JL_ZZ_AP_AWT_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AP_AWT_DEFAULT_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzpwds.pls 120.15.12010000.3 2010/02/26 08:23:44 rsaini ship $ */

--
-- R12 KI
--
PROCEDURE Insert_AWT_Default(
              P_Invoice_Id			IN	ap_invoices_all.invoice_id%TYPE,
              P_Inv_Dist_Id  		IN	ap_invoice_distributions_all.invoice_distribution_id%TYPE,
              P_Supp_Awt_Code_Id		IN	jl_zz_ap_sup_awt_cd.supp_awt_code_id%TYPE,
              p_calling_sequence   		IN    	VARCHAR2,
              P_Org_Id           		IN	jl_zz_ap_sup_awt_cd.org_id%TYPE);

FUNCTION Ver_Territorial_Flag
            (P_Province_Code jl_ar_ap_provinces.province_code%TYPE
            ) return boolean ;

FUNCTION Get_Vendor_Id
            (P_Tax_Payer_Id ap_invoice_distributions_all.global_attribute2%TYPE
            ,P_Invoice_Id ap_invoices_all.invoice_id%TYPE
            ) return number;

FUNCTION Company_Agent
            (P_Awt_Type_Code jl_zz_ap_awt_types.awt_type_code%TYPE,
             P_Invoice_Id ap_invoices_all.invoice_id%TYPE)
            return boolean ;

FUNCTION Validate_Line_Type
            (v_dist_type  varchar2
            ,v_tax_id     ap_tax_codes_all.tax_id%type)
             return boolean;

PROCEDURE  Province_Zone_City
              (p_ship_to_location_id in hr_locations_all.location_id%TYPE
              ,v_hr_zone out NOCOPY hr_locations_all.region_1%TYPE
              ,v_hr_province out NOCOPY  hr_locations_all.region_2%TYPE
              ,v_city_code out NOCOPY hr_locations_all.town_or_city%TYPE);

--
-- R12 KI
--
PROCEDURE Del_Wh_Def
             (p_inv_dist_id  ap_invoice_distributions_all.invoice_distribution_id%TYPE
             ) ;

--
-- R12 KI
--
PROCEDURE Supp_Wh_Def_Line
            (p_invoice_id   NUMBER,
             p_inv_dist_id  NUMBER,
             p_tax_payer_id NUMBER,
             p_ship_to_loc  VARCHAR2,
             p_line_type    VARCHAR2,
             p_vendor_id    NUMBER
             ) ;
--
-- R12 KI
--
PROCEDURE Supp_Wh_Def
             ( P_Invoice_Id   ap_invoices_all.invoice_id%TYPE
             , P_Inv_Line_Num ap_invoice_lines_all.line_number%TYPE
             , P_Inv_Dist_Id  ap_invoice_distributions_all.invoice_distribution_id%TYPE
             , P_Calling_Module VARCHAR2
             , P_Parent_Dist_ID IN Number Default null
             ) ;
--
-- R12 KI
--
PROCEDURE Carry_Withholdings_Prepay
                    (P_prepay_dist_id     Number
                    ,P_Invoice_Id         Number
                    ,P_inv_dist_id        Number
                    ,P_User_Id            Number
                    ,P_last_update_login  Number
                    ,P_Calling_Sequence   Varchar2);


/*----------------------------------------------------------------------------------------------
   Supp_Wh_ReDef receive as parameters the P_Invoice_Id and P_Vendor_ID
   Bug 3609925
------------------------------------------------------------------------------------------------*/

PROCEDURE Supp_Wh_ReDefault
             ( P_Invoice_Id  ap_invoices_all.invoice_id%TYPE
             , P_Vendor_ID   po_vendors.vendor_id%TYPE
             );

END JL_ZZ_AP_AWT_DEFAULT_PKG;

/
