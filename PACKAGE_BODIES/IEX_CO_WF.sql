--------------------------------------------------------
--  DDL for Package Body IEX_CO_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CO_WF" AS
/* $Header: IEXRCOWB.pls 120.0 2004/01/24 03:15:16 appldev noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE notify_customer
  ---------------------------------------------------------------------------
--  PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE notify_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) AS
    l_delinquency_id NUMBER := NULL;
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := fnd_api.g_false;
    l_return_status VARCHAR2(1);
    lx_msg_count NUMBER ;
    lx_msg_data VARCHAR2(2000);

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id;
  BEGIN
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                FOR cur IN l_khr_csr(l_delinquency_id) LOOP
                  iex_open_interface_pub.insert_pending(
                    p_api_version => l_api_version,
                    p_init_msg_list => l_init_msg_list,
                    p_object1_id1 => cur.object_id,
                    p_object1_id2 => '#',
                    p_jtot_object1_code => 'OKX_LEASE',
                    p_action => IEX_OPI_PVT.ACTION_NOTIFY_CUST,
                    p_status => IEX_OPI_PVT.STATUS_PENDING_AUTO,
                    p_comments => OKC_API.G_MISS_CHAR,
                    p_ext_agncy_id => NULL,
                    p_review_date => NULL,
                    p_recall_date => NULL,
                    p_automatic_recall_flag => NULL,
                    p_review_before_recall_flag => NULL,
                    x_return_status => l_return_status,
                    x_msg_count => lx_msg_count,
                    x_msg_data => lx_msg_data);

                  IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_ERROR;
                  END IF;
                END LOOP;
		resultout := 'COMPLETE:';
         	RETURN ;
	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
  EXCEPTION
     when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_CO_WF','notify_customer',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END notify_customer;

  ---------------------------------------------------------------------------
  -- PROCEDURE report_customer
  ---------------------------------------------------------------------------
  PROCEDURE report_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) AS
    l_delinquency_id NUMBER := NULL;
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := fnd_api.g_false;
    l_return_status VARCHAR2(1);
    lx_msg_count NUMBER ;
    lx_msg_data VARCHAR2(2000);

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id;
  BEGIN
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                FOR cur IN l_khr_csr(l_delinquency_id) LOOP
                  iex_open_interface_pub.insert_pending(
                    p_api_version => l_api_version,
                    p_init_msg_list => l_init_msg_list,
                    p_object1_id1 => cur.object_id,
                    p_object1_id2 => '#',
                    p_jtot_object1_code => 'OKX_LEASE',
                    p_action => IEX_OPI_PVT.ACTION_REPORT_CB,
                    p_status => IEX_OPI_PVT.STATUS_PENDING_AUTO,
                    p_comments => OKC_API.G_MISS_CHAR,
                    p_ext_agncy_id => NULL,
                    p_review_date => NULL,
                    p_recall_date => NULL,
                    p_automatic_recall_flag => NULL,
                    p_review_before_recall_flag => NULL,
                    x_return_status => l_return_status,
                    x_msg_count => lx_msg_count,
                    x_msg_data => lx_msg_data);

                  IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_ERROR;
                  END IF;
                END LOOP;
		resultout := 'COMPLETE:';
         	RETURN ;
	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
  EXCEPTION
     when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_CO_WF','report_customer',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END report_customer;

  ---------------------------------------------------------------------------
  -- PROCEDURE transfer_case
  ---------------------------------------------------------------------------
  PROCEDURE transfer_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) AS
    l_delinquency_id NUMBER := NULL;
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := fnd_api.g_false;
    l_return_status VARCHAR2(1);
    lx_msg_count NUMBER ;
    lx_msg_data VARCHAR2(2000);

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id;
  BEGIN
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                FOR cur IN l_khr_csr(l_delinquency_id) LOOP
                  iex_open_interface_pub.insert_pending(
                    p_api_version => l_api_version,
                    p_init_msg_list => l_init_msg_list,
                    p_object1_id1 => cur.object_id,
                    p_object1_id2 => '#',
                    p_jtot_object1_code => 'OKX_LEASE',
                    p_action => IEX_OPI_PVT.ACTION_TRANSFER_EXT_AGNCY,
                    p_status => IEX_OPI_PVT.STATUS_PENDING_AUTO,
                    p_comments => OKC_API.G_MISS_CHAR,
                    p_ext_agncy_id => NULL,
                    p_review_date => NULL,
                    p_recall_date => NULL,
                    p_automatic_recall_flag => NULL,
                    p_review_before_recall_flag => NULL,
                    x_return_status => l_return_status,
                    x_msg_count => lx_msg_count,
                    x_msg_data => lx_msg_data);

                  IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_ERROR;
                  END IF;
                END LOOP;
		resultout := 'COMPLETE:';
         	RETURN ;
	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
  EXCEPTION
     when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_CO_WF','transfer_case',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END transfer_case;

  ---------------------------------------------------------------------------
  -- PROCEDURE review_case
  ---------------------------------------------------------------------------
  PROCEDURE review_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) AS
    l_delinquency_id NUMBER := NULL;
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := fnd_api.g_false;
    l_return_status VARCHAR2(1);
    lx_msg_count NUMBER ;
    lx_msg_data VARCHAR2(2000);

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT OIN.ID,
            OIN.KHR_ID,
            OIN.CAS_ID,
            IOH.ID HST_ID,
            IOH.OBJECT1_ID1,
            IOH.OBJECT1_ID2,
            IOH.JTOT_OBJECT1_CODE,
            IOH.ACTION,
            IOH.STATUS,
            IOH.REQUEST_DATE,
            IOH.PROCESS_DATE,
            IOH.EXT_AGNCY_ID
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,Okl_Open_Int OIN
        ,Iex_Open_Int_Hst IOH
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = oin.khr_id
    AND OIN.khr_id = TO_NUMBER(IOH.object1_id1)
    AND   IOH.jtot_object1_code = 'OKX_LEASE'
    AND   (IOH.ACTION = IEX_OPI_PVT.ACTION_TRANSFER_EXT_AGNCY)
    AND   (IOH.STATUS = IEX_OPI_PVT.STATUS_PROCESSED);

    l_oinv_rec                 iex_open_interface_pub.oinv_rec_type;
    lx_oinv_rec                iex_open_interface_pub.oinv_rec_type;
    l_iohv_rec                 iex_open_interface_pub.iohv_rec_type;
    lx_iohv_rec                iex_open_interface_pub.iohv_rec_type;
  BEGIN
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                FOR cur IN l_khr_csr(l_delinquency_id) LOOP
                  l_oinv_rec.id := cur.id;
                  l_oinv_rec.khr_id := cur.khr_id;
                  l_oinv_rec.cas_id := cur.cas_id;
                  l_iohv_rec.id := cur.hst_id;
                  l_iohv_rec.object1_id1 := cur.object1_id1;
                  l_iohv_rec.object1_id2 := cur.object1_id2;
                  l_iohv_rec.jtot_object1_code := cur.jtot_object1_code;
                  l_iohv_rec.action := cur.action;
                  l_iohv_rec.status := cur.status;
                  l_iohv_rec.request_date := cur.request_date;
                  l_iohv_rec.process_date := cur.process_date;
                  l_iohv_rec.ext_agncy_id := cur.ext_agncy_id;

                  iex_open_interface_pub.review_transfer(
                    p_api_version => l_api_version,
                    p_init_msg_list => l_init_msg_list,
                    p_oinv_rec => l_oinv_rec,
                    p_iohv_rec => l_iohv_rec,
                    x_oinv_rec => lx_oinv_rec,
                    x_iohv_rec => lx_iohv_rec,
                    x_return_status => l_return_status,
                    x_msg_count => lx_msg_count,
                    x_msg_data => lx_msg_data);

                  IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_ERROR;
                  END IF;
                END LOOP;
		resultout := 'COMPLETE:';
         	RETURN ;
	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
  EXCEPTION
     when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_CO_WF','review_case',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END review_case;

  ---------------------------------------------------------------------------
  -- PROCEDURE recall_case
  ---------------------------------------------------------------------------
  PROCEDURE recall_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) AS
    l_delinquency_id NUMBER := NULL;
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := fnd_api.g_false;
    l_return_status VARCHAR2(1);
    lx_msg_count NUMBER ;
    lx_msg_data VARCHAR2(2000);

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT OIN.ID,
            OIN.KHR_ID,
            IOH.ID hst_id,
            IOH.OBJECT1_ID1,
            IOH.OBJECT1_ID2,
            IOH.JTOT_OBJECT1_CODE,
            IOH.EXT_AGNCY_ID
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,Okl_Open_Int OIN
        ,Iex_Open_Int_Hst IOH
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.object_id = oin.khr_id
    AND OIN.khr_id = TO_NUMBER(IOH.object1_id1)
    AND   IOH.jtot_object1_code = 'OKX_LEASE'
    AND   (IOH.ACTION = IEX_OPI_PVT.ACTION_TRANSFER_EXT_AGNCY)
    AND   (IOH.STATUS = IEX_OPI_PVT.STATUS_NOTIFIED OR IOH.STATUS = IEX_OPI_PVT.STATUS_PROCESSED);

    l_oinv_rec                 iex_open_interface_pub.oinv_rec_type;
    lx_oinv_rec                iex_open_interface_pub.oinv_rec_type;
    l_iohv_rec                 iex_open_interface_pub.iohv_rec_type;
    lx_iohv_rec                iex_open_interface_pub.iohv_rec_type;
  BEGIN
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                FOR cur IN l_khr_csr(l_delinquency_id) LOOP
                  l_oinv_rec.id := cur.id;
                  l_oinv_rec.khr_id := cur.khr_id;
                  l_iohv_rec.id := cur.hst_id;
                  l_iohv_rec.object1_id1 := cur.object1_id1;
                  l_iohv_rec.object1_id2 := cur.object1_id2;
                  l_iohv_rec.jtot_object1_code := cur.jtot_object1_code;
                  l_iohv_rec.ext_agncy_id := cur.ext_agncy_id;

                  iex_open_interface_pub.recall_transfer(p_api_version => l_api_version
                     ,p_init_msg_list => l_init_msg_list
                     ,p_interface_id => l_oinv_rec.id
                     ,p_recall_date => SYSDATE
                     ,p_comments => null
                     ,x_return_status => l_return_status
                     ,x_msg_count => lx_msg_count
                     ,x_msg_data => lx_msg_data);

                  IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_ERROR;
                  END IF;
                END LOOP;
		resultout := 'COMPLETE:';
         	RETURN ;
	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
  EXCEPTION
     when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_CO_WF','recall_case',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END recall_case;

  ---------------------------------------------------------------------------
  -- PROCEDURE wf_send_signal_cancelled
  ---------------------------------------------------------------------------
  /** send signal to the main work flow that the custom work
   *  flow is over and also updates the work item
   * the send signal is sent when the agent REJECTS the
   * notification since the vendor didn't approve it ,
   * so set the status to 'CANCELLED'.
   **/

  PROCEDURE wf_send_signal_cancelled(
    itemtype    in   varchar2,
    itemkey     in   varchar2,
    actid       in   number,
    funcmode    in   varchar2,
    result      out NOCOPY  varchar2)  AS

    l_work_item_id number;
    l_strategy_id number;
    l_return_status     VARCHAR2(20);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_msg_index_out number;
    i number;
    l_error VARCHAR2(32767);
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

    if (l_work_item_id is not null) then

      iex_stry_utl_pub.update_work_item(
                           p_api_version   => 1.0,
                           p_commit        => FND_API.G_TRUE,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_work_item_id  => l_work_item_id,
                           p_status        => 'CANCELLED',
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

  EXCEPTION
    when others then
      FOR i in 1..fnd_msg_pub.count_msg() LOOP
        fnd_msg_pub.get(p_data => l_msg_data,
                        p_msg_index_out => l_msg_index_out);
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage('wf_send_signal_cancelled: ' || 'error message is ' || l_msg_data);
        END IF;
        --dbms_output.put_line(to_char(i) || ':' || x_msg_data);
      END LOOP;

      --iex_strategy_wf.Get_Messages(l_msg_count,l_error);
      wf_core.context('IEX_CO_WF','wf_send_signal_cancelled',itemtype,
                       itemkey,to_char(actid),funcmode);
      raise;
  END wf_send_signal_cancelled;

  ---------------------------------------------------------------------------
  -- PROCEDURE wf_send_signal_complete
  ---------------------------------------------------------------------------
  /** send signal to the main work flow that the custom work
   *  flow is over and also updates the work item
   * the send signal is sent when the agent REJECTS the
   * notification since the vendor didn't approve it ,
   * so set the status to 'COMPLETE'.
   **/

  PROCEDURE wf_send_signal_complete(
    itemtype    in   varchar2,
    itemkey     in   varchar2,
    actid       in   number,
    funcmode    in   varchar2,
    result      out NOCOPY  varchar2)  AS

    l_work_item_id number;
    l_strategy_id number;
    l_return_status     VARCHAR2(20);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_msg_index_out number;
    i number;
    l_error VARCHAR2(32767);
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

  EXCEPTION
    when others then
      FOR i in 1..fnd_msg_pub.count_msg() LOOP
        fnd_msg_pub.get(p_data => l_msg_data,
                        p_msg_index_out => l_msg_index_out);
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage('wf_send_signal_complete: ' || 'error message is ' || l_msg_data);
        END IF;
        --dbms_output.put_line(to_char(i) || ':' || x_msg_data);
      END LOOP;

      --iex_strategy_wf.Get_Messages(l_msg_count,l_error);
      wf_core.context('IEX_CO_WF','wf_send_signal_complete',itemtype,
                       itemkey,to_char(actid),funcmode);
      raise;
  END wf_send_signal_complete;

  /*
  ---------------------------------------------------------------------------
  -- PROCEDURE raise_report_cb_event
  ---------------------------------------------------------------------------
  PROCEDURE raise_report_cb_event(p_delinquency_id IN NUMBER) AS
        l_parameter_list        wf_parameter_list_t;
        l_key                   varchar2(240);
        l_seq                   NUMBER;
        l_event_name            varchar2(240) := 'oracle.apps.iex.co.reportcb';
        l_itemtype              varchar2(240) := 'IEXCORCB';
        --l_event_name            varchar2(240) := 'oracle.apps.iex.co.transferea';
        --l_itemtype              varchar2(240) := 'IEXCOTEA';

	CURSOR okl_key_csr IS
	SELECT okl_wf_item_s.nextval
	FROM  dual;
  BEGIN
        SAVEPOINT raise_report_cb_event;

	OPEN okl_key_csr;
	FETCH okl_key_csr INTO l_seq;
	CLOSE okl_key_csr;
    l_key := l_event_name ||l_seq ;


  --Code for starting a workflow starts here
     wf_engine.createprocess(itemtype => l_itemtype,
                             itemkey  => l_key,
                             process  =>'IEX:STRATEGY_CUSTOM_WORKFLOW');


     wf_engine.SetItemAttrText(itemtype => l_itemtype,
                                 itemkey  => l_key,
                                 aname     => 'DELINQUENCY_ID',
                                 avalue    => p_delinquency_id);

     wf_engine.SetItemAttrText(itemtype => l_itemtype,
                                 itemkey  => l_key,
                                 aname     => 'PARTY_NAME',
                                 avalue    => 'Pradeep Gomes');

     wf_engine.SetItemAttrText(itemtype => l_itemtype,
                                 itemkey  => l_key,
                                 aname     => 'NOTIFICATION_USERNAME',
                                 avalue    => 'ADMIN');

     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                                     itemkey   =>  l_key,
                                     aname     => 'STRATEGY_ID',
                                     avalue    => 10128);

     wf_engine.SetItemAttrNumber(itemtype  => l_itemtype,
                                     itemkey   =>  l_key,
                                     aname     => 'WORK_ITEMID',
                                     avalue    => 10219);

    wf_engine.startprocess(itemtype => l_itemtype,
                           itemkey  => l_key);
  --Code for ending a workflow starts here

  --Code for raising an event starts here
        --wf_event.AddParameterToList('DELINQUENCY_ID',p_delinquency_id,l_parameter_list);
        --wf_event.AddParameterToList('PARTY_NAME','PRADEEP GOMES',l_parameter_list);
        --wf_event.AddParameterToList('CASE_NUMBER','PGOMES1002',l_parameter_list);
        --wf_event.AddParameterToList('NOTIFICATION_USERNAME','ADMIN',l_parameter_list);

   -- Raise Event
        --wf_event.raise(p_event_name => l_event_name
        --                ,p_event_key   => l_key
        --                ,p_parameters  => l_parameter_list);
        --   l_parameter_list.DELETE;
  --Code for raising an event ends here

EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('IEX', 'IEX_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO raise_report_cb_event;
END raise_report_cb_event;
*/

END IEX_CO_WF;

/
