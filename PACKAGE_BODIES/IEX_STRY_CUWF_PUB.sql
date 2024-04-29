--------------------------------------------------------
--  DDL for Package Body IEX_STRY_CUWF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRY_CUWF_PUB" as
/* $Header: iexpscwb.pls 120.4.12010000.2 2009/11/18 08:55:55 pnaveenk ship $ */
-- Start of Comments
-- Package name     : IEX_STRY_CUWF_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT    VARCHAR2(100):=  'IEX_STRY_CUWF_PUB ';
G_FILE_NAME     CONSTANT    VARCHAR2(50) := 'iexpscwb.pls';

/**Name   AddInvalidArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER;

--begin schekuri Bug#4506922 Date:02-Dec-2005
wf_yes 		varchar2(1) ;
wf_no 		varchar2(1) ;
--end schekuri Bug#4506922 Date:02-Dec-2005

PROCEDURE AddInvalidArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_value	IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 ) IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEX', 'IEX_API_ALL_INVALID_ARGUMENT');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('VALUE', p_param_value);
      fnd_message.set_token('PARAMETER', p_param_name);
      fnd_msg_pub.add;
   END IF;


END AddInvalidArgMsg;

/**Name   AddMissingArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

PROCEDURE AddMissingArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
            fnd_message.set_token('API_NAME', p_api_name);
            fnd_message.set_token('MISSING_PARAM', p_param_name);
            fnd_msg_pub.add;
        END IF;
END AddMissingArgMsg;

/**Name   AddNullArgMsg
**Appends to a message  the api name, parameter name and parameter Value
*/

PROCEDURE AddNullArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEX', 'IEX_API_ALL_NULL_PARAMETER');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('NULL_PARAM', p_param_name);
      fnd_msg_pub.add;
   END IF;


END AddNullArgMsg;

/**Name   AddFailMsg
  **Appends to a message  the name of the object anf the operation (insert, update ,delete)
*/
PROCEDURE AddfailMsg
  ( p_object	    IN	VARCHAR2,
    p_operation 	IN	VARCHAR2 ) IS

BEGIN
      fnd_message.set_name('IEX', 'IEX_FAILED_OPERATION');
      fnd_message.set_token('OBJECT',    p_object);
      fnd_message.set_token('OPERATION', p_operation);
      fnd_msg_pub.add;

END    AddfailMsg;


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

END;
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



/**
* populate the attributes which will send in the notification
**/

procedure populate_attributes(
   p_strategy_id    IN NUMBER,
   itemtype         IN   varchar2,
   itemkey          IN   varchar2) IS

 l_resource_id  NUMBER ;

 cursor c_get_delinquency(p_strategy_id number) is
   select a.party_id, a.party_type, a.party_name,
          b.cust_account_id,
          b.status, b.payment_schedule_id,
          b.aging_bucket_line_id,c.delinquency_id
    from iex_delinquencies_all b, hz_parties a,iex_strategies c
    where a.party_id(+)  = b.party_cust_id
    and c.strategy_id    = p_strategy_id
    and c.delinquency_id = b.delinquency_id;

--Begin bug#4930374 schekuri 12-Jan-2006
--Removed the outer join to ar_payment_schedules to avoid FTS and NMV.
cursor c_get_payment(p_delinquency_id number) is
  select a.amount_due_remaining
   from ar_payment_schedules a, iex_delinquencies b
  where a.payment_schedule_id = b.payment_schedule_id
  and b.delinquency_id = p_delinquency_id;

/*cursor c_get_payment(p_delinquency_id number) is
  select a.amount_due_remaining
   from ar_payment_schedules a, iex_delinquencies b
  where a.payment_schedule_id(+) = b.payment_schedule_id
  and b.delinquency_id = p_delinquency_id;*/
--End bug#4930374 schekuri 12-Jan-2006

BEGIN
-- right now populating only these many atributes
-- strategy_id,workitem_id and notification_username
-- has been already populated
    FOR d_rec in c_get_delinquency(p_strategy_id)
    LOOP

        wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'DELINQUENCY_ID',
                                    avalue    => d_rec.delinquency_id);

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

         FOR p_rec in c_get_payment(d_rec.delinquency_id)
         LOOP
             wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                        itemkey   => itemkey,
                                        aname     => 'OVERDUE_AMOUNT',
                                        avalue    => p_rec.amount_due_remaining);
         END LOOP;

    END LOOP;





End populate_attributes;


-----PUBLIC Procedures---------------------------------

/*
**The standard API for the selector/callback function is as follows
*/


procedure start_process (item_type   in varchar2,
                         item_key    in varchar2,
                         activity_id in number,
                         command     in varchar2,
                         result      in out NOCOPY varchar2) IS
BEGIN
       null;


END start_process;

procedure Start_CustomWF(
    p_api_version             IN  NUMBER := 1.0,
    p_init_msg_list           IN  VARCHAR2 ,
    p_commit                  IN  VARCHAR2 ,
    p_Custom_WF_rec           IN  CUSTOM_WF_REC_TYPE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2) IS


  l_api_name                VARCHAR2(100) ;
  l_api_name_full           CONSTANT VARCHAR2(100) := g_pkg_name || '.' || l_api_name;
  l_init_msg_list           VARCHAR2(1)  ;
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(32767);
  l_api_version             CONSTANT NUMBER   := 1.0;

  l_Custom_WF_rec        CUSTOM_WF_REC_TYPE;
  l_itemtype VARCHAR2 (100);
  l_itemkey  VARCHAR2 (100);
  l_result   VARCHAR2(100);
  l_ret_status   VARCHAR2(8);
  l_resource_id  NUMBER ;
  p_wait_date  DATE;
  l_commit varchar2(1);
BEGIN

    l_api_name                := 'START_CUSTOMWF';
    l_init_msg_list := p_init_msg_list;
    if (p_init_msg_list is null ) then
      l_init_msg_list           := FND_API.G_FALSE;
    end if;
    l_commit := p_commit;
    if (p_commit is null ) then
       l_commit                  := FND_API.G_FALSE;
    end if;
    l_resource_id             := nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);

  SAVEPOINT	START_CUSTOMWF_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('populate_attributes: ' || 'after init');
 END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for required parameter p_strategy_id
       IF (p_Custom_WF_rec.strategy_id IS NULL) OR
        (p_Custom_WF_rec.strategy_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('populate_attributes: ' || 'Required Parameter p_Custom_WF_rec.strategy_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_Custom_WF_rec.strategy_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('populate_attributes: ' || 'after p_Custom_WF_rec.strategy_id check');
     END IF;

      -- Check for required parameter p_workitem_id
       IF (p_Custom_WF_rec.workitem_id IS NULL) OR
                (p_Custom_WF_rec.workitem_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('populate_attributes: ' || 'Required Parameter p_Custom_WF_rec.workitem_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_Custom_WF_rec.workitem_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('populate_attributes: ' || 'after p_Custom_WF_rec.workitem_id check');
     END IF;

      -- Check for required parameter p_custom_itemtype
      -- this is the work flow to be launched
       IF (p_Custom_WF_rec.custom_itemtype IS NULL) OR
               (p_Custom_WF_rec.custom_itemtype = FND_API.G_MISS_CHAR) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('populate_attributes: ' || 'Required Parameter p_Custom_WF_rec.custom_itemtype is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_Custom_WF_rec.custom_itemtype' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('populate_attributes: ' || 'after p_Custom_WF_rec.custom_itemtype check');
     END IF;


     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_itemtype := p_Custom_WF_rec.custom_itemtype;
     l_itemkey  := p_Custom_WF_rec.workitem_id;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('populate_attributes: ' ||  'itemtype =>' ||l_itemtype);
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('populate_attributes: ' ||  'itemkey =>' ||l_itemkey);
     END IF;

    --create the custom process
    --process is An optional argument that allows the selection of
    --a particular process.for that item. Provide the process internal name.
    --If process is null, the item type's selector function is used to determine the
    --top level process to run. If you do not
    --specify a selector function and this argument is null, an error will be raised.
    -- but inthe selector function we have to pass the process name if it is 'RUN' mode
    -- so we are passing the process name.


     wf_engine.createprocess(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             process  =>'IEX_STRATEGY_CUSTOM_WORKFLOW');

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('populate_attributes: ' || ' after create workflow process');
    END IF;

     wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname     => 'STRATEGY_ID',
                                 avalue    => p_Custom_WF_rec.strategy_id);

     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                                  itemkey   => l_itemkey,
                                  aname     => 'WORK_ITEMID',
                                  avalue    => p_Custom_WF_rec.workitem_id);



      wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'USER_ID',
                             avalue    => p_Custom_WF_rec.user_id);


     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'RESP_ID',
                             avalue    => p_Custom_WF_rec.resp_id);


     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'RESP_APPL_ID',
                             avalue    => p_Custom_WF_rec.resp_appl_id);




    --wait 10 mts before sending the response
    p_wait_date := IEX_STRY_UTL_PUB.get_Date
                            (p_date =>SYSDATE,
                             l_UOM  =>'MIN',  -- changed for bug 7631756 PNAVEENK
                             l_UNIT =>10);

     wf_engine.SetItemAttrDate(itemtype  => l_itemtype,
                                itemkey   => l_itemkey,
                                 aname     => 'WAIT_PERIOD',
                                 avalue    => p_wait_date);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('populate_attributes: ' || ' before caling populate attributes');
    END IF;
    --populate the remaining attributes
    --set the resource to whim the notification will be send
     populate_attributes(
                         p_strategy_id  =>p_Custom_WF_rec.strategy_id,
                         itemtype       => l_itemtype,
                         itemkey        => l_itemkey);



    --populate notification_resource
    --sets the username to whom thenotification will be send
    BEGIN
          select resource_id into l_resource_id
          from iex_strategy_work_items
          where work_item_id =p_Custom_WF_rec.workitem_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
       l_resource_id   := nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);
    END;

     set_notification_resources(
                   p_resource_id    =>l_resource_id,
                   itemtype         =>l_itemtype,
                   itemkey          =>l_itemkey);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage (' before start workflow process');
END IF;


    wf_engine.startprocess(itemtype => l_itemtype,
                           itemkey  => l_itemkey);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage (' after start workflow process');
END IF;

    wf_engine.ItemStatus(
          itemtype =>   l_itemType,
          itemkey  =>   l_itemKey,
          status   =>   l_ret_status,
          result   =>   l_result);

    if (l_ret_status in (wf_engine.eng_completed, wf_engine.eng_active )) THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
    else
        x_return_status := FND_API.G_RET_STS_ERROR;
    end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage (' workflow return status = ' || l_return_status);
END IF;



  -- Standard check of p_commit
  IF FND_API.To_Boolean(l_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO START_CUSTOMWF_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO START_CUSTOMWF_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO START_CUSTOMWF_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


END  Start_CustomWF;


/** send signal to the main work flow that the custom work flow is over and
 * also updates the work item
 **/

procedure wf_send_signal(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out NOCOPY  varchar2)
IS

l_work_item_id number;
l_strategy_id number;
l_return_status     VARCHAR2(20);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
 exc                 EXCEPTION;
 l_error VARCHAR2(32767);

 l_user_id             NUMBER;
 l_resp_id             NUMBER;
 l_resp_appl_id        NUMBER;

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

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('wf_send_signal: ' || 'USER_ID' ||  l_user_id || ' RESP_ID ' ||  l_resp_id);
  END IF;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('wf_send_signal: ' || 'RESP_APPL_ID' ||l_resp_appl_id);
  END IF;
  --set the session
  FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);

  if (l_work_item_id is not null) then

    iex_stry_utl_pub.update_work_item(
                           p_api_version   => 1.0,
                           p_commit        => FND_API.G_TRUE,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_work_item_id  => l_work_item_id,
                           p_status        => 'COMPLETE',
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data
                           );

     if l_return_status =FND_API.G_RET_STS_SUCCESS THEN
       iex_strategy_wf.send_signal(
                         process    => 'IEXSTRY' ,
                         strategy_id => l_strategy_id,
                         status      => 'COMPLETE',
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
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('wf_send_signal: ' || 'error message is ' || l_error);
      END IF;
  wf_core.context('IEX_STRY_CUWF_PUB','wf_send_signal',itemtype,
                   itemkey,to_char(actid),funcmode,l_error);
     raise;

when others then

  wf_core.context('IEX_STRY_CUWF_PUB','wf_send_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
end wf_send_signal;


--Begin schekuri Bug#4506922 Date:02-Dec-2005
--added for the function WAIT_ON_HOLD_SIGNAL in workflow IEXSTRCM
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
  wf_core.context('IEX_STRY_CUWF_PUB','wait_on_hold_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  wait_on_hold_signal;
--end schekuri Bug#4506922 Date:02-Dec-2005


BEGIN
  -- initialize values
  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  --begin schekuri Bug#4506922 Date:02-Dec-2005
  wf_yes      := 'Y';
  wf_no       := 'N';
  --end schekuri Bug#4506922 Date:02-Dec-2005

END IEX_STRY_CUWF_PUB ;



/
