--------------------------------------------------------
--  DDL for Package Body OKE_IMPORT_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_IMPORT_CONTRACT_PUB" AS
/* $Header: OKEPIMPB.pls 120.2 2006/03/06 15:29:12 ausmani noship $ */
    g_api_type		CONSTANT VARCHAR2(4) := '_PUB';



-- GLOBAL MESSAGE CONSTANTS

  G_FND_APP			CONSTANT VARCHAR2(200) := OKE_API.G_FND_APP;

  G_FORM_UNABLE_TO_RESERVE_REC 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_DELETED;

  G_FORM_RECORD_CHANGED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_CHANGED;

  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKE_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;

  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKE_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';

  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_VIEW		 CONSTANT	VARCHAR2(200) := 'OKE_K_LINES_V';

  G_EXCEPTION_HALT_VALIDATION	exception;



PROCEDURE validate_OKC_header_fields ( x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

CURSOR l_csr1 IS
select 'x'
from hr_all_organization_units hr , mtl_parameters mp
where mp.organization_id = hr.organization_id
and mp.master_organization_id = mp.organization_id
and hr.organization_id = p_chr_rec.inv_organization_id;

CURSOR l_csr2 IS
select 'x'
from hr_operating_units
where organization_id = p_chr_rec.authoring_org_id;


l_dummy1  VARCHAR2(1) := '?';
l_dummy2  VARCHAR2(1) := '?';



BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.start_date = OKE_API.G_MISS_DATE
     OR p_chr_rec.start_date IS NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'START_DATE');
      x_return_status := OKE_API.G_RET_STS_ERROR;
  END IF;

  IF (   p_chr_rec.inv_organization_id = OKE_API.G_MISS_NUM
     OR p_chr_rec.inv_organization_id IS NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'INV_ORGANIZATION_ID');
      x_return_status := OKE_API.G_RET_STS_ERROR;
  END IF;


  IF (   p_chr_rec.authoring_org_id = OKE_API.G_MISS_NUM
     OR p_chr_rec.authoring_org_id IS NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'AUTHORING_ORG_ID');
      x_return_status := OKE_API.G_RET_STS_ERROR;
  END IF;


  IF ( p_chr_rec.inv_organization_id <> OKE_API.G_MISS_NUM
	AND p_chr_rec.inv_organization_id IS NOT NULL) THEN

	Open l_csr1;
	Fetch l_csr1 INTO l_dummy1;
	Close l_csr1;

	If l_dummy1 = '?' Then
  	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_no_parent_record,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'INV_ORGANIZATION_ID',
				p_token2		=> g_child_table_token,
				p_token2_value	=> G_VIEW,
				p_token3		=> g_parent_table_token,
				p_token3_value	=> 'HR_ALL_ORGANIZATION_UNITS,MTL_PARAMETERS');
      	  x_return_status := OKE_API.G_RET_STS_ERROR;
 	END IF;
  END IF;

  IF ( p_chr_rec.authoring_org_id <> OKE_API.G_MISS_NUM
	AND p_chr_rec.authoring_org_id <> -99
	AND p_chr_rec.authoring_org_id IS NOT NULL) THEN

	Open l_csr2;
	Fetch l_csr2 INTO l_dummy2;
	Close l_csr2;

	If l_dummy2 = '?' Then
  	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_no_parent_record,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'AUTHORING_ORG_ID',
				p_token2		=> g_child_table_token,
				p_token2_value	=> G_VIEW,
				p_token3		=> g_parent_table_token,
				p_token3_value	=> 'HR_OPERATING_UNITS');
      	  x_return_status := OKE_API.G_RET_STS_ERROR;
 	END IF;
  END IF;



EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_OKC_header_fields;




PROCEDURE validate_OKC_line_fields ( x_return_status OUT NOCOPY VARCHAR2,
				p_cle_rec	IN  cle_rec_type)IS

CURSOR l_csr1 IS
select 'x'
FROM Okc_Statuses_B
WHERE okc_statuses_b.code  = p_cle_rec.sts_code;

l_dummy1  VARCHAR2(1) := '?';
l_line_num VARCHAR2(400);


BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF ( p_cle_rec.sts_code <> OKE_API.G_MISS_CHAR
	AND p_cle_rec.sts_code IS NOT NULL) THEN

	Open l_csr1;
	Fetch l_csr1 INTO l_dummy1;
	Close l_csr1;

	If l_dummy1 = '?' Then
  	    OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_no_parent_record,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'STS_CODE',
				p_token2		=> g_child_table_token,
				p_token2_value	=> G_VIEW,
				p_token3		=> g_parent_table_token,
				p_token3_value	=> 'OKC_STATUSES_B');
      	  x_return_status := OKE_API.G_RET_STS_ERROR;
 	END IF;
  END IF;

  IF ( p_cle_rec.line_number <> OKE_API.G_MISS_CHAR
	AND p_cle_rec.line_number IS NOT NULL) THEN

	l_line_num := RTRIM(p_cle_rec.line_number)||' ';
	IF length(l_line_num)=1 THEN

      	  OKE_API.SET_MESSAGE(p_app_name	=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'LINE_NUMBER');
          x_return_status := OKE_API.G_RET_STS_ERROR;
 	END IF;
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_OKC_line_fields;







  PROCEDURE create_contract_header(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    p_ignore_oke_validation        IN VARCHAR2 DEFAULT 'N',
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_chr_rec			   IN  chr_rec_type,
    x_chr_rec			   OUT NOCOPY  chr_rec_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKE_API.G_RET_STS_SUCCESS;


    l_okc_chrv_rec		OKC_CONTRACT_PUB.chrv_rec_type;
    l_oke_chr_rec		OKE_CONTRACT_PUB.chr_rec_type;

    l_out_chrv		OKC_CONTRACT_PUB.chrv_rec_type;
    l_out_chr		OKE_CONTRACT_PUB.chr_rec_type;



BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;






-- start assigning items into the records


  l_oke_chr_rec.k_header_id  		:= p_chr_rec.k_header_id;
  l_oke_chr_rec.program_id  		:= p_chr_rec.program_id;
  l_oke_chr_rec.project_id  		:= p_chr_rec.project_id;
  l_oke_chr_rec.boa_id  		:= p_chr_rec.boa_id;
  l_oke_chr_rec.k_type_code  		:= p_chr_rec.k_type_code;
  l_oke_chr_rec.priority_code  		:= p_chr_rec.priority_code;
  l_oke_chr_rec.prime_k_alias  		:= p_chr_rec.prime_k_alias;
  l_oke_chr_rec.prime_k_number  	:= p_chr_rec.prime_k_number;
  l_oke_chr_rec.authorize_date  	:= p_chr_rec.authorize_date;
  l_oke_chr_rec.authorizing_reason  	:= p_chr_rec.authorizing_reason;
  l_oke_chr_rec.award_cancel_date 	:= p_chr_rec.award_cancel_date;
  l_oke_chr_rec.award_date	  	:= p_chr_rec.award_date;
  l_oke_chr_rec.date_definitized  	:= p_chr_rec.date_definitized;
  l_oke_chr_rec.date_issued 	  	:= p_chr_rec.date_issued;
  l_oke_chr_rec.date_negotiated   	:= p_chr_rec.date_negotiated;
  l_oke_chr_rec.date_received 	  	:= p_chr_rec.date_received;
  l_oke_chr_rec.date_sign_by_contractor := p_chr_rec.date_sign_by_contractor;
  l_oke_chr_rec.date_sign_by_customer  	:= p_chr_rec.date_sign_by_customer;
  l_oke_chr_rec.faa_approve_date 	:= p_chr_rec.faa_approve_date;
  l_oke_chr_rec.faa_reject_date  	:= p_chr_rec.faa_reject_date;
  l_oke_chr_rec.booked_flag		:= p_chr_rec.booked_flag;
  l_oke_chr_rec.open_flag		:= p_chr_rec.open_flag;
  l_oke_chr_rec.cfe_flag		:= p_chr_rec.cfe_flag;
  l_oke_chr_rec.vat_code		:= p_chr_rec.vat_code;
  l_oke_chr_rec.country_of_origin_code  := p_chr_rec.country_of_origin_code;
  l_oke_chr_rec.export_flag		:= p_chr_rec.export_flag;
  l_oke_chr_rec.human_subject_flag   	:= p_chr_rec.human_subject_flag;
  l_oke_chr_rec.cqa_flag		:= p_chr_rec.cqa_flag;
  l_oke_chr_rec.interim_rpt_req_flag   	:= p_chr_rec.interim_rpt_req_flag;
  l_oke_chr_rec.no_competition_authorize:= p_chr_rec.no_competition_authorize;
  l_oke_chr_rec.penalty_clause_flag   	:= p_chr_rec.penalty_clause_flag;
  l_oke_chr_rec.product_line_code   	:= p_chr_rec.product_line_code;
  l_oke_chr_rec.reporting_flag    	:= p_chr_rec.reporting_flag;
  l_oke_chr_rec.sb_plan_req_flag  	:= p_chr_rec.sb_plan_req_flag;
  l_oke_chr_rec.sb_report_flag 	  	:= p_chr_rec.sb_report_flag;
  l_oke_chr_rec.nte_amount 	  	:= p_chr_rec.nte_amount;
  l_oke_chr_rec.nte_warning_flag 	:= p_chr_rec.nte_warning_flag;
  l_oke_chr_rec.bill_without_def_flag   := p_chr_rec.bill_without_def_flag;
  l_oke_chr_rec.cas_flag	  	:= p_chr_rec.cas_flag;
  l_oke_chr_rec.classified_flag   	:= p_chr_rec.classified_flag;
  l_oke_chr_rec.client_approve_req_flag := p_chr_rec.client_approve_req_flag;
  l_oke_chr_rec.cost_of_money 	  	:= p_chr_rec.cost_of_money;
  l_oke_chr_rec.dcaa_audit_req_flag   	:= p_chr_rec.dcaa_audit_req_flag;
  l_oke_chr_rec.cost_share_flag 	:= p_chr_rec.cost_share_flag;
  l_oke_chr_rec.oh_rates_final_flag   	:= p_chr_rec.oh_rates_final_flag;
  l_oke_chr_rec.prop_delivery_location  := p_chr_rec.prop_delivery_location;
  l_oke_chr_rec.prop_due_date_time 	:= p_chr_rec.prop_due_date_time;
  l_oke_chr_rec.prop_expire_date 	:= p_chr_rec.prop_expire_date;
  l_oke_chr_rec.copies_required		:= p_chr_rec.copies_required;
  l_oke_chr_rec.sic_code 		:= p_chr_rec.sic_code;
  l_oke_chr_rec.tech_data_wh_rate   	:= p_chr_rec.tech_data_wh_rate;
  l_oke_chr_rec.progress_payment_flag	:= p_chr_rec.progress_payment_flag;
  l_oke_chr_rec.progress_payment_liq_rate:=p_chr_rec.progress_payment_liq_rate;
  l_oke_chr_rec.progress_payment_rate	:= p_chr_rec.progress_payment_rate;
  l_oke_chr_rec.alternate_liquidation_rate:=p_chr_rec.alternate_liquidation_rate;
  l_oke_chr_rec.prop_due_time		:= p_chr_rec.prop_due_time;
  l_oke_chr_rec.definitized_flag	:= p_chr_rec.definitized_flag;
  l_oke_chr_rec.financial_ctrl_verified_flag := p_chr_rec.financial_ctrl_verified_flag;
  l_oke_chr_rec.cost_of_sale_rate	:= p_chr_rec.cost_of_sale_rate;
  l_oke_chr_rec.created_by	  	:= p_chr_rec.created_by;
  l_oke_chr_rec.creation_date		:= p_chr_rec.creation_date;
  l_oke_chr_rec.last_updated_by   	:= p_chr_rec.last_updated_by;
  l_oke_chr_rec.last_update_login 	:= p_chr_rec.last_update_login;
  l_oke_chr_rec.last_update_date  	:= p_chr_rec.last_update_date;
  l_oke_chr_rec.line_value_total	:= p_chr_rec.line_value_total;
  l_oke_chr_rec.undef_line_value_total	:= p_chr_rec.undef_line_value_total;
  l_oke_chr_rec.owning_organization_id	:= p_chr_rec.owning_organization_id;


    l_okc_chrv_rec.id                             := p_chr_rec.k_header_id;
    l_okc_chrv_rec.object_version_number          := p_chr_rec.object_version_number;
    l_okc_chrv_rec.sfwt_flag                      := p_chr_rec.sfwt_flag;
    l_okc_chrv_rec.chr_id_response                := p_chr_rec.chr_id_response;
    l_okc_chrv_rec.chr_id_award                   := p_chr_rec.chr_id_award;

    l_okc_chrv_rec.INV_ORGANIZATION_ID            := p_chr_rec.INV_ORGANIZATION_ID;
    l_okc_chrv_rec.sts_code                       := p_chr_rec.sts_code;
    l_okc_chrv_rec.qcl_id                         := p_chr_rec.qcl_id;
    l_okc_chrv_rec.scs_code                       := p_chr_rec.scs_code;
    l_okc_chrv_rec.contract_number                := p_chr_rec.contract_number;
    l_okc_chrv_rec.currency_code                  := p_chr_rec.currency_code;
    l_okc_chrv_rec.contract_number_modifier       := p_chr_rec.contract_number_modifier;
    l_okc_chrv_rec.archived_yn                    := p_chr_rec.archived_yn;
    l_okc_chrv_rec.deleted_yn                     := p_chr_rec.deleted_yn;
    l_okc_chrv_rec.cust_po_number_req_yn          := p_chr_rec.cust_po_number_req_yn;
    l_okc_chrv_rec.pre_pay_req_yn                 := p_chr_rec.pre_pay_req_yn;
    l_okc_chrv_rec.cust_po_number                 := p_chr_rec.cust_po_number;
    l_okc_chrv_rec.short_description              := p_chr_rec.short_description;
    l_okc_chrv_rec.comments                       := p_chr_rec.comments;
    l_okc_chrv_rec.description                    := p_chr_rec.description;
    l_okc_chrv_rec.dpas_rating                    := p_chr_rec.dpas_rating;
    l_okc_chrv_rec.cognomen                       := p_chr_rec.cognomen;
    l_okc_chrv_rec.template_yn                    := p_chr_rec.template_yn;
    l_okc_chrv_rec.template_used                  := p_chr_rec.template_used;
    l_okc_chrv_rec.date_approved                  := p_chr_rec.date_approved;
    l_okc_chrv_rec.datetime_cancelled             := p_chr_rec.datetime_cancelled;
    l_okc_chrv_rec.auto_renew_days                := p_chr_rec.auto_renew_days;
    l_okc_chrv_rec.date_issued                    := p_chr_rec.date_issued;
    l_okc_chrv_rec.datetime_responded             := p_chr_rec.datetime_responded;
    l_okc_chrv_rec.non_response_reason            := p_chr_rec.non_response_reason;
    l_okc_chrv_rec.non_response_explain           := p_chr_rec.non_response_explain;
    l_okc_chrv_rec.rfp_type                       := p_chr_rec.rfp_type;
    l_okc_chrv_rec.chr_type                       := p_chr_rec.chr_type;
    l_okc_chrv_rec.keep_on_mail_list              := p_chr_rec. keep_on_mail_list;
    l_okc_chrv_rec.set_aside_reason               := p_chr_rec.set_aside_reason;
    l_okc_chrv_rec.set_aside_percent              := p_chr_rec.set_aside_percent;
    l_okc_chrv_rec.response_copies_req            := p_chr_rec.response_copies_req;
    l_okc_chrv_rec.date_close_projected           := p_chr_rec.date_close_projected;
    l_okc_chrv_rec.datetime_proposed              := p_chr_rec.datetime_proposed;
    l_okc_chrv_rec.date_signed                    := p_chr_rec.date_signed;
    l_okc_chrv_rec.date_terminated                := p_chr_rec.date_terminated;
    l_okc_chrv_rec.date_renewed                   := p_chr_rec.date_renewed;
    l_okc_chrv_rec.trn_code                       := p_chr_rec.trn_code;
    l_okc_chrv_rec.start_date                     := p_chr_rec.start_date;
    l_okc_chrv_rec.end_date                       := p_chr_rec.end_date;
    l_okc_chrv_rec.authoring_org_id               := p_chr_rec.authoring_org_id;
    l_okc_chrv_rec.buy_or_sell                    := p_chr_rec.buy_or_sell;
    l_okc_chrv_rec.issue_or_receive               := p_chr_rec.issue_or_receive;
    l_okc_chrv_rec.estimated_amount		  := p_chr_rec.estimated_amount;

    l_okc_chrv_rec.estimated_amount_renewed       := p_chr_rec.estimated_amount_renewed;
    l_okc_chrv_rec.currency_code_renewed	  := p_chr_rec.currency_code_renewed;
    l_okc_chrv_rec.upg_orig_system_ref            := p_chr_rec.upg_orig_system_ref;
    l_okc_chrv_rec.upg_orig_system_ref_id         := p_chr_rec.upg_orig_system_ref_id;
    l_okc_chrv_rec.attribute_category             := p_chr_rec.attribute_category;
    l_okc_chrv_rec.attribute1                     := p_chr_rec.attribute1;
    l_okc_chrv_rec.attribute2                     := p_chr_rec.attribute2;
    l_okc_chrv_rec.attribute3                     := p_chr_rec.attribute3;
    l_okc_chrv_rec.attribute4                     := p_chr_rec.attribute4;
    l_okc_chrv_rec.attribute5                     := p_chr_rec.attribute5;
    l_okc_chrv_rec.attribute6                     := p_chr_rec.attribute6;
    l_okc_chrv_rec.attribute7                     := p_chr_rec.attribute7;
    l_okc_chrv_rec.attribute8                     := p_chr_rec.attribute8;
    l_okc_chrv_rec.attribute9                     := p_chr_rec.attribute9;
    l_okc_chrv_rec.attribute10                    := p_chr_rec.attribute10;
    l_okc_chrv_rec.attribute11                    := p_chr_rec.attribute11;
    l_okc_chrv_rec.attribute12                    := p_chr_rec.attribute12;
    l_okc_chrv_rec.attribute13                    := p_chr_rec.attribute13;
    l_okc_chrv_rec.attribute14                    := p_chr_rec.attribute14;
    l_okc_chrv_rec.attribute15                    := p_chr_rec.attribute15;
    l_okc_chrv_rec.created_by                     := p_chr_rec.created_by;
    l_okc_chrv_rec.creation_date                  := p_chr_rec.creation_date;
    l_okc_chrv_rec.last_updated_by                := p_chr_rec.last_updated_by;
    l_okc_chrv_rec.last_update_date               := p_chr_rec.last_update_date;
    l_okc_chrv_rec.last_update_login              := p_chr_rec.last_update_login;




   If nvl(p_ignore_oke_validation,'N') = 'N' then
       Validate_OKC_header_fields ( l_return_status, p_chr_rec );

       --- If any errors happen abort API
       IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
         RAISE OKE_API.G_EXCEPTION_ERROR;
       END IF;
   end if;

-- assign mandatory values
	l_okc_chrv_rec.archived_yn := 'N';
	l_okc_chrv_rec.deleted_yn  := 'N';
	l_okc_chrv_rec.scs_code    := 'PROJECT';




	OKE_CONTRACT_PUB.create_contract_header(
			p_api_version		=>	p_api_version,
    			p_init_msg_list		=>	p_init_msg_list,
    			x_return_status		=>	x_return_status,
    			x_msg_count		=>	x_msg_count,
   			x_msg_data		=>	x_msg_data,
			p_chr_rec		=>	l_oke_chr_rec,
			p_chrv_rec		=>	l_okc_chrv_rec,
			x_chr_rec		=>	l_out_chr,
			x_chrv_rec		=>	l_out_chrv	);

    If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;



-- Added code to update who columns. neccessary for security to work after import process.

IF p_chr_rec.created_by <> OKE_API.G_MISS_NUM AND p_chr_rec.created_by IS NOT NULL THEN
  UPDATE OKE_K_HEADERS SET CREATED_BY = p_chr_rec.created_by
  WHERE K_HEADER_ID = l_out_chr.k_header_id;
END IF;
IF p_chr_rec.creation_date <> OKE_API.G_MISS_DATE AND p_chr_rec.creation_date IS NOT NULL THEN
  UPDATE OKE_K_HEADERS SET CREATION_DATE = p_chr_rec.creation_date
  WHERE K_HEADER_ID = l_out_chr.k_header_id;
END IF;
IF p_chr_rec.last_updated_by <> OKE_API.G_MISS_NUM AND p_chr_rec.last_updated_by IS NOT NULL THEN
  UPDATE OKE_K_HEADERS SET LAST_UPDATED_BY = p_chr_rec.last_updated_by
  WHERE K_HEADER_ID = l_out_chr.k_header_id;
END IF;
IF p_chr_rec.last_update_login <> OKE_API.G_MISS_NUM AND p_chr_rec.last_update_login IS NOT NULL THEN
  UPDATE OKE_K_HEADERS SET LAST_UPDATE_LOGIN = p_chr_rec.last_update_login
  WHERE K_HEADER_ID = l_out_chr.k_header_id;
END IF;
IF p_chr_rec.last_update_date <> OKE_API.G_MISS_DATE AND p_chr_rec.last_update_date IS NOT NULL THEN
  UPDATE OKE_K_HEADERS SET LAST_UPDATE_DATE = p_chr_rec.last_update_date
  WHERE K_HEADER_ID = l_out_chr.k_header_id;
END IF;

-- Added code to update who columns. neccessary for security to work after import process.



-- oke stuff

  x_chr_rec.k_header_id  	:= l_out_chr.k_header_id;
  x_chr_rec.program_id  	:= l_out_chr.program_id;
  x_chr_rec.project_id  	:= l_out_chr.project_id;
  x_chr_rec.boa_id  		:= l_out_chr.boa_id;
  x_chr_rec.k_type_code  	:= l_out_chr.k_type_code;
  x_chr_rec.priority_code  	:= l_out_chr.priority_code;
  x_chr_rec.prime_k_alias  	:= l_out_chr.prime_k_alias;
  x_chr_rec.prime_k_number  	:= l_out_chr.prime_k_number;
  x_chr_rec.authorize_date  	:= l_out_chr.authorize_date;
  x_chr_rec.authorizing_reason  := l_out_chr.authorizing_reason;
  x_chr_rec.award_cancel_date 	:= l_out_chr.award_cancel_date;
  x_chr_rec.award_date	  	:= l_out_chr.award_date;
  x_chr_rec.date_definitized  	:= l_out_chr.date_definitized;
  x_chr_rec.date_issued 	:= l_out_chr.date_issued;
  x_chr_rec.date_negotiated   	:= l_out_chr.date_negotiated;
  x_chr_rec.date_received 	:= l_out_chr.date_received;
  x_chr_rec.date_sign_by_contractor 	:= l_out_chr.date_sign_by_contractor;
  x_chr_rec.date_sign_by_customer 	:= l_out_chr.date_sign_by_customer;
  x_chr_rec.faa_approve_date 	  	:= l_out_chr.faa_approve_date;
  x_chr_rec.faa_reject_date 	  	:= l_out_chr.faa_reject_date;
  x_chr_rec.booked_flag		  	:= l_out_chr.booked_flag;
  x_chr_rec.open_flag		  	:= l_out_chr.open_flag;
  x_chr_rec.cfe_flag		  	:= l_out_chr.cfe_flag;
  x_chr_rec.vat_code		  	:= l_out_chr.vat_code;
  x_chr_rec.country_of_origin_code	:= l_out_chr.country_of_origin_code;
  x_chr_rec.export_flag		  	:= l_out_chr.export_flag;
  x_chr_rec.human_subject_flag    	:= l_out_chr.human_subject_flag;
  x_chr_rec.cqa_flag		  	:= l_out_chr.cqa_flag;
  x_chr_rec.interim_rpt_req_flag  	:= l_out_chr.interim_rpt_req_flag;
  x_chr_rec.no_competition_authorize   	:= l_out_chr.no_competition_authorize;
  x_chr_rec.penalty_clause_flag   	:= l_out_chr.penalty_clause_flag;
  x_chr_rec.product_line_code   	:= l_out_chr.product_line_code;
  x_chr_rec.reporting_flag    		:= l_out_chr.reporting_flag;
  x_chr_rec.sb_plan_req_flag  		:= l_out_chr.sb_plan_req_flag;
  x_chr_rec.sb_report_flag 	  	:= l_out_chr.sb_report_flag;
  x_chr_rec.nte_amount 	  		:= l_out_chr.nte_amount;
  x_chr_rec.nte_warning_flag 		:= l_out_chr.nte_warning_flag;
  x_chr_rec.bill_without_def_flag   	:= l_out_chr.bill_without_def_flag;
  x_chr_rec.cas_flag	  		:= l_out_chr.cas_flag;
  x_chr_rec.classified_flag   		:= l_out_chr.classified_flag;
  x_chr_rec.client_approve_req_flag 	:= l_out_chr.client_approve_req_flag;
  x_chr_rec.cost_of_money 	  	:= l_out_chr.cost_of_money;
  x_chr_rec.dcaa_audit_req_flag   	:= l_out_chr.dcaa_audit_req_flag;
  x_chr_rec.cost_share_flag 		:= l_out_chr.cost_share_flag;
  x_chr_rec.oh_rates_final_flag   	:= l_out_chr.oh_rates_final_flag;
  x_chr_rec.prop_delivery_location  	:= l_out_chr.prop_delivery_location;
  x_chr_rec.prop_due_date_time 		:= l_out_chr.prop_due_date_time;
  x_chr_rec.prop_expire_date 		:= l_out_chr.prop_expire_date;
  x_chr_rec.copies_required		:= l_out_chr.copies_required;
  x_chr_rec.sic_code 			:= l_out_chr.sic_code;
  x_chr_rec.tech_data_wh_rate   	:= l_out_chr.tech_data_wh_rate;
  x_chr_rec.progress_payment_flag	:= l_out_chr.progress_payment_flag;
  x_chr_rec.progress_payment_liq_rate	:= l_out_chr.progress_payment_liq_rate;
  x_chr_rec.progress_payment_rate	:= l_out_chr.progress_payment_rate;
  x_chr_rec.alternate_liquidation_rate	:= l_out_chr.alternate_liquidation_rate;
  x_chr_rec.prop_due_time		:= l_out_chr.prop_due_time;
  x_chr_rec.definitized_flag		:= l_out_chr.definitized_flag;
  x_chr_rec.financial_ctrl_verified_flag:= l_out_chr.financial_ctrl_verified_flag;
  x_chr_rec.cost_of_sale_rate		:= l_out_chr.cost_of_sale_rate;
  x_chr_rec.created_by	  		:= l_out_chr.created_by;
  x_chr_rec.creation_date		:= l_out_chr.creation_date;
  x_chr_rec.last_updated_by   		:= l_out_chr.last_updated_by;
  x_chr_rec.last_update_login 		:= l_out_chr.last_update_login;
  x_chr_rec.last_update_date  		:= l_out_chr.last_update_date;
  x_chr_rec.line_value_total		:= l_out_chr.line_value_total;
  x_chr_rec.undef_line_value_total	:= l_out_chr.undef_line_value_total;
  x_chr_rec.owning_organization_id	:= l_out_chr.owning_organization_id;



	-- okc stuff
	-- being later thereby overwriting the oke stuff if there is duplicate fields

    x_chr_rec.k_header_id                    := l_out_chrv.id;
    x_chr_rec.object_version_number          := l_out_chrv.object_version_number;
    x_chr_rec.sfwt_flag                      := l_out_chrv.sfwt_flag;
    x_chr_rec.chr_id_response                := l_out_chrv.chr_id_response;
    x_chr_rec.chr_id_award                   := l_out_chrv.chr_id_award;

    x_chr_rec.INV_ORGANIZATION_ID            := l_out_chrv.INV_ORGANIZATION_ID;
    x_chr_rec.sts_code                       := l_out_chrv.sts_code;
    x_chr_rec.qcl_id                         := l_out_chrv.qcl_id;
    x_chr_rec.scs_code                       := l_out_chrv.scs_code;
    x_chr_rec.contract_number                := l_out_chrv.contract_number;
    x_chr_rec.currency_code                  := l_out_chrv.currency_code;
    x_chr_rec.contract_number_modifier       := l_out_chrv.contract_number_modifier;
    x_chr_rec.archived_yn                    := l_out_chrv.archived_yn;
    x_chr_rec.deleted_yn                     := l_out_chrv.deleted_yn;
    x_chr_rec.cust_po_number_req_yn          := l_out_chrv.cust_po_number_req_yn;
    x_chr_rec.pre_pay_req_yn                 := l_out_chrv.pre_pay_req_yn;
    x_chr_rec.cust_po_number                 := l_out_chrv.cust_po_number;
    x_chr_rec.short_description              := l_out_chrv.short_description;
    x_chr_rec.comments                       := l_out_chrv.comments;
    x_chr_rec.description                    := l_out_chrv.description;
    x_chr_rec.dpas_rating                    := l_out_chrv.dpas_rating;
    x_chr_rec.cognomen                       := l_out_chrv.cognomen;
    x_chr_rec.template_yn                    := l_out_chrv.template_yn;
    x_chr_rec.template_used                  := l_out_chrv.template_used;
    x_chr_rec.date_approved                  := l_out_chrv.date_approved;
    x_chr_rec.datetime_cancelled             := l_out_chrv.datetime_cancelled;
    x_chr_rec.auto_renew_days                := l_out_chrv.auto_renew_days;
    x_chr_rec.date_issued                    := l_out_chrv.date_issued;
    x_chr_rec.datetime_responded             := l_out_chrv.datetime_responded;
    x_chr_rec.non_response_reason            := l_out_chrv.non_response_reason;
    x_chr_rec.non_response_explain           := l_out_chrv.non_response_explain;
    x_chr_rec.rfp_type                       := l_out_chrv.rfp_type;
    x_chr_rec.chr_type                       := l_out_chrv.chr_type;
    x_chr_rec.keep_on_mail_list              := l_out_chrv. keep_on_mail_list;
    x_chr_rec.set_aside_reason               := l_out_chrv.set_aside_reason;
    x_chr_rec.set_aside_percent              := l_out_chrv.set_aside_percent;
    x_chr_rec.response_copies_req            := l_out_chrv.response_copies_req;
    x_chr_rec.date_close_projected           := l_out_chrv.date_close_projected;
    x_chr_rec.datetime_proposed              := l_out_chrv.datetime_proposed;
    x_chr_rec.date_signed                    := l_out_chrv.date_signed;
    x_chr_rec.date_terminated                := l_out_chrv.date_terminated;
    x_chr_rec.date_renewed                   := l_out_chrv.date_renewed;
    x_chr_rec.trn_code                       := l_out_chrv.trn_code;
    x_chr_rec.start_date                     := l_out_chrv.start_date;
    x_chr_rec.end_date                       := l_out_chrv.end_date;
    x_chr_rec.authoring_org_id               := l_out_chrv.authoring_org_id;
    x_chr_rec.buy_or_sell                    := l_out_chrv.buy_or_sell;
    x_chr_rec.issue_or_receive               := l_out_chrv.issue_or_receive;
    x_chr_rec.estimated_amount		     := l_out_chrv.estimated_amount;

    x_chr_rec.estimated_amount_renewed       := l_out_chrv.estimated_amount_renewed;
    x_chr_rec.currency_code_renewed	     := l_out_chrv.currency_code_renewed;
    x_chr_rec.upg_orig_system_ref            := l_out_chrv.upg_orig_system_ref;
    x_chr_rec.upg_orig_system_ref_id         := l_out_chrv.upg_orig_system_ref_id;
    x_chr_rec.attribute_category             := l_out_chrv.attribute_category;
    x_chr_rec.attribute1                     := l_out_chrv.attribute1;
    x_chr_rec.attribute2                     := l_out_chrv.attribute2;
    x_chr_rec.attribute3                     := l_out_chrv.attribute3;
    x_chr_rec.attribute4                     := l_out_chrv.attribute4;
    x_chr_rec.attribute5                     := l_out_chrv.attribute5;
    x_chr_rec.attribute6                     := l_out_chrv.attribute6;
    x_chr_rec.attribute7                     := l_out_chrv.attribute7;
    x_chr_rec.attribute8                     := l_out_chrv.attribute8;
    x_chr_rec.attribute9                     := l_out_chrv.attribute9;
    x_chr_rec.attribute10                    := l_out_chrv.attribute10;
    x_chr_rec.attribute11                    := l_out_chrv.attribute11;
    x_chr_rec.attribute12                    := l_out_chrv.attribute12;
    x_chr_rec.attribute13                    := l_out_chrv.attribute13;
    x_chr_rec.attribute14                    := l_out_chrv.attribute14;
    x_chr_rec.attribute15                    := l_out_chrv.attribute15;
    x_chr_rec.created_by                     := l_out_chrv.created_by;
    x_chr_rec.creation_date                  := l_out_chrv.creation_date;
    x_chr_rec.last_updated_by                := l_out_chrv.last_updated_by;
    x_chr_rec.last_update_date               := l_out_chrv.last_update_date;
    x_chr_rec.last_update_login              := l_out_chrv.last_update_login;



    OKE_API.END_ACTIVITY(       x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END create_contract_header;




  PROCEDURE create_contract_line(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_cle_rec			   IN  cle_rec_type,
    x_cle_rec			   OUT NOCOPY  cle_rec_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKE_API.G_RET_STS_SUCCESS;

    l_okc_clev_rec		OKC_CONTRACT_PUB.clev_rec_type;
    l_oke_cle_rec		OKE_CONTRACT_PUB.cle_rec_type;
    l_out_clev		OKC_CONTRACT_PUB.clev_rec_type;
    l_out_cle		OKE_CONTRACT_PUB.cle_rec_type;

    l_cimv_rec		CIMV_REC_TYPE;
    l_cimv_out		CIMV_REC_TYPE;
    l_inv_Org		NUMBER;

    CURSOR get_inventory_org (p_chr NUMBER)  IS
    SELECT inv_organization_id
    FROM OKC_K_HEADERS_B
    WHERE ID = p_chr;


BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;




  l_oke_cle_rec.k_line_id		:= p_cle_rec.k_line_id;
  l_oke_cle_rec.parent_line_id		:= p_cle_rec.parent_line_id;
  l_oke_cle_rec.project_id		:= p_cle_rec.project_id;
  l_oke_cle_rec.task_id			:= p_cle_rec.task_id;
  l_oke_cle_rec.billing_method_code	:= p_cle_rec.billing_method_code;
  l_oke_cle_rec.inventory_item_id	:= p_cle_rec.inventory_item_id;
  l_oke_cle_rec.delivery_order_flag	:= p_cle_rec.delivery_order_flag;
  l_oke_cle_rec.splited_flag		:= p_cle_rec.splited_flag;
  l_oke_cle_rec.priority_code		:= p_cle_rec.priority_code;
  l_oke_cle_rec.customer_item_id	:= p_cle_rec.customer_item_id;
  l_oke_cle_rec.customer_item_number	:= p_cle_rec.customer_item_number;
  l_oke_cle_rec.line_quantity		:= p_cle_rec.line_quantity;
  l_oke_cle_rec.delivery_date		:= p_cle_rec.delivery_date;
  l_oke_cle_rec.unit_price		:= p_cle_rec.unit_price;
  l_oke_cle_rec.uom_code		:= p_cle_rec.uom_code;
  l_oke_cle_rec.billable_flag		:= p_cle_rec.billable_flag;
  l_oke_cle_rec.shippable_flag		:= p_cle_rec.shippable_flag;
  l_oke_cle_rec.subcontracted_flag    	:= p_cle_rec.subcontracted_flag;
  l_oke_cle_rec.completed_flag		:= p_cle_rec.completed_flag;
  l_oke_cle_rec.nsp_flag		:= p_cle_rec.nsp_flag;
  l_oke_cle_rec.app_code		:= p_cle_rec.app_code;
  l_oke_cle_rec.as_of_date		:= p_cle_rec.as_of_date;
  l_oke_cle_rec.authority		:= p_cle_rec.authority;
  l_oke_cle_rec.country_of_origin_code 	:= p_cle_rec.country_of_origin_code;
  l_oke_cle_rec.drop_shipped_flag	:= p_cle_rec.drop_shipped_flag;
  l_oke_cle_rec.customer_approval_req_flag  := p_cle_rec.customer_approval_req_flag;
  l_oke_cle_rec.date_material_req	:= p_cle_rec.date_material_req;
  l_oke_cle_rec.inspection_req_flag	:= p_cle_rec.inspection_req_flag;
  l_oke_cle_rec.interim_rpt_req_flag	:= p_cle_rec.interim_rpt_req_flag;
  l_oke_cle_rec.subj_a133_flag		:= p_cle_rec.subj_a133_flag;
  l_oke_cle_rec.export_flag		:= p_cle_rec.export_flag;
  l_oke_cle_rec.cfe_req_flag		:= p_cle_rec.cfe_req_flag;
  l_oke_cle_rec.cop_required_flag	:= p_cle_rec.cop_required_flag;
  l_oke_cle_rec.export_license_num	:= p_cle_rec.export_license_num;
  l_oke_cle_rec.export_license_res    	:= p_cle_rec.export_license_res;
  l_oke_cle_rec.copies_required		:= p_cle_rec.copies_required;
  l_oke_cle_rec.cdrl_category		:= p_cle_rec.cdrl_category;
  l_oke_cle_rec.data_item_name		:= p_cle_rec.data_item_name;
  l_oke_cle_rec.data_item_subtitle	:= p_cle_rec.data_item_subtitle;
  l_oke_cle_rec.date_of_first_submission:= p_cle_rec.date_of_first_submission;
  l_oke_cle_rec.frequency		:= p_cle_rec.frequency;
  l_oke_cle_rec.requiring_office	:= p_cle_rec.requiring_office;
  l_oke_cle_rec.dcaa_audit_req_flag	:= p_cle_rec.dcaa_audit_req_flag;
  l_oke_cle_rec.definitized_flag	:= p_cle_rec.definitized_flag;
  l_oke_cle_rec.cost_of_money		:= p_cle_rec.cost_of_money;
  l_oke_cle_rec.bill_undefinitized_flag := p_cle_rec.bill_undefinitized_flag;
  l_oke_cle_rec.nsn_number		:= p_cle_rec.nsn_number;
  l_oke_cle_rec.nte_warning_flag	:= p_cle_rec.nte_warning_flag;
  l_oke_cle_rec.discount_for_payment	:= p_cle_rec.discount_for_payment;
  l_oke_cle_rec.financial_ctrl_flag	:= p_cle_rec.financial_ctrl_flag;
  l_oke_cle_rec.c_scs_flag		:= p_cle_rec.c_scs_flag;
  l_oke_cle_rec.c_ssr_flag		:= p_cle_rec.c_ssr_flag;
  l_oke_cle_rec.prepayment_amount	:= p_cle_rec.prepayment_amount;
  l_oke_cle_rec.prepayment_percentage  	:= p_cle_rec.prepayment_percentage;
  l_oke_cle_rec.progress_payment_flag 	:= p_cle_rec.progress_payment_flag;
  l_oke_cle_rec.progress_payment_liq_rate := p_cle_rec.progress_payment_liq_rate;
  l_oke_cle_rec.progress_payment_rate 	:= p_cle_rec.progress_payment_rate;
  l_oke_cle_rec.award_fee		:= p_cle_rec.award_fee;
  l_oke_cle_rec.award_fee_pool_amount 	:= p_cle_rec.award_fee_pool_amount;
  l_oke_cle_rec.base_fee		:= p_cle_rec.base_fee;
  l_oke_cle_rec.ceiling_cost		:= p_cle_rec.ceiling_cost;
  l_oke_cle_rec.ceiling_price		:= p_cle_rec.ceiling_price;
  l_oke_cle_rec.labor_cost_index	:= p_cle_rec.labor_cost_index;
  l_oke_cle_rec.material_cost_index	:= p_cle_rec.material_cost_index;
  l_oke_cle_rec.customers_percent_in_order 	:= p_cle_rec.customers_percent_in_order;
  l_oke_cle_rec.cost_overrun_share_ratio	:= p_cle_rec.cost_overrun_share_ratio;
  l_oke_cle_rec.cost_underrun_share_ratio	:= p_cle_rec.cost_underrun_share_ratio;
  l_oke_cle_rec.date_of_price_redetermin 	:= p_cle_rec.date_of_price_redetermin;
  l_oke_cle_rec.estimated_total_quantity 	:= p_cle_rec.estimated_total_quantity;
  l_oke_cle_rec.fee_ajt_formula		:= p_cle_rec.fee_ajt_formula;
  l_oke_cle_rec.final_fee		:= p_cle_rec.final_fee;
  l_oke_cle_rec.final_pft_ajt_formula 	:= p_cle_rec.final_pft_ajt_formula;
  l_oke_cle_rec.fixed_fee		:= p_cle_rec.fixed_fee;
  l_oke_cle_rec.fixed_quantity		:= p_cle_rec.fixed_quantity;
  l_oke_cle_rec.initial_fee		:= p_cle_rec.initial_fee;
  l_oke_cle_rec.initial_price		:= p_cle_rec.initial_price;
  l_oke_cle_rec.level_of_effort_hours 	:= p_cle_rec.level_of_effort_hours;
  l_oke_cle_rec.line_liquidation_rate 	:= p_cle_rec.line_liquidation_rate;
  l_oke_cle_rec.maximum_fee		:= p_cle_rec.maximum_fee;
  l_oke_cle_rec.maximum_quantity	:= p_cle_rec.maximum_quantity;
  l_oke_cle_rec.minimum_fee		:= p_cle_rec.minimum_fee;
  l_oke_cle_rec.minimum_quantity	:= p_cle_rec.minimum_quantity;
  l_oke_cle_rec.number_of_options	:= p_cle_rec.number_of_options;
  l_oke_cle_rec.revised_price		:= p_cle_rec.revised_price;
  l_oke_cle_rec.target_cost		:= p_cle_rec.target_cost;
  l_oke_cle_rec.target_date_definitize 	:= p_cle_rec.target_date_definitize;
  l_oke_cle_rec.target_fee	        := p_cle_rec.target_fee;
  l_oke_cle_rec.target_price		:= p_cle_rec.target_price;
  l_oke_cle_rec.total_estimated_cost  	:= p_cle_rec.total_estimated_cost;
  l_oke_cle_rec.proposal_due_date	:= p_cle_rec.proposal_due_date;
  l_oke_cle_rec.cost_of_sale_rate	:= p_cle_rec.cost_of_sale_rate;
  l_oke_cle_rec.created_by	        := p_cle_rec.created_by;
  l_oke_cle_rec.creation_date		:= p_cle_rec.creation_date;
  l_oke_cle_rec.last_updated_by		:= p_cle_rec.last_updated_by;
  l_oke_cle_rec.last_update_login	:= p_cle_rec.last_update_login;
  l_oke_cle_rec.last_update_date      	:= p_cle_rec.last_update_date;
  l_oke_cle_rec.line_value		:= p_cle_rec.line_value;
  l_oke_cle_rec.line_value_total	:= p_cle_rec.line_value_total;
  l_oke_cle_rec.end_date                := p_cle_rec.end_date;

  l_oke_cle_rec.undef_line_value	:= p_cle_rec.undef_line_value;
  l_oke_cle_rec.undef_line_value_total	:= p_cle_rec.undef_line_value_total;
  l_oke_cle_rec.undef_unit_price        := p_cle_rec.undef_unit_price;

    l_okc_clev_rec.id                      	:= p_cle_rec.k_line_id;
    l_okc_clev_rec.object_version_number    	:= p_cle_rec.object_version_number;
    l_okc_clev_rec.sfwt_flag                	:= p_cle_rec.sfwt_flag;
    l_okc_clev_rec.chr_id                    	:= p_cle_rec.chr_id;
    l_okc_clev_rec.cle_id                    	:= p_cle_rec.cle_id;
    l_okc_clev_rec.lse_id                     	:= p_cle_rec.lse_id;
    l_okc_clev_rec.line_number               	:= p_cle_rec.line_number;
    l_okc_clev_rec.sts_code                  	:= p_cle_rec.sts_code;
    l_okc_clev_rec.display_sequence           	:= p_cle_rec.display_sequence;
    l_okc_clev_rec.trn_code                   	:= p_cle_rec.trn_code  ;
    l_okc_clev_rec.dnz_chr_id                 	:= p_cle_rec.dnz_chr_id  ;
    l_okc_clev_rec.comments                   	:= p_cle_rec.comments    ;
    l_okc_clev_rec.item_description           	:= p_cle_rec.item_description   ;
    l_okc_clev_rec.oke_boe_description        	:= p_cle_rec.oke_boe_description;
    l_okc_clev_rec.hidden_ind                 	:= p_cle_rec.hidden_ind   ;
    l_okc_clev_rec.price_unit			:= p_cle_rec.price_unit;
    l_okc_clev_rec.price_unit_percent		:= p_cle_rec.price_unit_percent;
    l_okc_clev_rec.price_negotiated           	:= p_cle_rec.price_negotiated;
    l_okc_clev_rec.price_negotiated_renewed     := p_cle_rec.price_negotiated_renewed;
    l_okc_clev_rec.price_level_ind    		:= p_cle_rec.price_level_ind;
    l_okc_clev_rec.invoice_line_level_ind       := p_cle_rec.invoice_line_level_ind;
    l_okc_clev_rec.dpas_rating                  := p_cle_rec.dpas_rating;
    l_okc_clev_rec.block23text                  := p_cle_rec.block23text;
    l_okc_clev_rec.exception_yn                 := p_cle_rec.exception_yn;
    l_okc_clev_rec.template_used                := p_cle_rec.template_used;
    l_okc_clev_rec.date_terminated              := p_cle_rec.date_terminated;
    l_okc_clev_rec.name                         := p_cle_rec.name;
    l_okc_clev_rec.start_date                   := p_cle_rec.start_date;

    l_okc_clev_rec.upg_orig_system_ref          := p_cle_rec.upg_orig_system_ref;
    l_okc_clev_rec.upg_orig_system_ref_id       := p_cle_rec.upg_orig_system_ref_id;
    l_okc_clev_rec.attribute_category           := p_cle_rec.attribute_category;
    l_okc_clev_rec.attribute1                   := p_cle_rec.attribute1;
    l_okc_clev_rec.attribute2                   := p_cle_rec.attribute2;
    l_okc_clev_rec.attribute3                   := p_cle_rec.attribute3;
    l_okc_clev_rec.attribute4                   := p_cle_rec.attribute4;
    l_okc_clev_rec.attribute5                   := p_cle_rec.attribute5;
    l_okc_clev_rec.attribute6                   := p_cle_rec.attribute6;
    l_okc_clev_rec.attribute7                   := p_cle_rec.attribute7;
    l_okc_clev_rec.attribute8                   := p_cle_rec.attribute8;
    l_okc_clev_rec.attribute9                   := p_cle_rec.attribute9;
    l_okc_clev_rec.attribute10                  := p_cle_rec.attribute10;
    l_okc_clev_rec.attribute11                  := p_cle_rec.attribute11;
    l_okc_clev_rec.attribute12                  := p_cle_rec.attribute12;
    l_okc_clev_rec.attribute13                  := p_cle_rec.attribute13;
    l_okc_clev_rec.attribute14                  := p_cle_rec.attribute14;
    l_okc_clev_rec.attribute15                  := p_cle_rec.attribute15;
    l_okc_clev_rec.created_by                   := p_cle_rec.created_by;
    l_okc_clev_rec.creation_date                := p_cle_rec.creation_date;
    l_okc_clev_rec.last_updated_by              := p_cle_rec.last_updated_by;
    l_okc_clev_rec.last_update_date             := p_cle_rec.last_update_date;
    l_okc_clev_rec.price_type                   := p_cle_rec.price_type;
    l_okc_clev_rec.currency_code                := p_cle_rec.currency_code;
    l_okc_clev_rec.currency_code_renewed	:= p_cle_rec.currency_code_renewed;
    l_okc_clev_rec.last_update_login            := p_cle_rec.last_update_login;



    Validate_OKC_line_fields ( l_return_status, p_cle_rec );

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


	OKE_CONTRACT_PUB.create_contract_line(
			p_api_version		=>	p_api_version,
    			p_init_msg_list		=>	p_init_msg_list,
    			x_return_status		=>	x_return_status,
    			x_msg_count		=>	x_msg_count,
   			x_msg_data		=>	x_msg_data,
			p_cle_rec		=>	l_oke_cle_rec,
			p_clev_rec		=>	l_okc_clev_rec,
			x_cle_rec		=>	l_out_cle,
			x_clev_rec		=>	l_out_clev	);

    If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


  x_cle_rec.k_line_id			:= l_out_cle.k_line_id;
  x_cle_rec.parent_line_id		:= l_out_cle.parent_line_id;
  x_cle_rec.project_id			:= l_out_cle.project_id;
  x_cle_rec.task_id			:= l_out_cle.task_id;
  x_cle_rec.billing_method_code		:= l_out_cle.billing_method_code;
  x_cle_rec.inventory_item_id		:= l_out_cle.inventory_item_id;
  x_cle_rec.delivery_order_flag		:= l_out_cle.delivery_order_flag;
  x_cle_rec.splited_flag		:= l_out_cle.splited_flag;
  x_cle_rec.priority_code		:= l_out_cle.priority_code;
  x_cle_rec.customer_item_id		:= l_out_cle.customer_item_id;
  x_cle_rec.customer_item_number	:= l_out_cle.customer_item_number;
  x_cle_rec.line_quantity		:= l_out_cle.line_quantity;
  x_cle_rec.delivery_date		:= l_out_cle.delivery_date;
  x_cle_rec.unit_price			:= l_out_cle.unit_price;
  x_cle_rec.uom_code			:= l_out_cle.uom_code;
  x_cle_rec.billable_flag		:= l_out_cle.billable_flag;
  x_cle_rec.shippable_flag		:= l_out_cle.shippable_flag;
  x_cle_rec.subcontracted_flag    	:= l_out_cle.subcontracted_flag;
  x_cle_rec.completed_flag		:= l_out_cle.completed_flag;
  x_cle_rec.nsp_flag			:= l_out_cle.nsp_flag;
  x_cle_rec.app_code			:= l_out_cle.app_code;
  x_cle_rec.as_of_date			:= l_out_cle.as_of_date;
  x_cle_rec.authority			:= l_out_cle.authority;
  x_cle_rec.country_of_origin_code 	:= l_out_cle.country_of_origin_code;
  x_cle_rec.drop_shipped_flag		:= l_out_cle.drop_shipped_flag;
  x_cle_rec.customer_approval_req_flag  := l_out_cle.customer_approval_req_flag;
  x_cle_rec.date_material_req		:= l_out_cle.date_material_req;
  x_cle_rec.inspection_req_flag		:= l_out_cle.inspection_req_flag;
  x_cle_rec.interim_rpt_req_flag	:= l_out_cle.interim_rpt_req_flag;
  x_cle_rec.subj_a133_flag		:= l_out_cle.subj_a133_flag;
  x_cle_rec.export_flag			:= l_out_cle.export_flag;
  x_cle_rec.cfe_req_flag		:= l_out_cle.cfe_req_flag;
  x_cle_rec.cop_required_flag		:= l_out_cle.cop_required_flag;
  x_cle_rec.export_license_num		:= l_out_cle.export_license_num;
  x_cle_rec.export_license_res    	:= l_out_cle.export_license_res;
  x_cle_rec.copies_required		:= l_out_cle.copies_required;
  x_cle_rec.cdrl_category		:= l_out_cle.cdrl_category;
  x_cle_rec.data_item_name		:= l_out_cle.data_item_name;
  x_cle_rec.data_item_subtitle		:= l_out_cle.data_item_subtitle;
  x_cle_rec.date_of_first_submission	:= l_out_cle.date_of_first_submission;
  x_cle_rec.frequency			:= l_out_cle.frequency;
  x_cle_rec.requiring_office		:= l_out_cle.requiring_office;
  x_cle_rec.dcaa_audit_req_flag		:= l_out_cle.dcaa_audit_req_flag;
  x_cle_rec.definitized_flag		:= l_out_cle.definitized_flag;
  x_cle_rec.cost_of_money		:= l_out_cle.cost_of_money;
  x_cle_rec.bill_undefinitized_flag 	:= l_out_cle.bill_undefinitized_flag;
  x_cle_rec.nsn_number			:= l_out_cle.nsn_number;
  x_cle_rec.nte_warning_flag		:= l_out_cle.nte_warning_flag;
  x_cle_rec.discount_for_payment	:= l_out_cle.discount_for_payment;
  x_cle_rec.financial_ctrl_flag		:= l_out_cle.financial_ctrl_flag;
  x_cle_rec.c_scs_flag			:= l_out_cle.c_scs_flag;
  x_cle_rec.c_ssr_flag			:= l_out_cle.c_ssr_flag;
  x_cle_rec.prepayment_amount		:= l_out_cle.prepayment_amount;
  x_cle_rec.prepayment_percentage  	:= l_out_cle.prepayment_percentage;
  x_cle_rec.progress_payment_flag 	:= l_out_cle.progress_payment_flag;
  x_cle_rec.progress_payment_liq_rate 	:= l_out_cle.progress_payment_liq_rate;
  x_cle_rec.progress_payment_rate 	:= l_out_cle.progress_payment_rate;
  x_cle_rec.award_fee			:= l_out_cle.award_fee;
  x_cle_rec.award_fee_pool_amount 	:= l_out_cle.award_fee_pool_amount;
  x_cle_rec.base_fee			:= l_out_cle.base_fee;
  x_cle_rec.ceiling_cost		:= l_out_cle.ceiling_cost;
  x_cle_rec.ceiling_price		:= l_out_cle.ceiling_price;
  x_cle_rec.labor_cost_index		:= l_out_cle.labor_cost_index;
  x_cle_rec.material_cost_index		:= l_out_cle.material_cost_index;
  x_cle_rec.customers_percent_in_order 	:= l_out_cle.customers_percent_in_order;
  x_cle_rec.cost_overrun_share_ratio	:= l_out_cle.cost_overrun_share_ratio;
  x_cle_rec.cost_underrun_share_ratio	:= l_out_cle.cost_underrun_share_ratio;
  x_cle_rec.date_of_price_redetermin 	:= l_out_cle.date_of_price_redetermin;
  x_cle_rec.estimated_total_quantity 	:= l_out_cle.estimated_total_quantity;
  x_cle_rec.fee_ajt_formula		:= l_out_cle.fee_ajt_formula;
  x_cle_rec.final_fee			:= l_out_cle.final_fee;
  x_cle_rec.final_pft_ajt_formula 	:= l_out_cle.final_pft_ajt_formula;
  x_cle_rec.fixed_fee			:= l_out_cle.fixed_fee;
  x_cle_rec.fixed_quantity		:= l_out_cle.fixed_quantity;
  x_cle_rec.initial_fee			:= l_out_cle.initial_fee;
  x_cle_rec.initial_price		:= l_out_cle.initial_price;
  x_cle_rec.level_of_effort_hours 	:= l_out_cle.level_of_effort_hours;
  x_cle_rec.line_liquidation_rate 	:= l_out_cle.line_liquidation_rate;
  x_cle_rec.maximum_fee			:= l_out_cle.maximum_fee;
  x_cle_rec.maximum_quantity		:= l_out_cle.maximum_quantity;
  x_cle_rec.minimum_fee			:= l_out_cle.minimum_fee;
  x_cle_rec.minimum_quantity		:= l_out_cle.minimum_quantity;
  x_cle_rec.number_of_options		:= l_out_cle.number_of_options;
  x_cle_rec.revised_price		:= l_out_cle.revised_price;
  x_cle_rec.target_cost			:= l_out_cle.target_cost;
  x_cle_rec.target_date_definitize 	:= l_out_cle.target_date_definitize;
  x_cle_rec.target_fee	        	:= l_out_cle.target_fee;
  x_cle_rec.target_price		:= l_out_cle.target_price;
  x_cle_rec.total_estimated_cost  	:= l_out_cle.total_estimated_cost;
  x_cle_rec.proposal_due_date		:= l_out_cle.proposal_due_date;
  x_cle_rec.cost_of_sale_rate		:= l_out_cle.cost_of_sale_rate;
  x_cle_rec.created_by	     	   	:= l_out_cle.created_by;
  x_cle_rec.creation_date		:= l_out_cle.creation_date;
  x_cle_rec.last_updated_by		:= l_out_cle.last_updated_by;
  x_cle_rec.last_update_login		:= l_out_cle.last_update_login;
  x_cle_rec.last_update_date      	:= l_out_cle.last_update_date;
  x_cle_rec.line_value		      	:= l_out_cle.line_value;
  x_cle_rec.line_value_total      	:= l_out_cle.line_value_total;
  x_cle_rec.end_date                    := l_out_cle.end_date;

  x_cle_rec.undef_line_value		      	:= l_out_cle.undef_line_value;
  x_cle_rec.undef_line_value_total      	:= l_out_cle.undef_line_value_total;
  x_cle_rec.undef_unit_price                    := l_out_cle.undef_unit_price;


    x_cle_rec.k_line_id                     	:= l_out_clev.id;
    x_cle_rec.object_version_number    		:= l_out_clev.object_version_number;
    x_cle_rec.sfwt_flag                		:= l_out_clev.sfwt_flag;
    x_cle_rec.chr_id                    	:= l_out_clev.chr_id;
    x_cle_rec.cle_id                    	:= l_out_clev.cle_id;

    x_cle_rec.lse_id                     	:= l_out_clev.lse_id;
    x_cle_rec.line_number               	:= l_out_clev.line_number;
    x_cle_rec.sts_code                  	:= l_out_clev.sts_code;
    x_cle_rec.display_sequence           	:= l_out_clev.display_sequence;
    x_cle_rec.trn_code                   	:= l_out_clev.trn_code  ;
    x_cle_rec.dnz_chr_id                 	:= l_out_clev.dnz_chr_id  ;
    x_cle_rec.comments                   	:= l_out_clev.comments    ;
    x_cle_rec.item_description           	:= l_out_clev.item_description   ;
    x_cle_rec.oke_boe_description        	:= l_out_clev.oke_boe_description;
    x_cle_rec.hidden_ind                 	:= l_out_clev.hidden_ind   ;
    x_cle_rec.price_unit			:= l_out_clev.price_unit;
    x_cle_rec.price_unit_percent		:= l_out_clev.price_unit_percent;
    x_cle_rec.price_negotiated           	:= l_out_clev.price_negotiated;
    x_cle_rec.price_negotiated_renewed     	:= l_out_clev.price_negotiated_renewed;
    x_cle_rec.price_level_ind    		:= l_out_clev.price_level_ind;
    x_cle_rec.invoice_line_level_ind       	:= l_out_clev.invoice_line_level_ind;
    x_cle_rec.dpas_rating                  	:= l_out_clev.dpas_rating;
    x_cle_rec.block23text                  	:= l_out_clev.block23text;
    x_cle_rec.exception_yn                	:= l_out_clev.exception_yn;
    x_cle_rec.template_used                	:= l_out_clev.template_used;
    x_cle_rec.date_terminated              	:= l_out_clev.date_terminated;
    x_cle_rec.name                         	:= l_out_clev.name;
    x_cle_rec.start_date                   	:= l_out_clev.start_date;

    x_cle_rec.upg_orig_system_ref          	:= l_out_clev.upg_orig_system_ref;
    x_cle_rec.upg_orig_system_ref_id       	:= l_out_clev.upg_orig_system_ref_id;
    x_cle_rec.attribute_category           	:= l_out_clev.attribute_category;
    x_cle_rec.attribute1                   	:= l_out_clev.attribute1;
    x_cle_rec.attribute2                   	:= l_out_clev.attribute2;
    x_cle_rec.attribute3                   	:= l_out_clev.attribute3;
    x_cle_rec.attribute4                   	:= l_out_clev.attribute4;
    x_cle_rec.attribute5                   	:= l_out_clev.attribute5;
    x_cle_rec.attribute6                   	:= l_out_clev.attribute6;
    x_cle_rec.attribute7                   	:= l_out_clev.attribute7;
    x_cle_rec.attribute8                   	:= l_out_clev.attribute8;
    x_cle_rec.attribute9                  	:= l_out_clev.attribute9;
    x_cle_rec.attribute10                  	:= l_out_clev.attribute10;
    x_cle_rec.attribute11                  	:= l_out_clev.attribute11;
    x_cle_rec.attribute12                  	:= l_out_clev.attribute12;
    x_cle_rec.attribute13                  	:= l_out_clev.attribute13;
    x_cle_rec.attribute14                  	:= l_out_clev.attribute14;
    x_cle_rec.attribute15                  	:= l_out_clev.attribute15;
    x_cle_rec.created_by                   	:= l_out_clev.created_by;
    x_cle_rec.creation_date                	:= l_out_clev.creation_date;
    x_cle_rec.last_updated_by              	:= l_out_clev.last_updated_by;
    x_cle_rec.last_update_date             	:= l_out_clev.last_update_date;
    x_cle_rec.price_type                   	:= l_out_clev.price_type;
    x_cle_rec.currency_code                	:= l_out_clev.currency_code;
    x_cle_rec.currency_code_renewed		:= l_out_clev.currency_code_renewed;
    x_cle_rec.last_update_login            	:= l_out_clev.last_update_login;


-- IF successful: create line item if necessary
    IF x_return_status = OKE_API.G_RET_STS_SUCCESS
	AND x_cle_rec.inventory_item_id IS NOT NULL THEN

	OPEN get_inventory_org (x_cle_rec.DNZ_CHR_ID);
	FETCH get_inventory_org INTO l_inv_org;
	CLOSE get_inventory_org;

	l_cimv_rec.DNZ_CHR_ID := x_cle_rec.DNZ_CHR_ID;
	l_cimv_rec.CLE_ID := x_cle_rec.K_LINE_ID;
	l_cimv_rec.EXCEPTION_YN := 'N';
	l_cimv_rec.PRICED_ITEM_YN := 'N';
	l_cimv_rec.OBJECT1_ID1 := x_cle_rec.inventory_item_id;
	l_cimv_rec.OBJECT1_ID2 := l_inv_org;
	l_cimv_rec.JTOT_OBJECT1_CODE := 'OKE_ITEMS';
	l_cimv_rec.UOM_CODE := x_cle_rec.UOM_CODE;
	l_cimv_rec.NUMBER_OF_ITEMS := x_cle_rec.LINE_QUANTITY;
	l_cimv_rec.CREATED_BY := x_cle_rec.CREATED_BY;
	l_cimv_rec.CREATION_DATE := x_cle_rec.CREATION_DATE;
	l_cimv_rec.LAST_UPDATED_BY := x_cle_rec.LAST_UPDATED_BY;
	l_cimv_rec.LAST_UPDATE_DATE := x_cle_rec.LAST_UPDATE_DATE;
	l_cimv_rec.LAST_UPDATE_LOGIN := x_cle_rec.LAST_UPDATE_LOGIN;


        OKC_CONTEXT.Set_OKC_Org_Context( p_chr_id => x_cle_rec.DNZ_CHR_ID );


	Create_Line_Item (
			p_api_version		=>	p_api_version,
    			p_init_msg_list		=>	p_init_msg_list,
    			x_return_status		=>	x_return_status,
    			x_msg_count		=>	x_msg_count,
   			x_msg_data		=>	x_msg_data,
			p_cimv_rec		=>	l_cimv_rec,
			x_cimv_rec		=>	l_cimv_out	);

    	If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif (x_return_status = OKE_API.G_RET_STS_ERROR) then
       		raise OKE_API.G_EXCEPTION_ERROR;
    	End If;

    END IF;


    OKE_API.END_ACTIVITY(       x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END create_contract_line;

  PROCEDURE create_deliverable(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_del_rec			   IN  del_rec_type,
    x_del_rec			   OUT NOCOPY  del_rec_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_DELIVERABLE';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKE_API.G_RET_STS_SUCCESS;

    l_del_rec		OKE_CONTRACT_PUB.del_rec_type;

    CURSOR get_inv_org IS
    SELECT INV_ORGANIZATION_ID
    FROM OKC_K_HEADERS_B
    WHERE ID = p_del_rec.k_header_id;

    CURSOR get_intent IS
    SELECT BUY_OR_SELL
    FROM OKC_K_HEADERS_B
    WHERE ID = p_del_rec.k_header_id;

    l_intent VARCHAR2(10);

  FUNCTION null_out_defaults(
	 p_del_rec	IN del_rec_type) RETURN del_rec_type IS

  l_del_rec del_rec_type := p_del_rec;

  BEGIN


    IF  l_del_rec.DELIVERABLE_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.DELIVERABLE_ID := NULL;
    END IF;

    IF  l_del_rec.DELIVERABLE_NUM = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DELIVERABLE_NUM := NULL;
    END IF;

    IF  l_del_rec.PROJECT_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.PROJECT_ID := NULL;
    END IF;

    IF  l_del_rec.TASK_ID = OKE_API.G_MISS_NUM THEN
      	l_del_rec.TASK_ID := NULL;
    END IF;

    IF	l_del_rec.ITEM_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.ITEM_ID := NULL;
    END IF;

    IF	l_del_rec.K_HEADER_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.K_HEADER_ID := NULL;
    END IF;

    IF	l_del_rec.K_LINE_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.K_LINE_ID := NULL;
    END IF;

    IF	l_del_rec.DELIVERY_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.DELIVERY_DATE := NULL;
    END IF;

    IF  l_del_rec.STATUS_CODE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.STATUS_CODE	:= NULL;
    END IF;

    IF	l_del_rec.PARENT_DELIVERABLE_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.PARENT_DELIVERABLE_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_TO_ORG_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_TO_ORG_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_TO_LOCATION_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_TO_LOCATION_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_FROM_ORG_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_FROM_ORG_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_FROM_LOCATION_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_FROM_LOCATION_ID := NULL;
    END IF;

    IF	l_del_rec.INVENTORY_ORG_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.INVENTORY_ORG_ID := NULL;
    END IF;

    IF	l_del_rec.DIRECTION = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DIRECTION := NULL;
    END IF;

    IF	l_del_rec.DEFAULTED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DEFAULTED_FLAG := NULL;
    END IF;

    IF	l_del_rec.IN_PROCESS_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.IN_PROCESS_FLAG := NULL;
    END IF;

    IF	l_del_rec.WF_ITEM_KEY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.WF_ITEM_KEY := NULL;
    END IF;

    IF	l_del_rec.SUB_REF_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.SUB_REF_ID := NULL;
    END IF;

    IF	l_del_rec.START_DATE	= OKE_API.G_MISS_DATE THEN
        l_del_rec.START_DATE	:= NULL;
    END IF;

    IF	l_del_rec.END_DATE	= OKE_API.G_MISS_DATE THEN
        l_del_rec.END_DATE	:= NULL;
    END IF;

    IF	l_del_rec.PRIORITY_CODE	= OKE_API.G_MISS_CHAR THEN
        l_del_rec.PRIORITY_CODE := NULL;
    END IF;

    IF	l_del_rec.CURRENCY_CODE	= OKE_API.G_MISS_CHAR THEN
        l_del_rec.CURRENCY_CODE	:= NULL;
    END IF;

    IF	l_del_rec.UNIT_PRICE = OKE_API.G_MISS_NUM THEN
	l_del_rec.UNIT_PRICE := NULL;
    END IF;

    IF	l_del_rec.UOM_CODE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.UOM_CODE := NULL;
    END IF;

    IF	l_del_rec.QUANTITY = OKE_API.G_MISS_NUM THEN
	l_del_rec.QUANTITY := NULL;
    END IF;

    IF  l_del_rec.COUNTRY_OF_ORIGIN_CODE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.COUNTRY_OF_ORIGIN_CODE := NULL;
    END IF;

    IF	l_del_rec.SUBCONTRACTED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.SUBCONTRACTED_FLAG := NULL;
    END IF;

    IF	l_del_rec.DEPENDENCY_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DEPENDENCY_FLAG := NULL;
    END IF;



    IF	l_del_rec.BILLABLE_FLAG	= OKE_API.G_MISS_CHAR THEN
	l_del_rec.BILLABLE_FLAG	:= NULL;
    END IF;

    IF	l_del_rec.BILLING_EVENT_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.BILLING_EVENT_ID := NULL;
    END IF;

    IF	l_del_rec.DROP_SHIPPED_FLAG = OKE_API.G_MISS_CHAR THEN
        l_del_rec.DROP_SHIPPED_FLAG := NULL;
    END IF;

    IF	l_del_rec.COMPLETED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.COMPLETED_FLAG := NULL;
    END IF;

    IF	l_del_rec.AVAILABLE_FOR_SHIP_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.AVAILABLE_FOR_SHIP_FLAG := NULL;
    END IF;

    IF	l_del_rec.CREATE_DEMAND = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CREATE_DEMAND := NULL;
    END IF;

    IF	l_del_rec.READY_TO_BILL = OKE_API.G_MISS_CHAR THEN
	l_del_rec.READY_TO_BILL := NULL;
    END IF;

    IF	l_del_rec.NEED_BY_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.NEED_BY_DATE := NULL;
    END IF;

    IF	l_del_rec.READY_TO_PROCURE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.READY_TO_PROCURE := NULL;
    END IF;

    IF	l_del_rec.MPS_TRANSACTION_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.MPS_TRANSACTION_ID := NULL;
    END IF;

    IF	l_del_rec.PO_REF_1 = OKE_API.G_MISS_NUM THEN
	l_del_rec.PO_REF_1 := NULL;
    END IF;

    IF	l_del_rec.PO_REF_2 = OKE_API.G_MISS_NUM THEN
	l_del_rec.PO_REF_2 := NULL;
    END IF;

    IF	l_del_rec.PO_REF_3 = OKE_API.G_MISS_NUM THEN
	l_del_rec.PO_REF_3 := NULL;
    END IF;

    IF	l_del_rec.SHIPPING_REQUEST_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIPPING_REQUEST_ID := NULL;
    END IF;

    IF	l_del_rec.UNIT_NUMBER = OKE_API.G_MISS_CHAR THEN
	l_del_rec.UNIT_NUMBER := NULL;
    END IF;

    IF	l_del_rec.NDB_SCHEDULE_DESIGNATOR = OKE_API.G_MISS_CHAR THEN
	l_del_rec.NDB_SCHEDULE_DESIGNATOR := NULL;
    END IF;

    IF	l_del_rec.SHIPPABLE_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.SHIPPABLE_FLAG := NULL;
    END IF;

    IF	l_del_rec.CFE_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CFE_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.INSPECTION_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.INSPECTION_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.INTERIM_RPT_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.INTERIM_RPT_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.LOT_APPLIES_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.LOT_APPLIES_FLAG := NULL;
    END IF;

    IF	l_del_rec.CUSTOMER_APPROVAL_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CUSTOMER_APPROVAL_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.EXPECTED_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.EXPECTED_SHIPMENT_DATE := NULL;
    END IF;

    IF	l_del_rec.INITIATE_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.INITIATE_SHIPMENT_DATE := NULL;
    END IF;

    IF	l_del_rec.PROMISED_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.PROMISED_SHIPMENT_DATE := NULL;
    END IF;

    IF	l_del_rec.AS_OF_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.AS_OF_DATE := NULL;
    END IF;

    IF	l_del_rec.DATE_OF_FIRST_SUBMISSION = OKE_API.G_MISS_DATE THEN
	l_del_rec.DATE_OF_FIRST_SUBMISSION := NULL;
    END IF;

    IF	l_del_rec.FREQUENCY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.FREQUENCY := NULL;
    END IF;

    IF	l_del_rec.ACQ_DOC_NUMBER = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ACQ_DOC_NUMBER := NULL;
    END IF;

    IF	l_del_rec.SUBMISSION_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.SUBMISSION_FLAG := NULL;
    END IF;

    IF	l_del_rec.DATA_ITEM_NAME = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DATA_ITEM_NAME := NULL;
    END IF;

    IF	l_del_rec.DATA_ITEM_SUBTITLE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DATA_ITEM_SUBTITLE := NULL;
    END IF;

    IF	l_del_rec.TOTAL_NUM_OF_COPIES = OKE_API.G_MISS_NUM THEN
	l_del_rec.TOTAL_NUM_OF_COPIES := NULL;
    END IF;

    IF	l_del_rec.CDRL_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CDRL_CATEGORY := NULL;
    END IF;

    IF	l_del_rec.EXPORT_LICENSE_NUM = OKE_API.G_MISS_CHAR THEN
   	l_del_rec.EXPORT_LICENSE_NUM := NULL;
    END IF;

    IF	l_del_rec.EXPORT_LICENSE_RES = OKE_API.G_MISS_CHAR THEN
	l_del_rec.EXPORT_LICENSE_RES := NULL;
    END IF;

    IF	l_del_rec.EXPORT_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.EXPORT_FLAG := NULL;
    END IF;

    IF	l_del_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_del_rec.CREATED_BY := NULL;
    END IF;

    IF	l_del_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_del_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_del_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_del_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_del_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_del_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE15 := NULL;
    END IF;



    IF l_del_rec.comments = OKE_API.G_MISS_CHAR THEN

       l_del_rec.comments := NULL;
    END IF;

    IF l_del_rec.weight = OKE_API.G_MISS_NUM THEN
       l_del_rec.weight := NULL;
    END IF;

    IF l_del_rec.weight_uom_code = OKE_API.G_MISS_CHAR THEN
       l_del_rec.weight_uom_code := NULL;
    END IF;

    IF l_del_rec.volume = OKE_API.G_MISS_NUM THEN
       l_del_rec.volume := NULL;
    END IF;

    IF l_del_rec.volume_uom_code = OKE_API.G_MISS_CHAR THEN
       l_del_rec.volume_uom_code := NULL;
    END IF;

    IF l_del_rec.expenditure_organization_id = OKE_API.G_MISS_NUM THEN
       l_del_rec.expenditure_organization_id := NULL;
    END IF;

    IF l_del_rec.expenditure_type = OKE_API.G_MISS_CHAR THEN
       l_del_rec.expenditure_type := NULL;
    END IF;

    IF l_del_rec.expenditure_item_date = OKE_API.G_MISS_DATE THEN
       l_del_rec.expenditure_item_date := NULL;
    END IF;

    IF l_del_rec.destination_type_code = OKE_API.G_MISS_CHAR THEN
       l_del_rec.destination_type_code := NULL;
    END IF;

    IF l_del_rec.rate_type = OKE_API.G_MISS_CHAR THEN
       l_del_rec.rate_type := NULL;
    END IF;

    IF l_del_rec.rate_date = OKE_API.G_MISS_DATE THEN
       l_del_rec.rate_date := NULL;
    END IF;

    IF l_del_rec.exchange_rate = OKE_API.G_MISS_NUM THEN
       l_del_rec.exchange_rate := NULL;
    END IF;

    IF l_del_rec.description = OKE_API.G_MISS_CHAR THEN
       l_del_rec.description := NULL;
    END IF;

    RETURN(l_del_rec);

  END null_out_defaults;

BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_del_rec := null_out_defaults(p_del_rec);

    IF p_del_rec.k_header_id IS NOT NULL AND
       p_del_rec.k_header_id <> OKE_API.G_MISS_NUM THEN

    	IF p_del_rec.inventory_org_id IS NULL
    	OR p_del_rec.inventory_org_id = OKE_API.G_MISS_NUM THEN
		OPEN get_inv_org;
		FETCH get_inv_org INTO l_del_rec.inventory_org_id;
		CLOSE get_inv_org;
    	END IF;


    	IF p_del_rec.direction IS NULL
    	OR p_del_rec.direction = OKE_API.G_MISS_CHAR THEN
		OPEN get_intent;
		FETCH get_intent INTO l_intent;
		CLOSE get_intent;
		IF l_intent = 'S' THEN
		   l_del_rec.direction := 'OUT';
		ELSE
		   l_del_rec.direction := 'IN';
		END IF;
    	END IF;

    END IF;


        -- Validate deliverable attributes
	OKE_CONTRACT_PUB.validate_deliverable(
			p_api_version		=>	p_api_version,
    			p_init_msg_list		=>	p_init_msg_list,
    			x_return_status		=>	x_return_status,
    			x_msg_count		=>	x_msg_count,
   			x_msg_data		=>	x_msg_data,
			p_del_rec		=>	l_del_rec);

    	If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif (x_return_status = OKE_API.G_RET_STS_ERROR) then
       		raise OKE_API.G_EXCEPTION_ERROR;
    	End If;



	OKE_CONTRACT_PUB.create_deliverable(
			p_api_version		=>	p_api_version,
    			p_init_msg_list		=>	p_init_msg_list,
    			x_return_status		=>	x_return_status,
    			x_msg_count		=>	x_msg_count,
   			x_msg_data		=>	x_msg_data,
			p_del_rec		=>	l_del_rec,
			x_del_rec		=>	x_del_rec);

    	If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif (x_return_status = OKE_API.G_RET_STS_ERROR) then
       		raise OKE_API.G_EXCEPTION_ERROR;
    	End If;


    OKE_API.END_ACTIVITY(       x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END create_deliverable;


FUNCTION validate_billing_method(p_bill_rec IN bill_rec_type) return VARCHAR2 IS

l_k_header_id		VARCHAR2(1) := '?';
l_billing_method_code 	VARCHAR2(1) := '?';
l_default_flag		VARCHAR2(1) := '?';

CURSOR c_k_header_id IS
select 'x'
from oke_k_headers
where k_header_id = p_bill_rec.k_header_id;

CURSOR c_billing_method_code IS
select 'x'
from oke_billing_methods_vl
where billing_method_code = p_bill_rec.billing_method_code;

BEGIN

	IF p_bill_rec.default_flag <>'N' AND p_bill_rec.default_flag <> 'Y' THEN
		return OKE_API.G_RET_STS_ERROR;
	END IF;

	OPEN c_k_header_id;
	FETCH c_k_header_id INTO l_k_header_id;
	CLOSE c_k_header_id;

	IF l_k_header_id = '?' THEN
		return OKE_API.G_RET_STS_ERROR;
	END IF;

	OPEN c_billing_method_code;
	FETCH c_billing_method_code INTO l_billing_method_code;
	CLOSE c_billing_method_code;

	IF l_billing_method_code = '?' THEN
		return OKE_API.G_RET_STS_ERROR;
	END IF;

	RETURN OKE_API.G_RET_STS_SUCCESS;

END validate_billing_method;


PROCEDURE define_billing_methods(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_bill_tbl			   IN bill_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'DEFINE_BILLING_METHODS';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKE_API.G_RET_STS_SUCCESS;

    i		NUMBER;
    l_flag	VARCHAR2(1);

    l_header_id NUMBER;

BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    l_flag := 'N';
    IF p_bill_tbl.COUNT > 0 THEN
    i:=p_bill_tbl.FIRST;
    l_header_id := p_bill_tbl(i).k_header_id;

    LOOP

      IF l_header_id <> p_bill_tbl(i).k_header_id THEN
	raise OKE_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_flag='Y' AND p_bill_tbl(i).default_flag='Y' THEN
	raise OKE_API.G_EXCEPTION_ERROR;
      ELSIF l_flag='Y' AND p_bill_tbl(i).default_flag='N' THEN
	null;
      ELSIF l_flag='N' AND p_bill_tbl(i).default_flag='Y' THEN
	l_flag:='Y';
      ELSE
	null;
      END IF;

    EXIT WHEN i = p_bill_tbl.LAST;
    i:=p_bill_tbl.NEXT(i);
    END LOOP;
    END IF;


    IF p_bill_tbl.COUNT > 0 THEN
    i:=p_bill_tbl.FIRST;
    LOOP



	l_return_status := validate_billing_method(p_bill_tbl(i));


	IF l_return_status = 'S' THEN

	insert into oke_k_billing_methods
	(
	k_header_id,
	billing_method_code,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	default_flag,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15
	)
	values
	(
	p_bill_tbl(i).k_header_id,
	p_bill_tbl(i).billing_method_code,
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	fnd_global.login_id,
	p_bill_tbl(i).default_flag,
	p_bill_tbl(i).attribute_category,
	p_bill_tbl(i).attribute1,
	p_bill_tbl(i).attribute2,
	p_bill_tbl(i).attribute3,
	p_bill_tbl(i).attribute4,
	p_bill_tbl(i).attribute5,
	p_bill_tbl(i).attribute6,
	p_bill_tbl(i).attribute7,
	p_bill_tbl(i).attribute8,
	p_bill_tbl(i).attribute9,
	p_bill_tbl(i).attribute10,
	p_bill_tbl(i).attribute11,
	p_bill_tbl(i).attribute12,
	p_bill_tbl(i).attribute13,
	p_bill_tbl(i).attribute14,
	p_bill_tbl(i).attribute15
);
	END IF;

    EXIT WHEN i = p_bill_tbl.LAST;
    i:=p_bill_tbl.NEXT(i);
    END LOOP;
    END IF;

    OKE_API.END_ACTIVITY(       x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END define_billing_methods;

PROCEDURE remove_billing_methods(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_bill_tbl			   IN bill_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'REMOVE_BILLING_METHODS';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKE_API.G_RET_STS_SUCCESS;

    i		NUMBER;

    l_header_id NUMBER;

    CURSOR c_check (p_header_id NUMBER, p_code VARCHAR2) IS
    select 'x' from oke_k_lines_v
    where billing_method_code = p_code
    and header_id = p_header_id;

    l_check VARCHAR2(1) := '?';

BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    IF p_bill_tbl.COUNT > 0 THEN
    i:=p_bill_tbl.FIRST;
    l_header_id := p_bill_tbl(i).k_header_id;

    LOOP

      IF l_header_id <> p_bill_tbl(i).k_header_id THEN
	raise OKE_API.G_EXCEPTION_ERROR;
      END IF;

    EXIT WHEN i = p_bill_tbl.LAST;
    i:=p_bill_tbl.NEXT(i);
    END LOOP;
    END IF;


    IF p_bill_tbl.COUNT > 0 THEN
    i:=p_bill_tbl.FIRST;
    LOOP

     IF p_bill_tbl(i).k_header_id <> OKE_API.G_MISS_NUM
      AND p_bill_tbl(i).k_header_id is not null
      AND p_bill_tbl(i).billing_method_code <> OKE_API.G_MISS_CHAR
      AND p_bill_tbl(i).billing_method_code is not null THEN

	l_check := '?';
	OPEN c_check(p_bill_tbl(i).k_header_id,
		p_bill_tbl(i).billing_method_code);
	FETCH c_check INTO l_check;
	CLOSE c_check;

	IF l_check <> 'x' THEN
	  delete from oke_k_billing_methods
	  where k_header_id = p_bill_tbl(i).k_header_id
	  and billing_method_code = p_bill_tbl(i).billing_method_code;
	END IF;
     END IF;
    EXIT WHEN i = p_bill_tbl.LAST;
    i:=p_bill_tbl.NEXT(i);
    END LOOP;
    END IF;

    OKE_API.END_ACTIVITY(       x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END remove_billing_methods;

  PROCEDURE create_line_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_cimv_rec			   IN  cimv_rec_type,
    x_cimv_rec			   OUT NOCOPY  cimv_rec_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_LINE_ITEM';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKE_API.G_RET_STS_SUCCESS;

  l_cimv_tbl_in     okc_contract_item_pub.cimv_tbl_type;

  l_cimv_tbl_out    okc_contract_item_pub.cimv_tbl_type;

BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_cimv_tbl_in(1).ID := p_cimv_rec.ID;
    l_cimv_tbl_in(1).OBJECT_VERSION_NUMBER := p_cimv_rec.OBJECT_VERSION_NUMBER;
    l_cimv_tbl_in(1).CHR_ID := p_cimv_rec.CHR_ID;
    l_cimv_tbl_in(1).CLE_ID := p_cimv_rec.CLE_ID;
    l_cimv_tbl_in(1).CLE_ID_FOR := p_cimv_rec.CLE_ID_FOR;
    l_cimv_tbl_in(1).DNZ_CHR_ID := p_cimv_rec.DNZ_CHR_ID;
    l_cimv_tbl_in(1).EXCEPTION_YN := p_cimv_rec.EXCEPTION_YN;
    l_cimv_tbl_in(1).PRICED_ITEM_YN := p_cimv_rec.PRICED_ITEM_YN;
    l_cimv_tbl_in(1).OBJECT1_ID1 := p_cimv_rec.OBJECT1_ID1;
    l_cimv_tbl_in(1).OBJECT1_ID2 := p_cimv_rec.OBJECT1_ID2;
    l_cimv_tbl_in(1).JTOT_OBJECT1_CODE := p_cimv_rec.JTOT_OBJECT1_CODE;
    l_cimv_tbl_in(1).UOM_CODE := p_cimv_rec.UOM_CODE;
    l_cimv_tbl_in(1).NUMBER_OF_ITEMS := p_cimv_rec.NUMBER_OF_ITEMS;
    l_cimv_tbl_in(1).CREATED_BY := p_cimv_rec.CREATED_BY;
    l_cimv_tbl_in(1).CREATION_DATE := p_cimv_rec.CREATION_DATE;
    l_cimv_tbl_in(1).LAST_UPDATED_BY := p_cimv_rec.LAST_UPDATED_BY;
    l_cimv_tbl_in(1).LAST_UPDATE_DATE := p_cimv_rec.LAST_UPDATE_DATE;
    l_cimv_tbl_in(1).LAST_UPDATE_LOGIN := p_cimv_rec.LAST_UPDATE_LOGIN;
    l_cimv_tbl_in(1).UPG_ORIG_SYSTEM_REF := p_cimv_rec.UPG_ORIG_SYSTEM_REF;
    l_cimv_tbl_in(1).UPG_ORIG_SYSTEM_REF_ID := p_cimv_rec.UPG_ORIG_SYSTEM_REF_ID;

    okc_contract_item_pub.create_contract_item
    ( p_api_version      => l_api_version
    , p_init_msg_list    => p_init_msg_list
    , x_return_status    => l_return_status
    , x_msg_count        => x_msg_count
    , x_msg_data         => x_msg_data
    , p_cimv_tbl         => l_cimv_tbl_in
    , x_cimv_tbl         => l_cimv_tbl_out
    );

    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    x_cimv_rec.ID := l_cimv_tbl_out(1).ID;
    x_cimv_rec.OBJECT_VERSION_NUMBER := l_cimv_tbl_out(1).OBJECT_VERSION_NUMBER;
    x_cimv_rec.CHR_ID := l_cimv_tbl_out(1).CHR_ID;
    x_cimv_rec.CLE_ID := l_cimv_tbl_out(1).CLE_ID;
    x_cimv_rec.CLE_ID_FOR := l_cimv_tbl_out(1).CLE_ID_FOR;
    x_cimv_rec.DNZ_CHR_ID := l_cimv_tbl_out(1).DNZ_CHR_ID;
    x_cimv_rec.EXCEPTION_YN := l_cimv_tbl_out(1).EXCEPTION_YN;
    x_cimv_rec.PRICED_ITEM_YN := l_cimv_tbl_out(1).PRICED_ITEM_YN;
    x_cimv_rec.OBJECT1_ID1 := l_cimv_tbl_out(1).OBJECT1_ID1;
    x_cimv_rec.OBJECT1_ID2 := l_cimv_tbl_out(1).OBJECT1_ID2;
    x_cimv_rec.JTOT_OBJECT1_CODE := l_cimv_tbl_out(1).JTOT_OBJECT1_CODE;
    x_cimv_rec.UOM_CODE := l_cimv_tbl_out(1).UOM_CODE;
    x_cimv_rec.NUMBER_OF_ITEMS := l_cimv_tbl_out(1).NUMBER_OF_ITEMS;
    x_cimv_rec.CREATED_BY := l_cimv_tbl_out(1).CREATED_BY;
    x_cimv_rec.CREATION_DATE := l_cimv_tbl_out(1).CREATION_DATE;
    x_cimv_rec.LAST_UPDATED_BY := l_cimv_tbl_out(1).LAST_UPDATED_BY;
    x_cimv_rec.LAST_UPDATE_DATE := l_cimv_tbl_out(1).LAST_UPDATE_DATE;
    x_cimv_rec.LAST_UPDATE_LOGIN := l_cimv_tbl_out(1).LAST_UPDATE_LOGIN;
    x_cimv_rec.UPG_ORIG_SYSTEM_REF := l_cimv_tbl_out(1).UPG_ORIG_SYSTEM_REF;
    x_cimv_rec.UPG_ORIG_SYSTEM_REF_ID := l_cimv_tbl_out(1).UPG_ORIG_SYSTEM_REF_ID;

    OKE_API.END_ACTIVITY(       x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END create_line_item;

END OKE_IMPORT_CONTRACT_PUB;


/
