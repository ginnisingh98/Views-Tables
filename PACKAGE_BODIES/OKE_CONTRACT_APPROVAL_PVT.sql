--------------------------------------------------------
--  DDL for Package Body OKE_CONTRACT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CONTRACT_APPROVAL_PVT" as
/* $Header: OKEVCAPB.pls 115.3 2002/12/02 21:05:13 alaw ship $ */
--
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKE_CONTRACT_APPROVAL_PVT';
  G_LEVEL				CONSTANT VARCHAR2(4)   := '_PVT';
  l_api_version               CONSTANT NUMBER := 1;
  G_FND_APP				CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
--
  G_K_WAS_APPROVED CONSTANT   varchar2(200) := 			'OKC_ALREADY_APPROVED';
--
  G_PROCESS_NOT_FOR_APPROVAL CONSTANT   varchar2(200) := 	'OKC_PROCESS_NOT_FOR_APPROVAL';
  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 			'WF_ITEM';
  G_WF_P_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_PROCESS';
--
  G_PROCESS_NOTFOUND CONSTANT   varchar2(200) := 		'OKC_PROCESS_NOT_FOUND';
--
  G_K_ON_APPROVAL CONSTANT   varchar2(200) := 			'OKC_IS_ON_APPROVAL';
--  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_ITEM';
  G_KEY_TOKEN CONSTANT   varchar2(200) := 			'WF_KEY';
--
  G_WF_NOT_PURGED CONSTANT   varchar2(200) := 			'OKC_WF_NOT_PURGED';
--  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_ITEM';
--  G_KEY_TOKEN CONSTANT   varchar2(200) := 			'WF_KEY';
--
  G_K_NOT_ON_APPROVAL CONSTANT   varchar2(200) := 		'OKC_PROCESS_NOT_ACTIVE';
--
  G_NO_U_PRIVILEGE CONSTANT   varchar2(200) := 			'OKC_NO_RIGHT_TO_CHANGE';

-- Start of comments
--
-- Procedure Name  : k_approval_start
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approval_start(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKE_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_contract_id IN number,
				p_process_id IN number,
				p_do_commit IN VARCHAR2 default OKE_API.G_TRUE
			) is
l_api_name                     CONSTANT VARCHAR2(30) := 'k_approval_start';
l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
--
l_key varchar2(240);
l_contract_number varchar2(120);
l_contract_number_modifier varchar2(120);
l_date_approved date;
--
l_wf_name_active varchar2(150);
l_wf_name varchar2(150);
l_wf_process_name varchar2(150);
l_usage varchar2(60);
--
l_q varchar2(1);
--
L_PAR_NAME      	VARCHAR2(150);
L_PAR_TYPE       VARCHAR2(90);
L_PAR_VALUE   VARCHAR2(2000);
--
L_NLS_VALUE VARCHAR2(30);
--
L1_CPSV_REC  OKC_CONTRACT_PUB.cpsv_rec_type;
L2_CPSV_REC  OKC_CONTRACT_PUB.cpsv_rec_type;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
cursor k_pid is
  select ID
  from okc_k_processes_v
  where CHR_ID = p_contract_id
    and PDF_ID = p_process_id
--because of bug in lock API
	for update of process_id nowait;
--
cursor k_header_csr is
  select H.CONTRACT_NUMBER,
    H.CONTRACT_NUMBER_MODIFIER,
    H.DATE_APPROVED,
	S.MEANING,
	S.STE_CODE
  from OKC_K_HEADERS_B H, okc_statuses_v S
  where H.ID = p_contract_id
	and H.STS_CODE=S.CODE;
l_status varchar2(100);
l_status_type varchar2(100);
--
cursor process_def_csr is
  select WF_NAME, WF_PROCESS_NAME, USAGE
  from OKC_PROCESS_DEFS_B
     where ID = p_process_id
  and begin_date<=sysdate
  and (end_date is NULL or end_date>=sysdate) and PDF_TYPE='WPS';
--
cursor approval_active_csr is
  select item_type
  from WF_ITEMS
  where item_type in
   ( select wf_name
     from OKC_PROCESS_DEFS_B
     where USAGE='APPROVE' and PDF_TYPE='WPS')
   and item_key = l_key
   and end_date is NULL;

--
cursor for_purge_csr is
  select '!'
  from WF_ITEMS
  where item_type = l_wf_name
   and item_key = l_key;
--
cursor defined_parameters_csr is
  select
    NAME,
    DATA_TYPE,
    DEFAULT_VALUE
  from OKC_PROCESS_DEF_PARAMETERS_V
  where PDF_ID = p_process_id;
--
begin
  l_return_status := OKE_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;
--
/*  if k_accesible( p_contract_id => p_contract_id,
			p_user_id => fnd_global.user_id,
			p_level => 'U'
		     ) = OKE_API.G_FALSE
  then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_NO_U_PRIVILEGE);
    raise OKE_API.G_EXCEPTION_ERROR;
  end if; */
  open k_header_csr;
  fetch k_header_csr
  into L_CONTRACT_NUMBER, L_CONTRACT_NUMBER_MODIFIER, L_DATE_APPROVED, L_STATUS, L_STATUS_TYPE;
  close k_header_csr;
  if (L_DATE_APPROVED is not NULL) then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_K_WAS_APPROVED);
    raise OKE_API.G_EXCEPTION_ERROR;
  end if;
  if (L_STATUS_TYPE <> 'ENTERED') then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => 'OKC_INVALID_K_STATUS',
                        p_token1       => 'NUMBER',
                        p_token1_value => L_CONTRACT_NUMBER||'-'||L_CONTRACT_NUMBER_MODIFIER,
                        p_token2       => 'STATUS',
                        p_token2_value => L_STATUS);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
  open process_def_csr;
  fetch process_def_csr into L_WF_NAME, L_WF_PROCESS_NAME, L_USAGE;
  close process_def_csr;
  if (L_WF_NAME is NULL) then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_PROCESS_NOTFOUND);
    raise OKE_API.G_EXCEPTION_ERROR;
  end if;
  if (L_USAGE <> 'APPROVE') then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_PROCESS_NOT_FOR_APPROVAL,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME,
                        p_token2       => G_WF_P_NAME_TOKEN,
                        p_token2_value => L_WF_PROCESS_NAME);
    raise OKE_API.G_EXCEPTION_ERROR;
  end if;
--
  L_KEY := L_CONTRACT_NUMBER||L_CONTRACT_NUMBER_MODIFIER;
  open approval_active_csr;
  fetch approval_active_csr into L_WF_NAME_ACTIVE;
  close approval_active_csr;
  if (L_WF_NAME_ACTIVE is not NULL) then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_K_ON_APPROVAL,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME_ACTIVE,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
    raise OKE_API.G_EXCEPTION_ERROR;
  end if;
--
  L_Q:='?';
  open for_purge_csr;
  fetch for_purge_csr into L_Q;
  close for_purge_csr;
  if (L_Q = '!') then
  begin
    wf_purge.total(l_wf_name,l_key);
  exception
  when others then
    begin
      wf_purge.totalPerm(l_wf_name,l_key);
    exception
    when others then
      OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_WF_NOT_PURGED,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
      raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    end;
  end;
  end if;
--
/*  OKC_CONTRACT_PUB.lock_contract_process(
    p_api_version		=> l_api_version,
    x_return_status	=> l_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_cpsv_rec     	=> L1_CPSV_REC);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
*/
  begin
    savepoint BECAUSE_OF_BUG_IN_lock;
    open k_pid;
    fetch k_pid into L1_CPSV_REC.id;
    close k_pid;
  exception
    when others then
	rollback to BECAUSE_OF_BUG_IN_lock;
      OKE_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
      RAISE OKE_API.G_EXCEPTION_ERROR;
  end;
    L1_CPSV_REC.PROCESS_ID := L_KEY;
    OKC_CONTRACT_PUB.update_contract_process(
      p_api_version		=> l_api_version,
      x_return_status	=> l_return_status,
      x_msg_count		=> l_msg_count,
      x_msg_data		=> l_msg_data,
      p_cpsv_rec		=> L1_CPSV_REC,
      x_cpsv_rec		=> L2_CPSV_REC);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
	rollback to BECAUSE_OF_BUG_IN_lock;
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
	rollback to BECAUSE_OF_BUG_IN_lock;
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    wf_engine.CreateProcess( ItemType => L_WF_NAME,
				 ItemKey  => L_KEY,
				 process  => L_WF_PROCESS_NAME);
    wf_engine.SetItemUserKey (ItemType	=> L_WF_NAME,
					ItemKey		=> L_KEY,
					UserKey		=> L_KEY);
/* -- commented not to jeopardize wf by wrong data format,
   -- instead use process_id attribute

    open defined_parameters_csr;
    LOOP
      fetch defined_parameters_csr into
        L_PAR_NAME,
        L_PAR_TYPE,
        L_PAR_VALUE;
      exit when defined_parameters_csr%NOTFOUND;
      if L_PAR_TYPE = 'C' then
      begin
	  wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME,
						avalue	=> L_PAR_VALUE);
        exception
        when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME);
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME,
						avalue	=> L_PAR_VALUE);
      end;
      elsif L_PAR_TYPE = 'N' then
      begin
	  wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME,
						avalue	=> to_number(L_PAR_VALUE));
        exception
        when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME);
 	    wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME,
						avalue	=> to_number(L_PAR_VALUE));
      end;
      elsif L_PAR_TYPE = 'D' then
      begin
	  wf_engine.SetItemAttrDate (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME,
						avalue	=> fnd_date.chardate_to_date(L_PAR_VALUE));
        exception
        when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME);
	  wf_engine.SetItemAttrDate (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> L_PAR_NAME,
						avalue	=> fnd_date.chardate_to_date(L_PAR_VALUE));
      end;
      end if;
    END LOOP;
*/
-- replacement to previous commented
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'PROCESS_ID',
						avalue	=> p_process_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'PROCESS_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'PROCESS_ID',
						avalue	=> p_process_id);
    end;
--
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'CONTRACT_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID');
	    wf_engine.SetItemAttrNumber(itemtype	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> fnd_global.SECURITY_GROUP_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> fnd_global.SECURITY_GROUP_id);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_FORMAT';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select '"'||value||'"' into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_NUMERIC_CHARACTERS';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    end;
    wf_engine.SetItemOwner (	itemtype => L_WF_NAME,
					itemkey  => L_KEY,
					owner	   => fnd_global.user_name);
    wf_engine.StartProcess( 	itemtype => L_WF_NAME,
	      			itemkey  => L_KEY);
  if (p_do_commit = OKE_API.G_TRUE) then
	commit;
  end if;
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKE_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKE_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKE_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKE_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end k_approval_start;

-- Start of comments
--
-- Procedure Name  : wf_monitor_url
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function wf_monitor_url(
				p_contract_id IN number,
				p_process_id IN number,
				p_mode IN varchar2 default 'USER'
		    ) return varchar2 is
--  to be used by fnd_utilities.open_url
l_wf_name varchar2(150);
l_key varchar2(240);
l_q varchar2(1);
l_admin varchar2(3);
--
cursor wf_name_csr is
  select WF_NAME
  from OKC_PROCESS_DEFS_B
     where ID = p_process_id and PDF_TYPE='WPS';
--
cursor wf_key_csr is
  select CONTRACT_NUMBER||CONTRACT_NUMBER_MODIFIER wf_key
  from OKC_K_HEADERS_B
  where ID = p_contract_id;
--
cursor wf_exist_csr is
  select '!'
  from WF_ITEMS
  where item_type = l_wf_name
   and item_key = l_key;
--
begin
  open wf_name_csr;
  fetch wf_name_csr into L_WF_NAME;
  close wf_name_csr;
--
  open wf_key_csr;
  fetch wf_key_csr into L_KEY;
  close wf_key_csr;
--
  l_q := '?';
  open wf_exist_csr;
  fetch wf_exist_csr into L_Q;
  close wf_exist_csr;
--
  if l_q = '?' then return NULL;
  else
    if p_mode = 'ADMIN' then l_admin := 'YES';
    else l_admin := 'NO';
    end if;
    return wf_monitor.GetDiagramURL(
	 X_AGENT => WF_CORE.TRANSLATE('WF_WEB_AGENT'),
	 X_ITEM_TYPE => L_WF_NAME,
	 X_ITEM_KEY => L_KEY,
	 X_ADMIN_MODE => l_admin);
  end if;
end wf_monitor_url;

-- Start of comments
--
-- Procedure Name  : k_approval_stop
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approval_stop(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 default OKE_API.G_FALSE,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_contract_id number,
				p_do_commit IN VARCHAR2 default OKE_API.G_TRUE
		    ) is
l_api_name                     CONSTANT VARCHAR2(30) := 'k_approval_stop';
l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
--
l_q varchar2(1);
l_key varchar2(240);
l_wf_name_active varchar2(150);
l_contract_number varchar2(120);
l_contract_number_modifier varchar2(120);
L_K_SHORT_DESCRIPTION varchar2(2000);
L_NLS_VALUE VARCHAR2(30);
--
cursor wf_key_csr is
  select CONTRACT_NUMBER||CONTRACT_NUMBER_MODIFIER wf_key,
	CONTRACT_NUMBER, CONTRACT_NUMBER_MODIFIER,
	short_description
  from OKC_K_HDR_AGREEDS_V
  where ID = p_contract_id;
--
cursor approval_active_csr is
  select item_type
  from WF_ITEMS
  where item_type in
   ( select wf_name
     from OKC_PROCESS_DEFS_B
     where USAGE='APPROVE' and PDF_TYPE='WPS')
   and item_key = l_key
   and end_date is NULL;
--
cursor abort_csr is
  select '!'
  from wf_activities
  where item_type=l_wf_name_active
  and TYPE='PROCESS' and NAME='ABORT_PROCESS'
;
--
cursor C_INITIATOR_DISPLAY_NAME is
/*
  select display_name
  from wf_roles
  where orig_system = 'FND_USR'
  and orig_system_id=fnd_global.user_id
-- changed to boost perf
*/
  select user_name display_name from fnd_user where user_id=fnd_global.user_id and EMPLOYEE_ID is null
  	union all
  select
       PER.FULL_NAME display_name
  from
       PER_PEOPLE_F PER,
       FND_USER USR
  where  trunc(SYSDATE)
      between PER.EFFECTIVE_START_DATE and PER.EFFECTIVE_END_DATE
    and    PER.PERSON_ID       = USR.EMPLOYEE_ID
    and USR.USER_ID = fnd_global.user_id
;
--
L_INITIATOR_NAME varchar2(100);
L_FINAL_APPROVER_UNAME varchar2(100);
L_INITIATOR_DISPLAY_NAME varchar2(200);
--
begin
  l_return_status := OKE_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;
--
/*  if k_accesible( p_contract_id => p_contract_id,
			p_user_id => fnd_global.user_id,
			p_level => 'U'
		     ) = OKE_API.G_FALSE
  then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_NO_U_PRIVILEGE);
    raise OKE_API.G_EXCEPTION_ERROR;
  end if; */
--
  open wf_key_csr;
  fetch wf_key_csr into L_KEY,l_contract_number,l_contract_number_modifier,L_K_SHORT_DESCRIPTION;
  close wf_key_csr;
--
  open approval_active_csr;
  fetch approval_active_csr into l_wf_name_active;
  close approval_active_csr;
--
  if l_wf_name_active is NULL then
    OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_K_NOT_ON_APPROVAL);
      raise OKE_API.G_EXCEPTION_ERROR;
  end if;
  wf_engine.abortprocess(l_wf_name_active,l_key);
  k_erase_approved(
			p_contract_id => p_contract_id,
                  x_return_status => l_return_status
		    );
  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;
--+
  L_Q:='?';
  open abort_csr;
  fetch abort_csr into L_Q;
  close abort_csr;
--+
--+ if abort process defined
--+
  if (L_Q = '!') then
-- previous initiator Uname
    L_INITIATOR_NAME := wf_engine.GetItemAttrText(l_wf_name_active,L_KEY,'INITIATOR_NAME');
-- last approver Uname
    L_FINAL_APPROVER_UNAME := NVL(
	wf_engine.GetItemAttrText(l_wf_name_active,L_KEY,'NEXT_PERFORMER_USERNAME'),
	wf_engine.GetItemAttrText(l_wf_name_active,L_KEY,'FINAL_APPROVER_UNAME')
      );
    if (L_FINAL_APPROVER_UNAME = L_INITIATOR_NAME) then
	L_FINAL_APPROVER_UNAME := NULL;
    end if;
    begin
      wf_purge.total(l_wf_name_active,l_key);
    exception
    when others then
      begin
        wf_purge.totalPerm(l_wf_name_active,l_key);
      exception
        when others then
          OKE_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_WF_NOT_PURGED,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => l_wf_name_active,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
          raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      end;
    end;
    wf_engine.CreateProcess( ItemType => l_wf_name_active,
				 ItemKey  => L_KEY,
				 process  => 'ABORT_PROCESS');
    wf_engine.SetItemUserKey (ItemType	=> l_wf_name_active,
					ItemKey		=> L_KEY,
					UserKey		=> L_KEY);
--+
--+ attributes
--+
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'CONTRACT_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> p_contract_id);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER',
						avalue	=> l_contract_number);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_NUMBER_MODIFIER',
						avalue	=> l_contract_number_MODIFIER);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION',
						avalue	=> L_K_SHORT_DESCRIPTION);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION',
						avalue	=> L_K_SHORT_DESCRIPTION);
    end;
-- current initiator Dname
    open C_INITIATOR_DISPLAY_NAME;
    fetch C_INITIATOR_DISPLAY_NAME into L_INITIATOR_DISPLAY_NAME;
    close C_INITIATOR_DISPLAY_NAME;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_DISPLAY_NAME',
						avalue	=> L_INITIATOR_DISPLAY_NAME);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_DISPLAY_NAME');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_DISPLAY_NAME',
						avalue	=> L_INITIATOR_DISPLAY_NAME);
    end;
-- previous initiator Uname
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_NAME',
						avalue	=> L_INITIATOR_NAME);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_NAME');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'INITIATOR_NAME',
						avalue	=> L_INITIATOR_NAME);
    end;
-- previous approver Uname
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'FINAL_APPROVER_UNAME',
						avalue	=> L_FINAL_APPROVER_UNAME);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'FINAL_APPROVER_UNAME');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'FINAL_APPROVER_UNAME',
						avalue	=> L_FINAL_APPROVER_UNAME);
    end;
--
-- environment
--
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID');
	    wf_engine.SetItemAttrNumber(itemtype	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> fnd_global.SECURITY_GROUP_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SECURITY_GROUP_ID',
						avalue	=> fnd_global.SECURITY_GROUP_id);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_FORMAT';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_FORMAT',
						avalue	=> L_NLS_VALUE);
    end;
    select value into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_DATE_LANGUAGE';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_DATE_LANGUAGE',
						avalue	=> L_NLS_VALUE);
    end;
    select '"'||value||'"' into L_NLS_VALUE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_NUMERIC_CHARACTERS';
    begin
      wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS');
	    wf_engine.SetItemAttrText (itemtype 	=> l_wf_name_active,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NLS_NUMERIC_CHARACTERS',
						avalue	=> L_NLS_VALUE);
    end;
--
-- start
--
    wf_engine.SetItemOwner (	itemtype => l_wf_name_active,
					itemkey  => L_KEY,
					owner	   => fnd_global.user_name);
    wf_engine.StartProcess( 	itemtype => l_wf_name_active,
	      			itemkey  => L_KEY);

  end if;--+ abort process exists
--
  if (p_do_commit = OKE_API.G_TRUE) then
	commit;
  end if;
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKE_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKE_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKE_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKE_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end k_approval_stop;

-- Start of comments
--
-- Procedure Name  : wf_copy_env
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure wf_copy_env(	p_item_type varchar2,
				p_item_key varchar2) is
L_NLS_VALUE1 varchar2(40);
L_NLS_VALUE2 varchar2(40);
L_NLS_VALUE3 varchar2(40);
L_NLS_VALUE4 varchar2(40);
L_NLS_VALUE11 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_LANGUAGE');
L_NLS_VALUE12 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_DATE_FORMAT');
L_NLS_VALUE13 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_DATE_LANGUAGE');
L_NLS_VALUE14 varchar2(40) := wf_engine.GetItemAttrText(p_item_type,p_item_key,'NLS_NUMERIC_CHARACTERS');
cursor c1(p varchar2) is
  select value
  from NLS_SESSION_PARAMETERS
  where PARAMETER=p;
begin
    open c1('NLS_LANGUAGE');
    fetch c1 into L_NLS_VALUE1;
    close c1;
    open c1('NLS_DATE_FORMAT');
    fetch c1 into L_NLS_VALUE2;
    close c1;
    open c1('NLS_DATE_LANGUAGE');
    fetch c1 into L_NLS_VALUE3;
    close c1;
    open c1('NLS_NUMERIC_CHARACTERS');
    fetch c1 into L_NLS_VALUE4;
    L_NLS_VALUE4 := '"'||L_NLS_VALUE4||'"';
    close c1;
   if not(
	(L_NLS_VALUE11 = L_NLS_VALUE1) and
	(L_NLS_VALUE12 = L_NLS_VALUE2) and
	(L_NLS_VALUE13 = L_NLS_VALUE3) and
	(L_NLS_VALUE14 = L_NLS_VALUE4)
   ) then
    fnd_global.set_nls_context
    (
	P_NLS_LANGUAGE => L_NLS_VALUE11,
	P_NLS_DATE_FORMAT => L_NLS_VALUE12,
	P_NLS_DATE_LANGUAGE => L_NLS_VALUE13,
	P_NLS_NUMERIC_CHARACTERS => L_NLS_VALUE14);
  end if;
  fnd_global.apps_initialize
    (
	user_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'USER_ID'),
	resp_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'RESP_ID'),
	resp_appl_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'RESP_APPL_ID'),
	security_group_id =>
     		wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'SECURITY_GROUP_ID')
  );
--  okc_context.set_okc_org_context;
end wf_copy_env;

-- Start of comments
--
-- Procedure Name  : k_accesible
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function k_accesible(
			p_contract_id IN number,
			p_user_id IN number,
			p_level IN varchar2 default 'R'
		     ) return varchar2 is
l_q varchar2(1);
/*
 cursor check_access_csr is
(select '!'
 from OKC_K_ACCESSES
 where chr_id = p_contract_id
 and user_id = p_user_id
 and (p_level='R' or access_level='U')
)
  UNION ALL
(select '!' from dual
 where exists
 (select agp_code
  from OKC_K_ACCESSES
  where chr_id = P_CONTRACT_ID
  and (p_level='R' or access_level='U')
    INTERSECT
  SELECT AGP_CODE
  FROM okc_acc_group_members
  where begin_date<=sysdate
   and (end_date is null or end_date>=sysdate)
  start with user_id = p_user_id
  CONNECT BY PRIOR AGP_CODE = AGP_CODE_COMPOSED_OF
 )
);
*/
begin
  l_q :=okc_util.get_k_access_level(p_chr_id => p_contract_id);
  if ((l_q = p_level) or (l_q = 'U'))
    then return OKC_API.G_TRUE;
    else return OKC_API.G_FALSE;
  end if;
/*
--
  open check_access_csr;
  fetch check_access_csr into l_q;
  close check_access_csr;
--

  if l_q = '?' then return OKC_API.G_FALSE;
  else return OKC_API.G_TRUE;
  end if;
*/

end k_accesible;

--
-- private procedure
-- to set context of db failure
--
procedure db_failed(p_oper varchar2) is
begin
      FND_MESSAGE.SET_NAME(application => G_APP_NAME,
                      	name     => 'OKC_DB_OPERATION_FAILED');
-- OKC_SIGN  OKC_APPROVE OKC_REVOKE
      FND_MESSAGE.SET_TOKEN(token => 'OPERATION',
                      	value     => p_oper,
				translate => TRUE);
      FND_MSG_PUB.add;
end db_failed;


-- Start of comments
--
-- Procedure Name  : k_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_approved(
			p_contract_id IN number,
			p_date_approved IN date default sysdate,
			x_return_status OUT NOCOPY varchar2
		    ) is
L1_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
L2_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
cursor lock_csr(p number) is
  	select object_version_number
  	from okc_k_headers_b
  	where ID = p
;
l_api_name                     CONSTANT VARCHAR2(30) := 'k_approved';
l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
begin

--start
  l_return_status := OKE_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              OKE_API.G_TRUE,
                                              l_api_version,
                                              l_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

--lock
  L1_header_rec.id := p_contract_id;
  open lock_csr(p_contract_id);
  fetch lock_csr into L1_header_rec.object_version_number;
  close lock_csr;
  OKC_CONTRACT_PUB.lock_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_chrv_rec		=> L1_header_rec);
  IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

--update
  L1_header_rec.date_approved := p_date_approved;
  OKC_CONTRACT_PUB.update_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    p_init_msg_list     => OKE_API.G_TRUE,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKE_API.G_TRUE,
    p_chrv_rec		=> L1_header_rec,
    x_chrv_rec		=> L2_header_rec);
  IF (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

--end
  OKE_API.END_ACTIVITY(l_msg_count, l_msg_data);
  EXCEPTION
     WHEN OKE_API.G_EXCEPTION_ERROR THEN
	 db_failed('OKC_APPROVE');
       x_return_status := OKE_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	 db_failed('OKC_APPROVE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
	 db_failed('OKC_APPROVE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
end k_approved;

-- Start of comments
--
-- Procedure Name  : k_erase_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_erase_approved(
			p_contract_id IN number,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    ) is
L1_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
L2_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
dummy varchar2(1) := '?';
cursor c1 is
  select '!'
  from OKC_K_HEADERS_B
  where ID = p_contract_id and date_approved is not null;
--
cursor lock_csr(p number) is
  	select object_version_number
  	from OKC_K_HEADERS_B
  	where ID = p
;
l_api_name                     CONSTANT VARCHAR2(30) := 'k_erase_approved';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
begin

--check if do anything
  open c1;
  fetch c1 into dummy;
  close c1;
  if (dummy = '?') then
	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	return;
  end if;

--start
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              OKC_API.G_TRUE,
                                              l_api_version,
                                              l_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--lock
  L1_header_rec.id := p_contract_id;
  open lock_csr(p_contract_id);
  fetch lock_csr into L1_header_rec.object_version_number;
  close lock_csr;
  OKC_CONTRACT_PUB.lock_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_chrv_rec		=> L1_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--update
  L1_header_rec.date_approved := NULL;
  OKC_CONTRACT_PUB.update_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKC_API.G_TRUE,
    p_chrv_rec		=> L1_header_rec,
    x_chrv_rec		=> L2_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--end
  OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
	 db_failed('OKC_REVOKE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	 db_failed('OKC_REVOKE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
	 db_failed('OKC_REVOKE');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
end k_erase_approved;

-- Start of comments
--
-- Procedure Name  : k_signed
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure k_signed(
			p_contract_id IN number,
			p_date_signed IN date default sysdate,
                  x_return_status	OUT NOCOPY	VARCHAR2
		    ) is
l_api_name                     CONSTANT VARCHAR2(30) := 'k_signed';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data varchar2(2000);

L1_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
L2_header_rec OKC_CONTRACT_PUB.chrv_rec_type;
cursor lock_csr(p number) is
  	select object_version_number, START_DATE, END_DATE
  	from okc_k_headers_b
  	where ID = p
;
--
l_new_status varchar2(30);
l_signed_status varchar2(30);
l_active_status varchar2(30);
l_expired_status varchar2(30);
cursor c1 is
  select code from okc_statuses_b
  where ste_code='SIGNED'
    and default_yn='Y';
cursor c2 is
  select code from okc_statuses_b
  where ste_code='ACTIVE'
    and default_yn='Y';
cursor c3 is
  select code from okc_statuses_b
  where ste_code='EXPIRED'
    and default_yn='Y';
--
cursor lock1_csr is
  	select L.ID ID, L.object_version_number
,decode(sign(months_between(sysdate-1, NVL(L.end_date,sysdate))),-1,
  decode(sign(months_between(p_date_signed-1,sysdate)),-1,
    decode(sign(months_between(L.start_date-1,sysdate)),-1,
	l_active_status,l_signed_status),l_signed_status),l_expired_status) STS_CODE
from okc_k_lines_b L
	, okc_statuses_b S
  	where L.dnz_chr_id = p_contract_id
	and S.code = L.sts_code
	and S.ste_code='ENTERED'
;
--
loc1_rec lock1_csr%ROWTYPE;
i number :=0;
--
l1_lines okc_contract_pub.clev_tbl_type;
l2_lines okc_contract_pub.clev_tbl_type;
l3_lines okc_contract_pub.clev_tbl_type;
--
call_time varchar2(1);

begin

--start
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              OKC_API.G_TRUE,
                                              l_api_version,
                                              l_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--lock header
  L1_header_rec.id := p_contract_id;
  open lock_csr(p_contract_id);
  fetch lock_csr into
	L1_header_rec.object_version_number,L1_header_rec.START_DATE,L1_header_rec.END_DATE;
  close lock_csr;
  OKC_CONTRACT_PUB.lock_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_chrv_rec		=> L1_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--update header
  L1_header_rec.date_signed := p_date_signed;
--
  open c1;
  fetch c1 into l_signed_status;
  close c1;
--
  open c2;
  fetch c2 into l_active_status;
  close c2;
--
  open c3;
  fetch c3 into l_expired_status;
  close c3;
--
  l_new_status := l_signed_status; call_time := 'Y';
  if (L1_header_rec.date_signed <= sysdate
	and L1_header_rec.START_DATE <= sysdate
	and (L1_header_rec.END_DATE is NULL or sysdate<=L1_header_rec.END_DATE+1)) then
    l_new_status := l_active_status; call_time := 'Y';
  end if;
  if (sysdate>L1_header_rec.END_DATE+1) then
    l_new_status := l_expired_status; call_time := 'N';
  end if;
  L1_header_rec.STS_CODE := l_new_status;

  OKC_CONTRACT_PUB.update_contract_header(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKC_API.G_TRUE,
    p_chrv_rec		=> L1_header_rec,
    x_chrv_rec		=> L2_header_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

-- lock lines
  for lock1_rec in lock1_csr LOOP
	i := i+1;
	l1_lines(i).id := lock1_rec.id;
	l1_lines(i).object_version_number := lock1_rec.object_version_number;
--
	l2_lines(i).id := lock1_rec.id;
	l2_lines(i).object_version_number := lock1_rec.object_version_number;
	l2_lines(i).sts_code := lock1_rec.sts_code;
  end LOOP;
  OKC_CONTRACT_PUB.lock_contract_line(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_clev_tbl    	=> l1_lines);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

-- update lines
OKC_CONTRACT_PUB.update_contract_line(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKC_API.G_TRUE,
    p_clev_tbl => l2_lines,
    x_clev_tbl => l3_lines);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

-- call time ...
   if (call_time = 'Y') then
     OKC_TIME_RES_PUB.Res_Time_New_K(L2_header_rec.id, l_api_version,OKC_API.G_FALSE,x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
   end if;

-- raise event
  OKC_K_SIGN_ASMBLR_PVT.acn_assemble(
    p_api_version		=> l_api_version,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_contract_id     	=> p_contract_id);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

--end
  OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
	 db_failed('OKC_SIGN');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	 db_failed('OKC_SIGN');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
	 db_failed('OKC_SIGN');
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
end k_signed;

end OKE_CONTRACT_APPROVAL_PVT;

/
