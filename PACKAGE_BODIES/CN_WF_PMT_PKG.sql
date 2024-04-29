--------------------------------------------------------
--  DDL for Package Body CN_WF_PMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_WF_PMT_PKG" as
-- $Header: cnwfpmtb.pls 120.4 2006/02/10 00:06:42 fmburu ship $ --CREATE OR REPLACE
--
-- Procedure
--  StartProcess
--
-- Description

--      Initiate workflow
-- IN
--   RequestorUsername  -Requestor Username from callling application
--   ProcessOwner - Process Owner Username from calling application
--   Workflowprocess    - Workflow process to run.
--
      G_last_updated_by       NUMBER  := fnd_global.user_id;
      G_last_update_login     NUMBER  := fnd_global.login_id;
procedure startprocess
  ( p_posting_detail_id in number,
  p_RequestorUsername in varchar2,
  p_ProcessOwner    in varchar2,
  p_WorkflowProcess in varchar2,
  p_Item_Type   in varchar2 ) is
     --+
     --+
     ItemKey  varchar2(240) := p_posting_detail_id;
     ItemUserKey  varchar2(80) := p_posting_detail_id;
     --+


     -- changes for bug#2568937
     CURSOR get_details IS
     SELECT cnpt.commission_header_id commission_header_id, cnpt.quota_id  quota_id, pr.payrun_mode
     FROM   cn_payment_transactions_all cnpt, cn_payruns_all pr
     WHERE  cnpt.payment_transaction_id = p_posting_detail_id
     AND    cnpt.payrun_id = pr.payrun_id ;

     -- added new cursor for for bug#2568937 start
     CURSOR get_revenue_class(l_commission_header_id NUMBER) IS
        SELECT revenue_class_id revenue_class_id
    FROM  cn_commission_headers_all cnch
    WHERE cnch.commission_header_id = l_commission_header_id;
           -- added new cursor for for bug#2568937 end

    CURSOR get_accgen_type IS
    SELECT nvl (payables_ccid_level, 'CUSTOM')
    FROM cn_repositories_all rp, cn_payment_transactions_all trxn
    WHERE  trxn.org_id = rp.org_id
    AND  trxn.payment_transaction_id = p_posting_detail_id ;


     l_accgen_type cn_repositories.payables_ccid_level%type;

     l_revenue_class_id cn_commission_headers.revenue_class_id%type;
           l_profile_value  VArchar2(01);

begin
   --+
   -- Start Process :
   --+
   --Changed from 'dd-mon-yyyy hh24:mi:ss' from 'dd-mon-yyyy hh24:mi:sssss' to have more control.
   SELECT p_posting_detail_id ||'--'|| to_char(sysdate, 'dd-mon-yyyy hh24:mi:sssss')
     INTO itemkey
     FROM dual;

   open get_accgen_type;
   fetch get_accgen_type into l_accgen_type;
   close get_accgen_type;

   wf_engine.CreateProcess( ItemType => p_Item_Type,
          ItemKey  => ItemKey,
          process  => p_WorkflowProcess );

   wf_engine.SetItemUserKey (   ItemType  => p_Item_Type,
        ItemKey   => ItemKey,
        UserKey   => ItemUserKey);

     FOR i IN get_details LOOP

      l_profile_value := i.payrun_mode ;

      -- changes for bug#2568937
      IF l_profile_value = 'Y' THEN
    OPEN  get_revenue_class(i.commission_header_id);
    FETCH get_revenue_class into l_revenue_class_id;
    CLOSE get_revenue_class;
      END IF;




  wf_engine.SetItemAttrNumber (   itemtype => p_item_type,
          itemkey  => itemkey,
          aname    => 'POSTING_DETAIL_ID',
          avalue   =>  p_posting_detail_id);

  --+
  wf_engine.SetItemAttrText (   itemtype => p_item_type,
          itemkey  => itemkey,
          aname    => 'QUOTA_ID',
          avalue   =>  i.quota_id);

  --+
  -- changes for bug#2568937
  IF l_profile_value = 'Y' THEN

        wf_engine.SetItemAttrText (   itemtype => p_item_type,
                        itemkey  => itemkey,
                  aname    => 'REVENUE_CLASS_ID',
                  avalue   =>  l_revenue_class_id);

        END IF;
  --+
  wf_engine.SetItemAttrText (   itemtype => p_item_type,
          itemkey  => itemkey,
          aname    => 'ACCGEN_TYPE',
          avalue   =>  l_accgen_type);
  -- changes for bug#2568937
  IF l_profile_value = 'Y' THEN

    -- Added KS
    wf_engine.SetItemAttrText (   itemtype => p_item_type,
            itemkey  => itemkey,
            aname    => 'COMMISSION_HEADER_ID',
            avalue   => i.commission_header_id);
        END IF;

     END LOOP;


     wf_engine.SetItemOwner ( itemtype => p_item_type,
        itemkey  => itemkey,
        owner  => p_ProcessOwner );

     --+

     wf_engine.StartProcess(  itemtype => p_item_type,
        itemkey  => itemkey );

     --+
exception
   when others then
      --+
      wf_core.context('CNACCGEN','CNACCGEN',p_posting_detail_id);
      raise;
      --+
end StartProcess;
--
-- Procedure
--  selector
--
-- Description
--      Determine which process to run
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   resultout - Name of workflow process to run
--
procedure selector
  (   itemtype  in varchar2,
  itemkey   in varchar2,
  actid   in number,
  funcmode  in varchar2,
  resultout out nocopy varchar2 ) is
     --+
begin
   --+
   -- RUN mode - normal process execution
   --+
   if (funcmode = 'RUN') then
      --+
      -- Return process to run
      --+
      resultout := 'CNACCGEN';
      return;
   end if;

   --+
exception
   when others then
      wf_core.context('CNACCGEN','Selector',itemtype,itemkey,actid,funcmode);
      raise;
end selector;

-- update_trx_ccid
--   Update the transaction with the ccid
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout    - 'COMPLETE'
--


procedure update_trx_ccid
  ( itemtype  in varchar2,
  itemkey   in varchar2,
  actid   in number,
  funcmode  in varchar2,
  resultout out nocopy varchar2 ) is

     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);
     l_expense_ccid cn_payment_transactions.expense_ccid%type;
     l_liability_ccid cn_payment_transactions.liability_ccid%type;
     l_posting_detail_id cn_payment_transactions.payment_transaction_id%type;

     --+
     --+
begin
   --+
   -- RUN mode - normal process execution
   --+
   l_expense_ccid := wf_engine.GetItemAttrNumber( itemtype => itemtype,
              itemkey  => itemkey,
              aname  => 'EXPENSE_CCID');
   l_liability_ccid := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                itemkey  => itemkey,
                aname  => 'LIABILITY_CCID');
   l_posting_detail_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                   itemkey  => itemkey,
                   aname   => 'POSTING_DETAIL_ID');
   if (funcmode = 'RUN') then
      update cn_payment_transactions_all
  set expense_ccid = l_expense_ccid,
  liability_ccid = l_liability_ccid,
    --Update WHO columns for bug 3866105 (the same as 11.5.8 bug 3854249, 11.5.10 3866113) by Julia Huang on 9/1/04.
    LAST_UPDATE_DATE = SYSDATE,
  LAST_UPDATED_BY = G_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = G_LAST_UPDATE_LOGIN
        where payment_transaction_id = l_posting_detail_id;
      resultout := 'COMPLETE:T';
   end if;
   --+
   -- CANCEL mode - activity 'compensation'
   --+
   if (funcmode = 'CANCEL') then
      --+
      resultout := 'COMPLETE:';
      return;
      --+
   end if;
   --+
   -- TIMEOUT mode
   --+
   if (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:';
      return;
   end if;

exception
   when FND_API.G_EXC_ERROR THEN
      wf_core.context('CNACCGEN','RECORDNTF',itemtype,itemkey,actid,funcmode);
      raise;
   when others then
      wf_core.context('CNACCGEN','RECORDNTF',itemtype,itemkey,actid,funcmode);
      raise;
end;

procedure get_ccid
  (   itemtype  in varchar2,
  itemkey   in varchar2,
  actid   in number,
  funcmode  in varchar2,
  resultout out nocopy varchar2 )
is

     l_accgen_type varchar2(30);
     l_expense_ccid number;

     l_liability_ccid number;
     l_ccid_identifier number;

     l_cached_org_id integer;
     l_cached_org_append varchar2(100);

    l_rule_id    NUMBER;

    cursor ruleset_cur ( p_commission_header_id number ) is
    select ruleset_id
    from cn_rulesets_all rs, cn_commission_headers_all ch
    where processed_date between start_date and end_date
    and commission_header_id = p_commission_header_id
    and  rs.org_id = ch.org_id
    and module_type = 'ACCGEN' ;

     l_ruleset_id cn_rulesets.ruleset_id%type;

     l_stmt varchar2(4000);
     l_profile_value  varchar2(01);
     l_payment_transaction_id cn_payment_transactions.payment_transaction_id%TYPE;
     l_itc cn_payment_transactions.incentive_type_code%TYPE;

begin
   l_accgen_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname   => 'ACCGEN_TYPE');

    --Bug 3866105 (the same as 11.5.8 bug 3854249, 11.5.10 3866113) by Julia Huang on 9/1/04.
    l_payment_transaction_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                             itemkey  => itemkey,
                                                             aname  => 'POSTING_DETAIL_ID');

    SELECT pr.payrun_mode, pr.org_id , cnpt.incentive_type_code
    INTO   l_profile_value, l_cached_org_id, l_itc
    FROM   cn_payment_transactions_all cnpt, cn_payruns_all pr
    WHERE  cnpt.payment_transaction_id = l_payment_transaction_id
    AND    cnpt.payrun_id = pr.payrun_id ;


   -- changes for bug#2568937
   --Bug 3866105 (the same as 11.5.8 bug 3854249, 11.5.10 3866113) by Julia Huang on 9/1/04.
   IF l_accgen_type = 'REVCLS' AND l_profile_value = 'Y' AND l_itc IN ('COMMISSION','BONUS') THEN

      l_ccid_identifier := wf_engine.GetItemAttrNumber( itemtype => itemtype,itemkey  => itemkey,aname  => 'REVENUE_CLASS_ID');
      SELECT expense_account_id, liability_account_id
      INTO   l_expense_ccid, l_liability_ccid
      FROM  cn_revenue_classes_all
      WHERE revenue_class_id = l_ccid_identifier;

  ELSIF l_accgen_type = 'PLANELEM' THEN
      l_ccid_identifier := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname  => 'QUOTA_ID');
      SELECT expense_account_id, liability_account_id
      INTO   l_expense_ccid, l_liability_ccid
      FROM   cn_quotas_all
      WHERE quota_id = l_ccid_identifier;

    -- changes for bug#2568937
    --Bug 3866105 (the same as 11.5.8 bug 3854249, 11.5.10 3866113) by Julia Huang on 9/1/04.
  ELSIF l_accgen_type = 'CLASSIFICATION' AND l_profile_value = 'Y' AND l_itc IN ('COMMISSION','BONUS') THEN
      l_ccid_identifier := wf_engine.getitemattrnumber
                                                    ( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname  => 'COMMISSION_HEADER_ID');
      IF l_cached_org_id = -99 then
           l_cached_org_append := '_MINUS99';
      ELSE
           l_cached_org_append := '_' || l_cached_org_id;
      END IF;

      open ruleset_cur (l_ccid_identifier);
      fetch ruleset_cur into l_ruleset_id;
      close ruleset_cur;

      l_stmt := 'BEGIN ' ||
                ' cn_clsfn_' || To_char(Abs(l_ruleset_id))
                || l_cached_org_append || '.classify_'
                || To_char(Abs(l_ruleset_id)) ||
                  '( :commission_header_id, :expense_ccid, :liability_ccid ); '
                || 'END;';

      EXECUTE IMMEDIATE l_stmt
      USING  l_ccid_identifier,
      OUT l_expense_ccid, OUT l_liability_ccid;

   --Bug 3866105 (the same as 11.5.8 bug 3854249, 11.5.10 3866113) by Julia Huang on 9/1/04.
   ELSIF l_accgen_type IN ('CLASSIFICATION','REVCLS') AND l_profile_value = 'Y'
        AND l_itc IN ('MANUAL_PAY_ADJ','PMTPLN','PMTPLN_REC')
   THEN
      l_ccid_identifier := wf_engine.GetItemAttrNumber( itemtype => itemtype,itemkey  => itemkey,aname  => 'QUOTA_ID');

      SELECT expense_account_id, liability_account_id
      INTO   l_expense_ccid, l_liability_ccid
      FROM   cn_quotas_all
      WHERE  quota_id = l_ccid_identifier;

   END IF;

   wf_engine.SetItemAttrNumber (  itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'EXPENSE_CCID',
          avalue   =>  l_expense_ccid);
   wf_engine.SetItemAttrNumber (  itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'LIABILITY_CCID',
          avalue   =>  l_liability_ccid);

end;

-- Procedure
--  Get_acc_gen_type
--
-- Description    dummy procedure
--
-- IN
--   itemkey
--
procedure get_acc_gen_type(   itemtype  in varchar2,
  itemkey   in varchar2,
  actid   in number,
  funcmode  in varchar2,
  resultout out nocopy varchar2 ) is

    begin
      resultout := wf_engine.GetItemAttrText( itemtype => itemtype,
              itemkey  => itemkey,
              aname  => 'ACCGEN_TYPE');
      null;
    end;



end CN_WF_PMT_PKG;

/
