--------------------------------------------------------
--  DDL for Package Body OKC_CHANGE_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CHANGE_CONTRACT_PVT" as
/* $Header: OKCRCHKB.pls 120.1 2005/11/21 12:06:16 dneetha noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CHANGE_CONTRACT_PVT';
  G_LEVEL				CONSTANT VARCHAR2(4)   := '_PVT';
  l_api_version               CONSTANT NUMBER := 1;
  G_FND_APP				CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
--
  G_PROCESS_NOT_FOR_APPROVAL CONSTANT   varchar2(200) := 	'OKC_PROCESS_NOT_FOR_APPROVAL';
  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 			'WF_ITEM';
  G_WF_P_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_PROCESS';
--
  G_PROCESS_NOTFOUND CONSTANT   varchar2(200) := 		'OKC_PROCESS_NOT_FOUND';
--
  G_WF_NOT_PURGED CONSTANT   varchar2(200) := 			'OKC_WF_NOT_PURGED';
--  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 		'WF_ITEM';
  G_KEY_TOKEN CONSTANT   varchar2(200) := 			'WF_KEY';
--
  G_CRT_NOT_ON_APPROVAL CONSTANT   varchar2(200) := 		'OKC_PROCESS_NOT_ACTIVE';
--
  G_A_NO_U_PRIVILEGE CONSTANT   varchar2(200) := 		'OKC_USER_NO_RIGHT_TO_CHANGE';
  G_USER_NAME	CONSTANT	varchar2(200)	:=		'USER_NAME';
--
  G_NO_U_PRIVILEGE CONSTANT   varchar2(200) := 'OKC_NO_RIGHT_TO_CHANGE';
  G_ADMINISTRATOR_REQUIRED CONSTANT   varchar2(200) := 'OKC_ADMINISTRATOR_REQUIRED';
--

-- Start of comments
--
-- Procedure Name  : change_approval_start
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

CURSOR cur_header_aa (p_contract_id number)IS
SELECT k.estimated_amount,k.scs_code,scs.cls_code,k.sts_code
 FROM OKC_K_HEADERS_B K,
	 OKC_SUBCLASSES_B SCS
WHERE k.id = p_contract_id
 AND  k.scs_code = scs.code;

 l_scs_code okc_subclasses_v.code%type;
 l_k_status_code okc_k_headers_v.sts_code%type;
 l_cls_code okc_subclasses_v.cls_code%type;
 l_estimated_amount number;
procedure change_approval_start(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2
			) is

--san
Cursor cur_chg(chq_id number) IS
Select datetime_request
FROM OKC_CHANGE_REQUESTS_B where
ID=chq_id;
l_chgreq_date  OKC_CHANGE_REQUESTS_V.DATETIME_REQUEST%TYPE;
--end san

l_api_name                     CONSTANT VARCHAR2(30) := 'change_approval_start';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l1_crtv_rec OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
L1_CPSV_REC  OKC_CONTRACT_PUB.cpsv_rec_type;
L2_CPSV_REC  OKC_CONTRACT_PUB.cpsv_rec_type;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
--
--
l_contract_id number;
l_contract_number varchar2(120);
l_contract_number_modifier varchar2(120);
l_k_short_description varchar2(4000);
l_crt_name varchar2(150);
l_crt_short_description varchar2(4000);
l_key varchar2(240);
l_auth_user_id number;
l_auth_username varchar2(100);
l_requestor varchar2(240);
l_signature_required_yn varchar2(3);
--
l_chreq_date date;
cursor key_csr is
  select
	K.ID 	CONTRACT_ID,
	K.CONTRACT_NUMBER,
	K.CONTRACT_NUMBER_MODIFIER,
	K.SHORT_DESCRIPTION K_SHORT_DESCRIPTION,
	C.NAME CRT_NAME,
	C.DATETIME_REQUEST,
	C.SHORT_DESCRIPTION CRT_SHORT_DESCRIPTION,
	substr(K.CONTRACT_NUMBER
		||K.CONTRACT_NUMBER_MODIFIER
		||C.NAME,1,240) KEY,
--	NVL(C.USER_ID,fnd_global.user_id) AUTH_USER_ID,
	NVL(C.USER_ID,OKC_API.G_MISS_NUM) AUTH_USER_ID,
	U.USER_NAME AUTH_USERNAME,
	C.AUTHORITY REQUESTOR,
	C.SIGNATURE_REQUIRED_YN
  from okc_change_requests_v C,
	  OKC_K_PROCESSES cpr,
	  OKC_K_HDR_AGREEDS_V K,
	  fnd_user_view U
  where C.ID = p_change_request_id
    and K.ID = C.CHR_ID
    and cpr.crt_id = C.ID
   -- and U.USER_ID = NVL(cpr.USER_ID,OKC_API.G_MISS_NUM);
    and U.USER_ID = NVL(cpr.USER_ID,fnd_global.user_id);
--
--
l_wf_name varchar2(150);
l_wf_process_name varchar2(150);
l_usage varchar2(60);
l_process_id number;
--
cursor process_def_csr is
  select PDF.ID, PDF.WF_NAME, PDF.WF_PROCESS_NAME, PDF.USAGE
  from okc_k_processes KP,
	OKC_PROCESS_DEFS_B PDF
     where KP.crt_id = p_change_request_id
	and PDF.ID = KP.PDF_ID
  and PDF.begin_date<=sysdate
  and (PDF.end_date is NULL or PDF.end_date>=sysdate)
  and PDF.PDF_TYPE = 'WPS';
--
--
l_q varchar2(1);
--
cursor for_purge_csr is
  select '!'
  from WF_ITEMS
  where item_type = l_wf_name
   and item_key = l_key;
--
-- because of bug in lock API
--
cursor k_pid is
  select ID,OBJECT_VERSION_NUMBER
  from okc_k_processes
  where CRT_ID = p_change_request_id
	for update of process_id nowait;
--
--
L_PAR_NAME      	VARCHAR2(150);
L_PAR_TYPE       VARCHAR2(90);
L_PAR_VALUE   VARCHAR2(2000);
--
cursor defined_parameters_csr is
  select
    NAME,
    DATA_TYPE,
    DEFAULT_VALUE
  from OKC_PROCESS_DEF_PARAMETERS_V
  where PDF_ID = l_process_id;
--
--
L_NLS_VALUE VARCHAR2(30);
begin

MO_GLOBAL.INIT('OKS');
--
-- start activity
--
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
-- get values
--
  open key_csr;
  fetch key_csr into
	l_contract_id,
	l_contract_number,
	l_contract_number_modifier,
	l_k_short_description,
	l_crt_name,
	l_chreq_date,
	l_crt_short_description,
	l_key,
	l_auth_user_id,
	l_auth_username,
	l_requestor,
	l_signature_required_yn;
  close key_csr;

-- No administrator specified
--
  If l_auth_user_id=OKC_API.G_MISS_NUM then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_ADMINISTRATOR_REQUIRED);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
--
-- authorised user has U privilege
-- Bug 2498302 Bypassed security check for administrator.
/*  if OKC_CONTRACT_APPROVAL_PUB.k_accesible(
			p_contract_id => l_contract_id,
			p_user_id => l_auth_user_id,
			p_level => 'U'
		     ) = OKC_API.G_FALSE
  then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_A_NO_U_PRIVILEGE,
                        p_token1       => G_USER_NAME,
                        p_token1_value => l_auth_username);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if; */
--
-- try to lock crt (will not be locked if approved or on approval etc.
-- message raised inside lock procedure
--
  l1_crtv_rec.id := p_change_request_id;
  OKC_CHANGE_REQUEST_PUB.lock_change_request(
    p_api_version		=> l_api_version,
    x_return_status	=> l_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_crtv_rec		=> l1_crtv_rec);
  IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
-- get wf name
--
  open process_def_csr;
  fetch process_def_csr into l_process_id, L_WF_NAME, L_WF_PROCESS_NAME, L_USAGE;
  close process_def_csr;
  if (L_WF_NAME is NULL) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_PROCESS_NOTFOUND);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
  if (L_USAGE <> 'CHG_REQ_APPROVE') then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_PROCESS_NOT_FOR_APPROVAL,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME,
                        p_token2       => G_WF_P_NAME_TOKEN,
                        p_token2_value => L_WF_PROCESS_NAME);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
-- purge previous item if exists
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
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_WF_NOT_PURGED,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    end;
  end;
  end if;
--
-- update contract process.process_id with key
--
  begin
    savepoint BECAUSE_OF_BUG_IN_lock;
    open k_pid;
    fetch k_pid into L1_CPSV_REC.id,L1_CPSV_REC.object_version_number;
    close k_pid;
  exception
    when others then
	rollback to BECAUSE_OF_BUG_IN_lock;
      OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
      raise OKC_API.G_EXCEPTION_ERROR;
  end;
    L1_CPSV_REC.PROCESS_ID := L_KEY;
    OKC_CONTRACT_PUB.update_contract_process(
      p_api_version		=> l_api_version,
      x_return_status	=> l_return_status,
      x_msg_count		=> l_msg_count,
      x_msg_data		=> l_msg_data,
      p_cpsv_rec		=> L1_CPSV_REC,
      x_cpsv_rec		=> L2_CPSV_REC);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	rollback to BECAUSE_OF_BUG_IN_lock;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	rollback to BECAUSE_OF_BUG_IN_lock;
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    wf_engine.CreateProcess( ItemType => L_WF_NAME,
				 ItemKey  => L_KEY,
				 process  => L_WF_PROCESS_NAME);
    wf_engine.SetItemUserKey (ItemType	=> L_WF_NAME,
					ItemKey		=> L_KEY,
					UserKey		=> L_KEY);
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
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> l_contract_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'CONTRACT_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> l_contract_id);
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
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION',
						avalue	=> l_k_short_description);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'K_SHORT_DESCRIPTION',
						avalue	=> l_k_short_description);
    end;
    begin
	wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CHANGE_REQUEST_ID',
						avalue	=> p_change_request_id);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
 	      				aname 	=> 'CHANGE_REQUEST_ID');
	    wf_engine.SetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CHANGE_REQUEST_ID',
						avalue	=> p_change_request_id);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CRT_NAME',
						avalue	=> l_crt_name);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CRT_NAME');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CRT_NAME',
						avalue	=> l_crt_name);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CRT_SHORT_DESCRIPTION',
						avalue	=> l_crt_short_description);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CRT_SHORT_DESCRIPTION');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CRT_SHORT_DESCRIPTION',
						avalue	=> l_crt_short_description);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'AUTH_USERNAME',
						avalue	=> l_auth_username);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'AUTH_USERNAME');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'AUTH_USERNAME',
						avalue	=> l_auth_username);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'REQUESTOR',
						avalue	=> l_requestor);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'REQUESTOR');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'REQUESTOR',
						avalue	=> l_requestor);
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SIGNATURE_REQUIRED_YN',
						avalue	=> l_signature_required_yn);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SIGNATURE_REQUIRED_YN');
	    wf_engine.SetItemAttrText (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'SIGNATURE_REQUIRED_YN',
						avalue	=> l_signature_required_yn);
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

  	open cur_header_aa(l_contract_id);
	fetch cur_header_aa into l_estimated_amount,l_scs_code,l_cls_code,l_k_status_code;
	close cur_header_aa;
  	open cur_chg(p_change_request_id);
	fetch cur_chg into l_chgreq_date;
	close cur_chg;

	OKC_CHG_REQ_ASMBLR_PVT.acn_assemble(p_api_version    => 1,
                                         p_init_msg_list  => OKC_API.G_FALSE,
                                         x_return_status  => l_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_k_id           => l_contract_id,
		   						 p_k_number       => l_contract_number,
								 p_k_nbr_mod      => l_contract_number_modifier,
								 p_k_class          => l_cls_code,
								 p_k_subclass       => l_scs_code,
								 p_k_STATUS_CODE       => l_k_status_code,
								 p_estimated_amount => l_estimated_amount,
								 p_chreq_id => p_change_request_id,
								 p_chreq_date => l_chgreq_date
								);

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
  if (p_do_commit = OKC_API.G_TRUE) then
	commit;
  end if;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end change_approval_start;

-- Start of comments
--
-- Procedure Name  : wf_monitor_url
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function wf_monitor_url(
				p_change_request_id IN number,
				p_process_id IN number,
				p_mode IN varchar2
		    ) return varchar2 is
--
--  to be used by fnd_utilities.open_url
--
--
l_wf_name varchar2(150);
--
cursor wf_name_csr is
  select WF_NAME
  from OKC_PROCESS_DEFS_V
     where ID = p_process_id and PDF_TYPE = 'WPS';
--
--
l_key varchar2(240);
--
cursor wf_key_csr is
  select
	substr(K.CONTRACT_NUMBER
		||K.CONTRACT_NUMBER_MODIFIER
		||C.NAME,1,240) KEY
  from okc_change_requests_v C,
	OKC_K_HDR_AGREEDS_V K
  where C.ID = p_change_request_id
    and K.ID = C.CHR_ID;
--
--
l_q varchar2(1);
--
cursor wf_exist_csr is
  select '!'
  from WF_ITEMS
  where item_type = l_wf_name
   and item_key = l_key;
--
--
l_admin varchar2(3);
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
-- Procedure Name  : change_approval_stop
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_approval_stop(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2
			) is
l_api_name                     CONSTANT VARCHAR2(30) := 'change_approval_stop';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--
l_key varchar2(240);
l_contract_id number;
--
cursor key_csr is
  select
	K.ID 	CONTRACT_ID,
	substr(K.CONTRACT_NUMBER
		||K.CONTRACT_NUMBER_MODIFIER
		||C.NAME,1,240) KEY
  from okc_change_requests_v C,
	OKC_K_HDR_AGREEDS_V K
  where C.ID = p_change_request_id
    and K.ID = C.CHR_ID;
--
l_wf_name_active varchar2(150);
--
cursor approval_active_csr is
  select item_type
  from WF_ITEMS
  where item_type in
   ( select wf_name
     from OKC_PROCESS_DEFS_B
     where USAGE='CHG_REQ_APPROVE' and PDF_TYPE = 'WPS')
   and item_key = l_key
   and end_date is NULL;
begin
MO_GLOBAL.INIT('OKS');
--
-- start activity
--
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
-- get values
--
  open key_csr;
  fetch key_csr into l_contract_id, l_key;
  close key_csr;
--
-- user have U privilege?
--
  if OKC_CONTRACT_APPROVAL_PUB.k_accesible(
			p_contract_id => l_contract_id,
			p_user_id => fnd_global.user_id,
			p_level => 'U'
		     ) = OKC_API.G_FALSE
  then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_NO_U_PRIVILEGE);
    raise OKC_API.G_EXCEPTION_ERROR;
  end if;
--
-- get active wf_item
--
  open approval_active_csr;
  fetch approval_active_csr into l_wf_name_active;
  close approval_active_csr;
--
  if l_wf_name_active is NULL then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_CRT_NOT_ON_APPROVAL);
      raise OKC_API.G_EXCEPTION_ERROR;
  end if;
  wf_engine.abortprocess(l_wf_name_active,l_key);
  if (p_do_commit = OKC_API.G_TRUE) then
	commit;
  end if;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end change_approval_stop;

-- Start of comments
--
-- Procedure Name  : change_get_key
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_get_key(
				p_api_version	IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                        x_return_status	OUT NOCOPY	VARCHAR2,
                        x_msg_count	OUT NOCOPY	NUMBER,
                        x_msg_data	OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_do_commit IN VARCHAR2
			) is
l_api_name                    CONSTANT VARCHAR2(30) := 'change_get_key';
l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_crtv_rec 				OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
l_cpsv_rec				OKC_CONTRACT_PUB.cpsv_rec_type;
l1_cpsv_rec				OKC_CONTRACT_PUB.cpsv_rec_type;
l_dummy varchar2(1) := '?';
--
cursor in_use_csr is
  select '!'
  from
	OKC_CHANGE_REQUESTS_B 	C,
	OKC_K_PROCESSES 		P
  where C.chr_id = (select chr_id from OKC_CHANGE_REQUESTS_B
			where id = p_change_request_id)
    and C.ID <> p_change_request_id
    and C.datetime_applied is NULL
    and P.crt_id = C.id
    and P.in_process_yn = 'Y';
--
cursor process_csr is
  select id,object_version_number from OKC_K_PROCESSES
  where crt_id = p_change_request_id;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
  l_crtv_rec.id := p_change_request_id;
  OKC_CHANGE_REQUEST_PUB.lock_change_request(
				p_api_version	=> p_api_version,
                       	x_return_status	=> l_return_status,
                       	x_msg_count		=> x_msg_count,
                       	x_msg_data		=> x_msg_data,
    				p_restricted 	=> OKC_API.G_FALSE,
                       	p_crtv_rec		=> l_crtv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  open in_use_csr;
  fetch in_use_csr into l_dummy;
  close in_use_csr;
  IF (l_dummy = '!') then
      OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  open process_csr;
  fetch process_csr into l_cpsv_rec.id,l_cpsv_rec.object_version_number;
  close process_csr;
  OKC_CONTRACT_PUB.lock_contract_process(
				p_api_version	=> p_api_version,
                       	x_return_status	=> l_return_status,
                       	x_msg_count		=> x_msg_count,
                       	x_msg_data		=> x_msg_data,
                       	p_cpsv_rec		=> l_cpsv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_cpsv_rec.in_process_yn := 'Y';
  l_cpsv_rec.user_id := fnd_global.user_id;
  OKC_CONTRACT_PUB.update_contract_process(
				p_api_version	=> p_api_version,
                       	x_return_status	=> l_return_status,
                       	x_msg_count		=> x_msg_count,
                       	x_msg_data		=> x_msg_data,
    				p_cpsv_rec		=> l_cpsv_rec,
    				x_cpsv_rec		=> l1_cpsv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
  if (p_do_commit = OKC_API.G_TRUE) then
	commit;
  end if;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end change_get_key;

-- Start of comments
--
-- Procedure Name  : change_put_key
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_put_key(
				p_api_version	     IN	NUMBER,
                  	p_init_msg_list	IN	VARCHAR2 ,
                    x_return_status	OUT NOCOPY	VARCHAR2,
                    x_msg_count	     OUT NOCOPY	NUMBER,
                    x_msg_data	     OUT NOCOPY	VARCHAR2,
				p_change_request_id IN number,
				p_datetime_applied  IN date ,
				p_k_version         IN VARCHAR2,
				p_do_commit         IN VARCHAR2
			) is
l_api_name                    CONSTANT VARCHAR2(30) := 'change_put_key';
l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_crtv_rec 				OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
l1_crtv_rec 				OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
l_cpsv_rec				OKC_CONTRACT_PUB.cpsv_rec_type;
l1_cpsv_rec				OKC_CONTRACT_PUB.cpsv_rec_type;
--
cursor process_csr is
  select id,object_version_number from OKC_K_PROCESSES
  where crt_id = p_change_request_id;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
  l_crtv_rec.id := p_change_request_id;
  OKC_CHANGE_REQUEST_PUB.lock_change_request(
				p_api_version	=> p_api_version,
                       	x_return_status	=> l_return_status,
                       	x_msg_count		=> x_msg_count,
                       	x_msg_data		=> x_msg_data,
    				p_restricted 	=> OKC_API.G_FALSE,
                       	p_crtv_rec		=> l_crtv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
  open process_csr;
  fetch process_csr into l_cpsv_rec.id,l_cpsv_rec.object_version_number;
  close process_csr;
  OKC_CONTRACT_PUB.lock_contract_process(
				p_api_version	=> p_api_version,
                       	x_return_status	=> l_return_status,
                       	x_msg_count		=> x_msg_count,
                       	x_msg_data		=> x_msg_data,
                       	p_cpsv_rec		=> l_cpsv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
  l_cpsv_rec.in_process_yn := 'N';
  OKC_CONTRACT_PUB.update_contract_process(
				p_api_version	=> p_api_version,
                       	x_return_status	=> l_return_status,
                       	x_msg_count		=> x_msg_count,
                       	x_msg_data		=> x_msg_data,
    				p_cpsv_rec		=> l_cpsv_rec,
    				x_cpsv_rec		=> l1_cpsv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_crtv_rec.datetime_applied := p_datetime_applied;
  l_crtv_rec.applied_contract_version := p_k_version;
  OKC_CHANGE_REQUEST_PUB.update_change_request(
				p_api_version	=> p_api_version,
                       	x_return_status	=> l_return_status,
                       	x_msg_count		=> x_msg_count,
                       	x_msg_data		=> x_msg_data,
    				p_crtv_rec		=> l_crtv_rec,
    				x_crtv_rec		=> l1_crtv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--
  if (p_do_commit = OKC_API.G_TRUE) then
	commit;
  end if;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
end change_put_key;

-- for wf development

--
-- private procedure
-- to set context of db failure
--
procedure db_failed(p_oper varchar2) is
begin
      FND_MESSAGE.SET_NAME(application => G_APP_NAME,
                      	name     => 'OKC_DB_OPERATION_FAILED');
-- OKC_CH_APPROVE OKC_CH_REJECT --OKC_SIGN  OKC_APPROVE OKC_REVOKE
      FND_MESSAGE.SET_TOKEN(token => 'OPERATION',
                      	value     => p_oper,
				translate => TRUE);
      FND_MSG_PUB.add;
end db_failed;

-- Start of comments
--
-- Procedure Name  : change_request_approved
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_request_approved(
				p_change_request_id IN number,
                  	x_return_status	OUT NOCOPY	VARCHAR2
		    		) is
l_crtv_rec 		OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
l1_crtv_rec 	OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
cursor lock_csr is
  select ID
  from okc_change_requests_B
  where ID = p_change_request_id
  for update of crs_code, datetime_approved, datetime_rejected
  nowait;
  Cursor Cur_header is
  select k.id,k.contract_number,k.contract_number_modifier,k.scs_code,
		 scs.cls_code,k.estimated_amount,k.sts_code
  from okc_k_headers_b k,
	  okc_subclasses_b scs,
	  okc_change_requests_b crt
 where crt.chr_id = k.id
   and k.scs_code = scs.code
   and crt.id = p_change_request_id;
l_chr_id number;
l_contract_number okc_k_headers_v.contract_number%type;
l_k_status_code okc_k_headers_v.sts_code%type;
l_contract_modifier okc_k_headers_v.contract_number_modifier%type;
begin
MO_GLOBAL.INIT('OKS');
  savepoint change_request_approved;
  open lock_csr;
  fetch lock_csr into l_crtv_rec.id;
  close lock_csr;
  l_crtv_rec.datetime_approved := sysdate;
  l_crtv_rec.datetime_rejected := NULL;
  l_crtv_rec.crs_code := 'APP';
  OKC_CHANGE_REQUEST_PUB.update_change_request(
				p_api_version	=> l_api_version,
                       	x_return_status	=> x_return_status,
                       	x_msg_count		=> l_msg_count,
                       	x_msg_data		=> l_msg_data,
    				p_crtv_rec		=> l_crtv_rec,
    				x_crtv_rec		=> l1_crtv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

   OPEN cur_header;
   FETCH cur_header into l_chr_id,l_contract_number,l_contract_modifier,l_scs_code,l_cls_code,
   l_estimated_amount,l_k_status_code;
   CLOSE cur_header;

	OKC_CHG_APR_ASMBLR_PVT.acn_assemble(p_api_version      => 1,
                                         p_init_msg_list    => OKC_API.G_FALSE,
                                         x_return_status    => x_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
								 p_k_class          => l_cls_code,
								 p_k_subclass       => l_scs_code,
								 p_k_status_code    => l_k_status_code,
								 p_estimated_amount => l_estimated_amount,
                                         p_k_id             => l_chr_id,
		   						 p_k_number         => l_contract_number,
								 p_k_nbr_mod        => l_contract_modifier,
								 p_chapp_date       => sysdate,
								 p_change_id        => p_change_request_id
								  );

     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
exception
when OKC_API.G_EXCEPTION_ERROR then
  rollback to change_request_approved;
	 db_failed('OKC_CH_APPROVE');
  x_return_status := OKC_API.G_RET_STS_ERROR;
when others then
  rollback to change_request_approved;
	 db_failed('OKC_CH_APPROVE');
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end change_request_approved;

-- Start of comments
--
-- Procedure Name  : change_request_rejected
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure change_request_rejected(
				p_change_request_id IN number,
                  	x_return_status	OUT NOCOPY	VARCHAR2
		    		) is
l_crtv_rec 		OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
l1_crtv_rec 	OKC_CHANGE_REQUEST_PUB.crtv_rec_type;
l_msg_count NUMBER;
l_msg_data varchar2(2000);
cursor lock_csr is
  select ID
  from okc_change_requests_b
  where ID = p_change_request_id
  for update of crs_code, datetime_approved, datetime_rejected
  nowait;
  Cursor Cur_header is
  select k.id,k.contract_number,k.contract_number_modifier,k.scs_code,scs.cls_code,
  k.estimated_amount,k.sts_code
  from okc_k_headers_b k,
	  okc_subclasses_b scs,
	  okc_change_requests_b crt
 where crt.chr_id = k.id
   and k.scs_code = scs.code
   and crt.id = p_change_request_id;

l_chr_id number;
l_contract_number okc_k_headers_v.contract_number%type;
l_k_status_code okc_k_headers_v.sts_code%type;
l_contract_modifier okc_k_headers_v.contract_number_modifier%type;
begin
MO_GLOBAL.INIT('OKS');
  savepoint change_request_rejected;
  open lock_csr;
  fetch lock_csr into l_crtv_rec.id;
  close lock_csr;
  l_crtv_rec.datetime_approved := NULL;
  l_crtv_rec.datetime_rejected := sysdate;
  l_crtv_rec.crs_code := 'REJ';
  OKC_CHANGE_REQUEST_PUB.update_change_request(
				p_api_version	=> l_api_version,
                       	x_return_status	=> x_return_status,
                       	x_msg_count		=> l_msg_count,
                       	x_msg_data		=> l_msg_data,
    				p_crtv_rec		=> l_crtv_rec,
    				x_crtv_rec		=> l1_crtv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
   OPEN cur_header;
   FETCH cur_header into l_chr_id,l_contract_number,l_contract_modifier,l_scs_code,
   l_cls_code,l_estimated_amount,l_k_status_code;
   CLOSE cur_header;
	OKC_CHG_REJ_ASMBLR_PVT.acn_assemble(p_api_version      => 1,
                                         p_init_msg_list    => OKC_API.G_FALSE,
                                         x_return_status    => x_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         p_k_id             => l_chr_id,
		   						 p_k_number         => l_contract_number,
								 p_k_nbr_mod        => l_contract_modifier,
								 p_chrej_date       => sysdate,
								 p_change_id        => p_change_request_id,
								 p_k_class          => l_cls_code,
								 p_k_subclass       => l_scs_code,
								 p_k_status_code       => l_k_status_code,
								 p_estimated_amount => l_estimated_amount
								  );

     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
exception
when OKC_API.G_EXCEPTION_ERROR then
  rollback to change_request_rejected;
	 db_failed('OKC_CH_REJECT');
  x_return_status := OKC_API.G_RET_STS_ERROR;
when others then
  rollback to change_request_rejected;
	 db_failed('OKC_CH_REJECT');
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end change_request_rejected;

end OKC_CHANGE_CONTRACT_PVT;

/
