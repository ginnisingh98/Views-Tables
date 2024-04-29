--------------------------------------------------------
--  DDL for Package JAI_AP_TDS_GENERATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TDS_GENERATION_PKG" 
/* $Header: jai_ap_tds_gen.pls 120.5 2007/05/03 13:48:44 csahoo ship $ */
AUTHID CURRENT_USER AS
/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_inv_tds_generation_pkg_s.sql

 Created By    : Aparajita

 Created Date  : 19-feb-2005

 Bug           :

 Purpose       : Implementation of tax defaultation functionality on AP invoice.

 Called from   : Trigger ja_in_ap_aia_after_trg
                 Trigger ja_in_ap_aida_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        24/12/2004   Aparajita for bug#4088186. version#115.0. TDS Clean Up.

                        Created this package for implementing the TDS generation
                        functionality onto AP invoice.

 2.       2/05/2005     rchandan for bug#4333449. Version 116.1
                        A new procedure to insert into jai_ap_tds_thhold_trxs table
                        is added.

3.         08-Jun-2005  Version 116.1 jai_ap_tds_gen -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

4.  19-Jan-2006 avallabh for bug 4926736. File version 120.2
      Removed procedure process_tds_batch since it is no longer used.

5   27/03/2006    Hjujjuru for Bug 5096787 , File Version 120.3
                   Spec changes have been made in this file as a part og Bug 5096787.
                   Now, the r12 Procedure/Function specs is in this file are in
                   sync with their corrsponding 11i counterparts

6.  03/11/2006   Sanjikum for Bug#5131075, File Version 120.4
                 1) Changes are done for forward porting of bugs - 4718907, 5346558

                 Dependency Due to this Bug
                 --------------------------
                 Yes, as Package spec is changed and there are multiple files changed as part of current

7.  03/05/2007   Bug 5722028. Added by csahoo file version 120.5
									Forward Porting to R12.
									Added parameter p_creation_date for the follownig procedures
									process_tds_at_inv_validate
									maintain_thhold_grps
									and pd_creation_date in generate_tds_invoices.
									Added global variables
									gn_tds_rounding_factor
									gd_tds_rounding_effective_date and function get_rnded_value


									Depedencies:
									=============
									jai_ap_tds_gen.pls - 120.5
									jai_ap_tds_gen.plb - 120.19
									jai_ap_tds_ppay.pls - 120.2
									jai_ap_tds_ppay.plb - 120.5
									jai_ap_tds_can.plb - 120.6

---------------------------------------------------------------------------- */
  g_inr_currency_rounding NUMBER := 0;
  g_fcy_currency_rounding NUMBER := 2;
  -- added, Harshita for Bug#5131075(5346558)
	gn_invoice_id 					NUMBER ;
  gv_request_id           NUMBER ;

  -- Bug 5722028. Added by csahoo
	  gn_tds_rounding_factor NUMBER;
	  gd_tds_rounding_effective_date DATE;

	  FUNCTION get_rnded_value (p_tax_amount in number )
	  RETURN NUMBER ;
  -- End for bug 5722028.

  procedure status_update_chk_validate
  (
    p_invoice_id                         in                  number,
    p_invoice_line_number                in                  number    default   null, /* AP lines uptake */
    p_invoice_distribution_id            in                  number    default   null,
    p_match_status_flag                  in                  varchar2  default   null,
    p_is_invoice_validated               out       nocopy    varchar2,
    p_process_flag                       out       nocopy    varchar2,
    p_process_message                    out       nocopy    varchar2,
    p_codepath                           in out    nocopy    varchar2
   );


  procedure process_tds_at_inv_validate
  (
    p_invoice_id                         in                  number,
    p_vendor_id                          in                  number,
    p_vendor_site_id                     in                  number,
    p_accounting_date                    in                  date,
    p_invoice_currency_code              in                  varchar2,
    p_exchange_rate                      in                  number,
    p_set_of_books_id                    in                  number,
    p_org_id                             in                  number,
    p_call_from                          in                  varchar2,
    -- Bug 5722028. Added by csahoo
    p_creation_date                      in                  date,
    p_process_flag                       out       nocopy    varchar2,
    p_process_message                    out       nocopy    varchar2,
    p_codepath                           in out    nocopy    varchar2
  );


  procedure generate_tds_invoices
  (
    pn_invoice_id                         in                 number,
    pn_invoice_line_number                in                 number   default null, /* AP lines  */
    pn_invoice_distribution_id            in                 number   default null, /* Prepayment apply / unapply scenario */
    pv_invoice_num_prepay_apply           in                 varchar2 default null, /* Prepayment application secanrio */
    pv_invoice_num_to_tds_apply           in                 varchar2 default null, /* Prepayment unapplication secanrio */
    pv_invoice_num_to_vendor_apply        in                 varchar2 default null, /* Prepayment unapplication secanrio */
    pv_invoice_num_to_vendor_can          in                 varchar2 default null, /* Invoice Cancel Secnario */
    pn_threshold_hdr_id                   in                 number   default null, /* For validate scenario only */
    pn_taxable_amount                     in                 number,
    pn_tax_amount                         in                 number,
    pn_tax_id                             in                 number,
    pd_accounting_date                    in                 date,
    pv_tds_event                          in                 varchar2,
    pn_threshold_grp_id                   in                 number,
    pv_tds_invoice_num                    out      nocopy    varchar2,
    pv_cm_invoice_num                     out      nocopy    varchar2,
    pn_threshold_trx_id                   out      nocopy    number,
    -- Bug 5722028. Added by csahoo
    pd_creation_date                      in                 date,
    p_process_flag                        out      nocopy    varchar2,
    p_process_message                     out      nocopy    varchar2
  );

  procedure process_threshold_transition
  (
    p_threshold_grp_id                   in                  number,
    p_threshold_slab_id                  in                  number,
    p_invoice_id                         in                  number,
    p_vendor_id                          in                  number,
    p_vendor_site_id                     in                  number,
    p_accounting_date                    in                  date,
    p_tds_event                          in                  varchar2,
    p_org_id                             in                  number,
    pv_tds_invoice_num                   out       nocopy    varchar2,
    pv_cm_invoice_num                    out       nocopy    varchar2,
    p_process_flag                       out       nocopy    varchar2,
    p_process_message                    out       nocopy    varchar2
  );

  procedure import_and_approve
  (
    p_invoice_id                    in                       number,
    p_start_thhold_trx_id           in                       number,
    p_tds_event                     in                       varchar2,
    p_process_flag                  out            nocopy    varchar2,
    p_process_message               out            nocopy    varchar2
  ) ;

  procedure approve_tds_invoices
  (
    errbuf                          out            nocopy    varchar2,
    retcode                         out            nocopy    varchar2,
    p_parent_request_id             in             number,
    p_invoice_id                    in             number,
    p_vendor_id                     in             number,
    p_vendor_site_id                in             number,
    p_start_thhold_trx_id           in             number
  );

  /* Following procedure is called from ja_in_ap_aia_before_trg to update the ids of the TDS invoices */
  procedure populate_tds_invoice_id
  (
    p_invoice_id                        in                number,
    p_invoice_num                       in                varchar2,
    p_vendor_id                         in                number,
    p_vendor_site_id                    in                number,
    p_process_flag                      out     nocopy    varchar2,
    p_process_message                   out     nocopy    varchar2
  );

  procedure maintain_thhold_grps
  (
    p_threshold_grp_id                  in out    nocopy    number    ,
    p_vendor_id                         in                  number    default null,
    p_org_tan_num                       in                  varchar2  default null,
    p_vendor_pan_num                    in                  varchar2  default null,
    p_section_type                      in                  varchar2  default null,
    p_section_code                      in                  varchar2  default null,
    p_fin_year                          in                  number    default null,
    p_org_id                            in                  number    default null,
    p_trx_invoice_amount                in                  number    default null,
    p_trx_invoice_cancel_amount         in                  number    default null,
    p_trx_invoice_apply_amount          in                  number    default null,
    p_trx_invoice_unapply_amount        in                  number    default null,
    p_trx_tax_paid                      in                  number    default null,
    p_trx_thhold_change_tax_paid        in                  number    default null,
    p_trx_threshold_slab_id             in                  number    default null,
    p_tds_event                         in                  varchar2,
    p_invoice_id                        in                  number    default null,
    p_invoice_line_number               in                  number    default null, /* AP lines Uptake */
    p_invoice_distribution_id           in                  number    default null,
    p_remarks                           in                  varchar2  default null,
    -- Bug 5722028. Added by csahoo
    p_creation_date                      in                 date default sysdate,
    p_threshold_grp_audit_id            out       nocopy    number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );

  procedure insert_tds_thhold_trxs  --4333449
  (
    p_invoice_id                        in                  number,
    p_tds_event                         in                  varchar2,
    p_tax_id                            in                  number     default null,
    p_tax_rate                          in                  number     default null,
    p_taxable_amount                    in                  number     default null,
    p_tax_amount                        in                  number     default null,
    p_tds_authority_vendor_id           in                  number     default null,
    p_tds_authority_vendor_site_id      in                  number     default null,
    p_invoice_tds_authority_num         in                  varchar2   default null,
    p_invoice_tds_authority_type        in                  varchar2   default null,
    p_invoice_tds_authority_curr        in                  varchar2   default null,
    p_invoice_tds_authority_amt         in                  number     default null,
    p_invoice_tds_authority_id          in                  number     default null,
    p_vendor_id                         in                  number     default null,
    p_vendor_site_id                    in                  number     default null,
    p_invoice_vendor_num                in                  varchar2   default null,
    p_invoice_vendor_type               in                  varchar2   default null,
    p_invoice_vendor_curr               in                  varchar2   default null,
    p_invoice_vendor_amt                in                  number     default null,
    p_invoice_vendor_id                 in                  number     default null,
    p_parent_inv_payment_priority       in                  number     default null,
    p_parent_inv_exchange_rate          in                  number     default null
  );

	-- added, Harshita for Bug 5096787
	Procedure create_tds_after_holds_release
	(
					errbuf                       out        nocopy    varchar2,
					retcode                      out        nocopy    varchar2,
		p_invoice_id                 IN  number   ,
		p_invoice_amount             IN  number   ,
		p_payment_status_flag        IN varchar2  ,
		p_invoice_type_lookup_code   IN varchar2  ,
		p_vendor_id                  IN  number   ,
		p_vendor_site_id             IN  number   ,
		p_accounting_date            IN DATE      ,
		p_invoice_currency_code      IN varchar2  ,
		p_exchange_rate              IN number    ,
		p_set_of_books_id            IN number    ,
		p_org_id                     IN number    ,
		p_call_from                  IN varchar2  ,
		p_process_flag               IN varchar2  ,
		p_process_message            IN varchar2  ,
		p_codepath                   IN varchar2  ,
		p_request_id                 IN number default null-- added, Harshita for Bug#5131075(5346558)
	) ;
	-- ended, Harshita for Bug 5096787

	--Procedure Added by Sanjikum for Bug#5131075(4718907)
	PROCEDURE get_tds_threshold_slab(
																		p_prepay_distribution_id    IN              NUMBER,
																		p_threshold_grp_id          IN OUT  NOCOPY  NUMBER,
																		p_threshold_hdr_id          IN OUT  NOCOPY  NUMBER,
																		p_threshold_slab_id         OUT     NOCOPY  NUMBER,
																		p_threshold_type            OUT     NOCOPY  VARCHAR2,
																		p_process_flag              OUT     NOCOPY  VARCHAR2,
																		p_process_message           OUT     NOCOPY  VARCHAR2,
																		p_codepath                  IN OUT  NOCOPY  VARCHAR2);

	--Procedure Added by Sanjikum for Bug#5131075(4718907)
	PROCEDURE process_threshold_rollback(
																		p_invoice_id                IN              VARCHAR2,
																		p_before_threshold_type     IN              VARCHAR2,
																		p_after_threshold_type      IN              VARCHAR2,
																		p_before_threshold_slab_id  IN              NUMBER,
																		p_after_threshold_slab_id   IN              NUMBER,
																		p_threshold_grp_id          IN              NUMBER,
																		p_org_id                    IN              NUMBER,
																		p_accounting_date           IN              DATE,
																		p_invoice_distribution_id   IN              NUMBER DEFAULT NULL,
																		p_prepay_distribution_id    IN              NUMBER DEFAULT NULL,
																		p_process_flag              OUT     NOCOPY  VARCHAR2,
																		p_process_message           OUT     NOCOPY  VARCHAR2,
																		p_codepath                  IN OUT  NOCOPY  VARCHAR2);


end jai_ap_tds_generation_pkg;

/
