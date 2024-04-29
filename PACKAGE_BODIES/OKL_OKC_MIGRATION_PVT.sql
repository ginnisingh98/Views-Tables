--------------------------------------------------------
--  DDL for Package Body OKL_OKC_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OKC_MIGRATION_PVT" AS
/* $Header: OKLROKCB.pls 120.5 2006/07/14 12:00:18 dkagrawa noship $ */
G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKL_API.G_APP_NAME;
-- The Enities we are Handling are as listed below
--1.OKC_K_VERS_NUMBERS_V  -- cvmv
--2.OKC_K_HEADERS_V       -- chrv
--3.OKC_K_LINES_V         -- clev
--4.OKC_K_ITEMS_V         -- cimv
--5.OKC_K_PARTY_ROLES_V   -- cplv
--6.OKC_GOVERNANCES_V     -- gvev
--7.OKC_RULE_GROUPS_V     -- rgpv
--8.OKC_RG_PARTY_ROLES_V  -- rmpv
--9.OKC_CONTACTS_V        -- ctcv
-- End of Listing
-- Badriath Kuchibhotla
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_OKC_MIGRATION_PVT';

   /*
   -- mvasudev, 09/09/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_PARTY_CREATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.party_created';


   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(20)  := 'CONTRACT_ID';
   G_WF_ITM_PARTY_ID CONSTANT VARCHAR2(15)    := 'PARTY_ID';
   G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(20) := 'CONTRACT_PROCESS';
   G_WF_ITM_PARTY_ROLE_ID CONSTANT VARCHAR2(15)    := 'PARTY_ROLE_ID';

   --vthiruva, 15-Sep-2004
   -- Added Constants to enable Business Event
   G_WF_EVT_ASSET_FEE_CREATED CONSTANT VARCHAR2(60) := 'oracle.apps.okl.la.lease_contract.asset_fee_created';
   G_WF_EVT_ASSET_SERV_FEE_CRTD CONSTANT VARCHAR2(65) := 'oracle.apps.okl.la.lease_contract.asset_service_fee_created';
   G_WF_ITM_FEE_LINE_ID CONSTANT VARCHAR2(20) := 'FEE_LINE_ID';
   G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(20) := 'ASSET_ID';
   G_WF_ITM_SERV_LINE_ID CONSTANT VARCHAR2(30) := 'SERVICE_LINE_ID';

   /*
    * sjalasut: sep 15, 04 added constants used in raising business event. BEGIN
    */
   G_WF_EVT_CONTRACT_TERM_UPDATED CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.asset_filing_terms_updated';
   G_WF_EVT_ASSET_FILING_UPDATED  CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.asset_filing_updated';
   G_WF_EVT_ASSET_PROPTAX_UPDATED CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.asset_property_tax_updated';
   G_WF_EVT_SERV_PASS_UPDATED     CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.service_fee_passthrough_updated';
   G_WF_EVT_FEE_PASS_UPDATED      CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.fee_passthrough_updated';
   G_WF_EVT_SERV_FEXP_UPDATED     CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.service_fee_expense_updated';
   G_WF_EVT_FEE_EXP_UPDATED       CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.fee_expense_updated';
   G_WF_ITM_TERMS_ID CONSTANT VARCHAR2(30)           := 'TERMS_ID';
   G_WF_ITM_SERV_CHR_ID  CONSTANT VARCHAR2(30)       := 'SERVICE_CONTRACT_ID';
   G_WF_ITM_SERV_CLE_ID  CONSTANT VARCHAR2(30)       := 'SERVICE_CONTRACT_LINE_ID';



   /*
   -- mvasudev, 09/09/2004
   -- Added PROCEDURE to enable Business Event
   */
   -- Start of comments
   --
   -- Procedure Name  : raise_business_event
   -- Description     : local_procedure, raises business event by making a call to
   --                   okl_wf_pvt.raise_event
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE raise_business_event(
        p_api_version      IN NUMBER
       ,p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	      ,x_return_status    OUT NOCOPY VARCHAR2
       ,x_msg_count        OUT NOCOPY NUMBER
       ,x_msg_data         OUT NOCOPY VARCHAR2
       ,p_event_name       IN WF_EVENTS.NAME%TYPE
       ,p_event_param_list IN WF_PARAMETER_LIST_T
    )IS
	    l_process VARCHAR2(20);
     p_chr_id  okc_k_headers_b.id%TYPE;
     l_parameter_list WF_PARAMETER_LIST_T := p_event_param_list;
   BEGIN
     p_chr_id := wf_event.GetValueForParameter(G_WF_ITM_CONTRACT_ID,p_event_param_list);
     l_process := Okl_Lla_Util_Pvt.get_contract_process(p_chr_id);
     wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

     OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_event_name     => p_event_name,
                             p_parameters     => l_parameter_list);
   EXCEPTION
   WHEN OTHERS THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   END raise_business_event;
   /*
   -- mvasudev, 09/09/2004
   -- END, PROCEDURE to enable Business Event
   */

-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared cvmv record type
  -- to OKC cvmv declared record type
 PROCEDURE migrate_version(p_from   IN cvmv_rec_type,
                           p_to OUT NOCOPY OKC_VERSION_PUB.cvmv_rec_type) IS
  BEGIN
    p_to.chr_id := p_from.chr_id;
    p_to.major_version := p_from.major_version;
    p_to.minor_version := p_from.minor_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate_version;

 PROCEDURE migrate_version(p_from   IN OKC_VERSION_PUB.cvmv_rec_type,
                           p_to OUT NOCOPY cvmv_rec_type) IS
  BEGIN
    p_to.chr_id := p_from.chr_id;
    p_to.major_version := p_from.major_version;
    p_to.minor_version := p_from.minor_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate_version;
---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared chrv record type
  -- to OKC chrv declared record type
  PROCEDURE migrate_chrv(p_from IN chrv_rec_type,
                         p_to OUT NOCOPY OKC_CONTRACT_PUB.chrv_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.contract_number := p_from.contract_number;
    p_to.authoring_org_id := p_from.authoring_org_id;
    p_to.contract_number_modifier := p_from.contract_number_modifier;
    p_to.chr_id_response := p_from.chr_id_response;
    p_to.chr_id_award := p_from.chr_id_award;
    p_to.INV_ORGANIZATION_ID := p_from.INV_ORGANIZATION_ID;
    p_to.sts_code := p_from.sts_code;
    p_to.qcl_id := p_from.qcl_id;
    p_to.scs_code := p_from.scs_code;
    p_to.trn_code := p_from.trn_code;
    p_to.currency_code := p_from.currency_code;
    p_to.archived_yn := p_from.archived_yn;
    p_to.deleted_yn := p_from.deleted_yn;
    p_to.template_yn := p_from.template_yn;
    p_to.chr_type := p_from.chr_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.cust_po_number_req_yn := p_from.cust_po_number_req_yn;
    p_to.pre_pay_req_yn := p_from.pre_pay_req_yn;
    p_to.cust_po_number := p_from.cust_po_number;
    p_to.dpas_rating := p_from.dpas_rating;
    p_to.template_used := p_from.template_used;
    p_to.date_approved := p_from.date_approved;
    p_to.datetime_cancelled := p_from.datetime_cancelled;
    p_to.auto_renew_days := p_from.auto_renew_days;
    p_to.date_issued := p_from.date_issued;
    p_to.datetime_responded := p_from.datetime_responded;
    p_to.rfp_type := p_from.rfp_type;
    p_to.keep_on_mail_list := p_from.keep_on_mail_list;
    p_to.set_aside_percent := p_from.set_aside_percent;
    p_to.response_copies_req := p_from.response_copies_req;
    p_to.date_close_projected := p_from.date_close_projected;
    p_to.datetime_proposed := p_from.datetime_proposed;
    p_to.date_signed := p_from.date_signed;
    p_to.date_terminated := p_from.date_terminated;
    p_to.date_renewed := p_from.date_renewed;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.buy_or_sell := p_from.buy_or_sell;
    p_to.issue_or_receive := p_from.issue_or_receive;
    p_to.estimated_amount := p_from.estimated_amount;
    p_to.estimated_amount_renewed := p_from.estimated_amount_renewed;
    p_to.currency_code_renewed := p_from.currency_code_renewed;
    p_to.last_update_login := p_from.last_update_login;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.application_id := p_from.application_id;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
    p_to.orig_system_id1 := p_from.orig_system_id1;
    p_to.orig_system_reference1 := p_from.orig_system_reference1 ;
    p_to.program_id            := p_from.program_id;
    p_to.request_id            := p_from.request_id;
    p_to.program_update_date   := p_from.program_update_date;
    p_to.program_application_id  := p_from.program_application_id;
    p_to.price_list_id         := p_from.price_list_id;
    p_to.pricing_date          := p_from.pricing_date;
    p_to.sign_by_date          := p_from.sign_by_date;
    p_to.total_line_list_price   := p_from.total_line_list_price;
    p_to.USER_ESTIMATED_AMOUNT   := p_from.USER_ESTIMATED_AMOUNT;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.description := p_from.description;
    p_to.cognomen := p_from.cognomen;
    p_to.non_response_reason := p_from.non_response_reason;
    p_to.non_response_explain := p_from.non_response_explain;
    p_to.set_aside_reason := p_from.set_aside_reason;
-- rules migration changes
p_to.bill_to_site_use_id  := p_from.bill_to_site_use_id;
p_to.cust_acct_id         := p_from.cust_acct_id;
p_to.conversion_type      := p_from.conversion_type;
p_to.conversion_rate      := p_from.conversion_rate;
p_to.conversion_rate_date := p_from.conversion_rate_date;
p_to.conversion_euro_rate := p_from.conversion_euro_rate;
p_to.inv_rule_id          := p_from.inv_rule_id;
p_to.renewal_type_code    := p_from.renewal_type_code;
p_to.renewal_notify_to    := p_from.renewal_notify_to;
p_to.renewal_end_date     := p_from.renewal_end_date;
p_to.ship_to_site_use_id  := p_from.ship_to_site_use_id;
p_to.payment_term_id      := p_from.payment_term_id;
p_to.org_id               := p_from.authoring_org_id;  --MOAC

  END migrate_chrv;
---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared chrv record type
  -- to Locally declared chrv record type
  PROCEDURE migrate_chrv(p_from IN OKC_CONTRACT_PUB.chrv_rec_type,
                                   p_to OUT NOCOPY chrv_rec_type ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.contract_number := p_from.contract_number;
    p_to.authoring_org_id := p_from.authoring_org_id;
    p_to.contract_number_modifier := p_from.contract_number_modifier;
    p_to.chr_id_response := p_from.chr_id_response;
    p_to.chr_id_award := p_from.chr_id_award;
    p_to.INV_ORGANIZATION_ID := p_from.INV_ORGANIZATION_ID;
    p_to.sts_code := p_from.sts_code;
    p_to.qcl_id := p_from.qcl_id;
    p_to.scs_code := p_from.scs_code;
    p_to.trn_code := p_from.trn_code;
    p_to.currency_code := p_from.currency_code;
    p_to.archived_yn := p_from.archived_yn;
    p_to.deleted_yn := p_from.deleted_yn;
    p_to.template_yn := p_from.template_yn;
    p_to.chr_type := p_from.chr_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.cust_po_number_req_yn := p_from.cust_po_number_req_yn;
    p_to.pre_pay_req_yn := p_from.pre_pay_req_yn;
    p_to.cust_po_number := p_from.cust_po_number;
    p_to.dpas_rating := p_from.dpas_rating;
    p_to.template_used := p_from.template_used;
    p_to.date_approved := p_from.date_approved;
    p_to.datetime_cancelled := p_from.datetime_cancelled;
    p_to.auto_renew_days := p_from.auto_renew_days;
    p_to.date_issued := p_from.date_issued;
    p_to.datetime_responded := p_from.datetime_responded;
    p_to.rfp_type := p_from.rfp_type;
    p_to.keep_on_mail_list := p_from.keep_on_mail_list;
    p_to.set_aside_percent := p_from.set_aside_percent;
    p_to.response_copies_req := p_from.response_copies_req;
    p_to.date_close_projected := p_from.date_close_projected;
    p_to.datetime_proposed := p_from.datetime_proposed;
    p_to.date_signed := p_from.date_signed;
    p_to.date_terminated := p_from.date_terminated;
    p_to.date_renewed := p_from.date_renewed;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.buy_or_sell := p_from.buy_or_sell;
    p_to.issue_or_receive := p_from.issue_or_receive;
    p_to.estimated_amount := p_from.estimated_amount;
    p_to.estimated_amount_renewed := p_from.estimated_amount_renewed;
    p_to.currency_code_renewed := p_from.currency_code_renewed;
    p_to.last_update_login := p_from.last_update_login;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.application_id := p_from.application_id;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
    p_to.orig_system_id1 := p_from.orig_system_id1;
    p_to.orig_system_reference1 := p_from.orig_system_reference1 ;
    p_to.program_id            := p_from.program_id;
    p_to.request_id            := p_from.request_id;
    p_to.program_update_date   := p_from.program_update_date;
    p_to.program_application_id  := p_from.program_application_id;
    p_to.price_list_id         := p_from.price_list_id;
    p_to.pricing_date          := p_from.pricing_date;
    p_to.sign_by_date          := p_from.sign_by_date;
    p_to.total_line_list_price   := p_from.total_line_list_price;
    p_to.USER_ESTIMATED_AMOUNT   := p_from.USER_ESTIMATED_AMOUNT;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.description := p_from.description;
    p_to.cognomen := p_from.cognomen;
    p_to.non_response_reason := p_from.non_response_reason;
    p_to.non_response_explain := p_from.non_response_explain;
    p_to.set_aside_reason := p_from.set_aside_reason;
-- rules migration changes
p_to.bill_to_site_use_id  := p_from.bill_to_site_use_id;
p_to.cust_acct_id         := p_from.cust_acct_id;
p_to.conversion_type      := p_from.conversion_type;
p_to.conversion_rate      := p_from.conversion_rate;
p_to.conversion_rate_date := p_from.conversion_rate_date;
p_to.conversion_euro_rate := p_from.conversion_euro_rate;
p_to.inv_rule_id          := p_from.inv_rule_id;
p_to.renewal_type_code    := p_from.renewal_type_code;
p_to.renewal_notify_to    := p_from.renewal_notify_to;
p_to.renewal_end_date     := p_from.renewal_end_date;
p_to.ship_to_site_use_id  := p_from.ship_to_site_use_id;
p_to.payment_term_id      := p_from.payment_term_id;

END migrate_chrv;
-----------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared clev record type
  -- to OKC clev declared record type
  PROCEDURE migrate_clev(p_from IN clev_rec_type,
                                  p_to OUT NOCOPY OKC_CONTRACT_PUB.clev_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.line_number := p_from.line_number;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.display_sequence := p_from.display_sequence;
    p_to.sts_code := p_from.sts_code;
    p_to.trn_code := p_from.trn_code;
    p_to.lse_id := p_from.lse_id;
    p_to.exception_yn := p_from.exception_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.hidden_ind := p_from.hidden_ind;
    p_to.price_unit := p_from.price_unit;
    p_to.price_unit_percent := p_from.price_unit_percent;
    p_to.price_negotiated := p_from.price_negotiated;
    p_to.price_negotiated_renewed := p_from.price_negotiated_renewed;
    p_to.price_level_ind := p_from.price_level_ind;
    p_to.invoice_line_level_ind := p_from.invoice_line_level_ind;
    p_to.dpas_rating := p_from.dpas_rating;
    p_to.template_used := p_from.template_used;
    p_to.price_type := p_from.price_type;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_code_renewed := p_from.currency_code_renewed;
    p_to.last_update_login := p_from.last_update_login;
    p_to.date_terminated := p_from.date_terminated;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.date_renewed := p_from.date_renewed;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
    p_to.orig_system_id1 :=p_from.orig_system_id1 ;
    p_to.orig_system_reference1 := p_from.orig_system_reference1 ;
    p_to.request_id                := p_from.request_id;
    p_to.program_application_id    := p_from.program_application_id;
    p_to.program_id                := p_from.program_id;
    p_to.program_update_date       := p_from.program_update_date;
    p_to.price_list_id             := p_from.price_list_id;
    p_to.pricing_date              := p_from.pricing_date;
    p_to.price_list_line_id        := p_from.price_list_line_id;
    p_to.line_list_price           := p_from.line_list_price;
    p_to.item_to_price_yn          := p_from.item_to_price_yn;
    p_to.price_basis_yn            := p_from.price_basis_yn;
    p_to.config_header_id          := p_from.config_header_id;
    p_to.config_revision_number    := p_from.config_revision_number;
    p_to.config_complete_yn        := p_from.config_complete_yn;
    p_to.config_valid_yn           := p_from.config_valid_yn;
    p_to.config_top_model_line_id  := p_from.config_top_model_line_id;
    p_to.config_item_type          := p_from.config_item_type;
---Bug.No.-1942374
    p_to.CONFIG_ITEM_ID          := p_from.CONFIG_ITEM_ID;
---Bug.No.-1942374
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.comments := p_from.comments;
    p_to.item_description := p_from.item_description;
    p_to.oke_boe_description := p_from.oke_boe_description;
    p_to.cognomen := p_from.cognomen;
    p_to.block23text := p_from.block23text;
-- rules migration changes
p_to.cust_acct_id         := p_from.cust_acct_id;
p_to.bill_to_site_use_id  := p_from.bill_to_site_use_id;
p_to.inv_rule_id          := p_from.inv_rule_id;
p_to.line_renewal_type_code    := p_from.line_renewal_type_code;
p_to.ship_to_site_use_id  := p_from.ship_to_site_use_id;
p_to.payment_term_id      := p_from.payment_term_id;


END migrate_clev;
-----------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared clev record type
  -- to Locally declared clev record type
  PROCEDURE migrate_clev(p_from IN OKC_CONTRACT_PUB.clev_rec_type,
                                  p_to OUT NOCOPY clev_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.line_number := p_from.line_number;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.display_sequence := p_from.display_sequence;
    p_to.sts_code := p_from.sts_code;
    p_to.trn_code := p_from.trn_code;
    p_to.lse_id := p_from.lse_id;
    p_to.exception_yn := p_from.exception_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.hidden_ind := p_from.hidden_ind;
    p_to.price_unit := p_from.price_unit;
    p_to.price_unit_percent := p_from.price_unit_percent;
    p_to.price_negotiated := p_from.price_negotiated;
    p_to.price_negotiated_renewed := p_from.price_negotiated_renewed;
    p_to.price_level_ind := p_from.price_level_ind;
    p_to.invoice_line_level_ind := p_from.invoice_line_level_ind;
    p_to.dpas_rating := p_from.dpas_rating;
    p_to.template_used := p_from.template_used;
    p_to.price_type := p_from.price_type;
    p_to.currency_code := p_from.currency_code;
    p_to.currency_code_renewed := p_from.currency_code_renewed;
    p_to.last_update_login := p_from.last_update_login;
    p_to.date_terminated := p_from.date_terminated;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.date_renewed := p_from.date_renewed;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
    p_to.orig_system_id1 :=p_from.orig_system_id1 ;
    p_to.orig_system_reference1 := p_from.orig_system_reference1 ;
    p_to.request_id                := p_from.request_id;
    p_to.program_application_id    := p_from.program_application_id;
    p_to.program_id                := p_from.program_id;
    p_to.program_update_date       := p_from.program_update_date;
    p_to.price_list_id             := p_from.price_list_id;
    p_to.pricing_date              := p_from.pricing_date;
    p_to.price_list_line_id        := p_from.price_list_line_id;
    p_to.line_list_price           := p_from.line_list_price;
    p_to.item_to_price_yn          := p_from.item_to_price_yn;
    p_to.price_basis_yn            := p_from.price_basis_yn;
    p_to.config_header_id          := p_from.config_header_id;
    p_to.config_revision_number    := p_from.config_revision_number;
    p_to.config_complete_yn        := p_from.config_complete_yn;
    p_to.config_valid_yn           := p_from.config_valid_yn;
    p_to.config_top_model_line_id  := p_from.config_top_model_line_id;
    p_to.config_item_type          := p_from.config_item_type;
---Bug.No.-1942374
    p_to.CONFIG_ITEM_ID          := p_from.CONFIG_ITEM_ID;
---Bug.No.-1942374
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.comments := p_from.comments;
    p_to.item_description := p_from.item_description;
    p_to.oke_boe_description := p_from.oke_boe_description;
    p_to.cognomen := p_from.cognomen;
    p_to.block23text := p_from.block23text;
-- rules migration changes
p_to.cust_acct_id         := p_from.cust_acct_id;
p_to.bill_to_site_use_id  := p_from.bill_to_site_use_id;
p_to.inv_rule_id          := p_from.inv_rule_id;
p_to.line_renewal_type_code    := p_from.line_renewal_type_code;
p_to.ship_to_site_use_id  := p_from.ship_to_site_use_id;
p_to.payment_term_id      := p_from.payment_term_id;
END migrate_clev;
-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared cimv record type
  -- to OKC cimv declared record type
PROCEDURE migrate_okl_okc_item(p_cimv_rec_type IN cimv_rec_type,
                                 x_cimv_rec_type OUT NOCOPY OKC_CONTRACT_ITEM_PUB.cimv_rec_type) IS

BEGIN
    x_cimv_rec_type.id := p_cimv_rec_type.id;
    x_cimv_rec_type.cle_id := p_cimv_rec_type.cle_id;
    x_cimv_rec_type.chr_id := p_cimv_rec_type.chr_id;
    x_cimv_rec_type.cle_id_for := p_cimv_rec_type.cle_id_for;
    x_cimv_rec_type.dnz_chr_id := p_cimv_rec_type.dnz_chr_id;
    x_cimv_rec_type.object1_id1 := p_cimv_rec_type.object1_id1;
    x_cimv_rec_type.object1_id2 := p_cimv_rec_type.object1_id2;
    x_cimv_rec_type.jtot_object1_code := p_cimv_rec_type.jtot_object1_code;
    x_cimv_rec_type.uom_code := p_cimv_rec_type.uom_code;
    x_cimv_rec_type.exception_yn := p_cimv_rec_type.exception_yn;
    x_cimv_rec_type.number_of_items := p_cimv_rec_type.number_of_items;
    x_cimv_rec_type.upg_orig_system_ref := p_cimv_rec_type.upg_orig_system_ref;
    x_cimv_rec_type.upg_orig_system_ref_id := p_cimv_rec_type.upg_orig_system_ref_id;
    x_cimv_rec_type.priced_item_yn := p_cimv_rec_type.priced_item_yn;
    x_cimv_rec_type.object_version_number := p_cimv_rec_type.object_version_number;
    x_cimv_rec_type.created_by := p_cimv_rec_type.created_by;
    x_cimv_rec_type.creation_date := p_cimv_rec_type.creation_date;
    x_cimv_rec_type.last_updated_by := p_cimv_rec_type.last_updated_by;
    x_cimv_rec_type.last_update_date := p_cimv_rec_type.last_update_date;
    x_cimv_rec_type.last_update_login := p_cimv_rec_type.last_update_login;
  END migrate_okl_okc_item;
-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared cimv record type
  -- to Locally declared cimv record type
  PROCEDURE migrate_okc_okl_item(p_cimv_rec_type IN OKC_CONTRACT_ITEM_PUB.cimv_rec_type,
                                 x_cimv_rec_type OUT NOCOPY cimv_rec_type) IS
  BEGIN
    x_cimv_rec_type.id := p_cimv_rec_type.id;
    x_cimv_rec_type.cle_id := p_cimv_rec_type.cle_id;
    x_cimv_rec_type.chr_id := p_cimv_rec_type.chr_id;
    x_cimv_rec_type.cle_id_for := p_cimv_rec_type.cle_id_for;
    x_cimv_rec_type.dnz_chr_id := p_cimv_rec_type.dnz_chr_id;
    x_cimv_rec_type.object1_id1 := p_cimv_rec_type.object1_id1;
    x_cimv_rec_type.object1_id2 := p_cimv_rec_type.object1_id2;
    x_cimv_rec_type.jtot_object1_code := p_cimv_rec_type.jtot_object1_code;
    x_cimv_rec_type.uom_code := p_cimv_rec_type.uom_code;
    x_cimv_rec_type.exception_yn := p_cimv_rec_type.exception_yn;
    x_cimv_rec_type.number_of_items := p_cimv_rec_type.number_of_items;
    x_cimv_rec_type.upg_orig_system_ref := p_cimv_rec_type.upg_orig_system_ref;
    x_cimv_rec_type.upg_orig_system_ref_id := p_cimv_rec_type.upg_orig_system_ref_id;
    x_cimv_rec_type.priced_item_yn := p_cimv_rec_type.priced_item_yn;
    x_cimv_rec_type.object_version_number := p_cimv_rec_type.object_version_number;
    x_cimv_rec_type.created_by := p_cimv_rec_type.created_by;
    x_cimv_rec_type.creation_date := p_cimv_rec_type.creation_date;
    x_cimv_rec_type.last_updated_by := p_cimv_rec_type.last_updated_by;
    x_cimv_rec_type.last_update_date := p_cimv_rec_type.last_update_date;
    x_cimv_rec_type.last_update_login := p_cimv_rec_type.last_update_login;
  END migrate_okc_okl_item;
---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared cplv record type
  -- to OKC cplv declared record type
  PROCEDURE migrate_okl_okc_party(p_cplv_rec_type IN cplv_rec_type,
                                  x_cplv_rec_type OUT NOCOPY OKC_CONTRACT_PARTY_PUB.cplv_rec_type) IS
  BEGIN
    x_cplv_rec_type.id := p_cplv_rec_type.id;
    x_cplv_rec_type.cpl_id := p_cplv_rec_type.cpl_id;
    x_cplv_rec_type.chr_id := p_cplv_rec_type.chr_id;
    x_cplv_rec_type.cle_id := p_cplv_rec_type.cle_id;
    x_cplv_rec_type.dnz_chr_id := p_cplv_rec_type.dnz_chr_id;
    x_cplv_rec_type.rle_code := p_cplv_rec_type.rle_code;
    x_cplv_rec_type.object1_id1 := p_cplv_rec_type.object1_id1;
    x_cplv_rec_type.object1_id2 := p_cplv_rec_type.object1_id2;
    x_cplv_rec_type.JTOT_OBJECT1_CODE := p_cplv_rec_type.JTOT_OBJECT1_CODE;
    x_cplv_rec_type.object_version_number := p_cplv_rec_type.object_version_number;
    x_cplv_rec_type.created_by := p_cplv_rec_type.created_by;
    x_cplv_rec_type.creation_date := p_cplv_rec_type.creation_date;
    x_cplv_rec_type.last_updated_by := p_cplv_rec_type.last_updated_by;
    x_cplv_rec_type.last_update_date := p_cplv_rec_type.last_update_date;
    x_cplv_rec_type.code := p_cplv_rec_type.code;
    x_cplv_rec_type.facility := p_cplv_rec_type.facility;
    x_cplv_rec_type.minority_group_lookup_code := p_cplv_rec_type.minority_group_lookup_code;
    x_cplv_rec_type.small_business_flag := p_cplv_rec_type.small_business_flag;
    x_cplv_rec_type.women_owned_flag := p_cplv_rec_type.women_owned_flag;
    x_cplv_rec_type.last_update_login := p_cplv_rec_type.last_update_login;
    x_cplv_rec_type.attribute_category := p_cplv_rec_type.attribute_category;
    x_cplv_rec_type.attribute1 := p_cplv_rec_type.attribute1;
    x_cplv_rec_type.attribute2 := p_cplv_rec_type.attribute2;
    x_cplv_rec_type.attribute3 := p_cplv_rec_type.attribute3;
    x_cplv_rec_type.attribute4 := p_cplv_rec_type.attribute4;
    x_cplv_rec_type.attribute5 := p_cplv_rec_type.attribute5;
    x_cplv_rec_type.attribute6 := p_cplv_rec_type.attribute6;
    x_cplv_rec_type.attribute7 := p_cplv_rec_type.attribute7;
    x_cplv_rec_type.attribute8 := p_cplv_rec_type.attribute8;
    x_cplv_rec_type.attribute9 := p_cplv_rec_type.attribute9;
    x_cplv_rec_type.attribute10 := p_cplv_rec_type.attribute10;
    x_cplv_rec_type.attribute11 := p_cplv_rec_type.attribute11;
    x_cplv_rec_type.attribute12 := p_cplv_rec_type.attribute12;
    x_cplv_rec_type.attribute13 := p_cplv_rec_type.attribute13;
    x_cplv_rec_type.attribute14 := p_cplv_rec_type.attribute14;
    x_cplv_rec_type.attribute15 := p_cplv_rec_type.attribute15;
    x_cplv_rec_type.sfwt_flag := p_cplv_rec_type.sfwt_flag;
    x_cplv_rec_type.cognomen := p_cplv_rec_type.cognomen;
    x_cplv_rec_type.alias := p_cplv_rec_type.alias;
-- rules migration changes
x_cplv_rec_type.bill_to_site_use_id  := p_cplv_rec_type.bill_to_site_use_id;
x_cplv_rec_type.cust_acct_id         := p_cplv_rec_type.cust_acct_id;

END migrate_okl_okc_party;
-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared cplv record type
  -- to Locally declared cplv record type
  PROCEDURE migrate_okc_okl_party(p_cplv_rec_type IN OKC_CONTRACT_PARTY_PUB.cplv_rec_type,
                                  x_cplv_rec_type OUT NOCOPY cplv_rec_type) IS
  BEGIN
    x_cplv_rec_type.id := p_cplv_rec_type.id;
    x_cplv_rec_type.cpl_id := p_cplv_rec_type.cpl_id;
    x_cplv_rec_type.chr_id := p_cplv_rec_type.chr_id;
    x_cplv_rec_type.cle_id := p_cplv_rec_type.cle_id;
    x_cplv_rec_type.dnz_chr_id := p_cplv_rec_type.dnz_chr_id;
    x_cplv_rec_type.rle_code := p_cplv_rec_type.rle_code;
    x_cplv_rec_type.object1_id1 := p_cplv_rec_type.object1_id1;
    x_cplv_rec_type.object1_id2 := p_cplv_rec_type.object1_id2;
    x_cplv_rec_type.JTOT_OBJECT1_CODE := p_cplv_rec_type.JTOT_OBJECT1_CODE;
    x_cplv_rec_type.object_version_number := p_cplv_rec_type.object_version_number;
    x_cplv_rec_type.created_by := p_cplv_rec_type.created_by;
    x_cplv_rec_type.creation_date := p_cplv_rec_type.creation_date;
    x_cplv_rec_type.last_updated_by := p_cplv_rec_type.last_updated_by;
    x_cplv_rec_type.last_update_date := p_cplv_rec_type.last_update_date;
    x_cplv_rec_type.code := p_cplv_rec_type.code;
    x_cplv_rec_type.facility := p_cplv_rec_type.facility;
    x_cplv_rec_type.minority_group_lookup_code := p_cplv_rec_type.minority_group_lookup_code;
    x_cplv_rec_type.small_business_flag := p_cplv_rec_type.small_business_flag;
    x_cplv_rec_type.women_owned_flag := p_cplv_rec_type.women_owned_flag;
    x_cplv_rec_type.last_update_login := p_cplv_rec_type.last_update_login;
    x_cplv_rec_type.attribute_category := p_cplv_rec_type.attribute_category;
    x_cplv_rec_type.attribute1 := p_cplv_rec_type.attribute1;
    x_cplv_rec_type.attribute2 := p_cplv_rec_type.attribute2;
    x_cplv_rec_type.attribute3 := p_cplv_rec_type.attribute3;
    x_cplv_rec_type.attribute4 := p_cplv_rec_type.attribute4;
    x_cplv_rec_type.attribute5 := p_cplv_rec_type.attribute5;
    x_cplv_rec_type.attribute6 := p_cplv_rec_type.attribute6;
    x_cplv_rec_type.attribute7 := p_cplv_rec_type.attribute7;
    x_cplv_rec_type.attribute8 := p_cplv_rec_type.attribute8;
    x_cplv_rec_type.attribute9 := p_cplv_rec_type.attribute9;
    x_cplv_rec_type.attribute10 := p_cplv_rec_type.attribute10;
    x_cplv_rec_type.attribute11 := p_cplv_rec_type.attribute11;
    x_cplv_rec_type.attribute12 := p_cplv_rec_type.attribute12;
    x_cplv_rec_type.attribute13 := p_cplv_rec_type.attribute13;
    x_cplv_rec_type.attribute14 := p_cplv_rec_type.attribute14;
    x_cplv_rec_type.attribute15 := p_cplv_rec_type.attribute15;
    x_cplv_rec_type.sfwt_flag := p_cplv_rec_type.sfwt_flag;
    x_cplv_rec_type.cognomen := p_cplv_rec_type.cognomen;
    x_cplv_rec_type.alias := p_cplv_rec_type.alias;
-- rules migration changes
x_cplv_rec_type.bill_to_site_use_id  := p_cplv_rec_type.bill_to_site_use_id;
x_cplv_rec_type.cust_acct_id         := p_cplv_rec_type.cust_acct_id;
END migrate_okc_okl_party;
-- Badriath Kuchibhotla
-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared gvev record type
  -- to OKC gvev declared record type
  PROCEDURE migrate_gvev(p_from IN gvev_rec_type,
                                        p_to OUT NOCOPY OKC_CONTRACT_PUB.gvev_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id_referred := p_from.chr_id_referred;
    p_to.cle_id_referred := p_from.cle_id_referred;
    p_to.isa_agreement_id := p_from.isa_agreement_id;
    p_to.copied_only_yn := p_from.copied_only_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate_gvev;
-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared gvev record type
  -- to Locally declared gvev record type
  PROCEDURE migrate_gvev(p_from IN OKC_CONTRACT_PUB.gvev_rec_type,
                         p_to OUT NOCOPY gvev_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id_referred := p_from.chr_id_referred;
    p_to.cle_id_referred := p_from.cle_id_referred;
    p_to.isa_agreement_id := p_from.isa_agreement_id;
    p_to.copied_only_yn := p_from.copied_only_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate_gvev;
---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared ctcv record type
  -- to OKC ctcv declared record type
  PROCEDURE migrate_okl_okc_contact(p_ctcv_rec_type IN ctcv_rec_type,
                                     x_ctcv_rec_type OUT NOCOPY OKC_CONTRACT_PARTY_PUB.ctcv_rec_type) IS
  BEGIN
    x_ctcv_rec_type.id := p_ctcv_rec_type.id;
    x_ctcv_rec_type.cpl_id := p_ctcv_rec_type.cpl_id;
    x_ctcv_rec_type.cro_code := p_ctcv_rec_type.cro_code;
    x_ctcv_rec_type.dnz_chr_id := p_ctcv_rec_type.dnz_chr_id;
    x_ctcv_rec_type.object1_id1 := p_ctcv_rec_type.object1_id1;
    x_ctcv_rec_type.object1_id2 := p_ctcv_rec_type.object1_id2;
    x_ctcv_rec_type.JTOT_OBJECT1_CODE := p_ctcv_rec_type.JTOT_OBJECT1_CODE;
    x_ctcv_rec_type.object_version_number := p_ctcv_rec_type.object_version_number;
    x_ctcv_rec_type.created_by := p_ctcv_rec_type.created_by;
    x_ctcv_rec_type.creation_date := p_ctcv_rec_type.creation_date;
    x_ctcv_rec_type.last_updated_by := p_ctcv_rec_type.last_updated_by;
    x_ctcv_rec_type.last_update_date := p_ctcv_rec_type.last_update_date;
    x_ctcv_rec_type.contact_sequence := p_ctcv_rec_type.contact_sequence;
    x_ctcv_rec_type.last_update_login := p_ctcv_rec_type.last_update_login;
    x_ctcv_rec_type.attribute_category := p_ctcv_rec_type.attribute_category;
    x_ctcv_rec_type.attribute1 := p_ctcv_rec_type.attribute1;
    x_ctcv_rec_type.attribute2 := p_ctcv_rec_type.attribute2;
    x_ctcv_rec_type.attribute3 := p_ctcv_rec_type.attribute3;
    x_ctcv_rec_type.attribute4 := p_ctcv_rec_type.attribute4;
    x_ctcv_rec_type.attribute5 := p_ctcv_rec_type.attribute5;
    x_ctcv_rec_type.attribute6 := p_ctcv_rec_type.attribute6;
    x_ctcv_rec_type.attribute7 := p_ctcv_rec_type.attribute7;
    x_ctcv_rec_type.attribute8 := p_ctcv_rec_type.attribute8;
    x_ctcv_rec_type.attribute9 := p_ctcv_rec_type.attribute9;
    x_ctcv_rec_type.attribute10 := p_ctcv_rec_type.attribute10;
    x_ctcv_rec_type.attribute11 := p_ctcv_rec_type.attribute11;
    x_ctcv_rec_type.attribute12 := p_ctcv_rec_type.attribute12;
    x_ctcv_rec_type.attribute13 := p_ctcv_rec_type.attribute13;
    x_ctcv_rec_type.attribute14 := p_ctcv_rec_type.attribute14;
    x_ctcv_rec_type.attribute15 := p_ctcv_rec_type.attribute15;
    x_ctcv_rec_type.start_date := p_ctcv_rec_type.start_date;
    x_ctcv_rec_type.end_date := p_ctcv_rec_type.end_date;
  END migrate_okl_okc_contact;
---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared ctcv record type
  -- to OKC ctcv declared record type
  PROCEDURE migrate_okc_okl_contact(p_ctcv_rec_type IN OKC_CONTRACT_PARTY_PUB.ctcv_rec_type,
                                     x_ctcv_rec_type OUT NOCOPY ctcv_rec_type) IS
  BEGIN
    x_ctcv_rec_type.id := p_ctcv_rec_type.id;
    x_ctcv_rec_type.cpl_id := p_ctcv_rec_type.cpl_id;
    x_ctcv_rec_type.cro_code := p_ctcv_rec_type.cro_code;
    x_ctcv_rec_type.dnz_chr_id := p_ctcv_rec_type.dnz_chr_id;
    x_ctcv_rec_type.object1_id1 := p_ctcv_rec_type.object1_id1;
    x_ctcv_rec_type.object1_id2 := p_ctcv_rec_type.object1_id2;
    x_ctcv_rec_type.JTOT_OBJECT1_CODE := p_ctcv_rec_type.JTOT_OBJECT1_CODE;
    x_ctcv_rec_type.object_version_number := p_ctcv_rec_type.object_version_number;
    x_ctcv_rec_type.created_by := p_ctcv_rec_type.created_by;
    x_ctcv_rec_type.creation_date := p_ctcv_rec_type.creation_date;
    x_ctcv_rec_type.last_updated_by := p_ctcv_rec_type.last_updated_by;
    x_ctcv_rec_type.last_update_date := p_ctcv_rec_type.last_update_date;
    x_ctcv_rec_type.contact_sequence := p_ctcv_rec_type.contact_sequence;
    x_ctcv_rec_type.last_update_login := p_ctcv_rec_type.last_update_login;
    x_ctcv_rec_type.attribute_category := p_ctcv_rec_type.attribute_category;
    x_ctcv_rec_type.attribute1 := p_ctcv_rec_type.attribute1;
    x_ctcv_rec_type.attribute2 := p_ctcv_rec_type.attribute2;
    x_ctcv_rec_type.attribute3 := p_ctcv_rec_type.attribute3;
    x_ctcv_rec_type.attribute4 := p_ctcv_rec_type.attribute4;
    x_ctcv_rec_type.attribute5 := p_ctcv_rec_type.attribute5;
    x_ctcv_rec_type.attribute6 := p_ctcv_rec_type.attribute6;
    x_ctcv_rec_type.attribute7 := p_ctcv_rec_type.attribute7;
    x_ctcv_rec_type.attribute8 := p_ctcv_rec_type.attribute8;
    x_ctcv_rec_type.attribute9 := p_ctcv_rec_type.attribute9;
    x_ctcv_rec_type.attribute10 := p_ctcv_rec_type.attribute10;
    x_ctcv_rec_type.attribute11 := p_ctcv_rec_type.attribute11;
    x_ctcv_rec_type.attribute12 := p_ctcv_rec_type.attribute12;
    x_ctcv_rec_type.attribute13 := p_ctcv_rec_type.attribute13;
    x_ctcv_rec_type.attribute14 := p_ctcv_rec_type.attribute14;
    x_ctcv_rec_type.attribute15 := p_ctcv_rec_type.attribute15;
    x_ctcv_rec_type.start_date := p_ctcv_rec_type.start_date;
    x_ctcv_rec_type.end_date := p_ctcv_rec_type.end_date;
  END migrate_okc_okl_contact;
-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared cimv record type
  -- to OKC rgpv declared record type
--okl to okc
PROCEDURE migrate_rgpv (
    p_from  IN rgpv_rec_type,
    p_to    IN OUT NOCOPY okc_rule_pub.rgpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgd_code := p_from.rgd_code;
    p_to.sat_code := p_from.sat_code;
    p_to.rgp_type := p_from.rgp_type;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_rgp_id := p_from.parent_rgp_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
--tl columns
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
END migrate_rgpv;
--okc to okl
PROCEDURE migrate_rgpv (
    p_from  IN okc_rule_pub.rgpv_rec_type,
    p_to    IN OUT NOCOPY rgpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgd_code := p_from.rgd_code;
    p_to.sat_code := p_from.sat_code;
    p_to.rgp_type := p_from.rgp_type;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_rgp_id := p_from.parent_rgp_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
--tl columns
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
END migrate_rgpv;
-------------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared cimv record type
  -- to OKC rmpv declared record type
--okl to okc
PROCEDURE migrate_rmpv(
    p_from  IN rmpv_rec_type,
    p_to    IN OUT NOCOPY okc_rule_pub.rmpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgp_id := p_from.rgp_id;
    p_to.rrd_id := p_from.rrd_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
END migrate_rmpv;
--okc to okl
PROCEDURE migrate_rmpv(
    p_from  IN okc_rule_pub.rmpv_rec_type,
    p_to    IN OUT NOCOPY rmpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rgp_id := p_from.rgp_id;
    p_to.rrd_id := p_from.rrd_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
END migrate_rmpv;
--------------------------------------------------------------------------------
PROCEDURE version_contract(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
        p_cvmv_rec          IN cvmv_rec_type,
    p_commit            IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
        x_cvmv_rec          OUT NOCOPY cvmv_rec_type) AS

    lr_cvmv_rec_type_in            OKC_VERSION_PUB.cvmv_rec_type;
    lr_cvmv_rec_type_out           OKC_VERSION_PUB.cvmv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_VERSION_PUB';
  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared cvmv record
    -- to OKC declared cvmv record type as process of input
    migrate_version(p_cvmv_rec,
                    lr_cvmv_rec_type_in);
    -- Calling the actual OKC api
    OKC_VERSION_PUB.version_contract(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_cvmv_rec      => lr_cvmv_rec_type_in,
                                 p_commit        => p_commit,
                                     x_cvmv_rec      => lr_cvmv_rec_type_out);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from OKC declared cimv record type
    -- to locally declared cimv record as process of input
    migrate_version(lr_cvmv_rec_type_out,
                    x_cvmv_rec);
    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END version_contract;
-------------------------------------------------------------------------------------------
PROCEDURE version_contract(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
        p_cvmv_tbl          IN cvmv_tbl_type,
    p_commit            IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
        x_cvmv_tbl          OUT NOCOPY cvmv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_VERISON_PVT';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_cvmv_tbl.COUNT>0) THEN
       i := p_cvmv_tbl.FIRST;
       LOOP
         version_contract(p_api_version   =>p_api_version,
                          p_init_msg_list =>OKC_API.G_FALSE,
                          x_return_status =>x_return_status,
                          x_msg_count     =>x_msg_count,
                          x_msg_data      =>x_msg_data,
                          p_cvmv_rec      =>p_cvmv_tbl(i),
                          x_cvmv_rec      =>x_cvmv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_cvmv_tbl.LAST);
         i := p_cvmv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END version_contract;
---------------------------------------------------------------------------------------

  PROCEDURE create_contract_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type) AS

    lr_cimv_rec_type_in            OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    lr_cimv_rec_type_out           OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_CREATE_K_ITEM';

    --vthiruva start, 15-Sep-2004
    --code changes to enable business events
    --cursor to fetch line style of sub line and parent line id.
     CURSOR lty_code_csr(p_line_id okc_k_lines_b.id%TYPE) IS
     SELECT lse.lty_code lty_code,
           lines.id fee_line_id
     FROM okc_line_styles_b lse,
         okc_k_lines_b subline,
         okc_k_lines_b lines
     WHERE subline.id = p_line_id
     AND lines.id = subline.cle_id
     AND lse.id = subline.lse_id;

     l_lty_code              okc_line_styles_b.lty_code%TYPE;
     l_parent_line_id        okc_k_lines_b.id%TYPE;
     l_parameter_list        wf_parameter_list_t;
     l_raise_business_event  VARCHAR2(1) := OKL_API.G_FALSE;
     l_business_event_name   WF_EVENTS.NAME%TYPE := NULL;
    --vthiruva end, 15-Sep-2004

  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared cimv record
    -- to OKC declared cimv record type as process of input
    migrate_okl_okc_item(p_cimv_rec,
                         lr_cimv_rec_type_in);
    -- Calling the actual OKC api

 -- smereddy,09/08/2005,Bug#4378699
    okl_context.set_okc_org_context(p_chr_id => lr_cimv_rec_type_in.dnz_chr_id);

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

             okl_la_validation_util_pvt.VALIDATE_STYLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count      => x_msg_count,
                                                          x_msg_data       => x_msg_data,
                                                          p_object_name    => lr_cimv_rec_type_in.jtot_object1_code,
                                                          p_id1            => lr_cimv_rec_type_in.object1_id1,
                                                          p_id2            => lr_cimv_rec_type_in.object1_id2);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

----  Changes End


    OKC_CONTRACT_ITEM_PUB.create_contract_item(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_cimv_rec      => lr_cimv_rec_type_in,
                                               x_cimv_rec      => lr_cimv_rec_type_out);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from OKC declared cimv record type
    -- to locally declared cimv record as process of input
    migrate_okc_okl_item(lr_cimv_rec_type_out,
                         x_cimv_rec);

    /*
    --vthiruva start, 15-Sep-2004
    --code changes to enable business events..
    --Added code to raise events for create fee by asset and
    --create serviced asset
    */
    --fetch the line style code and parent line id for the record
    OPEN lty_code_csr(p_cimv_rec.cle_id);
    FETCH lty_code_csr into l_lty_code, l_parent_line_id;
    CLOSE lty_code_csr;

    IF(l_lty_code = 'LINK_FEE_ASSET' AND
       okl_lla_util_pvt.is_lease_contract(p_cimv_rec.dnz_chr_id) = OKL_API.G_TRUE)THEN

       l_raise_business_event := OKL_API.G_TRUE;
       l_business_event_name  := G_WF_EVT_ASSET_FEE_CREATED;
 	   wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID,l_parent_line_id,l_parameter_list);

    ELSIF(l_lty_code = 'LINK_SERV_ASSET' AND
       okl_lla_util_pvt.is_lease_contract(p_cimv_rec.dnz_chr_id) = OKL_API.G_TRUE)THEN

       l_raise_business_event := OKL_API.G_TRUE;
       l_business_event_name  := G_WF_EVT_ASSET_SERV_FEE_CRTD;
 	   wf_event.AddParameterToList(G_WF_ITM_SERV_LINE_ID,l_parent_line_id,l_parameter_list);

    END IF;

    IF(l_raise_business_event = OKL_API.G_TRUE AND l_business_event_name IS NOT NULL)THEN
  	   wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_cimv_rec.dnz_chr_id,l_parameter_list);
  	   wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,p_cimv_rec.object1_id1,l_parameter_list);

	   raise_business_event(p_api_version      => p_api_version
                           ,p_init_msg_list    => p_init_msg_list
	                       ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data
                           ,p_event_name       => l_business_event_name
                           ,p_event_param_list => l_parameter_list);
    END IF;
    --vthiruva end, 15-Sep-2004

    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END create_contract_item;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE create_contract_item(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_cimv_tbl      IN  cimv_tbl_type,
    x_cimv_tbl      OUT NOCOPY  cimv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_CREATE_ITEM';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_cimv_tbl.COUNT>0) THEN
       i := p_cimv_tbl.FIRST;
       LOOP
         create_contract_item(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_cimv_rec      =>p_cimv_tbl(i),
                             x_cimv_rec      =>x_cimv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_cimv_tbl.LAST);
         i := p_cimv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END create_contract_item;
--------------------------------------------------------------------------------------------------

  PROCEDURE update_contract_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type) AS

    lr_cimv_rec_type_in            OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    lr_cimv_rec_type_out           OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_UPDATE_K_ITEM';

   -- smereddy,09/08/2005,Bug#4378699
    CURSOR l_dnz_chr_id_csr(p_id IN NUMBER)
    IS
    SELECT dnz_chr_id
    FROM   OKC_K_ITEMS_V
    WHERE  id = p_id;

    l_dnz_chr_id NUMBER;
    -- end,mvasudev,09/08/2005,Bug#4378699

  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared cimv record
    -- to OKC declared cimv record type as process of input
    migrate_okl_okc_item(p_cimv_rec,
                         lr_cimv_rec_type_in);

   -- smereddy,09/08/2005,Bug#4378699
    IF (lr_cimv_rec_type_in.dnz_chr_id IS NOT NULL OR
       lr_cimv_rec_type_in.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      l_dnz_chr_id := lr_cimv_rec_type_in.dnz_chr_id;
    ELSE
      FOR l_dnz_chr_id_rec IN l_dnz_chr_id_csr(p_cimv_rec.id)
      LOOP
       l_dnz_chr_id := l_dnz_chr_id_rec.dnz_chr_id;
      END LOOP;
    END IF;

    IF l_dnz_chr_id IS NOT NULL THEN
      okl_context.set_okc_org_context(p_chr_id => l_dnz_chr_id);
    ELSE
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
   -- smereddy,09/08/2005,Bug#4378699

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

          okl_la_validation_util_pvt.VALIDATE_STYLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count      => x_msg_count,
                                                          x_msg_data       => x_msg_data,
                                                          p_object_name    => lr_cimv_rec_type_in.jtot_object1_code,
                                                          p_id1            => lr_cimv_rec_type_in.object1_id1,
                                                          p_id2            => lr_cimv_rec_type_in.object1_id2);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
----  Changes End


    -- Calling the actual OKC api


    OKC_CONTRACT_ITEM_PUB.update_contract_item(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_cimv_rec      => lr_cimv_rec_type_in,
                                               x_cimv_rec      => lr_cimv_rec_type_out);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from OKC declared cimv record type
    -- to locally declared cimv record as process of input
    migrate_okc_okl_item(lr_cimv_rec_type_out,
                         x_cimv_rec);
    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END update_contract_item;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE update_contract_item(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_cimv_tbl      IN  cimv_tbl_type,
    x_cimv_tbl      OUT NOCOPY  cimv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_UPDATE_ITEM';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_cimv_tbl.COUNT>0) THEN
       i := p_cimv_tbl.FIRST;
       LOOP
         update_contract_item(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_cimv_rec      =>p_cimv_tbl(i),
                             x_cimv_rec      =>x_cimv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_cimv_tbl.LAST);
         i := p_cimv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END update_contract_item;
--------------------------------------------------------------------------------------------------
  PROCEDURE delete_contract_item(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_cimv_rec      IN  cimv_rec_type) AS

    lr_cimv_rec_type_in            OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_DELETE_K_ITEM';
  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared cimv record
    -- to OKC declared cimv record type as process of input
    migrate_okl_okc_item(p_cimv_rec,
                         lr_cimv_rec_type_in);
    -- Calling the actual OKC api
    OKC_CONTRACT_ITEM_PUB.delete_contract_item(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_cimv_rec      => lr_cimv_rec_type_in);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END delete_contract_item;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE delete_contract_item(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_cimv_tbl      IN  cimv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_DELETE_ITEM';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_cimv_tbl.COUNT>0) THEN
       i := p_cimv_tbl.FIRST;
       LOOP
         delete_contract_item(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_cimv_rec      =>p_cimv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_cimv_tbl.LAST);
         i := p_cimv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END delete_contract_item;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE create_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) AS

    lr_cplv_rec_type_in            OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    lr_cplv_rec_type_out           OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_CREATE_K_PARTY_ROLE';

    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE rle_code = p_rle_code
    AND     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

    /*
    -- mvasudev, 09/09/2004
    -- Code change to enable Business Event
    */
    l_parameter_list           wf_parameter_list_t;

  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared cplv record
    -- to OKC declared cplv record type as process of input
    migrate_okl_okc_party(p_cplv_rec,
                          lr_cplv_rec_type_in);
    -- Calling the actual OKC api

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lr_cplv_rec_type_in.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S')  THEN

           okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count      => x_msg_count,
                                                          x_msg_data       => x_msg_data,
                                                          p_object_name    => lr_cplv_rec_type_in.jtot_object1_code,
                                                          p_id1            => lr_cplv_rec_type_in.object1_id1,
                                                          p_id2            => lr_cplv_rec_type_in.object1_id2);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

     END IF;

----  Changes End



    OKC_CONTRACT_PARTY_PUB.create_k_party_role(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_cplv_rec      => lr_cplv_rec_type_in,
                                               x_cplv_rec      => lr_cplv_rec_type_out);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from OKC declared cplv record type
    -- to locally declared cplv record as process of input
    migrate_okc_okl_party(lr_cplv_rec_type_out,
                          x_cplv_rec);

     --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
     -- edit points for lease contract are any modifications between statuses
     -- 'PASSED' and 'APPROVED'
     IF (x_cplv_rec.dnz_chr_id IS NOT NULL) AND (x_cplv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => x_cplv_rec.dnz_chr_id);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

   /*
   -- mvasudev, 09/09/2004
   -- Code change to enable Business Event
   */
    IF (okl_lla_util_pvt.is_lease_contract(p_cplv_rec.dnz_chr_id) = OKL_API.G_TRUE) THEN
      wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_cplv_rec.dnz_chr_id,l_parameter_list);
      --vthiruva..04-jan-2004.. Modified to pass object1_id1 as party id and
      --added party_role_id to list of paramters passed to raise business event.
      wf_event.AddParameterToList(G_WF_ITM_PARTY_ID,p_cplv_rec.object1_id1,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_PARTY_ROLE_ID,x_cplv_rec.id,l_parameter_list);

	  raise_business_event(p_api_version      => p_api_version
                          ,p_init_msg_list    => p_init_msg_list
	                      ,x_return_status    => x_return_status
                          ,x_msg_count        => x_msg_count
                          ,x_msg_data         => x_msg_data
                          ,p_event_name       => G_WF_EVT_KHR_PARTY_CREATED
                          ,p_event_param_list => l_parameter_list);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

   /*
   -- mvasudev, 09/09/2004
   -- END, Code change to enable Business Event
   */

    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END create_k_party_role;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE create_k_party_role(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_cplv_tbl      IN  cplv_tbl_type,
    x_cplv_tbl      OUT NOCOPY  cplv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_CREATE_K_PARTY_ROLE';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_cplv_tbl.COUNT>0) THEN
       i := p_cplv_tbl.FIRST;
       LOOP
         create_k_party_role(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_cplv_rec      =>p_cplv_tbl(i),
                             x_cplv_rec      =>x_cplv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_cplv_tbl.LAST);
         i := p_cplv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END create_k_party_role;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE update_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) AS

    lr_cplv_rec_type_in            OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    lr_cplv_rec_type_out           OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_UPDATE_K_PARTY_ROLE';

    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE rle_code = p_rle_code
    AND     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared cplv record
    -- to OKC declared cplv record type as process of input
    migrate_okl_okc_party(p_cplv_rec,
                          lr_cplv_rec_type_in);

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lr_cplv_rec_type_in.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S')  THEN


           okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count      => x_msg_count,
                                                          x_msg_data       => x_msg_data,
                                                          p_object_name    => lr_cplv_rec_type_in.jtot_object1_code,
                                                          p_id1            => lr_cplv_rec_type_in.object1_id1,
                                                          p_id2            => lr_cplv_rec_type_in.object1_id2);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

     END IF;

----  Changes End


    -- Calling the actual OKC api


    OKC_CONTRACT_PARTY_PUB.update_k_party_role(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_cplv_rec      => lr_cplv_rec_type_in,
                                               x_cplv_rec      => lr_cplv_rec_type_out);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from OKC declared cplv record type
    -- to locally declared cplv record as process of input
    migrate_okc_okl_party(lr_cplv_rec_type_out,
                          x_cplv_rec);

     --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
     -- edit points for lease contract are any modifications between statuses
     -- 'PASSED' and 'APPROVED'
     --output will not be created with null dnz_chr_id
     IF (x_cplv_rec.dnz_chr_id IS NOT NULL) AND (x_cplv_rec.dnz_chr_id  <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => x_cplv_rec.dnz_chr_id);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END update_k_party_role;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE update_k_party_role(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_cplv_tbl      IN  cplv_tbl_type,
    x_cplv_tbl      OUT NOCOPY  cplv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_UPDATE_K_PARTY_ROLE';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_cplv_tbl.COUNT>0) THEN
       i := p_cplv_tbl.FIRST;
       LOOP
         update_k_party_role(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_cplv_rec      =>p_cplv_tbl(i),
                             x_cplv_rec      =>x_cplv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_cplv_tbl.LAST);
         i := p_cplv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END update_k_party_role;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE delete_k_party_role(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_cplv_rec      IN  cplv_rec_type) AS

    lr_cplv_rec_type_in            OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_DELETE_K_PARTY_ROLE';

    --cursor to find out chr id required to flip status at edit point
    CURSOR chr_id_crs (p_cpl_id IN NUMBER) IS
    SELECT DNZ_CHR_ID
    FROM   OKC_K_PARTY_ROLES_B
    WHERE  ID = P_CPL_ID;

    l_dnz_chr_id   OKC_K_PARTY_ROLES_B.dnz_chr_id%TYPE;



  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

      --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
     -- edit points for lease contract are any modifications between statuses
     -- 'PASSED' and 'APPROVED'

     IF (p_cplv_rec.dnz_chr_id IS NULL) OR (p_cplv_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
         OPEN chr_id_crs(p_cpl_id => p_cplv_rec.id);
         FETCH chr_id_crs INTO l_dnz_chr_id;
         IF chr_id_crs%NOTFOUND THEN
            NULL; --this error should have been trapped earlier (party not attached to chr)
         END IF;
         CLOSE chr_id_crs;
     ELSE
         l_dnz_chr_id := p_cplv_rec.dnz_chr_id;
     END IF;

     IF (l_dnz_chr_id IS NOT NULL AND l_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => l_dnz_chr_id);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared cplv record
    -- to OKC declared cplv record type as process of input
    migrate_okl_okc_party(p_cplv_rec,
                          lr_cplv_rec_type_in);
    -- Calling the actual OKC api
    OKC_CONTRACT_PARTY_PUB.delete_k_party_role(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_cplv_rec      => lr_cplv_rec_type_in);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END delete_k_party_role;
-------------------------------------------------------------------------------------------------------
  PROCEDURE delete_k_party_role(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_cplv_tbl      IN  cplv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_DELETE_K_PARTY_ROLE';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_cplv_tbl.COUNT>0) THEN
       i := p_cplv_tbl.FIRST;
       LOOP
         delete_k_party_role(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_cplv_rec      =>p_cplv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_cplv_tbl.LAST);
         i := p_cplv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END delete_k_party_role;

--------------------------------------------------------------------------------------------------------------
  PROCEDURE create_contact(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_ctcv_rec      IN  ctcv_rec_type,
    x_ctcv_rec      OUT NOCOPY  ctcv_rec_type) AS

    lr_ctcv_rec_type_in            OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
    lr_ctcv_rec_type_out           OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_CREATE_CONTACT';

    CURSOR contact_csr(p_cro_code VARCHAR2, p_cpl_id NUMBER)  IS
    SELECT  access_level
    FROM    OKC_CONTACT_SOURCES a, okc_k_party_roles_b b
    WHERE  a.cro_code = p_cro_code
    AND    b.id       = p_cpl_id
    AND    a.rle_code = b.rle_code
    AND    a.buy_or_sell = 'S';

    l_access_level OKC_CONTACT_SOURCES.access_level%TYPE;


  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared ctcv record
    -- to OKC declared ctcv record type as process of input
    migrate_okl_okc_contact(p_ctcv_rec,
                          lr_ctcv_rec_type_in);
    -- Calling the actual OKC api

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN contact_csr(lr_ctcv_rec_type_in.cro_code, lr_ctcv_rec_type_in.cpl_id);
     FETCH contact_csr INTO l_access_level;
     CLOSE contact_csr;

     IF (l_access_level = 'S')  THEN

        okl_la_validation_util_pvt.VALIDATE_CONTACT_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count      => x_msg_count,
                                                          x_msg_data       => x_msg_data,
                                                          p_object_name    => lr_ctcv_rec_type_in.jtot_object1_code,
                                                          p_id1            => lr_ctcv_rec_type_in.object1_id1,
                                                          p_id2            => lr_ctcv_rec_type_in.object1_id2);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

----  Changes End


    OKC_CONTRACT_PARTY_PUB.create_contact(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_ctcv_rec      => lr_ctcv_rec_type_in,
                                          x_ctcv_rec      => lr_ctcv_rec_type_out);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from OKC declared ctcv record type
    -- to locally declared ctcv record as process of input
    migrate_okc_okl_contact(lr_ctcv_rec_type_out,
                          x_ctcv_rec);

     --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
     -- edit points for lease contract are any modifications between statuses
     -- 'PASSED' and 'APPROVED'
    IF (x_ctcv_rec.dnz_chr_id IS NOT NULL) AND (x_ctcv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => x_ctcv_rec.dnz_chr_id);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END create_contact;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE create_contact(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_ctcv_tbl      IN  ctcv_tbl_type,
    x_ctcv_tbl      OUT NOCOPY  ctcv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_CREATE_CONTACT';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_ctcv_tbl.COUNT>0) THEN
       i := p_ctcv_tbl.FIRST;
       LOOP
         create_contact(p_api_version   =>p_api_version,
                        p_init_msg_list =>OKC_API.G_FALSE,
                        x_return_status =>x_return_status,
                        x_msg_count     =>x_msg_count,
                        x_msg_data      =>x_msg_data,
                        p_ctcv_rec      =>p_ctcv_tbl(i),
                        x_ctcv_rec      =>x_ctcv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_ctcv_tbl.LAST);
         i := p_ctcv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END create_contact;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE update_contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_rec                     IN ctcv_rec_type,
    x_ctcv_rec                     OUT NOCOPY ctcv_rec_type) AS

    lr_ctcv_rec_type_in            OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
    lr_ctcv_rec_type_out           OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_UPDATE_CONTACT';

    CURSOR contact_csr(p_cro_code VARCHAR2, p_cpl_id NUMBER)  IS
    SELECT  access_level
    FROM    OKC_CONTACT_SOURCES a, okc_k_party_roles_b b
    WHERE  a.cro_code = p_cro_code
    AND    b.id       = p_cpl_id
    AND    a.rle_code = b.rle_code
    AND    a.buy_or_sell = 'S';


    l_access_level OKC_CONTACT_SOURCES.access_level%TYPE;


  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared ctcv record
    -- to OKC declared ctcv record type as process of input
    migrate_okl_okc_contact(p_ctcv_rec,
                          lr_ctcv_rec_type_in);

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN contact_csr(lr_ctcv_rec_type_in.cro_code, lr_ctcv_rec_type_in.cpl_id);
     FETCH contact_csr INTO l_access_level;
     CLOSE contact_csr;

     IF (l_access_level = 'S') THEN

        okl_la_validation_util_pvt.VALIDATE_CONTACT_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count      => x_msg_count,
                                                          x_msg_data       => x_msg_data,
                                                          p_object_name    => lr_ctcv_rec_type_in.jtot_object1_code,
                                                          p_id1            => lr_ctcv_rec_type_in.object1_id1,
                                                          p_id2            => lr_ctcv_rec_type_in.object1_id2);
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

----  Changes End


    -- Calling the actual OKC api
    OKC_CONTRACT_PARTY_PUB.update_contact(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_ctcv_rec      => lr_ctcv_rec_type_in,
                                          x_ctcv_rec      => lr_ctcv_rec_type_out);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from OKC declared ctcv record type
    -- to locally declared ctcv record as process of input
    migrate_okc_okl_contact(lr_ctcv_rec_type_out,
                          x_ctcv_rec);

    --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
    -- edit points for lease contract are any modifications between statuses
    -- 'PASSED' and 'APPROVED'
        IF (x_ctcv_rec.dnz_chr_id IS NOT NULL) AND (x_ctcv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => x_ctcv_rec.dnz_chr_id);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END update_contact;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE update_contact(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_ctcv_tbl      IN  ctcv_tbl_type,
    x_ctcv_tbl      OUT NOCOPY  ctcv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_UPDATE_CONTACT';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_ctcv_tbl.COUNT>0) THEN
       i := p_ctcv_tbl.FIRST;
       LOOP
         update_contact(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_ctcv_rec      =>p_ctcv_tbl(i),
                             x_ctcv_rec      =>x_ctcv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_ctcv_tbl.LAST);
         i := p_ctcv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END update_contact;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE delete_contact(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_ctcv_rec      IN  ctcv_rec_type) AS

    lr_ctcv_rec_type_in            OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_DELETE_CONTACT';

    --cursor to find out chr id required to flip status at edit point
    CURSOR chr_id_crs (p_ctc_id IN NUMBER) IS
    SELECT DNZ_CHR_ID
    FROM   OKC_CONTACTS
    WHERE  ID = P_CTC_ID;

    l_dnz_chr_id   OKC_CONTACTS.dnz_chr_id%TYPE;

  BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

     --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
     -- edit points for lease contract are any modifications between statuses
     -- 'PASSED' and 'APPROVED'

     IF (p_ctcv_rec.dnz_chr_id IS NULL) OR (p_ctcv_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
         OPEN chr_id_crs(p_ctc_id => p_ctcv_rec.id);
         FETCH chr_id_crs INTO l_dnz_chr_id;
         IF chr_id_crs%NOTFOUND THEN
            NULL; --this error should have been trapped earlier (party not attached to chr)
         END IF;
         CLOSE chr_id_crs;
     ELSE
         l_dnz_chr_id := p_ctcv_rec.dnz_chr_id;
     END IF;

     IF (l_dnz_chr_id IS NOT NULL) AND (l_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => l_dnz_chr_id);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

    -- Since we are creatieng a wrapper over the okc
    -- we need to migrate from locally declared ctcv record
    -- to OKC declared ctcv record type as process of input
    migrate_okl_okc_contact(p_ctcv_rec,
                          lr_ctcv_rec_type_in);
    -- Calling the actual OKC api
    OKC_CONTRACT_PARTY_PUB.delete_contact(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_ctcv_rec      => lr_ctcv_rec_type_in);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END delete_contact;
-------------------------------------------------------------------------------------------------------
  PROCEDURE delete_contact(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_ctcv_tbl      IN  ctcv_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_DELETE_CONTACT';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_ctcv_tbl.COUNT>0) THEN
       i := p_ctcv_tbl.FIRST;
       LOOP
         delete_contact(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_ctcv_rec      =>p_ctcv_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_ctcv_tbl.LAST);
         i := p_ctcv_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END delete_contact;

---------------------------------------------------------------------------------------------------------
-- Badri
  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY  chrv_rec_type) IS

    l_chrv_rec         chrv_rec_type;
    l_okc_chrv_rec_in  okc_contract_pub.chrv_rec_type;
    l_okc_chrv_rec_out okc_contract_pub.chrv_rec_type;

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_chrv_rec := p_chrv_rec;
    -- call procedure in complex API

    migrate_chrv(p_from => l_chrv_rec,
                 p_to   => l_okc_chrv_rec_in);

    OKC_CONTRACT_PUB.create_contract_header(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_rec        => l_okc_chrv_rec_in,
      x_chrv_rec        => l_okc_chrv_rec_out);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_chrv(p_from => l_okc_chrv_rec_out,
                 p_to   => x_chrv_rec);

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

END create_contract_header;


PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY chrv_rec_type) IS

    l_chrv_rec      chrv_rec_type;
    l_okc_chrv_rec_in  okc_contract_pub.chrv_rec_type;
    l_okc_chrv_rec_out okc_contract_pub.chrv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_chrv_rec := p_chrv_rec;

    migrate_chrv(p_from => l_chrv_rec,
                 p_to   => l_okc_chrv_rec_in);


    -- call procedure in complex API
    OKC_CONTRACT_PUB.update_contract_header(
     p_api_version          => p_api_version,
     p_init_msg_list        => p_init_msg_list,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
     p_restricted_update    => p_restricted_update,
      p_chrv_rec            => l_okc_chrv_rec_in,
      x_chrv_rec            => l_okc_chrv_rec_out);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_chrv(p_from => l_okc_chrv_rec_out,
                 p_to   => x_chrv_rec);

        -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_contract_header;


  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type) IS

    l_chrv_rec      chrv_rec_type;
     l_okc_chrv_rec_in  okc_contract_pub.chrv_rec_type;
    l_okc_chrv_rec_out okc_contract_pub.chrv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_chrv_rec := p_chrv_rec;

    migrate_chrv(p_from => l_chrv_rec,
                 p_to   => l_okc_chrv_rec_in);

    -- call procedure in complex API
    OKC_CONTRACT_PUB.delete_contract_header(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
     x_return_status    => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_rec        => l_okc_chrv_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END delete_contract_header;


  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type) IS

    l_chrv_rec      chrv_rec_type;
    l_okc_chrv_rec_in  okc_contract_pub.chrv_rec_type;
    l_okc_chrv_rec_out okc_contract_pub.chrv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_HEADER';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_chrv_rec := p_chrv_rec;

    migrate_chrv(p_from => l_chrv_rec,
                 p_to   => l_okc_chrv_rec_in);
       -- call procedure in complex API
    OKC_CONTRACT_PUB.lock_contract_header(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
     x_return_status    => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_rec        => l_okc_chrv_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END lock_contract_header;

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type) IS

    l_chrv_rec      chrv_rec_type;
    l_okc_chrv_rec_in  okc_contract_pub.chrv_rec_type;
    l_okc_chrv_rec_out okc_contract_pub.chrv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_HEADER';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_chrv_rec := p_chrv_rec;
    migrate_chrv(p_from => l_chrv_rec,
                 p_to   => l_okc_chrv_rec_in);

    -- call procedure in complex API
    OKC_CONTRACT_PUB.validate_contract_header(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_rec        => l_okc_chrv_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END validate_contract_header;


  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT 'F',
    p_clev_rec                     IN  clev_rec_type,
    x_clev_rec                     OUT NOCOPY  clev_rec_type) IS

    l_clev_rec      clev_rec_type;
    l_okc_clev_rec_in  okc_contract_pub.clev_rec_type;
    l_okc_clev_rec_out okc_contract_pub.clev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_clev_rec := p_clev_rec;
    migrate_clev(p_from => l_clev_rec,
                 p_to   => l_okc_clev_rec_in);
    -- call procedure in complex API
    OKC_CONTRACT_PUB.create_contract_line(
                     p_api_version        => p_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     x_return_status      => x_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     p_restricted_update  => p_restricted_update,
                     p_clev_rec       => l_okc_clev_rec_in,
                     x_clev_rec       => l_okc_clev_rec_out);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_clev(p_from => l_okc_clev_rec_out,
                 p_to    => x_clev_rec);

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END create_contract_line;

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update         IN VARCHAR2 DEFAULT 'F',
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_CREATE_LINE';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_clev_tbl.COUNT>0) THEN
       i := p_clev_tbl.FIRST;
       LOOP
         create_contract_line(p_api_version      => p_api_version,
                             p_init_msg_list     => OKC_API.G_FALSE,
                             x_return_status     => x_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data,
                             p_restricted_update => p_restricted_update,
                             p_clev_rec          =>p_clev_tbl(i),
                             x_clev_rec          =>x_clev_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_clev_tbl.LAST);
         i := p_clev_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END create_contract_line;

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_rec                     IN  clev_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type) IS

    l_clev_rec      clev_rec_type;
    l_okc_clev_rec_in  okc_contract_pub.clev_rec_type;
    l_okc_clev_rec_out okc_contract_pub.clev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_clev_rec := p_clev_rec;
    migrate_clev(p_from => l_clev_rec,
                 p_to   => l_okc_clev_rec_in);


    -- call procedure in complex API
    OKC_CONTRACT_PUB.update_contract_line(
     p_api_version          => p_api_version,
     p_init_msg_list        => p_init_msg_list,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
     p_restricted_update    => p_restricted_update,
      p_clev_rec            => l_okc_clev_rec_in,
      x_clev_rec            => l_okc_clev_rec_out);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_clev(p_from => l_okc_clev_rec_out,
                 p_to   => x_clev_rec);
    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_contract_line;

    PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_UPDATE_LINE';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_clev_tbl.COUNT>0) THEN
       i := p_clev_tbl.FIRST;
       LOOP
         update_contract_line(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_restricted_update =>p_restricted_update,
                             p_clev_rec      =>p_clev_tbl(i),
                             x_clev_rec      =>x_clev_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_clev_tbl.LAST);
         i := p_clev_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END update_contract_line;


  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type) IS

    l_clev_rec      clev_rec_type;
    l_okc_clev_rec_in  okc_contract_pub.clev_rec_type;
    l_okc_clev_rec_out okc_contract_pub.clev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_clev_rec := p_clev_rec;
    migrate_clev(p_from => l_clev_rec,
                 p_to   => l_okc_clev_rec_in);


    -- call procedure in complex API
    OKC_CONTRACT_PUB.delete_contract_line(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_rec        => l_okc_clev_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


        -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END delete_contract_line;

PROCEDURE delete_contract_line(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_clev_tbl      IN  clev_tbl_type) AS

    l_api_name            CONSTANT VARCHAR2(30) := 'OKL_DELETE_LINE';
    i                              NUMBER := 0;
  BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     IF (p_clev_tbl.COUNT>0) THEN
       i := p_clev_tbl.FIRST;
       LOOP
         delete_contract_line(p_api_version   =>p_api_version,
                             p_init_msg_list =>OKC_API.G_FALSE,
                             x_return_status =>x_return_status,
                             x_msg_count     =>x_msg_count,
                             x_msg_data      =>x_msg_data,
                             p_clev_rec      =>p_clev_tbl(i));
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKC_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i=p_clev_tbl.LAST);
         i := p_clev_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   END delete_contract_line;


  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type) IS

    l_clev_rec      clev_rec_type;
    l_okc_clev_rec_in OKC_CONTRACT_PUB.clev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_LINE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_clev_rec := p_clev_rec;
    migrate_clev(p_from => l_clev_rec,
                 p_to   => l_okc_clev_rec_in);
    -- call procedure in complex API
    OKC_CONTRACT_PUB.lock_contract_line(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_rec        => l_okc_clev_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

      -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END lock_contract_line;


  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type) IS

    l_clev_rec      clev_rec_type;
    l_okc_clev_rec_in okc_contract_pub.clev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_LINE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_clev_rec := p_clev_rec;
    migrate_clev(p_from => l_clev_rec,
                 p_to   => l_okc_clev_rec_in);

    -- call procedure in complex API
    OKC_CONTRACT_PUB.validate_contract_line(
      p_api_version     => p_api_version,
      p_init_msg_list   => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_rec        => l_okc_clev_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END validate_contract_line;

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type) IS

    l_gvev_rec      gvev_rec_type;
    l_okc_gvev_rec_in  okc_contract_pub.gvev_rec_type;
    l_okc_gvev_rec_out okc_contract_pub.gvev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_GOVERNANCE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_gvev_rec := p_gvev_rec;
    migrate_gvev(p_from => l_gvev_rec,
                 p_to   => l_okc_gvev_rec_in);

    -- call procedure in complex API
    OKC_CONTRACT_PUB.create_governance(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec        => l_okc_gvev_rec_in,
      x_gvev_rec        => l_okc_gvev_rec_out);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_gvev(p_from => l_okc_gvev_rec_out,
                 p_to   => x_gvev_rec);

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END create_governance;

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type) IS

    l_gvev_rec      gvev_rec_type;
    l_okc_gvev_rec_in  okc_contract_pub.gvev_rec_type;
    l_okc_gvev_rec_out okc_contract_pub.gvev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_GOVERNANCE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_gvev_rec := p_gvev_rec;

     migrate_gvev(p_from => l_gvev_rec,
                 p_to   => l_okc_gvev_rec_in);

    -- call procedure in complex API
    OKC_CONTRACT_PUB.update_governance(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec        => l_okc_gvev_rec_in,
      x_gvev_rec        => l_okc_gvev_rec_out);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_gvev(p_from => l_okc_gvev_rec_out,
                 p_to   => x_gvev_rec);

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_governance;


  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type) IS

    l_gvev_rec      gvev_rec_type;
    l_okc_gvev_rec_in  okc_contract_pub.gvev_rec_type;
    l_okc_gvev_rec_out okc_contract_pub.gvev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_GOVERNANCE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_gvev_rec := p_gvev_rec;
    migrate_gvev(p_from => l_gvev_rec,
                 p_to   => l_okc_gvev_rec_in);

    -- call procedure in complex API
    OKC_CONTRACT_PUB.delete_governance(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec        => l_okc_gvev_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


        -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END delete_governance;


  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type) IS

    l_gvev_rec      gvev_rec_type;
    l_okc_gvev_rec_in  okc_contract_pub.gvev_rec_type;
    l_okc_gvev_rec_out okc_contract_pub.gvev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'LOCK_GOVERNANCE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_gvev_rec := p_gvev_rec;
    migrate_gvev(p_from => l_gvev_rec,
                 p_to   => l_okc_gvev_rec_in);
    -- call procedure in complex API
    OKC_CONTRACT_PUB.lock_governance(
      p_api_version     => p_api_version,
      p_init_msg_list   => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec        => l_okc_gvev_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END lock_governance;


  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type) IS

    l_gvev_rec      gvev_rec_type;
    l_okc_gvev_rec_in  okc_contract_pub.gvev_rec_type;
    l_okc_gvev_rec_out okc_contract_pub.gvev_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'VALIDATE_GOVERNANCE';
    l_api_version   CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(1)       := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                    p_api_name      => l_api_name,
                    p_pkg_name      => g_pkg_name,
                    p_init_msg_list => p_init_msg_list,
                    l_api_version   => l_api_version,
                    p_api_version   => p_api_version,
                    p_api_type      => g_api_type,
                    x_return_status => x_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_gvev_rec := p_gvev_rec;
    migrate_gvev(p_from => l_gvev_rec,
                 p_to   => l_okc_gvev_rec_in);

    -- call procedure in complex API
    OKC_CONTRACT_PUB.validate_governance(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec        => l_okc_gvev_rec_in);

    -- check return status
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- end activity
    OKC_API.END_ACTIVITY(   x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END validate_governance;

PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;

    l_okc_rgpv_rec_in                  OKC_RULE_PUB.rgpv_rec_type;
    l_okc_rgpv_rec_out                 OKC_RULE_PUB.rgpv_rec_type;

    -- sjalasut. added local variables and cursors to enable business events
    -- when called from contracts open interface. start

    CURSOR is_batch_process IS
    SELECT FND_GLOBAL.conc_request_id
      FROM dual;

    CURSOR get_line_style (p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT lty_code
      FROM okc_k_lines_b line,
           okc_line_styles_b style
     WHERE line.lse_id = style.id
       AND line.id = p_line_id;

    l_line_style okc_line_styles_b.lty_code%TYPE;

    CURSOR get_serv_chr_from_serv(p_chr_id okc_k_headers_b.id%TYPE,
                                  p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT rlobj.object1_id1
      FROM okc_k_rel_objs_v rlobj
     WHERE rlobj.chr_id = p_chr_id
       AND rlobj.cle_id = p_line_id
       AND rlobj.rty_code = 'OKLSRV'
       AND rlobj.jtot_object1_code = 'OKL_SERVICE_LINE';

    l_service_top_line_id okc_k_lines_b.id%TYPE;

    CURSOR get_serv_cle_from_serv (p_serv_top_line_id okc_k_lines_b.id%TYPE) IS
    SELECT dnz_chr_id
      FROM okc_k_lines_b
     WHERE id = p_serv_top_line_id;

    l_serv_contract_id okc_k_headers_b.id%TYPE;

    l_process_type VARCHAR2(20);
    l_request_id NUMBER := -1;
    l_parameter_list wf_parameter_list_t;
    l_raise_business_event VARCHAR2(1) := OKL_API.G_FALSE;
    l_business_event_name wf_events.name%TYPE;

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rgpv(p_from => l_rgpv_rec,
              p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.create_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_okc_rgpv_rec_in,
      x_rgpv_rec      => l_okc_rgpv_rec_out);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     migrate_rgpv(p_from => l_okc_rgpv_rec_out, p_to => x_rgpv_rec);

     -- sjalasut: 15 sep 04, added code to enable business events only
     -- when this code is called from the open interface. if the open interface program is run
     -- and the profile to enable business events is set for batch program, then the following
     -- code fires.
     OPEN is_batch_process; FETCH is_batch_process INTO l_request_id; CLOSE is_batch_process;
     IF(l_request_id <> -1)THEN
       -- if the dnz_chr_id and chr_id are not null and the cle_id is null then rule group is being created
       -- for a contract. if the cle_id is not null and the chr_id is null then the rule group is being
       -- created for a line
       IF(l_rgpv_rec.dnz_chr_id IS NOT NULL AND l_rgpv_rec.chr_id IS NOT NULL AND l_rgpv_rec.cle_id IS NULL)THEN
         l_process_type := 'HEADER';
       ELSIF(l_rgpv_rec.chr_id IS NULL AND l_rgpv_rec.cle_id IS NOT NULL AND l_rgpv_rec.dnz_chr_id IS NOT NULL)THEN
         l_process_type := 'LINE';
       END IF;
       IF(l_process_type IS NOT NULL AND l_process_type = 'HEADER')THEN
         IF(l_rgpv_rec.rgd_code = 'LAAFLG')THEN
           -- raise business event for the Liens and Title for Terms and Conditions for the Contract
           -- set raise business event flag to true
           l_raise_business_event := OKL_API.G_TRUE;
           -- set the event name to be raised. this event name will vary for each rule group
           l_business_event_name := G_WF_EVT_CONTRACT_TERM_UPDATED;
           wf_event.AddParameterToList(G_WF_ITM_TERMS_ID,  x_rgpv_rec.id, l_parameter_list);
         END IF;
       ELSIF(l_process_type IS NOT NULL AND l_process_type = 'LINE')THEN
         IF(l_rgpv_rec.rgd_code = 'LAAFLG')THEN
           -- raise business event for Liens Title and Registration for the Assets
           -- set raise business event flag to true
           l_raise_business_event := OKL_API.G_TRUE;
           -- set the event name to be raised. this event name will vary for each rule group
           l_business_event_name := G_WF_EVT_ASSET_FILING_UPDATED;
           wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, l_rgpv_rec.cle_id, l_parameter_list);
         ELSIF(l_rgpv_rec.rgd_code = 'LAASTX')THEN
           -- raise business event for tax, property tax updated.
           l_raise_business_event := OKL_API.G_TRUE;
           l_business_event_name := G_WF_EVT_ASSET_PROPTAX_UPDATED;
           wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, l_rgpv_rec.cle_id, l_parameter_list);
         ELSIF(l_rgpv_rec.rgd_code = 'LAPSTH')THEN
           OPEN get_line_style(l_rgpv_rec.cle_id);
           FETCH get_line_style INTO l_line_style;
           CLOSE get_line_style;
           -- raise business event for service line update passthru
           IF(l_line_style IS NOT NULL AND l_line_style = 'SOLD_SERVICE')THEN
             l_raise_business_event := OKL_API.G_TRUE;
             l_business_event_name := G_WF_EVT_SERV_PASS_UPDATED;
             wf_event.AddParameterToList(G_WF_ITM_SERV_LINE_ID, l_rgpv_rec.cle_id, l_parameter_list);
             -- check if the service line in context has a service contract associated with it
             -- if so, pass the service contract id and service contract line id as parameters
             -- is this valid for contract open interface ?
             OPEN get_serv_chr_from_serv(l_rgpv_rec.dnz_chr_id, l_rgpv_rec.cle_id);
             FETCH get_serv_chr_from_serv INTO l_service_top_line_id;
             CLOSE get_serv_chr_from_serv;
             IF(l_service_top_line_id IS NOT NULL)THEN
               OPEN get_serv_cle_from_serv(l_service_top_line_id);
               FETCH get_serv_cle_from_serv INTO l_serv_contract_id;
               CLOSE get_serv_cle_from_serv;
               wf_event.AddParameterToList(G_WF_ITM_SERV_CHR_ID, l_serv_contract_id, l_parameter_list);
               wf_event.AddParameterToList(G_WF_ITM_SERV_CLE_ID, l_service_top_line_id, l_parameter_list);
             END IF;
           -- raise the business event for update passthrough for Fee Line
           ELSIF(l_line_style IS NOT NULL AND l_line_style = 'FEE')THEN
             l_raise_business_event := OKL_API.G_TRUE;
             l_business_event_name := G_WF_EVT_FEE_PASS_UPDATED;
             wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID, l_rgpv_rec.cle_id, l_parameter_list);
           END IF;
         ELSIF(l_rgpv_rec.rgd_code = 'LAFEXP')THEN
           OPEN get_line_style(l_rgpv_rec.cle_id);
           FETCH get_line_style INTO l_line_style;
           CLOSE get_line_style;
           -- raise business event for service line update expense
           IF(l_line_style IS NOT NULL AND l_line_style = 'SOLD_SERVICE')THEN
             l_raise_business_event := OKL_API.G_TRUE;
             l_business_event_name := G_WF_EVT_SERV_FEXP_UPDATED;
             wf_event.AddParameterToList(G_WF_ITM_SERV_LINE_ID, l_rgpv_rec.cle_id, l_parameter_list);
             -- check if the service line in context has a service contract associated with it
             -- if so, pass the service contract id and service contract line id as parameters
             OPEN get_serv_chr_from_serv(l_rgpv_rec.dnz_chr_id, l_rgpv_rec.cle_id);
             FETCH get_serv_chr_from_serv INTO l_service_top_line_id;
             CLOSE get_serv_chr_from_serv;
             IF(l_service_top_line_id IS NOT NULL)THEN
               OPEN get_serv_cle_from_serv(l_service_top_line_id);
               FETCH get_serv_cle_from_serv INTO l_serv_contract_id;
               CLOSE get_serv_cle_from_serv;
               wf_event.AddParameterToList(G_WF_ITM_SERV_CHR_ID, l_serv_contract_id, l_parameter_list);
               wf_event.AddParameterToList(G_WF_ITM_SERV_CLE_ID, l_service_top_line_id, l_parameter_list);
             END IF;
           ELSIF(l_line_style IS NOT NULL AND l_line_style = 'FEE')THEN
             l_raise_business_event := OKL_API.G_TRUE;
             l_business_event_name := G_WF_EVT_FEE_EXP_UPDATED;
             wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID, l_rgpv_rec.cle_id, l_parameter_list);
           END IF; -- end if for l_line_style is not null
         END IF; -- end if for rgd_code
       END IF; -- end if for l_process_type
       -- check if the business event needs to be raised
       IF(l_raise_business_event = OKL_API.G_TRUE AND l_business_event_name IS NOT NULL AND
          OKL_LLA_UTIL_PVT.is_lease_contract(l_rgpv_rec.dnz_chr_id)= OKL_API.G_TRUE)THEN
         -- since contract id is called as 'CONTRACT_ID'  for all the above events, it is being
         -- added to the parameter list here, than duplicating it in all the above if conditions
         wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID, l_rgpv_rec.dnz_chr_id, l_parameter_list);
         raise_business_event(p_api_version     => p_api_version,
                              p_init_msg_list   => p_init_msg_list,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_event_name      => l_business_event_name,
                              p_event_param_list => l_parameter_list
                             );
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;

     END IF; -- end if for request id

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END;

PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;

    l_okc_rgpv_rec_in                  OKC_RULE_PUB.rgpv_rec_type;
    l_okc_rgpv_rec_out                 OKC_RULE_PUB.rgpv_rec_type;

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rgpv(p_from => l_rgpv_rec,
              p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.update_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_okc_rgpv_rec_in,
      x_rgpv_rec      => l_okc_rgpv_rec_out);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     migrate_rgpv(p_from => l_okc_rgpv_rec_out,
                 p_to   => x_rgpv_rec);

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
END;


  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delet_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;

    l_okc_rgpv_rec_in                  OKC_RULE_PUB.rgpv_rec_type;

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rgpv(p_from => l_rgpv_rec,
              p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.delete_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_okc_rgpv_rec_in);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
END;


  PROCEDURE lock_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;

    l_okc_rgpv_rec_in              OKC_RULE_PUB.rgpv_rec_type;

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rgpv(p_from => l_rgpv_rec,
              p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.lock_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_okc_rgpv_rec_in);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
END;

  PROCEDURE validate_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;

    l_okc_rgpv_rec_in              OKC_RULE_PUB.rgpv_rec_type;
    l_okc_rgpv_rec_out             OKC_RULE_PUB.rgpv_rec_type;

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rgpv(p_from => l_rgpv_rec,
              p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.validate_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_okc_rgpv_rec_in);


     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
END;



  PROCEDURE create_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_okc_rmpv_rec_in  okc_rule_pub.rmpv_rec_type;
    l_okc_rmpv_rec_out okc_rule_pub.rmpv_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rmpv(p_from => l_rmpv_rec,
                p_to   => l_okc_rmpv_rec_in);

    OKC_RULE_PUB.create_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => l_okc_rmpv_rec_in,
      x_rmpv_rec      => l_okc_rmpv_rec_out);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     migrate_rmpv(p_from => l_okc_rmpv_rec_out,
                 p_to   => x_rmpv_rec);

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_rg_mode_pty_role;


  PROCEDURE update_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_okc_rmpv_rec_in  okc_rule_pub.rmpv_rec_type;
    l_okc_rmpv_rec_out okc_rule_pub.rmpv_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rmpv(p_from => l_rmpv_rec,
                 p_to   => l_okc_rmpv_rec_in);


    OKC_RULE_PUB.update_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => l_okc_rmpv_rec_in,
      x_rmpv_rec      => l_okc_rmpv_rec_in);


     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     migrate_rmpv(p_from => l_okc_rmpv_rec_out,
                    p_to   => x_rmpv_rec);

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_rg_mode_pty_role;

  PROCEDURE delete_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_okc_rmpv_rec_in  okc_rule_pub.rmpv_rec_type;

  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rmpv(p_from => l_rmpv_rec,
                p_to   => l_okc_rmpv_rec_in);


    OKC_RULE_PUB.delete_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => l_okc_rmpv_rec_in);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_rg_mode_pty_role;

  PROCEDURE lock_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_okc_rmpv_rec_in  okc_rule_pub.rmpv_rec_type;


  BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rmpv(p_from => l_rmpv_rec,
                p_to   => l_okc_rmpv_rec_in);

    OKC_RULE_PUB.lock_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => l_okc_rmpv_rec_in);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END lock_rg_mode_pty_role;


  PROCEDURE validate_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type)IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
    l_okc_rmpv_rec_in              okc_rule_pub.rmpv_rec_type;

  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate_rmpv(p_from => l_rmpv_rec,
                p_to   => l_okc_rmpv_rec_in);

    OKC_RULE_PUB.validate_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => l_okc_rmpv_rec_in);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_rg_mode_pty_role;
END OKL_OKC_MIGRATION_PVT;

/
