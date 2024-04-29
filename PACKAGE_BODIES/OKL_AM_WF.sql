--------------------------------------------------------
--  DDL for Package Body OKL_AM_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_WF" AS
/* $Header: OKLRAWFB.pls 120.17.12010000.3 2010/02/26 13:40:56 bkatraga ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE             CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION             CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_wf.';

  SUBTYPE   p_bind_var_tbl       IS  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  SUBTYPE   p_bind_val_tbl       IS  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  SUBTYPE   p_bind_type_tbl      IS  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

  -- Start of comments
  --
  -- Procedure Name : set_wf_launch_message
  -- Description : Sets the message to display workflow and process called.
  -- Business Rules :
  -- Parameters  : p_event_name, p_event_key
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE set_wf_launch_message (p_event_name         IN VARCHAR2,
                                   p_event_key          IN VARCHAR2) AS

    -- Selects the workfow and process details
    CURSOR  c_get_wf_details_csr (c_event_name VARCHAR2)
    IS
    SELECT   IT.display_name
    ,        RP.display_name
    FROM     WF_EVENTS             WFEV,
             WF_EVENT_SUBSCRIPTIONS   WFES,
             wf_runnable_processes_v  RP,
             wf_item_types_vl         IT
    WHERE WFEV.guid = WFES.event_filter_guid
    AND   WFES.WF_PROCESS_TYPE = RP.ITEM_TYPE
    AND   WFES.WF_PROCESS_NAME = RP.PROCESS_NAME
    AND   RP.ITEM_TYPE = IT.NAME
    AND   WFEV.NAME  = c_event_name;

    l_wf_desc      VARCHAR2(100);
    l_process_desc VARCHAR2(100);

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_wf_launch_message';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN

     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

  OPEN  c_get_wf_details_csr(p_event_name);
  FETCH c_get_wf_details_csr INTO l_wf_desc, l_process_desc;
  IF c_get_wf_details_csr%found THEN

      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_WF_LAUNCH_MSG',
                          p_token1       => 'ITEM_DESC',
                          p_token1_value => l_wf_desc,
                          p_token2       => 'PROCESS_DESC',
                          p_token2_value => l_process_desc,
                          p_token3       => 'EVENT_KEY',
                          p_token3_value => p_event_key);
  END IF;
  CLOSE c_get_wf_details_csr;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
      WHEN OTHERS THEN
        IF c_get_wf_details_csr%ISOPEN THEN
           CLOSE c_get_wf_details_csr;
        END IF;

  END set_wf_launch_message;

  -- Start of comments
  --
  -- Procedure Name : raise_business_event
  -- Description   : Generic procedure for raising business events
  -- Business Rules :
  -- Parameters    : p_transaction_id, p_event_name
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE raise_business_event (p_transaction_id     IN NUMBER,
                                  p_event_name         IN VARCHAR2) AS

    l_parameter_list        wf_parameter_list_t;
    l_key                   VARCHAR2(240);
    l_seq                   NUMBER;


    -- Selects the nextval from sequence, used later for defining event key
 CURSOR okl_key_csr IS
 SELECT okl_wf_item_s.nextval
 FROM   dual;

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'raise_business_event';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    SAVEPOINT raise_event;

 OPEN okl_key_csr;
 FETCH okl_key_csr INTO l_seq;
 CLOSE okl_key_csr;

    l_key := p_event_name ||l_seq ;

    wf_event.AddParameterToList('TRANSACTION_ID',p_transaction_id,l_parameter_list);
    --added by akrangan as part of MOAC changes
    if p_event_name in ('oracle.apps.okl.am.approveassetrepair',
                        'oracle.apps.okl.am.acceptrestquote',
                        'oracle.apps.okl.am.preproceeds',
                        'oracle.apps.okl.am.postproceeds',
                        'oracle.apps.okl.am.submitquoteforapproval',
                        'oracle.apps.okl.am.remkcustomflow',
                        'oracle.apps.okl.am.notifycollections',
                        'oracle.apps.okl.am.notifyremarketer',
                        'oracle.apps.okl.am.notifyrepoagent',
                        'oracle.apps.okl.am.notifytitleholder',
                        'oracle.apps.okl.am.approvecontportfolio',
                        'oracle.apps.okl.am.notifyportexe',
                        'oracle.apps.okl.am.notifyshipinstr',
                        'oracle.apps.okl.am.notifytransdept' ,
   'oracle.apps.okl.am.sendquote'
                        )
    then
    --added by akrangan
      wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
    end if ;
    -- Raise Event
           wf_event.raise(p_event_name  => p_event_name
                         ,p_event_key   => l_key
                         ,p_parameters  => l_parameter_list);
           l_parameter_list.DELETE;

    -- Set Launch Message
    set_wf_launch_message(p_event_name => p_event_name,
                          p_event_key  => l_key);

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

    EXCEPTION
      WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

        IF okl_key_csr%ISOPEN THEN
           CLOSE okl_key_csr;
        END IF;

      ROLLBACK TO raise_event;

  END raise_business_event;

  -- Start of comments
  --
  -- Procedure Name : raise_fulfillment_event
  -- Description : Generic procedure for raising fulfillment business events
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE raise_fulfillment_event (
                  itemtype                   IN  VARCHAR2
                , itemkey                    IN  VARCHAR2
                , actid                      IN  NUMBER
                , funcmode                   IN  VARCHAR2
                , resultout                  OUT NOCOPY VARCHAR2) IS

 l_parameter_list        wf_parameter_list_t;
 l_key                   VARCHAR2(240);
 l_event_name            VARCHAR2(240) := 'oracle.apps.okl.am.notifyexternalparty' ;
 l_seq                   NUMBER;

 l_transaction_id             VARCHAR2(100);
 l_process_code               VARCHAR2(100);
 l_recipient_type             VARCHAR2(10);
 l_recipient_id               VARCHAR2(100);
 l_recipient_desc             VARCHAR2(1000);
 l_created_by                 NUMBER;
 l_expand_roles               VARCHAR2(1);
 l_email_address              VARCHAR2(100);
 --19-jul-2007 ansethur R12B XML Publisher starts
 l_batch_id                  number;-- Varchar2(100);
 l_from_address              VARCHAR2(100);
 --19-jul-2007 ansethur R12B XML Publisher ends

    -- Selects the nextval from sequence, used later for defining event key
 CURSOR okl_key_csr IS
 SELECT okl_wf_item_s.nextval
 FROM   dual;

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'raise_fulfillment_event';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

 BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

  IF (funcmode = 'RUN') THEN

      SAVEPOINT raise_fulfillment_event;

      l_transaction_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                            aname   => 'TRANSACTION_ID');

      l_process_code   := wf_engine.GetItemAttrText( itemtype => itemtype,
                          itemkey => itemkey,
                        aname   => 'PROCESS_CODE');

      l_recipient_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                          itemkey => itemkey,
                        aname   => 'RECIPIENT_TYPE');

      l_recipient_id   := wf_engine.GetItemAttrText( itemtype => itemtype,
                          itemkey => itemkey,
                        aname   => 'RECIPIENT_ID');

      l_recipient_desc := wf_engine.GetItemAttrText( itemtype => itemtype,
                          itemkey => itemkey,
                        aname   => 'RECIPIENT_DESCRIPTION');

      l_created_by     := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                          itemkey => itemkey,
                        aname   => 'CREATED_BY');

      l_email_address     := wf_engine.GetItemAttrText( itemtype => itemtype,
                          itemkey => itemkey,
                        aname   => 'EMAIL_ADDRESS');

 --19-jul-2007 ansethur R12B XML Publisher starts
      l_from_address     := wf_engine.GetItemAttrText( itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'FROM_ADDRESS');
      l_batch_id     := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'BATCH_ID');
 --19-jul-2007 ansethur R12B XML Publisher end
      OPEN okl_key_csr;
      FETCH okl_key_csr INTO l_seq;
      CLOSE okl_key_csr;

      l_key := l_event_name ||l_seq ;

      wf_event.AddParameterToList('TRANSACTION_ID',l_transaction_id,l_parameter_list);
      wf_event.AddParameterToList('PROCESS_CODE',l_process_code,l_parameter_list);
      wf_event.AddParameterToList('RECIPIENT_TYPE',l_recipient_type,l_parameter_list);
      wf_event.AddParameterToList('RECIPIENT_ID',l_recipient_id,l_parameter_list);
      wf_event.AddParameterToList('RECIPIENT_DESCRIPTION',l_recipient_desc,l_parameter_list);
      wf_event.AddParameterToList('CREATED_BY',l_created_by,l_parameter_list);
     -- wf_event.AddParameterToList('EXPAND_ROLES',l_expand_roles,l_parameter_list);
      wf_event.AddParameterToList('EMAIL_ADDRESS',l_email_address,l_parameter_list);
   --19-jul-2007 ansethur R12B XML Publisher Starts
      wf_event.AddParameterToList('BATCH_ID',l_batch_id,l_parameter_list);
      wf_event.AddParameterToList('FROM_ADDRESS',l_from_address,l_parameter_list);
   --19-jul-2007 ansethur R12B XML Publisher Ends
      --added by akrangan
      wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);


     -- Raise Event
       wf_event.raise(p_event_name  => l_event_name
                     ,p_event_key   => l_key
                     ,p_parameters  => l_parameter_list);
       l_parameter_list.DELETE;

  END IF;

  IF (funcmode = 'CANCEL') THEN
    --
    resultout := 'COMPLETE:';
    RETURN;
    --
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
    --
    resultout := 'COMPLETE:';
    RETURN;
    --
  END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

      IF okl_key_csr%ISOPEN THEN
         CLOSE okl_key_csr;
      END IF;

    ROLLBACK TO raise_fulfillment_event;

  END raise_fulfillment_event;

  -- Start of comments
  --
  -- Procedure Name : call_am_fulfillment
  -- Description : Called from any WF process to execute a fulfillment request
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE CALL_AM_FULFILLMENT( itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

    l_transaction_id             VARCHAR2(100);
    l_trans_id                   NUMBER;
 l_process_code               VARCHAR2(100);
 l_recipient_type             VARCHAR2(10);
 l_recipient_id               VARCHAR2(100);
 l_recipient_desc             VARCHAR2(1000);
    l_created_by                 NUMBER;
    l_expand_roles               VARCHAR2(1);

    l_mesg_count                 NUMBER := 0;
    l_mesg_text                  VARCHAR2(4000);
    l_mesg_len                   NUMBER;

    l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(30000);

    l_status_message             VARCHAR2(30000);

    l_notification_agent         VARCHAR2(100);
    l_desc                       VARCHAR2(100);

    l_mt_bind_names                 p_bind_var_tbl;
    l_mt_bind_values                p_bind_val_tbl;
    l_mt_bind_types                 p_bind_type_tbl;

    l_email_address              VARCHAR(100);
    lx_error_rec        OKL_API.error_rec_type;
    l_msg_idx             INTEGER := FND_MSG_PUB.G_FIRST;

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'call_am_fulfillment';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

    BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

      l_mt_bind_names(1)  := '';
      l_mt_bind_values(1) := '';
      l_mt_bind_types(1)  := '';

      IF (funcmode = 'RUN') THEN

        SAVEPOINT call_fulfillment;

      l_transaction_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

        l_process_code   := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'PROCESS_CODE');

        l_recipient_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'RECIPIENT_TYPE');

        l_recipient_id   := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'RECIPIENT_ID');

        l_recipient_desc := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'RECIPIENT_DESCRIPTION');

        l_created_by     := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'CREATED_BY');

        l_expand_roles   := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'EXPAND_ROLES');

        l_email_address   := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'EMAIL_ADDRESS');

        OKL_AM_UTIL_PVT.EXECUTE_FULFILLMENT_REQUEST (
            p_api_version                  => 1
          , p_init_msg_list                => FND_API.G_FALSE
          , x_return_status                => l_return_status
          , x_msg_count                    => l_msg_count
          , x_msg_data                     => l_msg_data
          , p_ptm_code                     => l_process_code
          , p_agent_id                     => l_created_by
          , p_transaction_id               => l_transaction_id
          , p_recipient_type               => l_recipient_type
          , p_recipient_id                 => l_recipient_id
          , p_expand_roles                 => l_expand_roles
          , p_pt_bind_names                => l_mt_bind_names
          , p_pt_bind_values               => l_mt_bind_values
          , p_pt_bind_types                => l_mt_bind_types
          , p_recipient_email              => l_email_address
      --    , p_commit                       => FND_API.G_FALSE
          );
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_util_pvt.execute_fulfillment_request :'||l_return_status);
   END IF;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         l_status_message := ' ';
         LOOP

          fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => FND_API.G_FALSE,
            p_data          => lx_error_rec.msg_data,
            p_msg_index_out => lx_error_rec.msg_count);

           IF (lx_error_rec.msg_count IS NOT NULL) THEN

              IF LENGTH(l_status_message) + LENGTH(lx_error_rec.msg_data) < 30000 THEN
                l_status_message := l_status_message||' '||lx_error_rec.msg_data;
              END IF;

           END IF;

          EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
          OR (lx_error_rec.msg_count IS NULL));

          l_msg_idx := FND_MSG_PUB.G_NEXT;

         END LOOP;

         wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'STATUS_MESSAGE',
                              avalue  => l_status_message);

            -- Locates the user name for the requestor, performing agent for notifications
            okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_created_by
                              , x_name     => l_notification_agent
                           , x_description => l_desc);

             wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'NOTIFY_AGENT',
                              avalue  => l_notification_agent);

             wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_DESCRIPTION',
                              avalue  => l_notification_agent);

        END IF;


        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   resultout := 'COMPLETE:ERROR';
  ELSE
   resultout := 'COMPLETE:SUCCESS';
  END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


    EXCEPTION
      WHEN OTHERS THEN

        ROLLBACK TO call_fulfillment;

        wf_core.context('OKL_AM_WF' , 'CALL_AM_FULFILLMENT', itemtype, itemkey, actid, funcmode);
        RAISE;

  END CALL_AM_FULFILLMENT;

  -- Start of comments
  --
  -- Procedure Name : start_approval_process
  -- Description : Called from any WF where AM Approvals WF needs to be launched
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE START_APPROVAL_PROCESS( itemtype IN VARCHAR2,
                        itemkey   IN VARCHAR2,
                         actid  IN NUMBER,
                           funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2 )IS

    -- Selects the nextval from sequence, used later for defining event key
 CURSOR okl_key_csr IS
 SELECT okl_wf_item_s.nextval
 FROM   dual;

    l_key                   VARCHAR2(240);
    l_seq                   NUMBER;
    l_itemtype              VARCHAR2(30) := 'OKLAMAPP';
    l_process               VARCHAR2(30) := 'APPROVAL_PROC';
    l_parent_trx_id         VARCHAR2(240);
    l_parent_trx_type       VARCHAR2(240);
    l_requester             VARCHAR2(30);
    l_mess_desc             VARCHAR2(4000);

    -- 19-NOV-03 MDOKAL -- Bug 3262184
    CURSOR check_ia_exists_csr(c_item_type VARCHAR2) IS
        SELECT name
        FROM   wf_item_attributes
        WHERE  item_type = c_item_type
        AND name IN ('APP_REQUEST_SUB' ,'APP_REMINDER_SUB' ,'APP_APPROVED_SUB',
                   'APP_REJECTED_SUB','APP_REMINDER_HEAD','APP_APPROVED_HEAD',
                   'APP_REJECTED_HEAD') ;
   -- smadhava - Bug#5235038 - Added - Start
   l_msg_doc VARCHAR2(4000);
   -- smadhava - Bug#5235038 - Added - End

   l_org_id  NUMBER;  --Added by bkatraga for bug 9412628

   --dkagrawa -Bug#5256290 start
   invalid_attr EXCEPTION;
   PRAGMA EXCEPTION_INIT(invalid_attr, -20002);
   --dkagrawa -Bug#5256290 end
       -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'start_approval_process';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
   BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

 OPEN okl_key_csr;
 FETCH okl_key_csr INTO l_seq;
 CLOSE okl_key_csr;

    l_key := l_itemtype ||l_seq ;

      IF (funcmode = 'RUN') THEN


        wf_engine.CreateProcess(itemtype         => l_itemtype,
                    itemkey           => l_key,
                                process             => l_process);


        wf_engine.SetItemParent(itemtype         => l_itemtype,
                    itemkey           => l_key,
                                parent_itemtype     => itemtype,
                                parent_itemkey      => itemkey,
                                parent_context      => 'MASTER');

        l_parent_trx_id := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'TRANSACTION_ID');

        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname               => 'TRANSACTION_ID',
                              avalue              => l_parent_trx_id);

        l_parent_trx_type := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'TRX_TYPE_ID');

        l_mess_desc := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'MESSAGE_DESCRIPTION');

        --Added by bkatraga for bug 9412628
        l_org_id := wf_engine.GetItemAttrText (
                       itemtype            => itemtype,
                       itemkey             => itemkey,
                       aname               => 'ORG_ID');

        wf_engine.SetItemAttrText (
                       itemtype            => l_itemtype,
                       itemkey             => l_key,
                       aname               => 'ORG_ID',
                       avalue              => l_org_id);
        --end bkatraga

        --dkagrawa -Bug#5256290 added exception handling start
        BEGIN
          -- smadhava - Bug#5235038 - Added - Start
          -- Get the MESSAGE_DOC attribute value set in the original Workflow
          l_msg_doc := wf_engine.GetItemAttrText(
                                itemtype            => itemtype
                              , itemkey             => itemkey
                              , aname               => 'MESSAGE_DOC');
          -- smadhava - Bug#5235038 - Added - End
        EXCEPTION
          WHEN  invalid_attr THEN
            l_msg_doc := null;
        END;
        --dkagrawa -Bug#5256290 end

        l_requester := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'REQUESTER');

        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname               => 'TRX_TYPE_ID',
                              avalue              => l_parent_trx_type);

        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname               => 'PARENT_ITEM_KEY',
                              avalue              => itemkey);

        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname               => 'PARENT_ITEM_TYPE',
                              avalue              => itemtype);

        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname               => 'MESSAGE_DESCRIPTION',
                              avalue              => l_mess_desc);

        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname               => 'REQUESTER',
                              avalue              => l_requester);

        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname      => 'WF_ADMINISTRATOR',
                              avalue              => l_requester);

        -- MDOKAL, 20-MAR-2003 Bug 2862254
        -- Added the following logic to populate the default value of the
        -- document type item attribute.
        -- smadhava - Bug#5235038 - Modified - Start
        -- Check if the MESSAGE_DOC has already been set. If so donot modify.
        -- Else assign the call to pop_approval_doc to assign the MESSAGE_DESCRIPTION
        IF l_msg_doc IS NULL THEN
          l_msg_doc := 'plsql:okl_am_wf.pop_approval_doc/'||l_key;
        END IF;
        wf_engine.SetItemAttrText (
                                itemtype            => l_itemtype,
                    itemkey             => l_key,
                    aname      => 'MESSAGE_DOC',
                              avalue              => l_msg_doc);
        -- smadhava - Bug#5235038 - Modified - End
        -- 19-NOV-03 MDOKAL -- Bug 3262184
        -- process optional parameters
        FOR ia_rec IN check_ia_exists_csr(itemtype) LOOP

            wf_engine.SetItemAttrText (
                                itemtype => l_itemtype,
                    itemkey  => l_key,
                    aname    => ia_rec.name,
                              avalue   => wf_engine.GetItemAttrText(
                                                itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => ia_rec.name)
                                );
        END LOOP;

        wf_engine.StartProcess(itemtype             => l_itemtype,
                   itemkey           => l_key);

        resultout := 'COMPLETE:';
        RETURN;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


    EXCEPTION
      WHEN OTHERS THEN

        IF okl_key_csr%ISOPEN THEN
           CLOSE okl_key_csr;
        END IF;

        wf_core.context('OKL_AM_WF' , 'START_APPROVAL_PROCESS', itemtype, itemkey, actid, funcmode);
        RAISE;

  END START_APPROVAL_PROCESS;

  -- Start of comments
  --
  -- Procedure Name : set_parent_attributes
  -- Description : Called from the Generic Approvals WF for setting the approval outcome
  --                  for the parent WF.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE SET_PARENT_ATTRIBUTES(  itemtype IN VARCHAR2,
                        itemkey   IN VARCHAR2,
                         actid  IN NUMBER,
                           funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2 )IS

    l_parent_key                   VARCHAR2(240);
    l_parent_type                  VARCHAR2(240);
    l_approved_yn                  VARCHAR2(240);
    l_transaction_id               VARCHAR2(100);

        -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_parent_attributes';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

    BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

--    SAVEPOINT set_atts;

      IF (funcmode = 'RUN') THEN


        -- Get parent information from Approvals WF

        l_parent_key := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'PARENT_ITEM_KEY');

        l_parent_type := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'PARENT_ITEM_TYPE');


        -- Get Approved flag
        l_approved_yn := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'RESULT');

        -- Set the parent attribute(s)

        if l_approved_yn = 'APPROVED' then
          l_approved_yn := 'Y';
        else
          l_approved_yn := 'N';
        end if;


          wf_engine.SetItemAttrText (
                                itemtype            => l_parent_type,
                    itemkey             => l_parent_key,
                    aname               => 'APPROVED_YN',
                              avalue              => l_approved_yn);

          l_transaction_id := wf_engine.GetItemAttrText (
                                itemtype            => l_parent_type,
                    itemkey             => l_parent_key,
                    aname               => 'TRANSACTION_ID');

        -- ensure the the statuses have been cleared out for reuse.
        update ame_temp_old_approver_lists
        set approval_status = null
        where transaction_id = l_transaction_id;


        resultout := 'COMPLETE:';
        RETURN;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

    EXCEPTION
      WHEN OTHERS THEN
        wf_core.context('OKL_AM_WF' , 'SET_PARENT_ATTRIBUTES', itemtype, itemkey, actid, funcmode);
        RAISE;

  END SET_PARENT_ATTRIBUTES;

  -- Start of comments
  --
  -- Procedure Name : validate_approval_request
  -- Description : Called from the Generic Approvals WF for validating approval request
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE VALIDATE_APPROVAL_REQUEST(  itemtype IN VARCHAR2,
                            itemkey   IN VARCHAR2,
                               actid  IN NUMBER,
                               funcmode    IN VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2 )IS

     l_trx_type    VARCHAR2(1000);
     l_app_id      NUMBER;
     l_knt         NUMBER;
     l_parent_type VARCHAR2(300);
     l_parent_key  VARCHAR2(300);

     -- Get the valid application id from FND
     CURSOR c_get_app_id_csr
     IS
     SELECT APPLICATION_ID
     FROM   FND_APPLICATION
     WHERE  APPLICATION_SHORT_NAME = 'OKL';

     -- Validate the Transaction Type Id from OAM
     CURSOR c_validate_trx_type_csr(c_trx_type  VARCHAR2)
     IS
     SELECT count(*)
     FROM   AME_CALLING_APPS
     WHERE  TRANSACTION_TYPE_ID = c_trx_type;
/*
     CURSOR c_get_parent_key_csr(c_itemtype VARCHAR2,
                                 c_itemkey  VARCHAR2)
     IS
     SELECT PARENT_ITEM_TYPE, PARENT_ITEM_KEY
     FROM   WF_ITEMS
     WHERE  ITEM_TYPE = c_itemtype
     AND    ITEM_KEY = c_itemkey;
*/

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'validate_approval_request';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

      IF (funcmode = 'RUN') THEN

        l_trx_type := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'TRX_TYPE_ID');

        OPEN  c_validate_trx_type_csr(l_trx_type);
        FETCH c_validate_trx_type_csr INTO l_knt;
        CLOSE c_validate_trx_type_csr;

        OPEN c_get_app_id_csr;
        FETCH c_get_app_id_csr INTO l_app_id;
        CLOSE c_get_app_id_csr;

        IF l_knt <> 0 AND l_app_id IS NOT NULL THEN

            wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'APPLICATION_ID',
                              avalue              => l_app_id);

          resultout := 'COMPLETE:VALID';
        ELSE
          resultout := 'COMPLETE:INVALID';
        END IF;

        RETURN;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


    EXCEPTION
      WHEN OTHERS THEN

        IF c_validate_trx_type_csr%ISOPEN THEN
           CLOSE c_validate_trx_type_csr;
        END IF;

        IF c_get_app_id_csr%ISOPEN THEN
           CLOSE c_get_app_id_csr;
        END IF;

        wf_core.context('OKL_AM_WF' , 'VALIDATE_APPROVAL_REQUEST', itemtype, itemkey, actid, funcmode);
        RAISE;

  END VALIDATE_APPROVAL_REQUEST;

  -- Start of comments
  --
  -- Procedure Name : get_approver
  -- Description : Called from the Generic Approvals WF and is recursively executed
  --                  until all approvers have been located or until an approvwer
  --                  rejects a request.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  -- History        : MSDOKAL - Created
  --                  SGORANTL 28-DEC-05 4887809 : Modified to convert person id into user id
  --                         before calling get_notification_agent
  --
  -- End of comments
  PROCEDURE GET_APPROVER(  itemtype     IN VARCHAR2,
                           itemkey      IN VARCHAR2,
                           actid        IN NUMBER,
                           funcmode     IN VARCHAR2,
                           resultout    OUT NOCOPY VARCHAR2 )IS


    l_trx_type          VARCHAR2(240);
    l_app_id            NUMBER;
    l_approver_rec      ame_util.approverRecord;
    l_approver          wf_users.name%type;
    l_name              wf_users.description%type;
    l_transaction_id    VARCHAR2(100);

    l_result            VARCHAR2(30);

    l_user_id           NUMBER;      -- SGORANTL 28-DEC-05 4887809
    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_approver';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

      IF (funcmode = 'RUN') THEN

        -- Get OAM parameter values from Approvals WF
        l_trx_type := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'TRX_TYPE_ID');

        l_app_id   := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'APPLICATION_ID');

        l_transaction_id := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'TRANSACTION_ID');

        -- Call OAM api to get approval details
        ame_api.getNextApprover(applicationIdIn     => l_app_id,
                                transactionIdIn     => l_transaction_id,
                                transactionTypeIn   => l_trx_type,
                                nextApproverOut     => l_approver_rec);

        IF l_approver_rec.person_id IS NOT NULL THEN -- populate attributes

             -- SGORANTL 28-DEC-05 4887809 : convert person_id into user_id
            l_user_id := ame_util.personidtouserid(L_approver_rec.person_id);

            okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
         -- , p_user_id     => l_approver_rec.person_id -- SGORANTL 28-DEC-05 4887809
                              , p_user_id     => l_user_id -- SGORANTL 28-DEC-05 4887809
      , x_name     => l_approver
                           , x_description => l_name);

            wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'PERFORMING_AGENT',
                              avalue              => l_approver);

            wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'FIRST_NAME',
                              avalue              => l_approver_rec.first_name);

            wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'LAST_NAME',
                              avalue              => l_approver_rec.last_name);

            wf_engine.SetItemAttrNumber (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'USER_ID',
                              avalue              => l_approver_rec.user_id);

            wf_engine.SetItemAttrNumber (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'PERSON_ID',
                              avalue              => l_approver_rec.person_id);

            wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'API_INSERTION',
                              avalue              => l_approver_rec.api_insertion);

            wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'AUTHORITY',
                              avalue              => l_approver_rec.authority);

            resultout := 'COMPLETE:FOUND';
        ELSE

            l_result := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'RESULT');

   IF l_result IS NULL THEN
   -- There were no appovers, set RESULT to APPROVE
               wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'RESULT',
                              avalue              => 'APPROVED');
   END IF;

            resultout := 'COMPLETE:NOT_FOUND';
        END IF;
        RETURN;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


    EXCEPTION
      WHEN OTHERS THEN

        wf_core.context('OKL_AM_WF' , 'GET_APPROVER', itemtype, itemkey, actid, funcmode);
        RAISE;

  END GET_APPROVER;

  -- Start of comments
  --
  -- Procedure Name : set_approval_status
  -- Description : Called from the Generic Approvals WF to set the approval status
  --                  and is recursively executed
  --                  until all approvers have been located or until an approvwer
  --                  rejects a request.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE SET_APPROVAL_STATUS(  itemtype IN VARCHAR2,
                      itemkey   IN VARCHAR2,
                         actid  IN NUMBER,
                         funcmode  IN VARCHAR2,
                      resultout OUT NOCOPY VARCHAR2 )IS

    l_app_id          NUMBER;
    l_trx_type        VARCHAR2(100);
    l_approved_yn     VARCHAR2(30);
    l_approver_rec    ame_util.approverRecord;
    l_user_id         NUMBER;
    l_transaction_id  VARCHAR2(100);
    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_approval_status';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    SAVEPOINT set_atts;

      IF (funcmode = 'RUN') THEN

            -- Get current approval status
            l_approved_yn := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'RESULT');

            IF l_approved_yn = 'APPROVED' THEN
                l_approver_rec.approval_status   := 'APPROVE';
            ELSE
                l_approver_rec.approval_status   := 'REJECT';
            END IF;

            -- All OAM attributes

            l_transaction_id := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'TRANSACTION_ID');

            l_trx_type := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'TRX_TYPE_ID');

            l_app_id := wf_engine.GetItemAttrNumber (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'APPLICATION_ID');

            l_approver_rec.last_name := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'LAST_NAME');

            l_approver_rec.first_name := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'FIRST_NAME');

            l_user_id  := wf_engine.GetItemAttrNumber (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'USER_ID');

             if l_user_id = -1 then
               l_approver_rec.user_id := null;
             else
               l_approver_rec.user_id := l_user_id;
             end if;

            l_approver_rec.person_id := wf_engine.GetItemAttrNumber (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'PERSON_ID');

            l_approver_rec.api_insertion  := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'API_INSERTION');

            l_approver_rec.authority  := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'AUTHORITY');

            ame_api.updateApprovalStatus(applicationIdIn    => l_app_id,
                                     transactionIdIn    => l_transaction_id,
                                     approverIn         => l_approver_rec,
                                     transactionTypeIn  => l_trx_type);

        resultout := 'COMPLETE:';
        RETURN;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


    EXCEPTION
      WHEN OTHERS THEN
        wf_core.context('OKL_AM_WF' , 'SET_APPROVAL_STATUS', itemtype, itemkey, actid, funcmode);
        RAISE;

  END SET_APPROVAL_STATUS;


  -- Start of comments
  --
  -- Procedure Name : GET_ERROR_STACK
  -- Description : Called from  AM workflows to retrieve errors from the error
  --                  stack and stores values in item attributes.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE GET_ERROR_STACK(      itemtype IN VARCHAR2,
                      itemkey   IN VARCHAR2,
                         actid  IN NUMBER,
                         funcmode  IN VARCHAR2,
                      resultout OUT NOCOPY VARCHAR2 )IS

  l_return_status   VARCHAR2(1);
  l_msg_data        VARCHAR2(4000);

  l_error_itemtype  VARCHAR2(100);
  l_error_itemkey   VARCHAR2(100);

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_error_stack';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

  IF funcmode = 'RUN' THEN

       -- get the errored processes itemtype and itemkey
       l_error_itemtype := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'ERROR_ITEM_TYPE');

       l_error_itemkey  := wf_engine.GetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'ERROR_ITEM_KEY');

       -- get the error details from the errored process

       l_return_status  := wf_engine.GetItemAttrText (
                                itemtype            => l_error_itemtype,
                    itemkey             => l_error_itemkey,
                    aname               => 'API_ERROR');

       l_msg_data       := wf_engine.GetItemAttrText (
                                itemtype            => l_error_itemtype,
                    itemkey             => l_error_itemkey,
                    aname               => 'API_ERROR_STACK');

       -- set error details in the standard error item type

       wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'API_ERROR',
                              avalue              => l_return_status);

       wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'API_ERROR_STACK',
                              avalue              => l_msg_data);


       resultout := 'COMPLETE:';
       RETURN;
  END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


  EXCEPTION
      WHEN OTHERS THEN

        wf_core.context('OKL_AM_WF' , 'GET_ERROR_STACK', itemtype, itemkey, actid, funcmode);
        RAISE;
  END GET_ERROR_STACK;

  -- Start of comments
  --
  -- Procedure Name : POPULATE_ERROR_ATTS
  -- Description : Called from the AM Error WF (OKLAMERR) to populate additonal
  --                  notificaiton attributes.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  -- History        : SECHAWLA 03-DEC-04 4047159 : display all messages from the stack
  -- End of comments
  PROCEDURE POPULATE_ERROR_ATTS(
     itemtype                        IN VARCHAR2
 , itemkey                        IN VARCHAR2
 , actid                       IN NUMBER
 , funcmode                      IN VARCHAR2
 , resultout                      OUT NOCOPY VARCHAR2 )IS

    l_mesg_count                 NUMBER := 0;
    l_mesg_text                  VARCHAR2(4000);
    l_mesg_len                   NUMBER;

    l_status_message             VARCHAR2(30000);
    l_wf_admin                   VARCHAR2(100);

    API_ERROR                    EXCEPTION;

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'populate_error_atts';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF funcmode = 'RUN' THEN

       l_mesg_count := fnd_msg_pub.count_msg;

        IF l_mesg_count > 0 THEN

            l_mesg_text :=  substr(fnd_msg_pub.get (fnd_msg_pub.G_FIRST, fnd_api.G_FALSE),1, 512);

            --FOR i IN 1..2 LOOP -- (l_mesg_count - 1) loop  -- SECHAWLA 03-DEC-04 4047159
            FOR i IN 1..(l_mesg_count - 1) loop -- SECHAWLA 03-DEC-04 4047159
                l_mesg_text := l_mesg_text || substr(fnd_msg_pub.get
                                         (fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 512);
            END  LOOP;

            fnd_msg_pub.delete_msg();

            l_mesg_len := length(l_mesg_text);

            FOR i IN 1..ceil(l_mesg_len/255) LOOP
                l_status_message := l_status_message||' '||substr(l_mesg_text, ((i*255)-254), 255);
            END  LOOP;

         ELSE

            l_status_message := 'An error was encountered but no message was found in the error stack';

         END IF;

         wf_engine.SetItemAttrText ( itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'API_ERROR_STACK',
                                   avalue   => l_status_message);

         wf_engine.SetItemAttrText ( itemtype => itemtype,
                          itemkey  => itemkey,
                         aname    => 'API_ERROR',
                                   avalue   => 'E');


          resultout := 'COMPLETE:';
          RETURN;

    END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


      EXCEPTION
      WHEN OTHERS THEN
        wf_core.context('OKL_AM_WF' , 'POPULATE_ERROR_ATTS', itemtype, itemkey, actid, funcmode);
        RAISE;

  END POPULATE_ERROR_ATTS;


  -- Start of comments
  --
  -- Procedure Name : GET_NOTIFICATION_AGENT
  -- Description : Used by WF procedures where internal notifications are sent.
  --                  Determines the user_name and description of the notification
  --                  agent.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout, p_user_id,
  --                  x_name, x_description
  -- Version  : 1.1
  -- MDOKAL         : Bug 2902588, changed code to check for fnd_user info 1st
  --                  and then WF_ROLES instead of WF_USERS.
  --                : 19-NOV-03 MDOKAL Bug 3262184 - changed order in which
  --                  wf users are retrieved.
  -- End of comments
  PROCEDURE GET_NOTIFICATION_AGENT(
      itemtype                      IN  VARCHAR2
 , itemkey                        IN  VARCHAR2
 , actid                       IN  NUMBER
 , funcmode                      IN  VARCHAR2
    , p_user_id                      IN  NUMBER
 , x_name                        OUT NOCOPY VARCHAR2
 , x_description                  OUT NOCOPY VARCHAR2 ) IS

    CURSOR wf_roles_csr(c_emp_id NUMBER, c_system VARCHAR2)
    IS
    SELECT NAME, DISPLAY_NAME
    FROM   WF_ROLES
    WHERE  orig_system_id = c_emp_id
    AND    orig_system = c_system;

    CURSOR fnd_users_csr(c_user_id NUMBER)
    IS
    SELECT USER_NAME, DESCRIPTION, EMPLOYEE_ID
    FROM   FND_USER
    WHERE  user_id = c_user_id;

    l_user  VARCHAR2(50);
    l_desc  VARCHAR2(100);
    l_emp   NUMBER;
    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_notification_agent';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        /* The logic for retrieving a wf user follows this hierarchy:
           [Step 1] First check if p_user_id is for an FND user.
           [Step 2] If FND user found, then find if attached to a HR person
           [Step 3] If Step 2 is TRUE then get user where orig system is 'PER'
                    based on the HR person id (l_emp)
           [Step 4] If Step 2 TRUE but l_emp is NULL therefore not attached
                    to a HR person, use the FND user as is.
           [Step 5] If FND user not found, then check if the p_user_id passed
                    is indeed for a HR person that is attached to an FND user.
           [Step 6] If FND user not found and PER user not found, check if the
                    p_user_id pertains to a HR person not attached to an FND user.
           [Step 7] Finally, this is an invalid user, user the sysadmin user.

        */
        -- 1st Check fnd users
        OPEN  fnd_users_csr(p_user_id);
        FETCH fnd_users_csr INTO l_user, l_desc, l_emp;
        IF fnd_users_csr%notfound THEN
            -- 2nd check if id passed belongs to an employee rather then fnd user
            OPEN  wf_roles_csr(p_user_id, 'PER');
            FETCH wf_roles_csr INTO l_user, l_desc;
            IF wf_roles_csr%notfound THEN
                CLOSE wf_roles_csr;
                -- Maybe a HR user not attached to FND user
                OPEN  wf_roles_csr(p_user_id, 'HZ_PARTY');
                FETCH wf_roles_csr INTO l_user, l_desc;
                CLOSE wf_roles_csr;
            ELSE
                CLOSE wf_roles_csr;
            END IF;
        END IF;
        CLOSE fnd_users_csr;

        -- if l_emp is not null then the user is attached to an employee
        IF l_emp IS NOT NULL THEN

            OPEN  wf_roles_csr(l_emp, 'PER');
            FETCH wf_roles_csr INTO l_user, l_desc;
            CLOSE wf_roles_csr;

        END IF;

       -- if l_user is still null, no user info was found
       IF l_user IS NULL THEN
          l_user := 'SYSADMIN';
          l_desc := 'System Administrator';
       END IF;

       x_name        := l_user;
    x_description := l_desc;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


       EXCEPTION
       WHEN OTHERS THEN
          wf_core.context('OKL_AM_WF' , 'GET_NOTIFICATION_AGENT', itemtype, itemkey, actid, funcmode);
          RAISE;
    END GET_NOTIFICATION_AGENT;


  -- Start of comments
  --
  -- Procedure Name : pop_approval_doc
  -- Description : MDOKAL, 20-MAR-2003 Bug 2862254
  --                  This procedure is invoked dynamically by Workflow API's
  --                  in order to populate the message body item attribute
  --                  during notification submission.
  -- Business Rules :
  -- Parameters  : document_id, display_type, document, document_type
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE pop_approval_doc (document_id   in varchar2,
                              display_type  in varchar2,
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS

    l_message        VARCHAR2(32000);
    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'pop_approval_doc';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        l_message := wf_engine.GetItemAttrText (
                                itemtype            => 'OKLAMAPP',
                    itemkey             => document_id,
                    aname               => 'MESSAGE_DESCRIPTION');

        document := l_message;
        document_type := display_type;

        RETURN;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


  EXCEPTION
     WHEN OTHERS THEN NULL;

  END pop_approval_doc;


   -- Start of comments
  --
  -- Procedure Name : set_status_on_exit
  -- Description : Called from the Generic Approvals WF to set the Result
  --                  attribute when requet timed out
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE SET_STATUS_ON_EXIT(  itemtype IN VARCHAR2,
                      itemkey   IN VARCHAR2,
                         actid  IN NUMBER,
                         funcmode  IN VARCHAR2,
                      resultout OUT NOCOPY VARCHAR2 )IS
    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_status_on_exit';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    SAVEPOINT set_atts;

      IF (funcmode = 'RUN') THEN

      wf_engine.SetItemAttrText (
                                itemtype            => itemtype,
                    itemkey             => itemkey,
                    aname               => 'RESULT',
                              avalue              => 'REJECT');


        resultout := 'COMPLETE:';
        RETURN;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


    EXCEPTION
      WHEN OTHERS THEN
        wf_core.context('OKL_AM_WF' , 'SET_STATUS_ON_EXIT', itemtype, itemkey, actid, funcmode);
        RAISE;

  END SET_STATUS_ON_EXIT;
  --added by akrangan as part of MOAC changes
  PROCEDURE CALLBACK(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2,
                                   activity_id IN NUMBER,
                                   command IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2) IS
    l_user_name          VARCHAR2(240);
    x_return_status      VARCHAR2(1);
    l_api_name           VARCHAR2(40) := 'callback';
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(32767);
    l_application_id     fnd_application.application_id%TYPE;
    l_api_version        NUMBER := 1.0;
    p_api_version        NUMBEr := 1.0;
    l_org_id             NUMBER;
    current_org_id       NUMBER;
    l_user_id            NUMBER;
    current_user_id      NUMBER;
    l_resp_id            NUMBER;
    current_resp_id      NUMBER;
    l_appl_id            NUMBER;
    current_appl_id      NUMBER;

    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'callback';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    l_org_id:= wf_engine.GetItemAttrNumber(itemtype,
                                                      itemkey,
                                                      'ORG_ID');
    current_org_id := nvl(mo_global.get_current_org_id(),-1);

    IF(itemtype = 'OKLCSCRM') THEN

    -- Get the user who intiated the workflow
    l_user_id:= wf_engine.GetItemAttrNumber(itemtype,
                                            itemkey,
                                           'USER_ID');
    -- Get the current user
    current_user_id:= FND_GLOBAL.USER_ID;
    -- Get the responsibility at which the above user intiated the workflow
    l_resp_id:= wf_engine.GetItemAttrNumber(itemtype,
                                            itemkey,
                                           'RESPONSIBILITY_ID');
    -- Get the current responsibility
    current_resp_id:= FND_GLOBAL.RESP_ID;
    -- Get the application where the above user intiated the workflow
    l_appl_id:= wf_engine.GetItemAttrNumber(itemtype,
                                            itemkey,
                                           'APPLICATION_ID');
    -- Get the current application
    current_appl_id:= FND_GLOBAL.RESP_APPL_ID;
    END IF;
    IF (command ='SET_CTX') THEN
    -- Set the application user context back to the original one
       IF(itemtype = 'OKLCSCRM') THEN
         FND_GLOBAL.APPS_initialize(l_user_id,l_resp_id,l_appl_id);
       END IF;
      mo_global.init('OKL');
      MO_GLOBAL.set_policy_context('S',l_org_id);
      resultout :='COMPLETE';
    END IF;

    IF (command='TEST_CTX') THEN
     -- Check if user or resp or application or org has changed
       IF(itemtype = 'OKLCSCRM') THEN
         IF ( l_org_id <> current_org_id
             OR l_user_id <> current_user_id
             OR l_resp_id <> current_resp_id
             OR l_appl_id <> current_appl_id) THEN
             resultout := 'NOTSET';
         ELSE
             resultout := 'TRUE';
        END IF;
      END IF;
      IF (l_org_id <> current_org_id) THEN
        resultout := 'NOTSET';
      ELSE
        resultout := 'TRUE';
      END IF;
      return;
    END IF;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name,
                                                     'OKL_AM_WF',
                                                     'OTHERS',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT');
        RAISE;
  END callback;

-- sechawla - 7594853 - Added - Start
  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By     : sechawla
    -- Procedure Name : CALLBACK_USER
    -- Description    : Procedure functions to set the user context.
    --                  Method is particularly useful in case of asynchronous
    --                  workflows where workflow can be run an user other than
    --                  the one requesting.
    -- Dependencies   :
    -- Parameters     :
    -- Version        : 1.0
    -- End of Comments
  -----------------------------------------------------------------------------
  PROCEDURE CALLBACK_USER(itemtype IN VARCHAR2,
                          itemkey IN VARCHAR2,
                          activity_id IN NUMBER,
                          command IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2) IS

    l_org_id             NUMBER;
    current_org_id       NUMBER;
    l_user_id            NUMBER;
    current_user_id      NUMBER;
    l_resp_id            NUMBER;
    current_resp_id      NUMBER;
    l_appl_id            NUMBER;
    current_appl_id      NUMBER;
  BEGIN

    -- Get the Org from where the workflow was initiated
    l_org_id:= wf_engine.GetItemAttrNumber(itemtype,
                                           itemkey,
                                          'ORG_ID');

   -- Get the current org
   current_org_id:= fnd_profile.value('ORG_ID');

    -- Get the user who intiated the workflow
    l_user_id:= wf_engine.GetItemAttrNumber(itemtype,
                                           itemkey,
                                          'USER_ID');
   -- Get the current user
   current_user_id:= FND_GLOBAL.USER_ID;

    -- Get the responsibility at which the above user intiated the workflow
    l_resp_id:= wf_engine.GetItemAttrNumber(itemtype,
                                           itemkey,
                                          'RESPONSIBILITY_ID');
   -- Get the current responsibility
   current_resp_id:= FND_GLOBAL.RESP_ID;

    -- Get the application where the above user intiated the workflow
    l_appl_id:= wf_engine.GetItemAttrNumber(itemtype,
                                           itemkey,
                                          'APPLICATION_ID');
   -- Get the current application
   current_appl_id:= FND_GLOBAL.RESP_APPL_ID;

    IF (command ='SET_CTX') THEN
      -- Set the application user context back to the original one
      FND_GLOBAL.APPS_initialize(l_user_id,l_resp_id,l_appl_id);
      -- Set the Org
      dbms_application_info.set_client_info(l_org_id);
      resultout :='COMPLETE';
    END IF;

    IF (command='TEST_CTX') THEN
      -- Check if user or resp or application or org has changed
      IF ( l_org_id <> current_org_id
        OR l_user_id <> current_user_id
        OR l_resp_id <> current_resp_id
        OR l_appl_id <> current_appl_id) THEN
        resultout := 'NOTSET';

      ELSE
        resultout := 'TRUE';

      END IF;
      return;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.CONTEXT ('OKL_AM_WF', 'CALLBACK_USER',
                        itemtype,itemkey,
                        to_char(activity_id), command);
        RAISE;
  END CALLBACK_USER;
  -- sechawla - 7594853  - Added - End


  /*Sosharma 24-Oct-2006
     Build:R12
     Procedure to populate attribute values for delivery mode from the profiles.
     Also to populate the value of template code based on recipient type and process code
     Start Changes */
   PROCEDURE populate_attributes( itemtype IN VARCHAR2,
                                                   itemkey          IN VARCHAR2,
                                               actid                IN NUMBER,
                                               funcmode        IN VARCHAR2,
                                                   resultout OUT NOCOPY VARCHAR2 )IS

       l_delivery_mode             VARCHAR2(100);
       l_recipient_type            VARCHAR2(100);
       l_template_code             VARCHAR2(100);
       l_process_code              VARCHAR2(100);
       l_datasource_code           VARCHAR2(100);
       l_notification_agent        VARCHAR2(200);
       l_desc                      VARCHAR2(500);
       l_created_by                VARCHAR2(100);
       l_message_body              VARCHAR2(500);
       l_message_sub               VARCHAR2(200);
  --19-jul-2007 ansethur R12B XML Publisher Starts
      l_email_subject_line  VARCHAR2(500);
  -- ansethur modified the cursor to return template_code, data_source_code and subject_line
       CURSOR c_get_temp_code(process_code varchar2,recipient_type varchar2)
        IS
       SELECT --PT.PTM_CODE REPORT_CODE,
             -- FND.MEANING REPORT_NAME,
              PT.XML_TMPLT_CODE TEMPLATE_CODE,
              --XDOTL.TEMPLATE_NAME,
             -- XDOB.APPLICATION_SHORT_NAME TMPLT_APPS_SHORT_NAME,
             -- XDOB.DS_APP_SHORT_NAME DATA_SRC_APPS_SHORT_NAME,
              XDOB.DATA_SOURCE_CODE,
              PTTL.EMAIL_SUBJECT_LINE
              FROM OKL_PROCESS_TMPLTS_B PT,
              OKL_PROCESS_TMPLTS_TL PTTL,
              FND_LOOKUPS FND,
              XDO_TEMPLATES_B XDOB,
              XDO_TEMPLATES_TL XDOTL
            WHERE PT.PTM_CODE = FND.LOOKUP_CODE
           AND XDOB.TEMPLATE_CODE = XDOTL.TEMPLATE_CODE
           AND XDOB.APPLICATION_SHORT_NAME = 'OKL'
           AND PT.START_DATE <= SYSDATE
           AND NVL(PT.END_DATE,SYSDATE) >= SYSDATE
           AND PT.XML_TMPLT_CODE = XDOB.TEMPLATE_CODE
           AND XDOTL.LANGUAGE = USERENV('LANG')
           AND PT.PTM_CODE = process_code
           AND PT.RECIPIENT_TYPE_CODE = recipient_type
           AND PTTL.ID=PT.ID;
  --19-jul-2007 ansethur R12B XML Publisher Ends
    -- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'populate_attributes';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
       BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


         IF (funcmode = 'RUN') THEN

         SAVEPOINT call_populate;


           l_recipient_type := wf_engine.GetItemAttrText (
                                   itemtype            => itemtype,
                                   itemkey             => itemkey,
                                   aname               => 'RECIPIENT_TYPE');

           l_process_code := wf_engine.GetItemAttrText (
                                   itemtype            => itemtype,
                                   itemkey             => itemkey,
                                   aname               => 'PROCESS_CODE');

           l_created_by     := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                                                itemkey        => itemkey,
                                                                              aname          => 'CREATED_BY');

           OPEN  c_get_temp_code(l_process_code,l_recipient_type);
           FETCH c_get_temp_code INTO l_template_code,l_datasource_code,l_email_subject_line; -- ansethur added subject line
           CLOSE c_get_temp_code;


         l_delivery_mode :=  'EMAIL';--fnd_profile.value('OKL_DELIVERY_MODE'); -- ansethur changed the delivery mode

         fnd_message.set_name ('OKL','OKL_XML_WF_SUB');
         l_message_sub:=fnd_message.get;
         fnd_message.set_name ('OKL','OKL_XML_WF_BODY');
         l_message_body:=fnd_message.get;

        okl_am_wf.get_notification_agent(
                                   itemtype          => itemtype
                                     , itemkey       => itemkey
                                     , actid         => actid
                                     , funcmode      => funcmode
                                     , p_user_id     => l_created_by
                                     , x_name        => l_notification_agent
                                     , x_description => l_desc);

           wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'NOTIFY_AGENT',
                                       avalue  => l_notification_agent);

           wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'RECIPIENT_DESCRIPTION',
                                       avalue  => l_notification_agent);

           wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                      itemkey => itemkey,
                                      aname   => 'TEMPLATE_CODE',
                                      avalue  => l_template_code);


           wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'DELIVERY_MODE',
                                       avalue  => l_delivery_mode);



            wf_engine.SetItemAttrText (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'MESSAGE_BODY_TEXT',
                                       avalue   => l_message_body
                                       );
           wf_engine.SetItemAttrText (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'MESSAGE_SUB_TEXT',
                                       avalue   => l_message_sub
                                      );
  --19-jul-2007 ansethur R12B XML Publisher Starts
           wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'DATA_SOURCE_CODE',
                                      avalue  => l_datasource_code);
           wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                       itemkey => itemkey,
                                       aname   => 'SUBJECT',
                                       avalue  => l_email_subject_line);
  --19-jul-2007 ansethur R12B XML Publisher Ends

          resultout := 'COMPLETE:SET';
          RETURN;

           END IF;



         --
         -- CANCEL mode
         --
         IF (funcmode = 'CANCEL') THEN
           --
           resultout := 'COMPLETE:';
           RETURN;
           --
         END IF;
         --
         -- TIMEOUT mode
         --
         IF (funcmode = 'TIMEOUT') THEN
           --
           resultout := 'COMPLETE:';
           RETURN;
           --
         END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


       EXCEPTION
         WHEN OTHERS THEN

           ROLLBACK TO call_populate;

           wf_core.context('OKL_AM_WF' , 'populate_attributes', itemtype, itemkey, actid, funcmode);
           RAISE;

     END populate_attributes;
     /* sosharma End Changes */



END OKL_AM_WF;

/
