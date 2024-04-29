--------------------------------------------------------
--  DDL for Package Body OKC_EURO_CONV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_EURO_CONV_PUB" as
/* $Header: OKCPEURB.pls 120.1.12010000.2 2008/11/12 15:42:27 vgujarat ship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
--
----------------------------------------------------------------------------
--
g_api_version constant number :=1;
g_init_msg_list varchar2(1) := OKC_API.G_FALSE;
g_msg_count NUMBER;
g_msg_data varchar2(2000);
g_conversion_type  VARCHAR2(200)  ;
g_conversion_rate_date DATE;
---
--Set header rec:
--This procedure populates the table of record with the contract
--hdr infomation to be updated
----
 FUNCTION set_header_rec(p_chr_rec OKC_K_HEADERS_B%ROWTYPE, x_return_status OUT NOCOPY VARCHAR2 )
          RETURN OKC_CONTRACT_PUB.chrv_tbl_type IS
    x_chrv_rec OKC_CONTRACT_PUB.chrv_rec_type;
    x_chrv_tbl OKC_CONTRACT_PUB.chrv_tbl_type;
    l_rate number;
    l_euro_rate number;
    l_proc  VARCHAR2(30)  := 'set header rec';
    l_return_status varchar2(1) :='S';
 BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_EURO_CONV_PUB');
       okc_debug.log('200: Entered set header rec', 2);
    END IF;

    x_chrv_rec.id := p_chr_rec.id;
    x_chrv_rec.contract_number := p_chr_rec.contract_number;
    x_chrv_rec.authoring_org_id := p_chr_rec.authoring_org_id;
    x_chrv_rec.contract_number_modifier := p_chr_rec.contract_number_modifier;
    x_chrv_rec.chr_id_response := p_chr_rec.chr_id_response;
    x_chrv_rec.chr_id_award := p_chr_rec.chr_id_award;
    x_chrv_rec.INV_ORGANIZATION_ID := p_chr_rec.INV_ORGANIZATION_ID;
    x_chrv_rec.sts_code := p_chr_rec.sts_code;
    x_chrv_rec.qcl_id := p_chr_rec.qcl_id;
    x_chrv_rec.scs_code := p_chr_rec.scs_code;
    x_chrv_rec.trn_code := p_chr_rec.trn_code;
    x_chrv_rec.currency_code := p_chr_rec.currency_code;
    x_chrv_rec.archived_yn := p_chr_rec.archived_yn;
    x_chrv_rec.deleted_yn := p_chr_rec.deleted_yn;
    x_chrv_rec.template_yn := p_chr_rec.template_yn;
    x_chrv_rec.chr_type := p_chr_rec.chr_type;
    x_chrv_rec.object_version_number := p_chr_rec.object_version_number;
    x_chrv_rec.created_by := p_chr_rec.created_by;
    x_chrv_rec.creation_date := p_chr_rec.creation_date;
    x_chrv_rec.last_updated_by := p_chr_rec.last_updated_by;
    x_chrv_rec.last_update_date := p_chr_rec.last_update_date;
    x_chrv_rec.cust_po_number_req_yn := p_chr_rec.cust_po_number_req_yn;
    x_chrv_rec.pre_pay_req_yn := p_chr_rec.pre_pay_req_yn;
    x_chrv_rec.cust_po_number := p_chr_rec.cust_po_number;
    x_chrv_rec.dpas_rating := p_chr_rec.dpas_rating;
    x_chrv_rec.template_used := p_chr_rec.template_used;
    x_chrv_rec.date_approved := p_chr_rec.date_approved;
    x_chrv_rec.datetime_cancelled := p_chr_rec.datetime_cancelled;
    x_chrv_rec.auto_renew_days := p_chr_rec.auto_renew_days;
    x_chrv_rec.date_issued := p_chr_rec.date_issued;
    x_chrv_rec.datetime_responded := p_chr_rec.datetime_responded;
    x_chrv_rec.rfp_type := p_chr_rec.rfp_type;
    x_chrv_rec.keep_on_mail_list := p_chr_rec.keep_on_mail_list;
    x_chrv_rec.set_aside_percent := p_chr_rec.set_aside_percent;
    x_chrv_rec.response_copies_req := p_chr_rec.response_copies_req;
    x_chrv_rec.date_close_projected := p_chr_rec.date_close_projected;
    x_chrv_rec.datetime_proposed := p_chr_rec.datetime_proposed;
    x_chrv_rec.date_signed := p_chr_rec.date_signed;
    x_chrv_rec.date_terminated := p_chr_rec.date_terminated;
    x_chrv_rec.date_renewed := p_chr_rec.date_renewed;
    x_chrv_rec.start_date := p_chr_rec.start_date;
    x_chrv_rec.end_date := p_chr_rec.end_date;
    x_chrv_rec.buy_or_sell := p_chr_rec.buy_or_sell;
    x_chrv_rec.issue_or_receive := p_chr_rec.issue_or_receive;
    x_chrv_rec.estimated_amount := p_chr_rec.estimated_amount;
    x_chrv_rec.estimated_amount_renewed := p_chr_rec.estimated_amount_renewed;
    x_chrv_rec.currency_code_renewed := p_chr_rec.currency_code_renewed;
    x_chrv_rec.last_update_login := p_chr_rec.last_update_login;
    x_chrv_rec.upg_orig_system_ref := p_chr_rec.upg_orig_system_ref;
    x_chrv_rec.upg_orig_system_ref_id := p_chr_rec.upg_orig_system_ref_id;
    x_chrv_rec.application_id := p_chr_rec.application_id;
    x_chrv_rec.orig_system_source_code := p_chr_rec.orig_system_source_code;
    x_chrv_rec.orig_system_id1 := p_chr_rec.orig_system_id1;
    x_chrv_rec.orig_system_reference1 := p_chr_rec.orig_system_reference1 ;
    x_chrv_rec.program_id   	       := p_chr_rec.program_id;
    x_chrv_rec.request_id   	       := p_chr_rec.request_id;
    x_chrv_rec.program_update_date   := p_chr_rec.program_update_date;
    x_chrv_rec.program_application_id  := p_chr_rec.program_application_id;
    x_chrv_rec.price_list_id         := p_chr_rec.price_list_id;
    x_chrv_rec.pricing_date          := p_chr_rec.pricing_date;
    x_chrv_rec.sign_by_date          := p_chr_rec.sign_by_date;
    x_chrv_rec.total_line_list_price   := p_chr_rec.total_line_list_price;
    x_chrv_rec.USER_ESTIMATED_AMOUNT   := p_chr_rec.USER_ESTIMATED_AMOUNT;
    x_chrv_rec.governing_contract_yn   := p_chr_rec.governing_contract_yn;
    x_chrv_rec.attribute_category := p_chr_rec.attribute_category;
    x_chrv_rec.attribute1 := p_chr_rec.attribute1;
    x_chrv_rec.attribute2 := p_chr_rec.attribute2;
    x_chrv_rec.attribute3 := p_chr_rec.attribute3;
    x_chrv_rec.attribute4 := p_chr_rec.attribute4;
    x_chrv_rec.attribute5 := p_chr_rec.attribute5;
    x_chrv_rec.attribute6 := p_chr_rec.attribute6;
    x_chrv_rec.attribute7 := p_chr_rec.attribute7;
    x_chrv_rec.attribute8 := p_chr_rec.attribute8;
    x_chrv_rec.attribute9 := p_chr_rec.attribute9;
    x_chrv_rec.attribute10 := p_chr_rec.attribute10;
    x_chrv_rec.attribute11 := p_chr_rec.attribute11;
    x_chrv_rec.attribute12 := p_chr_rec.attribute12;
    x_chrv_rec.attribute13 := p_chr_rec.attribute13;
    x_chrv_rec.attribute14 := p_chr_rec.attribute14;
    x_chrv_rec.attribute15 := p_chr_rec.attribute15;
 --new columns to replace rules
    x_chrv_rec.conversion_type        := p_chr_rec.conversion_type;
    x_chrv_rec.conversion_rate        := p_chr_rec.conversion_rate;
    x_chrv_rec.conversion_rate_date   := p_chr_rec.conversion_rate_date;
    x_chrv_rec.conversion_euro_rate   := p_chr_rec.conversion_euro_rate;
    x_chrv_rec.cust_acct_id           := p_chr_rec.cust_acct_id;
    x_chrv_rec.bill_to_site_use_id    := p_chr_rec.bill_to_site_use_id;
    x_chrv_rec.inv_rule_id            := p_chr_rec.inv_rule_id;
    x_chrv_rec.renewal_type_code      := p_chr_rec.renewal_type_code;
    x_chrv_rec.renewal_notify_to      := p_chr_rec.renewal_notify_to;
    x_chrv_rec.renewal_end_date       := p_chr_rec.renewal_end_date;
    x_chrv_rec.ship_to_site_use_id    := p_chr_rec.ship_to_site_use_id;
    x_chrv_rec.payment_term_id        := p_chr_rec.payment_term_id;

    x_chrv_tbl(1) := x_chrv_rec;


        x_chrv_tbl(1).conversion_type:=g_conversion_type;
        x_chrv_tbl(1).conversion_rate_date := g_conversion_rate_date;

--get rates
        okc_currency_api.get_rate(
        p_FROM_CURRENCY   => x_chrv_tbl(1).currency_code
         ,p_TO_CURRENCY     => okc_currency_api.get_ou_currency(x_chrv_tbl(1).authoring_org_id)
         ,p_CONVERSION_DATE => g_conversion_rate_date
         ,p_CONVERSION_TYPE => x_chrv_tbl(1).conversion_type
         ,x_CONVERSION_RATE => l_rate
         ,x_EURO_RATE       => l_euro_rate
         ,x_return_status   => l_return_status);

          x_return_status := l_return_status;

        IF (l_debug = 'Y') THEN
           okc_debug.log('okc_currency_api.get_rate is ' || l_return_status);
        END IF;
        IF l_return_status <> 'S' THEN
          RETURN x_chrv_tbl;
        END IF;

        x_chrv_tbl(1).conversion_rate := l_rate;

        IF l_euro_rate IS NOT NULL THEN
          x_chrv_tbl(1).conversion_euro_rate := l_rate;
          x_chrv_tbl(1).conversion_rate := l_euro_rate;
        END IF;


       return x_chrv_tbl;
EXCEPTION
 WHEN others THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('400: Exiting set_header_rec:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;
     x_return_status:='U';

     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
End ;


----This procecure is added for rules migration, conversion data now resides in okc_k_headers_b
--Add conversion data
--This procedure updates the header record if no/incomplete conversion data
----

Procedure Add_conversion_data(p_contracts_rec IN okc_k_headers_b%rowtype,
                              p_update_mode IN VARCHAR2 ,
                              x_return_status  OUT NOCOPY VARCHAR2 ) is

  l_proc  VARCHAR2(30)   := 'Add_Conversion_data';
  l_return_status  VARCHAR2(1)  := 'S';
  y_return_status  VARCHAR2(1)  := 'S';
  p_update_all  VARCHAR2(1)  ;
  l_chrv_tbl OKC_CONTRACT_PUB.chrv_tbl_type;
  x_chrv_tbl OKC_CONTRACT_PUB.chrv_tbl_type;

BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_EURO_CONV_PUB');
       okc_debug.log('600: Entered Add_conversion_data', 2);
    END IF;


  If
      (p_contracts_rec.conversion_type is null AND
      p_contracts_rec.conversion_rate is null AND
      p_contracts_rec.conversion_rate_date  is null)  THEN
       p_update_all := 'Y' ;
      IF (l_debug = 'Y') THEN
        okc_debug.log('625: No conversion data found',2);
      END IF;

  Elsif
      (p_contracts_rec.conversion_type is null OR
       p_contracts_rec.conversion_rate is null OR
       p_contracts_rec.conversion_rate_date  is null)  THEN
       p_update_all := 'N' ;
       IF (l_debug = 'Y') THEN
              okc_debug.log('650: Conversion data found, VALUES:'||
                      p_contracts_rec.conversion_rate || '/' ||
                      p_contracts_rec.conversion_rate_date || '/' ||
                      p_contracts_rec.conversion_type,2);
       END IF;
  Else
      p_update_all:= 'X';
     x_return_status:= 'N';
  End If;


-- If update mode is yes update the record if all or any of the
-- conversuion data apart from euro rate is missing

  If p_update_mode = 'Y'  and p_update_all in ('Y','N') then

--get values from DB into record
     l_chrv_tbl := set_header_rec(p_contracts_rec, y_return_status);

     If y_return_status = 'S' Then

	   IF (l_debug = 'Y') THEN
   	   okc_debug.log('640: Calling update_contract_header');
	   END IF;

        OKC_CONTRACT_PUB.update_contract_header(
         		p_api_version	=> g_api_version,
                p_init_msg_list => g_init_msg_list,
                x_return_status => l_return_status,
                x_msg_count	=> g_msg_count,
                x_msg_data	=> g_msg_data,
                p_chrv_tbl	=> l_chrv_tbl,
                x_chrv_tbl	=> x_chrv_tbl);

        x_return_status := l_return_status;
        IF (l_debug = 'Y') THEN
           okc_debug.log('635: update_header returns ' || l_return_status);
        END IF;

    Else
		 If l_debug = 'Y' Then
		  okc_debug.log('636:set header returns error');
           End If;
    End If;
  Else
        IF p_update_all = 'Y' THEN
           x_return_status := 'A';
        Elsif p_update_all ='N' Then
            x_return_status := 'U';
        END IF;
  End If;

  IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting Add_Conversion_data', 2);
       okc_debug.Reset_Indentation;
  END IF;


EXCEPTION

WHEN others THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting Add_Conversion_data:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);

END;


/*----------------------------------------------------------------------------
 Procudure Convert_Contracts
*----------------------------------------------------------------------------*/
PROCEDURE CONVERT_CONTRACTS (
 errbuf     OUT NOCOPY VARCHAR2,
 retcode    OUT NOCOPY VARCHAR2,
 p_org_id          NUMBER,
 p_conversion_type VARCHAR2,
 p_conversion_date  VARCHAR2,
 p_update_yn VARCHAR2 )  IS


  Cursor contracts_csr is
   Select CHRB.*
   from okc_k_headers_b CHRB, okc_subclasses_b SCS
   where CHRB.template_yn='N'
   and (CHRB.sts_code in (select code from okc_statuses_b
                          where ste_code in ('ACTIVE','SIGNED','HOLD'))
         OR
	    CHRB.sts_code in (select code from okc_statuses_b
					  where ste_code='EXPIRED'
					  and date_renewed is null))

    and CHRB.scs_code = SCS.code
    and SCS.cls_code = 'SERVICE'
    and authoring_org_id = p_org_id;

  l_funct_currency  VARCHAR2(3);
  l_proc            VARCHAR2(30)   := 'Convert_Contracts';
  l_upgrade_status_hdr  VARCHAR2(30) ;
  l_upgrade_status  VARCHAR2(80) ;
  l_report_title    VARCHAR2(80) ;
  NO_CONVERSION_RQD Exception;
  p_update_mode_yn   VARCHAR2(1);
  l_return_status   VARCHAR2(1);
  l_conversion_date DATE;
  l_record_processed      NUMBER := 0;
  k_counter         NUMBER := 0;
  k1_counter         NUMBER := 0;
  k_success_counter         NUMBER := 0;
  k_failure_counter         NUMBER := 0;

BEGIN

p_update_mode_yn := nvl(p_update_yn,'N');
IF NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y' THEN
    okc_util.init_trace;
    fnd_file.put_line(FND_FILE.LOG,'Trace Mode is Enabled');
  END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_EURO_CONV_PUB');
       okc_debug.log('900: Entered CONVERT_CONTRACTS', 2);
    END IF;

  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');
  fnd_file.put_line(FND_FILE.LOG,'        Starting Concurrent Program ... ');
  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  -- log session details
  fnd_file.put_line(FND_FILE.LOG,' ********** DATABASE TRACE INFORMATION*************** ');
  fnd_file.put_line(FND_FILE.LOG,'User id :     '||fnd_global.user_id);
  fnd_file.put_line(FND_FILE.LOG,'Conc Req id : '||fnd_global.conc_request_id);
  fnd_file.put_line(FND_FILE.LOG,' **************************************************** ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');

  -- log messages with parameters
  fnd_file.put_line(FND_FILE.LOG,' *********   Program Parameters **************** ');
  fnd_file.put_line(FND_FILE.LOG,' Update Mode       :'||p_update_mode_yn);
  fnd_file.put_line(FND_FILE.LOG,' Conversion Date   :'||p_conversion_date);
  fnd_file.put_line(FND_FILE.LOG,' Conversion Type   :'||p_conversion_type);
  fnd_file.put_line(FND_FILE.LOG,' Organization Id   :'||p_org_id);
  fnd_file.put_line(FND_FILE.LOG,' **************************************************** ');
  fnd_file.put_line(FND_FILE.LOG,'  ');

  fnd_file.put_line(FND_FILE.OUTPUT,' *********   Program Parameters **************** ');
  fnd_file.put_line(FND_FILE.OUTPUT,' Update Mode       :'||p_update_mode_yn);
  fnd_file.put_line(FND_FILE.OUTPUT,' Conversion Date   :'||p_conversion_date);
  fnd_file.put_line(FND_FILE.OUTPUT,' Conversion Type   :'||p_conversion_type);
  fnd_file.put_line(FND_FILE.OUTPUT,' Organization Id   :'||p_org_id);
  fnd_file.put_line(FND_FILE.OUTPUT,' ************************************************ ');

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: p_org_id   :            '||p_org_id,2);
     okc_debug.Log('20: p_conversion_date  :     '||p_conversion_date,2);
     okc_debug.Log('20: p_conversion_type    :   '||p_conversion_type,2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('25: User ID :     '||fnd_global.user_id,2);
     okc_debug.Log('25: Conc Req ID : '||fnd_global.conc_request_id,2);
  END IF;

  g_conversion_type := p_conversion_type;
  g_conversion_rate_date := fnd_date.canonical_to_date(p_conversion_date);

   Select currency_code
   into l_funct_currency
   from okx_set_of_books_v
   where set_of_books_id=(select set_of_books_id
                        from hr_operating_units
                        where  organization_id = p_org_id);

   If l_funct_currency <> 'EUR' then
      RAISE NO_CONVERSION_RQD;
   End If;

   -- set okc org context for this organization
   okc_context.SET_OKC_ORG_CONTEXT(P_ORG_ID => p_org_id);

  If p_update_mode_yn = 'Y' then

    l_report_title:='CONTRACTS PROCESSED FOR EURO CONVERSION';
    l_upgrade_status_hdr := 'Upgrade Status';
  Else
    l_report_title:='CONTRACTS TO BE PROCESSED FOR EURO CONVERSION';
    l_upgrade_status_hdr:='Upgrade changes Needed';
  End If;
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,lpad(l_report_title,90));
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,
    '-----------------------------------------------------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,
    rpad('Contract Number',30)||rpad('Modifier',20)||rpad('Currency Code',15)||rpad('Status',10)||
    rpad('Start_date',15)||rpad('End date',15)||rpad(l_upgrade_status_hdr,30));

    fnd_file.put_line(FND_FILE.OUTPUT,
    '=============================================================================================================================');
    FOR contracts_rec IN contracts_csr LOOP
---   Check if contract eligible for conversion
--dbms_output.put_line(contracts_rec.contract_number);

     If  OKC_CURRENCY_API.IS_EURO_CONVERSION_NEEDED(contracts_rec.currency_code)= 'Y' then

		-- increment counter
		k_counter := k_counter + 1;
          k1_counter:= k1_counter +1;
		IF (l_debug = 'Y') THEN
   		okc_debug.log('1000: Processing '||
				    (contracts_rec.contract_number || '(' ||
				    contracts_rec.contract_number_modifier || ')' ||
				    ' Currency: ' || contracts_rec.currency_code ||
				    ' Status: ' || contracts_rec.sts_code), 2);
		END IF;

/*          fnd_file.put_line(FND_FILE.OUTPUT,contracts_rec.contract_number,20) ||
					   ', '|| contracts_rec.contract_number_modifier ||
					   ', '|| contracts_rec.currency_code ||
					   ', '|| contracts_rec.sts_code);*/

            add_conversion_data(p_contracts_rec =>contracts_rec,
			    p_update_mode          =>p_update_mode_yn,
			    x_return_status        =>l_return_status);

          If p_update_mode_YN = 'Y' Then
             If l_return_status='S' Then
               k_success_counter := k_success_counter+1;
               IF (l_debug = 'Y') THEN
                  okc_debug.log('1200: Record Updated ', 2);
               END IF;
             Elsif l_return_status = 'N' Then
              k_success_counter := k_success_counter+1;
              IF (l_debug = 'Y') THEN
                 okc_debug.log('1100: Upgrade not required ', 2);
              END IF;
		   Else
		    fnd_message.set_name('OKC','OKC_K_CONV_ERROR');
		    fnd_message.set_token('CONTRACT_NUMBER',contracts_rec.contract_number);
		    fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
              IF (l_debug = 'Y') THEN
                 okc_debug.log('1100: Record not Updated ', 2);
              END IF;
		    k_failure_counter := k_failure_counter+1;
		  end If;
--dbms_output.put_line(contracts_rec.contract_number);

            If (k_counter >= 1000) Then
              commit;
	         k_counter := 0;
            End If;
          End If;

--replaced by stmt below for rules migration
        /* select decode(p_update_mode_yn,'Y',decode(l_return_status,'S','Successful','N',
               	'No change ','Failed'),decode(l_return_status,'U','Incomplete CVN Rule',
				'A','No CVN rule','N','No change required'))
         into l_upgrade_status
	    from dual;*/

         select decode(p_update_mode_yn,'Y',decode(l_return_status,'S','Successful','N',
                    'No change ','Failed'),decode(l_return_status,'U','Incomplete Conversion data',
                    'A','No Conversion data ','N','No change required'))
         into l_upgrade_status
         from dual;

         fnd_file.put_line(FND_FILE.OUTPUT,rpad(contracts_rec.contract_number,30)||
					    substr(rpad(nvl(contracts_rec.contract_number_modifier,'X'),21),2)||
					    rpad(contracts_rec.currency_code,15)||
					    rpad(contracts_rec.sts_code,10)||
					    rpad(contracts_rec.start_date,15)||
					    substr(rpad(nvl(to_char(contracts_rec.end_date),'X'),15),2)||
					    rpad(l_upgrade_status,30));
    End If;

  END LOOP;


  fnd_file.put_line(FND_FILE.OUTPUT,
    '----------------------------------------------------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,'Total Contracts processed :      '||k1_counter);
    fnd_file.put_line(FND_FILE.LOG,'Total Contracts processed :      '||k1_counter);

  IF (l_debug = 'Y') THEN
     okc_debug.log('1115: After LOOP' || 'Contracts proccessed' ,2);
  END IF;

  If p_update_mode_yn = 'Y' then
    fnd_file.put_line(FND_FILE.OUTPUT,'Number of Contracts - Success:    '||k_success_counter);
    fnd_file.put_line(FND_FILE.OUTPUT,'Number of Contracts - Failure:    '||k_failure_counter);
     commit;
  End If;

  IF (l_debug = 'Y') THEN
     okc_debug.log('1100: ' || k1_counter || 'Contracts Processed' ,2);
  END IF;

  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');
  fnd_file.put_line(FND_FILE.LOG,'Completed Concurrent Program. ');
  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');

  IF NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y' THEN
   okc_util.stop_trace;
  END IF;

   IF (l_debug = 'Y') THEN
      okc_debug.log('1100: Exiting CONVERT_CONTRACTS', 2);
      okc_debug.Reset_Indentation;
   END IF;


 EXCEPTION

  WHEN NO_CONVERSION_RQD then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting CONVERT_CONTRACTS:NO_CONVERSION_RQD Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

  fnd_message.set_name('OKC','OKC_CONV_NOT_REQD');
  fnd_file.put_line(FND_FILE.LOG,fnd_message.get);

  WHEN others THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting CONVERT_CONTRACTS:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     raise;


  END CONVERT_CONTRACTS;

end OKC_EURO_CONV_PUB;

/
