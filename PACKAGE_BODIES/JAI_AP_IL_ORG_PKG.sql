--------------------------------------------------------
--  DDL for Package Body JAI_AP_IL_ORG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_IL_ORG_PKG" AS
--$Header: jaiaporgb.pls 120.2.12010000.1 2008/07/29 10:16:06 appldev ship $

--+=======================================================================+
--|               Copyright (c) 2007 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=======================================================================
--| FILENAME
--|     jaiaporgb.pls
--|
--| DESCRIPTION
--|
--|     This package contains the PL/SQL tables/procedures/functions
--|     used by the APXINWKB.fmb form for calling India Localization form
--|
--|
--|
--|
--|
--| TYPE LIEST
--|
--|
--| PROCEDURE LIST
--|
--|
--|
--| HISTORY
--|    15-Feb-2008   Eric changed the function FUN_TDS_INVOICE for the bug#6787209
--|
--+======================================================================*/



--==========================================================================
--  FUNCTION NAME:
--
--    FUN_IL_ORG
--    Returns true if IL is installed at customer instance

--==========================================================================



FUNCTION FUN_IL_ORG (P_CURRENCY VARCHAR2) RETURN boolean  IS
BEGIN
IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done( p_Owner => 'JA',p_Event_Name => 'JAI_EXISTENCE_OF_TABLES' ) = TRUE ) AND  P_CURRENCY ='INR'  Then
Return True;
Else
      Return False;
End if;
END FUN_IL_ORG;




--==========================================================================
--  FUNCTION NAME:
--
--    FUN_TDS_INVOICE
--    /*Returns true if invoice is a TDS invoice */ --bug#6787209
--    Returns false if invoice is a TDS invoice
--
-- HISTORY
--    15-Feb-2008   Eric changed the function FUN_TDS_INVOICE for the bug#6787209

--==========================================================================
FUNCTION FUN_TDS_INVOICE( P_INVOICE_ID NUMBER) RETURN BOOLEAN IS
l_invoice_id number;
Begin
     Begin
       --deleted by eric for bug#6787209 on Feb 15,2008 begin
       ------------------------------------------------------------------
       /*
       select 1 into l_invoice_id from dual
       where not exists ( select invoice_id from jai_ap_tds_invoices where invoice_id = P_INVOICE_ID );  -- :inv_sum_folder.invoice_id
       */
       ------------------------------------------------------------------
       --deleted by eric for bug#6787209 on Feb 15,2008 end

       --added by eric for bug#6787209 on Feb 15,2008 begin
       ------------------------------------------------------------------
       select
         0
       into
         l_invoice_id
       from
         ap_invoices_all
       where source = 'INDIA TDS'
         and invoice_num like '%TDS%'
         and invoice_id = P_INVOICE_ID;
       ------------------------------------------------------------------
       --added by eric for bug#6787209 on Feb 15,2008 end

     Exception
      When no_data_found then
      --l_invoice_id :=0;bug#6787209
      l_invoice_id :=1;
    End;
    if l_invoice_id = 1 then
     Return True;
    else
     Return False;
    end if;
 End;



--==========================================================================
--  FUNCTION NAME:
--
--    FUN_MISC_LINE
--    Returns true if  invoice has MISC lines created by IL

--==========================================================================


FUNCTION FUN_MISC_LINE (P_INVOICE_ID NUMBER,P_LOOKUP_CODE VARCHAR2,P_LINE_NUMBER NUMBER ) RETURN BOOLEAN IS
v_misc_line number(10);
BEGIN
  Begin
  select 1 into v_misc_line from dual
  where exists (select 1 from ap_invoice_lines ap, jai_ap_invoice_lines jap
                where jap.invoice_id = P_INVOICE_ID --:INV_SUM_FOLDER.INVOICE_ID
                and   jap.line_type_lookup_code = P_LOOKUP_CODE --:LINE_SUM_FOLDER.LINE_TYPE_LOOKUP_CODE
                and   jap.invoice_line_number =  P_LINE_NUMBER --:LINE_SUM_FOLDER.LINE_NUMBER
                and   ap.invoice_id = jap.invoice_id
                and   jap.line_type_lookup_code ='MISCELLANEOUS'
                and   jap.invoice_line_number = ap.line_number);
 Exception
  When no_data_found then
      v_misc_line := 0;
 End;
If v_misc_line = 1 then
  Return True;
Else
  Return False;
End  If;
END FUN_MISC_LINE;



--==========================================================================
--  FUNCTION NAME:
--
--    FUN_MISC_PO
--    Returns true if invoice has MISC lines

--==========================================================================


FUNCTION FUN_MISC_PO (P_INVOICE_ID NUMBER) RETURN BOOLEAN IS
v_check number(10);
BEGIN
  Begin
  select 1 into v_check from dual
  where exists ( select 1 from jai_ap_invoice_lines jp where jp.invoice_id = P_INVOICE_ID and line_type_lookup_code ='MISCELLANEOUS' );
  Exception
   When no_data_found then
   v_check := 0;
  End;
IF v_check = 1 then
  Return True;
Else
  Return False;
End If;
END FUN_MISC_PO;




--==========================================================================
--  FUNCTION NAME:
--
--    fun_tax_cat_id
--    Returns the tax category id for a supplier

--==========================================================================

FUNCTION fun_tax_cat_id ( p_supplier_id number ,
                          p_supplier_site_id number ,
			  p_invoice_id NUMBER ,
                          p_line_number NUMBER
			  			  )return number as
-- when user changes the tax_category_id
cursor get_trx_tax_ctg_id ( p_invoice_id NUMBER , p_line_number NUMBER) is
select tax_category_id from jai_ap_invoice_lines
where invoice_id =p_invoice_id
and invoice_line_number =p_line_number
and LINE_TYPE_LOOKUP_CODE = 'ITEM';

-- when the new invoice is created or supplier is changed
cursor get_setup_tax_category_id ( p_supplier_id number , p_supplier_site_id number) is
select tax_category_id from jai_cmn_vendor_sites where vendor_id =p_supplier_id
and vendor_site_id = p_supplier_site_id;


l_tax_cat_id number;

begin


open get_trx_tax_ctg_id ( p_invoice_id , p_line_number);
fetch get_trx_tax_ctg_id into l_tax_cat_id;
close get_trx_tax_ctg_id;

   jai_cmn_utils_pkg.print_log('AP_STAND.log',' in JAI_AP_IL_ORG_PKG l_tax_cat_id  :'||l_tax_cat_id);

if l_tax_cat_id is null  then

	open get_setup_tax_category_id ( p_supplier_id , p_supplier_site_id );
	fetch get_setup_tax_category_id into l_tax_cat_id;
	close get_setup_tax_category_id;

end if;


return l_tax_cat_id;

end fun_tax_cat_id;

END JAI_AP_IL_ORG_PKG;

/
