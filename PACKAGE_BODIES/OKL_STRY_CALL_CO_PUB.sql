--------------------------------------------------------
--  DDL for Package Body OKL_STRY_CALL_CO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STRY_CALL_CO_PUB" as
/* $Header: OKLPCWFB.pls 115.3 2002/12/18 03:48:40 rabhupat noship $ */
-- Start of Comments
-- Package name     : OKL_STRY_CALL_CO_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT    VARCHAR2(100):=  'OKL_STRY_CALL_CO_PUB ';
G_FILE_NAME     CONSTANT    VARCHAR2(50) := 'OKLPCWFB.pls';

/*
* wait for 10 mts before sending response back to the strategy engine
*/
procedure set_wait_period ( itemtype in varchar2,
                            itemkey in varchar2) is
l_wait_period DATE;
Begin

         select sysdate + 10/24/60 into l_wait_period  from dual;

         wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname     => 'WAIT_PERIOD',
                                      avalue    => l_wait_period);

end set_wait_period;

/* Gets email for given party ID
 *
 */
PROCEDURE GET_PARTY_EMAIL (l_party_id IN NUMBER,
                           x_email OUT NOCOPY VARCHAR2) IS

 CURSOR C_GET_ORG_EMAIL (p_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_PARTIES
       WHERE party_ID =p_party_ID;

    CURSOR C_GET_CONTACT_EMAIL (p_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = p_party_ID
         AND Contact_point_type = 'EMAIL'
         AND primary_flag = 'Y';



l_email            HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;


BEGIN

      --set email address of the customer
       --get contact email or if contact is null ,
       --get org email address.
        Open C_Get_CONTACT_EMAIL(l_party_id);
        FETCH c_get_contact_email INTO l_email;
        CLOSE c_get_contact_email;
        If l_email is NULL THEN
           Open  C_Get_ORG_EMAIL(l_party_id);
           Fetch C_Get_ORG_EMAIL into l_email;
           CLOSE C_Get_ORG_EMAIL;
        End if;
        x_email :=l_email;

END GET_PARTY_EMAIL;


/** get user name
 * this will used to send the notification
**/

procedure get_username
                       ( p_resource_id IN NUMBER,
                         x_username    OUT NOCOPY VARCHAR2 ) IS
cursor c_getname(p_resource_id NUMBER) is
Select user_name
from jtf_rs_resource_extns
where resource_id =p_resource_id;

BEGIN
     OPEN c_getname(p_resource_id);
     FETCH c_getname INTO x_username;
     CLOSE c_getname;

END get_username;

-----populate set_notification_resources---------------------------------
procedure set_notification_resources(
            p_resource_id       in number,
            itemtype            in varchar2,
            itemkey             in varchar2
           ) IS
l_username VARCHAR2(100);
l_mgrname  VARCHAR2(100);
l_mgr_resource_id NUMBER ;
BEGIN

     -- get user name from  jtf_rs_resource_extns
     get_username
        ( p_resource_id =>p_resource_id,
          x_username    =>l_username);

     wf_engine.SetItemAttrText(itemtype  => itemtype,
                               itemkey   => itemkey,
                               aname     => 'NOTIFICATION_USERNAME',
                               avalue    =>  l_username);
  exception
  when others then
       null;

END  set_notification_resources;





-----PUBLIC Procedures--------------------------------

/**
get the most delinquent contract from a
case based on the no of days due
*/

PROCEDURE get_delinquent_contract(
     p_case_id		  IN NUMBER,
     x_contract_id OUT NOCOPY NUMBER,
     x_days        OUT NOCOPY NUMBER) IS

l_status      VARCHAR(1);
--x_days        NUMBER := 0;
x_greatest    NUMBER := 0;
cursor c_contracts(p_case_id IN NUMBER) is
select object_id from iex_case_objects
where cas_id =p_case_id ;
BEGIN
      FOR c_rec in c_contracts(p_case_id)
      LOOP
          l_status := okl_contract_info.
                      get_days_past_due(c_rec.object_id,x_days);
          if x_days >= x_greatest THEN
            x_contract_id :=c_rec.object_id;
            x_greatest := x_days;
          end if;
     END LOOP;
     x_days :=x_greatest;
EXCEPTION WHEN OTHERS THEN
x_contract_id := 0;
x_days :=0;
END get_delinquent_contract;

   ---------------------------------------------------------------------------
  -- PROCEDURE get_vendor_info
  ---------------------------------------------------------------------------
  PROCEDURE get_vendor_info(p_case_number in varchar2,
                         x_vendor_id   out nocopy number,
                         x_vendor_name out nocopy varchar2,
                         x_vendor_email out nocopy varchar2,
                         x_return_status out nocopy varchar2) AS

    --get vendor info
    CURSOR l_vendor_csr(cp_case_number IN VARCHAR2) IS SELECT pv.vendor_id
           ,pv.vendor_name
           --,pvs.email_address
     FROM  iex_cases_all_b ica
          ,iex_case_objects ico
          ,okc_k_party_roles_v opr
          ,po_vendors pv
          --,po_vendor_sites_all pvs
     WHERE ica.case_number = cp_case_number
     AND   ica.cas_id = ico.cas_id
     AND   ico.object_id =opr.dnz_chr_id
     AND   opr.rle_code = 'OKL_VENDOR'
     AND   opr.object1_id1 = pv.vendor_id;
     --AND   pv.vendor_id = pvs.vendor_id;

    --get contracts on case
    CURSOR l_khr_csr(cp_case_number IN VARCHAR2) IS SELECT ico.object_id
    , okh.contract_number
    FROM iex_cases_all_b ica
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ica.case_number = cp_case_number
    AND ica.cas_id = ico.cas_id
    AND ico.object_id = okh.id;

    --get program id to get the vendor sites id
    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;

    --get vendor email address
    CURSOR l_email_csr(cp_vendor_site_code IN VARCHAR2) IS
    SELECT pvs.email_address
    FROM po_vendor_sites_all pvs
    WHERE pvs.vendor_site_code = cp_vendor_site_code;

    l_id1 VARCHAR2(200) := NULL;
    l_id2 VARCHAR2(200) := NULL;
    l_vendor_site_code VARCHAR2(200) := null;
    l_return_status VARCHAR2(1);
  BEGIN
    --get sendto_third_party flag
    FOR cur_khr IN l_khr_csr(p_case_number) LOOP
      FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
          l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COVNAG'
                                          -- ,p_rule_name => 'Vendor location'
                                            ,p_segment_number => 1
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id2
                                           ,x_value => l_vendor_site_code);

          IF(l_vendor_site_code IS NOT NULL) THEN
            EXIT;
          END IF;
        END LOOP
        EXIT;
    END LOOP;

    FOR cur_email IN l_email_csr(l_vendor_site_code) LOOP
      x_vendor_email := cur_email.email_address;
    END LOOP;

    FOR cur IN l_vendor_csr(p_case_number) LOOP
      x_vendor_id := cur.vendor_id;
      x_vendor_name := cur.vendor_name;
      --x_vendor_email := cur.email_address;
      EXIT;
    END LOOP;
  END get_vendor_info;


/**
  * send an email thru fulfilment
  * right now the okl fulfilment api supports email
  * only
 **/

procedure  send_fulfilment(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out nocopy  varchar2)
IS

l_work_item_id     number;
l_strategy_id      number;
l_party_id         number;
l_delinquency_id   NUMBER;
l_contract_id      NUMBER;

l_return_status    VARCHAR2(20);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_error            VARCHAR2(32767);

l_api_version      CONSTANT NUMBER := 1;

l_email            HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
l_subject          VARCHAR2(2000);
l_from             VARCHAR2(2000);
l_agent_id         NUMBER := to_number(fnd_profile.value('OKL_FULFILLMENT_USER'));
l_request_id       NUMBER;

l_content_id       JTF_AMV_ITEMS_B.ITEM_ID%TYPE :=
                         to_number(fnd_profile.value('OKL_VND_APPROVAL_TEMPLATE'));
l_content_name     JTF_FM_TEMPLATE_CONTENTS.content_name%TYPE;
l_bind_var         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_val         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_var_type    JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;



-- get contract id for this strategy
-- this contract id will be used as the
--bind variable for fullfillment template.

cursor c_get_case_number (p_delinquency_id IN NUMBER) is
select c.case_number  from iex_cases_all_b c,iex_Delinquencies_all d
where c.cas_id=d.case_id
and   d.delinquency_id =p_delinquency_id;

l_case_number              IEX_CASES_ALL_B.CASE_NUMBER%TYPE;
l_vendor_id                PO_VENDORS.VENDOR_ID%TYPE;
l_vendor_name              PO_VENDORS.VENDOR_NAME%TYPE;

Begin

      if funcmode <> 'RUN' then
         result := wf_engine.eng_null;
         return;
      end if;

      l_work_item_id := wf_engine.GetItemAttrNumber(
                                               itemtype  => itemtype,
                                               itemkey   => itemkey,
                                               aname     => 'WORK_ITEMID');

      l_strategy_id := wf_engine.GetItemAttrNumber(
                                             itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => 'STRATEGY_ID');

      l_party_id := wf_engine.GetItemAttrNumber(
                                             itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => 'PARTY_ID');

      l_delinquency_id := wf_engine.GetItemAttrNumber(
                                             itemtype  => itemtype,
                                             itemkey   => itemkey,
                                              aname     => 'DELINQUENCY_ID');

      l_email := wf_engine.GetItemAttrText(
                                             itemtype  => itemtype,
                                             itemkey   => itemkey,
                                              aname     => 'PARTY_EMAIL');









      -- 08/16/02
       --- populate l_agent from the profile okl_fulfillment_user
       -- l_agent_id := FND_GLOBAL.USER_ID;
        --l_agent_id :=1001646;


       -- populate from to
   	   l_from := fnd_profile.value('OKL_VND_APPROVAL_EMAIL_FROM');

       If l_from is null THEN
            result := wf_engine.eng_completed ||':'||wf_no;
            return;
       end if;

       --populate l_subject
         l_subject := fnd_profile.value('OKL_VND_APPROVAL_EMAIL_SUBJECT');
         if l_subject is null THEN
            l_subject := 'Vendor Approval needed for strategy '
                          ||l_strategy_id || ' and Work item '||l_work_item_id;
         end if;



     -- populate  bind variables

      OPEN c_get_case_number(l_delinquency_id);
      FETCH c_get_case_number INTO l_case_number;
      CLOSE c_get_case_number;

      --get vendor email address
      -- get vendor_info
      -- don't get vendor info if custom workflow
      -- is write to customer. the email is picked from the hz_parties
      --table and is already set in the attribute PARTY_EMAIL.

     if l_email is NULL THEN
         get_vendor_info(p_case_number => l_case_number,
                      x_vendor_id  => l_vendor_id,
                      x_vendor_name => l_vendor_name,
                      x_vendor_email => l_email,
                      x_return_status => l_return_status);

      end if;
     --set vendor_name
     wf_engine.SetItemAttrText(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'VENDOR_NAME',
                                 avalue    =>  l_vendor_name);

       -- for the time being set as 'sanju.john@oracle.com
       if l_email is NULL THEN
            result := wf_engine.eng_completed ||':'||wf_no;
            return;
       end if;

       if itemtype ='OKLCOWRI' THEN
             l_content_id :=to_number(fnd_profile.value('OKL_WRITE_CUST_TEMPLATE'));
       end if;

       If l_content_id is null THEN
            result := wf_engine.eng_completed ||':'||wf_no;
            return;
       end if;


      l_bind_var(1) := 'p_case_number';
      l_bind_val(1) := l_case_number;
      l_bind_var_type(1) := 'VARCHAR2';



        OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version   => l_api_version,
                              p_init_msg_list => fnd_api.G_TRUE,
                              p_agent_id      => l_agent_id,
                              p_content_id    => l_content_id,
                              p_from          => l_from,
                              p_subject       => l_subject,
                              p_email         => l_email,
                              p_bind_var      => l_bind_var,
                              p_bind_val      => l_bind_val,
                              p_bind_var_type => l_bind_var_type,
                              p_commit        => fnd_api.G_FALSE,
                              x_request_id    => l_request_id,
                              x_return_status => l_return_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data);


      if l_return_status <>FND_API.G_RET_STS_SUCCESS THEN
         result := wf_engine.eng_completed ||':'||wf_no;
     else
         result := wf_engine.eng_completed ||':'||wf_yes;
         if itemtype ='OKLCOWRI' THEN
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname     => 'WK_STATUS',
                                      avalue    => 'COMPLETE');
         end if;
     end if;


EXCEPTION
when others then
  wf_core.context('OKL_STRY_CALL_CO_PUB',' send_fulfilment',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
end  send_fulfilment;


/** send signal to the main work flow that the custom work
 *  flow is over and also updates the work item
 * the send signal is send when the agent REJECTS the
 * notification since the vendor didn't approve it ,
 * so set the status to 'CANCELLED'.
 **/

procedure wf_send_signal(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out nocopy  varchar2)
IS

l_work_item_id      number;
l_strategy_id       number;
l_return_status     VARCHAR2(20);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
exc                 EXCEPTION;

l_error              VARCHAR2(32767);
l_user_id            NUMBER;
l_resp_id            NUMBER;
l_resp_appl_id       NUMBER;
l_wk_status varchar2(20);
Begin
  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_work_item_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'WORK_ITEMID');

  l_strategy_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_ID');


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

  --set the session
  --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);

 l_wk_status := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'WK_STATUS');


  if (l_work_item_id is not null) then

    iex_stry_utl_pub.update_work_item(
                           p_api_version   => 1.0,
                           p_commit        => FND_API.G_FALSE,
                           p_init_msg_list => FND_API.G_FALSE,
                           p_work_item_id  => l_work_item_id,
                           p_status        => l_wk_status,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data
                           );

     if l_return_status =FND_API.G_RET_STS_SUCCESS THEN
       iex_strategy_wf.send_signal(
                         process    => 'IEXSTRY' ,
                         strategy_id => l_strategy_id,
                         status      => 'CANCELLED',
                         work_item_id => l_work_item_id,
                         signal_source =>'CUSTOM');


   end if; -- if update is succcessful;
 end if;

 result := wf_engine.eng_completed;

exception
WHEN EXC THEN
     --pass the error message
      -- get error message and pass
      iex_strategy_wf.Get_Messages(l_msg_count,l_error);
      wf_core.context('OKL_STRY_CALL_CO_PUB','wf_send_signal',itemtype,
                   itemkey,to_char(actid),funcmode,l_error);
     raise;

when others then

  wf_core.context('OKL_STRY_CALL_CO_PUB','wf_send_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
end wf_send_signal;




  ---------------------------------------------------------------------------
  -- PROCEDURE get_vendorapproval_flag
  ---------------------------------------------------------------------------
  PROCEDURE get_vendorapproval_flag(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_vendorapproval_flag VARCHAR2(10) := NULL;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    , okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;


   l_resource_id   NUMBER;
   l_wait_date     DATE;

   cursor c_stry_wkitems (p_workitemid NUMBER) is
   select resource_id from iex_strategy_work_items
   where work_item_id =p_workitemid;

BEGIN

      if funcmode <> 'RUN' then
         result := wf_engine.eng_null;
         return;
      end if;

    --call api get vendor approval
    --get resource_id from iex_strategy_work_items
     OPEN c_stry_wkitems(itemkey);
     FETCH c_stry_wkitems INTO l_resource_id;
     CLOSE c_stry_wkitems;

    --set notification resource for the reminder notification
    --this person approves or rejects the notification

       set_notification_resources(
                    p_resource_id   =>l_resource_id,
                    itemtype        => itemtype,
                    itemkey         => itemkey);


	l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');
        --get vendorapproval flag
          FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
               FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                   l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                           p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COCALL'
                                        --   ,p_rule_name =>
                             -- 'Vendor approval required to call customer?'
                                           ,p_segment_number => 3
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_vendorapproval_flag);

                    IF(l_vendorapproval_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                END LOOP
                EXIT;
            END LOOP;

            l_vendorapproval_flag := UPPER(NVL(l_vendorapproval_flag, 'No'));

            IF(l_vendorapproval_flag = 'YES') THEN
                  l_vendorapproval_flag := 'Y';
            ELSE
                 l_vendorapproval_flag := 'N';
            END IF;
             result := 'COMPLETE:' || l_vendorapproval_flag;


  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','get_vendorapproval_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_vendorapproval_flag;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_notification_flag
  ---------------------------------------------------------------------------
  PROCEDURE get_notification_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_notification_flag VARCHAR2(10) := NULL;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    , okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;



  BEGIN

         if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
         end if;
     	l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');

        set_wait_period(itemtype,itemkey);
                --get notification_flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COCALL'
                                         --  ,p_rule_name =>
                               --'Call non-notification customer?'
                                           ,p_segment_number => 1
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_notification_flag);

                    IF(l_notification_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

                l_notification_flag := UPPER(NVL(l_notification_flag, 'No'));

                IF(l_notification_flag = 'YES') THEN
                  l_notification_flag := 'Y';
                ELSE
                  l_notification_flag := 'N';
                END IF;
                result := 'COMPLETE:' || l_notification_flag;



  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','get_notification_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_notification_flag;



  ---------------------------------------------------------------------------
  -- PROCEDURE check_days_past_due
  ---------------------------------------------------------------------------
  PROCEDURE check_days_past_due(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_noofdays      NUMBER :=0;
    l_actualdays    NUMBER :=0;
    l_contract_id   NUMBER;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;
    l_case_id NUMBER;
    l_days_after_ven_approval NUMBER;

   /* CURSOR l_khr_csr(p_contract_id IN NUMBER)
    IS SELECT  contract_number
    FROM    okc_k_headers_b
    WHERE    id = p_contract_id;
    */

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS
    SELECT ico.object_id, okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;

    cursor c_get_case_id (p_delinquency_id IN NUMBER) is
    select case_id from
    iex_Delinquencies_all d
    where delinquency_id =p_delinquency_id;

  BEGIN

         if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
         end if;
     	 l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');

         OPEN c_get_case_id(l_delinquency_id);
         FETCH c_get_case_id INTO l_case_id;
         CLOSE c_get_case_id;

         get_delinquent_contract (l_case_id,l_contract_id,l_actualdays);

                --get no of days
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COCALL'
                                           --,p_rule_name =>
                               --'Number of days after due date to call customer'
                                          ,p_segment_number => 2
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_noofdays);

                    IF(l_noofdays IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

          l_noofdays := NVL(l_noofdays,0);

  		 if l_actualdays > l_noofdays THEN
                   result := 'COMPLETE:' || 'Y';
         else
                   result := 'COMPLETE:' || 'N';
         end if;

        --get no of days after getting vendor approval
        --send this number in the agents email
              FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                       l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COCALL'
                                           --,p_rule_name =>
                              -- 'Number of days after vendor approval to call customer'
                                            ,p_segment_number => 4
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value =>  l_days_after_ven_approval);

                  IF(l_days_after_ven_approval IS NOT NULL) THEN
                      --set the workflow attribute
                      --set workitem_template_id attribute
                      wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'CALL_VENDOR_DAYS',
                                   avalue    => l_days_after_ven_approval);

                      EXIT;
                  END IF;
                END LOOP
                EXIT;
            END LOOP;


  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','check_days_past_due',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END check_days_past_due;


  ---------------------------------------------------------------------------
  -- PROCEDURE lessor_VISIT_FLAG
  ---------------------------------------------------------------------------
  PROCEDURE get_lessor_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_lessor_flag VARCHAR2(10) := NULL;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    , okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;

  BEGIN

         if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
         end if;
     	l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');

        set_wait_period(itemtype,itemkey);

                --get lessor_flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COVIST'
                                          -- ,p_rule_name =>
                               --'Lessor allowed to visit customer?'
                                            ,p_segment_number => 1
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_lessor_flag);

                    IF(l_lessor_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

                l_lessor_flag := UPPER(NVL(l_lessor_flag, 'No'));

                IF(l_lessor_flag = 'YES') THEN
                  l_lessor_flag := 'Y';
                ELSE
                  l_lessor_flag := 'N';
                END IF;
                result := 'COMPLETE:' || l_lessor_flag;



  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','get_lessor_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_lessor_flag;



  ---------------------------------------------------------------------------
  -- PROCEDURE Customer_VISIT_FLAG
  ---------------------------------------------------------------------------
  PROCEDURE get_Customer_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_Customer_flag VARCHAR2(10) := NULL;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    , okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;

  BEGIN

         if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
         end if;
     	l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');

                --get Customer_flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COVIST'
                                           --,p_rule_name =>
                               --'Vendor allowed to visit customer?'
                                            ,p_segment_number => 2
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_Customer_flag);

                    IF(l_Customer_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

                l_Customer_flag := UPPER(NVL(l_Customer_flag, 'No'));

                IF(l_Customer_flag = 'YES') THEN
                  l_Customer_flag := 'Y';
                ELSE
                  l_Customer_flag := 'N';
                END IF;
                result := 'COMPLETE:' || l_Customer_flag;



  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','get_Customer_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_Customer_flag;

 ---------------------------------------------------------------------------
  -- PROCEDURE get_Vendor_approval_flag
  ---------------------------------------------------------------------------
  PROCEDURE get_Vendor_approval_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_Vendor_Customer_flag VARCHAR2(10) := NULL;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    , okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;

  BEGIN

         if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
         end if;
     	l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');

                --get Vendor_Customer_flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COVIST'
                                           --,p_rule_name =>
                               --'Vendor approval required to visit customer?'
                                           ,p_segment_number => 3
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_Vendor_Customer_flag);

                    IF(l_Vendor_Customer_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

                l_Vendor_Customer_flag := UPPER(NVL(l_Vendor_Customer_flag, 'No'));

                IF(l_Vendor_Customer_flag = 'YES') THEN
                  l_Vendor_Customer_flag := 'Y';
                ELSE
                  l_Vendor_Customer_flag := 'N';
                END IF;
                result := 'COMPLETE:' || l_Vendor_Customer_flag;





  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','get_Vendor_approval_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_Vendor_approval_flag;

  --------------------------------------------------------------------------
  -- PROCEDURE Vend_Cust_NOTIFY
  ---------------------------------------------------------------------------
  PROCEDURE get_Vend_Cust_NOTIFY_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_Vend_cust_notify_flag VARCHAR2(10) := NULL;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    , okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;

  BEGIN

         if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
         end if;
     	l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');

                --get Vend_cust_notify_flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COVIST'
                                           --,p_rule_name =>
                             --'Vendor notification required prior to customer visit?'
                                           ,p_segment_number => 4
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_Vend_cust_notify_flag);

                    IF(l_Vend_cust_notify_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

                l_Vend_cust_notify_flag := UPPER(NVL(l_Vend_cust_notify_flag, 'No'));

                IF(l_Vend_cust_notify_flag = 'YES') THEN
                  l_Vend_cust_notify_flag := 'Y';
                ELSE
                  l_Vend_cust_notify_flag := 'N';
                END IF;
                result := 'COMPLETE:' || l_Vend_cust_notify_flag;



  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','get_Vend_cust_notify_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_Vend_cust_notify_flag;



  ---------------------------------------------------------------------------
  -- PROCEDURE Days to take notice of assignment for Syndicated Account?
  ---------------------------------------------------------------------------
  PROCEDURE check_days_for_syn_acct(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    result       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_noofdays      NUMBER :=0;
    l_actualdays    NUMBER :=0;
    l_contract_id   NUMBER;
    l_id1 VARCHAR2(200) := NULL;

    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;
    l_case_id NUMBER;
    l_days_after_ven_approval NUMBER;

    /* CURSOR l_khr_csr(p_contract_id IN NUMBER)
    IS SELECT  contract_number
    FROM    okc_k_headers_b
    WHERE    id = p_contract_id;
    */

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS
    SELECT ico.object_id, okh.contract_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,okc_k_headers_b okh
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = okh.id;

    CURSOR l_rule_csr(cp_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,rgp.dnz_chr_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COAGRM'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number = cp_contract_number;

    cursor c_get_case_id (p_delinquency_id IN NUMBER) is
    select case_id from
    iex_Delinquencies_all d
    where delinquency_id =p_delinquency_id;



l_status          VARCHAR2(1);
x_syndicate_flag  VARCHAR2(1) DEFAULT 'N';
l_party_id         number;
l_email            HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;

  BEGIN

         if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
         end if;



     	 l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
				                       	itemkey	=> itemkey,
                                        aname  	=> 'DELINQUENCY_ID');

         l_party_id := wf_engine.GetItemAttrNumber(
                                             itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => 'PARTY_ID');

         OPEN c_get_case_id(l_delinquency_id);
         FETCH c_get_case_id INTO l_case_id;
         CLOSE c_get_case_id;

         get_delinquent_contract (l_case_id,l_contract_id,l_actualdays);

         set_wait_period(itemtype,itemkey);

         l_status := okl_contract_info.
                     get_syndicate_flag(l_contract_id, x_syndicate_flag);

        IF l_status = 'Y' THEN
                --get no of days
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COWRIT'
                                           --,p_rule_name =>
                               --'Days to take notice of assignment for Syndicated Account?'
                                           ,p_segment_number => 1
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_noofdays);

                    IF(l_noofdays IS NOT NULL) THEN
                      --set the workflow attribute
                      --set workitem_template_id attribute
                      wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'SYNDICATED_DAYS',
                                   avalue    => l_days_after_ven_approval);

                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;
                result := 'COMPLETE:' || 'Y';

        else
                   result := 'COMPLETE:' || 'N';
       end if;

       GET_PARTY_EMAIL (l_party_id , l_email );
       If l_email is null THEN
             result := 'COMPLETE:' || 'N';
            return;
        else
            wf_engine.SetItemAttrText(itemtype  => itemtype,
                                        itemkey   => itemkey,
                                        aname     => 'PARTY_EMAIL',
                                        avalue    => l_email);
              result := 'COMPLETE:' || 'Y';
       end if;



  EXCEPTION
    when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_STRY_CALL_CO_PUB','check_days_for_syn_acct',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END check_days_for_syn_acct;



END OKL_STRY_CALL_CO_PUB ;



/
