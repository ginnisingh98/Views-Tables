--------------------------------------------------------
--  DDL for Package JL_ZZ_AP_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AP_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzpl1s.pls 120.7 2005/10/30 02:06:00 appldev ship $ */

Procedure get_state_valid(vscountry   IN Varchar2,
                          vsstate     IN Varchar2,
                          row_number  IN Number,
                          errcd       IN OUT NOCOPY Number);

Procedure get_context_name(vdesc       IN OUT NOCOPY Varchar2,
                           row_number  IN Number,
                           errcd       IN OUT NOCOPY Number);

Procedure get_interest_type(vndstid    IN Number,
                            inttyp     IN OUT NOCOPY Varchar2,
                            row_number IN Number,
                            errcd      IN OUT NOCOPY Number);

Procedure get_interest_penalty_details(vndstid    IN Number,
                                       pntamt     IN OUT NOCOPY Varchar2,
                                       intgrd     IN OUT NOCOPY Varchar2,
                                       intprd     IN OUT NOCOPY Varchar2,
                                       intamt     IN OUT NOCOPY Varchar2,
                                       row_number IN Number,
                                       errcd      IN OUT NOCOPY Number);

Procedure get_interest_formula(vndstid    IN Number,
                               intfml     IN OUT NOCOPY Varchar2,
                               row_number IN Number,
                               errcd      IN OUT NOCOPY Number);

Procedure get_penalty_type(vndstid    IN Number,
                           pnttyp     IN OUT NOCOPY Varchar2,
                           row_number IN Number,
                           errcd      IN OUT NOCOPY Number);

Procedure get_cons_inv_num(invoiceid      IN Number,
                           cons_inv_num   IN OUT NOCOPY Number,
                           row_number     IN Number,
                           errcd          IN OUT NOCOPY Number);

Procedure get_payment_status_flag(invoiceid      IN Number,
                                  pay_stat       IN OUT NOCOPY Varchar2,
                                  row_number     IN Number,
                                  errcd          IN OUT NOCOPY Number);

Procedure get_associated_payment_count(invoiceid      IN Number,
                                       tot_recs       IN OUT NOCOPY Number,
                                       row_number     IN Number,
                                       errcd          IN OUT NOCOPY Number);

Procedure get_podist_ccid(line_locn_id   IN Number,
                          ccid           IN OUT NOCOPY Number,
                          row_number     IN Number,
                          errcd          IN OUT NOCOPY Number);

Procedure get_account_type(ccid           IN Number,
                           account_type   IN OUT NOCOPY Varchar2,
                           row_number     IN Number,
                           errcd          IN OUT NOCOPY Number);

Procedure get_tax_ccid(tax_name   	IN 	Varchar2,
                       ccid       	IN OUT NOCOPY 	Number,
                       row_number 	IN 	Number,
                       errcd      	IN OUT NOCOPY  Number,
		       p_val_date 	IN 	Date);

Procedure get_hr_loc_distccid(locn_id    IN Number,
                              ccid       IN OUT NOCOPY Number,
                              row_number IN Number,
                              errcd      IN OUT NOCOPY Number);

Procedure get_max_dist_line_num(invoiceid            IN Number,
                                max_dist_line_num    IN OUT NOCOPY Number,
                                row_number           IN Number,
                                errcd                IN OUT NOCOPY Number);

Procedure get_po_dist_id(line_locn_id  IN Number,
                         distid        IN OUT NOCOPY Number,
                         row_number    IN Number,
                         errcd         IN OUT NOCOPY Number);

FUNCTION Get_Inv_Distrib_ID RETURN number;

PROCEDURE Get_Invoice_Information(P_Invoice_id             IN      number,
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
                                  );



Procedure get_tax_count(invoiceid  IN Number,
                        tot_rec    IN OUT NOCOPY Number,
                        row_number IN Number,
                        errcd      IN OUT NOCOPY Number);

Procedure get_ship_from(vendsite_id  IN Number,
                        shp_frm      IN OUT NOCOPY Varchar2,
                        row_number   IN Number,
                        errcd        IN OUT NOCOPY Number);

Procedure get_ship_to(locn_id    IN Number,
                      shp_to     IN OUT NOCOPY Varchar2,
                      row_number IN Number,
                      errcd      IN OUT NOCOPY Number);

Procedure get_ship_to_org_id(inv_org_id     IN OUT NOCOPY Number,
                             p_po_line_id   IN Number,
                             errcd          IN OUT NOCOPY Number);

Procedure get_tax_rate_diff(cfocd      IN  Varchar2,
                            tax_flag   IN OUT NOCOPY Varchar2,
                            row_number IN Number,
                            errcd      IN OUT NOCOPY Number);

Procedure get_trans_reason_code(polineid            IN  Number,
                                trans_reason_code   IN OUT NOCOPY Varchar2,
                                fiscal_class_code   IN OUT NOCOPY Varchar2,
                                row_number          IN Number,
                                errcd               IN OUT NOCOPY Number);

Procedure get_inv_org_id(inv_org_id   IN OUT NOCOPY Number,
                         row_number   IN Number,
                         errcd        IN OUT NOCOPY Number);

Procedure get_Association_Method(asson_method   IN OUT NOCOPY Varchar2,
                                 row_number     IN Number,
                                 errcd          IN OUT NOCOPY Number);

Procedure get_tcc_id(tax_reco_flg   IN  Varchar2,
                     vatcode        IN  Varchar2,
                     tcc_id         IN OUT NOCOPY Number,
                     description    IN OUT NOCOPY Varchar2,
                     account_type   IN OUT NOCOPY Varchar2,
                     row_number     IN Number,
                     errcd          IN OUT NOCOPY Number);

Procedure get_dist_count(invoiceid  IN Number,
                         tot_rec    IN OUT NOCOPY Number,
                         row_number IN Number,
                         errcd      IN OUT NOCOPY Number);

Procedure get_Tax_Recoverable(cfocd            IN  Varchar2,
                              tax_recoverable  IN OUT NOCOPY Varchar2,
                              row_number       IN Number,
                              errcd            IN OUT NOCOPY Number);

Procedure get_payment_schedule_count(invoiceid      IN Number,
                                     tot_rec        IN OUT NOCOPY Number,
                                     row_number     IN Number,
                                     errcd          IN OUT NOCOPY Number);

Procedure get_distribution_count(invoiceid      IN Number,
                                 tot_rec        IN OUT NOCOPY Number,
                                 row_number     IN Number,
                                 errcd          IN OUT NOCOPY Number);

Procedure get_vendor_site_id(invoiceid      IN Number,
                             vendsite_id    IN OUT NOCOPY Number,
                             row_number     IN Number,
                             errcd          IN OUT NOCOPY Number);

Procedure get_tax_calendar_name(vendsite_id      IN Number,
                                tax_cal_name     IN OUT NOCOPY Varchar2,
                                row_number       IN Number,
                                errcd            IN OUT NOCOPY Number);

Procedure get_tax_type(tax_code_id  IN Number,
                       tax_type     IN OUT NOCOPY Varchar2,
                       row_number   IN Number,
                       errcd        IN OUT NOCOPY Number);

Procedure get_base_date(taxcal_name  IN  Varchar2,
                        taxtype      IN  Varchar2,
                        basedt       IN OUT NOCOPY Varchar2,
                        row_number   IN Number,
                        errcd        IN OUT NOCOPY Number);


Procedure get_terms_due_date(invoiceid    IN  Number,
                             taxcal_name  IN  Varchar2,
                             duedt        IN OUT NOCOPY Date,
                             row_number   IN Number,
                             errcd        IN OUT NOCOPY Number);

Procedure get_inv_due_date(invoiceid    IN  Number,
                           taxcal_name  IN  Varchar2,
                           duedt        IN OUT NOCOPY Date,
                           row_number   IN Number,
                           errcd        IN OUT NOCOPY Number);

Procedure get_gl_due_date(invoiceid    IN  Number,
                          taxcal_name  IN  Varchar2,
                          duedt        IN OUT NOCOPY Date,
                          row_number   IN Number,
                          errcd        IN OUT NOCOPY Number);

Procedure get_city_frm_sys(vcity      IN OUT NOCOPY Varchar2,
                           row_number IN Number,
                           errcd      IN OUT NOCOPY Number);

Procedure get_city_frm_povend(vendsite_id  IN Number,
                              vcity        IN OUT NOCOPY Varchar2,
                              row_number   IN Number,
                              errcd        IN OUT NOCOPY Number);

PROCEDURE get_count_cnab(cnab       IN VARCHAR2,
                         curr_code  IN VARCHAR2,
                         total_rec  IN OUT NOCOPY NUMBER,
                         row_number IN NUMBER,
                         Errcd      IN OUT NOCOPY NUMBER);

PROCEDURE get_old_cnab_code(curr_code  IN VARCHAR2,
                            cnab       IN OUT NOCOPY VARCHAR2,
                            row_number IN NUMBER,
                            Errcd      IN OUT NOCOPY NUMBER);

PROCEDURE get_tax_code_id(p_tax_name   IN 	Varchar2,
                          p_val_date   IN 	Date,
                          p_tax_id     IN OUT NOCOPY 	Number);

Procedure get_city_frm_sys(vcity      IN OUT NOCOPY Varchar2,
                           row_number IN Number,
                           errcd      IN OUT NOCOPY Number,
                           vstate     IN OUT NOCOPY Varchar2);   --Bug # 2319552

Procedure get_city_frm_povend(vendsite_id  IN Number,
                              vcity        IN OUT NOCOPY Varchar2,
                              row_number   IN Number,
                              errcd        IN OUT NOCOPY Number,
                              vstate       IN OUT NOCOPY Varchar2); --Bug # 2319552

Procedure get_vendor_id(invoiceid      IN Number,
                        vendor_id      IN OUT NOCOPY Number,
                        row_number     IN Number,
                        errcd          IN OUT NOCOPY Number);

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
        errcd         IN OUT NOCOPY NUMBER);

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
        errcd         IN OUT NOCOPY NUMBER);

  PROCEDURE upd_inwkb_br_upd_due_date1
       (l_due_date_char   IN            VARCHAR2,
        l_invoice_id      IN            NUMBER,
        l_payment_num     IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE upd_inwkb_br_upd_due_date2
       (l_discount_date_char   IN            VARCHAR2,
        l_invoice_id           IN            NUMBER,
        l_payment_num          IN            NUMBER,
        errcd                  IN OUT NOCOPY NUMBER);

  PROCEDURE upd_inwkb_br_up_wh_due_date1
       (l_due_date_char   IN            VARCHAR2,
        l_new_invoice_id  IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE upd_inwkb_br_val_pay_sched1
       (l_new_date1       IN            DATE,
        s_invoice_id      IN            NUMBER,
        s_payment_num     IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE upd_inwkb_br_val_pay_sched2
       (l_new_date1       IN            DATE,
        s_invoice_id      IN            NUMBER,
        s_payment_num     IN            NUMBER,
        errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE upd_inwkb_br_val_pay_sched3
       (s_bank_collection_id   IN            jl_br_ap_collection_docs.bank_collection_id%Type,
        s_invoice_id           IN            NUMBER,
        s_payment_num          IN            NUMBER,
        errcd                  IN OUT NOCOPY NUMBER);

END JL_ZZ_AP_LIBRARY_1_PKG;

 

/
