--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_WORK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_WORK_PUB" as
--$Header: iexpstmb.pls 120.19.12010000.8 2010/06/22 14:57:36 pnaveenk ship $
----------- procedure check_work_items_completed ------------------------------
/**
 * check to see if there are any pending
 * work items to be processed
 **/
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER ;

--begin schekuri Bug#4506922 Date:02-Dec-2005
wf_yes 		varchar2(1) ;
wf_no 		varchar2(1) ;
--end schekuri Bug#4506922 Date:02-Dec-2005

procedure send_mail(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out NOCOPY  varchar2)
IS
  l_party_id number;
  l_strategy_id number;
  l_delinquency_id number;
  l_party_type varchar2(80);
  l_party_name varchar2(240);
  l_first_name varchar2(80);
  l_last_name varchar2(80);
  l_cust_account_id number;
  l_customer_site_use_id number;
  l_overdue_amount number;
  l_delinquency_status varchar2(30);
  l_payment_schedule_id number;
  l_template_id number;
  l_xdo_template_id number;
  l_workitem_id number;
  l_execution_time date;
  l_aging_bucket_line_id number;

  l_fulfillment_bind_tbl IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
  l_count             NUMBER := 0;
  l_return_status     VARCHAR2(20);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_request_id        NUMBER;
  my_message          VARCHAR2(2000);
  all_message         VARCHAR2(4000);

   --jsanju 04/09 -- fulfillment resource id
  l_resource_id NUMBER;

  cursor c_getuserid(l_resource_id NUMBER) is
  select user_id from jtf_rs_resource_extns
  where resource_id =l_resource_id;

  l_user_id NUMBER;
 -- ctlee, add for create dunning
    l_unique_fulfillment     VARCHAR2(1);
 --   l_delinquency_id        NUMBER;
    l_callback_flag         VARCHAR2(1);
    l_callback_date         DATE;
 --    l_template_id           NUMBER;
    l_campaign_sched_id     NUMBER;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_DUNNING_id            NUMBER;
    l_DUNNING_rec_upd       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_dunning_method        varchar2(2000);

    l_DUNNING_rec_upd_old       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    cursor c_get_dunning(p_workitem_id number) is
    select a.dunning_id from iex_dunnings a
      where a.object_id = p_workitem_id
      and a.object_type = 'IEX_STRATEGY'
      and a.status <> 'CLOSE';

   l_DefaultStrategyLevel varchar2(20);
   l_org_id  NUMBER ;

   -- xdo check
   l_curr_dmethod varchar2(10);
   l_assign_resource_id number;
   cursor c_get_assign_resource(l_strategy_id number, l_workitem_id number) is
--   begin bug 4930376 ctlee - performance 01/09/2006 -- sql id 14771818
     SELECT
      wkitem.resource_id ASSIGNED_TO
      from
      iex_strategy_work_items wkitem, iex_stry_temp_work_items_b stry_temp_wkitem_b, iex_stry_temp_work_items_tl stry_temp_wkitem_tl
      , wf_item_types_tl item, jtf_rs_resource_extns res
      WHERE
      wkitem.work_item_template_id = stry_temp_wkitem_b.work_item_temp_id
      and stry_temp_wkitem_b.work_item_temp_id =stry_temp_wkitem_tl.work_item_temp_id
      and stry_temp_wkitem_tl.LANGUAGE = userenv('LANG')
      and stry_temp_wkitem_b.WORKFLOW_ITEM_TYPE = item.name(+)
      and item.language(+) = userenv('LANG')
      and wkitem.resource_id = res.resource_id(+)
      and wkitem.strategy_id  = l_strategy_id
      and wkitem.work_item_id = l_workitem_id;
--   select a.assigned_to from iex_work_item_bali_v a
--   where a.strategy_id  = l_strategy_id
--      and a.wkitem_id = l_workitem_id;
--   end bug 4930376 ctlee - performance 01/09/2006

    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222

    cursor c_get_org_id ( p_strategy_id number) is
    select org_id from iex_strategies where strategy_id = p_strategy_id;

    v_org_id number;
    l_turnoff_coll_on_bankru	  varchar2(10);
    l_no_of_bankruptcy		  number;

    cursor c_no_of_bankruptcy (p_par_id number)
    is
    select nvl(count(*),0) from iex_bankruptcies
    where party_id = p_par_id
    and (disposition_code in ('GRANTED','NEGOTIATION')
         OR (disposition_code is NULL));

Begin
  -- initialize variables
  l_resource_id :=  fnd_profile.value('IEX_STRY_FULFILMENT_RESOURCE');
  --Bug#4679639 schekuri 20-OCT-2005
  --Value of profile ORG_ID should not be used for getting org_id
  --l_org_id  := fnd_profile.value('ORG_ID');
  l_org_id  := mo_global.get_current_org_id;


--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, funcmode = ' || funcmode);
  END IF;

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('send_mail: ' || 'itemtype = ' || itemtype);
   END IF;
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('send_mail: ' || 'itemtkey = ' || itemkey);
   END IF;
   l_party_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'PARTY_ID');

    if (l_party_id <> 0) then

--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, after PARTY_ID ='|| l_PARTY_ID );
   END IF;

      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'party_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_party_id);
    else  -- party_id could not be null
      result := 'COMPLETE:'||'N';
      return;
    end if;
    l_strategy_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_ID');
    if (l_strategy_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, strategy_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'strategy_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_strategy_id);
    end if;

    l_delinquency_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'DELINQUENCY_ID');
    if (l_delinquency_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, delinquency_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'delinquency_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_delinquency_id);
    end if;

    l_cust_account_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'CUST_ACCOUNT_ID');
    if (l_cust_account_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, cust_account_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'cust_account_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_cust_account_id);

      -- ctlee for xdo template using ACCOUNT_ID matching the query
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'account_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_cust_account_id);

    end if;


    l_overdue_amount := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'OVERDUE_AMOUNT');
    if (l_overdue_amount <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, overdue_amount ');
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'overdue_amount';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
	 l_fulfillment_bind_tbl(l_count).key_value := to_char(l_overdue_amount);
	 end if;


    /*  pass org_id instead
    l_delinquency_status := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'DELINQUENCY_STATUS');
    if (l_delinquency_status is not null) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, delinquency_status ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'delinquency_status';
      l_fulfillment_bind_tbl(l_count).key_type := 'VARCHAR2';
      l_fulfillment_bind_tbl(l_count).key_value := l_delinquency_status;
    end if;
    */

    if (l_org_id is not null) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, org_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'org_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := l_org_id;
    end if;

    l_aging_bucket_line_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'AGING_BUCKET_LINE_ID');
    /* not pass the l_aging_bucket_line_id -  pass customer_site_use_id instead
    if (l_aging_bucket_line_id <> 0) then
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, aging_bucket_line_id ' );
END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'aging_bucket_line_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_aging_bucket_line_id);
    end if;
    */

 l_customer_site_use_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'CUSTOMER_SITE_USE_ID');
    if (l_customer_site_use_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, customer_site_use_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'customer_site_use_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_customer_site_use_id);

    end if;

    l_payment_schedule_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'PAYMENT_SCHEDULE_ID');
    if (l_payment_schedule_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, payment_schedule_id ');
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'payment_schedule_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_payment_schedule_id);
    end if;

    l_template_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'TEMPLATE_ID');
    l_xdo_template_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'XDO_TEMPLATE_ID');
    if (l_template_id <> 0) then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, template_id ' );
      END IF;
    end if;

    if (l_xdo_template_id <> 0) then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, xdo_template_id ' );
      END IF;
    end if;
/*
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'template_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_template_id);
    else  -- template_id could not be null
      result := 'COMPLETE:'||'N';
      return;
    end if;
*/




    l_workitem_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'WORKITEM_ID');
    if (l_workitem_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, workitem_id ' );
      END IF;
/*
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'workitem_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_workitem_id);
*/
    else  -- workitem_id could not be null
      result := 'COMPLETE:'||'N';
      return;
    end if;

-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, l_count ='|| l_count );
 END IF;

  -- ctlee - check the hz_customer_profiles.dunning_letter
  if ( iex_utilities.DunningProfileCheck (
          p_party_id => l_party_id
          , p_cust_account_id => l_cust_account_id
          , p_site_use_id => l_customer_site_use_id
          , p_delinquency_id => l_delinquency_id     ) = 'N'
     ) then
    result := 'COMPLETE:' || 'Y'; -- Bug #6679939 bibeura 11-Dec-2007 Changed from 'N' to 'Y'
    begin
        -- Bug #6679939 bibeura 11-Dec-2007 Value for parameter "avalue" is changed in the following calls
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'ERROR_MESSAGE',
                             avalue    => 'The customer is excluded from dunning in the customer profile');
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'RETURN_STATUS',
                             avalue    => 'S');
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'SKIP');
       EXCEPTION
       WHEN OTHERS THEN
           NULL;
    END;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('send_mail: ' || ' check fail dunning profile check ' );
      END IF;
    return;
  end if;


  -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
  if ( iex_utilities.DunningMinAmountCheck (
           p_cust_account_id => l_cust_account_id
           , p_site_use_id => l_customer_site_use_id)  = 'N'
     ) then
    result := 'COMPLETE:' || 'Y'; -- Bug #6679939 bibeura 11-Dec-2007 Changed from 'N' to 'Y'
    begin
        -- Bug #6679939 bibeura 11-Dec-2007 Value for parameter "avalue" is changed in the following calls
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'ERROR_MESSAGE',
                             avalue    => 'The dunning amount does not exceed the minimum dunning amount in the customer profile');
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'RETURN_STATUS',
                             avalue    => 'S');
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'SKIP');
       EXCEPTION
       WHEN OTHERS THEN
           NULL;
    END;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('send_mail: ' || ' check fail dunning min amount check ' );
      END IF;
    return;

  end if;

  l_turnoff_coll_on_bankru	:= nvl(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'),'N');
  iex_debug_pub.logmessage ('send_mail: ' || ' - l_turnoff_coll_on_bankru: ' || l_turnoff_coll_on_bankru);


  if l_turnoff_coll_on_bankru = 'Y' then
	open c_no_of_bankruptcy (l_party_id);
	fetch c_no_of_bankruptcy into l_no_of_bankruptcy;
	close c_no_of_bankruptcy;
  end if;
  iex_debug_pub.logmessage ('send_mail: ' || ' - l_no_of_bankruptcy: ' || l_no_of_bankruptcy);
  if (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0 ) then
    result := 'COMPLETE:' || 'Y';
    begin
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'ERROR_MESSAGE',
                             avalue    => 'Profile IEX: Turn Off Collections Activity for Bankruptcy is Yes and bankruptcy record is exist, so will skip send dunning');
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'RETURN_STATUS',
                             avalue    => 'S');
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'SKIP');
       EXCEPTION
       WHEN OTHERS THEN
           NULL;
    END;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('send_mail: ' || ' bankruptcy exist for this customer, so will skip send dunning ' );
      END IF;
    return;

  end if;

--jsanju 04/09 fulfilment user only to send
   OPEN c_getuserid(l_resource_id) ;
   fetch c_getuserid  INTO l_user_id;
   CLOSE c_getuserid;


--ctlee 12/17/04 xdo - resource id in the xdo query
   OPEN c_get_assign_resource(l_strategy_id, l_workitem_id) ;
   fetch c_get_assign_resource  INTO l_assign_resource_id;
   CLOSE c_get_assign_resource;

 -- start for bug 9151851 PNAVEENK
   open c_get_org_id(l_strategy_id);
   fetch c_get_org_id into v_org_id;
   close c_get_org_id;
 -- end
-- ctlee - 7/15 fulfillment fax method available
    begin
      select upper(b.category_type)
        into l_dunning_method
        from iex_strategy_work_items a, IEX_STRY_TEMP_WORK_ITEMS_VL b
        where a.work_item_template_id = b.work_item_temp_id
        and a.work_item_id = l_workitem_id
        and b.work_type = 'AUTOMATIC';
      l_dunning_rec.dunning_method := l_dunning_method;  -- default
      exception
      when others then
         l_dunning_method := 'EMAIL';
         l_dunning_rec.dunning_method := l_dunning_method;  -- default
    end;
   -- start for bug 9151851 PNAVEENK
    l_dunning_rec.org_id := v_org_id;
   -- end
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' after fulfil method');
      END IF;
      iex_debug_pub.logmessage(' Org_id value ' || l_dunning_rec.org_id);
-- ctlee - 5/20 create dunning record;  11/21/2002 remove checking profile error when update a non-existing record
--  l_unique_fulfillment :=  nvl(fnd_profile.value('IEX_STRY_UNIQUE_FULFILMENT'), 'N');
--  if (l_unique_fulfillment = 'Y') then
    l_dunning_rec.delinquency_id := l_delinquency_id;
    l_dunning_rec.callback_yn := ''; -- l_callback_flag;
    l_dunning_rec.callback_date := ''; -- l_callback_date;
    l_dunning_rec.status := 'OPEN';

    l_dunning_rec.template_id:= l_template_id;
    --  ctlee xdo template id
    l_dunning_rec.xml_template_id:= l_template_id;

    l_dunning_rec.object_type:= 'IEX_STRATEGY';
    --l_dunning_rec.dunning_method:= 'EMAIL';
    l_dunning_rec.object_id:= l_workitem_id;

    --  set dunning_object_id and dunnint_level
    begin
      select decode(strategy_level, 10, 'CUSTOMER', 20, 'ACCOUNT', 30, 'BILL_TO', 40, 'DELINQUENCY', 'DELINQUENCY')
      into l_DefaultStrategyLevel
      from iex_strategies
      where strategy_id = l_strategy_id;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('Default StrategyLevel ' || l_DefaultStrategyLevel);
      END IF;
      EXCEPTION
            WHEN OTHERS THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logmessage('Strategy Level Rised Exception ');
             END IF;
             l_DefaultStrategyLevel := 'DELINQUENCY';
    END;
    IF l_DefaultStrategyLevel = 'CUSTOMER'  THEN
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_party_id;
    elsif l_DefaultStrategyLevel = 'ACCOUNT' THEN
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_cust_account_id;
    elsif l_DefaultStrategyLevel = 'BILL_TO' THEN
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_customer_site_use_id;
    else
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_delinquency_id;
    end if;

    begin
      select campaign_sched_id into l_campaign_sched_id from iex_delinquencies
        where delinquency_id = l_delinquency_id;
      l_dunning_rec.campaign_sched_id := l_campaign_sched_id;
      exception
      when others then
         l_dunning_rec.campaign_sched_id := null;
    end;

    -- close all the open dunning record before created
    FOR d_rec in c_get_dunning(l_workitem_id)
    LOOP
      begin
          l_dunning_rec_upd_old.dunning_id := d_rec.dunning_id;
          l_dunning_rec_upd_old.last_update_date := sysdate;
          l_dunning_rec_upd_old.callback_yn := 'N';
          l_dunning_rec_upd_old.status := 'SKIP';
          -- l_dunning_rec_upd_old.object_type:= 'IEX_STRATEGY';
          -- l_dunning_rec_upd_old.object_id:= l_workitem_id;

          IEX_DUNNING_PVT.Update_DUNNING(
                   p_api_version              => 1.0
                 , p_init_msg_list            => FND_API.G_FALSE
                 , p_commit                   => FND_API.G_FALSE
                 , p_dunning_rec              => l_dunning_rec_upd_old
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 );
      exception
      when others then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('close dunning before fulfillment exception');
END IF;
      end;
    END LOOP;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, before create dunning ' );
     END IF;
     -- Start Added by gnramasa for bug 5661324 14-Mar-07
     l_dunning_rec.template_id:= l_template_id;
     l_dunning_rec.xml_template_id:= l_xdo_template_id;

     iex_debug_pub.logmessage(' Org_id value ' || l_dunning_rec.org_id);
     -- End Added by gnramasa for bug 5661324 14-Mar-07
    IEX_DUNNING_PVT.CREATE_DUNNING(
        p_api_version              => 1.0
      , p_init_msg_list            => FND_API.G_FALSE
      , p_commit                   => FND_API.G_FALSE
      , p_dunning_rec              => l_dunning_rec
      , x_dunning_id               => l_dunning_id
      , x_return_status            => l_return_status
      , x_msg_count                => l_msg_count
      , x_msg_data                 => l_msg_data);
  -- end if;
     -- Start Added by gnramasa for bug 5661324 14-Mar-07
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'DUNNING_ID';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_dunning_id);
     -- End Added by gnramasa for bug 5661324 14-Mar-07
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, before send_fulfillment ' );
      END IF;
  -- call fulfilment function with multiple bind variables.
  -- ctlee - 6/18 fulfillment printer method available
  l_curr_dmethod := iex_send_xml_pvt.getCurrDeliveryMethod();
  if (l_curr_dmethod = 'FFM') then
    iex_dunning_pvt.send_fulfillment(
                           p_api_version             => 1.0,
                           p_init_msg_list           => FND_API.G_TRUE,
                           p_commit                  => FND_API.G_TRUE,
                           p_FULFILLMENT_BIND_TBL    => l_fulfillment_bind_tbl,
                           p_template_id             => l_template_id,
                           p_method                  => l_dunning_method,
                           p_party_id                => l_party_id,
                           p_user_id                 => l_user_id ,
                           x_return_status           => l_return_status,
                           x_msg_count               => l_msg_count,
                           x_msg_data                => l_msg_data,
                           x_REQUEST_ID              => l_request_id,
                           x_contact_destination      => l_contact_destination,  -- bug 3955222
                           x_contact_party_id         => l_contact_party_id);  -- bug 3955222
  else
	--Added for bug#8490070 by SNUTHALA on 29-May-2009
	BEGIN
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	         iex_debug_pub.logmessage ('send_mail: cancelling all xml requests for this workitem: ' || SQLERRM );
	    END IF;
	    update iex_xml_request_histories
	    set status='CANCELLED'
	    where object_type='IEX_STRATEGY'
	    and status<>'CANCELLED'
	    and xml_request_id in (select xml_request_id
	                       from iex_dunnings
			       where object_type='IEX_STRATEGY'
			       and object_id=l_workitem_id);
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	         iex_debug_pub.logmessage ('send_mail: ' || ' no active previous xml request exists for this workitem ' );
		END IF;
	    WHEN OTHERS THEN
	    	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	         iex_debug_pub.logmessage ('send_mail: error while checking for previous active xml requests for this workitem: ' || SQLERRM );
		END IF;
	END;
    iex_dunning_pvt.send_xml(
                           p_api_version             => 1.0,
                           p_init_msg_list           => FND_API.G_TRUE,
                           p_commit                  => FND_API.G_TRUE,
                           p_resend                  => 'N',
                           p_request_id              => null,
                           p_FULFILLMENT_BIND_TBL    => l_fulfillment_bind_tbl,
                           p_template_id             => l_xdo_template_id,
                           p_method                  => l_dunning_method,
                           p_user_id                 => l_user_id,
                           p_email                   => null,
                           p_party_id                => l_party_id,
                           p_level                   => l_dunning_rec.dunning_level,  -- strategy level
                           p_resource_id             => l_assign_resource_id, --Bug5233002. Fix By LKKUMAR.
                           p_object_code             => l_dunning_rec.object_type, -- 'IEX_STRATEGY'
                           p_source_id               => l_dunning_rec.dunning_object_id, -- used by iex_send_xml_pvt.send_copy
                           p_object_id               => l_workitem_id, -- changed for bug#8403051 by PNAVEENK on 3-4-2009 l_dunning_rec.dunning_object_id,  -- party/account/billto/del id
			   p_org_id                  => l_dunning_rec.org_id,  -- changed for bug 9151851 PNAVEENK
			   x_return_status           => l_return_status,
                           x_msg_count               => l_msg_count,
                           x_msg_data                => l_msg_data,
                           x_REQUEST_ID              => l_request_id,
                           x_contact_destination      => l_contact_destination,  -- bug 3955222
                           x_contact_party_id         => l_contact_party_id);  -- bug 3955222
  end if;
   -- Start Change by gnramasa for bug 5661324 14-Mar-07
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, after send_fulfillment ' );
       iex_debug_pub.logmessage ('send_mail: ' || 'request_id =>'|| l_request_id);
       iex_debug_pub.logmessage ('send_mail: ' || 'return_status =>'|| l_return_status);
       iex_debug_pub.logmessage ('send_mail: ' || 'msg_count =>' || l_msg_count);
       iex_debug_pub.logmessage ('send_mail: ' || 'msg_data =>' || l_msg_data);
    END IF;

   --- share a request id between xdo and ffm
   begin
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'REQUEST_ID',
                             avalue    => l_request_id);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'ERROR_MESSAGE',
                             avalue    => l_msg_data);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'RETURN_STATUS',
                             avalue    => l_return_status);
       EXCEPTION
       WHEN OTHERS THEN
           NULL;
    END;
 -- return to workflow
 if (l_request_id is null OR l_return_status <> 'S') then
    wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'INERROR');

    all_message := null;
    FOR l_index IN 1..l_msg_count LOOP
         my_message := FND_MSG_PUB.Get(p_msg_index => l_index,
                                       p_encoded => 'F');
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage ('send_mail: ' || my_message);
         END IF;
         if all_message is null then
             all_message := my_message;
         else
             all_message := all_message || '; ' || chr(0) || my_message;
         end if;
    END LOOP;
    iex_debug_pub.logmessage ('all_message: ' || all_message);

           wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'ERROR_MESSAGE',
                             avalue    => all_message);
    result := 'COMPLETE:' || 'N';
    iex_stry_utl_pub.update_work_item(
                           p_api_version   => 1.0,
                           p_commit        => FND_API.G_TRUE,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_work_item_id  => l_workitem_id,
                           p_status        => 'INERROR_CHECK_NOTIFY',
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data
                           );
  else
	wf_engine.SetItemAttrText(itemtype  => itemtype,
				     itemkey   => itemkey,
				     aname     => 'WK_STATUS',
				     avalue    => 'COMPLETE');
	wf_engine.SetItemAttrText(itemtype  => itemtype,
			     itemkey   => itemkey,
			     aname     => 'ERROR_MESSAGE',
			     avalue    => null);
	result := 'COMPLETE:'||'Y';
	wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'DELIVERY_WAIT_TIME',
                                 avalue    => sysdate+nvl(fnd_profile.value('IEX_DELIVERY_WAIT_DAYS'),0));

  end if;
                 l_dunning_rec_upd.dunning_id := l_dunning_id;
                 l_dunning_rec_upd.last_update_date := sysdate;
                 l_dunning_rec_upd.callback_yn := 'N';
                 l_dunning_rec_upd.status := 'CLOSE';
                 --  ctlee xdo template id
                 if (l_curr_dmethod = 'FFM') then
                    l_dunning_rec_upd.ffm_request_id := l_request_id;
                 else
                    l_dunning_rec_upd.xml_request_id := l_request_id;
                 end if;
                 l_dunning_rec_upd.contact_destination := l_contact_destination;  -- bug 3955222
                 l_dunning_rec_upd.contact_party_id := l_contact_party_id;  -- bug 3955222

                 IEX_DUNNING_PVT.Update_DUNNING(
                   p_api_version              => 1.0
                 , p_init_msg_list            => FND_API.G_FALSE
                 , p_commit                   => FND_API.G_FALSE
                 , p_dunning_rec              => l_dunning_rec_upd
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 );

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('update dunning l_status =>' || l_return_status);
    iex_debug_pub.logmessage ('send_mail: ' || 'result =>' || result);
END IF;

exception
  when others then
	wf_core.context('IEX_STRATEGY_WORK',' send_mail ',itemtype,
           itemkey,to_char(actid),funcmode);
     raise;

end send_mail;

procedure get_username
                       ( p_resource_id IN NUMBER,
                         x_username    OUT NOCOPY VARCHAR2 ) IS
cursor c_getname(p_resource_id NUMBER) is
Select user_name
from jtf_rs_resource_extns
where resource_id =p_resource_id;

BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** BEGIN get_username ************');
     END IF;
     OPEN c_getname(p_resource_id);
     FETCH c_getname INTO x_username;
     CLOSE c_getname;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** END get_username ************');
     END IF;
END get_username;
-- End Change by gnramasa for bug 5661324 14-Mar-07
-----populate execution_times---------------------------------
--set execution wait period
--populate to fulfillment workflow wait

procedure populate_fulfillment_wait
          (
            p_delinquency_id IN NUMBER,
            p_work_item_id IN NUMBER,
            itemtype            IN   varchar2,
            itemkey             IN   varchar2
           ) IS


cursor c_get_del(p_delinquency_id number) is
   select a.party_id, a.party_type, a.party_name,
    a.person_first_name, a.person_last_name,
    b.cust_account_id, b.status, b.payment_schedule_id,
    b.aging_bucket_line_id, b.customer_site_use_id
    from iex_delinquencies b, hz_parties a
    where a.party_id(+) = b.party_cust_id
      and b.delinquency_id = p_delinquency_id;

cursor c_get_party(p_work_item_id number) is
    select a.party_id, a.party_type, a.party_name,
    a.person_first_name, a.person_last_name, s.cust_account_id, s.customer_site_use_id
    from hz_parties a, iex_strategy_work_items w, iex_strategies s
    where a.party_id = s.party_id and s.strategy_id = w.strategy_id and w.work_item_id = p_work_item_id;

-- bug 4930376 ctlee sql id 14771930, use _all performance
cursor c_get_payment(p_delinquency_id number) is
  select a.amount_due_remaining
   from ar_payment_schedules_all a, iex_delinquencies b
  where a.payment_schedule_id(+) = b.payment_schedule_id
  and b.delinquency_id = p_delinquency_id;

cursor c_get_witem_temp(p_work_item_id NUMBER) is
   select a.post_execution_wait, a.execution_time_uom, a.schedule_wait, a.schedule_uom
      from  IEX_STRY_TEMP_WORK_ITEMS_VL a, IEX_STRATEGY_WORK_ITEMS b
   where b.work_item_template_id = a.work_item_temp_id
      and b.work_item_id = p_work_item_id;

l_fulfillment_wait date;
l_fulfillment_schedule date;
l_strategy_level number ;
l_resource_id NUMBER;
l_username VARCHAR2(120);
--Begin bug#5502077 schekuri 02-May-2007
l_strategy_id NUMBER;
l_SkipFlag NUMBER;
--End bug#5502077 schekuri 02-May-2007
BEGIN
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('populate_fulfillment_wait: ' || 'DEL ID = ' ||p_delinquency_id);
  END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('populate_fulfillment_wait: ' || 'work item id = ' ||p_work_item_id);
    END IF;
  begin
      select a.strategy_level,b.resource_id,a.strategy_id   --Added strategy_id for bug#5502077 schekuri 02-May-2007
         into l_strategy_level,l_resource_id,l_strategy_id
	 from iex_strategies a, iex_strategy_work_items b
        where a.strategy_id = b.strategy_id and b.work_item_id = p_work_item_id;
      if l_strategy_level is null then
        l_strategy_level := 40;
      end if;
    EXCEPTION WHEN OTHERS THEN
      l_strategy_level := 40; -- default to delinquency level
  end;

       -- get user name from  jtf_rs_resource_extns
     if (l_resource_id is not null) THEN
        get_username( p_resource_id =>l_resource_id,
                          x_username    =>l_username);
     else
        l_username := 'SYSADMIN';
     end if;


      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'NOTIFICATION_USERNAME',
                                 avalue    =>  l_username);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('populate_fulfillment_wait: ' || 'strategy_level = ' ||l_strategy_level);
    END IF;

  if l_strategy_level = 10 or l_strategy_level = 20 or l_strategy_level = 30 then
    FOR party_rec in c_get_party(p_work_item_id)
    LOOP
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('populate_fulfillment_wait: ' || 'INSIDE THE LOOP ' ||party_rec.party_id);
       iex_debug_pub.logmessage('populate_fulfillment_wait: ' || 'INSIDE THE LOOP ' ||party_rec.cust_account_id);
      END IF;
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'PARTY_ID',
                             avalue    => party_rec.party_id);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'PARTY_TYPE',
                             avalue    => party_rec.party_type);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'PARTY_NAME',
                             avalue    => party_rec.party_name);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'FIRST_NAME',
                             avalue    => party_rec.person_first_name);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'LAST_NAME',
                             avalue    => party_rec.person_last_name);
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'CUST_ACCOUNT_ID',
                             avalue    => party_rec.cust_account_id);
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'CUSTOMER_SITE_USE_ID',
                             avalue    => party_rec.customer_site_use_id);
        exit;
    END LOOP;
  else
    FOR d_rec in c_get_del(p_delinquency_id)
    LOOP
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('populate_fulfillment_wait: ' || 'INSIDE THE LOOP ' ||d_rec.party_id);
    END IF;
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'PARTY_ID',
                             avalue    => d_rec.party_id);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'PARTY_TYPE',
                             avalue    => d_rec.party_type);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'PARTY_NAME',
                             avalue    => d_rec.party_name);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'FIRST_NAME',
                             avalue    => d_rec.person_first_name);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'LAST_NAME',
                             avalue    => d_rec.person_last_name);
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'CUST_ACCOUNT_ID',
                             avalue    => d_rec.cust_account_id);
        wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'DELINQUENCY_STATUS',
                             avalue    => d_rec.status);
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'AGING_BUCKET_LINE_ID',
                             avalue    => d_rec.aging_bucket_LINE_id);
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'PAYMENT_SCHEDULE_ID',
                             avalue    => d_rec.payment_schedule_id);
        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'CUSTOMER_SITE_USE_ID',
                             avalue    => d_rec.customer_site_use_id);
        exit;
    END LOOP;
    FOR p_rec in c_get_payment(p_delinquency_id)
    LOOP
     wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'OVERDUE_AMOUNT',
                             avalue    => p_rec.amount_due_remaining);
      exit;
    END LOOP;
  end if;



     FOR c_rec in c_get_witem_temp(p_work_item_id)
     LOOP
	 --Begin bug#5502077 schekuri 02-May-2007
	 --If the Strategy workflow contains RESET_WORK_ITEM_STATUS activity
	 --skip the SCHEDULE_WAIT. Since it already waits at pre-wait node in
	 --main Strategy workflow there is no need to wait at WAIT node in Fulfillment workflow.
         l_SkipFlag := 0;

         if (l_strategy_id is not null) then

	    BEGIN

              select ceil(wfi.BEGIN_DATE - wfa.begin_Date) into l_SkipFlag
              from WF_ITEMS wfi, WF_ACTIVITIES wfa
              WHERE wfi.ITEM_TYPE = 'IEXSTRY'
	        and wfa.version = (select min(wa.version) from wf_activities wa
                                  where wa.item_type=wfa.item_type
                                  and wa.name=wfa.name)
                and wfi.item_key = l_Strategy_id
                and wfa.item_type = wfi.item_type AND
                wfa.name = 'RESET_WORK_ITEM_STATUS' ;

	    EXCEPTION
	      WHEN OTHERS THEN NULL;
	    END;

              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage ('populate_fulfillment_wait: check for skip ' || ' SKIP FLAG = ' ||
                  l_SkipFlag);
              END IF;

         end if;

         IF (l_SkipFlag > 0) THEN
               l_fulfillment_schedule := SYSDATE;
         ELSE

          l_fulfillment_schedule:=IEX_STRY_UTL_PUB.get_date
                            (p_date =>SYSDATE,
                             l_UOM  =>c_rec.schedule_uom,
                             l_UNIT =>c_rec.schedule_wait);
         END IF;

          /*l_fulfillment_schedule:=IEX_STRY_UTL_PUB.get_date
                            (p_date =>SYSDATE,
                             l_UOM  =>c_rec.schedule_uom,
                             l_UNIT =>c_rec.schedule_wait);*/
       --End bug#5502077 schekuri 02-May-2007
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage ('populate_fulfillment_wait: ' || ' SCHEDULE TIME WAIT = ' ||
            to_char(l_fulfillment_schedule, 'ss:mi:hh24 mm/dd/yyyy'));
         END IF;


         --set execution wait attribute
         wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'SCHEDULE_TIME',
                                   avalue    => l_fulfillment_schedule);

          --begin bug#5502077 schekuri 30-Apr-2007
	  --since there is post wait in the main strategy workflow there is no need to wait here
          /*l_fulfillment_wait:=IEX_STRY_UTL_PUB.get_date
                            (p_date =>l_fulfillment_schedule,
                             l_UOM  =>c_rec.execution_time_uom,
                             l_UNIT =>c_rec.post_execution_wait);*/
          l_fulfillment_wait:= sysdate;
          --end bug#5502077 schekuri 30-Apr-2007

--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage ('populate_fulfillment_wait: ' || ' EXECUTION TIME WAIT = ' ||
            to_char(l_fulfillment_wait, 'ss:mi:hh24 mm/dd/yyyy'));
         END IF;


         --set execution wait attribute
         wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'EXECUTION_TIME',
                                   avalue    => l_fulfillment_wait);

         exit;
    END LOOP;
EXCEPTION WHEN OTHERS THEN
    null;
END  populate_fulfillment_wait;

/**
 * setup the workflow which call the mailer thru fulfilment
 **/
procedure strategy_mailer(
    p_api_version             IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2,
    p_commit                  IN  VARCHAR2,
    p_strategy_mailer_rec     IN  STRATEGY_MAILER_REC_TYPE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2)
    IS
       l_itemtype    varchar2(80);
       l_itemkey     varchar2(80);
       l_workflowprocess     varchar2(80);
       l_result      varchar2(80);

       l_error_msg     VARCHAR2(2000);
       l_return_status     VARCHAR2(20);
       l_msg_count     NUMBER;
       l_msg_data     VARCHAR2(2000);
       l_api_name     VARCHAR2(100) ;
       l_api_version_number          CONSTANT NUMBER   := 1.0;

  begin
    -- initialize variables
       l_api_name     := 'STRATEGY_MAILER';


--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('in strategy_mailer');
END IF;
    -- Standard Start of API savepoint
  --  SAVEPOINT STRATEGY_MAILER;   -- Standard call to check for call compatibility.
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('in strategy_mailer 1');
END IF;
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('in strategy_mailer 2');
END IF;
    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('in strategy_mailer 3');
END IF;


-- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_itemtype := 'IEXSTFFM';
    l_workflowprocess := 'IEXSTFFM';
    l_itemkey := p_strategy_mailer_rec.workitem_id;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('in strategy_mailer 4');
END IF;

    wf_engine.createprocess  (  itemtype => l_itemtype,
        itemkey  => l_itemkey,
        process  => l_workflowprocess);
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('in strategy_mailer 5');
END IF;



   if (p_strategy_mailer_rec.strategy_id  is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'STRATEGY_ID',
                             avalue    => p_strategy_mailer_rec.strategy_id);
   end if;
   if (p_strategy_mailer_rec.delinquency_id is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'DELINQUENCY_ID',
                             avalue    => p_strategy_mailer_rec.delinquency_id);
   end if;
   if (p_strategy_mailer_rec.template_id is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'TEMPLATE_ID',
                             avalue    => p_strategy_mailer_rec.template_id);
   end if;
   if (p_strategy_mailer_rec.xdo_template_id is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'XDO_TEMPLATE_ID',
                             avalue    => p_strategy_mailer_rec.xdo_template_id);
   end if;
   if (p_strategy_mailer_rec.workitem_id is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'WORKITEM_ID',
                             avalue    => p_strategy_mailer_rec.workitem_id);
   end if;

   if (p_strategy_mailer_rec.user_id is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'USER_ID',
                             avalue    => p_strategy_mailer_rec.user_id);
   end if;

   if (p_strategy_mailer_rec.resp_id is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'RESP_ID',
                             avalue    => p_strategy_mailer_rec.resp_id);
   end if;

   if (p_strategy_mailer_rec.resp_appl_id is not null) then
     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'RESP_APPL_ID',
                             avalue    => p_strategy_mailer_rec.resp_appl_id);
   end if;



   populate_fulfillment_wait    (
            p_delinquency_id => p_strategy_mailer_rec.delinquency_id,
            p_work_item_id => p_strategy_mailer_rec.workitem_id,
            itemtype       => l_itemtype,
            itemkey        => l_itemkey
   );

--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('strategy_mailer: ' || ' before start workflow process');
   END IF;

    wf_engine.startprocess(itemtype => l_itemtype,  itemkey  =>   l_itemkey);
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('strategy_mailer: ' || ' after start workflow process');
    END IF;
    wf_engine.ItemStatus(
          itemtype =>   l_itemType,
          itemkey   =>   l_itemKey,
          status   =>   l_return_status,
          result   =>   l_result);

    if (l_return_status in ('COMPLETE', 'ACTIVE')) THEN
      x_return_status := 'S';
    else
      x_return_status := 'F';
    end if;
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('strategy_mailer: ' || ' workflow return status = ' || l_return_status);
 END IF;


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('UNEXPECTED ERROR. PUB: ' || l_api_name || ' end');
          iex_debug_pub.logmessage('PUB: ' || l_api_name || ' end');
          iex_debug_pub.logmessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('UNHANDLED WORKFLOW EXCEPTION. Strategy ID ' || p_strategy_mailer_rec.strategy_id);
          iex_debug_pub.logmessage('PUB: ' || l_api_name || ' end');
          iex_debug_pub.logmessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

end strategy_mailer;



procedure wf_send_signal(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out NOCOPY  varchar2)
IS
l_work_item_id number;
l_strategy_id number;
l_wk_status varchar2(20);
l_return_status     VARCHAR2(20);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
 exc                 EXCEPTION;
 l_error VARCHAR2(32767);
begin
  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_work_item_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'WORKITEM_ID');
  l_strategy_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_ID');
  if (l_work_item_id is not null) then
--04/04 jsanju
-- do not update the send signal will update
--04/16/02 -- update it here and send signal if successful
--05/20/02 -- update it work item status
    l_wk_status := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'WK_STATUS');

    iex_stry_utl_pub.update_work_item(
                           p_api_version   => 1.0,
                           p_commit        => FND_API.G_TRUE,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_work_item_id  => l_work_item_id,
                           p_status        => l_wk_status,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data
                           );

   if l_return_status =FND_API.G_RET_STS_SUCCESS THEN
      --04/04 -jsanju
      -- add new parameter to send signal

      iex_strategy_wf.send_signal(
                           process    => 'IEXSTRY' ,
                           strategy_id => l_strategy_id,
                           status      => l_wk_status,
                           work_item_id => l_work_item_id,
		      			  signal_source  => 'FULFILLMENT');
      else
          RAISE EXC;

      end if;-- if update successful

  end if;
 result := wf_engine.eng_completed;

EXCEPTION
WHEN EXC THEN
     --pass the error message
      -- get error message and pass
      iex_strategy_wf.Get_Messages(l_msg_count,l_error);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('wf_send_signal: ' || 'error message is ' || l_error);
      END IF;
      wf_core.context('IEX_STRATEGY_WORK_PUB','wf_send_signal',itemtype,
                   itemkey,to_char(actid),funcmode,l_error);
     raise;

WHEN OTHERS THEN

  wf_core.context('IEX_STRATEGY_WORK_PUB','wf_send_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;


end wf_send_signal;




procedure check_dunning(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out NOCOPY  varchar2)
IS
l_return_status     VARCHAR2(20);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
l_error VARCHAR2(32767);
l_delinquency_id        NUMBER;
l_cust_account_id        NUMBER;
l_customer_site_use_id        NUMBER;
l_count              NUMBER := 0;

l_user_id             NUMBER;
l_resp_id             NUMBER;
l_resp_appl_id        NUMBER;

l_work_item_id number;
l_strategy_id number;
l_party_id number;
-- l_cust_account_id number;
l_strategy_level varchar2(20);
l_unique_fulfillment     VARCHAR2(1);
begin

     if funcmode <> 'RUN' then
        result := 'COMPLETE:' || 'N';
        return;
      end if;
      result := 'COMPLETE:' || 'N';

  l_unique_fulfillment :=  nvl(fnd_profile.value('IEX_STRY_UNIQUE_FULFILMENT'), 'N');
/*
  if (l_unique_fulfillment = 'N') then
      result := 'COMPLETE:' || 'Y';
      return;
  end if;
*/

    l_user_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'USER_ID');

   l_resp_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'RESP_ID');

   l_resp_appl_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'RESP_APPL_ID');

   l_delinquency_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'DELINQUENCY_ID');
  l_work_item_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'WORKITEM_ID');
  l_strategy_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_ID');
   l_party_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'PARTY_ID');
    l_cust_account_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'CUST_ACCOUNT_ID');
    l_customer_site_use_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'CUSTOMER_SITE_USE_ID');
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('check_dunning: ' || ' check dunning, delinquency_id = ' || l_delinquency_id);
     iex_debug_pub.logmessage ('check_dunning: ' || ' check dunning, party_id = ' || l_party_id);
     iex_debug_pub.logmessage ('check_dunning: ' || ' check dunning, cust_account_id = ' || l_cust_account_id);
     iex_debug_pub.logmessage ('check_dunning: ' || ' check dunning, strategy_id = ' || l_strategy_id);
     iex_debug_pub.logmessage ('check_dunning: ' || ' check dunning, work_item_id = ' || l_work_item_id);
     iex_debug_pub.logmessage ('check_dunning: ' || ' check dunning, customer_site_use_id = ' || l_customer_site_use_id);
  END IF;

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('check_dunning: ' || 'USER_ID' ||  l_user_id || ' RESP_ID ' ||  l_resp_id);
  END IF;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('check_dunning: ' || 'RESP_APPL_ID' ||l_resp_appl_id);
  END IF;
  --set the session
  --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);

  select decode(strategy_level, 10, 'CUSTOMER', 20, 'ACCOUNT', 30, 'BILL_TO', 'DELINQUENCY') into l_strategy_level
    from iex_strategies where strategy_id = l_strategy_id;
  -- if l_delinquency_id is not null then
  if l_strategy_level = 'CUSTOMER' then
    begin
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('check_dunning: level 10' || ' check dunning, party_id = ' || l_party_id);
       END IF;
       if l_party_id is not null then
	      select count(*) into l_count from iex_dunnings where dunning_id in (
 	      select dun.dunning_id from iex_dunnings dun
		  where dun.dunning_object_id = l_party_id
		  and dun.dunning_level = l_strategy_level
                  and dun.status = 'CLOSE'
		  and trunc(sysdate) = trunc(dun.creation_date) );
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('check_dunning: level 10' || ' check dunning, l_count = ' || l_count);
          END IF;
          if l_count > 0 and l_unique_fulfillment = 'Y' then
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'CANCELLED');
              result := 'COMPLETE:' || 'Y';
   	     end if;
      end if;
      exception
      when others then
        result := 'COMPLETE:' || 'N';
    end;
  elsif l_strategy_level = 'ACCOUNT' then
    begin
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('check_dunning: level 20' || ' check dunning, cust_account_id = ' || l_cust_account_id);
       END IF;
       if l_cust_account_id is not null then
	      select count(*) into l_count from iex_dunnings where dunning_id in (
 	      select dun.dunning_id from iex_dunnings dun
		  where dun.dunning_object_id = l_cust_account_id
		  and dun.dunning_level = l_strategy_level
                  and dun.status = 'CLOSE'
		  and trunc(sysdate) = trunc(dun.creation_date) );
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('check_dunning: level 20' || ' check dunning, l_count = ' || l_count);
          END IF;
          if l_count > 0 and l_unique_fulfillment = 'Y' then
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'CANCELLED');
              result := 'COMPLETE:' || 'Y';
   	     end if;
      end if;
      exception
      when others then
        result := 'COMPLETE:' || 'N';
    end;
  elsif l_strategy_level = 'BILL_TO' then
    begin
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('check_dunning: level 30' || ' check dunning, customer_site_use_id = ' || l_customer_site_use_id);
       END IF;
       if l_customer_site_use_id is not null then
	      select count(*) into l_count from iex_dunnings where dunning_id in (
 	      select dun.dunning_id from iex_dunnings dun
		  where dun.dunning_object_id = l_customer_site_use_id
		  and dun.dunning_level = l_strategy_level
                  and dun.status = 'CLOSE'
		  and trunc(sysdate) = trunc(dun.creation_date) );
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('check_dunning: level 30' || ' check dunning, l_count = ' || l_count);
          END IF;
          if l_count > 0 and l_unique_fulfillment = 'Y' then
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'CANCELLED');
              result := 'COMPLETE:' || 'Y';
   	     end if;
      end if;
      exception
      when others then
        result := 'COMPLETE:' || 'N';
    end;
  else  -- default level 40
    begin
      select cust_account_id into l_cust_account_id from iex_delinquencies
        where delinquency_id = l_delinquency_id;
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('check_dunning: 40 ' || ' check dunning, delinquency_id = ' || l_delinquency_id);
       END IF;
       if l_cust_account_id is not null then
          -- begin bug #4230209 03/09/2005 by ctlee, multiple letters were sent in the same day even unique = 'Y'
	  --  select count(*) into l_count from iex_dunnings where dunning_id in (
 	  --    select dun.dunning_id from iex_delinquencies del, iex_dunnings dun
          --	  where del.cust_account_id = l_cust_account_id
          --	  and del.delinquency_id = dun.delinquency_id
          --      and dun.status = 'CLOSE'
          --      and trunc(sysdate) = trunc(dun.creation_date) );
	  select count(*) into l_count from iex_dunnings where dunning_id in (
 	    select dun.dunning_id from iex_delinquencies del, iex_dunnings dun
               where del.cust_account_id = l_cust_account_id
               and ((del.delinquency_id = dun.delinquency_id and dun.status = 'CLOSE') or
                    (del.delinquency_id = dun.delinquency_id and dun.status = 'OPEN' and
                     del.delinquency_id <> l_delinquency_id )
                   )
               and trunc(sysdate) = trunc(dun.creation_date) );
          -- end bug #4230209 03/09/2005 by ctlee, multiple letters were sent in the same day even unique = 'Y'
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('check_dunning: 40' || ' check dunning, l_count = ' || l_count);
          END IF;
          if l_count > 0 and l_unique_fulfillment = 'Y' then
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'WK_STATUS',
                             avalue    => 'CANCELLED');
             result := 'COMPLETE:' || 'Y';
   	     end if;
      end if;
      exception
      when others then
        result := 'COMPLETE:' || 'N';
    end;
  end if;
EXCEPTION
WHEN OTHERS THEN
  result := 'COMPLETE:' || 'N';
  wf_core.context('IEX_STRATEGY_WORK_PUB','check_dunning',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
end check_dunning;

/* resend fulfillment by clicked the button */

procedure resend_fulfillment(
p_work_item_id IN NUMBER
, x_status out NOCOPY varchar2
, x_error_message out NOCOPY varchar2
, x_request_id out NOCOPY number)
 IS
  p_delinquency_id NUMBER;

  l_party_id number;
  l_strategy_id number;
  l_delinquency_id number;
  l_party_type varchar2(80);
  l_party_name varchar2(240);
  l_first_name varchar2(80);
  l_last_name varchar2(80);
  l_cust_account_id number;
  l_customer_site_use_id number;
  l_overdue_amount number;
  l_status varchar2(30);
  l_payment_schedule_id number;
  l_template_id number;
   -- xdo check
  l_xdo_template_id number;
  l_workitem_id number;
  l_aging_bucket_line_id number;
  l_fulfil_temp_id number;
  l_xdo_temp_id number;

  l_fulfillment_bind_tbl IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
  l_count             NUMBER := 0;
  l_return_status     VARCHAR2(20);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_request_id        NUMBER;
  my_message          VARCHAR2(2000);

   --jsanju 04/09 -- fulfillment resource id
  l_resource_id NUMBER;

  cursor c_getuserid(l_resource_id NUMBER) is
  select user_id from jtf_rs_resource_extns
  where resource_id =l_resource_id;

  l_user_id NUMBER;
 -- ctlee, add for create dunning
    l_unique_fulfillment     VARCHAR2(1);
 --   l_delinquency_id        NUMBER;
    l_callback_flag         VARCHAR2(1);
    l_callback_date         DATE;
 --    l_template_id           NUMBER;
    l_campaign_sched_id     NUMBER;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_DUNNING_id            NUMBER;
    l_DUNNING_rec_upd       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_dunning_method        varchar2(2000);

  l_DUNNING_rec_upd_old       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    cursor c_get_dunning(p_workitem_id number) is
    select a.dunning_id from iex_dunnings a
      where a.object_id = p_workitem_id
      and a.object_type = 'WORK_ITEM'
      and a.status <> 'CLOSE';


  cursor c_get_del(p_delinquency_id number) is
    select a.party_id, a.party_type, a.party_name,
    a.person_first_name, a.person_last_name,
    b.cust_account_id, b.status, b.payment_schedule_id,
    b.aging_bucket_line_id, b.customer_site_use_id
    from iex_delinquencies b, hz_parties a
    where a.party_id(+) = b.party_cust_id
      and b.delinquency_id = p_delinquency_id;

-- bug 4930376 ctlee sql id 14772154, use _all performance
  cursor c_get_payment(p_delinquency_id number) is
   select a.amount_due_remaining
   from ar_payment_schedules_all a, iex_delinquencies b
   where a.payment_schedule_id(+) = b.payment_schedule_id
    and b.delinquency_id = p_delinquency_id;

  cursor c_get_witem_temp(p_work_item_id NUMBER) is
    select delinquency_id, a.strategy_id
      from iex_strategies a, iex_strategy_work_items b
      where a.strategy_id = b.strategy_id and  b.work_item_id = p_work_item_id;

    -- ctlee using xdo template id
  cursor c_get_xdo_template(p_work_item_id NUMBER) is
    select a.xdo_template_id from IEX_STRY_TEMP_WORK_ITEMS_VL a, iex_strategy_work_items b
    where a.work_item_temp_id = b.work_item_template_id and work_item_id = p_work_item_id;

  cursor c_get_fulfillment_template(p_work_item_id NUMBER) is
    select fulfil_temp_id from IEX_STRY_TEMP_WORK_ITEMS_VL a, iex_strategy_work_items b
    where a.work_item_temp_id = b.work_item_template_id and work_item_id = p_work_item_id;

  cursor c_get_party(p_work_item_id number) is
    select a.party_id, a.party_type, a.party_name,
    a.person_first_name, a.person_last_name, s.cust_account_id, s.customer_site_use_id
    from hz_parties a, iex_strategy_work_items w, iex_strategies s
    where a.party_id = s.party_id and s.strategy_id = w.strategy_id and w.work_item_id = p_work_item_id;

  l_strategy_level number ;
  l_DefaultStrategyLevel varchar2(20);

   -- xdo check
   l_curr_dmethod varchar2(10);
   l_assign_resource_id number;
   cursor c_get_assign_resource(l_strategy_id number, l_workitem_id number) is
--   begin bug 4930376 ctlee - performance 01/09/2006 -- sql id 14772213
     SELECT
      wkitem.resource_id ASSIGNED_TO
      from
      iex_strategy_work_items wkitem, iex_stry_temp_work_items_b stry_temp_wkitem_b, iex_stry_temp_work_items_tl stry_temp_wkitem_tl
      , wf_item_types_tl item, jtf_rs_resource_extns res
      WHERE
      wkitem.work_item_template_id = stry_temp_wkitem_b.work_item_temp_id
      and stry_temp_wkitem_b.work_item_temp_id =stry_temp_wkitem_tl.work_item_temp_id
      and stry_temp_wkitem_tl.LANGUAGE = userenv('LANG')
      and stry_temp_wkitem_b.WORKFLOW_ITEM_TYPE = item.name(+)
      and item.language(+) = userenv('LANG')
      and wkitem.resource_id = res.resource_id(+)
      and wkitem.strategy_id  = l_strategy_id
      and wkitem.work_item_id = l_workitem_id;
--     select a.assigned_to from iex_work_item_bali_v a
--       where a.strategy_id  = l_strategy_id
--       and a.wkitem_id = l_workitem_id;
--   end bug 4930376 ctlee - performance 01/09/2006

    -- start for bug 9151851
    cursor c_get_org_id ( p_strategy_id number) is
    select org_id from iex_strategies where strategy_id = p_strategy_id;
    -- end
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222
    v_org_id number; -- added for bug 9151851

BEGIN

    l_resource_id :=  fnd_profile.value('IEX_STRY_FULFILMENT_RESOURCE');
    x_status := 'F';
    x_request_id := 0;
    l_workitem_id := p_work_item_id;
    FOR c_rec in c_get_witem_temp(p_work_item_id)
    LOOP
         l_delinquency_id := c_rec.delinquency_id;
         l_strategy_id := c_rec.strategy_id;
         exit;
    END LOOP;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('resend_fulfillment: ' || 'DEL ID ' ||l_delinquency_id);
    END IF;

    FOR x_rec in c_get_xdo_template(p_work_item_id)
    LOOP
      -- xdo template id
      l_xdo_temp_id := x_rec.xdo_template_id;
      l_xdo_template_id := l_xdo_temp_id;
      exit;
    END LOOP;

    FOR f_rec in c_get_fulfillment_template(p_work_item_id)
    LOOP
      l_fulfil_temp_id := f_rec.fulfil_temp_id;
      l_template_id := l_fulfil_temp_id;
      exit;
    END LOOP;
  begin
      select a.strategy_level into l_strategy_level from iex_strategies a, iex_strategy_work_items b
        where a.strategy_id = b.strategy_id and b.work_item_id = p_work_item_id;
      if l_strategy_level is null then
        l_strategy_level := 40;
      end if;
    EXCEPTION WHEN OTHERS THEN
      l_strategy_level := 40; -- default to delinquency level
  end;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('resend_fulfillment: ' || 'strategy_level = ' ||l_strategy_level);
    END IF;

  if l_strategy_level = 10 or l_strategy_level = 20 or l_strategy_level = 30 then
    FOR party_rec in c_get_party(p_work_item_id)
    LOOP
        l_party_id := party_rec.party_id;
        l_party_type := party_rec.party_type;
        l_party_name := party_rec.party_name;
        l_first_name := party_rec.person_first_name;
        l_last_name := party_rec.person_last_name;
        l_cust_account_id := party_rec.cust_account_id;
        l_customer_site_use_id := party_rec.customer_site_use_id;
        -- l_status := party_rec.status;
        -- l_aging_bucket_LINE_id := party_rec.aging_bucket_LINE_id;
        -- l_payment_schedule_id := party_rec.payment_schedule_id;
        exit;
    END LOOP;
  else
    FOR d_rec in c_get_del(l_delinquency_id)
    LOOP
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage('resend_fulfillment: ' || 'INSIDE THE LOOP ' ||d_rec.party_id);
        END IF;
        l_party_id := d_rec.party_id;
        l_party_type := d_rec.party_type;
        l_party_name := d_rec.party_name;
        l_first_name := d_rec.person_first_name;
        l_last_name := d_rec.person_last_name;
        l_cust_account_id := d_rec.cust_account_id;
        l_status := d_rec.status;
        l_aging_bucket_LINE_id := d_rec.aging_bucket_LINE_id;
        l_payment_schedule_id := d_rec.payment_schedule_id;
        l_customer_site_use_id := d_rec.customer_site_use_id;
        exit;
    END LOOP;

    FOR p_rec in c_get_payment(l_delinquency_id)
    LOOP
      l_overdue_amount := p_rec.amount_due_remaining;
      exit;
    END LOOP;
  end if;


    if (l_party_id <> 0) then

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, after PARTY_ID ='|| l_PARTY_ID );
      END IF;

      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'party_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_party_id);
    else  -- party_id could not be null
      x_error_message := 'No party id';
      return;
    end if;

    if (l_strategy_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, strategy_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'strategy_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_strategy_id);
    end if;


    if (l_delinquency_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, delinquency_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'delinquency_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_delinquency_id);
    end if;

    if (l_cust_account_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, cust_account_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'cust_account_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_cust_account_id);

      -- ctlee for xdo template using ACCOUNT_ID matching the query
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'account_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_cust_account_id);
    end if;

   if (l_customer_site_use_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, customer_site_use_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'customer_site_use_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_customer_site_use_id);

    end if;

  if l_strategy_level = 40 then
    if (l_overdue_amount <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, overdue_amount ');
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'overdue_amount';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_overdue_amount);
    end if;


    if (l_status is not null) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, delinquency_status ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'delinquency_status';
      l_fulfillment_bind_tbl(l_count).key_type := 'VARCHAR2';
      l_fulfillment_bind_tbl(l_count).key_value := l_status;
    end if;

    /*
    if (l_aging_bucket_line_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, aging_bucket_line_id ' );
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'aging_bucket_line_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_aging_bucket_line_id);
    end if;
    */


    if (l_payment_schedule_id <> 0) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, payment_schedule_id ');
      END IF;
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'payment_schedule_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(l_payment_schedule_id);
    end if;

  end if; -- only if strategy_level = 40

  l_curr_dmethod := iex_send_xml_pvt.getCurrDeliveryMethod();
  if (l_curr_dmethod = 'FFM') then
    if (l_fulfil_temp_id <> 0) then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, template_id ' );
      END IF;
    else  -- template_id could not be null
      x_error_message := 'No fulfillment template id';
      return;
    end if;
  else
    if (l_xdo_template_id <> 0) then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('send_mail: ' || ' in send mail, xdo_template_id ' );
      END IF;
    else  -- template_id could not be null
      x_error_message := 'No xdo template id';
      return;
    end if;
  end if;


    if (p_work_item_id <> 0) then
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, workitem_id ' );
    END IF;
/*
      l_count := l_count +1;
      l_fulfillment_bind_tbl(l_count).key_name := 'workitem_id';
      l_fulfillment_bind_tbl(l_count).key_type := 'NUMBER';
      l_fulfillment_bind_tbl(l_count).key_value := to_char(p_work_item_id);
*/
    else  -- workitem_id could not be null
      x_error_message := 'No workitem id';
      return;
    end if;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, l_count ='|| l_count );
    END IF;


  -- ctlee - check the hz_customer_profiles.dunning_letter
  if ( iex_utilities.DunningProfileCheck (
          p_party_id => l_party_id
          , p_cust_account_id => l_cust_account_id
          , p_site_use_id => l_customer_site_use_id
          , p_delinquency_id => l_delinquency_id     ) = 'N'
     ) then
      x_error_message := 'Customer profile has set the dunning flag to NO';
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || x_error_message);
      END IF;
      return;
  end if;


  -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
  if ( iex_utilities.DunningMinAmountCheck (
           p_cust_account_id => l_cust_account_id
           , p_site_use_id => l_customer_site_use_id)  = 'N'
     ) then
      x_error_message := 'The dunning amount does not exceed the minimum dunning amount in customer profile';
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('resend_fulfillment: ' || x_error_message);
      END IF;
      return;

  end if;

--jsanju 04/09 fulfilment user
   OPEN c_getuserid(l_resource_id) ;
   fetch c_getuserid  INTO l_user_id;
   CLOSE c_getuserid;

--ctlee 12/17/04 xdo - resource id in the xdo query
   OPEN c_get_assign_resource(l_strategy_id, l_workitem_id) ;
   fetch c_get_assign_resource  INTO l_assign_resource_id;
   CLOSE c_get_assign_resource;

   -- start for bug 9151851
   open c_get_org_id ( l_strategy_id);
   fetch c_get_org_id into v_org_id;
   close c_get_org_id;

   -- end

-- ctlee - 7/15 fulfillment fax method available
    begin
      select upper(b.category_type)
        into l_dunning_method
        from iex_strategy_work_items a, IEX_STRY_TEMP_WORK_ITEMS_VL b
        where a.work_item_template_id = b.work_item_temp_id
        and a.work_item_id = l_workitem_id
        and b.work_type = 'AUTOMATIC';
      l_dunning_rec.dunning_method := l_dunning_method;  -- default
      exception
      when others then
         l_dunning_method := 'EMAIL';
         l_dunning_rec.dunning_method := l_dunning_method;  -- default
    end;

--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('resend_fulfillment: ' || ' after fulfil method');
   END IF;

-- ctlee - 5/20 create dunning record
--  l_unique_fulfillment :=  nvl(fnd_profile.value('IEX_STRY_UNIQUE_FULFILMENT'), 'N');
--  if (l_unique_fulfillment = 'Y') then
    l_dunning_rec.delinquency_id := l_delinquency_id;
    l_dunning_rec.callback_yn := ''; -- l_callback_flag;
    l_dunning_rec.callback_date := ''; -- l_callback_date;
    l_dunning_rec.status := 'OPEN';

    l_dunning_rec.template_id:= l_template_id;
    --  ctlee xdo template id
    l_dunning_rec.xml_template_id:= l_xdo_template_id;

    l_dunning_rec.object_type:= 'IEX_STRATEGY';
    --l_dunning_rec.dunning_method:= 'EMAIL';
    l_dunning_rec.object_id:= l_workitem_id;
    l_dunning_rec.org_id := v_org_id;

  --  set dunning_object_id and dunnint_level
    begin
      select decode(strategy_level, 10, 'CUSTOMER', 20, 'ACCOUNT', 30, 'BILL_TO', 40, 'DELINQUENCY', 'DELINQUENCY')
      into l_DefaultStrategyLevel
      from iex_strategies
      where strategy_id = l_strategy_id;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('resend_fulfillment Default StrategyLevel ' || l_DefaultStrategyLevel);
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                          iex_debug_pub.logmessage('Strategy Level Rised Exception ');
          END IF;
          l_DefaultStrategyLevel := 'DELINQUENCY';
    END;
    IF l_DefaultStrategyLevel = 'CUSTOMER'  THEN
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_party_id;
    elsif l_DefaultStrategyLevel = 'ACCOUNT' THEN
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_cust_account_id;
    elsif l_DefaultStrategyLevel = 'BILL_TO' THEN
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_customer_site_use_id;
    else
      l_dunning_rec.dunning_level:= l_DefaultStrategyLevel;
      l_dunning_rec.dunning_object_id:= l_delinquency_id;
    end if;

    begin
      select campaign_sched_id into l_campaign_sched_id from iex_delinquencies_all
        where delinquency_id = l_delinquency_id;
      l_dunning_rec.campaign_sched_id := l_campaign_sched_id;
      exception
      when others then
         l_dunning_rec.campaign_sched_id := null;
    end;

    -- close all the open dunning record before created
    FOR d_rec in c_get_dunning(l_workitem_id)
    LOOP
      begin
          l_dunning_rec_upd_old.dunning_id := d_rec.dunning_id;
          l_dunning_rec_upd_old.last_update_date := sysdate;
          l_dunning_rec_upd_old.callback_yn := 'N';
          l_dunning_rec_upd_old.status := 'SKIP';
          -- l_dunning_rec_upd_old.object_type:= 'WORK_ITEM';
          -- l_dunning_rec_upd_old.object_id:= l_workitem_id;

          IEX_DUNNING_PVT.Update_DUNNING(
                   p_api_version              => 1.0
                 , p_init_msg_list            => FND_API.G_FALSE
                 , p_commit                   => FND_API.G_FALSE
                 , p_dunning_rec              => l_dunning_rec_upd_old
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 );
      exception
      when others then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('close dunning before fulfillment exception');
END IF;
      end;
    END LOOP;

    -- ctlee - 6/18 fulfillment printer method available
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, before create dunning ' );
     END IF;
    IEX_DUNNING_PVT.CREATE_DUNNING(
        p_api_version              => 1.0
      , p_init_msg_list            => FND_API.G_FALSE
      , p_commit                   => FND_API.G_FALSE
      , p_dunning_rec              => l_dunning_rec
      , x_dunning_id               => l_dunning_id
      , x_return_status            => l_return_status
      , x_msg_count                => l_msg_count
      , x_msg_data                 => l_msg_data);
  -- end if;

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, before send_fulfillment ' );
END IF;


  -- call fulfilment function with multiple bind variables.
  if (l_curr_dmethod = 'FFM') then
    iex_dunning_pvt.send_fulfillment(
                           p_api_version             => 1.0,
                           p_init_msg_list           => FND_API.G_TRUE,
                           p_commit                  => FND_API.G_TRUE,
                           p_FULFILLMENT_BIND_TBL    => l_fulfillment_bind_tbl,
                           p_template_id             => l_template_id,
                           p_method                  => l_dunning_method,
                           p_party_id                => l_party_id,
                           p_user_id                 => l_user_id ,
                           x_return_status           => l_return_status,
                           x_msg_count               => l_msg_count,
                           x_msg_data                => l_msg_data,
                           x_REQUEST_ID              => l_request_id,
                           x_contact_destination     => l_contact_destination,  -- bug 3955222
                           x_contact_party_id        => l_contact_party_id);  -- bug 3955222
  else
    -- for now, resend to 'N' without request_id;  to send the old one 'Y' with request id
    iex_dunning_pvt.send_xml(
                           p_api_version             => 1.0,
                           p_init_msg_list           => FND_API.G_TRUE,
                           p_commit                  => FND_API.G_TRUE,
                           p_resend                  => 'N',
                           p_request_id              => null,
                           p_FULFILLMENT_BIND_TBL    => l_fulfillment_bind_tbl,
                           p_template_id             => l_xdo_template_id,
                           p_method                  => l_dunning_method,
                           p_user_id                 => l_user_id,
                           p_email                   => null,
                           p_party_id                => l_party_id,
                           p_level                   => l_dunning_rec.dunning_level,  -- strategy level
                           p_source_id               => l_dunning_rec.dunning_object_id, -- changed by gnramasa bug 5661324 14-Mar-07
                           p_object_code             => l_dunning_rec.object_type, -- 'IEX_STRATEGY'
                           p_object_id               => l_workitem_id,  -- changed for bug#8403051 by PNAVEENK on 3-4-2009 l_dunning_rec.dunning_object_id,  -- party/account/billto/del id
			   p_resource_id             => l_assign_resource_id, --Added for bug 7502980 05-Jan-2009 barathsr
                           p_org_id                  => l_dunning_rec.org_id, -- added for bug 9151851
			   x_return_status           => l_return_status,
                           x_msg_count               => l_msg_count,
                           x_msg_data                => l_msg_data,
                           x_REQUEST_ID              => l_request_id,
                           x_contact_destination     => l_contact_destination,  -- bug 3955222
                           x_contact_party_id        => l_contact_party_id);  -- bug 3955222
  end if;
   --- share a request id between xdo and ffm


   -- IEX_DEBUG_PUB.setDebugFileDir(P_FILEDIR => '/sqlcom/log', P_FILENAME =>'james.IEX');
   --IEX_DEBUG_PUB.setDebugFileDir(P_FILEDIR => '/sqlcom/log');


    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || ' in send mail, after send_fulfillment ' );
    END IF;

 -- return to workflow
  if (l_request_id is null OR l_return_status <> 'S') then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || 'request_id =>'|| l_request_id);
    END IF;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || 'return_status =>'|| l_return_status);
    END IF;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || 'msg_count =>' || l_msg_count);
    END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || 'msg_data =>');
    END IF;
    FOR l_index IN 1..l_msg_count LOOP
         my_message := FND_MSG_PUB.Get(p_msg_index => l_index,
                                       p_encoded => 'F');
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage ('resend_fulfillment: ' || my_message);
         END IF;
    END LOOP;
    x_error_message := my_message;
  else
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || 'request_id =>'|| l_request_id);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || 'return_status =>'|| l_return_status);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('resend_fulfillment: ' || 'msg_count =>' || l_msg_count);
    END IF;

    x_status :=  'S';
    x_request_id := l_request_id;

                 l_dunning_rec_upd.dunning_id := l_dunning_id;
                 l_dunning_rec_upd.last_update_date := sysdate;
                 l_dunning_rec_upd.callback_yn := 'N';
                 l_dunning_rec_upd.status := 'CLOSE';
                 --  ctlee xdo template id
                 if (l_curr_dmethod = 'FFM') then
                    l_dunning_rec_upd.ffm_request_id := l_request_id;
                 else
                    l_dunning_rec_upd.xml_request_id := l_request_id;
                 end if;
                 l_dunning_rec_upd.contact_destination := l_contact_destination;  -- bug 3955222
                 l_dunning_rec_upd.contact_party_id := l_contact_party_id;  -- bug 3955222

                 IEX_DUNNING_PVT.Update_DUNNING(
                   p_api_version              => 1.0
                 , p_init_msg_list            => FND_API.G_FALSE
                 , p_commit                   => FND_API.G_FALSE
                 , p_dunning_rec              => l_dunning_rec_upd
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 );
  end if;

  return;
EXCEPTION WHEN OTHERS THEN
    null;
END  resend_fulfillment;

--Start schekuri Bug#4506922 Date:02-Dec-2005
--added for the function WAIT_ON_HOLD_SIGNAL in workflow IEXSTFFM
procedure wait_on_hold_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('**** START wait_on_hold_signal ************');
END IF;
    if funcmode <> wf_engine.eng_run then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('SECOND TIME FUNCMODE' ||funcmode);
END IF;
        result := wf_engine.eng_null;
        return;
    end if;



IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage('FUNCMODE' ||funcmode);
END IF;
/*      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('ACTIVITYNAME' ||l_value);
END IF;*/


   result := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** END wait_on_hold_signal ************');
END IF;
 exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WORK_PUB','wait_on_hold_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  wait_on_hold_signal;

--end schekuri Bug#4506922 Date:02-Dec-2005


procedure wait_delivery_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('**** START wait_delivery_signal ************');
END IF;
    if funcmode <> wf_engine.eng_run then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('SECOND TIME FUNCMODE' ||funcmode);
END IF;
        result := wf_engine.eng_null;
        return;
    end if;



IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage('FUNCMODE' ||funcmode);
END IF;
      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('ACTIVITYNAME' ||l_value);
END IF;


   result := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** END wait_delivery_signal ************');
END IF;
 exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WORK_PUB','wait_delivery_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  wait_delivery_signal;

procedure cal_delivery_wait(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2) IS

l_schedule date;
l_wait_days number;
l_return VARCHAR2(1);
l_value VARCHAR2(300);
l_workitem_status varchar2(300);

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** START cal_pre_wait ************');
END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

        l_wait_days:=nvl(fnd_profile.value('IEX_DELIVERY_WAIT_DAYS'),0);

	 l_workitem_status := wf_engine.GetItemAttrText(Itemtype => itemtype,
							  Itemkey => itemkey,
							   aname => 'WK_STATUS');

	l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('Number of days to wait after submitting delivery request = ' ||l_wait_days);
        END IF;

         if (l_wait_days = 0 or l_workitem_status = 'SKIP') then
           l_return := wf_no;
         else
           l_schedule:= sysdate+l_wait_days;
	   wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'DELIVERY_WAIT_TIME',
                                 avalue    => l_schedule);
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.logMessage('Letter Delivery wait time = ' || to_char(l_schedule, 'hh24:mi:ss mm/dd/yyyy'));
           END IF;
           l_return := wf_yes;
         END IF;


        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logMessage('Collections cal_delivery_wait result = ' ||l_return);
        END IF;

       result := wf_engine.eng_completed ||':'||l_return;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage ('Collections **** END cal_delivery_wait ************');
        END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WORK_PUB','cal_delivery_wait',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;



END  cal_delivery_wait;

procedure send_delivery_signal(
			p_xml_request_id IN NUMBER,
			p_status IN varchar2,
			x_error_message out NOCOPY varchar2) is
l_activity_label varchar2(500);
l_work_item_id number;
l_return_status     VARCHAR2(20);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

begin
	iex_debug_pub.logmessage('Collections **** BEGIN send_delivery_signal ************');

	IF NVL(fnd_profile.value('IEX_DELIVERY_WAIT_DAYS'),0)=0 THEN
		iex_debug_pub.logmessage('Collections **** send_delivery_signal : Value of profile IEX: Workitem waiting time in days to get delivery status is 0 ************');
		return;
	END IF;

	BEGIN
		select dun.object_id
		into l_work_item_id
		from iex_dunnings dun,
		iex_strategy_work_items wi
		where dun.object_id=wi.work_item_id
		and dun.object_type='IEX_STRATEGY'
		and wi.status_code in ('OPEN','INERROR_CHECK_NOTIFY')
		and dun.xml_request_id=p_xml_request_id;
		l_activity_label := wf_engine.GetItemAttrText(itemtype  => 'IEXSTFFM',
							      itemkey   => l_work_item_id,
							      aname     => 'ACTIVITY_NAME');
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
        iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.SEND_DELIVERY_SIGNAL:Unable to find work item id corresponding to xml request id '||p_xml_request_id);
	RETURN;
	WHEN OTHERS THEN
	      iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.SEND_DELIVERY_SIGNAL:Exception'|| SQLERRM ||' while finding work item id corresponding to xml request id '||p_xml_request_id);
	RETURN;
	END;
	iex_debug_pub.logmessage('Activity label='||l_activity_label);
	IF l_activity_label = 'IEXSTFFM:WAIT_DELIVERY_SIGNAL' and l_work_item_id is not null then
		IF p_status = 'SUCCESS' THEN
		iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.SEND_DELIVERY_SIGNAL:Sending Success Signal');
		wf_engine.CompleteActivity(itemtype    => 'IEXSTFFM',
                                           itemkey     => l_work_item_id,
                                           activity    =>l_activity_label,
                                           result      =>'#DEFAULT');
		iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.SEND_DELIVERY_SIGNAL:Sent Success Signal');
		ELSE
		iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.SEND_DELIVERY_SIGNAL:Sending Failure Signal');
		wf_engine.SetItemAttrText(itemtype  => 'IEXSTFFM',
                             itemkey   =>l_work_item_id,
                             aname     => 'WK_STATUS',
                             avalue    => 'INERROR');

                iex_stry_utl_pub.update_work_item(
                           p_api_version   => 1.0,
                           p_commit        => FND_API.G_TRUE,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_work_item_id  => l_work_item_id,
                           p_status        => 'INERROR_CHECK_NOTIFY',
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data
                           );

		wf_engine.CompleteActivity(itemtype    => 'IEXSTFFM',
                                           itemkey     => l_work_item_id,
                                           activity    =>l_activity_label,
                                           result      =>'#TIMEOUT');
		iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.SEND_DELIVERY_SIGNAL:Sent Failure Signal');
		END IF;
	END IF;
	COMMIT;
	iex_debug_pub.logmessage('Collections **** END send_delivery_signal ************');
EXCEPTION
WHEN OTHERS THEN
	x_error_message:='Exception:'||SQLERRM;
	iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.SEND_DELIVERY_SIGNAL:::Exception:::'||SQLERRM);
END SEND_DELIVERY_SIGNAL;


PROCEDURE auto_retry_notifications(p_from_date in date,
                                   x_error_message out NOCOPY varchar2) IS
cursor c_error_workitems(l_from_date date) is
select wi.work_item_id work_item_id
from iex_dunnings dun,
iex_strategy_work_items wi,
iex_xml_request_histories xrh
where dun.object_id=wi.work_item_id
and xrh.object_type='IEX_STRATEGY'
and xrh.creation_date>=nvl(l_from_date,xrh.creation_date)
and dun.xml_request_id=xrh.xml_request_id
and xrh.status not in ('SUCCESSFUL','SUCCESSFUL WITH WARNINGS','OPEN','CANCELLED')
and wi.status_code in ('INERROR_CHECK_NOTIFY');

cursor c_notification(p_context varchar2) is
select notification_id from wf_notifications
where message_type='IEXSTFFM'
and MESSAGE_NAME='SEND FAILER MESSAGE'
and status='OPEN'
AND context like p_context; -- 'IEXSTFFM:14515%' ;

BEGIN
	iex_debug_pub.logmessage('Collections **** BEGIN auto_retry_notifications ************');

	IF NVL(fnd_profile.value('IEX_DELIVERY_WAIT_DAYS'),0)=0 THEN
		iex_debug_pub.logmessage('Collections **** auto_retry_notifications : Value of profile IEX: Workitem waiting time in days to get delivery status is 0 ************');
		return;
	END IF;

        for rec_error_wi in c_error_workitems(p_from_date) loop
	     iex_debug_pub.logmessage('Collections **** Before retrying notifications for work item :'||rec_error_wi.work_item_id||'************');
	     for rec_notif in c_notification('IEXSTFFM:'||rec_error_wi.work_item_id||':%') loop
	        begin
		wf_notification.setattrtext ( nid => rec_notif.notification_id
                                , aname => 'RESULT'
                                , avalue => 'RETRY' );

		WF_NOTIFICATION.respond(nid =>rec_notif.notification_id,
					respond_comment=>'Response sent by IEX: Bulk XML Delivery Manager cp');
		exception
		when others then
			iex_debug_pub.logmessage('Collections **** Erro auto retrying notifications with id :'||rec_notif.notification_id||'************');
		end;
	     end loop;
             iex_debug_pub.logmessage('Collections **** After retrying notifications for work item :'||rec_error_wi.work_item_id||'************');
	     commit;
	end loop;

	iex_debug_pub.logmessage('Collections **** END auto_retry_notifications ************');
EXCEPTION
WHEN OTHERS THEN
x_error_message:='Exception:'||SQLERRM;
iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.auto_retry_notifications:::Exception:::'||SQLERRM);
END auto_retry_notifications;

procedure delivery_failed(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2) is
l_work_item_id number;
l_return_status     VARCHAR2(20);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
   l_failure_reason varchar2(2000);

BEGIN
if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_work_item_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'WORKITEM_ID');
  if l_work_item_id is not null then
      begin
        iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.DELIVERY_FAILED:updating status of xml request for work item '||l_work_item_id);
	update iex_xml_request_histories
	set status='OTHER PROCESSING FAILURE',
	failure_reason='Request status timed out'
	where object_type='IEX_STRATEGY'
	--and status<>'CANCELLED'
	and status in ('IN PROCESS','XMLDATA','XMLDOC')
	and xml_request_id in (select xml_request_id
	                       from iex_dunnings
			       where object_type='IEX_STRATEGY'
			       and object_id=l_work_item_id);

        wf_engine.SetItemAttrText(itemtype  => 'IEXSTFFM',
                             itemkey   =>l_work_item_id,
                             aname     => 'WK_STATUS',
                             avalue    => 'INERROR');

                iex_stry_utl_pub.update_work_item(
                           p_api_version   => 1.0,
                           p_commit        => FND_API.G_TRUE,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_work_item_id  => l_work_item_id,
                           p_status        => 'INERROR_CHECK_NOTIFY',
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data
                           );

       result := wf_engine.eng_completed;

        -- Start for the bug#8435665 by PNAVEENK on 15-May-2009
       select failure_reason into l_failure_reason from iex_xml_request_histories where xml_request_id = (select max(xml_request_id) from
                                                                                                          iex_dunnings
			                                                                                  where object_type='IEX_STRATEGY'
			                                                                                  and object_id=l_work_item_id)
													  and failure_reason is not null;
       if l_failure_reason is not null then

          wf_engine.SetItemAttrText(itemtype  => 'IEXSTFFM',
                             itemkey   =>l_work_item_id,
                             aname     => 'FAILURE_REASON',
                             avalue    => l_failure_reason);
       end if;
       -- End for the bug#8435665

      exception
        when others then
        iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.DELIVERY_FAILED:exception while updating status of xml request'||SQLERRM);
      end;

  end if;
EXCEPTION
WHEN OTHERS THEN
iex_debug_pub.logmessage('IEX_STRATEGY_WORK_PUB.DELIVERY_FAILED:exception'||SQLERRM);
result := wf_engine.eng_completed ||':'||NULL;
  wf_core.context('IEX_STRATEGY_WORK_PUB','delivery_failed',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
END delivery_failed;



begin
  -- initialize variables
  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  --begin schekuri Bug#4506922 Date:02-Dec-2005
  wf_yes      := 'Y';
  wf_no       := 'N';
  --end schekuri Bug#4506922 Date:02-Dec-2005

end IEX_STRATEGY_WORK_PUB;


/
