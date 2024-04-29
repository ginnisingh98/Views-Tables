--------------------------------------------------------
--  DDL for Package Body OKL_CO_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CO_WF" AS
/* $Header: OKLRCOWB.pls 115.8 2002/12/18 05:51:12 rabhupat noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE get_syndicate_flag
  ---------------------------------------------------------------------------
  PROCEDURE get_syndicate_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out nocopy varchar2) AS
    l_delinquency_id NUMBER := NULL;
    l_report_after_days NUMBER := NULL;
    l_syndicate_flag VARCHAR2(10) := 'N';
    l_case_number VARCHAR2(240) := NULL;
    --l_notification_role VARCHAR2(25) := 'ADMIN';
    l_report_date Date := NULL;
    l_return_status            VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

    CURSOR l_khr_csr(cp_delinquency_id IN NUMBER) IS SELECT ico.object_id
    ,ica.case_number
    FROM iex_delinquencies_all ida
        ,iex_case_objects ico
        ,iex_cases_all_b ica
    WHERE ida.delinquency_id = cp_delinquency_id
    AND ida.case_id = ico.cas_id
    AND ico.cas_id = ica.cas_id;
  BEGIN
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                FOR cur IN l_khr_csr(l_delinquency_id) LOOP
                  --get syndicate flag
                  l_return_status := OKL_CONTRACT_INFO.get_syndicate_flag(
                                     p_contract_id => cur.object_id
                                     ,x_syndicate_flag => l_syndicate_flag);
                  l_case_number := cur.case_number;

                  IF(l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
                     raise G_EXCEPTION_HALT_VALIDATION;
                  END IF;

                  EXIT;
                END LOOP;
                resultout := 'COMPLETE:' || l_syndicate_flag;

                IF(itemtype = 'OKLCORCB') THEN
                  --get the number of days after which a notification is sent to get approval
                  --for reporting the customer to the credit bureau.
                  l_report_after_days := fnd_profile.value('IEX_CB_NOTIFY_GRACE_DAYS');
                  --l_report_after_days := 0.003;

                  l_report_date := SYSDATE + l_report_after_days;

                  wf_engine.SetItemAttrDate (itemtype=> itemtype,
			     itemkey => itemkey,
			     aname   => 'REPORT_DATE',
			     avalue  => l_report_date);
                END IF;

                wf_engine.SetItemAttrText (itemtype=> itemtype,
			     itemkey => itemkey,
			     aname   => 'CASE_NUMBER',
			     avalue  => l_case_number);

/*
                wf_engine.SetItemAttrText (itemtype=> itemtype,
			     itemkey => itemkey,
			     aname   => 'NOTIFICATION_USERNAME',
			     avalue  => l_notification_role);
*/
         	RETURN;
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
       wf_core.context('OKL_CO_WF','get_syndicate_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_syndicate_flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_sendtothirdparty_flag
  ---------------------------------------------------------------------------
  PROCEDURE get_sendtothirdparty_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_sendtothirdparty_flag VARCHAR2(10) := NULL;
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
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                --get sendto_third_party flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COPTA'
                                           ,p_segment_number => 1
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_sendtothirdparty_flag);

                    IF(l_sendtothirdparty_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

                l_sendtothirdparty_flag := UPPER(NVL(l_sendtothirdparty_flag, 'Yes'));

                IF(l_sendtothirdparty_flag = 'YES') THEN
                  l_sendtothirdparty_flag := 'Y';
                ELSE
                  l_sendtothirdparty_flag := 'N';
                END IF;
                resultout := 'COMPLETE:' || l_sendtothirdparty_flag;

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
       wf_core.context('OKL_CO_WF','get_sendtothirdparty_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_sendtothirdparty_flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_vendorapproval_flag
  ---------------------------------------------------------------------------
  PROCEDURE get_vendorapproval_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out nocopy varchar2) AS

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

  BEGIN
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                --get vendorapproval flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COPTA'
                                           ,p_segment_number => 2
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
                resultout := 'COMPLETE:' || l_vendorapproval_flag;

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
       wf_core.context('OKL_CO_WF','get_vendorapproval_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_vendorapproval_flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_vendornotify_flag
  ---------------------------------------------------------------------------
  PROCEDURE get_vendornotify_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out nocopy varchar2) AS

    l_delinquency_id NUMBER := NULL;
    l_vendornotify_flag VARCHAR2(10) := NULL;
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
    	if (funcmode = 'RUN') then
     		l_delinquency_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'DELINQUENCY_ID');

                --get vendornotify flag
                FOR cur_khr IN l_khr_csr(l_delinquency_id) LOOP
                  FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
                    l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COPTA'
                                           ,p_segment_number => 3
                                           ,x_id1 => l_id1
                                           ,x_id2 => l_id1
                                           ,x_value => l_vendornotify_flag);

                    IF(l_vendornotify_flag IS NOT NULL) THEN
                      EXIT;
                    END IF;
                  END LOOP
                  EXIT;
                END LOOP;

                l_vendornotify_flag := UPPER(NVL(l_vendornotify_flag, 'No'));

                IF(l_vendornotify_flag = 'YES') THEN
                  l_vendornotify_flag := 'Y';
                ELSE
                  l_vendornotify_flag := 'N';
                END IF;
                resultout := 'COMPLETE:' || l_vendornotify_flag;

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
       wf_core.context('OKL_CO_WF','get_vendorapproval_flag',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END get_vendornotify_flag;

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
    --get vendor_site_code flag
    FOR cur_khr IN l_khr_csr(p_case_number) LOOP
      FOR cur_rule IN l_rule_csr(cur_khr.contract_number) LOOP
          l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                                            p_contract_id => cur_rule.program_id
                                           ,p_rule_group_code => 'COAGRM'
                                           ,p_rule_code => 'COVNAG'
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

  ---------------------------------------------------------------------------
  -- PROCEDURE notify_customer
  ---------------------------------------------------------------------------
  PROCEDURE notify_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) AS
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
       wf_core.context('OKL_CO_WF','notify_customer',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
 END notify_customer;

  ---------------------------------------------------------------------------
  -- PROCEDURE wait_before_report
  ---------------------------------------------------------------------------
  PROCEDURE wait_before_report(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) AS
  l_work_item_temp_id NUMBER;
  l_result VARCHAR2(1);
  l_value VARCHAR2(300);

  BEGIN
    if funcmode <> wf_engine.eng_run then
        resultout := wf_engine.eng_null;
        return;
    end if;

    l_value :=wf_engine.GetActivityLabel(actid);
    wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);

    resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
  exception
    when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_CO_WF','wait_before_report',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END wait_before_report;

  ---------------------------------------------------------------------------
  -- PROCEDURE report_customer
  ---------------------------------------------------------------------------
  PROCEDURE report_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) AS
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
       wf_core.context('OKL_CO_WF','report_customer',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END report_customer;

  ---------------------------------------------------------------------------
  -- PROCEDURE send_vendor_approval
  ---------------------------------------------------------------------------
  PROCEDURE send_vendor_approval(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) AS
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := fnd_api.g_false;
    l_return_status VARCHAR2(1);
    lx_msg_count NUMBER ;
    lx_msg_data VARCHAR2(2000);

    l_bind_var                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_val                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_var_type            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

    l_case_number              IEX_CASES_ALL_B.CASE_NUMBER%TYPE;
    l_vendor_id                PO_VENDORS.VENDOR_ID%TYPE;
    l_vendor_name              PO_VENDORS.VENDOR_NAME%TYPE;
    l_email                    HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
    l_subject                  VARCHAR2(2000);
    l_content_id               JTF_AMV_ITEMS_B.ITEM_ID%TYPE;
    l_from                     VARCHAR2(2000);
    l_agent_id                 NUMBER;
    l_request_id               NUMBER;
  BEGIN
  if (funcmode = 'RUN') then
    --get subject
    l_subject := fnd_profile.value('OKL_VND_APPROVAL_EMAIL_SUBJECT');

    --get content_id
    l_content_id := to_number(fnd_profile.value('OKL_VND_APPROVAL_TEMPLATE'));

    --get approval_email_from
    l_from := fnd_profile.value('OKL_VND_APPROVAL_EMAIL_FROM');

    l_case_number := wf_engine.GetItemAttrText(itemtype => itemtype,
					      	  itemkey	=> itemkey,
						  aname  	=> 'CASE_NUMBER');

    l_bind_var(1) := 'p_case_number';
    l_bind_val(1) := l_case_number;
    l_bind_var_type(1) := 'VARCHAR2';

    get_vendor_info(p_case_number => l_case_number,
                      x_vendor_id => l_vendor_id,
                      x_vendor_name => l_vendor_name,
                      x_vendor_email => l_email,
                      x_return_status => l_return_status);

    wf_engine.SetItemAttrText (itemtype=> itemtype,
			     itemkey => itemkey,
			     aname   => 'VENDOR_NAME',
			     avalue  => l_vendor_name);

    l_agent_id := fnd_global.user_id;

    --call fulfillment
    OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version => l_api_version,
                              p_init_msg_list => okl_api.G_TRUE,
                              p_agent_id => l_agent_id,
                              p_content_id => l_content_id,
                              p_from => l_from,
                              p_subject => l_subject,
                              p_email => l_email,
                              p_bind_var => l_bind_var,
                              p_bind_val => l_bind_val,
                              p_bind_var_type => l_bind_var_type,
                              p_commit => okl_api.G_FALSE,
                              x_request_id => l_request_id,
                              x_return_status => l_return_status,
                              x_msg_count => lx_msg_count,
                              x_msg_data => lx_msg_data);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

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
       wf_core.context('OKL_CO_WF','send_vendor_approval',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END send_vendor_approval;

  ---------------------------------------------------------------------------
  -- PROCEDURE transfer_case
  ---------------------------------------------------------------------------
  PROCEDURE transfer_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) AS
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
       wf_core.context('OKL_CO_WF','transfer_case',itemtype,
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
                            resultout       out nocopy varchar2) AS
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
       wf_core.context('OKL_CO_WF','review_case',itemtype,
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
                            resultout       out nocopy varchar2) AS
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
       wf_core.context('OKL_CO_WF','recall_case',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END recall_case;


  ---------------------------------------------------------------------------
  -- PROCEDURE send_vendor_notify
  ---------------------------------------------------------------------------
  PROCEDURE send_vendor_notify(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) AS
    l_api_version NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := fnd_api.g_false;
    l_return_status VARCHAR2(1);
    lx_msg_count NUMBER ;
    lx_msg_data VARCHAR2(2000);

    l_bind_var                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_val                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_var_type            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

    l_case_number              IEX_CASES_ALL_B.CASE_NUMBER%TYPE;
    l_contract_id              OKC_K_HEADERS_B.ID%TYPE;
    l_vendor_id                PO_VENDORS.VENDOR_ID%TYPE;
    l_vendor_name              PO_VENDORS.VENDOR_NAME%TYPE;
    l_email                    HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
    l_subject                  VARCHAR2(2000);
    l_content_id               JTF_AMV_ITEMS_B.ITEM_ID%TYPE;
    l_from                     VARCHAR2(2000);
    l_agent_id                 NUMBER;
    l_request_id               NUMBER;

  BEGIN
  if (funcmode = 'RUN') then
    --get subject
    l_subject := fnd_profile.value('OKL_VND_NOTIFY_EMAIL_SUBJECT');

    --get content_id
    l_content_id := to_number(fnd_profile.value('OKL_VND_NOTIFY_TEMPLATE'));

    --get subject
    l_from := fnd_profile.value('OKL_VND_NOTIFY_EMAIL_FROM');

    l_case_number := wf_engine.GetItemAttrText(itemtype => itemtype,
					      	  itemkey	=> itemkey,
						  aname  	=> 'CASE_NUMBER');

    l_bind_var(1) := 'p_case_number';
    l_bind_val(1) := l_case_number;
    l_bind_var_type(1) := 'VARCHAR2';

    get_vendor_info(p_case_number => l_case_number,
                      x_vendor_id => l_vendor_id,
                      x_vendor_name => l_vendor_name,
                      x_vendor_email => l_email,
                      x_return_status => l_return_status);

    l_agent_id := fnd_global.user_id;

    --call fulfillment
    OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version => l_api_version,
                              p_init_msg_list => okl_api.G_TRUE,
                              p_agent_id => l_agent_id,
                              p_content_id => l_content_id,
                              p_from => l_from,
                              p_subject => l_subject,
                              p_email => l_email,
                              p_bind_var => l_bind_var,
                              p_bind_val => l_bind_val,
                              p_bind_var_type => l_bind_var_type,
                              p_commit => okl_api.G_FALSE,
                              x_request_id => l_request_id,
                              x_return_status => l_return_status,
                              x_msg_count => lx_msg_count,
                              x_msg_data => lx_msg_data);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

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
       wf_core.context('OKL_CO_WF','send_vendor_notify',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END send_vendor_notify;

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
    result      out  nocopy varchar2)  AS

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
        --dbms_output.put_line(to_char(i) || ':' || x_msg_data);
      END LOOP;

      --iex_strategy_wf.Get_Messages(l_msg_count,l_error);
      wf_core.context('OKL_CO_WF','wf_send_signal_cancelled',itemtype,
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
    result      out  nocopy varchar2)  AS

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
        --dbms_output.put_line(to_char(i) || ':' || x_msg_data);
      END LOOP;

      --iex_strategy_wf.Get_Messages(l_msg_count,l_error);
      wf_core.context('OKL_CO_WF','wf_send_signal_complete',itemtype,
                       itemkey,to_char(actid),funcmode);
      raise;
  END wf_send_signal_complete;

  ---------------------------------------------------------------------------
  -- FUNCTION get_party_name
  ---------------------------------------------------------------------------
  FUNCTION get_party_name(p_case_number in varchar2) RETURN VARCHAR2 AS
    l_party_id   NUMBER;
    l_party_name VARCHAR2(360);
    l_return_status VARCHAR2(1) := 'S';

    CURSOR l_party_csr(cp_case_number in varchar2) IS SELECT hp.party_name
    FROM IEX_CASES_ALL_B ica
        ,HZ_PARTIES hp
    WHERE ica.case_number = cp_case_number
    AND   ica.party_id = hp.party_id;
  BEGIN
    FOR cur IN l_party_csr(p_case_number) LOOP
      l_party_name := cur.party_name;
    END LOOP;

    RETURN l_party_name;
  END get_party_name;

  ---------------------------------------------------------------------------
  -- FUNCTION get_case_contracts
  ---------------------------------------------------------------------------
  FUNCTION get_case_contracts(p_case_number in varchar2) RETURN VARCHAR2 AS
    CURSOR l_contract_csr(cp_case_number in varchar2) IS SELECT okh.contract_number
    FROM IEX_CASES_ALL_B ica
        ,IEX_CASE_OBJECTS ico
        ,OKC_K_HEADERS_V okh
    WHERE ica.case_number = cp_case_number
    AND   ica.cas_id = ico.cas_id
    AND   ico.object_id = okh.id;

    l_contracts varchar2(2000);
    l_comma varchar2(10) := NULL;
  BEGIN
    FOR cur IN l_contract_csr(p_case_number) LOOP
      l_contracts := l_contracts || l_comma || cur.contract_number;
      l_comma := ', ';
    END LOOP;
    RETURN l_contracts;
  END get_case_contracts;

  ---------------------------------------------------------------------------
  -- FUNCTION get_case_total_value
  ---------------------------------------------------------------------------
  FUNCTION get_case_total_value(p_case_number in varchar2) RETURN NUMBER AS
    CURSOR l_contract_csr(cp_case_number in varchar2) IS SELECT okh.id
    FROM IEX_CASES_ALL_B ica
        ,IEX_CASE_OBJECTS ico
        ,OKC_K_HEADERS_V okh
    WHERE ica.case_number = cp_case_number
    AND   ica.cas_id = ico.cas_id
    AND   ico.object_id = okh.id;

    l_case_total number := 0;
  BEGIN
    FOR cur IN l_contract_csr(p_case_number) LOOP
    l_case_total := l_case_total + NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_oec(p_chr_id => cur.id, p_line_id => NULL),0)
    - NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_tradein(p_chr_id => cur.id, p_line_id => NULL),0)
    - NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_capital_reduction(p_chr_id => cur.id, p_line_id => NULL),0)
    + NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_fees_capitalized(p_chr_id => cur.id, p_line_id => NULL),0);
    END LOOP;
    RETURN l_case_total;
  END get_case_total_value;

  ---------------------------------------------------------------------------
  -- FUNCTION get_amt_overdue
  ---------------------------------------------------------------------------
  FUNCTION get_amt_overdue(p_case_number in varchar2) RETURN NUMBER AS
    CURSOR l_khr_past_due_csr(cp_case_number in varchar2) IS
    SELECT sum(nvl(aps.amount_due_remaining, 0)) past_due_amount
    FROM iex_cases_all_b ica
        ,iex_case_objects ico
        ,okl_cnsld_ar_strms_b ocas
        ,ar_payment_schedules_all aps
    WHERE ica.case_number = cp_case_number
    AND   ica.cas_id = ico.cas_id
    AND   ico.object_id = ocas.khr_id
    AND   ocas.receivables_invoice_id = aps.customer_trx_id
    AND   aps.class = 'INV'
    AND   aps.due_date < sysdate
    AND   nvl(aps.amount_due_remaining, 0) > 0;

    l_amt_overdue number := 0;
  BEGIN
    FOR cur IN l_khr_past_due_csr(p_case_number) LOOP
      l_amt_overdue := l_amt_overdue + cur.past_due_amount;
    END LOOP;
    RETURN l_amt_overdue;
  END get_amt_overdue;

  ---------------------------------------------------------------------------
  -- FUNCTION get_vendor_name
  ---------------------------------------------------------------------------
  FUNCTION get_vendor_name(p_case_number in varchar2) RETURN VARCHAR2 AS
    --how to obtain the vendor site
    CURSOR l_vendor_csr(cp_case_number in varchar2) IS SELECT pv.vendor_name
     FROM  iex_cases_all_b ica
          ,iex_case_objects ico
          ,okc_k_party_roles_v opr
          ,po_vendors pv
          ,po_vendor_sites_all pvs
     WHERE ica.case_number = cp_case_number
     AND   ica.cas_id = ico.cas_id
     AND   ico.object_id =opr.dnz_chr_id
     AND   opr.rle_code = 'OKL_VENDOR'
     AND   opr.object1_id1 = pv.vendor_id
     AND   pv.vendor_id = pvs.vendor_id;

     l_vendor_name PO_VENDORS.VENDOR_NAME%TYPE;
  BEGIN
   FOR cur IN l_vendor_csr(p_case_number) LOOP
     l_vendor_name := cur.vendor_name;
     exit;
   END LOOP;
   RETURN l_vendor_name;
  END get_vendor_name;

  /*
  ---------------------------------------------------------------------------
  -- PROCEDURE raise_report_cb_event
  ---------------------------------------------------------------------------
  PROCEDURE raise_report_cb_event(p_delinquency_id IN NUMBER) AS
        l_parameter_list        wf_parameter_list_t;
        l_key                   varchar2(240);
        l_seq                   NUMBER;
        l_event_name            varchar2(240) := 'oracle.apps.okl.co.reportcb';
        l_itemtype              varchar2(240) := 'OKLCORCB';
        --l_event_name            varchar2(240) := 'oracle.apps.okl.co.transferea';
        --l_itemtype              varchar2(240) := 'OKLCOTEA';

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
                                     aname     => 'WORK_ITEMID',
                                     avalue    => 123456789012345678901234567890);

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
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO raise_report_cb_event;
END raise_report_cb_event;
*/

END OKL_CO_WF;

/
