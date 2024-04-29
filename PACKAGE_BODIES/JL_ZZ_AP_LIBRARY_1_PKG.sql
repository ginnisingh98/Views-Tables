--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AP_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AP_LIBRARY_1_PKG" AS
/* $Header: jlzzpl1b.pls 120.11 2006/05/05 22:21:29 dbetanco ship $ */

Procedure get_state_valid(vscountry   IN Varchar2,
                          vsstate     IN Varchar2,
                          row_number  IN Number,
                          errcd       IN OUT NOCOPY Number) Is
l_exists VARCHAR2(6);
Begin
  errcd := 0;
  IF vscountry = 'US' THEN
    Begin
      select 'exists'
      into l_exists
      from ap_income_tax_regions
      where sysdate < nvl(inactive_date, sysdate+1)
      and region_short_name = vsstate;
    Exception
    When No_Data_Found Then
      errcd := 1;
    When Others Then
      errcd := sqlcode;
    End;

  ELSIF vscountry = 'BR' THEN
    Begin
      select 'exists'
      into l_exists
      from   hz_geographies geo
      where  geo.country_code = 'BR'
      and nvl(start_date, sysdate) <= sysdate
      and nvl(end_date, sysdate) >= sysdate
      and geo.geography_type = 'STATE'
      and geo.geography_code = vsstate;

    Exception
    When No_Data_Found Then
      errcd := 1;
    When Others Then
      errcd := sqlcode;
    End;

  END IF;
Exception
  When Others Then
  errcd := sqlcode;
End get_state_valid;

Procedure get_context_name(vdesc       IN OUT NOCOPY Varchar2,
                           row_number  IN Number,
                           errcd       IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select substr(description,1,30)
  into vdesc
  from fnd_descr_flex_contexts_vl
  where  application_id = 7003
  and descriptive_flexfield_name  = 'JG_AP_SYSTEM_PARAMETERS'
  and descriptive_flex_context_code = 'JL.BR.APXCUMSP.SYS_PARAMETER'
  and enabled_flag = 'Y' and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_context_name;

Procedure get_interest_type(vndstid    IN Number,
                            inttyp     IN OUT NOCOPY Varchar2,
                            row_number IN Number,
                            errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT L.LOOKUP_CODE
  Into inttyp
  FROM FND_LOOKUPS L,PO_VENDOR_SITES V
  WHERE L.LOOKUP_CODE = V.GLOBAL_ATTRIBUTE2
  AND L.LOOKUP_TYPE = 'JLBR_INTEREST_PENALTY_TYPE'
  AND V.VENDOR_SITE_ID = vndstid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_interest_type;

Procedure get_interest_penalty_details(vndstid    IN Number,
                                       pntamt     IN OUT NOCOPY Varchar2,
                                       intgrd     IN OUT NOCOPY Varchar2,
                                       intprd     IN OUT NOCOPY Varchar2,
                                       intamt     IN OUT NOCOPY Varchar2,
                                       row_number IN Number,
                                       errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT GLOBAL_ATTRIBUTE8, GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE4, GLOBAL_ATTRIBUTE3
  INTO pntamt, intgrd, intprd, intamt
  FROM PO_VENDOR_SITES
  WHERE VENDOR_SITE_ID = vndstid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_interest_penalty_details;

Procedure get_interest_formula(vndstid    IN Number,
                               intfml     IN OUT NOCOPY Varchar2,
                               row_number IN Number,
                               errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT L.LOOKUP_CODE
  INTO intfml
  FROM FND_LOOKUPS L, PO_VENDOR_SITES V
  WHERE L.LOOKUP_CODE = V.GLOBAL_ATTRIBUTE5
  AND L.LOOKUP_TYPE = 'JLBR_INTEREST_FORMULA'
  AND V.VENDOR_SITE_ID = vndstid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_interest_formula;

Procedure get_penalty_type(vndstid    IN Number,
                           pnttyp     IN OUT NOCOPY Varchar2,
                           row_number IN Number,
                           errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT L.LOOKUP_CODE
  INTO pnttyp
  FROM FND_LOOKUPS L, PO_VENDOR_SITES V
  WHERE L.LOOKUP_CODE = V.GLOBAL_ATTRIBUTE7
  AND L.LOOKUP_TYPE = 'JLBR_INTEREST_PENALTY_TYPE'
  AND V.VENDOR_SITE_ID = vndstid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_penalty_type;

Procedure get_cons_inv_num(invoiceid      IN Number,
                           cons_inv_num   IN OUT NOCOPY Number,
                           row_number     IN Number,
                           errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT substr(global_attribute10,1,38)
  INTO cons_inv_num
  FROM ap_invoices
  WHERE invoice_id = invoiceid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_cons_inv_num;

Procedure get_payment_status_flag(invoiceid      IN Number,
                                  pay_stat       IN OUT NOCOPY Varchar2,
                                  row_number     IN Number,
                                  errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select payment_status_flag
  into pay_stat
  from ap_invoices
  where invoice_id = invoiceid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_payment_status_flag;

Procedure get_associated_payment_count(invoiceid      IN Number,
                                       tot_recs       IN OUT NOCOPY Number,
                                       row_number     IN Number,
                                       errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select count(*)
  into tot_recs
  from ap_payment_schedules
  where invoice_id = invoiceid
  and global_attribute11 is not null;
Exception
  When Others Then
  errcd := sqlcode;
End get_associated_payment_count;

Procedure get_podist_ccid(line_locn_id   IN Number,
                          ccid           IN OUT NOCOPY Number,
                          row_number     IN Number,
                          errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select code_combination_id
  into ccid
  from po_distributions_ap2_v
  where line_location_id = line_locn_id
  and rownum < 2 ;
Exception
  When No_data_found Then
    errcd := sqlcode;
  When Others Then
    errcd := sqlcode;
End get_podist_ccid;

Procedure get_account_type(ccid           IN Number,
                           account_type   IN OUT NOCOPY Varchar2,
                           row_number     IN Number,
                           errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select decode(account_type,'A','Y','N')
  Into account_type
  from gl_code_combinations
  where code_combination_id = ccid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_account_type;

Procedure get_tax_ccid(tax_name   	IN 	Varchar2,
                       ccid       	IN OUT NOCOPY 	Number,
                       row_number 	IN 	Number,
                       errcd      	IN OUT NOCOPY  Number,
		       p_val_date 	IN 	Date) Is
Begin
  errcd := 0;
  select tax_code_combination_id
  Into ccid
  from ap_tax_codes
  where name = tax_name
   and nvl(start_date,p_val_date) <= p_val_date
   and nvl(inactive_date,p_val_date+1) > p_val_date
   and nvl(enabled_flag,'Y') = 'Y';
Exception
  When Others Then
  errcd := sqlcode;
End get_tax_ccid;

Procedure get_hr_loc_distccid(locn_id    IN Number,
                              ccid       IN OUT NOCOPY Number,
                              row_number IN Number,
                              errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select to_number(global_attribute2)
  Into ccid
  from hr_locations_all
  where location_id = locn_id and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_hr_loc_distccid;

Procedure get_max_dist_line_num(invoiceid            IN Number,
                                max_dist_line_num    IN OUT NOCOPY Number,
                                row_number           IN Number,
                                errcd                IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select nvl(max(distribution_line_number),0)
  into max_dist_line_num
  from ap_invoice_distributions
  where invoice_id = invoiceid
  -- Commented out as unnecessary - iswillia (08-OCT-1999)
  --and rownum = row_number
  -- End of Commented out portion - iswillia (08-OCT-1999)
  ;
Exception
  When Others Then
  errcd := sqlcode;
End get_max_dist_line_num;

Procedure get_po_dist_id(line_locn_id  IN Number,
                         distid        IN OUT NOCOPY Number,
                         row_number    IN Number,
                         errcd         IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT po_distribution_id
  INTO distid
  FROM po_distributions_ap2_v
  WHERE line_location_id = line_locn_id
  AND rownum < 2 ;
Exception
  When No_data_found Then
    errcd := sqlcode;
  When Others Then
    errcd := sqlcode;
End get_po_dist_id;

FUNCTION Get_Inv_Distrib_ID RETURN number IS

  l_invoice_distribution_id        number(38);

BEGIN

   Begin
    SELECT ap_invoice_distributions_s.nextval
    INTO   l_invoice_distribution_id
    FROM   dual;

   Exception
     WHEN others then
          null;
   End;

   return(l_invoice_distribution_id);

END Get_Inv_Distrib_ID;

PROCEDURE Get_Invoice_Information(p_invoice_id             IN      number,
                                  p_last_update_date       IN OUT NOCOPY  Date,
                                  p_Last_Updated_By        IN OUT NOCOPY  number,
                                  p_Set_Of_Books_Id        IN OUT NOCOPY  number,
                                  p_Type_1099              IN OUT NOCOPY  varchar2,
                                  p_Last_Update_Login      IN OUT NOCOPY  number,
                                  p_Creation_Date          IN OUT NOCOPY  Date,
                                  p_Created_By             IN OUT NOCOPY  number,
                                  p_exchange_rate          IN OUT NOCOPY  Number,
                                  p_exchange_rate_type     IN OUT NOCOPY  Varchar2,
                                  p_exchange_date          IN OUT NOCOPY  Date,
                                  p_invoice_amount_limit   IN OUT NOCOPY  number,
                                  p_amount_hold_flag       IN OUT NOCOPY  varchar2,
                                  p_cfo_code               IN OUT NOCOPY  varchar2
                                  ) IS
  l_last_update_date           Date;
  l_Last_Updated_By            number;
  l_Set_Of_Books_Id            number;
  l_Type_1099                  varchar2(10);
  l_Last_Update_Login          number;
  l_Creation_Date              Date;
  l_Created_By                 number;
  l_exchange_rate              Number(38);
  l_exchange_rate_type         Varchar2(30);
  l_exchange_date              Date;
  l_invoice_amount_limit       number(38);
  l_amount_hold_flag           varchar2(1);
  l_cfo_code                   varchar2(5);

BEGIN

   Begin
     SELECT set_of_books_id,
            type_1099,
            exchange_rate,
            exchange_rate_type,
            exchange_date,
            invoice_amount_limit,
            substr(amount_hold_flag,1,1),
            rtrim(substr(global_attribute2,1,5)),
            last_update_date,
            last_Updated_By,
            last_Update_Login,
            creation_date,
            created_by
    INTO    l_Set_Of_Books_Id,
            l_Type_1099,
            l_exchange_rate ,
            l_exchange_rate_type ,
            l_exchange_date,
            l_invoice_amount_limit,
            l_amount_hold_flag ,
            l_cfo_code,
            l_last_update_date ,
            l_last_Updated_By ,
            l_last_Update_Login ,
            l_creation_date,
            l_created_by
    FROM    ap_invoices_v
    where   invoice_id = P_Invoice_id;
    Exception When no_data_found then
                   null;
              When others then
                   null;
  End;

     p_set_of_books_id      := l_set_of_books_id;
     p_type_1099            := l_type_1099;
     p_exchange_rate        := l_exchange_rate;
     p_exchange_rate_type   := l_exchange_rate_type;
     p_exchange_date        := l_exchange_date;
     p_invoice_amount_limit := l_invoice_amount_limit;
     p_amount_hold_flag     := l_amount_hold_flag;
     p_cfo_code             := l_cfo_code;
     p_last_update_date     := l_last_update_date;
     p_last_Updated_By      := l_last_updated_by;
     p_last_Update_Login    := l_last_update_login;
     p_creation_date        := l_creation_date;
     p_created_by           := l_created_by;

END Get_Invoice_Information;


Procedure get_tax_count(invoiceid  IN Number,
                        tot_rec    IN OUT NOCOPY Number,
                        row_number IN Number,
                        errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT count(*)
  Into tot_rec
  FROM ap_invoice_distributions
  WHERE invoice_id = invoiceid
  AND line_type_lookup_code IN ('ICMS','IPI');
Exception
  When Others Then
  errcd := sqlcode;
End get_tax_count;

Procedure get_ship_from(vendsite_id  IN Number,
                        shp_frm      IN OUT NOCOPY Varchar2,
                        row_number   IN Number,
                        errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select state ship_from
  into shp_frm
  from po_vendor_sites
  where vendor_site_id = vendsite_id
  and nvl(inactive_date,sysdate + 1) > sysdate and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_ship_from;

Procedure get_ship_to(locn_id    IN Number,
                      shp_to     IN OUT NOCOPY Varchar2,
                      row_number IN Number,
                      errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select substr(region_2,1,30)
  into shp_to
  from hr_locations_all
  where location_id = locn_id and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_ship_to;

Procedure get_tax_rate_diff(cfocd      IN  Varchar2,
                            tax_flag   IN OUT NOCOPY Varchar2,
                            row_number IN Number,
                            errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select tax_rate_differential
  into tax_flag
  from jl_br_ap_operations
  where cfo_code = cfocd and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_tax_rate_diff;

Procedure get_trans_reason_code(polineid            IN  Number,
                                trans_reason_code   IN OUT NOCOPY Varchar2,
                                fiscal_class_code   IN OUT NOCOPY Varchar2,
                                row_number          IN Number,
                                errcd               IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT transaction_reason_code, substr(global_attribute1,1,15)
  INTO trans_reason_code, fiscal_class_code
  FROM po_lines
  WHERE po_line_id = polineid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_trans_reason_code;

Procedure get_ship_to_org_id(inv_org_id   IN OUT NOCOPY Number,
                         p_po_line_id  IN Number,
                         errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT ship_to_organization_id
  INTO inv_org_id
  FROM po_line_locations
  Where po_line_id = p_po_line_id ;
Exception
  When Others Then
  errcd := sqlcode;
End get_ship_to_org_id;

Procedure get_inv_org_id(inv_org_id   IN OUT NOCOPY Number,
                         row_number   IN Number,
                         errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT inventory_organization_id
  INTO inv_org_id
  FROM financials_system_parameters Where rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_inv_org_id;

Procedure get_Association_Method(asson_method   IN OUT NOCOPY Varchar2,
                                 row_number     IN Number,
                                 errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select substr(Global_Attribute3,1,25)
  into asson_method
  from ap_System_Parameters Where rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_Association_Method;

Procedure get_tcc_id(tax_reco_flg   IN  Varchar2,
                     vatcode        IN  Varchar2,
                     tcc_id         IN OUT NOCOPY Number,
                     description    IN OUT NOCOPY Varchar2,
                     account_type   IN OUT NOCOPY Varchar2,
                     row_number     IN Number,
                     errcd          IN OUT NOCOPY Number) Is
tcc_id1  Number;
tcc_id2  Number;
Begin
  errcd := 0;
  select ATC.tax_code_combination_id,
         to_number(substr(ATC.global_attribute1,1,15)),
         ATC.description,
         decode(GL.account_type,'A','Y','N')
  into tcc_id1, tcc_id2, description, account_type
  from ap_tax_codes ATC, gl_code_combinations GL
  where ATC.name = vatcode
  and ATC.tax_code_combination_id = GL.code_combination_id
  and nvl(ATC.inactive_date,sysdate + 1) > sysdate and rownum = row_number;
  If Nvl(Tax_Reco_flg,'N') = 'Y' Then
     tcc_id := tcc_id1;
  Else
     tcc_id := tcc_id2;
  End If;
Exception
  When Others Then
  errcd := sqlcode;
End get_tcc_id;

Procedure get_dist_count(invoiceid  IN Number,
                         tot_rec    IN OUT NOCOPY Number,
                         row_number IN Number,
                         errcd      IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  SELECT count(*)
  Into tot_rec
  FROM ap_invoice_distributions
  WHERE invoice_id = invoiceid
  AND line_type_lookup_code = 'ITEM';
Exception
  When Others Then
  errcd := sqlcode;
End get_dist_count;

Procedure get_Tax_Recoverable(cfocd            IN  Varchar2,
                              tax_recoverable  IN OUT NOCOPY Varchar2,
                              row_number       IN Number,
                              errcd            IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select nvl(tax_recoverable,'N')
  into tax_recoverable
  from jl_br_ap_operations
  where cfo_code = cfocd and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_Tax_Recoverable;

Procedure get_payment_schedule_count(invoiceid      IN Number,
                                     tot_rec        IN OUT NOCOPY Number,
                                     row_number     IN Number,
                                     errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select count(*)
  into tot_rec
  from ap_payment_schedules
  where invoice_id = invoiceid;
Exception
  When Others Then
  errcd := sqlcode;
End get_payment_schedule_count;

Procedure get_distribution_count(invoiceid      IN Number,
                                 tot_rec        IN OUT NOCOPY Number,
                                 row_number     IN Number,
                                 errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select count(*)
  into tot_rec
  from ap_invoice_distributions
  where invoice_id = invoiceid
  and awt_invoice_id is not null;
Exception
  When Others Then
  errcd := sqlcode;
End get_distribution_count;

Procedure get_vendor_site_id(invoiceid      IN Number,
                             vendsite_id    IN OUT NOCOPY Number,
                             row_number     IN Number,
                             errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select vendor_site_id
  into vendsite_id
  from ap_invoices
  where invoice_id = invoiceid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_vendor_site_id;

Procedure get_tax_calendar_name(vendsite_id      IN Number,
                                tax_cal_name     IN OUT NOCOPY Varchar2,
                                row_number       IN Number,
                                errcd            IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select substr(global_attribute16,1,25)
  into tax_cal_name
  from po_vendor_sites
  where vendor_site_id = vendsite_id
  and nvl(inactive_date,sysdate + 1) > sysdate and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_tax_calendar_name;

Procedure get_tax_type(tax_code_id  IN Number,
                       tax_type     IN OUT NOCOPY Varchar2,
                       row_number   IN Number,
                       errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select substr(global_attribute2,1,25)
  into tax_type
  from ap_tax_codes
  where tax_id = tax_code_id
  and nvl(inactive_date,sysdate + 1) > sysdate and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_tax_type;

Procedure get_base_date(taxcal_name  IN  Varchar2,
                        taxtype      IN  Varchar2,
                        basedt       IN OUT NOCOPY Varchar2,
                        row_number   IN Number,
                        errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select base_date
  Into basedt
  from jl_br_ap_tax_calendar_headers
  where tax_calendar_name = taxcal_name
  and tax_type = taxtype and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_base_date;

Procedure get_terms_due_date(invoiceid    IN  Number,
                             taxcal_name  IN  Varchar2,
                             duedt        IN OUT NOCOPY Date,
                             row_number   IN Number,
                             errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select j.due_date
  into duedt
  from jl_br_ap_tax_calendar_lines j, ap_invoices a
  where a.invoice_id = invoiceid
  and j.tax_calendar_name = taxcal_name
  and a.terms_date between j.start_date and j.end_date
  and sysdate < nvl(j.inactive_date,sysdate+1) and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_terms_due_date;

Procedure get_inv_due_date(invoiceid    IN  Number,
                           taxcal_name  IN  Varchar2,
                           duedt        IN OUT NOCOPY Date,
                           row_number   IN Number,
                           errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select j.due_date
  into duedt
  from jl_br_ap_tax_calendar_lines j, ap_invoices a
  where a.invoice_id = invoiceid
  and j.tax_calendar_name = taxcal_name
  and a.invoice_date between j.start_date and j.end_date
  and sysdate < nvl(j.inactive_date,sysdate+1) and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_inv_due_date;

Procedure get_gl_due_date(invoiceid    IN  Number,
                          taxcal_name  IN  Varchar2,
                          duedt        IN OUT NOCOPY Date,
                          row_number   IN Number,
                          errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select j.due_date
  into duedt
  from jl_br_ap_tax_calendar_lines j, ap_invoice_distributions a
  where a.invoice_id = invoiceid
  and j.tax_calendar_name = taxcal_name
  and a.accounting_date between j.start_date and j.end_date
  and sysdate < nvl(j.inactive_date,sysdate+1) and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_gl_due_date;

Procedure get_city_frm_sys(vcity      IN OUT NOCOPY Varchar2,
                           row_number IN Number,
                           errcd      IN OUT NOCOPY Number) Is

l_return_status   VARCHAR2(100);
l_msg_data        VARCHAR2(1000);
--l_ledger_info     xle_businessinfo_grp.le_ledger_rec_type;
l_ledger_id       NUMBER;
l_BSV             VARCHAR2(30);

Cursor CityT Is
  Select etb.town_or_city
    From
         xle_establishment_v etb
        ,xle_bsv_associations bsv
        ,gl_ledger_le_v gl
  Where
        etb.legal_entity_id = gl.legal_entity_id
  And   bsv.legal_parent_id = etb.legal_entity_id
  And   etb.establishment_id = bsv.legal_construct_id
  And   bsv.entity_name = l_BSV
  And   gl.ledger_id = l_ledger_id;

Begin

 select set_of_books_id,substr(global_attribute4,1,25)
 into l_ledger_id,l_BSV
 from ap_system_parameters;

/* bug 5206517
   XLE_BUSINESSINFO_GRP.Get_Ledger_Info
      (x_return_status => l_return_status, --OUT VARCHAR2,
       x_msg_data      => l_msg_data     , --OUT VARCHAR2,
       P_Ledger_ID     => l_ledger_id    , --IN  NUMBER,
       P_BSV           => l_BSV          , --IN  VARCHAR2,
       x_Ledger_info   => l_ledger_info);  --OUT LE_Ledger_Rec_Type
*/

  For City IN CityT Loop
      vcity  := City.TOWN_OR_CITY;
  END LOOP;
End get_city_frm_sys;

Procedure get_city_frm_povend(vendsite_id  IN Number,
                              vcity        IN OUT NOCOPY Varchar2,
                              row_number   IN Number,
                              errcd        IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select city
  into vcity
  from po_vendor_sites
  where vendor_site_id = vendsite_id
  and nvl(inactive_date,sysdate + 1) > sysdate and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_city_frm_povend;

PROCEDURE get_count_cnab(cnab       IN VARCHAR2,
                          curr_code  IN VARCHAR2,
                          total_rec  IN OUT NOCOPY NUMBER,
                          row_number IN NUMBER,
                          Errcd      IN OUT NOCOPY NUMBER) IS
BEGIN
  Errcd := 0;
  SELECT COUNT (*)
  INTO   total_rec
  FROM   fnd_currencies_vl c
  WHERE  c.global_attribute1 = cnab
  AND    c.currency_code <> curr_code;
EXCEPTION
  WHEN OTHERS THEN
    Errcd := SQLCODE;
END get_count_cnab;

PROCEDURE get_old_cnab_code(curr_code  IN VARCHAR2,
                            cnab       IN OUT NOCOPY VARCHAR2,
                            row_number IN NUMBER,
                            Errcd      IN OUT NOCOPY NUMBER) IS
BEGIN
  Errcd := 0;
  SELECT SUBSTR (c.global_attribute1, 1, 15)
  INTO    cnab
  FROM   fnd_currencies_vl c
  WHERE  c.currency_code = curr_code
  AND    rownum = row_number;
EXCEPTION
  WHEN OTHERS THEN
    Errcd := SQLCODE;
END get_old_cnab_code;

PROCEDURE get_tax_code_id(p_tax_name   IN 	Varchar2,
                          p_val_date   IN 	Date,
                          p_tax_id     IN OUT NOCOPY 	Number) Is
Begin

select tax_id
  into p_tax_id
  from AP_TAX_CODES
 where name = p_tax_name
   and nvl(start_date,p_val_date) <= p_val_date
   and nvl(inactive_date,p_val_date+1) > p_val_date
   and nvl(enabled_flag,'Y') = 'Y';

Exception
  When Others Then
       null;
End get_tax_code_id;

Procedure get_city_frm_sys(vcity      IN OUT NOCOPY Varchar2,
                           row_number IN Number,
                           errcd      IN OUT NOCOPY Number,
                           vstate     IN OUT NOCOPY Varchar2) Is  --Bug # 2319552

l_return_status   VARCHAR2(100);
l_msg_data        VARCHAR2(1000);
--l_ledger_info     xle_businessinfo_grp.le_ledger_rec_type;
l_ledger_id       NUMBER;
l_BSV             VARCHAR2(30);

Cursor CityTReg Is
  Select etb.town_or_city, etb.region_2
  From
         xle_establishment_v etb
        ,xle_bsv_associations bsv
        ,gl_ledger_le_v gl
  Where
        etb.legal_entity_id = gl.legal_entity_id
  And   bsv.legal_parent_id = etb.legal_entity_id
  And   etb.establishment_id = bsv.legal_construct_id
  And   bsv.entity_name = l_BSV
  And   gl.ledger_id = l_ledger_id;

BEGIN

 select set_of_books_id,substr(global_attribute4,1,25)
 into l_ledger_id,l_BSV
 from ap_system_parameters;

/* Bug# 5206517
 XLE_BUSINESSINFO_GRP.Get_Ledger_Info
    (x_return_status => l_return_status, --OUT VARCHAR2,
     x_msg_data      => l_msg_data     , --OUT VARCHAR2,
     P_Ledger_ID     => l_ledger_id    , --IN  NUMBER,
     P_BSV           => l_BSV          , --IN  VARCHAR2,
     x_Ledger_info   => l_ledger_info);  --OUT LE_Ledger_Rec_Type
*/

   For CityReg2 IN CityTReg Loop
       vcity  := CityReg2.town_or_city;
       vstate := CityReg2.region_2;
   End Loop;
End get_city_frm_sys;

Procedure get_city_frm_povend(vendsite_id  IN Number,
                              vcity        IN OUT NOCOPY Varchar2,
                              row_number   IN Number,
                              errcd        IN OUT NOCOPY Number,
                              vstate       IN OUT NOCOPY Varchar2) Is   --Bug # 2319552

Begin
  errcd := 0;
  select city,
         state    --Bug # 2319552
  into vcity,
       vstate     --Bug # 2319552
  from po_vendor_sites
  where vendor_site_id = vendsite_id
  and nvl(inactive_date,sysdate + 1) > sysdate and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_city_frm_povend;
-- Bug 3609925
Procedure get_vendor_id(invoiceid      IN Number,
                        vendor_id       IN OUT NOCOPY Number,
                        row_number     IN Number,
                        errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select vendor_id
  into vendor_id
  from ap_invoices
  where invoice_id = invoiceid and rownum = row_number;
Exception
  When Others Then
  errcd := sqlcode;
End get_vendor_id;

  --Bug 3740729
  PROCEDURE upd_inwkb_br_def_ps_segmts_1
       (v_inttyp      IN            VARCHAR2,
        v_intamt      IN            VARCHAR2,
        v_intprd      IN            VARCHAR2,
        v_intfml      IN            VARCHAR2,
        v_intgrd      IN            VARCHAR2,
        v_pnttyp      IN            VARCHAR2,
        v_pntamt      IN            VARCHAR2,
        v_glbattctg   IN            VARCHAR2,
        v_invid       IN            NUMBER,
        errcd         IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      SET GLOBAL_ATTRIBUTE1 = v_inttyp,
          GLOBAL_ATTRIBUTE2 = v_intamt,
          GLOBAL_ATTRIBUTE3 = v_intprd,
          GLOBAL_ATTRIBUTE4 = v_intfml,
          GLOBAL_ATTRIBUTE5 = v_intgrd,
          GLOBAL_ATTRIBUTE6 = v_pnttyp,
          GLOBAL_ATTRIBUTE7 = v_pntamt,
          GLOBAL_ATTRIBUTE8 = 'N',
          GLOBAL_ATTRIBUTE_CATEGORY = v_glbattctg
      WHERE INVOICE_ID = v_invid;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_def_ps_segmts_1;


  PROCEDURE upd_inwkb_br_def_ps_segmts_2
       (v_inttyp      IN            VARCHAR2,
        v_intamt      IN            VARCHAR2,
        v_intprd      IN            VARCHAR2,
        v_intfml      IN            VARCHAR2,
        v_intgrd      IN            VARCHAR2,
        v_pnttyp      IN            VARCHAR2,
        v_pntamt      IN            VARCHAR2,
        v_glbattctg   IN            VARCHAR2,
        v_invid       IN            NUMBER,
        v_pmtno       IN            NUMBER,
        errcd         IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      SET GLOBAL_ATTRIBUTE1 = v_inttyp,
          GLOBAL_ATTRIBUTE2 = v_intamt,
          GLOBAL_ATTRIBUTE3 = v_intprd,
          GLOBAL_ATTRIBUTE4 = v_intfml,
          GLOBAL_ATTRIBUTE5 = v_intgrd,
          GLOBAL_ATTRIBUTE6 = v_pnttyp,
          GLOBAL_ATTRIBUTE7 = v_pntamt,
          GLOBAL_ATTRIBUTE8 = 'N',
          GLOBAL_ATTRIBUTE_CATEGORY = v_glbattctg
      WHERE INVOICE_ID = v_invid
      AND PAYMENT_NUM = v_pmtno;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_def_ps_segmts_2;


  PROCEDURE upd_inwkb_br_upd_due_date1
       (l_due_date_char   IN            VARCHAR2,
        l_invoice_id      IN            NUMBER,
        l_payment_num     IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      set due_date = to_date (l_due_date_char,'YYYY/MM/DD HH24:MI:SS')
      where invoice_id  = l_invoice_id
      and   payment_num = l_payment_num;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_upd_due_date1;

  PROCEDURE upd_inwkb_br_upd_due_date2
       (l_discount_date_char   IN            VARCHAR2,
        l_invoice_id           IN            NUMBER,
        l_payment_num          IN            NUMBER,
        errcd                  IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      SET discount_date = to_date (l_discount_date_char,'YYYY/MM/DD HH24:MI:SS')
      WHERE invoice_id  = l_invoice_id
      AND   payment_num = l_payment_num;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_upd_due_date2;

  PROCEDURE upd_inwkb_br_up_wh_due_date1
       (l_due_date_char   IN            VARCHAR2,
        l_new_invoice_id  IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      SET due_date = to_date (l_due_date_char,'YYYY/MM/DD HH24:MI:SS')
      where invoice_id = l_new_invoice_id;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_up_wh_due_date1;

  PROCEDURE upd_inwkb_br_val_pay_sched1
       (l_new_date1       IN            DATE,
        s_invoice_id      IN            NUMBER,
        s_payment_num     IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      SET due_date = l_new_date1
      WHERE invoice_id = s_invoice_id
      AND payment_num = s_payment_num;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_val_pay_sched1;

  PROCEDURE upd_inwkb_br_val_pay_sched2
       (l_new_date1       IN            DATE,
        s_invoice_id      IN            NUMBER,
        s_payment_num     IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      SET discount_date = l_new_date1
      WHERE invoice_id = s_invoice_id
      AND payment_num = s_payment_num;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_val_pay_sched2;

  PROCEDURE upd_inwkb_br_val_pay_sched3
       (s_bank_collection_id   IN            jl_br_ap_collection_docs.bank_collection_id%Type,
        s_invoice_id           IN            NUMBER,
        s_payment_num          IN            NUMBER,
        errcd                  IN OUT NOCOPY NUMBER) IS

    l_exists      VARCHAR2(6);

  BEGIN
    errcd := 0;

    UPDATE AP_PAYMENT_SCHEDULES
      set global_attribute11 = s_bank_collection_id
      where invoice_id = s_invoice_id
      and payment_num = s_payment_num;

  EXCEPTION
    WHEN OTHERS THEN
      errcd := sqlcode;

  END upd_inwkb_br_val_pay_sched3;

END JL_ZZ_AP_LIBRARY_1_PKG;

/
