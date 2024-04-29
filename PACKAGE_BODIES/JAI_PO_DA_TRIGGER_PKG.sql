--------------------------------------------------------
--  DDL for Package Body JAI_PO_DA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_DA_TRIGGER_PKG" AS
/* $Header: jai_po_da_t.plb 120.1 2007/06/05 05:18:54 bgowrava ship $ */

/*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_DA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_DA_ARI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	/* About this Trigger Creation Date : 20-Apr-2001 Ramakrishna*/

--This trigger is used to default the taxes
--when Standard PO is created from a Standrad Requisition using AutoCreate.

--When Standard PO is created from a Standard Requisition
--Using AutoCreate, AutoCreate inserts details into PO_HEADERS_ALL,PO_LINE_LOCATIONS_ALL,
-- PO_DISTRIBUTIONS_ALL

--In PO_DISTRIBUTIONS_ALL , REQ_DISTRIBUTION_ID will be same as
--DISTRIBUTION_ID in PO_REQ_DISTRIBUTIONS_ALL and REQ_DISTRIBUTION_ID is inserted into
--PO_DISTRIBUTIONS_ALL only when Standard PO is created from a Standard Requisition using
--AutoCreate, other wise it should be null.

--This trigger will not fire if the user creates Requisition using Requisition Localized screen.

--This trigger will not fire if Override_flag for the Vendor  Vendor_site_id is not checked.

--This trigger fetches details from PO_HEADERS_ALL using PO_HEADER_ID and
--jai_po_tax_pkg.copy_reqn_taxes procedure is called.

/* End of About this trigger */
  v_org_id                       NUMBER;
  v_type_lookup_code             VARCHAR2(10);
  v_quot_class_code              VARCHAR2(25);
  v_curr                         VARCHAR2(15);
  v_ship_loc_id                  NUMBER;
  v_po_line_id                   NUMBER;  --File.Sql.35 Cbabu        := pr_new.Po_Line_Id ;
  v_po_hdr_id                    NUMBER; --File.Sql.35 Cbabu        := pr_new.Po_Header_Id;
  v_cre_dt                       DATE;   --File.Sql.35 Cbabu          := pr_new.Creation_Date;
  v_cre_by                       NUMBER; --File.Sql.35 Cbabu        := pr_new.Created_By;
  v_last_upd_dt                  DATE  ; --File.Sql.35 Cbabu        := pr_new.Last_Update_Date ;
  v_last_upd_by                  NUMBER; --File.Sql.35 Cbabu        := pr_new.Last_Updated_By;
  v_last_upd_login               NUMBER; --File.Sql.35 Cbabu        := pr_new.Last_Update_Login;
  v_rate                         NUMBER; --File.Sql.35 Cbabu        := pr_new.rate;
  v_line_location_id             NUMBER; --File.Sql.35 Cbabu        := pr_new.line_location_id;
  v_rate_type                    VARCHAR2(100);
  v_rate_date                    DATE;
  v_override_flag                VARCHAR2(1);
  v_sup_id                       NUMBER;
  v_sup_site_id                  NUMBER;
  v_count1                       NUMBER;
  v_count                        number;
  v_style_id                     po_headers_all.style_id%TYPE; --Added by Sanjikum for Bug#4483042

 CURSOR get_po_hdr(c_po_header_id number) IS
 SELECT type_lookup_code,Quotation_Class_Code,Ship_To_Location_Id,
        rate, rate_type, rate_date,currency_code,
        style_id --Added by Sanjikum for Bug#4483042
   FROM po_headers_all
  WHERE po_header_id = v_po_hdr_id;

  -- Get the Inventory Organization Id

 CURSOR Fetch_Org_Id_Cur IS
 SELECT Inventory_Organization_Id
 FROM   Hr_Locations
 WHERE  Location_Id = v_ship_loc_id;

  --Added to check value for Tax Override Flag

  CURSOR tax_override_flag_cur(c_supplier_id number, c_supp_site_id number) IS
  SELECT override_flag
  FROM   JAI_CMN_VENDOR_SITES
  WHERE  vendor_id = c_supplier_id
  AND    vendor_site_id = c_supp_site_id;

   --added, Bgowrava for Bug#6084636
	  Cursor c_get_tax_modified_flag IS
	  SELECT tax_modified_flag
	      FROM JAI_PO_LINE_LOCATIONS
	    WHERE line_location_id = pr_new.line_location_id ;
  lv_tax_modified_flag VARCHAR2(1) ;

  CURSOR get_vendor_info IS
  SELECT nvl(Vendor_id,0), nvl(vendor_Site_Id,0)
  /* Added by Brathod for bug#4242351 */
  ,rate
  ,rate_type
  ,rate_date
  ,currency_code
  /* End of Bug#4242351 */
  FROM   Po_Headers_All
  WHERE  Po_Header_Id = v_po_hdr_id;

  CURSOR Line_Loc_Cur( lineid IN NUMBER ) IS
  SELECT Line_Location_Id
  FROM   po_line_locations_all
  WHERE  Po_Line_Id = lineid;

 -- End of addition
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Po_dist_Tax_Insert_Trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details

1.        09/11/2004    ssumaith - bug# 3949401 Version#115.1

                        commented the code which returns when the new.po_release_id is null

                        moved the code which returns the control if taxes are already present in the JAI_PO_TAXES table
                        for the current line_location_id to the else part of the shipment_type <> 'BLANKET'

                        Added code to delete taxes from the JAI_PO_LINE_LOCATIONS and JAI_PO_TAXES
                        when the new.req_distribution_id is not null

                        Added cursor and code for INR check and returning code if set of books currency is a non india currency.

2. 29/Nov/2004  Aiyer for bug#4035566. Version#115.2
                  Issue:-
          The trigger should not get fired when the  non-INR based set of books is attached to the current operating unit
          where transaction is being done.

          Fix:-
          Function jai_cmn_utils_pkg.check_jai_exists is being called which returns the TRUE if the currency is INR and FALSE if the currency is
          NON-INR
                  Removed the cursor c_Sob_Cur and the variable lv_currency_code

                  Dependency Due to this Bug:-
                   The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0. introduced through the bug 4033992

3. 31/MAR/2005   BRATHOD For Bug#4242351, Version#115.4
     Issue :- Procedure jai_po_tax_pkg.copy_reqn_taxes is modified for mutating error and procedure signature
              has been changed and four new arguments are added.  So call to jai_po_tax_pkg.copy_reqn_taxes
        procedure in this trigger needs to be modified.
     Resolution:-  Call to jai_po_tax_pkg.copy_reqn_taxes is modified by passing required arguments.

4.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                  DB Entity as required for CASE COMPLAINCE.  Version 116.1

5. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

6. 08-Jul-2005    Sanjikum for Bug#4483042
                  1) Added a call to jai_cmn_utils_pkg.validate_po_type, to check whether for the current PO
                     IL functionality should work or not.

7. 08-Jul-2005    Sanjikum for Bug#4483042, file version 117.2
                  1) Added a new column style_id in the cursor - get_po_hdr

8. 17-Aug-2005   Ramananda for bug#4513549 during R12 Sanity Testing. jai_mrg_t.sql File Version 120.2
                 Ported the jai_po_da_t1.sql 120.2 changes
                 Commented out the code which is deleting the taxes for the current
                 line location id. This is not required after the current fix

9. 04-Jun-2007  Bgowrava for Bug#6084636
							 Issue :
								 When the tax_override_flag = 'Y', existing taxes must be deleted and Requisition taxes
								 must get defaulted.

							 Fix :
								 Added code to delete taxes if the tax_modified_flag is  'N' and tax_override_flag = 'N'

							 Dependency :
								There is a functional dependency on this Bug for all future Bugs.



 Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On
ja_in_intrfc_lines_aft_ins_trg
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.2              4035566        IN60105D2 +        ja_in_util_pkg_s.sql  115.0     Aiyer    29-Nov-2004  Call to this function.
                                  4033992            ja_in_util_pkg_b.sql  115.0

120.2                                                jai_po_rla_t1.sql     120.2
                                                     (Functional)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  --File.Sql.35 Cbabu
  v_po_line_id                  := pr_new.Po_Line_Id ;
  v_po_hdr_id                   := pr_new.Po_Header_Id;
  v_cre_dt                      := pr_new.Creation_Date;
  v_cre_by                      := pr_new.Created_By;
  v_last_upd_dt                 := pr_new.Last_Update_Date ;
  v_last_upd_by                 := pr_new.Last_Updated_By;
  v_last_upd_login              := pr_new.Last_Update_Login;
  v_rate                        := pr_new.rate;
  v_line_location_id            := pr_new.line_location_id;

  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */
  --IF jai_cmn_utils_pkg.check_jai_exists ( p_calling_object      => 'JA_IN_PO_DIST_TAX_INSERT_TRG' ,
  --                 p_set_of_books_id     => pr_new.set_of_books_id
  --                               )  = FALSE
  --THEN
    /*
  || return as the current set of books is NON-INR based
  */
  --  RETURN;
  -- END IF;

  IF pr_new.req_distribution_id is null THEN
    RETURN;
  END IF;

  OPEN get_po_hdr(v_po_hdr_id);
  FETCH get_po_hdr into v_type_lookup_code,v_Quot_Class_Code,v_Ship_Loc_Id,
         v_rate, v_rate_type, v_rate_date,v_curr,
         v_style_id; --Added by Sanjikum for Bug#4483042
  CLOSE get_po_hdr;

  --code added by Sanjikum for Bug#4483042
  IF jai_cmn_utils_pkg.validate_po_type(p_style_id => v_style_id) = FALSE THEN
    return;
  END IF;

     --Added to check value for Tax Override Flag

	  OPEN  get_vendor_info;
	  FETCH get_vendor_info into v_sup_id
	                           , v_sup_site_id
	  /* Added by brathod for bug#4242351 */
	         , v_rate
	         , v_rate_type
	         , v_rate_date
	         , v_curr
	  /* End of Bug# 4242351 */
	         ;
	  CLOSE get_vendor_info;

	  OPEN  tax_override_flag_cur(v_sup_id, v_sup_site_id);
	  FETCH tax_override_flag_cur into v_override_flag;
	  CLOSE tax_override_flag_cur;

	   --added, Bgowrava for Bug#6084636
		    OPEN c_get_tax_modified_flag ;
		    FETCH c_get_tax_modified_flag INTO lv_tax_modified_flag ;
		    CLOSE c_get_tax_modified_flag;
  --added, Bgowrava for Bug#6084636

    /* Bug 4513549. Commented delete as this is no more required
     after the new functionality change */

  /*

   if pr_new.po_release_id is  null then
     DELETE from ja_in_po_line_location_taxes
     WHERE line_location_id = v_line_location_id;

     DELETE from ja_in_po_line_locations
     WHERE line_location_id = v_line_location_id;

     return;

         the else and the part of code to execute when the else is met is
        added by ssumaith - bug#3949401

  else */

  --START, added, Bgowrava for Bug#6084636
  if pr_new.po_release_id is  null then
	     -- added, Harshita for Bug 4618717
	     IF nvl(v_override_flag,'N') = 'N' and NVL(lv_tax_modified_flag, 'N') = 'N' THEN

	       DELETE from JAI_PO_TAXES
	       WHERE line_location_id = v_line_location_id;

	       DELETE from JAI_PO_LINE_LOCATIONS
	       WHERE line_location_id = v_line_location_id;

	     END IF ;

	     return;
	     /*
	       the else and the part of code to execute when the else is met is added by ssumaith - bug#3949401
	     */
  else
--END, added, Bgowrava for Bug#6084636
     SELECT count(line_location_id)
     into   v_count1
     FROM   JAI_PO_LINE_LOCATIONS
     WHERE  line_location_id=v_line_location_id;

     IF v_count1 > 0 THEN
        RETURN;
     END IF;
     /* bug# 3949401  */
--  end if; -- End for bug4513549
end if;



  IF nvl(v_override_flag,'N') = 'Y' THEN
       jai_po_tax_pkg.copy_reqn_taxes(v_sup_Id            ,
                                  v_sup_Site_Id       ,
                                  v_Po_Hdr_Id         ,
                                  v_Po_Line_Id        ,
                                  v_Line_Location_id  ,
                                  v_Type_Lookup_Code  ,
                                  v_Quot_Class_Code   ,
                                  v_Ship_Loc_Id       ,
                                  v_Org_Id            ,
                                  v_Cre_Dt            ,
                                  v_Cre_By            ,
                                  v_Last_Upd_Dt       ,
                                  v_Last_Upd_By       ,
                                  v_Last_Upd_Login
          /* Added by brathod for bug# 4242351 */
         , v_rate
         , v_rate_type
         , v_rate_date
         , v_curr
          /* End of Bug#4242351 */
                                 );

  END IF;


  END ARI_T1 ;

END JAI_PO_DA_TRIGGER_PKG ;

/
