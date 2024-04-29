--------------------------------------------------------
--  DDL for Package Body AP_PMT_CALLOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PMT_CALLOUT_PKG" AS
/*$Header: apcnfrmb.pls 120.36.12010000.28 2010/06/10 23:47:47 gagrawal ship $ */

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_PMT_CALLOUT_PKG';
  G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'AP.PLSQL.AP_PMT_CALLOUT_PKG.';

FUNCTION get_user_rate (p_base_currency_code in varchar2,
                        p_payment_currency_code in varchar2,
                        p_checkrun_id in number) return number is
  l_rate number;
begin

  select exchange_rate
  into l_rate
  from ap_user_exchange_rates
  where checkrun_id = p_checkrun_id
  and ledger_currency_code = p_base_currency_code
  and payment_currency_code = p_payment_currency_code;

  return l_rate;

end;



FUNCTION get_base_amount
    ( p_base_currency_code      in varchar2,
      p_payment_currency_code   in varchar2,
      p_checkrun_id             in number,
      p_exchange_rate_type      in varchar2,
      p_base_currency_mac       in number,
      p_payment_amount          in number,
      p_base_currency_precision in number,
      p_exchange_date           in date) return number is

  l_rate number;
  l_base_amount number;

begin

  if p_exchange_rate_type = 'User' then
    l_rate := ap_pmt_callout_pkg.get_user_rate(p_base_currency_code,
                                               p_payment_currency_code,
                                               p_checkrun_id);


    if p_base_currency_mac is null then
      return round(p_payment_amount * l_rate, p_base_currency_precision);
    else
      return round(((p_payment_amount * l_rate)/p_base_currency_mac)*p_base_currency_mac);
    end if;

  else --exchange rate is not a user rate


    l_base_amount := gl_currency_api.convert_amount_sql(
                                    p_payment_currency_code,
                                    p_base_currency_code,
                                    p_exchange_date,
                                    p_exchange_rate_type,
                                    p_payment_amount);

     if l_base_amount not in (-1,-2) then
       return l_base_amount;
     else
       return null;
     end if;


  end if;



end;




PROCEDURE assign_vouchers (p_completed_pmts_group_id IN number,
                           p_checkrun_id in number,
                           p_first_voucher_number in number,
                           p_current_org_id in number) IS

  l_next_voucher_number number;
  l_check_id number;

  cursor checks_to_assign_vouchers is
    select check_id
    from ap_checks_all
    where completed_pmts_group_id = p_completed_pmts_group_id
    and org_id = p_current_org_id;


begin


  select next_voucher_number
  into l_next_voucher_number
  from ap_inv_selection_criteria_all
  where checkrun_id = p_checkrun_id
  for update;

  if l_next_voucher_number is null then
    l_next_voucher_number := p_first_voucher_number;
  end if;


  open checks_to_assign_vouchers;
  loop
    fetch checks_to_assign_vouchers into l_check_id;
    exit when checks_to_assign_vouchers%notfound;

    update ap_checks_all
    set check_voucher_num = l_next_voucher_number
    where check_id = l_check_id;

    l_next_voucher_number := l_next_voucher_number + 1;



  end loop;

  update ap_inv_selection_criteria_all
  set next_voucher_number = l_next_voucher_number
  where checkrun_id = p_checkrun_id;



end;



PROCEDURE assign_int_inv_sequence(p_check_id in number,
                                  p_check_date in date,
                                  p_seq_num_profile in varchar2,
                                  p_set_of_books_id in number,
                                  x_return_status   IN OUT NOCOPY VARCHAR2,
                                  x_msg_count       IN OUT NOCOPY NUMBER,
                                  x_msg_data        IN OUT NOCOPY VARCHAR2) IS






  CURSOR C_INTEREST_INVOICES IS
    SELECT i.invoice_id
    FROM   ap_invoice_payments_all aip,
           ap_checks_all c,
           ap_invoices_all i,
           ap_invoice_relationships ir
    WHERE  c.check_id = p_check_id
    AND    c.check_id = aip.check_id
    AND    aip.invoice_id = ir.related_invoice_id
    AND    aip.invoice_id = i.invoice_id
    AND    i.invoice_type_lookup_code = 'INTEREST';

  l_invoice_id number;
  l_return_code number;
  l_int_seqval number;
  l_int_dbseqid number;

BEGIN

  /* Initialize return status */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_seq_num_profile = 'P' and
     x_msg_data is not null then
       return; --return without raising an error
  end if;


  open c_interest_invoices;
  loop
    fetch c_interest_invoices INTO l_invoice_id;
    exit when c_interest_invoices%notfound;

    l_return_code := FND_SEQNUM.GET_SEQ_VAL(
                     200,
                     'INT INV',
                     p_set_of_books_id,
                     'A',
                     p_check_date,
                     l_int_seqval,
                     l_int_dbseqid,
		     'N',
                     'N');

    if (l_return_code <> 0 or l_int_seqval is null) and
        p_seq_num_profile = 'A' then

      x_return_status:= FND_API.G_RET_STS_ERROR;
      x_msg_count:= 1;
      x_msg_data := 'Invalid Interest Invoice Sequence';
      return;

    elsif l_return_code = 0 then

      update ap_invoices_all
      set doc_sequence_id = l_int_dbseqid,
          doc_sequence_value = l_int_seqval,
          doc_category_code = 'INT INV'
      where invoice_id = l_invoice_id;

    end if;

  END LOOP;


END assign_int_inv_sequence;




PROCEDURE assign_sequences(p_completed_pmts_group_id IN number,
                           p_set_of_books_id         IN number,
                           p_seq_num_profile         IN varchar,
                           x_return_status           IN OUT nocopy VARCHAR2,
                           x_msg_count               IN OUT nocopy NUMBER,
                           x_msg_data                IN OUT nocopy VARCHAR2,
                           p_auto_calculate_interest_flag in varchar2,
                           p_interest_invoice_count in number,
                           p_check_date date,
                           p_current_org_id in number) IS




  cursor check_sequences is
  select ac.check_id,
         ac.payment_document_id,
         ac.payment_method_code,
         ac.ce_bank_acct_use_id
  from ap_checks_all ac,
       iby_payment_profiles ipp
  where completed_pmts_group_id = p_completed_pmts_group_id
  and   ipp.payment_profile_id = ac.payment_profile_id
  and   ac.org_id = p_current_org_id;


  l_check_id number;
  l_payment_document_id number;
  l_payment_method_code varchar2(30);
  l_bank_acct_use_id number;
  l_doc_category_code varchar2(30);
  l_seqval number;
  l_dbseqid number;
  l_return_code number;
  l_docseq_id	 number;
  l_docseq_type char(1);      -- Bug 5555642
  l_docseq_name varchar2(30);
  l_db_seq_name varchar2(30);
  l_seq_ass_id number;
  l_prd_tab_name	varchar2(30);
  l_aud_tab_name	varchar2(30);
  l_msg_flag varchar(1);
  l_api_name          VARCHAR2(100);
  l_debug_info        varchar2(2000);

BEGIN


   /* Initialize return status */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_api_name := 'assign_sequences';

  -- Bug 5512197.Adding Fnd_Logging for this procedure
  l_debug_info := 'opening check_sequences cursor ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  open check_sequences;
  loop
    fetch check_sequences into l_check_id, l_payment_document_id, l_payment_method_code, l_bank_acct_use_id;

    exit when check_sequences%notfound;

    l_debug_info := 'calling CE_BANK_AND_ACCOUNT_VALIDATION.get_pay_doc_cat ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    CE_BANK_AND_ACCOUNT_VALIDATION.get_pay_doc_cat(l_payment_document_id,
                                                   l_payment_method_code,
                                                   l_bank_acct_use_id,
                                                   l_doc_category_code);  --out



    l_debug_info := 'Value of doc  category code from CE API: '|| l_doc_category_code;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


     -- Bug 5555642. Added fnd-logging and messages for sequence numbering
    --if p_seq_num_profile = 'A' and l_doc_category_code = '-1' then
    -- Bug 5555642
    if l_doc_category_code = '-1' then
      -- x_return_status:= FND_API.G_RET_STS_ERROR; --Bug6258525
       x_msg_count:= 1;
       if p_seq_num_profile = 'P' then
         x_msg_data := 'No document category found and sequential number is set to partially used';
         l_debug_info := 'No document category found from CE API and sequential number is set to '||
                       'partially used';
       elsif p_seq_num_profile = 'A' then
         x_msg_data := 'No document category found and sequential number is set to always used';
         l_debug_info := 'No document category found from CE API and sequential number is set to '||
                       'always used';
         x_return_status:= FND_API.G_RET_STS_ERROR; --Bug6258525
       end if;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       return;

    end if;



    if l_doc_category_code <> '-1' then

    l_debug_info := 'calling fnd_seqnum.get_seq_info ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'set_of_books_id: '||p_set_of_books_id||' check_date: '||
                    to_char(p_check_date, 'DD-MON-YYYY');
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


      l_return_code := fnd_seqnum.get_seq_info(
                app_id			=> 200,
		cat_code		=> l_doc_category_code,
		sob_id			=> p_set_of_books_id,
		met_code		=> 'A',
		trx_date		=> p_check_date,
		docseq_id		=> l_docseq_id,
		docseq_type		=> l_docseq_type,
		docseq_name		=> l_docseq_name,
		db_seq_name		=> l_db_seq_name,
		seq_ass_id		=> l_seq_ass_id,
		prd_tab_name	        => l_prd_tab_name,
		aud_tab_name	        => l_aud_tab_name,
		msg_flag		=> l_msg_flag);

      if l_return_code = 0 then
        if l_docseq_type = 'M' then
          x_msg_data := 'Manual Sequence assigned to Automatic Payments';
        end if;

      elsif l_return_code = -1 then
        x_msg_data := 'An oracle error occurred';
      elsif l_return_code = -2 then
        x_msg_data := 'No sequence assignment exists';
      elsif l_return_code = -3 then
        x_msg_data := 'The assigned sequence is inactive';
      elsif l_return_code = -8 then
        x_msg_data := 'Sequential Numbering is always used and there is no assignment';
      else
        x_msg_data := 'Invalid document sequence setup';
      end if;

      --Bug 6736077
      IF l_doc_category_code <> '-1' AND  p_seq_num_profile = 'P' THEN
        IF  l_return_code = -2 THEN
          RETURN;
         END IF;
      END IF;

      l_debug_info := 'Return Code from fnd_seqnum.get_seq_info: '||l_return_code;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'docseq_id: '||l_docseq_id||', docseq_type: '||l_docseq_type
                      ||' ,docseq_name: '||l_docseq_name;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'db_seq_name: '||l_db_seq_name||', seq_ass_id: '||l_seq_ass_id;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;


      l_debug_info := 'prd_tab_name: '||l_prd_tab_name||', aud_tab_name: '||l_aud_tab_name;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;


      if x_msg_data is not null then
        x_return_status:= FND_API.G_RET_STS_ERROR;
        x_msg_count:= 1;
        l_debug_info := x_msg_data;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        return;
      else
        l_debug_info := 'FND_SEQNUM.Get_Seq_Info returned succesfully';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

      end if;



      l_return_code := FND_SEQNUM.GET_SEQ_VAL(
                       200,
                       l_doc_category_code,
                       p_set_of_books_id,
                       'A',
                       p_check_date,
                       l_seqval,
                       l_dbseqid,
		       'N',
                       'N');

      l_debug_info := 'Return Code from fnd_seqnum.get_seq_val: '||l_return_code;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'seq_val: '||l_seqval||', docseq_d: '||l_dbseqid;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      if l_return_code <> 0 or l_seqval is null then

        x_return_status:= FND_API.G_RET_STS_ERROR;
        x_msg_count:= 1;
        x_msg_data := 'Invalid Sequence';
        return;

      elsif l_return_code = 0 then

        update ap_checks_all
        set doc_sequence_id = l_dbseqid,
            doc_sequence_value = l_seqval,
            doc_category_code = l_doc_category_code
        where check_id = l_check_id;


      end if;

    end if;





    IF p_auto_calculate_interest_flag = 'Y' and p_interest_invoice_count > 0 then

      l_return_code := fnd_seqnum.get_seq_info(
        app_id			=> 200,
		cat_code		=> 'INT INV',
		sob_id			=> p_set_of_books_id,
		met_code		=> 'A',
		trx_date		=> p_check_date,
		docseq_id		=> l_docseq_id,
		docseq_type		=> l_docseq_type,
		docseq_name		=> l_docseq_name,
		db_seq_name		=> l_db_seq_name,
		seq_ass_id		=> l_seq_ass_id,
		prd_tab_name	=> l_prd_tab_name,
		aud_tab_name	=> l_aud_tab_name,
		msg_flag		=> l_msg_flag);

      if l_return_code = 0 then
        if l_docseq_type = 'M' then
          x_msg_data := 'Manual Sequence assigned to interest invoices';
        end if;

      elsif l_return_code = -1 then
        x_msg_data := 'An oracle error occurred';
      elsif l_return_code = -2 then
        x_msg_data := 'No sequence assignment exists for interest invoices';
      elsif l_return_code = -3 then
        x_msg_data := 'The assigned interest invoice sequence is inactive';
      elsif l_return_code = -8 then
        x_msg_data := 'Sequential Numbering is always used and there is no assignment for interest invoices';
      else
        x_msg_data := 'Invalid document sequence setup for interest invoices';
      end if;

      if x_msg_data is not null and p_seq_num_profile = 'A' then
        x_return_status:= FND_API.G_RET_STS_ERROR;
        x_msg_count:= 1;
        return;
      end if;


      assign_int_inv_sequence ( l_check_id,
                                p_check_date,
                                p_seq_num_profile,
                                p_set_of_books_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);

        if x_return_status = FND_API.G_RET_STS_ERROR then
          return;
        end if;



    END if;

  end loop;

END assign_sequences;


PROCEDURE documents_payable_rejected
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2,
       p_commit                 IN  VARCHAR2,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2,
       p_rejected_docs_group_id IN  NUMBER) IS


  l_checkrun_id   number;
  l_checkrun_name ap_inv_selection_criteria_all.checkrun_name%type;
  l_check_date    date;
  l_debug_info    varchar2(200);
/*Bug 5020577*/
/*Introduced the join for org id with IBY tables*/
  CURSOR c_sel_invs  IS
    SELECT invoice_id
    ,      vendor_id
    ,      payment_num
    FROM   ap_SELECTed_invoices_all ASI,
           ap_system_parameters_all asp,
           iby_fd_docs_payable_v ibydocs
    WHERE  checkrun_name = l_checkrun_name
      AND  original_invoice_id IS NULL
      /* Bug 6950891. Added TO_CHAR */
      AND  ibydocs.calling_app_doc_unique_ref1 = TO_CHAR(ASI.checkrun_id)
      AND  ibydocs.calling_app_doc_unique_ref2 = TO_CHAR(ASI.invoice_id)
      AND  ibydocs.calling_app_doc_unique_ref3 = TO_CHAR(ASI.payment_num)
      AND  ibydocs.rejected_docs_group_id = p_rejected_docs_group_id
      AND  asp.org_id = asi.org_id
       and ibydocs.org_id=asp.org_id
       and ibydocs.calling_app_id = 200
      and  checkrun_id = l_checkrun_id
       AND  decode(nvl(ASP.allow_awt_flag, 'N'), 'Y',
                  decode(ASP.create_awt_dists_type,'BOTH','Y','PAYMENT',
                   'Y', decode(ASP.create_awt_invoices_type,'BOTH','Y','PAYMENT',
                              'Y', 'N'),
                         'N'),--Bug6660355
                  'N') = 'Y';

  rec_sel_invs c_sel_invs%ROWTYPE;




BEGIN


  select calling_app_doc_unique_ref1
  into l_checkrun_id
  from iby_fd_docs_payable_v
  where rejected_docs_group_id = p_rejected_docs_group_id
  and rownum=1;


  select checkrun_name, check_date
  into l_checkrun_name, l_check_date
  from ap_inv_selection_criteria_all
  where checkrun_id = l_checkrun_id;

  OPEN c_sel_invs;

  LOOP
    l_debug_info := 'Fetch CURSOR for all SELECTed invoices';
    FETCH c_sel_invs INTO rec_sel_invs;
    EXIT WHEN c_sel_invs%NOTFOUND;

    DECLARE
      undo_output VARCHAR2(2000);
    BEGIN
      AP_WITHHOLDING_PKG.Ap_Undo_Temp_Withholding
                     (P_Invoice_Id             => rec_sel_invs.invoice_id
                     ,P_VENDor_Id              => rec_sel_invs.vendor_id
                     ,P_Payment_Num            => rec_sel_invs.payment_num
                     ,P_Checkrun_Name          => l_Checkrun_Name
                     ,P_Undo_Awt_Date          => SYSDATE
                     ,P_Calling_Module         => 'CANCEL'
                     ,P_Last_Updated_By        => to_number(FND_PROFILE.VALUE('USER_ID'))
                     ,P_Last_Update_Login      => to_number(FND_PROFILE.VALUE('LOGIN_ID'))
                     ,P_Program_Application_Id => to_number(FND_PROFILE.VALUE('PROGRAM_APPLICATION_ID'))
                     ,P_Program_Id             => to_number(FND_PROFILE.VALUE('PROGRAM_ID'))
                     ,P_Request_Id             => to_number(FND_PROFILE.VALUE('REQUEST_ID'))
                     ,P_Awt_Success            => undo_output
                     ,P_checkrun_id            => l_checkrun_id );
    END;
  END LOOP;

  l_debug_info := 'CLOSE CURSOR for all SELECTed invoices';
  CLOSE c_sel_invs;


  --4693463

  delete from ap_unselected_invoices_all
  where checkrun_id = l_checkrun_id;



  delete from ap_selected_invoices_all
  where checkrun_id = l_checkrun_id
  /* Bug 6950891. Added TO_CHAR */
  and (TO_CHAR(invoice_id), TO_CHAR(payment_num)) in
      (select calling_app_doc_unique_ref2,
              calling_app_doc_unique_ref3
       from iby_fd_docs_payable_v
       where rejected_docs_group_id = p_rejected_docs_group_id);

  update ap_payment_schedules_all
  set checkrun_id = null
  where checkrun_id = l_checkrun_id
  /* Bug 6950891. Added TO_CHAR */
  and (TO_CHAR(invoice_id), TO_CHAR(payment_num)) in
      (select calling_app_doc_unique_ref2,
              calling_app_doc_unique_ref3
       from iby_fd_docs_payable_v
       where rejected_docs_group_id = p_rejected_docs_group_id);


  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END documents_payable_rejected;






PROCEDURE payments_completed
      (p_api_version             IN  NUMBER,
       p_init_msg_list           IN  VARCHAR2,
       p_commit                  IN  VARCHAR2,
       x_return_status           OUT nocopy VARCHAR2,
       x_msg_count               OUT nocopy NUMBER,
       x_msg_data                OUT nocopy VARCHAR2,
       p_completed_pmts_group_id IN  NUMBER) IS


l_batch_control_flag           varchar2(1);
l_interest_terms_id            number;
l_nls_int_inv_desc             varchar2(80);
l_perform_awt_flag             varchar2(1);
l_set_of_books_id              number;
l_interest_invoice_count       number;
l_checkrun_id                  number;
l_checkrun_name                ap_checks_all.checkrun_name%type;
l_exchange_rate_type           varchar2(30);
l_transfer_priority            varchar2(25);
l_check_date                   date;
l_current_org_id               number;
l_when_to_account_payment      varchar2(20);
l_company_name                 varchar2(30);
l_int_asset_tracking_flag      varchar2(1);
l_report_date                  varchar2(15);
l_interest_code_combination_id number;
l_base_currency_code           varchar2(10);
l_auto_calculate_interest_flag varchar2(1);
l_interest_accts_pay_ccid      number;
l_int_batch_id                 number;
l_prorate_int_inv_across_dists varchar2(1);
l_accounting_event_id          number;
l_period_name                  varchar2(15);
l_last_updated_by              number;

l_seq_num_profile              varchar2(80);
l_first_voucher_number         number;
l_base_currency_mac            number;
l_base_currency_precision      number;

l_current_calling_sequence     varchar2(2000);
l_debug_info                   varchar2(2000);

l_check_id                     number;
l_application_id               number;
l_return_status                varchar2(1);
l_msg_count                    number;
l_msg_data                     varchar2(2000);

subscribe_exception            exception;

--Bug 5115310 Start
TYPE checkrun_id_tab  IS TABLE OF NUMBER(15)    INDEX BY BINARY_INTEGER;
l_checkrun_id_list  checkrun_id_tab;
l_check_count       NUMBER;
l_total_check_count NUMBER;
l_docs_count        NUMBER;
l_total_docs_count  NUMBER;
l_iby_check_count   NUMBER;
l_iby_docs_count    NUMBER;
l_api_name          VARCHAR2(100);


CURSOR c_relevant_checkrun_ids IS
SELECT distinct calling_app_doc_unique_ref1
  FROM iby_fd_payments_v pmts,
       iby_fd_docs_payable_v docs
  WHERE pmts.payment_id = docs.payment_id
  AND pmts.completed_pmts_group_id = p_completed_pmts_group_id
  AND pmts.org_type = 'OPERATING_UNIT';


CURSOR c_relevant_orgs(c_checkrun_id IN NUMBER) is
SELECT distinct pmts.org_id
  FROM iby_fd_payments_v pmts,
       iby_fd_docs_payable_v docs
  WHERE pmts.payment_id = docs.payment_id
  AND pmts.completed_pmts_group_id = p_completed_pmts_group_id
  AND pmts.org_type = 'OPERATING_UNIT'
  AND docs.calling_app_doc_unique_ref1 = c_checkrun_id;
--Bug 5115310 End


  -- Added for Payment Request
  CURSOR c_subscribed_payments IS
  SELECT Distinct AC.Check_ID,
         APR.Reg_Application_ID
  FROM   AP_Checks_All AC,
         AP_Invoice_Payments_All AIP,
         AP_Invoices_All AI,
         AP_Product_Registrations APR
  WHERE  AC.Checkrun_Name = l_checkrun_name
  AND    AC.Completed_Pmts_Group_ID = p_completed_pmts_group_id
  AND    AC.Org_ID = l_current_org_id
  AND    AC.Check_ID = AIP.Check_ID
  AND    AIP.Invoice_ID = AI.Invoice_ID
  AND    AI.Application_ID = APR.Reg_Application_ID
  AND    APR.Registration_Event_Type = 'PAYMENT_CREATED';

  -- Bug 5658623. Cursor proceesing for Performance reason
  CURSOR c_invoice_amounts(p_last_updated_by    Number,
                           p_completed_group_id Number,
                           p_current_org_id     Number,
                           p_checkrun_name      Varchar2) IS
  SELECT sysdate,
         p_last_updated_by,
         iby_amount_paid,
         iby_discount_amount_taken,
         AP_INVOICES_UTILITY_PKG.get_payment_status(inv.invoice_id),
         inv.invoice_id
  FROM   ap_invoices_all          inv,
         ap_selected_invoices_all si,
         (SELECT sum(ibydocs.payment_amount)                      iby_amount_paid,
                 nvl(sum(ibydocs.payment_curr_discount_taken),0)  iby_discount_amount_taken,
                 ibydocs.calling_app_doc_unique_ref1  ref1,
                 ibydocs.calling_app_doc_unique_ref2  ref2,
                 ibydocs.calling_app_doc_unique_ref3  ref3
          FROM   iby_fd_docs_payable_v ibydocs,
                 iby_fd_payments_v ibypmts
          WHERE  ibypmts.org_type = 'OPERATING_UNIT'
          AND    ibypmts.payment_id = ibydocs.payment_id
          AND    ibypmts.completed_pmts_group_id = p_completed_group_id
          AND    ibypmts.org_id = p_current_org_id
          GROUP BY ibydocs.calling_app_doc_unique_ref1,
                   ibydocs.calling_app_doc_unique_ref2,
                   ibydocs.calling_app_doc_unique_ref3) ibydpm
  WHERE  inv.invoice_id = si.invoice_id
  AND    si.checkrun_name = p_checkrun_name
  AND    inv.invoice_type_lookup_code <> 'INTEREST'
  AND    ibydpm.ref2 = to_char(inv.invoice_id)
  AND    ibydpm.ref1 = to_char(si.checkrun_id)
  AND    ibydpm.ref2 = to_char(si.invoice_id)
  AND    ibydpm.ref3 = to_char(si.payment_num);


     -- Bug 5658623. Cursor proceesing for Performance reason
  CURSOR c_schedule_amounts(p_last_updated_by    Number,
                            p_completed_group_id Number,
                            p_current_org_id     Number,
                            p_checkrun_name      Varchar2) IS
  SELECT sysdate,
         p_last_updated_by,
         (si.amount_remaining - ibydocs.payment_amount -
            nvl(ibydocs.payment_curr_discount_taken,0)),
         0,
         decode(si.amount_remaining - ibydocs.payment_amount -
           nvl(ibydocs.payment_curr_discount_taken,0), 0,
           'Y', 'P'),
	    /* commented by zrehman for Bug#6836199 on 24-Jun-2008
 	 (si.amount_remaining - si.proposed_payment_amount -
            nvl(ibydocs.payment_curr_discount_taken,0)),
         0,
         decode(si.amount_remaining - si.proposed_payment_amount -
           nvl(ibydocs.payment_curr_discount_taken,0), 0,
           'Y', 'P'),*/
         -- Added by epajaril to capture the AWT
	 -- Bug8477014: Undoing changes done for bug6836199
         -- Bug8752557: Undoing changes done here for bug8477014
         si.withholding_amount,
         Null,
         ps.invoice_id,
         ps.payment_num
  FROM   ap_payment_schedules_all  ps,
         ap_invoices_all           inv,
         ap_selected_invoices_all  si,
         /*iby_fd_payments_v         ibypmts, Commented for Bug#9459810 */
         iby_fd_docs_payable_v     ibydocs
  WHERE  si.checkrun_name = p_checkrun_name
  AND    si.payment_num = ps.payment_num
  AND    si.invoice_id = ps.invoice_id
  AND    ibydocs.calling_app_doc_unique_ref1 = to_char(si.checkrun_id)
  AND    ibydocs.calling_app_doc_unique_ref2 = to_char(si.invoice_id)
  AND    ibydocs.calling_app_doc_unique_ref3 = to_char(si.payment_num)
  /*AND    ibypmts.payment_id = ibydocs.payment_id
  AND    ibypmts.completed_pmts_group_id = p_completed_group_id
  AND    ibypmts.org_id = p_current_org_id
  AND    ibypmts.org_type = 'OPERATING_UNIT' Commented for bug#9459810*/
  /* Added for bug#9459810 Start */
  AND    ibydocs.completed_pmts_group_id = p_completed_group_id
  AND    ibydocs.org_id = p_current_org_id
  AND    ibydocs.org_type = 'OPERATING_UNIT'
  /* Added for bug#9459810 End */
  AND    inv.invoice_id = si.invoice_id
  AND    inv.invoice_id = ps.invoice_id
  AND    inv.invoice_type_lookup_code <> 'INTEREST';

  -- Bug 5658623. Forall Processing for updating invoices and schedules
  TYPE t_date_tab   IS TABLE OF date INDEX BY binary_integer;
  TYPE t_number_tab IS TABLE OF number INDEX BY binary_integer;
  TYPE t_char_tab   IS TABLE OF varchar2(10) INDEX BY binary_integer;

  last_update_date_inv_l       t_date_tab;
  last_updated_by_inv_l        t_number_tab;
  amount_paid_inv_l            t_number_tab;
  discount_taken_inv_l         t_number_tab;
  payment_status_inv_l         t_char_tab;
  invoice_id_inv_l             t_number_tab;

  last_update_date_ps_l        t_date_tab;
  last_updated_by_ps_l         t_number_tab;
  amount_remaining_ps_l        t_number_tab;
  discount_remaining_ps_l      t_number_tab;
  payment_status_ps_l          t_char_tab;
  checkrun_id_ps_l             t_number_tab;
  invoice_id_ps_l              t_number_tab;
  payment_num_ps_l             t_number_tab;
  awt_num_ps_l                 t_number_tab;
  l_wf_event_exists            NUMBER; /* Added for bug#9459810 */

--Bug 9074840 start
   TYPE prob_pay_rec IS RECORD
   ( payment_id               iby_payments_all.payment_id%TYPE
   , payment_reference_number iby_payments_all.payment_reference_number%TYPE
   , payment_instruction_id   iby_payments_all.payment_instruction_id%TYPE
   , invoice_id        iby_docs_payable_all.calling_app_doc_unique_ref2%TYPE
   , payment_num           iby_docs_payable_all.calling_app_doc_unique_ref3%TYPE
   , prob_type         varchar2(200));

   TYPE prob_pmt_tab IS TABLE OF prob_pay_rec INDEX BY BINARY_INTEGER;
   l_prob_pmt_list     prob_pmt_tab;


   CURSOR c_prob_iby_payments IS
    select payment_id, payment_reference_number, payment_instruction_id
    , null, null, 'IBY_PMT'
    FROM iby_fd_payments_v ifp
    WHERE ifp.completed_pmts_group_id =  p_completed_pmts_group_id
    and not exists
     (select 1
     from ap_checks_all c
     where c.completed_pmts_group_id =  ifp.completed_pmts_group_id
     and c.payment_id = ifp.payment_id);

   CURSOR c_prob_iby_docs IS
   select ifp.payment_id, ifp.payment_reference_number, ifp.payment_instruction_id
   , ifd.calling_app_doc_unique_ref2, ifd.calling_app_doc_unique_ref3
   , 'IBY_DOC'
   from iby_fd_docs_payable_v ifd
   , iby_fd_payments_v ifp
   where ifd.payment_id = ifp.payment_id (+)
   and ifd.completed_pmts_group_id =  p_completed_pmts_group_id
   and not exists
           (select 1
            from ap_invoice_payments_all ip
            , ap_checks_all c
            where c.payment_id = ifd.payment_id
            and c.completed_pmts_group_id = ifd.completed_pmts_group_id
            and c.check_id = ip.check_id
            and ifd.calling_app_doc_unique_ref2 = TO_CHAR(ip.invoice_id)
            and ifd.calling_app_doc_unique_ref3 = TO_CHAR(ip.payment_num));

   CURSOR c_prob_checks IS
   select c.payment_id, ifp.payment_reference_number, ifp.payment_instruction_id
   , null, null, 'AP_CHECK'
   from ap_checks_all c
   , iby_fd_payments_v ifp
   where c.completed_pmts_group_id =  ifp.completed_pmts_group_id
   and c.payment_id = ifp.payment_id
   and c.completed_pmts_group_id = p_completed_pmts_group_id
   group by c.payment_id, ifp.payment_reference_number, ifp.payment_instruction_id
   having count(c.check_id) > 1;

   CURSOR c_prob_inv_pmts IS
   select ifp.payment_id, ifp.payment_reference_number
   , ifp.payment_instruction_id, TO_CHAR(ip.invoice_id), TO_CHAR(ip.payment_num)
   , 'AP_INV_PAY'
   from ap_invoice_payments_all ip
   , ap_checks_all c
   , iby_fd_payments_v ifp
   where ip.check_id = c.check_id
   and ifp.payment_id = c.payment_id
   and ifp.completed_pmts_group_id = c.completed_pmts_group_id
   and c.completed_pmts_group_id = p_completed_pmts_group_id
   group by ifp.payment_id, ifp.payment_reference_number
   , ifp.payment_instruction_id, ip.invoice_id, ip.payment_num
   having count(ip.invoice_payment_id) > 1;

   PROCEDURE print_prob_pmt_detail (p_prob_pmt_list prob_pmt_tab
                                   , p_message_name varchar2) IS
   BEGIN
      if p_prob_pmt_list.exists(1) then
         fnd_message.set_name('SQLAP', p_message_name);
         l_debug_info := fnd_message.get;
         FND_FILE.PUT_LINE(FND_FILE.LOG, l_debug_info);

         for i in l_prob_pmt_list.FIRST .. l_prob_pmt_list.LAST
         loop
            fnd_message.set_name('SQLAP', 'AP_IBY_PMT_MISMATCH_DETAIL');
            fnd_message.set_token('PAYMENT_REFERENCE_NUMBER', l_prob_pmt_list(i).payment_reference_number);
            fnd_message.set_token('PAYMENT_ID', l_prob_pmt_list(i).payment_id);
            fnd_message.set_token('PAYMENT_INSTRUCTION_ID', l_prob_pmt_list(i).payment_instruction_id);
            fnd_message.set_token('INVOICE_ID', l_prob_pmt_list(i).invoice_id);
            fnd_message.set_token('PAYMENT_NUM', l_prob_pmt_list(i).payment_num);
            l_debug_info := fnd_message.get;
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_debug_info);
         end loop;
      end if;
   END print_prob_pmt_detail;

--Bug 9074840 end

BEGIN
  l_api_name := 'payments_completed';
  l_current_calling_sequence := 'AP_PMT_CALLOUT_PKG.payments_completed';

  l_check_count       :=0;
  l_total_check_count :=0;
  l_docs_count        :=0;
  l_total_docs_count  :=0;
  l_iby_check_count   :=0;
  l_iby_docs_count    :=0;



  l_debug_info := 'get displayed Field';
  fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  SELECT displayed_field
  INTO   l_nls_int_inv_desc
  FROM   ap_lookup_codes
  WHERE  lookup_type = 'NLS TRANSLATION'
  AND    lookup_code = 'INTEREST OVERDUE INVOICE';



/* --Bug 5115310
  SELECT calling_app_doc_unique_ref1
  INTO l_checkrun_id
  FROM iby_fd_payments_v pmts,
       iby_fd_docs_payable_v docs
  WHERE pmts.payment_id = docs.payment_id
  AND pmts.completed_pmts_group_id = p_completed_pmts_group_id
  AND pmts.org_type = 'OPERATING_UNIT'
  AND rownum=1;
  */


  --Bug 5115310

   /* Initialize message list if p_init_msg_list is set to TRUE */
 /* IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
  END IF;
 */
     /* Initialize return status */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debug_info := 'get_relevant_checkrun_ids';
  fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN c_relevant_checkrun_ids;
  FETCH c_relevant_checkrun_ids
  BULK COLLECT INTO  l_checkrun_id_list;
  CLOSE c_relevant_checkrun_ids;


  FOR i IN 1..l_checkrun_id_list.COUNT
  LOOP

      l_checkrun_id :=  l_checkrun_id_list(i);

      l_debug_info := 'l_checkrun_id: '||to_char(l_checkrun_id);
      fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_debug_info := 'get_checkrun_info';
      fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      SELECT exchange_rate_type,
             transfer_priority,
             check_date,
             checkrun_name,
             first_voucher_number
      INTO l_exchange_rate_type,
           l_transfer_priority,
           l_check_date,  --use this for the exchange date also, PM confirmed
           l_checkrun_name,
           l_first_voucher_number
      FROM ap_inv_selection_criteria_all
      WHERE checkrun_id = l_checkrun_id;

      l_debug_info := 'get_terms';
      fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      BEGIN
        --these are not multi-org table so should be fine
        SELECT apt.term_id
        INTO   l_interest_terms_id
        FROM   ap_terms apt, ap_terms_lines atl
        WHERE  apt.term_id = atl.term_id
        AND    atl.due_days=0
        AND    nvl(end_date_active,sysdate+1) >= sysdate
        AND    rownum < 2;
       EXCEPTION
         WHEN no_data_found THEN null;
       END;

      l_last_updated_by   := to_number(FND_GLOBAL.USER_ID);

      l_debug_info := 'get_profiles';
      fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      fnd_profile.get('UNIQUE:SEQ_NUMBERS',l_seq_num_profile);
      fnd_profile.get('AP_USE_INV_BATCH_CONTROLS', l_batch_control_flag);

      OPEN c_relevant_orgs(l_checkrun_id);

      l_debug_info := 'c_relevant_orgs';
      fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      LOOP
          FETCH c_relevant_orgs INTO l_current_org_id;
          EXIT WHEN c_relevant_orgs%NOTFOUND;

          l_debug_info := 'l_current_org_id: '||to_char(l_current_org_id);
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
          l_debug_info := 'get_org_info';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          /* Bug 5124784. dist_code_combination_id, proration across distribution will
             decided by parent invoice */
          SELECT nvl(when_to_account_pmt,'ALWAYS'),
                 --nvl(prorate_int_inv_across_dists,'N'),
                 interest_code_combination_id,
                 base_currency_code,
                 nvl(auto_calculate_interest_flag, 'N'),
                 interest_accts_pay_ccid,
                 DECODE(account_type, 'A','Y','N'),
                 to_char(sysdate, 'DD-MON-RR HH24:MI'),
                 gsob.name,
                 decode(l_batch_control_flag, 'Y', AP_BATCHES_S.nextval, null),
/* Added BOTH for performing AWT -- Bug 9697441 */
                 decode(nvl(ASP.allow_awt_flag, 'N'),
                            'Y', decode(ASP.create_awt_dists_type,
                                     'PAYMENT', 'Y', 'BOTH', 'Y',
                                                decode(ASP.create_awt_invoices_type,
                                                    'PAYMENT', 'Y', 'BOTH', 'Y',
                                                               'N')),
                            'N'),
                 asp.set_of_books_id,
                 ap_utilities_pkg.get_gl_period_name(l_check_date,l_current_org_id)
          INTO  l_when_to_account_payment,
                --l_prorate_int_inv_across_dists,
                l_interest_code_combination_id,
                l_base_currency_code,
                l_auto_calculate_interest_flag,
                l_interest_accts_pay_ccid,
                l_int_asset_tracking_flag,
                l_report_date,
                l_company_name,
                l_int_batch_id,
                l_perform_awt_flag,
                l_set_of_books_id,
                l_period_name
          FROM ap_system_parameters_all asp,
               gl_code_combinations gc,
               gl_sets_of_books gsob
          WHERE gc.code_combination_id(+) = asp.interest_code_combination_id
          AND   gsob.set_of_books_id = asp.set_of_books_id
          AND   asp.org_id = l_current_org_id;


          select minimum_accountable_unit, precision
          into l_base_currency_mac, l_base_currency_precision
          from fnd_currencies
          where currency_code = l_base_currency_code;


          IF l_auto_calculate_interest_flag = 'Y' THEN

            l_debug_info := 'do interest invoice insertions';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            INSERT INTO ap_invoices_all(
             invoice_id,
             last_update_date,
             last_updated_by,
             vendor_id,
             invoice_num,
             invoice_amount,
             vendor_site_id,
             amount_paid,
             discount_amount_taken,
             invoice_date,
             invoice_type_lookup_code,
             description,
             batch_id,
             amount_applicable_to_discount,
             tax_amount,
             terms_id,
             terms_date,
             voucher_num,
             pay_group_lookup_code,
             set_of_books_id,
             accts_pay_code_combination_id,
             invoice_currency_code,
             payment_currency_code,
             payment_status_flag,
             posting_status,
             creation_date,
             created_by,
             payment_cross_rate,
             exchange_rate,
             exchange_rate_type,
             exchange_date,
             base_amount,
             source,
             payment_method_code,
             pay_curr_invoice_amount,
             payment_cross_rate_date,
             payment_cross_rate_type,
             gl_date,
             exclusive_payment_flag,
             approval_ready_flag,
             wfapproval_status,
             legal_entity_id,
             org_id,
             party_id,
             party_site_id,
	     -- added below columns for 7673570
             remit_to_supplier_name,
             remit_to_supplier_id,
             remit_to_supplier_site,
             remit_to_supplier_site_id,
	     relationship_id)
            SELECT
                new.invoice_id,
                SYSDATE,
                l_last_updated_by,
                new.vendor_id,
                new.invoice_num,
                decode(fcinv.minimum_accountable_unit, null,
                           round((new.payment_amount/orig.payment_cross_rate),
                                 fcinv.precision),
                           round((new.payment_amount/orig.payment_cross_rate)
                                 /fcinv.minimum_accountable_unit)
                                * fcinv.minimum_accountable_unit),
                new.vendor_site_id,
                ibydocs.payment_amount,
                0,
                new.due_date,
                'INTEREST',
                new.invoice_description||orig.invoice_num,
                l_int_batch_id,
                null,
                null,
                orig.terms_id,  /* bug 5124784. Terms will be the parent Invoice term. */
                orig.terms_date,
                orig.voucher_num,
                orig.pay_group_lookup_code,
                orig.set_of_books_id,
                l_interest_accts_pay_ccid,
                orig.invoice_currency_code,
                orig.payment_currency_code,
                'Y',
                null,
                SYSDATE,
                l_last_updated_by,
                orig.payment_cross_rate,
                -- Start bug 8899917 use new instead of orig.
                new.payment_exchange_rate,
                new.payment_exchange_rate_type,
                l_check_date, -- exchange_date
                decode(orig.invoice_currency_code, l_base_currency_code,
                       NULL,
                       decode(l_base_currency_mac, null,
                              round(new.payment_amount / orig.payment_cross_rate *
                                 nvl(new.payment_exchange_rate,1), l_base_currency_precision),
                              round( (new.payment_amount / orig.payment_cross_rate *
                                 nvl(new.payment_exchange_rate,1)) /
                                    l_base_currency_mac) *
                                    l_base_currency_mac  ) ),
                --end bug 8899917
                'Confirm PaymentBatch',
                orig.payment_method_code,
                new.payment_amount,
                orig.payment_cross_rate_date,
                orig.payment_cross_rate_type,
                new.due_date,
                new.exclusive_payment_flag,
                'Y',
                'NOT REQUIRED',
                ibypmts.legal_entity_id,
                ibypmts.org_id,
                orig.party_id,
                orig.party_site_id,
		-- added below columns for 7673570
 	        ibypmts.PAYEE_NAME,
                NVL(aps.vendor_id,-222), -- Modified for bug 8405513
                aps.vendor_site_code,
                NVL(ibypmts.supplier_site_id,-222), --modifed for bug 8405513
	        ibypmts.relationship_id
            FROM   ap_invoices_all orig,
	           ap_supplier_sites_all aps, -- bug 7673570
                   iby_fd_payments_v ibypmts,
                   ap_selected_invoices_all new,
                   iby_fd_docs_payable_v ibydocs,
                   fnd_currencies fcinv
                  /* Bug 6950891 . Added TO_CHAR */
            WHERE ibydocs.calling_app_doc_unique_ref1 = TO_CHAR(new.checkrun_id)
            AND   ibydocs.calling_app_doc_unique_ref2 = TO_CHAR(new.invoice_id)
            AND   ibydocs.calling_app_doc_unique_ref3 = TO_CHAR(new.payment_num)
            AND   new.original_invoice_id = orig.invoice_id
            and   ibypmts.org_type = 'OPERATING_UNIT'
            AND   ibypmts.payment_id = ibydocs.payment_id
            AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
	    AND   aps.vendor_site_id(+) = ibypmts.supplier_site_id -- bug 7673570 --modifed for bug 8405513
            AND   fcinv.currency_code = orig.invoice_currency_code
            AND   ibypmts.org_id = l_current_org_id;


            l_interest_invoice_count := sql%rowcount;

            l_debug_info := 'do interest invoice line insertions';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;


            INSERT INTO ap_invoice_lines_all(
                INVOICE_ID,
                LINE_NUMBER,
                LINE_TYPE_LOOKUP_CODE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                ACCOUNTING_DATE,
                PERIOD_NAME,
                AMOUNT,
                BASE_AMOUNT,
                DESCRIPTION,
                TYPE_1099,
                SET_OF_BOOKS_ID,
                ASSETS_TRACKING_FLAG,
          --      ASSET_BOOK_TYPE_CODE, ??
          --      ASSET_CATEGORY_ID,    ??
                LINE_SOURCE,
                GENERATE_DISTS,
                WFAPPROVAL_STATUS,
                org_id)
              SELECT  new.invoice_id,
                1,
                'ITEM',
                SYSDATE,
                l_last_updated_by,
                sysdate,
                l_last_updated_by,
                new.due_date,
                l_period_name,
                decode(fcinv.minimum_accountable_unit, null,
                           round((ibydocs.payment_amount/orig.payment_cross_rate),
                                 fcinv.precision),
                           round((ibydocs.payment_amount/orig.payment_cross_rate)
                                 /fcinv.minimum_accountable_unit)
                                * fcinv.minimum_accountable_unit),
                 decode(orig.invoice_currency_code, l_base_currency_code,
                        NULL,
                        decode(l_base_currency_mac, null,
                              round(new.payment_amount / orig.payment_cross_rate *
                                 --bug 8899917 take exchange rate from selected inv
                                 nvl(new.payment_exchange_rate,1), l_base_currency_precision),
                              round( (new.payment_amount / orig.payment_cross_rate *
                                 nvl(new.payment_exchange_rate,1)) /
                                    l_base_currency_mac) *
                                    l_base_currency_mac  ) ),
                new.invoice_description||orig.invoice_num,
                pv.type_1099,
                l_set_of_books_id,
                l_int_asset_tracking_flag,
                'AUTO INVOICE CREATION',
                'N',
                'NOT REQUIRED',
                l_current_org_id
              FROM
                po_vendors pv,
                ap_invoices_all orig,
                iby_fd_payments_v ibypmts,
                iby_fd_docs_payable_v ibydocs,
                ap_selected_invoices_all new, -- Modified for bug 8744658
                fnd_currencies fcinv
                                /* Bug 6950891 Added TO_CHAR */
              WHERE ibydocs.calling_app_doc_unique_ref1 = TO_CHAR(new.checkrun_id)
              AND ibydocs.calling_app_doc_unique_ref2 = TO_CHAR(new.invoice_id)
              AND   ibydocs.calling_app_doc_unique_ref3 = TO_CHAR(new.payment_num)
              AND   ibypmts.payment_id = ibydocs.payment_id
              AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
              AND   ibypmts.org_id = l_current_org_id
              and   ibypmts.org_type = 'OPERATING_UNIT'
              AND   new.original_invoice_id = orig.invoice_id
              AND   new.vendor_id = pv.vendor_id
              AND   new.checkrun_name = l_checkrun_name
              AND   fcinv.currency_code = orig.invoice_currency_code;


              l_debug_info := 'do ap_create_batch_interest_dists';
              fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;

              /* Bug 5124784. Distribution for interest invoice will be created via
                 interest invoice package. */

              AP_INTEREST_INVOICE_PKG.ap_create_batch_interest_dists(
                P_checkrun_name                  => l_checkrun_name,
                P_base_currency_code             => l_base_currency_code,
                P_interest_accts_pay_ccid        => l_interest_accts_pay_ccid,
                P_last_updated_by                => l_last_updated_by,
                P_period_name                    => l_period_name,
                P_asset_account_flag             => l_int_asset_tracking_flag,
                P_calling_sequence               => l_current_calling_sequence,
                p_checkrun_id                    => l_checkrun_id,
                p_completed_pmts_group_id        => p_completed_pmts_group_id,
                p_org_id                         => l_current_org_id);



            l_debug_info := 'INSERT INTO ap_payment_schedules_all';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            INSERT INTO ap_payment_schedules_all(
              invoice_id,
              payment_num,
              last_update_date,
              last_updated_by,
              due_date,
              gross_amount,
              discount_amount_available,
              amount_remaining,
              discount_amount_remaining,
              payment_priority,
              payment_status_flag,
              batch_id,
              payment_cross_rate,
              creation_date,
              created_by,
              payment_method_code,
              inv_curr_gross_amount,
              org_id,
	      -- added below columns for 7673570
              remit_to_supplier_name,
              remit_to_supplier_id,
              remit_to_supplier_site,
              remit_to_supplier_site_id,
	      relationship_id)
            SELECT
              new.invoice_id,
              1,
              SYSDATE,
              l_last_updated_by,
              new.due_date,
              ibydocs.payment_amount,
              0,
              0,
              0,
              new.payment_priority,
              'Y',
              l_int_batch_id,
              orig.payment_cross_rate,
              SYSDATE,
              l_last_updated_by,
              orig.payment_method_code,
              decode(fcinv.minimum_accountable_unit, null,
                           round((new.payment_amount/orig.payment_cross_rate),
                                 fcinv.precision),
                           round((new.payment_amount/orig.payment_cross_rate)
                                 /fcinv.minimum_accountable_unit)
                                * fcinv.minimum_accountable_unit),
              l_current_org_id,
	      -- added below columns for 7673570
	      ibypmts.PAYEE_NAME,
              NVL(aps.vendor_id, -222), --Modified for bug 8405513
              aps.vendor_site_code,
              NVL(ibypmts.supplier_site_id, -222), --modifed for bug 8405513
	      ibypmts.relationship_id
            FROM ap_invoices_all orig,
                 ap_selected_invoices_all new,
                 ap_supplier_sites_all aps, -- bug 7673570
                 fnd_currencies fcinv,
                 iby_fd_payments_v ibypmts,
                 iby_fd_docs_payable_v ibydocs
             /* Bug 6950891 Added TO_CHAR */
            WHERE ibydocs.calling_app_doc_unique_ref1 = TO_CHAR(new.checkrun_id)
            AND   ibydocs.calling_app_doc_unique_ref2 = TO_CHAR(new.invoice_id)
            AND   ibydocs.calling_app_doc_unique_ref3 = TO_CHAR(new.payment_num)
            AND   ibypmts.payment_id = ibydocs.payment_id
            AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
            and   ibypmts.org_type = 'OPERATING_UNIT'
            AND   ibypmts.org_id = l_current_org_id
	    AND   aps.vendor_site_id(+) = ibypmts.supplier_site_id -- bug 7673570 --modifed for bug 8405513
            AND   new.original_invoice_id = orig.invoice_id
            AND   new.checkrun_name = l_checkrun_name
            AND   fcinv.currency_code = orig.invoice_currency_code;



            l_debug_info := 'INSERT INTO ap_invoice_relationships';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            INSERT INTO ap_invoice_relationships(
              original_invoice_id,
              related_invoice_id,
              created_by,
              creation_date,
              original_payment_num,
              last_updated_by,
              last_update_date,
              checkrun_name)
            SELECT orig.invoice_id,
                   new.invoice_id,
                   l_last_updated_by,
                   SYSDATE,
                   new.original_payment_num,
                   l_last_updated_by,
                   SYSDATE,
                   l_checkrun_name
            FROM ap_invoices_all orig,
                 ap_selected_invoices_all new,
                 iby_fd_payments_v ibypmts,
                 iby_fd_docs_payable_v ibydocs
             /* Bug 6950891 Added TO_CHAR */
            WHERE ibydocs.calling_app_doc_unique_ref1 = TO_CHAR(new.checkrun_id)
            AND   ibydocs.calling_app_doc_unique_ref2 = TO_CHAR(new.invoice_id)
            and   ibypmts.org_type = 'OPERATING_UNIT'
            AND   ibydocs.calling_app_doc_unique_ref3 = TO_CHAR(new.payment_num)
            AND   ibypmts.payment_id = ibydocs.payment_id
            AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
            AND   ibypmts.org_id = l_current_org_id
            AND   new.original_invoice_id = orig.invoice_id
            AND   new.checkrun_name = l_checkrun_name;



            IF l_batch_control_flag = 'Y' THEN

                l_debug_info := 'INSERT INTO ap_batches_all';
                fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

              INSERT INTO ap_batches_all(
                batch_id,
                batch_name,
                batch_date,
                last_update_date,
                last_updated_by,
                control_invoice_count,
                actual_invoice_count,
                creation_date,
                created_by,
                org_id) --4945922
              SELECT  l_int_batch_id,
                substrb(LC.displayed_field||l_checkrun_name, 1,50),
                SYSDATE,
                SYSDATE,
                l_last_updated_by,
                count(*),
                count(*),
                SYSDATE,
                l_last_updated_by,
                i.org_id
              FROM ap_invoices_all I,
                   ap_lookup_codes LC
              WHERE I.batch_id= l_int_batch_id
              AND   LC.lookup_code = 'NLS TRANLSATION'
              AND   LC.lookup_type = 'INTEREST ON PAYMENTBATCH'
              GROUP BY l_int_batch_id, l_checkrun_name,
                       LC.displayed_field, SYSDATE, l_last_updated_by, i.org_id;

            END if;



          END if;  --if auto_calculate_interest_flag = 'Y'


	/*bug8224330, transported the insert into ap_checks_all here, after the insertion of interest invoices related data
                	 into ap tables*/

          l_debug_info := 'insert into ap_checks_all';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          INSERT INTO ap_checks_all
          (CHECK_ID,
           -- Bug 6845440 commented below field
           -- BANK_ACCOUNT_ID,
           CE_BANK_ACCT_USE_ID,
           BANK_ACCOUNT_NAME,
           AMOUNT,
           CHECK_NUMBER,
           CHECK_DATE,
           CURRENCY_CODE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           VENDOR_ID,
           VENDOR_NAME,
           VENDOR_SITE_ID,
           STATUS_LOOKUP_CODE,
           CHECKRUN_ID,
           CHECKRUN_NAME,
           ADDRESS_LINE1,
           ADDRESS_LINE2,
           ADDRESS_LINE3,
           ADDRESS_LINE4,
           CITY,
           STATE,
           ZIP,
           PROVINCE,
           COUNTRY,
        --   VENDOR_SITE_CODE,
           BANK_ACCOUNT_NUM,
        --   IBAN_NUMBER,
           BANK_NUM,
           BANK_ACCOUNT_TYPE,
           EXTERNAL_BANK_ACCOUNT_ID,
           TRANSFER_PRIORITY,
           PAYMENT_TYPE_FLAG,
           CREATION_DATE,
           CREATED_BY,
           PAYMENT_METHOD_code,
           EXCHANGE_RATE,
           EXCHANGE_RATE_TYPE,
           EXCHANGE_DATE,
           BASE_AMOUNT,
           FUTURE_PAY_DUE_DATE,
           MATURITY_EXCHANGE_DATE,
           MATURITY_EXCHANGE_RATE_TYPE,
           MATURITY_EXCHANGE_RATE,
           ANTICIPATED_VALUE_DATE,
           LEGAL_ENTITY_ID,
           ORG_ID,
           PAYMENT_ID,
           COMPLETED_PMTS_GROUP_ID,
           PAYMENT_PROFILE_ID, --SO WE CAN REFER BACK TO IBY
           PARTY_ID,
           PARTY_SITE_ID,
           PAYMENT_DOCUMENT_ID, --4752808
           PAYMENT_INSTRUCTION_ID, --4884849
	   -- added below columns for 7673570
           REMIT_TO_SUPPLIER_NAME,
           REMIT_TO_SUPPLIER_ID,
           REMIT_TO_SUPPLIER_SITE,
           REMIT_TO_SUPPLIER_SITE_ID,
	   RELATIONSHIP_ID)
          SELECT
               ap_checks_s.nextval,
               -- Bug 6845440 commented below field
               -- ce.bank_account_id,
               ce.bank_acct_use_id,
               ceb.bank_account_name,
               iby.payment_amount,
               nvl(iby.paper_document_number, iby.payment_reference_number),
               iby.payment_date,
               iby.payment_currency_code,
               SYSDATE,
               l_last_updated_by,
               pv.vendor_id,
               pv.vendor_name,
               iby.inv_supplier_site_id,  -- 7673570
               decode(iby.maturity_date,null,'NEGOTIABLE','ISSUED'),
               l_checkrun_id,
               l_checkrun_name,
               iby.payee_address1,
               iby.payee_address2,
               iby.payee_address3,
               iby.payee_address4,
               iby.payee_city,
               iby.payee_state,
               iby.payee_postal_code,
               iby.payee_province,
               iby.payee_country,
        --       sc.vendor_site_code,
               iby.ext_bank_account_number,
        --       SC.iban_number, --need FROM iby
               -- iby.ext_bank_account_name,  -- Bug 5090441
               iby.EXT_BANK_NUMBER,
               iby.ext_bank_account_type,
               iby.external_bank_account_id,
               l_transfer_priority,
               'A',
               sysdate,
               l_last_updated_by,
               iby.payment_method_code,
               decode(iby.payment_currency_code, l_base_currency_code,
                      null,
                      decode(l_exchange_rate_type, 'User',
                             ap_pmt_callout_pkg.get_user_rate(
                                 l_base_currency_code,
                                 iby.payment_currency_code,
                                 l_checkrun_id),
                             ap_utilities_pkg.get_exchange_rate(
                                 iby.payment_currency_code,
                                 l_base_currency_code,
                                 l_exchange_rate_type,
                                 l_check_date,
                                 'CONFIRM'))),
               l_exchange_rate_type,
               l_check_date, --exchange rate date
               decode(iby.payment_currency_code, l_base_currency_code,
                      null,
                      ap_pmt_callout_pkg.get_base_amount(l_base_currency_code,
                                                        iby.payment_currency_code,
                                                        l_checkrun_id,
                                                        l_exchange_rate_type,
                                                        l_base_currency_mac,
                                                        iby.payment_amount,
                                                        l_base_currency_precision,
                                                        l_check_date)),
               iby.maturity_date,
               decode(iby.payment_currency_code, l_base_currency_code,
                       null,
                       decode(l_exchange_rate_type, 'User', l_check_date,
                              iby.maturity_date)),
               l_exchange_rate_type,
               decode(iby.payment_currency_code, l_base_currency_code, NULL,
                       decode(l_exchange_rate_type, 'User',
                              ap_pmt_callout_pkg.get_user_rate(l_base_currency_code,
                                                               iby.payment_currency_code,
                                                               l_checkrun_id),
                              ap_utilities_pkg.get_exchange_rate(
                                  iby.payment_currency_code,
                                  l_base_currency_code,
                                  l_exchange_rate_type,
                                  iby.maturity_date,
                                  'CONFIRM'))),
               iby.anticipated_value_date,
               iby.legal_entity_id,
               iby.org_id,
               iby.payment_id,
               iby.completed_pmts_group_id,
               iby.payment_profile_id,
               iby.inv_payee_party_id, -- 7673570 iby.payee_party_id,
               iby.inv_party_site_id,  -- 7673570 iby.party_site_id,
               iby.payment_document_id,
               iby.payment_instruction_id,
               -- added below columns for 7673570
	       iby.PAYEE_NAME,
               NVL(aps.vendor_id, -222), -- modifed for bug 8405513
               aps.vendor_site_code,
               NVL(iby.supplier_site_id, -222), --modifed for bug 8405513
	       iby.relationship_id
          FROM iby_fd_payments_v iby,
               po_vendors pv,
               ce_bank_acct_uses_all ce,
               ce_bank_accounts ceb,
	       ap_supplier_sites_all aps -- 7673570
          WHERE  iby.inv_payee_party_id = pv.party_id(+) -- 7673570
  	      -- iby.payee_party_id = pv.party_id(+)     -- 7673570
  	 AND  aps.vendor_site_id(+) = iby.supplier_site_id  -- 7673570 --modifed for bug 8405513 to handle Payment Request
          --AND    pv.end_date_active IS NULL          -- bug7166247
          -- commented the above condition and added the below condition for bug 8401306
          /* AND trunc(nvl(pv.end_date_active,sysdate)) >= trunc(sysdate) Commented for bug#8773583 */
         AND nvl(pv.vendor_id,-99) = (select CASE
					  WHEN inv.invoice_type_lookup_code = 'PAYMENT REQUEST' AND SIGN(inv.vendor_id)= -1
					  THEN nvl(pv.vendor_id,-99)	 --bug 8657535. Changed -99 to nvl(pv.vendor_id,-99)
					  ELSE nvl(vendor_id,-99)
					  END --Bug7493630 and Bug 8260736 (8348480)
                                       from ap_invoices_all inv,iby_docs_payable_all idp
                                       where inv.invoice_id=idp.calling_app_doc_unique_ref2
                                       and idp.payment_id=iby.payment_id
                                       and idp.calling_app_doc_unique_ref1=l_checkrun_id
                                       and rownum=1
                                       )     --7196023
          AND    ce.bank_account_id = iby.internal_bank_account_id
          and    ceb.bank_account_id = ce.bank_account_id
          and    iby.org_type = 'OPERATING_UNIT'
          AND    ce.org_id = l_current_org_id
          AND    iby.org_id = l_current_org_id
          AND    iby.completed_pmts_group_id = p_completed_pmts_group_id
          -- Bug 6752984
          AND    iby.payment_service_request_id =
                       (SELECT payment_service_request_id
                          FROM IBY_PAY_SERVICE_REQUESTS
                         WHERE call_app_pay_service_req_code = l_checkrun_name
                           AND CALLING_APP_ID = 200);

          --Bug 5115310
          l_check_count := SQL%ROWCOUNT;
          l_total_check_count := l_check_count + l_total_check_count;

          l_debug_info := 'l_check_count: '||to_char(l_check_count);
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          l_debug_info := 'l_total_check_count: '||to_char(l_total_check_count);
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          l_debug_info := 'l_current_org_id: '||to_char(l_current_org_id);
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;


          l_debug_info := 'create accounting';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          AP_ACCOUNTING_EVENTS_PKG.create_payment_batch_events(
                               p_checkrun_name    => l_checkrun_name,
                               p_completed_pmts_group_id => p_completed_pmts_group_id,
                               p_accounting_date  => l_check_date,
                               p_org_id           => l_current_org_id,
                               p_set_of_books_id  => l_set_of_books_id,
                               p_calling_sequence => l_current_calling_sequence);


          IF l_when_to_account_payment = 'CLEARING ONLY' THEN

              l_debug_info := 'AP_ACCOUNTING_EVENTS_PKG.update_pmt_batch_event_status';
              fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;

             AP_ACCOUNTING_EVENTS_PKG.update_pmt_batch_event_status(
                               p_checkrun_name    => l_checkrun_name,
                               p_org_id           => l_current_org_id,
                               p_completed_pmts_group_id => p_completed_pmts_group_id,
                               p_calling_sequence => l_current_calling_sequence);

          END IF;

		--bug8224330

          l_debug_info := 'UPDATE ap_selected_invoices_all';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          UPDATE ap_selected_invoices_all ASI
          SET    ASI.invoice_payment_id = ap_invoice_payments_s.nextval
          WHERE  ASI.checkrun_id = l_checkrun_id
          /* Bug 6950891. Added TO_CHAR */
          AND  (TO_CHAR(ASI.invoice_id), TO_CHAR(ASI.payment_num)) in
                   (select calling_app_doc_unique_ref2, calling_app_doc_unique_ref3
                    FROM iby_fd_docs_payable_v ibydocs,
                         iby_fd_payments_v ibypmts
                    WHERE ibydocs.payment_id = ibypmts.payment_id
                    and   ibypmts.org_type = 'OPERATING_UNIT'
                    AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
                    AND   ibypmts.org_id = l_current_org_id);


          IF l_perform_awt_flag = 'Y' THEN

             l_debug_info := ' UPDATE ap_awt_temp_distributions_all';
             fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;

            UPDATE ap_awt_temp_distributions_all AATD
            SET    AATD.invoice_payment_id =
                                (SELECT ASI.invoice_payment_id
                                 FROM   ap_selected_invoices_all ASI
                                 WHERE  ASI.checkrun_id = AATD.checkrun_id
                                 AND    ASI.invoice_id    = AATD.invoice_id
                                 AND    ASI.payment_num   = AATD.payment_num
                                 AND    asi.org_id = l_current_org_id)
            WHERE  AATD.checkrun_id = l_checkrun_id
            AND    aatd.org_id = l_current_org_id
            /* Bug 6950891. Added TO_CHAR */
            AND  (TO_CHAR(AATD.invoice_id), TO_CHAR(AATD.payment_num)) in
                   /* Bug 5383066, calling_app_doc_unique_ref3 should be used for payment_num*/
                   (select calling_app_doc_unique_ref2, calling_app_doc_unique_ref3
                    FROM iby_fd_docs_payable_v ibydocs,
                         iby_fd_payments_v ibypmts
                    WHERE ibydocs.payment_id = ibypmts.payment_id
                    and   ibypmts.org_type = 'OPERATING_UNIT'
                    AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
                    AND   ibypmts.org_id = l_current_org_id);


            l_debug_info := 'AP_WITHHOLDING_PKG.AP_WITHHOLD_CONFIRM';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            AP_WITHHOLDING_PKG.AP_WITHHOLD_CONFIRM(l_checkrun_name,
                                                   l_last_updated_by,
                                                   --4863216
                                                   to_number(FND_PROFILE.VALUE('LOGIN_ID')),
                                                   to_number(FND_PROFILE.VALUE('PROGRAM_APPLICATION_ID')),
                                                   to_number(FND_PROFILE.VALUE('PROGRAM_ID')),
                                                   to_number(FND_PROFILE.VALUE('REQUEST_ID')),
                                                   l_checkrun_id,
                                                   p_completed_pmts_group_id,
                                                   l_current_org_id,
                                                   l_check_date);

            l_debug_info := 'DELETE FROM ap_awt_temp_distributions_all';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

           /*  Bug 5383066. Foloowing Delete is not requeired. As call to
               AP_WITHHOLDING_PKG.AP_WITHHOLD_CANCEL cleans up temporary withholding dists.

            WHERE checkrun_name = l_checkrun_name
            AND   org_id = l_current_org_id
            and   checkrun_id = l_checkrun_id
            and   (invoice_id, payment_num) in
                  (select calling_app_doc_unique_ref2, calling_app_doc_unique_ref2
                   FROM iby_fd_docs_payable_v ibydocs
                   where calling_app_doc_unique_ref1 = l_checkrun_id
                   and completed_pmts_group_id = p_completed_pmts_group_id
                   and org_id = l_current_org_id);
           */

          END IF;

          OPEN c_schedule_amounts(l_last_updated_by              --Bug5733731
                                 ,p_completed_pmts_group_id
                                 ,l_current_org_id
                                 ,l_checkrun_name);

            LOOP
              FETCH c_schedule_amounts
              BULK COLLECT INTO
                last_update_date_ps_l,
                last_updated_by_ps_l,
                amount_remaining_ps_l,
                discount_remaining_ps_l,
                payment_status_ps_l,
                --awt_num_ps_l,   --Bug8477014
                awt_num_ps_l, --Bug8752557
                checkrun_id_ps_l,
                invoice_id_ps_l,
                payment_num_ps_l
                LIMIT 1000;

                l_debug_info := 'UPDATE ap_payment_schedules_all';
                fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;


                FORALL i IN 1..invoice_id_ps_l.COUNT

                  UPDATE ap_payment_schedules_all
                  SET    last_update_date  = last_update_date_ps_l(i)
                        ,last_updated_by   = last_updated_by_ps_l(i)
                        -- Modified by epajaril, need to consider the AWT
                        --Bug8477014: Undoing changes done for bug6836199
                        --Bug8752557: Undoing changes done here for bug8477014
			                   --,amount_remaining  = amount_remaining_ps_l(i)
                        ,amount_remaining  = (amount_remaining_ps_l(i) -
                                              nvl(awt_num_ps_l(i),0))  --bug:7523065 --Bug8752557
                        ,discount_amount_remaining = discount_remaining_ps_l(i)
                        --,payment_status_flag = payment_status_ps_l(i)
                        , payment_status_flag = DECODE((amount_remaining_ps_l(i)-nvl(awt_num_ps_l(i),0)), 0,'Y', 'P')--Bug8759364
                        ,checkrun_id       = checkrun_id_ps_l(i)
                   WHERE invoice_id = invoice_id_ps_l(i)
                   AND   payment_num = payment_num_ps_l(i);

              EXIT WHEN c_schedule_amounts%NOTFOUND;
            END LOOP;

          CLOSE c_schedule_amounts;

           -- Bug 5658623. Cursor Processing for Performance
          l_debug_info := 'Opening Cursor for updating invoices via Forall';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          OPEN c_invoice_amounts(l_last_updated_by
                                 ,p_completed_pmts_group_id
                                 ,l_current_org_id
                                 ,l_checkrun_name);


            LOOP
              FETCH c_invoice_amounts
              BULK COLLECT INTO
                last_update_date_inv_l,
                last_updated_by_inv_l,
                amount_paid_inv_l,
                discount_taken_inv_l,
                payment_status_inv_l,
                invoice_id_inv_l
                LIMIT 1000;

                l_debug_info := 'UPDATE ap_invoices_all';
                fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

                FORALL i IN 1..invoice_id_inv_l.COUNT
                  UPDATE ap_invoices_all
                  SET    last_update_date  = last_update_date_inv_l(i)
                        ,last_updated_by   = last_updated_by_inv_l(i)
                        ,amount_paid       = nvl(amount_paid,0) + amount_paid_inv_l(i)
                        ,discount_amount_taken = nvl(discount_amount_taken,0) + discount_taken_inv_l(i)
                        ,payment_status_flag = payment_status_inv_l(i)
                   WHERE invoice_id = invoice_id_inv_l(i);

              EXIT WHEN c_invoice_amounts%NOTFOUND;
            END LOOP;

          CLOSE c_invoice_amounts;                     --Bug5733731



          l_debug_info := 'insert into ap_invoice_payments_all';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          INSERT INTO ap_invoice_payments_all(
              INVOICE_PAYMENT_ID,
              INVOICE_ID,
              PAYMENT_NUM,
              CHECK_ID,
              AMOUNT,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              ELECTRONIC_TRANSFER_ID,
              SET_OF_BOOKS_ID,
              ACCTS_PAY_CODE_COMBINATION_ID,
              ACCOUNTING_DATE,
              PERIOD_NAME,
              POSTED_FLAG,
              ACCRUAL_POSTED_FLAG,
              CASH_POSTED_FLAG,
              DISCOUNT_TAKEN,
              DISCOUNT_LOST,
              EXCHANGE_RATE,
              EXCHANGE_RATE_TYPE,
              GAIN_CODE_COMBINATION_ID,
              LOSS_CODE_COMBINATION_ID,
              ASSET_CODE_COMBINATION_ID,
              INVOICE_BASE_AMOUNT,
              PAYMENT_BASE_AMOUNT,
              EXCHANGE_DATE,
              BANK_ACCOUNT_NUM,
         --     IBAN_NUMBER, --Bug 2633878
              BANK_NUM,
              BANK_ACCOUNT_TYPE,
              EXTERNAL_BANK_ACCOUNT_ID,
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
              ATTRIBUTE15,
              ATTRIBUTE_CATEGORY, -- Bug 4087878
              FUTURE_PAY_CODE_COMBINATION_ID,
              FUTURE_PAY_POSTED_FLAG,
              ACCOUNTING_EVENT_ID,
              CREATION_DATE,
              CREATED_BY,
              ORG_ID, --4945922
              INVOICING_PARTY_ID, /*4739343, added 3rd party columns*/
              INVOICING_PARTY_SITE_ID,
              INVOICING_VENDOR_SITE_ID,  -- Bug 5658623
	      -- added below columns for 7673570
              REMIT_TO_SUPPLIER_NAME,
              REMIT_TO_SUPPLIER_ID,
              REMIT_TO_SUPPLIER_SITE,
              REMIT_TO_SUPPLIER_SITE_ID,
	      assets_addition_flag) -- bug 8741899: add
          SELECT /*+ Leading(xeg) index(ac ap_checks_u1) */
               SI.invoice_payment_id,
              SI.invoice_id,
              SI.payment_num,
              ac.check_id,
              ibydocs.payment_amount,
              sysdate,
              l_last_updated_by,
              NULL,
              l_set_of_books_id,
              null,
              trunc(l_check_date),    --bug6602676
              l_period_name,
              'N',
              'N',
              'N',
              DECODE(ibydocs.payment_curr_discount_taken,0,'',ibydocs.payment_curr_discount_taken),
              DECODE(ps.invoice_id, null, 0,
                 DECODE(ps.gross_amount, 0, 0,
                      (DECODE(FORE.minimum_accountable_unit,NULL,
                              ROUND((((ibydocs.payment_amount+ibydocs.payment_curr_discount_taken)/
                                      DECODE(ps.gross_amount,0,1,ps.gross_amount)) *
                                     (greatest (nvl(PS.discount_amount_available,0),
                                                nvl(PS.second_disc_amt_available,0),
                                                nvl(PS.third_disc_amt_available,0)))),
                                    FORE.precision),
                              ROUND((((ibydocs.payment_amount+ibydocs.payment_curr_discount_taken)/
                                      DECODE(ps.gross_amount,0,1,ps.gross_amount)) *
                                     (greatest (nvl(PS.discount_amount_available,0),
                                                nvl(PS.second_disc_amt_available,0),
                                                nvl(PS.third_disc_amt_available,0))))
                                    / FORE.minimum_accountable_unit)
                              * FORE.minimum_accountable_unit)
                       - ibydocs.payment_curr_discount_taken))),
              ac.exchange_rate,
              ac.exchange_rate_type,
              decode(ibydocs.payment_currency_code, l_base_currency_code,null,cegl.gain_code_combination_id),
              decode(ibydocs.payment_currency_code, l_base_currency_code,null,cegl.loss_code_combination_id),
              cegl.ap_asset_ccid,
              decode(AI.invoice_currency_code, l_base_currency_code,
                     decode(ibydocs.payment_currency_code, l_base_currency_code,
                           null,
                           decode(gl_currency_api.convert_amount_sql(
                                    ibydocs.payment_currency_code,
                                    l_base_currency_code,
                                    AI.payment_cross_rate_date,
                                    AI.payment_cross_rate_type,
                                    abs(ibydocs.payment_amount)),
                                    -1, null, -2, null,
                                    -1, null, -2, null,
                                  gl_currency_api.convert_amount_sql(
                                    ibydocs.payment_currency_code,
                                    l_base_currency_code,
                                    AI.payment_cross_rate_date,
                                    AI.payment_cross_rate_type,
                                    ibydocs.payment_amount))),
                     decode(SI.invoice_exchange_rate, null,
                            null,
                            decode(l_base_currency_mac,NULL,
                                       ROUND((ibydocs.payment_amount * SI.invoice_exchange_rate)
                                         / SI.payment_cross_rate, l_base_currency_precision),
                                       ROUND(((ibydocs.payment_amount * SI.invoice_exchange_rate)
                                          / SI.payment_cross_rate)
                                        / l_base_currency_mac)
                                        * l_base_currency_mac))),  --invoice_base_amount
              decode(ibydocs.payment_currency_code, l_base_currency_code,
                     decode(AI.invoice_currency_code, l_base_currency_code,
                              null,
                              ibydocs.payment_amount),
                     --bug 8899917 take ex rate from check
                     decode(ac.exchange_rate, NULL, NULL,
                           decode(l_base_currency_mac, NULL,
                                ROUND((ibydocs.payment_amount * ac.exchange_rate)
                                     ,l_base_currency_precision),
                                ROUND((ibydocs.payment_amount * ac.exchange_rate)
                                     / l_base_currency_mac)
                                     * l_base_currency_mac))), -- payment_base_amount
              l_check_date,
              SI.bank_account_num,
        --      SI.iban_number,
              SI.bank_num,
              SI.bank_account_type,
              SI.external_bank_account_id,
              SI.attribute1,
              SI.attribute2,
              SI.attribute3,
              SI.attribute4,
              SI.attribute5,
              SI.attribute6,
              SI.attribute7,
              SI.attribute8,
              SI.attribute9,
              SI.attribute10,
              SI.attribute11,
              SI.attribute12,
              SI.attribute13,
              SI.attribute14,
              SI.attribute15,
              SI.attribute_category,
              cegl.future_dated_payment_ccid,
              'N',
              XEG.event_id,
              sysdate,
              l_last_updated_by,
              ai.org_id, --4945922
              ibydocs.beneficiary_party,
              decode(ibydocs.beneficiary_party, null, null, ai.party_site_id),
              decode(ibydocs.beneficiary_party, null, null, ai.vendor_site_id),
	      -- added below columns for 7673570
              /* Bug 9074840 replaced following with ap_checks_all values
              ibypmts.PAYEE_NAME,
              NVL(aps.vendor_id, -222), --modifed for bug 8405513
              aps.vendor_site_code,
              NVL(ibypmts.supplier_site_id, -222), --modifed for bug 8405513
              */
              ac.remit_to_supplier_name,
              ac.remit_to_supplier_id,
              ac.remit_to_supplier_site,
              ac.remit_to_supplier_site_id,
	      'U' -- bug 8741899: add
          FROM
              iby_fd_payments_v ibypmts,
              iby_fd_docs_payable_v ibydocs,
              ap_selected_invoices_all SI,
              fnd_currencies FORE,
              ap_payment_schedules_all PS,
              ap_invoices_all AI,
              ap_checks_all ac,
	      --ap_supplier_sites_all aps, -- bug 7673570 --Removed by bug 9074840
              --ce_bank_acct_uses_all ceu, --Removed by bug 9074840
              ce_gl_accounts_ccid cegl,
              XLA_EVENTS_INT_GT xeg
         /* Bug 6950891. Added TO_CHAR */
         WHERE  ibydocs.calling_app_doc_unique_ref1 = TO_CHAR(si.checkrun_id)
          AND   ibydocs.calling_app_doc_unique_ref2 = TO_CHAR(si.invoice_id)
          AND   ibydocs.calling_app_doc_unique_ref3 = TO_CHAR(si.payment_num)
          AND   ibypmts.payment_id = ibydocs.payment_id
          AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
          AND   ibypmts.org_id = l_current_org_id
          and   ibypmts.org_type = 'OPERATING_UNIT'
          /* bug 9074840
          AND   aps.vendor_site_id(+) = ibypmts.supplier_site_id -- bug 7673570 --modifed for bug 8405513
          */
          AND   SI.checkrun_name = l_checkrun_name
          AND   ac.payment_id = ibypmts.payment_id
          AND   ac.completed_pmts_group_id = p_completed_pmts_group_id
          AND   ibypmts.payment_currency_code = FORE.currency_code
          AND   PS.invoice_id(+) = SI.invoice_id
          AND   PS.payment_num(+) = SI.payment_num
          AND   AI.invoice_id = SI.invoice_id
          /* bug 9074840
          AND   ceu.bank_account_id = ibypmts.internal_bank_account_id
          AND   ceu.org_id = l_current_org_id
          */
          AND   ac.ce_bank_acct_use_id = cegl.bank_acct_use_id --bug 9074840
          AND   xeg.application_id = 200
          AND   XEG.ENTITY_CODE = 'AP_PAYMENTS'
          AND   XEG.SOURCE_ID_INT_1 = ac.check_id ;

           --Bug 5115310
          l_docs_count := SQL%ROWCOUNT;

          l_total_docs_count := l_docs_count + l_total_docs_count;


          l_debug_info := 'Call product specific subscription API for Payment Event';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);

          -- Added for Payment Request
          OPEN c_subscribed_payments;
          LOOP

            FETCH c_subscribed_payments INTO l_check_id, l_application_id;
            EXIT  WHEN c_subscribed_payments%NOTFOUND;

            l_debug_info := 'AP_CHECKS_PKG.Subscribe_To_Payment_Event';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            AP_CHECKS_PKG.Subscribe_To_Payment_Event(
                          P_Event_Type       => 'PAYMENT_CREATED',
                          P_Check_ID         => l_check_id,
                          P_Application_ID   => l_application_id,
                          P_Return_Status    => l_return_status,
                          P_Msg_Count        => l_msg_count,
                          P_Msg_Data         => l_msg_data,
                          P_Calling_Sequence => l_current_calling_sequence);


            IF L_Return_Status <> 'S' THEN
               l_debug_info := 'Error during subscribing the payment event';
               fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
               RAISE SUBSCRIBE_EXCEPTION;
            END IF;

          END LOOP;
          CLOSE c_subscribed_payments;


          l_debug_info := 'AP_DBI_PKG.Insert_Payment_Confirm_DBI';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
          AP_DBI_PKG.Insert_Payment_Confirm_DBI(
                        p_checkrun_name      => l_checkrun_name,
                        p_base_currency_code => l_base_currency_code,
                        p_key_table          => 'AP_INVOICE_PAYMENTS_ALL',
                        p_calling_sequence   => l_current_calling_sequence  );

          l_debug_info := 'AP_Accounting_Events_Pkg.Batch_Update_Payment_Info';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
          AP_Accounting_Events_Pkg.Batch_Update_Payment_Info(
                                       p_checkrun_name  => l_checkrun_name,
                                       p_completed_pmts_group_id => p_completed_pmts_group_id,
                                       p_org_id => l_current_org_id,
                                       p_calling_sequence=>l_current_calling_sequence);

          -- Bug 5658623. Cursor Processing for Performance
          l_debug_info := 'Opening Cursor for updating payment schedules via Forall';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

       /*   OPEN c_schedule_amounts(l_last_updated_by     --Bug5733731
                                 ,p_completed_pmts_group_id
                                 ,l_current_org_id
                                 ,l_checkrun_name);

            LOOP
              FETCH c_schedule_amounts
              BULK COLLECT INTO
                last_update_date_ps_l,
                last_updated_by_ps_l,
                amount_remaining_ps_l,
                discount_remaining_ps_l,
                payment_status_ps_l,
                checkrun_id_ps_l,
                invoice_id_ps_l,
                payment_num_ps_l
                LIMIT 1000;

                l_debug_info := 'UPDATE ap_payment_schedules_all';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

                FORALL i IN 1..invoice_id_ps_l.COUNT
                  UPDATE ap_payment_schedules_all
                  SET    last_update_date  = last_update_date_ps_l(i)
                        ,last_updated_by   = last_updated_by_ps_l(i)
                        ,amount_remaining  = amount_remaining_ps_l(i)
                        ,discount_amount_remaining = discount_remaining_ps_l(i)
                        ,payment_status_flag = payment_status_ps_l(i)
                        ,checkrun_id       = checkrun_id_ps_l(i)
                   WHERE invoice_id = invoice_id_ps_l(i)
                   AND   payment_num = payment_num_ps_l(i);

              EXIT WHEN c_schedule_amounts%NOTFOUND;
            END LOOP;

          CLOSE c_schedule_amounts;

           -- Bug 5658623. Cursor Processing for Performance
          l_debug_info := 'Opening Cursor for updating invoices via Forall';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          OPEN c_invoice_amounts(l_last_updated_by
                                 ,p_completed_pmts_group_id
                                 ,l_current_org_id
                                 ,l_checkrun_name);


            LOOP
              FETCH c_invoice_amounts
              BULK COLLECT INTO
                last_update_date_inv_l,
                last_updated_by_inv_l,
                amount_paid_inv_l,
                discount_taken_inv_l,
                payment_status_inv_l,
                invoice_id_inv_l
                LIMIT 1000;

                l_debug_info := 'UPDATE ap_invoices_all';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

                FORALL i IN 1..invoice_id_inv_l.COUNT
                  UPDATE ap_invoices_all
                  SET    last_update_date  = last_update_date_inv_l(i)
                        ,last_updated_by   = last_updated_by_inv_l(i)
                        ,amount_paid       = nvl(amount_paid,0) + amount_paid_inv_l(i)
                        ,discount_amount_taken = nvl(discount_amount_taken,0) + discount_taken_inv_l(i)
                        ,payment_status_flag = payment_status_inv_l(i)
                   WHERE invoice_id = invoice_id_inv_l(i);

              EXIT WHEN c_invoice_amounts%NOTFOUND;
            END LOOP;

          CLOSE c_invoice_amounts; Bug5733731 */

        /*  UPDATE ap_payment_schedules_all ps1
          SET    (last_update_date,
                  last_updated_by,
                  amount_remaining,
                  discount_amount_remaining,
                  payment_status_flag,
                  checkrun_id) =
                 (SELECT sysdate,
                         l_last_updated_by,
                         SI1.amount_remaining - ibydocs.payment_amount -  nvl(ibydocs.payment_curr_discount_taken,0),
                         0,
                         decode(SI1.amount_remaining - ibydocs.payment_amount -  nvl(ibydocs.payment_curr_discount_taken,0), 0,
                                'Y', 'P'),
                         null --set checkrun_id to null
                  FROM  ap_selected_invoices_all SI1,
                        iby_fd_docs_payable_v ibydocs
                  WHERE checkrun_name = l_checkrun_name
                  AND   SI1.payment_num = ps1.payment_num
                  AND   SI1.invoice_id = ps1.invoice_id
                  AND   ibydocs.calling_app_doc_unique_ref1 = to_char(si1.checkrun_id)
                  AND   ibydocs.calling_app_doc_unique_ref2 = to_char(si1.invoice_id)
                  AND   ibydocs.calling_app_doc_unique_ref3 = to_char(si1.payment_num))
          WHERE (ps1.invoice_id, ps1.payment_num) in
                     (SELECT SI3.invoice_id, SI3.payment_num
                      FROM   ap_selected_invoices_all SI3,
                             iby_fd_payments_v ibypmts,
                             iby_fd_docs_payable_v ibydocs,
                             ap_invoices_all AI
                      WHERE  SI3.checkrun_name = l_checkrun_name
                      AND    ibydocs.calling_app_doc_unique_ref1 = to_char(si3.checkrun_id)
                      AND    ibydocs.calling_app_doc_unique_ref2 = to_char(si3.invoice_id)
                      AND    ibydocs.calling_app_doc_unique_ref3 = to_char(si3.payment_num)
                      AND    ibypmts.payment_id = ibydocs.payment_id
                      AND    ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
                      AND    ibypmts.org_id = l_current_org_id
                      and    ibypmts.org_type = 'OPERATING_UNIT'
                      AND    AI.invoice_id = SI3.invoice_id
                      AND    AI.invoice_type_lookup_code <> 'INTEREST');


          l_debug_info := 'UPDATE ap_invoices_all';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;


--bug5020577
--Modified the sql to prevent MJC.
          UPDATE ap_invoices_all inv1
          SET    (last_update_date,
                  last_updated_by,
                  amount_paid,
                  discount_amount_taken,
                  payment_status_flag)=
                 (SELECT sysdate,
                         l_last_updated_by,
                         nvl(inv1.amount_paid,0) + sum(ibydocs.payment_amount),
                         nvl(inv1.discount_amount_taken,0) + nvl(sum(ibydocs.payment_curr_discount_taken),0),
                         AP_INVOICES_UTILITY_PKG.get_payment_status( inv1.invoice_id )
                  FROM   iby_fd_docs_payable_v ibydocs,
                         iby_fd_payments_v ibypmts
                  WHERE  ibypmts.org_type = 'OPERATING_UNIT'
                  AND    ibypmts.payment_id = ibydocs.payment_id
                  AND    ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
                  AND    ibypmts.org_id = l_current_org_id
                  and
		  (ibydocs.calling_app_doc_unique_ref1,ibydocs.calling_app_doc_unique_ref2,ibydocs.calling_app_doc_unique_ref3)
	           in (select si.checkrun_id,si.invoice_id,si.payment_num from
		       ap_selected_invoices_all si where si.invoice_id=inv1.invoice_id
	               and checkrun_name = l_checkrun_name)
		  )
          WHERE invoice_id IN
                      (SELECT ibydocs.calling_app_doc_unique_ref2
                       FROM  iby_fd_docs_payable_v ibydocs,
                             iby_fd_payments_v ibypmts
                       WHERE ibypmts.payment_id = ibydocs.payment_id
                       AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
                       and   ibypmts.org_type = 'OPERATING_UNIT'
                       AND   ibypmts.org_id = l_current_org_id)
          AND   invoice_type_lookup_code <> 'INTEREST';
      */
          -- Bug 5512197. Adding the following for fnd logging
          l_debug_info := 'Sequential Numbering Option: '||l_seq_num_profile;
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          IF l_seq_num_profile IN ('A','P') then

             l_debug_info := 'assign_sequences';
             fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
            assign_sequences(p_completed_pmts_group_id,
                             l_set_of_books_id,
                             l_seq_num_profile,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             l_auto_calculate_interest_flag,
                             l_interest_invoice_count,
                             l_check_date,
                             l_current_org_id);

            IF (x_return_status =  FND_API.G_RET_STS_ERROR) THEN
              RETURN;
            END IF;

          END IF;


          IF l_seq_num_profile NOT IN ('A','P') and l_first_voucher_number is not null then
              l_debug_info := 'assign_vouchers';
              fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
            assign_vouchers(p_completed_pmts_group_id,
                            l_checkrun_id,
                            l_first_voucher_number,
                            l_current_org_id);
          END IF;


          if l_perform_awt_flag = 'Y' then

            l_debug_info := 'AP_WITHHOLDING_PKG.AP_WITHHOLD_CANCEL';
            fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            AP_WITHHOLDING_PKG.AP_WITHHOLD_CANCEL(l_checkrun_name,
                             l_last_updated_by,
                             --4863216
                             to_number(FND_GLOBAL.USER_ID),--Bug6489464
                             --to_number(FND_PROFILE.VALUE('LOGIN_ID')),
                             to_number(FND_PROFILE.VALUE('PROGRAM_APPLICATION_ID')),
                             to_number(FND_PROFILE.VALUE('PROGRAM_ID')),
                             to_number(FND_PROFILE.VALUE('REQUEST_ID')),
                             l_checkrun_id,
                             p_completed_pmts_group_id,
                             l_current_org_id);

          END if;

          l_debug_info := 'AP_PAYMENT_EVENT_PKG.raise_payment_batch_events';
          fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

          /* Added for Bug#9459810 Start */
          l_wf_event_exists :=0;
          BEGIN
            SELECT 1
              INTO l_wf_event_exists
              FROM wf_events we
             WHERE owner_tag = 'SQLAP'
               AND name   = 'oracle.apps.ap.payment'
               AND status = 'ENABLED';
          EXCEPTION
            WHEN others THEN
            l_wf_event_exists:=0;
          END;

          IF l_wf_event_exists=1 THEN

            AP_PAYMENT_EVENT_PKG.raise_payment_batch_events(
                         p_checkrun_name           => l_checkrun_name,
                         p_checkrun_id             => l_checkrun_id,
                         p_completed_pmts_group_id => p_completed_pmts_group_id,
                         p_org_id                  => l_current_org_id);

          END IF;
          /* Added for Bug#9459810 End  */


           l_debug_info := 'DELETE FROM ap_selected_invoices_all';
           fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;

          DELETE FROM ap_selected_invoices_all
          WHERE checkrun_id = l_checkrun_id
          /* Bug 6950891. Added TO_CHAR */
          and (TO_CHAR(invoice_id), TO_CHAR(payment_num)) in
            (select ibydocs.calling_app_doc_unique_ref2,
                    ibydocs.calling_app_doc_unique_ref3
             from iby_fd_docs_payable_v ibydocs,
                  iby_fd_payments_v ibypmts
             where ibypmts.payment_id = ibydocs.payment_id
             and   ibypmts.org_type = 'OPERATING_UNIT'
             AND   ibypmts.completed_pmts_group_id = p_completed_pmts_group_id
             AND   ibypmts.org_id = l_current_org_id);


      END LOOP;  --loop for org_id's
      close c_relevant_orgs;

      l_debug_info := 'DELETE FROM ap_unselected_invoices_all';
      fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

      DELETE FROM ap_unselected_invoices_all
      WHERE checkrun_id = l_checkrun_id;

  END LOOP; -- loop for checkrun_id


  SELECT COUNT(*)
    INTO l_iby_check_count
    FROM iby_fd_payments_v
   WHERE completed_pmts_group_id =  p_completed_pmts_group_id;

   SELECT COUNT(*)
    INTO l_iby_docs_count
    FROM iby_fd_docs_payable_v
   WHERE completed_pmts_group_id =  p_completed_pmts_group_id;

   l_debug_info := '******AP-IBY COUNTS****************';
   fnd_file.put_line(FND_FILE.LOG,l_debug_info||' - '||systimestamp);
   fnd_file.put_line(FND_FILE.LOG,'IBY CHECK COUNT: '||TO_CHAR(l_iby_check_count)||' - '||systimestamp);
   fnd_file.put_line(FND_FILE.LOG,'IBY DOC COUNT: '||TO_CHAR(l_iby_docs_count)||' - '||systimestamp);
   fnd_file.put_line(FND_FILE.LOG,'AP CHECK COUNT: '||TO_CHAR(l_total_check_count)||' - '||systimestamp);
   fnd_file.put_line(FND_FILE.LOG,'AP DOCS COUNT: '||TO_CHAR(l_total_docs_count)||' - '||systimestamp);


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           l_debug_info := 'IBY CHECK COUNT: '||TO_CHAR(l_iby_check_count);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           l_debug_info := 'IBY DOC COUNT: '||TO_CHAR(l_iby_docs_count);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           l_debug_info := 'AP CHECK COUNT: '||TO_CHAR(l_total_check_count);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           l_debug_info := 'AP DOCS COUNT: '||TO_CHAR(l_total_docs_count);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);

   END IF;

   --Bug 5115363
   IF (l_total_check_count <> l_iby_check_count) OR
      (l_total_docs_count <> l_iby_docs_count) THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.set_name('SQLAP', 'AP_IBY_PMT_MISMATCH');

      --Bug 9074840 Add additional debug queries

      --As this is an error condition it will be written to the concurrent log
      --regardless of the runtime fnd log level.
      FND_FILE.PUT_LINE(FND_FILE.LOG, G_MODULE_NAME);
      l_debug_info := fnd_message.get;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_debug_info);

      OPEN c_prob_iby_payments;
      FETCH c_prob_iby_payments BULK COLLECT INTO  l_prob_pmt_list;
      CLOSE c_prob_iby_payments;
      print_prob_pmt_detail(l_prob_pmt_list, 'AP_IBY_PMT_MISMATCH_PMT');

      OPEN c_prob_iby_docs;
      FETCH c_prob_iby_docs BULK COLLECT INTO  l_prob_pmt_list;
      CLOSE c_prob_iby_docs;
      print_prob_pmt_detail(l_prob_pmt_list, 'AP_IBY_PMT_MISMATCH_DOC');

      OPEN c_prob_checks;
      FETCH c_prob_checks BULK COLLECT INTO  l_prob_pmt_list;
      CLOSE c_prob_checks;
      print_prob_pmt_detail(l_prob_pmt_list, 'AP_IBY_PMT_MISMATCH_CHK');

      OPEN c_prob_inv_pmts;
      FETCH c_prob_inv_pmts BULK COLLECT INTO  l_prob_pmt_list;
      CLOSE c_prob_inv_pmts;
      print_prob_pmt_detail(l_prob_pmt_list, 'AP_IBY_PMT_MISMATCH_INV');

      l_debug_info := '*****************************************************************************';
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_debug_info);
      FND_FILE.PUT_LINE(FND_FILE.LOG, G_MODULE_NAME);
      /* no longer necessary as the messages are only written to the log
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET(
         p_count => x_msg_count,
         p_data  => x_msg_data
         );
      */
      --End Bug 9074840

   ELSE

      x_return_status := FND_API.G_RET_STS_SUCCESS;

   END IF;



EXCEPTION

  WHEN SUBSCRIBE_EXCEPTION THEN

     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',l_msg_data);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
              FND_MESSAGE.set_TOKEN('PARAMETERS',
                      'Complted Payments Group id  = '  || to_char(p_completed_pmts_group_id));
              FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;



END payments_completed;





PROCEDURE payments_cleared
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2,
       p_commit                 IN  VARCHAR2,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2,
       p_group                  IN  NUMBER)IS
BEGIN
NULL;
END;

PROCEDURE payments_uncleared
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2,
       p_commit                 IN  VARCHAR2,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2,
       p_group                  IN  NUMBER)IS
BEGIN
NULL;
END;

PROCEDURE Payment_Voided
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
       p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
       p_payment_id             IN  NUMBER,
       p_void_date              IN  DATE,
--       p_accounting_date        IN  DATE,  /* Bug 4775938 */
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2) IS

    l_api_name                  CONSTANT VARCHAR2(30)   := 'Payments_Voided';
    l_api_version               CONSTANT NUMBER         := 1.0;
    l_debug_info                VARCHAR2(2000);
BEGIN

    l_debug_info := 'Creating Savepoint';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

       -- Standard Start of API savepoint
    SAVEPOINT   Payments_Voided_PUB;

    l_debug_info := 'Checking API Compatibility';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (        l_api_version,
                                                p_api_version,
                                                l_api_name,
                                                G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_debug_info := 'Calling AP Void Pkg.Iby_Void_Check';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Ap_Void_Pkg.Iby_Void_Check
       (p_api_version       =>  1.0,
        p_init_msg_list     =>  p_init_msg_list,
        p_commit            =>  p_commit,
        p_payment_id        =>  p_payment_id,
        p_void_date         =>  p_void_date,
        x_return_status     =>  x_return_status,
        x_msg_count         =>  x_msg_count,
        x_msg_data          =>  x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      l_debug_info := 'AP Void Pkg.Iby_Void_Check returns error';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      ROLLBACK TO Payments_Voided_PUB; --4945922
    ELSE
      l_debug_info := 'AP Void Pkg.Iby_Void_Check returns success';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      COMMIT WORK;
    END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Payments_Voided_PUB; --4945922
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Payments_Voided_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN OTHERS THEN
    ROLLBACK TO Payments_Voided_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
    END IF;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

END Payment_Voided;

PROCEDURE ap_JapanBankChargeHook(
                p_api_version    IN  NUMBER,
                p_init_msg_list  IN  VARCHAR2,
                p_commit         IN  VARCHAR2,
                x_return_status  OUT nocopy VARCHAR2,
                x_msg_count      OUT nocopy NUMBER,
                x_msg_data       OUT nocopy VARCHAR2)
 is
    l_api_version               CONSTANT NUMBER         := 1.0;
    l_debug_info                VARCHAR2(2000);
    l_api_name                  CONSTANT VARCHAR2(100)  := 'AP_JAPANBANKCHARGEHOOK';
BEGIN

    l_debug_info := 'Creating Savepoint';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'Checking API Compatibility';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (        l_api_version,
                                                p_api_version,
                                                l_api_name,
                                                G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_debug_info := 'Calling ap_bank_charge_pkg.ap_JapanBankChargeHook';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    ap_bank_charge_pkg.ap_JapanBankChargeHook(
                p_api_version    ,
                p_init_msg_list  ,
                p_commit         ,
                x_return_status  ,
                x_msg_count      ,
                x_msg_data       );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
    END IF;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

end  ap_JapanBankChargeHook;

/* Bug 6756063: Added the following procedures to sync up the status
   of the Payment in Payables and IBY when Stop has been initiated and released. */

PROCEDURE Payment_Stop_Initiated
( p_payment_id             IN  NUMBER,
  p_stopped_date           IN  DATE, -- Bug 6957071
  p_stopped_by             IN  NUMBER,  -- Bug 6957071
  x_return_status          OUT nocopy VARCHAR2,
  x_msg_count              OUT nocopy NUMBER,
  x_msg_data               OUT nocopy VARCHAR2) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Payment_Status_Updated';
  l_api_version               CONSTANT NUMBER         := 1.0;
  l_debug_info                VARCHAR2(2000);

BEGIN

    l_debug_info := 'In Payment_Stop_Initiated';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'Payment_id from IBY API: '||p_payment_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    update ap_checks_all
       set status_lookup_code = 'STOP INITIATED',
           stopped_date= p_stopped_date,   -- Bug 6957071
           stopped_by= p_stopped_by        -- Bug 6957071
     where payment_id = p_payment_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_count := 1;
    x_msg_data := substr(SQLERRM,1,25);

END Payment_Stop_Initiated;


PROCEDURE Payment_Stop_Released
( p_payment_id             IN  NUMBER,
  x_return_status          OUT nocopy VARCHAR2,
  x_msg_count              OUT nocopy NUMBER,
  x_msg_data               OUT nocopy VARCHAR2) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Payment_Status_Updated';
  l_api_version               CONSTANT NUMBER         := 1.0;
  l_debug_info                VARCHAR2(2000);

BEGIN

    l_debug_info := 'In Payment_Stop_Released';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'Payment_id from IBY API: '||p_payment_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    update ap_checks_all
       set status_lookup_code = 'NEGOTIABLE',
	   stopped_date=null,  -- Bug 6957071
           stopped_by=null  -- Bug 6957071
     where payment_id = p_payment_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_count := 1;
    x_msg_data := substr(SQLERRM,1,25);

END Payment_Stop_Released;

/* End of fix for bug 6756063 */

PROCEDURE void_payment_allowed
     ( p_api_version            IN  NUMBER,
       p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
       p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
       p_payment_id             IN  NUMBER,
       x_return_flag            OUT nocopy VARCHAR2,
       x_return_status          OUT nocopy VARCHAR2,
       x_msg_count              OUT nocopy NUMBER,
       x_msg_data               OUT nocopy VARCHAR2) IS

    l_api_name                  CONSTANT VARCHAR2(30)   := 'void_payment_allowed';
    l_api_version               CONSTANT NUMBER         := 1.0;
    l_debug_info                VARCHAR2(2000);
    l_payment_status            VARCHAR2(30);
    l_prepay_app_exists         NUMBER;
    l_check_prepay_unapply      VARCHAR2(1) := 'N';


BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
--  Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
      SELECT status_lookup_code
      INTO   l_payment_status
      FROM   AP_CHECKS_ALL
      WHERE  payment_id = p_payment_id;

  EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_payment_status := null;
  END;

  --  Initialize the return flag to N
   x_return_flag := 'N';

  if(l_payment_status in ('ISSUED','NEGOTIABLE','STOP INITIATED')) then

   SELECT COUNT(*) INTO l_prepay_app_exists
       FROM ap_checks_all ac,
       ap_invoice_payments_all aip,
       ap_invoice_distributions_all aid,
       ap_invoices_all ai
      WHERE ac.payment_id = p_payment_id
      AND ac.check_id = aip.check_id
      AND aip.invoice_id = ai.invoice_id
      AND ai.invoice_id = aid.invoice_id
      AND ai.invoice_type_lookup_code = 'PREPAYMENT'
      AND nvl(aid.prepay_amount_remaining,aid.amount) <> aid.amount
      AND nvl(aid.reversal_flag,   'N') <> 'Y'
      AND rownum = 1;

       if (l_prepay_app_exists = 0) then

        -- bug9441420, we would not allow cancellation if there
        -- the payment has been made for a prepayment invoice
        -- which has been applied and unapplied, applied has been
        -- accounted, but unapplication is not accounted
        --
        BEGIN

        SELECT 'Y'
          INTO l_check_prepay_unapply
          FROM dual
         WHERE EXISTS
               (SELECT 1
                  FROM ap_invoice_distributions_all aid_prepay,
                       ap_checks_all ac,
                       ap_invoice_payments_all aip,
                       ap_invoices_all ai_prepay,
                       ap_invoice_distributions_all aid,
                       ap_invoice_distributions_all aidp
                 WHERE aip.check_id = ac.check_id
                   AND ac.payment_id = p_payment_id
                   AND aip.invoice_id = ai_prepay.invoice_id
                   AND ai_prepay.invoice_type_lookup_code = 'PREPAYMENT'
                   AND aid_prepay.invoice_id = ai_prepay.invoice_id
                   AND aid_prepay.invoice_distribution_id = aid.prepay_distribution_id
                   AND aid.prepay_distribution_id IS NOT NULL
                   AND aid.parent_reversal_id IS NOT NULL
                   AND aid.amount > 0
                   AND nvl(aid.posted_flag, 'N') = 'N'
                   AND aid.invoice_id = aidp.invoice_id
                   AND aid.invoice_line_number = aidp.invoice_line_number
                   AND aid.parent_reversal_id  = aidp.invoice_distribution_id
                   AND aid.prepay_distribution_id = aidp.prepay_distribution_id
                   AND nvl(aidp.posted_flag, 'N') = 'Y');

        EXCEPTION
	  WHEN OTHERS THEN
	    NULL;
        END;

        if l_check_prepay_unapply = 'N' then
          x_return_flag := 'Y';
        end if;

       end if ;

    end if ;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
    END IF;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
END void_payment_allowed;

END AP_PMT_CALLOUT_PKG;

/
