--------------------------------------------------------
--  DDL for Package Body FUN_MULTI_SYSTEM_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_MULTI_SYSTEM_WF_PKG" AS
/* $Header: funmulsb.pls 120.2.12010000.3 2009/03/23 12:47:49 makansal ship $ */


  -- Check a party is a local party or remote party
/*-----------------------------------------------------|
| PROCEDURE IS_LOCAL                                   |
|------------------------------------------------------|
|   Parameters     p_party_id       IN   NUMBER        |
|                                                      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Procedure to find out whether the recipient|
|           is located in the local instance           |
|                                                      |
|           Right now, it is a dummy function always   |
|           return true. It will be updated when LE    |
|           API is available                           |
|-----------------------------------------------------*/


  FUNCTION IS_LOCAL (p_party_id IN NUMBER) return boolean
  IS

BEGIN

    -- always return true

    return TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

--     WHEN OTHERS THEN
     -- generic expcetion has to be handled by the calling procedure

END IS_LOCAL;

  -- Raise transaction is sent by the initiator events for all
  -- the local recipients

/*-----------------------------------------------------|
| PROCEDURE RAISE_LOCAL_EVENTS                         |
|------------------------------------------------------|
|   Parameters     p_item_type      IN   Varchar2      |
|                  p_item_key       IN   Varchar2      |
|                  p_act_id         IN   NUMBER        |
|                  p_fun_mode       IN   Varchar2      |
|                  p_result         IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Raise transaction is sent event for all    |
|           local recipients                           |
|                                                      |
|           event raised:                              |
|               oracle.apps.fun.manualtrx.transaction. |
|               receive                                |
|-----------------------------------------------------*/



  PROCEDURE RAISE_LOCAL_EVENTS(itemtype              IN VARCHAR2,
                               itemkey               IN VARCHAR2,
                               actid                 IN NUMBER,
                               funcmode              IN VARCHAR2,
                               resultout             OUT  NOCOPY VARCHAR2)

IS
  l_batch_id     NUMBER;
  l_trx_id       NUMBER;
  l_recipient_id NUMBER;
  l_parameter_list WF_PARAMETER_LIST_T :=wf_parameter_list_t();
  l_event_key    VARCHAR2(240);
  l_resp_id      NUMBER;
  l_user_id      NUMBER;
  l_appl_id      NUMBER;
  l_user_env_lang varchar2(5);


  CURSOR c_recipient(p_batch_id IN NUMBER) IS
                          SELECT   trx_id, recipient_id
                          FROM     FUN_TRX_HEADERS
                          WHERE    batch_id = p_batch_id;


BEGIN
   l_resp_id :=   wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'RESP_ID');
   l_user_id  :=  wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'USER_ID');
   l_appl_id  :=  wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname =>'APPL_ID');
   l_user_env_lang := wf_engine.GetItemAttrText
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'USER_LANG');

    if(funcmode='RUN') then

-- get the batch_id from the item attributes

    l_batch_id :=   wf_engine.getitemattrnumber(itemtype,
                                                itemkey,
                                               'BATCH_ID');

-- open the cursor, and raise the business event for each recipient

    open c_recipient(l_batch_id);

    LOOP
    FETCH c_recipient INTO l_trx_id, l_recipient_id;
    EXIT WHEN c_recipient%NOTFOUND;

    -- check the recipient is local or not

    if (IS_LOCAL(l_recipient_id))  then
      -- renew the parameter list
   l_parameter_list :=wf_parameter_list_t();


      -- assembly the parameter list

     WF_EVENT.AddParameterToList(p_name=>'BATCH_ID',
                                 p_value=>TO_CHAR(l_batch_id),
                                 p_parameterlist=>l_parameter_list);

     WF_EVENT.AddParameterToList(p_name=>'TRX_ID',
                                 p_value=>TO_CHAR(l_trx_id),
                                 p_parameterlist=>l_parameter_list);
     WF_EVENT.AddParameterToList(p_name=>'RESP_ID',
                                 p_value=>TO_CHAR(l_resp_id),
                                 p_parameterlist=>l_parameter_list);
     WF_EVENT.AddParameterToList(p_name=>'USER_ID',
                                 p_value=>TO_CHAR(l_user_id),
                                 p_parameterlist=>l_parameter_list);
     WF_EVENT.AddParameterToList(p_name=>'APPL_ID',
                                 p_value=>TO_CHAR(l_appl_id),
                                 p_parameterlist=>l_parameter_list);
     WF_EVENT.AddParameterToList(p_name => 'USER_LANG',
                                 p_value => TO_CHAR(l_user_env_lang),
                                 p_parameterlist => l_parameter_list);
      -- generate the event key

      l_event_key :=FUN_INITIATOR_WF_PKG.GENERATE_KEY(l_batch_id, l_trx_id);

      -- temp solution
   --l_event_key :=to_char(l_batch_id) || '_' || to_char(l_trx_id) || SYS_GUID();

      -- Raise the event

 WF_EVENT.RAISE(p_event_name =>'oracle.apps.fun.manualtrx.transaction.receive',
                p_event_key  =>l_event_key,
                p_parameters =>l_parameter_list);

        l_parameter_list.delete();

       END IF;
       END LOOP;

       close c_recipient;

       -- Do we need commit?

     --  COMMIT;
       resultout := 'COMPLETE';
       return;

    END IF; -- end of the run mode


-- Cancel mode

 IF (funcmode = 'CANCEL') THEN

    -- extra cancel code goes here

   null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;


EXCEPTION

WHEN OTHERS THEN
    -- Rcords this function call in the error system
    -- in the case of an exception.
    wf_core.context('FUN_MULTI_SYSTEM_WF_PKG', 'RAISE_LOCAL_EVENTS',
		    itemtype, itemkey, to_char(actid), funcmode);

END RAISE_LOCAL_EVENTS;



  -- Set workflow item attributes for the process

/*-----------------------------------------------------|
| PROCEDURE SET_ATTRIBUTES                             |
|------------------------------------------------------|
|   Parameters     p_item_type      IN   Varchar2      |
|                  p_item_key       IN   Varchar2      |
|                  p_act_id         IN   NUMBER        |
|                  p_funcmode       IN   Varchar2      |
|                  p_result         IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Set the attributes of the WF process       |
|                                                      |
|                                                      |
|                                                      |
|                                                      |
|                                                      |
|-----------------------------------------------------*/


   PROCEDURE SET_ATTRIBUTES   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT  NOCOPY VARCHAR2)

IS
l_batch_id     NUMBER;
l_sts          VARCHAR2(1);
BEGIN

 IF (funcmode = 'RUN') THEN

    -- Currently we do not need additional attributes. This may change
    -- when handling the remote instances case.

    -- get the item attributes from the WF
    l_batch_id :=   wf_engine.getitemattrnumber(itemtype,
                                                itemkey,
                                               'BATCH_ID');

    -- We only need to check if invoice is required and set the
    -- flag in fun_trx_headers table.
    fun_wf_common.set_invoice_reqd_flag(p_batch_id             => l_batch_id,
                                        x_return_status        => l_sts);

    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

EXCEPTION

WHEN OTHERS THEN

    -- Rcords this function call in the error system
    -- in the case of an exception.

    wf_core.context('FUN_MULTI_SYSTEM_WF_PKG', 'SET_ATTRIBUTES',
		    itemtype, itemkey, to_char(actid), funcmode);

END  SET_ATTRIBUTES;

  -- Count the remote instances number

/*-----------------------------------------------------|
| PROCEDURE COUNT_REMOTE                               |
|------------------------------------------------------|
|   Parameters     p_item_type      IN   Varchar2      |
|                  p_item_key       IN   Varchar2      |
|                  p_act_id         IN   NUMBER        |
|                  p_funcmode       IN   Varchar2      |
|                  p_result         IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Count remote instance                      |
|                                                      |
|           Dummy Function                             |
|           Always return zero                         |
|           In the future, we can replace it in the    |
|           set_attributes procedure call              |
|-----------------------------------------------------*/


   PROCEDURE COUNT_REMOTE     (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT  NOCOPY VARCHAR2)

IS

BEGIN

 IF (funcmode = 'RUN') THEN

    -- Set the attribute to zero

                    wf_engine.setitemattrnumber(itemtype,
                                                itemkey,
                                                'NUM_REMOTE_INSTANCE',
                                                 0);

    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

EXCEPTION

WHEN OTHERS THEN

    -- Rcords this function call in the error system
    -- in the case of an exception.

    wf_core.context('FUN_MULTI_SYSTEM_WF_PKG', 'COUNT_REMOTE',
		    itemtype, itemkey, to_char(actid), funcmode);

END  COUNT_REMOTE;

 -- Check the trading partner that the status update event for is
 -- a local party or not.
 -- Note the trading partner is different for different status events

/*-----------------------------------------------------|
| PROCEDURE CHECK_TP_LOCAL                             |
|------------------------------------------------------|
|   Parameters     p_item_type      IN   Varchar2      |
|                  p_item_key       IN   Varchar2      |
|                  p_act_id         IN   NUMBER        |
|                  p_funcmode       IN   Varchar2      |
|                  p_result         IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Check the trading partner is               |
|           local or not                               |
|                                                      |
|   return YES / NO                                    |
|                                                      |
|                                                      |
|-----------------------------------------------------*/


   PROCEDURE CHECK_TP_LOCAL   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT  NOCOPY VARCHAR2)

IS

l_tp_party_id  NUMBER;
l_batch_id     NUMBER;
l_trx_id       NUMBER;
l_initiator_id NUMBER;
l_recipient_id NUMBER;
l_event_name   Varchar2(240);
l_new_event_name Varchar2(240);
l_event_key      Varchar2(240);
l_invoice_num    Varchar2(50);

BEGIN

 IF (funcmode = 'RUN') THEN

    -- get the item attributes from the WF
    l_batch_id :=   wf_engine.getitemattrnumber(itemtype,
                                                itemkey,
                                               'BATCH_ID');

    l_trx_id   :=   wf_engine.getitemattrnumber(itemtype,
                                                itemkey,
                                               'TRX_ID');

    l_event_name := wf_engine.getitemattrtext  (itemtype,
                                                itemkey,
                                               'EVENT_NAME');

    -- obtain the initiator_id and recipient_id

      SELECT  initiator_id, recipient_id
      INTO    l_initiator_id, l_recipient_id
      FROM    FUN_TRX_HEADERS
      WHERE   batch_id=l_batch_id
      AND     trx_id=l_trx_id;

    -- determine the TP ID
   /* TP is the recipient if the event is
                                 oracle.apps.fun.manualtrx.glcomple.send
                                 oracle.apps.fun.manualtrx.arcomplete.send

      TP is the initiator if the event is

                                 oracle.apps.fun.manualtrx.error.send
                                 oracle.apps.fun.manualtrx.reception.send
                                 oracle.apps.fun.manualtrx.rejection.send
                                 oracle.apps.fun.manualtrx.approval.send
                                 oracle.apps.fun.manualtrx.complete.send
*/

     if(lower(l_event_name) in ('oracle.apps.fun.manualtrx.glcomplete.send',
                                'oracle.apps.fun.manualtrx.arcomplete.send'))
     then
      l_tp_party_id :=l_recipient_id;

     -- get the Invoice Number
           l_invoice_num := wf_engine.getitemattrtext  (itemtype,
                                                itemkey,
                                               'INVOICE_NUM');


      else
      l_tp_party_id :=l_initiator_id;
     end if;

    -- determine the TP is local or not

       if(IS_LOCAL(l_tp_party_id)) then

       resultout:='COMPLETE:Y';

      -- set RECEIVE_EVENT_NAME
       l_new_event_name :=(RTRIM(l_event_name, 'send')) || 'receive';
      -- generate the event key

--      l_event_key :=FUN_INITIATOR_WF_PKG.GENERATE_KEY(l_batch_id, xsl_trx_id);

      -- temp solution
 l_event_key :=to_char(l_batch_id) || '_' || to_char(l_trx_id) || SYS_GUID();

      --set the WF item value
                    wf_engine.setitemattrtext(itemtype,
                                              itemkey,
                                              'RECEIVE_EVENT_NAME',
                                              l_new_event_name);

                    wf_engine.setitemattrtext(itemtype,
                                              itemkey,
                                              'LOCAL_EVT_KEY',
                                               l_event_key);
                    wf_engine.setitemattrtext(itemtype,
                                              itemkey,
                                              'INVOICE_NUM',
                                               l_invoice_num);
       else
       resultout:='COMPLETE:N';
       end if;

       return;

    END IF; -- end of RUN mode

EXCEPTION

WHEN OTHERS THEN

    -- Rcords this function call in the error system
    -- in the case of an exception.

    wf_core.context('FUN_MULTI_SYSTEM_WF_PKG', 'CHECK_TP_LOCAL',
		    itemtype, itemkey, to_char(actid), funcmode);

END  CHECK_TP_LOCAL;

END FUN_MULTI_SYSTEM_WF_PKG;


/
