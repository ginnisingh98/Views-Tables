--------------------------------------------------------
--  DDL for Package Body IGI_CIS_RESUBMIT_MTH_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_RESUBMIT_MTH_RT_PKG" AS
/* $Header: igicisrsmrb.pls 120.0.12010000.19 2018/01/11 07:49:36 sthatich noship $ */
  --==========================================================================
  ----Logging Declarations
  --==========================================================================
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER     :=  FND_LOG.LEVEL_PROCEDURE;
  C_EVENT_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EVENT;
  C_EXCEP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EXCEPTION;
  C_ERROR_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_ERROR;
  C_UNEXP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_UNEXPECTED;
  g_log_level   CONSTANT NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_path_name   CONSTANT VARCHAR2(100)  := 'igi.plsql.igirsmthrb.IGI_CIS_RESUBMIT_MTH_RT_PKG';

  PROCEDURE log
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS

  BEGIN
    IF (p_level >= g_log_level ) THEN
      FND_LOG.STRING(p_level, p_procedure_name, p_debug_info);
    END IF;
  END log;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    log(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    log(C_STATE_LEVEL, l_procedure_name, '$Header: igicisrsmrb.pls 120.0.12010000.19 2018/01/11 07:49:36 sthatich noship $');
  END;


procedure upload_and_summarize_hist_tab (p_errbuf OUT NOCOPY VARCHAR2,p_retcode OUT NOCOPY NUMBER, p_period_name IN varchar2)
is
l_procedure_name         VARCHAR2(100):='.upload_and_summarize_hist_tab';
l_current_version NUMBER:=0;
l_status_count NUMBER:=0;
l_action_count number:=0;
l_new_header_id number:=0;
l_old_header_id number:=0;
l_new_ver_num NUMBER:=0;
l_user_id NUMBER:= FND_GLOBAL.USER_ID();
l_login_id NUMBER:=FND_GLOBAL.LOGIN_ID();
l_org_id NUMBER:=fnd_profile.value('ORG_ID');
l_ver_exists NUMBER:=0;
l_retcode NUMBER:=0;
l_errbuf VARCHAR2(1000);
l_nil_return_sum NUMBER := 0;
l_nil_status VARCHAR2(1) := 'Y';

--Added by subhakar for bug 25941704
l_cis_sender_id VARCHAR2(30);
l_paye_reference VARCHAR2(30);
l_tax_office_number NUMBER(15);
l_accounts_office_reference VARCHAR2(30);
l_unique_tax_reference_num NUMBER(15);
l_sql_exception EXCEPTION;

cursor summarize_lines_cur(p_period VARCHAR2, p_org_id number) is
select
      pay.vendor_id VENDOR_ID,
      pay.VENDOR_NAME VENDOR_NAME,
      pov.vendor_type_lookup_code VENDOR_TYPE_LOOKUP_CODE,
      pov.first_name FIRST_NAME,
      pov.second_name SECOND_NAME,
      pov.last_name LAST_NAME,
      pov.salutation SALUTATION,
      pay.TRADING_NAME TRADING_NAME,
      pov.match_status_flag UNMATCHED_TAX_FLAG,
      pay.unique_taxpayer_ref  UNIQUE_TAX_REFERENCE_NUM,
      pay.company_registration_number COMPANY_REGISTRATION_NUMBER,
      pay.ni_number NATIONAL_INSURANCE_NUMBER,
      pay.verification_num VERIFICATION_NUMBER,
      sum(nvl(pay.amount,0)+ nvl(pay.TOTAL_DEDUCTIONS, 0)) TOTAL_PAYMENTS,
      sum(nvl(pay.TOTAL_DEDUCTIONS, 0)) TOTAL_DEDUCTIONS,
      sum(nvl(pay.MATERIAL_COST, 0)) MATERIAL_COST,
      sum(nvl(pay.LABOUR_COST, 0)) LABOUR_COST,
      sum(nvl(pay.DISCOUNT_AMOUNT, 0)) DISCOUNT_AMOUNT,
      sum(nvl(pay.CIS_TAX,0)) CIS_TAX,
      pay.TAX_TREATMENT_STATUS TAX_TREATMENT_STATUS
      from AP_SUPPLIERS pov, IGI_CIS_MTH_RET_PAY_VER pay
      where pov.vendor_id = pay.vendor_id
      and pay.status='WORKING'
	  and pay.action<>'DELETE'
      and pay.org_id=p_org_id
      and pay.period_name=p_period
      group by pay.vendor_id,
      pay.VENDOR_NAME,
      pov.vendor_type_lookup_code,
      pov.first_name,
      pov.second_name,
      pov.last_name,
      pov.salutation,
      pay.trading_name,
      pov.match_status_flag,
      pay.unique_taxpayer_ref,
      pay.company_registration_number,
      pay.ni_number,
      pay.verification_num,
      pay.TAX_TREATMENT_STATUS
      order by upper(VENDOR_NAME) asc;



begin
 l_procedure_name := g_path_name || l_procedure_name;
 log(C_STATE_LEVEL, l_procedure_name, 'Begin');
 log(C_STATE_LEVEL, l_procedure_name, 'org_id :'||l_org_id);
 l_retcode :=0;



            BEGIN
			select count(*) into l_action_count
            from IGI_CIS_MTH_RET_PAY_VER pv
            where pv.status='WORKING'
            and pv.org_id=l_org_id
            and pv.period_name=p_period_name;
			EXCEPTION
			WHEN OTHERS THEN
			  l_retcode := 2;
			  l_errbuf := l_errbuf||' Error deriving records with working status '|| sqlerrm;
			  RAISE l_sql_exception;
			END;
      IF l_action_count > 0 THEN
         BEGIN
        select sum(NVL(amount,0)) into l_nil_return_sum
              from IGI_CIS_MTH_RET_PAY_VER pv
              where pv.status='WORKING'
              and pv.org_id=l_org_id
              and pv.period_name=p_period_name;
        EXCEPTION
        WHEN OTHERS THEN
          l_retcode := 2;
          l_errbuf := l_errbuf||' Error deriving records with working status '|| sqlerrm;
		  RAISE l_sql_exception;
        END;
      END IF;

      IF l_nil_return_sum > 0 THEN
        l_nil_status := 'N';
      END IF;

            if l_action_count <> 0 then

			BEGIN
            select max(nvl(version_num,1)),old_header_id,
                    header_id
            into l_new_ver_num,l_old_header_id,l_new_header_id
            from  IGI_CIS_MTH_RET_PAY_VER vh
            where vh.period_name=p_period_name
            and vh.org_id=l_org_id
            and vh.status='WORKING'
			and rownum = 1
			group by old_header_id, header_id;
			EXCEPTION
			WHEN OTHERS THEN
			  l_retcode := 2;
			  l_errbuf := l_errbuf || 'Error deriving header_id and version_num '|| SQLERRM;
			  RAISE l_sql_exception;
			END;

             BEGIN
             select count(*) into l_ver_exists
             from igi_cis_mth_ret_hdr_h_all
             where period_name=p_period_name
              and status='WORKING'
              and version_num=l_new_ver_num
			  and org_id = l_org_id
              and header_id=l_new_header_id;
			 EXCEPTION
			 WHEN OTHERS THEN
			   l_retcode := 2;
			   l_errbuf := l_errbuf || 'Error deriving records with working status in hdr_h table '|| SQLERRM;
			   RAISE l_sql_exception;
			 END;


              if l_ver_exists = 0  then

                  select IGI_CIS_MTH_RET_HDR_T_S.nextval into l_new_header_id from dual;

                  update IGI_CIS_MTH_RET_PAY_VER
                  set header_id=l_new_header_id
                  where period_name=p_period_name
                  and org_id=l_org_id
                  and status='WORKING';
              end if;

			  --Changes for bug 25941704 by Subhakar
			  BEGIN
				SELECT cis_sender_id,
				       paye_reference,
					   tax_office_number,
					   accounts_office_reference,
					   unique_tax_reference_num
			      INTO l_cis_sender_id,
				       l_paye_reference,
					   l_tax_office_number,
					   l_accounts_office_reference,
					   l_unique_tax_reference_num
				  FROM ap_reporting_entities_all apea
				 WHERE apea.org_id = l_org_id;
			  EXCEPTION
			    WHEN OTHERS THEN
				  l_retcode := 2;
			      l_errbuf := l_errbuf || ' Error deriving extended reporting entities data'|| sqlerrm;
				  RAISE l_sql_exception;
			  END;


   log(C_STATE_LEVEL, l_procedure_name, 'INSERTING INTO igi_cis_mth_ret_hdr_h table');

   BEGIN

   insert into igi_cis_mth_ret_hdr_h_all
      (HEADER_ID,
             ORG_ID,
             CIS_SENDER_ID,
             TAX_OFFICE_NUMBER,
             PAYE_REFERENCE,
             --REQUEST_ID,
             --REQUEST_STATUS_CODE,
             --PROGRAM_APPLICATION_ID,
             --PROGRAM_ID,
             --PROGRAM_LOGIN_ID,
             UNIQUE_TAX_REFERENCE_NUM,
             ACCOUNTS_OFFICE_REFERENCE,
             PERIOD_NAME,
             PERIOD_ENDING_DATE,
             NIL_RETURN_FLAG,
             EMPLOYMENT_STATUS_FLAG,
             SUBCONT_VERIFY_FLAG,
             INFORMATION_CORRECT_FLAG,
             INACTIVITY_INDICATOR,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
             STATUS,
             VERSION_NUM)
      select distinct
            l_new_header_id,
             hdh.ORG_ID,
             l_CIS_SENDER_ID, -- Modified for bug 25941704 by Subhakar
             l_TAX_OFFICE_NUMBER, -- Modified for bug 25941704 by Subhakar
             l_PAYE_REFERENCE, -- Modified for bug 25941704 by Subhakar
             --hdh.REQUEST_ID,
             --hdh.REQUEST_STATUS_CODE,
             --hdh.PROGRAM_APPLICATION_ID,
             --hdh.PROGRAM_ID,
             --hdh.PROGRAM_LOGIN_ID,
             l_UNIQUE_TAX_REFERENCE_NUM, -- Modified for bug 25941704 by Subhakar
             l_ACCOUNTS_OFFICE_REFERENCE, -- Modified for bug 25941704 by Subhakar
             hdh.PERIOD_NAME,
             hdh.PERIOD_ENDING_DATE,
             l_nil_status,
             hdh.EMPLOYMENT_STATUS_FLAG,
             hdh.SUBCONT_VERIFY_FLAG,
             hdh.INFORMATION_CORRECT_FLAG,
             hdh.INACTIVITY_INDICATOR,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate,
             l_user_id,
             'WORKING',
             l_new_ver_num
        from  igi_cis_mth_ret_hdr_h_all hdh
        where hdh.HEADER_ID = l_old_header_id
		and hdh.period_name = p_period_name
        and request_status_code = 'C'--Added by Subhakar for bug 27337015
		and hdh.org_id = l_org_id ;
		EXCEPTION
		WHEN OTHERS THEN
		  l_retcode :=2;
		  l_errbuf := l_errbuf|| ' Error while inserting records into igi_cis_mth_ret_hdr_h table '||sqlerrm;
		  RAISE l_sql_exception;
		END;

              log(C_STATE_LEVEL, l_procedure_name, 'INSERTING INTO igi_cis_mth_ret_pay_h table');

           BEGIN
            insert into igi_cis_mth_ret_pay_h_all
                    (HEADER_ID,
                           ORG_ID,
                           VENDOR_ID,
                           CHILD_VENDOR_ID,
                           INVOICE_ID,
                           INVOICE_PAYMENT_ID,
                           AMOUNT,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_LOGIN,
                           CREATION_DATE,
                           CREATED_BY,
                           LABOUR_COST,
                           MATERIAL_COST,
                           TOTAL_DEDUCTIONS,
                           DISCOUNT_AMOUNT,
                            VERSION_NUM)
                    Select pv.HEADER_ID,
                           l_org_id,
                           pv.VENDOR_ID,
                           pv.CHILD_VENDOR_ID,
                           pv.INVOICE_ID,
                           pv.INVOICE_PAYMENT_ID,
                           pv.AMOUNT,
                           SYSDATE,
                           l_user_id,
                           l_login_id,
                           SYSDATE,
                           l_user_id,
                           pv.LABOUR_COST,
                           pv.MATERIAL_COST,
                           pv.TOTAL_DEDUCTIONS,
                           pv.DISCOUNT_AMOUNT,
                           pv.VERSION_NUM
                      from IGI_CIS_MTH_RET_PAY_VER pv
                      where pv.status='WORKING'
                      and pv.Action <> 'DELETE'
                      and  pv.Action is not null
                       and pv.old_header_id=l_old_header_id
                      and pv.period_name=p_period_name;
					 EXCEPTION
					 WHEN OTHERS THEN
					   l_retcode := 2;
					   l_errbuf := l_errbuf || ' Error while inserting records into igi_cis_mth_ret_pay_h table '||sqlerrm;
					   RAISE l_sql_exception;
					 END;


               log(C_STATE_LEVEL, l_procedure_name, 'INSERTING INTO IGI_CIS_MTH_RET_LINES_H table');
                  for summarize_lines_rec in summarize_lines_cur(p_period_name,l_org_id)
                  loop
				          IF summarize_lines_rec.TOTAL_PAYMENTS >=0 THEN
				          BEGIN
                            insert into IGI_CIS_MTH_RET_LINES_H_all
                            (
                            HEADER_ID,
                            VENDOR_ID,
                            ORG_ID,
                            VENDOR_NAME,
                            VENDOR_TYPE_LOOKUP_CODE,
                            FIRST_NAME,
                            SECOND_NAME,
                            LAST_NAME,
                            SALUTATION,
                            TRADING_NAME,
                            UNMATCHED_TAX_FLAG,
                            UNIQUE_TAX_REFERENCE_NUM,
                            COMPANY_REGISTRATION_NUMBER,
                            NATIONAL_INSURANCE_NUMBER,
                            VERIFICATION_NUMBER,
                            TOTAL_PAYMENTS,
                            MATERIAL_COST,
                            TOTAL_DEDUCTIONS,
                            LABOUR_COST,
                            DISCOUNT_AMOUNT,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN,
                            CREATION_DATE,
                            CREATED_BY,
                            CIS_TAX,
                            VERSION_NUM,
                            TAX_TREATMENT_STATUS)
                            values
                            (
                            l_new_header_id,
                            summarize_lines_rec.VENDOR_ID,
                            l_org_id,
                            summarize_lines_rec.VENDOR_NAME,
                            summarize_lines_rec.VENDOR_TYPE_LOOKUP_CODE,
                            summarize_lines_rec.FIRST_NAME,
                            summarize_lines_rec.SECOND_NAME,
                            summarize_lines_rec.LAST_NAME,
                            summarize_lines_rec.SALUTATION,
                            summarize_lines_rec.TRADING_NAME,
                            summarize_lines_rec.UNMATCHED_TAX_FLAG,
                            summarize_lines_rec.UNIQUE_TAX_REFERENCE_NUM,
                            summarize_lines_rec.COMPANY_REGISTRATION_NUMBER,
                            summarize_lines_rec.NATIONAL_INSURANCE_NUMBER,
                            summarize_lines_rec.VERIFICATION_NUMBER,
                            summarize_lines_rec.TOTAL_PAYMENTS,
                            summarize_lines_rec.MATERIAL_COST,
                            summarize_lines_rec.TOTAL_DEDUCTIONS,
                            summarize_lines_rec.LABOUR_COST,
                            summarize_lines_rec.DISCOUNT_AMOUNT,
                            SYSDATE,
                            l_user_id,
                            l_login_id,
                            SYSDATE,
                            l_user_id,
                            summarize_lines_rec.CIS_TAX,
                             l_new_ver_num,
                             summarize_lines_rec.TAX_TREATMENT_STATUS );
							EXCEPTION
							WHEN OTHERS THEN
							  l_retcode :=2;
							  l_errbuf := l_errbuf || ' Error while inserting records into IGI_CIS_MTH_RET_LINES_H table '||sqlerrm;
							  RAISE l_sql_exception;
							END;
					   ELSE
					       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Vendor :' || summarize_lines_rec.VENDOR_NAME || ', have negative summary amount. Cannot process the vendor with negative summary amount. Please correct the invoices.');
						   l_retcode :=2;
						   l_errbuf := l_errbuf || ' Vendor :'|| summarize_lines_rec.VENDOR_NAME || ' have negative summary amount. ';
						   log(C_STATE_LEVEL, l_procedure_name,'Vendor :'|| summarize_lines_rec.VENDOR_NAME || ' have negative summary amount');
						   --RAISE l_sql_exception;
					  END IF;
                  end loop;

				  IF l_retcode = 2 THEN
				     RAISE l_sql_exception;
                  END IF;

                  commit;
           else

              log(C_STATE_LEVEL, l_procedure_name, 'ACTION COLUMN CANNOT BE NULL');
           end if;


 log(C_STATE_LEVEL, l_procedure_name, 'End');

 p_retcode := l_retcode;
 p_errbuf := l_errbuf;

exception
WHEN l_sql_exception THEN
  p_retcode:= 2;
  p_errbuf := l_errbuf;
  log(C_STATE_LEVEL, l_procedure_name, 'Error : '|| l_errbuf);
when others then
p_retcode := 2;
p_errbuf := 'Error :'||SQLERRM;
log(C_STATE_LEVEL, l_procedure_name, 'Error : '|| SQLERRM);
end upload_and_summarize_hist_tab;
/*
populate_mth_ret_tabs procedure to copy working status headers from _H tables to _T
tables
*/
procedure populate_mth_ret_tabs(p_retcode OUT NOCOPY NUMBER, p_errbuf OUT NOCOPY VARCHAR2, p_header_id IN NUMBER)
is
l_procedure_name         VARCHAR2(100):='.populate_mth_ret_tabs';
l_org_id NUMBER:=fnd_profile.value('ORG_ID');

begin
l_procedure_name := g_path_name || l_procedure_name;
p_retcode := 0;
 log(C_STATE_LEVEL, l_procedure_name, 'Begin');
 log(C_STATE_LEVEL, l_procedure_name, 'insert into igi_cis_mth_ret_hdr_t');
       BEGIN
          insert into igi_cis_mth_ret_hdr_t_all(
          HEADER_ID,
          ORG_ID,
          CIS_SENDER_ID,
          TAX_OFFICE_NUMBER,
          PAYE_REFERENCE,
          REQUEST_ID,
          REQUEST_STATUS_CODE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_LOGIN_ID,
          UNIQUE_TAX_REFERENCE_NUM,
          ACCOUNTS_OFFICE_REFERENCE,
          PERIOD_NAME,
          PERIOD_ENDING_DATE,
          NIL_RETURN_FLAG,
          EMPLOYMENT_STATUS_FLAG,
          SUBCONT_VERIFY_FLAG,
          INFORMATION_CORRECT_FLAG,
          INACTIVITY_INDICATOR,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY,
          version_num
          )
           select  HEADER_ID,
          ORG_ID,
          CIS_SENDER_ID,
          TAX_OFFICE_NUMBER,
          PAYE_REFERENCE,
          FND_GLOBAL.CONC_REQUEST_ID(), -- REQUEST_ID
          'C', -- REQUEST_STATUS_CODE
          FND_GLOBAL.PROG_APPL_ID(), -- PROGRAM_APPLICATION_ID
          FND_GLOBAL.CONC_PROGRAM_ID(), -- PROGRAM_ID
          FND_GLOBAL.CONC_LOGIN_ID(), -- PROGRAM_LOGIN_ID
          UNIQUE_TAX_REFERENCE_NUM,
          ACCOUNTS_OFFICE_REFERENCE,
          PERIOD_NAME,
          PERIOD_ENDING_DATE,
          NIL_RETURN_FLAG,
          EMPLOYMENT_STATUS_FLAG,
          SUBCONT_VERIFY_FLAG,
          INFORMATION_CORRECT_FLAG,
          INACTIVITY_INDICATOR,
          sysdate,
          FND_GLOBAL.USER_ID(),
          FND_GLOBAL.LOGIN_ID(),
          sysdate,
          FND_GLOBAL.USER_ID(),
          version_num
          from
          igi_cis_mth_ret_hdr_h_all where
          header_id=p_header_id
          and status='WORKING'
		  and org_id = l_org_id;
		EXCEPTION
		WHEN OTHERS THEN
		   p_errbuf := p_errbuf||'Error while inserting data into table igi_cis_mth_ret_hdr_t '|| SQLERRM;
		   log(C_STATE_LEVEL, l_procedure_name, 'Error while inserting data into table igi_cis_mth_ret_hdr_t '|| SQLERRM);
		   p_retcode := 2;
		END;

        log(C_STATE_LEVEL, l_procedure_name, 'insert into igi_cis_mth_ret_lines_t');
       BEGIN
         insert into igi_cis_mth_ret_lines_t_all(
           HEADER_ID,
           ORG_ID,
           VENDOR_ID,
           VENDOR_NAME,
           VENDOR_TYPE_LOOKUP_CODE,
           FIRST_NAME,
           SECOND_NAME,
           LAST_NAME,
           SALUTATION,
           TRADING_NAME,
           UNMATCHED_TAX_FLAG,
           UNIQUE_TAX_REFERENCE_NUM,
           COMPANY_REGISTRATION_NUMBER,
           NATIONAL_INSURANCE_NUMBER,
           VERIFICATION_NUMBER,
           TOTAL_PAYMENTS,
           LABOUR_COST,
           MATERIAL_COST,
           TOTAL_DEDUCTIONS,
           DISCOUNT_AMOUNT,
           CIS_TAX,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY,
           version_num,
           TAX_TREATMENT_STATUS)
            select  lh.HEADER_ID,
           lh.ORG_ID,
           lh.VENDOR_ID,
           lh.VENDOR_NAME,
           lh.VENDOR_TYPE_LOOKUP_CODE,
           lh.FIRST_NAME,
           lh.SECOND_NAME,
           lh.LAST_NAME,
           lh.SALUTATION,
           lh.TRADING_NAME,
           lh.UNMATCHED_TAX_FLAG,
           lh.UNIQUE_TAX_REFERENCE_NUM,
           lh.COMPANY_REGISTRATION_NUMBER,
           lh.NATIONAL_INSURANCE_NUMBER,
           lh.VERIFICATION_NUMBER,
           lh.TOTAL_PAYMENTS,
           lh.LABOUR_COST,
           lh.MATERIAL_COST,
           lh.TOTAL_DEDUCTIONS,
           lh.DISCOUNT_AMOUNT,
           lh.CIS_TAX,
          sysdate,
          FND_GLOBAL.USER_ID(),
          FND_GLOBAL.LOGIN_ID(),
          sysdate,
          FND_GLOBAL.USER_ID(),
          lh.version_num,
          lh.TAX_TREATMENT_STATUS
          from
          igi_cis_mth_ret_lines_h_all lh,
          igi_cis_mth_ret_hdr_h_all rh
          where rh.header_id=p_header_id
          and rh.status='WORKING'
          and rh.header_id=lh.header_id
		  and lh.org_id = l_org_id
		  and rh.org_id = l_org_id
          and nvl(rh.version_num,1)=nvl(lh.version_num,1);
		EXCEPTION
		WHEN OTHERS THEN
		   p_errbuf := p_errbuf||'Error while inserting data into table igi_cis_mth_ret_lines_t '|| SQLERRM;
		   log(C_STATE_LEVEL, l_procedure_name, 'Error while inserting data into table igi_cis_mth_ret_lines_t '|| SQLERRM);
		   p_retcode := 2;
		END;


       log(C_STATE_LEVEL, l_procedure_name, 'insert into igi_cis_mth_ret_pay_t');
	 BEGIN
        insert into igi_cis_mth_ret_pay_t_all
        (
        HEADER_ID,
        ORG_ID,
        VENDOR_ID,
        CHILD_VENDOR_ID,
        INVOICE_ID,
        INVOICE_PAYMENT_ID,
        AMOUNT,
        LABOUR_COST,
        MATERIAL_COST,
        TOTAL_DEDUCTIONS,
        DISCOUNT_AMOUNT,
        CIS_TAX,--11699868
        LAST_UPDATE_DATE,--date
        LAST_UPDATED_BY, -- num
        LAST_UPDATE_LOGIN,-- num
        CREATION_DATE,--date
        CREATED_BY,
        version_num
        )
        Select
        ph.HEADER_ID,
        ph.ORG_ID,
        ph.VENDOR_ID,
        ph.CHILD_VENDOR_ID,
        ph.INVOICE_ID,
        ph.INVOICE_PAYMENT_ID,
        ph.AMOUNT,
        ph.LABOUR_COST,
        ph.MATERIAL_COST,
        ph.TOTAL_DEDUCTIONS,
        ph.DISCOUNT_AMOUNT,
        ph.CIS_TAX,
        sysdate,
        FND_GLOBAL.USER_ID(),
        FND_GLOBAL.LOGIN_ID(),
        sysdate,
        FND_GLOBAL.USER_ID(),
        ph.version_num
        from igi_cis_mth_ret_pay_h_all ph,
        igi_cis_mth_ret_hdr_h_all rh
        where rh.header_id=p_header_id
        and rh.status='WORKING'
		and ph.org_id = l_org_id
		and rh.org_id = l_org_id
        and rh.header_id=ph.header_id
        and nvl(rh.version_num,1)=nvl(ph.version_num,1);
     EXCEPTION
		WHEN OTHERS THEN
		   p_errbuf := p_errbuf||'Error while inserting data into table igi_cis_mth_ret_pay_t '|| SQLERRM;
		   log(C_STATE_LEVEL, l_procedure_name, 'Error while inserting data into table igi_cis_mth_ret_pay_t '|| SQLERRM);
		   p_retcode := 2;
		END;

        commit;
  log(C_STATE_LEVEL, l_procedure_name, 'End');
EXCEPTION
when others then
    p_errbuf := p_errbuf || 'Error in procedure populate_mth_ret_tabs '|| sqlerrm;
    p_retcode := 2;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 1='||p_errbuf);
end populate_mth_ret_tabs;

procedure resubmit_monthly_return ( errbuf OUT NOCOPY VARCHAR2,
      retcode OUT NOCOPY NUMBER,
      p_period_name IN varchar2)
is
l_procedure_name         VARCHAR2(100):='.resubmit_monthly_return';
l_current_version NUMBER:=0;
l_status_count NUMBER:=0;
l_new_header_id NUMBER:=0;
l_request_id number;
l_report_request_id number;
l_appln_name  varchar2(10) := 'IGI';
l_con_cp      varchar2(15) := 'IGIPMTHP';
l_con_cp_desc varchar2(200) := 'IGI : CIS2007 Monthly Returns Process';
l_con_rpt_cp      varchar2(15) := 'IGIPMTHR_XMLP';
l_con_rpt_cp_desc varchar2(200) := 'IGI : CIS2007 Monthly Returns Report';
e_request_submit_error exception;
e_insert_error exception;
l_org_id NUMBER:=fnd_profile.value('ORG_ID');
l_new_hdr_count NUMBER:=0;
l_xml_layout boolean;
l_req_return_status BOOLEAN;
rphase VARCHAR2(80);
rstatus VARCHAR2(80);
dphase VARCHAR2(80);
dstatus VARCHAR2(80);
message VARCHAR2(240);
l_status_code VARCHAR2(1);
l_program_application_id NUMBER;
l_program_login_id NUMBER;
l_program_id NUMBER;

begin
 l_procedure_name := g_path_name || l_procedure_name;
 retcode :=0;
 log(C_STATE_LEVEL, l_procedure_name, 'Begin');
            select vh.header_id into l_new_header_id
            from IGI_CIS_MTH_RET_HDR_H_all vh
            where vh.status='WORKING'
           and vh.period_name=p_period_name
		   and org_id = l_org_id;

 log(C_STATE_LEVEL, l_procedure_name, 'l_new_header_id -> '|| l_new_header_id);
 if l_new_header_id <> 0 then
    l_new_hdr_count:=0;
    select count(*) into l_new_hdr_count
    from IGI_CIS_MTH_RET_HDR_T_all vh
    where vh.header_id=l_new_header_id;

     log(C_STATE_LEVEL, l_procedure_name, 'POPULATE _T tables only if there are NO Rows for new header_id : count -> '|| l_new_hdr_count);
    if l_new_hdr_count=0 then
      populate_mth_ret_tabs(retcode, errbuf, l_new_header_id);
    end if;
    fnd_request.set_org_id(l_org_id);
	IF retcode <> 0 THEN
	  RAISE e_insert_error;
	END IF;
   log(C_STATE_LEVEL, l_procedure_name, 'Submit concurrent request for header id  -> '|| l_new_header_id);
        l_request_id := fnd_request.submit_request(application => l_appln_name,
                                              program     => l_con_cp,
                                              description => l_con_cp_desc,
                                              start_time  => NULL,
                                              sub_request => FALSE,
                                              argument1   => l_new_header_id
                                             );
       IF l_request_id = 0 THEN
         RAISE e_request_submit_error;
       ELSE
	   COMMIT;
	        /* Wait for Monthly returns Process to complete then trigger the Monthly Returns Summary Report */
	        l_req_return_status := Fnd_concurrent.Wait_for_request(l_request_id,
																	20,
																	0,
																	rphase,
																	rstatus,
																	dphase,
																	dstatus,
																	message);
			IF l_req_return_status = FALSE THEN
			   log(C_STATE_LEVEL, l_procedure_name,'Cannot Wait for Monthly Returns Process to complete');
			   RAISE e_request_submit_error;
			END IF;

			log(C_STATE_LEVEL, l_procedure_name,'dstatus:'||dstatus);

			IF dstatus = 'NORMAL' THEN

				IF l_request_id <> 0 THEN
				SELECT status_code, program_application_id, conc_login_id, concurrent_program_id
				  INTO l_status_code, l_program_application_id, l_program_login_id, l_program_id
				  FROM fnd_concurrent_requests WHERE request_id = l_request_id;
			   END IF;

			   update igi_cis_mth_ret_hdr_h_all
               set request_id = l_request_id,
			      request_status_code = l_status_code,
				  program_application_id = l_program_application_id,
				  program_id = l_program_id,
				  program_login_id = l_program_login_id
              where header_id=l_new_header_id
			  and org_id = l_org_id;

       		l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'IGIPMTHR','en','US','PDF');
          fnd_request.set_org_id(l_org_id);
        	l_report_request_id := fnd_request.submit_request(application => l_appln_name,
                                                      program     => l_con_rpt_cp,
                                                      description => l_con_rpt_cp_desc,
                                                      start_time  => NULL,
                                                      sub_request => FALSE,
                                                      argument1   => p_period_name,
                                                      argument2   => NULL,
                                                      argument3   => NULL,
                                                      argument4   => 'O', -- Original
                                                      argument5   => 'VENDOR_NAME', -- sort
                                                      argument6   => 'F',
                                                      argument7   => 'N', --delete temp
                                                      argument8   => 'S',
                                                      argument9   => 'A',
                                                      argument10   => chr(0));

          IF l_report_request_id = 0 THEN
            RAISE e_request_submit_error;
          else

             /*As the report is successfully generated and submitted to HMRC
               CHANGE WORKING STATUS TO FINAL FOR _H AND _VER tables
               And DELETE Rows from _T table */

              log(C_STATE_LEVEL, l_procedure_name, 'l_header_id='||l_new_header_id);
              delete from igi_cis_mth_ret_hdr_t_all where header_id = l_new_header_id;
              log(C_STATE_LEVEL, l_procedure_name, 'Deleted '||SQL%ROWCOUNT||' rows from igi_cis_mth_ret_hdr_t');
              delete from igi_cis_mth_ret_lines_t_all where header_id = l_new_header_id;
              log(C_STATE_LEVEL, l_procedure_name, 'Deleted '||SQL%ROWCOUNT||' rows from igi_cis_mth_ret_lines_t');
              delete from igi_cis_mth_ret_pay_t_all where header_id = l_new_header_id;
              log(C_STATE_LEVEL, l_procedure_name, 'Deleted '||SQL%ROWCOUNT||' rows from igi_cis_mth_ret_pay_t');


              update igi_cis_mth_ret_hdr_h_all
              set status='FINAL'
              where header_id=l_new_header_id
			  and org_id = l_org_id;

              update igi_cis_mth_ret_pay_ver
              set status='FINAL'
              where header_id=l_new_header_id;

             commit;
          END IF;

		  END IF;
           log(C_STATE_LEVEL, l_procedure_name, 'CIS Monthly returns is successful for  -> '|| l_new_header_id);
       END IF;
 end if;

 log(C_STATE_LEVEL, l_procedure_name, 'End');
Exception
WHEN e_insert_error THEN
  errbuf := errbuf||'Error While inserting data into _t tables for monthly returns.';
  retcode := 2;
when e_request_submit_error then
  errbuf := errbuf||'Error while calling resubmit_monthly_return ';
  retcode := 2;
when others then
    -- for debugging
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in processing' || sqlerrm);
    -- rollback the insert and updates
    rollback;
    errbuf := errbuf || sqlerrm;
    retcode := 2;
log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 6='||errbuf);
end resubmit_monthly_return;

/*CIS RESUBMIT MAIN PROCESS */
procedure main (
      errbuf OUT NOCOPY VARCHAR2,
      retcode OUT NOCOPY NUMBER,
      p_period_name IN varchar2,
      p_mode IN VARCHAR2 DEFAULT 'V')
is
l_procedure_name         VARCHAR2(100):='.main';
l_appln_name varchar2(50):='IGI';
l_con_cp  varchar2(50) := 'IGIPMTHRVR';
l_con_cp_desc varchar2(200) := 'IGI CIS Resubmit: Monthly Returns View Report';
l_xml_layout boolean;
l_report_request_id NUMBER;
l_org_id NUMBER:=fnd_profile.value('ORG_ID');
l_errbuf  VARCHAR2(1000);
l_retcode NUMBER;

begin
 l_procedure_name := g_path_name || l_procedure_name;
 l_retcode:= 0;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    /*if p_mode = 'D' then
        -- Download file
        log(C_STATE_LEVEL, l_procedure_name, 'Download file for customer to edit ');
        download_month_returns(p_period_name);
    els*/
    if p_mode = 'U' then
      -- Upload file
      log(C_STATE_LEVEL, l_procedure_name, 'Upload customer modified file ');
      upload_and_summarize_hist_tab(l_errbuf,l_retcode,p_period_name);
	  IF l_retcode <> 0 THEN
	    log(C_STATE_LEVEL, l_procedure_name, 'Upload customer modified file is not successfull. Cleaning up the data for reupload');

				--Added org_id check for bug 25941704
		delete from  IGI_CIS_MTH_RET_pay_h_all where header_id IN (Select header_id from IGI_CIS_MTH_RET_pay_ver where period_name = p_period_name and status = 'WORKING') and org_id = l_org_id;
		delete from  IGI_CIS_MTH_RET_lines_h_all where header_id IN (Select header_id from IGI_CIS_MTH_RET_pay_ver where period_name = p_period_name and status = 'WORKING')  and org_id = l_org_id;
		delete from  IGI_CIS_MTH_RET_hdr_h_all where period_name = p_period_name and status = 'WORKING'  and org_id = l_org_id;
		delete from IGI_CIS_MTH_RET_pay_ver where period_name = p_period_name and status = 'WORKING'  and org_id = l_org_id;
                commit;
     END IF;

    elsif p_mode = 'R' then
       -- Resubmit monthly returns
      log(C_STATE_LEVEL, l_procedure_name, 'Resubmit customer modified file ');
      resubmit_monthly_return(errbuf,retcode,p_period_name);
    else
    -- if p_mode is V
       log(C_STATE_LEVEL, l_procedure_name, 'View customer modified file ');
       l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'IGIPMTHRVR','en','US','PDF');
       fnd_request.set_org_id(l_org_id);
       l_report_request_id := fnd_request.submit_request(application => l_appln_name,
                                                      program     => l_con_cp,
                                                      description => l_con_cp_desc,
                                                      start_time  => NULL,
                                                      sub_request => FALSE,
                                                      argument1   => p_period_name,
                                                      argument2   => NULL,
                                                      argument3   => NULL,
                                                      argument4   => 'O', -- Original
                                                      argument5   => 'VENDOR_NAME', -- sort
                                                      argument6   => 'F',
                                                      argument7   => 'N', --delete temp
                                                      argument8   => 'S',
                                                      argument9   => 'A',
                                                      argument10   => chr(0));
    end if;
	retcode := l_retcode;
	errbuf := l_errbuf;
	IF l_retcode <> 0 THEN
	  FND_FILE.PUT_LINE(FND_FILE.LOG,l_errbuf);
	END IF;
    log(C_STATE_LEVEL, l_procedure_name, 'END');
exception
when others then
retcode:=2;
errbuf:= SQLERRM;

end main;

END IGI_CIS_RESUBMIT_MTH_RT_PKG;

/
