--------------------------------------------------------
--  DDL for Package Body AR_ARXRECON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXRECON_XMLP_PKG" AS
/* $Header: ARXRECONB.pls 120.0 2007/12/27 14:03:59 abraghun noship $ */
function CF_AR_CACL_AGINGFormula return Number is
  l_begin_age_amt               number;
  l_begin_age_acctd_amt         number;
  l_end_age_amt                 number;
  l_end_age_acctd_amt           number;
  l_fin_chrg_amt                number;
  l_fin_chrg_acctd_amt          number;
  l_adj_amt                     number;
  l_adj_acctd_amt               number;
  l_guar_amt                    number;
  l_guar_acctd_amt              number;
  l_dep_amt                     number;
  l_dep_acctd_amt               number;
  l_endorsmnt_amt               number;
  l_endorsmnt_acctd_amt         number;
  l_non_post_amt                number;
  l_non_post_acctd_amt          number;
  l_post_amt                    number;
  l_post_acctd_amt              number;
  l_unapp_amt                   number;
  l_unapp_acctd_amt             number;
  l_acc_amt                     number;
  l_acc_acctd_amt               number;
  l_claim_amt                   number;
  l_claim_acctd_amt             number;
  l_prepay_amt                  number;
  l_prepay_acctd_amt            number;
  l_app_amt                     number;
  l_app_acctd_amt               number;
  l_edisc_amt                   number;
  l_edisc_acctd_amt             number;
  l_unedisc_amt                 number;
  l_unedisc_acctd_amt           number;
  l_cm_gain_loss                number;
  l_post_excp_amt               number;
  l_post_excp_acctd_amt         number;
  l_nonpost_excp_amt            number;
  l_nonpost_excp_acctd_amt      number;
  l_period_total_amt            number;
  l_period_total_acctd_amt      number;
  l_recon_diff_amt              number;
  l_recon_diff_acctd_amt        number;
  l_sales_journal_amt           number;
  l_sales_journal_acctd_amt     number;
  l_adj_journal_amt             number;
  l_adj_journal_acctd_amt       number;
  l_app_journal_amt             number;
  l_app_journal_acctd_amt       number;
  l_unapp_journal_amt           number;
  l_unapp_journal_acctd_amt     number;
  l_cm_journal_acctd_amt        number;
  l_on_acc_cm_ref_amt           number;
  l_on_acc_cm_ref_acctd_amt     number;
begin
/*srw.reference(p_company_name);*/null;
/*srw.reference(p_functional_currency);*/null;
/*srw.reference(p_min_precision);*/null;
/*srw.reference(p_gl_date_low);*/null;
/*srw.reference(p_gl_date_high);*/null;
/*srw.reference(l_begin_as_of);*/null;
/*srw.reference(l_end_as_of);*/null;
/*srw.reference(p_chart_of_accounts_id);*/null;
/*srw.reference(p_co_seg_low);*/null;
/*srw.reference(p_co_seg_high);*/null;
/*srw.reference(p_reporting_level);*/null;
/*srw.reference(p_reporting_entity_id);*/null;
/*srw.reference(p_ca_set_of_books_id);*/null;
     ar_calc_aging.get_report_heading (p_reporting_level,
                                       p_reporting_entity_id,
                                       p_ca_set_of_books_id,
                                       p_company_name,
        	                       p_functional_currency,
                                       p_chart_of_accounts_id,
       	 	                       p_min_precision,
		                       p_sysdate,
                                       p_organization,
                                       p_bills_receivable_flag);
  l_begin_as_of := nvl(p_gl_date_low, TRUNC(sysdate) ) -1;
  l_end_as_of:= nvl(p_gl_date_high, TRUNC(sysdate)) ;
  ar_calc_aging.aging_as_of (l_begin_as_of ,
                             l_end_as_of,
                             p_reporting_level,
                             p_reporting_entity_id,
                             p_co_seg_low,
                             p_co_seg_high,
                             p_chart_of_accounts_id,
                             l_begin_age_amt,
                             l_end_age_amt,
                             l_begin_age_acctd_amt,
                             l_end_age_acctd_amt);
  p_begin_age_amt         := l_begin_age_amt ;
  p_begin_age_acctd_amt   := l_begin_age_acctd_amt ;
  p_end_age_amt           := l_end_age_amt;
  p_end_age_acctd_amt     := l_end_age_acctd_amt;
  ar_calc_aging.transaction_register(p_gl_date_low ,
                                     p_gl_date_high ,
                                     p_reporting_level,
                                     p_reporting_entity_id,
                                     p_co_seg_low,
                                     p_co_seg_high,
                                     p_chart_of_accounts_id,
                                     l_non_post_amt,
                                     l_non_post_acctd_amt,
                                     l_post_amt,
                                     l_post_acctd_amt);
  p_non_post_amt          := nvl(l_non_post_amt,0);
  p_non_post_acctd_amt    := nvl(l_non_post_acctd_amt,0);
  p_post_amt              := nvl(l_post_amt,0);
  p_post_acctd_amt        := nvl(l_post_acctd_amt,0);
  p_trx_reg_amt              := nvl(l_post_amt ,0)+
                                 nvl(l_non_post_amt,0);
  p_trx_reg_acctd_amt        := nvl(l_post_acctd_amt,0)+
                                 nvl(l_non_post_acctd_amt,0);
  ar_calc_aging.cash_receipts_register(p_gl_date_low,
                                       p_gl_date_high,
                                       p_reporting_level,
                                       p_reporting_entity_id,
                                       p_co_seg_low,
                                       p_co_seg_high,
                                       p_chart_of_accounts_id,
                                       l_unapp_amt,
                                       l_unapp_acctd_amt,
                                       l_acc_amt,
                                       l_acc_acctd_amt,
                                       l_claim_amt,
                                       l_claim_acctd_amt,
                                       l_prepay_amt,
                                       l_prepay_acctd_amt,
                                       l_app_amt,
                                       l_app_acctd_amt,
                                       l_edisc_amt,
                                       l_edisc_acctd_amt,
                                       l_unedisc_amt,
                                       l_unedisc_acctd_amt,
                                       l_cm_gain_loss,
                                       l_on_acc_cm_ref_amt,
                                       l_on_acc_cm_ref_acctd_amt );
  p_unapp_amt            :=  nvl(l_unapp_amt,0);
  p_unapp_acctd_amt      :=  nvl(l_unapp_acctd_amt,0);
  p_acc_amt              :=  nvl(l_acc_amt,0);
  p_acc_acctd_amt        :=  nvl(l_acc_acctd_amt,0);
  p_claim_amt            :=  nvl(l_claim_amt,0);
  p_claim_acctd_amt      :=  nvl(l_claim_acctd_amt,0);
  p_prepay_amt           :=  nvl(l_prepay_amt,0);
  p_prepay_acctd_amt     :=  nvl(l_prepay_acctd_amt,0);
  p_app_amt              :=  nvl(l_app_amt,0);
  p_app_acctd_amt        :=  nvl(l_app_acctd_amt,0);
  p_edisc_amt            :=  nvl(l_edisc_amt,0);
  p_edisc_acctd_amt      :=  nvl(l_edisc_acctd_amt,0);
  p_unedisc_amt          :=  nvl(l_unedisc_amt,0);
  p_unedisc_acctd_amt    :=  nvl(l_unedisc_acctd_amt,0);
  p_on_acc_cm_ref_amt    :=  nvl(l_on_acc_cm_ref_amt,0);
  p_on_acc_cm_ref_acctd_amt := nvl(l_on_acc_cm_ref_acctd_amt,0);
  p_unapp_reg_amt           :=  nvl(l_unapp_amt,0) +
                                 nvl(l_acc_amt,0) +
                                 nvl(l_claim_amt,0) +
                                 nvl(l_prepay_amt,0);
  p_unapp_reg_acctd_amt     :=  nvl(l_unapp_acctd_amt,0) +
                                 nvl(l_acc_acctd_amt,0) +
                                 nvl(l_claim_acctd_amt,0) +
                                 nvl(l_prepay_acctd_amt,0);
  p_app_reg_amt             :=  nvl(l_app_amt,0) +
                                 nvl(l_edisc_amt,0) +
                                 nvl(l_unedisc_amt,0);
  p_app_reg_acctd_amt       :=  nvl(l_app_acctd_amt,0) +
                                 nvl(l_edisc_acctd_amt,0) +
                                 nvl(l_unedisc_acctd_amt,0);
  p_cm_gain_loss            :=  nvl(l_cm_gain_loss,0) ;
  ar_calc_aging.adjustment_register(p_gl_date_low,
                                    p_gl_date_high,
                                    p_reporting_level,
                                    p_reporting_entity_id,
                                    p_co_seg_low,
                                    p_co_seg_high,
                                    p_chart_of_accounts_id,
                                    l_fin_chrg_amt,
                                    l_fin_chrg_acctd_amt,
                                    l_adj_amt,
                                    l_adj_acctd_amt,
                                    l_guar_amt,
                                    l_guar_acctd_amt,
                                    l_dep_amt,
                                    l_dep_acctd_amt,
                                    l_endorsmnt_amt,
                                    l_endorsmnt_acctd_amt);
  p_fin_chrg_amt         :=  nvl(l_fin_chrg_amt,0);
  p_fin_chrg_acctd_amt   :=  nvl(l_fin_chrg_acctd_amt,0);
  p_adj_amt              :=  nvl(l_adj_amt,0);
  p_adj_acctd_amt        :=  nvl(l_adj_acctd_amt,0);
  p_guar_amt             :=  nvl(l_guar_amt,0);
  p_guar_acctd_amt       :=  nvl(l_guar_acctd_amt,0);
  p_dep_amt              :=  nvl(l_dep_amt,0);
  p_dep_acctd_amt        :=  nvl(l_dep_acctd_amt,0);
  p_endorsmnt_amt        :=  nvl(l_endorsmnt_amt,0);
  p_endorsmnt_acctd_amt  :=  nvl(l_endorsmnt_acctd_amt,0);
  p_adj_reg_amt             :=  nvl(l_fin_chrg_amt,0) +
                                 nvl(l_adj_amt,0) +
                                 nvl(l_guar_amt,0) +
                                 nvl(l_dep_amt,0) +
                                 nvl(l_endorsmnt_amt,0) ;
  p_adj_reg_acctd_amt      :=   nvl(l_fin_chrg_acctd_amt,0) +
                                 nvl(l_adj_acctd_amt,0) +
                                 nvl(l_guar_acctd_amt,0) +
                                 nvl(l_dep_acctd_amt,0) +
                                 nvl(l_endorsmnt_acctd_amt,0);
  ar_calc_aging.invoice_exceptions(p_gl_date_low,
                                   p_gl_date_high,
                                   p_reporting_level,
                                   p_reporting_entity_id,
                                   p_co_seg_low,
                                   p_co_seg_high,
                                   p_chart_of_accounts_id,
                                   l_post_excp_amt,
                                   l_post_excp_acctd_amt,
                                   l_nonpost_excp_amt,
                                   l_nonpost_excp_acctd_amt);
  p_post_excp_amt            :=  nvl(l_post_excp_amt,0);
  p_post_excp_acctd_amt      :=  nvl(l_post_excp_acctd_amt,0);
  p_non_post_excp_amt        :=  nvl(l_nonpost_excp_amt,0);
  p_non_post_excp_acctd_amt  :=  nvl(l_nonpost_excp_acctd_amt,0);
  p_inv_exp_amt              :=  nvl(l_post_excp_amt,0) +
                                  nvl(l_nonpost_excp_amt,0);
  p_inv_exp_acctd_amt        :=  nvl(l_post_excp_acctd_amt,0) +
                                  nvl(l_nonpost_excp_acctd_amt,0);
  p_period_total_amt       :=     p_begin_age_amt
                                 + p_trx_reg_amt
                                 - p_app_reg_amt
                                 - p_unapp_reg_amt
                                 + p_adj_reg_amt
                                 - p_inv_exp_amt
                                 + p_on_acc_cm_ref_amt;
  p_period_total_acctd_amt :=     p_begin_age_acctd_amt
                                 + p_trx_reg_acctd_amt
                                 - p_app_reg_acctd_amt
                                 - p_unapp_reg_acctd_amt
                                 + p_adj_reg_acctd_amt
                                 - p_inv_exp_acctd_amt
                                 + p_cm_gain_loss
                                 + p_on_acc_cm_ref_acctd_amt;
  p_amt_diff       := NVL(p_period_total_amt - p_end_age_amt , 0 );
  p_acctd_amt_diff := nvl(p_period_total_acctd_amt - p_end_age_acctd_amt , 0);
  ar_calc_aging.journal_reports (p_gl_date_low,
                                 p_gl_date_high,
                                 p_reporting_level,
                                 p_reporting_entity_id,
                                 p_co_seg_low,
                                 p_co_seg_high,
                                 p_chart_of_accounts_id,
                                 l_sales_journal_amt,
                                 l_sales_journal_acctd_amt,
                                 l_adj_journal_amt,
                                 l_adj_journal_acctd_amt,
                                 l_app_journal_amt,
                                 l_app_journal_acctd_amt,
                                 l_unapp_journal_amt,
                                 l_unapp_journal_acctd_amt,
                                 l_cm_journal_acctd_amt);
  p_sales_journal_amt           :=  nvl(l_sales_journal_amt,0);
  p_sales_journal_acctd_amt     :=  nvl(l_sales_journal_acctd_amt,0);
  p_adj_journal_amt             :=  nvl(l_adj_journal_amt,0);
  p_adj_journal_acctd_amt       :=  nvl(l_adj_journal_acctd_amt,0);
  p_app_journal_amt             :=  nvl(l_app_journal_amt,0);
  p_app_journal_acctd_amt       :=  nvl(l_app_journal_acctd_amt,0);
  p_unapp_journal_amt           :=  nvl(l_unapp_journal_amt,0);
  p_unapp_journal_acctd_amt     :=  nvl(l_unapp_journal_acctd_amt,0);
  p_cm_journal_acctd_amt        :=  nvl(l_cm_journal_acctd_amt,0);
  p_trx_diff_acctd_amt          :=  nvl(p_post_acctd_amt,0) -
                                     nvl(p_sales_journal_acctd_amt,0);
  p_adj_diff_acctd_amt          :=  nvl(p_adj_journal_acctd_amt,0) -
                                     nvl(p_adj_reg_acctd_amt,0);
  p_app_diff_acctd_amt          :=  nvl(p_app_reg_acctd_amt,0) -
                                     nvl(p_app_journal_acctd_amt,0);
  p_unapp_diff_acctd_amt        :=  nvl(p_unapp_reg_acctd_amt,0) -
                                     nvl(p_unapp_journal_acctd_amt,0);
  p_cm_diff_acctd_amt           :=  nvl(p_cm_gain_loss,0)-
                                     nvl(p_cm_journal_acctd_amt,0);
  return (1);
RETURN NULL; EXCEPTION
	WHEN NO_DATA_FOUND THEN
		/*srw.message('100', 'No Data found.');*/null;
	RETURN NULL; WHEN OTHERS THEN
		/*srw.message('100', sqlerrm);*/null;
RETURN NULL; end;
function BeforeReport return boolean is
l_ld_sp varchar2(1);
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
arp_util.debug('Before Report');
LP_GL_DATE_HIGH := to_char(P_GL_DATE_HIGH, 'DD-MON-YYYY');
LP_GL_DATE_LOW := to_char(P_GL_DATE_LOW, 'DD-MON-YYYY');
rp_message:=null;
IF to_number(p_reporting_level) = 1000 THEN
l_ld_sp:= mo_utils.check_ledger_in_sp(TO_NUMBER(p_reporting_entity_id));
IF l_ld_sp = 'N' THEN
     FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
     rp_message := FND_MESSAGE.get;
END IF;
END IF;
FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
cp_acc_message := FND_MESSAGE.get;
   ar_calc_aging.initialize;
arp_util.debug('End of Before Report');
  return (TRUE);
end;
function AfterPForm return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  /*srw.reference(p_reporting_level);*/null;
  /*srw.reference(p_reporting_entity_id);*/null;
  IF p_reporting_level = 3000 THEN
     select set_of_books_id
     into p_ca_set_of_books_id
     from ar_system_parameters_all
     where org_id  = p_reporting_entity_id;
  ELSIF p_reporting_level = 1000 THEN
     p_ca_set_of_books_id := p_reporting_entity_id;
  END IF;
  return (TRUE);
end;
function CF_COMPANY_SEGMENTFormula return Char is
  l_co_seg   VARCHAR2(70);
begin
  /*srw.reference(p_co_seg_low);*/null;
  /*srw.reference(p_co_seg_high);*/null;
  IF p_co_seg_low IS NULL AND p_co_seg_high IS NULL THEN
      select meaning into l_co_seg
      from ar_lookups
      where lookup_type = 'ALL'
      and lookup_code = 'ALL';
  ELSIF p_co_seg_low IS NULL THEN
      l_co_seg :=  '<= '||p_co_seg_high;
  ELSIF p_co_seg_high IS NULL THEN
      l_co_seg :=  '>= '||p_co_seg_low;
  ELSIF p_co_seg_low = p_co_seg_high THEN
      l_co_seg := p_co_seg_low;
  ELSE
      l_co_seg :=  p_co_seg_low||' to '||p_co_seg_high;
  END IF;
  Return l_co_seg;
end;
function AfterReport return boolean is
l_request_id number;
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
arp_util.debug('Begin of After Report');
IF p_potential_rec_items = 'Y' THEN
/*srw.message('1001','p_bal_high '||p_co_seg_high);*/null;
/*srw.message('1001','p_bal_low '||p_co_seg_low);*/null;
/*srw.message('1001','p_ca_set_of_books_id '||p_ca_set_of_books_id);*/null;
/*srw.message('1001','p_coaid '||p_chart_of_accounts_id);*/null;
/*srw.message('1001','p_gl_date_high '||p_gl_date_high);*/null;
/*srw.message('1001','p_gl_date_low '||p_gl_date_low);*/null;
/*srw.message('1001','p_min_precision '||p_min_precision);*/null;
/*srw.message('1001','p_mrc_sobtype '||p_mrcsobtype);*/null;
/*srw.message('1001','p_reporting_entity_id '||to_char(p_reporting_entity_id));*/null;
/*srw.message('1001','p_reporting_level '||p_reporting_level);*/null;
l_request_id := FND_REQUEST.SUBMIT_REQUEST(application=>'AR',
			program=>'ARXPIREP_XML',
			description=>'',
			start_time=>'',
			sub_request=>FALSE,
			argument1=>'P_BAL_HIGH='||P_CO_SEG_HIGH,
			argument2=>'P_BAL_LOW='||p_co_seg_low,
			argument3=>'P_CA_SET_OF_BOOKS_ID='||p_ca_set_of_books_id,
			argument4=>'P_COAID='||p_chart_of_accounts_id,
			argument5=>'P_CURRENCY_CODE='||'All',
			argument6=>'P_HIGH_DATE='||to_char(p_gl_date_high,'YYYY/MM/DD HH24:MI:SS'),
			argument7=>'P_LOW_DATE='||to_char(p_gl_date_low,'YYYY/MM/DD HH24:MI:SS'),
			argument8=>'P_MIN_PRECISION='||p_min_precision,
			argument9=>'P_MRCSOBTYPE='||p_mrcsobtype,
                        argument10=>'P_REPORTING_ENTITY_ID='||to_char(p_reporting_entity_id),
                        argument11=>'P_REPORTING_LEVEL='||p_reporting_level,
			argument12=>'',
			argument13=>'',
			argument14=>'',
			argument15=>'',
			argument16=>'',
			argument17=>'',
			argument18=>'',
			argument19=>'',
			argument20=>'',
			argument21=>'',
			argument22=>'',
			argument23=>'',
			argument24=>'',
			argument25=>'',
			argument26=>'',
			argument27=>'',
			argument28=>'',
			argument29=>'',
			argument30=>'',
			argument31=>'',
			argument32=>'',
			argument33=>'',
			argument34=>'',
			argument35=>'',
			argument36=>'',
			argument37=>'',
			argument38=>'',
		 	argument39=>'',
			argument40=>'',
			argument41=>'',
			argument42=>'',
			argument43=>'',
			argument44=>'',
			argument45=>'',
			argument46=>'',
			argument47=>'',
			argument48=>'',
			argument49=>'',
			argument50=>'',
			argument51=>'',
			argument52=>'',
			argument53=>'',
			argument54=>'',
			argument55=>'',
			argument56=>'',
			argument57=>'',
			argument58=>'',
			argument59=>'',
			argument60=>'',
			argument61=>'',
			argument62=>'',
			argument63=>'',
			argument64=>'',
			argument65=>'',
			argument66=>'',
			argument67=>'',
			argument68=>'',
			argument69=>'',
			argument70=>'',
			argument71=>'',
			argument72=>'',
			argument73=>'',
			argument74=>'',
			argument75=>'',
			argument76=>'',
			argument77=>'',
			argument78=>'',
			argument79=>'',
			argument80=>'',
			argument81=>'',
			argument82=>'',
			argument83=>'',
			argument84=>'',
			argument85=>'',
			argument86=>'',
			argument87=>'',
			argument88=>'',
			argument89=>'',
			argument90=>'',
			argument91=>'',
			argument92=>'',
			argument93=>'',
			argument94=>'',
			argument95=>'',
			argument96=>'',
			argument97=>'',
			argument98=>'',
			argument99=>'',
			argument100=>'');
Commit;
/*srw.message('100', 'Request id  ' || l_request_id);*/null;
IF l_request_id = 0 THEN
   /*srw.message(100,' FAILED to submit the Potential Reconciling Items Report ' );*/null;
ELSE
   /*srw.message(100,'Potential Reconciling Items Report has been succesfully submitted');*/null;
END IF;
END IF;
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
return TRUE;
end;
function BeforePForm return boolean is
begin
  return (TRUE);
end;
function P_TRX_REG_ACCTD_AMT_DSPFormula return Char is
begin
return 0;
end;
--Functions to refer Oracle report placeholders--
 Function SO_ORGANIZATION_ID_p return number is
	Begin
	 return SO_ORGANIZATION_ID;
	 END;
 Function P_SYSDATE_p return varchar2 is
	Begin
	 return P_SYSDATE;
	 END;
 Function P_BEGIN_AGE_AMT_p return number is
	Begin
	 return P_BEGIN_AGE_AMT;
	 END;
 Function P_BEGIN_AGE_ACCTD_AMT_p return number is
	Begin
	 return P_BEGIN_AGE_ACCTD_AMT;
	 END;
 Function P_BEGIN_AGE_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_BEGIN_AGE_ACCTD_AMT_DSP;
	 END;
 Function P_UNAPP_REG_AMT_p return number is
	Begin
	 return P_UNAPP_REG_AMT;
	 END;
 Function P_UNAPP_REG_ACCTD_AMT_p return number is
	Begin
	 return P_UNAPP_REG_ACCTD_AMT;
	 END;
 Function P_UNAPP_REG_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_UNAPP_REG_ACCTD_AMT_DSP;
	 END;
 Function P_UNAPP_AMT_p return number is
	Begin
	 return P_UNAPP_AMT;
	 END;
 Function P_UNAPP_ACCTD_AMT_p return number is
	Begin
	 return P_UNAPP_ACCTD_AMT;
	 END;
 Function P_ACC_AMT_p return number is
	Begin
	 return P_ACC_AMT;
	 END;
 Function P_ACC_ACCTD_AMT_p return number is
	Begin
	 return P_ACC_ACCTD_AMT;
	 END;
 Function P_CLAIM_AMT_p return number is
	Begin
	 return P_CLAIM_AMT;
	 END;
 Function P_UNAPP_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_UNAPP_ACCTD_AMT_DSP;
	 END;
 Function P_ACC_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_ACC_ACCTD_AMT_DSP;
	 END;
 Function P_CLAIM_ACCTD_AMT_p return number is
	Begin
	 return P_CLAIM_ACCTD_AMT;
	 END;
 Function P_CLAIM_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_CLAIM_ACCTD_AMT_DSP;
	 END;
 Function P_PREPAY_AMT_p return number is
	Begin
	 return P_PREPAY_AMT;
	 END;
 Function P_PREPAY_ACCTD_AMT_p return number is
	Begin
	 return P_PREPAY_ACCTD_AMT;
	 END;
 Function P_PREPAY_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_PREPAY_ACCTD_AMT_DSP;
	 END;
 Function P_TRX_REG_AMT_p return number is
	Begin
	 return P_TRX_REG_AMT;
	 END;
 Function P_TRX_REG_ACCTD_AMT_p return number is
	Begin
	 return P_TRX_REG_ACCTD_AMT;
	 END;
 Function P_TRX_REG_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_TRX_REG_ACCTD_AMT_DSP;
	 END;
 Function P_NON_POST_AMT_p return number is
	Begin
	 return P_NON_POST_AMT;
	 END;
 Function P_NON_POST_ACCTD_AMT_p return number is
	Begin
	 return P_NON_POST_ACCTD_AMT;
	 END;
 Function P_NON_POST_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_NON_POST_ACCTD_AMT_DSP;
	 END;
 Function P_POST_AMT_p return number is
	Begin
	 return P_POST_AMT;
	 END;
 Function P_POST_ACCTD_AMT_p return number is
	Begin
	 return P_POST_ACCTD_AMT;
	 END;
 Function P_POST_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_POST_ACCTD_AMT_DSP;
	 END;
 Function P_ADJ_REG_AMT_p return number is
	Begin
	 return P_ADJ_REG_AMT;
	 END;
 Function P_ADJ_REG_ACCTD_AMT_p return number is
	Begin
	 return P_ADJ_REG_ACCTD_AMT;
	 END;
 Function P_ADJ_REG_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_ADJ_REG_ACCTD_AMT_DSP;
	 END;
 Function P_FIN_CHRG_AMT_p return number is
	Begin
	 return P_FIN_CHRG_AMT;
	 END;
 Function P_FIN_CHRG_ACCTD_AMT_p return number is
	Begin
	 return P_FIN_CHRG_ACCTD_AMT;
	 END;
 Function P_FIN_CHRG_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_FIN_CHRG_ACCTD_AMT_DSP;
	 END;
 Function P_ADJ_AMT_p return number is
	Begin
	 return P_ADJ_AMT;
	 END;
 Function P_ADJ_ACCTD_AMT_p return number is
	Begin
	 return P_ADJ_ACCTD_AMT;
	 END;
 Function P_ADJ_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_ADJ_ACCTD_AMT_DSP;
	 END;
 Function P_GUAR_AMT_p return number is
	Begin
	 return P_GUAR_AMT;
	 END;
 Function P_GUAR_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_GUAR_ACCTD_AMT_DSP;
	 END;
 Function P_GUAR_ACCTD_AMT_p return number is
	Begin
	 return P_GUAR_ACCTD_AMT;
	 END;
 Function P_DEP_AMT_p return number is
	Begin
	 return P_DEP_AMT;
	 END;
 Function P_DEP_ACCTD_AMT_p return number is
	Begin
	 return P_DEP_ACCTD_AMT;
	 END;
 Function P_DEP_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_DEP_ACCTD_AMT_DSP;
	 END;
 Function P_ENDORSMNT_AMT_p return number is
	Begin
	 return P_ENDORSMNT_AMT;
	 END;
 Function P_ENDORSMNT_ACCTD_AMT_p return number is
	Begin
	 return P_ENDORSMNT_ACCTD_AMT;
	 END;
 Function P_ENDORSMNT_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_ENDORSMNT_ACCTD_AMT_DSP;
	 END;
 Function P_CM_GAIN_LOSS_p return number is
	Begin
	 return P_CM_GAIN_LOSS;
	 END;
 Function P_CM_GAIN_LOSS_DSP_p return varchar2 is
	Begin
	 return P_CM_GAIN_LOSS_DSP;
	 END;
 Function P_PERIOD_TOTAL_AMT_p return number is
	Begin
	 return P_PERIOD_TOTAL_AMT;
	 END;
 Function P_PERIOD_TOTAL_ACCTD_AMT_p return number is
	Begin
	 return P_PERIOD_TOTAL_ACCTD_AMT;
	 END;
 Function P_PERIOD_TOTAL_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_PERIOD_TOTAL_ACCTD_AMT_DSP;
	 END;
 Function P_AMT_DIFF_p return number is
	Begin
	 return P_AMT_DIFF;
	 END;
 Function P_ACCTD_AMT_DIFF_p return number is
	Begin
	 return P_ACCTD_AMT_DIFF;
	 END;
 Function P_ACCTD_AMT_DIFF_DSP_p return varchar2 is
	Begin
	 return P_ACCTD_AMT_DIFF_DSP;
	 END;
 Function P_END_AGE_AMT_p return number is
	Begin
	 return P_END_AGE_AMT;
	 END;
 Function P_END_AGE_ACCTD_AMT_p return number is
	Begin
	 return P_END_AGE_ACCTD_AMT;
	 END;
 Function P_END_AGE_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_END_AGE_ACCTD_AMT_DSP;
	 END;
 Function P_APP_REG_AMT_p return number is
	Begin
	 return P_APP_REG_AMT;
	 END;
 Function P_APP_REG_ACCTD_AMT_p return number is
	Begin
	 return P_APP_REG_ACCTD_AMT;
	 END;
 Function P_APP_REG_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_APP_REG_ACCTD_AMT_DSP;
	 END;
 Function P_APP_AMT_p return number is
	Begin
	 return P_APP_AMT;
	 END;
 Function P_APP_ACCTD_AMT_p return number is
	Begin
	 return P_APP_ACCTD_AMT;
	 END;
 Function P_APP_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_APP_ACCTD_AMT_DSP;
	 END;
 Function P_EDISC_AMT_p return number is
	Begin
	 return P_EDISC_AMT;
	 END;
 Function P_EDISC_ACCTD_AMT_p return number is
	Begin
	 return P_EDISC_ACCTD_AMT;
	 END;
 Function P_UNEDISC_AMT_p return number is
	Begin
	 return P_UNEDISC_AMT;
	 END;
 Function P_UNEDISC_ACCTD_AMT_p return number is
	Begin
	 return P_UNEDISC_ACCTD_AMT;
	 END;
 Function P_EDISC_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_EDISC_ACCTD_AMT_DSP;
	 END;
 Function P_UNEDISC_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_UNEDISC_ACCTD_AMT_DSP;
	 END;
 Function P_INV_EXP_AMT_p return number is
	Begin
	 return P_INV_EXP_AMT;
	 END;
 Function P_INV_EXP_ACCTD_AMT_p return number is
	Begin
	 return P_INV_EXP_ACCTD_AMT;
	 END;
 Function P_INV_EXP_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_INV_EXP_ACCTD_AMT_DSP;
	 END;
 Function P_POST_EXCP_AMT_p return number is
	Begin
	 return P_POST_EXCP_AMT;
	 END;
 Function P_POST_EXCP_ACCTD_AMT_p return number is
	Begin
	 return P_POST_EXCP_ACCTD_AMT;
	 END;
 Function P_POST_EXCP_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_POST_EXCP_ACCTD_AMT_DSP;
	 END;
 Function P_NON_POST_EXCP_AMT_p return number is
	Begin
	 return P_NON_POST_EXCP_AMT;
	 END;
 Function P_NON_POST_EXCP_ACCTD_AMT_p return number is
	Begin
	 return P_NON_POST_EXCP_ACCTD_AMT;
	 END;
 Function P_NON_POST_EXCP_ACCTD_AMT_f return varchar2 is
	Begin
	 return P_NON_POST_EXCP_ACCTD_AMT_DSP;
	 END;
 Function P_SALES_JOURNAL_AMT_p return number is
	Begin
	 return P_SALES_JOURNAL_AMT;
	 END;
 Function P_SALES_JOURNAL_ACCTD_AMT_p return number is
	Begin
	 return P_SALES_JOURNAL_ACCTD_AMT;
	 END;
 Function P_SALES_JOURNAL_ACCTD_AMT_f return varchar2 is
	Begin
	 return P_SALES_JOURNAL_ACCTD_AMT_DSP;
	 END;
 Function P_TRX_DIFF_ACCTD_AMT_p return number is
	Begin
	 return P_TRX_DIFF_ACCTD_AMT;
	 END;
 Function P_TRX_DIFF_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_TRX_DIFF_ACCTD_AMT_DSP;
	 END;
 Function P_ADJ_JOURNAL_AMT_p return number is
	Begin
	 return P_ADJ_JOURNAL_AMT;
	 END;
 Function P_ADJ_JOURNAL_ACCTD_AMT_p return number is
	Begin
	 return P_ADJ_JOURNAL_ACCTD_AMT;
	 END;
 Function P_ADJ_JOURNAL_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_ADJ_JOURNAL_ACCTD_AMT_DSP;
	 END;
 Function P_ADJ_DIFF_ACCTD_AMT_p return number is
	Begin
	 return P_ADJ_DIFF_ACCTD_AMT;
	 END;
 Function P_ADJ_DIFF_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_ADJ_DIFF_ACCTD_AMT_DSP;
	 END;
 Function P_APP_JOURNAL_AMT_p return number is
	Begin
	 return P_APP_JOURNAL_AMT;
	 END;
 Function P_APP_JOURNAL_ACCTD_AMT_p return number is
	Begin
	 return P_APP_JOURNAL_ACCTD_AMT;
	 END;
 Function P_APP_JOURNAL_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_APP_JOURNAL_ACCTD_AMT_DSP;
	 END;
 Function P_APP_DIFF_ACCTD_AMT_p return number is
	Begin
	 return P_APP_DIFF_ACCTD_AMT;
	 END;
 Function P_APP_DIFF_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_APP_DIFF_ACCTD_AMT_DSP;
	 END;
 Function P_UNAPP_JOURNAL_AMT_p return number is
	Begin
	 return P_UNAPP_JOURNAL_AMT;
	 END;
 Function P_UNAPP_JOURNAL_ACCTD_AMT_p return number is
	Begin
	 return P_UNAPP_JOURNAL_ACCTD_AMT;
	 END;
 Function P_UNAPP_JOURNAL_ACCTD_AMT_f return varchar2 is
	Begin
	 return P_UNAPP_JOURNAL_ACCTD_AMT_DSP;
	 END;
 Function P_UNAPP_DIFF_ACCTD_AMT_p return number is
	Begin
	 return P_UNAPP_DIFF_ACCTD_AMT;
	 END;
 Function P_UNAPP_DIFF_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_UNAPP_DIFF_ACCTD_AMT_DSP;
	 END;
 Function P_CM_JOURNAL_ACCTD_AMT_p return number is
	Begin
	 return P_CM_JOURNAL_ACCTD_AMT;
	 END;
 Function P_CM_JOURNAL_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_CM_JOURNAL_ACCTD_AMT_DSP;
	 END;
 Function P_CM_DIFF_ACCTD_AMT_p return number is
	Begin
	 return P_CM_DIFF_ACCTD_AMT;
	 END;
 Function P_CM_DIFF_ACCTD_AMT_DSP_p return varchar2 is
	Begin
	 return P_CM_DIFF_ACCTD_AMT_DSP;
	 END;
 Function P_ORGANIZATION_p return varchar2 is
	Begin
	 return P_ORGANIZATION;
	 END;
 Function P_BILLS_RECEIVABLE_FLAG_p return varchar2 is
	Begin
	 return P_BILLS_RECEIVABLE_FLAG;
	 END;
 Function rp_message_p return varchar2 is
	Begin
	 return rp_message;
	 END;
 Function CP_ACC_MESSAGE_p return varchar2 is
	Begin
	 return CP_ACC_MESSAGE;
	 END;
 Function P_ON_ACC_CM_REF_AMT_p return number is
	Begin
	 return P_ON_ACC_CM_REF_AMT;
	 END;
 Function P_ON_ACC_CM_REF_ACCTD_AMT_p return number is
	Begin
	 return P_ON_ACC_CM_REF_ACCTD_AMT;
	 END;
 Function P_ON_ACC_CM_REF_ACCTD_AMT_f return varchar2 is
	Begin
	 return P_ON_ACC_CM_REF_ACCTD_AMT_DSP;
	 END;
 function F_ACC_MESSAGEFormatTrigger return char is
 begin
  if (arp_util.open_period_exists(p_reporting_level,p_reporting_entity_id,p_gl_date_low,p_gl_date_high)) then
   return 'TRUE';
  else
   return 'FALSE';
  end if;
 end;
END AR_ARXRECON_XMLP_PKG ;


/
