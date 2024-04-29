--------------------------------------------------------
--  DDL for Package Body OKE_KCOPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_KCOPY_PKG" AS
/*$Header: OKEKCPYB.pls 120.6.12000000.2 2007/02/21 09:25:56 nnadahal ship $ */

     g_api_type		CONSTANT VARCHAR2(4) := '_PKG';
     g_projh_overlap_allowed VARCHAR2(30);
     g_pty_not_copied BOOLEAN;

    function    get_cimv_rec(p_cim_id in number,
		x_cimv_rec out nocopy cimv_rec_type,
		p_from_cle_id in number) return  varchar2 is

      l_return_status	        varchar2(1) := oke_api.g_ret_sts_success;
      l_no_data_found 		boolean := true;
      l_line_number		varchar2(150);

      cursor c_cimv_rec is
      select	id,
		cle_id,
		chr_id,
		cle_id_for,
		dnz_chr_id,
		object1_id1,
		object1_id2,
		jtot_object1_code,
		uom_code,
		exception_yn,
		number_of_items,
                priced_item_yn
	from    okc_k_items_v
	where 	id = p_cim_id;

    begin

      open c_cimv_rec;
      fetch c_cimv_rec
      into	x_cimv_rec.id,
		x_cimv_rec.cle_id,
		x_cimv_rec.chr_id,
		x_cimv_rec.cle_id_for,
		x_cimv_rec.dnz_chr_id,
		x_cimv_rec.object1_id1,
		x_cimv_rec.object1_id2,
		x_cimv_rec.jtot_object1_code,
		x_cimv_rec.uom_code,
		x_cimv_rec.exception_yn,
		x_cimv_rec.number_of_items,
		x_cimv_rec.priced_item_yn;


      l_no_data_found := c_cimv_rec%notfound;
      close c_cimv_rec;
      if l_no_data_found then
        l_return_status := oke_api.g_ret_sts_error;
        return(l_return_status);
      else
        return(l_return_status);
      end if;
    exception
      when others then
        -- store sql error message on message stack for caller

	select line_number into l_line_number
	from oke_k_lines_v
	where k_line_id=p_from_cle_id;
	oke_api.set_message   (
                p_app_name              =>'OKE',
                p_msg_name              =>'OKE_KCOPY_ITEMS',
                p_token1                =>'LINE',
                p_token1_value          =>l_line_number);

        -- notify caller of an unexpected error
        l_return_status := oke_api.g_ret_sts_unexp_error;
        return(l_return_status);

    end get_cimv_rec;




procedure get_status( code out nocopy varchar2) is
    l_sts_code varchar2(30);
    cursor l_sts_csr is
      select code
      from okc_statuses_v
      where ste_code = 'ENTERED'
      and default_yn = 'Y'
      and sysdate between start_date and nvl(end_date,sysdate);
begin

    	open l_sts_csr;
    	fetch l_sts_csr into l_sts_code;
    	close l_sts_csr;
	code := l_sts_code;
  exception
    when no_data_found then
      if (l_sts_csr%isopen) then
        close l_sts_csr;
       end if;
       code :='ENTERED';

end get_status;




  procedure copy_items(
    p_api_version                  in number,
    p_init_msg_list                in varchar2 default oke_api.g_false,
    x_return_status                out nocopy varchar2,
    x_msg_count                    out nocopy number,
    x_msg_data                     out nocopy varchar2,
    p_from_cle_id                  in number,
    p_copy_reference               in varchar2 default 'COPY',
    p_to_cle_id                    in number default oke_api.g_miss_num) is

    l_num number;

    l_cimv_rec 	cimv_rec_type;
    x_cimv_rec 	cimv_rec_type;

    l_return_status	        varchar2(1) := oke_api.g_ret_sts_success;
    l_dnz_chr_id		number := oke_api.g_miss_num;
    l_price_level_ind   	varchar2(20);
    l_item_name         	varchar2(2000);
    l_item_desc         	varchar2(2000);
    l_api_name		constant varchar2(30) := 'COPY_ITEMS';
    l_api_version	constant number	  := 1.0;

    cursor c_dnz_chr_id is
    select dnz_chr_id,price_level_ind
    from okc_k_lines_b
    where id = p_to_cle_id;

    cursor c_cimv is
    select id
    from okc_k_items
    where cle_id = p_from_cle_id;

  begin
    x_return_status := oke_api.g_ret_sts_success;
    l_return_status := oke_api.start_activity(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    if (l_return_status = oke_api.g_ret_sts_unexp_error) then
       raise oke_api.g_exception_unexpected_error;
    elsif (l_return_status = oke_api.g_ret_sts_error) then
       raise oke_api.g_exception_error;
    end if;




    open c_dnz_chr_id;
    fetch c_dnz_chr_id into l_dnz_chr_id,l_price_level_ind;
    close c_dnz_chr_id;


    open c_cimv;
    loop
    fetch c_cimv into l_num;
    exit when c_cimv%notfound;
      l_return_status := get_cimv_rec(	p_cim_id 	=> l_num,
					x_cimv_rec 	=> l_cimv_rec,
					p_from_cle_id	=> p_from_cle_id);
     if l_return_status= oke_api.g_ret_sts_success then

      l_cimv_rec.cle_id := p_to_cle_id;
      l_cimv_rec.dnz_chr_id := l_dnz_chr_id;
	 if p_copy_reference = 'REFERENCE' then
	   l_cimv_rec.cle_id_for := p_from_cle_id;
	   l_cimv_rec.chr_id := null;
	 else
	   l_cimv_rec.cle_id_for := null;
	 end if;

	 if l_price_level_ind = 'N' then
        l_cimv_rec.priced_item_yn := 'N';
	 end if;

      okc_contract_item_pub.create_contract_item(
	      p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cimv_rec		=> l_cimv_rec,
           x_cimv_rec		=> x_cimv_rec);

      if (l_return_status <> oke_api.g_ret_sts_success) then
        if (l_return_status = oke_api.g_ret_sts_unexp_error) then
          x_return_status := l_return_status;
 		raise oke_api.g_exception_unexpected_error;
        else
             x_return_status := l_return_status;
        end if;
      end if;
     end if;

    end loop;
    close c_cimv;

   oke_api.end_activity(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  exception
    when oke_api.g_exception_error then
      x_return_status := oke_api.handle_exceptions(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when oke_api.g_exception_unexpected_error then
      x_return_status := oke_api.handle_exceptions(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when others then
      x_return_status := oke_api.handle_exceptions(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  end copy_items;

  -- copy the user attributes  (header)

  procedure copy_user_attributes( p_k_header_id     in number	,
  				  p_k_header_id_new in number) is

     cursor oke_user_attributes_cur is
       select *
       from   oke_k_user_attributes
       where  k_header_id = p_k_header_id
       and    k_line_id is null;

     l_user_att_rec  		 oke_k_user_attributes%rowtype;
     l_row_id	    		 varchar2(5000);
     l_k_user_attribute_id	 oke_k_user_attributes.k_user_attribute_id%type;
     l_record_version_number	 oke_k_user_attributes.record_version_number%type;

  begin

     open oke_user_attributes_cur;
     loop

        fetch oke_user_attributes_cur into l_user_att_rec;
        exit when oke_user_attributes_cur%notfound;

        oke_k_user_attributes_pkg.insert_row
        (x_rowid				=>	l_row_id			,
         x_k_user_attribute_id			=>	l_k_user_attribute_id		,
         x_record_version_number		=>	l_record_version_number		,
         x_creation_date			=>	sysdate				,
         x_created_by				=>	fnd_global.user_id		,
         x_last_update_date			=>	sysdate				,
         x_last_updated_by			=>	fnd_global.user_id		,
         x_last_update_login			=>	fnd_global.login_id		,
         x_k_header_id				=>	p_k_header_id_new		,
         x_k_line_id				=>	l_user_att_rec.k_line_id	,
         x_user_attribute_context		=>	l_user_att_rec.user_attribute_context	,
         x_user_attribute01			=>	l_user_att_rec.user_attribute01	,
         x_user_attribute02			=>	l_user_att_rec.user_attribute02	,
         x_user_attribute03			=>	l_user_att_rec.user_attribute03	,
         x_user_attribute04			=>	l_user_att_rec.user_attribute04	,
         x_user_attribute05			=>	l_user_att_rec.user_attribute05	,
         x_user_attribute06			=>	l_user_att_rec.user_attribute06	,
         x_user_attribute07			=>	l_user_att_rec.user_attribute07	,
         x_user_attribute08			=>	l_user_att_rec.user_attribute08	,
         x_user_attribute09			=>	l_user_att_rec.user_attribute09	,
         x_user_attribute10			=>	l_user_att_rec.user_attribute10	,
 	 x_user_attribute11			=>	l_user_att_rec.user_attribute11	,
         x_user_attribute12			=>	l_user_att_rec.user_attribute12	,
         x_user_attribute13			=>	l_user_att_rec.user_attribute13	,
         x_user_attribute14			=>	l_user_att_rec.user_attribute14	,
         x_user_attribute15			=>	l_user_att_rec.user_attribute15	,
         x_user_attribute16			=>	l_user_att_rec.user_attribute16	,
         x_user_attribute17			=>	l_user_att_rec.user_attribute17	,
         x_user_attribute18			=>	l_user_att_rec.user_attribute18	,
         x_user_attribute19			=>	l_user_att_rec.user_attribute19	,
         x_user_attribute20			=>	l_user_att_rec.user_attribute20	,
         x_user_attribute21			=>	l_user_att_rec.user_attribute21	,
         x_user_attribute22			=>	l_user_att_rec.user_attribute22	,
         x_user_attribute23			=>	l_user_att_rec.user_attribute23	,
         x_user_attribute24			=>	l_user_att_rec.user_attribute24	,
         x_user_attribute25			=>	l_user_att_rec.user_attribute25	,
         x_user_attribute26			=>	l_user_att_rec.user_attribute26	,
         x_user_attribute27			=>	l_user_att_rec.user_attribute27	,
         x_user_attribute28			=>	l_user_att_rec.user_attribute28	,
         x_user_attribute29			=>	l_user_att_rec.user_attribute29	,
         x_user_attribute30			=>	l_user_att_rec.user_attribute30
         );

      end loop;
      close oke_user_attributes_cur;
   end copy_user_attributes;


  -- copy the user attributes  (line)

  procedure copy_user_attr_line( p_k_header_id 		in number	,
  				 p_k_header_id_new	in number       ,
  				 p_k_line_id		in number	,
  				 p_k_line_id_new	in number       ) is
     cursor oke_user_attributes_cur2 is
       select *
       from   oke_k_user_attributes
       where  k_header_id = p_k_header_id
       and    k_line_id = p_k_line_id;

     l_user_att_rec  		 oke_k_user_attributes%rowtype;
     l_row_id	    		 varchar2(5000);
     l_k_user_attribute_id	 oke_k_user_attributes.k_user_attribute_id%type;
     l_record_version_number	 oke_k_user_attributes.record_version_number%type;

  begin

     open oke_user_attributes_cur2;
     loop

        fetch oke_user_attributes_cur2 into l_user_att_rec;
        exit when oke_user_attributes_cur2%notfound;

        oke_k_user_attributes_pkg.insert_row
        (x_rowid				=>	l_row_id			,
         x_k_user_attribute_id			=>	l_k_user_attribute_id		,
         x_record_version_number		=>	l_record_version_number		,
         x_creation_date			=>	sysdate				,
         x_created_by				=>	fnd_global.user_id		,
         x_last_update_date			=>	sysdate				,
         x_last_updated_by			=>	fnd_global.user_id		,
         x_last_update_login			=>	fnd_global.login_id		,
         x_k_header_id				=>	p_k_header_id_new		,
         x_k_line_id				=>	p_k_line_id_new			,
         x_user_attribute_context		=>	l_user_att_rec.user_attribute_context	,
         x_user_attribute01			=>	l_user_att_rec.user_attribute01	,
         x_user_attribute02			=>	l_user_att_rec.user_attribute02	,
         x_user_attribute03			=>	l_user_att_rec.user_attribute03	,
         x_user_attribute04			=>	l_user_att_rec.user_attribute04	,
         x_user_attribute05			=>	l_user_att_rec.user_attribute05	,
         x_user_attribute06			=>	l_user_att_rec.user_attribute06	,
         x_user_attribute07			=>	l_user_att_rec.user_attribute07	,
         x_user_attribute08			=>	l_user_att_rec.user_attribute08	,
         x_user_attribute09			=>	l_user_att_rec.user_attribute09	,
         x_user_attribute10			=>	l_user_att_rec.user_attribute10	,
 	 x_user_attribute11			=>	l_user_att_rec.user_attribute11	,
         x_user_attribute12			=>	l_user_att_rec.user_attribute12	,
         x_user_attribute13			=>	l_user_att_rec.user_attribute13	,
         x_user_attribute14			=>	l_user_att_rec.user_attribute14	,
         x_user_attribute15			=>	l_user_att_rec.user_attribute15	,
         x_user_attribute16			=>	l_user_att_rec.user_attribute16	,
         x_user_attribute17			=>	l_user_att_rec.user_attribute17	,
         x_user_attribute18			=>	l_user_att_rec.user_attribute18	,
         x_user_attribute19			=>	l_user_att_rec.user_attribute19	,
         x_user_attribute20			=>	l_user_att_rec.user_attribute20	,
         x_user_attribute21			=>	l_user_att_rec.user_attribute21	,
         x_user_attribute22			=>	l_user_att_rec.user_attribute22	,
         x_user_attribute23			=>	l_user_att_rec.user_attribute23	,
         x_user_attribute24			=>	l_user_att_rec.user_attribute24	,
         x_user_attribute25			=>	l_user_att_rec.user_attribute25	,
         x_user_attribute26			=>	l_user_att_rec.user_attribute26	,
         x_user_attribute27			=>	l_user_att_rec.user_attribute27	,
         x_user_attribute28			=>	l_user_att_rec.user_attribute28	,
         x_user_attribute29			=>	l_user_att_rec.user_attribute29	,
         x_user_attribute30			=>	l_user_att_rec.user_attribute30
         );

      end loop;
      close oke_user_attributes_cur2;
   end copy_user_attr_line;

/*-------------------------------------------------------------------------
 procedure get_oke_k_header_rec - get oke contract header information from
			 oke_k_headers
--------------------------------------------------------------------------*/

procedure get_oke_k_header_rec(	p_k_header_id in number,
				x_chr_rec out nocopy oke_chr_pvt.chr_rec_type,
				x_result out nocopy varchar2) is

  cursor oke_chr_pk_csr is
  select
	k_header_id,
	program_id,
 	project_id,
	boa_id,
        k_type_code,
	priority_code,
	prime_k_alias,
	prime_k_number,
	authorize_date,
	authorizing_reason,
	award_cancel_date,
	award_date,
	date_definitized,
	date_issued,
	date_negotiated,
	date_received,
	date_sign_by_contractor,
	date_sign_by_customer,
	faa_approve_date,
	faa_reject_date,
	booked_flag,
	open_flag,
	cfe_flag,
	vat_code,
	country_of_origin_code,
	export_flag,
	human_subject_flag,
	cqa_flag,
	interim_rpt_req_flag,
	no_competition_authorize,
	penalty_clause_flag,
	product_line_code,
	reporting_flag,
	sb_plan_req_flag,
	sb_report_flag,
	nte_amount,
	nte_warning_flag,
	bill_without_def_flag,
	cas_flag,
	classified_flag,
	client_approve_req_flag,
	cost_of_money,
	dcaa_audit_req_flag,
	cost_share_flag,
	oh_rates_final_flag,
	prop_delivery_location,
	prop_due_date_time,
	prop_expire_date,
	copies_required,
	sic_code,
	tech_data_wh_rate,
	progress_payment_flag,
	progress_payment_liq_rate,
	progress_payment_rate,
	alternate_liquidation_rate,
	prop_due_time,
	definitized_flag,
	financial_ctrl_verified_flag,
	cost_of_sale_rate,
	created_by,
	creation_date,
	last_updated_by,
	last_update_login,
	last_update_date,
--	line_value_total,
--	undef_line_value_total,
--	end_date,
	owning_organization_id,
	default_task_id

  from oke_k_headers
  where k_header_id = p_k_header_id;


begin

  open oke_chr_pk_csr;
  fetch oke_chr_pk_csr into
	x_chr_rec.k_header_id,
	x_chr_rec.program_id,
 	x_chr_rec.project_id,
	x_chr_rec.boa_id,
        x_chr_rec.k_type_code,
	x_chr_rec.priority_code,
	x_chr_rec.prime_k_alias,
	x_chr_rec.prime_k_number,
	x_chr_rec.authorize_date,
	x_chr_rec.authorizing_reason,
	x_chr_rec.award_cancel_date,
	x_chr_rec.award_date,
	x_chr_rec.date_definitized,
	x_chr_rec.date_issued,
	x_chr_rec.date_negotiated,
	x_chr_rec.date_received,
	x_chr_rec.date_sign_by_contractor,
	x_chr_rec.date_sign_by_customer,
	x_chr_rec.faa_approve_date,
	x_chr_rec.faa_reject_date,
	x_chr_rec.booked_flag,
	x_chr_rec.open_flag,
	x_chr_rec.cfe_flag,
	x_chr_rec.vat_code,
	x_chr_rec.country_of_origin_code,
	x_chr_rec.export_flag,
	x_chr_rec.human_subject_flag,
	x_chr_rec.cqa_flag,
	x_chr_rec.interim_rpt_req_flag,
	x_chr_rec.no_competition_authorize,
	x_chr_rec.penalty_clause_flag,
	x_chr_rec.product_line_code,
	x_chr_rec.reporting_flag,
	x_chr_rec.sb_plan_req_flag,
	x_chr_rec.sb_report_flag,
	x_chr_rec.nte_amount,
	x_chr_rec.nte_warning_flag,
	x_chr_rec.bill_without_def_flag,
	x_chr_rec.cas_flag,
	x_chr_rec.classified_flag,
	x_chr_rec.client_approve_req_flag,
	x_chr_rec.cost_of_money,
	x_chr_rec.dcaa_audit_req_flag,
	x_chr_rec.cost_share_flag,
	x_chr_rec.oh_rates_final_flag,
	x_chr_rec.prop_delivery_location,
	x_chr_rec.prop_due_date_time,
	x_chr_rec.prop_expire_date,
	x_chr_rec.copies_required,
	x_chr_rec.sic_code,
	x_chr_rec.tech_data_wh_rate,
	x_chr_rec.progress_payment_flag,
	x_chr_rec.progress_payment_liq_rate,
	x_chr_rec.progress_payment_rate,
	x_chr_rec.alternate_liquidation_rate,
	x_chr_rec.prop_due_time,
	x_chr_rec.definitized_flag,
	x_chr_rec.financial_ctrl_verified_flag,
	x_chr_rec.cost_of_sale_rate,
	x_chr_rec.created_by,
	x_chr_rec.creation_date,
	x_chr_rec.last_updated_by,
	x_chr_rec.last_update_login,
	x_chr_rec.last_update_date,
--	x_chr_rec.line_value_total,
--	x_chr_rec.undef_line_value_total,
--	x_chr_rec.end_date,
	x_chr_rec.owning_organization_id,
	x_chr_rec.default_task_id;


  if oke_chr_pk_csr%notfound then
	x_result := oke_api.g_ret_sts_error;
  end if;

  close oke_chr_pk_csr;



end get_oke_k_header_rec;


/*-------------------------------------------------------------------------
 procedure get_okc_k_header_rec - get okc contract header information from
			 okc_k_headers_v
--------------------------------------------------------------------------*/
procedure get_okc_k_header_rec(	p_k_header_id in number,
				x_chrv_rec out nocopy okc_chr_pvt.chrv_rec_type,
				x_result out nocopy varchar2) is

    cursor okc_chrv_pk_csr is
    select
            id,
            object_version_number,
            sfwt_flag,
            chr_id_response,
            chr_id_award,
--	    chr_id_renewed,
	    inv_organization_id,
            sts_code,
            qcl_id,
            scs_code,
            contract_number,
            currency_code,
            contract_number_modifier,
            archived_yn,
            deleted_yn,
            cust_po_number_req_yn,
            pre_pay_req_yn,
            cust_po_number,
            short_description,
            comments,
            description,
            dpas_rating,
            cognomen,
            template_yn,
            template_used,
            date_approved,
            datetime_cancelled,
            auto_renew_days,
            date_issued,
            datetime_responded,
            non_response_reason,
            non_response_explain,
            rfp_type,
            chr_type,
            keep_on_mail_list,
            set_aside_reason,
            set_aside_percent,
            response_copies_req,
            date_close_projected,
            datetime_proposed,
            date_signed,
            date_terminated,
            date_renewed,
            trn_code,
            start_date,
            end_date,
            authoring_org_id,
            buy_or_sell,
            issue_or_receive,
	    estimated_amount,
--            chr_id_renewed_to,
            estimated_amount_renewed,
            currency_code_renewed,
	    upg_orig_system_ref,
	    upg_orig_system_ref_id,
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
            attribute15,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
      from okc_k_headers_v
     where okc_k_headers_v.id   = p_k_header_id;

begin

    open okc_chrv_pk_csr;
    fetch okc_chrv_pk_csr into
              x_chrv_rec.id,
              x_chrv_rec.object_version_number,
              x_chrv_rec.sfwt_flag,
              x_chrv_rec.chr_id_response,
              x_chrv_rec.chr_id_award,
--	      x_chrv_rec.chr_id_renewed,
	      x_chrv_rec.inv_organization_id,
              x_chrv_rec.sts_code,
              x_chrv_rec.qcl_id,
              x_chrv_rec.scs_code,
              x_chrv_rec.contract_number,
              x_chrv_rec.currency_code,
              x_chrv_rec.contract_number_modifier,
              x_chrv_rec.archived_yn,
              x_chrv_rec.deleted_yn,
              x_chrv_rec.cust_po_number_req_yn,
              x_chrv_rec.pre_pay_req_yn,
              x_chrv_rec.cust_po_number,
              x_chrv_rec.short_description,
              x_chrv_rec.comments,
              x_chrv_rec.description,
              x_chrv_rec.dpas_rating,
              x_chrv_rec.cognomen,
              x_chrv_rec.template_yn,
              x_chrv_rec.template_used,
              x_chrv_rec.date_approved,
              x_chrv_rec.datetime_cancelled,
              x_chrv_rec.auto_renew_days,
              x_chrv_rec.date_issued,
              x_chrv_rec.datetime_responded,
              x_chrv_rec.non_response_reason,
              x_chrv_rec.non_response_explain,
              x_chrv_rec.rfp_type,
              x_chrv_rec.chr_type,
              x_chrv_rec.keep_on_mail_list,
              x_chrv_rec.set_aside_reason,
              x_chrv_rec.set_aside_percent,
              x_chrv_rec.response_copies_req,
              x_chrv_rec.date_close_projected,
              x_chrv_rec.datetime_proposed,
              x_chrv_rec.date_signed,
              x_chrv_rec.date_terminated,
              x_chrv_rec.date_renewed,
              x_chrv_rec.trn_code,
              x_chrv_rec.start_date,
              x_chrv_rec.end_date,
              x_chrv_rec.authoring_org_id,
              x_chrv_rec.buy_or_sell,
              x_chrv_rec.issue_or_receive,
	      x_chrv_rec.estimated_amount,
--              x_chrv_rec.chr_id_renewed_to,
              x_chrv_rec.estimated_amount_renewed,
              x_chrv_rec.currency_code_renewed,
	      x_chrv_rec.upg_orig_system_ref,
	      x_chrv_rec.upg_orig_system_ref_id,
              x_chrv_rec.attribute_category,
              x_chrv_rec.attribute1,
              x_chrv_rec.attribute2,
              x_chrv_rec.attribute3,
              x_chrv_rec.attribute4,
              x_chrv_rec.attribute5,
              x_chrv_rec.attribute6,
              x_chrv_rec.attribute7,
              x_chrv_rec.attribute8,
              x_chrv_rec.attribute9,
              x_chrv_rec.attribute10,
              x_chrv_rec.attribute11,
              x_chrv_rec.attribute12,
              x_chrv_rec.attribute13,
              x_chrv_rec.attribute14,
              x_chrv_rec.attribute15,
              x_chrv_rec.created_by,
              x_chrv_rec.creation_date,
              x_chrv_rec.last_updated_by,
              x_chrv_rec.last_update_date,
              x_chrv_rec.last_update_login;


  	if okc_chrv_pk_csr%notfound then
	x_result := oke_api.g_ret_sts_error;
  	end if;

    close okc_chrv_pk_csr;

end get_okc_k_header_rec;




/*---------------------------------------------------------------------------------------
 procedure copy_header_party_roles
-----------------------------------------------------------------------------------------*/

procedure copy_party_roles(p_api_version         in number,
    			  p_init_msg_list       in varchar2,
    			  x_return_status       out nocopy varchar2,
    			  x_msg_count           out nocopy number,
    			  x_msg_data            out nocopy varchar2,
			   f_k_header_id 	in number,  -- orig okc_k_headers_b.id
			   n_k_header_id 	in number,  -- new okc_k_headers_b.id
			   f_k_line_id 		in number,  -- orig okc_k_lines_b.id
			   n_k_line_id 		in number,  -- new okc_k_lines_b.id
			   p_k_header_id	in number   -- original header id, must provide, cannot be null
			  	) is

    x_pty_id	number;  -- new party id returned from api call
    l_return_status	varchar2(1)		  := oke_api.g_ret_sts_success;
    l_api_name		constant varchar2(30) := 'COPY_PARTY_ROLES';
    l_api_version	constant number	  := 1.0;


-- declare party cursor refer to contract headers
cursor hdr_pty_csr is
	select  id,jtot_object1_code
        from okc_k_party_roles_b
        where okc_k_party_roles_b.dnz_chr_id = f_k_header_id
	and okc_k_party_roles_b.chr_id is not null
	and okc_k_party_roles_b.cle_id is null;

-- declare party cursor refer to contract lines
cursor cle_pty_csr is
	select  id
        from okc_k_party_roles_b
        where okc_k_party_roles_b.cle_id = f_k_line_id
	and okc_k_party_roles_b.dnz_chr_id = p_k_header_id
	and okc_k_party_roles_b.chr_id is null;

TYPE id_list_tbl_type  is table of number index by binary_integer;
id_list 	id_list_tbl_type;
i 		number;
sql_stmt 	varchar2(4000);

begin
    x_return_status := oke_api.g_ret_sts_success;                                 -- call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := oke_api.start_activity(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    if (l_return_status = oke_api.g_ret_sts_unexp_error) then
       raise oke_api.g_exception_unexpected_error;
    elsif (l_return_status = oke_api.g_ret_sts_error) then
       raise oke_api.g_exception_error;
    end if;
-- bug 4388335
OKE_GLOBALS.Set_Globals
( p_k_header_id => n_k_header_id
);

    i:=0;

   if f_k_line_id is null then   -- copy party_roles for contract header
    	FOR pty IN hdr_pty_csr LOOP

		sql_stmt := OKC_UTIL.GET_SQL_FROM_JTFV(pty.jtot_object1_code);

		IF INSTR(UPPER(sql_stmt),'OKE_GLOBALS.K_HEADER_ID') = 0 THEN
		-- copy contract party_roles

		    OKC_COPY_CONTRACT_PUB.copy_party_roles(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> l_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_cpl_id		=> pty.id,
			p_cle_id		=> null,
      			p_chr_id		=> n_k_header_id,
      			p_rle_code		=> null,
			x_cpl_id		=> x_pty_id);

      If l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
        g_pty_not_copied := TRUE;
 		  End If;

		ELSE
			i:=i+1;
			id_list(i) := pty.id;
		END IF;
    	   END LOOP;

	   FOR j in 1..i LOOP

		    OKC_COPY_CONTRACT_PUB.copy_party_roles(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> l_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_cpl_id		=> id_list(j),
			p_cle_id		=> null,
      			p_chr_id		=> n_k_header_id,
      			p_rle_code		=> null,
			x_cpl_id		=> x_pty_id);

      If l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
        g_pty_not_copied := TRUE;
 		  End If;

	     END LOOP;

   ELSIF f_k_header_id is null THEN  -- copy party_roles for contract line
       FOR pty IN cle_pty_csr LOOP

		-- Copy line party_roles
		OKC_COPY_CONTRACT_PUB.copy_party_roles(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> l_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_cpl_id		=> pty.id,
			p_cle_id		=> n_k_line_id,
      			p_chr_id		=> null,
      			p_rle_code		=> null,
			x_cpl_id		=> x_pty_id);

      If l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
        g_pty_not_copied := TRUE;
 		  End If;

      	END LOOP;
   END IF;

   OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
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

end copy_party_roles;

/*---------------------------------------------------------------------------------------
 PROCEDURE COPY_ARTICLES
-----------------------------------------------------------------------------------------*/

PROCEDURE copy_articles(p_api_version         IN NUMBER,
    			  p_init_msg_list       IN VARCHAR2,
    			  x_return_status       OUT NOCOPY VARCHAR2,
    			  x_msg_count           OUT NOCOPY NUMBER,
    			  x_msg_data            OUT NOCOPY VARCHAR2,
			f_k_header_id 	IN NUMBER,  -- Orig OKC_K_HEADERS_B.id
			n_k_header_id 	IN NUMBER,  -- New OKC_K_HEADERS_B.id
			f_k_line_id 	IN NUMBER,  -- Orig OKC_K_LINES_B.id
			n_k_line_id 	IN NUMBER   -- New OKC_K_LINES_B.id
		  	) IS

l_cat_id	NUMBER;	 -- Old ARTICLE ID
x_cat_id	NUMBER;  -- New ARTICLE ID
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_api_name		CONSTANT VARCHAR2(30) := 'COPY_ARTICLES';
    l_api_version	CONSTANT NUMBER	  := 1.0;


-- DECLARE ARTICLE cursor refer to contract headers
CURSOR hdr_art_csr IS
	SELECT  ID
        FROM OKC_K_ARTICLES_B
        WHERE OKC_K_ARTICLES_B.DNZ_CHR_ID = f_k_header_id
	AND OKC_K_ARTICLES_B.CHR_ID is not null
	AND OKC_K_ARTICLES_B.CLE_ID is null;

-- DECLARE ARTICLE cursor refer to contract lines
CURSOR cle_art_csr IS
	SELECT  ID
        FROM OKC_K_ARTICLES_B
        WHERE OKC_K_ARTICLES_B.CLE_ID = f_k_line_id
	AND OKC_K_ARTICLES_B.CHR_ID is null;

    CURSOR c_sav_sae_id(p_cat_id IN NUMBER) IS
    SELECT sav_sae_id
    FROM okc_k_articles_b
    WHERE id = p_cat_id;

    CURSOR c_latest_version(p_sae_id IN NUMBER) IS
    SELECT sav_release
    FROM okc_std_art_versions_v
    WHERE sae_id = p_sae_id
       AND date_active = (SELECT max(date_active)
                            FROM okc_std_art_versions_v
                            WHERE sae_id = p_sae_id);

    l_sae_id			   NUMBER;
    l_sav_release              	   VARCHAR2(150);

BEGIN
    x_return_status := OKE_API.G_RET_STS_SUCCESS;
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


    IF f_k_line_id is null THEN   -- copy articles for contract header
    	OPEN hdr_art_csr;
    	   LOOP

    	        FETCH hdr_art_csr INTO 	l_cat_id;

     	        EXIT WHEN hdr_art_csr%NOTFOUND;


		-- Copy articles

	    	OPEN c_sav_sae_id(l_cat_id);
    		FETCH c_sav_sae_id INTO l_sae_id;
    		CLOSE c_sav_sae_id;

    		OPEN c_latest_version(l_sae_id);
    		FETCH c_latest_version INTO l_sav_release;
    		CLOSE c_latest_version;

		OKC_COPY_CONTRACT_PUB.copy_articles(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_cat_id		=> l_cat_id,
			p_cle_id		=> null,
      			p_chr_id		=> n_k_header_id,
			p_sav_sav_release	=> l_sav_release,
			x_cat_id		=> x_cat_id);

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;


    	   END LOOP;
        CLOSE hdr_art_csr;

   ELSIF f_k_header_id is null THEN
       OPEN cle_art_csr;
    	  LOOP

    		FETCH cle_art_csr INTO 	l_cat_id;

     	  	EXIT WHEN cle_art_csr%NOTFOUND;


		-- Copy contract line articles

	    	OPEN c_sav_sae_id(l_cat_id);
    		FETCH c_sav_sae_id INTO l_sae_id;
    		CLOSE c_sav_sae_id;

    		OPEN c_latest_version(l_sae_id);
    		FETCH c_latest_version INTO l_sav_release;
    		CLOSE c_latest_version;

		OKC_COPY_CONTRACT_PUB.copy_articles(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_cat_id		=> l_cat_id,
			p_cle_id		=> n_k_line_id,
      			p_chr_id		=> null,
			p_sav_sav_release	=> l_sav_release,
			x_cat_id		=> x_cat_id);

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

      	END LOOP;
      CLOSE cle_art_csr;
   END IF;

   OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
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

end copy_articles;





FUNCTION line_has_children(p_k_line_id		IN NUMBER)

RETURN VARCHAR2 IS

l_dummy		VARCHAR2(1) := '?';

CURSOR l_csr IS
SELECT 'x'
FROM okc_k_lines_v
WHERE CLE_ID = p_k_line_id;

BEGIN
	OPEN l_csr;
	FETCH l_csr INTO l_dummy;
	CLOSE l_csr;
	IF l_dummy='?' THEN RETURN 'N';
	ELSE RETURN 'Y';
	END IF;
END line_has_children;






PROCEDURE copy_sub_lines(p_api_version         IN NUMBER,
    			  p_init_msg_list       IN VARCHAR2,
    			  x_return_status       OUT NOCOPY VARCHAR2,
    			  x_msg_count           OUT NOCOPY NUMBER,
    			  x_msg_data            OUT NOCOPY VARCHAR2,
			  f_k_header_id 	IN NUMBER,
		    	  n_k_header_id 	IN NUMBER,
		          l_copy_parties	IN VARCHAR2,
		          l_copy_tncs		IN VARCHAR2,
		          l_copy_articles	IN VARCHAR2,
		          l_copy_standard_notes	IN VARCHAR2,
			  l_copy_items		IN VARCHAR2,
			  l_copy_user_att	IN VARCHAR2,
                          p_copy_projecttask_yn IN VARCHAR2,
			  f_k_line_id		IN NUMBER,
			  n_k_line_id		IN NUMBER,
			  start_date		IN DATE,
			  end_date		IN DATE) IS


    l_api_name		CONSTANT VARCHAR2(30) := 'COPY_SUB_LINES';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_cle_rec		OKE_CLE_PVT.cle_rec_type;
    l_clev_rec		OKC_CLE_PVT.clev_rec_type;

    l_orig_header_id    NUMBER;

    x_cle_rec		OKE_CLE_PVT.cle_rec_type;
    x_clev_rec		OKC_CLE_PVT.clev_rec_type;

    iter_from_line_id	NUMBER;
    iter_to_line_id	NUMBER;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

    -- DECLARE OKE cursor for sub-lines

    	CURSOR sub_line_csr IS
    	SELECT
		b.K_LINE_ID			,
		b.PARENT_LINE_ID		,
		b.PROJECT_ID			,
		b.TASK_ID			,
		b.BILLING_METHOD_CODE		,
		b.INVENTORY_ITEM_ID		,
		b.DELIVERY_ORDER_FLAG		,
	        b.SPLITED_FLAG			,
		b.PRIORITY_CODE			,
		b.CUSTOMER_ITEM_ID		,
		b.CUSTOMER_ITEM_NUMBER		,
		b.LINE_QUANTITY			,
		b.DELIVERY_DATE			,
		b.UNIT_PRICE			,
		b.UOM_CODE			,
		b.LINE_VALUE			,
--		b.LINE_VALUE_TOTAL		,
		b.UNDEF_UNIT_PRICE		,
		b.UNDEF_LINE_VALUE		,
--		b.UNDEF_LINE_VALUE_TOTAL	,
		b.END_DATE			,
		b.BILLABLE_FLAG			,
		b.SHIPPABLE_FLAG		,
		b.SUBCONTRACTED_FLAG		,
		b.COMPLETED_FLAG		,
		b.NSP_FLAG			,
		b.APP_CODE			,
		b.AS_OF_DATE			,
		b.AUTHORITY			,
		b.COUNTRY_OF_ORIGIN_CODE	,
		b.DROP_SHIPPED_FLAG		,
		b.CUSTOMER_APPROVAL_REQ_FLAG	,
		b.DATE_MATERIAL_REQ		,
		b.INSPECTION_REQ_FLAG		,
		b.INTERIM_RPT_REQ_FLAG		,
		b.SUBJ_A133_FLAG		,
		b.EXPORT_FLAG			,
		b.CFE_REQ_FLAG			,
		b.COP_REQUIRED_FLAG		,
		b.EXPORT_LICENSE_NUM		,
		b.EXPORT_LICENSE_RES		,
		b.COPIES_REQUIRED		,
		b.CDRL_CATEGORY			,
		b.DATA_ITEM_NAME		,
		b.DATA_ITEM_SUBTITLE		,
		b.DATE_OF_FIRST_SUBMISSION	,
		b.FREQUENCY			,
		b.REQUIRING_OFFICE		,
		b.DCAA_AUDIT_REQ_FLAG		,
		b.DEFINITIZED_FLAG		,
		b.COST_OF_MONEY			,
		b.BILL_UNDEFINITIZED_FLAG	,
		b.NSN_NUMBER			,
		b.NTE_WARNING_FLAG		,
		b.DISCOUNT_FOR_PAYMENT		,
		b.FINANCIAL_CTRL_FLAG		,
		b.C_SCS_FLAG			,
		b.C_SSR_FLAG			,
		b.PREPAYMENT_AMOUNT		,
		b.PREPAYMENT_PERCENTAGE		,
		b.PROGRESS_PAYMENT_FLAG		,
		b.PROGRESS_PAYMENT_LIQ_RATE	,
		b.PROGRESS_PAYMENT_RATE		,
		b.AWARD_FEE			,
		b.AWARD_FEE_POOL_AMOUNT		,
		b.BASE_FEE			,
		b.CEILING_COST			,
		b.CEILING_PRICE			,
		b.COST_OVERRUN_SHARE_RATIO	,
		b.COST_UNDERRUN_SHARE_RATIO	,
		b.LABOR_COST_INDEX		,
		b.MATERIAL_COST_INDEX		,
		b.CUSTOMERS_PERCENT_IN_ORDER	,
		b.DATE_OF_PRICE_REDETERMIN	,
		b.ESTIMATED_TOTAL_QUANTITY	,
		b.FEE_AJT_FORMULA		,
		b.FINAL_FEE			,
		b.FINAL_PFT_AJT_FORMULA		,
		b.FIXED_FEE			,
		b.FIXED_QUANTITY		,
		b.INITIAL_FEE			,
		b.INITIAL_PRICE			,
		b.LEVEL_OF_EFFORT_HOURS		,
		b.LINE_LIQUIDATION_RATE		,
		b.MAXIMUM_FEE			,
		b.MAXIMUM_QUANTITY		,
		b.MINIMUM_FEE			,
		b.MINIMUM_QUANTITY		,
		b.NUMBER_OF_OPTIONS		,
		b.REVISED_PRICE			,
		b.TARGET_COST			,
		b.TARGET_DATE_DEFINITIZE	,
		b.TARGET_FEE			,
		b.TARGET_PRICE			,
		b.TOTAL_ESTIMATED_COST		,
		b.PROPOSAL_DUE_DATE		,
		b.COST_OF_SALE_RATE		,
		b.CREATED_BY			,
		b.CREATION_DATE			,
		b.LAST_UPDATED_BY		,
		b.LAST_UPDATE_LOGIN		,
		b.LAST_UPDATE_DATE		,


            a.ID,
            a.OBJECT_VERSION_NUMBER,
            a.SFWT_FLAG,
            a.CHR_ID,
            a.CLE_ID,
            a.LSE_ID,
            a.LINE_NUMBER,
            a.STS_CODE,
            a.DISPLAY_SEQUENCE,
            a.TRN_CODE,
            a.DNZ_CHR_ID,
            a.COMMENTS,
            a.ITEM_DESCRIPTION,
            a.HIDDEN_IND,
	    a.PRICE_UNIT,
	    a.PRICE_UNIT_PERCENT,
            a.PRICE_NEGOTIATED,
	    a.PRICE_NEGOTIATED_RENEWED,
            a.PRICE_LEVEL_IND,
            a.INVOICE_LINE_LEVEL_IND,
            a.DPAS_RATING,
            a.BLOCK23TEXT,
            a.EXCEPTION_YN,
            a.TEMPLATE_USED,
            a.DATE_TERMINATED,
            a.NAME,
            a.START_DATE,
            a.END_DATE,
            a.UPG_ORIG_SYSTEM_REF,
            a.UPG_ORIG_SYSTEM_REF_ID,
            a.ATTRIBUTE_CATEGORY,
            a.ATTRIBUTE1,
            a.ATTRIBUTE2,
            a.ATTRIBUTE3,
            a.ATTRIBUTE4,
            a.ATTRIBUTE5,
            a.ATTRIBUTE6,
            a.ATTRIBUTE7,
            a.ATTRIBUTE8,
            a.ATTRIBUTE9,
            a.ATTRIBUTE10,
            a.ATTRIBUTE11,
            a.ATTRIBUTE12,
            a.ATTRIBUTE13,
            a.ATTRIBUTE14,
            a.ATTRIBUTE15,
            a.CREATED_BY,
            a.CREATION_DATE,
            a.LAST_UPDATED_BY,
            a.LAST_UPDATE_DATE,
            a.PRICE_TYPE,
            a.CURRENCY_CODE,
	    a.CURRENCY_CODE_RENEWED,
            a.LAST_UPDATE_LOGIN


      FROM okc_K_Lines_V a, oke_k_lines b
      WHERE a.cle_id = f_k_line_id AND a.id=b.k_line_id;


 BEGIN
    x_return_status := OKE_API.G_RET_STS_SUCCESS;                                 -- call START_ACTIVITY to create savepoint, check compatibility
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

    OPEN sub_line_csr;

    LOOP
    -- Get current database values from OKC side
    	FETCH sub_line_csr INTO
		l_cle_rec.K_LINE_ID			,
		l_cle_rec.PARENT_LINE_ID		,
		l_cle_rec.PROJECT_ID			,
		l_cle_rec.TASK_ID			,
		l_cle_rec.BILLING_METHOD_CODE		,
		l_cle_rec.INVENTORY_ITEM_ID		,
		l_cle_rec.DELIVERY_ORDER_FLAG		,
                l_cle_rec.SPLITED_FLAG			,
		l_cle_rec.PRIORITY_CODE			,
		l_cle_rec.CUSTOMER_ITEM_ID		,
		l_cle_rec.CUSTOMER_ITEM_NUMBER		,
		l_cle_rec.LINE_QUANTITY			,
		l_cle_rec.DELIVERY_DATE			,
		l_cle_rec.UNIT_PRICE			,
		l_cle_rec.UOM_CODE			,
		l_cle_rec.LINE_VALUE			,
--		l_cle_rec.LINE_VALUE_TOTAL		,
		l_cle_rec.UNDEF_UNIT_PRICE		,
		l_cle_rec.UNDEF_LINE_VALUE		,
--		l_cle_rec.UNDEF_LINE_VALUE_TOTAL	,
		l_cle_rec.END_DATE			,
		l_cle_rec.BILLABLE_FLAG			,
		l_cle_rec.SHIPPABLE_FLAG		,
		l_cle_rec.SUBCONTRACTED_FLAG		,
		l_cle_rec.COMPLETED_FLAG		,
		l_cle_rec.NSP_FLAG			,
		l_cle_rec.APP_CODE			,
		l_cle_rec.AS_OF_DATE			,
		l_cle_rec.AUTHORITY			,
		l_cle_rec.COUNTRY_OF_ORIGIN_CODE	,
		l_cle_rec.DROP_SHIPPED_FLAG		,
		l_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG	,
		l_cle_rec.DATE_MATERIAL_REQ		,
		l_cle_rec.INSPECTION_REQ_FLAG		,
		l_cle_rec.INTERIM_RPT_REQ_FLAG		,
		l_cle_rec.SUBJ_A133_FLAG		,
		l_cle_rec.EXPORT_FLAG			,
		l_cle_rec.CFE_REQ_FLAG			,
		l_cle_rec.COP_REQUIRED_FLAG		,
		l_cle_rec.EXPORT_LICENSE_NUM		,
		l_cle_rec.EXPORT_LICENSE_RES		,
		l_cle_rec.COPIES_REQUIRED		,
		l_cle_rec.CDRL_CATEGORY			,
		l_cle_rec.DATA_ITEM_NAME		,
		l_cle_rec.DATA_ITEM_SUBTITLE		,
		l_cle_rec.DATE_OF_FIRST_SUBMISSION	,
		l_cle_rec.FREQUENCY			,
		l_cle_rec.REQUIRING_OFFICE		,
		l_cle_rec.DCAA_AUDIT_REQ_FLAG		,
		l_cle_rec.DEFINITIZED_FLAG		,
		l_cle_rec.COST_OF_MONEY			,
		l_cle_rec.BILL_UNDEFINITIZED_FLAG	,
		l_cle_rec.NSN_NUMBER			,
		l_cle_rec.NTE_WARNING_FLAG		,
		l_cle_rec.DISCOUNT_FOR_PAYMENT		,
		l_cle_rec.FINANCIAL_CTRL_FLAG		,
		l_cle_rec.C_SCS_FLAG			,
		l_cle_rec.C_SSR_FLAG			,
		l_cle_rec.PREPAYMENT_AMOUNT		,
		l_cle_rec.PREPAYMENT_PERCENTAGE		,
		l_cle_rec.PROGRESS_PAYMENT_FLAG		,
		l_cle_rec.PROGRESS_PAYMENT_LIQ_RATE	,
		l_cle_rec.PROGRESS_PAYMENT_RATE		,
		l_cle_rec.AWARD_FEE			,
		l_cle_rec.AWARD_FEE_POOL_AMOUNT		,
		l_cle_rec.BASE_FEE			,
		l_cle_rec.CEILING_COST			,
		l_cle_rec.CEILING_PRICE			,
		l_cle_rec.COST_OVERRUN_SHARE_RATIO	,
		l_cle_rec.COST_UNDERRUN_SHARE_RATIO	,
		l_cle_rec.LABOR_COST_INDEX		,
		l_cle_rec.MATERIAL_COST_INDEX		,
		l_cle_rec.CUSTOMERS_PERCENT_IN_ORDER	,
		l_cle_rec.DATE_OF_PRICE_REDETERMIN	,
		l_cle_rec.ESTIMATED_TOTAL_QUANTITY	,
		l_cle_rec.FEE_AJT_FORMULA		,
		l_cle_rec.FINAL_FEE			,
		l_cle_rec.FINAL_PFT_AJT_FORMULA		,
		l_cle_rec.FIXED_FEE			,
		l_cle_rec.FIXED_QUANTITY		,
		l_cle_rec.INITIAL_FEE			,
		l_cle_rec.INITIAL_PRICE			,
		l_cle_rec.LEVEL_OF_EFFORT_HOURS		,
		l_cle_rec.LINE_LIQUIDATION_RATE		,
		l_cle_rec.MAXIMUM_FEE			,
		l_cle_rec.MAXIMUM_QUANTITY		,
		l_cle_rec.MINIMUM_FEE			,
		l_cle_rec.MINIMUM_QUANTITY		,
		l_cle_rec.NUMBER_OF_OPTIONS		,
		l_cle_rec.REVISED_PRICE			,
		l_cle_rec.TARGET_COST			,
		l_cle_rec.TARGET_DATE_DEFINITIZE	,
		l_cle_rec.TARGET_FEE			,
		l_cle_rec.TARGET_PRICE			,
		l_cle_rec.TOTAL_ESTIMATED_COST		,
		l_cle_rec.PROPOSAL_DUE_DATE		,
		l_cle_rec.COST_OF_SALE_RATE		,
		l_cle_rec.CREATED_BY			,
		l_cle_rec.CREATION_DATE			,
		l_cle_rec.LAST_UPDATED_BY		,
		l_cle_rec.LAST_UPDATE_LOGIN		,
		l_cle_rec.LAST_UPDATE_DATE		,

              l_clev_rec.ID,
              l_clev_rec.OBJECT_VERSION_NUMBER,
              l_clev_rec.SFWT_FLAG,
              l_clev_rec.CHR_ID,
              l_clev_rec.CLE_ID,
              l_clev_rec.LSE_ID,
              l_clev_rec.LINE_NUMBER,
              l_clev_rec.STS_CODE,
              l_clev_rec.DISPLAY_SEQUENCE,
              l_clev_rec.TRN_CODE,
              l_clev_rec.DNZ_CHR_ID,
              l_clev_rec.COMMENTS,
              l_clev_rec.ITEM_DESCRIPTION,
              l_clev_rec.HIDDEN_IND,
	      l_clev_rec.PRICE_UNIT,
	      l_clev_rec.PRICE_UNIT_PERCENT,
              l_clev_rec.PRICE_NEGOTIATED,
	      l_clev_rec.PRICE_NEGOTIATED_RENEWED,
              l_clev_rec.PRICE_LEVEL_IND,
              l_clev_rec.INVOICE_LINE_LEVEL_IND,
              l_clev_rec.DPAS_RATING,
              l_clev_rec.BLOCK23TEXT,
              l_clev_rec.EXCEPTION_YN,
              l_clev_rec.TEMPLATE_USED,
              l_clev_rec.DATE_TERMINATED,
              l_clev_rec.NAME,
              l_clev_rec.START_DATE,
              l_clev_rec.END_DATE,
              l_clev_rec.UPG_ORIG_SYSTEM_REF,
              l_clev_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_clev_rec.ATTRIBUTE_CATEGORY,
              l_clev_rec.ATTRIBUTE1,
              l_clev_rec.ATTRIBUTE2,
              l_clev_rec.ATTRIBUTE3,
              l_clev_rec.ATTRIBUTE4,
              l_clev_rec.ATTRIBUTE5,
              l_clev_rec.ATTRIBUTE6,
              l_clev_rec.ATTRIBUTE7,
              l_clev_rec.ATTRIBUTE8,
              l_clev_rec.ATTRIBUTE9,
              l_clev_rec.ATTRIBUTE10,
              l_clev_rec.ATTRIBUTE11,
              l_clev_rec.ATTRIBUTE12,
              l_clev_rec.ATTRIBUTE13,
              l_clev_rec.ATTRIBUTE14,
              l_clev_rec.ATTRIBUTE15,
              l_clev_rec.CREATED_BY,
              l_clev_rec.CREATION_DATE,
              l_clev_rec.LAST_UPDATED_BY,
              l_clev_rec.LAST_UPDATE_DATE,
              l_clev_rec.PRICE_TYPE,
              l_clev_rec.CURRENCY_CODE,
	      l_clev_rec.CURRENCY_CODE_RENEWED,
              l_clev_rec.LAST_UPDATE_LOGIN;

     	   EXIT WHEN sub_line_csr%NOTFOUND;



        l_orig_header_id := l_clev_rec.dnz_chr_id;



	l_clev_rec.cle_id :=  n_k_line_id;
	l_cle_rec.PARENT_LINE_ID:=n_k_line_id;
	l_clev_rec.dnz_chr_id := n_k_header_id;
--	l_clev_rec.sts_code := 'ENTERED';
--	l_clev_rec.sts_code :=null;
	get_status(l_clev_rec.sts_code);




	l_clev_rec.template_used := NULL;
--	l_cle_rec.billing_method_code := NULL;
	l_clev_rec.start_date := start_date;
	l_clev_rec.end_date := end_date;

       --bug#5680084
        IF trunc(start_date) > trunc(l_cle_rec.END_DATE) THEN
           l_cle_rec.end_date := NULL;
        END IF;
       --bug#5680084

l_cle_rec.DELIVERY_DATE :=null;
l_cle_rec.AS_OF_DATE := null;
l_cle_rec.DATE_MATERIAL_REQ := null;
l_cle_rec.DATE_OF_FIRST_SUBMISSION :=null;
l_cle_rec.DATE_OF_PRICE_REDETERMIN :=null;
l_cle_rec.TARGET_DATE_DEFINITIZE:=null;
l_cle_rec.PROPOSAL_DUE_DATE :=null;
If g_proj_copy_allowed ='N' then
   l_cle_rec.PROJECT_ID := null;
   l_cle_rec.TASK_ID := null;
end if;

l_clev_rec.DATE_TERMINATED :=null;


	-- Create contract lines

		OKE_CONTRACT_PUB.create_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_cle_rec		=> l_cle_rec,
			p_clev_rec		=> l_clev_rec,
      			x_cle_rec		=> x_cle_rec,
			x_clev_rec		=> x_clev_rec);

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;



	iter_to_line_id := x_cle_rec.k_line_id;
	iter_from_line_id := l_cle_rec.k_line_id;


	IF l_copy_items = 'Y' THEN
		copy_items
		(
		p_api_version     	=>	p_api_version,
    		p_init_msg_list     	=>	p_init_msg_list,
    		x_return_status      	=>	x_return_status,
    		x_msg_count         	=>     	x_msg_count,
   		x_msg_data              => 	x_msg_data,
    		p_from_cle_id     	=> 	iter_from_line_id,
    		p_to_cle_id 		=>	iter_to_line_id
		);

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;
	END IF;

        -- copy user attributes (lines)
        IF l_copy_user_att = 'Y' then
           copy_user_attr_line (p_k_header_id 	  =>	 f_k_header_id  	 ,
                                p_k_header_id_new =>     n_k_header_id 		 ,
                                p_k_line_id       =>  	 l_cle_rec.k_line_id	 ,
                                p_k_line_id_new   =>     x_cle_rec.k_line_id     );
        END IF;

	IF line_has_children(l_clev_rec.id)='Y' THEN

	copy_sub_lines(p_api_version         ,
    			  p_init_msg_list    ,
    			  x_return_status    ,
    			  x_msg_count        ,
    			  x_msg_data         ,
			  f_k_header_id      ,
		    	  n_k_header_id	     ,
		          l_copy_parties     ,
		          l_copy_tncs        ,
		          l_copy_articles    ,
		          l_copy_standard_notes,
			  l_copy_items,
			  l_copy_user_att,
                          p_copy_projecttask_yn,
			  iter_from_line_id  ,
			  iter_to_line_id ,
			  start_date	,
			  end_date      );

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

	END IF;


    IF l_copy_parties = 'Y' then
	copy_party_roles( p_api_version      	,
    			  p_init_msg_list    	,
    			  x_return_status 	,
    			  x_msg_count    	,
    			  x_msg_data         	,
			  null			,
			  null			,
			  l_cle_rec.k_line_id	,
			  x_cle_rec.k_line_id	,
			  l_orig_header_id );
 		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

  END IF;

   IF l_copy_articles = 'Y' then
	copy_articles(	p_api_version		,
    			p_init_msg_list		,
    			x_return_status		,
    			x_msg_count		,
    			x_msg_data		,
			null			,
			null			,
			l_cle_rec.k_line_id	,
			x_cle_rec.k_line_id	);
		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   END IF;


   IF l_copy_tncs = 'Y' then
   -- Copy Terms for Contract Header

      OKE_TERMS_PUB.copy_term(
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		x_return_status 	=> x_return_status,
		x_msg_count     	=> x_msg_count,
		x_msg_data      	=> x_msg_data,
    		p_from_level		=> 'L',
    		p_to_level		=> 'L',
    		p_from_chr_id		=> null,
    		p_to_chr_id		=> n_k_header_id,
    		p_from_cle_id		=> l_cle_rec.k_line_id,
    		p_to_cle_id		=> x_cle_rec.k_line_id
    );

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   END IF;

   IF l_copy_standard_notes = 'Y' then
   -- Copy Standard Notes
      OKE_STANDARD_NOTES_PUB.copy_standard_note(
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		x_return_status 	=> x_return_status,
		x_msg_count     	=> x_msg_count,
		x_msg_data      	=> x_msg_data,
      		p_from_hdr_id		=> null,
    		p_to_hdr_id	 	=> n_k_header_id,
    		p_from_cle_id		=> l_cle_rec.k_line_id,
    		p_to_cle_id		=> x_cle_rec.k_line_id,
    		p_from_del_id		=> null,
    		p_to_del_id		=> null,
		default_flag		=> 'N'
     );
		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   END IF;


  END LOOP;
    CLOSE sub_line_csr;

   OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
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

END copy_sub_lines;



/*-------------------------------------------------------------------------
 PROCEDURE get_k_lines_rec - get OKE and OKC contract line information from
			 oke_k_lines, okc_k_lines_v
--------------------------------------------------------------------------*/

PROCEDURE copy_contract_lines(p_api_version         IN NUMBER,
    			  p_init_msg_list       IN VARCHAR2,
    			  x_return_status       OUT NOCOPY VARCHAR2,
    			  x_msg_count           OUT NOCOPY NUMBER,
    			  x_msg_data            OUT NOCOPY VARCHAR2,
			  f_k_header_id 	IN NUMBER,
		    	  n_k_header_id 	IN NUMBER,
		          l_copy_parties	IN VARCHAR2,
		          l_copy_tncs		IN VARCHAR2,
		          l_copy_articles	IN VARCHAR2,
		          l_copy_standard_notes	IN VARCHAR2,
			  l_copy_items		IN VARCHAR2,
			  l_copy_user_att	IN VARCHAR2,
                          p_copy_projecttask_yn IN VARCHAR2,
			  start_date		IN DATE,
			  end_date		IN DATE  ) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'COPY_CONTRACT_LINES';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_cle_rec		OKE_CLE_PVT.cle_rec_type;
    l_clev_rec		OKC_CLE_PVT.clev_rec_type;

    x_cle_rec		OKE_CLE_PVT.cle_rec_type;
    x_clev_rec		OKC_CLE_PVT.clev_rec_type;

    iter_from_line_id	NUMBER;
    iter_to_line_id	NUMBER;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

    l_orig_header_id    NUMBER;


    -- DECLARE OKE cursor for top-lines

    	CURSOR top_line_csr IS
    	SELECT
		b.K_LINE_ID			,
		b.PARENT_LINE_ID		,
		b.PROJECT_ID			,
		b.TASK_ID			,
		b.BILLING_METHOD_CODE		,
		b.INVENTORY_ITEM_ID		,
		b.DELIVERY_ORDER_FLAG		,
	        b.SPLITED_FLAG			,
		b.PRIORITY_CODE			,
		b.CUSTOMER_ITEM_ID		,
		b.CUSTOMER_ITEM_NUMBER		,
		b.LINE_QUANTITY			,
		b.DELIVERY_DATE			,
		b.UNIT_PRICE			,
		b.UOM_CODE			,
		b.LINE_VALUE			,
--		b.LINE_VALUE_TOTAL		,
		b.UNDEF_UNIT_PRICE		,
		b.UNDEF_LINE_VALUE		,
--		b.UNDEF_LINE_VALUE_TOTAL	,
		b.END_DATE			,
		b.BILLABLE_FLAG			,
		b.SHIPPABLE_FLAG		,
		b.SUBCONTRACTED_FLAG		,
		b.COMPLETED_FLAG		,
		b.NSP_FLAG			,
		b.APP_CODE			,
		b.AS_OF_DATE			,
		b.AUTHORITY			,
		b.COUNTRY_OF_ORIGIN_CODE	,
		b.DROP_SHIPPED_FLAG		,
		b.CUSTOMER_APPROVAL_REQ_FLAG	,
		b.DATE_MATERIAL_REQ		,
		b.INSPECTION_REQ_FLAG		,
		b.INTERIM_RPT_REQ_FLAG		,
		b.SUBJ_A133_FLAG		,
		b.EXPORT_FLAG			,
		b.CFE_REQ_FLAG			,
		b.COP_REQUIRED_FLAG		,
		b.EXPORT_LICENSE_NUM		,
		b.EXPORT_LICENSE_RES		,
		b.COPIES_REQUIRED		,
		b.CDRL_CATEGORY			,
		b.DATA_ITEM_NAME		,
		b.DATA_ITEM_SUBTITLE		,
		b.DATE_OF_FIRST_SUBMISSION	,
		b.FREQUENCY			,
		b.REQUIRING_OFFICE		,
		b.DCAA_AUDIT_REQ_FLAG		,
		b.DEFINITIZED_FLAG		,
		b.COST_OF_MONEY			,
		b.BILL_UNDEFINITIZED_FLAG	,
		b.NSN_NUMBER			,
		b.NTE_WARNING_FLAG		,
		b.DISCOUNT_FOR_PAYMENT		,
		b.FINANCIAL_CTRL_FLAG		,
		b.C_SCS_FLAG			,
		b.C_SSR_FLAG			,
		b.PREPAYMENT_AMOUNT		,
		b.PREPAYMENT_PERCENTAGE		,
		b.PROGRESS_PAYMENT_FLAG		,
		b.PROGRESS_PAYMENT_LIQ_RATE	,
		b.PROGRESS_PAYMENT_RATE		,
		b.AWARD_FEE			,
		b.AWARD_FEE_POOL_AMOUNT		,
		b.BASE_FEE			,
		b.CEILING_COST			,
		b.CEILING_PRICE			,
		b.COST_OVERRUN_SHARE_RATIO	,
		b.COST_UNDERRUN_SHARE_RATIO	,
		b.LABOR_COST_INDEX		,
		b.MATERIAL_COST_INDEX		,
		b.CUSTOMERS_PERCENT_IN_ORDER	,
		b.DATE_OF_PRICE_REDETERMIN	,
		b.ESTIMATED_TOTAL_QUANTITY	,
		b.FEE_AJT_FORMULA		,
		b.FINAL_FEE			,
		b.FINAL_PFT_AJT_FORMULA		,
		b.FIXED_FEE			,
		b.FIXED_QUANTITY		,
		b.INITIAL_FEE			,
		b.INITIAL_PRICE			,
		b.LEVEL_OF_EFFORT_HOURS		,
		b.LINE_LIQUIDATION_RATE		,
		b.MAXIMUM_FEE			,
		b.MAXIMUM_QUANTITY		,
		b.MINIMUM_FEE			,
		b.MINIMUM_QUANTITY		,
		b.NUMBER_OF_OPTIONS		,
		b.REVISED_PRICE			,
		b.TARGET_COST			,
		b.TARGET_DATE_DEFINITIZE	,
		b.TARGET_FEE			,
		b.TARGET_PRICE			,
		b.TOTAL_ESTIMATED_COST		,
		b.PROPOSAL_DUE_DATE		,
		b.COST_OF_SALE_RATE		,
		b.CREATED_BY			,
		b.CREATION_DATE			,
		b.LAST_UPDATED_BY		,
		b.LAST_UPDATE_LOGIN		,
		b.LAST_UPDATE_DATE		,


            a.ID,
            a.OBJECT_VERSION_NUMBER,
            a.SFWT_FLAG,
            a.CHR_ID,
            a.CLE_ID,
            a.LSE_ID,
            a.LINE_NUMBER,
            a.STS_CODE,
            a.DISPLAY_SEQUENCE,
            a.TRN_CODE,
            a.DNZ_CHR_ID,
            a.COMMENTS,
            a.ITEM_DESCRIPTION,
            a.HIDDEN_IND,
	    a.PRICE_UNIT,
	    a.PRICE_UNIT_PERCENT,
            a.PRICE_NEGOTIATED,
	    a.PRICE_NEGOTIATED_RENEWED,
            a.PRICE_LEVEL_IND,
            a.INVOICE_LINE_LEVEL_IND,
            a.DPAS_RATING,
            a.BLOCK23TEXT,
            a.EXCEPTION_YN,
            a.TEMPLATE_USED,
            a.DATE_TERMINATED,
            a.NAME,
            a.START_DATE,
            a.END_DATE,
            a.UPG_ORIG_SYSTEM_REF,
            a.UPG_ORIG_SYSTEM_REF_ID,
            a.ATTRIBUTE_CATEGORY,
            a.ATTRIBUTE1,
            a.ATTRIBUTE2,
            a.ATTRIBUTE3,
            a.ATTRIBUTE4,
            a.ATTRIBUTE5,
            a.ATTRIBUTE6,
            a.ATTRIBUTE7,
            a.ATTRIBUTE8,
            a.ATTRIBUTE9,
            a.ATTRIBUTE10,
            a.ATTRIBUTE11,
            a.ATTRIBUTE12,
            a.ATTRIBUTE13,
            a.ATTRIBUTE14,
            a.ATTRIBUTE15,
            a.CREATED_BY,
            a.CREATION_DATE,
            a.LAST_UPDATED_BY,
            a.LAST_UPDATE_DATE,
            a.PRICE_TYPE,
            a.CURRENCY_CODE,
	    a.CURRENCY_CODE_RENEWED,
            a.LAST_UPDATE_LOGIN


      FROM okc_K_Lines_V a, oke_k_lines b
      WHERE a.chr_id = f_k_header_id AND a.id=b.k_line_id;


 BEGIN
    x_return_status := OKE_API.G_RET_STS_SUCCESS;                                 -- call START_ACTIVITY to create savepoint, check compatibility
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


    OPEN top_line_csr;

    LOOP
    -- Get current database values from OKC side

    	FETCH top_line_csr INTO
		l_cle_rec.K_LINE_ID			,
		l_cle_rec.PARENT_LINE_ID		,
		l_cle_rec.PROJECT_ID			,
		l_cle_rec.TASK_ID			,
		l_cle_rec.BILLING_METHOD_CODE		,
		l_cle_rec.INVENTORY_ITEM_ID		,
		l_cle_rec.DELIVERY_ORDER_FLAG		,
                l_cle_rec.SPLITED_FLAG			,
		l_cle_rec.PRIORITY_CODE			,
		l_cle_rec.CUSTOMER_ITEM_ID		,
		l_cle_rec.CUSTOMER_ITEM_NUMBER		,
		l_cle_rec.LINE_QUANTITY			,
		l_cle_rec.DELIVERY_DATE			,
		l_cle_rec.UNIT_PRICE			,
		l_cle_rec.UOM_CODE			,
		l_cle_rec.LINE_VALUE			,
--		l_cle_rec.LINE_VALUE_TOTAL		,
		l_cle_rec.UNDEF_UNIT_PRICE		,
		l_cle_rec.UNDEF_LINE_VALUE		,
--		l_cle_rec.UNDEF_LINE_VALUE_TOTAL	,
		l_cle_rec.END_DATE			,
		l_cle_rec.BILLABLE_FLAG			,
		l_cle_rec.SHIPPABLE_FLAG		,
		l_cle_rec.SUBCONTRACTED_FLAG		,
		l_cle_rec.COMPLETED_FLAG		,
		l_cle_rec.NSP_FLAG			,
		l_cle_rec.APP_CODE			,
		l_cle_rec.AS_OF_DATE			,
		l_cle_rec.AUTHORITY			,
		l_cle_rec.COUNTRY_OF_ORIGIN_CODE	,
		l_cle_rec.DROP_SHIPPED_FLAG		,
		l_cle_rec.CUSTOMER_APPROVAL_REQ_FLAG	,
		l_cle_rec.DATE_MATERIAL_REQ		,
		l_cle_rec.INSPECTION_REQ_FLAG		,
		l_cle_rec.INTERIM_RPT_REQ_FLAG		,
		l_cle_rec.SUBJ_A133_FLAG		,
		l_cle_rec.EXPORT_FLAG			,
		l_cle_rec.CFE_REQ_FLAG			,
		l_cle_rec.COP_REQUIRED_FLAG		,
		l_cle_rec.EXPORT_LICENSE_NUM		,
		l_cle_rec.EXPORT_LICENSE_RES		,
		l_cle_rec.COPIES_REQUIRED		,
		l_cle_rec.CDRL_CATEGORY			,
		l_cle_rec.DATA_ITEM_NAME		,
		l_cle_rec.DATA_ITEM_SUBTITLE		,
		l_cle_rec.DATE_OF_FIRST_SUBMISSION	,
		l_cle_rec.FREQUENCY			,
		l_cle_rec.REQUIRING_OFFICE		,
		l_cle_rec.DCAA_AUDIT_REQ_FLAG		,
		l_cle_rec.DEFINITIZED_FLAG		,
		l_cle_rec.COST_OF_MONEY			,
		l_cle_rec.BILL_UNDEFINITIZED_FLAG	,
		l_cle_rec.NSN_NUMBER			,
		l_cle_rec.NTE_WARNING_FLAG		,
		l_cle_rec.DISCOUNT_FOR_PAYMENT		,
		l_cle_rec.FINANCIAL_CTRL_FLAG		,
		l_cle_rec.C_SCS_FLAG			,
		l_cle_rec.C_SSR_FLAG			,
		l_cle_rec.PREPAYMENT_AMOUNT		,
		l_cle_rec.PREPAYMENT_PERCENTAGE		,
		l_cle_rec.PROGRESS_PAYMENT_FLAG		,
		l_cle_rec.PROGRESS_PAYMENT_LIQ_RATE	,
		l_cle_rec.PROGRESS_PAYMENT_RATE		,
		l_cle_rec.AWARD_FEE			,
		l_cle_rec.AWARD_FEE_POOL_AMOUNT		,
		l_cle_rec.BASE_FEE			,
		l_cle_rec.CEILING_COST			,
		l_cle_rec.CEILING_PRICE			,
		l_cle_rec.COST_OVERRUN_SHARE_RATIO	,
		l_cle_rec.COST_UNDERRUN_SHARE_RATIO	,
		l_cle_rec.LABOR_COST_INDEX		,
		l_cle_rec.MATERIAL_COST_INDEX		,
		l_cle_rec.CUSTOMERS_PERCENT_IN_ORDER	,
		l_cle_rec.DATE_OF_PRICE_REDETERMIN	,
		l_cle_rec.ESTIMATED_TOTAL_QUANTITY	,
		l_cle_rec.FEE_AJT_FORMULA		,
		l_cle_rec.FINAL_FEE			,
		l_cle_rec.FINAL_PFT_AJT_FORMULA		,
		l_cle_rec.FIXED_FEE			,
		l_cle_rec.FIXED_QUANTITY		,
		l_cle_rec.INITIAL_FEE			,
		l_cle_rec.INITIAL_PRICE			,
		l_cle_rec.LEVEL_OF_EFFORT_HOURS		,
		l_cle_rec.LINE_LIQUIDATION_RATE		,
		l_cle_rec.MAXIMUM_FEE			,
		l_cle_rec.MAXIMUM_QUANTITY		,
		l_cle_rec.MINIMUM_FEE			,
		l_cle_rec.MINIMUM_QUANTITY		,
		l_cle_rec.NUMBER_OF_OPTIONS		,
		l_cle_rec.REVISED_PRICE			,
		l_cle_rec.TARGET_COST			,
		l_cle_rec.TARGET_DATE_DEFINITIZE	,
		l_cle_rec.TARGET_FEE			,
		l_cle_rec.TARGET_PRICE			,
		l_cle_rec.TOTAL_ESTIMATED_COST		,
		l_cle_rec.PROPOSAL_DUE_DATE		,
		l_cle_rec.COST_OF_SALE_RATE		,
		l_cle_rec.CREATED_BY			,
		l_cle_rec.CREATION_DATE			,
		l_cle_rec.LAST_UPDATED_BY		,
		l_cle_rec.LAST_UPDATE_LOGIN		,
		l_cle_rec.LAST_UPDATE_DATE		,

              l_clev_rec.ID,
              l_clev_rec.OBJECT_VERSION_NUMBER,
              l_clev_rec.SFWT_FLAG,
              l_clev_rec.CHR_ID,
              l_clev_rec.CLE_ID,
              l_clev_rec.LSE_ID,
              l_clev_rec.LINE_NUMBER,
              l_clev_rec.STS_CODE,
              l_clev_rec.DISPLAY_SEQUENCE,
              l_clev_rec.TRN_CODE,
              l_clev_rec.DNZ_CHR_ID,
              l_clev_rec.COMMENTS,
              l_clev_rec.ITEM_DESCRIPTION,
              l_clev_rec.HIDDEN_IND,
	      l_clev_rec.PRICE_UNIT,
	      l_clev_rec.PRICE_UNIT_PERCENT,
              l_clev_rec.PRICE_NEGOTIATED,
	      l_clev_rec.PRICE_NEGOTIATED_RENEWED,
              l_clev_rec.PRICE_LEVEL_IND,
              l_clev_rec.INVOICE_LINE_LEVEL_IND,
              l_clev_rec.DPAS_RATING,
              l_clev_rec.BLOCK23TEXT,
              l_clev_rec.EXCEPTION_YN,
              l_clev_rec.TEMPLATE_USED,
              l_clev_rec.DATE_TERMINATED,
              l_clev_rec.NAME,
              l_clev_rec.START_DATE,
              l_clev_rec.END_DATE,
              l_clev_rec.UPG_ORIG_SYSTEM_REF,
              l_clev_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_clev_rec.ATTRIBUTE_CATEGORY,
              l_clev_rec.ATTRIBUTE1,
              l_clev_rec.ATTRIBUTE2,
              l_clev_rec.ATTRIBUTE3,
              l_clev_rec.ATTRIBUTE4,
              l_clev_rec.ATTRIBUTE5,
              l_clev_rec.ATTRIBUTE6,
              l_clev_rec.ATTRIBUTE7,
              l_clev_rec.ATTRIBUTE8,
              l_clev_rec.ATTRIBUTE9,
              l_clev_rec.ATTRIBUTE10,
              l_clev_rec.ATTRIBUTE11,
              l_clev_rec.ATTRIBUTE12,
              l_clev_rec.ATTRIBUTE13,
              l_clev_rec.ATTRIBUTE14,
              l_clev_rec.ATTRIBUTE15,
              l_clev_rec.CREATED_BY,
              l_clev_rec.CREATION_DATE,
              l_clev_rec.LAST_UPDATED_BY,
              l_clev_rec.LAST_UPDATE_DATE,
              l_clev_rec.PRICE_TYPE,
              l_clev_rec.CURRENCY_CODE,
	      l_clev_rec.CURRENCY_CODE_RENEWED,
              l_clev_rec.LAST_UPDATE_LOGIN;

     	   EXIT WHEN top_line_csr%NOTFOUND;

        l_orig_header_id := l_clev_rec.dnz_chr_id;


	l_clev_rec.chr_id :=  n_k_header_id;
	l_clev_rec.dnz_chr_id := n_k_header_id;
--	l_clev_rec.sts_code := 'ENTERED';
--	l_clev_rec.sts_code :=null;
	get_status(l_clev_rec.sts_code);

	l_clev_rec.template_used := NULL;
--	l_cle_rec.billing_method_code := NULL;
	l_clev_rec.start_date := start_date;
	l_clev_rec.end_date := end_date;

        --bug#5680084
        IF trunc(start_date) > trunc(l_cle_rec.END_DATE) THEN
           l_cle_rec.end_date := NULL;
        END IF;
        --bug#5680084

l_cle_rec.DELIVERY_DATE :=null;
l_cle_rec.AS_OF_DATE := null;
l_cle_rec.DATE_MATERIAL_REQ := null;
l_cle_rec.DATE_OF_FIRST_SUBMISSION :=null;
l_cle_rec.DATE_OF_PRICE_REDETERMIN :=null;
l_cle_rec.TARGET_DATE_DEFINITIZE:=null;
l_cle_rec.PROPOSAL_DUE_DATE :=null;
If g_proj_copy_allowed ='N' then
   l_cle_rec.PROJECT_ID := null;
   l_cle_rec.TASK_ID := null;
end if;
l_clev_rec.DATE_TERMINATED :=null;


	-- Create contract lines
		OKE_CONTRACT_PUB.create_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_cle_rec		=> l_cle_rec,
			p_clev_rec		=> l_clev_rec,
      			x_cle_rec		=> x_cle_rec,
			x_clev_rec		=> x_clev_rec);

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;


	iter_to_line_id := x_cle_rec.k_line_id;
	iter_from_line_id := l_cle_rec.k_line_id;


	IF l_copy_items = 'Y' THEN
		copy_items
		(
		p_api_version     	=>	p_api_version,
    		p_init_msg_list     	=>	p_init_msg_list,
    		x_return_status      	=>	x_return_status,
    		x_msg_count         	=>     	x_msg_count,
   		x_msg_data              => 	x_msg_data,
    		p_from_cle_id     	=> 	iter_from_line_id,
    		p_to_cle_id 		=>	iter_to_line_id
		);

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;
	END IF;

        -- copy user attributes (lines)
        IF l_copy_user_att = 'Y' then
           copy_user_attr_line (p_k_header_id 	  =>	 f_k_header_id  	 ,
                                p_k_header_id_new =>     n_k_header_id 		 ,
                                p_k_line_id       =>  	 l_cle_rec.k_line_id	 ,
                                p_k_line_id_new   =>     x_cle_rec.k_line_id     );
        END IF;

	IF line_has_children(l_clev_rec.id)='Y' THEN

	copy_sub_lines(p_api_version         ,
    			  p_init_msg_list    ,
    			  x_return_status    ,
    			  x_msg_count        ,
    			  x_msg_data         ,
			  f_k_header_id      ,
		    	  n_k_header_id	     ,
		          l_copy_parties     ,
		          l_copy_tncs        ,
		          l_copy_articles    ,
		          l_copy_standard_notes,
			  l_copy_items,
			  l_copy_user_att,
                          p_copy_projecttask_yn,
			  iter_from_line_id  ,
			  iter_to_line_id     ,
			  start_date		,
			  end_date	  );

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

	END IF;



   IF l_copy_parties = 'Y' then
	copy_party_roles( p_api_version      	,
    			  p_init_msg_list    	,
    			  x_return_status 	,
    			  x_msg_count    	,
    			  x_msg_data         	,
			  null			,
			  null			,
			  l_cle_rec.k_line_id	,
			  x_cle_rec.k_line_id	,
			  l_orig_header_id );

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   END IF;

   IF l_copy_articles = 'Y' then
	copy_articles(	p_api_version		,
    			p_init_msg_list		,
    			x_return_status		,
    			x_msg_count		,
    			x_msg_data		,
			null			,
			null			,
			l_cle_rec.k_line_id	,
			x_cle_rec.k_line_id	);

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   END IF;



   IF l_copy_tncs = 'Y' then
   -- Copy Terms for Contract Header
      OKE_TERMS_PUB.copy_term(
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		x_return_status 	=> x_return_status,
		x_msg_count     	=> x_msg_count,
		x_msg_data      	=> x_msg_data,
    		p_from_level		=> 'L',
    		p_to_level		=> 'L',
    		p_from_chr_id		=> null,
    		p_to_chr_id		=> n_k_header_id,
    		p_from_cle_id		=> l_cle_rec.k_line_id,
    		p_to_cle_id		=> x_cle_rec.k_line_id
    );

		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   END IF;

   IF l_copy_standard_notes = 'Y' then
   -- Copy Standard Notes
      OKE_STANDARD_NOTES_PUB.copy_standard_note(
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		x_return_status 	=> x_return_status,
		x_msg_count     	=> x_msg_count,
		x_msg_data      	=> x_msg_data,
      		p_from_hdr_id		=> null,
    		p_to_hdr_id	 	=> n_k_header_id,
    		p_from_cle_id		=> l_cle_rec.k_line_id,
    		p_to_cle_id		=> x_cle_rec.k_line_id,
    		p_from_del_id		=> null,
    		p_to_del_id		=> null,
		default_flag		=> 'N'
     );
		If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   END IF;


  END LOOP;
    CLOSE top_line_csr;

   OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

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

END copy_contract_lines;


PROCEDURE Calculate_Line_Totals(
  p_chr_id NUMBER,
  p_cle_id NUMBER,
  x_total   OUT NOCOPY NUMBER,
  x_total_u OUT NOCOPY NUMBER
 ) IS
  l_amount   NUMBER;
  l_amount_u NUMBER;

  CURSOR l_lines IS
   SELECT id
    FROM okc_k_lines_b
    WHERE dnz_chr_id = p_chr_id
     AND ( cle_id = p_cle_id AND p_cle_id IS NOT NULL
        OR cle_id IS NULL AND p_cle_id IS NULL);

 BEGIN

  x_total   := NULL;
  x_total_u := NULL;

  FOR c IN l_lines LOOP

    -- calculate sublines totals
    Calculate_Line_Totals( p_chr_id, c.id, l_amount, l_amount_u );

    -- the amounts are null if there is no sublines
    IF ( l_amount IS NULL AND l_amount_u IS NULL ) THEN
      SELECT Nvl(line_value,0), Nvl(undef_line_value,0)
        INTO l_amount, l_amount_u
        FROM oke_k_lines
        WHERE k_line_id = c.id;
    END IF;

    UPDATE oke_k_lines
      SET line_value_total = l_amount, undef_line_value_total = l_amount_u
      WHERE k_line_id = c.id;

    x_total := Nvl(x_total,0) + l_amount;
    x_total_u := Nvl(x_total_u,0) + l_amount_u;

  END LOOP;

END Calculate_Line_Totals;

PROCEDURE Calculate_Totals(p_chr_id NUMBER) IS
  l_total    NUMBER := NULL;
  l_total_u  NUMBER := NULL;
 BEGIN

  Calculate_Line_Totals( p_chr_id, NULL, l_total, l_total_u );

  UPDATE oke_k_headers
    SET line_value_total=l_total, undef_line_value_total=l_total_u
    WHERE k_header_id = p_chr_id;

END Calculate_Totals;



/*-------------------------------------------------------------------------
 PROCEDURE copy_contract - main program called by OKE Widzard UI
 ------------------------------------------------------------------------*/
PROCEDURE copy_contract(
   		p_api_version 		IN NUMBER,
    		p_init_msg_list 	IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    		x_return_status         OUT NOCOPY VARCHAR2,
    		x_msg_count            	OUT NOCOPY NUMBER,
    		x_msg_data             	OUT NOCOPY VARCHAR2,

		p_copy_lines		IN VARCHAR2,
		p_copy_parties		IN VARCHAR2,
		p_copy_tncs		IN VARCHAR2,
		p_copy_articles		IN VARCHAR2,
		p_copy_standard_notes	IN VARCHAR2,
                p_copy_user_attributes                  IN VARCHAR2,
		p_copy_admin_yn         IN VARCHAR2,
                p_copy_projecttask_yn   IN VARCHAR2,
		p_dest_doc_type 			IN VARCHAR2,
  		p_dest_doc_number 			IN VARCHAR2,
		p_dest_buy_or_sell			IN VARCHAR2,
		p_dest_currency_code			IN VARCHAR2,
		p_dest_start_date			IN DATE,
		p_dest_end_date				IN DATE,
		p_dest_template_yn			IN VARCHAR2,
		p_dest_authoring_org_id			IN NUMBER,
		p_dest_inv_organization_id		IN NUMBER,
		p_dest_boa_id				IN NUMBER,
		p_source_k_header_id			IN NUMBER,
		x_dest_k_header_id 			OUT NOCOPY NUMBER
                          )
IS

    l_row_notfound	BOOLEAN := TRUE;
    x_chr_rec		OKE_CHR_PVT.chr_rec_type;
    x_chrv_rec		OKC_CONTRACT_PUB.chrv_rec_type;
    l_chr_rec		OKE_CHR_PVT.chr_rec_type;
    l_chrv_rec		OKC_CHR_PVT.chrv_rec_type;
				--OKC_CONTRACT_PUB.chrv_rec_type;


    l_return_status	VARCHAR2(1)		:= OKE_API.G_RET_STS_SUCCESS;
    l_api_name		CONSTANT VARCHAR2(30) 	:= 'COPY_CONTRACT';
    l_api_version	NUMBER 			:= 1.0;


    l_check		VARCHAR2(1) := '?';

    CURSOR c_check_org(h1 NUMBER,h2 NUMBER) IS
	SELECT 'x'
	FROM okc_k_headers_all_b a, okc_k_headers_all_b b
	WHERE a.inv_organization_id=b.inv_organization_id
	AND a.id = h1 AND b.id=h2;


CURSOR c_access IS
select distinct role_id,person_id,
decode(sign(trunc(start_date_active)-trunc(sysdate)),1,trunc(start_date_active),trunc(sysdate)),
trunc(end_date_active)
from oke_k_access_v
where object_id=p_source_k_header_id
and (end_date_active is null OR trunc(end_date_active)> trunc(sysdate));


cursor c_get_process is
select pdf_id,
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
       ATTRIBUTE15
 from OKC_K_PROCESSES
 where chr_id=p_source_k_header_id;


 cursor c_source_doc_class is
 select type_class_code
 from oke_k_headers chr,
      OKE_K_TYPES_b ktype
 where chr.k_type_code = ktype.k_type_code
 and   chr.k_header_id = p_source_k_header_id;

 cursor c_dest_doc_class is
 select type_class_code
 from  OKE_K_TYPES_b
 where k_type_code =  p_dest_doc_type;


l_role 			NUMBER;
l_person 		NUMBER;
l_start_date		DATE:=NULL;
l_end_date		DATE:=NULL;
l_project_party_id 	NUMBER;
l_resource_id		NUMBER;
l_assignment_id		NUMBER;
l_record_version	NUMBER;

l_cpsv_tbl_in             okc_contract_pub.cpsv_tbl_type;
l_cpsv_tbl_out            okc_contract_pub.cpsv_tbl_type;
l_source_doc_class        varchar2(30);
l_dest_doc_class        varchar2(30);


BEGIN
    g_pty_not_copied := FALSE;
   -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- initialize return status
    x_return_status := OKE_API.G_RET_STS_SUCCESS;

--  Get contract header value from oke side.
    get_oke_k_header_rec(p_source_k_header_id,
			l_chr_rec,
			l_return_status);
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


--  Get contract header value from okc side.
    get_okc_k_header_rec(p_source_k_header_id,
			l_chrv_rec,
			l_return_status);
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


l_chrv_rec.contract_number := p_dest_doc_number;
l_chrv_rec.contract_number_modifier :=
	p_dest_doc_type||'.'||p_dest_buy_or_sell||'.'||p_dest_boa_id;
l_chr_rec.k_type_code := p_dest_doc_type;
l_chrv_rec.buy_or_sell := p_dest_buy_or_sell;
l_chrv_rec.currency_code := p_dest_currency_code;
l_chrv_rec.start_date := p_dest_start_date;
l_chrv_rec.end_date := p_dest_end_date;
l_chrv_rec.template_yn := p_dest_template_yn;
l_chr_rec.boa_id := p_dest_boa_id;
l_chrv_rec.authoring_org_id := p_dest_authoring_org_id;
l_chrv_rec.inv_organization_id :=p_dest_inv_organization_id;



	get_status(l_chrv_rec.sts_code);

        g_projh_overlap_allowed := fnd_profile.value('OKE_PROJH_OVERLAP_ALLOWED');
	l_chr_rec.AUTHORIZE_DATE:=null;
	l_chr_rec.AWARD_CANCEL_DATE:=null;
	l_chr_rec.AWARD_DATE:=null;
	l_chr_rec.DATE_DEFINITIZED:=null;
	l_chr_rec.DATE_ISSUED:=null;
	l_chr_rec.DATE_NEGOTIATED:=null;
	l_chr_rec.DATE_RECEIVED:=null;
	l_chr_rec.DATE_SIGN_BY_CONTRACTOR:=null;
	l_chr_rec.DATE_SIGN_BY_CUSTOMER:=null;
	l_chr_rec.FAA_APPROVE_DATE:=null;
	l_chr_rec.FAA_REJECT_DATE:=null;
	l_chr_rec.PROP_DUE_DATE_TIME:=null;
	l_chr_rec.PROP_EXPIRE_DATE:=null;
      IF p_copy_projecttask_yn = 'N' then
        g_proj_copy_allowed := 'N';
      ELSE
        If g_projh_overlap_allowed = 'DISALLOW' THEN
         open c_source_doc_class;
         fetch c_source_doc_class into l_source_doc_class;
         close c_source_doc_class;

         open c_dest_doc_class;
         fetch c_dest_doc_class into l_dest_doc_class;
         close c_dest_doc_class;
         If l_dest_doc_class =l_source_doc_class then
           g_proj_copy_allowed := 'N';
         else
          g_proj_copy_allowed := 'Y';
         end if;
        else
          g_proj_copy_allowed := 'Y';
      End if;
     END IF;

      If g_proj_copy_allowed ='N' then
         l_chr_rec.PROJECT_ID := null;
         l_chr_rec.DEFAULT_TASK_ID := null;
      end if;

	l_chrv_rec.DATE_APPROVED:=null;
	l_chrv_rec.DATETIME_CANCELLED:=null;
	l_chrv_rec.DATE_ISSUED:=null;
        l_chrv_rec.DATETIME_RESPONDED:=null;
        l_chrv_rec.DATE_CLOSE_PROJECTED:=null;
        l_chrv_rec.DATETIME_PROPOSED:=null;
        l_chrv_rec.DATE_SIGNED:=null;
        l_chrv_rec.DATE_TERMINATED:=null;
        l_chrv_rec.DATE_RENEWED:=null;


-- Create contract header
	OKE_CONTRACT_PUB.create_contract_header(
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		x_return_status 	=> l_return_status,
		x_msg_count     	=> x_msg_count,
		x_msg_data      	=> x_msg_data,
      		p_chr_rec		=> l_chr_rec,
		p_chrv_rec		=> l_chrv_rec,
      		x_chr_rec		=> x_chr_rec,
		x_chrv_rec		=> x_chrv_rec);

		If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   IF p_copy_admin_yn = 'Y' then
          open c_get_process;
    fetch c_get_process into
        l_cpsv_tbl_in(1).PDF_ID ,
        l_cpsv_tbl_in(1).ATTRIBUTE_CATEGORY ,
        l_cpsv_tbl_in(1).ATTRIBUTE1 ,
        l_cpsv_tbl_in(1).ATTRIBUTE2 ,
        l_cpsv_tbl_in(1).ATTRIBUTE3 ,
        l_cpsv_tbl_in(1).ATTRIBUTE4 ,
        l_cpsv_tbl_in(1).ATTRIBUTE5 ,
        l_cpsv_tbl_in(1).ATTRIBUTE6 ,
        l_cpsv_tbl_in(1).ATTRIBUTE7 ,
        l_cpsv_tbl_in(1).ATTRIBUTE8 ,
        l_cpsv_tbl_in(1).ATTRIBUTE9 ,
        l_cpsv_tbl_in(1).ATTRIBUTE10 ,
        l_cpsv_tbl_in(1).ATTRIBUTE11 ,
        l_cpsv_tbl_in(1).ATTRIBUTE12 ,
        l_cpsv_tbl_in(1).ATTRIBUTE13 ,
        l_cpsv_tbl_in(1).ATTRIBUTE14 ,
        l_cpsv_tbl_in(1).ATTRIBUTE15 ;

        l_cpsv_tbl_in(1).chr_ID := x_chr_rec.k_header_id;

    If c_get_process%found then
        okc_contract_pub.create_contract_process
             ( p_api_version   => l_api_version
             , p_init_msg_list => p_init_msg_list
             , x_return_status => l_return_status
             , x_msg_count     => x_msg_count
             , x_msg_data      => x_msg_data
             , p_cpsv_tbl      => l_cpsv_tbl_in
             , x_cpsv_tbl      => l_cpsv_tbl_out
             );

	    	If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;
       end if;
       close c_get_process;


	OPEN c_access;
	LOOP
	FETCH c_access INTO l_role,l_person,l_start_date,l_end_date;
	EXIT WHEN c_access%NOTFOUND;

	OKE_K_ACCESS_PVT.CREATE_CONTRACT_ACCESS
	( P_COMMIT                     =>	OKE_API.G_FALSE,
	  P_OBJECT_TYPE                =>	'OKE_K_HEADERS',
	  P_OBJECT_ID                  =>     	x_chr_rec.k_header_id,
	  P_ROLE_ID                    =>	l_role,
	  P_PERSON_ID                  =>	l_person,
	  P_START_DATE_ACTIVE          =>	l_start_date,
	  P_END_DATE_ACTIVE            =>	l_end_date,
	  X_PROJECT_PARTY_ID           =>	l_project_party_id,
	  X_RESOURCE_ID                =>	l_resource_id,
	  X_ASSIGNMENT_ID              =>	l_assignment_id,
	  X_RECORD_VERSION_NUMBER      =>	l_record_version,
	  X_RETURN_STATUS              =>	l_return_status,
	  X_MSG_COUNT                  =>	x_msg_count,
	  X_MSG_DATA                   =>	x_msg_data
	);
		If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

	END LOOP;
   END IF;

	insert into oke_k_billing_methods
	(k_header_id,
	 billing_method_code,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 default_flag,
	 attribute_category,
	 attribute1,attribute2,
	 attribute3,attribute4,
	 attribute5,attribute6,
	 attribute7,attribute8,
	 attribute9,attribute10,
	 attribute11,attribute12,
	 attribute13,attribute14,
	 attribute15
	 )
	select x_chr_rec.k_header_id,billing_method_code,sysdate,
		fnd_global.user_id,sysdate,fnd_global.user_id,
		fnd_global.login_id,
		default_flag,attribute_category,attribute1,attribute2,
		attribute3,attribute4,attribute5,attribute6,attribute7,
		attribute8,attribute9,attribute10,attribute11,attribute12,
		attribute13,attribute14,attribute15

		from oke_k_billing_methods

		where k_header_id = p_source_k_header_id;




    x_dest_k_header_id := x_chr_rec.k_header_id;
   IF p_copy_parties = 'Y' then
	copy_party_roles( p_api_version      	,
    			  p_init_msg_list    	,
    			  l_return_status 	,
    			  x_msg_count    	,
    			  x_msg_data         	,
			  l_chr_rec.k_header_id	,
			  x_chr_rec.k_header_id	,
			  null			,
			  null			,
			  l_chr_rec.k_header_id );

		If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

   End If;

   IF p_copy_articles = 'Y' then
	copy_articles(	p_api_version		,
    			p_init_msg_list		,
    			l_return_status		,
    			x_msg_count		,
    			x_msg_data		,
			l_chr_rec.k_header_id	,
			x_chr_rec.k_header_id	,
			null			,
			null			);

		If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

    End If;

-- Copy Terms for Contract Header

   IF p_copy_tncs = 'Y' then

   OKE_TERMS_PUB.copy_term(
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		x_return_status 	=> l_return_status,
		x_msg_count     	=> x_msg_count,
		x_msg_data      	=> x_msg_data,
    		p_from_level		=> 'H',
    		p_to_level		=> 'H',
    		p_from_chr_id		=> p_source_k_header_id,
    		p_to_chr_id		=> x_chr_rec.k_header_id,
    		p_from_cle_id		=> NULL,
    		p_to_cle_id		=> NULL
    );


		If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;
   End If;


-- Copy Standard Notes

   IF p_copy_standard_notes = 'Y' then
    OKE_STANDARD_NOTES_PUB.copy_standard_note(
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		x_return_status 	=> l_return_status,
		x_msg_count     	=> x_msg_count,
		x_msg_data      	=> x_msg_data,
      		p_from_hdr_id		=> p_source_k_header_id,
    		p_to_hdr_id	 	=> x_chr_rec.k_header_id,
    		p_from_cle_id		=> null,
    		p_to_cle_id		=> null,
    		p_from_del_id		=> null,
    		p_to_del_id		=> null,
		default_flag		=> 'N'
     );

		If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;

    End If;

   -- copy user attributes (header)

   IF p_copy_user_attributes = 'Y' then

      copy_user_attributes (p_k_header_id 	=>	 p_source_k_header_id	,
      			    p_k_header_id_new   =>       x_chr_rec.k_header_id  );

   END IF;



  IF p_copy_lines = 'Y' then

	OPEN c_check_org(p_source_k_header_id,x_chr_rec.k_header_id);
	FETCH c_check_org INTO l_check;
	CLOSE c_check_org;

	IF l_check = 'x' THEN
		l_check := 'Y';
	ELSE
		OKE_API.SET_MESSAGE   (
                p_app_name              =>'OKE',
                p_msg_name              =>'OKE_KCOPY_ITEMS_NOCOPY');
        x_return_status := OKE_API.G_RET_STS_WARNING;
		l_check := 'N';
	END IF;


       copy_contract_lines( p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> l_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
		    	f_k_header_id 		=> p_source_k_header_id,
		    	n_k_header_id 		=> x_chr_rec.k_header_id,
		    	l_copy_parties		=> p_copy_parties,
		    	l_copy_tncs		=> p_copy_tncs,
		    	l_copy_articles		=> p_copy_articles,
		    	l_copy_standard_notes	=> p_copy_standard_notes,
		    	l_copy_user_att		=> p_copy_user_attributes,
                        p_copy_projecttask_yn   => p_copy_projecttask_yn,
			l_copy_items		=> l_check,
			start_date		=> --NULL,
						p_dest_start_date	,
			end_date		=> NULL);
						--p_dest_end_date	);

		If l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
          		raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		Elsif l_return_status = OKE_API.G_RET_STS_ERROR Then
          		raise OKE_API.G_EXCEPTION_ERROR;
    		End If;


   END IF;

-- recalculate totals now -- bug#4302591
   Calculate_Totals(x_chr_rec.k_header_id);

    IF g_pty_not_copied THEN
      OKE_API.SET_MESSAGE   (
                p_app_name  => 'OKE',
                p_msg_name  => 'OKE_KCOPY_PARTIES_NOCOPY');
      x_return_status := OKE_API.G_RET_STS_WARNING;
    END IF;

    IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count
      , p_data   => x_msg_data
      );
    END IF;

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

END copy_contract;


END OKE_KCOPY_PKG;

/
